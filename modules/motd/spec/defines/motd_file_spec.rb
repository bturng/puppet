require 'spec_helper'

describe 'motd::file' do
  let(:facts) { {:operatingsystem => 'Ubuntu'} }
  let(:title) { 'mary-announce' }
  let(:params) { {:level => '45', 
                  :source => "puppet:///modules/${module_name}/motd_file_test.txt"} }
  
  it 'creates a motd component file from parameters' do
    should contain_file('/etc/motd.d/45-mary-announce')
  end
  
  describe 'allows level to be specified as a number' do
    let(:params) { {:level => 45, 
                    :source => "puppet:///modules/${module_name}/motd_file_test.txt"} }
  
    it do 
      should contain_file('/etc/motd.d/45-mary-announce')
    end
  end
  
  
  describe 'fails when source or content are not specified' do
    let(:params) { {:level => '45'} }
  
    it do 
      expect {
        should contain_file('/etc/motd.d/45-mary-announce')
      }.to raise_error(Puppet::Error, /requires either/)
    end
  end
  
end
