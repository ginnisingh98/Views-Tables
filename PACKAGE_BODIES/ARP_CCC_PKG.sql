--------------------------------------------------------
--  DDL for Package Body ARP_CCC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CCC_PKG" AS
/* $Header: ARCUECCB.pls 115.2 2002/11/15 02:27:24 anukumar ship $ */
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
) IS

l_call_rec ar_customer_calls%rowtype;

BEGIN

/*-------------------------------------------------+
|  populate the call record group with the values  |
|  passed as parameters                            |
+-------------------------------------------------*/

        l_call_rec.customer_id  :=p_customer_id;
        l_call_rec.collector_id  :=p_collector_id;
        l_call_rec.call_date  :=p_call_date;
        l_call_rec.site_use_id  :=p_site_use_id;
        l_call_rec.status  :=p_status;
        l_call_rec.promise_date  :=p_promise_date;
        l_call_rec.promise_amount  :=p_promise_amount;
        l_call_rec.call_outcome  :=p_call_outcome;
        l_call_rec.forecast_date  :=p_forecast_date;
        l_call_rec.collection_forecast  :=p_collection_forecast;
        l_call_rec.contact_id  :=p_contact_id;
        l_call_rec.phone_id  :=p_phone_id;
        l_call_rec.fax_id  :=p_fax_id;
        l_call_rec.reason_code  :=p_reason_code;
        l_call_rec.currency_code  :=p_currency_code     ;
        l_call_rec.attribute_category  :=p_attribute_category;
        l_call_rec.attribute1  :=p_attribute1;
        l_call_rec.attribute2  :=p_attribute2;
        l_call_rec.attribute3  :=p_attribute3;
        l_call_rec.attribute4  :=p_attribute4;
        l_call_rec.attribute5  :=p_attribute5;
        l_call_rec.attribute6  :=p_attribute6;
        l_call_rec.attribute7  :=p_attribute7;
        l_call_rec.attribute8  :=p_attribute8;
        l_call_rec.attribute9  :=p_attribute9;
        l_call_rec.attribute10  :=p_attribute10;
        l_call_rec.attribute11  :=p_attribute11;
        l_call_rec.attribute12  :=p_attribute12;
        l_call_rec.attribute13  :=p_attribute13;
        l_call_rec.attribute14  :=p_attribute14;
        l_call_rec.attribute15  :=p_attribute15;
        l_call_rec.follow_up_date := p_follow_up_date;
        l_call_rec.follow_up_action := p_follow_up_action;
        l_call_rec.complete_flag := p_complete_flag;

/*-----------------------------------------+
|  call the standard call entity handler   |
+-----------------------------------------*/

    arp_cce_pkg.insert_call(l_call_rec,p_customer_call_id);

EXCEPTION
 WHEN OTHERS THEN
  RAISE;


END insert_call_cover;


/*------------------------------------------------------------------ +
|  Procedure : insert_note_cover                                     |
|  cover procedure to assign variables to record group and           |
|  call standard enetity handler                                     |
+-------------------------------------------------------------------*/
PROCEDURE insert_note_cover (
                            p_note_type IN ar_notes.note_type%type,
                            p_text IN ar_notes.text%type,
                            p_customer_call_id IN ar_notes.customer_call_id%type,
                            p_customer_call_topic_id IN ar_notes.customer_call_topic_id%type,
                            p_call_action_id IN ar_notes.call_action_id%type,
                            p_note_id OUT NOCOPY ar_notes.note_id%type
) IS

l_note_rec  ar_notes%rowtype;

BEGIN
/*-----------------------------------------+
|  assign the variables to record group    |
+-----------------------------------------*/

l_note_rec.note_type            := p_note_type;
l_note_rec.text                 := p_text;
l_note_rec.customer_call_id     := p_customer_call_id;
l_note_rec.customer_call_topic_id := p_customer_call_topic_id;
l_note_rec.call_action_id       := p_call_action_id;


/*-----------------------------------------+
|  call standard entity handler            |
+-----------------------------------------*/

arp_cce_pkg.insert_note(l_note_rec,p_note_id);


EXCEPTION
WHEN OTHERS THEN
  RAISE;

END insert_note_cover;




PROCEDURE insert_topic_cover (
	p_customer_call_id	IN  ar_customer_call_topics.customer_call_id%type,
        p_customer_id           IN  ar_customer_call_topics.customer_id%type,
        p_collector_id          IN  ar_customer_call_topics.collector_id%type,
        p_call_date             IN  ar_customer_call_topics.call_date%type,
        p_site_use_id           IN  ar_customer_call_topics.site_use_id%type,
        p_payment_schedule_id   IN  ar_customer_call_topics.payment_schedule_id%type,
	p_customer_trx_id	IN  ar_customer_call_topics.customer_trx_id%type,
	p_customer_trx_line_id  IN  ar_customer_call_topics.customer_trx_line_id%type,
        p_cash_receipt_id       IN  ar_customer_call_topics.cash_receipt_id%type,
        p_promise_date          IN  ar_customer_call_topics.promise_date%type,
        p_promise_amount        IN  ar_customer_call_topics.promise_amount%type,
	p_follow_up_date	IN  ar_customer_call_topics.follow_up_date%type,
	p_follow_up_action	IN  ar_customer_call_topics.follow_up_action%type,
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
        p_topic_id              OUT NOCOPY ar_customer_call_topics.customer_call_topic_id%type,
        p_complete_flag         IN  ar_customer_call_topics.complete_flag%type
) IS

 l_topic_rec  ar_customer_call_topics%rowtype;

BEGIN

/*---------------------+
| assign the variables |
+---------------------*/

  l_topic_rec.customer_call_id		:= p_customer_call_id;
  l_topic_rec.customer_id		:= p_customer_id;
  l_topic_rec.collector_id		:= p_collector_id;
  l_topic_rec.call_date			:= p_call_date;
  l_topic_rec.site_use_id		:= p_site_use_id;
  l_topic_rec.payment_schedule_id	:= p_payment_schedule_id;
  l_topic_rec.customer_trx_id		:= p_customer_trx_id;
  l_topic_rec.customer_trx_line_id	:= p_customer_trx_line_id;
  l_topic_rec.cash_receipt_id           := p_cash_receipt_id;
  l_topic_rec.promise_date		:= p_promise_date;
  l_topic_rec.promise_amount		:= p_promise_amount;
  l_topic_rec.follow_up_date		:= p_follow_up_date;
  l_topic_rec.follow_up_action		:= p_follow_up_action;
  l_topic_rec.follow_up_company_rep_id	:= p_follow_up_company_rep_id;
  l_topic_rec.call_outcome		:= p_call_outcome;
  l_topic_rec.forecast_date		:= p_forecast_date;
  l_topic_rec.collection_forecast	:= p_collection_forecast;
  l_topic_rec.contact_id		:= p_contact_id;
  l_topic_rec.phone_id			:= p_phone_id;
  l_topic_rec.reason_code		:= p_reason_code;
  l_topic_rec.attribute_category	:= p_attribute_category;
  l_topic_rec.attribute1		:= p_attribute1;
  l_topic_rec.attribute2                := p_attribute2;
  l_topic_rec.attribute3                := p_attribute3;
  l_topic_rec.attribute4                := p_attribute4;
  l_topic_rec.attribute5                := p_attribute5;
  l_topic_rec.attribute6                := p_attribute6;
  l_topic_rec.attribute7                := p_attribute7;
  l_topic_rec.attribute8                := p_attribute8;
  l_topic_rec.attribute9                := p_attribute9;
  l_topic_rec.attribute10               := p_attribute10;
  l_topic_rec.attribute11               := p_attribute11;
  l_topic_rec.attribute12               := p_attribute12;
  l_topic_rec.attribute13               := p_attribute13;
  l_topic_rec.attribute14               := p_attribute14;
  l_topic_rec.attribute15               := p_attribute15;
  l_topic_rec.complete_flag             := p_complete_flag;

/*-----------------------+
| call the entity handler |
+------------------------*/

  arp_cce_pkg.insert_topic(l_topic_rec,p_topic_id);


EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END insert_topic_cover;


/*--------------------------------------------------------------+
| Cover for AR_CALL_ACTIONS entity handler                      |
+--------------------------------------------------------------*/
PROCEDURE insert_action_cover (
        p_customer_call_id      IN ar_call_actions.customer_call_id%type,
        p_customer_call_topic_id IN ar_call_actions.customer_call_topic_id%type,
        p_action_code           IN ar_call_actions.action_code%type,
        p_action_amount         IN ar_call_actions.action_amount%type,
        p_partial_flag          IN ar_call_actions.partial_invoice_amount_flag%type,
        p_complete_flag         IN ar_call_actions.complete_flag%type,
	p_action_date		IN ar_call_actions.action_date%type,
        p_action_id             IN OUT NOCOPY ar_call_actions.call_action_id%type,
        p_notif_id              IN ar_action_notifications.employee_id%type) IS

l_action_rec    ar_call_actions%rowtype;

BEGIN

/*--------------------------------+
| assign values for record group  |
+--------------------------------*/

  l_action_rec.customer_call_id         := p_customer_call_id;
  l_action_rec.customer_call_topic_id   := p_customer_call_topic_id;
  l_action_rec.action_code              := p_action_code;
  l_action_rec.action_amount            := p_action_amount;
  l_action_rec.partial_invoice_amount_flag := p_partial_flag;
  l_action_rec.complete_flag            := p_complete_flag;
  l_action_rec.action_date		:= p_action_date;

/*---------------------------------+
| call the entity handler          |
+---------------------------------*/

  arp_cce_pkg.insert_action(l_action_rec,p_action_id,p_notif_id);

END insert_action_cover;

PROCEDURE insert_notification_cover (
        p_call_action_id        IN ar_action_notifications.call_action_id%type,
        p_employee_id           IN ar_action_notifications.employee_id%type) IS

l_notification_rec ar_action_notifications%rowtype;

BEGIN

/*--------------------------------+
| assign values for record group  |
+--------------------------------*/

l_notification_rec.call_action_id	:= p_call_action_id;
l_notification_rec.employee_id		:= p_employee_id;


/*---------------------------------+
| call the entity handler          |
+---------------------------------*/

   arp_cce_pkg.insert_notification(l_notification_rec);
END insert_notification_cover;


PROCEDURE update_call_cover (p_status        IN ar_customer_calls.status%type,
                             p_rowid         IN VARCHAR2,
                             p_complete_flag IN ar_customer_calls.complete_flag%type) IS

l_call_rec ar_customer_calls%rowtype;

BEGIN

  l_call_rec.status        := p_status;
  l_call_rec.complete_flag := p_complete_flag;

  arp_cc_pkg.update_p(l_call_rec,p_rowid);

END update_call_cover;




PROCEDURE update_topic_cover  (p_complete_flag IN ar_customer_call_topics.complete_flag%type,
                               p_customer_call_topic_id IN ar_customer_call_topics.customer_call_topic_id%type,
                               p_customer_call_id IN ar_customer_call_topics.customer_call_id%type,
                               p_rowid IN varchar2) IS

l_topic_rec ar_customer_call_topics%rowtype;

BEGIN

l_topic_rec.complete_flag := p_complete_flag;
l_topic_rec.customer_call_topic_id := p_customer_call_topic_id;
l_topic_rec.customer_call_id := p_customer_call_id;

arp_cc_pkg.update_f_topics(l_topic_rec,p_rowid);

END update_topic_cover;





PROCEDURE update_action_cover (p_complete_flag IN ar_call_actions.complete_flag%type,
                               p_call_action_id IN ar_call_actions.call_action_id%type,
                               p_customer_call_id IN ar_call_actions.customer_call_id%type,
                               p_customer_call_topic_id IN ar_call_actions.customer_call_topic_id%type,
                               p_rowid IN varchar2) IS
l_action_rec ar_call_actions%rowtype;

BEGIN

l_action_rec.complete_flag := p_complete_flag;
l_action_rec.call_action_id :=  p_call_action_id;
l_action_rec.customer_call_id := p_customer_call_id;
l_action_rec.customer_call_topic_id := p_customer_call_topic_id;


arp_cc_pkg.update_f_actions(l_action_rec,p_rowid);

END update_action_cover;



END arp_ccc_pkg;

/
