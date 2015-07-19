# See http://www.kartar.net/2010/02/puppet-types-and-providers-are-easy/

Puppet::Type.type(:svcprop).provide(:solaris) do
  desc "Provider for Solaris svcprop"
  defaultfor :operatingsystem => :solaris

  commands :svccfg => "/usr/sbin/svccfg"
  commands :svcprop => "/usr/bin/svcprop"
  commands :svcadm => "/usr/sbin/svcadm"

  def create
    # we need to enclose multi-item values  with ()
    if ("#{@resource[:value]}" =~ / /)
      svccfg("-s",resource[:fmri],"setprop",resource[:property],"= ( ",resource[:value]," )")
    else
      svccfg("-s",resource[:fmri],"setprop",resource[:property],"=",resource[:value])
    end
    svcadm("refresh", @resource[:fmri])
  end

  def destroy
    Puppet.debug " ### svcprop.destroy called"
      raise ArgumentError, "svcprop cant really destroy a property. Define a value for it instead"
  end

  def exists?
    #Puppet.debug "svcprop.exists? has been called"
    #Puppet.debug "fmri is '#{@resource[:fmri]}'"
    #Puppet.debug "svcprop:property is #{@resource[:property]}"
    #Puppet.debug "svcprop:value is #{@resource[:value]}"

    if ("#{@resource[:property]}" == "")
      raise ArgumentError, "svcprop requires 'property' to be defined"
    end
    if ("#{@resource[:value]}" == "")
      raise ArgumentError, "svcprop requires 'value' to be defined"
    end

    begin
      output = svccfg("-s", @resource[:fmri], "listprop", "-o", "value", @resource[:property]).strip
    rescue
      return false
    end
    
    #Puppet.debug "svcprop return value is '#{output}'"

    if output == "#{@resource[:value]}"
      return true
    end
    
    return false
  end
  

  def validate
    Puppet.debug("  ### svcprop.solaris.validate called ## ")
    unless @resource[:fmri] and @resource[:property] and @resource[:value]
      raise ArgumentError,
            "svcprop must have fmri and property and value set"
    end
  end
  
end

