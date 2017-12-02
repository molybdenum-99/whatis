class WhatIs
  using Refinements

  class ThisIs
    class Link
      attr_reader :title, :section, :language, :description

      def initialize(title, section: nil, owner: nil, language: nil, description: nil)
        @owner = owner
        @title = title
        @language = language&.to_s
        @section = section unless section == ''
        @description = description
      end

      def inspect
        "#<ThisIs::Link #{language&.append(':')}#{section&.append('/')}#{title}>"
      end

      def resolve
        engine = @owner || language && WhatIs[language] or
          fail "Can't resolve #{inspect}"

        engine.this(title).values.first
      end

      def ==(other)
        other.is_a?(Link) && other.language == language && other.title == title
      end
    end
  end
end