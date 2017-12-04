class WhatIs
  class ThisIs
    # Represents not found page, allowing to search for term through Wikipedia API.
    #
    # You should never create instances of this class directly, but rather obtain it from {WhatIs#this}
    # and {WhatIs#these}.
    #
    # @example
    #   notfound = WhatIs.this('Guardians Of The Galaxy') # Wikipedia fetching is case-sensitive
    #   # => #<ThisIs::NotFound Guardians Of The Galaxy>
    #   notfound.search(3)
    #   # => [#<ThisIs::Ambigous Guardians of the Galaxy (11 options)>, #<ThisIs Guardians of the Galaxy (film)>, #<ThisIs Guardians of the Galaxy Vol. 2>]
    #
    class NotFound
      # @return [String]
      attr_reader :title

      # @private
      def initialize(owner, title)
        @owner = owner
        @title = title
      end

      # Searches for requested entity name through Wikipedia API.
      #
      # See {WhatIs#this} for options explanation.
      #
      # @param limit [Integer] Number of results to return.
      # @param options [Hash]
      # @option options [true, String, Symbol] :languages
      # @option options [true, false] :categories
      # @return [Array<ThisIs, ThisIs::Ambigous>]
      def search(limit = 5, **options)
        @owner.search(title, limit, **options)
      end

      # @return [String]
      def inspect
        "#<ThisIs::NotFound #{title}>"
      end

      # @return [String]
      def to_s
        "#{title}: not found"
      end

      # @return [Hash]
      def to_h
        {type: 'ThisIs::NotFound', title: title}
      end

      # @return [String]
      def to_json(opts)
        to_h.to_json(opts)
      end

      # @return [Description]
      def describe(help: true)
        Description.new("#{self}#{describe_help(help)}")
      end

      private

      def describe_help(render = true)
        return '' unless render
        "\n  Usage: .search(limit, **options)"
      end
    end
  end
end
