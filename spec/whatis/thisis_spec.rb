RSpec.describe WhatIs::ThisIs, :vcr do
  before { VCR.use_cassette('en.wikipedia') { WhatIs[:en] } } # caching metainfo request to VCR

  describe '#inspect' do
    subject { ->(*args) { WhatIs.this(*args).values.first.inspect } }

    its_call('Paris') { is_expected.to ret '#<ThisIs Paris [img] {48.856700,2.350800}>' }
    its_call('Bear') { is_expected.to ret '#<ThisIs Bear [img]>' }
    its_call('Paris', languages: :ru) { is_expected.to ret '#<ThisIs Paris/Париж [img] {48.856700,2.350800}>' }
    its_call('Paris', languages: true) { is_expected.to ret match /Paris \+\d+ translations/ }
    its_call('Paris', categories: true) { is_expected.to ret match /, \d+ categories/ }
  end

  describe '#describe' do
    subject { ->(*args) { WhatIs.this(*args).values.first.describe } }

    its_call('Paris') { is_expected.to ret eq_multiline(%{
      |ThisIs Paris
      |        title: "Paris"
      |  coordinates: #<Geo::Coord 48.856700,2.350800>
    }) }
  end
end
