--------------------------------------------------------
--  DDL for Package PO_REQUISITION_LINES_PKG3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQUISITION_LINES_PKG3" AUTHID CURRENT_USER as
/* $Header: POXRIL4S.pls 115.2 2003/07/30 21:52:41 anhuang ship $ */

   PROCEDURE Lock3_Row(X_Rowid                          VARCHAR2,
                     X_Rate_Type                        VARCHAR2,
                     X_Rate_Date                        DATE,
                     X_Rate                             NUMBER,
                     X_Currency_Unit_Price              NUMBER,
                     X_Currency_Amount                NUMBER, -- <SERVICES FPJ>
                     X_Suggested_Vendor_Name            VARCHAR2,
                     X_Suggested_Vendor_Location        VARCHAR2,
                     X_Suggested_Vendor_Contact         VARCHAR2,
                     X_Suggested_Vendor_Phone           VARCHAR2,
                     X_Sugg_Vendor_Product_Code    	VARCHAR2,
                     X_Un_Number_Id                     NUMBER,
                     X_Hazard_Class_Id                  NUMBER,
                     X_Must_Use_Sugg_Vendor_Flag        VARCHAR2,
                     X_Reference_Num                    VARCHAR2,
                     X_On_Rfq_Flag                      VARCHAR2,
                     X_Urgent_Flag                      VARCHAR2,
                     X_Cancel_Flag                      VARCHAR2,
                     X_Source_Organization_Id           NUMBER,
                     X_Source_Subinventory              VARCHAR2,
                     X_Destination_Type_Code            VARCHAR2,
                     X_Destination_Organization_Id      NUMBER,
                     X_Destination_Subinventory         VARCHAR2,
                     X_Quantity_Cancelled               NUMBER,
                     X_Cancel_Date                      DATE,
                     X_Cancel_Reason                    VARCHAR2,
                     X_Closed_Code                      VARCHAR2,
                     X_Agent_Return_Note                VARCHAR2,
                     X_Changed_After_Research_Flag      VARCHAR2,
                     X_Vendor_Id                        NUMBER,
                     X_Vendor_Site_Id                   NUMBER,
                     X_Vendor_Contact_Id                NUMBER);


END PO_REQUISITION_LINES_PKG3;

 

/
