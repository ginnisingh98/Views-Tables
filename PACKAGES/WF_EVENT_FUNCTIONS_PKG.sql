--------------------------------------------------------
--  DDL for Package WF_EVENT_FUNCTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_EVENT_FUNCTIONS_PKG" AUTHID CURRENT_USER as
/* $Header: WFEVFNCS.pls 120.2 2005/11/28 00:52:39 nravindr ship $ */
 /*#
 * Provides utility functions to communicate with the Business Event
 * System and manage events.
 * @rep:scope public
 * @rep:product OWF
 * @rep:displayname Workflow Event Functions
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY WF_EVENT
 * @rep:ihelp FND/@evfuncapis See the related online help
 */

------------------------------------------------------------------------------
type T_PARAMETERS is TABLE of varchar2(240);
------------------------------------------------------------------------------
/*#
 * Generates the event data for events in the Seed event group. This event
 * data contains Business Event System object definitions which can be
 * used to replicate the objects from one system to another. For the event,
 * event group, system, agent, agent group member, and subscription definition
 * events, WF_EVENT_FUNCTIONS_PKG.Generate() calls the Generate APIs associated
 * with the corresponding tables to produce the event data XML document. For
 * the Synchronize Event Systems event, WF_EVENT_FUNCTIONS_PKG.Generate()
 * produces an XML document containing all the event, event group, system,
 * agent, agent group member, and subscription definitions from the Event
 * Manager on the local system.
 * @param p_event_name Event Name
 * @param p_event_key Event Key
 * @return Event Data as CLOB
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Generate Event Data for Seed Event Group
 * @rep:compatibility S
 * @rep:ihelp FND/@evfuncapis#a_evfgen See the related online help
 */
function GENERATE (
  P_EVENT_NAME     in    varchar2,
  P_EVENT_KEY      in    varchar2
) return clob;
------------------------------------------------------------------------------
/*#
 * Generates the event data for events in the Seed event group. This event
 * data contains Business Event System object definitions which can be
 * used to replicate the objects from one system to another. For the event,
 * event group, system, agent, agent group member, and subscription definition
 * events, WF_EVENT_FUNCTIONS_PKG.Generate() calls the function
 * WF_EVENT_FUNCTIONS_PKG.Generate() ignoring the wf_parameter_list_t, which
 * in turn calls the APIs associated with the corresponding tables to produce
 * the event data XML document. For the Synchronize Event Systems event,
 * WF_EVENT_FUNCTIONS_PKG.Generate() produces an XML document containing all
 * the event, event group, system, agent, agent group member, and subscription
 * definitions from the Event Manager on the local system.
 * @param p_event_name Event Name
 * @param p_event_key Event Key
 * @param p_parameter_list Event Parameter List
 * @return Event Data as CLOB
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Generate Event Data for Seed Event Group
 * @rep:compatibility S
 */
function GENERATE (
  P_EVENT_NAME     in    varchar2,
  P_EVENT_KEY      in    varchar2,
  P_PARAMETER_LIST in    wf_parameter_list_t
) return clob;
------------------------------------------------------------------------------
/*#
 * Receives Business Event System object definitions during subscription
 * processing and loads the definitions into the appropriate Business
 * Event System tables. This function completes the replication of the
 * objects from one system to another. WF_EVENT_FUNCTIONS_PKG.Receive() is
 * defined according the the standard API for an event subscription rule
 * function. Oracle Workflow uses WF_EVENT_FUNCTIONS_PKG.Receive() as the
 * rule function for two predefined subscriptions, one that is triggered when
 * the System Signup event is raised locally, and one that is triggered when
 * any of the events in the Seed event group is received from an external
 * source.
 * @param p_subscription_guid Subscription GUID
 * @param p_event Event Message
 * @return Result as ERROR, SUCCESS, WARNING
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Receive Event Data for Seed Event Group
 * @rep:compatibility S
 * @rep:ihelp FND/@evfuncapis#a_evfrec See the related online help
 */
function RECEIVE (
 P_SUBSCRIPTION_GUID	in	raw,
 P_EVENT		in out nocopy wf_event_t
) return varchar2;
------------------------------------------------------------------------------
procedure SEND (
 P_EVENTNAME    in      varchar2,
 P_EVENTKEY     in      varchar2,
 P_EVENTDATA    in      clob,
 P_TOAGENT      in      varchar2,
 P_TOSYSTEM     in      varchar2,
 P_PRIORITY     in      number,
 P_SENDDATE     in      date
);
------------------------------------------------------------------------------
/*#
 * Parses a string of text that contains the specified number of parameters
 * delimited by the specified separator. Parameters() returns the parsed
 * parameters in a varray using the T_PARAMETERS composite datatype, which is
 * defined in the WF_EVENT_FUNCTIONS_PKG package. Parameters() is a generic
 * utility that you can call in Generate functions when the event key is a
 * concatenation of values separated by a known character. Use this function
 * to separate the event key into its component values.
 * @param p_string String with concatenated values
 * @param p_numvalues Number of values
 * @param p_separator Delimiter for values
 * @return Array of parameters
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Parse for Parameters
 * @rep:compatibility S
 * @rep:ihelp FND/@evfuncapis#a_evfpar See the related online help
 */
function PARAMETERS (
 P_STRING       in      varchar2,
 P_NUMVALUES    in      number,
 P_SEPARATOR    in      varchar2)
return t_parameters;
------------------------------------------------------------------------------
/*#
 * Adds a correlation ID to an event message during subscription
 * processing. AddCorrelation() searches the subscription parameters for
 * a parameter named ITEMKEY that specifies a custom function to generate
 * a correlation ID for the event message.
 * @param p_subscription_guid Subscription GUID
 * @param p_event Event Message
 * @return Status as ERROR, SUCCESS, WARNING
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Add Correlation ID
 * @rep:compatibility S
 * @rep:ihelp FND/@evfuncapis#a_evfadd See the related online help
 */
function ADDCORRELATION (
 P_SUBSCRIPTION_GUID    in      raw,
 P_EVENT                in out nocopy wf_event_t
) return varchar2;
------------------------------------------------------------------------------
/*#
 * Returns the value for the specified parameter from a text string
 * containing the parameters defined for an event subscription. The
 * parameter name and value pairs in the text string should be separated
 * by spaces and should appear in the following format: name1=value1
 * name2=value2 ...  nameN=valueN
 * @param p_string Text string with the parameters
 * @param p_key Parameter Name to get the value
 * @param p_guid Subscription GUID
 * @return Parameter Value
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Subscription Parameter Value
 * @rep:compatibility S
 * @rep:ihelp FND/@evfuncapis#a_evfsub See the related online help
 */
function SUBSCRIPTIONPARAMETERS (
 P_STRING       in out nocopy varchar2,
 P_KEY          in      varchar2,
 P_GUID         in      raw default NULL
) return varchar2;

------------------------------------------------------------------------------
function SubParamInEvent(p_guid in raw,
                         p_event in out NOCOPY wf_event_t,
                         p_match in varchar2 DEFAULT 'ALL' )
 return boolean;

------------------------------------------------------------------------------
Procedure UpdateLicenseStatus (p_OwnerTag in varchar2, p_Status in varchar2);

end WF_EVENT_FUNCTIONS_PKG;

 

/
