RSpec.describe WhatIs::ThisIs, :vcr do
  describe '#inspect' do
    subject { ->(*args) { WhatIs.this(*args).values.first.inspect } }

    its_call('Paris') { is_expected.to ret '#<ThisIs Paris (48.856700,2.350800)>' }
    its_call('Bear') { is_expected.to ret '#<ThisIs Bear>' }
    its_call('Paris', languages: :ru) { is_expected.to ret '#<ThisIs Paris/ru:Париж (48.856700,2.350800)>' }
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
