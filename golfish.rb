code = IO.binread(ARGV[0])

class Lang

  def initialize(code)

    @map = [[]]

    code.each_byte {|byte|
      if byte == 0x80
        @map.push []
      else
        @map[-1].push byte
      end
    }
    
    @ptr = 0
    
    @dir = 1
    
    @stack = []

    @reg = {}
    
  end


  def next!
    @ptr += @dir
    @ptr = @ptr.real + (@ptr.imag % @map.size) * 1i
    @ptr = (@ptr.real % @map[@ptr.imag].size) + @ptr.imag * 1i
  end

  def ins
    @map[@ptr.imag][@ptr.real]
  end

  def exec!

    loop {
      case ins

      when 0x00
        # do nothing

      when 0x01
        @stack.push $stdin.getc.ord
      when 0x02
        input = ""
        begin
          c = $stdin.getc
          input << c
        end while c && c =~ /\s/
        @stack.push input.to_i
      when 0x03
        @stack.push $stdin.each_byte.to_a
      when 0x04
        @stack.push $stdin.read.split.map(&:to_i)

      when 0x05
        a = @stack.pop
        if a.is_a?(Array)
          $stdout.print a.pack("C*")
        elsif a.is_a?(String)
          $stdout.print a
        elsif a.is_a?(Fixnum)
          $stdout.print a.chr
        end
      when 0x06
        $stdout.print @stack.pop
      when 0x07
        $stdout.print " "
      when 0x08
        $stdout.print "\n"

      when 0x10
        x, y = @stack.pop(2)
        @stack.push x + y
      when 0x11
        x, y = @stack.pop(2)
        @stack.push x - y
      when 0x12
        x, y = @stack.pop(2)
        @stack.push x * y
      when 0x13
        x, y = @stack.pop(2)
        @stack.push x / y
      when 0x14
        x, y = @stack.pop(2)
        @stack.push x % y
      when 0x15
        x, y = @stack.pop(2)
        @stack.push x ** y
      when 0x16
        x = @stack.pop
        @stack.push ~x
      when 0x17
        x, y = @stack.pop(2)
        @stack.push x & y
      when 0x18
        x, y = @stack.pop(2)
        @stack.push x | y
      when 0x19
        x, y = @stack.pop(2)
        @stack.push x ^ y
      when 0x1a
        x, y = @stack.pop(2)
        @stack.push x << y
      when 0x1b
        x, y = @stack.pop(2)
        @stack.push x >> y
      when 0x1c
        x, y = @stack.pop(2)
        @stack.push x[y]

      when 0x20
        x, y = @stack.pop(2)
        @stack.push (x == y) ? 1 : 0
      when 0x21
        x, y = @stack.pop(2)
        @stack.push (x != y) ? 1 : 0
      when 0x22
        x, y = @stack.pop(2)
        @stack.push (x < y) ? 1 : 0
      when 0x23
        x, y = @stack.pop(2)
        @stack.push (x <= y) ? 1 : 0
      when 0x24
        x, y = @stack.pop(2)
        @stack.push (x > y) ? 1 : 0
      when 0x25
        x, y = @stack.pop(2)
        @stack.push (x >= y) ? 1 : 0
      when 0x26
        x, y = @stack.pop(2)
        @stack.push x <=> y
      when 0x27
        x, y = @stack.pop(2)
        @stack.push (x =~ y) ? 1 : 0
      when 0x28
        @stack.push @stack.pop.min
      when 0x29
        @stack.push @stack.pop.max
      when 0x2a
        @stack.push @stack.sort

      when 0x30
        seq = []
        loop {
          next!
          case ins
          when 0xf0
            next!
            seq.push ins
          when 0xf1
            break
          when 0xf2
            seq = seq.pack("C*")
            break
          when 0xf3
            seq = Regexp.new seq.pack("C*")
            break
          when 0xf4
            $stdout.print seq.pack("C*")
            break
          else
            seq.push ins
          end
        }
        @stack.push seq

      when 0x31
        @stack.push @stack.pop.to_i
      when 0x32
        @stack.push @stack.pop.to_s

      when 0xa0..0xaf
        idx = ins - 0xa0
        @reg[idx] = @stack.pop

      when 0xb0..0xbf
        idx = ins - 0xb0
        @stack.push @reg[idx] || 0

      when 0xc0
        @stack.push @stack[-1].dup
      when 0xc1
        @stack.pop
      when 0xc2
        x, y = @stack.pop(2)
        @stack.push y, x
      when 0xc3
        x, y, z = @stack.pop(3)
        @stack.push z, x, y
      when 0xc4
        x, y, z = @stack.pop(3)
        @stack.push y, z, x
      when 0xc5
        @stack.rotate!(-1)
      when 0xc6
        @stack.rotate!(1)
      when 0xc7
        @stack.reverse!
      when 0xc8
        @stack.push @stack.size
      when 0xc9
        @stack.push @stack[-1].pop
      when 0xca
        @stack.push [@stack[-1].pop]
      when 0xcb
        arr, x = @stack.pop(2)
        arr += x
        @stack.push arr
      when 0xcc
        arr, x = @stack.pop(2)
        arr.push x
        @stack.push arr
      when 0xcd
        @stack.push []

      when 0xd0..0xda
        @stack.push ins - 0xd0
      when 0xdb
        @stack.push 100
      when 0xdc
        @stack.push 1000
      when 0xdd
        @stack.push 16
      when 0xde
        @stack.push 64
      when 0xdf
        @stack.push 256

      when 0xe0 # >
        @dir = 1
      when 0xe1 # <
        @dir = -1
      when 0xe2 # v
        @dir = 1i
      when 0xe3 # ^
        @dir = -1i
      when 0xe4 # /
        @dir = { 1 => -1i, -1 => 1i, 1i => -1, -1i => 1}[@dir]
      when 0xe5 # \
        @dir = { 1 => 1i, -1 => -1i, 1i => 1, -1i => -1}[@dir]
      when 0xe6 # |
        @dir = { 1 => -1, -1 => 1, 1i => 1i, -1i => -1i}[@dir]
      when 0xe7 # _
        @dir = { 1 => 1, -1 => -1, 1i => -1i, -1i => 1i}[@dir]
      when 0xe8 # clockwise
        @dir *= 1i
      when 0xe9 # anti-clockwise
        @dir *= -1i
      when 0xea # #
        @dir *= -1
      when 0xeb # random
        @dir = [1, -1, 1i, -1i][rand(4)]
      when 0xec # trampoline
        next!
      when 0xed # conditional trampoline
        a = @stack.pop
        f = true
        if a.is_a?(Array)
          f = a.empty?
        elsif a.is_a?(String)
          f = a.empty?
        elsif a.is_a?(Fixnum)
          f = a == 0
        end
        next! if f
      when 0xee # jump
        # Note that you have to jump to the cell before the instructions you want to execute.
        x, y = @stack.pop(2)
        @ptr = Complex(x, y)

      when 0xff
        exit
      end

      next!
    }
  end
end

lang = Lang.new(code)
lang.exec!
