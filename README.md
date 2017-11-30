**WTFer** (or Wikipedia Thing Foundation Extractor) is a quick probe for the meaning and metadata
of concepts through Wikipedia.

Example:

```ruby
# You have a lot of user-provided toponyms and want to find and normalize them:
cities = Wtfer.get('Warszav', 'Warsava', 'Berlin', 'Peking', 'Moskva', geo: true)
# .....
cities.each(&:describe)
Wtfer[:ru].get('Москва', geo: true, lang: :en).first
# => msk
msk.describe
msk.lang[:en].get

Wtfter.get('Pekin')

```

Non-geograpical examples:

## Usage

## How it works
