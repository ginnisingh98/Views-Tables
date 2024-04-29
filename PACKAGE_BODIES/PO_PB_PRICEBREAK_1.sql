--------------------------------------------------------
--  DDL for Package Body PO_PB_PRICEBREAK_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_PB_PRICEBREAK_1" as
/* $Header: POPBPBKB.pls 120.0 2005/06/01 13:31:06 appldev noship $*/

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
                       X_Shipment_Num                   NUMBER,
                       X_Ship_To_Organization_Id        NUMBER,
		       p_org_id                         NUMBER     -- <R12.MOAC>
) IS

      X_revised_date            DATE;
      X_item_status             VARCHAR2(20) :=null;
      X_progress                VARCHAR2(3) :='000';

      l_value_basis  PO_LINES_ALL.order_type_lookup_code%TYPE;  -- <Complex Work R12>

      BEGIN


        X_revised_date:=null;

        -- <Complex Work R12 Start>
        -- Get value basis from line

        SELECT pol.order_type_lookup_code
        INTO l_value_basis
        FROM po_lines_all pol
        WHERE pol.po_line_id = X_Po_Line_Id;

        X_progress :='010';

        -- <Complex Work R12 End>

	po_shipments_sv6.insert_po_shipment(
		       X_Rowid,
                       X_Line_Location_Id,
                       X_Creation_Date,
                       X_Created_By,
                       X_Po_Header_Id,
                       X_Po_Line_Id,
                       X_Last_Update_Login,
                       X_Creation_Date,
                       X_Created_By,
                       X_Quantity,
                       0,
                       0,
                       0,
                       0,
                       0,
                       X_Unit_Meas_Lookup_Code,
                       null,
                       X_Ship_To_Location_Id,
                       null,
                       null,
                       null,
                       null,
                       X_Price_Override,
                       'N',
                       null,
                       null,
                       null,
                       'N',  --X_Taxable_Flag
                       null,
		       null,
		       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       X_Price_Discount,
                       null,
                       null,
                       null,
                       null,
                       'N',
                       null,
                       null,
                       null,
                       'N',
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,  --attribute5
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       'NONE',
                       null,
                       null,
                       null,
                       'NONE',
                       null,
                       null,
                       X_Ship_To_Organization_Id,
                       X_Shipment_Num,
                       null,
                       'PRICE BREAK',
                       'OPEN',
                       null,
                       null,
                       null,
                       'N',
                       null, --X_Closed_Reason
                       null,
                       null,
	               null,
        	       null,
        	       null,
	               null,
	               null,
                       X_revised_date,
                       X_item_status,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,             -- X_Global_Attribute20
                       null,
                       null,
                       l_value_basis,    -- <Complex Work R12>
                       null,             -- <Complex Work R12>: matching_basis
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
                       null,
	               null,
	               null,
	               null,
	               null,
		       p_org_id   -- <R12.MOAC>
		       );

      EXCEPTION
	WHEN OTHERS THEN
--	  dbms_output.put_line('In exception');
	  po_message_s.sql_error('insert_po_pricebreak', X_progress, sqlcode);
          raise;
      END insert_po_pricebreak;

END  PO_PB_PRICEBREAK_1;

/
