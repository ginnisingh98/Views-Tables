--------------------------------------------------------
--  DDL for Package PA_PROJECT_CUSTOMERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_CUSTOMERS_PKG" AUTHID CURRENT_USER as
/* $Header: PAXPRCUS.pls 120.1 2005/08/19 17:17:23 mwasowic noship $ */


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       X_Project_Id                     NUMBER,
                       X_Customer_Id                    NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Project_Relationship_Code      VARCHAR2,
                       X_Customer_Bill_Split            NUMBER,
		       X_Bill_To_Customer_Id            NUMBER,
		       X_Ship_To_Customer_Id            NUMBER,
                       X_Bill_To_Address_Id             NUMBER,
                       X_Ship_To_Address_Id             NUMBER,
                       X_Inv_Currency_Code              VARCHAR2,
                       X_Inv_Rate_Type                  VARCHAR2,
                       X_Inv_Rate_Date                  DATE,
                       X_Inv_Exchange_Rate              NUMBER,
                       X_Allow_Inv_User_Rate_Type_Fg    VARCHAR2,
                       X_Bill_Another_Project_Flag      VARCHAR2,
                       X_Receiver_Task_Id               NUMBER,
                       X_Record_Version_Number          NUMBER,
		       X_Default_Top_Task_Cust_Flag     VARCHAR2
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Project_Id                       NUMBER,
                     X_Customer_Id                      NUMBER,
                     X_Project_Relationship_Code        VARCHAR2,
                     X_Customer_Bill_Split              NUMBER,
                     X_Bill_To_Address_Id               NUMBER,
                     X_Ship_To_Address_Id               NUMBER,
                     X_Inv_Currency_Code              VARCHAR2,
                     X_Inv_Rate_Type                  VARCHAR2,
                     X_Inv_Rate_Date                  DATE,
                     X_Inv_Exchange_Rate              NUMBER,
                     X_Allow_Inv_User_Rate_Type_Fg    VARCHAR2,
                     X_Bill_Another_Project_Flag      VARCHAR2,
                     X_Receiver_Task_Id               NUMBER,
                     X_Record_Version_Number          NUMBER,
                     X_Default_Top_Task_Cust_Flag     VARCHAR2
                    );



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Project_Id                     NUMBER,
                       X_Customer_Id                    NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Project_Relationship_Code      VARCHAR2,
                       X_Customer_Bill_Split            NUMBER,
		       X_Bill_To_Customer_Id            NUMBER,
		       X_Ship_To_Customer_Id            NUMBER,
                       X_Bill_To_Address_Id             NUMBER,
                       X_Ship_To_Address_Id             NUMBER,
                       X_Inv_Currency_Code              VARCHAR2,
                       X_Inv_Rate_Type                  VARCHAR2,
                       X_Inv_Rate_Date                  DATE,
                       X_Inv_Exchange_Rate              NUMBER,
                       X_Allow_Inv_User_Rate_Type_Fg    VARCHAR2,
                       X_Bill_Another_Project_Flag      VARCHAR2,
                       X_Receiver_Task_Id               NUMBER,
                       X_Record_Version_Number          NUMBER,
		       X_Default_Top_Task_Cust_Flag     VARCHAR2
                      );
  PROCEDURE Delete_Row(X_Rowid VARCHAR2,
                       x_record_version_number          NUMBER);

END PA_PROJECT_CUSTOMERS_PKG;
 

/
