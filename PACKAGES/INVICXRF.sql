--------------------------------------------------------
--  DDL for Package INVICXRF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVICXRF" AUTHID CURRENT_USER as
/* $Header: INVICXRS.pls 115.0 99/07/16 10:53:22 porting ship $ */

PROCEDURE Insert_Row   (X_Rowid 			OUT VARCHAR2,
			X_Customer_Item_Id		NUMBER,
			X_Inventory_Item_Id		NUMBER,
			X_Master_Organization_Id	NUMBER,
			X_Rank 				NUMBER,
			X_Inactive_Flag			VARCHAR2,
			X_Last_Update_Date		DATE,
			X_Last_Updated_By		NUMBER,
			X_Creation_Date			DATE,
			X_Created_By			NUMBER,
			X_Last_Update_Login		NUMBER,
			X_Attribute_Category		VARCHAR2,
			X_Attribute1			VARCHAR2,
			X_Attribute2			VARCHAR2,
			X_Attribute3			VARCHAR2,
			X_Attribute4			VARCHAR2,
			X_Attribute5			VARCHAR2,
			X_Attribute6			VARCHAR2,
			X_Attribute7			VARCHAR2,
			X_Attribute8			VARCHAR2,
			X_Attribute9			VARCHAR2,
			X_Attribute10			VARCHAR2,
			X_Attribute11			VARCHAR2,
			X_Attribute12			VARCHAR2,
			X_Attribute13			VARCHAR2,
			X_Attribute14			VARCHAR2,
			X_Attribute15			VARCHAR2
			);


PROCEDURE Lock_Row     (X_Rowid				VARCHAR2,
			X_Customer_Item_Id		NUMBER,
			X_Inventory_Item_Id		NUMBER,
			X_Master_Organization_Id	NUMBER,
			X_Rank 				NUMBER,
			X_Inactive_Flag			VARCHAR2,
			X_Last_Update_Date		DATE,
			X_Last_Updated_By		NUMBER,
			X_Creation_Date			DATE,
			X_Created_By			NUMBER,
			X_Last_Update_Login		NUMBER,
			X_Attribute_Category		VARCHAR2,
			X_Attribute1			VARCHAR2,
			X_Attribute2			VARCHAR2,
			X_Attribute3			VARCHAR2,
			X_Attribute4			VARCHAR2,
			X_Attribute5			VARCHAR2,
			X_Attribute6			VARCHAR2,
			X_Attribute7			VARCHAR2,
			X_Attribute8			VARCHAR2,
			X_Attribute9			VARCHAR2,
			X_Attribute10			VARCHAR2,
			X_Attribute11			VARCHAR2,
			X_Attribute12			VARCHAR2,
			X_Attribute13			VARCHAR2,
			X_Attribute14			VARCHAR2,
			X_Attribute15			VARCHAR2
			);


PROCEDURE Update_Row   (X_Rowid				VARCHAR2,
			X_Customer_Item_Id		NUMBER,
			X_Inventory_Item_Id		NUMBER,
			X_Master_Organization_Id	NUMBER,
			X_Rank 				NUMBER,
			X_Inactive_Flag			VARCHAR2,
			X_Last_Update_Date		DATE,
			X_Last_Updated_By		NUMBER,
			X_Creation_Date			DATE,
			X_Created_By			NUMBER,
			X_Last_Update_Login		NUMBER,
			X_Attribute_Category		VARCHAR2,
			X_Attribute1			VARCHAR2,
			X_Attribute2			VARCHAR2,
			X_Attribute3			VARCHAR2,
			X_Attribute4			VARCHAR2,
			X_Attribute5			VARCHAR2,
			X_Attribute6			VARCHAR2,
			X_Attribute7			VARCHAR2,
			X_Attribute8			VARCHAR2,
			X_Attribute9			VARCHAR2,
			X_Attribute10			VARCHAR2,
			X_Attribute11			VARCHAR2,
			X_Attribute12			VARCHAR2,
			X_Attribute13			VARCHAR2,
			X_Attribute14			VARCHAR2,
			X_Attribute15			VARCHAR2
			);


PROCEDURE CHECK_UNIQUE (X_Rowid VARCHAR2,
			X_Customer_Item_Id NUMBER,
			X_Inventory_Item_Id NUMBER,
			X_Master_Organization_Id NUMBER);


PROCEDURE CHECK_UNIQUE_RANK (X_Rowid VARCHAR2,
			     X_Customer_Item_Id NUMBER,
			     X_Master_Organization_Id NUMBER,
			     X_Rank NUMBER);


END INVICXRF;

 

/
