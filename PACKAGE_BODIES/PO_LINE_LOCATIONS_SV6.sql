--------------------------------------------------------
--  DDL for Package Body PO_LINE_LOCATIONS_SV6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_LINE_LOCATIONS_SV6" AS
/* $Header: POXPIISB.pls 120.2.12000000.1 2007/01/16 23:03:58 appldev ship $ */

/*================================================================

  PROCEDURE NAME: 	insert_po_line_locations()

==================================================================*/
PROCEDURE insert_po_line_locations(
                             x_line_location_id               IN NUMBER,
                             x_last_update_date               IN DATE,
                             x_last_updated_by                IN NUMBER,
                             x_po_header_id                   IN NUMBER,
                             x_po_line_id                     IN NUMBER,
                             x_last_update_login              IN NUMBER,
                             x_creation_date                  IN DATE,
                             x_created_by                     IN NUMBER,
                             x_quantity                       IN NUMBER,
                             x_quantity_received              IN NUMBER,
                             x_quantity_accepted              IN NUMBER,
                             x_quantity_rejected              IN NUMBER,
                             x_quantity_billed                IN NUMBER,
                             x_quantity_cancelled             IN NUMBER,
                             x_unit_meas_lookup_code          IN VARCHAR2,
                             x_po_release_id                  IN NUMBER,
                             x_ship_to_location_id            IN NUMBER,
                             x_ship_via_lookup_code           IN VARCHAR2,
                             x_need_by_date                   IN DATE,
                             x_promised_date                  IN DATE,
                             x_last_accept_date               IN DATE,
                             x_price_override                 IN NUMBER,
                             x_encumbered_flag                IN VARCHAR2,
                             x_encumbered_date                IN DATE,
                             x_fob_lookup_code                IN VARCHAR2,
                             x_freight_terms_lookup_code      IN VARCHAR2,
                             x_taxable_flag                   IN VARCHAR2,
                             x_tax_code_id                    IN NUMBER,
                             x_from_header_id                 IN NUMBER,
                             x_from_line_id                   IN NUMBER,
                             x_from_line_location_id          IN NUMBER,
                             x_start_date                     IN DATE,
                             x_end_date                       IN DATE,
                             x_lead_time                      IN NUMBER,
                             x_lead_time_unit                 IN VARCHAR2,
                             x_price_discount                 IN NUMBER,
                             x_terms_id                       IN NUMBER,
                             x_approved_flag                  IN VARCHAR2,
                             x_closed_flag                    IN VARCHAR2,
                             x_cancel_flag                    IN VARCHAR2,
                             x_cancelled_by                   IN NUMBER,
                             x_cancel_date                    IN DATE,
                             x_cancel_reason                  IN VARCHAR2,
                             x_firm_status_lookup_code        IN VARCHAR2,
                             x_attribute_category             IN VARCHAR2,
                             x_attribute1                     IN VARCHAR2,
                             x_attribute2                     IN VARCHAR2,
                             x_attribute3                     IN VARCHAR2,
                             x_attribute4                     IN VARCHAR2,
                             x_attribute5                     IN VARCHAR2,
                             x_attribute6                     IN VARCHAR2,
                             x_attribute7                     IN VARCHAR2,
                             x_attribute8                     IN VARCHAR2,
                             x_attribute9                     IN VARCHAR2,
                             x_attribute10                    IN VARCHAR2,
                             x_attribute11                    IN VARCHAR2,
                             x_attribute12                    IN VARCHAR2,
                             x_attribute13                    IN VARCHAR2,
                             x_attribute14                    IN VARCHAR2,
                             x_attribute15                    IN VARCHAR2,
                             x_inspection_required_flag       IN VARCHAR2,
                             x_receipt_required_flag          IN VARCHAR2,
                             x_qty_rcv_tolerance              IN NUMBER,
                             x_qty_rcv_exception_code         IN VARCHAR2,
                             x_enforce_ship_to_loc_code       IN VARCHAR2,
                             x_allow_sub_receipts_flag        IN VARCHAR2,
                             x_days_early_receipt_allowed     IN VARCHAR2,
                             x_days_late_receipt_allowed      IN VARCHAR2,
                             x_receipt_days_exception_code    IN VARCHAR2,
                             x_invoice_close_tolerance        IN NUMBER,
                             x_receive_close_tolerance        IN NUMBER,
                             x_ship_to_organization_id        IN NUMBER,
                             x_shipment_num                   IN NUMBER,
                             x_source_shipment_id             IN NUMBER,
                             x_shipment_type                  IN VARCHAR2,
                             x_closed_code                    IN VARCHAR2,
                             x_request_id                     IN NUMBER,
                             x_program_application_id         IN NUMBER,
                             x_program_id                     IN NUMBER,
                             x_program_update_date            IN DATE,
                             x_ussgl_transaction_code         IN VARCHAR2,
                             x_government_context             IN VARCHAR2,
                             x_receiving_routing_id           IN NUMBER,
                             x_accrue_on_receipt_flag         IN VARCHAR2,
                             x_closed_reason                  IN VARCHAR2,
                             x_closed_date                    IN DATE,
                             x_closed_by                      IN NUMBER,
                             x_org_id                         IN NUMBER,
                             p_transaction_flow_header_id     IN NUMBER,  --< Shared Proc FPJ >
                             --<SERVICES FPJ START>
                             p_amount                         IN NUMBER,
                             p_order_type_lookup_code         IN VARCHAR2,
                             p_purchase_basis                 IN VARCHAR2,
                             --<SERVICES FPJ END>
            	             x_match_option     IN VARCHAR2 DEFAULT NULL,
            	             X_note_to_receiver IN VARCHAR2 default null  --togeorge 09/28/2000
			     )

IS
   x_progress          varchar2(3) := null;
   l_unit_price        number;
   l_price_discount    number;
   l_type_lookup_code  po_headers_all.type_lookup_code%TYPE;   /* <TIMEPHASED FPI> */
   l_price_override    number := null;   /* <TIMEPHASED FPI> */

 BEGIN
   x_progress := '010';

   /* Bug: 550424. gtummala. 10/03/97.
    * The org_id was not being populated from the
    * default value (from client info) in the table because we
    * are passing in a value here, which could be null. If
    * we don't pass in the value org_id will get populated
    */

   -- Calculate the price_discount - Bug: 758866
   begin
	 select unit_price into l_unit_price
 	 from po_lines
	 where po_header_id = x_po_header_id
	 and   po_line_id   = x_po_line_id;

   	 l_price_discount := ROUND(((l_unit_price - x_price_override)/l_unit_price) * 100, 2);

      exception
         when others then
	 NULL;
   end;

   x_progress := '020';

   /* <TIMEPHASED FPI START> */
   /* Defaulting the price discount and pricebreak price for Blanket Agreement, if absent */
   select type_lookup_code
   into   l_type_lookup_code
   from   po_headers_all
   where  po_header_id = x_po_header_id;

   if (l_type_lookup_code = 'BLANKET') then
      if (x_price_override is not null) then
         l_price_discount := ROUND(((l_unit_price - x_price_override)/l_unit_price) * 100, 2);
      elsif (x_price_override is null AND x_price_discount is not null) then
         l_price_override := ROUND((((100 - x_price_discount)/100) * l_unit_price), 2);
      end if;
   end if;
   /* <TIMEPHASED FPI END> */

   if (l_price_override is not null) then
   INSERT INTO po_line_locations
   (
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
   tax_code_id,
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
   request_id,
   program_application_id,
   program_id,
   program_update_date,
   government_context,
   receiving_routing_id,
   accrue_on_receipt_flag,
   closed_reason,
   closed_date,
   closed_by,
   match_option,      --frkhan
   note_to_receiver,  --togeorge 09/28/2000
   transaction_flow_header_id,  --< Shared Proc FPJ >
   --<SERVICES FPJ START>
   amount,
   amount_received,
   amount_cancelled,
   amount_billed,
   --<SERVICES FPJ END>
   org_id   -- <R12 MOAC>
   )
   VALUES
   (
   x_line_location_id,
   x_last_update_date,
   x_last_updated_by,
   x_po_header_id,
   x_po_line_id,
   x_last_update_login,
   x_creation_date,
   x_created_by,
   x_quantity,
-- Bug: 1693472 Add the NVL
   nvl(x_quantity_received,0),
   nvl(x_quantity_accepted,0),
   nvl(x_quantity_rejected,0),
   nvl(x_quantity_billed,0),
   nvl(x_quantity_cancelled,0),
   x_unit_meas_lookup_code,
   x_po_release_id,
   x_ship_to_location_id,
   x_ship_via_lookup_code,
   x_need_by_date,
   x_promised_date,
   x_last_accept_date,
   l_price_override,   /* <TIMEPHASED FPI> */
   x_encumbered_flag,
   x_encumbered_date,
   x_fob_lookup_code,
   x_freight_terms_lookup_code,
   x_taxable_flag,
   x_tax_code_id,
   x_from_header_id,
   x_from_line_id,
   x_from_line_location_id,
   x_start_date,
   x_end_date,
   x_lead_time,
   x_lead_time_unit,
   l_price_discount,
   x_terms_id,
   x_approved_flag,
   x_closed_flag,
   x_cancel_flag,
   x_cancelled_by,
   x_cancel_date,
   x_cancel_reason,
   x_firm_status_lookup_code,
   x_attribute_category,
   x_attribute1,
   x_attribute2,
   x_attribute3,
   x_attribute4,
   x_attribute5,
   x_attribute6,
   x_attribute7,
   x_attribute8,
   x_attribute9,
   x_attribute10,
   x_attribute11,
   x_attribute12,
   x_attribute13,
   x_attribute14,
   x_attribute15,
   x_inspection_required_flag,
   x_receipt_required_flag,
   x_qty_rcv_tolerance,
   x_qty_rcv_exception_code,
   x_enforce_ship_to_loc_code,
   x_allow_sub_receipts_flag,
   x_days_early_receipt_allowed,
   x_days_late_receipt_allowed,
   x_receipt_days_exception_code,
   x_invoice_close_tolerance,
   x_receive_close_tolerance,
   x_ship_to_organization_id,
   x_shipment_num,
   x_source_shipment_id,
   x_shipment_type,
   x_closed_code,
   x_request_id,
   x_program_application_id,
   x_program_id,
   x_program_update_date,
   x_government_context,
   x_receiving_routing_id,
   x_accrue_on_receipt_flag,
   x_closed_reason,
   x_closed_date,
   x_closed_by,
   x_match_option,      --frkhan
   X_note_to_receiver,  --togeorge 09/28/2000
   p_transaction_flow_header_id,  --< Shared Proc FPJ >
   --<SERVICES FPJ START>
   p_amount,
   0,
   0,
   0,
   --<SERVICES FPJ END>
   X_org_id   -- <R12 MOAC>
   );

   /* <TIMEPHASED FPI START> */
   else
      INSERT INTO po_line_locations
   (
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
   tax_code_id,
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
   request_id,
   program_application_id,
   program_id,
   program_update_date,
   government_context,
   receiving_routing_id,
   accrue_on_receipt_flag,
   closed_reason,
   closed_date,
   closed_by,
   match_option,      --frkhan
   note_to_receiver,  --togeorge 09/28/2000
   transaction_flow_header_id,  --< Shared Proc FPJ >
   --<SERVICES FPJ START>
   amount,
   amount_received,
   amount_cancelled,
   amount_billed,
   --<SERVICES FPJ END>
   org_id   -- <R12 MOAC>
   )
   VALUES
   (
   x_line_location_id,
   x_last_update_date,
   x_last_updated_by,
   x_po_header_id,
   x_po_line_id,
   x_last_update_login,
   x_creation_date,
   x_created_by,
   x_quantity,
-- Bug: 1693472 Add the NVL
   nvl(x_quantity_received,0),
   nvl(x_quantity_accepted,0),
   nvl(x_quantity_rejected,0),
   nvl(x_quantity_billed,0),
   nvl(x_quantity_cancelled,0),
   x_unit_meas_lookup_code,
   x_po_release_id,
   x_ship_to_location_id,
   x_ship_via_lookup_code,
   x_need_by_date,
   x_promised_date,
   x_last_accept_date,
   x_price_override,
   x_encumbered_flag,
   x_encumbered_date,
   x_fob_lookup_code,
   x_freight_terms_lookup_code,
   x_taxable_flag,
   x_tax_code_id,
   x_from_header_id,
   x_from_line_id,
   x_from_line_location_id,
   x_start_date,
   x_end_date,
   x_lead_time,
   x_lead_time_unit,
   l_price_discount,
   x_terms_id,
   x_approved_flag,
   x_closed_flag,
   x_cancel_flag,
   x_cancelled_by,
   x_cancel_date,
   x_cancel_reason,
   x_firm_status_lookup_code,
   x_attribute_category,
   x_attribute1,
   x_attribute2,
   x_attribute3,
   x_attribute4,
   x_attribute5,
   x_attribute6,
   x_attribute7,
   x_attribute8,
   x_attribute9,
   x_attribute10,
   x_attribute11,
   x_attribute12,
   x_attribute13,
   x_attribute14,
   x_attribute15,
   x_inspection_required_flag,
   x_receipt_required_flag,
   x_qty_rcv_tolerance,
   x_qty_rcv_exception_code,
   x_enforce_ship_to_loc_code,
   x_allow_sub_receipts_flag,
   x_days_early_receipt_allowed,
   x_days_late_receipt_allowed,
   x_receipt_days_exception_code,
   x_invoice_close_tolerance,
   x_receive_close_tolerance,
   x_ship_to_organization_id,
   x_shipment_num,
   x_source_shipment_id,
   x_shipment_type,
   x_closed_code,
   x_request_id,
   x_program_application_id,
   x_program_id,
   x_program_update_date,
   x_government_context,
   x_receiving_routing_id,
   x_accrue_on_receipt_flag,
   x_closed_reason,
   x_closed_date,
   x_closed_by,
   x_match_option,      --frkhan
   X_note_to_receiver,  --togeorge 09/28/2000
   p_transaction_flow_header_id,  --< Shared Proc FPJ >
   --<SERVICES FPJ START>
   p_amount,
   0,
   0,
   0,
   --<SERVICES FPJ END>
   X_org_id   -- <R12 MOAC>
   );

   end if;
   /* <TIMEPHASED FPI END> */

EXCEPTION
  WHEN others THEN
       po_message_s.sql_error('insert_po_line_locations',
                               x_progress, sqlcode);
       raise;
END insert_po_line_locations;

END PO_LINE_LOCATIONS_SV6;

/
