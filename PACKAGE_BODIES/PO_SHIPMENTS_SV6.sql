--------------------------------------------------------
--  DDL for Package Body PO_SHIPMENTS_SV6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_SHIPMENTS_SV6" as
/* $Header: POXPOS6B.pls 120.4 2005/06/30 07:12:33 manram noship $*/

/*===========================================================================

  PROCEDURE NAME:	insert_po_shipment

===========================================================================*/
  PROCEDURE insert_po_shipment
		      (X_Rowid                          IN OUT NOCOPY VARCHAR2,
                       X_Line_Location_Id               IN OUT NOCOPY NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Po_Header_Id                   NUMBER,
                       X_Po_Line_Id                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Quantity                       NUMBER,
                       X_Quantity_Received              NUMBER,
                       X_Quantity_Accepted              NUMBER,
                       X_Quantity_Rejected              NUMBER,
                       X_Quantity_Billed                NUMBER,
                       X_Quantity_Cancelled             NUMBER,
                       X_Unit_Meas_Lookup_Code          VARCHAR2,
                       X_Po_Release_Id                  NUMBER,
                       X_Ship_To_Location_Id            NUMBER,
                       X_Ship_Via_Lookup_Code           VARCHAR2,
                       X_Need_By_Date                   DATE,
                       X_Promised_Date                  DATE,
                       X_Last_Accept_Date               DATE,
                       X_Price_Override                 NUMBER,
                       X_Encumbered_Flag                VARCHAR2,
                       X_Encumbered_Date                DATE,
                       X_Fob_Lookup_Code                VARCHAR2,
                       X_Freight_Terms_Lookup_Code      VARCHAR2,
                       X_Taxable_Flag                   VARCHAR2,
                       X_Tax_Code_Id                    NUMBER,
		       X_Tax_User_Override_Flag		VARCHAR2,
		       X_Calculate_Tax_Flag		VARCHAR2,
                       X_From_Header_Id                 NUMBER,
                       X_From_Line_Id                   NUMBER,
                       X_From_Line_Location_Id          NUMBER,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Lead_Time                      NUMBER,
                       X_Lead_Time_Unit                 VARCHAR2,
                       X_Price_Discount                 NUMBER,
                       X_Terms_Id                       NUMBER,
                       X_Approved_Flag                  VARCHAR2,
                       X_Approved_Date                  DATE,
                       X_Closed_Flag                    VARCHAR2,
                       X_Cancel_Flag                    VARCHAR2,
                       X_Cancelled_By                   NUMBER,
                       X_Cancel_Date                    DATE,
                       X_Cancel_Reason                  VARCHAR2,
                       X_Firm_Status_Lookup_Code        VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
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
                       X_Inspection_Required_Flag       VARCHAR2,
                       X_Receipt_Required_Flag          VARCHAR2,
                       X_Qty_Rcv_Tolerance              NUMBER,
                       X_Qty_Rcv_Exception_Code         VARCHAR2,
                       X_Enforce_Ship_To_Location       VARCHAR2,
                       X_Allow_Substitute_Receipts      VARCHAR2,
                       X_Days_Early_Receipt_Allowed     NUMBER,
                       X_Days_Late_Receipt_Allowed      NUMBER,
                       X_Receipt_Days_Exception_Code    VARCHAR2,
                       X_Invoice_Close_Tolerance        NUMBER,
                       X_Receive_Close_Tolerance        NUMBER,
                       X_Ship_To_Organization_Id        NUMBER,
                       X_Shipment_Num                   NUMBER,
                       X_Source_Shipment_Id             NUMBER,
                       X_Shipment_Type                  VARCHAR2,
                       X_Closed_Code                    VARCHAR2,
                       X_Ussgl_Transaction_Code         VARCHAR2,
                       X_Government_Context             VARCHAR2,
                       X_Receiving_Routing_Id           NUMBER,
                       X_Accrue_On_Receipt_Flag         VARCHAR2,
                       X_Closed_Reason                  VARCHAR2,
                       X_Closed_Date                    DATE,
                       X_Closed_By                      NUMBER,
                       X_item_id                        NUMBER,
                       X_hdr_approved_flag    IN        VARCHAR2,
                       X_po_rowid             IN        VARCHAR2,
                       X_increment_rev        IN        BOOLEAN,
                       X_new_revision_num     IN        NUMBER,
-- Bug 902976, zxzhang, 10/04/99
-- Change REVISED_DATE from VarChar(25) to Date.
--                     X_revised_date         IN OUT NOCOPY    VARCHAR2,
                       X_revised_date         IN OUT NOCOPY    DATE,
                       X_item_status          IN OUT NOCOPY    VARCHAR2,
                       X_Global_Attribute_Category          VARCHAR2,
                       X_Global_Attribute1                  VARCHAR2,
                       X_Global_Attribute2                  VARCHAR2,
                       X_Global_Attribute3                  VARCHAR2,
                       X_Global_Attribute4                  VARCHAR2,
                       X_Global_Attribute5                  VARCHAR2,
                       X_Global_Attribute6                  VARCHAR2,
                       X_Global_Attribute7                  VARCHAR2,
                       X_Global_Attribute8                  VARCHAR2,
                       X_Global_Attribute9                  VARCHAR2,
                       X_Global_Attribute10                 VARCHAR2,
                       X_Global_Attribute11                 VARCHAR2,
                       X_Global_Attribute12                 VARCHAR2,
                       X_Global_Attribute13                 VARCHAR2,
                       X_Global_Attribute14                 VARCHAR2,
                       X_Global_Attribute15                 VARCHAR2,
                       X_Global_Attribute16                 VARCHAR2,
                       X_Global_Attribute17                 VARCHAR2,
                       X_Global_Attribute18                 VARCHAR2,
                       X_Global_Attribute19                 VARCHAR2,
                       X_Global_Attribute20                 VARCHAR2,
		       X_Country_of_Origin_Code		    VARCHAR2,
		       X_Invoice_Match_Option		    VARCHAR2,  --bgu, Dec. 7, 98
                       p_value_basis            IN          VARCHAR2,  -- <Complex Work R12>
                       p_matching_basis            IN          VARCHAR2,  -- <Complex Work R12>
		       --togeorge 10/03/2000
		       --added note to receiver
		       X_note_to_receiver		    VARCHAR2,
-- Mahesh Chandak(GML) Add 7 process related fields.Bug# 1548597
-- start of 1548597
                       X_Secondary_Unit_Of_Measure        VARCHAR2,
                       X_Secondary_Quantity               NUMBER,
                       X_Preferred_Grade                  VARCHAR2,
                       X_Secondary_Quantity_Received      NUMBER,
                       X_Secondary_Quantity_Accepted      NUMBER,
                       X_Secondary_Quantity_Rejected      NUMBER,
                       X_Secondary_Quantity_Cancelled     NUMBER,
-- end of 1548597
                       X_Consigned_Flag                   VARCHAR2,  /* CONSIGNED FPI */
                       X_amount                           NUMBER,  -- <SERVICES FPJ>
                       p_transaction_flow_header_id       NUMBER,
                       p_org_id                     IN     NUMBER,  -- <R12.MOAC>
                       p_outsourced_assembly	IN NUMBER default 2 --<SHIKYU R12>
) IS

      X_progress                VARCHAR2(3)  := '';
      X_approval_status_ok      BOOLEAN;
      X_scheduled_quantity      NUMBER;

      BEGIN

         X_progress := '010';

	IF X_shipment_type not in ('RFQ', 'QUOTATION') THEN

           /* Item Status fetched here will be used for creating
           ** distributions automatically. */

           po_items_sv2.get_item_status(X_item_id,
                                        X_ship_to_organization_id,
                                        X_item_status);

	END IF;  /* X_shipment_type not in RFQ or QUOTATION */

        IF X_shipment_type = 'PLANNED' then

              begin

                SELECT nvl(sum(pll.quantity - nvl(pll.quantity_cancelled,0)),0)
                INTO   X_scheduled_quantity
                FROM   po_line_locations pll
                WHERE  pll.po_line_id         = X_po_line_id
                AND    pll.source_shipment_id = X_line_location_id
                AND    pll.shipment_type      = 'SCHEDULED';

                if  X_scheduled_quantity > X_quantity then
                    po_message_s.app_error('PO_PO_REL_EXCEEDS_QTY');
                end if;

            exception

                when no_data_found then
                     null;

                when others then
                     po_message_s.sql_error('insert_po_shipment',X_progress,
                                         sqlcode);
                     raise;
           END;

        END IF; /* End of Shipment_Type = 'PLANNED' */

        -- verify that the shipment number is unique.
        -- Otherwise, display a message to the user and
        -- abort insert_row.

        X_progress := '015';
        po_line_locations_pkg_s3.check_unique(
		X_rowid,
		X_shipment_num,
		X_po_line_id,
                null,
                X_shipment_type);


        /*
        ** Call the insert row routine with all parameters.
        */
	po_line_locations_pkg_s0.insert_row(
		       X_Rowid,
                       X_Line_Location_Id,
                       X_Last_Update_Date,
                       X_Last_Updated_By,
                       X_Po_Header_Id,
                       X_Po_Line_Id,
                       X_Last_Update_Login,
                       X_Creation_Date,
                       X_Created_By,
                       X_Quantity,
                       X_Quantity_Received,
                       X_Quantity_Accepted,
                       X_Quantity_Rejected,
                       X_Quantity_Billed,
                       X_Quantity_Cancelled,
                       X_Unit_Meas_Lookup_Code,
                       X_Po_Release_Id,
                       X_Ship_To_Location_Id,
                       X_Ship_Via_Lookup_Code,
                       X_Need_By_Date,
                       X_Promised_Date,
                       X_Last_Accept_Date,
                       X_Price_Override,
                       X_Encumbered_Flag,
                       X_Encumbered_Date,
                       X_Fob_Lookup_Code,
                       X_Freight_Terms_Lookup_Code,
                       X_Taxable_Flag,
                       NULL, --<R12 eTax Integration>
                       NULL, --<R12 eTax Integration>
		       X_Calculate_Tax_Flag,
                       X_From_Header_Id,
                       X_From_Line_Id,
                       X_From_Line_Location_Id,
                       X_Start_Date,
                       X_End_Date,
                       X_Lead_Time,
                       X_Lead_Time_Unit,
                       X_Price_Discount,
                       X_Terms_Id,
                       X_Approved_Flag,
                       X_Approved_Date,
                       X_Closed_Flag,
                       X_Cancel_Flag,
                       X_Cancelled_By,
                       X_Cancel_Date,
                       X_Cancel_Reason,
                       X_Firm_Status_Lookup_Code,
                       X_Attribute_Category,
                       X_Attribute1,
                       X_Attribute2,
                       X_Attribute3,
                       X_Attribute4,
                       X_Attribute5,
                       X_Attribute6,
                       X_Attribute7,
                       X_Attribute8,
                       X_Attribute9,
                       X_Attribute10,
                       X_Attribute11,
                       X_Attribute12,
                       X_Attribute13,
                       X_Attribute14,
                       X_Attribute15,
                       X_Inspection_Required_Flag,
                       X_Receipt_Required_Flag,
                       X_Qty_Rcv_Tolerance,
                       X_Qty_Rcv_Exception_Code,
                       X_Enforce_Ship_To_Location,
                       X_Allow_Substitute_Receipts,
                       X_Days_Early_Receipt_Allowed,
                       X_Days_Late_Receipt_Allowed,
                       X_Receipt_Days_Exception_Code,
                       X_Invoice_Close_Tolerance,
                       X_Receive_Close_Tolerance,
                       X_Ship_To_Organization_Id,
                       X_Shipment_Num,
                       X_Source_Shipment_Id,
                       X_Shipment_Type,
                       X_Closed_Code,
                       NULL, --<R12 SLA>
                       X_Government_Context,
                       X_Receiving_Routing_Id,
                       X_Accrue_On_Receipt_Flag,
                       X_Closed_Reason,
                       X_Closed_Date,
                       X_Closed_By,
	               X_Global_Attribute_Category,
        	       X_Global_Attribute1,
        	       X_Global_Attribute2,
	               X_Global_Attribute3,
	               X_Global_Attribute4,
	               X_Global_Attribute5,
	               X_Global_Attribute6,
	               X_Global_Attribute7,
	               X_Global_Attribute8,
	               X_Global_Attribute9,
	               X_Global_Attribute10,
	               X_Global_Attribute11,
	               X_Global_Attribute12,
	               X_Global_Attribute13,
	               X_Global_Attribute14,
	               X_Global_Attribute15,
	               X_Global_Attribute16,
	               X_Global_Attribute17,
	               X_Global_Attribute18,
	               X_Global_Attribute19,
	               X_Global_Attribute20,
		       X_Country_of_Origin_Code,
		       X_Invoice_Match_Option,  --bgu, Dec. 7, 98
                       p_value_basis,               -- <Complex Work R12>
                       p_matching_basis,            -- <Complex Work R12>
		       --togeorge 10/03/2000
		       --added note to receiver
		       X_note_to_receiver,
--Start of Bug# 1548597.
                       X_Secondary_Unit_Of_Measure,
                       X_Secondary_Quantity,
                       X_Preferred_Grade,
                       X_Secondary_Quantity_Received,
                       X_Secondary_Quantity_Accepted,
                       X_Secondary_Quantity_Rejected,
                       X_Secondary_Quantity_Cancelled,
-- end of Bug# 1548597
                       X_Consigned_Flag,  /* CONSIGNED FPI */
                       X_amount,  -- <SERVICES FPJ>
                       p_transaction_flow_header_id  --< Shared Proc FPJ >
                       ,NULL      --p_manual_price_change_flag  -- <Manual Price Override FPJ>
                       ,p_org_id                     -- <R12.MOAC>
		       ,p_outsourced_assembly  --<SHIKYU R12>
		       );

EXCEPTION
    WHEN OTHERS THEN
        po_message_s.sql_error('PO_SHIPMENTS_SV6.insert_po_shipment', X_progress, sqlcode);
        raise;
END insert_po_shipment;

END  PO_SHIPMENTS_SV6;

/
