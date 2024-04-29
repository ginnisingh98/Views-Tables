--------------------------------------------------------
--  DDL for Package SHP_PICKING_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."SHP_PICKING_BATCHES_PKG" AUTHID CURRENT_USER as
/* $Header: WSHFPKBS.pls 115.0 99/07/16 08:19:08 porting ship $ */


  PROCEDURE Insert_Row(X_Rowid                   IN OUT VARCHAR2,
                       X_Batch_Id                IN OUT NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Name                    IN OUT VARCHAR2,
                       X_Backorders_Only_Flag           VARCHAR2,
                       X_Print_Flag                     VARCHAR2,
                       X_Existing_Rsvs_Only_Flag        VARCHAR2,
                       X_Shipment_Priority_Code         VARCHAR2,
                       X_Ship_Method_Code               VARCHAR2,
                       X_Customer_Id                    NUMBER,
                       X_Group_Id                       NUMBER,
                       X_Header_Count                   NUMBER,
                       X_Header_Id                      NUMBER,
                       X_Ship_Set_Number                NUMBER,
                       X_Inventory_Item_Id              NUMBER,
                       X_Order_Type_Id                  NUMBER,
                       X_Date_Requested_From            DATE,
                       X_Date_Requested_To              DATE,
                       X_Scheduled_Shipment_Date_From   DATE,
                       X_Scheduled_Shipment_Date_To     DATE,
                       X_Site_Use_Id                    NUMBER,
                       X_Warehouse_Id                   NUMBER,
                       X_Subinventory                   VARCHAR2,
                       X_Date_Completed                 DATE,
                       X_Date_Confirmed                 DATE,
                       X_Date_Last_Printed              DATE,
                       X_Date_Released                  DATE,
                       X_Date_Unreleased                DATE,
		       X_Departure_Id			NUMBER,
		       X_Delivery_Id			NUMBER,
		       X_Include_Planned_Lines		VARCHAR2,
		       X_Partial_Allowed_Flag		VARCHAR2,
		       X_Pick_Slip_Rule_Id		NUMBER,
		       X_Release_Seq_Rule_Id		NUMBER,
		       X_Autocreate_Delivery_Flag		VARCHAR2,
                       X_Context                        VARCHAR2,
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
                       X_Error_Report_Flag              VARCHAR2,
                       X_Org_Id				NUMBER
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Batch_Id                         NUMBER,
                     X_Name                             VARCHAR2,
                     X_Backorders_Only_Flag             VARCHAR2,
                     X_Print_Flag                       VARCHAR2,
                     X_Existing_Rsvs_Only_Flag          VARCHAR2,
                     X_Shipment_Priority_Code           VARCHAR2,
                     X_Ship_Method_Code                 VARCHAR2,
                     X_Customer_Id                      NUMBER,
                     X_Group_Id                         NUMBER,
                     X_Header_Count                     NUMBER,
                     X_Header_Id                        NUMBER,
                     X_Ship_Set_Number                  NUMBER,
                     X_Inventory_Item_Id                NUMBER,
                     X_Order_Type_Id                    NUMBER,
                     X_Date_Requested_From              DATE,
                     X_Date_Requested_To                DATE,
                     X_Scheduled_Shipment_Date_From     DATE,
                     X_Scheduled_Shipment_Date_To       DATE,
                     X_Site_Use_Id                      NUMBER,
                     X_Warehouse_Id                     NUMBER,
                     X_Subinventory                     VARCHAR2,
                     X_Date_Completed                   DATE,
                     X_Date_Confirmed                   DATE,
                     X_Date_Last_Printed                DATE,
                     X_Date_Released                    DATE,
                     X_Date_Unreleased                  DATE,
          	     X_Departure_Id         		NUMBER,
          	     X_Delivery_Id	     		NUMBER,
          	     X_Include_Planned_Lines 		VARCHAR2,
          	     X_Partial_Allowed_Flag 		VARCHAR2,
          	     X_Pick_Slip_Rule_Id    		NUMBER,
          	     X_Release_Seq_Rule_Id  		NUMBER,
		     X_Autocreate_Delivery_Flag		VARCHAR2,
                     X_Context                          VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2,
                     X_Error_Report_Flag                VARCHAR2,
                     X_Org_Id				NUMBER
                    );



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Batch_Id                       NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Name                           VARCHAR2,
                       X_Backorders_Only_Flag           VARCHAR2,
                       X_Print_Flag                     VARCHAR2,
                       X_Existing_Rsvs_Only_Flag        VARCHAR2,
                       X_Shipment_Priority_Code         VARCHAR2,
                       X_Ship_Method_Code               VARCHAR2,
                       X_Customer_Id                    NUMBER,
                       X_Group_Id                       NUMBER,
                       X_Header_Count                   NUMBER,
                       X_Header_Id                      NUMBER,
                       X_Ship_Set_Number                NUMBER,
                       X_Inventory_Item_Id              NUMBER,
                       X_Order_Type_Id                  NUMBER,
                       X_Date_Requested_From            DATE,
                       X_Date_Requested_To              DATE,
                       X_Scheduled_Shipment_Date_From   DATE,
                       X_Scheduled_Shipment_Date_To     DATE,
                       X_Site_Use_Id                    NUMBER,
                       X_Warehouse_Id                   NUMBER,
                       X_Subinventory                   VARCHAR2,
                       X_Date_Completed                 DATE,
                       X_Date_Confirmed                 DATE,
                       X_Date_Last_Printed              DATE,
                       X_Date_Released                  DATE,
                       X_Date_Unreleased                DATE,
                       X_Context                        VARCHAR2,
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
                       X_Error_Report_Flag              VARCHAR2,
                       X_Org_Id				NUMBER
                      );
  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

  PROCEDURE Delete_And_Commit(X_Rowid VARCHAR2);

  PROCEDURE Commit_Work;

  FUNCTION Submit_Release_Request(Batch_Id NUMBER) RETURN NUMBER;

  PROCEDURE Get_Printer ( report IN VARCHAR2,
                          report_printer OUT VARCHAR2,
                          default_report IN VARCHAR2 default 'OEXSHPIK');


  FUNCTION Open_Batch( X_batch_id IN NUMBER)
	RETURN VARCHAR2;

  PRAGMA  RESTRICT_REFERENCES (Open_Batch, WNDS, WNPS );

END SHP_PICKING_BATCHES_PKG;

 

/
