require 'spec_helper'


describe 'find_install_domain' do
  
  it 'throw exeption if called with any parameters' do
    should run.with_params('somewhere').and_raise_error(Puppet::ParseError)
  end
  
  scenerios = [ ['SLC', 'host.slc.ebay.com', 'slc.ebay.com'],
                ['LVS', 'host.lvs.ebay.com', 'lvs.ebay.com'],
                ['PHX', 'host.phx.ebay.com', 'phx.ebay.com'],
                ['SJC', 'host.sjc.ebay.com', 'slc.ebay.com'],
                ['SMF', 'host.smf.ebay.com', 'slc.ebay.com'],
                ['SLC(stratus)', 'host.stratus.slc.ebay.com', 'slc.ebay.com'],
                ['LVS(stratus)', 'host.stratus.lvs.ebay.com', 'lvs.ebay.com'],
                ['PHX(stratus)', 'host.stratus.phx.ebay.com', 'phx.ebay.com'],
                ['CORP', 'host.corp.ebay.com', 'slc.ebay.com'],
                ['DEV', 'host.dev.ebay.com', 'slc.ebay.com'],
                ['ENGRS', 'host.engrs.ebay.com', 'slc.ebay.com'],
               ]
                
                
  scenerios.each do |testinfo|
    context "in #{testinfo[0]}" do
      let :facts do
        { :fqdn  =>  testinfo[1] }
      end
    
      it "returns #{testinfo[2]}" do
        should run.with_params.and_return(testinfo[2])
      end
    end
  end
  
end
