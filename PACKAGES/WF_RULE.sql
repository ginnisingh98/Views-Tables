--------------------------------------------------------
--  DDL for Package WF_RULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_RULE" AUTHID CURRENT_USER as
/* $Header: wfrules.pls 120.3 2006/04/27 03:09:47 nravindr ship $ */
/*#
 * Provides standard rule functions that you can assign to event
 * subscriptions. A rule function specifies the processing that Oracle
 * Workflow performs when the subscription's triggering event occurs.
 * @rep:scope public
 * @rep:product OWF
 * @rep:displayname Workflow Event Subscription Rule Function
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY WF_EVENT
 * @rep:ihelp FND/@evrulapis See the related online help
 */
--------------------------------------------------------------------------
/*
** log - logs the contents of the specified event.  Returns SUCCESS.
*/
/*#
 * Logs the contents of the specified event message using
 * DBMS_OUTPUT.put_line and returns the status code SUCCESS. Use this
 * function to output the contents of an event message to a SQL*Plus
 * session for testing and debugging purposes.
 * @param p_subscription_guid Subscription GUID
 * @param p_event Event Message
 * @return Status as ERROR, SUCCESS, WARNING
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Log Rule Function
 * @rep:compatibility S
 * @rep:ihelp FND/@evrulapis#a_evrullog See the related online help
 */
FUNCTION log(p_subscription_guid in     raw,
             p_event             in out nocopy wf_event_t) return varchar2;
---------------------------------------------------------------------------
/*
** error - no-op.  Returns ERROR.
*/
/*#
 * Returns the status code ERROR. Additionally, when you assign this
 * function as the rule function for a subscription, you must enter a text
 * string representing the internal name of an error message in the
 * Parameters field for the subscription. When the subscription is
 * executed, Error() will set that error message into the event.
 * @param p_subscription_guid Subscription GUID
 * @param p_event Event Message
 * @return Status as ERROR
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Error Rule Function
 * @rep:compatibility S
 * @rep:ihelp FND/@evrulapis#a_evrullog See the related online help
 */
FUNCTION error(p_subscription_guid in     raw,
               p_event             in out nocopy wf_event_t) return varchar2;
---------------------------------------------------------------------------
/*
** warning - no-op.  Returns WARNING.
*/
/*#
 * Returns the status code WARNING. Additionally, when you assign this
 * function as the rule function for a subscription, you must enter a text
 * string representing the internal name of an error message in the
 * Parameters field for the subscription. When the subscription is
 * executed, Warning() will set that error message into the event message.
 * @param p_subscription_guid Subscription GUID
 * @param p_event Event Message
 * @return Status as WARNING
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Warning Rule Function
 * @rep:compatibility S
 * @rep:ihelp FND/@evrulapis#a_evrulwar See the related online help
 */
FUNCTION warning(p_subscription_guid in     raw,
                 p_event             in out nocopy wf_event_t) return varchar2;
---------------------------------------------------------------------------
/*
** success - no-op.  Returns SUCCESS.
*/
/*#
 * Returns the status code SUCCESS. This function removes the event
 * message from the queue but executes no other code except returning
 * the SUCCESS status code to the calling subscription.
 * @param p_subscription_guid Subscription GUID
 * @param p_event Event Message
 * @return Status as SUCCESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Success Rule Function
 * @rep:compatibility S
 * @rep:ihelp FND/@evrulapis#a_evrulsuc See the related online help
 */
FUNCTION success(p_subscription_guid in     raw,
                 p_event             in out nocopy wf_event_t) return varchar2;
---------------------------------------------------------------------------
/*
** default_rule - default dispatch functionality for subscription processing
**
**    When a rule function is not supplied for a subscription, we
**    provide default subscription processing logic.  This procedure
**    implements that logic.  Users may also call this procedure to
**    add the default processing logic to their rule function.
**
**        1) Send the event message to a Workflow process, if specified
**        2) Send the event message to an agent, if specified
**
**    Returns ERROR and message if either the Workflow or
**    Send operation raises an exception.  Otherwise returns SUCCESS.
*/
/*#
 * Performs default subscription processing, including sending the event
 * message to a workflow process or to an agent, if specified in the
 * subscription definition. If either of these operations raises an
 * exception, Default_Rule() traps the exception, stores the error
 * information in the event message, and returns the status code
 * ERROR. Otherwise, Default_Rule() returns the status code SUCCESS.
 * @param p_subscription_guid Subscription GUID
 * @param p_event Event Message
 * @return Status as ERROR, SUCCESS, WARNING
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Default Rule Function
 * @rep:compatibility S
 * @rep:ihelp FND/@evrulapis#a_evruldef See the related online help
 */
FUNCTION default_rule(p_subscription_guid in     raw,
                      p_event             in out nocopy wf_event_t) return varchar2;

---------------------------------------------------------------------------
/*
** default_rule2 - Executes default_rule only if the subscription contains
**                 parameters that are in the event parameter list.
**    Returns ERROR and message if either the Workflow or
**    Send operation raises an exception.  Otherwise returns SUCCESS.
*/
/*#
 * Performs the default subscription processing only if the event message
 * includes parameters that match all the subscription parameters. The
 * default subscription processing includes sending the event message to
 * a workflow process or to an agent, if specified in the subscription
 * definition. If either of these operations raises an exception,
 * Default_Rule2() traps the exception, stores the error information in
 * the event message, and returns the status code ERROR. Otherwise,
 * Default_Rule2() returns the status code SUCCESS.
 * @param p_subscription_guid Subscription GUID
 * @param p_event Event Message
 * @return Status as ERROR, SUCCESS, WARNING
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Default Rule Function When Parameters Match
 * @rep:compatibility S
 * @rep:ihelp FND/@evrulapis#a_evruldeftw See the related online help
 */
FUNCTION default_rule2(p_subscription_guid in     raw,
                      p_event             in out nocopy wf_event_t)

return varchar2;
---------------------------------------------------------------------------
/*
** workflow_protocol - uses workflow to perform the send, instead of default
**
**    Subscription processing logic which will use a workflow process to
**    send messages.  Depending on values in the parameters field, the
**    workflow may wait on a receive for an acknowledgement.
**
**    Returns ERROR if the Workflow raises an exception.
**    Otherwise returns SUCCESS.
*/
/*#
 * Sends the event message to the workflow process specified in the
 * subscription, which will in turn send the event message to the inbound
 * agent specified in the subscription. This function does not itself
 * send the event message to the inbound agent. The function only sends
 * the event message to the workflow process, where you can model the
 * processing that you want to send the event message on to the specified
 * agent.
 * @param p_subscription_guid Subscription GUID
 * @param p_event Event Message
 * @return Status as ERROR, SUCCESS, WARNING
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Workflow Protocol
 * @rep:compatibility S
 * @rep:ihelp FND/@evrulapis#a_evrulwfp See the related online help
 */
FUNCTION workflow_protocol(p_subscription_guid in     raw,
                           p_event          in out nocopy wf_event_t) return varchar2;
----------------------------------------------------------------------------
/*
** error_rule - dispatch functionality for error subscription processing
**
**   Identical to default_rule, but if an exception is caught we raise it
**   up to cause a rollback.  We don't want messages processed off the
**   error queue to be continually recycled back on to the error queue.
**
**   Returns SUCCESS or raises an exception
**
*/
/*#
 * Performs the default subscription processing, but reraises any
 * exception. The default subscription processing includes sending the
 * event message to a workflow process or to an agent, if specified in
 * the subscription definition. If either of these operations encounters
 * an exception, Error_Rule() reraises the exception instead of returning
 * a WARNING or ERROR status code, so that the event is not placed back
 * onto the WF_ERROR queue. Otherwise, Error_Rule() returns the status
 * code SUCCESS.
 * @param p_subscription_guid Subscription GUID
 * @param p_event Event Message
 * @return Status as SUCCESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Default Error Rule Function
 * @rep:compatibility S
 * @rep:ihelp FND/@evrulapis#a_evrulerul See the related online help
 */
FUNCTION error_rule(p_subscription_guid in     raw,
                           p_event          in out nocopy wf_event_t) return varchar2;
----------------------------------------------------------------------------
/*
** setParametersIntoParameterList - Set Subscription Parameters into Parameter List
**
**    Returns ERROR if the Workflow raises an exception.
**    Otherwise returns SUCCESS.
**
*/
/*#
 * Sets the parameter name and value pairs from the subscription parameters
 * into the PARAMETER_LIST attribute of the event message, except for any
 * parameter named ITEMKEY or CORRELATION_ID. For a parameter with one of
 * these names, the function sets the CORRELATION_ID attribute of the event
 * message to the parameter value.
 * @param p_subscription_guid Subscription GUID
 * @param p_event Event Message
 * @return Status as ERROR, SUCCESS, WARNING
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Parameters into Parameter List
 * @rep:compatibility S
 * @rep:ihelp FND/@evrulapis#a_evrulspipl See the related online help
 */
FUNCTION setParametersIntoParameterList(p_subscription_guid in     raw,
                           p_event          in out nocopy wf_event_t) return varchar2;
----------------------------------------------------------------------------
--Bug 2193561
/*
**
This rule function can be used to send notifications .
This will make it trivial for the worklist to be accessed by
applications which do not want to build workflows, and still be able
to have certain actions performed based on the response processing
**
*/
/*#
 * Sends a notification as specified by the event parameter list. Use
 * this rule function to send notifications outside of a workflow
 * process.
 * @param p_subscription_guid Subscription GUID
 * @param p_event Event Message
 * @return Status as ERROR, SUCCESS, WARNING
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Send Notification Rule Function
 * @rep:compatibility S
 * @rep:ihelp FND/@evrulapis#a_evrulsntf See the related online help
 */
FUNCTION SendNotification (p_subscription_guid in    raw,
                           p_event          in out nocopy wf_event_t)
return varchar2;

-----------------------------------------------------------------------------
--Bug 2786192
/*
**
This rule function sets the parameterlist for the
the event from the subscription parameter list and subsequently
calls the default rule to execute the default processing
**
*/
/*#
 * Sets the subscription parameters into the event parameter list, and
 * then performs the default subscription processing with the modified
 * event message. The default subscription processing includes sending
 * the event message to a workflow process or to an agent, if specified
 * in the subscription definition. If either of these operations raises
 * an exception, Default_Rule3() traps the exception, stores the error
 * information in the event message, and returns the status code
 * ERROR. Otherwise, Default_Rule3() returns the status code SUCCESS.
 * @param p_subscription_guid Subscription GUID
 * @param p_event Event Message
 * @return Status as ERROR, SUCCESS, WARNING
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Default Rule Function Adding Parameters
 * @rep:compatibility S
 * @rep:ihelp FND/@evrulapis#a_evruldefth See the related online help
 */
FUNCTION default_rule3(p_subscription_guid in     raw,
                      p_event             in out nocopy wf_event_t)
return varchar2;

/* Bug 2472743
This rule function can be used to restart multiple Workflow process waiting
for this event (or a null event) where the event activity has item attribute
named #BUSINESS_KEY which has the specified value.
*/
/*#
 * Sends the event to all existing workflow process instances that have
 * eligible event activities waiting to receive it, identified by a
 * business key attribute that matches the event key.
 * @param p_subscription_guid Subscription GUID
 * @param p_event Event Message
 * @return Status as ERROR, SUCCESS, WARNING
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Send when Business Key Matches
 * @rep:compatibility S
 * @rep:ihelp FND/@evrulapis#a_evrulidr See the related online help
 */
FUNCTION instance_default_rule(p_subscription_guid in    raw,
                               p_event     in out nocopy wf_event_t)
return varchar2;

----------------------------------------------------------------------------

/*
** default_rule_or - Executes default_rule only if the subscription contains
**                 parameters that are in the event parameter list.
**    Returns ERROR and message if either the Workflow or
**    Send operation raises an exception.  Otherwise returns SUCCESS.
*/
/*#
 * Performs default subscription processing by calling Default_Rule only when
 * the subscription parameter list contains a parameter that exists in the
 * event parameter list.
 * The default processing either sends the event message to a workflow process,
 * if specified in the subscription definition or sends the event message
 * to an agent, if specified in the subscription definition. If either of
 * these operations raises an exception, Default_Rule() traps the exception,
 * stores the error information in the event message, and returns the
 * status code ERROR. Otherwise, Default_Rule() returns the status code
 * SUCCESS.
 * @param p_subscription_guid Subscription GUID
 * @param p_event Event Message
 * @return Status as ERROR, SUCCESS, WARNING
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Default Rule Function
 * @rep:compatibility S
 * @rep:ihelp FND/@evrulapis#a_evruldeftw See the related online help
 */
FUNCTION default_rule_or(p_subscription_guid in     raw,
                      p_event             in out nocopy wf_event_t)

return varchar2;

/*
** Default_Generate - This function is a generic event generation function
**                    that will generate an XML document based on the
**                    p_event_name, p_event_key and the p_parameter_list.
*/
/*#
 * Generates a simple set of event data from the specified event
 * name, event key, and parameter list. You can assign this
 * standard generate function to events for demonstration and
 * testing purposes. Default_Generate() generates the event data
 * as an XML document in the following structure:
 * <BUSINESSEVENT event-name="" key="">
 *    <GENERATETIME mask="" >
 *    <PARAMETERS count="">
 *       <PARAMETER parameter-name="">
 * @param p_event_name The event name
 * @param p_event_key The event key
 * @param p_parameter_list The list of parameter name and value pairs
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Standard Generate Function
 * @rep:compatibility S
 * @rep:ihelp FND/@a_evruldfgn See the related online help
 */
function Default_Generate(p_event_name in varchar2,
                  p_event_key in varchar2,
                  p_parameter_list in wf_parameter_list_t)
   return clob;

end WF_RULE;

 

/
