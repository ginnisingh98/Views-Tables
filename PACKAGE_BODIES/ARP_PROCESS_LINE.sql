--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_LINE" AS
/* $Header: ARTECTLB.pls 120.18.12010000.3 2008/11/07 13:01:19 ankuagar ship $ */


pg_base_curr_code          fnd_currencies.currency_code%type;
pg_base_precision          fnd_currencies.precision%type;
pg_base_min_acct_unit       fnd_currencies.minimum_accountable_unit%type;
pg_earliest_date  date;


AR_NUMBER_DUMMY CONSTANT NUMBER(15)   := -999999999999999;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    make_incomplete                                                        |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Sets complete_flag in ra_customer_trx to No.                           |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_id                                      |
 |              OUT:                                                         |
 |          IN/ OUT:							     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-MAY-96  Martin Johnson      Created                                |
 |                                                                           |
 +===========================================================================*/

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE make_incomplete( p_customer_trx_id  IN
                             ra_customer_trx.customer_trx_id%type )
IS

  l_trx_rec  ra_customer_trx%rowtype;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_process_line.make_incomplete()+');
  END IF;

  arp_ct_pkg.set_to_dummy( l_trx_rec );

  l_trx_rec.complete_flag := 'N';

  arp_ct_pkg.update_p( l_trx_rec,
                       p_customer_trx_id );

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_process_line.make_incomplete()-');
  END IF;

EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('EXCEPTION:  arp_process_line.make_incomplete()');
         arp_util.debug('make_incomplete: ' || '');
         arp_util.debug('---------- parameters for make_incomplete() ---------');
         arp_util.debug('make_incomplete: ' || 'p_customer_trx_id = ' || p_customer_trx_id );
      END IF;

      RAISE;

END make_incomplete;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_commitment_line_id                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns the id for the commitment line                                 |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_id                                      |
 |              OUT:                                                         |
 |                    p_commitment_line_id                                   |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-MAY-96  Martin Johnson      Created                                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE get_commitment_line_id(
  p_customer_trx_id      IN ra_customer_trx.customer_trx_id%type,
  p_commitment_line_id  OUT NOCOPY ra_customer_trx_lines.customer_trx_line_id%type )
IS
BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_process_line.get_commitment_line_id()+');
  END IF;

  BEGIN

     SELECT customer_trx_line_id
     INTO   p_commitment_line_id
     FROM   ra_customer_trx_lines ctl,
            ra_customer_trx ct
     WHERE  ct.customer_trx_id = p_customer_trx_id
     AND    ctl.customer_trx_id = ct.initial_customer_trx_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      null;
    WHEN OTHERS THEN
      RAISE;
  END;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_process_line.get_commitment_line_id()-');
  END IF;

EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('EXCEPTION:  arp_process_line.get_commitment_line_id()');
         arp_util.debug('------ parameters for get_commitment_line_id() -----');
         arp_util.debug('p_customer_trx_id = ' || p_customer_trx_id );
      END IF;

      RAISE;

END get_commitment_line_id;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    set_flags								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Sets various change and status flags for the current record.  	     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_line_rec  					     |
 |		      p_customer_trx_line_id				     |
 |		      p_old_line_rec 					     |
 |              OUT:                                                         |
 |		      p_derive_gldate_flag 				     |
 |		      p_amount_changed_flag				     |
 |                    p_last_period_changed_flag                             |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-JUL-95  Charlie Tomberg     Created                                |
 |     17-JAN-96  Martin Johnson      Added parameter                        |
 |                                      p_last_period_changed_flag           |
 |     11-AUG-97  OSTEINME	      changed logic for Rel. 11 tax inclusive|
 |				      feature to deal with gross amounts     |
 |     01-JAN-00  SNAMBIAR            Bug 1158952 Modified set_flags()       |
 |                                    procedure to add NVL() to              |
 |                                    p_line_rec.gross_extended_amount       |
 |                                                                           |
 |     08-Jun-04  Naruhiko Yanagita   Bug:3678009                            |
 |                                   Added a condition for unit_selling_price|
 +===========================================================================*/

PROCEDURE set_flags( p_line_rec             IN ra_customer_trx_lines%rowtype,
                     p_old_line_rec         IN ra_customer_trx_lines%rowtype,
                     p_customer_trx_line_id IN
                              ra_customer_trx_lines.customer_trx_line_id%type,
                 p_derive_gl_date_flag      OUT NOCOPY boolean,
                 p_amount_changed_flag      OUT NOCOPY boolean,
                 p_last_period_changed_flag OUT NOCOPY boolean) IS

  l_derive_gl_date_flag       boolean;
  l_amount_changed_flag	      boolean;
  l_last_period_changed_flag  boolean;

BEGIN

   arp_util.debug('arp_process_line.set_flags()+');


  /*--------------------------------+
   |  Set the flags appropriately   |
   +--------------------------------*/

/* Rel. 10 code:
   IF   ( p_old_line_rec.extended_amount = p_line_rec.extended_amount )
   THEN l_amount_changed_flag := FALSE;
   ELSE l_amount_changed_flag := TRUE;
   END IF;
*/

   /* Rel. 11 code: */
   /* Bug 1158952. Added NVL() to p_line_rec.gross_extended_amount */

   IF (NVL(p_old_line_rec.gross_extended_amount,
		p_old_line_rec.extended_amount) =
		NVL(p_line_rec.gross_extended_amount,
                    p_line_rec.extended_amount))
     AND
		NVL(p_old_line_rec.vat_tax_id,-123) =
		NVL(p_line_rec.vat_tax_id, -123)
     AND
		NVL(p_old_line_rec.amount_includes_tax_flag, 'X') =
		NVL(p_line_rec.amount_includes_tax_flag, 'X')
 /* Bug:3678009 Added the condition for unit_selling_price */
     AND
                NVL(p_old_line_rec.gross_unit_selling_price,
                    nvl(p_old_line_rec.unit_selling_price,0.000000000000000001))=
                NVL(p_line_rec.gross_unit_selling_price,
                    nvl(p_line_rec.unit_selling_price,0.000000000000000001))
     THEN
       l_amount_changed_flag := FALSE;
     ELSE
       l_amount_changed_flag := TRUE;
   END IF;


   IF (
           nvl(p_old_line_rec.accounting_rule_id, 0) <>
           nvl(p_line_rec.accounting_rule_id, 0)
        OR
           nvl(p_old_line_rec.accounting_rule_duration, -1) <>
           nvl(p_line_rec.accounting_rule_duration, -1)
        OR
           nvl(p_old_line_rec.rule_start_date, pg_earliest_date) <>
           nvl(p_line_rec.rule_start_date, pg_earliest_date)
      )
   THEN    l_derive_gl_date_flag := TRUE;
   ELSE    l_derive_gl_date_flag := FALSE;
   END IF;

   IF ( nvl(p_old_line_rec.last_period_to_credit, -1) =
                                    nvl(p_line_rec.last_period_to_credit, -1) )
   THEN l_last_period_changed_flag := FALSE;
   ELSE l_last_period_changed_flag := TRUE;
   END IF;

   p_derive_gl_date_flag      := l_derive_gl_date_flag;
   p_amount_changed_flag      := l_amount_changed_flag;
   p_last_period_changed_flag := l_last_period_changed_flag;

  /*------------------------+
   |  Print out NOCOPY the results |
   +------------------------*/

   arp_util.debug('l_derive_gl_date_flag  = ' ||
                  arp_trx_util.boolean_to_varchar2( l_derive_gl_date_flag ));
   arp_util.debug('l_amount_changed_flag  = ' ||
                  arp_trx_util.boolean_to_varchar2( l_amount_changed_flag ));
   arp_util.debug('l_last_period_changed_flag = ' ||
                  arp_trx_util.boolean_to_varchar2(
                                    l_last_period_changed_flag ));

   arp_util.debug('arp_process_line.set_flags()-');


EXCEPTION
  WHEN OTHERS THEN

  /*---------------------------------------------+
   |  Display parameters and raise the exception |
   +---------------------------------------------*/

   arp_util.debug('EXCEPTION:  arp_process_line.set_flags()');

   arp_util.debug('');
   arp_util.debug('---------- parameters for set_flags() ---------');

   arp_util.debug('p_customer_trx_line_id = ' ||
                  p_customer_trx_line_id);

   arp_util.debug('');

   arp_util.debug('---------- old line record ----------');
   arp_ctl_pkg.display_line_rec( p_old_line_rec );
   arp_util.debug('');

   arp_util.debug('---------- new line record ----------');
   arp_ctl_pkg.display_line_rec( p_line_rec );
   arp_util.debug('');

   RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    line_rerun_aa							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Reruns AutoAccounting for Revenue and Charges.		  	     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_customer_trx_id					     |
 |		      p_customer_trx_line_id				     |
 |              OUT:                                                         |
 |		      None						     |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     25-JUL-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE line_rerun_aa(
                         p_customer_trx_id IN
                               ra_customer_trx.customer_trx_id%type,
                         p_customer_trx_line_id IN
                               ra_customer_trx_lines.customer_trx_line_id%type
                       ) IS

   l_ccid			binary_integer;
   l_concat_segments 		varchar2(2000);
   l_num_failed_dist_rows 	binary_integer;

BEGIN

   arp_util.debug('arp_process_line.line_rerun_aa()+');

   BEGIN
       arp_auto_accounting.do_autoaccounting
	                 (
	                    'U',
	                    'ALL',
	                    p_customer_trx_id,
	                    p_customer_trx_line_id,
	                    null,
	                    null,
	                    null,
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
     WHEN NO_DATA_FOUND THEN
       null;
     WHEN OTHERS THEN
       RAISE;
   END;

   arp_util.debug('arp_process_line.line_rerun_aa()-');

EXCEPTION
   WHEN OTHERS THEN

   arp_util.debug('EXCEPTION:  arp_process_line.line_rerun_aa()');


  /*---------------------------------------------+
   |  Display parameters and raise the exception |
   +---------------------------------------------*/

   arp_util.debug('');
   arp_util.debug('---------- parameters for line_rerun_aa() ---------');

   arp_util.debug('p_customer_trx_id      = ' ||
                  p_customer_trx_id);

   arp_util.debug('p_customer_trx_line_id = ' ||
                  p_customer_trx_line_id);

   arp_util.debug('');

   RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |   header_fright_only_rules_case	                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Converts the transaction from a transaction with rules to one that does |
 |   not use rules. This happens in the case where the last line of type     |
 |   line has been deleted and the transaction only contains a header        |
 |   freight record.							     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_customer_trx_id    				     |
 |                   p_trx_amount         				     |
 |                   p_exchange_rate      				     |
 |                   p_gl_date            				     |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     25-JUL-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE header_freight_only_rules_case(
                               p_customer_trx_id    IN
					  ra_customer_trx.customer_trx_id%type,
                               p_trx_amount         IN number,
                               p_exchange_rate      IN
                                          ra_customer_trx.exchange_rate%type,
	 		       p_gl_date 	    IN
					  ra_cust_trx_line_gl_dist.gl_date%type
					)
                                      IS

   l_trx_rec   ra_customer_trx%rowtype;
   l_dist_rec  ra_cust_trx_line_gl_dist%rowtype;

BEGIN

   arp_util.debug('arp_process_line.header_freight_only_rules_case()+');

   IF (arp_trx_util.detect_freight_only_rules_case( p_customer_trx_id ) = TRUE)
   THEN

       /*-----------------------------------------------------+
        |  Null out NOCOPY the invoicing rule ID of the transaction  |
	+-----------------------------------------------------*/

       arp_ct_pkg.set_to_dummy( l_trx_rec );
       l_trx_rec.invoicing_rule_id := '';

       arp_ct_pkg.update_p( l_trx_rec,
                            p_customer_trx_id );


       /*---------------------------------------------------------+
        |   update the account sets to be real dists.		  |
        |   inv rule is cleared by the form at complete time	  |
        |   or when all 'line' lines are deleted 		  |
        |   if rules and freight only invoice. 			  |
        |   Reason is that the Revenue Recognition Program 	  |
        |    cannot handle freight only transactions with rules.  |
        |							  |
        |  There are two dists in this case:			  |
        |   o The REC dist					  |
        |   o The FREIGHT dist					  |
	+---------------------------------------------------------*/

       arp_ctlgd_pkg.set_to_dummy(l_dist_rec);

       l_dist_rec.account_set_flag := 'N';


       l_dist_rec.acctd_amount := arpcurr.functional_amount(
                                                 p_trx_amount,
                                                 pg_base_curr_code,
                                                 p_exchange_rate,
                                                 pg_base_precision,
                                                 pg_base_min_acct_unit);

       l_dist_rec.amount 	   := p_trx_amount;
       l_dist_rec.gl_date	   := p_gl_date;
       l_dist_rec.original_gl_date := p_gl_date;

       arp_ctlgd_pkg.update_f_ct_id(l_dist_rec,
                                    p_customer_trx_id,
                                    null,
                                    null);

   END IF;

   arp_util.debug('arp_process_line.header_freight_only_rules_case()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug(
              'EXCEPTION:  arp_process_line.header_freight_only_rules_case()');

        arp_util.debug('');
       arp_util.debug('-- parameters for header_freight_only_rules_case() --');

        arp_util.debug('p_customer_trx_id       = ' || p_customer_trx_id);
        arp_util.debug('p_trx_amount            = ' || p_trx_amount);
        arp_util.debug('p_exchange_rate         = ' || p_exchange_rate);
        arp_util.debug('p_gl_date               = ' || p_gl_date);

        RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    val_insert_line			                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Does validation that is required when a new line is inserted.	     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_line_rec					     |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     24-JUL-95  Charlie Tomberg     Created                                |
 |     31-JAN-96  Martin Johnson      Added call to                          |
 |                                    arp_dates.val_gl_periods_for_rules.    |
 |                                    Changed l_line_rec.set_of_books_id to  |
 |                                    arp_global.set_of_books_id.            |
 |     06-FEB-96  Martin Johnson      Don't call val_gl_periods_for_rules    |
 |                                    for CM's because CM module will        |
 |                                    derive the correct values later        |
 |                                                                           |
 +===========================================================================*/


PROCEDURE val_insert_line ( p_line_rec IN ra_customer_trx_lines%rowtype ) IS


BEGIN

   arp_util.debug('arp_process_line.val_insert_line()+');

   arp_trx_validate.check_dup_line_number(p_line_rec.line_number,
                                          p_line_rec.customer_trx_id,
                                          null);

   /*----------------------------------------------------------------------+
    |  Don't call val_gl_periods_for_rules for CM's because CM module will |
    |  derive correct accounting_rule_duration and rule_start_date later   |
    +----------------------------------------------------------------------*/

   IF ( p_line_rec.previous_customer_trx_id IS NULL )
     THEN
       arp_dates.val_gl_periods_for_rules(
                                        null,  -- p_request_id
                                        p_line_rec.accounting_rule_id,
                                        p_line_rec.accounting_rule_duration,
                                        p_line_rec.rule_start_date,
                                        arp_global.set_of_books_id );
   END IF;

   arp_util.debug('arp_process_line.val_insert_line()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_process_line.val_insert_line()');

        arp_util.debug('');
        arp_util.debug('------ parameters for val_insert_line() -------');

        arp_ctl_pkg.display_line_rec(p_line_rec);

        RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    val_update_line			                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Does validation that is required when a line is updated.		     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_line_rec    - The line rec with the changed colums   |
 |                    p_db_line_rec - The old line record                    |
 |                    p_new_line_rec - Contains old rec + updated columns    |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     24-JUL-95  Charlie Tomberg     Created                                |
 |     31-JAN-96  Martin Johnson      Changed l_line_rec.set_of_books_id to  |
 |                                    arp_global.set_of_books_id.            |
 |     06-FEB-96  Martin Johnson      Don't call val_gl_periods_for_rules    |
 |                                    for CM's because CM module will        |
 |                                    derive the correct values later        |
 |                                                                           |
 +===========================================================================*/


PROCEDURE val_update_line ( p_line_rec      IN ra_customer_trx_lines%rowtype,
                            p_db_line_rec   IN ra_customer_trx_lines%rowtype,
                            p_new_line_rec OUT NOCOPY ra_customer_trx_lines%rowtype )
                          IS

   l_errorbuf  varchar2(200);

   l_line_rec  ra_customer_trx_lines%rowtype;

BEGIN

   arp_util.debug('arp_process_line.val_update_line()+');


   arp_ctl_pkg.merge_line_recs( p_db_line_rec,
                                p_line_rec,
                                l_line_rec );

   p_new_line_rec := l_line_rec;

  /*------------------------------------------+
   |  Verify the line is of the correct type  |
   +------------------------------------------*/

   IF    (l_line_rec.line_type not in ('LINE', 'CHARGES', 'CB') )
   THEN
         arp_util.debug('EXCEPTION:  arp_process_line.val_update_line()');
         arp_util.debug(
                      'The specified line is not of type LINE, CHARGES or CB');
         fnd_message.set_name('AR', 'C-1647');
         app_exception.raise_exception;
   END IF;

   arp_trx_validate.check_dup_line_number(l_line_rec.line_number,
                                          l_line_rec.customer_trx_id,
                                          p_db_line_rec.customer_trx_line_id);

   /*----------------------------------------------------------------------+
    |  Don't call val_gl_periods_for_rules for CM's because CM module will |
    |  derive correct accounting_rule_duration and rule_start_date later   |
    +----------------------------------------------------------------------*/

   IF ( p_line_rec.previous_customer_trx_id IS NULL )
     THEN
       arp_dates.val_gl_periods_for_rules(
                                        null,  -- p_request_id
                                        l_line_rec.accounting_rule_id,
                                        l_line_rec.accounting_rule_duration,
                                        l_line_rec.rule_start_date,
                                        arp_global.set_of_books_id );
   END IF;

   arp_util.debug('arp_process_line.val_update_line()-');


EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_process_line.val_update_line()');

        arp_util.debug('');
        arp_util.debug('------ parameters for val_update_line() -------');

        arp_util.debug('');
        arp_util.debug('------ new line record -------');
        arp_ctl_pkg.display_line_rec(p_line_rec);

        arp_util.debug('');
        arp_util.debug('------ old line record -------');
        arp_ctl_pkg.display_line_rec(p_db_line_rec);

        arp_util.debug('');
        arp_util.debug('------ merged line record -------');
        arp_ctl_pkg.display_line_rec(l_line_rec);

        RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    val_delete_line			                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Does validation that is required when a line is deleted.		     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_line_rec					     |
 |		      p_complete_flag					     |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     24-JUL-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE val_delete_line ( p_line_rec       IN ra_customer_trx_lines%rowtype,
                            p_complete_flag  IN
                                       ra_customer_trx.complete_flag%type ) IS


BEGIN

   arp_util.debug('arp_process_line.val_delete_line()+');

   IF   ( p_complete_flag = 'Y' )
   THEN arp_trx_validate.check_has_one_line( p_line_rec.customer_trx_id );
   END IF;


   arp_util.debug('arp_process_line.val_delete_line()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_process_line.val_delete_line()');

        arp_util.debug('');
        arp_util.debug('------ parameters for val_delete_line() -------');

        arp_util.debug('p_complete_flag   = ' || p_complete_flag);

        arp_ctl_pkg.display_line_rec(p_line_rec);

        RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_line							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Inserts a record into ra_customer_trx_lines.			     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_form_name					     |
 |		      p_form_version					     |
 |		      p_line_rec					     |
 |		      p_memo_line_type					     |
 |		      p_currency_code					     |
 |              OUT:                                                         |
 |                    p_customer_trx_line_id				     |
 |                    p_rule_start_date                                      |
 |                    p_accounting_rule_duration                             |
 |                    p_status                                               |
 |          IN/ OUT:							     |
 |		      p_gl_date                                              |
 |                    p_trx_date                                             |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     24-JUL-95  Charlie Tomberg     Created                                |
 |     15-JAN-96  Martin Johnson      Added call to credit memo module.      |
 |                                    Added OUT NOCOPY parameters            |
 |                                    p_rule_start_date                      |
 |                                      and p_accounting_rule_duration       |
 |     06-FEB-96  Martin Johnson      Don't call tax engine if trx is a      |
 |                                      debit memo reversal                  |
 |     08-FEB-96  Martin Johnson      Call arp_dates.derive_gl_trx_dates_    |
 |                                      from_rules() and added IN OUT NOCOPY |
 |                                      parameters p_gl_date and p_trx_date. |
 |     15-MAY-96  Martin Johnson      BugNo:356814.  Added OUT NOCOPY param  |
 |                                      p_status.  Call calculate_tax_f_ctl_ |
 |                                      id in 'DEFERRED' mode so that        |
 |                                      'soft' exception will be raised.     |
 |     01-JUL-96  Simon Leung         Do not call the tax engine if the      |
 |                                      memo line type is TAX, FREIGHT or    |
 |                                      CHARGES.                             |
 |									     |
 |     Rel 11 Changes:							     |
 |									     |
 |     04-AUG-97  OSTEINME	Added new parameters p_header_currency_code  |
 |						     p_header_exchange_rate  |
 |				changed p_line_rec to IN OUT NOCOPY	     |
 |                                                                           |
 +===========================================================================*/


PROCEDURE insert_line(
               p_form_name             IN varchar2,
               p_form_version          IN number,
               p_line_rec	       IN OUT NOCOPY ra_customer_trx_lines%rowtype,
               p_memo_line_type        IN ar_memo_lines.line_type%type,
               p_customer_trx_line_id  OUT NOCOPY
                               ra_customer_trx_lines.customer_trx_line_id%type,
               p_trx_class             IN ra_cust_trx_types.type%type
                                           DEFAULT NULL,
               p_ccid1                 IN
                                 gl_code_combinations.code_combination_id%type
                                 DEFAULT NULL,
               p_ccid2                 IN
                                 gl_code_combinations.code_combination_id%type
                                 DEFAULT NULL,
               p_amount1               IN ra_cust_trx_line_gl_dist.amount%type
                                           DEFAULT NULL,
               p_amount2               IN ra_cust_trx_line_gl_dist.amount%type
                                          DEFAULT NULL,
               p_rule_start_date       OUT NOCOPY
                                 ra_customer_trx_lines.rule_start_date%type,
               p_accounting_rule_duration OUT NOCOPY
                         ra_customer_trx_lines.accounting_rule_duration%type,
               p_gl_date               IN OUT NOCOPY
                         ra_cust_trx_line_gl_dist.gl_date%type,
               p_trx_date              IN OUT NOCOPY
                         ra_customer_trx.trx_date%type,
	       p_header_currency_code  IN
				ra_customer_trx.invoice_currency_code%type
				DEFAULT NULL,
	       p_header_exchange_rate  IN ra_customer_trx.exchange_rate%type
				DEFAULT NULL,
               p_status                OUT NOCOPY varchar2,
               p_run_autoacc_flag      IN varchar2  DEFAULT 'Y',
               p_run_tax_flag          IN varchar2  DEFAULT 'Y',
               p_create_salescredits_flag IN VARCHAR2 DEFAULT 'Y'  )

IS

      l_ccid		       number;
      l_concat_segments        varchar2(2000);
      l_num_failed_dist_rows   number;
      l_errorbuf 	       varchar2(200);
      l_result		       number;

      l_customer_trx_line_id   ra_customer_trx_lines.customer_trx_line_id%type;
      l_new_tax_amount	       NUMBER;

      l_failure_count          number;
      l_rule_start_date        ra_customer_trx_lines.rule_start_date%type;
      l_accounting_rule_duration
                      ra_customer_trx_lines.accounting_rule_duration%type;

      l_recalculate_tax_flag   boolean;
      l_status1                varchar2(100);
      l_status2                varchar2(100);
      l_status3                varchar2(100);
      l_status4                varchar2(100);

      l_commitment_line_id     ra_customer_trx_lines.customer_trx_line_id%type;
      l_line_rec               ra_customer_trx_lines%rowtype;

      l_extended_amount		NUMBER;
      l_unit_selling_price	NUMBER;
      l_gross_extended_amount   NUMBER;
      l_gross_unit_selling_price NUMBER;

--Bug#2750340
      l_ev_rec                   arp_xla_events.xla_events_type;
      /*Bug 3130851 and bug 3407389*/
      l_dist_rec               ra_cust_trx_line_gl_dist%rowtype;
      l_dist_line              ra_cust_trx_line_gl_dist.customer_trx_line_id%type;
      l_tax_computed   BOOLEAN;
      l_action         VARCHAR2(12);
      l_count          NUMBER;

      l_mode           VARCHAR2(50);
BEGIN

      arp_util.debug('arp_process_line.insert_line()+');

    arp_util.debug('ARTECTLB: p_line_rec.amount_includes_tax_flag = ' || p_line_rec.amount_includes_tax_flag);

      p_rule_start_date          := p_line_rec.rule_start_date;
      p_accounting_rule_duration := p_line_rec.accounting_rule_duration;

      /*----------------------------------------------+
       |   Check the form version to determine if it  |
       |   is compatible with the entity handler.     |
       +----------------------------------------------*/

      arp_trx_validate.ar_entity_version_check(p_form_name, p_form_version);

      /*-------------------------+
       |  Do required validation |
       +-------------------------*/

      arp_process_line.val_insert_line(p_line_rec);

      /*----------------------------------------------------------------+
       | Lock rows in other tables that reference this customer_trx_id  |
       +----------------------------------------------------------------*/

      arp_trx_util.lock_transaction(p_line_rec.customer_trx_id);

      l_line_rec := p_line_rec;

      IF (l_line_rec.initial_customer_trx_line_id IS NULL) THEN
         get_commitment_line_id(p_line_rec.customer_trx_id,
                                l_commitment_line_id);

         l_line_rec.initial_customer_trx_line_id := l_commitment_line_id;
      END IF;

      /*----------------------------------------------+
       |  Call the table handler to insert the line   |
       +----------------------------------------------*/

    arp_util.debug('ARTECTLB: l_line_rec.amount_includes_tax_flag = ' || l_line_rec.amount_includes_tax_flag);

      arp_ctl_pkg.insert_p( l_line_rec,
                            l_customer_trx_line_id);


      p_customer_trx_line_id := l_customer_trx_line_id;

     /*---------------------------------------------+
      |  If trx is not a CM and there are rules,    |
      |  derive the gl_date and trx_date            |
      +---------------------------------------------*/

      IF ( ( p_trx_class <> 'CM' )
           AND
           ( p_line_rec.accounting_rule_id IS NOT NULL )
         )
        THEN

          arp_dates.derive_gl_trx_dates_from_rules(
                                   p_line_rec.customer_trx_id,
                                   p_gl_date,
                                   p_trx_date,
                                   l_recalculate_tax_flag );
      END IF;

      IF (p_create_salescredits_flag = 'Y')
      THEN
           arp_process_salescredit.create_line_salescredits(
                                                    p_line_rec.customer_trx_id,
                                                    l_customer_trx_line_id,
                                                    p_memo_line_type,
                                                    'N',
                                                    'N',
                                                    l_status1 );
      END IF;

      /* ----------------------------------------------------------------
         Bug 5054198 the condition needs to be modified so that
         line_Det_Factors handler is also called for Freight and Charges

         Bug 5197390 -- removed TAX from the excluded condition.  memo
         lines of type 'TAX' are tax-only transactions and need det factors

	 Bug 6346105 - Removed 'CHARGES' conditon. Now line_det_factors()
	 is called for 'CHARGES' memo line type also.
        ------------------------------------------------------------------*/

      IF ( p_trx_class NOT IN ( 'CB', 'DM_REV' )  AND
           p_run_tax_flag = 'Y'
         )
      THEN

          /*-----------------------------------------------------------------+
           | Call Tax Engine, calculating tax for this invoice line.         |
           +-----------------------------------------------------------------*/

          BEGIN

            arp_util.debug(
              'arp_process_line.insert_line before create_tax_f_ctl_id');

	    -- Rel. 11: call to new tax engine procedure
	    -- 		to handle tax-inclusive case:

	    l_extended_amount := p_line_rec.extended_amount;
	    l_unit_selling_price := p_line_rec.unit_selling_price;

arp_util.debug('**** Before calling Calculate TAX ****');
arp_util.debug('     Parameters:');
arp_util.debug('	l_customer_trx_line_id = ' || l_customer_trx_line_id);
arp_util.debug(' 	l_extended_amount = ' || l_extended_amount);
arp_util.debug(' 	l_unit_selling_price = ' || l_unit_selling_price);
arp_util.debug(' 	p_header_currency_code = ' || p_header_currency_code);
arp_util.debug(' 	p_header_exchange_rate = ' || p_header_exchange_rate);


   /* 5197390 - Handle tax-type memo lines */
   IF p_memo_line_type = 'TAX'
   THEN
      l_mode := 'INSERT_NO_TAX';
      arp_util.debug('Overridding mode to INSERT_NO_TAX');
   ELSE
      l_mode := 'INSERT';
   END IF;

   /* we need to call the line_Det_Factors table handler so
      tax can get the attributes for calculating tax */
   ARP_ETAX_SERVICES_PKG.line_det_factors(
               p_customer_trx_line_id => l_customer_trx_line_id,
               p_customer_trx_id => p_line_rec.customer_trx_id,
               p_mode => l_mode);

/*********************************************************
ETAX: NOT SURE IF WE NEED THESE RETURN!!!
	    p_line_rec.extended_amount := l_extended_amount;
	    l_line_rec.extended_amount := l_extended_amount;
	    p_line_rec.unit_selling_price := l_unit_selling_price;
	    l_line_rec.unit_selling_price := l_unit_selling_price;

	    p_line_rec.gross_extended_amount := l_gross_extended_amount;
	    l_line_rec.gross_extended_amount := l_gross_extended_amount;
	    p_line_rec.gross_unit_selling_price := l_gross_unit_selling_price;
	    l_line_rec.gross_unit_selling_price := l_gross_unit_selling_price;

****************************************************************************/

            arp_util.debug(
              'arp_process_line.insert_line after create_tax_f_ctl_id');

          EXCEPTION
            WHEN OTHERS THEN
              l_status2 := 'AR_TAX_EXCEPTION';
              RAISE;

          END;

      END IF;

     /*----------------------------------------------------------------+
      |  IF    this transaction is a debit memo reversal,              |
      |  THEN  create two distributions based on the ccid and amount   |
      |        parameters.                                             |
      |  ELSIF the transaction is a credit memo against a transaction, |
      |        call the credit memo module to create the distributions |
      |  ELSE  create the distributions by calling AutoAccounting      |
      +----------------------------------------------------------------*/

      IF    ( p_trx_class = 'DM_REV' )
      THEN
            arp_process_debit_memo.line_post_insert(
                                                     l_customer_trx_line_id,
                                                     p_ccid1,
                                                     p_ccid2,
                                                     p_amount1,
                                                     p_amount2
                                                   );

      ELSIF ( p_line_rec.previous_customer_trx_id IS NOT NULL )
        THEN

          /*--------------------------------------------+
           |  It's a credit memo against a transaction  |
           +--------------------------------------------*/

          BEGIN

            -- arp_global.msg_level := 99;

            arp_util.debug(
              'arp_process_line.insert_line before credit_transactions');

            arp_credit_memo_module.credit_transactions(
	                      p_line_rec.customer_trx_id,
                              l_customer_trx_line_id,
                              p_line_rec.previous_customer_trx_id,
                              p_line_rec.previous_customer_trx_line_id,
                              null,
                              l_failure_count,
                              l_rule_start_date,
                              l_accounting_rule_duration,
                              p_run_autoaccounting_flag =>
                                                   (p_run_autoacc_flag = 'Y'));

            arp_util.debug(
              'arp_process_line.insert_line after credit_transactions');

            p_rule_start_date          := l_rule_start_date;
            p_accounting_rule_duration := l_accounting_rule_duration;

          EXCEPTION
            WHEN arp_credit_memo_module.no_ccid THEN

              l_status3 := 'ARP_CREDIT_MEMO_MODULE.NO_CCID';

            WHEN OTHERS THEN
              RAISE;

          END;

      ELSE
            IF ( p_run_autoacc_flag = 'Y' )
            THEN
                  BEGIN
                      arp_auto_accounting.do_autoaccounting
                            (
                               'I',
                               'ALL',
                               p_line_rec.customer_trx_id,
                               l_customer_trx_line_id,
                               null,
                               null,
                               null,
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

            END IF;

      END IF;

      arp_util.debug('l_status1  = ' || l_status1);
      arp_util.debug('l_status2  = ' || l_status2);
      arp_util.debug('l_status3  = ' || l_status3);
      arp_util.debug('l_status4  = ' || l_status4);

      IF    ( NVL(l_status1, 'OK') <> 'OK' )
      THEN  p_status := l_status1;
      ELSIF ( NVL(l_status2, 'OK') <> 'OK' )
         THEN  p_status := l_status2;
      ELSIF ( NVL(l_status3, 'OK') <> 'OK' )
         THEN  p_status := l_status3;
      ELSIF ( NVL(l_status4, 'OK') <> 'OK' )
         THEN  p_status := l_status4;
      ELSE     p_status := 'OK';
      END IF;

      /*Bug 3130851 and Bug 3407389*/

      /* Check if any gl_dist rows are inserted for the current trx_line.*/

	BEGIN
	  SELECT customer_trx_line_id
	  INTO   l_dist_line
	  FROM   ra_cust_trx_line_gl_dist
	  WHERE  customer_trx_line_id = p_customer_trx_line_id
	  AND    account_set_flag     = 'N'
	  AND    ROWNUM               < 2;
	 EXCEPTION
		WHEN NO_DATA_FOUND THEN
		l_dist_line := NULL;
	END;


      IF  ( p_line_rec.previous_customer_trx_id IS NOT NULL AND l_dist_line IS NOT NULL)

      THEN
        arp_util.debug('Stamping distributions with the transaction code when entered at line level');
        ARP_CTLGD_PKG.set_to_dummy(l_dist_rec);
        l_dist_rec.ussgl_transaction_code := p_line_rec.DEFAULT_USSGL_TRANSACTION_CODE;
        ARP_CTLGD_PKG.update_f_ctl_id(l_dist_rec,p_customer_trx_line_id,'N','');


        DECLARE
        cursor c1 is select customer_trx_line_id
                     from ra_customer_trx_lines
                     where link_to_cust_trx_line_id = p_customer_trx_line_id;
        l_id number;
        BEGIN
            open c1;
            LOOP
               fetch c1 into l_id;
               ARP_CTLGD_PKG.set_to_dummy(l_dist_rec);
               l_dist_rec.ussgl_transaction_code := p_line_rec.DEFAULT_USSGL_TRANSACTION_CODE;
               ARP_CTLGD_PKG.update_f_ctl_id(l_dist_rec,l_id,'N','');
               exit when c1%NOTFOUND;
            END LOOP;
            close c1;
        EXCEPTION
        when NO_DATA_FOUND then
	         null;
        END;
        arp_util.debug('Completed stamping distributions with the transaction code when entered at line level');
       END IF;


--Bug#2750340
      l_ev_rec.xla_from_doc_id   := p_line_rec.customer_trx_id;
      l_ev_rec.xla_to_doc_id     := p_line_rec.customer_trx_id;
      l_ev_rec.xla_req_id        := NULL;
      l_ev_rec.xla_dist_id       := NULL;
      l_ev_rec.xla_doc_table     := 'CT';
      l_ev_rec.xla_doc_event     := NULL;
      l_ev_rec.xla_mode          := 'O';
      l_ev_rec.xla_call          := 'B';
      l_ev_rec.xla_fetch_size    := 999;
      arp_xla_events.create_events(p_xla_ev_rec => l_ev_rec );

      arp_util.debug('arp_process_line.insert_line()-');

EXCEPTION
    WHEN OTHERS THEN

        IF   (l_errorbuf is not null)
        THEN arp_util.debug('AutoAccounting error: ' || l_errorbuf);
        END IF;

       /*---------------------------------------------+
        |  Display parameters and raise the exception |
        +---------------------------------------------*/

        arp_util.debug('EXCEPTION:  arp_process_line.insert_line()');

        arp_util.debug('');
        arp_util.debug('---------- parameters for insert_line() ---------');

        arp_util.debug('p_form_name            = ' || p_form_name );
        arp_util.debug('p_form_version         = ' || p_form_version);
        arp_util.debug('p_memo_line_type       = ' || p_memo_line_type);
        arp_util.debug('');

        arp_ctl_pkg.display_line_rec(p_line_rec);

        RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_line			                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Updates a ra_customer_trx_lines record				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_form_name					     |
 |		      p_form_version					     |
 |		      p_customer_trx_line_id 				     |
 |                    p_line_rec					     |
 |		      p_foreign_currency_code				     |
 |		      p_exchange_rate 					     |
 |		      p_recalculate_tax_flag				     |
 |		      p_rerun_autoacc_flag				     |
 |              OUT:                                                         |
 |                    p_rule_start_date                                      |
 |                    p_accounting_rule_duration                             |
 |                    p_status                                               |
 |           IN OUT:                                                         |
 |                    p_gl_date                                              |
 |                    p_trx_date                                             |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     24-JUL-95  Charlie Tomberg     Created                                |
 |     17-JAN-96  Martin Johnson      Added call to credit memo module.      |
 |                                    Added OUT NOCOPY parameters            |
 |                                    p_rule_start_date                      |
 |                                    and p_accounting_rule_duration         |
 |     13-FEB-96  Martin Johnson      Added OUT NOCOPY parameters p_gl_date  |
 |                                    and  p_trx_date                        |
 |     20-MAR-96  Martin Johnson      Rewrote algorithm to figure out NOCOPY |
 |                                    whether to call CM module, autoacc, or |
 |                                    dist table handler to update           |
 |                                    distributions                          |
 |     20-MAY-96  Martin Johnson      BugNo:356814.  Added OUT NOCOPY        |
 |                                    parameter p_status.  Call tax engine   |
 |                                    in 'DEFERRED' mode so that 'soft'      |
 |                                    excpetion will be raise.               |
 |                                                                           |
 +===========================================================================*/


PROCEDURE update_line(
                p_form_name	        IN varchar2,
                p_form_version          IN number,
                p_customer_trx_line_id  IN
                              ra_customer_trx_lines.customer_trx_line_id%type,
                p_line_rec	        IN OUT NOCOPY ra_customer_trx_lines%rowtype,
                p_foreign_currency_code IN fnd_currencies.currency_code%type,
		p_exchange_rate         IN ra_customer_trx.exchange_rate%type,
                p_recalculate_tax_flag  IN boolean,
                p_rerun_autoacc_flag    IN boolean,
                p_rule_start_date       OUT NOCOPY
                                 ra_customer_trx_lines.rule_start_date%type,
                p_accounting_rule_duration OUT NOCOPY
                         ra_customer_trx_lines.accounting_rule_duration%type,
                p_gl_date                IN OUT NOCOPY
                         ra_cust_trx_line_gl_dist.gl_date%type,
                p_trx_date               IN OUT NOCOPY
                         ra_customer_trx.trx_date%type,
                p_status                 OUT NOCOPY varchar2 )
IS

      l_recalculate_tax_flag      boolean;
      l_derive_gldate_flag        boolean;
      l_amount_changed_flag       boolean;
      l_last_period_changed_flag  boolean;

      l_db_line_rec            ra_customer_trx_lines%rowtype;
      l_new_line_rec           ra_customer_trx_lines%rowtype;

      l_old_tax_amount	       NUMBER;
      l_new_tax_amount	       NUMBER;
      l_requery_tax_if_visible BOOLEAN;

      l_failure_count          number;
      l_rule_start_date        ra_customer_trx_lines.rule_start_date%type;
      l_accounting_rule_duration
                      ra_customer_trx_lines.accounting_rule_duration%type;

      l_old_trx_date           date;
      l_trx_date_changed       boolean;

      l_status1                varchar2(100);
      l_status2                varchar2(100);
      l_status3                varchar2(100);
      l_status4                varchar2(100);

      l_extended_amount		NUMBER;
      l_unit_selling_price	NUMBER;
      l_gross_extended_amount   NUMBER;
      l_gross_unit_selling_price NUMBER;
      --Bug#2750340
      l_ev_rec                   arp_xla_events.xla_events_type;

      /*Bug 3130851 and bug 3407389*/

      l_dist_rec        ra_cust_trx_line_gl_dist%rowtype;
      l_dist_line       ra_cust_trx_line_gl_dist.customer_trx_line_id%type;
      l_tax_computed    BOOLEAN;


--{BUG#5192414
CURSOR cpost IS
SELECT 'Y'
FROM ra_customer_trx_lines    l,
     ra_cust_trx_line_gl_dist d
WHERE l.customer_trx_line_id = p_customer_trx_line_id
AND   l.customer_trx_id      = d.customer_trx_id
AND   d.account_set_flag     = 'N'
AND   d.posting_Control_id  <> -3;

l_test   VARCHAR2(1);
--}
BEGIN

      arp_util.debug('arp_process_line.update_line()+');

      p_rule_start_date          := p_line_rec.rule_start_date;
      p_accounting_rule_duration := p_line_rec.accounting_rule_duration;

      l_old_trx_date     := p_trx_date;
      l_trx_date_changed := FALSE;

      /*----------------------------------------------+
       |   Check the form version to determine if it  |
       |   is compatible with the entity handler.     |
       +----------------------------------------------*/

      arp_trx_validate.ar_entity_version_check(p_form_name, p_form_version);

      /*---------------------------------------------------------------+
       |  Fetch the old record from the database for later comparisons |
       +---------------------------------------------------------------*/

      arp_ctl_pkg.fetch_p( l_db_line_rec,
                           p_customer_trx_line_id);


      /*-------------------------+
       |  Do required validation |
       +-------------------------*/

      arp_process_line.val_update_line(p_line_rec,
                                       l_db_line_rec,
                                       l_new_line_rec);



      /*----------------------------------------------------------------+
       | Lock rows in other tables that reference this customer_trx_id  |
       +----------------------------------------------------------------*/

      arp_trx_util.lock_transaction(l_db_line_rec.customer_trx_id);


      set_flags( p_line_rec,
                 l_db_line_rec,
                 l_db_line_rec.customer_trx_line_id,
                 l_derive_gldate_flag,
                 l_amount_changed_flag,
                 l_last_period_changed_flag);


      /*---------------------------------------------------------------------+
       |  check if tax needs to be recalculated                              |
       +---------------------------------------------------------------------*/

      BEGIN


        --  Check to see if any relevant columns have been updated which
        --  affect tax calculation. If there are columns which affect tax
        --  have been modified, we will delete the tax lines and the
        --  accounting from those lines before we will eventually call
        --  ETAX to recreate the tax lines.

        arp_etax_services_pkg.before_update_line(
                       l_db_line_rec.customer_trx_line_id,
                       p_line_rec,
                       l_recalculate_tax_flag);

        l_recalculate_tax_flag := l_recalculate_tax_flag OR
                                  p_recalculate_tax_flag;

      EXCEPTION
        WHEN OTHERS THEN

          arp_util.debug(
            'arp_etax_services_pkg.before_update_line raised exception');
          RAISE;
      END;

      /* Rel. 11: If amount changed or tax is recalculated, then
	 NULL out NOCOPY gross amounts, otherwise make sure the l_line_rec
	 amounts contain the right (original) values
      */

      IF (l_amount_changed_flag = TRUE OR
	  l_recalculate_tax_flag = TRUE) THEN
	 p_line_rec.gross_extended_amount := NULL;
	 p_line_rec.gross_unit_selling_price := NULL;
      ELSE
	 -- Bug 2833554
	 -- amounts have not changed, and tax engine is not called, so
	 -- set net amounts and gross amounts to AR_NUMBER_DUMMY to avoid update

	 p_line_rec.extended_amount := AR_NUMBER_DUMMY;
	 p_line_rec.unit_selling_price := AR_NUMBER_DUMMY;

	 p_line_rec.gross_extended_amount := AR_NUMBER_DUMMY;
	 p_line_rec.gross_unit_selling_price := AR_NUMBER_DUMMY;
      END IF;

      /*---------------------------------------------+
       |  Call the table handler to update the line  |
       +---------------------------------------------*/

      arp_ctl_pkg.update_p( p_line_rec,
                            p_customer_trx_line_id,
                            p_foreign_currency_code );

      /*--------------------------------------------------------------------+
       |  If the rule schedule has changed, the trx_date and gl_date        |
       |  may now be invalid. This may cause the tax to be invalid as well. |
       |  arp_dates.derive_gl_trx_dates_from_rules() rederives and          |
       |  resets the gl_date and trx date.                                  |
       +--------------------------------------------------------------------*/

      IF   ( l_derive_gldate_flag = TRUE )
      THEN
        arp_dates.derive_gl_trx_dates_from_rules (
   						l_db_line_rec.customer_trx_id,
 						p_gl_date,
						p_trx_date,
						l_recalculate_tax_flag );

        IF ( p_trx_date <> l_old_trx_date )
          THEN l_trx_date_changed := TRUE;
        END IF;

      END IF;


      /*----------------------------------------------------------------+
       |  recreate the tax lines associated with this transaction line  |
       +----------------------------------------------------------------*/

      IF    ( l_recalculate_tax_flag = TRUE  )
      THEN
         /*------------------------------------------------------------------+
          | Call Tax Engine, recalculating tax for this updated invoice line.|
          +------------------------------------------------------------------*/

         BEGIN

	   -- Rel. 11 call to new tax engine:

	   -- copy entered amounts into parameters

	   l_extended_amount := p_line_rec.extended_amount;
	   l_unit_selling_price := p_line_rec.unit_selling_price;

           /* we need to call the line_Det_Factors table handler so
              tax can get the attributes for calculating tax */
           ARP_ETAX_SERVICES_PKG.line_det_factors(
                       p_customer_trx_line_id => p_customer_trx_line_id,
                       p_customer_trx_id => p_line_rec.customer_trx_id,
                       p_mode => 'UPDATE');

/***************************************************************
           --  ETAX:  CAll Calculate in update mode

            l_tax_computed := ARP_ETAX_SERVICES_PKG.Calculate (
                    p_customer_trx_id =>  p_line_rec.customer_trx_id,
                    p_cust_trx_line_id => p_customer_trx_line_id,
                    p_action =>  'UPDATE',
                    p_line_level_action => 'UPDATE');

            IF (NOT l_tax_computed) THEN
               arp_util.debug('ERROR COMPUTING TAX ');
              app_exception.raise_exception;
            END IF;
*****************************************************************/


	    p_line_rec.extended_amount := l_extended_amount;
	    l_new_line_rec.extended_amount := l_extended_amount;
	    p_line_rec.unit_selling_price := l_unit_selling_price;
	    l_new_line_rec.unit_selling_price := l_unit_selling_price;

	    p_line_rec.gross_extended_amount := l_gross_extended_amount;
	    l_new_line_rec.gross_extended_amount := l_gross_extended_amount;
	    p_line_rec.gross_unit_selling_price := l_gross_unit_selling_price;
	    l_new_line_rec.gross_unit_selling_price := l_gross_unit_selling_price;


         EXCEPTION
           WHEN OTHERS THEN
             RAISE;

         END;

      END IF;

      /*---------------------------------------------------------------------+
       |  Update the salescredit lines associated with this transaction line |
       +---------------------------------------------------------------------*/

      IF   ( l_amount_changed_flag  = TRUE )
      THEN arp_ctls_pkg.update_amounts_f_ctl_id(p_customer_trx_line_id,
		                                l_new_line_rec.extended_amount,
                                                p_foreign_currency_code );
      END IF;

      /*-----------------------------------------------------------+
       |  IF transaction is a credit memo against a transaction    |
       |     AND rerun_autoacc is TRUE                             |
       |     OR CM has rules AND amount or last period changed     |
       |    THEN call CM module to update the distributions        |
       |  ELSIF rerun_autoacc is TRUE                              |
       |    THEN call autoaccounting to update the distributions   |
       |  ELSIF amount changed                                     |
       |    THEN update the distribution amounts                   |
       +-----------------------------------------------------------*/

      IF ( ( p_line_rec.previous_customer_trx_id IS NOT NULL )
           AND
           ( ( p_rerun_autoacc_flag )
             OR
             ( ( p_line_rec.accounting_rule_id IS NOT NULL )
               AND
               ( l_amount_changed_flag OR l_last_period_changed_flag )
             )
           )
         )
        THEN
          BEGIN
            arp_credit_memo_module.credit_transactions(
	                      p_line_rec.customer_trx_id,
                              p_customer_trx_line_id,
                              p_line_rec.previous_customer_trx_id,
                              p_line_rec.previous_customer_trx_line_id,
                              null,
                              l_failure_count,
                              l_rule_start_date,
                              l_accounting_rule_duration,
                              'U' );

            p_rule_start_date          := l_rule_start_date;
            p_accounting_rule_duration := l_accounting_rule_duration;

          EXCEPTION
            WHEN arp_credit_memo_module.no_ccid THEN

              l_status3 := 'ARP_CREDIT_MEMO_MODULE.NO_CCID';

            WHEN OTHERS THEN
              RAISE;
          END;

        ELSIF p_rerun_autoacc_flag
          THEN

            BEGIN

              line_rerun_aa( l_new_line_rec.customer_trx_id,
                             p_customer_trx_line_id );

              EXCEPTION
                WHEN arp_auto_accounting.no_ccid THEN

                  l_status4 := 'ARP_AUTO_ACCOUNTING.NO_CCID';

                WHEN OTHERS THEN
                  RAISE;
            END;

        ELSIF l_amount_changed_flag
          THEN
            arp_ctlgd_pkg.update_amount_f_ctl_id(
				             p_customer_trx_line_id,
 				             l_new_line_rec.extended_amount,
				             p_foreign_currency_code,
                	       	             pg_base_curr_code,
				             p_exchange_rate,
                                             pg_base_precision,
				             pg_base_min_acct_unit );
      END IF;

      arp_util.debug('l_status1  = ' || l_status1);
      arp_util.debug('l_status2  = ' || l_status2);
      arp_util.debug('l_status3  = ' || l_status3);
      arp_util.debug('l_status4  = ' || l_status4);

      IF    ( NVL(l_status1, 'OK') <> 'OK' )
      THEN  p_status := l_status1;
      ELSIF ( NVL(l_status2, 'OK') <> 'OK' )
         THEN  p_status := l_status2;
      ELSIF ( NVL(l_status3, 'OK') <> 'OK' )
         THEN  p_status := l_status3;
      ELSIF ( NVL(l_status4, 'OK') <> 'OK' )
         THEN  p_status := l_status4;
      ELSE     p_status := 'OK';
      END IF;


      /* Bug 3407389 and bug 3130851*/
      /* Check if any gl_dist rows are inserted for the current trx_line.*/

    BEGIN
      SELECT customer_trx_line_id
      INTO   l_dist_line
      FROM   ra_cust_trx_line_gl_dist
      WHERE  customer_trx_line_id = p_customer_trx_line_id
      AND    account_set_flag     = 'N'
      AND    ROWNUM               < 2;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
        l_dist_line := NULL;
    END;

      IF  ( p_line_rec.previous_customer_trx_id IS NOT NULL AND l_dist_line IS NOT NULL)

      THEN
         IF nvl(l_db_line_rec.DEFAULT_USSGL_TRANSACTION_CODE,0) <> nvl(p_line_rec.DEFAULT_USSGL_TRANSACTION_CODE,0)
         THEN

          arp_util.debug('Updating distributions with the transaction code when changed at line level');
          ARP_CTLGD_PKG.set_to_dummy(l_dist_rec);
          l_dist_rec.ussgl_transaction_code := p_line_rec.DEFAULT_USSGL_TRANSACTION_CODE;
          ARP_CTLGD_PKG.update_f_ctl_id(l_dist_rec,p_customer_trx_line_id,'N','');

          /* The logic below is mainly to hit the other rows in RA_CUST_TRX_LINE_GL_DIST which are
	     linked to the line updated above apart from the REC row*/
          DECLARE
          cursor c1 is select customer_trx_line_id
                       from ra_customer_trx_lines
	               where link_to_cust_trx_line_id = p_customer_trx_line_id;
          l_id number;
          BEGIN
            open c1;
            LOOP
               fetch c1 into l_id;
               ARP_CTLGD_PKG.set_to_dummy(l_dist_rec);
               l_dist_rec.ussgl_transaction_code := p_line_rec.DEFAULT_USSGL_TRANSACTION_CODE;
               ARP_CTLGD_PKG.update_f_ctl_id(l_dist_rec,l_id,'N','');
               exit when c1%NOTFOUND;
            END LOOP;
            close c1;
          EXCEPTION
          when NO_DATA_FOUND then
	         null;
          END;
          arp_util.debug('Completed updating distributions with the transaction code when changed at line level');
         END IF;
       END IF;

OPEN cpost;
FETCH cpost INTO l_test;
IF cpost%NOTFOUND THEN
--BUG#2750340
      l_ev_rec.xla_from_doc_id   := p_line_rec.customer_trx_id;
      l_ev_rec.xla_to_doc_id     := p_line_rec.customer_trx_id;
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

      arp_util.debug('arp_process_line.update_line()-');

EXCEPTION
    WHEN OTHERS THEN

        arp_util.debug('EXCEPTION:  arp_process_line.update_line()');

        arp_util.debug('');
        arp_util.debug('---------- parameters for update_line() ---------');

        arp_util.debug('p_form_name             = ' || p_form_name );
        arp_util.debug('p_form_version          = ' || p_form_version);
        arp_util.debug('p_customer_trx_line_id  = ' ||
                       p_customer_trx_line_id);
        arp_util.debug('p_foreign_currency_code = ' ||p_foreign_currency_code);
        arp_util.debug('p_exchange_rate         = ' || p_exchange_rate);
        arp_util.debug('p_recalculate_tax_flag  = ' ||
                     arp_trx_util.boolean_to_varchar2(p_recalculate_tax_flag));
        arp_util.debug('p_rerun_autoacc_flag    = ' ||
                       arp_trx_util.boolean_to_varchar2(p_rerun_autoacc_flag));

        arp_util.debug('');

        arp_ctl_pkg.display_line_rec(p_line_rec);

        RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_line			                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Deletes records from ra_customer_trx_lines			     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_form_name					     |
 |		      p_form_version					     |
 |		      p_customer_trx_line_id				     |
 |                    p_complete_flag 					     |
 |		      p_recalculate_tax_flag 				     |
 |		      p_trx_amount   					     |
 |		      p_exchange_rate					     |
 |                    p_line_rec 					     |
 |              IN / OUT:                                                    |
 |                    p_gl_date						     |
 |                    p_trx_date					     |
 |              OUT:                                                         |
 |                    p_status                                               |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     24-JUL-95  Charlie Tomberg     Created                                |
 |     15-MAR-96  Martin Johnson      Delete from ar_credit_memo_amounts if  |
 |                                    the transaction is a credit memo with  |
 |                                    rules.                                 |
 |                                    Do not derive gl and trx dates for CM's|
 |     20-MAY-96  Martin Johnson      BugNo:356814.  Added OUT NOCOPY parameter     |
 |                                      p_status.  Call tax engine in        |
 |                                      'DEFERRED' mode so that 'soft'       |
 |                                      excpetion will be raise.             |
 |  21-OCT-1997		OSTEINME      Bug 565566:
 |				      added call to procedure
 |				      arp_ctlgd_pkg.delete_f_ct_ltctl_id_type
 |                                                                           |
 +===========================================================================*/


PROCEDURE delete_line(p_form_name		IN varchar2,
                       p_form_version		IN number,
                       p_customer_trx_line_id	IN
                               ra_customer_trx_lines.customer_trx_line_id%type,
                       p_complete_flag   IN ra_customer_trx.complete_flag%type,
		       p_recalculate_tax_flag  	IN boolean,
                       p_trx_amount         	IN number,
                       p_exchange_rate  IN ra_customer_trx.exchange_rate%type,
		       p_header_currency_code IN fnd_currencies.currency_code%type,
	 	       p_gl_date  IN OUT NOCOPY ra_cust_trx_line_gl_dist.gl_date%type,
	 	       p_trx_date IN OUT NOCOPY ra_customer_trx.trx_date%type,
                       p_line_rec    IN ra_customer_trx_lines%rowtype,
                       p_status OUT NOCOPY varchar2 ) IS

   l_recalculate_tax_flag boolean;
   l_old_tax_amount       NUMBER;
   l_new_tax_amount       NUMBER;
   l_tax_computed   BOOLEAN;

   --added for bug 7478499
    CURSOR cont_cursor IS
     select alc.customer_trx_line_id
     from  ra_customer_trx_lines ctl,
           ar_line_conts alc
     where
     ctl.customer_trx_line_id = p_customer_trx_line_id
     and ctl.customer_trx_line_id = alc.customer_trx_line_id
     and ctl.line_type = 'LINE'
     FOR UPDATE OF alc.customer_trx_line_id NOWAIT;

   CURSOR deferred_cursor IS
     select customer_trx_line_id
     from  ar_deferred_lines
     where customer_trx_line_id = p_customer_trx_line_id
     FOR UPDATE OF customer_trx_line_id NOWAIT;
BEGIN

   arp_util.debug('arp_process_line.delete_line()+');

   p_status := 'OK';

      /*----------------------------------------------+
       |   Check the form version to determine if it  |
       |   is compatible with the entity handler.     |
       +----------------------------------------------*/

      arp_trx_validate.ar_entity_version_check(p_form_name, p_form_version);

      /*-------------------------+
       |  Do required validation |
       +-------------------------*/

      arp_process_line.val_delete_line(p_line_rec,
                                       p_complete_flag);


      l_recalculate_tax_flag := p_recalculate_tax_flag;

      /*----------------------------------------------------------------+
       | Lock rows in other tables that reference this customer_trx_id  |
       +----------------------------------------------------------------*/

      arp_trx_util.lock_transaction(p_line_rec.customer_trx_id);

      /*---------------------------------------------------------------------+
       | Call Tax Engine, deleting any tax associated with this line.        |
       +---------------------------------------------------------------------*/

       arp_etax_services_pkg.before_delete_line(
              p_customer_trx_line_id =>   p_customer_trx_line_id,
              p_customer_trx_id      =>   p_line_rec.customer_trx_id);


       /*---------------------------------------------------+
        |  Delete the account assignments associated with   |
        |  the freight line.        			    |
        +---------------------------------------------------*/

      arp_ctlgd_pkg.delete_f_ct_ltctl_id_type(
		p_line_rec.customer_trx_id,
		p_customer_trx_line_id,
		'FREIGHT',
		NULL,
		NULL);

       /*------------------------------------------------------------------+
        |  Delete the tax and freight lines that are associated with this  |
        |  line of type LINE.						   |
        +------------------------------------------------------------------*/

      arp_ctl_pkg.delete_f_ltctl_id( p_customer_trx_line_id );

       /*------------------------------------------------------+
        |  Delete the salescredits associated with this line.  |
        +------------------------------------------------------*/

      arp_ctls_pkg.delete_f_ctl_id( p_customer_trx_line_id );


       /*---------------------------------------------------+
        |  Delete the account assignments and account sets  |
        |  associated with this line. 			    |
        +---------------------------------------------------*/

      arp_ctlgd_pkg.delete_f_ctl_id( p_customer_trx_line_id,
				     null,
				     null );

      /*------------------------------------------------------------+
       |  Delete from ar_credit_memo_amounts if the transaction is  |
       |  a credit memo with rules.                                 |
       +------------------------------------------------------------*/

      IF ( (p_line_rec.previous_customer_trx_line_id IS NOT NULL) AND
           (p_line_rec.accounting_rule_id IS NOT NULL ) )
        THEN
          arp_cma_pkg.delete_f_ctl_id( p_customer_trx_line_id );
      END IF;

--added for bug 7478499
     BEGIN
        FOR l_cont_rec IN cont_cursor LOOP
                  delete from ar_line_conts
                  where customer_trx_line_id = l_cont_rec.customer_trx_line_id;
        END LOOP;

        FOR l_deferred_rec IN deferred_cursor LOOP
                  delete from ar_deferred_lines
                  WHERE  customer_trx_line_id = l_deferred_rec.customer_trx_line_id;
        END LOOP;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
          null;
        WHEN OTHERS THEN
          RAISE;
      END;

      /*-----------------------------------------------------+
       |  call the table-handler to delete the line record  |
       +-----------------------------------------------------*/

      arp_ctl_pkg.delete_p( p_customer_trx_line_id );

      /*--------------------------------------------------------------------+
       | If the line had rules, the trx_date and gl_date may have to        |
       | change if they were originally set to their current values because |
       | of the rule schedule of the line that has just been deleted.       |
       | arp_dates.derive_gl_trx_dates_from_rules() rederives and resets    |
       | the trx_date and gl_date.					    |
       |								    |
       | If the line that was deleted was the last line on a transaction    |
       | that has header freight and rules, the transaction is no longer    |
       | valid because header freight only transactions cannot have rules.  |
       | header_freight_only_rules_case() converts the transaction to one   |
       | without rules in this case.					    |
       +--------------------------------------------------------------------*/

      IF (p_line_rec.accounting_rule_id IS NOT NULL )
      THEN

            IF ( p_line_rec.previous_customer_trx_line_id IS NULL )
              THEN
       	        arp_dates.derive_gl_trx_dates_from_rules(
                                                 p_line_rec.customer_trx_id,
 			                         p_gl_date,
			                         p_trx_date,
                                                 l_recalculate_tax_flag);
            END IF;

            header_freight_only_rules_case( p_line_rec.customer_trx_id,
					    p_trx_amount,
                               		    p_exchange_rate,
	   	 		            p_gl_date);


       END IF;

       IF   ( l_recalculate_tax_flag = TRUE )
       THEN -- salestax delete
            -- call header tax in update mode if the trx_date has changed
            --      (the tax may not be valid for the new trx_date)
            null;
       END IF;

      arp_util.debug('arp_process_line.delete_line()-');

EXCEPTION
    WHEN OTHERS THEN

       /*---------------------------------------------+
        |  Display parameters and raise the exception |
        +---------------------------------------------*/

        arp_util.debug('EXCEPTION:  arp_process_line.delete_line()');

        arp_util.debug('');
        arp_util.debug('---------- parameters for delete_line() ---------');

        arp_util.debug('p_form_name                 = ' || p_form_name );
        arp_util.debug('p_form_version              = ' || p_form_version);
        arp_util.debug('p_customer_trx_line_id      = ' ||
                                                     p_customer_trx_line_id);
        arp_util.debug('p_complete_flag             = ' || p_complete_flag);
        arp_util.debug('p_recalculate_tax_flag      = ' ||
                     arp_trx_util.boolean_to_varchar2(p_recalculate_tax_flag));
        arp_util.debug('p_trx_amount                = ' || p_trx_amount);
        arp_util.debug('p_exchange_rate             = ' || p_exchange_rate);
        arp_util.debug('p_gl_date                   = ' || p_gl_date);
        arp_util.debug('p_trx_date                  = ' || p_trx_date);
        arp_util.debug('');

        arp_ctl_pkg.display_line_rec(p_line_rec);

        RAISE;

END;


  /*---------------------------------------------+
   |   Package initialization section.           |
   +---------------------------------------------*/

BEGIN

        pg_base_curr_code     := arp_trx_global.system_info.base_currency;
        pg_base_precision     := arp_trx_global.system_info.base_precision;
        pg_base_min_acct_unit := arp_trx_global.system_info.base_min_acc_unit;
        pg_earliest_date      := to_date('01/01/1901', 'DD/MM/YYYY');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_process_line.initialization');
        RAISE;


END ARP_PROCESS_LINE;

/
