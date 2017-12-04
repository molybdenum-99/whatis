class WhatIs
  class ThisIs
    # Represents disambiguation page.
    #
    # You should never create instances of this class directly, but rather obtain it from {WhatIs#this}
    # and {WhatIs#these}.
    #
    # `Ambigous` consists of {#variants}, each of them represented by a {ThisIs::Link} which can
    # be {ThisIs::Link#resolve resolved}.
    #
    # @note This functionality (special wrapper for disambiguation
    #   pages) works only for those language Wikis which have their "disambiguation" category known
    #   to `WhatIs`. See {WhatIs::AMBIGOUS_CATEGORIES}.
    #
    # @example
    #   a = WhatIs.this('Bela Crkva')
    #   # => #<ThisIs::Ambigous Bela Crkva (6 options)>
    #   a.describe
    #   # => Bela Crkva: ambigous (6 options)
    #   #  #<ThisIs::Link Bela Crkva, Banat>: Bela Crkva, Banat, a town in Vojvodina, Serbia
    #   #  #<ThisIs::Link Bela Crkva, Krivogaštani>: Bela Crkva, Krivogaštani, a village in the Municipality of Krivogaštani, Macedonia
    #   #  #<ThisIs::Link Bela Crkva (Krupanj)>: Bela Crkva (Krupanj), a village in the Mačva District of Serbia
    #   #  #<ThisIs::Link Toplička Bela Crkva>: Toplička Bela Crkva, original name of the city of Kuršumlija, Serbia
    #   #  #<ThisIs::Link See also/Bila Tserkva>: Bila Tserkva (Біла Церква), a city in the Kiev Oblast of Ukraine
    #   #  #<ThisIs::Link See also/Byala Cherkva>: Byala Cherkva, a town in the Veliko Turnovo oblast of Bulgaria
    #   #
    #   #  Usage: .variants[0].resolve, .resolve_all
    #
    #   a.variants[0]
    #   # => #<ThisIs::Link Bela Crkva, Banat>
    #   a.variants[0].resolve
    #   # => #<ThisIs Bela Crkva, Banat [img] {44.897500,21.416944}>
    #   a.variants[0].resolve(categories: true)
    #   # => #<ThisIs Bela Crkva, Banat, 5 categories [img] {44.897500,21.416944}>
    #   a.resolve_all
    #   # => {"Bela Crkva, Banat"=>#<ThisIs Bela Crkva, Banat [img] {44.897500,21.416944}>, "Bela Crkva, Krivogaštani"=>#<ThisIs Bela Crkva, Krivogaštani {41.280833,21.345278}>, "Bela Crkva (Krupanj)"=>#<ThisIs Bela Crkva (Krupanj) [img] {44.395000,19.479400}>, "Toplička Bela Crkva"=>#<ThisIs Kuršumlija [img] {43.150000,21.266667}>, "Bila Tserkva"=>#<ThisIs Bila Tserkva [img] {49.798889,30.115278}>, "Byala Cherkva"=>#<ThisIs Byala Cherkva [img] {43.200000,25.300000}>}
    #
    class Ambigous
      # Original [Infoboxer page](http://www.rubydoc.info/gems/infoboxer/Infoboxer/MediaWiki/Page) data.
      # @return [Infoboxer::MediaWiki::Page]
      attr_reader :page

      # Each link can be {ThisIs::Link#resolve resolved} individually, like
      # `ambigous.variants[0].resolve`, or you can resolve them all at once with {#resolve_all}.
      #
      # @return [Array<ThisIs::Link>]
      attr_reader :variants

      # @private
      def initialize(owner, page)
        @owner = owner
        @page = page
        @variants = extract_variants
      end

      # @return [String]
      def title
        page.title
      end

      # @return [String]
      def inspect
        "#<ThisIs::Ambigous #{title} (#{variants.count} options)>"
      end

      # @return [String]
      def to_s
        "#{title}: ambigous (#{variants.count} options)"
      end

      # @return [Hash]
      def to_h
        {
          type: 'ThisIs::Ambigous',
          title: title,
          variants: variants.map(&:to_s)
        }
      end

      # @return [String]
      def to_json(opts)
        to_h.to_json(opts)
      end

      # @return [Description]
      def describe(help: true)
        Description.new(
          "#{self}\n" +
            variants.map { |link| "  #{link.inspect}: #{link.description}" }.join("\n") +
            describe_help(help)
        )
      end

      # Resolves all ambigous variants with one query.
      # See {WhatIs#this} for options explanation.
      #
      # @param options [Hash]
      # @option options [true, String, Symbol] :languages
      # @option options [true, false] :categories
      # @return [Hash{String => ThisIs}]
      def resolve_all(**options)
        @owner.these(*variants.map(&:title), **options)
      end

      private

      def describe_help(render = true)
        return '' unless render
        "\n\n  Usage: .variants[0].resolve, .resolve_all"
      end

      def extract_variants
        page.wikipath('//ListItem')
          .reject { |item| item.wikilinks.empty? }
          .map(&method(:item_to_link))
      end

      def item_to_link(item)
        Link.new(
          item.wikilinks.first.link,
          owner: @owner,
          section: item.in_sections.map(&:heading).map(&:text_).reverse.reject(&:empty?).join('/'),
          description: item.children.map(&:text).join
        )
      end
    end
  end
end
