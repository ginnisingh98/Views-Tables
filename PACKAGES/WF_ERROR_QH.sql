--------------------------------------------------------
--  DDL for Package WF_ERROR_QH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_ERROR_QH" AUTHID CURRENT_USER as
/* $Header: wferrqhs.pls 120.2.12010000.2 2009/08/16 14:08:24 skandepu ship $ */
/*#
 * Handles business event messages on error queues that use the WF_EVENT_T
 * datatype as their payload type.
 * @rep:scope public
 * @rep:product OWF
 * @rep:displayname Workflow Error Queue Handler
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY WF_EVENT
 */
-------------------------------------------------------------------------
navigation  binary_integer := dbms_aq.next_message;
-------------------------------------------------------------------------
/*#
 * Dequeues an event message from the queue associated with the specified
 * inbound error agent.
 * @param p_agent_guid The globally unique identifier of the inbound agent.
 * @param p_event The deqeueued event message.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Dequeue Business Event
 * @rep:compatibility S
 */
PROCEDURE dequeue(p_agent_guid in  raw,
                  p_event      out nocopy wf_event_t);
-------------------------------------------------------------------------
/*#
 * Dequeues an event message from the queue associated with the specified
 * inbound error agent after waiting for the specified time.
 * @param p_agent_guid The globally unique identifier of the inbound agent.
 * @param p_event The deqeueued event message.
 * @param p_wait The number of seconds to wait before dequeuing the event.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Dequeue Business Event After Wait
 * @rep:compatibility S
 */
-- Bug 5034154
-- Added as a wrapper over the existing dequeue with two parameters
PROCEDURE dequeue(p_agent_guid in  raw,
                  p_event      out nocopy wf_event_t,
                  p_wait       in         binary_integer);
-------------------------------------------------------------------------
/*#
 * Enqueues an event message onto the queue associated with the outbound error agent.
 * You can optionally specify an override agent where you want to enqueue the event message.
 * Otherwise, the event message is enqueued on the From Agent specified within the message.
 * @param p_event The event message.
 * @param p_out_agent_override The address of the override outbound agent.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Enqueue Business Event
 * @rep:compatibility S
 */
PROCEDURE enqueue(p_event              in wf_event_t,
                  p_out_agent_override in wf_agent_t default null);
-------------------------------------------------------------------------
end WF_ERROR_QH;

/
