--------------------------------------------------------
--  DDL for Package Body JAI_PO_RLA_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_PO_RLA_TRIGGER_PKG" AS
/* $Header: jai_po_rla_t.plb 120.12.12010000.6 2009/08/26 08:29:45 bgowrava ship $ */

/*
  REM +======================================================================+
  REM NAME          ARI_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_PO_RLA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_PO_RLA_ARI_T2
  REM
  REM +======================================================================+
*/
  PROCEDURE ARI_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
	--Blanket/Quotation Defaulting Logic

  v_type_lookup_code      VARCHAR2(25);
  FOUND                   BOOLEAN;
  --v_rowid                 ROWID;--File.Sql.35 Cbabu      :=  pr_new.ROWID;
  v_blanket_hdr           NUMBER;--File.Sql.35 Cbabu     :=  pr_new.BLANKET_PO_HEADER_ID;
  v_blanket_line          NUMBER;--File.Sql.35 Cbabu     :=  pr_new.BLANKET_PO_LINE_NUM;
  v_set_books             VARCHAR2(1996);
  v_gl_set_of_bks_id      NUMBER;
  v_dest_org_id           NUMBER;--File.Sql.35 Cbabu     :=  pr_new.Destination_Organization_Id;
  v_src_org_id            NUMBER;--File.Sql.35 Cbabu     :=  pr_new.Source_Organization_Id;
  v_org_id                NUMBER;--File.Sql.35 Cbabu     :=  0;
  v_vendor_id             NUMBER;
  v_site_id               NUMBER;
  v_seg_id                VARCHAR2(20);
  v_uom_code              VARCHAR2(3);
  v_RATE_TYPE             VARCHAR2(30);--File.Sql.35 Cbabu   :=  pr_new.Rate_Type;
  v_RATE_DATE             DATE;--File.Sql.35 Cbabu       :=  pr_new.Rate_Date;
  v_RATE                  NUMBER;--File.Sql.35 Cbabu     :=  pr_new.Rate;
  v_hdr_currency          VARCHAR2(15);
  v_currency              VARCHAR2(15);--File.Sql.35 Cbabu   :=  pr_new.Currency_Code;
  v_requisition_header_id NUMBER ;--File.Sql.35 Cbabu    :=  pr_new.Requisition_Header_Id;
  v_requisition_line_id   NUMBER;--File.Sql.35 Cbabu     :=  pr_new.Requisition_Line_Id;
  v_po_line_id            NUMBER;
  v_line_quantity         NUMBER;--File.Sql.35 Cbabu     :=  pr_new.quantity;
  v_qty                   NUMBER;
  v_unit_price            NUMBER;--File.Sql.35 Cbabu     :=  pr_new.Unit_Price;
  v_inventory_item_id     NUMBER;--File.Sql.35 Cbabu     :=  pr_new.item_id;
  v_sugg_vendor_name      VARCHAR2(360);--File.Sql.35 Cbabu   :=  pr_new.suggested_vendor_name; --Increased the  length 80 to 360 by JMEENA for bug#5394234
  v_sugg_vendor_loc       VARCHAR2(360);--File.Sql.35 Cbabu   :=  pr_new.suggested_vendor_location; --Increased the  length 80 to 360 by JMEENA for bug#5394234
  v_line_amount           NUMBER ;--File.Sql.35 Cbabu    :=  NVL( (pr_new.quantity * pr_new.unit_price) ,0);
  v_tax_category_id       NUMBER;
  v_line_location_id      NUMBER;
  v_tax_amount            NUMBER;
  v_line_total            NUMBER;
  v_total_amount          NUMBER;
  v_creation_date         DATE ;--File.Sql.35 Cbabu      :=  pr_new.Creation_Date;
  v_created_by            NUMBER ;--File.Sql.35 Cbabu    :=  pr_new.Created_By;
  v_last_update_date      DATE ;--File.Sql.35 Cbabu      :=  pr_new.Last_Update_Date;
  v_last_updated_by       NUMBER;--File.Sql.35 Cbabu     :=  pr_new.Last_Updated_By;
  v_last_update_login     NUMBER ;--File.Sql.35 Cbabu    :=  pr_new.Last_Update_Login;
  v_modified_by_agent_flag      po_requisition_lines_all.modified_by_agent_flag%type  := pr_new.modified_by_agent_flag; /*Added for Bug 8241905*/
  v_parent_req_line_id          po_requisition_lines_all.parent_req_line_id%type      := pr_new.parent_req_line_id; /*Added for Bug 8241905*/
  conv_rate               NUMBER;
  p_tax_amount            NUMBER;
  v_assessable_value      NUMBER;
  ln_vat_assess_value     NUMBER;    -- Ravi for VAT

  v_tax_category_id_holder JAI_PO_LINE_LOCATIONS.tax_category_id%TYPE;    -- cbabu for EnhancementBug# 2427465

  CURSOR Fetch_Org_Id_Cur IS
  SELECT NVL(Operating_Unit,0)
    FROM   Org_Organization_Definitions
   WHERE  Organization_Id = v_dest_org_id;

  CURSOR org_cur IS
  SELECT A.Segment1, A.Type_Lookup_Code,apps_source_code--added apps_source_code by rchandan for bug#4627239
    FROM   Po_Requisition_Headers_All A
   WHERE  A.Requisition_Header_Id = v_requisition_header_id;

  /* Bug 5243532. Addd by Lakshmi Gopalsami
   * Removed the cursor Fetch_Book_Id_Cur
   * and implemented the same using caching logic.
   */
  CURSOR vend_cur(p_sugg_vendor_name IN VARCHAR2) IS
  SELECT Vendor_Id
    FROM   Po_Vendors
   WHERE  Vendor_Name = p_sugg_vendor_name;

  CURSOR site_cur(p_sugg_vendor_loc IN VARCHAR2) IS
  SELECT Vendor_Site_Id
    FROM   Po_Vendor_Sites_All A
   WHERE  A.Vendor_Site_Code = p_sugg_vendor_loc
     AND    A.Vendor_Id        = v_vendor_id
     AND    (A.Org_Id  = v_org_id
               OR
      (A.Org_Id  is NULL AND  v_org_id is NULL)) ;  /* Modified by Ramananda for removal of SQL LITERALs */
     --AND    NVL(A.Org_Id,0)           = NVL(v_org_id,0);

  --pramasub commented FP start
  /*CURSOR location_cur(p_blanket_hdr IN NUMBER, p_blanket_line NUMBER) IS
  SELECT Line_Location_Id, Quantity, Price_Override*/
 /*4281841 start*/
 CURSOR cur_bpa_unit_measure(p_blanket_hdr IN NUMBER, p_blanket_line NUMBER) IS
 SELECT unit_meas_lookup_code
  FROM   Po_Line_Locations_All
  WHERE  Po_Line_Id IN (SELECT Po_Line_Id
                           FROM Po_Lines_All
                          WHERE Po_Header_Id = p_blanket_hdr
                            AND Line_Num     = p_blanket_line);
  lv_unit_meas_lookup   po_line_locations_all.unit_meas_lookup_code%TYPE;

/*4281841 end*/ --pramasub FP end

-- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
--pramasub commented for FP strt
  /*CURSOR tax_cur(p_line_location_id IN NUMBER) IS
  SELECT a.Po_Line_Id, a.tax_line_no lno, a.tax_id,
         a.precedence_1 p_1, a.precedence_2 p_2, a.precedence_3 p_3,a.precedence_4 p_4, a.precedence_5 p_5,
         a.precedence_6 p_6, a.precedence_7 p_7, a.precedence_8 p_8,a.precedence_9 p_9, a.precedence_10 p_10,
	 a.currency, a.tax_rate, a.qty_rate, a.uom, a.tax_amount, a.tax_type,
         a.vendor_id, a.modvat_flag,
         tax_category_id     -- cbabu for EnhancementBug# 2427465
    FROM JAI_PO_TAXES a
   WHERE a.line_location_id = p_line_location_id
   ORDER BY  a.tax_line_no;

-- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
  CURSOR tax1_cur IS
  SELECT a.Po_Line_Id, a.tax_line_no lno, a.tax_id,
         a.precedence_1 p_1, a.precedence_2 p_2, a.precedence_3 p_3, a.precedence_4 p_4, a.precedence_5 p_5,
         a.precedence_6 p_6, a.precedence_7 p_7, a.precedence_8 p_8, a.precedence_9 p_9, a.precedence_10 p_10,
	 a.currency, a.tax_rate, a.qty_rate, a.uom, a.tax_amount, a.tax_type,
         a.vendor_id, a.modvat_flag,
         tax_category_id     -- cbabu for EnhancementBug# 2427465
    FROM JAI_PO_TAXES a
   WHERE a.po_line_id = v_po_line_id
     AND Line_Location_Id IS NULL
   ORDER BY  a.tax_line_no;*/
--pramasub commented for FP end
  CURSOR cur_bpa_tax_lines(p_po_line_id IN NUMBER,p_line_location_id IN NUMBER) IS
	SELECT a.Po_Line_Id,
	a.tax_line_no lno  ,
	a.tax_id           ,
	a.precedence_1  p_1,
	a.precedence_2  p_2,
	a.precedence_3  p_3,
	a.precedence_4  p_4,
	a.precedence_5  p_5,
	a.precedence_6  p_6,
	a.precedence_7  p_7,
	a.precedence_8  p_8,
	a.precedence_9  p_9,
	a.precedence_10 p_10,
	a.currency          ,
	a.tax_rate          ,
	a.qty_rate          ,
	a.uom               ,
	a.tax_amount        ,
	a.tax_type          ,
	a.vendor_id         ,
	a.modvat_flag       ,
	tax_category_id     -- cbabu for EnhancementBug# 2427465
  FROM JAI_PO_TAXES a --Ja_In_Po_Line_Location_Taxes a
  WHERE po_line_id = p_po_line_id
  AND nvl(line_location_id,-999) = p_line_location_id
  ORDER BY  a.tax_line_no; --new cursor added by pramasub for FP

  CURSOR Fetch_Hdr_Curr_Cur IS
  SELECT NVL( Currency_Code, '$' )
    FROM Po_Requisition_Headers_V
   WHERE Requisition_Header_Id = v_requisition_header_id;

  --CURSOR Fetch_Uom_Code_Cur IS pramasub FP start
  CURSOR Fetch_Uom_Code_Cur(cp_unit_of_meas VARCHAR2) IS /*4281841*/
  SELECT Uom_Code
    FROM Mtl_Units_Of_Measure
   WHERE Unit_Of_Measure = cp_unit_of_meas;
   --WHERE Unit_Of_Measure = v_uom_code; pramasub start

  -- additions by sriram - starts here Bug # 2977200

  CURSOR c_reqn_line_id(p_reqn_line_id Number) is
  SELECT 1
    FROM JAI_PO_REQ_LINE_TAXES
   WHERE requisition_line_id = p_reqn_line_id;

  v_reqn_ctr  Number :=0;

  -- additions by sriram - ends  here  Bug # 2977200
  lv_apps_source_code po_requisition_headers_all.apps_source_code%type; -- added by rchandan for bug#462739
	/*5852041..start */ -- pramasub start
   ln_tax_amount        NUMBER;
   ln_program_id        NUMBER;

   CURSOR c_program_id
	   IS
   SELECT concurrent_program_id
		   FROM fnd_concurrent_programs_vl
		  WHERE concurrent_program_name ='REQIMPORT'
	  AND application_id = 201;

   /*5852041..start */  -- pramasub end
      --pramasub 6066485 start
   cursor c_fetch_sob_from_hrou(cp_org_id in number)
	is
	select set_of_books_id
	from hr_operating_units
	Where organization_id = cp_org_id;
	v_new_org_id  NUMBER;
	v_sob_hrou_id NUMBER;
   --pramasub 6066485 end


   v_hook_value              VARCHAR2(10) ;

  /* Bug 5243532. Added by Lakshmi Gopalsami
   * Defined variable for implementing caching logic.
   */
  l_func_curr_det jai_plsql_cache_pkg.func_curr_details;
  -- End for bug 5243532

  BEGIN
    pv_return_code := jai_constants.successful ;
    /*-----------------------------------------------------------------------------------------------------------------------
CHANGE HISTORY:   FILENAME: ja_in_reqn_tax_insert_trg.sql
S.No   Date       Author and Details
-------------------------------------------------------------------------------------------------------------------------
1  06/12/2002         cbabu for EnhancementBug# 2427465, FileVersion# 615.1
                      tax_category_id column is populated into PO and SO localization tables, which will be used to
                      identify from which tax_category the taxes are defaulted. Also the tax_category_id populated into
                      the  tax table will be useful to identify whether the tax is a defaulted or a manual tax.

2. 26/05/2003         sriram - Bug # 2977200

                      A check has been added to ensure that the insert into JAI_PO_REQ_LINE_TAXES
                      should happen only when the  requisition line  id
                      does not exist in the JAI_PO_REQ_LINE_TAXES table.
                      This check has been added at 2 places , before insert into JAI_PO_REQ_LINE_TAXES

3  21/10/2003         Vijay Shankar for Bug# 3207886, FileVersion# 616.2
                      Taxes are not getting defaulted from ITEM_CLASS and TAX_CATEGORY setup if Supplier information is not provided
                      requisition line. The issue occured because jai_cmn_tax_defaultation_pkg.ja_in_vendor_default_taxes accepts the Inventory
                      organization id as first argument, but we are passing Operating Unit Id as first parameter. Fixed the issue
                      by passing Destination Organization as parameter.

4. 30/11/2005         Aparajita for bug#4036241. Version#115.1

                      Introduced the call to centralized packaged procedure,
                      jai_cmn_utils_pkg.check_jai_exists to check if localization has been installed.

5.   17/mar-2005     Rchandan for bug#4245365   Version#115.3
                     Changes made to calculate VAT assessable value . This vat assessable is passed
                     to the procedure that calculates the VAT related taxes

6.   08-Jun-2005     This Object is Modified to refer to New DB Entry names in place of Old
                     DB as required for CASE COMPLAINCE. Version 116.1

7. 13-Jun-2005    File Version: 116.2
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done

8  06-Jul-2005    rallamse for bug#4479131 PADDR Elimination
                  1. Replaced call to jai_po_cmn_pkg.query_locator_for_line with
                     jai_cmn_hook_pkg.Po_Requisition_Lines_All


9. 03/11/2006    SACSETHI for Bug 5228046, File version 120.4
	         Forward porting the change in 11i bug 5365523  (Additional CVD Enhancement, Tax precedence, BOE).


10. 17-APR-2007   Bgowrava for forward porting bug#5989740, 11i Bug#5907436 , File version 120.5
                  Changes added for Handling secondary and Higher Secondary Education Cess

		 This bug has datamodel and spec changes.

11  15-JUN-2007   ssawant   for bug 6134111
		The Taxes are defaulted from the Req to PO but the the Tax Category name
		it not visible. Hence tax_category_id = v_tax_category_id_holder clause was added
		in update table query.

12. 07-Nov-2008 JMEENA for bug#5394234
		Increased the length of variables v_sugg_vendor_name and v_sugg_vendor_loc from 80 to 360

13  31-JUL-2009   Bug 8711805
                  Uom_Code was fetched from mtl_units_of_measure using a Query instead of cursor
                  Hence when unit_of_measure is NULL in case of 'Fixed Price Services' Line Type
                  (Set in Profile option 'POR : Amount Based Services Line Type') NO_DATA_FOUND
                  error is thrown.
Dependency:
----------

Sl No. Bug        Dependent on
                  Bug/Patch set    Details
-------------------------------------------------------------------------------------------------
1      4036241    4033992          Call to  jai_cmn_utils_pkg.check_jai_exists, whcih was created thru bug
                                   4033992.
                                   ja_in_util_pkg_s.sql 115.0
                                   ja_in_util_pkg_b.sql 115.0

2.     4245365    4245089          VAT implementation

--------------------------------------------------------------------------------------------*/

--File.Sql.35 Cbabu
--v_rowid                   :=  pr_new.ROWID;
v_blanket_hdr             :=  pr_new.BLANKET_PO_HEADER_ID;
v_blanket_line            :=  pr_new.BLANKET_PO_LINE_NUM;
v_dest_org_id             :=  pr_new.Destination_Organization_Id;
v_src_org_id              :=  pr_new.Source_Organization_Id;
v_org_id                  :=  0;
v_RATE_TYPE               :=  pr_new.Rate_Type;
v_RATE_DATE               :=  pr_new.Rate_Date;
v_RATE                    :=  pr_new.Rate;
v_currency                :=  pr_new.Currency_Code;
v_requisition_header_id   :=  pr_new.Requisition_Header_Id;
v_requisition_line_id     :=  pr_new.Requisition_Line_Id;
v_line_quantity           :=  pr_new.quantity;
v_unit_price              :=  pr_new.Unit_Price;
v_inventory_item_id       :=  pr_new.item_id;
v_sugg_vendor_name        :=  pr_new.suggested_vendor_name;
v_sugg_vendor_loc         :=  pr_new.suggested_vendor_location;
v_line_amount             :=  NVL( (pr_new.quantity * pr_new.unit_price) ,0);
v_creation_date           :=  pr_new.Creation_Date;
v_created_by              :=  pr_new.Created_By;
v_last_update_date        :=  pr_new.Last_Update_Date;
v_last_updated_by         :=  pr_new.Last_Updated_By;
v_last_update_login       :=  pr_new.Last_Update_Login;
v_reqn_ctr                :=0;
v_new_org_id                 :=  pr_new.ORG_ID; --pramasub 6066485

--if
--  jai_cmn_utils_pkg.check_jai_exists (p_calling_object   => 'JA_IN_REQN_TAX_INSERT_TRG',
--                               p_org_id           =>  pr_new.org_id)

--  =
--  FALSE
-- then
  /* India Localization funtionality is not required */
--  return;
-- end if;

	OPEN  org_cur;  --rchandan for bug#462739 moved the cursor call here as apps_source_code was added in the cursor
	FETCH Org_Cur INTO v_seg_id, v_type_lookup_code,lv_apps_source_code;
	CLOSE org_cur;

 /* added by rchandan for bug#4627239 start*/

 /*IF nvl(lv_apps_source_code,'xyz') = 'POR' THEN
   return;
		 --India Localization does not support iProcurement
 END IF ;*/
 /*
 	   || ssumaith - eliminated code to stop iprocurement Requisitions from being created.
*/
 /* added by rchandan for bug#4627239 end*/

-- jai_po_cmn_pkg.query_locator_for_line( v_requisition_header_id, 'JAINREQN', FOUND );
v_hook_value          := 'TRUE';
/* If v_hook_value is TRUE, then it means taxes should be defaulted. IF FALSE then return */
v_hook_value := jai_cmn_hook_pkg.Po_Requisition_Lines_All
                (
                  pr_new.REQUISITION_LINE_ID,
                  pr_new.REQUISITION_HEADER_ID,
                  pr_new.LINE_NUM,
                  pr_new.LINE_TYPE_ID,
                  pr_new.CATEGORY_ID,
                  pr_new.ITEM_DESCRIPTION,
                  pr_new.UNIT_MEAS_LOOKUP_CODE,
                  pr_new.UNIT_PRICE,
                  pr_new.QUANTITY,
                  pr_new.DELIVER_TO_LOCATION_ID,
                  pr_new.TO_PERSON_ID,
                  pr_new.LAST_UPDATE_DATE,
                  pr_new.LAST_UPDATED_BY,
                  pr_new.SOURCE_TYPE_CODE,
                  pr_new.LAST_UPDATE_LOGIN,
                  pr_new.CREATION_DATE,
                  pr_new.CREATED_BY,
                  pr_new.ITEM_ID,
                  pr_new.ITEM_REVISION,
                  pr_new.QUANTITY_DELIVERED,
                  pr_new.SUGGESTED_BUYER_ID,
                  pr_new.ENCUMBERED_FLAG,
                  pr_new.RFQ_REQUIRED_FLAG,
                  pr_new.NEED_BY_DATE,
                  pr_new.LINE_LOCATION_ID,
                  pr_new.MODIFIED_BY_AGENT_FLAG,
                  pr_new.PARENT_REQ_LINE_ID,
                  pr_new.JUSTIFICATION,
                  pr_new.NOTE_TO_AGENT,
                  pr_new.NOTE_TO_RECEIVER,
                  pr_new.PURCHASING_AGENT_ID,
                  pr_new.DOCUMENT_TYPE_CODE,
                  pr_new.BLANKET_PO_HEADER_ID,
                  pr_new.BLANKET_PO_LINE_NUM,
                  pr_new.CURRENCY_CODE,
                  pr_new.RATE_TYPE,
                  pr_new.RATE_DATE,
                  pr_new.RATE,
                  pr_new.CURRENCY_UNIT_PRICE,
                  pr_new.SUGGESTED_VENDOR_NAME,
                  pr_new.SUGGESTED_VENDOR_LOCATION,
                  pr_new.SUGGESTED_VENDOR_CONTACT,
                  pr_new.SUGGESTED_VENDOR_PHONE,
                  pr_new.SUGGESTED_VENDOR_PRODUCT_CODE,
                  pr_new.UN_NUMBER_ID,
                  pr_new.HAZARD_CLASS_ID,
                  pr_new.MUST_USE_SUGG_VENDOR_FLAG,
                  pr_new.REFERENCE_NUM,
                  pr_new.ON_RFQ_FLAG,
                  pr_new.URGENT_FLAG,
                  pr_new.CANCEL_FLAG,
                  pr_new.SOURCE_ORGANIZATION_ID,
                  pr_new.SOURCE_SUBINVENTORY,
                  pr_new.DESTINATION_TYPE_CODE,
                  pr_new.DESTINATION_ORGANIZATION_ID,
                  pr_new.DESTINATION_SUBINVENTORY,
                  pr_new.QUANTITY_CANCELLED,
                  pr_new.CANCEL_DATE,
                  pr_new.CANCEL_REASON,
                  pr_new.CLOSED_CODE,
                  pr_new.AGENT_RETURN_NOTE,
                  pr_new.CHANGED_AFTER_RESEARCH_FLAG,
                  pr_new.VENDOR_ID,
                  pr_new.VENDOR_SITE_ID,
                  pr_new.VENDOR_CONTACT_ID,
                  pr_new.RESEARCH_AGENT_ID,
                  pr_new.ON_LINE_FLAG,
                  pr_new.WIP_ENTITY_ID,
                  pr_new.WIP_LINE_ID,
                  pr_new.WIP_REPETITIVE_SCHEDULE_ID,
                  pr_new.WIP_OPERATION_SEQ_NUM,
                  pr_new.WIP_RESOURCE_SEQ_NUM,
                  pr_new.ATTRIBUTE_CATEGORY,
                  pr_new.DESTINATION_CONTEXT,
                  pr_new.INVENTORY_SOURCE_CONTEXT,
                  pr_new.VENDOR_SOURCE_CONTEXT,
                  pr_new.ATTRIBUTE1,
                  pr_new.ATTRIBUTE2,
                  pr_new.ATTRIBUTE3,
                  pr_new.ATTRIBUTE4,
                  pr_new.ATTRIBUTE5,
                  pr_new.ATTRIBUTE6,
                  pr_new.ATTRIBUTE7,
                  pr_new.ATTRIBUTE8,
                  pr_new.ATTRIBUTE9,
                  pr_new.ATTRIBUTE10,
                  pr_new.ATTRIBUTE11,
                  pr_new.ATTRIBUTE12,
                  pr_new.ATTRIBUTE13,
                  pr_new.ATTRIBUTE14,
                  pr_new.ATTRIBUTE15,
                  pr_new.BOM_RESOURCE_ID,
                  pr_new.CLOSED_REASON,
                  pr_new.CLOSED_DATE,
                  pr_new.TRANSACTION_REASON_CODE,
                  pr_new.QUANTITY_RECEIVED,
                  pr_new.SOURCE_REQ_LINE_ID,
                  pr_new.ORG_ID,
                  pr_new.KANBAN_CARD_ID,
                  pr_new.CATALOG_TYPE,
                  pr_new.CATALOG_SOURCE,
                  pr_new.MANUFACTURER_ID,
                  pr_new.MANUFACTURER_NAME,
                  pr_new.MANUFACTURER_PART_NUMBER,
                  pr_new.REQUESTER_EMAIL,
                  pr_new.REQUESTER_FAX,
                  pr_new.REQUESTER_PHONE,
                  pr_new.UNSPSC_CODE,
                  pr_new.OTHER_CATEGORY_CODE,
                  pr_new.SUPPLIER_DUNS,
                  pr_new.TAX_STATUS_INDICATOR,
                  pr_new.PCARD_FLAG,
                  pr_new.NEW_SUPPLIER_FLAG,
                  pr_new.AUTO_RECEIVE_FLAG,
                  pr_new.TAX_USER_OVERRIDE_FLAG,
                  pr_new.TAX_CODE_ID,
                  pr_new.NOTE_TO_VENDOR,
                  pr_new.OKE_CONTRACT_VERSION_ID,
                  pr_new.OKE_CONTRACT_HEADER_ID,
                  pr_new.ITEM_SOURCE_ID,
                  pr_new.SUPPLIER_REF_NUMBER,
                  pr_new.SECONDARY_UNIT_OF_MEASURE,
                  pr_new.SECONDARY_QUANTITY,
                  pr_new.PREFERRED_GRADE,
                  pr_new.SECONDARY_QUANTITY_RECEIVED,
                  pr_new.SECONDARY_QUANTITY_CANCELLED,
                  pr_new.VMI_FLAG,
                  pr_new.AUCTION_HEADER_ID,
                  pr_new.AUCTION_DISPLAY_NUMBER,
                  pr_new.AUCTION_LINE_NUMBER,
                  pr_new.REQS_IN_POOL_FLAG,
                  pr_new.BID_NUMBER,
                  pr_new.BID_LINE_NUMBER,
                  pr_new.NONCAT_TEMPLATE_ID,
                  pr_new.SUGGESTED_VENDOR_CONTACT_FAX,
                  pr_new.SUGGESTED_VENDOR_CONTACT_EMAIL,
                  pr_new.AMOUNT,
                  pr_new.CURRENCY_AMOUNT,
                  pr_new.LABOR_REQ_LINE_ID,
                  pr_new.JOB_ID,
                  pr_new.JOB_LONG_DESCRIPTION,
                  pr_new.CONTRACTOR_STATUS,
                  pr_new.CONTACT_INFORMATION,
                  pr_new.SUGGESTED_SUPPLIER_FLAG,
                  pr_new.CANDIDATE_SCREENING_REQD_FLAG,
                  pr_new.CANDIDATE_FIRST_NAME,
                  pr_new.CANDIDATE_LAST_NAME,
                  pr_new.ASSIGNMENT_END_DATE,
                  pr_new.OVERTIME_ALLOWED_FLAG,
                  pr_new.CONTRACTOR_REQUISITION_FLAG,
                  pr_new.DROP_SHIP_FLAG,
                  pr_new.ASSIGNMENT_START_DATE,
                  pr_new.ORDER_TYPE_LOOKUP_CODE,
                  pr_new.PURCHASE_BASIS,
                  pr_new.MATCHING_BASIS,
                  pr_new.NEGOTIATED_BY_PREPARER_FLAG,
                  pr_new.SHIP_METHOD,
                  pr_new.ESTIMATED_PICKUP_DATE,
                  pr_new.SUPPLIER_NOTIFIED_FOR_CANCEL,
                  pr_new.BASE_UNIT_PRICE,
                  pr_new.AT_SOURCING_FLAG,
      /* Bug 4535701. Added by Lakshmi Gopalsami
       * Passing event_id and line_number as null
       * for build issue */
       /* Bug4540709. Added by Lakshmig Gopalsami
	* Reverting the fix for bug 4535701 */
                 /*  pr_new.EVENT_ID,
                  pr_new.LINE_NUMBER*/ -- the above two lines commented by ssumaith - bug#4616729
                  NULL, /* the following two nulls are added by ssumaith because these two columns are not present in the table po_requisition_lines_all at this time */
                  NULL
                ) ;

--This change is done By Nagaraj.s for Bug#2381124
--Change done : The Program id of Requisition Import Program is 32353. If the
-- Requisition is created through Requisition Import program then the trigger should
-- be executed without checking for the Localization Form Session Id.
	 -- pramasub start
	 OPEN c_program_id;
 	 FETCH c_program_id INTO ln_program_id;
 	 CLOSE c_program_id;
	 -- pramasub end

IF pr_new.PROGRAM_ID <> ln_program_id  AND nvl(lv_apps_source_code,'$$') <> 'POR' THEN
/*rchandan for bug#5852041..replaced 32353 with ln_program_id and OR with AND*/ -- pramasub FP
  --IF NOT FOUND THEN
   IF v_hook_value = 'FALSE' THEN
     RETURN;
  END IF;
END IF;

  OPEN  Fetch_Org_Id_Cur;
  FETCH Fetch_Org_Id_Cur INTO v_org_id;
  CLOSE Fetch_Org_Id_Cur;

  /*OPEN  org_cur; commeneted by pramasub for FP
  FETCH Org_Cur INTO v_seg_id, v_type_lookup_code;
  CLOSE org_cur;*/

  /* Bug 5243532. Added by Lakshmi Gopalsami
   * Removed the cursor Fetch_Book_Id_Cur
   * and implemented using caching logic.
   */

  l_func_curr_det       := jai_plsql_cache_pkg.return_sob_curr
                            (p_org_id  => v_dest_org_id );
  v_gl_set_of_bks_id    := l_func_curr_det.ledger_id;

  -- Start, cbabu for EnhancementBug# 2427465
  INSERT INTO JAI_PO_REQ_LINES (
    requisition_line_id, requisition_header_id, tax_modified_flag,
    tax_amount, total_amount,
    creation_date, created_by, last_update_date,
    last_updated_by, last_update_login
  ) VALUES (
    v_requisition_line_id,  v_requisition_header_id,  'N',
    NULL, NULL,
    v_creation_date, v_created_by, v_last_update_date,
    v_last_updated_by, v_last_update_login
  );
  -- End, cbabu for EnhancementBug# 2427465

  OPEN  Fetch_Hdr_Curr_Cur;
  FETCH Fetch_Hdr_Curr_Cur INTO v_hdr_currency;
  CLOSE Fetch_Hdr_Curr_Cur;

  OPEN  vend_cur(v_sugg_vendor_name);
  FETCH Vend_Cur INTO v_vendor_id;
  CLOSE vend_cur;

  OPEN  site_cur(v_sugg_vendor_loc);
  FETCH Site_Cur INTO v_site_id;
  CLOSE site_cur;

  /*Added for Bug 8711805 - Start*/
  OPEN Fetch_Uom_Code_Cur(pr_new.Unit_Meas_Lookup_Code);
  FETCH Fetch_Uom_Code_Cur INTO v_uom_code;
  CLOSE Fetch_Uom_Code_Cur;
  /*Added for Bug 8711805 - End*/
  /*
  SELECT Uom_Code
  INTO v_uom_code
  FROM Mtl_Units_of_Measure
  WHERE Unit_Of_Measure = pr_new.Unit_Meas_Lookup_Code;
  */

  v_assessable_value := jai_cmn_setup_pkg.get_po_assessable_value( v_vendor_id, v_site_id,
                  v_inventory_item_id, v_uom_code );



  -- insert into xc values( ' vendor id ' || to_char( v_vendor_id ) || ' vendor site ' || to_char( v_site_id ) || ' item id ' || to_char( v_inventory_item_id ) || ' uom ' || v_uom_code );


   v_currency := NVL( v_currency, v_hdr_currency );

   -- pramasub start 6066485
	open c_fetch_sob_from_hrou(v_new_org_id);
	Fetch c_fetch_sob_from_hrou into v_sob_hrou_id;
	close c_fetch_sob_from_hrou;
-- pramasub end 6066485

 --IF v_currency = v_hdr_currency THEN commented by pramasub on FP
 IF NVL(v_currency,'$$') = NVL(v_hdr_currency,'$$') THEN -- inserted by pramasub on FP
    conv_rate := 1;
 ELSE
    IF v_rate_type = 'User' THEN
       conv_rate := 1/v_rate;
    ELSE
        --conv_rate := 1/jai_cmn_utils_pkg.currency_conversion( v_gl_set_of_bks_id, v_currency, v_rate_date, v_rate_type, v_rate ); pramasub 6066485
       conv_rate := 1/jai_cmn_utils_pkg.currency_conversion( v_sob_hrou_id, v_currency, v_rate_date, v_rate_type, v_rate );
    END IF;
 END IF;

  v_line_amount := v_line_amount * conv_rate;

  ln_vat_assess_value :=  jai_general_pkg.ja_in_vat_assessable_value
                                               ( p_party_id => v_vendor_id,
                                                 p_party_site_id => v_site_id,
                                                 p_inventory_item_id => v_inventory_item_id,
                                                 p_uom_code => v_uom_code,
                                                 p_default_price => 0,
                                                 p_ass_value_date => SYSDATE,
                                                 p_party_type => 'V'
                                              ) ;     -- Ravi for VAT

  IF NVL( v_assessable_value, 0 ) <= 0 THEN
     v_assessable_value := v_line_amount;
  ELSE
     v_assessable_value := v_assessable_value * v_line_quantity * conv_rate;
  END IF;

  IF ln_vat_assess_value = 0 THEN     -- Ravi for VAT
     ln_vat_assess_value := v_line_amount;
  ELSE
     ln_vat_assess_value := ln_vat_assess_value * v_line_quantity * conv_rate;
  END IF;

  -- insert into xc values( ' av ' || to_char( v_assessable_value ) );
  --pramasub start FP
  -- Following IF condition added by skjayaba for internal QA issue. Tax currency coming as NULL for Requisitions.
	IF (lv_apps_source_code = 'POR' AND  v_currency is NULL) THEN
		v_currency := 'INR';
 	END IF;
  --pramasub end FP
  IF v_blanket_hdr IS NOT NULL AND v_blanket_line IS NOT NULL THEN

     jai_po_cmn_pkg.locate_source_line( v_blanket_hdr, v_blanket_line, v_line_quantity, v_po_line_id, v_line_location_id );

     /*IF v_line_location_id = -999 THEN --pramasub commented FP
        -- code added by sriram to ensure that we do not have a duplicate requisition line_id
        -- checking if the requisition line id is already created or not
        -- Bug # 2977200*/

        open  c_reqn_line_id(v_requisition_line_id);
        fetch c_reqn_line_id into v_reqn_ctr;
        close c_reqn_line_id;

        if nvl(v_reqn_ctr,0) = 0  then

        -- ends here additions by sriram -- Bug # 2977200
           --FOR rec IN  tax1_cur LOOP
		   FOR rec IN  cur_bpa_tax_lines(v_po_line_id, v_line_location_id ) LOOP /*rchandan for bug#5852041*/ --pramasub FP
               v_po_line_id := Rec.Po_Line_Id;


-- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
      INSERT INTO JAI_PO_REQ_LINE_TAXES(
        requisition_line_id, requisition_header_id, tax_line_no,
        precedence_1, precedence_2, precedence_3, precedence_4, precedence_5,
	precedence_6, precedence_7, precedence_8, precedence_9, precedence_10,
	tax_id, tax_rate, qty_rate, uom, tax_amount, tax_target_amount,
        tax_type, modvat_flag, vendor_id, currency,
        creation_date, created_by, last_update_date, last_updated_by, last_update_login,
        tax_category_id       -- cbabu for EnhancementBug# 2427465
      ) VALUES (
        v_requisition_line_id, v_requisition_header_id, rec.lno,
        rec.p_1, rec.p_2, rec.p_3, rec.p_4, rec.p_5,
        rec.p_6, rec.p_7, rec.p_8, rec.p_9, rec.p_10,
        rec.tax_id, rec.tax_rate, rec.qty_rate, rec.uom, rec.tax_amount, rec.tax_amount + v_line_amount,
        rec.tax_type, rec.modvat_flag, rec.vendor_id, rec.currency,
        v_creation_date, v_created_by, v_last_update_date, v_last_updated_by, v_last_update_login,
        rec.tax_category_id     -- cbabu for EnhancementBug# 2427465
      );


          --v_uom_code := rec.uom; /*4281841..commented*/ pramasub FP
           END LOOP;
        end if; -- end if added by sriram -- Bug # 2977200
		/*4281841...start*/
		   OPEN cur_bpa_unit_measure(v_blanket_hdr, v_blanket_line);
		   FETCH cur_bpa_unit_measure INTO lv_unit_meas_lookup;
		   CLOSE cur_bpa_unit_measure;

		   OPEN Fetch_Uom_Code_Cur(lv_unit_meas_lookup);
		   FETCH Fetch_Uom_Code_Cur INTO v_uom_code;
		   CLOSE Fetch_Uom_Code_Cur;
	   /*4281841...end*/

      /* jai_po_tax_pkg.calculate_tax( 'REQUISITION', v_requisition_line_id , v_requisition_header_id, NULL,
                    v_line_quantity, v_unit_price*v_line_quantity, NVL( v_currency, v_hdr_currency ) ,
                    v_assessable_value, v_assessable_value, NULL, conv_rate ); */

    /* ELSE  -- pramasub FP commented

       -- code added by sriram to ensure that we do not have a duplicate requisition line_id
       -- checking if the requisition line id is already created or not
       -- Bug # 2977200

       open  c_reqn_line_id(v_requisition_line_id) ;
       fetch c_reqn_line_id into v_reqn_ctr;
       close c_reqn_line_id;

       if nvl(v_reqn_ctr,0) = 0 then

          FOR rec IN  tax_cur(v_line_location_id) LOOP
              v_po_line_id := Rec.Po_Line_Id;


-- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
	INSERT INTO JAI_PO_REQ_LINE_TAXES(
        requisition_line_id, requisition_header_id, tax_line_no,
        precedence_1, precedence_2, precedence_3, precedence_4, precedence_5,
        precedence_6, precedence_7, precedence_8, precedence_9, precedence_10,
        tax_id, tax_rate, qty_rate, uom, tax_amount, tax_target_amount,
        tax_type, modvat_flag, vendor_id, currency,
        creation_date, created_by, last_update_date, last_updated_by, last_update_login,
        tax_category_id       -- cbabu for EnhancementBug# 2427465
      ) VALUES (
        v_requisition_line_id, v_requisition_header_id, rec.lno,
        rec.p_1, rec.p_2, rec.p_3, rec.p_4, rec.p_5,
        rec.p_6, rec.p_7, rec.p_8, rec.p_9, rec.p_10,
        rec.tax_id, rec.tax_rate, rec.qty_rate, rec.uom, rec.tax_amount, rec.tax_amount + v_line_amount,
        rec.tax_type, rec.modvat_flag, rec.vendor_id, rec.currency,
        v_creation_date, v_created_by, v_last_update_date, v_last_updated_by, v_last_update_login,
        rec.tax_category_id     -- cbabu for EnhancementBug# 2427465
      );

            v_uom_code := rec.uom;
        END LOOP;
       end if; -- added by sriram -- Bug # 2977200

     END IF;*/
     /*jai_po_tax_pkg.calculate_tax( 'REQUISITION_BLANKET', v_requisition_line_id , v_po_line_id, v_line_location_id,
                    v_line_quantity, v_unit_price*v_line_quantity, NVL( v_currency, v_hdr_currency ) ,
                    v_assessable_value, v_assessable_value,ln_vat_assess_value, NULL, conv_rate ); -- Ravi for VAT*/ --pramasub FP commented
		--ja_in_po_calc_tax is renamed to jai_po_tax_pkg.calc_tax
 jai_po_tax_pkg.calc_tax(p_type          => 'REQUISITION_BLANKET',
				   p_header_id           => v_blanket_hdr,
				   p_requisition_line_id => v_requisition_line_id ,
				   P_line_id             => v_po_line_id,
				   p_line_location_id    => v_line_location_id,
				   p_line_focus_id       => NULL,
				   p_line_quantity       => v_line_quantity,
				   p_base_value          => v_line_amount,
				   p_line_uom_code       => v_uom_code,
				   p_tax_amount          => ln_tax_amount,
				   p_assessable_value    => v_assessable_value,
				   p_vat_assess_value    => ln_vat_assess_value,
				   p_item_id             => v_inventory_item_id,
				   p_conv_rate           => 1/conv_rate,
				   p_po_curr             => v_currency,
				   p_func_curr           => v_hdr_currency);

  ELSIF v_blanket_hdr IS NULL AND v_blanket_line IS NULL THEN

     IF v_type_lookup_code = 'PURCHASE' THEN

         -- Following line modified by Vijay Shankar for Bug# 3207886
         -- Reason: jai_cmn_tax_defaultation_pkg.ja_in_vendor_default_taxes accepts INV_ORGANIZATION_ID as Parameter but we are passing OPT Unit id
         -- jai_cmn_tax_defaultation_pkg.JA_IN_VENDOR_DEFAULT_TAXES(NVL(v_org_id,0), v_vendor_id,
         jai_cmn_tax_defaultation_pkg.JA_IN_VENDOR_DEFAULT_TAXES(v_dest_org_id, v_vendor_id,
      v_site_id, v_inventory_item_id, v_requisition_header_id,
      v_requisition_line_id, v_tax_category_id);

         jai_cmn_tax_defaultation_pkg.JA_IN_CALC_PREC_TAXES('PO_REQN', v_tax_category_id, v_requisition_header_id,
             v_requisition_line_id, v_assessable_value, v_line_amount, v_inventory_item_id, v_line_quantity ,
             v_uom_code, v_vendor_id, NVL( v_currency, v_hdr_currency ), conv_rate,
             v_creation_date, v_created_by, v_last_update_date,
             v_last_updated_by, v_last_update_login,p_vat_assessable_value => ln_vat_assess_value,    -- Ravi for VAT
             p_modified_by_agent_flag => v_modified_by_agent_flag, /*Added for Bug 8241905*/
             p_parent_req_line_id => v_parent_req_line_id); /*Added for Bug 8241905*/

     ELSIF v_type_lookup_code = 'INTERNAL' THEN

         jai_cmn_tax_defaultation_pkg.Ja_In_Org_Default_Taxes( v_src_org_id, v_inventory_item_id, v_tax_category_id );

         jai_cmn_tax_defaultation_pkg.JA_IN_CALC_PREC_TAXES('PO_REQN', v_tax_category_id, v_requisition_header_id,
             v_requisition_line_id, v_assessable_value, v_line_amount, v_inventory_item_id, v_line_quantity ,
             v_uom_code, NULL, NVL( v_currency, v_hdr_currency ), conv_rate,
             v_creation_date, v_created_by, v_last_update_date,
             v_last_updated_by, v_last_update_login, -1*v_src_org_id,p_vat_assessable_value => ln_vat_assess_value,
             p_modified_by_agent_flag => v_modified_by_agent_flag,   /*Added for Bug 8241905*/
             p_parent_req_line_id => v_parent_req_line_id);      /*Added for Bug 8241905*/

     END IF;

  END IF;

     SELECT SUM(TAX_AMOUNT)
     INTO   v_tax_amount
     FROM   JAI_PO_REQ_LINE_TAXES
     WHERE  Requisition_Header_Id = v_requisition_header_id
     AND    Requisition_Line_Id   = v_requisition_line_id
     AND    Tax_Type <> jai_constants.tax_type_tds ; /* 'TDS' ;Ramananda for removal of SQL LITERALs */
     v_total_amount := v_line_amount + v_tax_amount;

  -- cbabu for EnhancementBug# 2427465
  UPDATE JAI_PO_REQ_LINES
  SET tax_amount = v_tax_amount,
    total_amount = v_total_amount
  WHERE requisition_line_id = v_requisition_line_id;
  END ARI_T1 ;

  /*
  REM +======================================================================+
  REM NAME          ARU_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_PO_RLA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_PO_RLA_ARU_T1
  REM
  REM +======================================================================+
  */
PROCEDURE ARU_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
	 v_requisition_line_id   NUMBER; --File.Sql.35 Cbabu         := pr_new.Requisition_Line_Id;
  v_sugg_vendor_name    VARCHAR2(360); --File.Sql.35 Cbabu    := pr_new.Suggested_Vendor_Name; --Increased the  length 80 to 360 by JMEENA for bug#5394234
  v_dest_org_id               NUMBER; --File.Sql.35 Cbabu             := pr_new.Destination_Organization_Id; --Increased the  length 80 to 360 by JMEENA for bug#5394234
  v_sugg_vendor_location  VARCHAR2(360); --File.Sql.35 Cbabu  := pr_new.Suggested_Vendor_Location;
  v_item_id       NUMBER; --File.Sql.35 Cbabu     := pr_new.Item_Id;
  v_shipment_type     VARCHAR2(30);
  v_po_vendor_id      NUMBER;
  v_vendor_id     NUMBER;
  v_sugg_vendor_id    NUMBER;
  v_po_vendor_site_id   NUMBER;
  v_line_loc_id     NUMBER; --File.Sql.35 Cbabu          := pr_new.Line_Location_Id;
  v_cre_dt        DATE ; --File.Sql.35 Cbabu             := pr_new.Creation_Date;
  v_cre_by        NUMBER; --File.Sql.35 Cbabu          := pr_new.Created_By;
  v_last_upd_dt     DATE ; --File.Sql.35 Cbabu           := pr_new.Last_Update_Date ;
  v_last_upd_by     NUMBER; --File.Sql.35 Cbabu          := pr_new.Last_Updated_By;
  v_last_upd_login    NUMBER  ; --File.Sql.35 Cbabu        := pr_new.Last_Update_Login;
  v_hdr_curr      VARCHAR2(30);
  v_uom_code      VARCHAR2(100);
  v_price       NUMBER ; --File.Sql.35 Cbabu     := pr_new.Unit_Price;
  v_qty       NUMBER   ; --File.Sql.35 Cbabu   := pr_new.Quantity;
  v_curr        VARCHAR2(30) ; --File.Sql.35 Cbabu       := pr_new.Currency_Code;
  v_req_conv_rate     NUMBER  ; --File.Sql.35 Cbabu        := pr_new.Rate;
  v_req_conv_type     VARCHAR2(30) ; --File.Sql.35 Cbabu       := pr_new.Rate_Type;
  v_req_conv_date     DATE  ; --File.Sql.35 Cbabu              := pr_new.Rate_Date;
  v_t_curr        VARCHAR2(30);
  v_po_curr       VARCHAR2(30);
  v_po_conv_rate      NUMBER;
  v_po_conv_type      VARCHAR2(30);
  v_po_conv_date      DATE;
  v_set_of_book_id    NUMBER;
  conv_rate       NUMBER;
  v_curr_conv_factor          NUMBER;
  DUMMY                       NUMBER;--File.Sql.35 Cbabu              := 1;
  v_currency_code   GL_SETS_OF_BOOKS.currency_code%TYPE;--added by Gsr and Srihari on 07-03-2001

  -- For Blanket Release
  v_src_ship_id               NUMBER;
  v_po_rel_id                 NUMBER;

  -- For Cursor Fetch tax cur
  v_po_hdr_id     NUMBER;
  v_po_line_id      NUMBER;
  v_line_focus_id     NUMBER;
  Line_tot        NUMBER;
  v_tax_amt       NUMBER;
  v_total_amt       NUMBER;
  v_tax_line_no     NUMBER;
  v_prec1       NUMBER;
  v_prec2       NUMBER;
  v_prec3         NUMBER;
  v_prec4       NUMBER;
  v_prec5         NUMBER;

  v_prec6       NUMBER;
  v_prec7       NUMBER;
  v_prec8         NUMBER;
  v_prec9       NUMBER;
  v_prec10         NUMBER;


  v_taxid         NUMBER;
  v_tax_rate      NUMBER;
  v_qty_rate      NUMBER;
  v_uom       VARCHAR2(15);
  v_tax_type      VARCHAR2(30);
  v_mod_flag      VARCHAR2(1);
  v_vendor2_id      NUMBER;
  v_mod_cr        NUMBER;
  v_vendor1_id      NUMBER;
  v_tax_target_amt    NUMBER;
  v_tax_amt1      NUMBER;
  v_assessable_value    NUMBER;
  ln_vat_assess_value NUMBER; -- added rallamse bug#4250072 VAT
  v_loc_count     NUMBER;--File.Sql.35 Cbabu  := 0;      --new variable for loc chk on 17-aug-00

  v_tax_category_id     JAI_PO_TAXES.tax_category_id%TYPE;  -- cbabu for EnhancementBug# 2427465
  v_tax_category_id_holder  JAI_PO_LINE_LOCATIONS.tax_category_id%TYPE;   -- cbabu for EnhancementBug# 2427465
  v_style_id            po_headers_all.style_id%TYPE; --Added by Sanjikum for Bug#4483042

------------------------------>
--  Check the vendor btn the vendor present in tax lines and that of suggested vendor in requisition lines
--    If they are same or any one is null then insert po vendor else keep the vendor in tact.
--    Check if the document to be created is a Blanket Release / Standard Purchase Order.
--    Pick up Line Location Details as well.
  -- Start of addition by Gsri on 07-MAR-2001
  /* Bug 5243532. Added by Lakshmi Gopalsami
   * Removed cursor Sob_cur as currency_code
   * will be fetched via caching logic.
   */


  -- End of addition by Gsri on 07-MAR-2001

  CURSOR Fetch_Hdr_Cur IS
    SELECT Po_Header_Id, Po_Line_Id, ( Price_Override * Quantity ) Total,
      Shipment_Type, Po_Release_Id, Source_Shipment_Id
      , quantity      -- cbabu for Bug# 3051278
      , ship_to_organization_id, ship_to_location_id, price_override, Unit_Meas_Lookup_Code   -- Vijay Shankar for Bug# 3193592
    FROM Po_Line_Locations_All
    WHERE  Line_Location_Id = v_line_loc_id;

  -- Start, Vijay Shankar for Bug# 3193592
  CURSOR c_inventory_org_id(p_ship_to_location_id IN NUMBER) IS
    SELECT Inventory_Organization_Id
    FROM Hr_Locations
    WHERE Location_Id = p_ship_to_location_id;

  v_inventory_org_id  HR_LOCATIONS.Inventory_Organization_Id%TYPE;
  v_line_loc_cnt NUMBER;
  v_ship_to_organization_id NUMBER;
  v_ship_to_location_id NUMBER;
  v_price_override    PO_LINE_LOCATIONS_ALL.price_override%TYPE;
  v_unit_meas_lookup_code   PO_LINE_LOCATIONS_ALL.unit_meas_lookup_code%TYPE;
  v_line_uom          PO_LINES_ALL.unit_meas_lookup_code%TYPE;
  v_type_lookup_code PO_HEADERS_ALL.type_lookup_code%TYPE;
  v_quot_class_code PO_HEADERS_ALL.quotation_class_code%TYPE;
  -- End, Vijay Shankar for Bug# 3193592

  CURSOR Fetch_Unit_Measure_Cur IS
    SELECT Unit_Meas_Lookup_Code
    FROM Po_Lines_All
    WHERE Po_Line_Id = v_po_line_id;

  CURSOR Fetch_UomCode_Cur(p_uom IN VARCHAR2) IS
    SELECT Uom_Code
    FROM Mtl_Units_Of_Measure
    WHERE Unit_Of_Measure = p_uom;

  -- Pick up vendor id for the corresponding Po_Header_Id
  CURSOR Fetch_Po_Vendor_Id_Cur( hdr_id IN NUMBER ) IS
    SELECT Vendor_Id, Vendor_SIte_Id, Currency_Code, Rate_Date, Rate_Type, Rate
      , type_lookup_code, quotation_class_code,  -- Vijay Shankar for Bug# 3193592
      style_id --Added by Sanjikum for Bug#4483042
    FROM Po_Headers_All
    WHERE Po_Header_Id = hdr_id;

  /*  Bug 4513549. Added by LGOPALSA
      Commented the following cursor as it is
      not used anywhere
  CURSOR Fetch_Focus_Id_Cur( line_id IN NUMBER ) IS
    SELECT Line_Focus_Id
    FROM   JAI_PO_LINE_LOCATIONS
    WHERE  Po_Line_Id = line_id
    -- AND Line_Location_Id IS NULL
    AND ( Line_Location_Id IS NULL OR line_location_id = 0 );  -- cbabu for EnhancementBug# 2427465
  */

-- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
  CURSOR Fetch_Taxes_Cur( rqlineid IN NUMBER ) IS
    SELECT Tax_Line_no,
           Precedence_1, Precedence_2, Precedence_3, Precedence_4, Precedence_5,
	   Precedence_6, Precedence_7, Precedence_8, Precedence_9, Precedence_10,
      Tax_Id, Currency, Tax_Rate, Qty_Rate, UOM, Tax_Amount, Tax_Type, Modvat_Flag,
      Vendor_Id, Tax_Target_Amount,
      tax_category_id         -- cbabu for EnhancementBug# 2427465
    FROM JAI_PO_REQ_LINE_TAXES
    WHERE requisition_line_id = rqlineid
    ORDER BY Tax_Line_No;

  CURSOR Fetch_Mod_Cr_Cur( taxid IN NUMBER ) IS
    SELECT Tax_Type, Mod_Cr_Percentage, Vendor_Id
      , adhoc_flag  -- Vijay Shankar for Bug# 2782356
    FROM   JAI_CMN_TAXES_ALL
    WHERE  Tax_Id = taxid;

  CURSOR Fetch_Vendor_Id IS
    SELECT Vendor_Id
    FROM   Po_Vendors
    WHERE  Vendor_Name = v_sugg_vendor_name;

  -- Get the header currency code


  CURSOR Tot_Amt_Cur IS
    SELECT SUM( NVL( Tax_Amount, 0 ) )
    FROM JAI_PO_TAXES
    WHERE line_location_id = v_line_loc_id
    AND Tax_Type <> jai_constants.tax_type_tds ; /* 'TDS'; Ramananda for removal of SQL LITERALs */

  -- Start Modification by Gaurav for PO Autocreate issue 17-aug-00
  CURSOR Chk_localization_entry IS
    SELECT COUNT(REQUISITION_LINE_ID)
    FROM JAI_PO_REQ_LINES
    WHERE REQUISITION_LINE_ID = pr_new.REQUISITION_LINE_ID;
  -- End modification

  -- Addition to check tax override flag on 24-apr-01 by RK and GSR
  CURSOR tax_override_flag_cur(c_vendor_id NUMBER, c_vendor_site_id NUMBER) IS
    SELECT override_flag
    FROM JAI_CMN_VENDOR_SITES
    WHERE vendor_id = c_vendor_id
    AND vendor_site_id = c_vendor_site_id;

  v_override_flag VARCHAR2(1);
  -- End of addition to check tax override flag on 24-apr-01 by RK and GSR

  -- cbabu for EnhancementBug# 2427465
  CURSOR c_get_tax_category_id(p_requisition_line_id IN NUMBER) IS
    SELECT tax_category_id
    FROM JAI_PO_REQ_LINES
    WHERE requisition_line_id = p_requisition_line_id;


  v_quantity NUMBER;      -- cbabu for Bug# 3051278

  -- Vijay Shankar for Bug# 2782356
  v_tax_amount NUMBER;
  v_adhoc_flag CHAR(1);
  -- v_tax_currency VARCHAR2(15);
  v_curr_conv_rate NUMBER;

  v_debug BOOLEAN;  --File.Sql.35 Cbabu  := false;
  v_utl_file_name VARCHAR2(50);--File.Sql.35 Cbabu  := 'ja_in_po_dflt_taxes.log';
  v_utl_location VARCHAR2(512);
  v_myfilehandle UTL_FILE.FILE_TYPE; -- This is for File handling

  -- Bug 4513549. Added by LGOPALSA
  lv_tax_cnt NUMBER := 0;
  lv_tax_from_reqn_flag varchar2(1) := 'N';

  /* Bug 5243532. Added by Lakshmi Gopalsami
   * Defined variable for implementing caching logic.
   */
  l_func_curr_det jai_plsql_cache_pkg.func_curr_details;
  v_requisition_header_id  NUMBER;
  v_reqn_tax NUMBER;  --Added by Bgowrava for Bug#8766851

  /* Bug 4513549. Fetch the line_focus_id.
     This is used when we are inserting taxes from
     requistion and ja_in_po_line_locations already exists */

    CURSOR Fetch_Focus_Id_Cur_for_req( line_id IN NUMBER , line_loc_id in Number ) IS
    SELECT Line_Focus_Id
    FROM   JAI_PO_LINE_LOCATIONS
    WHERE  Po_Line_Id = line_id
    AND Line_Location_Id = line_loc_id;

     Cursor fetch_Tax_cnt( cp_line_loc_id in number ) is
     select count(1)
       from JAI_PO_TAXES
      where line_location_id = cp_line_loc_id;

   /* Bug 5243532. Added by Lakshmi Gopalsami
    * Removed cursors  Fetch_Book_Id and used po_requisition_headers_v
    * in cursor Hdr_Curr_Cur instead of gl_sets_of_books
    * and implemented using caching logic.
    */
   CURSOR Fetch_Hdr_Curr_Cur IS
   SELECT NVL( Currency_Code, '$' )
     FROM Po_Requisition_Headers_V
    WHERE Requisition_Header_Id = v_requisition_header_id;

 --added, Bgowrava for Bug#6084636
	    Cursor c_get_tax_modified_flag IS
	    SELECT tax_modified_flag
	        FROM JAI_PO_LINE_LOCATIONS
	      WHERE line_location_id = pr_new.line_location_id ;
  lv_tax_modified_flag VARCHAR2(1) ;

  BEGIN
    pv_return_code := jai_constants.successful ;
    /*------------------------------------------------------------------------------------------------------------------
Change History for ja_in_po_dflt_taxes_trg.sql
S.No  DD/MM/YYYY   Details
------------------------------------------------------------------------------------------------------------------
1     16/08/2002  SSUMAITH for Bug# 2504283
          unCommented the return statement because because it was causing the taxes to be  picked up from
          requisition instead of  blanket agreement.
2  06/12/2002   cbabu for EnhancementBug# 2427465, FileVersion# 615.2
                   tax_category_id column is populated into PO and SO localization tables, which will be used to
                   identify from which tax_category the taxes are defaulted. Also the tax_category_id populated into
                   the  tax table will be useful to identify whether the tax is a defaulted or a manual tax.
                   A cursor is modified to fetch tax_category_id. UPDATE statement of JAI_PO_LINE_LOCATIONS is modified to update
                   tax_category_id column with defaulting tax category
3  04/02/2003   cbabu for Bug# 2782356, FileVersion# 615.3, Bug logged for IN60104
                   Adhoc tax amounts are not defaulted from requisition taxes to STANDARD PO autocreated from requisition

4  22/07/2003   cbabu for Bug# 3051278, FileVersion# 616.1
                   This fix is done to default the taxes onto PO Shipment line which got created through AutoCreate of
                   Blanket Release from Purchase Requisition. If there is any change in UOM between
                   requisition line and BPO Line, then PO Shipment quantity has to be given as input to jai_po_cmn_pkg.process_release_shipment
                   procedure. But requisition quantity is going as input and this is causing the problem.
                   Code is modified to pick PO Shipment quantity and give it as input to jai_po_cmn_pkg.process_release_shipment procedure

5  18/11/2003   Vijay Shankar for Bug# 3193592, FileVersion# 617.1
                   when multiple requisitions are merged to form a single PO Shipment during Autocreation process, then this trigger
                   is erroring out as taxes from multiple requisition lines are getting populated into the same line_location_id.
                   This is resolved by defaulting taxes from setup with an API call to jai_po_tax_pkg.ja_in_po_case2 procedure
                   instead of carrying taxes from requisition lines to PO Shipment

6.02/08/2004   ssumaith - bug# 3729015 file version 115.1
                 commented call to jai_po_cmn_pkg.process_release_shipment because in the ja_in_po_tax_insert_trg
                 a hook has been implemented which defaults the taxes from a requisition to the release.
                 and JAINPOCR concurrent is anyway called from ja_in_po_tax_insert_trg , hence the presense
                 of the call is superfluous.

                 Also ported the changes done as part of the one-off bug 3599268 into generic code path at two places
                 in the code.
7.12/Mar/2005  Bug 4210102 - Added by LGOPALSA Version  115.3
               (1) Added Customs and CVD education cess
               (2) Added checkfile in dbdrv

8. 14/03/2005  bug#4250072  rallamse Version# 115.4
               VAT implementation

9.  08-Jun-2005   This Object is Modified to refer to New DB Entry names in place of Old
                  DB as required for CASE COMPLAINCE. Version  116.1

10. 13-Jun-2005    File Version: 116.2
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done

11. 08-Jul-2005    Sanjikum for Bug#4483042
                   1) Added a call to jai_cmn_utils_pkg.validate_po_type, to check whether for the current PO
                      IL functionality should work or not.

12. 08-Jul-2005    Sanjikum for Bug#4483042, File version 117.2
                   1) Added a new column in cursor - Fetch_Po_Vendor_Id_Cur

13. 17-Aug-2005    Ramananda for bug#4513549 during R12 sanity testing. jai_mfg_t.sql File Version 120.2
                   Re-done the jai_po_rla_t1.sql 120.2 changes.
                    Problem :
                    ---------
                    Existing taxes on PO  were getting deleted and then getting
                    inserted from the setup always whenever merge happens.

                    Fix:
                    ----
                    Checked whether tax already exists for PO for the current line location id
                    If there exists atleast one line we will not copy the taxes from the PO
                    Else we will copy the taxes from the current requisition which is getting
                    merged.

                    Dependency Due To the current fix:-
                    None
14. 07-Nov-2008 JMEENA for bug#5394234
		Increased the length of variables v_sugg_vendor_name and v_sugg_vendor_locations from 80 to 360

15.  26-Aug-2009  Bgowrava for Bug#8766851 , File Version 120.12.12010000.6
                                Issue: CAN'T AUTOCREATE PO FOR INDIA OPERATING ORG
			Fix: Introduced the v_reqn_tax variable to hold the value of  number of taxes on the purchase requisition and if this is greater than zero then
			the code for calculating tax and updating JaI_Po_Line_Locations is done.

===============================================================================
Dependencies

Version  Author       Dependencies        Comments
115.3    LGOPALSA     IN60106 +            Added CVD and Customs education cess
                      4146708

115.4    rallamse     IN60106 +            For VAT implementation
                      4146708 +
                      4245089

120.2    RPOKKULA                          jai_po_da_t1.sql 120.2 (Functional)
------------------------------------------------------------------------------------------------------------------*/

  --File.Sql.35 Cbabu
  v_requisition_line_id           := pr_new.Requisition_Line_Id;
  v_sugg_vendor_name              := pr_new.Suggested_Vendor_Name;
  v_dest_org_id                   := pr_new.Destination_Organization_Id;
  v_sugg_vendor_location          := pr_new.Suggested_Vendor_Location;
  v_item_id                       := pr_new.Item_Id;
  v_line_loc_id                   := pr_new.Line_Location_Id;
  v_cre_dt                        := pr_new.Creation_Date;
  v_cre_by                        := pr_new.Created_By;
  v_last_upd_dt                   := pr_new.Last_Update_Date ;
  v_last_upd_by                   := pr_new.Last_Updated_By;
  v_last_upd_login                := pr_new.Last_Update_Login;
  v_price                         := pr_new.Unit_Price;
  v_qty                           := pr_new.Quantity;
  v_curr                          := pr_new.Currency_Code;
  v_req_conv_rate                 := pr_new.Rate;
  v_req_conv_type                 := pr_new.Rate_Type;
  v_req_conv_date                 := pr_new.Rate_Date;
  DUMMY                           := 1;
  v_loc_count                     := 0;      --new variable for loc chk on 17-aug-00
  v_debug                         := true;
  v_utl_file_name                 := 'ja_in_po_dflt_taxes.log';
  -- Bug 5243532. Added by Lakshmi Gopalsami
  v_requisition_header_id         := pr_new.requisition_header_id;

  IF v_debug THEN
    BEGIN
    pv_return_code := jai_constants.successful ;
      SELECT DECODE(SUBSTR (value,1,INSTR(value,',') -1),NULL, Value,SUBSTR (value,1,INSTR(value,',') -1))
      INTO v_utl_location
      FROM v$parameter
      WHERE name = 'utl_file_dir';

      v_myfilehandle := UTL_FILE.FOPEN(v_utl_location, v_utl_file_name ,'A');

    EXCEPTION
      WHEN OTHERS THEN
        v_debug := false;
    END;

  END IF;



  IF v_debug THEN
    UTL_FILE.PUT_LINE(v_myfilehandle,'********* Start Debug, TimeStamp -> '||TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'));
    UTL_FILE.PUT_LINE(v_myfilehandle, 'reqn_line_id -> '||pr_new.Requisition_Line_Id
      ||', line_loc_id -> '||pr_new.line_location_Id
      ||', dest_org_id -> '||pr_new.Destination_Organization_Id
    );
  END IF;

  -- porting of bug 3599268 into generic code path
  --Start, Vijay Shankar for Bug# 3599268

  /* Bug 5243532. Added by Lakshmi Gopalsami
   * Removed cursors  Fetch_Book_Id and Sob_cur
   * and implemented using caching logic.
   */
   l_func_curr_det  := jai_plsql_cache_pkg.return_sob_curr
                            (p_org_id  => v_dest_org_id );
   v_set_of_book_id := l_func_curr_det.ledger_id;
   v_currency_code  := l_func_curr_det.currency_code;
   -- End of bug 5243532

  /*IF pr_new.org_id IS NOT NULL THEN
    IF v_currency_code <> 'INR' THEN
      IF v_debug  THEN
        utl_file.fclose(v_myfilehandle);
      END IF;
      RETURN;
    END IF;
  END IF;*/
  --End, Vijay Shankar for Bug# 3599268
  -- porting of bug 3599268 into generic code path


  -- Start Modification by sriram,gadde and subbu on 26-feb-01
  OPEN  Fetch_Hdr_Cur;
  FETCH Fetch_Hdr_Cur INTO v_po_hdr_id, v_po_line_id, Line_Tot,
    v_shipment_type, v_po_rel_id, v_src_ship_id
    , v_quantity    -- cbabu for Bug# 3051278
    , v_ship_to_organization_id, v_ship_to_location_id, v_price_override, v_unit_meas_lookup_code;    -- Vijay Shankar for Bug# 3193592
  CLOSE Fetch_Hdr_Cur;
  -- end Modification by sriram,gadde and subbu on 26-feb-01

   OPEN  Fetch_Po_Vendor_Id_Cur( v_po_hdr_id );
   FETCH Fetch_Po_Vendor_Id_Cur INTO v_po_vendor_id, v_po_vendor_site_id, v_po_curr,
      v_po_conv_date, v_po_conv_type, v_po_conv_rate
      , v_type_lookup_code, v_quot_class_code,    -- Vijay Shankar for Bug# 3193592
      v_style_id; --Added by Sanjikum for Bug#4483042
   CLOSE Fetch_Po_Vendor_Id_Cur;

   --code added by Sanjikum for Bug#4483042
   IF jai_cmn_utils_pkg.validate_po_type(p_style_id => v_style_id) = FALSE THEN
     return;
   END IF;

    -- Start Modification by Gaurav for PO Autocreate issue 17-aug-00
   OPEN Chk_localization_entry;
   FETCH Chk_localization_entry INTO v_loc_count;
   CLOSE Chk_localization_entry;

  /* Bug 5243532. Added by Lakshmi Gopalsami
   * Removed cursor  Fetch_Book_Id
   * as this is duplication of the earlier values fetched
   * Now this is derived using caching logic.
   */

   OPEN Fetch_Hdr_Curr_Cur;
    FETCH Fetch_Hdr_Curr_Cur INTO v_hdr_curr;
   CLOSE Fetch_Hdr_Curr_Cur;

   v_curr     := NVL( v_curr, v_hdr_curr);

   OPEN  Fetch_Unit_Measure_Cur;
   -- FETCH Fetch_Unit_Measure_Cur INTO v_uom_code;
   FETCH Fetch_Unit_Measure_Cur INTO v_line_uom;
   CLOSE Fetch_Unit_Measure_Cur;

   OPEN  Fetch_UomCode_Cur(v_line_uom);
   FETCH Fetch_UomCode_Cur INTO v_uom_code;
   CLOSE Fetch_UomCode_Cur;

   --Addition to check tax override flag on 24-apr-01 by RK and GSR
   OPEN  tax_override_flag_cur(v_po_vendor_id, v_po_vendor_site_id);
   FETCH tax_override_flag_cur INTO v_override_flag;
   CLOSE tax_override_flag_cur;

   IF NVL(v_override_flag,'N') = 'Y' AND v_shipment_type <> 'BLANKET' THEN
    IF v_debug  THEN
     utl_file.fclose(v_myfilehandle);
    END IF;
     RETURN;
   END IF;

   --End of addition to check override flag on 24-apr-01 by RK and GSR
   --Start of addition by subbu AND gadde on 26-FEB-01

   IF v_shipment_type <> 'BLANKET' THEN
     IF NVL(v_loc_count,0) = 0 THEN
      IF v_debug  THEN
       utl_file.fclose(v_myfilehandle);
      END IF;
       RETURN;
     END IF;

   --End of addition by subbu AND gadde on 26-FEB-01
   ELSE

  /*
    commented by sriram,gadde and subbu on 26-feb-01
    OPEN  Fetch_Hdr_Cur;
    FETCH Fetch_Hdr_Cur INTO v_po_hdr_id, v_po_line_id, Line_Tot, v_shipment_type, v_po_rel_id, v_src_ship_id;
    CLOSE Fetch_Hdr_Cur;
  */
  -- IF v_shipment_type = 'BLANKET' THEN  --commented by gadde and subbu
  -- Start of addition by Gsri on 07-MAR-2001
    /* Porting of Bug# 3599268 into generic code path. This check here is causing to fire for even Other functional currency PO's
    so, shifted this code from here to top

    OPEN Sob_cur;
    FETCH Sob_cur INTO v_currency_code;
    CLOSE Sob_cur;

    IF pr_new.org_id IS NOT NULL THEN
      IF v_currency_code <> 'INR' THEN
      IF v_debug  THEN
       utl_file.fclose(v_myfilehandle);
      END IF;
        RETURN;
      END IF;

  END IF;
*/
    -- End of addition by Gsri on 07-MAR-2001

  if v_debug THEN
    UTL_FILE.PUT_LINE(v_myfilehandle,'777 jai_po_cmn_pkg.process_release_shipment ('''||'BLANKET'||''''
      ||','||v_src_ship_id || v_line_loc_id||',' ||v_po_line_id||',' ||v_po_hdr_id
      ||','||v_quantity||',' ||v_po_rel_id
      ||',' ||''''||TO_CHAR(v_cre_dt,'DD/MM/RRRR HH24:MI:SS')||''''||',' ||v_cre_by
      ||',' ||''''||TO_CHAR(v_last_upd_dt,'DD/MM/RRRR HH24:MI:SS')||''''||',' ||v_last_upd_by
      ||',' ||v_last_upd_login||' );'

    );
  end if;

       /*
       commented by ssumaith - bug# 3729015 file version 115.2
        because in the ja_in_po_tax_insert_trg, because of a hook ,
        the taxes JAINPOCR concurrent is anyway called from ja_in_po_tax_insert_trg


       jai_po_cmn_pkg.process_release_shipment ( 'BLANKET',
                       v_src_ship_id,
                           v_line_loc_id,
                           v_po_line_id,
                           v_po_hdr_id,
                           -- v_qty,    -- commented by cbabu for Bug# 3051278
                           v_quantity,    -- cbabu for Bug# 3051278
                           v_po_rel_id,
                           v_cre_dt,
                           v_cre_by,
                           v_last_upd_dt,
                           v_last_upd_by,
                           v_last_upd_login );

*/
    IF v_debug  THEN
     utl_file.fclose(v_myfilehandle);
    END IF;

--This Return is commented by Nagaraj.s on 09/05/2002
--As this is stopping insertion of Taxes into Ja_IN_Po_line_location_taxes_trg(Bug#2364148)
       RETURN; -- uncomented by sriram bug # 2504283 base bug 2335923 16-aug-2002
--Ends here................
    END IF;

    IF v_sugg_vendor_name IS NULL THEN
       v_sugg_vendor_id := -999;     --  Means sugg vendor is null
    ELSE
       OPEN  Fetch_Vendor_Id;
       FETCH Fetch_Vendor_Id INTO v_sugg_vendor_id;
       CLOSE Fetch_Vendor_Id;
    END IF;

  -- Vijay Shankar for Bug# 3193592
  select count(1) into v_line_loc_cnt from JAI_PO_LINE_LOCATIONS
  where line_location_id = pr_new.line_location_id;

  IF v_debug THEN -- bug 7218695. Added by Lakshmi Gopalsami
    UTL_FILE.PUT_LINE(v_myfilehandle, 'pr_new.line_location_id '|| pr_new.line_location_id);
    UTL_FILE.PUT_LINE(v_myfilehandle, 'v_line_loc_cnt '|| v_line_loc_cnt);
  END IF;

  -- this means multiple requisition lines are merged into a single PO Shipment line
  -- so the taxes should get defaulted from SET UP's rather than carrying the reqn taxes to PO Shipment

  /* Bug 4513549 Added by Lakshmi Gopalsami */

   IF v_line_loc_cnt > 0 THEN

     IF v_debug THEN -- bug 7218695. Added by Lakshmi Gopalsami
        UTL_FILE.PUT_LINE(v_myfilehandle, 'Into the IF Condition');
     END IF;

 --START, added, Bgowrava for Bug#6084636
	OPEN c_get_tax_modified_flag ;
	FETCH c_get_tax_modified_flag INTO lv_tax_modified_flag ;
	CLOSE c_get_tax_modified_flag;


	IF NVL(lv_tax_modified_flag,'N') = 'N' THEN --added, Bgowrava for Bug#6084636

	 DELETE FROM JAI_PO_TAXES
	 WHERE line_location_id = pr_new.line_location_id;

	 IF v_debug THEN -- bug 7218695. Added by Lakshmi Gopalsami

	   UTL_FILE.PUT_LINE(v_myfilehandle, 'Deleted Taxes');
         END IF;

	 OPEN  c_inventory_org_id( v_ship_to_location_id );
	 FETCH c_inventory_org_id INTO v_inventory_org_id;
	 CLOSE c_inventory_org_id;


   jai_po_tax_pkg.ja_in_po_case2(v_type_lookup_code,
                                             v_quot_class_code,
                                             v_po_vendor_id,
                                             v_po_vendor_site_id,
                                             v_po_curr,
                                             v_inventory_org_id,
                                             v_item_id,
                                             v_line_loc_id,
                                             v_po_hdr_id,
                                             v_po_line_id,
                                             v_price_override,
                                             v_quantity,
                                             v_cre_dt,
                                             v_cre_by,
                                             v_last_upd_dt,
                                             v_last_upd_by,
                                             v_last_upd_login,
                                             nvl(v_unit_meas_lookup_code, v_line_uom),
                                             FLAG => NULL,
                                             P_VAT_ASSESS_VALUE => NULL -- Added by rallamse bug#4250072 VAT
                                            );


		 IF v_debug THEN
				UTL_FILE.PUT_LINE(v_myfilehandle, 'Reqn Lines Merge returning Successfully' );
				 utl_file.fclose(v_myfilehandle);
			END IF;
	END IF ;
	return;
  END IF;
   --END, added, Bgowrava for Bug#6084636


  /*
  ||Po lines does not exists .
  ||Insert the line locations from requisition into po using the procedure below
  */

   jai_po_cmn_pkg.insert_line( 'STANDARD',
                   v_line_loc_id, -- Bug 4513549
                   v_po_hdr_id,
                   v_po_line_id,
                   v_cre_dt,
                   v_cre_by,
                   v_last_upd_dt,
                   v_last_upd_by,
                   v_last_upd_login,
                   'I' );

    IF v_debug THEN
      UTL_FILE.PUT_LINE(v_myfilehandle, 'line focus id '|| v_line_focus_id);
    END IF;




   /* Bug 4513549. Added by LGOPALSA
     Fetch the line_focus_id for the current line and current
     line location id  */

   Open  Fetch_Focus_Id_Cur_for_req( v_po_line_id,v_line_loc_id);
    Fetch Fetch_Focus_Id_Cur_for_req INTO v_line_focus_id;
   Close Fetch_Focus_Id_Cur_for_req;

   IF v_debug THEN
      UTL_FILE.PUT_LINE(v_myfilehandle, 'line focus id '|| v_line_focus_id);
   END IF;

   IF v_debug THEN
      UTL_FILE.PUT_LINE(v_myfilehandle, '2-1 v_line_loc_cnt -> '||v_line_loc_cnt
      );
   END IF;

    v_reqn_tax := 0;     --Added by Bgowrava for Bug#8766851
    OPEN Fetch_Taxes_Cur( v_requisition_line_id );
    LOOP

    FETCH Fetch_Taxes_Cur INTO v_tax_line_no, v_prec1, v_prec2, v_prec3, v_prec4, v_prec5,
                                              v_prec6, v_prec7, v_prec8, v_prec9, v_prec10,
      v_taxid, v_t_curr, v_tax_rate, v_qty_rate, v_uom, v_tax_amt,
      v_tax_type, v_mod_flag, v_vendor2_id, v_tax_target_amt,
      v_tax_category_id;    -- cbabu for EnhancementBug# 2427465

    EXIT WHEN Fetch_Taxes_Cur%NOTFOUND;
	v_reqn_tax := v_reqn_tax + 1;        --Added by Bgowrava for Bug#8766851

    OPEN Fetch_Mod_Cr_Cur( v_taxid );
    FETCH Fetch_Mod_Cr_Cur INTO v_tax_type, v_mod_cr, v_vendor1_id
      , v_adhoc_flag;   -- Vijay Shankar for Bug# 2782356
    CLOSE Fetch_Mod_Cr_Cur;

    IF v_debug THEN
      UTL_FILE.PUT_LINE(v_myfilehandle, '2 tax_id -> '||v_taxid
        ||', v_t_curr -> '||v_t_curr
        ||', v_tax_amt -> '||v_tax_amt
      );
    END IF;

    -- Start, Vijay Shankar for Bug# 2782356
    IF nvl(v_adhoc_flag, 'N') = 'Y' THEN
      IF v_t_curr <> v_po_curr THEN
        -- Vijay Shankar for Bug# 2782356
        IF v_debug THEN
          UTL_FILE.PUT_LINE(v_myfilehandle,    '3 jai_cmn_utils_pkg.currency_conversion('||v_set_of_book_id
            ||', '''||v_po_curr
      ||''', to_date('||v_po_conv_date
            ||','''||'''DD/MM/YYYY''||''), '''||v_po_conv_type
            ||''', '||v_po_conv_rate ||');'
          );
        END IF;

        IF v_debug THEN
          UTL_FILE.PUT_LINE(v_myfilehandle, '5 v_curr_conv_rate -> '||v_curr_conv_rate );
        END IF;

        -- as tax_currency is same as functional currency and v_curr_conv_rate contains conversion from v_po_curr to func_curr
        IF v_t_curr = v_currency_code THEN
          v_curr_conv_rate := jai_cmn_utils_pkg.currency_conversion( v_set_of_book_id , v_po_curr , v_po_conv_date , v_po_conv_type, v_po_conv_rate );

          v_tax_amount := v_tax_amt / v_curr_conv_rate;
          IF v_debug THEN
            UTL_FILE.PUT_LINE(v_myfilehandle, '5.1 multiply ');
          END IF;

        ELSE  -- now tax_currency is not equal to functional currency, so division is fine
          v_curr_conv_rate := jai_cmn_utils_pkg.currency_conversion( v_set_of_book_id , v_t_curr , v_po_conv_date , v_po_conv_type, v_po_conv_rate );
          v_tax_amount := v_tax_amt * v_curr_conv_rate;
          IF v_debug THEN
            UTL_FILE.PUT_LINE(v_myfilehandle, '5.2 divide' );
          END IF;

        END IF;

        v_curr_conv_rate := null;
      ELSE
        v_tax_amount := v_tax_amt;
      END IF;
    ELSE
      v_tax_amount := 0;
    END IF;
    -- End, Vijay Shankar for Bug# 2782356

    IF v_mod_cr IS NOT NULL AND v_mod_cr > 0 THEN
      v_mod_flag := 'Y';
    ELSE
      v_mod_flag := 'N';
    END IF;

    /* Added by LGOPALSA. Bug 4210102
     * Added Customs and CVD Education Cess */

    IF upper(v_tax_type) IN ( 'CUSTOMS', 'CVD',
                              jai_constants.tax_type_add_cvd , -- Date 03/11/2006 Bug 5228046 added by SACSETHI
                              jai_constants.tax_type_customs_edu_Cess,JAI_CONSTANTS.TAX_TYPE_SH_CUSTOMS_EDU_CESS,
                              jai_constants.tax_type_cvd_edu_cess,JAI_CONSTANTS.TAX_TYPE_SH_CVD_EDU_CESS)                 --Added SH related entries by Bgowrava for forward porting bug#5989740
    THEN
      v_vendor_id := NULL;
    ELSIF v_tax_type = 'TDS' THEN
      v_vendor_id := v_vendor1_id;
    ELSE
      IF NVL( v_vendor2_id, -999 ) = v_sugg_vendor_id THEN
        v_vendor_id := v_po_vendor_id;
      ELSE
        v_vendor_id := v_vendor2_id;
      END IF;
    END IF;

-- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
    INSERT INTO JAI_PO_TAXES(
        line_focus_id, line_location_id, tax_line_no, po_line_id, po_header_id,
        precedence_1, precedence_2, precedence_3, precedence_4, precedence_5,
	precedence_6, precedence_7, precedence_8, precedence_9, precedence_10,
        tax_id, currency, tax_rate, qty_rate, uom,
        tax_amount, tax_type, modvat_flag, vendor_id, tax_target_amount,
        creation_date, created_by, last_update_date, last_updated_by, last_update_login,
        tax_category_id     -- cbabu for EnhancementBug# 2427465
    ) VALUES (
        v_line_focus_id, v_line_loc_id, v_tax_line_no, v_po_line_id, v_po_hdr_id,
        v_prec1, v_prec2, v_prec3, v_prec4, v_prec5,
        v_prec6, v_prec7, v_prec8, v_prec9, v_prec10,
        v_taxid, NVL( v_po_curr, NVL( v_curr, v_hdr_curr ) ), v_tax_rate, v_qty_rate, v_uom,
        -- 0, v_tax_type, v_mod_flag, v_vendor_id, 0,
        v_tax_amount, v_tax_type, v_mod_flag, v_vendor_id, 0,   -- Vijay Shankar for Bug# 2782356
                                  -- v_taxid, v_tax_currency, v_tax_rate, v_qty_rate, v_uom,
        v_cre_dt, v_cre_by, v_last_upd_dt, v_last_upd_by, v_last_upd_login,
        v_tax_category_id     -- cbabu for EnhancementBug# 2427465
    );

    -- Vijay Shankar for Bug# 2782356
    v_tax_amt := 0;
    v_tax_amount := 0;
    v_adhoc_flag := null;
    -- v_tax_currency := null;


    END LOOP;

    CLOSE Fetch_Taxes_Cur;

    if v_reqn_tax > 0 then   --Added by Bgowrava for Bug#8766851
    v_assessable_value := jai_cmn_setup_pkg.get_po_assessable_value( v_po_vendor_id, v_po_vendor_site_id, v_item_id, v_uom_code );

    IF NVL( v_assessable_value, 0 ) > 0  THEN
        -- Bug 4513549. Added by LGOPALSA
       v_assessable_value := v_assessable_value * v_quantity;
       jai_po_cmn_pkg.Ja_In_Po_Func_Curr( v_po_hdr_id, v_assessable_value, v_po_curr, v_curr_conv_factor );
    ELSE
       v_assessable_value := Line_Tot;
    END IF;

    /*  begin rallamse bug#4250072  for VAT */
    ln_vat_assess_value := jai_general_pkg.ja_in_vat_assessable_value (
                                                          p_party_id          => v_po_vendor_id,
                                                          p_party_site_id     => v_po_vendor_site_id,
                                                          p_inventory_item_id => v_item_id,
                                                          p_uom_code          => v_uom_code,
                                                          p_default_price     => 0,
                                                          p_ass_value_date    => trunc(sysdate) ,
                                                          p_party_type        => 'V'
                                                        );

    IF NVL( ln_vat_assess_value , 0 ) = 0 THEN
      ln_vat_assess_value := Line_tot ;
    ELSE
      -- Bug 4513549.
      -- Added by LGOPALSA. Fix
      ln_vat_assess_value := ln_vat_assess_value * v_quantity;
      jai_po_cmn_pkg.Ja_In_Po_Func_Curr( v_po_hdr_id, ln_vat_assess_value, v_po_curr, v_curr_conv_factor );
    END IF ;
    /*  end rallamse bug#4250072  for VAT */


    jai_po_cmn_pkg.Ja_In_Po_Func_Curr( v_po_hdr_id, DUMMY, v_po_curr, v_curr_conv_factor);  -- TO get the conversion rate .

    /* Added ln_vat_assess_value for bug# for VAT */
    jai_po_tax_pkg.calculate_tax( 'STANDARDPO',
                   v_po_hdr_id ,
                   v_po_line_id,
                   v_line_loc_id,
                   -- Bug 4513549. Added by LGOPALSA
                   v_quantity,
                   line_tot,
                   v_uom_code,
                   v_assessable_value,
                   v_assessable_value,
                   ln_vat_assess_value,
                   NULL,
                   v_curr_conv_factor );


  /* Bug 4513549. Added by LGOPALSA
     Removed the commented call to ja_in_po_calc_tax */

    OPEN  Tot_Amt_Cur;
    FETCH Tot_Amt_Cur INTO v_tax_amt;
    CLOSE Tot_Amt_Cur;



      -- cbabu for EnhancementBug# 2427465
      OPEN  c_get_tax_category_id(pr_new.REQUISITION_LINE_ID);
      FETCH c_get_tax_category_id INTO v_tax_category_id_holder;
      CLOSE c_get_tax_category_id;



    UPDATE JaI_Po_Line_Locations
       SET Tax_Amount = NVL( v_tax_amt, 0 ),
          Total_Amount = NVL( Line_Tot, 0 ) + NVL( v_tax_amt, 0 ),
          Last_Updated_By = v_last_upd_by,
          Last_Update_Date = v_last_upd_dt,
          Last_Update_Login = v_last_upd_login,
	  tax_category_id = v_tax_category_id_holder   /*added by ssawant for bug 6134111*/
    WHERE  Po_Line_Id = v_po_line_id
      AND Line_Location_Id = v_line_Loc_id;

    end if; --Added by Bgowrava for Bug#8766851

  IF v_debug THEN
    UTL_FILE.PUT_LINE(v_myfilehandle, '*******End*******');
     utl_file.fclose(v_myfilehandle);
  END IF;

exception
  when others then
    IF v_debug THEN
      UTL_FILE.PUT_LINE(v_myfilehandle, '4 Error in procedure, errm -> '||SQLERRM
      );
       utl_file.fclose(v_myfilehandle);
    END IF;
    RAISE;
  END ARU_T1 ;

  /*
  REM +======================================================================+
  REM NAME          ARU_T2
  REM
  REM DESCRIPTION   Called from trigger JAI_PO_RLA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_PO_RLA_ARU_T3
  REM
  REM +======================================================================+
  */
  PROCEDURE ARU_T2 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
	  --v_row_id             ROWID  ; --File.Sql.35 Cbabu     := pr_new.ROWID;
  v_dest_org_id        NUMBER  ; --File.Sql.35 Cbabu    := pr_new.Destination_Organization_Id;
  v_currency           VARCHAR2(15); --File.Sql.35 Cbabu    := pr_new.Currency_Code;
  v_rate_type          VARCHAR2(30); --File.Sql.35 Cbabu    := pr_new.Rate_Type;
  v_rate_date          DATE    ; --File.Sql.35 Cbabu  := pr_new.Rate_Date;
  v_rate               NUMBER  ; --File.Sql.35 Cbabu    := pr_new.Rate;
  v_header_id          NUMBER  ; --File.Sql.35 Cbabu        := pr_new.requisition_header_id;
  v_line_id            NUMBER  ; --File.Sql.35 Cbabu        := pr_new.requisition_line_id;
  v_sugg_vendor_name   VARCHAR2(360); --File.Sql.35 Cbabu    := pr_new.suggested_vendor_name; --Increased the  length 80 to 360 by JMEENA for bug#5394234
  v_sugg_vendor_loc    VARCHAR2(360); --File.Sql.35 Cbabu    := pr_new.suggested_vendor_location; --Increased the  length 80 to 360 by JMEENA for bug#5394234
  v_inventory_item_id  NUMBER  ; --File.Sql.35 Cbabu        := pr_new.item_id;
  v_src_org_id         NUMBER  ; --File.Sql.35 Cbabu        := pr_new.Source_Organization_Id;
  v_uom                VARCHAR2(30)   ; --File.Sql.35 Cbabu := pr_new.Unit_Meas_Lookup_Code;
  v_quantity           NUMBER     ; --File.Sql.35 Cbabu := pr_new.Quantity;
  v_line_tax_amount    NUMBER ; --File.Sql.35 Cbabu     :=  NVL( (pr_new.quantity * pr_new.unit_price) ,0 );
  v_line_amount        NUMBER ; --File.Sql.35 Cbabu     :=  NVL( ( pr_new.quantity * pr_new.unit_price) ,0 );
  v_creation_date      DATE   ; --File.Sql.35 Cbabu       := pr_new.Creation_Date;
  v_created_by         NUMBER   ; --File.Sql.35 Cbabu       := pr_new.Created_By;
  v_last_update_date   DATE   ; --File.Sql.35 Cbabu         := pr_new.Last_Update_Date;
  v_last_updated_by    NUMBER ; --File.Sql.35 Cbabu         := pr_new.Last_Updated_By;
  v_last_update_login  NUMBER ; --File.Sql.35 Cbabu         := pr_new.Last_Update_Login;

  v_type_lookup_code   Po_Requisition_Headers_All.Type_Lookup_Code % TYPE;
  v_tax_category_id    NUMBER;
  v_org_id             NUMBER     ; --File.Sql.35 Cbabu := 0;
  found                BOOLEAN;
  v_vendor_id          NUMBER;
  v_site_id            NUMBER;
  v_hdr_curr           VARCHAR2(15);
  v_tax_flag           VARCHAR2(1);
  v_seg_id             VARCHAR2(20);
  v_tax_amount         NUMBER;
  v_uom_code           VARCHAR2(3);
  conv_rate            NUMBER;
  v_assessable_value   NUMBER;
  ln_vat_assess_value  NUMBER;      -- Ravi for VAT
  v_gl_set_of_bks_id   NUMBER;
  v_hook_value         VARCHAR2(10) ; /* rallamse bug#4479131 PADDR Elimination */
  ln_tax_amount        NUMBER; -- pramasub FP

------------- added by Gsr 12-jul-01
 v_operating_id                     number; --File.Sql.35 Cbabu   :=pr_new.ORG_ID;

 /* Bug 5243532. Added by Lakshmi Gopalsami
  * Defined variable for implementing caching logic.
  */
 l_func_curr_det jai_plsql_cache_pkg.func_curr_details;

CURSOR Fetch_Org_Id_Cur IS SELECT NVL(Operating_Unit,0)
                  FROM   Org_Organization_Definitions
            WHERE  Organization_Id = v_dest_org_id;

CURSOR bind_cur IS
  SELECT Segment1, Type_Lookup_Code, apps_source_code -- pramasub FP
    FROM Po_Requisition_Headers_All
   WHERE Requisition_Header_Id = v_header_id;

CURSOR vend_cur(p_sugg_vendor_name IN VARCHAR2) IS
  SELECT vendor_id
    FROM po_vendors
   WHERE vendor_name = p_sugg_vendor_name;

CURSOR site_cur(p_sugg_vendor_loc IN VARCHAR2) IS
  SELECT Vendor_Site_Id
    FROM Po_Vendor_Sites_All A
   WHERE A.Vendor_Site_Code = p_sugg_vendor_loc
     AND A.Vendor_Id        = v_vendor_id
     AND (A.Org_Id    = v_org_id
          OR
    (A.Org_Id    is NULL AND  v_org_id is NULL));
--     AND NVL(A.Org_Id,0)    = NVL(v_org_id,0);

CURSOR tax_rate_cur(p_tax_id IN NUMBER) IS
   SELECT Tax_Rate, Tax_Amount, Uom_Code, Tax_Type
     FROM JAI_CMN_TAXES_ALL
    WHERE Tax_Id = p_tax_id;

CURSOR Fetch_Hdr_Curr_Cur IS SELECT NVL( Currency_Code, '$' )
             FROM   Po_Requisition_Headers_V
             WHERE  Requisition_Header_Id = v_header_id;

/* Bug 5243532. Addd by Lakshmi Gopalsami
 * Removed the cursor Fetch_Book_Id_Cur
 * and implemented the same using caching logic.
 */

CURSOR Fetch_Uom_Code_Cur IS SELECT Uom_Code
             FROM   Mtl_Units_Of_Measure
             WHERE  Unit_Of_Measure = v_uom;

CURSOR Fetch_Mod_Flag_Cur IS   Select Tax_modified_Flag
           From JAI_PO_REQ_LINES
           Where Requisition_Line_Id   = v_line_id;

lv_apps_source_code  VARCHAR2(20);
/*rchandan for bug#5852041.. start*/ --pramasub FP end
 	 v_blanket_hdr        NUMBER;
 	 v_blanket_line       NUMBER;
 	 v_po_line_id         NUMBER;
 	 v_line_location_id   NUMBER;
 	 v_reqn_ctr           NUMBER;


 	 CURSOR cur_bpa_tax_lines(p_po_line_id IN NUMBER,p_line_location_id IN NUMBER) IS
 	 SELECT a.Po_Line_Id         ,
 	        a.tax_line_no   lno  ,
 	        a.tax_id             ,
 	                          a.precedence_1  p_1  ,
 	                          a.precedence_2  p_2  ,
 	                          a.precedence_3  p_3  ,
 	                          a.precedence_4  p_4  ,
 	                          a.precedence_5  p_5  ,
 	                          a.precedence_6  p_6  ,
 	                          a.precedence_7  p_7  ,
 	                          a.precedence_8  p_8  ,
 	                          a.precedence_9  p_9  ,
 	                          a.precedence_10 p_10 ,
 	                          a.currency           ,
 	                          a.tax_rate           ,
 	                          a.qty_rate           ,
 	                          a.uom                ,
 	                          a.tax_amount         ,
 	                          a.tax_type           ,
 	                          a.vendor_id          ,
 	                          a.modvat_flag        ,
 	                          tax_category_id
 	         --FROM Ja_In_Po_Line_Location_Taxes a
			 FROM JAI_PO_TAXES a
 	  WHERE po_line_id                 = p_po_line_id
 	    AND nvl(line_location_id,-999) = p_line_location_id
 	  ORDER BY a.tax_line_no;

 	 CURSOR c_reqn_line_id(p_reqn_line_id Number) is
 	 SELECT 1
 	   --FROM ja_in_reqn_tax_lines
	   FROM JAI_PO_REQ_LINE_TAXES
 	  WHERE requisition_line_id = p_reqn_line_id;

 	  v_unit_price  NUMBER;

 	 /*rchandan for bug#5852041.. end*/  --pramasub FP end

  BEGIN
    pv_return_code := jai_constants.successful ;
    /*------------------------------------------------------------------------------------------
CHANGE HISTORY: FILENAME: Ja_In_Reqn_Tax_Update_Trg.sql
S.No      Date          Author and Details
------------------------------------------------------------------------------------------
1     16/08/2002     Nagaraj.s for Bug#2508790
                        Previously the Coding was
                        OPEN  Fetch_Book_Id_Curr ;
                        FETCH Fetch_Book_Id_Cur INTO v_gl_set_of_books_id;
                        CLOSE Fetch_Book_Id_Curr;
                        The Coding is changed as
                        OPEN  Fetch_Book_Id_Curr ;
                        FETCH Fetch_Book_Id_Curr INTO v_gl_set_of_books_id;
                        CLOSE Fetch_Book_Id_Curr;

2       10/10/2003   Vijay Shankar for Bug# 3190872, FileVersion: 616.1
                      Call to jai_po_tax_pkg.calculate_tax is not invoked properly, which is made proper with this fix

3.       30/11/2005  Aparajita for bug#4036241. Version#115.1

                        Introduced the call to centralized packaged procedure,
                        jai_cmn_utils_pkg.check_jai_exists to check if localization has been installed.

5.   17/mar-2005  Rchandan for bug#4245365   Version#115.3
                  Changes made to calculate VAT assessable value . This vat assessable is passed
                  to the procedure that calculates the VAT related taxes

6.   08-Jun-2005  This Object is Modified to refer to New DB Entry names in place of Old
                  DB as required for CASE COMPLAINCE. Version 116.1

7. 13-Jun-2005    File Version: 116.2
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done

8  06-Jul-2005    rallamse for bug# PADDR Elimination
                  1. Replaced call to jai_po_cmn_pkg.query_locator_for_line with
                     jai_cmn_hook_pkg.Po_Requisition_Lines_All

9 04-Aug-2005     P1 Build Issue bug# 4535701 by Ramananda. File Version 120.2
                  Commented the columns Event_Id and Line_Number.
                  These will be uncommented once PO team's po_requisition_lines_all table has these columns
10 17-sep-05      p1 bug 4616729 - ssumaith - file version 120.3
                  event_id and line_number columns have been commented and null is passes instead in calls to various hook packages

02/11/2006 	 for Bug 5228046, File version 120.2
                 Forward porting the change in 11i bug 5365523 (Additional CVD Enhancement).
                 This bug has datamodel and spec changes.

12. 07-Nov-2008 JMEENA for bug#5394234
		Increased the length of variables v_sugg_vendor_name and v_sugg_vendor_loc from 80 to 360

Dependency:
----------

Sl No. Bug        Dependent on
                  Bug/Patch set    Details
-------------------------------------------------------------------------------------------------
1      4036241    4033992          Call to  jai_cmn_utils_pkg.check_jai_exists, whcih was created thru bug
                                   4033992.
                                   ja_in_util_pkg_s.sql 115.0
                                   ja_in_util_pkg_b.sql 115.0
2.     4245365    4245089          VAT implementation

--------------------------------------------------------------------------------------------*/

--File.Sql.35 Cbabu
--v_row_id                  := pr_new.ROWID;
v_dest_org_id             := pr_new.Destination_Organization_Id;
v_currency                := pr_new.Currency_Code;
v_rate_type               := pr_new.Rate_Type;
v_rate_date               := pr_new.Rate_Date;
v_rate                    := pr_new.Rate;
v_header_id               := pr_new.requisition_header_id;
v_line_id                 := pr_new.requisition_line_id;
v_sugg_vendor_name        := pr_new.suggested_vendor_name;
v_sugg_vendor_loc         := pr_new.suggested_vendor_location;
v_inventory_item_id       := pr_new.item_id;
v_src_org_id              := pr_new.Source_Organization_Id;
v_uom                     := pr_new.Unit_Meas_Lookup_Code;
v_quantity                := pr_new.Quantity;
v_line_tax_amount         :=  NVL( (pr_new.quantity * pr_new.unit_price) ,0 );
v_line_amount             :=  NVL( ( pr_new.quantity * pr_new.unit_price) ,0 );
v_creation_date           := pr_new.Creation_Date;
v_created_by              := pr_new.Created_By;
v_last_update_date        := pr_new.Last_Update_Date;
v_last_updated_by         := pr_new.Last_Updated_By;
v_last_update_login       := pr_new.Last_Update_Login;
v_org_id                  := 0;
v_operating_id            :=pr_new.ORG_ID;


--if
--  jai_cmn_utils_pkg.check_jai_exists (p_calling_object   => 'JA_IN_REQN_TAX_UPDATE_TRG',
--                               p_org_id           =>  pr_new.org_id)

--  =
--  FALSE
--then
  /* India Localization funtionality is not required */
--  return;
--end if;

--pramasub FP start
OPEN  bind_cur;
 	 FETCH Bind_cur INTO v_seg_id, v_type_lookup_code , lv_apps_source_code;
CLOSE bind_cur;
--pramasub FP end

--jai_po_cmn_pkg.query_locator_for_line( v_header_id, 'JAINREQN', found );
v_hook_value          := 'TRUE'; /* rallamse bug#4479131 PADDR Elimination */
/* If v_hook_value is TRUE, then it means taxes should be defaulted. IF FALSE then return */
v_hook_value := jai_cmn_hook_pkg.Po_Requisition_Lines_All
                (
                  pr_new.REQUISITION_LINE_ID,
                  pr_new.REQUISITION_HEADER_ID,
                  pr_new.LINE_NUM,
                  pr_new.LINE_TYPE_ID,
                  pr_new.CATEGORY_ID,
                  pr_new.ITEM_DESCRIPTION,
                  pr_new.UNIT_MEAS_LOOKUP_CODE,
                  pr_new.UNIT_PRICE,
                  pr_new.QUANTITY,
                  pr_new.DELIVER_TO_LOCATION_ID,
                  pr_new.TO_PERSON_ID,
                  pr_new.LAST_UPDATE_DATE,
                  pr_new.LAST_UPDATED_BY,
                  pr_new.SOURCE_TYPE_CODE,
                  pr_new.LAST_UPDATE_LOGIN,
                  pr_new.CREATION_DATE,
                  pr_new.CREATED_BY,
                  pr_new.ITEM_ID,
                  pr_new.ITEM_REVISION,
                  pr_new.QUANTITY_DELIVERED,
                  pr_new.SUGGESTED_BUYER_ID,
                  pr_new.ENCUMBERED_FLAG,
                  pr_new.RFQ_REQUIRED_FLAG,
                  pr_new.NEED_BY_DATE,
                  pr_new.LINE_LOCATION_ID,
                  pr_new.MODIFIED_BY_AGENT_FLAG,
                  pr_new.PARENT_REQ_LINE_ID,
                  pr_new.JUSTIFICATION,
                  pr_new.NOTE_TO_AGENT,
                  pr_new.NOTE_TO_RECEIVER,
                  pr_new.PURCHASING_AGENT_ID,
                  pr_new.DOCUMENT_TYPE_CODE,
                  pr_new.BLANKET_PO_HEADER_ID,
                  pr_new.BLANKET_PO_LINE_NUM,
                  pr_new.CURRENCY_CODE,
                  pr_new.RATE_TYPE,
                  pr_new.RATE_DATE,
                  pr_new.RATE,
                  pr_new.CURRENCY_UNIT_PRICE,
                  pr_new.SUGGESTED_VENDOR_NAME,
                  pr_new.SUGGESTED_VENDOR_LOCATION,
                  pr_new.SUGGESTED_VENDOR_CONTACT,
                  pr_new.SUGGESTED_VENDOR_PHONE,
                  pr_new.SUGGESTED_VENDOR_PRODUCT_CODE,
                  pr_new.UN_NUMBER_ID,
                  pr_new.HAZARD_CLASS_ID,
                  pr_new.MUST_USE_SUGG_VENDOR_FLAG,
                  pr_new.REFERENCE_NUM,
                  pr_new.ON_RFQ_FLAG,
                  pr_new.URGENT_FLAG,
                  pr_new.CANCEL_FLAG,
                  pr_new.SOURCE_ORGANIZATION_ID,
                  pr_new.SOURCE_SUBINVENTORY,
                  pr_new.DESTINATION_TYPE_CODE,
                  pr_new.DESTINATION_ORGANIZATION_ID,
                  pr_new.DESTINATION_SUBINVENTORY,
                  pr_new.QUANTITY_CANCELLED,
                  pr_new.CANCEL_DATE,
                  pr_new.CANCEL_REASON,
                  pr_new.CLOSED_CODE,
                  pr_new.AGENT_RETURN_NOTE,
                  pr_new.CHANGED_AFTER_RESEARCH_FLAG,
                  pr_new.VENDOR_ID,
                  pr_new.VENDOR_SITE_ID,
                  pr_new.VENDOR_CONTACT_ID,
                  pr_new.RESEARCH_AGENT_ID,
                  pr_new.ON_LINE_FLAG,
                  pr_new.WIP_ENTITY_ID,
                  pr_new.WIP_LINE_ID,
                  pr_new.WIP_REPETITIVE_SCHEDULE_ID,
                  pr_new.WIP_OPERATION_SEQ_NUM,
                  pr_new.WIP_RESOURCE_SEQ_NUM,
                  pr_new.ATTRIBUTE_CATEGORY,
                  pr_new.DESTINATION_CONTEXT,
                  pr_new.INVENTORY_SOURCE_CONTEXT,
                  pr_new.VENDOR_SOURCE_CONTEXT,
                  pr_new.ATTRIBUTE1,
                  pr_new.ATTRIBUTE2,
                  pr_new.ATTRIBUTE3,
                  pr_new.ATTRIBUTE4,
                  pr_new.ATTRIBUTE5,
                  pr_new.ATTRIBUTE6,
                  pr_new.ATTRIBUTE7,
                  pr_new.ATTRIBUTE8,
                  pr_new.ATTRIBUTE9,
                  pr_new.ATTRIBUTE10,
                  pr_new.ATTRIBUTE11,
                  pr_new.ATTRIBUTE12,
                  pr_new.ATTRIBUTE13,
                  pr_new.ATTRIBUTE14,
                  pr_new.ATTRIBUTE15,
                  pr_new.BOM_RESOURCE_ID,
                  pr_new.CLOSED_REASON,
                  pr_new.CLOSED_DATE,
                  pr_new.TRANSACTION_REASON_CODE,
                  pr_new.QUANTITY_RECEIVED,
                  pr_new.SOURCE_REQ_LINE_ID,
                  pr_new.ORG_ID,
                  pr_new.KANBAN_CARD_ID,
                  pr_new.CATALOG_TYPE,
                  pr_new.CATALOG_SOURCE,
                  pr_new.MANUFACTURER_ID,
                  pr_new.MANUFACTURER_NAME,
                  pr_new.MANUFACTURER_PART_NUMBER,
                  pr_new.REQUESTER_EMAIL,
                  pr_new.REQUESTER_FAX,
                  pr_new.REQUESTER_PHONE,
                  pr_new.UNSPSC_CODE,
                  pr_new.OTHER_CATEGORY_CODE,
                  pr_new.SUPPLIER_DUNS,
                  pr_new.TAX_STATUS_INDICATOR,
                  pr_new.PCARD_FLAG,
                  pr_new.NEW_SUPPLIER_FLAG,
                  pr_new.AUTO_RECEIVE_FLAG,
                  pr_new.TAX_USER_OVERRIDE_FLAG,
                  pr_new.TAX_CODE_ID,
                  pr_new.NOTE_TO_VENDOR,
                  pr_new.OKE_CONTRACT_VERSION_ID,
                  pr_new.OKE_CONTRACT_HEADER_ID,
                  pr_new.ITEM_SOURCE_ID,
                  pr_new.SUPPLIER_REF_NUMBER,
                  pr_new.SECONDARY_UNIT_OF_MEASURE,
                  pr_new.SECONDARY_QUANTITY,
                  pr_new.PREFERRED_GRADE,
                  pr_new.SECONDARY_QUANTITY_RECEIVED,
                  pr_new.SECONDARY_QUANTITY_CANCELLED,
                  pr_new.VMI_FLAG,
                  pr_new.AUCTION_HEADER_ID,
                  pr_new.AUCTION_DISPLAY_NUMBER,
                  pr_new.AUCTION_LINE_NUMBER,
                  pr_new.REQS_IN_POOL_FLAG,
                  pr_new.BID_NUMBER,
                  pr_new.BID_LINE_NUMBER,
                  pr_new.NONCAT_TEMPLATE_ID,
                  pr_new.SUGGESTED_VENDOR_CONTACT_FAX,
                  pr_new.SUGGESTED_VENDOR_CONTACT_EMAIL,
                  pr_new.AMOUNT,
                  pr_new.CURRENCY_AMOUNT,
                  pr_new.LABOR_REQ_LINE_ID,
                  pr_new.JOB_ID,
                  pr_new.JOB_LONG_DESCRIPTION,
                  pr_new.CONTRACTOR_STATUS,
                  pr_new.CONTACT_INFORMATION,
                  pr_new.SUGGESTED_SUPPLIER_FLAG,
                  pr_new.CANDIDATE_SCREENING_REQD_FLAG,
                  pr_new.CANDIDATE_FIRST_NAME,
                  pr_new.CANDIDATE_LAST_NAME,
                  pr_new.ASSIGNMENT_END_DATE,
                  pr_new.OVERTIME_ALLOWED_FLAG,
                  pr_new.CONTRACTOR_REQUISITION_FLAG,
                  pr_new.DROP_SHIP_FLAG,
                  pr_new.ASSIGNMENT_START_DATE,
                  pr_new.ORDER_TYPE_LOOKUP_CODE,
                  pr_new.PURCHASE_BASIS,
                  pr_new.MATCHING_BASIS,
                  pr_new.NEGOTIATED_BY_PREPARER_FLAG,
                  pr_new.SHIP_METHOD,
                  pr_new.ESTIMATED_PICKUP_DATE,
                  pr_new.SUPPLIER_NOTIFIED_FOR_CANCEL,
                  pr_new.BASE_UNIT_PRICE,
                  pr_new.AT_SOURCING_FLAG,
                  /*
                  || Commented the columns for P1 bug# 4535701.
                  || These will be uncommented once PO teams po_requisition_lines_all table has these columns
                  */
		  /* Bug4540709. Added by Lakshmig Gopalsami
		   * Reverting the fix for bug 4535701 */
                 /* pr_new.EVENT_ID,  /*following 2 cols commented by ssumaith - bug# 4616729 and added the two null towards the end /*
                  pr_new.LINE_NUMBER*/
                  NULL,
                  NULL
                ) ;
IF lv_apps_source_code <> 'POR' THEN --pramasub FP
--IF NOT found THEN
IF v_hook_value = 'FALSE' THEN
   RETURN;
END IF;
END IF; --pramasub FP
/*5852041 start*/ --pramasub FP start

 v_blanket_hdr       :=  pr_new.BLANKET_PO_HEADER_ID;
 v_blanket_line      :=  pr_new.BLANKET_PO_LINE_NUM;
 v_unit_price        :=  pr_new.unit_price;


 --IF DELETING THEN
 IF pv_action = jai_constants.deleting THEN
		 DELETE from JAI_PO_REQ_LINE_TAXES --ja_in_reqn_tax_lines
		 WHERE  requisition_line_id = pr_old.requisition_line_id ;

		 DELETE from JAI_PO_REQ_LINES --ja_in_reqn_lines
		 WHERE  requisition_line_id = pr_old.requisition_line_id;

		 RETURN;

 --ELSIF UPDATING  AND NVL(pr_new.cancel_flag,'$') = 'Y'  AND NVL(pr_old.cancel_flag,'#') <> 'Y' THEN
 ELSIF pv_action = jai_constants.updating
	AND NVL(pr_new.cancel_flag,'$') = 'Y'  AND NVL(pr_old.cancel_flag,'#') <> 'Y' THEN
		 DELETE from JAI_PO_REQ_LINE_TAXES --ja_in_reqn_tax_lines
		 WHERE  requisition_line_id = pr_old.requisition_line_id ;

		 DELETE from JAI_PO_REQ_LINES --ja_in_reqn_lines
		 WHERE  requisition_line_id = pr_old.requisition_line_id;

		 RETURN;

 END IF;

 /*5852041 end*/ --pramasub FP end
/*OPEN  bind_cur;
FETCH Bind_cur INTO v_seg_id, v_type_lookup_code;
CLOSE bind_cur;*/ --pramasub FP

OPEN  Fetch_Org_Id_Cur;
FETCH Fetch_Org_Id_Cur INTO v_org_id;
CLOSE Fetch_Org_Id_Cur;

OPEN  Fetch_Mod_Flag_Cur;
FETCH Fetch_Mod_Flag_Cur INTO v_tax_flag;
CLOSE Fetch_Mod_Flag_Cur;

OPEN  Fetch_Hdr_Curr_Cur;
FETCH Fetch_Hdr_Curr_Cur INTO v_hdr_curr;
CLOSE Fetch_Hdr_Curr_Cur;

OPEN vend_cur(v_sugg_vendor_name);
FETCH Vend_Cur INTO v_vendor_id;
CLOSE vend_cur;

OPEN site_cur(v_sugg_vendor_loc);
FETCH Site_Cur INTO v_site_id;
CLOSE site_cur;

 /* Bug 5243532. Added by Lakshmi Gopalsami
  * Removed the cursor Fetch_Book_Id_Cur
  * and implemented using caching logic.
  */

l_func_curr_det       := jai_plsql_cache_pkg.return_sob_curr
                           (p_org_id  => v_dest_org_id );
v_gl_set_of_bks_id    := l_func_curr_det.ledger_id;


OPEN  Fetch_Uom_Code_Cur;
FETCH Fetch_Uom_Code_Cur INTO v_uom_code;
CLOSE Fetch_Uom_Code_Cur;

v_currency := NVL( v_currency, v_hdr_curr );

 /*
 	 || The NVL conditions added on both sides of the Equal to sign by ssumaith
 	 || during dev of iprocurement.
 	 */
IF NVL(v_currency,'$') = NVL(v_hdr_curr,'$') THEN
--IF v_currency = v_hdr_curr THEN commented by pramasub FP
   conv_rate := 1;
ELSE
   IF v_rate_type = 'User' THEN
      conv_rate := 1/v_rate;
   ELSE
      conv_rate := 1/jai_cmn_utils_pkg.currency_conversion( v_gl_set_of_bks_id, v_currency, v_rate_date, v_rate_type, v_rate );
   END IF;
END IF;

v_assessable_value := jai_cmn_setup_pkg.get_po_assessable_value( v_vendor_id, v_site_id,
                  v_inventory_item_id, v_uom_code );


v_line_amount := v_line_amount * conv_rate ;

ln_vat_assess_value :=  jai_general_pkg.ja_in_vat_assessable_value
                                              ( p_party_id => v_vendor_id,
                                                p_party_site_id => v_site_id,
                                                p_inventory_item_id => v_inventory_item_id,
                                                p_uom_code => v_uom_code,
                                                p_default_price => 0,
                                                p_ass_value_date => trunc(SYSDATE),
                                                p_party_type => 'V'
                                               ) ;      -- Ravi for VAT

IF NVL( v_assessable_value, 0 ) <= 0 THEN
     v_assessable_value := v_line_amount;
ELSE
     v_assessable_value := v_assessable_value * v_quantity * conv_rate ;
END IF;

IF ln_vat_assess_value = 0 THEN    -- Ravi for VAT

  ln_vat_assess_value := v_line_amount;

ELSE

  ln_vat_assess_value := ln_vat_assess_value * v_quantity * conv_rate ;

END IF;

--If v_tax_flag = 'N' Then commented by pramasub start FP
/*Entire OR condition in the if clause is added by rchandan for bug#5852041*/
--If v_tax_flag = 'N' OR
	-- Following IF condition added by skjayaba for internal QA issue. Tax currency coming as NULL for internal Requisitions. pramasub FP for 115.10
	IF (lv_apps_source_code = 'POR' AND  v_currency is NULL) THEN
		 v_currency := 'INR';
	END IF;

	IF ( (
		NVL( pr_old.suggested_vendor_name, 'X' ) <> NVL( pr_new.suggested_vendor_name, 'X' )
	  )OR
	  (
		NVL( pr_old.suggested_vendor_location, 'X' ) <> NVL( pr_new.suggested_vendor_location, 'X' )
	  )
	)  Then --pramasub end FP

  Delete From JAI_PO_REQ_LINE_TAXES
  Where  Requisition_Line_Id = v_line_id;

 jai_cmn_tax_defaultation_pkg.JA_IN_VENDOR_DEFAULT_TAXES( v_dest_org_id, v_vendor_id, /*rchandan for bug# replaced NVL(v_org_id,0) with v_dest_org_id*/ --pramasub FP
                                           v_site_id, v_inventory_item_id, v_header_id,
                           v_line_id, v_tax_category_id );

 IF v_type_lookup_code = 'INTERNAL' THEN
    v_src_org_id := -1*v_src_org_id;
 END IF;

 jai_cmn_tax_defaultation_pkg.JA_IN_CALC_PREC_TAXES( 'PO_REQN', v_tax_category_id, v_header_id,
    v_line_id, v_assessable_value, v_line_amount, v_inventory_item_id,
    v_quantity , v_uom_code, v_vendor_id, NVL( v_currency, v_hdr_curr ),
    conv_rate, v_creation_date, v_created_by, v_last_update_date,
    v_last_updated_by, v_last_update_login, v_src_org_id,p_vat_assessable_value => ln_vat_assess_value );     -- Ravi for VAT

     /*UPDATE JAI_PO_REQ_LINES
        SET Last_Update_Date  = pr_new.last_update_date,
            Last_Updated_By   = pr_new.last_updated_by,
            Last_Update_Login = pr_new.last_update_login
      WHERE Requisition_Line_Id   =  v_line_id
        AND Requisition_Header_Id =  v_header_id;*/ --pramasub commented for FP
--pramasub FP start 115.10
ELSIF v_tax_flag = 'N' THEN /*5852041*/
			Delete From JAI_PO_REQ_LINE_TAXES --Ja_In_Reqn_Tax_Lines   pramasub FP
 	          Where  Requisition_Line_Id = v_line_id;
 IF v_blanket_hdr IS NOT NULL AND v_blanket_line IS NOT NULL THEN
		--Ja_In_Locate_Line( v_blanket_hdr, v_blanket_line, v_quantity, v_po_line_id, v_line_location_id );
		jai_po_cmn_pkg.locate_source_line( v_blanket_hdr, v_blanket_line, v_quantity, v_po_line_id,
										   v_line_location_id );
		open  c_reqn_line_id(v_line_id);
		fetch c_reqn_line_id into v_reqn_ctr;
		close c_reqn_line_id;

		if nvl(v_reqn_ctr,0) = 0  then
			 FOR rec IN  cur_bpa_tax_lines(v_po_line_id, v_line_location_id) LOOP
				INSERT INTO JAI_PO_REQ_LINE_TAXES(requisition_line_id, requisition_header_id, tax_line_no,
				precedence_1, precedence_2, precedence_3, precedence_4, precedence_5,
				precedence_6, precedence_7, precedence_8, precedence_9, precedence_10,
				tax_id, tax_rate, qty_rate, uom, tax_amount, tax_target_amount,
				tax_type, modvat_flag, vendor_id, currency,
				creation_date, created_by, last_update_date, last_updated_by, last_update_login,
				tax_category_id)
				VALUES (
				v_line_id, v_header_id, rec.lno,rec.p_1, rec.p_2, rec.p_3, rec.p_4,
				rec.p_5,rec.p_6 , rec.p_7, rec.p_8 , rec.p_9 , rec.p_10 ,
				rec.tax_id, rec.tax_rate, rec.qty_rate, rec.uom, rec.tax_amount,
				rec.tax_amount + v_line_amount,rec.tax_type, rec.modvat_flag,
				rec.vendor_id, rec.currency,v_creation_date, v_created_by, v_last_update_date,
				v_last_updated_by, v_last_update_login,rec.tax_category_id);

				--v_uom_code := rec.uom; /*commented out by srjayara for bug 6023447 */ pramasub FP 115.13
			END LOOP;
		end if;
				/*JA_IN_CAL_TAX( 'REQUISITION_BLANKET', v_line_id , v_po_line_id, v_line_location_id,
				 	                             v_quantity, v_line_amount , NVL( v_currency, v_hdr_curr ) ,
				 	                             v_assessable_value, v_assessable_value,ln_vat_assess_value, NULL, conv_rate ); -- Ravi for VAT*/

 	               /*5852041 ..commented the above and made call to ja_in_po_calc_tax*/
                jai_po_tax_pkg.calc_tax(p_type => 'REQUISITION_BLANKET',
								 p_header_id           => v_blanket_hdr,
								 p_requisition_line_id => v_line_id ,
								 P_line_id             => v_po_line_id,
								 p_line_location_id    => v_line_location_id,
								 p_line_focus_id       => NULL,
								 p_line_quantity       => v_quantity,
								 p_base_value          => v_line_amount,
								 p_line_uom_code       => v_uom_code,
								 p_tax_amount          => ln_tax_amount,
								 p_assessable_value    => v_assessable_value,
								 p_vat_assess_value    => ln_vat_assess_value,
								 p_item_id             => v_inventory_item_id,
								 p_conv_rate           => 1/conv_rate,
								 p_po_curr             => v_currency);
ELSIF v_blanket_hdr IS NULL AND v_blanket_line IS NULL THEN
	 IF v_type_lookup_code = 'PURCHASE' THEN
		jai_cmn_tax_defaultation_pkg.JA_IN_VENDOR_DEFAULT_TAXES(v_dest_org_id, v_vendor_id,
				v_site_id, v_inventory_item_id,
				v_header_id,v_line_id, v_tax_category_id);

		jai_cmn_tax_defaultation_pkg.JA_IN_CALC_PREC_TAXES('PO_REQN', v_tax_category_id, v_header_id,
				v_line_id, v_assessable_value, v_line_amount, v_inventory_item_id, v_quantity ,
				v_uom_code, v_vendor_id, NVL( v_currency, v_hdr_curr ), conv_rate,
				v_creation_date, v_created_by, v_last_update_date,
				v_last_updated_by, v_last_update_login,p_vat_assessable_value => ln_vat_assess_value);
	ELSIF v_type_lookup_code = 'INTERNAL' THEN
		jai_cmn_tax_defaultation_pkg.Ja_In_Org_Default_Taxes( v_src_org_id, v_inventory_item_id,
				v_tax_category_id );

		jai_cmn_tax_defaultation_pkg.JA_IN_CALC_PREC_TAXES('PO_REQN', v_tax_category_id, v_header_id,
				v_line_id, v_assessable_value, v_line_amount, v_inventory_item_id, v_quantity ,
				v_uom_code, NULL, NVL( v_currency, v_hdr_curr ), conv_rate,
				v_creation_date, v_created_by, v_last_update_date,
				v_last_updated_by, v_last_update_login,
				-1*v_src_org_id,p_vat_assessable_value => ln_vat_assess_value );
	END IF;
END IF;
--pramasub FP end
ELSIF v_tax_flag = 'Y' Then
     Update JAI_PO_REQ_LINE_TAXES
        Set Tax_Amount = 0
      WHERE Requisition_Header_Id = v_header_id
        AND Requisition_Line_Id   = v_line_id
        --AND Tax_Rate is Not Null;
		AND nvl(Tax_Rate,0) <> 0 and nvl(qty_rate,0) <> 0; /*5852041*/ --pramasub FP 115.10
		/*5852041*/ --pramasub FP 115.12
		IF ( NVL( pr_old.CURRENCY_CODE, 'INR' ) <> NVL( pr_new.CURRENCY_CODE,'INR' ) ) THEN

		UPDATE JAI_PO_REQ_LINE_TAXES --ja_in_reqn_tax_lines
		  SET currency              = nvl(pr_new.CURRENCY_CODE,'INR')
		WHERE requisition_header_id = v_header_id
		  AND requisition_line_id   = v_line_id;

		UPDATE JAI_PO_REQ_LINE_TAXES jrtl --ja_in_reqn_tax_lines jrtl
		  SET tax_amount = tax_amount * DECODE(nvl(pr_new.CURRENCY_CODE,'INR'),
						'INR',jai_cmn_utils_pkg.currency_conversion( v_gl_set_of_bks_id, pr_old.CURRENCY_CODE,
						pr_old.rate_date, pr_old.rate_type, pr_old.rate ),conv_rate)
		WHERE requisition_header_id = v_header_id
		  AND requisition_line_id   = v_line_id
		  AND exists ( SELECT 1
						 FROM JAI_CMN_TAXES_ALL --ja_in_tax_codes
						WHERE tax_id     = jrtl.tax_id
						  AND adhoc_flag = 'Y'
					  );

		END IF; --pramasub FP 115.12

   -- following procedure call commented and modified in the next line by Vijay Shankar for Bug# 3190872
     -- jai_po_tax_pkg.calculate_tax( 'REQUISITION', v_header_id, v_line_id, -999, -999, -999, ' ', v_line_amount, v_assessable_value, NULL, conv_rate );
     /*jai_po_tax_pkg.calculate_tax( 'REQUISITION', v_header_id, v_line_id,
      -999, -999, v_line_amount, v_uom_code,  v_line_amount,
      v_assessable_value,ln_vat_assess_value, v_inventory_item_id, conv_rate ); */-- Ravi for VAT | commented by pramasub FP

	/*rchandan for bug#5852041. Commented the above and added the call to ja_in_po_calc_tax*/ --pramasub FP
	/*jai_po_tax_pkg.calculate_tax( 'REQUISITION', v_header_id, v_line_id,
      -999, v_quantity, v_line_amount, v_uom_code,  v_line_amount,
      v_assessable_value,ln_vat_assess_value, v_inventory_item_id, conv_rate ); -- Ravi for VAT*/
	  --ja_in_po_calc_tax is FPed to jai_po_tax_pkg.calc_tax pramasub FP
	  jai_po_tax_pkg.calc_tax(p_type             => 'REQUISITION',
						p_header_id        => v_header_id,
						P_line_id          => v_line_id,
						p_line_location_id => NULL,
						p_line_focus_id    => NULL,
						p_line_quantity    => v_quantity,
						p_base_value       => v_line_amount,
						p_line_uom_code    => v_uom_code,
						p_tax_amount       => ln_tax_amount,
						p_assessable_value => v_assessable_value,
						p_vat_assess_value => ln_vat_assess_value,
						p_item_id          => v_inventory_item_id,
						p_conv_rate        => 1/conv_rate,
						p_po_curr          => v_currency,
						p_func_curr        => v_hdr_curr);

     /*UPDATE JAI_PO_REQ_LINES --pramasub FP commented out 115.10
        SET Last_Update_Date  = pr_new.last_update_date,
            Last_Updated_By   = pr_new.last_updated_by,
            Last_Update_Login = pr_new.last_update_login
      WHERE Requisition_Line_Id   =  v_line_id
        AND Requisition_Header_Id =  v_header_id;*/

END IF;
END ARU_T2 ;

  /*
  REM +======================================================================+
  REM NAME          ARU_T3
  REM
  REM DESCRIPTION   Called from trigger JAI_PO_RLA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_PO_RLA_ARU_T4
  REM
  REM +======================================================================+
  */
  PROCEDURE ARU_T3 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
	  -- Trigger used for Currency Updation.

  found       BOOLEAN;
  v_type_lookup_code  Po_Requisition_Headers_All.Type_Lookup_Code % TYPE;
  --v_row_id        Rowid;  --File.Sql.35 Cbabu      := pr_new.ROWID;
  v_vendor_id         NUMBER;
  v_site_id           NUMBER;
  v_dest_org_id       NUMBER ;  --File.Sql.35 Cbabu    := pr_new.Destination_Organization_Id;
  v_org_id        NUMBER  ;  --File.Sql.35 Cbabu   := 0;
  v_currency          VARCHAR2(15) ;  --File.Sql.35 Cbabu  := pr_new.Currency_Code;
  v_rate_type         VARCHAR2(30);  --File.Sql.35 Cbabu   := pr_new.Rate_Type;
  v_rate_date         DATE  ;  --File.Sql.35 Cbabu   := pr_new.Rate_Date;
  v_rate              NUMBER ;  --File.Sql.35 Cbabu   := pr_new.Rate;
  v_hdr_curr      VARCHAR2(15);
  v_header_id         NUMBER   ;  --File.Sql.35 Cbabu      := pr_new.requisition_header_id;
  v_line_id           NUMBER    ;  --File.Sql.35 Cbabu     := pr_new.requisition_line_id;
  v_tax_flag          VARCHAR2(1);
  v_seg_id            VARCHAR2(20);
  v_sugg_vendor_name  VARCHAR2(360);  --File.Sql.35 Cbabu   := pr_new.suggested_vendor_name; --Increased the  length 80 to 360 by JMEENA for bug#5394234
  v_sugg_vendor_loc   VARCHAR2(360);  --File.Sql.35 Cbabu   := pr_new.suggested_vendor_location; --Increased the  length 80 to 360 by JMEENA for bug#5394234
  v_inventory_item_id NUMBER      ;  --File.Sql.35 Cbabu   := pr_new.item_id;
  v_uom       VARCHAR2(30) ;  --File.Sql.35 Cbabu  := pr_new.Unit_Meas_Lookup_Code;
  v_tax_category_list VARCHAR2(30);
  v_tax_category_id   NUMBER;
  v_item_class        VARCHAR2(30);
  v_line_no           NUMBER;
  v_tax_id        NUMBER;
  v_tax_rate        NUMBER;
  v_tax_amount        NUMBER;
  v_quantity      NUMBER   ;  --File.Sql.35 Cbabu  := pr_new.Quantity;
  v_line_tax_amount   NUMBER  ;  --File.Sql.35 Cbabu   := NVL( (pr_new.quantity * pr_new.unit_price) ,0 );
  v_uom_code          VARCHAR2(3);
  v_line_amount       NUMBER  ;  --File.Sql.35 Cbabu   := NVL( ( pr_new.quantity * pr_new.unit_price) ,0 );
  conv_rate       NUMBER;
  v_assessable_value      NUMBER ;
  ln_vat_assess_value     NUMBER ;
  v_src_org_id        NUMBER  ;  --File.Sql.35 Cbabu       := pr_new.Source_Organization_Id;

  v_gl_set_of_bks_id  NUMBER;

  v_creation_date     DATE  ;  --File.Sql.35 Cbabu    := pr_new.Creation_Date;
  v_created_by      NUMBER  ;  --File.Sql.35 Cbabu    := pr_new.Created_By;
  v_last_update_date  DATE   ;  --File.Sql.35 Cbabu     := pr_new.Last_Update_Date;
  v_last_updated_by   NUMBER ;  --File.Sql.35 Cbabu     := pr_new.Last_Updated_By;
  v_last_update_login NUMBER ;  --File.Sql.35 Cbabu     := pr_new.Last_Update_Login;
  v_hook_value        VARCHAR2(10) ; /* rallamse bug#4479131 PADDR Elimination */

  /* Bug 5243532. Added by Lakshmi Gopalsami
   * Defined variable for implementing caching logic.
   */
  l_func_curr_det jai_plsql_cache_pkg.func_curr_details;

------------------------------------------------------------------------------------------------
CURSOR Fetch_Org_Id_Cur IS SELECT nvl(Operating_Unit,0)
               FROM   Org_Organization_Definitions
           WHERE  Organization_Id = v_dest_org_id;

Cursor bind_cur IS SELECT Segment1, Type_Lookup_Code
       FROM   Po_Requisition_Headers_All
       WHERE  Requisition_Header_Id = v_header_id;

Cursor Vend_cur(p_sugg_vendor_name IN VARCHAR2) IS SELECT vendor_id
                   FROM   po_vendors
                   WHERE  vendor_name = p_sugg_vendor_name;

Cursor site_cur(p_sugg_vendor_loc IN VARCHAR2) IS SELECT vendor_Site_Id
                  FROM   Po_vendor_Sites_All A
                  WHERE  A.vendor_Site_Code = p_sugg_vendor_loc
                   AND   A.vendor_Id        = v_vendor_id
                   AND   nvl(A.Org_Id,0)    = nvl(v_org_id,0);

Cursor tax_rate_cur(p_tax_id IN NUMBER) IS
   SELECT Tax_Rate, Tax_Amount, Uom_Code, Tax_Type
     FROM JAI_CMN_TAXES_ALL
    WHERE Tax_Id = p_tax_id;

CURSOR Fetch_Hdr_Curr_Cur IS SELECT NVL( Currency_Code, '$' )
                 FROM   Po_Requisition_Headers_V
                 WHERE  Requisition_Header_Id = v_header_id;

CURSOR Fetch_Uom_Code_Cur IS SELECT Uom_Code
             FROM   Mtl_Units_Of_Measure
             WHERE  Unit_Of_Measure = v_uom;

CURSOR Fetch_Mod_Flag_Cur IS   SELECT Tax_modIFied_Flag
           From JAI_PO_REQ_LINES
           Where Requisition_Line_Id   = v_line_id;
  BEGIN
    pv_return_code := jai_constants.successful ;
    /*------------------------------------------------------------------------------------------
 FILENAME: Ja_In_Reqn_Curr_Upd_Trg .sql

 CHANGE HISTORY:
S.No      Date          Author and Details

1.        30/11/2005    Aparajita for bug#4036241. Version#115.1

                        Introduced the call to centralized packaged procedure,
                        jai_cmn_utils_pkg.check_jai_exists to check if localization has been installed.

2.        15/03/2005    Brathod for bug#4250072 , Version#115.2
                        Modified the trigger for VAT implementation (vat assessable value)

3.        08-Jun-2005   This Object is Modified to refer to New DB Entry names in place of Old
                        DB as required for CASE COMPLAINCE. Version 116.1

4. 13-Jun-2005    File Version: 116.2
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done

5  06-Jul-2005    rallamse for bug# PADDR Elimination
                  1. Replaced call to jai_po_cmn_pkg.query_locator_for_line with
                     jai_cmn_hook_pkg.Po_Requisition_Lines_All

6 04-Aug-2005     P1 Build Issue bug# 4535701 by Ramananda. File Version 120.2
                  Commented the columns Event_Id and Line_Number.
                  These will be uncommented once PO team's po_requisition_lines_all table has these columns
7. 07-Nov-2008 JMEENA for bug#5394234
		Increased the length of variables v_sugg_vendor_name and v_sugg_vendor_loc from 80 to 360

Dependency:
----------

Sl No. Bug        Dependent on
                  Bug/Patch set    Details
-------------------------------------------------------------------------------------------------
1      4036241    4033992          Call to  jai_cmn_utils_pkg.check_jai_exists, whcih was created thru bug
                                   4033992.
                                   ja_in_util_pkg_s.sql 115.0
                                   ja_in_util_pkg_b.sql 115.0

2      4250072    4245089          All objects for VAT Implementaion
--------------------------------------------------------------------------------------------*/

--File.Sql.35 Cbabu
--v_row_id              := pr_new.ROWID;
v_dest_org_id         := pr_new.Destination_Organization_Id;
v_org_id              := 0;
v_currency            := pr_new.Currency_Code;
v_rate_type           := pr_new.Rate_Type;
v_rate_date           := pr_new.Rate_Date;
v_rate                := pr_new.Rate;
v_header_id           := pr_new.requisition_header_id;
v_line_id             := pr_new.requisition_line_id;
v_sugg_vendor_name    := pr_new.suggested_vendor_name;
v_sugg_vendor_loc     := pr_new.suggested_vendor_location;
v_inventory_item_id   := pr_new.item_id;
v_uom                 := pr_new.Unit_Meas_Lookup_Code;
v_quantity            := pr_new.Quantity;
v_line_tax_amount     := NVL( (pr_new.quantity * pr_new.unit_price) ,0 );
v_line_amount         := NVL( ( pr_new.quantity * pr_new.unit_price) ,0 );
v_src_org_id          := pr_new.Source_Organization_Id;
v_creation_date       := pr_new.Creation_Date;
v_created_by          := pr_new.Created_By;
v_last_update_date    := pr_new.Last_Update_Date;
v_last_updated_by     := pr_new.Last_Updated_By;
v_last_update_login   := pr_new.Last_Update_Login;


--if
--  jai_cmn_utils_pkg.check_jai_exists (p_calling_object   => 'JA_IN_REQN_CURR_UPD_TRG',
--                               p_org_id           =>  pr_new.org_id)

--  =
--  FALSE
--then
  /* India Localization funtionality is not required */
--  return;
--end if;


 --jai_po_cmn_pkg.query_locator_for_line( v_header_id, 'JAINREQN', found );
 v_hook_value          := 'TRUE'; /* rallamse bug#4479131 PADDR Elimination */
 /* If v_hook_value is TRUE, then it means taxes should be defaulted. IF FALSE then return */
 v_hook_value := jai_cmn_hook_pkg.Po_Requisition_Lines_All
                (
                  pr_new.REQUISITION_LINE_ID,
                  pr_new.REQUISITION_HEADER_ID,
                  pr_new.LINE_NUM,
                  pr_new.LINE_TYPE_ID,
                  pr_new.CATEGORY_ID,
                  pr_new.ITEM_DESCRIPTION,
                  pr_new.UNIT_MEAS_LOOKUP_CODE,
                  pr_new.UNIT_PRICE,
                  pr_new.QUANTITY,
                  pr_new.DELIVER_TO_LOCATION_ID,
                  pr_new.TO_PERSON_ID,
                  pr_new.LAST_UPDATE_DATE,
                  pr_new.LAST_UPDATED_BY,
                  pr_new.SOURCE_TYPE_CODE,
                  pr_new.LAST_UPDATE_LOGIN,
                  pr_new.CREATION_DATE,
                  pr_new.CREATED_BY,
                  pr_new.ITEM_ID,
                  pr_new.ITEM_REVISION,
                  pr_new.QUANTITY_DELIVERED,
                  pr_new.SUGGESTED_BUYER_ID,
                  pr_new.ENCUMBERED_FLAG,
                  pr_new.RFQ_REQUIRED_FLAG,
                  pr_new.NEED_BY_DATE,
                  pr_new.LINE_LOCATION_ID,
                  pr_new.MODIFIED_BY_AGENT_FLAG,
                  pr_new.PARENT_REQ_LINE_ID,
                  pr_new.JUSTIFICATION,
                  pr_new.NOTE_TO_AGENT,
                  pr_new.NOTE_TO_RECEIVER,
                  pr_new.PURCHASING_AGENT_ID,
                  pr_new.DOCUMENT_TYPE_CODE,
                  pr_new.BLANKET_PO_HEADER_ID,
                  pr_new.BLANKET_PO_LINE_NUM,
                  pr_new.CURRENCY_CODE,
                  pr_new.RATE_TYPE,
                  pr_new.RATE_DATE,
                  pr_new.RATE,
                  pr_new.CURRENCY_UNIT_PRICE,
                  pr_new.SUGGESTED_VENDOR_NAME,
                  pr_new.SUGGESTED_VENDOR_LOCATION,
                  pr_new.SUGGESTED_VENDOR_CONTACT,
                  pr_new.SUGGESTED_VENDOR_PHONE,
                  pr_new.SUGGESTED_VENDOR_PRODUCT_CODE,
                  pr_new.UN_NUMBER_ID,
                  pr_new.HAZARD_CLASS_ID,
                  pr_new.MUST_USE_SUGG_VENDOR_FLAG,
                  pr_new.REFERENCE_NUM,
                  pr_new.ON_RFQ_FLAG,
                  pr_new.URGENT_FLAG,
                  pr_new.CANCEL_FLAG,
                  pr_new.SOURCE_ORGANIZATION_ID,
                  pr_new.SOURCE_SUBINVENTORY,
                  pr_new.DESTINATION_TYPE_CODE,
                  pr_new.DESTINATION_ORGANIZATION_ID,
                  pr_new.DESTINATION_SUBINVENTORY,
                  pr_new.QUANTITY_CANCELLED,
                  pr_new.CANCEL_DATE,
                  pr_new.CANCEL_REASON,
                  pr_new.CLOSED_CODE,
                  pr_new.AGENT_RETURN_NOTE,
                  pr_new.CHANGED_AFTER_RESEARCH_FLAG,
                  pr_new.VENDOR_ID,
                  pr_new.VENDOR_SITE_ID,
                  pr_new.VENDOR_CONTACT_ID,
                  pr_new.RESEARCH_AGENT_ID,
                  pr_new.ON_LINE_FLAG,
                  pr_new.WIP_ENTITY_ID,
                  pr_new.WIP_LINE_ID,
                  pr_new.WIP_REPETITIVE_SCHEDULE_ID,
                  pr_new.WIP_OPERATION_SEQ_NUM,
                  pr_new.WIP_RESOURCE_SEQ_NUM,
                  pr_new.ATTRIBUTE_CATEGORY,
                  pr_new.DESTINATION_CONTEXT,
                  pr_new.INVENTORY_SOURCE_CONTEXT,
                  pr_new.VENDOR_SOURCE_CONTEXT,
                  pr_new.ATTRIBUTE1,
                  pr_new.ATTRIBUTE2,
                  pr_new.ATTRIBUTE3,
                  pr_new.ATTRIBUTE4,
                  pr_new.ATTRIBUTE5,
                  pr_new.ATTRIBUTE6,
                  pr_new.ATTRIBUTE7,
                  pr_new.ATTRIBUTE8,
                  pr_new.ATTRIBUTE9,
                  pr_new.ATTRIBUTE10,
                  pr_new.ATTRIBUTE11,
                  pr_new.ATTRIBUTE12,
                  pr_new.ATTRIBUTE13,
                  pr_new.ATTRIBUTE14,
                  pr_new.ATTRIBUTE15,
                  pr_new.BOM_RESOURCE_ID,
                  pr_new.CLOSED_REASON,
                  pr_new.CLOSED_DATE,
                  pr_new.TRANSACTION_REASON_CODE,
                  pr_new.QUANTITY_RECEIVED,
                  pr_new.SOURCE_REQ_LINE_ID,
                  pr_new.ORG_ID,
                  pr_new.KANBAN_CARD_ID,
                  pr_new.CATALOG_TYPE,
                  pr_new.CATALOG_SOURCE,
                  pr_new.MANUFACTURER_ID,
                  pr_new.MANUFACTURER_NAME,
                  pr_new.MANUFACTURER_PART_NUMBER,
                  pr_new.REQUESTER_EMAIL,
                  pr_new.REQUESTER_FAX,
                  pr_new.REQUESTER_PHONE,
                  pr_new.UNSPSC_CODE,
                  pr_new.OTHER_CATEGORY_CODE,
                  pr_new.SUPPLIER_DUNS,
                  pr_new.TAX_STATUS_INDICATOR,
                  pr_new.PCARD_FLAG,
                  pr_new.NEW_SUPPLIER_FLAG,
                  pr_new.AUTO_RECEIVE_FLAG,
                  pr_new.TAX_USER_OVERRIDE_FLAG,
                  pr_new.TAX_CODE_ID,
                  pr_new.NOTE_TO_VENDOR,
                  pr_new.OKE_CONTRACT_VERSION_ID,
                  pr_new.OKE_CONTRACT_HEADER_ID,
                  pr_new.ITEM_SOURCE_ID,
                  pr_new.SUPPLIER_REF_NUMBER,
                  pr_new.SECONDARY_UNIT_OF_MEASURE,
                  pr_new.SECONDARY_QUANTITY,
                  pr_new.PREFERRED_GRADE,
                  pr_new.SECONDARY_QUANTITY_RECEIVED,
                  pr_new.SECONDARY_QUANTITY_CANCELLED,
                  pr_new.VMI_FLAG,
                  pr_new.AUCTION_HEADER_ID,
                  pr_new.AUCTION_DISPLAY_NUMBER,
                  pr_new.AUCTION_LINE_NUMBER,
                  pr_new.REQS_IN_POOL_FLAG,
                  pr_new.BID_NUMBER,
                  pr_new.BID_LINE_NUMBER,
                  pr_new.NONCAT_TEMPLATE_ID,
                  pr_new.SUGGESTED_VENDOR_CONTACT_FAX,
                  pr_new.SUGGESTED_VENDOR_CONTACT_EMAIL,
                  pr_new.AMOUNT,
                  pr_new.CURRENCY_AMOUNT,
                  pr_new.LABOR_REQ_LINE_ID,
                  pr_new.JOB_ID,
                  pr_new.JOB_LONG_DESCRIPTION,
                  pr_new.CONTRACTOR_STATUS,
                  pr_new.CONTACT_INFORMATION,
                  pr_new.SUGGESTED_SUPPLIER_FLAG,
                  pr_new.CANDIDATE_SCREENING_REQD_FLAG,
                  pr_new.CANDIDATE_FIRST_NAME,
                  pr_new.CANDIDATE_LAST_NAME,
                  pr_new.ASSIGNMENT_END_DATE,
                  pr_new.OVERTIME_ALLOWED_FLAG,
                  pr_new.CONTRACTOR_REQUISITION_FLAG,
                  pr_new.DROP_SHIP_FLAG,
                  pr_new.ASSIGNMENT_START_DATE,
                  pr_new.ORDER_TYPE_LOOKUP_CODE,
                  pr_new.PURCHASE_BASIS,
                  pr_new.MATCHING_BASIS,
                  pr_new.NEGOTIATED_BY_PREPARER_FLAG,
                  pr_new.SHIP_METHOD,
                  pr_new.ESTIMATED_PICKUP_DATE,
                  pr_new.SUPPLIER_NOTIFIED_FOR_CANCEL,
                  pr_new.BASE_UNIT_PRICE,
                  pr_new.AT_SOURCING_FLAG,
                  /*
                  || Commented the columns for P1 bug# 4535701.
                  || These will be uncommented once PO teams po_requisition_lines_all table has these columns
                  */
		  /* Bug4540709. Added by Lakshmig Gopalsami
		   * Reverting the fix for bug 4535701 */
                 /*  pr_new.EVENT_ID,/*following 2 cols commented by ssumaith - bug# 4616729 and added the two null towards the end /*
                  pr_new.LINE_NUMBER*/
                  null,
                  null
                ) ;

/*
  END Of POC
*/

OPEN  Fetch_Hdr_Curr_Cur;
FETCH Fetch_Hdr_Curr_Cur INTO v_hdr_curr;
CLOSE Fetch_Hdr_Curr_Cur;

--IF ( NOT FOUND ) OR ( v_hdr_curr = NVL( v_currency, v_hdr_curr ) ) THEN
IF ( v_hook_value = 'FALSE' ) OR ( v_hdr_curr = NVL( v_currency, v_hdr_curr ) ) THEN
  RETURN;
END IF;

OPEN  bind_cur;
FETCH Bind_cur INTO v_seg_id, v_type_lookup_code;
CLOSE bind_cur;

OPEN  Fetch_Org_Id_Cur;
FETCH Fetch_Org_Id_Cur INTO v_org_id;
CLOSE Fetch_Org_Id_Cur;

OPEN  Fetch_Mod_Flag_Cur;
FETCH Fetch_Mod_Flag_Cur INTO v_tax_flag;
CLOSE Fetch_Mod_Flag_Cur;

OPEN  Vend_cur(v_sugg_vendor_name);
FETCH Vend_Cur INTO v_vendor_id;
CLOSE Vend_cur;

OPEN  site_cur(v_sugg_vendor_loc);
FETCH Site_Cur INTO v_site_id;
CLOSE site_cur;

/* Bug 5243532. Added by Lakshmi Gopalsami
 * Removed the cursor Fetch_Book_Id_Cur
 * and implemented using caching logic.
 */
l_func_curr_det       := jai_plsql_cache_pkg.return_sob_curr
                          (p_org_id  => v_dest_org_id );
v_gl_set_of_bks_id    := l_func_curr_det.ledger_id;


OPEN  Fetch_Uom_Code_Cur;
FETCH Fetch_Uom_Code_Cur INTO v_uom_code;
CLOSE Fetch_Uom_Code_Cur;

IF v_currency = v_hdr_curr THEN
   conv_rate := 1;
ELSE
   IF v_rate_type = 'User' THEN
      conv_rate := 1/v_rate;
   ELSE
      conv_rate := jai_cmn_utils_pkg.currency_conversion( v_gl_set_of_bks_id, v_currency, v_rate_date, v_rate_type, v_rate );
   END IF;
END IF;

v_assessable_value := jai_cmn_setup_pkg.get_po_assessable_value( v_vendor_id, v_site_id,
                    v_inventory_item_id, v_uom_code );

v_line_amount := v_line_amount * conv_rate;

IF NVL( v_assessable_value, 0 ) <= 0 THEN
     v_assessable_value := v_line_amount;
ELSE
     v_assessable_value := v_assessable_value * v_quantity * conv_rate;
END IF;


ln_vat_assess_value :=  jai_general_pkg.ja_in_vat_assessable_value
                                    ( p_party_id => v_vendor_id,
                                      p_party_site_id => v_site_id,
                                      p_inventory_item_id => v_inventory_item_id,
                                      p_uom_code => v_uom_code,
                                      p_default_price => 0,
                                      p_ass_value_date => SYSDATE,
                                      p_party_type => 'V'
                                     ) ;
IF  ln_vat_assess_value = 0 THEN
  ln_vat_assess_value :=  v_line_amount ;
ELSE
  ln_vat_assess_value := ln_vat_assess_value  * v_quantity * conv_rate;
END IF;

IF v_tax_flag = 'N' THEN

  Delete From JAI_PO_REQ_LINE_TAXES
  Where  Requisition_Line_Id = v_line_id;

  jai_cmn_tax_defaultation_pkg.Ja_In_vendor_Default_Taxes( nvl(v_org_id,0),
                                            v_vendor_id, v_site_id,
                                            v_inventory_item_id, v_header_id, v_line_id,
                                            v_tax_category_id );
  IF v_type_lookup_code <> 'INTERNAL' THEN
     v_src_org_id := 0;
  ELSE
     v_src_org_id := -1 * v_src_org_id;
  END IF;

  jai_cmn_tax_defaultation_pkg.Ja_In_Calc_Prec_Taxes( 'PO_REQN', v_tax_category_id, v_header_id, v_line_id,
                                        v_assessable_value, v_line_amount, v_inventory_item_id,
                v_quantity , v_uom_code, v_vendor_id, NVL( v_currency, v_hdr_curr ),
                                        conv_rate, v_creation_date, v_created_by, v_last_update_date,
                        v_last_updated_by, v_last_update_login, v_src_org_id, ln_vat_assess_value );

     UPDATE JAI_PO_REQ_LINES
        SET Last_Update_Date  = pr_new.last_update_date,
            Last_Updated_By   = pr_new.last_updated_by,
            Last_Update_Login = pr_new.last_update_login
      WHERE Requisition_Line_Id   =  v_line_id
        AND Requisition_Header_Id =  v_header_id;

ELSIF v_tax_flag = 'Y' THEN
     Update JAI_PO_REQ_LINE_TAXES
        Set Tax_Amount = 0
      WHERE Requisition_Header_Id = v_header_id
        AND Requisition_Line_Id   = v_line_id
        AND Currency = NVL( v_currency, v_hdr_curr )
        AND Tax_Rate is Not Null;
     jai_po_tax_pkg.calculate_tax( 'REQUISITION', v_header_id, v_line_id, -999, -999, -999, ' ', v_line_tax_amount, v_assessable_value,
                     ln_vat_assess_value, NULL, conv_rate );
     UPDATE JAI_PO_REQ_LINES
        SET Last_Update_Date  = pr_new.last_update_date,
            Last_Updated_By   = pr_new.last_updated_by,
            Last_Update_Login = pr_new.last_update_login
      WHERE Requisition_Line_Id   =  v_line_id
        AND Requisition_Header_Id =  v_header_id;
END IF;
  END ARU_T3 ;

END JAI_PO_RLA_TRIGGER_PKG ;

/
