require 'spec_helper'
require 'deterministic/enum'

describe Deterministic::Enum  do
  include Deterministic

  it "value" do
    expect { InvalidEnum = Deterministic::enum {
      Unary(:value)
    }}.to raise_error ArgumentError
  end

  context "Nullary, Unary, Binary" do
    MyEnym = Deterministic::enum {
      Nullary()
      Unary(:a)
      Binary(:a, :b)
    }

    it "Nullary" do
      n = MyEnym::Nullary.new

      expect(n).to be_a MyEnym
      expect(n).to be_a MyEnym::Nullary
      expect { n.value }.to raise_error
      expect(n.inspect).to eq "Nullary"
      expect(n.to_s).to eq ""
      expect(n.fmap { }).to eq n
    end

    it "Unary" do
      u = MyEnym::Unary.new(1)

      expect(u).to be_a MyEnym
      expect(u).to be_a MyEnym::Unary
      expect(u.a).to eq 1
      expect(u.value).to eq 1
      expect(u.inspect).to eq "Unary(1)"
      expect(u.to_s).to eq "1"
    end

    it "Binary" do
      # hash
      b = MyEnym::Binary.new(a: 1, b: 2)
      expect(b).to be_a MyEnym
      expect(b).to be_a MyEnym::Binary
      expect(b.inspect).to eq "Binary(a: 1, b: 2)"

      expect(b.a).to eq 1
      expect(b.b).to eq 2
      expect(b.value).to eq({a: 1, b: 2})

      # values only
      b = MyEnym::Binary.new(1, 2)
      expect(b.value).to eq({a: 1, b: 2})

      # other names are ok
      b = MyEnym::Binary.new(c: 1, d: 2)
      expect(b.value).to eq({a: 1, b: 2})

      expect { MyEnym::Binary.new(1) }.to raise_error ArgumentError
    end

    it "generated enum" do
      expect(MyEnym.variants).to eq [:Nullary, :Unary, :Binary]
      expect(MyEnym.constants.inspect).to eq "[:Nullary, :Unary, :Binary, :Matcher]"

      b = MyEnym::Binary.new(a: 1, b: 2)

      res =
        MyEnym.match(b) {
          Nullary()  { 0 }
          Unary(a) { [a, b] }
          Binary(x, y) { [x, y]}
        }

      expect(res).to eq [1, 2]

      res =
        b.match {
          Nullary()  { 0 }
          Unary(a) { [a, b] }
          Binary(x, y) { [x, y]}
        }

      expect(res).to eq [1, 2]
    end
  end
end
