--------------------------------------------------------
--  DDL for Package WF_BES_CLEANUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_BES_CLEANUP" AUTHID CURRENT_USER as
/* $Header: WFBESCUS.pls 120.1.12010000.2 2009/08/16 14:06:23 skandepu ship $ */
/*#
 * Cleans up the standard WF_CONTROL queue in the Business Event System
 * by removing inactive subscribers from the queue.
 * @rep:scope public
 * @rep:product OWF
 * @rep:displayname Workflow Control Queue Cleanup
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY WF_EVENT
 * @rep:ihelp FND/@besclnapi See the related online help
 */

--------------------------------------------------------------------------------
-- Removes dead subscribers from the WF_CONTROL queue.  This procedure will be
-- run periodically to remove subscribers which have died.  This procedure:
-- 1. Checks to make sure that sufficient time has elapsed since the last time
--    it was run.  If not, it just returns.
-- 2. Removes dead queue subscribers.  A subscriber is assumed to be dead
--    if it has not responded to at least one ping.
-- 3. Sends out a new ping to the current subscribers.
--
-- errbuf - the error buffer
-- retcode - the return code
--------------------------------------------------------------------------------
/*#
 * Performs cleanup for the standard WF_CONTROL queue. When a middle tier
 * process for Oracle E-Business Suite starts up, it creates a JMS subscriber
 * to the WF_CONTROL queue. Then, when an event message is placed on the
 * queue, a copy of the event message is created for each subscriber to
 * the queue. If a middle tier process dies, however, the corresponding
 * subscriber remains in the database. For more efficient processing,
 * you should ensure that WF_CONTROL is periodically cleaned up by
 * running Cleanup_Subscribers() to remove the subscribers for any middle tier
 * processes that are no longer active.
 * @param errbuf Return Error Message
 * @param retcode Return Error Code
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Clean Up Inactive Subscribers
 * @rep:compatibility S
 * @rep:ihelp FND/@besclnapi#a_clnsub See the related online help
 */
procedure cleanup_subscribers(errbuf  out nocopy varchar2,
                              retcode out nocopy varchar2);

-------------------------------------------------------------------------------
-- Used by a subscriber to acknowledge receiving a ping.
--
-- ping_number - the ping number
-- queue_name - the queue name
-- subscriber_name - the subscriber name
--------------------------------------------------------------------------------
procedure acknowledge_ping(p_ping_number     in number,
                           p_queue_name      in varchar2,
                           p_subscriber_name in varchar2);

-------------------------------------------------------------------------------
-- Used to dequeue messages from exception queue
-- p_owner  Owner of the queue whose exception message will be removed
-- p_queue_table queue table of the queue
--------------------------------------------------------------------------------
-- Purge JMS Queue

-- p_queue_name     Queue name in format of owner.queue
-- p_consumer_name  mandatary for multiple consumer queue. Default is null
-- p_correlation    Optional to purge message with certain correlation. Default is null
-- p_commit_frequency how frequently the transaction should commit. Default is 100

/*#
 * Purges messages from a queue that uses the SYS.AQ$_JMS_TEXT_MESSAGE datatype
 * as its payload type. For a multi-consumer queue, you must specify
 * the consumer associated with the messages to purge. You can optionally
 * specify a correlation ID to purge only messages marked with that ID.
 * @param p_queue_name The queue name.
 * @param p_consumer_name The consumer name for the messages to purge.
 * @param p_correlation The correlation ID for the messages to purge.
 * @param p_commit_frequency The number of messages to purge before committing.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Purge JMS Queue
 * @rep:compatibility S
 */
procedure purge_jms_queue(p_queue_name in VARCHAR2,
                          p_consumer_name in VARCHAR2 default null,
                          p_correlation in VARCHAR2 default null,
                          p_commit_frequency in NUMBER default 100);

--------------------------------------------------------------------------------
-- Purge EVT Queue

-- p_queue_name     Queue name in format of owner.queue
-- p_consumer_name  mandatary for multiple consumer queue. Default is null
-- p_correlation    Optional to purge message with certain correlation. Default is null
-- p_commit_frequency how frequently the transaction should commit. Default is 100

/*#
 * Purges messages from a queue that uses the WF_EVENT_T datatype
 * as its payload type. For a multi-consumer queue, you must specify
 * the consumer associated with the messages to purge. You can optionally
 * specify a correlation ID to purge only messages marked with that ID.
 * @param p_queue_name The queue name.
 * @param p_consumer_name The consumer name for the messages to purge.
 * @param p_correlation The correlation ID for the messages to purge.
 * @param p_commit_frequency The number of messages to purge before committing.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Purge Event Queue
 * @rep:compatibility S
 */
procedure purge_evt_queue(p_queue_name in VARCHAR2,
                          p_consumer_name in VARCHAR2 default null,
                          p_correlation in VARCHAR2 default null,
                          p_commit_frequency in NUMBER default 100);

end wf_bes_cleanup;

/
