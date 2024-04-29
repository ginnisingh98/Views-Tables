--------------------------------------------------------
--  DDL for Package Body JAI_JAR_TL_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_JAR_TL_TRIGGER_PKG" AS
/* $Header: jai_jar_tl_t.plb 120.22.12010000.12 2010/05/19 02:09:35 boboli ship $ */

/*
  REM +======================================================================+
  REM NAME          ARI_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_JAR_TL_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_JAR_TL_ARI_T1
  REM
  REM +======================================================================+
*/
  PROCEDURE ARI_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
    v_line_no             NUMBER := 0;
  v_books_id            NUMBER := 1;
  v_salesrep_id         NUMBER;
  v_line_type           VARCHAR2(30);
  v_vat_tax             NUMBER;
  v_ccid                NUMBER;
  v_cust_trx_line_id        RA_CUSTOMER_TRX_LINES_ALL.customer_trx_line_id%TYPE;
  /* commented by rallamse bug#4479131 PADDR Elimination
  v_paddr               v$session.paddr%TYPE;
  */
  v_customer_trx_line_id    NUMBER; -- := pr_new.customer_trx_line_id; --Ramananda for File.Sql.35
  v_customer_trx_id         NUMBER; -- := pr_new.customer_trx_id;      --Ramananda for File.Sql.35
  v_created_from            VARCHAR2(30);
  c_from_currency_code      VARCHAR2(15);
  c_conversion_type     VARCHAR2(30);
  c_conversion_date     DATE;
  c_conversion_rate     NUMBER := 0;
  v_converted_rate      NUMBER := 1;
  req_id                NUMBER;
  result                BOOLEAN;
  v_organization_id     NUMBER ;
  v_location_id         NUMBER ;
  v_batch_source_id     NUMBER ;
  v_register_code       VARCHAR2(50);
  v_order_number        VARCHAR2(30);
  v_order_type          ra_customer_trx_all.interface_header_attribute2%type;
  v_org_id              NUMBER(15); -- added by sriram because the orgid value is not going into temp_lines_insert table

  --v_ORDER_PRICE_EXCISE_INCLUSIVE JAI_CMN_INVENTORY_ORGS.ORDER_PRICE_EXCISE_INCLUSIVE%type;  ---- Deleted by Jia Li for Tax inclusive Computations on 2007/11/22, TD18

  ln_inv_curr_precision     NUMBER;  /* added by CSahoo - bug# 5364120*/
  --commented by kunkumar for bug#6066813
  lv_intf_hdr_ctx   ra_customer_trx_all.interface_header_context%type; /*  bug# 6012570 (5876390)       */

  /* added by CSahoo - bug# 5364120*/
  CURSOR c_inv_curr_precision(cp_currency_code varchar2)
  IS
  SELECT  NVL(minimum_accountable_unit,NVL(precision,2)) curr_precision
    FROM  fnd_currencies
   WHERE   currency_code = cp_currency_code;




  CURSOR tax_type_cur
  IS
  SELECT
            a.tax_id                    taxid           ,
            a.tax_rate                                  ,
            a.uom                       uom             ,
            a.tax_amount                tax_amt         ,
            b.tax_type                  t_type          ,
            a.customer_trx_line_id      line_id         ,
            a.tax_line_no               tax_line_no     -- added by sriram - 10/4/2003 - bug # 2769439
  FROM
            JAI_AR_TRX_TAX_LINES a ,
            JAI_CMN_TAXES_ALL             b
  WHERE
            link_to_cust_trx_line_id = v_customer_trx_line_id   AND
            a.tax_id                 = b.tax_id
    AND     NVL(b.inclusive_tax_flag,'N') = 'N'   --Added by Jia Li for Tax inclusive Computations on 2007/11/22, TD11
   ORDER BY
            1;

 /* Bug 4535701. Added by Lakshmi gopalsami
  * Commented the following cursor as part of PADDR elimiation
  CURSOR PADDR_CUR IS
  SELECT A.paddr
  FROM JAI_CMN_LOCATORS_T A , v$session s
  WHERE A.PADDR = s.paddr
  AND s.audsid = USERENV('SESSIONID');
 */
  CURSOR HEADER_INFO_CUR IS
  SELECT set_of_books_id, primary_salesrep_id, org_id , invoice_currency_code, exchange_rate_type,
      exchange_date, exchange_rate
        --commented by kunkumar for Bug#6066813
        ,interface_header_context  /*  6012570 (5876390)  */
  FROM   RA_CUSTOMER_TRX_ALL
  WHERE  customer_trx_id = v_customer_trx_id;

  --Commented for bug#4468353
  /*
  CURSOR VAT_TAX_CUR(cp_tax_code  AR_VAT_TAX_ALL.tax_code%type) IS
  SELECT MAX(vat_tax_id)
  FROM   AR_VAT_TAX_ALL
  WHERE  tax_code = cp_tax_code ;
  */

 /* Added by Ramananda for bug#4468353 , start   */
  CURSOR ORG_CUR IS
  SELECT ORG_ID
  FROM   RA_CUSTOMER_TRX_ALL
  WHERE  CUSTOMER_TRX_ID = pr_new.customer_trx_id;

  lv_tax_regime_code             zx_rates_b.tax_regime_code%type ;
  ln_party_tax_profile_id        zx_party_tax_profile.party_tax_profile_id%type ;
  ln_tax_rate_id                 zx_rates_b.tax_rate_id%type ;
  /* Added by Ramananda for bug#4468353 , end     */


  CURSOR TAX_CCID_CUR(p_tax_id IN NUMBER) IS
  SELECT tax_account_id
  FROM   JAI_CMN_TAXES_ALL B
  WHERE  B.tax_id = p_tax_id ;

  CURSOR CREATED_FROM_CUR IS
  SELECT created_from, interface_header_attribute1,interface_header_attribute2
  FROM   ra_customer_trx_all
  WHERE  customer_trx_id = v_customer_trx_id;

   CURSOR SO_AR_HDR_INFO IS
  SELECT organization_id, location_id, batch_source_id /*uncommented for bug#8775345*/
 -- SELECT  batch_source_id
  FROM   JAI_AR_TRXS
  WHERE  Customer_Trx_ID = v_customer_trx_id;


    --cursor added for bug 8775345
 CURSOR get_batch_src_id IS
 SELECT  batch_source_id
  FROM   JAI_AR_TRXS
  WHERE  Customer_Trx_ID = v_customer_trx_id;


  --start additions for bug#7661892
  Cursor c_get_orgn
  is
  select warehouse_id,interface_line_attribute6
  from ra_interfacE_lines_all
  where interfacE_line_context= 'ORDER ENTRY'
  and line_type='LINE'
  and interface_line_id=v_customer_trx_line_id;

  --added for bug#9151886
  CURSOR  c_get_orgn_project
  IS
  SELECT  a.organization_id, a.location_id
  FROM    jai_pa_draft_invoices a, ra_interface_lines_all b, pa_projects_all c
  WHERE   b.interface_line_context = 'PROJECTS INVOICES'
  AND     b.line_type = 'LINE'
  AND     b.interface_line_attribute1 = c.segment1
  AND     c.project_id = a.project_id
  AND     a.draft_invoice_num = b.interface_line_attribute2
  AND     interface_line_id=v_customer_trx_line_id;

  Cursor c_get_loc(cp_order_line_id varchar2)
is
select location_id
 from jai_om_wsh_lines_all
 where order_line_id=cp_order_line_id;

 ln_order_line_id varchar2(30);
 --end additions for bug#7661892


  CURSOR register_code_cur(p_org_id IN NUMBER,  p_loc_id IN NUMBER,
                                      p_batch_source_id  IN NUMBER)  IS
  SELECT register_code
  FROM   JAI_OM_OE_BOND_REG_HDRS
  WHERE  organization_id = p_org_id AND location_id = p_loc_id   AND
       register_id IN (SELECT register_id
                     FROM   JAI_OM_OE_BOND_REG_DTLS
                 WHERE  order_type_id = p_batch_source_id AND order_flag = 'N');

  /*  Bug 4938350. Added by Lakshmi Gopalsami
      Removed the sub-query and added oe_transaction_types_tl
      Removed parameter p_order_number
  */
  CURSOR register_code_cur1(p_organization_id NUMBER,
                            p_location_id NUMBER,
          p_order_type varchar2) IS
  SELECT A.register_code
    FROM JAI_OM_OE_BOND_REG_HDRS A,
         JAI_OM_OE_BOND_REG_DTLS b,
   oe_transaction_types_tl ott
   WHERE A.organization_id = p_organization_id
     AND A.location_id = p_location_id
     AND A.register_id = b.register_id
     AND b.order_flag    = 'Y'
     AND b.order_type_id = ott.transaction_type_id
     AND ott.NAME = p_order_type;

    /* Bug 5243532. Added by Lakshmi Gopalsami
     * Removed cursor set_of_books_cur and c_opr_set_of_books_id
     * and implemented caching logic.
     */
      CURSOR trx_num(v_cust_trx_id NUMBER) IS SELECT
  trx_number FROM ra_customer_trx_all WHERE
  customer_trx_id = v_cust_trx_id;

  -- following cursor added by sriram -3266982

  -- Deleted by Jia Li for Tax inclusive Computations on 2007/11/22 Begin
  -- TD18-changed Trading AR Invoice
  -------------------------------------------------------------------------
  /*
  cursor c_ORDER_PRICE_EXCISE_INCLUSIVE(p_organization_id number,p_location_id number) is
  select ORDER_PRICE_EXCISE_INCLUSIVE
  from   JAI_CMN_INVENTORY_ORGS
  where  organization_id = p_organization_id
  and    location_id     = p_location_id;
  */
  -------------------------------------------------------------------------
  -- Deleted by Jia Li for Tax inclusive Computations on 2007/11/22 End

  CURSOR cur_chk_rgm ( cp_tax_type JAI_CMN_TAXES_ALL.TAX_TYPE%TYPE )
  IS
  SELECT
         regime_id   ,
         regime_code
  FROM
         jai_regime_tax_types_v      jrttv
  WHERE
         upper(jrttv.tax_type)   = upper(cp_tax_type);


  ln_regime_code JAI_RGM_DEFINITIONS.REGIME_CODE%TYPE;
  lv_attr_value  JAI_RGM_REGISTRATIONS.ATTRIBUTE_VALUE%TYPE;

  -- Start of bug 4089440
   ln_regime_id     JAI_RGM_DEFINITIONS.REGIME_ID%TYPE     ;
   lv_error_flag    VARCHAR2(2)                    ;
   lv_error_message VARCHAR2(4000)                 ;
   -- End of bug 4089440

   v_err_mesg     VARCHAR2(250)                    ;
   v_trx_num  ra_customer_trx_all.trx_number%TYPE  ;

   /* Bug 5243532. Added by Lakshmi Gopalsami
    * Defined variable for implementing caching logic
    */
   l_func_curr_det jai_plsql_cache_pkg.func_curr_details;

   --Added by Bo Li for Bug 9705313                Begin
   ----------------------------------------------------------------------------
   CURSOR check_rma_credit_cur(pn_order_number NUMBER
                           ,pn_order_line_id NUMBER)
   IS
   SELECT count(1)
   FROM  OE_ORDER_HEADERS_ALL oh,
         OE_ORDER_LINES_ALL ol,
         OE_TRANSACTION_TYPES_TL ot,
         oe_workflow_assignments owf
   WHERE oh.header_id = ol.header_id
   AND   oh.order_type_id = ot.transaction_type_id
   AND   oh.order_type_id = owf.order_type_id
   AND   ol.line_type_id = owf.line_type_id
   AND   oh.order_number = pn_order_number
   AND   ot.language = userenv('LANG')
   AND   ol.line_id = pn_order_line_id
   AND   owf.process_name IN ('R_RMA_CREDIT_APP_HDR_INV',
                              'R_RMA_CREDIT_WO_SHIP_APPROVE',
                              'R_RMA_CREDIT_WO_SHIP_HDR_INV',
                              'R_RMA_FOR_CREDIT_WO_SHIPMENT',
                              'R_RMA_FOR_OTA_CREDIT');

   CURSOR check_shippable_item_cur(pn_order_line_id NUMBER)
   IS
   SELECT COUNT(1)
   FROM MTL_SYSTEM_ITEMS msi,
        JAI_OM_OE_RMA_LINES l
   WHERE msi.inventory_item_id = pr_new.inventory_item_id
   AND   msi.inventory_item_id = l.inventory_item_id
   AND   l.rma_line_id = pn_order_line_id
   AND   msi.shippable_item_flag = 'N'  ;

   ln_rma_flag   NUMBER;
   ln_nonship_rma_flag        NUMBER;
   ----------------------------------------------------------------------------
    --Added by Bo Li for Bug  9705313               End

  BEGIN
    pv_return_code := jai_constants.successful ;
    /*------------------------------------------------------------------------------------------
 FILENAME: JA_IN_APPS_AR_LINES_INSERT_TRG.sql
 CHANGE HISTORY:
S.No      Date          Author and Details
1.        10-Jun-01 Jagdish / Subbu
                To populate Tax_rate column in RA_CUSTOMER_TRX_LINES_ALL
                table as receipts with discounts doesn't get saved.
2.      2001/06/22  Anuradha Parthasarathy
                        Commented and Added code for better performance.

3.        2002/03/22    RPK
                        added the column error_flag to the table 'JAI_AR_TRX_INS_LINES_T'
                        added the cursor trx_num to get the invoice num.

4         2002/04/22    RPK
                        BUG#2334972.
                        Code modified to allow the taxes to be inserted into
                        the table JAI_AR_TRX_INS_LINES_T.When an order line is having 2 tax amounts
                        one with a positive value and the other with a negative value(eg:100 and -100)
                        then these lines were not getting transferred to AR Tables and the same is
                        required to be transferred to have the proper accounting of the GL/AR.For this,
                        the when_clause of this trigger is commented to facilitate the execution of this
                        code.This is required to facilitate the functionality of having discounts in the
                        OM/AR tax flow.

5.       2002/05/04     Added the If Condition to ensure that the concurrent request to.
                        AR Tax and Freight Defaultation gets invoked only for manual invoices

6.       2002/05/06     Added the Source Column in the insert statement of Ja-In_temp_lines_insert
                        table.

8.       2003/04/07     SSUMAITH.Bug # 2779967
                        column Org id was not inserted in the JAI_AR_TRX_INS_LINES_T table. This needs to be
                        inserted in the table , because when processing the records using the 'India Local Concurrent'
                        only records that belong to the orgid of the current responsiblity needs to be picked up.

9.       2003/04/10     SSUMAITH - Bug # 2769439
                        Also inserting the tax line number in the JAI_AR_TRX_INS_LINES_T table.
                        This is necessary for creating links between OM and AR.

10.      2003/11/20     SSUMAITH - Bug # 3266982 File Version 617.1
                        The cursor which fetches order number was still pointing to So_headers_all table.
                        This caused the query to fetch no records, causing the code not to execute based on
                        register types.

                        This bug introduces dependency . Because as part of this bug , a new column ORDER_PRICE_EXCISE_INCLUSIVE
                        is added into the table - ja_in_hr_organzization_units.

                        If the flag value of ORDER_PRICE_EXCISE_INCLUSIVE becomes 'Y' then the excise tax will go as zero
                        else , the normal excise value will go to the base apps.

                        Also , a join between oe_order_headers_all and oe_transaction_types_tl has been added.
                        Without this join, if the same sales order number is associated to multiple order types,
                        there is scope for the wrong order number to be chosen and comparison done on that basis.

                        With this join condition, the value in the ra_customer_trx_all.interface_header_attribute2  is
                        compared to the 'Name' field in the oe_transaction_types_tl.

11.      2005/27/01     aiyer - Bug # 4089440 File Version 115.1
                        Issue:-
                        In case of service invoices having service/service_education type of taxes the code combination id should be picked
                        up from regime tax setup. This is being done as a part of the service tax enhancement

                        Solution:-
                        The check that, for service type of taxes ccid should be picked up from regime tax setup has been impletemented.
                        Called the procedure jai_ar_rgm_processing_pkg.get_regime_info is being called for regime setup validation.
                        Aslo called the function jai_cmn_rgm_recording_pkg.get_account  to get the ccid in such cases.

                        Dependency introduced as a part of this bug:-
                        This file should be released on top of Bug 4146708.

12.      01-Mar-2005   aiyer - Bug # 4212816 File Version 115.2
                        Issue:-
                        In case of invoices having any of the taxes setup for VAT REGIME, the code combination should get picked up from the
                                                            VAT Regime setup. This is being done as a part of the VAT enhancement

                        Solution:-
                        The check that, for taxes belonging to the VAT regime, ccid should be picked up from VAT regime setup has been impletemented.
                                                          The account info is fetched using the function jai_cmn_rgm_recording_pkg.get_account.

                        Dependency introduced as a part of this bug:-
                        This file should be released on top of Bug 4245089.
                                                            Datamodel changes for VAT

13.      02-Apr-2005   aiyer - Bug # 4279702 File Version 115.3
                        Issue:-
                        VAT regime code does not get reinitialized for any tax type which does not fall in the VAT / Service TAx regime

                        Solution:-
                        Changed the triggers ja_in_apps_lines_insert_trg and ja_in_apps_ar_lines_update_trg to reinitialize the regime codes
                        every time processing happens for a tax type.

                        Dependency introduced as a part of this bug:-
                        This file should be released on top of Bug 4245089.

14      08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old
                      DB Entity as required for CASE COMPLAINCE.  Version 116.1

15. 13-Jun-2005    File Version: 116.2
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done

16 06-Jul-2005     rallamse for bug# PADDR Elimination
                   1. Commented use of v_paddr and cursor PADDR_CUR

17 04-Aug-2005    Bug4535701. Added by Lakshmi Gopalsami Version 120.2
                  Commented the cursor which is used for PADDR

18 25-Jan-2007    CSahoo for Bug#5631784, File Version 120.3
                  Forward Porting of BUG#4742259
                  Accounting information popluated for TCS regime

19 14-FEB-2007    CSahoo - bug# 5364120  - file version 120.4
                  Forward Porting Of 11i BUG 5346489.

                  The transaction amounts are rounded based on the currency precision of the invoice currency code
                  when the insert id done in the JAI_AR_TRX_INS_LINES_T.
                  Added the cursor c_inv_curr_precision.

                  Dependency due to this bug :- None


19. 15-Feb-2007   CSahoo Bug# 5390583, File Version 120.5
                  Forward Porting of 11i Bug 5357400
                  When taxes are added manually to the ar invoice from the transactions localised screen and the
                  batch source is set to bond register, the excise taxes are going to base AR. This should not go.

                  Fix :
                  The code to take care of this was in a trading loop and would never reach there.
                  Modified the code appropriately.

20    24/04/2007     cbabu for bug#6012570 (5876390), File Version 120.7 (115.14 )
                       FP: For project billing bond register functionality is not required hence added a check to see if
                        the invoice is created by projects then bond register related logic should not be executed.

21     25/05/2007   sacsethi for bug 6072461  file version 120.11

        Problem - MANUAL AR TRANSACTION GIVES PROBLEM WITH VAT TAXES

            when we creating transactions in receivalbles , at that time at time of saving , it was
            giving error , vat setup is not defined but vat setup was defined

                    Solution - At time of get account of vat , we were passing wrong value of organzation id and location id .

 22.   31/05/2007   csahoo for bug#6081806, File version 120.13
                    added the sh cess types.

 23.        14/06/2007   sacsethi for bug 6072461 for file version - 120.15

      This bug is used to fp 11i bug 5183031 for vat reveresal

      Problem - Vat Reversal Enhancement not forward ported
      Solution - Changes has been done to make it compatible for vat reversal functioanlity also.
24  06-jan-2009    vkaranam for bug# 7661892
                 Issue:
     Auto Invoice is landing into error if the Order having the delivery from different warehouses
     Fix:
     Changed the query logic to get the organization ,location details.

25  08-sep-2009 vkaranam for bug#8775345
                Issue: Manual AR invoice is giving an error "Organization Cannot be Null".
                Fix:
                Changed the query logic to get the organization ,location details.

26.  26-Nov-2009  CSahoo for bug#9151886
                  Issue: AUTO INVOICE IMPORT ERROR
                  Fix: Added the code to fetch the organization_id and location_id for project invoices.


27   11-May-2010  Bug 9705313  Added by Bo Li
                  For nonshippable RMA flow
                  Generate the account for the nonshippable item Tax
==========================================================================================================================================================

Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )

----------------------------------------------------------------------------------------------------------------------------------------------------
Current Version       Current Bug    Dependent           Files                              Version     Author     Date         Remarks
Of File                              On Bug/Patchset    Dependent On
ja_in_apps_ar_lines_insert_trg.sql

617.1                 3266982        IN60105D1                                              617.1       ssumaith   03/12/2003

115.1                 4089440       IN60105D2 +                                                         Aiyer   27-Jan-2005   4146708 is the release bug for SERVICE/CESS
                                     4146708                                                                                  enhancement release
115.2                 4247989      IN60106 + 4146708  + 4245089                                         Aiyer   01-Mar-2005   4245089 is the Base bug for VAT.
                                                                                                                                                          This has datamodel changes for VAT.
24.    22/11/2007    Added by Jia Li
                     for Tax inclusive Computations
--------------------------------------------------------------------------------------------------------------------------------------------------------*/

  v_customer_trx_line_id    := pr_new.customer_trx_line_id; --Ramananda for File.Sql.35
  v_customer_trx_id         := pr_new.customer_trx_id;      --Ramananda for File.Sql.35

  --added the following block to capture the trx_number on 22-Mar-2002

  OPEN trx_num(pr_new.Customer_trx_id);
  FETCH trx_num INTO v_trx_num;
  CLOSE trx_num;
--end addition 22-Mar-2002
  OPEN   CREATED_FROM_CUR;
  FETCH  CREATED_FROM_CUR INTO v_created_from , v_order_number, v_order_type;
  CLOSE  CREATED_FROM_CUR;
  IF v_created_from IN ('ARXREC') THEN
     RETURN;
  END IF;

  /* Commented rallamse bug#4479131 PADDR Elimination
  OPEN   PADDR_CUR;
  FETCH  PADDR_CUR INTO v_paddr;
  CLOSE  PADDR_CUR;
  */

  OPEN  HEADER_INFO_CUR;
  FETCH HEADER_INFO_CUR INTO v_books_id, v_salesrep_id,v_org_id , c_from_currency_code,
                         c_conversion_type, c_conversion_date, c_conversion_rate, lv_intf_hdr_ctx;
  CLOSE HEADER_INFO_CUR;

  /* start additions by CSahoo - bug#5364120 */

  IF c_from_currency_code IS NOT NULL THEN
    OPEN  c_inv_Curr_precision(c_from_currency_code);
    FETCH c_inv_curr_precision INTO ln_inv_curr_precision;
    CLOSE c_inv_curr_precision;
  END IF;

  IF ln_inv_curr_precision is NULL THEN
     ln_inv_curr_precision := 0;
  END IF;

 /* end additions by CSahoo - bug#5364120 */

 --Commented for bug#4468353
 /*
  OPEN  VAT_TAX_CUR('Localization');
  FETCH VAT_TAX_CUR INTO v_vat_tax;
  CLOSE VAT_TAX_CUR;
  */

/* Added by Ramananda for bug# due to ebtax uptake by AR, start */
       OPEN  ORG_CUR;
       FETCH ORG_CUR INTO V_ORG_ID;
       CLOSE ORG_CUR;

       OPEN  jai_ar_trx_pkg.c_tax_regime_code_cur(V_ORG_ID);
       FETCH jai_ar_trx_pkg.c_tax_regime_code_cur INTO lv_tax_regime_code;
       CLOSE jai_ar_trx_pkg.c_tax_regime_code_cur ;

       OPEN  jai_ar_trx_pkg.c_max_tax_rate_id_cur(lv_tax_regime_code);
       FETCH jai_ar_trx_pkg.c_max_tax_rate_id_cur INTO ln_tax_rate_id;
       CLOSE jai_ar_trx_pkg.c_max_tax_rate_id_cur ;
/* Added by Ramananda for bug# due to ebtax uptake by AR, end */

  IF v_books_id IS NULL THEN
    /* Bug 5243532. Added by Lakshmi Gopalsami
     * Removed the cursor set_of_books_cur and implemented using caching logic.
     */
     l_func_curr_det := jai_plsql_cache_pkg.return_sob_curr
                            (p_org_id  => v_org_id );
     v_books_id := l_func_curr_det.ledger_id;
  END IF;

  v_converted_rate := jai_cmn_utils_pkg.currency_conversion (v_books_id ,c_from_currency_code ,
                            c_conversion_date ,c_conversion_type, c_conversion_rate);
  /*
  OPEN  SO_AR_HDR_INFO ;
  --FETCH SO_AR_HDR_INFO INTO v_organization_id, v_location_id, v_batch_source_id; commented for bug#7661892
  FETCH SO_AR_HDR_INFO INTO v_batch_source_id;
  CLOSE SO_AR_HDR_INFO ;
  *//*commented for bug#8775345*/

    --start additions for bug#8775345
  open get_batch_src_id;
  fetch get_batch_src_id into v_batch_source_id;
  close  get_batch_src_id;
  --end additions for bug#8775345


  --start additions for bug#7661892
  open c_get_orgn;
  fetch c_get_orgn into  v_organization_id,ln_order_line_id;
  close  c_get_orgn;

   --start additions for bug#8775345
  if   v_organization_id is null
  then
   OPEN  SO_AR_HDR_INFO ;
   FETCH SO_AR_HDR_INFO INTO   v_organization_id, v_location_id, v_batch_source_id;
  CLOSE SO_AR_HDR_INFO ;
  end if;
  --end additions for bug#8775345



  open c_get_loc(ln_order_line_id);
  fetch c_get_loc into  v_location_id;
  close  c_get_loc;

  --end additions for bug#7661892

  /*Commented by kunkumar for Bug#6066813  Start, Bug 6012570 (5876390)  */
  if JAI_AR_RCTLA_TRIGGER_PKG.is_this_projects_context (lv_intf_hdr_ctx) then
    /* For project invoices, there is no bond register functionality, so no need to do any processing for bond registers
      If line context is not PROJECT INVOICE then continue the normal processing flow  */
    --null;
    --added for bug#9151886, start
    open  c_get_orgn_project;
    fetch c_get_orgn_project into  v_organization_id,v_location_id;
    close  c_get_orgn_project;
    -- bug#9151886,end
  else
  -- End commented by kunkumar for bug#6066813
  -- End 6012570 (5876390)  */

    IF v_created_from = 'RAXTRX' THEN
      /* Bug 4938350. Added by Lakshmi Gopalsami
         Removed the parameter v_order_number
      */
      OPEN  register_code_cur1(v_organization_id, v_location_id,v_order_type);
      FETCH register_code_cur1 INTO v_register_code;
      CLOSE register_code_cur1;
    ELSIF v_created_from = 'ARXTWMAI' THEN
      OPEN  register_code_cur(v_organization_id, v_location_id, v_batch_source_id);
      FETCH register_code_cur INTO v_register_code;
      CLOSE register_code_cur;
    END IF;

    -- Deleted by Jia Li for Tax inclusive Computations on 2007/11/22 Begin
    -- TD18-changed Trading AR Invoice
    -------------------------------------------------------------------------
    /*
    open  c_ORDER_PRICE_EXCISE_INCLUSIVE(v_organization_id, v_location_id);
    fetch c_ORDER_PRICE_EXCISE_INCLUSIVE into v_ORDER_PRICE_EXCISE_INCLUSIVE;
    close c_ORDER_PRICE_EXCISE_INCLUSIVE;
    */
    -------------------------------------------------------------------------
    -- Deleted by Jia Li for Tax inclusive Computations on 2007/11/22 End

  --commented by kunkumar for bug#6066813
  end if;
/* Bug 6012570 (5876390) */

  BEGIN  --19-MAR-2002
   FOR TAX_TYPE_REC IN TAX_TYPE_CUR
   LOOP /* following if condition added by sriram - bug# 3266982*/

    -- IF nvl(v_ORDER_PRICE_EXCISE_INCLUSIVE,'N') = 'Y' then -- Deleted by Jia Li for Tax inclusive Computations on 2007/11/22 ,TD18

       IF NVL(v_register_code,'N') IN ('23D_EXPORT_WITHOUT_EXCISE','23D_EXPORT_EXCISE',
                                   '23D_DOMESTIC_EXCISE','23D_DOM_WITHOUT_EXCISE','BOND_REG')
       THEN
         -- jai_constants.tax_type_sh_exc_edu_cess,jai_constants.tax_type_sh_cvd_edu_cess  added by csahoo for bug#6081806
         IF Tax_Type_Rec.T_Type IN ('Excise','Addl. Excise','Other Excise','EXCISE_EDUCATION_CESS','CVD_EDUCATION_CESS',jai_constants.tax_type_sh_exc_edu_cess,jai_constants.tax_type_sh_cvd_edu_cess) THEN
           TAX_TYPE_REC.tax_amt := 0;
         END IF;
       END IF;
    -- END IF; -- Deleted by Jia Li for Tax inclusive Computations on 2007/11/22 ,TD18

     /*
        Date 14-jun-2007 by sacsethi for bug 6072461
     */

     IF ( upper(Tax_Type_Rec.T_Type) = 'VAT REVERSAL' )
     THEN
        TAX_TYPE_REC.tax_amt := 0;
     END IF;


     /*
     || added by CSahoo - bug# 5390583 In case of bond reg , the excise taxes should not go to base AR tables.
     */
     IF NVL(v_register_code,'N') = 'BOND_REG' THEN
        -- jai_constants.tax_type_sh_exc_edu_cess,jai_constants.tax_type_sh_cvd_edu_cess  added by csahoo for bug#6081806
        IF upper(Tax_Type_Rec.T_Type) IN ('EXCISE','ADDL. EXCISE','OTHER EXCISE','EXCISE_EDUCATION_CESS','CVD_EDUCATION_CESS',jai_constants.tax_type_sh_exc_edu_cess,jai_constants.tax_type_sh_cvd_edu_cess) THEN
           TAX_TYPE_REC.tax_amt := 0;
        END IF;
     END IF;

     /*
     || Ends additions by CSahoo - bug# 5390583
     */

     IF tax_type_rec.t_type = 'Freight' THEN
        v_line_type := 'FREIGHT';
     ELSE
        v_line_type := 'TAX';
     END IF;
     /*
     || Code modified by aiyer for the bug 4279702.
     || Initializing the regime variables
     */
     ln_regime_id   := null;
     ln_regime_code := null;

     /*
     || Get the regime attached to a transaction tax type
     */
     OPEN  cur_chk_rgm  ( cp_tax_type => tax_type_rec.t_type);
     FETCH cur_chk_rgm  INTO ln_regime_id,ln_regime_code ;
     CLOSE cur_chk_rgm  ;

     -- Start of bug 4089440
     /*
     || The following code has been added by aiyer for the bug 4089440
     || IF tax type is SERVICE or SERVICE-CESS then get the account info from regime setup
     || IF no setup is found then raise an error and stop the transaction.
     */
     IF   upper(tax_type_rec.t_type) = upper(jai_constants.tax_type_service)       OR
          upper(tax_type_rec.t_type) = upper(jai_constants.tax_type_service_edu_cess)
          OR upper(tax_type_rec.t_type)= upper(jai_constants.tax_type_sh_service_edu_cess)   --added by csahoo for bug#6081806
     THEN -- Start of A1

       /**********************************************************************************************************
       || Get the regime id and also validate the Regime/Regime Registratiom Setup Information
       ***********************************************************************************************************/

       jai_ar_rgm_processing_pkg.get_regime_info    (  p_regime_code    => jai_constants.service_regime    ,
                                                      p_tax_type_code  => tax_type_rec.t_type             ,
                                                      p_regime_id      => ln_regime_id                    ,
                                                      p_error_flag     => lv_error_flag                   ,
                                                      p_error_message  => lv_error_message
                                                   );

       IF lv_error_flag <> jai_constants.successful THEN
         /*
         || Encountered an error from the call to jai_ar_rgm_processing_pkg.get_regime_info
         || Stop processing and thorw an error
         */
/*          raise_application_error (-20130,lv_error_message);
       */ pv_return_code := jai_constants.expected_error ; pv_return_message := lv_error_message ; return ;
       END IF ;
       /**********************************************************************************************************
       || Get Tax Account Info from the Regime Organization/Regime Registration setup
       **********************************************************************************************************/

       /*
       || Get the code combination id from the Organization/Regime Registration setup
       || by calling the function jai_cmn_rgm_recording_pkg.get_account
       */

       v_ccid := jai_cmn_rgm_recording_pkg.get_account (
                                                          p_regime_id             => ln_regime_id                              ,
                                                          p_organization_type     => jai_constants.service_tax_orgn_type       ,
                                                          p_organization_id       => v_organization_id                                  ,
                                                          p_location_id           => v_location_id                             ,
                                                          p_tax_type              => tax_type_rec.t_type                       ,
                                                          p_account_name          => jai_constants.liability_interim
                                                        );
       IF v_ccid IS NULL THEN
         /*
         || Code Combination id has been returned as null from the function jai_cmn_rgm_recording_pkg.get_account
         || This is an error condition and the current processing has to be stopped
         */
/*          raise_application_error (-20130,'Invalid Code combination ,please check the Service Tax - Tax Accounting Setup');
       */ pv_return_code := jai_constants.expected_error ; pv_return_message := 'Invalid Code combination ,please check the Service Tax - Tax Accounting Setup' ; return ;
      END IF;
     /*
     || Start of bug 4212816
     || Code modified by aiyer for the VAT Enhancement
     || Get the Tax accounting information from the vat regime setup when the taxes are as mentioned below taxes
     */

     ELSIF UPPER(nvl(ln_regime_code,'####')) = jai_constants.vat_regime THEN

       /*********************************************************************************************************
       || Validate whether the item attached is vatable or not
       *********************************************************************************************************/
     if pr_new.inventory_item_id  is not null then  /*ssumaith - bug#6104491 */
       jai_inv_items_pkg.jai_get_attrib (
                                        p_regime_code         =>  ln_regime_code                                                 ,
                                        p_organization_id     =>  v_organization_id                                      ,
                                        p_inventory_item_id   =>  pr_new.inventory_item_id                 ,
                                        p_attribute_code      =>  jai_constants.rgm_attr_item_applicable ,
                                        p_attribute_value     =>  lv_attr_value                                                  ,
                                        p_process_flag        =>  lv_error_flag                          ,
                                        p_process_msg         =>  lv_error_message
                                       ) ;
       IF lv_error_flag <> jai_constants.successful THEN
         /*
         || Encountered an error from the call to jai_ar_rgm_processing_pkg.get_regime_info
         || Stop processing and thorw an error
         */
/*          raise_application_error (-20130,lv_error_message); */ pv_return_code := jai_constants.expected_error ; pv_return_message := lv_error_message ; return ;
         /*
         app_exception.raise_exception( EXCEPTION_TYPE  => 'APP',
                                        EXCEPTION_CODE => NULL ,
                                        EXCEPTION_TEXT => lv_error_message
                                      );
         */


       END IF;
 end if; /*ssumaith - bug# 6104491 */
       /*********************************************************************************************************
       || Raise an error if item is not vatable
       *********************************************************************************************************/
        if pr_new.inventory_item_id is not null and  nvl(lv_attr_value,'N')    = 'N' THEN
         /* above if condition before the if added by ssumaith - bug# 6104491 */
         /*
         || Item is not vatable . Stop processing and throw an error
         */
/*          raise_application_error (-20130,'ITEM not vatable'); */ pv_return_code := jai_constants.expected_error ; pv_return_message := 'ITEM not vatable' ; return ;
                 /* DO not delete this code, enable this code while doing the messageing project
         app_exception.raise_exception( EXCEPTION_TYPE  => 'APP',
                                        EXCEPTION_CODE => NULL ,
                                        EXCEPTION_TEXT => 'Cannot attach VAT type of taxes to non vatable items.'
                                      );
        */



           END IF;
       /*********************************************************************************************************
       || Get the code combination id from the Organization/Regime Registration setup
       || by calling the function jai_cmn_rgm_recording_pkg.get_account
       *********************************************************************************************************/

        -- 25/05/2007 by sacsethi for bug 6072461
  -- Previously Organziation id was going wrong and location id was wrong

     --Added by Bo Li for Bug 9705313 Begin
     -----------------------------------------------------------------------
     OPEN  check_rma_credit_cur(v_order_number,ln_order_line_id);
     FETCH check_rma_credit_cur
     INTO ln_rma_flag ;
     CLOSE check_rma_credit_cur;


     OPEN  check_shippable_item_cur(ln_order_line_id);
     FETCH check_shippable_item_cur
     INTO ln_nonship_rma_flag ;
     CLOSE check_shippable_item_cur;

     IF ln_rma_flag > 0 OR ln_nonship_rma_flag > 0
     THEN
       v_ccid := jai_cmn_rgm_recording_pkg.get_account (
                                                          p_regime_id             => ln_regime_id                              ,
                                                          p_organization_type     => jai_constants.orgn_type_io                ,
                                                          p_organization_id       => v_organization_id                         ,
                                                          p_location_id           => v_location_id                             ,
                                                          p_tax_type              => tax_type_rec.t_type                       ,
                                                          p_account_name          => jai_constants.recovery
                                                        );
     ELSE
     ----------------------------------------------------------------------
     --Added by Bo Li for Bug 9705313   End
       v_ccid := jai_cmn_rgm_recording_pkg.get_account (
                                                          p_regime_id             => ln_regime_id                              ,
                                                          p_organization_type     => jai_constants.orgn_type_io                ,
                                                          p_organization_id       => v_organization_id                         ,
                                                          p_location_id           => v_location_id                            ,
                                                          p_tax_type              => tax_type_rec.t_type                       ,
                                                          p_account_name          => jai_constants.liability_interim
                                                        );

     End IF; -- Added by Bo Li for Bug 9705313
       IF v_ccid IS NULL THEN
         /**********************************************************************************************************
         || Code Combination id has been returned as null from the function jai_cmn_rgm_recording_pkg.get_account
         || This is an error condition and the current processing has to be stopped
         **********************************************************************************************************/
/*          raise_application_error (-20130,'Invalid Code combination ,please check the VAT Tax - Tax Accounting Setup'); */
        pv_return_code := jai_constants.expected_error ;
  pv_return_message := 'Invalid Code combination ,please check the VAT Tax - Tax Accounting Setup  ' ;
  return ;
         /*
         app_exception.raise_exception( EXCEPTION_TYPE  => 'APP',
                                        EXCEPTION_CODE => NULL ,
                                        EXCEPTION_TEXT => 'Invalid Code combination ,please check the VAT Tax - Tax Accounting Setup'
                                      );
          */
       END IF;

     /*
     || End of bug 4212816
     */

     /* Added by CSahoo for the TCS enhancements Bug# 5631784 */
     ELSIF  UPPER(nvl(ln_regime_code,'####')) = jai_constants.tcs_regime THEN -- Start of A1

        /*********************************************************************************************************
        || Get the code combination id from the Organization/Regime Registration setup
        || by calling the function jai_rgm_trx_recording_pkg.get_account
        *********************************************************************************************************/


        v_ccid := jai_cmn_rgm_recording_pkg.get_account (
                                                           p_regime_id             => ln_regime_id                              ,
                                                           p_organization_type     => jai_constants.orgn_type_io                ,
                                                           p_organization_id       => v_organization_id                         ,
                                                           p_location_id           => v_location_id                             ,
                                                           p_tax_type              => tax_type_rec.t_type                       ,
                                                           p_account_name          => jai_constants.liability_interim
                                                         );
        IF v_ccid IS NULL THEN
          /**********************************************************************************************************
          || Code Combination id has been returned as null from the function jai_rgm_trx_recording_pkg.get_account
          || This is an error condition and the current processing has to be stopped
          **********************************************************************************************************/
           raise_application_error (-20130,'Invalid Code combination ,please check the TCS Tax - Tax Accounting Setup');

        END IF;

     /*End of bug 5631784 */

     ELSE -- ELSE of A1
       /*
       || As tax type is not SERVICE hence
       || get code combination from tax definition setup
       */
       OPEN  TAX_CCID_CUR(TAX_TYPE_REC.taxid);
       FETCH TAX_CCID_CUR INTO v_ccid;
       CLOSE TAX_CCID_CUR;

     END IF; --End if of A1
     -- End of bug 4089440

     IF TAX_TYPE_REC.t_type  = 'TDS' THEN
        TAX_TYPE_REC.tax_amt := 0;
     END IF;

     INSERT INTO JAI_AR_TRX_INS_LINES_T (  -- paddr,
  -- 6842749
                                           extended_amount,
                                           customer_trx_line_id,
                                           customer_trx_id,
                                           set_of_books_id,
                                           link_to_cust_trx_line_id,
                                           line_type,
                                           uom_code,
                                           vat_tax_id,
                                           acctd_amount,
                                           amount,
                                           CODE_COMBINATION_ID,
                                           cust_trx_line_sales_rep_id,
                                           insert_update_flag,
                                           last_update_date,
                                           last_updated_by,
                                           creation_date,
                                           created_by,
                                           last_update_login,
                                           tax_rate,    --Tax_rate column added by Jagdish/Subbu 10-Jun-01
                                           error_flag ,--added on 22-Mar-2002 by RPK to store the error_flag.Initially it  --will be NULL
                                           source, -- column added by sriram on 6th May 2002.
                                           org_id,  -- Added by sriram bug # 2779967
                                           line_number ) -- Added by sriram Bug # 2769439

                                  VALUES ( -- NULL,   /* Previously passing v_paddr. Replaced with NULL by rallamse bug#4448789 */
                                           round( TAX_TYPE_REC.tax_amt, ln_inv_curr_precision ), /* rounding based on inv currency precision - bug# 5364120*/
                                           TAX_TYPE_REC.LINE_ID,
                                           v_customer_trx_id,
                                           v_books_id,
                                           v_customer_trx_line_id,
                                           v_line_type,
                                           TAX_TYPE_REC.uom,
                                           ln_tax_rate_id, --v_vat_tax, /* Modified by Ramananda for bug#4468353 due to ebtax uptake by AR */
                                           v_converted_rate * TAX_TYPE_REC.tax_amt,
                                           round(TAX_TYPE_REC.tax_amt, ln_inv_curr_precision ) , /* rounding based on inv currency precision - bug# 5364120*/
                                           v_ccid,
                                           v_salesrep_id,
                                           'U',
                                           pr_new.last_update_date,
                                           pr_new.last_updated_by,
                                           pr_new.creation_date,
                                           pr_new.created_by,
                                           pr_new.last_update_login,
                                           TAX_TYPE_REC.tax_rate,       --Tax_rate column added by Jagdish/Subbu 10-Jun-01
                                           'P',
                                           v_created_from,
                                           v_org_id , -- added by sriram bug # 2779967
                                           tax_type_rec.tax_line_no ); -- added by sriram - bug # 2769439
        --END; --19-MAR-2002
   END LOOP;
   EXCEPTION
   WHEN OTHERS THEN
        v_err_mesg := SQLERRM;
/*         RAISE_APPLICATION_ERROR(-20003,'error in processing the invoice ..' || v_trx_num || v_err_mesg);
 */ pv_return_code := jai_constants.expected_error ; pv_return_message := 'error in processing the invoice ..' || v_trx_num || v_err_mesg ; return ; --19-MAR-2002
   END;
   -- the following if added by Sriram / Pavan on 06-May-2002
   IF v_created_from = 'ARXTWMAI' THEN
       result := fnd_request.set_mode(TRUE);
       req_id := fnd_request.submit_request( 'JA', 'JAILINEGL', 'AR Tax and Freight Defaultation',
            SYSDATE, FALSE,v_customer_trx_id, v_customer_trx_line_id );
   END IF;
  END ARI_T1 ;

  /*
  REM +======================================================================+
  REM NAME          ARU_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_JAR_TL_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_JAR_TL_ARU_T2
  REM
  REM +======================================================================+
  */
PROCEDURE ARU_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
    v_books_id            NUMBER;
  v_salesrep_id         NUMBER;
  v_line_type           VARCHAR2(30);
  v_vat_tax             NUMBER;
  v_ccid                NUMBER;
  v_cust_trx_line_id        RA_CUSTOMER_TRX_LINES_ALL.customer_trx_line_id%TYPE;
  --  v_paddr               v$session.paddr%TYPE;
 -- bug#6842749
  v_counter             NUMBER;
  v_customer_trx_id     NUMBER; -- := pr_old.customer_trx_id; --rpokkula for File.Sql.35
  c_from_currency_code      VARCHAR2(15);
  c_conversion_type     VARCHAR2(30);
  c_conversion_date     DATE;
  c_conversion_rate     NUMBER := 0;
  v_converted_rate      NUMBER := 1;
  req_id                NUMBER;
  result                BOOLEAN;
  v_created_from            VARCHAR2(30);
  v_insert_update_flag      VARCHAR2(1) ;
  v_organization_id     NUMBER ;
  v_location_id         NUMBER ;
  v_batch_source_id     NUMBER ;
  v_register_code           VARCHAR2(50);
  -- added by sriram - bug # 2779967
  v_org_id                      ra_customer_trx_all.org_id%type;
  /*Bug 8371741 - Start*/
  v_line_amount         NUMBER := 0;
  v_quantity            NUMBER;
  v_trans_type          VARCHAR2(30);
  v_line_tax_amount     NUMBER := 0;
  l_tcs_line_num        NUMBER := 0;
  l_tcs_sur_line_num    NUMBER := 0;
  ln_tcs_regime_id      JAI_RGM_DEFINITIONS.regime_id%type;
  l_org_id              NUMBER;
  l_bill_to_customer_id NUMBER;
  l_bill_to_site_use_id NUMBER;
  ln_organization_id    NUMBER;
  ln_trx_date           DATE;
  ln_threshold_slab_id      jai_ap_tds_thhold_slabs.threshold_slab_id%type;
  ln_threshold_tax_cat_id   jai_ap_tds_thhold_taxes.tax_category_id%type;
  lv_process_flag       VARCHAR2(2);
  lv_process_message    VARCHAR2(1996);
  ln_tax_amount         NUMBER;
  l_tot_tax_lines       NUMBER;
  l_max_tax_line_no     NUMBER;
  /*Bug 8371741 - End*/
  -- added by sriram - bug # 2779967

  /*Bug 8371741 - Start*/
  CURSOR GC_GET_REGIME_ID (CP_REGIME_CODE    JAI_RGM_DEFINITIONS.REGIME_CODE%TYPE)
  IS
  SELECT REGIME_ID
  FROM   JAI_RGM_DEFINITIONS
  WHERE  REGIME_CODE = CP_REGIME_CODE;

  Cursor transaction_type_cur IS
  Select a.type
  From   RA_CUST_TRX_TYPES_ALL a, RA_CUSTOMER_TRX_ALL b
  Where  a.cust_trx_type_id = b.cust_trx_type_id
  And    b.customer_trx_id = v_customer_trx_id
  And    NVL(a.org_id,0) = NVL(b.org_id,0);

  CURSOR  bind_cur IS
  SELECT  RCTA.org_id,
          RCTA.bill_to_customer_id,
          NVL(RCTA.bill_to_site_use_id,0),
      RCTA.trx_date
  FROM    RA_CUSTOMER_TRX_ALL RCTA
  WHERE   RCTA.customer_trx_id = v_customer_trx_id;

  /*Bug 8371741 - End*/
  /*Commented by kunkumar for bug#6066813 start Bug 6012570 (5876390)  */
   /*cursor c_get_hdr_ctx
   is
   select interface_header_context
   from ra_customer_trx_all
   where  customer_trx_id = pr_new.customer_trx_id;*/
   /*commented the above cursor and added the following for bug#5597146*/
   /*commented the cursor c_get_hdr_ctx for bug#8310220
   cursor c_get_hdr_ctx
   is
   select distinct interface_line_context
   from ra_customer_trx_lines_all
   where customer_trx_id = pr_new.customer_trx_id
   and customer_trx_line_id = pr_new.customer_trx_line_id  --added for bug#5597146
   and interface_line_context is not null
   and rownum = 1;*/


   lv_intf_hdr_ctx   ra_customer_trx_all.interface_header_context%type ;
  /* End commented by kunkumar for bug#6066813 */
  /*end Bug 6012570 (5876390)  */

  -- Deleted by Jia Li for Tax inclusive Computations on 2007/11/22 Begin
  -- TD18-changed Trading AR Invoice
  -------------------------------------------------------------------------
  /*
  v_ORDER_PRICE_EXCISE_INCLUSIVE JAI_CMN_INVENTORY_ORGS.ORDER_PRICE_EXCISE_INCLUSIVE%type; -- date 15/06/2007 sacsethi for bug 6131957

-- date 15/06/2007 sacsethi for bug 6131957

  cursor c_ORDER_PRICE_EXCISE_INCLUSIVE(p_organization_id number,p_location_id number) is
  select ORDER_PRICE_EXCISE_INCLUSIVE
  from   JAI_CMN_INVENTORY_ORGS
  where  organization_id = p_organization_id
  and    location_id     = p_location_id;
  */
  -------------------------------------------------------------------------
  -- Deleted by Jia Li for Tax inclusive Computations on 2007/11/22 End


  CURSOR tax_type_cur IS
  SELECT
            a.tax_id                taxid       ,
            a.tax_rate                          ,
            a.uom                   uom         ,
            a.tax_amount            tax_amt     ,
            b.tax_type              t_type      ,
            a.customer_trx_line_id  line_id     ,
            a.tax_line_no           tax_line_no
  FROM
            JAI_AR_TRX_TAX_LINES a ,
            JAI_CMN_TAXES_ALL             b
  WHERE
            link_to_cust_trx_line_id    = pr_old.customer_trx_line_id and
            a.tax_id                    = b.tax_id
    AND     NVL(b.inclusive_tax_flag,'N') = 'N'   --Added by Jia Li for Tax inclusive Computations on 2007/11/22
  ORDER BY
            1;

--  bug#6842749
/*
  CURSOR PADDR_CUR IS
  SELECT paddr
  FROM v$session
  WHERE audsid = USERENV('SESSIONID');
*/

  CURSOR BOOKS_TRX_CUR IS
  SELECT set_of_books_id, primary_salesrep_id, invoice_currency_code, exchange_rate_type, exchange_date, exchange_rate
  FROM   JAI_AR_TRXS
  WHERE  customer_trx_id = v_customer_trx_id;


   --Commented for bug#4468353
  /*
  CURSOR VAT_TAX_CUR(cp_tax_code  AR_VAT_TAX_ALL.tax_code%type) IS
  SELECT DISTINCT vat_tax_id
  FROM   AR_VAT_TAX_ALL
  WHERE  UPPER(tax_code) = cp_tax_code ;
  */


  /* Added by Ramananda for bug#4468353 , start
  CURSOR ORG_CUR IS
  SELECT ORG_ID
  FROM   RA_CUSTOMER_TRX_ALL
  WHERE  CUSTOMER_TRX_ID = pr_new.customer_trx_id;*/

  --commented the above org_cur cursor and added the following org_cur cursor for bug#5597146
  CURSOR ORG_CUR IS
  SELECT ORG_ID
  FROM   RA_CUST_TRX_LINE_GL_DIST_ALL
  WHERE  CUSTOMER_TRX_ID = pr_new.customer_trx_id
  AND    account_class ='REC'
  AND    latest_rec_flag ='Y';

  lv_tax_regime_code             zx_rates_b.tax_regime_code%type ;
  ln_party_tax_profile_id        zx_party_tax_profile.party_tax_profile_id%type ;
  ln_tax_rate_id                 zx_rates_b.tax_rate_id%type ;
  /* Added by Ramananda for bug#4468353 , end     */

  CURSOR TAX_CCID_CUR(p_tax_id IN NUMBER) IS
  SELECT tax_account_id
  FROM   JAI_CMN_TAXES_ALL B
  WHERE  B.tax_id = p_tax_id ;

  CURSOR GL_DATE_CUR IS
  SELECT gl_date
  FROM   RA_CUST_TRX_LINE_GL_DIST_ALL
  WHERE  CUSTOMER_TRX_LINE_ID = pr_old.customer_trx_line_id;

  CURSOR CREATED_FROM_CUR IS
  SELECT created_from
  FROM   JAI_AR_TRXS  -- table reference was previously RA_CUSTOMER_TRX_ALL - using JA_IN_RA_CUSTOMER_TRX instead - bug# 2728636
  WHERE  customer_trx_id = v_customer_trx_id;

  CURSOR Insert_Update_Cur(p_customer_trx_line_id IN NUMBER) IS
  SELECT INSERT_UPDATE_FLAG
  FROM   JAI_AR_TRX_INS_LINES_T
  WHERE  customer_trx_id = V_CUSTOMER_TRX_ID AND
         Customer_trx_line_id = p_customer_trx_line_id
  ORDER BY CUSTOMER_TRX_LINE_ID;

  CURSOR SO_AR_HDR_INFO IS
  SELECT organization_id, location_id, batch_source_id
  FROM   JAI_AR_TRXS
  WHERE  Customer_Trx_ID = v_customer_trx_id;

  CURSOR register_code_cur(p_org_id IN NUMBER,  p_loc_id IN NUMBER, p_batch_source_id  IN NUMBER)  IS
  SELECT register_code
  FROM   JAI_OM_OE_BOND_REG_HDRS
  WHERE  organization_id = p_org_id AND location_id = p_loc_id   AND
       register_id IN (SELECT register_id
                     FROM   JAI_OM_OE_BOND_REG_DTLS
                 WHERE  order_type_id = p_batch_source_id AND order_flag = 'N');

    /* Bug 5243532. Added by Lakshmi Gopalsami
     * Removed cursor set_of_books_cur and c_opr_set_of_books_id
     * and implemented caching logic.
     */
  CURSOR cur_chk_rgm ( cp_tax_type JAI_CMN_TAXES_ALL.TAX_TYPE%TYPE )
  IS
  SELECT
         regime_id   ,
         regime_code
  FROM
         jai_regime_tax_types_v      jrttv
  WHERE
         upper(jrttv.tax_type)   = upper(cp_tax_type);


  ln_regime_code JAI_RGM_DEFINITIONS.REGIME_CODE%TYPE;
  lv_attr_value  JAI_RGM_REGISTRATIONS.ATTRIBUTE_VALUE%TYPE;

  -- Start of bug 4089440
   ln_regime_id     JAI_RGM_DEFINITIONS.REGIME_ID%TYPE     ;
   lv_error_flag    VARCHAR2(2)                    ;
   lv_error_message VARCHAR2(4000)                 ;
  -- End of bug 4089440

  /* Bug 5243532. Added by Lakshmi Gopalsami
   * Removed cursor  set_of_books_cur
   * and implemented caching logic.
   */
   l_func_curr_det jai_plsql_cache_pkg.func_curr_details;

   ln_inv_curr_precision     NUMBER;

   /* added by CSahoo - bug# 5364120*/
   CURSOR c_inv_curr_precision(cp_currency_code varchar2) IS
   SELECT  NVL(minimum_accountable_unit,NVL(precision,2)) curr_precision
     FROM    fnd_currencies
    WHERE   currency_code = cp_currency_code;
   --added the function for bug#8310220
   FUNCTION get_hdr_ctx (p_customer_trx_id IN NUMBER,
                         p_customer_trx_line_id IN NUMBER)
   RETURN VARCHAR2
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      cursor c_get_hdr_ctx
      is
        select  distinct interface_line_context
        from    ra_customer_trx_lines_all
        where   customer_trx_id = p_customer_trx_id
        and     customer_trx_line_id = p_customer_trx_line_id  --added for bug#5597146
        and     interface_line_context is not null
        and     rownum = 1;
      lv_hdr_ctx ra_customer_trx_lines_all.INTERFACE_LINE_CONTEXT%type;
    BEGIN
      OPEN c_get_hdr_ctx;
      FETCH c_get_hdr_ctx into lv_hdr_ctx;
      CLOSE c_get_hdr_ctx;

      return lv_hdr_ctx;
    END get_hdr_ctx;

  BEGIN
    pv_return_code := jai_constants.successful ;
    /*------------------------------------------------------------------------------------------
FILENAME: JA_IN_APPS_AR_LINES_UPDATE_TRG.sql
CHANGE HISTORY:
S.No  Date        Author and Details
1.  2001/04/09  Changed the Cases for Register Codes
2.  2001/06/11  Jagdish
            Added tax_rate for Receipts Discounts Issue
3.  2001/06/22      Anuradha Parthasarathy
            Code commented and added to improve performance.
4.  2001/12/13  Anuradha Parthasarathy
            Code commented because if the updated tax amount is zero the tax lines
            need to be corrected in the Base Tables as well.
5.  2002/05/09  Sriram
                        Added the Source Column in the Column list in the insert statement
            This Column was added in the JAI_AR_TRX_INS_LINES_T table because the
            AR Tax and Freight Defaultation Concurrent - was split into 2 concurrents
            doing the same functionality - one being called from the AR side for manual invoice
            from this trigger and another from OM side which is scheduled to run on a periodid basis
6.  2002/05/09  Sriram
                        Added the if condition at the bottom of the trigger to conditionally call the concurrent
            only if is a manual invoice.
7.      2003/01/02      Ssumaith Bug # 2728636 File Version 615.2
                        Reference to table RA_CUSTOMER_TRX_ALL was present in the cursor Created_from_cur
                        Which was causing a mutating error and causing the transaction to error out
                        with unhandled exception.This has been changed to point to JAI_AR_TRXS
                        table instead which takes care of the issue.
8.      2003/04/07      SSUMAITH.Bug # 2779967
                        column Org id was not inserted in the JAI_AR_TRX_INS_LINES_T table. This needs to be
                        inserted in the table , because when processing the records using the 'India Local Concurrent'
                        only records that belong to the orgid of the current responsiblity needs to be picked up.
9.     2003/04/10       SSUMAITH - Bug # 2769439
                        Also inserting the tax line number in the JAI_AR_TRX_INS_LINES_T table.
                        This is necessary for creating links between OM and AR.


10.     2005/27/01     aiyer - Bug # 4089440 File Version 115.1
                        Issue:-
                        In case of service invoices having service/service_education type of taxes the code combination id should be picked
                        up from regime tax setup. This is being done as a part of the service tax enhancement

                        Solution:-
                        The check that, for service type of taxes ccid should be picked up from regime tax setup has been impletemented.
                        Called the procedure jai_ar_rgm_processing_pkg.get_regime_info is being called for regime setup validation.
                        Aslo called the function jai_cmn_rgm_recording_pkg.get_account  to get the ccid in such cases.

                        Dependency introduced as a part of this bug:-
                        This file should be released on top of Bug 4146708.

11.      01-Mar-2005   aiyer - Bug # 4212816 File Version 115.2
                        Issue:-
                        In case of invoices having any of the taxes setup for VAT REGIME, the code combination should get picked up from the
                                                            VAT Regime setup. This is being done as a part of the VAT enhancement

                        Solution:-
                        The check that, for taxes belonging to the VAT regime, ccid should be picked up from VAT regime setup has been impletemented.
                                                        The account info is fetched using the function jai_cmn_rgm_recording_pkg.get_account.


                        Dependency introduced as a part of this bug:-
                        This file should be released on top of Bug 4245089.
                                                            Datamodel changes for VAT


12.      02-Apr-2005   aiyer - Bug # 4279702 File Version 115.3
                        Issue:-
                        VAT regime code does not get reinitialized for any tax type which does not fall in the VAT / Service TAx regime

                        Solution:-
                        Changed the triggers ja_in_apps_ar_lines_insert_trg and ja_in_apps_ar_lines_update_trg to reinitialize the regime codes
                        every time processing happens for a tax type.

                        Dependency introduced as a part of this bug:-
                        This file should be released on top of Bug 4245089.

13.       08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old
                        DB Entity as required for CASE COMPLAINCE.  Version 116.1

14.       13-Jun-2005    File Version: 116.2
                        Ramananda for bug#4428980. Removal of SQL LITERALs is done

15.       25-Jan-2007   CSahoo for Bug#5631784, File Version 120.3
                        Forward Porting of BUG#4742259
                        Accounting information popluated for TCS regime

15.       14-Feb-2007   CSahoo BUG#5364120, File Version - 120.4
                        Forward Porting of 11i BUG#5346489
                        The transaction amounts are rounded based on the currency precision of the invoice currency code
                        when the insert is done in the JAI_AR_TRX_INS_LINES_T.
                        Added the cursor c_inv_curr_precision.

                        Dependency due to this bug :- None

16.       15-Feb-2007   CSahoo Bug#5390583, File Version - 120.5
                        Forward Porting of 11i bug#5357400
                        When taxes are added manually to the ar invoice from the transactions localised screen and the
                        batch source is set to bond register, the excise taxes are going to base AR. This should not go.

                        Fix :
                        The code to take care of this was in a trading loop and would never reach there.
17.       05-APR-2007   bduvarag for bug#5671400,File version 120.6
                         Forward porting the changes done in 11i bug#4648231

                        Modified the code appropriately.

18    24/04/2007     cbabu for bug#5876390, File Version 120.7 (115.17 )
                       FP: For project billing bond register functionality is not required hence added a check to see if
                        the invoice is created by projects then bond register related logic should not be executed.
19.        31/05/2007   CSahoo for bug#6081806, File Version 120.13
                        added the sh cess tax types.


20.        14/06/2007   sacsethi for bug 6072461 for file version - 120.15

      This bug is used to fp 11i bug 5183031 for vat reveresal

      Problem - Vat Reversal Enhancement not forward ported
      Solution - Changes has been done to make it compatible for vat reversal functioanlity also.

21.        15/06/2007   sacsethi for bug 6131957 for file version - 120.16

      R12RUP03-ST1: TRADING TAKES EXCISE PRICE INCLUSIVE EVEN WHEN FLAG IS UNCHECKED

                        Variable v_order_price_excise_inclusive and cursor c_order_price_excise_inclusive is defined

22.    10/07/2007   CSahoo for bug#5597146, FileVersion 120.17
                    modified the cursor ORG_CUR.
23.    10/10/2007   CSahoo for bug#5597146, FileVersion 120.19
                    modified the cursor c_get_hdr_ctx to remove the mutating trigger error.
24.    11/10/2007   CSahoo for bug#5597146, File Version 120.20
                    Added the following AND condition in the cursor c_get_hdr_ctx
                    "and customer_trx_line_id = pr_new.customer_trx_line_id "
25.    23/04/2009   CSahoo for bug#8310220, File Version 120.22.12010000.4,120.22.12010000.5
                    Commented the cursor c_get_hdr_ctx. added the function get_hdr_ctx

==========================================================================================================================================================

Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )

----------------------------------------------------------------------------------------------------------------------------------------------------
Current Version       Current Bug    Dependent           Files                              Version     Author     Date         Remarks
Of File                              On Bug/Patchset    Dependent On
ja_in_apps_ar_lines_update_trg.sql

115.1                 4089440       IN60105D2 +                                                         Aiyer   27-Jan-2005   4146708 is the release bug for SERVICE/CESS
                                     4146708                                                                                  enhancement release

115.2                 4247989      IN60106 + 4146708  + 4245089                                         Aiyer   01-Mar-2005   4245089 is the Base bug for VAT.
                                                                                                                                                          This has datamodel changes for VAT.

25.    22/11/2007    Added by Jia Li
                     for Tax inclusive Computations

-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

  -- added by sriram - bug # 2779967
     v_org_id := FND_PROFILE.VALUE('ORG_ID');
  -- added by sriram - bug # 2779967

  v_customer_trx_id     := pr_old.customer_trx_id; --rpokkula for File.Sql.35

  OPEN   CREATED_FROM_CUR;
  FETCH  CREATED_FROM_CUR INTO v_created_from;
  CLOSE  CREATED_FROM_CUR;
  IF v_created_from IN ('ARXREC','ARXTWCMI') THEN /* Added on 19/9/99*/
     RETURN;
  END IF;

  IF (NVL(pr_old.TAX_AMOUNT,0) = NVL(pr_new.TAX_AMOUNT,1)) AND (pr_new.Customer_Trx_Id = pr_old.Customer_Trx_Id)
  THEN
    RETURN;
  END IF;
   -- 6842749
  /*  OPEN   PADDR_CUR;
  FETCH  PADDR_CUR INTO v_paddr;
  CLOSE  PADDR_CUR;
*/
  OPEN  BOOKS_TRX_CUR;
  FETCH BOOKS_TRX_CUR INTO v_books_id, v_salesrep_id, c_from_currency_code, c_conversion_type, c_conversion_date, c_conversion_rate ;
  CLOSE BOOKS_TRX_CUR;

  /* start additions by CSahoo - bug# 5364120*/

  IF c_from_currency_code IS NOT NULL THEN
   OPEN  c_inv_Curr_precision(c_from_currency_code);
   FETCH c_inv_curr_precision INTO ln_inv_curr_precision;
   CLOSE c_inv_curr_precision;
  END IF;


  IF ln_inv_curr_precision IS NULL THEN
    ln_inv_curr_precision := 0;
  END IF;

 /* end additions by CSahoo - bug#5364120 */

--- This Gives More then One Row, Still To solve This Issue

 --Commented for bug#4468353
  /*
  OPEN  VAT_TAX_CUR('LOCALIZATION');
  FETCH VAT_TAX_CUR INTO v_vat_tax;
  CLOSE VAT_TAX_CUR;
  */

/* Added by Ramananda for bug# due to ebtax uptake by AR, start */
       OPEN  ORG_CUR;
       FETCH ORG_CUR INTO V_ORG_ID;
       CLOSE ORG_CUR;

       OPEN  jai_ar_trx_pkg.c_tax_regime_code_cur(V_ORG_ID);
       FETCH jai_ar_trx_pkg.c_tax_regime_code_cur INTO lv_tax_regime_code;
       CLOSE jai_ar_trx_pkg.c_tax_regime_code_cur ;

       OPEN  jai_ar_trx_pkg.c_max_tax_rate_id_cur(lv_tax_regime_code);
       FETCH jai_ar_trx_pkg.c_max_tax_rate_id_cur INTO ln_tax_rate_id;
       CLOSE jai_ar_trx_pkg.c_max_tax_rate_id_cur ;
/* Added by Ramananda for bug# due to ebtax uptake by AR, end */

  OPEN  SO_AR_HDR_INFO ;
  FETCH SO_AR_HDR_INFO INTO v_organization_id, v_location_id, v_batch_source_id;
  CLOSE SO_AR_HDR_INFO ;

  --Commented by kunkumar for bug#6066813  Start,  Bug 6012570 (5876390)
  /*commented the following for bug#8310220
  open  c_get_hdr_ctx;
  fetch c_get_hdr_ctx into lv_intf_hdr_ctx;
  close c_get_hdr_ctx;*/
  --added the following for bug#8310220
  lv_intf_hdr_ctx := get_hdr_ctx(pr_new.customer_trx_id,pr_new.customer_trx_line_id);

  if JAI_AR_RCTLA_TRIGGER_PKG.is_this_projects_context (lv_intf_hdr_ctx) then
    /* For project invoices, there is no bond register functionality, so no need to do any processing for bond registers
       If line context is not PROJECT INVOICE then continue the normal processing flow  */
    null;

  else
  -- End commented by kunkumar for bug#6066813  End 6012570 (5876390)  */

    OPEN  register_code_cur(v_organization_id, v_location_id, v_batch_source_id);
    FETCH register_code_cur INTO v_register_code;
    CLOSE register_code_cur;

  --commented by kunkumar for bug#6066813
  end if;
/* 6012570 (5876390) */

  IF v_books_id IS NULL
  THEN
    /* Bug 5243532. Added by Lakshmi Gopalsami
     * Removed the cursor set_of_books_cur and implemented using caching logic.
     */
     l_func_curr_det := jai_plsql_cache_pkg.return_sob_curr
                            (p_org_id  => v_organization_id );
     v_books_id := l_func_curr_det.ledger_id;
  END IF;
  v_converted_rate := jai_cmn_utils_pkg.currency_conversion (v_books_id ,c_from_currency_code ,
                            c_conversion_date ,c_conversion_type, c_conversion_rate);


  -- date 15/06/2007 sacsethi for bug 6131957
  -- Deleted by Jia Li for Tax inclusive Computations on 2007/11/22 Begin
  -- TD18-changed Trading AR Invoice
  -------------------------------------------------------------------------
  /*
  open  c_ORDER_PRICE_EXCISE_INCLUSIVE(v_organization_id, v_location_id);
  fetch c_ORDER_PRICE_EXCISE_INCLUSIVE into v_ORDER_PRICE_EXCISE_INCLUSIVE;
  close c_ORDER_PRICE_EXCISE_INCLUSIVE;
  */
  -------------------------------------------------------------------------
  -- Deleted by Jia Li for Tax inclusive Computations on 2007/11/22 End

  FOR TAX_TYPE_REC IN TAX_TYPE_CUR
  LOOP
    SELECT COUNT(*) INTO v_counter
    FROM   JAI_AR_TRX_INS_LINES_T b
    WHERE  b.LINK_TO_CUST_TRX_LINE_ID = pr_new.Customer_Trx_Line_Id
      AND  b.customer_trx_line_id = Tax_Type_Rec.LINE_ID;

--IF nvl(v_ORDER_PRICE_EXCISE_INCLUSIVE,'N') = 'Y' then   -- date 15/06/2007 sacsethi for bug 6131957 -- Deleted by Jia Li for Tax inclusive Computations on 2007/11/22, TD18

 IF NVL(v_register_code,'N') IN ('23D_EXPORT_WITHOUT_EXCISE','23D_EXPORT_EXCISE',
                        '23D_DOMESTIC_EXCISE','23D_DOM_WITHOUT_EXCISE','BOND_REG') THEN
    --jai_constants.tax_type_sh_exc_edu_cess,jai_constants.tax_type_sh_cvd_edu_cess  added by csahoo for bug#6081806
    IF Tax_Type_Rec.T_Type IN ('Excise','Addl. Excise','Other Excise','EXCISE_EDUCATION_CESS','CVD_EDUCATION_CESS',jai_constants.tax_type_sh_exc_edu_cess,jai_constants.tax_type_sh_cvd_edu_cess) THEN
    TAX_TYPE_REC.tax_amt := 0;
    END IF;
  END IF;

--end if ;  -- Deleted by Jia Li for Tax inclusive Computations on 2007/11/22, TD18

  /*
        Date 14-jun-2007 by sacsethi for bug 6072461
  */

     IF ( upper(Tax_Type_Rec.T_Type) = 'VAT REVERSAL' )
     THEN
        TAX_TYPE_REC.tax_amt := 0;
     END IF;

  /*
  || added by CSahoo - bug# 5390583 In case of bond reg , the excise taxes should not go to base AR tables.
  */
  IF NVL(v_register_code,'N') = 'BOND_REG' THEN
    -- jai_constants.tax_type_sh_exc_edu_cess,jai_constants.tax_type_sh_cvd_edu_cess added by csahoo for bug#6081806
     IF upper(Tax_Type_Rec.T_Type) IN ('EXCISE','ADDL. EXCISE','OTHER EXCISE','EXCISE_EDUCATION_CESS','CVD_EDUCATION_CESS',jai_constants.tax_type_sh_exc_edu_cess,jai_constants.tax_type_sh_cvd_edu_cess) THEN
        TAX_TYPE_REC.tax_amt := 0;
     END IF;
  END IF;

  /*
  || Ends additions by CSahoo - bug# 5390583
  */

  OPEN  Insert_Update_Cur(TAX_TYPE_REC.line_id);
  FETCH Insert_Update_Cur INTO v_insert_update_flag;
  CLOSE Insert_Update_Cur;
IF NVL(v_insert_update_flag,'I') <> 'X' THEN
  IF TAX_TYPE_REC.t_type = 'Freight' THEN
    v_line_type := 'FREIGHT';
  ELSE
    v_line_type := 'TAX';
  END IF;

  IF tax_type_rec.t_type = 'TDS' THEN
    tax_type_rec.tax_amt := 0;
  END IF;

  /*
  || Code modified by aiyer for the bug 4279702.
  || Initializing the regime variables
  */
  ln_regime_id   := null;
  ln_regime_code := null;

  /*
  || Get the regime attached to a transaction tax type
  */
  OPEN  cur_chk_rgm  ( cp_tax_type => tax_type_rec.t_type);
  FETCH cur_chk_rgm  INTO ln_regime_id,ln_regime_code ;
  CLOSE cur_chk_rgm  ;

  -- Start of bug 4089440
  /*
  || The following code has been added by aiyer for the bug 4089440
  || IF tax type is SERVICE or SERVICE-CESS then get the account info from regime setup
  || IF no setup is found then raise an error and stop the transaction.
  */
  IF   upper(tax_type_rec.t_type) = upper(jai_constants.tax_type_service)       OR
       upper(tax_type_rec.t_type) = upper(jai_constants.tax_type_service_edu_cess)
       OR upper(tax_type_rec.t_type)= upper(jai_constants.tax_type_sh_service_edu_cess)  -- added by csahoo for bug#6081806
  THEN   -- Start of A1

    /*################################################################################################################
    || Get the regime id and also validate the Regime/Regime Registratiom Setup Information
    ################################################################################################################*/

    jai_ar_rgm_processing_pkg.get_regime_info    ( p_regime_code    => jai_constants.service_regime ,
                                                  p_tax_type_code  => tax_type_rec.t_type              ,
                                                  p_regime_id      => ln_regime_id                     ,
                                                  p_error_flag     => lv_error_flag                    ,
                                                  p_error_message  => lv_error_message
                                                );

    IF lv_error_flag <> jai_constants.successful THEN
      /*
      || Encountered an error from the call to jai_ar_rgm_processing_pkg.get_regime_info
      || Stop processing and thorw an error
      */
/*       raise_application_error (-20130,lv_error_message); */ pv_return_code := jai_constants.expected_error ; pv_return_message := lv_error_message ; return ;
          /*
      app_exception.raise_exception( EXCEPTION_TYPE  => 'APP',
                                      EXCEPTION_CODE => NULL ,
                                      EXCEPTION_TEXT => lv_error_message
                                   );
          */

    END IF;

    /*################################################################################################################
    || Get Tax Account Info from the Regime Organization/Regime Registration setup
    ################################################################################################################*/

    /*
    || Get the code combination id from the Organization/Regime Registration setup
    || by calling the function jai_cmn_rgm_recording_pkg.get_account
    */

    v_ccid := jai_cmn_rgm_recording_pkg.get_account (
                                                       p_regime_id             => ln_regime_id                              ,
                                                       p_organization_type     => jai_constants.service_tax_orgn_type       ,
                                                       p_organization_id       => v_organization_id                                  ,
                                                       p_location_id           => v_location_id                           ,
                                                       p_tax_type              => tax_type_rec.t_type                       ,
                                                       p_account_name          => jai_constants.liability_interim
                                                     );

    IF v_ccid IS NULL THEN
      /*
      || Code Combination id has been returned as null from the function jai_cmn_rgm_recording_pkg.get_account
      || This is an error condition and the current processing has to be stopped
      */
/*       raise_application_error (-20130,'Invalid Code combination, please check the Service Tax - Tax Accounting Setup'); */
pv_return_code := jai_constants.expected_error ; pv_return_message :=  'Invalid Code combination,please check the Service Tax - Tax Accounting Setup' ; return ;
          /*
      app_exception.raise_exception( EXCEPTION_TYPE  => 'APP',
                                      EXCEPTION_CODE => NULL ,
                                      EXCEPTION_TEXT => 'Invalid Code combination, please check the Service Tax - Tax Type Accounting Setup'
                                   );
                                                                   */

    END IF;


     /*
     || Start of bug 4212816
     || Code modified by aiyer for the VAT Enhancement
     || Get the Tax accounting information from the vat regime setup when the taxes are as mentioned below taxes
     */
     ELSIF UPPER(nvl(ln_regime_code,'####')) = jai_constants.vat_regime THEN

       /*********************************************************************************************************
       || Validate whether the item attached is vatable or not
       *********************************************************************************************************/
  if pr_new.inventory_item_id is not null then  /*Bug 5671400 bduvarag*/
       jai_inv_items_pkg.jai_get_attrib (
                                        p_regime_code         =>  ln_regime_code                                                 ,
                                        p_organization_id     =>  v_organization_id                              ,
                                        p_inventory_item_id   =>  pr_new.inventory_item_id                 ,
                                        p_attribute_code      =>  jai_constants.rgm_attr_item_applicable ,
                                        p_attribute_value     =>  lv_attr_value                                                  ,
                                        p_process_flag        =>  lv_error_flag                          ,
                                        p_process_msg         =>  lv_error_message
                                       ) ;

       IF lv_error_flag <> jai_constants.successful THEN
         /*
         || Encountered an error from the call to jai_ar_rgm_processing_pkg.get_regime_info
         || Stop processing and thorw an error
         */
/*          raise_application_error (-20130,lv_error_message); */ pv_return_code := jai_constants.expected_error ; pv_return_message := lv_error_message ; return ;
                 /*
         app_exception.raise_exception( EXCEPTION_TYPE  => 'APP',
                                         EXCEPTION_CODE => NULL ,
                                         EXCEPTION_TEXT => lv_error_message
                                      );
         */

       END IF;
  END IF; /*Bug 5671400 bduvarag*/
       /*********************************************************************************************************
       || Raise an error if item is not vatable
       *********************************************************************************************************/
          IF pr_new.inventory_item_id is not null
     and nvl(lv_attr_value,'N')  = 'N' THEN /*Bug 5671400 bduvarag */

         /*
         || Item is not vatable . Stop processing and throw an error
         */
/*          raise_application_error (-20130,'ITEM not vatable'); */ pv_return_code := jai_constants.expected_error ; pv_return_message := 'ITEM not vatable' ; return ;
                 /* DO not delete this code, enable this code while doing the messageing project
         app_exception.raise_exception( EXCEPTION_TYPE  => 'APP',
                                        EXCEPTION_CODE => NULL ,
                                        EXCEPTION_TEXT => 'Cannot attach VAT type of taxes to non vatable items.'
                                      );
        */


           END IF;

       /*################################################################################################################
       || Get Tax Account Info from the Regime Organization/Regime Registration setup
       ################################################################################################################*/

       /*
       || Get the code combination id from the Organization/Regime Registration setup
       || by calling the function jai_cmn_rgm_recording_pkg.get_account
       */

       v_ccid := jai_cmn_rgm_recording_pkg.get_account (
                                                          p_regime_id             => ln_regime_id                              ,
                                                          p_organization_type     => jai_constants.orgn_type_io                ,
                                                          p_organization_id       => v_organization_id                         ,
                                                          p_location_id           => v_location_id                             ,
                                                          p_tax_type              => tax_type_rec.t_type                       ,
                                                          p_account_name          => jai_constants.liability_interim
                                                        );
       IF v_ccid IS NULL THEN
         /*
         || Code Combination id has been returned as null from the function jai_cmn_rgm_recording_pkg.get_account
         || This is an error condition and the current processing has to be stopped
         */
/*          raise_application_error (-20130,'Invalid Code combination ,please check the VAT Tax - Tax Accounting Setup'); */
pv_return_code := jai_constants.expected_error ; pv_return_message := 'Invalid Code combination ,please check the VAT Tax - Tax Accounting Setup' ; return ;
                 /*
         app_exception.raise_exception( EXCEPTION_TYPE  => 'APP',
                                        EXCEPTION_CODE => NULL ,
                                        EXCEPTION_TEXT => 'Invalid Code combination ,please check the VAT Tax - Tax Type Accounting Setup'
                                      );
                 */
       END IF;

     /*
     || End of bug 4212816
     */


  /* Added by CSahoo for the TCS enhancements Bug# 5631784 */
    ELSIF  UPPER(nvl(ln_regime_code,'####')) = jai_constants.tcs_regime THEN -- Start of A1

      /*********************************************************************************************************
      || Get the code combination id from the Organization/Regime Registration setup
      || by calling the function jai_rgm_trx_recording_pkg.get_account
      *********************************************************************************************************/


      v_ccid := jai_cmn_rgm_recording_pkg.get_account (
                                                         p_regime_id             => ln_regime_id                              ,
                                                         p_organization_type     => jai_constants.orgn_type_io                ,
                                                         p_organization_id       => v_organization_id                         ,
                                                         p_location_id           => v_location_id                             ,
                                                         p_tax_type              => tax_type_rec.t_type                       ,
                                                         p_account_name          => jai_constants.liability_interim
                                                       );
      IF v_ccid IS NULL THEN
        /**********************************************************************************************************
        || Code Combination id has been returned as null from the function jai_rgm_trx_recording_pkg.get_account
        || This is an error condition and the current processing has to be stopped
        **********************************************************************************************************/
       raise_application_error (-20130,'Invalid Code combination ,please check the TCS Tax - Tax Accounting Setup');

      END IF;

    /*End of bug 5631784 */

    ELSE -- ELSE of A1
      /*
      || As tax type is not SERVICE hence
      || get code combination from tax definition setup
      */
       OPEN  TAX_CCID_CUR(TAX_TYPE_REC.taxid);
       FETCH TAX_CCID_CUR INTO v_ccid;
       CLOSE TAX_CCID_CUR;
  END IF;

  IF NVL(v_counter,0) = 0 THEN
   INSERT INTO JAI_AR_TRX_INS_LINES_T (
     -- paddr,
 -- 6842749
        extended_amount,
        customer_trx_line_id,
    customer_trx_id,
    set_of_books_id,
    link_to_cust_trx_line_id,
    line_type,
    uom_code,
    vat_tax_id,
    acctd_amount,
    amount,
    CODE_COMBINATION_ID,
    cust_trx_line_sales_rep_id,
        insert_update_flag,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    tax_rate,  -- Tax_rate column added by Jagdish/Subbu 10-Jun-01
        Source, -- Source Column added by Sriram / Pavan
        org_id ,  -- org_id column added by sriram - bug # 2779967
        line_number ) -- added by sriram - bug # 2769439
    VALUES(
        --  v_paddr,
 -- 6842749
    round(TAX_TYPE_REC.tax_amt,ln_inv_curr_precision), /* rounding based on inv currency precision - bug# 5364120*/
    TAX_TYPE_REC.line_id,
    v_customer_trx_id,
    v_books_id,
    pr_new.customer_trx_line_id,
    v_line_type,
    TAX_TYPE_REC.uom,
    ln_tax_rate_id, --v_vat_tax, /* Modified by Ramananda for bug#4468353 due to ebtax uptake by AR */
        v_converted_rate * TAX_TYPE_REC.tax_amt,
    round(TAX_TYPE_REC.tax_amt,ln_inv_curr_precision), /* rounding based on inv currency precision - bug# 5364120*/
    v_ccid,
    v_salesrep_id,
    'U',
    pr_new.last_update_date,
    pr_new.last_updated_by,
    pr_new.creation_date,
    pr_new.created_by,
    pr_new.last_update_login,
    TAX_TYPE_REC.tax_rate, --- Tax_rate column added by Jagdish/Subbu 10-Jun-01
        v_Created_from,   -- v_created_from column added by Sriram - 09-MAY-2002
        v_org_id      , -- added by sriram bug # 2779967
        tax_type_rec.tax_line_no) ; -- added by sriram - bug # 2769439
   ELSE
    UPDATE JAI_AR_TRX_INS_LINES_T
    SET    extended_amount = TAX_TYPE_REC.tax_amt,
         set_of_books_id = v_books_id,
         line_type = v_line_type,
         uom_code = TAX_TYPE_REC.uom,
         acctd_amount = v_converted_rate * TAX_TYPE_REC.tax_amt,
         amount  = TAX_TYPE_REC.tax_amt,
         insert_update_flag = 'U',
         tax_rate=TAX_TYPE_REC.tax_rate  -- Tax_rate column added by Jagdish/Subbu 10-Jun-01
        WHERE  customer_trx_id = v_customer_trx_id
    AND    customer_trx_line_id = TAX_TYPE_REC.line_id;
  END IF;
END IF;
  END LOOP;
-- the following if condition added by sriram - 09-MAY-2002
-- this is added because the AR Tax and Freight Defaultation should be called only
-- if it is a manual invoice.
IF v_created_from = 'ARXTWMAI' THEN
  result := fnd_request.set_mode(TRUE);
  req_id := fnd_request.submit_request('JA', 'JAILINEGL', 'AR Tax and Freight Defaultation', SYSDATE, FALSE,
            v_customer_trx_id, pr_old.customer_trx_line_id);
  /*Bug 8371741 - Start*/
  BEGIN
    SELECT max(jattl.tax_line_no) INTO l_tcs_sur_line_num
    FROM JAI_AR_TRX_TAX_LINES jattl, jai_cmn_taxes_all jcta
    WHERE jattl.link_to_cust_trx_line_id = pr_new.customer_trx_line_id
    AND jattl.tax_id = jcta.tax_id
    AND jcta.tax_type = jai_constants.tax_type_tcs_surcharge
    GROUP BY jcta.tax_type;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        l_tcs_sur_line_num := 0;
  END;

  BEGIN
    SELECT count(jattl.tax_line_no) INTO l_tot_tax_lines
  FROM JAI_AR_TRX_TAX_LINES jattl
  WHERE jattl.link_to_cust_trx_line_id = pr_new.customer_trx_line_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
         RETURN;
  END;

  if (pr_new.tax_category_id is NULL and l_tcs_sur_line_num = 0) then
      if (c_conversion_date is NULL) then
        SELECT trx_date INTO c_conversion_date
      FROM ra_customer_trx_all
      WHERE customer_trx_id = v_customer_trx_id;
    end if;

    OPEN  transaction_type_cur;
      FETCH transaction_type_cur INTO v_trans_type;
      CLOSE transaction_type_cur;

      IF NVL(v_trans_type,'N') Not in ( 'INV','CM') THEN -- 'CM' added ssumaith - bug# 3957682
         Return;
      END IF;

      v_line_amount      := nvl(pr_new.quantity * pr_new.unit_selling_price,0);
      v_quantity         := pr_new.quantity;

    v_line_tax_amount := nvl(v_line_amount,0);

    BEGIN
      SELECT max(jattl.tax_line_no) INTO l_tcs_line_num
      FROM JAI_AR_TRX_TAX_LINES jattl, jai_cmn_taxes_all jcta
      WHERE jattl.link_to_cust_trx_line_id = pr_new.customer_trx_line_id
      AND jattl.tax_id = jcta.tax_id
      AND jcta.tax_type = jai_constants.tax_type_tcs
      GROUP BY jcta.tax_type;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
             RETURN;
      END;

    IF (l_tcs_line_num > 0) then
            /** TCS type of tax(s) are present */
              open  gc_get_regime_id ( cp_regime_code => jai_constants.tcs_regime);
              fetch gc_get_regime_id into ln_tcs_regime_id;
              close gc_get_regime_id;

        open bind_cur;
        fetch bind_cur into l_org_id, l_bill_to_customer_id, l_bill_to_site_use_id, ln_trx_date;
        close bind_cur;

              SELECT organization_id into ln_organization_id
              FROM   JAI_AR_TRXS
              WHERE  customer_trx_id = pr_new.customer_trx_id;

              jai_rgm_thhold_proc_pkg.get_threshold_slab_id
                                        (   p_regime_id         =>    ln_tcs_regime_id
                                          , p_organization_id   =>    ln_organization_id
                                          , p_party_type        =>    jai_constants.party_type_customer
                                          , p_party_id          =>    l_bill_to_customer_id
                                          , p_org_id            =>    l_org_id
                                          , p_source_trx_date   =>    ln_trx_date /* ssumaith - bug# 6109941*/
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
                                        ,  p_org_id               =>    l_org_id
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

        select max(jattl.tax_line_no) into l_max_tax_line_no
        from JAI_AR_TRX_TAX_LINES jattl
        where jattl.link_to_cust_trx_line_id = pr_new.customer_trx_line_id;

        jai_cmn_tax_defaultation_pkg.ja_in_calc_prec_taxes
              (
               transaction_name         => 'AR_LINES',
               p_tax_category_id        => -1,
               p_header_id              => pr_new.customer_trx_id,
               p_line_id                => pr_new.customer_trx_line_id,
               p_assessable_value       => pr_new.assessable_value * pr_new.quantity,
               p_tax_amount             => ln_tax_amount,
               p_inventory_item_id      => pr_new.inventory_item_id,
               p_line_quantity          => pr_new.quantity,
               p_uom_code               => pr_new.unit_code,
               p_vendor_id              => NULL,
               p_currency               => NULL,
               p_currency_conv_factor   => NVL(v_converted_rate, 1),
               p_creation_date          => sysdate,
               p_created_by             => FND_GLOBAL.user_id,
               p_last_update_date       => sysdate,
               p_last_updated_by        => FND_GLOBAL.user_id,
               p_last_update_login      => FND_GLOBAL.login_id,
               p_operation_flag         => NULL,
               p_vat_assessable_value   => pr_new.vat_assessable_value,
               p_thhold_cat_base_tax_typ =>   'TCS' ,
               p_threshold_tax_cat_id    =>   ln_threshold_tax_cat_id,
               p_source_trx_type         =>   null,
               p_source_table_name       =>   null,
               p_action                  =>   'DEFAULT_TAXES',
         p_max_tax_line            =>   l_max_tax_line_no ,
         p_max_rgm_tax_line        =>   l_tcs_line_num
              );
    end if; /*IF (l_tcs_line_num > 0) then*/

  end if; /*if (pr_new.tax_category_id is NULL) then*/
  /*Bug 8371741 - End*/

END IF;
   /* Added an exception block by Ramananda for bug#4570303 */
 EXCEPTION
   WHEN OTHERS THEN
     Pv_return_code     :=  jai_constants.unexpected_error;
     Pv_return_message  := 'Encountered an error in JAI_JAR_TL_TRIGGER_PKG.ARU_T1 '  || substr(sqlerrm,1,1900);

  END ARU_T1 ;

END JAI_JAR_TL_TRIGGER_PKG ;

/
