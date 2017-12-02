RSpec.describe WhatIs::ThisIs::Ambigous, :vcr do
  subject(:ambigous) { WhatIs.this(title).values.first }

  before { VCR.use_cassette('en.wikipedia') { WhatIs[:en] } } # caching metainfo request to VCR

  let(:title) { 'Bela Crkva' }

  describe '#variants' do
    subject { ambigous.variants }

    its(:count) { is_expected.to eq 6 }
    it { is_expected.to all be_a WhatIs::ThisIs::Link }
    its_map(:title) { is_expected.to eq ['Bela Crkva, Banat', 'Bela Crkva, Krivogaštani', 'Bela Crkva (Krupanj)', 'Toplička Bela Crkva', 'Bila Tserkva', 'Byala Cherkva'] }

    context 'when not all variants have links' do
      let(:title) { 'Split' }

      its(:count) { is_expected.to eq 46 }
      its(:'last.title') { is_expected.to eq 'Splitter (disambiguation)' }
      its(:'last.inspect') { is_expected.to eq '#<ThisIs::Link See also/Splitter (disambiguation)>' }
    end
  end

  describe '#inspect' do
    subject { ->(*args) { WhatIs.this(*args).values.first.inspect } }

    its_call('Bela Crkva') { is_expected.to ret '#<ThisIs::Ambigous Bela Crkva (6 options)>' }
  end

  describe '#describe' do
    subject { ->(*args) { WhatIs.this(*args).values.first.describe } }

    its_call('Bela Crkva') {
      is_expected.to ret start_with('#<ThisIs::Ambigous Bela Crkva (6 options)>')
        .and include('#<ThisIs::Link Bela Crkva, Banat>: Bela Crkva, Banat, a town in Vojvodina, Serbia')
        .and end_with('Usage: .variants[0].resolve, .resolve_all')
    }
  end

  describe '#resolve_all' do
    subject { ambigous.resolve_all }

    it { is_expected.to be_a(Hash).and have_attributes(count: 6) }
    its(:values) { are_expected.to all be_a WhatIs::ThisIs }
  end
end
