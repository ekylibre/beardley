# encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)
require "beardley/version"

Gem::Specification.new do |s|
  s.name        = "beardley"
  s.version     = Beardley::VERSION::STRING
  s.authors     = ["Brice Texier"]
  s.summary     = %q{JasperReports integration}
  s.description = %q{Generate reports using JasperReports reporting tool}
  s.email       = "burisu@oneiros.fr"
  s.homepage    = "https://github.com/burisu/beardley"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('rjb', '1.4.6')
  s.add_dependency('beardley-groovy', '>= 1.7.5')
  s.add_development_dependency('rake', '>= 10')
  s.add_development_dependency('coveralls', '>= 0.6')
  s.add_development_dependency('bundler', '> 1')
end
