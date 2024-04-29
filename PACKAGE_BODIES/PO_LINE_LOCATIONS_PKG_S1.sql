--------------------------------------------------------
--  DDL for Package Body PO_LINE_LOCATIONS_PKG_S1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_LINE_LOCATIONS_PKG_S1" as
/* $Header: POXP2PSB.pls 120.2.12010000.2 2012/08/31 08:48:59 hliao ship $ */
-- Read the profile option that enables/disables the debug log
g_fnd_debug CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

c_log_head    CONSTANT VARCHAR2(40) := 'po.plsql.PO_LINE_LOCATIONS_PKG_S1.';

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Line_Location_Id                 NUMBER,
                     X_Po_Header_Id                     NUMBER,
                     X_Po_Line_Id                       NUMBER,
                     X_Quantity                         NUMBER,
                     X_Quantity_Received                NUMBER,
                     X_Quantity_Accepted                NUMBER,
                     X_Quantity_Rejected                NUMBER,
                     X_Quantity_Billed                  NUMBER,
                     X_Quantity_Cancelled               NUMBER,
                     X_Unit_Meas_Lookup_Code            VARCHAR2,
                     X_Po_Release_Id                    NUMBER,
                     X_Ship_To_Location_Id              NUMBER,
                     X_Ship_Via_Lookup_Code             VARCHAR2,
                     X_Need_By_Date                     DATE,
                     X_Promised_Date                    DATE,
                     X_Last_Accept_Date                 DATE,
                     X_Price_Override                   NUMBER,
                     X_Encumbered_Flag                  VARCHAR2,
                     X_Encumbered_Date                  DATE,
                     X_Fob_Lookup_Code                  VARCHAR2,
                     X_Freight_Terms_Lookup_Code        VARCHAR2,
                     X_Tax_Code_Id                      NUMBER,
		     X_Tax_User_Override_Flag		VARCHAR2,
                     X_From_Header_Id                   NUMBER,
                     X_From_Line_Id                     NUMBER,
                     X_From_Line_Location_Id            NUMBER,
                     X_Start_Date                       DATE,
                     X_End_Date                         DATE,
                     X_Lead_Time                        NUMBER,
                     X_Lead_Time_Unit                   VARCHAR2,
                     X_Price_Discount                   NUMBER,
                     X_Terms_Id                         NUMBER,
                     X_Approved_Flag                    VARCHAR2,
                     X_Approved_Date                    DATE,
                     X_Closed_Flag                      VARCHAR2,
                     X_Cancel_Flag                      VARCHAR2,
                     X_Cancelled_By                     NUMBER,
                     X_Cancel_Date                      DATE,
                     X_Cancel_Reason                    VARCHAR2,
                     X_Firm_Status_Lookup_Code          VARCHAR2,
                     X_Attribute_Category               VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2,
                     X_Inspection_Required_Flag         VARCHAR2,
                     X_Receipt_Required_Flag            VARCHAR2,
                     X_Qty_Rcv_Tolerance                NUMBER,
                     X_Qty_Rcv_Exception_Code           VARCHAR2,
                     X_Enforce_Ship_To_Location         VARCHAR2,
                     X_Allow_Substitute_Receipts        VARCHAR2,
                     X_Days_Early_Receipt_Allowed       NUMBER,
                     X_Days_Late_Receipt_Allowed        NUMBER,
                     X_Receipt_Days_Exception_Code      VARCHAR2,
                     X_Invoice_Close_Tolerance          NUMBER,
                     X_Receive_Close_Tolerance          NUMBER,
                     X_Ship_To_Organization_Id          NUMBER,
                     X_Shipment_Num                     NUMBER,
                     X_Source_Shipment_Id               NUMBER,
                     X_Shipment_Type                    VARCHAR2,
                     X_Closed_Code                      VARCHAR2,
                     X_Ussgl_Transaction_Code           VARCHAR2,
                     X_Government_Context               VARCHAR2,
                     X_Receiving_Routing_Id             NUMBER,
                     X_Accrue_On_Receipt_Flag           VARCHAR2,
                     X_Closed_Reason                    VARCHAR2,
                     X_Closed_Date                      DATE,
                     X_Closed_By                        NUMBER,
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
		     X_Country_of_Origin_Code		  VARCHAR2,
		     X_Invoice_Match_Option		  VARCHAR2,  --bgu, Dec. 7, 98
-- Mahesh Chandak(GML) Add process related fields secondary_quantity, preferred
--grade and received,rejected,accepted and cancelled sec. qnty.Secondary_unit_of
--measure is not required since this is not populated in release form in po_line_locations_all but is referenced from the view. Bug# 1548597
                     X_Secondary_Quantity               NUMBER  default null,
                     X_Preferred_Grade                  VARCHAR2 default null,
                     X_Secondary_Quantity_Received      NUMBER default null,
                     X_Secondary_Quantity_Accepted      NUMBER default null,
                     X_Secondary_Quantity_Rejected      NUMBER default null,
                     X_Secondary_Quantity_Cancelled     NUMBER default null,
                     X_amount                           NUMBER default null  -- <SERVICES FPJ>
  ) IS
    CURSOR C IS
        SELECT *
        FROM   PO_LINE_LOCATIONS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Line_Location_Id NOWAIT;
    Recinfo C%ROWTYPE;

    l_purchase_basis po_lines_all.purchase_basis%TYPE;
	  -- For debug purposes
    l_api_name CONSTANT VARCHAR2(30) := 'Lock_Row';

  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;

    -- SERVICES FPJ Bug 3262883
    Begin
      -- SQL What : gets the purchase basis from the PO line
      -- SQL Why  : To use in the lock row to not compare amounts for temp
      --            labor lines
      SELECT purchase_basis
      INTO   l_purchase_basis
      FROM   po_lines_all
      WHERE  po_line_id = Recinfo.po_line_id;
    Exception
      when others then
        APP_EXCEPTION.RAISE_EXCEPTION;
    end;

    if (

               (Recinfo.line_location_id = X_Line_Location_Id)
           AND (Recinfo.po_header_id = X_Po_Header_Id)
           AND (Recinfo.po_line_id = X_Po_Line_Id)
           AND (   (Recinfo.quantity = X_Quantity)
                OR (    (Recinfo.quantity IS NULL)
                    AND (X_Quantity IS NULL)))
           AND (   (Recinfo.quantity_received = X_Quantity_Received)
                OR (    (Recinfo.quantity_received IS NULL)
                    AND (X_Quantity_Received IS NULL)))
           AND (   (Recinfo.quantity_accepted = X_Quantity_Accepted)
                OR (    (Recinfo.quantity_accepted IS NULL)
                    AND (X_Quantity_Accepted IS NULL)))
           AND (   (Recinfo.quantity_rejected = X_Quantity_Rejected)
                OR (    (Recinfo.quantity_rejected IS NULL)
                    AND (X_Quantity_Rejected IS NULL)))
           AND (   (Recinfo.quantity_billed = X_Quantity_Billed)
                OR (    (Recinfo.quantity_billed IS NULL)
                    AND (X_Quantity_Billed IS NULL)))
           AND (   (Recinfo.quantity_cancelled = X_Quantity_Cancelled)
                OR (    (Recinfo.quantity_cancelled IS NULL)
                    AND (X_Quantity_Cancelled IS NULL)))
-- bug# 2249466.Do check for OPM related fields only if Common Receiving is
-- installed.
-- Mahesh Chandak(GML) Bug# 1548597 Include check for secondary_quantity and preferred grade also
--Start of 1548597
-- 2249466.add a call for CR installed or not.

/* BUG 3285605 : Issue resolved. Added the condition so that secondary values are not compared
   for RFQs and QUOTATIONS. This has been done since RFQs and QUOTEs were kept out of scope while
   building the integration of OPM and PURCHASING. Hence secondary values are not present on the
   RFQ and QUOTE forms, but while autocreating OPM imported requisitions to RFQs these values are
   populated to the PO_HEADERS table.*/

           AND ( NOT GML_PO_FOR_PROCESS.check_po_for_proc
           OR (

		 (X_shipment_type in ('RFQ','QUOTATION'))  --BUG 3285605 added this condition so that
							   --secondary quantity is not compared for RFQ and Quotation
                OR  ((Recinfo.secondary_quantity = X_Secondary_Quantity)
                OR (    (Recinfo.secondary_quantity IS NULL)
                    AND (X_Secondary_Quantity IS NULL)))
           AND (   (TRIM(Recinfo.preferred_grade) = TRIM(X_Preferred_Grade))
                OR (    (TRIM(Recinfo.preferred_grade) IS NULL)
                    AND (TRIM(X_preferred_grade) IS NULL)))
           AND (   (Recinfo.secondary_quantity_received = X_secondary_Quantity_Received)
                OR (    (Recinfo.secondary_quantity_received IS NULL)
                    AND (X_Secondary_Quantity_Received IS NULL)))
           AND (   (Recinfo.secondary_quantity_accepted = X_Secondary_Quantity_Accepted)
                OR (    (Recinfo.secondary_quantity_accepted IS NULL)
                    AND (X_Secondary_Quantity_Accepted IS NULL)))
           AND (   (Recinfo.secondary_quantity_rejected = X_Secondary_Quantity_Rejected)
                OR (    (Recinfo.secondary_quantity_rejected IS NULL)
                    AND (X_Secondary_Quantity_Rejected IS NULL)))
           AND (   (Recinfo.secondary_quantity_cancelled = X_Secondary_Quantity_Cancelled)
                OR (    (Recinfo.secondary_quantity_cancelled IS NULL)
                    AND (X_Secondary_Quantity_Cancelled IS NULL)))
            ))
--end of 1548597
/* Do not need unit_meas_lookup_code as it is NOT from PO_LINE_LOCATIONS
** in the form.Also, it is just a display field
            AND (   (Recinfo.unit_meas_lookup_code = X_Unit_Meas_Lookup_Code)
           --     OR (    (Recinfo.unit_meas_lookup_code IS NULL)
           --         AND (X_Unit_Meas_Lookup_Code IS NULL)))  */
           AND (   (Recinfo.po_release_id = X_Po_Release_Id)
                OR (    (Recinfo.po_release_id IS NULL)
                    AND (X_Po_Release_Id IS NULL)))
           AND (   (Recinfo.ship_to_location_id = X_Ship_To_Location_Id)
                OR (    (Recinfo.ship_to_location_id IS NULL)
                    AND (X_Ship_To_Location_Id IS NULL)))
           AND (   (TRIM(Recinfo.ship_via_lookup_code) = TRIM(X_Ship_Via_Lookup_Code))
                OR (    (TRIM(Recinfo.ship_via_lookup_code) IS NULL)
                    AND (TRIM(X_Ship_Via_Lookup_Code) IS NULL)))
           AND (   (trunc(Recinfo.need_by_date) = trunc(X_Need_By_Date))
                OR (    (Recinfo.need_by_date IS NULL)
                    AND (X_Need_By_Date IS NULL)))
           AND (   (trunc(Recinfo.promised_date) = trunc(X_Promised_Date))
                OR (    (Recinfo.promised_date IS NULL)
                    AND (X_Promised_Date IS NULL)))
           AND (   (trunc(Recinfo.last_accept_date) = trunc(X_Last_Accept_Date))
                OR (    (Recinfo.last_accept_date IS NULL)
                    AND (X_Last_Accept_Date IS NULL)))
           AND (   (Recinfo.price_override = X_Price_Override)
                OR (    (Recinfo.price_override IS NULL)
                    AND (X_Price_Override IS NULL)))
           AND (   (nvl(TRIM(Recinfo.encumbered_flag),'N') = TRIM(X_Encumbered_Flag))
                OR (    (TRIM(Recinfo.encumbered_flag) IS NULL)
                    AND (TRIM(X_Encumbered_Flag) IS NULL)))
           AND (   (trunc(Recinfo.encumbered_date) = trunc(X_Encumbered_Date))
                OR (    (Recinfo.encumbered_date IS NULL)
                    AND (X_Encumbered_Date IS NULL)))
           AND (   (TRIM(Recinfo.fob_lookup_code) = TRIM(X_Fob_Lookup_Code))
                OR (    (TRIM(Recinfo.fob_lookup_code) IS NULL)
                    AND (TRIM(X_Fob_Lookup_Code) IS NULL)))
           AND (   (TRIM(Recinfo.freight_terms_lookup_code) = TRIM(X_Freight_Terms_Lookup_Code))
                OR (    (TRIM(Recinfo.freight_terms_lookup_code) IS NULL)
                    AND (TRIM(X_Freight_Terms_Lookup_Code) IS NULL)))
           AND (   (Recinfo.from_header_id = X_From_Header_Id)
                OR (    (Recinfo.from_header_id IS NULL)
                    AND (X_From_Header_Id IS NULL)))
           AND (   (Recinfo.from_line_id = X_From_Line_Id)
                OR (    (Recinfo.from_line_id IS NULL)
                    AND (X_From_Line_Id IS NULL)))
           AND (   (Recinfo.from_line_location_id = X_From_Line_Location_Id)
                OR (    (Recinfo.from_line_location_id IS NULL)
                    AND (X_From_Line_Location_Id IS NULL)))
           AND (   (trunc(Recinfo.start_date) = trunc(X_Start_Date))
                OR (    (Recinfo.start_date IS NULL)
                    AND (X_Start_Date IS NULL)))
           AND (   (trunc(Recinfo.end_date) = trunc(X_End_Date))
                OR (    (Recinfo.end_date IS NULL)
                    AND (X_End_Date IS NULL)))
           AND (   (Recinfo.lead_time = X_Lead_Time)
                OR (    (Recinfo.lead_time IS NULL)
                    AND (X_Lead_Time IS NULL)))
           AND (   (TRIM(Recinfo.lead_time_unit) = TRIM(X_Lead_Time_Unit))
                OR (    (TRIM(Recinfo.lead_time_unit) IS NULL)
                    AND (TRIM(X_Lead_Time_Unit) IS NULL)))
           AND (   (Recinfo.price_discount = X_Price_Discount)
                OR (    (Recinfo.price_discount IS NULL)
                    AND (X_Price_Discount IS NULL)))
           AND (   (Recinfo.terms_id = X_Terms_Id)
                OR (    (Recinfo.terms_id IS NULL)
                    AND (X_Terms_Id IS NULL)))
           AND (   (TRIM(Recinfo.approved_flag) = TRIM(X_Approved_Flag))
                OR (    (TRIM(Recinfo.approved_flag) IS NULL)
                    AND (TRIM(X_Approved_Flag) IS NULL)))
           AND (   (trunc(Recinfo.approved_date) = trunc(X_Approved_Date))
                OR (    (Recinfo.approved_date IS NULL)
                    AND (X_Approved_Date IS NULL)))
           AND (   (TRIM(Recinfo.closed_flag) = TRIM(X_Closed_Flag))
                OR (    (TRIM(Recinfo.closed_flag) IS NULL)
                    AND (TRIM(X_Closed_Flag) IS NULL)))
           AND (   (TRIM(Recinfo.cancel_flag) = TRIM(X_Cancel_Flag))
                OR (    (TRIM(Recinfo.cancel_flag) IS NULL)
                    AND (TRIM(X_Cancel_Flag) IS NULL)))
           AND (   (Recinfo.cancelled_by = X_Cancelled_By)
                OR (    (Recinfo.cancelled_by IS NULL)
                    AND (X_Cancelled_By IS NULL)))
           AND (   (trunc(Recinfo.cancel_date) = trunc(X_Cancel_Date))
                OR (    (Recinfo.cancel_date IS NULL)
                    AND (X_Cancel_Date IS NULL)))
           AND (   (TRIM(Recinfo.cancel_reason) = TRIM(X_Cancel_Reason))
                OR (    (TRIM(Recinfo.cancel_reason) IS NULL)
                    AND (TRIM(X_Cancel_Reason) IS NULL)))
           AND (   (TRIM(Recinfo.firm_status_lookup_code) = TRIM(X_Firm_Status_Lookup_Code))
                OR (    (TRIM(Recinfo.firm_status_lookup_code) IS NULL)
                    AND (TRIM(X_Firm_Status_Lookup_Code) IS NULL)))
           AND (   (TRIM(Recinfo.attribute_category) = TRIM(X_Attribute_Category))
                OR (    (TRIM(Recinfo.attribute_category) IS NULL)
                    AND (TRIM(X_Attribute_Category) IS NULL)))
           AND (   (TRIM(Recinfo.attribute1) = TRIM(X_Attribute1))
                OR (    (TRIM(Recinfo.attribute1) IS NULL)
                    AND (TRIM(X_Attribute1) IS NULL)))
           AND (   (TRIM(Recinfo.attribute2) = TRIM(X_Attribute2))
                OR (    (TRIM(Recinfo.attribute2) IS NULL)
                    AND (TRIM(X_Attribute2) IS NULL)))
           AND (   (TRIM(Recinfo.attribute3) = TRIM(X_Attribute3))
                OR (    (TRIM(Recinfo.attribute3) IS NULL)
                    AND (TRIM(X_Attribute3) IS NULL)))
           AND (   (TRIM(Recinfo.attribute4) = TRIM(X_Attribute4))
                OR (    (TRIM(Recinfo.attribute4) IS NULL)
                    AND (TRIM(X_Attribute4) IS NULL)))
           AND (   (TRIM(Recinfo.attribute5) = TRIM(X_Attribute5))
                OR (    (TRIM(Recinfo.attribute5) IS NULL)
                    AND (TRIM(X_Attribute5) IS NULL)))
           AND (   (TRIM(Recinfo.attribute6) = TRIM(X_Attribute6))
                OR (    (TRIM(Recinfo.attribute6) IS NULL)
                    AND (TRIM(X_Attribute6) IS NULL)))
           AND (   (TRIM(Recinfo.attribute7) = TRIM(X_Attribute7))
                OR (    (TRIM(Recinfo.attribute7) IS NULL)
                    AND (TRIM(X_Attribute7) IS NULL)))
           AND (   (TRIM(Recinfo.attribute8) = TRIM(X_Attribute8))
                OR (    (TRIM(Recinfo.attribute8) IS NULL)
                    AND (TRIM(X_Attribute8) IS NULL)))
           AND (   (TRIM(Recinfo.attribute9) = TRIM(X_Attribute9))
                OR (    (TRIM(Recinfo.attribute9) IS NULL)
                    AND (TRIM(X_Attribute9) IS NULL)))
           AND (   (TRIM(Recinfo.attribute10) = TRIM(X_Attribute10))
                OR (    (TRIM(Recinfo.attribute10) IS NULL)
                    AND (TRIM(X_Attribute10) IS NULL)))
           AND (   (TRIM(Recinfo.attribute11) = TRIM(X_Attribute11))
                OR (    (TRIM(Recinfo.attribute11) IS NULL)
                    AND (TRIM(X_Attribute11) IS NULL)))
           AND (   (TRIM(Recinfo.attribute12) = TRIM(X_Attribute12))
                OR (    (TRIM(Recinfo.attribute12) IS NULL)
                    AND (TRIM(X_Attribute12) IS NULL)))
           AND (   (TRIM(Recinfo.attribute13) = TRIM(X_Attribute13))
                OR (    (TRIM(Recinfo.attribute13) IS NULL)
                    AND (TRIM(X_Attribute13) IS NULL)))
           AND (   (TRIM(Recinfo.attribute14) = TRIM(X_Attribute14))
                OR (    (TRIM(Recinfo.attribute14) IS NULL)
                    AND (TRIM(X_Attribute14) IS NULL)))
           AND (   (TRIM(Recinfo.attribute15) = TRIM(X_Attribute15))
                OR (    (TRIM(Recinfo.attribute15) IS NULL)
                    AND (TRIM(X_Attribute15) IS NULL)))
           -- <SERVICES FPJ START>
           AND  (l_purchase_basis = 'TEMP LABOR' OR
                (   (Recinfo.amount = X_amount)
                OR (    (Recinfo.amount IS NULL)
                    AND (X_amount IS NULL))))
           -- <SERVICES FPJ END>
	) then
           if (

               (   (TRIM(Recinfo.inspection_required_flag) = TRIM(X_Inspection_Required_Flag))
                OR (    (TRIM(Recinfo.inspection_required_flag) IS NULL)
                    AND (TRIM(X_Inspection_Required_Flag) IS NULL)))
           AND (   (TRIM(Recinfo.receipt_required_flag) = TRIM(X_Receipt_Required_Flag))
                OR (    (TRIM(Recinfo.receipt_required_flag) IS NULL)
                    AND (TRIM(X_Receipt_Required_Flag) IS NULL)))
           AND (   (Recinfo.qty_rcv_tolerance = X_Qty_Rcv_Tolerance)
                OR (    (Recinfo.qty_rcv_tolerance IS NULL)
                    AND (X_Qty_Rcv_Tolerance IS NULL)))
           AND (   (TRIM(Recinfo.qty_rcv_exception_code) = TRIM(X_Qty_Rcv_Exception_Code))
                OR (    (TRIM(Recinfo.qty_rcv_exception_code) IS NULL)
                    AND (TRIM(X_Qty_Rcv_Exception_Code) IS NULL)))
           AND (   (TRIM(Recinfo.enforce_ship_to_location_code) = TRIM(X_Enforce_Ship_To_Location))
                OR (    (TRIM(Recinfo.enforce_ship_to_location_code) IS NULL)
                    AND (TRIM(X_Enforce_Ship_To_Location) IS NULL)))
           AND (   (TRIM(Recinfo.allow_substitute_receipts_flag) = TRIM(X_Allow_Substitute_Receipts))
                OR (    (TRIM(Recinfo.allow_substitute_receipts_flag) IS NULL)
                    AND (TRIM(X_Allow_Substitute_Receipts) IS NULL)))
           AND (   (Recinfo.days_early_receipt_allowed = X_Days_Early_Receipt_Allowed)
                OR (    (Recinfo.days_early_receipt_allowed IS NULL)
                    AND (X_Days_Early_Receipt_Allowed IS NULL)))
           AND (   (Recinfo.days_late_receipt_allowed = X_Days_Late_Receipt_Allowed)
                OR (    (Recinfo.days_late_receipt_allowed IS NULL)
                    AND (X_Days_Late_Receipt_Allowed IS NULL)))
           AND (   (TRIM(Recinfo.receipt_days_exception_code) = TRIM(X_Receipt_Days_Exception_Code))
                OR (    (TRIM(Recinfo.receipt_days_exception_code) IS NULL)
                    AND (TRIM(X_Receipt_Days_Exception_Code) IS NULL)))
           AND (   (Recinfo.invoice_close_tolerance = X_Invoice_Close_Tolerance)
                OR (    (Recinfo.invoice_close_tolerance IS NULL)
                    AND (X_Invoice_Close_Tolerance IS NULL)))
           AND (   (Recinfo.receive_close_tolerance = X_Receive_Close_Tolerance)
                OR (    (Recinfo.receive_close_tolerance IS NULL)
                    AND (X_Receive_Close_Tolerance IS NULL)))
           AND (   (NVL(TRIM(Recinfo.match_option),'P') = NVL(TRIM(X_Invoice_Match_Option),'P')))   --bgu, Dec. 7, 98
           AND (   (Recinfo.ship_to_organization_id = X_Ship_To_Organization_Id)
                OR (    (Recinfo.ship_to_organization_id IS NULL)
                    AND (X_Ship_To_Organization_Id IS NULL)))
           AND (   (Recinfo.shipment_num = X_Shipment_Num)
                OR (    (Recinfo.shipment_num IS NULL)
                    AND (X_Shipment_Num IS NULL)))
           AND (   (Recinfo.source_shipment_id = X_Source_Shipment_Id)
                OR (    (Recinfo.source_shipment_id IS NULL)
                    AND (X_Source_Shipment_Id IS NULL)))
           AND (TRIM(Recinfo.shipment_type) = TRIM(X_Shipment_Type))
           AND (   (TRIM(Recinfo.closed_code) = TRIM(X_Closed_Code))
                OR (    (TRIM(Recinfo.closed_code) IS NULL)
                    AND (TRIM(X_Closed_Code) IS NULL)))
           AND (   (TRIM(Recinfo.government_context) = TRIM(X_Government_Context))
                OR (    (TRIM(Recinfo.government_context) IS NULL)
                    AND (TRIM(X_Government_Context) IS NULL)))
           AND (   (Recinfo.receiving_routing_id = X_Receiving_Routing_Id)
                OR (    (Recinfo.receiving_routing_id IS NULL)
                    AND (X_Receiving_Routing_Id IS NULL)))
           AND (   (TRIM(Recinfo.accrue_on_receipt_flag) = TRIM(X_Accrue_On_Receipt_Flag))
                OR (    (TRIM(Recinfo.accrue_on_receipt_flag) IS NULL)
                    AND (TRIM(X_Accrue_On_Receipt_Flag) IS NULL)))
           AND (   (TRIM(Recinfo.closed_reason) = TRIM(X_Closed_Reason))
                OR (    (TRIM(Recinfo.closed_reason) IS NULL)
                    AND (TRIM(X_Closed_Reason) IS NULL)))
           AND (   (trunc(Recinfo.closed_date) = trunc(X_Closed_Date))
                OR (    (Recinfo.closed_date IS NULL)
                    AND (X_Closed_Date IS NULL)))
           AND (   (Recinfo.closed_by = X_Closed_By)
                OR (    (Recinfo.closed_by IS NULL)
                    AND (X_Closed_By IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute_category) = TRIM(X_Global_Attribute_Category))
                OR (    (TRIM(Recinfo.global_attribute_category) IS NULL)
                    AND (TRIM(X_Global_Attribute_Category) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute1) = TRIM(X_Global_Attribute1))
                OR (    (TRIM(Recinfo.global_attribute1) IS NULL)
                    AND (TRIM(X_Global_Attribute1) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute2) = TRIM(X_Global_Attribute2))
                OR (    (TRIM(Recinfo.global_attribute2) IS NULL)
                    AND (TRIM(X_Global_Attribute2) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute3) = TRIM(X_Global_Attribute3))
                OR (    (TRIM(Recinfo.global_attribute3) IS NULL)
                    AND (TRIM(X_Global_Attribute3) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute4) = TRIM(X_Global_Attribute4))
                OR (    (TRIM(Recinfo.global_attribute4) IS NULL)
                    AND (TRIM(X_Global_Attribute4) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute5) = TRIM(X_Global_Attribute5))
                OR (    (TRIM(Recinfo.global_attribute5) IS NULL)
                    AND (TRIM(X_Global_Attribute5) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute6) = TRIM(X_Global_Attribute6))
                OR (    (TRIM(Recinfo.global_attribute6) IS NULL)
                    AND (TRIM(X_Global_Attribute6) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute7) = TRIM(X_Global_Attribute7))
                OR (    (TRIM(Recinfo.global_attribute7) IS NULL)
                    AND (TRIM(X_Global_Attribute7) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute8) = TRIM(X_Global_Attribute8))
                OR (    (TRIM(Recinfo.global_attribute8) IS NULL)
                    AND (TRIM(X_Global_Attribute8) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute9) = TRIM(X_Global_Attribute9))
                OR (    (TRIM(Recinfo.global_attribute9) IS NULL)
                    AND (TRIM(X_Global_Attribute9) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute10) = TRIM(X_Global_Attribute10))
                OR (    (TRIM(Recinfo.global_attribute10) IS NULL)
                    AND (TRIM(X_Global_Attribute10) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute11) = TRIM(X_Global_Attribute11))
                OR (    (TRIM(Recinfo.global_attribute11) IS NULL)
                    AND (TRIM(X_Global_Attribute11) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute12) = TRIM(X_Global_Attribute12))
                OR (    (TRIM(Recinfo.global_attribute12) IS NULL)
                    AND (TRIM(X_Global_Attribute12) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute13) = TRIM(X_Global_Attribute13))
                OR (    (TRIM(Recinfo.global_attribute13) IS NULL)
                    AND (TRIM(X_Global_Attribute13) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute14) = TRIM(X_Global_Attribute14))
                OR (    (TRIM(Recinfo.global_attribute14) IS NULL)
                    AND (TRIM(X_Global_Attribute14) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute15) = TRIM(X_Global_Attribute15))
                OR (    (TRIM(Recinfo.global_attribute15) IS NULL)
                    AND (TRIM(X_Global_Attribute15) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute16) = TRIM(X_Global_Attribute16))
                OR (    (TRIM(Recinfo.global_attribute16) IS NULL)
                    AND (TRIM(X_Global_Attribute16) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute17) = TRIM(X_Global_Attribute17))
                OR (    (TRIM(Recinfo.global_attribute17) IS NULL)
                    AND (TRIM(X_Global_Attribute17) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute18) = TRIM(X_Global_Attribute18))
                OR (    (TRIM(Recinfo.global_attribute18) IS NULL)
                    AND (TRIM(X_Global_Attribute18) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute19) = TRIM(X_Global_Attribute19))
                OR (    (TRIM(Recinfo.global_attribute19) IS NULL)
                    AND (TRIM(X_Global_Attribute19) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute20) = TRIM(X_Global_Attribute20))
                OR (    (TRIM(Recinfo.global_attribute20) IS NULL)
                    AND (TRIM(X_Global_Attribute20) IS NULL)))
           AND (   (TRIM(Recinfo.country_of_origin_code) = TRIM(X_Country_Of_Origin_Code))
                OR (    (TRIM(Recinfo.country_of_origin_code) IS NULL)
                    AND (TRIM(X_Country_Of_Origin_Code) IS NULL)))
            ) then
      return;
    else

	    IF (g_fnd_debug = 'Y') THEN
        IF (NVL(X_Line_Location_Id,-999) <> NVL(Recinfo.line_location_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form line_location_id'||X_Line_Location_Id ||' Database  line_location_id '|| Recinfo.line_location_id);
        END IF;
        IF (NVL(X_Po_Header_Id,-999) <> NVL(Recinfo.po_header_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form po_header_id'||X_Po_Header_Id ||' Database  po_header_id '|| Recinfo.po_header_id);
        END IF;
        IF (NVL(X_Po_Line_Id,-999) <> NVL(Recinfo.po_line_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form po_line_id'||X_Po_Line_Id ||' Database  po_line_id '|| Recinfo.po_line_id);
        END IF;
        IF (NVL(X_Quantity,-999) <> NVL(Recinfo.quantity,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form quantity'||X_Quantity ||' Database  quantity '|| Recinfo.quantity);
        END IF;
        IF (NVL(X_Quantity_Received,-999) <> NVL(Recinfo.quantity_received,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form quantity_received'||X_Quantity_Received ||' Database  quantity_received '|| Recinfo.quantity_received);
        END IF;
        IF (NVL(X_Quantity_Accepted,-999) <> NVL(Recinfo.quantity_accepted,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form quantity_accepted'||X_Quantity_Accepted ||' Database  quantity_accepted '|| Recinfo.quantity_accepted);
        END IF;
        IF (NVL(X_Quantity_Rejected,-999) <> NVL(Recinfo.quantity_rejected,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form quantity_rejected'||X_Quantity_Rejected ||' Database  quantity_rejected '|| Recinfo.quantity_rejected);
        END IF;
        IF (NVL(X_Quantity_Billed,-999) <> NVL(Recinfo.quantity_billed,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form quantity_billed'||X_Quantity_Billed ||' Database  quantity_billed '|| Recinfo.quantity_billed);
        END IF;
        IF (NVL(X_Quantity_Cancelled,-999) <> NVL(Recinfo.quantity_cancelled,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form quantity_cancelled'||X_Quantity_Cancelled ||' Database  quantity_cancelled '|| Recinfo.quantity_cancelled);
        END IF;
        IF (NVL(TRIM(X_Unit_Meas_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.unit_meas_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form unit_meas_lookup_code '||X_Unit_Meas_Lookup_Code ||' Database  unit_meas_lookup_code '||Recinfo.unit_meas_lookup_code);
        END IF;
        IF (NVL(X_Po_Release_Id,-999) <> NVL(Recinfo.po_release_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form po_release_id'||X_Po_Release_Id ||' Database  po_release_id '|| Recinfo.po_release_id);
        END IF;
        IF (NVL(X_Ship_To_Location_Id,-999) <> NVL(Recinfo.ship_to_location_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form ship_to_location_id'||X_Ship_To_Location_Id ||' Database  ship_to_location_id '|| Recinfo.ship_to_location_id);
        END IF;
        IF (NVL(TRIM(X_Ship_Via_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.ship_via_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form ship_via_lookup_code '||X_Ship_Via_Lookup_Code ||' Database  ship_via_lookup_code '||Recinfo.ship_via_lookup_code);
        END IF;
        IF (X_Need_By_Date <> Recinfo.need_by_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form need_by_date '||X_Need_By_Date ||' Database  need_by_date '||Recinfo.need_by_date);
        END IF;
        IF (X_Promised_Date <> Recinfo.promised_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form promised_date '||X_Promised_Date ||' Database  promised_date '||Recinfo.promised_date);
        END IF;
        IF (X_Last_Accept_Date <> Recinfo.last_accept_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form last_accept_date '||X_Last_Accept_Date ||' Database  last_accept_date '||Recinfo.last_accept_date);
        END IF;
        IF (NVL(X_Price_Override,-999) <> NVL(Recinfo.price_override,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form price_override'||X_Price_Override ||' Database  price_override '|| Recinfo.price_override);
        END IF;
        IF (NVL(TRIM(X_Encumbered_Flag),'-999') <> NVL( TRIM(Recinfo.encumbered_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form encumbered_flag '||X_Encumbered_Flag ||' Database  encumbered_flag '||Recinfo.encumbered_flag);
        END IF;
        IF (X_Encumbered_Date <> Recinfo.encumbered_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form encumbered_date '||X_Encumbered_Date ||' Database  encumbered_date '||Recinfo.encumbered_date);
        END IF;
        IF (NVL(TRIM(X_Fob_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.fob_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form fob_lookup_code '||X_Fob_Lookup_Code ||' Database  fob_lookup_code '||Recinfo.fob_lookup_code);
        END IF;
        IF (NVL(TRIM(X_Freight_Terms_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.freight_terms_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form freight_terms_lookup_code '||X_Freight_Terms_Lookup_Code ||' Database  freight_terms_lookup_code '||Recinfo.freight_terms_lookup_code);
        END IF;
--        IF (NVL(X_Tax_Code_Id,-999) <> NVL(Recinfo.taRecinfo.code_id,-999)) THEN
--             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form tacode_id'||X_Tax_Code_Id ||' Database  tacode_id '|| Recinfo.taRecinfo.code_id);
--        END IF;
--        IF (NVL(TRIM(X_Tax_User_Override_Flag),'-999') <> NVL( TRIM(Recinfo.taRecinfo.user_override_flag),'-999')) THEN
--             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form tauser_override_flag '||X_Tax_User_Override_Flag ||' Database  tauser_override_flag '||Recinfo.taRecinfo.user_override_flag);
--        END IF;
        IF (NVL(X_From_Header_Id,-999) <> NVL(Recinfo.from_header_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form from_header_id'||X_From_Header_Id ||' Database  from_header_id '|| Recinfo.from_header_id);
        END IF;
        IF (NVL(X_From_Line_Id,-999) <> NVL(Recinfo.from_line_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form from_line_id'||X_From_Line_Id ||' Database  from_line_id '|| Recinfo.from_line_id);
        END IF;
        IF (NVL(X_From_Line_Location_Id,-999) <> NVL(Recinfo.from_line_location_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form from_line_location_id'||X_From_Line_Location_Id ||' Database  from_line_location_id '|| Recinfo.from_line_location_id);
        END IF;
        IF (X_Start_Date <> Recinfo.start_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form start_date '||X_Start_Date ||' Database  start_date '||Recinfo.start_date);
        END IF;
        IF (X_End_Date <> Recinfo.end_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form end_date '||X_End_Date ||' Database  end_date '||Recinfo.end_date);
        END IF;
        IF (NVL(X_Lead_Time,-999) <> NVL(Recinfo.lead_time,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form lead_time'||X_Lead_Time ||' Database  lead_time '|| Recinfo.lead_time);
        END IF;
        IF (NVL(TRIM(X_Lead_Time_Unit),'-999') <> NVL( TRIM(Recinfo.lead_time_unit),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form lead_time_unit '||X_Lead_Time_Unit ||' Database  lead_time_unit '||Recinfo.lead_time_unit);
        END IF;
        IF (NVL(X_Price_Discount,-999) <> NVL(Recinfo.price_discount,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form price_discount'||X_Price_Discount ||' Database  price_discount '|| Recinfo.price_discount);
        END IF;
        IF (NVL(X_Terms_Id,-999) <> NVL(Recinfo.terms_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form terms_id'||X_Terms_Id ||' Database  terms_id '|| Recinfo.terms_id);
        END IF;
        IF (NVL(TRIM(X_Approved_Flag),'-999') <> NVL( TRIM(Recinfo.approved_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form approved_flag '||X_Approved_Flag ||' Database  approved_flag '||Recinfo.approved_flag);
        END IF;
        IF (X_Approved_Date <> Recinfo.approved_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form approved_date '||X_Approved_Date ||' Database  approved_date '||Recinfo.approved_date);
        END IF;
        IF (NVL(TRIM(X_Closed_Flag),'-999') <> NVL( TRIM(Recinfo.closed_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form closed_flag '||X_Closed_Flag ||' Database  closed_flag '||Recinfo.closed_flag);
        END IF;
        IF (NVL(TRIM(X_Cancel_Flag),'-999') <> NVL( TRIM(Recinfo.cancel_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form cancel_flag '||X_Cancel_Flag ||' Database  cancel_flag '||Recinfo.cancel_flag);
        END IF;
        IF (NVL(X_Cancelled_By,-999) <> NVL(Recinfo.cancelled_by,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form cancelled_by'||X_Cancelled_By ||' Database  cancelled_by '|| Recinfo.cancelled_by);
        END IF;
        IF (X_Cancel_Date <> Recinfo.cancel_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form cancel_date '||X_Cancel_Date ||' Database  cancel_date '||Recinfo.cancel_date);
        END IF;
        IF (NVL(TRIM(X_Cancel_Reason),'-999') <> NVL( TRIM(Recinfo.cancel_reason),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form cancel_reason '||X_Cancel_Reason ||' Database  cancel_reason '||Recinfo.cancel_reason);
        END IF;
        IF (NVL(TRIM(X_Firm_Status_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.firm_status_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form firm_status_lookup_code '||X_Firm_Status_Lookup_Code ||' Database  firm_status_lookup_code '||Recinfo.firm_status_lookup_code);
        END IF;
        IF (NVL(TRIM(X_Attribute_Category),'-999') <> NVL( TRIM(Recinfo.attribute_category),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute_category '||X_Attribute_Category ||' Database  attribute_category '||Recinfo.attribute_category);
        END IF;
        IF (NVL(TRIM(X_Attribute1),'-999') <> NVL( TRIM(Recinfo.attribute1),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute1 '||X_Attribute1 ||' Database  attribute1 '||Recinfo.attribute1);
        END IF;
        IF (NVL(TRIM(X_Attribute2),'-999') <> NVL( TRIM(Recinfo.attribute2),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute2 '||X_Attribute2 ||' Database  attribute2 '||Recinfo.attribute2);
        END IF;
        IF (NVL(TRIM(X_Attribute3),'-999') <> NVL( TRIM(Recinfo.attribute3),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute3 '||X_Attribute3 ||' Database  attribute3 '||Recinfo.attribute3);
        END IF;
        IF (NVL(TRIM(X_Attribute4),'-999') <> NVL( TRIM(Recinfo.attribute4),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute4 '||X_Attribute4 ||' Database  attribute4 '||Recinfo.attribute4);
        END IF;
        IF (NVL(TRIM(X_Attribute5),'-999') <> NVL( TRIM(Recinfo.attribute5),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute5 '||X_Attribute5 ||' Database  attribute5 '||Recinfo.attribute5);
        END IF;
        IF (NVL(TRIM(X_Attribute6),'-999') <> NVL( TRIM(Recinfo.attribute6),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute6 '||X_Attribute6 ||' Database  attribute6 '||Recinfo.attribute6);
        END IF;
        IF (NVL(TRIM(X_Attribute7),'-999') <> NVL( TRIM(Recinfo.attribute7),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute7 '||X_Attribute7 ||' Database  attribute7 '||Recinfo.attribute7);
        END IF;
        IF (NVL(TRIM(X_Attribute8),'-999') <> NVL( TRIM(Recinfo.attribute8),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute8 '||X_Attribute8 ||' Database  attribute8 '||Recinfo.attribute8);
        END IF;
        IF (NVL(TRIM(X_Attribute9),'-999') <> NVL( TRIM(Recinfo.attribute9),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute9 '||X_Attribute9 ||' Database  attribute9 '||Recinfo.attribute9);
        END IF;
        IF (NVL(TRIM(X_Attribute10),'-999') <> NVL( TRIM(Recinfo.attribute10),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute10 '||X_Attribute10 ||' Database  attribute10 '||Recinfo.attribute10);
        END IF;
        IF (NVL(TRIM(X_Attribute11),'-999') <> NVL( TRIM(Recinfo.attribute11),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute11 '||X_Attribute11 ||' Database  attribute11 '||Recinfo.attribute11);
        END IF;
        IF (NVL(TRIM(X_Attribute12),'-999') <> NVL( TRIM(Recinfo.attribute12),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute12 '||X_Attribute12 ||' Database  attribute12 '||Recinfo.attribute12);
        END IF;
        IF (NVL(TRIM(X_Attribute13),'-999') <> NVL( TRIM(Recinfo.attribute13),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute13 '||X_Attribute13 ||' Database  attribute13 '||Recinfo.attribute13);
        END IF;
        IF (NVL(TRIM(X_Attribute14),'-999') <> NVL( TRIM(Recinfo.attribute14),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute14 '||X_Attribute14 ||' Database  attribute14 '||Recinfo.attribute14);
        END IF;
        IF (NVL(TRIM(X_Attribute15),'-999') <> NVL( TRIM(Recinfo.attribute15),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute15 '||X_Attribute15 ||' Database  attribute15 '||Recinfo.attribute15);
        END IF;
        IF (NVL(TRIM(X_Inspection_Required_Flag),'-999') <> NVL( TRIM(Recinfo.inspection_required_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form inspection_required_flag '||X_Inspection_Required_Flag ||' Database  inspection_required_flag '||Recinfo.inspection_required_flag);
        END IF;
        IF (NVL(TRIM(X_Receipt_Required_Flag),'-999') <> NVL( TRIM(Recinfo.receipt_required_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form receipt_required_flag '||X_Receipt_Required_Flag ||' Database  receipt_required_flag '||Recinfo.receipt_required_flag);
        END IF;
        IF (NVL(X_Qty_Rcv_Tolerance,-999) <> NVL(Recinfo.qty_rcv_tolerance,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form qty_rcv_tolerance'||X_Qty_Rcv_Tolerance ||' Database  qty_rcv_tolerance '|| Recinfo.qty_rcv_tolerance);
        END IF;
        IF (NVL(TRIM(X_Qty_Rcv_Exception_Code),'-999') <> NVL( TRIM(Recinfo.qty_rcv_exception_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form qty_rcv_exception_code '||X_Qty_Rcv_Exception_Code ||' Database  qty_rcv_exception_code '||Recinfo.qty_rcv_exception_code);
        END IF;
        IF (NVL(TRIM(X_Enforce_Ship_To_Location),'-999') <> NVL( TRIM(Recinfo.enforce_ship_to_location_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form enforce_ship_to_location '||X_Enforce_Ship_To_Location ||' Database  enforce_ship_to_location '||Recinfo.enforce_ship_to_location_code);
        END IF;
        IF (NVL(TRIM(X_Allow_Substitute_Receipts),'-999') <> NVL( TRIM(Recinfo.allow_substitute_receipts_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form allow_substitute_receipts '||X_Allow_Substitute_Receipts ||' Database  allow_substitute_receipts '||Recinfo.allow_substitute_receipts_flag);
        END IF;
        IF (NVL(X_Days_Early_Receipt_Allowed,-999) <> NVL(Recinfo.days_early_receipt_allowed,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form days_early_receipt_allowed'||X_Days_Early_Receipt_Allowed ||' Database  days_early_receipt_allowed '|| Recinfo.days_early_receipt_allowed);
        END IF;
        IF (NVL(X_Days_Late_Receipt_Allowed,-999) <> NVL(Recinfo.days_late_receipt_allowed,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form days_late_receipt_allowed'||X_Days_Late_Receipt_Allowed ||' Database  days_late_receipt_allowed '|| Recinfo.days_late_receipt_allowed);
        END IF;
        IF (NVL(TRIM(X_Receipt_Days_Exception_Code),'-999') <> NVL( TRIM(Recinfo.receipt_days_exception_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form receipt_days_exception_code '||X_Receipt_Days_Exception_Code ||' Database  receipt_days_exception_code '||Recinfo.receipt_days_exception_code);
        END IF;
        IF (NVL(X_Invoice_Close_Tolerance,-999) <> NVL(Recinfo.invoice_close_tolerance,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form invoice_close_tolerance'||X_Invoice_Close_Tolerance ||' Database  invoice_close_tolerance '|| Recinfo.invoice_close_tolerance);
        END IF;
        IF (NVL(X_Receive_Close_Tolerance,-999) <> NVL(Recinfo.receive_close_tolerance,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form receive_close_tolerance'||X_Receive_Close_Tolerance ||' Database  receive_close_tolerance '|| Recinfo.receive_close_tolerance);
        END IF;
        IF (NVL(X_Ship_To_Organization_Id,-999) <> NVL(Recinfo.ship_to_organization_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form ship_to_organization_id'||X_Ship_To_Organization_Id ||' Database  ship_to_organization_id '|| Recinfo.ship_to_organization_id);
        END IF;
        IF (NVL(X_Shipment_Num,-999) <> NVL(Recinfo.shipment_num,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form shipment_num'||X_Shipment_Num ||' Database  shipment_num '|| Recinfo.shipment_num);
        END IF;
        IF (NVL(X_Source_Shipment_Id,-999) <> NVL(Recinfo.source_shipment_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form source_shipment_id'||X_Source_Shipment_Id ||' Database  source_shipment_id '|| Recinfo.source_shipment_id);
        END IF;
        IF (NVL(TRIM(X_Shipment_Type),'-999') <> NVL( TRIM(Recinfo.shipment_type),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form shipment_type '||X_Shipment_Type ||' Database  shipment_type '||Recinfo.shipment_type);
        END IF;
        IF (NVL(TRIM(X_Closed_Code),'-999') <> NVL( TRIM(Recinfo.closed_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form closed_code '||X_Closed_Code ||' Database  closed_code '||Recinfo.closed_code);
        END IF;
        IF (NVL(TRIM(X_Ussgl_Transaction_Code),'-999') <> NVL( TRIM(Recinfo.ussgl_transaction_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form ussgl_transaction_code '||X_Ussgl_Transaction_Code ||' Database  ussgl_transaction_code '||Recinfo.ussgl_transaction_code);
        END IF;
        IF (NVL(TRIM(X_Government_Context),'-999') <> NVL( TRIM(Recinfo.government_context),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form government_context '||X_Government_Context ||' Database  government_context '||Recinfo.government_context);
        END IF;
        IF (NVL(X_Receiving_Routing_Id,-999) <> NVL(Recinfo.receiving_routing_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form receiving_routing_id'||X_Receiving_Routing_Id ||' Database  receiving_routing_id '|| Recinfo.receiving_routing_id);
        END IF;
        IF (NVL(TRIM(X_Accrue_On_Receipt_Flag),'-999') <> NVL( TRIM(Recinfo.accrue_on_receipt_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form accrue_on_receipt_flag '||X_Accrue_On_Receipt_Flag ||' Database  accrue_on_receipt_flag '||Recinfo.accrue_on_receipt_flag);
        END IF;
        IF (NVL(TRIM(X_Closed_Reason),'-999') <> NVL( TRIM(Recinfo.closed_reason),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form closed_reason '||X_Closed_Reason ||' Database  closed_reason '||Recinfo.closed_reason);
        END IF;
        IF (X_Closed_Date <> Recinfo.closed_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form closed_date '||X_Closed_Date ||' Database  closed_date '||Recinfo.closed_date);
        END IF;
        IF (NVL(X_Closed_By,-999) <> NVL(Recinfo.closed_by,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form closed_by'||X_Closed_By ||' Database  closed_by '|| Recinfo.closed_by);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute_Category),'-999') <> NVL( TRIM(Recinfo.global_attribute_category),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute_category '||X_Global_Attribute_Category ||' Database  global_attribute_category '||Recinfo.global_attribute_category);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute1),'-999') <> NVL( TRIM(Recinfo.global_attribute1),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute1 '||X_Global_Attribute1 ||' Database  global_attribute1 '||Recinfo.global_attribute1);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute2),'-999') <> NVL( TRIM(Recinfo.global_attribute2),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute2 '||X_Global_Attribute2 ||' Database  global_attribute2 '||Recinfo.global_attribute2);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute3),'-999') <> NVL( TRIM(Recinfo.global_attribute3),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute3 '||X_Global_Attribute3 ||' Database  global_attribute3 '||Recinfo.global_attribute3);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute4),'-999') <> NVL( TRIM(Recinfo.global_attribute4),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute4 '||X_Global_Attribute4 ||' Database  global_attribute4 '||Recinfo.global_attribute4);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute5),'-999') <> NVL( TRIM(Recinfo.global_attribute5),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute5 '||X_Global_Attribute5 ||' Database  global_attribute5 '||Recinfo.global_attribute5);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute6),'-999') <> NVL( TRIM(Recinfo.global_attribute6),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute6 '||X_Global_Attribute6 ||' Database  global_attribute6 '||Recinfo.global_attribute6);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute7),'-999') <> NVL( TRIM(Recinfo.global_attribute7),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute7 '||X_Global_Attribute7 ||' Database  global_attribute7 '||Recinfo.global_attribute7);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute8),'-999') <> NVL( TRIM(Recinfo.global_attribute8),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute8 '||X_Global_Attribute8 ||' Database  global_attribute8 '||Recinfo.global_attribute8);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute9),'-999') <> NVL( TRIM(Recinfo.global_attribute9),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute9 '||X_Global_Attribute9 ||' Database  global_attribute9 '||Recinfo.global_attribute9);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute10),'-999') <> NVL( TRIM(Recinfo.global_attribute10),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute10 '||X_Global_Attribute10 ||' Database  global_attribute10 '||Recinfo.global_attribute10);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute11),'-999') <> NVL( TRIM(Recinfo.global_attribute11),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute11 '||X_Global_Attribute11 ||' Database  global_attribute11 '||Recinfo.global_attribute11);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute12),'-999') <> NVL( TRIM(Recinfo.global_attribute12),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute12 '||X_Global_Attribute12 ||' Database  global_attribute12 '||Recinfo.global_attribute12);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute13),'-999') <> NVL( TRIM(Recinfo.global_attribute13),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute13 '||X_Global_Attribute13 ||' Database  global_attribute13 '||Recinfo.global_attribute13);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute14),'-999') <> NVL( TRIM(Recinfo.global_attribute14),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute14 '||X_Global_Attribute14 ||' Database  global_attribute14 '||Recinfo.global_attribute14);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute15),'-999') <> NVL( TRIM(Recinfo.global_attribute15),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute15 '||X_Global_Attribute15 ||' Database  global_attribute15 '||Recinfo.global_attribute15);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute16),'-999') <> NVL( TRIM(Recinfo.global_attribute16),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute16 '||X_Global_Attribute16 ||' Database  global_attribute16 '||Recinfo.global_attribute16);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute17),'-999') <> NVL( TRIM(Recinfo.global_attribute17),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute17 '||X_Global_Attribute17 ||' Database  global_attribute17 '||Recinfo.global_attribute17);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute18),'-999') <> NVL( TRIM(Recinfo.global_attribute18),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute18 '||X_Global_Attribute18 ||' Database  global_attribute18 '||Recinfo.global_attribute18);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute19),'-999') <> NVL( TRIM(Recinfo.global_attribute19),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute19 '||X_Global_Attribute19 ||' Database  global_attribute19 '||Recinfo.global_attribute19);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute20),'-999') <> NVL( TRIM(Recinfo.global_attribute20),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute20 '||X_Global_Attribute20 ||' Database  global_attribute20 '||Recinfo.global_attribute20);
        END IF;
        IF (NVL(TRIM(X_Country_of_Origin_Code),'-999') <> NVL( TRIM(Recinfo.country_of_origin_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form country_of_origin_code '||X_Country_of_Origin_Code ||' Database  country_of_origin_code '||Recinfo.country_of_origin_code);
        END IF;
        IF (NVL(TRIM(X_Invoice_Match_Option),'-999') <> NVL( TRIM(Recinfo.match_option),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form invoice_match_option '||X_Invoice_Match_Option ||' Database  invoice_match_option '||Recinfo.match_option);
        END IF;
    END IF;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;
  else

      IF (g_fnd_debug = 'Y') THEN
        IF (NVL(X_Line_Location_Id,-999) <> NVL(Recinfo.line_location_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form line_location_id'||X_Line_Location_Id ||' Database  line_location_id '|| Recinfo.line_location_id);
        END IF;
        IF (NVL(X_Po_Header_Id,-999) <> NVL(Recinfo.po_header_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form po_header_id'||X_Po_Header_Id ||' Database  po_header_id '|| Recinfo.po_header_id);
        END IF;
        IF (NVL(X_Po_Line_Id,-999) <> NVL(Recinfo.po_line_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form po_line_id'||X_Po_Line_Id ||' Database  po_line_id '|| Recinfo.po_line_id);
        END IF;
        IF (NVL(X_Quantity,-999) <> NVL(Recinfo.quantity,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form quantity'||X_Quantity ||' Database  quantity '|| Recinfo.quantity);
        END IF;
        IF (NVL(X_Quantity_Received,-999) <> NVL(Recinfo.quantity_received,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form quantity_received'||X_Quantity_Received ||' Database  quantity_received '|| Recinfo.quantity_received);
        END IF;
        IF (NVL(X_Quantity_Accepted,-999) <> NVL(Recinfo.quantity_accepted,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form quantity_accepted'||X_Quantity_Accepted ||' Database  quantity_accepted '|| Recinfo.quantity_accepted);
        END IF;
        IF (NVL(X_Quantity_Rejected,-999) <> NVL(Recinfo.quantity_rejected,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form quantity_rejected'||X_Quantity_Rejected ||' Database  quantity_rejected '|| Recinfo.quantity_rejected);
        END IF;
        IF (NVL(X_Quantity_Billed,-999) <> NVL(Recinfo.quantity_billed,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form quantity_billed'||X_Quantity_Billed ||' Database  quantity_billed '|| Recinfo.quantity_billed);
        END IF;
        IF (NVL(X_Quantity_Cancelled,-999) <> NVL(Recinfo.quantity_cancelled,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form quantity_cancelled'||X_Quantity_Cancelled ||' Database  quantity_cancelled '|| Recinfo.quantity_cancelled);
        END IF;
        IF (NVL(TRIM(X_Unit_Meas_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.unit_meas_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form unit_meas_lookup_code '||X_Unit_Meas_Lookup_Code ||' Database  unit_meas_lookup_code '||Recinfo.unit_meas_lookup_code);
        END IF;
        IF (NVL(X_Po_Release_Id,-999) <> NVL(Recinfo.po_release_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form po_release_id'||X_Po_Release_Id ||' Database  po_release_id '|| Recinfo.po_release_id);
        END IF;
        IF (NVL(X_Ship_To_Location_Id,-999) <> NVL(Recinfo.ship_to_location_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form ship_to_location_id'||X_Ship_To_Location_Id ||' Database  ship_to_location_id '|| Recinfo.ship_to_location_id);
        END IF;
        IF (NVL(TRIM(X_Ship_Via_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.ship_via_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form ship_via_lookup_code '||X_Ship_Via_Lookup_Code ||' Database  ship_via_lookup_code '||Recinfo.ship_via_lookup_code);
        END IF;
        IF (X_Need_By_Date <> Recinfo.need_by_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form need_by_date '||X_Need_By_Date ||' Database  need_by_date '||Recinfo.need_by_date);
        END IF;
        IF (X_Promised_Date <> Recinfo.promised_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form promised_date '||X_Promised_Date ||' Database  promised_date '||Recinfo.promised_date);
        END IF;
        IF (X_Last_Accept_Date <> Recinfo.last_accept_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form last_accept_date '||X_Last_Accept_Date ||' Database  last_accept_date '||Recinfo.last_accept_date);
        END IF;
        IF (NVL(X_Price_Override,-999) <> NVL(Recinfo.price_override,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form price_override'||X_Price_Override ||' Database  price_override '|| Recinfo.price_override);
        END IF;
        IF (NVL(TRIM(X_Encumbered_Flag),'-999') <> NVL( TRIM(Recinfo.encumbered_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form encumbered_flag '||X_Encumbered_Flag ||' Database  encumbered_flag '||Recinfo.encumbered_flag);
        END IF;
        IF (X_Encumbered_Date <> Recinfo.encumbered_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form encumbered_date '||X_Encumbered_Date ||' Database  encumbered_date '||Recinfo.encumbered_date);
        END IF;
        IF (NVL(TRIM(X_Fob_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.fob_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form fob_lookup_code '||X_Fob_Lookup_Code ||' Database  fob_lookup_code '||Recinfo.fob_lookup_code);
        END IF;
        IF (NVL(TRIM(X_Freight_Terms_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.freight_terms_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form freight_terms_lookup_code '||X_Freight_Terms_Lookup_Code ||' Database  freight_terms_lookup_code '||Recinfo.freight_terms_lookup_code);
        END IF;
--        IF (NVL(X_Tax_Code_Id,-999) <> NVL(Recinfo.taRecinfo.code_id,-999)) THEN
--             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form tacode_id'||X_Tax_Code_Id ||' Database  tacode_id '|| Recinfo.taRecinfo.code_id);
--        END IF;
--        IF (NVL(TRIM(X_Tax_User_Override_Flag),'-999') <> NVL( TRIM(Recinfo.taRecinfo.user_override_flag),'-999')) THEN
--             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form tauser_override_flag '||X_Tax_User_Override_Flag ||' Database  tauser_override_flag '||Recinfo.taRecinfo.user_override_flag);
--        END IF;
        IF (NVL(X_From_Header_Id,-999) <> NVL(Recinfo.from_header_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form from_header_id'||X_From_Header_Id ||' Database  from_header_id '|| Recinfo.from_header_id);
        END IF;
        IF (NVL(X_From_Line_Id,-999) <> NVL(Recinfo.from_line_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form from_line_id'||X_From_Line_Id ||' Database  from_line_id '|| Recinfo.from_line_id);
        END IF;
        IF (NVL(X_From_Line_Location_Id,-999) <> NVL(Recinfo.from_line_location_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form from_line_location_id'||X_From_Line_Location_Id ||' Database  from_line_location_id '|| Recinfo.from_line_location_id);
        END IF;
        IF (X_Start_Date <> Recinfo.start_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form start_date '||X_Start_Date ||' Database  start_date '||Recinfo.start_date);
        END IF;
        IF (X_End_Date <> Recinfo.end_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form end_date '||X_End_Date ||' Database  end_date '||Recinfo.end_date);
        END IF;
        IF (NVL(X_Lead_Time,-999) <> NVL(Recinfo.lead_time,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form lead_time'||X_Lead_Time ||' Database  lead_time '|| Recinfo.lead_time);
        END IF;
        IF (NVL(TRIM(X_Lead_Time_Unit),'-999') <> NVL( TRIM(Recinfo.lead_time_unit),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form lead_time_unit '||X_Lead_Time_Unit ||' Database  lead_time_unit '||Recinfo.lead_time_unit);
        END IF;
        IF (NVL(X_Price_Discount,-999) <> NVL(Recinfo.price_discount,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form price_discount'||X_Price_Discount ||' Database  price_discount '|| Recinfo.price_discount);
        END IF;
        IF (NVL(X_Terms_Id,-999) <> NVL(Recinfo.terms_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form terms_id'||X_Terms_Id ||' Database  terms_id '|| Recinfo.terms_id);
        END IF;
        IF (NVL(TRIM(X_Approved_Flag),'-999') <> NVL( TRIM(Recinfo.approved_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form approved_flag '||X_Approved_Flag ||' Database  approved_flag '||Recinfo.approved_flag);
        END IF;
        IF (X_Approved_Date <> Recinfo.approved_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form approved_date '||X_Approved_Date ||' Database  approved_date '||Recinfo.approved_date);
        END IF;
        IF (NVL(TRIM(X_Closed_Flag),'-999') <> NVL( TRIM(Recinfo.closed_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form closed_flag '||X_Closed_Flag ||' Database  closed_flag '||Recinfo.closed_flag);
        END IF;
        IF (NVL(TRIM(X_Cancel_Flag),'-999') <> NVL( TRIM(Recinfo.cancel_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form cancel_flag '||X_Cancel_Flag ||' Database  cancel_flag '||Recinfo.cancel_flag);
        END IF;
        IF (NVL(X_Cancelled_By,-999) <> NVL(Recinfo.cancelled_by,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form cancelled_by'||X_Cancelled_By ||' Database  cancelled_by '|| Recinfo.cancelled_by);
        END IF;
        IF (X_Cancel_Date <> Recinfo.cancel_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form cancel_date '||X_Cancel_Date ||' Database  cancel_date '||Recinfo.cancel_date);
        END IF;
        IF (NVL(TRIM(X_Cancel_Reason),'-999') <> NVL( TRIM(Recinfo.cancel_reason),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form cancel_reason '||X_Cancel_Reason ||' Database  cancel_reason '||Recinfo.cancel_reason);
        END IF;
        IF (NVL(TRIM(X_Firm_Status_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.firm_status_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form firm_status_lookup_code '||X_Firm_Status_Lookup_Code ||' Database  firm_status_lookup_code '||Recinfo.firm_status_lookup_code);
        END IF;
        IF (NVL(TRIM(X_Attribute_Category),'-999') <> NVL( TRIM(Recinfo.attribute_category),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute_category '||X_Attribute_Category ||' Database  attribute_category '||Recinfo.attribute_category);
        END IF;
        IF (NVL(TRIM(X_Attribute1),'-999') <> NVL( TRIM(Recinfo.attribute1),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute1 '||X_Attribute1 ||' Database  attribute1 '||Recinfo.attribute1);
        END IF;
        IF (NVL(TRIM(X_Attribute2),'-999') <> NVL( TRIM(Recinfo.attribute2),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute2 '||X_Attribute2 ||' Database  attribute2 '||Recinfo.attribute2);
        END IF;
        IF (NVL(TRIM(X_Attribute3),'-999') <> NVL( TRIM(Recinfo.attribute3),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute3 '||X_Attribute3 ||' Database  attribute3 '||Recinfo.attribute3);
        END IF;
        IF (NVL(TRIM(X_Attribute4),'-999') <> NVL( TRIM(Recinfo.attribute4),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute4 '||X_Attribute4 ||' Database  attribute4 '||Recinfo.attribute4);
        END IF;
        IF (NVL(TRIM(X_Attribute5),'-999') <> NVL( TRIM(Recinfo.attribute5),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute5 '||X_Attribute5 ||' Database  attribute5 '||Recinfo.attribute5);
        END IF;
        IF (NVL(TRIM(X_Attribute6),'-999') <> NVL( TRIM(Recinfo.attribute6),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute6 '||X_Attribute6 ||' Database  attribute6 '||Recinfo.attribute6);
        END IF;
        IF (NVL(TRIM(X_Attribute7),'-999') <> NVL( TRIM(Recinfo.attribute7),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute7 '||X_Attribute7 ||' Database  attribute7 '||Recinfo.attribute7);
        END IF;
        IF (NVL(TRIM(X_Attribute8),'-999') <> NVL( TRIM(Recinfo.attribute8),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute8 '||X_Attribute8 ||' Database  attribute8 '||Recinfo.attribute8);
        END IF;
        IF (NVL(TRIM(X_Attribute9),'-999') <> NVL( TRIM(Recinfo.attribute9),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute9 '||X_Attribute9 ||' Database  attribute9 '||Recinfo.attribute9);
        END IF;
        IF (NVL(TRIM(X_Attribute10),'-999') <> NVL( TRIM(Recinfo.attribute10),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute10 '||X_Attribute10 ||' Database  attribute10 '||Recinfo.attribute10);
        END IF;
        IF (NVL(TRIM(X_Attribute11),'-999') <> NVL( TRIM(Recinfo.attribute11),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute11 '||X_Attribute11 ||' Database  attribute11 '||Recinfo.attribute11);
        END IF;
        IF (NVL(TRIM(X_Attribute12),'-999') <> NVL( TRIM(Recinfo.attribute12),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute12 '||X_Attribute12 ||' Database  attribute12 '||Recinfo.attribute12);
        END IF;
        IF (NVL(TRIM(X_Attribute13),'-999') <> NVL( TRIM(Recinfo.attribute13),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute13 '||X_Attribute13 ||' Database  attribute13 '||Recinfo.attribute13);
        END IF;
        IF (NVL(TRIM(X_Attribute14),'-999') <> NVL( TRIM(Recinfo.attribute14),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute14 '||X_Attribute14 ||' Database  attribute14 '||Recinfo.attribute14);
        END IF;
        IF (NVL(TRIM(X_Attribute15),'-999') <> NVL( TRIM(Recinfo.attribute15),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute15 '||X_Attribute15 ||' Database  attribute15 '||Recinfo.attribute15);
        END IF;
        IF (NVL(TRIM(X_Inspection_Required_Flag),'-999') <> NVL( TRIM(Recinfo.inspection_required_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form inspection_required_flag '||X_Inspection_Required_Flag ||' Database  inspection_required_flag '||Recinfo.inspection_required_flag);
        END IF;
        IF (NVL(TRIM(X_Receipt_Required_Flag),'-999') <> NVL( TRIM(Recinfo.receipt_required_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form receipt_required_flag '||X_Receipt_Required_Flag ||' Database  receipt_required_flag '||Recinfo.receipt_required_flag);
        END IF;
        IF (NVL(X_Qty_Rcv_Tolerance,-999) <> NVL(Recinfo.qty_rcv_tolerance,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form qty_rcv_tolerance'||X_Qty_Rcv_Tolerance ||' Database  qty_rcv_tolerance '|| Recinfo.qty_rcv_tolerance);
        END IF;
        IF (NVL(TRIM(X_Qty_Rcv_Exception_Code),'-999') <> NVL( TRIM(Recinfo.qty_rcv_exception_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form qty_rcv_exception_code '||X_Qty_Rcv_Exception_Code ||' Database  qty_rcv_exception_code '||Recinfo.qty_rcv_exception_code);
        END IF;
        IF (NVL(TRIM(X_Enforce_Ship_To_Location),'-999') <> NVL( TRIM(Recinfo.enforce_ship_to_location_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form enforce_ship_to_location '||X_Enforce_Ship_To_Location ||' Database  enforce_ship_to_location '||Recinfo.enforce_ship_to_location_code);
        END IF;
        IF (NVL(TRIM(X_Allow_Substitute_Receipts),'-999') <> NVL( TRIM(Recinfo.allow_substitute_receipts_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form allow_substitute_receipts '||X_Allow_Substitute_Receipts ||' Database  allow_substitute_receipts '||Recinfo.allow_substitute_receipts_flag);
        END IF;
        IF (NVL(X_Days_Early_Receipt_Allowed,-999) <> NVL(Recinfo.days_early_receipt_allowed,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form days_early_receipt_allowed'||X_Days_Early_Receipt_Allowed ||' Database  days_early_receipt_allowed '|| Recinfo.days_early_receipt_allowed);
        END IF;
        IF (NVL(X_Days_Late_Receipt_Allowed,-999) <> NVL(Recinfo.days_late_receipt_allowed,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form days_late_receipt_allowed'||X_Days_Late_Receipt_Allowed ||' Database  days_late_receipt_allowed '|| Recinfo.days_late_receipt_allowed);
        END IF;
        IF (NVL(TRIM(X_Receipt_Days_Exception_Code),'-999') <> NVL( TRIM(Recinfo.receipt_days_exception_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form receipt_days_exception_code '||X_Receipt_Days_Exception_Code ||' Database  receipt_days_exception_code '||Recinfo.receipt_days_exception_code);
        END IF;
        IF (NVL(X_Invoice_Close_Tolerance,-999) <> NVL(Recinfo.invoice_close_tolerance,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form invoice_close_tolerance'||X_Invoice_Close_Tolerance ||' Database  invoice_close_tolerance '|| Recinfo.invoice_close_tolerance);
        END IF;
        IF (NVL(X_Receive_Close_Tolerance,-999) <> NVL(Recinfo.receive_close_tolerance,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form receive_close_tolerance'||X_Receive_Close_Tolerance ||' Database  receive_close_tolerance '|| Recinfo.receive_close_tolerance);
        END IF;
        IF (NVL(X_Ship_To_Organization_Id,-999) <> NVL(Recinfo.ship_to_organization_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form ship_to_organization_id'||X_Ship_To_Organization_Id ||' Database  ship_to_organization_id '|| Recinfo.ship_to_organization_id);
        END IF;
        IF (NVL(X_Shipment_Num,-999) <> NVL(Recinfo.shipment_num,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form shipment_num'||X_Shipment_Num ||' Database  shipment_num '|| Recinfo.shipment_num);
        END IF;
        IF (NVL(X_Source_Shipment_Id,-999) <> NVL(Recinfo.source_shipment_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form source_shipment_id'||X_Source_Shipment_Id ||' Database  source_shipment_id '|| Recinfo.source_shipment_id);
        END IF;
        IF (NVL(TRIM(X_Shipment_Type),'-999') <> NVL( TRIM(Recinfo.shipment_type),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form shipment_type '||X_Shipment_Type ||' Database  shipment_type '||Recinfo.shipment_type);
        END IF;
        IF (NVL(TRIM(X_Closed_Code),'-999') <> NVL( TRIM(Recinfo.closed_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form closed_code '||X_Closed_Code ||' Database  closed_code '||Recinfo.closed_code);
        END IF;
        IF (NVL(TRIM(X_Ussgl_Transaction_Code),'-999') <> NVL( TRIM(Recinfo.ussgl_transaction_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form ussgl_transaction_code '||X_Ussgl_Transaction_Code ||' Database  ussgl_transaction_code '||Recinfo.ussgl_transaction_code);
        END IF;
        IF (NVL(TRIM(X_Government_Context),'-999') <> NVL( TRIM(Recinfo.government_context),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form government_context '||X_Government_Context ||' Database  government_context '||Recinfo.government_context);
        END IF;
        IF (NVL(X_Receiving_Routing_Id,-999) <> NVL(Recinfo.receiving_routing_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form receiving_routing_id'||X_Receiving_Routing_Id ||' Database  receiving_routing_id '|| Recinfo.receiving_routing_id);
        END IF;
        IF (NVL(TRIM(X_Accrue_On_Receipt_Flag),'-999') <> NVL( TRIM(Recinfo.accrue_on_receipt_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form accrue_on_receipt_flag '||X_Accrue_On_Receipt_Flag ||' Database  accrue_on_receipt_flag '||Recinfo.accrue_on_receipt_flag);
        END IF;
        IF (NVL(TRIM(X_Closed_Reason),'-999') <> NVL( TRIM(Recinfo.closed_reason),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form closed_reason '||X_Closed_Reason ||' Database  closed_reason '||Recinfo.closed_reason);
        END IF;
        IF (X_Closed_Date <> Recinfo.closed_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form closed_date '||X_Closed_Date ||' Database  closed_date '||Recinfo.closed_date);
        END IF;
        IF (NVL(X_Closed_By,-999) <> NVL(Recinfo.closed_by,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form closed_by'||X_Closed_By ||' Database  closed_by '|| Recinfo.closed_by);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute_Category),'-999') <> NVL( TRIM(Recinfo.global_attribute_category),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute_category '||X_Global_Attribute_Category ||' Database  global_attribute_category '||Recinfo.global_attribute_category);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute1),'-999') <> NVL( TRIM(Recinfo.global_attribute1),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute1 '||X_Global_Attribute1 ||' Database  global_attribute1 '||Recinfo.global_attribute1);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute2),'-999') <> NVL( TRIM(Recinfo.global_attribute2),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute2 '||X_Global_Attribute2 ||' Database  global_attribute2 '||Recinfo.global_attribute2);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute3),'-999') <> NVL( TRIM(Recinfo.global_attribute3),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute3 '||X_Global_Attribute3 ||' Database  global_attribute3 '||Recinfo.global_attribute3);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute4),'-999') <> NVL( TRIM(Recinfo.global_attribute4),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute4 '||X_Global_Attribute4 ||' Database  global_attribute4 '||Recinfo.global_attribute4);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute5),'-999') <> NVL( TRIM(Recinfo.global_attribute5),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute5 '||X_Global_Attribute5 ||' Database  global_attribute5 '||Recinfo.global_attribute5);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute6),'-999') <> NVL( TRIM(Recinfo.global_attribute6),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute6 '||X_Global_Attribute6 ||' Database  global_attribute6 '||Recinfo.global_attribute6);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute7),'-999') <> NVL( TRIM(Recinfo.global_attribute7),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute7 '||X_Global_Attribute7 ||' Database  global_attribute7 '||Recinfo.global_attribute7);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute8),'-999') <> NVL( TRIM(Recinfo.global_attribute8),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute8 '||X_Global_Attribute8 ||' Database  global_attribute8 '||Recinfo.global_attribute8);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute9),'-999') <> NVL( TRIM(Recinfo.global_attribute9),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute9 '||X_Global_Attribute9 ||' Database  global_attribute9 '||Recinfo.global_attribute9);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute10),'-999') <> NVL( TRIM(Recinfo.global_attribute10),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute10 '||X_Global_Attribute10 ||' Database  global_attribute10 '||Recinfo.global_attribute10);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute11),'-999') <> NVL( TRIM(Recinfo.global_attribute11),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute11 '||X_Global_Attribute11 ||' Database  global_attribute11 '||Recinfo.global_attribute11);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute12),'-999') <> NVL( TRIM(Recinfo.global_attribute12),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute12 '||X_Global_Attribute12 ||' Database  global_attribute12 '||Recinfo.global_attribute12);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute13),'-999') <> NVL( TRIM(Recinfo.global_attribute13),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute13 '||X_Global_Attribute13 ||' Database  global_attribute13 '||Recinfo.global_attribute13);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute14),'-999') <> NVL( TRIM(Recinfo.global_attribute14),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute14 '||X_Global_Attribute14 ||' Database  global_attribute14 '||Recinfo.global_attribute14);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute15),'-999') <> NVL( TRIM(Recinfo.global_attribute15),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute15 '||X_Global_Attribute15 ||' Database  global_attribute15 '||Recinfo.global_attribute15);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute16),'-999') <> NVL( TRIM(Recinfo.global_attribute16),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute16 '||X_Global_Attribute16 ||' Database  global_attribute16 '||Recinfo.global_attribute16);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute17),'-999') <> NVL( TRIM(Recinfo.global_attribute17),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute17 '||X_Global_Attribute17 ||' Database  global_attribute17 '||Recinfo.global_attribute17);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute18),'-999') <> NVL( TRIM(Recinfo.global_attribute18),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute18 '||X_Global_Attribute18 ||' Database  global_attribute18 '||Recinfo.global_attribute18);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute19),'-999') <> NVL( TRIM(Recinfo.global_attribute19),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute19 '||X_Global_Attribute19 ||' Database  global_attribute19 '||Recinfo.global_attribute19);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute20),'-999') <> NVL( TRIM(Recinfo.global_attribute20),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute20 '||X_Global_Attribute20 ||' Database  global_attribute20 '||Recinfo.global_attribute20);
        END IF;
        IF (NVL(TRIM(X_Country_of_Origin_Code),'-999') <> NVL( TRIM(Recinfo.country_of_origin_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form country_of_origin_code '||X_Country_of_Origin_Code ||' Database  country_of_origin_code '||Recinfo.country_of_origin_code);
        END IF;
        IF (NVL(TRIM(X_Invoice_Match_Option),'-999') <> NVL( TRIM(Recinfo.match_option),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form invoice_match_option '||X_Invoice_Match_Option ||' Database  invoice_match_option '||Recinfo.match_option);
        END IF;
    END IF;
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;

  end if;

  END Lock_Row;
END PO_LINE_LOCATIONS_PKG_S1;



/
