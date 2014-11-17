require 'rubygems/package_task'
require 'rubygems/specification'
require 'rspec/core/rake_task'

require 'apns/version'

GEM = 'apns'
GEM_NAME = 'apns'
GEM_VERSION = APNS::VERSION
AUTHORS = ["James Pozdena", "Thomas Kollbach"]
EMAIL = ["jpoz@jpoz.net", "thomas@kollba.ch"]
HOMEPAGE = "http://github.com/graydot/apns"
DESCRIPTION = <<DESC
Simple Apple push notification service gem.
It supports the 3rd wire format (command 2) with support for content-availible (Newsstand), expiration dates and delivery priority (background pushes)
(Modified to support proxy configuration)
DESC

SUMMARY = "Simple Apple push notification service gem"
 
spec = Gem::Specification.new do |s|
  s.name = GEM
  s.version = GEM_VERSION
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["MIT-LICENSE"]
  s.summary = SUMMARY
  s.description = DESCRIPTION
  s.authors = AUTHORS
  s.email = EMAIL
  s.homepage = HOMEPAGE
  s.require_paths = ["lib"]
  s.files = %w(MIT-LICENSE README.textile Rakefile) + Dir.glob("{lib}/**/*")
  s.rubygems_version = "1.3.5"

  s.add_dependency 'json', '~> 1.8.1'

  s.add_development_dependency 'rspec', '>= 2.14.0', '< 3.0'
  s.add_development_dependency 'rake', '~> 10.3.2'
end
 
task :default => :spec
 
desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = FileList['spec/**/*_spec.rb']
  t.rspec_opts = %w(--format documentation --color)
end
 
Gem::PackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end
 
desc "install the gem locally"
task :install => [:package] do
  sh %{sudo gem install pkg/#{GEM}-#{GEM_VERSION}}
end
 
desc "create a gemspec file"
task :make_spec do
  File.open("#{GEM}.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end