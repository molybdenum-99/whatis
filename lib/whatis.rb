require 'infoboxer'
require 'geo/coord'

class WhatIs
  AMBIGOUS_CATEGORY = 'Category:All disambiguation pages'.freeze

  class << self
    def [](lang)
      all[lang]
    end

    def this(*titles, **options)
      self[:en].this(*titles, **options)
    end

    private

    def all
      @all = Hash.new { |h, lang| h[lang] = WhatIs.new(lang) }
    end
  end

  attr_reader :infoboxer

  def initialize(language = :en)
    @infoboxer = Infoboxer.wikipedia(language)
  end

  def this(*titles, **options)
    @infoboxer
      .get_h(*titles) { |req| setup_request(req, **options) }
      .map { |title, page| [title, ThisIs.create(self, title, page)] }.to_h
  end

  def search(title, limit = 5)
    infoboxer.search(title, limit: limit, &method(:setup_request))
          .map { |page| ThisIs.create(@owner, page.title, page) }
  end

  private

  def setup_request(request, categories: false, languages: false, **options)
    request = request
      .prop(:coordinates, :categories).prop(:hidden) # hidden categories
      .prop(:extracts).sentences(1)
      .prop(:pageimages).prop(:original)
      .prop(:pageterms)
    # We fetch just "disambig" category if not requested otherwise
    request = request.categories(AMBIGOUS_CATEGORY) unless categories
    if languages
      request = request.prop(:langlinks)
      request = request.lang(languages) unless languages == true
    end
    request
  end
end

require_relative 'whatis/refinements'
require_relative 'whatis/thisis'
