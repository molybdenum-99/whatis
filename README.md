# WhatIs.this

**WhatIs.this** is a quick probe for the meaning and metadata of concepts through Wikipedia.

## Showcase

```ruby
require 'whatis'

sparta = WhatIs.this('Sparta')
# => #<ThisIs Sparta [img] {37.081944,22.423611}>
sparta.coordinates
# => #<Geo::Coord 37.081944,22.423611>
sparta.image
# => "https://upload.wikimedia.org/wikipedia/commons/6/6c/Sparta_territory.jpg"

sparta.describe
# => Sparta
#            title: "Sparta"
#      description: "city-state in ancient Greece"
#      coordinates: #<Geo::Coord 37.081944,22.423611>
#          extract: "Sparta (Doric Greek: ; Attic Greek: ) was a prominent city-state in ancient Greece."
#            image: "https://upload.wikimedia.org/wikipedia/commons/6/6c/Sparta_territory.jpg"

# Fetch additional information: categories & translations:
sparta = WhatIs.this('Sparta', categories: true, languages: 'el')
# => #<ThisIs Sparta/Αρχαία Σπάρτη, 7 categories [img] {37.081944,22.423611}>
sparta.describe
# => Sparta
#            title: "Sparta"
#      description: "city-state in ancient Greece"
#      coordinates: #<Geo::Coord 37.081944,22.423611>
#       categories: ["Former countries in Europe", "Former populated places in Greece", "Locations in Greek mythology", "Populated places in Laconia", "Sparta", "States and territories disestablished in the 2nd century BC", "States and territories established in the 11th century BC"]
#        languages: {"el"=>#<ThisIs::Link el:Αρχαία Σπάρτη>}
#          extract: "Sparta (Doric Greek: ; Attic Greek: ) was a prominent city-state in ancient Greece."
#            image: "https://upload.wikimedia.org/wikipedia/commons/6/6c/Sparta_territory.jpg"

sparta.languages['el'].resolve
# => #<ThisIs Αρχαία Σπάρτη [img]>

# Multiple entities at once:
WhatIs.these('Paris', 'Berlin', 'Rome', 'Athens')
# => {
#   "Paris"=>#<ThisIs Paris [img] {48.856700,2.350800}>,
#   "Berlin"=>#<ThisIs Berlin [img] {52.516667,13.388889}>,
#   "Rome"=>#<ThisIs Rome [img] {41.900000,12.500000}>,
#   "Athens"=>#<ThisIs Athens [img] {37.983972,23.727806}>
# }
```
## Applications

The gem is intended to be a simpel tool for entities resolution/normalization. Possible usages:

* You have a lot of user-entered answers to "What city are you from". Through `WhatIs.these` it is
  pretty easy to resolve them to "canonical" city name (e.g. "Warsaw", "Warszawa", "Warsaw, Poland" =>
  "Warsaw") and map locations;
* Quick check on user-entered cultural objects, "what is it";
* Canonical Wikipedia-powered translations of toponyms, movie titles and historical people;
* ...and so-on.

## Features/problems

* Fetches Wikipedia data by entity names: canonical title, geographical coordinates, main page image,
  first phrase, short entity description from Wikidata;
* Optionally fetches links to other Wikipedia languages, and list of page categories;
* Fetches any number of Wikipedia pages in minimal number of API requests (50-page batches);
  * Note that despite this optimization, Wikipedia API responses are not very small, so resolving,
    say, 1000 entities, will errrm _take some time_;
* Works with any language version of Wikipedia:
```ruby
WhatIs[:de].this('München')
# => #<ThisIs München [img] {48.137222,11.575556}>
```
* Handles not found pages and allows to search them in place:
```ruby
g = WhatIs.this('Guardians Of The Galaxy') # Wikipedia pages is case-sensitive
# => #<ThisIs::NotFound Guardians Of The Galaxy>
g.search(3)
# => [#<ThisIs::Ambigous Guardians of the Galaxy (11 options)>, #<ThisIs Guardians of the Galaxy (film)>, #<ThisIs Guardians of the Galaxy Vol. 2>]
```
* Handles disambiguation pages:
```ruby
g = WhatIs.this('Guardians of the Galaxy')
g.describe
g.variants[1].resolve
# => #<ThisIs::Ambigous Guardians of the Galaxy (11 options)>
g.describe
# => Guardians of the Galaxy: ambigous (11 options)
#      #<ThisIs::Link Marvel Comics teams/Guardians of the Galaxy (1969 team)>: Guardians of the Galaxy (1969 team), the original 31st-century team from an alternative timeline of the Marvel Universe (Earth-691)
#      #<ThisIs::Link Marvel Comics teams/Guardians of the Galaxy (2008 team)>: Guardians of the Galaxy (2008 team), the modern version of the team formed in the aftermath of Annihilation: Conquest
#    <...skip...>
#      Usage: .variants[0].resolve, .resolve_all
g.variants[1].resolve(categories: true)
# => #<ThisIs Guardians of the Galaxy (2008 team), 13 categories>
```
* Provides command-line tool:
```
$ whatis Paris Berlin Rome
Paris {48.856700,2.350800}: capital city of France
Berlin {52.516667,13.388889}: capital city of Germany
Rome {41.900000,12.500000}: capital city of Italy

$ whatis --help
Usage: `whatis [options] title1, title2, title3

Options:
    -l, --language CODE              Which language Wikipedia to ask, 2-letter code. "en" by default
    -t, --languages [CODE]           Without argument, fetches all translations for entity.
                                     With argument (two-letter code) fetches only one translation.
                                     By default, no translations are fetched.
        --categories                 Whether to fetch entity categories
    -f, --format FORMAT              Output format: one line per entity ("short"), several lines per
                                     entity ("long"), or "json". Default is "short".
    -h, --help                       Show this message
```

## How it works

`WhatIs.this` is a small brother of large [reality](https://github.com/molybdenum-99/reality). Under
the hood, it uses [infoboxer](https://github.com/molybdenum-99/infoboxer) semantic Wikipedia client.

Unlike `reality` (which tries to be _comprehensive_), `WhatIs.this` tries to be as simple yet useful,
as possible.

## Author

[Victor Shepelev](http://zverok.github.io)

## License

MIT
