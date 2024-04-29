--------------------------------------------------------
--  DDL for Package PO_REQUISITION_LINES_PKG2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQUISITION_LINES_PKG2" AUTHID CURRENT_USER as
/* $Header: POXRIL3S.pls 120.0 2005/06/01 14:58:04 appldev noship $ */


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
		       X_transferred_to_oe_flag    OUT NOCOPY  VARCHAR2,
		       --togeorge 10/03/2000
		       -- added oke columns
		       x_oke_contract_header_id	   	NUMBER default null,
	               x_oke_contract_version_id  	NUMBER default null,
-- MC bug# 1548597.. Add 3 process related columns.unit_of_measure,quantity and grade.
-- start of 1548597
                       X_Secondary_Unit_Of_Measure      VARCHAR2 default null,
                       X_Secondary_Quantity             NUMBER default null,
                       X_Preferred_Grade                VARCHAR2 default null,
-- end of 1548597
                       X_order_type_lookup_code         VARCHAR2 default null,  -- <SERVICES FPJ>
                       X_purchase_basis                 VARCHAR2 default null,  -- <SERVICES FPJ>
                       X_matching_basis                 VARCHAR2 default null,  -- <SERVICES FPJ

                       p_negotiated_by_preparer_flag    in     VARCHAR2  DEFAULT  NULL,   --<DBI FPJ>
                       p_org_id                         IN     NUMBER    DEFAULT  NULL   -- <R12 MOAC>
                      );


END PO_REQUISITION_LINES_PKG2;

 

/
