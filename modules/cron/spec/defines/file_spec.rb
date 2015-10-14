require 'spec_helper'

describe 'cron::file' do 
  let(:title)  { 'some_task' }
  let(:params) { { :source => "puppet:///modules/${module_name}/some_task" } }
  #let(:params) { { :content => template("cron/some_task.erb") } }

  context 'Ubuntu' do
    let(:facts) { {:operatingsystem => 'Ubuntu' } }
    
    it 'creates /etc/cron.d/some_task' do
      should contain_file('/etc/cron.d/some_task') 
              .with_ensure('present') 
            #  .with_owner('root') 
            #  .with_mode('0444')
    end
  end
  
  
  context 'Beos' do
    let(:facts) { {:operatingsystem => 'Beos'} }
    
    it 'produces an fail condition' do
      expect {
        should contain_file('/etc/cron.d/some_task')
      }.to raise_error(Puppet::Error)
    end
  end
  
end
