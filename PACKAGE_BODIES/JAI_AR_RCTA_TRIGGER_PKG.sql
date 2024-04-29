--------------------------------------------------------
--  DDL for Package Body JAI_AR_RCTA_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AR_RCTA_TRIGGER_PKG" AS
/* $Header: jai_ar_rcta_t.plb 120.17.12010000.9 2010/06/10 11:24:41 haoyang ship $ */

/*
  || foll function created by csahoo - for seperate vat invoice num for unreg dealers - bug# 5233925
  */

  FUNCTION  check_reg_dealer
            ( pn_customer_id      NUMBER  ,
              pn_site_use_id      NUMBER
            ) return boolean

  IS
   ln_address_id   NUMBER;
   lv_regno        JAI_CMN_CUS_ADDRESSES.vat_Reg_no%type;

   CURSOR c_get_address is
   SELECT hzcas.cust_acct_site_id
   FROM   hz_cust_site_uses_all         hzcsu ,
          hz_cust_acct_sites_all        hzcas
   WHERE  hzcas.cust_acct_site_id   =   hzcsu.cust_acct_site_id
   AND    hzcsu.site_use_id         =   pn_site_use_id
         AND    hzcas.cust_account_id     =   pn_customer_id ;

   CURSOR c_regno (pn_address_id NUMBER) IS
   SELECT vat_Reg_no
   FROM   JAI_CMN_CUS_ADDRESSES
   WHERE  customer_id = pn_customer_id
   AND    address_id  = pn_address_id;


  BEGIN

     open   c_get_address;
     fetch  c_get_address into ln_address_id;
     close  c_get_address;

     IF  ln_address_id IS NOT NULL THEN

       open   c_regno (ln_address_id);
       fetch  c_regno into lv_regno;
       close  c_regno;
     END IF;

     IF   lv_regno IS NULL THEN
        return (false);
     ELSE
         return (true);
     END IF;


  END  check_reg_dealer;

  /*
  || csahoo - for seperate vat invoice num for unreg dealers - bug# 5233925
  */

/*
  REM +======================================================================+
  REM NAME          ARI_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_AR_RCTA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_AR_RCTA_ARI_T8
  REM
  REM +======================================================================+
*/
  PROCEDURE ARI_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
    v_org_id              Number; --File.Sql.35 Cbabu  := -1;
  v_loc_id              Number ;
  v_reg_code            Varchar2(30);
  v_excise_invoice_no   Number;
  v_update_rg           Varchar2(1);     -- := 'Y'; --Ramananda for File.Sql.35
  v_update_rg23d_flag   Varchar2(1);   -- := 'Y'; --Ramananda for File.Sql.35
  v_reg_type            Varchar2(10);
  v_complete_flag       Varchar2(1);
  --v_row_id              rowid;  --File.Sql.35 Cbabu  := pr_new.rowid;
  v_parent_trx_number   Varchar2(20); --File.Sql.35 Cbabu  := pr_new.recurred_from_trx_number;
  v_trans_type          Varchar2(30);

  cursor loc_app_cur IS
  SELECT organization_id, location_id
  FROM JAI_AR_TRX_APPS_RELS_T ; /* Modified cursor by rallamse bug#4479131 PADDR Elimination */


  Cursor register_code_cur(p_org_id IN Number,  p_loc_id IN Number)  IS
  SELECT register_code
  FROM   JAI_OM_OE_BOND_REG_HDRS
  WHERE  organization_id = p_org_id AND location_id = p_loc_id   AND
   register_id in (SELECT register_id
         FROM   JAI_OM_OE_BOND_REG_DTLS
   WHERE  order_type_id = pr_new.batch_source_id and order_flag = 'N');

  Cursor organization_cur IS
  SELECT organization_id,location_id
  FROM   JAI_AR_TRXS
  WHERE  trx_number = v_parent_trx_number;

  Cursor transaction_type_cur IS
  Select type
  From   RA_CUST_TRX_TYPES_ALL
  Where  cust_trx_type_id = pr_new.cust_trx_type_id
  And    NVL(org_id,0) = NVL(pr_new.org_id,0);

  Cursor localization_header_info IS
  Select organization_id, location_id, update_rg_flag
  From   JAI_AR_TRXS
  Where  customer_trx_id= pr_new.previous_customer_trx_id;

v_currency_code        gl_sets_of_books.currency_code%type;
CURSOR curr(c_sob NUMBER) IS
SELECT currency_code
  FROM gl_sets_of_books
  WHERE set_of_books_id = c_sob;
V_CURR      CURR%ROWTYPE; --2002/03/11 Vijay
  BEGIN
    pv_return_code := jai_constants.successful ;
       /*------------------------------------------------------------------------------------------
 FILENAME: JA_IN_LOC_INFO_AR_HDR_TRG.sql

 CHANGE HISTORY:
S.No      Date      Author and Details
========================================

1.  10-Aug-2005  Aiyer bug 4545146 version 120.1
                 Issue:-
                   Deadlock on tables due to multiple triggers on the same table (in different sql files)
                   firing in the same phase.
                 Fix:-
                   Multiple triggers on the same table have been merged into a single file to resolve
                   the problem
                   The following files have been stubbed:-
                     jai_ar_rcta_t1.sql
                     jai_ar_rcta_t2.sql
                     jai_ar_rcta_t3.sql
                     jai_ar_rcta_t4.sql
                     jai_ar_rcta_t6.sql
                     jai_ar_rcta_t7.sql
                     jai_ar_rcta_t8.sql
                     jai_ar_rcta_t9.sql
                   Instead the new file jai_ar_rcta_t.sql has been created which contains all the triggers in the above files


Dependency Due to this Bug:-
The current trigger becomes dependent on the function jai_cmn_utils_pkg.check_jai_exists version 115.0.


Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Current Version    Current Bug    Dependent           Files                Version   Author   Date          Remarks
Of File                           On Bug/Patchset    Dependent On

ja_in_loc_info_ar_hdr_trg.sql
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

  v_update_rg          := 'Y'; --Ramananda for File.Sql.35
  v_update_rg23d_flag  := 'Y'; --Ramananda for File.Sql.35
  v_org_id               := -1;
  v_parent_trx_number   := pr_new.recurred_from_trx_number;

 OPEN curr(pr_new.set_of_books_id);
 FETCH curr into v_curr;
 CLOSE curr;

  OPEN  transaction_type_cur;
  FETCH transaction_type_cur INTO v_trans_type;
  CLOSE transaction_type_cur;
  IF NVL(v_trans_type,'N') NOT IN('CM','INV','DM') THEN
    Return;
  END IF;
  IF pr_new.created_from = 'ARXREC' THEN
    Insert Into JAI_AR_TRX_COPY_HDR_T
      (TRX_NUMBER, CUSTOMER_TRX_ID, RECURRED_FROM_TRX_NUMBER, BATCH_SOURCE_ID,
      CREATED_FROM, CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE,
      LAST_UPDATED_BY, LAST_UPDATE_LOGIN )
       VALUES
      (pr_new.trx_number, pr_new.CUSTOMER_TRX_ID, v_parent_trx_number, pr_new.BATCH_SOURCE_ID,
      pr_new.CREATED_FROM, pr_new.CREATION_DATE, pr_new.CREATED_BY, pr_new.LAST_UPDATE_DATE,
      pr_new.LAST_UPDATED_BY, pr_new.LAST_UPDATE_LOGIN);
  ELSE
    IF pr_new.created_from = 'ARXTWCMI' THEN
      IF pr_new.previous_customer_trx_id IS Not Null Then
        Open  localization_header_info;
        Fetch localization_header_info Into v_org_id, v_loc_id, v_update_rg;
        Close localization_header_info;
      ELSE
        Return;
      END IF;
    ELSE
      OPEN   loc_app_cur;
      FETCH  loc_app_cur INTO v_org_id,v_loc_id;
      CLOSE  loc_app_cur;

      IF NVL(v_org_id, 999999) = 999999 THEN -- changed 0 to 999999 because trigger was returning in case where
                                             -- setup business group is done. Bug # 2846277
        IF v_parent_trx_number IS NULL THEN
          RETURN;
        ELSE
          OPEN  organization_cur;
          FETCH organization_cur INTO v_org_id, v_loc_id;
          CLOSE organization_cur;
        END IF;
      END IF;
      IF NVL(v_org_id, 999999) = 999999 THEN -- changed 0 to 999999 because trigger was returning in case where
                                             -- setup business group is done. Bug # 2846277
        RETURN;
      END IF;

      OPEN   register_code_cur(v_org_id,v_loc_id);
      FETCH  register_code_cur INTO v_reg_code;
      CLOSE  register_code_cur;

      /*
       in the following if .. elsif block comparison to the register codes was done in lower case , which was in R11 , in R11i ,
       it is in upper case. - bug# 3496577
      */
      IF v_reg_code IS NULL THEN
        v_update_rg := 'N';
        v_update_rg23d_flag := 'N';
      ELSIF v_reg_code IN ('23D_DOMESTIC_EXCISE','23D_EXPORT_EXCISE','23D_EXPORT_WITHOUT_EXCISE','23D_DOM_WITHOUT_EXCISE') THEN
        v_update_rg23d_flag := 'Y';
        v_update_rg := 'N';
      ELSIF v_reg_code IN ('DOMESTIC_EXCISE','EXPORT_EXCISE','BOND_REG','DOM_WITHOUT_EXCISE') THEN
        v_update_rg := 'Y';
        v_update_rg23d_flag := 'N';
      END IF;
    END IF;

  -------
  INSERT INTO JAI_AR_TRXS
  (
    CUSTOMER_TRX_ID  ,
    ORGANIZATION_ID  ,
    LOCATION_ID      ,
    TRX_NUMBER       ,
    UPDATE_RG_FLAG   ,
    UPDATE_RG23d_FLAG,
    ONCE_COMPLETED_FLAG,
    BATCH_SOURCE_ID,
    SET_OF_BOOKS_ID,
    PRIMARY_SALESREP_ID,
    INVOICE_CURRENCY_CODE,
    EXCHANGE_RATE_TYPE,
    EXCHANGE_DATE,
    EXCHANGE_RATE,
    CREATED_FROM,
    CREATION_DATE  ,
    CREATED_BY    ,
    LAST_UPDATE_DATE ,
    LAST_UPDATE_LOGIN   ,
    LAST_UPDATED_BY,
    LEGAL_ENTITY_ID /* added rallamse bug#4448789 */
  )
  VALUES
  (
   pr_new.CUSTOMER_TRX_ID,
   V_ORG_ID,
   V_LOC_ID,
   pr_new.TRX_NUMBER,
   V_UPDATE_RG,
   v_update_rg23d_flag,
   pr_new.COMPLETE_FLAG,
   pr_new.BATCH_SOURCE_ID,
   pr_new.SET_OF_BOOKS_ID,
   pr_new.PRIMARY_SALESREP_ID,
   pr_new.INVOICE_CURRENCY_CODE,
   pr_new.EXCHANGE_RATE_TYPE,
   pr_new.EXCHANGE_DATE,
   pr_new.EXCHANGE_RATE,
   pr_new.CREATED_FROM,
   pr_new.CREATION_DATE,
   pr_new.CREATED_BY,
   pr_new.LAST_UPDATE_DATE,
   pr_new.LAST_UPDATE_LOGIN,
   pr_new.LAST_UPDATED_BY,
   pr_new.LEGAL_ENTITY_ID /* added rallamse bug#4448789 */
   );
  END IF;
  /* Added an exception block by Ramananda for bug#4570303 */
   EXCEPTION
     WHEN OTHERS THEN
       Pv_return_code     :=  jai_constants.unexpected_error;
       Pv_return_message  := 'Encountered an error in JAI_AR_RCTA_TRIGGER_PKG.ARI_T1  '  || substr(sqlerrm,1,1900);
  END ARI_T1 ;

  /*
  REM +======================================================================+
  REM NAME          ARU_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_AR_RCTA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_AR_RCTA_ARU_T2
  REM
  REM +======================================================================+
  */
  PROCEDURE ARU_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
    /*
    start additions by sriram for VAT
  */

   v_vat_start_num     JAI_CMN_INVENTORY_ORGS.current_number%Type;
   v_vat_jump_by       JAI_CMN_INVENTORY_ORGS.jump_by%type;
   v_vat_prefix        JAI_CMN_INVENTORY_ORGS.prefix%type;
   v_vat_invoice_no    JAI_AR_TRXS.tax_invoice_no%type;
   v_vat_reg_no        JAI_CMN_INVENTORY_ORGS.vat_reg_no%type;


   v_organization_id   Number;
   v_loc_id            Number;
   v_vat_taxes_exist   Number;
   v_trans_type        VARCHAR2(30);
   v_loc_vat_inv_no    JAI_AR_TRXS.tax_invoice_no%type;

   CURSOR organization_cur IS
   SELECT organization_id,location_id
   FROM   JAI_AR_TRXS
   where  customer_trx_id = pr_new.customer_trx_id;

   CURSOR C_VAT_INVOICE_CUR IS
   SELECT TAX_INVOICE_NO
   FROM   JAI_AR_TRXS
   WHERE  Customer_Trx_Id = pr_new.customer_trx_id;


   cursor c_vat_taxes_exist
   is
   select 1
   from   JAI_AR_TRX_TAX_LINES
   where link_to_cust_trx_line_id
     in
     (select customer_trx_line_id
    from   JAI_AR_TRX_LINES
    where  customer_trx_id = pr_new.customer_trx_id
    )
    and tax_id in
    (select tax_id
     from   JAI_CMN_TAXES_ALL
     where  vat_flag = 'Y'
     and org_id = pr_new.org_id
    )
    ;

    CURSOR transaction_type_cur IS
    SELECT TYPE
    FROM   RA_CUST_TRX_TYPES_ALL
    WHERE  cust_trx_type_id = pr_new.cust_trx_type_id
    AND    NVL(org_id,0) = NVL(pr_new.org_id,0);


   Procedure   Generate_Tax_Invoice_no (p_organization_id Number , p_loc_id Number) is

    Cursor c_get_vat_reg_no is
    select vat_reg_no
    from   JAI_CMN_INVENTORY_ORGS
    where  organization_id = p_organization_id
    and    location_id = p_loc_id;

    cursor c_get_vat_invoice_no is
    select current_number , jump_by , prefix
    from   JAI_CMN_INVENTORY_ORGS
    where  organization_id = p_organization_id
    and    location_id = p_loc_id;



   Begin

    open  c_get_vat_reg_no;
    fetch c_get_vat_reg_no into v_vat_reg_no;
    close c_get_vat_reg_no;

    if v_vat_reg_no is null then
      -- VAT reg number has not been defined for the org and loc.
      return;
    end if;


    -- lock the records
    update JAI_CMN_INVENTORY_ORGS
    set    last_update_date = last_update_date
    where  vat_reg_no = v_vat_reg_no;

    Open  c_get_vat_invoice_no;
    Fetch c_get_vat_invoice_no into  v_vat_start_num,  v_vat_jump_by, v_vat_prefix;
    close c_get_vat_invoice_no;

    v_vat_start_num := NVL(v_vat_start_num,0) + NVL(v_vat_jump_by,1);

    if v_vat_prefix is not null then
       v_vat_invoice_no := v_vat_prefix || '/' || v_vat_start_num;
    else
       v_vat_invoice_no :=  v_vat_start_num;
    end if;

    update JAI_AR_TRXS
    set    tax_invoice_no = v_vat_invoice_no
    where  customer_trx_id = pr_new.customer_trx_id;

    update JAI_CMN_INVENTORY_ORGS
    set    current_number = NVL(v_vat_start_num,0) ,
           prefix         = v_vat_prefix,
           jump_by        = v_vat_jump_by
    where  vat_Reg_no = v_vat_reg_no;

   End;


/*
    end additions by sriram for VAT
*/
/******************************************************************************************************************
File name : jai_ar_gen_tax_inv_upd_trg.sql
Created By    Aiyer

Created Date  31-Mar-2005

Bug           4276502

Purpose     : Support the old vat Functionality . The ja_in_loc_ar_hdr_upd_trg_vat 115.2 now supports the new vat functionality for Credit Memo.
              This trigger supports the same for the Invoice .The code in this trigger is the same as that which existed in the trigger
              ja_in_loc_ar_hdr_upd_trg_vat 115.1.
              Tax invoice number to be generated when an Auto_invoiced invoice is imported or when a manual invoice is completed.

1.   08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old
                    DB Entity as required for CASE COMPLAINCE.  Version 116.1

Dependency Due to this Bug:-
IN60106 + 4245089 (VAT Enhancement)

2. 13-Jun-2005    File Version: 116.2
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done



3.  10-Aug-2005  Aiyer bug 4545146 version 120.1
                 Issue:-
                   Deadlock on tables due to multiple triggers on the same table (in different sql files)
                   firing in the same phase.
                 Fix:-
                   Multiple triggers on the same table have been merged into a single file to resolve
                   the problem
                   The following files have been stubbed:-
                     jai_ar_rcta_t1.sql
                     jai_ar_rcta_t2.sql
                     jai_ar_rcta_t3.sql
                     jai_ar_rcta_t4.sql
                     jai_ar_rcta_t6.sql
                     jai_ar_rcta_t7.sql
                     jai_ar_rcta_t8.sql
                     jai_ar_rcta_t9.sql
                   Instead the new file jai_ar_rcta_t.sql has been created which contains all the triggers

Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Current Version    Current Bug    Dependent           Files                Version   Author   Date          Remarks
Of File                           On Bug/Patchset    Dependent On

jai_ar_gen_tax_inv_upd_trg.sql
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
4. 02-MAR-2007   SSAWANT , File version 120.6
                 Forward porting the change in 11.5 bug 4998378 to R12 bug no 5040383.
                 1) Moved the opening/fetching/closing of the cursors - transaction_type_cur, Complete_Cur
Future Dependency due to this Bug
--------------------------
None
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

  BEGIN
    pv_return_code := jai_constants.successful ;
    Open  C_VAT_INVOICE_CUR;
    Fetch C_VAT_INVOICE_CUR  into  v_loc_vat_inv_no;
    close C_VAT_INVOICE_CUR;

    if v_loc_vat_inv_no is not null then
       return;
    end if;

    OPEN  transaction_type_cur;
    FETCH transaction_type_cur INTO v_trans_type;
    CLOSE transaction_type_cur;

    IF NVL(v_trans_type,'N') <> 'INV' THEN
       -- VAT invoice number should be generated only for an Invoice and not for others like cm for RMA.
       RETURN;
    END IF;


   OPEN  organization_cur;
   FETCH organization_cur INTO v_organization_id, v_loc_id;
   CLOSE organization_cur;

   Open  c_vat_taxes_exist;
   Fetch c_vat_taxes_exist into v_vat_taxes_exist;
   Close c_vat_taxes_exist;

   if v_vat_taxes_exist = 1 then
      Generate_Tax_Invoice_no(v_organization_id,v_loc_id);
   end if;
  /* Added an exception block by Ramananda for bug#4570303 */
   EXCEPTION
     WHEN OTHERS THEN
       Pv_return_code     :=  jai_constants.unexpected_error;
       Pv_return_message  := 'Encountered an error in JAI_AR_RCTA_TRIGGER_PKG.ARU_T1  '  || substr(sqlerrm,1,1900);
  END ARU_T1 ;

  /*
  REM +======================================================================+
  REM NAME          ARU_T2
  REM
  REM DESCRIPTION   Called from trigger JAI_AR_RCTA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_AR_RCTA_ARU_T3
  REM
  REM +======================================================================+
  */
  PROCEDURE ARU_T2 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
    v_trans_type    Varchar2(30);
  v_trx_number    varchar2(30);   -- := pr_new.Trx_Number;    --Ramananda for File.Sql.35
  v_ref_line_id   varchar2(30);   -- := pr_new.interface_header_attribute7; --Ramananda for File.Sql.35

  Cursor transaction_type_cur IS
  Select type
  From   RA_CUST_TRX_TYPES_ALL
  Where  cust_trx_type_id = pr_new.cust_trx_type_id
  And    NVL(org_id,0) = NVL(pr_new.org_id,0);

  v_currency_code   gl_sets_of_books.currency_code%type;
  BEGIN
    pv_return_code := jai_constants.successful ;
    /*------------------------------------------------------------------------------------------
 FILENAME:JA_IN_TRX_HDR_UPDATE_TRG.sql

 CHANGE HISTORY:
S.No      Date          Author and Details
------------------------------------------------------------------------------------------
1.  10-Aug-2005  Aiyer bug 4545146 version 120.1
                 Issue:-
                   Deadlock on tables due to multiple triggers on the same table (in different sql files)
                   firing in the same phase.
                 Fix:-
                   Multiple triggers on the same table have been merged into a single file to resolve
                   the problem
                   The following files have been stubbed:-
                     jai_ar_rcta_t1.sql
                     jai_ar_rcta_t2.sql
                     jai_ar_rcta_t3.sql
                     jai_ar_rcta_t4.sql
                     jai_ar_rcta_t6.sql
                     jai_ar_rcta_t7.sql
                     jai_ar_rcta_t8.sql
                     jai_ar_rcta_t9.sql
                   Instead the new file jai_ar_rcta_t.sql has been created which contains all the triggers

Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Current Version    Current Bug    Dependent           Files                Version   Author   Date          Remarks
Of File                           On Bug/Patchset    Dependent On

ja_in_trx_hdr_update_trg.sql
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

  v_trx_number    := pr_new.Trx_Number;     --Ramananda for File.Sql.35
  v_ref_line_id   := pr_new.interface_header_attribute7;  --Ramananda for File.Sql.35


  IF pr_new.created_from = 'RAXTRX' THEN
    IF pr_new.CUSTOMER_TRX_ID <> pr_old.CUSTOMER_TRX_ID
    THEN
      Update JAI_AR_TRXS
      Set    Customer_Trx_ID = pr_new.Customer_Trx_ID
      Where  Customer_Trx_ID = pr_old.Customer_Trx_ID;
      Update JAI_AR_TRX_LINES
      Set    Customer_Trx_Id = pr_new.Customer_Trx_ID
      Where  Customer_Trx_ID = pr_old.Customer_Trx_ID;
    END IF;


    Update JAI_AR_TRXS
    Set    Trx_Number = pr_new.Trx_Number
    Where  Customer_Trx_ID = pr_new.Customer_Trx_ID;
  END IF;

  OPEN  transaction_type_cur;
  FETCH transaction_type_cur INTO v_trans_type;
  CLOSE transaction_type_cur;
  IF NVL(v_trans_type,'N') in ('CM','DM') THEN

    -- Start, Vijay Shankar for bug # 3181921
    IF pr_new.created_from = 'RAXTRX' THEN
    Update JAI_AR_TRXS
    Set    Trx_Number = pr_new.Trx_Number
    Where  Customer_Trx_ID = pr_new.Customer_Trx_ID;
  ELSE
  -- End, Vijay Shankar for bug # 3181921

    Update JAI_AR_TRXS
    Set    Trx_Number = pr_new.Trx_Number
       , Once_Completed_Flag = NVL(pr_new.Complete_Flag,'N')
    Where  Customer_Trx_ID = pr_new.Customer_Trx_ID;
  END IF;

  ELSIF NVL(v_trans_type,'N') = 'INV' THEN
    Update JAI_AR_TRXS
    Set    Trx_Number = pr_new.Trx_Number
    Where  Customer_Trx_ID = pr_new.Customer_Trx_ID;
  END IF;
  /* Added an exception block by Ramananda for bug#4570303 */
   EXCEPTION
     WHEN OTHERS THEN
       Pv_return_code     :=  jai_constants.unexpected_error;
       Pv_return_message  := 'Encountered an error in JAI_AR_RCTA_TRIGGER_PKG.ARU_T2  '  || substr(sqlerrm,1,1900);
  END ARU_T2 ;

  /*
REM +======================================================================+
  REM NAME          ARU_T3
  REM
  REM DESCRIPTION   Called from trigger JAI_AR_RCTA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_AR_RCTA_ARU_T4
  REM
  REM +======================================================================+
*/
  PROCEDURE ARU_T3 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
   v_organization_id       NUMBER                                       ;
   v_loc_id                NUMBER                                       ;
   v_trans_type            RA_CUST_TRX_TYPES_ALL.TYPE%TYPE              ;
   lv_vat_invoice_no       JAI_AR_TRXS.VAT_INVOICE_NO%TYPE    ;
   ln_regime_id      JAI_RGM_DEFINITIONS.REGIME_ID%TYPE                   ;
   ln_regime_code          JAI_RGM_DEFINITIONS.REGIME_CODE%TYPE                 ;
   lv_process_flag         VARCHAR2(10)                                 ;
   lv_process_message      VARCHAR2(4000)                               ;
   ld_gl_date              RA_CUST_TRX_LINE_GL_DIST_ALL.GL_DATE%TYPE    ;
   ld_vat_invoice_date     JAI_AR_TRXS.VAT_INVOICE_DATE%TYPE  ;


   /*
   || Get the organization, location, vat_invoice_no and vat_invoice_date from JAI_AR_TRXS
   */
   CURSOR organization_cur
   IS
   SELECT
          organization_id   ,
          location_id   ,
      vat_invoice_no    ,
          vat_invoice_date
   FROM
          JAI_AR_TRXS
   WHERE
          customer_trx_id = pr_new.customer_trx_id;

  /*
  || Get the transaction type of the document
  */
  CURSOR transaction_type_cur
  IS
  SELECT
          type
  FROM
          ra_cust_trx_types_all
  WHERE
          cust_trx_type_id  = pr_new.cust_trx_type_id   AND
          NVL(org_id,0)   = NVL(pr_new.org_id,0);


   /*
   || Check whether vat types of taxes exist for the CM.
   || IF yes then get the regime id and regime code
   */
   CURSOR cur_vat_taxes_exist
   IS
   SELECT
          regime_id   ,
          regime_code
   FROM
          JAI_AR_TRX_TAX_LINES jcttl,
          JAI_AR_TRX_LINES jctl,
          JAI_CMN_TAXES_ALL             jtc ,
          jai_regime_tax_types_v      jrttv
   WHERE
          jcttl.link_to_cust_trx_line_id  = jctl.customer_trx_line_id           AND
          jctl.customer_trx_id            = pr_new.customer_trx_id                AND
          jcttl.tax_id                    = jtc.tax_id                          AND
          jtc.tax_type                    = jrttv.tax_type                      AND
          regime_code                     = jai_constants.vat_regime            AND
          jtc.org_id                      = pr_new.org_id ;


  CURSOR  cur_get_gl_date(cp_acct_class ra_cust_trx_line_gl_dist_all.account_class%type)
  IS
  SELECT
          gl_date
  FROM
          ra_cust_trx_line_gl_dist_all
  WHERE
          customer_trx_id = pr_new.customer_trx_id   AND
          account_class   = cp_acct_class          AND /*--'REC'                  AND*/
          latest_rec_flag = 'Y';

  CURSOR  cur_get_in_vat_no
  IS
  SELECT
          vat_invoice_no
  FROM
          JAI_AR_TRXS
  WHERE
          customer_trx_id = pr_new.previous_customer_trx_id;

 /*
    || Added by kunkumar for bug#5645003
    || Check if only 'VAT REVERSAL' tax type is present in ja_in_ra_cust_trx_tax_lines
    */
    CURSOR c_chk_vat_reversal (cp_tax_type jai_cmn_taxes_all.tax_type%TYPE )
     IS
     SELECT
              1
     FROM
            JAI_AR_TRX_TAX_LINES jcttl,
            JAI_AR_TRX_LINES jctl,
            JAI_CMN_TAXES_ALL            jtc
     WHERE
            jcttl.link_to_cust_trx_line_id  = jctl.customer_trx_line_id    AND
            jctl.customer_trx_id            = pr_new.customer_trx_id        AND
            jcttl.tax_id                    = jtc.tax_id                   AND
            jtc.org_id                      = pr_new.org_id                 AND
            jtc.tax_type                    = cp_tax_type ;

    lv_vat_reversal   VARCHAR2(30);
    ln_vat_reversal_exists  NUMBER;

   /*
   || Retrieve the regime_id which is of regime code 'VAT'
   */
      CURSOR c_get_regime_id
      IS
      SELECT
           regime_id
      FROM
           jai_regime_tax_types_v
      WHERE
           regime_code = jai_constants.vat_regime
      AND  rownum       = 1 ;
/******************************************************************************************************************
File name : ja_in_loc_ar_hdr_upd_trg_vat.sql
 Change History :

1.  10-Aug-2005  Aiyer bug 4545146 version 120.1
                 Issue:-
                   Deadlock on tables due to multiple triggers on the same table (in different sql files)
                   firing in the same phase.
                 Fix:-
                   Multiple triggers on the same table have been merged into a single file to resolve
                   the problem
                   The following files have been stubbed:-
                     jai_ar_rcta_t1.sql
                     jai_ar_rcta_t2.sql
                     jai_ar_rcta_t3.sql
                     jai_ar_rcta_t4.sql
                     jai_ar_rcta_t6.sql
                     jai_ar_rcta_t7.sql
                     jai_ar_rcta_t8.sql
                     jai_ar_rcta_t9.sql
                   Instead the new file jai_ar_rcta_t.sql has been created which contains all the triggers

Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Current Version    Current Bug    Dependent           Files                Version          Author   Date          Remarks
Of File                           On Bug/Patchset    Dependent On

ja_in_loc_ar_hdr_upd_trg_vat.sql
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

  BEGIN
    pv_return_code := jai_constants.successful ;

  /*
  || Get the Organization and location info , vat_invoice_no, vat_invoice_date
  */
  OPEN  organization_cur;
  FETCH organization_cur INTO v_organization_id, v_loc_id,lv_vat_invoice_no,ld_vat_invoice_date ;
  CLOSE organization_cur;
  IF lv_vat_invoice_no   IS NOT NULL OR
     ld_vat_invoice_date IS NOT NULL
  THEN
    /*
    || IF vat_invoice_no or vat_invoice_date has already been populated into this record (indicating that it has already been run once)
    || then return.
    */
    return;
  END IF;

  /*
  || Get the Otransaction type of the document
  || Process only CM type of transaction's
  */
  OPEN  transaction_type_cur;
  FETCH transaction_type_cur INTO v_trans_type;
  CLOSE transaction_type_cur;

  IF NVL(v_trans_type,'N') <> 'CM'  THEN
  /*
  || In case of CM only VAT accouting should be done.
  */
     return;
  END IF;

  OPEN  cur_vat_taxes_exist;
  FETCH cur_vat_taxes_exist into  ln_regime_id,ln_regime_code;
  CLOSE cur_vat_taxes_exist;

  IF UPPER(nvl(ln_regime_code,'####')) <> UPPER(jai_constants.vat_regime)  THEN
    /*
    || only vat type of taxes should be processed
    */
    return;
  END IF;
 /*
    || Added by kunkumar for bug#5645003
    || Check if only 'VAT REVERSAL' tax type is present in ja_in_ra_cust_trx_tax_lines
    */
    IF ln_regime_id IS NULL THEN
       lv_vat_reversal := 'VAT REVERSAL' ;
       OPEN  c_chk_vat_reversal(lv_vat_reversal) ;
       FETCH c_chk_vat_reversal INTO ln_vat_reversal_exists;
       CLOSE c_chk_vat_reversal ;

       /*
       || Retrieve the regime_id for 'VAT REVERSAL' tax type, which is of regime code 'VAT'
       */
       IF ln_vat_reversal_exists = 1 THEN
         OPEN  c_get_regime_id ;
         FETCH c_get_regime_id INTO ln_regime_id ;
         CLOSE c_get_regime_id ;

        IF  ln_regime_id IS NOT NULL THEN
          ln_regime_code := jai_constants.vat_regime ;
        END IF ;
       END IF ;
    END IF ;
    --bug#5645003, ends




  /*
  || Get the vat invoice number for the Credit Memo from the Source Invoice only if a CM has a source INvoice
  || IF it is from legacy then the vat invoice number would go as null
  */
  IF pr_new.previous_customer_trx_id is NOT NULL THEN
    OPEN  cur_get_in_vat_no;
    FETCH cur_get_in_vat_no INTO lv_vat_invoice_no;
    CLOSE cur_get_in_vat_no ;
  END IF;

  /*
  || Get the gl_date from ra_cust_trx_lines_gl_dist_all
  */
  OPEN  cur_get_gl_date('REC');  /* Modified by Ramananda for removal of SQL LITERALs */
  FETCH cur_get_gl_date INTO ld_gl_date;
  CLOSE cur_get_gl_date;

  /*
  || IF the VAT invoice Number has been successfully generated, then pass accounting entries
  */
  jai_cmn_rgm_vat_accnt_pkg.process_order_invoice (
                                                          p_regime_id               => ln_regime_id                       ,
                                                          p_source                  => jai_constants.source_ar            ,
                                                          p_organization_id         => v_organization_id                  ,
                                                          p_location_id             => v_loc_id                           ,
                                                          p_delivery_id             => NULL                               ,
                                                          p_customer_trx_id         => pr_new.customer_trx_id               ,
                              p_transaction_type        => v_trans_type                       ,
                                                          p_vat_invoice_no          => lv_vat_invoice_no                  ,
                                                          p_default_invoice_date    => nvl(ld_gl_date,pr_new.trx_date)      ,
                                                          p_batch_id                => NULL                               ,
                                                          p_called_from             => 'JA_IN_LOC_AR_HDR_UPD_TRG_VAT'     , /* The string 'JA_IN_LOC_AR_HDR_UPD_TRG_VAT' is also being used in jai_cmn_rgm_vat_accnt_pkg.process_order_invoice*/
                                                          p_debug                   => jai_constants.no                   ,
                                                          p_process_flag            => lv_process_flag                    ,
                                                          p_process_message         => lv_process_message
                                                    );

  IF lv_process_flag = jai_constants.expected_error    OR
     lv_process_flag = jai_constants.unexpected_error
  THEN

/*     raise_application_error(-20130,lv_process_message); */ pv_return_code := jai_constants.expected_error ; pv_return_message := lv_process_message ; return ;
    /*
      app_exception.raise_exception( EXCEPTION_TYPE  => 'APP',
                                      EXCEPTION_CODE  => NULL ,
                                      EXCEPTION_TEXT  => lv_process_message
                                   );
    */

  END IF;

  UPDATE
        JAI_AR_TRXS
  SET
        vat_invoice_no   = lv_vat_invoice_no          ,
        vat_invoice_date = nvl(ld_gl_date,pr_new.trx_date)
  WHERE
        customer_trx_id  = pr_new.customer_trx_id ;

  /* Added an exception block by Ramananda for bug#4570303 */
   EXCEPTION
     WHEN OTHERS THEN
       Pv_return_code     :=  jai_constants.unexpected_error;
       Pv_return_message  := 'Encountered an error in JAI_AR_RCTA_TRIGGER_PKG.ARU_T3 '  || substr(sqlerrm,1,1900);

  END ARU_T3 ;

  /*
  REM +======================================================================+
  REM NAME          ARU_T4
  REM
  REM DESCRIPTION   Called from trigger JAI_AR_RCTA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_AR_RCTA_ARU_T6
  REM
  REM+=======================================================================+
  REM Change History
  REM slno  Date        Name     BugNo    File Version
  REM +=======================================================================+
  REM
  REM
  REM -----------------------------------------------------------------------
  REM 1.    04-Jul-2006 aiyer    5364288  120.3
  REM -----------------------------------------------------------------------
  REM Comments:-
  REM Removed references to ra_customer_trx_all and replaced it with jai_ar_trx.
  REM -----------------------------------------------------------------------
  REM 2.
  REM -----------------------------------------------------------------------
  REM -----------------------------------------------------------------------
  REM 3.
  REM -----------------------------------------------------------------------
  REM -----------------------------------------------------------------------
  REM 4.
  REM -----------------------------------------------------------------------
  REM
  REM
  REM+======================================================================+
*/
  PROCEDURE ARU_T4 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
  v_org_id      NUMBER;
  v_loc_id      NUMBER;
  v_reg_code      VARCHAR2(30);
  v_update_rg     VARCHAR2(1);
  v_reg_type      VARCHAR2(10);
  v_excise_paid_register  VARCHAR2(10);
  v_rg23a_type      VARCHAR2(10);
  v_rg23c_type      VARCHAR2(10);
  v_complete_flag   VARCHAR2(1); -- := 'N'; --Ramananda for File.Sql.35
  v_rg_flag     VARCHAR2(1); -- := 'N'; --Ramananda for File.Sql.35
  v_update_rg_flag    VARCHAR2(1); -- := 'N'; --Ramananda for File.Sql.35
--  v_update_rg23d_flag VARCHAR2(30); /*Bug 5040383*/
  v_tax_amount      NUMBER := 0;
  v_rg23a_tax_amount    NUMBER := 0;
  v_rg23c_tax_amount    NUMBER := 0;
  v_other_tax_amount    NUMBER := 0;
  v_basic_ed      NUMBER := 0;
  v_additional_ed   NUMBER := 0;
  v_other_ed      NUMBER := 0;
  v_item_class      VARCHAR2(10); -- := 'N'; --Ramananda for File.Sql.35
  v_excise_flag     VARCHAR2(1);
  v_fin_year      NUMBER;
  v_gp_1      NUMBER := 0;
  v_gp_2      NUMBER := 0;
  v_rg23a_bal     NUMBER := 0;
  v_rg23c_bal     NUMBER := 0;
  v_pla_bal     NUMBER := 0;
  v_invoice_no      VARCHAR2(200);
  v_other_invoice_no    NUMBER ;
  v_rg23a_invoice_no    NUMBER ;
  v_rg23c_invoice_no    NUMBER ;
  rg23a       NUMBER :=0;
  rg23c       NUMBER :=0;
  pla       NUMBER :=0;
  --v_row_id      ROWID;    -- := pr_new.ROWID; --Ramananda for File.Sql.35
  v_parent_trx_number   VARCHAR2(20);   -- := pr_new.recurred_from_trx_number; --Ramananda for File.Sql.35
  v_register_balance    NUMBER := 0;
  v_rg23d_register_balance  NUMBER := 0;
  v_customer_trx_id   NUMBER;   -- := pr_old.customer_trx_id; --Ramananda for File.Sql.35
  v_converted_rate    NUMBER := 1;
  v_ssi_unit_flag   VARCHAR2(1);
  v_trans_type      VARCHAR2(30);
  v_last_update_date    DATE;   -- := pr_new.last_update_date; --Ramananda for File.Sql.35
  v_last_updated_by   NUMBER;   -- := pr_new.last_updated_by; --Ramananda for File.Sql.35
  v_creation_date   DATE;   -- := pr_new.creation_date; --Ramananda for File.Sql.35
  v_created_by      NUMBER;   -- := pr_new.created_by; --Ramananda for File.Sql.35
  v_last_update_login   NUMBER;   -- := pr_new.last_update_login; --Ramananda for File.Sql.35
  v_bond_tax_amount   NUMBER := 0;
  V_rg23d_tax_amount    NUMBER := 0;
  v_modvat_tax_rate   NUMBER;
  v_exempt_bal      NUMBER;
  v_matched_qty     NUMBER;
  VSQLERRM      VARCHAR2(240);
  v_trans_type_up   VARCHAR2(3);
  v_order_invoice_type_up VARCHAR2(25);---ashish 10june
  v_register_code_up    VARCHAR2(25);---ashish 10june
  v_errbuf      VARCHAR2(250);
  -- added by sriram - bug # 3021588
  v_register_id         JAI_OM_OE_BOND_REG_HDRS.register_id%type;
  v_register_exp_date   JAI_OM_OE_BOND_REG_HDRS.bond_expiry_date%type;
  v_lou_flag            JAI_OM_OE_BOND_REG_HDRS.lou_flag%type;
  -- added by sriram - bug # 3021588
  v_trading_flag        JAI_CMN_INVENTORY_ORGS.TRADING%TYPE;/*Bug#4601570 bduvarag*/
  v_update_rg23d_flag   JAI_AR_TRXS.UPDATE_RG23D_FLAG%TYPE;/*Bug#4601570 bduvarag*/

 /*
 || Start of bug 4101549
 || Cursor modified by aiyer
 */
 CURSOR complete_cur
  IS
  SELECT
        organization_id     ,
    location_id       ,
    once_completed_flag   ,
    decode(once_completed_flag,'A','RG23A','C','RG23C','P','PLA') register_type,
    update_rg_flag, -- update_rg_flag added by sriram - bug# 3496577
    nvl(update_rg23d_flag,'N')  /*Bug 5040383*/
  FROM
    JAI_AR_TRXS
  WHERE
    customer_trx_id = v_customer_trx_id;


--2001/06/22 Anuradha Parthasarathy
  CURSOR REG_BALANCE_CUR(p_org_id IN NUMBER,p_loc_id IN NUMBER) IS
  SELECT NVL(rg23a_balance,0) rg23a_balance ,NVL(rg23c_balance,0) rg23c_balance,NVL(pla_balance,0) pla_balance
  FROM   JAI_CMN_RG_BALANCES
  WHERE  organization_id = p_org_id AND location_id = p_loc_id;

  CURSOR register_code_cur(p_org_id IN NUMBER,  p_loc_id IN NUMBER)  IS
  SELECT register_code
  FROM   JAI_OM_OE_BOND_REG_HDRS
  WHERE  organization_id = p_org_id AND location_id = p_loc_id   AND
     register_id IN (SELECT register_id
               FROM   JAI_OM_OE_BOND_REG_DTLS
         WHERE  order_type_id = pr_new.batch_source_id AND order_flag= 'N'); /* Modified by Ramananda for removal of SQL LITERALs */

  CURSOR fin_year_cur(p_org_id IN NUMBER) IS
  SELECT MAX(A.fin_year)
  FROM   JAI_CMN_FIN_YEARS A
  WHERE  organization_id = p_org_id AND fin_active_flag = 'Y';

  CURSOR tax_amount_cur IS
  SELECT NVL(tax_amount,0) tax_amount
  FROM   JAI_AR_TRXS
  WHERE  customer_trx_id = v_customer_trx_id;

  CURSOR preference_reg_cur(p_org_id IN  NUMBER, p_loc_id IN NUMBER) IS
  SELECT pref_rg23a , pref_rg23c , pref_pla
  FROM   JAI_CMN_INVENTORY_ORGS
  WHERE  organization_id = p_org_id AND
         location_id     = p_loc_id;

  CURSOR item_class_cur(P_ORG_ID IN NUMBER, P_Item_id IN NUMBER)  IS
  SELECT item_class, excise_flag
  FROM   JAI_INV_ITM_SETUPS
  WHERE  inventory_item_id = P_Item_Id AND
         ORGANIZATION_ID = P_ORG_ID;

  CURSOR organization_cur IS
  SELECT organization_id,location_id
  FROM   JAI_AR_TRXS
  WHERE  trx_number = v_parent_trx_number;

  CURSOR  register_balance_cur(p_org_id IN  NUMBER, p_loc_id IN NUMBER) IS
  SELECT  NVL(register_balance,0) register_balance
    FROM  JAI_OM_OE_BOND_TRXS
   WHERE  transaction_id = (SELECT MAX(A.transaction_id)
          FROM   JAI_OM_OE_BOND_TRXS A, JAI_OM_OE_BOND_REG_HDRS B
          WHERE  A.register_id = B.register_id
          AND    B.organization_id = p_org_id AND B.location_id = p_loc_id);

  CURSOR  register_balance_cur1(p_org_id IN  NUMBER, p_loc_id IN NUMBER) IS
  SELECT  NVL(rg23d_register_balance,0) rg23d_register_balance
    FROM  JAI_OM_OE_BOND_TRXS
   WHERE  transaction_id = (SELECT MAX(A.transaction_id)
          FROM   JAI_OM_OE_BOND_TRXS A, JAI_OM_OE_BOND_REG_HDRS B
          WHERE  A.register_id = B.register_id
          AND    B.organization_id = p_org_id AND B.location_id = p_loc_id);

  CURSOR line_cur IS
  SELECT customer_trx_line_id, inventory_item_id, quantity,line_number,
     excise_exempt_type, assessable_value
  FROM   JAI_AR_TRX_LINES
  WHERE  customer_trx_id = v_customer_trx_id
  ORDER BY customer_trx_line_id;

  CURSOR matched_qty_cur (p_customer_trx_line_id NUMBER) IS
  SELECT SUM(quantity_applied)
   FROM  JAI_CMN_MATCH_RECEIPTS
  WHERE  ref_line_id = p_customer_trx_line_id;

  CURSOR excise_cal_cur(p_line_id IN NUMBER, p_inventory_item_id IN NUMBER, p_org_id IN NUMBER) IS
  SELECT
         A.tax_id,
         A.tax_rate t_rate,
         A.tax_amount tax_amt,
         A.func_tax_amount func_amt,
         b.tax_type t_type,
         b.stform_type,
         A.tax_line_no
  FROM   JAI_AR_TRX_TAX_LINES A ,
         JAI_CMN_TAXES_ALL B,
         JAI_INV_ITM_SETUPS C
  WHERE  link_to_cust_trx_line_id = p_line_id
         AND  b.tax_type IN  --('Excise','Addl. Excise','Other Excise')  /* Modified by Ramananda for removal of SQL LITERALs */
     (jai_constants.tax_type_excise,jai_constants.tax_type_exc_additional,jai_constants.tax_type_exc_other)
         AND  A.tax_id = b.tax_id
   AND  c.inventory_item_id = p_inventory_item_id
   AND  c.organization_id = p_org_id
   --AND  c.item_class IN ('RMIN','RMEX','CGEX','CGIN','CCEX','CCIN','FGIN','FGEX') /* Modified by Ramananda for removal of SQL LITERALs */
   AND  c.item_class IN ( jai_constants.item_class_rmin, jai_constants.item_class_rmex,
        jai_constants.item_class_cgex, jai_constants.item_class_cgin,
        jai_constants.item_class_ccex, jai_constants.item_class_ccin,
        jai_constants.item_class_fgin, jai_constants.item_class_fgex
            )
  ORDER BY 1;

  CURSOR ssi_unit_flag_cur(p_org_id IN  NUMBER, p_loc_id IN NUMBER) IS
  SELECT ssi_unit_flag, nvl(trading,'N')/*Bug#4601570 bduvarag*/
  FROM   JAI_CMN_INVENTORY_ORGS
  WHERE  organization_id = p_org_id AND
   location_id     = p_loc_id;

  CURSOR transaction_type_cur IS
  SELECT TYPE
  FROM   RA_CUST_TRX_TYPES_ALL
  WHERE  cust_trx_type_id = pr_new.cust_trx_type_id
  AND    (org_id = pr_new.org_id
             OR
   (org_id is null and pr_new.org_id is null)) ; /* Modified by Ramananda for removal of SQL LITERALs */


/* Code Added For Generation of Excise Invoice Number */
  CURSOR Batch_Source_Name_Cur IS
  SELECT name
  FROM   Ra_Batch_Sources_All
  WHERE  batch_source_id = pr_new.batch_source_id
  AND    (org_id   = pr_new.org_id
           OR
   ( org_id is null AND pr_new.org_id is null)); /* Modified by Ramananda for removal of SQL LITERALs */

  --------------chnages in cursor definition

  CURSOR Def_Excise_Invoice_Cur(p_organization_id IN NUMBER, p_location_id IN NUMBER, p_fin_year IN NUMBER,
                                p_batch_name IN VARCHAR2, p_register_code IN VARCHAR2) IS
  SELECT start_number, end_number, jump_by, prefix
  FROM   JAI_CMN_RG_EXC_INV_NOS
  WHERE  organization_id               = p_organization_id
  AND    location_id                   = p_location_id
  AND    fin_year                      = p_fin_year
  AND    transaction_type     IN ( 'I','DOM','EXP')  --ashish 20jun02
  AND    order_invoice_type = p_batch_name
  AND    register_code      = p_register_code ;  /* Modified by Ramananda for removal of SQL LITERALs */

  CURSOR excise_invoice_cur(p_org_id IN NUMBER, p_loc_id IN NUMBER, p_fin_year IN NUMBER)  IS
  SELECT NVL(MAX(GP1),0),NVL(MAX(GP2),0)
  FROM   JAI_CMN_RG_EXC_INV_NOS
  WHERE  organization_id = p_org_id
  AND    location_id     = p_loc_id
  AND    fin_year    = p_fin_year
  AND    transaction_type IS NULL
  AND    order_invoice_type IS NULL
  AND    register_code IS NULL;

  CURSOR Register_Code_Meaning_Cur(p_register_code IN VARCHAR2,cp_register_type ja_lookups.lookup_type%type ) IS
  SELECT meaning
  FROM   ja_lookups
  WHERE  lookup_code = p_register_code
  AND    lookup_type = cp_register_type; /*'JAI_REGISTER_TYPE'; Ramananda for removal of SQL LITERALs */

--added by GD
   CURSOR for_modvat_percentage(v_org_id NUMBER, v_location_id NUMBER) IS
      SELECT MODVAT_REVERSE_PERCENT
      FROM   JAI_CMN_INVENTORY_ORGS
      WHERE  organization_id = v_org_id
      AND  (location_id = v_location_id
             OR
     (location_id is NULL and  v_location_id is NULL));  /* Modified by Ramananda for removal of SQL LITERALs */

CURSOR for_modvat_tax_rate(p_cust_trx_line_id NUMBER) IS
      SELECT A.tax_rate
      FROM   JAI_AR_TRX_TAX_LINES A, JAI_CMN_TAXES_ALL b
      WHERE  A.tax_id = b.tax_id
      AND    A.link_to_cust_trx_line_id = p_cust_trx_line_id
      AND    b.tax_type = jai_constants.tax_type_modvat_recovery ; --'Modvat Recovery';

--added by GD
  v_start_number           NUMBER;
  v_end_number             NUMBER;
  v_jump_by                NUMBER;
  v_order_invoice_type     VARCHAR2(50);
  v_prefix         VARCHAR2(50);
  v_meaning                VARCHAR2(80);
  v_set_of_books_id        NUMBER; -- := pr_new.set_of_books_id; --Ramananda for File.Sql.35
  /* Bug 5243532. Added by Lakshmi Gopalsami
     Removed the reference to set_of_books_cur
     which is selecting SOB from org_organization_definitions
     as the SOB will never by null in base table.
  */
 /* CODE ADDED TO INCORPORATE MASTER ORGANIZATION  */
  CURSOR ec_code_cur(p_organization_id IN NUMBER, p_location_id IN NUMBER) IS
  SELECT A.Organization_Id, A.Location_Id
  FROM   JAI_CMN_INVENTORY_ORGS A
  WHERE  A.Ec_Code IN (SELECT B.Ec_Code
                       FROM   JAI_CMN_INVENTORY_ORGS B
                       WHERE  B.Organization_Id = p_organization_id
                       AND    B.Location_Id     = p_location_id);

--3661746
  CURSOR c_total_Excise_amt IS
    SELECT   nvl(sum(jrtl.func_tax_amount),0)
    FROM     JAI_AR_TRXS         jtrx,
             JAI_AR_TRX_LINES   jtl,
           JAI_AR_TRX_TAX_LINES   jrtl,
           JAI_CMN_TAXES_ALL               jtc ,
           JAI_INV_ITM_SETUPS        jmtl
    WHERE    jrtl.tax_id = jtc.tax_id
    AND      jtrx.customer_trx_id = jtl.customer_Trx_id
    AND      jrtl.link_to_cust_trx_line_id = jtl.customer_trx_line_id
    AND      jtl.inventory_item_id = jmtl.inventory_item_id
    AND      jtrx.organization_id = jmtl.organization_id
    --AND    jmtl.item_class in ('RMIN','RMEX','CGEX','CGIN','FGIN','FGEX','CCIN','CCEX') /* Modified by Ramananda for removal of SQL LITERALs */
    AND      jmtl.item_class IN ( jai_constants.item_class_rmin, jai_constants.item_class_rmex,
        jai_constants.item_class_cgex, jai_constants.item_class_cgin,
        jai_constants.item_class_ccex, jai_constants.item_class_ccin,
        jai_constants.item_class_fgin, jai_constants.item_class_fgex
            )
    AND      jtc.tax_type like '%Excise%'
    AND      jtl.customer_trx_id   = pr_new.customer_trx_id
    AND      jtrx.customer_trx_id  = pr_new.customer_trx_id;

    v_total_excise_amt NUMBER :=0;

     CURSOR  c_cess_amount is
     SELECT   NVL(SUM(jrctl.func_tax_amount),0)  tax_amount
      FROM    JAI_AR_TRX_TAX_LINES jrctl ,
              JAI_CMN_TAXES_ALL             jtc
      WHERE   jtc.tax_id  =  jrctl.tax_id
      AND     link_to_cust_trx_line_id IN
      (SELECT customer_trx_line_id
       FROM   JAI_AR_TRX_LINES
       WHERE  customer_trx_id = pr_new.customer_trx_id
      )
      AND    upper(jtc.tax_type) IN (upper(jai_constants.tax_type_cvd_edu_cess), upper(jai_constants.tax_type_exc_edu_cess));

  -- Start of bug 4185033
  /*
  || Cursor added by aiyer for the bug 4185033
  || Check whether the JAI_AR_TRX_INS_LINES_T table still has the row corresponding to the current
  || customer_trx_id
  */
  CURSOR  cur_chk_temp_lines_exist( cp_customer_trx_id JAI_AR_TRXS.CUSTOMER_TRX_ID%TYPE ) /* changed the RA_CUSTOMER_TRX_ALL.CUSTOMER_TRX_ID%TYPE  to JAI_AR_TRXS.CUSTOMER_TRX_ID%TYPE for the bug 5364288 */
  IS
  SELECT
        1
  FROM
        JAI_AR_TRX_INS_LINES_T
  WHERE
      customer_trx_id =  cp_customer_trx_id ;

  -- End of bug 4185033

   CURSOR c_vat_invoice_cur
   IS
   SELECT
          vat_invoice_no
   FROM   JAI_AR_TRXS
   WHERE  customer_trx_id = pr_new.customer_trx_id;

   CURSOR cur_vat_taxes_exist
   IS
   SELECT
          regime_id   ,
          regime_code
   FROM
          JAI_AR_TRX_TAX_LINES jcttl,
          JAI_AR_TRX_LINES jctl,
          JAI_CMN_TAXES_ALL             jtc ,
          jai_regime_tax_types_v      jrttv
   WHERE
          jcttl.link_to_cust_trx_line_id  = jctl.customer_trx_line_id           AND
          jctl.customer_trx_id            = pr_new.customer_trx_id                AND
          jcttl.tax_id                    = jtc.tax_id                          AND
          jtc.tax_type                    = jrttv.tax_type                      AND
          regime_code                     = jai_constants.vat_regime            AND
          jtc.org_id                      = pr_new.org_id ;

 /*
    || Added by kunkumar for bug#5645003
    || Check if only 'VAT REVERSAL' tax type is present in ja_in_ra_cust_trx_tax_lines
    */
    CURSOR c_chk_vat_reversal (cp_tax_type jai_cmn_taxes_all.tax_type%TYPE )
     IS
     SELECT
              1
     FROM
            JAI_AR_TRX_TAX_LINES jcttl,
            JAI_AR_TRX_LINES jctl,
            JAI_CMN_TAXES_ALL            jtc
     WHERE
            jcttl.link_to_cust_trx_line_id  = jctl.customer_trx_line_id    AND
            jctl.customer_trx_id            = pr_new.customer_trx_id        AND
            jcttl.tax_id                    = jtc.tax_id                   AND
            jtc.org_id                      = pr_new.org_id                 AND
            jtc.tax_type                    = cp_tax_type ;

     /*
     || Retrieve the regime_id which is of regime code 'VAT'
     */
     CURSOR c_get_regime_id
     IS
     SELECT
            regime_id
     FROM
            jai_regime_tax_types_v
     WHERE
            regime_code = jai_constants.vat_regime
     AND    rownum       = 1 ;

    ln_vat_reversal_exists  NUMBER ;
    lv_vat_reversal         VARCHAR2(100);
     --bug#5645003, ends



   CURSOR cur_get_same_inv_no ( cp_organization_id JAI_AR_TRXS.ORGANIZATION_ID%TYPE ,
                                cp_location_id     JAI_AR_TRXS.LOCATION_ID%TYPE
                              )
   IS
   SELECT
            nvl(attribute_value ,'N') attribute_value
    FROM
            JAI_RGM_ORG_REGNS_V
    WHERE
            regime_code         = jai_constants.vat_regime   AND
            attribute_type_code = jai_constants.regn_type_others  AND /*'OTHERS' AND */
            attribute_code      = jai_constants.attr_code_same_inv_no AND  /*'SAME_INVOICE_NO' AND */
            organization_id     = cp_organization_id        AND
            location_id         = cp_location_id;

    CURSOR cur_get_exc_inv_no
    IS
    SELECT
           excise_invoice_no
    FROM
          JAI_AR_TRX_LINES
    WHERE
         customer_trx_id = pr_new.customer_trx_id ;


  CURSOR cur_get_gl_date(cp_account_class  ra_cust_trx_line_gl_dist_all.account_class%type)
  IS
  SELECT
     gl_date
  FROM
    ra_cust_trx_line_gl_dist_all
  WHERE
    customer_trx_id = pr_new.customer_trx_id   AND
    account_class   =  cp_account_class AND  /* 'REC' AND -- Ramananda for removal of SQL LITERALs */
    latest_rec_flag = 'Y';



    ln_exists                   NUMBER                   ;
    ln_cess_amount              JAI_CMN_RG_OTHERS.DEBIT%TYPE;
    lv_process_flag             VARCHAR2(2);
    lv_process_message          VARCHAR2(1996);
    lv_register_type            VARCHAR2(5);
    lv_rg23a_cess_avlbl         VARCHAR2(10);
    lv_rg23c_cess_avlbl         VARCHAR2(10);
    lv_pla_cess_avlbl           VARCHAR2(10);
    lv_vat_invoice_number       JAI_AR_TRXS.VAT_INVOICE_NO%TYPE;
    lv_vat_taxes_exist          VARCHAR2(1);
    lv_vat_no_same_exc_no       JAI_RGM_REGISTRATIONS.ATTRIBUTE_VALUE%TYPE; --     := 'N'; --Ramananda for File.Sql.35
    ld_gl_date                  RA_CUST_TRX_LINE_GL_DIST_ALL.GL_DATE%TYPE;
    ln_regime_id        JAI_RGM_DEFINITIONS.REGIME_ID%TYPE;
    ln_regime_code              JAI_RGM_DEFINITIONS.REGIME_CODE%TYPE;


--3661746

    lv_doc_type_class           varchar2(2); /* csahoo for seperate vat invoice num for unreg dealers - bug# 5233925*/

  /* CODE ADDED TILL TO INCORPORATE MASTER ORGANIZATION */
  BEGIN
    pv_return_code := jai_constants.successful ;
   /*------------------------------------------------------------------------------------------
 FILENAME: JA_IN_LOC_AR_HDR_UPDATE_TRG.sql
 CHANGE HISTORY:
S.No      Date          Author and Details
1.  10-Aug-2005  Aiyer bug 4545146 version 120.1
                 Issue:-
                   Deadlock on tables due to multiple triggers on the same table (in different sql files)
                   firing in the same phase.
                 Fix:-
                   Multiple triggers on the same table have been merged into a single file to resolve
                   the problem
                   The following files have been stubbed:-
                     jai_ar_rcta_t1.sql
                     jai_ar_rcta_t2.sql
                     jai_ar_rcta_t3.sql
                     jai_ar_rcta_t4.sql
                     jai_ar_rcta_t6.sql
                     jai_ar_rcta_t7.sql
                     jai_ar_rcta_t8.sql
                     jai_ar_rcta_t9.sql
                   Instead the new file jai_ar_rcta_t.sql has been created which contains all the triggers in the above files
2 09-Mar-2007 ssawant for the bug#5040383, File version 120.6
    Forward porting the changes done in bug#4998378
    bduvarag for the bug#5171573, File version 120.6
    Forward porting the changes done in bug#5057544
3 17/05/2007  bduvarag for the bug#4601570, File version 120.14
    Forward porting the changes done in bug#4474270
Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
Current Version       Current Bug    Dependent           Files                                  Version   Author   Date           Remarks
Of File                              On Bug/Patchset    Dependent On
ja_in_loc_ar_hdr_update_trg.sql
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------*/
-----Once Complete Button is Pressed Following code tell you what will happen at what stage

/* --Ramananda for File.Sql.35, start */
  v_complete_flag   := 'N';
  v_rg_flag     := 'N';
  v_update_rg_flag    := 'N';
  v_item_class      := 'N';
  v_parent_trx_number   := pr_new.recurred_from_trx_number;
  v_customer_trx_id   := pr_old.customer_trx_id;
  v_last_update_date    := pr_new.last_update_date;
  v_last_updated_by   := pr_new.last_updated_by;
  v_creation_date   := pr_new.creation_date;
  v_created_by      := pr_new.created_by;
  v_last_update_login   := pr_new.last_update_login;
  v_set_of_books_id             := pr_new.set_of_books_id;
  lv_vat_no_same_exc_no         := 'N';
  /* --Ramananda for File.Sql.35, end */

   -- Start of bug 4185033
  /*
  || This code has been added by aiyer for the bug 4185033
  || Stop the processing before if the user tries to complete the Manual AR invoice before the Ar TAx and Fregiht DEfaultation is complete.
  || This is essential as otherwise it would lead to data corruption. i.e ra_cust_trx_lines_gl_dist_all would be out of sync with
  || ar_payment_schedule_all
  */
  IF pr_new.created_from = 'ARXTWMAI' THEN
    OPEN  cur_chk_temp_lines_exist( cp_customer_trx_id => v_customer_trx_id );
    FETCH cur_chk_temp_lines_exist INTO ln_exists;
    IF CUR_CHK_TEMP_LINES_EXIST%FOUND THEN
      CLOSE cur_chk_temp_lines_exist;
/*       raise_application_error(-20121,'IL Tax not applied - Please wait for AR Tax and Freight Defaultation Concurrent Request to complete');
    */ pv_return_code := jai_constants.expected_error ; pv_return_message := 'IL Tax not applied - Please wait for AR Tax and Freight Defaultation Concurrent Request to complete' ; return ;
    END IF ;
    CLOSE cur_chk_temp_lines_exist;
  END IF;
  -- End of bug 4185033
  --Added the below  for Bug 5040383

  OPEN  transaction_type_cur;
  FETCH transaction_type_cur INTO v_trans_type;
  CLOSE transaction_type_cur;

  --Added the below  for Bug 5040383
  OPEN  Complete_Cur;
  FETCH Complete_Cur INTO  v_org_id, v_loc_id,v_complete_flag,v_reg_type, v_update_rg_flag,v_update_rg23d_flag;
  CLOSE Complete_Cur;

  IF pr_new.COMPLETE_FLAG <> pr_old.COMPLETE_FLAG THEN

  /*   --commented for bug 5040383
      OPEN  Complete_Cur;
      FETCH Complete_Cur INTO  v_org_id, v_loc_id,v_complete_flag,v_reg_type, v_update_rg_flag;
      CLOSE Complete_Cur;
   */

   v_rg_flag := v_update_rg_flag;

   IF NVL(v_complete_flag,'N') = 'Y' THEN
   RETURN;
      END IF;
      /*
      --commented for bug 5040383
      OPEN  transaction_type_cur;
      FETCH transaction_type_cur INTO v_trans_type;
      CLOSE transaction_type_cur;
      */

      IF NVL(v_trans_type,'N') <> 'INV' THEN
      /*Bug 5171573 bduvarag start*/
              UPDATE JAI_AR_TRXS
        SET    ONCE_COMPLETED_FLAG = pr_new.COMPLETE_FLAG
        WHERE  CUSTOMER_TRX_ID = V_CUSTOMER_TRX_ID;
  /*Bug 5171573 bduvarag End*/
      RETURN;
      END IF;
      IF pr_new.created_from = 'RAXTRX' THEN
      UPDATE JAI_AR_TRXS
      SET    ONCE_COMPLETED_FLAG = pr_new.COMPLETE_FLAG
      WHERE  CUSTOMER_TRX_ID = V_CUSTOMER_TRX_ID;
    ELSE

    IF NVL(v_org_id, 999999) = 999999 THEN -- ssumaith --- changed 0 to 999999 because trigger was returning in case where
                                             -- setup business group is done. Bug # 2846277
        IF v_parent_trx_number IS NULL THEN
          RETURN;
        ELSE
          OPEN  organization_cur;
          FETCH organization_cur INTO v_org_id, v_loc_id;
          CLOSE organization_cur;
          v_rg_flag := 'Y';
        END IF;
      END IF;
      IF NVL(v_org_id, 999999) = 999999 THEN -- ssumaith - -- changed 0 to 999999 because trigger was returning in case where
                                             -- setup business group is done. Bug # 2846277
        RETURN;
      END IF;
      -- above code segment commented by sriram - calling the procedure instead -- bug # 3021588
      jai_cmn_bond_register_pkg.GET_REGISTER_ID (v_org_id,
                                           v_loc_id,
                                           NVL(pr_new.batch_source_id,0),
                                           'N',
                                           v_register_id ,
                                           v_reg_code
                                    );
      -- ends here code added by sriram - Bug # 3021588

      OPEN  register_code_meaning_cur(v_reg_code, 'JAI_REGISTER_TYPE'); /* Modified by Ramananda for removal of SQL LITERALs */
      FETCH register_code_meaning_cur INTO v_meaning;
      CLOSE register_code_meaning_cur;
      OPEN   fin_year_cur(v_org_id);
      FETCH  fin_year_cur INTO v_fin_year;
      CLOSE  fin_year_cur;
      OPEN   Batch_Source_Name_Cur;
      FETCH  Batch_Source_Name_Cur INTO v_order_invoice_type;
      CLOSE  Batch_Source_Name_Cur;




      IF v_reg_code IN ('DOMESTIC_EXCISE','EXPORT_EXCISE','DOM_WITHOUT_EXCISE','BOND_REG') THEN
        v_rg_flag := 'Y';
        -- following comparision values made into upper case by sriram -bug # 3179379
      ELSIF upper(v_reg_code) IN ('23D_DOMESTIC_EXCISE','23D_EXPORT_EXCISE',
          '23D_DOM_WITHOUT_EXCISE','23D_EXPORT_WITHOUT_EXCISE')THEN
        v_rg_flag := 'N';
      END IF;

      v_update_rg_flag := 'Y';-- bug#3496577 -- setting the value to 'Y' because the update_rg_flag has to only impact
      -- amount registers and not quantity registers and excise invoice generation.

      OPEN   REG_BALANCE_CUR(v_org_id, v_loc_id);
      FETCH  REG_BALANCE_CUR INTO v_rg23a_bal,v_rg23c_bal,v_pla_bal;
      CLOSE  REG_BALANCE_CUR;
      OPEN  ssi_unit_flag_cur(v_org_id, v_loc_id);
      FETCH ssi_unit_flag_cur INTO v_ssi_unit_flag, v_trading_flag;/*Bug#4601570 bduvarag*/
      CLOSE ssi_unit_flag_cur;

    /*
    ||Start of bug 4101549
    || IF condition modified forthe bug 4101549
    ||The complete flag statuses should be 'A','P','C','N'
    */
      IF NVL(v_complete_flag,'N') IN ('N','A','C','P')  AND
      (v_rg_flag = 'Y' OR v_update_rg_flag = 'Y')     AND
    v_reg_code     IS NOT NULL
     THEN
    /*
    ||End of bug 4101549
    */
        FOR Line_Rec IN Line_Cur LOOP
          FOR excise_cal_rec IN excise_cal_cur(Line_Rec.customer_trx_line_id, Line_Rec.Inventory_Item_ID, v_org_id) LOOP
          IF excise_cal_rec.t_type IN ('Excise') THEN
              v_basic_ed := NVL(v_basic_ed,0) + NVL(excise_cal_rec.func_amt,0);
            ELSIF excise_cal_rec.t_type IN ('Addl. Excise') THEN
              v_additional_ed := NVL(v_additional_ed,0) + NVL(excise_cal_rec.func_amt,0);
            ELSIF excise_cal_rec.t_type IN ('Other Excise') THEN
            v_other_ed := NVL(v_other_ed,0) + NVL(excise_cal_rec.func_amt,0);
            END IF;
          END LOOP;
          v_tax_amount := NVL(v_basic_ed,0) + NVL(v_additional_ed,0) + NVL(v_other_ed,0);
          IF v_reg_code IN ('DOMESTIC_EXCISE','EXPORT_EXCISE') THEN
            OPEN   item_class_cur(V_ORG_ID,Line_Rec.Inventory_Item_Id);
            FETCH  item_class_cur INTO v_item_class, v_excise_flag;
            CLOSE  item_class_cur;


          IF NVL(v_excise_flag,'N') = 'Y' THEN
              IF NVL(v_ssi_unit_flag,'N') = 'N'
          AND NVL(line_rec.excise_exempt_type, '@@@') NOT IN ('CT2', 'EXCISE_EXEMPT_CERT','CT2_OTH', 'EXCISE_EXEMPT_CERT_OTH' )
            THEN
                IF v_item_class IN ('CGEX','CGIN') THEN
                v_rg23c_tax_amount := NVL(v_rg23c_tax_amount,0) + NVL(v_tax_amount,0);
                ELSIF v_item_class IN ('RMIN','RMEX') THEN
                v_rg23a_tax_amount := NVL(v_rg23a_tax_amount,0) + NVL(v_tax_amount,0);
          ELSIF v_item_class  IN ('FGIN','FGEX','CCIN','CCEX') THEN
            v_other_tax_amount := NVL(v_other_tax_amount,0) + NVL(v_tax_amount,0);
             -------------ADDED BY GD {
          ELSIF NVL(v_ssi_unit_flag,'N') = 'N' AND
          NVL(line_rec.excise_exempt_type, '@@@') IN ('CT2', 'EXCISE_EXEMPT_CERT',
          'CT2_OTH', 'EXCISE_EXEMPT_CERT_OTH' )  THEN
            IF v_item_class NOT IN ('OTIN', 'OTEX') THEN
            IF line_rec.excise_exempt_type IN ('CT2 - OTHERS', 'Excise Exempted OTHERS' ) THEN
                OPEN  for_modvat_tax_rate(line_rec.customer_trx_line_id);
              FETCH for_modvat_tax_rate INTO v_modvat_tax_rate;
            CLOSE for_modvat_tax_rate;
            ELSE
            OPEN for_modvat_percentage(v_org_id, v_loc_id);
            FETCH   for_modvat_percentage INTO v_modvat_tax_rate;
            CLOSE for_modvat_percentage;
            END IF;
                  v_exempt_bal := (NVL(v_exempt_bal, 0) + line_rec.quantity * line_rec.assessable_value * NVL(v_modvat_tax_rate,0))/100;
                    IF v_exempt_bal > v_rg23a_bal THEN
/*                        RAISE_APPLICATION_ERROR(-20120, 'Register RG23A PART II Balance -> '||
                   TO_CHAR(v_rg23a_bal ) || ' IS less than the Modvat Amount ->' ||
                 TO_CHAR(v_exempt_bal)); */ pv_return_code := jai_constants.expected_error ; pv_return_message :=  'Register RG23A PART II Balance -> '||
                   TO_CHAR(v_rg23a_bal ) || ' IS less than the Modvat Amount ->' ||
                 TO_CHAR(v_exempt_bal) ; return ;
                    END IF;
              END IF;
                  -----------ADDED BY GD }
                END IF;
              END IF; -- SSI UNIT FLAG
            END IF; -- EXCISE INVOICE FLAG
          ELSIF v_reg_code IN ('BOND_REG')
          THEN
                -- added by sriram - bug # 3021588
          jai_cmn_bond_register_pkg.GET_REGISTER_DETAILS(v_register_id,
                                         v_register_balance,
                                         v_register_exp_date,
                                         v_lou_flag
                                          );

            v_converted_rate := jai_cmn_utils_pkg.currency_conversion (pr_new.set_of_books_id ,pr_new.invoice_currency_code ,
                                          pr_new.exchange_date ,pr_new.exchange_rate_type, pr_new.exchange_rate);
            v_bond_tax_amount := NVL(v_tax_amount,0) + NVL(v_bond_tax_amount,0);


            IF (v_register_balance < v_bond_tax_amount )
            AND                                          -- added by sriram - bug # 3021588
            ( NVL(v_lou_flag,'N') = 'N')                 -- added by sriram - bug # 3021588
            THEN
/*               RAISE_APPLICATION_ERROR(-20120, 'Bonded Register Has Balance -> ' || TO_CHAR(v_register_balance)
           || ' ,which IS less than Excisable Amount -> ' || TO_CHAR(v_bond_tax_amount)); */ pv_return_code := jai_constants.expected_error ; pv_return_message := 'Bonded Register Has Balance -> ' || TO_CHAR(v_register_balance)
           || ' ,which IS less than Excisable Amount -> ' || TO_CHAR(v_bond_tax_amount) ; return ;
            END IF;

            IF (nvl(v_register_exp_date,sysdate) < Sysdate ) THEN
/*               RAISE_APPLICATION_ERROR(-20121, 'Validity Date of the Bond Register has expired');
 */ pv_return_code := jai_constants.expected_error ; pv_return_message :=  'Validity Date of the Bond Register has expired' ; return ;
            END IF ;
          ELSIF v_reg_code IN ('23D_DOMESTIC_EXCISE','23D_EXPORT_EXCISE','23D_DOM_WITHOUT_EXCISE','23D_EXPORT_WITHOUT_EXCISE')
          THEN  /*Bug#4601570 bduvarag start*/
                IF v_trading_flag      = 'Y' AND
               v_update_rg23d_flag = 'Y'
            THEN
/*Bug#4601570 bduvarag end*/
    if line_rec.inventory_item_id is not null then
            OPEN matched_qty_cur(line_rec.customer_trx_line_id);
            FETCH matched_qty_cur INTO v_matched_qty;
            CLOSE matched_qty_cur;
            IF NVL(v_matched_qty,0)<> NVL(line_rec.quantity,0)
            THEN
/*               RAISE_APPLICATION_ERROR(-20120, 'Matched Quantity -> ' || TO_CHAR(v_matched_qty)
        || ' , IS less than Invoiced Quantity -> ' || TO_CHAR(line_rec.quantity)
              || ' , FOR line NUMBER -> ' || TO_CHAR(line_rec.line_number)); */ pv_return_code := jai_constants.expected_error ; pv_return_message :=  'Matched Quantity -> ' || TO_CHAR(v_matched_qty)
        || ' , IS less than Invoiced Quantity -> ' || TO_CHAR(line_rec.quantity)
              || ' ,FOR line NUMBER -> ' || TO_CHAR(line_rec.line_number) ; return ;
              EXIT;
            END IF;
END IF;

            -- needs to start here

            --  needs to end here
            IF v_reg_code = '23D_EXPORT_WITHOUT_EXCISE'
            THEN
              v_rg23d_tax_amount := NVL(v_tax_amount,0) + NVL(v_rg23d_tax_amount,0);
              IF NVL(v_rg23d_register_balance,0) < NVL(v_rg23d_tax_amount,0)
              and (NVL(v_lou_flag,'N') = 'N')  -- added by sriram bug # 3021588
              THEN
/*                 RAISE_APPLICATION_ERROR(-20120, 'RG23D Bonded Register Has Balance -> ' || TO_CHAR(v_rg23d_register_balance)
            || ' ,which IS less than Excisable Amount -> ' || TO_CHAR(v_rg23d_tax_amount)); */ pv_return_code := jai_constants.expected_error ; pv_return_message := 'RG23D Bonded Register Has Balance -> ' || TO_CHAR(v_rg23d_register_balance)
            || ' ,which IS less than Excisable Amount -> ' || TO_CHAR(v_rg23d_tax_amount) ; return ;
              END IF;

              -- added by sriram - bug # 3021588
              IF (v_register_exp_date > Sysdate ) THEN
/*                RAISE_APPLICATION_ERROR(-20121, 'Validity Date of the Bond Register has expired');
*/ pv_return_code := jai_constants.expected_error ; pv_return_message :=  'Validity Date of the Bond Register has expired' ; return ;
              -- ends here additions by sriram - bug # 3021588
           END IF;
            END IF;
END IF;/*Bug#4601570 bduvarag*/
          END IF;
        END LOOP;
        v_basic_Ed := 0;
        v_additional_ed := 0;
        v_other_ed := 0;
        v_tax_amount := 0;
        v_other_tax_amount := 0;
        v_rg23a_tax_amount := 0;
        v_rg23c_tax_amount := 0;
        v_rg23d_tax_Amount := 0;

------------------------------start of update loop------------------------

        FOR Line_Rec IN Line_Cur LOOP
          -- Excise invoice generation logic commented by sriram and
          -- making call to the procedure instead.
          -- Bug # 2663211

        Open  item_class_cur(v_org_id,line_rec.Inventory_item_id);
        fetch item_class_cur into v_item_class , v_excise_flag;
        close item_class_cur;

          IF NVL(v_excise_flag,'N') = 'Y' THEN
            IF v_invoice_no is Null THEN
             jai_cmn_setup_pkg.generate_excise_invoice_no(v_org_id,v_loc_id,'I',pr_new.batch_source_id, v_fin_year, v_invoice_no , v_errbuf);
            END IF;

          IF v_errbuf is not null THEN
             -- to raise an error when the excise invoice returns a value.
/*              raise_application_error(-20107,'Error During Excise Invoice Generation ! ' || v_errbuf);
*/ pv_return_code := jai_constants.expected_error ; pv_return_message := 'Error During Excise Invoice Generation ! ' || v_errbuf ; return ;
         END IF;

          IF NVL(v_item_class,'~') not in ('OTIN') THEN

              UPDATE JAI_AR_TRX_LINES
              SET    EXCISE_INVOICE_NO    = v_invoice_no ,
                     EXCISE_INVOICE_DATE  = SYSDATE
              WHERE  CUSTOMER_TRX_LINE_ID = LINE_REC.customer_trx_line_id AND
                   INVENTORY_ITEM_ID    = LINE_REC.inventory_item_id AND
            CUSTOMER_TRX_ID      = v_customer_trx_id;
            END IF;
          END IF;
        END LOOP;
----------------end of excise no update loop--------------------

        --3661746
          open  c_total_Excise_amt;
          fetch c_total_Excise_amt into v_total_excise_amt;
          close c_total_Excise_amt;
        --3661746

        /* start additions by ssumaith to check for negative cess - bug#4171272*/

          open   c_cess_amount;
          fetch  c_cess_amount into ln_Cess_amount;
          close  c_cess_amount;

           lv_register_type := 'RG23A';
           jai_cmn_rg_others_pkg.check_balances(
                                            p_organization_id   =>  v_org_id          ,
                                            p_location_id       =>  v_loc_id          ,
                                            p_register_type     =>  lv_register_type  ,
                                            p_trx_amount        =>  ln_cess_amount    ,
                                            p_process_flag      =>  lv_process_flag   ,
                                            p_process_message   =>  lv_process_message
                                           );

           if  lv_process_flag <> jai_constants.successful then
              lv_rg23a_cess_avlbl := 'FALSE';
           else
              lv_rg23a_cess_avlbl := 'TRUE';
           end if;


           lv_register_type := 'RG23C';
           jai_cmn_rg_others_pkg.check_balances(
                                           p_organization_id   =>  v_org_id          ,
                                           p_location_id       =>  v_loc_id          ,
                                           p_register_type     =>  lv_register_type  ,
                                           p_trx_amount        =>  ln_cess_amount    ,
                                           p_process_flag      =>  lv_process_flag   ,
                                           p_process_message   =>  lv_process_message
                                          );

           if  lv_process_flag <> jai_constants.successful then
              lv_rg23c_cess_avlbl := 'FALSE';
           else
              lv_rg23c_cess_avlbl := 'TRUE';
           end if;


           lv_register_type := 'PLA';
           jai_cmn_rg_others_pkg.check_balances(
                                          p_organization_id   =>  v_org_id          ,
                                          p_location_id       =>  v_loc_id          ,
                                          p_register_type     =>  lv_register_type  ,
                                          p_trx_amount        =>  ln_cess_amount    ,
                                          p_process_flag      =>  lv_process_flag   ,
                                          p_process_message   =>  lv_process_message
                                         );

           if  lv_process_flag <> jai_constants.successful then
              lv_pla_cess_avlbl := 'FALSE';
           else
              lv_pla_cess_avlbl := 'TRUE';
           end if;


         /* ends here additions by ssumaith to check for negative cess - bug# 4171272 */



        FOR Line_Rec IN Line_Cur LOOP
          OPEN   item_class_cur(V_ORG_ID,Line_Rec.Inventory_Item_Id);
          FETCH  item_class_cur INTO v_item_class , v_excise_flag;
          CLOSE  item_class_cur;
          FOR excise_cal_rec IN excise_cal_cur(Line_Rec.customer_trx_line_id, Line_Rec.Inventory_Item_ID, v_org_id) LOOP
          IF excise_cal_rec.t_type IN ('Excise') THEN
              v_basic_ed := NVL(v_basic_ed,0) + NVL(excise_cal_rec.func_amt,0);
            ELSIF excise_cal_rec.t_type IN ('Addl. Excise') THEN
              v_additional_ed := NVL(v_additional_ed,0) + NVL(excise_cal_rec.func_amt,0);
            ELSIF excise_cal_rec.t_type IN ('Other Excise') THEN
              v_other_ed := NVL(v_other_ed,0) + NVL(excise_cal_rec.func_amt,0);
            END IF;
          END LOOP;
          v_tax_amount := NVL(v_basic_ed,0) + NVL(v_additional_ed,0) + NVL(v_other_ed,0);
          v_basic_Ed := 0;
          v_additional_ed := 0;
          v_other_ed := 0;
          IF v_item_class IN ('CGEX','CGIN') THEN
           v_rg23c_tax_amount := NVL(v_rg23c_tax_amount,0) + NVL(v_tax_amount,0);
          ELSIF v_item_class IN ('RMIN','RMEX') THEN
           v_rg23a_tax_amount := NVL(v_rg23a_tax_amount,0) + NVL(v_tax_amount,0);
          ELSIF v_item_class  IN ('FGIN','FGEX','CCIN','CCEX') THEN
             v_other_tax_amount := NVL(v_other_tax_amount,0) + NVL(v_tax_amount,0);
          END IF;

          v_tax_amount:=v_total_excise_amt;

          IF NVL(v_excise_flag,'N') = 'Y' THEN
            IF NVL(v_ssi_unit_flag,'N') = 'N' THEN
         /*
         || code changed by aiyer for the bug 4101549
         || v_complete_flag should have the values as ('N','A','C','P')
         */
               IF v_complete_flag IN ('N','A','C','P') THEN
                 IF v_rg_flag = 'Y' THEN
                   IF v_reg_code IN ('DOMESTIC_EXCISE','EXPORT_EXCISE') THEN
               --3661746
                     -- following code modified by ssumaith - bug# --3661746
                     -- in order to hit the register based on preferences.
                     /*
                       Added code in the following segment to check for cess balance also
                     */

                     IF v_item_class IN ('FGIN','FGEX','CCIN','CCEX','CGIN','CGEX','RMIN','RMEX') THEN
                       IF v_reg_type IS NULL THEN
                         OPEN   preference_reg_cur(v_org_id,v_loc_id);
                         FETCH  preference_reg_cur INTO rg23a,rg23c,pla;
                         CLOSE  preference_reg_cur;

                         FOR reg_balance IN reg_balance_cur(v_org_id,v_loc_id) LOOP
                           IF rg23a = 1 THEN
                              IF reg_balance.rg23a_balance >= v_tax_amount AND lv_rg23a_cess_avlbl = 'TRUE' THEN
                                    v_rg23a_tax_amount := v_tax_amount;
                                    v_reg_type := 'RG23A';
                              ELSE
                                IF rg23c = 2 THEN
                                  IF reg_balance.rg23c_balance >= v_tax_amount AND lv_rg23c_cess_avlbl = 'TRUE' THEN
                                        v_rg23c_tax_amount := v_tax_amount;
                                        v_reg_type  := 'RG23C';
                                  ELSIF  reg_balance.pla_balance >= v_tax_amount AND lv_pla_cess_avlbl = 'TRUE' THEN
                                        v_reg_type  := 'PLA';
                                  END IF;
                                ELSIF pla = 2 THEN
                                  IF reg_balance.pla_balance >= v_tax_amount AND lv_pla_cess_avlbl = 'TRUE' THEN
                                        v_reg_type := 'PLA';
                                  ELSIF  reg_balance.rg23c_balance >= v_tax_amount AND lv_rg23c_cess_avlbl = 'TRUE' THEN
                                        v_rg23c_tax_amount := v_tax_amount;
                                        v_reg_type  := 'RG23C';
                                  END IF;
                                END IF;
                              END IF;
                           ELSIF rg23c = 1 THEN
                             IF reg_balance.rg23c_balance >= v_tax_amount AND lv_rg23c_cess_avlbl = 'TRUE' THEN
                                   v_rg23c_tax_amount := v_tax_amount;
                                   v_reg_type := 'RG23C';
                             ELSE
                                IF rg23a = 2 THEN
                                  IF reg_balance.rg23a_balance >= v_tax_amount AND lv_rg23a_cess_avlbl = 'TRUE' THEN
                                        v_rg23a_tax_amount := v_tax_amount;
                                        v_reg_type  := 'RG23A';
                                  ELSIF  reg_balance.pla_balance >= v_tax_amount AND lv_pla_cess_avlbl = 'TRUE' THEN
                                        v_reg_type  := 'PLA';
                                  END IF;
                                ELSIF pla = 2 THEN
                                  IF reg_balance.pla_balance >= v_tax_amount AND lv_pla_cess_avlbl = 'TRUE' THEN
                                         v_reg_type  := 'PLA';
                                  ELSIF  reg_balance.rg23a_balance >= v_tax_amount AND lv_rg23a_cess_avlbl = 'TRUE' THEN
                                         v_rg23a_tax_amount := v_tax_amount;
                                         v_reg_type  := 'RG23A';
                                  END IF;
                                END IF;
                           END IF;
                           ELSIF pla = 1 THEN
                             IF reg_balance.pla_balance >= v_tax_amount AND lv_pla_cess_avlbl = 'TRUE'  THEN
                                   v_reg_type  := 'PLA';
                             ELSE
                               IF rg23c = 2 THEN
                                 IF reg_balance.rg23c_balance >= v_tax_amount AND lv_rg23c_cess_avlbl = 'TRUE'  THEN
                                       v_rg23c_tax_amount := v_tax_amount;
                                       v_reg_type  := 'RG23C';
                               ELSIF  reg_balance.rg23a_balance >= v_tax_amount AND lv_rg23a_cess_avlbl = 'TRUE' THEN
                                       v_rg23a_tax_amount := v_tax_amount;
                                       v_reg_type := 'RG23A';
                               END IF;
                               ELSIF rg23a = 2 THEN
                                 IF reg_balance.rg23a_balance >= v_tax_amount AND lv_rg23a_cess_avlbl = 'TRUE' THEN
                                       v_rg23a_tax_amount := v_tax_amount;
                                       v_reg_type  := 'RG23A';
                                 ELSIF  reg_balance.rg23c_balance >= v_tax_amount AND lv_rg23c_cess_avlbl = 'TRUE' THEN
                                       v_rg23c_tax_amount := v_tax_amount;
                                       v_reg_type := 'RG23C';
                                 END IF;
                               END IF;
                           END IF;
                           END IF; -- pref 1 if condition's end if

                           IF v_reg_type is null THEN
/*                              raise_application_error(-20102,'None of the registers have enough balance for the excise duty -> ' || v_tax_amount  || ' Or Cess amount => ' || ln_Cess_amount);
                           */ pv_return_code := jai_constants.expected_error ; pv_return_message := 'None of the registers have enough balance for the excise duty -> ' || v_tax_amount  || ' Or Cess amount => ' || ln_Cess_amount ; return ;
                           END IF;
                           IF v_reg_type = 'PLA' and NVL(v_ssi_unit_flag,'N') <> 'Y' THEN
                             IF v_tax_amount > reg_balance.pla_balance AND lv_pla_cess_avlbl = 'TRUE' THEN
/*                                   raise_application_error(-20102,'PLA Balance -> ' || reg_balance.pla_balance ||
                                                              ' is not enough for the excise duty -> ' || v_tax_amount ); */ pv_return_code := jai_constants.expected_error ; pv_return_message := 'PLA Balance -> ' || reg_balance.pla_balance ||
                                                              ' is not enough for the excise duty -> ' || v_tax_amount  ; return ;
                             END IF;
                           ELSIF v_reg_type = 'RG23A' THEN
                             IF v_tax_amount > reg_balance.rg23a_balance AND lv_rg23a_cess_avlbl = 'TRUE'  THEN
/*                                    raise_application_error(-20102,'RG23A Balance -> ' || reg_balance.rg23a_balance ||
                                             ' is not enough for the excise duty -> ' || v_tax_amount ); */ pv_return_code := jai_constants.expected_error ; pv_return_message := 'RG23A Balance -> ' || reg_balance.rg23a_balance ||
                                             ' is not enough for the excise duty -> ' || v_tax_amount  ; return ;
                             END IF;
                           ELSIF v_reg_type = 'RG23C' THEN
                             IF v_tax_amount > reg_balance.rg23c_balance AND lv_rg23c_cess_avlbl = 'TRUE' THEN
/*                                     raise_application_error(-20102,'RG23C Balance -> ' ||  reg_balance.rg23c_balance ||
                                                 ' is not enough for the excise duty -> ' || v_tax_amount ); */ pv_return_code := jai_constants.expected_error ; pv_return_message := 'RG23C Balance -> ' ||  reg_balance.rg23c_balance ||
                                                 ' is not enough for the excise duty -> ' || v_tax_amount  ; return ;
                             END IF;
                           END IF;
                         END LOOP;
                       END IF;  -- for v_reg_type is null
                       v_excise_paid_register := v_reg_type;
                     END IF; -- for v_item_class in ('FGIN','FGEX'.... )
                   END IF; -- for v_reg_code in ('DOMESTIC_EXCISE')....

                 /*
                   the following piece of code added by sriram bug # 2521387
                 */
                 Declare
                   v_reg_type VARCHAR2(10);
                 Begin
                     SELECT  once_completed_flag
                     INTO    v_reg_type
                     FROM    JAI_AR_TRXS
                     WHERE   CUSTOMER_TRX_ID = pr_new.Customer_trx_id;

                   IF v_reg_type = 'P' THEN
                     v_reg_type := 'PLA';
                   ELSIF v_reg_type = 'A' THEN
                     v_reg_type := 'RG23A';
                   ELSIF v_reg_type = 'C' THEN
                     v_reg_type := 'RG23C';
                   END IF;

                   IF v_reg_type is not null and  v_reg_type <> 'N' THEN
                     v_excise_paid_register := v_reg_type;
                   END IF;

                 Exception
                   When Others Then
/*                      RAISE_APPLICATION_ERROR(-10101,SQLERRM);
                 */ pv_return_code := jai_constants.expected_error ; pv_return_message := SQLERRM ; return ;
                 End ;

                 /*
                  Ends here
                 */

                   UPDATE JAI_AR_TRX_LINES
                   SET    PAYMENT_REGISTER = v_excise_paid_register
                   WHERE  CUSTOMER_TRX_LINE_ID = LINE_REC.customer_trx_line_id AND
                          INVENTORY_ITEM_ID    = LINE_REC.inventory_item_id AND
                          CUSTOMER_TRX_ID      = v_customer_trx_id;
               END IF;  -- for v_rg_flag = 'Y'
                   v_excise_paid_register := '';
               END IF; -- for v_complete_flag = 'N'
                   -- END IF; --3661746
             ELSIF NVL(v_ssi_unit_flag,'N') = 'Y' THEN
               IF v_item_class IN ('RMIN','RMEX','CGEX','CGIN','FGIN','FGEX','CCIN','CCEX')  THEN
                 /*
                 || code changed by aiyer for the bug 4101549
                 || v_complete_flag should have the values as ('N','A','C','P')
                 */
                 IF v_complete_flag IN ('N','A','C','P') THEN
                   IF v_rg_flag = 'Y' THEN
                     IF v_reg_code IN ('DOMESTIC_EXCISE','EXPORT_EXCISE') THEN
                       IF v_reg_type IS NULL THEN
                         OPEN   preference_reg_cur(v_org_id,v_loc_id);
                         FETCH  preference_reg_cur INTO rg23a,rg23c,pla;
                         CLOSE  preference_reg_cur;
                         --======
                         FOR reg_balance IN reg_balance_cur(v_org_id,v_loc_id) LOOP --3661746
                           IF rg23a = 1 THEN
                              IF reg_balance.rg23a_balance >= v_tax_amount AND lv_rg23a_cess_avlbl = 'TRUE' THEN
                                    v_rg23a_tax_amount := v_tax_amount;
                                    v_reg_type := 'RG23A';
                              ELSE
                                 IF rg23c = 2 THEN
                                    IF reg_balance.rg23c_balance >= v_tax_amount AND lv_rg23c_cess_avlbl = 'TRUE' THEN
                                          v_rg23c_tax_amount := v_tax_amount;
                                          v_reg_type  := 'RG23C';
                                    ELSE
                                       v_reg_type  := 'PLA';
                                    END IF;
                                 ELSIF pla = 2 THEN
                                    v_reg_type := 'PLA';
                                 END IF;
                              END IF;
                           ELSIF rg23c = 1 THEN
                             IF reg_balance.rg23c_balance >= v_tax_amount AND lv_rg23c_cess_avlbl = 'TRUE' THEN
                                   v_rg23c_tax_amount := v_tax_amount;
                                   v_reg_type := 'RG23C';
                             ELSE
                               IF rg23a = 2 THEN
                                  IF reg_balance.rg23a_balance >= v_tax_amount AND lv_rg23a_cess_avlbl = 'TRUE' THEN
                                         v_rg23a_tax_amount := v_tax_amount;
                                         v_reg_type  := 'RG23A';
                                  ELSE
                                    v_reg_type  := 'PLA';
                                  END IF;
                               ELSIF pla = 2 THEN
                                  v_reg_type  := 'PLA';
                               END IF;
                             END IF;
                           ELSIF pla = 1 THEN
                             v_reg_type  := 'PLA';
                           END IF;
                           --3661746
                           IF v_reg_type = 'RG23A' THEN
                              IF v_tax_amount > reg_balance.rg23a_balance AND lv_rg23a_cess_avlbl = 'TRUE' THEN
/*                                     raise_application_error(-20102,'RG23A Balance -> ' || reg_balance.rg23a_balance ||
                                    ' is not enough for the excise duty -> ' || v_tax_amount ); */ pv_return_code := jai_constants.expected_error ; pv_return_message := 'RG23A Balance -> ' || reg_balance.rg23a_balance ||
                                    ' is not enough for the excise duty -> ' || v_tax_amount  ; return ;
                              END IF;
                           ELSIF v_reg_type = 'RG23C' THEN
                              IF v_tax_amount > reg_balance.rg23c_balance AND lv_rg23c_cess_avlbl = 'TRUE' THEN
/*                                     raise_application_error(-20102,'RG23C Balance -> ' ||  reg_balance.rg23c_balance ||
                                    ' is not enough for the excise duty -> ' || v_tax_amount ); */ pv_return_code := jai_constants.expected_error ; pv_return_message := 'RG23C Balance -> ' ||  reg_balance.rg23c_balance ||
                                    ' is not enough for the excise duty -> ' || v_tax_amount  ; return ;
                              END IF;
                           END IF;
                           --3661746
                         END LOOP; --3661746
                       END IF; -- for v_reg_type is null

                       v_excise_paid_register := v_reg_type;
                       -- END IF; -- for v_item_clas in ('FGIN','FGEX'...)
                   END IF; -- for if v_reg_code in ('DOMESTIC_EXCISE'....)

                   /*
                 the following piece of code added by sriram bug # 2521387
                   */

                   Declare
                   v_reg_type1 VARCHAR2(10);
                 Begin
                   SELECT  once_completed_flag
                   INTO    v_reg_type1
                   FROM    JAI_AR_TRXS
                   WHERE   CUSTOMER_TRX_ID = pr_new.Customer_trx_id;

                   If v_reg_type1 = 'P' THEN
                     v_reg_type1 := 'PLA';
                   ELSIF  v_reg_type1 = 'A' THEN
                     v_reg_type1 := 'RG23A';
                   ELSIF  v_reg_type1 = 'C' THEN
                     v_reg_type1 := 'RG23C';
                   END IF;

                   if v_reg_type1 is not null and v_reg_type1 <> 'N'  then
                         v_excise_paid_register := v_reg_type1;
                   end if;

                   Exception
                     When Others Then
/*                        RAISE_APPLICATION_ERROR(-10101,SQLERRM);
                     */ pv_return_code := jai_constants.expected_error ; pv_return_message := SQLERRM ; return ;
                     END;
                     /*
                     Ends here - Additions by Sriram
                     */
                       UPDATE JAI_AR_TRX_LINES
                       SET    PAYMENT_REGISTER     = v_excise_paid_register
                       WHERE  CUSTOMER_TRX_LINE_ID = LINE_REC.customer_trx_line_id AND
                              INVENTORY_ITEM_ID    = LINE_REC.inventory_item_id AND
                              CUSTOMER_TRX_ID      = v_customer_trx_id;
                 END IF; -- for v_rg_flag = 'Y;
                     v_excise_paid_register := '';
                 END IF; -- for v_complete_flag = 'N'
               END IF; -- for v_item_class in ('...)
            END IF; -- for v_ssi_unit_flag ....
        END IF; -- v_excise_flag = 'Y'


        END LOOP;
        INSERT INTO JAI_AR_TRX_INS_HDRS_T
         (
          ORGANIZATION_ID,
          LOCATION_ID,
          CUSTOMER_TRX_ID ,
          SHIP_TO_CUSTOMER_ID,
          SHIP_TO_SITE_USE_ID,
          CUST_TRX_TYPE_ID,
          TRX_DATE,
          SOLD_TO_CUSTOMER_ID,
          BATCH_SOURCE_ID,
          BILL_TO_CUSTOMER_ID , -- BILL_TO_CUSTOMER_ID column in insert  added by sriram - 13/may-02
          BILL_TO_SITE_USE_ID ,
          CREATED_BY ,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE
         ) -- BILL_TO_SITE_USE_ID column in insert  added by sriram - 13/may-02
         VALUES
         (
          V_ORG_ID,
          V_LOC_ID,
          V_CUSTOMER_TRX_ID ,
          pr_new.SHIP_TO_CUSTOMER_ID,
          pr_new.SHIP_TO_SITE_USE_ID,
          pr_new.CUST_TRX_TYPE_ID,
          pr_new.TRX_DATE,
          pr_new.SOLD_TO_CUSTOMER_ID,
          pr_new.BATCH_SOURCE_ID,
          pr_new.BILL_TO_CUSTOMER_ID ,-- ADDED BY SRIRAM - 13-MAY-2002
          pr_new.BILL_TO_SITE_USE_ID,
          FND_GLOBAL.USER_ID ,  -- added standard who columns by brahtod for bug# 4558072
          SYSDATE ,
          FND_GLOBAL.USER_ID ,
          SYSDATE);
          END IF;
        UPDATE JAI_AR_TRXS
        SET
        ONCE_COMPLETED_FLAG = pr_new.COMPLETE_FLAG
        WHERE CUSTOMER_TRX_ID = V_CUSTOMER_TRX_ID;
      END IF;
   END IF;

  /*
  ||Start of code changes for bug 4247989
  ||Modification for VAT enhancement, code added by aiyer
  */
   IF NVL(v_trans_type,'N') NOT IN ('INV','DM') THEN
     RETURN;
   END IF;

  IF nvl(pr_new.created_from,'###') = 'ARXTWMAI'  THEN
    OPEN  c_vat_invoice_cur;
    FETCH c_vat_invoice_cur  INTO  lv_vat_invoice_number;
    CLOSE c_vat_invoice_cur;

    IF lv_vat_invoice_number IS NOT NULL THEN
      return;
    END IF;

    /*
    || check if VAT regime setup has been done
    || if yes then continue with the VAT processing
    */
    OPEN  cur_vat_taxes_exist;
    FETCH cur_vat_taxes_exist into ln_regime_id,ln_regime_code;


 /*
      || Added by kunkumar for bug#5645003
      || Check if only 'VAT REVERSAL' tax type is present in ja_in_ra_cust_trx_tax_lines
      */
      IF ln_regime_id IS NULL THEN
         lv_vat_reversal := 'VAT REVERSAL' ;
         OPEN  c_chk_vat_reversal(lv_vat_reversal) ;
         FETCH c_chk_vat_reversal INTO ln_vat_reversal_exists;
         CLOSE c_chk_vat_reversal ;

         /*
         || Retrieve the regime_id for 'VAT REVERSAL' tax type, which is of regime code 'VAT'
         */
         IF ln_vat_reversal_exists = 1 THEN
           OPEN  c_get_regime_id ;
           FETCH c_get_regime_id INTO ln_regime_id ;
           CLOSE c_get_regime_id ;

          IF  ln_regime_id IS NOT NULL THEN
            ln_regime_code := jai_constants.vat_regime ;
          END IF ;
         END IF ;
      END IF ;
      --bug#5645003, ends

 IF UPPER(nvl(ln_regime_code,'####')) = jai_constants.vat_regime  THEN
      /*
      || Check the VAT Regime setup for vat invoice no being same as excise invoice no.
      || If the attribute value is 'N' or this attribute code does not exist the generate the vat invoice number
      */
      OPEN  cur_get_same_inv_no ( cp_organization_id => v_org_id ,
                                  cp_location_id     => v_loc_id
                                ) ;
      FETCH cur_get_same_inv_no INTO lv_vat_no_same_exc_no;
      CLOSE cur_get_same_inv_no ;

      IF nvl(lv_vat_no_same_exc_no,'N') =  'Y' THEN
        /*
        || vat invoice number should be same as excise invoice number
        */
        OPEN  cur_get_exc_inv_no ;
        FETCH cur_get_exc_inv_no INTO lv_vat_invoice_number;
        CLOSE cur_get_exc_inv_no;
      END IF;


      IF lv_vat_invoice_number IS NULL THEN
        /*
        || Either the setup for excise invoice number has not been doe or the attribute_value was set to 'N'
        || In either of this cases generate VAT Invoice number
        */

         /*
        || added csahoo - for seperate vat invoice num for unreg dealers  - bug# 5233925
        */
        IF  check_reg_dealer( NVL(pr_new.SHIP_TO_CUSTOMER_ID ,pr_new.BILL_TO_CUSTOMER_ID) ,
                              NVL(pr_new.SHIP_TO_SITE_USE_ID, pr_new.BILL_TO_SITE_USE_ID)
                            ) THEN
           lv_doc_type_class := 'I';
        ELSE
           lv_doc_type_class := 'UI';
        END IF;

        /*
          || csahoo - for seperate vat invoice num for unreg dealers  - bug# 5233925
          */

        jai_cmn_rgm_setup_pkg.gen_invoice_number(
                                               p_regime_id        => ln_regime_id                   ,
                                               p_organization_id  => v_org_id                       ,
                                               p_location_id      => v_loc_id                       ,
                                               p_date             => pr_new.trx_date                  ,
                                               p_doc_class        => lv_doc_type_class              , --added for bug#7475924
                                               p_doc_type_id      => pr_new.batch_source_id           ,
                                               p_invoice_number   => lv_vat_invoice_number          ,
                                               p_process_flag     => lv_process_flag                ,
                                               p_process_msg      => lv_process_message
                                              );

        IF lv_process_flag = jai_constants.expected_error    OR
           lv_process_flag = jai_constants.unexpected_error
        THEN
          CLOSE cur_vat_taxes_exist;
/*           raise_application_error(-20130,lv_process_message); */ pv_return_code := jai_constants.expected_error ; pv_return_message := lv_process_message ; return ;
          /*
          app_exception.raise_exception( EXCEPTION_TYPE  => 'APP',
                                        EXCEPTION_CODE  => NULL ,
                                        EXCEPTION_TEXT  => lv_process_message
                                      );
          */
        END IF;
      END IF; -- END IF of lv_excise_inv_no IS NULL

      /*
      || Get the gl_date from ra_cust_trx_lines_gl_dist_all
      */
      OPEN  cur_get_gl_date('REC');
      FETCH cur_get_gl_date INTO ld_gl_date;
      CLOSE cur_get_gl_date;

      /*
      || IF the VAT invoice Number has been successfully generated, then pass accounting entries
      */
      jai_cmn_rgm_vat_accnt_pkg.process_order_invoice (
                                                             p_regime_id               => ln_regime_id                              ,
                                                             p_source                  => jai_constants.source_ar                   ,
                                                             p_organization_id         => v_org_id                                  ,
                                                             p_location_id             => v_loc_id                                  ,
                                                             p_delivery_id             => NULL                                      ,
                                                             p_customer_trx_id         => pr_new.customer_trx_id                      ,
                                                             p_transaction_type        => v_trans_type                              ,
                                                             p_vat_invoice_no          => lv_vat_invoice_number                     ,
                                                             p_default_invoice_date    => nvl(ld_gl_date,pr_new.trx_date)             ,
                                                             p_batch_id                => NULL                                      ,
                                                             p_called_from             => jai_constants.vat_repo_call_inv_comp      ,
                                                             p_debug                   => jai_constants.no                          ,
                                                             p_process_flag            => lv_process_flag                           ,
                                                             p_process_message         => lv_process_message
                                                       );

      IF lv_process_flag = jai_constants.expected_error    OR
         lv_process_flag = jai_constants.unexpected_error
      THEN
        CLOSE cur_vat_taxes_exist ;
/*         raise_application_error(-20130,lv_process_message); */ pv_return_code := jai_constants.expected_error ; pv_return_message := lv_process_message ; return ;
        /*
         app_exception.raise_exception( EXCEPTION_TYPE  => 'APP',
                                       EXCEPTION_CODE  => NULL ,
                                       EXCEPTION_TEXT  => lv_process_message
                                    );
        */

      END IF;

      UPDATE
              JAI_AR_TRXS
      SET
              vat_invoice_no   = lv_vat_invoice_number          ,
              vat_invoice_date = nvl(ld_gl_date,pr_new.trx_date)
      WHERE
              customer_trx_id = pr_new.customer_trx_id ;

      END IF; -- END IF of vat type of taxes found

      CLOSE cur_vat_taxes_exist;

  END IF  ; --EBD IF of nvl(new.created_from,'###') ='ARXTWMAI'

  /*
  ||End of code changes for bug 4247989
  */
  /* Added an exception block by Ramananda for bug#4570303 */
   EXCEPTION
     WHEN OTHERS THEN
       Pv_return_code     :=  jai_constants.unexpected_error;
       Pv_return_message  := 'Encountered an error in JAI_AR_RCTA_TRIGGER_PKG.ARU_T4 '  || substr(sqlerrm,1,1900);

  END ARU_T4 ;

  /*
  REM +======================================================================+
  REM NAME          ARU_T5
  REM
  REM DESCRIPTION   Called from trigger JAI_AR_RCTA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_AR_RCTA_ARU_T6
  REM
  REM+=======================================================================+
  REM Change History
  REM slno  Date        Name     BugNo    File Version
  REM +=======================================================================+
  REM
  REM
  REM -----------------------------------------------------------------------
  REM 1.    04-Jul-2006 aiyer    5364288  120.3
  REM -----------------------------------------------------------------------
  REM Comments:-
  REM Removed references to ra_customer_trx_all and replaced it with jai_ar_trx.
  REM also removed the cursor org_cur which was trying to fetch the org_id from ra_customer_trx_all.
  REM This was not required as pr_new.org_id is already being passed to the procedure and has the
  REM value of org_id.
  REM -----------------------------------------------------------------------
  REM 2.
  REM -----------------------------------------------------------------------
  REM -----------------------------------------------------------------------
  REM 3.
  REM -----------------------------------------------------------------------
  REM -----------------------------------------------------------------------
  REM 4.
  REM -----------------------------------------------------------------------
  REM
  REM
  REM+======================================================================+
*/
  PROCEDURE ARU_T5 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
    v_line_no       NUMBER := 0;
  v_books_id      NUMBER := 1;
  v_salesrep_id     NUMBER;
  v_line_type     VARCHAR2(30);
  v_vat_tax       NUMBER;
  v_ccid        NUMBER;
  v_cust_trx_line_id      RA_CUSTOMER_TRX_LINES_ALL.customer_trx_line_id%TYPE;
  v_customer_trx_line_id  NUMBER ;
  v_customer_trx_id   NUMBER;           -- := pr_new.customer_trx_id; --Ramananda for File.Sql.35
  v_created_from      VARCHAR2(30);
  c_from_currency_code    VARCHAR2(15);
  c_conversion_type   VARCHAR2(30);
  c_conversion_date   DATE;
  c_conversion_rate   NUMBER := 0;
  v_converted_rate    NUMBER := 1;
  req_id        NUMBER;
  result        BOOLEAN;
  v_organization_id   NUMBER ;
  v_location_id     NUMBER ;
  v_batch_source_id   NUMBER ;
  v_register_code     VARCHAR2(50);
  v_order_number      VARCHAR2(30);
  v_org_id              NUMBER(15);
  -- Bug 5207772. Added by Lakshmi Gopalsami
  v_order_type        VARCHAR2(30);

  lv_line_type_tax     RA_CUSTOMER_TRX_LINES_ALL.LINE_TYPE%type ;
  lv_line_type_freight RA_CUSTOMER_TRX_LINES_ALL.LINE_TYPE%type ;
  lv_acct_class_tax    RA_CUST_TRX_LINE_GL_DIST_ALL.ACCOUNT_CLASS%type ;
  lv_acct_class_freight  RA_CUST_TRX_LINE_GL_DIST_ALL.ACCOUNT_CLASS%type ;

  -- CURSOR ADDED BY SRIRAM - BUG # 2654567

  CURSOR C_GET_TRX_DETAILS
  IS
  SELECT * FROM JAI_AR_TRX_LINES
  WHERE CUSTOMER_TRX_ID = pr_new.CUSTOMER_TRX_ID;


  CURSOR C_GET_TRX_COUNT
  IS
  SELECT COUNT(*)
  FROM   RA_CUSTOMER_TRX_LINES_ALL
  WHERE  CUSTOMER_TRX_ID = pr_new.CUSTOMER_TRX_ID
  AND    LINE_TYPE in (lv_line_type_tax, lv_line_type_freight);  /* Modified by Ramananda for removal of SQL LITERALs */
   --('TAX','FREIGHT');

  CURSOR C_GET_GL_DIST_ALL_COUNT IS
  SELECT COUNT(*)
  FROM   RA_CUST_TRX_LINE_GL_DIST_ALL
  WHERE  CUSTOMER_TRX_ID = pr_new.CUSTOMER_TRX_ID
  AND    ACCOUNT_CLASS IN (lv_acct_class_tax , lv_acct_class_freight );       /* Modified by Ramananda for removal of SQL LITERALs */
  --AND    ACCOUNT_CLASS IN ('TAX','FREIGHT');

  CURSOR TAX_TYPE_CUR(p_customer_trx_line_id Number) IS
  SELECT A.tax_id taxid, A.tax_rate, A.uom uom,A.tax_amount tax_amt,b.tax_type t_type,A.customer_trx_line_id  line_id , a.tax_line_no
  FROM   JAI_AR_TRX_TAX_LINES A , JAI_CMN_TAXES_ALL B
  WHERE  link_to_cust_trx_line_id = p_customer_trx_line_id
    AND  A.tax_id = B.tax_id
   ORDER BY 1;

  lv_tax_regime_code             zx_rates_b.tax_regime_code%type ;
  ln_party_tax_profile_id        zx_party_tax_profile.party_tax_profile_id%type ;
  ln_tax_rate_id                 zx_rates_b.tax_rate_id%type ;
  /* Added by Ramananda for bug#4468353 , end     */

  CURSOR TAX_CCID_CUR(p_tax_id IN NUMBER) IS
  SELECT tax_account_id
  FROM   JAI_CMN_TAXES_ALL B
  WHERE  B.tax_id = p_tax_id ;


  CURSOR SO_AR_HDR_INFO IS
  SELECT organization_id, location_id, batch_source_id
  FROM   JAI_AR_TRXS
  WHERE  Customer_Trx_ID = v_customer_trx_id;

  /*Bug 8625057 - Start*/
  CURSOR cur_chk_rgm ( cp_tax_type JAI_CMN_TAXES_ALL.TAX_TYPE%TYPE )
  IS
  SELECT regime_id, regime_code
  FROM   jai_regime_tax_types_v      jrttv
  WHERE  upper(jrttv.tax_type)   = upper(cp_tax_type);

  ln_regime_code              VARCHAR2(30);
  ln_regime_id                NUMBER;
  /*Bug 8625057 - End*/


  CURSOR register_code_cur(p_org_id IN NUMBER,  p_loc_id IN NUMBER,
                                      p_batch_source_id  IN NUMBER)  IS
  SELECT register_code
  FROM   JAI_OM_OE_BOND_REG_HDRS
  WHERE  organization_id = p_org_id AND location_id = p_loc_id   AND
     register_id IN (SELECT register_id
               FROM   JAI_OM_OE_BOND_REG_DTLS
           WHERE  order_type_id = p_batch_source_id AND order_flag = 'N');

  /* Bug5207772. Added by Lakshmi Gopalsami
     Fixed performance issue - SQL id - 17698796
     Removed the reference to so_headers_all and added oe_transaction_types_tl
     Changed the parameter to p_order_type instead of p_order_number
  */
  CURSOR register_code_cur1(p_organization_id NUMBER,
                            p_location_id NUMBER,
          p_order_type  VARCHAR2) IS
  SELECT A.register_code
    FROM JAI_OM_OE_BOND_REG_HDRS A,
         JAI_OM_OE_BOND_REG_DTLS b,
   oe_transaction_types_tl ott
   WHERE A.organization_id = p_organization_id
     AND A.location_id = p_location_id
     AND A.register_id = b.register_id
     AND b.order_flag  = 'Y'
     AND b.order_type_id = ott.transaction_type_id
     AND ott.NAME = p_order_type;



/*
    || Added by kunkumar for bug#5645003
    || Check if only 'VAT REVERSAL' tax type is present in ja_in_ra_cust_trx_tax_lines
    */
    CURSOR c_chk_vat_reversal (cp_tax_type jai_cmn_taxes_all.tax_type%TYPE )
     IS
     SELECT
              1
     FROM
           JAI_AR_TRX_TAX_LINES jcttl,
            JAI_AR_TRX_LINES jctl,
           JAI_CMN_TAXES_ALL            jtc
     WHERE
            jcttl.link_to_cust_trx_line_id  = jctl.customer_trx_line_id    AND
            jctl.customer_trx_id            = pr_new.customer_trx_id        AND
            jcttl.tax_id                    = jtc.tax_id                   AND
            jtc.org_id                      = pr_new.org_id                 AND
            jtc.tax_type                    = cp_tax_type ;

    /*
   || Retrieve the regime_id which is of regime code 'VAT'
   */
      CURSOR c_get_regime_id
      IS
      SELECT
           regime_id
      FROM
           jai_regime_tax_types_v
      WHERE
           regime_code = jai_constants.vat_regime
      AND  rownum       = 1 ;



   v_err_mesg VARCHAR2(250);

  /*
  || start of bug 5364288 - code modified by aiyer
  ||changed the variable definition from RA_CUSTOMER_TRX_ALL.CUSTOMER_TRX_ID%TYPE  to JAI_AR_TRXS.CUSTOMER_TRX_ID%TYPE
  */
  v_trx_num  JAI_AR_TRXS.TRX_NUMBER%TYPE;

 /* End of bug 5364288 */

  v_TRX_TAX_COUNT Number;
  v_trx_gl_dist_COUNT Number;
  BEGIN
    pv_return_code := jai_constants.successful ;
    /*------------------------------------------------------------------------------------------
 FILENAME: JA_IN_APPS_AR_LINES_INSERT_TRG.sql
 CHANGE HISTORY:
1.  10-Aug-2005  Aiyer bug 4545146 version 120.1
                 Issue:-
                   Deadlock on tables due to multiple triggers on the same table (in different sql files)
                   firing in the same phase.
                 Fix:-
                   Multiple triggers on the same table have been merged into a single file to resolve
                   the problem
                   The following files have been stubbed:-
                     jai_ar_rcta_t1.sql
                     jai_ar_rcta_t2.sql
                     jai_ar_rcta_t3.sql
                     jai_ar_rcta_t4.sql
                     jai_ar_rcta_t6.sql
                     jai_ar_rcta_t7.sql
                     jai_ar_rcta_t8.sql
                     jai_ar_rcta_t9.sql
                   Instead the new file jai_ar_rcta_t.sql has been created which contains all the triggers in the above files

Dependency:
----------

Sl No. Bug        Dependent on
                  Bug/Patch set    Details
-------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------*/

 v_customer_trx_id   := pr_new.customer_trx_id; --Ramananda for File.Sql.35

/* Added by Ramananda for removal of SQL LITERALs */
 lv_line_type_tax     := 'TAX';
 lv_line_type_freight := 'FREIGHT' ;
 OPEN   C_GET_TRX_COUNT ;
 FETCH  C_GET_TRX_COUNT INTO v_TRX_TAX_COUNT;
 CLOSE  C_GET_TRX_COUNT;

/* Added by Ramananda for removal of SQL LITERALs */
 lv_acct_class_tax     := 'TAX';
 lv_acct_class_freight := 'FREIGHT' ;
 OPEN   C_GET_GL_DIST_ALL_COUNT ;
 FETCH  C_GET_GL_DIST_ALL_COUNT INTO   v_trx_gl_dist_COUNT;
 CLOSE  C_GET_GL_DIST_ALL_COUNT;



 IF v_TRX_TAX_COUNT <> v_trx_gl_dist_COUNT THEN
/*      RAISE_APPLICATION_ERROR(-20102,'Taxes are not consistent in the RA_CUSTOMER_TRX_LINES_ALL AND RA_CUST_TRX_LINE_GL_DIST_ALL Tables');
*/ pv_return_code := jai_constants.expected_error ; pv_return_message := 'Taxes are not consistent in the RA_CUSTOMER_TRX_LINES_ALL AND RA_CUST_TRX_LINE_GL_DIST_ALL Tables' ; return ;
END IF ;

 FOR v_trx_rec in C_GET_TRX_DETAILS

 LOOP
  v_customer_trx_line_id := v_trx_rec.customer_trx_line_id;
  v_trx_num              := pr_new.trx_number;
  v_created_from         := pr_new.created_from;
  v_order_number         := pr_new.interface_header_attribute1;
  -- Bug 5207772. Added by Lakshmi Gopalsami
  v_order_type          := pr_new.interface_header_attribute2;




  IF v_created_from IN ('ARXREC','ARXTWMAI') THEN
     RETURN;
  END IF;


  v_books_id            := pr_new.set_of_books_id;
  v_salesrep_id         := pr_new.primary_salesrep_id ;
  v_org_id              := pr_new.org_id ;
  c_from_currency_code  := pr_new.invoice_currency_code ;
  c_conversion_type   := pr_new.exchange_rate_type;
  c_conversion_date   := pr_new.exchange_date ;
  c_conversion_rate   := pr_new.exchange_rate;

     /*
      || Assigned the value of pr_new.org_id to v_org and instead removed the cursor  org_cur which was picking org_id from ra_customer_trx_all
      || and causing mutation issue
      */
       v_org_id := pr_new.org_id;
       OPEN  jai_ar_trx_pkg.c_tax_regime_code_cur(V_ORG_ID);
       FETCH jai_ar_trx_pkg.c_tax_regime_code_cur INTO lv_tax_regime_code;
       CLOSE jai_ar_trx_pkg.c_tax_regime_code_cur ;

       OPEN  jai_ar_trx_pkg.c_max_tax_rate_id_cur(lv_tax_regime_code);
       FETCH jai_ar_trx_pkg.c_max_tax_rate_id_cur INTO ln_tax_rate_id;
       CLOSE jai_ar_trx_pkg.c_max_tax_rate_id_cur ;


  v_converted_rate := jai_cmn_utils_pkg.currency_conversion (v_books_id ,c_from_currency_code ,
                        c_conversion_date ,c_conversion_type, c_conversion_rate);



  OPEN  SO_AR_HDR_INFO ;
  FETCH SO_AR_HDR_INFO INTO v_organization_id, v_location_id, v_batch_source_id;
  CLOSE SO_AR_HDR_INFO ;



  IF v_created_from = 'RAXTRX' THEN
    -- Bug 5207772. Added by Lakshmi Gopalsami
    OPEN  register_code_cur1(v_organization_id, v_location_id, v_order_type);
    FETCH register_code_cur1 INTO v_register_code;
    CLOSE register_code_cur1;
  END IF;
  BEGIN
    pv_return_code := jai_constants.successful ;
   FOR TAX_TYPE_REC IN TAX_TYPE_CUR(v_trx_rec.customer_trx_line_id)
   LOOP


         IF NVL(v_register_code,'N') IN ('23D_EXPORT_WITHOUT_EXCISE','23D_EXPORT_EXCISE',
                                 '23D_DOMESTIC_EXCISE','23D_DOM_WITHOUT_EXCISE','BOND_REG')
           THEN


               IF Tax_Type_Rec.T_Type IN ('Excise','Addl. Excise','Other Excise') THEN
                  TAX_TYPE_REC.tax_amt := 0;
               END IF;
     END IF;
     IF TAX_TYPE_REC.t_type = 'Freight' THEN
        v_line_type := 'FREIGHT';
     ELSE
        v_line_type := 'TAX';
     END IF;

     /*
     Bug 8625057 - Fetched the Interim Liability Code combination ID from Regime Setup
     	           Code Combination ID is fetched from the Tax Codes only if there is no setup at Regime Level
 	 */

     ln_regime_id := 0;
     ln_regime_code := NULL;

     OPEN  cur_chk_rgm  (cp_tax_type => TAX_TYPE_REC.t_type);
     FETCH cur_chk_rgm  INTO ln_regime_id, ln_regime_code ;
     CLOSE cur_chk_rgm  ;

     IF   UPPER(nvl(ln_regime_code,'####')) = jai_constants.service_regime  THEN

       v_ccid := jai_cmn_rgm_recording_pkg.get_account  (
                                                          p_regime_id             => ln_regime_id                              ,
                                                          p_organization_type     => jai_constants.service_tax_orgn_type       ,
                                                          p_organization_id       => v_organization_id                         ,
                                                          p_location_id           => v_location_id                             ,
                                                          p_tax_type              => TAX_TYPE_REC.t_type                       ,
                                                          p_account_name          => jai_constants.liability_interim
                                                        );
       IF v_ccid IS NULL THEN
          raise_application_error (-20150,'Regime Registration Incomplete. Please check the Service Tax - Tax Accounting Setup');
       END IF;


     ELSIF UPPER(nvl(ln_regime_code,'####')) = jai_constants.vat_regime THEN

       v_ccid := jai_cmn_rgm_recording_pkg.get_account  (
                                                           p_regime_id             => ln_regime_id                              ,
                                                           p_organization_type     => jai_constants.orgn_type_io                ,
                                                           p_organization_id       => v_organization_id                         ,
                                                           p_location_id           => v_location_id                             ,
                                                           p_tax_type              => TAX_TYPE_REC.t_type                       ,
                                                           p_account_name          => jai_constants.liability_interim
                                                        );
       IF v_ccid IS NULL THEN
          raise_application_error (-20150,'Regime Registration Incomplete. Please check the VAT Tax - Tax Accounting Setup');
       END IF;


     ELSIF  UPPER(nvl(ln_regime_code,'####')) = jai_constants.tcs_regime THEN

       v_ccid := jai_cmn_rgm_recording_pkg.get_account  (
                                                           p_regime_id             => ln_regime_id                              ,
                                                           p_organization_type     => jai_constants.orgn_type_io                ,
                                                           p_organization_id       => v_organization_id                         ,
                                                           p_location_id           => v_location_id                             ,
                                                           p_tax_type              => TAX_TYPE_REC.t_type                       ,
                                                           p_account_name          => jai_constants.liability_interim
                                                        );
       IF v_ccid IS NULL THEN
          raise_application_error (-20150,'Regime Registration Incomplete. Please check the TCS Tax - Tax Accounting Setup');
       END IF;

     ELSE
       OPEN  tax_ccid_cur(TAX_TYPE_REC.t_type);
       FETCH tax_ccid_cur INTO v_ccid;
       CLOSE tax_ccid_cur;
     END IF;

     /*Bug 8625057 - End*/

     IF TAX_TYPE_REC.t_type  = 'TDS' THEN
        TAX_TYPE_REC.tax_amt := 0;
     END IF;


     INSERT INTO JAI_AR_TRX_INS_LINES_T ( paddr,
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
                                           tax_rate,
                                           error_flag ,
                                           source ,
                                           org_id   ,  -- bug# 3479348
                                           line_number) -- added by sriram   bug# 3479348
                                  VALUES ( NULL,   /* Previously passing v_paddr. Replaced with NULL by rallamse bug#4448789 */
                                           TAX_TYPE_REC.tax_amt,
                                           TAX_TYPE_REC.LINE_ID,
                                           v_customer_trx_id,
                                           v_books_id,
                                           v_customer_trx_line_id,
                                           v_line_type,
                                           TAX_TYPE_REC.uom,
                                           ln_tax_rate_id, --v_vat_tax,   /* Modified by Ramananda for bug#4468353 due to ebtax uptake by AR */
                                           v_converted_rate * TAX_TYPE_REC.tax_amt,
                                           TAX_TYPE_REC.tax_amt,
                                           v_ccid,
                                           v_salesrep_id,
                                           'U',
                                         Sysdate,
                                           UID,
                                         Sysdate,
                                           UID,
                                           UID,
                                         TAX_TYPE_REC.tax_rate,
                                           'P',
                                           v_created_from,
                                           pr_new.org_id, -- added by sriram  bug# 3479348
                                           TAX_TYPE_REC.tax_line_no); -- added by sriram   bug# 3479348


   END LOOP;

   EXCEPTION
   WHEN OTHERS THEN
        v_err_mesg := SUBSTR(SQLERRM,1,240);

/*         RAISE_APPLICATION_ERROR(-20004,'error in processing the invoice ..' || v_trx_num || v_err_mesg);
 */ pv_return_code := jai_constants.expected_error ; pv_return_message := 'error in processing the invoice ..' || v_trx_num || v_err_mesg ; return ;
   END ;

END LOOP;
EXCEPTION
  WHEN OTHERS THEN
      v_err_mesg := SUBSTR(SQLERRM,1,240);

      --RAISE_APPLICATION_ERROR(-20003,'exception occured during processing invoice ..' || v_trx_num || v_err_mesg);

       /* Added an exception block by Ramananda for bug#4570303 */
       Pv_return_code     :=  jai_constants.unexpected_error;
       Pv_return_message  := 'Encountered an error in JAI_AR_RCTA_TRIGGER_PKG.ARU_T4. '  ||
                             'Exception occured during processing invoice ..' || v_trx_num || v_err_mesg ;

  END ARU_T5 ;

  /*
  REM +======================================================================+
  REM NAME          ARU_T6
  REM
  REM DESCRIPTION   Called from trigger JAI_AR_RCTA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_AR_RCTA_ARU_T9
  REM
  REM +======================================================================+
  */
  PROCEDURE ARU_T6 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS

/* --Ramananda for File.Sql.35, start */
  v_customer_id                 Number;   -- := pr_new.Ship_To_Customer_ID;
  v_org_id                      Number;   -- := NVL(pr_new.Org_ID,0);
  v_header_id                   Number;   -- := pr_new.customer_trx_id;
  v_ship_to_site_use_id         Number;   -- := NVL(pr_new.Ship_To_Site_Use_ID,0);
  v_created_from                Varchar2(30); -- := pr_new.Created_From;
  --v_row_id                      rowid;    -- := pr_new.rowid;
  v_last_update_date            Date;   --   := pr_new.last_update_date;
  v_last_updated_by             Number;   -- := pr_new.last_updated_by;
  v_creation_date               Date;   --   := pr_new.creation_date;
  v_created_by                  Number;   -- := pr_new.created_by;
  v_last_update_login           Number;   -- := pr_new.last_update_login;
  c_from_currency_code          Varchar2(15); -- := pr_new.invoice_currency_code;
  c_conversion_type             Varchar2(30); -- := pr_new.exchange_rate_type;
  c_conversion_date             Date;   --   := NVL(pr_new.exchange_date, pr_new.trx_date);
  c_conversion_rate             Number;   -- := NVL(pr_new.exchange_rate, 0);
  v_books_id                    Number;   -- := pr_new.set_of_books_id;
/* --Ramananda for File.Sql.35, end */

  v_inventory_item_id           Number ;
  v_address_id                  Number ;
  v_once_completed_flag         Varchar2(1);
  v_organization_id             Number ;
  v_tax_category_id             Number ;
  v_price_list                  Number := 0;
  v_price_list_uom_code         Varchar2(10);
  v_conversion_rate             Number ;
  v_price_list_val              Number := 0;
  v_converted_rate              Number ;
  v_line_tax_amount             Number := 0;
  v_trx_date                    Date;   --   := pr_new.trx_date; --Ramananda for File.Sql.35
  v_service_type    VARCHAR2(30); --added by ssawant


  Cursor address_cur(p_ship_to_site_use_id IN Number) IS
  SELECT cust_acct_site_id address_id
    FROM hz_cust_site_uses_all A  /*Removed ra_site_uses_all for Bug# 4434287*/
    WHERE A.site_use_id = p_ship_to_site_use_id;  /* Modified by Ramananda for removal of SQL LITERALs */
   --WHERE A.site_use_id = NVL(p_ship_to_site_use_id,0);


  CURSOR price_list_cur(p_customer_id IN Number,p_inventory_item_id IN Number,
          p_address_id IN Number DEFAULT 0, v_uom_code VARCHAR2, p_trx_date DATE) IS
  select list_price, unit_code
  from   so_price_list_lines
  where  price_list_id in (select price_list_id from JAI_CMN_CUS_ADDRESSES
         where  customer_id = p_customer_id and
          address_id  = p_address_id) and
   inventory_item_id = p_inventory_item_id
   and unit_code = v_uom_code
   AND   NVL(end_date_active,SYSDATE) >= p_trx_date;

  CURSOR ORG_CUR IS
  SELECT organization_id
  FROM JAI_AR_TRX_APPS_RELS_T ;/*altered by rchandan for bug#4479131*/

  CURSOR organization_cur IS
  SELECT organization_id
  FROM   JAI_AR_TRXS
  WHERE  trx_number = pr_new.recurred_from_trx_number;

  CURSOR ONCE_COMPLETE_FLAG_CUR IS
  SELECT once_completed_flag
  FROM   JAI_AR_TRXS
  WHERE  customer_trx_id = v_header_id;

  v_trans_type    Varchar2(30);

  Cursor transaction_type_cur IS
  Select a.type
  From   RA_CUST_TRX_TYPES_ALL a
  Where  a.cust_trx_type_id = pr_new.cust_trx_type_id
  And    a.org_id = v_org_id;  /* Modified by Ramananda for removal of SQL LITERALs */
--  And    NVL(a.org_id,0) = v_org_id;

  Cursor Ar_Line_Cur IS
  Select Customer_Trx_Line_ID, Inventory_Item_ID, Unit_Code, Line_Amount, Quantity,unit_selling_price
  From   JAI_AR_TRX_LINES
  Where  Customer_Trx_ID = v_header_id;

  /* Bug 5243532. Added by Lakshmi Gopalsami
     Removed the reference to set_of_books_cur
     which is selecting SOB from org_organization_definitions
     as the SOB will never by null in base table.
  */
  ln_vat_assessable_value  JAI_AR_TRX_LINES.VAT_ASSESSABLE_VALUE%TYPE;

-- Added by sacsethi for bug 5631784 on 30-01-2007
-- START 5631784
    LN_TCS_EXISTS                   NUMBER;
    LN_TCS_REGIME_ID                JAI_RGM_DEFINITIONS.REGIME_ID%TYPE;
    LN_THRESHOLD_SLAB_ID            JAI_AP_TDS_THHOLD_SLABS.THRESHOLD_SLAB_ID%TYPE;
    LN_THRESHOLD_TAX_CAT_ID         JAI_AP_TDS_THHOLD_TAXES.TAX_CATEGORY_ID%TYPE;

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

   CURSOR GC_GET_REGIME_ID (CP_REGIME_CODE    JAI_RGM_DEFINITIONS.REGIME_CODE%TYPE)
      IS
        SELECT REGIME_ID
        FROM   JAI_RGM_DEFINITIONS
        WHERE  REGIME_CODE = CP_REGIME_CODE;

  LV_PROCESS_FLAG       VARCHAR2 (2);
  LV_PROCESS_MESSAGE    VARCHAR2 (1998);

--END 5631784

  BEGIN
    pv_return_code := jai_constants.successful ;
   /*------------------------------------------------------------------------------------------
 FILENAME: JA_IN_AR_HDR_UPDATE_TRG.sql

 CHANGE HISTORY:
S.No      Date          Author and Details
1.  10-Aug-2005  Aiyer bug 4545146 version 120.1
                 Issue:-
                   Deadlock on tables due to multiple triggers on the same table (in different sql files)
                   firing in the same phase.
                 Fix:-
                   Multiple triggers on the same table have been merged into a single file to resolve
                   the problem
                   The following files have been stubbed:-
                     jai_ar_rcta_t1.sql
                     jai_ar_rcta_t2.sql
                     jai_ar_rcta_t3.sql
                     jai_ar_rcta_t4.sql
                     jai_ar_rcta_t6.sql
                     jai_ar_rcta_t7.sql
                     jai_ar_rcta_t8.sql
                     jai_ar_rcta_t9.sql
                   Instead the new file jai_ar_rcta_t.sql has been created which contains all the triggers in the above files

2.   31-AUG-2006    SACSETHI FOR BUG 5631784 , 5228046 FILE VERSION 120.4
        FORWARD PORTING BUG FROM 11I BUG 4742259
        NEW ENH: TAX COLLECTION AT SOURCE IN RECEIVABLES
     Changes -

    Object Type     Object Name                           Change                 Description
    ---------------------------------------------------------------------------------------------

    VARIABLE        LN_TCS_EXISTS                          Add         Variable Added
    VARIABLE  LN_TCS_REGIME_ID           Add         Variable Added
    VARIABLE  LN_THRESHOLD_SLAB_ID           Add         Variable Added
    VARIABLE  LN_THRESHOLD_TAX_CAT_ID          Add         Variable Added
    CURSOR          GC_CHK_RGM_TAX_EXISTS          ADD                   CURSOR FOR GETTING COUNT(1) FROM TAXES
    CURSOR    GC_GET_REGIME_ID           ADD                   CURSOR FOR GETTING REGIME ID FOR TCS
    VARIABLE        LV_PROCESS_FLAG                        ADD                   VARIABLE LV_PROCESS_FLAG IS PROCESS FLAG
    VARIABLE  LV_PROCESS_MESSAGE                     ADD                   VARIABLE LV_PROCESS_MESSAGE IS PROCESS MESSAGE RETURN BY CALLING OBJECT IN RESPONSE
    CURSOR          TAX_INFO_CUR             MODIFY        PRECEDENCE IS ADDED FROM 6 TO 10
    SQL STATEMENT   JAI_AR_TRX_TAX_LINES           MODIFY                PRECEDENCE IS ADDED FROM 6 TO 10
3.    27-Feb-2007   CSahoo for Bug 5390583, File Version 120.5                    Forward Porting of 11i BUG 5357400
                    When a change is done in the invoice currency code from the front end
                    the change is being reflected in the JAI_AR_TRXS table.
                    Added a IF clause for the same.


4.    14-05-2007   ssawant for bug 5879769, File Version  120.6
       Objects was not compiling. so changes are done to make it compiling.
5.    12-10-2007   ssumaith - bug#5597146 - file version 120.16
     when there is a change in currency at the invoice header , the excise av
and vat av were calculated wrongly.

Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Current Version    Current Bug    Dependent           Files                Version   Author   Date          Remarks
Of File                           On Bug/Patchset    Dependent On

ja_in_ar_hdr_update_trg.sql
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

6.    21-Mar-2008   Jia for Bug#6859632
                 Issue: TAX WILL BE ERROR IF SHIP-TO FILED OF AR TRANSACTION IS NOT ENTER AT FIRST.
                        v_price_list_val didn't multiply quantity;
                        Parameter is wrong when invoke jai_cmn_tax_defaultation_pkg.ja_in_calc_prec_taxes.
                 Fixed: 1) v_price_list_val = v_price_list_val * quantity
                        2) Add a default value for p_operation_flag parameter.

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/* --Ramananda for File.Sql.35 */
  v_customer_id                 := pr_new.Ship_To_Customer_ID;
  v_org_id                      := NVL(pr_new.Org_ID,0);
  v_header_id                   := pr_new.customer_trx_id;
  v_ship_to_site_use_id         := NVL(pr_new.Ship_To_Site_Use_ID,0);
  v_created_from                := pr_new.Created_From;
  --v_row_id                      := pr_new.rowid;
  v_last_update_date            := pr_new.last_update_date;
  v_last_updated_by             := pr_new.last_updated_by;
  v_creation_date               := pr_new.creation_date;
  v_created_by                  := pr_new.created_by;
  v_last_update_login           := pr_new.last_update_login;
  c_from_currency_code          := pr_new.invoice_currency_code;
  c_conversion_type             := pr_new.exchange_rate_type;
  c_conversion_date             := NVL(pr_new.exchange_date, pr_new.trx_date);
  c_conversion_rate             := NVL(pr_new.exchange_rate, 0);
  v_books_id                    := pr_new.set_of_books_id;
  v_trx_date                    := pr_new.trx_date;

/*  --Ramananda for File.Sql.35 */

  OPEN  transaction_type_cur;
  FETCH transaction_type_cur INTO v_trans_type;
  CLOSE transaction_type_cur;
  IF NVL(v_trans_type,'N') <> 'INV' THEN
    Return;
  END IF;

  OPEN   ONCE_COMPLETE_FLAG_CUR;
  FETCH  ONCE_COMPLETE_FLAG_CUR INTO v_once_completed_flag;
  CLOSE  ONCE_COMPLETE_FLAG_CUR;
  IF NVL(v_once_completed_flag,'N') = 'Y' THEN
    RETURN;
  END IF;
  IF v_created_from in('RAXTRX','ARXREC') THEN
     RETURN;
  END IF;
  --Following If and update added by CSahoo - bug# 5390583
  IF pr_new.invoice_currency_code <> pr_old.invoice_currency_code THEN

       UPDATE JAI_AR_TRXS
       SET    invoice_currency_code  =  pr_new.invoice_currency_code ,
              exchange_rate_type     =  pr_new.exchange_rate_type    ,
              exchange_date          =  pr_new.exchange_date         ,
              exchange_rate          =  pr_new.exchange_rate
       WHERE  customer_trx_id        =  pr_new.customer_trx_id;

  END IF;

  OPEN  ORG_CUR;
  FETCH ORG_CUR INTO v_organization_id;
  CLOSE ORG_CUR;
  IF NVL(v_organization_id,999999) = 999999 THEN  -- made 0 to 999999 because in case of setup business group setup , inventory organization value is 0
                                                  -- which was causing code to return .- bug # 2846277
    OPEN  organization_cur;
    FETCH organization_cur INTO v_organization_id;
    CLOSE organization_cur;
  END IF;
  IF NVL(v_organization_id,999999) = 999999 THEN  -- made 0 to 999999 because in case of setup business group setup , inventory organization value is 0
                                                 -- which was causing code to return .- bug # 2846277
    RETURN;
  END IF;
  OPEN address_cur(v_ship_to_site_use_id);
  FETCH address_cur INTO v_address_id;
  CLOSE address_cur;

  FOR rec In Ar_Line_Cur
  LOOP
    v_tax_category_id := '';
    v_price_list      := '';
    v_price_list_uom_code := '';
    v_conversion_rate := '';
    v_price_list_val  := '';
    v_converted_rate  := '';
    v_line_tax_amount := 0;

    DELETE JAI_AR_TRX_TAX_LINES
    WHERE  LINK_TO_CUST_TRX_LINE_ID = Rec.CUSTOMER_TRX_LINE_ID;

    IF v_customer_id IS NOT NULL AND v_address_id IS NOT NULL
    THEN
      jai_cmn_tax_defaultation_pkg.ja_in_cust_default_taxes(v_organization_id , v_customer_id ,v_ship_to_site_use_id ,
          rec.inventory_item_id ,v_header_id , rec.customer_trx_line_id,
          v_tax_category_id );
    ELSE
      jai_cmn_tax_defaultation_pkg.ja_in_org_default_taxes(v_organization_id , rec.inventory_item_id , v_tax_category_id );
    END IF;
    IF v_tax_category_id IS NOT NULL
    THEN
      OPEN  price_list_cur(v_customer_id , rec.inventory_item_id, v_address_id,rec.unit_code, v_trx_date);
      FETCH price_list_cur INTO v_price_list, v_price_list_uom_code;
      CLOSE price_list_cur;
      IF v_price_list IS NULL
      THEN
        OPEN  price_list_cur(v_customer_id ,rec.inventory_item_id, 0, rec.unit_code, v_trx_date);
        FETCH price_list_cur INTO v_price_list, v_price_list_uom_code;
        CLOSE price_list_cur;
      END IF;
      /*
      Added by ssumaith - 4245053
      */
      ln_vat_assessable_value :=  jai_general_pkg.ja_in_vat_assessable_value
                          (
                           p_party_id           => v_customer_id          ,
                           p_party_site_id      => v_ship_to_site_use_id  ,
                           p_inventory_item_id  => rec.inventory_item_id  ,
                           p_uom_code           => rec.unit_code          ,
                           p_default_price      => nvl(rec.unit_selling_price,0) , /*ssumaith - bug#5597146 */
                           p_ass_value_date     => pr_new.trx_date          ,
                           p_party_type         => 'C'
                          );


      ln_vat_assessable_value := NVL(ln_vat_assessable_value,0) * rec.quantity;

      v_line_tax_amount := nvl(rec.line_amount,0);
      IF NVL(v_price_list,0) > 0  THEN
        IF v_price_list_uom_code IS NOT NULL THEN
          INV_CONVERT.inv_um_conversion(rec.unit_code, v_price_list_uom_code, rec.inventory_item_id,v_conversion_rate);
          IF nvl(v_conversion_rate, 0) <= 0 THEN
      INV_CONVERT.inv_um_conversion(rec.unit_code, v_price_list_uom_code, 0,v_conversion_rate);
      IF nvl(v_conversion_rate, 0) <= 0  THEN
          v_conversion_rate := 0;
      END IF;
          END IF;
        END IF;
        v_converted_rate := jai_cmn_utils_pkg.currency_conversion (v_books_id ,c_from_currency_code ,
                              c_conversion_date ,c_conversion_type, c_conversion_rate);
        v_price_list := NVL(1/v_converted_rate,0) * nvl(v_price_list,0) * v_conversion_rate;
        v_price_list_val := nvl(rec.quantity * v_price_list,0);
      ELSE
        v_price_list     := rec.unit_selling_price; /*ssumaith - bug#5597146 */
        --v_price_list_val := rec.unit_selling_price; /*ssumaith - bug#5597146 */
        v_price_list_val := rec.unit_selling_price * rec.quantity ; -- Modified by Jia for Bug#6859632
      END IF;

       /*
          ln_vat_assessable_value added by ssumaith - 4245053 in the following call.
       */

---------------------------------------------------------------------------------------------------------
  /** sacseth, bug# 5631784 - TCS enhancement */
  /** Check if TCS type of taxes exists for v_tax_category_id */

  OPEN  GC_CHK_RGM_TAX_EXISTS
        ( CP_REGIME_CODE     =>   JAI_CONSTANTS.TCS_REGIME
        , CP_RGM_TAX_TYPE    =>   JAI_CONSTANTS.TAX_TYPE_TCS
        , CP_TAX_CATEGORY_ID =>   V_TAX_CATEGORY_ID
        );
        FETCH GC_CHK_RGM_TAX_EXISTS INTO LN_TCS_EXISTS;
        CLOSE GC_CHK_RGM_TAX_EXISTS;

        IF  LN_TCS_EXISTS IS NOT NULL THEN
          /** TCS type of tax(s) are present */
          OPEN  GC_GET_REGIME_ID ( CP_REGIME_CODE => JAI_CONSTANTS.TCS_REGIME);
          FETCH GC_GET_REGIME_ID INTO LN_TCS_REGIME_ID;
          CLOSE GC_GET_REGIME_ID;

          /** Check current threshold slab.  The following procedure returns null threshold_slab_id if threshold is not yet reached */
          jai_rgm_thhold_proc_pkg.get_threshold_slab_id
                                    (   p_regime_id         =>    ln_tcs_regime_id
                                      , p_organization_id   =>    v_organization_id
                                      , p_party_type        =>    jai_constants.party_type_customer
                                      , p_party_id          =>    v_customer_id
                                      , p_org_id            =>    v_org_id
                                      , p_source_trx_date   =>    v_trx_date
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
---------------------------------------------------------------------------------------------------------
      jai_cmn_tax_defaultation_pkg.ja_in_calc_prec_taxes('AR_LINES' , v_tax_category_id , v_header_id, rec.customer_trx_line_id,
    v_price_list_val , v_line_tax_amount ,rec.inventory_item_id , NVL(rec.quantity,0),
    rec.unit_code , NULL , NULL , v_converted_rate ,v_creation_date , v_created_by ,
    v_last_update_date , v_last_updated_by , v_last_update_login
    , null  --Add a default value by Jia for Bug#6859632
    , ln_vat_assessable_value
    -- Bug 6109941, Added by brathod for fwd porting bug 4742259
                        ,   p_thhold_cat_base_tax_typ      =>   jai_constants.tax_type_tcs
                        ,   p_threshold_tax_cat_id         =>   ln_threshold_tax_cat_id
                        ,   p_source_trx_type              =>   null
                        ,   p_source_table_name            =>   null
                        ,   p_action                       =>   jai_constants.default_taxes

   -- End 6109941
    );

    END IF;

    v_service_type:=JAI_AR_RCTLA_TRIGGER_PKG.get_service_type( v_customer_id,v_ship_to_site_use_id ,'C'); --added by csahoo for Bug#5879769
    UPDATE JAI_AR_TRX_LINES
       SET   tax_category_id   = v_tax_category_id,
       service_type_code = v_service_type,      --added by csahoo for Bug#5879769
    assessable_value  = nvl(v_price_list,0),
    vat_assessable_value = ln_vat_assessable_value,
    tax_amount        = v_line_tax_amount,
             total_amount      = nvl(rec.line_amount,0) + v_line_tax_amount,
             last_update_date  = v_last_update_date,
       last_updated_by   = v_last_updated_by,
       last_update_login = v_last_update_login
     WHERE  Customer_Trx_Line_ID = rec.customer_trx_line_id;

  END LOOP;
  /* Added an exception block by Ramananda for bug#4570303 */
   EXCEPTION
     WHEN OTHERS THEN
       Pv_return_code     :=  jai_constants.unexpected_error;
       Pv_return_message  := 'Encountered an error in JAI_AR_RCTA_TRIGGER_PKG.ARI_T7  '  || substr(sqlerrm,1,1900);

  END ARU_T6 ;
/*
  REM +======================================================================+
  REM NAME          ARU_T7
  REM
  REM DESCRIPTION   Called from trigger JAI_AR_RCTA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_AR_RCTA_ARU_T9
  REM
  REM
  REM  CHANGE HISTORY:
  REM             S.No      Date          Author and Details
  REM     1.        30/01/2007    SACSETHI FOR BUG 5631784
  REM                             PROCEDURE ARU_T7 IS NEWELY CREATED FOR PROVIDING TCS FUNCTIONALITY
  REM +======================================================================+
*/
PROCEDURE ARU_T7
            ( PR_OLD T_REC%TYPE , PR_NEW T_REC%TYPE , PV_ACTION VARCHAR2 , PV_RETURN_CODE OUT NOCOPY VARCHAR2 , PV_RETURN_MESSAGE OUT NOCOPY VARCHAR2 )
 IS
  LV_DOCUMENT_TYPE      VARCHAR2(40);
  LN_REG_ID             NUMBER;
  LV_ONCE_COMPLETED_FLAG   JAI_AR_TRXS.ONCE_COMPLETED_FLAG%TYPE;
  V_HEADER_ID                   NUMBER;


  CURSOR ONCE_COMPLETE_FLAG_CUR IS
  SELECT ONCE_COMPLETED_FLAG
  FROM   JAI_AR_TRXS
  WHERE  CUSTOMER_TRX_ID = V_HEADER_ID;

 BEGIN

      V_HEADER_ID                   := PR_NEW.CUSTOMER_TRX_ID;
    IF NVL(PR_NEW.COMPLETE_FLAG,JAI_CONSTANTS.NO) = JAI_CONSTANTS.YES THEN
      /** Invoice is getting COMPLETED */
      LV_DOCUMENT_TYPE := JAI_CONSTANTS.TRX_TYPE_INV_COMP;
      /*********
      || When the invoice is getting completed for the very first time (once_complete_flag is still null or 'N') then pass the
      || final TCS accounting for the TCS type of taxes belonging to the manual invoice only
      || This is not applicable for the imported invoices.
      *********/

      OPEN   ONCE_COMPLETE_FLAG_CUR;
      FETCH  ONCE_COMPLETE_FLAG_CUR INTO LV_ONCE_COMPLETED_FLAG;
      CLOSE  ONCE_COMPLETE_FLAG_CUR;

      IF Pr_new.created_from     <> 'RAXTRX'        AND
         lv_once_completed_flag = jai_constants.yes
      /*Bug 8463839 - Accounting must be done to set off Interim Liability
      Account when Transaction is completed*/
      THEN
       -- jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Calling -> jai_ar_tcs_rep_pkg.ar_accounting ');
        JAI_AR_TCS_REP_PKG.AR_ACCOUNTING (  P_RACT             =>  PR_NEW       ,
                                            P_PROCESS_FLAG     =>  PV_RETURN_CODE  ,
                                            P_PROCESS_MESSAGE  =>  PV_RETURN_MESSAGE
                                         );
--        JAI_CMN_DEBUG_CONTEXTS_PKG.PRINT ( PN_REG_ID   =>  LN_REG_ID ,
--                                           PV_LOG_MSG  =>   'RETURNED FROM JAI_AR_TCS_REP_PKG.AR_ACCOUNTING '  || CHR(10)
--                                                          ||'P_PROCESS_FLAG='   ||PV_ERR_FLG
--                                         );
    --    IF PV_ERR_FLG <> JAI_CONSTANTS.SUCCESSFUL THEN
  --        jai_cmn_debug_contexts_pkg.print ( pn_reg_id   =>  ln_reg_id ,
   --                                          pv_log_msg  =>  'Error during processing of  jai_ar_tcs_rep_pkg.ar_accounting '||chr(10)
    --                                                       ||'p_process_flag='   ||pv_err_flg||chr(10)
     --                                                      ||'p_process_message='||pv_err_msg
      --                                     );
--
  --        return;
      --  END IF;
      END IF;

    ELSIF NVL(PR_NEW.COMPLETE_FLAG,JAI_CONSTANTS.NO) = JAI_CONSTANTS.NO THEN
      /** INVOICE IS GETTING INCOMPLETED */
      LV_DOCUMENT_TYPE := JAI_CONSTANTS.TRX_TYPE_INV_INCOMP;
    END IF;

--    jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Calling -> JAI_AR_TCS_REP_PKG.PROCESS_TRANSACTIONS');
    JAI_AR_TCS_REP_PKG.PROCESS_TRANSACTIONS
                        ( P_RACT            =>  PR_NEW
                        , P_EVENT           =>  JAI_CONSTANTS.TRX_EVENT_COMPLETION
                        , P_PROCESS_FLAG    =>  PV_RETURN_CODE
                        , P_PROCESS_MESSAGE =>  PV_RETURN_MESSAGE
                        );
  --  jai_cmn_debug_contexts_pkg.print (ln_reg_id
--                            , 'Process Result: '  || chr(10)
--                            ||'p_process_flag='   ||PV_RETURN_CODE||chr(10)
--                            ||'p_process_message='||PV_RETURN_MESSAGE||chr(10)
--                            );
    IF PV_RETURN_CODE <> JAI_CONSTANTS.SUCCESSFUL THEN
      RETURN;
    END IF;

 END ARU_T7;

/*
  REM +======================================================================+
  REM NAME          ARU_T8
  REM
  REM DESCRIPTION   Called from trigger JAI_AR_RCTA_ARIUD_T1 for deal with
  REM               RMA credit only
  REM
  REM HISTORY       Created by Bo Li for bug9666476
  REM
  REM 18-MAY-2010   Modified by Bo Li for Bug9706176
  REM               Change the cursor logic of check_rma_credit_cur
  REM               Added the new cursor get_order_and_item_id_cur &
  REM               check_shippable_item_cur
  REM
  REM 03-JUN-2010   Modified by Bo Li for Bug9759668
  REM                Get the VAT invoice number from the source SO and insert the source
  REM                VAT invoice number to REPOSITORY table when pre_customer_trx_id is null.
  REM                In functoinality,the issue happens when the Source SO and RMA SO
  REM                are imported into AR together.
  REM 10-Jun-2010   Modified by Allen Yang for bug 9793678
  REM               Commented code which populates VAT invoice number on
  REM               JAI_AR_TRXS for non-shippable RMA.
  REM +======================================================================+
*/
 PROCEDURE ARU_T8 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
   v_organization_id       NUMBER                                       ;
   v_loc_id                NUMBER                                       ;
   v_trans_type            RA_CUST_TRX_TYPES_ALL.TYPE%TYPE              ;
   lv_vat_invoice_no       JAI_AR_TRXS.VAT_INVOICE_NO%TYPE              ;
   ln_regime_id      JAI_RGM_DEFINITIONS.REGIME_ID%TYPE                 ;
   ln_regime_code          JAI_RGM_DEFINITIONS.REGIME_CODE%TYPE         ;
   lv_process_flag         VARCHAR2(10)                                 ;
   lv_process_message      VARCHAR2(4000)                               ;
   ld_gl_date              RA_CUST_TRX_LINE_GL_DIST_ALL.GL_DATE%TYPE    ;
   ld_vat_invoice_date     JAI_AR_TRXS.VAT_INVOICE_DATE%TYPE            ;

   ln_rma_flag                NUMBER;
   ln_order_line_id           NUMBER;
   ln_nonship_rma_flag        NUMBER;

    /*
   || Get the order line id for customer trx line
   */
   CURSOR get_order_and_item_id_cur
   IS
   SELECT  interface_line_attribute6 order_line_id
          ,inventory_item_id
   FROM   ra_customer_trx_lines_all
   WHERE  customer_trx_id = pr_new.customer_trx_id;

    /*
   || Check the trasaction is from RMA credit only
   */
   CURSOR check_rma_credit_cur(pn_order_line_id NUMBER)
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
   AND   oh.order_number = pr_new.interface_header_attribute1
   AND   ot.language = userenv('LANG')
   AND   ol.line_id = pn_order_line_id
   AND   owf.process_name IN ('R_RMA_CREDIT_APP_HDR_INV',
                              'R_RMA_CREDIT_WO_SHIP_APPROVE',
                              'R_RMA_CREDIT_WO_SHIP_HDR_INV',
                              'R_RMA_FOR_CREDIT_WO_SHIPMENT',
                              'R_RMA_FOR_OTA_CREDIT');

   /*
   || Check the item type shippable or  non-shippable
   */
   CURSOR check_shippable_item_cur(pn_inventory_item_id NUMBER,pn_order_line_id NUMBER)
   IS
   SELECT COUNT(1)
   FROM MTL_SYSTEM_ITEMS msi,
        JAI_OM_OE_RMA_LINES l
   WHERE msi.inventory_item_id = pn_inventory_item_id
   AND   msi.inventory_item_id = l.inventory_item_id
   AND   l.rma_line_id = pn_order_line_id
   AND   msi.shippable_item_flag = 'N'  ;

   /*
   || Get the organization, location, vat_invoice_no and vat_invoice_date from JAI_AR_TRXS
   */
   CURSOR organization_cur
   IS
   SELECT organization_id   ,
          location_id       ,
          vat_invoice_no    ,
          vat_invoice_date
   FROM  JAI_AR_TRXS
   WHERE customer_trx_id = pr_new.customer_trx_id;

  /*
  || Get the transaction type of the document
  */
  CURSOR transaction_type_cur
  IS
  SELECT  type
  FROM    ra_cust_trx_types_all
  WHERE   cust_trx_type_id  = pr_new.cust_trx_type_id   AND
          NVL(org_id,0)   = NVL(pr_new.org_id,0);


   /*
   || Check whether vat types of taxes exist for the CM.
   || IF yes then get the regime id and regime code
   */
   CURSOR cur_vat_taxes_exist
   IS
   SELECT regime_id   ,
          regime_code
   FROM
          JAI_AR_TRX_TAX_LINES jcttl,
          JAI_AR_TRX_LINES jctl,
          JAI_CMN_TAXES_ALL             jtc ,
          jai_regime_tax_types_v      jrttv
   WHERE jcttl.link_to_cust_trx_line_id  = jctl.customer_trx_line_id
   AND   jctl.customer_trx_id            = pr_new.customer_trx_id
   AND   jcttl.tax_id                    = jtc.tax_id
   AND   jtc.tax_type                    = jrttv.tax_type
   AND   regime_code                     = jai_constants.vat_regime
   AND   jtc.org_id                      = pr_new.org_id ;


  CURSOR  cur_get_gl_date(cp_acct_class ra_cust_trx_line_gl_dist_all.account_class%type)
  IS
  SELECT gl_date
  FROM   ra_cust_trx_line_gl_dist_all
  WHERE  customer_trx_id = pr_new.customer_trx_id
  AND    account_class   = cp_acct_class
  AND    latest_rec_flag = 'Y';

  CURSOR  cur_get_in_vat_no
  IS
  SELECT vat_invoice_no
  FROM JAI_AR_TRXS
  WHERE customer_trx_id = pr_new.previous_customer_trx_id;

  /*
  || Check if only 'VAT REVERSAL' tax type is present in ja_in_ra_cust_trx_tax_lines
  */
  CURSOR c_chk_vat_reversal (cp_tax_type jai_cmn_taxes_all.tax_type%TYPE )
   IS
   SELECT 1
   FROM   JAI_AR_TRX_TAX_LINES jcttl,
          JAI_AR_TRX_LINES jctl,
          JAI_CMN_TAXES_ALL            jtc
   WHERE  jcttl.link_to_cust_trx_line_id  = jctl.customer_trx_line_id
     AND     jctl.customer_trx_id            = pr_new.customer_trx_id
     AND     jcttl.tax_id                    = jtc.tax_id
     AND     jtc.org_id                      = pr_new.org_id
     AND     jtc.tax_type                    = cp_tax_type ;

    lv_vat_reversal   VARCHAR2(30);
    ln_vat_reversal_exists  NUMBER;

   /*
   || Retrieve the regime_id which is of regime code 'VAT'
   */
      CURSOR c_get_regime_id
      IS
      SELECT regime_id
      FROM   jai_regime_tax_types_v
      WHERE  regime_code = jai_constants.vat_regime
      AND    rownum      = 1 ;

    --Added by Bo Li for Bug9759668 on 2010-6-2 Begin
    -------------------------------------------------------------
    CURSOR get_copy_vat_invoice_cur
    IS
    SELECT jwl.vat_invoice_no
    FROM OE_ORDER_HEADERS_ALL    ohc,
         oe_transaction_types_tl ot,
         JAI_OM_WSH_LINES_ALL    jwl
   WHERE ohc.order_type_id = ot.transaction_type_id
     AND ot.LANGUAGE = userenv('LANG')
     AND ohc.source_document_id = jwl.ORDER_HEADER_ID
     AND ohc.ORDER_NUMBER = pr_new.INTERFACE_HEADER_ATTRIBUTE1
     AND ot.NAME = pr_new.INTERFACE_HEADER_ATTRIBUTE2;

   -------------------------------------------------------------
   --Added by Bo Li for Bug9759668 on 2010-6-2 End


  BEGIN
    pv_return_code := jai_constants.successful ;

  /*
  || Get the Otransaction type of the document
  || Process only CM type of transaction's
  */
  OPEN  transaction_type_cur;
  FETCH transaction_type_cur INTO v_trans_type;
  CLOSE transaction_type_cur;

  IF NVL(v_trans_type,'N') <> 'CM'
  OR pr_new.created_from <> 'RAXTRX' THEN
  /*
  || In case of CM only VAT accouting should be done.
  */
     RETURN;
  END IF;

  /*
  || Get the Organization and location info , vat_invoice_no, vat_invoice_date
  */
  OPEN  organization_cur;
  FETCH organization_cur
  INTO  v_organization_id
       ,v_loc_id
       ,lv_vat_invoice_no
       ,ld_vat_invoice_date ;
  CLOSE organization_cur;

  IF lv_vat_invoice_no   IS NOT NULL OR
     ld_vat_invoice_date IS NOT NULL
  THEN
    /*
    || IF vat_invoice_no or vat_invoice_date has already been populated into this record (indicating that it has already been run once)
    || then return.
    */
    RETURN;
  END IF;


  OPEN  cur_vat_taxes_exist;
  FETCH cur_vat_taxes_exist into  ln_regime_id,ln_regime_code;
  CLOSE cur_vat_taxes_exist;

  IF upper(nvl(ln_regime_code,'####')) <> UPPER(jai_constants.vat_regime)  THEN
    /*
    || only vat type of taxes should be processed
    */
    RETURN;
  END IF;
    /*
    || Check if only 'VAT REVERSAL' tax type is present in ja_in_ra_cust_trx_tax_lines
    */
  IF ln_regime_id IS NULL THEN
    lv_vat_reversal := 'VAT REVERSAL' ;
    OPEN  c_chk_vat_reversal(lv_vat_reversal) ;
    FETCH c_chk_vat_reversal INTO ln_vat_reversal_exists;
    CLOSE c_chk_vat_reversal ;

    /*
    || Retrieve the regime_id for 'VAT REVERSAL' tax type, which is of regime code 'VAT'
    */
    IF ln_vat_reversal_exists = 1 THEN
      OPEN  c_get_regime_id ;
      FETCH c_get_regime_id
      INTO ln_regime_id ;
      CLOSE c_get_regime_id ;

      IF  ln_regime_id IS NOT NULL THEN
          ln_regime_code := jai_constants.vat_regime ;
      END IF ;
    END IF ;
  END IF ;

  /*
  || Get the vat invoice number for the Credit Memo from the Source Invoice only if a CM has a source INvoice
  || IF it is from legacy then the vat invoice number would go as null
  */
  IF pr_new.previous_customer_trx_id is NOT NULL THEN
    OPEN  cur_get_in_vat_no;
    FETCH cur_get_in_vat_no
    INTO lv_vat_invoice_no;
    CLOSE cur_get_in_vat_no ;
   --Added by Bo Li for Bug9759668 on 2010-6-2 Begin
   ---------------------------------------------------
  ELSE
    OPEN  get_copy_vat_invoice_cur;
    FETCH get_copy_vat_invoice_cur
    INTO  lv_vat_invoice_no;
    CLOSE get_copy_vat_invoice_cur ;
   ---------------------------------------------------
   --Added by Bo Li for Bug9759668 on 2010-6-2 End
  END IF;

  /*
  || Get the gl_date from ra_cust_trx_lines_gl_dist_all
  */
  OPEN  cur_get_gl_date('REC');  /* Modified by Ramananda for removal of SQL LITERALs */
  FETCH cur_get_gl_date INTO ld_gl_date;
  CLOSE cur_get_gl_date;

  FOR get_order_and_item_id_rec IN get_order_and_item_id_cur LOOP


    OPEN  check_rma_credit_cur(get_order_and_item_id_rec.order_line_id);
    FETCH check_rma_credit_cur
    INTO  ln_rma_flag;
    CLOSE check_rma_credit_cur;

    OPEN  check_shippable_item_cur( get_order_and_item_id_rec.inventory_item_id
                                   ,get_order_and_item_id_rec.order_line_id);
    FETCH check_shippable_item_cur
    INTO  ln_nonship_rma_flag;
    CLOSE check_shippable_item_cur;

  IF ln_rma_flag >0 OR ln_nonship_rma_flag >0
  THEN
      /*
      || IF the VAT invoice Number has been successfully generated, then pass accounting entries
      */
      jai_cmn_rgm_vat_accnt_pkg.process_order_invoice (       p_regime_id               => ln_regime_id                       ,
                                                              p_source                  => jai_constants.source_ar            ,
                                                              p_organization_id         => v_organization_id                  ,
                                                              p_location_id             => v_loc_id                           ,
                                                              p_delivery_id             => NULL                               ,
                                                              p_order_line_id           => get_order_and_item_id_rec.order_line_id,
                                                              p_customer_trx_id         => pr_new.customer_trx_id             ,
                                                              p_transaction_type        => v_trans_type                       ,
                                                              p_vat_invoice_no          => lv_vat_invoice_no                  ,
                                                              p_default_invoice_date    => nvl(ld_gl_date,pr_new.trx_date)    ,
                                                              p_batch_id                => NULL                               ,
                                                              p_called_from             => 'JA_IN_LOC_AR_HDR_UPD_TRG_VAT'     ,
                                                              p_debug                   => jai_constants.no                   ,
                                                              p_process_flag            => lv_process_flag                    ,
                                                              p_process_message         => lv_process_message
                                                        );



      IF lv_process_flag = jai_constants.expected_error    OR
         lv_process_flag = jai_constants.unexpected_error
      THEN
        pv_return_code    := jai_constants.expected_error ;
        pv_return_message := lv_process_message ;
        RETURN ;
      END IF;
  END IF;
  END LOOP;

  /* Commented by Allen Yang 10-Jun-2010 for bug 9793678
  IF lv_vat_invoice_no IS NOT NULL THEN
  UPDATE JAI_AR_TRXS
  SET   vat_invoice_no   = lv_vat_invoice_no          ,
        vat_invoice_date = nvl(ld_gl_date,pr_new.trx_date)
  WHERE customer_trx_id  = pr_new.customer_trx_id ;
  END IF;
  */

   EXCEPTION
     WHEN OTHERS THEN
       Pv_return_code     :=  jai_constants.unexpected_error;
       Pv_return_message  := 'Encountered an error in JAI_AR_RCTA_TRIGGER_PKG.ARU_T8 '  || substr(sqlerrm,1,1900);

  END ARU_T8 ;


  /*
  REM +======================================================================+
  REM NAME          ASI_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_AR_RCTA_ASI_T1
  REM
  REM NOTES         Refers to old trigger JAI_AR_RCTA_ASI_T1
  REM
  REM +======================================================================+
  */
  PROCEDURE ASI_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
   /*---------------------------------------------------------------------------
    HISTORY :
    1.  08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old
                      DB Entity as required for CASE COMPLAINCE.  Version 116.1

    2.  10-Jun-2005    File Version: 116.2
                       Removal of SQL LITERALs is done

    3.  10-Jun-2005   rallamse bug#4448789  116.3
                      Added legal_entity_id for table JAI_AR_TRXS in insert statement

    4.  26-07-2005   rallamse bug#4510143 120.2
                     Modified legal_entity_id for table JAI_AR_TRXS to get from header_info_cur cursor

    5.  10-Aug-2005  Aiyer bug 4545146 version 120.1
                     Issue:-
                       Deadlock on tables due to multiple triggers on the same table (in different sql files)
                       firing in the same phase.
                     Fix:-
                       Multiple triggers on the same table have been merged into a single file to resolve
                        the problem
                       The following files have been stubbed:-
                         jai_ar_rcta_t1.sql
                         jai_ar_rcta_t2.sql
                         jai_ar_rcta_t3.sql
                         jai_ar_rcta_t4.sql
                         jai_ar_rcta_t6.sql
                         jai_ar_rcta_t7.sql
                         jai_ar_rcta_t8.sql
                         jai_ar_rcta_t9.sql
                       Instead the new file jai_ar_rcta_t.sql has been created which contains all the triggers

    ---------------------------------------------------------------------------------------------------*/
      v_created_from    Varchar2(30);
      v_header_id     Number;
      v_customer_trx_line_id  Number;
      v_recurred_from_trx_number    Varchar2(20);
      v_trx_number      Varchar2(20);
      v_once_completed_flag   Varchar2(1);
      x       Number;
      v_batch_source_id   Number := 0;
      v_parent_header_id    Number;
      v_line_tax_amount   Number := 0;
      v_header_tax_amount   Number := 0;
      v_last_update_date    Date;
      v_last_updated_by   Number;
      v_creation_date   Date;
      v_created_by      Number;
      v_last_update_login   Number;
      v_service_type    VARCHAR2(30); --added by ssawant

      CURSOR temp_fetch IS
      SELECT trx_number, customer_trx_id, recurred_from_trx_number, batch_source_id, created_from,
         creation_date, created_by, last_update_date, last_updated_by, last_update_login
      FROM   JAI_AR_TRX_COPY_HDR_T
      ORDER BY customer_trx_id;

      CURSOR ONCE_COMPLETE_FLAG_CUR(p_header_id  IN NUMBER, p_batch_source_id IN Number) IS
      SELECT once_completed_flag, 1
      FROM   JAI_AR_TRXS
      WHERE  customer_trx_id = p_header_id
      AND    NVL(batch_source_id,0) = p_batch_source_id;

      CURSOR parent_header_id(p_recurred_from_trx_number IN Varchar2, p_batch_source_id IN Number) IS
      SELECT a.customer_trx_id
       FROM   JAI_AR_TRXS a
      WHERE  a.trx_number = p_recurred_from_trx_number
      AND    NVL(batch_source_id,0) = p_batch_source_id;

      CURSOR LINES_INFO_CUR(p_parent_header_id  IN Number) IS
      SELECT customer_trx_line_id, line_number, description, inventory_item_id, unit_code, quantity, tax_category_id,
         auto_invoice_flag, unit_selling_price, line_amount, gl_date,
         tax_amount,total_amount,assessable_value
      FROM   JAI_AR_TRX_LINES
      WHERE  customer_trx_id = p_parent_header_id
      ORDER BY customer_trx_line_id;

      CURSOR TAX_INFO_CUR(p_parent_line_id IN NUMBER) IS
      SELECT a.tax_line_no,
             a.precedence_1,a.precedence_2, a.precedence_3, a.precedence_4,a.precedence_5,
             a.precedence_6,a.precedence_7, a.precedence_8, a.precedence_9,a.precedence_10, -- Date  06/12/2006 Bug 5228046 added by SACSETHI
             a.tax_id, a.tax_rate, a.qty_rate, a.uom, a.tax_amount, a.base_tax_amount, a.func_tax_amount,
             b.end_date valid_date, b.tax_type
      FROM   JAI_AR_TRX_TAX_LINES a, JAI_CMN_TAXES_ALL b
      WHERE  a.link_to_cust_trx_line_id = p_parent_line_id
      AND    a.tax_id = b.tax_id
      ORDER BY a.tax_line_no;


      CURSOR HEADER_INFO_CUR(p_recurred_from_trx_number IN Varchar2, p_batch_source_id IN Number) IS
      SELECT CUSTOMER_TRX_ID, ORGANIZATION_ID, LOCATION_ID, UPDATE_RG_FLAG, UPDATE_RG23D_FLAG,
         TAX_AMOUNT, LINE_AMOUNT, TOTAL_AMOUNT, BATCH_SOURCE_ID,legal_entity_id  /* added rallamse bug#4448789 */
      FROM   JAI_AR_TRXS
      WHERE  trx_number = p_recurred_from_trx_number
      AND    NVL(batch_source_id,0) = p_batch_source_id;

    BEGIN
    pv_return_code := jai_constants.successful ;

      OPEN   temp_fetch;
      FETCH  temp_fetch INTO v_trx_number, v_header_id, v_recurred_from_trx_number, v_batch_source_id,
           v_created_from, v_creation_date, v_created_by,
           v_last_update_date, v_last_updated_by, v_last_update_login;
      CLOSE  temp_fetch;

      DELETE JAI_AR_TRX_COPY_HDR_T
      WHERE  customer_trx_id = v_header_id;

      IF v_trx_number IS NULL THEN
        Return;
      END IF;
     IF v_created_from <>'ARXREC' THEN
         RETURN;
      END IF;

      OPEN   ONCE_COMPLETE_FLAG_CUR(v_header_id, v_batch_source_id);
      FETCH  ONCE_COMPLETE_FLAG_CUR INTO v_once_completed_flag, x;
      CLOSE  ONCE_COMPLETE_FLAG_CUR;
      IF NVL(v_once_completed_flag,'N') = 'Y' THEN
        RETURN;
      END IF;

      OPEN   parent_header_id(v_recurred_from_trx_number, v_batch_source_id);
      FETCH  parent_header_id INTO v_parent_header_id;
      CLOSE  parent_header_id;

      IF NVL(x,0) <> 1 THEN

        FOR hdr in HEADER_INFO_CUR(v_recurred_from_trx_number, v_batch_source_id)
        LOOP
          INSERT INTO JAI_AR_TRXS
          (customer_trx_id, organization_id, location_id, update_rg23d_flag,
          update_rg_flag, trx_number, once_completed_flag,
          line_amount, batch_source_id, created_from,
          creation_date, created_by,
          last_update_date,last_updated_by, last_update_login,
          legal_entity_id)     /* added rallamse bug#4448789 */
              VALUES(v_header_id, hdr.organization_id, hdr.location_id, hdr.update_rg23d_flag,
          hdr.update_rg_flag, v_trx_number, 'N',
          hdr.line_amount, hdr.batch_source_id, v_created_from ,
          v_creation_date, v_created_by,
          v_last_update_date, v_last_updated_by, v_last_update_login,
          hdr.legal_entity_id); /* added rallamse bug#4448789 */
        END LOOP;
      END IF;
      --added by ssawant to replace r_new to pr_new
      v_service_type:=JAI_AR_RCTLA_TRIGGER_PKG.get_service_type( NVL(pr_new.SHIP_TO_CUSTOMER_ID ,pr_new.BILL_TO_CUSTOMER_ID) ,
                              NVL(pr_new.SHIP_TO_SITE_USE_ID, pr_new.BILL_TO_SITE_USE_ID),'C');    -- added by csahoo for bug#5879769

      FOR rec in LINES_INFO_CUR(v_parent_header_id)
      LOOP

      -- SELECT ra_customer_trx_lines_s.nextval INTO v_customer_trx_line_id FROM Dual;

        INSERT INTO JAI_AR_TRX_LINES
            (customer_trx_line_id, line_number,
            customer_trx_id, description,
              inventory_item_id, unit_code,
            quantity, tax_category_id,auto_invoice_flag ,
                unit_selling_price, line_amount, gl_date,
            assessable_value,
            creation_date, created_by,
            last_update_date,last_updated_by,
            last_update_login,
            service_type_code)    --added by csahoo for Bug#5879769
                   VALUES(ra_customer_trx_lines_s.nextval,
                  --v_customer_trx_line_id, /* Commented by Ramananda as a part of removal of SQL LITERALs  */
                  rec.line_number,
            v_header_id,rec.description,
            rec.inventory_item_id, rec.unit_code,
            rec.quantity, rec.tax_category_id,rec.auto_invoice_flag,
            rec.unit_selling_price,rec.line_amount, rec.gl_date,
            rec.assessable_value,
            v_creation_date, v_created_by, v_last_update_date,
            v_last_updated_by, v_last_update_login,
            v_service_type)   --added by csahoo for Bug#5879769
            returning customer_trx_line_id into v_customer_trx_line_id ;

        FOR rec1 in TAX_INFO_CUR(rec.customer_trx_line_id)
        LOOP
          IF rec1.valid_date < sysdate THEN
            rec1.tax_amount := 0;
            rec1.base_tax_amount := 0;
            rec1.func_tax_amount := 0;
          END IF;
            INSERT INTO JAI_AR_TRX_TAX_LINES(customer_trx_line_id, link_to_cust_trx_line_id, tax_line_no,
                                             precedence_1,precedence_2, precedence_3, precedence_4,precedence_5,
                                             precedence_6,precedence_7, precedence_8, precedence_9,precedence_10, -- Date  06/12/2006 Bug 5228046 added by SACSETHI
                                             tax_id, tax_rate, qty_rate, uom,
               tax_amount, base_tax_amount, func_tax_amount,
               creation_date, created_by, last_update_date,
               last_updated_by, last_update_login)
                  VALUES(    ra_customer_trx_lines_s.nextval, v_customer_trx_line_id, rec1.tax_line_no,
                 rec1.precedence_1, rec1.precedence_2, rec1.precedence_3, rec1.precedence_4, rec1.precedence_5,
                 rec1.precedence_6, rec1.precedence_7, rec1.precedence_8, rec1.precedence_9, rec1.precedence_10, -- Date  06/12/2006 Bug 5228046 added by SACSETHI
                 rec1.tax_id, rec1.tax_rate, rec1.qty_rate, rec1.uom,
           rec1.tax_amount, rec1.base_tax_amount, rec1.func_tax_amount,
           v_creation_date, v_created_by, v_last_update_date,
           v_last_updated_by, v_last_update_login);

            IF rec1.tax_type <> 'TDS' THEN
              v_line_tax_amount := nvl(v_line_tax_amount,0) + nvl(rec1.tax_amount,0);
            END IF;

            IF rec1.tax_type in ('Excise', 'Addl. Excise', 'Other Excise') THEN
              v_header_tax_amount := nvl(v_header_tax_amount,0) + nvl(rec1.tax_amount,0);
            END IF;

        END LOOP;
        UPDATE  JAI_AR_TRX_LINES
        SET     tax_amount =  v_line_tax_amount,
            total_amount = nvl(line_amount,0) + v_line_tax_amount
        WHERE   customer_trx_line_id = v_customer_trx_line_id;
        v_line_tax_amount := 0;
      END LOOP;

      UPDATE  JAI_AR_TRXS
      SET     tax_amount =  v_header_tax_amount,
          total_amount = nvl(line_amount,0) + v_header_tax_amount
      WHERE   customer_trx_id = v_header_id;
      v_header_tax_amount := 0;

  END ASI_T1 ;

  --added this procedure for bug#7450481
  PROCEDURE ARD_T1 ( pr_old t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
  BEGIN
    DELETE JAI_AR_TRXS
    WHERE  customer_trx_id = pr_old.customer_trx_id ;

   pv_return_message := '';
   pv_return_code := jai_constants.successful;

  EXCEPTION
    when others then
      pv_return_message := substr (sqlerrm,1,1999);
      pv_return_code := jai_constants.unexpected_error;
  END ARD_T1;

END JAI_AR_RCTA_TRIGGER_PKG ;

/
