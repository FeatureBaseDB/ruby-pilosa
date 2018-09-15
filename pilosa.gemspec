Gem::Specification.new do |s|
  s.name               = "pilosa"
  s.version            = "0.0.1"
  s.default_executable = "pilosa"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.date = %q{2018-09-10}
  s.description = %q{A Ruby client for the Pilosa bitmap database}
  s.files =  Dir['README.md', 'VERSION', 'Gemfile', 'Rakefile', '{bin,lib,config,vendor}/**/*']
  s.homepage = %q{http://rubygems.org/gems/pilosa}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{2.4.5}
  s.summary = %q{A Ruby client for the Pilosa bitmap database}

  s.add_runtime_dependency "google-protobuf", "~> 3.6.1"

  if s.respond_to? :specification_version then
    s.specification_version = 1

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
