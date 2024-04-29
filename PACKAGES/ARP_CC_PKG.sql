--------------------------------------------------------
--  DDL for Package ARP_CC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CC_PKG" AUTHID CURRENT_USER AS
/* $Header: ARCIECCS.pls 115.2 2002/11/15 02:18:13 anukumar ship $ */

PROCEDURE insert_p (p_call_rec        IN  ar_customer_calls%rowtype,
                    p_customer_call_id  OUT NOCOPY ar_customer_calls.customer_call_id%type);

PROCEDURE insert_f_notes (p_note_rec        IN  ar_notes%rowtype,
                          p_note_id  OUT NOCOPY ar_notes.note_id%type);

PROCEDURE insert_f_topics (p_topic_rec IN ar_customer_call_topics%rowtype,
                           p_topic_id OUT NOCOPY ar_customer_call_topics.customer_call_topic_id%type);

PROCEDURE insert_f_actions (p_action_rec IN ar_call_actions%rowtype,
                            p_action_id OUT NOCOPY ar_call_actions.call_action_id%type);

PROCEDURE insert_f_notifications (p_notification_rec IN ar_action_notifications%rowtype);

PROCEDURE update_p (p_call_rec IN ar_customer_calls%rowtype, p_rowid IN VARCHAR2
);

PROCEDURE update_f_topics (p_topic_rec ar_customer_call_topics%rowtype, p_rowid IN rowid);

PROCEDURE update_f_actions (p_action_rec ar_call_actions%rowtype, p_rowid IN rowid);

FUNCTION check_dunning RETURN BOOLEAN;

END arp_cc_pkg;

 

/
