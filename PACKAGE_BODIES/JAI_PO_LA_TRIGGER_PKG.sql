--------------------------------------------------------
--  DDL for Package Body JAI_PO_LA_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_PO_LA_TRIGGER_PKG" AS
/* $Header: jai_po_la_t.plb 120.2.12010000.7 2010/02/16 11:41:41 nprashar ship $ */

/*  REM +======================================================================+
  REM NAME          ARD_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_PO_LA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_PO_LA_ARD_T2
  REM
  REM +======================================================================+
*/
  PROCEDURE ARD_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
   ------------- added by Gsr 12-jul-01
 v_operating_id                     number; --File.Sql.35 Cbabu   :=pr_new.ORG_ID;
 v_gl_set_of_bks_id                 gl_sets_of_books.set_of_books_id%type;
 v_currency_code                     gl_sets_of_books.currency_code%type;

  /* Bug 5243532. Added by Lakshmi Gopalsami
   * Removed cursor Fetch_Book_Id_Cur
   * and implemented using caching logic.
   */

 CURSOR Sob_Cur is
 select Currency_code
 from gl_sets_of_books
 where set_of_books_id = v_gl_set_of_bks_id;
------ End of addition by Gsri on 12-jul-01


  v_po_line_id    NUMBER; --File.Sql.35 Cbabu   :=  pr_old.Po_Line_Id;

  dummy     NUMBER;


  CURSOR Check_Llid_Cur IS SELECT COUNT( Line_Location_Id )
             FROM   JAI_PO_TAXES
               WHERE  Po_Line_Id = v_po_line_id;

  /* Bug 5243532. Added by Lakshmi Gopalsami
   * Defined variable for implementing caching logic.
   */
  l_func_curr_det jai_plsql_cache_pkg.func_curr_details;
  BEGIN
    pv_return_code := jai_constants.successful ;
    /*------------------------------------------------------------------------------------------
 FILENAME: Ja_In_Po_Lines_Tax_Delete_Trg.sql

 CHANGE HISTORY:
S.No      Date          Author and Details
1         29-Nov-2004   Sanjikum for 4035297. Version 115.1
                        Changed the 'INR' check. Added the call to jai_cmn_utils_pkg.check_jai_exists

Dependency Due to this Bug:-
The current trigger becomes dependent on the function jai_cmn_utils_pkg.check_jai_exists version 115.0.

2.  08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old
                  DB Entity as requiredfor CASE COMPLAINCE.  Version 116.1

3. 13-Jun-2005    File Version: 116.2
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done

Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Current Version    Current Bug    Dependent           Files                Version   Author   Date          Remarks
Of File                           On Bug/Patchset    Dependent On

Ja_In_Po_Lines_Tax_Delete_Trg.sql
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
115.1              4035297        IN60105D2+4033992  ja_in_util_pkg_s.sql  115.0     Sanjikum 29-Nov-2004  Call to this function.
                                                     ja_in_util_pkg_s.sql  115.0     Sanjikum

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

  --File.Sql.35 Cbabu
  v_operating_id   :=pr_new.ORG_ID;
  v_po_line_id     :=  pr_old.Po_Line_Id;
 /* Bug 5243532. Added by Lakshmi Gopalsami
    REmoved the cursor Fetch_Book_Id_Cur and implemented the same using
    caching logic.
  */
  l_func_curr_det := jai_plsql_cache_pkg.return_sob_curr
                        (p_org_id  => v_operating_id);
  v_gl_set_of_bks_id := l_func_curr_det.ledger_id;

   --IF jai_cmn_utils_pkg.check_jai_exists( p_calling_object => 'JA_IN_PO_LINES_TAX_DELETE_TRG',
   --                                p_set_of_books_id => v_gl_set_of_bks_id ) = FALSE THEN
   -- RETURN;`
   --END IF;


  DELETE FROM JAI_PO_LINE_LOCATIONS
   WHERE Po_Line_Id = v_po_line_id;

  OPEN  Check_Llid_Cur;
  FETCH Check_Llid_Cur INTO dummy;
  CLOSE Check_Llid_Cur;

  IF NVL( dummy, 0 ) > 0 THEN
     DELETE FROM JAI_PO_TAXES
      WHERE Po_Line_Id = v_po_line_id;
  END IF;
  END ARD_T1 ;

  /*
  REM +======================================================================+
  REM NAME          ARI_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_PO_LA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_PO_LA_ARI_T1
  REM
  REM +======================================================================+
  */
  PROCEDURE ARI_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
	   v_org_id                NUMBER;     --       := pr_new.Org_Id;
    v_type_lookup_code      VARCHAR2(10);
    v_quot_class_code       VARCHAR2(25);
    v_vendor_id             NUMBER;
    v_vendor_site_id        NUMBER;
    v_curr                  VARCHAR2(15);
    v_ship_loc_id           NUMBER;

    v_po_line_id            NUMBER; --File.Sql.35 Cbabu        := pr_new.Po_Line_Id ;
    v_po_hdr_id             NUMBER; --File.Sql.35 Cbabu        := pr_new.Po_Header_Id;
    v_frm_po_line_id        NUMBER; --File.Sql.35 Cbabu        := pr_new.From_Line_Id;
    v_cre_dt                DATE ; --File.Sql.35 Cbabu             := pr_new.Creation_Date;
    v_cre_by                NUMBER ; --File.Sql.35 Cbabu           := pr_new.Created_By;
    v_last_upd_dt           DATE  ; --File.Sql.35 Cbabu            := pr_new.Last_Update_Date ;
    v_last_upd_by           NUMBER; --File.Sql.35 Cbabu        := pr_new.Last_Updated_By;
    v_last_upd_login        NUMBER; --File.Sql.35 Cbabu        := pr_new.Last_Update_Login;
    v_uom_measure           VARCHAR2(25); --File.Sql.35 Cbabu      := pr_new.Unit_Meas_Lookup_Code;
    success                 NUMBER; --File.Sql.35 Cbabu        := 1;

    v_item_id               NUMBER ;--File.Sql.35 Cbabu       := pr_new.Item_Id;
    v_tax_ctg_id            NUMBER;
    v_uom_code              VARCHAR2(3);

    --  found               BOOLEAN;
    v_currency_code         gl_sets_of_books.currency_code%type; --added by Gsr and Sriram on 21-03-2001

    -- Vijay Shankar for Bug# 3466223
    v_from_header_id NUMBER;
    v_from_type_lookup_code PO_HEADERS_ALL.from_type_lookup_code%TYPE;
    result  BOOLEAN;
    req_id  NUMBER;

    CURSOR Check_Rfq_Quot_Cur IS
        SELECT Type_Lookup_Code, Quotation_Class_Code, Vendor_id,
            Vendor_Site_Id, Currency_Code, Ship_To_Location_Id
            , from_header_id, from_type_lookup_code     -- Vijay Shankar for Bug# 3466223
        FROM   Po_Headers_All
        WHERE  Po_Header_Id = v_po_hdr_id;

    -- Get the Inventory Organization Id
    CURSOR Fetch_Org_Id_Cur IS
        SELECT Inventory_Organization_Id
        FROM   Hr_Locations
        WHERE  Location_Id = v_ship_loc_id;

  -- Vijay Shankar for Bug# 3184418
    CURSOR c_tax_modified_flag(p_po_line_id IN NUMBER) IS
        SELECT tax_modified_flag
        FROM JAI_PO_LINE_LOCATIONS
        WHERE po_line_id = p_po_line_id
        AND line_location_id IS NULL;

    v_tax_modified_flag CHAR(1);
    v_inv_org_id NUMBER;

    -- Vijay Shankar for bugs# 3570189
    v_hook_value VARCHAR2(10);  --File.Sql.35 Cbabu  := 'TRUE';
  BEGIN
    pv_return_code := jai_constants.successful ;
    /*------------------------------------------------------------------------------------------
Change history:
S.No      Date          Author and Details
--------------------------------------------------------------------------------------------
1    16/12/2003    Vijay Shankar(cbabu) for Bug# 3184418, Fileversion: 618.1
                        code modified to take care of the following issues
                         - If RFQ is autocreated from Requisition, then taxes if present in Requisition should default
                         onto the RFQ without check for Record in JAI_CMN_LOCATORS_T table. (this is to verify whether the user
                         has navigated through Localization form or not). With this fix, taxes will get defaulted onto RFQ if
                         the INR check is passed and required SETUPs are done
                         - For a Quotation, code is modified to copy taxes from source document if taxes are in source document
                         are modified, otherwise it will default the taxes onto quotation line (i.e line_location_id = NULL) via
                         defaulting logic as per setups

2    20/02/2004      Nagaraj.s for bug 3438863. , Fileversion: 618.2
                      Hook Functionality is incorporated by calling the package
                      jai_cmn_hook_pkg.sql
                      Hence this is a certain dependency issue and should be carefully handled

3    14/04/2004     Vijay Shankar for bugs# 3570189 and 3553351, Version : 619.1
                     BUG# 3570189: PO Hook Functionality is made compatible with 11.5.3 Base Applications by removing last 11 parameters in call to
                     jai_cmn_hook_pkg.Ja_In_po_lines_all procedure
                     Removed Locator related code and the defaultation happens only base on HOOK Implemenation by Ct. By Default tax
                     defaultation happens for all documents created with INR as functional currency

                     BUG# 3553351: Taxes are not getting defaulted for BPA and success is made 0 after returning from
                     jai_po_tax_pkg.Ja_In_Po_Case1 procedure. This is rectified by commenting the line success = 0

                     FileVersion: 618.2 is obsoleted with this Version
                     This is a DEPENDANCY for later versions of the file

4   15/04/2004      Vijay Shankar for Bug# 3466223, FileVersion# 619.2
                     Code is added to Submit Request for Conc. Prog. JAINCPDC to default taxes for BPA lines when created from a
                      Source Document eg. Quotation

5. 29/Nov/2004      Aiyer for bug#4035566. Version#115.1
                      Issue:-
                      The trigger should not get fired when the  non-INR based set of books is attached to the current operating unit
                      where transaction is being done.

                      Fix:-
                      Function jai_cmn_utils_pkg.check_jai_exists is being called which returns the TRUE if the currency is INR and FALSE if the currency is
                      NON-INR
            Also removed the two cursors Fetch_Book_Id_Cur and Sob_cur and variables v_gl_set_of_bks_id and  v_currency_code

                      Dependency Due to this Bug:-
              The current trigger becomes dependent on the function jai_cmn_utils_pkg.check_jai_exists version 115.0. introduced through the bug 4033992

6.  19-Mar-05      rallamse for bug#4227171 Version#115.2
                   Remove automatic GSCC errors

7.  19-Mar-05      rallamse for bug#4250072 Version#115.3
                   Added P_VAT_ASSESS_VALUE as argument to  jai_po_tax_pkg.Ja_In_Po_Case2

8.   08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old
                   DB Entity as required for CASE COMPLAINCE.  Version 116.1

9. 13-Jun-2005    File Version: 116.2
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done

Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )
--------------------------------------------------------------------------------------------------------------------------------------
Current Version    Current Bug    Dependent           Files                Version   Author   Date          Remarks
Of File                           On Bug/Patchset    Dependent On
ja_in_po_lines_set_locator_trg
--------------------------------------------------------------------------------------------------------------------------------------
618.2 (Obsolete)   3438863       IN60105D2

619.1              3570189       IN60105D2 + 3438863

115.1              4035566        IN60105D2  +         ja_in_util_pkg_s.sql  115.0     Aiyer    29-Nov-2004  Call to this function.
                                  3438863    +         ja_in_util_pkg_b.sql  115.0
                                  3570189  +
                                  4033992

115.2             4250072         IN60106 +
                                  4035566 +         jai_po_tax_pkg.Ja_In_Po_Case2
                                  4245089

--------------------------------------------------------------------------------------------------------------------------------------*/

  --File.Sql.35 Cbabu
  v_po_line_id            := pr_new.Po_Line_Id ;
  v_po_hdr_id             := pr_new.Po_Header_Id;
  v_frm_po_line_id        := pr_new.From_Line_Id;
  v_cre_dt                := pr_new.Creation_Date;
  v_cre_by                := pr_new.Created_By;
  v_last_upd_dt           := pr_new.Last_Update_Date ;
  v_last_upd_by           := pr_new.Last_Updated_By;
  v_last_upd_login        := pr_new.Last_Update_Login;
  v_uom_measure           := pr_new.Unit_Meas_Lookup_Code;
  success                 := 1;
    v_item_id             := pr_new.Item_Id;
    v_hook_value          := 'TRUE';

  /*
  || Code added by aiyer for the bug 4035566
  || Call the function jai_cmn_utils_pkg.check_jai_exists to check the current set of books in INR/NON-INR based.
  */
  --IF jai_cmn_utils_pkg.check_jai_exists ( p_calling_object      => 'JA_IN_PO_LINES_SET_LOCATOR_TRG' ,
  --                 p_org_id              => pr_new.org_id
  --                               )  = FALSE
  --THEN
    /*
  || return as the current set of books is NON-INR based
  */
  --  RETURN;
  -- END IF;


-- Start, Vijay Shankar for bugs# 3570189
-- If v_hook_value is TRUE, then it means taxes should be defaulted. IF FALSE then return
v_hook_value := jai_cmn_hook_pkg.Ja_In_po_lines_all(
        pr_new.PO_LINE_ID                          ,
        pr_new.PO_HEADER_ID                       ,
        pr_new.LINE_TYPE_ID                       ,
        pr_new.LINE_NUM                            ,
        pr_new.ITEM_ID                                  ,
        pr_new.ITEM_REVISION                            ,
        pr_new.CATEGORY_ID                              ,
        pr_new.ITEM_DESCRIPTION                         ,
        pr_new.UNIT_MEAS_LOOKUP_CODE                    ,
        pr_new.QUANTITY_COMMITTED                       ,
        pr_new.COMMITTED_AMOUNT                         ,
        pr_new.ALLOW_PRICE_OVERRIDE_FLAG                ,
        pr_new.NOT_TO_EXCEED_PRICE                      ,
        pr_new.LIST_PRICE_PER_UNIT                      ,
        pr_new.UNIT_PRICE                               ,
        pr_new.QUANTITY                                 ,
        pr_new.UN_NUMBER_ID                             ,
        pr_new.HAZARD_CLASS_ID                          ,
        pr_new.NOTE_TO_VENDOR                           ,
        pr_new.FROM_HEADER_ID                           ,
        pr_new.FROM_LINE_ID                             ,
        pr_new.MIN_ORDER_QUANTITY                       ,
        pr_new.MAX_ORDER_QUANTITY                       ,
        pr_new.QTY_RCV_TOLERANCE                        ,
        pr_new.OVER_TOLERANCE_ERROR_FLAG                ,
        pr_new.MARKET_PRICE                             ,
        pr_new.UNORDERED_FLAG                           ,
        pr_new.CLOSED_FLAG                   ,
        pr_new.USER_HOLD_FLAG                           ,
        pr_new.CANCEL_FLAG                              ,
        pr_new.CANCELLED_BY                             ,
        pr_new.CANCEL_DATE                              ,
        pr_new.CANCEL_REASON                            ,
        pr_new.FIRM_STATUS_LOOKUP_CODE                  ,
        pr_new.FIRM_DATE                                ,
        pr_new.VENDOR_PRODUCT_NUM                       ,
        pr_new.CONTRACT_NUM                             ,
        pr_new.TAXABLE_FLAG                             ,
        pr_new.TAX_NAME                                 ,
        pr_new.TYPE_1099                                ,
        pr_new.CAPITAL_EXPENSE_FLAG                     ,
        pr_new.NEGOTIATED_BY_PREPARER_FLAG              ,
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
        pr_new.REFERENCE_NUM                            ,
        pr_new.ATTRIBUTE11                              ,
        pr_new.ATTRIBUTE12                              ,
        pr_new.ATTRIBUTE13                              ,
        pr_new.ATTRIBUTE14                              ,
        pr_new.ATTRIBUTE15                              ,
        pr_new.MIN_RELEASE_AMOUNT                       ,
        pr_new.PRICE_TYPE_LOOKUP_CODE                   ,
        pr_new.CLOSED_CODE                              ,
        pr_new.PRICE_BREAK_LOOKUP_CODE                  ,
        pr_new.USSGL_TRANSACTION_CODE                   ,
        pr_new.GOVERNMENT_CONTEXT                       ,
        pr_new.REQUEST_ID                               ,
        pr_new.PROGRAM_APPLICATION_ID                   ,
        pr_new.PROGRAM_ID                               ,
        pr_new.PROGRAM_UPDATE_DATE                      ,
        pr_new.CLOSED_DATE                              ,
        pr_new.CLOSED_REASON                            ,
        pr_new.CLOSED_BY                                ,
        pr_new.TRANSACTION_REASON_CODE                  ,
        pr_new.ORG_ID                                   ,
        pr_new.QC_GRADE                                 ,
        pr_new.BASE_UOM                                 ,
        pr_new.BASE_QTY                                 ,
        pr_new.SECONDARY_UOM                            ,
        pr_new.SECONDARY_QTY                            ,
        pr_new.LINE_REFERENCE_NUM                       ,
        pr_new.PROJECT_ID                               ,
        pr_new.TASK_ID                                  ,
        pr_new.EXPIRATION_DATE                          ,
        pr_new.TAX_CODE_ID
);

IF v_hook_value = 'FALSE' THEN
    RETURN;
END IF;
-- End, Vijay Shankar for bugs# 3570189

OPEN Check_Rfq_Quot_Cur;
FETCH Check_Rfq_Quot_Cur INTO v_type_lookup_code, v_quot_Class_Code, v_vendor_id,
               v_vendor_site_id, v_curr, v_ship_loc_id
               , v_from_header_id, v_from_type_lookup_code;     -- Vijay Shankar for Bug# 3466223
CLOSE Check_Rfq_Quot_Cur;

OPEN  Fetch_Org_Id_cur;
FETCH Fetch_Org_Id_cur INTO v_org_id;
CLOSE Fetch_Org_Id_cur;

IF v_type_lookup_code = 'BLANKET' OR v_quot_class_code = 'CATALOG' THEN

    -- Start, Vijay Shankar for Bug# 3466223
    IF v_type_lookup_code = 'BLANKET' AND v_from_header_id IS NOT NULL THEN

        Insert into JAI_PO_COPYDOC_T(
            TYPE, PO_HEADER_ID, PO_LINE_ID, LINE_LOCATION_ID, LINE_NUM,
            SHIPMENT_NUM, ITEM_ID, FROM_HEADER_ID, FROM_TYPE_LOOKUP_CODE,
            CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN
        ) Values (
            'L', v_po_hdr_id, v_po_line_id, NULL, pr_new.line_num,
            NULL, v_item_id, v_from_header_id, v_from_type_lookup_code,
            v_cre_dt, v_cre_by, v_last_upd_dt, v_last_upd_by, v_last_upd_login
        );

        result := Fnd_Request.Set_Mode( TRUE );

        req_id := Fnd_Request.Submit_Request('JA', 'JAINCPDC',
                'Copy Document India Localization.', SYSDATE, FALSE,
                'L', v_po_hdr_id, v_po_line_id, NULL,
                pr_new.line_num, NULL, v_item_id,
                v_from_header_id, v_from_type_lookup_code,
                v_cre_dt, v_cre_by, v_last_upd_dt, v_last_upd_by, v_last_upd_login);

        RETURN;

    END IF;
    -- End, Vijay Shankar for Bug# 3466223

    -- Start, Vijay Shankar for Bug# 3184418
    -- this is for Quotation
    IF v_frm_po_line_id IS NOT NULL AND v_quot_class_code = 'CATALOG' THEN
        OPEN c_tax_modified_flag(v_frm_po_line_id);
        FETCH c_tax_modified_flag INTO v_tax_modified_flag;
        CLOSE c_tax_modified_flag;

        IF v_tax_modified_flag IS NULL THEN
            v_tax_modified_flag := 'N';
        END IF;
    ELSE
        v_tax_modified_flag := 'N';
    END IF;

    -- this call is moved here which is previously called after the check (IF v_type_lookup_code = 'BLANKET' OR v_quot_class_code = 'CATALOG' THEN)
    jai_po_cmn_pkg.insert_line( 'CATALOG', NULL,
        v_po_hdr_id, v_po_line_id, v_cre_dt,
        v_cre_by, v_last_upd_dt, v_last_upd_by, v_last_upd_login, 'I'
    );

    IF ( v_tax_modified_flag = 'Y' AND v_quot_class_code = 'CATALOG') OR v_type_lookup_code = 'BLANKET' THEN
    -- End, Vijay Shankar for Bug# 3184418

        jai_po_tax_pkg.Ja_In_Po_Case1(
            v_type_lookup_code, v_quot_class_code, v_vendor_id, v_vendor_site_id,
            v_curr, v_org_id, v_item_id, v_uom_measure, NULL,
            v_po_hdr_id, v_po_line_id, v_frm_po_line_id, NULL, NULL, NULL,
            v_cre_dt, v_cre_by, v_last_upd_dt, v_last_upd_by, v_last_upd_login, 'I', success
        );

        -- Vijay Shankar for bugs# 3570189, 3553351
        -- success := 0;
    -- Vijay Shankar for Bug# 3184418
    ELSE
        success := 1;
    END IF;

    IF success <> 0 THEN

        jai_po_tax_pkg.Ja_In_Po_Case2 (
            v_type_lookup_code, v_quot_class_code, v_vendor_id, v_vendor_site_id,
            v_curr, v_org_id,  v_item_id, NULL,
            v_po_hdr_id, v_po_line_id, NULL, NULL, v_cre_dt, v_cre_by,
            v_last_upd_dt, v_last_upd_by, v_last_upd_login, v_uom_measure, FLAG => 'INSLINES',P_VAT_ASSESS_VALUE => NULL /* Added p_vat_assess_value by rallamse bug#4250072 VAT */
        );

    END IF;

END IF;
  END ARI_T1 ;

  /*
  REM +======================================================================+
  REM NAME          ARU_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_PO_LA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_PO_LA_ARU_T3
  REM
  REM +======================================================================+
  */
 PROCEDURE ARU_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
	------------- added by Gsr 12-jul-01
 v_operating_id           number;--File.Sql.35 Cbabu   :=pr_new.ORG_ID;
 v_gl_set_of_bks_id       gl_sets_of_books.set_of_books_id%type;
 v_currency_code          gl_sets_of_books.currency_code%type;

 /* Bug 5243532. Added by Lakshmi Gopalsami
  * Removed cursor Fetch_Book_Id_Cur
  * and implemented using caching logic.
  */

CURSOR Sob_Cur is
select Currency_code
from gl_sets_of_books
where set_of_books_id = v_gl_set_of_bks_id;
------ End of addition by Gsri on 12-jul-01

  v_po_hdr_id         NUMBER; --File.Sql.35 Cbabu       :=  pr_new.Po_Header_Id;
  v_po_line_id        NUMBER; --File.Sql.35 Cbabu     :=  pr_new.Po_Line_Id;
  v_line_loc_id       NUMBER;
  v_line_amt                NUMBER;
  v_org_id                  NUMBER; --    :=   pr_new.Org_Id;
  v_vendor_site_id          NUMBER;
  v_Type_Lookup_Code      VARCHAR2(25);
  v_Quot_Class_Code       VARCHAR2(25);
  v_vendor_id         NUMBER;
  v_reqn_entries          NUMBER;
  v_requisition_line_id   NUMBER;
  v_curr              VARCHAR2(3);
  v_ship_loc_id     NUMBER;
  v_t_flag                VARCHAR2(1);

  v_n_price       NUMBER; --File.Sql.35 Cbabu     := pr_new.Unit_Price;
  v_price       NUMBER;
  v_qty       NUMBER;
  v_item_id       NUMBER; --File.Sql.35 Cbabu       := pr_new.Item_Id;
  v_line_uom      VARCHAR2(25); --File.Sql.35 Cbabu       := pr_new.Unit_Meas_Lookup_Code;
  v_cre_dt        DATE ; --File.Sql.35 Cbabu      := pr_new.Creation_Date;
  v_cre_by        NUMBER; --File.Sql.35 Cbabu     := pr_new.Created_By;
  v_last_upd_dt     DATE ; --File.Sql.35 Cbabu      := pr_new.Last_Update_Date ;
  v_last_upd_by     NUMBER; --File.Sql.35 Cbabu     := pr_new.Last_Updated_By;
  v_last_upd_login    NUMBER ; --File.Sql.35 Cbabu    := pr_new.Last_Update_Login;
  v_uom_measure     VARCHAR2(25);
  v_hook_value VARCHAR2(10);/*added by rchandan for bug#4479131*/
  v_from_header_id  NUMBER; /*Added by nprashar for bug # 9362704*/
  v_from_line_id   NUMBER;/*Added by nprashar for bug # 9362704*/
  v_unit_code             VARCHAR2(25); /*Added by nprashar for bug # 9362704*/
  v_assessable_value     NUMBER; /*Added by nprashar for bug # 9362704*/

  success       NUMBER; --File.Sql.35 Cbabu     := 1;

  /*v_rowid       JAI_CMN_LOCATORS_T.Row_Id%TYPE;*//*commented by rchandan for bug#4479131*/
  found       BOOLEAN;
  v_style_id  po_headers_all.style_id%TYPE;--Added by Sanjikum for Bug#4483042

  /* Bug 5243532. Added by Lakshmi Gopalsami
   * Defined variable for implementing caching logic.
   */
  l_func_curr_det jai_plsql_cache_pkg.func_curr_details;

------------------------------------------------------------------------------------

  CURSOR POC_Cur IS SELECT Rowid
        FROM   Po_Headers_All
        WHERE  Po_Header_Id = v_po_hdr_id;

  CURSOR Check_Rfq_Quot_Cur IS SELECT Type_Lookup_Code, Quotation_Class_Code, Vendor_id,
                                      Vendor_Site_Id, Currency_Code, Ship_To_Location_Id,
                                      style_id --Added by Sanjikum for Bug#4483042
                               FROM   Po_Headers_All
                               WHERE  Po_Header_Id = v_po_hdr_id;

  -- Get the Inventory Organization Id

 CURSOR Fetch_Org_Id_Cur IS SELECT Inventory_Organization_Id
          FROM   Hr_Locations
          WHERE  Location_Id = v_ship_loc_id;

--Removed cursor CURSOR C_Check_Quot_lines     /*Added by nprashar for bug # 9362704*/
CURSOR Fetch_UOMCode_Cur( v_temp_uom IN VARCHAR2 ) IS
    SELECT Uom_Code
    FROM   Mtl_Units_Of_Measure
    WHERE  Unit_Of_Measure = v_temp_uom;


------------------------------------------------------------------------------------


  CURSOR Fetch_Lines_Cur IS SELECT Line_Location_Id, Price_Override, Quantity, Unit_Meas_Lookup_Code
                            FROM   Po_Line_Locations_All
                            WHERE  Po_Line_Id = v_po_line_id;

  CURSOR Fetch_Flag_Cur( llid IN NUMBER ) IS SELECT NVL( Tax_Modified_Flag, 'N' ) Tax_Modified_Flag
                                             FROM   JAI_PO_LINE_LOCATIONS
                                             WHERE  Line_Location_Id = llid
                                               AND  Po_Line_Id = v_po_line_id;
  BEGIN
    pv_return_code := jai_constants.successful ;
     /*------------------------------------------------------------------------------------------
 FILENAME: Ja_In_Po_Lines_Tax_Update_Trg.sql

 CHANGE HISTORY:
S.No      Date          Author and Details
1         29-Nov-2004   Sanjikum for 4035297. Version 115.1
                        Changed the 'INR' check. Added the call to jai_cmn_utils_pkg.check_jai_exists

2.  19-Mar-05      rallamse for bug#4227171 Version#115.2
                   Remove automatic GSCC errors

3.  19-Mar-05      rallamse for bug#4250072 Version#115.3
                   Changes for VAT

Dependency Due to this Bug:-
The current trigger becomes dependent on the function jai_cmn_utils_pkg.check_jai_exists version 115.0.

4.  08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old DB Entity Names,
                  as required for CASE COMPLAINCE. Version 116.1

5. 13-Jun-2005    File Version: 116.2
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done

6. 08-Jul-2005    Sanjikum for Bug#4483042.File Version: 116.3
                  1) Added a call to jai_cmn_utils_pkg.validate_po_type, to check whether for the current PO
                     IL functionality should work or not.

7.  8-Jul-2005    File Version: 116.3
                  rchandan for bug#4479131
      The object is modified to eliminate the paddr usage.

8. 12-Jul-2005    Sanjikum for Bug#4483042.File Version: 117.2
                  1) Added a new parameter in cursor - Check_Rfq_Quot_Cur



  Future Dependencies For the release Of this Object:-
  (Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
  A datamodel change )
  -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Current Version    Current Bug    Dependent           Files                Version   Author   Date          Remarks
  Of File                           On Bug/Patchset    Dependent On

  Ja_In_Po_Lines_Tax_Update_Trg.sql
  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  115.1              4035297        IN60105D2+4033992  ja_in_util_pkg_s.sql  115.0     Sanjikum 29-Nov-2004  Call to this function.
                                                       ja_in_util_pkg_s.sql  115.0     Sanjikum

  115.3              4250072        IN60106 +
                                    4035297 +
                                    4245089

  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    --File.Sql.35 Cbabu
    v_operating_id     :=pr_new.ORG_ID;
    v_po_hdr_id       :=  pr_new.Po_Header_Id;
    v_po_line_id      :=  pr_new.Po_Line_Id;
    v_n_price         := pr_new.Unit_Price;
    v_item_id         := pr_new.Item_Id;
    v_line_uom        := pr_new.Unit_Meas_Lookup_Code;
    v_cre_dt          := pr_new.Creation_Date;
    v_cre_by          := pr_new.Created_By;
    v_last_upd_dt     := pr_new.Last_Update_Date ;
    v_last_upd_by     := pr_new.Last_Updated_By;
    v_last_upd_login  := pr_new.Last_Update_Login;
    v_from_header_id  := pr_new.from_header_id;
    v_from_line_id    := pr_new.from_line_id;
    success           := 1;

    /* Bug 5243532. Added by Lakshmi Gopalsami
     * Removed cursor Fetch_Book_Id_Cur
     * and implemented using caching logic.
     */

    l_func_curr_det := jai_plsql_cache_pkg.return_sob_curr
                        (p_org_id  => v_operating_id);
    v_gl_set_of_bks_id := l_func_curr_det.ledger_id;


    --IF jai_cmn_utils_pkg.check_jai_exists(p_calling_object => 'JA_IN_PO_LINES_TAX_UPDATE_TRG',
    --                              p_set_of_books_id => v_gl_set_of_bks_id) = FALSE THEN
    --  RETURN;
    -- END IF;


    OPEN Check_Rfq_Quot_Cur;
    FETCH Check_Rfq_Quot_Cur INTO  v_Type_Lookup_Code, v_Quot_Class_Code, v_vendor_id,
                                   v_vendor_site_id, v_curr, v_ship_loc_id,
                                   v_style_id; --Added by Sanjikum for Bug#4483042
    CLOSE Check_Rfq_Quot_Cur;

    --code added by Sanjikum for Bug#4483042
    IF jai_cmn_utils_pkg.validate_po_type(p_style_id => v_style_id) = FALSE THEN
      return;
    END IF;

  -- POC

 /*   IF v_type_lookup_code IN ( 'RFQ', 'QUOTATION' ) THEN
       jai_po_cmn_pkg.query_locator_for_line( v_po_hdr_id, 'JAINRFQQ', found );
    ELSIF v_type_lookup_code IN ( 'STANDARD', 'PLANNED', 'CONTRACT', 'BLANKET' ) THEN
       jai_po_cmn_pkg.query_locator_for_line( v_po_hdr_id, 'JAINPO', found );
    END IF;*//*commented by rchandan for bug#4479131*/

IF nvl(pr_new.from_header_id,0) <> nvl(pr_old.from_header_id,0) and nvl(pr_new.from_line_id,0) <> nvl(pr_old.from_line_id,0) Then  /*Added by nprashar for bug # 9362704*/
  IF v_type_lookup_code IN ('STANDARD', 'PLANNED')  Then /*Added by nprashar for bug # 9362704*/
       If  v_from_header_id is NOT NULL and v_from_line_id is NOT NULL
           Then

	 OPEN  Fetch_UOMCode_Cur( v_line_uom);
         FETCH Fetch_UOMCode_Cur INTO v_unit_code;
         CLOSE Fetch_UOMCode_Cur;


         Open Fetch_Lines_Cur;
	 Fetch Fetch_Lines_Cur into v_line_loc_id, v_price, v_qty, v_uom_measure;
         Close Fetch_Lines_Cur;

	 v_assessable_value := jai_cmn_setup_pkg.get_po_assessable_value( v_vendor_id, v_vendor_site_id, v_item_id, v_unit_code );


	IF v_assessable_value IS NOT NULL AND v_assessable_value > 0 THEN
          v_assessable_value := v_assessable_value * v_qty;
        ELSE
          v_assessable_value := v_qty * v_price;
        END IF;


       INSERT INTO JAI_PO_QUOT_LINES_T (
          po_header_id, po_line_id, line_location_id, from_header_id,
          from_line_id, price_override, uom_code, assessable_value,
          creation_date, created_by, last_update_date, last_updated_by, last_update_login)
        VALUES (v_po_hdr_id,v_po_line_id,v_line_loc_id,v_from_header_id,v_from_line_id,v_price,v_unit_code,
                v_assessable_value,v_cre_dt,v_cre_by,v_last_upd_dt,v_last_upd_by,v_last_upd_login);

       End IF;
   End IF; /*Added by nprashar for bug # 9362704 Ends here*/
End IF;

    IF v_type_lookup_code IN ( 'RFQ', 'QUOTATION' ,'STANDARD', 'PLANNED', 'CONTRACT', 'BLANKET' ) THEN
          v_hook_value := jai_cmn_hook_pkg.Ja_In_po_lines_all (
      P_PO_LINE_ID                      =>pr_new.PO_LINE_ID                    ,
      P_PO_HEADER_ID                    =>pr_new.PO_HEADER_ID                  ,
      P_LINE_TYPE_ID                    =>pr_new.LINE_TYPE_ID                  ,
      P_LINE_NUM                        =>pr_new.LINE_NUM                      ,
      P_ITEM_ID                         =>pr_new.ITEM_ID                       ,
      P_ITEM_REVISION                   =>pr_new.ITEM_REVISION                 ,
      P_CATEGORY_ID                     =>pr_new.CATEGORY_ID                   ,
      P_ITEM_DESCRIPTION                =>pr_new.ITEM_DESCRIPTION              ,
      P_UNIT_MEAS_LOOKUP_CODE           =>pr_new.UNIT_MEAS_LOOKUP_CODE         ,
      P_QUANTITY_COMMITTED              =>pr_new.QUANTITY_COMMITTED            ,
      P_COMMITTED_AMOUNT                =>pr_new.COMMITTED_AMOUNT              ,
      P_ALLOW_PRICE_OVERRIDE_FLAG       =>pr_new.ALLOW_PRICE_OVERRIDE_FLAG     ,
      P_NOT_TO_EXCEED_PRICE             =>pr_new.NOT_TO_EXCEED_PRICE           ,
      P_LIST_PRICE_PER_UNIT             =>pr_new.LIST_PRICE_PER_UNIT           ,
      P_UNIT_PRICE                      =>pr_new.UNIT_PRICE                    ,
      P_QUANTITY                        =>pr_new.QUANTITY                      ,
      P_UN_NUMBER_ID                    =>pr_new.UN_NUMBER_ID                  ,
      P_HAZARD_CLASS_ID                 =>pr_new.HAZARD_CLASS_ID               ,
      P_NOTE_TO_VENDOR                  =>pr_new.NOTE_TO_VENDOR                ,
      P_FROM_HEADER_ID                  =>pr_new.FROM_HEADER_ID                ,
      P_FROM_LINE_ID                    =>pr_new.FROM_LINE_ID                  ,
      P_MIN_ORDER_QUANTITY              =>pr_new.MIN_ORDER_QUANTITY            ,
      P_MAX_ORDER_QUANTITY              =>pr_new.MAX_ORDER_QUANTITY            ,
      P_QTY_RCV_TOLERANCE               =>pr_new.QTY_RCV_TOLERANCE             ,
      P_OVER_TOLERANCE_ERROR_FLAG       =>pr_new.OVER_TOLERANCE_ERROR_FLAG     ,
      P_MARKET_PRICE                    =>pr_new.MARKET_PRICE                  ,
      P_UNORDERED_FLAG                  =>pr_new.UNORDERED_FLAG                ,
      P_CLOSED_FLAG                     =>pr_new.CLOSED_FLAG                   ,
      P_USER_HOLD_FLAG                  =>pr_new.USER_HOLD_FLAG                ,
      P_CANCEL_FLAG                     =>pr_new.CANCEL_FLAG                   ,
      P_CANCELLED_BY                    =>pr_new.CANCELLED_BY                  ,
      P_CANCEL_DATE                     =>pr_new.CANCEL_DATE                   ,
      P_CANCEL_REASON                   =>pr_new.CANCEL_REASON                 ,
      P_FIRM_STATUS_LOOKUP_CODE         =>pr_new.FIRM_STATUS_LOOKUP_CODE       ,
      P_FIRM_DATE                       =>pr_new.FIRM_DATE                     ,
      P_VENDOR_PRODUCT_NUM              =>pr_new.VENDOR_PRODUCT_NUM            ,
      P_CONTRACT_NUM                    =>pr_new.CONTRACT_NUM                  ,
      P_TAXABLE_FLAG                    =>pr_new.TAXABLE_FLAG                  ,
      P_TAX_NAME                        =>pr_new.TAX_NAME                      ,
      P_TYPE_1099                       =>pr_new.TYPE_1099                     ,
      P_CAPITAL_EXPENSE_FLAG            =>pr_new.CAPITAL_EXPENSE_FLAG          ,
      P_NEGOTIATED_BY_PREPARER_FLAG     =>pr_new.NEGOTIATED_BY_PREPARER_FLAG   ,
      P_ATTRIBUTE_CATEGORY              =>pr_new.ATTRIBUTE_CATEGORY            ,
      P_ATTRIBUTE1                      =>pr_new.ATTRIBUTE1                    ,
      P_ATTRIBUTE2                      =>pr_new.ATTRIBUTE2                    ,
      P_ATTRIBUTE3                      =>pr_new.ATTRIBUTE3                    ,
      P_ATTRIBUTE4                      =>pr_new.ATTRIBUTE4                    ,
      P_ATTRIBUTE5                      =>pr_new.ATTRIBUTE5                    ,
      P_ATTRIBUTE6                      =>pr_new.ATTRIBUTE6                    ,
      P_ATTRIBUTE7                      =>pr_new.ATTRIBUTE7                    ,
      P_ATTRIBUTE8                      =>pr_new.ATTRIBUTE8                    ,
      P_ATTRIBUTE9                      =>pr_new.ATTRIBUTE9                    ,
      P_ATTRIBUTE10                     =>pr_new.ATTRIBUTE10                   ,
      P_REFERENCE_NUM                   =>pr_new.REFERENCE_NUM                 ,
      P_ATTRIBUTE11                     =>pr_new.ATTRIBUTE11                   ,
      P_ATTRIBUTE12                     =>pr_new.ATTRIBUTE12                   ,
      P_ATTRIBUTE13                     =>pr_new.ATTRIBUTE13                   ,
      P_ATTRIBUTE14                     =>pr_new.ATTRIBUTE14                   ,
      P_ATTRIBUTE15                     =>pr_new.ATTRIBUTE15                   ,
      P_MIN_RELEASE_AMOUNT              =>pr_new.MIN_RELEASE_AMOUNT            ,
      P_PRICE_TYPE_LOOKUP_CODE          =>pr_new.PRICE_TYPE_LOOKUP_CODE        ,
      P_CLOSED_CODE                     =>pr_new.CLOSED_CODE                   ,
      P_PRICE_BREAK_LOOKUP_CODE         =>pr_new.PRICE_BREAK_LOOKUP_CODE       ,
      P_USSGL_TRANSACTION_CODE          =>pr_new.USSGL_TRANSACTION_CODE        ,
      P_GOVERNMENT_CONTEXT              =>pr_new.GOVERNMENT_CONTEXT            ,
      P_REQUEST_ID                      =>pr_new.REQUEST_ID                    ,
      P_PROGRAM_APPLICATION_ID          =>pr_new.PROGRAM_APPLICATION_ID        ,
      P_PROGRAM_ID                      =>pr_new.PROGRAM_ID                    ,
      P_PROGRAM_UPDATE_DATE             =>pr_new.PROGRAM_UPDATE_DATE           ,
      P_CLOSED_DATE                     =>pr_new.CLOSED_DATE                   ,
      P_CLOSED_REASON                   =>pr_new.CLOSED_REASON                 ,
      P_CLOSED_BY                       =>pr_new.CLOSED_BY                     ,
      P_TRANSACTION_REASON_CODE         =>pr_new.TRANSACTION_REASON_CODE       ,
      P_ORG_ID                          =>pr_new.ORG_ID                        ,
      P_QC_GRADE                        =>pr_new.QC_GRADE                      ,
      P_BASE_UOM                        =>pr_new.BASE_UOM                      ,
      P_BASE_QTY                        =>pr_new.BASE_QTY                      ,
      P_SECONDARY_UOM                   =>pr_new.SECONDARY_UOM                 ,
      P_SECONDARY_QTY                   =>pr_new.SECONDARY_QTY                 ,
      P_LINE_REFERENCE_NUM              =>pr_new.LINE_REFERENCE_NUM            ,
      P_PROJECT_ID                      =>pr_new.PROJECT_ID                    ,
      P_TASK_ID                         =>pr_new.TASK_ID                       ,
      P_EXPIRATION_DATE                 =>pr_new.EXPIRATION_DATE               ,
      P_TAX_CODE_ID                     =>pr_new.TAX_CODE_ID
     );

  END IF;/*added by rchandan for bug#4479131*/

  -- End Of POC

   IF v_hook_value = 'FALSE' THEN
      RETURN;
   END IF;

  -- Get Inventory Organization Id

   OPEN  Fetch_Org_Id_Cur;
   FETCH Fetch_Org_Id_Cur INTO v_org_id;
   CLOSE Fetch_Org_Id_Cur;

  -- Continue, only if the Item is changed !

   IF pr_old.Item_id <> pr_new.Item_id  THEN

        OPEN Fetch_Lines_Cur;
        LOOP
           FETCH Fetch_Lines_Cur INTO v_line_loc_id, v_price, v_qty, v_uom_measure;
           EXIT WHEN Fetch_Lines_Cur%NOTFOUND;

           IF v_type_lookup_code  NOT IN ( 'RFQ', 'QUOTATION' ) THEN
              v_price := v_n_price;
           END IF;

           OPEN Fetch_Flag_Cur( v_line_loc_id );
           LOOP
              FETCH Fetch_Flag_Cur INTO v_t_flag;
              EXIT WHEN Fetch_Flag_Cur%NOTFOUND;
              IF UPPER( v_t_flag ) = 'N' THEN

                 DELETE FROM JAI_PO_TAXES
                 WHERE Line_Location_Id = v_line_loc_id;

              jai_po_cmn_pkg.insert_line( 'CATALOG',
                              v_line_loc_id,
                              v_po_hdr_id,
                              v_po_line_id,
                              v_cre_dt,
                              v_cre_by,
                              v_last_upd_dt,
                              v_last_upd_by,
                              v_last_upd_login,
                              'U' );

                  jai_po_tax_pkg.Ja_In_Po_Case1(  v_type_lookup_code,
                                                          v_quot_class_code,
                                                          v_vendor_id,
                                                          v_vendor_site_id,
                                                          v_curr,
                                                          v_org_id,
                                                          v_item_id,
                                                          v_line_uom,
                                                          v_line_loc_id,
                                                          v_po_hdr_id,
                                                          v_po_line_id,
                                                          v_po_line_id,
                                                          v_line_loc_id,
                                                          v_price,
                                                          v_Qty,
                                                          v_cre_dt,
                                                          v_cre_by,
                                                          v_last_upd_dt,
                                                          v_last_upd_by,
                                                          v_last_upd_login,
                                                          'U',
                                                          success );
              END IF;

              IF ( success <> 0 OR v_t_flag = 'Y' ) THEN

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
                                                           v_Qty,
                                                           v_cre_dt,
                                                           v_cre_by,
                                                           v_last_upd_dt,
                                                           v_last_upd_by,
                                                           v_last_upd_login,
                                                           v_uom_measure,
                                                           NULL,
                                                          P_VAT_ASSESS_VALUE => NULL /* Added p_vat_assess_value by rallamse bug#4250072  VAT */
                                                          );
              END IF;
           END LOOP;
           CLOSE Fetch_Flag_Cur;
        END LOOP;
       CLOSE Fetch_Lines_Cur;
   END IF;
  END ARU_T1 ;

END JAI_PO_LA_TRIGGER_PKG ;

/
