--------------------------------------------------------
--  DDL for Package Body ARP_QUEUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_QUEUE" AS
-- $Header: ARPQUEFB.pls 115.9 2003/10/10 14:25:45 mraymond ship $

  g_nq_opts        DBMS_AQ.ENQUEUE_OPTIONS_T;
  g_dq_opts        DBMS_AQ.DEQUEUE_OPTIONS_T;
  g_recipients     DBMS_AQ.AQ$_RECIPIENT_LIST_T;
  g_msg_id         RAW(16);
  g_full_qname     VARCHAR2(61);

  l_no_more_msgs   EXCEPTION;
  PRAGMA EXCEPTION_INIT(l_no_more_msgs, -25228);

  /*=========================================================================+
   |    Enqueue the message in the queue                                     |
   +=========================================================================*/

  PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE enqueue (p_msg IN system.AR_REV_REC_TYP) AS

     trx_with_no_rules EXCEPTION;
     l_msg             system.AR_REV_REC_TYP := p_msg;
     l_msg_prop       DBMS_AQ.MESSAGE_PROPERTIES_T;

  BEGIN

    --
    arp_util.print_fcn_label('arp_queue.enqueue()+');
    --
    -- Create a message to enqueue.

    l_msg_prop.recipient_list := g_recipients;

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('enqueue: ' ||  '> Processing Trx number : <' || p_msg.trx_number || '> Trx Id <' ||
     p_msg.customer_trx_id || '> Created From : <' || p_msg.created_from || ' ' ||p_msg.org_id );
     END IF;

    -- Enqueue it with the default options.
    DBMS_AQ.ENQUEUE(
      queue_name => get_full_qname('AR_REV_REC_Q'),
      enqueue_options => g_nq_opts,
      message_properties => l_msg_prop,
      payload => l_msg,
      msgid => g_msg_id);

    --
    arp_util.print_fcn_label('arp_queue.enqueue()-');
    --
  EXCEPTION
     WHEN trx_with_no_rules THEN
	NULL;
     WHEN OTHERS THEN
	RAISE;
  END enqueue;

  /*=========================================================================+
   |    Dequeue the message from the queue                                   |
   +=========================================================================*/

  PROCEDURE dequeue (p_msg IN OUT NOCOPY system.AR_REV_REC_TYP,
		     p_browse IN BOOLEAN := FALSE,
		     p_wait IN INTEGER := DBMS_AQ.NO_WAIT,
		     p_first IN BOOLEAN := FALSE) AS

  l_msg_prop       DBMS_AQ.MESSAGE_PROPERTIES_T;

  l_no_more_msgs   EXCEPTION;
  PRAGMA EXCEPTION_INIT(l_no_more_msgs, -25228);

  BEGIN

      -- Set the dequeue mode based on the i/p parameter
      --
      arp_util.print_fcn_label('arp_queue.dequeue()+');
      --

      IF p_browse THEN
	 g_dq_opts.dequeue_mode := DBMS_AQ.BROWSE;
      ELSE
	 g_dq_opts.dequeue_mode := DBMS_AQ.REMOVE;
      END IF;

      IF p_first THEN
         g_dq_opts.navigation    := DBMS_AQ.FIRST_MESSAGE;   --- Get the First available message
      ELSE
         g_dq_opts.navigation    := DBMS_AQ.NEXT_MESSAGE;    --- Get the Next available message
      END IF;

      g_dq_opts.wait          := p_wait;
      g_dq_opts.consumer_name := consumer_name;
      g_dq_opts.visibility    := DBMS_AQ.IMMEDIATE;
      --
      DBMS_AQ.DEQUEUE(
        queue_name         => get_full_qname('AR_REV_REC_Q'),
        dequeue_options    => g_dq_opts,
        message_properties => l_msg_prop,
        payload            => p_msg,
        msgid              => g_msg_id);

      --
      arp_util.print_fcn_label('arp_queue.dequeue()-');
      --
  EXCEPTION
     WHEN l_no_more_msgs THEN
	RAISE;
     WHEN OTHERS THEN
	RAISE;
  END dequeue;
      --
  /*=========================================================================+
   |    Get the full Queue name based on the product schema                  |
   +=========================================================================*/

   FUNCTION get_full_qname(p_qname IN VARCHAR2) RETURN VARCHAR2 AS

   l_schema varchar2(30);
   l_status varchar2(1);
   l_industry varchar2(1);

   BEGIN

      arp_util.print_fcn_label('arp_queue.get_full_qname()+');

      /* Bug 2133254 - Check to see if global is null before
         executing fnd_installation call */

      IF (g_full_qname IS NULL) THEN
         IF (fnd_installation.get_app_info('AR', l_status, l_industry, l_schema)) THEN

            g_full_qname := l_schema||'.'|| p_qname;
         ELSE
            raise_application_error(-20000,
   		       'Failed to get information for product '||
		       'AR');
         END IF;
      END IF;

      --
      arp_util.print_fcn_label('arp_queue.get_full_qname()-');
      --
      RETURN g_full_qname;
   END get_full_qname;

BEGIN
   --
   -- Using the consumers to separate the org specific request from the queue
   --
   --
   arp_util.print_fcn_label('arp_queue()+');
   --
   consumer_name := 'AGENT_' || NVL(arp_global.sysparam.org_id, 0);
   --
   g_recipients(1) := sys.aq$_agent(consumer_name,
		                     null, null) ;
   --
   arp_util.print_fcn_label('arp_queue()-');
   --

END;

/
