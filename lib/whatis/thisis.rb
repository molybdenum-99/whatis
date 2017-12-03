class WhatIs
  using Refinements

  # Represents one resolved entity, provides introspection and access to individual properties.
  # You should never create instances of this class directly, but rather obtain it from {WhatIs#this}
  # and {WhatIs#these}.
  #
  # @example
  #   paris = WhatIs.this('Paris')
  #   # => #<ThisIs Paris [img] {48.856700,2.350800}>
  #   paris.describe
  #   # => Paris
  #   #        title: "Paris"
  #   #  description: "capital city of France"
  #   #  coordinates: #<Geo::Coord 48.856700,2.350800>
  #   #      extract: "Paris (French pronunciation: ​[paʁi] ( listen)) is the capital and most populous city of France, with an administrative-limits area of 105 square kilometres (41 square miles) and a 2015 population of 2,229,621."
  #   #        image: "https://upload.wikimedia.org/wikipedia/commons/0/08/Seine_and_Eiffel_Tower_from_Tour_Saint_Jacques_2013-08.JPG"
  #   #
  #   paris.coordinates
  #   # => #<Geo::Coord 48.856700,2.350800>
  #   paris2 = paris.what(languages: :ru, categories: true) # fetch more details
  #   # => #<ThisIs Paris/Париж, 12 categories [img] {48.856700,2.350800}>
  #   paris2.describe
  #   # => Paris
  #   #        title: "Paris"
  #   #  description: "capital city of France"
  #   #  coordinates: #<Geo::Coord 48.856700,2.350800>
  #   #   categories: ["3rd-century BC establishments", "Capitals in Europe", "Catholic pilgrimage sites", "Cities in France", "Cities in Île-de-France", "Companions of the Liberation", "Departments of Île-de-France", "European culture", "French culture", "Paris", "Populated places established in the 3rd century BC", "Prefectures in France"]
  #   #    languages: {"ru"=>#<ThisIs::Link ru:Париж>}
  #   #      extract: "Paris (French pronunciation: ​[paʁi] ( listen)) is the capital and most populous city of France, with an administrative-limits area of 105 square kilometres (41 square miles) and a 2015 population of 2,229,621."
  #   #        image: "https://upload.wikimedia.org/wikipedia/commons/0/08/Seine_and_Eiffel_Tower_from_Tour_Saint_Jacques_2013-08.JPG"
  #   paris2.languages['ru'].resolve(categories: true)
  #   # => #<ThisIs Париж, 10 categories [img] {48.833333,2.333333}>
  #
  # See also:
  #
  # * {ThisIs::Ambigous} Representing disambiguation page, allows fetching variants.
  # * {ThisIs::NotFound} Representing not found entity, allows searching for possible options.
  class ThisIs
    # @private
    EXTRACTORS = {
      title: ->(page) { page.title },
      description: ->(page) { page.source.dig('terms', 'description', 0) },
      coordinates: ->(page) {
        coord = page.source['coordinates']&.first or return nil
        Geo::Coord.from_h(coord)
      },
      categories: ->(page) {
        Array(page.source['categories'])
          .reject { |c| c.key?('hidden') }
          .map { |c| c['title'].split(':', 2).last }
      },
      languages: ->(page) {
        Array(page.source['langlinks'])
          .map { |l| [l['lang'], l['*']] }
          .map { |code, title| [code, Link.new(title, language: code)] }.to_h
          .to_h
      },
      extract: ->(page) {
        # remove HTML tags
        # NB: Wikipedia "extracts" submodule has "plaintext=true" option, but it produces wrong 1-sentece
        # extracts (broken by first ".", which can be somewhere in transcription of the main entity).
        # HTML extracts, on the other hand, return proper sentences
        #
        # Link: https://en.wikipedia.org/w/api.php?action=help&modules=query%2Bextracts
        page.source['extract']&.gsub(/<[^>]+>/, '')&.strip
      },
      image: ->(page) { page.source.dig('original', 'source') }
    }.freeze

    # @private
    def self.create(owner, title, page)
      case
      when page.nil?
        NotFound.new(owner, title)
      when Array(page.source['categories']).any? { |c| owner.ambigous_categories.include?(c['title']) }
        Ambigous.new(owner, page)
      else
        new(owner, page)
      end
    end

    # Original [Infoboxer page](http://www.rubydoc.info/gems/infoboxer/Infoboxer/MediaWiki/Page) data.
    # @return [Infoboxer::MediaWiki::Page]
    attr_reader :page

    # @private
    def initialize(owner, page)
      @owner = owner
      @page = page
      @data = EXTRACTORS.map { |sym, proc| [sym, proc.call(page)] }.to_h
    end

    # @!method title
    #   Title of Wikipedia page
    #   @return [String]
    # @!method description
    #   Short entity description phrase from Wikidata. Not always present.
    #   @return [String]
    # @!method extract
    #   First sentence of Wikipedia page
    #   @return [String]
    # @!method coordinates
    #   Geographical coordinates, associated with the page, if known, wrapped in
    #   [Geo::Coord](https://github.com/zverok/geo_coord) type.
    #   @return [Geo::Coord]
    # @!method image
    #   URL of page's main image, if known.
    #   @return [Geo::Coord]
    # @!method categories
    #   List of page's categories, present only if page was fetched with `categories: true` option.
    #   @return [Array<String>]
    # @!method languages
    #   Hash of other language version of page. Present only if the page wath fetched with `:languages`
    #   option. Keys are language codes, values are {ThisIs::Link} objects, allowing to fetch corresponding
    #   entities with {ThisIs::Link#resolve}.
    #   @return [Hash{String => ThisIs::Link}]

    EXTRACTORS.each_key { |title| define_method(title) { @data[title] } }

    alias to_s title

    # @return [String]
    def inspect # rubocop:disable Metrics/AbcSize
      [
        'ThisIs ',
        title,
        languages.iff { |l| l.count == 1 }&.yield_self { |l| l.values.first.title.prepend('/') },
        languages.iff { |l| l.count > 1 }&.yield_self { |l| " +#{l.count} translations" },
        categories.iff(&:any?)&.yield_self { |c| ", #{c.count} categories" },
        image&.yield_self { ' [img]' },
        coordinates&.to_s&.surround(' {', '}')
      ].compact.join.surround('#<', '>')
    end

    # @return [Description]
    def describe(*)
      maxlength = @data.keys.map(&:length).max
      Description.new(
        "#{self}\n" +
          clean_data
            .map { |k, v| "  #{k.to_s.rjust(maxlength)}: #{v.inspect}" }.join("\n")
      )
    end

    # @return [Hash]
    def to_h
      {type: 'ThisIs'} # To be at the beginning of a hash
        .merge(@data)
        .merge(
          coordinates: coordinates&.to_s,
          languages: languages.transform_values(&:to_s)
        ).reject { |_, v| v.nil? || v.respond_to?(:empty?) && v.empty? }
    end

    # @return [String]
    def to_json(opts)
      to_h.to_json(opts)
    end

    # Refetch page with more data, see {WhatIs#this} for options explanation. Returns new object.
    #
    # @param options [Hash]
    # @option options [true, String, Symbol] :languages
    # @option options [true, false] :categories
    # @return [ThisIs]
    def what(**options)
      @owner.this(title, **options)
    end

    private

    def clean_data
      @data.reject { |_, v| v.nil? || v.respond_to?(:empty?) && v.empty? }
    end
  end
end

require_relative 'thisis/ambigous'
require_relative 'thisis/notfound'
require_relative 'thisis/link'
