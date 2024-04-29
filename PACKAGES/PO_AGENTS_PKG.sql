--------------------------------------------------------
--  DDL for Package PO_AGENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_AGENTS_PKG" AUTHID CURRENT_USER as
/* $Header: POXTIDBS.pls 115.2 2002/11/23 01:22:02 sbull ship $ */


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Agent_Id                	NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
		       X_Last_Update_Login              NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Location_ID		        NUMBER,
                       X_Category_ID			NUMBER,
		       X_Authorization_Limit		NUMBER,
		       X_Start_Date_Active		DATE,
		       X_End_Date_Active		DATE,
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
		       X_Attribute15			VARCHAR2);


  PROCEDURE Lock_Row(X_Rowid                        	VARCHAR2,
                     X_Agent_ID                		NUMBER,
		     X_Last_Update_Login		NUMBER,
                     X_Location_ID		        NUMBER,
                     X_Category_ID			NUMBER,
		     X_Authorization_Limit		NUMBER,
		     X_Start_Date_Active		DATE,
		     X_End_Date_Active			DATE,
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
		     X_Attribute15			VARCHAR2);

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Agent_Id                	NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
		       X_Last_Update_Login              NUMBER,
                       X_Location_ID		        NUMBER,
                       X_Category_ID			NUMBER,
		       X_Authorization_Limit		NUMBER,
		       X_Start_Date_Active		DATE,
		       X_End_Date_Active		DATE,
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
		       X_Attribute15			VARCHAR2);


  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END PO_AGENTS_PKG;

 

/
