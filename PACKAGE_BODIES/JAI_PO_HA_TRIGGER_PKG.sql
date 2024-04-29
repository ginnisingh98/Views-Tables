--------------------------------------------------------
--  DDL for Package Body JAI_PO_HA_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_PO_HA_TRIGGER_PKG" AS
/* $Header: jai_po_ha_t.plb 120.3.12010000.3 2009/04/09 13:27:59 nprashar ship $ */

/*
  REM +======================================================================+
  REM NAME          ARU_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_PO_HA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_PO_HA_ARU_T1
  REM
  REM +======================================================================+
*/
  PROCEDURE ARU_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
   CURSOR c_check_osp_po_distrib is
   select 1
   from   po_lines_all pol
   where  po_header_id = pr_new.po_header_id
   and    exists
   (select 1
    from   po_line_types_b
    where  line_type_id = pol.line_type_id
    and    outside_operation_flag = 'Y'
   );

   cursor c_set_of_books is
   select set_of_books_id
   from   po_distributions_all
   where  po_header_id = pr_new.po_header_id;

   CURSOR c_Sob_Cur(cp_set_of_books_id number) is
   select Currency_code
   from   gl_sets_of_books
   where  set_of_books_id = cp_set_of_books_id;

   ln_sob_id     number;
   lv_sob_cur    gl_sets_of_books.Currency_code%type;
   ln_osp_flag   number;
   v_sqlerrm     varchar2(210);


  BEGIN
    pv_return_code := jai_constants.successful ;
    /*--------------------------------------------------------------------------------------------------------------------------
 FILENAME: ja_in_create_57F4.sql

 CHANGE HISTORY:
S.No      Date          Author and Details
1        23/05/2003     Nagaraj.s for Bug2728485 Version : 616.1

      This Issue corresponds to the Code Merge
      The Average Cost of the Item is not previously picked up.
      The Costs are picked up in the Following Order, means if the First One is not
      found then the Program tries to Pick up the cost from the second combination.

      1. List_Price from so_price_list_lines for the combination of
        Item,Vendor,Vendor Site and UOM Code.

      2. List_Price from so_price_list_lines for the combination of
            Item,Vendor,Vendor Site =0 and UOM Code.

      3. list_price_per_unit from mtl_system_items for Item,Organization combination

      4. Item_Cost from CST_Item_Costs Table for Organization,Item



2.      11/08/2003      Sriram - Bug # 3021456 File Version 616.2

                        When a Phantom item exists as a part of the Bill of materials ,
                        the phantom item needs to be exploded until its atomic element.

                        This is achived by doing the following.

                        1) Added a new loop which explodes each of the phantom items
                           This is done by making an API call to the BOM routine.
                        2) Added another loop which inserts the atomic elements in that
                           belong to a phantom item instead of the phantom item itself.

                        3) Changed the Quantity to correctly reflect the po Qty * component quantity instead of just the po_qty.

3.   01/11/2004       ssumaith - bug#3179320  - file version 115.1

                       Removed the code to populate the 57F4 details from the trigger and instead calling the procedure
                       jai_po_osp_pkg.ja_in_57F4_process_header. This creates a dependency for future bugs.


4.   29-nov-2004  ssumaith - bug# 4037690  - File version 115.3
                   Check whether india localization is being used was done using a INR check in every trigger.
                   This check has now been moved into a new package and calls made to this package from this trigger
                   If the function jai_cmn_utils_pkg.check_jai_exists returns true it means INR is the set of books currency ,
                   Hence if this function returns FALSE , control should return.

5.   08-dec-2004 ssumaith - bug# 4037690  - File version 115.4

                   comparison in the cursor c_set_of_books was incorrect. This cursor was refering to po_release_id
                   instead of po_header_id. This has been corrected now.

6.   08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old
                   DB Entity as required for CASE COMPLAINCE.  Version 116.1

7. 13-Jun-2005    File Version: 116.2
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done

8    07/12/2005   Hjujjuru for the bug 4866533 File version 120.1
                    added the who columns in the insert of JAI_CMN_ERRORS_T
                    Dependencies Due to this bug:-
                    None

Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Current Version    Current Bug    Dependent           Files                Version   Author   Date          Remarks
Of File                           On Bug/Patchset    Dependent On

ja_in_create_57f4_trg.sql
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
115.2              4037690        IN60105D2          ja_in_util_pkg_s.sql  115.0     ssumaith 29-Nov-2004  Call to this function.
                                                     ja_in_util_pkg_s.sql  115.0     ssumaith

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

   open  c_set_of_books;
   fetch c_set_of_books into ln_sob_id;
   close c_set_of_books;

   --If jai_cmn_utils_pkg.check_jai_exists(P_CALLING_OBJECT => 'JA_IN_CREATE_57F4', P_SET_OF_BOOKS_ID => ln_sob_id) = false then
   --   return;
   --end if;

   /*The following code has been commented and added the above code instead - ssumaith - bug# 4037690*/

   /*
   open  c_Sob_Cur(ln_sob_id);
   fetch c_Sob_Cur into lv_sob_cur;
   close c_Sob_Cur;

   if lv_sob_cur <> 'INR' then
      return;
   end if;
   */
    open  c_check_osp_po_distrib;
    fetch c_check_osp_po_distrib into ln_osp_flag;
    close c_check_osp_po_distrib;

    if nvl(ln_osp_flag, -1) = 1 then

        jai_po_osp_pkg.ja_in_57F4_process_header
        (
          pr_new.po_header_id   ,
          NULL, /* release id */
          pr_new.vendor_id,
          pr_new.vendor_site_id,
          'PO'
          );
    end if;

exception
when others then
    v_sqlerrm := substr(sqlerrm,1,200);
    insert into JAI_CMN_ERRORS_T
    ( APPLICATION_SOURCE                 ,
      ERROR_MESSAGE                  ,
      ADDITIONAL_ERROR_MESG          ,
      CREATION_DATE                  ,
      CREATED_BY ,
      -- added, Harshita for Bug 4866533
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE
      )
    values
    ( 'ja_in_create_57F4',
      'error occured'    ,
      v_sqlerrm ,
      sysdate  ,
      fnd_global.user_id,
      -- added, Harshita for Bug 4866533
      fnd_global.user_id,
      sysdate
    );
  END ARU_T1 ;

  /*
  REM +======================================================================+
  REM NAME          ARU_T2
  REM
  REM DESCRIPTION   Called from trigger JAI_PO_HA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_PO_HA_ARU_T3
  REM
  REM +======================================================================+
  */
PROCEDURE ARU_T2 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
    v_po_hdr_id           NUMBER; --File.Sql.35 Cbabu           :=  pr_new.Po_Header_Id;
  v_curr                VARCHAR2(3); --File.Sql.35 Cbabu      :=  pr_new.Currency_Code;
  v_old_curr            VARCHAR2(3); --File.Sql.35 Cbabu      :=  pr_old.Currency_Code;
  v_last_upd_dt     DATE ; --File.Sql.35 Cbabu            :=  pr_new.Last_Update_Date ;
  v_last_upd_by     NUMBER; --File.Sql.35 Cbabu           :=  pr_new.Last_Updated_By;
  v_last_upd_login  NUMBER ; --File.Sql.35 Cbabu          :=  pr_new.Last_Update_Login;

  BEGIN
    pv_return_code := jai_constants.successful ;
   /*------------------------------------------------------------------------------------------
 FILENAME: Ja_In_Po_Hdr_Curr_Upd_Trg.sql

 CHANGE HISTORY:
S.No Date         Author and Details
1.   29/Nov/2004  Aiyer for bug#4035566. Version#115.1
                  Issue:-
                   The trigger should not get fired when the  non-INR based set of books is attached to the current operating unit
                   where transaction is being done.

                  Fix:-
                   Function jai_cmn_utils_pkg.check_jai_exists is being called which returns the TRUE if the currency is INR and FALSE if the currency is
                   NON-INR
                   Removed the cursors Fetch_Book_Id_Cur and Sob_Cur and the variables v_operating_id and v_gl_set_of_bks_id

                  Dependency Due to this Bug:-
                   The current trigger becomes dependent on the function jai_cmn_utils_pkg.check_jai_exists version 115.0 introduced through the bug 4033992

2.   08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old
                   DB Entity as required for CASE COMPLAINCE.  Version 116.1

3. 13-Jun-2005    File Version: 116.2
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done

 Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Current Version    Current Bug    Dependent           Files                Version   Author   Date          Remarks
Of File                           On Bug/Patchset     Dependent On
ja_in_po_hdr_curr_upd_trg
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
115.1              4035566        IN60105D2 + 4033992 ja_in_util_pkg_s.sql  115.0     Aiyer    29-Nov-2004  Call to this function.
                                                      ja_in_util_pkg_b.sql  115.0

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

  v_po_hdr_id           :=  pr_new.Po_Header_Id;
  v_curr                :=  pr_new.Currency_Code;
  v_old_curr            :=  pr_old.Currency_Code;
  v_last_upd_dt     :=  pr_new.Last_Update_Date ;
  v_last_upd_by     :=  pr_new.Last_Updated_By;
  v_last_upd_login  :=  pr_new.Last_Update_Login;
  /*
  || Code added by aiyer for the bug 4035566
  || Call the function jai_cmn_utils_pkg.check_jai_exists to check the current set of books in INR/NON-INR based.
  */

  --IF jai_cmn_utils_pkg.check_jai_exists ( p_calling_object      => 'JA_IN_PO_HDR_CURR_UPD_TRG'                             ,
  --                                 p_org_id              => pr_new.org_id
  --                               )  = FALSE
  --THEN
    /*
    || return as the current set of books is NON-INR based
    */
  --  RETURN;
  -- END IF;



    UPDATE JAI_PO_TAXES
    SET    Currency = v_curr,
         Last_Update_Date = v_last_upd_dt,
         Last_Updated_By = v_last_upd_by,
         Last_Update_Login = v_last_upd_login
    WHERE  Po_Header_Id = v_po_hdr_id
     AND   Currency = v_old_curr;

  END ARU_T2 ;

  /*
  REM +======================================================================+
  REM NAME          ARU_T3
  REM
  REM DESCRIPTION   Called from trigger JAI_PO_HA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_PO_HA_ARU_T4
  REM
  REM +======================================================================+
  */
PROCEDURE ARU_T3 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
     v_vendor_id                 NUMBER; --File.Sql.35 Cbabu           :=  NVL( pr_new.Vendor_Id, 0 );
    v_vendor_site_id            NUMBER; --File.Sql.35 Cbabu           :=  NVL( pr_new.Vendor_Site_Id, 0 );
    v_po_hdr_id                 NUMBER; --File.Sql.35 Cbabu           :=  pr_new.Po_Header_Id;
    v_type_lookup_code          VARCHAR2(30); --File.Sql.35 Cbabu     :=  pr_new.Type_Lookup_Code;
    v_quot_class_code           VARCHAR2(30); --File.Sql.35 Cbabu     :=  pr_new.Quotation_Class_Code;
    v_ship_loc_id               NUMBER ; --File.Sql.35 Cbabu          :=  pr_new.Ship_To_Location_Id;
    v_org_id                    NUMBER;
    v_po_org_id                 NUMBER ; --File.Sql.35 Cbabu          :=  NVL( pr_new.Org_Id, -999 );
    v_rate                      NUMBER; --File.Sql.35 Cbabu           :=  pr_new.Rate;
    v_rate_type                 VARCHAR2(100); --File.Sql.35 Cbabu    :=  pr_new.Rate_Type;
    v_rate_date                 DATE ; --File.Sql.35 Cbabu            :=  pr_new.Rate_Date;
    v_ship_to_loc_id            NUMBER; --File.Sql.35 Cbabu           :=  pr_new.Ship_To_Location_Id;


    v_next_val                  NUMBER;
    line_loc_flag               BOOLEAN;

    v_assessable_value          NUMBER;
    ln_vat_assess_value         NUMBER;  -- added, Harshita for bug #4245062
    v_func_curr                 VARCHAR2(15);
    v_curr                      VARCHAR2(100);  --File.Sql.35 Cbabu        :=  pr_new.Currency_Code;
    v_conv_rate                 NUMBER;

    flag                        VARCHAR2(10);

    v_line_cnt                  NUMBER;
    v_tax_flag                  VARCHAR2(1);
    v_old_vendor_id             NUMBER;
    v_item_id                   NUMBER;
    v_qty                       NUMBER;
    v_price                     NUMBER;
    v_uom                       VARCHAR2(25);
    v_line_uom                  VARCHAR2(25);

    v_cre_dt                    DATE ;  --File.Sql.35 Cbabu                :=  pr_new.Creation_Date;
    v_cre_by                    NUMBER;  --File.Sql.35 Cbabu               :=  pr_new.Created_By;
    v_last_upd_dt               DATE  ;  --File.Sql.35 Cbabu               :=  pr_new.Last_Update_Date ;
    v_last_upd_by               NUMBER;  --File.Sql.35 Cbabu               :=  pr_new.Last_Updated_By;
    v_last_upd_login            NUMBER;  --File.Sql.35 Cbabu               :=  pr_new.Last_Update_Login;

    v_service_Type_code         VARCHAR2(30); /* ssumaith - bug# 6109941 */

    CURSOR Fetch_Org_Id_Cur IS
    SELECT Inventory_Organization_id
    FROM   Hr_Locations
    WHERE  Location_Id = v_ship_loc_id;

    -- Get the Line Focus Id from the Sequence

    CURSOR Fetch_Focus_Id IS
    SELECT JAI_PO_LINE_LOCATIONS_S.NEXTVAL
    FROM   Dual;

    CURSOR Chk_Line_Count IS
    SELECT NVL( COUNT( Po_Line_Id ), 0 )
    FROM   JAI_PO_LINE_LOCATIONS
    WHERE  Po_Header_Id = v_po_hdr_id;


    CURSOR Lines_Cur IS
    SELECT DISTINCT Po_Line_Id
    FROM   JAI_PO_LINE_LOCATIONS
    WHERE  Po_Header_Id = v_po_hdr_id;

    CURSOR Fetch_Item_Cur( Lineid IN NUMBER ) IS
    SELECT Item_Id
    FROM   Po_Lines_All
    WHERE  Po_Line_Id = Lineid;

    CURSOR Line_Loc_Cur( lineid IN NUMBER ) IS
    SELECT Line_Location_Id
    FROM   JAI_PO_LINE_LOCATIONS
    WHERE  Po_Line_Id = lineid;

    CURSOR Fetch_Dtls_Cur( lineid IN NUMBER ) IS
    SELECT Quantity, Unit_Price, Unit_Meas_Lookup_Code
    FROM   Po_Lines_All
    WHERE  Po_Line_Id = lineid;

    CURSOR Fetch_Dtls1_Cur( lineid IN NUMBER, linelocid IN NUMBER ) IS
    SELECT Quantity, Price_Override, Unit_Meas_Lookup_Code
    FROM   Po_Line_Locations_All
    WHERE  Po_Line_Id = lineid
    AND   Line_Location_Id = linelocid;


    CURSOR Fetch_UOMCode_Cur IS
    SELECT Uom_Code
    FROM   Mtl_Units_Of_Measure
    WHERE  Unit_Of_Measure = v_uom;

    CURSOR Tax_Flag1_Cur( lineid IN NUMBER ) IS
    SELECT NVL( Tax_Modified_Flag, 'N' )
    FROM   JAI_PO_LINE_LOCATIONS
    WHERE  Po_Line_Id = lineid
    AND   Line_Location_Id IS NULL;


    CURSOR Tax_Flag_Cur( lineid IN NUMBER, linelocid IN NUMBER ) IS
    SELECT NVL( Tax_Modified_Flag, 'N' )
    FROM   JAI_PO_LINE_LOCATIONS
    WHERE  Po_Line_Id = lineid
    AND   Line_Location_Id = linelocid;


    CURSOR Chk_Vendor( lineid IN NUMBER, linelocid IN NUMBER ) IS
    SELECT Vendor_Id
    FROM   JAI_PO_TAXES
    WHERE  Po_Line_Id = lineid
    AND   Line_Location_Id = linelocid;

    CURSOR Chk_Vendor1( lineid IN NUMBER )  IS
    SELECT Vendor_Id
    FROM   JAI_PO_TAXES
    WHERE  Po_Line_Id = lineid
    AND   Line_Location_Id IS NULL;

   --This code is added to check value of Tax Override Flag for the Supplier,Supplier_site_id
   --by RK and GSR on 19-Apr-2001

    CURSOR tax_override_flag_cur(c_supplier_id number, c_supp_site_id number) IS
    SELECT  override_flag
    FROM    JAI_CMN_VENDOR_SITES
    WHERE   vendor_id = c_supplier_id
    AND     vendor_site_id = c_supp_site_id;

    v_override_flag varchar2(1);

  BEGIN
    pv_return_code := jai_constants.successful ;
    /*--------------------------------------------------------------------------------------------------------------
 FILENAME: Ja_In_Po_Hdr_Vendor_Upd_Trg.sql

CHANGE HISTORY:
SL.No      Date           Author and Details
1         19-Apr-2001    RK and GSR. Version#614.1
                         Code has been added to Check for override_flag for vendor and Vendor_site_id.

2.        08-mar-2004    Aparajita. Bug#3030483. Version#619.1
                         Vendor id gets updated for a PO for supplier merge scenario. Data in receipt tax table
                         JAI_RCV_LINE_TAXES still used to hold the old vendor. Added code on top to update
                         this vendor id as there are multiple return statements in the code.

                         There is no need to update the vendor site as it is only for third party tax.

3.        29/Nov/2004    Aiyer for bug#4035566. Version#115.1
                          Issue:-
                          The trigger should not get fires when the  non-INR based set of books is attached to the current operating unit
                          where transaction is being done.

                          Fix:-
                          Function jai_cmn_utils_pkg.check_jai_exists is being called which returns the TRUE if the currency is INR and FALSE if the currency is
                          NON-INR

                          Dependency Due to this Bug:-
                  The current trigger becomes dependent on the function jai_cmn_utils_pkg.check_jai_exists version 115.0. introduced through the bug 4033992

4.        23/Jan/2005     brathod for bug#4030192 Version#115.2
                          Issue:-   Trigger is not updating the vendor_id field in JAI_PO_TAXES
                                    when a PO having no vendor is updated with the new vendor.

                          Fix :-    Modified condition that checks wether pr_old.vendor_id is equal to vendor_id in
                                    JAI_PO_TAXES.  The condition was evaluating to false because
                                    comparision like "Null = Null".

5.       17-Mar-2005  hjujjuru - bug #4245062  File version 115.3
                      The Assessable Value is calculated for the transaction. For this, a call is
                      made to the function ja_in_vat_assessable_value_f.sql with the parameters
                      relevant for the transaction. This assessable value is again passed to the
                      procedure that calucates the taxes.

                      Base bug - #4245089

                          Dependency Due to this Bug:-
                          None
6.      31-Mar-2005 Brathod, Bug#4242351, File Version 115.5
                        Issue :- Procedure jai_po_tax_pkg.copy_reqn_taxes is modified for mutating error and new
               arguments are added in the procedure signature that must be passed from
         current trigger.  Call to jai_po_tax_pkg.copy_reqn_taxes procedure in the current
         trigger needs to be modified.

      Fix:-    call to jai_po_tax_pkg.copy_reqn_taxes is modified by passing the required
               new arguments.

7.    08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old
                    DB Entity as required for CASE COMPLAINCE.  Version 116.1

8. 13-Jun-2005    File Version: 116.2
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done

9. 08-Jul-2005    Sanjikum for Bug#4483042
                  1) Added a call to jai_cmn_utils_pkg.validate_po_type, to check whether for the current PO
                     IL functionality should work or not.

10. 12-Jul-2005   Sanjikum for Bug#4483042
                  1) Changed the parameter being passed to jai_cmn_utils_pkg.validate_po_type


 Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )
----------------------------------------------------------------------------------------------------------------------------------------------------------
Current Version    Current Bug    Dependent           Files                Version   Author   Date          Remarks
Of File                           On Bug/Patchset    Dependent On
ja_in_po_hdr_vendor_upd_trg
----------------------------------------------------------------------------------------------------------------------------------------------------
115.1              4035566        IN60105D2 +
                                  4033992           ja_in_util_pkg_s.sql  115.0     Aiyer    29-Nov-2004  Call to this function.
                          ja_in_util_pkg_b.sql  115.0

115.2              4245062       IN60106 + 4245089                                  hjujjuru  17/03/2005   VAT Implelentation
----------------------------------------------------------------------------------------------------------------------------------------------------*/


  --File.Sql.35 Cbabu
  v_vendor_id                 :=  NVL( pr_new.Vendor_Id, 0 );
  v_vendor_site_id            :=  NVL( pr_new.Vendor_Site_Id, 0 );
  v_po_hdr_id                 :=  pr_new.Po_Header_Id;
  v_type_lookup_code          :=  pr_new.Type_Lookup_Code;
  v_quot_class_code           :=  pr_new.Quotation_Class_Code;
  v_ship_loc_id               :=  pr_new.Ship_To_Location_Id;
  v_po_org_id                 :=  NVL( pr_new.Org_Id, -999 );
  v_rate                      :=  pr_new.Rate;
  v_rate_type                 :=  pr_new.Rate_Type;
  v_rate_date                 :=  pr_new.Rate_Date;
  v_ship_to_loc_id            :=  pr_new.Ship_To_Location_Id;
  v_curr                      :=  pr_new.Currency_Code;
  v_cre_dt                    :=  pr_new.Creation_Date;
  v_cre_by                    :=  pr_new.Created_By;
  v_last_upd_dt               :=  pr_new.Last_Update_Date ;
  v_last_upd_by               :=  pr_new.Last_Updated_By;
  v_last_upd_login            :=  pr_new.Last_Update_Login;


  /*
  || Code added by aiyer for the bug 4035566
  || Call the function jai_cmn_utils_pkg.check_jai_exists to check the current set of books in INR/NON-INR based.
  */
  --IF jai_cmn_utils_pkg.check_jai_exists ( p_calling_object      => 'JA_IN_PO_HDR_VENDOR_UPD_TRG' ,
  --                 p_org_id              => pr_new.org_id
  --                               )  = FALSE
  --THEN
    /*
  || return as the current set of books is NON-INR based
  */
  --  RETURN;
  -- END IF;

  --code added by Sanjikum for Bug#4483042
  IF jai_cmn_utils_pkg.validate_po_type(p_style_id => pr_new.style_id) = FALSE THEN
    return;
  END IF;

    -- Start added for bug#3030483
  IF pr_new.vendor_id <> pr_old.vendor_id then
    for c_receipt_rec in
    (
    select  distinct shipment_header_id, shipment_line_id
    from    rcv_transactions
    where   po_header_id = pr_new.po_header_id
    )
    loop
        update JAI_RCV_LINE_TAXES
        set    vendor_id = pr_new.vendor_id
        where  shipment_header_id =  c_receipt_rec.shipment_header_id
        and    shipment_line_id =  c_receipt_rec.shipment_line_id
        and    vendor_id  = pr_old.vendor_id;
    end loop;
  END IF;
    -- End added for bug#3030483

    --This code is added to check value of Tax Override Flag for the Supplier,Supplier_site_id
    --by RK and GSR on 19-Apr-2001
    OPEN  tax_override_flag_cur(v_vendor_id, v_vendor_site_id);
    FETCH tax_override_flag_cur into v_override_flag;
    CLOSE tax_override_flag_cur;

    OPEN  Chk_Line_Count;
    FETCH Chk_Line_Count INTO v_line_cnt;
    CLOSE Chk_Line_Count;

    -- Get the Inventory Organization Id

    OPEN  Fetch_Org_Id_Cur;
    FETCH Fetch_Org_Id_Cur INTO v_org_id;
    CLOSE fetch_Org_Id_Cur;

    FOR Rec IN Lines_Cur  LOOP

        FOR Rec1 IN Line_Loc_Cur( Rec.Po_Line_Id )  LOOP

            IF NVL( Rec1.Line_Location_Id, -999 ) = -999  THEN

                /** Added by Sriram **/

                IF nvl(v_override_flag,'N') = 'Y' THEN

                    DELETE FROM JAI_PO_TAXES
                    WHERE po_header_id = v_po_hdr_id;

                    jai_po_tax_pkg.copy_reqn_taxes
                    (
                    v_Vendor_Id ,
                    v_Vendor_Site_Id,
                    v_Po_Hdr_Id ,
                    Rec.Po_Line_Id, --added by Sriram on 22-Nov-2001
                    Rec1.Line_Location_Id, --added by Sriram on 22-Nov-2001
                    v_Type_Lookup_Code ,
                    v_Quot_Class_Code ,
                    v_Ship_To_Loc_Id ,
                    v_Org_Id ,
                    v_Cre_Dt ,
                    v_Cre_By ,
                    v_Last_Upd_Dt ,
                    v_Last_Upd_By ,
                    v_Last_Upd_Login
        /* Added by brathod, For Bug#4242351 */
        ,v_rate
        ,v_rate_type
        ,v_rate_date
        ,v_curr
        /* End of Bug#4242351 */
                    );
                    RETURN;

                END IF;

                /** End Addition **/


                OPEN  Tax_Flag1_Cur( Rec.Po_Line_Id );
                FETCH Tax_Flag1_Cur INTO v_tax_flag;
                CLOSE Tax_Flag1_Cur;

                OPEN  Fetch_Dtls_Cur( Rec.Po_Line_Id );
                FETCH Fetch_Dtls_Cur INTO v_qty, v_price, v_uom;
                CLOSE Fetch_Dtls_Cur;

                v_line_uom := v_uom;
                line_loc_flag := FALSE;

            ELSE

                OPEN  Tax_Flag_Cur( Rec.Po_Line_Id, Rec1.Line_Location_Id );
                FETCH Tax_Flag_Cur INTO v_tax_flag;
                CLOSE Tax_Flag_Cur;

                OPEN  Fetch_Dtls1_Cur( Rec.Po_Line_Id, Rec1.Line_Location_Id );
                FETCH Fetch_Dtls1_Cur INTO v_qty, v_price, v_uom;
                CLOSE Fetch_Dtls1_Cur;

                IF v_uom IS NULL THEN
                    FOR uom_rec IN  Fetch_Dtls_Cur( Rec.Po_Line_Id ) LOOP
                        v_uom := uom_rec.unit_meas_lookup_code;
                    END LOOP;
                END IF;

                line_loc_flag := TRUE;

            END IF;

            --v_uom := NVL( v_uom, v_line_uom );
            OPEN  Fetch_UOMCode_Cur;
            FETCH Fetch_UOMCode_Cur INTO v_uom;
            CLOSE Fetch_UOMCode_Cur;

            OPEN  Fetch_Item_Cur( Rec.Po_Line_Id );
            FETCH Fetch_Item_Cur INTO v_item_id;
            CLOSE Fetch_Item_Cur;

            v_assessable_value :=
            jai_cmn_setup_pkg.get_po_assessable_value
            (
            v_vendor_id, v_vendor_site_id,
            v_item_id, v_uom
            );

            v_conv_rate := v_rate;

            jai_po_cmn_pkg.get_functional_curr
            (
            v_ship_to_loc_id,
            v_po_org_id, v_org_id,
            v_curr, v_assessable_value,
            v_conv_rate,
            v_rate_type,
            v_rate_date,
            v_func_curr
            );


            IF NVL( v_assessable_value, 0 ) <= 0 THEN
                v_assessable_value := v_price * v_qty;
            ELSE
                v_assessable_value := v_assessable_value * v_qty;
            END IF;

            -- added, Harshita for bug #4245062

            ln_vat_assess_value :=
                        jai_general_pkg.ja_in_vat_assessable_value
                        ( p_party_id => v_vendor_id,
                          p_party_site_id => v_vendor_site_id,
                          p_inventory_item_id => v_item_id,
                          p_uom_code => v_uom,
                          p_default_price => v_price,
                          p_ass_value_date => trunc(SYSDATE),
                          p_party_type => 'V'
                        ) ;
            v_conv_rate := v_rate;

            jai_po_cmn_pkg.get_functional_curr
                                    (
                                    v_ship_to_loc_id,
                                    v_po_org_id, v_org_id,
                                    v_curr, ln_vat_assess_value,
                                    v_conv_rate,
                                    v_rate_type,
                                    v_rate_date,
                                    v_func_curr
            );

            ln_vat_assess_value := ln_vat_assess_value * v_qty;
            --ended, Harshita for bug #4245062

            IF v_tax_flag = 'N'  THEN

                DELETE FROM JAI_PO_TAXES
                WHERE Po_Line_Id = Rec.Po_Line_Id
                AND NVL( Line_Location_Id, -999 ) = NVL( Rec1.Line_Location_Id, -999 );


                DELETE FROM JAI_PO_LINE_LOCATIONS
                WHERE Po_Line_Id = Rec.Po_Line_Id
                AND NVL( Line_Location_Id, -999 ) = NVL( Rec1.Line_Location_Id, -999 );

                OPEN  Fetch_Focus_Id;
                FETCH Fetch_Focus_Id INTO v_next_val;
                CLOSE Fetch_Focus_Id;

                v_service_type_code := jai_ar_rctla_trigger_pkg.get_service_Type(v_vendor_id,v_vendor_site_id , 'V');
                /*above code added by ssumaith - bug# 6109941 */

                INSERT INTO JAI_PO_LINE_LOCATIONS
                (
                Line_Focus_Id,
                Line_Location_Id,
                Po_Line_Id,
                Po_Header_Id,
                Tax_Modified_Flag,
                Tax_Amount,
                Total_Amount,
                Creation_Date,
                Created_By,
                Last_Update_Date,
                Last_Updated_By,
                Last_Update_Login,
                service_type_code /* ssumaith - bug# 6109941*/
                )
                VALUES
                (
                v_next_val,
                Rec1.Line_Location_Id,
                Rec.po_line_id,
                v_po_hdr_id,
                'N',
                0,
                0,
                v_cre_dt,
                v_cre_by,
                v_last_upd_dt,
                v_last_upd_by,
                v_last_upd_login,
                v_service_type_code  /* added by ssumaith - bug# 6109941 */
                );

                IF v_type_lookup_code = 'BLANKET' OR v_quot_class_code = 'CATALOG' THEN
                    --Addition by Ramakrishna on 15/12/2000 to check taxes defaulting
                    if Rec1.line_location_id is null then
                        flag := 'INSLINES';
                    else
                        flag := 'I';
                    end if;

                    --end of addition by Ramakrishna
                ELSE
                    flag := 'I';
                END IF;

                jai_po_tax_pkg.Ja_In_Po_Case2
                (
                v_Type_Lookup_Code,
                v_Quot_Class_Code,
                pr_new.Vendor_Id,
                pr_new.Vendor_Site_Id,
                pr_new.Currency_Code,
                v_org_id,
                v_Item_Id,
                Rec1.Line_Location_Id,
                v_po_hdr_id,
                Rec.Po_Line_Id,
                v_price,
                v_qty,
                v_cre_dt,
                v_cre_by,
                v_last_upd_dt,
                v_last_upd_by,
                v_last_upd_login,
                v_uom,
                flag,
                NVL( v_assessable_value, -9999 ),
                ln_vat_assess_value, -- added, Harshita for bug #4245062
                NVL( v_conv_rate, 1 ),
		/* Bug 5096787. Added by Lakshmi Gopalsami */
                v_rate,
		v_rate_date,
		v_rate_type -- Bug 8319569. Changed the order of date and type
                );

            ELSE

                IF line_loc_flag THEN
                    OPEN  Chk_Vendor( Rec.Po_Line_Id, Rec1.Line_Location_Id );
                    FETCH Chk_Vendor INTO v_old_vendor_id;
                    CLOSE Chk_Vendor;

                    jai_po_tax_pkg.calculate_tax
                    (
                    'STANDARDPO',
                    v_po_hdr_id ,
                    Rec.Po_Line_Id,
                    Rec1.line_location_id,
                    v_qty, v_price*v_qty, v_uom, v_assessable_value,
                    NVL( v_assessable_value, v_price*v_qty ),
                    ln_vat_assess_value, -- added, Harshita for bug #4245062
                    NULL,
                    v_conv_rate
                    );

                ELSE

                    OPEN  Chk_Vendor1( Rec.Po_Line_Id );
                    FETCH Chk_Vendor1 INTO v_old_vendor_id;
                    CLOSE Chk_Vendor1;

                END IF;


              -- Before Modification for BUG#4030192
              -- IF pr_old.Vendor_Id = NVL( v_old_vendor_id, pr_old.Vendor_Id )     THEN

              -- Modified by Bhavik for BUG#4030192
                 IF NVL(pr_old.Vendor_Id,0) = NVL( v_old_vendor_id, NVL(pr_old.Vendor_Id,0) )     THEN

                    UPDATE JAI_PO_TAXES
                    SET    Vendor_Id = v_vendor_id
                    WHERE Vendor_id  = nvl(pr_old.vendor_id,0)   /*Added by nprashar for bug 8349329*/
                    AND       Po_Line_Id = Rec.Po_Line_Id
                    AND   nvl(Line_Location_Id,-999) = nvl(Rec1.Line_Location_Id,-999); /*Added by nprashar for bug 8349329*/

                END IF;

            END IF;

        END LOOP;

    END LOOP;
  END ARU_T3 ;

END JAI_PO_HA_TRIGGER_PKG ;

/
