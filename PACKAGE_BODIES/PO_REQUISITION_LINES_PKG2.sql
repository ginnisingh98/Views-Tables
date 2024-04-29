--------------------------------------------------------
--  DDL for Package Body PO_REQUISITION_LINES_PKG2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQUISITION_LINES_PKG2" as
/* $Header: POXRIL3B.pls 120.3.12010000.2 2008/09/22 18:13:38 rohbansa ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Requisition_Line_Id     IN OUT NOCOPY NUMBER,
                       X_Requisition_Header_Id          NUMBER,
                       X_Line_Num                       NUMBER,
                       X_Line_Type_Id                   NUMBER,
                       X_Category_Id                    NUMBER,
                       X_Item_Description               VARCHAR2,
                       X_Unit_Meas_Lookup_Code          VARCHAR2,
                       X_Unit_Price                     NUMBER,
                       X_Base_Unit_Price                NUMBER, -- <FPJ Advanced Price>
                       X_Quantity                       NUMBER,
                       X_Amount                       NUMBER, -- <SERVICES FPJ>
                       X_Deliver_To_Location_Id         NUMBER,
                       X_To_Person_Id                   NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Source_Type_Code               VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Item_Id                        NUMBER,
                       X_Item_Revision                  VARCHAR2,
                       X_Quantity_Delivered             NUMBER,
                       X_Suggested_Buyer_Id             NUMBER,
                       X_Encumbered_Flag                VARCHAR2,
                       X_Rfq_Required_Flag              VARCHAR2,
                       X_Need_By_Date                   DATE,
                       X_Line_Location_Id               NUMBER,
                       X_Modified_By_Agent_Flag         VARCHAR2,
                       X_Parent_Req_Line_Id             NUMBER,
                       X_Justification                  VARCHAR2,
                       X_Note_To_Agent                  VARCHAR2,
                       X_Note_To_Receiver               VARCHAR2,
                       X_Purchasing_Agent_Id            NUMBER,
                       X_Document_Type_Code             VARCHAR2,
                       X_Blanket_Po_Header_Id           NUMBER,
                       X_Blanket_Po_Line_Num            NUMBER,
                       X_Currency_Code                  VARCHAR2,
                       X_Rate_Type                      VARCHAR2,
                       X_Rate_Date                      DATE,
                       X_Rate                           NUMBER,
                       X_Currency_Unit_Price            NUMBER,
                       X_Currency_Amount              NUMBER, -- <SERVICES FPJ>
                       X_Suggested_Vendor_Name          VARCHAR2,
                       X_Suggested_Vendor_Location      VARCHAR2,
                       X_Suggested_Vendor_Contact       VARCHAR2,
                       X_Suggested_Vendor_Phone         VARCHAR2,
                       X_Sugg_Vendor_Product_Code   	VARCHAR2,
                       X_Un_Number_Id                   NUMBER,
                       X_Hazard_Class_Id                NUMBER,
                       X_Must_Use_Sugg_Vendor_Flag      VARCHAR2,
                       X_Reference_Num                  VARCHAR2,
                       X_On_Rfq_Flag                    VARCHAR2,
                       X_Urgent_Flag                    VARCHAR2,
                       X_Cancel_Flag                    VARCHAR2,
                       X_Source_Organization_Id         NUMBER,
                       X_Source_Subinventory            VARCHAR2,
                       X_Destination_Type_Code          VARCHAR2,
                       X_Destination_Organization_Id    NUMBER,
                       X_Destination_Subinventory       VARCHAR2,
                       X_Quantity_Cancelled             NUMBER,
                       X_Cancel_Date                    DATE,
                       X_Cancel_Reason                  VARCHAR2,
                       X_Closed_Code                    VARCHAR2,
                       X_Agent_Return_Note              VARCHAR2,
                       X_Changed_After_Research_Flag    VARCHAR2,
                       X_Vendor_Id                      NUMBER,
                       X_Vendor_Site_Id                 NUMBER,
                       X_Vendor_Contact_Id              NUMBER,
                       X_Research_Agent_Id              NUMBER,
                       X_On_Line_Flag                   VARCHAR2,
                       X_Wip_Entity_Id                  NUMBER,
                       X_Wip_Line_Id                    NUMBER,
                       X_Wip_Repetitive_Schedule_Id     NUMBER,
                       X_Wip_Operation_Seq_Num          NUMBER,
                       X_Wip_Resource_Seq_Num           NUMBER,
                       X_Attribute_Category             VARCHAR2,
                       X_Destination_Context            VARCHAR2,
                       X_Inventory_Source_Context       VARCHAR2,
                       X_Vendor_Source_Context          VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Bom_Resource_Id                NUMBER,
                       X_Ussgl_Transaction_Code         VARCHAR2,
                       X_Government_Context             VARCHAR2,
                       X_Closed_Reason                  VARCHAR2,
                       X_Closed_Date                    DATE,
                       X_Transaction_Reason_Code        VARCHAR2,
                       X_Quantity_Received              NUMBER,
		       X_Tax_Code_Id			NUMBER,
		       X_Tax_User_Override_Flag		VARCHAR2,
		       X_transferred_to_oe_flag     OUT NOCOPY VARCHAR2,
		       --togeorge 10/03/2000
		       -- added oke columns
		       X_oke_contract_header_id	   	NUMBER default null,
	               X_oke_contract_version_id  	NUMBER default null,
-- MC bug# 1548597.. Add 3 process related columns.unit_of_measure,quantity and grade.
-- start of 1548597
                       X_Secondary_Unit_Of_Measure      VARCHAR2 default null,
                       X_Secondary_Quantity             NUMBER default null,
		       X_Preferred_Grade                VARCHAR2 default null,
-- end of 1548597
		       X_order_type_lookup_code         VARCHAR2 default null,  -- <SERVICES FPJ>
		       X_purchase_basis                 VARCHAR2 default null,  -- <SERVICES FPJ>
		       X_matching_basis                 VARCHAR2 default null,  -- <SERVICES FPJ>

                       -- Bug #3161499
                       p_negotiated_by_preparer_flag    in     VARCHAR2    DEFAULT  NULL,   --<DBI FPJ>
                       p_org_id                         IN     NUMBER      DEFAULT  NULL   -- <R12 MOAC>
   ) IS
     CURSOR C IS SELECT rowid FROM PO_REQUISITION_LINES
                 WHERE requisition_line_id = X_Requisition_Line_Id;

      CURSOR C2 IS SELECT po_requisition_lines_s.nextval FROM sys.dual;

     --<REQINPOOL> begin
     x_reqs_in_pool_flag PO_REQUISITION_LINES_ALL.REQS_IN_POOL_FLAG%TYPE;
     x_auth_status    PO_REQUISITION_HEADERS_ALL.AUTHORIZATION_STATUS%TYPE;
     x_contractor_status PO_REQUISITION_HEADERS_ALL.CONTRACTOR_STATUS%TYPE;
     x_progress      VARCHAR2(3) := NULL;
     x_return_status VARCHAR2(1);

      l_manufacturer_id         po_requisition_lines_All.MANUFACTURER_ID%TYPE;
    l_manufacturer_name       PO_ATTRIBUTE_VALUES_TLP.manufacturer%TYPE;
    l_manufacturer_pn         PO_ATTRIBUTE_VALUES.manufacturer_part_num%TYPE;
    l_lead_time               PO_ATTRIBUTE_VALUES.lead_time%TYPE;

    BEGIN
      if (X_Requisition_Line_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Requisition_Line_Id;
        CLOSE C2;
      end if;

    x_progress := '010';

       --<REQINPOOL> Begin: determine what the value of reqs_in_pool_flag
       --should be based on the other parameters
       BEGIN

	 x_progress := '011';

         SELECT prh.authorization_status
	      , prh.contractor_status
	   INTO x_auth_status
	      , x_contractor_status
	   FROM po_requisition_headers_all prh
	  WHERE prh.requisition_header_id = X_Requisition_Header_Id;

	 x_progress := '012';

         IF (    NVL(X_Cancel_Flag,'N')                     =  'N'
	     AND NVL(X_Closed_Code,'OPEN')                  <> 'FINALLY CLOSED'
	     AND NVL(X_Modified_By_Agent_Flag,'N')          =  'N'
	     AND X_Source_Type_Code                         <> 'INVENTORY'
	     AND X_Line_Location_Id                         IS NULL
	     AND NVL(x_auth_status,'INCOMPLETE')            =  'APPROVED'
	     AND NVL(x_contractor_status,'NOT_APPLICABLE')  <> 'PENDING'
	     )
	 THEN
	   x_reqs_in_pool_flag := 'Y';
	 ELSE
	   x_reqs_in_pool_flag := NULL;
	 END IF;

	 x_progress := '013';

	EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	    x_reqs_in_pool_flag := NULL;
	END;
        --<REQINPOOL> End

 IF  (x_item_id IS NOT NULL) Then
               po_attribute_values_pvt.get_item_attributes_values(X_Item_Id, l_manufacturer_pn,l_manufacturer_name,
                                          l_lead_time,l_manufacturer_id) ;

	        END IF ;

       INSERT INTO PO_REQUISITION_LINES(
               requisition_line_id,
               requisition_header_id,
               line_num,
               line_type_id,
               category_id,
               item_description,
               unit_meas_lookup_code,
               unit_price,
               base_unit_price, -- <FPJ Advanced Price>
               quantity,
               amount,                                        -- <SERVICES FPJ>
               deliver_to_location_id,
               to_person_id,
               last_update_date,
               last_updated_by,
               source_type_code,
               last_update_login,
               creation_date,
               created_by,
               item_id,
               item_revision,
               quantity_delivered,
               suggested_buyer_id,
               encumbered_flag,
               rfq_required_flag,
               need_by_date,
               line_location_id,
               modified_by_agent_flag,
               parent_req_line_id,
               justification,
               note_to_agent,
               note_to_receiver,
               purchasing_agent_id,
               document_type_code,
               blanket_po_header_id,
               blanket_po_line_num,
               currency_code,
               rate_type,
               rate_date,
               rate,
               currency_unit_price,
               currency_amount,                               -- <SERVICES FPJ>
               suggested_vendor_name,
               suggested_vendor_location,
               suggested_vendor_contact,
               suggested_vendor_phone,
               suggested_vendor_product_code,
               un_number_id,
               hazard_class_id,
               must_use_sugg_vendor_flag,
               reference_num,
               on_rfq_flag,
               urgent_flag,
               cancel_flag,
               source_organization_id,
               source_subinventory,
               destination_type_code,
               destination_organization_id,
               destination_subinventory,
               quantity_cancelled,
               cancel_date,
               cancel_reason,
               closed_code,
               agent_return_note,
               changed_after_research_flag,
               vendor_id,
               vendor_site_id,
               vendor_contact_id,
               research_agent_id,
               on_line_flag,
               wip_entity_id,
               wip_line_id,
               wip_repetitive_schedule_id,
               wip_operation_seq_num,
               wip_resource_seq_num,
               attribute_category,
               destination_context,
               inventory_source_context,
               vendor_source_context,
               attribute1,
               attribute2,
               attribute3,
               attribute4,
               attribute5,
               attribute6,
               attribute7,
               attribute8,
               attribute9,
               attribute10,
               attribute11,
               attribute12,
               attribute13,
               attribute14,
               attribute15,
               bom_resource_id,
               government_context,
               closed_reason,
               closed_date,
               transaction_reason_code,
               quantity_received,
	       tax_code_id,
	       tax_user_override_flag,
	       --togeorge 10/03/2000
	       -- added oke columns
	       oke_contract_header_id,
	       oke_contract_version_id,
-- start of 1548597
               secondary_unit_of_measure,
               secondary_quantity,
               preferred_grade,
-- end of 1548597
               order_type_lookup_code,  -- <SERVICES FPJ>
               purchase_basis,          -- <SERVICES FPJ>
               matching_basis,          -- <SERVICES FPJ>
               negotiated_by_preparer_flag, -- <DBI FPJ> 3161499
	       reqs_in_pool_flag,        -- <REQINPOOL>
               Org_Id,                   -- <R12 MOAC>
               tax_attribute_update_code, --<eTax Integration R12>
	       MANUFACTURER_ID,            --bug 7387487
                   MANUFACTURER_NAME,
                   MANUFACTURER_PART_NUMBER

             ) VALUES (
               X_Requisition_Line_Id,
               X_Requisition_Header_Id,
               X_Line_Num,
               X_Line_Type_Id,
               X_Category_Id,
               X_Item_Description,
               X_Unit_Meas_Lookup_Code,
               X_Unit_Price,
               X_Base_Unit_Price,	-- <FPJ Advanced Price>
               X_Quantity,
               X_Amount,                                      -- <SERVICES FPJ>
               X_Deliver_To_Location_Id,
               X_To_Person_Id,
               X_Last_Update_Date,
               X_Last_Updated_By,
               X_Source_Type_Code,
               X_Last_Update_Login,
               X_Creation_Date,
               X_Created_By,
               X_Item_Id,
               X_Item_Revision,
               X_Quantity_Delivered,
               X_Suggested_Buyer_Id,
               X_Encumbered_Flag,
               nvl(X_Rfq_Required_Flag, 'N'),
               X_Need_By_Date,
               X_Line_Location_Id,
               X_Modified_By_Agent_Flag,
               X_Parent_Req_Line_Id,
               X_Justification,
               X_Note_To_Agent,
               X_Note_To_Receiver,
               X_Purchasing_Agent_Id,
               X_Document_Type_Code,
               X_Blanket_Po_Header_Id,
               X_Blanket_Po_Line_Num,
               X_Currency_Code,
               X_Rate_Type,
               X_Rate_Date,
               X_Rate,
               X_Currency_Unit_Price,
               X_Currency_Amount,                             -- <SERVICES FPJ>
               X_Suggested_Vendor_Name,
               X_Suggested_Vendor_Location,
               X_Suggested_Vendor_Contact,
               X_Suggested_Vendor_Phone,
               X_Sugg_Vendor_Product_Code,
               X_Un_Number_Id,
               X_Hazard_Class_Id,
               X_Must_Use_Sugg_Vendor_Flag,
               X_Reference_Num,
               X_On_Rfq_Flag,
               X_Urgent_Flag,
               X_Cancel_Flag,
               X_Source_Organization_Id,
               X_Source_Subinventory,
               X_Destination_Type_Code,
               X_Destination_Organization_Id,
               X_Destination_Subinventory,
               X_Quantity_Cancelled,
               X_Cancel_Date,
               X_Cancel_Reason,
               X_Closed_Code,
               X_Agent_Return_Note,
               X_Changed_After_Research_Flag,
               X_Vendor_Id,
               X_Vendor_Site_Id,
               X_Vendor_Contact_Id,
               X_Research_Agent_Id,
               X_On_Line_Flag,
               X_Wip_Entity_Id,
               X_Wip_Line_Id,
               X_Wip_Repetitive_Schedule_Id,
               X_Wip_Operation_Seq_Num,
               X_Wip_Resource_Seq_Num,
               X_Attribute_Category,
               X_Destination_Context,
               X_Inventory_Source_Context,
               X_Vendor_Source_Context,
               X_Attribute1,
               X_Attribute2,
               X_Attribute3,
               X_Attribute4,
               X_Attribute5,
               X_Attribute6,
               X_Attribute7,
               X_Attribute8,
               X_Attribute9,
               X_Attribute10,
               X_Attribute11,
               X_Attribute12,
               X_Attribute13,
               X_Attribute14,
               X_Attribute15,
               X_Bom_Resource_Id,
               X_Government_Context,
               X_Closed_Reason,
               X_Closed_Date,
               X_Transaction_Reason_Code,
               X_Quantity_Received,
	       X_tax_code_id,
	       X_Tax_User_Override_Flag,
	       --togeorge 10/03/2000
	       -- added oke columns
	       X_oke_contract_header_id,
	       X_oke_contract_version_id,
-- start of 1548597
               X_secondary_unit_of_measure,
               X_secondary_quantity,
               X_preferred_grade,
-- end of 1548597
               X_order_type_lookup_code,  -- <SERVICES FPJ>
               X_purchase_basis,          -- <SERVICES FPJ>
               X_matching_basis,          -- <SERVICES FPJ>
               p_negotiated_by_preparer_flag, -- <DBI FPJ>
	       x_reqs_in_pool_flag,        --<REQINPOOL>
               p_org_id,                  -- <R12 MOAC>
              'CREATE' ,   --<eTax Integration R12>
	       l_manufacturer_id,
    l_manufacturer_name,
    l_manufacturer_pn

             );

    x_progress := '020';

    --togeorge 10/26/2000 commented out due to arcs in problems
    --dbms_output.put_line ('Before call to update_transferred...');

    po_req_lines_sv.update_transferred_to_oe_flag (X_requisition_header_id,
						 X_transferred_to_oe_flag);

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;

  EXCEPTION
    WHEN OTHERS then
      po_message_s.sql_error('INSERT_ROW',x_progress,sqlcode);
      raise;

  END Insert_Row;


END PO_REQUISITION_LINES_PKG2;

/
