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

      def to_s
        "#{title}: not found"
      end

      def to_h
        {type: 'ThisIs::NotFound', title: title}
      end

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
