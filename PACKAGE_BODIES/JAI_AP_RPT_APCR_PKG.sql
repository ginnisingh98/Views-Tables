--------------------------------------------------------
--  DDL for Package Body JAI_AP_RPT_APCR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AP_RPT_APCR_PKG" 
/* $Header: jai_ap_rpt_apcr.plb 120.4.12010000.7 2009/05/28 10:18:00 vumaasha ship $ */
AS

/* --------------------------------------------------------------------------------------
Filename:

Change History:

Date         Bug         Remarks
---------    ----------  -------------------------------------------------------------
08-Jun-2005    Version 116.1 jai_ap_rpt_apcr -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
    as required for CASE COMPLAINCE.
*/
FUNCTION compute_credit_balance
(
p_bal_date            DATE,
p_vendor_id           NUMBER,
p_set_of_books_id     NUMBER,
p_vendor_site_code    VARCHAR2,
p_org_id              NUMBER ,-- added by Aparajita on 26-sep-2002 for bug # 2574262
p_currency_code       VARCHAR2 DEFAULT NULL, /* added by vumaasha for bug 8310720 */
p_accts               ap_invoices_all.accts_pay_code_combination_id%TYPE DEFAULT NULL
)
RETURN NUMBER
IS
/*------------------------------------------------------------------------------
FILENAME: jai_ap_rpt_apcr_pkg.compute_credit_balance.sql
CHANGE HISTORY:

S.No     Date           Author AND Details

1.     16/07/2002       Aparajita Das, revamped this procedure the older code is
                        commented below for bug # 2459399.version# 615.1.

                        This function is called from 'Creditor's ledger Report' for c
                        alculating opening and closing balances. The logic for the detail
                        report line was correct, but balances were getting calculated
                        wrongly in many scenarios, to tackel this issue, this procedure
                        has been redefined based on the queries of the report.

2.       26/09/2002    Aparajita for bug # 2574262. version# 615.2
                       Added the concept of org_id, as org_id was being considered at
                       line level but not balance level.
                       Added the additional parameter p_org_id.


3.       17/12/2002    Aparajita for bug # 2668999. version# 615.3

                       For debit memos the entries should come as follows.
                       - -ve entry in credit side when it has been created and approved and if paid
                         it should not be a refund type of payment.
                       - -ve entry in debit side when it has been paid.
                       Changed the query1 of the report query to add a subquery condition to check
                       for payment existance  of refund type of transactions.

4.       16/01/2003    Aparajita for bug # 2545466. Version# 615.4

                       Broke the GAIN/LOSS query in the cursor into 4 queries to take care of the
                       4 different source from which the gain loss record gets populated into
                       ap_ae_lines_all table.

                       Also removed the old code that was earlier commented at the end of this code.

                       There was inconsistancy between the logic followed in the report and this
                       function for following four fields, changed to follow
                       the report as that was correct.

                       - exchange_rate
                       - exchange_rate_type
                       - invoice_currency_code
                       - exchange_date
                       All the modifications are done in cursor C_invoices.

5.       15/07/2003    RBASKER  for Bug #2911835.   Version #616.1

                       Performance Issue: The report 'India Creditors Ledger' is running indefinitely ,
                       when it is run for all the vendors.

                        Fix:  i)The TRUNC function around the date fields suppress the use of index.
                                Removed the TRUNC function from all SELECT statments.

                             ii)In query4 Gain or Loss source AP_INVOICE_DISTRIBUTIONS,
                                 the join condition between ap_invoices_all and
                                 ap_invoice_distributions_all was missing. Corrected the same.

6.       22/01/2004    Aparajita for Bug#3392495. Version#618.1
                       Added code to reduce the invoice amount by discount amount already given.
                       Changes in cursor C_invoices Query 1.

7.      04/06/2004      Added by vchallur for bug#3663549 version 115.1

                        added code so that it can free from invoice entry need not start
                        with disribution_line_number=1

8.      03/08/2004      Aparajita for bug#2839228. Version#115.2

                        Modified cursor C_vendor_site_id to select vendor site id from po_vendor_sites_all
                        considering the operating unit also.  This was needed as vendor site code for the
                        same vendor may be same accross operating units..

9.      05/11/2004      Sanjikum for bug # 3896940, Version 115.3
                        Following changes are made in query 1 of cursor C_invoices
                        a) In the query's column Credit_val, changed the column from api.Invoice_amt to z.amt_val
                        b) In the From clause, added the inline view Z
                        c) In the where clause, added the join "z.invoice_id = api.invoice_id"

10.     05/11/2004      Sanjikum for bug # 4030311, Version 115.4
                        Following changes are made in query 1 of cursor C_invoices
                        a) In the inline view Z, added a condition - ap_invoice_distributions_all.Line_type_lookup_code <> 'PREPAY'

11.     12/01/2005      For bug4035943. Added by LGOPALSA
                        Modified the calculation for balances as per the query
            change.
            Added the accounted_dr and accounted_cr for GAIN/LOSS
            lines as they will have the correct values with respect
            to functional currency. Thus we can avoid any
            rounding errors on further calculation.
            (1) Added invoice_type_lookup_code in all the query
            (2) Changed the column selection for exchange rate in query 2
            (3) Selected zero for acct_dr except for LOSS lines
            (4) Selected accounted_dr from core accounting tables which will make the
                calculation easier and also avoids the rounding problems.
                        (5) Added the validation for 'LOSS' in calculating the credit balance.
            (6) Rounded the value to 2 decimal places as this is showing .01 while
                            displaying closing balance. We need to round it before sending the
                            values for displaying credit and debite values

12.     14-Jun-2005      rchandan for bug#4428980, Version 116.2
                        Modified the object to remove literals from DML statements and CURSORS.
       As part OF R12 Initiative Inventory conversion the OPM code is commented

13     07/12/2005   Hjujjuru for the bug 4866533 File version 120.3
                    added the who columns in the insert into table JAI_PO_REP_PRRG_T
                    Dependencies Due to this bug:-
                    None
14.  31-MAR-2009 JMEENA for bug#7689858
				Removed  discount_amount_taken from invoice amount and added with payment amount.
----------------------------------------------------------------------------------------------------------------------- */

  v_exchange_rate     NUMBER;
  v_credit_bal        NUMBER;
  v_invoice_amount    NUMBER;
  v_vendor_site_id    NUMBER;
  lv_prepayment       CONSTANT varchar2(30) := 'PREPAYMENT';   --rchandan for bug#4428980
  lv_prepay           CONSTANT varchar2(30) := 'PREPAY';   --rchandan for bug#4428980
  lv_debit            CONSTANT varchar2(30) := 'DEBIT' ; --rchandan for bug#4428980
  lv_cleared          CONSTANT varchar2(30) := 'CLEARED';--rchandan for bug#4428980
  lv_negotiable       CONSTANT varchar2(30) := 'NEGOTIABLE';--rchandan for bug#4428980
  lv_voided           CONSTANT varchar2(30) := 'VOIDED';--rchandan for bug#4428980
  lv_rec_unacc        CONSTANT varchar2(30) := 'RECONCILED UNACCOUNTED';--rchandan for bug#4428980
  lv_reconciled       CONSTANT varchar2(30) := 'RECONCILED';--rchandan for bug#4428980
  lv_cleared_unacc    CONSTANT varchar2(30) := 'CLEARED BUT UNACCOUNTED';--rchandan for bug#4428980
  lv_ap_checks                  CONSTANT varchar2(30) := 'AP_CHECKS';              --rchandan for bug#4428980
  lv_ap_invoices                CONSTANT varchar2(30) := 'AP_INVOICES';              --rchandan for bug#4428980
  lv_ap_invoice_distributions   CONSTANT varchar2(30) := 'AP_INVOICE_DISTRIBUTIONS';              --rchandan for bug#4428980
  lv_ap_invoice_payments        CONSTANT varchar2(30) := 'AP_INVOICE_PAYMENTS';              --rchandan for bug#4428980

  -- Bug 4997569. Added by Lakshmi Gopalsami
  lv_inv_entity_code  CONSTANT varchar2(30) := 'AP_INVOICES';
  lv_pay_entity_code  CONSTANT varchar2(30) := 'AP_PAYMENTS';

  CURSOR C_invoices( p_gain ap_ae_lines_all.ae_line_type_code%TYPE,p_loss ap_ae_lines_all.ae_line_type_code%TYPE )  IS
    -- query 1
    --Removed discount_amount_taken from amount for the bug#7689858
  SELECT api.invoice_type_lookup_code,
         DECODE(api.invoice_type_lookup_code,
                'CREDIT',
                0,
                z.amt_val
                ) credit_val,
          0 acct_cr,
          api.exchange_rate exchange_rate,
          api.exchange_rate_type exchange_rate_type,
          api.invoice_currency_code invoice_currency_code,
          api.exchange_date exchange_date
  FROM    ap_invoices_all api,
          ap_invoice_distributions_all apd,
          (SELECT NVL(SUM(apd.amount),0) amt_val,
                  api.invoice_id
          FROM    ap_invoices_all api,
                  ap_invoice_distributions_all apd
          WHERE   api.invoice_id = apd.invoice_id
          AND     api.invoice_type_lookup_code <> lv_prepayment  --rchandan for bug#4428980
          AND     apd.match_status_flag = 'A'
          AND     api.vendor_id = p_vendor_id
          AND     api.vendor_site_id = v_vendor_site_id
          AND     apd.accounting_date < p_bal_date
          AND     (api.org_id = p_org_id or api.org_id  is null)
          AND     apd.line_type_lookup_code <> lv_prepay
          GROUP BY api.invoice_id) z
  WHERE   z.invoice_id = api.invoice_id
  AND     api.invoice_id = apd.invoice_id
  AND     apd.rowid = (select rowid
                      from    ap_invoice_distributions_all
                      where   rownum=1
                      and     invoice_id=apd.invoice_id
                      AND     match_status_flag = 'A'
                      AND     accounting_date < p_bal_date)
  AND     api.invoice_type_lookup_code <> lv_prepayment  --rchandan for bug#4428980
  AND     apd.match_status_flag = 'A'
  AND     api.vendor_id = p_vendor_id
  AND     api.vendor_site_id = v_vendor_site_id
  AND     apd.accounting_date < p_bal_date
  AND     (api.org_id = p_org_id or api.org_id  is null)
  AND     ((api.invoice_type_lookup_code  <> lv_debit)--rchandan for bug#4428980
           or
           (
             (api.invoice_type_lookup_code  = lv_debit)  --rchandan for bug#4428980
              and
             ( not exists
                          (Select '1'
                           from   ap_invoice_payments_all  app,
                                  ap_checks_all apc
                           where  app.check_id = apc.check_id
                           and    app.invoice_id = api.invoice_id
                           and    apc.payment_type_flag = 'R'
                           )
             )
           )
        )
  AND api.invoice_currency_code =nvl( p_currency_code,api.invoice_currency_code)  /* Added by vumaasha for bug 8310720 */
  AND api.accts_pay_code_combination_id = nvl(p_accts,api.accts_pay_code_combination_id) /* Added by vumaasha for bug 8310720 */

  UNION  ALL
  -- query 2
  --Added discount_amount_taken in the amount for the bug#7689858
  SELECT api.invoice_type_lookup_code,
         DECODE(api.invoice_type_lookup_code,'CREDIT',
             DECODE(status_lookup_code,'VOIDED',
                 app.amount+ nvl(discount_amount_taken, 0) , ABS(app.amount)+ abs(nvl(discount_amount_taken, 0)) ), 0)  credit_val,
          0 acct_cr,
         apc.exchange_rate exchange_rate,
     apc.exchange_rate_type exchange_rate_type,
         api.payment_currency_code invoice_currency_code,
     apc.exchange_date exchange_date
  FROM   ap_invoices_all api,
         --ap_invoice_distributions_all apd,Commented by nprashar for bug 8307469
         ap_invoice_payments_all app,
         ap_checks_all apc
  WHERE  /*api.invoice_id = apd.invoice_id
  AND    apd.distribution_line_number = (select distribution_line_number from ap_invoice_distributions_all
                                         where rownum=1
                                         and invoice_id=apd.invoice_id
                                         AND    apd.match_status_flag='A') Commented by nprashar for bug 8307469

  AND */   app.invoice_id = api.invoice_id
  AND    app.check_id = apc.check_id
  AND    apc.status_lookup_code IN (lv_cleared,lv_negotiable,lv_voided,lv_rec_unacc,lv_reconciled,lv_cleared_unacc )  --rchandan for bug#4428980
  --AND    apd.match_status_flag='A' Commented by nprashar for bug 8307469
  AND    api.vendor_id = p_vendor_id
  AND    api.vendor_site_id = v_vendor_site_id
  AND    app.accounting_date  < trunc(p_bal_date)
  AND    ( api.org_id = p_org_id or api.org_id  is null )
  AND    Exists ( Select '1' from ap_invoice_distributions_all apd where apd.invoice_id = api.invoice_id
                  and apd.match_status_flag ='A') /*Added by nprashar for bug 8307469*/
  AND api.invoice_currency_code =nvl( p_currency_code,api.invoice_currency_code)  /* Added by vumaasha for bug 8310720 */
  AND api.accts_pay_code_combination_id = nvl(p_accts,api.accts_pay_code_combination_id) /* Added by vumaasha for bug 8310720 */
  UNION ALL
  -- query 3
       /* Gain or Loss source AP_INVOICES */
    /* Bug 4997569. Added by Lakshmi Gopalsami
      (1) Changed the reference to xla_ae_headers instead of ap_ae_headers_all
          and xla_ae_lines instead of xla_ae_lines.
      (2) Changed ae_line_type_code to accounting_class_code
      (3) Also added xla_transaction_entities to get the entity_id and
          source_int_id_1 so that it can be joined with transaction tables.
    */
    select 'LOSS' invoice_type_lookup_code,
         0 credit_val,
              DECODE(xal.accounting_class_code,'LOSS', accounted_dr,0) acct_cr,
         xal.currency_conversion_rate  exchange_rate ,
         xal.currency_conversion_type exchange_rate_type,
         xal.currency_code invoice_currency_code,
         xal.currency_conversion_date exchange_date
     FROM xla_ae_lines xal,
	 xla_ae_headers xah,
	 xla_transaction_entities xte,
         ap_invoices_all api
    WHERE xal.application_id = 200 AND
         xal.ae_header_id =  xah.ae_header_id AND
         xal.accounting_class_code in ( p_gain,p_loss) AND   --rchandan for bug#4428980
	 xah.application_id = 200 AND
	 xah.entity_id = xte.entity_id AND
	 xte.application_id = 200 AND
	 xte.entity_code =lv_inv_entity_code AND --'AP_INVOICES'
	 xte.source_id_int_1 = api.invoice_id AND
         api.vendor_id = p_vendor_id  AND
         api.vendor_site_id = v_vendor_site_id  AND
         xah.ACCOUNTING_DATE < p_bal_date  AND
         (api.org_id = p_org_id or api.org_id  is null )
    AND api.invoice_currency_code =nvl( p_currency_code,api.invoice_currency_code)  /* Added by vumaasha for bug 8310720 */
	AND api.accts_pay_code_combination_id = nvl(p_accts,api.accts_pay_code_combination_id) /* Added by vumaasha for bug 8310720 */
    union  all
      -- Query 4
         /* Gain or Loss source AP_INVOICE_DISTRIBUTIONS */
       /* Bug 4997569. Added by Lakshmi Gopalsami
      (1) Changed the reference to xla_ae_headers instead of ap_ae_headers_all
          and xla_ae_lines instead of xla_ae_lines.
      (2) Changed ae_line_type_code to accounting_class_code
      (3) Also added xla_transaction_entities to get the entity_id and
          source_int_id_1 so that it can be joined with transaction tables.
      */
 /* Commented query 4 by nprashar for bug 8307469 as query 3 and 4 are identical
     select 'LOSS' invoice_type_lookup_code,
         0 credit_val,
         DECODE(xal.accounting_class_code,'LOSS', accounted_dr,0) acct_cr,
         xal.currency_conversion_rate  exchange_rate ,
         xal.currency_conversion_type exchange_rate_type,
         xal.currency_code invoice_currency_code,
         xal.currency_conversion_date exchange_date
    from  xla_ae_lines xal,
	 xla_ae_headers xah,
	 xla_transaction_entities xte,
         ap_invoices_all api,
         ap_invoice_distributions_all apd --Commented by nprashar for bug 8307469
    where xal.application_id = 200 AND
         xal.ae_header_id =  xah.ae_header_id AND
         xal.accounting_class_code in ( p_gain,p_loss) AND   --rchandan for bug#4428980
	 xah.application_id = 200 AND
	 xah.entity_id = xte.entity_id AND
	 xte.application_id = 200 AND
	 xte.entity_code =lv_inv_entity_code AND --'AP_INVOICES'
	 xte.source_id_int_1 = api.invoice_id AND
	 /*api.invoice_id = apd.invoice_id AND
	 apd.accounting_event_id = xah.event_id AND  --Commented by nprashar for bug 8307469
         api.vendor_id = p_vendor_id  AND
         api.vendor_site_id = v_vendor_site_id  AND
         xah.ACCOUNTING_DATE < p_bal_date  AND
        ( api.org_id = p_org_id or api.org_id  is null ) AND
        Exists( select '1' from  ap_invoice_distributions_all apd
                where api.invoice_id = apd.invoice_id
                AND apd.accounting_event_id = xah.event_id) --Added by nprashar for bug 8307469
    union all Commenting ends */
      -- Query 5
         /* Gain or Loss source AP_CHECKS */
    /* Bug 4997569. Added by Lakshmi Gopalsami
      (1) Changed the reference to xla_ae_headers instead of ap_ae_headers_all
          and xla_ae_lines instead of xla_ae_lines.
      (2) Changed ae_line_type_code to accounting_class_code
      (3) Also added xla_transaction_entities to get the entity_id and
          source_int_id_1 so that it can be joined with transaction tables.
    */
    select 'LOSS' invoice_type_lookup_code,
         0 credit_val,
	 DECODE(xal.accounting_class_code,'LOSS', accounted_dr,0) acct_cr,
         xal.currency_conversion_rate  exchange_rate ,
         xal.currency_conversion_type exchange_rate_type,
         xal.currency_code invoice_currency_code,
         xal.currency_conversion_date exchange_date
    from xla_ae_lines xal,
	 xla_ae_headers xah,
	 xla_transaction_entities xte,
         ap_invoices_all api,
         ap_checks_all ac ,
         ap_invoice_payments_all app
    where xal.application_id = 200 AND
         xal.ae_header_id =  xah.ae_header_id AND
         xal.accounting_class_code in ( p_gain,p_loss) AND   --rchandan for bug#4428980
	 xah.application_id = 200 AND
	 xah.entity_id = xte.entity_id AND
	 xte.application_id = 200 AND
	 xte.entity_code = lv_pay_entity_code AND --'AP_PAYMENTS'
	 xte.source_id_int_1 = ac.check_id AND
	 xah.event_id = app.accounting_event_id AND
         api.invoice_id =  app.invoice_id AND
         app.check_id = ac.check_id  AND
         ac.status_lookup_code IN (lv_cleared,lv_negotiable,lv_voided,
                       lv_rec_unacc,lv_reconciled,lv_cleared_unacc) AND
         api.vendor_id = p_vendor_id  AND
         api.vendor_site_id = v_vendor_site_id  AND
         xah.ACCOUNTING_DATE < p_bal_date  AND
         (api.org_id = p_org_id or api.org_id  is null )
		  AND api.invoice_currency_code =nvl( p_currency_code,api.invoice_currency_code)  /* Added by vumaasha for bug 8310720 */
		  AND api.accts_pay_code_combination_id = nvl(p_accts,api.accts_pay_code_combination_id) /* Added by vumaasha for bug 8310720 */;

  /* Commented query 6 as , Query 5 and query 6 are identical
  union all
     -- Query 6
         Gain or Loss source AP_INVOICE_PAYMENTS
      Bug 4997569. Added by Lakshmi Gopalsami
      (1) Changed the reference to xla_ae_headers instead of ap_ae_headers_all
          and xla_ae_lines instead of xla_ae_lines.
      (2) Changed ae_line_type_code to accounting_class_code
      (3) Also added xla_transaction_entities to get the entity_id and
          source_int_id_1 so that it can be joined with transaction tables.

    select 'LOSS' invoice_type_lookup_code,
         0 credit_val,
         DECODE(xal.accounting_class_code,'LOSS', accounted_dr,0) acct_cr,
         xal.currency_conversion_rate  exchange_rate ,
         xal.currency_conversion_type exchange_rate_type,
         xal.currency_code invoice_currency_code,
         xal.currency_conversion_date exchange_date
    from xla_ae_lines xal,
	 xla_ae_headers xah,
	 xla_transaction_entities xte,
         ap_invoices_all api,
         ap_checks_all ac ,
         ap_invoice_payments_all app
    where  xal.application_id = 200 AND
         xal.ae_header_id =  xah.ae_header_id AND
         xal.accounting_class_code in ( p_gain,p_loss) AND   --rchandan for bug#4428980
	 xah.application_id = 200 AND
	 xah.entity_id = xte.entity_id AND
	 xte.application_id = 200 AND
	 xte.entity_code = lv_pay_entity_code AND --'AP_PAYMENTS'
	 xte.source_id_int_1 = ac.check_id AND
	 xah.event_id = app.accounting_event_id AND
         api.invoice_id =  app.invoice_id AND
         app.check_id = ac.check_id  AND
         ac.status_lookup_code IN (lv_cleared,lv_negotiable,lv_voided,lv_rec_unacc,lv_reconciled,lv_cleared_unacc )  AND--rchandan for bug#4428980
         api.vendor_id = p_vendor_id  AND
         api.vendor_site_id = v_vendor_site_id  AND
         xah.ACCOUNTING_DATE < p_bal_date  AND
         (api.org_id = p_org_id or api.org_id  is null )
      ; Commented by nprashar for bug  8307469*/


  CURSOR  C_vendor_site_id IS
  SELECT  vendor_site_id
  FROM    po_vendor_sites_all
  WHERE   vendor_id = p_vendor_id
  AND     org_id = p_org_id       /* Added for Bug 2839228 */
  AND     vendor_site_code = p_vendor_site_code ;

  BEGIN

    -- get the vendor site id
  OPEN C_vendor_site_id;
  FETCH C_vendor_site_id INTO v_vendor_site_id;
  CLOSE C_vendor_site_id;


    v_credit_bal := 0;

    FOR inv_rec IN C_invoices('GAIN','LOSS') LOOP   --rchandan for bug#4428980

    v_invoice_amount := 0;
    v_exchange_rate  := 1;

       /* For bug 4035943. Added by LGOPALSA
          Added the logic for LOSS Lines */
       If inv_rec.invoice_type_lookup_code ='LOSS' Then

          v_invoice_amount := nvl(inv_rec.acct_cr,0);
fnd_file.put_line(FND_FILE.LOG, 'invoice amt- LOSS : '|| v_invoice_amount);

       Else


        IF inv_rec.exchange_rate_type IS NOT NULL THEN

           v_exchange_rate  := jai_cmn_utils_pkg.currency_conversion( p_set_of_books_id,
                                             inv_rec.invoice_currency_code,
                                             inv_rec.exchange_date,
                                             inv_rec.exchange_rate_type,
                                             inv_rec.exchange_rate );

            v_invoice_amount := NVL(inv_rec.credit_val, 0) * NVL(v_exchange_rate, 1);
fnd_file.put_line(FND_FILE.LOG, 'invoice amt'|| v_invoice_amount);
        ELSE
            v_invoice_amount := NVL(inv_rec.credit_val, 0) ;
        END IF;

      End if;

      v_credit_bal := v_credit_bal + NVL(v_invoice_amount, 0);

  END LOOP ;

  RETURN  (round( NVL(v_credit_bal, 0),2));

  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20009,'EXCEPTION IN FUNCTION ja_in_cledger_credit_bal : ' || SQLERRM);

END compute_credit_balance;

FUNCTION compute_debit_balance
(
p_bal_date            DATE,
p_vendor_id           NUMBER,
p_set_of_books_id     NUMBER,
p_vendor_site_code    VARCHAR2,
p_org_id              NUMBER, -- added by Aparajita on 26-sep-2002 for bug # 2574262
p_currency_code       VARCHAR2 DEFAULT NULL, /* added by vumaasha for bug 8310720 */
p_accts               ap_invoices_all.accts_pay_code_combination_id%TYPE DEFAULT NULL
)
RETURN NUMBER
IS
/*------------------------------------------------------------------------------
FILENAME: jai_ap_rpt_apcr_pkg.compute_credit_balance.sql
CHANGE HISTORY:

S.No     Date        Author AND Details

1.     16/07/2002    Aparajita Das, revamped this procedure the older code is
                     commented below for bug # 2459399. Version # 615.1

                      This function is called from 'Creditor's ledger Report' for
                      calculating opening and closing balances. The logic for the
                      detail report line was correct, but balances were getting
                      calculated wrongly in many scenarios, to tackel this issue,
                      this procedure has been redefined based on the queries of
                      the report.

2.       26/09/2002    Aparajita for bug # 2574262. Version # 615.2

                       Added the concept of org_id, as org_id was being considered at
                       line level but not balance level.
                       Added the additional parameter p_org_id.

3.       17/12/2002   Aparajita for bug # 2668999. Version # 615.3

                       For debit memos the entries should come as follows.
                       - -ve entry in credit side when it has been created and approved
                          and if paid it should not be a refund type of payment.

                       - -ve entry in debit side when it has been paid.

                       Changed the query1 of the report query to add a subquery condition
                       to check for paymentexistance  of refund type of transactions.


4.       16/01/2003    Aparajita for bug # 2545466. Version # 615.4

                       Broke the GAIN/LOSS query in the cursor into 4 queries to take
                       care of the 4 different source from which the gain loss record
                       gets populated into ap_ae_lines_all table.

                       Also removed the old code that was earlier commented at the end
                       of this code.

                       There was inconsistancy between the logic followed in the report
                       and this function for following four fields,
                       changed to follow the report as that was correct.
                       - exchange_rate
                       - exchange_rate_type
                       - invoice_currency_code
                       - exchange_date
                       All the modifications are done in cursor C_invoices.

5.       15/07/2003    RBASKER   for Bug #2911835.   Version #616.1

                       Performance Issue: The report 'India Creditors Ledger' is running
                       indefinitely ,when it is run for all the vendors.

                       Fix:
                       i)The TRUNC function around the date fields suppress the use of index.
                         Removed the TRUNC function from all SELECT statments.

                       ii)In query4 Gain or Loss source AP_INVOICE_DISTRIBUTIONS, the join condition
                          between ap_invoices_all and ap_invoice_distributions_all was missing.
                          Corrected the same.

6.       22/01/2004    Aparajita for Bug#3392495. Version#115.1
                       Added code to reduce the invoice amount by discount amount already given.
                       Changes in cursor C_invoices Query 1.

7.     04/06/2004       Added by vchallur for bug#3663549 version 115.1
                        added code so that it can free from invoice entry need not start with
                        disribution_line_number=1

8.      03/08/2004      Aparajita for bug#2839228. Version#115.2

                        Modified cursor C_vendor_site_id to select vendor site id from po_vendor_sites_all
                        considering the operating unit also.  This was needed as vendor site code for the
                        same vendor may be same accross operating units..

9.      05/11/2004      Sanjikum for bug # 3896940, Version 115.3
                        Following changes are made in query 1 of cursor C_invoices
                        a) In the query's column Credit_val, changed the column from api.Invoice_amt to z.amt_val
                        b) In the From clause, added the inline view Z
                        c) In the where clause, added the join "z.invoice_id = api.invoice_id"

10.     05/11/2004      Sanjikum for bug # 4030311, Version 115.4
                        Following changes are made in query 1 of cursor C_invoices
                        a) In the inline view Z, added a condition - ap_invoice_distributions_all.Line_type_lookup_code <> 'PREPAY'

11.     12/01/2005      For bug4035943. Added by LGOPALSA
                        Modified the calculation for balances as per the
            query change.
            Added the accounted_dr and accounted_cr for GAIN/LOSS
            lines as they will have the correct values with respect
            to functional currency. Thus, we can avoid any rounding
            errors on further calculation.
            (1) Added invoice_type_lookup_code in all the query
            (2) Changed the column selection for exchange rate in
                query 2
            (3) Selected zero for acct_cr except for GAIN lines
            (4) Selected accounted_cr from core accounting tables
                which will make the calculation easier and also
                avoids the rounding problems.
                        (5) Added the validation for 'GAIN' in calculating the debit balance.
            (6) Rounded the value to 2 decimal places as this is showing .01 while
                            displaying closing balance. We need to round it before sending the
                            values for displaying credit and debite values

12.  31-MAR-2009 JMEENA for bug#7689858
				Removed  discount_amount_taken from invoice amount and added with payment amount.
----------------------------------------------------------------------------------------------*/


  v_exchange_rate     NUMBER;
  v_debit_bal         NUMBER;
  v_invoice_amount    NUMBER;
  v_vendor_site_id    NUMBER;
  lv_prepayment       CONSTANT varchar2(30) := 'PREPAYMENT';   --rchandan for bug#4428980
  lv_prepay           CONSTANT varchar2(30) := 'PREPAY';   --rchandan for bug#4428980
  lv_debit            CONSTANT varchar2(30) := 'DEBIT' ; --rchandan for bug#4428980
  lv_cleared          CONSTANT varchar2(30) := 'CLEARED';--rchandan for bug#4428980
  lv_negotiable       CONSTANT varchar2(30) := 'NEGOTIABLE';--rchandan for bug#4428980
  lv_voided           CONSTANT varchar2(30) := 'VOIDED';--rchandan for bug#4428980
  lv_rec_unacc        CONSTANT varchar2(30) := 'RECONCILED UNACCOUNTED';--rchandan for bug#4428980
  lv_reconciled       CONSTANT varchar2(30) := 'RECONCILED';--rchandan for bug#4428980
  lv_cleared_unacc    CONSTANT varchar2(30) := 'CLEARED BUT UNACCOUNTED';--rchandan for bug#4428980
  lv_ap_checks                  CONSTANT varchar2(30) := 'AP_CHECKS';              --rchandan for bug#4428980
  lv_ap_invoices                CONSTANT varchar2(30) := 'AP_INVOICES';              --rchandan for bug#4428980
  lv_ap_invoice_distributions   CONSTANT varchar2(30) := 'AP_INVOICE_DISTRIBUTIONS';              --rchandan for bug#4428980
  lv_ap_invoice_payments        CONSTANT varchar2(30) := 'AP_INVOICE_PAYMENTS';              --rchandan for bug#4428980

  -- Bug 4997569. Added by Lakshmi Gopalsami
  lv_inv_entity_code  CONSTANT varchar2(30) := 'AP_INVOICES';
  lv_pay_entity_code  CONSTANT varchar2(30) := 'AP_PAYMENTS';


  CURSOR C_invoices( p_gain ap_ae_lines_all.ae_line_type_code%TYPE,p_loss ap_ae_lines_all.ae_line_type_code%TYPE ) IS --rchandan for bug#4428980
    -- query 1
    --Removed discount_amount_taken from debit_val for the bug#7689858
  SELECT api.invoice_type_lookup_code,
         DECODE(api.invoice_type_lookup_code,
                'CREDIT',
                ABS(z.amt_val) , -- Changed from api.Invoice_amt to z.amt_val for Bug#3896940
                0
                )  debit_val,
          /* Bug4035943. Added by LGOPALSA */
          0 acct_dr,
          api.exchange_rate exchange_rate,
          api.exchange_rate_type exchange_rate_type,
          api.invoice_currency_code invoice_currency_code,
          api.exchange_date exchange_date
  FROM    ap_invoices_all api,
          ap_invoice_distributions_all apd,
          (SELECT NVL(SUM(apd.amount),0) amt_val, /* Bug#3390665*/
                  api.invoice_id
          FROM    ap_invoices_all api,
                  ap_invoice_distributions_all apd
          WHERE   api.invoice_id = apd.invoice_id
          AND     api.invoice_type_lookup_code <> lv_prepayment  --rchandan for bug#4428980
          AND     apd.match_status_flag = 'A'
          AND     api.vendor_id = p_vendor_id
          AND     api.vendor_site_id = v_vendor_site_id
          AND     apd.accounting_date < p_bal_date
          AND     (api.org_id = p_org_id or api.org_id  is null)
          AND     apd.line_type_lookup_code <> lv_prepay --Added by Sanjikum for Bug # 4030311 --rchandan for bug#4428980
          GROUP BY api.invoice_id) z -- Added the Inline view for Bug # 3896940, as sum of amount was required in place of invoice amount
  WHERE   z.invoice_id = api.invoice_id --Added the condition for Bug # 3896940
  AND     api.invoice_id = apd.invoice_id
  AND     apd.rowid = (select rowid
                      from    ap_invoice_distributions_all
                      where   rownum=1
                      and     invoice_id=apd.invoice_id
                      AND     match_status_flag = 'A'
                      AND     accounting_date < p_bal_date)
  AND     api.invoice_type_lookup_code <> lv_prepayment  --rchandan for bug#4428980
  AND     apd.match_status_flag = 'A'
  AND     api.vendor_id = p_vendor_id
  AND     api.vendor_site_id = v_vendor_site_id
  AND     apd.accounting_date < p_bal_date
  AND     (api.org_id = p_org_id or api.org_id  is null) --  added by Aparajita on 26-sep-2002 for bug # 2574262
  /*        Following and clause added by Aparajita on 17/12/2002 for bug # 2668999 */
  AND     ((api.invoice_type_lookup_code  <> lv_debit)
           or
           (
             (api.invoice_type_lookup_code  = lv_debit)
              and
             ( not exists
                          (Select '1'
                           from   ap_invoice_payments_all  app,
                                  ap_checks_all apc
                           where  app.check_id = apc.check_id
                           and    app.invoice_id = api.invoice_id
                           and    apc.payment_type_flag = 'R'
                           )
             )
           )
        )
   AND api.invoice_currency_code =nvl( p_currency_code,api.invoice_currency_code)  /* Added by vumaasha for bug 8310720 */
   AND api.accts_pay_code_combination_id = nvl(p_accts,api.accts_pay_code_combination_id) /* Added by vumaasha for bug 8310720 */

  UNION  ALL
  -- query 2
  --Added discount_amount_taken in the amount for the bug#7689858
  SELECT  api.invoice_type_lookup_code,
       DECODE(api.invoice_type_lookup_code,'CREDIT', 0, app.amount+ nvl(discount_amount_taken, 0))  debit_val,
       /* Bug4035943. Added by LGOPALSA */
       0 acct_dr,
       /* Bug 4035943. Also need to select the exchange rate details from
          checks rather that invoices for payments */
       apc.exchange_rate exchange_rate,
       apc.exchange_rate_type exchange_rate_type,
       api.payment_currency_code invoice_currency_code,
       apc.exchange_date exchange_date
  FROM   ap_invoices_all api,
         --ap_invoice_distributions_all apd, Commented by nprashar for bug # 8307469
         ap_invoice_payments_all app,
         ap_checks_all apc
  WHERE  /*api.invoice_id = apd.invoice_id
  AND    apd.distribution_line_number = (select distribution_line_number from ap_invoice_distributions_all
                                         where rownum=1
                                         and invoice_id=apd.invoice_id
                                         AND    apd.match_status_flag='A')
                                          added by vchallur for bug#3663549 Commented by nprashar for bug # 8307469
  AND */   app.invoice_id = api.invoice_id
  AND    app.check_id = apc.check_id
  AND    apc.status_lookup_code IN (lv_cleared,lv_negotiable,lv_voided,lv_rec_unacc,lv_reconciled,lv_cleared_unacc )  --rchandan for bug#4428980
 -- AND    apd.match_status_flag='A' Commented by nprashar for bug # 8307469
  AND    api.vendor_id = p_vendor_id
  AND    api.vendor_site_id = v_vendor_site_id
  AND    app.accounting_date  < p_bal_date
  AND    ( api.org_id = p_org_id or api.org_id  is null ) -- added by Aparajita on 26-sep-2002 for bug # 2574262
 AND    Exists ( Select '1' from ap_invoice_distributions_all apd where apd.invoice_id = api.invoice_id
                 and apd.match_status_flag ='A') --Added by nprashar for bug # 8307469
 AND api.invoice_currency_code =nvl( p_currency_code,api.invoice_currency_code)  /* Added by vumaasha for bug 8310720 */
 AND api.accts_pay_code_combination_id = nvl(p_accts,api.accts_pay_code_combination_id) /* Added by vumaasha for bug 8310720 */
  UNION ALL
  -- query 3
       /* Gain or Loss source AP_INVOICES */
    /* Bug 4997569. Added by Lakshmi Gopalsami
      (1) Changed the reference to xla_ae_headers instead of ap_ae_headers_all
          and xla_ae_lines instead of xla_ae_lines.
      (2) Changed ae_line_type_code to accounting_class_code
      (3) Also added xla_transaction_entities to get the entity_id and
          source_int_id_1 so that it can be joined with transaction tables.
    */
    select 'GAIN' invoice_type_lookup_code,
         0 debit_val,
         DECODE(xal.accounting_class_code,'GAIN', accounted_cr,0) acct_dr,
         xal.currency_conversion_rate  exchange_rate ,
         xal.currency_conversion_type exchange_rate_type,
         xal.currency_code invoice_currency_code,
         xal.currency_conversion_date exchange_date
     from  xla_ae_lines xal,
	 xla_ae_headers xah,
         xla_transaction_entities xte,
         ap_invoices_all api
    where xal.application_id = 200 AND
         xal.ae_header_id =  xah.ae_header_id AND
         xal.accounting_class_code in ( p_gain,p_loss) AND   --rchandan for bug#4428980
	 xah.application_id = 200 AND
	 xah.entity_id = xte.entity_id AND
	 xte.application_id = 200 AND
	 xte.entity_code =lv_inv_entity_code AND --'AP_INVOICES'
         xte.source_id_int_1 = api.invoice_id AND   /*Added for Bug 8262193*/
         api.vendor_id = p_vendor_id  AND
         api.vendor_site_id = v_vendor_site_id  AND
         xah.ACCOUNTING_DATE < p_bal_date  AND
         (api.org_id = p_org_id or api.org_id  is null )
    AND api.invoice_currency_code =nvl( p_currency_code,api.invoice_currency_code)  /* Added by vumaasha for bug 8310720 */
	AND api.accts_pay_code_combination_id = nvl(p_accts,api.accts_pay_code_combination_id) /* Added by vumaasha for bug 8310720 */
    union  all
     -- Query 4
         /* Gain or Loss source AP_INVOICE_DISTRIBUTIONS */
      /* Bug 4997569. Added by Lakshmi Gopalsami
      (1) Changed the reference to xla_ae_headers instead of ap_ae_headers_all
          and xla_ae_lines instead of xla_ae_lines.
      (2) Changed ae_line_type_code to accounting_class_code
      (3) Also added xla_transaction_entities to get the entity_id and
          source_int_id_1 so that it can be joined with transaction tables.
      */
    /*Commented Query 4 by nprashar for bug 8307469 as query3 and 4 identical
      select 'GAIN' invoice_type_lookup_code,
         0 debit_val,
         DECODE(xal.accounting_class_code,'GAIN', accounted_cr,0) acct_dr,
         xal.currency_conversion_rate  exchange_rate ,
         xal.currency_conversion_type exchange_rate_type,
         xal.currency_code invoice_currency_code,
         xal.currency_conversion_date exchange_date
    from  xla_ae_lines xal,
	 xla_ae_headers xah,
	 xla_transaction_entities xte,
         ap_invoices_all api/*,
         ap_invoice_distributions_all apd --Commented by nprashar for bug # 8307469
    WHERE xal.application_id = 200 AND
         xal.ae_header_id =  xah.ae_header_id AND
         xal.accounting_class_code in ( p_gain,p_loss) AND   --rchandan for bug#4428980
	 xah.application_id = 200 AND
	 xah.entity_id = xte.entity_id AND
	 xte.application_id = 200 AND
	 xte.entity_code =lv_inv_entity_code AND --'AP_INVOICES'
	 xte.source_id_int_1 = api.invoice_id AND
	 /*apd.accounting_event_id = xah.event_id AND
         api.invoice_id = apd.invoice_id AND -- Commented by nprashar for bug # 8307469
         api.vendor_id = p_vendor_id  AND
         api.vendor_site_id = v_vendor_site_id  AND
         xah.ACCOUNTING_DATE < p_bal_date  AND
         ( api.org_id = p_org_id or api.org_id  is null )
         AND Exists (Select '1' from ap_invoice_distributions_all apd
                     Where apd.accounting_event_id = xah.event_id
                     AND 	api.invoice_id = apd.invoice_id ) -- Added by nprashar for bug # 8307469
    union all Commenting Ends*/
      -- Query 5
         /* Gain or Loss source AP_CHECKS */
    /* Bug 4997569. Added by Lakshmi Gopalsami
      (1) Changed the reference to xla_ae_headers instead of ap_ae_headers_all
          and xla_ae_lines instead of xla_ae_lines.
      (2) Changed ae_line_type_code to accounting_class_code
      (3) Also added xla_transaction_entities to get the entity_id and
          source_int_id_1 so that it can be joined with transaction tables.
    */
    select 'GAIN' invoice_type_lookup_code,
         0 debit_val,
         DECODE(xal.accounting_class_code,'GAIN', accounted_cr,0) acct_dr,
         xal.currency_conversion_rate  exchange_rate ,
         xal.currency_conversion_type exchange_rate_type,
         xal.currency_code invoice_currency_code,
         xal.currency_conversion_date exchange_date
    from   xla_ae_lines xal,
	 xla_ae_headers xah,
	 xla_transaction_entities xte,
         ap_invoices_all api,
         ap_checks_all ac ,
         ap_invoice_payments_all app
    where xal.application_id = 200 AND
         xal.ae_header_id =  xah.ae_header_id AND
         xal.accounting_class_code in ( p_gain,p_loss) AND   --rchandan for bug#4428980
	 xah.application_id = 200 AND
	 xah.entity_id = xte.entity_id AND
	 xte.application_id = 200 AND
	 xte.entity_code = lv_pay_entity_code AND --'AP_PAYMENTS'
	 xte.source_id_int_1 = ac.check_id AND
	 xah.event_id = app.accounting_event_id AND
         api.invoice_id =  app.invoice_id AND
         app.check_id = ac.check_id  AND
         ac.status_lookup_code IN (lv_cleared,lv_negotiable,lv_voided,
	                           lv_rec_unacc,lv_reconciled,
		   lv_cleared_unacc )  AND --rchandan for bug#4428980
         api.vendor_id = p_vendor_id  AND
         api.vendor_site_id = v_vendor_site_id  AND
         xah.ACCOUNTING_DATE < p_bal_date  AND
         (api.org_id = p_org_id or api.org_id  is null )
          AND api.invoice_currency_code =nvl( p_currency_code,api.invoice_currency_code)  /* Added by vumaasha for bug 8310720 */
		  AND api.accts_pay_code_combination_id = nvl(p_accts,api.accts_pay_code_combination_id) /* Added by vumaasha for bug 8310720 */;

    /*Commented Query 6 , as query 5 and 6 are identical
     union all
      -- Query 6
         Gain or Loss source AP_INVOICE_PAYMENTS
     Bug 4997569. Added by Lakshmi Gopalsami
      (1) Changed the reference to xla_ae_headers instead of ap_ae_headers_all
          and xla_ae_lines instead of xla_ae_lines.
      (2) Changed ae_line_type_code to accounting_class_code
      (3) Also added xla_transaction_entities to get the entity_id and
          source_int_id_1 so that it can be joined with transaction tables.

    select 'GAIN' invoice_type_lookup_code,
         0 debit_val,
         DECODE(xal.accounting_class_code,'GAIN', accounted_cr,0) acct_dr,
         xal.currency_conversion_rate  exchange_rate ,
         xal.currency_conversion_type exchange_rate_type,
         xal.currency_code invoice_currency_code,
         xal.currency_conversion_date exchange_date
    from xla_ae_lines xal,
	 xla_ae_headers xah,
	 xla_transaction_entities xte,
         ap_invoices_all api,
         ap_checks_all ac ,
         ap_invoice_payments_all app
    where  xal.application_id = 200 AND
         xal.ae_header_id =  xah.ae_header_id AND
         xal.accounting_class_code in ( p_gain,p_loss) AND   --rchandan for bug#4428980
	 xah.application_id = 200 AND
	 xah.entity_id = xte.entity_id AND
	 xte.application_id = 200 AND
	 xte.entity_code = lv_pay_entity_code AND --'AP_PAYMENTS'
	 xte.source_id_int_1 = ac.check_id AND
	 xah.event_id = app.accounting_event_id AND
         api.invoice_id =  app.invoice_id AND
         app.check_id = ac.check_id  AND
         ac.status_lookup_code IN (lv_cleared,lv_negotiable,lv_voided,
	                           lv_rec_unacc,lv_reconciled,
 	                   lv_cleared_unacc )  AND --rchandan for bug#4428980
         api.vendor_id = p_vendor_id  AND
         api.vendor_site_id = v_vendor_site_id  AND
         xah.ACCOUNTING_DATE < p_bal_date  AND
         (api.org_id = p_org_id or api.org_id  is null )
      ; Commented by nprashar for bug 8307469*/

  CURSOR  C_vendor_site_id IS
  SELECT  vendor_site_id
  FROM    po_vendor_sites_all
  WHERE   vendor_id = p_vendor_id
  AND     org_id = p_org_id       /* Added for Bug 2839228 */
  AND     vendor_site_code = p_vendor_site_code ;

  BEGIN

    -- get the vendor site id
  OPEN C_vendor_site_id;
  FETCH C_vendor_site_id INTO v_vendor_site_id;
  CLOSE C_vendor_site_id;


    v_debit_bal := 0;

    FOR inv_rec IN C_invoices('GAIN','LOSS') LOOP   --rchandan for bug#4428980

    v_invoice_amount := 0;
    v_exchange_rate  := 1;

    /* For bug 4035943. Added by LGOPALSA
          Added the logic for GAIN  Lines */
    If inv_rec.invoice_type_lookup_code ='GAIN' Then

          v_invoice_amount := nvl(inv_rec.acct_dr,0);

    Else

      IF inv_rec.exchange_rate_type IS NOT NULL THEN

          v_exchange_rate  := jai_cmn_utils_pkg.currency_conversion( p_set_of_books_id,
                                            inv_rec.invoice_currency_code,
                                            inv_rec.exchange_date,
                                            inv_rec.exchange_rate_type,
                                inv_rec.exchange_rate );

          v_invoice_amount := NVL(inv_rec.debit_val, 0) * NVL(v_exchange_rate, 1);

      ELSE
          v_invoice_amount := NVL(inv_rec.debit_val, 0) ;
      END IF;

    End if;

      v_debit_bal := v_debit_bal +  v_invoice_amount;

  END LOOP ;

  RETURN (round( NVL(v_debit_bal, 0),2));

  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20009,'Exception in function Ja_In_Cledger_debit_Bal : ' || SQLERRM);

END compute_debit_balance;


PROCEDURE process_report
(
p_invoice_date_from             IN  date,
p_invoice_date_to               IN  date,
p_vendor_id                     IN  number,
p_vendor_site_id                IN  number,
p_org_id                        IN  NUMBER,
p_run_no OUT NOCOPY number,
p_error_message OUT NOCOPY varchar2
)
IS

cursor c_get_run_no  IS
    select JAI_PO_REP_PRRG_T_RUNNO_S.nextval
    from dual;

    cursor c_inv_select_cursor( c_line_type_lookup_code ap_invoice_distributions_all.line_type_lookup_code%TYPE ) IS   --rchandan for bug#4428980
    select invoice_id, invoice_num, org_id, vendor_id, vendor_site_id, invoice_date,
        invoice_currency_code, nvl(exchange_rate,1) exchange_rate, voucher_num
    from   ap_invoices_all  aia
    where  cancelled_date is null
    and    (p_vendor_id is null or vendor_id = p_vendor_id)
    and    (p_vendor_site_id is null or vendor_site_id = p_vendor_site_id)
    and    (p_org_id is null or org_id = p_org_id)
    and    exists
           (select '1'
            from   ap_invoice_distributions_all
            where  invoice_id = aia.invoice_id
            and    line_type_lookup_code = c_line_type_lookup_code
            and    po_distribution_id is not null
            and    nvl(reversal_flag, 'N') <> 'Y'
            and    accounting_date >= p_invoice_date_from /* Modified by Ramananda for bug:4071409 */
            and    accounting_date <= p_invoice_date_to /* Modified by Ramananda for bug:4071409 */
           );

    cursor c_inv_item_lines(p_invoice_id number,c_line_type_lookup_code ap_invoice_distributions_all.line_type_lookup_code%TYPE) is
    select
        distribution_line_number,
        po_distribution_id,
        rcv_transaction_id,
        amount,
        invoice_distribution_id,
        invoice_line_number
    from ap_invoice_distributions_all
    where invoice_id = p_invoice_id
    and    line_type_lookup_code = c_line_type_lookup_code
    and    po_distribution_id is not null
    and    nvl(reversal_flag, 'N') <> 'Y'
    and    accounting_date >= p_invoice_date_from /* Modified by Ramananda for bug:4071409 */
    and    accounting_date <= p_invoice_date_to;    /* Modified by Ramananda for bug:4071409 */




    cursor c_get_po_details(p_po_distribution_id number) is
    select
        po_header_id,
        segment1,
        trunc(creation_date) po_date
    from   po_headers_all
    where  po_header_id =
        (   select  po_header_id
            from    po_distributions_all
            where   po_distribution_id = p_po_distribution_id);

    cursor c_get_po_release (p_po_distribution_id number) is
    select  release_num, release_date
    from    po_releases_all
    where   po_release_id in
        (
            select po_release_id
            from po_line_locations_all
            where  (po_header_id, po_line_id, line_location_id ) in
                    (
                        select  po_header_id, po_line_id, line_location_id
                        from    po_distributions_all
                        where   po_distribution_id = p_po_distribution_id
                    )
        );



    cursor c_get_receipt_num(p_transaction_id number) is
    select receipt_num, trunc(creation_date) receipt_date
    from   rcv_shipment_headers
    where  shipment_header_id =
        (   select  shipment_header_id
            from    rcv_transactions
            where   transaction_id = p_transaction_id);


    cursor c_get_tax_from_ap (
        p_invoice_id number,
        p_parent_distribution_id number,
        p_po_distribution_id number) is
    select distribution_line_number, tax_id
    from   JAI_AP_MATCH_INV_TAXES
    where  invoice_id = p_invoice_id
    and    parent_invoice_distribution_id = p_parent_distribution_id
    and    po_distribution_id = p_po_distribution_id
    union
    select distribution_line_number, tax_id
    from   JAI_AP_MATCH_INV_TAXES
    where  invoice_id = p_invoice_id
    and    parent_invoice_distribution_id is null
    and    po_distribution_id is null
    and    (po_header_id, po_line_id, line_location_id)
           in
           (
            select po_header_id, po_line_id, line_location_id
            from   po_distributions_all
            where  po_distribution_id = p_po_distribution_id
            );

    cursor c_get_tax_type(p_tax_id number) is
    select  upper(tax_type) tax_type
    from    JAI_CMN_TAXES_ALL
    where   tax_id = p_tax_id;

    cursor c_get_misc_tax_line_amt (p_invoice_id number, p_distribution_line_number number) is
    select amount
    from   ap_invoice_distributions_all
    where  invoice_id = p_invoice_id
    and    distribution_line_number = p_distribution_line_number
    and    accounting_date >= p_invoice_date_from /* Modified by Ramananda for bug:4071409 */
    and    accounting_date <= p_invoice_date_to;    /* Modified by Ramananda for bug:4071409 */


    cursor c_get_tax_from_receipt
            (
            p_invoice_id                number,
            p_parent_distribution_id    number,
            p_po_distribution_id        number,
            p_rcv_transaction_id        number
            ) is
    select tax_id, upper(tax_type) tax_type, currency, tax_amount
    from   JAI_RCV_LINE_TAXES
    where (shipment_header_id, shipment_line_id)
           in
           (select shipment_header_id, shipment_line_id
            from   rcv_transactions
            where  transaction_id = p_rcv_transaction_id)
    and    tax_id not in
            (
                select tax_id
                from   JAI_AP_MATCH_INV_TAXES
                where  invoice_id = p_invoice_id
                and    parent_invoice_distribution_id = p_parent_distribution_id
                and    po_distribution_id = p_po_distribution_id
                union
                select tax_id
                from   JAI_AP_MATCH_INV_TAXES
                where  invoice_id = p_invoice_id
                and    parent_invoice_distribution_id is null
                and    po_distribution_id is null
                and    (po_header_id, po_line_id, line_location_id)
                       in
                       (
                        select po_header_id, po_line_id, line_location_id
                        from   po_distributions_all
                        where  po_distribution_id = p_po_distribution_id
                        )
            )
            ;



    cursor c_get_tax_from_po
            (
            p_invoice_id                number,
            p_parent_distribution_id    number,
            p_po_distribution_id        number,
            p_rcv_transaction_id        number
            ) is
    select tax_id, upper(tax_type) tax_type, currency, tax_amount
    from   JAI_PO_TAXES
    where  (po_header_id, po_line_id, line_location_id)
           in
           (select po_header_id, po_line_id, line_location_id
            from   po_distributions_all
            where  po_distribution_id = p_po_distribution_id)
    and    tax_id not in
            (
                select tax_id
                from   JAI_AP_MATCH_INV_TAXES
                where  invoice_id = p_invoice_id
                and    parent_invoice_distribution_id = p_parent_distribution_id
                and    po_distribution_id = p_po_distribution_id
                union
                select tax_id
                from   JAI_AP_MATCH_INV_TAXES
                where  invoice_id = p_invoice_id
                and    parent_invoice_distribution_id is null
                and    po_distribution_id is null
                and    (po_header_id, po_line_id, line_location_id)
                       in
                       (
                        select po_header_id, po_line_id, line_location_id
                        from   po_distributions_all
                        where  po_distribution_id = p_po_distribution_id
                        )
            );



    v_run_no            number;
    v_po_header_id      po_headers_all.po_header_id%type;
    v_po_number         po_headers_all.segment1%type;
    v_po_date           date;
    v_receipt_num       rcv_shipment_headers.receipt_num%type;
    v_receipt_date      date;
    v_tax_type          JAI_CMN_TAXES_ALL.tax_type%type;
    v_po_release_num    po_releases_all.release_num%type;
    v_po_release_date   date;

    v_excise_ap         number;
    v_customs_ap        number;
    v_cvd_ap            number;
    v_cst_ap            number;
    v_lst_ap            number;
    v_freight_ap        number;
    v_octroi_ap         number;
    v_others_ap         number;

    v_excise_po         number;
    v_customs_po        number;
    v_cvd_po            number;
    v_cst_po            number;
    v_lst_po            number;
    v_freight_po        number;
    v_octroi_po         number;
    v_others_po         number;

    v_tax_amt           number;

    v_conversion_factor number;

    v_statement_id      number:=0;


BEGIN

/* -----------------------------------------------------------------------------
 FILENAME: ja_in_prrg_report_temp_proc_p.sql
 CHANGE HISTORY:

 S.No      Date          Author and Details
 1         14/06/2004    Created by Aparajita for bug#3633078. Version#115.0.

                         This procedure populates temporary table JAI_PO_REP_PRRG_T,
                         to be used by the purchase register report.

                         Depending on the input parameter, all invoices are selected.
                         Taxes that have been already brought over to payable invoice
                         as 'miscellaneous' distribution lines are considered by their tax
                         type.

                         For each line the taxes from the corresponding Receipt / PO are
                         again considered for any tax that is not brought over to AP. This is
                         possible as third party taxes and taxes like cvd and customs are not brought
                         over to AP. These taxes are also grouped by their tax type. These taxes
                         from purchasing side are checked for apportion factor for changes in Quantity,
                         Price and UOM for each line. Each tax line's currency is also compared against
                         invoice currency and is converted to invoice currency if required.

                         Taxes are grouped as follows,

                            excise
                            customs
                            cvd
                            cst
                            lst
                            freight
                            octroi
                            others

 2         31/12/2004   Created by Ramananda for bug#4071409. Version#115.1

           Issue:-
                         The report JAINPRRG.rdf calls this procedure jai_ap_rpt_prrg_pkg.process_report.
                         A set of from and to dates are being passed to this report.Currently the report
                         picks up the invoices based on these parameters and the details of these
                         picked up invoices are displayed in the report
           Reason:-
                         Invoice date is checked against the input date parameters to pick the invoices
           Fix:-
                         Accounting date is used against the input date parameters to pick the invoices
           Dependency due to this bug:-
       None

 Future Dependencies For the release Of this Object:-
 ==================================================
 Please add a row in the section below only if your bug introduces a dependency
 like,spec change/ A new call to a object/A datamodel change.

 --------------------------------------------------------------------------------
 Version       Bug       Dependencies (including other objects like files if any)
 --------------------------------------------------------------------------------
 115.0       3633078    Datamodel dependencies

--------------------------------------------------------------------------------- */

    -- get the run_no
    v_statement_id:= 1;
    open c_get_run_no;
    fetch c_get_run_no into v_run_no;
    close c_get_run_no;

    v_statement_id:= 2;
    for c_inv_select_rec in c_inv_select_cursor('ITEM') loop--rchandan for bug#4428980

        v_statement_id:= 3;

        -- check and loop through all the eligible item lines and populate the temp table
        for c_item_lines_rec in c_inv_item_lines(c_inv_select_rec.invoice_id,'ITEM') loop

            v_statement_id:= 4;

            v_po_header_id  := null;
            v_po_number     := null;
            v_receipt_num   := null;
            v_receipt_date  := null;
            v_po_date       := null;
            v_po_release_num := null;
            v_po_release_date := null;


            v_excise_ap     := 0;
            v_customs_ap    := 0;
            v_cvd_ap        := 0;
            v_cst_ap        := 0;
            v_lst_ap        := 0;
            v_freight_ap    := 0;
            v_octroi_ap     := 0;
            v_others_ap     := 0;

            v_excise_po     := 0;
            v_customs_po    := 0;
            v_cvd_po        := 0;
            v_cst_po        := 0;
            v_lst_po        := 0;
            v_freight_po    := 0;
            v_octroi_po     := 0;
            v_others_po     := 0;

            v_conversion_factor := 1;

            v_statement_id:= 5;
            -- get the PO reference for the item line
            open c_get_po_details(c_item_lines_rec.po_distribution_id);
            fetch c_get_po_details into  v_po_header_id, v_po_number, v_po_date;
            close c_get_po_details;

            v_statement_id:= 6;
            open c_get_po_release(c_item_lines_rec.po_distribution_id);
            fetch c_get_po_release into v_po_release_num, v_po_release_date;
            close c_get_po_release;


            -- get the receipt reference
            if c_item_lines_rec.rcv_transaction_id is not null then
                v_statement_id:= 7;
                open c_get_receipt_num(c_item_lines_rec.rcv_transaction_id);
                fetch c_get_receipt_num into v_receipt_num, v_receipt_date;
                close c_get_receipt_num;
            end if;


            -- get tax from payables side
            for c_get_tax_from_ap_rec in
                c_get_tax_from_ap
                (
                c_inv_select_rec.invoice_id,
                c_item_lines_rec.invoice_distribution_id,
                c_item_lines_rec.po_distribution_id)
            loop

                v_statement_id:= 8;

                v_tax_type := null;
                v_tax_amt := 0;

                open c_get_tax_type(c_get_tax_from_ap_rec.tax_id);
                fetch c_get_tax_type into v_tax_type;
                close c_get_tax_type;

                v_statement_id:= 9;

                open c_get_misc_tax_line_amt
                (c_inv_select_rec.invoice_id, c_get_tax_from_ap_rec.distribution_line_number);
                fetch c_get_misc_tax_line_amt into v_tax_amt;
                close c_get_misc_tax_line_amt;

                v_statement_id:= 10;

                if v_tax_type in ('ADDL. EXCISE', 'EXCISE', 'OTHER EXCISE') then
                    v_excise_ap := v_excise_ap + v_tax_amt;
                elsif v_tax_type  = 'CST' then
                    v_cst_ap := v_cst_ap + v_tax_amt;
                elsif v_tax_type  = 'SALES TAX' then
                    v_lst_ap := v_lst_ap + v_tax_amt;
                elsif v_tax_type  = 'CUSTOMS'  then
                    v_customs_ap := v_customs_ap + v_tax_amt;
                elsif v_tax_type  = 'CVD' then
                    v_cvd_ap := v_cvd_ap + v_tax_amt;
                elsif v_tax_type  = 'FREIGHT' then
                    v_freight_ap := v_freight_ap + v_tax_amt;
                elsif v_tax_type  = 'OCTRAI' then
                    v_octroi_ap := v_octroi_ap + v_tax_amt;
                else
                    v_others_ap := v_others_ap + v_tax_amt;
                end if;

            end loop; --c_get_tax_from_ap_rec

            -- Get taxes from source doc PO / Receipt that are not brought over to AP

            -- get the conversion factor considering UOM, Quantity and Price change
            v_statement_id:= 11;
            v_conversion_factor := jai_ap_utils_pkg.get_apportion_factor(c_inv_select_rec.invoice_id,c_item_lines_rec.invoice_line_number);


            if nvl(v_conversion_factor, 0) = 0  then
                v_conversion_factor := 1;
            end if;


            -- If invoice currency and tax currency are different then conversion is required.

            if c_item_lines_rec.rcv_transaction_id is not null then

                v_statement_id:= 12;
                -- get from receipt.

                for c_receipt_tax_rec in c_get_tax_from_receipt
                (
                c_inv_select_rec.invoice_id,
                c_item_lines_rec.invoice_distribution_id,
                c_item_lines_rec.po_distribution_id,
                c_item_lines_rec.rcv_transaction_id
                )
                loop

                    v_statement_id:= 13;
                    v_tax_type := c_receipt_tax_rec.tax_type;
                    v_tax_amt :=  c_receipt_tax_rec.tax_amount;


                    v_tax_amt := v_tax_amt * v_conversion_factor;

                    v_statement_id:= 14;
                    if c_inv_select_rec.invoice_currency_code <> c_receipt_tax_rec.currency then
                        v_tax_amt := v_tax_amt / c_inv_select_rec.exchange_rate;
                    end if;


                    if v_tax_type in ('ADDL. EXCISE', 'EXCISE', 'OTHER EXCISE') then
                        v_excise_po := v_excise_po + v_tax_amt;
                    elsif v_tax_type  = 'CST' then
                        v_cst_po := v_cst_po + v_tax_amt;
                    elsif v_tax_type  = 'SALES TAX' then
                        v_lst_po := v_lst_po + v_tax_amt;
                    elsif v_tax_type  = 'CUSTOMS'  then
                        v_customs_po := v_customs_po + v_tax_amt;
                    elsif v_tax_type  = 'CVD' then
                        v_cvd_po := v_cvd_po + v_tax_amt;
                    elsif v_tax_type  = 'FREIGHT' then
                        v_freight_po := v_freight_po + v_tax_amt;
                    elsif v_tax_type  = 'OCTRAI' then
                        v_octroi_po := v_octroi_po + v_tax_amt;
                    else
                        v_others_po := v_others_po + v_tax_amt;
                    end if;

                    v_statement_id:= 15;

                end loop; -- c_receipt_tax_rec

            else
              -- get from po

                for c_get_tax_from_po_rec in c_get_tax_from_po
                (
                c_inv_select_rec.invoice_id,
                c_item_lines_rec.invoice_distribution_id,
                c_item_lines_rec.po_distribution_id,
                c_item_lines_rec.rcv_transaction_id
                )

                loop

                    v_statement_id:= 16;

                    v_tax_type := c_get_tax_from_po_rec.tax_type;
                    v_tax_amt :=  c_get_tax_from_po_rec.tax_amount;

                    v_tax_amt := v_tax_amt * v_conversion_factor;

                    v_statement_id:= 17;

                    if c_inv_select_rec.invoice_currency_code <> c_get_tax_from_po_rec.currency then
                        v_tax_amt := v_tax_amt / c_inv_select_rec.exchange_rate;
                    end if;

                    if v_tax_type in ('ADDL. EXCISE', 'EXCISE', 'OTHER EXCISE') then
                        v_excise_po := v_excise_po + v_tax_amt;
                    elsif v_tax_type  = 'CST' then
                        v_cst_po := v_cst_po + v_tax_amt;
                    elsif v_tax_type  = 'SALES TAX' then
                        v_lst_po := v_lst_po + v_tax_amt;
                    elsif v_tax_type  = 'CUSTOMS'  then
                        v_customs_po := v_customs_po + v_tax_amt;
                    elsif v_tax_type  = 'CVD' then
                        v_cvd_po := v_cvd_po + v_tax_amt;
                    elsif v_tax_type  = 'FREIGHT' then
                        v_freight_po := v_freight_po + v_tax_amt;
                    elsif v_tax_type  = 'OCTRAI' then
                        v_octroi_po := v_octroi_po + v_tax_amt;
                    else
                        v_others_po := v_others_po + v_tax_amt;
                    end if;

                    v_statement_id:= 18;

                end loop; -- c_get_tax_from_po_rec

            end if;

            v_statement_id:= 19;
            -- insert into the temp table with all the values.
            insert into JAI_PO_REP_PRRG_T
            (
            run_no,
            org_id,
            vendor_id,
            vendor_site_id,
            invoice_id,
            invoice_num,
            invoice_date,
            invoice_currency_code,
            exchange_rate,
            voucher_num,
            distribution_line_number,
            po_number,
            po_header_id,
            po_creation_date,
            po_distribution_id,
            po_release_num,
            receipt_number,
            receipt_date,
            rcv_transaction_id,
            line_amount,
            excise,
            customs,
            cvd,
            cst,
            lst,
            freight,
            octroi,
            others,
            -- added, Harshita for Bug 4866533
            created_by,
            creation_date,
            last_updated_by,
            last_update_date
            )
            values
            (
            v_run_no,
            c_inv_select_rec.org_id  ,
            c_inv_select_rec.vendor_id,
            c_inv_select_rec.vendor_site_id,
            c_inv_select_rec.invoice_id,
            c_inv_select_rec.invoice_num,
            c_inv_select_rec.invoice_date,
            c_inv_select_rec.invoice_currency_code,
            c_inv_select_rec.exchange_rate,
            c_inv_select_rec.voucher_num,
            c_item_lines_rec.distribution_line_number,
            v_po_number,
            v_po_header_id,
            nvl(v_po_release_date, v_po_date),
            c_item_lines_rec.po_distribution_id,
            nvl(v_po_release_num, 0),
            v_receipt_num,
            v_receipt_date,
            c_item_lines_rec.rcv_transaction_id,
            c_item_lines_rec.amount,
            v_excise_ap +  v_excise_po,
            v_customs_ap + v_customs_po,
            v_cvd_ap + v_cvd_po,
            v_cst_ap + v_cst_po,
            v_lst_ap + v_lst_po,
            v_freight_ap + v_freight_po,
            v_octroi_ap + v_octroi_po,
            v_others_ap + v_others_po,
            -- added, Harshita for Bug 4866533
            fnd_global.user_id,
            sysdate,
            fnd_global.user_id,
            sysdate
            );


            v_statement_id:= 19;

        end loop; -- c_item_lines_rec

        v_statement_id:= 20;

    end loop;-- c_inv_select_cursor

    p_run_no := v_run_no;

EXCEPTION
    when others then
        p_error_message := 'Error from Proc jai_ap_rpt_prrg_pkg.process_report(Statement id):'
                            || '(' || v_statement_id || ')' || sqlerrm;

END process_report;

END jai_ap_rpt_apcr_pkg;


/
