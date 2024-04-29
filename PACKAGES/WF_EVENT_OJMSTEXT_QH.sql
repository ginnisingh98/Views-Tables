--------------------------------------------------------
--  DDL for Package WF_EVENT_OJMSTEXT_QH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_EVENT_OJMSTEXT_QH" AUTHID CURRENT_USER as
/* $Header: wfjmstxs.pls 120.3.12010000.2 2009/08/16 14:11:28 skandepu ship $ */
/*#
 * Handles business event messages on queues that use the
 * SYS.AQ$_JMS_TEXT_MESSAGE datatype as their payload type.
 * @rep:scope public
 * @rep:product WF
 * @rep:displayname Workflow JMS Text Queue Handler
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY WF_EVENT
 */

JMS_TYPE     constant varchar2(8)  := 'JMS_TYPE';
JMS_USERID   constant varchar2(10) := 'JMS_USERID';
JMS_APPID    constant varchar2(9)  := 'JMS_APPID';
JMS_GROUPID  constant varchar2(11) := 'JMS_GROUPID';
JMS_GROUPSEQ constant varchar2(12) := 'JMS_GROUPSEQ';
JMS_REPLYTO  constant varchar2(11) := 'JMS_REPLYTO';

--------------------------------------------------------------------------------
-- Enqueues a business event into a JMS queue.
--
-- p_event - the business event to enqueue
-- p_out_agent_override - the out agent override
--------------------------------------------------------------------------------
/*#
 * Enqueues an event message onto the JMS queue associated with the outbound agent.
 * You can optionally specify an override agent where you want to enqueue the event message.
 * Otherwise, the event message is enqueued on the From Agent specified within the message.
 * @param p_event The event message.
 * @param p_out_agent_override The address of the override outbound agent.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Enqueue Business Event
 * @rep:compatibility S
 */
procedure enqueue(p_event              in wf_event_t,
                  p_out_agent_override in wf_agent_t default null);

--------------------------------------------------------------------------------
-- Dequeues a business event from a JMS queue.
--
-- p_agent_guid - the agent GUID
-- p_event - the business event
-- p_wait - the number of seconds to wait to dequeue the event
--------------------------------------------------------------------------------
/*#
 * Dequeues an event message from the JMS queue associated with the specified
 * inbound agent.
 * @param p_agent_guid The globally unique identifier of the inbound agent.
 * @param p_event The deqeueued event message.
 * @param p_wait The number of seconds to wait before dequeuing the event.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Dequeue Business Event
 * @rep:compatibility S
 */
procedure dequeue(p_agent_guid in raw,
                  p_event      out nocopy wf_event_t,
                  p_wait       in binary_integer default dbms_aq.no_wait);

--------------------------------------------------------------------------------
-- Tranforms a business event into a JMS Text Message.
--
-- p_event - the business event to transform
-- p_jms_text_message - the JMS Text Message
--------------------------------------------------------------------------------
/*#
 * Transforms the specified event message into a JMS Text message.
 * @param p_event The event message to transform.
 * @param p_jms_text_message The resulting JMS Text message.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Serialize Business Event
 * @rep:compatibility S
 */
procedure serialize(p_event            in wf_event_t,
                    p_jms_text_message out nocopy sys.aq$_jms_text_message);

--------------------------------------------------------------------------------
-- Tranforms a JMS Text Message into a business event.
--
-- p_jms_text_message - the JMS Text Message
-- p_event - the business event
--------------------------------------------------------------------------------
/*#
 * Transforms the specified JMS Text message into an event message.
 * @param p_jms_text_message The JMS Text message to transform.
 * @param p_event The resulting event message.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Deserialize JMS Text Message
 * @rep:compatibility S
 */
procedure deserialize(p_jms_text_message in out nocopy sys.aq$_jms_text_message,
                      p_event            out nocopy wf_event_t);

end wf_event_ojmstext_qh;

/
