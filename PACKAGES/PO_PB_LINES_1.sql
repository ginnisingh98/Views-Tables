--------------------------------------------------------
--  DDL for Package PO_PB_LINES_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_PB_LINES_1" AUTHID CURRENT_USER as
/* $Header: POPBLINS.pls 115.2 2002/11/23 04:08:02 sbull noship $*/

 procedure insert_line(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Po_Line_Id              IN OUT NOCOPY NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Po_Header_Id                   NUMBER,
                       X_Line_Type_Id                   NUMBER,
                       X_Line_Num                       NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Item_Id                        NUMBER,
                       X_Item_Revision                  VARCHAR2,
                       X_Category_Id                    NUMBER,
                       X_Item_Description               VARCHAR2,
                       X_Unit_Meas_Lookup_Code          VARCHAR2,
                       X_Unit_Price                     NUMBER,
                       X_Vendor_Product_Num             VARCHAR2,
		       X_Org_Id				NUMBER,
		       X_Note_To_Vendor			VARCHAR2
                      );


END PO_PB_LINES_1;

 

/
