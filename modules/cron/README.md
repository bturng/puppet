ghickey-cron
============

Puppet module for automating cron and creating cron.d files across multiple platforms. 

Usage
-----

There are two methods to use this module. In both cases it is required that you include the cron class in the class in which you reference a cron file or the cron daemon. This can be done by using the following line in your class definition. 

    include cron

The first method for using this module should be used for 99.9% of the use cases. Actually I am not able to come up with a reason to using the second method as it is more prone for producing errors in your Puppet modules and makes you do more work. But it will be explained on the off chance someone actually finds a need to use it. 

So the first method is using the cron::file define function to create the cron entry and signal cron to restart. This is accomplished with something like the following:

```ruby
    cron::file{"report_run":
        source  => "puppet:///modules/${module_name}/report_run",
    }
```

What this crafty line will do is pull the report_run file from your modules files directory and install it as /etc/cron.d/report_run. It will then send a notification to cron to restart so that the file will be read. This file should have the standard cron.d file format similar to the following:

    <min> <hr> <day> <mon> <dow> <user> <cmd>

Note that this is much like a crontab entry, but with the user added as the sixth field. Because this is directly copied to /etc/cron.d the file can have any of the standard items that cron.d files are allowed to have such as environmental variable definitions, PATH settings, and multiple cron entries. 

Using the cron::file type will handle the cron daemon name differences on various operating systems. In addition the secret sauce also will convert the cron.d entry to a crontab entry for Solaris and add it to the root crontab. At this time only root crontab is supported, but a future version will support the user that is specified on the cron line. Send email if you need this support sooner than later. 

The Solaris support requires that the content parameter be used instead of the source parameter. Again a future version will probably remove this restriction and send email if you need it sooner. So if you are supporting Solaris along with Linux, you probably want to specify the resource as follows: 

```ruby
    cron::file{"report_run":
        content  => template("${module_name}/report_run.erb"),
    }
```

This of course requires that you put your cron entry in an ERB template--even if you are not doing any variable substitution. 

A few additional things get for free under Solaris is variable substitution on the command line and prepending the command with the PATH variable. So if you had the following cron ERB template:

```bash
    PUPPET_LOG='/var/log/puppet/puppet.log'
    PATH=/usr/local/bin:/usr/bin:/bin
    0 * * * * root puppet agent -t --logdest $PUPPET_LOG 2>/dev/null
    30 * * * * root puppet agent -t --logdest $PUPPET_LOG 2>/dev/null
```

You would get the following lines written to the crontab:

```bash
    #####
    # report_run created by Puppet
    0 * * * * PATH=/usr/local/bin:/usr/bin:/bin puppet agent -t --logdest /var/log/puppet/puppet.log 2>/dev/null
    30 * * * * PATH=/usr/local/bin:/usr/bin:/bin puppet agent -t --logdest /var/log/puppet/puppet.log 2>/dev/null
```

Final note about the Solaris support. While it will support pretty much all the cron formats you can think of, it will not support the enhanced time specifications that were introduced with Vixie cron. So time formats like "0,15,30,45" will work just fine where as "*/15" will not be understood and the result would be that no crontab entry gets made. 

Now for the second method. You can do things manually by creating your own file resource that notifies cron to restart. 

```ruby
    file {'/etc/cron.d/someservice':
        # Settings for manually setting crontab file
        ensure   => present,
        notify   => Service['cron'],
    }
```

While you do get the advantage of restarting cron on any platform you happen to be on, you don't get the support of Solaris. Again you get to do everything by hand: "here you go sonny, here is a nickle, go buy yourself a real Puppet manifest!"

That is about it. Should be all you need to know to use this module. 


Contact
-------

Gerard Hickey <ghickey@ebay.com>

Support
-------

You want what?!?
