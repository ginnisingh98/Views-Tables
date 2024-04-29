--------------------------------------------------------
--  DDL for Package PA_DRAFT_INVOICE_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_DRAFT_INVOICE_ITEMS_PKG" AUTHID CURRENT_USER as
/* $Header: PAINDIIS.pls 120.3 2005/08/19 16:35:00 mwasowic noship $ */


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       X_Project_Id                     NUMBER,
                       X_Draft_Invoice_Num              NUMBER,
                       X_Line_Num                       NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Amount                         NUMBER,
                       X_Text                           VARCHAR2,
                       X_Invoice_Line_Type              VARCHAR2,
                       X_Unearned_Revenue_Cr            NUMBER,
                       X_Unbilled_Receivable_Dr         NUMBER,
                       X_Task_Id                        NUMBER,
                       X_Event_Task_Id                  NUMBER,
                       X_Event_Num                      NUMBER,
                       X_Ship_To_Address_Id             NUMBER,
                       X_Taxable_Flag                   VARCHAR2,
                       X_Draft_Inv_Line_Num_Credited    NUMBER,
                       X_Last_Update_Login              NUMBER
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Project_Id                       NUMBER,
                     X_Draft_Invoice_Num                NUMBER,
                     X_Line_Num                         NUMBER,
                     X_Amount                           NUMBER,
                     X_Text                             VARCHAR2,
                     X_Invoice_Line_Type                VARCHAR2,
                     X_Unearned_Revenue_Cr              NUMBER,
                     X_Unbilled_Receivable_Dr           NUMBER,
                     X_Task_Id                          NUMBER,
                     X_Event_Task_Id                    NUMBER,
                     X_Event_Num                        NUMBER,
                     X_Ship_To_Address_Id               NUMBER,
                     X_Taxable_Flag                     VARCHAR2,
                     X_Draft_Inv_Line_Num_Credited      NUMBER,
                     X_output_tax_code                  VARCHAR2,
                     X_output_tax_exempt_flag           VARCHAR2,
                     X_out_tax_exempt_reason_code       VARCHAR2,
                     X_output_tax_exempt_number         VARCHAR2,
                     X_translated_text                  VARCHAR2
                    );



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Project_Id                     NUMBER,
                       X_Draft_Invoice_Num              NUMBER,
                       X_Line_Num                       NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Amount                         NUMBER,
                       X_Text                           VARCHAR2,
                       X_Invoice_Line_Type              VARCHAR2,
                       X_Unearned_Revenue_Cr            NUMBER,
                       X_Unbilled_Receivable_Dr         NUMBER,
                       X_Task_Id                        NUMBER,
                       X_Event_Task_Id                  NUMBER,
                       X_Event_Num                      NUMBER,
                       X_Ship_To_Address_Id             NUMBER,
                       X_Taxable_Flag                   VARCHAR2,
                       X_Draft_Inv_Line_Num_Credited    NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_output_tax_code                VARCHAR2,
                       X_output_tax_exempt_flag         VARCHAR2,
                       X_out_tax_exempt_reason_code     VARCHAR2,
                       X_output_tax_exempt_number       VARCHAR2,
                       X_translated_text                VARCHAR2
                      );
  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END PA_DRAFT_INVOICE_ITEMS_PKG;
 

/
