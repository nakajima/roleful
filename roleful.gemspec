# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{roleful}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Pat Nakajima"]
  s.date = %q{2008-10-27}
  s.email = %q{patnakajima@gmail.com}
  s.files = ["lib/core_ext", "lib/core_ext/module.rb", "lib/roleful", "lib/roleful/inclusion.rb", "lib/roleful/role.rb", "lib/roleful.rb"]
  s.homepage = %q{http://github.com/nakajima/roleful}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{Generic roles for you and your objects}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<metaid>, [">= 0"])
    else
      s.add_dependency(%q<metaid>, [">= 0"])
    end
  else
    s.add_dependency(%q<metaid>, [">= 0"])
  end
end
