def coposify(code)
  code.chars.map{|c| ?# * c.ord } * $/
end

IO.binwrite "./copos/hello.copos-rb", coposify('puts"Hello, world!"')

IO.binwrite "./copos/cat.copos-rb", coposify('$><<STDIN.read')

IO.binwrite "./golfish/hello.golfish", "\x30Hello, world!\n\xf4\xff"

IO.binwrite "./golfish/cat.golfish", "\x03\x05\xff"
