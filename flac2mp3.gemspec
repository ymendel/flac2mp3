Gem::Specification.new do |gem|
  gem.add_development_dependency 'bacon', '>= 1.1.0'
  gem.add_development_dependency 'facon', '>= 0.5.0'
  gem.add_runtime_dependency 'flacinfo-rb',  '>= 0.4'
  gem.add_runtime_dependency 'ruby-mp3info', '>= 0.5.1'
  gem.authors = ['Yossef Mendelssohn']
  gem.description = %q{A simple converter for FLAC to MP3.}
  gem.email = ['ymendel@pobox.com']
  gem.executables = ['flac2mp3', 'metaflac2mp3']
  gem.files = Dir['License.txt', 'History.txt', 'README.md', 'lib/**/*', 'spec/**/*', 'bin/**/*']
  gem.homepage = 'http://github.com/ymendel/one_inch_punch/'
  gem.name = 'flac2mp3'
  gem.require_paths = ['lib']
  gem.summary = %q{convert FLAC to MP3}
  gem.version = '0.4.2'
end
