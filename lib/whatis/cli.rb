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
      __send__("#{@format}_format", @whatis.these(*@titles, **@options))
    end

    private

    def short_format(objects)
      formatter = Formatter.new
      objects.map { |title, o| formatter.call(title, o) }.join("\n")
    end

    def long_format(objects)
      objects.flat_map { |title, o|
        [
          '',
          title,
          '-' * title.length,
          o.describe(help: false)
        ]
      }.join("\n")
    end

    def json_format(objects)
      require 'json'
      JSON.pretty_generate(objects)
    end
  end
end
