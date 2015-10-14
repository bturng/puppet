require 'spec_helper'


describe 'num2padded_string' do
  
  it 'is called with 45 and returns 45' do
    should run.with_params(45).and_return('45')
  end
  
  it 'is called with 45, 4 and returns 0045' do
    should run.with_params(45, 4).and_return('0045')
  end
  
  
end
