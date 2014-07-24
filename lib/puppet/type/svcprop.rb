Puppet::Type.newtype(:svcprop) do
    @doc = "Handle `system properties`. Inspired by solaris svcprop, and
primarily implemented for that purpose, although could theoretically be
used by other systems as well"

    # Not sure if this type should be ensurable. From an English language
    # point of view I want it to be, but
    # "ensurable" seems to imply a few things that dont sit well:
    # "create, destroy, exists?" does not seem to match paradigms
    ensurable do
      defaultvalues
      defaultto :present  #magic to default "ensure => present"
      
      # This appears to be "change to state", for "ensurable"s.
      def change_to_s(oldstate,newstate)
        ##Puppet.debug "svcprop: ### old is '#{oldstate}', new is '#{newstate}'"
        if ( oldstate == :absent && newstate == :present )
          return "set #{@resource[:property]} = #{@resource[:value]}"
        end
      end
    end


    newparam(:name) do
      desc "Mnemonic name"
      isnamevar
    end
    newparam(:fmri) do
      desc "Name of the FMRI that the property is associated with"
    end
    newparam(:property) do
      desc "Specific name of the property to be set or checked"
    end
    newparam(:value) do
      desc "value to set/check for the named property"
    end

    def validate
      # Let this be done by provider. But keep this for syntax at this level
      # unless self[:fmri] && self[:property] && self[:value]
      #  raise(ArgumentError,"svcprop: fmri and property and value must be defined")
      provider.validate if provider.respond_to?(:validate)

    end
    
    

end
