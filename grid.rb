#! /usr/bin/env ruby
#
#  Utility for finding grids
#
#
#  Usage:
#    Gridr.explore(Range.new(900,1440,1))
#
#  Output:
#    1200 / 1.0	-- gutter 12.0px	–– column 89.0px
#     960 / 1.25	-- gutter 12.0px	–– column 69.0px
#    1280 / 1.25	-- gutter 16.0px	–– column 92.0px
#    1250 / 1.76	-- gutter 22.0px	–– column 84.0px
#    1000 / 2.0	-- gutter 20.0px	–– column 65.0px
#    1200 / 2.0	-- gutter 24.0px	–– column 78.0px
#    1400 / 2.0	-- gutter 28.0px	–– column 91.0px
#    1125 / 2.4	-- gutter 27.0px	–– column 69.0px
#    960 / 2.5	-- gutter 24.0px	–– column 58.0px
#    1200 / 3.0	-- gutter 36.0px	–– column 67.0px
#    1000 / 3.2	-- gutter 32.0px	–– column 54.0px
#    1250 / 3.68	-- gutter 46.0px	–– column 62.0px
#    960 / 3.75	-- gutter 36.0px	–– column 47.0px
#    900 / 4.0	-- gutter 36.0px	–– column 42.0px
#    1050 / 4.0	-- gutter 42.0px	–– column 49.0px
#    1200 / 4.0	-- gutter 48.0px	–– column 56.0px
#    1350 / 4.0	-- gutter 54.0px	–– column 63.0px
#    1000 / 4.4	-- gutter 44.0px	–– column 43.0px
#    1250 / 4.64	-- gutter 58.0px	–– column 51.0px
#    960 / 5.0	-- gutter 48.0px	–– column 36.0px
#    1040 / 5.0	-- gutter 52.0px	–– column 39.0px
#    1120 / 5.0	-- gutter 56.0px	–– column 42.0px
#    1200 / 5.0	-- gutter 60.0px	–– column 45.0px
#    1280 / 5.0	-- gutter 64.0px	–– column 48.0px
#    1360 / 5.0	-- gutter 68.0px	–– column 51.0px

class Gridr
  def self.grid_compute(base, gutter)
    gutter_w = base * gutter / 100.0
    column_w = (base - gutter_w * 11.0) / 12.0
    return [column_w, gutter_w]
  end

  def self.grid_test(range, gutter, verbose = false)
    range.each do |w|
      column_width, gutter_width = grid_compute(w, gutter)
      if verbose and (gutter_width % 0.25) == 0 and (column_width % 0.25) == 0
        puts " #{w} / #{gutter}\t-- gutter #{ gutter_width }px\t–– column #{ column_width }px"
      end

      if !verbose and (gutter_width % 1) == 0 and (column_width % 1) == 0
        puts " #{w} / #{gutter}\t-- gutter #{ gutter_width }px\t–– column #{ column_width }px"
      end
    end
  end

  def self.explore(widths_range, verbose = false, gutter_min= 100, gutter_max = 500, gutter_divider = 100)
    gutter_range = Range.new(100, 500)
    gutter_range.each do |g|
      gutter = g/(1.0 * gutter_divider)
      grid_test(widths_range, gutter)
    end
  end
end
