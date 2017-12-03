class WhatIs
  using Refinements

  class ThisIs
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
