class WhatIs
  class ThisIs
    class NotFound
      # @return [String]
      attr_reader :title

      # @private
      def initialize(owner, title)
        @owner = owner
        @title = title
      end

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
