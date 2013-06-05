require 'backports' if RUBY_VERSION < '1.9'
require 'prime'

class Prime::MillerRabin < Prime::PseudoPrimeGenerator
  VERSION = "0.0.2"
end
