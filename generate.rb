def coposify(code)
  code.chars.map{|c| ?# * c.ord } * $/
end

IO.binwrite "./hello.copos-rb", coposify('puts"Hello, world!"')

IO.binwrite "./cat.copos-rb", coposify('$><<STDIN.read')

IO.binwrite "./hello.golfish", "\x30Hello, world!\n\xf4\xff"

IO.binwrite "./cat.golfish", "\x02\x05\xff"
