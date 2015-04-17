# Calculates (pixel) scales
#
# Usage
#
#   require "size_scale"
#
#   SizeScale.gen(20, 27)
#   => Generates all numbers in-scale with 1.5 multiplication
#   between 3 and 1440 (useful css px values)
#
#   scale = SizeScale.new(20, 27)
#   scale.ratio=1.618
#   scale.calculate!
#   => Generates all numbers in-scale with 20 and 27 with 1.618 multiplication
#   between 3 and 1440 (useful css px values)
#

class SizeScale
  @@min = 3
  @@max = 1440
  @@default_ratio = 1.5

  attr_accessor :ratio
  attr_accessor :list

  def self.gen(s , stwo)
    scale = new(s , stwo)
  end

  def self.genr(s , stwo, r)
    scale = new(s , stwo)
    scale.ratio = r
    scale.calculate!
  end

  def initialize(seed, seedtwo)
    @seed = seed
    @seedtwo = seedtwo
    @ratio = @@default_ratio
    calculate!
  end

  def calculate!
    @list = []
    @list << [@seed, @seedtwo]
    @list << gen_up(@seed)
    @list << gen_down(@seed)
    @list << gen_up(@seedtwo)
    @list << gen_down(@seedtwo)
    @list = @list.flatten.compact.sort.uniq.select do |val|
      val > @@min && val < @@max
    end
  end

  def to_s
    "Modular Scale:\n" + @list.join("\n")
  end

  private
    def gen_up(seed)
      scaled = seed
      (1..20).map do |s|
        scaled *= @ratio
      end
    end

    def gen_down(seed)
      scaled = seed
      (1..20).map do |s|
        scaled = scaled / @ratio
      end
    end
end
