RSpec.describe WhatIs::ThisIs::Link, :vcr do
  before { VCR.use_cassette('ru.wikipedia') { WhatIs[:ru] } } # caching metainfo request to VCR

  describe '#resolve' do
    subject { link.resolve }

    context 'with owner' do
      let(:link) { described_class.new('Харьков', owner: WhatIs[:ru]) }

      it { is_expected.to be_a(WhatIs::ThisIs).and have_attributes(title: 'Харьков') }
    end

    context 'with language' do
      let(:link) { described_class.new('Харьков', language: :ru) }

      it { is_expected.to be_a(WhatIs::ThisIs).and have_attributes(title: 'Харьков') }
    end
  end

  describe '#inspect' do
    subject { ->(*args) { described_class.new(*args).inspect } }

    its_call('Kharkiv') { is_expected.to ret '#<ThisIs::Link Kharkiv>' }
    its_call('Kharkiv', section: 'See also') { is_expected.to ret '#<ThisIs::Link See also/Kharkiv>' }
    its_call('Kharkiv', language: :de) { is_expected.to ret '#<ThisIs::Link de:Kharkiv>' }
  end
end
