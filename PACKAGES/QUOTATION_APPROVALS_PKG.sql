--------------------------------------------------------
--  DDL for Package QUOTATION_APPROVALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QUOTATION_APPROVALS_PKG" AUTHID CURRENT_USER as
/* $Header: POXAPQPS.pls 120.0 2005/06/02 00:41:43 appldev noship $ */


  PROCEDURE Insert_Row(	X_Rowid                  IN OUT NOCOPY VARCHAR2,
			X_Quotation_Approval_ID  IN OUT	NOCOPY  NUMBER,
                       	X_Approval_Type			 VARCHAR2,
			X_Approval_Reason		 VARCHAR2,
			X_Comments			 VARCHAR2,
			X_Approver_ID			 NUMBER,
			X_Start_Date_Active		 DATE,
			X_End_Date_Active		 DATE,
			X_Line_Location_ID		 NUMBER,
                       	X_Last_Update_Date               DATE,
			X_Last_Updated_By                NUMBER,
			X_Last_Update_Login		 NUMBER,
                        X_Creation_Date                  DATE,
                       	X_Created_By                     NUMBER,
                        X_Attribute_Category		 VARCHAR2,
			X_Attribute1			 VARCHAR2,
			X_Attribute2			 VARCHAR2,
			X_Attribute3			 VARCHAR2,
			X_Attribute4			 VARCHAR2,
			X_Attribute5			 VARCHAR2,
			X_Attribute6			 VARCHAR2,
			X_Attribute7			 VARCHAR2,
			X_Attribute8			 VARCHAR2,
			X_Attribute9			 VARCHAR2,
			X_Attribute10			 VARCHAR2,
                        X_Attribute11			 VARCHAR2,
			X_Attribute12			 VARCHAR2,
			X_Attribute13			 VARCHAR2,
			X_Attribute14			 VARCHAR2,
                      	X_Attribute15			 VARCHAR2,
			X_Request_ID			 NUMBER,
			X_Program_Application_ID	 NUMBER,
			X_Program_ID			 NUMBER,
			X_Program_Update_Date		 DATE,
                     	X_Org_ID			 NUMBER     --<R12 MOAC> uncommented  /* bug2493519*/
                        );


  PROCEDURE Lock_Row(	X_Rowid                          VARCHAR2,
			X_Quotation_Approval_ID		 NUMBER,
                     	X_Approval_Type			 VARCHAR2,
			X_Approval_Reason		 VARCHAR2,
			X_Comments			 VARCHAR2,
			X_Approver_ID			 NUMBER,
			X_Start_Date_Active		 DATE,
			X_End_Date_Active		 DATE,
			X_Line_Location_ID		 NUMBER,
                       	X_Last_Update_Date               DATE,
			X_Last_Updated_By                NUMBER,
			X_Last_Update_Login		 NUMBER,
                        X_Creation_Date                  DATE,
                       	X_Created_By                     NUMBER,
                        X_Attribute_Category		 VARCHAR2,
			X_Attribute1			 VARCHAR2,
			X_Attribute2			 VARCHAR2,
			X_Attribute3			 VARCHAR2,
			X_Attribute4			 VARCHAR2,
			X_Attribute5			 VARCHAR2,
			X_Attribute6			 VARCHAR2,
			X_Attribute7			 VARCHAR2,
			X_Attribute8			 VARCHAR2,
			X_Attribute9			 VARCHAR2,
			X_Attribute10			 VARCHAR2,
                        X_Attribute11			 VARCHAR2,
			X_Attribute12			 VARCHAR2,
			X_Attribute13			 VARCHAR2,
			X_Attribute14			 VARCHAR2,
                      	X_Attribute15			 VARCHAR2,
			X_Request_ID			 NUMBER,
			X_Program_Application_ID	 NUMBER,
			X_Program_ID			 NUMBER,
			X_Program_Update_Date		 DATE,
			X_Org_ID			 NUMBER     --<R12 MOAC> uncommented /* bug2493519*/
                        );

  PROCEDURE Update_Row(	X_Rowid                          VARCHAR2,
			X_Quotation_Approval_ID		 NUMBER,
                       	X_Approval_Type			 VARCHAR2,
			X_Approval_Reason		 VARCHAR2,
			X_Comments			 VARCHAR2,
			X_Approver_ID			 NUMBER,
			X_Start_Date_Active		 DATE,
			X_End_Date_Active		 DATE,
			X_Line_Location_ID		 NUMBER,
                       	X_Last_Update_Date               DATE,
			X_Last_Updated_By                NUMBER,
			X_Last_Update_Login		 NUMBER,
                        X_Attribute_Category		 VARCHAR2,
			X_Attribute1			 VARCHAR2,
			X_Attribute2			 VARCHAR2,
			X_Attribute3			 VARCHAR2,
			X_Attribute4			 VARCHAR2,
			X_Attribute5			 VARCHAR2,
			X_Attribute6			 VARCHAR2,
			X_Attribute7			 VARCHAR2,
			X_Attribute8			 VARCHAR2,
			X_Attribute9			 VARCHAR2,
			X_Attribute10			 VARCHAR2,
                        X_Attribute11			 VARCHAR2,
			X_Attribute12			 VARCHAR2,
			X_Attribute13			 VARCHAR2,
			X_Attribute14			 VARCHAR2,
                      	X_Attribute15			 VARCHAR2,
			X_Request_ID			 NUMBER,
			X_Program_Application_ID	 NUMBER,
			X_Program_ID			 NUMBER,
			X_Program_Update_Date		 DATE
		--	X_Org_ID			 NUMBER /* bug2493519*/
                        );


  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END QUOTATION_APPROVALS_PKG;

 

/
