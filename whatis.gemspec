Gem::Specification.new do |s|
  s.name     = 'whatis'
  s.version  = '0.0.1'
  s.authors  = ['Victor Shepelev']
  s.email    = 'zverok.offline@gmail.com'
  s.homepage = 'https://github.com/molybdenum-99/wtfer'

  s.summary = 'WhatIs.this: Small entity resolver through Wikipedia'
  s.description = <<-EOF
  EOF
  s.licenses = ['MIT']

  s.required_ruby_version = '>= 2.1.0'

  s.files = `git ls-files`.split($RS).reject do |file|
    file =~ /^(?:
    spec\/.*
    |Gemfile
    |Rakefile
    |\.codeclimate.yml
    |\.rspec
    |\.gitignore
    |\.rubocop.yml
    |\.rubocop_todo.yml
    |\.travis.yml
    |\.yardopts
    )$/x
  end
  s.require_paths = ["lib"]
  s.bindir = 'exe'
  s.executables << 'whatis'

  s.required_ruby_version = '>= 2.3.0'

  s.add_dependency 'infoboxer', '= 0.3.1'
  s.add_dependency 'geo_coord'
  s.add_dependency 'backports'

  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rspec', '>= 3'
  s.add_development_dependency 'rubocop-rspec'
  s.add_development_dependency 'rspec-its', '~> 1'
  s.add_development_dependency 'saharspec', '0.0.4'
  s.add_development_dependency 'simplecov', '~> 0.9'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rubygems-tasks'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'kramdown'
  s.add_development_dependency 'vcr'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'dokaz'
end
