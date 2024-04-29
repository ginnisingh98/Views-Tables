--------------------------------------------------------
--  DDL for Package PO_REQ_DISTRIBUTIONS_PKG2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQ_DISTRIBUTIONS_PKG2" AUTHID CURRENT_USER as
/* $Header: POXRID2S.pls 115.4 2003/07/30 21:53:20 anhuang ship $ */

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Distribution_Id                  NUMBER,
                     X_Requisition_Line_Id              NUMBER,
                     X_Set_Of_Books_Id                  NUMBER,
                     X_Code_Combination_Id              NUMBER,
                     X_Req_Line_Quantity                NUMBER,
                     X_Req_Line_Amount                  NUMBER,  -- <SERVICES FPJ>
                     X_Encumbered_Flag                  VARCHAR2,
                     X_Gl_Encumbered_Date               DATE,
                     X_Gl_Encumbered_Period_Name        VARCHAR2,
                     X_Gl_Cancelled_Date                DATE,
                     X_Failed_Funds_Lookup_Code         VARCHAR2,
                     X_Encumbered_Amount                NUMBER,
                     X_Budget_Account_Id                NUMBER,
                     X_Accrual_Account_Id               NUMBER,
                     X_Variance_Account_Id              NUMBER,
                     X_Prevent_Encumbrance_Flag         VARCHAR2,
                     X_Attribute_Category               VARCHAR2,
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
                     X_Ussgl_Transaction_Code           VARCHAR2,
                     X_Government_Context               VARCHAR2,
                     X_Project_Id                       NUMBER,
                     X_Task_Id                          NUMBER,
                     X_Expenditure_Type                 VARCHAR2,
                     X_Project_Accounting_Context       VARCHAR2,
                     X_Expenditure_Organization_Id      NUMBER,
                     X_Gl_Closed_Date                   DATE,
                     X_Source_Req_Distribution_Id       NUMBER,
                     X_Distribution_Num                 NUMBER,
                     X_Project_Related_Flag             VARCHAR2,
                     X_Expenditure_Item_Date            DATE,
                     X_End_Item_Unit_Number             VARCHAR2 DEFAULT NULL,
	             X_Recovery_Rate			NUMBER,
	             X_Tax_Recovery_Override_Flag	VARCHAR2
                    );



  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END PO_REQ_DISTRIBUTIONS_PKG2;

 

/
