require 'infoboxer'
require 'geo/coord'

class WhatIs
  AMBIGOUS_CATEGORIES = {
    be: ['Катэгорыя:Неадназначнасці'],
    en: ['Category:All disambiguation pages', 'Category:All set index articles'],
    ru: ['Категория:Страницы значений по алфавиту'],
    uk: ['Категорія:Всі статті визначеного індексу', 'Категорія:Всі сторінки неоднозначності статей']
  }.freeze

  class Description < String
    alias inspect to_s # Allows pretty inspect of multi-line descriptions
  end

  class << self
    def [](lang)
      all[lang]
    end

    def these(*titles, **options)
      self[:en].these(*titles, **options)
    end

    def this(title, **options)
      self[:en].this(title, **options)
    end

    private

    def all
      @all ||= Hash.new { |h, lang| h[lang] = WhatIs.new(lang) }
    end
  end

  attr_reader :language

  def initialize(language = :en)
    @language = language
    @infoboxer = Infoboxer.wikipedia(language)
  end

  def these(*titles, **options)
    titles.any? or
      fail(ArgumentError, "Usage: `these('Title 1', 'Title 2', ..., **options). At least one title is required.")
    @infoboxer
      .get_h(*titles) { |req| setup_request(req, **options) }
      .map { |title, page| [title, ThisIs.create(self, title, page)] }.to_h
  end

  def this(title, **options)
    these(title, **options).values.first
  end

  def search(title, limit = 5, **options)
    @infoboxer
      .search(title, limit: limit) { |req| setup_request(req, **options) }
      .map { |page| ThisIs.create(self, page.title, page) }
  end

  def inspect
    "#<WhatIs(#{language}). Usage: .this(*pages, **options)>"
  end

  def ambigous_categories
    AMBIGOUS_CATEGORIES[language.to_sym]
  end

  private

  def setup_request(request, categories: false, languages: false, **) # rubocop:disable Metrics/MethodLength
    request = request
      .prop(:coordinates, :categories).prop(:hidden) # "hidden" category field to filter them out
      .prop(:extracts).sentences(1)
      .prop(:pageimages).prop(:original)
      .prop(:pageterms)
    # We fetch just "disambig" category if not requested otherwise
    request = request.categories(*ambigous_categories) unless categories
    if languages
      request = request.prop(:langlinks)
      request = request.lang(languages) unless languages == true
    end
    request
  end
end

require_relative 'whatis/refinements'
require_relative 'whatis/thisis'
