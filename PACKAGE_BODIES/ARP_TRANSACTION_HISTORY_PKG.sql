--------------------------------------------------------
--  DDL for Package Body ARP_TRANSACTION_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_TRANSACTION_HISTORY_PKG" AS
/*$Header: ARRITRHB.pls 120.8 2005/08/10 23:14:24 hyu ship $*/

/*--------------------------------------------------------+
 |  Dummy constants for use in update and lock operations |
 +--------------------------------------------------------*/

  AR_TEXT_DUMMY   CONSTANT VARCHAR2(10) := '~~!@#$*&^';
  AR_FLAG_DUMMY   CONSTANT VARCHAR2(10) := '~';
  AR_NUMBER_DUMMY CONSTANT NUMBER(15)   := -999999999999999;
  AR_DATE_DUMMY   CONSTANT DATE         := to_date(1, 'J');

/*-------------------------------------+
 |  WHO column values from ARP_GLOBAL  |
 +-------------------------------------*/

  pg_request_id                 number;
  pg_program_application_id     number;
  pg_program_id                 number;
  pg_program_update_date        date;
  pg_last_updated_by            number;
  pg_last_update_date           date;
  pg_last_update_login          number;
  pg_set_of_books_id            number;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    set_to_dummy                                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |  Returns transaction history record with values set to dummy values       |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN: NONE                                                     |
 |              OUT: p_trh_rec Transaction history record                    |
 | RETURNS    :                                                              |
 | NOTES                                                                     |
 | MODIFICATION HISTORY - Created by Jani Rautiainen - 18-JAN-2000           |
 |                                                                           |
 +===========================================================================*/
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE set_to_dummy( p_trh_rec OUT NOCOPY AR_TRANSACTION_HISTORY%ROWTYPE ) IS
BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'ARP_TRANSACTION_HISTORY_PKG.set_to_dummy()+' );
    END IF;

    p_trh_rec.customer_trx_id := AR_NUMBER_DUMMY;
    p_trh_rec.status := AR_TEXT_DUMMY;
    p_trh_rec.event := AR_TEXT_DUMMY;
    p_trh_rec.batch_id := AR_NUMBER_DUMMY;
    p_trh_rec.trx_date := AR_DATE_DUMMY;
    p_trh_rec.gl_date := AR_DATE_DUMMY;
    p_trh_rec.maturity_date := AR_DATE_DUMMY;
    p_trh_rec.current_record_flag := AR_FLAG_DUMMY;
    p_trh_rec.current_accounted_flag := AR_FLAG_DUMMY;
    p_trh_rec.postable_flag := AR_FLAG_DUMMY;
    p_trh_rec.first_posted_record_flag  := AR_FLAG_DUMMY;
    p_trh_rec.posting_control_id := AR_NUMBER_DUMMY;
    p_trh_rec.gl_posted_date := AR_DATE_DUMMY;
    p_trh_rec.prv_trx_history_id := AR_NUMBER_DUMMY;
    p_trh_rec.created_from := AR_TEXT_DUMMY;
    p_trh_rec.comments := AR_TEXT_DUMMY;
    p_trh_rec.attribute_category := AR_TEXT_DUMMY;
    p_trh_rec.attribute1 := AR_TEXT_DUMMY;
    p_trh_rec.attribute2 := AR_TEXT_DUMMY;
    p_trh_rec.attribute3 := AR_TEXT_DUMMY;
    p_trh_rec.attribute4 := AR_TEXT_DUMMY;
    p_trh_rec.attribute5 := AR_TEXT_DUMMY;
    p_trh_rec.attribute6 := AR_TEXT_DUMMY;
    p_trh_rec.attribute7 := AR_TEXT_DUMMY;
    p_trh_rec.attribute8 := AR_TEXT_DUMMY;
    p_trh_rec.attribute9 := AR_TEXT_DUMMY;
    p_trh_rec.attribute10 := AR_TEXT_DUMMY;
    p_trh_rec.attribute11 := AR_TEXT_DUMMY;
    p_trh_rec.attribute12 := AR_TEXT_DUMMY;
    p_trh_rec.attribute13 := AR_TEXT_DUMMY;
    p_trh_rec.attribute14 := AR_TEXT_DUMMY;
    p_trh_rec.attribute15 := AR_TEXT_DUMMY;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'ARP_TRANSACTION_HISTORY_PKG.set_to_dummy()-' );
    END IF;

    EXCEPTION
        WHEN  OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug( 'EXCEPTION: ARP_TRANSACTION_HISTORY_PKG.set_to_dummy' );
            END IF;
            RAISE;
END set_to_dummy;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_p                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |  Updates transaction history record in DB with values given in the        |
 |  parameter transaction record.                                            |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN: p_trh_rec Transaction history record                     |
 |                  p_trh_id  Transaction history id                         |
 |              OUT: NONE                                                    |
 | RETURNS    :                                                              |
 | NOTES                                                                     |
 | MODIFICATION HISTORY - Created by Jani Rautiainen - 18-JAN-2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE update_p( p_trh_rec    IN  AR_TRANSACTION_HISTORY%ROWTYPE,
                    p_trh_id     IN AR_TRANSACTION_HISTORY.transaction_history_id%TYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'ARP_TRANSACTION_HISTORY_PKG.update_p()+' );
    END IF;

    UPDATE AR_TRANSACTION_HISTORY SET
                   customer_trx_id =
                           DECODE( p_trh_rec.customer_trx_id,
                                   AR_NUMBER_DUMMY, customer_trx_id,
                                   p_trh_rec.customer_trx_id ),
                   status =
                           DECODE( p_trh_rec.status,
                                   AR_TEXT_DUMMY, status,
                                   p_trh_rec.status ),
                   event =
                           DECODE( p_trh_rec.event,
                                   AR_TEXT_DUMMY, event,
                                   p_trh_rec.event ),
                   batch_id =
                           DECODE( p_trh_rec.batch_id,
                                   AR_NUMBER_DUMMY, batch_id,
                                   p_trh_rec.batch_id ),
                   trx_date =
                           DECODE( p_trh_rec.trx_date,
                                   AR_DATE_DUMMY, trx_date,
                                   p_trh_rec.trx_date ),
                   gl_date =
                           DECODE( p_trh_rec.gl_date,
                                   AR_DATE_DUMMY, gl_date,
                                   p_trh_rec.gl_date ),
                   maturity_date =
                           DECODE( p_trh_rec.maturity_date,
                                   AR_DATE_DUMMY, maturity_date,
                                   p_trh_rec.maturity_date),
                   current_record_flag =
                           DECODE( p_trh_rec.current_record_flag,
                                   AR_FLAG_DUMMY, current_record_flag,
                                   p_trh_rec.current_record_flag ),
                   current_accounted_flag =
                           DECODE( p_trh_rec.current_accounted_flag,
                                   AR_FLAG_DUMMY, current_accounted_flag,
                                   p_trh_rec.current_accounted_flag ),
                   postable_flag =
                           DECODE( p_trh_rec.postable_flag,
                                   AR_FLAG_DUMMY, postable_flag,
                                   p_trh_rec.postable_flag ),
                   first_posted_record_flag =
                           DECODE( p_trh_rec.first_posted_record_flag,
                                   AR_FLAG_DUMMY, first_posted_record_flag,
                                   p_trh_rec.first_posted_record_flag ),
                   posting_control_id =
                           DECODE( p_trh_rec.posting_control_id,
                                   AR_NUMBER_DUMMY, posting_control_id,
                                   p_trh_rec.posting_control_id ),
                   gl_posted_date =
                           DECODE( p_trh_rec.gl_posted_date,
                                   AR_DATE_DUMMY, gl_posted_date,
                                   p_trh_rec.gl_posted_date ),
                   prv_trx_history_id =
                           DECODE( p_trh_rec.prv_trx_history_id,
                                   AR_NUMBER_DUMMY, prv_trx_history_id,
                                   p_trh_rec.prv_trx_history_id ),
                   created_from =
                           DECODE( p_trh_rec.created_from,
                                   AR_TEXT_DUMMY, created_from,
                                   p_trh_rec.created_from ),
                   comments =
                           DECODE( p_trh_rec.comments,
                                   AR_TEXT_DUMMY, comments,
                                   p_trh_rec.comments ),
                   attribute_category =
                           DECODE( p_trh_rec.attribute_category,
                                   AR_TEXT_DUMMY, attribute_category,
                                   p_trh_rec.attribute_category ),
                   attribute1 =
                           DECODE( p_trh_rec.attribute1,
                                   AR_TEXT_DUMMY, attribute1,
                                   p_trh_rec.attribute1 ),
                   attribute2 =
                           DECODE( p_trh_rec.attribute2,
                                   AR_TEXT_DUMMY, attribute2,
                                   p_trh_rec.attribute2 ),
                   attribute3 =
                           DECODE( p_trh_rec.attribute3,
                                   AR_TEXT_DUMMY, attribute3,
                                   p_trh_rec.attribute3 ),
                   attribute4 =
                           DECODE( p_trh_rec.attribute4,
                                   AR_TEXT_DUMMY, attribute4,
                                   p_trh_rec.attribute4 ),
                   attribute5 =
                           DECODE( p_trh_rec.attribute5,
                                   AR_TEXT_DUMMY, attribute5,
                                   p_trh_rec.attribute5 ),
                   attribute6 =
                           DECODE( p_trh_rec.attribute6,
                                   AR_TEXT_DUMMY, attribute6,
                                   p_trh_rec.attribute6 ),
                   attribute7 =
                           DECODE( p_trh_rec.attribute7,
                                   AR_TEXT_DUMMY, attribute7,
                                   p_trh_rec.attribute7 ),
                   attribute8 =
                           DECODE( p_trh_rec.attribute8,
                                   AR_TEXT_DUMMY, attribute8,
                                   p_trh_rec.attribute8 ),
                   attribute9 =
                           DECODE( p_trh_rec.attribute9,
                                   AR_TEXT_DUMMY, attribute9,
                                   p_trh_rec.attribute9 ),
                   attribute10 =
                           DECODE( p_trh_rec.attribute10,
                                   AR_TEXT_DUMMY, attribute10,
                                   p_trh_rec.attribute10 ),
                   attribute11 =
                           DECODE( p_trh_rec.attribute11,
                                   AR_TEXT_DUMMY, attribute11,
                                   p_trh_rec.attribute11 ),
                   attribute12 =
                           DECODE( p_trh_rec.attribute12,
                                   AR_TEXT_DUMMY, attribute12,
                                   p_trh_rec.attribute12 ),
                   attribute13 =
                           DECODE( p_trh_rec.attribute13,
                                   AR_TEXT_DUMMY, attribute13,
                                   p_trh_rec.attribute13 ),
                   attribute14 =
                           DECODE( p_trh_rec.attribute14,
                                   AR_TEXT_DUMMY, attribute14,
                                   p_trh_rec.attribute14 ),
                   attribute15 =
                           DECODE( p_trh_rec.attribute15,
                                   AR_TEXT_DUMMY, attribute15,
                                   p_trh_rec.attribute15 ),
                   program_application_id = pg_program_application_id,
                   program_id = pg_program_id,
                   program_update_date = pg_program_update_date,
                   request_id = pg_request_id,
                   last_update_login = pg_last_update_login,
                   last_update_date = pg_last_update_date,
                   last_updated_by = pg_last_updated_by

    WHERE transaction_history_id = p_trh_id;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'ARP_TRANSACTION_HISTORY_PKG.update_p()-' );
    END IF;

    EXCEPTION
        WHEN  OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug(   'EXCEPTION: ARP_TRANSACTION_HISTORY_PKG.update_p' );
            END IF;
            RAISE;
END update_p;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_p                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |  Creates transaction history record in DB with values given in the        |
 |  parameter transaction record. Returns the transaction_history_id of the  |
 |  record that was created.                                                 |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN: p_trh_rec Transaction history record                     |
 |              OUT: p_trh_id  Transaction history id                        |
 | RETURNS    :                                                              |
 | NOTES                                                                     |
 | MODIFICATION HISTORY - Created by Jani Rautiainen - 18-JAN-2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE insert_p(p_trh_rec IN AR_TRANSACTION_HISTORY%ROWTYPE,
                   p_trh_id  OUT NOCOPY AR_TRANSACTION_HISTORY.transaction_history_id%TYPE ) IS

  l_trh_id AR_TRANSACTION_HISTORY.transaction_history_id%TYPE;
BEGIN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug(   'ARP_TRANSACTION_HISTORY_PKG.insert_p()+' );
      END IF;

      SELECT AR_TRANSACTION_HISTORY_s.nextval
      INTO   l_trh_id
      FROM   dual;

      INSERT INTO  AR_TRANSACTION_HISTORY (
                   transaction_history_id,
                   customer_trx_id,
                   status,
                   event,
                   batch_id,
                   trx_date,
                   gl_date,
                   maturity_date,
                   current_record_flag,
                   current_accounted_flag,
                   postable_flag,
                   first_posted_record_flag,
                   posting_control_id,
                   gl_posted_date,
                   prv_trx_history_id,
                   created_from,
                   comments,
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
                   program_application_id,
                   program_id,
                   program_update_date,
                   request_id,
                   creation_date,
                   created_by,
                   last_update_login,
                   last_update_date,
                   last_updated_by
                   ,org_id)
       VALUES (    l_trh_id,
                   p_trh_rec.customer_trx_id,
                   p_trh_rec.status,
                   p_trh_rec.event,
                   p_trh_rec.batch_id,
                   p_trh_rec.trx_date,
                   p_trh_rec.gl_date,
                   p_trh_rec.maturity_date,
                   p_trh_rec.current_record_flag,
                   p_trh_rec.current_accounted_flag,
                   p_trh_rec.postable_flag,
                   p_trh_rec.first_posted_record_flag,
                   p_trh_rec.posting_control_id,
                   p_trh_rec.gl_posted_date,
                   p_trh_rec.prv_trx_history_id,
                   p_trh_rec.created_from,
                   p_trh_rec.comments,
                   p_trh_rec.attribute_category,
                   p_trh_rec.attribute1,
                   p_trh_rec.attribute2,
                   p_trh_rec.attribute3,
                   p_trh_rec.attribute4,
                   p_trh_rec.attribute5,
                   p_trh_rec.attribute6,
                   p_trh_rec.attribute7,
                   p_trh_rec.attribute8,
                   p_trh_rec.attribute9,
                   p_trh_rec.attribute10,
                   p_trh_rec.attribute11,
                   p_trh_rec.attribute12,
                   p_trh_rec.attribute13,
                   p_trh_rec.attribute14,
                   p_trh_rec.attribute15,
 		   NVL( arp_standard.profile.program_application_id,p_trh_rec.program_application_id ),
 		   NVL( arp_standard.profile.program_id,p_trh_rec.program_id ),
		   DECODE( arp_standard.profile.program_id,NULL, NULL, SYSDATE),
 		   NVL( arp_standard.profile.request_id, p_trh_rec.request_id ),
 		   SYSDATE,
		   arp_standard.profile.user_id,
		   NVL( arp_standard.profile.last_update_login,p_trh_rec.last_update_login ),
 		   SYSDATE,
		   arp_standard.profile.user_id
                   ,arp_standard.sysparm.org_id /* SSA changes anuj */);

    p_trh_id := l_trh_id;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'ARP_TRANSACTION_HISTORY_PKG.insert_p()-' );
    END IF;

    EXCEPTION
	WHEN  OTHERS THEN
	    IF PG_DEBUG in ('Y', 'C') THEN
	       arp_standard.debug(   'EXCEPTION: ARP_TRANSACTION_HISTORY_PKG.insert_p' );
	    END IF;
	    RAISE;
END insert_p;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_p                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |  Deletes transaction history record from DB related to the transaction    |
 |  history id given as parameter                                            |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN: p_trh_id  Transaction history id                         |
 |              OUT: NONE                                                    |
 | RETURNS    :                                                              |
 | NOTES                                                                     |
 | MODIFICATION HISTORY - Created by Jani Rautiainen - 18-JAN-2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE delete_p(p_trh_id IN AR_TRANSACTION_HISTORY.transaction_history_id%TYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'ARP_TRANSACTION_HISTORY_PKG.delete_p()+' );
    END IF;

    DELETE FROM AR_TRANSACTION_HISTORY
    WHERE transaction_history_id = p_trh_id;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'ARP_TRANSACTION_HISTORY_PKG.delete_p()-' );
    END IF;
    EXCEPTION
        WHEN  OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug(   'EXCEPTION: ARP_TRANSACTION_HISTORY_PKG.delete_p' );
            END IF;
            RAISE;
END delete_p;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_p                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |  Deletes all transaction history records from DB related to the           |
 |  transaction id given as parameter.                                       |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN: p_trx_id  Transaction id                                 |
 |              OUT: NONE                                                    |
 | RETURNS    :                                                              |
 | NOTES                                                                     |
 | MODIFICATION HISTORY - Created by Jani Rautiainen - 18-JAN-2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE delete_p(p_trx_id IN ra_customer_trx.customer_trx_id%TYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'ARP_TRANSACTION_HISTORY_PKG.delete_p()+' );
    END IF;

    DELETE FROM AR_TRANSACTION_HISTORY
    WHERE customer_trx_id = p_trx_id;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'ARP_TRANSACTION_HISTORY_PKG.delete_p()-' );
    END IF;
    EXCEPTION
        WHEN  OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug(   'EXCEPTION: ARP_TRANSACTION_HISTORY_PKG.delete_p' );
            END IF;
            RAISE;
END delete_p;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_p                                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |  Locks transaction history record in DB related to the transaction        |
 |  history id given as parameter. If the row  is already locked this        |
 |  procedure will wait for it to be released.                               |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN: p_trh_id  Transaction history id                         |
 |              OUT: NONE                                                    |
 | RETURNS    :                                                              |
 | NOTES                                                                     |
 | MODIFICATION HISTORY - Created by Jani Rautiainen - 18-JAN-2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE lock_p(p_trh_id IN AR_TRANSACTION_HISTORY.transaction_history_id%TYPE ) IS
  l_trh_id AR_TRANSACTION_HISTORY.transaction_history_id%TYPE;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'ARP_TRANSACTION_HISTORY_PKG.lock_p()+' );
    END IF;

    SELECT transaction_history_id
    INTO   l_trh_id
    FROM  AR_TRANSACTION_HISTORY
    WHERE transaction_history_id = p_trh_id
    FOR UPDATE OF STATUS;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'ARP_TRANSACTION_HISTORY_PKG.lock_p()-' );
    END IF;
    EXCEPTION
        WHEN  OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug(   'EXCEPTION: ARP_TRANSACTION_HISTORY_PKG.lock_p' );
            END IF;
            RAISE;
END lock_p;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    nowaitlock_p                                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |  Locks transaction history record in DB related to the transaction        |
 |  history id given as parameter. If the row  is already locked this        |
 |  procedure will return an error.                                          |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN: p_trh_id  Transaction history id                         |
 |              OUT: NONE                                                    |
 | RETURNS    :                                                              |
 | NOTES                                                                     |
 | MODIFICATION HISTORY - Created by Jani Rautiainen - 18-JAN-2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE nowaitlock_p( p_trh_id IN AR_TRANSACTION_HISTORY.transaction_history_id%TYPE ) IS
  l_trh_id AR_TRANSACTION_HISTORY.transaction_history_id%TYPE;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'ARP_TRANSACTION_HISTORY_PKG.nowaitlock_p()+' );
    END IF;

    SELECT transaction_history_id
    INTO   l_trh_id
    FROM  AR_TRANSACTION_HISTORY
    WHERE transaction_history_id = p_trh_id
    FOR UPDATE OF status NOWAIT;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'ARP_TRANSACTION_HISTORY_PKG.nowaitlock_p()-' );
    END IF;
    EXCEPTION
        WHEN  OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug(   'EXCEPTION: ARP_TRANSACTION_HISTORY_PKG.nowaitlock_p' );
            END IF;
            RAISE;
END nowaitlock_p;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    fetch_p                                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |  Fetches the transaction history record from DB related to transaction    |
 |  history id given as parameter.
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN: p_trh_id  Transaction history id                         |
 |              OUT: p_trh_rec Transaction history record                    |
 | RETURNS    :                                                              |
 | NOTES                                                                     |
 | MODIFICATION HISTORY - Created by Jani Rautiainen - 18-JAN-2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE fetch_p( p_trh_id IN AR_TRANSACTION_HISTORY.transaction_history_id%TYPE,
                   p_trh_rec OUT NOCOPY AR_TRANSACTION_HISTORY%ROWTYPE ) IS
BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'ARP_TRANSACTION_HISTORY_PKG.fetch_p()+' );
    END IF;

    SELECT *
    INTO   p_trh_rec
    FROM   AR_TRANSACTION_HISTORY
    WHERE  transaction_history_id = p_trh_id;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'ARP_TRANSACTION_HISTORY_PKG.fetch_p()-' );
    END IF;

    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug(   'EXCEPTION: ARP_TRANSACTION_HISTORY_PKG.fetch_p' );
              END IF;
              RAISE;
END fetch_p;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    fetch_f_trx_id                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |  Fetches the current transaction history record from DB related to        |
 |  transaction id given in record parameter.                                |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN: p_trh_rec Transaction history record                     |
 |              OUT: p_trh_rec Transaction history record                    |
 | RETURNS    :                                                              |
 | NOTES                                                                     |
 | MODIFICATION HISTORY - Created by Jani Rautiainen - 18-JAN-2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE fetch_f_trx_id( p_trh_rec IN OUT NOCOPY AR_TRANSACTION_HISTORY%ROWTYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'ARP_TRANSACTION_HISTORY_PKG.fetch_f_trx_id()+' );
    END IF;

    SELECT *
    INTO   p_trh_rec
    FROM   AR_TRANSACTION_HISTORY
    WHERE  customer_trx_id = p_trh_rec.customer_trx_id AND
           current_record_flag = 'Y';

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'ARP_TRANSACTION_HISTORY_PKG.fetch_f_trx_id()-' );
    END IF;

    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug(   'EXCEPTION: ARP_TRANSACTION_HISTORY_PKG.fetch_f_trx_id' );
              END IF;
              RAISE;
END fetch_f_trx_id;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_fetch_p                                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |  Locks and fetches the transaction history record from DB related to      |
 |  transaction history id given in record parameter. If the row  is already |
 |  locked this procedure will wait for it to be released.                   |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN: p_trh_rec Transaction history record                     |
 |              OUT: p_trh_rec Transaction history record                    |
 | RETURNS    :                                                              |
 | NOTES                                                                     |
 | MODIFICATION HISTORY - Created by Jani Rautiainen - 18-JAN-2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE lock_fetch_p(p_trh_rec IN OUT NOCOPY AR_TRANSACTION_HISTORY%ROWTYPE) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'ARP_TRANSACTION_HISTORY_PKG.lock_fetch_p()+' );
    END IF;

    SELECT *
    INTO   p_trh_rec
    FROM   AR_TRANSACTION_HISTORY
    WHERE  transaction_history_id = p_trh_rec.transaction_history_id
    FOR UPDATE OF status;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'ARP_TRANSACTION_HISTORY_PKG.lock_fetch_p()-' );
    END IF;

    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug(  'EXCEPTION: ARP_TRANSACTION_HISTORY_PKG.lock_fetch_p' );
              END IF;
              RAISE;
END lock_fetch_p;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    nowaitlock_fetch_p                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |  Locks and fetches the transaction history record from DB related to      |
 |  transaction history id given in record parameter. If the row  is already |
 |  locked this procedure will return an error.                              |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN: p_trh_rec Transaction history record                     |
 |              OUT: p_trh_rec Transaction history record                    |
 | RETURNS    :                                                              |
 | NOTES                                                                     |
 | MODIFICATION HISTORY - Created by Jani Rautiainen - 18-JAN-2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE nowaitlock_fetch_p(p_trh_rec IN OUT NOCOPY AR_TRANSACTION_HISTORY%ROWTYPE) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'ARP_TRANSACTION_HISTORY_PKG.nowaitlock_fetch_p()+' );
    END IF;

    SELECT *
    INTO   p_trh_rec
    FROM   AR_TRANSACTION_HISTORY
    WHERE  transaction_history_id = p_trh_rec.transaction_history_id
    FOR UPDATE OF status NOWAIT;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'ARP_TRANSACTION_HISTORY_PKG.nowaitlock_fetch_p()-' );
    END IF;

    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug(   'EXCEPTION: ARP_TRANSACTION_HISTORY_PKG.nowaitlock_fetch_p' );
              END IF;
              RAISE;
END nowaitlock_fetch_p;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_f_trx_id                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |  Locks transaction history record in DB related to the transaction        |
 |  id given as parameter. If the row  is already locked this                |
 |  procedure will wait for it to be released.                               |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN: p_trx_id  Transaction id                                 |
 |              OUT: NONE                                                    |
 | RETURNS    :                                                              |
 | NOTES                                                                     |
 | MODIFICATION HISTORY - Created by Jani Rautiainen - 18-JAN-2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE lock_f_trx_id(p_trx_id IN ra_customer_trx.customer_trx_id%TYPE ) IS

  CURSOR lock_C IS
   SELECT 'lock'
   FROM   AR_TRANSACTION_HISTORY
   WHERE  customer_trx_id = p_trx_id
   FOR UPDATE OF status;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'ARP_TRANSACTION_HISTORY_PKG.lock_f_trx_id()+' );
    END IF;

    OPEN lock_C;
    CLOSE lock_C;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'ARP_TRANSACTION_HISTORY_PKG.lock_f_trx_id()-' );
    END IF;

    EXCEPTION
         WHEN OTHERS THEN
	      IF lock_C%ISOPEN THEN
   	         CLOSE lock_C;
	      END IF;

              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug(   'EXCEPTION: ARP_TRANSACTION_HISTORY_PKG.lock_f_trx_id' );
              END IF;
              RAISE;
END lock_f_trx_id;
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    nowaitlock_f_trx_id                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |  Locks transaction history record in DB related to the transaction        |
 |  id given as parameter. If the row  is already locked this                |
 |  procedure will return an error.                                          |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN: p_trx_id  Transaction id                                 |
 |              OUT: NONE                                                    |
 | RETURNS    :                                                              |
 | NOTES                                                                     |
 | MODIFICATION HISTORY - Created by Jani Rautiainen - 18-JAN-2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE nowaitlock_f_trx_id(p_trx_id IN ra_customer_trx.customer_trx_id%TYPE ) IS

  CURSOR lock_C IS
   SELECT 'lock'
   FROM   AR_TRANSACTION_HISTORY
   WHERE  customer_trx_id = p_trx_id
   FOR UPDATE OF status NOWAIT;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'ARP_TRANSACTION_HISTORY_PKG.nowaitlock_f_trx_id()+' );
    END IF;

    OPEN lock_C;
    CLOSE lock_C;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'ARP_TRANSACTION_HISTORY_PKG.nowaitlock_f_trx_id()-' );
    END IF;

    EXCEPTION
         WHEN OTHERS THEN
	      IF lock_C%ISOPEN THEN
   	         CLOSE lock_C;
	      END IF;

              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug(   'EXCEPTION: ARP_TRANSACTION_HISTORY_PKG.nowaitlock_f_trx_id' );
              END IF;
              RAISE;
END nowaitlock_f_trx_id;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_fetch_f_trx_id                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |  Locks and fetches the current transaction history record from DB         |
 |  related to transaction id given in record parameter. If the row  is      |
 |  already locked this procedure will wait for it to be released.           |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN: p_trh_rec Transaction history record                     |
 |              OUT: p_trh_rec Transaction history record                    |
 | RETURNS    :                                                              |
 | NOTES                                                                     |
 | MODIFICATION HISTORY - Created by Jani Rautiainen - 18-JAN-2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE lock_fetch_f_trx_id(p_trh_rec IN OUT NOCOPY AR_TRANSACTION_HISTORY%ROWTYPE) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'ARP_TRANSACTION_HISTORY_PKG.lock_fetch_f_trx_id()+' );
    END IF;

    SELECT *
    INTO   p_trh_rec
    FROM   AR_TRANSACTION_HISTORY
    WHERE  customer_trx_id = p_trh_rec.customer_trx_id
    AND    current_record_flag = 'Y'
    FOR UPDATE OF status;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'ARP_TRANSACTION_HISTORY_PKG.lock_fetch_f_trx_id()-' );
    END IF;

    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug(   'EXCEPTION: ARP_TRANSACTION_HISTORY_PKG.lock_fetch_f_trx_id' );
              END IF;
              RAISE;
END lock_fetch_f_trx_id;
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    nowaitlock_fetch_f_trx_id                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |  Locks and fetches the current transaction history record from DB         |
 |  related to transaction id given in record parameter. If the row  is      |
 |  already locked this procedure will return an error.                      |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN: p_trh_rec Transaction history record                     |
 |              OUT: p_trh_rec Transaction history record                    |
 | RETURNS    :                                                              |
 | NOTES                                                                     |
 | MODIFICATION HISTORY - Created by Jani Rautiainen - 18-JAN-2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE nowaitlock_fetch_f_trx_id(p_trh_rec IN OUT NOCOPY AR_TRANSACTION_HISTORY%ROWTYPE) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'ARP_TRANSACTION_HISTORY_PKG.nowaitlock_fetch_f_trx_id()+' );
    END IF;

    SELECT *
    INTO   p_trh_rec
    FROM   AR_TRANSACTION_HISTORY
    WHERE  customer_trx_id = p_trh_rec.customer_trx_id
    AND    current_record_flag = 'Y'
    FOR UPDATE OF status NOWAIT;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'ARP_TRANSACTION_HISTORY_PKG.nowaitlock_fetch_f_trx_id()-' );
    END IF;

    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug(   'EXCEPTION: ARP_TRANSACTION_HISTORY_PKG.nowaitlock_fetch_f_trx_id' );
              END IF;
              RAISE;
END nowaitlock_fetch_f_trx_id;

BEGIN
  /* Populate the package header level variables from global variables */
  pg_request_id             :=  arp_global.request_id;
  pg_program_application_id :=  arp_global.program_application_id;
  pg_program_id             :=  arp_global.program_id;
  pg_program_update_date    :=  arp_global.program_update_date;
  pg_last_updated_by        :=  arp_global.last_updated_by;
  pg_last_update_date       :=  arp_global.last_update_date;
  pg_last_update_login      :=  arp_global.last_update_login;
  pg_set_of_books_id        :=  arp_global.set_of_books_id;

END ARP_TRANSACTION_HISTORY_PKG;

/
