require File.expand_path('../../../spec_helper', __FILE__)

require 'picky-indexes/rust/array'

describe Rust::Array do
  
  it 'can be created' do
    described_class.new
  end
  
  it 'finalizable (will run after specs)' do
    ohai = described_class.new
    ohai = nil
  end
  
  let(:empty) { described_class.new }
  let(:array) { described_class.new }
  
  describe 'with some elements' do
    before(:each) do
      5.times { |i| array << i }
    end
    describe '#first' do
      # it 'handles an empty array' do
      #   empty.first.assert == nil
      # end
      it 'is correct' do
        array.first.assert == 0
      end
    end
    describe '#last' do
      # it 'handles an empty array' do
      #   empty.last.assert == nil
      # end
      it 'is correct' do
        array.last.assert == 4
      end
    end
    describe '#length' do
      it 'handles an empty array' do
        empty.length.assert == 0
      end
      it 'is correct' do
        array.length.assert == 5
      end
    end
    describe '#size' do
      it 'handles an empty array' do
        empty.size.assert == 0
      end
      it 'is correct' do
        array.size.assert == 5
      end
    end
    describe '#intersect' do
      it 'handles a left empty array' do
        empty.intersect(array).assert == Rust::Array.new
      end
      it 'handles a right empty array' do
        array.intersect(empty).assert == Rust::Array.new
      end
      it 'is correct' do
        array.intersect(array).assert == array
      end
      it 'is correct' do
        a1 = Rust::Array.new
        a1 << 2 << 3 << 4
        
        a2 = Rust::Array.new
        a2 << 3 << 4 << 5
        
        expected = Rust::Array.new
        expected << 3 << 4
        
        a1.intersect(a2).assert == expected
        a2.intersect(a1).assert == expected
      end
    end
    describe '#slice!' do
      # it 'handles an empty array' do
      #   empty.slice!(1,1).assert == nil
      # end
      it 'is correct' do
        expected = Rust::Array.new
        expected << 0 << 1 << 3 << 4
        
        array.slice!(2,1)
        
        array.assert == expected
      end
      it 'returns the deleted object(s)' do
        expected = Rust::Array.new
        expected << 2 << 3
        
        array.slice!(2,2).assert == expected
      end
      it 'handles a too large amount' do
        expected = Rust::Array.new
        expected << 0 << 1 << 2 << 3 << 4
        
        array.slice!(0,20).assert == expected
      end
    end
    describe '#==' do
      it 'handles empty arrays' do
        assert empty == empty.dup
      end
      it 'handles empty arrays' do
        assert !(empty == array)
      end
      it 'handles empty arrays' do
        assert !(array == empty)
      end
      it 'handles normal arrays' do
        assert array == array.dup
      end
      it 'handles normal arrays' do
        shorty = Rust::Array.new
        shorty << 1
        
        assert !(array == shorty)
      end
    end
  end
  
  describe '#<<' do
    it 'works' do
      array << 1
    end
    it 'returns the array' do
      expected = Rust::Array.new
      expected << 1

      result = array << 1
      expected.assert == result
    end
    # it 'actually appends' do
    #   # [].assert == array
    #
    #   array << 1
    #
    #   # assert [1] == array
    # end
  end
  describe '#shift' do
    # it 'works with empty arrays' do
    #   empty.shift.assert == nil
    # end
    it 'works' do
      array << 7
      array << 8
      array << 9
      
      array.shift.assert == 7
      array.shift.assert == 8
      array.shift.assert == 9
    end
  end
  describe '#unshift' do
    it 'works with empty arrays' do
      expected = Rust::Array.new
      expected << 7
      
      empty.unshift(7).assert == expected
    end
    it 'works with normal arrays' do
      expected = Rust::Array.new
      expected << 7 << 1 << 2
      
      array << 1 << 2
      array.unshift(7).assert == expected
    end
  end
  
end