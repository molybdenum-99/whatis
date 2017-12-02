class WhatIs
  class ThisIs
    class Ambigous < ThisIs
      attr_reader :variants

      def initialize(*)
        super
        @variants = page.wikipath('//ListItem')
          .reject { |item| item.wikilinks.empty? }
          .map { |item|
            Link.new(
              @owner,
              item.wikilinks.first.link,
              section: item.in_sections.map(&:heading).map(&:text_).reverse.reject(&:empty?).join('/'),
              description: item.children.map(&:text).join
            )
          }
      end

      def inspect
        "#<ThisIs::Ambigous #{title} (#{variants.count} options)>"
      end

      def describe
        "#{inspect}\n" +
          variants.map { |link| "  #{link.inspect}: #{link.description}" }.join("\n")
      end

      def resolve_all
        @owner.this(*variants.map(&:title))
      end
    end
  end
end
