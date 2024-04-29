--------------------------------------------------------
--  DDL for Package Body ARP_CCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CCE_PKG" AS
/*$Header: ARCEECCB.pls 115.2 2002/11/15 02:15:26 anukumar ship $*/
PROCEDURE insert_call (p_call_rec        IN  ar_customer_calls%rowtype,
                    p_customer_call_id  OUT NOCOPY ar_customer_calls.customer_call_id%type) IS

BEGIN

arp_cc_pkg.insert_p(p_call_rec,p_customer_call_id);


EXCEPTION
WHEN OTHERS THEN
   RAISE;
END insert_call;


/*--------------------------------------------------------------+
|  Entity Handler  AR_NOTES                                     |
+--------------------------------------------------------------*/
PROCEDURE insert_note (p_note_rec IN  ar_notes%rowtype,
                       p_note_id  OUT NOCOPY ar_notes.note_id%type) IS

BEGIN

arp_cc_pkg.insert_f_notes(p_note_rec,p_note_id);


EXCEPTION
WHEN OTHERS THEN
   RAISE;
END insert_note;



/*--------------------------------------------------------------+
|  Entity Handler  AR_CUSTOMER_CALL_TOPICS                      |
+--------------------------------------------------------------*/
PROCEDURE insert_topic (p_topic_rec IN  ar_customer_call_topics%rowtype,
                        p_topic_id  OUT NOCOPY ar_customer_call_topics.customer_call_topic_id%type) IS

BEGIN

arp_cc_pkg.insert_f_topics(p_topic_rec,p_topic_id);


EXCEPTION
WHEN OTHERS THEN
   RAISE;
END insert_topic;


/*-------------------------------------------------------------+
| Entity handler  AR_CALL_ACTIONS                              |
+-------------------------------------------------------------*/
PROCEDURE insert_action(p_action_rec IN ar_call_actions%rowtype,
                        p_action_id IN OUT NOCOPY ar_call_actions.call_action_id%type,
                        p_notif_id IN ar_action_notifications.employee_id%type) IS

BEGIN

  arp_cc_pkg.insert_f_actions(p_action_rec, p_action_id);

  IF p_action_rec.action_code = 'XDUNNING' THEN
     /* update customer or site profile */
    null;
  END IF;


  IF p_notif_id IS NOT NULL THEN
   arp_ccc_pkg.insert_notification_cover(p_action_id,p_notif_id);
  END IF;


EXCEPTION
WHEN OTHERS THEN
  RAISE;

END insert_action;


/*-------------------------------------------------------------+
| Entity handler  AR_ACTION_NOTIFICATION                       |
+-------------------------------------------------------------*/
PROCEDURE insert_notification (p_notification_rec IN ar_action_notifications%rowtype) IS
BEGIN

 arp_cc_pkg.insert_f_notifications(p_notification_rec);

EXCEPTION
WHEN OTHERS THEN
  RAISE;

END insert_notification;
END arp_cce_pkg;

/
