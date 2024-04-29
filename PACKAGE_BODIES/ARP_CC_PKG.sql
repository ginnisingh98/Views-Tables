--------------------------------------------------------
--  DDL for Package Body ARP_CC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CC_PKG" AS
/* $Header: ARCIECCB.pls 120.2 2005/06/14 18:50:21 vcrisost ship $ */
/*-----------------------------------------------------------------------------
|  insert values into ar_customer_calls
+----------------------------------------------------------------------------*/
PROCEDURE insert_p (p_call_rec        IN  ar_customer_calls%rowtype,
                    p_customer_call_id  OUT NOCOPY ar_customer_calls.customer_call_id%type) IS

l_created_by number;
l_creation_date date;
l_last_updated_by number;
l_last_update_login number;
l_last_update_date date;

BEGIN

l_created_by := FND_GLOBAL.USER_ID;
l_creation_date 	:= sysdate;
l_last_update_login	:= FND_GLOBAL.LOGIN_ID;
l_last_update_date	:= sysdate;
l_last_updated_by	:= FND_GLOBAL.USER_ID;

/*-----------------------------+
|  get the unique identifier   |
+-----------------------------*/
p_customer_call_id :='';
SELECT ar_customer_calls_s.nextval
INTO p_customer_call_id
FROM DUAL;

/*-----------------------------+
|  insert the record           |
+-----------------------------*/

INSERT INTO ar_customer_calls
        (customer_call_id,
        customer_id,
        collector_id,
        call_date,
        site_use_id,
        status,
        promise_date,
        promise_amount,
        call_outcome,
        forecast_date,
        collection_forecast,
        contact_id,
        phone_id,
        fax_id,
        reason_code,
        currency_code,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        last_updated_by,
        last_update_date,
        last_update_login,
        created_by,
        creation_date,
        follow_up_date,
        follow_up_action,
        complete_flag,
        org_id)
VALUES
        (p_customer_call_id,
        p_call_rec.customer_id,
        p_call_rec.collector_id,
        p_call_rec.call_date,
        p_call_rec.site_use_id,
        p_call_rec.status,
        p_call_rec.promise_date,
        p_call_rec.promise_amount,
        p_call_rec.call_outcome,
        p_call_rec.forecast_date,
        p_call_rec.collection_forecast,
        p_call_rec.contact_id,
        p_call_rec.phone_id,
        p_call_rec.fax_id,
        p_call_rec.reason_code,
        p_call_rec.currency_code,
        p_call_rec.attribute_category,
        p_call_rec.attribute1,
        p_call_rec.attribute2,
        p_call_rec.attribute3,
        p_call_rec.attribute4,
        p_call_rec.attribute5,
        p_call_rec.attribute6,
        p_call_rec.attribute7,
        p_call_rec.attribute8,
        p_call_rec.attribute9,
        p_call_rec.attribute10,
        p_call_rec.attribute11,
        p_call_rec.attribute12,
        p_call_rec.attribute13,
        p_call_rec.attribute14,
        p_call_rec.attribute15,
        l_last_updated_by,
        l_last_update_date,
        l_last_update_login,
        l_created_by,
        l_creation_date,
        p_call_rec.follow_up_date,
        p_call_rec.follow_up_action,
        p_call_rec.complete_flag,
        arp_standard.sysparm.org_id);

EXCEPTION
WHEN OTHERS THEN
  RAISE;

END insert_p;



/*------------------------------------------------------------------
|  Insert values into ar_notes
+------------------------------------------------------------------*/

PROCEDURE insert_f_notes (
                    p_note_rec        IN  ar_notes%rowtype,
                    p_note_id  OUT NOCOPY ar_notes.note_id%type) IS

l_created_by number;
l_creation_date date;
l_last_updated_by number;
l_last_update_login number;
l_last_update_date date;

BEGIN

l_created_by := FND_GLOBAL.USER_ID;
l_creation_date         := sysdate;
l_last_update_login     := FND_GLOBAL.LOGIN_ID;
l_last_update_date      := sysdate;
l_last_updated_by       := FND_GLOBAL.USER_ID;


/*------------------------------+
|  get the unique id            |
+------------------------------*/
select ar_notes_s.nextval
into p_note_id
from dual;

/*------------------------------+
|  insert the record            |
+------------------------------*/
insert into ar_notes (
  note_id,
  note_type,
  text,
  customer_call_id,
  customer_call_topic_id,
  call_action_id,
  last_updated_by,
  last_update_date,
  last_update_login,
  created_by,
  creation_date)
values (
  p_note_id,
  p_note_rec.note_type,
  p_note_rec.text,
  p_note_rec.customer_call_id,
  p_note_rec.customer_call_topic_id,
  p_note_rec.call_action_id,
  l_last_updated_by,
  l_last_update_date,
  l_last_update_login,
  l_created_by,
  l_creation_date);


EXCEPTION
WHEN OTHERS THEN
  RAISE;

END insert_f_notes;



/* ---------------------------------------------------------------------+
|  Table handler to insert records in the ar_customer_call_topics table |
+----------------------------------------------------------------------*/
PROCEDURE insert_f_topics (p_topic_rec IN ar_customer_call_topics%rowtype,
                           p_topic_id OUT NOCOPY ar_customer_Call_topics.customer_call_topic_id%type) IS

l_created_by number;
l_creation_date date;
l_last_updated_by number;
l_last_update_login number;
l_last_update_date date;

BEGIN

l_created_by 		:= FND_GLOBAL.USER_ID;
l_creation_date         := sysdate;
l_last_update_login     := FND_GLOBAL.LOGIN_ID;
l_last_update_date      := sysdate;
l_last_updated_by       := FND_GLOBAL.USER_ID;


/*-----------------------+
| get the unique id      |
+-----------------------*/
select ar_customer_call_topics_s.nextval
into p_topic_id
from dual;


/*-----------------------+
| insert the row         |
+-----------------------*/
INSERT INTO ar_customer_call_topics (
	customer_call_topic_id,
	last_updated_by,
	last_update_date,
	last_update_login,
	created_by,
	creation_date,
	customer_call_id,
	customer_id,
	collector_id,
	call_date,
	payment_schedule_id,
	customer_trx_id,
	customer_trx_line_id,
        cash_receipt_id,
	promise_date,
	promise_amount,
	follow_up_date,
	follow_up_action,
	follow_up_company_rep_id,
	call_outcome,
	forecast_date,
	collection_forecast,
	reason_code,
	site_use_id,
	contact_id,
	phone_id,
	attribute_category,
	attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        complete_flag,
        org_id)
values (
	p_topic_id,
	l_last_updated_by,
        l_last_update_date,
        l_last_update_login,
        l_created_by,
        l_creation_date,
        p_topic_rec.customer_call_id,
        p_topic_rec.customer_id,
        p_topic_rec.collector_id,
        p_topic_rec.call_date,
        p_topic_rec.payment_schedule_id,
        p_topic_rec.customer_trx_id,
        p_topic_rec.customer_trx_line_id,
        p_topic_rec.cash_receipt_id,
        p_topic_rec.promise_date,
        p_topic_rec.promise_amount,
        p_topic_rec.follow_up_date,
        p_topic_rec.follow_up_action,
        p_topic_rec.follow_up_company_rep_id,
        p_topic_rec.call_outcome,
        p_topic_rec.forecast_date,
        p_topic_rec.collection_forecast,
        p_topic_rec.reason_code,
        p_topic_rec.site_use_id,
        p_topic_rec.contact_id,
        p_topic_rec.phone_id,
        p_topic_rec.attribute_category,
        p_topic_rec.attribute1,
        p_topic_rec.attribute2,
        p_topic_rec.attribute3,
        p_topic_rec.attribute4,
        p_topic_rec.attribute5,
        p_topic_rec.attribute6,
        p_topic_rec.attribute7,
        p_topic_rec.attribute8,
        p_topic_rec.attribute9,
        p_topic_rec.attribute10,
        p_topic_rec.attribute11,
        p_topic_rec.attribute12,
        p_topic_rec.attribute13,
        p_topic_rec.attribute14,
        p_topic_rec.attribute15,
        p_topic_rec.complete_flag,
        arp_standard.sysparm.org_id)
;



EXCEPTION
WHEN OTHERS THEN
  RAISE;

END insert_f_topics;


/*---------------------------------------------------------------+
|  Insert row into ar_call_actions                               |
+---------------------------------------------------------------*/
PROCEDURE insert_f_actions (p_action_rec IN ar_call_actions%rowtype,
                            p_action_id OUT NOCOPY ar_call_actions.call_action_id%type) IS



l_created_by number;
l_creation_date date;
l_last_updated_by number;
l_last_update_login number;
l_last_update_date date;

BEGIN

l_created_by            := FND_GLOBAL.USER_ID;
l_creation_date         := sysdate;
l_last_update_login     := FND_GLOBAL.LOGIN_ID;
l_last_update_date      := sysdate;
l_last_updated_by       := FND_GLOBAL.USER_ID;

/*--------------------------+
| get unique identifier     |
+--------------------------*/
select ar_call_actions_s.nextval
into p_action_id
from dual;

/*--------------------------+
| insert the row            |
+--------------------------*/
insert into ar_call_actions (
	call_action_id,
	last_updated_by,
	last_update_date,
	last_update_login,
	created_by,
	creation_date,
	customer_call_id,
	customer_call_topic_id,
	action_code,
	action_amount,
	partial_invoice_amount_flag,
	complete_flag,
        action_date)
values (
	p_action_id,
	l_last_updated_by,
        l_last_update_date,
        l_last_update_login,
        l_created_by,
        l_creation_date,
	p_action_rec.customer_call_id,
        p_action_rec.customer_call_topic_id,
        p_action_rec.action_code,
        p_action_rec.action_amount,
        p_action_rec.partial_invoice_amount_flag,
        p_action_rec.complete_flag,
        p_action_rec.action_date);


END insert_f_actions;






PROCEDURE insert_f_notifications (p_notification_rec IN ar_action_notifications
%rowtype) IS
l_notif_id ar_action_notifications.action_notification_id%type;

l_created_by number;
l_creation_date date;
l_last_updated_by number;
l_last_update_login number;
l_last_update_date date;

BEGIN

l_created_by            := FND_GLOBAL.USER_ID;
l_creation_date         := sysdate;
l_last_update_login     := FND_GLOBAL.LOGIN_ID;
l_last_update_date      := sysdate;
l_last_updated_by       := FND_GLOBAL.USER_ID;


/*------------------------+
| insert the unique id    |
+-------------------------*/
select ar_action_notifications_s.nextval
into l_notif_id
from dual;

/*------------------------+\
| insert the row          |
+-------------------------*/

insert into ar_action_notifications
(action_notification_id,
last_updated_by,
last_update_date,
last_update_login,
created_by,
creation_date,
call_action_id,
employee_id)
values
( l_notif_id,
l_last_updated_by,
l_last_update_date,
l_last_update_login,
l_created_by,
l_creation_date,
p_notification_rec.call_action_id,
p_notification_rec.employee_id);

EXCEPTION
WHEN OTHERS THEN
  RAISE;


END insert_f_notifications;




/*------------------------------------------------+
| Update status of Customer Call                  |
+------------------------------------------------*/
PROCEDURE update_p (p_call_rec IN ar_customer_calls%rowtype, p_rowid IN VARCHAR2) IS

l_last_updated_by number;
l_last_update_login number;
l_last_update_date date;

BEGIN

l_last_update_login     := FND_GLOBAL.LOGIN_ID;
l_last_update_date      := sysdate;
l_last_updated_by       := FND_GLOBAL.USER_ID;


  update ar_customer_calls
  set    status            = p_call_rec.status,
         last_update_login = l_last_update_login,
         last_update_date  = l_last_update_date,
         last_updated_by   = l_last_updated_by,
         complete_flag     = p_call_rec.complete_flag
  where  rowid = p_rowid;

END update_p;



/*------------------------------------------+
| Update complete flag in AR_CUSTOMER_CALL_TOPICS |
+------------------------------------------------*/
PROCEDURE update_f_topics (p_topic_rec ar_customer_call_topics%rowtype, p_rowid IN rowid) IS

cursor c1 is
select customer_call_id
from ar_customer_calls
where customer_call_id = p_topic_rec.customer_call_id
for update of customer_call_id NOWAIT;

l_last_updated_by number;
l_last_update_login number;
l_last_update_date date;

BEGIN

l_last_update_login     := FND_GLOBAL.LOGIN_ID;
l_last_update_date      := sysdate;
l_last_updated_by       := FND_GLOBAL.USER_ID;

open c1;

  update ar_customer_call_topics
  set complete_flag = p_topic_rec.complete_flag,
  last_updated_by = l_last_updated_by,
  last_update_date = l_last_update_date,
  last_update_login = l_last_update_login
  where rowid = p_rowid;

close c1;

EXCEPTION
WHEN OTHERS THEN
  RAISE;

END update_f_topics;

/*----------------------------------------+
| Update complete flag in AR_CALL_ACTIONS |
+----------------------------------------*/
PROCEDURE update_f_actions (p_action_rec ar_call_actions%rowtype, p_rowid IN rowid) IS

cursor c1 is
select customer_call_id
from ar_customer_calls
where customer_call_id = p_action_rec.customer_call_id
for update of customer_call_id NOWAIT;

cursor c2 is
select customer_call_topic_id
from ar_customer_call_topics
where customer_call_topic_id = p_action_rec.customer_call_topic_id
for update of customer_call_topic_id NOWAIT;

l_last_updated_by number;
l_last_update_login number;
l_last_update_date date;

BEGIN

l_last_update_login     := FND_GLOBAL.LOGIN_ID;
l_last_update_date      := sysdate;
l_last_updated_by       := FND_GLOBAL.USER_ID;

open c1;
open c2;

  update ar_call_actions
  set complete_flag = p_action_rec.complete_flag,
  last_updated_by = l_last_updated_by,
  last_update_date = l_last_update_date,
  last_update_login = l_last_update_login
  where rowid = p_rowid;

close c1;
close c2;

EXCEPTION
WHEN OTHERS THEN
  RAISE;

END update_f_actions;


FUNCTION check_dunning RETURN BOOLEAN IS
l_id number;

BEGIN

Select call_action_id
into l_id
from ar_call_actions
where call_action_id in (select call_action_id
                             from ar_call_actions
                             where customer_call_id = 1049
                             and action_code = 'XDUNNING')
or customer_call_topic_id in (select aca.customer_call_topic_id
                         from ar_call_actions aca, ar_customer_call_topics cct
                         where action_code = 'XDUNNING'
                         and aca.customer_call_topic_id = cct.customer_call_topic_id
                         and cct.customer_call_id = 1049);

return true;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return false;
  WHEN TOO_MANY_ROWS THEN
    return true;
  WHEN OTHERS THEN
    RAISE;

END check_dunning;


END arp_cc_pkg;

/
