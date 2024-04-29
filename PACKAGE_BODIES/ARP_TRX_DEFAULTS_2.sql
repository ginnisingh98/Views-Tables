--------------------------------------------------------
--  DDL for Package Body ARP_TRX_DEFAULTS_2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_TRX_DEFAULTS_2" AS
/* $Header: ARTUDF2B.pls 120.5.12010000.1 2008/07/24 16:57:49 appldev ship $ */

pg_text_dummy   varchar2(10);
pg_flag_dummy   varchar2(10);
pg_number_dummy number;
pg_date_dummy   date;

pg_base_curr_code          gl_sets_of_books.currency_code%type;
pg_base_precision          fnd_currencies.precision%type;
pg_base_min_acc_unit       fnd_currencies.minimum_accountable_unit%type;
pg_set_of_books_id         ar_system_parameters.set_of_books_id%type;



/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_source_default                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Checks a potential batch source default to see if it is valid.         |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_batch_source_id                                        |
 |                  p_ctt_class                                              |
 |                  p_trx_date                                               |
 |                  p_trx_number                                             |
 |              OUT:                                                         |
 |                  p_default_batch_source_id                                |
 |                  p_default_batch_source_name                              |
 |                  p_auto_trx_numbering_flag                                |
 |                  p_batch_source_type                                      |
 |                  p_default_cust_trx_type_id                               |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     04-NOV-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE get_source_default(
                              p_batch_source_id             IN
                                        ra_batch_sources.batch_source_id%type,
                              p_ctt_class                   IN
                                       ra_cust_trx_types.type%type,
                              p_trx_date                    IN
                                        ra_customer_trx.trx_date%type,
                              p_trx_number                  IN
                                        ra_customer_trx.trx_number%type,
                              p_default_batch_source_id    OUT NOCOPY
                                        ra_batch_sources.batch_source_id%type,
                              p_default_batch_source_name  OUT NOCOPY
                                        ra_batch_sources.name%type,
                              p_auto_trx_numbering_flag    OUT NOCOPY
                                ra_batch_sources.auto_trx_numbering_flag%type,
                              p_batch_source_type          OUT NOCOPY
                                       ra_batch_sources.batch_source_type%type,
                              p_copy_doc_number_flag       OUT NOCOPY
                                        ra_batch_sources.copy_doc_number_flag%type,
                              p_default_cust_trx_type_id   OUT NOCOPY
                                        ra_cust_trx_types.cust_trx_type_id%type
                            ) IS


BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_trx_defaults_2.get_source_default()+');
   END IF;


   IF (p_batch_source_id IS NOT NULL)
   THEN

       BEGIN

            SELECT bs.name                     source,
                   bs.batch_source_id          batch_source_id,
                   bs.auto_trx_numbering_flag  auto_trx_numbering_flag,
                   bs.batch_source_type        batch_source_type,
                   bs.default_inv_trx_type     default_inv_trx_type,
		   bs.copy_doc_number_flag     copy_doc_number_flag
            INTO   p_default_batch_source_name,
                   p_default_batch_source_id,
                   p_auto_trx_numbering_flag,
                   p_batch_source_type,
                   p_default_cust_trx_type_id,
		   p_copy_doc_number_flag
            FROM   ra_cust_trx_types ctt,
                   ra_batch_sources bs
            WHERE  bs.batch_source_id      = p_batch_source_id
            AND    bs.default_inv_trx_type = ctt.cust_trx_type_id(+)
            AND    NVL(p_ctt_class, '-99') =
                                              DECODE(p_ctt_class,
                                                     null, '-99',
                                                           ctt.type(+) )
            AND    NVL(p_trx_date,
                       TRUNC(sysdate))
                   BETWEEN NVL(bs.start_date,
                               nvl(p_trx_date, TRUNC(sysdate)))
                       AND NVL(bs.end_date, NVL(p_trx_date, TRUNC(sysdate)))
            AND    NVL(p_trx_date,
                       TRUNC(sysdate))
                   BETWEEN NVL(ctt.start_date(+),
                               NVL(p_trx_date, trunc(sysdate)))
                      AND NVL(ctt.end_date(+), nvl(p_trx_date, trunc(sysdate)))
            AND (
                     bs.batch_source_type  ='INV'
                  OR p_ctt_class           = 'CM'
                )
            /* do not show 'DM Reversal' and 'Chargeback' */
            AND bs.batch_source_id not in (11, 12)
            AND (
                     p_trx_number IS NULL
                 OR bs.auto_trx_numbering_flag = 'N'
                );

            EXCEPTION
                 WHEN NO_DATA_FOUND THEN NULL;
                 WHEN OTHERS THEN RAISE;
            END;

   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_trx_defaults_2.get_source_default()-');
   END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION:  arp_trx_defaults_2.get_source_default()');
        END IF;
        RAISE;

END get_source_default;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_type_defaults                                                      |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validates a potential transaction type default value and returns       |
 |    items that default from the type if the type is valid.                 |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_cust_trx_type_id                                      |
 |                   p_trx_date                                              |
 |                   p_ctt_class                                             |
 |                   p_row_id                                                |
 |                   p_invoicing_rule_id                                     |
 |                   p_rev_recog_run_flag                                    |
 |                   p_complete_flag                                         |
 |                   p_open_receivables_flag                                 |
 |                   p_customer_trx_id                                       |
 |                   p_security_inv_enter_flag                               |
 |                   p_security_cm_enter_flag                                |
 |                   p_security_dm_enter_flag                                |
 |                   p_security_commit_enter_flag                            |
 |              OUT:                                                         |
 |                   p_default_cust_trx_type_id                              |
 |                   p_default_type_name                                     |
 |                   p_default_class                                         |
 |                   p_deflt_open_receivables_flag                           |
 |                   p_default_post_to_gl_flag                               |
 |                   p_default_allow_freight_flag                            |
 |                   p_default_creation_sign                                 |
 |                   p_default_allow_overapp_flag                            |
 |                   p_deflt_natural_app_only_flag                           |
 |                   p_default_tax_calculation_flag                          |
 |                   p_default_status_code                                   |
 |                   p_default_status                                        |
 |                   p_default_printing_option_code                          |
 |                   p_default_printing_option                               |
 |                   p_default_term_id                                       |
 |                   p_default_term_name                                     |
 |                   p_number_of_due_dates                                   |
 |                   p_term_due_date                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     04-NOV-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE get_type_defaults(
                             p_cust_trx_type_id       IN
                                     ra_cust_trx_types.cust_trx_type_id%type,
                             p_trx_date               IN
                                     ra_customer_trx.trx_date%type,
                             p_ctt_class              IN
                                     ra_cust_trx_types.type%type,
                             p_row_id                 IN varchar2,
                             p_invoicing_rule_id      IN ra_rules.rule_id%type,
                             p_rev_recog_run_flag     IN varchar2,
                             p_complete_flag          IN
                                     ra_customer_trx.complete_flag%type,
                             p_open_receivables_flag  IN
                                 ra_cust_trx_types.accounting_affect_flag%type,
                             p_customer_trx_id        IN
                                     ra_customer_trx.customer_trx_id%type,
                             p_default_cust_trx_type_id        OUT NOCOPY
                                     ra_cust_trx_types.cust_trx_type_id%type,
                             p_default_type_name               OUT NOCOPY
                                     ra_cust_trx_types.name%type,
                             p_default_class                   OUT NOCOPY
                                     ra_cust_trx_types.type%type,
                             p_deflt_open_receivables_flag     OUT NOCOPY
                                 ra_cust_trx_types.accounting_affect_flag%type,
                             p_default_post_to_gl_flag         OUT NOCOPY
                                     ra_cust_trx_types.post_to_gl%type,
                             p_default_allow_freight_flag      OUT NOCOPY
                                     ra_cust_trx_types.allow_freight_flag%type,
                             p_default_creation_sign           OUT NOCOPY
                                     ra_cust_trx_types.creation_sign%type,
                             p_default_allow_overapp_flag      OUT NOCOPY
                          ra_cust_trx_types.allow_overapplication_flag%type,
                             p_deflt_natural_app_only_flag   OUT NOCOPY
                          ra_cust_trx_types.natural_application_only_flag%type,
                             p_default_tax_calculation_flag    OUT NOCOPY
                                  ra_cust_trx_types.tax_calculation_flag%type,
                             p_default_status_code             OUT NOCOPY
                                  ar_lookups.lookup_code%type,
                             p_default_status                  OUT NOCOPY
                                  ar_lookups.meaning%type,
                             p_default_printing_option_code    OUT NOCOPY
                                  ar_lookups.lookup_code%type,
                             p_default_printing_option         OUT NOCOPY
                                  ar_lookups.meaning%type,
                             p_default_term_id                 OUT NOCOPY
                                  ra_terms.term_id%type,
                             p_default_term_name               OUT NOCOPY
                                  ra_terms.name%type,
                             p_number_of_due_dates             OUT NOCOPY number,
                             p_term_due_date                   OUT NOCOPY
                                  ra_customer_trx.term_due_date%type,
                             p_security_inv_enter_flag      IN
                                  varchar2   DEFAULT 'Y',
                             p_security_cm_enter_flag       IN
                                  varchar2   DEFAULT 'Y',
                             p_security_dm_enter_flag       IN
                                  varchar2   DEFAULT 'Y',
                             p_security_commit_enter_flag    IN
                                  varchar2   DEFAULT 'Y'
                          ) IS

   l_number_of_due_dates number;
   l_default_term_id     ra_terms.term_id%type;
   l_term_due_date       ra_customer_trx.term_due_date%type;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_trx_defaults_2.get_type_defaults()+');
   END IF;


   IF (p_cust_trx_type_id IS NOT NULL )
   THEN

         SELECT  ctt.cust_trx_type_id          cust_trx_type_id,
                 ctt.name                      name,
                 ctt.type                      class,
                 ctt.accounting_affect_flag    open_receivable_flag,
                 ctt.post_to_gl                post_to_gl_flag,
                 ctt.allow_freight_flag        allow_freight_flag,
                 ctt.creation_sign             creation_sign,
                 allow_overapplication_flag    allow_overapplication_flag,
                 natural_application_only_flag natural_application_only_flag,
                 ctt.tax_calculation_flag     tax_calculation_flag,
                 ctt.default_status            default_status_code,
                 arl_status.meaning            default_status,
                 ctt.default_printing_option   default_printing_option_code,
                 arl_print.meaning             default_printing_option,
                 ctt.default_term              default_term_id,
                 rat.name                      default_term
        INTO
                 p_default_cust_trx_type_id,
                 p_default_type_name,
                 p_default_class,
                 p_deflt_open_receivables_flag,
                 p_default_post_to_gl_flag,
                 p_default_allow_freight_flag,
                 p_default_creation_sign,
                 p_default_allow_overapp_flag,
                 p_deflt_natural_app_only_flag,
                 p_default_tax_calculation_flag,
                 p_default_status_code,
                 p_default_status,
                 p_default_printing_option_code,
                 p_default_printing_option,
                 l_default_term_id,
                 p_default_term_name
         FROM    ar_lookups         arl_print,
                 ar_lookups         arl_status,
                 ra_terms           rat,
                 ra_cust_trx_types  ctt
         WHERE  ctt.cust_trx_type_id          = p_cust_trx_type_id
         AND    'INVOICE_PRINT_OPTIONS'       = arl_print.lookup_type(+)
         AND    ctt.default_printing_option   = arl_print.lookup_code(+)
         AND    'INVOICE_TRX_STATUS'          = arl_status.lookup_type(+)
         AND    ctt.default_status            = arl_status.lookup_code(+)
         AND    ctt.default_term              = rat.term_id(+)
         AND    'Y'                           = arl_print.enabled_flag(+)
         AND    'Y'                           = arl_status.enabled_flag(+)
         AND   -- Check effectivity dates
               NVL(p_trx_date, TRUNC(SYSDATE) )
                  BETWEEN start_date
                      AND NVL(end_date, NVL(p_trx_date, TRUNC(SYSDATE) ) )
         AND   NVL(p_trx_date, TRUNC(SYSDATE))
               BETWEEN rat.start_date_active(+)
               AND NVL(rat.end_date_active(+),
                       NVL( p_trx_date, TRUNC(SYSDATE) ) )
         AND   NVL(p_trx_date, TRUNC(SYSDATE))
               BETWEEN arl_print.start_date_active(+)
               AND NVL(arl_print.end_date_active(+),
                       NVL( p_trx_date, TRUNC(SYSDATE) ) )
         AND   NVL(p_trx_date, TRUNC(SYSDATE))
               BETWEEN arl_status.start_date_active(+)
               AND NVL(arl_status.end_date_active(+),
                       NVL( p_trx_date, TRUNC(SYSDATE) ) )
         AND   -- The transaction must have the same class as is specified
               -- in the form.
               -- However, existing Debit Memos may be converted into Invoices
               -- and Invoices may be converted to Debit Memos
               (
                    NVL(p_ctt_class, ctt.type) = ctt.type
                OR
                    (
                         p_ctt_class IN ('DM', 'INV')
                     AND
                         p_row_id IS NOT NULL
                     AND
                         ctt.type IN ('DM', 'INV')
                    )
               )
         AND  -- Only invoices and credit memos can have rules
               (
                   p_invoicing_rule_id IS NULL
                OR
                   ctt.type IN ('INV', 'CM')
               )
         AND  -- Commitments must be Open Receivable Yes
               (
                  ctt.type NOT IN ('DEP', 'GUAR')
               OR
                  ctt.accounting_affect_flag = 'Y'
               )
         AND   -- Don't allow changes to the Post To GL flag after
               -- the Revenue Recognition Program has been run on
               -- this transaction
               ctt.post_to_gl = DECODE(p_rev_recog_run_flag,
                                       'Y', p_rev_recog_run_flag,
                                            ctt.post_to_gl )
         AND   -- Don't allow changes to the Open Receivables Flag for
               -- complete credit memos
               (
                     p_complete_flag = 'N'
                  OR
                     p_ctt_class    <> 'CM'
                  OR
                     (
                        ctt.accounting_affect_flag = p_open_receivables_flag
                     )
               )
         AND  -- Check allow freight constraint and
              -- prevent transactions with charges from being changed
              -- into transactions that do not allow charges.
             NOT EXISTS  ( SELECT 'violates allow freight'
                           FROM   ra_customer_trx_lines ctl
                           WHERE  ctl.customer_trx_id    = p_customer_trx_id
                           AND    (
                                      (
                                               ctt.allow_freight_flag = 'N'
                                        AND    ctl.line_type        = 'FREIGHT'
                                      )
                                   OR
                                      (
                                           ctl.line_type = 'CHARGES'
                                       AND ctt.type NOT IN ('DM', 'CM')
                                      )
                                  )
                         )
         AND   -- Check creation sign constraint
             NOT EXISTS  (
                           SELECT    'VIOLATES CREATION SIGN'
                           FROM      ra_customer_trx_lines ctl
                           WHERE     ctl.customer_trx_id = p_customer_trx_id
                           GROUP BY  ctt.creation_sign
                           HAVING    DECODE(
                                             SIGN( SUM(ctl.extended_amount) ),
                                             1,  DECODE( ctt.creation_sign,
                                                         'P', 'Y',
                                                         'A', 'Y',
                                                              'N' ),
                                             -1, DECODE( ctt.creation_sign,
                                                        'N', 'Y',
                                                        'A', 'Y',
                                                             'N' ),
                                                 'Y'
                                            ) = 'N'
                           )
         -- Check the functional security rules for transaction entry
         AND (
                 p_security_inv_enter_flag = 'Y'
              OR ctt.type <> 'INV'
             )
         AND (
                 p_security_cm_enter_flag = 'Y'
              OR ctt.type <> 'CM'
             )
         AND (
                 p_security_dm_enter_flag = 'Y'
              OR ctt.type <> 'DM'
             )
         AND (
                 p_security_commit_enter_flag = 'Y'
              OR ctt.type NOT IN ('DEP', 'GUAR')
             );


       /*----------------------------------------+
        |  Get the number of term due dates and  |
        |  Check an additional term constraint   |
        +----------------------------------------*/

        IF  ( l_default_term_id IS NOT NULL )
        THEN

            SELECT COUNT(*),
                   arpt_sql_func_util.get_First_Due_Date(l_default_term_id,
                                                         p_trx_date)
            INTO   l_number_of_due_dates,
                   l_term_due_date
            FROM   ra_terms_lines
            WHERE  term_id = l_default_term_id;

            -- Guarantees cannot have split term terms

            IF (
                       p_ctt_class = 'GUAR'
                  AND  l_number_of_due_dates > 1
               )
            THEN
                  l_default_term_id     := NULL;
                  l_number_of_due_dates := NULL;
            ELSE
                  p_default_term_id     := l_default_term_id;
                  p_number_of_due_dates := l_number_of_due_dates;
                  p_term_due_date       := l_term_due_date;
            END IF;

        END IF;


   END IF;   -- p_cust_trx_type_id IS NOT NULL case


   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_trx_defaults_2.get_type_defaults()-');
   END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION:  arp_trx_defaults_2.get_type_defaults()');
        END IF;
        RAISE;

END get_type_defaults;


  /*---------------------------------------------+
   |   Package initialization section.           |
   +---------------------------------------------*/
PROCEDURE init IS
BEGIN

  pg_text_dummy   := arp_ct_pkg.get_text_dummy;
  pg_flag_dummy   := arp_ct_pkg.get_flag_dummy;
  pg_number_dummy := arp_ct_pkg.get_number_dummy;
  pg_date_dummy   := arp_ct_pkg.get_date_dummy;

  pg_base_curr_code    := arp_global.functional_currency;
  pg_base_precision    := arp_global.base_precision;
  pg_base_min_acc_unit := arp_global.base_min_acc_unit;
  pg_set_of_books_id   :=
          arp_trx_global.system_info.system_parameters.set_of_books_id;
END init;

BEGIN
   init;
END ARP_TRX_DEFAULTS_2;

/
