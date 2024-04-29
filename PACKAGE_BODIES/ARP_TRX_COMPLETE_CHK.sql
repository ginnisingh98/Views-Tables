--------------------------------------------------------
--  DDL for Package Body ARP_TRX_COMPLETE_CHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_TRX_COMPLETE_CHK" AS
/* $Header: ARTUVA2B.pls 120.23.12010000.2 2008/11/04 09:31:03 dgaurab ship $ */


   pg_ai_pds_exist_cursor               integer;
   pg_ai_overlapping_pds_cursor         integer;
   pg_form_pds_exist_cursor             integer;
   pg_form_overlapping_pds_cursor       integer;

   pg_salesrep_required_flag  ar_system_parameters.salesrep_required_flag%type;
   pg_set_of_books_id         ar_system_parameters.set_of_books_id%type;
   pg_base_curr_code          gl_sets_of_books.currency_code%type;
   pg_so_source_code          varchar2(240);
   pg_so_installed_flag       varchar2(1);


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    check_tax_and_accounting()                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Checks if the transaction can be completed.                            |
 |                                                                           |
 |    The following checks are performed:                                    |
 |    - Check the existance and validtity of account assignments or          |
 |      account sets:                                                        |
 |        Constraints:                                                       |
 |          - records exists for each line                                   |
 |          - all code combinations are valid                                |
 |          - For account assignments, the sum of the assignment amounts     |
 |            must equal the line amount.                                    |
 |          - For account sets, the sum of the percents for each line and    |
 |            account class must equal 100%.                                 |
 |    - If TAX_CALCULATION_FLAG is Yes, then tax is required for all invoice |
 |        lines unless it's a memo line not of type LINE.                    |
 |    - Tax is also required if TAX_CALCULATION_FLAG is No and               |
 |      TAX_EXEMPT_FLAG is Require.                                          |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_bal_util.get_commitment_balance                                    |
 |    arp_ct_pkg.fetch_p                                                     |
 |    arp_non_db_pkg.check_creation_sign                                     |
 |    arp_non_db_pkg.check_natural_application                               |
 |    arp_trx_global.profile_info.use_inv_acct_for_cm_flag                   |
 |    arp_trx_util.get_summary_trx_balances                                  |
 |    arp_trx_validate.validate_trx_date                                     |
 |    arp_util.debug                                                         |
 |    arp_util.validate_and_default_gl_date                                  |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                     p_customer_trx_id                                     |
 |                     p_so_source_code                                      |
 |                     p_so_installed_flag                                   |
 |                                                                           |
 |              OUT:                                                         |
 |                     p_error_count                                         |
 |                                                                           |
 | RETURNS    : p_error_count                                                |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     26-JUN-96  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

FUNCTION check_tax_and_accounting(
                                     p_mode                       IN varchar2,
                                     p_customer_trx_id            IN integer,
                                     p_previous_customer_trx_id   IN integer,
                                     p_trx_number                 IN varchar2,
                                     p_class                      IN varchar2,
                                     p_tax_calculation_flag       IN varchar2,
                                     p_invoicing_rule_id          IN integer,
                                     p_error_count            IN OUT NOCOPY integer,
                                     p_error_line_number         OUT NOCOPY integer,
                                     p_error_other_line_number   OUT NOCOPY integer
                                  ) RETURN BOOLEAN IS

    /* 5093094 - removed cursor tax_check */

  CURSOR dist_check IS
   SELECT  ctl.customer_trx_line_id                customer_trx_line_id,
           NVL(ctl_line.line_number,
               ctl.line_number)                    line_number,
           DECODE(ctl_line.customer_trx_line_id,
                  NULL, TO_NUMBER(NULL),
                        ctl.line_number)           other_line_number,
           ctl.extended_amount                     line_amount,
           SUM(lgd.amount)                         dist_amount,
           MAX(lgd.account_class)                  account_class,
           DECODE(p_invoicing_rule_id,
               NULL,
                -- no rules case
                DECODE( MAX(lgd.cust_trx_line_gl_dist_id),
                  NULL, DECODE( ctl.line_type,
                                'LINE',    'AR_TW_NO_LINE_DISTS',
                                'CHARGES', 'AR_TW_NO_CHARGES_DISTS',
                                'TAX',     'AR_TW_NO_TAX_DISTS',
                                'FREIGHT', 'AR_TW_NO_FREIGHT_DISTS',
                                           'AR_TW_NO_REC_DIST'),
                     DECODE( MIN(lgd.code_combination_id),
                             -1,  DECODE( ctl.line_type,
                                          'LINE',    'AR_TW_BAD_LINE_DISTS',
                                          'CHARGES', 'AR_TW_BAD_CHARGES_DISTS',
                                          'TAX',     'AR_TW_BAD_TAX_DISTS',
                                         'FREIGHT',  'AR_TW_BAD_FREIGHT_DISTS',
                                                     'AR_TW_BAD_REC_DIST'),
                                  DECODE( ctl.extended_amount,
                                          SUM(lgd.amount), NULL,
                                          DECODE( ctl.line_type,
                                           'LINE',    'AR_TW_LINE_DIST_AMT',
                                           'CHARGES', 'AR_TW_CHARGES_DIST_AMT',
                                           'TAX',     'AR_TW_TAX_DIST_AMT',
                                           'FREIGHT', 'AR_TW_FREIGHT_DIST_AMT')
                                        )
                           )
                     ),
                 -- rules case
                 DECODE( MAX(lgd.cust_trx_line_gl_dist_id),
                  NULL,
-- Bug 2137682: changed the MAX(lgd.account_class) to MAX(ctl.line_type)
		     DECODE( MAX(ctl.line_type),
                                'REV',      'AR_TW_NO_REVENUE_SETS',
                                'SUSPENSE', 'AR_TW_NO_SUSPENSE_SETS',
                                'UNEARN',   'AR_TW_NO_UNEARN_SETS',
                                'UNBILL',   'AR_TW_NO_UNBILL_SETS',
                                'CHARGES',  'AR_TW_NO_CHARGES_SETS',
                                'TAX',      'AR_TW_NO_TAX_SETS',
                                'FREIGHT',  'AR_TW_NO_FREIGHT_SETS',
                                            'AR_TW_NO_REC_SETS'),
                     DECODE( MIN(lgd.code_combination_id),
                             -1,  DECODE( MAX(lgd.account_class),
                                          'REV',      'AR_TW_BAD_REVENUE_SETS',
                                          'SUSPENSE','AR_TW_BAD_SUSPENSE_SETS',
                                          'UNEARN',   'AR_TW_BAD_UNEARN_SETS',
                                          'UNBILL',   'AR_TW_BAD_UNBILL_SETS',
                                          'CHARGES',  'AR_TW_BAD_CHARGES_SETS',
                                          'TAX',      'AR_TW_BAD_TAX_SETS',
                                          'FREIGHT',  'AR_TW_BAD_FREIGHT_SETS',
                                                      'AR_TW_BAD_REC_SETS'),
                                  DECODE( SUM(lgd.percent),
                                          100, NULL,
                                          DECODE( MAX(lgd.account_class),
                                           'REV',    'AR_TW_REVENUE_SETS_PCT',
                                          'SUSPENSE','AR_TW_SUSPENSE_SETS_PCT',
                                          'UNEARN',  'AR_TW_UNEARN_SETS_PCT',
                                          'UNBILL',  'AR_TW_UNBILL_SETS_PCT',
                                          'CHARGES', 'AR_TW_CHARGES_SETS_PCT',
                                           'TAX',    'AR_TW_TAX_SETS_PCT',
                                           'FREIGHT','AR_TW_FREIGHT_SETS_PCT')
                                        )
                           )
                     )
             )                            message_name
   FROM      ra_customer_trx_lines        ctl_line,
             ra_customer_trx_lines        ctl,
             ra_cust_trx_line_gl_dist     lgd,
             ra_customer_trx              ct
   WHERE     ct.customer_trx_id           = p_customer_trx_id
   AND       ct.customer_trx_id           = ctl.customer_trx_id(+)
   AND       ctl.customer_trx_line_id     = lgd.customer_trx_line_id(+)
   AND       ctl.link_to_cust_trx_line_id = ctl_line.customer_trx_line_id(+)
   AND       DECODE(p_invoicing_rule_id,
                    NULL, 'N',
                          'Y')          = lgd.account_set_flag(+)
   GROUP BY  ctl.customer_trx_line_id,
             ctl.line_number,
             ctl_line.line_number,
             ctl_line.customer_trx_line_id,
             ctl.extended_amount,
             ctl.line_type,
             DECODE(p_invoicing_rule_id,
                    NULL, NULL,
                          lgd.account_class)
   HAVING (
              MAX(lgd.cust_trx_line_gl_dist_id)  IS NULL
           OR
              MIN(lgd.code_combination_id) < 0
           OR (
                      p_invoicing_rule_id  IS NULL
                 AND  ctl.extended_amount <> SUM(lgd.amount)
              )
           OR (
                      (
                           p_invoicing_rule_id  IS NOT NULL
                        OR MAX(lgd.account_class) = 'REC'
                      )
                 AND  SUM(lgd.percent) <> 100
              )
          )
  UNION
  SELECT   -- Receivables case
         TO_NUMBER(NULL),
         TO_NUMBER(NULL),
         TO_NUMBER(NULL),
         TO_NUMBER(NULL),
         lgd.amount,
         'REC',
         DECODE(p_invoicing_rule_id,
                NULL,
                -- no rules case
                     DECODE( lgd.cust_trx_line_gl_dist_id,
                             NULL, 'AR_TW_NO_REC_DISTS',
                                   'AR_TW_BAD_REC_DISTS'),
                      -- rules case
                     DECODE( lgd.cust_trx_line_gl_dist_id,
                             NULL, 'AR_TW_NO_REC_SETS',
                                    'AR_TW_BAD_REC_SETS')
               )                            message_name
  FROM   ra_cust_trx_line_gl_dist lgd
  WHERE  lgd.customer_trx_id  = p_customer_trx_id
  AND    lgd.account_class    = 'REC'
  AND    lgd.latest_rec_flag  = 'Y'
  AND    (
              NVL(lgd.code_combination_id, -1) < 0
           OR lgd.percent <> 100
         )
  ORDER BY 1;

   l_error_mode      	varchar2(15);
   /*
    * arp_process_tax.validate_tax_enforcement() returns the following:
    */
   p_line_number     	NUMBER;
   p_gl_tax_code	zx_rates_b.tax_rate_code%TYPE := NULL;
   p_validation_status	BOOLEAN := TRUE;

   l_error_count        NUMBER;
   l_valid_for_tax      VARCHAR2(1);

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_trx_validate.check_tax_and_accounting()+');
   END IF;


  /*-----------------------------------------------------------------------+
   |  Check account assignments or account sets                            |
   |  Unless the current transaction is a credit memo against a specific   |
   |  transaction with rules and the Use Invoice Accounting flag is Yes.   |
   |  (In that case, the CM will not have any line level account           |
   |   assignments or account sets because it will use the account sets of |
   |   the invoice that it is crediting.)                                  |
   |                                                                       |
   |  Constraints:                                                         |
   |    - records exists for each line                                     |
   |    - all code combinations are valid                                  |
   |    - For account assignments, the sum of the assignment amounts must  |
   |      equal the line amount.                                           |
   |    - For account sets, the sum of the percents for each line and      |
   |      account class must equal 100%.                                   |
   +-----------------------------------------------------------------------*/


   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('check_tax_and_accounting: ' || 'check account assignments and account sets');
   END IF;

	-- Bug 540962: need to compare the 'HANDLER' and 'STANDARD'
	--	       to make sure error is raised when procedure is
        --             called as part of completion checking
	--	       (used to be compared only to 'HANDLER', which
	--	       caused l_error_mode to be NO_EXCEPTION for
   	--	       p_mode=STANDARD

        IF (p_mode IN ('HANDLER', 'STANDARD'))
        THEN
              l_error_mode := 'STANDARD';
        ELSIF (p_mode = 'PL/SQL')
           THEN l_error_mode := 'PL/SQL';
        ELSE
              l_error_mode := 'NO_EXCEPTION';
        END IF;

   IF (
           p_previous_customer_trx_id  IS NULL
       OR  p_invoicing_rule_id         IS NULL
       OR  arp_trx_global.profile_info.use_inv_acct_for_cm_flag = 'N'
      )
   THEN

        BEGIN
              FOR l_error_rec IN dist_check LOOP

                  IF PG_DEBUG in ('Y', 'C') THEN
                     arp_util.debug('check_tax_and_accounting: ' || 'ERROR:  The accounts for line ' ||
                                 TO_CHAR(l_error_rec.line_number) || '-' ||
                                 TO_CHAR(l_error_rec.other_line_number) ||
                                 ' is invalid');
                     arp_util.debug('check_tax_and_accounting: ' || 'line amt:  ' ||
                                 TO_CHAR(l_error_rec.line_amount)  ||
                                 '  dist amt: ' ||
                                 TO_CHAR(l_error_rec.dist_amount)  ||
                                 '  class: ' || l_error_rec.account_class);
                  END IF;


                  arp_trx_validate.add_to_error_list(
                                      l_error_mode,
                                      p_error_count,
                                      p_customer_trx_id,
                                      p_trx_number,
                                      l_error_rec.line_number,
                                      l_error_rec.other_line_number,
                                      l_error_rec.message_name,
                                      NULL,           -- p_error_location,
                                      'LINE_NUMBER',
                                      l_error_rec.line_number,
                                      'OTHER_LINE_NUMBER',
                                      l_error_rec.other_line_number
                                   );

                  IF (p_mode = 'FORM')
                  THEN
                      p_error_line_number := l_error_rec.line_number;
                    p_error_other_line_number := l_error_rec.other_line_number;
                      RETURN(FALSE);
                  END IF;

              END LOOP;

        EXCEPTION
           WHEN NO_DATA_FOUND THEN NULL;
           WHEN OTHERS
                THEN RAISE;
        END;

  END IF;

  /* 5093094 - Removed entire tax validation section based on
     tax_check cursor.  We no longer validate existance of tax
     based on trx_type. */

  /* 4188835 - removed call to arp_process_tax.validate_tax_enforcement
      as this validation is handled automatically by etax call
      to calculate_tax */

  /* 5373072 - Added call to arp_etax_services_pkg.validate_for_tax
      This routine determines if the tax is still active/valid at
      the point of completion.  It uses the error handling from
      arp_trx_validate to log and raise messages based on the p_mode
      parameter */

      arp_etax_services_pkg.validate_for_tax(
           p_customer_trx_id => p_customer_trx_id,
           p_error_mode      => l_error_mode,
           p_valid_for_tax   => l_valid_for_tax,
           p_number_of_errors=> l_error_count);

      p_error_count := p_error_count + l_error_count;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('  num of etax validation errors = ' || l_error_count);
      arp_util.debug('arp_trx_validate.check_tax_and_accounting()-');
   END IF;

   RETURN(TRUE);

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('check_tax_and_accounting: ' ||
                    'EXCEPTION:  arp_trx_validate.check_tax_and_accounting()');
        END IF;
        RAISE;

END check_tax_and_accounting;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    check_tax_and_accounting()                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Checks if the transaction can be completed.                            |
 |                                                                           |
 |    The following checks are performed:                                    |
 |    - Check the existance and validtity of account assignments or          |
 |      account sets:                                                        |
 |        Constraints:                                                       |
 |          - records exists for each line                                   |
 |          - all code combinations are valid                                |
 |          - For account assignments, the sum of the assignment amounts     |
 |            must equal the line amount.                                    |
 |          - For account sets, the sum of the percents for each line and    |
 |            account class must equal 100%.                                 |
 |    - If TAX_CALCULATION_FLAG is Yes, then tax is required for all invoice |
 |        lines unless it's a memo line not of type LINE.                    |
 |    - Tax is also required if TAX_CALCULATION_FLAG is No and               |
 |      TAX_EXEMPT_FLAG is Require.                                          |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_bal_util.get_commitment_balance                                    |
 |    arp_ct_pkg.fetch_p                                                     |
 |    arp_non_db_pkg.check_creation_sign                                     |
 |    arp_non_db_pkg.check_natural_application                               |
 |    arp_trx_global.profile_info.use_inv_acct_for_cm_flag                   |
 |    arp_trx_util.get_summary_trx_balances                                  |
 |    arp_trx_validate.validate_trx_date                                     |
 |    arp_util.debug                                                         |
 |    arp_util.validate_and_default_gl_date                                  |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                     p_customer_trx_id                                     |
 |                     p_so_source_code                                      |
 |                     p_so_installed_flag                                   |
 |                                                                           |
 |              OUT:                                                         |
 |                     p_error_count                                         |
 |                                                                           |
 | RETURNS    : p_error_count                                                |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     26-JUN-96  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

FUNCTION check_tax_and_accounting(
                                     p_query_string               IN varchar2,
                                     p_error_trx_number          OUT NOCOPY varchar2,
                                     p_error_line_number         OUT NOCOPY number,
                                     p_error_other_line_number   OUT NOCOPY number
                                  ) RETURN BOOLEAN IS

   l_cursor                   integer;
   l_error_count              integer;
   l_error_line_number        integer;
   l_error_other_line_number  integer;

   l_customer_trx_id          integer;
   l_previous_customer_trx_id integer;
   l_trx_number               varchar2(20);
   l_invoicing_rule_id        integer;
   l_class                    varchar2(20);
   l_tax_calculation_flag     varchar2(1);
   l_dummy                    integer;
   l_result                   boolean;
   l_sql_statement            varchar2(800);

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_trx_validate.check_tax_and_accounting()+');
   END IF;

   -- Bug 540962: error count variable needs to be initialized

   l_error_count := 0;

   l_cursor := dbms_sql.open_cursor;

   l_sql_statement :=
      'SELECT ct.previous_customer_trx_id previous_customer_trx_id,
              ct.trx_number               trx_number,
              ct.invoicing_rule_id        invoicing_rule_id,
              ctt.type                    class,
              ctt.tax_calculation_flag    tax_calculation_flag,
              ct.customer_trx_id          customer_trx_id
       FROM   ra_customer_trx ct,
              ra_cust_trx_types ctt
       WHERE  ct.cust_trx_type_id = ctt.cust_trx_type_id
       AND    ct.customer_trx_id IN (' || p_query_string || ')';

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('check_tax_and_accounting: ' || 'sql statement: ');
      arp_util.debug('check_tax_and_accounting: ' ||  l_sql_statement );
   END IF;

   dbms_sql.parse(l_cursor,
                  l_sql_statement,
                  dbms_sql.v7);

   dbms_sql.define_column(l_cursor, 1, l_previous_customer_trx_id);
   dbms_sql.define_column(l_cursor, 2, l_trx_number, 20);
   dbms_sql.define_column(l_cursor, 3, l_invoicing_rule_id);
   dbms_sql.define_column(l_cursor, 4, l_class,      20);
   dbms_sql.define_column(l_cursor, 5, l_tax_calculation_flag, 1);
   dbms_sql.define_column(l_cursor, 6, l_customer_trx_id);
   l_dummy := dbms_sql.execute(l_cursor);


   LOOP
        IF (dbms_sql.fetch_rows(l_cursor) > 0)
        THEN

             dbms_sql.column_value(l_cursor, 1, l_previous_customer_trx_id);
             dbms_sql.column_value(l_cursor, 2, l_trx_number);
             dbms_sql.column_value(l_cursor, 3, l_invoicing_rule_id);
             dbms_sql.column_value(l_cursor, 4, l_class);
             dbms_sql.column_value(l_cursor, 5, l_tax_calculation_flag);
             dbms_sql.column_value(l_cursor, 6, l_customer_trx_id);

             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('check_tax_and_accounting: ' || '');
                arp_util.debug('check_tax_and_accounting: ' || 'Checking: ');
                arp_util.debug('check_tax_and_accounting: ' || 'customer_trx_id           = ' ||
                            TO_CHAR(l_customer_trx_id));
                arp_util.debug('check_tax_and_accounting: ' || 'previous_customer_trx_id  = ' ||
                            TO_CHAR(l_previous_customer_trx_id));
                arp_util.debug('check_tax_and_accounting: ' || 'trx_number                = ' ||
                            l_trx_number);
                arp_util.debug('check_tax_and_accounting: ' || 'invoicing_rule_id         = ' ||
                            TO_CHAR(l_invoicing_rule_id));
                arp_util.debug('check_tax_and_accounting: ' || 'class                     = ' ||
                            l_class);
                arp_util.debug('check_tax_and_accounting: ' || 'tax_calculation_flag      = ' ||
                            l_tax_calculation_flag);
             END IF;

             IF ( check_tax_and_accounting(
                                            'FORM',
                                            l_customer_trx_id,
                                            l_previous_customer_trx_id,
                                            l_trx_number,
                                            l_class,
                                            l_tax_calculation_flag,
                                            l_invoicing_rule_id,
                                            l_error_count,
                                            l_error_line_number,
                                            l_error_other_line_number
                                          ) = FALSE )
             THEN
                    p_error_trx_number        := l_trx_number;
                    p_error_line_number       := l_error_line_number;
                    p_error_other_line_number := l_error_other_line_number;

                    IF PG_DEBUG in ('Y', 'C') THEN
                       arp_util.debug('check_tax_and_accounting: ' || 'Setting error out NOCOPY parameters to: ');
                       arp_util.debug('check_tax_and_accounting: ' || 'p_error_trx_number          = ' ||
                                   l_trx_number);
                       arp_util.debug('check_tax_and_accounting: ' || 'p_error_line_number         = ' ||
                                   l_error_line_number);
                       arp_util.debug('check_tax_and_accounting: ' || 'p_error_other_line_number   = ' ||
                                   l_error_other_line_number);
                    END IF;

                    dbms_sql.close_cursor(l_cursor);

                    IF PG_DEBUG in ('Y', 'C') THEN
                       arp_util.debug('check_tax_and_accounting: ' || 'returning FALSE');
                       arp_util.debug('check_tax_and_accounting: ' ||
                              'arp_trx_validate.check_tax_and_accounting()-');
                    END IF;

                    RETURN(FALSE);
             END IF;

        ELSE
               EXIT;
        END IF;
   END LOOP;

   dbms_sql.close_cursor(l_cursor);

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('check_tax_and_accounting: ' || 'returning TRUE');
      arp_util.debug('arp_trx_validate.check_tax_and_accounting()-');
   END IF;

   RETURN(TRUE);

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('check_tax_and_accounting: ' ||
                    'EXCEPTION:  arp_trx_validate.check_tax_and_accounting()');
           arp_util.debug('======= parameters for check_tax_and_accounting: ' ||
                       '=======');
           arp_util.debug('check_tax_and_accounting: ' || 'p_query_string  = ' || p_query_string  );
        END IF;
        IF (dbms_sql.is_open(l_cursor))
        THEN   dbms_sql.close_cursor(l_cursor);
        END IF;

        RAISE;

END check_tax_and_accounting;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    do_completion_checking()                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Checks if the transaction can be completed.                            |
 |                                                                           |
 |    The following checks are performed:                                    |
 |    - Insure that at least one line or freight line exists.                |
 |    - Insure that all entities that have start / end dates  are valid for  |
 |        the specified trx date.                                            |
 |    - Insure that if a commitment has been specified, it is valid   with   |
 |        the transaction's trx_date and gl_date                             |
 |    - If salescredits are required, the total salescredits for each line   |
 |        must equal 100% of the line amount.                                |
 |    - If salescredits are not required, either no salescredits exist for   |
 |        a line or they sum to 100%.                                        |
 |    - Check the existance and validtity of account assignments or          |
 |      account sets:                                                        |
 |        Constraints:                                                       |
 |          - records exists for each line                                   |
 |          - all code combinations are valid                                |
 |          - For account assignments, the sum of the assignment amounts     |
 |            must equal the line amount.                                    |
 |          - For account sets, the sum of the percents for each line and    |
 |            account class must equal 100%.                                 |
 |    - If an invoicing rule has been specified, verify that all lines       |
 |        have accounting rules and rule start dates.                        |
 |    - If TAX_CALCULATION_FLAG is Yes, then tax is required for all invoice |
 |        lines unless it's a memo line not of type LINE.                    |
 |    - Tax is also required if TAX_CALCULATION_FLAG is No and               |
 |      TAX_EXEMPT_FLAG is Require.                                          |
 |    - Check the creation sign of the transaction                           |
 |    - Verify that the GL Date is in an Opened, Future or                   |
 |         Never Opened (Arrears only) Period.                               |
 |                                                                           |
 |    The following validations only apply to credit memos against           |
 |    transactions.                                                          |
 |                                                                           |
 |    - Check for illegal overapplications.                                  |
 |    - The GL Date must be >= the credited transaction's GL Date.           |
 |    - There can be no later credit memos applied to the same transaction.  |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_bal_util.get_commitment_balance                                    |
 |    arp_ct_pkg.fetch_p                                                     |
 |    arp_non_db_pkg.check_creation_sign                                     |
 |    arp_non_db_pkg.check_natural_application                               |
 |    arp_trx_global.profile_info.use_inv_acct_for_cm_flag                   |
 |    arp_trx_util.get_summary_trx_balances                                  |
 |    arp_trx_validate.validate_trx_date                                     |
 |    arp_util.debug                                                         |
 |    arp_util.validate_and_default_gl_date                                  |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                     p_customer_trx_id                                     |
 |                     p_so_source_code                                      |
 |                     p_so_installed_flag                                   |
 |                                                                           |
 |              OUT:                                                         |
 |                     p_error_count                                         |
 |                                                                           |
 | RETURNS    : p_error_count                                                |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-DEC-95  Charlie Tomberg     Created                                |
 |                                                                           |
 |     01-FEB-02  Michael Raymond     Bug 2164863 - Added parameter with
 |                                    default value to do_completion_checking.
 |                                    The parameter, 'p_check_tax_acct' is
 |                                    used to conditionally execute the
 |                                    check_tax_and_accounting procedure.
 |                                    Values:
 |                                      'Y' - Execute tax/acct validation only
 |                                      'N' - Execute all other validations
 |                                      'B' - Execute all validations (Y + N)
 |      13-MAr-2003 B chatterjee       Bug 2836430 - modified salesrep_check cursor
 |                                     to compare %'s of round (SUM , 4)
 |	18-DEC-2003 Srivasud		Added a procedure dm_reversal_amount_chk
 |					to check whether the amount of Debit memo
 |				        is greater than original debit memo amount
 +===========================================================================*/

PROCEDURE do_completion_checking(
                                  p_customer_trx_id       IN
                                          ra_customer_trx.customer_trx_id%type,
                                  p_so_source_code        IN varchar2,
                                  p_so_installed_flag     IN varchar2,
                                  p_error_count          OUT NOCOPY number
                                ) IS
BEGIN

     do_completion_checking(
                             p_customer_trx_id,
                             p_so_source_code,
                             p_so_installed_flag,
                             'STANDARD',
                             p_error_count,
                             'B' -- 2164863
                           );



END;

PROCEDURE do_completion_checking(
                                  p_customer_trx_id       IN
                                          ra_customer_trx.customer_trx_id%type,
                                  p_so_source_code        IN varchar2,
                                  p_so_installed_flag     IN varchar2,
                                  p_error_mode            IN VARCHAR2,
                                  p_error_count          OUT NOCOPY number,
                                  p_check_tax_acct        IN VARCHAR2 DEFAULT 'B'
                                ) IS


   l_trx_rec                 ra_customer_trx%rowtype;
   l_prev_trx_rec            ra_customer_trx%rowtype;
   l_commit_trx_rec          ra_customer_trx%rowtype;

   l_class                   ra_cust_trx_types.type%type;
   l_credited_class          ra_cust_trx_types.type%type;
   l_creation_sign           ra_cust_trx_types.creation_sign%type;
   l_allow_overapplication_flag
                             ra_cust_trx_types.allow_overapplication_flag%type;
   l_natural_app_only_flag
                          ra_cust_trx_types.natural_application_only_flag%type;

   l_open_receivables_flag   ra_cust_trx_types.accounting_affect_flag%type;
   l_tax_calculation_flag    ra_cust_trx_types.tax_calculation_flag%type;


   l_trx_gl_date             ra_cust_trx_line_gl_dist.gl_date%type;
   l_commit_gl_date          ra_cust_trx_line_gl_dist.gl_date%type;
   l_prev_gl_date            ra_cust_trx_line_gl_dist.gl_date%type;
   l_default_gl_date         ra_cust_trx_line_gl_dist.gl_date%type;

   l_commit_amount           number;
   l_trx_amount              number;
   l_commitment_balance      number;
   l_line_amount             number;
   l_tax_amount              number;
   l_freight_amount          number;
   l_prev_line_original      number;
   l_prev_line_remaining     number;
   l_prev_tax_original       number;
   l_prev_tax_remaining      number;
   l_prev_freight_original   number;
   l_prev_freight_remaining  number;
   l_prev_charges_original   number;
   l_prev_charges_remaining  number;
   l_prev_total_original     number;
   l_prev_total_remaining    number;

   l_dummy                   varchar2(128);
   l_dummy_date              date;
   l_dummy_flag              boolean;
   l_dummy_number            number;
   l_result                  number;
   l_result_flag             boolean;
   l_error_message           VARCHAR2(30);
   l_error_count             integer;
   l_so_source_code          varchar2(240);
   l_so_installed_flag       varchar2(1);
   l_rule_flag               varchar2(1):='N';

   /* Bug 882789 */
   l_commit_adj_amount       number;
   /* Bug 2534132 */
   l_commit_line_amount        NUMBER;
   l_commit_tax_amount         NUMBER;
   l_commit_frt_amount         NUMBER;

--Bug Fix: 3261620 Begin#1
   l_gl_account_ccid	     ra_cust_trx_line_gl_dist.code_combination_id%type;
   l_dist_gl_date            DATE;
--Bug Fix: 3261620 End#1
 /* Bug fix 5444418 */
   l_account_class           ra_cust_trx_line_gl_dist.account_class%TYPE;
   l_account_set_flag        ra_cust_trx_line_gl_dist.account_set_flag%TYPE;
   l_revrec_complete         varchar2(1);
/*bug 2836430*/
   CURSOR salesrep_check IS
          SELECT    l.line_number                line_number,
                    l.customer_trx_line_id       customer_trx_line_id,
                    round(SUM(s.revenue_percent_split),4) error_amount
          FROM      ra_customer_trx_lines      l,
                    ra_cust_trx_line_salesreps s
          WHERE     pg_salesrep_required_flag  = 'Y'
          AND       l.customer_trx_id          = p_customer_trx_id
          AND       l.customer_trx_line_id     = s.customer_trx_line_id(+)
          AND       l.line_type                = 'LINE'
          GROUP BY  l.line_number,
                    l.customer_trx_line_id
          HAVING    round(SUM(NVL(s.revenue_percent_split, 0)),4) <> 100
      UNION
          SELECT    l.line_number                line_number,
                    l.customer_trx_line_id       customer_trx_line_id,
                    round(SUM(s.revenue_percent_split),4) error_amount
          FROM      ra_customer_trx_lines      l,
                    ra_cust_trx_line_salesreps s
          WHERE     pg_salesrep_required_flag   = 'N'
          AND       l.customer_trx_id           = p_customer_trx_id
          AND       l.customer_trx_line_id      = s.customer_trx_line_id
          AND       l.line_type                 = 'LINE'
          GROUP BY  l.line_number,
                    l.customer_trx_line_id
          HAVING    round(SUM(NVL(s.revenue_percent_split, 0)),4) <> 100
          AND       SUM(s.revenue_percent_split) IS NOT NULL
          ORDER BY  1,3,2;

   CURSOR rule_check IS
          SELECT    l.line_number line_number
          FROM      ra_customer_trx_lines l
          WHERE     l.customer_trx_id = p_customer_trx_id
          AND       (
                         l.accounting_rule_id  IS NULL
                      OR
                         l.rule_start_date     IS NULL
                    )
          AND       l.line_type = 'LINE'
          ORDER BY  l.line_number;

--Bug Fix: 3261620 Begin#2
   CURSOR gl_account_ccid_cur IS
   /* modified bug5444418*/
          SELECT  DISTINCT  code_combination_id ,     gl_date, account_class,
                            account_set_flag
          FROM              ra_cust_trx_line_gl_dist
          WHERE             customer_trx_id           = p_customer_trx_id;
--Bug Fix: 3261620 End#2

/* Bug3185358 */
l_status	VARCHAR2(1);
BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_trx_completion_chk.do_completion_checking()+');
      arp_util.debug('   p_check_tax_acct = ' || p_check_tax_acct);
   END IF;
   -- Bug 540962: l_error_count variable needs to be initialized.

   p_error_count := 0;
   l_error_count := 0;

 /*-------------------------------------------------+
  |  Get information about the current transaction  |
  +-------------------------------------------------*/

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Get information about the transaction');
   END IF;

   arp_ct_pkg.fetch_p(l_trx_rec,
                      p_customer_trx_id);


   /* Bug 3185358 Additional check added to check whether
      debit memo amount is lesser than original receipt amount .
      This is applicable only for DM Reversals */

   IF l_trx_rec.reversed_cash_receipt_id IS NOT NULL THEN
	dm_reversal_amount_chk(l_trx_rec.customer_trx_id,l_trx_rec.reversed_cash_receipt_id,l_status);
	IF l_status='E' THEN
           arp_trx_validate.add_to_error_list(
                              p_error_mode,
                              l_error_count,
                              l_trx_rec.customer_trx_id,
                              l_trx_rec.trx_number,
                              NULL,  -- line_number
                              NULL,  -- other_line_number
                              'AR_DEBIT_REVERSAL_AMOUNT',
                              NULL,  -- p_error_location,
                              NULL,  -- token name 1
                              NULL,  -- token 1
                              NULL,  -- token name 2
                              NULL   -- token 2
                           );
	END IF;
  END IF;
  /* End of Bug 3185358 */


   SELECT type,
          creation_sign,
          tax_calculation_flag
   INTO   l_class,
          l_creation_sign,
          l_tax_calculation_flag
   FROM   ra_cust_trx_types
   WHERE  cust_trx_type_id = l_trx_rec.cust_trx_type_id;

   SELECT lgd_trx.gl_date,
          lgd_trx.amount
   INTO   l_trx_gl_date,
          l_trx_amount
   FROM   ra_cust_trx_line_gl_dist lgd_trx
   WHERE  lgd_trx.customer_trx_id = l_trx_rec.customer_trx_id
   AND    lgd_trx.latest_rec_flag = 'Y'
   AND    lgd_trx.account_class   = 'REC';

   /* Bug 2164863 - We now conditionally execute the check_tax_and_accounting
      routine based on the value of p_check_tax_acct parameter.
       Y - Execute only check_tax_and_accounting
       N - Execute all other validations (except tax/acct)
       B - Execute all validations (Y + N) */

   IF (p_check_tax_acct = 'N' OR p_check_tax_acct = 'B')
   THEN

  /*-------------------------------------------------------------------+
   |  Get information about the transaction's commitment if one exists |
   +-------------------------------------------------------------------*/

   IF ( l_trx_rec.initial_customer_trx_id IS NOT NULL )
   THEN

         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('Get information about the commitment');
         END IF;

         arp_ct_pkg.fetch_p(l_commit_trx_rec,
                            l_trx_rec.initial_customer_trx_id);

         SELECT lgd_trx.gl_date,
                lgd_trx.amount
         INTO   l_commit_gl_date,
                l_commit_amount
         FROM   ra_cust_trx_line_gl_dist lgd_trx
         WHERE  lgd_trx.customer_trx_id = l_trx_rec.initial_customer_trx_id
         AND    lgd_trx.latest_rec_flag = 'Y'
         AND    lgd_trx.account_class   = 'REC';

   END IF;

    /*------------------------------------------------*
     | validate that the transaction number is unique |
     *------------------------------------------------*/

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('Insure that the transaction number is unique.');
     END IF;

     BEGIN
          arp_trx_validate.validate_trx_number( l_trx_rec.batch_source_id,
                                                l_trx_rec.trx_number,
                                                l_trx_rec.customer_trx_id);

     EXCEPTION
       WHEN OTHERS THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('ERROR: transaction number uniqueness check failed');
          END IF;

          arp_trx_validate.add_to_error_list(
                              p_error_mode,
                              l_error_count,
                              l_trx_rec.customer_trx_id,
                              l_trx_rec.trx_number,
                              NULL,  -- line_number
                              NULL,  -- other_line_number
                              'AR_TW_INVALID_TRX_NUMBER',
                              NULL,  -- p_error_location,
                              NULL,  -- token name 1
                              NULL,  -- token 1
                              NULL,  -- token name 2
                              NULL   -- token 2
                           );

     END;

    /*---------------------------------------------*
     | validate that the document number is unique |
     *---------------------------------------------*/

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('Insure that the document number is unique.');
     END IF;

     /* 4537055 - Corrected this validation to use validate_doc_number.
         it was using validate_trx_number (typo) before.  Also exception
         block was coded to raise another exception */

     BEGIN
          arp_trx_validate.validate_doc_number( l_trx_rec.batch_source_id,
                                                l_trx_rec.doc_sequence_value,
                                                l_trx_rec.customer_trx_id);

     EXCEPTION
       WHEN OTHERS THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('ERROR: document number uniqueness check failed');
          END IF;

          arp_trx_validate.add_to_error_list(
                              p_error_mode,
                              l_error_count,
                              l_trx_rec.customer_trx_id,
                              l_trx_rec.trx_number,
                              NULL,  -- line_number
                              NULL,  -- other_line_number
                              'UNIQUE-DUPLICATE SEQUENCE',
                              NULL,  -- p_error_location,
                              NULL,  -- token name 1
                              NULL,  -- token 1
                              NULL,  -- token name 2
                              NULL   -- token 2
                           );

     END;

  /*---------------------------------------------------------+
   |  Insure that at least one line or freight line exists.  |
   +---------------------------------------------------------*/

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Insure that at least one line or freight line exists.');
   END IF;

   SELECT COUNT(*)
   INTO   l_result
   FROM   ra_customer_trx_lines
   WHERE  customer_trx_id = p_customer_trx_id;

   IF (l_result < 1)
   THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('ERROR: line existance validation failed');
          END IF;

          arp_trx_validate.add_to_error_list(
                              p_error_mode,
                              l_error_count,
                              l_trx_rec.customer_trx_id,
                              l_trx_rec.trx_number,
                              NULL,  -- line_number
                              NULL,  -- other_line_number
                              'AR_TW_NO_LINES',
                              NULL,  -- p_error_location,
                              NULL,  -- token name 1
                              NULL,  -- token 1
                              NULL,  -- token name 2
                              NULL   -- token 2
                           );

   END IF;

  --Bug 2141727 fix begins
  --Bug 4188835 - refit for eTax
  /*--------------------------------------------------------+
   |  Insure that if Tax is calculated after discount then  |
   |  Payment term should be such that the discount is      |
   |  calculated based on Invoice Line amounts only.        |
   +--------------------------------------------------------*/
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Insure that Payment term and Tax code do not conflict');
   END IF;

   SELECT count(*)
   INTO   l_result
   FROM   ra_terms tm,
          ra_customer_trx_lines cl,
          ra_customer_trx cs,
          zx_lines zl,
          zx_formula_b zf
   WHERE  cs.customer_trx_id = p_customer_trx_id
   AND    cs.term_id = tm.term_id
   AND    tm.calc_discount_on_lines_flag <> 'L'
   AND    cl.customer_trx_id = cs.customer_trx_id
   AND    cl.line_type = 'TAX'
   AND    cl.tax_line_id = zl.tax_line_id
   AND    zl.taxable_basis_formula = zf.formula_code
   AND    zl.tax_determine_date between zf.effective_from and nvl(zf.effective_to, zl.trx_date)
   AND    zf.formula_type_code = 'TAXABLE_BASIS'
   AND    zf.cash_discount_appl_flag = 'Y';

   IF (l_result  > 0)
   THEN
 	IF PG_DEBUG in ('Y', 'C') THEN
 	   arp_util.debug('ERROR: Tax and payment term conflict exist');
 	END IF;
   	arp_trx_validate.add_to_error_list(
			    p_error_mode,
			    l_error_count,
			    l_trx_rec.customer_trx_id,
			    l_trx_rec.trx_number,
			    NULL,  -- line_number
			    NULL,  -- other_line_number
			    'AR_TERM_TAX_CONFLICT',
			    'TGW_HEADER.RAT_TERM_NAME_MIR',  -- p_error_location,
			    NULL,  -- token name 1
			    NULL,  -- token 1
		            NULL   -- token 2
		          );
   END IF;
  --Bug 2141727 fix ends.


  /*--------------------------------------------------------+
   |  Insure that all entities that have start / end dates  |
   |  are valid for the specified trx date.                 |
   +--------------------------------------------------------*/

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Check date ranges');
   END IF;

   arp_trx_validate.validate_trx_date(
                   p_error_mode,
                   l_trx_rec.trx_date,
                   l_prev_trx_rec.trx_date,
                   l_commit_trx_rec.trx_date,
                   l_trx_rec.customer_trx_id,
                   l_trx_rec.trx_number,
                   l_trx_rec.previous_customer_trx_id,
                   l_trx_rec.initial_customer_trx_id,
                   l_trx_rec.agreement_id,
                   l_trx_rec.batch_source_id,
                   l_trx_rec.cust_trx_type_id,
                   l_trx_rec.term_id,
                   l_trx_rec.ship_via,
                   l_trx_rec.primary_salesrep_id,
                   l_trx_rec.reason_code,
                   l_trx_rec.status_trx,
                   l_trx_rec.invoice_currency_code,
                   l_trx_rec.receipt_method_id,
                   l_trx_rec.customer_bank_account_id,
                   l_dummy_date,
                   l_result_flag,
                   l_dummy_flag,
                   l_dummy_flag,
                   l_dummy_flag,
                   l_dummy_flag,
                   l_dummy_flag,
                   l_dummy_flag,
                   l_dummy_flag,
                   l_dummy_flag,
                   l_dummy_flag,
                   l_dummy_flag,
                   l_dummy_flag,
                   l_dummy_flag,
                   l_dummy_flag,
                   l_dummy_flag,
                   l_dummy_flag,
                   l_dummy_flag,
                   l_dummy_flag,
                   l_dummy_flag,
                   l_error_count
                );

   IF    (l_result_flag = FALSE)
   THEN

          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug(  'ERROR: date range validation failed');
          END IF;
          app_exception.raise_exception;

   END IF;


  /*--------------------------------------------------------------+
   |  Insure that the exchange rate fields are filled in if the   |
   |  transaction is in a foreign currency.                       |
   +--------------------------------------------------------------*/

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Insure that the exchange rate fields are filled in');
   END IF;

   IF    ( l_trx_rec.invoice_currency_code <> arp_global.functional_currency )
   THEN
         IF ( l_trx_rec.exchange_rate IS NULL )
         THEN

               IF PG_DEBUG in ('Y', 'C') THEN
                  arp_util.debug(  'ERROR: exchange rate is null');
               END IF;

               arp_trx_validate.add_to_error_list(
                                   p_error_mode,
                                   l_error_count,
                                   l_trx_rec.customer_trx_id,
                                   l_trx_rec.trx_number,
                                   NULL,  -- line_number
                                   NULL,  -- other_line_number
                                   'AR_TW_NULL_EXCHANGE_RATE',
                                   'TGW_HEADER.EXCHANGE_RATE',
                                                          -- p_error_location,
                                   NULL,  -- token name 1
                                   NULL,  -- token 1
                                   NULL,  -- token name 2
                                   NULL   -- token 2
                                );
         END IF;

         IF ( l_trx_rec.exchange_rate_type IS NULL )
         THEN

               IF PG_DEBUG in ('Y', 'C') THEN
                  arp_util.debug(  'ERROR: exchange rate type is null');
               END IF;

               arp_trx_validate.add_to_error_list(
                                   p_error_mode,
                                   l_error_count,
                                   l_trx_rec.customer_trx_id,
                                   l_trx_rec.trx_number,
                                   NULL,  -- line_number
                                   NULL,  -- other_line_number
                                   'AR_TW_NULL_EXCHANGE_RATE_TYPE',
                                   'TGW_HEADER.EXCHANGE_RATE_TYPE',
                                                          -- p_error_location,
                                   NULL,  -- token name 1
                                   NULL,  -- token 1
                                   NULL,  -- token name 2
                                   NULL   -- token 2
                                );
         END IF;

         IF ( l_trx_rec.exchange_date IS NULL )
         THEN

               IF PG_DEBUG in ('Y', 'C') THEN
                  arp_util.debug(  'ERROR: exchange rate date is null');
               END IF;

               arp_trx_validate.add_to_error_list(
                                   p_error_mode,
                                   l_error_count,
                                   l_trx_rec.customer_trx_id,
                                   l_trx_rec.trx_number,
                                   NULL,  -- line_number
                                   NULL,  -- other_line_number
                                   'AR_TW_NULL_EXCHANGE_DATE',
                                   'TGW_HEADER.EXCHANGE_DATE',
                                                          -- p_error_location,
                                   NULL,  -- token name 1
                                   NULL,  -- token 1
                                   NULL,  -- token name 2
                                   NULL   -- token 2
                                );
         END IF;


   END IF;

  /*----------------------------------------------------------------+
   |  Insure that if a commitment has been specified, it is valid   |
   |  with the transaction's trx_date and gl_date                   |
   +----------------------------------------------------------------*/

  /*----------------------------------------------------------+
   |  The transaction's trx_date must be in the commitment's  |
   |  start / end date range.                                 |
   +----------------------------------------------------------*/

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'Check the dates of the transaction''s commitment');
   END IF;

   IF ( l_trx_rec.initial_customer_trx_id IS NOT NULL )
   THEN


         IF (
              l_trx_rec.trx_date  NOT BETWEEN
                                   NVL( l_commit_trx_rec.start_date_commitment,
                                          l_trx_rec.trx_date)
                                  AND
                                     NVL( l_commit_trx_rec.end_date_commitment,
                                          l_trx_rec.trx_date)
            )
         THEN
                     IF PG_DEBUG in ('Y', 'C') THEN
                        arp_util.debug(
                        'ERROR: commitment dates do not include the trx_date');
                     END IF;

                     arp_trx_validate.add_to_error_list(
                                         p_error_mode,
                                         l_error_count,
                                         l_trx_rec.customer_trx_id,
                                         l_trx_rec.trx_number,
                                         NULL,  -- line_number
                                         NULL,  -- other_line_number
                                         'AR_TW_BAD_COMMITMT_DATE_RANGE',
                                         'TGW_HEADER.EXCHANGE_DATE',
                                         'START_DATE',
                               TO_CHAR(l_commit_trx_rec.start_date_commitment),
                                         'END_DATE',
                               TO_CHAR(l_commit_trx_rec.end_date_commitment)
                                      );

         END IF;


        /*-----------------------------------------------------+
         |  The transaction's GL Date must be on or after the  |
         |  commitment's GL Date.                              |
         +-----------------------------------------------------*/


         IF   (
                l_commit_gl_date >  l_trx_gl_date
              )
         THEN

              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug(  'ERROR: The transaction''s GL date is before '||
                             'the commitment''s GL date');
              END IF;

              arp_trx_validate.add_to_error_list(
                                 p_error_mode,
                                 l_error_count,
                                 l_trx_rec.customer_trx_id,
                                 l_trx_rec.trx_number,
                                 NULL,  -- line_number
                                 NULL,  -- other_line_number
                                 'AR_TW_GL_DATE_BEFORE_COMMIT_GL',
                                 'TGW_HEADER.CT_COMMITMENT_NUMBER',
                                                        -- p_error_location,
                                 NULL,
                                 NULL,
                                 'GL_DATE',
                                 TO_CHAR(l_commit_gl_date)
                              );

         END IF;

   END IF;


  /*---------------------------------------------------------------------+
   |  If salescredits are required, the total salescredits for each line |
   |     must equal 100% of the line amount.                             |
   |  If salescredits are not required, either no salescredits exist for |
   |     a line or they sum to 100%.                                     |
   +---------------------------------------------------------------------*/

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'Check salescredits');
   END IF;

   BEGIN
         FOR l_error_rec IN salesrep_check LOOP

             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug(  'ERROR:  salescredits for line ' ||
                            TO_CHAR(l_error_rec.line_number) ||
                            ' are invalid');
             END IF;

     /* Bug 2215439 - call to public sector API for industry specific message */
             arp_trx_validate.add_to_error_list(
                                 p_error_mode,
                                 l_error_count,
                                 l_trx_rec.customer_trx_id,
                                 l_trx_rec.trx_number,
                                 l_error_rec.line_number,
                                 NULL,  -- other_line_number
                                 gl_public_sector.get_message_name
                                      (p_message_name =>
                                             'AR_TW_SALESCREDITS_INCOMPLT',
                                       p_app_short_name => 'AR'),
                                 NULL,                   -- p_error_location,
                                 'LINE_NUMBER',
                                 l_error_rec.line_number,
                                 'ERROR_AMOUNT',
                                 l_error_rec.error_amount
                              );

         END LOOP;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
      WHEN OTHERS
           THEN RAISE;
   END;

     /* Bug 2164863 - Only call check_tax_and_accounting here
        if all validations (B) specified */
     IF (p_check_tax_acct = 'B')
     THEN
         l_dummy_flag := check_tax_and_accounting(
                                            p_error_mode,
                                            p_customer_trx_id,
                                            l_trx_rec.previous_customer_trx_id,
                                            l_trx_rec.trx_number,
                                            l_class,
                                            l_tax_calculation_flag,
                                            l_trx_rec.invoicing_rule_id,
                                            l_error_count,
                                            l_dummy_number,
                                            l_dummy_number);
     END IF;

  /*---------------------------------------------------------------------+
   |  If an invoicing rule has been specified,                           |
   |  verify that all lines have accounting rules and rule start dates.  |
   +---------------------------------------------------------------------*/

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'check that all lines have rule information if rules are '||
                   'being used');
   END IF;

   IF ( l_trx_rec.invoicing_rule_id  IS NOT NULL )
   THEN

         /* Its a Release 9 Invoice i.e l_rule_flag ='N', don't do checking * /

        /* Modified For Bug 461391 */
        SELECT decode( max(d.customer_trx_id),
                           null, 'N',
                           'Y')
            INTO   l_rule_flag
            FROM   ra_customer_trx trx,
                   ra_cust_trx_line_gl_dist d
            WHERE  trx.customer_trx_id   = l_trx_rec.customer_trx_id
            and    trx.previous_customer_trx_id = d.customer_trx_id
            and    d.account_class in ('UNEARN', 'UNBILL');
        IF ( l_rule_flag ='Y')
        THEN


        BEGIN
              FOR l_error_rec IN rule_check LOOP

                  IF PG_DEBUG in ('Y', 'C') THEN
                     arp_util.debug(  'ERROR:  the rule information is invalid ' ||
                                 ' for line ' ||
                                 TO_CHAR(l_error_rec.line_number));
                  END IF;

                  arp_trx_validate.add_to_error_list(
                                      p_error_mode,
                                      l_error_count,
                                      l_trx_rec.customer_trx_id,
                                      l_trx_rec.trx_number,
                                      l_error_rec.line_number,
                                      NULL,  -- other_line_number
                                      'AR_TW_LINE_RULE_INCOMPLETE',
                                      NULL,            -- p_error_location,
                                      'LINE_NUMBER',
                                      l_error_rec.line_number,
                                      NULL,
                                      NULL
                                   );

              END LOOP;

        EXCEPTION
           WHEN NO_DATA_FOUND THEN NULL;
           WHEN OTHERS
                THEN RAISE;
        END;

   END IF;
  END IF;

  /*----------------------------------------------+
   |  Check the creation sign of the transaction  |
   +----------------------------------------------*/

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'check creation sign');
   END IF;

   arp_non_db_pkg.check_creation_sign(
                                        l_creation_sign,
                                        l_trx_amount,
                                        NULL,
                                        l_error_message
                                      );
   IF ( l_error_message IS NOT NULL )
   THEN

          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug(  'ERROR: the transaction violate the creation sign');
          END IF;

          arp_trx_validate.add_to_error_list(
                              p_error_mode,
                              l_error_count,
                              l_trx_rec.customer_trx_id,
                              l_trx_rec.trx_number,
                              NULL,  -- line_number
                              NULL,  -- other_line_number
                              l_error_message,
                              'TGW_HEADER.CTT_TYPE_NAME',
                              NULL,
                              NULL,
                              NULL,
                              NULL
                           );

   END IF;



  /*---------------------+
   |  Check the GL Date  |
   +---------------------*/

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'check the GL date');
   END IF;

  /*------------------------------------------------------+
   |  Verify that the GL Date is in an Opened, Future or  |
   |  Never Opened (Arrears only) Period.                 |
   +------------------------------------------------------*/

   l_result_flag := arp_util.validate_and_default_gl_date(
                                     l_trx_gl_date,
                                     NULL,
                                     NULL,
                                     NULL,
                                     null,
                                     l_trx_gl_date,
                                     null,
                                     null,
                                     null,
                                     TO_CHAR(l_trx_rec.invoicing_rule_id),
                                     pg_set_of_books_id,
                                     222,
                                     l_default_gl_date,
                                     l_dummy,
                                     l_dummy);

   IF ( l_trx_gl_date <> l_default_gl_date )
   THEN
                  IF PG_DEBUG in ('Y', 'C') THEN
                     arp_util.debug(  'ERROR:  the GL date is invalid');
                  END IF;

                  arp_trx_validate.add_to_error_list(
                                      p_error_mode,
                                      l_error_count,
                                      l_trx_rec.customer_trx_id,
                                      l_trx_rec.trx_number,
                                      NULL,
                                      NULL,  -- other_line_number
                                      'AR_INVALID_APP_GL_DATE',
                                      'TGW_HEADER.GD_GL_DATE',
                                      'GL_DATE',
                                      l_trx_gl_date,
                                      NULL,
                                      NULL
                                   );

   END IF;



  /*==================================+
   |  Credit Memo Validations Follow  |
   +==================================*/

   IF ( l_trx_rec.previous_customer_trx_id IS NOT NULL )
   THEN

         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug(  'check credit memos against specific transactions');
            arp_util.debug(  'get credit memo information');
         END IF;

         arp_ct_pkg.fetch_p(l_prev_trx_rec,
                            l_trx_rec.previous_customer_trx_id);

         SELECT lgd_trx.gl_date
         INTO   l_prev_gl_date
         FROM   ra_cust_trx_line_gl_dist lgd_trx
         WHERE  lgd_trx.customer_trx_id = l_trx_rec.previous_customer_trx_id
         AND    lgd_trx.latest_rec_flag = 'Y'
         AND    lgd_trx.account_class   = 'REC';

         SELECT allow_overapplication_flag,
                natural_application_only_flag,
                accounting_affect_flag,
                type
         INTO   l_allow_overapplication_flag,
                l_natural_app_only_flag,
                l_open_receivables_flag,
                l_credited_class
         FROM   ra_cust_trx_types
         WHERE  cust_trx_type_id = l_prev_trx_rec.cust_trx_type_id;


        /*--------------------------------------+
         |  Get the amounts of the credit memo  |
         +--------------------------------------*/

         SELECT SUM(
                     DECODE( ctl.line_type,
                             'LINE',     ctl.extended_amount,
                             'CHARGES',  ctl.extended_amount,
                                         0 )
                   ),
                SUM(
                     DECODE( ctl.line_type,
                             'TAX',  ctl.extended_amount,
                                     0 )
                   ),
                SUM(
                     DECODE( ctl.line_type,
                             'FREIGHT',  ctl.extended_amount,
                                         0 )
                   )
         INTO   l_line_amount,
                l_tax_amount,
                l_freight_amount
         FROM   ra_customer_trx_lines ctl
         WHERE  customer_trx_id = l_trx_rec.customer_trx_id;


        /*-------------------------------------------------+
         |  Get the balances for the credited transaction  |
 	+-------------------------------------------------*/

         arp_trx_util.get_summary_trx_balances( l_trx_rec.previous_customer_trx_id,
                                                l_open_receivables_flag,
                                                l_prev_line_original,
                                                l_prev_line_remaining,
                                                l_prev_tax_original,
                                                l_prev_tax_remaining,
                                                l_prev_freight_original,
                                                l_prev_freight_remaining,
                                                l_prev_charges_original,
                                                l_prev_charges_remaining,
                                                l_prev_total_original,
                                                l_prev_total_remaining);

         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug(  'previous_customer_trx_id : '||l_trx_rec.previous_customer_trx_id);
            arp_util.debug(  'l_line_amount            : '||l_line_amount);
            arp_util.debug(  'l_tax_amount             : '||l_tax_amount);
            arp_util.debug(  'l_freight_amount         : '||l_freight_amount);
            arp_util.debug(  'l_open_receivables_flag  : '||l_open_receivables_flag);
            arp_util.debug(  'l_prev_line_original     : '||l_prev_line_original);
            arp_util.debug(  'l_prev_line_remaining    : '||l_prev_line_remaining);
            arp_util.debug(  'l_prev_tax_original      : '||l_prev_tax_original);
            arp_util.debug(  'l_prev_tax_remaining     : '||l_prev_tax_remaining);
            arp_util.debug(  'l_prev_freight_original  : '||l_prev_freight_original);
            arp_util.debug(  'l_prev_freight_remaining : '||l_prev_freight_remaining);
            arp_util.debug(  'l_prev_total_original    : '||l_prev_total_original);
            arp_util.debug(  'l_prev_total_remaining   : '||l_prev_total_remaining);
            arp_util.debug(  'l_open_receivables_flag : '||l_open_receivables_flag);
         END IF;

        /* Bug 882789: Get commitment adjustment amount for the credited
           transaction. This amount should be added to l_prev_total_remaining
           when checking natural application since the commitment adjustment
           will be reversed when we complete the credit memo. Otherwise,
           natural application checking will fail since the credit amount
           is more than the amount remaining for the credited transaction */

       /* Bug 2534132: Get Line,tax and freight buckets of the Commitment Adjustment
           and add to the line_remaining, tax_remaining and freight_remaining while
           checking natural application since the commitment adjustment will be reversed
           when we complete the credit memo. */

        select nvl(sum(amount),0),nvl(sum(line_adjusted),0),nvl(sum(tax_adjusted),0),nvl(sum(freight_adjusted),0)
        into l_commit_adj_amount,l_commit_line_amount,l_commit_tax_amount,l_commit_frt_amount
        from ar_adjustments
        where customer_trx_id = l_trx_rec.previous_customer_trx_id
        and receivables_trx_id = -1;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug(  'l_commit_adj_amount : ' || to_char(l_commit_adj_amount));
        END IF;

        /*----------------------------------------------------+
         |  For credit memos against specific transactions,   |
         |  check for illegal overapplications.               |
         +----------------------------------------------------*/

        /*----------------------------------------+
         |  Check the transaction's total amount  |
         +----------------------------------------*/

         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug(  'check for total overapplication');
         END IF;

         /* Bug 882789: minus l_commit_adj_amount from l_prev_total_remaining */
         arp_non_db_pkg.check_natural_application(
                                                  l_creation_sign,
                                                  l_allow_overapplication_flag,
                                                  l_natural_app_only_flag,
                                                  '+', -- p_sign_of_ps
                                                  'Y', -- p_chk_overapp_if_zero
                                                  l_trx_amount,
                                                  0,   -- p_discount_taken
                                                  l_prev_total_remaining -
							l_commit_adj_amount,
                                                  l_prev_total_original,
                                                  NULL,    -- event
                                                  l_error_message
                                                );

         IF ( l_error_message IS NOT NULL )
         THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug(  'ERROR:  overapplication of the total amount');
                END IF;

                arp_trx_validate.add_to_error_list(
                                    p_error_mode,
                                    l_error_count,
                                    l_trx_rec.customer_trx_id,
                                    l_trx_rec.trx_number,
                                    NULL,  -- line_number
                                    NULL,  -- other_line_number
                                    l_error_message,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL
                                 );

         END IF;


        /*---------------------------------------+
         |  Check the transaction's line amount  |
         +---------------------------------------*/

         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug(  'check for line overapplication');
         END IF;

         /* Bug 882789: minus l_commit_adj_amount from l_prev_line_remaining */
         arp_non_db_pkg.check_natural_application(
                                                  l_creation_sign,
                                                  l_allow_overapplication_flag,
                                                  l_natural_app_only_flag,
                                                  '+', -- p_sign_of_ps
                                                  'Y', -- p_chk_overapp_if_zero
                                                  l_line_amount,
                                                  0,   -- p_discount_taken
                                                  l_prev_line_remaining -
							l_commit_line_amount, /* Bug2534132*/
                                                  l_prev_line_original,
                                                  NULL,    -- event
                                                  l_error_message
                                                );

         IF ( l_error_message IS NOT NULL )
         THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug(  'ERROR:  overapplication of the line amount');
                END IF;

                arp_trx_validate.add_to_error_list(
                                    p_error_mode,
                                    l_error_count,
                                    l_trx_rec.customer_trx_id,
                                    l_trx_rec.trx_number,
                                    NULL,  -- line_number
                                    NULL,  -- other_line_number
                                    l_error_message,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL
                                 );

         END IF;

        /*--------------------------------------+
         |  Check the transaction's tax amount  |
         +--------------------------------------*/

         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug(  'check for tax overapplication');
         END IF;

         arp_non_db_pkg.check_natural_application(
                                                  l_creation_sign,
                                                  l_allow_overapplication_flag,
                                                  l_natural_app_only_flag,
                                                  '+', -- p_sign_of_ps
                                                  'Y', -- p_chk_overapp_if_zero
                                                  l_tax_amount,
                                                  0,   -- p_discount_taken
                                                  l_prev_tax_remaining -
                                                          l_commit_tax_amount,/*Bug2534132*/
                                                  l_prev_tax_original,
                                                  NULL,    -- event
                                                  l_error_message
                                                );

         IF ( l_error_message IS NOT NULL )
         THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug(  'ERROR:  overapplication of the tax amount');
                END IF;

                arp_trx_validate.add_to_error_list(
                                    p_error_mode,
                                    l_error_count,
                                    l_trx_rec.customer_trx_id,
                                    l_trx_rec.trx_number,
                                    NULL,  -- line_number
                                    NULL,  -- other_line_number
                                    l_error_message,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL
                                 );

         END IF;

        /*------------------------------------------+
         |  Check the transaction's freight amount  |
         +------------------------------------------*/

         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug(  'check for freight overapplication');
         END IF;

         arp_non_db_pkg.check_natural_application(
                                                  l_creation_sign,
                                                  l_allow_overapplication_flag,
                                                  l_natural_app_only_flag,
                                                  '+', -- p_sign_of_ps
                                                  'Y', -- p_chk_overapp_if_zero
                                                  l_freight_amount,
                                                  0,   -- p_discount_taken
                                                  l_prev_freight_remaining -
                                                            l_commit_frt_amount, /*Bug2534132*/
                                                  l_prev_freight_original,
                                                  NULL,    -- event
                                                  l_error_message
                                                );

         IF ( l_error_message IS NOT NULL )
         THEN

               IF PG_DEBUG in ('Y', 'C') THEN
                  arp_util.debug(  'ERROR:  overapplication of the freight amount');
               END IF;

                arp_trx_validate.add_to_error_list(
                                    p_error_mode,
                                    l_error_count,
                                    l_trx_rec.customer_trx_id,
                                    l_trx_rec.trx_number,
                                    NULL,  -- line_number
                                    NULL,  -- other_line_number
                                    l_error_message,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL
                                 );

        END IF;

       /*---------------------------------------------------------------+
        |  Insure that the credit memo does not overapply the Deposit   |
        |  that it is crediting.                                        |
        +---------------------------------------------------------------*/

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug(  'check for commitment balance overapplication');
        END IF;

        IF ( l_credited_class = 'DEP' )
        THEN

         /*---------------------------------------------------------------+
          |  Get the so_source_code and so_installed_flag values          |
          |  from the passed in parameter, the cached value ffrom the DB. |
          +---------------------------------------------------------------*/

          IF (p_so_source_code IS NOT NULL )
          THEN
               pg_so_source_code := p_so_source_code;
               l_so_source_code := pg_so_source_code;
          ELSE
               IF (pg_so_source_code IS NOT NULL)
               THEN
                     l_so_source_code := pg_so_source_code;
               ELSE
                     -- OE/OM change
                     -- fnd_profile.get( 'SO_SOURCE_CODE', l_so_source_code );
                     oe_profile.get( 'SO_SOURCE_CODE', l_so_source_code );
                     pg_so_source_code :=  l_so_source_code;
               END IF;
          END IF;

          IF (p_so_installed_flag IS NOT NULL )
          THEN
               pg_so_installed_flag := p_so_installed_flag;
               l_so_installed_flag  := pg_so_installed_flag;
          ELSE
               IF (pg_so_installed_flag IS NOT NULL)
               THEN
                     l_so_installed_flag := pg_so_installed_flag;
               ELSE
                     l_so_installed_flag := 'N';
                     l_result_flag := fnd_installation.get_app_info('OE',
                                                 l_so_installed_flag,
                                                 l_dummy,
                                                 l_dummy);

                     pg_so_installed_flag :=  l_so_installed_flag;
               END IF;
          END IF;

	  /*  Bug 3249432. Check for commitment overapplication only if trx is incomplete. */

          IF l_trx_rec.complete_flag = 'N'
          AND ( NOT arp_trx_val.check_commitment_overapp(
                                   l_trx_rec.previous_customer_trx_id,
                                   l_credited_class,
                                   l_commit_amount,
                                   ABS(l_trx_amount),
                                   l_so_source_code,
                                   p_so_installed_flag,
                                   l_commitment_balance) )
             THEN
               IF PG_DEBUG in ('Y', 'C') THEN
                  arp_util.debug(
                         'ERROR:  overapplication of the commitment balance');
               END IF;

               arp_trx_validate.add_to_error_list(
                                        p_error_mode,
                                        l_error_count,
                                        l_trx_rec.customer_trx_id,
                                        l_trx_rec.trx_number,
                                        NULL,
                                        NULL,  -- other_line_number
                                        'AR_TW_CM_COMMIT_BAL_OVERAPP',
                                        NULL,
                                        'COMMITMENT_BALANCE',
                                        TO_CHAR(l_commitment_balance),
                                        NULL,
                                        NULL
                                     );
          END IF;

        END IF;

       /*-------------------------------------------------------+
        |  The GL Date must be >= the credited transaction's    |
        |  GL Date.                                             |
        +-------------------------------------------------------*/

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug(  'check the GL date against the credited transaction''s');
       END IF;

        IF ( l_trx_gl_date < l_prev_gl_date )
        THEN

              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug(
                     'ERROR:  GL date is before the credited transaction''s');
              END IF;

              arp_trx_validate.add_to_error_list(
                                  p_error_mode,
                                  l_error_count,
                                  l_trx_rec.customer_trx_id,
                                  l_trx_rec.trx_number,
                                  NULL,  -- line number
                                  NULL,  -- other_line_number
                                  'AR_TW_GL_DATE_BEFORE_INV_GL_DT',
                                  'TGW_HEADER.GD_GL_DATE',
                                  'GL_DATE',
                                  TO_CHAR(l_prev_gl_date, 'DD-MON-YYYY'),
                                  NULL,
                                  NULL
                               );

        END IF;

  /*-------------------------------------------------------------------------+
   |  For credit memos against specific transactions,                        |
   |  check for later credit memos.                                          |
   |                                                                         |
   |  If any other credit memos against the same invoice have been completed |
   |  between the time when this credit memo was created and when it is made |
   |  complete, the accounting for this CM will be wrong. For example, if the|
   |  Credit Method For Split Term Invoices is LIFO, then the same periods   |
   |  could be credited more than once. In this case, the accounting for the |
   |  credit memo must be redone before the CM can be made complete.         |
   +-------------------------------------------------------------------------*/

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug(  'check for later credit memos');
        END IF;
        SELECT MAX( other_ct.customer_trx_id )
        INTO   l_result
        FROM   ra_customer_trx       other_ct,
               ra_customer_trx       this_ct
        WHERE  this_ct.customer_trx_id           = p_customer_trx_id
        AND    other_ct.previous_customer_trx_id =
                                               this_ct.previous_customer_trx_id
        AND    other_ct.customer_trx_id         <> this_ct.customer_trx_id
	/*3606541*/
	AND    other_ct.creation_date > this_ct.creation_date
	AND    NVL(other_ct.complete_flag,'N')='Y';

        IF ( l_result  IS NOT NULL )
        THEN

                 IF PG_DEBUG in ('Y', 'C') THEN
                    arp_util.debug(  'ERROR: later credit memos exist');
                 END IF;

                  arp_trx_validate.add_to_error_list(
                                      p_error_mode,
                                      l_error_count,
                                      l_trx_rec.customer_trx_id,
                                      l_trx_rec.trx_number,
                                      NULL,
                                      NULL,  -- other_line_number
                                      'AR_TW_STALE_CM',
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL
                                   );

        END IF;



   END IF;  -- credit memo against specific transaction case

   /* Bug 2164863 - p_check_tax_acct = 'Y' condition */
   ELSIF (p_check_tax_acct = 'Y')
   THEN

         l_dummy_flag := check_tax_and_accounting(
                                            p_error_mode,
                                            p_customer_trx_id,
                                            l_trx_rec.previous_customer_trx_id,
                                            l_trx_rec.trx_number,
                                            l_class,
                                            l_tax_calculation_flag,
                                            l_trx_rec.invoicing_rule_id,
                                            l_error_count,
                                            l_dummy_number,
                                            l_dummy_number);

   END IF;

--Bug Fix: 3261620 Begin#3
/*-------------------------------------------------------------------------+
|Bug Fix: 3261620                                                          |
|       Check whether the GL Accounts of the current transaction are either|
|invalid or end dated.                                                     |
+-------------------------------------------------------------------------*/
 IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug(  'Check for invalid GL Accounts');
 END IF;
  /* Bug fix 4398445
      Check if the transaction is revenue recognized */

   select decode(account_set_flag,'Y','N','N','Y','Y')
   into l_revrec_complete
   from ra_cust_trx_line_gl_dist
   where customer_trx_id = p_customer_trx_id
   and  account_class = 'REC'
   and  latest_rec_flag = 'Y';

   IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('do_completion_checking: ' || 'Revenue Recognition Complete Flag : '||l_revrec_complete);
   END IF;
   /*End bug5444418*/

   OPEN gl_account_ccid_cur;
   LOOP
        FETCH gl_account_ccid_cur INTO l_gl_account_ccid,l_dist_gl_date,
                                       l_account_class, l_account_set_flag;
        EXIT WHEN gl_account_ccid_cur%NOTFOUND;
               /* Bug fix 5444418
           Do not check the validity of the CCID if it is derived from the Invoice */
      IF NOT (l_trx_rec.invoicing_rule_id IS NOT NULL AND
            l_account_class in ('REV','UNEARN','UNBILL') AND
            l_account_set_flag = 'N' AND
            l_revrec_complete = 'N') THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('do_completion_checking: '||'Checking CCID '||l_gl_account_ccid);
            END IF;
           IF (
              -- If the GL Account is excluded using a Security Rule
              -- 3567612 : pass ARP_GLOBAL.chart_of_accounts_id instead of 101
    		( NOT fnd_flex_keyval.validate_ccid ( appl_short_name  => 'SQLGL',
                       				      key_flex_code    => 'GL#',
                       				      structure_number => ARP_GLOBAL.chart_of_accounts_id,
                       				      combination_id   => l_gl_account_ccid,
                       				      security         => 'ENFORCE'
		    				    )
		 )
 	     OR
		-- If the GL Account is  End Dated
		 (fnd_flex_keyval.start_date > l_dist_gl_date)
	     OR
		 (fnd_flex_keyval.end_date   < l_dist_gl_date)
	     /*3679531*/
	     OR  (fnd_flex_keyval.enabled_flag=FALSE)
           )
        THEN

	     IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug(
                               'Error: Atleast one of the GL Accounts is either invalid or end dated');
             END IF;
             arp_trx_validate.add_to_error_list(
                              p_error_mode,
                              l_error_count,
                              l_trx_rec.customer_trx_id,
                              l_trx_rec.trx_number,
                              NULL,  -- line_number
                              NULL,  -- other_line_number
                              'AR_INVALID_GL_ACCOUNT',--Message Name
                              NULL,  -- p_error_location,
                              NULL,  -- token name 1
                              NULL,  -- token 1
                              NULL,  -- token name 2
                              NULL   -- token 2
                           );
        END IF;
      END IF;
   END LOOP;
   CLOSE gl_account_ccid_cur;

--Bug Fix: 3261620 End#3

   p_error_count := l_error_count;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'completion error count: ' || to_char(l_error_count));
      arp_util.debug('arp_trx_completion_chk.do_completion_checking()-');
   END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug(
                    'EXCEPTION:  arp_trx_completion_chk.do_completion_checking()');
        END IF;
        RAISE;

END  do_completion_checking;

/* Bug 3185358 */
PROCEDURE dm_reversal_amount_chk(
				p_customer_trx_id 	IN
					ra_customer_trx.customer_trx_id%type,
				p_reversed_cash_receipt_id IN
					ra_customer_trx.reversed_cash_receipt_id%type,
				p_status		OUT NOCOPY VARCHAR2) IS
l_original_amount	ra_customer_trx_lines.gross_extended_amount%type;
l_dm_amount		ra_customer_trx_lines.gross_extended_amount%type;
line_amount		ra_customer_trx_lines.gross_extended_amount%type;
tax_amount		ra_customer_trx_lines.gross_extended_amount%type;
frt_amount		ra_customer_trx_lines.gross_extended_amount%type;
BEGIN
	/* step 1: Fetch the original receipt amount from ar_cash_receipts
	   step 2: Fetch total amount from trx (dm)
	   step 3: compare .
	   step 4: if dm amount < origianl return "E"
		   else return "S"
	*/
	/* Fetch Original receipt amount */
	l_original_amount:=0;
	BEGIN
	SELECT amount INTO
		l_original_amount
	FROM
	   AR_CASH_RECEIPTS WHERE cash_receipt_id=p_reversed_cash_receipt_id;
	EXCEPTION
	   WHEN OTHERS THEN
	     l_original_amount:=0;
	END;

	/* Fetch Amount due original for debit memo */
	l_dm_amount:=0;
	line_amount:=0;
	tax_amount:=0;
	frt_amount:=0;

	SELECT sum(decode(ctl.line_type, 'LINE', ctl.extended_amount,
                        'CB', ctl.extended_amount, 0)),
	sum(decode(ctl.line_type, 'TAX', ctl.extended_amount, 0)),
	sum(decode(ctl.line_type, 'FREIGHT', ctl.extended_amount, 0))
	INTO
	line_amount,
	tax_amount,
	frt_amount
	FROM
	ra_customer_trx_lines ctl
	WHERE  ctl.customer_trx_id = p_customer_trx_id;

	l_dm_amount:=nvl(line_amount,0)+nvl(tax_amount,0)+nvl(frt_amount,0);

	/* Debit memo amount < original amount Raise error */

	IF l_dm_amount < l_original_amount THEN
		p_status:='E';
	ELSE
		p_status:='S';
	END IF;
END dm_reversal_amount_chk;


  /*---------------------------------------------+
   |   Package initialization section.           |
   +---------------------------------------------*/
PROCEDURE init IS
BEGIN

  pg_base_curr_code    := arp_global.functional_currency;
  pg_salesrep_required_flag :=
          arp_trx_global.system_info.system_parameters.salesrep_required_flag;
  pg_set_of_books_id   :=
          arp_trx_global.system_info.system_parameters.set_of_books_id;
END init;

BEGIN
   init;
END ARP_TRX_COMPLETE_CHK;

/
