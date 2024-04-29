--------------------------------------------------------
--  DDL for Package PO_REQUISITION_LINES_PKG1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQUISITION_LINES_PKG1" AUTHID CURRENT_USER as
/* $Header: POXRIL2S.pls 115.6 2003/07/30 21:52:08 anhuang ship $ */

  PROCEDURE Lock1_Row(X_Rowid                         VARCHAR2,
                     X_Requisition_Line_Id            NUMBER,
                     X_Requisition_Header_Id          NUMBER,
                     X_Line_Num                       NUMBER,
                     X_Line_Type_Id                   NUMBER,
                     X_Category_Id                    NUMBER,
                     X_Item_Description               VARCHAR2,
                     X_Unit_Meas_Lookup_Code          VARCHAR2,
                     X_Unit_Price                     NUMBER,
                     X_Quantity                       NUMBER,
                     X_Amount                         NUMBER, -- <SERVICES FPJ>
                     X_Deliver_To_Location_Id         NUMBER,
                     X_To_Person_Id                   NUMBER,
                     X_Source_Type_Code               VARCHAR2,
                     X_Item_Id                        NUMBER,
		     X_Tax_Code_Id			NUMBER,
		     X_Tax_User_Override_Flag		VARCHAR2,
-- MC bug# 1548597.. Add 3 process related columns.unit_of_measure,quantity and grade.
-- start of 1548597
                       X_Secondary_Unit_Of_Measure      VARCHAR2 default null,
                       X_Secondary_Quantity             NUMBER default null,
                       X_Preferred_Grade                VARCHAR2 default null
-- end of 1548597
);




  PROCEDURE Delete_Row(X_Rowid 				VARCHAR2,
		       X_transferred_to_oe_flag  	OUT NOCOPY VARCHAR2);


END PO_REQUISITION_LINES_PKG1;

 

/
