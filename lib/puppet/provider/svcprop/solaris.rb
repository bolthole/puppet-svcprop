# See http://www.kartar.net/2010/02/puppet-types-and-providers-are-easy/

Puppet::Type.type(:svcprop).provide(:solaris) do
  desc 'Provider for Solaris svcprop'
  defaultfor :operatingsystem => :solaris

  commands :svccfg  => '/usr/sbin/svccfg'
  commands :svcprop => '/usr/bin/svcprop'
  commands :svcadm  => '/usr/sbin/svcadm'

  def create
    # Set a default type of 'astring'. The user can override this.
    #
    @resource[:type] ||= 'astring'

    # If the user has given us an array, join it with spaces

    if @resource[:value].is_a?(Array)
      @resource[:value] = @resource[:value].join(' ')
    end

    # we need to enclose multi-item values  with ()

    val = @resource[:value].match(/\s/) ? '(' + @resource[:value] + ')' :
                                          @resource[:value]

    svccfg('-s', @resource[:fmri], 'setprop', @resource[:property],
           '=', "#{@resource[:type]}:",  val)

    svcadm('refresh', @resource[:fmri])
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
      output = svcprop("-p", @resource[:property], @resource[:fmri]).strip
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

