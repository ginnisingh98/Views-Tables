--------------------------------------------------------
--  DDL for Package Body ARP_TRX_DEFAULTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_TRX_DEFAULTS" AS
/* $Header: ARTUDFLB.pls 120.5 2005/10/30 03:58:39 appldev ship $ */

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
 |    get_header_defaults()                                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Gets the header level default values for a transaction.                |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_batch_source_id                                        |
 |                  p_batch_batch_source_id                                  |
 |                  p_profile_batch_source_id                                |
 |                  p_customer_trx_id                                        |
 |                  p_cust_trx_type_id                                       |
 |                  p_term_id                                                |
 |                  p_com_default_cust_trx_type_id                           |
 |                  p_ctt_class                                              |
 |                  p_trx_date                                               |
 |                  p_trx_number                                             |
 |                  p_row_id                                                 |
 |                  p_invoicing_rule_id                                      |
 |                  p_rev_recog_run_flag                                     |
 |                  p_complete_flag                                          |
 |                  p_open_receivables_flag                                  |
 |                  p_customer_id                                            |
 |                  p_site_use_id                                            |
 |                  p_gl_date                                                |
 |                  p_prev_gl_date                                           |
 |                  p_commit_gl_date                                         |
 |                  p_batch_gl_date                                          |
 |                  p_security_inv_enter_flag                                |
 |                  p_security_cm_enter_flag                                 |
 |                  p_security_dm_enter_flag                                 |
 |                  p_security_commit_enter_flag                             |
 |                                                                           |
 |              OUT:                                                         |
 |                  p_default_batch_source_id                                |
 |                  p_default_batch_source_name                              |
 |                  p_auto_trx_numbering_flag                                |
 |                  p_batch_source_type                                      |
 |		    p_copy_doc_number_flag				     |
 |                  p_bs_default_cust_trx_type_id                            |
 |                  p_default_cust_trx_type_id                               |
 |                  p_default_type_name                                      |
 |                  p_class                                                  |
 |                  p_open_receivable_flag                                   |
 |                  p_post_to_gl_flag                                        |
 |                  p_allow_freight_flag                                     |
 |                  p_creation_sign                                          |
 |                  p_allow_overapplication_flag                             |
 |                  p_natural_app_only_flag                                  |
 |                  p_tax_calculation_flag                                   |
 |                  p_default_status_code                                    |
 |                  p_default_status                                         |
 |                  p_default_printing_option_code                           |
 |                  p_default_printing_option                                |
 |                  p_default_term_id                                        |
 |                  p_default_term_name                                      |
 |                  p_number_of_due_dates                                    |
 |                  p_term_due_date                                          |
 |                  p_default_gl_date                                        |
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

PROCEDURE get_header_defaults(
                                p_batch_source_id                  IN
                                        ra_batch_sources.batch_source_id%type,
                                p_batch_batch_source_id            IN
                                        ra_batch_sources.batch_source_id%type,
                                p_profile_batch_source_id          IN
                                        ra_batch_sources.batch_source_id%type,
                                p_customer_trx_id                  IN
                                      ra_customer_trx.customer_trx_id%type,
                                p_cust_trx_type_id                 IN
                                  ra_cust_trx_types.cust_trx_type_id%type,
                                p_term_id                          IN
                                      ra_terms.term_id%type,
                                p_com_default_cust_trx_type_id     IN
                                  ra_cust_trx_types.cust_trx_type_id%type,
                                p_ctt_class                        IN
                                        ra_cust_trx_types.type%type,
                                p_trx_date                         IN
                                        ra_customer_trx.trx_date%type,
                                p_trx_number                       IN
                                        ra_customer_trx.trx_number%type,
                                p_row_id                           IN varchar2,
                                p_invoicing_rule_id                IN
                                        ra_rules.rule_id%type,
                                p_rev_recog_run_flag               IN varchar2,
                                p_complete_flag                    IN
                                        ra_customer_trx.complete_flag%type,
                                p_open_receivables_flag            IN
                                 ra_cust_trx_types.accounting_affect_flag%type,
                                p_customer_id                      IN
                                        hz_cust_accounts.cust_account_id%type,
                                p_site_use_id                      IN
                                        hz_cust_site_uses.site_use_id%type,
                                p_gl_date                          IN
                                   ra_cust_trx_line_gl_dist.gl_date%type,
                                p_prev_gl_date                     IN
                                   ra_cust_trx_line_gl_dist.gl_date%type,
                                p_commit_gl_date                   IN
                                   ra_cust_trx_line_gl_dist.gl_date%type,
                                p_batch_gl_date                    IN
                                   ra_cust_trx_line_gl_dist.gl_date%type,
                                p_default_batch_source_id         OUT NOCOPY
                                        ra_batch_sources.batch_source_id%type,
                                p_default_batch_source_name       OUT NOCOPY
                                        ra_batch_sources.name%type,
                                p_auto_trx_numbering_flag         OUT NOCOPY
                               ra_batch_sources.auto_trx_numbering_flag%type,
                                p_batch_source_type               OUT NOCOPY
                                      ra_batch_sources.batch_source_type%type,
                                p_copy_doc_number_flag            OUT NOCOPY
                                      ra_batch_sources.copy_doc_number_flag%type,
                                p_bs_default_cust_trx_type_id     OUT NOCOPY
                                      ra_cust_trx_types.cust_trx_type_id%type,
                                p_default_cust_trx_type_id        OUT NOCOPY
                                      ra_cust_trx_types.cust_trx_type_id%type,
                                p_default_type_name               OUT NOCOPY
                                      ra_cust_trx_types.name%type,
                                p_class                           OUT NOCOPY
                                      ra_cust_trx_types.type%type,
                                p_open_receivable_flag            OUT NOCOPY
                                 ra_cust_trx_types.accounting_affect_flag%type,
                                p_post_to_gl_flag                 OUT NOCOPY
                                      ra_cust_trx_types.post_to_gl%type,
                                p_allow_freight_flag              OUT NOCOPY
                                     ra_cust_trx_types.allow_freight_flag%type,
                                p_creation_sign                   OUT NOCOPY
                                     ra_cust_trx_types.creation_sign%type,
                                p_allow_overapplication_flag      OUT NOCOPY
                          ra_cust_trx_types.allow_overapplication_flag%type,
                                p_natural_app_only_flag           OUT NOCOPY
                          ra_cust_trx_types.natural_application_only_flag%type,
                                p_tax_calculation_flag            OUT NOCOPY
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
                                p_default_gl_date                 OUT NOCOPY
                                  ra_cust_trx_line_gl_dist.gl_date%type,
                                p_security_inv_enter_flag         IN
                                  varchar2   DEFAULT 'Y',
                                p_security_cm_enter_flag          IN
                                  varchar2   DEFAULT 'Y',
                                p_security_dm_enter_flag          IN
                                  varchar2   DEFAULT 'Y',
                                p_security_commit_enter_flag      IN
                                  varchar2   DEFAULT 'Y'
          ) IS

     l_batch_source_id               ra_batch_sources.batch_source_id%type;
     l_default_batch_source_name     ra_batch_sources.name%type;
     l_auto_trx_numbering_flag  ra_batch_sources.auto_trx_numbering_flag%type;
     l_batch_source_type             ra_batch_sources.batch_source_type%type;
     l_copy_doc_number_flag 	     ra_batch_sources.copy_doc_number_flag%type;
     l_bs_default_cust_trx_type_id   ra_cust_trx_types.cust_trx_type_id%type;
     l_default_cust_trx_type_id      ra_cust_trx_types.cust_trx_type_id%type;
     l_default_status_code           ar_lookups.lookup_code%type;
     l_default_printing_option_code  ar_lookups.lookup_code%type;
     l_default_term_id               ra_terms.term_id%type;
     l_default_term_name             ra_terms.name%type;
     l_default_class                 ra_cust_trx_types.type%type;
     l_post_to_gl_flag               ra_cust_trx_types.post_to_gl%type;
     l_allow_not_open_flag           varchar2(1);
     l_default_gl_date               ra_cust_trx_line_gl_dist.gl_date%type;
     l_defaulting_rule_used          varchar2(128);
     l_error_message                 varchar2(128);

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_trx_defaults.get_header_defaults()+');
   END IF;


  /*-----------------------------------------------------+
   |  Determine the batch source value or default value  |
   +-----------------------------------------------------*/

   /*4091613*/
   IF p_customer_trx_id is NULL THEN
      IF    ( p_batch_source_id  IS NOT NULL)
      THEN

             arp_trx_defaults_2.get_source_default(
                                 p_batch_source_id,
                                 p_ctt_class,
                                 p_trx_date,
                                 p_trx_number,
                                 l_batch_source_id,
                                 p_default_batch_source_name,
                                 p_auto_trx_numbering_flag,
                                 p_batch_source_type,
				 p_copy_doc_number_flag,
                                 l_bs_default_cust_trx_type_id
                               );

      ELSE
            l_batch_source_id := p_batch_source_id;
      END IF;

      IF     (
               l_batch_source_id        IS NULL
           AND
               p_batch_batch_source_id  IS NOT NULL
          )
      THEN

            -- Try the current batch

            IF ( p_batch_batch_source_id IS NOT NULL )
            THEN

                  arp_trx_defaults_2.get_source_default(
                                      p_batch_batch_source_id,
                                      p_ctt_class,
                                      p_trx_date,
                                      p_trx_number,
                                      l_batch_source_id,
                                      p_default_batch_source_name,
                                      p_auto_trx_numbering_flag,
                                      p_batch_source_type,
				      p_copy_doc_number_flag,
                                      l_bs_default_cust_trx_type_id
                                    );
            END IF;

      END IF;

     -- Try the profile

      IF   (
                   l_batch_source_id          IS NULL
              AND  p_profile_batch_source_id  IS NOT NULL
         )
      THEN

             arp_trx_defaults_2.get_source_default(
                                 p_profile_batch_source_id,
                                 p_ctt_class,
                                 p_trx_date,
                                 p_trx_number,
                                 l_batch_source_id,
                                 p_default_batch_source_name,
                                 p_auto_trx_numbering_flag,
                                 p_batch_source_type,
				 p_copy_doc_number_flag,
                                 l_bs_default_cust_trx_type_id
                               );

      END IF;
   END IF;


      /*-----------------------------------------------------------+
       |  Don't do any more processing if the batch source cannot  |
       |  be determined or defaulted.                              |
       |  Otherwise, get the type default.                         |
       +-----------------------------------------------------------*/

   /*4091613*/
   IF ( l_batch_source_id IS NULL AND p_customer_trx_id IS NULL)
   THEN  RETURN;
   ELSE
        p_default_batch_source_id      := l_batch_source_id;
        p_bs_default_cust_trx_type_id  := l_bs_default_cust_trx_type_id;

        IF ( p_cust_trx_type_id  IS NOT NULL)
        THEN

             arp_trx_defaults_2.get_type_defaults(
                                p_cust_trx_type_id,
                                p_trx_date,
                                p_ctt_class,
                                p_row_id,
                                p_invoicing_rule_id,
                                p_rev_recog_run_flag,
                                p_complete_flag,
                                p_open_receivables_flag,
                                p_customer_trx_id,
                                l_default_cust_trx_type_id,
                                p_default_type_name,
                                l_default_class,
                                p_open_receivable_flag,
                                l_post_to_gl_flag,
                                p_allow_freight_flag,
                                p_creation_sign,
                                p_allow_overapplication_flag,
                                p_natural_app_only_flag,
                                p_tax_calculation_flag,
                                l_default_status_code,
                                p_default_status,
                                l_default_printing_option_code,
                                p_default_printing_option,
                                l_default_term_id,
                                l_default_term_name,
                                p_number_of_due_dates,
                                p_term_due_date,
                                p_security_inv_enter_flag,
                                p_security_cm_enter_flag,
                                p_security_dm_enter_flag,
                                p_security_commit_enter_flag
                              );

        END IF;

        -- Try to default the type from the commitment

        IF (
                l_default_cust_trx_type_id  IS NULL
            AND
                p_com_default_cust_trx_type_id  IS NOT NULL
           )
        THEN

             arp_trx_defaults_2.get_type_defaults(
                                p_com_default_cust_trx_type_id,
                                p_trx_date,
                                p_ctt_class,
                                p_row_id,
                                p_invoicing_rule_id,
                                p_rev_recog_run_flag,
                                p_complete_flag,
                                p_open_receivables_flag,
                                p_customer_trx_id,
                                l_default_cust_trx_type_id,
                                p_default_type_name,
                                l_default_class,
                                p_open_receivable_flag,
                                l_post_to_gl_flag,
                                p_allow_freight_flag,
                                p_creation_sign,
                                p_allow_overapplication_flag,
                                p_natural_app_only_flag,
                                p_tax_calculation_flag,
                                l_default_status_code,
                                p_default_status,
                                l_default_printing_option_code,
                                p_default_printing_option,
                                l_default_term_id ,
                                l_default_term_name,
                                p_number_of_due_dates,
                                p_term_due_date,
                                p_security_inv_enter_flag,
                                p_security_cm_enter_flag,
                                p_security_dm_enter_flag,
                                p_security_commit_enter_flag
                              );

        END IF;

        -- Try to default the type from the batch source

        IF (
                l_default_cust_trx_type_id  IS NULL
            AND
                l_bs_default_cust_trx_type_id  IS NOT NULL
           )
        THEN

             arp_trx_defaults_2.get_type_defaults(
                                l_bs_default_cust_trx_type_id,
                                p_trx_date,
                                p_ctt_class,
                                p_row_id,
                                p_invoicing_rule_id,
                                p_rev_recog_run_flag,
                                p_complete_flag,
                                p_open_receivables_flag,
                                p_customer_trx_id,
                                l_default_cust_trx_type_id,
                                p_default_type_name,
                                l_default_class,
                                p_open_receivable_flag,
                                l_post_to_gl_flag,
                                p_allow_freight_flag,
                                p_creation_sign,
                                p_allow_overapplication_flag,
                                p_natural_app_only_flag,
                                p_tax_calculation_flag,
                                l_default_status_code,
                                p_default_status,
                                l_default_printing_option_code,
                                p_default_printing_option,
                                l_default_term_id,
                                l_default_term_name,
                                p_number_of_due_dates,
                                p_term_due_date,
                                p_security_inv_enter_flag,
                                p_security_cm_enter_flag,
                                p_security_dm_enter_flag,
                                p_security_commit_enter_flag
                              );

        END IF;

        p_default_cust_trx_type_id      := l_default_cust_trx_type_id;
        p_default_status_code           := l_default_status_code;
        p_default_printing_option_code  := l_default_printing_option_code;
        p_default_term_id               := l_default_term_id;
        p_default_term_name             := l_default_term_name;
        p_class                         := l_default_class;
        p_post_to_gl_flag               := l_post_to_gl_flag;

   END IF;

   arp_trx_defaults_3.get_term_default(
                      p_term_id,
                      l_default_term_id,
                      l_default_term_name,
                      p_customer_id,
                      p_site_use_id,
                      p_trx_date,
                      NVL(p_ctt_class, l_default_class),
                      l_default_cust_trx_type_id,
                      p_default_term_id,
                      p_default_term_name,
                      p_number_of_due_dates,
                      p_term_due_date );


  /*-----------------------------------------------------------------+
   |  Default the status to Open if no other default has been found  |
   +-----------------------------------------------------------------*/

   IF ( l_default_status_code  IS NULL)
   THEN

         BEGIN

               SELECT lookup_code,
                      meaning
               INTO   p_default_status_code,
                      p_default_status
               FROM   ar_lookups arl_status
               WHERE  'INVOICE_TRX_STATUS'  = arl_status.lookup_type
               AND    'OP'                  = arl_status.lookup_code
               AND    'Y'                   = arl_status.enabled_flag
               AND    NVL(p_trx_date, TRUNC(SYSDATE))
                      BETWEEN arl_status.start_date_active
                      AND NVL(arl_status.end_date_active,
                              NVL( p_trx_date, TRUNC(SYSDATE) ) );

         EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
            WHEN OTHERS THEN RAISE;

         END;

   END IF;


  /*-------------------------------------------------------------------------+
   | Default the printing option to Print if no other default has been found |
   +-------------------------------------------------------------------------*/

   IF ( l_default_printing_option_code  IS NULL)
   THEN

         BEGIN

               SELECT lookup_code,
                      meaning
               INTO   p_default_printing_option_code,
                      p_default_printing_option
               FROM   ar_lookups arl_print
               WHERE  'INVOICE_PRINT_OPTIONS'  = arl_print.lookup_type
               AND    'PRI'                    = arl_print.lookup_code
               AND    'Y'                      = arl_print.enabled_flag
               AND    NVL(p_trx_date, TRUNC(SYSDATE))
                      BETWEEN arl_print.start_date_active
                      AND NVL(arl_print.end_date_active,
                              NVL( p_trx_date, TRUNC(SYSDATE) ) );

         EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
            WHEN OTHERS THEN RAISE;

         END;

   END IF;

  /*---------------------------+
   |  Get the default gl_date  |
   +---------------------------*/

   IF (l_post_to_gl_flag = 'Y')
   THEN
         IF   (p_invoicing_rule_id = -3)
         THEN  l_allow_not_open_flag := 'Y';
         ELSE  l_allow_not_open_flag := 'N';
         END IF;

         IF (  arp_util.validate_and_default_gl_date(
                                       p_gl_date,
                                       NULL,
                                       p_prev_gl_date,
                                       p_commit_gl_date ,
                                       NULL,
                                       p_batch_gl_date,
                                       p_trx_date,
                                       TRUNC(sysdate),
                                       l_allow_not_open_flag,
                                       TO_CHAR(p_invoicing_rule_id),
                                       pg_set_of_books_id,
                                       222,
                                       l_default_gl_date,
                                       l_defaulting_rule_used,
                                       l_error_message
                                     ) = FALSE )
          THEN
                fnd_message.set_name('AR', 'GENERIC_MESSAGE');
                fnd_message.set_token('GENERIC_TEXT',
                                      l_error_message);
                app_exception.raise_exception;

          ELSE

               IF PG_DEBUG in ('Y', 'C') THEN
                  arp_util.debug('get_header_defaults: ' || 'default GL Date: ' ||
                              to_char(l_default_gl_date) ||
                              '  Rule: ' || l_defaulting_rule_used);
               END IF;

               IF (l_default_gl_date IS NOT NULL)
               THEN
                     p_default_gl_date := l_default_gl_date;
               END IF;
          END IF;

   END IF;

  /*---------------------------------------------------------+
   |  Get the default primary salesperson:                   |
   |  Default from:                                          |
   |   - The salesrep on the customer record                 |
   |   - No Sales Credit (only if salescredits are required) |
   +---------------------------------------------------------*/
/*
   SELECT NVL(s.name,            s1.name),
          NVL(s.salesrep_number, s1.salesrep_number),
          NVL(s.salesrep_id,     s1.salesrep_id)
   INTO   p_primary_salesrep_name,
          p_primary_salesrep_number,
          p_primary_salesrep_id
   FROM   ra_salesreps s,
          ra_salesreps s1,
          hz_cust_accounts cust_acct
   WHERE  cust_acct.primary_salesrep_id = s.salesrep_id(+)
   AND    cust_acct.cust_account_id         = p_customer_id
   AND    DECODE(p_salesrep_required_flag,
                'Y', -3,
                    -100)       = s1.salesrep_id(+)
   AND    p_trx_date BETWEEN
            NVL(s.start_date_active(+), p_trx_date) AND
            NVL(s.end_date_active(+),   p_trx_date)
   AND    p_trx_date BETWEEN
            NVL(s1.start_date_active(+), p_trx_date) AND
            NVL(s1.end_date_active(+),   p_trx_date);
*/

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_trx_defaults.get_header_defaults()-');
   END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION:  arp_trx_defaults.get_header_defaults()');
        END IF;
        RAISE;

END get_header_defaults;


  /*---------------------------------------------+
   |   Package initialization section.           |
   +---------------------------------------------*/

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

END ARP_TRX_DEFAULTS;

/
