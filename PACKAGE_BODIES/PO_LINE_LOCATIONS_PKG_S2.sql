--------------------------------------------------------
--  DDL for Package Body PO_LINE_LOCATIONS_PKG_S2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_LINE_LOCATIONS_PKG_S2" as
/* $Header: POXP3PSB.pls 120.9.12010000.2 2012/05/21 09:13:37 dtoshniw ship $ */

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Line_Location_Id               NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Po_Header_Id                   NUMBER,
                       X_Po_Line_Id                     NUMBER,
                       X_Last_Update_Login              NUMBER,
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
           X_Tax_User_Override_Flag   VARCHAR2,
           X_Calculate_Tax_Flag   VARCHAR2,
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
           X_Country_of_Origin_Code       VARCHAR2,
           X_Invoice_Match_Option       VARCHAR2,  --bgu, Dec. 7, 98
           --togeorge 10/03/2000
           --added note to receiver
           X_note_to_receiver       VARCHAR2,
-- Mahesh Chandak(GML) Add 7 process related fields.
-- start of Bug# 1548597
                       X_Secondary_Unit_Of_Measure        VARCHAR2,
                       X_Secondary_Quantity               NUMBER,
                       X_Preferred_Grade                  VARCHAR2,
                       X_Secondary_Quantity_Received      NUMBER,
                       X_Secondary_Quantity_Accepted      NUMBER,
                       X_Secondary_Quantity_Rejected      NUMBER,
                       X_Secondary_Quantity_Cancelled     NUMBER,
-- end of Bug# 1548597
                       X_Consigned_Flag                   VARCHAR2,  /* CONSIGNED FPI */
                       X_amount                           NUMBER,  -- <SERVICES FPJ>
                       p_transaction_flow_header_id       NUMBER,
                       p_manual_price_change_flag       VARCHAR2 default null  --< Manual Price Override FPJ >
 ) IS
 l_tax_attribute_update_code PO_LINE_LOCATIONS_ALL.tax_attribute_update_code%type;--<eTax Integration R12>
 BEGIN

     --<eTax Integration  R12 Start>
    IF X_Shipment_Type in ('STANDARD', 'PLANNED', 'BLANKET', 'SCHEDULED') AND
       PO_TAX_INTERFACE_PVT.any_tax_attributes_updated(
          p_doc_type       => 'PO',
          p_doc_level      => 'SHIPMENT',
          p_doc_level_id   => X_Line_Location_Id,
          p_qty            => X_Quantity,
          p_price_override => X_Price_Override, --Bug 5647417
          p_amt            => X_amount,
          p_ship_to_org    => X_Ship_To_Organization_Id,
          p_ship_to_loc    => X_Ship_To_Location_Id,
          p_need_by_date   => X_Need_By_Date
    ) THEN
        l_tax_attribute_update_code := 'UPDATE';
    END IF;
    --<eTax Integration  R12 End>


   UPDATE PO_LINE_LOCATIONS
   SET
     line_location_id                  =     X_Line_Location_Id,
     last_update_date                  =     X_Last_Update_Date,
     last_updated_by                   =     X_Last_Updated_By,
     po_header_id                      =     X_Po_Header_Id,
     po_line_id                        =     X_Po_Line_Id,
     last_update_login                 =     X_Last_Update_Login,
     quantity                          =     X_Quantity,
     quantity_received                 =     X_Quantity_Received,
     quantity_accepted                 =     X_Quantity_Accepted,
     quantity_rejected                 =     X_Quantity_Rejected,
     quantity_billed                   =     X_Quantity_Billed,
     quantity_cancelled                =     X_Quantity_Cancelled,
     unit_meas_lookup_code             =     X_Unit_Meas_Lookup_Code,
     po_release_id                     =     X_Po_Release_Id,
     ship_to_location_id               =     X_Ship_To_Location_Id,
     ship_via_lookup_code              =     X_Ship_Via_Lookup_Code,
     need_by_date                      =     X_Need_By_Date,
     promised_date                     =     X_Promised_Date,
     last_accept_date                  =     X_Last_Accept_Date,
     price_override                    =     X_Price_Override,
     encumbered_flag                   =     X_Encumbered_Flag,
     encumbered_date                   =     X_Encumbered_Date,
     fob_lookup_code                   =     X_Fob_Lookup_Code,
     freight_terms_lookup_code         =     X_Freight_Terms_Lookup_Code,
     from_header_id                    =     X_From_Header_Id,
     from_line_id                      =     X_From_Line_Id,
     from_line_location_id             =     X_From_Line_Location_Id,
     start_date                        =     X_Start_Date,
     end_date                          =     X_End_Date,
     lead_time                         =     X_Lead_Time,
     lead_time_unit                    =     X_Lead_Time_Unit,
     price_discount                    =     X_Price_Discount,
     terms_id                          =     X_Terms_Id,
     approved_flag                     =     X_Approved_Flag,
     approved_date                     =     X_Approved_Date,
     closed_flag                       =     X_Closed_Flag,
     cancel_flag                       =     X_Cancel_Flag,
     cancelled_by                      =     X_Cancelled_By,
     cancel_date                       =     X_Cancel_Date,
     cancel_reason                     =     X_Cancel_Reason,
     firm_status_lookup_code           =     X_Firm_Status_Lookup_Code,
     attribute_category                =     X_Attribute_Category,
     attribute1                        =     X_Attribute1,
     attribute2                        =     X_Attribute2,
     attribute3                        =     X_Attribute3,
     attribute4                        =     X_Attribute4,
     attribute5                        =     X_Attribute5,
     attribute6                        =     X_Attribute6,
     attribute7                        =     X_Attribute7,
     attribute8                        =     X_Attribute8,
     attribute9                        =     X_Attribute9,
     attribute10                       =     X_Attribute10,
     attribute11                       =     X_Attribute11,
     attribute12                       =     X_Attribute12,
     attribute13                       =     X_Attribute13,
     attribute14                       =     X_Attribute14,
     attribute15                       =     X_Attribute15,
     inspection_required_flag          =     X_Inspection_Required_Flag,
     receipt_required_flag             =     X_Receipt_Required_Flag,
     qty_rcv_tolerance                 =     X_Qty_Rcv_Tolerance,
     qty_rcv_exception_code            =     X_Qty_Rcv_Exception_Code,
     enforce_ship_to_location_code     =     X_Enforce_Ship_To_Location,
     allow_substitute_receipts_flag    =     X_Allow_Substitute_Receipts,
     days_early_receipt_allowed        =     X_Days_Early_Receipt_Allowed,
     days_late_receipt_allowed         =     X_Days_Late_Receipt_Allowed,
     receipt_days_exception_code       =     X_Receipt_Days_Exception_Code,
     invoice_close_tolerance           =     X_Invoice_Close_Tolerance,
     receive_close_tolerance           =     X_Receive_Close_Tolerance,
     ship_to_organization_id           =     X_Ship_To_Organization_Id,
     shipment_num                      =     X_Shipment_Num,
     source_shipment_id                =     X_Source_Shipment_Id,
     shipment_type                     =     X_Shipment_Type,
     closed_code                       =     X_Closed_Code,
     government_context                =     X_Government_Context,
     receiving_routing_id              =     X_Receiving_Routing_Id,
     accrue_on_receipt_flag            =     X_Accrue_On_Receipt_Flag,
     closed_reason                     =     X_Closed_Reason,
     closed_date                       =     X_Closed_Date,
     closed_by                         =     X_Closed_By,
     global_attribute_category         =     X_Global_Attribute_Category,
     global_attribute1                 =     X_Global_Attribute1,
     global_attribute2                 =     X_Global_Attribute2,
     global_attribute3                 =     X_Global_Attribute3,
     global_attribute4                 =     X_Global_Attribute4,
     global_attribute5                 =     X_Global_Attribute5,
     global_attribute6                 =     X_Global_Attribute6,
     global_attribute7                 =     X_Global_Attribute7,
     global_attribute8                 =     X_Global_Attribute8,
     global_attribute9                 =     X_Global_Attribute9,
     global_attribute10                =     X_Global_Attribute10,
     global_attribute11                =     X_Global_Attribute11,
     global_attribute12                =     X_Global_Attribute12,
     global_attribute13                =     X_Global_Attribute13,
     global_attribute14                =     X_Global_Attribute14,
     global_attribute15                =     X_Global_Attribute15,
     global_attribute16                =     X_Global_Attribute16,
     global_attribute17                =     X_Global_Attribute17,
     global_attribute18                =     X_Global_Attribute18,
     global_attribute19                =     X_Global_Attribute19,
     global_attribute20                =     X_Global_Attribute20,
     country_of_origin_code            =     X_Country_of_Origin_Code,
     match_option                      =     X_Invoice_Match_Option,  --bgu, Dec. 7, 98
     --togeorge 10/03/2000
     --added note to receiver
     note_to_receiver          =     X_note_to_receiver,
-- Mahesh Bug# 1548597 added process fields in the update clause. 15-feb-2001
-- start of 1548597
     secondary_unit_of_measure         =     X_Secondary_Unit_Of_Measure,
     secondary_quantity                =     X_Secondary_Quantity,
     preferred_grade                   =     X_preferred_grade,
     secondary_quantity_received       =     X_Secondary_Quantity_Received,
     secondary_quantity_accepted       =     X_Secondary_Quantity_Accepted,
     secondary_quantity_rejected       =     X_Secondary_Quantity_Rejected,
     secondary_quantity_cancelled      =     X_Secondary_Quantity_Cancelled,

-- end of 1548597
     consigned_flag                    =     X_Consigned_Flag,  /* CONSIGNED FPI */
     amount                            =     X_amount,  -- <SERVICES FPJ>
     transaction_flow_header_id        =     p_transaction_flow_header_id,  --< Shared Proc FPJ >
     manual_price_change_flag          =     p_manual_price_change_flag,  --< Manual Price Override FPJ >
     tax_attribute_update_code         =     NVL(tax_attribute_update_code, --<eTax Integration R12>
                                                 l_tax_attribute_update_code)
  WHERE rowid = X_rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
      --<R12 eTax Integration Start>
      l_transaction_line_rec_type ZX_API_PUB.transaction_line_rec_type;
      l_return_status     VARCHAR2(1);
      l_msg_count         NUMBER;
      l_msg_data          VARCHAR2(2000);
      l_po_header_id      PO_LINE_LOCATIONS_ALL.po_header_id%TYPE;
      l_po_release_id     PO_LINE_LOCATIONS_ALL.po_release_id%TYPE;
      l_line_location_id  PO_LINE_LOCATIONS_ALL.line_location_id%TYPE;
      l_shipment_type     PO_LINE_LOCATIONS_ALL.shipment_type%TYPE;
      l_org_id            PO_LINE_LOCATIONS_ALL.org_id%type;
      --<R12 eTax Integration End>

  BEGIN
    DELETE FROM PO_LINE_LOCATIONS
    WHERE  rowid = X_Rowid
    --<R12 eTax Integration>
    RETURNING shipment_type, po_header_id, po_release_id, line_location_id,org_id
    INTO l_shipment_type, l_po_header_id, l_po_release_id, l_line_location_id,l_org_id;


    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    --<R12 eTax Integration Start>
    IF l_shipment_type in ('STANDARD','PLANNED','BLANKET','SCHEDULED') THEN

        l_transaction_line_rec_type.internal_organization_id := l_org_id;
        l_transaction_line_rec_type.application_id           := PO_CONSTANTS_SV.APPLICATION_ID;
       /* Bug 14004400: Applicaton id being passed to EB Tax was responsibility id rather than 201 which
               is pased when the tax lines are created. Same should be passed when they are deleted.  */
        l_transaction_line_rec_type.entity_code              := PO_CONSTANTS_SV.PO_ENTITY_CODE ;
        l_transaction_line_rec_type.event_class_code         := PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE;
        l_transaction_line_rec_type.event_type_code          := PO_CONSTANTS_SV.PO_ADJUSTED;
        l_transaction_line_rec_type.trx_id                   := NVL(l_po_release_id, l_po_header_id);
        l_transaction_line_rec_type.trx_level_type           := 'SHIPMENT';
        l_transaction_line_rec_type.trx_line_id              := l_line_location_id;

        -- Call eTax API to delete corresponding tax lines and distributions
        ZX_API_PUB.del_tax_line_and_distributions(
            p_api_version             =>  1.0,
            p_init_msg_list           =>  FND_API.G_TRUE,
            p_commit                  =>  FND_API.G_FALSE,
            p_validation_level        =>  FND_API.G_VALID_LEVEL_FULL,
            x_return_status           =>  l_return_status,
            x_msg_count               =>  l_msg_count,
            x_msg_data                =>  l_msg_data,
            p_transaction_line_rec    =>  l_transaction_line_rec_type
        );
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    --<R12 eTax Integration End>

  END Delete_Row;

END PO_LINE_LOCATIONS_PKG_S2;

/
