class WhatIs
  class ThisIs
    class NotFound
      attr_reader :title

      def initialize(owner, title)
        @owner = owner
        @title = title
      end

      def search(limit = 5, **options)
        @owner.search(title, limit, **options)
      end

      def inspect
        "#<ThisIs::NotFound #{title}>"
      end

      def describe
        Description.new("#{inspect}\n  Usage: .search(limit)")
      end
    end
  end
end
