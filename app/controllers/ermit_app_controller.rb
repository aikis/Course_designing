class ErmitAppController < ApplicationController
  def index
    if params[:power]
      table = GoogleVisualr::DataTable.new
      build! params[:power].to_i, table
      option = { width: 750, height: 480, backgroundColor: '#93968F', chartArea: {left:50,top:20,width:"95%",height:"90%"} }
      @chart = GoogleVisualr::Interactive::LineChart.new(table, option)
    end
  end

  def line_chart!(table, ermit, e)
    x0 = -5
    len = 10.0
    n = 100
    table.new_column('string', 'X')
    table.new_column('number', 'Y')
    table.add_rows(n+1)
    interval = len/n
    (0..n).each do |i|
      x = x0 + i*interval
      table.set_cell(i, 0, x.to_s)
      table.set_cell(i, 1, e.call(x))
    end
  end
  
  def build!(n, table)
    h = init(n)
    ermit = h[-1]
    e = ->arg do
      ans = 0
      ermit.each_with_index do |obj, i| 
        ans += obj*(arg**i)
      end
      ans
    end
    line_chart! table, ermit, e
  end

  def printit(a)
    (a.length - 1).downto(1) { |n| print "(#{a[n]})x^#{n} + " if a[n] != 0 }
    print "(#{a[0]})" if a[0] != 0
    puts
  end

  def inits(n)
    e0 = Array.new n + 1, 0
    e0[0] = 1
    e1 = Array.new n + 1, 0
    e1[1] = 1
    return e0, e1
  end

  def init(n)
    m = 2
    h = Array.new n+1
    h[0], h[1] = inits n
    m.upto(n) do |i|
      h[i] = Array.new n+1, 0
      (0..n).each do |j|
        if j != 0
          h[i][j] = h[i-1][j-1] - (i-1)*h[i-2][j]
        else
          h[i][j] = -(i-1)*h[i-2][j]
        end
      end
      # printit h[i]
    end
    h
  end
end
