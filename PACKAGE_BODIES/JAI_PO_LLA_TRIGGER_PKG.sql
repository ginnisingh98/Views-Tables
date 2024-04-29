--------------------------------------------------------
--  DDL for Package Body JAI_PO_LLA_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_PO_LLA_TRIGGER_PKG" AS
/* $Header: jai_po_lla_t.plb 120.6.12010000.5 2009/08/14 06:06:54 jijili ship $ */


/********************************************************************************

1.  Ramananada for bug#4703617. File Version 120.1
     To get the currency code from GL_SETS_OF_BOOKS table,
     ORG_ORGANIZATION_DEFINITIONS table is referred to get the Set_Of_Books_Id.
     But using this table has a performance impact. Hence using the table
     FINANCIALS_SYSTEM_PARAMS_ALL along with GL_SETS_OF_BOOKS talbe to get the
     currency code.
     Removed the references of ORG_ORGANIZATION_DEFINITIONS and instead used
     FINANCIALS_SYSTEM_PARAMS_ALL table

********************************************************************************/

/*
Bug 8586635 - Added the procedure to get the quantity from the parent Shipment
line to split the taxes in the child lines
Used Autonomous transaction as po_line_locations_all needs to be queried
*/
PROCEDURE ja_in_po_get_lineloc_p
(
p_line_loc_id IN NUMBER,
p_prev_quantity OUT NOCOPY NUMBER
) IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
select quantity into p_prev_quantity
from po_line_locations_all
where line_location_id =  p_line_loc_id;
END;

/*
  REM +======================================================================+
  REM NAME          ARD_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_PO_LLA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_PO_LLA_ARD_T1
  REM
  REM +======================================================================+
*/
  PROCEDURE ARD_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
    v_po_line_loc_id    NUMBER;--File.Sql.35 Cbabu   :=  pr_old.Line_Location_Id;

------------- added by Gsr 12-jul-01
 v_operating_id                     number;--File.Sql.35 Cbabu   :=pr_new.ORG_ID;
 v_gl_set_of_bks_id                 gl_sets_of_books.set_of_books_id%type;
 v_currency_code                     gl_sets_of_books.currency_code%type;

  /*
  || Commented the following two cursors as they are not used in the trigger
  || Ramananada for bug#4703617
  */
  /*
    CURSOR Fetch_Book_Id_Cur IS SELECT Set_Of_Books_Id
    FROM   Org_Organization_Definitions
    WHERE  Operating_unit  = v_operating_id; -- Modified by Ramananda for removal of SQL LITERALs
    --WHERE  NVL(Operating_unit,0)  = v_operating_id;
    CURSOR Sob_Cur is
    select Currency_code
    from gl_sets_of_books
    where set_of_books_id = v_gl_set_of_bks_id; */

------ End of addition by Gsri on 12-jul-01

  BEGIN
    pv_return_code := jai_constants.successful ;
    /*------------------------------------------------------------------------------------------
 FILENAME: Ja_In_Po_Tax_Delete_Trg.sql

 CHANGE HISTORY:
S.No      Date          Author and Details

1         29-Nov-2004   Sanjikum for 4035297. Version 115.1
                        Changed the 'INR' check. Added the call to jai_cmn_utils_pkg.check_jai_exists

2         08-Jun-2005   This Object is Modified to refer to New DB Entry names in place of Old
                        DB as required for CASE COMPLAINCE. Version 116.1

3.        13-Jun-2005   File Version: 116.2
                        Ramananda for bug#4428980. Removal of SQL LITERALs is done

Dependency Due to this Bug:-
The current trigger becomes dependent on the function jai_cmn_utils_pkg.check_jai_exists version 115.0.


Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Current Version    Current Bug    Dependent           Files                Version   Author   Date          Remarks
Of File                           On Bug/Patchset    Dependent On

ja_in_po_tax_delete_trg.sql
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
115.1              4035297        IN60105D2+4033992  ja_in_util_pkg_s.sql  115.0     Sanjikum 29-Nov-2004  Call to this function.
                                                     ja_in_util_pkg_s.sql  115.0   Sanjikum

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

  --File.Sql.35 Cbabu
  v_po_line_loc_id    :=  pr_old.Line_Location_Id;
  v_operating_id       :=pr_new.ORG_ID;

   /*
   || Commented by Ramananda for bug4703617
   || Reason:
   ||  v_gl_set_of_bks_id is not used in the trigger
   OPEN  Fetch_Book_Id_Cur ;
   FETCH Fetch_Book_Id_Cur INTO v_gl_set_of_bks_id;
   CLOSE Fetch_Book_Id_Cur;
   */


   --IF jai_cmn_utils_pkg.check_jai_exists(p_calling_object => 'JA_IN_PO_TAX_DELETE_TRG' ,
   --                               p_set_of_books_id => v_gl_set_of_bks_id) = FALSE THEN
   -- RETURN;
   -- END IF;

     DELETE FROM JAI_PO_LINE_LOCATIONS
      WHERE Line_Location_Id = v_po_line_loc_id;

     DELETE FROM JAI_PO_TAXES
      WHERE Line_Location_Id = v_po_line_loc_id;
  END ARD_T1 ;

  /*
  REM +======================================================================+
  REM NAME          ARI_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_PO_LLA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_PO_LLA_ARI_T2
  REM
  REM +======================================================================+
  */
  PROCEDURE ARI_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
    v_org_id        NUMBER;
  v_type_lookup_code    VARCHAR2(10);
  v_quot_class_code   VARCHAR2(25);
  v_vendor_id       NUMBER;
  v_vendor_site_id    NUMBER;
  v_curr          VARCHAR2(15);
  v_ship_loc_id     NUMBER;
  x           NUMBER;
  y           NUMBER;
  v_shipment_type     VARCHAR2(25); --File.Sql.35 Cbabu  := pr_new.Shipment_Type;
  v_shipment_num      NUMBER; --File.Sql.35 Cbabu        := pr_new.Shipment_Num; -- added on 13th oct subbu
  v_po_rel_id       NUMBER  ; --File.Sql.35 Cbabu      := pr_new.Po_Release_Id;
  v_src_ship_id         NUMBER  ; --File.Sql.35 Cbabu      := pr_new.Source_Shipment_Id;
  v_from_line_loc_id      NUMBER; --File.Sql.35 Cbabu        := pr_new.From_Line_Location_Id;
  v_from_line_id      NUMBER    ; --File.Sql.35 Cbabu    := pr_new.From_Line_Id;
  v_from_hdr_id           NUMBER; --File.Sql.35 Cbabu        := pr_new.From_Header_Id;
  v_quot_line_loc_id      NUMBER;
  v_line_loc_id     NUMBER    ; --File.Sql.35 Cbabu    := pr_new.Line_Location_Id;
  v_po_line_id      NUMBER    ; --File.Sql.35 Cbabu    := pr_new.Po_Line_Id ;
  v_po_hdr_id       NUMBER    ; --File.Sql.35 Cbabu    := pr_new.Po_Header_Id;
  v_q_hdr_id              NUMBER;
  v_q_line_id             NUMBER;
  v_q_line_num            NUMBER;
  v_line_focus_id         NUMBER;
  v_price         NUMBER ; --File.Sql.35 Cbabu       := pr_new.Price_Override;
  v_assessable_value      NUMBER;
  ln_vat_assess_value         NUMBER; /* rallamse bug#4250072  VAT */
  v_qty         NUMBER  ; --File.Sql.35 Cbabu      := pr_new.Quantity;
  v_cre_dt        DATE  ; --File.Sql.35 Cbabu      := pr_new.Creation_Date;
  v_cre_by        NUMBER ; --File.Sql.35 Cbabu       := pr_new.Created_By;
  v_last_upd_dt     DATE  ; --File.Sql.35 Cbabu      := pr_new.Last_Update_Date ;
  v_last_upd_by     NUMBER ; --File.Sql.35 Cbabu       := pr_new.Last_Updated_By;
  v_last_upd_login    NUMBER ; --File.Sql.35 Cbabu       := pr_new.Last_Update_Login;
  v_uom_measure     VARCHAR2(25); --File.Sql.35 Cbabu  := pr_new.Unit_Meas_Lookup_Code;
  v_uom_code              VARCHAR2(25);
  v_unit_code             VARCHAR2(25);
  v_tax_amt               NUMBER;
  success         NUMBER ; --File.Sql.35 Cbabu        := 1;

  /* Commented by rallamse bug#4479131 PADDR Elimination
  rel_found       BOOLEAN;
  --File.Sql.35 Cbabu        := FALSE;
  */
  --  found       BOOLEAN;
  dummy                   NUMBER;
  v_item_id       NUMBER;
  v_temp_uom        VARCHAR2(25);
  result                  BOOLEAN;
  req_id                  NUMBER;
  v_from_type_lookup_code VARCHAR2(25);    -- addition by subbu 11-oct-2000
  v_line_num              NUMBER;          -- added on 13th oct
  v_quot_from_hdr_id      NUMBER;          -- Added by subbu on 15-OCT-2000
  v_count                 NUMBER;          -- Added by subbu on 15-OCT-2000
  v_type                  VARCHAR2(1) ; -- Added by subbu on 16th-oct-00
  v_style_id              po_headers_all.style_id%TYPE; --Added by Sanjikum for Bug#4483042
  v_orig_ship_id          NUMBER; /*Bug 8586635*/

  v_service_type_code VARCHAR2(30); -- added brathod Bug#5879769


  CURSOR Check_Rfq_Quot_Cur IS
    SELECT From_Type_Lookup_Code, from_header_id,
      Type_Lookup_Code, Quotation_Class_Code,
      Vendor_id, Vendor_Site_Id, Currency_Code, Ship_To_Location_Id,
      style_id --Added by Sanjikum for Bug#4483042
    FROM   Po_Headers_All
    WHERE  Po_Header_Id = v_po_hdr_id;

  CURSOR Fetch_Org_Id_Cur IS
    SELECT Inventory_Organization_Id
    FROM   Hr_Locations
    WHERE  Location_Id = v_ship_loc_id;

  CURSOR Item_Id_Cur IS
    SELECT Item_Id, From_Header_Id, From_Line_Id, Line_Num
    FROM   Po_Lines_All
    WHERE  Po_Line_Id = v_po_line_id;

  CURSOR Fetch_Uom_Cur IS
    SELECT Unit_Meas_Lookup_Code
    FROM   Po_Lines_All
    WHERE  Po_Line_Id = v_po_line_id;

  v_operating_id      number; --File.Sql.35 Cbabu   :=pr_new.ORG_ID;
  v_gl_set_of_bks_id    gl_sets_of_books.set_of_books_id%type;
  v_currency_code     gl_sets_of_books.currency_code%type;


  /*
  || Commented the following two cursors as they are not used in the trigger
  || Ramananada for bug#4703617
  */
  /*
    CURSOR Fetch_Book_Id_Cur IS
      SELECT Set_Of_Books_Id
      FROM   Org_Organization_Definitions
      WHERE  Operating_unit  = v_operating_id; -- Modified by Ramananda for removal of SQL LITERALs
      --WHERE  NVL(Operating_unit,0)  = v_operating_id;
    CURSOR Sob_Cur is
      select Currency_code
      from gl_sets_of_books
      where set_of_books_id = v_gl_set_of_bks_id; */

  CURSOR tax_cur IS
    SELECT a.Po_Line_Id, a.tax_line_no lno, a.tax_id,
      a.precedence_1 p_1, a.precedence_2 p_2, a.precedence_3 p_3, a.precedence_4 p_4, a.precedence_5 p_5,
      a.currency, a.tax_rate, a.qty_rate, a.uom, a.tax_amount, a.tax_type, a.vendor_id, a.modvat_flag
    FROM   JAI_PO_TAXES a
    WHERE  NVL( a.line_location_id, -999 ) = DECODE( v_quot_line_loc_id, -999, -999, v_quot_line_loc_id )
    AND  Po_Line_Id = v_from_line_id
    ORDER BY  a.tax_line_no;

  CURSOR Fetch_Line_Focus_Id_Cur IS
    SELECT Line_Focus_Id
    FROM   JAI_PO_LINE_LOCATIONS
    WHERE  Po_Line_Id = v_po_line_id
    AND  Line_Location_Id = v_line_loc_id;

  CURSOR Fetch_UOMCode_Cur( v_temp_uom IN VARCHAR2 ) IS
    SELECT Uom_Code
    FROM   Mtl_Units_Of_Measure
    WHERE  Unit_Of_Measure = v_temp_uom;

  CURSOR Fetch_Count_Cur IS
    SELECT COUNT(Line_Location_Id)
    FROM   JAI_PO_LINE_LOCATIONS
    WHERE  Po_Header_Id = v_quot_from_hdr_id;

  -- Vijay Shankar for Bug# 3184418
  v_tax_modified_flag CHAR(1);
  CURSOR c_tax_modified_flag(p_line_location_id IN NUMBER) IS
    SELECT tax_modified_flag
    FROM JAI_PO_LINE_LOCATIONS
    WHERE line_location_id = p_line_location_id;

  /*Bug 8586635 - Start*/
  CURSOR c_get_po_taxes (p_line_location_id IN NUMBER) IS
  SELECT *
  FROM JAI_PO_TAXES
  WHERE line_location_id = p_line_location_id;

  CURSOR c_get_po_line_loc_details (p_line_location_id IN NUMBER) IS
  SELECT *
  FROM JAI_PO_LINE_LOCATIONS
  WHERE line_location_id = p_line_location_id;

  r_get_po_taxes            c_get_po_taxes%ROWTYPE;
  r_get_po_line_loc_details c_get_po_line_loc_details%ROWTYPE;
  l_prev_quantity           NUMBER;
  l_tax_amount              NUMBER;
  l_ship_line_amount        NUMBER;
  l_line_focus_id           NUMBER;
  /*Bug 8586635 - End*/

  v_hook_value VARCHAR2(10);
  BEGIN
    pv_return_code := jai_constants.successful ;

/*------------------------------------------------------------------------------------------
CHANGE HISTORY:
S.No      Date          Author and Details
--------------------------------------------------------------------------------------------
1   19/09/2002    Vijay Shankar(cbabu) for Bug# 2541354 (Pre- Requisite for future bugs that modify this file)
            When PO's are auto created from MRP workbench, then taxes are calculated properly
            according to the quantity passed to the tax defaulting code. But in the present
            situation quantity of fist distribution line present in shipment line is passed to tax
            defaulting code from where taxes are getting calculated.

            Solution: A batch program is made which should be run from Reports -> Run of India Local Purchasing responsibility
            to default the taxes if PO's are auto created as given in the Functional. This
            solution also solves the performance issue
            Instead of firing the concurrent 'Concurrent request for defaulting Taxes in PO when linked with Quotation'
            from this trigger, we are populating NEW temp table created and process them when the same
            concurrent is fired manually.
            This bug becomes a prerequisite for future Bugs that modifies this file.

2   16/12/2003     Vijay Shankar(cbabu) for Bug# 3184418, Fileversion: 618.1 (Obsoleted with Bug# 3570189)
            When a Quotation is copied from a Source Document, then code is modified to copy the taxes from the SOURCE
            document to Quotation if defaulted taxes on Source Document are modified by users

3   19/02/2004     Nagaraj.s for bug 3438863, Fileversion: 618.2 (Obsoleted with Bug# 3570189)
                Hook Functionality is incorporated by calling the package jai_cmn_hook_pkg.sql
              Hence this is a certain dependency issue and should be carefully handled

4     14/04/2004     Vijay Shankar for bugs# 3570189, Version : 619.1
                      PO Hook Functionality is made compatible with 11.5.3 Base Applications by removing last 12 params in call too
                      jai_cmn_hook_pkg.Ja_In_po_line_locations_all procedure. Also Locator related code is removed except for RELEASES
                      as defaultation happens whether the user navigated from localization form or not.
                      Tax defaultation is driven by jai_cmn_hook_pkg. By default taxes are defaulted for all PO's created in
                      Indian OU's (INR as Functional Currency)

            FileVersion: 618.2 is obsoleted with this Version
             This is a DEPENDANCY for later versions of the file

5   29-Nov-2004    Sanjikum for 4035297. Version 115.1
                   Changed the 'INR' check. Added the call to jai_cmn_utils_pkg.check_jai_exists

                  Dependency Due to this Bug:-
                  The current trigger becomes dependent on the function jai_cmn_utils_pkg.check_jai_exists version 115.0.

6.  19-Mar-05      rallamse for bug#4227171 Version#115.2
                   Remove automatic GSCC errors

7.  19-Mar-05      rallamse for bug#4250072 Version#115.3
                   Changes for VAT

8.  08-Jun-2005   This Object is Modified to refer to New DB Entry names in place of Old
                  DB as required for CASE COMPLAINCE. Version 116.1

9      13-Jun-2005    File Version: 116.3
                       Ramananda for bug#4428980. Removal of SQL LITERALs is done

10  06-Jul-2005 rallamse for bug# PADDR Elimination
                   1. Commented rel_found and call to jai_po_cmn_pkg.query_locator_for_release

11. 08-Jul-2005    Sanjikum for Bug#4483042
                  1) Added a call to jai_cmn_utils_pkg.validate_po_type, to check whether for the current PO
                     IL functionality should work or not.

11. 08-Jul-2005    Sanjikum for Bug#4483042, File Version 117.2
                   1) Added a new column style_id in cursor - Check_Rfq_Quot_Cur

12.	04-Jun-2007  	brathod for BUG#5879769, 6109941  File Version # 120.2
											Added a Call to function get_service_type to get the Service_Type_Code.

13. 22-Jun-2007   CSahoo for bug#6144740, File Version 120.4
									Added the parameter pr_new.quantity to the call to jai_po_tax_pkg.Ja_In_Po_Case1 procedure

14. 08-Jul-2009   Bug 8586635
                  Description: When the Shipment Lines are split in iSupplier, the appropriate Taxes are not updated
                  Fix: Tax Lines are inserted into jai_po_taxes on a prorated basis
                  and the tax amounts are updated in JAI_PO_LINE_LOCATIONS

15. 14-Aug-2009  Jia for bug#8745089 and bug#8765528.
                Issue: Create a new quotations or a BPA Release with incorrect price list successfully
                 Fix:  Add Item_UOM validation that is advanced pricing enhancement for quotation and Blanket.


Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )

---------------------------------------------------------------------------------------------
Current Version       Current Bug    Dependent            Files                 Version
Of File                              On Bug/Patchset      Dependent On
ja_in_po_tax_insert_trg.sql
---------------------------------------------------------------------------------------------
618.2(OBSOLETE)        3438863       IN60105D2 + 3438863
619.1                  3570189       IN60105D2 + 3570189

115.1                  4035297       IN60105D2+4033992    ja_in_util_pkg_s.sql  115.0
                                                          ja_in_util_pkg_s.sql  115.0

115.3                  4250072       IN60106 +
                                     4035297 +
                                     4245089
--------------------------------------------------------------------------------------------*/

--File.Sql.35 Cbabu
v_shipment_type       := pr_new.Shipment_Type;
v_shipment_num        := pr_new.Shipment_Num; -- added on 13th oct subbu
v_po_rel_id           := pr_new.Po_Release_Id;
v_src_ship_id         := pr_new.Source_Shipment_Id;
v_from_line_loc_id    := pr_new.From_Line_Location_Id;
v_from_line_id        := pr_new.From_Line_Id;
v_from_hdr_id         := pr_new.From_Header_Id;
v_line_loc_id         := pr_new.Line_Location_Id;
v_po_line_id          := pr_new.Po_Line_Id ;
v_po_hdr_id           := pr_new.Po_Header_Id;
v_price               := pr_new.Price_Override;
v_qty                 := pr_new.Quantity;
v_cre_dt              := pr_new.Creation_Date;
v_cre_by              := pr_new.Created_By;
v_last_upd_dt         := pr_new.Last_Update_Date ;
v_last_upd_by         := pr_new.Last_Updated_By;
v_last_upd_login      := pr_new.Last_Update_Login;
v_uom_measure         := pr_new.Unit_Meas_Lookup_Code;
v_orig_ship_id        := pr_new.original_shipment_id; /*Bug 8586635*/
success               := 1;

/* Commented rallamse bug#4479131 PADDR Elimination
rel_found             := false;
*/

v_operating_id        :=pr_new.ORG_ID;

-- added modification done by GSri on 12-jul-01

/* Commented by Ramananda for bug#4703617
|| Reason: v_gl_set_of_bks_id is not used in the trigger
OPEN  Fetch_Book_Id_Cur ;
FETCH Fetch_Book_Id_Cur INTO v_gl_set_of_bks_id;
CLOSE Fetch_Book_Id_Cur;
*/

--IF jai_cmn_utils_pkg.check_jai_exists( p_calling_object => 'JA_IN_PO_TAX_INSERT_TRG',
--                                p_set_of_books_id => v_gl_set_of_bks_id) = FALSE THEN
--  RETURN;
-- END IF;

-- Start, Vijay Shankar for Bug# 3570189
v_hook_value := jai_cmn_hook_pkg.Ja_In_po_line_locations_all(  -- added the hook call for bug 3438863 to customize the code for deciding on India loc Tax defaultation
  pr_new.LINE_LOCATION_ID                  ,
  pr_new.PO_HEADER_ID                      ,
  pr_new.PO_LINE_ID                        ,
  pr_new.QUANTITY                                 ,
  pr_new.QUANTITY_RECEIVED                        ,
  pr_new.QUANTITY_ACCEPTED                        ,
  pr_new.QUANTITY_REJECTED                        ,
  pr_new.QUANTITY_BILLED                          ,
  pr_new.QUANTITY_CANCELLED                       ,
  pr_new.UNIT_MEAS_LOOKUP_CODE                    ,
  pr_new.PO_RELEASE_ID                            ,
  pr_new.SHIP_TO_LOCATION_ID                      ,
  pr_new.SHIP_VIA_LOOKUP_CODE                     ,
  pr_new.NEED_BY_DATE                             ,
  pr_new.PROMISED_DATE                            ,
  pr_new.LAST_ACCEPT_DATE                         ,
  pr_new.PRICE_OVERRIDE                           ,
  pr_new.ENCUMBERED_FLAG                          ,
  pr_new.ENCUMBERED_DATE                          ,
  pr_new.UNENCUMBERED_QUANTITY                    ,
  pr_new.FOB_LOOKUP_CODE                          ,
  pr_new.FREIGHT_TERMS_LOOKUP_CODE                ,
  pr_new.TAXABLE_FLAG                             ,
  pr_new.TAX_NAME                                 ,
  pr_new.ESTIMATED_TAX_AMOUNT                     ,
  pr_new.FROM_HEADER_ID                           ,
  pr_new.FROM_LINE_ID                             ,
  pr_new.FROM_LINE_LOCATION_ID                    ,
  pr_new.START_DATE                               ,
  pr_new.END_DATE                                 ,
  pr_new.LEAD_TIME                                ,
  pr_new.LEAD_TIME_UNIT                           ,
  pr_new.PRICE_DISCOUNT                           ,
  pr_new.TERMS_ID                                 ,
  pr_new.APPROVED_FLAG                            ,
  pr_new.APPROVED_DATE                            ,
  pr_new.CLOSED_FLAG                              ,
  pr_new.CANCEL_FLAG                              ,
  pr_new.CANCELLED_BY                             ,
  pr_new.CANCEL_DATE                              ,
  pr_new.CANCEL_REASON                            ,
  pr_new.FIRM_STATUS_LOOKUP_CODE                  ,
  pr_new.FIRM_DATE                                ,
  pr_new.ATTRIBUTE_CATEGORY                       ,
  pr_new.ATTRIBUTE1                               ,
  pr_new.ATTRIBUTE2                               ,
  pr_new.ATTRIBUTE3                               ,
  pr_new.ATTRIBUTE4                               ,
  pr_new.ATTRIBUTE5                               ,
  pr_new.ATTRIBUTE6                               ,
  pr_new.ATTRIBUTE7                               ,
  pr_new.ATTRIBUTE8                               ,
  pr_new.ATTRIBUTE9                               ,
  pr_new.ATTRIBUTE10                              ,
  pr_new.UNIT_OF_MEASURE_CLASS                    ,
  pr_new.ENCUMBER_NOW                             ,
  pr_new.ATTRIBUTE11                              ,
  pr_new.ATTRIBUTE12                              ,
  pr_new.ATTRIBUTE13                              ,
  pr_new.ATTRIBUTE14                              ,
  pr_new.ATTRIBUTE15                              ,
  pr_new.INSPECTION_REQUIRED_FLAG                 ,
  pr_new.RECEIPT_REQUIRED_FLAG                    ,
  pr_new.QTY_RCV_TOLERANCE                        ,
  pr_new.QTY_RCV_EXCEPTION_CODE                   ,
  pr_new.ENFORCE_SHIP_TO_LOCATION_CODE            ,
  pr_new.ALLOW_SUBSTITUTE_RECEIPTS_FLAG           ,
  pr_new.DAYS_EARLY_RECEIPT_ALLOWED               ,
  pr_new.DAYS_LATE_RECEIPT_ALLOWED                ,
  pr_new.RECEIPT_DAYS_EXCEPTION_CODE              ,
  pr_new.INVOICE_CLOSE_TOLERANCE                  ,
  pr_new.RECEIVE_CLOSE_TOLERANCE                  ,
  pr_new.SHIP_TO_ORGANIZATION_ID                  ,
  pr_new.SHIPMENT_NUM                             ,
  pr_new.SOURCE_SHIPMENT_ID                       ,
  pr_new.SHIPMENT_TYPE                      ,
  pr_new.CLOSED_CODE                              ,
  pr_new.REQUEST_ID                               ,
  pr_new.PROGRAM_APPLICATION_ID                   ,
  pr_new.PROGRAM_ID                               ,
  pr_new.PROGRAM_UPDATE_DATE                      ,
  pr_new.USSGL_TRANSACTION_CODE                   ,
  pr_new.GOVERNMENT_CONTEXT                       ,
  pr_new.RECEIVING_ROUTING_ID                     ,
  pr_new.ACCRUE_ON_RECEIPT_FLAG                   ,
  pr_new.CLOSED_REASON                            ,
  pr_new.CLOSED_DATE                              ,
  pr_new.CLOSED_BY                                ,
  pr_new.ORG_ID                                   ,
  pr_new.QUANTITY_SHIPPED                         ,
  pr_new.COUNTRY_OF_ORIGIN_CODE                   ,
  pr_new.TAX_USER_OVERRIDE_FLAG                   ,
  pr_new.MATCH_OPTION                             ,
  pr_new.TAX_CODE_ID                              ,
  pr_new.CALCULATE_TAX_FLAG                       ,
  pr_new.CHANGE_PROMISED_DATE_REASON
);

IF v_hook_value = 'FALSE' THEN
  RETURN;
END IF;
-- End, 3570189

-- Commented by Vijay Shankar for bugs# 3570189
-- jai_po_cmn_pkg.query_locator_for_release( pr_new.Po_Release_Id, rel_found );

OPEN  Check_Rfq_Quot_Cur;
FETCH Check_Rfq_Quot_Cur INTO v_from_type_lookup_code, v_quot_from_hdr_id, v_type_lookup_code, v_Quot_Class_Code,
               v_vendor_id, v_vendor_site_id, v_curr, v_ship_loc_id,
               v_style_id; --Added by Sanjikum for Bug#4483042
CLOSE Check_Rfq_Quot_Cur;

--code added by Sanjikum for Bug#4483042
IF jai_cmn_utils_pkg.validate_po_type(p_style_id => v_style_id) = FALSE THEN
  return;
END IF;

open c_get_po_line_loc_details(v_orig_ship_id);
fetch c_get_po_line_loc_details into r_get_po_line_loc_details;
close c_get_po_line_loc_details;

/*Bug 8586635 - Start*/
/*
Bug 8740543
Added clause to compare PO Header ID and Line ID so that the below code is called only when split is done
*/
IF v_orig_ship_id IS NOT NULL
   AND r_get_po_line_loc_details.po_header_id = v_po_hdr_id
   AND r_get_po_line_loc_details.po_line_id = v_po_line_id THEN

    /*Get the Quantity of the parent Line in an Autonomous Transaction*/
    ja_in_po_get_lineloc_p (v_orig_ship_id, l_prev_quantity);
    /*Insert into JAI_PO_LINE_LOCATIONS*/
    jai_po_cmn_pkg.insert_line
    ( v_type_lookup_code,
      v_line_loc_id,
      r_get_po_line_loc_details.po_header_id,
      r_get_po_line_loc_details.po_line_id,
      r_get_po_line_loc_details.creation_date,
      r_get_po_line_loc_details.created_by,
      r_get_po_line_loc_details.last_update_date,
      r_get_po_line_loc_details.last_updated_by,
      r_get_po_line_loc_details.last_update_login,
      'I'
    );

    select line_focus_id into l_line_focus_id
    from JAI_PO_LINE_LOCATIONS
    where line_location_id = v_line_loc_id;
    /*Insert Taxes of the parent line in to the split line after adjusting the Tax Amount and Tax Target Amount*/
    for r_get_po_taxes in c_get_po_taxes(v_orig_ship_id) loop

        jai_po_tax_pkg.Ja_In_Po_Insert
        ( v_type_lookup_code, v_quot_class_code,
          l_line_focus_id, v_line_loc_id,
          r_get_po_taxes.tax_line_no, r_get_po_taxes.po_line_id,  r_get_po_taxes.po_header_id,
          r_get_po_taxes.precedence_1, r_get_po_taxes.precedence_2, r_get_po_taxes.precedence_3,
          r_get_po_taxes.precedence_4, r_get_po_taxes.precedence_5,
          r_get_po_taxes.precedence_6, r_get_po_taxes.precedence_7, r_get_po_taxes.precedence_8,
          r_get_po_taxes.precedence_9, r_get_po_taxes.precedence_10,
          r_get_po_taxes.tax_id, NULL, 0, r_get_po_taxes.currency,
          r_get_po_taxes.tax_rate, r_get_po_taxes.qty_rate, r_get_po_taxes.uom,
          (r_get_po_taxes.tax_amount * pr_new.QUANTITY/l_prev_quantity), r_get_po_taxes.tax_type,  r_get_po_taxes.modvat_flag,
          r_get_po_taxes.vendor_id, (r_get_po_taxes.tax_target_amount * pr_new.QUANTITY/l_prev_quantity),
          r_get_po_taxes.creation_date,  r_get_po_taxes.created_by, r_get_po_taxes.last_update_date,
          r_get_po_taxes.last_updated_by, r_get_po_taxes.last_update_login,
          r_get_po_taxes.tax_category_id
        );

    END LOOP;

    select sum(tax_amount) into l_tax_amount
    from jai_po_taxes
    where line_location_id = v_line_loc_id;

    l_ship_line_amount :=  v_qty * v_price;

    UPDATE JAI_PO_LINE_LOCATIONS
    SET tax_modified_flag = 'N',
        tax_amount = l_tax_amount,
        total_amount = l_ship_line_amount + l_tax_amount,
        tax_category_id = r_get_po_taxes.tax_category_id
    WHERE line_location_id = v_line_loc_id;

ELSE
/*Bug 8586635 - End*/
    IF v_shipment_type NOT IN ( 'SCHEDULED' , 'BLANKET' ) THEN

      OPEN  Fetch_Org_Id_Cur;
      FETCH Fetch_Org_Id_Cur INTO v_org_id;
      CLOSE Fetch_Org_Id_Cur;

      OPEN  Item_Id_Cur;
      FETCH Item_Id_Cur INTO v_item_id, v_q_hdr_id, v_q_line_id,v_line_num;
      CLOSE Item_Id_Cur;

      OPEN  Fetch_Uom_Cur;
      FETCH Fetch_Uom_Cur INTO v_temp_uom;
      CLOSE Fetch_Uom_Cur;

      /* Bug#5879769. Added by brahtod */
      v_service_type_code := JAI_AR_RCTLA_TRIGGER_PKG.get_service_type(v_vendor_id, v_vendor_site_id, 'V');

      IF NVL( v_uom_measure, '$' ) = '$' THEN
        v_uom_measure := v_temp_uom;
      END IF;

      x := v_line_loc_id;
      y := v_po_line_id;

      IF v_type_lookup_code = 'QUOTATION'  THEN
        x := v_from_line_loc_id;
        y := v_from_line_id;
      END IF;

      /* commented by Vijay Shankar for bugs# 3570189
      IF v_type_lookup_code = 'QUOTATION' THEN
        jai_po_cmn_pkg.query_locator_for_line( v_po_hdr_id, 'JAINRFQQ', found );
        IF NOT found AND y IS NULL THEN
          RETURN;
        END IF;
      END IF;
      */

         -- Added code for copy document.
         -- for quotation to PO and PO to PO on 15-OCT-2000 subbu

      IF v_from_type_lookup_code IN ('QUOTATION','PLANNED','BLANKET','STANDARD')
        AND v_quot_from_hdr_id IS NOT NULL
      THEN

        OPEN Fetch_Count_Cur;
        FETCH Fetch_Count_Cur INTO v_count;
        CLOSE Fetch_Count_Cur;

        IF v_count > 0 THEN

          v_type := 'S';

          INSERT INTO JAI_PO_COPYDOC_T(
            TYPE, PO_HEADER_ID, PO_LINE_ID, LINE_LOCATION_ID, LINE_NUM,
            SHIPMENT_NUM, ITEM_ID, FROM_HEADER_ID, FROM_TYPE_LOOKUP_CODE,
            CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN
          ) Values (
            v_type, v_po_hdr_id, v_po_line_id, v_line_loc_id, v_line_num,
            v_shipment_num, v_item_id, v_quot_from_hdr_id, v_from_type_lookup_code,
            v_cre_dt, v_cre_by, v_last_upd_dt, v_last_upd_by, v_last_upd_login
          );

          result := Fnd_Request.Set_Mode( TRUE );

          req_id := Fnd_Request.Submit_Request(
            'JA', 'JAINCPDC', 'Copy Document India Localization.', SYSDATE, FALSE,
            v_type, v_po_hdr_id, v_po_line_id, v_line_loc_id, v_line_num,
            v_shipment_num, v_item_id, v_quot_from_hdr_id, v_from_type_lookup_code,
            v_cre_dt, v_cre_by, v_last_upd_dt, v_last_upd_by, v_last_upd_login
          );

          RETURN;

        END IF;

      END IF;

      -- end of modification for copy quotation to PO. on 15th oct 2000. subbu

      -- If the following if is satisfied, it implies that PO has been linked by a quotation.
      IF v_type_lookup_code IN ( 'STANDARD', 'PLANNED') AND v_q_line_id IS NOT NULL THEN

        OPEN  Fetch_UOMCode_Cur( v_temp_uom );
        FETCH Fetch_UOMCode_Cur INTO v_unit_code;
        CLOSE Fetch_UOMCode_Cur;

        v_assessable_value := jai_cmn_setup_pkg.get_po_assessable_value( v_vendor_id, v_vendor_site_id, v_item_id, v_unit_code );

        IF v_assessable_value IS NOT NULL AND v_assessable_value > 0 THEN
          v_assessable_value := v_assessable_value * v_qty;
        ELSE
          v_assessable_value := v_qty * v_price;
        END IF;

        /* Begin - Bug#4250072  - Added by rallamse for VAT */

        ln_vat_assess_value := jai_general_pkg.ja_in_vat_assessable_value (
                                                            p_party_id          => v_vendor_id,
                                                            p_party_site_id     => v_vendor_site_id,
                                                            p_inventory_item_id => v_item_id,
                                                            p_uom_code          => v_unit_code,
                                                            p_default_price     => v_price,
                                                            p_ass_value_date    => trunc(sysdate) ,
                                                            p_party_type        => 'V'
                                                          );

        ln_vat_assess_value := ln_vat_assess_value * v_qty ;

        /* End - Bug#4250072   - Added by rallamse for VAT */

        -- Insert Statement added for Bug# 2541354 (When PO is created from Quotation during MRP release then taxes are defaulted correctly)
        INSERT INTO JAI_PO_QUOT_LINES_T (
          po_header_id, po_line_id, line_location_id, from_header_id,
          from_line_id, price_override, uom_code, assessable_value,
          creation_date, created_by, last_update_date, last_updated_by, last_update_login
        ) VALUES (
          v_po_hdr_id, v_po_line_id, v_line_loc_id, v_q_hdr_id,
          v_q_line_id, v_price, v_unit_code, v_assessable_value,
          v_cre_dt, v_cre_by, v_last_upd_dt, v_last_upd_by, v_last_upd_login
        );

        RETURN;     ------ DO NOT ALLOW THE OTHER DEFAULTING TO TAKE PLACE.

      END IF;

      IF v_type_lookup_code = 'QUOTATION' THEN

        -- Added by Jia for bug#8745089 on 2009-08-14, Begin
        -------------------------------------------------------------------------------------------
        JAI_AVLIST_VALIDATE_PKG.Check_AvList_Validation( pn_party_id          => v_vendor_id
                                                       , pn_party_site_id     => v_vendor_site_id
                                                       , pn_inventory_item_id => v_item_id
                                                       , pd_ordered_date      => trunc(sysdate)
                                                       , pv_party_type        => 'V'
                                                       , pn_pricing_list_id   => null
                                                       );
        -------------------------------------------------------------------------------------------
        -- Added by Jia for bug#8745089 on 2009-08-14, End

        jai_po_cmn_pkg.insert_line( 'CATALOG', v_line_loc_id, v_po_hdr_id, v_po_line_id, v_cre_dt,
          v_cre_by, v_last_upd_dt, v_last_upd_by, v_last_upd_login, 'I' , v_service_type_code  -- 5879769, brathod
        );

        -- added by Vijay Shankar for Bug# 3184418
        IF x IS NOT NULL THEN

          OPEN c_tax_modified_flag(x);
          FETCH c_tax_modified_flag INTO v_tax_modified_flag;
          CLOSE c_tax_modified_flag;

          IF v_tax_modified_flag IS NULL THEN
            v_tax_modified_flag := 'N';
          END IF;

        ELSE
          v_tax_modified_flag := 'N';
        END IF;

        -- condition added by Vijay Shankar for Bug# 3184418
        IF v_tax_modified_flag = 'Y' THEN
          jai_po_tax_pkg.Ja_In_Po_Case1(
            v_type_lookup_code, v_quot_class_code, v_vendor_id, v_vendor_site_id, v_curr,
            v_org_id, v_item_id, v_uom_measure, v_line_loc_id,
            v_po_hdr_id, v_po_line_id, y, x, v_price, v_Qty, v_cre_dt,
            v_cre_by, v_last_upd_dt, v_last_upd_by, v_last_upd_login, 'I', success, pr_new.quantity   -- pr_new.quantity added by csahoo for bug#6144740
          );
        END IF;

      END IF;

      /* commented by Vijay Shankar for bugs# 3570189
      IF v_type_lookup_code = 'RFQ' THEN
        jai_po_cmn_pkg.query_locator_for_line( v_po_hdr_id, 'JAINRFQQ', found );
        success := 1;

      ELSIF v_type_lookup_code IN ( 'STANDARD', 'PLANNED', 'CONTRACT', 'BLANKET' ) THEN
        jai_po_cmn_pkg.query_locator_for_line( v_po_hdr_id, 'JAINPO', found );
        success := 1;
      END IF;

      IF NOT found AND v_type_lookup_code <> 'RFQ' THEN
        If v_hook_value = 'FALSE' THEN
          RETURN;
        End if; -- bug 3438863
      END IF;
      */

      success := 1;

      IF v_type_lookup_code <> 'QUOTATION'  THEN

        jai_po_cmn_pkg.insert_line( v_type_lookup_code, v_line_loc_id, v_po_hdr_id, v_po_line_id, v_cre_dt,
          v_cre_by, v_last_upd_dt, v_last_upd_by, v_last_upd_login, 'I' ,v_service_type_code -- 5879769, brathod
        );

      END IF;

      IF x IS NOT NULL AND y IS NOT NULL AND v_type_lookup_code = 'QUOTATION' THEN
        -- condition added by Vijay Shankar for Bug# 3184418
        IF v_tax_modified_flag = 'Y' THEN
          success := 0;
        ELSE
          success := 1;
        END IF;

      END IF;

      IF success <> 0 THEN
        jai_po_tax_pkg.Ja_In_Po_Case2 (
          v_type_lookup_code, v_quot_class_code, v_vendor_id, v_vendor_site_id, v_curr,
          v_org_id, v_item_id, v_line_loc_id, v_po_hdr_id, v_po_line_id,
          v_price, v_qty, v_cre_dt, v_cre_by, v_last_upd_dt,
          v_last_upd_by, v_last_upd_login, v_uom_measure, NULL,P_VAT_ASSESS_VALUE => NULL
        );
      END IF;

    -- modified by Vijay Shankar for bugs# 3570189
    -- ELSIF v_shipment_type IN ( 'SCHEDULED', 'BLANKET' ) AND rel_found = TRUE THEN
    ELSIF v_shipment_type IN ( 'SCHEDULED', 'BLANKET' ) THEN

      -- Added by Jia for bug#8765528 on 2009-08-14, Begin
      -------------------------------------------------------------------------------------------
      JAI_AVLIST_VALIDATE_PKG.Check_AvList_Validation( pn_party_id          => v_vendor_id
                                                     , pn_party_site_id     => v_vendor_site_id
                                                     , pn_inventory_item_id => v_item_id
                                                     , pd_ordered_date      => trunc(sysdate)
                                                     , pv_party_type        => 'V'
                                                     , pn_pricing_list_id   => null
                                                     );
      -------------------------------------------------------------------------------------------
      -- Added by Jia for bug#8765528 on 2009-08-14, End

      -- Vijay Shankar for Bug# 3570189

      /* Commented rallamse bug#4479131 PADDR Elimination
      jai_po_cmn_pkg.query_locator_for_release( pr_new.Po_Release_Id, rel_found );
      */

      jai_po_cmn_pkg.process_release_shipment (
        v_shipment_type, v_src_ship_id, v_line_loc_id, v_po_line_id, v_po_hdr_id,
        v_qty, v_po_rel_id, v_cre_dt, v_cre_by,
        v_last_upd_dt, v_last_upd_by, v_last_upd_login, 'I'
      );

    END IF;

END IF; /*IF v_orig_ship_id IS NOT NULL THEN*/

END ARI_T1 ;

  /*
  REM +======================================================================+
  REM NAME          ARU_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_PO_LLA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_PO_LLA_ARU_T3
  REM
  REM +======================================================================+
  */
  PROCEDURE ARU_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
   p_tax_amount                  NUMBER                                                                                          ;
  x                             NUMBER                                                                                          ;
  y                             NUMBER                                                                                          ;
  v_type_lookup_code            VARCHAR2(40)                                                                                    ;
  v_flag                        VARCHAR2(1)                                                                                     ;
  flag                          VARCHAR2(8)                                                                                     ;
  v_quot_class_code             VARCHAR2(25)                                                                                    ;
  v_vendor_id                   NUMBER                                                                                          ;
  v_vendor_site_id              NUMBER                                                                                          ;
  v_curr                        VARCHAR2(15)                                                                                    ;
  v_ship_loc_id                 NUMBER                                                                                          ;
  v_org_id                      NUMBER                                                                                          ;
  v_from_line_loc_id            NUMBER; --File.Sql.35 Cbabu                                           := pr_new.from_line_location_id                   ;
  v_from_line_id                NUMBER; --File.Sql.35 Cbabu                                           := pr_new.from_line_id                            ;
  v_line_loc_id                 NUMBER; --File.Sql.35 Cbabu                                           := pr_new.line_location_id                        ;
  v_po_line_id                  NUMBER; --File.Sql.35 Cbabu                                           := pr_new.po_line_id                              ;
  v_po_hdr_id                   NUMBER; --File.Sql.35 Cbabu                                           := pr_new.po_header_id                            ;
  v_price                       NUMBER; --File.Sql.35 Cbabu                                           := pr_new.price_override                          ;
  v_old_price                   NUMBER; --File.Sql.35 Cbabu                                           := pr_old.price_override                          ;
  v_qty                         NUMBER; --File.Sql.35 Cbabu                                           := pr_new.quantity                                ;
  v_old_qty                     NUMBER; --File.Sql.35 Cbabu                                           := pr_old.quantity                                ;
  v_cre_dt                      DATE  ; --File.Sql.35 Cbabu                                           := pr_new.creation_date                           ;
  v_cre_by                      NUMBER; --File.Sql.35 Cbabu                                           := pr_new.created_by                              ;
  v_last_upd_dt                 DATE  ; --File.Sql.35 Cbabu ;                                          := pr_new.last_update_date                        ;
  v_last_upd_by                 NUMBER ; --File.Sql.35 Cbabu                                          := pr_new.last_updated_by                         ;
  v_last_upd_login              NUMBER ; --File.Sql.35 Cbabu                                          := pr_new.last_update_login                       ;
  v_uom_measure                 VARCHAR2(50)                                                                                    ;
  v_uom_code                    VARCHAR2(25)                                                                                    ;
  v_shipment_type               VARCHAR2(25); --File.Sql.35 Cbabu                                     := pr_new.shipment_type                           ;
  v_src_ship_id                 NUMBER      ; --File.Sql.35 Cbabu                                     := pr_new.source_shipment_id                      ;
  v_po_rel_id                   NUMBER      ; --File.Sql.35 Cbabu                                     := pr_new.po_release_id                           ;
  v_item_id                     NUMBER                                                                                          ;
  rel_found                     BOOLEAN     ; --File.Sql.35 Cbabu                                     := FALSE                                        ;
  found                         BOOLEAN                                                                                         ;
  retcode                       BOOLEAN                                                                                         ;
  success                       NUMBER      ; --File.Sql.35 Cbabu                                     := 1                                            ;
  v_tax_amt                     NUMBER      ; --File.Sql.35 Cbabu                                     := 0                                            ;
  v_tot_amt                     NUMBER      ; --File.Sql.35 Cbabu                                     := 0                                            ;
  v_assessable_value            NUMBER      ; --File.Sql.35 Cbabu                                     := 0                                            ;
  ln_vat_assess_value           NUMBER                                                                                          ; -- added, Harshita for bug #4245062
  v_curr_conv_factor            NUMBER                                                                                          ;
  dummy                         NUMBER      ; --File.Sql.35 Cbabu                                     := 1                                            ;
  v_exist                       NUMBER      ; --File.Sql.35 Cbabu                                     := 0                                            ;
  v_hook_value VARCHAR2(10);/*added by rchandan for paddr elimination*/

  -- Start of bug 3037284
  v_quantity_received           PO_LINE_LOCATIONS_ALL.QUANTITY_RECEIVED%TYPE ; --File.Sql.35 Cbabu     := nvl(pr_new.quantity_received,0)               ;
  v_quantity_cancelled          PO_LINE_LOCATIONS_ALL.QUANTITY_CANCELLED%TYPE ; --File.Sql.35 Cbabu    := pr_new.quantity_cancelled                     ;
  v_style_id                    po_headers_all.style_id%TYPE;

  CURSOR rec_get_tax_amount
  IS
  SELECT
        nvl(a.tax_amount,0) tax_amount,
        nvl(b.adhoc_flag, 'N') adhoc_flag
  FROM
        JAI_PO_TAXES a ,
        JAI_CMN_TAXES_ALL b
  WHERE
        a.tax_id                = b.tax_id          AND
        a.po_line_id              = v_po_line_id      AND
        a.po_header_id            = v_po_hdr_id       AND
        a.line_location_id        = v_line_loc_id FOR UPDATE OF a.tax_amount;

  CURSOR rec_calc_total_tax
  IS
  SELECT sum(tax_amount )
  FROM JAI_PO_TAXES
  WHERE
         po_line_id             = v_po_line_id      AND
         po_header_id           = v_po_hdr_id       AND
         line_location_id       = v_line_loc_id     AND
         tax_type               <> jai_constants.tax_type_tds ; /*'TDS';Ramananda for removal of SQL LITERALs */

 cur_rec_get_total             REC_CALC_TOTAL_TAX%ROWTYPE;
 l_total_tax_amount            JAI_PO_LINE_LOCATIONS.TAX_AMOUNT%TYPE;

  -- END of bug 3037284

  CURSOR check_rfq_quot_cur
  IS
  SELECT
          type_lookup_code        ,
          quotation_class_code    ,
          vendor_id               ,
          vendor_site_id          ,
          currency_code           ,
          ship_to_location_id
          , rate_type, rate_date, rate,    -- Vijay Shankar for Bug #3184673
          style_id
  FROM
          po_headers_all
  WHERE
          po_header_id = v_po_hdr_id;

    -- Get the Inventory Organization Id

  CURSOR  fetch_org_id_cur IS
  SELECT
          Inventory_Organization_Id
  FROM
          hr_locations
  WHERE
          location_id = v_ship_loc_id;



  CURSOR  Item_Id_Cur  IS
  SELECT
          item_id,
          unit_meas_lookup_code
  FROM
          po_lines_all
  WHERE
          po_line_id = v_po_line_id;


  CURSOR  tax_modified_cur
  IS
  SELECT
          NVL( Tax_Modified_Flag, 'N' )
  FROM
          JAI_PO_LINE_LOCATIONS
  WHERE
          Po_Line_Id       = v_po_line_id         AND
          Line_Location_Id = v_line_loc_id;


  CURSOR  fetch_sum_cur
  IS
  SELECT
          SUM( NVL( Tax_Amount, 0 ) )
  FROM
          JAI_PO_TAXES
  WHERE
          po_line_id       = v_po_line_id         AND
          line_location_id = v_line_loc_id        AND
          tax_type         <> jai_constants.tax_type_tds ; /*'TDS';Ramananda for removal of SQL LITERALs */

  CURSOR fetch_sum1_cur
  IS
  SELECT
          sum( nvl( tax_amount, 0 ) )
  FROM
          JAI_PO_TAXES
  WHERE
          po_line_id              = v_po_line_id  AND
          line_location_id        is null         AND
          tax_type                <> jai_constants.tax_type_tds ; /*'TDS';Ramananda for removal of SQL LITERALs */

  -- To Check  whether record modified is localized or not
  CURSOR localizaed_check_cur
  IS
  SELECT
          nvl(1,0)
  FROM
          JAI_PO_LINE_LOCATIONS
  WHERE
          po_line_id        = v_po_line_id        AND
          Line_Location_Id  = v_line_loc_id;


  CURSOR fetch_uomcode_cur
  IS
  SELECT
          uom_code
  FROM
          mtl_units_of_measure
  WHERE
          unit_of_measure = v_uom_measure;

  ------------- added by Gsr 12-jul-01

  v_operating_id              number; --File.Sql.35 Cbabu   :=pr_new.org_id                       ;
  v_gl_set_of_bks_id          gl_sets_of_books.set_of_books_id%type       ;
  v_currency_code             gl_sets_of_books.currency_code%type         ;


  /*
  || Commented the following two cursors and added the cur_get_curr_code cursor
  || Ramananada for bug#4703617
  */
  /*
    CURSOR fetch_book_id_cur
    IS
    SELECT     set_of_books_id
    FROM      org_organization_definitions
    WHERE     operating_unit  = v_operating_id; -- Modified by Ramananda for removal of SQL LITERALs
     --nvl(operating_unit,0)  = v_operating_id;
    CURSOR sob_cur IS
    SELECT currency_code
    FROM gl_sets_of_books
    WHERE
    set_of_books_id = v_gl_set_of_bks_id; */

  /*
  || Added the following cur_get_curr_code cursor
  || Ramananada for bug#4703617
  */
  CURSOR cur_get_curr_code IS
  SELECT
         sob.currency_code
  FROM
         financials_system_params_all FSP, gl_sets_of_books SOB
  WHERE
         FSP.set_of_books_id = SOB.set_of_books_id
  AND    FSP.org_id  = v_operating_id ;


-- Vijay Shankar for Bug #3184673
v_po_rate_type  PO_HEADERS_ALL.rate_type%TYPE;
v_po_rate_date  PO_HEADERS_ALL.rate_date%TYPE;
v_po_rate   PO_HEADERS_ALL.rate%TYPE;

v_currency_conv_rate NUMBER;
v_trigger_name VARCHAR2(50);
v_temp VARCHAR2(2500);

--Added by Kevin Cheng for Retroactive Price 2008/01/13
--=====================================================
lv_retro_price_flag        VARCHAR2(1) := 'N';
lv_process_flag            VARCHAR2(10);
lv_process_message         VARCHAR2(2000);
--=====================================================

  BEGIN
    pv_return_code := jai_constants.successful ;
    /*------------------------------------------------------------------------------------------
 FILENAME: Ja_In_Po_Tax_Update_Trg.sql

S.No  dd/mm/yyyy           Author and Details
------------------------------------------------------------------------------------------
1.    14/08/2003    Aiyer , Bug #3037284 ,File version 616.1
            Changed the triggering condition to fire when cancel_flag is 'Y'.
            In case of full cancellation of a Purchase order line  (no receipt done),
            the lines from JAI_PO_TAXES and JAI_PO_LINE_LOCATIONS are deleted.
            In case of partial cancellation of purchase order line, apportion the tax amount
            in the ratio of quantity_received to original line quantity i.e quantity_received/quantity
            in table JAI_PO_TAXES.
            Calculate the tax_amount in the table JAI_PO_LINE_LOCATIONS as a sum of all records
            in the table JAI_PO_TAXES for that line_locations_id excluding 'TDS'
            type of taxes.
            The total amount in JAI_PO_LINE_LOCATIONS is calculated as
            (po_line_locations_all.quantity_received * po_line_locations_all.price_override)
             +
             sum of all taxes from JAI_PO_TAXES for that line_location_id .

2     15/10/2003    Vijay Shankar for Bug #3184673, File version 618.1
            Adhoc taxes are not apportioned when quantity is changed which is handled with this bug.
            Code is added to update JAI_PO_TAXES tables based on old and new quantity for adhoc taxes

3     29-Nov-2004    Sanjikum for 4035297. Version 115.1
                   Changed the 'INR' check. Added the call to jai_cmn_utils_pkg.check_jai_exists

                  Dependency Due to this Bug:-
                  The current trigger becomes dependent on the function jai_cmn_utils_pkg.check_jai_exists version 115.0.

4.    17-Mar-2005  hjujjuru - bug #4245062  File version 115.2
                    The Assessable Value is calculated for the transaction. For this, a call is
                    made to the function ja_in_vat_assessable_value_f.sql with the parameters
                    relevant for the transaction. This assessable value is again passed to the
                    procedure that calucates the taxes.
                    Base bug - #4245089

5.    08-Jun-2005   This Object is Modified to refer to New DB Entry names in place of Old
                    DB as required for CASE COMPLAINCE. Version 116.1

6.   13-Jun-2005    File Version: 116.2
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done

7.   08-Jul-2005    Sanjikum for Bug#4483042 File Version: 116.3
                    1) Added a call to jai_cmn_utils_pkg.validate_po_type, to check whether for the current PO
                       IL functionality should work or not.

8.  8-Jul-2005    File Version: 116.3
                  rchandan for bug#4479131
      The object is modified to eliminate the paddr usage.

9 . 8-Jul-2005    Sanjikum for Bug#4483042, File Version 117.2
                   1) Added a new column in cursor - check_rfq_quot_cur

10. 15-Jan-2008   Kevin Cheng for Retroactive Price Enhancement
                   1) Insert change history table;
                   2) Add parameter to procedure called in ARU_T1;

11. 23-Mar-2009   Bug 8224547 File version 120.6.12010000.2/120.7
                  Issue - Not able to update PO line quantity and save - getting the PL/SQL
                          character to number conversion error.
                  Cause - In procedure ARU_T1, the call to jai_po_tax_pkg.Ja_In_Po_Case2 didn't
                          have the 4 parameters (they have default value of null) introduced for
                          bug 5096787. In the previous version, lv_retro_price_flag was passed
                          as the last parameter, which got assigned to the parameter v_rate as
                          per the spec. v_rate is a number variable, and this caused the error.
                  Fix   - Inserted 4 null values as parameters (just before lv_retro_price_flag)
                          in the call to jai_po_tax_pkg.Ja_In_Po_Case2.



Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Current Version    Current Bug    Dependent           Files                Version   Author   Date          Remarks
Of File                           On Bug/Patchset    Dependent On

Ja_In_Po_Tax_Update_Trg.sql
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
115.1              4035297        IN60105D2+4033992  ja_in_util_pkg_s.sql  115.0     Sanjikum 29-Nov-2004  Call to this function.
                                                     ja_in_util_pkg_s.sql  115.0   Sanjikum

115.2              4245062       IN60106 + 4245089                                  hjujjuru  17/03/2005   VAT Implelentation

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/


SELECT 'START_JA_IN_PO_TAX_UPDATE_TRG' INTO v_trigger_name FROM DUAL;

  --File.Sql.35 Cbabu
  v_from_line_loc_id            := pr_new.from_line_location_id                   ;
  v_from_line_id                := pr_new.from_line_id                            ;
  v_line_loc_id                 := pr_new.line_location_id                        ;
  v_po_line_id                  := pr_new.po_line_id                              ;
  v_po_hdr_id                   := pr_new.po_header_id                            ;
  v_price                       := pr_new.price_override                          ;
  v_old_price                   := pr_old.price_override                          ;
  v_qty                         := pr_new.quantity                                ;
  v_old_qty                     := pr_old.quantity                                ;
  v_cre_dt                      := pr_new.creation_date                           ;
  v_cre_by                      := pr_new.created_by                              ;
  v_last_upd_dt                 := pr_new.last_update_date                        ;
  v_last_upd_by                 := pr_new.last_updated_by                         ;
  v_last_upd_login              := pr_new.last_update_login                       ;
  v_shipment_type               := pr_new.shipment_type                           ;
  v_src_ship_id                 := pr_new.source_shipment_id                      ;
  v_po_rel_id                   := pr_new.po_release_id                           ;
  rel_found                     := FALSE                                        ;
  success                       := 1                                            ;
  v_tax_amt                     := 0                                            ;
  v_tot_amt                     := 0                                            ;
  v_assessable_value            := 0                                            ;
  dummy                         := 1                                            ;
  v_exist                       := 0                                            ;
  v_quantity_received           := nvl(pr_new.quantity_received,0)               ;
  v_quantity_cancelled          := pr_new.quantity_cancelled                     ;
  v_operating_id                := pr_new.org_id                       ;


/*
|| Commented by Ramananda for bug4703617
OPEN  Fetch_Book_Id_Cur ;
FETCH Fetch_Book_Id_Cur INTO v_gl_set_of_bks_id;
CLOSE Fetch_Book_Id_Cur;
*/

  IF pr_new.org_id IS NOT NULL
   THEN

       /*
       || Added by Ramananda for bug4703617
       */
       OPEN cur_get_curr_code ;
       FETCH cur_get_curr_code INTO v_currency_code ;
       CLOSE cur_get_curr_code ;

       /*
       || Commented by Ramananda for bug4703617
        OPEN Sob_cur;
        FETCH Sob_cur INTO v_currency_code;
        CLOSE Sob_cur; */

    /*IF nvl(v_currency_code,'###') <> 'INR'
     THEN
       RETURN;
     END IF;*/
   END IF;

   --Commented the above and added the below by Sanjikum for Bug#4035297

  -- IF jai_cmn_utils_pkg.check_jai_exists( p_calling_object => 'JA_IN_PO_TAX_UPDATE_TRG',
  --                                 p_set_of_books_id => v_gl_set_of_bks_id) = FALSE THEN
  --    RETURN;
  -- END IF;

-- POC for Releases ONLY

/* jai_po_cmn_pkg.query_locator_for_release( pr_new.Po_Release_Id, rel_found );*//*commented by rchandan for bug#4479131*/

/*added by rchandan for bug#4479131*/

v_hook_value := jai_cmn_hook_pkg.Ja_In_po_line_locations_all(  -- added the hook call for bug 3438863 to customize the code for deciding on India loc Tax defaultation
  pr_new.LINE_LOCATION_ID                  ,
  pr_new.PO_HEADER_ID                      ,
  pr_new.PO_LINE_ID                        ,
  pr_new.QUANTITY                                 ,
  pr_new.QUANTITY_RECEIVED                        ,
  pr_new.QUANTITY_ACCEPTED                        ,
  pr_new.QUANTITY_REJECTED                        ,
  pr_new.QUANTITY_BILLED                          ,
  pr_new.QUANTITY_CANCELLED                       ,
  pr_new.UNIT_MEAS_LOOKUP_CODE                    ,
  pr_new.PO_RELEASE_ID                            ,
  pr_new.SHIP_TO_LOCATION_ID                      ,
  pr_new.SHIP_VIA_LOOKUP_CODE                     ,
  pr_new.NEED_BY_DATE                             ,
  pr_new.PROMISED_DATE                            ,
  pr_new.LAST_ACCEPT_DATE                         ,
  pr_new.PRICE_OVERRIDE                           ,
  pr_new.ENCUMBERED_FLAG                          ,
  pr_new.ENCUMBERED_DATE                          ,
  pr_new.UNENCUMBERED_QUANTITY                    ,
  pr_new.FOB_LOOKUP_CODE                          ,
  pr_new.FREIGHT_TERMS_LOOKUP_CODE                ,
  pr_new.TAXABLE_FLAG                             ,
  pr_new.TAX_NAME                                 ,
  pr_new.ESTIMATED_TAX_AMOUNT                     ,
  pr_new.FROM_HEADER_ID                           ,
  pr_new.FROM_LINE_ID                             ,
  pr_new.FROM_LINE_LOCATION_ID                    ,
  pr_new.START_DATE                               ,
  pr_new.END_DATE                                 ,
  pr_new.LEAD_TIME                                ,
  pr_new.LEAD_TIME_UNIT                           ,
  pr_new.PRICE_DISCOUNT                           ,
  pr_new.TERMS_ID                                 ,
  pr_new.APPROVED_FLAG                            ,
  pr_new.APPROVED_DATE                            ,
  pr_new.CLOSED_FLAG                              ,
  pr_new.CANCEL_FLAG                              ,
  pr_new.CANCELLED_BY                             ,
  pr_new.CANCEL_DATE                              ,
  pr_new.CANCEL_REASON                            ,
  pr_new.FIRM_STATUS_LOOKUP_CODE                  ,
  pr_new.FIRM_DATE                                ,
  pr_new.ATTRIBUTE_CATEGORY                       ,
  pr_new.ATTRIBUTE1                               ,
  pr_new.ATTRIBUTE2                               ,
  pr_new.ATTRIBUTE3                               ,
  pr_new.ATTRIBUTE4                               ,
  pr_new.ATTRIBUTE5                               ,
  pr_new.ATTRIBUTE6                               ,
  pr_new.ATTRIBUTE7                               ,
  pr_new.ATTRIBUTE8                               ,
  pr_new.ATTRIBUTE9                               ,
  pr_new.ATTRIBUTE10                              ,
  pr_new.UNIT_OF_MEASURE_CLASS                    ,
  pr_new.ENCUMBER_NOW                             ,
  pr_new.ATTRIBUTE11                              ,
  pr_new.ATTRIBUTE12                              ,
  pr_new.ATTRIBUTE13                              ,
  pr_new.ATTRIBUTE14                              ,
  pr_new.ATTRIBUTE15                              ,
  pr_new.INSPECTION_REQUIRED_FLAG                 ,
  pr_new.RECEIPT_REQUIRED_FLAG                    ,
  pr_new.QTY_RCV_TOLERANCE                        ,
  pr_new.QTY_RCV_EXCEPTION_CODE                   ,
  pr_new.ENFORCE_SHIP_TO_LOCATION_CODE            ,
  pr_new.ALLOW_SUBSTITUTE_RECEIPTS_FLAG           ,
  pr_new.DAYS_EARLY_RECEIPT_ALLOWED               ,
  pr_new.DAYS_LATE_RECEIPT_ALLOWED                ,
  pr_new.RECEIPT_DAYS_EXCEPTION_CODE              ,
  pr_new.INVOICE_CLOSE_TOLERANCE                  ,
  pr_new.RECEIVE_CLOSE_TOLERANCE                  ,
  pr_new.SHIP_TO_ORGANIZATION_ID                  ,
  pr_new.SHIPMENT_NUM                             ,
  pr_new.SOURCE_SHIPMENT_ID                       ,
  pr_new.SHIPMENT_TYPE                      ,
  pr_new.CLOSED_CODE                              ,
  pr_new.REQUEST_ID                               ,
  pr_new.PROGRAM_APPLICATION_ID                   ,
  pr_new.PROGRAM_ID                               ,
  pr_new.PROGRAM_UPDATE_DATE                      ,
  pr_new.USSGL_TRANSACTION_CODE                   ,
  pr_new.GOVERNMENT_CONTEXT                       ,
  pr_new.RECEIVING_ROUTING_ID                     ,
  pr_new.ACCRUE_ON_RECEIPT_FLAG                   ,
  pr_new.CLOSED_REASON                            ,
  pr_new.CLOSED_DATE                              ,
  pr_new.CLOSED_BY                                ,
  pr_new.ORG_ID                                   ,
  pr_new.QUANTITY_SHIPPED                         ,
  pr_new.COUNTRY_OF_ORIGIN_CODE                   ,
  pr_new.TAX_USER_OVERRIDE_FLAG                   ,
  pr_new.MATCH_OPTION                             ,
  pr_new.TAX_CODE_ID                              ,
  pr_new.CALCULATE_TAX_FLAG                       ,
  pr_new.CHANGE_PROMISED_DATE_REASON
);

IF v_hook_value = 'FALSE' THEN
  RETURN;
END IF; /*added by rchandan for bug#4479131*/

-- End of POC

  OPEN check_rfq_quot_cur;
  FETCH check_rfq_quot_cur INTO
                                v_type_lookup_code      ,
                                v_quot_class_code       ,
                                v_vendor_id             ,
                                v_vendor_site_id        ,
                                v_curr, v_ship_loc_id
                                , v_po_rate_type, v_po_rate_date, v_po_rate,    -- Vijay Shankar for Bug #3184673
                                v_style_id; --Added by Sanjikum for Bug#4483042
  CLOSE check_rfq_quot_cur;

  --code added by Sanjikum for Bug#4483042
  IF jai_cmn_utils_pkg.validate_po_type(p_style_id => v_style_id) = FALSE THEN
    return;
  END IF;

  OPEN  item_id_cur;
  FETCH item_id_cur INTO v_item_id, v_uom_measure;
  CLOSE item_id_cur;

-- Get Inventory Organization Id

  OPEN  fetch_org_id_cur;
  FETCH fetch_org_id_cur INTO v_org_id;
  CLOSE fetch_org_id_cur;

  OPEN  fetch_uomcode_cur;
  FETCH fetch_uomcode_cur INTO v_uom_code;
  CLOSE fetch_uomcode_cur;

  OPEN  Localizaed_Check_Cur;
  FETCH Localizaed_Check_Cur INTO v_exist;
  CLOSE Localizaed_Check_Cur;

  --Added by Kevin Cheng for Retroactive Price 2008/01/13
  --=====================================================
  IF pr_new.RETROACTIVE_DATE IS NOT NULL
     AND (pr_old.PRICE_OVERRIDE <> pr_new.PRICE_OVERRIDE)
  THEN
    lv_retro_price_flag := 'Y';
  END IF;

  IF lv_retro_price_flag = 'Y'
  THEN
    JAI_RETRO_PRC_PKG.Insert_Price_Changes( pr_old             => pr_old
                                          , pr_new             => pr_new
                                          , pv_process_flag    => lv_process_flag
                                          , pv_process_message => lv_process_message
                                          );

    IF lv_process_flag IN ('EE', 'UE')
    THEN
      FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG','JAI_PO_LLA_TRIGGER_PKG.ARU_T1.Err:'||lv_process_message);
      app_exception.raise_exception;
    END IF;
  END IF;
  --=====================================================

/*************************************** Part 2 ********************************************************/
/************************** Processing For Po Summary Cancellation *************************************/
/*******************************************************************************************************/
  /*
    This code has been added by aiyer for the fix of the bug 3037284
    This piece of code introduces a new functionality into this trigger.

  */
  -- Start of code 3037284
  IF nvl(pr_old.cancel_flag,'N') <> 'Y' AND nvl(pr_new.cancel_flag,'N') = 'Y' THEN
     IF nvl(v_quantity_cancelled,-9999) = nvl(v_qty,0) THEN
        /*
           Indicating that the entire line has been cancelled and no receipt has been made for ths line,
           then delete the line and associated taxes from JAI_PO_LINE_LOCATIONS
           and JAI_PO_TAXES and return .
        */
        DELETE
                JAI_PO_TAXES
        WHERE
               line_location_id = v_line_loc_id AND
               po_line_id       = v_po_line_id  AND
               po_header_id     = v_po_hdr_id;

        DELETE
               JAI_PO_LINE_LOCATIONS
        WHERE
               po_line_id       =    v_po_line_id    AND
               po_header_id     =    v_po_hdr_id     AND
               line_location_id =    v_line_loc_id;

     ELSIF  nvl(v_quantity_cancelled,-9999) < nvl(v_qty,0) THEN
        /*
          Indicating that a partial receipt has been made for the line and then the line has been cancelled.
          In such a case the cancelled quantity would be lesser than the quantity in table po_line_locations_all.
          Now in this scenario update the line and the associated apportioned taxes in the table JAI_PO_LINE_LOCATIONS
          and JAI_PO_TAXES
        */

        /*
           Update the JAI_PO_TAXES with the apportioned tax_amount
           The tax amounts are apportioned in a ratio of the (quantity_received\quantity)
           Only the taxes which have a adhoc flag set to 'N' can be apportioned.
           Taxes which have adhoc flag set to 'Y' would remain unaffected .

        */
        FOR cur_rec_get_tax_amount  IN rec_get_tax_amount
        LOOP

          -- following IF commented by Vijay Shankar for Bug #3184673
          -- IF cur_rec_get_tax_amount.adhoc_flag = 'N' THEN

             UPDATE
                     JAI_PO_TAXES
             SET
                    tax_amount = (nvl(v_quantity_received,0) / nvl(v_qty,1)) * nvl(cur_rec_get_tax_amount.tax_amount,0)
             WHERE
                    CURRENT OF rec_get_tax_amount;

          -- END IF;
        END LOOP;

        /*
            The record in ja_in_po_line_location has to be updated with the total of all taxes from JAI_PO_TAXES
            excluding the TDS type of taxes. The total_amount should be calculated as (quantity_received * price_override) + total of tax amount
        */

        OPEN  rec_calc_total_tax ;
        FETCH rec_calc_total_tax INTO l_total_tax_amount;
        CLOSE rec_calc_total_tax;

        UPDATE
               JAI_PO_LINE_LOCATIONS
        SET
               tax_amount   =  l_total_tax_amount ,
               total_amount =  nvl(pr_new.quantity_received * pr_new.price_override, 0) + nvl(l_total_tax_amount,0)
        WHERE
               po_line_id         = v_po_line_id      AND
               po_header_id       = v_po_hdr_id       AND
               line_location_id   = v_line_loc_id     ;


     END IF; /* End if of nvl(v_quantity_cancelled,-9999) = nvl(v_qty,0 */

     -- Exit the trigger
     RETURN;
  END IF; /* End if of nvl(pr_old.cancel_flag,'N') <> 'Y' AND nvl(pr_new.cancel_flag,'N') = 'Y' */
  -- End of code 3037284

/*************************************** Part 3 ********************************************************/
/************************** Processing Based on Shipment type values ***********************************/
/*******************************************************************************************************/


  IF v_shipment_type NOT IN ( 'SCHEDULED', 'BLANKET' ) THEN

     /*IF v_type_lookup_code IN ( 'RFQ', 'QUOTATION' ) THEN
        jai_po_cmn_pkg.query_locator_for_line( v_po_hdr_id, 'JAINRFQQ', found );
     ELSIF v_type_lookup_code IN ( 'STANDARD', 'PLANNED', 'CONTRACT', 'BLANKET' ) and v_exist <> 1 THEN
        jai_po_cmn_pkg.query_locator_for_line( v_po_hdr_id, 'JAINPO', found );
     END IF;

     IF NOT found THEN
        RETURN;
     END IF;*//*commented by rchandan for bug#4479131*/
     IF v_type_lookup_code IN ( 'RFQ', 'QUOTATION', 'STANDARD', 'PLANNED', 'CONTRACT', 'BLANKET' ) THEN
  v_hook_value := jai_cmn_hook_pkg.Ja_In_po_line_locations_all(  -- added the hook call for bug 3438863 to customize the code for deciding on India loc Tax defaultation
      pr_new.LINE_LOCATION_ID                  ,
      pr_new.PO_HEADER_ID                      ,
      pr_new.PO_LINE_ID                        ,
      pr_new.QUANTITY                          ,
      pr_new.QUANTITY_RECEIVED                 ,
      pr_new.QUANTITY_ACCEPTED                 ,
      pr_new.QUANTITY_REJECTED                 ,
      pr_new.QUANTITY_BILLED                   ,
      pr_new.QUANTITY_CANCELLED                ,
      pr_new.UNIT_MEAS_LOOKUP_CODE             ,
      pr_new.PO_RELEASE_ID                            ,
      pr_new.SHIP_TO_LOCATION_ID                      ,
      pr_new.SHIP_VIA_LOOKUP_CODE                     ,
      pr_new.NEED_BY_DATE                             ,
      pr_new.PROMISED_DATE                            ,
      pr_new.LAST_ACCEPT_DATE                         ,
      pr_new.PRICE_OVERRIDE                           ,
      pr_new.ENCUMBERED_FLAG                          ,
      pr_new.ENCUMBERED_DATE                          ,
      pr_new.UNENCUMBERED_QUANTITY                    ,
      pr_new.FOB_LOOKUP_CODE                          ,
      pr_new.FREIGHT_TERMS_LOOKUP_CODE                ,
      pr_new.TAXABLE_FLAG                             ,
      pr_new.TAX_NAME                                 ,
      pr_new.ESTIMATED_TAX_AMOUNT                     ,
      pr_new.FROM_HEADER_ID                           ,
      pr_new.FROM_LINE_ID                             ,
      pr_new.FROM_LINE_LOCATION_ID                    ,
      pr_new.START_DATE                               ,
      pr_new.END_DATE                                 ,
      pr_new.LEAD_TIME                                ,
      pr_new.LEAD_TIME_UNIT                           ,
      pr_new.PRICE_DISCOUNT                           ,
      pr_new.TERMS_ID                                 ,
      pr_new.APPROVED_FLAG                            ,
      pr_new.APPROVED_DATE                            ,
      pr_new.CLOSED_FLAG                              ,
      pr_new.CANCEL_FLAG                              ,
      pr_new.CANCELLED_BY                             ,
      pr_new.CANCEL_DATE                              ,
      pr_new.CANCEL_REASON                            ,
      pr_new.FIRM_STATUS_LOOKUP_CODE                  ,
      pr_new.FIRM_DATE                                ,
      pr_new.ATTRIBUTE_CATEGORY                       ,
      pr_new.ATTRIBUTE1                               ,
      pr_new.ATTRIBUTE2                               ,
      pr_new.ATTRIBUTE3                               ,
      pr_new.ATTRIBUTE4                               ,
      pr_new.ATTRIBUTE5                               ,
      pr_new.ATTRIBUTE6                               ,
      pr_new.ATTRIBUTE7                               ,
      pr_new.ATTRIBUTE8                               ,
      pr_new.ATTRIBUTE9                               ,
      pr_new.ATTRIBUTE10                              ,
      pr_new.UNIT_OF_MEASURE_CLASS                    ,
      pr_new.ENCUMBER_NOW                             ,
      pr_new.ATTRIBUTE11                              ,
      pr_new.ATTRIBUTE12                              ,
      pr_new.ATTRIBUTE13                              ,
      pr_new.ATTRIBUTE14                              ,
      pr_new.ATTRIBUTE15                              ,
      pr_new.INSPECTION_REQUIRED_FLAG                 ,
      pr_new.RECEIPT_REQUIRED_FLAG                    ,
      pr_new.QTY_RCV_TOLERANCE                        ,
      pr_new.QTY_RCV_EXCEPTION_CODE                   ,
      pr_new.ENFORCE_SHIP_TO_LOCATION_CODE            ,
      pr_new.ALLOW_SUBSTITUTE_RECEIPTS_FLAG           ,
      pr_new.DAYS_EARLY_RECEIPT_ALLOWED               ,
      pr_new.DAYS_LATE_RECEIPT_ALLOWED                ,
      pr_new.RECEIPT_DAYS_EXCEPTION_CODE              ,
      pr_new.INVOICE_CLOSE_TOLERANCE                  ,
      pr_new.RECEIVE_CLOSE_TOLERANCE                  ,
      pr_new.SHIP_TO_ORGANIZATION_ID                  ,
      pr_new.SHIPMENT_NUM                             ,
      pr_new.SOURCE_SHIPMENT_ID                       ,
      pr_new.SHIPMENT_TYPE                      ,
      pr_new.CLOSED_CODE                              ,
      pr_new.REQUEST_ID                               ,
      pr_new.PROGRAM_APPLICATION_ID                   ,
      pr_new.PROGRAM_ID                               ,
      pr_new.PROGRAM_UPDATE_DATE                      ,
      pr_new.USSGL_TRANSACTION_CODE                   ,
      pr_new.GOVERNMENT_CONTEXT                       ,
      pr_new.RECEIVING_ROUTING_ID                     ,
      pr_new.ACCRUE_ON_RECEIPT_FLAG                   ,
      pr_new.CLOSED_REASON                            ,
      pr_new.CLOSED_DATE                              ,
      pr_new.CLOSED_BY                                ,
      pr_new.ORG_ID                                   ,
      pr_new.QUANTITY_SHIPPED                         ,
      pr_new.COUNTRY_OF_ORIGIN_CODE                   ,
      pr_new.TAX_USER_OVERRIDE_FLAG                   ,
      pr_new.MATCH_OPTION                             ,
      pr_new.TAX_CODE_ID                              ,
      pr_new.CALCULATE_TAX_FLAG                       ,
      pr_new.CHANGE_PROMISED_DATE_REASON
    );

           IF v_hook_value = 'FALSE' THEN
              RETURN;
           END IF; /*added by rchandan for bug#4479131*/
     END IF;

  ELSIF v_shipment_type IN ( 'SCHEDULED', 'BLANKET' ) AND rel_found <> TRUE THEN

    --RETURN; commented for #6137011
    null;

  ELSE

     -- v_org_id := pr_new.Org_Id;
     IF v_shipment_type = 'BLANKET' THEN
         v_type_lookup_code := v_shipment_type || 'R' ;
     ELSE
         v_type_lookup_code := v_shipment_type;
     END IF;

  END IF;



/*************************************** Part 4 ********************************************************/
/************************** Processing When Tax Modifiable flag is 'Y' *********************************/
/*******************************************************************************************************/


  OPEN  Tax_Modified_Cur;
  FETCH Tax_Modified_Cur INTO v_flag;
  CLOSE Tax_Modified_Cur;

  IF v_flag = 'Y' THEN
     v_assessable_value := jai_cmn_setup_pkg.get_po_assessable_value(
                                                                v_vendor_id       ,
                                                                v_vendor_site_id  ,
                                                                v_item_id         ,
                                                                v_uom_code
                                                        );
     IF NVL( v_assessable_value, 0 ) > 0 THEN
        -- The Assessable value is greater than 0
        v_assessable_value := v_assessable_value * v_qty;
        jai_po_cmn_pkg.Ja_In_Po_Func_Curr( v_po_hdr_id, v_assessable_value, v_curr, v_curr_conv_factor );
     ELSE
        v_assessable_value := v_price*v_qty;
     END IF;

     --added, Harshita for bug #4245062
          ln_vat_assess_value :=
                     jai_general_pkg.ja_in_vat_assessable_value
                     ( p_party_id => v_vendor_id,
                       p_party_site_id => v_vendor_site_id,
                       p_inventory_item_id => v_item_id,
                       p_uom_code => v_uom_code,
                       p_default_price => v_price,
                       p_ass_value_date => trunc(SYSDATE),
                       p_party_type => 'V'
                     ) ;


     IF ln_vat_assess_value <> v_price THEN
         ln_vat_assess_value := ln_vat_assess_value *   v_qty ;
         jai_po_cmn_pkg.Ja_In_Po_Func_Curr( v_po_hdr_id, ln_vat_assess_value, v_curr, v_curr_conv_factor );
     ELSE
         ln_vat_assess_value := ln_vat_assess_value *   v_qty ;
     END IF ;

     --ended, Harshita for bug #4245062

     jai_po_cmn_pkg.Ja_In_Po_Func_Curr( v_po_hdr_id, dummy, v_curr, v_curr_conv_factor );




   -- Start, Vijay Shankar for Bug #3184673
   IF v_old_qty IS NULL OR v_old_qty = 0 THEN
    v_old_qty := 1;
   END IF;

   UPDATE JAI_PO_TAXES a
   SET tax_amount = (tax_amount * pr_new.quantity/ v_old_qty ),
     tax_target_amount = (tax_target_amount * pr_new.quantity/ v_old_qty)
   WHERE line_location_id = v_line_loc_id
   AND EXISTS (select 1 from JAI_CMN_TAXES_ALL b where b.tax_id = a.tax_id and b.adhoc_flag = 'Y');

  IF v_curr <> v_currency_code THEN
    v_currency_conv_rate := jai_cmn_utils_pkg.currency_conversion(v_gl_set_of_bks_id,
         v_curr, v_po_rate_date, v_po_rate_type, v_po_rate);
  ELSE
    v_currency_conv_rate := 1;
  END IF;

  jai_po_tax_pkg.calc_tax(
    p_type => 'STANDARDPO',
    p_header_id => v_po_hdr_id,
    P_line_id => v_po_line_id,
    p_line_location_id => v_line_loc_id,
    p_line_focus_id => null,
    p_line_quantity => v_qty,
    p_base_value => v_price*v_qty,
    p_line_uom_code => v_uom_code,
    p_tax_amount => P_TAX_AMOUNT,
    p_assessable_value => v_assessable_value,
    p_vat_assess_value => ln_vat_assess_value,    -- added, Harshita for bug #4245062
    p_item_id => v_item_id,
    p_conv_rate => v_currency_conv_rate,
    p_po_curr => v_curr,
    p_func_curr => v_currency_code
    , pv_retroprice_changed => lv_retro_price_flag --Added by Kevin Cheng for Retroactive Price 2008/01/13
  );
  -- End, Vijay Shankar for Bug #3184673

    /* commented by Vijay Shankar for Bug #3184673
       jai_po_tax_pkg.calculate_tax( 'STANDARDPO',  v_po_hdr_id,  v_po_line_id,  v_line_loc_id, v_qty,
          v_price*v_qty, v_uom_code,  P_TAX_AMOUNT,  v_assessable_value,
          NULL, v_curr_conv_factor
       );
    */

    -- SELECT 'END_JA_IN_PO_TAX_UPDATE_TRG_1.3' INTO v_trigger_name FROM DUAL;

     RETURN;
  END IF;


/*************************************** Part 5 ********************************************************/
/************************** Processing When Tax Modifiable flag is 'N' *********************************/
/*******************************************************************************************************/


 IF v_flag = 'N' OR retcode = FALSE THEN

     DELETE FROM JAI_PO_TAXES
     WHERE Po_Line_Id = v_po_line_id
     AND NVL( Line_Location_Id, - 999 ) = NVL( v_line_loc_id, -999 );

     DELETE FROM JAI_PO_LINE_LOCATIONS
     WHERE Po_Line_Id = v_po_line_id
     AND NVL( Line_Location_Id, - 999 ) = NVL( v_line_loc_id, -999 );

     x := v_line_loc_id;
     y := v_po_line_id;

     IF v_type_lookup_code = 'QUOTATION' AND v_quot_class_code = 'CATALOG' THEN
        x := v_from_line_loc_id;
        y := v_from_line_id;
     END IF;

     IF v_shipment_type IN ( 'SCHEDULED', 'BLANKET' ) THEN

          jai_po_cmn_pkg.process_release_shipment ( v_shipment_type,
                                  v_src_ship_id,
                                  v_line_loc_id,
                                  v_po_line_id,
                                  v_po_hdr_id,
                                  v_qty,
                                  v_po_rel_id,
                                  v_cre_dt,
                                  v_cre_by,
                                  v_last_upd_dt,
                                  v_last_upd_by,
                                  v_last_upd_login,
                                  'I'
                                  ,lv_retro_price_flag --Added by Kevin Cheng for Retroactive Price 2008/01/13
                                 );

        RETURN;
     ELSE

       jai_po_cmn_pkg.insert_line( 'CATALOG', v_line_loc_id, v_po_hdr_id, v_po_line_id, v_cre_dt,
                                             v_cre_by,
                                             v_last_upd_dt,
                                             v_last_upd_by,
                                             v_last_upd_login,
                                             'I' );

      jai_po_tax_pkg.Ja_In_Po_Case1( v_type_lookup_code,
                                             v_quot_class_code,
                                                   v_vendor_id,
                                                     v_vendor_site_id,
                                                   v_curr,
                                             v_org_id,
                                             v_item_id,
                                             v_uom_measure,
                                             v_line_loc_id,
                                             v_po_hdr_id,
                                             v_po_line_id,
                                             y,
                                             x,
                                             v_price,
                                             v_Qty,
                                             v_cre_dt,
                                             v_cre_by,
                                             v_last_upd_dt,
                                             v_last_upd_by,
                                             v_last_upd_login,
                                             'I',
                                                   success );

     IF success <> 0 THEN
        jai_po_tax_pkg.Ja_In_Po_Case2 ( v_type_lookup_code,
                                                v_quot_class_code,
                                                v_vendor_id,
                                                v_vendor_site_id,
                                                v_curr,
                                                v_org_id,
                                                v_item_id,
                                                v_line_loc_id,
                                                v_po_hdr_id,
                                                v_po_line_id,
                                                v_price,
                                                v_qty,
                                                v_cre_dt,
                                                v_cre_by,
                                                v_last_upd_dt,
                                                v_last_upd_by,
                                                v_last_upd_login,
                                                v_uom_measure,
                                                NULL,
                                                null,
                                                ln_vat_assess_value, -- added, Harshita for bug #4245062
                                                null, /*following four parameters added for bug 8224547*/
						null,
						null,
						null,
						null,
                                                lv_retro_price_flag --Added by Kevin Cheng for Retroactive Price 2008/01/13
                                                );

     END IF;
   END IF;

ELSE

    IF v_line_loc_id IS NOT NULL THEN
       OPEN  Fetch_Sum_Cur;
       FETCH Fetch_Sum_Cur INTO v_tax_amt;
       CLOSE Fetch_Sum_Cur;
    ELSE
       OPEN  Fetch_Sum1_Cur;
       FETCH Fetch_Sum1_Cur INTO v_tax_amt;
       CLOSE Fetch_Sum1_Cur;
    END IF;

    IF v_type_lookup_code = 'BLANKET' OR v_quot_class_code = 'CATALOG' THEN
       v_tax_amt := NULL;
       v_tot_amt := NULL;
    ELSE
       v_tot_amt := v_tax_amt + ( v_qty * v_price );
    END IF;

    UPDATE  JAI_PO_LINE_LOCATIONS
    SET     Tax_Amount = v_tax_amt,
            Total_Amount = v_tot_amt,
            Last_Updated_By = v_last_upd_by,
              Last_Update_Date = v_last_upd_dt,
              Last_Update_Login = v_last_upd_login
    WHERE   Po_Line_Id = v_po_line_id
     AND    Line_Location_Id = v_line_loc_id;
  END IF;

-- SELECT 'END_JA_IN_PO_TAX_UPDATE_TRG_FINAL' INTO v_trigger_name FROM DUAL;


  END ARU_T1 ;

END JAI_PO_LLA_TRIGGER_PKG ;

/
