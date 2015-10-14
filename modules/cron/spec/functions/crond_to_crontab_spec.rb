require 'spec_helper'

describe 'crond_to_crontab' do 
  
  it "raises Puppet::ParseError if not correct number of params" do
    should run.with_params().and_raise_error(Puppet::ParseError) 
  end
  
  
  it "removes username from cron.d entry" do
    crond_entry = '10 * * * * root /bin/date >> $PUPPET_LOG ; /bin/sleep 0; puppet agent --onetime -v >>$PUPPET_LOG 2>&1'
    crontab_entry = '10 * * * * /bin/date >> $PUPPET_LOG ; /bin/sleep 0; puppet agent --onetime -v >>$PUPPET_LOG 2>&1'
    
    should run.with_params(crond_entry).and_return(crontab_entry)
    
  end
  
  
  it "removes username from complex cron.d entry" do
    crond_entry = '0,15,30,45  2,15   7,14,28   *   3,5   root   puppet apply /etc/puppet/manifests/motd-stats.pp >$PUPPET_LOG 2>&1'
    crontab_entry = '0,15,30,45 2,15 7,14,28 * 3,5 puppet apply /etc/puppet/manifests/motd-stats.pp >$PUPPET_LOG 2>&1'
    
    should run.with_params(crond_entry).and_return(crontab_entry)
    
  end
  
  
  it "substitutes variables into complex cron.d entry" do
    crond_entry = '''PUPPET_LOG=/var/log/puppet/puppet.log
0,15,30,45  2,15   7,14,28   *   3,5   root   puppet apply /etc/puppet/manifests/motd-stats.pp >$PUPPET_LOG 2>&1
'''
    crontab_entry = '0,15,30,45 2,15 7,14,28 * 3,5 puppet apply /etc/puppet/manifests/motd-stats.pp >/var/log/puppet/puppet.log 2>&1'
  
    should run.with_params(crond_entry).and_return(crontab_entry)
  
  end
  
  
  it "prepends $PATH to cron.d command" do
    crond_entry = '''PATH=/usr/local/bin:/usr/bin:/bin
0,15,30,45  2,15   7,14,28   *   3,5   root   puppet apply /etc/puppet/manifests/motd-stats.pp >$PUPPET_LOG 2>&1
'''
    crontab_entry = '0,15,30,45 2,15 7,14,28 * 3,5 PATH=/usr/local/bin:/usr/bin:/bin; export PATH; puppet apply /etc/puppet/manifests/motd-stats.pp >$PUPPET_LOG 2>&1'
  
    should run.with_params(crond_entry).and_return(crontab_entry)
  
  end
  

  it "substitutes variables into crontab entry" do
    crond_entry = "PUPPET_LOG='/var/log/puppet.log\n10 * * * * root /bin/date >> $PUPPET_LOG ; /bin/sleep 0; puppet agent --onetime -v >>$PUPPET_LOG 2>&1"
    crontab_entry = '10 * * * * /bin/date >> /var/log/puppet.log ; /bin/sleep 0; puppet agent --onetime -v >>/var/log/puppet.log 2>&1'
    
    should run.with_params(crond_entry).and_return(crontab_entry)
    
  end
  
  
end

