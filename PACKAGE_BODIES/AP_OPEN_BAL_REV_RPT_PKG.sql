--------------------------------------------------------
--  DDL for Package Body AP_OPEN_BAL_REV_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_OPEN_BAL_REV_RPT_PKG" 
-- $Header: APOBRRPB.pls 120.4 2008/01/25 11:22:33 sgudupat noship $
   -- ****************************************************************************************
   -- Copyright (c)  2000  Oracle Corporation    Product Development
   -- All rights reserved
   -- ****************************************************************************************
   --
   -- PROGRAM NAME
   -- APOBRRPB.pls
   --
   -- DESCRIPTION
   --  This script creates the package body of AP_OPEN_BAL_REV_RPT_PKG.
   --  This package is used to generate AP Open Balances Revaluation Report.
   --
   -- USAGE
   --   To install        How to Install
   --   To execute        How to Execute
   --
   -- DEPENDENCIES
   --   None.
   --
   --
   -- LAST UPDATE DATE   25-JAN-2008
   --   Date the program has been modified for the last time
   --
   -- HISTORY
   -- =======
   --
   -- VERSION DATE        AUTHOR(S)         DESCRIPTION
   -- ------- ----------- ---------------   ------------------------------------
   -- 1.0    21-FEB-2007 Praveen Gollu      Creation
   -- 1.1    25-JAN-2008 Sandeep G          Fix for Bug #6773558
   --****************************************************************************************
AS
   FUNCTION beforereport
      RETURN BOOLEAN
   IS
      lc_exchange_rate_type   VARCHAR2 (2000);
      ex_exchange_rate_type   EXCEPTION;
      ln_exch_rate            NUMBER;
   BEGIN
      SELECT gl.ledger_id, gl.currency_code
        INTO gc_ledger_id, gc_func_currency
        FROM gl_ledgers gl, hr_operating_units hou
       WHERE hou.organization_id = fnd_profile.VALUE ('org_id')
         AND gl.ledger_id = hou.set_of_books_id;

      BEGIN
         SELECT NAME
           INTO gc_operating_name
           FROM hr_operating_units
          WHERE organization_id = p_org_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            gc_operating_name := NULL;
      END;

      IF p_org_id IS NULL
      THEN
         gc_ou_where := 'AND 1=1';
      ELSE
         gc_ou_where := 'AND ai.org_id=:p_org_id';
      END IF;

      IF p_include_domestic_inv = 'N'
      THEN
         gc_include_dom_inv :=
                         ' AND ai.invoice_currency_code <> :gc_func_currency';
      ELSE
         gc_include_dom_inv := ' AND 1 = 1';
      END IF;

      IF p_supplier IS NOT NULL
      THEN
         SELECT vendor_name
           INTO gc_supplier_name
           FROM po_vendors
          WHERE vendor_id = p_supplier;
      ELSE
         gc_supplier_name := NULL;
      END IF;

      IF p_supplier IS NOT NULL
      THEN
         gc_supplier := ' AND ai.vendor_id=:P_SUPPLIER';
      ELSE
         gc_supplier := ' AND 1 = 1';
      END IF;

      IF p_currency = 'ANY' OR p_currency IS NULL
      THEN
         IF p_exchange_rate_type = 'User'
         THEN
            fnd_message.set_name ('SQLAP', 'AP_EXCHANGE_RATE_TYPE');
            lc_exchange_rate_type := fnd_message.get;
            RAISE ex_exchange_rate_type;
         ELSE
            gc_currency := ' AND 1 = 1';
         END IF;
      ELSE
         gc_currency := 'AND ai.invoice_currency_code = :P_CURRENCY';
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN ex_exchange_rate_type
      THEN
         fnd_file.put_line (fnd_file.LOG, lc_exchange_rate_type);
         RETURN FALSE;
   END beforereport;

   FUNCTION exch_rate_calc (currency IN VARCHAR2)
      RETURN NUMBER
   AS
      ln_exch_rate            NUMBER;
      p_date_from             VARCHAR2 (11);
      lc_error_msg            VARCHAR2 (3000);
      lc_exchange_rate_type   VARCHAR2 (2000);
      ex_exchange_rate_type   EXCEPTION;
   BEGIN
      BEGIN
         IF currency <> gc_func_currency
         THEN
            BEGIN
               SELECT gdr.conversion_rate
                 INTO ln_exch_rate
                 FROM gl_daily_rates gdr
                WHERE gdr.conversion_type = p_exchange_rate_type
                  AND gdr.from_currency = currency
                  AND gdr.to_currency = gc_func_currency
                  AND gdr.conversion_date = p_as_of_date;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  fnd_message.set_name ('SQLAP', 'AP_EXCHANGE_RATE');
                  fnd_message.set_token ('P_EXCHANGE_RATE_TYPE',
                                         p_exchange_rate_type
                                        );
                  fnd_message.set_token ('CURRENCY', currency);
                  fnd_message.set_token ('P_AS_OF_DATE', p_as_of_date);
                  lc_exchange_rate_type := fnd_message.get;
                  fnd_file.put_line (fnd_file.LOG, lc_exchange_rate_type);
                  raise_application_error (-20101, lc_exchange_rate_type);
            END;
         ELSE
            ln_exch_rate := 1;
         END IF;

         RETURN (ln_exch_rate);
      EXCEPTION
         WHEN ex_exchange_rate_type
         THEN
            fnd_file.put_line (fnd_file.LOG, lc_exchange_rate_type);
      END;
   END exch_rate_calc;

   FUNCTION amtduereval (
      func_curr_amt   IN   NUMBER,
      exch_rate       IN   NUMBER,
      tran_curr       IN   VARCHAR
   )
      RETURN NUMBER
   IS
   BEGIN
      IF tran_curr = gc_func_currency
      THEN
         RETURN (NVL (func_curr_amt, 0));
      ELSE
         RETURN (NVL (func_curr_amt * exch_rate, 0));
      END IF;
   END amtduereval;

   FUNCTION vat_calc_amt (
      prepay_amt_app   IN   NUMBER,
      tax_amt          IN   NUMBER,
      inv_amt          IN   NUMBER
   )
      RETURN NUMBER
   IS
      return_number   NUMBER;
      sum_amt         NUMBER;
   BEGIN
      fnd_file.put_line (fnd_file.LOG,
                            'return'
                         ||   (inv_amt - tax_amt)
                            * ((inv_amt - prepay_amt_app) / inv_amt)
                        );
      sum_amt := inv_amt + tax_amt;
      return_number :=
                    (sum_amt - tax_amt)
                  * ((sum_amt - prepay_amt_app) / sum_amt);
      RETURN (return_number);
   END vat_calc_amt;

   FUNCTION amtduefilter (p_amt_due IN NUMBER)
      RETURN BOOLEAN
   IS
   BEGIN
      IF p_amt_due = 0 OR p_amt_due IS NULL
      THEN
         RETURN (FALSE);
      ELSE
         RETURN (TRUE);
      END IF;
   END;
END ap_open_bal_rev_rpt_pkg;

/
