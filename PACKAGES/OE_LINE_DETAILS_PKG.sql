--------------------------------------------------------
--  DDL for Package OE_LINE_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_LINE_DETAILS_PKG" AUTHID CURRENT_USER AS
/* $Header: oexdets.pls 115.0 99/07/16 08:28:56 porting ship $ */
    PROCEDURE Manually_Insert_Detail
         (      P_Line_Detail_Id			NUMBER,
		P_Creation_Date			IN OUT  DATE,
                P_Created_By				NUMBER,
		P_Last_Update_Date		IN OUT  DATE,
                P_Last_Updated_By			NUMBER,
                P_Last_Update_Login			NUMBER,
                P_Line_Id				NUMBER,
                P_Inventory_Item_Id			NUMBER,
                P_Component_Sequence_Id			NUMBER,
                P_Component_Code			VARCHAR2,
                P_Quantity				NUMBER,
                P_Schedule_Date				DATE,
                P_Lot_Number				VARCHAR2,
                P_Subinventory				VARCHAR2,
                P_Warehouse_Id				NUMBER,
                P_Revision				VARCHAR2,
                P_Customer_Requested_Lot_Flag		VARCHAR2,
                P_Schedule_Status_Code			VARCHAR2,
                P_Context				VARCHAR2,
                P_Attribute1				VARCHAR2,
                P_Attribute2				VARCHAR2,
                P_Attribute3				VARCHAR2,
                P_Attribute4				VARCHAR2,
                P_Attribute5				VARCHAR2,
                P_Attribute6				VARCHAR2,
                P_Attribute7				VARCHAR2,
                P_Attribute8				VARCHAR2,
                P_Attribute9				VARCHAR2,
                P_Attribute10				VARCHAR2,
                P_Attribute11				VARCHAR2,
                P_Attribute12				VARCHAR2,
                P_Attribute13				VARCHAR2,
                P_Attribute14				VARCHAR2,
                P_Attribute15				VARCHAR2,
                P_Included_Item_Flag    		VARCHAR2,
                P_Component_Ratio			NUMBER,
                P_Shippable_Flag			VARCHAR2,
                P_Transactable_Flag			VARCHAR2,
                P_Reservable_Flag			VARCHAR2,
                P_Released_Flag				VARCHAR2,
                P_Demand_Class_Code			VARCHAR2,
                P_Unit_Code				VARCHAR2,
                P_Required_For_Revenue_Flag IN OUT	VARCHAR2,
                P_Quantity_Svrid			NUMBER,
                P_Warehouse_Svrid			NUMBER,
                P_Demand_Class_Svrid			NUMBER,
                P_Date_Svrid				NUMBER,
                P_Customer_Requested_Svrid		NUMBER,
                P_Df_Svrid				NUMBER,
                P_Delivery				NUMBER,
                P_Update_Flag				VARCHAR2,
                P_Configuration_Item_Flag		VARCHAR2,
		P_Result			IN OUT  VARCHAR2,
		P_Dpw_Assigned_Flag			VARCHAR2 DEFAULT 'N'
		);

  PROCEDURE Validate_Scheduling_Attributes
	(
		P_DB_RECORD_FLAG		VARCHAR2,
		P_DB_QUANTITY			NUMBER,
		P_DB_WAREHOUSE_ID		NUMBER,
		P_DB_SCHEDULE_DATE		DATE,
		P_DB_SUBINVENTORY		VARCHAR2,
		P_DB_REVISION			VARCHAR2,
		P_DB_LOT_NUMBER			VARCHAR2,
		P_DB_DEMAND_CLASS_CODE		VARCHAR2,
		P_QUANTITY			NUMBER,
		P_WAREHOUSE_ID			NUMBER,
		P_SCHEDULE_DATE			DATE,
		P_SUBINVENTORY			VARCHAR2,
		P_REVISION			VARCHAR2,
		P_LOT_NUMBER			VARCHAR2,
		P_DEMAND_CLASS_CODE		VARCHAR2,
		P_REVISION_CONTROL_FLAG		VARCHAR2,
		P_LOT_CONTROL_FLAG		VARCHAR2,
		P_SCHEDULE_ACTION_CODE		VARCHAR2,
		P_SCHEDULE_STATUS_CODE		VARCHAR2,
		P_RESULT		IN OUT	VARCHAR2
	);


END OE_LINE_DETAILS_PKG;

 

/
