--------------------------------------------------------
--  DDL for Package ARP_CCC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CCC_PKG" AUTHID CURRENT_USER AS
/* $Header: ARCUECCS.pls 115.2 2002/11/15 02:27:35 anukumar ship $ */
PROCEDURE insert_call_cover (
        p_customer_id           IN  ar_customer_calls.customer_id%type,
        p_collector_id          IN  ar_customer_calls.collector_id%type,
        p_call_date             IN  ar_customer_calls.call_date%type,
        p_site_use_id           IN  ar_customer_calls.site_use_id%type,
        p_status                IN  ar_customer_calls.status%type,
        p_promise_date          IN  ar_customer_calls.promise_date%type,
        p_promise_amount        IN  ar_customer_calls.promise_amount%type,
        p_call_outcome          IN  ar_customer_calls.call_outcome%type,
        p_forecast_date         IN  ar_customer_calls.forecast_date%type,
        p_collection_forecast   IN  ar_customer_calls.collection_forecast%type,
        p_contact_id            IN  ar_customer_calls.contact_id%type,
        p_phone_id              IN  ar_customer_calls.phone_id%type,
        p_fax_id                IN  ar_customer_calls.fax_id%type,
        p_reason_code           IN  ar_customer_calls.reason_code%type,
        p_currency_code         IN  ar_customer_calls.currency_code%type,
        p_attribute_category    IN  ar_customer_calls.attribute_category%type,
        p_attribute1            IN  ar_customer_calls.attribute1%type,
        p_attribute2            IN  ar_customer_calls.attribute2%type,
        p_attribute3            IN  ar_customer_calls.attribute3%type,
        p_attribute4            IN  ar_customer_calls.attribute4%type,
        p_attribute5            IN  ar_customer_calls.attribute5%type,
        p_attribute6            IN  ar_customer_calls.attribute6%type,
        p_attribute7            IN  ar_customer_calls.attribute7%type,
        p_attribute8            IN  ar_customer_calls.attribute8%type,
        p_attribute9            IN  ar_customer_calls.attribute9%type,
        p_attribute10           IN  ar_customer_calls.attribute10%type,
        p_attribute11           IN  ar_customer_calls.attribute11%type,
        p_attribute12           IN  ar_customer_calls.attribute12%type,
        p_attribute13           IN  ar_customer_calls.attribute13%type,
        p_attribute14           IN  ar_customer_calls.attribute14%type,
        p_attribute15           IN  ar_customer_calls.attribute15%type,
        p_customer_call_id      OUT NOCOPY ar_customer_calls.customer_call_id%type,
        p_follow_up_date        IN  ar_customer_calls.follow_up_date%type,
        p_follow_up_action      IN  ar_customer_calls.follow_up_action%type,
        p_complete_flag         IN  ar_customer_calls.complete_flag%type
);


PROCEDURE insert_note_cover (
        p_note_type IN ar_notes.note_type%type,
        p_text IN ar_notes.text%type,
        p_customer_call_id IN ar_notes.customer_call_id%type,
        p_customer_call_topic_id IN ar_notes.customer_call_topic_id%type,
        p_call_action_id IN ar_notes.call_action_id%type,
        p_note_id OUT NOCOPY ar_notes.note_id%type);



PROCEDURE insert_topic_cover (
        p_customer_call_id      IN  ar_customer_call_topics.customer_call_id%type,
        p_customer_id           IN  ar_customer_call_topics.customer_id%type,
        p_collector_id          IN  ar_customer_call_topics.collector_id%type,
        p_call_date             IN  ar_customer_call_topics.call_date%type,
        p_site_use_id           IN  ar_customer_call_topics.site_use_id%type,
        p_payment_schedule_id   IN  ar_customer_call_topics.payment_schedule_id%type,
        p_customer_trx_id       IN  ar_customer_call_topics.customer_trx_id%type,
        p_customer_trx_line_id  IN  ar_customer_call_topics.customer_trx_line_id%type,
        p_cash_receipt_id       IN  ar_customer_call_topics.cash_receipt_id%type,
        p_promise_date          IN  ar_customer_call_topics.promise_date%type,
        p_promise_amount        IN  ar_customer_call_topics.promise_amount%type,
        p_follow_up_date        IN  ar_customer_call_topics.follow_up_date%type,
        p_follow_up_action      IN  ar_customer_call_topics.follow_up_action%type,
        p_follow_up_company_rep_id IN ar_customer_call_topics.follow_up_company_rep_id%type,
        p_call_outcome          IN  ar_customer_call_topics.call_outcome%type,
        p_forecast_date         IN  ar_customer_call_topics.forecast_date%type,
        p_collection_forecast   IN  ar_customer_call_topics.collection_forecast%type,
        p_contact_id            IN  ar_customer_call_topics.contact_id%type,
        p_phone_id              IN  ar_customer_call_topics.phone_id%type,
        p_reason_code           IN  ar_customer_call_topics.reason_code%type,
        p_attribute_category    IN  ar_customer_call_topics.attribute_category%type,
        p_attribute1            IN  ar_customer_call_topics.attribute1%type,
        p_attribute2            IN  ar_customer_call_topics.attribute2%type,
        p_attribute3            IN  ar_customer_call_topics.attribute3%type,
        p_attribute4            IN  ar_customer_call_topics.attribute4%type,
        p_attribute5            IN  ar_customer_call_topics.attribute5%type,
        p_attribute6            IN  ar_customer_call_topics.attribute6%type,
        p_attribute7            IN  ar_customer_call_topics.attribute7%type,
        p_attribute8            IN  ar_customer_call_topics.attribute8%type,
        p_attribute9            IN  ar_customer_call_topics.attribute9%type,
        p_attribute10           IN  ar_customer_call_topics.attribute10%type,
        p_attribute11           IN  ar_customer_call_topics.attribute11%type,
        p_attribute12           IN  ar_customer_call_topics.attribute12%type,
        p_attribute13           IN  ar_customer_call_topics.attribute13%type,
        p_attribute14           IN  ar_customer_call_topics.attribute14%type,
        p_attribute15           IN  ar_customer_call_topics.attribute15%type,
        p_topic_id      OUT NOCOPY ar_customer_call_topics.customer_call_topic_id%type,
        p_complete_flag         IN  ar_customer_call_topics.complete_flag%type

);



PROCEDURE insert_action_cover (
	p_customer_call_id	IN ar_call_actions.customer_call_id%type,
	p_customer_call_topic_id IN ar_call_actions.customer_call_topic_id%type,
	p_action_code		IN ar_call_actions.action_code%type,
	p_action_amount		IN ar_call_actions.action_amount%type,
	p_partial_flag		IN ar_call_actions.partial_invoice_amount_flag%type,
	p_complete_flag		IN ar_call_actions.complete_flag%type,
	p_action_date		IN ar_call_actions.action_date%type,
        p_action_id		IN OUT NOCOPY ar_call_actions.call_action_id%type,
        p_notif_id              IN ar_action_notifications.employee_id%type);


PROCEDURE insert_notification_cover (
        p_call_action_id	IN ar_action_notifications.call_action_id%type,
	p_employee_id		IN ar_action_notifications.employee_id%type);


PROCEDURE update_call_cover (p_status        IN ar_customer_calls.status%type,
                             p_rowid         IN VARCHAR2,
                             p_complete_flag IN ar_customer_calls.complete_flag%type
                            );

PROCEDURE update_topic_cover  (p_complete_flag IN ar_customer_call_topics.complete_flag%type,
                               p_customer_call_topic_id IN ar_customer_call_topics.customer_call_topic_id%type,
                               p_customer_call_id IN ar_customer_call_topics.customer_call_id%type,
                               p_rowid IN varchar2);

PROCEDURE update_action_cover (p_complete_flag IN ar_call_actions.complete_flag%type,
                               p_call_action_id IN ar_call_actions.call_action_id%type,
                               p_customer_call_id IN ar_call_actions.customer_call_id%type,
                               p_customer_call_topic_id IN ar_call_actions.customer_call_topic_id%type,
                               p_rowid IN varchar2);


END arp_ccc_pkg;

 

/
