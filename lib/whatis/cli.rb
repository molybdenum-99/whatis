class WhatIs
  # @private
  class CLI
    def initialize(titles, options)
      @whatis = WhatIs[options.language]
      @titles = titles
      @options = {categories: options.categories, languages: options.languages}
      @format = options.format
    end

    def run
      __send__("#{@format}_format", @whatis.these(*@titles, **@options).values)
    end

    private

    def short_format(objects)
      formatter = Formatter.new
      objects.map(&formatter.method(:call)).join("\n")
    end

    def long_format(objects)
      objects.map { |o| o.describe(help: false) }.join("\n")
    end

    def json_format(objects)
      require 'json'
      JSON.pretty_generate(objects.map(&:to_h))
    end
  end
end
