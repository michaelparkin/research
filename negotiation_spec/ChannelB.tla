------------------------------ MODULE ChannelB ------------------------------------------

EXTENDS          Bags, FiniteSets, Naturals,  TLC

CONSTANTS        Message,                            \* The set of messages that can be
                                                     \* sent and received on this channel.
                 MaxDuplicates                       \* The maximum number of duplicate
                                                     \* messages allowed on the network at
                                                     \* any one point in time.

VARIABLES        sent,                               \* The bag of sent messages.
                 network,                            \* The bag of messages on the network
                                                     \* waiting to be received.
                 received                            \* The set of received messages.

vars               == << sent, network, received >>  \* The tuple of all variables.

-----------------------------------------------------------------------------------------
(* The initial state. The sent messages and network are declared as empty bags. The set
  of received messages is initialised to the empty set.                                *)

Init               == /\ sent = EmptyBag
                      /\ network = EmptyBag
                      /\ received = {}

(* The send message action adds the message to the bag of sent messages and the 
   network, not changing the set of received messages.                                 *)

Send( msg )        == /\ sent' = sent (+) SetToBag( { msg } )
                      /\ network' = network (+) SetToBag( { msg } )
                      /\ UNCHANGED << received >>

(* The receive message action. If the message is present on the network add the
   message to the set of received messages and take the message from the network not
   changing the bag of sent messages.                                                  *)

Receive( msg )     == /\ BagIn( msg, network )
                      /\ received' = received \cup { msg }
                      /\ network' = network (-) SetToBag( { msg } )
                      /\ UNCHANGED << sent >>

(* The next state is found through either sending or receiving a message.              *)

Next               == \E msg \in Message :  Send(msg) \/ Receive( msg )

-----------------------------------------------------------------------------------------
(* The type invariants for the specification. Sent and network are bags and only 
   contain items from the set Message. The received set is finite and can only contain
   items from the set Message.                                                         *)

TypeInvariant      == /\ IsABag( sent )
                      /\ BagToSet( sent ) \subseteq Message
                      /\ IsABag( network )
                      /\ BagToSet( network ) \subseteq Message
                      /\ IsFiniteSet( received )
                      /\ received \subseteq Message

(* The liveness property is that the network is eventually empty.                      *)

Liveness           == <>( network = EmptyBag )

(* The safety properties for the specification are that all messages on the network
   and all received messages must have been sent.                                      *)

Safety             == /\ []( network \sqsubseteq sent )
                      /\ []( received \subseteq BagToSet( sent ) )

(* The message constraint allows a maximum number of duplicate messages on the network
   at any one point in time. Without this constraint checking the model would take
   forever - it would never complete.                                                  *)

MsgConstraint      == \A msg \in Message : CopiesIn( msg, sent ) \leq MaxDuplicates

-----------------------------------------------------------------------------------------
(* The channels specification and theorems.                                            *)

ChannelBSpec       == Init /\ [][Next]_vars

THEOREM ChannelBSpec => []TypeInvariant
THEOREM ChannelBSpec => Liveness /\ Safety
=========================================================================================