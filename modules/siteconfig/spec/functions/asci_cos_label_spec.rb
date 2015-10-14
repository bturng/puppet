require 'spec_helper'

describe 'asci_cos_label' do
  
  it 'throw exeption if called with more than 1  parameter' do
    should run.with_params('somewhat', 'somewhere').and_raise_error(Puppet::ParseError)
  end                                                                                                                                                                                                                                                   
  
  # Following table fully exersizes the network map defined in asci_site_label.rb
  scenerios = [[ 'PROD', '10.2.1.30' ],    [ 'PROD', '10.1.100.64' ],
               [ 'PROD', '10.6.99.24' ],   [ 'PROD', '10.1.10.59' ],
               [ 'PROD', '10.1.20.9' ],    [ 'PROD', '10.1.30.208' ],
               [ 'PROD', '10.1.40.1' ],    [ 'PROD', '10.1.200.42' ],
               [ 'PROD', '10.7.14.27' ],   [ 'PROD', '10.8.31.28' ],
               [ 'PROD', '10.11.87.184' ],
               [ 'PROD', '10.1.50.5' ],    [ 'PROD', '10.5.3.35' ],
               [ 'PROD', '10.1.60.58' ],   [ 'PROD', '10.1.65.39' ],
               [ 'PROD', '10.1.70.101' ],  [ 'PROD', '10.1.75.14' ],
               [ 'PROD', '10.17.4.105' ],
               [ 'PROD', '10.18.2.11' ],
               [ 'PROD', '10.25.5.208' ],
               [ 'PROD', '10.20.3.78' ], 
               [ 'PROD', '10.21.1.16' ],
               [ 'PROD', '10.24.13.123' ],              
               [ 'DEV', '10.13.8.29' ],   [ 'PROD', '10.244.1.45' ],
               [ 'PROD', '172.16.18.34' ], ]
    
  scenerios.each do |testinfo|
    context "in #{testinfo[1]}" do
      before :each do
        Facter.clear 
      end
      
      let! :facts do
        { :ipaddress_eth0  =>  testinfo[1], 
          :interfaces      =>  'bond0,docker0,eth0,lo0' }
      end
      
      it "returns #{testinfo[0]}" do
        should run.with_params().and_return(testinfo[0])
      end
    end
  end
  
  # Validate that the function can identify a number of interfaces
  context "identifies em3" do
    before :each do
      Facter.clear 
    end
        
    let :facts do
      { :ipaddress_em3   =>  scenerios[0][1], 
        :interfaces      =>  'em3,lo0' }
    end
      
    it "returns #{scenerios[0][0]}" do
      should run.with_params().and_return(scenerios[0][0])
    end
  end
  
  context "identifies em1" do
    before :each do
      Facter.clear 
    end
         
    let :facts do
      { :ipaddress_em1   =>  scenerios[0][1], 
        :interfaces      =>  'em1,lo0' }
    end
      
    it "returns #{scenerios[0][0]}" do
      should run.with_params().and_return(scenerios[0][0])
    end
  end
  
  context "identifies bond0" do
    before :each do
      Facter.clear 
    end
    
    let :facts do
      { :ipaddress_bond0 =>  scenerios[0][1], 
        :interfaces      =>  'bond0,lo0' }
    end
      
    it "returns #{scenerios[0][0]}" do
      should run.with_params().and_return(scenerios[0][0])
    end
  end
  
  context "identifies eth2" do
    before :each do
      Facter.clear 
    end
    
    let :facts do
      { :ipaddress_eth2  =>  scenerios[0][1], 
        :interfaces      =>  'eth2,lo0' }
    end
      
    it "returns #{scenerios[0][0]}" do
      should run.with_params().and_return(scenerios[0][0])
    end
  end
  
  # throws exception when valid inteface can not be found
  context "with invalid interfaces" do
    before :each do
      Facter.clear 
    end
    
    let :facts do
      { :ipaddress_eth1  =>  scenerios[0][1], 
        :interfaces      =>  'eth1,lo0' }
    end
      
    it "throws exception" do
      should run.with_params().and_raise_error(Puppet::Error)
    end
  end
  
  
  # Test the behavior when function executes on a host that is out of range
  bad_ips = [ '134.141.1.1', '208.56.40.231' ]
  
  # First test if an exception gets thrown
  bad_ips.each do |testinfo|
    context "in #{testinfo}" do
      before :each do
        Facter.clear 
      end
      
      let! :facts do
        { :ipaddress_eth0  =>  testinfo, 
          :interfaces      =>  'bond0,docker0,eth0,lo0' }
      end
      
      it "throws exception" do 
        should run.with_params().and_raise_error(Puppet::Error)
      end
    end
  end
  
  # Next test to see if function quietly returns nothing
  bad_ips.each do |testinfo|
    context "in #{testinfo}" do
      before :each do
        Facter.clear 
      end
      
      let! :facts do
        { :ipaddress_eth0  =>  testinfo, 
          :interfaces      =>  'bond0,docker0,eth0,lo0' }
      end
      
      it "returns nothing" do 
        should run.with_params(true).and_return('')
      end
    end
  end
  
end

