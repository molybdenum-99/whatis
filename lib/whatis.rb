require 'infoboxer'
require 'geo/coord'

class WhatIs
  AMBIGOUS_CATEGORY = 'Category:All disambiguation pages'.freeze

  class ThisIs
    EXTRACTORS = {
      canonical: ->(page) { page.title },
      coordinates: ->(page) {
        coord = page.source['coordinates']&.first or return nil
        Geo::Coord.from_h(coord)
      },
      categories: ->(page) {
        Array(page.source['categories']).map { |c| c['title'].split(':', 2).last }
      },
      languages: ->(page) {
        Array(page.source['langlinks']).map { |l| [l['lang'], l['*']] }.to_h
      }
    }.freeze

    class NotFound
      attr_reader :title

      def initialize(infoboxer, title)
        @infoboxer = infoboxer
        @title = title
      end

      def inspect
        "#<ThisIs::NotFound #{title}>"
      end
    end

    class Ambigous
      attr_reader :title, :page

      def initialize(infoboxer, title, page)
        @infoboxer = infoboxer
        @title = title
        @page = page
      end

      def inspect
        "#<ThisIs::Ambigous #{page.title}>"
      end
    end

    def self.create(infoboxer, title, page)
      case
      when page.nil?
        NotFound.new(infoboxer, title)
      when Array(page.source['categories']).any? { |c| c['title'] == AMBIGOUS_CATEGORY }
        Ambigous.new(infoboxer, title, page)
      else
        new(infoboxer, title, page)
      end
    end

    attr_reader :title, :page

    def initialize(infoboxer, title, page)
      @infoboxer = infoboxer
      @title, @page = title, page
      @data = EXTRACTORS.map { |sym, proc| [sym, proc.call(page)] }.to_h
    end

    def inspect
      "#<ThisIs #{canonical} #{coordinates}>"
    end

    EXTRACTORS.keys.each { |title| define_method(title) { @data[title] } }
  end

  def initialize(language = :en)
    @infoboxer = Infoboxer.wikipedia(language)
  end

  def this(*titles, **options)
    @infoboxer
      .get_h(*titles) { |req| setup_request(req, **options) }
      .map { |title, page| ThisIs.create(@infoboxer, title, page) }
  end

  private

  def setup_request(request, categories: false, languages: false, **options)
    request = request.prop(:coordinates, :categories)
    # We fetch just "disambig" category if not requested otherwise
    request = request.categories(AMBIGOUS_CATEGORY) unless categories
    if languages
      request = request.prop(:langlinks)
      request = request.lang(*languages) unless languages == true
    end
    request
  end
end
