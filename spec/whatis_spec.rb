RSpec.describe WhatIs do
  subject!(:wikipedia) { VCR.use_cassette('en.wikipedia') { described_class.new(:en) } }

  describe '#this', vcr: true do
    context 'simplest' do
      subject { wikipedia.this('Paris, France').first }

      it { is_expected.to be_a WhatIs::ThisIs }
      its(:title) { is_expected.to eq 'Paris, France' }
      its(:page) { is_expected.to be_a Infoboxer::MediaWiki::Page }

      its(:canonical) { is_expected.to eq 'Paris' }
      its(:coordinates) { is_expected.to eq Geo::Coord.new(48.856700, 2.350800) }
    end

    context 'with categories' do
      subject { wikipedia.this('Paris, France', categories: true).first }

      its(:categories) { are_expected.to include('Cities in France') }
    end

    context 'with languages' do
      subject { wikipedia.this('Paris, France', languages: true).first }

      its(:languages) { are_expected.to include('ru' => 'Париж') }
    end

    context 'with only one language' do
      subject { wikipedia.this('Paris, France', languages: 'uk').first }

      its(:languages) { are_expected.to have_attributes(size: 1).and include('uk' => 'Париж') }
    end

    context 'multiple pages' do
    end

    context 'when not found' do
      subject { wikipedia.this('definitely not found').first }

      it { is_expected.to be_a WhatIs::ThisIs::NotFound }
      its(:title) { is_expected.to eq 'definitely not found' }
    end

    context 'when ambigous' do
      subject { wikipedia.this('Bela Crkva').first }

      it { is_expected.to be_a WhatIs::ThisIs::Ambigous }
      its(:title) { is_expected.to eq 'Bela Crkva' }
    end

    context 'when no params passed' do
    end
  end
end
