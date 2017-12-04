class WhatIs
  using Refinements

  # @private
  class Formatter
    def call(title, object)
      str =
        case object
        when ThisIs
          format_thisis(object)
        when ThisIs::Ambigous
          format_ambigous(object)
        when ThisIs::NotFound
          format_notfound(object)
        end
      "#{title}: #{str}"
    end

    private

    def format_thisis(object)
      [
        object.title,
        object.coordinates&.to_s&.surround(' {', '}'),
        ' - ',
        short_description(object)
      ].join
    end

    def short_description(obj) # rubocop:disable Metrics/AbcSize
      case
      when obj.categories.any?
        obj.categories.sort.join('; ')
      when obj.languages.count == 1
        obj.languages.values.first
      when !obj.description.to_s.empty?
        obj.description
      else
        obj.extract
      end
    end

    def format_ambigous(object)
      "#{object.title}, #{object.variants.count} options - #{object.variants.join('; ')}"
    end

    def format_notfound(*)
      'not found'
    end
  end
end
