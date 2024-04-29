--------------------------------------------------------
--  DDL for Package AP_DUPLICATE_VENDORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_DUPLICATE_VENDORS_PKG" AUTHID CURRENT_USER as
/* $Header: apiduves.pls 120.4 2004/10/28 00:01:59 pjena noship $ */


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Entry_Id                       NUMBER DEFAULT NULL,
                       X_Vendor_Id                      NUMBER DEFAULT NULL,
                       X_Duplicate_Vendor_Id            NUMBER DEFAULT NULL,
                       X_Vendor_Site_Id                 NUMBER DEFAULT NULL,
                       X_Duplicate_Vendor_Site_Id       NUMBER DEFAULT NULL,
                       X_Number_Unpaid_Invoices         NUMBER DEFAULT NULL,
                       X_Number_Paid_Invoices           NUMBER DEFAULT NULL,
                       X_Number_Po_Headers_Changed      NUMBER DEFAULT NULL,
                       X_Amount_Unpaid_Invoices         NUMBER DEFAULT NULL,
                       X_Amount_Paid_Invoices           NUMBER DEFAULT NULL,
                       X_Last_Update_Date               DATE DEFAULT NULL,
                       X_Last_Updated_By                NUMBER DEFAULT NULL,
                       X_Process_Flag                   VARCHAR2 DEFAULT NULL,
                       X_Process                        VARCHAR2 DEFAULT NULL,
                       X_Keep_Site_Flag                 VARCHAR2 DEFAULT NULL,
                       X_Paid_Invoices_Flag             VARCHAR2 DEFAULT NULL,
                       X_Last_Update_Login              NUMBER DEFAULT NULL,
                       X_Creation_Date                  DATE DEFAULT NULL,
                       X_Created_By                     NUMBER DEFAULT NULL,
                       X_Org_Id                         NUMBER,
		       X_calling_sequence		VARCHAR2
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Entry_Id                         NUMBER DEFAULT NULL,
                     X_Vendor_Id                        NUMBER DEFAULT NULL,
                     X_Duplicate_Vendor_Id              NUMBER DEFAULT NULL,
                     X_Vendor_Site_Id                   NUMBER DEFAULT NULL,
                     X_Duplicate_Vendor_Site_Id         NUMBER DEFAULT NULL,
                     X_Number_Unpaid_Invoices           NUMBER DEFAULT NULL,
                     X_Number_Paid_Invoices             NUMBER DEFAULT NULL,
                     X_Number_Po_Headers_Changed        NUMBER DEFAULT NULL,
                     X_Amount_Unpaid_Invoices           NUMBER DEFAULT NULL,
                     X_Amount_Paid_Invoices             NUMBER DEFAULT NULL,
                     X_Process_Flag                     VARCHAR2 DEFAULT NULL,
                     X_Process                          VARCHAR2 DEFAULT NULL,
                     X_Keep_Site_Flag                   VARCHAR2 DEFAULT NULL,
                     X_Paid_Invoices_Flag               VARCHAR2 DEFAULT NULL,
                     X_Org_Id                           NUMBER,
		     X_calling_sequence			VARCHAR2
                    );



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Entry_Id                       NUMBER DEFAULT NULL,
                       X_Vendor_Id                      NUMBER DEFAULT NULL,
                       X_Duplicate_Vendor_Id            NUMBER DEFAULT NULL,
                       X_Vendor_Site_Id                 NUMBER DEFAULT NULL,
                       X_Duplicate_Vendor_Site_Id       NUMBER DEFAULT NULL,
                       X_Number_Unpaid_Invoices         NUMBER DEFAULT NULL,
                       X_Number_Paid_Invoices           NUMBER DEFAULT NULL,
                       X_Number_Po_Headers_Changed      NUMBER DEFAULT NULL,
                       X_Amount_Unpaid_Invoices         NUMBER DEFAULT NULL,
                       X_Amount_Paid_Invoices           NUMBER DEFAULT NULL,
                       X_Last_Update_Date               DATE DEFAULT NULL,
                       X_Last_Updated_By                NUMBER DEFAULT NULL,
                       X_Process_Flag                   VARCHAR2 DEFAULT NULL,
                       X_Process                        VARCHAR2 DEFAULT NULL,
                       X_Keep_Site_Flag                 VARCHAR2 DEFAULT NULL,
                       X_Paid_Invoices_Flag             VARCHAR2 DEFAULT NULL,
                       X_Last_Update_Login              NUMBER DEFAULT NULL,
                       X_Org_Id                         NUMBER,
		       X_calling_sequence		VARCHAR2
                      );
  PROCEDURE Delete_Row(X_Rowid 				VARCHAR2,
		       X_calling_sequence		VARCHAR2
		      );

END AP_DUPLICATE_VENDORS_PKG;

 

/
