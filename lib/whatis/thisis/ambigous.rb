class WhatIs
  class ThisIs
    class Ambigous
      # @return [Infoboxer::MediaWiki::Page]
      attr_reader :page
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

      # @return [Description]
      def describe(help: true)
        Description.new(
          "#{self}\n" +
            variants.map { |link| "  #{link.inspect}: #{link.description}" }.join("\n") +
            describe_help(help)
        )
      end

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
