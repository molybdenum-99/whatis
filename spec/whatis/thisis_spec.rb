RSpec.describe WhatIs::ThisIs, :vcr do
  before { VCR.use_cassette('en.wikipedia') { WhatIs[:en] } } # caching metainfo request to VCR

  describe '#inspect' do
    subject { ->(*args) { WhatIs.this(*args).inspect } }

    its_call('Paris') { is_expected.to ret '#<ThisIs Paris [img] {48.856700,2.350800}>' }
    its_call('Bear') { is_expected.to ret '#<ThisIs Bear [img]>' }
    its_call('Paris', languages: :ru) { is_expected.to ret '#<ThisIs Paris/Париж [img] {48.856700,2.350800}>' }
    its_call('Paris', languages: true) { is_expected.to ret match(/Paris \+\d+ translations/) }
    its_call('Paris', categories: true) { is_expected.to ret match(/, \d+ categories/) }
  end

  describe '#describe' do
    subject { ->(*args) { WhatIs.this(*args).describe } }

    its_call('Paris') {
      is_expected.to ret start_with('Paris')
        .and include('coordinates: #<Geo::Coord 48.856700,2.350800>')
    }
  end

  describe '#to_s' do
    subject { ->(*args) { WhatIs.this(*args).to_s } }

    its_call('Paris, France') { is_expected.to ret 'Paris' }
  end

  describe '#to_h' do
    subject { WhatIs.this('Paris', categories: 'true', languages: 'uk') }

    its(:to_h) {
      is_expected.to match hash_including(
        type: 'ThisIs',
        title: 'Paris',
        languages: {'uk' => 'Париж'},
        categories: include('Cities in France'),
        coordinates: '48.856700,2.350800'
      )
    }
  end

  describe '#what' do
    subject { this.what(languages: :be) }

    let(:this) { WhatIs.this('Paris') }

    it { is_expected.not_to be_equal this }
    its(:languages) { is_expected.to eq('be' => WhatIs::ThisIs::Link.new('Парыж', language: :be)) }
  end
end
