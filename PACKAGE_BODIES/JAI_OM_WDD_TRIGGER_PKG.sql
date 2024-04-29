--------------------------------------------------------
--  DDL for Package Body JAI_OM_WDD_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_OM_WDD_TRIGGER_PKG" AS
/* $Header: jai_om_wdd_t.plb 120.9.12010000.14 2010/06/07 08:03:28 jijili ship $ */

/*  REM +======================================================================+
  REM NAME          ARD_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_OM_WDD_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_OM_WDD_ARD_T3
  REM
  REM +======================================================================+
*/
  PROCEDURE ARD_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
   v_DELIVERY_DETAIL_ID    Number; --File.Sql.35 Cbabu   := pr_old.DELIVERY_DETAIL_ID;
  x                       Number; --File.Sql.35 Cbabu   := 0;

  Cursor del_count IS
  Select 1
  From   JAI_OM_WSH_LINES_ALL
  Where  delivery_detail_id = v_delivery_detail_id;


  BEGIN
    pv_return_code := jai_constants.successful ;

    v_DELIVERY_DETAIL_ID      := pr_old.DELIVERY_DETAIL_ID;
  x                     := 0;

/*------------------------------------------------------------------------------------------
 FILENAME: JA_IN_WSH_DLRY_DTLS_AD_TRG.sql

 CHANGE HISTORY:
S.No      Date          Author and Details
1.  2001/07/12          Anuradha Parthasarathy
                        Code added to ensure that the trigger does not fire
                        For Non Indian OU.

2.  29-nov-2004       ssumaith - bug# 4037690  - File version 115.1
                        Check whether india localization is being used was done using a INR check in every trigger.
                        This check has now been moved into a new package and calls made to this package from this trigger
                        If the function jai_cmn_utils_pkg.check_jai_exists returns true it means INR is the set of books currency ,
                        Hence if this function returns FALSE , control should return.

3.  08-Jun-2005      This Object is Modified to refer to New DB Entity names in place of Old
                     DB Entity as required for CASE COMPLAINCE.  Version 116.1

4. 13-Jun-2005    File Version: 116.2
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done


   02/11/2006      for Bug 5228046 by SACSETHI, File version 120.2
                   Forward porting the change in 11i bug 5365523 (Additional CVD Enhancement).
                   This bug has datamodel and spec changes.



Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Current Version    Current Bug    Dependent           Files                Version   Author   Date          Remarks
Of File                           On Bug/Patchset    Dependent On

ja_in_wsh_dlry_dtls_ad_trg.sql
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
115.1              4037690        IN60105D2          ja_in_util_pkg_s.sql  115.0   Ssumaith 29-Nov-2004  Call to this function.
                                                     ja_in_util_pkg_s.sql  115.0   Ssumaith

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
--------------------------------------------------------------------------------------------*/

  /* following code added by ssumaith - bug# 4037690 */
 -- if pr_new.org_id is not null then
 --   If jai_cmn_utils_pkg.check_jai_exists( P_CALLING_OBJECT => 'JA_IN_WSH_DLRY_DTLS_AD_TRG', P_ORG_ID => pr_new.org_id) = false then
 --     return;
 --   end if;
 -- end if;

  /* ends here additions by ssumaith */

  Open  del_count;
  Fetch del_count into x;
  Close del_count;

  If nvl(x,0) <> 1 then
    Return;
  Else
        DELETE JAI_OM_WSH_LINES_ALL
        WHERE delivery_detail_id  = v_DELIVERY_DETAIL_ID;

    DELETE JAI_OM_WSH_LINE_TAXES
    WHERE delivery_detail_id   = v_DELIVERY_DETAIL_ID;
  End If;

  END ARD_T1 ;

  /*
REM +======================================================================+
  REM NAME          ARU_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_OM_WDD_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_OM_WDD_ARU_T1
  REM
  REM +======================================================================+
*/
  PROCEDURE ARU_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
  BEGIN
    pv_return_code := jai_constants.successful ;
/*------------------------------------------------------------------------------------------
 FILENAME: ja_in_receipts_match_trg.sql

 CHANGE HISTORY:
S.No      Date          Author and Details
1.        2002/03/11    Vijay
                        Trigger written to delete data from tables
                        JAI_CMN_MATCH_RECEIPTS, JAI_CMN_MATCH_TAXES.
                        After Match Receipt is done, when back order is done,
                        this trigger enables to match again.

2.        29/11/2005    Aparajita for bug#4036241. Version#115.1

                        Introduced the call to centralized packaged procedure,
                        jai_cmn_utils_pkg.check_jai_exists to check if localization has been installed.

3.        08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old
                        DB Entity as required for CASE COMPLAINCE.  Version 116.1

4.        13-Jun-2005   Ramananda for bug#4428980. File Version: 116.2
                        Removal of SQL LITERALs is done
Dependency:
----------

Sl No. Bug        Dependent on
                  Bug/Patch set    Details
-------------------------------------------------------------------------------------------------
1      4036241    4033992          Call to  jai_cmn_utils_pkg.check_jai_exists, whcih was created thru bug
                                   4033992.
                                   ja_in_util_pkg_s.sql 115.0
                                   ja_in_util_pkg_b.sql 115.0

--------------------------------------------------------------------------------------------------*/
--if
--  jai_cmn_utils_pkg.check_jai_exists (p_calling_object => 'JA_IN_WSH_BACKORDER_AU_TRG', p_inventory_orgn_id =>  pr_new.organization_id)
--  =
--  FALSE
--then
  /* India Localization funtionality is not required */
--  return;
--end if;


  Delete from JAI_CMN_MATCH_RECEIPTS
  Where ref_line_id = pr_new.delivery_detail_id;

  Delete from JAI_CMN_MATCH_TAXES
  Where ref_line_id = pr_new.delivery_detail_id;
  END ARU_T1 ;

  /*
  REM +======================================================================+
  REM NAME          ARU_T2
  REM
  REM DESCRIPTION   Called from trigger JAI_OM_WDD_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_OM_WDD_ARU_T2
  REM
  REM +======================================================================+
  */
PROCEDURE ARU_T2 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
  v_inventory_item_id            NUMBER; --File.Sql.35 Cbabu           :=pr_new.inventory_item_id        ;
v_organization_id              NUMBER ; --File.Sql.35 Cbabu          :=pr_new.organization_id          ;
v_subinventory                 VARCHAR2(10); --File.Sql.35 Cbabu     :=pr_new.subinventory             ;
v_delivery_detail_id           NUMBER; --File.Sql.35 Cbabu           :=pr_new.delivery_detail_id       ;
v_source_header_type_id        NUMBER ; --File.Sql.35 Cbabu          :=pr_new.source_header_type_id    ;
v_shipped_quantity             NUMBER ; --File.Sql.35 Cbabu          := nvl(pr_new.shipped_quantity,0) ;
v_matched_qty                  NUMBER ; --File.Sql.35 Cbabu          := 0                            ;
v_trading_flag                 VARCHAR2(1)                                     ;
--added for bug#6327274, start
v_bonded                       JAI_INV_SUBINV_DTLS.bonded%TYPE;
lv_allow_shipment_wo_excise    VARCHAR2(1);
-- bug#6327274, end
v_trad_register_code           VARCHAR2(30)                                    ;
v_item_trading_flag            VARCHAR2(1)                                     ;
v_location_id                  NUMBER                                          ;
v_exe_flag                     VARCHAR2(150)                                   ;
v_mod_flag                     VARCHAR2(150)                                   ;
v_container_item_flag          mtl_system_items.container_item_flag%type       ;
lv_inventory_item_flag         mtl_system_items.inventory_item_flag%type       ;/*added by csahoo for bug#8500697*/

 /*
  ||Added by bgowrava for the forward porting bug 5631784 (TCS enhancement)
  */

  /* variables used in debug package */
  lv_object_name        jai_cmn_debug_contexts.LOG_CONTEXT%TYPE ;
  lv_member_name        jai_cmn_debug_contexts.LOG_CONTEXT%TYPE;
  lv_context            jai_cmn_debug_contexts.LOG_CONTEXT%TYPE;
  ln_reg_id             NUMBER                                 ;
  le_error              EXCEPTION                              ;

CURSOR Location_Cursor
IS
SELECT
      NVL(Location_id,0),
      trading,
      NVL(bonded,'N') bonded --added for bug#6327274
FROM
      JAI_INV_SUBINV_DTLS
WHERE
      Sub_Inventory_Name      = v_subinventory AND
      organization_id         = v_organization_id                             ;

--added the cursor for bug#6327274
cursor  c_orgn_Null_site_info is
select  exc_shpt_wo_exc_tax_flag
from    JAI_CMN_INVENTORY_ORGS
where   organization_id = pr_new.organization_id
and     location_id = 0;


CURSOR item_trading_cur
IS
SELECT
       Item_Trading_Flag
FROM
       JAI_INV_ITM_SETUPS
WHERE
       organization_id   = v_organization_id    AND
       inventory_item_id = v_inventory_item_id                                ;

CURSOR Trading_register_code_cur(
                                              p_organization_id       NUMBER  ,
                                              p_location_id           NUMBER  ,
                                              p_delivery_detail_id    NUMBER  ,
                                              p_order_type_id         NUMBER
                                       )
IS
 SELECT
        A.register_code
 FROM
        JAI_OM_OE_BOND_REG_HDRS A, JAI_OM_OE_BOND_REG_DTLS b
 WHERE
        a.organization_id      = p_organization_id  AND
        a.location_id          = p_location_id      AND
        a.register_id          = b.register_id      AND
        b.order_flag           = 'Y'                AND
        b.order_type_id        = p_order_type_id    ;
       -- a.register_code        LIKE '23D%'; -- commented for bug#6327274

 /*
Code added by aiyer for the bug 3844145.
  Removed the group by subinventory clause from the query. The matched qty should be considered irrespective of the
subinventory
 */

 CURSOR matched_receipt_cur1
 IS
 SELECT
        sum(a.quantity_applied) quantity_applied
 FROM
        JAI_CMN_MATCH_RECEIPTS a
 WHERE
        a.ref_line_id = v_delivery_detail_id
 AND    a.order_invoice = 'O' ;

 CURSOR get_item_attributes
 IS
 SELECT
       excise_flag ,-- Commented attribute1 by Brathod for Bug# 4299606 (DFF Elimination)
       modvat_flag ,-- Commented attribute2 by Brathod for Bug# 4299606 (DFF Elimination)
       nvl(container_item_flag,'N'), --Added by Nagaraj.s for Bug3123613.
       nvl(inventory_item_flag,'N') --added by csahoo for bug#8500697
 FROM
       mtl_system_items msi,
       JAI_INV_ITM_SETUPS jmsi -- Added by Brathod for Bug# 4299606 (DFF Elimination)
 WHERE msi.organization_id          = jmsi.organization_id
 AND   msi.inventory_item_id        = jmsi.inventory_item_id
 AND   jmsi.inventory_item_id       = v_Inventory_Item_Id  -- Added by Brathod for Bug# 4299606 (DFF Elimination)
 AND   jmsi.organization_id         = v_organization_id;   -- Added by Brathod for Bug# 4299606 (DFF Elimination)


 -- Following cursors added by sriram bug# 2165355
 CURSOR  c_check_lc_order
 IS
 SELECT
        lc_flag
 FROM
        JAI_OM_OE_SO_LINES
 WHERE
        lc_flag        = 'Y'    AND
        header_id      = pr_new.source_header_id;

 /*
   This query has been modified aiyer for the bug #3039521.
   Add the delivery_detail_id in the where clause so that the lc matched quantity for a particular delivery_detail_id is checked.
   This would ensure that even though a order line has been split before release ,every split order Line
   (based on the delivery detail id ) needs to be lc matched for the shipped quantity.
 */

 --Added parameter by JMEENA for bug#6731913
 CURSOR c_matched_qty_cur(cp_delivery_detail_id IN NUMBER)
 IS
 SELECT
       sum(qty_matched)
 FROM
       JAI_OM_LC_MATCHINGS
 WHERE
       order_header_id         = pr_new.source_header_id         AND
      -- order_line_id           = pr_new.source_line_id           AND    --commented by csahoo for bug#5686360
       delivery_detail_id      = cp_delivery_detail_id          AND
       release_flag is null;

 v_check_lc_order   VARCHAR2(1);
 v_lc_qty_matched   NUMBER;
 v_lc_shipped_qty       NUMBER; --File.Sql.35 Cbabu  := pr_new.Shipped_quantity;

 -- ends here additions bug sriram bug# 2165355

 /* Start, bug#5686360
   following code is to correct the existing lc_matching order line to new split line id
 */
 cursor c_order_line is
   select split_from_line_id --, split_by
   from oe_order_lines_all
   where line_id = pr_new.source_line_id;

 cursor c_lc_mtch_dlry_line is
   select order_line_id
   from JAI_OM_LC_MATCHINGS
   where delivery_detail_id = v_delivery_detail_id;
 r_order_line          c_order_line%rowtype;
 r_lc_mtch_dlry_line   c_lc_mtch_dlry_line%rowtype;
 ln_lc_update_cnt      number;
  /* end bug#5686360 */


 -- Following cursors added by sriram - bug # 2689417
 -- The following cursor gets the tax amount for the line_id from JAI_OM_OE_SO_LINES table
 CURSOR c_ja_in_so_lines_tax_amt
 IS
 SELECT
        tax_amount
 FROM
        JAI_OM_OE_SO_LINES
 WHERE
        line_id   = pr_new.source_line_id        AND
        header_id = pr_new.source_header_id;


 -- The following cursor gets the sum of tax amount for the line_id from JAI_OM_OE_SO_TAXES table
 CURSOR  c_ja_in_so_tax_lines_tax_amt
 IS
 SELECT
       nvl(sum(so_tax.tax_amount),0)
 FROM
       JAI_OM_OE_SO_TAXES so_tax
     , jai_cmn_taxes_all  tax                  -- Added by Jia Li for inclusive tax on 2008/01/07
 WHERE
       line_id   = pr_new.source_line_id         AND
       header_id = pr_new.source_header_id
   AND so_tax.tax_id = tax.tax_id                -- Added by Jia Li for inclusive tax on 2008/01/07
   AND NVL(tax.inclusive_tax_flag,'N') = 'N' ;   -- Added by Jia Li for inclusive tax on 2008/01/07



 v_line_tax_amount Number; --File.Sql.35 Cbabu  :=0; -- to hold the tax amount for a line   - based on JAI_OM_OE_SO_LINES
 v_sum_tax_amount  Number; --File.Sql.35 Cbabu  :=0; -- to hold the sum of taxes for a line - based on JAI_OM_OE_SO_TAXES
 -- ends here -- cursors added by sriram - bug # 2689417


 /*
   The following cursor has been added by aiyer for the bug #3039521.
   Get the Currency code using the current org id from the table hr_operating_units and gl_sets_of_books
 */
 -- Start of cursor added by aiyer for the bug #3039521
 /* bug 5243532. Added by Lakshmi Gopalsami
    Removed the reference to cursor sob_cur
    as this is not used anywhere.
 */

 v_currency_code         GL_SETS_OF_BOOKS.CURRENCY_CODE%TYPE      ;

 -- End  of cursor Sob_Cur added for the bug #3039521.
  -- Start Of Bug #
  CURSOR c_chk_exc_exmpt_rule
  IS
  SELECT
          a.excise_exempt_type            ,
          a.line_number                   ,
          a.shipment_line_number          ,
          quantity                        -- added by sriram bug# 3441684
 FROM
          JAI_OM_OE_SO_LINES      a
 WHERE
          a.line_id   = pr_new.source_line_id   AND
          a.header_id = pr_new.source_header_id ;

 lv_excise_exempt_type        JAI_OM_OE_SO_LINES.EXCISE_EXEMPT_TYPE%TYPE      ;
 ln_line_number               JAI_OM_OE_SO_LINES.LINE_NUMBER%TYPE             ;
 ln_shipment_line_number      JAI_OM_OE_SO_LINES.SHIPMENT_LINE_NUMBER%TYPE    ;
 lv_ret_flag                  VARCHAR2(10)                                ;
 lv_error_msg                 VARCHAR2(1996)                              ;
 v_quantity                   number;
 -- End Of Bug #

-- added by sriram - bug#3441684
cursor  c_orgn_info is
select  trading
from    JAI_CMN_INVENTORY_ORGS
where   organization_id = pr_new.organization_id
and     location_id = pr_new.ship_from_location_id ;
--ends here additions by sriram - bug#3441684

/*
||  Begin Bug#4245073
||  Author : Brathod
||  Date   : 17-Mar-2005
*/
ln_vat_cnt           NUMBER DEFAULT 0 ;
ln_exc_cnt           NUMBER DEFAULT 0 ; --added for bug#8538431
ln_cnt_org_loc_setup NUMBER DEFAULT 0 ;
lv_applicable        JAI_RGM_ITM_TMPL_ATTRS.ATTRIBUTE_CODE%TYPE;
lv_process_flag      VARCHAR2 (2);
lv_process_message   VARCHAR2 (1000);

CURSOR cur_chk_vat_exists  (cp_line_id JAI_OM_OE_SO_TAXES.LINE_ID%TYPE,
                            cp_header_id JAI_OM_OE_SO_TAXES.HEADER_ID%TYPE
                            )
IS
SELECT 1
FROM   JAI_OM_OE_SO_TAXES       jstl    ,
       JAI_CMN_TAXES_ALL          jtc     ,
       jai_regime_tax_types_v   tax_types
WHERE  jstl.line_id   = cp_line_id
AND    jstl.header_id = cp_header_id
AND    jtc.tax_id     = jstl.tax_id
AND    jtc.tax_type   = tax_types.tax_type
AND    tax_types.regime_code = jai_constants.vat_regime;

--added the following cursor for bug#8538431
CURSOR cur_chk_excise_exists  (cp_line_id JAI_OM_OE_SO_TAXES.LINE_ID%TYPE,
                               cp_header_id JAI_OM_OE_SO_TAXES.HEADER_ID%TYPE
                              )
IS
SELECT 1
FROM   JAI_OM_OE_SO_TAXES       jstl    ,
       JAI_CMN_TAXES_ALL          jtc
WHERE  jstl.line_id   = cp_line_id
AND    jstl.header_id = cp_header_id
AND    jtc.tax_id     = jstl.tax_id
AND    jtc.tax_type   in ( jai_constants.tax_type_excise,
                           jai_constants.tax_type_exc_additional,
                           jai_constants.tax_type_exc_other,
                           jai_constants.tax_type_exc_edu_cess,
                           jai_constants.tax_type_sh_exc_edu_cess);

CURSOR cur_chk_org_loc_setup  (cp_organization_id JAI_OM_WSH_LINES_ALL.LOCATION_ID%TYPE,
                               cp_location_id     JAI_OM_WSH_LINES_ALL.ORGANIZATION_ID%TYPE
                              )
IS
SELECT 1
FROM   jai_rgm_parties rgmpt,
       JAI_RGM_DEFINITIONS     rgms
WHERE  rgmpt.regime_id        = rgms.regime_id
AND    rgmpt.location_id      = cp_location_id
AND    rgmpt.organization_id  = cp_organization_id
AND    rgms.regime_code       = jai_constants.vat_regime;

/*
||End of bug 4245073
*/


/*
|| Added by bgowrava for the forward porting bug 5631784
*/
 tab_ooh OE_ORDER_HEADERS_ALL%ROWTYPE  ;
 CURSOR  cur_get_org_hdr (cp_header_id OE_ORDER_HEADERS_ALL.HEADER_ID%TYPE)
 IS
 SELECT
        *
 FROM
        oe_order_headers_all
 WHERE
        header_id = cp_header_id ;
--Added cursor by JMEENA for bug#6731913
CURSOR cur_tot_shipped_quantity (cp_delivery_detail_id IN NUMBER)
 IS
 SELECT sum ( shipped_quantity)
   FROM jai_wsh_del_details_gt
  WHERE delivery_detail_id = cp_delivery_detail_id
     OR split_from_delivery_detail_id = cp_delivery_detail_id;
 v_tot_lc_shipped_qty   NUMBER;
 ln_cnt                 NUMBER;
 ln_unprocessed_recs    NUMBER;
 --End bug#6731913

 /* Added for bug#8924003, Start */
  CURSOR c_ato_line_id IS
  SELECT
        oel.ato_line_id
  FROM
        oe_order_headers_all oeh,
        oe_order_lines_all oel
  WHERE
        oeh.header_id        = pr_new.source_header_id
  AND   oeh.header_id        = oel.header_id
  AND   item_type_code       = 'CONFIG' ;

  CURSOR c_model_item_id(cp_ato_line_id oe_order_lines_all.line_id%TYPE) IS
  SELECT
        oel.inventory_item_id
  FROM
        oe_order_lines_all oel
  WHERE
        oel.line_id     = cp_ato_line_id
  AND   item_type_code  = 'MODEL' ;

  ln_ato_line_id   NUMBER ;
  ln_model_item_id NUMBER ;
 /*bug#8924003, end*/

 PROCEDURE set_debug_context
 IS
 BEGIN
   lv_context  := rtrim(lv_object_name || '.'||lv_member_name,'.');
 END set_debug_context;

  /* End of bug 5631784*/

  BEGIN
    pv_return_code := jai_constants.successful ;
   /***************************************************************************************************************************************************

  Change History :

  1. Sriram - Bug # 2645439. File Version 615.1
                   Created the trigger.This trigger was created because , when the
                   interface trip stop runs into an error in the case of a trading organization , because the
                   Shipment is not matched against any receipt , it shows a form level error message and does
                   not allow shipment to continue.

  2. Sriram - Bug # 2689417  File Version 615.2
                   Added another condition in the WHEN Clause of the trigger to check that the trigger
                   fires only when the Released_status field is set to 'C' and does not fire
                   on updates of other fields at which point the releaed_status is 'C'.

                   Also the update statement , which updates the released_flag in the JAI_OM_LC_MATCHINGS table
                   has been commented , because the update should happen after the shipping has completed.

                   Also an error message has to be thrown , when shipping is done , for an order
                   where the tax amounts in the JAI_OM_OE_SO_TAXES and JAI_OM_OE_SO_LINES do not tally.

  3. Avishek - Bug # 2928261
                   Added a RAISE_APPLICATION_ERROR to give an error message when a sub-inventory is not
                   associated properly with a location ID.

  4. Aiyer   - Bug # 3039521, File Version 616.1   Date 09-Jul-2003
                 Issue:-
                  1. Orders which are partially matched and shipped post splitting of lines without full matching get shipped and are not stopped by
                     this trigger as it does when the lines are not split.

                  2. Another issue reported with this trigger was that it used to get fired even in case for non Indian Shipments.
                     These shipments need not have the Localization sub-inventory setup - Mandatory for all Indian Shipments
                     (using localization). However as this trigger used to get fired in those cases also hence the error
                     "Mandatory Localization sub-inventory setup is not made" used to get invoked and the execution used
                     to stop.

                 Solution:-
                  1. While checking that for a line being shipped, if the LC flag is enabled , then the amount being shipped should be
                     lc matched. However it was not being checked that, in case of a split line also the amount pertaining to the
                     same delivery_detail_id should be lc matched.
                     Added a where clause in the cursor c_matched_qty_cur to also include the check for the delivery_detail_id.

                  2.Put a check in the beginning of the trigger that if the functional currency is NOT 'INR' then
                    return from the trigger, i.e this trigger should get bypassed in case of Non Indian Shipments
                    (Global Scenario).

  5. Aiyer   - Bug #3032569, File Version 616.2   Date 24-Jul-2003
                 Issue:-
                  The trigger checks that the match receipt functionality is performed in scenario's of
                  Trading Domestic Without Excise and Export Without excise.
                  This check is not required. The match receipts only needs to be done for
                  'Trading Domestic With Excise' and 'Export with Excise' type of Scenario's

                Solution:-
                         Modified the IF statment to raise an error only when trading register code is in 23D_DOMESTIC_EXCISE and 23D_EXPORT_EXCISE.
                         The other two trading register_codes '23D_DOM_WITHOUT_EXCISE' and '23D_EXPORT_WITHOUT_EXCISE' have been removed as matched receipts
                         is not relevant in this case.
                Dependency Introduced Due to this Bug : -
                  None

  6. Nagaraj.s    -Bug#3123613, File Version : 616.3 Date:04-Sep-2003
                    Added the container_item_flag also in the cursor get_item_attributes and the
                    check for Mandatory Location is added with one more condition of :
                    v_container_item_flag ='N' , so that in case of containerization, the check
                    does not hold good.

  7. Aiyer        -Bug# 3392528 , File Version : 618.1 Date:11-Feb-2004
                   Issue
                   =====
                    An sales order In India Localization Order Management should not be allowed to be shipped on the following
                    conditions : -
                     1. A Sales order with excise exemption types like EXCISE_EXEMPT_CERT,
                        CT2,CT3 has modvat type of taxes attached

                     2. A Sales order with excise exemption types like EXCISE_EXEMPT_CERT_OTH,
                        CT2_OTH does not have modvat recovery type of tax attached

                     3. A sales order does not have any excise exemptions specified and still
                        has Modvat Recovery type of taxes.

                       These check also needs to be implemented at shipping level

                   Solution:-
                    Created the procedure jai_om_utils_pkg.validate_excise_exemption to validate all the above conditions and called the same
                    with the relevent parameters. This has resolved the issue

                   Dependency Due To The Current Bug :
                    1. This trigger ja_in_wsh_dlry_au_rel_stat_trg.sql (618.1) call the
                       function ->jai_om_utils_pkg.validate_excise_exemption(618.1) and hence has dependencies

 8. ssumaith      - Bug#3441684 file version 618.2 : 20-feb-04

                   After match receipts is done for a delivery , when back-ordering is performed, the delivery
                   is back-ordered , but the matched info is not removed from the match receipts table.

                   The requirement is to raise an error when backordering is done without unmatching the delivery.

                   Dependency Due to this bug:
           None

9.    Aiyer     23/08/2004  Bug# 3844145 file version 115.2
              Issue:-
               The inventory trip stop concurrent program errors out for a Internal sales order with qty being matched to two different subinventories.

              Reason :-
               The existing code was considering matched quantites as per the subinventories. This should not be considered.
               Matched quantities should be considered irrespective of the subinventories.

      Solution:-
       Modified the cursor matched_receipt_cur1 in the current trigger.Removed the group by subinventory clause from the query.

              Dependency Due to this bug:
       None


10.       Aparajita  30/11/2004. Bug#4036241. Version#115.3

                  Introduced the call to centralized packaged procedure,
                  jai_cmn_utils_pkg.check_jai_exists to check if localization has been installed.


11.       Brathod   21/03/2005. Bug#4245073. Version# 115.4, 115.5
                    Trigger modified to check whether vat type of tax exists or not.
                    If vat type of tax exits and organization, location setup does not
                    exits for vat rigme, trigger will throw an exeception.
                    Also if vat type of tax exits but the item is not vatable trigger
                    will throw an exception

12    Brathod   26/04/2005for Bug# 4299606 File Version 116.1
                  Issue:-
      Item DFF Elimination
      Fix:-
      Changed the code that references attributeN (where N=1,2,3,4,5,15) of
      mtl_system_items to corrosponding columns in JAI_INV_ITM_SETUPS

      Dependency :-
        IN60106 + 4239736  (Service Tax) + 4245089  (VAT)

13    08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old
                    DB Entity as required for CASE COMPLAINCE.  Version 116.1

14. 13-Jun-2005    File Version: 116.2
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done

15.       Aiyer 22/08/2005. Bug#4566002(Forward Porting for bug 4426615), File Version# 120.3
             Issue : -
              After LC Matching, the user is not being allowed to Backorder the quantity.

             Fix:-
              The matched quantity = shipped quantity should be checked only in case of ship confirm release_status = 'C'.
              This check should not happen on Backordering release_status = 'B'.

16.   30-Jan-2007  bgowrava for forward porting bug#5631784(4742259), File Version 120.4
                Added the call to jai_ar_tcs_rep_pkg.process_transaction. for TCS related validations.
                Dependencies Due to this bug:-
                This bug has lots of datamodel abd specification changes.

17.   17-May-2007   CSahoo for bug#5686360  File Version 120.5
                    Forward porting of 11i BUG#5665937
                    modified the cursor c_matched_qty_cur to filter the data only by delivery_detail_id
                    and order header_id and removed the filter by order line_id

                    Added the cursors c_order_line and c_lc_mtch_dlry_line, to check if the order line attached
                    the delivery detail in LC matching table is same or not. If not, then the related delivery_detail
                    line is updated with the :new.source_line_id

                    Appended SQLERRM to the fnd_message.set_token value parameter to display the error

18.   25-May-2009   CSahoo for bug#8538431, File Version 120.9.12010000.6
                    Issue: ERROR SHOULD BE SHOWN WHEN THE ITEM THE EXCISE TAXES BUT ITEM DFF NOT GIVEN.
                    Fix: Added the cursor cur_chk_excise_exists to check if excise taxes exists or not.
                         Also added the code to check if item is not excisable and still excise taxes are
                         added, then it would raise an error.

19.   25-JUN-2009   JMEENA for bug#6731913
                    Issue: INDIA LOCAL: SHIP CONFIRM GIVES LC MATCH ERROR EVEN AFTER MATCHING IS DONE
                    Fix:  The fix inlvoves a lot of modification in the code. A new procedure ARU_T4 and temp
                          table JAI_WSH_DEL_DETAILS_GT is created.
                          This table gets populated when the shipped_quantity gets updated. Then when the released Quantity changes to 'C'
                          the shipped quantity is calculated from this temp table. Then finally the table gets flushed after all the
                          records are processed.
                          Commented LC Matching code in procedure ARU_T3 as it exists in ARU_T2.

20.   27-Jul-2009   CSahoo for bug#8731696, File Version 120.9.12010000.9
                    FP 12.0 8687223 :VAT INV IS NOT GENERATING WHEN BILL TO AND SHIP TO LOCATIONS AR
                    Modified the cursor get_ship_to_org_id_cur to get the bill_to_org_id. Added the cursor
                    cur_get_bill_to_cust_id to obtain the bill_to_customer_id.

21.   14-Aug-2009   CSahoo for bug#6327274, File Version 120.9.12010000.10
                    Issue: FP :INDIA EXCISE INV GENERATION ENDS IN ERROR WHEN ED TAX NOT ATTACHED
                    Fix: Modified the code in this procedure. Added the cursor c_orgn_Null_site_info

22.   23-Sep-2009   CSahoo for bug#8924003, File Version 120.9.12010000.11
                    Issue : TAXES AND UNIT RATE  COMING WRONGLY FOR THE ATO/PTO ITEM
                    Fix: forward ported the changes done for bug#6147494. Added cursors to identify
                         the ato_line_id of config item and inturn derived inventory_item_id of model item.
                         If star(Config) item is being shipped from shipping transactions form, model items
                         'Item Classification' is validated.

Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Current Version       Current Bug    Dependent         Dependency On Files       Version   Author   Date         Remarks
Of File                              On Bug/Patchset
ja_in_wsh_dlry_au_rel_stat_trg.sql
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
618.1                  3392528       IN60105D2         ja_in_val_exc_exmpt_f.sql  618.1    Aiyer   11-Feb-2004  This trigger calls the function ja_in_val_exc_exmpt_f.sql

115.3                 4036241        4033992           ja_in_util_pkg_s.sql 115.0  115.0   Apdas   30-nov-04
                                                       ja_in_util_pkg_b.sql 115.0  115.0   apdas   30-11-2004

115.5                 4245073         4245089          ALL VAT Objects

115.6                 4299606         IN60106
            + 4239736  (Service Tax)
            + 4245089  (VAT)

18.    01-JAN-2008  Added by Jia Li
                    for Inclusive tax Computation
-------------------------------------------------------------------------------------------------------------------*/

--File.Sql.35 Cbabu
v_inventory_item_id            :=pr_new.inventory_item_id        ;
v_organization_id              :=pr_new.organization_id          ;
v_subinventory                 :=pr_new.subinventory             ;
v_delivery_detail_id           :=pr_new.delivery_detail_id       ;
v_source_header_type_id        :=pr_new.source_header_type_id    ;
v_shipped_quantity             := nvl(pr_new.shipped_quantity,0) ;
lv_object_name           :='TRIGGER.ARAA.AFTER.JA_IN_WSH_DLRY_AU_REL_STAT_TRG' ;  -- added Date 02-Feb-2007  by bgowrava  for Bug  bug#5631784
v_matched_qty                  := 0                            ;
v_lc_shipped_qty        := pr_new.Shipped_quantity;
v_line_tax_amount  :=0;
v_sum_tax_amount   :=0;


  --if
  --  jai_cmn_utils_pkg.check_jai_exists (p_calling_object => 'JA_IN_WSH_DLRY_AU_REL_STAT_TRG', p_org_id =>  pr_new.org_id)
  --  =
  --  FALSE
  --then
  --  /* India Localization funtionality is not required */
  --  return;
  --end if;

  -- Following statements added by sriram - bug # 2689417
  OPEN  c_ja_in_so_lines_tax_amt;
  FETCH c_ja_in_so_lines_tax_amt INTO v_line_tax_amount;
  CLOSE c_ja_in_so_lines_tax_amt;

  OPEN  c_ja_in_so_tax_lines_tax_amt;
  FETCH c_ja_in_so_tax_lines_tax_amt INTO v_sum_tax_amount;
  CLOSE c_ja_in_so_tax_lines_tax_amt;

  IF NVL(v_line_tax_amount,0) <> NVL(v_sum_tax_amount,0) THEN
/*      RAISE_APPLICATION_ERROR(-20405,'Taxes are not matching in JAI_OM_OE_SO_LINES and JA_IN_SO_TAX_LINE FOR LINE_ID ' || pr_new.Source_line_id);
  */ pv_return_code := jai_constants.expected_error ; pv_return_message := 'Taxes are not matching in JAI_OM_OE_SO_LINES and JA_IN_SO_TAX_LINE FOR LINE_ID ' || pr_new.Source_line_id ; return ;
  END IF;
-- ends here  bug # 2689417

  -- Start Of Bug #3392528,
  /*
   This code has been added by aiyer for the bug 3392528.
   Call the function jai_om_utils_pkg.validate_excise_exemption to validate the different valid combination of values
   that can exists  between JAI_OM_OE_SO_LINES.excise_exempt_type and tax types associated with the
   table JAI_OM_OE_SO_TAXES
  */

  OPEN  c_chk_exc_exmpt_rule;
  FETCH c_chk_exc_exmpt_rule INTO lv_excise_exempt_type,ln_line_number,ln_shipment_line_number,v_quantity;
  CLOSE c_chk_exc_exmpt_rule ;

  lv_ret_flag :=   jai_om_utils_pkg.validate_excise_exemption (
                                         p_line_id              => pr_new.source_line_id      ,
                                         p_excise_exempt_type   => lv_excise_exempt_type    ,
                                         p_line_number          => ln_line_number           ,
                                         p_shipment_line_number => ln_shipment_line_number  ,
                                         p_error_msg            => lv_error_msg
                                       ) ;
 IF nvl(lv_ret_flag,'S') = 'EE' THEN
   /* Handle all expected errors in this section. */
/*    raise_application_error(-20406, lv_error_msg ); */ pv_return_code := jai_constants.expected_error ; pv_return_message :=  lv_error_msg  ; return ;

 ELSIF  nvl(lv_ret_flag,'S') = 'UE' THEN
   /* Handle all unexpected errors in this section. */
/*    raise_application_error(-20406, lv_error_msg );
*/ pv_return_code := jai_constants.expected_error ; pv_return_message :=  lv_error_msg  ; return ;
 END IF ;
-- End Of Bug #3392528

  OPEN  location_cursor;
  FETCH location_cursor INTO    v_location_id, v_trading_flag , v_bonded; --added lv_bonded for bug#6327274
  CLOSE location_cursor;
  --moved the code here for bug#6327274, start
  OPEN  trading_register_code_cur(    v_organization_id       ,
                                      v_location_id           ,
                                      v_delivery_detail_id    ,
                                      v_source_header_type_id
                                 );
  FETCH trading_register_code_cur INTO v_trad_register_code;
  CLOSE trading_register_code_cur;
  --bug#6327274, end

  /*moved the code to here for bug#8500697*/
  OPEN get_item_attributes;
  FETCH get_item_attributes INTO v_exe_flag,v_mod_flag,v_container_item_flag,lv_inventory_item_flag;
  CLOSE get_item_attributes;


  if  nvl(pr_new.Released_status,'N') = 'C' then
    --added for bug#8538431, start
    OPEN cur_chk_excise_exists(cp_line_id    => pr_new.source_line_id,
                               cp_header_id  => pr_new.source_header_id
                              );
    FETCH cur_chk_excise_exists INTO ln_exc_cnt;
    CLOSE cur_chk_excise_exists ;

    IF nvl (ln_exc_cnt,0) > 0 AND nvl(v_exe_flag,'N') = 'N' THEN
      pv_return_code := jai_constants.expected_error ;
      pv_return_message :=  'An item which is not Excisable has Excise Taxes attached.
                             Please correct the item attribute or remove the Excise type of taxes' ;
      return ;
    END IF;
    --bug#8538431, end
    --added the following for bug#6327274, start


    IF (
       (
        NVL(v_bonded,'N') =  'Y'                             OR
        NVL(v_trading_flag,'N') = 'Y'
       )                                                       AND
       NVL(v_exe_flag,'N') = 'Y'                               AND
       v_trad_register_code  IN (
                                '23D_DOMESTIC_EXCISE'   ,
                                '23D_EXPORT_EXCISE'     ,
                                'DOMESTIC_EXCISE'       ,
                                'EXPORT_EXCISE'         ,
                                'BOND_REG'              ,
                                '23D_EXPORT_WITHOUT_EXCISE'
                               )                              AND
       nvl(ln_exc_cnt,0) = 0
      )
   THEN

      OPEN c_orgn_null_site_info;
      FETCH c_orgn_null_site_info INTO  lv_allow_shipment_wo_excise;
      CLOSE c_orgn_null_site_info;

      IF  NVL(lv_allow_shipment_wo_excise,'N') =  'Y' THEN
          raise_application_error(-20412, 'Delivery can not be ship confirmed as Excisable Item in the shipment does not have Excise taxes' );
      END IF;
   END IF;
   --bug#6327274, end
    --csahoo for bug#8500697. Added a check on lv_inventory_item_flag in the following if clause
    IF v_location_id IS NULL  and v_container_item_flag ='N' and lv_inventory_item_flag = 'Y' then
    /*  raise_application_error(-20406, 'Mandatory India Localization Sub-inventory Setup not done for this Location from where shipment is made');
    */ pv_return_code := jai_constants.expected_error ; pv_return_message :=  'Mandatory India Localization Sub-inventory Setup not done for this Location from where shipment is made' ; return ;
    end if ;
  end if;
  -- ends here  - Bug # 2928261

  -- starts here additions by sriram - bug#3441684
  if v_location_id is null then
     v_location_id := pr_new.ship_from_location_id;
  end if;
  -- ends here additions by sriram - bug# 3441684
  /*bug#8500697,end*/

  /*
  ||  Begin  Bug#4245073
  ||  Author : Brathod
  ||  Date   : 17-Mar-2005
  */

  IF  nvl(pr_new.Released_status,'N') = 'C' THEN
    OPEN  cur_chk_vat_exists ( cp_line_id    => pr_new.source_line_id,
                               cp_header_id  => pr_new.source_header_id
                             );
    FETCH cur_chk_vat_exists INTO ln_vat_cnt;
    CLOSE cur_chk_vat_exists ;

    IF nvl (ln_vat_cnt,0) > 0 THEN

      OPEN cur_chk_org_loc_setup  (cp_organization_id => v_organization_id ,
                                   cp_location_id     => v_location_id
                                   );
      FETCH cur_chk_org_loc_setup INTO ln_cnt_org_loc_setup;
      CLOSE cur_chk_org_loc_setup ;

      IF nvl(ln_cnt_org_loc_setup,0) = 0 THEN
      /*
      || For vat regime organization-location specific setup does not exist in
      || jai_rgm_parties (Regime Organization Registration)
      */
      app_exception.raise_exception( EXCEPTION_TYPE   => 'APP'
                                     ,EXCEPTION_CODE  => NULL
                                     ,EXCEPTION_TEXT  => 'Organization-Location setup does not exist at regime level'
                                    );
      END IF;
      /* Added for bug#8924003, Start */
      ln_ato_line_id   := NULL ;
      ln_model_item_id := NULL ;

      OPEN  c_ato_line_id ;
      FETCH c_ato_line_id INTO ln_ato_line_id ;
      CLOSE c_ato_line_id ;

      IF ln_ato_line_id IS NOT NULL THEN
        OPEN  c_model_item_id(ln_ato_line_id) ;
        FETCH c_model_item_id INTO ln_model_item_id ;
        CLOSE c_model_item_id ;

        jai_inv_items_pkg.jai_get_attrib ( p_regime_code        =>  jai_constants.vat_regime
                                         , p_organization_id    =>  pr_new.organization_id
                                         , p_inventory_item_id  =>  ln_model_item_id
                                         , p_attribute_code     =>  jai_constants.rgm_attr_item_applicable
                                         , p_attribute_value    =>  lv_applicable
                                         , p_process_flag       =>  lv_process_flag
                                         , p_process_msg        =>  lv_process_message
                                         );
      ELSE
      /*bug#8924003, End */

        jai_inv_items_pkg.jai_get_attrib ( p_regime_code        =>  jai_constants.vat_regime
                                         , p_organization_id    =>  pr_new.organization_id
                                         , p_inventory_item_id  =>  pr_new.inventory_item_id
                                         , p_attribute_code     =>  jai_constants.rgm_attr_item_applicable
                                         , p_attribute_value    =>  lv_applicable
                                         , p_process_flag       =>  lv_process_flag
                                         , p_process_msg        =>  lv_process_message
                                         );
      END IF;
      IF  lv_process_flag = jai_constants.successful
      AND nvl(lv_applicable,'N') = 'N' THEN
        /*
        ||item is not vatable
        */
        app_exception.raise_exception( EXCEPTION_TYPE  => 'APP'
                                      ,EXCEPTION_CODE  => NULL
                                      ,EXCEPTION_TEXT  => 'An item which is not Vatable has VAT Taxes attached.
                                                           Please correct the item attribute or remove the VAT type of taxes'
                                      );
      ELSIF lv_process_flag <> jai_constants.successful THEN
        app_exception.raise_exception( EXCEPTION_TYPE  => 'APP'
                                      ,EXCEPTION_CODE  => NULL
                                      ,EXCEPTION_TEXT  => substr (lv_process_message,1,999)
                                      );


      END IF;
    END IF;
  END IF;

  /*
  || End Bug#4245073
  */


  -- SJS
  open  c_orgn_info;
  fetch c_orgn_info into v_trading_flag;
  close c_orgn_info;
  -- SJS
  -- code to be added by AVIKUMAR Bug # 2928261

  OPEN  item_trading_cur;
  FETCH item_trading_cur INTO v_item_trading_flag;
  CLOSE item_trading_cur;

/*
    Code modified by aiyer for the bug 3032569
    Modified the IF statment to raise an error only when trading register code is in 23D_DOMESTIC_EXCISE and 23D_EXPORT_EXCISE.
    The other two trading register_codes '23D_DOM_WITHOUT_EXCISE' and '23D_EXPORT_WITHOUT_EXCISE' have been removed from this if statement
    as matched receipts is not relevant in this case.
  */
  -- Start of Bug #3032569

  IF v_trad_register_code IN(
                                   '23D_DOMESTIC_EXCISE'           ,
                                   '23D_EXPORT_EXCISE'
                             )
  THEN
  -- End of Bug #3032569

    IF nvl(v_trading_flag,'N') = 'Y' AND nvl(V_item_trading_flag,'N') = 'Y'  AND NVL(v_exe_flag,'N')= 'Y' THEN

      OPEN  matched_receipt_cur1;
      FETCH matched_receipt_cur1 INTO v_matched_qty/*,v_matched_subinv*/;
      CLOSE matched_receipt_cur1;
      IF  nvl(pr_new.Released_status,'N') = 'C' THEN
        IF nvl(v_shipped_quantity,0) <> nvl(v_matched_qty,0) THEN
/*           raise_application_error(-20401, 'Matched Quantity -- ' || TO_CHAR(NVL(v_matched_qty,0)) ||
                                         ' should be equal to Shipped Quantity -- ' || TO_CHAR(NVL(v_shipped_quantity,0))); */
pv_return_code := jai_constants.expected_error ; pv_return_message := 'Matched Quantity -- ' || TO_CHAR(NVL(v_matched_qty,0)) ||
                                         ' should be equal to Shipped Quantity -- ' || TO_CHAR(NVL(v_shipped_quantity,0));  return ;

        END IF;
      END IF;

      -- starts additions by sriram - bug# 3441684
      if  nvl(pr_new.Released_status,'N') = 'B' then
         -- if  v_matched_qty = v_quantity and v_matched_qty is not null then
          if  nvl(v_matched_qty,0) > 0     then
/*             raise_application_error (-20402, 'Please Unmatch the Delivery prior to backordering ');
 */ pv_return_code := jai_constants.expected_error ; pv_return_message :=  'Please Unmatch the Delivery prior to backordering ' ; return ;
      end if ;
      end if;
      -- ends here additions by sriram - bug# 3441684
    END IF;
  END IF;

  /*
  || Start of bug 4566002
  || Code added by aiyer for the bug 4566002
  || Added the IF statment to make sure that The matched quantity = shipped quantity condition should be checked only
  || in case of ship confirm release_status = 'C'.
  || This check should not happen on Backordering release_status = 'B'.
  */
  IF  nvl(pr_new.Released_status,'N') = 'C' THEN
  /*
  the following lines added by sriram - lc functionality - bug# 2165355 - 19/09/2002
  moved into the trigger on 27th november 2002.
  */
  OPEN   c_check_lc_order;
  FETCH  c_check_lc_order INTO v_check_lc_order;
  CLOSE  c_check_lc_order;

  IF NVL(v_check_lc_order,'N') = 'Y' THEN
    OPEN  c_matched_qty_cur(pr_new.DELIVERY_DETAIL_ID) ; --Added parameter for bug#6731913
    FETCH c_matched_qty_cur INTO v_lc_qty_matched;
    CLOSE c_matched_qty_cur;

  --Added below code by JMEENA for bug#6731913
    IF v_lc_qty_matched IS NULL AND pr_new.SPLIT_FROM_DELIVERY_DETAIL_ID IS NOT NULL THEN
        OPEN  c_matched_qty_cur (pr_new.SPLIT_FROM_DELIVERY_DETAIL_ID);
        FETCH c_matched_qty_cur INTO v_lc_qty_matched;
        CLOSE c_matched_qty_cur;

      END IF;
    IF NVL(v_lc_qty_matched,-999) <> NVL(v_lc_shipped_qty,-888) THEN
    IF pr_new.SPLIT_FROM_DELIVERY_DETAIL_ID IS NULL THEN
           OPEN cur_tot_shipped_quantity (pr_new.delivery_detail_id);
           FETCH cur_tot_shipped_quantity INTO v_tot_lc_shipped_qty;
           CLOSE cur_tot_shipped_quantity;
        ELSE
           OPEN cur_tot_shipped_quantity (pr_new.SPLIT_FROM_DELIVERY_DETAIL_ID);
           FETCH cur_tot_shipped_quantity INTO v_tot_lc_shipped_qty;
           CLOSE cur_tot_shipped_quantity;
        END IF;

        IF NVL(v_lc_qty_matched,-999) <> NVL(v_tot_lc_shipped_qty,-888) THEN

/*       raise_application_error(-20401, 'LC Matched Quantity -- ' || TO_CHAR(NVL(v_lc_qty_matched,0)) ||
                                      ' should be equal to Shipped Quantity -- ' || TO_CHAR(NVL(v_lc_shipped_qty,0)) || ' for LC enabled Orders'
                             ); */ pv_return_code := jai_constants.expected_error ; pv_return_message := 'LC Matched Quantity -- ' || TO_CHAR(NVL(v_lc_qty_matched,0)) ||
                                      ' should be equal to Shipped Quantity -- ' || TO_CHAR(NVL(v_lc_shipped_qty,0)) || ' for LC enabled Orders'
                              ; return ;
    END IF;
    END IF;

    Update jai_wsh_del_details_gt
      set processed_flag = 'Y'
      where delivery_detail_id = pr_new.delivery_detail_id;
--End bug#6731913

     /* Start, bug#5686360 csahoo
        following code is to correct the existing lc_matching order line to new split line id
      */
      open c_order_line;
      fetch c_order_line into r_order_line;
      close c_order_line;

      ln_lc_update_cnt := -1;
      if r_order_line.split_from_line_id is not null then
        open c_lc_mtch_dlry_line;
        fetch c_lc_mtch_dlry_line into r_lc_mtch_dlry_line;
        close c_lc_mtch_dlry_line;
        if pr_new.source_line_id <> r_lc_mtch_dlry_line.order_line_id then

          update JAI_OM_LC_MATCHINGS
          set order_line_id = pr_new.source_line_id
          where delivery_detail_id = v_delivery_detail_id
          -- and order_line_id = r_order_line.split_from_line_id
          and release_flag is null;
          ln_lc_update_cnt := sql%rowcount;
        end if;

      end if;


      /* End, bug#5686360 csahoo*/

  END IF;

  /*
    ENDS HERE - CHANGES BY SRIRAM FOR LC FUNCTIONALITY - BUG # 2165355 - 19/09/2002
  */
  END IF;
  /*
  || End of bug 4566002
  */
  --Added below code by JMEENA for bug#6731913
  IF NVL(v_check_lc_order,'N') = 'Y' THEN
  select count(1) into ln_unprocessed_recs from jai_wsh_del_details_gt
  where processed_flag = 'N'
  --modified for bug#6443738
  AND (delivery_detail_id = nvl(pr_new.SPLIT_FROM_DELIVERY_DETAIL_ID,pr_new.delivery_detail_id )
     OR split_from_delivery_detail_id = nvl(pr_new.SPLIT_FROM_DELIVERY_DETAIL_ID,pr_new.delivery_detail_id));

  IF ln_unprocessed_recs = 0 THEN
     delete jai_wsh_del_details_gt
     where processed_flag = 'Y'
     --modified for bug#6443738
     and (delivery_detail_id = nvl(pr_new.SPLIT_FROM_DELIVERY_DETAIL_ID,pr_new.delivery_detail_id )
        OR split_from_delivery_detail_id =  nvl(pr_new.SPLIT_FROM_DELIVERY_DETAIL_ID,pr_new.delivery_detail_id));

  END IF;
END IF;
--End for bug#6731913


   /****************************************************
   || Added by bgowrava for forward porting bug#5631784(4742259)
   ||TCS Validation
   ****************************************************/
   OPEN  cur_get_org_hdr (cp_header_id => pr_new.source_header_id);
   FETCH cur_get_org_hdr INTO tab_ooh ;
   CLOSE cur_get_org_hdr ;

   /*jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        pv_log_msg  =>  ' Before call to jai_ar_tcs_rep_pkg.process_transactions .'
                                     );*/ --commented by bgowrava for Bug #5631784

   jai_ar_tcs_rep_pkg.process_transactions   (  p_ooh                => tab_ooh                        ,
                                                p_event              => jai_constants.wsh_ship_confirm ,
                                                p_process_flag       => lv_process_flag                ,
                                                p_process_message    => lv_process_message
                                             );

   /*jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                       pv_log_msg  =>  ' returned from jai_ar_tcs_rep_pkg.process_transactions .'
                                    );*/ --commented by bgowrava for Bug #5631784

   IF lv_process_flag = jai_constants.expected_error    OR                      ---------A2
      lv_process_flag = jai_constants.unexpected_error
   THEN
     /*
     || As Returned status is an error hence:-
     || Set out variables p_process_flag and p_process_message accordingly
     */
     --call to debug package
     /*jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                pv_log_msg  =>  ' Error : - lv_process_flag -> '||lv_process_flag||' - '||lv_process_message
                             ); */ --commented by bgowrava for Bug #5631784

     raise le_error;
   END IF;                                                                      ---------A2


  /*  jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        pv_log_msg  =>  ' TRIGGER ja_in_wsh_dlry_au_rel_stat_trg COMPLETED SUCCESSFUL'
                                     ); */ --commented by bgowrava for Bug #5631784
    jai_cmn_debug_contexts_pkg.deregister (pn_reg_id => ln_reg_id);


  EXCEPTION
    WHEN le_error THEN
      IF lv_process_flag   = jai_constants.unexpected_error THEN
        lv_process_message := substr (lv_process_message || ' Object = ja_in_wsh_dlry_au_rel_stat_trg ', 1,1999) ;
      END IF;


      fnd_message.set_name (application => 'JA',
                            name        => 'JAI_ERR_DESC'
                             );

      fnd_message.set_token ( token => 'JAI_ERROR_DESCRIPTION',
                              value => lv_process_message
                             );


      app_exception.raise_exception;

    WHEN others THEN
      fnd_message.set_name (  application => 'JA',
                              name        => 'JAI_ERR_DESC'
                           );

      fnd_message.set_token ( token => 'JAI_ERROR_DESCRIPTION',
                              value => 'Exception Occured in ' || ' Object = ja_in_wsh_dlry_au_rel_stat_trg'||fnd_global.local_chr(10)||SQLERRM  /* added SQLERRM for bug#5686360*/
                            );

    app_exception.raise_exception;
  /* end of Bug#5631784 */

  END ARU_T2 ;

  /*
  REM +======================================================================+
  REM NAME          ARU_T3
  REM
  REM DESCRIPTION   Called from trigger JAI_OM_WDD_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_OM_WDD_ARU_T4
  REM
  REM    02/11/2006      for Bug 5228046 by SACSETHI, File version 120.2
  REM                    Forward porting the change in 11i bug 5365523 (Additional CVD Enhancement).
  REM                    This bug has datamodel and spec changes.
  REM    16-Apr-2010     modified by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement).
  REM                    modified population logic of table jai_om_wsh_lines_all to populate column
  REM                    shippable_flag as 'Y'.
  REM    28-Apr-2010     modified by Allen Yang for bug 9666476
  REM                    logic of shippable_flag population is changed back. For shippable lines,
  REM                    shippable_flag will be populated with NULL.
  REM
  REM
  REM +======================================================================+
  */
  PROCEDURE ARU_T3 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
                 v_creation_date                 DATE; --File.Sql.35 Cbabu             :=pr_new.Creation_Date;
                v_created_by                    NUMBER; --File.Sql.35 Cbabu   :=pr_new.Created_By;
                v_last_update_date              DATE ; --File.Sql.35 Cbabu            :=pr_new.Last_Update_Date;
                v_last_updated_by               NUMBER; --File.Sql.35 Cbabu   :=pr_new.Last_Updated_By;
                v_last_update_login             NUMBER; --File.Sql.35 Cbabu   :=pr_new.Last_Update_Login;
                v_delivery_detail_id            NUMBER; --File.Sql.35 Cbabu   :=pr_new.Delivery_Detail_Id;
                v_source_header_id              NUMBER; --File.Sql.35 Cbabu   :=pr_new.Source_Header_Id;
                v_source_line_id                        NUMBER; --File.Sql.35 Cbabu   :=pr_new.Source_Line_Id;
                v_Inventory_Item_Id             NUMBER; --File.Sql.35 Cbabu   :=pr_new.Inventory_Item_Id;
                v_Requested_Quantity_Uom      VARCHAR2(3); --File.Sql.35 Cbabu      :=pr_new.Requested_Quantity_Uom;
                v_org_id                                NUMBER; --File.Sql.35 Cbabu   :=pr_new.ORG_ID;
                v_customer_id                   NUMBER; --File.Sql.35 Cbabu   :=pr_new.CUSTOMER_ID;
                v_source_header_type_id         NUMBER ; --File.Sql.35 Cbabu  :=pr_new.SOURCE_HEADER_TYPE_ID;
                v_subinventory                  VARCHAR2(10); --File.Sql.35 Cbabu :=pr_new.SUBINVENTORY;
                v_released_status                       VARCHAR2(1); --File.Sql.35 Cbabu  :=pr_new.Released_Status;
                v_ordered_quantity              NUMBER; --File.Sql.35 Cbabu   := NVL(pr_new.Requested_Quantity,0);
                v_shipped_quantity              NUMBER; --File.Sql.35 Cbabu   := NVL(pr_new.Shipped_Quantity,0);
                v_Organization_Id               NUMBER ; --File.Sql.35 Cbabu  :=pr_new.Organization_Id;
                v_trading_flag                  VARCHAR2(1);
                  v_status_code                 VARCHAR2(2);
                v_so_lines_count                        NUMBER;
                v_selling_price                 NUMBER;
                v_tax_category_id                       NUMBER(15);
                v_assessable_value              NUMBER;
                v_excise_exempt_type            VARCHAR2(60);
                v_excise_exempt_refno           VARCHAR2(30);
                v_excise_exempt_date            DATE;
                v_quantity                      NUMBER;
                v_picking_tax_lines_count       NUMBER;
                v_tax_amount                    NUMBER;
                v_base_tax_amount               NUMBER;
                v_func_tax_amount               NUMBER;
                v_basic_excise_duty_amount      NUMBER; --File.Sql.35 Cbabu           := 0;
                v_add_excise_duty_amount        NUMBER; --File.Sql.35 Cbabu           := 0;
                v_oth_excise_duty_amount        NUMBER; --File.Sql.35 Cbabu           := 0;
                v_excise_amount                 NUMBER; --File.Sql.35 Cbabu           := 0;
                v_left_shipped_qty              NUMBER; --File.Sql.35 Cbabu   := 0;
                v_rg23d_tax_amount              NUMBER; --File.Sql.35 Cbabu   := 0;
                v_rg23d_base_tax_amount         NUMBER; --File.Sql.35 Cbabu   := 0;
                v_rg23d_func_tax_amount         NUMBER; --File.Sql.35 Cbabu   := 0;
                v_tax_amt                               NUMBER; --File.Sql.35 Cbabu   := 0;
                v_base_tax_amt                  NUMBER; --File.Sql.35 Cbabu   := 0;
                v_func_tax_amt                  NUMBER; --File.Sql.35 Cbabu   := 0;
                v_tot_tax_amount                        NUMBER;
                v_delivery_line_count           NUMBER;
                v_location_id                   NUMBER;
                v_sqlerrm                       VARCHAR2(500);
                v_delivery_id                   NUMBER;
                v_ship_to_org_id                        NUMBER;
                v_bill_to_org_id                        NUMBER;  --bug 8731696
                ln_bill_to_cust_id              NUMBER; --added for bug#8731696
                v_date_confirmed                      DATE;
                counter NUMBER; --File.Sql.35 Cbabu :=0;
         -- Added by subbu
          v_raise_error_flag    VARCHAR2(1);
          v_bonded_flag         VARCHAR2(1);
          v_register_code               VARCHAR2(30);
          v_fin_year            NUMBER;
          v_old_register                JAI_OM_WSH_LINES_ALL.register%TYPE;
          v_old_excise_invoice_no     VARCHAR2(200);
          v_reg_type            VARCHAR2(10);
          v_rg_type                     VARCHAR2(1);
          v_exc_invoice_no      JAI_OM_WSH_LINES_ALL.excise_invoice_no%TYPE;
          v_tot_excise_amt      NUMBER;
          v_tot_basic_ed_amt    NUMBER;
          v_tot_addl_ed_amt     NUMBER;
          v_tot_oth_ed_amt      NUMBER;
          v_pref_rg23a          NUMBER;
          v_pref_rg23c          NUMBER;
          v_pref_pla            NUMBER;
          v_ssi_unit_flag               VARCHAR2(1);
          v_rg23a_balance             NUMBER;
          v_rg23c_balance             NUMBER;
          v_pla_balance         NUMBER;
          v_order_type_id             NUMBER;
          v_excise_flag         VARCHAR2(1);
          v_item_class          JAI_INV_ITM_SETUPS.item_class%TYPE;
          v_modvat_tax_rate     NUMBER;
          v_rounding_factor     NUMBER;
          v_exempt_bal          NUMBER;
          v_basic_ed_amt                NUMBER;
          v_remarks             VARCHAR2(60);
          v_register_balance    NUMBER;
          v_bond_tax_amount     NUMBER;
          v_raise_exempt_flag   VARCHAR2(1);
          v_exe_flag            VARCHAR2(150);
          v_mod_flag            VARCHAR2(150);
          --New Variables Declared by Nagaraj.s for Enh2415656
          v_output NUMBER ;-- By Nagaraj.s to get the output of the function jai_om_wsh_processing_pkg.excise_balance_check
          v_export_oriented_unit JAI_CMN_INVENTORY_ORGS.export_oriented_unit%TYPE;
          v_basic_pla_balance NUMBER;
          v_additional_pla_balance NUMBER;
          v_other_pla_balance NUMBER;
          v_error_message   NUMBER; --This is for Capturing the Error Message
          v_myfilehandle    UTL_FILE.FILE_TYPE; -- This is for File handling
          v_utl_location    VARCHAR2(512);
          v_trip_id       NUMBER;
          v_debug_flag      VARCHAR2(1);  --File.Sql.35 Cbabu  := 'N'; -- Debug flag made to 'N' by arun iyer 12/03/2003 -- bug # 2828927
           --Ends here for Enh2415656
        -- end of addition by subbu

        -- Added by Brathod for Bug#4215808
        ln_vat_assessable_value     JAI_OM_OE_SO_LINES.VAT_ASSESSABLE_VALUE%TYPE;
        lv_vat_exemption_flag       JAI_OM_WSH_LINES_ALL.VAT_EXEMPTION_FLAG%TYPE;
        lv_vat_exemption_type       JAI_OM_WSH_LINES_ALL.VAT_EXEMPTION_TYPE%TYPE;
        ld_vat_exemption_date       JAI_OM_WSH_LINES_ALL.VAT_EXEMPTION_DATE%TYPE;
        lv_vat_exemption_refno      JAI_OM_WSH_LINES_ALL.VAT_EXEMPTION_REFNO%TYPE;
        -- End of Bug#4215808


           CURSOR Get_Status_Cur IS
                SELECT  A.delivery_id,
                        A.confirm_date,
                        A.status_code
                FROM    Wsh_Delivery_Assignments B,
                        Wsh_New_deliveries A
                WHERE   B.Delivery_Id           = A.Delivery_Id
                AND     B.Delivery_Detail_id    = v_delivery_detail_id;
        --Added by GSRI for BUG 2283066
    /* Commented by Brathod for Bug# 4299606 (DFF Elimination)*/
                /* CURSOR get_item_attributes IS
                                SELECT attribute1 ,attribute2
                 FROM  mtl_system_items
                           WHERE inventory_item_id = v_Inventory_Item_Id
                           AND organization_id = v_organization_id;
    End of Bug# 4299606 */
    /* Added by Brathod for Bug# 4299606 */
    CURSOR get_item_attributes IS
                SELECT excise_flag, modvat_flag
                FROM   JAI_INV_ITM_SETUPS
                WHERE  inventory_item_id = v_Inventory_Item_Id
                AND    organization_id = v_organization_id;
    /* End of Bug# 4299606 */

        -- End of Addition
           CURSOR Get_So_Lines_Count_Cur IS
                SELECT  COUNT(*)
                FROM    JAI_OM_OE_SO_LINES
                WHERE   Line_id = v_source_line_id;

           CURSOR Get_So_Lines_Details_Cur IS
                SELECT  NVL(Selling_Price,0),
                                NVL(Quantity,0),
                                NVL(Tax_Category_Id,0),
                                NVL(Assessable_Value,0),
                                NVL(vat_assessable_value,0),
                                Excise_Exempt_Type,
                                Excise_Exempt_Refno,
                                Excise_Exempt_Date,
                                -- Added by Brathod for Bug#4215808
                                vat_exemption_flag,
                                vat_exemption_type,
                                vat_exemption_date,
                                vat_exemption_refno
                                -- End of Bug#4215808
                FROM    JAI_OM_OE_SO_LINES
                WHERE   Line_id = v_source_line_id;
        /*
           Code changed by aiyer for the bug #3139718.
           Added the cursor to details required for currency conversion.
        */

         --Start of #3139718
    /* bug 5243532. Added by Lakshmi Gopalsami
             Removed the reference to cursor sob_cur
             as this is not used anywhere.
         */


         CURSOR get_conv_detail_cur
         IS
         SELECT
                transactional_curr_code                                 ,
                conversion_type_code                                    ,
                conversion_rate                                         ,
                nvl(b.actual_shipment_date,sysdate)   actual_shipment_date
         FROM
                oe_order_headers_all a  ,
                oe_order_lines_all   b
         WHERE
                a.header_id = b.header_id       AND
                b.line_id   = v_source_line_id  AND
                a.header_id = v_source_header_id ;

             v_currency_code    GL_SETS_OF_BOOKS.CURRENCY_CODE%TYPE      ;
             v_set_of_books_id  HR_OPERATING_UNITS.SET_OF_BOOKS_ID%TYPE  ;
             v_conv_type_code   oe_order_headers_all.conversion_type_code%TYPE;
             v_conv_rate        NUMBER;
             v_conv_date        DATE;

             v_curr_conv_rate   NUMBER;

         --End of #3139718

           CURSOR Get_Tax_Lines_Details_Cur IS
                SELECT  b.Tax_Type,
                        NVL(b.Rounding_Factor,2) Rounding_Factor,  --changed the rounding factor to 2 if it is null, JMEENA bug#6280735 (FP 6164922)
                        A.Tax_Line_No,
                        A.Precedence_1,
                        A.Precedence_2,
                        A.Precedence_3,
                        A.Precedence_4,
                        A.Precedence_5,
                        A.Precedence_6, -- CHANGE ON 02/11/2006 BY SACSETHI FOR BUG 5228046
                        A.Precedence_7,
                        A.Precedence_8,
                        A.Precedence_9,
                        A.Precedence_10,
                        A.Tax_Id,
                        A.Tax_Rate,
                        A.Qty_Rate,
                        A.Uom,
                        A.Tax_Amount,
                        A.Base_Tax_Amount,
                        A.Func_Tax_Amount
                FROM    JAI_OM_OE_SO_TAXES A,
                        JAI_CMN_TAXES_ALL b
                WHERE    Line_id = v_source_line_id
                AND     A.Tax_Id = b.Tax_Id
                ORDER BY A.Tax_Line_No;
           CURSOR Pick_Tax_Line_Count_Cur(P_Tax_Id NUMBER) IS
                SELECT  COUNT(*)
                FROM    JAI_OM_WSH_LINE_TAXES
                WHERE   Delivery_Detail_Id = v_delivery_detail_id
                AND     Tax_Id = P_Tax_Id;
           CURSOR Get_Tot_Tax_Amount_Cur IS
                SELECT  SUM(A.Tax_Amount)
                FROM    JAI_OM_WSH_LINE_TAXES A,
                        JAI_CMN_TAXES_ALL b
                WHERE   A.Delivery_Detail_Id = v_delivery_detail_id
                AND     b.Tax_Id = A.Tax_Id
                AND     b.Tax_Type <> 'TDS';
           CURSOR Get_Delivery_Line_Count_Cur IS
                SELECT  COUNT(*)
                FROM    JAI_OM_WSH_LINES_ALL
                WHERE   Delivery_Detail_Id = v_delivery_detail_id;
          CURSOR Location_Cursor IS
                SELECT  NVL(Location_id,0),
                        trading
                FROM    JAI_INV_SUBINV_DTLS
                  WHERE Sub_Inventory_Name      = v_subinventory
                 AND    organization_id         = v_organization_id;
          CURSOR get_ship_to_org_id_cur( p_line_id NUMBER) IS
                SELECT ship_to_org_id, invoice_to_org_id --added invoice_to_org_id for bug#8731696
                FROM    Oe_order_lines_all
                  WHERE line_id = p_line_id;

          --added the cursor for bug#8731696
          Cursor cur_get_bill_to_cust_id (cp_site_use_id IN NUMBER)
          IS
            SELECT customer_id
            FROM   oe_invoice_to_orgs_v
            WHERE  site_use_id = cp_site_use_id;

          CURSOR rg23d_amount_cur(p_tax_id NUMBER) IS
          SELECT        nvl(sum(tax_amount),0)     ,
                        nvl(sum(base_tax_amount),0),
                        nvl(sum(func_tax_amount),0)
          FROM
                        JAI_CMN_MATCH_TAXES
          WHERE
                        ref_line_id     = v_delivery_detail_id          AND
                        receipt_id      IS NOT NULL                     AND
                        tax_id          = p_tax_id;

          CURSOR ed_cur (p_tax_type VARCHAR2)IS
          -- SELECT     SUM(NVL(A.func_tax_amount,0))
          SELECT
                        nvl(sum(a.func_tax_amount),0)           -- cbabu for Bug# 2736191
          FROM
                        JAI_CMN_MATCH_TAXES     a,
                        JAI_CMN_TAXES_ALL                 b
          WHERE
                        a.tax_id        = b.tax_id                      AND
                        b.tax_type      = p_tax_type                    AND
                        A.ref_line_id   = v_delivery_detail_id          AND
                        A.receipt_id    IS NOT NULL;

          CURSOR        ja_in_so_picking_exc_check(p_delivery_id NUMBER)  IS
          SELECT        DISTINCT register
          FROM          JAI_OM_WSH_LINES_ALL
          WHERE         delivery_id = p_delivery_id;

        --2001/07/10 Anuradha Parthasarathy
          CURSOR        item_trading_cur IS
          SELECT
                    item_trading_flag
          FROM
                    JAI_INV_ITM_SETUPS
          WHERE
                    organization_id   = v_organization_id AND
                    inventory_item_id = v_inventory_item_id;

          v_item_trading_flag                   VARCHAR2(1);

        --2001/10/03 Anuradha Parthasarathy
          CURSOR        uom_code IS
          SELECT        order_quantity_uom
          FROM  oe_order_lines_all
          WHERE line_id = v_source_line_id;
          v_order_quantity_uom                  VARCHAR2(3);
          v_conversion_rate                     NUMBER; --File.Sql.35 Cbabu := 0;
        --2001/12/20
          CURSOR        Trading_register_code_cur(
                                                        p_organization_id       NUMBER,
                                                        p_location_id           NUMBER,
                                                        p_delivery_detail_id    NUMBER,
                                                        p_order_type_id         NUMBER
                                                 ) IS
          SELECT
                a.register_code
          FROM
                JAI_OM_OE_BOND_REG_HDRS a,
                JAI_OM_OE_BOND_REG_DTLS b
          WHERE
                A.organization_id       = p_organization_id             AND
                A.location_id           = p_location_id                 AND
                A.register_id           = b.register_id                 AND
                b.order_flag            = 'Y'                           AND
                b.order_type_id         = p_order_type_id               AND
                A.register_code         LIKE '23D%';

                v_trad_register_code                  VARCHAR2(30);

           /*
            Code added by aiyer for the bug 3844145.
            Removed the group by subinventory clause from the query. The matched qty should be considered irrespective of the
            subinventory
           */

          CURSOR matched_receipt_cur1 IS
          SELECT

                sum(a.quantity_applied) quantity_applied
          FROM
                JAI_CMN_MATCH_RECEIPTS a
          WHERE
                a.ref_line_id = v_delivery_detail_id;

          v_matched_qty                 NUMBER; --File.Sql.35 Cbabu  := 0;
        --------------------------------------------------------------
        -- start of cursors for checking RG balances by subbu
           CURSOR get_item_dtls (p_organization_id NUMBER,p_item_id NUMBER) IS
                   SELECT
                         excise_flag,
                         item_class
                   FROM
                         JAI_INV_ITM_SETUPS
                   WHERE
                         organization_id   = p_organization_id AND
                         inventory_item_id = p_item_id;

           CURSOR bonded_cur(p_organization_id NUMBER, p_subinventory VARCHAR2) IS
                SELECT NVL(A.bonded,'Y') bonded
                FROM JAI_INV_SUBINV_DTLS A
                WHERE A.sub_inventory_name = p_subinventory
                AND A.organization_id = p_organization_id;
           CURSOR register_code_cur(p_organization_id NUMBER, p_location_id NUMBER, p_order_type_id NUMBER) IS
                SELECT A.register_code
                FROM JAI_OM_OE_BOND_REG_HDRS A, JAI_OM_OE_BOND_REG_DTLS b
                WHERE A.organization_id = p_organization_id
                AND A.location_id = p_location_id
                AND A.register_id = b.register_id
                AND b.order_flag         = 'Y'
                AND b.order_type_id = p_order_type_id ;
           CURSOR fin_year_cur(p_organization_id IN NUMBER) IS
                SELECT MAX(A.fin_year)
                FROM   JAI_CMN_FIN_YEARS A
                WHERE  organization_id = p_organization_id
                AND fin_active_flag = 'Y';
           CURSOR pref_cur(p_organization_id NUMBER, p_location_id NUMBER)IS
           --This is included in the select by Nagaraj.s for Enh2415656
                SELECT pref_rg23a, pref_rg23c, pref_pla,
                NVL(Export_oriented_unit ,'N')
                FROM JAI_CMN_INVENTORY_ORGS
                WHERE organization_id = p_organization_id
                AND location_id = p_location_id ;
                --This is included in the select by Nagaraj.s for Enh2415656
           CURSOR rg_bal_cur(p_organization_id NUMBER, p_location_id NUMBER)IS
                SELECT NVL(rg23a_balance,0) rg23a_balance ,NVL(rg23c_balance,0) rg23c_balance,NVL(pla_balance,0) pla_balance,
                NVL(basic_pla_balance,0) basic_pla_balance,
                NVL(additional_pla_balance,0) additional_pla_balance,
                NVL(other_pla_balance,0) other_pla_balance
                FROM JAI_CMN_RG_BALANCES
                WHERE organization_id = p_organization_id
                AND location_id = p_location_id ;
           CURSOR ssi_unit_flag_cur(p_organization_id NUMBER, p_location_id NUMBER) IS
                SELECT ssi_unit_flag
                FROM   JAI_CMN_INVENTORY_ORGS
                WHERE  organization_id = p_organization_id
                AND    location_id     = p_location_id;
           CURSOR  register_balance_cur(p_organization_id NUMBER,p_location_id NUMBER) IS
                SELECT  register_balance
                FROM  JAI_OM_OE_BOND_TRXS
                WHERE  transaction_id = (SELECT MAX(A.transaction_id)
                                FROM   JAI_OM_OE_BOND_TRXS A, JAI_OM_OE_BOND_REG_HDRS B
                                WHERE  A.register_id = B.register_id
                                AND    B.organization_id = p_organization_id
                                AND    B.location_id = p_location_id );
           CURSOR Get_Tax_Lines_Details_Cur1 IS
                SELECT  A.Tax_Rate, NVL(b.Rounding_Factor,0) Rounding_Factor
                FROM    JAI_OM_OE_SO_TAXES A, JAI_CMN_TAXES_ALL b
                WHERE    Line_id = v_source_line_id
                AND     A.Tax_Id = b.Tax_Id
                AND     b.tax_type = 'Modvat Recovery'
                ORDER BY A.Tax_Line_No;
           CURSOR for_modvat_percentage(p_organization_id NUMBER, p_location_id NUMBER) IS
                  SELECT MODVAT_REVERSE_PERCENT
                  FROM   JAI_CMN_INVENTORY_ORGS
                  WHERE  organization_id = p_organization_id
                  AND   ( location_id  = p_location_id
              OR
              location_id  is NULL AND  p_location_id is NULL); /* Modified by Ramananda for removal of SQL LITERALs */
                  --AND NVL(location_id,0) = NVL(p_location_id,0);

                  -- end of cursors for checking RG balances by subbu
                  -- following cursors added by sriram bug# 2165355

                  CURSOR  C_CHECK_LC_ORDER IS
                  SELECT  LC_FLAG
                  FROM    JAI_OM_OE_SO_LINES
                  WHERE   LC_FLAG = 'Y' AND
                  HEADER_ID = pr_new.SOURCE_HEADER_ID;

                  CURSOR C_MATCHED_QTY_CUR IS
                  SELECT SUM(QTY_MATCHED)
                  FROM   JAI_OM_LC_MATCHINGS
                  WHERE  ORDER_HEADER_ID = pr_new.SOURCE_HEADER_ID
                 -- AND    ORDER_LINE_ID = pr_new.SOURCE_LINE_ID   --commented by csahoo for bug#5680459
                  AND    delivery_detail_id = pr_new.delivery_detail_id -- bug# 3541960
                  AND    RELEASE_FLAG IS NULL;
                  v_check_lc_order   VARCHAR2(1);
          v_lc_qty_matched   NUMBER;
          v_lc_shipped_qty       NUMBER;  --File.Sql.35 Cbabu  := pr_new.Shipped_quantity;
                  -- ends here additions bug sriram bug# 2165355

          /* Start, csahoo for bug#5680459
            following code is to correct the existing lc_matching order line to new split line id
          */
          cursor c_order_line is
            select split_from_line_id --, split_by
            from oe_order_lines_all
            where line_id = pr_new.source_line_id;

          cursor c_lc_mtch_dlry_line is
            select order_line_id
            from JAI_OM_LC_MATCHINGS
            where delivery_detail_id = pr_new.delivery_detail_id;
          r_order_line          c_order_line%rowtype;
          r_lc_mtch_dlry_line   c_lc_mtch_dlry_line%rowtype;
          ln_lc_update_cnt      number;
          /* end csahoo for bug#5680459 */


          -- start additions by sriram - bug # 3021588
          v_asst_register_id Number;
          v_reg_exp_date     Date;
          v_lou_flag         Varchar2(1);

          CURSOR    c_cess_amount (cp_delivery_id JAI_OM_WSH_LINES_ALL.DELIVERY_ID%TYPE) IS
          SELECT    nvl(sum(jsptl.func_tax_amount),0)  tax_amount
          FROM      JAI_OM_WSH_LINE_TAXES jsptl ,
                    JAI_CMN_TAXES_ALL            jtc
          WHERE     jtc.tax_id  =  jsptl.tax_id
          AND       delivery_detail_id in
          (SELECT   delivery_detail_id
           FROM     JAI_OM_WSH_LINES_ALL
           WHERE    delivery_id = cp_delivery_id
          )
          AND       upper(jtc.tax_type) in (upper(jai_constants.tax_type_cvd_edu_cess), upper(jai_constants.tax_type_exc_edu_cess));


          -- start, Bgowrava for forward porting bug#5989740

              ln_sh_cess_amount     JAI_CMN_RG_OTHERS.DEBIT%TYPE;
                            /* Cursor is responsible to get secondary and higher cess */

             CURSOR    c_sh_cess_amount (cp_delivery_id JAI_OM_WSH_LINES_ALL.DELIVERY_ID%TYPE) IS
             SELECT    nvl(sum(jsptl.func_tax_amount),0)  tax_amount
             FROM      JAI_OM_WSH_LINE_TAXES jsptl ,
                       JAI_CMN_TAXES_ALL jtc
             WHERE     jtc.tax_id  =  jsptl.tax_id
             AND       delivery_detail_id in
             (SELECT   delivery_detail_id
              FROM     JAI_OM_WSH_LINES_ALL
              WHERE    delivery_id = cp_delivery_id
             )
             AND       upper(jtc.tax_type) in (upper(jai_constants.tax_type_sh_exc_edu_cess),
                upper(jai_constants.tax_type_sh_cvd_edu_cess)
               );
          -- end, Bgowrava for forward porting bug#5989740


          ln_cess_amount     JAI_CMN_RG_OTHERS.DEBIT%TYPE;
          lv_process_flag    VARCHAR2(5);
          lv_process_message VARCHAR2(1996);


          -- Added by brathod for Bug#4215808

           ln_vat_cnt      NUMBER DEFAULT 0 ;
           ln_vat_proc_cnt NUMBER DEFAULT 0 ;
           ln_regime_id  JAI_RGM_ORG_REGNS_V.REGIME_ID%TYPE;
           lv_regns_num  JAI_RGM_ORG_REGNS_V.ATTRIBUTE_VALUE%TYPE;

           CURSOR cur_chk_vat_exists  (cp_del_det_id JAI_OM_WSH_LINES_ALL.DELIVERY_DETAIL_ID%TYPE)
           IS
           SELECT 1
           FROM   JAI_OM_WSH_LINE_TAXES  jsptl,
                  JAI_CMN_TAXES_ALL             jtc
                  , jai_regime_tax_types_v    tax_types
           WHERE  jsptl.delivery_detail_id = cp_del_det_id
           AND    jtc.tax_id            = jsptl.tax_id
           AND    jtc.tax_type          = tax_types.tax_type
           AND    tax_types.regime_code = jai_constants.vat_regime;

           CURSOR cur_get_regime_info (cp_organization_id JAI_RGM_ORG_REGNS_V.ORGANIZATION_ID%TYPE ,
                                       cp_location_id     JAI_RGM_ORG_REGNS_V.LOCATION_ID%TYPE
                                      )
           IS
           SELECT regime_id,
                  attribute_value
           FROM   JAI_RGM_ORG_REGNS_V orrg
           WHERE  orrg.organization_id    =  cp_organization_id
           AND    orrg.location_id        =  cp_location_id
           AND    attribute_type_code     =  jai_constants.rgm_attr_type_code_primary
           AND    attribute_code          =  jai_constants.attr_code_regn_no
           AND    regime_code             =  jai_constants.vat_regime;

          CURSOR cur_chk_vat_proc_entry (cp_delivery_id JAI_OM_WSH_LINES_ALL.DELIVERY_ID%TYPE)
          IS
          SELECT 1
          FROM   JAI_RGM_INVOICE_GEN_T
          WHERE  delivery_id =  cp_delivery_id;

          -- End of Bug#4215808

          /*
          || Added by csahoo for bug#5680459
          || Check if only 'VAT REVERSAL' tax type is present in JAI_OM_WSH_LINE_TAXES
          */
          CURSOR c_chk_vat_reversal (cp_del_det_id JAI_OM_WSH_LINES_ALL.delivery_detail_id%TYPE,
                                     cp_tax_type JAI_CMN_TAXES_ALL.tax_type%TYPE )
           IS
           SELECT 1
           FROM   JAI_OM_WSH_LINE_TAXES  jsptl,
                  JAI_CMN_TAXES_ALL             jtc
           WHERE  jsptl.delivery_detail_id = cp_del_det_id
           AND    jtc.tax_id               = jsptl.tax_id
           AND    jtc.tax_type             = cp_tax_type ;

          ln_vat_reversal_exists  NUMBER ;
          lv_vat_reversal         VARCHAR2(100);
          lv_vat_invoice_no       VARCHAR2(10);
          lv_vat_inv_gen_status   VARCHAR2(10);
          --bug#5680459, ends


         /** Bgowrava for forward porting Bug#5631784 */
  ln_tcs_exists             number;
  --lv_process_flag           jai_constants.successful%type;
  ln_threshold_tax_cat_id   jai_ap_tds_thhold_taxes.tax_category_id%type;
  ln_tcs_regime_id          JAI_RGM_DEFINITIONS.regime_id%type;
  ln_threshold_slab_id      jai_ap_tds_thhold_slabs.threshold_slab_id%type;
  ln_last_line_no           number;
  ln_base_line_no           number;
  lv_context                varchar2(240);
  ln_reg_id                 number;

  CURSOR C_GET_REGIME_ID (CP_REGIME_CODE    JAI_RGM_DEFINITIONS.REGIME_CODE%TYPE)
  IS
  SELECT REGIME_ID
  FROM   JAI_RGM_DEFINITIONS
  WHERE  REGIME_CODE = CP_REGIME_CODE;

  /** Check if taxes with taxType as defined in the regime setup exists for given regime code */
  CURSOR C_CHK_RGM_TAX_EXISTS  ( CP_REGIME_CODE          JAI_RGM_DEFINITIONS.REGIME_CODE%TYPE
           , CP_DELIVERY_DETAIL_ID   JAI_OM_WSH_LINE_TAXES.DELIVERY_DETAIL_ID%TYPE
           )
  IS
  SELECT  COUNT(1)
  FROM    JAI_REGIME_TAX_TYPES_V JRTTV
      , JAI_OM_WSH_LINE_TAXES  JSPT
      , JAI_CMN_TAXES_ALL JTC
  WHERE   JTC.TAX_ID     = JSPT.TAX_ID
  AND     JTC.TAX_TYPE  = JRTTV.TAX_TYPE
  AND     REGIME_CODE    = CP_REGIME_CODE
  AND     JSPT.DELIVERY_DETAIL_ID = CP_DELIVERY_DETAIL_ID;

        /** End of Bug#5631784 **/



    /* Bug 5243532. Added by Lakshmi Gopalsami
       Implemented caching logic.
          */
    l_func_curr_det jai_plsql_cache_pkg.func_curr_details;


  BEGIN
    pv_return_code := jai_constants.successful ;
    /*------------------------------------------------------------------------------------------
FILENAME: JA_IN_WSH_DLRY_DTLS_AU_TRG.sql  CHANGE HISTORY:
SlNo.  DD/MM/YYYY       Author and Details of Modifications
------------------------------------------------------------------------------------------
1      19/12/2000       MANOHAR MISHRA
                           nvl function added to v_location_id

2      31/05/2001       Anuradha Parthasarathy
                           Code added to return in case of qty shipped is zero

3      08/06/2001       Anuradha Parthasarathy
                           Code added for correct tax insertions in case of trading orders.

4      23/06/2001       Anuradha Parthasarathy
                           nvl function to v_location_id commented,because this is a necessary setup.

5      10/07/2001       Anuradha Parthasarathy
                           Taxes should be picked from ja_in_rg23d_shipping_taxes only when a trading item is transacted
                           from a trading subinventory.

6      03/10/2001   Anuradha Parthasarathy
                           Tax Calculation as per the Inventory Uom

7      08/05/2002       Sriram SJ Bug # 2330055
                            Insert of non zero selling price and assessable value in  JAI_OM_WSH_LINES_ALL even though
                            tax lines are not there.

8      03/07/2002       Nagaraj.s - For Enh#2415656.
                             Cursors pref_cur - Incorporated v_export_oriented_unit also in the select clause
                            RG Bal Cur- Incorporated basic,additional,other pla balance also in the select clause.
                            Functions jai_om_wsh_processing_pkg.excise_balance_check - for preference checks in case of EOU and Non-EOU for total excise amount
                            jai_om_wsh_pkg.get_excise_register_with_bal - for preference checks in case of EOU and Non-EOU
                            for exempted amount.
                            Before sending this patch it has to be taken care that, the alter scripts,functions should also
                            accompany the patch otherwise the patch would certainly fail.

9      24/08/2002       Sriram SJ bug # 2531013
                            Made the changes , to take care as to when the backordering functionality should be allowed.

10     01/11/2002       Sriram - Bug # 2165355
                            LC Functionality. Added the Lc checks.

11     13/12/2002       Sriram - Bug # 2689417 - File Version 615.3
                             Changed  the WHEN clause in the trigger because after the ONT Patchset 'G'
                             OM interface executes first and then Inventory interface . If the inventory interface
                             errors out due to some reason other than Localization issue , then the line information
                             is carried over to AR , but the taxes are not present in Shiping Localization tables ,
                             causing lot of Data fix requirements.

12     09/01/2003       cbabu for Bug# 2736191 - File Version# 615.4
                              For trading functionality JAI_OM_WSH_LINES_ALL.excise_amount is getting populated NULL always, if one
                              of 'Excise', 'Addl. Excise', 'Other Excise' tax components is missing. ED_CUR cursor is modified to fetch
                              0 if query does not retreive any data.

13.   12/03/2003        Arun Iyer  Bug # 2828927 615.5
                              v_Debug_flag = 'Y' was causing problems owing to reasons such as /usr/tmp folder etc.
                              Hence making it 'N' .

14.   24/07/2003       Aiyer  Bug #3032569, File Version 616.1

                          Issue:-
                              The trigger validates that the match receipt functionality is performed in scenario's where an order is associated
                              to bond registers - 'Trading Domestic Without Excise' and 'Export Without Excise'.
                              This check is not required. The match receipts only needs to be done for
                              'Trading Domestic With Excise' and 'Export with Excise' type of Scenario's

                          Solution:-
                               Modified the IF statment to raise an error only when trading register code is in 23D_DOMESTIC_EXCISE and
                               23D_EXPORT_EXCISE.
                               The other two trading register_codes '23D_DOM_WITHOUT_EXCISE' and '23D_EXPORT_WITHOUT_EXCISE' have
                               been removed as matched receipts is not relevant in this case.

                          Fix of bug #2988829 along with the current bug
                          ----------------------------------------------
                          Issue:-
                           Initial code used to check that if the organization is a Trading organization,item is tradable and excisable
                           then used to assume that a match receipt has been done and get the sum (tax_amount), sum(base_tax_amount),
                           sum(func_tax_amount) for a delivery_detail_id and tax_id from the JAI_CMN_MATCH_TAXES table and
                           populate this into the tax_amount, base_tax_amount and func_tax_amount columns of the table
                           JAI_OM_WSH_LINE_TAXES.

                           This approach used to fail, as many a times a record never used to exists in the JAI_CMN_MATCH_TAXES table
                           for the delivery_detail_id and tax_id even though the organization is declared as a trading organization,
                           Item is tradable and excisable.

                           This happens in scenario's where an order assigned to a Bond register_type is either 'Trading domestic without excise' or
                           'Export Without Excise', the match receipt functionaity would not be performed by client and consequently no
                           data gets populated in JAI_CMN_MATCH_TAXES.

                          Solution: -
                            Added the additional check :-
                            v_trad_register_code IN ( '23D_DOMESTIC_EXCISE','23D_EXPORT_EXCISE') .
                            is all the above cases.
                            With this the check becomes that if a organization is trdable, item is tradable , excisable and the order
                            associated to the bond register is Trading Domestic With Excise and Export With Excise only then
                            it can be assumed that there would be data in table JAI_CMN_MATCH_TAXES (Match receipts has been performed).
                            In such a case take the tax_amoutn ,base_tax_amount and func_tax_amoutn for the above table.
                            Else take it from JAI_OM_OE_SO_LINES and JAI_OM_OE_SO_TAXES table.


                          Dependency Introduced Due to this Bug : -
                            None

15. 22/08/2003           Bug # 3021588 (Bond Register Enhancement) Version 616.2

                           For Multiple Bond Register Enhancement,
                           Instead of using the cursors for fetching the register associated with the order type , a call has been made to the procedures
                           of the jai_cmn_bond_register_pkg package. There enhancement has created dependency because of the
                           introduction of 3 new columns in the JAI_OM_OE_BOND_REG_HDRS table and also call to the new package jai_cmn_bond_register_pkg.

                           New Validations for checking the bond expiry date and to check the balance based on the call to the jai_cmn_bond_register_pkg has been added

                           Provision for letter of undertaking has been incorporated. Letter of undetaking is also a type of bond register but without validation for the balances.
                           This has been done by checking if the LOU_FLAG is 'Y' in the JAI_OM_OE_BOND_REG_HDRS table for the
                           associated register id , if yes , then validation is only based on bond expiry date .

                           This fix has introduced huge dependency . All future changes in this object should have this bug as a prereq


16.17/09/2003          Bug #3148621   File Version : 616.3

                       For a trading organization , none of the  taxes were proportioned based on the split quantity ,
                       The tax amount in the sales order is applied as it is to each of the split portions causing these tax amounts to be duplicated many times.

                       As per the requirement , all taxes other than excisable taxes need to be proportioned based on split quantity , as excise taxes will be picked from receipt against which this shipment is done.

                       This issue has been resolved by adding a check that tax amount should be proportionally calculated based on quantity shipped for all non-excise taxes.


17.24/09/2003    Aiyer Bug #3139718 File Version : 616.4

                          Added the cursor get_conv_detail_cur to get the actual_shipment_date from oe_order_lines_all instead of the
                          conversion_date from oe_order_headers_all.
                          As a sales order shipment date can be different from its creation date, hence the conversion rate
                          applicable on the date of shipment should be considerd for all processing rather than the creation
                          date of the Sales order.
        Added the procedure call jai_cmn_utils_pkg.currency_conversion to calculated the currency conversion rate.
        Also changed the population logic of v_func_tax_amt variable, such that
        during shipping the functional tax amount gets recalculated from the tax_amount column in JAI_OM_OE_SO_TAXES
                          and hence logic is ->
        v_func_tax_amt = v_tax_amt * nvl((v_curr_conv_rate ,1)

                        Fix Of Bug#3158282:-
                         Issue:-
                          In case of non INR type of transactions with Excise type of tax the rounding precision should be maintained at 0
                          and in all other cases the rounding factor should be picked up from JAI_CMN_TAXES_ALL.

                         Solution:-
                          Modified the rounding factor to reflect the above scenario. variable v_func_tax_amount gets
                          rounded of to zero in case of non INR type of transactions ( v_curr_conv_rate <> 1) with Excise type of tax
                          and for all other cases rounding precession is picked up from JAI_CMN_TAXES_ALL table.

                          Dependency Introduced Due to this Bug : -
                            None

18. 21/01/2004  ssumaith bug # 3390174   618.1

                Issue :- In a trading organzation , when match receipts is done, taxes which are
                         dependent on adhoc excise taxes was not getting recalculated based on the
                         value of the excise tax retreived from matching.

                         This issue has been resolved by commenting out the condition which is
                         documented by this bug number.

19.31/03/2004  ssumaith - bug# 3541960  file version 619.1

               Issue :-   when an lc enabled order is split and shipped , interface trip stop was going into error.
                          The reason for this error is because for a delivery , the sum of matched quantity in the
                          JAI_OM_LC_MATCHINGS table is compared to the quantity shipped for the  delivery detail id being processed.

               Solution :- This issue is solved by comparing the delivery_detail_id also when getting the matched quantity.
                           By including the delivery detail in the where clause , ensuring that in case of split orders
                           also the shipment can go through without any errors.

                           code change has been done in the cursor - c_matched_qty_cur


20.04/05/2004 ssumaith - bug# 3609172 file version 619.2

              issue    :-   In a trading scenario, when matching happens post split of a delivery either intentionally
                            or due to lot controls , the non-excise taxes are getting incorrectly calculated.
                            Analysis is that post split when matching happens, there are sets of tax records for each split
                            in the delivery.When this trigger processess the delivery detail , it again apportions based
                            on the quantity causing the taxes to be calculated as less than that of the actual value

              Solution :-   Issue has been resolved by doing the following :
                            The apportion based on quantity shipped has been removed and instead the tax amount from
                            the JAI_CMN_MATCH_TAXES table is used for population into JAI_OM_WSH_LINES_ALL
                            and jain_so_picking_tax_lines table

              Dependency : None

21.23/08/2004  Aiyer - bug# 3844145 file version 115.1
                 Issue:-
                   The inventory trip stop concurrent program errors out for a Internal sales order with qty being matched to two different subinventories.

                 Reason :-
                   The existing code was considering matched quantites as per the subinventories. This should not be considered.
                   Matched quantities should be considered irrespective of the subinventories.

        Solution:-
          Modified the cursor matched_receipt_cur1 in the current trigger.Removed the group by subinventory clause from the query.

                Dependency Introduced Due to this Bug : -
                  None


22. 29/Nov/2004  Aiyer for bug#4035566. Version#115.2
                  Issue:-
                  The trigger should not get fired when the  non-INR based set of books is attached to the current operating unit
                  where transaction is being done.

                  Fix:-
                  Function jai_cmn_utils_pkg.check_jai_exists is being called which returns the TRUE if the currency is INR and FALSE if the currency is
                  NON-INR

                  Dependency Due to this Bug:-
                  The current trigger becomes dependent on the function jai_cmn_utils_pkg.check_jai_exists version 115.0 introduced through the bug 4033992


23.  2005/02/11    ssumaith - bug# 4171272 - File version 115.3

                     Shipment needs to be stopped if education cess is not available.

                     The basic business logic validation is that both cess and excise should be available as
                     part of the same register type and the precedence setup at the organization additional information
                     needs to be considered for picking up the correct register order.

                     This code object calls the functions ja_in_exc_balance_amt_f and ja_in_exc_exempt_balance_amt_f
                     which have had changes in their signature and hence the caller also needs to pass the correct
                     parameters.

                     The change done in this object is to pass the additional parameters correctly to the functions.

                  Dependency Due to this Bug:-
                    The current trigger becomes dependent on the functions jai_om_wsh_processing_pkg.excise_balance_check (version 115.1) and
                    jai_om_wsh_pkg.get_excise_register_with_bal (version 115.1) also packaged as part of this bug.

23.  2005/03/15    brathod - Bug#4215808- File version 115.5
                   Trigger modified for VAT Implementation.
                   New VAT fields in JAI_OM_WSH_LINES_ALL are populated by fetching them
                   from JAI_OM_OE_SO_LINES table.  Also populated jai_vat_preocessing_t temporery
                   table for VAT invoice number generation

24  26/04/2005     Brathod for Bug# 4299606 File Version 116.1
                   Issue:-
       Item DFF Elimination
       Fix:-
       Changed the code that references attributeN (where N=1,2,3,4,5,15) of
       mtl_system_items to corrosponding columns in JAI_INV_ITM_SETUPS

       Dependency :-
        IN60106 + 4239736  (Service Tax) + 4245089  (VAT)

25    08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old
                    DB Entity as required for CASE COMPLAINCE.  Version 116.1

26. 13-Jun-2005    File Version: 116.2
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done

27  30/Jan/2007    bgowrava, forward porting Bug#5631784 (4742259) - File Version 116.2
                  Modified the trigger for TCS Enahancement.
                  Changes are made to support following functionalities required for TCS
                  1.  Whenver a Sales Order has TCS type of tax, depending upon the setup done for threshold
                      Surcharge type of taxes needs to be defaulted at the time of shipping
                        The following are the logical steps
                        a.  Check if tcs type of taxes exists
                        b.  If yes,  check the current threshold slab
                        c.  If threshold up (not null threshold_slab_id) then derrive the tax_category_id attached
                            in the threshold setup for the slab
                        d.  Based on the tax category (p_threshold_tax_cat_id) defaul the additional taxes by calling
                            JAI_RGM_THHOLD_PROC_PKG.DEFAULT_THHOLD_TAXES
                        e.  Added the call to jai_ar_tcs_rep_pkg.wsh_interim_accounting to do the interim accounting for TCS type of taxes.

28. 16/Apr/2007   Bgowrava for forward porting bug#5989740 11i Bug#5907436 - File version
                  ENH : HANDLING SECONDARY AND HIGHER EDUCATION CESS
                  additional cess of 1% on all taxes to be levied to fund secondary education and higher
                  education .
                  Changes - -
                              Object Type             Object Name            Changes
                              -----------------------------------------------------------------------
                               Cursor                  c_sh_cess_amount        Cursor is added to get cess amount for seconday and higher cess

                  Code is added to check balances for secondary and higher educat

29.  17/May/2007  CSahoo for bug 5680459, File Version 120.5
                  Forward porting of 11i BUG#5645003
                  modified the cursor c_matched_qty_cur to filter the data only by delivery_detail_id
                       and order header_id and removed the filter by order line_id
                  Added the cursors c_order_line and c_lc_mtch_dlry_line, to check if the order line attached
                  the delivery detail in LC matching table is same or not. If not, then the related delivery_detail
                  line is updated with the pr_new.source_line_id
                  Added the cursors c_chk_vat_reversal.
                  modified the code in ARU_T3

30    09/10/2007    ssumaith - bug#6487667 - File version - 120.6

                    When comparing the register balance, the amount in INR is not compared. Instead the amount in the Fc is compared.
                    This has been corrected by multiplying the v_tot_excise_amt with the currency conversion factor.

31.   16/10/2007    CSahoo for bug#6498072, File Version 120.8
                    Modified the p_assessable_value parameter during call to JAI_RGM_THHOLD_PROC_PKG.DEFAULT_THHOLD_TAXES
                    p_assessable_value => nvl(v_assessable_value * v_shipped_quantity, 0)
                    Moved cursor uom_code to the start of the loop to fetch v_order_quantity_uom

32.   16/10/2008    CSahoo for bug#5189432, File Version 120.9.12010000.2
                    Assigned the sysdate to the variable v_creation_date instead of pr_new.creation_date

33.   13/11/2008    JMEENA for bug#6280735( FP6164922)
                    Issue:WRONG EXCISE DUTY PASSED TO DELY WHILE MATCHING RG23D REGISTER.
                    Fix: 1. The issue was beacuse a conversion factor was getting multiplied to the tax amount while matching.
                         Hence the excise duty reflected was wrong. so while matching the receipts the conversion factor should be 1
                         and for other cases it should be as it is.  Thus modified the code for the same.
                         assigned the v_conversion_rate to 1 in case of matching and for
                         manufacturing organization Inv_Convert.inv_um_conversion should be executed. so included this logic in the else part.
                         2. Modified the Get_Tax_Lines_Details_Cur cursor. changed the rounding factor to 2 when the
                         rounding factor is null.

34    14-May-2009   CSahoo for bug#8500697, File Version 120.9.12010000.4, 120.9.12010000.5
                    Forward ported the changes done for bug#5199329 in 11i.
                    Added the code to populate the locattion_id in case it is null.
                    Further modified the procedure ARU_T2. Added a check the if it a non inventory item, then
                    the error should not be shown.

35    16-Apr-2010   modified by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement).
                    modified population logic of table jai_om_wsh_lines_all to populate column
                    shippable_flag as 'Y'.
                    File Version: 120.9.12010000.12

36    28-Apr-2010   modified by Allen Yang for bug 9666476
                    logic of shippable_flag population is changed back. For shippable lines,
                    shippable_flag will be still populated with NULL.

37    07-Jun-2010   Modified by Jia for bug#9736876
                    Issue: TAXES POSTED TO PLA IN FOREIGN CURRENCY
                     Fix: If conversion rate is not defined on ship confirm, and when Entered Currency is not equal to Functional Currency
                         giving an warning in the "Interface Trip Stop" concurrent saying "Currency Conversion on shipment date not setup".

Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )

----------------------------------------------------------------------------------------------------------------------------------------------------
Current Version       Current Bug    Dependent           Files          Version          Author   Date         Remarks
Of File                              On Bug/Patchset    Dependent On
ja_in_wsh_dlry_dtls_au_trg.sql
----------------------------------------------------------------------------------------------------------------------------------------------------
616.2                  3021588       IN60104D1 +                                         ssumaith  22/08/2003   Bond Register Enhancement
                                     2801751   +
                                     2769440

115.2                  4035566       IN60105D2 +
                                     4033992           ja_in_util_pkg_s.sql  115.0     Aiyer    29-Nov-2004   Call to this function.
                                                       ja_in_util_pkg_b.sql  115.0
115.3                  4171272      IN60106 +
                                    4147608            ja_in_exc_exempt_balance_amt_f.sql 115.1 ssumaith  11/02/2005    New parameters added to function.
                                                       ja_in_exc_balance_amt_f.sql        115.1 ssumaith  11/02/2005    New parameters added to function.

115.5                  4215808      IN60106            All VAT Objects
                                    +4245089

------------------------------------------------------------------------------------------------------------------------------------------------*/

  --File.Sql.35 Cbabu
  v_creation_date              := sysdate;    -- replaced pr_new.Creation_Date by sysdate for bug#5189432
  v_created_by                 :=pr_new.Created_By;
  v_last_update_date           :=pr_new.Last_Update_Date;
  v_last_updated_by            :=pr_new.Last_Updated_By;
  v_last_update_login          :=pr_new.Last_Update_Login;
  v_delivery_detail_id         :=pr_new.Delivery_Detail_Id;
  v_source_header_id           :=pr_new.Source_Header_Id;
  v_source_line_id             :=pr_new.Source_Line_Id;
  v_Inventory_Item_Id          :=pr_new.Inventory_Item_Id;
  v_Requested_Quantity_Uom     :=pr_new.Requested_Quantity_Uom;
  v_org_id                     :=pr_new.ORG_ID;
  v_customer_id                :=pr_new.CUSTOMER_ID;
  v_source_header_type_id      :=pr_new.SOURCE_HEADER_TYPE_ID;
  v_subinventory               :=pr_new.SUBINVENTORY;
  v_released_status            :=pr_new.Released_Status;
  v_ordered_quantity           := NVL(pr_new.Requested_Quantity,0);
  v_shipped_quantity           := NVL(pr_new.Shipped_Quantity,0);
  v_Organization_Id            :=pr_new.Organization_Id;
  v_basic_excise_duty_amount   := 0;
  v_add_excise_duty_amount     := 0;
  v_oth_excise_duty_amount     := 0;
  v_excise_amount              := 0;
  v_left_shipped_qty           := 0;
  v_rg23d_tax_amount           := 0;
  v_rg23d_base_tax_amount      := 0;
  v_rg23d_func_tax_amount      := 0;
  v_tax_amt                    := 0;
  v_base_tax_amt               := 0;
  v_func_tax_amt               := 0;
  counter                       :=0;
  v_debug_flag                  := jai_constants.no;
  v_conversion_rate             := 0;
  v_matched_qty                 := 0;
  v_lc_shipped_qty              := pr_new.Shipped_quantity;


  IF v_debug_flag ='Y' THEN
    BEGIN
    pv_return_code := jai_constants.successful ;
     SELECT DECODE(SUBSTR (value,1,INSTR(value,',') -1),NULL,
     Value,SUBSTR (value,1,INSTR(value,',') -1))
     INTO v_utl_location
     FROM v$parameter
     WHERE name = 'utl_file_dir';
     EXCEPTION
      WHEN OTHERS THEN
      v_debug_flag:='N';
     END;
  END IF;

  IF v_debug_flag ='Y' THEN
     v_myfilehandle := UTL_FILE.FOPEN(v_utl_location,'ja_in_wsh_dlry_dtls_au_trg.LOG','A');
     UTL_FILE.PUT_LINE(v_myfilehandle,'************************START************************************');
     UTL_FILE.PUT_LINE(v_myfilehandle,'The TIME Stamp this ENTRY IS Created IS ' ||TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'));
  END IF;

  /*
  || Code added by aiyer for the bug 4035566
  || Call the function jai_cmn_utils_pkg.check_jai_exists to check the current set of books in INR/NON-INR based.
  */
  --IF jai_cmn_utils_pkg.check_jai_exists ( p_calling_object      => 'JA_IN_WSH_DLRY_DTLS_AU_TRG' ,
  --                 p_org_id              => pr_new.org_id
  --                               )  = FALSE
  --THEN
    /*
  || return as the current set of books is NON-INR based
  */
  --  RETURN;
  --END IF;

  OPEN get_ship_to_org_id_cur( v_source_line_id);
  FETCH get_ship_to_org_id_cur INTO v_ship_to_org_id , v_bill_to_org_id; -- added v_bill_to_org_id for bug#8731696
  CLOSE get_ship_to_org_id_cur;

  --added for bug#8731696,start
  OPEN cur_get_bill_to_cust_id(v_bill_to_org_id);
  FETCH cur_get_bill_to_cust_id INTO ln_bill_to_cust_id;
  CLOSE cur_get_bill_to_cust_id;
  --bug#8731696, end

  /*
    This code is added by aiyer for the bug #3139718
    Added the check that the trigger should be bypassed in case the functional currency code is NON INR.
  */
  IF pr_new.org_id IS NOT NULL THEN
  /* Bug 5243532. Added by Lakshmi Gopalsami
     Removed the reference to cursor sob_cur and implemented using
     caching logic.
   */

    l_func_curr_det := jai_plsql_cache_pkg.return_sob_curr
                            (p_org_id  => pr_new.org_id);
    v_currency_code   := l_func_curr_det.currency_code;
    v_set_of_books_id := l_func_curr_det.ledger_id;
    -- end for bug 5243532
  END IF;

  -- Check for the Delivery Status
  OPEN Get_Status_Cur;
  FETCH Get_Status_Cur INTO  v_delivery_id, v_date_confirmed, v_status_code;
  CLOSE Get_Status_Cur;
  IF NVL(v_status_code,'#') NOT IN ('CO', 'IT','CL') THEN
                RETURN;
  END IF;                                               --1
  --2001/05/31 Anuradha Parthasarathy
  IF NVL(pr_new.shipped_quantity,0) = 0 THEN
        RETURN;
  END IF;
  -- Check whether Line Details exists in Localization table.
  OPEN Get_So_Lines_Count_Cur;
  FETCH Get_So_Lines_Count_Cur  INTO v_so_lines_count;
  CLOSE Get_So_Lines_Count_Cur ;
  IF v_so_lines_count = 0 THEN                                  --2
        RETURN;
  END IF;                               --2
  --  Fetch Lines Details from  Localization Table
  OPEN Get_So_Lines_Details_Cur;
  FETCH Get_So_Lines_Details_Cur  INTO
                                           v_selling_price,
                                           v_quantity,
                                           v_tax_category_id,
                                           v_assessable_value,
                                           ln_vat_assessable_value,
                                           v_excise_exempt_type,
                                           v_excise_exempt_refno,
                                           v_excise_exempt_date,
                                           -- Added by Brathod for Bug#4215808
                                           lv_vat_exemption_flag,
                                           lv_vat_exemption_type,
                                           ld_vat_exemption_date,
                                           lv_vat_exemption_refno;
                                           -- End of Bug#4215808
    CLOSE Get_So_Lines_Details_Cur;
    --Get The Location Id
    OPEN Location_Cursor;
    FETCH Location_Cursor INTO    v_location_id, v_trading_flag;
    CLOSE Location_Cursor;

    /*start. csahoo for bug#8500697*/
    IF v_location_id IS NULL THEN
      v_location_id := pr_new.ship_from_location_id ;
    END IF;
    /*end. rchandan for bug#8500697*/

    OPEN  Trading_register_code_cur(v_organization_id, v_location_id,v_delivery_detail_id, v_source_header_type_id);
    FETCH Trading_register_code_cur INTO v_trad_register_code;
    CLOSE Trading_register_code_cur;

    --2001/07/10          Anuradha Parthasarathy
    OPEN  item_trading_cur;
    FETCH item_trading_cur INTO v_item_trading_flag;
    CLOSE item_trading_cur;
    OPEN get_item_attributes;
    FETCH get_item_attributes INTO v_exe_flag,v_mod_flag;
    CLOSE get_item_attributes;
    /*
       Code modified by aiyer for the bug#3032569
       Modified the IF statment to raise an error only when trading register code is in 23D_DOMESTIC_EXCISE and 23D_EXPORT_EXCISE.
       The other two trading register_codes '23D_DOM_WITHOUT_EXCISE' and '23D_EXPORT_WITHOUT_EXCISE' have been removed from this if statement
       as matched receipts is not relevant in this case.
    */

     -- Start of Bug #3032569

      IF v_trad_register_code IN(
                                   '23D_DOMESTIC_EXCISE',
                                   '23D_EXPORT_EXCISE'
                                 )
      THEN
      -- End of Bug #3032569

        IF NVL(v_trading_flag,'N') = 'Y' AND NVL(V_item_trading_flag,'N') = 'Y'  AND NVL(v_exe_flag,'N')= 'Y' THEN
          OPEN matched_receipt_cur1;
      FETCH matched_receipt_cur1 INTO v_matched_qty;
          CLOSE matched_receipt_cur1;
          IF NVL(v_shipped_quantity,0) <> NVL(v_matched_qty,0) THEN
/*             RAISE_APPLICATION_ERROR(-20401, 'Matched Quantity -- ' || TO_CHAR(NVL(v_matched_qty,0)) ||
                           ' should be equal to Shipped Quantity -- ' || TO_CHAR(NVL(v_shipped_quantity,0))); */ pv_return_code := jai_constants.expected_error ; pv_return_message := 'Matched Quantity -- ' || TO_CHAR(NVL(v_matched_qty,0)) ||
                           ' should be equal to Shipped Quantity -- ' || TO_CHAR(NVL(v_shipped_quantity,0)) ; return ;

          END IF;
        END IF;
     END IF;

/*Commented below code by JMEENA for bug#6731913 as it already exists in ARU_T2.

     --THE FOLLOWING LINES ADDED BY SRIRAM - LC FUNCTIONALITY - BUG# 2165355 - 19/09/2002

     OPEN   C_CHECK_LC_ORDER;
     FETCH  C_CHECK_LC_ORDER INTO v_check_lc_order;
     CLOSE  C_CHECK_LC_ORDER;
     IF NVL(v_check_lc_order,'N') = 'Y' THEN
        OPEN  C_MATCHED_QTY_CUR;
        FETCH C_MATCHED_QTY_CUR INTO v_lc_qty_matched;
        CLOSE C_MATCHED_QTY_CUR;
        IF NVL(v_lc_qty_matched,-999) <> NVL(v_lc_shipped_qty,-888) THEN
      RAISE_APPLICATION_ERROR(-20120, 'LC Matched Quantity -- ' || TO_CHAR(NVL(v_lc_qty_matched,0)) ||
                ' should be equal to Shipped Quantity -- ' || TO_CHAR(NVL(v_lc_shipped_qty,0)) || ' for LC enabled Orders');
pv_return_code := jai_constants.expected_error ; pv_return_message := 'LC Matched Quantity -- ' || TO_CHAR(NVL(v_lc_qty_matched,0)) ||
                ' should be equal to Shipped Quantity -- ' || TO_CHAR(NVL(v_lc_shipped_qty,0)) || ' for LC enabled Orders' ; return ;
        END IF;

        --Start, bug#5680459 csahoo
       --   following code is to correct the existing lc_matching order line to new split line id

        open c_order_line;
        fetch c_order_line into r_order_line;
        close c_order_line;

        ln_lc_update_cnt := -1;
        if r_order_line.split_from_line_id is not null then
          open c_lc_mtch_dlry_line;
          fetch c_lc_mtch_dlry_line into r_lc_mtch_dlry_line;
          close c_lc_mtch_dlry_line;
          if pr_new.source_line_id <> r_lc_mtch_dlry_line.order_line_id then

            update JAI_OM_LC_MATCHINGS
            set order_line_id = pr_new.source_line_id
            where delivery_detail_id = pr_new.Delivery_Detail_Id
            -- and order_line_id = r_order_line.split_from_line_id
            and release_flag is null;
            ln_lc_update_cnt := sql%rowcount;
          end if;

        end if;

        -- End, bug#5680459 csahoo


        UPDATE JAI_OM_LC_MATCHINGS
        SET    RELEASE_FLAG = 'Y'
        WHERE  DELIVERY_DETAIL_ID = pr_new.Delivery_Detail_id;
     END IF;

    -- ENDS HERE - CHANGES BY SRIRAM FOR LC FUNCTIONALITY - BUG # 2165355 - 19/09/2002

    End of bug#6731913 */

     -- Start of code for bug #3139718
     OPEN get_conv_detail_cur;
     FETCH get_conv_detail_cur INTO v_currency_code, v_conv_type_code,v_conv_rate, v_conv_date;

     IF get_conv_detail_cur%FOUND THEN

       v_curr_conv_rate := jai_cmn_utils_pkg.currency_conversion (
                                             v_set_of_books_id       ,
                                             v_currency_code         ,
                                             v_conv_date             ,
                                             v_conv_type_code        ,
                                             v_conv_rate
                                        );
       -- Added by Jia for bug#9736876, Begin
       ----------------------------------------------
       IF v_curr_conv_rate IS NULL
       THEN
         lv_process_message := 'Currency Conversion on shipment date not setup.';
         app_exception.raise_exception
                            (exception_type   =>    'APP'
                            ,exception_code   =>    -20275
                            ,exception_text   =>    lv_process_message
                            );
       END IF;
       ----------------------------------------------
       -- Added by Jia for bug#9736876, End
     END IF;
     -- End of code for bug #3139718

     CLOSE get_conv_detail_cur;

     -- Start Inserting Tax Lines
       FOR Rec IN Get_Tax_Lines_Details_Cur
       LOOP
       counter:=counter+1;

       /* Moved the code from below else part to here for bug# 6498072 */
      OPEN    uom_code;
      FETCH   uom_code INTO v_order_quantity_uom;
      CLOSE   uom_code;

     --2001/06/08            Anuradha Parthasarathy
     /*
       This if statement has been modified by aiyer for the bug #2988829.
       As the tax amount, base_tax_amount and func_tax_amount would be present in table JAI_CMN_MATCH_TAXES
       only when match receipt functionality has been done .
       Now in order to check that the match receipts functionality has been performed the following check has been added in additions
       to the other three checks (of organization being a trading organization, Item being tradable and excisable ):-
       The order attached to the bond register is one of 'Trading Domestic With Excise' or 'Export With Excise'
       hence applying the check that
       v_trad_register_code IN ( '23D_DOMESTIC_EXCISE','23D_EXPORT_EXCISE') .
       Before this fix, Null value used to get inserted into taxes in table JAI_OM_WSH_LINE_TAXES for Bond register with
       'Trading Domestic Without Excise' and 'Export Without Excise' ( problem stated in the bug )
     */
      IF NVL(v_trading_flag,'N')      = 'Y' AND
         NVL(v_item_trading_flag,'N') = 'Y' AND
         NVL(v_exe_flag,'N')          = 'Y' AND
         v_trad_register_code         IN ( '23D_DOMESTIC_EXCISE','23D_EXPORT_EXCISE')
      THEN

        OPEN  rg23d_amount_cur(rec.tax_id);
        FETCH rg23d_amount_cur  INTO  v_tax_amt,v_base_tax_amt,v_func_tax_amt;
        CLOSE rg23d_amount_cur;

    v_conversion_rate := 1;  -- conversion_rate should be 1 in case of trading, added by JMEENA for bug#6280735 (FP 6164922)
      ELSE
      /*
      this control comes here for manufacturing - all scenarios
      */
        v_tax_amt      := (v_shipped_quantity * (rec.tax_amount/v_quantity))     ;
        v_base_tax_amt := (v_shipped_quantity * (rec.base_tax_amount/v_quantity)) ;
          /*
          Code modified by aiyer for the bug 3139718
            As the Conversion rate can be different while the sales order was booked and when the sales order would be shipped.
          So during shipping the functional tax amount needs to be recalculated from the tax_amount column in JAI_OM_OE_SO_TAXES
          , hence  setting the v_func_tax_amt = v_tax_amt * nvl((v_curr_conv_rate ,1)
           */
        v_func_tax_amt :=  (v_tax_amt  * nvl(v_curr_conv_rate,1)) ; -- added by ssumaith - bug#3609172
      --END IF; Commented by JMEENA for bug#6280735

       -- Proportionate the Tax Amounts as per the New Shipped Quantity
       -- and round it off according to the Rounding Factor Defined.
       -- 2001/10/03 Anuradha Parthasarathy

      --Moved the following code to the start of the loop for bug# 6498072
      --OPEN    uom_code;
      --FETCH   uom_code INTO v_order_quantity_uom;
      --CLOSE   uom_code;

     /*included the UOM conversion logic into the else part Earlier it was outside the end of If condition.
                  added by JMEENA for bug#6280735 (FP 6164922) */
      Inv_Convert.inv_um_conversion(v_Requested_Quantity_Uom,
                                                                v_order_quantity_uom,
                                                                v_inventory_item_id,
                                                                v_conversion_rate);
      IF NVL(v_conversion_rate, 0) <= 0 THEN
        Inv_Convert.inv_um_conversion(v_Requested_Quantity_Uom,
                                                                      v_order_quantity_uom,
                                                                      0,
                                                                      v_conversion_rate);
        IF NVL(v_conversion_rate, 0) <= 0 THEN
              v_conversion_rate := 0;
        END IF;
      END IF;
  END IF; --Added by JMEENA for bug#6280735
      -- the following section added by sriram on 24-aug-02 bug # 25310103
      -- this was done because - it will ensure that Line splitting \ Backordering is not supported only
      -- when the Organization as well as Item are both Trading which is a
      -- requirement when match receipt funtionality for RG23D is being used.

      -- code reorg done by sriram - bug#3609172 - for old code refer to rcs version 619.1

        v_tax_amount          := ROUND((v_tax_amt) * v_conversion_rate,rec.rounding_factor);
        v_base_tax_amount     := ROUND((v_base_tax_amt) * v_conversion_rate,rec.rounding_factor);

        IF NVL(v_trading_flag,'N')      = 'Y' AND
       NVL(v_item_trading_flag,'N') = 'Y' AND
       NVL(v_exe_flag,'N')          = 'Y' AND
       v_trad_register_code         IN ( '23D_DOMESTIC_EXCISE','23D_EXPORT_EXCISE')
       AND   Rec.Tax_type         like '%Excise%' --  Excise added into the if by Sriram for Bug# 3148621 17/09/2003
        THEN
           v_func_tax_amount     := ROUND((v_func_tax_amt)* v_conversion_rate, rec.rounding_factor);
        ELSE
           IF v_curr_conv_rate <> 1 AND rec.tax_type like '%Excise%' THEN
                 v_func_tax_amount       := ROUND((v_func_tax_amt)* v_conversion_rate,0);
       ELSE
                 v_func_tax_amount       := ROUND((v_func_tax_amt)* v_conversion_rate, rec.rounding_factor);
         END IF;
        END IF;


      -- Accumulate the respective types of Excise Duties
      -- for inserting into JAI_OM_WSH_LINES_ALL Table.
      IF rec.tax_type = 'Excise' THEN                                                                                                         --3
        v_basic_excise_duty_amount := NVL(v_basic_excise_duty_amount,0) + v_tax_amount ;
      ELSIF rec.tax_type = 'Addl. Excise' THEN                                                                                                                --3
        v_add_excise_duty_amount   := NVL(v_add_excise_duty_amount,0) + v_tax_amount ;
      ELSIF rec.tax_type = 'Other Excise' THEN                                                                                                                --3
        v_oth_excise_duty_amount   := NVL(v_oth_excise_duty_amount,0) + v_tax_amount ;
      END IF;

      IF v_debug_flag ='Y' THEN
           UTL_FILE.PUT_LINE(v_myfilehandle,'1 v_basic_excise_duty_amount -> '||v_basic_excise_duty_amount
                  ||', v_add_excise_duty_amount -> '|| v_add_excise_duty_amount
                  ||', v_oth_excise_duty_amount -> '|| v_oth_excise_duty_amount
           );
      END IF;                                                                                             --3
      -- Check for the existence of Tax Lines in JAI_OM_WSH_LINE_TAXES
      OPEN Pick_Tax_Line_Count_Cur(rec.tax_id);
      FETCH Pick_Tax_Line_Count_Cur INTO v_picking_tax_lines_count;
      CLOSE Pick_Tax_Line_Count_Cur;
      IF v_picking_tax_lines_count = 0  THEN                                                                                  --4
        INSERT INTO JAI_OM_WSH_LINE_TAXES(Delivery_Detail_Id,
                                               Tax_Line_No,
                                               Precedence_1,
                                               Precedence_2,
                                               Precedence_3,
                                               Precedence_4,
                                               Precedence_5,
                 Precedence_6, -- CHANGE ON 02/11/2006 BY SACSETHI FOR BUG 5228046
                                               Precedence_7,
                                               Precedence_8,
                                               Precedence_9,
                                               Precedence_10,
                                               Tax_Id,
                                               Tax_Rate,
                                               Qty_Rate,
                                               Uom,
                                               Tax_Amount,
                                               Base_Tax_Amount,
                                               Func_Tax_Amount,
                                               Creation_Date,
                                               Created_By,
                                               Last_Update_Date,
                                               Last_Updated_By,
                                               Last_Update_Login)
                                       VALUES (
            v_delivery_detail_id,
                                                rec.Tax_Line_No,
                                                rec.Precedence_1,
                                                rec.Precedence_2,
                                                rec.Precedence_3,
                                                rec.Precedence_4,
                                                rec.Precedence_5,
                                                rec.Precedence_6, -- CHANGE ON 02/11/2006 BY SACSETHI FOR BUG 5228046
                                                rec.Precedence_7,
                                                rec.Precedence_8,
                                                rec.Precedence_9,
                                                rec.Precedence_10,
            rec.Tax_id,
                                                rec.Tax_rate,
                                                rec.Qty_Rate,
                                                rec.Uom,
                                                v_tax_amount,
                                                v_base_tax_amount,
                                                v_func_tax_amount,
                                                v_creation_date,
                                                v_created_by,
                                                v_last_update_date,
                                                v_last_updated_by,
                                                v_last_update_login
                 );
       ELSE                                                                                    --4
          UPDATE  JAI_OM_WSH_LINE_TAXES
          SET Tax_Amount                                = v_tax_amount,
                    Last_Update_Date              = v_last_update_date,
                    Last_Updated_By               = v_last_updated_by,
                    Last_Update_Login             = v_last_update_login
          WHERE Delivery_Detail_Id      = v_delivery_detail_id
          AND   Tax_Id          = rec.Tax_Id;
        END IF;                                                                         --4
      END LOOP;


      /** Added by Bgowrava for forward porting Bug#5631784 , TCS Enh.*/

      /**
      Aim:  Populate TCS Surcharge and Surcharge cess type of taxes if threshold level is high.

      Check if TCS type of taxes exists,  If yes using the threshold API found out the slab and the tax category id
      and delegate the call tax defaultation API
      */

      ln_tcs_exists  := 0;  --kunkumar for bug#5604375  and 6066750
      /*  jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Checking if TCS type of tax exists?'); */ --commented by bgowrava for bug#5631784
      open c_chk_rgm_tax_exists ( cp_regime_code        => jai_constants.tcs_regime
                              , cp_delivery_detail_id => v_delivery_detail_id
                              );
      fetch c_chk_rgm_tax_exists into ln_tcs_exists;
      close c_chk_rgm_tax_exists ;

      /*   jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'ln_tcs_exists='||ln_tcs_exists); */ --commented by bgowrava for bug#5631784
      if nvl(ln_tcs_exists,0) >0 then   --kunkumar for bug#5604375  and 6066750
      /* TCS type of tax is present */
      fnd_file.put_line(FND_FILE.LOG,'Localization' );

       open  c_get_regime_id (cp_regime_code => jai_constants.tcs_regime);
       fetch c_get_regime_id into ln_tcs_regime_id;
       close c_get_regime_id;
       /* Find out what is the current slab */
      /*  jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Get threshold_slab_id.  Before calling JAI_RGM_THHOLD_PROC_PKG.GET_THRESHOLD_SLAB_ID');*/ --commented by bgowrava for bug#5631784
      jai_rgm_thhold_proc_pkg.get_threshold_slab_id
                                (
                                    p_regime_id         =>    ln_tcs_regime_id
                                  , p_organization_id   =>    v_organization_id
                                  , p_party_type        =>    jai_constants.party_type_customer
                                  , p_party_id          =>    v_customer_id
                                  , p_org_id            =>    v_org_id
                                  , p_source_trx_date   =>    v_date_confirmed
                                  , p_threshold_slab_id =>    ln_threshold_slab_id
                                  , p_process_flag      =>    lv_process_flag
                                  , p_process_message   =>    lv_process_message
                                );
  /*    jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Process Result for JAI_RGM_THHOLD_PROC_PKG.GET_THRESHOLD_SLAB_ID');
      jai_cmn_debug_contexts_pkg.print (ln_reg_id,
                              'lv_process_flag    ='  ||lv_process_flag||chr(10)
                            ||'lv_process_message ='  ||lv_process_message
                             );   */ --commented by bgowrava for bug#5631784

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

    /*    jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Process Result for JAI_RGM_THHOLD_PROC_PKG.GET_THRESHOLD_TAX_CAT_ID');
        jai_cmn_debug_contexts_pkg.print (ln_reg_id
                                ,'lv_process_flag    ='  ||lv_process_flag||chr(10)
                              ||'lv_process_message ='  ||lv_process_message
                                );  */ --commented by bgowrava for bug#5631784


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
        from   JAI_OM_WSH_LINE_TAXES
        where  delivery_detail_id = v_delivery_detail_id;

        /* Get line number of the base tax (tax_type=TCS) for calculating the surcharge basically to set a precedence */
        select max(tax_line_no)
        into  ln_base_line_no
        from  JAI_OM_WSH_LINE_TAXES jsptl
            , JAI_CMN_TAXES_ALL jtc
        where jsptl.delivery_detail_id = v_delivery_detail_id
        and   jsptl.tax_id    = jtc.tax_id
        and   jtc.tax_type    = jai_constants.tax_type_tcs;

        /*
        ||Call the helper method to default surcharge taxes on top of the SO taxes  using the tax category
        || The api jai_rgm_thhold_proc_pkg.default_thhold_taxes inserts lines as per the same specified in the TCS tax category
        || into the JAI_OM_WSH_LINE_TAXES table
        */

      /*  jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Calling JAI_RGM_THHOLD_PROC_PKG.DEFAULT_THHOLD_TAXES');*/ --commented by bgowrava for bug#5631784

        jai_rgm_thhold_proc_pkg.default_thhold_taxes
                                  (
                                    p_source_trx_id         => ''
                                  , p_source_trx_line_id    => v_delivery_detail_id
                                  , p_source_event          => jai_constants.source_ttype_delivery
                                  , p_action                => jai_constants.default_taxes
                                  , p_threshold_tax_cat_id  => ln_threshold_tax_cat_id
                                  , p_tax_base_line_number  => ln_base_line_no
                                  , p_last_line_number      => ln_last_line_no
                                  , p_currency_code         => v_currency_code
                                  , p_currency_conv_rate    => v_conv_rate
                                  , p_quantity              => nvl(v_shipped_quantity,0)
                                  , p_base_tax_amt          => nvl((v_selling_price * v_conversion_rate) * v_shipped_quantity,0)
                                  , p_assessable_value      => nvl(v_assessable_value * v_shipped_quantity, 0) /* Added v_shipped_quantity and nvl() for bug#6498072 */
                                  , p_inventory_item_id     => v_inventory_item_id
                                  , p_uom_code              => v_order_quantity_uom
                                  , p_vat_assessable_value  => ln_vat_assessable_value
                                  , p_process_flag          => lv_process_flag
                                  , p_process_message       => lv_process_message
                                  );

    /*    jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Process Result for JAI_RGM_THHOLD_PROC_PKG.DEFAULT_THHOLD_TAXES');
        jai_cmn_debug_contexts_pkg.print (ln_reg_id
                                ,'lv_process_flag    ='  ||lv_process_flag||chr(10)
                                ||'lv_process_message ='  ||lv_process_message
                                );    */ --commented by bgowrava for bug#5631784

        if lv_process_flag <> jai_constants.successful then
          app_exception.raise_exception
                        (exception_type   =>    'APP'
                        ,exception_code   =>    -20275
                        ,exception_text   =>    lv_process_message
                        );
        end if;

      end if; /* ln_threshold_slab_id is not null then */

      end if;  /** ln_tcs_exists is not null then  */

  /** End bug 5631784*/





      -- THE FOLLOWING CODE ADDED BY SRIRAM - BUG # 2330055 - 08-may-2002
      -- This Code was Added because - in case there are items which do not have tax lines , the
      -- v_conversion_rate variable is not getting populated - so the selling price and the
      -- assessable value fields are being multiplied by the v_conversion_rate which is 0 initially.
      -- hence the addition of the following lines ensures the v_conversion_rate is calculated ,
      -- multiplied and correctly done with selling price and assessable value.
      OPEN      uom_code;
      FETCH     uom_code INTO v_order_quantity_uom;
      CLOSE     uom_code;
      Inv_Convert.inv_um_conversion(v_Requested_Quantity_Uom,
                                    v_order_quantity_uom,
                                    v_inventory_item_id,
                                    v_conversion_rate);
      IF NVL(v_conversion_rate, 0) <= 0 THEN
        Inv_Convert.inv_um_conversion(v_Requested_Quantity_Uom,
                                      v_order_quantity_uom,
                                      0,
                                      v_conversion_rate);
        IF NVL(v_conversion_rate, 0) <= 0 THEN
          v_conversion_rate := 0;
        END IF;
      END IF;
      /*
        insert into debug_data (str) values ('AFTER - the value OF v_conversion_rate IS ' || to_char(v_conversion_rate));
        insert into debug_data (str) values ('AFTER - the value OF v_Requested_Quantity_Uom IS ' || v_Requested_Quantity_Uom);
        insert into debug_data (str) values ('AFTER - the value OF v_order_quantity_uom IS ' || v_order_quantity_uom);
      */
       -- debug code ends here -  sriram
      /*
             code added ends here - 2330055 - 08-may-2002
      */
      OPEN get_item_dtls(v_organization_id,v_inventory_item_id);
      FETCH get_item_dtls INTO v_excise_flag,v_item_class;
      CLOSE get_item_dtls;

      /*
        This if statement has been modified by aiyer for the bug #2988829.
        As the tax amount, base_tax_amount and func_tax_amount would be present in table JAI_CMN_MATCH_TAXES
        only when match receipt functionality has been done .
        Now in order to check that the match receipts functionality has been performed the following check has been added in additions
        to the other three checks (of organization being a trading organization, Item being tradable and excisable ):-
        The order attached to the bond register is one of 'Trading Domestic With Excise' or 'Export With Excise'
        hence applying the check that
        v_trad_register_code IN ( '23D_DOMESTIC_EXCISE','23D_EXPORT_EXCISE') .
        Before this fix, Null value used to get inserted into taxes in table JAI_OM_WSH_LINES_ALL for Bond register with
        'Trading Domestic Without Excise' and 'Export Without Excise' ( problem stated in the bug )
      */


      IF    nvl(v_trading_flag,'N')         = 'Y'   AND
            nvl(v_item_trading_flag,'N')    = 'Y'   AND
            nvl(v_excise_flag,'N')          = 'Y'   AND
            v_trad_register_code            IN ( '23D_DOMESTIC_EXCISE','23D_EXPORT_EXCISE')
      THEN
            OPEN  ed_cur('Excise');
            FETCH ed_cur INTO v_basic_excise_duty_amount;
            CLOSE ed_cur ;
            OPEN  ed_cur('Addl. Excise');
            FETCH ed_cur INTO v_add_excise_duty_amount;
            CLOSE ed_cur;
            OPEN  ed_cur('Other Excise');
            FETCH ed_cur INTO v_oth_excise_duty_amount;
            CLOSE ed_cur;
      END IF;
      --Get Cumulative Excise amount
      --for inserting into JAI_OM_WSH_LINES_ALL Table.
      v_excise_amount := (v_basic_excise_duty_amount + v_add_excise_duty_amount +
                                             v_oth_excise_duty_amount);
      -- Get Total Tax Amount for the Line
      -- for Inserting into  JAI_OM_WSH_LINES_ALL Table.
      OPEN Get_Tot_Tax_Amount_Cur;
      FETCH Get_Tot_Tax_Amount_Cur  INTO v_tot_tax_amount;
      CLOSE Get_Tot_Tax_Amount_Cur;
      -- Check for Delivery lines existence in JAI_OM_WSH_LINES_ALL Table
      OPEN Get_Delivery_Line_Count_Cur ;
      FETCH Get_Delivery_Line_Count_Cur INTO        v_delivery_line_count;
      CLOSE Get_Delivery_Line_Count_Cur ;
      IF v_delivery_line_count = 0 THEN
                                                                                            --5
        INSERT INTO JAI_OM_WSH_LINES_ALL(
            Delivery_Detail_Id,
                                                Order_Header_Id,
                                                Order_Line_Id,
                                                split_from_delivery_detail_id,
                                                Selling_Price,
                                                Quantity,
                                                Assessable_value,
                                                vat_assessable_value,
                                                Tax_Category_Id,
                                                Tax_Amount,
                                                Inventory_Item_Id,
                                                Organization_Id,
                                                Location_Id,
                                                Unit_Code,
                                                Excise_Amount,
                                                Basic_Excise_Duty_Amount,
                                                Add_Excise_Duty_Amount,
                                                Oth_Excise_Duty_Amount,
                                                Excise_Exempt_Type,
                                                Excise_Exempt_Refno,
                                                Excise_Exempt_Date,
                                                Creation_Date,
                                                Created_By,
                                                Last_Update_Date,
                                                Last_Updated_By,
                                                Last_Update_Login,
                                                ORG_ID,
                                                CUSTOMER_ID,
                                                SHIP_TO_ORG_ID,
                                                ORDER_TYPE_ID,
                                                SUBINVENTORY,
                                                DELIVERY_ID,
                                                -- Added by Brathod for Bug#4215808
                                                VAT_EXEMPTION_FLAG,
                                                VAT_EXEMPTION_TYPE,
                                                VAT_EXEMPTION_DATE,
                                                VAT_EXEMPTION_REFNO
                                                -- End of Bug#4215808
                                                -- added by Allen Yang for bug 9485355 16-Apr-2010, begin
                                                , SHIPPABLE_FLAG
                                                -- added by Allen Yang for bug 9485355 16-Apr-2010, end
                                            )
                                    VALUES (   v_delivery_detail_id,
                                               v_source_header_id,
                                               v_source_line_id,
                                               pr_new.split_from_delivery_detail_id,
                                               v_selling_price * v_conversion_rate,
                                               v_shipped_quantity,
                                               v_assessable_value * v_conversion_rate,
                                               ln_vat_assessable_value * v_conversion_rate,
                                               v_tax_category_id,
                                               v_tot_tax_amount,
                                               v_Inventory_Item_Id,
                                               v_Organization_Id,
                                               v_location_id,-- 2001/06/23 Anuradha Parthasarathy
                                               v_Requested_Quantity_Uom,
                                               v_excise_amount,
                                               v_basic_excise_duty_amount,
                                               v_add_excise_duty_amount,
                                               v_oth_excise_duty_amount,
                                               v_excise_exempt_type,
                                               v_excise_exempt_refno,
                                               v_excise_exempt_date,
                                               v_creation_date,
                                               v_created_by,
                                               v_last_update_date,
                                               v_last_updated_by,
                                               v_last_update_login,
                                               v_org_Id,
                                               v_customer_id,
                                               v_ship_to_org_id,
                                               v_source_header_type_id,
                                               v_subinventory,
                                               v_DELIVERY_ID,
                                               -- Added by Brathod for Bug#4215808
                                               lv_vat_exemption_flag,
                                               lv_vat_exemption_type,
                                               ld_vat_exemption_date,
                                               lv_vat_exemption_refno
                                                -- End of Bug#4215808
                                               -- added by Allen Yang for bug 9485355 16-Apr-2010, begin
                                               --, 'Y'  -- shippable_flag  commented by allen yang for bug 9666476
                                               , NULL   -- shippable_flag, added by Allen Yang for bug 9666476
                                               -- added by Allen Yang for bug 9485355 16-Apr-2010, end
             );

        -- Insert the Data Required for RG entries into a Temporary Table
        IF  NVL(v_excise_flag,'N') = 'Y' THEN
          INSERT INTO JAI_OM_OE_GEN_TAXINV_T(
                 date_released,
                                               date_confirmed,
                                               delivery_detail_id,
                                               order_header_id,
                                               creation_date,
                                               created_by,
                                               last_update_date,
                                               last_updated_by,
                                               last_update_login,
                                               delivery_id
                )
                                      VALUES  (
                       SYSDATE,
                                               v_date_confirmed,
                                               v_delivery_detail_id,
                                               v_source_header_id,
                                               v_creation_date,
                                               v_created_by,
                                               v_last_update_date,
                                               v_last_updated_by,
                                               v_last_update_login,
                                               v_delivery_id
               );
        END IF;

      -- Added by brathod for Bug#4215808
      /*
      || check if VAT type of tax exists
      */

      OPEN  cur_chk_vat_exists (cp_del_det_id => v_delivery_detail_id) ;
      FETCH cur_chk_vat_exists INTO ln_vat_cnt;
      CLOSE cur_chk_vat_exists ;

      OPEN  cur_chk_vat_proc_entry (cp_delivery_id => v_delivery_id);
      FETCH cur_chk_vat_proc_entry INTO ln_vat_proc_cnt ;
      CLOSE cur_chk_vat_proc_entry;


       /*
      || Added by csahoo for bug#5680459
      || Check if only 'VAT REVERSAL' tax type is present in JAI_OM_WSH_LINE_TAXES
      */
      IF nvl(ln_vat_cnt,0) = 0 THEN     /* If taxes of type 'VAT' are not present */
         lv_vat_reversal := 'VAT REVERSAL' ;
         OPEN  c_chk_vat_reversal(cp_del_det_id => v_delivery_detail_id,
                                  cp_tax_type   => lv_vat_reversal) ;
         FETCH c_chk_vat_reversal INTO ln_vat_reversal_exists;
         CLOSE c_chk_vat_reversal ;

         /*
         || VAT invoice number should be punched as 'NA' and accounting should happen
         || when 'VAT REVERSAL' type of tax exist and 'VAT' type of tax(es) doesn't exist
         */
         lv_vat_invoice_no     := jai_constants.not_applicable ;
         lv_vat_inv_gen_status := 'C' ;
      END IF ;

      /*
      || Added 'OR nvl(ln_vat_reversal_exists,0) = 1' for bug#5680459
      || If taxes of 'VAT' type (or) taxes of 'VAT REVERSAL' type exists
      */

      IF (nvl(ln_vat_cnt,0) > 0 OR nvl(ln_vat_reversal_exists,0) = 1 ) AND nvl (ln_vat_proc_cnt,0) = 0 THEN
        /* VAT type of tax exists*/
        /* Get the regime id for these type of taxes */
        OPEN  cur_get_regime_info (cp_organization_id => v_organization_id,
                                   cp_location_id => v_location_id
                                  );
        FETCH cur_get_regime_info INTO ln_regime_id,
                                       lv_regns_num;
        CLOSE cur_get_regime_info;

        INSERT INTO JAI_RGM_INVOICE_GEN_T (  regime_id                      ,
                                            delivery_id                    ,
                                            delivery_date                  ,
                                            customer_trx_id                ,
                                            organization_id                ,
                                            location_id                    ,
                                            registration_num               ,
                                            vat_invoice_no                 ,
                                            vat_inv_gen_status             ,
                                            vat_inv_gen_err_message        ,
                                            vat_acct_status                ,
                                            vat_acct_err_message           ,
                                            request_id                     ,
                                            program_application_id         ,
                                            program_id                     ,
                                            program_update_date            ,
                                            party_id                       ,
                                            party_site_id                  ,
                                            party_type                     ,
                                            creation_date                  ,
                                            created_by                     ,
                                            last_update_date               ,
                                            last_update_login              ,
                                            last_updated_by
                                           )
                              VALUES       (ln_regime_id                   ,
                                            v_delivery_id                  ,
                                            v_creation_date                ,
                                            null                           ,  -- customer_trx_id
                                            v_organization_id              ,
                                            v_location_id                  ,
                                            lv_regns_num                   ,
                                            lv_vat_invoice_no              ,  -- vat_invoice_no     --Replaced NULL with lv_vat_invoice_no for bug#5680459
                                            nvl(lv_vat_inv_gen_status, 'P'),  -- vat_inv_gen_status --Added nvl() for bug#5680459
                                            null                           ,  -- vat_inv_gen_err_message
                                            'P'                            ,  -- vat_acct_status
                                            null                           ,  -- vat_acct_err_message
                                            null                           ,  -- request_id
                                            null                           ,  -- program_application_id
                                            null                           ,  -- program_id
                                            null                           ,  -- program_update_date
                                            ln_bill_to_cust_id             , --added for bug#8731696
                                            v_bill_to_org_id               , --added for bug#8731696
                                            jai_constants.party_type_customer,
                                            v_creation_date                ,
                                            v_created_by                   ,
                                            v_last_update_date             ,
                                            v_last_update_login            ,
                                            v_last_updated_by
                                            );

      END IF;
      -- End of Bug#4215808

      ELSE
        UPDATE JAI_OM_WSH_LINES_ALL
        SET quantity                            = v_shipped_quantity,
                tax_amount                      = v_tot_tax_amount,
                order_line_id                   = v_source_line_id,
                excise_amount                   = v_excise_amount,
                basic_excise_duty_amount        = v_basic_excise_duty_amount,
                add_excise_duty_amount          = v_add_excise_duty_amount,
                oth_excise_duty_amount          = v_oth_excise_duty_amount,
                last_update_date                = v_last_update_date,
                last_updated_by                 = v_last_updated_by,
                last_update_login               = v_last_update_login,
                -- Added by Brathod for Bug#4215808
                VAT_EXEMPTION_FLAG              = lv_vat_exemption_flag,
                VAT_EXEMPTION_TYPE              = lv_vat_exemption_type,
                VAT_EXEMPTION_DATE              = ld_vat_exemption_date,
                VAT_EXEMPTION_REFNO             = lv_vat_exemption_refno
                -- End of Bug#4215808
        WHERE Delivery_id               = v_delivery_id
        AND   Delivery_Detail_id        = v_delivery_detail_id;
      END IF;                                                                                       --5


       /*
           || Start of bug #5631784
           || Code added by bgowrava for the forward porting bug
           */
       /*   jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                              pv_log_msg  =>  ' Before call to jai_ar_tcs_rep_pkg.wsh_interim_accounting '
                                   );   */ --commented by bgowrava for bug#5631784

          /*
          ||Does interim TCS accounting for the TCS type of taxes
          */
          jai_ar_tcs_rep_pkg.wsh_interim_accounting (   p_delivery_id         => v_delivery_id          ,
                                                        p_delivery_detail_id  => v_delivery_detail_id   ,
                                                        p_order_header_id     => v_source_header_id     ,
                                                        p_organization_id     => v_organization_id      ,
                                                        p_location_id         => v_location_id          ,
                                                        p_currency_code       => v_currency_code        ,
                                                        p_process_flag        => lv_process_flag        ,
                                                        p_process_message     => lv_process_message
                                                      );
       /*   jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                              pv_log_msg  =>  ' Returned from jai_ar_tcs_rep_pkg.wsh_interim_accounting '
                                   ); */ --commented by bgowrava for bug#5631784

          IF lv_process_flag = jai_constants.expected_error    OR                      ---------A2
             lv_process_flag = jai_constants.unexpected_error
          THEN
            /*
            || As Returned status is an error/not applicable hence:-
            || Set out variables p_process_flag and p_process_message accordingly
            */
       /*     jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                                pv_log_msg  =>  ' Error in processing jai_ar_tcs_rep_pkg.wsh_interim_accounting ' ||CHR(10)
                                                              ||',lv_process_flag -> '||lv_process_flag    ||CHR(10)
                                                              ||',lv_process_message -> '||lv_process_message
                                          ); */ --commented by bgowrava for bug#5631784
            fnd_message.set_name (  application => 'JA',
                                    name        => 'JAI_ERR_DESC'
                                 );

            fnd_message.set_token ( token => 'JAI_ERROR_DESCRIPTION',
                                    value => lv_process_message
                                  );

            app_exception.raise_exception;

          END IF;                                                                      ---------A2


           /*
           || End of bug #5631784
     */


      --------------------------------------------------------------------------------------------------------
      -- start
        OPEN  bonded_cur(v_organization_id, v_subinventory);
        FETCH bonded_cur INTO v_bonded_flag;
        CLOSE bonded_cur;
        IF v_debug_flag ='Y' THEN
         UTL_FILE.PUT_LINE(v_myfilehandle,'2 BEFORE the assignment OF v_order_type_id');
        END IF;
        v_order_type_id := v_source_header_type_id;
        IF v_debug_flag ='Y' THEN
        UTL_FILE.PUT_LINE(v_myfilehandle,'3 v_order_type_id IS '|| v_order_type_id);
        END IF;

        -- added by sriram - bug # 3021588

        jai_cmn_bond_register_pkg.GET_REGISTER_ID(v_organization_id,
                                            v_location_id,
                                            v_order_type_id,
                                            'Y',
                                            v_asst_register_id,
                                            v_register_code
                                           );


       -- following cursor has been commented and instead call to the jai_cmn_bond_register_pkg package has been done

       /*OPEN register_code_cur(v_organization_id, v_location_id,v_order_type_id);
       FETCH register_code_cur INTO v_register_code;
       CLOSE register_code_cur;
       */


       IF v_debug_flag ='Y' THEN
          UTL_FILE.PUT_LINE(v_myfilehandle,'4 AFTER the Register Code CURSOR');
         END IF;
         OPEN   fin_year_cur(v_organization_id);
         FETCH  fin_year_cur INTO v_fin_year;
         CLOSE  fin_year_cur;
         IF v_debug_flag ='Y' THEN
          UTL_FILE.PUT_LINE(v_myfilehandle,'5 AFTER the Financial Year CURSOR');
         END IF;
         IF v_delivery_id <> -1 THEN
           v_old_register := NULL;
           v_old_excise_invoice_no := NULL;
           IF v_old_register IS NULL THEN
             v_reg_type         := NULL;
             v_rg_type          := NULL;
             v_exc_invoice_no := NULL;
             v_tot_basic_ed_amt := v_basic_excise_duty_amount ;
             v_tot_addl_ed_amt  := v_add_excise_duty_amount;
             v_tot_oth_ed_amt   := v_oth_excise_duty_amount;
             v_tot_excise_amt   := v_excise_amount;
             IF NVL(v_bonded_flag,'Y') = 'Y'
             AND ( NVL(v_tot_excise_amt,0) > 0 OR v_excise_exempt_type IS NOT NULL ) THEN
             IF v_debug_flag ='Y' THEN
              UTL_FILE.PUT_LINE(v_myfilehandle,'6 BEFORE the Preference cursors');
             END IF;
             --Changed by Nagaraj.s for Enh#2415656
                   OPEN pref_cur(v_organization_id, v_location_id);
                   FETCH pref_cur INTO  v_pref_rg23a, v_pref_rg23c, v_pref_pla,v_export_oriented_unit;
                   CLOSE pref_cur;
                   ----Changed by Nagaraj.s for Enh#2415656
                   IF v_debug_flag ='Y' THEN
                    UTL_FILE.PUT_LINE(v_myfilehandle,'7 BEFORE the RG Balance CURSOR');
                   END IF;
                    OPEN rg_bal_cur(v_organization_id, v_location_id);
                    FETCH rg_bal_cur INTO v_rg23a_balance, v_rg23c_balance, v_pla_balance,
                    v_basic_pla_balance,v_additional_pla_balance,v_other_pla_balance;
                    CLOSE rg_bal_cur;
                    IF v_debug_flag ='Y' THEN
                         UTL_FILE.PUT_LINE(v_myfilehandle,'8 BEFORE the SSI Unit Flag CURSOR');
                        END IF;
                        OPEN  ssi_unit_flag_cur(v_organization_id, v_location_id);
                        FETCH ssi_unit_flag_cur INTO v_ssi_unit_flag;
                        CLOSE ssi_unit_flag_cur;
                        IF v_debug_flag ='Y' THEN
                         UTL_FILE.PUT_LINE(v_myfilehandle,'9 BEFORE the Register Code CURSOR');
                        END IF;


                        -- added by sriram - bug # 3021588

                        jai_cmn_bond_register_pkg.GET_REGISTER_ID(v_organization_id,
                                                            v_location_id,
                                                            v_order_type_id,
                                                            'Y',
                                                            v_asst_register_id,
                                                            v_register_code
                                                            );

                        -- call to the jai_cmn_bond_register_pkg package has been included instead of using the cursors
                        -- to get the bond register balance info and other bond register details

                        /*OPEN register_code_cur(v_organization_id, v_location_id, v_order_type_id);
                        FETCH register_code_cur INTO v_register_code;
                        CLOSE register_code_cur;
                        */


                        IF NVL(v_register_code,'N') IN ('DOMESTIC_EXCISE','EXPORT_EXCISE') THEN
                          OPEN get_item_dtls(v_organization_id,v_inventory_item_id);
                          FETCH get_item_dtls INTO v_excise_flag,v_item_class;
                          CLOSE get_item_dtls;
                          IF NVL(v_excise_flag,'N') = 'Y' THEN
                                IF NVL(v_excise_exempt_type, '@@@') NOT IN ('CT2', 'EXCISE_EXEMPT_CERT',
                                'CT2_OTH', 'EXCISE_EXEMPT_CERT_OTH','CT3' ) THEN
                                --***************************************************************************************************
                                --Calling the Function by Nagaraj.s for Enh#2415656............................
                                IF v_debug_flag ='Y' THEN
                                 UTL_FILE.PUT_LINE(v_myfilehandle,'10 BEFORE the jai_om_wsh_processing_pkg.excise_balance_check FUNCTION');
                                 UTL_FILE.FCLOSE(v_myfilehandle);
                                END IF;

                                open   c_cess_amount(v_delivery_id);
                                fetch  c_cess_amount into ln_cess_amount;
                                close  c_cess_amount;

                                -- start Bgowrava for forward porting bug#5989740
                                open   c_sh_cess_amount(v_delivery_id);
                                fetch  c_sh_cess_amount into ln_sh_cess_amount;
                                close  c_sh_cess_amount;

                                -- end Bgowrava for forward porting bug#5989740


                                v_reg_type:= jai_om_wsh_processing_pkg.excise_balance_check
                                                                  (v_pref_rg23a,
                                                                   v_pref_rg23c,
                                                                   v_pref_pla,
                                                                   NVL(v_ssi_unit_flag,'N'),
                                                                   v_tot_excise_amt,
                                                                   v_rg23a_balance,
                                                                   v_rg23c_balance,
                                                                   v_pla_balance,
                                                                   v_basic_pla_balance,
                                                                   v_additional_pla_balance,
                                                                   v_other_pla_balance,
                                                                   v_basic_excise_duty_amount,
                                                                   v_add_excise_duty_amount ,
                                                                   v_oth_excise_duty_amount,
                                                                   v_export_oriented_unit,
                                                                   v_register_code,
                                                                   v_delivery_id  ,
                                                                   v_organization_id,
                                                                   v_location_id    ,
                                                                   ln_cess_amount   ,
                                                                   ln_sh_cess_amount   , --Bgowrava for forward porting bug#5989740
                                                                   lv_process_flag  ,
                                                                   lv_process_message
                                                                  );
                                --Ends here......................................
                                IF v_debug_flag ='Y' THEN
                                 v_myfilehandle := UTL_FILE.FOPEN(v_utl_location,'ja_in_wsh_dlry_dtls_au_trg.LOG','A');
                                 UTL_FILE.PUT_LINE(v_myfilehandle,'11 AFTER the jai_om_wsh_processing_pkg.excise_balance_check FUNCTION v_reg_type -> ' || v_reg_type);
                                END IF;
                                --***************************************************************************************************
                                ELSE
                                  OPEN get_item_dtls(v_organization_id,v_inventory_item_id);
                                  FETCH get_item_dtls INTO v_excise_flag,v_item_class;
                                  CLOSE get_item_dtls;
                                  IF v_item_class NOT IN ('OTIN', 'OTEX') THEN
                                        IF v_excise_exempt_type IN ('CT2_OTH', 'EXCISE_EXEMPT_CERT_OTH' ) THEN
                                          OPEN Get_Tax_Lines_Details_Cur1;
                                          FETCH Get_Tax_Lines_Details_Cur1 INTO v_modvat_tax_rate,v_rounding_factor;
                                          CLOSE Get_Tax_Lines_Details_Cur1;
                                        ELSE
                                          OPEN for_modvat_percentage(v_organization_id, v_location_id);
                                          FETCH   for_modvat_percentage INTO v_modvat_tax_rate;
                                          CLOSE for_modvat_percentage;
                                        END IF;
                                        v_exempt_bal := (NVL(v_exempt_bal, 0) + v_shipped_quantity * v_assessable_value * NVL(v_modvat_tax_rate,0))/100;
                                --*********************************************************************************************************
                                     IF v_debug_flag ='Y' THEN
                                      UTL_FILE.PUT_LINE(v_myfilehandle,'12 BEFORE the jai_om_wsh_pkg.get_excise_register_with_bal FUNCTION v_exempt_bal -> '|| v_exempt_bal);
                                     END IF;
                                                --Calling the Function by Nagaraj.s for Enh#2415656............................

                                        /*
                                        Following cursor added by ssumaith - bug#4171272
                                        */

                                        open   c_cess_amount(v_delivery_id);
                                        fetch  c_cess_amount into ln_cess_amount;
                                        close  c_cess_amount;


                                        -- start Bgowrava for forward porting bug#5989740

                                        open   c_sh_cess_amount(v_delivery_id);
                                        fetch  c_sh_cess_amount into ln_sh_cess_amount;
                                        close  c_sh_cess_amount;
                                        -- end Bgowrava for forward porting bug#5989740


                                        v_reg_type := jai_om_wsh_pkg.get_excise_register_with_bal
                                                                                   (v_pref_rg23a,
                                                                                    v_pref_rg23c,
                                                                                    v_pref_pla,
                                                                                    NVL(v_ssi_unit_flag,'N'),
                                                                                    v_exempt_bal,
                                                                                    v_rg23a_balance,
                                                                                    v_rg23c_balance,
                                                                                    v_pla_balance,
                                                                                    v_basic_pla_balance,
                                                                                    v_additional_pla_balance,
                                                                                    v_other_pla_balance,
                                                                                    v_basic_excise_duty_amount,
                                                                                    v_add_excise_duty_amount ,
                                                                                    v_oth_excise_duty_amount,
                                                                                    v_export_oriented_unit,
                                                                                    v_register_code,
                                                                                    v_delivery_id,
                                                                                    v_organization_id,
                                                                                    v_location_id    ,
                                                                                    ln_cess_amount   ,
                                                                                    ln_sh_cess_amount , --Bgowrava for forward porting bug#5989740
                                                                                    lv_process_flag  ,
                                                                                    lv_process_message
                                                                                    );
                                        --Ends here......................................
                                     IF v_debug_flag ='Y' THEN
                                        UTL_FILE.PUT_LINE(v_myfilehandle,'13 AFTER the jai_om_wsh_pkg.get_excise_register_with_bal FUNCTION v_reg_type -> '|| v_reg_type);
                     END IF;
                                --*********************************************************************************************************
                                                  v_basic_ed_amt := v_exempt_bal;
                                                  v_tot_basic_ed_amt := NVL(v_tot_basic_ed_amt,0) + v_exempt_bal;
                                                  v_remarks := 'Against Modvat Recovery'||'-'||v_excise_exempt_refno;
                                                  IF v_debug_flag ='Y' THEN
                                                UTL_FILE.PUT_LINE(v_myfilehandle,'14  v_basic_ed_amt -> '|| v_basic_ed_amt||', v_tot_basic_ed_amt -> '|| v_tot_basic_ed_amt);
                                                UTL_FILE.FCLOSE(v_myfilehandle);
                          END IF;
                                         END IF;
                                        END IF;
                                  END IF;
                        ELSIF NVL(v_register_code,'N') IN ('BOND_REG') THEN
                          v_bond_tax_amount := NVL(v_tot_excise_amt,0) + NVL(v_bond_tax_amount,0);

                          -- commenting the following cursor definition as balance already fetched using the call to bond register package

                          /*OPEN   register_balance_cur(v_organization_id, v_location_id);
                          FETCH  register_balance_cur INTO v_register_balance;
                          CLOSE  register_balance_cur;
                          */

                          jai_cmn_bond_register_pkg.GET_REGISTER_DETAILS(v_asst_register_id,
                                                                   v_register_balance,
                                                                   v_reg_exp_date ,
                                                                   v_lou_flag);


                          -- added logic to check if the register validity is ok
                          IF nvl(v_reg_exp_date,sysdate) < sysdate then
/*                              RAISE_APPLICATION_ERROR(-20122, 'Bonded Register Validity has Expired on ' || v_reg_exp_date);
                          */ pv_return_code := jai_constants.expected_error ; pv_return_message :=  'Bonded Register Validity has Expired on ' || v_reg_exp_date ; return ;
                          end if;
                          -- added the letter of undertaking comparison in the following if.
                          -- logic is : to check if it is a letter of undertaking and only then if balance is a problem , raise an error
                          v_tot_excise_amt := v_tot_excise_amt * v_curr_conv_rate; /* ssumaith - bug#6487667*/
                          IF NVL(v_register_balance,0) < NVL(v_tot_excise_amt,0) and nvl(v_lou_flag,'N') = 'N' THEN
/*                                 RAISE_APPLICATION_ERROR(-20120, 'Bonded Register Has Balance -> '
                                || TO_CHAR(v_register_balance) || ' ,which IS less than Excisable Amount -> '
                                || TO_CHAR(v_tot_excise_amt)); */ pv_return_code := jai_constants.expected_error ; pv_return_message := 'Bonded Register Has Balance -> '|| TO_CHAR(v_register_balance) || ' ,which IS less than Excisable Amount -> '
                                || TO_CHAR(v_tot_excise_amt) ; return ;
                          END IF;
                        END IF;
                  END IF;
          END IF;
          END IF;
        -- end
        ---------------------------------------------------------------------------------------
        Exception
        When Others then
/*           raise_application_error (-20001,substr(sqlerrm,1,200)); */ pv_return_code := jai_constants.expected_error ; pv_return_message := substr(sqlerrm,1,200) ; return ;

  END ARU_T3 ;

 PROCEDURE ARU_T4 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS

  CURSOR  c_check_lc_order
 IS
 SELECT
        lc_flag
 FROM
        JAI_OM_OE_SO_LINES
 WHERE
        lc_flag        = 'Y'    AND
        header_id      = pr_new.source_header_id;

v_check_lc_order   VARCHAR2(1);
ln_cnt                 NUMBER;


  BEGIN
    pv_return_code := jai_constants.successful ;


  OPEN   c_check_lc_order;
  FETCH  c_check_lc_order INTO v_check_lc_order;
  CLOSE  c_check_lc_order;

  IF NVL(v_check_lc_order,'N') = 'Y' THEN

    IF nvl(pr_new.SHIPPED_QUANTITY,0) <> nvl(pr_old.SHIPPED_QUANTITY,0) THEN

      Select count(delivery_detail_id) into ln_cnt
      from jai_wsh_del_details_gt
      Where delivery_detail_id = pr_new.delivery_detail_id;

     IF nvl(ln_cnt,0) > 0 THEN
       Update jai_wsh_del_details_gt
       set shipped_quantity = pr_new.shipped_quantity
       where delivery_detail_id = pr_new.delivery_detail_id;

     ELSE
       Insert into jai_wsh_del_details_gt(
                                delivery_detail_id,
                                organization_id ,
                                inventory_item_id,
                                source_header_type_id,
                                shipped_quantity,
                                source_header_id,
                                source_line_id,
                                SPLIT_FROM_DELIVERY_DETAIL_ID,
                                processed_flag)
                                         Values
                                (
                                pr_new.delivery_detail_id,
                                pr_new.organization_id ,
                                pr_new.inventory_item_id,
                                pr_new.source_header_type_id,
                                pr_new.shipped_quantity,
                                pr_new.source_header_id,
                                pr_new.source_line_id,
                                pr_new.SPLIT_FROM_DELIVERY_DETAIL_ID,
                                'N'
                                );
    END IF;
   END IF;
 END IF;
  END ARU_T4 ;

END JAI_OM_WDD_TRIGGER_PKG ;

/
