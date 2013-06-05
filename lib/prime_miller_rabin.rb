require 'backports' if RUBY_VERSION < '1.9'
require 'prime'
require "prime_miller_rabin/version"

class Prime::MillerRabin < Prime::PseudoPrimeGenerator

  def self.speed_intercept
    if RUBY_VERSION >= "2.0"
      Prime.send(:prepend, Prime::MillerRabin::PrimeIntercept)
    else
      Prime.class_eval <<-INTERCEPT_EVAL, __FILE__, __LINE__ + 1
        def prime_with_intercept?(value, *args)
          args.first.instance_of?(Prime::MillerRabin) ? args.first.prime?(value) : prime_without_intercept?(value, *args)
        end

        alias_method "prime_without_intercept?", "prime?"
        alias_method "prime?", "prime_with_intercept?"
      INTERCEPT_EVAL
    end
  end

  def self.make_default
    if RUBY_VERSION >= "2.0"
      Prime.send(:prepend, Prime::MillerRabin::Default::Prime, Prime::MillerRabin::PrimeIntercept)
      Integer.send(:prepend, Prime::MillerRabin::Default::Integer)
    else
      Prime.class_eval <<-PRIME_DEFAULT_EVAL, __FILE__, __LINE__ + 1
        # Change the default generator used to be MillerRabin
        def prime_with_mr_default?(value, generator = ::Prime::MillerRabin.new)
          generator.instance_of?(Prime::MillerRabin) ? generator.prime?(value) : prime_without_mr_default?(value, generator)
        end

        def prime_division_with_mr_default?(value, generator = ::Prime::MillerRabin.new)
          prime_division_without_mr_default?(value, generator)
        end

        alias_method "prime_without_mr_default?", "prime?"
        alias_method "prime?", "prime_with_mr_default?"

        alias_method "prime_division_without_mr_default?", "prime_division"
        alias_method "prime_division", "prime_division_with_mr_default?"
      PRIME_DEFAULT_EVAL

      Integer.class_eval <<-INTEGER_DEFAULT_EVAL, __FILE__, __LINE__ + 1

        def prime_division_with_mr_default(generator = ::Prime::MillerRabin.new)
          prime_division_without_mr_default(generator)
        end

        alias_method "prime_division_with_mr_default?", "prime_division"
        alias_method "prime_division", "prime_division_with_mr_default?"
      INTEGER_DEFAULT_EVAL

    end
  end

  def succ()
    self.last_prime = next_prime(last_prime || 1)
  end

  def rewind()
    self.last_prime = nil
  end

  def prime?(x)
    miller_rabin(x)
  end

  private

  attr_accessor :last_prime

  def likely_prime?(a, n)
    d = n - 1
    s = 0
    while d % 2 == 0 do
      d >>= 1
      s += 1
    end

    b = 1
    while d > 0
      u = d % 2
      t = d / 2
      b = (b * a) % n if u == 1
      a = a**2 % n
      d = t
    end

    if b == 1
      true
    else
      s.times do |i|
        return true if b == n - 1
        b = (b * b) % n
      end
      (b == n - 1)
    end
  end

  def miller_rabin(n)
    if n.abs < 2
      false
    else
      likely_prime = true
      # 26 Yields a probability of prime at 99.99999999999998% so lets kick it up a notch.
      27.times do |i|
        begin
          a = rand(n)
        end while a == 0
        likely_prime = likely_prime?(a, n)
        break unless likely_prime
      end
      likely_prime
    end
  end

  def next_prime(x)
    if x < 2
      2
    elsif x < 3
      3
    elsif x < 5
      5
    else
      x += (x.even? ? 1 : (x % 10 == 3 ? 4 : 2 ))
      x += (x % 10 == 3 ? 4 : 2 ) until x.prime?
      x
    end
  end

end

module Prime::MillerRabin::PrimeIntercept

  # Intercept the prime? method. By going right to MillerRabin we can produce a faster result.
  def prime?(value, *args)
    args.first.instance_of?(Prime::MillerRabin) ? args.first.prime?(value) : super
  end

end

module Prime::MillerRabin::Default

  module Prime

    # Change the default generator used to be MillerRabin
    def prime?(value, generator = ::Prime::MillerRabin.new)
      super
    end

    def prime_division(value, generator = ::Prime::MillerRabin.new)
      super
    end

  end

  module Integer

    def prime_division(generator = ::Prime::MillerRabin.new)
      super
    end

  end

end
