--------------------------------------------------------
--  DDL for Package WF_QUEUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_QUEUE" AUTHID CURRENT_USER as
/* $Header: wfques.pls 120.2.12010000.2 2009/08/16 14:14:51 skandepu ship $ */
/*#
 * Provides APIs that can be called by an application program or a
 * workflow function in the runtime phase to handle workflow Advanced
 * Queue processing. Although these APIs will continue to be supported
 * for backward compatibility, customers using Oracle Workflow Release
 * 2.6 and higher should use the Business Event System rather than the
 * queue APIs to integrate with Oracle Advanced Queuing.
 * @rep:scope public
 * @rep:product OWF
 * @rep:displayname Workflow Queues
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY WF_ENGINE
 * @rep:ihelp FND/@que_api See the related online help
 */

-- define the queue variables
-- for Apps installs this includes the schema name (because queue is in
-- different schema to the package).
-- Standalone does not need the schema defined because everything is in
-- same schema.
deferred_queue_name      varchar2(60);
inbound_queue_name       varchar2(60);
outbound_queue_name      varchar2(60);
-- define the account name. This only has a value for Apps installs.
account_name             varchar2(320);
name_init                boolean:= FALSE;

-- ==================================================
-- Bug 4005674
-- define variables to calculate the number of occurrences from the
-- history table since the background engine started
-- ==================================================
g_defer_occurrence         number;
g_add_delay_seconds        number;
g_max_delay_seconds        number;

-- ==================================================
-- declare types for Developer APIs for Inbound Queue
-- Note: we may change these in the future. For example
-- we may convert to XHTML so dont make types PUBLIC
-- ==================================================
type TypeArrayTyp    is table of varchar2(8)    index by binary_integer;
type StckItemkey     is table of varchar2(200)  index by binary_integer;
type StckActidTyp    is table of pls_integer    index by binary_integer;
type StckResultTyp   is table of varchar2(30)   index by binary_integer;
type StckAttrListTyp is table of varchar2(4000) index by binary_integer;
type StckCtrTyp      is table of pls_integer    index by binary_integer;


stck_itemtype   TypeArrayTyp;
stck_itemkey    StckItemKey;
stck_actid      StckActidTyp;
stck_result     StckResultTyp;
stck_attrlist   StckAttrListTyp;

stck_ctr      pls_integer := 0;

/*===========================================================================

  PL*SQL TABLE NAME:    wf_queue_protocol_rec_type

  DESCRIPTION:  Stores a list of queue types with an index into the
                  queue name list

============================================================================*/

TYPE wf_queue_protocol_rec_type IS RECORD
(
   protocol           VARCHAR2(30),  -- Protocol - SMTP,
   inbound_outbound   VARCHAR2(10),  -- Is this an outbound or inbound queue
   queue_count        NUMBER         -- How many queues are defined for the protocol
);

TYPE wf_queue_protocol_tbl_type IS TABLE OF
    wf_queue.wf_queue_protocol_rec_type  INDEX BY BINARY_INTEGER;

-- List of indexes for the queue
queue_names_index wf_queue_protocol_tbl_type;

-- ==================================================================
-- PUBLIC APIs
-- ==================================================================
/*#
 * Enqueues the result from an outbound event onto the inbound queue.
 * Oracle Workflow marks the external function activity as complete with the
 * specified result when it processes the inbound queue.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param actid Activity ID
 * @param result Result
 * @param attrlist Item Attribute List
 * @param correlation Correlation ID
 * @param error_stack Error Stack
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Enqueue Inbound Message
 * @rep:compatibility S
 * @rep:ihelp FND/@que_api#a_eqib See the related online help
 */
procedure EnqueueInbound(
                        itemtype        in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        result          in varchar2 default null,
                        attrlist        in varchar2 default null,
                        correlation     in varchar2 default null,
                        error_stack      in varchar2 default null);

/*#
 * Dequeues a message from the outbound queue for some agent to consume.
 * @param dequeuemode Dequeue Mode
 * @param navigation Message Navigation
 * @param correlation Correlation ID
 * @param itemtype Item Type
 * @param payload Payload
 * @param message_handle Message Handle
 * @param timeout Dequeue Timeout
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Dequeue Outbound Message
 * @rep:compatibility S
 * @rep:ihelp FND/@que_api#a_dqob See the related online help
 */
procedure DequeueOutbound(
                        dequeuemode     in  number,
                        navigation      in  number default 1,
                        correlation     in  varchar2 default null,
                        itemtype        in  varchar2 default null,
                        payload         out nocopy system.wf_payload_t,
                        message_handle  in out nocopy raw,
                        timeout         out nocopy boolean);

/*#
 * Dequeues the full event details for a given message from the outbound
 * queue. This API is similar to DequeueOutbound except it does not
 * reference the payload type. Instead, it outputs the item key, activity
 * ID, function name, and parameter list, which are part of the payload.
 * @param dequeuemode Dequeue Mode
 * @param navigation Message Navigation
 * @param correlation Correlation ID
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param actid Activity ID
 * @param function_name Function Name
 * @param param_list Parameter List
 * @param message_handle Message Handle
 * @param timeout Dequeue Timeout
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Dequeue Event Detail
 * @rep:compatibility S
 * @rep:ihelp FND/@que_api#a_dqed See the related online help
 */
procedure DequeueEventDetail(
                        dequeuemode     in  number,
                        navigation      in  number default 1,
                        correlation     in  varchar2 default null,
                        itemtype        in  out nocopy varchar2,
                        itemkey         out nocopy varchar2,
                        actid           out nocopy number,
                        function_name   out nocopy varchar2,
                        param_list      out nocopy varchar2,
                        message_handle  in out nocopy raw,
                        timeout         out nocopy boolean);

/*#
 * Removes an event from a specified queue without further processing.
 * @param queuename Queue Name to purge
 * @param message_handle Message Handle
 * @param multiconsumer For Internal Use Only
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Purge Event from Queue
 * @rep:compatibility S
 * @rep:ihelp FND/@que_api#a_pe See the related online help
 */
procedure PurgeEvent(queuename in varchar2,
                     message_handle in raw,
                     multiconsumer in boolean default FALSE);

/*#
 * Removes all events belonging to a specific item type from a specified
 * queue without further processing.
 * @param queuename Queue Name to purge
 * @param itemtype Item Type
 * @param correlation Correlation ID
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Purge Events based on Item Type
 * @rep:compatibility S
 * @rep:ihelp FND/@que_api#a_pit See the related online help
 */
procedure PurgeItemtype(queuename    in varchar2,
                        itemtype     in varchar2  default null,
                        correlation  in varchar2 default null);

/*#
 * Reads every message off the inbound queue and records each message
 * as a completed event. The result of the completed event and the list of
 * item attributes that are updated as a consequence of the completed
 * event are specified by each message in the inbound queue.
 * @param itemtype Item Type
 * @param correlation Correlation ID
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process Inbound Queue
 * @rep:compatibility S
 * @rep:ihelp FND/@que_api#a_pibq See the related online help
 */
procedure ProcessInboundQueue (itemtype     in varchar2 default null,
                               correlation  in varchar2 default null);

/*#
 * Returns a message handle ID for a specified message.
 * @param queuename Queue Name
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param actid Activity ID
 * @param correlation Correlation ID
 * @param multiconsumer For Internal Use Only
 * @return Message Handle
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Message Handle
 * @rep:compatibility S
 * @rep:ihelp FND/@que_api#a_gmh See the related online help
 */
function  GetMessageHandle(queuename in varchar2,
                           itemtype  in varchar2,
                           itemkey   in varchar2,
                           actid     in number,
                           correlation  in varchar2 default null,
                           multiconsumer in boolean default FALSE) return raw;

/*#
 * Dequeues all messages from an exception queue and places the
 * messages on the standard Business Event System WF_ERROR queue
 * with the error message 'Message Expired'. When the messages are
 * dequeued from WF_ERROR, a predefined subscription is triggered that
 * launches the Default Event Error process.
 * @param queuename Queue Name
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Dequeue from Exception Queue
 * @rep:compatibility S
 * @rep:ihelp FND/@que_api#a_dqexc See the related online help
 */
procedure DequeueException (queuename in varchar2);

procedure AddSubscriber(queuename in varchar2,
                        name      in varchar2);
--Bug 2307428
--Enable inbound and deferred queues.
--To be called by wf_engine.Background
  procedure EnableBackgroundQueues;

-- ==================================================================
-- PRIVATE APIs
-- ==================================================================

procedure Enqueue_Event(queuename       in varchar2,
                        itemtype        in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        correlation     in varchar2 default null,
                        delay           in number   default 0,
                        funcname        in varchar2 default null,
                        paramlist       in varchar2 default null,
                        result          in varchar2 default null,
                        message_handle  in out nocopy raw,
                        priority        in number default null);

procedure Dequeue_Event(queuename       in  varchar2,
                        dequeuemode     in  number,
                        navigation      in  number default 1,
                        correlation     in  varchar2 default null,
                        payload         out nocopy system.wf_payload_t,
                        message_handle  in out nocopy raw,
                        timeout         out nocopy boolean,
                        multiconsumer   in  boolean default FALSE);

procedure ProcessDeferredQueue (itemtype     in varchar2 default null,
                                minthreshold in number default null,
                                maxthreshold in number default null,
                                correlation  in varchar2 default null);


procedure ProcessDeferredEvent(itemtype in varchar2,
                         itemkey        in varchar2,
                         actid          in number,
                         message_handle in raw,
                         minthreshold   in number,
                         maxthreshold   in number);

function Get_param_list(itemtype        in varchar2,
                         itemkey        in varchar2,
                         actid          in number) return varchar2 ;

-- ==================================================================
-- QUEUE set up
-- replace this with simple synonyms when AQ supports them
-- for now build a string as schema_name.queue_name
-- ==================================================================
procedure set_queue_names;

/*#
 * Returns the name of the queue and schema used by the background engine
 * for deferred processing.
 * @return Name and Schema of Deferred Queue
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Deferred Queue Information
 * @rep:compatibility S
 * @rep:ihelp FND/@que_api#a_dq See the related online help
 */
function DeferredQueue return varchar2; --(PUBLIC)

/*#
 * Returns the name of the inbound queue and schema. The inbound queue
 * contains messages for the Workflow Engine to consume.
 * @return Name and Schema of Inbound Queue
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Inbound Queue Information
 * @rep:compatibility S
 * @rep:ihelp FND/@que_api#a_iq See the related online help
 */
function InboundQueue  return varchar2; --(PUBLIC)

/*#
 * Returns the name of the outbound queue and schema. The outbound queue
 * contains messages for external agents to consume.
 * @return Name and Schema of Outbound Queue
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Outbound Queue Information
 * @rep:compatibility S
 * @rep:ihelp FND/@que_api#a_oq See the related online help
 */
function OutboundQueue return varchar2; --(PUBLIC)

--===================================================================
--
-- Declare all developer APIs for manipulating Inbound Queue
--
--===================================================================
--
-- ClearMsgStack
-- clears the stack
--
/*#
 * Clears the internal stack.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Clear Internal Stack
 * @rep:compatibility S
 * @rep:ihelp FND/@que_api#a_cms See the related online help
 */
procedure ClearMsgStack;

--
-- CreateMsg (public)
-- creates a new message on the stack if it doesnt already exist
--
/*#
 * Creates a new message in the internal stack if it doesn't already exist.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param actid Activity ID
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create New Message
 * @rep:compatibility S
 * @rep:ihelp FND/@que_api#a_cmsg See the related online help
 */
procedure CreateMsg(
  itemtype in varchar2,
  itemkey in varchar2,
  actid in number);

--
-- WriteMsg (public)
-- writes a message from the stack to the Inbound Queue
--
/*#
 * Writes a message from the internal stack to the inbound queue.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param actid Activity ID
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Write Message
 * @rep:compatibility S
 * @rep:ihelp FND/@que_api#a_wm See the related online help
 */
procedure WriteMsg(
  itemtype in varchar2,
  itemkey in varchar2,
  actid in number);

--
-- SetMsgAttr (public)
-- appends a message attribute
--
/*#
 * Appends an item attribute to the message in the internal stack.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param actid Activity ID
 * @param attrName Attribute Name
 * @param attrValue Attribute Value
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Message Attribute
 * @rep:compatibility S
 * @rep:ihelp FND/@que_api#a_sma See the related online help
 */
procedure SetMsgAttr(
  itemtype in varchar2,
  itemkey in varchar2,
  actid in number,
  attrName in varchar2,
  attrValue in varchar2);

--
-- SetMsgResult (public)
-- sets the message result
--
/*#
 * Sets a result to the message written in the internal stack.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param actid Activity ID
 * @param result Result
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Message Result
 * @rep:compatibility S
 * @rep:ihelp FND/@que_api#a_smr See the related online help
 */
procedure SetMsgResult(
  itemtype in varchar2,
  itemkey in varchar2,
  actid in number,
  result in varchar2);

--
-- AddNewMsg (Private)
-- adds a msg to the stack
procedure AddNewMsg(
  itemtype in varchar2,
  itemkey in varchar2,
  actid in number);

--
-- SearchMsgStack (private)
-- Sequential search of message stack.
function  SearchMsgStack(
  itemtype in varchar2,
  itemkey in varchar2,
  actid in number) RETURN number;

--
-- Generic_Queue_Display
--   Produce list of generic_queues
--
procedure Generic_Queue_Display;

--
-- Generic_Queue_View_Detail
--   Produce list of generic_queues
--
procedure Generic_Queue_View_Detail (
p_protocol         IN VARCHAR2 DEFAULT NULL,
p_inbound_outbound IN VARCHAR2 DEFAULT NULL
);

--
-- Procedure:  get_hash_queue_name
--
-- Description: Load all queue definitions into memory.  The use a hashing algorithm
--              to return a queue name
--
procedure get_hash_queue_name
(p_protocol          in varchar2,
 p_inbound_outbound  in varchar2,
 p_queue_name        out nocopy varchar2);


--
-- Procedure:  Generic_Queue_Edit
--
-- Description: UI to Add a new queue definition or modify the properties of a queue
--
procedure Generic_Queue_Edit (
p_protocol         IN VARCHAR2   DEFAULT NULL,
p_inbound_outbound IN VARCHAR2 DEFAULT NULL
);

--
-- Procedure:  create_generic_queue
--
-- Description: Create the aq components and insert into the wf_queues table
--
procedure create_generic_queue
(p_protocol          IN VARCHAR2,
 p_inbound_outbound  IN VARCHAR2,
 p_description       IN VARCHAR2,
 p_queue_count       IN NUMBER);


--
-- Procedure:  delete_generic_queue
--
-- delete a generic queue with the object type of WF_MESSAGE_PAYLOAD_T
--
procedure delete_generic_queue
(p_protocol          IN VARCHAR2,
 p_inbound_outbound  IN VARCHAR2);

--
-- Procedure:  generic_queue_update
--
-- Execute all the dml to either create the generic queues or modify them
-- in some way.
--
procedure Generic_Queue_Update (
p_protocol           IN VARCHAR2   DEFAULT NULL,
p_inbound_outbound   IN VARCHAR2   DEFAULT NULL,
p_description        IN VARCHAR2   DEFAULT NULL,
p_queue_count        IN VARCHAR2   DEFAULT NULL,
p_original_protocol  IN VARCHAR2   DEFAULT NULL,
p_original_inbound   IN VARCHAR2   DEFAULT NULL);

--
-- Procedure:  generic_queue_display_contents
--
-- Display the contents of a message in a generic queue
--
procedure generic_queue_display_contents
(p_protocol          IN VARCHAR2 DEFAULT NULL,
 p_inbound_outbound  IN VARCHAR2 DEFAULT NULL,
 p_queue_number      IN NUMBER   DEFAULT NULL,
 p_message_number    IN NUMBER   DEFAULT 1);

--
-- Function: enable_exception_queue
--
-- Enable the exception queue for the queue table for dequing
-- Returns the name of the exception queue for the given queue name
--
function enable_Exception_Queue(p_queue_name in varchar2) return varchar2;

--
-- getCntMsgSt
--
-- For all agents that the business event system knows about on the
-- local system, returns the number of messages in different states.
-- In addition, we will return the number of messages on the error
-- agent.
--
/*#
 * Returns the number of messages in different statuses for the specified
 * agent, or for all agents on the local system if no agent is specified.
 * @param p_agent The agent name.
 * @param p_ready The number of messages with the status READY.
 * @param p_wait The number of messages with the status WAIT.
 * @param p_processed The number of messages with the status PROCESSED.
 * @param p_expired The number of messages with the status EXPIRED.
 * @param p_undeliverable The number of messages with the status UNDELIVERED.
 * @param p_error The number of messages on the standard Business Event System error agents.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Message Status Counts
 * @rep:compatibility S
 */
procedure getCntMsgSt
(p_agent        IN VARCHAR2 DEFAULT '%',
 p_ready        OUT NOCOPY NUMBER,
 p_wait         OUT NOCOPY NUMBER,
 p_processed    OUT NOCOPY NUMBER,
 p_expired      OUT NOCOPY NUMBER,
 p_undeliverable OUT NOCOPY NUMBER,
 p_error        OUT NOCOPY NUMBER);

--
-- move_msgs_excep2normal (CONCURRENT PROGRAM API)
--
-- API to move messages from the exception queue to the normal queue
-- of the given agent. Handles wf_event_t and JMS_TEXT_MESSAGE payloads.
--
/*#
 * Moves messages from the exception queue associated with the specified
 * agent back to the agent's normal queue. This procedure helps enable
 * mass reprocessing in case of a large number of errors. The procedure
 * handles both queues whose payload type is WF_EVENT_T and queues whose
 * payload type is SYS.AQ$_JMS_TEXT_MESSAGE.
 * @param errbuf The error buffer.
 * @param retcode The return code.
 * @param p_agent_name The agent name.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Move Messages from Exception to Normal Queue
 * @rep:compatibility S
 */
 procedure move_msgs_excep2normal
(errbuf       OUT NOCOPY VARCHAR2,
 retcode      OUT NOCOPY VARCHAR2,
 p_agent_name IN  VARCHAR2);

--
-- Overloaded Procedure 1 : Definition without the AGE parameter
--
-- clean_evt
--   Procedure to purge the messages in the READY state of a Queue
--   of WF_EVENT_T payload type. Supports correlation id based purge.
--
/*#
 * Purges event messages with the status READY from the queue associated with
 * the specified agent. The queue must use the WF_EVENT_T datatype as its
 * payload type. You can optionally specify a correlation ID to purge
 * only messages marked with that ID.
 * @param p_agent_name The agent name.
 * @param p_correlation The correlation ID for the messages to purge.
 * @param p_commit_frequency The number of messages to purge before committing.
 * @param p_msg_count The number of messages that were purged.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Clean Events from Queue
 * @rep:compatibility S
 */
procedure clean_evt
(p_agent_name       IN  VARCHAR2,
 p_correlation      IN  VARCHAR2 DEFAULT NULL,
 p_commit_frequency IN  NUMBER   DEFAULT 500,
 p_msg_count        OUT NOCOPY NUMBER);

--
-- Overloaded Procedure 2 : Definition with the AGE parameter
--
-- clean_evt
--   Procedure to purge the messages in the READY state of a Queue
--   of WF_EVENT_T payload type. Supports time-based selective purge
--   with the given correlation id.
--
/*#
 * Purges event messages with the status READY and of the specified age
 * from the queue associated with the specified agent. The queue must
 * use the WF_EVENT_T datatype as its payload type. You can optionally
 * specify a correlation ID to purge only messages marked with that ID.
 * @param p_agent_name The agent name.
 * @param p_correlation The correlation ID for the messages to purge.
 * @param p_commit_frequency The number of messages to purge before committing.
 * @param p_msg_count The number of messages that were purged.
 * @param p_age The age of the messages to purge.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Clean Events from Queue by Age
 * @rep:compatibility S
 */
procedure clean_evt
(p_agent_name       IN  VARCHAR2,
 p_correlation      IN  VARCHAR2 DEFAULT NULL,
 p_commit_frequency IN  NUMBER   DEFAULT 500,
 p_msg_count        OUT NOCOPY NUMBER,
 p_age              IN  NUMBER);

end;

/

  GRANT EXECUTE ON "APPS"."WF_QUEUE" TO "EM_OAM_MONITOR_ROLE";
