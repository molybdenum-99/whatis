class WhatIs
  using Refinements

  class ThisIs
    # Represents link to some entity that can be resolved to proper entity definition.
    #
    # You should never create instances of this class directly, it occurs as variant links from
    # {Ambigous}, and as {ThisIs::languages} links.
    #
    # @example
    #   # Ambigous variants link
    #   a = WhatIs.this('Bela Crkva')
    #   # => #<ThisIs::Ambigous Bela Crkva (6 options)>
    #   a.variants[0]
    #   # => #<ThisIs::Link Bela Crkva, Banat>
    #   a.variants[0].resolve
    #   # => #<ThisIs Bela Crkva, Banat [img] {44.897500,21.416944}>
    #
    #   # Languages link
    #   paris = WhatIs.this('Paris', languages: :ru)
    #   # => #<ThisIs Paris/Париж, [img] {48.856700,2.350800}>
    #   paris.languages
    #   # => {"ru"=>#<ThisIs::Link ru:Париж>}
    #   paris.languages['ru'].resolve(categories: true)
    #   # => #<ThisIs Париж, 10 categories [img] {48.833333,2.333333}>
    #
    class Link
      # @return [String]
      attr_reader :title
      # @private
      attr_reader :language

      # @private
      #   For pretty output only
      attr_reader :section, :description

      # @private
      def initialize(title, section: nil, owner: nil, language: nil, description: nil)
        @owner = owner
        @title = title
        @language = language&.to_s
        @section = section unless section == ''
        @description = description
      end

      # @return [String]
      def inspect
        "#<ThisIs::Link #{language&.append(':')}#{section&.append('/')}#{title}>"
      end

      alias to_s title

      # Resolves the link, fetching entity from Wikipedia API.
      #
      # See {WhatIs#this} for options explanation.
      #
      # @param options [Hash]
      # @option options [true, String, Symbol] :languages
      # @option options [true, false] :categories
      # @return [ThisIs, ThisIs::Ambigous]
      def resolve(**options)
        engine = @owner || language && WhatIs[language] or
          fail "Can't resolve #{inspect}"

        engine.this(title, **options)
      end

      # @private
      #   For tests only
      def ==(other)
        other.is_a?(Link) && other.language == language && other.title == title
      end
    end
  end
end
