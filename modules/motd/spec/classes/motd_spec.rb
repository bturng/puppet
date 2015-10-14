require 'spec_helper'

describe 'motd' do
  
  context 'Ubuntu' do
    let(:facts) { {:operatingsystem => 'Ubuntu'} }
    
    it 'creates the /etc/motd.d directory' do
      should contain_file('/etc/motd.d')
    end
    
    
    it 'creates the /usr/local/bin/motd script' do 
      should contain_file('/usr/local/bin/motd')
                .with_owner('root')
                .with_mode('0555')
    end
    
    
    it 'creates legal disclaimer component file' do
      should contain_file('/etc/motd.d/00-authorized-use')
                .with_owner('root').with_mode('0444')
                #.with_notify('Exec["motd::generate motd"]')
    end
    
    
    it 'creates managed by puppet component file' do
      should contain_file('/etc/motd.d/10-managed-by-puppet')
                .with_owner('root').with_mode('0444')
                #.with_notify('Exec["motd::generate motd"]')
    end
    
    
    it 'can regenerate the /etc/motd file' do
      should contain_exec('motd::generate motd')
                .with_command('/usr/local/bin/motd generate')
    end
      
    
    it 'prepares to generate system stats in cron' do
      should contain_file('/etc/puppet/manifests/motd-stats.pp')
    end
    
    it 'prepares to generate system stats in cron' do
      should contain_file('/etc/puppet/templates/system-stats.erb')
    end
  end
  
  
  context 'CentOS' do
    let(:facts) { {:operatingsystem => 'CentOS'} }
    
    it 'creates the /etc/motd.d directory' do
      should contain_file('/etc/motd.d')
    end
    
    
    it 'creates the /usr/local/bin/motd script' do 
      should contain_file('/usr/local/bin/motd')
                .with_owner('root')
                .with_mode('0555')
    end
    
    
    it 'creates legal disclaimer component file' do
      should contain_file('/etc/motd.d/00-authorized-use')
                .with_owner('root').with_mode('0444')
                #.with_notify('Exec["motd::generate motd"]')
    end
    
    
    it 'creates managed by puppet component file' do
      should contain_file('/etc/motd.d/10-managed-by-puppet')
                .with_owner('root').with_mode('0444')
                #.with_notify('Exec["motd::generate motd"]')
    end
    
    
    it 'can regenerate the /etc/motd file' do
      should contain_exec('motd::generate motd')
                .with_command('/usr/local/bin/motd generate')
    end
      
    
    it 'prepares to generate system stats in cron' do
      should contain_file('/etc/puppet/manifests/motd-stats.pp')
    end
    
    it 'prepares to generate system stats in cron' do
      should contain_file('/etc/puppet/templates/system-stats.erb')
    end
  end
  
  
  context 'Solaris' do
    let(:facts) { {:operatingsystem => 'Solaris'} }
    
    it 'creates the /etc/motd.d directory' do
      should contain_file('/etc/motd.d')
    end
    
    
    it 'creates the /usr/local/bin/motd script' do 
      should contain_file('/usr/local/bin/motd')
                .with_owner('root')
                .with_mode('0555')
    end
    
    
    it 'creates legal disclaimer component file' do
      should contain_file('/etc/motd.d/00-authorized-use')
                .with_owner('root').with_mode('0444')
    end
    
    
    it 'creates managed by puppet component file' do
      should contain_file('/etc/motd.d/10-managed-by-puppet')
                .with_owner('root').with_mode('0444')
    end
    
    
    it 'can regenerate the /etc/motd file' do
      should contain_exec('motd::generate motd')
                .with_command('/usr/local/bin/motd generate')
    end
      
    
    it 'prepares to generate system stats in cron' do
    end
    
    it 'prepares to generate system stats in cron' do
    end
  end
  
end
