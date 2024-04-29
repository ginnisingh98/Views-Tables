--------------------------------------------------------
--  DDL for Package Body AP_TRIAL_BALANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_TRIAL_BALANCE_PKG" AS
/* $Header: aptrbalb.pls 120.2 2004/06/04 23:09:22 yicao noship $ */

/*=============================================================================
This is the main entry routine for the Trial Balance Report. This function will
be called by the APXTRBAL.rdf the report itself and it passes the following
arguments:

p_accounting_date      - Accounting Date (Required)
p_from_date            - Exclude invoices Prior to this Date.
p_request_id           - Concurrent Request ID
p_reporting_entity_id  - Will be org_id, legal_entity_id or set_of_books_id
                         according to the reporting level. This is the cross
                         reporting paramter.
p_org_where_alb        - Multi ORG WHERE condition for cross org reporting
                         represents alias to ap_liability_balance.
p_org_where_ael        - Multi ORG WHERE condition for cross org reporting
                         represents alias to ap_ae_lines_all.
p_org_where_asp        - Multi ORG WHERE condition for cross org reporting
                         represents alias to ap_system_parameters_all.
p_neg_bal_only         - Report on Negative Balances only parameter.
p_debug_switch         - Debug Switch.

This function returns TRUE on successful completion and FALSE on any error.

Logic:
======

1.   Delete all records from AP_TRIAL_BAL table
2.   If Exclude invoices from date is not provided,
     2.1   Calls the Insert AP_TRIAL_BAL function without from date.
     2.2   validates for this given ORG condition if there exists atleast
           one record that has  future_dated_pmt_liab_relief = MATURITY.
           If so calls the future dated payments insert for AP_TRIAL_BAL
     2.3   If the report is submitted only for Negative Balances calls the
           process negative balances routine to remove all the possitive
           balances records.
3.   Else Processes the same logic mentioned above for p_from_date case.
     3.1   Calls the Insert AP_TRIAL_BAL function with from date.
     3.2   validates for this given ORG condition if there exists atleast
           one record that has  future_dated_pmt_liab_relief = MATURITY.
           If so calls the future dated payments insert for AP_TRIAL_BAL
     3.3   If the report is submitted only for Negative Balances calls the
           process negative balances routine to remove all the possitive
           balances records.
=============================================================================*/


FUNCTION Process_Trial_Balance (
                 p_accounting_date          IN  DATE,
                 p_from_date                IN  DATE,
                 p_request_id               IN  NUMBER,
                 p_reporting_entity_id      IN  NUMBER,
                 p_org_where_alb            IN  VARCHAR2,
                 p_org_where_ael            IN  VARCHAR2,
                 p_org_where_asp            IN  VARCHAR2,
                 p_neg_bal_only             IN  VARCHAR2,
                 p_debug_switch             IN  VARCHAR2)
                 RETURN BOOLEAN IS

  future_dated_pmts_used BOOLEAN;

BEGIN

  fnd_file.put_line (fnd_file.log, 'Stage :001 - Into Process_Trial_Balance');
  fnd_file.put_line (fnd_file.log, 'Stage :002 - Delete Existing ap_trial_bal'
                                   ||' records.');

  DELETE FROM ap_trial_bal;

  fnd_file.put_line (fnd_file.log, 'Stage :003 - Insert AP_Trial_Bal Info.');

  IF (p_from_date IS NULL) THEN

    fnd_file.put_line (fnd_file.log, 'Stage :004 - Into From Date Null Case');

    IF (Insert_AP_Trial_Bal (p_accounting_date,
                             p_request_id,
                             p_reporting_entity_id,
                             p_org_where_alb,
                             p_org_where_ael,
                             p_debug_switch) <> TRUE) THEN
       RETURN FALSE;

    END IF;

    fnd_file.put_line (fnd_file.log, 'Stage :005 - Verify Future Dated '
                                     ||'Payments Used.');

    future_dated_pmts_used := Use_Future_Dated(p_org_where_asp,
                                               p_debug_switch);

    fnd_file.put_line (fnd_file.log, 'Stage :006 - Insert Future Dated if '
                                     ||' applicable.');

    IF (future_dated_pmts_used) THEN

      fnd_file.put_line (fnd_file.log, 'Stage :007 - Into Insert Future Dated '
                                       ||'Payments Block');

      IF (Insert_Future_Dated (p_accounting_date,
                               p_request_id,
                               p_reporting_entity_id,
                               p_org_where_ael,
                               p_debug_switch) <> TRUE) THEN

         RETURN FALSE;

      END IF;

    END IF;

    fnd_file.put_line (fnd_file.log, 'Stage :008 - Negative Balances');

    IF (NVL(p_neg_bal_only,'N') = 'Y') THEN

      fnd_file.put_line (fnd_file.log, 'Stage :009 - Into Negative Balances'
                                       ||' Block');

      IF (Process_Neg_Bal (p_request_id) <> TRUE) THEN

         RETURN (TRUE);

      END IF;

    END IF;

  ELSE

   fnd_file.put_line (fnd_file.log, 'Stage :010 - Into From Date Case');

   IF (Insert_AP_Trial_Bal (p_accounting_date,
                            p_from_date,
                            p_request_id,
                            p_reporting_entity_id,
                            p_org_where_alb,
                            p_org_where_ael,
                            p_debug_switch) <> TRUE) THEN
      RETURN FALSE;

   END IF;

   fnd_file.put_line (fnd_file.log, 'Stage :011 - Verify Future Dated '
                                     ||'Payments Used.');

   future_dated_pmts_used := Use_Future_Dated(p_org_where_asp,
                                              p_debug_switch);

   fnd_file.put_line (fnd_file.log, 'Stage :012 - Insert Future Dated if '
                                     ||' applicable.');

   IF (future_dated_pmts_used) THEN

     fnd_file.put_line (fnd_file.log, 'Stage :013 - Into Insert Future Dated '
                                      ||'Payments Block');

     IF (Insert_Future_Dated (p_accounting_date,
                              p_from_date,
                              p_request_id,
                              p_reporting_entity_id,
                              p_org_where_ael,
                              p_debug_switch) <> TRUE) THEN
        RETURN FALSE;

     END IF;

   END IF;

   fnd_file.put_line (fnd_file.log, 'Stage :014 - Negative Balances');

   IF (NVL(p_neg_bal_only,'N') = 'Y') THEN

     fnd_file.put_line (fnd_file.log, 'Stage :015 - Into Negative Balances'
                                      ||' Block');

     IF (Process_Neg_Bal (p_request_id) <> TRUE) THEN

        RETURN FALSE;

     END IF;

   END IF;

  END IF;

RETURN TRUE;

EXCEPTION

  WHEN OTHERS THEN

    fnd_file.put_line(fnd_file.log,'Error Occured in Process_Trial_Balance'
                                   ||' Function.');
    fnd_file.put_line(fnd_file.log,'Error Code: '||to_char(SQLCODE));
    fnd_file.put_line(fnd_file.log,'Error Message: '||SQLERRM);

    RETURN FALSE;


END Process_Trial_Balance;

/*=============================================================================
Insert_AP_Trial_Bal Function is an overloaded function. Based on the
p_from_date option either of the function will be called. This function returns
TRUE on success and FALSE on any errors.

This procedure inserts records into AP_TRIAL_BAL table for a given org_id or
for set of orgs as per the parameter for AP and AX set of books. This inserts
invoices that have not been fully paid on or before for a given as of date.

For AP the insert gets the information from the AP_LIABILITY_BALANCE. As of
now this table is populated only by AP, While transferring information to
GL.
For AX the insert gets the information from the AX views namely:
ax_ap_ae_lines_all_v and ax_ap_ae_headers_all_v.

Note:
=====
1) Trial Balance will report based on AP accounting data for all pre 11i
transactions irrespective of customers using AX or AP. For Post 11i trial
balance will report based on the accounting information from either AX or AP
as it is being used.

The UNION SELECT is written to handle the same requirement.

=============================================================================*/
FUNCTION Insert_AP_Trial_Bal (
                 p_accounting_date          IN  DATE,
                 p_request_id               IN  NUMBER,
                 p_reporting_entity_id      IN  NUMBER,
                 p_org_where_alb            IN  VARCHAR2,
                 p_org_where_ael            IN  VARCHAR2,
                 p_debug_switch             IN  VARCHAR2)
                 RETURN BOOLEAN IS

  l_sql_stmt VARCHAR2(32000);

BEGIN

  fnd_file.put_line (fnd_file.log, 'Stage :016 - Into Insert_AP_Trial_Bal');

  l_sql_stmt:= 'INSERT INTO ap_trial_bal '
  || '  SELECT alb.invoice_id invoice_id, '
  || '         alb.code_combination_id code_combination_id, '
  || '         SUM (alb.accounted_cr) -  '
  || '             SUM (alb.accounted_dr) remaining_amount, '
  || '         alb.vendor_id vendor_id, '
  || '         alb.set_of_books_id set_of_books_id, '
  || '         alb.org_id org_id, '
  || '         '||p_request_id||' request_id, '
  || '         SUM(ae_invoice_amount) invoice_amount '
  || '  FROM   ap_liability_balance alb '
  || '  WHERE  trunc(accounting_date) <=  '
  || '         trunc(to_date('''||p_accounting_date||''',''YYYY/MM/DD'')) '
  ||    p_org_where_alb
  || '  GROUP BY '
  || '         alb.invoice_id, '
  || '         alb.code_combination_id, '
  || '         alb.vendor_id, '
  || '         alb.set_of_books_id, '
  || '         alb.org_id, '
  || '         '||p_request_id||' '
  || '  HAVING SUM (accounted_cr) <> SUM (accounted_dr) ';

  IF (p_debug_switch IN ('y','Y')) THEN
     fnd_file.put_line(fnd_file.log,l_sql_stmt);
  END IF;

  EXECUTE IMMEDIATE l_sql_stmt;

  RETURN TRUE;

EXCEPTION

  WHEN OTHERS THEN

    fnd_file.put_line(fnd_file.log,'Error Occured in Insert_AP_Trial_Bal'
                                   ||' Function.');
      IF (p_debug_switch IN ('y','Y')) THEN
         fnd_file.put_line(fnd_file.log,l_sql_stmt);
      END IF;
    fnd_file.put_line(fnd_file.log,'Error Code: '||to_char(SQLCODE));
    fnd_file.put_line(fnd_file.log,'Error Message: '||SQLERRM);

    RETURN FALSE;

END Insert_AP_Trial_Bal;

/*=============================================================================
Insert_AP_Trial_Bal Function is an overloaded function. Same as the previous
function. But this will be called only if the p_from_date is provided.

=============================================================================*/
FUNCTION Insert_AP_Trial_Bal (
                 p_accounting_date          IN  DATE,
                 p_from_date                IN  DATE,
                 p_request_id               IN  NUMBER,
                 p_reporting_entity_id      IN  NUMBER,
                 p_org_where_alb            IN  VARCHAR2,
                 p_org_where_ael            IN  VARCHAR2,
                 p_debug_switch             IN  VARCHAR2)
                 RETURN BOOLEAN IS

  l_sql_stmt VARCHAR2(32000);

BEGIN

  fnd_file.put_line (fnd_file.log, 'Stage :017 - Into Insert_AP_Trial_Bal');

  l_sql_stmt := 'INSERT INTO ap_trial_bal '
  || '  SELECT alb.invoice_id invoice_id, '
  || '         alb.code_combination_id code_combination_id, '
  || '         SUM (alb.accounted_cr) -  '
  || '         SUM (alb.accounted_dr) remaining_amount, '
  || '         alb.vendor_id vendor_id, '
  || '         alb.set_of_books_id set_of_books_id, '
  || '         alb.org_id org_id, '
  || '         '||p_request_id||' request_id, '
  || '         SUM(ae_invoice_amount) invoice_amount '
  || '  FROM   ap_liability_balance alb, '
  || '         ap_invoices_all ai '
  || '  WHERE  ai.invoice_id = alb.invoice_id '
  || '  AND    trunc(alb.accounting_date) <=  '
  || '         trunc(to_date('''||p_accounting_date||''',''YYYY/MM/DD'')) '
  || '  AND    ai.invoice_date >= to_date('''||p_from_date||''',''YYYY/MM/DD'')   '
  ||    p_org_where_alb
  || '  GROUP BY '
  || '         alb.invoice_id, '
  || '         alb.code_combination_id, '
  || '         alb.vendor_id, '
  || '         alb.set_of_books_id, '
  || '         alb.org_id, '
  || '         '||p_request_id||' '
  || '  HAVING SUM (accounted_cr) <> SUM (accounted_dr) ';

  IF (p_debug_switch IN ('y','Y')) THEN
     fnd_file.put_line(fnd_file.log,l_sql_stmt);
  END IF;

  EXECUTE IMMEDIATE l_sql_stmt;

  RETURN TRUE;


EXCEPTION

  WHEN OTHERS THEN

    fnd_file.put_line(fnd_file.log,'Error Occured in Insert_AP_Trial_Bal'
                                   ||' Function.');
    IF (p_debug_switch IN ('y','Y')) THEN
       fnd_file.put_line(fnd_file.log,l_sql_stmt);
    END IF;
    fnd_file.put_line(fnd_file.log,'Error Code: '||to_char(SQLCODE));
    fnd_file.put_line(fnd_file.log,'Error Message: '||SQLERRM);
    RETURN FALSE;

END Insert_AP_Trial_Bal;

/*=============================================================================
Insert_Future_Dated Function is an overloaded function. Based on the
p_from_date option either of the function will be called. This function returns
TRUE on success and FALSE on any errors.

This procedure inserts records into AP_TRIAL_BAL table for a given org_id or
for set of orgs as per the parameter for AP and AX set of books. This inserts
invoices that have not been fully paid on or before for a given as of date
associated to the future dated payments.

Note:
=====
1) Trial Balance will report based on AP accounting data for all pre 11i
transactions irrespective of customers using AX or AP. For Post 11i trial
balance will report based on the accounting information from either AX or AP
as it is being used.

The UNION SELECT is written to handle the same requirement.

=============================================================================*/


FUNCTION Insert_Future_Dated (
                 p_accounting_date          IN  DATE,
                 p_request_id               IN  NUMBER,
                 p_reporting_entity_id      IN  NUMBER,
                 p_org_where_ael            IN  VARCHAR2,
                 p_debug_switch             IN  VARCHAR2)
                 RETURN BOOLEAN IS

  l_sql_stmt              VARCHAR2(32000);
  l_sql_stmt_1            VARCHAR2(32000);

BEGIN

  fnd_file.put_line (fnd_file.log, 'Stage :018 - Into Insert_Future_Dated');
  fnd_file.put_line (fnd_file.log, 'Stage :019 - Gain Loss At Payment '
                                   ||'Line Level');

  l_sql_stmt_1 := 'INSERT INTO ap_trial_bal  '
  || '(( '
  || '  SELECT /*+ full(aeh)  '
  || '         parallel(aeh,DEFAULT) '
  || '         parallel(ael,DEFAULT) '
  || '         use_hash(aeh,ael) */ '
  || '         ai.invoice_id invoice_id, '
  || '         ael.code_combination_id code_combination_id, '
  || '         SUM(NVL(ael.accounted_cr,0)) -  '
  || '         SUM(NVL(ael.accounted_dr,0)) remaining_amount, '
  || '         ael.third_party_id vendor_id, '
  || '         aeh.set_of_books_id set_of_books_id, '
  || '         ael.org_id org_id, '
  || '         '||p_request_id||' request_id, '
  || '         Ap_Trial_Balance_Pkg.Get_Invoice_Amount ( '
  || '                              aeh.set_of_books_id, '
  || '                              ai.invoice_id, '
  || '                              ai.invoice_amount, '
  || '                              NVL(ai.exchange_rate,1)) invoice_amount '
  || '  FROM   ap_ae_lines_all ael, '
  || '         ap_ae_headers_all aeh, '
  || '         ap_invoice_payments_all aip, '
  || '         ap_invoices_all ai, '
  || '         ap_system_parameters_all asp '
  || '  WHERE  ael.ae_line_type_code = ''FUTURE PAYMENT'' '
  || '  AND    ael.ae_header_id = aeh.ae_header_id '
  || '  AND    aeh.gl_transfer_flag = ''Y'' '
  || '  AND    trunc(aeh.accounting_date) <=  '
  || '         trunc(to_date('''||p_accounting_date||''',''YYYY/MM/DD'')) '
  || '  AND    ael.source_table = ''AP_INVOICE_PAYMENTS'' '
  || '  AND    ael.source_id = aip.invoice_payment_id '
  || '  AND    aip.invoice_id = ai.invoice_id '
  || '  AND    nvl(ael.org_id,-99) = nvl(asp.org_id,-99) '
  || '  AND    asp.future_dated_pmt_liab_relief = ''MATURITY'' '
  ||    p_org_where_ael
  || '  GROUP BY  '
  || '         ai.invoice_id, '
  || '         ael.code_combination_id, '
  || '         ael.third_party_id, '
  || '         aeh.set_of_books_id, '
  || '         ael.org_id, '
  || '         '||p_request_id||', '
  || '         Ap_Trial_Balance_Pkg.Get_Invoice_Amount ( '
  || '                              aeh.set_of_books_id, '
  || '                              ai.invoice_id, '
  || '                              ai.invoice_amount, '
  || '                              NVL(ai.exchange_rate,1)) '
  || '  HAVING SUM(NVL(ael.accounted_cr,0)) <> SUM(NVL(ael.accounted_dr,0))  '
  || ' ) '
  || ' UNION '
  || ' ( '
  || '  SELECT ai.invoice_id invoice_id, '
  || '         ael.code_combination_id code_combination_id, '
  || '         SUM(NVL(ael.accounted_cr,0)) -  '
  || '         SUM(NVL(ael.accounted_dr,0)) remaining_amount, '
  || '         ai.vendor_id vendor_id, '
  || '         aeh.set_of_books_id set_of_books_id, '
  || '         ael.org_id org_id, '
  || '         '||p_request_id||' request_id, '
  || '         Ap_Trial_Balance_Pkg.Get_Invoice_Amount ( '
  || '                              aeh.set_of_books_id, '
  || '                              ai.invoice_id, '
  || '                              ai.invoice_amount, '
  || '                              NVL(ai.exchange_rate,1)) invoice_amount '
  || '  FROM   ax_ap_ae_lines_all_v ael, '
  || '         ax_ap_ae_headers_all_v aeh, '
  || '         ap_invoice_payments_all aip, '
  || '         ap_invoices_all ai, '
  || '         ap_system_parameters_all asp '
  || '  WHERE  ael.ae_line_type_code = ''FUTURE PAYMENT'' '
  || '  AND    ael.set_of_books_id = aeh.set_of_books_id '
  || '  AND    ael.journal_sequence_id = aeh.journal_sequence_id '
  || '  AND    ael.ae_header_id = aeh.ae_header_id '
  || '  AND    aeh.gl_transfer_flag = ''Y'' '
  || '  AND    aeh.accounting_date <= to_date('''||p_accounting_date||''',''YYYY/MM/DD'') '
  || '  AND    ael.last_updated_by <> -6672 '
  || '  AND    ael.source_table = ''AP_INVOICE_PAYMENTS'' '
  || '  AND    ael.source_id = aip.invoice_payment_id '
  || '  AND    aip.invoice_id = ai.invoice_id '
  || '  AND    nvl(ael.org_id,-99) = nvl(asp.org_id,-99) '
  || '  AND    asp.future_dated_pmt_liab_relief = ''MATURITY'' '
  ||    p_org_where_ael
  || '  GROUP BY  '
  || '         ai.invoice_id, '
  || '         ael.code_combination_id, '
  || '         ai.vendor_id, '
  || '         aeh.set_of_books_id, '
  || '         ael.org_id, '
  || '         '||p_request_id||', '
  || '         Ap_Trial_Balance_Pkg.Get_Invoice_Amount ( '
  || '                              aeh.set_of_books_id, '
  || '                              ai.invoice_id, '
  || '                              ai.invoice_amount, '
  || '                              NVL(ai.exchange_rate,1)) '
  || '  HAVING SUM(NVL(ael.accounted_cr,0)) <> SUM(NVL(ael.accounted_dr,0))   '
  || ' ) '
  || ') ';

  IF (p_debug_switch IN ('y','Y')) THEN
     fnd_file.put_line(fnd_file.log,l_sql_stmt_1);
  END IF;

  EXECUTE IMMEDIATE l_sql_stmt_1;

  RETURN TRUE;

EXCEPTION

  WHEN OTHERS THEN

    fnd_file.put_line(fnd_file.log,'Error Occured in Insert_Future_Dated'
                                   ||' Function.');
    IF (p_debug_switch IN ('y','Y')) THEN
       fnd_file.put_line(fnd_file.log,l_sql_stmt);
       fnd_file.put_line(fnd_file.log,l_sql_stmt_1);
    END IF;
    fnd_file.put_line(fnd_file.log,'Error Code: '||to_char(SQLCODE));
    fnd_file.put_line(fnd_file.log,'Error Message: '||SQLERRM);
    RETURN FALSE;

END Insert_Future_Dated;

/*=============================================================================
Insert_Future_Dated Function is an overloaded function.  This function
will be called when the p_from_date is provided. The functionality remains the
same as mentioned in the Insert_Future_Dated function1 above.

=============================================================================*/


FUNCTION Insert_Future_Dated (
                 p_accounting_date          IN  DATE,
                 p_from_date                IN  DATE,
                 p_request_id               IN  NUMBER,
                 p_reporting_entity_id      IN  NUMBER,
                 p_org_where_ael            IN  VARCHAR2,
                 p_debug_switch             IN  VARCHAR2)
                 RETURN BOOLEAN IS

  l_sql_stmt     VARCHAR2(32000);
  l_sql_stmt_1   VARCHAR2(32000);

BEGIN

  fnd_file.put_line (fnd_file.log, 'Stage :020 - Into Insert_Future_Dated');
  fnd_file.put_line (fnd_file.log, 'Stage :021 - Gain Loss At Payment '
                                   ||'Line Level');
  l_sql_stmt_1 := 'INSERT INTO ap_trial_bal  '
  || '(( '
  || '  SELECT /*+ full(aeh)  '
  || '         parallel(aeh,DEFAULT) '
  || '         parallel(ael,DEFAULT) '
  || '         use_hash(aeh,ael) */ '
  || '         ai.invoice_id invoice_id, '
  || '         ael.code_combination_id code_combination_id, '
  || '         SUM(NVL(ael.accounted_cr,0)) -  '
  || '         SUM(NVL(ael.accounted_dr,0)) remaining_amount, '
  || '         ael.third_party_id vendor_id, '
  || '         aeh.set_of_books_id set_of_books_id, '
  || '         ael.org_id org_id, '
  || '         '||p_request_id||' request_id, '
  || '         Ap_Trial_Balance_Pkg.Get_Invoice_Amount ( '
  || '                              aeh.set_of_books_id, '
  || '                              ai.invoice_id, '
  || '                              ai.invoice_amount, '
  || '                              NVL(ai.exchange_rate,1)) invoice_amount '
  || '  FROM   ap_ae_lines_all ael, '
  || '         ap_ae_headers_all aeh, '
  || '         ap_invoice_payments_all aip, '
  || '         ap_invoices_all ai, '
  || '         ap_system_parameters_all asp '
  || '  WHERE  ael.ae_line_type_code = ''FUTURE PAYMENT'' '
  || '  AND    ai.invoice_date >= to_date('''||p_from_date||''',''YYYY/MM/DD'')   '
  || '  AND    ael.ae_header_id = aeh.ae_header_id '
  || '  AND    aeh.gl_transfer_flag = ''Y'' '
  || '  AND    trunc(aeh.accounting_date) <=  '
  || '         trunc(to_date('''||p_accounting_date||''',''YYYY/MM/DD'')) '
  || '  AND    ael.source_table = ''AP_INVOICE_PAYMENTS'' '
  || '  AND    ael.source_id = aip.invoice_payment_id '
  || '  AND    aip.invoice_id = ai.invoice_id '
  || '  AND    nvl(ael.org_id,-99) = nvl(asp.org_id,-99) '
  || '  AND    asp.future_dated_pmt_liab_relief = ''MATURITY'' '
  ||    p_org_where_ael
  || '  GROUP BY  '
  || '         ai.invoice_id, '
  || '         ael.code_combination_id, '
  || '         ael.third_party_id, '
  || '         aeh.set_of_books_id, '
  || '         ael.org_id, '
  || '         '||p_request_id||', '
  || '         Ap_Trial_Balance_Pkg.Get_Invoice_Amount ( '
  || '                              aeh.set_of_books_id, '
  || '                              ai.invoice_id, '
  || '                              ai.invoice_amount, '
  || '                              NVL(ai.exchange_rate,1)) '
  || '  HAVING SUM(NVL(ael.accounted_cr,0)) <> SUM(NVL(ael.accounted_dr,0))  '
  || ' ) '
  || ' UNION '
  || ' ( '
  || '  SELECT ai.invoice_id invoice_id, '
  || '         ael.code_combination_id code_combination_id, '
  || '         SUM(NVL(ael.accounted_cr,0)) -  '
  || '         SUM(NVL(ael.accounted_dr,0)) remaining_amount, '
  || '         ai.vendor_id vendor_id, '
  || '         aeh.set_of_books_id set_of_books_id, '
  || '         ael.org_id org_id, '
  || '         '||p_request_id||' request_id, '
  || '         Ap_Trial_Balance_Pkg.Get_Invoice_Amount ( '
  || '                              aeh.set_of_books_id, '
  || '                              ai.invoice_id, '
  || '                              ai.invoice_amount, '
  || '                              NVL(ai.exchange_rate,1)) invoice_amount '
  || '  FROM   ax_ap_ae_lines_all_v ael, '
  || '         ax_ap_ae_headers_all_v aeh, '
  || '         ap_invoice_payments_all aip, '
  || '         ap_invoices_all ai, '
  || '         ap_system_parameters_all asp '
  || '  WHERE  ael.ae_line_type_code = ''FUTURE PAYMENT'' '
  || '  AND    ai.invoice_date >= to_date('''||p_from_date||''',''YYYY/MM/DD'')   '
  || '  AND    ael.set_of_books_id = aeh.set_of_books_id '
  || '  AND    ael.journal_sequence_id = aeh.journal_sequence_id '
  || '  AND    ael.ae_header_id = aeh.ae_header_id '
  || '  AND    aeh.gl_transfer_flag = ''Y'' '
  || '  AND    aeh.accounting_date <= to_date('''||p_accounting_date||''',''YYYY/MM/DD'') '
  || '  AND    ael.last_updated_by <> -6672 '
  || '  AND    ael.source_table = ''AP_INVOICE_PAYMENTS'' '
  || '  AND    ael.source_id = aip.invoice_payment_id '
  || '  AND    aip.invoice_id = ai.invoice_id '
  || '  AND    nvl(ael.org_id,-99) = nvl(asp.org_id,-99) '
  || '  AND    asp.future_dated_pmt_liab_relief = ''MATURITY'' '
  ||    p_org_where_ael
  || '  GROUP BY  '
  || '         ai.invoice_id, '
  || '         ael.code_combination_id, '
  || '         ai.vendor_id, '
  || '         aeh.set_of_books_id, '
  || '         ael.org_id, '
  || '         '||p_request_id||', '
  || '         Ap_Trial_Balance_Pkg.Get_Invoice_Amount ( '
  || '                              aeh.set_of_books_id, '
  || '                              ai.invoice_id, '
  || '                              ai.invoice_amount, '
  || '                              NVL(ai.exchange_rate,1)) '
  || '  HAVING SUM(NVL(ael.accounted_cr,0)) <> SUM(NVL(ael.accounted_dr,0))   '
  || ' ) '
  || ') ';

  IF (p_debug_switch IN ('y','Y')) THEN
     fnd_file.put_line(fnd_file.log,l_sql_stmt_1);
  END IF;

  EXECUTE IMMEDIATE l_sql_stmt_1;

  RETURN TRUE;

EXCEPTION

  WHEN OTHERS THEN

    fnd_file.put_line(fnd_file.log,'Error Occured in Insert_Future_Dated'
                                   ||' Function.');
    IF (p_debug_switch IN ('y','Y')) THEN
       fnd_file.put_line(fnd_file.log,l_sql_stmt);
       fnd_file.put_line(fnd_file.log,l_sql_stmt_1);
    END IF;
    fnd_file.put_line(fnd_file.log,'Error Code: '||to_char(SQLCODE));
    fnd_file.put_line(fnd_file.log,'Error Message: '||SQLERRM);
    RETURN FALSE;

END Insert_Future_Dated;

/*=============================================================================
Process_Neg_Bal function - This function is used to get rid of the records
that add to a possitive balance in the AP_TRIAL_BAL table. So that when the
trial balance select statement gets executed will report only on the negative
balances only. This was an added feature to the trial balance report to replace
the supplier open balance report.
=============================================================================*/


FUNCTION Process_Neg_Bal(p_request_id IN NUMBER)
                         RETURN BOOLEAN IS

BEGIN

  fnd_file.put_line (fnd_file.log, 'Stage :024 - Into Process_Neg_Bal');

  DELETE FROM ap_trial_bal
  WHERE (code_combination_id,
	 vendor_id,
	 set_of_books_id,
	 nvl(org_id,-99))  --Bug2679383 Added nvl to org_id passing -99 for
                           -- non-multi org.
         IN
	 (SELECT code_combination_id,
	         vendor_id,
	         set_of_books_id,
	         nvl(org_id,-99)  --Bug2679383 Added nvl to org_id passing -99
                                  --for non-multi org.
	  FROM   ap_trial_bal
          WHERE  request_id = p_request_id
	  GROUP BY
	         code_combination_id,
	         vendor_id,
	         set_of_books_id,
	         org_id
	  HAVING sum(remaining_amount) > 0);

  RETURN TRUE;

EXCEPTION

  WHEN OTHERS THEN

    fnd_file.put_line(fnd_file.log,'Error Occured in Process_Neg_Bal'
                                   ||' Function.');
    fnd_file.put_line(fnd_file.log,'Error Code: '||to_char(SQLCODE));
    fnd_file.put_line(fnd_file.log,'Error Message: '||SQLERRM);
    RETURN FALSE;

END Process_Neg_Bal;

/*=============================================================================
Use_Future_Dated function is used to verify for the given org or set of orgs
if there exists atleast one ORG has future_dated_pmt_liab_relief vlaue set to
MATURITY in ap_system_parameters_all. If so we should call the Insert Future
Dated payments function. The function will return TRUE if there exists atleast
one org that satisfies the requirement, else will return FALSE.

=============================================================================*/


FUNCTION Use_Future_Dated (
             p_org_where_asp            IN  VARCHAR2,
             p_debug_switch             IN  VARCHAR2)
             RETURN BOOLEAN IS

  l_is_future_dated NUMBER;
  l_sql_stmt        VARCHAR2(32000);

BEGIN

  l_sql_stmt := 'SELECT COUNT(*) '
                || 'FROM   ap_system_parameters_all asp '
                || 'WHERE  asp.future_dated_pmt_liab_relief = ''MATURITY'' '
                || p_org_where_asp;

  IF (p_debug_switch IN ('y','Y')) THEN
     fnd_file.put_line(fnd_file.log,l_sql_stmt);
  END IF;

  EXECUTE IMMEDIATE l_sql_stmt INTO l_is_future_dated;

  IF l_is_future_dated <> 0 THEN
     RETURN TRUE;
  ELSE
     RETURN FALSE;
  END IF;

EXCEPTION

  WHEN OTHERS THEN

    fnd_file.put_line(fnd_file.log,'Error Occured in Use_Future_Dated'
                                   ||' Function.');
    IF (p_debug_switch IN ('y','Y')) THEN
       fnd_file.put_line(fnd_file.log,l_sql_stmt);
    END IF;
    fnd_file.put_line(fnd_file.log,'Error Code: '||to_char(SQLCODE));
    fnd_file.put_line(fnd_file.log,'Error Message: '||SQLERRM);

END Use_Future_Dated;

/*=============================================================================
Insert_AP_Liability_Balance function is used to populate the
AP_LIABILITY_BALANCE table. This will be called from the APXGLTRN.rdf report
after the GL transfer has been completed successfully.

It takes the following arguments:

p_request_id          - Concurrent Request ID
p_user_id             - Application User ID
p_resp_appl_id        - Application ID
p_login_id            - Last Update Login ID
p_program_id          - Concurrent Program ID
p_program_appl_id     - Concurrent Program Application ID.

Logic:
======

1) For a given request_id the function first determines the list of
   gl_transfer_run_id from xla_gl_transfer_batches_all.
2) Inserts the AP_LIABILITY_BALANCE with the denormalized information
   from ap_ae_lines_all and ap_ae_headers_all for a given gl_transfer_run_id.
3) Calls the Update trial_balance_flag of ap_ae_headers_all for the same
   gl_transfer_run_id, so that we can make sure that accounting entry
   lines of type LIABILITY associsted with the header record have been
   transferred to the AP_LIABILITY_BALANCE table.

Bug Fixes:

     Bug 2284841
     Bug 2319648 - Prepayment Application Case, Standard Invoice is
                   not displayed with the right invoice_amount.
=============================================================================*/

FUNCTION Insert_AP_Liability_Balance (
                 p_request_id               IN  NUMBER,
                 p_user_id                  IN  NUMBER,
                 p_resp_appl_id             IN  NUMBER,
                 p_login_id                 IN  NUMBER,
                 p_program_id               IN  NUMBER,
                 p_program_appl_id          IN  NUMBER)
                 RETURN BOOLEAN IS

  -- Bug 2284841 Code Modified by MSWAMINA.

  CURSOR transfer_info IS
  SELECT DISTINCT (xgt.gl_transfer_run_id)
  FROM   xla_gl_transfer_batches_all xgt,
         ap_ae_headers_all aeh
  WHERE  xgt.gl_transfer_run_id = aeh.gl_transfer_run_id
  AND    xgt.request_id = p_request_id
  AND    nvl(aeh.trial_balance_flag,'N') = 'N';

  l_gl_transfer_run_id  xla_gl_transfer_batches_all.gl_transfer_run_id%TYPE;

BEGIN

  fnd_file.put_line(fnd_file.log,'Into Insert_AP_Liability_Balance Procedure');

  fnd_file.put_line(fnd_file.log,'Open transfer_info cursor');

  OPEN transfer_info;

  LOOP

    FETCH transfer_info INTO l_gl_transfer_run_id;
    EXIT WHEN transfer_info%NOTFOUND;

    fnd_file.put_line(fnd_file.log,'Insert ap_liability_balance for every'
                                 ||'gl_transfer_run_id');

    fnd_file.put_line(fnd_file.log,'Processing gl_transfer_run_id : '
                                   ||l_gl_transfer_run_id);

    INSERT INTO ap_liability_balance
    (ae_line_id,
     ae_header_id,
     invoice_id,
     code_combination_id,
     vendor_id,
     vendor_site_id,
     set_of_books_id,
     org_id,
     accounting_date,
     accounted_dr,
     accounted_cr,
     ae_invoice_amount,
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login,
     program_update_date,
     program_application_id,
     program_id,
     request_id)
    (
      SELECT
              ael.ae_line_id ae_line_id,
              ael.ae_header_id ae_header_id,
              to_number(NVL(ael.reference2,0)) invoice_id,
              ael.code_combination_id code_combination_id,
              ael.third_party_id vendor_id,
              ael.third_party_sub_id vendor_site_id,
              aeh.set_of_books_id set_of_books_id,
              ael.org_id org_id,
              aeh.accounting_date accounting_date,
              NVL(ael.accounted_dr,0) accounted_dr,
              NVL(ael.accounted_cr,0) accounted_cr,
              -- Bug 2319648
              DECODE(aae.event_type_code,
                     'PREPAYMENT APPLICATION',
                     0,
                     'PREPAYMENT UNAPPLICATION',
                     0,
                     DECODE(ael.source_table,
                     'AP_INVOICES',              (NVL(ael.accounted_cr,0) -
                                                  NVL(ael.accounted_dr,0)),
                     'AP_INVOICE_DISTRIBUTIONS', (NVL(ael.accounted_cr,0) -
                                                  NVL(ael.accounted_dr,0)),
                     0)),
              SYSDATE,
              p_user_id,
              SYSDATE,
              p_user_id,
              p_login_id,
              SYSDATE,
              p_program_appl_id,
              p_program_id,
              p_request_id
      FROM    ap_ae_headers_all aeh,
              ap_ae_lines_all   ael,
              ap_accounting_events_all aae
      WHERE   aae.accounting_event_id = aeh.accounting_event_id
      AND     aeh.ae_header_id = ael.ae_header_id
      AND     ael.ae_line_type_code = 'LIABILITY'
      AND     aeh.gl_transfer_flag = 'Y'
      AND     aeh.gl_transfer_run_id = l_gl_transfer_run_id
    );

    fnd_file.put_line(fnd_file.log,'Update AE Headers trial_balance_flag');

    IF (Update_Trial_Balance_Flag (l_gl_transfer_run_id) <> TRUE) THEN

       RETURN FALSE;

    END IF;

    fnd_file.put_line(fnd_file.log,'Processed gl_transfer_run_id : '
                                     ||l_gl_transfer_run_id);

  END LOOP;

  fnd_file.put_line(fnd_file.log,'Close transfer_info cursor');

  CLOSE transfer_info;

  RETURN (TRUE);

EXCEPTION

  WHEN OTHERS THEN

    fnd_file.put_line(fnd_file.log,'Error Occured in '
                                   ||'Insert_AP_Liability_Balance '
                                   ||'Procedure');
    fnd_file.put_line(fnd_file.log,  'Error Code: '||SQLCODE);
    fnd_file.put_line(fnd_file.log,  'Error Message: '|| SQLERRM);

    IF transfer_info%ISOPEN THEN
       CLOSE transfer_info;
    END IF;

    RETURN (FALSE);


END Insert_AP_Liability_Balance;

/*=============================================================================
Update_Trial_Balance_Flag Function - is a local function called by the
Insert_AP_Liability_Balance to update the ap_ae_header_all trial_balance_flag
. This flag represents the accounting entry lines of type LIABILTIY have been
successfully inserted for a header record to the AP_LIABILTY_BALANCE table.
=============================================================================*/


FUNCTION Update_Trial_Balance_Flag (
                 p_gl_transfer_run_id       IN  NUMBER)
                 RETURN BOOLEAN IS

BEGIN

  fnd_file.put_line(fnd_file.log, 'Into Update_Trial_Balance_Flag Procedure');
  fnd_file.put_line(fnd_file.log, 'Updating AE Headers for '
                                  ||p_gl_transfer_run_id);

  UPDATE ap_ae_headers_all
  SET    trial_balance_flag = 'Y'
  WHERE  gl_transfer_run_id = p_gl_transfer_run_id;

  RETURN TRUE;


EXCEPTION

  WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.log, 'Error Occured in Update_Trial_Balance_Flag'
                                    ||' Procedure while processing '
                                    ||' the following gl_transfer_run_id: '
                                    || p_gl_transfer_run_id);
    fnd_file.put_line(fnd_file.log,  'Error Code: '||SQLCODE);
    fnd_file.put_line(fnd_file.log,  'Error Message: '|| SQLERRM);
    RETURN FALSE;

END Update_Trial_Balance_Flag;

/*=============================================================================
Is_Reporting_Books Function is used to identify whether the given set of books
ID is a reporting set of books or not. If yes this function will return TRUE.
else will return FALSE.

This is a local function used by the Get_Invoice_Amount function.

It takes the following Parameters:
p_set_of_books_id         - Set of Books identifier.
=============================================================================*/


FUNCTION Is_Reporting_Books (
                p_set_of_books_id           IN NUMBER)
                RETURN BOOLEAN IS

  l_set_of_books_type gl_sets_of_books.mrc_sob_type_code%TYPE;

BEGIN

  SELECT mrc_sob_type_code
  INTO   l_set_of_books_type
  FROM   gl_sets_of_books
  WHERE  set_of_books_id = p_set_of_books_id;

  IF l_set_of_books_type = 'R' THEN
     RETURN TRUE;
  ELSE
     RETURN FALSE;
  END IF;

EXCEPTION

WHEN OTHERS THEN
  RETURN FALSE;

END Is_Reporting_Books;

/*=============================================================================
Get_Base_Currency_Code function is used to get the base currency code for a
given set of books id.

This is a local function used by the Get_Invoice_Amount function.

It takes the following Parameters:
p_set_of_books_id         - Set of Books identifier.
=============================================================================*/


FUNCTION Get_Base_Currency_Code (
                p_set_of_books_id           IN NUMBER)
                RETURN VARCHAR2 IS

  l_currency_code ap_system_parameters_all.base_currency_code%TYPE;

BEGIN

  SELECT base_currency_code
  INTO   l_currency_code
  FROM   ap_system_parameters_all
  WHERE  set_of_books_id = p_set_of_books_id;

  RETURN l_currency_code;

EXCEPTION

WHEN OTHERS THEN
  l_currency_code := '';
  RETURN l_currency_code;

END Get_Base_Currency_Code;

/*=============================================================================
Get_Invoice_Amount is the function added in sync with resolving the issue
with Trial balance report not displaying the Invoice_amount in the funcitonal
currency with the right proportion when customer uses automatic offsets.

As a part of enhancement to the trial balance we have added new column named
ae_invoice_amount in the AP_LIABILITY_BALANCE table. This will store the
invoice amount in the functional currency (for the appropriate set of books
includes MRC books as trial balance reports on MRC books as well) from the
accounting tables, not only at the invoice level but also at the CCID (Liability)
within the invoice. But the same cannot be directly applied in couple of cases
like
1) As of now AX does not populate the AP_LIABILITY_BALANCE table. So we will
   not be able to derive the amounts per liability CCID within an
   Invoice for AX. So we will substitute the Actual invoice_amount in functional
   currency using this API.

2) For the Future dated payments the decision to report them in trial balance
   is driven completely based on the payments and not much based on the invoice.
   So based on the discussion (Omar and Lauren) , we will again report the
   invoice_amount in functional currency.

This Function will be called in all the Insert statements except the one that
gets the information from AP_LIABILITY_BALANCE table.

It takes the following Arguments:

p_set_of_books_id        - Set of Books Identifier.
p_invoice_id             - Invoice Identifier
p_invoice_amount         - Invoice Amount in the Entered Currency
p_exchange_rate          - Exchange rate on the Invoice.

Logic:
======

1) Verify the set of books ID mentioned is a reporting SOBs.
2) If reporting then
   2.1) Call the MRC API to get the Base amount for the Invoice. As the base
        amount has to be in the Reporting books currency.
3) Else
   3.1) Calculate the Base amount using the entered invoice_amount and
        the exchange rate.
4) Return this amount to the Insert statement.

Note:
=====

If an error happen in any of these APIs due to any reason we will not abort the
report. We will return the original invoice amount back.
=============================================================================*/

FUNCTION Get_Invoice_Amount (
                p_set_of_books_id           IN NUMBER,
                p_invoice_id                IN NUMBER,
                p_invoice_amount            IN NUMBER,
                p_exchange_rate             IN NUMBER)
                RETURN NUMBER IS

  l_invoice_amount NUMBER;
  l_table_name     VARCHAR2(30) := 'AP_INVOICES';
  l_req_info       VARCHAR2(30) := 'BASE_AMOUNT';
  l_currency_code  ap_system_parameters_all.base_currency_code%TYPE;

BEGIN

  IF Is_Reporting_Books(p_set_of_books_id) = TRUE THEN

     l_invoice_amount := GL_MC_INFO.Get_Acctd_Amount(p_invoice_id,
                                                     p_set_of_books_id,
                                                     l_table_name,
                                                     l_req_info);

  ELSE

     l_currency_code := Get_Base_Currency_Code(p_set_of_books_id);

     l_invoice_amount :=  AP_UTILITIES_PKG.Ap_Round_Currency
                                          ((p_invoice_amount *
                                            p_exchange_rate),
                                            l_currency_code);
  END IF;

  RETURN l_invoice_amount;

EXCEPTION
  WHEN OTHERS THEN
    l_invoice_amount := p_invoice_amount;
    RETURN l_invoice_amount;

END Get_Invoice_Amount;




END AP_TRIAL_BALANCE_PKG;

/
