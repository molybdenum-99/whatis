class WhatIs
  module Refinements
    refine String do
      alias append <<

      def surround(before, after = before)
        "#{before}#{self}#{after}"
      end
    end
  end
end
