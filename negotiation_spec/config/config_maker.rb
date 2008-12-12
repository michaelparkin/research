#!/usr/bin/ruby
# This script creates a set of TLC config files for running
# the negotiation protocol specification. It allows you to
# vary for each check/instance of TLC the maximum total
# number of messages sent and the maximum number of duplicates
# that can exist on the netork (i.e., within each network
# channel) at one any step.
# Once the config files have been created they will have the
# name 'nxm.cfg' (e.g., 20x1.cfg). n is the maximum number of
# messages and m is the maximum number of duplicates.
# The set of config files produced can then be used with the
# script 'runner.sh'.

max_num_of_messages   = 20
max_num_of_duplicates = 1

(1..max_num_of_messages).each do |messages|

  (1..max_num_of_duplicates).each do |duplicates|

    file_name = messages.to_s + "x" + duplicates.to_s + ".cfg"

    message_string = "1"
    (2..messages).each do |m|
      message_string += "," + m.to_s
    end

    file_contents = "
    SPECIFICATION     NewSpec
    CONSTANTS         MessageId     = { #{message_string} }
                      NullId        = null
                      MaxDuplicates = #{duplicates}
    INVARIANT         TypeInvariant
    PROPERTY          Liveness
    CONSTRAINT        MsgConstraint"

    File.open(file_name, 'w') { |f| f.write(file_contents) }
  end
end

