--------------------------------------------------------
--  DDL for Package WF_EVENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_EVENT" AUTHID CURRENT_USER as
/* $Header: WFEVENTS.pls 120.3.12010000.2 2009/03/20 19:47:37 alepe ship $ */
/*#
 * Provides APIs to communicate with the Business Event System and manage
 * events.
 * @rep:scope public
 * @rep:product OWF
 * @rep:displayname Workflow Business Event System
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY WF_EVENT
 * @rep:ihelp FND/@evtapis See the related online help
 */
------------------------------------------------------------------------------
navigation  binary_integer := dbms_aq.first_message;

------------------------------------------------------------------------------
/*
** exception source indicator - used by dispatch and listen (NONE | WF | RULE)
*/
WF_EXCEPTION_SOURCE varchar2(10) := 'NONE';
------------------------------------------------------------------------------
/*
** **** PRIVATE VARIABLE - NOT FOR CUSTOMER USE ******
** phase maxthreshold - used by dispatch to determine which subscriptions to
**		     execute, only those with a phase < phase threshold
** **** PRIVATE VARIABLE - NOT FOR CUSTOMER USE ******
*/
PHASE_MAXTHRESHOLD number := 100;
------------------------------------------------------------------------------
/*
** **** PRIVATE VARIABLE - NOT FOR CUSTOMER USE ******
** phase minstart   - used by dispatch to determine which subscriptions to
**		   execute, only those with a phase >= phase threshold
** **** PRIVATE VARIABLE - NOT FOR CUSTOMER USE ******
*/
PHASE_MINTHRESHOLD number := 0;
------------------------------------------------------------------------------
/*
** **** PRIVATE VARIABLE - NOT FOR CUSTOMER USE ******
** account name  - current schema
**
** **** PRIVATE VARIABLE - NOT FOR CUSTOMER USE ******
*/
ACCOUNT_NAME  varchar2(320);
------------------------------------------------------------------------------
/*
** **** PRIVATE VARIABLE - NOT FOR CUSTOMER USE ******
** local_system_guid - the value of local system guid
** local_system_status - status of the local system
** local_system_name - status of the local system
** **** PRIVATE VARIABLE - NOT FOR CUSTOMER USE ******
*/
local_system_guid  raw(16);
local_system_status varchar2(10);
local_system_name  varchar2(30);


schema_name         varchar2(30);

------------------------------------------------------------------------------
/*
** **** PRIVATE VARIABLE - NOT FOR CUSTOMER USE ******
** evt_param_index - pl/sql table to hold hash values of event parameters.
** **** PRIVATE VARIABLE - NOT FOR CUSTOMER USE ******
*/

TYPE Event_Param_INDEX is table of varchar2(4000) index by binary_integer;
evt_param_index Event_Param_INDEX;

/*
** **** PRIVATE VARIABLE - NOT FOR CUSTOMER USE ******
** sub_param_index - pl/sql table to hold hash values of subscription parameters.
** **** PRIVATE VARIABLE - NOT FOR CUSTOMER USE ******
*/

TYPE Subscription_Param_INDEX is table of varchar2(4000) index by binary_integer;
sub_param_index Subscription_Param_INDEX;

------------------------------------------------------------------------------
/*
** **** PRIVATE VARIABLE - NOT FOR CUSTOMER USE ******
** g_correlation     - Current correlation id.
** g_queueType       - Current Queue Type.
** g_deq_condition   - Dequeue Condition (9i feature)
** g_dispatch_result - Result returned from dispatch_internal
** **** PRIVATE VARIABLE - NOT FOR CUSTOMER USE ******
*/

/*
** **** PUBLIC VARIABLE ******
** Max nested raise gives the number of recursive raises
** possible.
**
*/
NESTED_RAISE_COUNT number  := 0;
MAX_NESTED_RAISES  number  := 100;

g_correlation      varchar2(240);
g_queueType        varchar2(20);
g_deq_condition    varchar2(4000);
g_message_grouping varchar2(30);
g_msgid            raw(16); --<rwunderl:2699059>
g_local_system_guid raw(16); --<rwunderl:2792298>

/*#
 * Internally dispatch an event to one of the event's
 * subscription.
 * @param p_source_type The source of the evnet
 * @param p_rule_data   indicator if the event data should be generated
 * @param p_rule_func   the rule function of this subscription
 * @param p_sub_guid    GUID of this subscription
 * @param p_source_agent_guid the agent where event comes
 * @param p_phase       the phase of this subscription
 * @param p_priority    priority of this sub
 * @param p_event       Event to be dispatched.
 * @return The status of the subscription execution
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Test Event
 * @rep:compatibility S
 * @rep:ihelp FND/@evtapis#a_evtest See the related online help
 */
FUNCTION dispatch_internal(p_source_type        in      varchar2,
                           p_rule_data          in      varchar2,
                           p_rule_func          in      varchar2,
                           p_sub_guid           in      raw,
                           p_source_agent_guid  in      raw,
                           p_phase              in      number,
                           p_priority           in      number,
                           p_event              in out nocopy wf_event_t,
                           p_on_error           in      varchar2)
return varchar2;
------------------------------------------------------------------------------
/*
** test - Verifies the specified event is enabled.  Then, tests if there
**        is an enabled LOCAL subscription for this event, or an enabled
**        subscription for an enabled group that contains this event.
**
**        Returns the most costly data requirement for active subscriptions
**        on the event:
**          NONE     no subscription or no event           (best)
**          KEY      subscription requiring event key only
**          MESSAGE  subscription requiring event message  (worst)
*/
/*#
 * Tests whether the specified event is enabled and whether there are any
 * enabled subscriptions by the local system referencing the event, or
 * referencing an enabled event group that contains the event. Returns
 * NONE if no enabled local subscriptions reference the event, or the
 * event does not exist. Returns KEY if at least one enabled local
 * subscription references the event, but all such subscriptions require
 * only the event key. Returns MESSAGE if at least one enabled local
 * subscription to the event requires the complete event data.
 * @param p_event_name Event Name
 * @return Most Costly Data Requirement among Subscriptions
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Test Event
 * @rep:compatibility S
 * @rep:ihelp FND/@evtapis#a_evtest See the related online help
 */
FUNCTION test(p_event_name in varchar2) return varchar2;
------------------------------------------------------------------------------
/*
** send - send event message to agent
**
**    The event's FROM_AGENT specifies an output agent/queue upon which
**    the message should be placed.  The event's TO_AGENT_LIST specifies
**    the message recipients for propagation.
**
**    The message will be asynchronously delivered to the
**    TO_AGENT by AQ propagation.  If the FROM_AGENT is not specified,
**    the system will automatically enqueue the message to an output agent
**    that matches the recipient's queue type.
*/
/*#
 * Sends an event message from one agent to another. If the event message
 * contains both a From Agent and a To Agent, the message is placed on
 * the outbound queue of the From Agent and then asynchronously delivered
 * to the To Agent by AQ propagation, or whichever type of propagation is
 * implemented for the agents' protocol. If the event message contains a
 * To Agent but no specified From Agent, the message is sent from the
 * default outbound agent that matches the queue type of the To Agent. If
 * the event message contains a From Agent but no specified To Agent, the
 * event message is placed on the From Agent's queue without a specified
 * recipient.
 * @param p_event Event Message to Send
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Send Event
 * @rep:compatibility S
 * @rep:ihelp FND/@evtapis#a_evsend See the related online help
 */
PROCEDURE send(p_event in out nocopy wf_event_t);
------------------------------------------------------------------------------
/*#
 * Sets the Recipient_List when an event is sent from one agent to another
 * This method handles both Agent and Agent Group.
 * @param p_event Event to be sent
 * @param p_out_agent_name Source Agent Name
 * @param p_out_system_name Source System Name
 * @param x_message_properties the enqueue options with recipient list generated
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Send Event
 * @rep:compatibility S
 * @rep:ihelp FND/@evtapis#a_evsend See the related online help
 */
PROCEDURE Set_Recipient_List(p_event               in wf_event_t,
                             p_out_agent_name     in varchar2,
                             p_out_system_name    in varchar2,
                             x_message_properties in out nocopy dbms_aq.message_properties_t);
/*
** newAgent - Construct a wf_agent_t from a guid
*/
/*#
 * Creates a WF_AGENT_T structure for the specified agent and sets the agent's
 * system and name into the structure.
 * @param p_agent_guid Agent GUID
 * @return WF_AGENT_T structure containing Agent Information
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname New Agent
 * @rep:compatibility S
 * @rep:ihelp FND/@evtapis#a_evnewagt See the related online help
 */
FUNCTION newAgent(p_agent_guid in raw) return wf_agent_t;
------------------------------------------------------------------------------
/*
** dispatch - (internal) run event dispatcher for an event
**
**        Main subscription execution loop.  Finds all matching
**        subscriptions and executes their rules.
**
**        P_SOURCE_TYPE is one of 'LOCAL', 'EXTERNAL', or 'ERROR',
**        indicating the general class of the event.  This will be
**        matched against the corresonding column in the
**        subscriptions table when selecting subscriptions.
**
**        P_SOURCE_AGENT_GUID is NULL if local, otherwise is set to the
**        GUID of the agent that sent the event.
**
**        All matching subscriptions are then queried and executed.
**        Subscription execution is ordered by the PHASE attribute of the
**        subscriptions table.  Subscription execution involves
*/
/*#
 * Creates a WF_AGENT_T structure for the specified agent and sets the agent's
 * system and name into the structure.
 * @param p_source_type       LOCAL, EXTERNAL or ERROR
 * @param p_source_agent_guid where the event comes
 * @param p_event             event to be dispatched
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname New Agent
 * @rep:compatibility S
 * @rep:ihelp FND/@evtapis#a_evnewagt See the related online help
 */
PROCEDURE dispatch(p_source_type        in     varchar2,
                   p_source_agent_guid  in     raw,
                   p_event              in out nocopy wf_event_t);
------------------------------------------------------------------------------
/*
** raise - raise a local event to the event manager
**        -- Below Moved to Dispatcher --
**        Calls TEST to determine whether a MESSAGE type subscription
**        exists.  If a MESSAGE is required, and none is specified by
**        the caller, we generate one using the GENERATE_FUNCTION
**        identified for the event in the WF_EVENTS table.  If no
**        GENERATE_FUNCTION is found, we create a default message using
**        the event name and event key data.
**        -- Above moved to Dispatcher --
**
**        Event is passed to the dispatcher.
**
**        Note: If the event is not defined, no error will be raised.
*/
/*#
 * Raises a local event to the Event Manager. Creates a WF_EVENT_T structure
 * for this event instance and sets the specified event name, event key,
 * event data, parameter list, and send date into the structure. The event data
 * can be passed to the Event Manager within the call to the Raise() API, or
 * the Event Manager can obtain the event data itself by calling the Generate
 * function for the event, after first checking whether the event data is
 * required by a subscription.
 * @param p_event_name Event Name
 * @param p_event_key Event Key
 * @param p_event_data Event Message
 * @param p_parameters Parameter List
 * @param p_send_date Send Date for a Deferred Event
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Raise Local Event
 * @rep:compatibility S
 * @rep:ihelp FND/@evtapis#a_evraise See the related online help
 */
PROCEDURE raise(p_event_name in varchar2,
                p_event_key  in varchar2,
                p_event_data in clob default NULL,
                p_parameters in wf_parameter_list_t default NULL,
                p_send_date  in date default NULL);
------------------------------------------------------------------------------
/*
** listen -  dequeues and dispatches all events currently enqueued
**           for this agent.
**
**        Uses the appropriate QUEUE_HANDLER interface package to
**        dequeue events into the WF_EVENT_T type structure.  Then
**        calls DISPATCH with the appropriate source type
**        (usually 'EXTERNAL' but 'ERROR' if agent name is 'WF_ERROR')
**
**        Exits after all the events have been dequeued.
**
**        The WF_SETUP package schedules LISTEN procedures for all active
**        inbound agents.
*/
/*#
 * Monitors an agent for inbound event messages and dequeues messages
 * using the agent's queue handler. The standard WF_EVENT_QH queue handler
 * sets the date and time when an event message is dequeued into the
 * RECEIVE_DATE attribute of the event message. Custom queue handlers can
 * also set the RECEIVE_DATE value if this functionality is included in the
 * Dequeue API. When an event is dequeued, the Event Manager searches for and
 * executes any active subscriptions by the local system to that event with
 * a source type of External, and also any active subscriptions by the local
 * system to the Any event with a source type of External. If no active
 * subscriptions exist for the event that was received (apart from
 * subscriptions to the Any event), then Oracle Workflow executes any active
 * subscriptions by the local system to the Unexpected event with a source type
 * of External.
 * @param p_agent_name Agent Name
 * @param p_wait Wait period in seconds
 * @param p_correlation Correlation ID
 * @param p_deq_condition Dequeue Condition
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Listen to Agent
 * @rep:compatibility S
 * @rep:ihelp FND/@evtapis#a_evlis See the related online help
 */
PROCEDURE listen(p_agent_name  in varchar2,
                 p_wait        in binary_integer default dbms_aq.no_wait,
                 p_correlation in varchar2       default null,
                 p_deq_condition in varchar2     default null);
---------------------------------------------------------------------------
/*
** listen - New API to implement GSC-alike Logic
**
** Two more parameters are added: p_message_count and p_max_error_count
*/
/*#
 * New Listen API with Two more parameters are added: p_message_count and p_max_error_count
 * to limit how many messages listener is going to process.
 * @param p_agent_name Agent Name
 * @param p_wait Wait period in seconds
 * @param p_correlation Correlation ID
 * @param p_deq_condition Dequeue condition as in SQL WHERE clause
 * @param p_message_count maximum count of messages to be processed
 * @param p_max_error_count maximum number of errors tolerated.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Listen to Agent
 * @rep:compatibility S
 * @rep:ihelp FND/@evtapis#a_evlis See the related online help
 */
PROCEDURE listen(p_agent_name  in varchar2,
                 p_wait        in binary_integer default dbms_aq.no_wait,
                 p_correlation in varchar2       default null,
                 p_deq_condition in varchar2     default null,
                 p_message_count in out nocopy number,
                 p_max_error_count in out nocopy number);
---------------------------------------------------------------------------
/*
** listen_concurrent - This is a cover of listen() that can be used
**                     by the Concurrent Manager.
*/
--Bug 2505487
--Included the AQ wait parameter for the listen_concurrent

PROCEDURE listen_concurrent(errbuf        out nocopy varchar2,
                            retcode       out nocopy varchar2,
                            p_agent_name  in  varchar2,
                            p_correlation in varchar2 default null,
                            p_deq_condition in varchar2 default null,
                            p_wait    in binary_integer default dbms_aq.no_wait
                           );
---------------------------------------------------------------------------
/*
** listen_grp -  dequeues and dispatches all events currently enqueued
**               for this agent.
**
**        Supports message grouping to dequeue by transactions.
**        Uses the appropriate QUEUE_HANDLER interface package to
**        dequeue events into the WF_EVENT_T type structure.  Then
**        calls DISPATCH with the appropriate source type
**        (usually 'EXTERNAL' but 'ERROR' if agent name is 'WF_ERROR')
**
**        Exits after all the events have been dequeued.
**
**
*/
PROCEDURE listen_grp(p_agent_name in varchar2,
                     p_wait       in binary_integer default dbms_aq.no_wait);
---------------------------------------------------------------------------
/*
** listen__grp_concurrent - This is a cover of listen_grp() that can be used
**                          by the Concurrent Manager.
*/
PROCEDURE listen_grp_concurrent(errbuf       out nocopy varchar2,
                                retcode      out nocopy varchar2,
                                p_agent_name in  varchar2);

---------------------------------------------------------------------------

/*
** dequeue - generic dequeue.
**
**        Determines the appropriate QUEUE_HANDLER interface package to
**        dequeue events into the WF_EVENT_T type structure.
*/
/* @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Enqueue Event Message
 * @rep:compatibility S
 * @rep:ihelp FND/@evtapis#a_evenq See the related online help
*/
PROCEDURE dequeue(p_agent_guid    in     raw,
                  p_event         out nocopy    wf_event_t,
                  p_queue_handler in out nocopy varchar2,
                  p_wait          in     binary_integer default dbms_aq.no_wait,
                  p_correlation   in     varchar2       default null,
                  p_deq_condition in     varchar2       default null);
---------------------------------------------------------------------------
/*
** enqueue - generic enqueue.
**
**        Determines the appropriate QUEUE_HANDLER interface package to
**        enqueue events from the WF_EVENT_T type structure.
**
**        If the p_out_agent_override is specified, enqueues to that
**        agent instead of the one specified in p_event.From_agent.
*/
/*#
 * Enqueues an event message onto a queue associated with an outbound agent.
 * You can optionally specify an override agent where you want to enqueue the
 * event message. Otherwise, the event message is enqueued on the From Agent
 * specified within the message. The message recipient is set to the To Agent
 * specified in the event message. Enqueue() uses the queue handler for the
 * outbound agent to place the message on the queue.
 * @param p_event Event Message to Enqueue
 * @param p_out_agent_override Outbound Agent
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Enqueue Event Message
 * @rep:compatibility S
 * @rep:ihelp FND/@evtapis#a_evenq See the related online help
 */
PROCEDURE enqueue(p_event              in wf_event_t,
                  p_out_agent_override in wf_agent_t default null);
---------------------------------------------------------------------------
/*
** setErrorInfo - retrieve the error information from the
**                stack and set into the wf_event_t.
**
**                p_type should be WARNING or ERROR
*/
/*#
 * Retrieves error information from the error stack and sets it into the event
 * message. The error message and error stack are set into the corresponding
 * attributes of the event message. The error name and error type are added to
 * the PARAMETER_LIST attribute of the event message.
 * @param p_event Event Message
 * @param p_type Error Type ('ERROR' or 'WARNING')
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Error Information
 * @rep:compatibility S
 * @rep:ihelp FND/@evtapis#a_evseinf See the related online help
 */
PROCEDURE setErrorInfo(p_event  in out nocopy wf_event_t,
                       p_type   in     varchar2);
---------------------------------------------------------------------------
/*
** AddParameterToList - adds name and value to varray size 100
**			wf_parameter_list_t
**			if the varray is null, will initialize
**			otherwise just adds to end of list
*/
/*#
 * Adds the specified parameter name and value pair to the end of the specified
 * parameter list varray. If the varray is null, AddParameterToList()
 * initializes it with the new parameter.
 * @param p_name Parameter Name
 * @param p_value Parameter Value
 * @param p_parameterlist Parameter List
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Add Parameter to List
 * @rep:compatibility S
 * @rep:ihelp FND/@evtapis#a_evaptl See the related online help
 */
PROCEDURE AddParameterToList(p_name  in varchar2,
                             p_value in varchar2,
                             p_parameterlist in out nocopy wf_parameter_list_t);
---------------------------------------------------------------------------
/*
** AddParameterToListPos - adds name and value to varray size 100
**			   wf_parameter_list_t
**			   if the varray is null, will initialize
**                         After the value is set,
**                         the index will be set into the position.
*/
/*#
 * Adds the specified parameter name and value pair to the end of the specified
 * parameter list varray. If the varray is null, AddParameterToListPos()
 * initializes it with the new parameter. The procedure also returns the
 * index for the position at which the parameter is stored within the varray.
 * @param p_name Parameter Name
 * @param p_value Parameter Value
 * @param p_position Position at which Parameter is Added
 * @param p_parameterlist Parameter List
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Add Parameter to List and Return Position
 * @rep:compatibility S
 * @rep:ihelp FND/@evtapis#a_evaptlp See the related online help
 */
PROCEDURE AddParameterToListPos(p_name  in varchar2,
                             p_value in varchar2,
                             p_position out nocopy integer,
                             p_parameterlist in out nocopy wf_parameter_list_t);
---------------------------------------------------------------------------
/*
** GetValueForParameter - Gets value for name from wf_parameter_list_t
*/
/*#
 * Retrieves the value of the specified parameter from the specified parameter
 * list varray. GetValueForParameter() begins at the end of the parameter list
 * and searches backwards through the list.
 * @param p_name Parameter Name
 * @param p_parameterlist Parameter List
 * @return Parameter Value
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Value for Parameter
 * @rep:compatibility S
 * @rep:ihelp FND/@evtapis#a_evgvfp See the related online help
 */
FUNCTION getValueForParameter(p_name in varchar2,
			      p_parameterlist in wf_parameter_list_t)
return varchar2;
---------------------------------------------------------------------------
/*
** GetValueForParameterPos - Gets value for position from wf_parameter_list_t
*/
/*#
 * Retrieves the value of the parameter stored at the specified position in
 * the specified parameter list varray.
 * @param p_position Parameter Position in the List
 * @param p_parameterlist Parameter List
 * @return Parameter Value
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Value for Parameter in a Position
 * @rep:compatibility S
 * @rep:ihelp FND/@evtapis#a_evgvfpp See the related online help
 */
FUNCTION getValueForParameterPos(p_position in integer,
			      p_parameterlist in wf_parameter_list_t)
return varchar2;
---------------------------------------------------------------------------
/*
** SetDispatchMode
**        - Sets Phase Max Threshold to -1 or 100
*/
/*#
 * Sets the dispatch mode of the Event Manager to either deferred or
 * synchronous subscription processing. Call SetDispatchMode() with the
 * mode 'ASYNC' just before calling Raise() to defer all subscription
 * processing forever for the event that you will raise. In this case, the
 * Event Manager places the event on the WF_DEFERRED queue before
 * executing any subscriptions for that event. The subscriptions are not
 * executed until the agent listener runs to dequeue the event from the
 * WF_DEFERRED queue. You can call SetDispatchMode() with the mode 'SYNC' to
 * set the dispatch mode back to normal synchronous subscription processing.
 * In this mode, the phase number for each subscription determines whether
 * the subscription is executed immediately or deferred.
 * @param p_mode Dispatch Mode
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Dispatch Mode
 * @rep:compatibility S
 * @rep:ihelp FND/@evtapis#a_evsdmode See the related online help
 */
PROCEDURE SetDispatchMode(p_mode in varchar2);
---------------------------------------------------------------------------
/*
** InitPhaseMinThreshold
**        - Sets Phase Min Threshold to 0
*/
PROCEDURE InitPhaseMinThreshold;
---------------------------------------------------------------------------
/*
** DeferEvent  - Saves Event to Deferred Queue
*/
PROCEDURE DeferEvent(p_source_type        in     varchar2,
                     p_event              in out nocopy wf_event_t);
---------------------------------------------------------------------------
/*
** DeferEventToJava  - Saves Event to WF_JAVA_DEFERRED Queue
*/
PROCEDURE DeferEventToJava(p_source_type        in     varchar2,
                           p_event              in out nocopy wf_event_t);
---------------------------------------------------------------------------
/*
** GetDeferEventCtx - Determines the Source Type and Start Phase
**                    of deferred events
*/
PROCEDURE GetDeferEventCtx (p_source_type        in out nocopy     varchar2,
                         p_agent_name         in         varchar2,
                         p_system_name        in         varchar2,
                         p_event              in   wf_event_t);
---------------------------------------------------------------------------
/*
** SetAccountName  - Populates Global Variable with account name
**                   the session is logged in under
*/
PROCEDURE SetAccountName;
---------------------------------------------------------------------------
--
-- Bug# 2211719 - New API raise2 for calls that do not understand
--                Oracle data types

/*
** Raise API for calls that donot understand Oracle types
*/

PROCEDURE raise2(p_event_name      in varchar2,
                p_event_key        in varchar2,
                p_event_data       in clob default NULL,
                p_parameter_name1  in varchar2 default NULL,
                p_parameter_value1 in varchar2 default NULL,
                p_parameter_name2  in varchar2 default NULL,
                p_parameter_value2 in varchar2 default NULL,
                p_parameter_name3  in varchar2 default NULL,
                p_parameter_value3 in varchar2 default NULL,
                p_parameter_name4  in varchar2 default NULL,
                p_parameter_value4 in varchar2 default NULL,
                p_parameter_name5  in varchar2 default NULL,
                p_parameter_value5 in varchar2 default NULL,
                p_parameter_name6  in varchar2 default NULL,
                p_parameter_value6 in varchar2 default NULL,
                p_parameter_name7  in varchar2 default NULL,
                p_parameter_value7 in varchar2 default NULL,
                p_parameter_name8  in varchar2 default NULL,
                p_parameter_value8 in varchar2 default NULL,
                p_parameter_name9  in varchar2 default NULL,
                p_parameter_value9 in varchar2 default NULL,
                p_parameter_name10  in varchar2 default NULL,
                p_parameter_value10 in varchar2 default NULL,
                p_parameter_name11  in varchar2 default NULL,
                p_parameter_value11 in varchar2 default NULL,
                p_parameter_name12  in varchar2 default NULL,
                p_parameter_value12 in varchar2 default NULL,
                p_parameter_name13  in varchar2 default NULL,
                p_parameter_value13 in varchar2 default NULL,
                p_parameter_name14  in varchar2 default NULL,
                p_parameter_value14 in varchar2 default NULL,
                p_parameter_name15  in varchar2 default NULL,
                p_parameter_value15 in varchar2 default NULL,
                p_parameter_name16  in varchar2 default NULL,
                p_parameter_value16 in varchar2 default NULL,
                p_parameter_name17  in varchar2 default NULL,
                p_parameter_value17 in varchar2 default NULL,
                p_parameter_name18  in varchar2 default NULL,
                p_parameter_value18 in varchar2 default NULL,
                p_parameter_name19  in varchar2 default NULL,
                p_parameter_value19 in varchar2 default NULL,
                p_parameter_name20  in varchar2 default NULL,
                p_parameter_value20 in varchar2 default NULL,
                p_send_date         in date default NULL);
---------------------------------------------------------------------------
/*
** CreateParamater - Creates a wf_parameter_t type object based in the
**                   input name and value
*/

FUNCTION CreateParameter (p_name        in      varchar2,
                          p_value       in      varchar2)
return wf_parameter_t;

--------------------------------------------------------------------------
--Bug2375902
--New API that raises an event with the parameterlist and
--returns the same to the calling program
-------------------------------------------------------------------------
/*#
 * Raises a local event to the Event Manager and returns the parameter list for
 * the event. Raise3() performs the same processing as the Raise() procedure,
 * except that Raise3() passes the event parameter list back to the calling
 * application after completing the event subsription processing.
 * @param p_event_name Event Name
 * @param p_event_key Event Key
 * @param p_event_data Event Message
 * @param p_parameter_list Parameter List
 * @param p_send_date Send Date for a Deferred Event
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Raise Local Event and Return Parameter List
 * @rep:compatibility S
 * @rep:ihelp FND/@evtapis#a_evrsthree See the related online help
 */
PROCEDURE raise3(p_event_name      in varchar2,
                p_event_key        in varchar2,
                p_event_data       in clob default NULL,
                p_parameter_list   in out nocopy wf_parameter_list_t,
                p_send_date        in date default NULL);

---------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Sets the queue correlation (g_correlation) for dequeuing.
--
-- NOTE: This has been done because we did not want to change the signature of
--       dequeue in the queue handler
--
-- p_correlation - the correlation
--------------------------------------------------------------------------------
PROCEDURE Set_Correlation(p_correlation in varchar2);

---------------------------------------------------------------------------
/*
** PUBLIC
** SetMaxNestedRaise  - Populates Global Variable : max_nested_raises
**                      with the value specified in the input parameter.
*/
/*#
 * Sets the maximum number of nested raises that can be performed to the
 * specified value. A nested raise occurs when one event is raised and a Local
 * subscription to that event is executed and raises another event. The default
 * maximum is 100.
 * @param maxcount Maximum Number of Nested Raises
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Maximum Nested Raise Count
 * @rep:compatibility S
 * @rep:ihelp FND/@evtapis#a_evsmnr See the related online help
 */
PROCEDURE SetMaxNestedRaise (maxcount  in number default 100);
---------------------------------------------------------------------------
/*
** PUBLIC
** SetNestedRaiseCount  - Populates Global Variable : nested_raises_count
**                        with the value specified in the input parameter.
*/
PROCEDURE SetNestedRaiseCount (nestedcount in number default 0);
---------------------------------------------------------------------------
/*
** PUBLIC
** GetMaxNestedRaise  - Get the value of the Global Variable max_nested_raises
*/
/*#
 * Returns the maximum number of nested raises that can currently be performed.
 * A nested raise occurs when one event is raised and a Local subscription to
 * that event is executed and raises another event.
 * @return Maximum Number of Nested Raises
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Maximum Nested Raise Count
 * @rep:compatibility S
 * @rep:ihelp FND/@evtapis#a_evgmnr See the related online help
 */
FUNCTION GetMaxNestedRaise return number;

---------------------------------------------------------------------------
/*
** PUBLIC
** GetNestedRaiseCount  - Get the value of the Global Variable
**                        nested_raises_count
*/

FUNCTION GetNestedRaiseCount return number;

----------------------------------------------------------------------------

FUNCTION Get_MsgId return varchar2;

----------------------------------------------------------------------------
/*
** PUBLIC
** GetLocalSystemInfo - Gets the local system name, guid and status
*/

PROCEDURE GetLocalSystemInfo(system_guid   out nocopy raw,
                             system_name   out nocopy varchar2,
                             system_status out nocopy varchar2);

----------------------------------------------------------------------------
/*
** PUBLIC
** GetSourceAgentGUID - Gets the agent guid based on the agent name and the
**                      system name
*/
PROCEDURE GetSourceAgentGUID(agent_name   in         varchar2,
                             agent_system in         varchar2,
                             agent_guid   out nocopy raw);

----------------------------------------------------------------------------
/*
** PUBLIC
** StartAgent - Starts the given agent (if not already running) based on
** whether it is enabled for enqueue or dequeue or both
*/
procedure StartAgent(agent_name   in    varchar2);

----------------------------------------------------------------------------
/*
** PUBLIC
** Peek_Agent - Listens on the given queue to check for messages
*/
FUNCTION Peek_Agent(p_agent_name IN VARCHAR2)
         RETURN VARCHAR2;

----------------------------------------------------------------------------
-- GetParamListFromString
--   Takes a space delimited NAME=VALUE pairs of Subscription Parameters
--   string and returns a WF_PARAMETER_LIST_T
-- IN
--   p_parameters A string with space delimited name=value pairs
function GetParamListFromString(p_parameters in varchar2)
return wf_parameter_list_t;

  /*
  ** PUBLIC
  ** setNavigationParams - Sets the navigation parameters for dequeue: agent name,
  **           and navigation threshold. The navigation threshold is the maximum
  **           number of dequeued messages after which the navigation should be
  **           set back to FIRST_MESSAGE; the threshold parameter does not apply
  **           for TRANSACTIONAL dequeuing. Use setNavigationParams() typically
  **           before a loop to dequeue several messages from an agent queue,
  **           for instance, before calling listen().
  */
  procedure setNavigationParams(p_agentName in varchar2 default null
                              , p_navigationThreshold in number default 0);

  /*
  ** PUBLIC
  ** resetNavigationParams - Resets the navigation message counter, so that next
  **               navigation to use is FIRST_MESSAGE/NEXT_TRSANCTION (typically
  **               when catching a dequeue exception).
  */
  procedure resetNavigationParams;

  /*
  ** PUBLIC
  ** getQueueNavigation - Returns the next dequeue navigation (FIRST_MESSAGE,
  **               NEXT_MESSAGE, etc.); to be used before calling dequeue() to
  **               get the proper navigation option. It is assumed that
  **               wf_event.setNavigationParams() was called before
  **               starting a loop to dequeue messages from a queue.
  **               Use this api to get the proper navigation value just before
  **               dequeuing, so that the agent parameter
  **               NAVIGATION_RESET_THRESHOLD takes effect.
  */
  function getQueueNavigation return BINARY_INTEGER;

end WF_EVENT;

/
