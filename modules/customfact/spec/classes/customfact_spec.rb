
require 'spec_helper'

describe 'customfact' do
  let(:facts) { {:rubysitedir  => '/usr/lib/ruby/site'} }

  it 'creates /etc/facts.d' do
    should contain_file('/etc/facts.d').with(
              { 'ensure' => 'directory', 
                'owner'  => 'root',
                'group'  => 'root' } )
  end
  
  it 'installs fact-dot-d.rb' do
    should contain_file('/usr/lib/ruby/site/facter/facts-dot-d.rb')
    #.with(
    #        { 'owner' => 'root', 
    #          'group' => 'root',
    #          'mode'  => '0444' } )
  end
  
end