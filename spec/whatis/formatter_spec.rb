RSpec.describe WhatIs::Formatter, :vcr do
  subject { ->(*arg) { formatter.call('Title', WhatIs.this(*arg)) } }

  let(:formatter) { described_class.new }

  its_call('Paris') { is_expected.to ret 'Title: Paris {48.856700,2.350800} - capital city of France' }
  its_call('Paris', languages: 'ru') { is_expected.to ret 'Title: Paris {48.856700,2.350800} - Париж' }
  its_call('Paris', categories: true) { is_expected.to ret start_with 'Title: Paris {48.856700,2.350800} - 3rd-century BC establishments; ' }

  its_call('John F. Kennedy') { is_expected.to ret 'Title: John F. Kennedy - 35th president of the United States of America' }

  its_call('Bela Crkva') { is_expected.to ret 'Title: Bela Crkva, 6 options - Bela Crkva, Banat; Bela Crkva, Krivogaštani; Bela Crkva (Krupanj); Toplička Bela Crkva; Bila Tserkva; Byala Cherkva' }
  its_call('Guardians Of The Galaxy') { is_expected.to ret 'Title: not found' }
end
