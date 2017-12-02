RSpec.describe WhatIs::ThisIs::NotFound, :vcr do
  before { VCR.use_cassette('en.wikipedia') { WhatIs[:en] } } # caching metainfo request to VCR

  subject(:notfound) { described_class.new(WhatIs[:en], 'Guardians Of The Galaxy') }

  describe '#inspect' do
    its(:inspect) { is_expected.to eq '#<ThisIs::NotFound Guardians Of The Galaxy>' }
  end

  describe '#describe' do
    its(:describe) { is_expected.to eq "#<ThisIs::NotFound Guardians Of The Galaxy>\n  Usage: .search(limit)" }
  end

  describe '#search' do
    subject { notfound.search(3) }

    its_block { is_expected.to send_message(WhatIs[:en], :search).with('Guardians Of The Galaxy', 3) }
    it { is_expected.to all be_a(WhatIs::ThisIs) }
    its_map(:title) { is_expected.to eq ['Guardians of the Galaxy', 'Guardians of the Galaxy (film)', 'Guardians of the Galaxy Vol. 2'] }
  end
end
