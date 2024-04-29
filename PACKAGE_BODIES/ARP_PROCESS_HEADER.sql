--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_HEADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_HEADER" AS
/* $Header: ARTEHEAB.pls 120.24.12010000.7 2009/11/13 06:50:23 npanchak ship $ */

pg_tax_flag varchar2(10);
pg_text_dummy   varchar2(10);
pg_flag_dummy   varchar2(10);
pg_number_dummy number;
pg_date_dummy   date;
pg_earliest_date  date;

pg_base_curr_code          gl_sets_of_books.currency_code%type;
pg_base_precision          fnd_currencies.precision%type;
pg_base_min_acc_unit       fnd_currencies.minimum_accountable_unit%type;
pg_set_of_books_id         ar_system_parameters.set_of_books_id%type;

/*3609567*/
pg_trx_header_level_rounding ar_system_parameters.TRX_HEADER_LEVEL_ROUNDING%TYPE;

pg_use_inv_acctg  varchar2(1);

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_insert_header                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validates row that is going to be inserted into ra_customer_trx.       |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:  l_trx_rec                                               |
 |              OUT: l_status                                                |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     13-JUL-95  Martin Johnson      Created                                |
 |     13-MAY-99  Srihari Koukuntla   Modified for BugNo :860294             |
 |                added to i/p parameters l_trx_rec and l_status             |
 |                to validate complete_flag                                  |
 |                                                                           |
 +===========================================================================*/

PROCEDURE validate_insert_header( l_trx_rec IN ra_customer_trx%rowtype,
                                  l_status OUT NOCOPY varchar2 ) IS

BEGIN

   arp_util.debug('arp_process_header.validate_insert_header()+');
   if l_trx_rec.complete_flag is null then
      arp_util.debug('Complete flag cannot be null,Valid values are Y or N');
      l_status := 'E';
      return;
   end if;
   arp_util.debug('arp_process_header.validate_insert_header()-');

EXCEPTION
    WHEN OTHERS THEN
     arp_util.debug('EXCEPTION:  arp_process_header.validate_insert_header()');
     RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_update_header                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validates row that is going to be updated in ra_customer_trx.          |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-JUL-95  Martin Johnson      Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE validate_update_header IS

BEGIN

   arp_util.debug('arp_process_header.validate_update_header()+');

   arp_util.debug('arp_process_header.validate_update_header()-');

EXCEPTION
    WHEN OTHERS THEN
     arp_util.debug('EXCEPTION:  arp_process_header.validate_update_header()');
     RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_delete_header                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validates row that is going to be delete from ra_customer_trx.         |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     26-JUL-95  Martin Johnson      Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE validate_delete_header IS

BEGIN

   arp_util.debug('arp_process_header.validate_delete_header()+');

   arp_util.debug('arp_process_header.validate_delete_header()-');

EXCEPTION
    WHEN OTHERS THEN
     arp_util.debug('EXCEPTION:  arp_process_header.validate_delete_header()');
     RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    set_flags                                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Sets various change and status flags for the current record.           |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_customer_trx_id                                       |
 |                   p_new_trx_rec                                           |
 |                   p_new_gl_date                                           |
 |                   p_new_open_rec_flag                                     |
 |                   pd_dispute_date
 |              OUT:                                                         |
 |                   p_ex_rate_changed_flag                                  |
 |                   p_commitment_changed_flag                               |
 |                   p_gl_date_changed_flag                                  |
 |                   p_complete_changed_flag                                 |
 |                   p_open_rec_changed_flag                                 |
 |          IN/ OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-JUL-95  Martin Johnson      Created                                |
 |     10/10/1996 Harri Kaukovuo      Fixed bug 411036. Updating dispute
 |                                    date did not work.
 |                                    Added code to check whether dispute date
 |                                    has changes.
 |     11-MAR-05  M Raymond       Bug 4233770/4235243 - added exception block
 |                                    for SELECT that fetches gl_date
 +===========================================================================*/

PROCEDURE set_flags(p_customer_trx_id          IN
                      ra_customer_trx.customer_trx_id%type,
                    p_new_trx_rec              IN ra_customer_trx%rowtype,
                    p_new_gl_date              IN
                      ra_cust_trx_line_gl_dist.gl_date%type,
                    p_new_open_rec_flag        IN
                      ra_cust_trx_types.accounting_affect_flag%type,
                    p_ps_dispute_amount        IN
                      ar_payment_schedules.amount_in_dispute%type,
                    pd_dispute_date            IN DATE,
                    p_ex_rate_changed_flag    OUT NOCOPY boolean,
                    p_commitment_changed_flag OUT NOCOPY boolean,
                    p_gl_date_changed_flag    OUT NOCOPY boolean,
                    p_complete_changed_flag   OUT NOCOPY boolean,
                    p_open_rec_changed_flag   OUT NOCOPY boolean,
                    p_dispute_changed_flag    OUT NOCOPY boolean,
                    p_number_of_payment_schedules OUT NOCOPY NUMBER,
                    p_old_trx_rec             OUT NOCOPY ra_customer_trx%rowtype,
		    p_cust_trx_type_changed_flag OUT NOCOPY boolean)
IS

  l_old_trx_rec         ra_customer_trx%rowtype;
  l_old_gl_date         ra_cust_trx_line_gl_dist.gl_date%type;
  l_old_open_rec_flag   ra_cust_trx_types.accounting_affect_flag%type;
  l_old_dispute_amount  ar_payment_schedules.amount_in_dispute%type;
  ld_old_dispute_date   DATE;

BEGIN

   arp_util.debug('arp_process_header.set_flags()+');

   arp_ct_pkg.fetch_p(l_old_trx_rec,
                      p_customer_trx_id);

   p_old_trx_rec := l_old_trx_rec;

   /* Bug 4233770/4235243 - added exception handling */
   BEGIN

      select gl_date
        into l_old_gl_date
        from ra_cust_trx_line_gl_dist
       where customer_trx_id = p_customer_trx_id
         and account_class = 'REC'
         and latest_rec_flag = 'Y';

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       /* Bug 4233770/4235243 - no data in gl_dist table.  This happens
          for freight lines coming through invoice API.
          Clearly, there is no assigned gl_date yet */
       arp_standard.debug('No rows in ra_cust_trx_line_gl_dist');
     WHEN OTHERS THEN
       RAISE;
   END;

   IF (
        nvl(l_old_trx_rec.exchange_rate, 0) <>
        nvl(p_new_trx_rec.exchange_rate, 0)
        AND
        nvl(p_new_trx_rec.exchange_rate, 0) <> pg_number_dummy
      )
     THEN p_ex_rate_changed_flag := TRUE;
     ELSE p_ex_rate_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_trx_rec.initial_customer_trx_id, 0) <>
        nvl(p_new_trx_rec.initial_customer_trx_id, 0)
        AND
        nvl(p_new_trx_rec.initial_customer_trx_id, 0) <> pg_number_dummy
      )
     THEN p_commitment_changed_flag := TRUE;
     ELSE p_commitment_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_gl_date, pg_earliest_date) <>
        nvl(p_new_gl_date, pg_earliest_date)
        AND
        nvl(p_new_gl_date, pg_earliest_date) <> pg_date_dummy
      )
     THEN p_gl_date_changed_flag := TRUE;
     ELSE p_gl_date_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_trx_rec.complete_flag, 'x') <>
        nvl(p_new_trx_rec.complete_flag, 'x')
        AND
        nvl(p_new_trx_rec.complete_flag, 'x') <> pg_flag_dummy
      )
     THEN p_complete_changed_flag := TRUE;
     ELSE p_complete_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_trx_rec.cust_trx_type_id, 0) <>
        nvl(p_new_trx_rec.cust_trx_type_id, 0)
        AND
        nvl(p_new_trx_rec.cust_trx_type_id, 0) <> pg_number_dummy
      )
     THEN
          select accounting_affect_flag
            into l_old_open_rec_flag
            from ra_cust_trx_types
           where cust_trx_type_id = l_old_trx_rec.cust_trx_type_id;

           IF l_old_open_rec_flag <> p_new_open_rec_flag
             THEN p_open_rec_changed_flag := TRUE;
             ELSE p_open_rec_changed_flag := FALSE;
           END IF;

     ELSE p_open_rec_changed_flag := FALSE;
   END IF;

   -- 10/10/1996 H.Kaukovuo  Added dispute date to the selection
   IF   (p_ps_dispute_amount IS NULL)
   THEN  p_dispute_changed_flag := FALSE;
   ELSE
         SELECT SUM( NVL(ps.amount_in_dispute,0) ),
                COUNT(*)
                , MAX(ps.dispute_date)
         INTO   l_old_dispute_amount,
                p_number_of_payment_schedules
                , ld_old_dispute_date
         FROM   ar_payment_schedules ps
         WHERE  ps.customer_trx_id = p_customer_trx_id;

         -- Return true if amount or date was changed
         IF  (p_ps_dispute_amount <> l_old_dispute_amount
              OR ld_old_dispute_date <> pd_dispute_date)
         THEN
           p_dispute_changed_flag := TRUE;
         ELSE
           p_dispute_changed_flag := FALSE;
         END IF;

   END IF;

   -- 10/9/97: Added by OSTEINME for bug 446263

   IF (p_new_trx_rec.cust_trx_type_id <> l_old_trx_rec.cust_trx_type_id) THEN
     p_cust_trx_type_changed_flag := TRUE;
   ELSE
     p_cust_trx_type_changed_flag := FALSE;
   END IF;

   arp_util.debug('arp_process_header.set_flags()-');


EXCEPTION
  WHEN OTHERS THEN

  /*---------------------------------------------+
   |  Display parameters and raise the exception |
   +---------------------------------------------*/

   arp_util.debug('EXCEPTION:  arp_process_header.set_flags()');

   arp_util.debug('');
   arp_util.debug('---------- parameters for set_flags() ---------');

   arp_util.debug('p_customer_trx_id    = ' || p_customer_trx_id);
   arp_util.debug('p_new_gl_date        = ' || p_new_gl_date);
   arp_util.debug('p_new_open_rec_flag  = ' || p_new_open_rec_flag);
   arp_util.debug('p_ps_dispute_amount  = ' || TO_CHAR(p_ps_dispute_amount));
   arp_util.debug('');

   arp_util.debug('---------- new transaction record ----------');
   arp_ct_pkg.display_header_rec( p_new_trx_rec );
   arp_util.debug('');

   RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    header_rerun_aa                                                        |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    reruns autoaccounting at the header level                              |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     21-JUL-95  Martin Johnson      Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE header_rerun_aa(p_customer_trx_id  IN number,
                          p_gl_date          IN
                            ra_cust_trx_line_gl_dist.gl_date%type,
                          p_total_trx_amount IN number,
                          p_status          OUT NOCOPY varchar2) IS

   l_result                number;
   l_ccid                  number;
   l_concat_segments       varchar2(2000);
   l_num_failed_dist_rows  number;
   l_errorbuf              varchar2(200);
   l_status1               varchar2(100);
   l_status2               varchar2(100);
   l_status3               varchar2(100);
   l_status4               varchar2(100);
   l_status5               varchar2(100);
   l_status6               varchar2(100);
   l_status7               varchar2(100);

   l_event_source_info 	xla_events_pub_pkg.t_event_source_info;
   l_security          	xla_events_pub_pkg.t_security;
   l_event_id          	NUMBER;


	CURSOR c_ct IS
	SELECT  distinct gld.event_id  event_id
	FROM ra_cust_trx_line_gl_dist gld, ra_customer_trx ra
	WHERE gld.customer_trx_id = p_customer_trx_id
	and   gld.customer_trx_id = ra.customer_trx_id
	and   ra.invoicing_rule_id is NULL
	and   gl_date <> p_gl_date
	and   gld.account_class = 'REC'
	and   gld.posting_control_id = -3
	and  account_set_flag = 'N'
	AND  event_id is not null
	AND exists
	(Select 1 from xla_events
	 where entity_id in (
	 Select entity_id from xla_transaction_entities
	 where entity_code = 'TRANSACTIONS'
	 and nvl(source_id_int_1 , -99) = ra.customer_trx_id
	 and ledger_id = ra.set_of_books_id
	 and application_id = 222 ));


BEGIN

   arp_util.debug('arp_process_header.header_rerun_aa()+');


   	-- Bug9005547
	-- Delete the existing event_id that has been latched to the GLD rows:
	 BEGIN
	    arp_util.debug('header_rerun_a: Deleting existing events');

	      FOR c IN c_ct loop

	      l_event_id  := c.event_id;

	      l_event_source_info.entity_type_code:= 'TRANSACTIONS';
	      l_security.security_id_int_1        := arp_global.sysparam.org_id;
	      l_event_source_info.application_id  := 222;
	      l_event_source_info.ledger_id       := arp_standard.sysparm.set_of_books_id;
	      l_event_source_info.source_id_int_1 := p_customer_trx_id;

	      xla_events_pub_pkg.delete_event
	      ( p_event_source_info => l_event_source_info,
		p_event_id          => l_event_id,
		p_valuation_method  => NULL,
		p_security_context  => l_security);

	      END loop;

	     arp_util.debug('header_rerun_a: Completed deleting existing events');
	EXCEPTION
	  WHEN OTHERS THEN
	  arp_util.debug('EXCEPTION: header_rerun_aa : delete events'||SQLERRM);
	  RAISE;
	END;

   BEGIN
        arp_auto_accounting.do_autoaccounting(
                                 'U',
                                 'REC',
                                 p_customer_trx_id,
                                 null,
                                 null,
                                 null,
                                 p_gl_date,
                                 null,
                                 p_total_trx_amount,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 l_ccid,
                                 l_concat_segments,
                                 l_num_failed_dist_rows);
   EXCEPTION
     WHEN arp_auto_accounting.no_ccid THEN
       l_status1 := 'ARP_AUTO_ACCOUNTING.NO_CCID';

     WHEN NO_DATA_FOUND THEN
       null;
     WHEN OTHERS THEN
       RAISE;
   END;


   BEGIN
        arp_auto_accounting.do_autoaccounting(
                                 'U',
                                 'REV',
                                 p_customer_trx_id,
                                 null,
                                 null,
                                 null,
                                 p_gl_date,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 l_ccid,
                                 l_concat_segments,
                                 l_num_failed_dist_rows);
   EXCEPTION
     WHEN arp_auto_accounting.no_ccid THEN
       l_status2 := 'ARP_AUTO_ACCOUNTING.NO_CCID';

     WHEN NO_DATA_FOUND THEN
       null;
     WHEN OTHERS THEN
       RAISE;
   END;

   /* bug 842360 : added next 2 calls to do_autoaccounting for UNEARN and UNBILL */
   BEGIN
        arp_auto_accounting.do_autoaccounting(
                                 'U',
                                 'UNEARN',
                                 p_customer_trx_id,
                                 null,
                                 null,
                                 null,
                                 p_gl_date,
                                 null,
                                 p_total_trx_amount,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 l_ccid,
                                 l_concat_segments,
                                 l_num_failed_dist_rows);
   EXCEPTION
     WHEN arp_auto_accounting.no_ccid THEN
       l_status6 := 'ARP_AUTO_ACCOUNTING.NO_CCID';

     WHEN NO_DATA_FOUND THEN
       null;
     WHEN OTHERS THEN
       RAISE;
   END;

   BEGIN
        arp_auto_accounting.do_autoaccounting(
                                 'U',
                                 'UNBILL',
                                 p_customer_trx_id,
                                 null,
                                 null,
                                 null,
                                 p_gl_date,
                                 null,
                                 p_total_trx_amount,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 l_ccid,
                                 l_concat_segments,
                                 l_num_failed_dist_rows);
   EXCEPTION
     WHEN arp_auto_accounting.no_ccid THEN
       l_status7 := 'ARP_AUTO_ACCOUNTING.NO_CCID';

     WHEN NO_DATA_FOUND THEN
       null;
     WHEN OTHERS THEN
       RAISE;
   END;

   BEGIN
        arp_auto_accounting.do_autoaccounting(
                                 'U',
                                 'CHARGES',
                                 p_customer_trx_id,
                                 null,
                                 null,
                                 null,
                                 p_gl_date,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 l_ccid,
                                 l_concat_segments,
                                 l_num_failed_dist_rows);
   EXCEPTION
     WHEN arp_auto_accounting.no_ccid THEN
       l_status3 := 'ARP_AUTO_ACCOUNTING.NO_CCID';

     WHEN NO_DATA_FOUND THEN
       null;
     WHEN OTHERS THEN
       RAISE;
   END;


   BEGIN
        arp_auto_accounting.do_autoaccounting(
                                 'U',
                                 'TAX',
                                 p_customer_trx_id,
                                 null,
                                 null,
                                 null,
                                 p_gl_date,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 l_ccid,
                                 l_concat_segments,
                                 l_num_failed_dist_rows);
   EXCEPTION
     WHEN arp_auto_accounting.no_ccid THEN
       l_status4 := 'ARP_AUTO_ACCOUNTING.NO_CCID';

     WHEN NO_DATA_FOUND THEN
       null;
     WHEN OTHERS THEN
       RAISE;
   END;


   BEGIN
        arp_auto_accounting.do_autoaccounting(
                                 'U',
                                 'FREIGHT',
                                 p_customer_trx_id,
                                 null,
                                 null,
                                 null,
                                 p_gl_date,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 l_ccid,
                                 l_concat_segments,
                                 l_num_failed_dist_rows);
   EXCEPTION
     WHEN arp_auto_accounting.no_ccid THEN
       l_status5 := 'ARP_AUTO_ACCOUNTING.NO_CCID';

     WHEN NO_DATA_FOUND THEN
       null;
     WHEN OTHERS THEN
       RAISE;
   END;

   arp_util.debug('l_status1  = ' || l_status1);
   arp_util.debug('l_status2  = ' || l_status2);
   arp_util.debug('l_status3  = ' || l_status3);
   arp_util.debug('l_status4  = ' || l_status4);
   arp_util.debug('l_status5  = ' || l_status5);
   arp_util.debug('l_status6  = ' || l_status6);
   arp_util.debug('l_status7  = ' || l_status7);

   IF    ( NVL(l_status1, 'OK') <> 'OK' )
   THEN  p_status := l_status1;
   ELSIF ( NVL(l_status2, 'OK') <> 'OK' )
      THEN  p_status := l_status2;
   ELSIF ( NVL(l_status3, 'OK') <> 'OK' )
      THEN  p_status := l_status3;
   ELSIF ( NVL(l_status4, 'OK') <> 'OK' )
      THEN  p_status := l_status4;
   ELSIF ( NVL(l_status5, 'OK') <> 'OK' )
      THEN  p_status := l_status5;
   ELSIF ( NVL(l_status6, 'OK') <> 'OK' )
      THEN  p_status := l_status6;
   ELSIF ( NVL(l_status7, 'OK') <> 'OK' )
      THEN  p_status := l_status7;
   ELSE     p_status := 'OK';
   END IF;

   arp_util.debug('arp_process_header.header_rerun_aa()-');

EXCEPTION
    WHEN OTHERS THEN
     arp_util.debug('EXCEPTION:  arp_process_header.header_rerun_aa()');
     RAISE;

END;

/* Bug 2689013 */
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    reverse_revrec_effect                                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    When a transaction with rule is incompleted, we will now reverse the   |
 |    effect of revenue recognition on the transaction, if it is already run.|
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 | ARGUMENTS :                                                               |
 |                 IN :  p_customer_trx_id                                   |
 |                 OUT:                                                      |
 |             IN/ OUT:                                                      |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     25-JUL-03  Veena Rao      Created                                     |
 |                                                                           |
 +===========================================================================*/

 PROCEDURE reverse_revrec_effect (
       p_customer_trx_id IN ra_customer_trx.customer_trx_id%type
               )  IS

     l_line_rec                ra_customer_trx_lines%rowtype;
     l_dist_rec                ra_cust_trx_line_gl_dist%rowtype;
 BEGIN

    arp_util.debug('arp_process_header.reverse_revrec_effect()+');

    arp_ctl_pkg.set_to_dummy( l_line_rec );

    l_line_rec.autorule_complete_flag := 'N';
    l_line_rec.autorule_duration_processed := NULL;

    BEGIN
       arp_ctl_pkg.update_f_ct_id( l_line_rec,
                            p_customer_trx_id,
                                       'LINE');
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
          arp_util.debug('arp_process_header..reverse_revrec_effect: '||
                              'no child lines to update.');
       WHEN OTHERS THEN
          arp_util.debug('EXCEPTION:  '||
             'arp_process_header..reverse_revrec_effect()');
       RAISE;
    END;

     BEGIN

       --6870437
       ARP_XLA_EVENTS.delete_reverse_revrec_event( p_document_id  => p_customer_trx_id,
                                                   p_doc_table    => 'CT');

       arp_ctlgd_pkg.delete_f_ct_id(p_customer_trx_id,
                                                  'N',
                                                 NULL);
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
          arp_util.debug('arp_process_header.reverse_revrec_effect: '||
                                         'no dists to delete.');
        WHEN OTHERS THEN
          arp_util.debug('EXCEPTION:  '||
                  'arp_process_header.reverse_revrec_effect()');
         RAISE;
     END;

     arp_ctlgd_pkg.set_to_dummy(l_dist_rec);
     l_dist_rec.latest_rec_flag := 'Y';
     BEGIN
       arp_ctlgd_pkg.update_f_ct_id(l_dist_rec,
                             p_customer_trx_id,
                                           'Y',
                                        'REC');
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
          arp_util.debug('arp_process_header.reverse_revrec_effect: '||
                                     'no dists to update.');
        WHEN OTHERS THEN
          arp_util.debug('EXCEPTION:  '||
                         'arp_process_header.reverse_revrec_effect()');
        RAISE;
     END;
   EXCEPTION
       WHEN OTHERS THEN
          arp_util.debug('EXCEPTION:  '||
                  'arp_process_header.reverse_revrec_effect()');
       RAISE;
														 END ;
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_header                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Inserts a record into ra_customer_trx.                                 |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                       p_form_name                                         |
 |                       p_form_version                                      |
 |                       p_trx_rec                                           |
 |                       p_trx_class                                         |
 |                       p_gl_date                                           |
 |                       p_term_in_use_flag                                  |
 |                       p_commitment_rec                                    |
 |              OUT:                                                         |
 |                       p_trx_number                                        |
 |                       p_customer_trx_id                                   |
 |                       p_status                                            |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     11-JUL-95  Martin Johnson      Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE insert_header(
  p_form_name             IN varchar2,
  p_form_version          IN number,
  p_trx_rec               IN ra_customer_trx%rowtype,
  p_trx_class             IN ra_cust_trx_types.type%type,
  p_gl_date               IN ra_cust_trx_line_gl_dist.gl_date%type,
  p_term_in_use_flag      IN varchar2,
  p_commitment_rec        IN arp_process_commitment.commitment_rec_type,
  p_trx_number           OUT NOCOPY ra_customer_trx.trx_number%type,
  p_customer_trx_id      OUT NOCOPY ra_customer_trx.customer_trx_id%type,
  p_customer_trx_line_id OUT NOCOPY ra_customer_trx_lines.customer_trx_line_id%type,
  p_row_id               OUT NOCOPY rowid,
  p_status               OUT NOCOPY varchar2,
  p_receivable_ccid       IN gl_code_combinations.code_combination_id%type
                             DEFAULT NULL,
  p_run_autoacc_flag      IN varchar2  DEFAULT 'Y',
  p_create_default_sc_flag IN varchar2  DEFAULT 'Y' )

                 IS

   l_customer_trx_id       ra_customer_trx.customer_trx_id%type;
   l_result                number;
   l_ccid                  number;
   l_concat_segments       varchar2(2000);
   l_num_failed_dist_rows  number;
   l_errorbuf              varchar2(200);

   l_remit_to_address_rec  arp_trx_defaults_3.address_rec_type;
   l_trx_rec               ra_customer_trx%rowtype;
   l_status1               varchar2(100);
   l_status2               varchar2(100);
--Bug# 2750340
   l_ev_rec                arp_xla_events.xla_events_type;

   /* bug 3609567 */
   l_error_message VARCHAR2(128) := '';
   l_dist_count NUMBER;

BEGIN

   arp_util.debug('arp_process_header.insert_header()+');

   p_trx_number := '';
   p_customer_trx_id := '';
   l_trx_rec := p_trx_rec;

   -- check form version to determine if it is compatible with the
   -- entity handler.
      arp_trx_validate.ar_entity_version_check(p_form_name, p_form_version);

   -- do validation
   p_status := 'S';
   validate_insert_header(p_trx_rec,p_status);
   if p_status = 'E' then
      arp_util.debug('Failed in validate insert header');
      return;
   end if;

   /*--------------------+
    |  pre-insert logic  |
    +--------------------*/


  /*---------------------------------------------------------------------+
   |  IF   the remit to address is null                                  |
   |  AND  the transaction is not a credit memo                          |
   |  THEN try to derive the remit to address from the bill to address   |
   |       or from the default remit to address.                         |
   |                                                                     |
   |  If no remit to address can be derived, the procedure raises a      |
   |  NO_DATA_FOUND error. Ignore this error.                            |
   +---------------------------------------------------------------------*/

   IF    ( l_trx_rec.remit_to_address_id IS NULL ) AND
         ( p_trx_class <> 'CM' )
   THEN
         BEGIN
              arp_trx_defaults_3.get_remit_to_address(
                                                 null,
                                                 null,
                                                 null,
                                                 null,
                                                 l_trx_rec.bill_to_site_use_id,
                                                 l_trx_rec.remit_to_address_id,
                                                 l_remit_to_address_rec
                                               );
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
                null;
            WHEN OTHERS THEN RAISE;
         END;

   END IF;

  /*------------------------------------------------+
   |  IF    the printing option is null             |
   |  THEN  default it from the transaction type    |
   |        or set it to 'Print'.                   |
   +------------------------------------------------*/

   IF    ( l_trx_rec.printing_option IS NULL )
   THEN

         SELECT NVL( default_printing_option, 'PRI' )
         INTO   l_trx_rec.printing_option
         FROM   ra_cust_trx_types
         WHERE  cust_trx_type_id = l_trx_rec.cust_trx_type_id;

   END IF;


      IF p_trx_class in ('DEP', 'GUAR')
        THEN arp_process_commitment.header_pre_insert;
             -- does commitment validation
      END IF;


   /*----------------------+
    |  call table-handler  |
    +----------------------*/

      arp_ct_pkg.insert_p(l_trx_rec, p_trx_number, l_customer_trx_id);

      p_customer_trx_id := l_customer_trx_id;


   /*---------------------+
    |  post-insert logic  |
    +---------------------*/

       IF p_trx_class in ('DEP', 'GUAR')
         THEN arp_process_commitment.header_post_insert(
                                           l_customer_trx_id,
                                           p_commitment_rec,
                                           l_trx_rec.primary_salesrep_id,
                                           p_gl_date,
                                           p_customer_trx_line_id,
                                           l_status1 );

         ELSE arp_process_invoice.header_post_insert(
                                           l_trx_rec.primary_salesrep_id,
                                           l_customer_trx_id,
                                           p_create_default_sc_flag);
       END IF;

       -- Call AutoAccounting to insert the gl dist record for Receivable

       IF ( p_run_autoacc_flag = 'Y' )
       THEN

             BEGIN

                 arp_auto_accounting.do_autoaccounting(
                                     'I',
                                     'REC',
                                     l_customer_trx_id,
                                     null,
                                     null,
                                     null,
                                     p_gl_date,
                                     null,
                                     nvl(p_commitment_rec.extended_amount, 0),
                                     p_receivable_ccid,
                                     null,
                                     null,
                                     null,
                                     null,
                                     null,
                                     l_ccid,
                                     l_concat_segments,
                                     l_num_failed_dist_rows);
                 /* Bug 3609567 */
                 IF  arp_rounding.correct_dist_rounding_errors(
                                        NULL,
                                        l_customer_trx_id ,
                                        NULL,
                                        l_dist_count,
                                        l_error_message ,
                                        pg_base_precision ,
                                        pg_base_min_acc_unit ,
                                        'ALL' ,
                                        NULL,
                                        'N' ,
                                        pg_trx_header_level_rounding ,
                                        'N',
                                        'N') = 0 -- FALSE
                 THEN
                    arp_util.debug('EXCEPTION:  Insert_Header');
                    arp_util.debug(l_error_message);
                    fnd_message.set_name('AR', 'AR_PLCRE_FHLR_CCID');
                    APP_EXCEPTION.raise_exception;
                 END IF;

             EXCEPTION
               WHEN arp_auto_accounting.no_ccid THEN
                   l_status2 := 'ARP_AUTO_ACCOUNTING.NO_CCID';
               WHEN NO_DATA_FOUND THEN
                 null;
               WHEN OTHERS THEN
                 RAISE;
             END;

       END IF;

       -- update ra_terms.in_use
          arp_trx_util.set_term_in_use_flag(
                                        p_form_name,
                                        p_form_version,
                                        l_trx_rec.term_id,
                                        p_term_in_use_flag);

        arp_util.debug('l_status1  = ' || l_status1);
        arp_util.debug('l_status2  = ' || l_status2);

        IF    ( NVL(l_status1, 'OK') <> 'OK' )
        THEN  p_status := l_status1;
        ELSIF ( NVL(l_status2, 'OK') <> 'OK' )
           THEN  p_status := l_status2;
        ELSE     p_status := 'OK';
        END IF;

   -- Bug# 2750340  : Call AR_XLA_EVENTS
     ------------------------------------------------------------
     -- This call to ARP_XLA_EVENT is required when
     -- user creates a document through the transaction Workbench
     ------------------------------------------------------------
     l_ev_rec.xla_from_doc_id   := l_customer_trx_id;
     l_ev_rec.xla_to_doc_id     := l_customer_trx_id;
     l_ev_rec.xla_req_id        := NULL;
     l_ev_rec.xla_dist_id       := NULL;
     l_ev_rec.xla_doc_table     := 'CT';
     l_ev_rec.xla_doc_event     := NULL;
     l_ev_rec.xla_mode          := 'O';
     l_ev_rec.xla_call          := 'B';
     l_ev_rec.xla_fetch_size    := 999;
     arp_xla_events.create_events(p_xla_ev_rec => l_ev_rec );

   arp_util.debug('arp_process_header.insert_header()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_process_header.insert_header()');
        RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_header                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Updates a record into ra_customer_trx.                                 |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-JUL-95  Martin Johnson      Created                                |
 |     29-NOV-95  Nigel Smith         Added calls to Tax Engine.             |
 |     10/10/1996 Harri Kaukovuo      Added parameter pd_dispute_date
 |                                    to set_flags().
 |				      Fixed bug when updating dispute amount
 |				      would cause the whole ar_payment_schedules
 |				      to be updated.
 +===========================================================================*/

PROCEDURE update_header(
  p_form_name             IN varchar2,
  p_form_version          IN number,
  p_trx_rec               IN OUT NOCOPY ra_customer_trx%rowtype,
  p_customer_trx_id       IN ra_customer_trx.customer_trx_id%type,
  p_trx_amount            IN number,
  p_trx_class             IN ra_cust_trx_types.type%type,
  p_gl_date               IN ra_cust_trx_line_gl_dist.gl_date%type,
  p_initial_customer_trx_line_id IN
         ra_customer_trx_lines.initial_customer_trx_line_id%type
         default null,
  p_commitment_rec        IN arp_process_commitment.commitment_rec_type,
  p_open_rec_flag         IN ra_cust_trx_types.accounting_affect_flag%type,
  p_term_in_use_flag      IN varchar2,
  p_recalc_tax_flag       IN boolean,
  p_rerun_autoacc_flag    IN boolean,
  p_ps_dispute_amount     IN NUMBER  DEFAULT NULL,
  p_ps_dispute_date       IN DATE    DEFAULT NULL,
  p_status               OUT NOCOPY varchar2)

                 IS

  l_rerun_autoacc_flag      boolean;  /* Bug-3454082  - 4019170 */
  l_frt_only_rules          boolean;
  l_ex_rate_changed_flag    boolean;
  l_commitment_changed_flag boolean;
  l_gl_date_changed_flag    boolean;
  l_complete_changed_flag   boolean;
  l_open_rec_changed_flag   boolean;
  l_dispute_changed_flag    boolean;
  l_cust_trx_type_changed_flag boolean;

  l_initial_customer_trx_line_id
                          ra_customer_trx_lines.initial_customer_trx_line_id%type;
  l_exchange_rate           ra_customer_trx.exchange_rate%type;
  l_invoice_currency_code   ra_customer_trx.invoice_currency_code%type;

  l_line_rec                ra_customer_trx_lines%rowtype;
  l_dist_rec                ra_cust_trx_line_gl_dist%rowtype;

  l_old_trx_rec             ra_customer_trx%rowtype;

  l_number_of_pay_scheds    NUMBER;
  l_new_tax_amount          NUMBER;
  l_recalc_tax              BOOLEAN;
  l_dummy_flag              varchar2(1); /* Bug-3454082 - 4019170 */

  l_status1                 varchar2(100);
  l_status2                 varchar2(100);
  l_status3                 varchar2(100);

--Bug# 2750340
  l_ev_rec                  arp_xla_events.xla_events_type;

--BUG#5192414
  CURSOR cpost IS
  SELECT 'Y'
    FROM ra_cust_trx_line_gl_dist
   WHERE customer_trx_id = p_customer_trx_id
     AND posting_control_id <> -3
     AND account_set_flag  = 'N';
 l_test    VARCHAR2(1);
--BUG#7366912
 l_event_source_info   xla_events_pub_pkg.t_event_source_info;
 l_event_id            NUMBER;
 l_security            xla_events_pub_pkg.t_security;
 l_post_to_gl          varchar2(100);
 l_event_status_code   varchar2(100);
BEGIN

   arp_util.debug('arp_process_header.update_header()+');

   -- check form version to determine if it is compatible with the
   -- entity handler.
      arp_trx_validate.ar_entity_version_check(p_form_name, p_form_version);

   -- do validation
      validate_update_header;

   -- Lock rows in other tables that reference this customer_trx_id
   /* Bug-3630210 - 3874863  Added the Exception class */
      Begin
        arp_trx_util.lock_transaction(p_customer_trx_id);
      Exception
         WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
              FND_MESSAGE.SET_NAME('AR','AR_TW_RECORD_LOCKED');
              app_exception.raise_exception;
         WHEN OTHERS THEN
              arp_util.debug('EXCEPTION:  arp_trx_util.delete_lock()');
              Raise;
      END;

   /*--------------------+
    |  pre-update logic  |
    +--------------------*/

   -- If tax user exit is going to be called in update mode (if
   -- recalculate_tax_flag = 'Y'), call salestax delete.  The Tax
   -- Vendor Code will then be able to "backout" these old tax rows.
   -- And, the subsequent call to AR SALESTAX UPDATE can be relied
   -- upon to just recalculate the new data.  This allows the Tax
   -- Vendor Code to keep an audit trail.


     l_recalc_tax := p_recalc_tax_flag;



   IF p_trx_class in ('DEP', 'GUAR')
     THEN arp_process_commitment.header_pre_update;
          -- does commitment validation
   END IF;

   set_flags(p_customer_trx_id,
             p_trx_rec,
             p_gl_date,
             p_open_rec_flag,
             p_ps_dispute_amount,
             p_ps_dispute_date,  -- pd_dispute_date
             l_ex_rate_changed_flag,
             l_commitment_changed_flag,
             l_gl_date_changed_flag,
             l_complete_changed_flag,
             l_open_rec_changed_flag,
             l_dispute_changed_flag,
             l_number_of_pay_scheds,
             l_old_trx_rec,
	     l_cust_trx_type_changed_flag);

   -- If transaction is a freight-only transaction with rules, then
   -- set invoicing_rule_id to null because autorule cannot handle freight
   -- only invoices with rules.

   l_frt_only_rules := FALSE;

   IF l_complete_changed_flag
     THEN
          IF p_trx_rec.complete_flag = 'Y'
            THEN
                 l_frt_only_rules :=
                   arp_trx_util.detect_freight_only_rules_case(
                                                     p_customer_trx_id);

                 IF l_frt_only_rules
                   THEN p_trx_rec.invoicing_rule_id := null;
                 END IF;
          END IF;
   END IF;

   /*----------------------+
    |  call table-handler  |
    +----------------------*/

   arp_ct_pkg.update_p(p_trx_rec, p_customer_trx_id);

  /*---------------------------------------------------------+
   |  Update the dispute amounts on the payment schedules if |
   |  the dispute amount has changed.                        |
   |
   |  10/10/1996  Harri Kaukovuo        Bug fix 411031.
   +---------------------------------------------------------*/

   IF ( l_dispute_changed_flag = TRUE )
   THEN
        DECLARE
        /*Adding cursor as part of bug fix 5129946*/
          CURSOR get_existing_ps (p_ctrx_id IN NUMBER) IS
          SELECT payment_schedule_id,
                 amount_in_dispute,
                 amount_due_remaining,
                 dispute_date
          FROM   ar_payment_schedules
          WHERE  customer_trx_id = p_ctrx_id;
          l_old_dispute_date        DATE;
          l_new_dispute_date        DATE;
          l_old_dispute_amount      NUMBER;
          l_amount_due_remaining    NUMBER;
          l_ps_id                   NUMBER;
          l_new_dispute_amount      NUMBER;
          l_sysdate                 DATE := SYSDATE;
          l_last_update_login       NUMBER := arp_standard.profile.last_update_login;
          l_user_id                 NUMBER := arp_standard.profile.user_id;
        BEGIN
          /*Bug 5129946: Calling arp_dispute_history.DisputeHistory*/
          OPEN get_existing_ps(p_customer_trx_id);
            FETCH get_existing_ps INTO
                  l_ps_id,
                  l_old_dispute_amount,
                  l_amount_due_remaining,
                  l_old_dispute_date;
            IF get_existing_ps%ROWCOUNT>0 THEN
            if(p_ps_dispute_amount = NULL) THEN
               l_new_dispute_amount := l_old_dispute_amount;
            ELSIF (p_ps_dispute_amount = 0) THEN
               l_new_dispute_amount := 0;
            ELSE
               IF(l_number_of_pay_scheds = 1) THEN
               l_new_dispute_amount := p_ps_dispute_amount;
               ELSE
               l_new_dispute_amount := l_amount_due_remaining;
               END IF;
            END IF;
            l_new_dispute_date := p_ps_dispute_date;
            if(l_new_dispute_amount <> l_old_dispute_amount)
            OR(l_new_dispute_amount IS NULL AND l_old_dispute_amount IS NOT NULL)
            OR(l_new_dispute_amount IS NOT NULL AND l_old_dispute_amount IS NULL)
            THEN
            arp_dispute_history.DisputeHistory(l_new_dispute_date,
                                               l_old_dispute_date,
                                               l_ps_id,
                                               l_ps_id,
                                               l_amount_due_remaining,
                                               l_new_dispute_amount,
                                               l_old_dispute_amount,
                                               l_user_id,
                                               l_sysdate,
                                               l_user_id,
                                               l_sysdate,
                                               l_last_update_login);
            END IF;
            END IF;--IF get_existing_ps%ROWCOUNT>0 THEN
            CLOSE get_existing_ps;
            UPDATE ar_payment_schedules ps
            SET    ps.amount_in_dispute = DECODE(p_ps_dispute_amount,
                                          NULL, ps.amount_in_dispute,
                                          0,    0,
                                               DECODE(l_number_of_pay_scheds,
                                                     1, p_ps_dispute_amount,
                                                     ps.amount_due_remaining)),
               ps.dispute_date      = p_ps_dispute_date
            WHERE  ps.customer_trx_id = p_customer_trx_id;
     END;
   END IF;

  /*---------------------+
   |  post-update logic  |
   +---------------------*/

   IF p_trx_rec.exchange_rate = pg_number_dummy
     THEN l_exchange_rate := nvl(l_old_trx_rec.exchange_rate, 1);
     ELSE l_exchange_rate := nvl(p_trx_rec.exchange_rate, 1);
   END IF;

   IF p_trx_class in ('DEP', 'GUAR')
     THEN
          IF p_trx_rec.invoice_currency_code = pg_text_dummy
            THEN l_invoice_currency_code :=
                           l_old_trx_rec.invoice_currency_code;
            ELSE l_invoice_currency_code :=
                           p_trx_rec.invoice_currency_code;
          END IF;

          arp_process_commitment.header_post_update(
                                   p_commitment_rec,
                                   l_invoice_currency_code,
                                   l_exchange_rate,
                                   p_rerun_autoacc_flag);
   END IF;

  /*--------------------------------------------------------------------+
   |  Clear Lines Rule Info for void transactions Bug-3454082-4019170   |
   +--------------------------------------------------------------------*/
     l_rerun_autoacc_flag := p_rerun_autoacc_flag;
/* Start FP Bug 5501665 Autoaccounting pops-up for tran tupe changed to void */
     IF (
          l_gl_date_changed_flag                AND
          p_gl_date       IS     NULL           AND
          p_trx_class     =     'INV'           AND
          p_trx_rec.invoicing_rule_id IS NULL	AND
	  	  l_old_trx_rec.invoicing_rule_id is not NULL
        )
     THEN
             arp_util.debug('Clearing Lines and dist  Rule Info ()+');
         BEGIN
              Select 'X' INTO l_dummy_flag
              FROM ra_customer_trx_lines
              WHERE customer_trx_id = p_customer_trx_id
              AND rownum = 1;

               arp_ctl_pkg.set_to_dummy( l_line_rec );
               l_line_rec.accounting_rule_id          := NULL;
               l_line_rec.accounting_rule_duration    := NULL;
               l_line_rec.rule_start_date             := NULL;
               l_line_rec.autorule_complete_flag      := NULL;
               l_line_rec.autorule_duration_processed := NULL;
             BEGIN
               arp_ctl_pkg.update_f_ct_id( l_line_rec,
                                           p_customer_trx_id,
                                            'LINE');
             EXCEPTION
             WHEN NO_DATA_FOUND THEN
                arp_util.debug('EXCEPTION: arp_process_header.Clearing Lines Rule Info: '||
                              'no child lines to update.');
             WHEN OTHERS THEN
                arp_util.debug('EXCEPTION:  '||
                                    'arp_process_header..Clearing Lines Rule Info()');
                RAISE;
             END;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                arp_util.debug('EXCEPTION: arp_process_header.update_header: '||
                              'no child lines to clear rule info.');
          END;
             BEGIN
               arp_ctlgd_pkg.delete_f_ct_id(p_customer_trx_id,
                                                      'Y',
                                                     NULL);
               l_rerun_autoacc_flag := TRUE;
             EXCEPTION
              WHEN NO_DATA_FOUND THEN
                     arp_util.debug('arp_process_header.Clearing GL Dist Rule Info : '||
                                     'no dists to delete.');
              WHEN OTHERS THEN
                     arp_util.debug('EXCEPTION:  '||
                      'arp_process_header.Clearing GL Dist Rule Info ()');
                    RAISE;
             END;
             arp_util.debug('Clearing Lines and dist Rule Info ()-');
      END IF;


   /*------------------------------------------------------------+
    |  If autoaccounting is rerun, it drops and recreates the    |
    |  distributions.  Therefore, we don't need to update        |
    |  the distributions if autoaccounting is rerun - they will  |
    |  already have the correct values.                          |
    +------------------------------------------------------------*/

   IF l_rerun_autoacc_flag  /* Bug-3454082 - 4019170 */
     THEN
        header_rerun_aa(p_customer_trx_id,
                          p_gl_date,
                          p_trx_amount,
                          l_status2);

     ELSE
          IF l_ex_rate_changed_flag
            THEN
              arp_ctlgd_pkg.update_acctd_amount(p_customer_trx_id,
                                                pg_base_curr_code,
                                                l_exchange_rate,
                                                pg_base_precision,
                                                pg_base_min_acc_unit);
          END IF;
   END IF;  /* IF l_rerun_autoacc_flag */
   /* Bug 1580246  Moved the following code from  the ELSE part of
      the above condition which checks for p_rerun_autoacc_flag
      so that the GL_DATE of the ROUND record is updated
      properly even when autoaccounting is re-run. */

          IF l_gl_date_changed_flag
            THEN
              -- update gl_date for all gl_distributions

              arp_ctlgd_pkg.set_to_dummy(l_dist_rec);

              l_dist_rec.gl_date := p_gl_date;

              BEGIN
                arp_ctlgd_pkg.update_f_ct_id(l_dist_rec,
                                             p_customer_trx_id,
                                             null,
                                             null);

                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    arp_util.debug('arp_process_header.update_header: '||
                                   'no dists to update.');
                  WHEN OTHERS THEN
                    arp_util.debug('EXCEPTION:  '||
                                   'arp_process_header.update_header()');
                    RAISE;

              END;
            END IF;  /* IF l_gl_date_changed_flag */

      /* Bug 2689013 Added the call to the procedure reverse_revrec_effect */

     /* Bug 2689013 Added the call to the procedure reverse_revrec_effect */
      IF l_complete_changed_flag  AND
         p_trx_rec.complete_flag = 'N' AND
         p_trx_rec.invoicing_rule_id IS NOT NULL
      THEN
         /* 5633334/5637907 - also reverse for CMs that have not
            been through Rev Rec yet */
         IF (p_trx_rec.previous_customer_trx_id IS NULL AND
             arpt_sql_func_util.get_revenue_recog_run_flag(p_customer_trx_id,
                                       p_trx_rec.invoicing_rule_id) = 'Y')
         OR (p_trx_rec.previous_customer_trx_id IS NOT NULL AND
             pg_use_inv_acctg = 'N' AND
             arpt_sql_func_util.get_revenue_recog_run_flag(
                     p_trx_rec.previous_customer_trx_id,
                     p_trx_rec.invoicing_rule_id) = 'Y')
         THEN
            reverse_revrec_effect(p_customer_trx_id);
         END IF;
      END IF;   /* IF l_complete_flag_changed */

     IF l_recalc_tax
     THEN
              pg_tax_flag := arp_trx_validate2.pg_tax_flag;
              arp_util.debug( 'Before Update TAX P'|| pg_tax_flag);

        /*------------------------------------------------------------------+
         | Do not update line tax codes when the Complete Flag is changed   |
         | to 'Y' and the system option Enforce from Revenue Account is 'Y'.|
         | Line tax codes are corrected when the checkbox is changed on the |
         | client side. Calling update_tax will erroneously override them.  |
         +------------------------------------------------------------------*/
	IF ( l_complete_changed_flag AND
	     p_trx_rec.complete_flag = 'Y' AND
	     nvl(ARP_GLOBAL.sysparam.tax_enforce_account_flag, 'N') = 'Y' ) THEN

	     -- Don't update line tax code, Would've been updated at the client
	     -- side.
	     null;
	ELSE
          /*------------------------------------------------------------------+
           | Call  update_tax to re-default line tax codes                    |
           +------------------------------------------------------------------*/
           arp_ct_pkg.update_tax(p_trx_rec.ship_to_site_use_id,
				p_trx_rec.bill_to_site_use_id,
		      		p_trx_rec.trx_date,
		      		p_trx_rec.cust_trx_type_id,
				p_customer_trx_id,
				pg_tax_flag,
				FALSE);
	END IF;


        -- Bug 446263: if the transaction type has the property
        -- Calculate_Tax=N, the automatically generated tax codes
        -- on the lines should be nulled out.

        /* Bug 5093094 - removed logic that nulled
           vat_tax_id when trx_type changed from
           cal_tax=Y to N.  Flag is no longer
           used in this way in R12 */

    END IF;

   IF (l_commitment_changed_flag
       OR
       (l_complete_changed_flag
        AND
        p_trx_rec.complete_flag = 'Y'
        AND
        p_trx_rec.initial_customer_trx_id IS NOT NULL
        AND
        nvl(p_trx_rec.initial_customer_trx_id, 0) <> pg_number_dummy)
      )
     THEN
       -- update ra_customer_trx_lines.initial_customer_trx_line_id
         IF (p_trx_rec.initial_customer_trx_id IS NOT NULL
             AND
             p_initial_customer_trx_line_id IS NULL)
         THEN
             BEGIN
                 SELECT customer_trx_line_id
                 INTO   l_initial_customer_trx_line_id
                 FROM   ra_customer_trx_lines ctl
                 WHERE  ctl.customer_trx_id = p_trx_rec.initial_customer_trx_id
                 AND    ctl.line_type = 'LINE';
             END;
         ELSE
            l_initial_customer_trx_line_id := p_initial_customer_trx_line_id;
         END IF;

         arp_ctl_pkg.set_to_dummy( l_line_rec );

         l_line_rec.initial_customer_trx_line_id :=
                                 l_initial_customer_trx_line_id;

       BEGIN
         arp_ctl_pkg.update_f_ct_id( l_line_rec,
                                     p_customer_trx_id,
                                     'LINE');

         EXCEPTION
           WHEN NO_DATA_FOUND THEN
               arp_util.debug('arp_process_header.update_header: '||
                              'no child lines to update.');
           WHEN OTHERS THEN
               arp_util.debug('EXCEPTION:  '||
                              'arp_process_header.update_header()');
               RAISE;
       END;
   END IF;

   IF l_frt_only_rules
     THEN
       -- update the account sets to be real dists.
       -- inv rule is cleared at complete time
       -- or when all 'line' lines are deleted
       -- if rules and freight only invoice.
       -- Reason is that autorule cannot handle freight only invoices
       -- with rules.

       -- There are two dists in this case:
       -- o The REC dist
       -- o The FREIGHT dist

       arp_ctlgd_pkg.set_to_dummy(l_dist_rec);

       l_dist_rec.account_set_flag := 'N';

       l_dist_rec.acctd_amount := arp_standard.functional_amount(
                                                 p_trx_amount,
                                                 pg_base_curr_code,
                                                 l_exchange_rate,
                                                 pg_base_precision,
                                                 pg_base_min_acc_unit);

       l_dist_rec.amount := p_trx_amount;
       l_dist_rec.gl_date := p_gl_date;
       l_dist_rec.original_gl_date := p_gl_date;

       arp_ctlgd_pkg.update_f_ct_id(l_dist_rec,
                                    p_customer_trx_id,
                                    null,
                                    null);
   END IF;


   -- IF l_complete_changed_flag
   --   THEN IF p_trx_rec.complete_flag = 'N'
   --          THEN delete the payment schedule(s) (if there is one)
   --          ELSE IF p_open_rec_flag = 'Y'
   --                 THEN tell post-commit that it needs to create the
   --                      payment schedule(s).
   --               END IF;
   --        END IF;
   --   ELSE IF l_open_rec_changed_flag
   --          THEN IF p_open_rec_flag = 'N'
   --                 THEN delete the payment schedule (s)
   --                 ELSE tell post-commit that it needs to create the
   --                      payment schedule(s).
   --               END IF;
   --          ELSE IF p_open_rec_flag = 'Y'
   --                 THEN tell post-commit that it needs to update the
   --                      payment schedule(s).
   --               END IF;
   --        END IF;
   -- END IF;

   IF p_trx_rec.term_id <> pg_number_dummy
     THEN
          arp_trx_util.set_term_in_use_flag(
                                     p_form_name,
                                     p_form_version,
                                     p_trx_rec.term_id,
                                     p_term_in_use_flag);
   END IF;

      arp_util.debug('l_status1  = ' || l_status1);
      arp_util.debug('l_status2  = ' || l_status2);
      arp_util.debug('l_status3  = ' || l_status3);

      IF    ( NVL(l_status1, 'OK') <> 'OK' )
      THEN  p_status := l_status1;
      ELSIF ( NVL(l_status2, 'OK') <> 'OK' )
         THEN  p_status := l_status2;
      ELSIF ( NVL(l_status3, 'OK') <> 'OK' )
         THEN  p_status := l_status3;
      ELSE     p_status := 'OK';
      END IF;

--BUG5192414
OPEN cpost;
FETCH cpost INTO l_test;
IF cpost%NOTFOUND THEN
--BUG#7366912
IF (p_gl_date is NULL)  THEN
  BEGIN
  select  xet.legal_entity_id legal_entity_id,
        ct.SET_OF_BOOKS_ID set_of_books_id,
        ct.org_id          org_id,
        xe.event_id        event_id,
        xet.entity_code     entity_code,
        ct.customer_trx_id   transaction_id,
        xet.application_id,
        ctt.post_to_gl,
        xe.event_status_code
        into
        l_event_source_info.legal_entity_id,
        l_event_source_info.ledger_id,
        l_security.security_id_int_1,
        l_event_id ,
        l_event_source_info.entity_type_code,
        l_event_source_info.source_id_int_1,
        l_event_source_info.application_id,
        l_post_to_gl,
        l_event_status_code
        from
        ra_customer_trx ct ,
        ra_cust_trx_types ctt,
        xla_transaction_entities_upg  xet ,
        xla_events xe
    where  ct.customer_trx_id  = p_customer_trx_id
        and   ctt.cust_trx_type_id = ct.cust_trx_type_id
        and   ct.customer_trx_id       = nvl(xet.source_id_int_1,-99)
        AND   ct.SET_OF_BOOKS_ID       = xet.LEDGER_ID
        and   xet.entity_code          ='TRANSACTIONS'
        AND   xet.application_id       = 222
        AND   xe.entity_id = xet.entity_id
        AND   xe.application_id = 222 ;

        IF ((l_post_to_gl ='N')
         AND (l_event_status_code = 'I'))  THEN

              xla_events_pub_pkg.delete_event
                        ( p_event_source_info   => l_event_source_info,
                          p_event_id            => l_event_id,
                          p_valuation_method    => NULL,
                          p_security_context    => l_security);

            update ra_cust_trx_line_gl_dist set event_id=null
            WHERE customer_trx_id = p_customer_trx_id
            and ACCOUNT_SET_FLAG='N'
            and event_id =l_event_id;

         END IF;
    EXCEPTION
     WHEN OTHERS THEN
           arp_util.debug('Unable to get the XLA Entites Data ' ||
           'EXCEPTION: arp_process_header.update_header()' );
         --RAISE;
    END;
END IF;

--Bug# 2750340
    ---------------------------------------------------------
    -- Call to ARP_XLA_EVENTS for transaction updation in
    -- Trx Workbench. Mandatory when user complete a document
    ---------------------------------------------------------
    l_ev_rec.xla_from_doc_id   := p_customer_trx_id;
    l_ev_rec.xla_to_doc_id     := p_customer_trx_id;
    l_ev_rec.xla_req_id        := NULL;
    l_ev_rec.xla_dist_id       := NULL;
    l_ev_rec.xla_doc_table     := 'CT';
    l_ev_rec.xla_doc_event     := NULL;
    l_ev_rec.xla_mode          := 'O';
    l_ev_rec.xla_call          := 'B';
    l_ev_rec.xla_fetch_size    := 999;
    arp_xla_events.create_events(p_xla_ev_rec => l_ev_rec );

END IF;
CLOSE cpost;

   arp_util.debug('arp_process_header.update_header()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_process_header.update_header()');
        RAISE;

END;

--added for bug 7478499
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_cont_defer_data                                                 |         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    deletes rows from ar_line_conts and ar_deferred_lines.                 |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:        p_customer_trx_id                                 |                 |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     07-NOV-08  Ankur Agarwal      Created                                 |
 |                                                                           |
 |                                                                           |
 +===========================================================================*/

PROCEDURE delete_cont_defer_data(p_customer_trx_id IN NUMBER) IS
CURSOR cont_cursor IS
   select alc.customer_trx_line_id
   from  ra_customer_trx_lines ctl,
         ar_line_conts alc
   where
   ctl.customer_trx_id = p_customer_trx_id
   and ctl.customer_trx_line_id = alc.customer_trx_line_id
   and ctl.line_type = 'LINE'
   FOR UPDATE OF alc.customer_trx_line_id NOWAIT;

CURSOR deferred_cursor IS
   select customer_trx_id
   from  ar_deferred_lines
   where customer_trx_id = p_customer_trx_id
   FOR UPDATE OF customer_trx_id NOWAIT;


BEGIN
arp_util.debug('arp_process_header.delete_cont_defer_data+');

FOR l_cont_rec IN cont_cursor LOOP
          delete from ar_line_conts
          where customer_trx_line_id = l_cont_rec.customer_trx_line_id;
END LOOP;

FOR l_deferred_rec IN deferred_cursor LOOP
          delete from ar_deferred_lines
          WHERE  customer_trx_id = l_deferred_rec.customer_trx_id;
END LOOP;

arp_util.debug('arp_process_header.delete_cont_defer_data-');
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      null;
    WHEN OTHERS THEN
    arp_util.debug('EXCEPTION : '||
                   'arp_process_header.delete_cont_defer_data()-');
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_header                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    deletes row from ra_customer_trx.  Also deletes all child rows.        |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     26-JUL-95  Martin Johnson      Created                                |
 |     29-NOV-95  Nigel Smith         Added call to Tax Engine.              |
 |                                                                           |
 +===========================================================================*/

PROCEDURE delete_header(
  p_form_name             IN varchar2,
  p_form_version          IN number,
  p_customer_trx_id       IN number,
  p_trx_class             IN varchar2,
  p_status               OUT NOCOPY varchar2)

  IS

  l_new_tax_amount        NUMBER;

BEGIN

   arp_util.debug('arp_process_header.delete_header()+');

   p_status := 'OK';

   -- check form version to determine if it is compatible with the
   -- entity handler.
      arp_trx_validate.ar_entity_version_check(p_form_name, p_form_version);

   -- do validation
      validate_delete_header;

   -- Lock rows in other tables that reference this customer_trx_id
      arp_trx_util.lock_transaction(p_customer_trx_id);

   /*--------------------+
    |  pre-delete logic  |
    +--------------------*/

      IF p_trx_class in ('DEP', 'GUAR')
      THEN arp_process_commitment.header_pre_delete;
             -- does commitment validation
      ELSE
        /* 5156232 - remove tax from etax repository */
        ARP_ETAX_UTIL.GLOBAL_DOCUMENT_UPDATE(p_customer_trx_id,
                                             NULL,'DELETE');
      END IF;


    --Bug#2750340
    --Bug # 6450286
    --------------------------------
    -- Delete the corresponding event in XLA schema
    --------------------------------
     ARP_XLA_EVENTS.delete_event( p_document_id  => p_customer_trx_id,
                                  p_doc_table    => 'CT');

    --added for bug 7478499
    delete_cont_defer_data(p_customer_trx_id);
   /*-------------------------+
    |  delete the transaction |
    +-------------------------*/

     arp_trx_util.delete_transaction(p_form_name,
                                     p_form_version,
                                     p_customer_trx_id);




     arp_util.debug('arp_process_header.delete_header()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_process_header.delete_header()');
        RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    post_commit                                                            |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Performs logic that must occur after all of the other logic for the    |
 |    insertion or update of a transaction has occurred.                     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |    arp_maintain_ps.maintain_payment_schedules                             |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-AUG-95  Charlie Tomberg      Created                               |
 |      19-FEB-96  Oliver Steinmeier   Changed logic in post-commit to       |
 |                                     make sure the payment schedule        |
 |                                     gets called for debit memos           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE post_commit( p_form_name                    IN varchar2,
                       p_form_version                 IN number,
                       p_customer_trx_id              IN
                                      ra_customer_trx.customer_trx_id%type,
                       p_previous_customer_trx_id     IN
                               ra_customer_trx.previous_customer_trx_id%type,
                       p_complete_flag                IN
                               ra_customer_trx.complete_flag%type,
                       p_trx_open_receivables_flag    IN
                                 ra_cust_trx_types.accounting_affect_flag%type,
                       p_prev_open_receivables_flag   IN
                                 ra_cust_trx_types.accounting_affect_flag%type,
                       p_creation_sign                IN
                                 ra_cust_trx_types.creation_sign%type,
                       p_allow_overapplication_flag   IN
                             ra_cust_trx_types.allow_overapplication_flag%type,
                       p_natural_application_flag     IN
                          ra_cust_trx_types.natural_application_only_flag%type,
                       p_cash_receipt_id              IN
                          ar_cash_receipts.cash_receipt_id%type DEFAULT NULL
                     ) IS

BEGIN

          arp_process_header_post_commit.
                    post_commit( p_form_name,
                                 p_form_version,
                                 p_customer_trx_id,
                                 p_previous_customer_trx_id,
                                 p_complete_flag,
                                 p_trx_open_receivables_flag,
                                 p_prev_open_receivables_flag,
                                 p_creation_sign,
                                 p_allow_overapplication_flag,
                                 p_natural_application_flag,
                                 p_cash_receipt_id,
                                 'STANDARD'
                               );

END;



/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_header_freight_cover                                            |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Converts column parameters to a header transaction record and          |
 |    updates the freight columns on the transaction header                  |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_form_name                                            |
 |                    p_form_version                                         |
 |                    p_trx_class                                            |
 |                    p_open_rec_flag                                        |
 |                    p_ship_via                                             |
 |                    p_ship_date_actual                                     |
 |                    p_waybill_number                                       |
 |                    p_fob_point                                            |
 |              OUT:                                                         |
 |                    p_status                                               |
 |          IN/ OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     10-OCT-95  Subash Chadalavada  Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_header_freight_cover(
  p_form_name             IN varchar2,
  p_form_version          IN number,
  p_customer_trx_id       IN ra_customer_trx.customer_trx_id%type,
  p_trx_class             IN ra_cust_trx_types.type%type,
  p_open_rec_flag         IN ra_cust_trx_types.accounting_affect_flag%type,
  p_ship_via              IN ra_customer_trx.ship_via%type,
  p_ship_date_actual      IN ra_customer_trx.ship_date_actual%type,
  p_waybill_number        IN ra_customer_trx.waybill_number%type,
  p_fob_point             IN ra_customer_trx.fob_point%type,
  p_status               OUT NOCOPY varchar2)

IS

  l_trx_rec     ra_customer_trx%rowtype;
  l_commit_rec  arp_process_commitment.commitment_rec_type;
  l_dummy       varchar2(80);

BEGIN

    arp_util.debug('arp_process_header.update_header_freight_cover()+');

    arp_ct_pkg.set_to_dummy(l_trx_rec);

    l_trx_rec.ship_via         := p_ship_via;
    l_trx_rec.ship_date_actual := p_ship_date_actual;
    l_trx_rec.waybill_number   := p_waybill_number;
    l_trx_rec.fob_point        := p_fob_point;

    update_header(
                   p_form_name,
                   p_form_version,
                   l_trx_rec,
                   p_customer_trx_id,
                   null,
                   p_trx_class,
                   pg_date_dummy,
                   null,
                   l_commit_rec,
                   null,
                   null,
                   null,
                   null,
                   null,
                   null,
                   p_status);

    arp_util.debug('arp_process_header.update_header_freight_cover()-');

EXCEPTION
  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION : '||
                   'arp_process_header.update_header_freight_cover()-');
    arp_util.debug('------- parameters for update_header_freight_cover ----');
    arp_util.debug('p_form_name        = '||p_form_name);
    arp_util.debug('p_form_version     = '||p_form_version);
    arp_util.debug('p_ship_via         = '||p_ship_via);
    arp_util.debug('p_ship_date_actual = '||p_ship_date_actual);
    arp_util.debug('p_waybill_number   = '||p_waybill_number);
    arp_util.debug('p_fob_point        = '||p_fob_point);

    RAISE;
END;



/*===========================================================================+
 | PROCEDURE                                                                 |
 |    post_query()                                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Selects additional data from the database in the following cases:      |
 |      - The transaction is the child of a commitment                       |
 |      - The transaction is a commitment                                    |
 |      - The transaction is a credit memo against a specific transaction    |
 |        (not on account).                                                  |
 |                                                                           |
 |    This procedure was created so that the ra_customer_trx_v view could    |
 |    be simplified by removing koins to support these special cases.        |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_ct_rowid                                               |
 |                  p_customer_trx_id                                        |
 |                  p_initial_customer_trx_id                                |
 |                  p_previous_customer_trx_id                               |
 |                  p_class                                                  |
 |              OUT:                                                         |
 |                  p_ct_commitment_trx_date                                 |
 |                  p_ct_commitment_number                                   |
 |                  p_gd_commitment_gl_date                                  |
 |                  p_ctl_commit_cust_trx_line_id                            |
 |                  p_ctl_commitment_amount                                  |
 |                  p_ctl_commitment_text                                    |
 |                  p_ctl_commitment_inv_item_id                             |
 |                  p_interface_line_context                                 |
 |                  p_interface_line_attribute1                              |
 |                  p_interface_line_attribute2                              |
 |                  p_interface_line_attribute3                              |
 |                  p_interface_line_attribute4                              |
 |                  p_interface_line_attribute5                              |
 |                  p_interface_line_attribute6                              |
 |                  p_interface_line_attribute7                              |
 |                  p_interface_line_attribute8                              |
 |                  p_interface_line_attribute9                              |
 |                  p_interface_line_attribute10                             |
 |                  p_interface_line_attribute11                             |
 |                  p_interface_line_attribute12                             |
 |                  p_interface_line_attribute13                             |
 |                  p_interface_line_attribute14                             |
 |                  p_interface_line_attribute15                             |
 |                  p_attribute_category                                     |
 |                  p_attribute1                                             |
 |                  p_attribute2                                             |
 |                  p_attribute3                                             |
 |                  p_attribute4                                             |
 |                  p_attribute5                                             |
 |                  p_attribute6                                             |
 |                  p_attribute7                                             |
 |                  p_attribute8                                             |
 |                  p_attribute9                                             |
 |                  p_attribute10                                            |
 |                  p_attribute11                                            |
 |                  p_attribute12                                            |
 |                  p_attribute13                                            |
 |                  p_attribute14                                            |
 |                  p_attribute15                                            |
 |                  p_ct_prev_trx_number                                     |
 |                  p_ct_prev_trx_reference                                  |
 |                  p_ct_prev_inv_currency_code                              |
 |                  p_ct_prev_trx_date                                       |
 |                  p_ct_prev_bill_to_customer_id                            |
 |                  p_ct_prev_ship_to_customer_id                            |
 |                  p_ct_prev_sold_to_customer_id                            |
 |                  p_ct_prev_paying_customer_id                             |
 |                  p_ct_prev_bill_to_site_use_id                            |
 |                  p_ct_prev_ship_to_site_use_id                            |
 |                  p_ct_prev_paying_site_use_id                             |
 |                  p_ct_prev_bill_to_contact_id                             |
 |                  p_ct_prev_ship_to_contact_id                             |
 |                  p_ct_prev_initial_cust_trx_id                            |
 |                  p_ct_prev_primary_salesrep_id                            |
 |                  p_ct_prev_invoicing_rule_id                              |
 |                  p_gd_prev_gl_date                                        |
 |                  p_prev_trx_original                                      |
 |                  p_prev_trx_balance                                       |
 |                  p_rac_prev_bill_to_cust_name                             |
 |                  p_rac_prev_bill_to_cust_num                              |
 |                  p_bs_prev_source_name                                    |
 |                  p_ctt_prev_class                                         |
 |                  p_ctt_prev_allow_overapp_flag                            |
 |                  p_ctt_prev_natural_app_only                              |
 |                  p_al_cm_reason_meaning                                   |
 |          IN/ OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     05-APR-96  Charlie Tomberg     Created                                |
 |     08-MAY-96  Martin Johnson      BugNo:345208.  Return p_ctl_commitment_|
 |                                    inv_item_id for Child Of A Commitment  |
 |                                    case                                   |
 |     20-Oct-04  Surendra Rajan      Bug-3954193 : Added two parameters ct_ |
 |                                    prev_open_receviables and ct_prev_post_|
 |                                    to_gl_flag in the procedure post_query.|
 |                                                                           |
 |                                                                           |
 +===========================================================================*/

PROCEDURE post_query(
                      p_ct_rowid                        IN varchar2,
                      p_customer_trx_id                 IN NUMBER,
                      p_initial_customer_trx_id         IN NUMBER,
                      p_previous_customer_trx_id        IN NUMBER,
                      p_class                           IN varchar2,
                      p_ct_commitment_trx_date         OUT NOCOPY date,
                      p_ct_commitment_number           OUT NOCOPY varchar2,
                      p_gd_commitment_gl_date          OUT NOCOPY date,
                      p_ctl_commit_cust_trx_line_id    OUT NOCOPY number,
                      p_ctl_commitment_amount          OUT NOCOPY number,
                      p_ctl_commitment_text            OUT NOCOPY varchar2,
                      p_ctl_commitment_inv_item_id     OUT NOCOPY number,
                      p_interface_line_context         OUT NOCOPY varchar2,
                      p_interface_line_attribute1      OUT NOCOPY varchar2,
                      p_interface_line_attribute2      OUT NOCOPY varchar2,
                      p_interface_line_attribute3      OUT NOCOPY varchar2,
                      p_interface_line_attribute4      OUT NOCOPY varchar2,
                      p_interface_line_attribute5      OUT NOCOPY varchar2,
                      p_interface_line_attribute6      OUT NOCOPY varchar2,
                      p_interface_line_attribute7      OUT NOCOPY varchar2,
                      p_interface_line_attribute8      OUT NOCOPY varchar2,
                      p_interface_line_attribute9      OUT NOCOPY varchar2,
                      p_interface_line_attribute10     OUT NOCOPY varchar2,
                      p_interface_line_attribute11     OUT NOCOPY varchar2,
                      p_interface_line_attribute12     OUT NOCOPY varchar2,
                      p_interface_line_attribute13     OUT NOCOPY varchar2,
                      p_interface_line_attribute14     OUT NOCOPY varchar2,
                      p_interface_line_attribute15     OUT NOCOPY varchar2,
                      p_attribute_category             OUT NOCOPY varchar2,
                      p_attribute1                     OUT NOCOPY varchar2,
                      p_attribute2                     OUT NOCOPY varchar2,
                      p_attribute3                     OUT NOCOPY varchar2,
                      p_attribute4                     OUT NOCOPY varchar2,
                      p_attribute5                     OUT NOCOPY varchar2,
                      p_attribute6                     OUT NOCOPY varchar2,
                      p_attribute7                     OUT NOCOPY varchar2,
                      p_attribute8                     OUT NOCOPY varchar2,
                      p_attribute9                     OUT NOCOPY varchar2,
                      p_attribute10                    OUT NOCOPY varchar2,
                      p_attribute11                    OUT NOCOPY varchar2,
                      p_attribute12                    OUT NOCOPY varchar2,
                      p_attribute13                    OUT NOCOPY varchar2,
                      p_attribute14                    OUT NOCOPY varchar2,
                      p_attribute15                    OUT NOCOPY varchar2,
                      p_default_ussgl_trx_code         OUT NOCOPY varchar2,
                      p_ct_prev_trx_number             OUT NOCOPY varchar2,
                      p_ct_prev_trx_reference          OUT NOCOPY varchar2,
                      p_ct_prev_inv_currency_code      OUT NOCOPY varchar2,
                      p_ct_prev_trx_date               OUT NOCOPY date,
                      p_ct_prev_bill_to_customer_id    OUT NOCOPY number,
                      p_ct_prev_ship_to_customer_id    OUT NOCOPY number,
                      p_ct_prev_sold_to_customer_id    OUT NOCOPY number,
                      p_ct_prev_paying_customer_id     OUT NOCOPY number,
                      p_ct_prev_bill_to_site_use_id    OUT NOCOPY number,
                      p_ct_prev_ship_to_site_use_id    OUT NOCOPY number,
                      p_ct_prev_paying_site_use_id     OUT NOCOPY number,
                      p_ct_prev_bill_to_contact_id     OUT NOCOPY number,
                      p_ct_prev_ship_to_contact_id     OUT NOCOPY number,
                      p_ct_prev_initial_cust_trx_id    OUT NOCOPY number,
                      p_ct_prev_primary_salesrep_id    OUT NOCOPY number,
                      p_ct_prev_invoicing_rule_id      OUT NOCOPY number,
                      p_gd_prev_gl_date                OUT NOCOPY date,
                      p_prev_trx_original              OUT NOCOPY number,
                      p_prev_trx_balance               OUT NOCOPY number,
                      p_rac_prev_bill_to_cust_name     OUT NOCOPY varchar2,
                      p_rac_prev_bill_to_cust_num      OUT NOCOPY varchar2,
                      p_bs_prev_source_name            OUT NOCOPY varchar2,
                      p_ctt_prev_class                 OUT NOCOPY varchar2,
                      p_ctt_prev_allow_overapp_flag    OUT NOCOPY varchar2,
                      p_ctt_prev_natural_app_only      OUT NOCOPY varchar2,
                      p_ct_prev_open_receivables       OUT NOCOPY varchar2,    /* Bug-3954193 */
                      p_ct_prev_post_to_gl_flag        OUT NOCOPY varchar2,    /* Bug-3954193 */
                      p_al_cm_reason_meaning           OUT NOCOPY varchar2,
		      p_commit_memo_line_id            OUT NOCOPY number,
                      p_commit_memo_line_desc          OUT NOCOPY varchar2
                    ) IS

    l_ct_commitment_trx_date       ra_customer_trx.trx_date%type;
    l_ct_commitment_number         ra_customer_trx.trx_number%type;
    l_gd_commitment_gl_date        ra_cust_trx_line_gl_dist.gl_date%type;
    l_ctl_commit_cust_trx_line_id
         ra_customer_trx_lines.customer_trx_line_id%type;
    l_ctl_commitment_amount       ra_customer_trx_lines.extended_amount%type;
    l_ctl_commitment_text         ra_customer_trx_lines.description%type;
    l_ctl_commitment_inv_item_id  ra_customer_trx_lines.inventory_item_id%type;
    l_interface_line_context
         ra_customer_trx_lines.interface_line_context%type;
    l_interface_line_attribute1
         ra_customer_trx_lines.interface_line_attribute1%type;
    l_interface_line_attribute2
         ra_customer_trx_lines.interface_line_attribute2%type;
    l_interface_line_attribute3
         ra_customer_trx_lines.interface_line_attribute3%type;
    l_interface_line_attribute4
         ra_customer_trx_lines.interface_line_attribute4%type;
    l_interface_line_attribute5
         ra_customer_trx_lines.interface_line_attribute5%type;
    l_interface_line_attribute6
         ra_customer_trx_lines.interface_line_attribute6%type;
    l_interface_line_attribute7
         ra_customer_trx_lines.interface_line_attribute7%type;
    l_interface_line_attribute8
         ra_customer_trx_lines.interface_line_attribute8%type;
    l_interface_line_attribute9
         ra_customer_trx_lines.interface_line_attribute9%type;
    l_interface_line_attribute10
         ra_customer_trx_lines.interface_line_attribute10%type;
    l_interface_line_attribute11
         ra_customer_trx_lines.interface_line_attribute11%type;
    l_interface_line_attribute12
         ra_customer_trx_lines.interface_line_attribute12%type;
    l_interface_line_attribute13
         ra_customer_trx_lines.interface_line_attribute13%type;
    l_interface_line_attribute14
         ra_customer_trx_lines.interface_line_attribute14%type;
    l_interface_line_attribute15
         ra_customer_trx_lines.interface_line_attribute15%type;
    l_attribute_category
         ra_customer_trx_lines.attribute_category%type;
    l_attribute1
         ra_customer_trx_lines.attribute1%type;
    l_attribute2
         ra_customer_trx_lines.attribute2%type;
    l_attribute3
         ra_customer_trx_lines.attribute3%type;
    l_attribute4
         ra_customer_trx_lines.attribute4%type;
    l_attribute5
         ra_customer_trx_lines.attribute5%type;
    l_attribute6
         ra_customer_trx_lines.attribute6%type;
    l_attribute7
         ra_customer_trx_lines.attribute7%type;
    l_attribute8
         ra_customer_trx_lines.attribute8%type;
    l_attribute9
         ra_customer_trx_lines.attribute9%type;
    l_attribute10
         ra_customer_trx_lines.attribute10%type;
    l_attribute11
         ra_customer_trx_lines.attribute11%type;
    l_attribute12
         ra_customer_trx_lines.attribute12%type;
    l_attribute13
         ra_customer_trx_lines.attribute13%type;
    l_attribute14
         ra_customer_trx_lines.attribute14%type;
    l_attribute15
         ra_customer_trx_lines.attribute15%type;
    l_default_ussgl_trx_code
         ra_customer_trx_lines.default_ussgl_transaction_code%type;
    l_ct_prev_trx_number              ra_customer_trx.trx_number%type;
    l_ct_prev_trx_reference
         ra_customer_trx.interface_header_attribute1%type;
    l_ct_prev_inv_currency_code
         ra_customer_trx.invoice_currency_code%type;
    l_ct_prev_trx_date                ra_customer_trx.trx_date%type;
    l_ct_prev_bill_to_customer_id     ra_customer_trx.bill_to_customer_id%type;
    l_ct_prev_ship_to_customer_id     ra_customer_trx.ship_to_customer_id%type;
    l_ct_prev_sold_to_customer_id     ra_customer_trx.sold_to_customer_id%type;
    l_ct_prev_paying_customer_id      ra_customer_trx.paying_customer_id%type;
    l_ct_prev_bill_to_site_use_id     ra_customer_trx.bill_to_site_use_id%type;
    l_ct_prev_ship_to_site_use_id     ra_customer_trx.ship_to_site_use_id%type;
    l_ct_prev_paying_site_use_id      ra_customer_trx.paying_site_use_id%type;
    l_ct_prev_bill_to_contact_id      ra_customer_trx.bill_to_contact_id%type;
    l_ct_prev_ship_to_contact_id      ra_customer_trx.ship_to_contact_id%type;
    l_ct_prev_initial_cust_trx_id     ra_customer_trx.customer_trx_id%type;
    l_ct_prev_primary_salesrep_id     ra_customer_trx.primary_salesrep_id%type;
    l_ct_prev_invoicing_rule_id       ra_customer_trx.invoicing_rule_id%type;
    l_gd_prev_gl_date                 ra_cust_trx_line_gl_dist.gl_date%type;
    l_prev_trx_original               number;
    l_prev_trx_balance                number;
    l_rac_prev_bill_to_cust_name      hz_parties.party_name%type;
    l_rac_prev_bill_to_cust_num       hz_cust_accounts.account_number%type;
    l_bs_prev_source_name             ra_batch_sources.name%type;
    l_ctt_prev_class                  ra_cust_trx_types.type%type;
    l_ctt_prev_allow_overapp_flag
        ra_cust_trx_types.allow_overapplication_flag%type;
    l_ctt_prev_natural_app_only
        ra_cust_trx_types.natural_application_only_flag%type;
    l_ct_prev_open_receivables
        ra_cust_trx_types.accounting_affect_flag%type;                  /* Bug-3954193 */
    l_ct_prev_post_to_gl_flag
        ra_cust_trx_types.post_to_gl%type;                              /* Bug-3954193 */
    l_al_cm_reason_meaning            ar_lookups.meaning%type;
    l_ct_prev_rowid                   rowid;
    l_commit_memo_line_id             ra_customer_trx_lines.memo_line_id%type;
    l_commit_memo_line_desc           ar_memo_lines.description%type;

BEGIN

    arp_util.debug('arp_process_header.post_query()+');

  /*-----------------------------------------+
   |  Initialize the OUT NOCOPY parameters to NULL  |
   +-----------------------------------------*/

    p_ct_commitment_trx_date            := NULL;
    p_ct_commitment_number              := NULL;
    p_gd_commitment_gl_date             := NULL;
    p_ctl_commit_cust_trx_line_id       := NULL;
    p_ctl_commitment_amount             := NULL;
    p_ctl_commitment_text               := NULL;
    p_ctl_commitment_inv_item_id        := NULL;
    p_interface_line_context            := NULL;
    p_interface_line_attribute1         := NULL;
    p_interface_line_attribute2         := NULL;
    p_interface_line_attribute3         := NULL;
    p_interface_line_attribute4         := NULL;
    p_interface_line_attribute5         := NULL;
    p_interface_line_attribute6         := NULL;
    p_interface_line_attribute7         := NULL;
    p_interface_line_attribute8         := NULL;
    p_interface_line_attribute9         := NULL;
    p_interface_line_attribute10        := NULL;
    p_interface_line_attribute11        := NULL;
    p_interface_line_attribute12        := NULL;
    p_interface_line_attribute13        := NULL;
    p_interface_line_attribute14        := NULL;
    p_interface_line_attribute15        := NULL;
    p_default_ussgl_trx_code            := NULL;
    p_attribute_category                := NULL;
    p_attribute1                        := NULL;
    p_attribute2                        := NULL;
    p_attribute3                        := NULL;
    p_attribute4                        := NULL;
    p_attribute5                        := NULL;
    p_attribute6                        := NULL;
    p_attribute7                        := NULL;
    p_attribute8                        := NULL;
    p_attribute9                        := NULL;
    p_attribute10                       := NULL;
    p_attribute11                       := NULL;
    p_attribute12                       := NULL;
    p_attribute13                       := NULL;
    p_attribute14                       := NULL;
    p_attribute15                       := NULL;
    p_ct_prev_trx_number                := NULL;
    p_ct_prev_trx_reference             := NULL;
    p_ct_prev_inv_currency_code         := NULL;
    p_ct_prev_trx_date                  := NULL;
    p_ct_prev_bill_to_customer_id       := NULL;
    p_ct_prev_ship_to_customer_id       := NULL;
    p_ct_prev_sold_to_customer_id       := NULL;
    p_ct_prev_paying_customer_id        := NULL;
    p_ct_prev_bill_to_site_use_id       := NULL;
    p_ct_prev_ship_to_site_use_id       := NULL;
    p_ct_prev_paying_site_use_id        := NULL;
    p_ct_prev_bill_to_contact_id        := NULL;
    p_ct_prev_ship_to_contact_id        := NULL;
    p_ct_prev_initial_cust_trx_id       := NULL;
    p_ct_prev_primary_salesrep_id       := NULL;
    p_ct_prev_invoicing_rule_id         := NULL;
    p_gd_prev_gl_date                   := NULL;
    p_prev_trx_original                 := NULL;
    p_prev_trx_balance                  := NULL;
    p_rac_prev_bill_to_cust_name        := NULL;
    p_rac_prev_bill_to_cust_num         := NULL;
    p_bs_prev_source_name               := NULL;
    p_ctt_prev_class                    := NULL;
    p_ctt_prev_allow_overapp_flag       := NULL;
    p_ctt_prev_natural_app_only         := NULL;
    p_ct_prev_open_receivables          := NULL;   /* Bug-3954193 */
    p_ct_prev_post_to_gl_flag           := NULL;   /* Bug-3954193 */
    p_al_cm_reason_meaning              := NULL;
    p_commit_memo_line_id               := NULL;
    p_commit_memo_line_desc             := NULL;


   /*------------------------------+
    |  Child Of A Commitment case  |
    +------------------------------*/

    IF ( p_initial_customer_trx_id IS NOT NULL )
    THEN
           SELECT ct_commit.trx_date,
                  ct_commit.trx_number,
                  gd_commit.gl_date,
                  ctl_commit.inventory_item_id
           INTO   l_ct_commitment_trx_date,
                  l_ct_commitment_number,
                  l_gd_commitment_gl_date,
                  l_ctl_commitment_inv_item_id
           FROM   ra_customer_trx              ct_commit,
                  ra_cust_trx_line_gl_dist     gd_commit,
                  ra_customer_trx_lines        ctl_commit
           WHERE  ct_commit.customer_trx_id    = p_initial_customer_trx_id
           AND    ct_commit.customer_trx_id    = ctl_commit.customer_trx_id
           AND    ct_commit.customer_trx_id    = gd_commit.customer_trx_id
           AND    'REC'                        = gd_commit.account_class(+)
           AND    'Y'                          = gd_commit.latest_rec_flag(+);

           p_ct_commitment_trx_date     := l_ct_commitment_trx_date;
           p_ct_commitment_number       := l_ct_commitment_number;
           p_gd_commitment_gl_date      := l_gd_commitment_gl_date;
           p_ctl_commitment_inv_item_id := l_ctl_commitment_inv_item_id;

    END IF;


   /*-------------------+
    |  Commitment case  |
    +-------------------*/

    IF (p_class IN ('DEP', 'GUAR'))
    THEN
           BEGIN
                SELECT ctl_commit.customer_trx_line_id,
                       ctl_commit.extended_amount,
                       ctl_commit.description,
                       ctl_commit.inventory_item_id,
                       ctl_commit.interface_line_context,
                       ctl_commit.interface_line_attribute1,
                       ctl_commit.interface_line_attribute2,
                       ctl_commit.interface_line_attribute3,
                       ctl_commit.interface_line_attribute4,
                       ctl_commit.interface_line_attribute5,
                       ctl_commit.interface_line_attribute6,
                       ctl_commit.interface_line_attribute7,
                       ctl_commit.interface_line_attribute8,
                       ctl_commit.interface_line_attribute9,
                       ctl_commit.interface_line_attribute10,
                       ctl_commit.interface_line_attribute11,
                       ctl_commit.interface_line_attribute12,
                       ctl_commit.interface_line_attribute13,
                       ctl_commit.interface_line_attribute14,
                       ctl_commit.interface_line_attribute15,
                       ctl_commit.attribute_category,
                       ctl_commit.attribute1,
                       ctl_commit.attribute2,
                       ctl_commit.attribute3,
                       ctl_commit.attribute4,
                       ctl_commit.attribute5,
                       ctl_commit.attribute6,
                       ctl_commit.attribute7,
                       ctl_commit.attribute8,
                       ctl_commit.attribute9,
                       ctl_commit.attribute10,
                       ctl_commit.attribute11,
                       ctl_commit.attribute12,
                       ctl_commit.attribute13,
                       ctl_commit.attribute14,
                       ctl_commit.attribute15,
                       ctl_commit.default_ussgl_transaction_code,
                       ctl_commit.memo_line_id
                INTO   l_ctl_commit_cust_trx_line_id,
                       l_ctl_commitment_amount,
                       l_ctl_commitment_text,
                       l_ctl_commitment_inv_item_id,
                       l_interface_line_context,
                       l_interface_line_attribute1,
                       l_interface_line_attribute2,
                       l_interface_line_attribute3,
                       l_interface_line_attribute4,
                       l_interface_line_attribute5,
                       l_interface_line_attribute6,
                       l_interface_line_attribute7,
                       l_interface_line_attribute8,
                       l_interface_line_attribute9,
                       l_interface_line_attribute10,
                       l_interface_line_attribute11,
                       l_interface_line_attribute12,
                       l_interface_line_attribute13,
                       l_interface_line_attribute14,
                       l_interface_line_attribute15,
                       l_attribute_category,
                       l_attribute1,
                       l_attribute2,
                       l_attribute3,
                       l_attribute4,
                       l_attribute5,
                       l_attribute6,
                       l_attribute7,
                       l_attribute8,
                       l_attribute9,
                       l_attribute10,
                       l_attribute11,
                       l_attribute12,
                       l_attribute13,
                       l_attribute14,
                       l_attribute15,
                       l_default_ussgl_trx_code,
                       l_commit_memo_line_id
                FROM   ra_customer_trx_lines     ctl_commit
                WHERE  ctl_commit.customer_trx_id   = p_customer_trx_id
                AND    1                            = ctl_commit.line_number
                AND    'LINE'                       = ctl_commit.line_type;

                p_ctl_commit_cust_trx_line_id           :=
                       l_ctl_commit_cust_trx_line_id;
                p_ctl_commitment_amount                 :=
                       l_ctl_commitment_amount;
                p_ctl_commitment_text                   :=
                       l_ctl_commitment_text;
                p_ctl_commitment_inv_item_id            :=
                       l_ctl_commitment_inv_item_id;
                p_interface_line_context                :=
                       l_interface_line_context;
                p_interface_line_attribute1             :=
                       l_interface_line_attribute1;
                p_interface_line_attribute2             :=
                       l_interface_line_attribute2;
                p_interface_line_attribute3             :=
                       l_interface_line_attribute3;
                p_interface_line_attribute4             :=
                       l_interface_line_attribute4;
                p_interface_line_attribute5             :=
                       l_interface_line_attribute5;
                p_interface_line_attribute6             :=
                       l_interface_line_attribute6;
                p_interface_line_attribute7             :=
                       l_interface_line_attribute7;
                p_interface_line_attribute8             :=
                       l_interface_line_attribute8;
                p_interface_line_attribute9             :=
                       l_interface_line_attribute9;
                p_interface_line_attribute10            :=
                       l_interface_line_attribute10;
                p_interface_line_attribute11            :=
                       l_interface_line_attribute11;
                p_interface_line_attribute12            :=
                       l_interface_line_attribute12;
                p_interface_line_attribute13            :=
                       l_interface_line_attribute13;
                p_interface_line_attribute14            :=
                       l_interface_line_attribute14;
                p_interface_line_attribute15            :=
                       l_interface_line_attribute15;
                p_attribute_category            :=  l_attribute_category;
                p_attribute1                    :=  l_attribute1;
                p_attribute2                    :=  l_attribute2;
                p_attribute3                    :=  l_attribute3;
                p_attribute4                    :=  l_attribute4;
                p_attribute5                    :=  l_attribute5;
                p_attribute6                    :=  l_attribute6;
                p_attribute7                    :=  l_attribute7;
                p_attribute8                    :=  l_attribute8;
                p_attribute9                    :=  l_attribute9;
                p_attribute10                   :=  l_attribute10;
                p_attribute11                   :=  l_attribute11;
                p_attribute12                   :=  l_attribute12;
                p_attribute13                   :=  l_attribute13;
                p_attribute14                   :=  l_attribute14;
                p_attribute15                   :=  l_attribute15;
                p_default_ussgl_trx_code        :=
                                          l_default_ussgl_trx_code;
                p_commit_memo_line_id           := l_commit_memo_line_id;

        IF l_commit_memo_line_id is NOT NULL
            THEN
                SELECT description
                INTO   l_commit_memo_line_desc
                FROM   ar_memo_lines
                WHERE  memo_line_id = l_commit_memo_line_id;
                p_commit_memo_line_desc :=l_commit_memo_line_desc;
        END IF;
           EXCEPTION
              WHEN NO_DATA_FOUND THEN NULL;
              WHEN OTHERS THEN RAISE;
           END;

   /*-------------------+
    |  Credit Memo case |
    +-------------------*/

    ELSIF ( p_previous_customer_trx_id  IS NOT NULL )
       THEN

           SELECT ct_prev.rowid,
                  ct_prev.trx_number,
                  ct_prev.invoice_currency_code,
                  ct_prev.trx_date,
                  ct_prev.bill_to_customer_id,
                  ct_prev.ship_to_customer_id,
                  ct_prev.sold_to_customer_id,
                  ct_prev.paying_customer_id,
                  ct_prev.bill_to_site_use_id,
                  ct_prev.ship_to_site_use_id,
                  ct_prev.paying_site_use_id,
                  ct_prev.bill_to_contact_id,
                  ct_prev.ship_to_contact_id,
                  ct_prev.initial_customer_trx_id,
                  ct_prev.primary_salesrep_id,
                  ct_prev.invoicing_rule_id,
                  gd_prev.gl_date,
                  gd_prev.amount,
                  substrb(party.party_name,1,50),
                  rac_prev.account_number,
                  bs_prev.name,
                  ctt_prev.type,
                  ctt_prev.allow_overapplication_flag,
                  ctt_prev.natural_application_only_flag,
                  ctt_prev.accounting_affect_flag, /* Bug-3954193 */
                  ctt_prev.post_to_gl,             /* Bug-3954193 */
                  al_cm_reason.meaning
           INTO   l_ct_prev_rowid,
                  l_ct_prev_trx_number,
                  l_ct_prev_inv_currency_code,
                  l_ct_prev_trx_date,
                  l_ct_prev_bill_to_customer_id,
                  l_ct_prev_ship_to_customer_id,
                  l_ct_prev_sold_to_customer_id,
                  l_ct_prev_paying_customer_id,
                  l_ct_prev_bill_to_site_use_id,
                  l_ct_prev_ship_to_site_use_id,
                  l_ct_prev_paying_site_use_id,
                  l_ct_prev_bill_to_contact_id,
                  l_ct_prev_ship_to_contact_id,
                  l_ct_prev_initial_cust_trx_id,
                  l_ct_prev_primary_salesrep_id,
                  l_ct_prev_invoicing_rule_id,
                  l_gd_prev_gl_date,
                  l_prev_trx_original,
                  l_rac_prev_bill_to_cust_name,
                  l_rac_prev_bill_to_cust_num,
                  l_bs_prev_source_name,
                  l_ctt_prev_class,
                  l_ctt_prev_allow_overapp_flag,
                  l_ctt_prev_natural_app_only,
                  l_ct_prev_open_receivables,   /* Bug-3954193 */
                  l_ct_prev_post_to_gl_flag,    /* Bug-3954193 */
                  l_al_cm_reason_meaning
           FROM   ra_customer_trx          ct,
                  ra_customer_trx          ct_prev,
                  ra_cust_trx_line_gl_dist gd_prev,
                  hz_cust_accounts         rac_prev,
                  hz_parties		   party,
                  ra_batch_sources         bs_prev,
                  ra_cust_trx_types        ctt_prev,
                  ar_lookups               al_cm_reason
           WHERE  ct.rowid                      = p_ct_rowid
           and    ct.previous_customer_trx_id   = ct_prev.customer_trx_id
           and    ct_prev.batch_source_id       = bs_prev.batch_source_id
           and    ct_prev.cust_trx_type_id      = ctt_prev.cust_trx_type_id
           and    ct_prev.customer_trx_id       = gd_prev.customer_trx_id
           and    'REC'                         = gd_prev.account_class
           and    'Y'                           = gd_prev.latest_rec_flag
           and    ct_prev.bill_to_customer_id   = rac_prev.cust_account_id
           and    rac_prev.party_id             = party.party_id
           and    'CREDIT_MEMO_REASON'          = al_cm_reason.lookup_type(+)
           and    ct.reason_code                = al_cm_reason.lookup_code(+);


           l_ct_prev_trx_reference :=
                            arpt_sql_func_util.get_reference(l_ct_prev_rowid);

           l_prev_trx_balance      :=
                  arp_bal_util.get_trx_balance( p_previous_customer_trx_id,
                                                NULL);

           p_prev_trx_balance              := l_prev_trx_balance;
           p_ct_prev_trx_reference         := l_ct_prev_trx_reference;
           p_ct_prev_trx_number            := l_ct_prev_trx_number;
           p_ct_prev_inv_currency_code     := l_ct_prev_inv_currency_code;
           p_ct_prev_trx_date              := l_ct_prev_trx_date;
           p_ct_prev_bill_to_customer_id   := l_ct_prev_bill_to_customer_id;
           p_ct_prev_ship_to_customer_id   := l_ct_prev_ship_to_customer_id;
           p_ct_prev_sold_to_customer_id   := l_ct_prev_sold_to_customer_id;
           p_ct_prev_paying_customer_id    := l_ct_prev_paying_customer_id;
           p_ct_prev_bill_to_site_use_id   := l_ct_prev_bill_to_site_use_id;
           p_ct_prev_ship_to_site_use_id   := l_ct_prev_ship_to_site_use_id;
           p_ct_prev_paying_site_use_id    := l_ct_prev_paying_site_use_id;
           p_ct_prev_bill_to_contact_id    := l_ct_prev_bill_to_contact_id;
           p_ct_prev_ship_to_contact_id    := l_ct_prev_ship_to_contact_id;
           p_ct_prev_initial_cust_trx_id   := l_ct_prev_initial_cust_trx_id;
           p_ct_prev_primary_salesrep_id   := l_ct_prev_primary_salesrep_id;
           p_ct_prev_invoicing_rule_id     := l_ct_prev_invoicing_rule_id;
           p_gd_prev_gl_date               := l_gd_prev_gl_date;
           p_prev_trx_original             := l_prev_trx_original;
           p_rac_prev_bill_to_cust_name    := l_rac_prev_bill_to_cust_name;
           p_rac_prev_bill_to_cust_num     := l_rac_prev_bill_to_cust_num;
           p_bs_prev_source_name           := l_bs_prev_source_name;
           p_ctt_prev_class                := l_ctt_prev_class;
           p_ctt_prev_allow_overapp_flag   := l_ctt_prev_allow_overapp_flag;
           p_ctt_prev_natural_app_only     := l_ctt_prev_natural_app_only;
           p_ct_prev_open_receivables      := l_ct_prev_open_receivables;  /* Bug-3954193 */
           p_ct_prev_post_to_gl_flag       := l_ct_prev_post_to_gl_flag;   /* Bug-3954193 */
           p_al_cm_reason_meaning          := l_al_cm_reason_meaning;

    END IF;

  /*-----------------------------------------+
   |  Print the results to the debug stream  |
   +-----------------------------------------*/

    arp_util.debug('');
    arp_util.debug('======= results from post_query() =======');
    arp_util.debug('p_ct_commitment_trx_date            = ' ||
                     l_ct_commitment_trx_date);
    arp_util.debug('p_ct_commitment_number              = ' ||
                     l_ct_commitment_number);
    arp_util.debug('p_gd_commitment_gl_date             = ' ||
                     l_gd_commitment_gl_date);
    arp_util.debug('p_ctl_commit_cust_trx_line_id       = ' ||
                     l_ctl_commit_cust_trx_line_id);
    arp_util.debug('p_ctl_commitment_amount             = ' ||
                     l_ctl_commitment_amount);
    arp_util.debug('p_ctl_commitment_text               = ' ||
                     l_ctl_commitment_text);
    arp_util.debug('p_ctl_commitment_inv_item_id        = ' ||
                     l_ctl_commitment_inv_item_id);
    arp_util.debug('p_interface_line_context            = ' ||
                     l_interface_line_context);
    arp_util.debug('p_interface_line_attribute1         = ' ||
                     l_interface_line_attribute1);
    arp_util.debug('p_interface_line_attribute2         = ' ||
                     l_interface_line_attribute2);
    arp_util.debug('p_interface_line_attribute3         = ' ||
                     l_interface_line_attribute3);
    arp_util.debug('p_interface_line_attribute4         = ' ||
                     l_interface_line_attribute4);
    arp_util.debug('p_interface_line_attribute5         = ' ||
                     l_interface_line_attribute5);
    arp_util.debug('p_interface_line_attribute6         = ' ||
                     l_interface_line_attribute6);
    arp_util.debug('p_interface_line_attribute7         = ' ||
                     l_interface_line_attribute7);
    arp_util.debug('p_interface_line_attribute8         = ' ||
                     l_interface_line_attribute8);
    arp_util.debug('p_interface_line_attribute9         = ' ||
                     l_interface_line_attribute9);
    arp_util.debug('p_interface_line_attribute10        = ' ||
                     l_interface_line_attribute10);
    arp_util.debug('p_interface_line_attribute11        = ' ||
                     l_interface_line_attribute11);
    arp_util.debug('p_interface_line_attribute12        = ' ||
                     l_interface_line_attribute12);
    arp_util.debug('p_interface_line_attribute13        = ' ||
                     l_interface_line_attribute13);
    arp_util.debug('p_interface_line_attribute14        = ' ||
                     l_interface_line_attribute14);
    arp_util.debug('p_interface_line_attribute15        = ' ||
                     l_interface_line_attribute15);
    arp_util.debug('p_attribute_category                = ' ||
                     l_attribute_category);
    arp_util.debug('p_attribute1                        = ' ||
                     l_attribute1);
    arp_util.debug('p_attribute2                        = ' ||
                     l_attribute2);
    arp_util.debug('p_attribute3                        = ' ||
                     l_attribute3);
    arp_util.debug('p_attribute4                        = ' ||
                     l_attribute4);
    arp_util.debug('p_attribute5                        = ' ||
                     l_attribute5);
    arp_util.debug('p_attribute6                        = ' ||
                     l_attribute6);
    arp_util.debug('p_attribute7                        = ' ||
                     l_attribute7);
    arp_util.debug('p_attribute8                        = ' ||
                     l_attribute8);
    arp_util.debug('p_attribute9                        = ' ||
                     l_attribute9);
    arp_util.debug('p_attribute10                       = ' ||
                     l_attribute10);
    arp_util.debug('p_attribute11                       = ' ||
                     l_attribute11);
    arp_util.debug('p_attribute12                       = ' ||
                     l_attribute12);
    arp_util.debug('p_attribute13                       = ' ||
                     l_attribute13);
    arp_util.debug('p_attribute14                       = ' ||
                     l_attribute14);
    arp_util.debug('p_attribute15                       = ' ||
                     l_attribute15);
    arp_util.debug('p_default_ussgl_trx_code            = ' ||
                   l_default_ussgl_trx_code);
    arp_util.debug('p_ct_prev_trx_number                = ' ||
                     l_ct_prev_trx_number);
    arp_util.debug('p_ct_prev_trx_reference             = ' ||
                     l_ct_prev_trx_reference);
    arp_util.debug('p_ct_prev_inv_currency_code         = ' ||
                     l_ct_prev_inv_currency_code);
    arp_util.debug('p_ct_prev_trx_date                  = ' ||
                     l_ct_prev_trx_date);
    arp_util.debug('p_ct_prev_bill_to_customer_id       = ' ||
                     l_ct_prev_bill_to_customer_id);
    arp_util.debug('p_ct_prev_ship_to_customer_id       = ' ||
                     l_ct_prev_ship_to_customer_id);
    arp_util.debug('p_ct_prev_sold_to_customer_id       = ' ||
                     l_ct_prev_sold_to_customer_id);
    arp_util.debug('p_ct_prev_paying_customer_id        = ' ||
                     l_ct_prev_paying_customer_id);
    arp_util.debug('p_ct_prev_bill_to_site_use_id       = ' ||
                     l_ct_prev_bill_to_site_use_id);
    arp_util.debug('p_ct_prev_ship_to_site_use_id       = ' ||
                     l_ct_prev_ship_to_site_use_id);
    arp_util.debug('p_ct_prev_paying_site_use_id        = ' ||
                     l_ct_prev_paying_site_use_id);
    arp_util.debug('p_ct_prev_bill_to_contact_id        = ' ||
                     l_ct_prev_bill_to_contact_id);
    arp_util.debug('p_ct_prev_ship_to_contact_id        = ' ||
                     l_ct_prev_ship_to_contact_id);
    arp_util.debug('p_ct_prev_initial_cust_trx_id       = ' ||
                     l_ct_prev_initial_cust_trx_id);
    arp_util.debug('p_ct_prev_primary_salesrep_id       = ' ||
                     l_ct_prev_primary_salesrep_id);
    arp_util.debug('p_ct_prev_invoicing_rule_id         = ' ||
                     l_ct_prev_invoicing_rule_id);
    arp_util.debug('p_gd_prev_gl_date                   = ' ||
                     l_gd_prev_gl_date);
    arp_util.debug('p_prev_trx_original                 = ' ||
                     l_prev_trx_original);
    arp_util.debug('p_prev_trx_balance                  = ' ||
                     l_prev_trx_balance);
    arp_util.debug('p_rac_prev_bill_to_cust_name        = ' ||
                     l_rac_prev_bill_to_cust_name);
    arp_util.debug('p_rac_prev_bill_to_cust_num         = ' ||
                     l_rac_prev_bill_to_cust_num);
    arp_util.debug('p_bs_prev_source_name               = ' ||
                     l_bs_prev_source_name);
    arp_util.debug('p_ctt_prev_class                    = ' ||
                     l_ctt_prev_class);
    arp_util.debug('p_ctt_prev_allow_overapp_flag       = ' ||
                     l_ctt_prev_allow_overapp_flag);
    arp_util.debug('p_ctt_prev_natural_app_only         = ' ||
                     l_ctt_prev_natural_app_only);
    arp_util.debug('p_ct_prev_open_receivables          = ' ||
                     l_ct_prev_open_receivables);
    arp_util.debug('p_ct_prev_post_to_gl_flag           = ' ||
                     l_ct_prev_post_to_gl_flag );
    arp_util.debug('p_al_cm_reason_meaning              = ' ||
                     l_al_cm_reason_meaning);

    arp_util.debug('arp_process_header.post_query()-');

EXCEPTION
  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION : '||
                   'arp_process_header.post_query()-');
    arp_util.debug('------- parameters for post_query ----');
    arp_util.debug('p_class                     = ' ||   p_class);
    arp_util.debug('p_ct_rowid                  = ' ||   p_ct_rowid);
    arp_util.debug('p_customer_trx_id           = ' ||   p_customer_trx_id);
    arp_util.debug('p_initial_customer_trx_id   = ' ||
                    p_initial_customer_trx_id);
    arp_util.debug('p_previous_customer_trx_id  = ' ||
                    p_previous_customer_trx_id);

    RAISE;
END;

  /*---------------------------------------------+
   |   Package initialization section.           |
   +---------------------------------------------*/
PROCEDURE init IS
BEGIN

  pg_text_dummy   := arp_ct_pkg.get_text_dummy;
  pg_flag_dummy   := arp_ct_pkg.get_flag_dummy;
  pg_number_dummy := arp_ct_pkg.get_number_dummy;
  pg_date_dummy   := arp_ct_pkg.get_date_dummy;
  pg_earliest_date      := to_date('01/01/1901', 'DD/MM/YYYY');

  pg_base_curr_code    := arp_global.functional_currency;
  pg_base_precision    := arp_global.base_precision;
  pg_base_min_acc_unit := arp_global.base_min_acc_unit;
  pg_set_of_books_id   :=
          arp_trx_global.system_info.system_parameters.set_of_books_id;
  /* bug 3567353 */
  pg_trx_header_level_rounding  := arp_global.sysparam.trx_header_level_rounding;

  /* 5633334/5637907 */
  fnd_profile.get('AR_USE_INV_ACCT_FOR_CM_FLAG', pg_use_inv_acctg);
  IF pg_use_inv_acctg IS NULL
  THEN
     pg_use_inv_acctg := 'N';
  END IF;

END init;

BEGIN
   init;
END ARP_PROCESS_HEADER;

/
