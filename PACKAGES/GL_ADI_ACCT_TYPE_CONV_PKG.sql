--------------------------------------------------------
--  DDL for Package GL_ADI_ACCT_TYPE_CONV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_ADI_ACCT_TYPE_CONV_PKG" AUTHID CURRENT_USER as
/* $Header: gluadics.pls 120.5 2005/05/05 01:34:50 kvora ship $ */

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
  --      NULL, '1205', '1204', to_date('31-MAR-1999', 'DD-MON-YYYY'),
  --      NULL, 'Payables', 'Other', 31, 34567, 100.00, NULL, NULL),

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
    p_error_msg                  OUT NOCOPY VARCHAR2);

END GL_ADI_ACCT_TYPE_CONV_PKG;

 

/
