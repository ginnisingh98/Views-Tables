--------------------------------------------------------
--  DDL for Package Body PO_LINE_LOCATIONS_PKG_S0
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_LINE_LOCATIONS_PKG_S0" as
/* $Header: POXP1PSB.pls 120.6 2005/08/29 00:26:09 vsanjay noship $ */

PROCEDURE Insert_Row
(
    X_Rowid                   IN OUT NOCOPY VARCHAR2,
    X_Line_Location_Id        IN OUT NOCOPY NUMBER,
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
    X_Tax_Code_ID                    NUMBER,
    X_Tax_User_Override_Flag         VARCHAR2,
    X_Calculate_Tax_Flag             VARCHAR2,
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
    X_Global_Attribute_Category      VARCHAR2,
    X_Global_Attribute1              VARCHAR2,
    X_Global_Attribute2              VARCHAR2,
    X_Global_Attribute3              VARCHAR2,
    X_Global_Attribute4              VARCHAR2,
    X_Global_Attribute5              VARCHAR2,
    X_Global_Attribute6              VARCHAR2,
    X_Global_Attribute7              VARCHAR2,
    X_Global_Attribute8              VARCHAR2,
    X_Global_Attribute9              VARCHAR2,
    X_Global_Attribute10             VARCHAR2,
    X_Global_Attribute11             VARCHAR2,
    X_Global_Attribute12             VARCHAR2,
    X_Global_Attribute13             VARCHAR2,
    X_Global_Attribute14             VARCHAR2,
    X_Global_Attribute15             VARCHAR2,
    X_Global_Attribute16             VARCHAR2,
    X_Global_Attribute17             VARCHAR2,
    X_Global_Attribute18             VARCHAR2,
    X_Global_Attribute19             VARCHAR2,
    X_Global_Attribute20             VARCHAR2,
    X_Country_of_Origin_Code         VARCHAR2,
    X_Invoice_Match_Option           VARCHAR2, -- bgu, Dec. 7, 98
    p_value_basis               IN   VARCHAR2, -- <Complex Work R12>
    p_matching_basis            IN   VARCHAR2, -- <Complex Work R12>
    --togeorge 10/03/2000
    --added note to receiver
    X_note_to_receiver               VARCHAR2,
    -- Mahesh Chandak(GML) Add 7 process related fields.
    -- start of Bug# 1548597
    X_Secondary_Unit_Of_Measure      VARCHAR2,
    X_Secondary_Quantity             NUMBER,
    X_Preferred_Grade                VARCHAR2,
    X_Secondary_Quantity_Received    NUMBER,
    X_Secondary_Quantity_Accepted    NUMBER,
    X_Secondary_Quantity_Rejected    NUMBER,
    X_Secondary_Quantity_Cancelled   NUMBER,
    -- end of Bug# 1548597
    X_Consigned_Flag                 VARCHAR2,  /* CONSIGNED FPI */
    X_amount                         NUMBER,  -- <SERVICES FPJ>
    p_transaction_flow_header_id     NUMBER,  --< Shared Proc FPJ >
    p_manual_price_change_flag       VARCHAR2, --< Manual Price Override FPJ >
    p_org_id                       IN NUMBER,          -- <R12.MOAC>
    p_outsourced_assembly          IN NUMBER default 2 --<SHIKYU R12>
)
IS
     CURSOR C IS SELECT rowid FROM PO_LINE_LOCATIONS
                 WHERE line_location_id = X_Line_Location_Id;

      CURSOR C2 IS SELECT po_line_locations_s.nextval FROM sys.dual;
      l_tax_attribute_update_code PO_LINE_LOCATIONS_ALL.tax_attribute_update_code%type; --<eTax Integration R12>

    BEGIN
      if (X_Line_Location_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Line_Location_Id;
        CLOSE C2;
      end if;
       --<eTax Integration  R12>
      IF X_Shipment_Type in ('STANDARD', 'PLANNED', 'BLANKET', 'SCHEDULED') THEN
            l_tax_attribute_update_code := 'CREATE';
      END IF;

       INSERT INTO PO_LINE_LOCATIONS(
               line_location_id,
               last_update_date,
               last_updated_by,
               po_header_id,
               po_line_id,
               last_update_login,
               creation_date,
               created_by,
               quantity,
               quantity_received,
               quantity_accepted,
               quantity_rejected,
               quantity_billed,
               quantity_cancelled,
               unit_meas_lookup_code,
               po_release_id,
               ship_to_location_id,
               ship_via_lookup_code,
               need_by_date,
               promised_date,
               last_accept_date,
               price_override,
               encumbered_flag,
               encumbered_date,
               fob_lookup_code,
               freight_terms_lookup_code,
               taxable_flag,
	       calculate_tax_flag,
               from_header_id,
               from_line_id,
               from_line_location_id,
               start_date,
               end_date,
               lead_time,
               lead_time_unit,
               price_discount,
               terms_id,
               approved_flag,
               approved_date,
               closed_flag,
               cancel_flag,
               cancelled_by,
               cancel_date,
               cancel_reason,
               firm_status_lookup_code,
               attribute_category,
               attribute1,
               attribute2,
               attribute3,
               attribute4,
               attribute5,
               attribute6,
               attribute7,
               attribute8,
               attribute9,
               attribute10,
               attribute11,
               attribute12,
               attribute13,
               attribute14,
               attribute15,
               inspection_required_flag,
               receipt_required_flag,
               qty_rcv_tolerance,
               qty_rcv_exception_code,
               enforce_ship_to_location_code,
               allow_substitute_receipts_flag,
               days_early_receipt_allowed,
               days_late_receipt_allowed,
               receipt_days_exception_code,
               invoice_close_tolerance,
               receive_close_tolerance,
               ship_to_organization_id,
               shipment_num,
               source_shipment_id,
               shipment_type,
               closed_code,
               government_context,
               receiving_routing_id,
               accrue_on_receipt_flag,
               closed_reason,
               closed_date,
               closed_by,
		global_attribute_category,
		global_attribute1,
		global_attribute2,
		global_attribute3,
		global_attribute4,
		global_attribute5,
		global_attribute6,
		global_attribute7,
		global_attribute8,
		global_attribute9,
		global_attribute10,
		global_attribute11,
		global_attribute12,
		global_attribute13,
		global_attribute14,
		global_attribute15,
		global_attribute16,
		global_attribute17,
		global_attribute18,
		global_attribute19,
		global_attribute20,
	 	country_of_origin_code,
	        match_option, --bgu, Dec. 7, 98
		--togeorge 10/03/2000
		--added note to receiver
		note_to_receiver,
--Start of 1548597.Add 7 fields in the insert clause
                secondary_unit_of_measure,
                secondary_quantity,
                preferred_grade,
                secondary_quantity_received,
                secondary_quantity_accepted,
                secondary_quantity_rejected,
                secondary_quantity_cancelled,
--end of 1548597
                consigned_flag,  /* CONSIGNED FPI */
                amount,  -- <SERVICES FPJ>
                transaction_flow_header_id,  --< Shared Proc FPJ >
                manual_price_change_flag  --<  Manual Price Override FPJ >
                  --<DBI Req Fulfillment 11.5.11 Start >
                ,shipment_closed_date
                ,closed_for_receiving_date
                ,closed_for_invoice_date
                --<DBI Req Fulfillment 11.5.11 End >
		,Org_Id                -- <R12.MOAC>
                , value_basis    -- <Complex Work R12>
                , matching_basis -- <Complex Work R12>
                , outsourced_assembly --<SHIKYU R12>
                , tax_attribute_update_code --<eTax Integration R12>
             ) VALUES (
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
               p_transaction_flow_header_id,  --< Shared Proc FPJ >
               p_manual_price_change_flag  --< Manual Price Override FPJ >
               --<DBI Req Fulfillment 11.5.11 Start >
              ,decode(X_Closed_code,'CLOSED',
	             nvl(X_closed_date,sysdate), null)      ---- Shipment_closed_date
              , decode(X_Closed_code,'CLOSED',nvl(X_closed_date,sysdate),
                 'CLOSED FOR RECEIVING',sysdate,null)     --- Closed_for_receiving
              , decode(X_Closed_code,'CLOSED',nvl(X_closed_date,sysdate),
                 'CLOSED FOR INVOICE',sysdate,null)      -- closed_for_invoice_date
              --<DBI Req Fulfillment 11.5.11 End >
	      ,p_org_id                -- <R12.MOAC>
              , p_value_basis     -- <Complex Work R12>
              , p_matching_basis  -- <Complex Work R12>
              , p_outsourced_assembly --<SHIKYU R12>
              ,l_tax_attribute_update_code --<eTax integration R12>
	);

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;
END PO_LINE_LOCATIONS_PKG_S0;

/
