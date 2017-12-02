RSpec.describe WhatIs::ThisIs::Ambigous, :vcr do
  subject(:ambigous) { WhatIs.this(title).values.first }

  before { VCR.use_cassette('en.wikipedia') { WhatIs[:en] } } # caching metainfo request to VCR

  let(:title) { 'Bela Crkva' }

  describe '#variants' do
    subject { ambigous.variants }

    its(:count) { is_expected.to eq 6 }
    it { is_expected.to all be_a WhatIs::ThisIs::Link }
    its_map(:title) { is_expected.to eq ['Bela Crkva, Banat', 'Bela Crkva, Krivogaštani', 'Bela Crkva (Krupanj)', 'Toplička Bela Crkva', 'Bila Tserkva', 'Byala Cherkva'] }

    context 'not all variants have links' do
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
    subject { ->(*args) { WhatIs.this(*args).values.first.describe.tap(&method(:puts)) } }

    its_call('Bela Crkva') {
      is_expected.to ret eq_multiline(%{
        |#<ThisIs::Ambigous Bela Crkva (6 options)>
        |  #<ThisIs::Link Bela Crkva, Banat>: Bela Crkva, Banat, a town in Vojvodina, Serbia
        |  #<ThisIs::Link Bela Crkva, Krivogaštani>: Bela Crkva, Krivogaštani, a village in the Municipality of Krivogaštani, Macedonia
        |  #<ThisIs::Link Bela Crkva (Krupanj)>: Bela Crkva, Krivogaštani, a village in the Mačva District of Serbia
        |  #<ThisIs::Link Toplička Bela Crkva>: Toplička Bela Crkva, original name of the city of Kuršumlija, Serbia
        |  #<ThisIs::Link See also/Bila Tserkva>: Bila Tserkva (Біла Церква), a city in the Kiev Oblast of Ukraine
        |  #<ThisIs::Link See also/Byala Cherkva>: Byala Cherkva, a town in the Veliko Turnovo oblast of Bulgaria
      })
    }
  end

  describe '#resolve_all' do
    subject { ambigous.resolve_all }

    it { is_expected.to be_a(Hash).and have_attributes(count: 6) }
    its(:values) { are_expected.to all be_a WhatIs::ThisIs }
  end
end
