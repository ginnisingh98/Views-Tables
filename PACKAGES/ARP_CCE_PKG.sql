--------------------------------------------------------
--  DDL for Package ARP_CCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CCE_PKG" AUTHID CURRENT_USER AS
/* $Header: ARCEECCS.pls 115.2 2002/11/15 02:15:37 anukumar ship $ */
PROCEDURE insert_call (p_call_rec        IN  ar_customer_calls%rowtype,
                    p_customer_call_id  OUT NOCOPY ar_customer_calls.customer_call_id%type);

PROCEDURE insert_note (p_note_rec IN  ar_notes%rowtype,
                       p_note_id  OUT NOCOPY ar_notes.note_id%type);

PROCEDURE insert_topic (p_topic_rec IN  ar_customer_call_topics%rowtype,
                        p_topic_id  OUT NOCOPY ar_customer_call_topics.customer_call_topic_id%type);

PROCEDURE insert_action(p_action_rec IN ar_call_actions%rowtype,
                        p_action_id IN OUT NOCOPY ar_call_actions.call_action_id%type,
                        p_notif_id IN ar_action_notifications.employee_id%type);

PROCEDURE insert_notification (p_notification_rec IN ar_action_notifications%rowtype);


END arp_cce_pkg;

 

/
