--------------------------------------------------------
--  DDL for Package Body ARP_TRX_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_TRX_UTIL" AS
/* $Header: ARTUTILB.pls 120.7.12010000.2 2008/11/13 15:43:17 rmanikan ship $ */

pg_base_curr_code     gl_sets_of_books.currency_code%type;
pg_base_precision     fnd_currencies.precision%type;
pg_base_min_acc_unit  fnd_currencies.minimum_accountable_unit%type;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_transaction                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Deletes all records in all tables associated with a particular         |
 |    transcation.                                                           |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    dbms_sql.bind_variable                                                 |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_form_name                                            |
 |                    p_form_version                                         |
 |                    p_customer_trx_is                                      |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     05-JUL-95  Charlie Tomberg     Created                                |
 |     21-AUG-97  OSTEINME	      Bug 514459: Delete Payment Schedules   |
 |					when transaction is deleted          |
 |     24-JUL-02  VERAO               Bug 2217253: Delete RA record of a CM  |
 |                                      when transaction is deleted          |
 |     11-APR-03  MRAYMOND        Bug 2868648 - remove CMA rows when
 |                                    transaction is deleted.
 +===========================================================================*/
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE delete_transaction(p_form_name         IN varchar2,
                             p_form_version      IN number,
                             p_customer_trx_id   IN NUMBER) IS


BEGIN

   arp_util.debug('arp_process_header.delete_transaction()+');

   -- check form version to determine if it is compatible with the
   -- entity handler.
   --   arp_trx_validate.ar_entity_version_check(p_form_name, p_form_version);

   -- MRC trigger replacement:
   -- Delete sales credit first because it requires an update to
   -- the gl_dist / lines tables

   arp_ctls_pkg.delete_f_ct_id(p_customer_trx_id);

   arp_ct_pkg.delete_p(p_customer_trx_id);

   /* Bug 2868648 - remove CMA rows, too! */
   arp_cma_pkg.delete_f_ct_id(p_customer_trx_id);

   arp_ctl_pkg.delete_f_ct_id(p_customer_trx_id);
   arp_ctlgd_pkg.delete_f_ct_id(p_customer_trx_id, '', '');
   arp_ps_pkg.delete_f_ct_id(p_customer_trx_id);

-- Bugfix 2217253. Uncommented the line below
   arp_app_pkg.delete_f_ct_id(p_customer_trx_id);


   arp_util.debug('arp_process_header.delete_transaction()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_process_header.delete_transaction()');
        rollback to savepoint ar_delete_transaction_1;
        RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_transaction			                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Locks all records in all tables associated with a particular           |
 |    transcation.							     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    dbms_sql.bind_variable                                                 |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_form_name					     |
 |		      p_form_version					     |
 |		      p_customer_trx_id 				     |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     05-JUL-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE lock_transaction(p_customer_trx_id   IN NUMBER) IS


BEGIN

   arp_util.debug('arp_trx_util.lock_transaction()+');

   -- check form version to determine if it is compatible with the
   -- entity handler.
   --   arp_trx_validate.ar_entity_version_check(p_form_name, p_form_version);


   savepoint ar_lock_transaction_1;

   arp_ct_pkg.lock_p(p_customer_trx_id);
   arp_ctl_pkg.lock_f_ct_id(p_customer_trx_id);
   arp_ctls_pkg.lock_f_ct_id(p_customer_trx_id);
   arp_ctlgd_pkg.lock_f_ct_id(p_customer_trx_id, '', '');
   arp_ps_pkg.lock_f_ct_id(p_customer_trx_id);
   arp_adjustments_pkg.lock_f_ct_id(p_customer_trx_id);


   arp_util.debug('arp_trx_util.lock_transaction()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_trx_util.delete_lock()');
        rollback to savepoint ar_lock_transaction_1;
        RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    set_term_in_use_flag		                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Sets the ra_terms.in_use flag if necessary.			     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    dbms_sql.bind_variable                                                 |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_form_name					     |
 |		      p_form_version					     |
 |		      p_term_id						     |
 |		      p_term_in_use_flag 				     |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     05-JUL-95  Charlie Tomberg     Created                                |
 |     22-DEC-98  Victoria Smith      Changes RA_TERMS to RA_TERMS_B, so that|
 |                                    update will be done on base MLS table  |
 |                                                                           |
 +===========================================================================*/


PROCEDURE set_term_in_use_flag(p_form_name         IN varchar2,
                               p_form_version      IN number,
                               p_term_id           IN number,
                               p_term_in_use_flag  IN varchar2) IS


BEGIN

   arp_util.debug('arp_trx_util.set_term_in_use_flag()+');

   -- check form version to determine if it is compatible with the
   -- entity handler.
   --   arp_trx_validate.ar_entity_version_check(p_form_name, p_form_version);

   -- Set term in use flag to Yes unless it already is in use.


   IF (NVL(p_term_in_use_flag, 'N') = 'N')
   THEN
       arp_util.debug('setting the in_use flag for term ' || p_term_id ||
                      ' to  Y.');

        UPDATE ra_terms_b
           SET in_use   = 'Y'
         WHERE term_id  = p_term_id
           AND in_use   = 'N';
   END IF;

   arp_util.debug('arp_trx_util.set_term_in_use_flag()-');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        null;
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_trx_util.set_term_in_use_flag()');
        RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    set_posted_flag			                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Determines if a transaction has been posted.			     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_customer_trx_id 				     |
 |              OUT:                                                         |
 |                    p_posted_flag                                          |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-JUL-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE set_posted_flag(p_customer_trx_id   IN NUMBER,
                          p_posted_flag      OUT NOCOPY BOOLEAN) IS

   l_posted_flag varchar2(2);

BEGIN

   arp_util.debug('arp_trx_util.set_posted_flag()+');

   SELECT decode(max(dummy),
                 NULL, 'N',
                     'Y')

   INTO   l_posted_flag
   FROM   dual
   WHERE  EXISTS
                 (SELECT 'posted distribution exists'
                  FROM   ra_cust_trx_line_gl_dist
                  WHERE  customer_trx_id  = p_customer_trx_id
                  AND    account_set_flag = 'N'
                  AND    gl_posted_date   IS NOT NULL
                 );

   IF      (l_posted_flag = 'Y')
   THEN    p_posted_flag := TRUE;
   ELSE    p_posted_flag := FALSE;
   END IF;

   arp_util.debug('arp_trx_util.set_posted_flag()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_trx_util.set_posted_flag()');
        RAISE;

END;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    boolean_to_varchar2		                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Converts a boolean value to a varchar2				     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_boolean	 					     |
 |              OUT:                                                         |
 |		      None						     |
 |                                                                           |
 | RETURNS    : varchar2 value                                               |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     18-JUL-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


FUNCTION boolean_to_varchar2(p_boolean IN boolean) RETURN varchar2 IS

   l_result varchar2(6);

BEGIN

   IF    (p_boolean = TRUE)
   THEN  l_result := 'TRUE';
   ELSE  l_result := 'FALSE';
   END IF;

   return(l_result);

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_trx_util.boolean_to_varchar2()');
        RAISE;

END;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    detect_freight_only_rules_case	                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns TRUE if the specified transaction is a header freight only     |
 |    transaction with rules.						     |
 |                                                                           |
 |    If the case is detected, the function returns TRUE and puts a warning  |
 |    message on the message stack.					     |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_customer_trx_id					     |
 |              OUT:                                                         |
 |		      None						     |
 |                                                                           |
 | RETURNS    :       TRUE if the specified transaction is a freight only    |
 |                         transaction with rules.                           |
 |		      FALSE otherwise.					     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     25-JUL-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


FUNCTION detect_freight_only_rules_case( p_customer_trx_id IN
                                         ra_customer_trx.customer_trx_id%type )
                      RETURN BOOLEAN IS

   l_result  varchar2(2);

BEGIN
   arp_util.debug('arp_trx_util.detect_freight_only_rules_case()+');


   SELECT DECODE( MAX(t.customer_trx_id),
                  NULL, 'N',
                      'Y')
   INTO   l_result
   FROM   ra_customer_trx t,
          ra_customer_trx_lines l,
          ra_customeR_trx_lines frt
   WHERE  t.customer_trx_id              = p_customer_trx_id
   AND    t.customer_trx_id              = frt.customer_trx_id
   AND    frt.line_type                  = 'FREIGHT'
   AND    frt.link_to_cust_trx_line_id  IS NULL
   AND    t.customer_trx_id              = l.customer_trx_id(+)
   AND    'FREIGHT'                     <> l.line_type(+)
   AND    t.invoicing_rule_id           IS NOT NULL
   AND    l.customer_trx_line_id        IS NULL;

   IF      ( l_result = 'Y' )
   THEN    fnd_message.set_name('AR', 'AR_INV_RULE_CLEARED');
           RETURN(TRUE);
   ELSE    RETURN FALSE;
   END IF;

   arp_util.debug('arp_trx_util.detect_freight_only_rules_case()-');

EXCEPTION
 WHEN OTHERS THEN
   arp_util.debug('EXCEPTION:  arp_trx_util.detect_freight_only_rules_case()');
   RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    transaction_balances						     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Determines the balances for a transaction				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_id         - identifies the transaction |
 |                    p_open_receivables_flag                                |
 |                    p_exchange_rate                                        |
 |                    p_mode           - Can be 'ALL'  or 'SUMMARY'          |
 |                                     - All balances are returned in ALL    |
 |                                       mode. Only the Txn. original and    |
 |                                       remaining balances are returned     |
 |                                       in SUMMARY mode.                    |
 |                                                                           |
 |                    p_currency_mode  - Can be 'E'(ntered) or 'A'(ll)       |
 |                                     - The base currency amounts are only  |
 |                                       calculated and returned in 'A' mode.|
 |              OUT:                                                         |
 |                    < entered currency balances >                          |
 |                    < base currency balances >                             |
 |                                                                           |
 | NOTES                                                                     |
 |     Rounding errors for the base amounts are corrected in this procedure  |
 |     by putting the rounding error on the line balances. This may not be   |
 |     the same as how the rounding errors are corrected on the actual       |
 |     transaction. Therefore, the base line, tax and freight balances may   |
 |     not be accurate. The totals are always accurate, however.             |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     31-AUG-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE transaction_balances(
                              p_customer_trx_id             IN
                                        ra_customer_trx.customer_trx_id%type,
                              p_open_receivables_flag       IN
                                 ra_cust_trx_types.accounting_affect_flag%type,
                              p_exchange_rate               IN
                                 ra_customer_trx.exchange_rate%type,
                              p_mode                        IN VARCHAR2,
                              p_currency_mode               IN VARCHAR2,
                              p_line_original              OUT NOCOPY NUMBER,
                              p_line_remaining             OUT NOCOPY NUMBER,
                              p_tax_original               OUT NOCOPY NUMBER,
                              p_tax_remaining              OUT NOCOPY NUMBER,
                              p_freight_original           OUT NOCOPY NUMBER,
                              p_freight_remaining          OUT NOCOPY NUMBER,
                              p_charges_original           OUT NOCOPY NUMBER,
                              p_charges_remaining          OUT NOCOPY NUMBER,
                              p_line_discount              OUT NOCOPY NUMBER,
                              p_tax_discount               OUT NOCOPY NUMBER,
                              p_freight_discount           OUT NOCOPY NUMBER,
                              p_charges_discount           OUT NOCOPY NUMBER,
                              p_total_discount             OUT NOCOPY NUMBER,
                              p_total_original             OUT NOCOPY NUMBER,
                              p_total_remaining            OUT NOCOPY NUMBER,
                              p_line_receipts              OUT NOCOPY NUMBER,
                              p_tax_receipts               OUT NOCOPY NUMBER,
                              p_freight_receipts           OUT NOCOPY NUMBER,
                              p_charges_receipts           OUT NOCOPY NUMBER,
                              p_total_receipts             OUT NOCOPY NUMBER,
                              p_line_credits               OUT NOCOPY NUMBER,
                              p_tax_credits                OUT NOCOPY NUMBER,
                              p_freight_credits            OUT NOCOPY NUMBER,
                              p_total_credits              OUT NOCOPY NUMBER,
                              p_line_adjustments           OUT NOCOPY NUMBER,
                              p_tax_adjustments            OUT NOCOPY NUMBER,
                              p_freight_adjustments        OUT NOCOPY NUMBER,
                              p_charges_adjustments        OUT NOCOPY NUMBER,
                              p_total_adjustments          OUT NOCOPY NUMBER,
                              p_aline_adjustments          OUT NOCOPY NUMBER,
                              p_atax_adjustments           OUT NOCOPY NUMBER,
                              p_afreight_adjustments       OUT NOCOPY NUMBER,
                              p_acharges_adjustments       OUT NOCOPY NUMBER,
                              p_atotal_adjustments         OUT NOCOPY NUMBER,
                              p_base_line_original         OUT NOCOPY NUMBER,
                              p_base_line_remaining        OUT NOCOPY NUMBER,
                              p_base_tax_original          OUT NOCOPY NUMBER,
                              p_base_tax_remaining         OUT NOCOPY NUMBER,
                              p_base_freight_original      OUT NOCOPY NUMBER,
                              p_base_freight_remaining     OUT NOCOPY NUMBER,
                              p_base_charges_original      OUT NOCOPY NUMBER,
                              p_base_charges_remaining     OUT NOCOPY NUMBER,
                              p_base_line_discount         OUT NOCOPY NUMBER,
                              p_base_tax_discount          OUT NOCOPY NUMBER,
                              p_base_freight_discount      OUT NOCOPY NUMBER,
                              p_base_total_discount        OUT NOCOPY NUMBER,
                              p_base_total_original        OUT NOCOPY NUMBER,
                              p_base_total_remaining       OUT NOCOPY NUMBER,
                              p_base_line_receipts         OUT NOCOPY NUMBER,
                              p_base_tax_receipts          OUT NOCOPY NUMBER,
                              p_base_freight_receipts      OUT NOCOPY NUMBER,
                              p_base_charges_receipts      OUT NOCOPY NUMBER,
                              p_base_total_receipts        OUT NOCOPY NUMBER,
                              p_base_line_credits          OUT NOCOPY NUMBER,
                              p_base_tax_credits           OUT NOCOPY NUMBER,
                              p_base_freight_credits       OUT NOCOPY NUMBER,
                              p_base_total_credits         OUT NOCOPY NUMBER,
                              p_base_line_adjustments      OUT NOCOPY NUMBER,
                              p_base_tax_adjustments       OUT NOCOPY NUMBER,
                              p_base_freight_adjustments   OUT NOCOPY NUMBER,
                              p_base_charges_adjustments   OUT NOCOPY NUMBER,
                              p_base_total_adjustments     OUT NOCOPY NUMBER,
                              p_base_aline_adjustments     OUT NOCOPY NUMBER,
                              p_base_atax_adjustments      OUT NOCOPY NUMBER,
                              p_base_afreight_adjustments  OUT NOCOPY NUMBER,
                              p_base_acharges_adjustments  OUT NOCOPY NUMBER,
                              p_base_atotal_adjustments    OUT NOCOPY NUMBER
                             ) IS


BEGIN
   arp_util.debug('arp_trx_util.transaction_balances()+');

   arp_bal_util.transaction_balances(
                              p_customer_trx_id,
                              p_open_receivables_flag,
                              p_exchange_rate,
                              p_mode,
                              p_currency_mode,
                              p_line_original,
                              p_line_remaining,
                              p_tax_original,
                              p_tax_remaining,
                              p_freight_original,
                              p_freight_remaining,
                              p_charges_original,
                              p_charges_remaining,
                              p_line_discount,
                              p_tax_discount,
                              p_freight_discount,
                              p_charges_discount,
                              p_total_discount,
                              p_total_original,
                              p_total_remaining,
                              p_line_receipts,
                              p_tax_receipts,
                              p_freight_receipts,
                              p_charges_receipts,
                              p_total_receipts,
                              p_line_credits,
                              p_tax_credits,
                              p_freight_credits,
                              p_total_credits,
                              p_line_adjustments,
                              p_tax_adjustments,
                              p_freight_adjustments,
                              p_charges_adjustments,
                              p_total_adjustments,
                              p_aline_adjustments,
                              p_atax_adjustments,
                              p_afreight_adjustments,
                              p_acharges_adjustments,
                              p_atotal_adjustments,
                              p_base_line_original,
                              p_base_line_remaining,
                              p_base_tax_original,
                              p_base_tax_remaining,
                              p_base_freight_original,
                              p_base_freight_remaining,
                              p_base_charges_original,
                              p_base_charges_remaining,
                              p_base_line_discount,
                              p_base_tax_discount,
                              p_base_freight_discount,
                              p_base_total_discount,
                              p_base_total_original,
                              p_base_total_remaining,
                              p_base_line_receipts,
                              p_base_tax_receipts,
                              p_base_freight_receipts,
                              p_base_charges_receipts,
                              p_base_total_receipts,
                              p_base_line_credits,
                              p_base_tax_credits,
                              p_base_freight_credits,
                              p_base_total_credits,
                              p_base_line_adjustments,
                              p_base_tax_adjustments,
                              p_base_freight_adjustments,
                              p_base_charges_adjustments,
                              p_base_total_adjustments,
                              p_base_aline_adjustments,
                              p_base_atax_adjustments,
                              p_base_afreight_adjustments,
                              p_base_acharges_adjustments,
                              p_base_atotal_adjustments
                             );



   arp_util.debug('arp_trx_util.transaction_balances()-');

EXCEPTION
 WHEN OTHERS THEN
   arp_util.debug('EXCEPTION:  arp_trx_util.transaction_balances()');
   RAISE;

END;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_summary_trx_balances      	                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns the original and remaining balances for a transaction.         |
 |    This procedure does not provide the line type breakdown for credits,   |
 |    adjustments, receipts or discounts. It also does not provide base      |
 |    currency amounts.                                                      |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_customer_trx_id					     |
 |                    p_open_receivables_flag                                |
 |                    p_exchange_rate                                        |
 |              OUT:                                                         |
 |                    p_line_original                                        |
 |                    p_line_remaining                                       |
 |                    p_tax_original                                         |
 |                    p_tax_remaining                                        |
 |                    p_freight_original                                     |
 |                    p_freight_remaining                                    |
 |                    p_charges_original                                     |
 |                    p_charges_remaining                                    |
 |                    p_total_original                                       |
 |                    p_total_remaining                                      |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     05-SEP-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE get_summary_trx_balances( p_customer_trx_id       IN
                                        ra_customer_trx.customer_trx_id%type,
                              p_open_receivables_flag       IN
                                 ra_cust_trx_types.accounting_affect_flag%type,
                              p_line_original              OUT NOCOPY NUMBER,
                              p_line_remaining             OUT NOCOPY NUMBER,
                              p_tax_original               OUT NOCOPY NUMBER,
                              p_tax_remaining              OUT NOCOPY NUMBER,
                              p_freight_original           OUT NOCOPY NUMBER,
                              p_freight_remaining          OUT NOCOPY NUMBER,
                              p_charges_original           OUT NOCOPY NUMBER,
                              p_charges_remaining          OUT NOCOPY NUMBER,
                              p_total_original             OUT NOCOPY NUMBER,
                              p_total_remaining            OUT NOCOPY NUMBER )
                      IS
   l_dummy  NUMBER;


BEGIN
   arp_util.debug('arp_trx_util.get_summary_trx_balances()+');

   arp_bal_util.get_summary_trx_balances( p_customer_trx_id,
                                          p_open_receivables_flag,
                                          p_line_original,
                                          p_line_remaining,
                                          p_tax_original,
                                          p_tax_remaining,
                                          p_freight_original,
                                          p_freight_remaining,
                                          p_charges_original,
                                          p_charges_remaining,
                                          p_total_original,
                                          p_total_remaining );

   arp_util.debug('arp_trx_util.get_summary_trx_balances()-');

EXCEPTION
 WHEN OTHERS THEN
   arp_util.debug('EXCEPTION:  arp_trx_util.get_summary_trx_balances()');
   RAISE;

END;

/*===========================================================================+
 | FUNTION                                                                   |
 |    IS_FV_ENABLED                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Checks whether the Federal is enabled or not using                     |
 |    Federal Financial api fv_install.enabled.                              |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |         arp_standard.debug                                                |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                                                                           |
 |             OUT:                                                          |
 |                                                                           |
 | RETURNS    : T - True, F - False                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     23-Jun-08	      Thirumalaisamy      	Created                        |
 +===========================================================================*/
FUNCTION IS_FV_ENABLED RETURN VARCHAR2
  IS
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug ('inside IS_FV_ENABLED');
   END IF;

  IF(fv_install.enabled) THEN
    RETURN 'T';
  ELSE
    RETURN 'F';
  END IF;

EXCEPTION
    WHEN OTHERS THEN
      arp_standard.debug ('Exception occurred in IS_FV_ENABLED :'||SQLERRM);
      RETURN 'F';
END;

/*===========================================================================+
 | FUNTION                                                                   |
 |    IS_CCR_SUPPLIER                                                        |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Checks the given party/site is CCR supplier/Site                       |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |         arp_standard.debug                                                |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_object_type - CUST - Customer, ADDR - Address         |
 |             OUT:                                                          |
 |                                                                           |
 | RETURNS    : T - True, F - False                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     23-Jun-08	      Thirumalaisamy      	Created                        |
 +===========================================================================*/

FUNCTION IS_CCR_SUPPLIER(
 p_object_type           IN      VARCHAR2 ,
 p_object_id             IN      NUMBER
 )RETURN VARCHAR2
IS
l_api_version           NUMBER        := 1.0;
l_init_msg_list         VARCHAR2(1)   := FND_API.G_TRUE;
l_out_status            VARCHAR2(1);
is_enabled              VARCHAR2(1);
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(3000);
l_error_code            NUMBER;
l_ccr_id                NUMBER;
l_vendor_id             NUMBER;

cursor l_addr_site_cur is
select vendor_site_id from ap_supplier_sites_all
WHERE party_site_id = p_object_id;

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug ('p_object_type = '||p_object_type || ', p_object_id = '||p_object_id);
    END IF;

    l_out_status := 'F';
    is_enabled := ARP_TRX_UTIL.IS_FV_ENABLED();

    IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug ('is_enabled = '||is_enabled);
    END IF;

    IF is_enabled <> 'T' THEN
        RETURN l_out_status;
    ELSIF (p_object_type = 'CUST') THEN
        SELECT vendor_id INTO l_vendor_id FROM po_vendors WHERE party_id = p_object_id;
        FV_CCR_GRP.FV_IS_CCR(
            		  l_api_version,
            		  l_init_msg_list,
            		  l_vendor_id,
            		  'S',
            		  l_return_status,
            		  l_msg_count,
            		  l_msg_data,
            		  l_ccr_id,
            		  l_out_status,
            		  l_error_code
            		);
        IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug ('l_return_status = '||l_return_status);
            arp_standard.debug ('l_msg_count = '||l_msg_count);
            arp_standard.debug ('l_msg_data = '||l_msg_data);
            arp_standard.debug ('l_ccr_id = '||l_ccr_id);
            arp_standard.debug ('l_out_status = '||l_out_status);
            arp_standard.debug ('l_error_code = '||l_error_code);

        END IF;
    ELSIF (p_object_type = 'ADDR') THEN
          for  i in l_addr_site_cur  loop
              IF PG_DEBUG in ('Y', 'C') THEN
                  arp_standard.debug ('i.vendor_site_id  = '||i.vendor_site_id);
              END IF;
      	      FV_CCR_GRP.FV_IS_CCR(
      			  l_api_version,
      			  l_init_msg_list,
      			  i.vendor_site_id,
      			  'T',
      			  l_return_status,
      			  l_msg_count,
      			  l_msg_data,
      			  l_ccr_id,
      			  l_out_status,
      			  l_error_code
      			);
      	      IF PG_DEBUG in ('Y', 'C') THEN
                  arp_standard.debug ('l_return_status = '||l_return_status);
                  arp_standard.debug ('l_msg_count = '||l_msg_count);
                  arp_standard.debug ('l_msg_data = '||l_msg_data);
                  arp_standard.debug ('l_ccr_id = '||l_ccr_id);
                  arp_standard.debug ('l_out_status = '||l_out_status);
                  arp_standard.debug ('l_error_code = '||l_error_code);
              END IF;

      	      IF l_out_status <> 'F' THEN
      	  	return l_out_status;
      	       END IF;
    	 END LOOP;
    END IF;
RETURN l_out_status;
EXCEPTION
    WHEN OTHERS THEN
      arp_standard.debug ('Exception occurred in IS_CCR_SUPPLIER: '||SQLERRM);
      RETURN 'F';
END ;

  /*---------------------------------------------+
   |   Package initialization section.           |
   +---------------------------------------------*/
PROCEDURE init IS
BEGIN

  pg_base_curr_code    := arp_global.functional_currency;
  pg_base_precision    := arp_global.base_precision;
  pg_base_min_acc_unit := arp_global.base_min_acc_unit;

END init;

BEGIN
   init;
END ARP_TRX_UTIL;

/
