class WhatIs
  # @private
  module Refinements
    refine String do
      def append(after)
        "#{self}#{after}"
      end

      def prepend(before)
        "#{before}#{self}"
      end

      def surround(before, after = before)
        "#{before}#{self}#{after}"
      end
    end

    refine Object do
      def yield_self
        yield self
      end

      def iff
        yield(self) ? self : nil
      end
    end

    refine Hash do
      def transform_keys
        map { |key, val| [yield(key), val] }.to_h
      end
    end
  end
end
