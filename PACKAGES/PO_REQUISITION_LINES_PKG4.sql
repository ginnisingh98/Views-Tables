--------------------------------------------------------
--  DDL for Package PO_REQUISITION_LINES_PKG4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQUISITION_LINES_PKG4" AUTHID CURRENT_USER as
/* $Header: POXRIL5S.pls 120.0 2005/06/01 14:25:39 appldev noship $ */

  PROCEDURE Lock4_Row(X_Rowid                           VARCHAR2,
                     X_Item_Revision                    VARCHAR2,
                     X_Quantity_Delivered               NUMBER,
                     X_Suggested_Buyer_Id               NUMBER,
                     X_Encumbered_Flag                  VARCHAR2,
                     X_Rfq_Required_Flag                VARCHAR2,
                     X_Need_By_Date                     DATE,
                     X_Line_Location_Id                 NUMBER,
                     X_Modified_By_Agent_Flag           VARCHAR2,
                     X_Parent_Req_Line_Id               NUMBER,
                     X_Justification                    VARCHAR2,
                     X_Note_To_Agent                    VARCHAR2,
                     X_Note_To_Receiver                 VARCHAR2,
                     X_Purchasing_Agent_Id              NUMBER,
                     X_Document_Type_Code               VARCHAR2,
                     X_Blanket_Po_Header_Id             NUMBER,
                     X_Blanket_Po_Line_Num              NUMBER,
                     X_Currency_Code                    VARCHAR2);

END PO_REQUISITION_LINES_PKG4;

 

/
