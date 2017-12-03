RSpec.describe WhatIs, :vcr do
  before { VCR.use_cassette('en.wikipedia') { described_class[:en] } }

  describe '#these' do
    subject(:these) { described_class.these(*args) }

    let(:args) { %w[Paris Berlin Rome] }

    it { is_expected.to be_a Hash }
    its(:keys) { are_expected.to eq %w[Paris Berlin Rome] }
    its(:values) { are_expected.to all be_a WhatIs::ThisIs }

    context 'when no params passed' do
      let(:args) { [] }

      its_block {
        is_expected.to raise_error(ArgumentError, "Usage: `these('Title 1', 'Title 2', ..., **options). At least one title is required.")
      }
    end
  end

  describe '#this' do
    subject { described_class.this(*args) }

    let(:args) { 'Paris, France' }

    it { is_expected.to be_a WhatIs::ThisIs }
    its(:title) { is_expected.to eq 'Paris' }
    its(:page) { is_expected.to be_a Infoboxer::MediaWiki::Page }
    its(:coordinates) { is_expected.to eq Geo::Coord.new(48.856700, 2.350800) }
    its(:extract) { is_expected.to start_with('Paris (French pronunciation') }
    its(:description) { is_expected.to eq 'capital city of France' }
    its(:image) { is_expected.to start_with 'https://upload.wikimedia.org' }

    context 'with categories' do
      let(:args) { ['Paris, France', categories: true] }

      its(:categories) { are_expected.to include('Cities in France') }
    end

    context 'with languages' do
      subject { ->(lang) { WhatIs.these('Paris, France', languages: lang).values.first.languages } }

      its_call(true) { is_expected.to ret include('ru' => WhatIs::ThisIs::Link.new('Париж', language: :ru)) }
      its_call(:uk) { is_expected.to ret('uk' => WhatIs::ThisIs::Link.new('Париж', language: :uk)) }
    end

    context 'when not found' do
      let(:args) { ['definitely not found'] }

      it { is_expected.to be_a WhatIs::ThisIs::NotFound }
      its(:title) { is_expected.to eq 'definitely not found' }
    end

    context 'when ambigous' do
      let(:args) { 'Bela Crkva' }

      it { is_expected.to be_a WhatIs::ThisIs::Ambigous }
      its(:title) { is_expected.to eq 'Bela Crkva' }
    end

    context 'with other language' do
      subject { described_class[:ru].this('Париж') }

      it { is_expected.to be_a WhatIs::ThisIs }
      its(:title) { is_expected.to eq 'Париж' }
      its(:page) { is_expected.to be_a Infoboxer::MediaWiki::Page }
      its(:coordinates) { is_expected.to be_a Geo::Coord }
    end

    context 'when language has empty "ambigous categories" list' do
      subject { described_class[:fr].this('Paris') }

      its(:categories) { are_expected.to be_empty }

      context 'with categories' do
        subject { described_class[:fr].this('Paris', categories: true) }

        its(:categories) { are_expected.to include('Aire urbaine de Paris') }
      end
    end
  end
end
