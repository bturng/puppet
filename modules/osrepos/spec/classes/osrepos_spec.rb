require 'spec_helper'


describe 'osrepos' do
  
  describe 'osrepos::gemrc' do
    let :facts do
      { :fqdn  =>  'test.dc01.revsci.net' }
    end
    
    it 'creates /etc/gemrc' do
      should contain_file('osrepos::gemrc').with(
        { 
          :owner  =>  'root', 
          :mode   =>  '0444'
        } )
    end
    
    it 'creates /usr/local/etc/gemrc' do
      should contain_file('/usr/local/etc/gemrc').with(
        { 
          :ensure =>  :link,
          :target =>  '/etc/gemrc',
          :owner  =>  'root', 
          :mode   =>  '0444'
        } )
    end
  end
  
  
  context 'Redhat' do
    [ #  operatingsystemrelease, architecture, os_dist_dir, yum_type
      ['6.4', 'x86_64', '6.4_64', 'yum'],
      ['6.3', 'x86_64', '6.3_64', 'yum'],
      ['6.2', 'x86_64', '6.2_64', 'yum'],
      ['6.1', 'x86_64', '6.1_64', 'yum'],
      ['6.0', 'x86_64', '6.0_64', 'yum'],
      ['5.7', 'x86_64', '5.7_64', 'yum5'],
      ['5.6', 'x86_64', '5.6_64', 'yum5'],
      ['5.5', 'x86_64', '5.5_64', 'yum5']
    ].each do |osinfo|
      describe "#{osinfo[0]}" do
        let :facts do
          { :operatingsystem        => 'Redhat',
            :operatingsystemrelease => osinfo[0],
            :architecture           => osinfo[1],
            :fqdn                   => 'host.slc.ebay.com' }
        end
          
          
        it 'creates /etc/yum.repos.d/ebay-rhel-repo.repo' do
          should contain_file('/etc/yum.repos.d/ebay-rhel-repo.repo').with(
          {
            :owner  =>  'root', 
            :mode   =>  '0444'
          } )
          .with_content(/baseurl=http:\/\/installsvc.vip.slc.ebay.com\/images\/redhat\/#{osinfo[2]}\//)
        end
        
        
        it 'creates /etc/yum.repos.d/ebay-packages-repo.repo' do
          should contain_file('/etc/yum.repos.d/ebay-packages-repo.repo').with(
          {
            :owner  =>  'root', 
            :mode   =>  '0444'
          } )
          .with_content(/baseurl=http:\/\/installsvc.vip.slc.ebay.com\/packages\/#{osinfo[3]}/)
        end
        
      end
    end
  end
  
  
end