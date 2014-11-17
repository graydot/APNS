# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{apns}
  s.version = "1.1.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["James Pozdena", "Thomas Kollbach"]
  s.date = %q{2014-11-20}
  s.description = %q{Simple Apple push notification service gem.
It supports the 3rd wire format (command 2) with support for content-availible (Newsstand), expiration dates and delivery priority (background pushes)
(Modified to support proxy configuration)
}
  s.email = ["jpoz@jpoz.net", "thomas@kollba.ch"]
  s.extra_rdoc_files = ["MIT-LICENSE"]
  s.files = ["MIT-LICENSE", "README.textile", "Rakefile", "lib/apns", "lib/apns/connection_methods.rb", "lib/apns/core.rb", "lib/apns/direct_connection.rb", "lib/apns/notification.rb", "lib/apns/proxy_connection.rb", "lib/apns/version.rb", "lib/apns.rb"]
  s.homepage = %q{http://github.com/graydot/apns}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Simple Apple push notification service gem}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<json>, ["~> 1.8.1"])
      s.add_development_dependency(%q<rspec>, ["< 3.0", ">= 2.14.0"])
      s.add_development_dependency(%q<rake>, ["~> 10.3.2"])
    else
      s.add_dependency(%q<json>, ["~> 1.8.1"])
      s.add_dependency(%q<rspec>, ["< 3.0", ">= 2.14.0"])
      s.add_dependency(%q<rake>, ["~> 10.3.2"])
    end
  else
    s.add_dependency(%q<json>, ["~> 1.8.1"])
    s.add_dependency(%q<rspec>, ["< 3.0", ">= 2.14.0"])
    s.add_dependency(%q<rake>, ["~> 10.3.2"])
  end
end
