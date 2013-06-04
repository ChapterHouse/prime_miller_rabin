# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'prime_miller_rabin/version'

Gem::Specification.new do |spec|
  spec.name          = "prime_miller_rabin"
  spec.version       = Prime::MillerRabin::VERSION
  spec.authors       = ["Frank Hall"]
  spec.email         = ["ChapterHouse.Dune@gmail.com"]
  spec.description   = %q{Test primes faster than Ruby's default methods by using the Miller-Rabin method.}
  spec.summary       = %q{Test primes faster than Ruby's default methods by using the Miller-Rabin method.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  #spec.add_runtime_dependency "prime"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
