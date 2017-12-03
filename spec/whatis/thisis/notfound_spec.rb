RSpec.describe WhatIs::ThisIs::NotFound, :vcr do
  before { VCR.use_cassette('en.wikipedia') { WhatIs[:en] } } # caching metainfo request to VCR

  subject(:notfound) { described_class.new(WhatIs[:en], 'Guardians Of The Galaxy') }

  describe '#inspect' do
    its(:inspect) { is_expected.to eq '#<ThisIs::NotFound Guardians Of The Galaxy>' }
  end

  describe '#describe' do
    its(:describe) { is_expected.to eq "Guardians Of The Galaxy: not found\n  Usage: .search(limit, **options)" }

    context 'without help' do
      subject { notfound.describe(help: false) }
      it { is_expected.to eq 'Guardians Of The Galaxy: not found' }
    end
  end

  describe '#to_s' do
    its(:to_s) { is_expected.to eq 'Guardians Of The Galaxy: not found' }
  end

  describe '#search' do
    subject { notfound.search(3) }

    its_block { is_expected.to send_message(WhatIs[:en], :search).with('Guardians Of The Galaxy', 3, {}) }
    it { is_expected.to all be_a(WhatIs::ThisIs).or(be_a(WhatIs::ThisIs::Ambigous)) }
    its_map(:title) { is_expected.to eq ['Guardians of the Galaxy', 'Guardians of the Galaxy (film)', 'Guardians of the Galaxy Vol. 2'] }

    context 'with arguments' do
      subject { notfound.search(3, languages: :ru) }

      its(:'last.languages') { are_expected.to include('ru') }
    end
  end
end
