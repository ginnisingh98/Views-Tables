--------------------------------------------------------
--  DDL for Package Body JAI_AP_ILA_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AP_ILA_TRIGGER_PKG" AS
/* $Header: jai_ap_ila_t.plb 120.12.12010000.4 2010/02/10 13:00:35 srjayara ship $ */

 /*
  REM +======================================================================+
  REM NAME          ARU_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_AP_ILA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_AP_ILA_ARI_T1
  REM
  REM +======================================================================+
  */
  PROCEDURE ARU_T1 ( pr_old t_rec%type ,
                     pr_new t_rec%type ,
                     pv_action varchar2 ,
                     pv_return_code out nocopy varchar2 ,
                     pv_return_message out nocopy varchar2 ) IS

  /*bug 8425058*/
  lv_source ap_invoices_all.source%TYPE;

  BEGIN
           -- Bug 6780154. Added by Lakshmi Gopalsami
           -- Removed the cursor and added op_distribution_id is null
           update JAI_AP_MATCH_ERS_T
              set po_distribution_id = pr_new.po_distribution_id
            where invoice_id = pr_new.invoice_id
              and invoice_line_number = pr_new.line_number
              and po_distribution_id is null;

  /*bug 8425058
   *Issue - "To Insert Tax Distributions" concurrent is not firing when invoice is
   *matched to PO using the "Quick Match" option in the invoice workbench.
   *Reason - po_distribution_id is null when row is inserted in ap_invoice_lines_all.
   *So the procedure ARI_T1 exits without firing the program.
   *Fix - Call the ARI_T1 procedure from ARU_T1 when the invoice source is not ERS.*/

   SELECT source INTO lv_source
   FROM ap_invoices_all
   WHERE invoice_id = pr_new.invoice_id;

   IF Nvl(lv_source,'XX') <> 'ERS' THEN
    ari_t1 (pr_old, pr_new, pv_action, pv_return_code, pv_return_message);
   END IF;

  /*end bug 8425058*/

  EXCEPTION
     WHEN OTHERS THEN
       Pv_return_code     :=  jai_constants.unexpected_error;
       Pv_return_message  := 'Encountered an error in JAI_AP_ILA_TRIGGER_PKG.ARI_T1  '  || substr(sqlerrm,1,1900);
  END;


  /*
  REM +======================================================================+
  REM NAME          ARI_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_AP_ILA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_AP_ILA_ARI_T1
  REM
  REM +======================================================================+
  */
  PROCEDURE ARI_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
  CURSOR curr(c_sob NUMBER) IS
  SELECT currency_code
  FROM gl_sets_of_books
  WHERE set_of_books_id = c_sob;

CURSOR fetch_rcv_record(v_rcv_trans_id  NUMBER)  IS
  SELECT po_header_id,po_line_id
  FROM   rcv_transactions
  WHERE  transaction_id = v_rcv_trans_id;

CURSOR  fetch_tax_distribution(v_po_header_id  NUMBER, v_po_line_id   NUMBER, v_invoice_id  NUMBER)   IS
  SELECT COUNT(*)
  FROM   JAI_AP_MATCH_INV_TAXES
  WHERE  po_header_id = v_po_header_id
  AND    po_line_id =  v_po_line_id
  AND    invoice_id =  v_invoice_id;

fetch_rcv_record_rec          fetch_rcv_record%ROWTYPE;
v_count_tax_dist              NUMBER;

result                        BOOLEAN;
req_id                        NUMBER;

v_receipt_num                 RCV_SHIPMENT_HEADERS.RECEIPT_NUM%TYPE;
v_inv_org_id                  NUMBER;
v_source                      VARCHAR2(25);
v_shipment_header_id          NUMBER;
v_shipment_line_id            NUMBER;
v_count                       NUMBER := 0;
v_vendor_site_id              NUMBER;

/*Bug 5990061 --vkantamn.Substr is added to retrieve only 30 characters from invoice_num*/
CURSOR fetch_recpt_num_cur IS
  SELECT SUBSTR(SUBSTR(invoice_num, INSTR(invoice_num, '-', 1, 1) + 1 ,
                             (INSTR(invoice_num, '-', 1, 2)-1) - INSTR(invoice_num, '-', 1, 1)
               ),1,30), Source
  FROM   ap_invoices_all
  WHERE  invoice_id = pr_new.Invoice_Id;

CURSOR fetch_inv_org_id_cur IS
  SELECT Inventory_Organization_Id
  FROM   Hr_Locations
  WHERE  Location_Id = ( SELECT Ship_To_Location_Id
                         FROM   Po_Headers_All
                         WHERE  Po_Header_Id = ( SELECT Po_Header_Id
                                                 FROM   Po_Distributions_All
                                                 WHERE  Po_Distribution_Id = pr_new.Po_Distribution_Id
                                               )
                       );

CURSOR Fetch_Shipment_Line_Id_Cur( invorg IN NUMBER, receiptnum IN VARCHAR2 ) IS
  SELECT Shipment_Line_Id, Shipment_Header_Id
  FROM   Rcv_Shipment_Lines
  WHERE  Shipment_Header_Id IN ( SELECT Shipment_Header_Id
                                 FROM   Rcv_Shipment_Headers
                                 WHERE  Receipt_Num = receiptnum )
  AND    Po_Line_location_Id = ( SELECT Line_Location_Id
                                 FROM   Po_Distributions_All
                                 WHERE  Po_Distribution_Id = pr_new.Po_Distribution_Id )
 AND     To_Organization_Id = invorg;

CURSOR Fetch_Shipment_Count_Cur( invorg IN NUMBER ) IS
  SELECT COUNT( Shipment_Line_Id )
  FROM   Rcv_Shipment_Lines
  WHERE  Shipment_Header_Id = v_shipment_header_id
  AND    To_Organization_Id = invorg;

------------Packing Slip---------------------
CURSOR vend_info(inv_id NUMBER) IS
  SELECT vendor_id, vendor_site_id
    , invoice_type_lookup_code, cancelled_date  -- cbabu for Bug# 2560026
  FROM   ap_invoices_all
  WHERE  invoice_id = inv_id;

CURSOR set_up_info(ven_id NUMBER, ven_site_id NUMBER, v_org_id NUMBER) IS
  SELECT pay_on_code, pay_on_receipt_summary_code
  FROM   po_vendor_sites_all
  WHERE  vendor_id = ven_id
  AND    vendor_site_id = ven_site_id
  AND    NVL(org_id, 0) = NVL(v_org_id, 0);

CURSOR count_receipts(p_pck_slip VARCHAR2, ven_id NUMBER, cpv_transaction_type VARCHAR2 ) IS
  SELECT DISTINCT rsh.receipt_num, rsh.shipment_header_id
  FROM   rcv_shipment_headers rsh, rcv_transactions rt
  WHERE  rsh.shipment_header_id = rt.shipment_header_id
  AND    rsh.packing_slip = p_pck_slip
  AND    rsh.vendor_id = ven_id
  AND    rt.transaction_type = cpv_transaction_type;

  set_up_info_rec               set_up_info%ROWTYPE;
  vend_info_rec                 vend_info%ROWTYPE;
  count_receipts_rec            count_receipts%ROWTYPE;
  v_initial_count               NUMBER := 0;
  v_receipt_code                VARCHAR2(25) := 'RECEIPT';
  v_curr                        curr%ROWTYPE;
  ------------Packing Slip---------------------
  v_rematching                  VARCHAR2(15) := NULL;


  v_log_file_name VARCHAR2(50) := 'jai_ap_ida_t3.log';
  v_utl_location  VARCHAR2(512);
  v_myfilehandle    UTL_FILE.FILE_TYPE;
  v_debug CHAR(1) := 'N';

  BEGIN
    pv_return_code := jai_constants.successful ;

    /*-------------------------------------------------------------------------------------------------------------------------
FILENAME: jai_ap_ida_t3.sql
CHANGE HISTORY:
S.No     Date          Author AND Details
-------------------------------------------------------------------------------------------------------------------------
1.       07-Apr-01     Ajay Sharma to take care of computations related
                       to TDS_TAX_ID at site level.

2.       20-Apr-01     Modified by Ajay Sharma to correctly compute taxes
                       at the time of RCV_MATCHING

3.       27-Aug-01     Modification done to fire Pay On Receipt code for
                       running pay on receipt for subsequent receipts against a PO

4.       30-Aug-01     Ajay Sharma, Code modified on 30-Aug-01 to give complete
                       functionality of pay on receipt and receipt matching

5.       06-Mar-2002   RPK:
                       Parameter nvl(pr_new.Org_id,0) is added to call the procedure distribution_matching.This has
                       been added for the issue of the unique constraint violation error,when an invoice is matched
                       with more than one receipt at a time. BUG#2255404.

6.       05-may-2002   Aparajita.
                       Commented the call to concurrent for insert tax lines for pay_on_receipt option and populating
                       a temporary table instead, for avoiding a concurrent request for each item line for
                       performance issue.

7.       15-nov-2002   cbabu for Bug# 2665306, Version# 615.1
                        Following extra condition is added to stop firing 'India - To Insert Tax distributions'
                        concurrent AND (v_source NOT IN ('ERS', 'ASBN') ) As the data gets inserted into
                        JAI_AP_MATCH_ERS_T table that gets processed through the another concurrent for
                        inserting tax distributions during pay on receipt. And debug code is added to debug whenever
                        there are any issues.

8.       26-NOV-2002   cbabu for Bug# 2560026, Version# 615.2
                        another ELSIF condition (AP_INVOICES_ALL.invoice_type_lookup_code = 'DEBIT') is added to
                        default taxes when debit memo is auto created or matched with a PURCHASE ORDER or RECEIPT.
                        Based on transaction data following two ways are followed.

                        If AP_INVOICES_ALL.source = 'RTS' THEN 'ERS' functionality is invoked Otherwise PO, RECEIPT
                        Match functionality is invoked.

9.       23-DEC-2002  cbabu for Bug# 2717471, Version# 615.3
                      functionality is added to default the taxes for debit memo distribution line, when it is
                      matched with an invoice.

10.      08-apr-2003  Aparajita for bug#2851123. Version#615.4
                      The request JAINDIST was submitted wrongly. The seventh parameter in the submit request has to                                           be the po distributions id. It was being passed as transactions id in receipt matching cases.

11.      11-sep-2003  Vijay Shankar for bug#3138227. Version#616.1
                      The utl file related code is failing which is stopping the transaction to continue. If the utl file
                      opening fails, then v_debug has to be made 'N' so that the transaction goes on without any error

12      29-Nov-2004   Sanjikum for 4035297. Version 115.1
                      Changed the 'INR' check. Added the call to JA_IN_UTIL.CHECK_JAI_EXISTS

                      Dependency Due to this Bug:-
                      The current trigger becomes dependent on the function ja_in_util.check_jai_exists version 115.0.

13      24-mar-2005    Aparajita. Version#115.2. TDS Clean up Bug#4088186.
                       Removed the TDS related functionality from this trigger. It only caters to pulling
                       purchasing taxes to payables.

14.     17-AUG-2005    Brathod, Bug# 4557312, File Version 120.1
                       Issue:-  fnd_request.submit_request call for submitting concurrent JAINDIST was using
                                SQLAP as application which is JA in R12 as reason concurrent was trying to find
                                a procedure registered with SQLAP application which does not exist in
                                R12 code line
                    Solution:-  All the call to submit JAINDIST concurrent are modified to use JA
                                as application instead of SQLAP.

OBJECT RENAMED TO jai_ap_ida_t3.sql
-----------------------------------

14.     22-Jun-2005    Brathod, File Version 116.0
                       For CASE complaince objects are modified to refer to new db entity names
                       in place of old db entity names.

15      22-Jun-2005    Brathod, File Version 116.1
                       Object Modified For SQL Literal Changes

16      23-Jun-2005    Brathod, Filer Version 112.0, Bug# 4445989
                       -  Trigger on the table ap_invoice_distributions_all was obsoleted and new trigger (jai_ap_ila_ari_t1)
                          on table ap_invoice_lines_all is created by modifying the trigger code to use ap_invoice_lines_all.
                          Trigger is also reponsible to submit a concurrent JAINDIST.  Arguments to the concurrent is modified
                          so the call to concurrent is also modified to use invoice_line_number instead
                          of distribution_line_number

17     07/12/2005   Hjujjuru for the bug 4866533 File version 120.1
                    added the who columns in the insert into table JAI_AP_MATCH_ERS_T.
                    Dependencies Due to this bug:-
                    None


Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Current Version    Current Bug    Dependent           Files                Version   Author   Date          Remarks
Of File                           On Bug/Patchset    Dependent On

jai_ap_ida_t3.sql
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
115.1              4035297        IN60105D2+4033992  ja_in_util_pkg_s.sql  115.0     Sanjikum 29-Nov-2004  Call to this function.
                                                     ja_in_util_pkg_s.sql  115.0   Sanjikum

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

18     20-Sep-2007   Bug#5990061. Added by vkantamn ,Version 120.8
		     Modified cursor fetch_recpt_num_cur.
		     Added substr when retrieving receipt number from invoice_num

19     08-Jan-2008    Modifed by Jason Liu for retroactive price

20     03-APR-2008      Jason Liu for bug#6918386
       Added PO Matched invoice case to insert tax lines for PPA invoice
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

  --IF JAI_CMN_UTILS_PKG.CHECK_JAI_EXISTS( p_calling_object  => 'JAIN_TDSTEMP_AFTERINSERT_TRG',
  --                                p_set_of_books_id => pr_new.set_of_books_id) = FALSE
  --THEN
  --  RETURN;
  --END IF;

  IF v_debug = 'Y' THEN
    DECLARE
     lv_name VARCHAR2 (10);
    BEGIN
    pv_return_code := jai_constants.successful ;
      -- Modified by Brathod for SQL Literals
      lv_name := 'utl_file_dir';
      SELECT DECODE(SUBSTR (value,1,INSTR(value,',') -1),NULL,
        Value,SUBSTR (value,1,INSTR(value,',') -1)) INTO v_utl_location
      FROM v$parameter
      WHERE name = lv_name;

      v_myfilehandle := UTL_FILE.FOPEN(v_utl_location, v_log_file_name ,'A');
      UTL_FILE.PUT_LINE(v_myfilehandle, '********* Start TdsTemp_AfterInsert_Trg ('||TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') ||') *********');

    EXCEPTION
      WHEN OTHERS THEN
        v_debug := 'N';
    END;

  END IF;

  OPEN  fetch_recpt_num_cur;
  FETCH fetch_recpt_num_cur INTO v_receipt_num, v_source;
  CLOSE fetch_recpt_num_cur;

  OPEN  vend_info(pr_new.invoice_id);
  FETCH vend_info INTO vend_info_rec;
  CLOSE vend_info;

  IF v_source IN ( 'ERS','ASBN') THEN

    OPEN  set_up_info(vend_info_rec.vendor_id, vend_info_rec.vendor_site_id, pr_new.org_id );
    FETCH set_up_info INTO set_up_info_rec;
    CLOSE set_up_info;


    IF set_up_info_rec.pay_on_receipt_summary_code = 'RECEIPT' THEN

      OPEN  fetch_inv_org_id_cur;
      FETCH fetch_inv_org_id_cur INTO v_inv_org_id;
      CLOSE fetch_inv_org_id_cur;

      OPEN  Fetch_Shipment_Line_Id_Cur( v_inv_org_id, v_receipt_num );
      FETCH Fetch_Shipment_Line_Id_Cur INTO v_shipment_line_id, v_shipment_header_id;
      CLOSE Fetch_Shipment_Line_Id_Cur;

      OPEN  Fetch_Shipment_Count_Cur( v_inv_org_id );
      FETCH Fetch_Shipment_Count_Cur INTO v_count;
      CLOSE Fetch_Shipment_Count_Cur;

      v_receipt_code := 'RECEIPT';

    ELSIF set_up_info_rec.pay_on_receipt_summary_code = 'PACKING_SLIP' THEN

      v_initial_count := 0;
      v_count := 0;

      FOR  count_receipts_rec IN count_receipts( v_receipt_num, vend_info_rec.vendor_id , 'RECEIVE') LOOP

        OPEN  fetch_inv_org_id_cur;
        FETCH fetch_inv_org_id_cur INTO v_inv_org_id;
        CLOSE fetch_inv_org_id_cur;

        OPEN  Fetch_Shipment_Line_Id_Cur( v_inv_org_id, count_receipts_rec.receipt_num );
        FETCH Fetch_Shipment_Line_Id_Cur INTO v_shipment_line_id, v_shipment_header_id;
        CLOSE Fetch_Shipment_Line_Id_Cur;

        OPEN  Fetch_Shipment_Count_Cur( v_inv_org_id );
        FETCH Fetch_Shipment_Count_Cur INTO v_initial_count;
        CLOSE Fetch_Shipment_Count_Cur;

        v_count := v_count + v_initial_count;

      END LOOP;

      v_receipt_code := 'PACKING_SLIP';


      IF v_count = 0 THEN
        OPEN  fetch_inv_org_id_cur;
        FETCH fetch_inv_org_id_cur INTO v_inv_org_id;
        CLOSE fetch_inv_org_id_cur;

        OPEN  Fetch_Shipment_Line_Id_Cur( v_inv_org_id, v_receipt_num );
        FETCH Fetch_Shipment_Line_Id_Cur INTO v_shipment_line_id, v_shipment_header_id;
        CLOSE Fetch_Shipment_Line_Id_Cur;

        OPEN  Fetch_Shipment_Count_Cur( v_inv_org_id );
        FETCH Fetch_Shipment_Count_Cur INTO v_count;
        CLOSE Fetch_Shipment_Count_Cur;

        v_receipt_code := 'RECEIPT';
      END IF;

    END IF; -- packing slip

  END IF; -- IF v_source IN ( 'ERS','ASBN')

/*
  IF pr_new.attribute11 = 'Y' THEN
    UPDATE ap_invoices_all
    SET    invoice_amount = invoice_amount + DECODE(pr_new.amount,-1,1,1,-1)
    WHERE  invoice_id =  pr_new.invoice_id;
  END IF;
*/

  OPEN  fetch_rcv_record(pr_new.rcv_transaction_id);
  FETCH  fetch_rcv_record  INTO  fetch_rcv_record_rec;
  CLOSE  fetch_rcv_record;

  OPEN  fetch_tax_distribution(fetch_rcv_record_rec.po_header_id, fetch_rcv_record_rec.po_line_id, pr_new.invoice_id);
  FETCH  fetch_tax_distribution  INTO   v_count_tax_dist;
  CLOSE  fetch_tax_distribution;

  IF v_debug = 'Y' THEN
    UTL_FILE.PUT_LINE(v_myfilehandle, 'invoice_id -> '|| pr_new.invoice_id
      ||', po_distribution_id -> ' ||pr_new.po_distribution_id
      || ', line_type_lookup_code -> ' ||pr_new.line_type_lookup_code
      || ', amount -> ' ||pr_new.amount
      || ', line_type_lookup_code -> ' ||pr_new.line_type_lookup_code
      || ', v_count_tax_dist -> ' ||v_count_tax_dist
      || ', v_source -> ' ||v_source
    );
  END IF;
   -- Bug 5361931. Added by Lakshmi Gopalsami. Added debug messages
  fnd_file.put_line(FND_FILE.LOG, 'invoice_id -> '|| pr_new.invoice_id
      ||', po_distribution_id -> ' || pr_new.po_distribution_id
      ||', rcv_transaction_id -> ' || pr_new.rcv_transaction_id
      ||', match_type         -> ' || pr_new.match_type
      ||', line_type_lookup_code -> ' ||pr_new.line_type_lookup_code
      ||', amount             -> ' || pr_new.amount
      ||', line_type_lookup_code -> ' ||pr_new.line_type_lookup_code
      ||', v_count_tax_dist   -> ' || v_count_tax_dist
      ||', v_source           -> ' || v_source
    );


 /* Bug 5361931. Added by Lakshmi Gopalsami
  * Instead of blindly checking for po_distribution_id is not null
  * split the condition depending on match_type.
  */
/*     IF (  ( (pr_new.match_type = 'ITEM_TO_RECEIPT' AND
           pr_new.rcv_transaction_id IS NOT NULL ) OR
          (pr_new.match_type = 'ITEM_TO_PO' AND
           pr_new.po_distribution_id IS NOT NULL
           )
        ) AND
       (pr_new.line_type_lookup_code in ('ITEM', 'ACCRUAL') ) AND
       (pr_new.amount >= 0)
       AND v_source IN ('ERS', 'ASBN') OR  (v_source = 'SUPPLEMENT')
     )
       AND v_count_tax_dist = 0
  THEN */
  -- Chenged for iSupplier 6137011
  /*For ASBN the po_distribution_id is getting updated later. So we are allowing the temp table to be populated
  even if the po_distribution_id is null and then updating when the update is happening*/
  IF (  ( pr_new.match_type = 'ITEM_TO_RECEIPT' AND
          pr_new.rcv_transaction_id IS NOT NULL AND
		  v_source in ('ERS','ASBN','SUPPLEMENT') )
		 OR
	    ( pr_new.match_type = 'ITEM_TO_PO'
		  AND
		  ( ( v_source in ('SUPPLEMENT') AND
		      pr_new.po_distribution_id IS NOT NULL )
			  or
			  v_source='ERS' /* added for bug 8259434 */
			  or
			  v_source ='ASBN' )
         )
	 ) and
     pr_new.line_type_lookup_code in ('ITEM', 'ACCRUAL') AND
     pr_new.amount >= 0 and
     v_count_tax_dist = 0
  THEN

    v_rematching := 'PAY_ON_RECEIPT';

    INSERT INTO JAI_AP_MATCH_ERS_T
  (
    invoice_id,
    invoice_line_number, -- Using Invoice_line_number instead of distribution_line_number for Bug# 4445989
    po_distribution_id,
    quantity_invoiced,
    shipment_header_id,
    receipt_num,
    receipt_code,
    rematching,
    rcv_transaction_id,
    amount,
    org_id,
    creation_date,
    -- added, Harshita for Bug 4866533
    created_by,
    last_updated_by,
    last_update_date
  )
    VALUES
    (
    pr_new.invoice_id,
    pr_new.line_number,  -- Using pr_new.line_number instead of pr_new.distribution_line_number, Bug# 4445989
    pr_new.po_distribution_id,
    pr_new.quantity_invoiced,
    v_shipment_header_id,
    v_receipt_num,
    v_receipt_code,
    v_rematching,
    pr_new.rcv_transaction_id,
    pr_new.amount,
    NVL(pr_new.org_id,0),
    SYSDATE,
    -- added, Harshita for Bug 4866533
    fnd_global.user_id,
    fnd_global.user_id,
    sysdate
    );

  ELSIF ( (pr_new.po_distribution_id IS NOT NULL) AND
          (pr_new.line_type_lookup_code in ('ITEM', 'ACCRUAL') ) AND
          (pr_new.amount >= 0) AND
          v_count_tax_dist > 0  AND
          v_source IN ('ERS', 'ASBN')
        )
        OR  (v_source = 'SUPPLEMENT')

  THEN

    v_rematching := 'RCV_MATCHING';
    result := Fnd_Request.set_mode(TRUE);
    req_id := Fnd_Request.submit_request
    (
    'JA',    -- Removed SQLAP', Bug# 4557312, BRATHOD
    'JAINDIST',
    'TO INSERT TAX Distributions',
    '',
    FALSE,
    pr_new.invoice_id,
    pr_new.line_number,  -- Using line_number instead of Distribution_line_number, Bug# 4445989
    pr_new.po_distribution_id,
    pr_new.quantity_invoiced,
    v_shipment_header_id,
    v_receipt_num,
    v_receipt_code,
    v_rematching,
    pr_new.rcv_transaction_id,
    pr_new.amount,
    NVL(pr_new.org_id,0),
    pr_new.project_id,  -- 5876390, 6012570
    pr_new.task_id,     -- 5876390, 6012570
    pr_new.expenditure_type,  -- 5876390, 6012570
    pr_new.expenditure_organization_id, -- 5876390, 6012570
    pr_new.expenditure_item_date -- 5876390, 6012570
    );

  END IF;



  IF (
       (pr_new.match_type = 'ITEM_TO_RECEIPT') AND
       (pr_new.line_type_lookup_code in ('ITEM', 'ACCRUAL') ) AND
       (pr_new.amount >= 0) AND
       v_source NOT IN ('ERS', 'ASBN')
  )
  THEN

    v_rematching := 'RCV_MATCHING';
    result := Fnd_Request.set_mode(TRUE);
    req_id := Fnd_Request.submit_request
    (
    'JA', --Removed 'SQLAP',Bug# 4557312, brathod
    'JAINDIST',
    'TO INSERT TAX Distributions',
    '',
    FALSE,
    pr_new.invoice_id,
    pr_new.line_number,  -- Using Line_Number instead of Distribution_Line_Number, Bug#4445989
    pr_new.po_distribution_id,-- pr_new.rcv_transaction_id, commented by Aparajita for bug#2851123
    pr_new.quantity_invoiced,
    v_shipment_header_id,
    v_receipt_num,
    v_receipt_code,
    v_rematching,
    pr_new.rcv_transaction_id,
    pr_new.amount,
    NVL(pr_new.org_id,0),
    pr_new.project_id,  -- 5876390, 6012570
    pr_new.task_id,  -- 5876390, 6012570
    pr_new.expenditure_type,  -- 5876390, 6012570
    pr_new.expenditure_organization_id,  -- 5876390, 6012570
    pr_new.expenditure_item_date
    );

  ELSIF (
          (pr_new.match_type = 'ITEM_TO_PO') AND
          (pr_new.line_type_lookup_code in ('ITEM', 'ACCRUAL') ) AND
          (pr_new.amount >= 0)  AND
          (pr_new.PO_DISTRIBUTION_ID IS NOT NULL OR pr_new.po_header_id IS NOT NULL)   /*bug 9346307*/
          AND (v_source NOT IN ('ERS', 'ASBN')) -- cbabu for bug # 2665306
        )
  THEN

    v_rematching := 'PO_MATCHING';
    result := Fnd_Request.set_mode(TRUE);
    req_id := Fnd_Request.submit_request
    (
    'JA', --Removed 'SQLAP', Bug# 4557312, Brathod
    'JAINDIST',
    'TO INSERT TAX Distributions',
    '',
    FALSE,
    pr_new.invoice_id,
    pr_new.line_number, -- Using Line_Number instead of Distribution_Line_Number,Bug# 4445989
    pr_new.po_distribution_id,
    pr_new.quantity_invoiced,
    v_shipment_header_id,
    v_receipt_num,
    v_receipt_code,
    v_rematching,
    pr_new.rcv_transaction_id,
    pr_new.amount,
    NVL(pr_new.org_id,0),
    pr_new.project_id,  -- 5876390, 6012570
    pr_new.task_id,     -- 5876390, 6012570
    pr_new.expenditure_type,  -- 5876390, 6012570
    pr_new.expenditure_organization_id,  -- 5876390, 6012570
    pr_new.expenditure_item_date -- 5876390, 6012570
    );

-- Start, cbabu for Bug# 2560026 on 20-nov-2002
ELSIF (
      (pr_new.po_distribution_id IS NOT NULL) AND
      (pr_new.line_type_lookup_code in ('ITEM', 'ACCRUAL') )  AND
      (pr_new.amount<0) AND
      (vend_info_rec.invoice_type_lookup_code = 'DEBIT' ) AND
      (vend_info_rec.cancelled_date IS NULL)
    )
THEN


    IF v_source = 'RTS' THEN

    v_receipt_code := 'RECEIPT';
    v_rematching := 'PAY_ON_RECEIPT';
    INSERT INTO JAI_AP_MATCH_ERS_T (
      invoice_id, invoice_line_number,  -- Bug# 4445989
      po_distribution_id, quantity_invoiced,  shipment_header_id,
      receipt_num, receipt_code, rematching,
      rcv_transaction_id, amount, org_id, creation_date,
      -- added, Harshita for Bug 4866533
      created_by, last_updated_by, last_update_date
    ) VALUES (
      pr_new.invoice_id, pr_new.line_number,  -- Bug# 4445989
      pr_new.po_distribution_id, pr_new.quantity_invoiced, v_shipment_header_id,
      v_receipt_num, v_receipt_code, v_rematching,
      pr_new.rcv_transaction_id, pr_new.amount,NVL(pr_new.org_id,0), SYSDATE,
      -- added, Harshita for Bug 4866533
      fnd_global.user_id, fnd_global.user_id, sysdate
    );

  ELSIF v_source = 'Manual Invoice Entry' THEN -- this code will be fired if v_source (i.e AP_INVOICES_ALL.source) is 'Manual Invoice Entry'

    v_rematching := null;
    IF (pr_new.match_type = 'ITEM_TO_PO' )
      /* OR (pr_new.match_type IS NULL AND pr_new.parent_invoice_id IS NOT NULL)  -- cbabu for Bug# 2717471 */
    THEN
      IF pr_new.rcv_transaction_id IS NOT NULL THEN   -- cbabu for Bug# 2717471
        v_rematching := 'RCV_MATCHING';     -- cbabu for Bug# 2717471
      ELSE
        v_rematching := 'PO_MATCHING';
      END IF;
    ELSIF pr_new.match_type = 'ITEM_TO_RECEIPT' THEN
      v_rematching := 'RCV_MATCHING';
    END IF;


    IF v_debug = 'Y' THEN
      UTL_FILE.PUT_LINE(v_myfilehandle, 'invoice_id -> '|| pr_new.invoice_id
        ||', po_distribution_id -> ' ||pr_new.po_distribution_id
        || ', line_type_lookup_code -> ' ||pr_new.line_type_lookup_code
        || ', amount -> ' ||pr_new.amount
        || ', line_type_lookup_code -> ' ||pr_new.line_type_lookup_code
        || ', v_shipment_header_id -> ' ||v_shipment_header_id
        || ', v_receipt_num -> ' ||v_receipt_num
        || ', v_receipt_code -> ' ||v_receipt_code
        || ', v_rematching -> ' ||v_rematching
      );
      UTL_FILE.PUT_LINE(v_myfilehandle, ', rcv_transaction_id -> ' ||pr_new.rcv_transaction_id
        || ', amount -> ' ||pr_new.amount
        || ', org_id -> ' ||pr_new.org_id
        || ', v_source -> ' ||v_source
      );
    END IF;

    IF v_rematching IS NOT NULL THEN
      result := Fnd_Request.set_mode(TRUE);
      req_id := Fnd_Request.submit_request (
        'JA', --Removed 'SQLAP', Bug# 4557312, Brathod
        'JAINDIST', 'To INSERT TAX Distributions', '', FALSE,
        pr_new.invoice_id, pr_new.line_number, -- Bug#4445989
        pr_new.po_distribution_id, pr_new.quantity_invoiced,
        v_shipment_header_id, v_receipt_num,  v_receipt_code,  v_rematching,
        pr_new.rcv_transaction_id, pr_new.amount,NVL(pr_new.org_id,0),
         pr_new.project_id, pr_new.task_id,pr_new.expenditure_type          -- 5876390, 6012570
        , pr_new.expenditure_organization_id, pr_new.expenditure_item_date -- 5876390, 6012570
      );
    END IF;

  END IF;

-- End, cbabu for Bug# 2560026
  -- Added by Jason Liu for retroactive price on 2008/01/07
  ----------------------------------------------------------------------
  ELSIF (pr_new.line_type_lookup_code ='RETROITEM'  AND
      v_source = 'PPA' AND pr_new.match_type = 'PO_PRICE_ADJUSTMENT')
  THEN
    -- Added by Jason Liu for bug#6918386
    ----------------------------------------------------------------------
    IF (pr_new.rcv_transaction_id IS NULL)
    THEN
      v_rematching := 'PO_MATCHING';
    ELSE
      v_rematching := 'RCV_MATCHING';
    END IF;
    ----------------------------------------------------------------------
    result := Fnd_Request.set_mode(TRUE);
    req_id := Fnd_Request.submit_request
    (
    'JA', --Removed 'SQLAP',Bug# 4557312, brathod
    'JAINDIST',
    'TO INSERT TAX Distributions',
    '',
    FALSE,
    pr_new.invoice_id,
    pr_new.line_number,  -- Using Line_Number instead of Distribution_Line_Number, Bug#4445989
    pr_new.po_distribution_id,-- pr_new.rcv_transaction_id, commented by Aparajita for bug#2851123
    pr_new.quantity_invoiced,
    v_shipment_header_id,
    v_receipt_num,
    v_receipt_code,
    v_rematching,
    pr_new.rcv_transaction_id,
    pr_new.amount,
    NVL(pr_new.org_id,0),
    pr_new.project_id,  -- 5876390, 6012570
    pr_new.task_id,  -- 5876390, 6012570
    pr_new.expenditure_type,  -- 5876390, 6012570
    pr_new.expenditure_organization_id,  -- 5876390, 6012570
    pr_new.expenditure_item_date
    );
  END IF; -- ITEM_TO_PO
  ----------------------------------------------------------------------
  IF v_debug = 'Y' THEN
    UTL_FILE.fclose(v_myfilehandle);
  END IF;
   /* Added an exception block by Ramananda for bug#4570303 */
   EXCEPTION
     WHEN OTHERS THEN
       Pv_return_code     :=  jai_constants.unexpected_error;
       Pv_return_message  := 'Encountered an error in JAI_AP_ILA_TRIGGER_PKG.ARI_T1  '  || substr(sqlerrm,1,1900);
  END ARI_T1 ;

END JAI_AP_ILA_TRIGGER_PKG ;

/
