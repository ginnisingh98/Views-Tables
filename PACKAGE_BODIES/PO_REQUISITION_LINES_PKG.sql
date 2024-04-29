--------------------------------------------------------
--  DDL for Package Body PO_REQUISITION_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQUISITION_LINES_PKG" as
/* $Header: POXRIL1B.pls 120.6.12010000.2 2012/07/26 10:24:09 rkandima ship $ */


  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Requisition_Line_Id            NUMBER,
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
                       X_Sugg_Vendor_Product_Code  	VARCHAR2,
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
                       X_transferred_to_oe_flag         OUT NOCOPY VARCHAR2,
                       X_update_dist_quantity           VARCHAR2,
                       X_Tax_Code_Id                    NUMBER,
                       X_Tax_User_Override_Flag         VARCHAR2,
                       --togeorge 10/03/2000
                       -- added oke columns
                       x_oke_contract_header_id         NUMBER default null,
                       x_oke_contract_version_id        NUMBER default null,
-- MC bug# 1548597.. Add 3 process related columns.unit_of_measure,quantity and grade.
-- start of 1548597
                       X_Secondary_Unit_Of_Measure      VARCHAR2 default null,
                       X_Secondary_Quantity             NUMBER default null,
                       X_Preferred_Grade                VARCHAR2 default null
-- end of 1548597
 ) IS

 x_progress      VARCHAR2(3) := NULL;
 x_return_status VARCHAR2(1);
 BEGIN

   x_progress := '010';


   UPDATE PO_REQUISITION_LINES
   SET
     requisition_line_id               =     X_Requisition_Line_Id,
     requisition_header_id             =     X_Requisition_Header_Id,
     line_num                          =     X_Line_Num,
     line_type_id                      =     X_Line_Type_Id,
     category_id                       =     X_Category_Id,
     item_description                  =     X_Item_Description,
     unit_meas_lookup_code             =     X_Unit_Meas_Lookup_Code,
     unit_price                        =     X_Unit_Price,
     base_unit_price                   =     X_Base_Unit_Price, -- <FPJ Advanced Price>
     quantity                          =     X_Quantity,
     amount                            =     X_Amount,        -- <SERVICES FPJ>
     deliver_to_location_id            =     X_Deliver_To_Location_Id,
     to_person_id                      =     X_To_Person_Id,
     last_update_date                  =     X_Last_Update_Date,
     last_updated_by                   =     X_Last_Updated_By,
     source_type_code                  =     X_Source_Type_Code,
     last_update_login                 =     X_Last_Update_Login,
     item_id                           =     X_Item_Id,
     item_revision                     =     X_Item_Revision,
     quantity_delivered                =     X_Quantity_Delivered,
     suggested_buyer_id                =     X_Suggested_Buyer_Id,
     encumbered_flag                   =     X_Encumbered_Flag,
     rfq_required_flag                 =     X_Rfq_Required_Flag,
     need_by_date                      =     X_Need_By_Date,
     line_location_id                  =     X_Line_Location_Id,
     modified_by_agent_flag            =     X_Modified_By_Agent_Flag,
     parent_req_line_id                =     X_Parent_Req_Line_Id,
     justification                     =     X_Justification,
     note_to_agent                     =     X_Note_To_Agent,
     note_to_receiver                  =     X_Note_To_Receiver,
     purchasing_agent_id               =     X_Purchasing_Agent_Id,
     document_type_code                =     X_Document_Type_Code,
     blanket_po_header_id              =     X_Blanket_Po_Header_Id,
     blanket_po_line_num               =     X_Blanket_Po_Line_Num,
     currency_code                     =     X_Currency_Code,
     rate_type                         =     X_Rate_Type,
     rate_date                         =     X_Rate_Date,
     rate                              =     X_Rate,
     currency_unit_price               =     X_Currency_Unit_Price,
     currency_amount                   =     X_Currency_Amount,     -- <SERVICES FPJ>
     suggested_vendor_name             =     X_Suggested_Vendor_Name,
     suggested_vendor_location         =     X_Suggested_Vendor_Location,
     suggested_vendor_contact          =     X_Suggested_Vendor_Contact,
     suggested_vendor_phone            =     X_Suggested_Vendor_Phone,
     suggested_vendor_product_code     =     X_Sugg_Vendor_Product_Code,
     un_number_id                      =     X_Un_Number_Id,
     hazard_class_id                   =     X_Hazard_Class_Id,
     must_use_sugg_vendor_flag         =     X_Must_Use_Sugg_Vendor_Flag,
     reference_num                     =     X_Reference_Num,
     on_rfq_flag                       =     X_On_Rfq_Flag,
     urgent_flag                       =     X_Urgent_Flag,
     cancel_flag                       =     X_Cancel_Flag,
     source_organization_id            =     X_Source_Organization_Id,
     source_subinventory               =     X_Source_Subinventory,
     destination_type_code             =     X_Destination_Type_Code,
     destination_organization_id       =     X_Destination_Organization_Id,
     destination_subinventory          =     X_Destination_Subinventory,
     quantity_cancelled                =     X_Quantity_Cancelled,
     cancel_date                       =     X_Cancel_Date,
     cancel_reason                     =     X_Cancel_Reason,
     closed_code                       =     X_Closed_Code,
     agent_return_note                 =     X_Agent_Return_Note,
     changed_after_research_flag       =     X_Changed_After_Research_Flag,
     vendor_id                         =     X_Vendor_Id,
     vendor_site_id                    =     X_Vendor_Site_Id,
     vendor_contact_id                 =     X_Vendor_Contact_Id,
     research_agent_id                 =     X_Research_Agent_Id,
     on_line_flag                      =     X_On_Line_Flag,
     wip_entity_id                     =     X_Wip_Entity_Id,
     wip_line_id                       =     X_Wip_Line_Id,
     wip_repetitive_schedule_id        =     X_Wip_Repetitive_Schedule_Id,
     wip_operation_seq_num             =     X_Wip_Operation_Seq_Num,
     wip_resource_seq_num              =     X_Wip_Resource_Seq_Num,
     attribute_category                =     X_Attribute_Category,
     destination_context               =     X_Destination_Context,
     inventory_source_context          =     X_Inventory_Source_Context,
     vendor_source_context             =     X_Vendor_Source_Context,
     attribute1                        =     X_Attribute1,
     attribute2                        =     X_Attribute2,
     attribute3                        =     X_Attribute3,
     attribute4                        =     X_Attribute4,
     attribute5                        =     X_Attribute5,
     attribute6                        =     X_Attribute6,
     attribute7                        =     X_Attribute7,
     attribute8                        =     X_Attribute8,
     attribute9                        =     X_Attribute9,
     attribute10                       =     X_Attribute10,
     attribute11                       =     X_Attribute11,
     attribute12                       =     X_Attribute12,
     attribute13                       =     X_Attribute13,
     attribute14                       =     X_Attribute14,
     attribute15                       =     X_Attribute15,
     bom_resource_id                   =     X_Bom_Resource_Id,
     government_context                =     X_Government_Context,
     closed_reason                     =     X_Closed_Reason,
     closed_date                       =     X_Closed_Date,
     transaction_reason_code           =     X_Transaction_Reason_Code,
     quantity_received                 =     X_Quantity_Received,
     --togeorge 10/03/2000
     -- added oke columns
     oke_contract_header_id            =     x_oke_contract_header_id,
     oke_contract_version_id           =     x_oke_contract_version_id,
-- start of 1548597
     secondary_unit_of_measure         =     X_Secondary_Unit_Of_Measure,
     secondary_quantity                =     X_Secondary_Quantity,
     preferred_grade                   =     X_Preferred_Grade,
-- end of 1548597
     tax_attribute_update_code         =     NVL(tax_attribute_update_code, 'UPDATE')  --<eTax Integration R12>
   WHERE rowid = X_rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;


    x_progress := '020';
    --dbms_output.put_line ('Before call to update_transferred...');

    po_req_lines_sv.update_transferred_to_oe_flag (X_requisition_header_id,
						 X_transferred_to_oe_flag);

    x_progress := '030';

   --Fix bug14350660, comment out this code, move below call to the
   --calling procedure (POXRILNS.pld)po_req_lns_th1.update_row

    /*if (x_update_dist_quantity = 'Y') then

      po_req_dist_sv1.update_dist_quantity (x_requisition_line_id,
					    x_quantity);
    end if;*/

   --bug 14350660 end

    x_progress := '040';

    -- begin <REQINPOOL>
    -- bug 4931033 - incorrect parameters were passed
    -- pass in x_requisition_header_id as well as it is available
    po_req_lines_sv.update_reqs_in_pool_flag(x_req_line_id => x_requisition_line_id,
                                             x_req_header_id => x_requisition_header_id,
                                             x_return_status => x_return_status);

    -- end <REQINPOOL>

    x_progress := '050';

  EXCEPTION
    WHEN OTHERS then
      po_message_s.sql_error('UPDATE_ROW',x_progress,sqlcode);
  END Update_Row;



PROCEDURE check_unique (X_rowid		VARCHAR2,
			X_line_num	VARCHAR2,
			X_req_header_id   NUMBER) IS

x_progress VARCHAR2(3) := NULL;
dummy	   NUMBER;

BEGIN

  x_progress := '010';

  SELECT  1
  INTO    dummy
  FROM    DUAL
  WHERE  not exists (SELECT 1
		     FROM   po_requisition_lines
		     WHERE  line_num  = X_line_num
		     AND    requisition_header_id = X_req_header_id
		     AND    ((x_rowid is null) or (rowid <> x_rowid))
		    );

EXCEPTION
 WHEN NO_DATA_FOUND THEN
  po_message_s.app_error('PO_RQ_LINE_NUM_ALREADY_EXISTS');

END  check_unique;



END PO_REQUISITION_LINES_PKG;

/
