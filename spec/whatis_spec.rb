RSpec.describe WhatIs, :vcr do
  before { VCR.use_cassette('en.wikipedia') { described_class[:en] } }

  describe '#this', vcr: true do
    context 'simplest' do
      subject { described_class.this('Paris, France').values.first }

      it { is_expected.to be_a WhatIs::ThisIs }
      its(:title) { is_expected.to eq 'Paris' }
      its(:page) { is_expected.to be_a Infoboxer::MediaWiki::Page }
      its(:coordinates) { is_expected.to eq Geo::Coord.new(48.856700, 2.350800) }
    end

    context 'with categories' do
      subject { WhatIs.this('Paris, France', categories: true).values.first }

      its(:categories) { are_expected.to include('Cities in France') }
    end

    context 'with languages' do
      subject { ->(lang) { WhatIs.this('Paris, France', languages: lang).values.first.languages } }

      its_call(true) { is_expected.to ret include('ru' => WhatIs::ThisIs::Link.new('Париж', language: :ru)) }
      its_call(:uk) { is_expected.to ret('uk' => WhatIs::ThisIs::Link.new('Париж', language: :uk)) }
    end

    context 'multiple pages' do
    end

    context 'when not found' do
      subject { WhatIs.this('definitely not found').values.first }

      it { is_expected.to be_a WhatIs::ThisIs::NotFound }
      its(:title) { is_expected.to eq 'definitely not found' }
    end

    context 'when ambigous' do
      subject { WhatIs.this('Bela Crkva').values.first }

      it { is_expected.to be_a WhatIs::ThisIs::Ambigous }
      its(:title) { is_expected.to eq 'Bela Crkva' }
    end

    context 'when no params passed' do
    end

    context 'with other language' do
      subject { described_class[:ru].this('Париж').values.first }

      it { is_expected.to be_a WhatIs::ThisIs }
      its(:title) { is_expected.to eq 'Париж' }
      its(:page) { is_expected.to be_a Infoboxer::MediaWiki::Page }
      its(:coordinates) { is_expected.to be_a Geo::Coord }
    end
  end
end
