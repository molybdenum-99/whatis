class WhatIs
  class ThisIs
    EXTRACTORS = {
      title: ->(page) { page.title },
      coordinates: ->(page) {
        coord = page.source['coordinates']&.first or return nil
        Geo::Coord.from_h(coord)
      },
      categories: ->(page) {
        Array(page.source['categories'])
          .reject { |c| c.key?('hidden') }
          .map { |c| c['title'].split(':', 2).last }
      },
      languages: ->(page) {
        Array(page.source['langlinks']).map { |l| [l['lang'], l['*']] }.to_h
      }
    }.freeze

    def self.create(owner, title, page)
      case
      when page.nil?
        NotFound.new(owner, title)
      when Array(page.source['categories']).any? { |c| c['title'] == AMBIGOUS_CATEGORY }
        Ambigous.new(owner, page)
      else
        new(owner, page)
      end
    end

    attr_reader :page

    def initialize(owner, page)
      @owner = owner
      @page = page
      @data = EXTRACTORS.map { |sym, proc| [sym, proc.call(page)] }.to_h
    end

    INSPECT = InTem.parse('#<{class_name} {title}{languages | ifcount 1 | first | join ":" | prepend "/"}{coordinates | not nil? | surround " (", ")"}>').freeze

    def inspect
      INSPECT.render(@data.merge(class_name: self.class.name.sub('WhatIs::', '')))
    end

    def describe
      maxlength = @data.keys.map(&:length).max
      "ThisIs #{title}\n" +
        @data
          .reject { |_, v| v.nil? || v.respond_to?(:empty?) && v.empty? }
          .map { |k, v| "  #{k.to_s.rjust(maxlength)}: #{v.inspect}" }.join("\n")
    end

    EXTRACTORS.keys.each { |title| define_method(title) { @data[title] } }
  end
end

require_relative 'thisis/ambigous'
require_relative 'thisis/notfound'
