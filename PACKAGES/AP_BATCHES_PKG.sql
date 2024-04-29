--------------------------------------------------------
--  DDL for Package AP_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_BATCHES_PKG" AUTHID CURRENT_USER as
/* $Header: apibatcs.pls 120.4 2004/10/28 00:01:03 pjena noship $ */

  FUNCTION get_actual_inv_count(l_batch_id IN NUMBER) RETURN NUMBER;
  FUNCTION get_actual_inv_amount(l_batch_id IN NUMBER) RETURN NUMBER;

  PRAGMA RESTRICT_REFERENCES(get_actual_inv_count, WNDS, WNPS, RNPS);
  PRAGMA RESTRICT_REFERENCES(get_actual_inv_amount, WNDS, WNPS, RNPS);

  PROCEDURE CHECK_UNIQUE (X_ROWID             VARCHAR2,
                          X_BATCH_NAME        VARCHAR2,
			  X_calling_sequence  VARCHAR2);


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Batch_Id                       NUMBER,
                       X_Batch_Name                     VARCHAR2,
                       X_Batch_Date                     DATE,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Control_Invoice_Count          NUMBER,
                       X_Control_Invoice_Total          NUMBER,
                       X_Invoice_Currency_Code          VARCHAR2,
                       X_Payment_Currency_Code          VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Pay_Group_Lookup_Code          VARCHAR2,
                       X_Payment_Priority               NUMBER,
                       X_Batch_Code_Combination_Id      NUMBER,
                       X_Terms_Id                       NUMBER,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
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
                       X_Invoice_Type_Lookup_Code       VARCHAR2,
                       X_Hold_Lookup_Code               VARCHAR2,
                       X_Hold_Reason                    VARCHAR2,
                       X_Doc_Category_Code              VARCHAR2,
                       X_Org_Id                         NUMBER,
		       X_calling_sequence		VARCHAR2,
		       X_gl_date			DATE		-- **1
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Batch_Id                         NUMBER,
                     X_Batch_Name                       VARCHAR2,
                     X_Batch_Date                       DATE,
                     X_Control_Invoice_Count            NUMBER,
                     X_Control_Invoice_Total            NUMBER,
                     X_Invoice_Currency_Code            VARCHAR2,
                     X_Payment_Currency_Code            VARCHAR2,
                     X_Pay_Group_Lookup_Code            VARCHAR2,
                     X_Payment_Priority                 NUMBER,
                     X_Batch_Code_Combination_Id        NUMBER,
                     X_Terms_Id                         NUMBER,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute_Category               VARCHAR2,
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
                     X_Invoice_Type_Lookup_Code         VARCHAR2,
                     X_Hold_Lookup_Code                 VARCHAR2,
                     X_Hold_Reason                      VARCHAR2,
                     X_Doc_Category_Code                VARCHAR2,
                     X_Org_Id                           NUMBER,
		     X_calling_sequence			VARCHAR2,
		     X_gl_date				DATE		-- **1
                    );



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Batch_Id                       NUMBER,
                       X_Batch_Name                     VARCHAR2,
                       X_Batch_Date                     DATE,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Control_Invoice_Count          NUMBER,
                       X_Control_Invoice_Total          NUMBER,
                       X_Invoice_Currency_Code          VARCHAR2,
                       X_Payment_Currency_Code          VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Pay_Group_Lookup_Code          VARCHAR2,
                       X_Payment_Priority               NUMBER,
                       X_Batch_Code_Combination_Id      NUMBER,
                       X_Terms_Id                       NUMBER,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
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
                       X_Invoice_Type_Lookup_Code       VARCHAR2,
                       X_Hold_Lookup_Code               VARCHAR2,
                       X_Hold_Reason                    VARCHAR2,
                       X_Doc_Category_Code              VARCHAR2,
                       X_Org_Id                         NUMBER,
		       X_calling_sequence		VARCHAR2,
		       X_gl_date			DATE		-- **1
                      );

  PROCEDURE Delete_Row(X_Rowid 				VARCHAR2,
		       X_calling_sequence		VARCHAR2);


END AP_BATCHES_PKG;

 

/
