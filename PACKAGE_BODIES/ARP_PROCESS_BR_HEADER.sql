--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_BR_HEADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_BR_HEADER" AS
/* $Header: ARTEBRHB.pls 120.4.12010000.3 2008/10/31 05:36:19 spdixit ship $ */

SUBTYPE ae_doc_rec_type   IS arp_acct_main.ae_doc_rec_type;

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE delete_transaction(p_customer_trx_id   IN ra_customer_trx.customer_trx_id%TYPE);
PROCEDURE delete_transaction_dist(p_customer_trx_id IN ra_customer_trx.customer_trx_id%TYPE);

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    	                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Inserts a record into ra_customer_trx for bills receivable transaction |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:      p_trx_rec                                           |
 |              OUT:     p_trx_number                                        |
 |                       p_customer_trx_id                                   |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-MAR-2000  Jani Rautiainen      Created                             |
 |                                                                           |
 +===========================================================================*/

PROCEDURE insert_header(p_trx_rec              IN  OUT NOCOPY ra_customer_trx%rowtype,
                        p_gl_date              IN      DATE,
                        p_trx_number           OUT NOCOPY     ra_customer_trx.trx_number%type,
                        p_customer_trx_id      OUT NOCOPY     ra_customer_trx.customer_trx_id%type) IS

 l_trh_rec                 ar_transaction_history%ROWTYPE;
 l_transaction_history_id  ar_transaction_history.transaction_history_id%TYPE;
BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('delete_transaction: ' || 'arp_process_br_header.insert_header()+');
   END IF;

   /*------------------------------------------------+
    |  All the validation and defaulting is done in  |
    |  the BR API, so none is done in the entity     |
    |  handler.                                      |
    +------------------------------------------------*/

   /*----------------------+
    |  call table-handler  |
    +----------------------*/

    arp_ct_pkg.insert_p(p_trx_rec, p_trx_number, p_customer_trx_id);

   /*------------------------------------------------+
    |  Create the firs transaction history record    |
    |  with status of 'INCOMPLETE'                   |
    +------------------------------------------------*/

    l_trh_rec.customer_trx_id          := p_customer_trx_id;
    l_trh_rec.status                   := 'INCOMPLETE';
    l_trh_rec.event                    := 'INCOMPLETE';
    l_trh_rec.batch_id                 := p_trx_rec.batch_id;
    l_trh_rec.trx_date                 := p_trx_rec.trx_date;
    l_trh_rec.gl_date                  := p_gl_date;
    l_trh_rec.maturity_date            := p_trx_rec.term_due_date;
    l_trh_rec.current_record_flag      := 'Y';
    l_trh_rec.current_accounted_flag   := 'N';
    l_trh_rec.postable_flag            := 'N';
    l_trh_rec.first_posted_record_flag := 'N';
    l_trh_rec.posting_control_id       := -3;
    l_trh_rec.gl_posted_date           := NULL;
    l_trh_rec.created_from             := 'ARTEBRHB';
    l_trh_rec.comments                 := p_trx_rec.comments;
    l_trh_rec.org_id                   := p_trx_rec.org_id;

   /*----------------------------------------------------------------------------------+
    |  Following columns are defaulted by the table handler:                           |
    |  program_application_id, program_id, program_update_date, request_id,            |
    |  creation_date, created_by, last_update_login, last_update_date, last_updated_by |
    +----------------------------------------------------------------------------------*/

    ARP_PROC_TRANSACTION_HISTORY.insert_transaction_history(l_trh_rec, l_transaction_history_id);

   /*----------------------------------------+
    |  BR has no Sales Credit, terms or tax  |
    +----------------------------------------*/

   /*---------------------------------------------------------------------------+
    |  All accounting is done in the accounting engine called by transaction    |
    |  history entity handler                                                   |
    +---------------------------------------------------------------------------*/

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('delete_transaction: ' || 'arp_process_br_header.insert_header()-');
   END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('delete_transaction: ' || 'EXCEPTION:  arp_process_br_header.insert_header()');
        END IF;
        RAISE;

END insert_header;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_header                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Updates a record into ra_customer_trx for bills receivable transaction.|
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |          IN/ OUT:  p_trx_rec                                              |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-MAR-2000  Jani Rautiainen      Created                             |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_header(p_trx_rec               IN OUT NOCOPY ra_customer_trx%rowtype,
                        p_customer_trx_id       IN     ra_customer_trx.customer_trx_id%TYPE) IS
BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('delete_transaction: ' || 'arp_process_br_header.update_header()+');
   END IF;

  /*------------------------------------------------+
   |  All the validation and defaulting is done in  |
   |  the BR API, so none is done in the entity     |
   |  handler.                                      |
   +------------------------------------------------*/

  /*----------------------------------------------------------------+
   |  Lock rows in other tables that reference this customer_trx_id |
   +----------------------------------------------------------------*/
   arp_process_br_header.lock_transaction(p_trx_rec.customer_trx_id);

   /*----------------------------------------------------------------------+
    | BR does not have Tax tax itself, deferred tax exists but it is taken |
    | care of with the transaction history.                                |
    +----------------------------------------------------------------------*/

   /*----------------------+
    |  call table-handler  |
    +----------------------*/

   arp_ct_pkg.update_p(p_trx_rec, p_customer_trx_id);

   /*----------------------------------------------------------------------+
    | Disputing is handled by updating the PS using PS entity handlers     |
    +----------------------------------------------------------------------*/

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('delete_transaction: ' || 'arp_process_br_header.update_header()-');
   END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('delete_transaction: ' || 'EXCEPTION:  arp_process_br_header.update_header()');
        END IF;
        RAISE;

END update_header;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_header                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Deletes row from ra_customer_trx for Bills Receivable Transaction.     |
 |    Also deletes all child rows.                                           |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:  p_customer_trx_id                                       |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-MAR-2000  Jani Rautiainen      Created                             |
 |                                                                           |
 +===========================================================================*/
PROCEDURE delete_header(p_customer_trx_id       IN ra_customer_trx.customer_trx_id%TYPE) IS
l_transaction_history_id    NUMBER;
BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('delete_transaction: ' || 'arp_process_br_header.delete_header()+');
   END IF;

  /*----------------------------------------------------------------+
   |  Lock rows in other tables that reference this customer_trx_id |
   +----------------------------------------------------------------*/
   arp_process_br_header.lock_transaction(p_customer_trx_id);

   /*-------------------------+
    |  delete the transaction |
    +-------------------------*/
   /*Bug7484811, Called ARP_XLA_EVENTS.delete_event to delete XLA record. */
   BEGIN
	SELECT transaction_history_id
	INTO l_transaction_history_id
	FROM ar_transaction_history
	WHERE customer_trx_id = p_customer_trx_id
	AND current_record_flag = 'Y';

   EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: getting trh_id in arp_process_br_header.delete_header() '|| sqlerrm);
        END IF;
        RAISE;
   END;

   ARP_XLA_EVENTS.delete_event( p_document_id  => l_transaction_history_id,
                                p_doc_table    => 'TRH');

   arp_process_br_header.delete_transaction(p_customer_trx_id);

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('delete_transaction: ' || 'arp_process_br_header.delete_header()-');
   END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('delete_transaction: ' || 'EXCEPTION:  arp_process_br_header.delete_header()');
        END IF;
        RAISE;

END delete_header;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_transaction                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Deletes all records in all tables associated with a particular         |
 |    bills receivable transcation.                                          |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:   p_customer_trx_id                                      |
 |              OUT:  None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |      28-MAR-2000  Jani Rautiainen Created
 |                                                                           |
 +===========================================================================*/
PROCEDURE delete_transaction(p_customer_trx_id   IN ra_customer_trx.customer_trx_id%TYPE) IS

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_process_br_header.delete_transaction()+');
   END IF;

   savepoint ar_br_delete_transaction_1;

  /*------------------------------------------------------------------+
   |  Delete rows in other tables that reference this customer_trx_id |
   +------------------------------------------------------------------*/
   arp_ct_pkg.delete_p(p_customer_trx_id);
   arp_ctl_pkg.delete_f_ct_id(p_customer_trx_id);
   arp_ps_pkg.delete_f_ct_id(p_customer_trx_id);
   arp_process_br_header.delete_transaction_dist(p_customer_trx_id);
   arp_transaction_history_pkg.delete_p(p_trx_id => p_customer_trx_id);

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_process_br_header.delete_transaction()-');
   END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION:  arp_process_br_header.delete_transaction()');
        END IF;
        rollback to savepoint ar_br_delete_transaction_1;
        RAISE;

END delete_transaction;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_transaction			                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Locks all records in all tables associated with a particular           |
 |    bills receivable transcation.	                                     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    dbms_sql.bind_variable                                                 |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:   p_customer_trx_id 				     |
 |              OUT:  None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |      28-MAR-2000  Jani Rautiainen Created
 |                                                                           |
 +===========================================================================*/
PROCEDURE lock_transaction(p_customer_trx_id   IN ra_customer_trx.customer_trx_id%TYPE) IS
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('delete_transaction: ' || 'arp_process_br_header.lock_transaction()+');
   END IF;

   savepoint ar_br_lock_transaction_1;

  /*----------------------------------------------------------------+
   |  Lock rows in other tables that reference this customer_trx_id |
   +----------------------------------------------------------------*/
   arp_ct_pkg.lock_p(p_customer_trx_id);
   arp_ctl_pkg.lock_f_ct_id(p_customer_trx_id);
   arp_ps_pkg.lock_f_ct_id(p_customer_trx_id);
   arp_adjustments_pkg.lock_f_ct_id(p_customer_trx_id);
   arp_transaction_history_pkg.lock_f_trx_id(p_customer_trx_id);

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('delete_transaction: ' || 'arp_process_br_header.lock_transaction()-');
   END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('delete_transaction: ' || 'EXCEPTION:  arp_process_br_header.lock_transaction');
        END IF;
        rollback to savepoint ar_br_lock_transaction_1;
        RAISE;

END lock_transaction;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_transaction_dist                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Deletes distribution rows from ar_distributions for given transaction  |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:  p_customer_trx_id                                       |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-MAR-2000  Jani Rautiainen      Created                             |
 |                                                                           |
 +===========================================================================*/
PROCEDURE delete_transaction_dist(p_customer_trx_id IN ra_customer_trx.customer_trx_id%TYPE) IS

 /*----------------------------------------------------------------+
  |  Cursor for all transaction history rows that have accounting  |
  +----------------------------------------------------------------*/
  CURSOR transaction_history_cur IS
    select th.transaction_history_id
    from ar_transaction_history th
    where customer_trx_id = p_customer_trx_id
    and postable_flag = 'Y';

  transaction_history_rec transaction_history_cur%ROWTYPE;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_process_br_header.delete_transaction_dist()+');
   END IF;

  /*------------------------------------------------------------------+
   |  loop through all transaction history rows that have accounting  |
   +------------------------------------------------------------------*/

   FOR transaction_history_rec IN transaction_history_cur LOOP

     /*-------------------------------------------------------+
      |  delete the accounting related to transaction history |
      +-------------------------------------------------------*/

     arp_proc_transaction_history.delete_transaction_hist_dist(transaction_history_rec.transaction_history_id);

   END LOOP;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_process_br_header.delete_transaction_dist()-');
   END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION:  arp_process_br_header.delete_transaction_dist()');
        END IF;
        RAISE;

END delete_transaction_dist;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    move_deferred_tax                                                      |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure is used to deduct whether deferred tax needs to be      |
 |    moved for a Bills Receivable transaction.                              |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:  p_customer_trx_id - ID of the BR to be checked          |
 |              OUT: p_required        - returns whether to move tax or not  |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     31-AUG-2000  Jani Rautiainen      Created                             |
 |                                                                           |
 +===========================================================================*/
PROCEDURE move_deferred_tax(p_customer_trx_id  IN  ra_customer_trx.customer_trx_id%TYPE,
                            p_required         OUT NOCOPY BOOLEAN) IS

  CURSOR move_deferred_tax_cur IS
   select 'Y' deferred_tax_moved
   from dual
   where exists (select 'x'
                 from ra_customer_trx ct
                 where ct.customer_trx_id IN (select distinct ctl.br_ref_customer_trx_id
                                              from ra_customer_trx_lines ctl
                                              start with ctl.customer_trx_id = p_customer_trx_id
                                              connect by prior ctl.br_ref_customer_trx_id = ctl.customer_trx_id
                                             )
                 and ct.drawee_site_use_id IS NULL
                 and exists (select 'x'
                             from ra_cust_trx_line_gl_dist gld
                             where gld.account_class = 'TAX'
                             and   gld.customer_trx_id = ct.customer_trx_id
                             and   gld.collected_tax_ccid IS NOT NULL
                            )
                );

  move_deferred_tax_rec move_deferred_tax_cur%ROWTYPE;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_process_br_header.move_deferred_tax()+');
  END IF;

  OPEN move_deferred_tax_cur;
  FETCH move_deferred_tax_cur INTO move_deferred_tax_rec;
  CLOSE move_deferred_tax_cur;

  IF NVL(move_deferred_tax_rec.deferred_tax_moved,'N') = 'Y' THEN

    p_required := TRUE;

  ELSE

    p_required := FALSE;

  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_process_br_header.move_deferred_tax()-');
  END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION:  arp_process_br_header.move_deferred_tax()');
        END IF;
        p_required := FALSE; --Tax is not deferred processing not required

   WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION:  arp_process_br_header.move_deferred_tax()');
        END IF;
        p_required := FALSE; --Tax is not deferred processing not required

END move_deferred_tax;


END ARP_PROCESS_BR_HEADER;

/
