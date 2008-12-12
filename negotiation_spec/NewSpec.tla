------------------------------------ MODULE NewSpec -------------------------------------

EXTENDS            Bags, FiniteSets, Naturals, TLC

CONSTANTS          MessageId,                      \* The set of all possible message
                                                   \* identifiers that can be used in
                                                   \* the negotiation.
                   NullId,                         \* The empty message identifier.
                   MaxDuplicates                   \* The maximum number of duplicate
                                                   \* messages allowed on the network
                                                   \* at any one point in time.

VARIABLES          provContracted, custContracted, \* Boolean flags denoting whether the
                                                   \* provider and customer are in a
                                                   \* contracted state (or not).
                   provSent, custSent,             \* The sets of messages sent by the
                                                   \* provider and customer.
                   provInQ, custInQ,               \* The bags of messages waiting to be
                                                   \* received by the provider and 
                                                   \* customer.
                   provRcvd, custRcvd,             \* The sets of messages received by
                                                   \* the provider and customer.
                   ackdOffer,                      \* The set of acknowledged but
                                                   \* unprocessed offers.
                   usedId                          \* The set of used MessageIds.

-----------------------------------------------------------------------------------------
(***************************************************************************************)
(* Definitions of the allowed messages in the protocol.                                *)
(***************************************************************************************)

QuoteRequestMessage  == [ messageType: { "QuoteRequest" },
                          messageId: MessageId,
                          correlationId: MessageId \cup { NullId } ]

OfferMessage         == [ messageType: { "Offer" },
                          messageId: MessageId,
                          correlationId: MessageId \cup { NullId } ]

RevokeRequestMessage == [ messageType: { "RevokeRequest" },
                          messageId: MessageId,
                          correlationId: MessageId \cup { NullId } ]

QuoteMessage         == [ messageType: { "Quote" },
                          messageId: MessageId,
                          correlationId: MessageId \cup { NullId } ]

OfferAckMessage      == [ messageType: { "OfferAck" },
                          messageId: MessageId,
                          correlationId: MessageId ]

AcceptMessage        == [ messageType: { "Accept" }, 
                          messageId: MessageId,
                          correlationId: MessageId ]

RejectMessage        == [ messageType: { "Reject" },
                          messageId: MessageId,
                          correlationId: MessageId ]

RevokeAcceptMessage  == [ messageType: { "RevokeAccept" },
                          messageId: MessageId,
                          correlationId: MessageId ]

ProvMessage          == UNION{ QuoteMessage, OfferAckMessage,
                               AcceptMessage, RejectMessage,
                               RevokeAcceptMessage }

CustMessage          == UNION{ QuoteRequestMessage, OfferMessage,
                               RevokeRequestMessage }

-----------------------------------------------------------------------------------------
(***************************************************************************************)
(* A function to return a message identifier that hasn't been used before in the 
   negotiation. This ensures that each new message has a unique identifier.            *)
(***************************************************************************************)

NewId              == CHOOSE id \in MessageId : id \notin usedId

-----------------------------------------------------------------------------------------
(***************************************************************************************)
(* Definition of the messaging channels. p2c is provider to customer, c2p is customer
   to provider.                                                                        *)
(***************************************************************************************)

c2p                == INSTANCE ChannelB WITH sent <- custSent,
                                             received <- provRcvd,
                                             network <- provInQ,
                                             Message <- CustMessage,
                                             MaxDuplicates <- MaxDuplicates

p2c                == INSTANCE ChannelB WITH sent <- provSent,
                                             received <- custRcvd,
                                             network <- custInQ,
                                             Message <- ProvMessage,
                                             MaxDuplicates <- MaxDuplicates

-----------------------------------------------------------------------------------------
(***************************************************************************************)
(* PROVIDER SERVICE SPECIFICATION.                                                     *)
(***************************************************************************************)
-----------------------------------------------------------------------------------------

(***************************************************************************************)
(* A function to check if a type of message has been sent in response to a particular
   offer.                                                                              *)
(***************************************************************************************)

AlreadySent( offer, type ) ==
                      /\ { msg \in BagToSet( provSent ) \intersect type :
                           offer.messageId = msg.correlationId } # {}

(***************************************************************************************)
(* Message resend actions for the provider.                                            *)
(***************************************************************************************)

ResendRevokeAccept( offer ) == 
                      LET matches == { msg \in BagToSet( provSent )
                            \intersect RevokeAcceptMessage :
                                  offer.messageId = msg.correlationId }
                      IN /\ LET revokeAccept == CHOOSE msg \in matches :
                                  msg.messageType = "RevokeAccept"
                            IN /\ p2c!Send( revokeAccept )
                               /\ UNCHANGED << provContracted, provRcvd, provInQ,
                                               custContracted, custSent,
                                               custRcvd, usedId >>

ResendReject( offer ) ==
                      LET matches == { msg \in BagToSet( provSent )
                            \intersect RejectMessage :
                                  offer.messageId = msg.correlationId }
                      IN /\ LET reject == CHOOSE msg \in matches :
                                  msg.messageType = "Reject"
                            IN /\ p2c!Send( reject )
                               /\ UNCHANGED << provContracted, ackdOffer,
                                               custContracted, custSent,
                                               custRcvd, usedId >>

ResendAccept       == LET accept == CHOOSE msg \in BagToSet( provSent)
                            \intersect AcceptMessage : msg.messageType = "Accept"
                      IN /\ p2c!Send( accept )
                         /\ UNCHANGED << provSent, provContracted,
                                         provInQ, provRcvd, ackdOffer,
                                         custContracted, custSent,
                                         custRcvd, usedId >>

(***************************************************************************************)
(* Definition of the SendQuote action.
   The first action sends a Quote message without correlation to a received
   message. That is, the correlation identifier is null. The second action sends a
   Quote in response to a QuoteRequest message already received. In this case the 
   correlation identifier references the message received.                             *)
(***************************************************************************************)

SendQuote1         == LET id == NewId
                      IN /\ p2c!Send( [ messageType |-> "Quote",
                                        messageId |-> id,
                                        correlationId |-> NullId ] )
                         /\ usedId' = usedId \cup { id }
                         /\ UNCHANGED << custSent, custRcvd, custContracted,
                                         ackdOffer, provRcvd, provInQ,
                                         provContracted >>

SendQuote2         == \E message \in BagToSet( provInQ ) \intersect QuoteRequestMessage :
                        /\ c2p!Receive( message )
                        /\ LET id == NewId
                           IN /\ p2c!Send( [ messageType |-> "Quote",
                                             messageId |-> id,
                                             correlationId |-> message.messageId ] )
                              /\ usedId' = usedId \cup { id }
                              /\ UNCHANGED << custSent, custRcvd, custContracted,
                                              ackdOffer, provContracted >>

(***************************************************************************************)
(* The full SendQuote action is composed of the two specifications above. The action is
   only enabled if the provider is not contracted.                                     *)
(***************************************************************************************)

SendQuote          == /\ \neg provContracted
                      /\ ( SendQuote1 \/ SendQuote2 )

(***************************************************************************************)
(* Definition of the SendOfferAck action.
   The action checks for an offer in the inbound network channel. If an offer is
   present, we receive the offer. We then attempt to find the offer acknowledgement
   with the same correlation identifier as the message identifier of the offer. If
   an acknowledgement exists then we resend it. If no acknowledgement exists we send a
   new acknowledgement using the AckOffer action (the AckOffer action creates and
   sends a new offer acknowledgement, remembering to add its message identifier to
   the set of used identifiers used so that it cannot be reused). The action then
   checks to see what state the provider is in. If the provider is "not contracted" the
   offer is added to the set of offers waiting to be processed,  otherwise the original
   accept message that was used to form the contract is resent.                        *)
(***************************************************************************************)

ProcessOffer( offer ) ==
                      IF provContracted
                      THEN ResendAccept
                      ELSE ackdOffer' = ackdOffer \cup { offer }

AckOffer( offer )  == LET id == NewId
                      IN /\ p2c!Send( [ messageType |-> "OfferAck",
                                        messageId |-> id,
                                        correlationId |-> offer.messageId ] )
                         /\ usedId' = usedId \cup { id }

SendOfferAck       == /\ \E offer \in BagToSet( provInQ ) \intersect OfferMessage :
                         /\ c2p!Receive( offer )
                         /\ LET offerAck == { msg \in BagToSet( provSent ) \intersect
                                OfferAckMessage : offer.messageId = msg.correlationId }
                            IN /\ IF offerAck = {}
                                  THEN /\ AckOffer( offer ) 
                                       /\ ProcessOffer( offer )
                                       /\ UNCHANGED << provContracted, custContracted,
                                                       custSent, custRcvd >>
                                  ELSE /\ p2c!Send( offerAck )
                                       /\ ProcessOffer( offer )

(***************************************************************************************)
(* Definition of the SendAccept action.
   The SendAccept action first checks to see if there is an offer in the set of offers
   acknowledged but not processed. If an offer exists, we remove the offer from the
   set of ackd offers and we attempt to resend the reject message initially sent
   for this offer. If ResendReject returns TRUE (i.e. a reject existed and was resent)
   we return, else we attempt to resend the revoke accept for this offer. If
   ResendRevokeRequest returns TRUE (i.e. a revoke accept existed and was resent)
   we return, otherwise we accept the offer using the AcceptOffer action.              *)
(***************************************************************************************)

AcceptOffer( offer ) ==
                     LET id == NewId
                     IN /\ p2c!Send( [ messageType |-> "Accept",
                                       messageId |-> id,
                                       correlationId |-> offer.messageId ] )
                        /\ usedId' = usedId \cup { id }
                        /\ provContracted' = TRUE
                        /\ UNCHANGED << provInQ, provRcvd, 
                                        custContracted, custSent,
                                        custRcvd >>

SendAccept         == \E offer \in ackdOffer :
                        /\ ackdOffer' = ackdOffer \ { offer }
                        /\ IF AlreadySent( offer, RejectMessage )
                           THEN ResendReject( offer )
                           ELSE /\ IF AlreadySent( offer, RevokeAcceptMessage )
                                   THEN /\ ResendRevokeAccept( offer )
                                   ELSE /\ AcceptOffer( offer )
                                        /\ ackdOffer' = {}

(***************************************************************************************)
(* Definition of the SendReject action.
   The SendReject action first checks to see if there is an offer in the set of offers
   acknowledged but not processed. If an offer exists, we remove the offer from the
   set of ackd offers and we attempt to resend the reject message initially sent
   for this offer. If ResendReject returns TRUE (i.e. a reject existed and was resent)
   we return, else we attempt to resend the revoke accept for this offer. If 
   ResendRevokeRequest returns TRUE (i.e. a revoke accept existed and was resent)
   we return, else we reject the offer using the RejectOffer action.                   *)
(***************************************************************************************)

RejectOffer( offer ) ==
                     LET id == NewId
                     IN /\ p2c!Send( [ messageType |-> "Reject",
                                       messageId |-> id,
                                       correlationId |-> offer.messageId ] )
                        /\ usedId' = usedId \cup { id }
                        /\ UNCHANGED << provContracted, provInQ,
                                        provRcvd, custContracted,
                                        custSent, custRcvd >>

SendReject         == \E offer \in ackdOffer :
                        /\ ackdOffer' = ackdOffer \ { offer }
                        /\ IF AlreadySent( offer, RejectMessage )
                           THEN ResendReject( offer )
                           ELSE /\ IF AlreadySent( offer, RevokeAcceptMessage )
                                   THEN ResendRevokeAccept( offer )
                                   ELSE RejectOffer( offer )

(***************************************************************************************)
(* Definition of the SendRevokeAccept action.                                          *)
(***************************************************************************************)

RevokeOffer( offer ) ==
                      LET id == NewId
                      IN /\ p2c!Send( [ messageType |-> "RevokeAccept",
                                        messageId |-> id,
                                        correlationId |-> offer.messageId ] )
                         /\ usedId' = usedId \cup { id }
                         /\ UNCHANGED << provContracted, custContracted,
                                         custSent, custRcvd,
                                         ackdOffer >>

SendRevokeAccept   == \E revokeRequest \in BagToSet( provInQ ) \intersect
                           RevokeRequestMessage :
                        /\ LET match == { msg \in provRcvd \intersect OfferMessage :
                                 msg.messageId = revokeRequest.correlationId }
                           IN /\ match # {} \* Have received the offer the customer wants to revoke
                              /\ c2p!Receive( revokeRequest )
                              /\ LET offer == CHOOSE msg \in match : msg.messageType = "Offer"
                                 IN /\ IF AlreadySent( offer, RejectMessage )
                                       THEN ResendReject( offer )
                                       ELSE /\ IF AlreadySent( offer, RevokeAcceptMessage )
                                               THEN ResendRevokeAccept( offer)
                                               ELSE RevokeOffer( offer )

(***************************************************************************************)
(* Definition of the CustMessageWithNoAction.
   In some circumstances when a provider receives a customer message they may wish not
   to take any further action. For example, when a provider receives a quote request
   message from the customer they are not obliged to respond to it. This action allows
   this case by simply receiving the message and taking no further action.             *)
(***************************************************************************************)

CustMessageWithNoAction == 
                      \E message \in BagToSet( provInQ ) \intersect 
                            QuoteRequestMessage :
                        /\ c2p!Receive( message )
                        /\ UNCHANGED << provContracted, provSent,
                                        custInQ, custRcvd,
                                        ackdOffer, custContracted,
                                        usedId, custSent >>

-----------------------------------------------------------------------------------------
(***************************************************************************************)
(* CUSTOMER SERVICE SPECIFICATION.                                                     *)
(***************************************************************************************)

(***************************************************************************************)
(* Definition of the SendQuoteRequest action.
   The first action sends a QuoteRequest message without correlation to a received
   message. That is, the correlation identifier is null. The second action sends a
   QuoteRequest in response to a message waiting on the network. In this case the
   correlation identifier references that message.                                     *)
(***************************************************************************************)

SendQuoteRequest1  == LET id == NewId
                      IN /\ c2p!Send( [ messageType |-> "QuoteRequest",
                                        messageId |-> id,
                                        correlationId |-> NullId ] )
                         /\ usedId' = usedId \cup { id }
                         /\ UNCHANGED << ackdOffer, provSent,
                                         custInQ, provRcvd,
                                         custRcvd, custContracted,
                                         provContracted >>

SendQuoteRequest2 == \E message \in BagToSet( custInQ ) \intersect
                           UNION{ QuoteMessage, RejectMessage } :
                        /\ p2c!Receive( message )
                        /\ LET id == NewId
                           IN /\ c2p!Send( [ messageType |-> "QuoteRequest",
                                             messageId |-> id,
                                             correlationId |-> message.messageId ] )
                              /\ usedId' = usedId \cup { id }
                              /\ UNCHANGED << ackdOffer, provSent,
                                              provRcvd, custContracted,
                                              provContracted >>

(***************************************************************************************)
(* The full SendQuoteRequest action is composed of the two specifications above. The
   action is only enabled if the customer is not contracted.                           *)
(***************************************************************************************)

SendQuoteRequest   == /\ \neg custContracted
                      /\ ( SendQuoteRequest1 \/ SendQuoteRequest2 )

(***************************************************************************************)
(* Definition of the SendOffer action.
   The first action sends an Offer message without correlation to a received message.
   That is, the correlation identifier is null. The second action sends an Offer
   message in response to a received Quote or Reject message. In this case the
   correlation identifier references that message.                                     *)
(***************************************************************************************)

SendOffer1         == LET id == NewId
                      IN /\ c2p!Send( [ messageType |-> "Offer",
                                        messageId |-> id,
                                        correlationId |-> NullId ] )
                         /\ usedId' = usedId \cup { id }
                         /\ UNCHANGED << ackdOffer, provSent,
                                         custInQ, provRcvd,
                                         custRcvd, custContracted,
                                         provContracted >>

SendOffer2         == \E message \in BagToSet( custInQ ) \intersect 
                           UNION { QuoteMessage, RejectMessage } :
                        /\ p2c!Receive( message )
                        /\ LET id == NewId
                           IN /\ c2p!Send( [ messageType |-> "Offer",
                                             messageId |-> id,
                                             correlationId |-> message.messageId ] )
                              /\ usedId' = usedId \cup { id }
                              /\ UNCHANGED << ackdOffer, provSent,
                                              provRcvd, custContracted, 
                                              provContracted >>

(***************************************************************************************)
(* The full SendOffer action is composed of the two specifications above. The action
   is only enabled if the customer is not contracted.                                  *)
(***************************************************************************************)

SendOffer          == /\ \neg custContracted 
                      /\ ( SendOffer1 \/ SendOffer2 )

(***************************************************************************************)
(* Definition of the SendRevokeRequest action.
   This action is only enabled if the customer is not contracted. If this is the case,
   for an offer in the set of sent offers we check to see if the offer is either
   revoked or rejected. If it is not, we use its message identifier as the
   correlation identifier of a new RevokeRequest message.                              *)
(***************************************************************************************)

NotRejectedOffer( offer ) == 
                      /\ { msg \in custRcvd \intersect RejectMessage :
                           msg.correlationId = offer.messageId } = {}

NotRevokedOffer( offer ) ==
                      /\ { msg \in custRcvd \intersect RevokeAcceptMessage :
                           msg.correlationId = offer.messageId } = {}

RequestRevoke( offer ) ==
                      LET match == { msg \in BagToSet( custSent ) \intersect RevokeRequestMessage :
                            msg.correlationId = offer.messageId }
                      IN /\ IF match # {} \* Found an already sent revoke request
                            THEN /\ LET rr == CHOOSE msg \in match : msg.messageType = "RevokeRequest"
                                 IN /\ c2p!Send( rr )
                                    /\ UNCHANGED << provContracted, provSent,
                                                 provRcvd, ackdOffer,
                                                 custContracted, custInQ,
                                                 custRcvd, usedId >>
                            ELSE LET id == NewId \* Send new revoke request
                                 IN /\ c2p!Send( [ messageType |-> "RevokeRequest",
                                                  messageId |-> id,
                                                  correlationId |-> offer.messageId ] )
                                    /\ usedId' = usedId \cup { id }
                                    /\ UNCHANGED << provContracted, provSent,
                                                    provRcvd, ackdOffer,
                                                    custContracted, custInQ,
                                                    custRcvd >>

SendRevokeRequest  == /\ \neg custContracted
                      /\ \E offer \in BagToSet( custSent ) \intersect OfferMessage:
                        /\ NotRejectedOffer( offer )
                        /\ NotRevokedOffer( offer )
                        /\ RequestRevoke( offer )

(***************************************************************************************)
(* Definition of the ReceiveAccept action.
   If an accept message is present in the customers inbound queue of unprocessed
   messages, we receive the message. As a result, the customer is contracted.          *)
(***************************************************************************************)

ReceiveAccept      == \E accept \in BagToSet( custInQ ) \intersect AcceptMessage :
                        /\ p2c!Receive( accept )
                        /\ custContracted' = TRUE
                        /\ UNCHANGED << provContracted, provSent,
                                        provInQ, provRcvd,
                                        ackdOffer, custSent,
                                        usedId >>

(***************************************************************************************)
(* Definition of the ProvMessageWithNoAction.
   In some circumstances a customer may receives a provider message and not wish to
   take any further action. For example, when a customer receives a quote they don't
   like they may take the choice not to pursue the negotiation further. This action
   allows this case by receiving the message and taking no further action.             *)
(***************************************************************************************)

ProvMessageWithNoAction == 
                      \E message \in BagToSet( custInQ ) \intersect
                           UNION { QuoteMessage, OfferAckMessage,
                                   RejectMessage, RevokeAcceptMessage } :
                        /\ p2c!Receive( message )
                        /\ UNCHANGED << provContracted, provSent,
                                        provInQ, provRcvd,
                                        ackdOffer, custContracted,
                                        custSent, usedId >>

-----------------------------------------------------------------------------------------

Init               == /\ c2p!Init
                      /\ p2c!Init
                      /\ usedId = {}              (* No message ids have been used.    *)
                      /\ ackdOffer = {}           (* No offers waiting to be processed.*)
                      /\ provContracted = FALSE   (* Both parties are not contracted,  *)
                      /\ custContracted = FALSE   (* i.e., no agreement has been made. *)

ProvAction         == \/ SendQuote                (* The allowed provider actions.     *)
                      \/ SendOfferAck
                      \/ SendAccept
                      \/ SendReject
                      \/ SendRevokeAccept
                      \/ CustMessageWithNoAction

CustAction         == \/ SendQuoteRequest         (* The allowed customer actions.     *)
                      \/ SendOffer
                      \/ ReceiveAccept
                      \/ SendRevokeRequest
                      \/ ProvMessageWithNoAction

Next               == \/ ProvAction               (* The next state is found through   *)
                      \/ CustAction               (* taking either a provider or       *)
                                                  (* customer action                   *)

-----------------------------------------------------------------------------------------

TypeInvariant      == /\ IsABag( provSent )
                      /\ BagToSet( provSent ) \subseteq ProvMessage
                      /\ IsABag( provInQ )
                      /\ BagToSet( provInQ ) \subseteq CustMessage
                      /\ IsFiniteSet( provRcvd )
                      /\ provRcvd \subseteq CustMessage
                      /\ IsABag( custSent )
                      /\ BagToSet( custSent ) \subseteq CustMessage
                      /\ IsABag( custInQ )
                      /\ BagToSet( custInQ ) \subseteq ProvMessage
                      /\ IsFiniteSet( custRcvd )
                      /\ custRcvd \subseteq ProvMessage
                      /\ IsFiniteSet( ProvMessage )
                      /\ IsFiniteSet( CustMessage )
                      /\ provContracted \in BOOLEAN
                      /\ custContracted \in BOOLEAN
                      /\ \A msg \in provRcvd : msg \in CustMessage
                      /\ \A msg \in custRcvd : msg \in ProvMessage
                      /\ \A msg \in BagToSet( provSent ) : msg \in ProvMessage
                      /\ \A msg \in BagToSet( custSent ) : msg \in CustMessage
                      /\ \A msg \in BagToSet( provInQ ) : msg \in CustMessage
                      /\ \A msg \in BagToSet( custInQ ) : msg \in ProvMessage

-----------------------------------------------------------------------------------------

MsgConstraint      == BagCardinality( custSent ) + BagCardinality( provSent ) < Cardinality ( MessageId )

Liveness           == /\ c2p!Liveness
                      /\ p2c!Liveness

Safety             == /\ c2p!Safety
                      /\ p2c!Safety
                      /\ Cardinality( BagToSet( provSent ) \intersect AcceptMessage ) \in { 0, 1 }

-----------------------------------------------------------------------------------------
(* Tuples of variables.                                                                *)
provVars           == << provContracted, provSent, provInQ, provRcvd, ackdOffer >>
custVars           == << custContracted, custSent, custInQ, custRcvd >>
vars               == << provVars, custVars, usedId >>

-----------------------------------------------------------------------------------------

NewSpec            == /\ Init
                      /\ [][Next]_<< vars >>

THEOREM NewSpec    => []TypeInvariant
THEOREM NewSpec    => Liveness /\ Safety
=========================================================================================