require 'infoboxer'
require 'geo/coord'
require 'intem'

class WhatIs
  AMBIGOUS_CATEGORY = 'Category:All disambiguation pages'.freeze

  class ThisIs
    EXTRACTORS = {
      title: ->(page) { page.title },
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

      def initialize(owner, title)
        @owner = owner
        @title = title
      end

      def search(limit = 5)
        @owner.search(title, limit)
      end

      def inspect
        "#<ThisIs::NotFound #{title}>"
      end
    end

    class Ambigous < ThisIs
      attr_reader :page

      #def initialize(infoboxer, title, page)
        #@infoboxer = infoboxer
        #@title = title
        #@page = page
      #end

      #def inspect
        #"#<ThisIs::Ambigous #{page.title}>"
      #end
    end

    def self.create(owner, title, page)
      case
      when page.nil?
        NotFound.new(owner, title)
      when Array(page.source['categories']).any? { |c| c['title'] == AMBIGOUS_CATEGORY }
        Ambigous.new(owner, page)
      else
        new(owner, page)
      end
    end

    attr_reader :page

    def initialize(owner, page)
      @owner = owner
      @page = page
      @data = EXTRACTORS.map { |sym, proc| [sym, proc.call(page)] }.to_h
    end

    INSPECT = InTem.parse('#<{class_name} {title}{coordinates | not nil? | prepend " (" | append ")"}>').freeze

    def inspect
      INSPECT.render(@data.merge(class_name: self.class.name.sub('WhatIs::', '')))
    end

    EXTRACTORS.keys.each { |title| define_method(title) { @data[title] } }
  end

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
    request = request.prop(:coordinates, :categories)
    # We fetch just "disambig" category if not requested otherwise
    request = request.categories(AMBIGOUS_CATEGORY) unless categories
    if languages
      request = request.prop(:langlinks)
      request = request.lang(languages) unless languages == true
    end
    request
  end
end
