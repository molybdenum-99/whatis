class WhatIs
  class ThisIs
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
  end
end
