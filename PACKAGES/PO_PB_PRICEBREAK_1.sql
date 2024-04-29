--------------------------------------------------------
--  DDL for Package PO_PB_PRICEBREAK_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_PB_PRICEBREAK_1" AUTHID CURRENT_USER AS
/* $Header: POPBPBKS.pls 120.0 2005/06/02 00:30:01 appldev noship $*/


   PROCEDURE insert_po_pricebreak
		      (X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Line_Location_Id               IN OUT NOCOPY NUMBER,
                       X_Po_Header_Id                   NUMBER,
                       X_Po_Line_Id                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Quantity                       NUMBER,
                       X_Unit_Meas_Lookup_Code          VARCHAR2,
                       X_Ship_To_Location_Id            NUMBER,
                       X_Price_Override                 NUMBER,
                       X_Price_Discount                 NUMBER,
                       X_Shipment_Num			NUMBER,
                       X_Ship_To_Organization_Id        NUMBER,
		       p_org_id                         NUMBER default null   -- <R12.MOAC>
       );

END PO_PB_PRICEBREAK_1;

 

/
