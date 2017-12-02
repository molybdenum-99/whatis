class WhatIs
  module Refinements
    refine String do
      def append(after)
        "#{self}#{after}"
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
  end
end