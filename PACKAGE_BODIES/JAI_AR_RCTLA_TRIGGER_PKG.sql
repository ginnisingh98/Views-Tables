--------------------------------------------------------
--  DDL for Package Body JAI_AR_RCTLA_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AR_RCTLA_TRIGGER_PKG" AS
/* $Header: jai_ar_rctla_t.plb 120.22.12010000.19 2010/05/28 06:22:18 xlv ship $ */
/*
  REM +======================================================================+
  REM NAME          ARD_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_AR_RCTLA_ARIUD_T1
  REM
  RE NOTES         Refers to old trigger JAI_AR_RCTLA_ARD_T3
  REM
  REM +======================================================================*/
/**************************************************************************************
    Change History

    S.No.   Description

    1    07/12/2005    Hjujjuru for the bug 4866533 File version 120.1
                        added the who columns in the insert of JAI_CMN_ERRORS_T
                       Dependencies Due to this bug:-
                       None

2      24/04/1005    cbabu for bug#6012570 (5876390) Version: 120.11
                      Projects Billing Enh.
                      forward ported from R11i to R12

    3    26/04/2007   CSahoo for bug#5989740  File Version 120.12
                      Forward porting of 11i BUG#5907436
                      ENH: Handling Secondary and Higher Education Cess
                      Added the new cess types jai_constants.tax_type_sh_exc_edu_cess, jai_constants.tax_type_sh_cvd_edu_cess

    4.   27/04/2007   CSahoo for bug#5879769, File Version 120.12
                      Forward porting of 11i bug#5694855
                      Added a function get_service_type to get the service_type_code
                      added the cursor c_get_address_details to get the customer_id and Customer_site_id



    5.  14/05/2007  bduvarag for bug 5879769  File Version 120.14
                    Removed the Project Billing Code

    6.  04/07/2007  brathod, File Version 120.17, bug#6012570 (5876390)
                    Reintroduced the project billing related changes.

    7.  11-10-07    JMEENA for bug# 6493501 File Version 120.7.12000000.5
        Issue:  AUTOINVOICE PROGRAM GOING IN ERROR
                    Reason: IL doesn't processes the data which is being imported into Receivables,
                           if interface_line_context is any of the following :-
                           ('PROJECTS INVOICES', 'OKS CONTRACTS','LEGACY', 'Property-Projects','CLAIM').
                    Fix:   Trigger jai_ractl_ariud_trg:-
                           IL sucessfully processes the data which is being imported into Receivables,
                           if interface_line_context is any of the following:-
                             ('ORDER ENTRY',  'SUPPLEMENT CM',  'SUPPLEMENT DM',  'SUPPLEMENT INVOICE',
                              'TCS Debit Memo',  'TCS Credit Memo' )
                           and interface_header_context is any of the following
                              ('PROJECTS INVOICES',   'PA INVOICES') --'PA INTERNAL INVOICES'
                           (jai_ractl_trg_pkg) Function is_this_projects_context:-
                            Commented 'PA INTERNAL INVOICES'
                            It can be used to support interproject or intercompany billing in future

8 06-nov-08      vkaranam for bug#7539258,  File Version 120.7.12000000.6
                 forwardported the changes done in 115 bug#7536069
9. 09-SEP-2009 VKARANAM for bug#8849775
Issue: Line Amount,Tax Amount has been calculated as 0 in India Localization for Manual Credit Memo.
Reason:
This issue is happening only for the CM created without qty.
Fix:
Added nvl(pr_new.extended_amount,0) while calculating the line amount.

10. 02-Apr-2010 Allen Yang for bug 9485355
Procedure ARI_T2 is modified to ensure that 'Non-shippable' data that is now inserted in
'JAI_OM_WSH_LINES_ALL' & 'JAI_OM_WSH_LINE_TAXES' without 'Delivery_detail_id' gets pulled
into OFI Receivables tables, when Bill Only workflow is not used.

11. 20-May-2010 Allen Yang for bug 9710600
Modified inner procedure process_bill_only of procedure ARI_T2 to copy VAT Invoice Number
from JAI_OM_WSH_LINES_ALL for Bill Only items.
12. 28-May-2010 Xiao for bug 9737639.
                Issue: Tax amount is calculated as sum amount for all the taxes
                Fixed: Only exclusive taxes amount should be calculated in sum formula.
                       Modify curso c_cust_trx_tax_line_amt to sum tax_amount only for exlcusive tax amount.
                       Add condition nvl(b.inclusive_tax_flag, 'N') = 'N';
----------------------------------------------------------------------------------------



Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Current Version    Current Bug    Dependent           Files                Version   Author   Date          Remarks
Of File                           On Bug/Patchset    Dependent On


------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
  PROCEDURE ARD_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS

  v_excise                      Number := 0;
  v_additional                  Number := 0;
  v_other                       Number := 0;
  v_old_tax_tot                 Number := 0;
  v_old_line_amount             Number := 0;
  v_customer_trx_line_id        Number; -- := pr_old.CUSTOMER_TRX_LINE_ID;        --Ramananda for File.Sql.35
  v_customer_trx_id             Number; -- := pr_old.CUSTOMER_TRX_ID;             --Ramananda for File.Sql.35
  v_once_completed_flag         Varchar2(1);

  CURSOR excise_cal_cur IS
  SELECT  A.tax_id, A.tax_rate, A.tax_amount tax_amt,b.tax_type t_type
    FROM  JAI_AR_TRX_TAX_LINES A , JAI_CMN_TAXES_ALL B
   WHERE  link_to_cust_trx_line_id = v_customer_trx_line_id
     and  A.tax_id = B.tax_id
   order by 1;

  CURSOR old_line_amount_cur IS
  SELECT line_amount ,tax_amount  --added tax_amount for bug#7539258
  FROM   JAI_AR_TRX_LINES
  WHERE  CUSTOMER_TRX_ID = v_customer_trx_id AND
         CUSTOMER_TRX_LINE_ID = v_customer_trx_line_id;

  CURSOR ONCE_COMPLETE_FLAG_CUR IS
  SELECT once_completed_flag
  FROM   JAI_AR_TRXS
  WHERE  customer_trx_id = v_customer_trx_id;

  -- following segment uncommented by sriram - bug # 2618503
  v_trans_type    Varchar2(30);

  /*Cursor transaction_type_cur IS
  Select a.type
  From   RA_CUST_TRX_TYPES_ALL a, RA_CUSTOMER_TRX_ALL b
  Where  a.cust_trx_type_id = b.cust_trx_type_id
  And    b.customer_trx_id = v_customer_trx_id
  And    NVL(a.org_id,0) = NVL(pr_old.org_id,0);
  */

  -- the above cursor commented and using the following instead.

  Cursor transaction_type_cur IS
  Select a.type
  From   RA_CUST_TRX_TYPES_ALL a
  Where  cust_trx_type_id
  in
  (
   SELECT cust_trx_type_id
   FROM   RA_CUSTOMER_TRX_ALL
   WHERE  CUSTOMER_TRX_ID = v_customer_trx_id
   AND    org_id = pr_old.ORG_ID     /* Modified by Ramananda for removal of SQL LITERALs */
   --AND    org_id = NVL(pr_old.ORG_ID,0)
  )
   AND ORG_ID = pr_old.ORG_ID ;  /* Modified by Ramananda for removal of SQL LITERALs */
 -- AND ORG_ID = NVL(pr_old.ORG_ID,0);

    -- ends here uncommented code by sriram - bug # 2618503

  -- code added by sriram to check up if the line created corresponds to an so line or a return line

  cursor c_check_so_line is
  select 1
  from   JAI_OM_OE_SO_LINES
  where  line_id = to_number(pr_old.interface_line_attribute6);

  cursor c_check_rma_line is
  select 1
  from   JAI_OM_OE_RMA_LINES
  where  rma_line_id = to_number(pr_old.interface_line_attribute6);

  v_so_line_check  Number :=0;
  v_rma_line_check Number :=0;


  /**************************************************************************************
  Change History

  S.No.   Description

  1       Sriram - Bug # 2590650 - Added delete statements to delete from the
          JAI_AR_TRX_INS_LINES_T for customer trx id and trx line id and also the
          JAI_AR_TRXS table

  2       Sriram - Bug # 2618503
          If the line being deleted corresponds to a return order or a sales order then
          delete the lines related to localization ar tables.

  3.      29-nov-2004  ssumaith - bug# 4037690  - File version 115.1
          Check whether india localization is being used was done using a INR check in every trigger.
          This check has now been moved into a new package and calls made to this package from this trigger
          If the function jai_cmn_utils_pkg.check_jai_exists returns true it means INR is the set of books currency ,
          Hence if this function returns FALSE , control should return

  4.      08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old
          DB Entity as required for CASE COMPLAINCE.  Version 116.1

  5.      13-Jun-2005    File Version: 116.2
                         Ramananda for bug#4428980. Removal of SQL LITERALs is done

  6.      16-Jan-06      rallamse Bug#4926736 , Version # 120.2
                         Removed cursor location_cur in ARI_T2 as it is not being used

  7.      17-feb-2007    sacsethi for bug#5228046 , version 120.8
                         for tax precedence
   8.   27/02/2007    bduvarag for the bug#4694650 File version 120.9
      Forward porting the changes done in 11i bug#4644152
 9.  18/04/2007   bduvarag for the Bug#4881426, file version 120.10
        Forward porting the changes done in 11i bug#4862976
10. 20/04/2007  bduvarag for the Bug#5684363, file version 120.10
        Forward porting the changes done in 11i bug#5682531
Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Current Version    Current Bug    Dependent           Files                Version   Author   Date          Remarks
Of File                           On Bug/Patchset    Dependent On

ja_in_ar_lines_delete_trg.sql
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
115.1              4037690        IN60105D2          ja_in_util_pkg_s.sql  115.0     ssumaith 29-Nov-2004  Call to this function.
                                                     ja_in_util_pkg_s.sql  115.0     ssumaith

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

  BEGIN
    pv_return_code := jai_constants.successful ;
      v_customer_trx_line_id        := pr_old.CUSTOMER_TRX_LINE_ID;        --Ramananda for File.Sql.35
  v_customer_trx_id             := pr_old.CUSTOMER_TRX_ID;             --Ramananda for File.Sql.35

  --If jai_cmn_utils_pkg.check_jai_exists(P_CALLING_OBJECT => 'JA_IN_AR_LINES_DELETE_TRG', P_ORG_ID => pr_old.ORG_ID) = false then
  --  return;
  --end if;


  FOR excise_cal_rec in excise_cal_cur LOOP
    IF excise_cal_rec.t_type IN ('Excise') THEN
      v_excise := nvl(v_excise,0) + nvl(excise_cal_rec.tax_amt,0);
    ELSIF excise_cal_rec.t_type IN ('Addl. Excise') THEN
      v_additional := nvl(v_additional,0) + nvl(excise_cal_rec.tax_amt,0);
    ELSIF excise_cal_rec.t_type IN ('Other Excise') THEN
      v_other := nvl(v_other,0) + nvl(excise_cal_rec.tax_amt,0);
    END IF;
  END LOOP;
  v_old_tax_tot  := nvl(v_excise,0) + nvl(v_other,0) + nvl(v_additional,0);

  OPEN   old_line_amount_cur;
  FETCH  old_line_amount_cur INTO v_old_line_amount,v_old_tax_tot;--added v_old_tax_tot for bug#7539258
  CLOSE  old_line_amount_cur;


  --start additions for bug#7539258
  UPDATE JAI_AR_TRXS
     SET line_amount = nvl(line_amount,0) - nvl(v_old_line_amount,0),
     tax_amount  = nvl(tax_amount,0) - nvl(v_old_tax_tot,0),
     total_amount = nvl(total_amount,0) - (nvl(v_old_line_amount,0) + nvl(v_old_tax_tot,0))
   WHERE customer_trx_id = v_customer_trx_id;

     --end additions for bug#7539258

  DELETE FROM
  JAI_AR_TRXS  trx
  WHERE customer_trx_id = v_customer_trx_id
  AND EXISTS
  (SELECT 1
   FROM  ra_interface_lines_all il
   WHERE il.customer_trx_id = v_customer_trx_id
   AND   NVL(il.interface_status , '~') <> 'P'
  );

  DELETE JAI_AR_TRX_TAX_LINES
  WHERE  LINK_TO_CUST_TRX_LINE_ID = v_customer_trx_line_id;

-- the followining delete from temp_lines_insert added by sriram bug # 2590650

  DELETE JAI_AR_TRX_INS_LINES_T
  WHERE  CUSTOMER_TRX_ID = v_customer_trx_id
  AND
  LINK_TO_CUST_TRX_LINE_ID = v_customer_trx_line_id;


  DELETE JAI_AR_TRX_LINES
  WHERE  CUSTOMER_TRX_ID = v_customer_trx_id AND
   CUSTOMER_TRX_LINE_ID = v_customer_trx_line_id;
    /* Added an exception block by Ramananda for bug#4570303 */
   EXCEPTION
     WHEN OTHERS THEN
       Pv_return_code     :=  jai_constants.unexpected_error;
       Pv_return_message  := 'Encountered an error in JAI_AR_RCTLA_TRIGGER_PKG.ARD_T1  '  || substr(sqlerrm,1,1900);
  END ARD_T1 ;

  /*
  REM +======================================================================+
  REM NAME          ARI_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_AR_RCTLA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_AR_RCTLA_ARI_T1
  REM
  REM +======================================================================+
  */
 PROCEDURE ARI_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
   v_trans_type                  Varchar2(30);

   /* --Ramananda for File.Sql.35, START */
  v_header_id                   Number; -- := pr_new.customer_trx_id;
  v_inventory_item_id           Number; -- := pr_new.inventory_item_id;
  v_line_amount                 number; -- := nvl(NVL(pr_new.quantity_credited,pr_new.quantity_invoiced) * pr_new.unit_selling_price,0);
  v_customer_trx_line_id        Number; -- := pr_new.customer_trx_line_id;
  v_line_type                   Varchar2(10); -- := pr_new.line_type;
  v_prev_customer_trx_line_id   Number; -- := pr_new.previous_customer_trx_line_id;
  v_link_to_cust_id             Number; -- := pr_new.link_to_cust_trx_line_id;
 /* --Ramananda for File.Sql.35, end */

  v_gl_date                     Date ;
  v_tax_category_id             Number ;
  v_price_list                  Number ;
  c_from_currency_code          Varchar2(15);
  c_conversion_type             Varchar2(30);
  c_conversion_date             Date;
  c_conversion_rate             Number := 0;
  v_converted_rate              Number := 1;
  v_books_id                    Number;

/* --Ramananda for File.Sql.35, start */
  v_last_update_date            Date; --   := pr_new.last_update_date;
  v_last_updated_by             Number; -- := pr_new.last_updated_by;
  v_creation_date               Date; --   := pr_new.creation_date;
  v_created_by                  Number; -- := pr_new.created_by;
  v_last_update_login           Number; -- := pr_new.last_update_login;
  v_operating_id                number; --  :=pr_new.ORG_ID;
 /* --Ramananda for File.Sql.35, end */

  v_created_from                Varchar2(30);
  v_organization_id             Number ;

  v_gl_set_of_bks_id            gl_sets_of_books.set_of_books_id%type;
  v_currency_code               gl_sets_of_books.currency_code%type;

  lv_service_type_code          VARCHAR2(30); --added by csahoo for bug#5879769


  Cursor transaction_type_cur IS
  Select a.type
  From   RA_CUST_TRX_TYPES_ALL a, RA_CUSTOMER_TRX_ALL b
  Where  a.cust_trx_type_id = b.cust_trx_type_id
  And    b.customer_trx_id = v_header_id
  And    NVL(a.org_id,0) = NVL(pr_new.org_id,0);

  CURSOR gl_date_cur IS
  SELECT DISTINCT gl_date
  FROM   RA_CUST_TRX_LINE_GL_DIST_ALL
  WHERE  CUSTOMER_TRX_LINE_ID = v_prev_customer_trx_line_id;

  Cursor localization_line_info IS
  Select assessable_value, tax_category_id, service_type_code   --service_type_code added by csahoo for bug#5879769
  From   JAI_AR_TRX_LINES
  Where  customer_trx_line_id = v_prev_customer_trx_line_id;


-- Date 23/02/2006 by sacsethi for bug 5228046
-- precedence 6 to 10
  CURSOR  localization_tax_info IS
  SELECT  a.tax_id, a.tax_line_no lno,
          a.precedence_1 p_1, a.precedence_2 p_2, a.precedence_3 p_3,
          a.precedence_4 p_4, a.precedence_5 p_5,
          a.precedence_6 p_6, a.precedence_7 p_7, a.precedence_8 p_8,
          a.precedence_9 p_9, a.precedence_10 p_10,
          a.tax_rate, a.tax_amount, a.uom uom_code, a.qty_rate,
          decode(upper(b.tax_type),'EXCISE', 1, 'ADDL. EXCISE', 1, 'OTHER EXCISE', 1, 'CVD',1, 'TDS', 2, 0) tax_type_val,
          b.tax_type
  FROM    JAI_AR_TRX_TAX_LINES a, JAI_CMN_TAXES_ALL b
  WHERE   a.customer_trx_line_id = v_prev_customer_trx_line_id
  AND     a.tax_id = b.tax_id;


  Cursor header_info_cur IS
  SELECT created_from, set_of_books_id,  invoice_currency_code, exchange_rate_type, nvl(exchange_date,trx_date), exchange_rate
  FROM   RA_CUSTOMER_TRX_ALL
  WHERE  customer_trx_id = v_header_id;

  Cursor localization_header_info_cur IS
  SELECT organization_id
  FROM   JAI_AR_TRXS
  WHERE  customer_trx_id = v_header_id;

  /* Bug 5243532. Added by Lakshmi Gopalsami
   Removed the cursors Fetch_Book_Id_cur and set_of_books_cur
   which is referening to org_organization_definitions as we
   can get the SOB from the value assigned in the trigger

   Removed the cursor sob_cur also.
  */
  BEGIN
    pv_return_code := jai_constants.successful ;
      /*------------------------------------------------------------------------------------------
     FILENAME: JA_IN_AR_CM_LINES_INSERT_TRG.sql

     CHANGE HISTORY:
    S.No      Date          Author and Details
    1.  2001/07/14    Anuradha Parthasarathy
                      Check added to ensure non firing of trigger for Non Indian OU.

    2. 2004/10/18    ssumaith - bug# 3957682- File version 115.1
                     when a manual credit memo is created , taxes are not getting defaulted.
                     The reason this was happening is because this trigger has code to copy the
                     taxes from the invoice against which the credit memo is applied.

                     Added code to return control when a manual credit memo without reference is created.
                     Manual Credit memo with reference    to invoice has ra_customer_trx_all.created_from as ARXTWCMI
                     Manual Credit memo without reference to invoice has ra_customer_trx_all.created_from as ARXTWMAI
   3.  08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old
                     DB Entity as required for CASE COMPLAINCE.  Version 116.1

   4.  10-Jun-2005    File Version: 116.2
                      Removal of SQL LITERALs is done
    --------------------------------------------------------------------------------------------*/

/* --Ramananda for File.Sql.35, start */
  v_header_id                   := pr_new.customer_trx_id;
  v_inventory_item_id           := pr_new.inventory_item_id;
  v_line_amount                 := nvl(NVL(pr_new.quantity_credited,pr_new.quantity_invoiced) * pr_new.unit_selling_price,nvl(pr_new.extended_amount,0));   --added  nvl(pr_new.extended_amount,0) for bug#8849775
  v_customer_trx_line_id        := pr_new.customer_trx_line_id;
  v_line_type                   := pr_new.line_type;
  v_prev_customer_trx_line_id   := pr_new.previous_customer_trx_line_id;
  v_link_to_cust_id             := pr_new.link_to_cust_trx_line_id;
  v_last_update_date            := pr_new.last_update_date;
  v_last_updated_by             := pr_new.last_updated_by;
  v_creation_date               := pr_new.creation_date;
  v_created_by                  := pr_new.created_by;
  v_last_update_login           := pr_new.last_update_login;
  v_operating_id                :=pr_new.ORG_ID;
/* --Ramananda for File.Sql.35, end */
    /* Bug 5243532. Added by Lakshmi Gopalsami
       Removed the cursor and assigned the value from the
       table value assigned in the trigger

    OPEN  Fetch_Book_Id_Cur ;
    FETCH Fetch_Book_Id_Cur INTO v_gl_set_of_bks_id;
    CLOSE Fetch_Book_Id_Cur;
    */



    v_gl_set_of_bks_id := pr_new.set_of_books_id;

   /* IF pr_new.org_id IS NOT NULL THEN

        OPEN Sob_cur;
        FETCH Sob_cur INTO v_currency_code;
        CLOSE Sob_cur;
        IF v_currency_code <> 'INR'    THEN
           RETURN;
        END IF;
    END IF; */


    OPEN  transaction_type_cur;
    FETCH transaction_type_cur INTO v_trans_type;
    CLOSE transaction_type_cur;

    IF NVL(v_trans_type,'N') NOT IN ('DM','CM') THEN -- Modified on 19/9
       Return;
    END IF;

    OPEN  HEADER_INFO_CUR;
    FETCH HEADER_INFO_CUR INTO v_created_from, v_books_id, c_from_currency_code, c_conversion_type, c_conversion_date, c_conversion_rate ;
    CLOSE HEADER_INFO_CUR;
    IF v_created_from NOT IN ('ARXTWCMI','ARXTWMAI') THEN -- Modified on 19/9
       Return;
    END IF;

    /*
      following code added by ssumaith - bug# 3957682
      Ensured that for a manual credit memo tax defaultation does not take place from this trigger and it instead takes
      place from the trigger ja_in_ar_lines_insert_trg.
    */
    if v_created_from  = 'ARXTWMAI' and v_trans_type = 'CM' then
      return;
    end if;
    /*
       code added by ssumaith - bug# 3957682 - ends here
    */

    IF v_books_id IS NULL THEN
        OPEN  localization_header_info_cur;
        FETCH localization_header_info_cur INTO v_organization_id;
        CLOSE localization_header_info_cur;
        /* Bug 5243532. Added by Lakshmi Gopalsami
     Removed the reference to cursor set_of_books_cur.
  */
    END IF;

    v_converted_rate := jai_cmn_utils_pkg.currency_conversion (v_books_id ,c_from_currency_code ,
                        c_conversion_date ,c_conversion_type, c_conversion_rate);

    IF v_line_type = 'LINE' THEN
       Open  Gl_Date_Cur;
       Fetch Gl_Date_Cur Into v_gl_date;
       Close Gl_Date_Cur;

       Open  localization_line_info;
       Fetch localization_line_info into v_tax_category_id, v_price_list, lv_service_type_code;  -- lv_service_type_code added by csahoo for bug#5879769
       Close localization_line_info;

       INSERT INTO JAI_AR_TRX_LINES
                                              (customer_trx_line_id,
                                               line_number,
                                               customer_trx_id,
                                               description,
                                               inventory_item_id,
                                               unit_code,
                                               quantity,
                                               tax_category_id,
                                               auto_invoice_flag ,
                                               unit_selling_price,
                                               line_amount,
                                               gl_date,
                                               tax_amount,
                                               total_amount,
                                               assessable_value,
                                               creation_date,
                                               created_by,
                                               last_update_date,
                                               last_updated_by,
                                               last_update_login,
                                               service_type_code   -- added by csahoo for bug#5879769
                                              )
                                       VALUES(
                                               v_customer_trx_line_id,
                                               pr_new.line_number,
                                               v_header_id,
                                               pr_new.description,
                                               v_inventory_item_id,
                                               pr_new.uom_code,
                                               NVL(NVL(pr_new.quantity_credited,pr_new.quantity_invoiced) ,0)
                                               , v_tax_category_id,
                                               'N',
                                               pr_new.unit_selling_price,
                                               v_line_amount,
                                               v_gl_date,
                                               0,
                                               v_line_amount,
                                               v_price_list,
                                               v_creation_date,
                                               v_created_by,
                                               v_last_update_date,
                                               v_last_updated_by,
                                               v_last_update_login,
                                               lv_service_type_code  -- added by csahoo for bug#5879769
                                              );
       Update  JAI_AR_TRXS
       Set     line_amount = nvl(line_amount,0) + nvl(v_line_amount,0)
       Where   Customer_Trx_Id = v_header_id;

    ELSIF v_line_type in ('FREIGHT','TAX') THEN
        FOR rec in localization_tax_info
        LOOP
-- Date 23/02/2006 by sacsethi for bug 5228046
-- precedence 6 to 10
    INSERT INTO JAI_AR_TRX_TAX_LINES
                                                (customer_trx_line_id,
                                                 link_to_cust_trx_line_id,
                                                 tax_line_no,
                                                 precedence_1,
                                                 precedence_2,
                                                 precedence_3,
                                                 precedence_4,
                                                 precedence_5,
                                                 precedence_6,
                                                 precedence_7,
                                                 precedence_8,
                                                 precedence_9,
                                                 precedence_10,
             tax_id,
                                                 tax_rate,
                                                 qty_rate,
                                                 uom,
                                                 tax_amount,
                                                 base_tax_amount,
                                                 func_tax_amount,
                                                 creation_date,
                                                 created_by,
                                                 last_update_date,
                                                 last_updated_by,
                                                 last_update_login
                                                )
                                          VALUES
                                               (v_customer_trx_line_id,
                                                v_link_to_cust_id,
                                                rec.lno,
                                                rec.p_1,
                                                rec.p_2,
                                                rec.p_3,
                                                rec.p_4,
                                                rec.p_5,
                                                rec.p_6,
                                                rec.p_7,
                                                rec.p_8,
                                                rec.p_9,
                                                rec.p_10,
                                                rec.tax_id,
                                                rec.tax_rate,
                                                rec.qty_rate,
                                                rec.uom_code,
                                                pr_new.extended_amount,
                                                pr_new.extended_amount,
                                                pr_new.extended_amount *  v_converted_rate,
                                                v_creation_date,
                                                v_created_by,
                                                v_last_update_date,
                                                v_last_updated_by,
                                                v_last_update_login
                                               );

          IF rec.tax_type in ('Excise','Addl. Excise','Other Excise') THEN
             Update  JAI_AR_TRXS
             Set     total_amount = nvl(total_amount,0) + nvl(pr_new.extended_amount,0),
                     tax_amount = nvl(tax_amount,0) + nvl(pr_new.extended_amount,0)
             Where   Customer_Trx_Id = v_header_id;
          END IF;
          Update  JAI_AR_TRX_LINES
          Set     total_amount = nvl(total_amount,0) + nvl(pr_new.extended_amount,0),
                  tax_amount = nvl(tax_amount,0) + nvl(pr_new.extended_amount,0)
          Where   Customer_Trx_Id = v_header_id
          and     Customer_Trx_Line_Id = v_link_to_cust_id;
        END LOOP;
    END IF;
    /* Added an exception block by Ramananda for bug#4570303 */
   EXCEPTION
     WHEN OTHERS THEN
       Pv_return_code     :=  jai_constants.unexpected_error;
       Pv_return_message  := 'Encountered an error in JAI_AR_RCTLA_TRIGGER_PKG.ARI_T1  '  || substr(sqlerrm,1,1900);
  END ARI_T1 ;

  /*
  REM +======================================================================+
  REM NAME          ARI_T2
  REM
  REM DESCRIPTION   Called from trigger JAI_AR_RCTLA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_AR_RCTLA_ARI_T7
  REM
  REM +======================================================================+
  */
PROCEDURE ARI_T2 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
  --2001/05/03 Gadde,Jagdish6
v_currency_code         gl_sets_of_books.currency_code%TYPE;
v_gl_set_of_bks_id      NUMBER;
--2001/05/03 Gadde,Jagdish

  v_created_from                VARCHAR2(30);

  /* --Ramananda for File.Sql.35, start */
  v_org_id                      NUMBER; --:=pr_new.org_id;
  v_last_update_date            DATE; --   := pr_new.last_update_date;
  v_last_updated_by             NUMBER; -- := pr_new.last_updated_by;
  v_creation_date               DATE; --   := pr_new.creation_date;
  v_created_by                  NUMBER; -- := pr_new.created_by;
  v_last_update_login           NUMBER; -- := pr_new.last_update_login;
  v_interface_line_attribute3   VARCHAR2(30); -- :=  pr_new.interface_line_attribute3;
  v_interface_line_attribute6   VARCHAR2(30); -- :=  pr_new.interface_line_attribute6;
  v_customer_trx_line_id        NUMBER; -- := pr_new.customer_trx_line_id;
  v_header_id                   NUMBER; -- := pr_new.customer_trx_id;
  v_line_amount                 NUMBER; -- := nvl(pr_new.quantity_invoiced * pr_new.unit_selling_price,0);
  /* --Ramananda for File.Sql.35, end */

  x                             NUMBER;
  v_organization_id             NUMBER;
  v_location_id                 NUMBER;
  v_once_completed_flag         VARCHAR2(1);
  v_excise_amount               NUMBER; --File.Sql.35 Cbabu  := 0;
  v_trx_number                  VARCHAR2(20);
  v_tax_category_id             NUMBER;
  v_payment_register            VARCHAR2(15);
  v_excise_invoice_no           VARCHAR2(200);
  v_excise_invoice_date         DATE;
  v_tax_amount                  NUMBER; --File.Sql.35 Cbabu  := 0;
  v_excise_diff                 NUMBER; --File.Sql.35 Cbabu  := 0;
  v_assessable_value            NUMBER; --File.Sql.35 Cbabu  := 0;
  v_basic_excise_duty_amount    NUMBER; --File.Sql.35 Cbabu  := 0;
  v_add_excise_duty_amount      NUMBER; --File.Sql.35 Cbabu  := 0;
  v_oth_excise_duty_amount      NUMBER; --File.Sql.35 Cbabu  := 0;

  v_exist_flag                  NUMBER;--File.Sql.35 Cbabu  := 0;
  v_batch_source_id             NUMBER ;
  v_preprinted_excise_inv_no    VARCHAR2(50);
  v_books_id                    NUMBER;
  v_salesrep_id                 NUMBER;
  c_from_currency_code          VARCHAR2(15);
  c_conversion_type             VARCHAR2(30);
  c_conversion_date             DATE;
  c_conversion_rate             NUMBER;
  v_tax_line_no                 NUMBER;
  v_tax_catg_id                 NUMBER;
  v_excise_exempt_type          VARCHAR2(60);
  v_excise_exempt_refno         VARCHAR2(30);
  v_excise_exempt_date          DATE;
  v_exchange_rate   NUMBER;
  v_bill_to_customer_id   NUMBER;
  v_bill_to_site_use_id   NUMBER; /*Bug 8371741*/
  v_receipt_id      NUMBER;
  v_so_tax_amount   NUMBER;
  vsqlerrm      VARCHAR2(240);
  v_qty       NUMBER; -- added by sriram
  -- added, Harshita for bug#4245062
  lv_vat_exemption_flag       JAI_AR_TRX_LINES.vat_exemption_flag%TYPE ;
  lv_vat_exemption_type       JAI_AR_TRX_LINES.vat_exemption_type%TYPE ;
  lv_vat_exemption_date       JAI_AR_TRX_LINES.vat_exemption_date%TYPE ;
  lv_vat_exemption_refno      JAI_AR_TRX_LINES.vat_exemption_refno%TYPE ;
  ln_vat_assessable_value     JAI_AR_TRX_LINES.vat_assessable_value%TYPE    ;
  ln_vat_invoice_no           JAI_AR_TRXS.vat_invoice_no %TYPE ;
  ln_vat_invoice_date         JAI_AR_TRXS.vat_invoice_date%TYPE;
  -- ended, Harshita for bug#4245062

lv_appl_src  JAI_CMN_ERRORS_T.APPLICATION_SOURCE%type;
lv_err_msg   JAI_CMN_ERRORS_T.error_message%type;

ln_legal_entity_id NUMBER ; /* rallamse bug#4510143 */

v_service_type VARCHAR2(30);    -- added by csahoo for bug#5879769

-- Date 26-feb-2006 added by sacsethi for bug 5631784
-- for TCS enhancement
-- start 5631784
    ln_threshold_tax_cat_id         jai_ap_tds_thhold_taxes.tax_category_id%type;
-- start 5631784
----------------------

-- added by Allen Yang 02-Apr-2010 for bug 9485355 (non-sihppable enhancement), begin
CURSOR c_so_picking_hdr_info_ns
IS
SELECT jowla.organization_id
     , jowla.location_id
FROM   JAI_OM_WSH_LINES_ALL jowla
WHERE  order_line_id = TO_NUMBER(v_interface_line_attribute6)
  AND  shippable_flag = 'N';

CURSOR c_so_picking_tax_record_ns
IS
SELECT DISTINCT 1
FROM   JAI_OM_WSH_LINE_TAXES
WHERE  delivery_detail_id IS NULL
  AND  order_line_id    = TO_NUMBER(v_interface_line_attribute6);

CURSOR c_so_picking_tax_lines_info_ns
IS
SELECT   jowla.quantity
       , jowlt.tax_line_no
       , jowlt.uom
       , jowlt.tax_id
       , jowlt.tax_rate
       , jowlt.qty_rate
       , jowlt.base_tax_amount
       , jowlt.tax_amount
       , jcta.tax_type
       , jowlt.func_tax_amount
       , jowlt.precedence_1
       , jowlt.precedence_2
       , jowlt.precedence_3
       , jowlt.precedence_4
       , jowlt.precedence_5
       , jowlt.precedence_6
       , jowlt.precedence_7
       , jowlt.precedence_8
       , jowlt.precedence_9
       , jowlt.precedence_10
       , jowla.vat_invoice_no
       , jowla.vat_invoice_date
FROM     JAI_OM_WSH_LINE_TAXES jowlt
       , JAI_OM_WSH_LINES_ALL jowla
       , JAI_CMN_TAXES_ALL jcta
WHERE    jowlt.delivery_detail_id IS NULL
  AND    jowlt.order_line_id = jowla.order_line_id
  AND    jowlt.tax_id= jcta.tax_id
  AND    jcta.tax_type <> 'Modvat Recovery'
  AND    jowlt.order_line_id  = TO_NUMBER(v_interface_line_attribute6);

CURSOR c_so_picking_tax_amt_ns(p_tax_id NUMBER)
IS
SELECT SUM(base_tax_amount) base_tax_amount
     , SUM(tax_amount) tax_amount
     , SUM(func_tax_amount) func_tax_amount
FROM   JAI_OM_WSH_LINE_TAXES
WHERE  delivery_detail_id IS NULL
  AND  order_line_id = TO_NUMBER(v_interface_line_attribute6)
  AND  tax_id = p_tax_id
GROUP BY tax_id;

CURSOR c_so_picking_lines_info_ns
IS
SELECT tax_category_id,Quantity
     , (tax_amount/quantity) tax_amount
     ,  assessable_value
     , (basic_excise_duty_amount/quantity) basic_excise_duty_amount
     , (add_excise_duty_amount/quantity) add_excise_duty_amount
     , (oth_excise_duty_amount/quantity) oth_excise_duty_amount
     , register
     , excise_invoice_no
     , preprinted_excise_inv_no
     , excise_invoice_date
     , excise_exempt_type
     , excise_exempt_refno
     , excise_exempt_date
     , ar3_form_no
     , ar3_form_date
     , vat_exemption_flag
     , vat_exemption_type
     , vat_exemption_date
     , vat_exemption_refno
     , vat_assessable_value
     , vat_invoice_no
     , vat_invoice_date
FROM   JAI_OM_WSH_LINES_ALL
WHERE  delivery_id IS NULL
  AND  order_line_id  = TO_NUMBER(v_interface_line_attribute6);
-- added by Allen Yang 02-Apr-2010 for bug 9485355 (non-sihppable enhancement), end

-------------- cursor for st forms tracking -------------
  CURSOR GET_HEADER_DETAILS IS
  SELECT bill_to_customer_id,
           bill_to_site_use_id,
         trx_number,
         batch_source_id
    FROM RA_CUSTOMER_TRX_ALL
   WHERE customer_trx_id = pr_new.customer_trx_id;
 CURSOR GET_SITE(P_TRX_NUMBER VARCHAR2) IS
 SELECT customer_site
   FROM JAI_AR_SUP_HDRS_ALL
  WHERE supplementary_num = TO_NUMBER(p_trx_number);
-------------- cursor for st forms tracking -------------
  CURSOR GET_EXCHANGE_RATE IS
  SELECT exchange_rate
  FROM   ra_customer_trx_all
  WHERE  customer_trx_id = pr_new.customer_trx_id;
  CURSOR CREATED_FROM_CUR IS
  SELECT created_from, trx_number, batch_source_id, set_of_books_id, primary_salesrep_id,
           invoice_currency_code, exchange_rate_type, exchange_date, exchange_rate
  FROM   ra_customer_trx_all
  WHERE  customer_trx_id = v_header_id;

CURSOR SO_PICKING_HDR_INFO IS
  SELECT A.organization_id, A.location_id
  FROM   JAI_OM_WSH_LINES_ALL A,WSH_NEW_DELIVERIES B
  WHERE  A.delivery_id = B.DELIVERY_ID AND
         B.NAME = v_interface_line_attribute3 AND
         A.order_line_id         = TO_NUMBER(v_interface_line_attribute6);

/* Added by JMEENA for bug#5684033 */
  CURSOR so_picking_hdr_info_1 IS
  SELECT a.organization_id, a.location_id
  FROM   JAI_OM_WSH_LINES_ALL a
  WHERE  a.delivery_id = v_interface_line_attribute3
  AND    a.organization_id IS NOT NULL
  AND    a.location_id IS NOT NULL
  AND    rownum=1 ;

 /* Added by JMEENA for bug# 6498345 (FP 6492966) Starts */
  CURSOR c_ato_order IS
  SELECT
         1
  FROM
         oe_order_lines_all
  WHERE
         item_type_code IN ('CONFIG', 'MODEL', 'OPTION', 'CLASS')
    AND  line_id        =  (SELECT ato_line_id
                            FROM   oe_order_lines_all
                            WHERE  line_id = v_interface_line_attribute6 );

  /* Retrieve Org + Loc from ja_in_so_picking_lines from the Config (Start) Item */
  CURSOR c_ato_hdr_info IS
  SELECT
         organization_id, location_id
  FROM
         JAI_OM_WSH_LINES_ALL
  WHERE
         order_line_id IN  (SELECT line_id
                            FROM  oe_order_lines_all oel2
                            WHERE oel2.item_type_code = 'CONFIG'
                             AND  oel2.header_id = (
                                                SELECT header_id
                                                FROM  oe_order_lines_all oel
                                                WHERE oel.line_id = v_interface_line_attribute6)
                             AND oel2.ato_line_id = (SELECT ato_line_id
                                                 FROM oe_order_lines_all oel1
                                                 WHERE oel1.line_id = v_interface_line_attribute6))
  AND    organization_id is not null
  AND    location_id     is not null
  AND    rownum = 1 ;

  ln_order_ato NUMBER ;
  /* Added by JMEENA for bug#6498345(FP 6492966) Ends */

 CURSOR  JA_IN_RA_CUSTOMER_TRX_INFO  IS
  SELECT organization_id,
         Location_id
  FROM   JAI_AR_TRXS
  WHERE  customer_trx_id = TO_NUMBER(pr_new.interface_line_attribute4);  -- Replaced pr_new.interface_line_attribute1 , Bug 4392001
  CURSOR  JA_IN_RA_CUSTOMER_TRX_INFOCNSL IS
  SELECT A.organization_id,
         A.Location_id
  FROM   JAI_AR_TRXS A,
         JAI_AR_SUP_HDRS_ALL B,
         RA_CUSTOMER_TRX_ALL C
  WHERE  pr_new.customer_trx_id = c.customer_trx_id
  AND    c.trx_number = TO_CHAR(B.SUPPLEMENTARY_NUM)
  AND    B.customer_trx_id = A.customer_trx_id;

  CURSOR SO_PICKING_LINES_INFO IS  --12-APR-02
  SELECT tax_category_id,Quantity , -- Quantity Added By Sriram Bug #  .. Base Bug 2335923
       (tax_amount/quantity) tax_amount, --Added by Jagdish 30-Aug-01
           assessable_value, (basic_excise_duty_amount/quantity) basic_excise_duty_amount,
         (add_excise_duty_amount/quantity) add_excise_duty_amount,
           (oth_excise_duty_amount/quantity) oth_excise_duty_amount,
           register, excise_invoice_no,
         preprinted_excise_inv_no, excise_invoice_date,
           excise_exempt_type,  excise_exempt_refno, excise_exempt_date
                , ar3_form_no, ar3_form_date,            -- Vijay Shankar for Bug # 3181892
         vat_exemption_flag, vat_exemption_type, vat_exemption_date, vat_exemption_refno, vat_assessable_value, vat_invoice_no, vat_invoice_date  -- added, Harshita for bug#4245062
  FROM   JAI_OM_WSH_LINES_ALL a,wsh_new_deliveries b
  WHERE  A.delivery_id = b.delivery_id AND
         B.NAME = v_interface_line_attribute3 AND
         A.order_line_id         = TO_NUMBER(v_interface_line_attribute6);

  CURSOR SUPPLEMENT_LINES_INFO IS
  SELECT DISTINCT A.tax_category_id,
         (NVL(A.excise_diff_amt,0)+NVL(A.other_diff_amt,0)) TAX_AMT,
           NVL(A.excise_diff_amt,0) excise_diff,
         A.new_assessable_value
  FROM   JAI_AR_SUP_LINES A,
         ra_customer_trx_all b,
         ra_cust_trx_types_all c
  WHERE  B.CUST_TRX_TYPE_ID =  C.CUST_TRX_TYPE_ID
  AND    A.SUP_INV_TYPE = DECODE(C.TYPE,'DM','DB','CM','CR','INV','SI')
  AND    A.customer_trx_line_id = TO_NUMBER(pr_new.interface_line_attribute3)
  AND    pr_new.customer_trx_id = b.customer_trx_id;

  CURSOR SUPPLEMENT_LINES_INFO_CNSLDT IS
  SELECT SUM(NVL(A.excise_diff_amt,0))+SUM(NVL(A.other_diff_amt,0)) TAX_AMT,
           NVL(A.excise_diff_amt,0) excise_diff,
         A.new_assessable_value
  FROM   JAI_AR_SUP_LINES A,
         JAI_AR_SUP_HDRS_ALL b,
         ra_customer_trx_all c,
         ra_cust_trx_types_all e
  WHERE  pr_new.customer_trx_id = c.customer_trx_id
  AND    c.trx_number = TO_CHAR( b.SUPPLEMENTARY_NUM)
  AND    B.customer_trx_id = A.customer_trx_id
  AND    C.cust_trx_type_id = e.cust_trx_type_id
  AND    b.supp_inv_type = DECODE(e.TYPE,'DM','DB','CM','CR','INV','SI')
  AND    A.description = pr_new.description
  AND    A.sup_inv_type = b.supp_inv_type
  GROUP BY A.inventory_item_id ,
           A.new_assessable_value,
           b.supp_inv_type;

  CURSOR SUPPLEMENT_LINES_INFO_Tax_catg IS
  SELECT A.tax_category_id
  FROM   JAI_AR_SUP_LINES A,
         JAI_AR_SUP_HDRS_ALL b,
         ra_customer_trx_all c,
         ra_cust_trx_types_all D
  WHERE  pr_new.customer_trx_id = c.customer_trx_id
  AND    c.trx_number =TO_CHAR( b.SUPPLEMENTARY_NUM)
  AND    B.customer_trx_id = A.customer_trx_id
  AND    A.sup_inv_type = b.supp_inv_type
  AND    C.cust_trx_type_id = D.cust_trx_type_id
  AND    b.supp_inv_type = DECODE(D.TYPE,'DM','DB','CM','CR','INV','SI');

-- Date 23/02/2006 by sacsethi for bug 5228046
-- precedence 6 to 10
CURSOR SO_PICKING_TAX_LINES_INFO IS
  SELECT b.quantity ,        --Added by Jagdish 30-Aug-01
         A.tax_line_no,
         A.uom,
         A.tax_id,
         A.tax_rate,
         A.qty_rate,
         A.base_tax_amount,
         A.tax_amount,
         c.tax_type,
         A.func_tax_amount,
   A.precedence_1, A.precedence_2, A.precedence_3, A.precedence_4, A.precedence_5,
   A.precedence_6, A.precedence_7, A.precedence_8, A.precedence_9, A.precedence_10,
         b.vat_invoice_no,b.vat_invoice_date
  FROM   JAI_OM_WSH_LINE_TAXES A,JAI_OM_WSH_LINES_ALL  b,
         JAI_CMN_TAXES_ALL c, wsh_new_deliveries D
  WHERE  A.delivery_detail_id = b.delivery_detail_id
  AND    A.tax_id=c.tax_id
  and    c.tax_type <> 'Modvat Recovery'/*Bug 4881426 bduvarag*/
  AND    b.delivery_id = D.delivery_id
  AND    D.name = v_interface_line_attribute3
  AND    b.order_line_id         = TO_NUMBER(v_interface_line_attribute6);  --Added on 17-Apr-2002


  CURSOR SO_PICKING_TAX_AMT(p_tax_id NUMBER) IS
  SELECT SUM(A.base_tax_amount) base_tax_amount,
           SUM(A.tax_amount) tax_amount,
           SUM(A.func_tax_amount) func_tax_amount
  FROM   JAI_OM_WSH_LINE_TAXES A,JAI_OM_WSH_LINES_ALL        b,WSH_NEW_DELIVERIES C
  WHERE  A.delivery_detail_id = b.delivery_detail_id
  AND    b.delivery_id = c.delivery_id
  AND    c.NAME = v_interface_line_attribute3
  AND    b.order_line_id = TO_NUMBER(v_interface_line_attribute6)
  AND    A.tax_id = p_tax_id
  GROUP BY A.tax_id;  --17-Apr-2002

  v_base_tax_amount     NUMBER;
  v_tax_amt                     NUMBER;
  v_func_tax_amount     NUMBER;

  ln_first_time         NUMBER;


  CURSOR SUPPLEMENT_TAX_LINES IS
  SELECT DISTINCT A.tax_line_no,
         A.new_uom,
         A.new_tax_id,
         A.new_rate,
         A.new_qty_rate,
         (NVL(A.new_base_tax_amt,0) - NVL(A.old_base_tax_amt,0)) BASE_TAX_AMT,
         A.diff_amt,
         A.diff_amt FUNC_TAX_AMT,
         t.tax_type,
         t.stform_type
  FROM   JAI_AR_SUP_TAXES A,
         JAI_AR_SUP_LINES  b,
         ra_customer_trx_all C,
         ra_cust_trx_types_all D,
         JAI_CMN_TAXES_ALL t
  WHERE  A.link_to_cust_trx_line_id = b.customer_trx_line_id
  AND    A.sup_inv_type = b.sup_inv_type
  AND    b.customer_Trx_line_id = TO_NUMBER(pr_new.interface_line_attribute3)
  AND    pr_new.customer_trx_id = c.customer_trx_id
  AND    c.cust_trx_type_id = D.cust_trx_type_id
  AND    b.sup_inv_type = DECODE(D.TYPE,'DM','DB','CM','CR','INV','SI')
  AND    A.new_tax_id = t.tax_id
  ORDER BY A.tax_line_no;

  CURSOR SUPPLEMENT_TAX_LINES_CNSLDT IS
  SELECT A.new_uom,
         A.new_tax_id,
         A.new_rate,
         A.new_qty_rate,
         SUM(NVL(A.new_base_Tax_amt,0) - NVL(A.old_base_tax_amt,0)) BASE_TAX_AMT,
         SUM(A.diff_amt) DIFF_AMT,
         SUM(A.diff_amt) FUNC_TAX_AMT,
         t.tax_type,
         t.stform_type
  FROM   JAI_AR_SUP_TAXES A,
         JAI_AR_SUP_LINES b,
         JAI_AR_SUP_HDRS_ALL c,
         ra_customer_trx_all D,
         ra_cust_trx_types_all e,
           JAI_CMN_TAXES_ALL t
  WHERE  pr_new.customer_trx_id = D.customer_trx_id
  AND    D.trx_number = TO_CHAR(c.SUPPLEMENTARY_NUM)
  AND    c.customer_trx_id = b.customer_trx_id
  AND    b.customer_trx_line_id = A.link_to_cust_trx_line_id
  AND    b.sup_inv_type = A.sup_inv_type
  AND    b.description =  pr_new.description
  AND    c.supp_inv_type = b.sup_inv_type
  AND    e.cust_trx_type_id = D.cust_trx_type_id
  AND    c.supp_inv_type =  DECODE(e.TYPE,'DM','DB','CM','CR','INV','SI')
and    t.tax_type <> lc_modvat_tax/*Bug 4881426 bduvarag*/
  AND    A.new_tax_id = t.tax_id
  GROUP BY b.inventory_item_id,
           A.new_tax_id,
           A.new_uom,
           A.new_qty_rate,
           A.new_rate,
           t.tax_type,
           t.stform_type ;

  CURSOR DUPLICATE_HDR_CUR IS
  SELECT 1
  FROM   JAI_AR_TRXS
  WHERE  customer_trx_id = v_header_id;

  CURSOR ONCE_COMPLETE_FLAG_CUR IS
  SELECT once_completed_flag
  FROM   JAI_AR_TRXS
  WHERE  customer_trx_id = v_header_id;
  /* Cursor To Check Whether Interfaced Record Exist in JAI_OM_WSH_LINES_ALL */

CURSOR SO_PICKING_RECORD_CHECK IS
  SELECT 1
  FROM   JAI_OM_WSH_LINES_ALL A,WSH_NEW_DELIVERIES B
  WHERE  A.delivery_id = B.DELIVERY_ID AND
         B.NAME = v_interface_line_attribute3
  AND    A.order_line_id         = TO_NUMBER(v_interface_line_attribute6); --17-Apr-2002


  CURSOR SUPPLEMENT_LINES_CHECK IS
  SELECT 1
  FROM   JAI_AR_SUP_LINES
  WHERE  customer_trx_line_id = TO_NUMBER(pr_new.interface_line_attribute3);
  CURSOR SUPPLEMENT_LINES_CHECK_CNSLDT IS
  SELECT 1
  FROM    JAI_AR_SUP_LINES A,
          JAI_AR_SUP_HDRS_ALL B,
          RA_CUSTOMER_TRX_ALL C,
          RA_CUST_TRX_TYPES_ALL D
  WHERE   pr_new.CUSTOMER_TRX_ID = C.customer_trx_id
   AND    c.cust_trx_type_id = D.cust_trx_type_id
   AND    c.trx_number = TO_CHAR(b.SUPPLEMENTARY_NUM)
   AND    b.supp_inv_type = DECODE(D.TYPE,'INV','SI','CM','CR','DM','DB')
   AND    b.supp_inv_type = A.sup_inv_type
   AND    A.customer_trx_id = b.customer_trx_id;

  CURSOR SO_PICKING_TAX_RECORD_CHECK IS
  SELECT DISTINCT 1
  FROM   JAI_OM_WSH_LINE_TAXES A, JAI_OM_WSH_LINES_ALL  b, WSH_NEW_DELIVERIES C
  WHERE  A.delivery_detail_id = b.delivery_detail_id
  AND    b.delivery_id = C.DELIVERY_ID AND
         c.NAME = v_interface_line_attribute3
  AND    b.order_line_id         = TO_NUMBER(v_interface_line_attribute6);  --17-Apr-2002

  CURSOR SUPPLEMENT_TAX_LINES_CHECK IS
  SELECT 1
  FROM   JAI_AR_SUP_TAXES A, JAI_AR_SUP_LINES b
  WHERE  A.link_to_cust_trx_line_id = b.customer_trx_line_id
  AND    b.customer_trx_line_id = v_customer_Trx_line_id;

  CURSOR SUPPLEMENT_TAX_LINES_CHECK_CNS IS
   SELECT 1
   FROM   JAI_AR_SUP_LINES A,
          JAI_AR_SUP_HDRS_ALL B,
          RA_CUSTOMER_TRX_ALL C,
          RA_CUST_TRX_TYPES_ALL D,
          JAI_AR_SUP_TAXES E
  WHERE  pr_new.CUSTOMER_TRX_ID = C.customer_trx_id
   AND   c.cust_trx_type_id = D.cust_trx_type_id
   AND   c.trx_number = TO_CHAR(b.SUPPLEMENTARY_NUM)
   AND   b.supp_inv_type = DECODE(D.TYPE,'INV','SI','CM','CR','DM','DB')
   AND   b.supp_inv_type = A.sup_inv_type
   AND   A.customer_trx_id = b.customer_trx_id
   AND   E.link_to_cust_trx_line_id = A.customer_trx_line_id
   AND   A.sup_inv_type = e.sup_inv_type;

 CURSOR complete_flag_cur IS
  SELECT complete_flag
  FROM   ra_customer_trx_all
  WHERE  customer_trx_id = v_header_id;
  v_trans_type          VARCHAR2(30);

  CURSOR transaction_type_cur IS
  SELECT A.TYPE
  FROM   RA_CUST_TRX_TYPES_ALL A, RA_CUSTOMER_TRX_ALL b
  WHERE  A.cust_trx_type_id = b.cust_trx_type_id
  AND    b.customer_trx_id = v_header_id
  AND    NVL(A.org_id,0) = NVL(pr_new.org_id,0);
  /*  Code Added For Service Module */
  v_item_type_code                 VARCHAR2(50);
  v_serviced_quantity              NUMBER;
  v_return_reference_id            NUMBER;
  v_original_line_reference        VARCHAR2(50);
  v_customer_product_id            NUMBER;
  v_warehouse_id                             NUMBER;
  v_order_header_id                NUMBER;

  CURSOR So_Lines_Info_Cur IS
  SELECT item_type_code, serviced_quantity, return_reference_id, original_system_line_reference, customer_product_id,
         warehouse_id, header_id
  FROM   So_Lines_All
  WHERE  line_id = TO_NUMBER(v_interface_line_attribute6);

  CURSOR JA_SO_LINES_RECORD_CHECK IS
  SELECT 1
  FROM   JAI_OM_OE_SO_LINES
  WHERE  line_id         = TO_NUMBER(v_interface_line_attribute6);

  CURSOR JA_SO_LINES_TAX_RECORD_CHECK IS
  SELECT DISTINCT 1
  FROM   JAI_OM_OE_SO_TAXES A, JAI_OM_OE_SO_LINES  b
  WHERE  A.line_id         = TO_NUMBER(v_interface_line_attribute6)
  AND    A.line_id         = b.line_id;

-- Date 23/02/2006 by sacsethi for bug 5228046
-- precedence 6 to 10
  CURSOR JA_SO_TAX_LINES_INFO IS
  SELECT A.tax_line_no, A.uom, A.tax_id, A.tax_rate, A.qty_rate, A.base_tax_amount,A.tax_amount,
         A.func_tax_amount,
   A.precedence_1, A.precedence_2, A.precedence_3, A.precedence_4, A.precedence_5,
   A.precedence_6, A.precedence_7, A.precedence_8, A.precedence_9, A.precedence_10,
   c.tax_type
  FROM   JAI_OM_OE_SO_TAXES A, JAI_OM_OE_SO_LINES  b, JAI_CMN_TAXES_ALL c
  WHERE  A.line_id = b.line_id
  AND    b.line_id   = TO_NUMBER(v_interface_line_attribute6)
  AND    A.tax_id    = c.tax_id
and    c.tax_type <> lc_modvat_tax/*Bug 4881426 bduvarag*/
  ORDER BY A.tax_line_no;

  CURSOR ja_so_lines_info IS
  SELECT tax_category_id, tax_amount, assessable_value, excise_exempt_type,excise_exempt_refno, excise_exempt_date,
         vat_exemption_flag, vat_exemption_type, vat_exemption_date, vat_exemption_refno, vat_assessable_value   -- added, Harshita for bug#4245062
	 ,service_type_code  --Added by JMEENA for bug#8466638
  FROM   JAI_OM_OE_SO_LINES
  WHERE  line_id         = to_number(v_interface_line_attribute6);
  -- Bug 3357587
  CURSOR C_JA_SO_LINES_ASSESSABLE_VAL IS
  SELECT assessable_value, service_type_code  -- service_type_code added by csahoo for bug#5879769
       from JAI_OM_OE_SO_LINES
       WHERE  line_id         = TO_NUMBER(v_interface_line_attribute6);
  /* bug 5243532. Added by Lakshmi Gopalsami
     Removed the reference to cursor set_of_books_cur
     as the SOB will never be null in base table.
  */

  --ADDED TO CHECK DUPLICATE ENTRY FOR LINES 01-DEC-99 GAURAV.
 CURSOR DUPLICATE_LINES_CUR IS
  SELECT 1
  FROM   JAI_AR_TRX_LINES
  WHERE  customer_trx_LINE_id = v_customer_trx_line_id;

CURSOR OLD_CUSTOMER_TRX_ID_CUR IS
  SELECT Customer_Trx_Id
  FROM   JAI_AR_TRX_LINES
  WHERE  customer_trx_LINE_id = v_customer_trx_line_id;
 CURSOR DUPLICATE_TAX_LINES_CUR(v_tax_id NUMBER) IS
  SELECT 1
  FROM   JAI_AR_TRX_TAX_LINES
  WHERE  link_to_cust_trx_line_id = v_customer_trx_line_id
   AND   tax_id = v_tax_id;
 v_line_count                   NUMBER;
 v_tax_line_count               NUMBER;
 v_old_customer_trx_id        NUMBER;
--2001/04/11        JAGDISH BHOSLE

J_organization_id NUMBER;
J_location_id   NUMBER;
J_batch_source_id       NUMBER;
v_register_code         JAI_OM_OE_BOND_REG_HDRS.REGISTER_CODE%TYPE;

  CURSOR get_header_info_cur IS
  SELECT A.organization_id,
         A.location_id,
         A.order_type_id
  FROM   JAI_OM_WSH_LINES_ALL A,WSH_NEW_DELIVERIES B
 WHERE   A.delivery_id = B.DELIVERY_ID AND
         B.NAME = v_interface_line_attribute3
        AND    A.order_line_id   = TO_NUMBER(v_interface_line_attribute6);  --17-Apr-2002

 CURSOR get_register_code_cur(p_organization_id         NUMBER,
                              p_location_id       NUMBER,
                              p_batch_source_id   NUMBER) IS
 SELECT register_code
 FROM   JAI_OM_OE_BOND_REG_HDRS
 WHERE  organization_id = p_organization_id
 AND    location_id     = p_location_id
 AND    register_id IN (SELECT register_id
                                    FROM   JAI_OM_OE_BOND_REG_DTLS
                                    WHERE  order_type_id = p_batch_source_id
                            AND    order_flag = 'Y');


/*
The following cursor definition has been modified for performance reasons.
Using the nvl and the org_organization_definitions table was causing performance problems .
The modified explain plan has been compared with the previous and the performance is much
better with the modified one.
Sriram - Bug # 2668342 - Organization_id column is the operating_unit in the table.
*/

/* Bug 5243532. Added by Lakshmi Gopalsami
   Removed the cursor Fetch_Book_Id_cur which is referening to
   org_organization_definitions as we can get the SOB from the
   value assigned in the trigger

   Also removed the sob_cur as it is not used anywhere.
*/


--2001/05/03 Gadde,Jagdish
--2001/04/20 Anuradha Parthasarathy

CURSOR pref_cur(p_organization_id NUMBER, p_location_id NUMBER)IS
SELECT pref_rg23a, pref_rg23c, pref_pla
FROM JAI_CMN_INVENTORY_ORGS
WHERE organization_id = p_organization_id
AND location_id = p_location_id ;

v_pref_rg23a            NUMBER;
v_pref_rg23c            NUMBER;
v_pref_pla                      NUMBER;
v_ssi_unit_flag         VARCHAR2(1);
v_raise_error_flag      VARCHAR2(1);
v_fin_year                      NUMBER;
v_rg23a_balance         NUMBER;
v_rg23c_balance         NUMBER;
v_pla_balance           NUMBER;
v_reg_type                      VARCHAR2(10);
v_calc_tax_amount   NUMBER;

CURSOR fin_year_cur(p_org_id IN NUMBER) IS
SELECT MAX(A.fin_year)
FROM   JAI_CMN_FIN_YEARS A
WHERE  organization_id = p_org_id AND fin_active_flag = 'Y';

CURSOR rg_bal_cur(p_organization_id NUMBER, p_location_id NUMBER)IS
SELECT NVL(rg23a_balance,0) rg23a_balance ,NVL(rg23c_balance,0) rg23c_balance,NVL(pla_balance,0) pla_balance
FROM JAI_CMN_RG_BALANCES
WHERE organization_id = p_organization_id
AND location_id = p_location_id ;

CURSOR ssi_unit_flag_cur(p_organization_id IN  NUMBER, p_location_id IN NUMBER) IS
SELECT ssi_unit_flag
FROM   JAI_CMN_INVENTORY_ORGS
WHERE  organization_id = p_organization_id AND
location_id = p_location_id;

CURSOR register_code_cur(p_org_id IN NUMBER,  p_loc_id IN NUMBER, p_batch_source_id IN NUMBER)  IS
SELECT register_code
FROM   JAI_OM_OE_BOND_REG_HDRS
WHERE  organization_id = p_org_id AND
location_id     = p_loc_id  AND
register_id IN (SELECT register_id FROM   JAI_OM_OE_BOND_REG_DTLS
WHERE  order_type_id = p_batch_source_id AND order_flag ='N');

CURSOR Register_Code_Meaning_Cur(p_register_code IN VARCHAR2, cp_lookup_type So_lookups.lookup_type%TYPE ) IS
SELECT meaning
FROM   So_lookups
WHERE  lookup_code = p_register_code
AND    lookup_type = cp_lookup_type; /* 'REGISTER_TYPE'; Ramananda for removal of SQL LITERALs */

v_meaning                               VARCHAR2(80);

CURSOR Batch_Source_Name_Cur(p_batch_source_id IN NUMBER) IS
SELECT name
FROM   Ra_Batch_Sources_All
WHERE  batch_source_id = p_batch_source_id
AND    NVL(org_id,0)   = NVL(pr_new.org_id,0);

v_order_invoice_type            VARCHAR2(50);

CURSOR Def_Excise_Invoice_Cur(p_organization_id IN NUMBER, p_location_id IN NUMBER, p_fin_year IN NUMBER,
                                p_batch_name IN VARCHAR2, p_register_code IN VARCHAR2) IS
SELECT start_number, end_number, jump_by, prefix
FROM   JAI_CMN_RG_EXC_INV_NOS
WHERE  organization_id               = p_organization_id
AND    location_id                   = p_location_id
AND    fin_year                      = p_fin_year
AND    transaction_type               = 'I'
AND    order_invoice_type             = p_batch_name
AND    register_code                 = p_register_code ;
/* Modified by Ramananda for removal of SQL LITERALs */
--AND    NVL(order_invoice_type,'###') = p_batch_name
--AND    NVL(register_code,'###')      = NVL(p_register_code,'***');

v_start_number                  NUMBER;
v_end_number                    NUMBER;
v_jump_by                       NUMBER;
v_prefix                                VARCHAR2(50);
v_exc_invoice_no                        VARCHAR2(200);
v_reg_code                              VARCHAR2(30);
CURSOR ec_code_cur(p_organization_id IN NUMBER, p_location_id IN NUMBER) IS
SELECT A.Organization_Id, A.Location_Id
FROM   JAI_CMN_INVENTORY_ORGS A
WHERE  A.Ec_Code IN (SELECT B.Ec_Code
                       FROM   JAI_CMN_INVENTORY_ORGS B
                       WHERE  B.Organization_Id = p_organization_id
                       AND    B.Location_Id     = p_location_id);

v_source_name           VARCHAR2(100);  --File.Sql.35 Cbabu  := 'Receivables India';
v_category_name         VARCHAR2(100); --File.Sql.35 Cbabu  := 'RG Register Data Entry';

v_rg23_part_ii_no               NUMBER;
v_rg23_part_i_no        NUMBER;
v_pla_register_no               NUMBER;
v_part_i_register_id    NUMBER ;

CURSOR site_cur IS
SELECT SHIP_TO_CUSTOMER_ID,SHIP_TO_SITE_USE_ID
FROM   ra_customer_trx_all
WHERE  customer_trx_id = pr_new.customer_trx_id
AND    org_id = pr_new.org_id;

rec_so_lines        JA_SO_LINES_INFO%rowtype; --Added by JMEENA for bug#8466638

v_ship_id                       NUMBER;
v_ship_site_id          NUMBER;
v_bond_tax_amt          NUMBER;         -- cbabu for Bug# 2779990

--Start of bug 3328871
/*
 Query modified by aiyer for the bug 3328871
 Nvl clause has been added to ascertain that a value of zero
 gets inserted even if where clause fails to retrieve a record.
*/
--Modified by Xiao for bug#9737639 on 28-May-2010
-- bug # 3000550 sriram
/*cursor c_cust_trx_tax_line_amt is
select nvl(sum(tax_amount),0)
from   JAI_AR_TRX_TAX_LINES
where  link_to_cust_trx_line_id = v_customer_trx_line_id;*/
-- bug # 3000550 sriram
CURSOR c_cust_trx_tax_line_amt IS
SELECT nvl(SUM(a.tax_amount),0)
FROM   JAI_AR_TRX_TAX_LINES a, JAI_CMN_TAXES_ALL b
WHERE  link_to_cust_trx_line_id = v_customer_trx_line_id
AND    a.tax_id = b.tax_id
AND    nvl(b.inclusive_tax_flag, 'N') = 'N';
--Modified by Xiao for bug#9737639 on 28-May-2010
-- End of bug 3328871

--2001/04/20 Anuradha Parthasarathy

V_REGISTER_ID Number; -- bug # 3021588


-- Added an internal procedure for processing ATO Orders Bug # 2806274 - Sriram

v_so_line_id       Number;
v_item_type        oe_order_lines_all.item_type_code%type;
v_ato_line_id      Varchar2(30);
v_config_line_id   Number;
v_ex_inv_no        JAI_OM_WSH_LINES_ALL.excise_invoice_no%type;
v_pmt_reg          JAI_OM_WSH_LINES_ALL.register%type;
v_pre_prnt_ex_no   JAI_OM_WSH_LINES_ALL.preprinted_excise_inv_no%type;
v_ato_line_amount  Number;
v_ato_tax_amount   Number;
v_ato_total_amount Number;
-- v_ar3_form_no      Number;
v_ar3_form_no      JAI_AR_TRX_LINES.ar3_form_no%TYPE;                -- Vijay shankar for Bug # 3181892
v_ar3_form_date    Date;

/*
start additions by sriram - bug# 3607101
*/
cursor c_ont_source_code is
select FND_PROFILE.VALUE('ONT_SOURCE_CODE')
from   dual;
v_ont_source_code ra_interface_lines_all.interface_line_context%type;
/*
ends here additions by sriram -bug#3607101
*/

cursor c_bill_only_invoice(cp_customer_trx_line_id number, cp_process_name oe_wf_line_assign_v.process_name%type ) is
 select  1
 from    oe_wf_order_assign_v o_wf_asg
 where   order_type_name = pr_new.interface_line_attribute2
 and     exists
 (
  select  1
  from    oe_wf_line_assign_v  l_wf_asg
  where   assignment_id = o_wf_asg.assignment_id
  and     process_name  = cp_process_name  /*'R_BILL_ONLY' Ramananda for removal of SQL LITERALs */
  and     order_type_id = l_wf_asg.order_type_id
 )
;

  /* Added by  JMEENA for bug#6391684( FP of 6386592), Starts */
  CURSOR c_duplicate_tax(cp_tax_id JAI_AR_TRX_TAX_LINES.tax_id%TYPE,
                         cp_link_cust_trx_line_id JAI_AR_TRX_TAX_LINES.link_to_cust_trx_line_id%TYPE)
  IS
  SELECT 1
  FROM  JAI_AR_TRX_TAX_LINES
  WHERE tax_id = cp_tax_id
  AND   link_to_cust_trx_line_id = cp_link_cust_trx_line_id ;

  ln_tax_exist NUMBER;
  /* Added by JMEENA for bug#6391684( FP of 6386592), Ends */

ln_bill_only number;  --File.Sql.35 Cbabu  := 0;


/* added rallamse bug#4448789 */
FUNCTION get_legal_entity_id RETURN NUMBER IS

  CURSOR cur_legal_entity_id IS
  SELECT legal_entity_id
  FROM   RA_CUSTOMER_TRX_ALL
  WHERE  customer_trx_id = pr_new.customer_trx_id ;

  ln_legal_entity_id NUMBER ;

BEGIN
    pv_return_code := jai_constants.successful ;

  FND_FILE.PUT_LINE(FND_FILE.LOG, '  Function get_legal_entity_id');

  OPEN  cur_legal_entity_id ;
  FETCH cur_legal_entity_id INTO ln_legal_entity_id ;
  CLOSE cur_legal_entity_id ;

  FND_FILE.PUT_LINE(FND_FILE.LOG, ' Legal Entity Id: '|| ln_legal_entity_id);

  RETURN ln_legal_entity_id ;

END get_legal_entity_id ;
/* end bug#4448789 */

Procedure Process_Taxes_for_ATO_Order is

cursor c_item_type is
select item_type_code
from   oe_order_lines_all
where  line_id = v_interface_line_attribute6;

Cursor c_om_taxes(v_so_config_line_id Number) is
select *
from   JAI_OM_OE_SO_TAXES
where  line_id = v_so_config_line_id;

Cursor  c_get_config_line_id(v_ato_line_id Varchar2, cp_item_code  oe_order_lines_all.item_type_code%type) is
Select  line_id
from    oe_order_lines_all
where   ato_line_id = v_ato_line_id
and     item_type_code = cp_item_code;  /*'CONFIG'; Ramananda for removal of SQL LITERALs */

CURSOR  c_get_om_lines(v_ato_line_id Varchar2) is
SELECT  *
FROM    JAI_OM_OE_SO_LINES
WHERE   line_id = v_ato_line_id;

cursor  c_so_picking_data (v_ato_line_id Varchar2) is
SELECT  excise_invoice_no , register , preprinted_excise_inv_no , ar3_form_no ,ar3_form_date
FROM    JAI_OM_WSH_LINES_ALL
WHERE   order_line_id = v_ato_line_id;

CURSOR so_ato_picking_hdr_info(v_ato_line_id Varchar2) IS
SELECT a.organization_id, a.location_id
FROM   JAI_OM_WSH_LINES_ALL a,wsh_new_deliveries b
WHERE  a.delivery_id = b.delivery_id and
       B.NAME = v_interface_line_attribute3 AND
       A.order_line_id   = TO_NUMBER(v_ato_line_id);

CURSOR c_get_tax_info(p_tax_id Number) is
SELECT tax_type
FROM   JAI_CMN_TAXES_ALL
WHERE  tax_id = p_tax_id;

v_tax_type   JAI_CMN_TAXES_ALL.tax_type%type;
v_tax_amount Number; --File.Sql.35 Cbabu  :=0;

ln_legal_entity_id NUMBER ; /* rallamse bug#4510143 */
  /* Added by JMEENA for bug#6391684 (FP 6061010 )*/
  ln_hdr_exist_chk number;
BEGIN
  pv_return_code := jai_constants.successful ;

  FND_FILE.PUT_LINE(FND_FILE.LOG, ' Inside Procedure Process_Taxes_for_ATO_Order');
  FND_FILE.PUT_LINE(FND_FILE.LOG,'ATO: v_item_type: ' || v_item_type); -- Added for bug#6498345 by JMEENA
  v_tax_amount  :=0;

 open  c_item_type;
 fetch c_item_type into v_item_type;
 close c_item_type;

 FND_FILE.PUT_LINE(FND_FILE.LOG, ' Item type'|| v_item_type);

 if NVL(v_item_type,'$$$') = 'MODEL' then
  IF (NVL(pr_new.Interface_line_attribute11,'0') ='0'
      and nvl(v_ont_source_code,'ORDER ENTRY') = ltrim(rtrim(pr_new.interface_line_context)) -- added by sriram - bug# 3607101
     ) /* following OR added by sriram - bug#3607101 */
  or
     (nvl(v_ont_source_code,'ORDER ENTRY') <> nvl(ltrim(rtrim(pr_new.interface_line_context)),'$$$')  -- added by sriram - bug# 3607101
     )
  then
    -- using the following cursor , we get the line_id
    -- of the 'config' item in oe_order_lines_all
    Open    c_get_config_line_id(v_interface_line_attribute6, 'CONFIG'); /* Modified by Ramananda for removal of SQL LITERALs */
    Fetch   c_get_config_line_id into v_config_line_id;
    Close   c_get_config_line_id;

    FND_FILE.PUT_LINE(FND_FILE.LOG, ' Config line id ' || v_config_line_id);

    -- the variable v_config_line_id holds the line_id of the
    -- config item corresponding to the 'Model' item being imported.

    For  so_taxes_rec in c_om_taxes(v_config_line_id)
    Loop
     Open   c_get_tax_info(so_taxes_rec.tax_id);
     Fetch  c_get_tax_info into v_tax_type;
     close  c_get_tax_info;

     FND_FILE.PUT_LINE(FND_FILE.LOG, ' Tax Type: '|| v_tax_type);

     IF V_REGISTER_CODE ='BOND_REG' THEN

  FND_FILE.PUT_LINE(FND_FILE.LOG, ' Inside BOND Register');
      /* jai_constants.tax_type_sh_exc_edu_cess, jai_constants.tax_type_sh_cvd_edu_cess added by CSahoo Bug#5989740*/
      IF v_tax_type NOT IN ('Excise','Other Excise','CVD_EDUCATION_CESS','EXCISE_EDUCATION_CESS',jai_constants.tax_type_sh_cvd_edu_cess, jai_constants.tax_type_sh_exc_edu_cess) THEN
/* 'CVD_EDUCATION_CESS','EXCISE_EDUCATION_CESS' added by ssumaith - bug# 4136981*/
-- Date 23/02/2006 by sacsethi for bug 5228046
-- precedence 6 to 10
       INSERT INTO JAI_AR_TRX_TAX_LINES
       (
       tax_line_no                    ,
       customer_trx_line_id           ,
       link_to_cust_trx_line_id       ,
       precedence_1                   ,
       precedence_2                   ,
       precedence_3                   ,
       precedence_4                   ,
       precedence_5                   ,
       precedence_6                   ,
       precedence_7                   ,
       precedence_8                   ,
       precedence_9                   ,
       precedence_10                   ,
       tax_id                         ,
       tax_rate                       ,
       qty_rate                       ,
       uom                            ,
       tax_amount                     ,
       func_tax_amount                ,
       base_tax_amount                ,
       creation_date                  ,
       created_by                     ,
       last_update_date               ,
       last_updated_by                ,
       last_update_login
       )
       VALUES
       (so_taxes_rec.tax_line_no,
        ra_customer_trx_lines_s.nextval,
        v_customer_trx_line_id,
        so_taxes_rec.precedence_1,
        so_taxes_rec.precedence_2,
        so_taxes_rec.precedence_3,
        so_taxes_rec.precedence_4,
        so_taxes_rec.precedence_5,
        so_taxes_rec.precedence_6,
        so_taxes_rec.precedence_7,
        so_taxes_rec.precedence_8,
        so_taxes_rec.precedence_9,
        so_taxes_rec.precedence_10,
  so_taxes_rec.tax_id,
        so_taxes_rec.tax_rate,
        so_taxes_rec.qty_rate,
        so_taxes_rec.uom,
        so_taxes_rec.tax_amount,
        so_taxes_rec.base_tax_amount,
        so_taxes_rec.func_tax_amount,
        sysdate,
        so_taxes_rec.created_by,
        sysdate,
        so_taxes_rec.last_updated_by,
        so_taxes_rec.last_update_login
       );

      FND_FILE.PUT_LINE(FND_FILE.LOG, ' After insert into JAI_AR_TRX_TAX_LINES');

       v_tax_amount := NVL(v_tax_amount,0) + NVL(so_taxes_rec.tax_amount,0);

       FND_FILE.PUT_LINE(FND_FILE.LOG,' Tax amount: '|| v_tax_amount);

      end if;  -- for 'tax type'
     else

     -- handle for the case where the register code is not BOND_REG
-- Date 23/02/2006 by sacsethi for bug 5228046
-- precedence 6 to 10
     INSERT INTO JAI_AR_TRX_TAX_LINES
            (
            TAX_LINE_NO                    ,
            CUSTOMER_TRX_LINE_ID           ,
            LINK_TO_CUST_TRX_LINE_ID       ,
            PRECEDENCE_1                   ,
            PRECEDENCE_2                   ,
            PRECEDENCE_3                   ,
            PRECEDENCE_4                   ,
            PRECEDENCE_5                   ,
            PRECEDENCE_6                   ,
            PRECEDENCE_7                   ,
            PRECEDENCE_8                   ,
            PRECEDENCE_9                   ,
            PRECEDENCE_10                   ,
      TAX_ID                         ,
            TAX_RATE                       ,
            QTY_RATE                       ,
            UOM                            ,
            TAX_AMOUNT                     ,
            FUNC_TAX_AMOUNT                ,
            BASE_TAX_AMOUNT                ,
            CREATION_DATE                  ,
            CREATED_BY                     ,
            LAST_UPDATE_DATE               ,
            LAST_UPDATED_BY                ,
            LAST_UPDATE_LOGIN
            )
            values
            (so_taxes_rec.tax_line_no,
             ra_customer_trx_lines_s.nextval,
             v_customer_trx_line_id,
             so_taxes_rec.precedence_1,
             so_taxes_rec.precedence_2,
             so_taxes_rec.precedence_3,
             so_taxes_rec.precedence_4,
             so_taxes_rec.precedence_5,
             so_taxes_rec.precedence_6,
             so_taxes_rec.precedence_7,
             so_taxes_rec.precedence_8,
             so_taxes_rec.precedence_9,
             so_taxes_rec.precedence_10,
       so_taxes_rec.tax_id,
             so_taxes_rec.tax_rate,
             so_taxes_rec.qty_rate,
             so_taxes_rec.uom,
             so_taxes_rec.tax_amount,
             so_taxes_rec.base_tax_amount,
             so_taxes_rec.func_tax_amount,
             sysdate,
             so_taxes_rec.created_by,
             sysdate,
             so_taxes_rec.last_updated_by,
             so_taxes_rec.last_update_login
            );
        FND_FILE.PUT_LINE(FND_FILE.LOG,
               ' Else - After insert into JAI_AR_TRX_TAX_LINES');
        v_tax_amount := NVL(v_tax_amount,0) + NVL(so_taxes_rec.tax_amount,0);
        FND_FILE.PUT_LINE(FND_FILE.LOG, ' Tax amount: '|| v_tax_amount);

     end if; -- for 'BOND_REG'
    End Loop;

-- creation of item line equivalent.


   Open  c_so_picking_data(v_config_line_id);
   fetch c_so_picking_data into  v_ex_inv_no , v_pmt_reg , v_pre_prnt_ex_no , v_ar3_form_no , v_ar3_form_date;
   close c_so_picking_data;

   FND_FILE.PUT_LINE(FND_FILE.LOG, ' Excise invoice number: '|| v_ex_inv_no);
   FND_FILE.PUT_LINE(FND_FILE.LOG, ' Pmt reg: ' ||v_pmt_reg);
   FND_FILE.PUT_LINE(FND_FILE.LOG, ' Pre print ex. no : '|| v_pre_prnt_ex_no);
   FND_FILE.PUT_LINE(FND_FILE.LOG, ' AR3 form no.: '|| v_ar3_form_no);
   FND_FILE.PUT_LINE(FND_FILE.LOG, ' AR3 form date '||v_ar3_form_date);

   /* JMEENA for bug#6391684( FP of 6061010), Starts */
     open duplicate_hdr_cur;
     fetch duplicate_hdr_cur into ln_hdr_exist_chk;
     close duplicate_hdr_cur;

     if nvl(ln_hdr_exist_chk,0) = 1 then
       open   so_ato_picking_hdr_info(v_config_line_id);
       fetch  so_ato_picking_hdr_info into v_organization_id , v_location_id;
       close  so_ato_picking_hdr_info;

       FND_FILE.PUT_LINE(FND_FILE.LOG, 'ATO: 1. v_organization_id , v_location_id: ' ||  v_organization_id || ' , ' ||  v_location_id );

       IF v_organization_id IS NULL THEN
         open   so_picking_hdr_info_1 ;
         fetch  so_picking_hdr_info_1 into v_organization_id , v_location_id;
         close  so_picking_hdr_info_1;

		 FND_FILE.PUT_LINE(FND_FILE.LOG,'ATO: 2. v_organization_id , v_location_id: ' ||  v_organization_id || ' , ' ||  v_location_id );

       END IF ;

       update JAI_AR_TRXS
       set organization_id    = nvl(organization_id, v_organization_id)
          , location_id       = nvl(location_id, v_location_id)
          , last_update_date  = sysdate
       where customer_trx_id  = v_header_id;
 /* Added by JMEENA for bug# 6391684 (FP of 6386592), Starts */
     ELSIF nvl(ln_hdr_exist_chk,0) <> 1 THEN

       OPEN   CREATED_FROM_CUR;
       FETCH  CREATED_FROM_CUR INTO v_created_from, v_trx_number, v_batch_source_id, v_books_id,
                                        v_salesrep_id, c_from_currency_code, c_conversion_type,
                                c_conversion_date, c_conversion_rate ;
       CLOSE  CREATED_FROM_CUR;

       FND_FILE.PUT_LINE(FND_FILE.LOG,' Created from: '|| v_created_from);
       FND_FILE.PUT_LINE(FND_FILE.LOG,' Trx number : ' ||v_trx_number);
       FND_FILE.PUT_LINE(FND_FILE.LOG,' Batch source id '|| v_batch_source_id);
       FND_FILE.PUT_LINE(FND_FILE.LOG,' SOB id : '|| v_books_id);
       FND_FILE.PUT_LINE(FND_FILE.LOG,' Salesrep. id '||v_salesrep_id);
       FND_FILE.PUT_LINE(FND_FILE.LOG,' From currency code '||c_from_currency_code);
       FND_FILE.PUT_LINE(FND_FILE.LOG,' conversion type: '||c_conversion_type);
       FND_FILE.PUT_LINE(FND_FILE.LOG,' conversion date: '||c_conversion_date);
       FND_FILE.PUT_LINE(FND_FILE.LOG,' conversion rate: '||c_conversion_rate);

       OPEN   SO_ATO_PICKING_HDR_INFO(v_config_line_id);
       Fetch  SO_ATO_PICKING_HDR_INFO into v_organization_id , v_location_id;
       close  SO_ATO_PICKING_HDR_INFO;

       FND_FILE.PUT_LINE(FND_FILE.LOG,' Org id: '|| v_organization_id);
       FND_FILE.PUT_LINE(FND_FILE.LOG,' Loc id: '||v_location_id);

       ln_legal_entity_id := get_legal_entity_id ;
    /* Added by JMEENA for bug#5684033*/
       IF v_organization_id IS NULL THEN
         open   so_picking_hdr_info_1 ;
         fetch  so_picking_hdr_info_1 into v_organization_id , v_location_id;
         close  so_picking_hdr_info_1;
		 FND_FILE.PUT_LINE(FND_FILE.LOG,' ATO: Org id: '|| v_organization_id);
         FND_FILE.PUT_LINE(FND_FILE.LOG,' ATO: Loc id: '|| v_location_id);
       END IF ;


       Insert into JAI_AR_TRXS
       (
       CUSTOMER_TRX_ID                ,
       ORGANIZATION_ID                ,
       LOCATION_ID                    ,
       UPDATE_RG_FLAG                 ,
       ONCE_COMPLETED_FLAG            ,
       TOTAL_AMOUNT                   ,
       LINE_AMOUNT                    ,
       TAX_AMOUNT                     ,
       TRX_NUMBER                     ,
       BATCH_SOURCE_ID                ,
       CREATION_DATE                  ,
       CREATED_BY                     ,
       LAST_UPDATE_DATE               ,
       LAST_UPDATED_BY                ,
       LAST_UPDATE_LOGIN              ,
       SET_OF_BOOKS_ID                ,
       PRIMARY_SALESREP_ID            ,
       INVOICE_CURRENCY_CODE          ,
       EXCHANGE_RATE_TYPE             ,
       EXCHANGE_DATE                  ,
       EXCHANGE_RATE                  ,
       CREATED_FROM                   ,
       UPDATE_RG23D_FLAG              ,
       LEGAL_ENTITY_ID         /* rallamse bug#4448789 */
       )
       Values
       (
       v_header_id,
       v_organization_id,
       v_location_id,
       'Y',
       'N',/*Bug 4694650 bduvarag*/
       v_ato_total_amount,
       v_ato_line_amount,
       v_ato_tax_amount,
       v_trx_number,
       v_batch_source_id,
       sysdate,
       uid,
       sysdate,
       uid,
       uid,
       v_books_id,
       v_salesrep_id,
       c_from_currency_code,
       c_conversion_type,
       c_conversion_date,
       c_conversion_rate,
       v_created_from,
       'Y',
       ln_legal_entity_id        /* rallamse bug#4448789 */
   );

   FND_FILE.PUT_LINE(FND_FILE.LOG,'After insert into JAI_AR_TRXS ');
        /* Added by JMEENA for bug# 6391684( FP of 6386592), Ends */
     end if;
     /* JMEENA for bug#6391684( FP of 6061010), Ends */

   /*added by csahoo for bug#5879769*/
    OPEN c_get_address_details(v_header_id);
    FETCH c_get_address_details into r_add;
    CLOSE c_get_address_details;

    v_service_type:=get_service_type( NVL(r_add.SHIP_TO_CUSTOMER_ID ,r_add.BILL_TO_CUSTOMER_ID) ,
                            NVL(r_add.SHIP_TO_SITE_USE_ID, r_add.BILL_TO_SITE_USE_ID),'C');

   for so_line_rec in c_get_om_lines(v_config_line_id)
    Loop
     Insert into JAI_AR_TRX_LINES
     (
       customer_trx_line_id           ,
       customer_trx_id                ,
       line_number                    ,
       inventory_item_id              ,
       description                    ,
       unit_code                      ,
       quantity                       ,
       unit_selling_price             ,
       tax_category_id                ,
       line_amount                    ,
       tax_amount                     ,
       total_amount                   ,
       auto_invoice_flag              ,
       assessable_value               ,
       creation_date                  ,
       created_by                     ,
       last_update_date               ,
       last_updated_by                ,
       last_update_login              ,
       excise_exempt_type             ,
       excise_exempt_refno            ,
       excise_exempt_date             ,
       excise_invoice_no              ,
       payment_register               ,
       preprinted_excise_inv_no       ,
       ar3_form_no                    ,
       ar3_form_date                  ,
       vat_exemption_flag             , -- added, harshita for bug#4245062
       vat_exemption_type             ,
       vat_exemption_date             ,
       vat_exemption_refno            ,
       vat_assessable_value           ,
       service_type_code                --Added by csahoo for Bug#5879769
     )
       Values
     (
       v_customer_trx_line_id,
       v_header_id,
       pr_new.line_number,
       pr_new.inventory_item_id,
       pr_new.description,
       so_line_rec.unit_code,
       so_line_rec.quantity,
       so_line_rec.selling_price,
       so_line_rec.tax_category_id,
       so_line_rec.line_amount,
       v_tax_amount,
       so_line_rec.line_amount + v_tax_amount,
       'Y',
       so_line_rec.assessable_value,
       sysdate,
       so_line_rec.created_by,
       sysdate,
       so_line_rec.last_updated_by,
       so_line_rec.last_update_login,
       so_line_rec.excise_exempt_type,
       so_line_rec.excise_exempt_refno,
       so_line_rec.excise_exempt_date,
       v_ex_inv_no ,
       v_pmt_reg ,
       v_pre_prnt_ex_no,
       v_ar3_form_no ,
       v_ar3_form_date,
       so_line_rec.vat_exemption_flag,  -- added, Harshita for bug#4245062
       so_line_rec.vat_exemption_type,
       so_line_rec.vat_exemption_date,
       so_line_rec.vat_exemption_refno,
       so_line_rec.vat_assessable_value,
       v_service_type                     --Added by csahoo for Bug#5879769
      );

     FND_FILE.PUT_LINE(FND_FILE.LOG,' Cursor . c_get_om_lines ');
     FND_FILE.PUT_LINE(FND_FILE.LOG,
              ' Inserted  jai_ar_trx_lines for TRX LINE ID: '||v_customer_trx_line_id);
     FND_FILE.PUT_LINE(FND_FILE.LOG,' Trx id: ' || v_header_id);

     v_ato_line_amount := so_line_rec.line_amount;
     v_ato_tax_amount := NVL(v_ato_tax_amount,0) + NVL(v_tax_amount,0);
     v_ato_total_amount := NVL(v_ato_total_amount,0) + NVL(so_line_rec.line_amount,0) + NVL(v_ato_tax_amount,0);
     FND_FILE.PUT_LINE(FND_FILE.LOG, ' Ato tax amount: '||v_ato_tax_amount);
     FND_FILE.PUT_LINE(FND_FILE.LOG, ' Ato tot amount: '||v_ato_total_amount);
    end loop;


    -- creation of record in JAI_AR_TRXS
/* Commented for bug# 6391684 (Fp of 6386592), Starts */
       /*OPEN   CREATED_FROM_CUR;
       FETCH  CREATED_FROM_CUR INTO v_created_from, v_trx_number, v_batch_source_id, v_books_id,
                                        v_salesrep_id, c_from_currency_code, c_conversion_type,
                                c_conversion_date, c_conversion_rate ;
       CLOSE  CREATED_FROM_CUR;

       FND_FILE.PUT_LINE(FND_FILE.LOG,' Created from: '|| v_created_from);
       FND_FILE.PUT_LINE(FND_FILE.LOG,' Trx number : ' ||v_trx_number);
       FND_FILE.PUT_LINE(FND_FILE.LOG,' Batch source id '|| v_batch_source_id);
       FND_FILE.PUT_LINE(FND_FILE.LOG,' SOB id : '|| v_books_id);
       FND_FILE.PUT_LINE(FND_FILE.LOG,' Salesrep. id '||v_salesrep_id);
       FND_FILE.PUT_LINE(FND_FILE.LOG,' From currency code '||c_from_currency_code);
       FND_FILE.PUT_LINE(FND_FILE.LOG,' conversion type: '||c_conversion_type);
       FND_FILE.PUT_LINE(FND_FILE.LOG,' conversion date: '||c_conversion_date);
       FND_FILE.PUT_LINE(FND_FILE.LOG,' conversion rate: '||c_conversion_rate);

       OPEN   SO_ATO_PICKING_HDR_INFO(v_config_line_id);
       Fetch  SO_ATO_PICKING_HDR_INFO into v_organization_id , v_location_id;
       close  SO_ATO_PICKING_HDR_INFO;

       FND_FILE.PUT_LINE(FND_FILE.LOG,' Org id: '|| v_organization_id);
       FND_FILE.PUT_LINE(FND_FILE.LOG,' Loc id: '||v_location_id);

       ln_legal_entity_id := get_legal_entity_id ;

       Insert into JAI_AR_TRXS
       (
       CUSTOMER_TRX_ID                ,
       ORGANIZATION_ID                ,
       LOCATION_ID                    ,
       UPDATE_RG_FLAG                 ,
       ONCE_COMPLETED_FLAG            ,
       TOTAL_AMOUNT                   ,
       LINE_AMOUNT                    ,
       TAX_AMOUNT                     ,
       TRX_NUMBER                     ,
       BATCH_SOURCE_ID                ,
       CREATION_DATE                  ,
       CREATED_BY                     ,
       LAST_UPDATE_DATE               ,
       LAST_UPDATED_BY                ,
       LAST_UPDATE_LOGIN              ,
       SET_OF_BOOKS_ID                ,
       PRIMARY_SALESREP_ID            ,
       INVOICE_CURRENCY_CODE          ,
       EXCHANGE_RATE_TYPE             ,
       EXCHANGE_DATE                  ,
       EXCHANGE_RATE                  ,
       CREATED_FROM                   ,
       UPDATE_RG23D_FLAG              ,
       LEGAL_ENTITY_ID         -- rallamse bug#4448789
       )
       Values
       (
       v_header_id,
       v_organization_id,
       v_location_id,
       'Y',
       'N', --Bug 4694650 bduvarag
       v_ato_total_amount,
       v_ato_line_amount,
       v_ato_tax_amount,
       v_trx_number,
       v_batch_source_id,
       sysdate,
       uid,
       sysdate,
       uid,
       uid,
       v_books_id,
       v_salesrep_id,
       c_from_currency_code,
       c_conversion_type,
       c_conversion_date,
       c_conversion_rate,
       v_created_from,
       'Y',
       ln_legal_entity_id        -- rallamse bug#4448789
   );

   FND_FILE.PUT_LINE(FND_FILE.LOG,'After insert into JAI_AR_TRXS ');
   */ --End bug#6391684( FP of 6386592)
   FND_FILE.PUT_LINE(FND_FILE.LOG,
           'End of Procedure Process_Taxes_for_ATO_Order');

  end if; -- end if for IF NVL(pr_new.Interface_line_attribute11,'0') ='0'
 end if;


End Process_Taxes_for_ATO_Order;
-- Ends here additions by sriram

/*
Start additions by ssumaith for bug# 4136981*/
procedure process_bill_only_invoice is
  cursor c_check_hdr_exists is
  select 1
  from   JAI_AR_TRXS
  where  customer_trx_id = pr_new.customer_trx_id;


  cursor c_trx_cur is
  select trx_number               ,
         batch_source_id          ,
         set_of_books_id          ,
         primary_salesrep_id      ,
         invoice_currency_Code    ,
         exchange_rate_type       ,
         exchange_date            ,
         exchange_rate            ,
         created_from ,
   nvl(bill_to_customer_id,ship_to_customer_id) customer_id , -- Date 26-feb-2006 added by sacsethi for bug 5631784
         trx_date
  from   ra_customer_trx_all
  where  customer_trx_id = pr_new.customer_trx_id;

  CURSOR JA_SO_LINES_INFO IS
  SELECT tax_category_id     ,
         tax_amount          ,
         assessable_value    ,
         line_amount         ,
         excise_exempt_type  ,
         excise_exempt_refno ,
         excise_exempt_date  ,
         vat_exemption_flag  ,   -- added, Harshita for bug#4245062
         vat_exemption_type  ,
         vat_exemption_date  ,
         vat_exemption_refno ,
         vat_assessable_value,
   unit_code           , -- Date 26-feb-2006 added by sacsethi for bug 5631784
         inventory_item_id   , -- Date 26-feb-2006 added by sacsethi for bug 5631784
         quantity            ,  -- Date 26-feb-2006 added by sacsethi for bug 5631784
         service_type_code   -- Added by csahoo, Bug 5879769
  FROM   JAI_OM_OE_SO_LINES
  WHERE  line_id         = TO_NUMBER(v_interface_line_attribute6);

  cursor  c_get_amounts is
  select  sum(tax_amount) tax_amt , sum(line_amount) line_amt
  from    JAI_AR_TRX_LINES
  where   customer_trx_id = pr_new.customer_trx_id;

  cursor  c_default_location(CP_ORGANIZATION_ID  number) is
  select  DEFAULT_LOCATION_BILL_ONLY
  from    JAI_CMN_INVENTORY_ORGS
  where   organization_id = cp_organization_id
  and     location_id = 0;

  cursor  c_oe_system_params is
  select  master_organization_id
  from    oe_system_parameters ;

  -- added by Allen Yang for bug 9710600 20-May-2010, begin
  ------------------------------------------------------------
  CURSOR c_get_vat_inv_no IS
  SELECT VAT_INVOICE_NO
  FROM JAI_OM_WSH_LINES_ALL
  WHERE DELIVERY_ID IS NULL
  AND   ORDER_LINE_ID = TO_NUMBER(v_interface_line_attribute6);

  lv_vat_invoice_no   JAI_OM_WSH_LINES_ALL.VAT_INVOICE_NO%TYPE;
  ------------------------------------------------------------
  -- added by Allen Yang for bug 9710600 20-May-2010, end


  lr_trx_rec          c_trx_cur%rowtype;
  ln_hdr_exists       number; --File.Sql.35 Cbabu  := 0;
  ln_line_amount      number; --File.Sql.35 Cbabu  :=0;
  ln_tax_amount       number; --File.Sql.35 Cbabu  :=0;
  rec_so_lines        JA_SO_LINES_INFO%rowtype;
  ln_inv_orgn_id      number ;
  ln_default_locn_id  number;

  lv_appl_src  JAI_CMN_ERRORS_T.APPLICATION_SOURCE%type;
  lv_err_msg   JAI_CMN_ERRORS_T.ERROR_MESSAGE%type;
  lv_addl_msg  JAI_CMN_ERRORS_T.ADDITIONAL_ERROR_MESG%type;

  ln_legal_entity_id NUMBER ; /* rallamse bug#4510143 */
-- Date 26-feb-2006 added by sacsethi for bug 5631784
--start 5631784
    ln_tcs_exists             number;
    ln_tcs_regime_id          JAI_RGM_DEFINITIONS.regime_id%type;
    ln_threshold_slab_id      jai_ap_tds_thhold_slabs.threshold_slab_id%type;
    ln_last_line_no           number;
    ln_base_line_no           number;
    lv_process_flag             VARCHAR2(2);
    lv_process_message          VARCHAR2(1996);
    ln_reg_id                   number;
    cursor c_chk_rgm_tax_exists  ( cp_regime_code          JAI_RGM_DEFINITIONS.regime_code%type
                                 , cp_cust_trx_line_id     ra_customer_trx_lines_all.customer_trx_line_id%type
                                 )
    is
      select  count(1)
      from    jai_regime_tax_types_v jrttv
            , JAI_AR_TRX_TAX_LINES  jrctt
            , JAI_CMN_TAXES_ALL jtc
      where   jtc.tax_id     = jrctt.tax_id
      and     jtc.tax_type  = jrttv.tax_type
      and     regime_code    = cp_regime_code
      and     jrctt.link_to_cust_trx_line_id = cp_cust_trx_line_id;
cursor c_get_regime_id (cp_regime_code    JAI_RGM_DEFINITIONS.regime_code%type)
    is
      select regime_id
      from   JAI_RGM_DEFINITIONS
      where  regime_code = cp_regime_code;
--end 5631784
/*added for bug#6498072*/
Cursor get_ar_tax_amount
is
  select sum(tax_amount)
  from JAI_AR_TRX_TAX_LINES
  Where link_to_cust_trx_line_id = v_customer_trx_line_id;

ln_ar_tax_amount JAI_AR_TRX_TAX_LINES.TAX_AMOUNT%type;

begin
  FND_FILE.PUT_LINE(FND_FILE.LOG,
       ' Inside Procedure process_bill_only_invoice');

  ln_hdr_exists        := 0;
  ln_line_amount       :=0;
  ln_tax_amount        :=0;
  /*
   writing code here to process a bill only invoice.
   Validations to handle
   ---------------------
    a) in case of discounts only one line should have taxes
    b) in case of bond register excise and excise cess taxes should not flow into AR
    c) only one record should be inserted in the JAI_AR_TRXS table.
  */

  ln_hdr_exists := 0;
  open c_check_hdr_exists;
  fetch c_check_hdr_exists into ln_hdr_exists;
  close c_check_hdr_exists;

  FND_FILE.PUT_LINE(FND_FILE.LOG,' Header exists '|| ln_hdr_exists);

  if nvl(ln_hdr_exists,0) = 0 then
    /*
    no record exists in the JAI_AR_TRXS table for the customer trx id ,
    hence insert a record into the table.
    */

    open  c_trx_cur;
    fetch c_trx_cur into lr_trx_rec;
    close c_trx_cur;

    if pr_new.warehouse_id is null then
       open  c_oe_system_params;
       fetch c_oe_system_params into ln_inv_orgn_id;
       close c_oe_system_params;
    else
       ln_inv_orgn_id := pr_new.warehouse_id ;
    end if;

    FND_FILE.PUT_LINE(FND_FILE.LOG,' Inv orgn id: '|| ln_inv_orgn_id);

    open  c_default_location(ln_inv_orgn_id);
    fetch c_default_location into ln_default_locn_id;
    close c_default_location;

    FND_FILE.PUT_LINE(FND_FILE.LOG,' Default location id '|| ln_default_locn_id);

    if ln_default_locn_id is null then

     /*
      if the default location setup is not done , log this as a message in the JAI_CMN_ERRORS_T table
      do not stop the processing.
      We could still update the organization and location id in the JAI_AR_TRXS table later on (as a datafix)
     */
       lv_appl_src := 'JA_IN_OE_AR_LINES_INSERT_TRG' ;
       lv_err_msg  := 'Default Location is not setup for Inventory Organization ' ||  pr_new.warehouse_id ;
       lv_addl_msg := 'Please setup the Default Location in Organization Additional Information Screen for Trx id : ' || pr_new.customer_trx_id ;

       insert into JAI_CMN_ERRORS_T
       (
        APPLICATION_SOURCE          ,
        ERROR_MESSAGE           ,
        ADDITIONAL_ERROR_MESG   ,
        CREATION_DATE           ,
        CREATED_BY              ,
        -- added, Harshita for Bug 4866533
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE
       )
       values
       (
       lv_appl_src,  /*'JA_IN_OE_AR_LINES_INSERT_TRG', Ramananda for removal of SQL LITERALs */
       lv_err_msg,   /* 'Default Location is not setup for Inventory Organization ' ||  pr_new.warehouse_id , */
       lv_addl_msg, /* 'Please setup the Default Location in Organization Additional Information Screen for Trx id : ' || pr_new.customer_trx_id  , */
       sysdate,
       fnd_global.user_id ,
        -- added, Harshita for Bug 4866533
        fnd_global.user_id,
        sysdate
       );
    end if;

    ln_legal_entity_id := get_legal_entity_id ;

    insert into JAI_AR_TRXS    -- bill only invoice
    (
    CUSTOMER_TRX_ID                           ,
    ORGANIZATION_ID                           ,
    LOCATION_ID                               ,
    UPDATE_RG_FLAG                            ,
    ONCE_COMPLETED_FLAG                       ,
    TOTAL_AMOUNT                              ,
    LINE_AMOUNT                               ,
    TAX_AMOUNT                                ,
    TRX_NUMBER                                ,
    BATCH_SOURCE_ID                           ,
    CREATION_DATE                             ,
    CREATED_BY                                ,
    LAST_UPDATE_DATE                          ,
    LAST_UPDATED_BY                           ,
    LAST_UPDATE_LOGIN                         ,
    SET_OF_BOOKS_ID                           ,
    PRIMARY_SALESREP_ID                       ,
    INVOICE_CURRENCY_CODE                     ,
    EXCHANGE_RATE_TYPE                        ,
    EXCHANGE_DATE                             ,
    EXCHANGE_RATE                             ,
    CREATED_FROM                              ,
    UPDATE_RG23D_FLAG                         ,
    TAX_INVOICE_NO                            ,
    LEGAL_ENTITY_ID         /* rallamse bug#4448789 */
    )
    values
    (
    pr_new.customer_trx_id                    ,
    ln_inv_orgn_id                          ,
    ln_default_locn_id                      ,
    'N'                                     ,
    'N'                                     ,/*Bug 4694650 bduvarag*/
    0                                       ,
    0                                       ,
    0                                       ,
    lr_trx_rec.trx_number                   ,
    lr_trx_rec.batch_source_id              ,
    sysdate                                 ,
    fnd_global.user_id                      ,
    sysdate                                 ,
    fnd_global.user_id                      ,
    fnd_global.login_id                     ,
    lr_trx_rec.set_of_books_id              ,
    lr_trx_rec.primary_salesrep_id          ,
    lr_trx_rec.invoice_currency_code        ,
    lr_trx_rec.exchange_rate_type           ,
    lr_trx_rec.exchange_date                ,
    lr_trx_rec.exchange_rate                ,
    lr_trx_rec.created_from                 ,
    'N'                                     ,
    NULL                                    ,
    ln_legal_entity_id         /* rallamse bug#4448789 */
    );

    FND_FILE.PUT_LINE(FND_FILE.LOG,
      ' After insert into JAI_AR_TRXS - Bill only invoice');
  end if;

  /*
   insert into the JAI_AR_TRX_TAX_LINES table and then insert into the JAI_AR_TRX_LINES table.
   pr_new.interface_line_attribute6 = order_line_id
   pr_new.interface_line_context    = 'ORDER ENTRY'
  */

   open  c_ont_source_code;
   fetch c_ont_source_code into v_ont_source_code;
   close c_ont_source_code;
   FND_FILE.PUT_LINE(FND_FILE.LOG,' Ont source code: '|| v_ont_source_code);

   v_ont_source_code := ltrim(rtrim(v_ont_source_code));

   FND_FILE.PUT_LINE(FND_FILE.LOG,
       ' Ont source code- after trunc: '|| v_ont_source_code);

   /*
    return if it is discount line
   */
   if nvl(pr_new.interface_line_attribute11,'0') <> '0' then
     FND_FILE.PUT_LINE(FND_FILE.LOG,
      ' Int. line att1: '||pr_new.interface_line_attribute11);
     return;
   end if;

   for tax_rec in JA_SO_TAX_LINES_INFO
   Loop
     FND_FILE.PUT_LINE(FND_FILE.LOG,' cursor ja_so_tax_lines_info');
     FND_FILE.PUT_LINE(FND_FILE.LOG,' Tax type '|| tax_rec.tax_type);

     if v_register_code = 'BOND_REG' then
       FND_FILE.PUT_LINE(FND_FILE.LOG,' Register code '|| v_register_code);
     if upper(tax_rec.tax_type) not in ('EXCISE','OTHER EXCISE','CVD_EDUCATION_CESS','EXCISE_EDUCATION_CESS', jai_constants.tax_type_sh_cvd_edu_cess, jai_constants.tax_type_sh_exc_edu_cess) then
/* 'CVD_EDUCATION_CESS','EXCISE_EDUCATION_CESS' added by ssumaith - bug# 4136981*/
          /*jai_constants.tax_type_sh_exc_edu_cess, jai_constants.tax_type_sh_cvd_edu_cess added by CSahoo BUG#5989740*/
          /*
           This is not a discount line , so taxes can flow. In case it was discount , control would have never come here
          because of the return statement above.
          */
          /* Date 23/02/2006 by sacsethi for bug 5228046
             precedence 6 to 10  */
    INSERT INTO JAI_AR_TRX_TAX_LINES
              (
               tax_line_no                 ,
               customer_trx_line_id        ,
               link_to_cust_trx_line_id    ,
               precedence_1                ,
               precedence_2                ,
               precedence_3                ,
               precedence_4                ,
               precedence_5                ,
               precedence_6                ,
               precedence_7                ,
               precedence_8                ,
               precedence_9                ,
               precedence_10                ,
         tax_id                      ,
               tax_rate                    ,
               qty_rate                    ,
               uom                         ,
               tax_amount                  ,
               func_tax_amount             ,
               base_tax_amount             ,
               creation_date               ,
               created_by                  ,
               last_update_date            ,
               last_updated_by             ,
               last_update_login
              )
          VALUES
              (
              tax_rec.tax_line_no               ,
              ra_customer_trx_lines_s.nextval   ,
              v_customer_trx_line_id            ,
              tax_rec.precedence_1              ,
              tax_rec.precedence_2              ,
              tax_rec.precedence_3              ,
              tax_rec.precedence_4              ,
              tax_rec.precedence_5              ,
              tax_rec.precedence_6              ,
              tax_rec.precedence_7              ,
              tax_rec.precedence_8              ,
              tax_rec.precedence_9              ,
              tax_rec.precedence_10              ,
        tax_rec.tax_id                    ,
              tax_rec.tax_rate                  ,
              tax_rec.qty_rate                  ,
              tax_rec.uom                       ,
              round(tax_rec.tax_amount,2)       ,
              round(tax_rec.func_tax_amount,2)  ,
              round(tax_rec.base_tax_amount,2)  ,
              sysdate                           ,
              fnd_global.user_id                ,
              sysdate                           ,
              fnd_global.user_id                ,
              fnd_global.login_id
             );
        end if; /* end if for tax type not in excise .... */
     else       /* register association is not bond register , so all taxes can flow */
    /* Date 23/02/2006 by sacsethi for bug 5228046
     precedence 6 to 10  */
  INSERT INTO JAI_AR_TRX_TAX_LINES
                 (
                  tax_line_no                 ,
                  customer_trx_line_id        ,
                  link_to_cust_trx_line_id    ,
                  precedence_1                ,
                  precedence_2                ,
                  precedence_3                ,
                  precedence_4                ,
                  precedence_5                ,
                  precedence_6                ,
                  precedence_7                ,
                  precedence_8                ,
                  precedence_9                ,
                  precedence_10                ,
      tax_id                      ,
                  tax_rate                    ,
                  qty_rate                    ,
                  uom                         ,
                  tax_amount                  ,
                  func_tax_amount             ,
                  base_tax_amount             ,
                  creation_date               ,
                  created_by                  ,
                  last_update_date            ,
                  last_updated_by             ,
                  last_update_login
                 )
                  VALUES
                 (
                  tax_rec.tax_line_no               ,
                  ra_customer_trx_lines_s.nextval   ,
                  v_customer_trx_line_id            ,
                  tax_rec.precedence_1              ,
                  tax_rec.precedence_2              ,
                  tax_rec.precedence_3              ,
                  tax_rec.precedence_4              ,
                  tax_rec.precedence_5              ,
                  tax_rec.precedence_6              ,
                  tax_rec.precedence_7              ,
                  tax_rec.precedence_8              ,
                  tax_rec.precedence_9              ,
                  tax_rec.precedence_10              ,
      tax_rec.tax_id                    ,
                  tax_rec.tax_rate                  ,
                  tax_rec.qty_rate                  ,
                  tax_rec.uom                       ,
                  round(tax_rec.tax_amount,2)       ,
                  round(tax_rec.func_tax_amount,2)  ,
                  round(tax_rec.base_tax_amount,2)  ,
                  sysdate                           ,
                  fnd_global.user_id                ,
                  sysdate                           ,
                  fnd_global.user_id                ,
                  fnd_global.login_id
               );

     end if;
   end loop;


   open   JA_SO_LINES_INFO;
   fetch  JA_SO_LINES_INFO into rec_so_lines;
   close  JA_SO_LINES_INFO;

--end 5631784
    ln_tcs_exists  := null;
    open c_chk_rgm_tax_exists ( cp_regime_code        => jai_constants.tcs_regime
                              , cp_cust_trx_line_id   => v_customer_trx_line_id
                                );
    fetch c_chk_rgm_tax_exists into ln_tcs_exists;
    close c_chk_rgm_tax_exists ;
--    if ln_tcs_exists is not null then/*Bug 5684363 bduvarag*/
  if ln_tcs_exists > 0 then
      /* TCS type of tax is present */
         open  c_get_regime_id (cp_regime_code => jai_constants.tcs_regime);
         fetch c_get_regime_id into ln_tcs_regime_id;
         close c_get_regime_id;
   /* Find out what is the current slab */
        jai_rgm_thhold_proc_pkg.get_threshold_slab_id
                                  (
                                      p_regime_id         =>    ln_tcs_regime_id
                                    , p_organization_id   =>    ln_inv_orgn_id
                                    , p_party_type        =>    jai_constants.party_type_customer
                                    , p_party_id          =>    lr_trx_rec.customer_id
                                    , p_org_id            =>    v_org_id
                                    , p_source_trx_date   =>    lr_trx_rec.trx_date
                                    , p_threshold_slab_id =>    ln_threshold_slab_id
                                    , p_process_flag      =>    lv_process_flag
                                    , p_process_message   =>    lv_process_message
                                  );

       if lv_process_flag <> jai_constants.successful then
          app_exception.raise_exception
                        (exception_type   =>    'APP'
                        ,exception_code   =>    -20275
                        ,exception_text   =>    lv_process_message
                        );
        end if;
        if ln_threshold_slab_id is not null then
        /* Threshold level is up.  Surcharge needs to be defaulted , so find out the tax category based on the threshold slab */
          jai_rgm_thhold_proc_pkg.get_threshold_tax_cat_id
                                    (
                                       p_threshold_slab_id    =>    ln_threshold_slab_id
                                    ,  p_org_id               =>    v_org_id
                                    ,  p_threshold_tax_cat_id =>    ln_threshold_tax_cat_id
                                    ,  p_process_flag         =>    lv_process_flag
                                    ,  p_process_message      =>    lv_process_message
                                    );
          if lv_process_flag <> jai_constants.successful then
            app_exception.raise_exception
                          (exception_type   =>    'APP'
                          ,exception_code   =>    -20275
                          ,exception_text   =>    lv_process_message
                          );
          end if;
          /* Get line number after which threshold taxes needs to be defaulted */
          select max(tax_line_no)
          into   ln_last_line_no
          from   JAI_AR_TRX_TAX_LINES
          where  link_to_cust_trx_line_id = v_customer_trx_line_id;
          /* Get line number of the base tax (tax_type=TCS) for calculating the surcharge basically to set a precedence */
          select max(tax_line_no)
          into  ln_base_line_no
          from  JAI_AR_TRX_TAX_LINES jrctt
              , JAI_CMN_TAXES_ALL jtc
          where jrctt.link_to_cust_trx_line_id  = v_customer_trx_line_id
          and   jrctt.tax_id    = jtc.tax_id
          and   jtc.tax_type    = jai_constants.tax_type_tcs;
          /*
          ||Call the helper method to default surcharge taxes on top of the SO taxes  using the tax category
          || The api jai_rgm_thhold_proc_pkg.default_thhold_taxes inserts lines as per the same specified in the TCS tax category
          || into the ja_in_so_picking_tax_lines table
          */
          jai_rgm_thhold_proc_pkg.default_thhold_taxes
                                    (
                                      p_source_trx_id         => ''
                                    , p_source_trx_line_id    => v_customer_trx_line_id
                                    , p_source_event          => jai_constants.bill_only_invoice
                                    , p_action                => jai_constants.default_taxes
                                    , p_threshold_tax_cat_id  => ln_threshold_tax_cat_id
                                    , p_tax_base_line_number  => ln_base_line_no
                                    , p_last_line_number      => ln_last_line_no
                                    , p_currency_code         => lr_trx_rec.invoice_currency_code
                                    , p_currency_conv_rate    => lr_trx_rec.exchange_rate
                                    , p_quantity              => nvl(rec_so_lines.quantity,0)
                                    , p_base_tax_amt          => nvl(rec_so_lines.line_amount,0)
                                    , p_assessable_value      => rec_so_lines.assessable_value * rec_so_lines.quantity  --ADDED rec_so_lines.quantity FOR BUG#6498072
                                    , p_inventory_item_id     => rec_so_lines.inventory_item_id
                                    , p_uom_code              => rec_so_lines.unit_code
                                    , p_vat_assessable_value  => rec_so_lines.vat_assessable_value
                                    , p_process_flag          => lv_process_flag
                                    , p_process_message       => lv_process_message
                                    );

          if lv_process_flag <> jai_constants.successful then
            app_exception.raise_exception
                          (exception_type   =>    'APP'
                          ,exception_code   =>    -20275
                          ,exception_text   =>    lv_process_message
                          );
          end if;
        end if; /* ln_threshold_slab_id is not null then */
      end if;  /** ln_tcs_exists is not null then  */

       /*added by csahoo for bug#6498072, start*/

      open get_ar_tax_amount;
      FETCH get_ar_tax_amount INTO ln_ar_tax_amount;
      CLOSE get_ar_tax_amount;
      /*added by csahoo for bug#6498072, end*/

      /*moved the following code here for bug# 6498072*/

      INSERT INTO JAI_AR_TRX_LINES (
                                               customer_trx_line_id                         ,
                                               line_number                                  ,
                                               customer_trx_id                              ,
                                               description                                  ,
                                               payment_register                             ,
                                               excise_invoice_no                            ,
                                               preprinted_excise_inv_no                     ,
                                               excise_invoice_date                          ,
                                               inventory_item_id                            ,
                                               unit_code                                    ,
                                               quantity                                     ,
                                               tax_category_id                              ,
                                               auto_invoice_flag                            ,
                                               unit_selling_price                           ,
                                               line_amount                                  ,
                                               tax_amount                                   ,
                                               total_amount                                 ,
                                               assessable_value                             ,
                                               creation_date                                ,
                                               created_by                                   ,
                                               last_update_date                             ,
                                               last_updated_by                              ,
                                               last_update_login                            ,
                                               excise_exempt_type                           ,
                                               excise_exempt_refno                          ,
                                               excise_exempt_date                           ,
                                               ar3_form_no                                  ,
                                               ar3_form_date                                ,
                                               vat_exemption_flag                           , -- added, Harshita for bug#4245062
                                               vat_exemption_type                           ,
                                               vat_exemption_date                           ,
                                               vat_exemption_refno                                    ,
                                               vat_assessable_value                         ,
                                               service_type_code                               --Added by csahoo for Bug#5879769
                                              )
                                      VALUES  (
                                               pr_new.customer_trx_line_id                    ,
                                               pr_new.line_number                             ,
                                               pr_new.customer_trx_id                         ,
                                               pr_new.description                             ,
                                               NULL                                         ,
                                               NULL                                         ,
                                               NULL                                         ,
                                               NULL                                         ,
                                               pr_new.inventory_item_id                       ,
                                               pr_new.uom_code                                ,
                                               pr_new.quantity_invoiced                       ,
                                               rec_so_lines.tax_category_id                 ,
                                               'Y'                                          ,
                                               pr_new.unit_selling_price                      ,
                                               round(nvl(rec_so_lines.line_amount,0),2)     ,
                                               round(nvl(ln_ar_tax_amount,0),2)      ,
                                               round(nvl(rec_so_lines.line_amount,0) +
                                               nvl(ln_ar_tax_amount,0),2)            ,
                                               rec_so_lines.assessable_value                ,
                                               sysdate                                      ,
                                               fnd_global.user_id                           ,
                                               sysdate                                      ,
                                               fnd_global.user_id                           ,
                                               fnd_global.login_id                          ,
                                               rec_so_lines.excise_exempt_type              ,
                                               rec_so_lines.excise_exempt_refno             ,
                                               rec_so_lines.excise_exempt_date              ,
                                               NULL                                         ,
                                               NULL                                         ,
                                               rec_so_lines.vat_exemption_flag              , -- added, Harshita for bug#4245062
                                               rec_so_lines.vat_exemption_type              ,
                                               rec_so_lines.vat_exemption_date              ,
                                               rec_so_lines.vat_exemption_refno             ,
                                               rec_so_lines.vat_assessable_value            ,
                                               rec_so_lines.service_type_code                 --Added by csahoo for Bug#5879769
                                              );

    open  c_get_amounts;
    fetch c_get_amounts into ln_tax_amount, ln_line_amount ;
    close c_get_amounts;

    FND_FILE.PUT_LINE(FND_FILE.LOG,' Cursor c_get_amounts');
    FND_FILE.PUT_LINE(FND_FILE.LOG,' Tax amount '|| ln_tax_amount);
    FND_FILE.PUT_LINE(FND_FILE.LOG,' Line amount '|| ln_line_amount);

    -- added by Allen Yang for bug 9710600 20-May-2010, begin
    ----------------------------------------------------------
    OPEN c_get_vat_inv_no;
    FETCH c_get_vat_inv_no INTO lv_vat_invoice_no;
    CLOSE c_get_vat_inv_no;
    FND_FILE.PUT_LINE(FND_FILE.LOG,' VAT Invoice Number '|| lv_vat_invoice_no);
    ---------------------------------------------------------
    -- added by Allen Yang for bug 9710600 20-May-2010, end

    update  JAI_AR_TRXS
    set     tax_amount   = ln_tax_amount ,
            line_amount  = ln_line_amount,
            total_amount = ln_line_amount + ln_tax_amount
            -- added by Allen Yang for bug 9710600 20-May-2010, begin
            ---------------------------------------------------------
           ,vat_invoice_no = lv_vat_invoice_no
           ----------------------------------------------------------
            -- added by Allen Yang for bug 9710600 20-May-2010, end
    where   customer_trx_id = pr_new.customer_trx_id;
     /*bug# 6498072, end*/
    /*
    --  End of bug 4742259
    */
    jai_ar_tcs_rep_pkg.ar_accounting
                          (    p_ractl             =>  pr_new
                            ,  p_process_flag      =>  lv_process_flag
                            ,  p_process_message   =>  lv_process_message
                          );
    if lv_process_flag <> jai_constants.successful then
      app_exception.raise_exception
                    (exception_type   =>    'APP'
                    ,exception_code   =>    -20275
                    ,exception_text   =>    lv_process_message
                    );
    end if;
end ;

  BEGIN
    pv_return_code := jai_constants.successful ;
   /*---------------------------------------------------------------------------------------------
FILENAME: JA_IN_OE_AR_LINES_INSERT_TRG.sql CHANGE HISTORY:
S.No  Date        Author and Details
---------------------------------------------------------------------------------------------
1.      12/02/01   MANOHAR MISHRA
                                Removed the Duplicate_hdr_cur from the commented zone.
2.      2001/04/11        JAGDISH BHOSLE
                                Added Bond register checking to avoid Excise duty to hit
                                Accounting entries.
3.      2001/04/20              Anuradha Parthasarathy
                                Enhancement for RG entries for Supplementary Transactions.
4.      2001/05/03              Gadde,Jagdish
                                Check added to avoid firing of trigger for Non_Indian OU.
5.      2001/06/05              Anuradha Parthasarathy
                                Cursor added to take care of correct tax insertions
                                into JAI_AR_TRX_TAX_LINES
6.    2001/09/13        Vijay
                        Added condition of interface_line_context to return
                        for Project Accounting
7.      2001/11/01              Anuradha Parthasarathy
                                Condition added to ensure that Modvat Recovery types of Taxes
                                should not be charged to the customer.
8.    2002/04/17        RPK
                        for BUG# 2327261.
                        Code modified to prevent the erroring out of the autoinvoice import program
                        when the manual delivery is made and when the delivery name is alphanumeric.
                        When the order created is assigned to this delivery and the ship confimation is
                        done ,then the autoinvoice import program is running into error because the
                        the validation is failing for delivery_id and interface_line_attribute3
9.    2002/04/22        SRIRAM For Bug # 2316589 . The JAI_AR_TRXS table was updated with
                        wrong values . Instead a new update has been written using a different value to
                        update tax amounts correctly.
10    2002/06/26        SRIRAM For Bug # 2398198 . Tax Lines were inserted multiple times in the
                        JAI_AR_TRX_TAX_LINES , JAI_AR_TRX_LINES tables when discounts
                                                exist and tax amounts were updated doubly in JAI_AR_TRXS table, which have been
                                                solved in this bug.
11.  2002/08/17         SRIRAM .Fopr Bug # 2518534 . When there is a change in UOM in the
                        Sales order screen , the taxes in the localization screen are not
                                                flowing correctly.
12.  2002/11/19         SRIRAM - Bug # 2668342. Performance issue reported when using the
                        org_organization_definitions table using nvl(operating_unit) in the where
                        clause. This is causing couple of full table scans which was a performance
                        bottle neck.A new cursor definition has been written which uses the
                        HR_OPERATING_UNITS table and this is performance optimized.
                        Organization_id column is the operating_unit in the table.

13. 2003/01/09  Sriram - Bug # 2742849 - Version is 615.3
                          This problem is about tax lines being inserted for discount line also.
                          The earlier fix assumed that the discount line follows the item line by line number,
                          that is they are consecutive lines. But this assumption is not correct and  it depends on setup.

                          Found out from base apps team that interface_line_attribute11 can be used to identify a discount line from the item line.
                          For a Invoice line imported from OM , the  interface_line_attribute11 will have a value 0 or Null ,
                          whereas for a discount  line , the interface_line_attribute11 will have a value which maps to the price_adjustment_id.

13. 2003/02/07  Vijay Shankar - Bug # 2779990 - Version is 615.4
                  When bond transaction invoice is created, then tax_amounts populated in JAI_AR_TRXS and JAI_AR_TRX_LINES is wrong.
                  this is rectified by writing a new cursor name c_tax_amount

14. 2003/03/17  Sriram  LMW ATO Issue - Bug #2806274  Version 615.5
                Created an internal procedure Process_Taxes_for_ATO_Order to pull taxes from OM to Ar for ATO Orders.
                The idea was to import the taxes for the 'Model' Item based on the config item.

15. 2003/06/26  Sriram - Bug # 3000550 version 616.1
                Tax amounts were not calculated correctly , in the JAI_AR_TRXS and JAI_AR_TRX_LINES
                table.This was observed when there was a split done during shipment.
                Data was correct in the JAI_AR_TRX_TAX_LINES table , but incorrect in the JAI_AR_TRX_LINES
                and JAI_AR_TRXS table.
                This has been fixed in this bug

16. 2003/08/22  Sriram - Bug # 3021588 version 616.2

                   For Multiple Bond Register Enhancement,
                   Instead of using the cursors for fetching the register associated with the invoice type , a call has been made to the procedures
                   of the jai_cmn_bond_register_pkg package. There enhancement has created dependency because of the
                   introduction of 3 new columns in the JAI_OM_OE_BOND_REG_HDRS table and also call to the new package jai_cmn_bond_register_pkg.

                  This fix has introduced huge dependency . All future changes in this object should have this bug as a prereq


17  2003/09/16   SSUMAITH - Bug # 3134224 Version 616.3
                         For a Supplementary invoice , if if the ST form Type is NULL , entries are going into the ST forms Tracking tables.
                         This is causing the unique constraint violation error. This has been resolved by making a change to ensure that
                         entries in the ST forms table needs to go only if the St form Type is not null and tax type is 'Sales Tax' or 'CST'.

18  2003/10/10   Vijay shankar - Bug # 3181892, Version 616.4
                          AR3 form number and date values are not populated into JAI_AR_TRX_LINES table which is resolved with this fix

19  2003/12/30   Aiyer - Bug #3328871, Version 618.1

     Issue: -
         Create an order such that it does not have any associated taxes.
       Ship this order and run the auto invoice program.
       It is found that no records are inserted in the table JAI_AR_TRX_LINES.

     Solution: -
       This was happening because the code was assuming that a line cannot exist without any taxes.
       So in such a case the control was made to return back without inserting a line in JAI_AR_TRX_LINES
       table.

     Fix Details:-
       Added a if clause in the code. Placed the return statement between the if clause.
       So the modified functionality is that is a line does not have any taxes in shpiing tables and also does not have
       any taxes in JAI_OM_OE_SO_TAXES table then check whether a line exists in JAI_OM_OE_SO_LINES table only.
       IF yes then do not retunr, if not found then return.
       Also  added a nvl clause in the cursor c_cust_trx_tax_line_amt. so that a value of zero would be returned
       even if the where clause failed to fetch a record.
       This would take care that tax amount would be inserted as 0 and total amount would also be computed properly
       in table JAI_AR_TRX_LINES.
       This issue was reported thorugh the bug 3344492.
       Also indented the whole code and added additional comments wereever necessary.
       Removed the commented code wherever applicable.

                 Dependency Introduced Due To This Bug:-
      None
20  2004/02/16   RBASKER - Bug 3357587, Version 618.2
    When SO UOM is different from that of the primary UOM,
      JAI_AR_TRX_LINES is updated with wrong assessable value
      Added a cursor C_JA_SO_LINES_ASSESSABLE_VAL to fetch the correct assessable_value
      from JAI_OM_OE_SO_LINES instead of JAI_OM_WSH_LINES_ALL table.

21. 2004/05/05   ssumaith - bug# 3607101 - Version 619.1
         When autoinvoice import program imports an invoice from customer software and if interface_line_attribute11
         field in the ra_customer_trx_lines_all table is not null then , localization taxes are not retreived
         into the AR invoice.
         This issue has been resolved by adding a context based check that interface_line_attribute11 field cannot be
         null for Order Entry as the source of the invoice for taxes to be imported , and other wise if the context is not
         Order Entry then the localisation taxes will be populated into the Invoice from shipment.

22. 2004/04/16  ssumaith - bug# 3532716 Version - 115.1

        The variable v_tax_count was not re-initialised to zero , as a result code flow is not entering into an if condition
        because of the static value of 1 it has initially and hence all taxes are not flowing into the AR invoice.

23. 2004/11/03  Vijay Shankar for Bug# 3985561 (Porting of Bug#3651923), Version: 115.2
                 commented a delete statement on JAI_AR_TRX_INS_LINES_T table which is redundant and causing deadlock problems
                 This DELETE statement is executed in Concurrent process where in taxes are defaulted from OM to AR
                 * HIGH DEPENDENCY for future bugs *

24. 29-nov-2004  ssumaith - bug# 4037690  - File version 115.4
                   Check whether india localization is being used was done using a INR check in every trigger.
                   This check has now been moved into a new package and calls made to this package from this trigger
                   If the function jai_cmn_utils_pkg.check_jai_exists returns true it means INR is the set of books currency ,
                   Hence if this function returns FALSE , control should return.

25. 06-JAn-2005  ssumaith - bug#4136981   File version 115.5

                  In case of Bond Register Setup , in addition to Excise, the Education Cess taxes should also not flow to
                  Receivables Localization tables.
                  This check has been done in the code at two places.

                  Also added code for ensuring that taxes flow into ar in case of bill only workflow scenario

                  This fix does not introduce dependency on this object , but this patch cannot be sent alone to the CT
                  because it relies on the alter done and the new tables created as part of the education cess enhancement
                  bug# 4146708 creates the objects

26. 17-Mar-2005  hjujjuru - bug #4245062  File version 115.6
                 The columns  vat_exemption_flag, vat_exemption_type, vat_exemption_date, vat_exemption_refno,
                 and vat_assessable_value have been added in JAI_OM_OE_SO_LINES, JAI_OM_WSH_LINES_ALL
                 and JAI_AR_TRX_LINES.
                 Additional fields vat_invoice_no and vat_invoice_date have been added into JAI_OM_WSH_LINES_ALL
                 and JAI_AR_TRXS.
                 The trigger has been updated to ensure that any data flowing into JAI_AR_TRX_LINES and
                 JAI_AR_TRXS also includes the Vat information that comes down from either JAI_OM_OE_SO_LINES
                 or JAI_OM_WSH_LINES_ALL .

                 Base bug - #4245089

Trigger file name is renamed to JAI_AR_RCTLA_T7.SQL
---------------------------------------------------
27.  25-MAY-2005   BRATHOD, Bug# 4392001, File Version 116.1
                   Issue:-
                   RA_INTERFACE_LINES DFF segments needs to be limited use only one segment
                   Fix:-
                   - Following four segments will be obsoleted
                     1.  SUPPLEMENT CM
                     2.  SUPPLEMENT DM
                     3.  SUPPLEMENT INVOICE
                     4.  TDS CREDIT
                   - A new segment (INDIA INVOICES) will be created with following attributes
                     1. INTERFACE_LINE_ATTRIBUTE1 - Invoice Type
                     2. INTERFACE_LINE_ATTRIBUTE2 - Unique Identifier
                   - As new dff uses the ATTRIBUTE1 field the existing values of ATTRIBUTE1 will be
                     migrated to ATTRIBUTE4
                   - Attribute context will be changed to INDIA INVOICES.
                   - INTERFACE_LINE_ATTRIBUTE1 will identify the type of invoice the possible values
                     for this field will be same as different segments used previously
                     i.e SUPPLEMENT CM, SUPPLEMENT DM, SUPPLEMENT INVOICE, TDS CREDIT

28    08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old
                    DB Entity as required for CASE COMPLAINCE.  Version 116.2

29    10-Jun-2005   File Version: 116.3
                    Removal of SQL LITERALs is done

30    10-Jun-2005   rallamse bug#4448789  116.3
                    Added legal_entity_id for table JAI_AR_TRXS in insert statement

      06-Jul-2005   Ramananda for bug#4477004. File Version: 116.4
                    GL Sources and GL Categories got changed. Refer bug for the details

31    14-Jul-2005   rchandan for  bug#4487676. File Version: 117.2
                    JAI_CMN_RG_23AC_I_TXNS_S is replaced by JAI_CMN_RG_23AC_I_TRXS_S

32    26-Jul-2005    rallamse for bug#4510143 File Version 120.2
                    Changed the legal_entity_id to get from function get_legal_entity_id.
                    Replaced legal_entity_id with ln_legal_entity_id( holds value of get_legal_entity_id )
                    for table JAI_AR_TRXS in insert statement.

33.   24-Aug-2005   Ramananda for bug #4567935 (115 bug 4404898).  File version 120.2
                    Issue:-
                     1. Trigger currently processes invoices with interface line context as LEGACY.This needs to be stopped

                    Fix:-
                     1. Added the check to RETURN from the trigger if interface line context in ( 'LEGACY','PROJECTS INVOICES','OKS CONTRACTS')
                      also did forward porting for the bugs 4395450,4426613.

                    Dependency due to this bug :-
                     Functional dependency with jai_ar_rctla_ari_t8 trigger of jai_fin_t.sql (120.2)

34.   28-Jun-2007    CSahoo for bug#6155839, File Version 120.16
         replaced RG Register Data Entry by jai_constants.je_category_rg_entry
35.   16-oCT-2007    CSahoo for bug#6498072, File Version 120.21
         Multipled p_quantity to the assesible value in the call to the procedure jai_rgm_thhold_proc_pkg.default_thhold_taxes

36.   18-OCT-2007    CSahoo for bug#6498072, File Version 120.22
         Added the cursor get_ar_tax_amount to get the total tax amount from JAI_AR_TRX_TAX_LINES table.
         Moved the code for Inserting into JAI_AR_TRX_LINES and updating the table JAI_AR_TRXS to the end in the procedure
         process_bill_only_invoice

37  11-Nov-2008  JMEENA for bug#6498345( FP 6492966 )
                  Issue:  AR Autoinvoice completes in Error: ORA-20130: ORGANIZATION CANNOT BE NULL
                  Reason: OPTION items in the sales order have taxes attached (Excise + VAT) with zero tax amounts.
                          For OPTION item, derivation of organization and location is not present in the code
                          as the taxes are not expected to be in the option item.
                          As the it has vat taxes, it checks for organization id and AI errors out.
                     Fix: Added logic to extract organization and location for OPTION items

38. 22-Nov-2008   JMEENA for bug#6391684( FP of 6061010 and 6386592)
				1.Issue:  INDIA LOCAL-CTO ITEM-EXCISE INV,PLA REG NOT UPDATED, AR TAXES NOT GENERATED
				Fix:    When a model line is being inserted into table JAI_AR_TRX_LINES,
						trigger JAI_AR_RCTA_ARIUD_T1 is invoked for MODEL item. By this
						time, a record is available in table JAI_AR_TRXS but without
						organization and location values. Hence, added the code to update the organization_id
						and location_id in the JAI_AR_TRXS table

				2. Issue:  AUTOINVOICE FOR CERTAIN CTO SALES ORDERS GOING INTO ERRORS
				Reason: Code to insert an header record into table JAI_AR_TRXS was present after
						insertion of lines in table JAI_AR_TRX_LINES. Trigger
						JAI_AR_RCTA_ARIUD_T1 was fired before the header record is present in
						IL header table JAI_AR_TRXS. Hence the AutoInvoice goes into error.
				Fix: 	  	Modified the code in internal procedure process_taxes_for_ato_order of
						proceudre JAI_AR_RCTLA_TRIGGER_PKG.ARI_T2.
						  Moved the insertion code into table JAI_AR_TRXS before
						  the insertion of lines into IL taxes table.

39. 08-DEC-2008	JMEENA For Bug#5684033
						Issue: AUTOINVOICE GOES IN ERROR FOR PTO ORDERS
                        Fix:  Added cursor so_ato_picking_hdr_info_1. If organization_id is null from
                              cursor so_ato_picking_hdr_info, organization_id is being fetched
                              from so_ato_picking_hdr_info_1

40  30-APR-2009	JMEENA for bug#8466638
			  Issue: Service type is not flowing OM to AR
			  Fix: Added column Service_type_code and its value in the insert of JAI_AR_TRX_LINES.

41. 04-JUN-2009 JMEENA for bug#5641896 (FP of 5639516 )
		Issue:  AutoInvoice Import Program (RAXTRX) is running slow.
		Fix:    Removed to_char() from to_char(line_id) in so_rma_hdr_info cursor definition.

42. 02-Apr-2010   Allen Yang modified for bug 9485355 (12.1.3 non-shippable enhancement)
    Issue:  ARI_T2 pulls data from OFI Shipping tables and populates OFI Receivables tables for shippable lines only.
            Also need to do this for non-shippable lines when Bill Only workflow is not used.
    Fix:    modified table populating logic to process non-shippable items.

43. 20-May-2010  Allen Yang for bug 9710600
    Issue:  TST1213.XB1.QA. VAT INVOICE# NOT SHOWN IN IL AR TRANSACTION
    Fix:    Modified inner procedure process_bill_only of procedure ARI_T2 to copy VAT Invoice Number
            from JAI_OM_WSH_LINES_ALL for Bill Only items.


Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )

----------------------------------------------------------------------------------------------------------------------------------------------------
Current Version       Current Bug    Dependent           Files          Version   Author   Date         Remarks
Of File                              On Bug/Patchset    Dependent On
ja_in_oe_ar_lines_insert_trg.sql
----------------------------------------------------------------------------------------------------------------------------------------------------
616.2                  3021588       IN60104D1 +                                 ssumaith  22/08/2003   Bond Register Enhancement
                                     2801751   +
                                     2769440

115.4                  4037690       IN60105D2          ja_in_util_pkg_s.sql  115.0     ssumaith 29-Nov-2004  Call to this function.
                                                        ja_in_util_pkg_s.sql  115.0     ssumaith

115.6                  4245062       IN60106 + 4245089                           hjujjuru  17/03/2005   VAT Implelentation

----------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------*/

/* --Ramananda for File.Sql.35, start */
  v_org_id                      :=pr_new.org_id;
  v_last_update_date            := pr_new.last_update_date;
  v_last_updated_by             := pr_new.last_updated_by;
  v_creation_date               := pr_new.creation_date;
  v_created_by                  := pr_new.created_by;
  v_last_update_login           := pr_new.last_update_login;
  v_customer_trx_line_id        := pr_new.customer_trx_line_id;
  v_header_id                   := pr_new.customer_trx_id;
  v_line_amount                 := nvl(pr_new.quantity_invoiced * pr_new.unit_selling_price, nvl(pr_new.extended_amount,0));	    --added  nvl(pr_new.extended_amount,0) for bug#8849775
  v_interface_line_attribute3   :=  pr_new.interface_line_attribute3;
  v_interface_line_attribute6   :=  pr_new.interface_line_attribute6;
  v_excise_amount               := 0;
  v_tax_amount                  := 0;
  v_excise_diff                 := 0;
  v_assessable_value            := 0;
  v_basic_excise_duty_amount    := 0;
  v_add_excise_duty_amount      := 0;
  v_oth_excise_duty_amount      := 0;
  v_exist_flag                  := 0;
  v_source_name                 := 'Receivables India';
  v_category_name               := jai_constants.je_category_rg_entry ; -- 'RG Register Data Entry' modified by csahoo for bug#6155839
  /* --Ramananda for File.Sql.35, end */

  ln_bill_only                  := 0;
  ln_legal_entity_id := get_legal_entity_id ;

  --2001/05/03 Gadde,Jagdish

  /****************************** Validation 1 ********************************/
  FND_FILE.PUT_LINE(FND_FILE.LOG,' Org id: '||v_org_id);

  /* Bug 5243532. Added by Lakshmi Gopalsami
     Removed the reference to cursor Fetch_Book_Id_Cur
     and used the values assigned in trigger to get
     the value of SOB.
  */
  v_gl_set_of_bks_id := pr_new.set_of_books_id;

  FND_FILE.PUT_LINE(FND_FILE.LOG,' SOB id '|| v_gl_set_of_bks_id);

  --If jai_cmn_utils_pkg.check_jai_exists(P_CALLING_OBJECT => 'JA_IN_OE_AR_LINES_INSERT_TRG', P_ORG_ID => pr_new.org_id) = false then
  --  return;
  --end if;

  /*The following code has been commented and added the above code instead - ssumaith - bug# 4037690*/

  /*
  IF pr_new.org_id IS NOT NULL
  THEN
    OPEN Sob_cur;
      FETCH Sob_cur INTO v_currency_code;
    CLOSE Sob_cur;
    IF nvl(v_currency_code,'###') <> 'INR'
    THEN
      RETURN;
    END IF;
  END IF;
  */

  -- End addition
  --added by vijay on 13-sep-01

  /****************************** Validation 2 ********************************/
  /*
  || Added by Ramananda for bug# 4567935 (115 bug#4404898,4395450,4426613)
  || Added the check to RETURN from the trigger if interface line context = 'LEGACY'
  */
  IF pr_new.interface_line_context in ( 'PROJECTS INVOICES','OKS CONTRACTS', 'LEGACY') THEN
    RETURN;
  END IF;
  --end addition by vijay on 13-sep-01

  /****************************** Validation 3 ********************************/
  OPEN get_header_info_cur;
  FETCH get_header_info_cur INTO    j_organization_id   ,
                                    j_location_id       ,
                                    j_batch_source_id;
  CLOSE get_header_info_cur;

  FND_FILE.PUT_LINE(FND_FILE.LOG, ' header info.' );
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' org id: '|| j_organization_id);
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' loc id: '|| j_location_id);
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' Batch source id: '|| j_batch_source_id);

  /* The following code has been added by SRIRAM -- BUG # 3021588 CALL TO jai_cmn_bond_register_pkg INSTEAD */

  jai_cmn_bond_register_pkg.get_register_id(
                                      j_organization_id      ,
                                      j_location_id          ,
                                      j_batch_source_id      ,
                                      'Y'                    ,
                                      v_register_id          ,
                                      v_register_code
                                    );

  /****************************** Validation 4 ********************************/
  OPEN  transaction_type_cur;
  FETCH transaction_type_cur INTO v_trans_type;
  CLOSE transaction_type_cur;

  FND_FILE.PUT_LINE(FND_FILE.LOG, ' Transaction type '|| v_trans_type);
  FND_FILE.PUT_LINE(FND_FILE.LOG,
   ' Interface line attribute1 '||pr_new.interface_line_attribute1);
  FND_FILE.PUT_LINE(FND_FILE.LOG,
   ' Interface line context '|| pr_new.interface_line_context);

  IF (    v_trans_type = 'CM'
      AND pr_new.interface_line_attribute1 = 'SUPPLEMENT CM'   -- pr_new.interface_line_context, Bug 4392001
      AND pr_new.interface_line_context='INDIA INVOICES'       -- Added by Brathod, for Bug# 4392001
     )
     OR
     (   v_trans_type = 'DM'
     AND pr_new.interface_line_attribute1 = 'SUPPLEMENT DM'   -- pr_new.interface_line_context, Bug 4392001
     AND pr_new.interface_line_context='INDIA INVOICES'       -- Added by Brathod, for Bug# 4392001
     )
     OR
     (v_trans_type = 'INV')
  THEN
     null;
  ELSE
    return;
  END IF;

  /****************************** Validation 5 ********************************/
  /*
    This is cursor that is commonly used at various places in the code
  */
  OPEN   created_from_cur;
  FETCH  created_from_cur INTO  v_created_from          ,
                                v_trx_number            ,
                                v_batch_source_id       ,
                                v_books_id              ,
                                v_salesrep_id           ,
                                c_from_currency_code    ,
                                c_conversion_type       ,
                                c_conversion_date       ,
                                c_conversion_rate ;
  CLOSE  created_from_cur;

  IF v_created_from <> 'RAXTRX' THEN
     return;
  END IF;

  /****************************** Validation 6 ********************************/
  OPEN   once_complete_flag_cur;
  FETCH  once_complete_flag_cur INTO v_once_completed_flag;
  CLOSE  once_complete_flag_cur;

  FND_FILE.PUT_LINE(FND_FILE.LOG,
    ' Once completed flag '|| v_once_completed_flag);


  IF NVL(v_once_completed_flag,'N') = 'Y' THEN
    RETURN;
  END IF;

  /****************************** Validation 7 ********************************/
  /*
    Code for handling supplementary invoices
  */
  /*  Modified from pr_new.interface_line_context, Bug# 4392001 */
  IF pr_new.interface_line_attribute1 IN ('SUPPLEMENT CM'
                                        ,'SUPPLEMENT DM'
                                        ,'SUPPLEMENT INVOICE'
                                        )
  AND pr_new.interface_line_context = 'INDIA INVOICES' -- Added by Brathod, Bug# 4392001
  THEN

    OPEN  get_exchange_rate;
    FETCH get_exchange_rate INTO v_exchange_rate;
    CLOSE get_exchange_rate;

    FND_FILE.PUT_LINE(FND_FILE.LOG, ' Exchange rate '|| v_exchange_rate);

    OPEN   duplicate_hdr_cur;
    FETCH  duplicate_hdr_cur INTO x;
    CLOSE  duplicate_hdr_cur;

   -- IF pr_new.interface_line_attribute1 IS NULL THEN -- Commented By BRATHOD Bug 4392001
    IF pr_new.interface_line_attribute4 IS NULL THEN   -- Added by BRATHOD, Big# 4392001
      FND_FILE.PUT_LINE(FND_FILE.LOG, ' Interface line att4 is null');

      OPEN supplement_lines_check_cnsldt;
      FETCH supplement_lines_check_cnsldt INTO v_exist_flag;
      CLOSE supplement_lines_check_cnsldt;

   -- ELSIF pr_new.interface_line_attribute1 IS NOT NULL THEN -- Commented By BRATHOD Bug 4392001
    ELSIF pr_new.interface_line_attribute4 IS NOT NULL THEN   -- Added By BRATHOD Bug 4392001
      FND_FILE.PUT_LINE(FND_FILE.LOG, ' Interface line att4 is not null');
      OPEN  supplement_lines_check;
      FETCH supplement_lines_check INTO v_exist_flag;
      CLOSE supplement_lines_check;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,
         ' Supplement lines check exists flag'|| v_exist_flag);
    IF NVL(v_exist_flag,0) <> 1 THEN
      return;
    END IF;

    IF NVL(x,0) <> 1 THEN
      IF pr_new.interface_line_attribute4 IS NULL THEN  -- pr_new.interface_line_attribute1, Bug 4392001
        OPEN ja_in_ra_customer_trx_infocnsl;
        FETCH ja_in_ra_customer_trx_infocnsl INTO v_organization_id, v_location_id;
        CLOSE ja_in_ra_customer_trx_infocnsl;
      ELSIF pr_new.interface_line_attribute4 IS NOT NULL THEN -- pr_new.interface_line_attribute1, Bug 4392001
        OPEN  ja_in_ra_customer_trx_info;
        FETCH ja_in_ra_customer_trx_info INTO v_organization_id, v_location_id;
        CLOSE ja_in_ra_customer_trx_info;
      END IF;

      INSERT INTO JAI_AR_TRXS (                               -- supplement
                                           customer_trx_id         ,
                                           organization_id         ,
                                           location_id             ,
                                           trx_number              ,
                                           update_rg_flag          ,
                                           update_rg23d_flag       ,
                                           once_completed_flag     ,
                                           batch_source_id         ,
                                           set_of_books_id         ,
                                           primary_salesrep_id     ,
                                           invoice_currency_code   ,
                                           exchange_rate_type      ,
                                           exchange_date           ,
                                           exchange_rate           ,
                                           creation_date           ,
                                           created_by              ,
                                           last_update_date        ,
                                           last_updated_by         ,
                                           last_update_login       ,
                                           legal_entity_id         /* rallamse bug#4448789 */
                                        )
                                VALUES  (
                                           v_header_id             ,
                                           v_organization_id       ,
                                           v_location_id           ,
                                           v_trx_number            ,
                                           'Y'                     ,
                                           'Y'                     ,
                                           'N'                     ,
                                           v_batch_source_id       ,
                                           v_books_id              ,
                                           v_salesrep_id           ,
                                           c_from_currency_code    ,
                                           c_conversion_type       ,
                                           c_conversion_date       ,
                                           c_conversion_rate       ,
                                           v_creation_date         ,
                                           v_created_by            ,
                                           v_last_update_date      ,
                                           v_last_updated_by       ,
                                           v_last_update_login     ,
                                           ln_legal_entity_id         /* rallamse bug#4448789 */
                                        );
      FND_FILE.PUT_LINE(FND_FILE.LOG, ' Inside x <> 1: After insert into JAI_AR_TRXS');
    END IF;

    IF pr_new.interface_line_attribute4 IS NULL THEN  --  pr_new.interface_line_attribute1, Bug# 4392001
      OPEN  supplement_tax_lines_check_cns;
      FETCH supplement_tax_lines_check_cns INTO v_exist_flag;
      CLOSE supplement_tax_lines_check_cns;

    ELSIF pr_new.INTERFACE_LINE_ATTRIBUTE4 IS NOT NULL THEN  --  pr_new.interface_line_attribute1, Bug# 4392001
     OPEN  supplement_tax_lines_check;
     FETCH supplement_tax_lines_check INTO v_exist_flag;
     CLOSE supplement_tax_lines_check;
    END IF;


    IF NVL(v_exist_flag,0) <> 1 THEN
      return;
    END IF;

    v_tax_line_no := 0;

    /**************** Start of If Loop pr_new.interface_line_attribute1 IS NULL  **********/
    IF pr_new.interface_line_attribute4 IS NULL THEN --  pr_new.interface_line_attribute1, Bug# 4392001
      FOR tax_rec IN supplement_tax_lines_cnsldt  LOOP
        v_tax_line_no := v_tax_line_no+1;

-- Date 23/02/2006 by sacsethi for bug 5228046
-- precedence 6 to 10
  INSERT INTO JAI_AR_TRX_TAX_LINES(
                                                tax_line_no                                     ,
                                                customer_trx_line_id                            ,
                                                link_to_cust_trx_line_id                        ,
                                                precedence_1                                    ,
                                                precedence_2                                    ,
                                                precedence_3                                    ,
                                                precedence_4                                    ,
                                                precedence_5                                    ,
                                                precedence_6                                    ,
                                                precedence_7                                    ,
                                                precedence_8                                    ,
                                                precedence_9                                    ,
                                                precedence_10                                    ,
            tax_id                                          ,
                                                tax_rate                                        ,
                                                qty_rate                                        ,
                                                uom                                             ,
                                                tax_amount                                      ,
                                                func_tax_amount                                 ,
                                                base_tax_amount                                 ,
                                                creation_date                                   ,
                                                created_by                                      ,
                                                last_update_date                                ,
                                                last_updated_by                                 ,
                                                last_update_login
                                              )
                                        VALUES(
                                                v_tax_line_no                                   ,
                                                ra_customer_trx_lines_s.NEXTVAL                 ,
                                                v_customer_trx_line_id                          ,
                                                NULL                                            ,
                                                NULL                                            ,
                                                NULL                                            ,
                                                NULL                                            ,
                                                NULL                                            ,
                                                NULL                                            ,
                                                NULL                                            ,
                                                NULL                                            ,
                                                NULL                                            ,
                                                NULL                                            ,
            tax_rec.new_tax_id                              ,
                                                tax_rec.new_rate                                ,
                                                tax_rec.new_qty_rate                            ,
                                                tax_rec.new_uom                                 ,
                                                tax_rec.diff_amt                                ,
                                                tax_rec.func_tax_amt*nvl(v_exchange_rate,1)     ,
                                                tax_rec.base_tax_amt                            ,
                                                v_creation_date                                 ,
                                                v_created_by                                    ,
                                                v_last_update_date                              ,
                                                v_last_updated_by                               ,
                                                v_last_update_login
                                              );

        OPEN get_header_details;
        FETCH get_header_details INTO v_bill_to_customer_id       ,
                                    v_bill_to_site_use_id       , /*Bug 8371741*/
                                    v_trx_number                ,
                                    v_batch_source_id;

        FND_FILE.PUT_LINE(FND_FILE.LOG, ' Bill to cust id:  '|| v_bill_to_customer_id);
        FND_FILE.PUT_LINE(FND_FILE.LOG, ' Bill to site use: '|| v_bill_to_site_use_id); /*Bug 8371741*/
        FND_FILE.PUT_LINE(FND_FILE.LOG, ' Trx number: '|| v_trx_number);
        FND_FILE.PUT_LINE(FND_FILE.LOG, ' Batch source id: '|| v_batch_source_id);

        CLOSE get_header_details;
        OPEN  get_site(v_trx_number);
        FETCH get_site INTO v_bill_to_site_use_id; /*Bug 8371741*/
        CLOSE get_site;
      END LOOP;

    ELSIF pr_new.interface_line_attribute4 IS NOT NULL THEN  --  pr_new.interface_line_attribute1, Bug# 4392001
      FOR Tax_Rec IN SUPPLEMENT_TAX_LINES LOOP
        v_tax_line_no :=  v_tax_line_no+1;

        INSERT INTO JAI_AR_TRX_TAX_LINES(
                                                tax_line_no                                     ,
                                                customer_trx_line_id                            ,
                                                link_to_cust_trx_line_id                        ,
                                                precedence_1                                    ,
                                                precedence_2                                    ,
                                                precedence_3                                    ,
                                                precedence_4                                    ,
                                                precedence_5                                    ,
                                                precedence_6                                    ,
                                                precedence_7                                    ,
                                                precedence_8                                    ,
                                                precedence_9                                    ,
                                                precedence_10                                    ,
            tax_id                                          ,
                                                tax_rate                                        ,
                                                qty_rate                                        ,
                                                uom                                             ,
                                                tax_amount                                      ,
                                                func_tax_amount                                 ,
                                                base_tax_amount                                 ,
                                                creation_date                                   ,
                                                created_by                                      ,
                                                last_update_date                                ,
                                                last_updated_by                                 ,
                                                last_update_login
                                             )
                                      VALUES (
                                                v_tax_line_no                                   ,
                                                ra_customer_trx_lines_s.nextval                 ,
                                                v_customer_trx_line_id                          ,
                                                NULL                                            ,
                                                NULL                                            ,
                                                NULL                                            ,
                                                NULL                                            ,
                                                NULL                                            ,
                                                NULL                                            ,
                                                NULL                                            ,
                                                NULL                                            ,
                                                NULL                                            ,
                                                NULL                                            ,
            tax_rec.new_tax_id                              ,
                                                tax_rec.new_rate                                ,
                                                tax_rec.new_qty_rate                            ,
                                                tax_rec.new_uom                                 ,
                                                tax_rec.diff_amt                                ,
                                                tax_rec.func_tax_amt*nvl(v_exchange_rate,1)     ,
                                                tax_rec.base_tax_amt                            ,
                                                v_creation_date                                 ,
                                                v_created_by                                    ,
                                                v_last_update_date                              ,
                                                v_last_updated_by                               ,
                                                v_last_update_login
                                             );

        OPEN get_header_details;
        FETCH get_header_details INTO v_bill_to_customer_id,
                                    v_bill_to_site_use_id, /*Bug 8371741*/
                                    v_trx_number,
                                    v_batch_source_id;
        CLOSE get_header_details;
        OPEN get_site(v_trx_number);
        FETCH get_site INTO v_bill_to_site_use_id; /*Bug 8371741*/
        CLOSE get_site;
      END LOOP;

    END IF;

    /**************** End of If Loop pr_new.interface_line_attribute1 IS NULL  **********/

    IF pr_new.interface_line_attribute4 IS NULL THEN  -- new.interface_line_attribute1, Bug# 4392001
      FND_FILE.PUT_LINE(FND_FILE.LOG,' Int. line att4 is null');

      OPEN  supplement_lines_info_cnsldt;
      FETCH supplement_lines_info_cnsldt INTO  v_tax_amount,
                                             v_excise_diff,
                                             v_assessable_value;
      CLOSE supplement_lines_info_cnsldt;

      FND_FILE.PUT_LINE(FND_FILE.LOG,' Tax amount: '|| v_tax_amount);
      FND_FILE.PUT_LINE(FND_FILE.LOG,' Excise diff: '|| v_excise_diff);
      FND_FILE.PUT_LINE(FND_FILE.LOG,' Assessable Value: '||v_assessable_value);

      OPEN  supplement_lines_info_tax_catg;
      FETCH supplement_lines_info_tax_catg INTO v_tax_category_id;
      CLOSE supplement_lines_info_tax_catg;

      FND_FILE.PUT_LINE(FND_FILE.LOG,' Tax category: '|| v_tax_category_id);

    ELSIF pr_new.INTERFACE_LINE_ATTRIBUTE4 IS NOT NULL  THEN  --  pr_new.interface_line_attribute1, Bug# 4392001
      FND_FILE.PUT_LINE(FND_FILE.LOG,' Int. line att4 is not  null');
      OPEN  supplement_lines_info;
      FETCH supplement_lines_info INTO v_tax_category_id,
                                     v_tax_amount     ,
                                     v_excise_diff    ,
                                     v_assessable_value;
      CLOSE supplement_lines_info;
     FND_FILE.PUT_LINE(FND_FILE.LOG,' Tax category: '|| v_tax_category_id);
     FND_FILE.PUT_LINE(FND_FILE.LOG,' Tax amount: '|| v_tax_amount);
     FND_FILE.PUT_LINE(FND_FILE.LOG,' Excise diff: '|| v_excise_diff);
     FND_FILE.PUT_LINE(FND_FILE.LOG,' Assessable Value: '||v_assessable_value);

    END IF;


    /*added by csahoo for bug#5879769*/
    OPEN c_get_address_details(v_header_id);
    FETCH c_get_address_details into r_add;
    CLOSE c_get_address_details;

    v_service_type:=get_service_type( NVL(r_add.SHIP_TO_CUSTOMER_ID ,r_add.BILL_TO_CUSTOMER_ID) ,
                          NVL(r_add.SHIP_TO_SITE_USE_ID, r_add.BILL_TO_SITE_USE_ID),'C');

    INSERT INTO JAI_AR_TRX_LINES (
                                              customer_trx_line_id                      ,
                                              line_number                               ,
                                              customer_trx_id                           ,
                                              description                               ,
                                              inventory_item_id                         ,
                                              unit_code                                 ,
                                              quantity                                  ,
                                              tax_category_id                           ,
                                              auto_invoice_flag                         ,
                                              unit_selling_price                        ,
                                              line_amount                               ,
                                              tax_amount                                ,
                                              total_amount                              ,
                                              assessable_value                          ,
                                              creation_date                             ,
                                              created_by                                ,
                                              last_update_date                          ,
                                              last_updated_by                           ,
                                              last_update_login,
					      service_type_code   --Added by JMEENA for bug#8466638
                                           )
                                     VALUES(
                                              v_customer_trx_line_id                    ,
                                              pr_new.line_number                          ,
                                              v_header_id                               ,
                                              pr_new.description                          ,
                                              pr_new.inventory_item_id                    ,
                                              pr_new.uom_code                             ,
                                              NVL(pr_new.quantity_invoiced,0)             ,
                                              v_tax_category_id                         ,
                                              'Y'                                       ,
                                              NVL(pr_new.unit_selling_price,0)            ,
                                              v_line_amount                             ,
                                              v_tax_amount                              ,
                                              (v_line_amount + v_tax_amount)            ,
                                              v_assessable_value                        ,
                                              v_creation_date                           ,
                                              v_created_by                              ,
                                              v_last_update_date                        ,
                                              v_last_updated_by                         ,
                                              v_last_update_login,
					     v_service_type --Added by JMEENA for bug#8466638
                                           );

    UPDATE  JAI_AR_TRXS
    SET
          line_amount             =  NVL(line_amount, 0 ) + NVL(v_line_amount,0),
          once_completed_flag     = NVL(v_once_completed_flag,'N')
    WHERE
          customer_trx_id = v_header_id;

    --2001/04/20 Anuradha Parthasarathy
    OPEN  register_code_cur(v_organization_id, v_location_id,v_batch_source_id);
    FETCH register_code_cur INTO v_reg_code;
    CLOSE register_code_cur;

    IF NVL(v_excise_diff ,0) > 0 THEN

      IF NVL(v_reg_code,'N') IN ('DOMESTIC_EXCISE','EXPORT_EXCISE') THEN

        FND_FILE.PUT_LINE(FND_FILE.LOG,' Register code: '||v_reg_code);


        OPEN pref_cur(v_organization_id, v_location_id);
        FETCH pref_cur INTO  v_pref_rg23a, v_pref_rg23c, v_pref_pla;
        CLOSE pref_cur;

        FND_FILE.PUT_LINE(FND_FILE.LOG,' Pref RG23A: '|| v_pref_rg23a);
        FND_FILE.PUT_LINE(FND_FILE.LOG,' Pref RG23c: '||v_pref_rg23c);
        FND_FILE.PUT_LINE(FND_FILE.LOG,' Pref. PLA:  '||v_pref_pla);

        OPEN rg_bal_cur(v_organization_id, v_location_id);
        FETCH rg_bal_cur INTO v_rg23a_balance, v_rg23c_balance, v_pla_balance;
        CLOSE rg_bal_cur;

        FND_FILE.PUT_LINE(FND_FILE.LOG,' Balance: RG23A:'||v_rg23a_balance);
  FND_FILE.PUT_LINE(FND_FILE.LOG,' RG23c: '||v_rg23c_balance);
  FND_FILE.PUT_LINE(FND_FILE.LOG,' PLA: '|| v_pla_balance);


        OPEN  ssi_unit_flag_cur(v_organization_id, v_location_id);
        FETCH ssi_unit_flag_cur INTO v_ssi_unit_flag;
        CLOSE ssi_unit_flag_cur;

  FND_FILE.PUT_LINE(FND_FILE.LOG,' SSI unit flag'||v_ssi_unit_flag);

        IF v_pref_rg23a = 1 THEN                             --5
          IF v_rg23a_balance >= NVL(v_excise_diff,0) THEN         --6
            v_reg_type := 'RG23A';

          ELSIF v_pref_rg23c = 2 THEN                                     --6

            IF v_rg23c_balance >= NVL(v_excise_diff,0) THEN        --7
              v_reg_type  := 'RG23C';
            ELSIF  v_pla_balance >= NVL(v_excise_diff,0) THEN  --7
              v_reg_type  := 'PLA';
            ELSIF NVL(v_ssi_unit_flag,'N') = 'Y' THEN                  --7
              v_reg_type  := 'PLA';
            ELSE                                                       --7
              v_raise_error_flag := 'Y';
            END IF;                                                    --7

          ELSIF v_pla_balance >= NVL(v_excise_diff,0) THEN             --6
            v_reg_type  := 'PLA';

          ELSIF NVL(v_ssi_unit_flag,'N') = 'Y' THEN                    --6
            v_reg_type  := 'PLA';

          ELSIF v_rg23c_balance >= NVL(v_excise_diff,0) THEN   --6
            v_reg_type  := 'RG23C';

          ELSE                                                 --6
            v_raise_error_flag := 'Y';
          END IF;                                                      --6

        ELSIF v_pref_rg23c = 1  THEN                                  --5

          IF v_rg23c_balance >= NVL(v_excise_diff,0) THEN --6
            v_reg_type := 'RG23C';

          ELSIF v_pref_rg23a = 2 THEN                                     --6

            IF v_rg23a_balance >= NVL(v_excise_diff,0) THEN        --7
              v_reg_type  := 'RG23A';
            ELSIF v_pla_balance >= NVL(v_excise_diff,0) THEN   --7
              v_reg_type  := 'PLA';
            ELSIF NVL(v_ssi_unit_flag,'N') = 'Y' THEN                  --7
              v_reg_type  := 'PLA';
            ELSE                                                       --7
              v_raise_error_flag := 'Y';
            END IF;                                                    --7

          ELSIF v_pla_balance >= NVL(v_excise_diff,0) THEN                --6
            v_reg_type  := 'PLA';
          ELSIF NVL(v_ssi_unit_flag,'N') = 'Y' THEN                       --6
            v_reg_type  := 'PLA';
          ELSIF v_rg23a_balance >= NVL(v_excise_diff,0) THEN      --6
            v_reg_type  := 'RG23A';
          ELSE                                                        --6
            v_raise_error_flag := 'Y';
          END IF;                                                 --6

        ELSIF  v_pla_balance >= NVL(v_excise_diff,0) THEN
          v_reg_type  := 'PLA';
        ELSIF NVL(v_ssi_unit_flag,'N') = 'Y' THEN                     --6
          v_reg_type  := 'PLA';
        ELSIF v_pref_rg23a = 2 THEN                                   --6
          IF v_rg23a_balance >= NVL(v_excise_diff,0) THEN        --7
            v_reg_type  := 'RG23A';
          ELSIF  v_rg23c_balance >= NVL(v_excise_diff,0) THEN     --7
            v_reg_type  := 'RG23C';
          ELSE
            v_raise_error_flag := 'Y';
          END IF;

        ELSIF v_rg23c_balance >= NVL(v_excise_diff,0) THEN    --7
          v_reg_type  := 'RG23C';
        ELSIF v_rg23a_balance >= NVL(v_excise_diff,0) THEN    --7
          v_reg_type  := 'RG23A';
        ELSE
          v_raise_error_flag := 'Y';
        END IF;                                                       --5

        IF NVL(v_raise_error_flag,'N') = 'Y' THEN
/*           RAISE_APPLICATION_ERROR(-20120, 'NONE OF the Register Have Balances Greater OR Equal TO the Excisable Amount ->' || TO_CHAR(v_excise_diff));
        */ pv_return_code := jai_constants.expected_error ; pv_return_message :=  'NONE OF the Register Have Balances Greater OR Equal TO the Excisable Amount ->' || TO_CHAR(v_excise_diff) ; return ;
        END IF;

        OPEN  register_code_meaning_cur(v_reg_code, 'REGISTER_TYPE'); /* Modified by Ramananda for removal of SQL LITERALs */
        FETCH register_code_meaning_cur INTO v_meaning;
        CLOSE register_code_meaning_cur;

        FND_FILE.PUT_LINE(FND_FILE.LOG,' Meaning'|| v_meaning);

        OPEN   fin_year_cur(v_organization_id);
        FETCH  fin_year_cur INTO v_fin_year;
        CLOSE  fin_year_cur;

  FND_FILE.PUT_LINE(FND_FILE.LOG,' Fin year '|| v_fin_year);

        OPEN  Batch_Source_Name_Cur(v_batch_source_id);
        FETCH Batch_Source_Name_Cur INTO v_order_invoice_type;
        CLOSE Batch_Source_Name_Cur;

  FND_FILE.PUT_LINE(FND_FILE.LOG,' Order invoice type: '|| v_order_invoice_type);

        OPEN   Def_Excise_Invoice_Cur(v_organization_id, v_location_id, v_fin_year, v_order_invoice_type, v_meaning);
        FETCH  Def_Excise_Invoice_Cur INTO v_start_number, v_end_number, v_jump_by, v_prefix;
        CLOSE  Def_Excise_Invoice_Cur;

  FND_FILE.PUT_LINE(FND_FILE.LOG,' Start number'|| v_start_number);
  FND_FILE.PUT_LINE(FND_FILE.LOG,' End number:'|| v_end_number);
  FND_FILE.PUT_LINE(FND_FILE.LOG,' jump by: '|| v_jump_by);
  FND_FILE.PUT_LINE(FND_FILE.LOG,' prefix : '|| v_prefix);


        IF v_start_number IS NOT NULL THEN                            --2
          IF NVL(v_start_number,0) >= NVL(v_end_number,0) AND v_end_number IS NOT NULL THEN
/*             RAISE_APPLICATION_ERROR(-20120, 'Excise Invoice NUMBER has been exhausted. ' ||
                                            ' Increase END NUMBER OR enter fresh START NUMBER AND END NUMBER.'); */ pv_return_code := jai_constants.expected_error ; pv_return_message :=  'Excise Invoice NUMBER has been exhausted. ' ||
                                            ' Increase END NUMBER OR enter fresh START NUMBER AND END NUMBER.' ; return ;
          END IF;
          v_exc_invoice_no := NVL(v_start_number,0);
          v_start_number := NVL(v_start_number,0) + NVL(v_jump_by,0);
          IF v_prefix IS NOT NULL THEN
            v_exc_invoice_no := v_prefix||'/'||v_exc_invoice_no;
          END IF;
        END IF;                                                               --2

        IF v_exc_invoice_no IS NOT NULL THEN
          IF v_start_number IS NOT NULL THEN
            FOR master_org_rec IN ec_code_cur(v_organization_id, v_location_id) LOOP
              UPDATE
                    JAI_CMN_RG_EXC_INV_NOS
              SET
                    start_number            = v_start_number,
                    last_update_date        = v_last_update_date,
                    last_updated_by         = v_last_updated_by,
                    last_update_login       = v_last_update_login
              WHERE
                    organization_id         = master_org_rec.organization_id AND
                    location_id             = master_org_rec.location_id     AND
                    fin_year                = v_fin_year                     AND
                    order_invoice_type      = v_order_invoice_type           AND
                    register_code           = v_meaning;

            END LOOP;
          END IF;
        END IF;

        UPDATE JAI_AR_TRX_LINES
        SET    payment_register             =  v_reg_type,
               excise_invoice_no            =  v_exc_invoice_no,
               excise_invoice_date          =  trunc(sysdate)
        WHERE
               customer_trx_line_id         = v_customer_trx_line_id AND
               inventory_item_id            = pr_new.inventory_item_id AND
               customer_trx_id              = v_header_id;

        OPEN  site_cur;
        FETCH site_cur INTO v_ship_id,v_ship_site_id;
        CLOSE site_cur;

        IF v_reg_type IN ('RG23A','RG23C') THEN
        jai_om_rg_pkg.ja_in_rg23_part_I_entry(
                                                  v_reg_type                      ,
                                                  v_fin_year                      ,
                                                  v_organization_id               ,
                                                  v_location_id                   ,
                                                  pr_new.inventory_item_id          ,
                                                  33                              ,
                                                  sysdate                         ,
                                                  'I'                             ,
                                                  pr_new.quantity_invoiced          ,
                                                  pr_new.uom_code                   ,
                                                  v_exc_invoice_no                ,
                                                  sysdate                         ,
                                                  v_excise_diff                   ,
                                                  0                               ,
                                                  0                               ,
                                                  v_ship_id                       ,
                                                  v_ship_site_id                  ,
                                                  v_header_id                     ,
                                                  sysdate                         ,
                                                  v_reg_code                      ,
                                                  v_creation_date                 ,
                                                  v_created_by                    ,
                                                  v_last_update_date              ,
                                                  v_last_updated_by               ,
                                                  v_last_update_login
                                             );

        SELECT JAI_CMN_RG_23AC_I_TRXS_S.currval INTO v_part_i_register_id FROM dual;  /* txns changed to trxs by rchandan for  bug#4487676 */

        jai_om_rg_pkg.ja_in_rg23_part_II_entry(
                                                  v_reg_code                      ,
                                                  v_reg_type                      ,
                                                  v_fin_year                      ,
                                                  v_organization_id               ,
                                                  v_location_id                   ,
                                                  pr_new.inventory_item_id          ,
                                                  33                              ,
                                                  sysdate                         ,
                                                  v_part_i_register_id            ,
                                                  v_exc_invoice_no                ,
                                                  sysdate                         ,
                                                  v_excise_diff                   ,
                                                  0                               ,
                                                  0                               ,
                                                  v_ship_id                       ,
                                                  v_ship_site_id                  ,
                                                  v_source_name                   ,
                                                  v_category_name                 ,
                                                  v_creation_date                 ,
                                                  v_created_by                    ,
                                                  v_last_update_date              ,
                                                  v_last_updated_by               ,
                                                  v_last_update_login             ,
                                                  pr_new.customer_trx_line_id       ,
                                                  null                            ,
                                                  null
                                              );

        SELECT JAI_CMN_RG_23AC_I_TRXS_S.currval  INTO v_rg23_part_i_no  FROM dual; /* txns changed to trxs by rchandan for bug# bug#4487676 */

        SELECT JAI_CMN_RG_23AC_II_TRXS_S.currval INTO v_rg23_part_ii_no FROM dual;

        UPDATE  JAI_CMN_RG_23AC_I_TRXS
        SET     REGISTER_ID_PART_II = v_rg23_part_ii_no,
                charge_account_id = (
                                      SELECT
                                              charge_account_id
                                      FROM
                                              JAI_CMN_RG_23AC_II_TRXS
                                      WHERE
                                              register_id = v_rg23_part_ii_no
                                     )
        WHERE  register_id = v_rg23_part_i_no;

      ELSIF v_reg_type = 'PLA' THEN
        jai_om_rg_pkg.ja_in_pla_entry(
                                      v_organization_id               ,
                                      v_location_id                   ,
                                      pr_new.inventory_item_id          ,
                                      v_fin_year                      ,
                                      33                              ,
                                      v_header_id                     ,
                                      SYSDATE                         ,
                                      v_exc_invoice_no                ,
                                      SYSDATE                         ,
                                      v_excise_diff                   ,
                                      0                               ,
                                      0                               ,
                                      v_ship_id                       ,
                                      v_ship_site_id                  ,
                                      v_source_name                   ,
                                      v_category_name                 ,
                                      v_creation_date                 ,
                                      v_created_by                    ,
                                      v_last_update_date              ,
                                      v_last_updated_by               ,
                                      v_last_update_login
                                    );


        SELECT  JAI_CMN_RG_PLA_TRXS_S1.currval INTO v_pla_register_no FROM dual;
        UPDATE  JAI_CMN_RG_23AC_I_TRXS
        SET     REGISTER_ID_PART_II = v_pla_register_no,
                charge_account_id = (SELECT charge_account_id FROM JAI_CMN_RG_PLA_TRXS
                                                       WHERE  register_id = v_pla_register_no)
        WHERE  register_id = v_rg23_part_i_no;
      END IF;

      END IF;
    END IF;

  --2001/04/20 Anuradha Parthasarathy

  /* ( */
  ELSE /* ELSIF OF pr_new.interface_line_context IN ('SUPPLEMENT CM','SUPPLEMENT DM','SUPPLEMENT INVOICE')     */
    -------------------------------------------------------------------------------------------
    /*from here starts the actual coding with respect to what needs to be done for a normal imported invoice
      the code segment until now - is for supplementary transactions
    */
     -- Manohar Mishra 12/02/01
	 /* Moved the cursor to after if nvl(v_exist_flag,0) <> 1 then statement for bug# 6391684( FP of 6386592)
     OPEN   duplicate_hdr_cur;
     FETCH  duplicate_hdr_cur INTO x;
     CLOSE  duplicate_hdr_cur; */

     OPEN  So_picking_record_check;
     FETCH So_picking_record_check INTO v_exist_flag;
     CLOSE So_picking_record_check;

     ln_first_time := 0;
     IF NVL(v_exist_flag,0) <> 1 THEN

       /* Here checking whether the invoice line corresponds to a bill only workflow , and if is true , the control should
          not return because there would be no shipment process  */

       ln_bill_only := 0;
       open  c_bill_only_invoice(pr_new.customer_trx_line_id, 'R_BILL_ONLY'); /* Modified by Ramananda for removal of SQL LITERALs */
       fetch c_bill_only_invoice into ln_bill_only;
       close c_bill_only_invoice;

       if ln_bill_only = 1 then
          process_bill_only_invoice;
          return;
       end if;
       -- here code returns for an ato imported order because because
       -- records do not exist in JAI_OM_WSH_LINES_ALL table
       process_taxes_for_ato_order;


     END IF;

     v_exist_flag := 0;

       OPEN  so_picking_hdr_info;
       FETCH so_picking_hdr_info INTO v_organization_id, v_location_id;
       CLOSE so_picking_hdr_info;
    FND_FILE.PUT_LINE(FND_FILE.LOG,'v_organization_id= '||v_organization_id||' v_location_id= ' || v_location_id );

	 /* Added by JMEENA for bug#5684033 */
    IF v_organization_id IS NULL THEN
       OPEN  so_picking_hdr_info_1;
       FETCH so_picking_hdr_info_1 INTO v_organization_id, v_location_id;
       CLOSE so_picking_hdr_info_1;

	   FND_FILE.PUT_LINE(FND_FILE.LOG,'From Cursor so_picking_hdr_info_1: v_organization_id= '||v_organization_id||' v_location_id= ' || v_location_id );
    END IF ;

    /* Added by JMEENA for bug#6498345 ( FP 6492966), Starts */
    IF v_organization_id IS NULL THEN
      ln_order_ato := NULL ;
      OPEN  c_ato_order ;
      FETCH c_ato_order INTO ln_order_ato ;
      CLOSE c_ato_order ;

      IF nvl(ln_order_ato,0) = 1 THEN
        open  c_ato_hdr_info;
        fetch c_ato_hdr_info into v_organization_id, v_location_id;
        close c_ato_hdr_info;
      END IF ;

        FND_FILE.PUT_LINE(FND_FILE.LOG,'ATO Header Info: v_organization_id= '||v_organization_id||' v_location_id= ' || v_location_id );
    END IF ;

    -- added by Allen Yang 02-Apr-2010 for bug 9485355 (non-shippable enhancement), begin
    -- get organization_id, location_id for non-shippable items
    IF v_organization_id IS NULL
    THEN
      IF((v_interface_line_attribute3 IS NULL OR v_interface_line_attribute3 = '0') -- delivery_id
         AND v_interface_line_attribute6 IS NOT NULL -- order_line_id
        )
      THEN
        OPEN c_so_picking_hdr_info_ns;
        FETCH c_so_picking_hdr_info_ns INTO v_organization_id, v_location_id;
        CLOSE c_so_picking_hdr_info_ns;
        FND_FILE.PUT_LINE(FND_FILE.LOG,'From Cursor c_so_picking_hdr_info_ns: v_organization_id= '||v_organization_id||' v_location_id= ' || v_location_id );
      END IF; -- v_interface_line_attribute3 IS NULL ... ...
    END IF; -- v_organization_id IS NULL
    -- added by Allen Yang 02-Apr-2010 for bug 9485355 (non-shippable enhancement), end


    /* Added for bug#6498345( FP 6492966), Ends */
	/* This cursor moved here from above for bug#6391684 (FP of 6386592) */
     OPEN   duplicate_hdr_cur;
     FETCH  duplicate_hdr_cur INTO x;
     CLOSE  duplicate_hdr_cur;

     /*( */
     IF NVL(x,0) <> 1 THEN
       /* Bug 5243532. Added by Lakshmi Gopalsami
          Removed the reference to cursor set_of_books_cur.
       END IF;
       */
       /* start additions by sriram - bug# 3607101
       */
       open  c_ont_source_code;
       fetch c_ont_source_code into v_ont_source_code;
       close c_ont_source_code;
       v_ont_source_code := ltrim(rtrim(v_ont_source_code));
       -- The value retreived here should be ideally 'ORDER ENTRY' , not hard coding because it can be profile driven.
       /*
       ends here -- bug# 3607101
       */

       INSERT INTO JAI_AR_TRXS
                   (Customer_Trx_ID, Organization_ID, Location_ID, Trx_Number,
                   Update_RG_Flag,UPDATE_RG23D_FLAG, Once_Completed_Flag, Batch_Source_ID, Set_Of_Books_ID,
                   Primary_Salesrep_ID, Invoice_Currency_Code, Exchange_Rate_Type,
                   Exchange_Date, Exchange_Rate,
                   creation_date, created_by, last_update_date, last_updated_by, last_update_login,
                   legal_entity_id         /* rallamse bug#4448789 */
                   )
                   VALUES (
                   v_header_id, v_organization_id, v_location_id, v_trx_number,
                   'Y', 'Y','N', v_batch_source_id, v_books_id,
                   v_salesrep_id, c_from_currency_code, c_conversion_type,
                   c_conversion_date, c_conversion_rate,
                   v_creation_date, v_created_by, v_last_update_date, v_last_updated_by, v_last_update_login,
                   ln_legal_entity_id         /* rallamse bug#4448789 */
                   );
     END IF;

     /* ) */

     OPEN  so_picking_tax_record_check;
     FETCH so_picking_tax_record_check INTO v_exist_flag;
     CLOSE so_picking_tax_record_check;

     /*
       Check if taxes exist in JAI_OM_WSH_LINE_TAXES tables.
       IF yes then insert all the taxes into ja_in_ra_cust_trx_lines_all table
       IF no then check the same in ja_in_so_tax_lines_table.

     (
     */
     IF NVL(v_exist_flag,0) = 1 THEN
       v_bond_tax_amt := 0;            -- cbabu for Bug# 2779990

       FOR tax_rec IN so_picking_tax_lines_info LOOP
         /*IF ln_first_time = 0 THEN
            ln_first_time := ln_first_time + 1;
            UPDATE JAI_AR_TRXS
            SET    vat_invoice_no =  tax_rec.vat_invoice_no,
                   vat_invoice_date = tax_rec.vat_invoice_date
            WHERE  customer_trx_id = pr_new.customer_trx_id;
         END IF;*/
        --2001/06/05 Anuradha Parthasarathy

        -- ssumaith - 3532716.
        v_base_tax_amount :=0;
        v_tax_amt :=0;
        v_func_tax_amount :=0;
        -- ssumaith - 3532716.
         OPEN  so_picking_tax_amt(Tax_Rec.tax_id);
         FETCH so_picking_tax_amt INTO v_base_tax_amount,v_tax_amt,v_func_tax_amount;
         CLOSE so_picking_tax_amt;

         v_tax_line_count := 0; -- ssumaith - 3532716.
         OPEN  duplicate_tax_lines_cur(tax_rec.tax_id);
         FETCH duplicate_tax_lines_cur INTO v_tax_line_count;
         CLOSE duplicate_tax_lines_cur;

         IF NVL(v_tax_line_count,0) <> 1 THEN
           IF v_register_code ='BOND_REG' THEN
             IF tax_rec.tax_type NOT IN ('Excise','Other Excise','CVD_EDUCATION_CESS','EXCISE_EDUCATION_CESS',jai_constants.tax_type_sh_cvd_edu_cess, jai_constants.tax_type_sh_exc_edu_cess) THEN
             /*jai_constants.tax_type_sh_cvd_edu_cess,jai_constants.tax_type_sh_exc_edu_cess added by CSahoo BUG#5989740*/
               IF (NVL(pr_new.Interface_line_attribute11,'0') = '0'
                   and nvl(v_ont_source_code,'ORDER ENTRY') = ltrim(rtrim(pr_new.interface_line_context))
                  )/* following OR added by sriram - bug#3607101 */
               or
                  (nvl(v_ont_source_code,'ORDER ENTRY') <> nvl(ltrim(rtrim(pr_new.interface_line_context)),'$$$') -- added by sriram - bug# 3607101
                  )
               then
-- Date 23/02/2006 by sacsethi for bug 5228046
-- precedence 6 to 10
      INSERT INTO JAI_AR_TRX_TAX_LINES (
                                                           tax_line_no                        ,
                                                           customer_trx_line_id               ,
                                                           link_to_cust_trx_line_id           ,
                                                           precedence_1                       ,
                                                           precedence_2                       ,
                                                           precedence_3                       ,
                                                           precedence_4                       ,
                                                           precedence_5                       ,
                                                           precedence_6                       ,
                                                           precedence_7                       ,
                                                           precedence_8                       ,
                                                           precedence_9                       ,
                                                           precedence_10                       ,
                 tax_id                             ,
                                                           tax_rate                           ,
                                                           qty_rate                           ,
                                                           uom                                ,
                                                           tax_amount                         ,
                                                           func_tax_amount                    ,
                                                           base_tax_amount                    ,
                                                           creation_date                      ,
                                                           created_by                         ,
                                                           last_update_date                   ,
                                                           last_updated_by                    ,
                                                           last_update_login
                                                          )
                                                    VALUES
                                                          (
                                                            tax_rec.tax_line_no               ,
                                                            ra_customer_trx_lines_s.nextval   ,
                                                            v_customer_trx_line_id            ,
                                                            tax_rec.precedence_1              ,
                                                            tax_rec.precedence_2              ,
                                                            tax_rec.precedence_3              ,
                                                            tax_rec.precedence_4              ,
                                                            tax_rec.precedence_5              ,
                                                            tax_rec.precedence_6              ,
                                                            tax_rec.precedence_7              ,
                                                            tax_rec.precedence_8              ,
                                                            tax_rec.precedence_9              ,
                                                            tax_rec.precedence_10              ,
                  tax_rec.tax_id                    ,
                                                            tax_rec.tax_rate                  ,
                                                            tax_rec.qty_rate                  ,
                                                            tax_rec.uom                       ,
                                                            round(v_tax_amt,2)                ,
                                                            round(v_func_tax_amount,2)        ,
                                                            round(v_base_tax_amount,2)        ,
                                                            v_creation_date                   ,
                                                            v_created_by                      ,
                                                            v_last_update_date                ,
                                                            v_last_updated_by                 ,
                                                            v_last_update_login
                                                          );

                                        -- cbabu for Bug# 2779990
                  IF tax_rec.tax_type <> 'TDS' THEN
                    v_bond_tax_amt := v_bond_tax_amt + nvl(v_tax_amt,0);
                  END IF;
               END IF;  /* END IF FOR IF (NVL(pr_new.Interface_line_attribute11,'0') = '0'  */
             END IF;   /* END IF FOR IF tax_rec.tax_type NOT IN ('Excise','Other Excise')*/

           ELSE   /*  ELSE OF IF v_register_code ='BOND_REG'  */
              -- the following If Condition  added by Sriram - 27/06/2002 - Bug # 2398198
              -- Here trying to conditionally update Ja_in_ra_customer_trx_table
              -- For the second line of the same order line in AR , the tax amounts should not be
              -- inserted.Hence conditionally executing the insert statement.
             IF (NVL(pr_new.Interface_line_attribute11,'0') ='0'
                 and nvl(v_ont_source_code,'ORDER ENTRY') = ltrim(rtrim(pr_new.interface_line_context)) -- added by sriram - bug# 3607101
                )/* following OR added by sriram - bug#3607101 */
              or
             (nvl(v_ont_source_code,'ORDER ENTRY') <> nvl(ltrim(rtrim(pr_new.interface_line_context)),'$$$')  -- added by sriram - bug# 3607101
             )
             then
-- Date 23/02/2006 by sacsethi for bug 5228046
-- precedence 6 to 10
         INSERT INTO JAI_AR_TRX_TAX_LINES(
                                                       tax_line_no                   ,
                                                       customer_trx_line_id          ,
                                                       link_to_cust_trx_line_id      ,
                                                       precedence_1                  ,
                                                       precedence_2                  ,
                                                       precedence_3                  ,
                                                       precedence_4                  ,
                                                       precedence_5                  ,
                                                       precedence_6                  ,
                                                       precedence_7                  ,
                                                       precedence_8                  ,
                                                       precedence_9                  ,
                                                       precedence_10                  ,
                   tax_id                        ,
                                                       tax_rate                      ,
                                                       qty_rate                      ,
                                                       uom                           ,
                                                       tax_amount                    ,
                                                       func_tax_amount               ,
                                                       base_tax_amount               ,
                                                       creation_date                 ,
                                                       created_by                    ,
                                                       last_update_date              ,
                                                       last_updated_by               ,
                                                       last_update_login
                                                      )

                                                VALUES(
                                                       tax_rec.tax_line_no                ,
                                                       ra_customer_trx_lines_s.nextval    ,
                                                       v_customer_trx_line_id             ,
                                                       tax_rec.precedence_1               ,
                                                       tax_rec.precedence_2               ,
                                                       tax_rec.precedence_3               ,
                                                       tax_rec.precedence_4               ,
                                                       tax_rec.precedence_5               ,
                                                       tax_rec.precedence_6               ,
                                                       tax_rec.precedence_7               ,
                                                       tax_rec.precedence_8               ,
                                                       tax_rec.precedence_9               ,
                                                       tax_rec.precedence_10               ,
                   tax_rec.tax_id                     ,
                                                       tax_rec.tax_rate                   ,
                                                       tax_rec.qty_rate                   ,
                                                       tax_rec.uom                        ,
                                                       round(v_tax_amt,2)                 ,
                                                       round(v_func_tax_amount,2)         ,
                                                       round(v_base_tax_amount,2)         ,
                                                       v_creation_date                    ,
                                                       v_created_by                       ,
                                                       v_last_update_date                 ,
                                                       v_last_updated_by                  ,
                                                       v_last_update_login
                  );

             END IF;
           END IF;  /*  END IF OF IF v_register_code ='BOND_REG'  */
         END IF; /* END IF OF IF NVL(v_tax_line_count,0) <> 1 */
       END LOOP;
       OPEN  so_picking_lines_info;
       FETCH so_picking_lines_info INTO v_tax_category_id               ,
                                        v_qty                           ,
                                        v_tax_amount                    ,
                                        v_assessable_value              ,
                                        v_basic_excise_duty_amount      ,
                                        v_add_excise_duty_amount        ,
                                        v_oth_excise_duty_amount        ,
                                        v_payment_register              ,
                                        v_excise_invoice_no             ,
                                        v_preprinted_excise_inv_no      ,
                                        v_excise_invoice_date           ,
                                        v_excise_exempt_type            ,
                                        v_excise_exempt_refno           ,
                                        v_excise_exempt_date            ,
                                        v_ar3_form_no                   ,
                                        v_ar3_form_date                 , -- Vijay Shankar for Bug # 3181892
                                        lv_vat_exemption_flag           , -- added, Harshita for bug#4245062
                                        lv_vat_exemption_type           ,
                                        lv_vat_exemption_date           ,
                                        lv_vat_exemption_refno          ,
                                        ln_vat_assessable_value         ,
                                        ln_vat_invoice_no               ,
                                        ln_vat_invoice_date             ;
       CLOSE so_picking_lines_info;
       -- cbabu for Bug# 2779990
       -- this overrides the v_tax_amount fetched from cursor SO_PICKING_LINES_INFO for bond reg transactions
       IF v_register_code = 'BOND_REG' THEN
         v_tax_amount := v_bond_tax_amt / v_qty;
       END IF;
       -- Bug 3357587
       -- To pick assessable_value from JAI_OM_OE_SO_LINES instead of JAI_OM_WSH_LINES_ALL
         OPEN   C_JA_SO_LINES_ASSESSABLE_VAL;
         FETCH  C_JA_SO_LINES_ASSESSABLE_VAL into v_assessable_value,v_service_type;/*5879769..csahoo*/
         CLOSE  C_JA_SO_LINES_ASSESSABLE_VAL;


     ELSE  /* ELSE OF IF NVL(v_exist_flag,0) = 1 */
       -- modified by Allen Yang 02-Apr-2010 for bug 9485355 (12.1.3 non-shippable enhancement), begin
       -- for non-shippable items, need to fetch OFI taxes from JAI_OM_WSH_LINE_TAXES
       IF((v_interface_line_attribute3 IS NULL OR v_interface_line_attribute3 = '0') -- delivery_id
         AND v_interface_line_attribute6 IS NOT NULL -- order_line_id
        )
       THEN
         OPEN  c_so_picking_tax_record_ns;
         FETCH c_so_picking_tax_record_ns INTO v_exist_flag;
         CLOSE c_so_picking_tax_record_ns;
         IF NVL(v_exist_flag,0) = 1
         THEN
           v_bond_tax_amt := 0;
           FOR tax_rec IN c_so_picking_tax_lines_info_ns
           LOOP
             v_base_tax_amount :=0;
             v_tax_amt :=0;
             v_func_tax_amount :=0;
             OPEN  c_so_picking_tax_amt_ns (Tax_Rec.tax_id);
             FETCH c_so_picking_tax_amt_ns INTO v_base_tax_amount,v_tax_amt,v_func_tax_amount;
             CLOSE c_so_picking_tax_amt_ns;

             v_tax_line_count := 0;
             OPEN  duplicate_tax_lines_cur(tax_rec.tax_id);
             FETCH duplicate_tax_lines_cur INTO v_tax_line_count;
             CLOSE duplicate_tax_lines_cur;

             IF NVL(v_tax_line_count,0) <> 1 THEN
               IF v_register_code ='BOND_REG' THEN
                 IF tax_rec.tax_type NOT IN ('Excise','Other Excise','CVD_EDUCATION_CESS',
                                            'EXCISE_EDUCATION_CESS',
                                            jai_constants.tax_type_sh_cvd_edu_cess,
                                            jai_constants.tax_type_sh_exc_edu_cess)
                 THEN
                   IF (NVL(pr_new.Interface_line_attribute11,'0') = '0'
                      AND nvl(v_ont_source_code,'ORDER ENTRY') =
                          ltrim(rtrim(pr_new.interface_line_context))
                      )
                      OR
                      (nvl(v_ont_source_code,'ORDER ENTRY') <>
                       nvl(ltrim(rtrim(pr_new.interface_line_context)),'$$$')
                      )
                   THEN
                     INSERT INTO JAI_AR_TRX_TAX_LINES (
                                                           tax_line_no                    ,
                                                           customer_trx_line_id           ,
                                                           link_to_cust_trx_line_id       ,
                                                           precedence_1                   ,
                                                           precedence_2                   ,
                                                           precedence_3                   ,
                                                           precedence_4                   ,
                                                           precedence_5                   ,
                                                           precedence_6                   ,
                                                           precedence_7                   ,
                                                           precedence_8                   ,
                                                           precedence_9                   ,
                                                           precedence_10                  ,
                                                           tax_id                         ,
                                                           tax_rate                       ,
                                                           qty_rate                       ,
                                                           uom                            ,
                                                           tax_amount                     ,
                                                           func_tax_amount                ,
                                                           base_tax_amount                ,
                                                           creation_date                  ,
                                                           created_by                    ,
                                                           last_update_date               ,
                                                           last_updated_by                ,
                                                           last_update_login
                                                       )
                                                 VALUES
                                                       (
                                                            tax_rec.tax_line_no           ,
                                                            ra_customer_trx_lines_s.nextval,
                                                            v_customer_trx_line_id        ,
                                                            tax_rec.precedence_1           ,
                                                            tax_rec.precedence_2           ,
                                                            tax_rec.precedence_3           ,
                                                            tax_rec.precedence_4           ,
                                                            tax_rec.precedence_5           ,
                                                            tax_rec.precedence_6           ,
                                                            tax_rec.precedence_7           ,
                                                            tax_rec.precedence_8           ,
                                                            tax_rec.precedence_9           ,
                                                            tax_rec.precedence_10           ,
                                                            tax_rec.tax_id                 ,
                                                            tax_rec.tax_rate               ,
                                                            tax_rec.qty_rate               ,
                                                            tax_rec.uom                    ,
                                                            round(v_tax_amt,2)             ,
                                                            round(v_func_tax_amount,2)     ,
                                                            round(v_base_tax_amount,2)     ,
                                                            v_creation_date                ,
                                                            v_created_by                   ,
                                                            v_last_update_date             ,
                                                            v_last_updated_by              ,
                                                            v_last_update_login
                                                          );
                     IF tax_rec.tax_type <> 'TDS' THEN
                       v_bond_tax_amt := v_bond_tax_amt + nvl(v_tax_amt,0);
                     END IF;
                  END IF;  /* END IF FOR IF (NVL(pr_new.Interface_line_attribute11,'0') = '0'  */
               END IF;   /* END IF FOR IF tax_rec.tax_type NOT IN ('Excise','Other Excise')*/

           ELSE   /*  ELSE OF IF v_register_code ='BOND_REG'  */
              -- Here trying to conditionally update Ja_in_ra_customer_trx_table
              -- For the second line of the same order line in AR , the tax amounts should
              -- not be
              -- inserted.Hence conditionally executing the insert statement.
             IF (NVL(pr_new.Interface_line_attribute11,'0') ='0'
                 AND nvl(v_ont_source_code,'ORDER ENTRY') =
                         ltrim(rtrim(pr_new.interface_line_context))
                )
                OR
                (nvl(v_ont_source_code,'ORDER ENTRY') <>
                 nvl(ltrim(rtrim(pr_new.interface_line_context)),'$$$')
                )
             THEN
               INSERT INTO JAI_AR_TRX_TAX_LINES(
                                                       tax_line_no                   ,
                                                       customer_trx_line_id          ,
                                                       link_to_cust_trx_line_id      ,
                                                       precedence_1                  ,
                                                       precedence_2                  ,
                                                       precedence_3                  ,
                                                       precedence_4                  ,
                                                       precedence_5                  ,
                                                       precedence_6                  ,
                                                       precedence_7                  ,
                                                       precedence_8                  ,
                                                       precedence_9                  ,
                                                       precedence_10                  ,
                                                       tax_id                        ,
                                                       tax_rate                      ,
                                                       qty_rate                      ,
                                                       uom                           ,
                                                       tax_amount                    ,
                                                       func_tax_amount               ,
                                                       base_tax_amount               ,
                                                       creation_date                 ,
                                                       created_by                    ,
                                                       last_update_date              ,
                                                       last_updated_by               ,
                                                       last_update_login
                                                      )

                                                VALUES(
                                                       tax_rec.tax_line_no                ,
                                                       ra_customer_trx_lines_s.nextval    ,
                                                       v_customer_trx_line_id             ,
                                                       tax_rec.precedence_1               ,
                                                       tax_rec.precedence_2               ,
                                                       tax_rec.precedence_3               ,
                                                       tax_rec.precedence_4               ,
                                                       tax_rec.precedence_5               ,
                                                       tax_rec.precedence_6               ,
                                                       tax_rec.precedence_7               ,
                                                       tax_rec.precedence_8               ,
                                                       tax_rec.precedence_9               ,
                                                       tax_rec.precedence_10               ,
                                                       tax_rec.tax_id                     ,
                                                       tax_rec.tax_rate                   ,
                                                       tax_rec.qty_rate                   ,
                                                       tax_rec.uom                        ,
                                                       round(v_tax_amt,2)                 ,
                                                       round(v_func_tax_amount,2)         ,
                                                       round(v_base_tax_amount,2)         ,
                                                       v_creation_date                    ,
                                                       v_created_by                       ,
                                                       v_last_update_date                 ,
                                                       v_last_updated_by                  ,
                                                       v_last_update_login
                                                       );

             END IF;
           END IF;  /*  END IF OF IF v_register_code ='BOND_REG'  */
         END IF; /* END IF OF IF NVL(v_tax_line_count,0) <> 1 */
       END LOOP;
       OPEN  c_so_picking_lines_info_ns;
       FETCH c_so_picking_lines_info_ns INTO v_tax_category_id               ,
                                        v_qty                           ,
                                        v_tax_amount                    ,
                                        v_assessable_value              ,
                                        v_basic_excise_duty_amount      ,
                                        v_add_excise_duty_amount        ,
                                        v_oth_excise_duty_amount        ,
                                        v_payment_register              ,
                                        v_excise_invoice_no             ,
                                        v_preprinted_excise_inv_no      ,
                                        v_excise_invoice_date           ,
                                        v_excise_exempt_type            ,
                                        v_excise_exempt_refno           ,
                                        v_excise_exempt_date            ,
                                        v_ar3_form_no                   ,
                                        v_ar3_form_date                 ,
                                        lv_vat_exemption_flag           ,
                                        lv_vat_exemption_type           ,
                                        lv_vat_exemption_date           ,
                                        lv_vat_exemption_refno          ,
                                        ln_vat_assessable_value         ,
                                        ln_vat_invoice_no               ,
                                        ln_vat_invoice_date             ;
       CLOSE c_so_picking_lines_info_ns;

       IF v_register_code = 'BOND_REG' THEN
         v_tax_amount := v_bond_tax_amt / v_qty;
       END IF;
       -- To pick assessable_value from JAI_OM_OE_SO_LINES instead of JAI_OM_WSH_LINES_ALL
         OPEN   C_JA_SO_LINES_ASSESSABLE_VAL;
         FETCH  C_JA_SO_LINES_ASSESSABLE_VAL into v_assessable_value,v_service_type;
         CLOSE  C_JA_SO_LINES_ASSESSABLE_VAL;
       END IF; -- NVL(v_exist_flag,0) = 1
     ELSE -- ELSE OF IF v_interface_line_attribute3 IS NULL ... ...
       -- else, the record is not non-shippable item
       -- original logic of getting taxes from JAI_OM_OE_SO_TAXES
       /*
       If records do not exist in JAI_OM_WSH_LINE_TAXES table then control comes to this portion of the code
       */

       OPEN  ja_so_lines_tax_record_check ;
       FETCH ja_so_lines_tax_record_check INTO v_exist_flag;
       CLOSE ja_so_lines_tax_record_check;
       /*
       Check if a tax line exists in ja_in_so_tax_lines_table
       IF yes then insert all the taxes into JAI_AR_TRX_TAX_LINES table.
       */
       IF NVL(v_exist_flag,0) = 1 THEN
         FOR tax_rec IN ja_so_tax_lines_info LOOP
		     /* Added by JMEENA for bug# 6391684( FP of 6386592), Starts */
            ln_tax_exist := 0 ;
            OPEN  c_duplicate_tax(tax_rec.tax_id, v_customer_trx_line_id)  ;
            FETCH c_duplicate_tax INTO ln_tax_exist ;
            CLOSE c_duplicate_tax ;

            IF nvl(ln_tax_exist, 0) <> 1 THEN
              /* Added by JMEENA for bug# 6391684 ( FP of 6386592), Ends */
              -- Date 23/02/2006 by sacsethi for bug 5228046
              -- precedence 6 to 10
              INSERT INTO JAI_AR_TRX_TAX_LINES(
               tax_line_no                 ,
               customer_trx_line_id        ,
               link_to_cust_trx_line_id    ,
               precedence_1                ,
               precedence_2                ,
               precedence_3                ,
               precedence_4                ,
               precedence_5                ,
               precedence_6                ,
               precedence_7                ,
               precedence_8                ,
               precedence_9                ,
               precedence_10                ,
               tax_id                      ,
               tax_rate                    ,
               qty_rate                    ,
               uom                         ,
               tax_amount                  ,
               func_tax_amount             ,
               base_tax_amount             ,
               creation_date               ,
               created_by                  ,
               last_update_date            ,
               last_updated_by             ,
               last_update_login
              )
          VALUES(
               tax_rec.tax_line_no               ,
               ra_customer_trx_lines_s.nextval   ,
               v_customer_trx_line_id            ,
               tax_rec.precedence_1              ,
               tax_rec.precedence_2              ,
               tax_rec.precedence_3              ,
               tax_rec.precedence_4              ,
               tax_rec.precedence_5              ,
               tax_rec.precedence_6              ,
               tax_rec.precedence_7              ,
               tax_rec.precedence_8              ,
               tax_rec.precedence_9              ,
               tax_rec.precedence_10              ,
         tax_rec.tax_id                    ,
               tax_rec.tax_rate                  ,
               tax_rec.qty_rate                  ,
               tax_rec.uom                       ,
               round(tax_rec.tax_amount,2)       ,
               round(tax_rec.func_tax_amount,2)  ,
               round(tax_rec.base_tax_amount,2)  ,
               v_creation_date                   ,
               v_created_by                      ,
               v_last_update_date                ,
               v_last_updated_by                 ,
               v_last_update_login
               );
			     END IF ; -- Added for bug#6391684 ( FP of 6386592)
         END LOOP;
         OPEN  ja_so_lines_info;
         FETCH ja_so_lines_info INTO    v_tax_category_id       ,
                                        v_tax_amount            ,
                                        v_assessable_value      ,
                                        v_excise_exempt_type    ,
                                        v_excise_exempt_refno   ,
                                        v_excise_exempt_date    ,
                                        lv_vat_exemption_flag   , -- added, Harshita for bug#4245062
                                        lv_vat_exemption_type   ,
                                        lv_vat_exemption_date   ,
                                        lv_vat_exemption_refno  ,
                                        ln_vat_assessable_value,
					v_service_type ; --Added v_service_type by JMEENA for bug#8466638
         CLOSE ja_so_lines_info;
         ELSE /* ELSE FOR IF NVL(v_exist_flag,0) = 1  */
             /*
            Update done by aiyer for the bug #3328871
            If taxes do not exist in JAI_OM_WSH_LINE_TAXES and JAI_OM_OE_SO_TAXES then control
            would come here.
            Code should return only in case of an RMA i.e return only when a line does not exist in JAI_OM_OE_SO_LINES table
            for the given line_id.
             */
           DECLARE
             CURSOR c_so_lines_exists
             IS
             SELECT    1
             FROM      JAI_OM_OE_SO_LINES
             WHERE     line_id = pr_new.interface_line_attribute6;
             lv_exists VARCHAR2(1);
           BEGIN
    pv_return_code := jai_constants.successful ;
             OPEN   c_so_lines_exists ;
             FETCH  c_so_lines_exists INTO lv_exists;
             IF c_so_lines_exists%NOTFOUND THEN
                CLOSE  c_so_lines_exists;
                 fnd_file.put_line(FND_FILE.LOG,
     'no lines in jai_om_oe_so_lines -return');
               return;
             END IF;
             CLOSE  c_so_lines_exists;
           END ;
       END IF; /* END IF FOR IF NVL(v_exist_flag,0) = 1  */


       END IF; -- -- v_interface_line_attribute3 IS NULL ... ...
       -- added by Allen Yang 02-Apr-2010 for bug 9485355 (12.1.3 non-shippable enhancement), end



     END IF;
     OPEN  duplicate_lines_cur;
     FETCH duplicate_lines_cur INTO v_line_count;
     CLOSE duplicate_lines_cur;

     fnd_file.put_line(FND_FILE.LOG, ' Line cnt: '|| v_line_count);

     IF NVL(v_line_count,0) <> 1 THEN
              -- the following If Condition  added by Sriram - 27/06/2002 - Bug # 2398198
              -- Here trying to conditionally update Ja_in_ra_customer_trx_table
              -- For the second line of the same order line in AR , the tax amount should not be
              -- inserted.Hence Setting setting tax amount variable  v_calc_tax_amount to 0.
         IF (NVL(pr_new.Interface_line_attribute11,'0') ='0'
             and nvl(v_ont_source_code,'ORDER ENTRY') = ltrim(rtrim(pr_new.interface_line_context)) -- added by sriram - bug# 3607101
            )/* following OR added by sriram - bug#3607101 */
         or
         (nvl(v_ont_source_code,'ORDER ENTRY') <> nvl(ltrim(rtrim(pr_new.interface_line_context)),'$$$')  -- added by sriram - bug# 3607101
         )
         then

           fnd_file.put_line(FND_FILE.LOG, ' int. line att1 = 0 ');
           v_calc_tax_amount := v_tax_amount * v_qty;
           OPEN  c_cust_trx_tax_line_amt;
           FETCH c_cust_trx_tax_line_amt into v_calc_tax_amount;
           CLOSE c_cust_trx_tax_line_amt;
         ELSE
           v_calc_tax_amount := 0;
         END IF;

	 --Added below code for bug#8466638 by JMEENA
		open   JA_SO_LINES_INFO;
		fetch  JA_SO_LINES_INFO into rec_so_lines; --jkmeena
		close  JA_SO_LINES_INFO;
	--End bug#8466638

         INSERT INTO JAI_AR_TRX_LINES (
                                                   customer_trx_line_id                         ,
                                                   line_number                                  ,
                                                   customer_trx_id                              ,
                                                   description                                  ,
                                                   payment_register                             ,
                                                   excise_invoice_no                            ,
                                                   preprinted_excise_inv_no                     ,
                                                   excise_invoice_date                          ,
                                                   inventory_item_id                            ,
                                                   unit_code                                    ,
                                                   quantity                                     ,
                                                   tax_category_id                              ,
                                                   auto_invoice_flag                            ,
                                                   unit_selling_price                           ,
                                                   line_amount                                  ,
                                                   tax_amount                                   ,
                                                   total_amount                                 ,
                                                   assessable_value                             ,
                                                   creation_date                                ,
                                                   created_by                                   ,
                                                   last_update_date                             ,
                                                   last_updated_by                              ,
                                                   last_update_login                            ,
                                                   excise_exempt_type                           ,
                                                   excise_exempt_refno                          ,
                                                   excise_exempt_date                           ,
                                                   ar3_form_no                                  ,
                                                   ar3_form_date                                ,
                                                   vat_exemption_flag                           , -- added, Harshita for bug#4245062
                                                   vat_exemption_type                           ,
                                                   vat_exemption_date                           ,
                                                   vat_exemption_refno                                    ,
                                                   vat_assessable_value,
						   service_type_code	--Added by JMEENA for bug#8466638
                                                  )
                                         VALUES  (
                                                   v_customer_trx_line_id                       ,
                                                   pr_new.line_number                             ,
                                                   v_header_id                                  ,
                                                   pr_new.description                             ,
                                                   v_payment_register                           ,
                                                   v_excise_invoice_no                          ,
                                                   v_preprinted_excise_inv_no                   ,
                                                   v_excise_invoice_date                        ,
                                                   pr_new.inventory_item_id                       ,
                                                   pr_new.uom_code                                ,
                                                   pr_new.quantity_invoiced                       ,
                                                   v_tax_category_id                            ,
                                                   'Y'                                          ,
                                                   pr_new.unit_selling_price                      ,
                                                   round(v_line_amount,2)                       ,
                                                   round(v_calc_tax_amount,2)                   ,
                                                   round((v_line_amount + v_calc_tax_amount),2) ,
                                                   v_assessable_value                           ,
                                                   v_creation_date                              ,
                                                   v_created_by                                 ,
                                                   v_last_update_date                           ,
                                                   v_last_updated_by                            ,
                                                   v_last_update_login                          ,
                                                   v_excise_exempt_type                         ,
                                                   v_excise_exempt_refno                        ,
                                                   v_excise_exempt_date                         ,
                                                   v_ar3_form_no                                ,
                                                   v_ar3_form_date                              ,
                                                   lv_vat_exemption_flag                        ,  -- added, Harshita for bug#4245062
                                                   lv_vat_exemption_type                        ,
                                                   lv_vat_exemption_date                        ,
                                                   lv_vat_exemption_refno                       ,
                                                   ln_vat_assessable_value,
						   rec_so_lines.service_type_code --Added by JMEENA for bug#8466638
                                                 );
  ELSE  /* ELSE OF IF NVL(v_line_count,0) <> 1*/
    OPEN  old_customer_trx_id_cur;
    FETCH old_customer_trx_id_cur INTO v_old_customer_trx_id;
    CLOSE old_customer_trx_id_cur;

    -- Vijay Shankar for Bug# 3985561
    -- commented the following delete statement as this is not required in this trigger.
    -- This statement is executed in Concurrent process to default taxes from OM to AR
    --DELETE  JAI_AR_TRX_INS_LINES_T
    --WHERE   customer_trx_line_id = v_customer_trx_line_id;

    IF v_old_customer_trx_id <> v_header_id THEN
      UPDATE  JAI_AR_TRX_LINES
      SET     customer_trx_id = v_header_id
      WHERE   customer_trx_line_id = v_customer_trx_line_id;
      DELETE   JAI_AR_TRXS
      WHERE    customer_trx_id = v_old_customer_trx_id;
    END IF;
  END IF; /* END IF OF IF NVL(v_line_count,0) <> 1 */

  v_excise_amount := round(nvl(v_basic_excise_duty_amount,0) + nvl(v_add_excise_duty_amount,0) + nvl(v_oth_excise_duty_amount,0));

  fnd_file.put_line(FND_FILE.LOG, ' Excise amount: '|| v_excise_amount);

  OPEN  complete_flag_cur;
  FETCH complete_flag_cur INTO v_once_completed_flag;
  CLOSE complete_flag_cur;

  fnd_file.put_line(FND_FILE.LOG, ' Once complete flag'|| v_once_completed_flag);

  v_so_tax_amount := v_tax_amount * v_qty ;

  /*Bug # 2316589*/
  -- Instead the following update has been modified . It used a new variable
  -- called v_so_tax_amount to calculate the tax amount.
  -- the following If Condition  added by Sriram - 27/06/2002 - Bug # 2398198
  -- Here trying to conditionally update Ja_in_ra_customer_trx_table
  -- For the second line of the same order line in AR , the tax amount should not be
  -- updated.

  -- bug # 3000550 sriram
  OPEN  c_cust_trx_tax_line_amt;
  FETCH c_cust_trx_tax_line_amt into v_so_tax_amount;
  CLOSE c_cust_trx_tax_line_amt;

  fnd_file.put_line(FND_FILE.LOG, ' so tax amount: '|| v_so_tax_amount);

  -- bug # 3000550 sriram
  IF (NVL(pr_new.Interface_line_attribute11,'0') ='0'
      and nvl(v_ont_source_code,'ORDER ENTRY') = ltrim(rtrim(pr_new.interface_line_context)) -- added by sriram - bug# 3607101
     )/* following OR added by sriram - bug#3607101 */
  or
     (nvl(v_ont_source_code,'ORDER ENTRY') <> nvl(ltrim(rtrim(pr_new.interface_line_context)),'$$$')  -- added by sriram - bug# 3607101
     )
  then
    -- Above if condition added by sriram Bug # 2742849
    -- instead of the previous if condition because , it may fail in circumstances
    -- where line ordering rules are set up in autoinvoice options.

    UPDATE  JAI_AR_TRXS
    SET     line_amount  =  round(NVL(line_amount,0) + NVL(v_line_amount,0),2),
               tax_amount   =  round(NVL(tax_amount,0) + NVL(v_so_tax_amount,0),2),
               total_amount =  round(NVL(total_amount,0) + NVL(v_line_amount,0) + NVL(v_so_tax_amount,0),2),
               once_completed_flag = NVL(v_once_completed_flag,'N'),
                vat_invoice_no = ln_vat_invoice_no, vat_invoice_date = ln_vat_invoice_date -- added, Harshita for bug#4245062
    WHERE   customer_trx_id = v_header_id;
  ELSE
    UPDATE  JAI_AR_TRXS
    SET     line_amount  =  round(NVL(line_amount, 0 ) + NVL(v_line_amount,0),2),
            total_amount =  round(NVL(total_amount,0) + NVL(v_line_amount,0),2),
            once_completed_flag = NVL(v_once_completed_flag,'N'),
            vat_invoice_no = ln_vat_invoice_no, vat_invoice_date = ln_vat_invoice_date -- added, Harshita for bug#4245062
    WHERE   customer_trx_id = v_header_id;
  END IF;

END IF;
EXCEPTION
  WHEN OTHERS THEN
    vsqlerrm := SQLERRM;

     /* Added an exception block by Ramananda for bug#4570303 */
     Pv_return_code     :=  jai_constants.unexpected_error;
     Pv_return_message  := 'Encountered an error in JAI_AR_RCTLA_TRIGGER_PKG.ARI_T2  '  || substr(sqlerrm,1,1900);

     lv_appl_src := 'JA_IN_OE_AR_LINES_INSERT_TRG' ;
     lv_err_msg  := 'EXCEPTION Occured' ;

    INSERT INTO JAI_CMN_ERRORS_T
    (
       APPLICATION_SOURCE                  ,
       error_message                   ,
       additional_error_mesg           ,
       creation_date                   ,
       created_by                      ,
       -- added, Harshita for Bug 4866533
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE
    )
    VALUES
    (
       lv_appl_src,          /*'JA_IN_OE_AR_LINES_INSERT_TRG' ,*/
       lv_err_msg ,          /* 'EXCEPTION Occured '           ,*/
       substr(vsqlerrm,1,200)         ,
       sysdate                        ,
       user     ,
        -- added, Harshita for Bug 4866533
        fnd_global.user_id,
        sysdate
     );

  END ARI_T2 ;

  /*REM +======================================================================+
  REM NAME          ARI_T3
  REM
  REM DESCRIPTION   Called from trigger JAI_AR_RCTLA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_AR_RCTLA_ARI_T8
  REM Change History :-
  REM    Slno   Date          Bug       File Version   Comments
  REM    1.     14-Jul-2006   5378650   120.7          Uncommented the assigned of values
  REM                                                  from record group to local variables
  REM +======================================================================+
  */
PROCEDURE ARI_T3 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
   v_created_from        VARCHAR2(30);
  /* --Ramananda for File.Sql.35, start */
  /*
  ||Modified by aiyer for the bug 5378650
  */
  v_last_update_date    DATE                  := pr_new.last_update_date;
  v_last_updated_by     NUMBER                := pr_new.last_updated_by;
  v_creation_date       DATE                  := pr_new.creation_date;
  v_created_by          NUMBER                := pr_new.created_by;
  v_last_update_login   NUMBER                := pr_new.last_update_login;
  v_customer_trx_line_id    NUMBER            := pr_new.customer_trx_line_id;
  v_header_id           NUMBER                := pr_new.customer_trx_id;
  v_line_amount         NUMBER                := NVL(pr_new.quantity_credited * pr_new.unit_selling_price, nvl(pr_new.extended_amount,0));  --added  nvl(pr_new.extended_amount,0) for bug 8849775
  v_interface_line_attribute7   VARCHAR2(30)  :=  pr_new.interface_line_attribute6;
  v_quantity_credited   NUMBER                := pr_new.quantity_credited;
  /* --Ramananda for File.Sql.35, end */

  x                     NUMBER := 0;
    v_organization_id     NUMBER;
  v_location_id         NUMBER;
  v_once_completed_flag VARCHAR2(1);
  v_excise_amount       NUMBER := 0;
  v_trx_number          VARCHAR2(30);
  v_tax_category_id     NUMBER;
  v_payment_register    VARCHAR2(15);
  v_excise_invoice_no   NUMBER;
  v_excise_invoice_date DATE;
  v_tax_amount          NUMBER := 0;
  v_assessable_value    NUMBER := 0;
  v_basic_excise_duty_amount    NUMBER := 0;
  v_add_excise_duty_amount  NUMBER := 0;
  v_oth_excise_duty_amount  NUMBER := 0;
  v_exist_flag          NUMBER := 0;
  v_quantity            NUMBER := 0;
  v_func_tax_amount     NUMBER := 0;
  v_batch_source_id     NUMBER ;
  v_books_id            NUMBER;
  v_salesrep_id         NUMBER;
  c_from_currency_code  VARCHAR2(15);
  c_conversion_type     VARCHAR2(30);
  c_conversion_date     DATE;
  c_conversion_rate     NUMBER;
  v_old_customer_trx_id NUMBER;
  v_line_count          NUMBER := 0;  -- added on 14-jun-01 by subbu
  ln_legal_entity_id    NUMBER ; /* rallamse bug#4448789 */
  v_service_type        VARCHAR2(30);  -- added by csahoo for bug#5879769

  -- cusrsor added to check duplication in JAI_AR_TRX_LINES for avoiding
  -- unique constraint violation

    CURSOR DUPLICATE_LINES_CUR IS
    SELECT 1
    FROM   JAI_AR_TRX_LINES
    WHERE  customer_trx_LINE_id = v_customer_trx_line_id;

    CURSOR OLD_CUSTOMER_TRX_ID_CUR IS
    SELECT Customer_Trx_Id
    FROM   JAI_AR_TRX_LINES
    WHERE  customer_trx_LINE_id = v_customer_trx_line_id;

  CURSOR CREATED_FROM_CUR IS
  SELECT created_from, trx_number, batch_source_id, set_of_books_id, primary_salesrep_id,
  invoice_currency_code, exchange_rate_type, exchange_date, exchange_rate,
  legal_entity_id /* rallamse bug#4448789 */
  FROM   ra_customer_trx_all
  WHERE  customer_trx_id = v_header_id;


  -- following cursor definition modified by sriram - bug # 2755890 - 18/01/2003
  CURSOR SO_RMA_HDR_INFO IS
  SELECT organization_id, location_id
  FROM   JAI_OM_WSH_LINES_ALL
  WHERE  order_line_id IN
  (SELECT reference_line_id
   FROM oe_order_lines_all
   WHERE line_id = v_interface_line_attribute7 -- Removed to_char from to_char(line_id) for bug#5641896 by JMEENA
  );

  -- following cursor added by sriram -- bug # 2755890 to pick up the
  -- organization and location id based on the subinventory name

  Cursor c_get_location is
   SELECT organization_id , location_id  FROM JAI_INV_SUBINV_DTLS
    WHERE organization_id = pr_new.interface_line_attribute10
    AND UPPER(sub_inventory_name) IN
    (SELECT UPPER(subinventory)
     FROM rcv_transactions
     WHERE
     organization_id = pr_new.interface_line_attribute10
     AND (oe_order_line_id) = v_interface_line_attribute7
     AND subinventory IS NOT NULL
    );

  -- ends here -- additions by sriram -- bug # 2755890


  /*
  ||Start of bug 4567935
  ||Added by Ramananda for the bug 4567935 (115 bug4404898)
  */
  CURSOR SO_RMA_LINES_INFO IS
  SELECT tax_category_id, assessable_value, service_type_code -- service_type_code added by csahoo for bug#5879769
  FROM   JAI_OM_OE_RMA_LINES
  WHERE  rma_line_id = v_interface_line_attribute7;
  /*
  ||End of bug 4567935
  */
-- Date 23/02/2006 by sacsethi for bug 5228046
-- precedence 6 to 10
  CURSOR SO_RMA_TAX_LINES_INFO IS
  SELECT A.tax_line_no, A.uom, A.tax_id, A.tax_rate, A.qty_rate, A.base_tax_amount, A.tax_amount, b.tax_type,
         A.func_tax_amount,
   A.precedence_1, A.precedence_2, A.precedence_3, A.precedence_4, A.precedence_5 ,
   A.precedence_6, A.precedence_7, A.precedence_8, A.precedence_9, A.precedence_10
  FROM   JAI_OM_OE_RMA_TAXES A, JAI_CMN_TAXES_ALL b
  WHERE  A.rma_line_id = v_interface_line_attribute7
  AND    A.tax_id = b.tax_id
and    b.tax_type <> lc_modvat_tax/*Bug 4881426 bduvarag*/
  ORDER BY tax_line_no;


  CURSOR DUPLICATE_HDR_CUR IS
  SELECT 1
  FROM   JAI_AR_TRXS
  WHERE  customer_trx_id = v_header_id;


  /* Cursor To Check Whether Interfaced Record Exist in JAI_OM_WSH_LINES_ALL */
  CURSOR SO_RMA_RECORD_CHECK IS
  SELECT 1
  FROM   JAI_OM_OE_RMA_LINES
  WHERE  rma_line_id = v_interface_line_attribute7;


  CURSOR SO_RMA_TAX_RECORD_CHECK IS
  SELECT 1
  FROM   JAI_OM_OE_RMA_TAXES
  WHERE  rma_line_id = v_interface_line_attribute7;


  v_trans_type      VARCHAR2(30);
  CURSOR transaction_type_cur IS
  SELECT A.TYPE
  FROM   RA_CUST_TRX_TYPES_ALL A, RA_CUSTOMER_TRX_ALL b
  WHERE  A.cust_trx_type_id = b.cust_trx_type_id
  AND    b.customer_trx_id = v_header_id
  AND    NVL(A.org_id,0) = NVL(pr_new.org_id,0);


  CURSOR SO_RMA_QUANTITY_CHECK IS
  SELECT NVL(quantity,0)
  FROM   JAI_OM_OE_RMA_LINES
  WHERE  rma_line_id = v_interface_line_attribute7;

  /* bug 5243532. Added by Lakshmi Gopalsami
     Removed the reference to cursor set_of_books_cur
     as the SOB will never be null in base table.
  */

  /*
  start additions by sriram - bug#3680721
  */
  cursor c_ont_source_code is
  select FND_PROFILE.VALUE('ONT_SOURCE_CODE')
  from   dual;
  v_ont_source_code ra_interface_lines_all.interface_line_context%type;
  /*
  ends here additions by sriram -bug#3680721
  */

  /*
  ||Code added by Ramananda for the bug 4567935 (115 bug4404898)
  ||Get the batch_source_id for the invoice corresponding to the credit memo.
  */
  CURSOR cur_get_transaction_type_id
  IS
  SELECT
        ott.transaction_type_id
  FROM
        ra_customer_trx_all     rct,
        oe_transaction_types_tl ott
  WHERE
        rct.customer_trx_id                    = pr_new.previous_customer_trx_id
  /* bug 4926865. Added by Lakshmi Gopalsami
     Removed the upper as the data getting inserted into
     interface_header_attribute2 will be same as name in
     oe_transaction_types_tl
  */
  AND   rct.interface_header_attribute2 = ott.name       ;

  /*added by csahoo for bug#6407648, start*/
  CURSOR cur_get_cmline_tax_amt
  IS
  SELECT
        nvl(sum(tax_amount),0)
  FROM
        JAI_AR_TRX_TAX_LINES
  WHERE
    link_to_cust_trx_line_id = pr_new.customer_trx_line_id ;
  /*added by csahoo for bug#6407648, end*/

  ln_transaction_type_id        OE_TRANSACTION_TYPES_TL.TRANSACTION_TYPE_ID%TYPE;
  ln_register_id                JAI_OM_OE_BOND_REG_HDRS.REGISTER_ID%TYPE;
  lv_register_code              JAI_OM_OE_BOND_REG_HDRS.REGISTER_CODE%TYPE;
  /*
  || End of bug4567935 (115 bug4404898)
  */
  --Added by Bo Li for ER VAT non-shippable RMA 2010-4-27 Begin
  ----------------------------------------------------------------
  CURSOR check_reference_existed
  IS
  SELECT 1
  FROM   OE_ORDER_LINES_ALL
  WHERE  LINE_ID = v_interface_line_attribute7
  AND    reference_line_id = v_interface_line_attribute7;


  CURSOR get_non_ship_loc
  IS
  SELECT ORGANIZATION_ID,LOCATION_ID
  FROM  HR_ORGANIZATION_UNITS
  WHERE ORGANIZATION_ID = pr_new.interface_line_attribute10;

  ln_ref_existed_flag NUMBER;
  ln_location_id   NUMBER;
  -----------------------------------------------------------------
  --Added by Bo Li for ER VAT non-shippable RMA 2010-4-27 Begin
  BEGIN
    pv_return_code := jai_constants.successful ;
    /*------------------------------------------------------------------------------------------
  FILENAME: JA_IN_RMA_AR_LINES_INSERT_TRG.sql

  CHANGE HISTORY:

 S.No      Date          Author and Details
================================================================================================
 1.   2001/06/14        Subbu Code added to avoid unique constraint violation.

 2.   2002/06/07        Ashish Shukla 2398850 INR check included in the code.(changes as per GSR)

 3.   2002/09/11        Sriram Bug # 2461542. Added an if condition to check the duplicate taxes.
                        This  was happening was because when a RMA was done against a sales order
                        that had discounts,the taxes were flowing as many times extra as the number
                        of discounts. If a line has 2 discounts , then the taxes were getting tripled.

4     2002/11/22        Bug # 2668342 - replaced  cursor using org_organization_definitions
                        with nvl(operating_unit,0) causing performance problem
                        and used the hr_operating_units table instead.

5 .   2003/01/09        Sriram - Bug # 2742849 - Version is 615.2
                        This problem is about tax lines being inserted for discount line also. The earlier fix assumed
                        that the discount line follows the item line by line number, that is they are consecutive
                        lines. But this assumption is not correct and  it depends on setup.
                        Found out from base apps team that interface_line_attribute11 can be used to identify a
                        discount line from the item line.  For a Invoice line imported from OM , the
                        interface_line_attribute11 will have a value 0 or Null , whereas for a discount  line , the
                        interface_line_attribute11 will have a value which maps to the price_adjustment_id.

6.    2003/01/18        Sriram - Bug # 2755890 - File Version 615.3
                        When a credit memo created in AR because of a RMA Transaction is queried
                        in the localization AR screen , it was causing no reords to be retreived.
                        It is because , organization id and location id are not getting populated
                        in the JAI_AR_TRXS table. This was because a cursor fetch was done incorrectly. The
                        cursor definition has been corrected .

                        For RMA without reference , organization and location has to be fetched based on the subinventory
                        chosen in the receiving transaction in Purchasing responsibility. Hence a new cursor is written
                        to fetch the organization id , location id based on the subinventory name from the JAI_INV_SUBINV_DTLS
                        table based on the subinventory name in the rcv transactions table.

7.   2003/04/18         Sriram - Bug # 2905912 - File Version 615.4
                        For a RMA Transaction , the tax amount and total amount columns in the JAI_AR_TRXS
                        table were incorrect. This has been corrected in this fix.

8.   2004/06/09         ssumaith - bug# 3680721 File Version 115.1

                        When autoinvoice import program imports a crdit memo from custom software and if interface_line_attribute11
                        field in the ra_customer_trx_lines_all table is not null then , localization taxes are not retreived
                        into the AR invoice.

                        This issue has been resolved by adding a context based check that interface_line_attribute11 field cannot be
                        null for Order Entry as the source of the invoice for taxes to be imported , and other wise if the context is not
                        Order Entry then the localisation taxes will be populated into the credit memo based on rma order.

9.   29/Nov/2004        Aiyer for bug#4035566. Version#115.1
                        Issue:-
                        The trigger should not get fired when the  non-INR based set of books is attached to the current operating unit
                        where transaction is being done.

                        Fix:-
                        Function jai_cmn_utils_pkg.check_jai_exists is being called which returns the TRUE if the currency is INR and FALSE if the currency is
                        NON-INR
                        Also removed the cursors Fetch_Book_Id_Cur and Sob_cur and the variables v_gl_set_of_bks_id and v_currency_code and v_operating_id

                        Dependency Due to this Bug:-
                        The current trigger becomes dependent on the function jai_cmn_utils_pkg.check_jai_exists version 115.0. introduced through the bug 4033992

10.   08-Jun-2005       This Object is Modified to refer to New DB Entity names in place of Old
                        DB Entity as required for CASE COMPLAINCE.  Version 116.1

11.   10-Jun-2005     File Version: 116.2
                      Removal of SQL LITERALs is done

12.   10-Jun-2005   rallamse bug#4448789  116.3
                    Added legal_entity_id for table JAI_AR_TRXS in insert statement

13.  26-07-2005    rallamse bug#4510143 120.2
                   The legal_entity_id is derived from CREATED_FROM_CUR cursor based on ra_customer_trx_all.

14. 24-Aug-2005   Ramananda for bug #4567935 (115 bug 4404898, 4395450).  File version 120.2
                  Issue:-
                   1. The following type of taxes should not be inserted into JAI_AR_TRX_LINES when Order type is BOND register:-
                       'EXCISE', 'OTHER EXCISE', 'CVD_EDUCATION_CESS', 'EXCISE_EDUCATION_CESS'

                   2. Trigger currently processing Credit memo invoices with interface line context as LEGACY.This needs to be stopped

                  Fix:-
                   1. Before a insert in the table JAI_AR_TRX_LINES, added a IF statement to bypass the insert into JAI_AR_TRX_LINES if
                      the register code is 'BOND_REG' and any of the above stated taxes are present.
                   2. Added the check to RETURN from the trigger if interface line context = 'LEGACY'

                  Dependency due to this bug :-
                   Functional dependency with jai_ar_rctla_ari_t7 trigger of jai_fin_t.sql  (120.2)

15.  20-Sep-2007  CSahoo for bug#6407648, file version 120.20
                  Added the Cursor cur_get_cmline_tax_amt to get the line tax amount.

16. 29-Apr-2010 Bo Li for bug9666476
                Procedure ARI_T3 to handle the non-shippable RMA flow
                Insert the organization_id and location_id into the JAI_AR_TRXS so that
                the AR transaction can be viewed in the AR transcation India location

 Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Current Version    Current Bug    Dependent           Files                Version   Author   Date          Remarks
Of File                           On Bug/Patchset    Dependent On
ja_in_rma_ar_lines_insert_trg
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
115.1              4035566        IN60105D2 +        ja_in_util_pkg_s.sql  115.0     Aiyer    29-Nov-2004  Call to this function.
                                  4033992            ja_in_util_pkg_b.sql  115.0

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

  /*
  || Code added by aiyer for the bug 4035566
  || Call the function jai_cmn_utils_pkg.check_jai_exists to check the current set of books in INR/NON-INR based.
  */
  --IF jai_cmn_utils_pkg.check_jai_exists ( p_calling_object      => 'JA_IN_RMA_AR_LINES_INSERT_TRG' ,
  --                                 p_set_of_books_id     => pr_new.set_of_books_id
 --                                )  = FALSE
 -- THEN
    /*
    || return as the current set of books is NON-INR based
    */
   -- RETURN;
  --END IF;

  /*
  || Start of bug #4567935 (115 bug4404898, 4395450,4404898)
  || Code added by Ramananda
  */
  IF pr_new.interface_line_context IN ('PROJECTS INVOICES','OKS CONTRACTS','LEGACY') THEN
    RETURN;
  END IF;


-------------------------------------------------------------------------------------------------------
  OPEN  transaction_type_cur;
  FETCH transaction_type_cur INTO v_trans_type;
  CLOSE transaction_type_cur;

  IF NVL(v_trans_type,'N') <> 'CM' THEN
    RETURN;
  END IF;

  OPEN   CREATED_FROM_CUR;
  FETCH  CREATED_FROM_CUR INTO v_created_from, v_trx_number, v_batch_source_id, v_books_id,
                               v_salesrep_id, c_from_currency_code, c_conversion_type,
                               c_conversion_date, c_conversion_rate, ln_legal_entity_id ; /* rallamse bug#4448789 */
  CLOSE  CREATED_FROM_CUR;

  IF v_created_from <> 'RAXTRX' THEN
     RETURN;
  END IF;

  OPEN   DUPLICATE_HDR_CUR;
  FETCH  DUPLICATE_HDR_CUR INTO x;
  CLOSE  DUPLICATE_HDR_CUR;

  OPEN  SO_RMA_RECORD_CHECK;
  FETCH SO_RMA_RECORD_CHECK INTO v_exist_flag;
  CLOSE SO_RMA_RECORD_CHECK;

  fnd_file.put_line(FND_FILE.LOG, ' RMA record chk:'|| v_exist_flag);

  IF NVL(v_exist_flag,0) <> 1 THEN
    RETURN;
  END IF;

  IF NVL(x,0) <> 1 THEN
    --Added by Bo Li for VAT non-shippable ER RMA Bug9666476 on 2010-4-27 Begin
    ---------------------------------------------------------------------------
     OPEN  check_reference_existed;
     FETCH check_reference_existed
     INTO  ln_ref_existed_flag;
     CLOSE check_reference_existed;

   IF NVL(ln_ref_existed_flag,0) = 1 THEN
   ---------------------------------------------------------------------------
   --Added by Bo Li for VAT non-shippable ER RMA Bug9666476 2010-4-27  End

    OPEN  SO_RMA_HDR_INFO;
    FETCH SO_RMA_HDR_INFO INTO v_organization_id, v_location_id;
    CLOSE SO_RMA_HDR_INFO;

    -- added by sriram -- bug # 2755890
    if v_location_id is null then
     Begin
       Open  c_get_location;
       Fetch c_get_location into  v_organization_id, v_location_id;
       Close c_get_location;
     Exception
       -- adding the exception section so that this should not cause control flow
       -- to halt.If it hits the exception , the maximum effect is that organization
       -- and location id will not get fetched .. that will happen only for
       -- rma without refernec .. but for rma with reference it will go thru fine.
       When others then
         Null;
     End;
    end if;
  ELSE --Added by Bo Li for VAT non-shippable ER RMA Bug9666476 on 2010-4-27 Begin
     --------------------------------------------------------------------------------
       OPEN  get_non_ship_loc;
       FETCH get_non_ship_loc
       INTO  v_organization_id, v_location_id;
       CLOSE get_non_ship_loc;

  END IF; --NVL(ln_non_ship_flag,0) <> 1
  ---------------------------------------------------------------------------------
  --Added by Bo Li for VAT non-shippable ER RMA Bug9666476 on 2010-4-27 End

    -- ends here additions by sriram - bug # 2755890
    /* Bug 5243532. Added by Lakshmi Gopalsami
     Removed the reference to cursor set_of_books_cur.
    */

     IF NVL(pr_new.Interface_line_attribute11,'0') = '0'
      and (nvl(v_ont_source_code,'ORDER ENTRY') = ltrim(rtrim(pr_new.interface_line_context)) -- added by sriram - bug#3680721
          ) /* following OR added by sriram - bug#3680721 */
      or
        (nvl(v_ont_source_code,'ORDER ENTRY') <> nvl(ltrim(rtrim(pr_new.interface_line_context)),'$$$')  -- added by sriram - bug#3680721
        )
      then
         INSERT INTO JAI_AR_TRXS
                     (
                      Customer_Trx_ID,
                      Organization_ID,
                      Location_ID,
                      Trx_Number,
                      Update_RG_Flag,
                      Once_Completed_Flag,
                      Batch_Source_ID,
                      Set_Of_Books_ID,
                      Primary_Salesrep_ID,
                      Invoice_Currency_Code,
                      Exchange_Rate_Type,
                      Exchange_Date,
                      Exchange_Rate,
                      Created_From,
                      creation_date,
                      created_by,
                      last_update_date,
                      last_updated_by,
                      last_update_login,
                      legal_entity_id         /* rallamse bug#4448789 */
                     )
                VALUES
                     (
                      v_header_id,
                      v_organization_id,
                      v_location_id,
                      v_trx_number,
                      'Y',
                      'Y',
                      v_batch_source_id,
                      v_books_id,
                      v_salesrep_id,
                      c_from_currency_code,
                      c_conversion_type,
                      c_conversion_date,
                      c_conversion_rate,
                      v_created_from,
                      v_creation_date,
                      v_created_by,
                      v_last_update_date,
                      v_last_updated_by,
                      v_last_update_login,
                      ln_legal_entity_id         /* rallamse bug#4448789 */
                    );
      END If;
  END IF;

  OPEN  SO_RMA_TAX_RECORD_CHECK;
  FETCH SO_RMA_TAX_RECORD_CHECK INTO v_exist_flag;
  CLOSE SO_RMA_TAX_RECORD_CHECK;


  IF NVL(v_exist_flag,0) <> 1 THEN
    RETURN;
  END IF;

  OPEN  SO_RMA_QUANTITY_CHECK;
  FETCH SO_RMA_QUANTITY_CHECK INTO v_quantity;
  CLOSE SO_RMA_QUANTITY_CHECK;

 /*
  || Added by Ramananda for bug#4567935 (115 bug 4404898)  , Start
  */
  OPEN  cur_get_transaction_type_id ;
  FETCH cur_get_transaction_type_id INTO ln_transaction_type_id;
  CLOSE cur_get_transaction_type_id ;

  jai_cmn_bond_register_pkg.get_register_id(
                                      v_organization_id      ,
                                      v_location_id          ,
                                      ln_transaction_type_id ,
                                      'Y'                    ,
                                      ln_register_id          ,
                                      lv_register_code
                                    );
  /*
  || Added by Ramananda for bug#4567935 (115 bug 4404898)  , End
  */

  FOR Tax_Rec IN SO_RMA_TAX_LINES_INFO LOOP
    v_func_tax_amount  := NVL((Tax_Rec.func_tax_amount * v_quantity_credited) / v_quantity,0);

           IF NVL(pr_new.Interface_line_attribute11,'0') ='0'
           and (nvl(v_ont_source_code,'ORDER ENTRY') = ltrim(rtrim(pr_new.interface_line_context)) -- added by sriram - --bug#3680721
               ) /* following OR added by sriram - bug#3680721 */
           or
                  (nvl(v_ont_source_code,'ORDER ENTRY') <> nvl(ltrim(rtrim(pr_new.interface_line_context)),'$$$')  -- added by sriram - bug#3680721
                  )
           then
-- Date 23/02/2006 by sacsethi for bug 5228046
-- precedence 6 to 10
       INSERT INTO JAI_AR_TRX_TAX_LINES
                         (
                          tax_line_no,
                          customer_trx_line_id,
                          link_to_cust_trx_line_id,
                          precedence_1,
                          precedence_2,
                          precedence_3,
                          precedence_4,
                          precedence_5,
                          precedence_6,
                          precedence_7,
                          precedence_8,
                          precedence_9,
                          precedence_10,
                          tax_id,
                          tax_rate,
                          qty_rate,
                          uom,
                          tax_amount,
                          func_tax_amount,
                          base_tax_amount,
                          creation_date,
                          created_by,
                          last_update_date,
                          last_updated_by,
                          last_update_login
                         )
                   VALUES(
                          Tax_Rec.tax_line_no,
                          ra_customer_trx_lines_s.NEXTVAL,
                          v_customer_trx_line_id,
                          Tax_Rec.precedence_1,
                          Tax_Rec.precedence_2,
                          Tax_Rec.precedence_3,
                          Tax_Rec.precedence_4,
                          Tax_Rec.precedence_5,
                          Tax_Rec.precedence_6,
                          Tax_Rec.precedence_7,
                          Tax_Rec.precedence_8,
                          Tax_Rec.precedence_9,
                          Tax_Rec.precedence_10,
                          Tax_Rec.tax_id,
                          Tax_Rec.tax_rate,
                          Tax_Rec.qty_rate,
                          Tax_Rec.uom,
                          NVL((Tax_Rec.tax_amount * v_quantity_credited) / v_quantity,0),
                          v_func_tax_amount,
                          NVL((Tax_Rec.base_tax_amount * v_quantity_credited) / v_quantity,0),
                          v_creation_date,
                          v_created_by,
                          v_last_update_date,
                          v_last_updated_by,
                          v_last_update_login
                         );
           end if;

      v_excise_amount := NVL(v_excise_amount,0) + NVL(v_func_tax_amount,0);
  END LOOP;


  OPEN  DUPLICATE_LINES_CUR;
  FETCH DUPLICATE_LINES_CUR INTO v_line_count;
  CLOSE DUPLICATE_LINES_CUR;


  IF NVL(v_line_count,0) <> 1 THEN
    OPEN  SO_RMA_LINES_INFO;
    /*
    || Code modified by Ramananda for the bug 4567935 (115 bug4404898)
    || FETCH SO_RMA_LINES_INFO INTO v_tax_category_id, v_tax_amount, v_assessable_value;
    */
    FETCH SO_RMA_LINES_INFO INTO v_tax_category_id, v_assessable_value,v_service_type;/*5879769*/
    CLOSE SO_RMA_LINES_INFO;

    /*added by csahoo for bug#6407648,start*/
    OPEN cur_get_cmline_tax_amt;
    FETCH cur_get_cmline_tax_amt INTO v_tax_amount;
    CLOSE cur_get_cmline_tax_amt ;
    /*added by csahoo for bug#6407648,end*/

    IF NVL(pr_new.Interface_line_attribute11,'0') ='0'
    and (nvl(v_ont_source_code,'ORDER ENTRY') = ltrim(rtrim(pr_new.interface_line_context)) -- added by sriram - --bug#3680721
           ) /* following OR added by sriram - bug#3680721 */
    or
           (nvl(v_ont_source_code,'ORDER ENTRY') <> nvl(ltrim(rtrim(pr_new.interface_line_context)),'$$$')  -- added by sriram - bug#3680721
           )
    then
        v_tax_amount := NVL((v_tax_amount *  abs(v_quantity_credited)) / v_quantity,0);  -- added abs(v_quantity_credited) for bug #6407648
    ELSE
        v_tax_amount :=0;
    END IF;


    INSERT INTO JAI_AR_TRX_LINES
                (customer_trx_line_id,
                 line_number,
                 customer_trx_id,
                 description,
                 inventory_item_id,
                 unit_code,
                 quantity,
                 tax_category_id,
                 auto_invoice_flag,
                 unit_selling_price,
                 line_amount,
                 tax_amount,
                 total_amount,
                 assessable_value,
                 creation_date,
                 created_by,
                 last_update_date,
                 last_updated_by,
                 last_update_login,
                 service_type_code                 -- added by csahoo for bug#5879769
                )
         VALUES(
                v_customer_trx_line_id,
                pr_new.line_number,
                v_header_id,
                pr_new.description,
                pr_new.inventory_item_id,
                pr_new.uom_code,
                pr_new.quantity_credited,
                v_tax_category_id,
                'Y',
                pr_new.unit_selling_price,
                v_line_amount,
                v_tax_amount,
                (v_line_amount + v_tax_amount),
                v_assessable_value,
                v_creation_date,
                v_created_by,
                v_last_update_date,
                v_last_updated_by,
                v_last_update_login,
                v_service_type                 -- added by csahoo for bug#5879769
               );
  ELSE
    OPEN  OLD_CUSTOMER_TRX_ID_CUR;
    FETCH OLD_CUSTOMER_TRX_ID_CUR INTO v_old_customer_trx_id;
    CLOSE OLD_CUSTOMER_TRX_ID_CUR;

    DELETE  JAI_AR_TRX_INS_LINES_T
    WHERE   Customer_Trx_Line_Id = v_customer_trx_line_id;

    IF v_old_customer_trx_id <> v_header_id THEN
       UPDATE  JAI_AR_TRX_LINES
       SET     Customer_Trx_Id = v_header_id
       WHERE   Customer_Trx_Line_Id = v_customer_trx_line_id;

       DELETE   JAI_AR_TRXS
       WHERE    customer_trx_id = v_old_customer_trx_id;
    END IF;
  END IF; -- end if for the modification by subbu on 14-jun-01

  UPDATE  JAI_AR_TRXS
  SET     line_amount  =  NVL(line_amount, 0 ) + NVL(v_line_amount,0),
          tax_amount     =  NVL(tax_amount,0) + NVL(v_excise_amount,0),
          total_amount =  NVL(total_amount,0) + NVL(v_line_amount,0) + NVL(v_excise_amount,0)
  WHERE   customer_trx_id = v_header_id;
  /* Added an exception block by Ramananda for bug#4570303 */
   EXCEPTION
     WHEN OTHERS THEN
       Pv_return_code     :=  jai_constants.unexpected_error;
       Pv_return_message  := 'Encountered an error in JAI_AR_RCTLA_TRIGGER_PKG.ARI_T3  '  || substr(sqlerrm,1,1900);
  END ARI_T3 ;

  /*
  REM +======================================================================+
  REM NAME          ARIU_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_AR_RCTLA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_AR_RCTLA_ARIU_T4
  REM
  REM +======================================================================+
  */
 PROCEDURE ARIU_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
 v_customer_id  Number;  /*Added by nprashar for TCS for bug # 9489145*/
 v_customer_id_bill           Number ;/*Added by nprashar for TCS for bug # 9489145*/
 v_customer_id_ship           Number; /*Added by nprashar for TCS for bug # 9489145*/
  v_address_id                 Number ;
  v_org_id                     Number := 0;
  v_header_id                  Number; -- := pr_new.customer_trx_id; --Ramananda for File.Sql.35
  v_bill_to_site_use_id        Number := 0; /*Bug 8371741*/
  v_ship_to_site_use_id        Number := 0; /*Added by nprashar for TCS for bug # 9489145*/
  v_site_use_id                Number := 0;  /*Added by nprashar for TCS for bug # 9489145*/
  v_inventory_item_id          Number; -- := pr_new.inventory_item_id; --Ramananda for File.Sql.35
  v_tax_category_list          varchar2(30);
  v_tax_category_id            Number;
  v_item_class                 varchar2(30); -- := 'N'; --Ramananda for File.Sql.35
  v_line_amount                number :=0 ;
  v_line_no                    Number;
  v_tax_id                     Number;
  v_tax_rate                   Number;
  v_tax_amount                 Number;
  v_line_tax_amount            Number := 0;
  v_uom_code                   varchar2(3); -- := pr_new.uom_code; --Ramananda for File.Sql.35
  v_tax_tot                    Number := 0;
  v_tot_amt                    Number := 0;
  v_excise                     Number := 0;
  v_additional                 Number := 0;
  v_other                      Number := 0;
  v_hdr_tax_amount             Number := 0;
  v_hdr_total_amount           Number := 0;
  v_price_list                 Number := 0;
  v_price_list_val             Number := 0;
  v_price_list_uom_code        Varchar2(3);
  v_conversion_rate            Number := 0;
  v_organization_id            Number := -1;
  v_row_id                     Rowid;
  v_customer_trx_line_id       Number; -- := pr_new.customer_trx_line_id; --Ramananda for File.Sql.35
  v_once_completed_flag        Varchar2(1);
  v_old_line_amount            Number := 0;
  v_old_tax_tot                Number := 0;
  v_created_from               Varchar2(30);
  c_from_currency_code         Varchar2(15);
  c_conversion_type            Varchar2(30);
  c_conversion_date            Date;
  c_conversion_rate            Number := 0;
  v_converted_rate             Number := 1;
  v_books_id                   Number;
  v_gl_date                    Date;
-- Date 26-feb-2006 added by sacsethi for bug 5631784
  ln_tcs_exists                number;
  ln_tcs_regime_id             JAI_RGM_DEFINITIONS.regime_id%type;
  ln_threshold_slab_id         JAI_AP_TDS_THHOLD_SLABS.threshold_slab_id%type;
  ln_threshold_tax_cat_id      JAI_AP_TDS_THHOLD_TAXES.tax_category_id%type;
  ld_gl_dist_date              date;
  v_service_type               VARCHAR2(30);      -- added by csahoo for bug#5879769
 v_num_check Number;  /*Added by nprashar for TCS*/

  cursor c_gl_dist_date ( cp_customer_trx_id  ra_customer_trx_all.customer_trx_id%type)
    is
      select gl_date
      from   ra_cust_trx_line_gl_dist_all
      where  customer_trx_id = cp_customer_trx_id
      and    account_class = jai_constants.account_class_rec
      and    latest_rec_flag = jai_constants.yes;

   CURSOR GC_GET_REGIME_ID (CP_REGIME_CODE    JAI_RGM_DEFINITIONS.REGIME_CODE%TYPE)
      IS
       SELECT REGIME_ID
       FROM   JAI_RGM_DEFINITIONS
       WHERE  REGIME_CODE = CP_REGIME_CODE;

   CURSOR GC_CHK_RGM_TAX_EXISTS ( CP_REGIME_CODE      JAI_RGM_DEFINITIONS.REGIME_CODE%TYPE
      ,    CP_RGM_TAX_TYPE     JAI_CMN_TAXES_ALL.TAX_TYPE%TYPE
      ,    CP_TAX_CATEGORY_ID  JAI_CMN_TAX_CTGS_ALL.TAX_CATEGORY_ID%TYPE
      )
     IS
        SELECT COUNT(1)
  FROM   JAI_CMN_TAX_CTG_LINES CATL
          ,JAI_CMN_TAXES_ALL CODES
       ,JAI_REGIME_TAX_TYPES_V JRTTV
  WHERE CATL.TAX_CATEGORY_ID  = CP_TAX_CATEGORY_ID
  AND   CATL.TAX_ID           = CODES.TAX_ID
  AND   CODES.TAX_TYPE        = JRTTV.TAX_TYPE
  AND   JRTTV.REGIME_CODE     = CP_REGIME_CODE;
-- END 5631784


  /*  --Ramananda for File.Sql.35, START */
  v_last_update_date           Date; --   := pr_new.last_update_date;
  v_last_updated_by            Number; -- := pr_new.last_updated_by;
  v_creation_date              Date ; --  := pr_new.creation_date;
  v_created_by                 Number; -- := pr_new.created_by;
  v_last_update_login          Number; -- := pr_new.last_update_login;
  /* --Ramananda for File.Sql.35, END */

  v_trx_date                   Date;
  v_total_tax_amount           Number :=0;
  v_line_type                  varchar2(20); -- := pr_new.LINE_TYPE; --Ramananda for File.Sql.35
  V_DEBUG_VAR                  VARCHAR2(1996);
  VAR_REC_CTR                  NUMBER :=0;
  VAR_SQLERRM                  VARCHAR2(240);
  v_trans_type                 Varchar2(30);
  v_quantity                   number; -- It holds the quantity_invoiced in case of 'INV' and quantity_credited in case of 'CM' -- added ssumaith - bug# 3957682

-- Date 26-feb-2006 added by sacsethi for bug 5631784
  lv_process_flag               VARCHAR2(2);
  lv_process_message            VARCHAR2(1996);
-- date 5631784
  Cursor  bind_cur IS /*Bug 8371741 - Modified to use Bill to Account*/
  /*Commented by nprashar for bug # 9489145
SELECT  A.org_id,
          A.bill_to_customer_id,
          NVL(A.bill_to_site_use_id,0)
  FROM    RA_CUSTOMER_TRX_ALL A
  WHERE   customer_trx_id = v_header_id; */

SELECT  A.org_id,  /*Added by nprashar for bug # 9489145*/
          A.ship_to_customer_id,
          NVL(A.ship_to_site_use_id,0),
          A.bill_to_customer_id,
          NVL(A.bill_to_site_use_id,0)
         FROM RA_CUSTOMER_TRX_ALL A
WHERE   customer_trx_id = v_header_id;

  Cursor header_info_cur IS
  SELECT set_of_books_id,
         invoice_currency_code,
         exchange_rate_type,
         exchange_date,
         exchange_rate, trx_date
  FROM   RA_CUSTOMER_TRX_ALL
  WHERE  customer_trx_id = v_header_id;

  Cursor address_cur(p_ship_to_site_use_id IN Number) IS
  SELECT cust_acct_site_id address_id
  FROM   HZ_CUST_SITE_USES_ALL A  /* Removed ra_site_uses_all for Bug# 4434287 */
  WHERE  A.site_use_id = NVL(p_ship_to_site_use_id,0);

  CURSOR excise_cal_cur IS
  SELECT A.tax_id, A.tax_rate, A.tax_amount tax_amt,b.tax_type t_type
  FROM   JAI_AR_TRX_TAX_LINES A , JAI_CMN_TAXES_ALL B
  WHERE  link_to_cust_trx_line_id = v_customer_trx_line_id
  AND    A.tax_id = B.tax_id
  ORDER  BY 1;


  /*
  || Commented, Ramananda for bug #4567935 (115 bug3671351)
  */
  /*
  CURSOR price_list_cur(p_customer_id IN Number,p_inventory_item_id IN Number,
         p_address_id IN Number DEFAULT 0,v_uom_code VARCHAR2, p_trx_date DATE) IS
  SELECT A.list_price, a.unit_code
  FROM   so_price_list_lines A, JAI_CMN_CUS_ADDRESSES B
  WHERE  A.price_list_id  =  B.price_list_id
  AND    B.customer_id = p_customer_id
  AND    B.address_id  = p_address_id
  AND    A.inventory_item_id = p_inventory_item_id
  AND    a.unit_code = v_uom_code
  AND    NVL(a.end_date_active,SYSDATE) >= p_trx_date;
  */


  CURSOR ORG_CUR IS
  SELECT organization_id
  FROM   JAI_AR_TRX_APPS_RELS_T ;/*altered by rchandan for bug#4479131*/

  CURSOR organization_cur IS
  SELECT A.organization_id
  FROM   JAI_AR_TRXS A, RA_CUSTOMER_TRX_ALL B
  WHERE  A.trx_number = B.recurred_from_trx_number AND B.customer_trx_id = v_header_id;

  CURSOR CREATED_FROM_CUR IS
  SELECT created_from , trx_date
  FROM   ra_customer_trx_all
  WHERE  customer_trx_id = v_header_id;

  ld_trx_date ra_customer_trx_all.trx_Date%type;

  CURSOR ONCE_COMPLETE_FLAG_CUR IS
  SELECT once_completed_flag
  FROM   JAI_AR_TRXS
  WHERE  customer_trx_id = v_header_id;

  CURSOR ROW_ID_CUR IS
  SELECT rowid
  FROM   RA_CUSTOMER_TRX_ALL
  WHERE  customer_trx_id = v_header_id;

  CURSOR old_line_amount_cur IS
  SELECT line_amount
  FROM   JAI_AR_TRX_LINES
  WHERE  CUSTOMER_TRX_ID = pr_old.CUSTOMER_TRX_ID
  AND    CUSTOMER_TRX_LINE_ID = pr_old.CUSTOMER_TRX_LINE_ID;

  CURSOR gl_date_cur IS
  SELECT DISTINCT gl_date
  FROM   RA_CUST_TRX_LINE_GL_DIST_ALL
  WHERE  CUSTOMER_TRX_LINE_ID = v_customer_trx_line_id;


  Cursor transaction_type_cur IS
  Select a.type
  From   RA_CUST_TRX_TYPES_ALL a, RA_CUSTOMER_TRX_ALL b
  Where  a.cust_trx_type_id = b.cust_trx_type_id
  And    b.customer_trx_id = v_header_id
  And    NVL(a.org_id,0) = NVL(pr_new.org_id,0);

  ln_vat_assessable_value JAI_AR_TRX_LINES.VAT_ASSESSABLE_VALUE%TYPE;

  /* Added by Ramananda as a part of removal of SQL LITERALs , start */
  lv_appl_src JAI_CMN_ERRORS_T.APPLICATION_SOURCE%type ;
  lv_add_err  JAI_CMN_ERRORS_T.additional_error_mesg%type ;
  BEGIN
    pv_return_code := jai_constants.successful ;
       /*  This Trigger fires , when you insert a record in RA_CUSTOMER_TRX_LINES_ALL */

/*------------------------------------------------------------------------------------------
FILENAME: JA_IN_AR_LINES_INSERT_TRG.sql
CHANGE HISTORY:

S.No      Date          Author and Details
--------------------------------------------------------------------------------------------
1.      2001/06/22     Anuradha Parthasarathy
                       Code commented and added to improve performance.

2.      2003/03/12     Sriram - Bug # 2846277 - File Version 615.1

                       In case where seup business group setup is done , inventory organization is a value 0.
                       This was causing the trigger to return because of code comparison . Hence changed the
                       comparison to a large value such as 999999

3.      2004/10/17     ssumaith - bug# 3957682 - file version 115.1

                       Tax defaultation was not happening for a manual credit memo created without reference to
                       an invoice.
                       Added code in the trigger to ensure that code does not return when the transaction type is
                       either 'INV' or 'CM'. Earlier the check was for 'INV' only.

4.      29-nov-2004    ssumaith - bug# 4037690  - File version 115.2
                       Check whether india localization is being used was done using a INR check in every trigger.
                       This check has now been moved into a new package and calls made to this package from this trigger
                       If the function jai_cmn_utils_pkg.check_jai_exists returns true it means INR is the set of books currency ,
                       Hence if this function returns FALSE , control should return

5.      16/Mar/05     ssumaith - bug# 4245053 file version 115.3

                      uptake of the vat assessable value has been done in this trigger.
                      A call to the  jai_general_pkg.JA_IN_VAT_ASSESSABLE_VALUE  has been made passing the parameters
                      to get the vat assessable value to the tax calculation routines and update the vat assessable
                      value in the JAI_OM_OE_SO_LINES table.

                      This vat assessable value is sent as an additional parameter to the various procedures
                      such as jai_om_tax_pkg.recalculate_oe_taxes , jai_cmn_tax_defaultation_pkg.ja_in_calc_prec_taxes

                      Hence, its mandatory that with this object all the other objects in this patch as well as the base bug
                      need to be sent.

                      VAt assessable value , vat exemption related columns (type , refno and date) have also been copied
                      from the source line in the case of a copy order / split scenario.

                      Dependency due to this bug - Huge
                      This patch should always be accompanied by the VAT consolidated patch - 4245089

6.     08-Jun-2005    File Version 116.1. This Object is Modified to refer to New DB Entity names in place of Old
                      DB Entity as required for CASE COMPLAINCE.

7.     10-Jun-2005    File Version: 116.2
                      Removal of SQL LITERALs is done

8.     8-Jul-2005     rchandan for bug#4479131. File Version: 116.3
                      The object is modified to eliminate the paddr usage.

9.     23-Aug-2005    Ramananda for bug#4567935 (115 bug3671351). File version 120.2

                      Problem
                      -------
                      Excise taxes not getting calculated on assessable price in AR INVOICE.

                      Fix
                      ---
                      Commented the code to calculate the assessable price and added a call
                      to the jai_om_utils_pkg.get_oe_assessable_value function to calculate the assessable price
                      correctly through various levels of defaultation.

10.    12-Nov-2008    CSahoo for bug#6012465, File Version 120.7.12000000.8
                      Issue:  ASSESSABLE PRICE FOR ITEMS DOES NOT APPEAR IN AR
                      Reason: While creation of Manual Invoices, attachment of Item / Tax category list is checked before the
                              calculation of excise / vat assessable value. If any category list is not attached,
                              assessable value is shown as zero.
                      Fix:   Tax Category check is moved after the calculation of excise and vat assessable value.

Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Current Version    Current Bug    Dependent           Files                Version   Author   Date          Remarks
Of File                           On Bug/Patchset    Dependent On

ja_in_ar_lines_insert_trg.sql
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
115.2              4037690        IN60105D2          ja_in_util_pkg_s.sql  115.0     ssumaith 29-Nov-2004  Call to this function.
                                                     ja_in_util_pkg_s.sql  115.0     ssumaith

115.3              4245053        IN60106 +                                          ssumaith                Service Tax and VAT Infrastructure are created
                                  4146708 +                                                                   based on the bugs - 4146708 and 4545089 respectively.
                                  4245089

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

  /* --Ramananda for File.Sql.35, start */
  v_header_id                  := pr_new.customer_trx_id;
  v_inventory_item_id          := pr_new.inventory_item_id;
  v_item_class                 := 'N';
  v_uom_code                   := pr_new.uom_code;
  v_customer_trx_line_id       := pr_new.customer_trx_line_id;
  v_last_update_date           := pr_new.last_update_date;
  v_last_updated_by            := pr_new.last_updated_by;
  v_creation_date              := pr_new.creation_date;
  v_created_by                 := pr_new.created_by;
  v_last_update_login          := pr_new.last_update_login;
  v_line_type                  := pr_new.LINE_TYPE;
  ------------------
  /* --Ramananda for File.Sql.35, end */

    /*The following code has added - ssumaith - bug# 4037690*/
    --If jai_cmn_utils_pkg.check_jai_exists(P_CALLING_OBJECT => 'JA_IN_AR_LINES_INSERT_TRG', P_ORG_ID => pr_new.ORG_ID) = false then
    --   return;
    --end if;

    OPEN  transaction_type_cur;
    FETCH transaction_type_cur INTO v_trans_type;
    CLOSE transaction_type_cur;

    IF NVL(v_trans_type,'N') Not in ( 'INV','CM') THEN -- 'CM' added ssumaith - bug# 3957682
       Return;
    END IF;


    IF NVL(v_trans_type,'N') = 'INV' then
       v_line_amount      := nvl(pr_new.quantity_invoiced * pr_new.unit_selling_price, nvl(pr_new.extended_amount,0)); --added  nvl(pr_new.extended_amount,0) for bug#8849775
       v_quantity         := pr_new.quantity_invoiced; -- added ssumaith - bug# 3957682
    elsif NVL(v_trans_type,'N') = 'CM' then
        v_line_amount      := nvl(pr_new.quantity_credited * pr_new.unit_selling_price,nvl(pr_new.extended_amount,0)); --added  nvl(pr_new.extended_amount,0) for bug#8849775
       v_quantity         := pr_new.quantity_credited; -- added ssumaith - bug# 3957682
    end if;

    OPEN   ONCE_COMPLETE_FLAG_CUR;
    FETCH  ONCE_COMPLETE_FLAG_CUR INTO v_once_completed_flag;
    CLOSE  ONCE_COMPLETE_FLAG_CUR;
    IF NVL(v_once_completed_flag,'N') = 'Y' THEN
      RETURN;
    END IF;

    OPEN   CREATED_FROM_CUR;
    FETCH  CREATED_FROM_CUR INTO v_created_from , ld_trx_date;
    CLOSE  CREATED_FROM_CUR;
    IF v_created_from in ('ARXREC','RAXTRX') THEN
       RETURN;
    END IF;
    IF v_created_from = 'ARXTWMAI' THEN
       OPEN  ORG_CUR;
       FETCH ORG_CUR INTO v_organization_id;
       CLOSE ORG_CUR;
       IF NVL(v_organization_id,999999) = 999999 THEN    -- made 0 to 999999 because in case of setup business group setup , inventory organization value is 0
          OPEN  organization_cur;                         -- which was causing code to return .- bug # 2846277
          FETCH organization_cur INTO v_organization_id;
          CLOSE organization_cur;
       /*ELSE
          OPEN  ROW_ID_CUR;
          FETCH ROW_ID_CUR INTO v_row_id;
          CLOSE ROW_ID_CUR;
          jai_cmn_utils_pkg.JA_IN_SET_LOCATOR('JAINARTX',v_row_id);*//*commented by rchandan for bug#4479131*/
       END IF;
       IF NVL(v_organization_id,999999) = 999999 THEN   -- -- made 0 to 999999 because in case of setup business group setup , inventory organization value is 0
         RETURN;
       END IF;
       OPEN bind_cur;
       FETCH bind_cur INTO v_org_id, v_customer_id_ship,v_ship_to_site_use_id, v_customer_id_bill,v_bill_to_site_use_id ; /*Added by nprashar for TCS for bug # 9489145*/
       CLOSE bind_cur;
       IF pr_new.inventory_item_id <> pr_old.inventory_item_id THEN
          FOR excise_cal_rec in excise_cal_cur
          LOOP
             IF excise_cal_rec.t_type IN ('Excise') THEN
                v_excise := nvl(v_excise,0) + nvl(excise_cal_rec.tax_amt,0);
             ELSIF excise_cal_rec.t_type IN ('Addl. Excise') THEN
                v_additional := nvl(v_additional,0) + nvl(excise_cal_rec.tax_amt,0);
             ELSIF excise_cal_rec.t_type IN ('Other Excise') THEN
                v_other := nvl(v_other,0) + nvl(excise_cal_rec.tax_amt,0);
             END IF;
          END LOOP;
          v_old_tax_tot  := nvl(v_excise,0) + nvl(v_other,0) + nvl(v_additional,0);
          OPEN   old_line_amount_cur;
          FETCH  old_line_amount_cur INTO v_old_line_amount;
          CLOSE  old_line_amount_cur;
          UPDATE JAI_AR_TRXS
          SET    line_amount = nvl(line_amount,0) - nvl(v_old_line_amount,0),
                 tax_amount  = nvl(tax_amount,0) - nvl(v_old_tax_tot,0),
                 total_amount = nvl(total_amount,0) - (nvl(v_old_line_amount,0) + nvl(v_old_tax_tot,0))
          WHERE  customer_trx_id = pr_old.CUSTOMER_TRX_ID;

          DELETE JAI_AR_TRX_TAX_LINES
          WHERE  LINK_TO_CUST_TRX_LINE_ID = pr_old.CUSTOMER_TRX_LINE_ID;

          DELETE JAI_AR_TRX_LINES
          WHERE  CUSTOMER_TRX_ID = pr_old.CUSTOMER_TRX_ID
          AND    CUSTOMER_TRX_LINE_ID = pr_old.CUSTOMER_TRX_LINE_ID;
       END IF;

       OPEN  HEADER_INFO_CUR;
       FETCH HEADER_INFO_CUR INTO v_books_id, c_from_currency_code, c_conversion_type, c_conversion_date,
                                  c_conversion_rate, v_trx_date;
       CLOSE HEADER_INFO_CUR;

       v_site_use_id := v_bill_to_site_use_id; /*Added by nprashar for TCS for bug # 9489145*/
       v_customer_id := v_customer_id_bill;  /*Added by nprashar for TCS for bug # 9489145*/

       /*Added by nprashar for TCS for bug # 9489145*/
       For check_corr_tax_category_id in 1 .. 2  /*Logic to check whethet to Use bill_to value or ship_to value depending upon TCS taxes*/
       Loop
       OPEN address_cur( v_site_use_id ); /*Added by nprashar for TCS for bug # 9489145*/
       FETCH address_cur INTO v_address_id;
       CLOSE address_cur;

       IF v_customer_id IS NOT NULL AND v_address_id IS NOT NULL  THEN
           jai_cmn_tax_defaultation_pkg.ja_in_cust_default_taxes(
                                                  v_organization_id ,
                                                  v_customer_id,
                                                  v_site_use_id , /*Added by nprashar for TCS for bug # 9489145*/
                                                  v_inventory_item_id ,
                                                  v_header_id ,
                                                  v_customer_trx_line_id,
                                                  v_tax_category_id
                                                 );
       ELSE
           jai_cmn_tax_defaultation_pkg.ja_in_org_default_taxes(
                                                 v_organization_id ,
                                                 v_inventory_item_id ,
                                                 v_tax_category_id
                                                );
       END IF;
       open  gc_chk_rgm_tax_exists
                                      ( cp_regime_code     =>   jai_constants.tcs_regime
                                      , cp_rgm_tax_type    =>   jai_constants.tax_type_tcs
                                      , cp_tax_category_id =>   v_tax_category_id
                                      );
            fetch gc_chk_rgm_tax_exists into ln_tcs_exists;
            close gc_chk_rgm_tax_exists;

       If ln_tcs_exists > 0 then
           v_num_check := 1;
           Exit;
       End If;
       v_num_check := 2;
       v_site_use_id := v_ship_to_site_use_id;
       v_customer_id := v_customer_id_ship;
       End Loop;

       If v_num_check = 1 then  /*Added by nprashar for TCS for bug # 9489145*/
        v_site_use_id := v_bill_to_site_use_id;
        v_customer_id := v_customer_id_bill;
       Elsif v_num_check = 2 then
        v_site_use_id := v_ship_to_site_use_id;
        v_customer_id := v_customer_id_ship;
       End If; /*Ends here for bug # 9489145*/



        -- bug#6012465. Moved the following if statement after assessable_value calculations
        --IF v_tax_category_id IS NOT NULL  THEN

        /*
        ||Start of bug #4567935 (115 bug3671351)
        ||Code added, Ramananda for bug #4567935 (115 bug3671351), Start
        ||Instead of deriving the assessable valeu in this trigger,
        ||the same has been now shifted to the function jai_om_utils_pkg.get_oe_assessable_value
        ||The function gets the assessable value based on 5 level defaultation
        ||logic.Currently the assessable value was being fetched only from the so_price_list_lines
        */

        v_price_list := jai_om_utils_pkg.get_oe_assessable_value
                             (
                                p_customer_id         => v_customer_id,
                                p_ship_to_site_use_id => v_site_use_id, /*v_bill_to_site_use_id, Bug 8371741*/
                                p_inventory_item_id   => v_inventory_item_id,
                                p_uom_code            => v_uom_code,
                                p_default_price       => pr_new.unit_selling_price,
                                p_ass_value_date      => ld_trx_date,
        /* Bug 5096787. Added by Lakshmi Gopalsami */
        p_sob_id              => v_books_id,
        p_curr_conv_code      => c_conversion_type,
        p_conv_rate           => c_conversion_rate
        /* Later need to derive for p_conv_rate using ja_curr_conv
         as part of forwarding 11i code bug 4446346 */
                             );
        v_price_list_val := v_quantity * NVL(v_price_list,0);
        /*
        ||End of #4567935 (115 bug3671351)
        */


         /* added by ssumaith - bug#4245053 */
        ln_vat_assessable_value :=  jai_general_pkg.ja_in_vat_assessable_value
                                   (
                                    p_party_id           => v_customer_id          ,
                                    p_party_site_id      => v_site_use_id , /*v_bill_to_site_use_id  , Bug 8371741*/
                                    p_inventory_item_id  => v_inventory_item_id    ,
                                    p_uom_code           => v_uom_code             ,
                                    p_default_price      => pr_new.unit_selling_price,
                                    p_ass_value_date     => ld_trx_date            ,
                                    p_party_type         => 'C'
                                   );
        ln_vat_assessable_value := nvl(ln_vat_assessable_value,0) * v_quantity;
        /* ends here additions by ssumaith - bug# 4245053*/

        IF v_tax_category_id IS NOT NULL  THEN  --added for bug#6012465

          IF c_conversion_date is NULL THEN
             c_conversion_date := v_trx_date;
          END IF;

          v_converted_rate := jai_cmn_utils_pkg.currency_conversion(
                                           v_books_id ,
                                           c_from_currency_code ,
                                           c_conversion_date ,
                                           c_conversion_type,
                                           c_conversion_rate
                                          );
          v_line_tax_amount := nvl(v_line_amount,0);
           -- Date 26-feb-2006 added by sacsethi for bug 5631784
            /*open  gc_chk_rgm_tax_exists
                                      ( cp_regime_code     =>   jai_constants.tcs_regime
                                      , cp_rgm_tax_type    =>   jai_constants.tax_type_tcs
                                      , cp_tax_category_id =>   v_tax_category_id
                                      );
            fetch gc_chk_rgm_tax_exists into ln_tcs_exists;
            close gc_chk_rgm_tax_exists;
            if  ln_tcs_exists > 0 then
             TCS type of tax(s) are present */
           If v_num_check = 1 then  /*Added by nprashar for TCS for bug # 9489145*/
              open  gc_get_regime_id ( cp_regime_code => jai_constants.tcs_regime);
              fetch gc_get_regime_id into ln_tcs_regime_id;
              close gc_get_regime_id;

              jai_rgm_thhold_proc_pkg.get_threshold_slab_id
                                        (   p_regime_id         =>    ln_tcs_regime_id
                                          , p_organization_id   =>    v_organization_id
                                          , p_party_type        =>    jai_constants.party_type_customer
                                          , p_party_id          =>    v_customer_id
                                          , p_org_id            =>    v_org_id
                                          , p_source_trx_date   =>    ld_trx_date /* ssumaith - bug# 6109941*/
                                          , p_threshold_slab_id =>    ln_threshold_slab_id
                                          , p_process_flag      =>    lv_process_flag
                                          , p_process_message   =>    lv_process_message
                                        );

                if lv_process_flag <> jai_constants.successful then
                   app_exception.raise_exception
                                  (exception_type   =>    'APP'
                                  ,exception_code   =>    -20275
                              ,exception_text   =>    lv_process_message
                              );
                end if;
            if ln_threshold_slab_id is not null then
              /**
                  Threshold is high and slab is available.   Hence get tax_category defined for the salb to default additional taxes
              */
                jai_rgm_thhold_proc_pkg.get_threshold_tax_cat_id
                                        (
                                           p_threshold_slab_id    =>    ln_threshold_slab_id
                                        ,  p_org_id               =>    v_org_id
                                        ,  p_threshold_tax_cat_id =>    ln_threshold_tax_cat_id
                                        ,  p_process_flag         =>    lv_process_flag
                                        ,  p_process_message      =>    lv_process_message
                                        );
                if lv_process_flag <> jai_constants.successful then
                  app_exception.raise_exception
                                (exception_type   =>    'APP'
                                ,exception_code   =>    -20275
                                ,exception_text   =>    lv_process_message
                                );
                end if;
              end if; /** ln_threshold_slab_id is not null  */
            end if; /** ln_tcs_exists is not null  */
            jai_cmn_tax_defaultation_pkg.ja_in_calc_prec_taxes(
                                              'AR_LINES' ,
                                              v_tax_category_id ,
                                              v_header_id,
                                              v_customer_trx_line_id,
                                              v_price_list_val ,
                                              v_line_tax_amount ,
                                              v_inventory_item_id ,
                                              nvl(v_quantity,0), -- added  - bug# 3957682
                                              pr_new.uom_code ,
                                              NULL ,
                                              NULL ,
                                              v_converted_rate ,
                                              v_creation_date ,
                                              v_created_by ,
                                              v_last_update_date ,
                                              v_last_updated_by ,
                                              v_last_update_login,
                                              NULL,
                                              ln_vat_assessable_value, /* added by ssumaith - bug# 4245053*/
                                              p_thhold_cat_base_tax_typ      =>   jai_constants.tax_type_tcs ,  -- Date 26-feb-2006 added by sacsethi for bug 5631784
                                              p_threshold_tax_cat_id         =>   ln_threshold_tax_cat_id,-- Date 26-feb-2006 added by sacsethi for bug 5631784
                                              p_source_trx_type              =>   null,-- Date 26-feb-2006 added by sacsethi for bug 5631784
                                              p_source_table_name            =>   null,-- Date 26-feb-2006 added by sacsethi for bug 5631784
                                              p_action                       =>   jai_constants.default_taxes-- Date 26-feb-2006 added by sacsethi for bug 5631784
                                             );
       END IF;
       v_excise := 0;
       v_additional := 0;
       v_other := 0;
       v_total_tax_amount := 0;
       FOR excise_cal_rec in excise_cal_cur
       LOOP
          IF excise_cal_rec.t_type IN ('Excise') THEN
             v_excise := nvl(v_excise,0) + excise_cal_rec.tax_amt;
          ELSIF excise_cal_rec.t_type IN ('Addl. Excise') THEN
             v_additional := nvl(v_additional,0) + excise_cal_rec.tax_amt;
          ELSIF excise_cal_rec.t_type IN ('Other Excise') THEN
             v_other := nvl(v_other,0) + excise_cal_rec.tax_amt;
          END IF;
          v_total_tax_amount := nvl(v_total_tax_amount,0) + nvl(excise_cal_rec.tax_amt,0);
       END LOOP;
       v_tax_tot  := nvl(v_excise,0) + nvl(v_other,0) + nvl(v_additional,0);
       v_tot_amt    := nvl(v_line_amount,0) + nvl(v_total_tax_amount,0);

       UPDATE JAI_AR_TRXS
       SET    line_amount  = NVL(line_amount,0) + NVL(v_line_amount,0),
              total_amount = NVL(total_amount,0)+ NVL(v_tot_amt,0) ,
              tax_amount   = NVL(tax_amount,0)  + NVL(v_total_tax_amount,0)
       WHERE  JAI_AR_TRXS.customer_trx_id = v_header_id;

       /*added by csahoo for bug#5879769*/
       OPEN c_get_address_details(v_header_id);
       FETCH c_get_address_details into r_add;
       CLOSE c_get_address_details;

       v_service_type:=get_service_type( NVL(r_add.SHIP_TO_CUSTOMER_ID ,r_add.BILL_TO_CUSTOMER_ID) ,
                          NVL(r_add.SHIP_TO_SITE_USE_ID, r_add.BILL_TO_SITE_USE_ID),'C');


       Open  Gl_Date_Cur;
       Fetch Gl_Date_Cur Into v_gl_date;
       Close Gl_Date_Cur;
       INSERT INTO JAI_AR_TRX_LINES(
                                               customer_trx_line_id,
                                               line_number,
                                               customer_trx_id,
                                               description,
                                               inventory_item_id,
                                               unit_code,
                                               quantity,
                                               tax_category_id,
                                               auto_invoice_flag ,
                                               unit_selling_price,
                                               line_amount,
                                               gl_date,
                                               tax_amount,
                                               total_amount,
                                               assessable_value,
                                               creation_date,
                                               created_by,
                                               last_update_date,
                                               last_updated_by,
                                               last_update_login,
                                               vat_assessable_value, /* added by ssumaith - bug# 4245053*/
                                               service_type_code      -- Added by csahoo for Bug#5879769
                                              )
                                       VALUES(
                                              v_customer_trx_line_id,
                                              pr_new.line_number,
                                              v_header_id,
                                              pr_new.description,
                                              pr_new.inventory_item_id,
                                              pr_new.uom_code,
                                              --NVL(pr_new.quantity_invoiced,0), -- commented - bug# 3957682
                                              nvl(v_quantity,0), -- added - bug# 3957682
                                              v_tax_category_id,
                                              'N',
                                              pr_new.unit_selling_price,
                                              v_line_amount,
                                              v_gl_date,
                                              v_line_tax_amount,
                                              (v_line_amount + v_line_tax_amount),
                                              v_price_list,
                                              v_creation_date,
                                              v_created_by,
                                              v_last_update_date,
                                              v_last_updated_by,
                                              v_last_update_login,
                                              ln_vat_assessable_value,  /* added by ssumaith - bug# 4245053*/
                                              v_service_type            -- Added by csahoo for Bug#5879769
                                             );
    END IF;


EXCEPTION
WHEN OTHERS THEN
   VAR_SQLERRM := 'EXCEPTION OCCURED - ' || SQLERRM;
   VAR_SQLERRM := SUBSTR(VAR_SQLERRM,1,235);

  /* Added an exception block by Ramananda for bug#4570303 */
   Pv_return_code     :=  jai_constants.unexpected_error;
   Pv_return_message  := 'Encountered an error in JAI_AR_RCTLA_TRIGGER_PKG.ARIU_T1  '  || substr(sqlerrm,1,1900);

   lv_appl_src := 'JA_IN_AR_LINES_INSERT_TRG';
   lv_add_err  := 'CUSTOMER_TRX_ID = ' || TO_CHAR(pr_new.CUSTOMER_TRX_ID) || ' CUSTOMER_TRX_LINE_ID = ' || TO_CHAR(pr_new.CUSTOMER_TRX_LINE_ID) ;

   INSERT INTO JAI_CMN_ERRORS_T
                                        ( APPLICATION_SOURCE,
                                          error_message,
                                          additional_error_mesg,
                                          creation_date,
                                          created_by    ,
                                          -- added, Harshita for Bug 4866533
                                          LAST_UPDATED_BY,
                                          LAST_UPDATE_DATE
                                       )
                                        values
                                        (
                                         lv_appl_src, /*'JA_IN_AR_LINES_INSERT_TRG', Ramananda for removal of SQL LITERALs */
                                         VAR_SQLERRM,
                                         lv_add_err, /* 'CUSTOMER_TRX_ID = ' || TO_CHAR(pr_new.CUSTOMER_TRX_ID) || ' CUSTOMER_TRX_LINE_ID = ' || TO_CHAR(pr_new.CUSTOMER_TRX_LINE_ID) , */
                                         sysdate,
                                         user      ,
                                          -- added, Harshita for Bug 4866533
                                          fnd_global.user_id,
                                          sysdate
                                        );

  END ARIU_T1 ;

  /*REM +======================================================================+
  REM NAME          ARU_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_AR_RCTLA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_AR_RCTLA_ARU_T2
  REM
  REM +======================================================================+
  */
 PROCEDURE ARU_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
   v_customer_id                           Number ;
  v_address_id                            Number ;
  v_org_id                                Number := 0;
  v_bill_to_site_use_id                   Number := 0;
  v_tax_category_list                     varchar2(30);
  v_tax_category_id                       Number;
  v_line_no                               Number;
  v_tax_id                                Number;
  v_tax_rate                              Number;
  v_tax_amount                            Number;
  v_line_tax_amount                       Number := 0;
  v_tax_tot                               Number := 0;
  v_tot_amt                               Number := 0;
  v_excise                                Number := 0;
  v_additional                            Number := 0;
  v_other                                 Number := 0;
  v_price_list                            Number := 0;
  v_price_list_val                        Number := 0;
  v_price_list_uom_code                   Varchar2(3);
  v_conversion_rate                       Number := 0;
  v_old_tax_tot                           Number := 0;
  v_organization_id                       Number := -1;
  v_created_from                          Varchar2(30);
  v_once_completed_flag                   Varchar2(1);
  c_from_currency_code                    Varchar2(15);
  c_conversion_type                       Varchar2(30);
  c_conversion_date                       Date;
  c_conversion_rate                       Number := 0;
  v_converted_rate                        Number := 0;
  v_books_id                              Number;
  v_row_id                                Rowid;

  /* --Ramananda for File.Sql.35 */
  v_uom_code                              varchar2(3); -- := pr_new.uom_code;
  v_line_amount                           number; -- := nvl(nvl(pr_new.quantity_credited,pr_new.quantity_invoiced) * pr_new.unit_selling_price,0);
  v_old_amount                            Number; -- := nvl(nvl(pr_old.quantity_credited,pr_new.quantity_invoiced) * pr_old.unit_selling_price,0);
  v_item_class                            varchar2(30); -- :='N';
  v_inventory_item_id                     Number; -- := pr_new.inventory_item_id;
  v_header_id                             Number; -- := pr_old.customer_trx_id;
  v_customer_trx_line_id                  Number; -- := pr_old.customer_trx_line_id;
  v_last_update_date                      Date ; --  := pr_new.last_update_date;
  v_last_updated_by                       Number; -- := pr_new.last_updated_by;
  v_creation_date                         Date ; --  := pr_new.creation_date;
  v_created_by                            Number; -- := pr_new.created_by;
  v_last_update_login                     Number; -- := pr_new.last_update_login;
  v_trx_date                              Date;
  v_trans_type                            Varchar2(30);
/* --Ramananda for File.Sql.35 */

  Cursor bind_cur IS /*Modified to use Bill to Account - Bug 8371741*/
  SELECT  A.org_id,A.bill_to_customer_id,NVL(A.bill_to_site_use_id,0)
  FROM    RA_CUSTOMER_TRX_ALL A
  WHERE   customer_trx_id = v_header_id;

  Cursor header_info_cur IS
  SELECT set_of_books_id   ,  invoice_currency_code,
         exchange_rate_type,  exchange_date,
         exchange_rate     , trx_date
  FROM   RA_CUSTOMER_TRX_ALL
  WHERE  customer_trx_id = v_header_id;

  CURSOR excise_cal_cur IS
  select A.tax_id, A.tax_rate, A.tax_amount tax_amt,b.tax_type t_type
  from   JAI_AR_TRX_TAX_LINES     A ,
         JAI_CMN_TAXES_ALL                 B
  where  link_to_cust_trx_line_id = pr_old.customer_trx_line_id
  and    A.tax_id = B.tax_id
  order  by 1;

  CURSOR ORG_CUR IS
  SELECT organization_id
  FROM   JAI_AR_TRX_APPS_RELS_T;/*altered by rchandan for bug#4479131*/


  CURSOR organization_cur IS
  SELECT organization_id
  FROM   JAI_AR_TRXS
  WHERE  trx_number = (
                        SELECT recurred_from_trx_number
                        FROM   RA_CUSTOMER_TRX_ALL
                        WHERE  customer_trx_id = v_header_id
                      );

  CURSOR CREATED_FROM_CUR IS
  SELECT created_from
  FROM   ra_customer_trx_all
  WHERE  customer_trx_id = v_header_id;

  /*CURSOR ROW_ID_CUR IS
  SELECT rowid  FROM RA_CUSTOMER_TRX_ALL
  WHERE  customer_trx_id = v_header_id;*//*commented by rchandan for bug#4479131*/


  Cursor transaction_type_cur IS
  Select a.type
  From   RA_CUST_TRX_TYPES_ALL a, RA_CUSTOMER_TRX_ALL b
  Where  a.cust_trx_type_id = b.cust_trx_type_id
  And    b.customer_trx_id = v_header_id
  And    (a.org_id = pr_new.org_id
          OR
          (a.org_id is null and  pr_new.org_id is null )) ;  /* Modified by Ramananda for removal of SQL LITERALs */
--  And    NVL(a.org_id,0) = NVL(pr_new.org_id,0);

  /* bug 5243532. Added by Lakshmi Gopalsami
     Removed the reference to cursor set_of_books_cur
     as the SOB will never be null in base table.
  */
  BEGIN
    pv_return_code := jai_constants.successful ;
          /*------------------------------------------------------------------------------------------
         FILENAME: JA_IN_AR_CM_LINES_UPDATE_TRG.sql

         CHANGE HISTORY:
        S.No      Date          Author and Details
        1.  2001/06/22    Anuradha Parthasarathy
                                 Code commented and added to improve performance.

        2.  2003/03/12    Sriram - Bug # 2846277  File Version - 615.1
                                   In case where setup business group setup is done , inventory organization is a value 0.
                                   This was causing the trigger to return because of code comparison . Hence changed the
                                   comparison to a large value such as 999999

       3.   2004/10/21   ssumaith -  bug# 3957682 File Version - 115.1
                                   Added code to return the control when the condition = 'ARXTWMAI' and transaction_Type = 'CM'
                                   because tax defaultation is already taken care of as part of the trigger ja_in_ar_lines_update_trg

       4.  08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old
                         DB Entity as required for CASE COMPLAINCE.  Version 116.1

       5. 13-Jun-2005    File Version: 116.2
                         Ramananda for bug#4428980. Removal of SQL LITERALs is done

       6.  8-Jul-2005    File Version: 116.3
                         rchandan for bug#4479131
             The object is modified to eliminate the paddr usage.


        --------------------------------------------------------------------------------------------*/

/* --Ramananda for File.Sql.35 */
  v_header_id                := pr_old.customer_trx_id;
  v_inventory_item_id        := pr_new.inventory_item_id;
  v_item_class               :='N';
  v_uom_code                 := pr_new.uom_code;
   v_line_amount              := nvl(nvl(pr_new.quantity_credited,pr_new.quantity_invoiced) * pr_new.unit_selling_price,nvl(pr_new.extended_amount,0)); --added  nvl(pr_new.extended_amount,0) for bug#8849775
  v_old_amount               := nvl(nvl(pr_old.quantity_credited,pr_new.quantity_invoiced) * pr_old.unit_selling_price,nvl(pr_old.extended_amount,0)); --added  nvl(pr_old.extended_amount,0) for bug#8849775
 v_customer_trx_line_id     := pr_old.customer_trx_line_id;
  v_last_update_date         := pr_new.last_update_date;
  v_last_updated_by          := pr_new.last_updated_by;
  v_creation_date            := pr_new.creation_date;
  v_created_by               := pr_new.created_by;
  v_last_update_login        := pr_new.last_update_login;
/* --Ramananda for File.Sql.35 */

     OPEN  transaction_type_cur;
     FETCH transaction_type_cur INTO v_trans_type;
     CLOSE transaction_type_cur;

     IF NVL(v_trans_type,'N') not in ('CM','DM') THEN
       Return;
     END IF;

     OPEN   CREATED_FROM_CUR;
     FETCH  CREATED_FROM_CUR INTO v_created_from;
     CLOSE  CREATED_FROM_CUR;

     /* added by ssumaith - bug# 3957682 */

     if  v_created_from = 'ARXTWMAI' and NVL(v_trans_type,'N') = 'CM' then
         return;
     end if;

      /* ends here additions by ssumaith - bug# 3957682 */

     IF v_created_from in('RAXTRX','ARXREC') THEN
       RETURN;
     END IF;

     OPEN  ORG_CUR;
     FETCH ORG_CUR INTO v_organization_id;
     CLOSE ORG_CUR;
     IF NVL(v_organization_id,999999) = 999999 THEN
       OPEN  organization_cur;
       FETCH organization_cur INTO v_organization_id;
       CLOSE organization_cur;
    /* ELSE
       OPEN  ROW_ID_CUR;
       FETCH ROW_ID_CUR INTO v_row_id;
       CLOSE ROW_ID_CUR;
       jai_cmn_utils_pkg.JA_IN_SET_LOCATOR(
                                            'JAINARTX',
                                            v_row_id
                                           );*//*commented by rchandan for bug#4479131*/
     END IF;
     IF NVL(v_organization_id,999999) = 999999 THEN

       RETURN;
     END IF;
     FOR excise_cal_rec in excise_cal_cur
     LOOP
         IF excise_cal_rec.t_type IN ('Excise') THEN
           v_excise := nvl(v_excise,0) + nvl(excise_cal_rec.tax_amt,0);
         ELSIF excise_cal_rec.t_type IN ('Addl. Excise') THEN
           v_additional := nvl(v_additional,0) + nvl(excise_cal_rec.tax_amt,0);
         ELSIF excise_cal_rec.t_type IN ('Other Excise') THEN
           v_other := nvl(v_other,0) + nvl(excise_cal_rec.tax_amt,0);
         END IF;
     END LOOP;

     v_old_tax_tot  := nvl(v_excise,0) + nvl(v_other,0) + nvl(v_additional,0);

     OPEN  bind_cur;
     FETCH bind_cur INTO v_org_id, v_customer_id,v_bill_to_site_use_id ; /*Bug 8371741*/
     CLOSE bind_cur;

     /* Bug 5243532. Added by Lakshmi Gopalsami
     Removed the reference to cursor set_of_books_cur.
     */
     OPEN  HEADER_INFO_CUR;
     FETCH HEADER_INFO_CUR INTO v_books_id , c_from_currency_code, c_conversion_type,
                             c_conversion_date, c_conversion_rate, v_trx_date;
     CLOSE HEADER_INFO_CUR;

     v_line_tax_amount := nvl(v_line_amount,0);

     IF c_conversion_date is NULL THEN
       c_conversion_date := v_trx_date;
     END IF;

     v_converted_rate := jai_cmn_utils_pkg.currency_conversion (
                                        v_books_id              ,
                                        c_from_currency_code    ,
                                        c_conversion_date       ,
                                        c_conversion_type       ,
                                        c_conversion_rate
                                      );
     v_price_list_val := v_line_tax_amount;

     jai_ar_utils_pkg.recalculate_tax(
                         'AR_LINES_UPDATE'                ,
                          null                            ,
                          v_header_id                     ,
                          v_customer_trx_line_id          ,
                          v_price_list_val                ,
                          v_line_tax_amount               ,
                          v_converted_rate                ,
                          v_inventory_item_id             ,
                          NVL(pr_new.quantity_credited,0)   ,
                          pr_new.uom_code                   ,
                          NULL                            ,
                          NULL                            ,
                          v_creation_date                 ,
                          v_created_by                    ,
                          v_last_update_date              ,
                          v_last_updated_by               ,
                          v_last_update_login
                        );
     v_excise := 0;
     v_additional := 0;
     v_other := 0;


     FOR excise_cal_rec in excise_cal_cur LOOP
       IF excise_cal_rec.t_type IN ('Excise') THEN
         v_excise := nvl(v_excise,0) + excise_cal_rec.tax_amt;
       ELSIF excise_cal_rec.t_type IN ('Addl. Excise') THEN
         v_additional := nvl(v_additional,0) + excise_cal_rec.tax_amt;
       ELSIF excise_cal_rec.t_type IN ('Other Excise') THEN
         v_other := nvl(v_other,0) + excise_cal_rec.tax_amt;
       END IF;
     END LOOP;
     v_tax_tot  := v_excise + v_other + v_additional;
     v_tot_amt    := v_line_amount + v_tax_tot;

     UPDATE JAI_AR_TRXS
     SET    line_amount       = NVL(line_amount,0) + NVL(v_line_amount,0) - NVL(v_old_amount,0),
            total_amount      = NVL(total_amount,0)+ NVL(v_tot_amt,0) - nvl(v_old_amount,0) - NVL(v_old_tax_tot,0),
            tax_amount        = NVL(tax_amount,0)  + NVL(v_tax_tot,0) - NVL(v_old_tax_tot,0),
            creation_date     = v_creation_date,
            created_by        = v_created_by,
            last_update_date  = v_last_update_date,
            last_updated_by   = v_last_updated_by,
            last_update_login = v_last_update_login
     WHERE  customer_trx_id = v_header_id;

     UPDATE JAI_AR_TRX_LINES
     SET    description          = pr_new.description,
            inventory_item_id    = pr_new.inventory_item_id,
            unit_code            = pr_new.uom_code,
            quantity             = pr_new.quantity_credited,
            auto_invoice_flag    = 'N',
            tax_category_id      = v_tax_category_id,
            unit_selling_price   = pr_new.unit_selling_price,
            line_amount          = v_line_amount,
            tax_amount           = v_line_tax_amount,
            total_amount         = v_line_amount + v_line_tax_amount,
            creation_date        = v_creation_date,
            created_by           = v_created_by,
            last_update_date     = v_last_update_date,
            last_updated_by      = v_last_updated_by,
            last_update_login    = v_last_update_login
     WHERE  customer_trx_line_id = pr_old.customer_trx_line_id
     AND    customer_trx_id = v_header_id;

  END ARU_T1 ;

  /*
  REM +======================================================================+
  REM NAME          ARU_T2
  REM
  REM DESCRIPTION   Called from trigger JAI_AR_RCTLA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_AR_RCTLA_ARU_T5
  REM
  REM +======================================================================+
  */
PROCEDURE ARU_T2 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS

  v_customer_id               Number ;
  v_address_id                Number ;
  v_org_id                    Number := 0;
  v_bill_to_site_use_id       Number := 0; /*Bug 8371741*/
  v_tax_category_list         varchar2(30);
  v_tax_category_id           Number;
  v_line_no                   Number;
  v_tax_id                    Number;
  v_tax_rate                  Number;
  v_tax_amount                Number;
  v_line_tax_amount           Number := 0;
  v_new_quantity              number:=0;
  v_old_quantity              number:=0;
  v_line_amount               number := 0;
  v_old_amount                Number := 0;
  v_tax_tot                   Number := 0;
  v_tot_amt                   Number := 0;
  v_excise                    Number := 0;
  v_additional                Number := 0;
  v_other                     Number := 0;
  v_price_list                Number := 0;
  v_price_list_val            Number := 0;
  v_price_list_uom_code       Varchar2(3);
  v_conversion_rate           Number := 0;
  v_old_tax_tot               Number := 0;
  v_organization_id           Number := -1;
  v_created_from              Varchar2(30);
  v_once_completed_flag       Varchar2(1);
  c_from_currency_code        Varchar2(15);
  c_conversion_type           Varchar2(30);
  c_conversion_date           Date;
  c_conversion_rate           Number := 0;
  v_converted_rate            Number := 0;
  v_books_id                  Number;
  v_row_id                    Rowid;
  v_trx_date                  Date;
  v_trans_type                Varchar2(30);

  /* --Ramananda for File.Sql.35 */
  v_uom_code                  varchar2(3); -- := pr_new.uom_code;
  v_item_class                varchar2(30); -- :='N';
  v_inventory_item_id         Number; -- := pr_new.inventory_item_id;
  v_header_id                 Number; -- := pr_old.customer_trx_id;
  v_customer_trx_line_id      Number; -- := pr_old.customer_trx_line_id;
  v_last_update_date          Date; --   := pr_new.last_update_date;
  v_last_updated_by           Number; -- := pr_new.last_updated_by;
  v_creation_date             Date ; --  := pr_new.creation_date;
  v_created_by                Number; -- := pr_new.created_by;
  v_last_update_login         Number; -- := pr_new.last_update_login;
  /* --Ramananda for File.Sql.35 */

  /* Bind variables customer_id , org_id to be retrieved in the db trigger */
  Cursor  bind_cur IS /*Bug 8371741 - Modified to use Bill to Account*/
  SELECT  A.org_id,A.bill_to_customer_id,NVL(A.bill_to_site_use_id,0)
  FROM    RA_CUSTOMER_TRX_ALL A
  WHERE   customer_trx_id = v_header_id;

  Cursor header_info_cur IS
  SELECT set_of_books_id,  invoice_currency_code, exchange_rate_type, exchange_date,
         exchange_rate, trx_date
  FROM   RA_CUSTOMER_TRX_ALL
  WHERE  customer_trx_id = v_header_id;

  Cursor tax_id_cur(p_tax_category_id IN Number) IS
  SELECT line_no
  FROM   JAI_CMN_TAX_CTG_LINES A
  WHERE  A.tax_category_id = p_tax_category_id
  ORDER  BY line_no;

  /* to get address_id */
  /* Removed ra_site_uses_all and used hz_cust_site_uses_all for Bug# 4434287*/
  Cursor address_cur(p_ship_to_site_use_id IN Number) IS
  SELECT cust_acct_site_id address_id
  FROM   hz_cust_site_uses_all A
  WHERE  A.site_use_id = p_ship_to_site_use_id;  /* Modified by Ramananda for removal of SQL LITERALs */
--  WHERE  A.site_use_id = NVL(p_ship_to_site_use_id,0);

  CURSOR excise_cal_cur IS
  select A.tax_id, A.tax_rate, A.tax_amount tax_amt,b.tax_type t_type
  from   JAI_AR_TRX_TAX_LINES A , JAI_CMN_TAXES_ALL B
  where  link_to_cust_trx_line_id = pr_old.customer_trx_line_id
  and    A.tax_id = B.tax_id
  order  by 1;

 CURSOR  ORG_CUR IS
 SELECT  organization_id
 FROM    JAI_AR_TRX_APPS_RELS_T;/*altered by rchandan for paddr limination*/

 CURSOR organization_cur IS
 SELECT organization_id
 FROM   JAI_AR_TRXS
 WHERE  trx_number = (
                      SELECT recurred_from_trx_number
                      FROM   RA_CUSTOMER_TRX_ALL
                      WHERE  customer_trx_id = v_header_id
                     );

CURSOR CREATED_FROM_CUR IS
SELECT created_from , trx_date
FROM   ra_customer_trx_all
WHERE  customer_trx_id = v_header_id;

/*CURSOR ROW_ID_CUR IS
SELECT rowid  FROM RA_CUSTOMER_TRX_ALL
WHERE  customer_trx_id = v_header_id;*//*commented by rchandan for bug#4479131*/

CURSOR ONCE_COMPLETE_FLAG_CUR IS
SELECT once_completed_flag
FROM   JAI_AR_TRXS
WHERE  customer_trx_id = v_header_id;


Cursor transaction_type_cur IS
Select a.type
From   RA_CUST_TRX_TYPES_ALL a, RA_CUSTOMER_TRX_ALL b
Where  a.cust_trx_type_id = b.cust_trx_type_id
And    b.customer_trx_id = v_header_id
And    ( a.org_id = pr_new.org_id
          OR
   (a.org_id is NULL AND  pr_new.org_id is NULL ));  /* Modified by Ramananda for removal of SQL LITERALs */
--And    NVL(a.org_id,0) = NVL(pr_new.org_id,0);

/* bug 5243532. Added by Lakshmi Gopalsami
   Removed the reference to cursor set_of_books_cur
   as the SOB will never be null in base table.
*/

ln_vat_assessable_value JAI_AR_TRX_LINES.VAT_ASSESSABLE_VALUE%TYPE;
ld_trx_date             DATE;

  BEGIN
    pv_return_code := jai_constants.successful ;
      /*------------------------------------------------------------------------------------------
     FILENAME: JA_IN_AR_LINES_UPDATE_TRG.sql

     CHANGE HISTORY:
     S.No      Date          Author and Details
     ------------------------------------------------------------------------------------------
      1.  2001/06/22    Anuradha Parthasarathy
                        Code commented and added to improve performance.

      2.  2003/03/12    Sriram - Bug # 2846277 - File Version 615.1

                        If inventory organization is 0 , which is possible when setup business group
                        is done , it was causing the trigger to return . Hence comparing the nvl against
                        a large value such as 999999.

      3.   2004/21/10   ssumaith - bug# 3957682 - file version 115.1

                        For a manual credit memo when quantity is changed, taxes are not getting recalculated.
                        This was because this trigger was written to fire only for invoice quantity change.

                        Changes done:
                         1) Added a new when clause to ensure that trigger fires for credit memo quantity change
                         2) Added code to use the quantity_invoiced for an invoice and quantity_credited for a credit memo.

      4.  29-nov-2004  ssumaith - bug# 4037690  - File version 115.2
                        Check whether india localization is being used was done using a INR check in every trigger.
                        This check has now been moved into a new package and calls made to this package from this trigger
                        If the function jai_cmn_utils_pkg.check_jai_exists returns true it means INR is the set of books currency ,
                        Hence if this function returns FALSE , control should return.

      5.  17/03/2005   ssumaith - bug# 4245053  - File Version 115.3

                       uptake of the vat assessable value has been done in this trigger.
                       A call to the  jai_general_pkg.JA_IN_VAT_ASSESSABLE_VALUE  has been made passing the parameters
                       to get the vat assessable value to the tax calculation routines and update the vat assessable
                       value in the JAI_OM_OE_SO_LINES table.

                       This vat assessable value is sent as an additional parameter to the various procedures
                       such as jai_om_tax_pkg.recalculate_oe_taxes , jai_cmn_tax_defaultation_pkg.ja_in_calc_prec_taxes

                       Hence, its mandatory that with this object all the other objects in this patch as well as the base bug
                       need to be sent.

                       VAt assessable value , vat exemption related columns (type , refno and date) have also been copied
                       from the source line in the case of a copy order / split scenario.

                       Dependency due to this bug - Huge
                       This patch should always be accompanied by the VAT consolidated patch - 4245089


      6.  08-Jun-2005  File Version 116.1. This Object is Modified to refer to New DB Entity names in place of Old
                       DB Entity as required for CASE COMPLAINCE.

      7.  13-Jun-2005  Ramananda for bug#4428980. File Version: 116.2
                       Removal of SQL LITERALs is done

      8.  8-Jul-2005   rchandan for bug#4479131. File Version: 116.3
                       The object is modified to eliminate the paddr usage.

      9.  23-Aug-2005  Ramananda for bug# 4567935 (115 bug3671351). File Version 120.2
                       Problem:
                       -------
                       Excise taxes not getting calculated on assessable price in AR INVOICE.

                       Fix:
                       ----
                       Commented the code to calculate the assessable price and added a call
                       to the jai_om_utils_pkg.get_oe_assessable_value function to calculate the assessable price
                       correctly through various levels of defaultation

      10. 2-FEB-2006   SACSETHI for bug 5631784 , forward porting bug
                       for TCS Enchancement

11.  18-Nov-2008 JMEENA for bug#6414523
			Issue:  When selling price is changed, Excise Assessable Value should be updated correctly
			Reason: Excise Assessable value is derived but not updated in the table ja_in_ra_customer_trx_lines
                               Fix:    Modifed procedure ARU_T2. Added column assessable_value in the update statement of table JAI_AR_TRX_LINES.
12.  20-JUL-2009 JMEENA For bug#8441899
				Added column vat_assessable_value in the update of table JAI_AR_TRX_LINES to update the New VAT Assessable
				value in the table if Quantity or UOM is changed.


Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Current Version    Current Bug    Dependent           Files                Version   Author   Date          Remarks
Of File                           On Bug/Patchset    Dependent On

ja_in_ar_lines_update_trg.sql
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
115.2              4037690        IN60105D2          ja_in_util_pkg_s.sql  115.0     ssumaith 29-Nov-2004  Call to this function.
                                                     ja_in_util_pkg_s.sql  115.0     ssumaith

115.3              4245053        IN60106 +                                          ssumaith             Service Tax and VAT Infrastructure are created
                                  4146708 +                                                               based on the bugs - 4146708 and 4545089 respectively.
                                  4245089

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/


  /* --Ramananda for File.Sql.35 */
  v_header_id                 := pr_old.customer_trx_id;
  v_inventory_item_id         := pr_new.inventory_item_id;
  v_item_class                := 'N';
  v_uom_code                  := pr_new.uom_code;
  v_customer_trx_line_id      := pr_old.customer_trx_line_id;
  v_last_update_date          := pr_new.last_update_date;
  v_last_updated_by           := pr_new.last_updated_by;
  v_creation_date             := pr_new.creation_date;
  v_created_by                :=  pr_new.created_by;
  v_last_update_login         := pr_new.last_update_login;
/* --Ramananda for File.Sql.35 */

  /*The following code has added - ssumaith - bug# 4037690*/

  --If jai_cmn_utils_pkg.check_jai_exists(P_CALLING_OBJECT => 'JA_IN_AR_LINES_UPDATE_TRG',  P_ORG_ID => pr_new.org_id) = false then
  --      return;
  --end if;

  OPEN  transaction_type_cur;
  FETCH transaction_type_cur INTO v_trans_type;
  CLOSE transaction_type_cur;
  IF NVL(v_trans_type,'N') not in ( 'INV','CM') THEN -- added the CM into the IN by ssumaith - bug# 3957682
    Return;
  END IF;

  /*  ssumaith - bug# 3957682 */
  if NVL(v_trans_type,'N') = 'INV' then
     v_new_quantity := pr_new.quantity_invoiced;
     v_old_quantity := pr_old.quantity_invoiced;
  elsif NVL(v_trans_type,'N') = 'CM' then
     v_new_quantity := pr_new.quantity_credited;
     v_old_quantity := pr_old.quantity_credited;
  end if;
    v_line_amount     := nvl(v_new_quantity * pr_new.unit_selling_price,nvl(pr_new.extended_amount,0)); --added  nvl(pr_new.extended_amount,0) for bug#8849775
  v_old_amount      := nvl(v_old_quantity * pr_old.unit_selling_price,nvl(pr_old.extended_amount,0)); --added  nvl(pr_old.extended_amount,0) for bug#8849775

  /*  ssumaith - bug# 3957682 */


  OPEN   ONCE_COMPLETE_FLAG_CUR;
  FETCH  ONCE_COMPLETE_FLAG_CUR INTO v_once_completed_flag;
  CLOSE  ONCE_COMPLETE_FLAG_CUR;
  IF NVL(v_once_completed_flag,'N') = 'Y' THEN
    RETURN;
  END IF;

  OPEN   CREATED_FROM_CUR;
  FETCH  CREATED_FROM_CUR INTO v_created_from, ld_trx_date;
  CLOSE  CREATED_FROM_CUR;
  IF v_created_from in('RAXTRX','ARXREC') THEN
     RETURN;
  END IF;

  OPEN  ORG_CUR;
  FETCH ORG_CUR INTO v_organization_id;
  CLOSE ORG_CUR;
  IF NVL(v_organization_id,999999) = 999999 THEN
     OPEN  organization_cur;
     FETCH organization_cur INTO v_organization_id;
     CLOSE organization_cur;
  /*ELSE
     OPEN  ROW_ID_CUR;
     FETCH ROW_ID_CUR INTO v_row_id;
     CLOSE ROW_ID_CUR;
     jai_cmn_utils_pkg.JA_IN_SET_LOCATOR('JAINARTX',v_row_id);*//*commented by rchandan for bug#4479131*/
  END IF;
  IF NVL(v_organization_id,999999) = 999999 THEN
     RETURN;
  END IF;
  FOR excise_cal_rec in excise_cal_cur
  LOOP
       IF excise_cal_rec.t_type IN ('Excise') THEN
          v_excise := nvl(v_excise,0) + nvl(excise_cal_rec.tax_amt,0);
       ELSIF excise_cal_rec.t_type IN ('Addl. Excise') THEN
          v_additional := nvl(v_additional,0) + nvl(excise_cal_rec.tax_amt,0);
       ELSIF excise_cal_rec.t_type IN ('Other Excise') THEN
          v_other := nvl(v_other,0) + nvl(excise_cal_rec.tax_amt,0);
       END IF;
  END LOOP;

  v_old_tax_tot  := nvl(v_excise,0) + nvl(v_other,0) + nvl(v_additional,0);

  OPEN  bind_cur;
  FETCH bind_cur INTO v_org_id, v_customer_id,v_bill_to_site_use_id ; /*Bug 8371741*/
  CLOSE bind_cur;

  /* Bug 5243532. Added by Lakshmi Gopalsami
     Removed the reference to cursor set_of_books_cur.
  */

  OPEN  HEADER_INFO_CUR;
  FETCH HEADER_INFO_CUR INTO v_books_id       , c_from_currency_code, c_conversion_type,
                             c_conversion_date, c_conversion_rate   , v_trx_date;
  CLOSE HEADER_INFO_CUR;

  OPEN address_cur(v_bill_to_site_use_id); /*Bug 8371741*/
  FETCH address_cur INTO v_address_id;
  CLOSE address_cur;

  IF v_customer_id IS NOT NULL AND v_address_id IS NOT NULL THEN
     jai_cmn_tax_defaultation_pkg.ja_in_cust_default_taxes(
                                            v_organization_id ,
                                            v_customer_id ,
                                            v_bill_to_site_use_id , /*Bug 8371741*/
                                            v_inventory_item_id ,
                                            v_header_id ,
                                            v_customer_trx_line_id,
                                            v_tax_category_id
                                           );
  ELSE
     jai_cmn_tax_defaultation_pkg.ja_in_org_default_taxes(
                                           v_organization_id ,
                                           v_inventory_item_id ,
                                           v_tax_category_id
                                          );
  END IF;
  --IF v_tax_category_id IS NOT NULL THEN --commented for bug#6012465

  /*
  ||Added by Ramananda for bug #4567935 (115 bug3671351) , Start
  ||Instead of deriving the assessable valeu in this trigger,
  ||the same has been now shifted to the function jai_om_utils_pkg.get_oe_assessable_value
  ||The function gets the assessable value based on 5 level defaultation
  ||logic.Currently the assessable value was being fetched only from the so_price_list_lines
  */
   v_price_list := jai_om_utils_pkg.get_oe_assessable_value
                         (
                            p_customer_id         => v_customer_id,
                            p_ship_to_site_use_id => v_bill_to_site_use_id, /*Bug 8371741*/
                            p_inventory_item_id   => v_inventory_item_id,
                            p_uom_code            => v_uom_code,
                            p_default_price       => pr_new.unit_selling_price,
                            p_ass_value_date      => ld_trx_date,
                            /* Bug 5096787. Added by Lakshmi Gopalsami */
                            p_sob_id              => v_books_id,
                            p_curr_conv_code      => c_conversion_type,
                            p_conv_rate           => c_conversion_rate
                            /*  Later need to derive for p_conv_rate using ja_curr_conv
                               as part of forwarding 11i code bug 4446346 */
                         );
   v_price_list_val := v_new_quantity * NVL(v_price_list,0);
  /*
  ||Added by Ramananda for bug #4567935 (115 bug3671351) , End
  */

  /* Bug# 4245053 - following function call added by ssumaith */
  ln_vat_assessable_value :=  jai_general_pkg.ja_in_vat_assessable_value
                                       (
                                        p_party_id           => v_customer_id          ,
                                        p_party_site_id      => v_bill_to_site_use_id  , /*Bug 8371741*/
                                        p_inventory_item_id  => v_inventory_item_id    ,
                                        p_uom_code           => v_uom_code             ,
                                        p_default_price      => pr_new.unit_selling_price,
                                        p_ass_value_date     => ld_trx_date            ,
                                        p_party_type         => 'C'
                                       );

  ln_vat_assessable_value := nvl(ln_vat_assessable_value,0) * v_new_quantity;
  /* ends here - additions by ssumaith - bug# 4245053*/

  v_line_tax_amount := nvl(v_line_amount,0);

  /* Bug# 4245053 - added a parameter and passing the value here */
  jai_ar_utils_pkg.recalculate_tax('AR_LINES_UPDATE' ,
                       v_tax_category_id ,
                       v_header_id,
                       v_customer_trx_line_id,
                       v_price_list_val ,
                       v_line_tax_amount ,
                       v_converted_rate,
                       v_inventory_item_id ,
                       NVL(v_new_quantity,0),
                       pr_new.uom_code ,
                       NULL ,
                       NULL ,
                       v_creation_date ,
                       v_created_by ,
                       v_last_update_date ,
                       v_last_updated_by ,
                       v_last_update_login,
                       ln_vat_assessable_value /* added by ssumaith - bug# 4245053*/
                     );
  --END IF; --commented for bug#6012465
    v_excise := 0;
    v_additional := 0;
    v_other := 0;
      /*  Update The Localizaed Header Table with the Line amount, Tax amount, Total Amount */

    FOR excise_cal_rec in excise_cal_cur
    LOOP
         IF excise_cal_rec.t_type IN ('Excise') THEN
            v_excise := nvl(v_excise,0) + excise_cal_rec.tax_amt;
         ELSIF excise_cal_rec.t_type IN ('Addl. Excise') THEN
            v_additional := nvl(v_additional,0) + excise_cal_rec.tax_amt;
         ELSIF excise_cal_rec.t_type IN ('Other Excise') THEN
            v_other := nvl(v_other,0) + excise_cal_rec.tax_amt;
         END IF;
    END LOOP;

    v_tax_tot    := v_excise + v_other + v_additional;
    v_tot_amt    := v_line_amount + v_tax_tot;

    UPDATE JAI_AR_TRXS
    SET    line_amount         = NVL(line_amount,0) + NVL(v_line_amount,0) - NVL(v_old_amount,0),
           total_amount        = NVL(total_amount,0)+ NVL(v_tot_amt,0) - nvl(v_old_amount,0) - NVL(v_old_tax_tot,0),
           tax_amount          = NVL(tax_amount,0)  + NVL(v_tax_tot,0) - NVL(v_old_tax_tot,0),
           creation_date       = v_creation_date,
           created_by          = v_created_by,
           last_update_date    = v_last_update_date,
           last_updated_by     = v_last_updated_by,
           last_update_login   = v_last_update_login
   WHERE  customer_trx_id      = v_header_id;

   UPDATE JAI_AR_TRX_LINES
   SET    description          = pr_new.description,
          inventory_item_id    = pr_new.inventory_item_id,
          unit_code            = pr_new.uom_code,
          quantity             = v_new_quantity,
          auto_invoice_flag    = 'N',
          tax_category_id      = v_tax_category_id,
          unit_selling_price   = pr_new.unit_selling_price,
          line_amount          = v_line_amount,
          tax_amount           = v_line_tax_amount,
          total_amount         = v_line_amount + v_line_tax_amount,
          creation_date        = v_creation_date,
          created_by           = v_created_by,
          last_update_date     = v_last_update_date,
          last_updated_by      = v_last_updated_by,
          last_update_login    = v_last_update_login,
		  assessable_value     = v_price_list ,           -- Added by JMEENA for Bug#6414523( FP 6318850)
	vat_assessable_value = ln_vat_assessable_value --Added by JMEENA for bug#8441899
   WHERE  customer_trx_line_id = pr_old.customer_trx_line_id
   AND    customer_trx_id      = v_header_id;
   /* Added an exception block by Ramananda for bug#4570303 */
   EXCEPTION
     WHEN OTHERS THEN
       Pv_return_code     :=  jai_constants.unexpected_error;
       Pv_return_message  := 'Encountered an error in JAI_AR_RCTLA_TRIGGER_PKG.ARU_T2  '  || substr(sqlerrm,1,1900);
  END ARU_T2 ;

    /* following procedure added by cbabu for bug#6012570 (5876390) */
  procedure import_projects_taxes
          (       r_new         in         ra_customer_trx_lines_all%rowtype
              ,   r_old         in         ra_customer_trx_lines_all%rowtype
              ,   pv_action     in         varchar2
              ,   pv_err_msg    OUT NOCOPY varchar2
              ,   pv_err_flg    OUT NOCOPY varchar2
          )
  is

    cursor c_draft_inv_line_taxes( cpn_draft_invoice_line_id in number ) is
      select *
      from jai_cmn_document_taxes
      where source_doc_type = jai_pa_billing_pkg.gv_source_projects
      and source_doc_line_id = cpn_draft_invoice_line_id
      order by tax_line_no;
    -- 6369471
    -- cursor to get transaction type
    CURSOR c_transaction_type IS
    SELECT A.TYPE
    FROM   RA_CUST_TRX_TYPES_ALL A, RA_CUSTOMER_TRX_ALL b
    WHERE  A.cust_trx_type_id = b.cust_trx_type_id
    AND    b.customer_trx_id = r_new.customer_trx_id
    AND    NVL(A.org_id,0) = NVL(r_new.org_id,0);

    r_trx_type  c_transaction_type%rowtype; --Bug 6369471
    ln_quantity                jai_ar_trx_lines.quantity%type; -- Bug 6369471


    cursor c_ra_customer_trx is
      select trx_number, trx_date, batch_source_id, set_of_books_id
           , primary_salesrep_id ,invoice_currency_code, exchange_rate_type
           , exchange_date, exchange_rate
           , legal_entity_id -- 6012570
      from ra_customer_trx_all
      where customer_trx_id = r_new.customer_trx_id;
    r_ra_customer_trx       c_ra_customer_trx%rowtype;

    cursor c_jai_ra_customer_trx is
      select customer_trx_id
      from jai_ar_trxs
      where customer_trx_id = r_new.customer_trx_id;
    r_jai_ra_customer_trx       c_jai_ra_customer_trx%rowtype;

    cursor c_jai_ra_customer_trx_line is
      select customer_trx_line_id
      from jai_ar_trx_lines
      where customer_trx_line_id = r_new.customer_trx_line_id;
    r_jai_ra_customer_trx_line    c_jai_ra_customer_trx_line%rowtype;

    cursor c_get_project_id(cp_project_code in varchar2) is
      select project_id
      from pa_projects_all
      where segment1 = cp_project_code;

    cursor c_jai_pa_draft_invoice(cpn_project_id in number, cpn_draft_invoice_num in number) is
      select draft_invoice_id, organization_id, location_id
        , excise_register_type
        , excise_invoice_no
        , excise_invoice_date
        , vat_invoice_no
        , vat_invoice_date
      from jai_pa_draft_invoices
      where project_id = cpn_project_id
      and draft_invoice_num = cpn_draft_invoice_num;

    r_jai_pa_draft_invoice      c_jai_pa_draft_invoice%rowtype;

    cursor c_jai_pa_draft_inv_line(
        cpn_draft_invoice_id in number,
        cpn_line_num in number
    ) is
      select
          draft_invoice_id
        , draft_invoice_line_id
        , tax_category_id
        , service_type_code
      from jai_pa_draft_invoice_lines
      where draft_invoice_id = cpn_draft_invoice_id
      and line_num = cpn_line_num;

    r_jai_pa_draft_inv_line    c_jai_pa_draft_inv_line%rowtype;


    ln_line_customer_trx_line_id    ra_customer_trx_lines_all.customer_trx_line_id%type;

    ln_project_id           pa_draft_invoices_all.project_id%type;
    ln_draft_invoice_num    pa_draft_invoices_all.draft_invoice_num%type;
    ln_line_num             pa_draft_invoice_items.line_num%type;
    ln_line_amount          number;
    ln_tax_amount           number;
    ln_func_tax_amount      number;
    ln_base_tax_amount      number;

    ln_line_tax_amt            number;


  begin
    /* 6369471
       If transaction is Credit memo then quantity invoiced should be considered, otherwise Quantity Invoice is fine.
    */
    open  c_transaction_type;
    fetch c_transaction_type into r_trx_type;
    close c_transaction_type;

    if nvl(r_trx_type.type ,'N') = 'CM' then
      ln_quantity := r_new.quantity_credited;
    else
      ln_quantity := r_new.quantity_invoiced;
    end if;
    /* End 6369471 */

    ln_line_customer_trx_line_id := r_new.customer_trx_line_id;
    ln_line_amount    := round( nvl(ln_quantity * r_new.unit_selling_price, 0), 2); -- Bug 6369471

    open c_get_project_id(r_new.interface_line_attribute1);
    fetch c_get_project_id into ln_project_id;
    close c_get_project_id;

    ln_draft_invoice_num  := to_number(r_new.interface_line_attribute2);
    ln_line_num           := to_number(r_new.interface_line_attribute6);

    open c_jai_pa_draft_invoice(ln_project_id, ln_draft_invoice_num);
    fetch c_jai_pa_draft_invoice into r_jai_pa_draft_invoice;
    close c_jai_pa_draft_invoice;

    if r_jai_pa_draft_invoice.draft_invoice_id is null then
      /* no data exists in JAI_PA tables, so no need to Import taxes from PA to AR  */
      return;
    end if;

    open c_jai_pa_draft_inv_line(r_jai_pa_draft_invoice.draft_invoice_id, ln_line_num);
    fetch c_jai_pa_draft_inv_line into r_jai_pa_draft_inv_line;
    close c_jai_pa_draft_inv_line;

    open c_ra_customer_trx;
    fetch c_ra_customer_trx into r_ra_customer_trx;
    close c_ra_customer_trx;

    open c_jai_ra_customer_trx;
    fetch c_jai_ra_customer_trx into r_jai_ra_customer_trx;
    close c_jai_ra_customer_trx;

    if r_jai_ra_customer_trx.customer_trx_id is null then
      /* insert into jai_ar_trxs */
      insert into jai_ar_trxs(
            customer_trx_id
          , organization_id
          , location_id
          , trx_number
          , update_rg_flag
          , update_rg23d_flag
          , once_completed_flag
          , batch_source_id
          , set_of_books_id
          , primary_salesrep_id
          , invoice_currency_code
          , exchange_rate_type
          , exchange_date
          , exchange_rate
          , creation_date
          , created_by
          , last_update_date
          , last_updated_by
          , last_update_login
          , vat_invoice_no
          , vat_invoice_date
          , legal_entity_id  -- 6012570
      ) values (
            r_new.customer_trx_id
          , r_jai_pa_draft_invoice.organization_id
          , r_jai_pa_draft_invoice.location_id
          , r_ra_customer_trx.trx_number
          , 'Y'
          , 'Y'
          , 'N'
          , r_ra_customer_trx.batch_source_id
          , r_ra_customer_trx.set_of_books_id
          , r_ra_customer_trx.primary_salesrep_id
          , r_ra_customer_trx.invoice_currency_code
          , r_ra_customer_trx.exchange_rate_type
          , r_ra_customer_trx.exchange_date
          , r_ra_customer_trx.exchange_rate
          , sysdate
          , r_new.created_by
          , sysdate
          , r_new.last_updated_by
          , r_new.last_update_login
          , r_jai_pa_draft_invoice.vat_invoice_no
          , r_jai_pa_draft_invoice.vat_invoice_date
          , r_ra_customer_trx.legal_entity_id -- 6012570
      );

    end if;

    /* insert into ja_in_ra_cust_trx_tax_lines */
    for tax_rec in c_draft_inv_line_taxes(r_jai_pa_draft_inv_line.draft_invoice_line_id)  loop

      ln_tax_amount         := round(tax_rec.tax_amt,2);
      ln_func_tax_amount    := round(tax_rec.func_tax_amt,2);
      if tax_rec.tax_rate <> 0 then
        ln_base_tax_amount  := tax_rec.tax_amt * 100/ tax_rec.tax_rate;
      else
        ln_base_tax_amount  := ln_tax_amount;
      end if;

      insert into jai_ar_trx_tax_lines(
           tax_line_no                   ,
           customer_trx_line_id          ,
           link_to_cust_trx_line_id      ,
           precedence_1                  ,
           precedence_2                  ,
           precedence_3                  ,
           precedence_4                  ,
           precedence_5                  ,
           precedence_6                  ,
           precedence_7                  ,
           precedence_8                  ,
           precedence_9                  ,
           precedence_10                 ,
           tax_id                        ,
           tax_rate                      ,
           qty_rate                      ,
           uom                           ,
           tax_amount                    ,
           func_tax_amount               ,
           base_tax_amount               ,
           creation_date                 ,
           created_by                    ,
           last_update_date              ,
           last_updated_by               ,
           last_update_login
      ) values(
           tax_rec.tax_line_no                ,
           ra_customer_trx_lines_s.nextval    ,
           ln_line_customer_trx_line_id       ,
           tax_rec.precedence_1               ,
           tax_rec.precedence_2               ,
           tax_rec.precedence_3               ,
           tax_rec.precedence_4               ,
           tax_rec.precedence_5               ,
           tax_rec.precedence_6               ,
           tax_rec.precedence_7               ,
           tax_rec.precedence_8               ,
           tax_rec.precedence_9               ,
           tax_rec.precedence_10              ,
           tax_rec.tax_id                     ,
           tax_rec.tax_rate                   ,
           tax_rec.qty_rate                   ,
           tax_rec.uom                        ,
           ln_tax_amount                ,
           ln_func_tax_amount             ,
           ln_base_tax_amount,    /* Complete this round(v_base_tax_amount,2)         , */
           sysdate                    ,
           r_new.created_by,
           sysdate                 ,
           r_new.last_updated_by                  ,
           r_new.last_update_login
      );

      ln_line_tax_amt := nvl(ln_line_tax_amt,0) + ln_tax_amount;

    end loop;

    /* insert into jai_ar_trx_lines */
    open c_jai_ra_customer_trx_line;
    fetch c_jai_ra_customer_trx_line into r_jai_ra_customer_trx_line;
    close c_jai_ra_customer_trx_line;

    if r_jai_ra_customer_trx_line.customer_trx_line_id is null then
      INSERT INTO jai_ar_trx_lines (
             customer_trx_line_id                         ,
             line_number                                  ,
             customer_trx_id                              ,
             description                                  ,
             payment_register                             ,
             excise_invoice_no                            ,
             preprinted_excise_inv_no                     ,
             excise_invoice_date                          ,
             inventory_item_id                            ,
             unit_code                                    ,
             quantity                                     ,
             tax_category_id                              ,
             auto_invoice_flag                            ,
             unit_selling_price                           ,
             line_amount                                  ,
             tax_amount                                   ,
             total_amount                                 ,
             assessable_value                             ,
             creation_date                                ,
             created_by                                   ,
             last_update_date                             ,
             last_updated_by                              ,
             last_update_login                            ,
             excise_exempt_type                           ,
             excise_exempt_refno                          ,
             excise_exempt_date                           ,
             ar3_form_no                                  ,
             ar3_form_date                                ,
             vat_exemption_flag                           ,
             vat_exemption_type                           ,
             vat_exemption_date                           ,
             vat_exemption_refno                          ,
             vat_assessable_value             ,
             service_type_code
      ) VALUES  (
             ln_line_customer_trx_line_id                   ,
             r_new.line_number                              ,
             r_new.customer_trx_id                          ,
             r_new.description                              ,
             r_jai_pa_draft_invoice.excise_register_type    ,
             r_jai_pa_draft_invoice.excise_invoice_no       ,
             null                                           ,       -- v_preprinted_excise_inv_no                   ,
             r_jai_pa_draft_invoice.excise_invoice_date     ,
             r_new.inventory_item_id                        ,
             r_new.uom_code                                 ,
             ln_quantity                                    ,  -- 6369471, using ln_quanity instead of r_new.quantity_inoviced
             r_jai_pa_draft_inv_line.tax_category_id    ,
             'Y'                                            ,
             r_new.unit_selling_price                       ,
             ln_line_amount                                 ,
             ln_line_tax_amt                                ,
             (ln_line_amount + ln_line_tax_amt)             ,
             null                                           ,       -- v_assessable_value                           ,
             sysdate                                        ,
             r_new.created_by                               ,
             sysdate                                        ,
             r_new.last_updated_by                          ,
             r_new.last_update_login                        ,
             null                                           ,       -- v_excise_exempt_type                         ,
             null                                           ,       -- v_excise_exempt_refno                        ,
             null                                           ,       -- v_excise_exempt_date                         ,
             null                                           ,       -- v_ar3_form_no                                ,
             null                                           ,       -- v_ar3_form_date                              ,
             null                                           ,       -- lv_vat_exemption_flag                        ,
             null                                           ,       -- lv_vat_exemption_type                        ,
             null                                           ,       -- lv_vat_exemption_date                        ,
             null                                           ,       -- lv_vat_exemption_refno                       ,
             null                                           ,        -- ln_vat_assessable_value
             r_jai_pa_draft_inv_line.service_type_code
      );

      update  jai_ar_trxs
      set     tax_amount   = nvl(tax_amount,0) + round( nvl(ln_line_tax_amt,0), 2)
              , line_amount  = nvl(line_amount,0) + round( nvl(ln_line_amount,0), 2)
              , total_amount = nvl(total_amount,0) + round(nvl(ln_line_amount,0) + nvl(ln_line_tax_amt,0), 2)
              , last_updated_by = r_new.last_updated_by
              , last_update_date = sysdate
              , last_update_login = r_new.last_update_login
      where   customer_trx_id = r_new.customer_trx_id;

    end if;

  end import_projects_taxes;

  /*following function added for Projects Billing Implementation. bug#6012570 (5876390) */
  function is_this_projects_context(
    pv_context          IN  varchar2
  ) return boolean is

    lb_return_value boolean;

  begin

    if upper(pv_context) in ('PROJECTS INVOICES', 'PA INVOICES' ) then
                                       /* Commented the following for bug# 6493501
                                      To support interproject or intercompany billing in future
                                     -- 'PA INTERNAL INVOICES' */
      lb_return_value := true;
    else
      lb_return_value := false;
    end if;

    return lb_return_value;

  end is_this_projects_context;



  /* Function to get the service_type
  added by csahoo for bug#5879769*/

  FUNCTION get_service_type(pn_party_id      NUMBER,
                            pn_party_site_id NUMBER,
                            pv_party_type    VARCHAR2) return VARCHAR2
  IS
  v_service_type VARCHAR2(30);
  ln_address_id   NUMBER;

  CURSOR c_get_address IS
  SELECT hzcas.cust_acct_site_id
    FROM hz_cust_site_uses_all         hzcsu ,
         hz_cust_acct_sites_all        hzcas
   WHERE hzcas.cust_acct_site_id   =   hzcsu.cust_acct_site_id
     AND hzcsu.site_use_id         =   pn_party_site_id
     AND hzcas.cust_account_id     =   pn_party_id ;

  CURSOR cur_get_ser_type_customer(pn_cust_id NUMBER,pn_address_id NUMBER) IS
  SELECT service_type_code
    FROM JAI_CMN_CUS_ADDRESSES
   WHERE customer_id  = pn_cust_id
     AND address_id   = pn_address_id;

  CURSOR cur_get_ser_type_vendor(
                                   cp_vendor_id IN Po_Headers_All.vendor_id%type,
                                   cp_vendor_site_id IN Po_Headers_All.vendor_site_id%type
                                 )
      IS
  SELECT service_type_code
    FROM JAI_CMN_VENDOR_SITES
   WHERE vendor_id      = cp_vendor_id
     AND vendor_site_id = cp_vendor_site_id;

  /*
  ||This function is used to retreive the service type based on the customer id and address id
  ||passed as parameters.
  */

  BEGIN
    IF pv_party_type = jai_constants.party_type_customer THEN

      OPEN   c_get_address;
      FETCH  c_get_address INTO ln_address_id;
      CLOSE  c_get_address;

      OPEN cur_get_ser_type_customer(pn_party_id,ln_address_id);
      FETCH cur_get_ser_type_customer INTO v_service_type;
      CLOSE cur_get_ser_type_customer;

      IF v_service_type is null THEN

        OPEN cur_get_ser_type_customer(pn_party_id,0);
        FETCH cur_get_ser_type_customer INTO v_service_type;
        CLOSE cur_get_ser_type_customer;

      END IF;

    ELSIF pv_party_type = jai_constants.party_type_vendor THEN

      OPEN  cur_get_ser_type_vendor(pn_party_id, pn_party_site_id);
      FETCH cur_get_ser_type_vendor INTO v_service_type;
      CLOSE cur_get_ser_type_vendor;

      IF v_service_type IS NULL THEN
        OPEN cur_get_ser_type_vendor(pn_party_id, 0);
        FETCH cur_get_ser_type_vendor INTO v_service_type;
        CLOSE cur_get_ser_type_vendor;
      END IF;

    END IF;

    return v_service_type;

END;

END JAI_AR_RCTLA_TRIGGER_PKG;

/
