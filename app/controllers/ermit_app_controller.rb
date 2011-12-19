class ErmitAppController < ApplicationController
  def index
    if params[:power] and params[:power].to_i >= 0 and params[:power].to_i < 300
      all = params[:all] ? params[:all] : nil
      table = GoogleVisualr::DataTable.new
      n = params[:power].to_i
      @s = build! n, table, all
      option = { width: 780, height: 480, backgroundColor: '#93968F', chartArea: {left:70,top:20,width:"90%",height:"87%"} }
      @chart = GoogleVisualr::Interactive::LineChart.new(table, option)
    elsif params[:power]
      redirect_to :back, :notice => true
    end
  end

  def theory
  end

  def line_chart!(table, e)
    x0 = -2
    len = 4.0
    n = 100
    table.new_column('string', 'X')
    e.size.times do |i|
      table.new_column('number', 'Y' + i.to_s)
    end
    table.add_rows(n+1)
    interval = len/n
    (0..n).each do |i|
      x = x0 + i*interval
      table.set_cell(i, 0, x.to_s)
      e.each_with_index { |el, j| table.set_cell(i, j+1, el.call(x)) }
    end
  end
  
  def build!(n, table, all)
    h = init(n)
    e = []
    s = []
    if all
      (0..n).each do |i|
        ermit = n == 0 ? h[0] : h[i]
        s << printit(ermit)
        e[i] = ->arg do
          ans = 0
          ermit.each_with_index do |obj, i| 
            ans += obj*(arg**i)
          end
          ans
        end
      end
    else
      ermit = n == 0 ? h[0] : h[-1]
      s << printit(ermit)
      e[0] = ->arg do
        ans = 0
        ermit.each_with_index do |obj, i| 
          ans += obj*(arg**i)
        end
        ans
      end
    end
    line_chart! table, e
    s
  end

  def printit(a)
    s = ""
    (a.length - 1).downto(2) do |n| 
      s += "+ " if a[n] > 0 and n != a.length - 1
      s += a[n].to_s + "x^" + n.to_s + " " if a[n] != 0 and a[n] != 1
      s += "x^" + n.to_s + " " if a[n] != 0 and a[n] == 1
    end
    s += "+ " if a[1] > 0 
    s += a[1].to_s + "x" + " " if a[1] != 0 
    s += "+ " if a[0] > 0
    s += a[0].to_s if a[0] != 0
    p s
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
