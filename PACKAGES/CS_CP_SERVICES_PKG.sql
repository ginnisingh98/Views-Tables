--------------------------------------------------------
--  DDL for Package CS_CP_SERVICES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CP_SERVICES_PKG" AUTHID CURRENT_USER as
/* $Header: csxsicss.pls 115.0 99/07/16 09:08:52 porting ship $ */

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Cp_Service_Id                    NUMBER,
                     X_Customer_Product_Id              NUMBER,
                     X_Service_Inventory_Item_Id        NUMBER,
                     X_Service_Manufacturing_Org_Id     NUMBER,
                     X_Start_Date_Active                DATE,
                     X_End_Date_Active                  DATE,
                     X_Original_Start_Date              DATE,
                     X_Original_End_Date                DATE,
				 X_Service_Date_Change              VARCHAR2,
                     X_Status_Code                      VARCHAR2,
                     X_Last_Cp_Service_Txn_Id           NUMBER,
                     X_Invoice_Flag                     VARCHAR2,
                     X_Coverage_Schedule_Id             NUMBER,
                     X_Prorate_Flag                     VARCHAR2,
                     X_Duration_Quantity                NUMBER,
                     X_Unit_Of_Measure_Code             VARCHAR2,
                     X_Starting_Delay                   NUMBER,
                     X_Bill_To_Site_Use_Id              NUMBER,
                     X_Bill_To_Contact_Id               NUMBER,
                     X_Service_Txn_Avail_Code           VARCHAR2,
                     X_Next_Pm_Visit_Date               DATE,
                     X_Pm_Visits_Completed              NUMBER,
                     X_Last_Pm_Visit_Date               DATE,
                     X_Pm_Schedule_Id                   NUMBER,
                     X_Pm_Schedule_Flag                 VARCHAR2,
                     X_Current_Max_Schedule_Date        DATE,
                     X_Price_List_Id                    NUMBER,
                     X_Pricing_Attribute1               VARCHAR2,
                     X_Pricing_Attribute2               VARCHAR2,
                     X_Pricing_Attribute3               VARCHAR2,
                     X_Pricing_Attribute4               VARCHAR2,
                     X_Pricing_Attribute5               VARCHAR2,
                     X_Pricing_Attribute6               VARCHAR2,
                     X_Pricing_Attribute7               VARCHAR2,
                     X_Pricing_Attribute8               VARCHAR2,
                     X_Pricing_Attribute9               VARCHAR2,
                     X_Pricing_Attribute10              VARCHAR2,
                     X_Pricing_Attribute11              VARCHAR2,
                     X_Pricing_Attribute12              VARCHAR2,
                     X_Pricing_Attribute13              VARCHAR2,
                     X_Pricing_Attribute14              VARCHAR2,
                     X_Pricing_Attribute15              VARCHAR2,
                     X_Pricing_Context                  VARCHAR2,
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
                     X_Context                          VARCHAR2,
                     X_Service_Order_Type               VARCHAR2,
                     X_Invoice_Count                    NUMBER,
                     X_Currency_Code                    VARCHAR2,
                     X_Conversion_Type                  VARCHAR2,
                     X_Conversion_Rate                  NUMBER,
                     X_Conversion_Date                  DATE,
                     X_Original_Service_Line_Id         NUMBER
                    );

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Cp_Service_Id                  NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Customer_Product_Id            NUMBER,
                       X_Service_Inventory_Item_Id      NUMBER,
                       X_Service_Manufacturing_Org_Id   NUMBER,
                       X_Start_Date_Active              DATE,
                       X_End_Date_Active                DATE,
                       X_Original_Start_Date            DATE,
                       X_Original_End_Date              DATE,
				   X_Service_Date_Change            VARCHAR2,
                       X_Status_Code                    VARCHAR2,
                       X_Last_Cp_Service_Txn_Id         NUMBER,
                       X_Invoice_Flag                   VARCHAR2,
                       X_Coverage_Schedule_Id           NUMBER,
                       X_Prorate_Flag                   VARCHAR2,
                       X_Duration_Quantity              NUMBER,
                       X_Unit_Of_Measure_Code           VARCHAR2,
                       X_Starting_Delay                 NUMBER,
                       X_Bill_To_Site_Use_Id            NUMBER,
                       X_Bill_To_Contact_Id             NUMBER,
                       X_Service_Txn_Avail_Code         VARCHAR2,
                       X_Next_Pm_Visit_Date             DATE,
                       X_Pm_Visits_Completed            NUMBER,
                       X_Last_Pm_Visit_Date             DATE,
                       X_Pm_Schedule_Id                 NUMBER,
                       X_Pm_Schedule_Flag               VARCHAR2,
                       X_Current_Max_Schedule_Date      DATE,
                       X_Price_List_Id                  NUMBER,
                       X_Pricing_Attribute1             VARCHAR2,
                       X_Pricing_Attribute2             VARCHAR2,
                       X_Pricing_Attribute3             VARCHAR2,
                       X_Pricing_Attribute4             VARCHAR2,
                       X_Pricing_Attribute5             VARCHAR2,
                       X_Pricing_Attribute6             VARCHAR2,
                       X_Pricing_Attribute7             VARCHAR2,
                       X_Pricing_Attribute8             VARCHAR2,
                       X_Pricing_Attribute9             VARCHAR2,
                       X_Pricing_Attribute10            VARCHAR2,
                       X_Pricing_Attribute11            VARCHAR2,
                       X_Pricing_Attribute12            VARCHAR2,
                       X_Pricing_Attribute13            VARCHAR2,
                       X_Pricing_Attribute14            VARCHAR2,
                       X_Pricing_Attribute15            VARCHAR2,
                       X_Pricing_Context                VARCHAR2,
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
                       X_Context                        VARCHAR2,
                       X_Service_Order_Type             VARCHAR2,
                       X_Invoice_Count                  NUMBER,
                       X_Currency_Code                  VARCHAR2,
                       X_Conversion_Type                VARCHAR2,
                       X_Conversion_Rate                NUMBER,
                       X_Conversion_Date                DATE,
                       X_Original_Service_Line_Id       NUMBER
                      );

END CS_CP_SERVICES_PKG;

 

/