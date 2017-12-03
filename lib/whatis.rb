require 'infoboxer'
require 'geo/coord'
require 'backports/2.4.0/hash/transform_values'

# `WhatIs` is a simple entity resolver through Wikipedia.
#
# @example
#   # Simplest usage
#   WhatIs.this('Sparta') # => #<ThisIs Sparta [img] {37.081944,22.423611}>
#
#   # Additional options
#   WhatIs.this('Sparta', languages: :el, categories: true)
#   # => #<ThisIs Sparta/Αρχαία Σπάρτη, 7 categories [img] {37.081944,22.423611}>
#
#   # Several pages at once (in batch requests to Wikipedia API)
#   WhatIs.these('Paris', 'Athens', 'Rome')
#   # => {"Paris"=>#<ThisIs Paris [img] {48.856700,2.350800}>, "Athens"=>#<ThisIs Athens [img] {37.983972,23.727806}>, "Rome"=>#<ThisIs Rome [img] {41.900000,12.500000}>}
#
#   # Other language Wikipedia
#    WhatIs[:ru].this('Спарта') # => #<ThisIs Спарта [img]>
#
# See {#this} and {#these} methods docs for details on call sequence and options, and response classes:
#
# * {ThisIs} -- normal response object;
# * {ThisIs::Ambigous} -- response object representing disambiguation page;
# * {ThisIs::NotFound} -- response object for not found page, includes search for term service.
#
class WhatIs
  # This constant lists Wikipedia ambiguity categories per Wikipedia language. For {ThisIs::Ambigous}
  # feature to work for your language, this list should include it.
  AMBIGOUS_CATEGORIES = {
    be: ['Катэгорыя:Неадназначнасці'],
    en: ['Category:All disambiguation pages', 'Category:All set index articles'],
    ru: ['Категория:Страницы значений по алфавиту'],
    uk: ['Категорія:Всі статті визначеного індексу', 'Категорія:Всі сторінки неоднозначності статей']
  }.freeze

  # String-like class, with the only difference for how its #inspect is represented.
  #
  # Used for {ThisIs#describe} method for its answer to be readable in Ruby console (IRB or Pry)
  #
  # @example
  #   "foo\nbar"
  #   # => "foo\nbar"
  #   Description.new("foo\nbar")
  #   # => foo
  #   # bar
  #
  class Description < String
    alias inspect to_s # Allows pretty inspect of multi-line descriptions
  end

  class << self
    # @param lang [Symbol, String] Wikipedia version language code, usually two-letter ("en", "fr"),
    #   but not for all languages (for example, "be-x-old" or "zh-classical").
    #
    # @return [WhatIs]
    def [](lang)
      all[lang.to_s]
    end

    # Shortcut for `WhatIs[:en].these`, see {#these} for details.
    def these(*titles, **options)
      self[:en].these(*titles, **options)
    end

    # Shortcut for `WhatIs[:en].this`, see {#this} for details.
    def this(title, **options)
      self[:en].this(title, **options)
    end

    private

    def all
      @all ||= Hash.new { |h, lang| h[lang] = WhatIs.new(lang) }
    end
  end

  # @private
  attr_reader :language

  # @private
  def initialize(language = :en)
    @language = language
    @infoboxer = Infoboxer.wikipedia(language)
  end

  # @param titles [Array<String>]
  # @param options [Hash]
  # @return [Hash{String => ThisIs, ThisIs::Ambigous, ThisIs::NotFound}]
  def these(*titles, **options)
    titles.any? or
      fail(ArgumentError, "Usage: `these('Title 1', 'Title 2', ..., **options). At least one title is required.")
    @infoboxer
      .get_h(*titles) { |req| setup_request(req, **options) }
      .map { |title, page| [title, ThisIs.create(self, title, page)] }.to_h
  end

  # @param title [String]
  # @param options [Hash]
  # @return [ThisIs, ThisIs::Ambigous, ThisIs::NotFound]
  def this(title, **options)
    these(title, **options).values.first
  end

  # @return [String]
  def inspect
    "#<WhatIs(#{language}). Usage: .this(*pages, **options)>"
  end

  # @private
  # Used by {ThisIs::NotFound#search}
  def search(title, limit = 5, **options)
    @infoboxer
      .search(title, limit: limit) { |req| setup_request(req, **options) }
      .map { |page| ThisIs.create(self, page.title, page) }
  end

  # @private
  def ambigous_categories
    @ambigous_categories = AMBIGOUS_CATEGORIES.fetch(language.to_sym, [])
  end

  private

  def setup_request(request, categories: false, languages: false, **) # rubocop:disable Metrics/MethodLength
    request = request
      .prop(:coordinates)
      .prop(:extracts).sentences(1)
      .prop(:pageimages).prop(:original)
      .prop(:pageterms)

    request = setup_categories(request, categories)
    if languages
      request = request.prop(:langlinks)
      request = request.lang(languages) unless languages == true
    end
    request
  end

  def setup_categories(request, categories_requested)
    if categories_requested
      # Fetch all categories, include "hidden" flag to filter out internal
      request.prop(:categories).prop(:hidden)
    elsif !ambigous_categories.empty?
      # Fetch only "ambigous" categories, to tell ambigous pages out
      request.prop(:categories).categories(*ambigous_categories)
    else
      request
    end
  end
end

require_relative 'whatis/refinements'
require_relative 'whatis/thisis'
require_relative 'whatis/formatter'
