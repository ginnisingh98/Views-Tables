--------------------------------------------------------
--  DDL for Package Body JAI_JAR_TRXS_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_JAR_TRXS_TRIGGER_PKG" AS
/* $Header: jai_jar_t.plb 120.7.12010000.2 2009/01/05 12:46:00 csahoo ship $ */

/*
  REM +======================================================================+
  REM NAME          ARU_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_JAR_T_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_JAR_T_ARU_T1
  REM
  REM +======================================================================+
*/
  PROCEDURE ARU_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
    v_org_id                      Number;
  v_loc_id                      Number := 0;
  v_receipt_id          Number;
  v_reg_code            Varchar2(30);
  v_reg_type                    Varchar2(10);
  v_complete_flag       Varchar2(1);
  v_fin_year            Number;
  v_register_id         number;
  v_payment_register    Varchar2(30) ;
  v_basic_ed            Number := 0;
  v_additional_ed       Number := 0;
  v_other_ed            Number := 0;
  v_rg_flag                     Varchar2(1);
  v_tax_amount          Number := 0;
  v_charge_account      number;
  v_tax_rate            Number := 0;
  v_rg_register_id      Number := 0;

  v_rg23a_bal           number := 0;
  v_rg23c_bal           number := 0;
  v_pla_bal             number := 0;
  v_sold_cust_id                Number;
  v_ship_cust_id                Number;
  v_ship_to_site_use_id Number;
  v_cust_trx_type_id    Number;
  v_trx_date            Date;
  v_batch_source_id     Number := 0;
  v_account_id          Number;
  v_counter                     Number := 0;
  v_average_duty                Number := 0;
  v_rg23_part_ii_no     Number;
  v_rg23_part_i_no      Number;
  v_excise_flag         Varchar2(1);
  v_pla_register_no     Number;
  v_part_i_register_id  Number ;

/* --Ramananda for File.Sql.35 */
  v_item_class          Varchar2(10); -- := 'N';
  v_customer_trx_id     Number; -- := pr_old.customer_trx_id;
  v_last_update_date    Date ; --  := pr_new.last_update_date;
  v_last_updated_by     Number; -- := pr_new.last_updated_by;
  v_creation_date       Date; --   := SYSDATE;
  v_created_by          Number; -- := pr_new.created_by;
  v_last_update_login   Number; -- := pr_new.last_update_login;
  v_set_of_books_id     Number; -- := pr_new.set_of_books_id;
  v_currency_code       Varchar2(30); -- := pr_new.invoice_currency_code;
  v_conv_date           Date ; --        := NVL(pr_new.exchange_date, pr_new.creation_date);
  v_conv_type_code      Varchar2(30); -- := pr_new.Exchange_Rate_Type;
  v_conv_rate           Number ; --      := pr_new.Exchange_rate;
  v_trx_number          varchar2(20); --  := pr_new.Trx_Number;
  v_source_name         Varchar2(100); -- := 'Receivables India';
  v_category_name       Varchar2(100); -- := 'RG Register Data Entry';
/* --Ramananda for File.Sql.35 */

  v_converted_rate      Number;
  v_assessable_value    Number;
/*  v_bill_to_site_id     number;
  v_bill_to_site_use_id number;    */
--2001/05/04    Vijay,Subbu.

  v_tax_rate_counter    Number := 0;
  v_match_tax_rate      Number := 0;
  v_rg23d_receipt_id    Number;
  v_oth_receipt_id      Number;
  v_duty_amount         number;
  uom_code              varchar2(3);
  V_item_trading_flag   Varchar2(1);
  v_modvat_tax_rate     Number;
  v_remarks             Varchar2(60);
  v_rounding_factor     Number;
  v_opt_unit            Number; --2001/05/04    Vijay,Subbu.
  v_bill_to_customer_id Number; --2001/05/04    Vijay,Subbu.
  v_bill_to_site_use_id Number; --2001/05/04    Vijay,Subbu.
   --Added the below 3 variables by Anujsax for Bug#5636544
  lv_excise_invoice_no  jai_ar_trx_lines.excise_invoice_no%TYPE;
  req_id                NUMBER;
  result                BOOLEAN;
    ---ended  by Anujsax for Bug#5636544
  Cursor complete_info_cur IS
  Select SHIP_TO_CUSTOMER_ID,SHIP_TO_SITE_USE_ID,CUST_TRX_TYPE_ID,
        TRX_DATE,SOLD_TO_CUSTOMER_ID,
           BATCH_SOURCE_ID,
         BILL_TO_CUSTOMER_ID, BILL_TO_SITE_USE_ID --2001/05/04  Vijay,Subbu.
  From   JAI_AR_TRX_INS_HDRS_T
  Where  customer_trx_id = v_customer_trx_id;

  --2001/06/22 Anuradha Parthasarathy
  /*Cursor org_loc_cur IS
  SELECT organization_id,location_id,register_type,rg_update_flag,once_completed_flag
  FROM   JAI_AR_TRX_APPS_RELS_T
  WHERE  paddr = (SELECT paddr FROM v$session WHERE sid =
               (SELECT sid FROM v$mystat WHERE rownum = 1));*/

  Cursor org_loc_cur IS
  SELECT organization_id, location_id, register_type, rg_update_flag, once_completed_flag
  FROM JAI_AR_TRX_APPS_RELS_T r;/*, v$session s
  WHERE r.paddr = s.paddr
  and s.audsid=userenv('SESSIONID');*/ --commented by rchandan for CASE120
--2001/06/22 Anuradha Parthasarathy
--assessable value added
  Cursor line_cur IS
  SELECT customer_trx_line_id line_id, payment_register, inventory_item_id,
           quantity quantity_invoiced,unit_selling_price,unit_code,
           excise_invoice_no, excise_invoice_date, assessable_value,
        customer_trx_line_id, excise_exempt_type
  FROM   JAI_AR_TRX_LINES
  WHERE  customer_trx_id = v_customer_trx_id;
  CURSOR REG_BALANCE_CUR(p_org_id IN Number,
                         p_loc_id IN Number) IS
  SELECT nvl(rg23a_balance,0) rg23a_balance ,nvl(rg23c_balance,0) rg23c_balance,
nvl(pla_balance,0) pla_balance
  FROM   JAI_CMN_RG_BALANCES
  WHERE  organization_id = p_org_id AND
         location_id = p_loc_id;
  Cursor register_code_cur(p_org_id IN Number,  p_loc_id IN Number, p_batch_source_id IN NUMBER)  IS
  SELECT register_code
  FROM   JAI_OM_OE_BOND_REG_HDRS
  WHERE  organization_id = p_org_id AND
         location_id    = p_loc_id  AND
         register_id in (SELECT register_id FROM   JAI_OM_OE_BOND_REG_DTLS
                         WHERE  order_type_id = p_batch_source_id and order_flag ='N');
  CURSOR excise_cal_cur(p_line_id IN NUMBER, p_inventory_item_id IN NUMBER,
                                p_org_id IN NUMBER) IS
  select A.tax_id,
        A.tax_rate t_rate,
        A.tax_amount tax_amt,
        A.func_tax_amount func_amt,
    (a.func_tax_amount*100)/decode(a.tax_rate,0,0.01) taxable_amt, --2001/03/30 Jagdish
        A.BASE_TAX_AMOUNT BASE_TAX_AMT,                 --2001/03/30 Jagdish
        b.tax_type t_type,
        b.stform_type,
        a.tax_line_no
  from   JAI_AR_TRX_TAX_LINES A , JAI_CMN_TAXES_ALL B,
         JAI_INV_ITM_SETUPS C
  where  link_to_cust_trx_line_id = p_line_id
         and  a.tax_id = b.tax_id
         and  c.inventory_item_id = p_inventory_item_id
         and  c.organization_id = p_org_id
     AND c.item_class in ('RMIN','RMEX','CGEX','CGIN','CCEX','CCIN','FGIN','FGEX')
  order by 1;
  cursor item_class_cur(P_ORG_ID IN NUMBER,P_INVENTORY_ITEM_ID IN NUMBER)  IS
  select item_class, excise_flag,item_trading_flag
  from   JAI_INV_ITM_SETUPS
  where  inventory_item_id = p_inventory_item_id AND
         ORGANIZATION_ID = P_ORG_ID;
  cursor organization_cur IS
  select organization_id,location_id
  FROM   JAI_AR_TRX_INS_HDRS_T
  WHERE  customer_trx_id = v_customer_trx_id;
  CURSOR fin_year_cur(p_org_id IN NUMBER) IS
  SELECT MAX(a.fin_year)
  FROM   JAI_CMN_FIN_YEARS a
  WHERE  organization_id = p_org_id and fin_active_flag = 'Y';

  CURSOR matched_receipt_cur(p_customer_trx_line_id  IN NUMBER) IS
  SELECT a.receipt_id, a.quantity_applied, b.transaction_type,b.qty_to_adjust,
        b.rate_per_unit,b.excise_duty_rate
  FROM   JAI_CMN_MATCH_RECEIPTS a, JAI_CMN_RG_23D_TRXS b
  WHERE  a.ref_line_id = p_customer_trx_line_id
    AND  a.receipt_id = b.register_id
    AND  a.quantity_applied > 0 ;
  CURSOR tax_rate_cur(p_customer_trx_line_id IN NUMBER, p_receipt_id IN NUMBER)
IS
  SELECT tax_rate
  FROM   JAI_CMN_MATCH_TAXES
  WHERE  ref_line_id = p_customer_trx_line_id
  AND   receipt_id = p_receipt_id; /* Modified by Ramananda for removal of SQL LITERALs */
--    AND  nvl(receipt_id,0) = p_receipt_id;

 --added by GD
   CURSOR for_modvat_percentage(v_org_id NUMBER, v_location_id NUMBER) IS
      SELECT MODVAT_REVERSE_PERCENT
      FROM   JAI_CMN_INVENTORY_ORGS
      WHERE  organization_id = v_org_id
      AND    (location_id = v_location_id
             OR
       (location_id is NULL AND  v_location_id is NULL));
      --AND NVL(location_id,0) = NVL(v_location_id,0);

   CURSOR for_modvat_tax_rate(p_cust_trx_line_id NUMBER) IS
      SELECT a.tax_rate, b.rounding_factor
      FROM   JAI_AR_TRX_TAX_LINES a, JAI_CMN_TAXES_ALL b
      WHERE  a.tax_id = b.tax_id
      AND    a.link_to_cust_trx_line_id = p_cust_trx_line_id
      AND    b.tax_type = jai_constants.tax_type_modvat_recovery  ; /*'Modvat Recovery'; Ramananda for removal of SQL LITERALs */
--added by GD

  /* Bug 5243532. Added by Lakshmi Gopalsami
   * Removed the cursor set_of_books_cur and implemented using caching logic.
   */

--2001/05/04    Vijay,Subbu.
CURSOR get_opt_unit is SELECT Operating_unit
                       FROM org_organization_definitions
                       WHERE organization_id = nvl(v_org_id,0);


        -- added by sriram -- bug # 2769440

        v_ref_10  gl_interface.reference10%type; -- := 'India Localization Entry for Invoice # '; -- will hold a standard text such as 'India Localization Entry for sales order'
        v_ref_23  gl_interface.reference23%type; -- := 'ja_in_ar_hdr_complete_trg'; -- holds the object name -- 'ja_in_ar_hdr_complete_trg'
        v_ref_24  gl_interface.reference24%type; -- := 'ra_customer_trx_lines_all'; -- holds the table name  -- ' ra_customer_trx_all'
        v_ref_25  gl_interface.reference25%type; -- := 'customer_trx_line_id'; -- holds the column name -- 'customer_trx_id'
        v_ref_26  gl_interface.reference26%type; -- := v_customer_trx_id; -- holds the column value -- eg -- 13645

        -- ends here additions by sriram - Bug # 2769440

VSQLERRM varchar2(250);
vsqlstmt varchar2(20);

lv_ship_status  JAI_CMN_MATCH_RECEIPTS.ship_status%type ;

  /*
  || Start of bug 4566054
  ||Code added by aiyer for the bug 4566054
  ||Get the total cess amount at the invoice level
  ||hence calculate the cess and pass it to the procedure ja_in_Rg_pkg.ja_in_rg_i_entry with source as 'AR'
  */
  CURSOR cur_get_trx_cess_amt (cp_trx_line_id in number) /* added by ssawant for bug 5989740 */
  IS
  SELECT
         sum(jrcttl.func_tax_amount) cess_amount
  FROM
         jai_ar_trx_lines         jrctl   ,
         jai_ar_trx_tax_lines     jrcttl  ,
         jai_cmn_taxes_all        jtc
  WHERE
         jrctl.customer_trx_line_id = jrcttl.link_to_cust_trx_line_id  AND
         jrcttl.tax_id              = jtc.tax_id                       AND
         -- commented by ssawant
         --jrctl.customer_trx_id     = :old.customer_trx_id;
    upper(jtc.tax_type)        IN (jai_constants.tax_type_cvd_edu_cess,jai_constants.tax_type_exc_edu_cess) AND /* added by ssawant for bug 5989740 */
    jrctl.customer_trx_line_id     = cp_trx_line_id; /* added by ssawant for bug 5989740 */

-- This cursor is added by ssawant to account for the total sh cess amount for bug 5989740
  CURSOR cur_get_trx_sh_cess_amt (cp_trx_line_id in number)
  IS
  SELECT
         sum(jrcttl.func_tax_amount) sh_cess_amount
  FROM
         jai_ar_trx_lines   jrctl,
         jai_ar_trx_tax_lines   jrcttl,
         jai_cmn_taxes_all               jtc
  WHERE
         jrctl.customer_trx_line_id = jrcttl.link_to_cust_trx_line_id  AND
         jrcttl.tax_id              = jtc.tax_id                       AND
         upper(jtc.tax_type)        IN (jai_constants.tax_type_sh_cvd_edu_cess,jai_constants.tax_type_sh_exc_edu_cess) AND
   jrctl.customer_trx_line_id     = cp_trx_line_id;

  ln_trx_totcess_amt  JAI_CMN_RG_I_TRXS.CESS_AMT%TYPE;  /* End of bug 4346220 */
  ln_trx_totshcess_amt  JAI_CMN_RG_I_TRXS.SH_CESS_AMT%TYPE; /* added by ssawant for bug 5989740 */


  /* End of bug 4566054 */

  /* Bug 5243532. Added by Lakshmi Gopalsami
   * Defined variable for implementing caching logic.
   */
  l_func_curr_det jai_plsql_cache_pkg.func_curr_details;
  BEGIN
    pv_return_code := jai_constants.successful ;
    /*------------------------------------------------------------------------------------------
FILENAME: JA_IN_AR_HDR_COMPLETE_TRG.sql

CHANGE HISTORY:
S.No  Date        Author and Details
1.      2001/03/30      Jagdish
                        In case of Bond register transactions to calculate the excise_duty,modification
                      done to excise_cal_rec cursor.Search for Jagdish for more modifications

2.      2001/05/04      Vijay,Subbu.
                        Code commented and added for ST Form Tracking

3.      2001/06/22      Anuradha Parthasarathy
                        Code commented and added to improve performance.

4.      2003/03/14      Sriram - Bug # 2846277 -- File Version 615.1
                        Trigger was returning when organization id value is 0 . Organization id
                        value can be 0 in case of setup business group setup is done . Hence making it into
                        a large number (999999) instead of 0.

5.      2003/08/22      Sriram Bug # 3021588 (Bond Register Enhancement) Version 616.2

                           For Multiple Bond Register Enhancement,
                           Instead of using the cursors for fetching the register associated with the invoice type , a call has been made to the procedures
                           of the jai_cmn_bond_register_pkg package. There enhancement has created dependency because of the
                           introduction of 3 new columns in the JAI_OM_OE_BOND_REG_HDRS table and also call to the new package jai_cmn_bond_register_pkg.

                           New Validations for checking the bond expiry date and to check the balance based on the call to the jai_cmn_bond_register_pkg has been added

                           Provision for letter of undertaking has been incorporated. In the case of the letter of undetaking , its also a type of bond register
                           but without validation for the balances.
                           This has been done by checking if the LOU_FLAG is 'Y' in the JAI_OM_OE_BOND_REG_HDRS table for the
                           associated register id , if yes , then validation is only based on bond expiry date .

                           This bug has introduced huge dependency. All future bugs on this object should have this bug as a prereq

6.      2003/10/10     Ssumaith - bug # 3179653 File Version 616.3

                                           When RG23D register is getting hit, instead of populating the excise invoice number in the commercial invoice no field (comm_invoice_no)
                                           trx_number of the invoice is getting populated.This is wrong ans has been corrected in this fix.

7.      2003/11/11     ssumaith - bug # 3138194 File Version 616.4

                       ST forms population functionality has been removed from  this trigger and instead moved to a new
                       concurrent program which does the exclusive job of population of ST form records into the tables.

8.    11-Nov-2003     Aiyer  - Bug #3249375 File Version 617.1
                      References to JA_IN_OE_ST_FORMS_HDR table, which has been obsolete post IN60105D1 patchset, was found
                      in this file in some cursors.
                      As these tables do not exists in the database any more post application the above mentioned patchset
                      hence deleting the cursors.

                     Dependency Due to This Bug:-
                     Can be applied only post application of IN60105D1.

9.   21-Nov-03       Ssumaith Bug # 3273545

                     When only Adhoc Excise tax is attached to the invoice line and matched against a receipt and the invoice
                     completed from the base apps screen is causing error - Divide by Zero ORA-1476.

10.  2004/04/20     ssumaith - bug# 3496577

                    Made code changes such that payment register does not get hit when update_rg_flag is set to No. Only
                    quantity register gets hit.

11.  2005/01/28    ssumaith - bug#4136981

                   IN call to the ja_in_register_txn_entry procedure , passing the customer_Trx_line_id instead of customer_trx_id
                   Because , this procedure gets called from individual line in the JAI_AR_TRX_LINES table
                   when 'COMPLETE' action is done.

12.  08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old
                   DB Entity as required for CASE COMPLAINCE.  Version 116.2

13. 13-Jun-2005   Ramananda for bug#4428980. File Version: 116.2
                  Removal of SQL LITERALs is done

14. 06-Jul-2005   Ramananda for bug#4477004. File Version: 116.4
                  GL Sources and GL Categories got changed. Refer bug for the details

15. 23-Aug-2005 Aiyer - Bug 4566054 (Forward porting for the 11.5 bug 4346220 ),Version 120.1
                  Issue :-
                   Rg does not show correct cess value in case of Shipment transactions.

                  Fix:-
                  Two fields cess_amt and source have been added in JAI_CMN_RG_I_TRXS table.
                  The cess amt and source would be populated from jai_jar_t_aru_t1 (Source -> 'AR' ) and
                  as 'WSH' from jai_om_wsh.plb procedure Shipment.
                  Corresponding changes have been done in the form JAINIRGI.fmb and JAFRMRG1.rdf .
                  For shipment and Ar receivable transaction currently the transaction_id is 33 and in some cases where the jai_cmn_rg_i_trxs.ref_doc_id
                  exactly matches the jai_om_wsh_lines_all.delivery_detail_id and jai_ar_trxs.customer_trx_id the tracking of the source
                  becomes very difficult hence to have a clear demarcation between WSh and AR sources hence the source field has been added.

                  Added 2 new parametes p_cess_amt and p_source to jai_om_rg_pkg.ja_in_rg_i_entry package.
                  This has been populated from this and jai_om_wsh_pkg.process_delivery procedure.

                  A migration script has been provided to migrate the value for cess and source.

                  Dependency due to this bug:-
                  1. Datamodel change in table JAI_CMN_RG_I_TRXS, added the cess_amt and source fields
                  2. Added two new parameters in jai_om_rg_pkg.ja_in_rg_i_entry procedure to insert data into JAI_CMN_RG_I_TRXS table
                  3. Modified the trigger jai_jar_t_aru_t1
                  4. Procedure jai_om_wsh_pkg.process_delivery
                  5. Report JAICMNRG1.rdf
                  6. Created a migration script to populate cess_amt and source for Shipment and Receivable transactions.
                  Both functional and technical dependencies exists


16. 23-Aug-2005  Aiyer - Bug# 4541303 (Forward porting for the 11.5 bug 4538315) 120.1

                  For a manual AR invoice with more than one line, the cess amount was being hit for the whole of the
                  invoice amount for each of the lines.

                  Code changes are done in the package jai_om_rg_pkg as well this trigger.

                  Code changes done in the package include calculating the cess amount for the current customer trx line id.

                  Code changes done in the trigger include sending the customer trx line id when pla is hit . This is inline
                  with the way JAI_CMN_RG_23AC_II_TRXS works.


                  Dependency Due to thus bug:-
                    jai_om_rg.plb (120.4)

 17. 15-Feb-2007  CSahoo - BUG# 5390583, File Version 120.2
                  Forward Porting of 11i BUG 5357400
                  Issue : Excise amount not hitting bond register in functional currency.
                  Fix   : Excise and cess amounts would hit bond register in functional currency.
                          Changes are done in three objects.

                          1. Package jai_om_rg_pkg.  - Added a parameter to the ja_in_register_txn_entry called p_currency_rate
                             It holds the currency conversion rate which would be multiplied by the transaction amts to
                             get the functional amounts.

                          2. Package jai_jar_t.plb - In the call to the ja_in_register_txn_entry procedure
                             added the parameter called p_currency_code.

                          3. Package - jai_ract_trg_pkg - When a change is done in the invoice currency code from the front end
                             the change is being reflected in the JAI_AR_TRXS table.

                  Future Dependency due to this Bug
                  ------------------------
                   YES - A new parameter is added to the procedure  - ja_in_register_txn_entry in the package jai_om_rg_pkg.
                         It has a technical dependency on jai_om_rg_pkg and Package jai_jar_t.plb.
                         It has functional dependency on jai_ract_trg.plb


18. 16-April-2007   ssawant for bug 5989740 ,File version 120.3
                    Forward porting Budget07-08 changes of handling secondary and
              Higher Secondary Education Cess from 11.5( bug no 5907436) to R12 (bug no 5989740).

19. 28-Jun-2007     CSahoo for bug#6155839 , File Version 120.6
                    replaced RG Register Data Entry by jai_constants.je_category_rg_entry

20. 17-Sep-2007        Anujsax for bug#5636544 ,File Version 120.7
                       Forward porting for R11 bug 5629319 into R12 bug 5636544
             Issue : excise_invoice_number need to be updated in the ra_customer_trx_all.ct_reference table.
                       Fix :   1) Stored the excise_invoice_no into a variable
                               2) Submitted the concurrent - JAICMNCP to update the excise invoice number
21. 05-Jan-2009     CSahoo for bug#7685000, File Version 120.7.12010000.2
                    ISSUE: TST1211.XB1 : CONCURRENT RUNS IN ERROR
                    FIX: commented the call to the conc request JAICMNCP : India - Concurrent for
                         updating the excise invoice no.


Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )

----------------------------------------------------------------------------------------------------------------------------------------------------
Current Version       Current Bug    Dependent           Files                                      Version   Author   Date         Remarks
Of File                              On Bug/Patchset    Dependent On
ja_in_ar_hdr_complete_trg.sql
----------------------------------------------------------------------------------------------------------------------------------------------------
616.1                  3021588       IN60104D1 +                                                              ssumaith  22/08/2003   Bond Register Enhancement
                                     2801751   +
                                     2769440

617.1                  3249375       IN60105D1                                                                Aiyer     11/Nov/2003  Can be applied only after IN60105D1 patchset
                                                                                                                                      has been applied.
12.0              4566054                               jai_om_rg.pls                                      120.3   Aiyer     24-Aug-2005
                                                        jai_om_rg.plb                                      120.4
                                                        jai_om_wsh.plb (jai_om_wsh_pkg.process_delivery)   120.4
                                                        JAINIRGI.fmb                                       120.2
                                                        jain14.odf                                         120.3
                                                        jain14reg.ldt                                      120.3
                                                        New migration script to port data into new tables  120.0
                                                        JAICMNRG1.rdf                                      120.3
                                                        jai_jai_t.sql (trigger jai_jar_t_aru_t1)           120.1
17/5/2007 bduvarag for the bug#4601570, File version 120.4
    Forward porting the changes done in the 11i bug#4474270

----------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------*/
  v_item_class          := 'N'; --Ramananda for File.Sql.35
  v_customer_trx_id     := pr_old.customer_trx_id; --Ramananda for File.Sql.35
  v_last_update_date    := pr_new.last_update_date; --Ramananda for File.Sql.35
  v_last_updated_by     := pr_new.last_updated_by; --Ramananda for File.Sql.35
  v_creation_date       := SYSDATE; --Ramananda for File.Sql.35
  v_created_by          := pr_new.created_by;--Ramananda for File.Sql.35
  v_last_update_login   := pr_new.last_update_login; --Ramananda for File.Sql.35
  v_set_of_books_id     := pr_new.set_of_books_id; --Ramananda for File.Sql.35
  v_currency_code       := pr_new.invoice_currency_code; --Ramananda for File.Sql.35
  v_conv_date           := NVL(pr_new.exchange_date, pr_new.creation_date); --Ramananda for File.Sql.35
  v_conv_type_code      := pr_new.Exchange_Rate_Type; --Ramananda for File.Sql.35
  v_conv_rate           := pr_new.Exchange_rate; --Ramananda for File.Sql.35
  --2001/05/04    Vijay,Subbu.
  v_trx_number          := pr_new.Trx_Number; --Ramananda for File.Sql.35
  v_source_name         := 'Receivables India'; --Ramananda for File.Sql.35
  v_category_name       := jai_constants.je_category_rg_entry ; -- modified by csahoo for bug#6155839 --'RG Register Data Entry'; --Ramananda for File.Sql.35
  v_ref_10              := 'India Localization Entry for Invoice # '; -- will hold a standard text such as 'India Localization Entry for sales order'
  v_ref_23              := 'ja_in_ar_hdr_complete_trg'; -- holds the object name -- 'ja_in_ar_hdr_complete_trg'
  v_ref_24              := 'ra_customer_trx_lines_all'; -- holds the table name  -- ' ra_customer_trx_all'
  v_ref_25              := 'customer_trx_line_id'; -- holds the column name -- 'customer_trx_id'
  v_ref_26              := v_customer_trx_id; -- holds the column value -- eg -- 13645

  OPEN  complete_info_cur;
  FETCH complete_info_cur INTO v_ship_cust_id, v_ship_to_site_use_id,
                  v_cust_trx_type_id,
                v_trx_date,v_sold_cust_id,v_batch_source_id,
            v_bill_to_customer_id, v_bill_to_site_use_id; --2001/05/04  Vijay,Subbu.
  CLOSE complete_info_cur;
  IF v_trx_date IS NULL THEN
    RETURN;
  END IF;

  OPEN   org_loc_cur;
  FETCH  org_loc_cur INTO v_org_id, v_loc_id, v_reg_type, v_rg_flag,
                v_complete_flag ;
  CLOSE  org_loc_cur;
  IF NVL(v_org_id,999999) = 999999 THEN     -- made 0 to 999999 because in case of setup business group setup , inventory organization value is 0
                                            -- which was causing code to return .- bug # 2846277
    OPEN  organization_cur;
    FETCH organization_cur INTO v_org_id, v_loc_id;
    CLOSE organization_cur;
  END IF;
  IF NVL(v_org_id,999999) = 999999 THEN    -- made 0 to 999999 because in case of setup business group setup , inventory organization value is 0
                                           -- which was causing code to return .- bug # 2846277
    RETURN;
  END IF;



  v_ref_10  := v_ref_10 || v_trx_number ;
  vsqlstmt := '1';
-----Once Complete Button is Pressed Following code WILL tell you what will happ
--en at what stage
IF pr_new.ONCE_COMPLETED_FLAG <> pr_old.ONCE_COMPLETED_FLAG THEN
  IF v_set_of_books_id IS NULL
  THEN
    /* Bug 5243532. Added by Lakshmi Gopalsami
     * Removed the cursor set_of_books_cur and implemented using caching logic.
     */
     l_func_curr_det := jai_plsql_cache_pkg.return_sob_curr
                            (p_org_id  => v_org_id );
     v_set_of_books_id := l_func_curr_det.ledger_id;
  END IF;
  v_converted_rate := jai_cmn_utils_pkg.currency_conversion (v_set_of_books_id ,v_currency_code ,
                                      v_conv_date ,v_conv_type_code, v_conv_rate);

vsqlstmt := '2';
/*

  OPEN   register_code_cur(v_org_id, v_loc_id,v_batch_source_id);
  FETCH  register_code_cur INTO v_reg_code;
  CLOSE  register_code_cur;
*/

-- above code commented by sriram - bug # 3021588 and instead making a call to the jai_cmn_bond_register_pkg Package instead.

jai_cmn_bond_register_pkg.GET_REGISTER_ID(v_org_id,
                                    v_loc_id,
                                    v_batch_source_id,
                                    'N',
                                    v_register_id,
                                    v_reg_code
                                   );
vsqlstmt := '3';
  OPEN   fin_year_cur(v_org_id);
  FETCH  fin_year_cur INTO v_fin_year;
  CLOSE  fin_year_cur;
  OPEN   REG_BALANCE_CUR(v_org_id, v_loc_id);
  FETCH  REG_BALANCE_CUR INTO v_rg23a_bal,v_rg23c_bal,v_pla_bal;
  CLOSE  REG_BALANCE_CUR;
vsqlstmt := '4';
--2001/05/04    Vijay,Subbu.
  OPEN get_opt_unit;
  FETCH get_opt_unit INTO v_opt_unit;
  CLOSE get_opt_unit;
--2001/05/04    Vijay,Subbu.
vsqlstmt := '5';
FOR l_rec in line_cur LOOP

 v_ref_26  := l_rec.customer_trx_line_id; -- sriram - bug # 2967440

 OPEN  item_class_cur(v_org_id,l_rec.inventory_item_id);
 FETCH  item_class_cur INTO v_item_class , v_excise_flag,V_item_trading_flag;
 CLOSE  item_class_cur;

/* Changed by Sjha on 25/10/99 */
vsqlstmt := '5';
 IF NVL(v_excise_flag,'N') = 'Y' THEN
   FOR excise_cal_rec in excise_cal_cur(l_rec.line_id, l_rec.inventory_item_id,
                                        v_org_id)
  LOOP
     IF v_reg_code in ('BOND_REG') THEN
                         --  2001/03/30 Jagdish
        vsqlstmt := '6';
        IF excise_cal_rec.t_type IN ('Excise') THEN
                v_basic_ed := NVL(v_basic_ed,0) +
                NVL(excise_cal_rec.BASE_TAX_AMT * (excise_cal_rec.t_rate)/100 ,0);
                v_tax_rate := NVL(v_tax_rate,0) + NVL(excise_cal_rec.t_rate,0);
                vsqlstmt := '7';
           IF NVL(excise_cal_rec.t_rate,0) > 0 THEN
                v_counter  := v_counter + 1;
           END IF;
        ELSIF excise_cal_rec.t_type IN ('Addl. Excise') THEN
            vsqlstmt := '8';
                v_additional_ed := NVL(v_additional_ed,0) +
                NVL(excise_cal_rec.BASE_TAX_AMT * (excise_cal_rec.t_rate)/100 ,0);
        ELSIF excise_cal_rec.t_type IN ('Other Excise') THEN
            vsqlstmt := '9';
                v_other_ed := NVL(v_other_ed,0) +
                NVL(excise_cal_rec.BASE_TAX_AMT * (excise_cal_rec.t_rate)/100 ,0);
        END IF;
   ELSE
           IF excise_cal_rec.t_type IN ('Excise') THEN
                vsqlstmt := '10';
                v_basic_ed := NVL(v_basic_ed,0) + NVL(excise_cal_rec.func_amt,0);
                v_tax_rate := NVL(v_tax_rate,0) + NVL(excise_cal_rec.t_rate,0);
             IF NVL(excise_cal_rec.t_rate,0) > 0 THEN
             vsqlstmt := '11';
                v_counter  := v_counter + 1;
             END IF;
           ELSIF excise_cal_rec.t_type IN ('Addl. Excise') THEN
            vsqlstmt := '12';
                v_additional_ed := NVL(v_additional_ed,0) +NVL(excise_cal_rec.func_amt,0);
           ELSIF excise_cal_rec.t_type IN ('Other Excise') THEN
            vsqlstmt := '13';
                v_other_ed := NVL(v_other_ed,0) + NVL(excise_cal_rec.func_amt,0);
           END IF;
   END IF;
---ghankot cmmented on 25-oct-99
---ghankot commented on 25-oct-99
--     END IF;
   END LOOP;
   IF NVL(v_counter,0) = 0 THEN
     v_counter := 1;
   END IF;
   vsqlstmt := '14';
   v_average_duty := NVL(v_tax_rate,0)/v_counter;
   vsqlstmt := '15';
   v_average_duty := TRUNC(v_average_duty,2);
   v_tax_amount := NVL(v_basic_ed,0) + NVL(v_additional_ed,0) +
                        NVL(v_other_ed,0);
    IF v_item_class IN ('RMIN','RMEX','CGEX','CGIN','FGIN','FGEX','CCIN','CCEX')
  THEN
   vsqlstmt := '16';

v_assessable_value := NVL(v_converted_rate,0) * nvl(l_rec.assessable_value,0);
    IF v_reg_code in ('DOMESTIC_EXCISE','EXPORT_EXCISE',
                        'DOMESTIC_WITHOUT_EXCISE', 'BOND_REG') THEN
                        vsqlstmt := '17';
      /*
      || Code added for the bug 4566054
      || Initialize the ln_trx_totcess_amt variable to null;
      */

      ln_trx_totcess_amt := null;
      ln_trx_totshcess_amt := null; /* added by ssawant for bug 5989740 */

      /*
      || Start of bug 4566054
      ||Code added by aiyer for the bug 4566054
      ||The cess amount is also being maintained in jai_cmn_rg_i_trxs table at a delivery_detail_level
      ||hence calculate the cess and pass it to the procedure jai_om_rg_pkg.ja_in_rg_i_entry with source as 'WSH'
      */

      OPEN  cur_get_trx_cess_amt(l_rec.line_id) ;
      FETCH cur_get_trx_cess_amt INTO ln_trx_totcess_amt;
      CLOSE cur_get_trx_cess_amt ;
      /* End of bug 4566054 */

  /* added by ssawant for bug 5989740 */
      OPEN  cur_get_trx_sh_cess_amt(l_rec.line_id) ;
      FETCH cur_get_trx_sh_cess_amt INTO ln_trx_totshcess_amt;
      CLOSE cur_get_trx_sh_cess_amt ;



     IF v_item_class IN ('FGIN','FGEX','CCIN','CCEX') THEN
       vsqlstmt := '18';
       IF l_rec.payment_register = 'RG23A' THEN
         v_reg_type := 'A';
         v_payment_register := 'RG23A';
       ELSIF l_rec.payment_register = 'RG23C' THEN
         v_reg_type := 'C';
         v_payment_register := 'RG23A';
       ELSIF l_rec.payment_register = 'PLA' THEN
         v_payment_register := 'PLA';
       END IF;
       vsqlstmt := '19';
       jai_om_rg_pkg.ja_in_rg_I_entry(

                                     p_fin_year               =>     v_fin_year                   ,
                                     p_org_id                 =>     v_org_id                     ,
                                     p_location_id            =>     v_loc_id                     ,
                                     p_inventory_item_id      =>     l_rec.inventory_item_id      ,
                                     p_transaction_id         =>     33                           ,
                                     p_transaction_date       =>     SYSDATE                      ,
                                     p_transaction_type       =>     'I'                          ,
                                     p_header_id              =>     v_customer_trx_id            ,
                                     p_excise_quantity        =>     l_rec.quantity_invoiced      ,
                                     p_excise_amount          =>     v_tax_amount                 ,
                                     p_uom_code               =>     l_rec.unit_code              ,
                                     p_excise_invoice_no      =>     l_rec.excise_invoice_no      ,
                                     p_excise_invoice_date    =>     l_rec.excise_invoice_date    ,
                                     p_payment_register       =>     v_payment_register           ,
                                     p_basic_ed               =>     v_basic_ed                   ,
                                     p_additional_ed          =>     v_additional_ed              ,
                                     p_other_ed               =>     v_other_ed                   ,
                                     p_excise_duty_rate       =>     v_average_duty               ,
                                     p_customer_id            =>     v_ship_cust_id               ,
                                     p_customer_site_id       =>     v_ship_to_site_use_id        ,
                                     p_register_code          =>     v_reg_code                   ,
                                     p_creation_date          =>     v_creation_date              ,
                                     p_created_by             =>     v_created_by                 ,
                                     p_last_update_date       =>     v_last_update_date           ,
                                     p_last_updated_by        =>     v_last_updated_by            ,
                                     p_last_update_login      =>     v_last_update_login          ,
                                     p_assessable_value       =>     v_assessable_value           ,
                                     p_cess_amt               =>     ln_trx_totcess_amt           , /*Parameters p_cess_amt and p_source added by aiyer for the bug 4566054 */
             p_sh_cess_amt            =>     ln_trx_totshcess_amt         ,  /* added by ssawant for bug 5989740 */
                                     p_source                 =>     jai_constants.source_ar
                                    );


              vsqlstmt := '20';
       SELECT JAI_CMN_RG_I_TRXS_S.CURRVAL INTO v_part_i_register_id  from dual;
     ELSIF v_item_class IN ('CGEX','CGIN') THEN
       v_reg_type := 'C';
     ELSIF v_item_class IN ('RMIN','RMEX') THEN
       v_reg_type := 'A';
     END IF;
     IF v_item_class IN ('RMIN','RMEX','CGIN','CGEX') THEN
       vsqlstmt := '21';
       jai_om_rg_pkg.ja_in_rg23_part_I_entry(v_reg_type, v_fin_year, v_org_id,
                                        v_loc_id,
                l_rec.inventory_item_id, 33, SYSDATE, 'I',
                l_rec.quantity_invoiced, l_rec.unit_code,  l_rec.excise_invoice_no,
                l_rec.excise_invoice_date, v_basic_ed, v_additional_ed,
                v_other_ed, v_ship_cust_id, v_ship_to_site_use_id,
                v_customer_trx_id, SYSDATE, v_reg_code,
                v_creation_date, v_created_by,v_last_update_date,
                v_last_updated_by, v_last_update_login );
                vsqlstmt := '22';
         SELECT JAI_CMN_RG_23AC_I_TRXS_S.CURRVAL INTO v_part_i_register_id from dual;
     END IF;
    END IF;
    IF v_reg_code in ('DOMESTIC_EXCISE','EXPORT_EXCISE') THEN



     -- to code such that payment register does not get hit when update_rg_flag is set to No

     if pr_new.update_rg_flag = 'Y' or pr_old.update_rg_flag = 'Y' then  -- 3496577


      IF l_rec.payment_register IN( 'RG23A','RG23C') THEN
        IF l_rec.payment_register = 'RG23A' THEN
          v_reg_type := 'A';
        ELSIF l_rec.payment_register = 'RG23C' THEN
          v_reg_type := 'C';
        END IF;
        IF NVL(l_rec.EXCISE_EXEMPT_TYPE,'@@@') IN
                    ('CT2', 'EXCISE_EXEMPT_CERT' )
                   AND v_item_class NOT IN ('OTIN', 'OTEX')
        THEN
            v_reg_type := 'A';
            OPEN for_modvat_percentage(v_org_id, v_loc_id);
            FETCH   for_modvat_percentage INTO v_modvat_tax_rate;
            CLOSE for_modvat_percentage;
            v_basic_ed := ROUND((l_rec.quantity_invoiced * l_rec.unit_selling_price
                                                * v_modvat_tax_rate)/100);
            v_remarks := 'Against Modvat Recovery'||'-'||l_rec.EXCISE_EXEMPT_TYPE;
        ELSIF NVL(l_rec.EXCISE_EXEMPT_TYPE,'@@@')  IN
                ('CT2_OTH', 'EXCISE_EXEMPT_CERT_OTH')
                 AND v_item_class NOT IN ('OTIN', 'OTEX')
        THEN
            OPEN  for_modvat_tax_rate(l_rec.line_id);
            FETCH for_modvat_tax_rate INTO v_modvat_tax_rate, v_rounding_factor;
            CLOSE for_modvat_tax_rate;
            v_basic_ed := (l_rec.quantity_invoiced * l_rec.unit_selling_price
                                * v_modvat_tax_rate)/100;
            IF v_rounding_factor IS NOT NULL THEN
                v_basic_ed := ROUND(v_basic_ed, v_rounding_factor);
            ELSE
                v_basic_ed := ROUND(v_basic_ed);
            END IF;
            v_remarks := 'Against Modvat Recovery'||'-'||l_rec.EXCISE_EXEMPT_TYPE;
        END IF;
     --2001/03/26 Manohar Mishra , added new parameter V_REG_CODE as below.
        vsqlstmt := '23';
        jai_om_rg_pkg.ja_in_rg23_part_II_entry(v_reg_code,v_reg_type, v_fin_year, v_org_id,
                                                v_loc_id,
                l_rec.inventory_item_id, 33, SYSDATE, v_part_i_register_id,
                l_rec.excise_invoice_no, l_rec.excise_invoice_date ,
            round(v_basic_ed), -- Vijay 2001/10/19
                round(v_additional_ed), -- Vijay 2001/10/19
            round(v_other_ed), -- Vijay 2001/10/19
            v_ship_cust_id, v_ship_to_site_use_id,
                v_source_name, v_category_name,
                v_creation_date, v_created_by,v_last_update_date,
                v_last_updated_by, v_last_update_login, l_rec.line_id,
                l_rec.excise_exempt_type, v_remarks ,
                v_ref_10,
                v_ref_23,
                v_ref_24,
                v_ref_25,
                v_ref_26
                );
                vsqlstmt := '24';
     ELSIF l_rec.payment_register IN ('PLA') THEN
       vsqlstmt := '25';
       jai_om_rg_pkg.ja_in_pla_entry(v_org_id,
                                    v_loc_id,
                                    l_rec.inventory_item_id,
                                    v_fin_year,
                                    33,
                                    l_rec.line_id, -- modified by, aiyer for Bug #4541303
                                    SYSDATE,
                                    l_rec.excise_invoice_no ,
                                    l_rec.excise_invoice_date ,
                                    round(v_basic_ed), -- Vijay 2001/10/19
                                    round(v_additional_ed),-- Vijay 2001/10/19
                                    round(v_other_ed), -- Vijay 2001/10/19
                                    v_ship_cust_id,
                                    v_ship_to_site_use_id,
                                    v_source_name,
                                    v_category_name,
                                    v_creation_date,
                                    v_created_by,
                                    v_last_update_date,
                                    v_last_updated_by,
                                    v_last_update_login ,
                                    v_ref_10,
                                    v_ref_23,
                                    v_ref_24,
                                    v_ref_25,
                                    v_ref_26
                                    );
                                    vsqlstmt := '26';
     END IF;
     IF v_item_class IN ('FGIN','FGEX','CCIN','CCEX') THEN
       SELECT JAI_CMN_RG_I_TRXS_S.CURRVAL INTO v_rg23_part_i_no  from dual;
       IF l_rec.payment_register IN( 'RG23A','RG23C') THEN
         SELECT JAI_CMN_RG_23AC_II_TRXS_S.CURRVAL INTO v_rg23_part_ii_no from dual;
         UPDATE  JAI_CMN_RG_I_TRXS
            SET  register_id_part_ii = v_rg23_part_ii_no,
                 CHARGE_ACCOUNT_ID = (SELECT CHARGE_ACCOUNT_ID FROM JAI_CMN_RG_23AC_II_TRXS
                                      WHERE  register_id = v_rg23_part_ii_no)
          WHERE  register_id = v_rg23_part_i_no;
       ELSIF l_rec.payment_register IN( 'PLA') THEN
         SELECT  JAI_CMN_RG_PLA_TRXS_S1.CURRVAL INTO v_pla_register_no from dual;
         UPDATE  JAI_CMN_RG_I_TRXS
            SET  register_id_part_ii = v_pla_register_no,
                 CHARGE_ACCOUNT_ID = (SELECT CHARGE_ACCOUNT_ID FROM JAI_CMN_RG_PLA_TRXS
                                      WHERE  register_id = v_pla_register_no)
          WHERE  register_id = v_rg23_part_i_no;
       END IF;
     ELSIF v_item_class IN ('RMIN','RMEX','CGIN','CGEX') THEN
       SELECT JAI_CMN_RG_23AC_I_TRXS_S.CURRVAL INTO v_rg23_part_i_no  from dual;
       IF l_rec.payment_register IN( 'RG23A','RG23C') THEN
         SELECT JAI_CMN_RG_23AC_II_TRXS_S.CURRVAL INTO v_rg23_part_ii_no from dual;
         UPDATE  JAI_CMN_RG_23AC_I_TRXS
            SET  REGISTER_ID_PART_II = v_rg23_part_ii_no,
                 CHARGE_ACCOUNT_ID = (SELECT CHARGE_ACCOUNT_ID FROM JAI_CMN_RG_23AC_II_TRXS
                                      WHERE  register_id = v_rg23_part_ii_no)
          WHERE  register_id = v_rg23_part_i_no;
       ELSIF l_rec.payment_register IN( 'PLA') THEN
         SELECT  JAI_CMN_RG_PLA_TRXS_S1.CURRVAL INTO v_pla_register_no from dual;
         UPDATE  JAI_CMN_RG_23AC_I_TRXS
            SET  REGISTER_ID_PART_II = v_pla_register_no,
                 CHARGE_ACCOUNT_ID = (SELECT CHARGE_ACCOUNT_ID FROM JAI_CMN_RG_PLA_TRXS
                                      WHERE  register_id = v_pla_register_no)
          WHERE  register_id = v_rg23_part_i_no;
       END IF;
     END IF;
    END IF;

   end if; -- 3496577
     IF v_reg_code IN ('BOND_REG','23D_EXPORT_WITHOUT_EXCISE') THEN
       vsqlstmt := '27';
        jai_om_rg_pkg.ja_in_register_txn_entry(
                                              v_org_id,
                                              v_loc_id,
                                              l_rec.excise_invoice_no,
                                              'BOND SALES',
                                              'N',
                                              l_rec.line_id,--v_customer_trx_id,
                                              round(v_tax_amount * NVL(pr_new.exchange_rate ,1),2) , /* added by CSahoo - bug# 5390583 */
                                              v_reg_code,
                                              v_creation_date,
                                              v_created_by,
                                              v_last_update_date,
                                              v_last_updated_by,
                                              v_last_update_login ,
                                              pr_new.Batch_source_id,
                                              NVL(pr_new.exchange_Rate,1) /* added by CSahoo - bug# 5390583 */
                                             );
                                             vsqlstmt := '28';
     END IF;
     IF v_reg_code IN('23D_EXPORT_WITHOUT_EXCISE','23D_EXPORT_EXCISE',
                        '23D_DOMESTIC_EXCISE','23D_DOM_WITHOUT_EXCISE')
      and
        nvl(pr_new.update_rg23d_flag,'N') = 'Y'  /*bduvarag for the bug4601570*/
      then
     if nvl(v_item_trading_flag,'N') = 'Y' then
       select sum(func_tax_amount) into v_duty_amount
       from JAI_AR_TRX_TAX_LINES
       where link_to_cust_trx_line_id=l_rec.customer_trx_line_id;
     FOR match_rec IN matched_receipt_cur(l_rec.customer_trx_line_id)
     LOOP
       FOR rate_rec IN tax_rate_cur(l_rec.customer_trx_line_id,
                                        match_rec.receipt_id)
       LOOP
         IF nvl(rate_rec.tax_rate,0) > 0 THEN
           v_tax_rate_counter := v_tax_rate_counter + 1;
           v_match_tax_rate := nvl(v_match_tax_rate,0)
                                        + nvl(rate_rec.tax_rate,0);
         END IF;
         /*
         and v_tax_rate_counter > 0 added by sriram for patchset bug
         because it was causing a divide by zero exception. Bug # 3273545

         The variable v_match_tax_rate is not used anywhere further below the
         following if condition.However, I have not removed the code snippet
         to be on the safer side.
         */
         IF v_counter > 0 and v_tax_rate_counter > 0  THEN
           v_match_tax_rate := v_match_tax_rate/v_tax_rate_counter;
         END IF;
       END LOOP;

       Select JAI_CMN_RG_23D_TRXS_S.NEXTVAL into v_register_id From   Dual;
       IF match_rec.transaction_type = 'R'
       THEN
         v_rg23d_receipt_id := match_rec.receipt_id;
       ELSIF match_rec.transaction_type = 'CR'
       THEN
         v_oth_receipt_id := match_rec.receipt_id;
       END IF;
       vsqlstmt := '29';
       jai_om_rg_pkg.ja_in_rg23d_entry(
                                 v_register_id,
         v_org_id, v_loc_id,
                                 v_fin_year, 'I', l_rec.inventory_item_id,
                                 l_rec.customer_trx_line_id, l_rec.unit_code, l_rec.unit_code,
                                 v_ship_cust_id, v_sold_cust_id, v_ship_to_site_use_id,
                                 match_rec.quantity_applied,
                                 v_reg_code,  match_rec.rate_per_unit,
                                 match_rec.excise_duty_rate,v_tax_amount ,null,
                                 v_source_name, v_category_name, null,null,
                                 v_creation_date,v_created_by,v_last_update_date,
                                 v_last_update_login,
                                 v_last_updated_by, null, null, null,
                                 l_rec.excise_invoice_no,--v_trx_number Bug # 3179653 passing excise invoice no instead of trx number,
                                 v_trx_date,
                                 v_ref_10,v_ref_23,v_ref_24,v_ref_25,v_ref_26);
                                 vsqlstmt := '30';

        jai_cmn_rg_23d_trxs_pkg.upd_receipt_qty_matched(match_rec.receipt_id,match_rec.quantity_applied,
                                        match_rec.qty_to_adjust
                                        );

   lv_ship_status  := 'CLOSED' ;

    UPDATE JAI_CMN_MATCH_RECEIPTS
    set ship_status = lv_ship_status --'CLOSED'  /* Modified by Ramananda for removal of SQL LITERALs */
    where ref_line_id = l_rec.customer_trx_line_id;
     END LOOP;
    END IF;
    END IF;
   ELSE
     null;
   END IF;
   v_item_class := '';
   v_tax_amount := 0;
   v_basic_ed   := 0;
   v_additional_ed := 0;
   v_other_ed   := 0;
   v_average_duty := 0;
   v_counter    := 0;
   v_tax_rate   := 0;
   v_reg_type   := '';
   END IF;

   --Added the below by Anujsax for Bug#5636544
 IF l_rec.excise_invoice_no IS NOT NULL AND lv_excise_invoice_no IS NULL THEN
 lv_excise_invoice_no := l_rec.excise_invoice_no;
 --Ended by Anujsax for Bug#5636544
 END IF;

END LOOP;
  DELETE JAI_AR_TRX_INS_HDRS_T
  WHERE  CUSTOMER_TRX_ID = v_customer_trx_id;
  --Start addition by Anujsax for Bug#5636544
/* commented this code for bug#7685000, csahoo
IF lv_excise_invoice_no IS NOT NULL THEN
result := fnd_request.set_mode(TRUE);
req_id := fnd_request.submit_request( 'JA',
                 'JAICMNCP',
                'India - Concurrent for updating the excise invoice no',
          SYSDATE,
          FALSE,
          'UPDATE EXCISE INVOICE NO',
          NULL,
          'Y',
          v_customer_trx_id,
          lv_excise_invoice_no);
  END IF;
--End Addition by Anujsax for Bug#5636544
bug#7685000, csahoo, end*/

END IF;

/*EXCEPTION
WHEN OTHERS THEN
VSQLERRM := SUBSTR(SQLERRM,1,240);
         INSERT INTO JAI_CMN_ERRORS_T
         (
         APPLICATION_SOURCE,
         ERROR_MESSAGE ,
         ADDITIONAL_ERROR_MESG,
         CREATION_DATE,
         CREATED_BY
         )
         VALUES
         ('JA_IN_AR_HDR_COMPLETE_TRG',
         'EXCEPTION OCCURED AT SQLSTMT' || vsqlstmt ,
         VSQLERRM,
         SYSDATE,
         USER
         );
*/
   /* Added an exception block by Ramananda for bug#4570303 */
 EXCEPTION
   WHEN OTHERS THEN
     Pv_return_code     :=  jai_constants.unexpected_error;
     Pv_return_message  := 'Encountered an error in JAI_JAR_TRXS_TRIGGER_PKG.ARU_T1 '  || substr(sqlerrm,1,1900);

  END ARU_T1 ;

END JAI_JAR_TRXS_TRIGGER_PKG ;

/
