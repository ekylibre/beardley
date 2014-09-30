# encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)
require "beardley/version"

Gem::Specification.new do |spec|
  spec.name        = "beardley"
  spec.version     = Beardley::VERSION::STRING
  spec.authors     = ["Brice Texier"]
  spec.summary     = %q{JasperReports integration}
  spec.description = %q{Generate reports using JasperReports reporting tool}
  spec.email       = "burisu@oneiros.fr"
  spec.homepage    = "https://github.com/ekylibre/beardley"

  spec.files         = `git ls-files LICENSE README.rdoc lib vendor`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency('rjb', '>= 1.4.8')
  spec.add_dependency('rjb-loader', '>= 0.0.2')
  spec.add_development_dependency('minitest')
  spec.add_development_dependency('rake', '>= 10')
  spec.add_development_dependency('coveralls', '>= 0.6')
  spec.add_development_dependency('bundler', '> 1')
end
