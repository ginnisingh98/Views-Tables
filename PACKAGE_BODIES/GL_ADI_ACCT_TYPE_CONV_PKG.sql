--------------------------------------------------------
--  DDL for Package Body GL_ADI_ACCT_TYPE_CONV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_ADI_ACCT_TYPE_CONV_PKG" as
/* $Header: gluadicb.pls 120.5 2005/05/05 01:34:42 kvora ship $ */

  ---
  --- PUBLIC FUNCTIONS
  ---

  --
  -- Procedure
  --   get_accounted_amount
  -- Purpose
  --   Get accounted amount after applying account type specific conversion.
  --   This program assumes that currencies with an EMU fixed rate will not
  --   be passed as parameters. ADI will call a different API in that case.
  --   The accounted amount is returned with the correct precision and mau.
  --   If the p_conversion_type is passed, the program attempts to find the
  --   conversion rate. If p_conversion_type is User, the passed p_conversion_
  --   rate is used to calculate the accounted amount.
  -- History
  --   19-APR-2000      K Vora        Created
  -- Arguments
  --   p_ledger_id                   Ledger Id
  --   p_reporting_ledger_id         Preferred Reporting Ledger Id
  --   p_functional_currency         Functional Currency
  --   p_journal_currency            Entered Currency
  --   p_conversion_type             Currency Conversion Type (Optional)
  --   p_bs_conversion_type          Balance Sheet or User Conversion Type
  --   p_is_conversion_type          Income Statement Account Conversion Type
  --   p_conversion_date             Currency Conversion Date
  --   p_conversion_rate             Currency Conversion Rate (Optional)
  --   p_source_name                 Journal Source
  --   p_category_name               Journal Category
  --   p_max_roll_days               Rollback Days from Profile Option
  --   p_code_combination_id         Code Combination Id
  --   p_entered_amount              Entered Amount
  --   p_accounted_amount            Returns - Accounted Amount
  --   p_error_msg                   Returns - Error Message, 240 chars max
  --
  -- Example
  --   gl_adi_acct_type_conv_pkg.get_accounted_amount(101, 102, 'USD', 'ITL',
  --      '', '1205', '1204', to_date('31-MAR-1999', 'DD-MON-YYYY'),
  --      '', 'Payables', 'Other', 31, 34567, 100.00, NULL, NULL),

  PROCEDURE get_accounted_amount(
    p_ledger_id                  NUMBER,
    p_reporting_ledger_id        NUMBER,
    p_functional_currency        VARCHAR2,
    p_journal_currency           VARCHAR2,
    p_conversion_type            VARCHAR2,
    p_bs_conversion_type         VARCHAR2,
    p_is_conversion_type         VARCHAR2,
    p_conversion_date            DATE,
    p_conversion_rate            NUMBER,
    p_source_name                VARCHAR2,
    p_category_name              VARCHAR2,
    p_max_roll_days              NUMBER,
    p_code_combination_id        NUMBER,
    p_entered_amount             NUMBER,
    p_accounted_amount           OUT NOCOPY NUMBER,
    p_error_msg                  OUT NOCOPY VARCHAR2) IS

  l_conversion_type              VARCHAR2(30);
  l_account_type                 VARCHAR2(1);
  l_other_source                 VARCHAR2(1);
  l_other_category               VARCHAR2(1);
  l_conv_rate_denom              NUMBER;
  l_conv_rate_numer              NUMBER;
  l_max_roll_days                NUMBER;
  i                              NUMBER;

  CURSOR get_rollback_days_c IS
      SELECT decode(lrl.alc_no_rate_action_code,
                    'REPORT_ERROR', 0, p_max_roll_days)
      FROM   gl_ledger_relationships lrl,
	         gl_je_inclusion_rules inc
      WHERE  lrl.source_ledger_id = p_ledger_id
      AND    lrl.target_ledger_id = p_reporting_ledger_id
      AND    lrl.target_ledger_category_code = 'ALC'
      AND    lrl.relationship_type_code in ('ADJUST', 'JOURNAL', 'SUBLEDGER')
      AND    lrl.application_id = 101
      AND    lrl.relationship_enabled_flag = 'Y'
	  AND    inc.je_rule_set_id = lrl.gl_je_conversion_set_id
      AND    inc.include_flag = 'Y'
      AND    ((inc.je_source_name = p_source_name AND
	           inc.je_category_name = p_category_name)
		   OR (inc.je_source_name = p_source_name AND
		       inc.je_category_name = 'Other')
		   OR (inc.je_source_name = 'Other' AND
		       inc.je_category_name = p_category_name)
		   OR (inc.je_source_name = 'Other' AND
		       inc.je_category_name = 'Other'))
      ORDER BY decode(inc.je_source_name, 'Other', 2, 0)
               + decode(inc.je_category_name, 'Other', 1, 0);

  BEGIN

     IF (p_conversion_type IS NULL) THEN
        SELECT account_type
        INTO   l_account_type
        FROM   gl_code_combinations
        WHERE  code_combination_id = p_code_combination_id;

        IF ((l_account_type = 'R') OR
            (l_account_type = 'E')) THEN
           l_conversion_type := p_is_conversion_type;
        ELSE
           l_conversion_type := p_bs_conversion_type;
        END IF;
     ELSE
        l_conversion_type := p_conversion_type;
     END IF;

     IF (l_conversion_type <> 'User') THEN
        l_max_roll_days := -1;

        OPEN get_rollback_days_c;
        WHILE (l_max_roll_days = -1) LOOP
           FETCH get_rollback_days_c INTO l_max_roll_days;
           IF (get_rollback_days_c%NOTFOUND) THEN
              IF (l_max_roll_days IS NULL) THEN
                 l_max_roll_days := -1;
              END IF;
              CLOSE get_rollback_days_c;
              EXIT;
           END IF;
        END LOOP;

        IF (l_max_roll_days = -1) THEN
           l_max_roll_days := 0;
        END IF;

        l_conv_rate_numer := gl_currency_api.get_closest_rate_numerator_sql(
                                p_journal_currency,
                                p_functional_currency,
                                p_conversion_date,
                                l_conversion_type,
                                l_max_roll_days);

        l_conv_rate_denom := gl_currency_api.get_closest_rate_denom_sql(
                                p_journal_currency,
                                p_functional_currency,
                                p_conversion_date,
                                l_conversion_type,
                                l_max_roll_days);

     ELSE     -- Conversion Type is User
        l_conv_rate_numer := p_conversion_rate;
        l_conv_rate_denom := 1;
     END IF;

     IF ((l_conv_rate_numer > 0) AND
         (l_conv_rate_denom > 0)) THEN

        SELECT round((p_entered_amount * l_conv_rate_numer
                      / l_conv_rate_denom)
             / nvl(curr.minimum_accountable_unit, power(10, -curr.precision)))
             * nvl(curr.minimum_accountable_unit, power(10, -curr.precision))
        INTO   p_accounted_amount
        FROM   fnd_currencies curr
        WHERE  curr.currency_code = p_functional_currency;
     ELSE
        p_error_msg := FND_MESSAGE.get_string('SQLGL', 'R_PPOS0056');
        p_accounted_amount := NULL;
     END IF;

EXCEPTION WHEN OTHERS THEN
  i := SQLCODE;
  p_error_msg := substrb(SQLERRM, 1, 150);

END get_accounted_amount;

END GL_ADI_ACCT_TYPE_CONV_PKG;

/
