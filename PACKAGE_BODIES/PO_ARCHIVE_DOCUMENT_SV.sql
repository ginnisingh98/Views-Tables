--------------------------------------------------------
--  DDL for Package Body PO_ARCHIVE_DOCUMENT_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ARCHIVE_DOCUMENT_SV" AS
/* $Header: POXPIARB.pls 115.9 2003/01/10 21:59:33 pparthas ship $ */

/*
  DESCRIPTION:	   Archiving code for Purchase Orders
		   Can archive Blanket PAs using this API

  OWNER:           Imran Ali

  CHANGE HISTORY:  Created  02/17/98  Iali
		            03/30/00  Preetam Bamb (GML-OPM)
					Added 5 fields in the insert statement of PO_LINES_ARCHIVE view.
*/

-- *************************************************************************************** --

--
-- PRIVATE PROCEDURES.
--

-- Archive PO Header

procedure archive_header(X_po_header_id IN NUMBER);

-- Archive PO Lines

procedure archive_lines(X_po_header_id IN NUMBER, X_revision_num IN NUMBER);

-- Archive PO Line locations

procedure archive_line_locations(X_po_header_id IN NUMBER, X_revision_num IN NUMBER);


-- *************************************************************************************** --


--
-- PROCEDURE  Archive_PO
--

--
-- Archives the specified PO.
-- The procedure assumes that the document requires archving.
-- It does not perform any validation to check if archiving is required.
-- The calling program must do this validation.
--

--
-- In case of any error all changes to the archive table are rolled back
-- and a result of FALSE is returned.
--

PROCEDURE  Archive_PO (X_po_header_id IN NUMBER, X_result OUT NOCOPY BOOLEAN)
is

l_revision_num	number;

Begin

   X_result := TRUE;
   savepoint archiving_po_document;

   begin
	   select revision_num into l_revision_num
	   from po_headers
	   where  po_header_id = X_po_header_id;

   exception
	when others then
	l_revision_num := 0;
   end;

   begin

	-- Archive PO header

	archive_header(X_po_header_id);

	-- Archive PO Lines

	archive_lines(X_po_header_id, l_revision_num);

	-- Archive PO Line locations

	archive_line_locations(X_po_header_id, l_revision_num);

   exception
	when others then
	X_result := FALSE;
   end;

   if not X_result then
	rollback to archiving_po_document;
   end if;

End;


-- *************************************************************************************** --

--
-- PRIVATE PROCEDURES.
--

-- Archive PO Header

procedure archive_header(X_po_header_id  IN  NUMBER)
is
begin

	-- Set the latest_external_flag of the archived header to 'N'.

        UPDATE PO_HEADERS_ARCHIVE
        SET   latest_external_flag = 'N'
        WHERE po_header_id         = X_po_header_id
        AND   latest_external_flag = 'Y';

	/*  Archive the header.
            This will be an exact copy of po_headers except for
            the latest_external_flag.  Keep the columns in
            alphabetical order for easy verification.
        */
        INSERT INTO PO_HEADERS_ARCHIVE
            (
             acceptance_due_date             ,
             acceptance_required_flag        ,
             agent_id                        ,
             amount_limit                    ,
             approval_required_flag          ,
             approved_date                   ,
             approved_flag                   ,
             attribute1                      ,
             attribute10                     ,
             attribute11                     ,
             attribute12                     ,
             attribute13                     ,
             attribute14                     ,
             attribute15                     ,
             attribute2                      ,
             attribute3                      ,
             attribute4                      ,
             attribute5                      ,
             attribute6                      ,
             attribute7                      ,
             attribute8                      ,
             attribute9                      ,
             attribute_category              ,
             authorization_status            ,
             bill_to_location_id             ,
             blanket_total_amount            ,
             cancel_flag                     ,
             closed_code                     ,
             closed_date                     ,
             comments                        ,
             confirming_order_flag           ,
             created_by                      ,
             creation_date                   ,
             currency_code                   ,
             enabled_flag                    ,
             end_date                        ,
             end_date_active                 ,
             firm_status_lookup_code         ,
             fob_lookup_code                 ,
             freight_terms_lookup_code       ,
             from_header_id                  ,
             from_type_lookup_code           ,
             frozen_flag                     ,
             government_context              ,
             global_agreement_flag           ,          -- FPI GA
             last_updated_by                 ,
             last_update_date                ,
             last_update_login               ,
             latest_external_flag            ,
             min_release_amount              ,
             note_to_authorizer              ,
             note_to_receiver                ,
             note_to_vendor                  ,
             po_header_id                    ,
             printed_date                    ,
             print_count                     ,
             program_application_id          ,
             program_id                      ,
             program_update_date             ,
             quotation_class_code            ,
             quote_type_lookup_code          ,
             quote_vendor_quote_number       ,
             quote_warning_delay             ,
             quote_warning_delay_unit        ,
             rate                            ,
             rate_date                       ,
             rate_type                       ,
             reply_date                      ,
             reply_method_lookup_code        ,
             request_id                      ,
             revised_date                    ,
             revision_num                    ,
             rfq_close_date                  ,
             segment1                        ,
             segment2                        ,
             segment3                        ,
             segment4                        ,
             segment5                        ,
             ship_to_location_id             ,
             ship_via_lookup_code            ,
             start_date                      ,
             start_date_active               ,
             summary_flag                    ,
             terms_id                        ,
             type_lookup_code                ,
             user_hold_flag                  ,
             ussgl_transaction_code          ,
             vendor_contact_id               ,
             vendor_id                       ,
             vendor_order_num                ,
             vendor_site_id                  ,
             consigned_consumption_flag			 ) -- FPI Consigned Inventory
        SELECT
             acceptance_due_date             ,
             acceptance_required_flag        ,
             agent_id                        ,
             amount_limit                    ,
             approval_required_flag          ,
             approved_date                   ,
             approved_flag                   ,
             attribute1                      ,
             attribute10                     ,
             attribute11                     ,
             attribute12                     ,
             attribute13                     ,
             attribute14                     ,
             attribute15                     ,
             attribute2                      ,
             attribute3                      ,
             attribute4                      ,
             attribute5                      ,
             attribute6                      ,
             attribute7                      ,
             attribute8                      ,
             attribute9                      ,
             attribute_category              ,
             authorization_status            ,
             bill_to_location_id             ,
             blanket_total_amount            ,
             cancel_flag                     ,
             closed_code                     ,
             closed_date                     ,
             comments                        ,
             confirming_order_flag           ,
             created_by                      ,
             creation_date                   ,
             currency_code                   ,
             enabled_flag                    ,
             end_date                        ,
             end_date_active                 ,
             firm_status_lookup_code         ,
             fob_lookup_code                 ,
             freight_terms_lookup_code       ,
             from_header_id                  ,
             from_type_lookup_code           ,
             frozen_flag                     ,
             government_context              ,
             global_agreement_flag           ,      -- FPI GA
             last_updated_by                 ,
             last_update_date                ,
             last_update_login               ,
             'Y'                             ,
             min_release_amount              ,
             note_to_authorizer              ,
             note_to_receiver                ,
             note_to_vendor                  ,
             po_header_id                    ,
             printed_date                    ,
             print_count                     ,
             program_application_id          ,
             program_id                      ,
             program_update_date             ,
             quotation_class_code            ,
             quote_type_lookup_code          ,
             quote_vendor_quote_number       ,
             quote_warning_delay             ,
             quote_warning_delay_unit        ,
             rate                            ,
             rate_date                       ,
             rate_type                       ,
             reply_date                      ,
             reply_method_lookup_code        ,
             request_id                      ,
             revised_date                    ,
             revision_num                    ,
             rfq_close_date                  ,
             segment1                        ,
             segment2                        ,
             segment3                        ,
             segment4                        ,
             segment5                        ,
             ship_to_location_id             ,
             ship_via_lookup_code            ,
             start_date                      ,
             start_date_active               ,
             summary_flag                    ,
             terms_id                        ,
             type_lookup_code                ,
             user_hold_flag                  ,
             ussgl_transaction_code          ,
             vendor_contact_id               ,
             vendor_id                       ,
             vendor_order_num                ,
             vendor_site_id                  ,
             consigned_consumption_flag	      -- FPI Consigned Inventory
             FROM PO_HEADERS
        WHERE PO_HEADER_ID = x_po_header_id;

exception
	when others then
	raise;
end;

-- * ----------------------------------------------------------------------------------- * --

-- Archive PO Lines

procedure archive_lines(X_po_header_id IN NUMBER, X_revision_num IN NUMBER)
is
	l_first_count number  := 0;
	l_second_count number := 0;
begin

    select count(*) into l_first_count
    from po_lines_archive
    where po_header_id = x_po_header_id;

    /*  Archive the lines.
        This will be an exact copy of po_lines except for the
        latest_external_flag and the revision_num.  Keep the columns
        in alphabetical order for easy verification.
     */
     INSERT INTO PO_LINES_ARCHIVE
                (
                 allow_price_override_flag       ,
                 attribute1                      ,
                 attribute10                     ,
                 attribute11                     ,
                 attribute12                     ,
                 attribute13                     ,
                 attribute14                     ,
                 attribute15                     ,
                 attribute2                      ,
                 attribute3                      ,
                 attribute4                      ,
                 attribute5                      ,
                 attribute6                      ,
                 attribute7                      ,
                 attribute8                      ,
                 attribute9                      ,
                 attribute_category              ,
                 cancelled_by                    ,
                 cancel_date                     ,
                 cancel_flag                     ,
                 cancel_reason                   ,
                 capital_expense_flag            ,
                 category_id                     ,
                 closed_by                       ,
                 closed_code                     ,
                 closed_date                     ,
                 closed_flag                     ,
                 closed_reason                   ,
                 committed_amount                ,
                 contract_num                    ,
                 created_by                      ,
                 creation_date                   ,
                 firm_status_lookup_code         ,
                 from_header_id                  ,
                 from_line_id                    ,
                 government_context              ,
                 hazard_class_id                 ,
                 item_description                ,
                 item_id                         ,
                 item_revision                   ,
                 last_updated_by                 ,
                 last_update_date                ,
                 last_update_login               ,
                 latest_external_flag            ,
                 line_num                        ,
                 line_type_id                    ,
                 list_price_per_unit             ,
                 market_price                    ,
                 max_order_quantity              ,
                 min_order_quantity              ,
                 min_release_amount              ,
                 negotiated_by_preparer_flag     ,
                 note_to_vendor                  ,
                 not_to_exceed_price             ,
                 over_tolerance_error_flag       ,
                 po_header_id                    ,
                 po_line_id                      ,
                 price_break_lookup_code         ,
                 price_type_lookup_code          ,
                 program_application_id          ,
                 program_id                      ,
                 program_update_date             ,
                 qty_rcv_tolerance               ,
                 quantity                        ,
                 quantity_committed              ,
                 reference_num                   ,
                 request_id                      ,
                 revision_num                    ,
                 taxable_flag                    ,
                 tax_code_id                     ,
                 transaction_reason_code         ,
                 type_1099                       ,
                 unit_meas_lookup_code           ,
                 unit_price                      ,
                 unordered_flag                  ,
                 un_number_id                    ,
                 user_hold_flag                  ,
                 ussgl_transaction_code          ,
                 vendor_product_num              ,
		 expiration_date		 ,
		 base_qty			 ,
		 base_uom			 ,
		 secondary_qty			 ,
		 secondary_uom			 ,
		 qc_grade			)
             SELECT
                 POL.allow_price_override_flag       ,
                 POL.attribute1                      ,
                 POL.attribute10                     ,
                 POL.attribute11                     ,
                 POL.attribute12                     ,
                 POL.attribute13                     ,
                 POL.attribute14                     ,
                 POL.attribute15                     ,
                 POL.attribute2                      ,
                 POL.attribute3                      ,
                 POL.attribute4                      ,
                 POL.attribute5                      ,
                 POL.attribute6                      ,
                 POL.attribute7                      ,
                 POL.attribute8                      ,
                 POL.attribute9                      ,
                 POL.attribute_category              ,
                 POL.cancelled_by                    ,
                 POL.cancel_date                     ,
                 POL.cancel_flag                     ,
                 POL.cancel_reason                   ,
                 POL.capital_expense_flag            ,
                 POL.category_id                     ,
                 POL.closed_by                       ,
                 POL.closed_code                     ,
                 POL.closed_date                     ,
                 POL.closed_flag                     ,
                 POL.closed_reason                   ,
                 POL.committed_amount                ,
                 POL.contract_num                    ,
                 POL.created_by                      ,
                 POL.creation_date                   ,
                 POL.firm_status_lookup_code         ,
                 POL.from_header_id                  ,
                 POL.from_line_id                    ,
                 POL.government_context              ,
                 POL.hazard_class_id                 ,
                 POL.item_description                ,
                 POL.item_id                         ,
                 POL.item_revision                   ,
                 POL.last_updated_by                 ,
                 POL.last_update_date                ,
                 POL.last_update_login               ,
                 'Y'                                 ,
             	 POL.line_num                        ,
                 POL.line_type_id                    ,
                 POL.list_price_per_unit             ,
                 POL.market_price                    ,
                 POL.max_order_quantity              ,
                 POL.min_order_quantity              ,
                 POL.min_release_amount              ,
                 POL.negotiated_by_preparer_flag     ,
                 POL.note_to_vendor                  ,
                 POL.not_to_exceed_price             ,
                 POL.over_tolerance_error_flag       ,
                 POL.po_header_id                    ,
                 POL.po_line_id                      ,
                 POL.price_break_lookup_code         ,
                 POL.price_type_lookup_code          ,
                 POL.program_application_id          ,
                 POL.program_id                      ,
                 POL.program_update_date             ,
                 POL.qty_rcv_tolerance               ,
                 POL.quantity                        ,
                 POL.quantity_committed              ,
                 POL.reference_num                   ,
                 POL.request_id                      ,
                 X_revision_num                       ,
                 POL.taxable_flag                    ,
                 POL.tax_code_id                     ,
                 POL.transaction_reason_code         ,
                 POL.type_1099                       ,
                 POL.unit_meas_lookup_code           ,
                 POL.unit_price                      ,
                 POL.unordered_flag                  ,
                 POL.un_number_id                    ,
                 POL.user_hold_flag                  ,
                 POL.ussgl_transaction_code          ,
                 POL.vendor_product_num              ,
		 POL.expiration_date		     ,
		 POL.base_qty   	         	 ,
		 POL.base_uom				 ,
		 POL.secondary_qty			 ,
		 POL.secondary_uom			 ,
		 POL.qc_grade
            FROM  PO_LINES POL,
                  PO_LINES_ARCHIVE POLA
            WHERE POL.po_header_id              = X_po_header_id
            AND   POL.po_line_id                = POLA.po_line_id (+)
            AND   POLA.latest_external_flag (+) = 'Y'
            AND (
                    (POLA.po_line_id is NULL)
              OR (POL.line_num <> POLA.line_num)
              OR (POL.item_id <> POLA.item_id)
              OR (POL.item_id IS NULL AND POLA.item_id IS NOT NULL)
              OR (POL.item_id IS NOT NULL AND POLA.item_id IS NULL)
              OR (POL.item_revision <> POLA.item_revision)
              OR (POL.item_revision IS NULL AND POLA.item_revision IS NOT NULL)
              OR (POL.item_revision IS NOT NULL AND POLA.item_revision IS NULL)
              OR (POL.item_description <> POLA.item_description)
              OR (POL.item_description IS NULL
                        AND POLA.item_description IS NOT NULL)
              OR (POL.item_description IS NOT NULL
                        AND POLA.item_description IS NULL)
              OR (POL.unit_meas_lookup_code <> POLA.unit_meas_lookup_code)
              OR (POL.unit_meas_lookup_code IS NULL
                        AND POLA.unit_meas_lookup_code IS NOT NULL)
          OR (POL.unit_meas_lookup_code IS NOT NULL
                    AND POLA.unit_meas_lookup_code IS NULL)
          OR (POL.quantity_committed <> POLA.quantity_committed)
          OR (POL.quantity_committed IS NULL
                    AND POLA.quantity_committed IS NOT NULL)
          OR (POL.quantity_committed IS NOT NULL
                    AND POLA.quantity_committed IS NULL)
          OR (POL.committed_amount <> POLA.committed_amount)
          OR (POL.committed_amount IS NULL
                    AND POLA.committed_amount IS NOT NULL)
          OR (POL.committed_amount IS NOT NULL
                    AND POLA.committed_amount IS NULL)
          OR (POL.unit_price <> POLA.unit_price)
          OR (POL.unit_price IS NULL AND POLA.unit_price IS NOT NULL)
          OR (POL.unit_price IS NOT NULL AND POLA.unit_price IS NULL)
          OR (POL.un_number_id <> POLA.un_number_id)
          OR (POL.un_number_id IS NULL AND POLA.un_number_id IS NOT NULL)
          OR (POL.un_number_id IS NOT NULL AND POLA.un_number_id IS NULL)
          OR (POL.hazard_class_id <> POLA.hazard_class_id)
          OR (POL.hazard_class_id IS NULL
                    AND POLA.hazard_class_id IS NOT NULL)
          OR (POL.hazard_class_id IS NOT NULL
                    AND POLA.hazard_class_id IS NULL)
          OR (POL.note_to_vendor <> POLA.note_to_vendor)
          OR (POL.note_to_vendor IS NULL
                    AND POLA.note_to_vendor IS NOT NULL)
          OR (POL.note_to_vendor IS NOT NULL
                    AND POLA.note_to_vendor IS NULL)
          OR (POL.from_header_id <> POLA.from_header_id)
          OR (POL.from_header_id IS NULL
                    AND POLA.from_header_id IS NOT NULL)
          OR (POL.from_header_id IS NOT NULL
                    AND POLA.from_header_id IS NULL)
          OR (POL.from_line_id <> POLA.from_line_id)
          OR (POL.from_line_id IS NULL
                    AND POLA.from_line_id IS NOT NULL)
          OR (POL.from_line_id IS NOT NULL
                    AND POLA.from_line_id IS NULL)
          OR (POL.closed_flag = 'Y'
                    AND nvl(POLA.closed_flag, 'N') = 'N')
          OR (POL.vendor_product_num <> POLA.vendor_product_num)
          OR (POL.vendor_product_num IS NULL
                    AND POLA.vendor_product_num IS NOT NULL)
          OR (POL.vendor_product_num IS NOT NULL
                    AND POLA.vendor_product_num IS NULL)
          OR (POL.contract_num <> POLA.contract_num)
          OR (POL.contract_num IS NULL
                    AND POLA.contract_num IS NOT NULL)
          OR (POL.contract_num IS NOT NULL
                    AND POLA.contract_num IS NULL)
          OR (POL.price_type_lookup_code <> POLA.price_type_lookup_code)
          OR (POL.price_type_lookup_code IS NULL
                    AND POLA.price_type_lookup_code IS NOT NULL)
          OR (POL.price_type_lookup_code IS NOT NULL
                    AND POLA.price_type_lookup_code IS NULL)
 	  OR (POL.expiration_date <> POLA.expiration_date)
          OR (POL.expiration_date IS NULL
                    AND POLA.expiration_date IS NOT NULL)
          OR (POL.expiration_date IS NOT NULL
                    AND POLA.expiration_date IS NULL));

    select count(*) into l_second_count
    from po_lines_archive
    where po_header_id = x_po_header_id;

    if l_first_count = l_second_count then

	-- no row inserted
	null;

    else

        /*  Assert: Insert statement processed at least one row.
        */

        /*  Set the latest_external_flag to 'N' for all rows which have:
                 - latest_external_flag = 'Y'
                 - revision_num < X_revision_num  (the new revision of the
                                                   header)
                 - have no new archived row
        */

          UPDATE PO_LINES_ARCHIVE POL1
          SET   latest_external_flag = 'N'
          WHERE po_header_id         = X_po_header_id
          AND   latest_external_flag = 'Y'
          AND   revision_num         < X_revision_num
          AND   EXISTS
              (SELECT 'A new archived row'
               FROM   PO_LINES_ARCHIVE POL2
               WHERE  POL2.po_line_id           = POL1.po_line_id
               AND    POL2.latest_external_flag = 'Y'
               AND    POL2.revision_num         = X_revision_num);

    end if;

exception
	when others then
	raise;
end;

-- * ----------------------------------------------------------------------------------- * --

-- Archive PO Line locations

procedure archive_line_locations(X_po_header_id IN NUMBER, X_revision_num IN NUMBER)
is
	l_first_count number  := 0;
	l_second_count number := 0;
begin

    select count(*) into l_first_count
    from po_line_locations_archive
    where po_header_id = x_po_header_id;

    /*  Archive the line locations.
        This will be an exact copy of po_line_locations except for the
        latest_external_flag and the revision_num.  Keep the columns
        in alphabetical order for easy verification.
    */
     /* Bug 2704039. As part of time phased FPI project, we added the
      * start and end date for a price break. Added these conditions in
      * the where clause below so that if there are any changes to these
      * dates, the record will be archived.
     */

    INSERT INTO PO_LINE_LOCATIONS_ARCHIVE
            (
             accrue_on_receipt_flag          ,
             allow_substitute_receipts_flag  ,
             approved_date                   ,
             approved_flag                   ,
             attribute1                      ,
             attribute10                     ,
             attribute11                     ,
             attribute12                     ,
             attribute13                     ,
             attribute14                     ,
             attribute15                     ,
             attribute2                      ,
             attribute3                      ,
             attribute4                      ,
             attribute5                      ,
             attribute6                      ,
             attribute7                      ,
             attribute8                      ,
             attribute9                      ,
             attribute_category              ,
             cancelled_by                    ,
             cancel_date                     ,
             cancel_flag                     ,
             cancel_reason                   ,
             closed_by                       ,
             closed_code                     ,
             closed_date                     ,
             closed_flag                     ,
             closed_reason                   ,
             created_by                      ,
             creation_date                   ,
             days_early_receipt_allowed      ,
             days_late_receipt_allowed       ,
             encumbered_date                 ,
             encumbered_flag                 ,
             encumber_now                    ,
             end_date                        ,
             enforce_ship_to_location_code   ,
             estimated_tax_amount            ,
             firm_status_lookup_code         ,
             fob_lookup_code                 ,
             freight_terms_lookup_code       ,
             from_header_id                  ,
             from_line_id                    ,
             from_line_location_id           ,
             government_context              ,
             inspection_required_flag        ,
             invoice_close_tolerance         ,
             last_accept_date                ,
             last_updated_by                 ,
             last_update_date                ,
             last_update_login               ,
             latest_external_flag            ,
             lead_time                       ,
             lead_time_unit                  ,
             line_location_id                ,
             need_by_date                    ,
             po_header_id                    ,
             po_line_id                      ,
             po_release_id                   ,
             price_discount                  ,
             price_override                  ,
             program_application_id          ,
             program_id                      ,
             program_update_date             ,
             promised_date                   ,
             qty_rcv_exception_code          ,
             qty_rcv_tolerance               ,
             quantity                        ,
             quantity_accepted               ,
             quantity_billed                 ,
             quantity_cancelled              ,
             quantity_received               ,
             quantity_rejected               ,
             receipt_days_exception_code     ,
             receipt_required_flag           ,
             receive_close_tolerance         ,
             receiving_routing_id            ,
             request_id                      ,
             revision_num                    ,
             shipment_num                    ,
             shipment_type                   ,
             ship_to_location_id             ,
             ship_to_organization_id         ,
             ship_via_lookup_code            ,
             source_shipment_id              ,
             start_date                      ,
             taxable_flag                    ,
             tax_code_id                     ,
             terms_id                        ,
             unencumbered_quantity           ,
             unit_meas_lookup_code           ,
             unit_of_measure_class           ,
             ussgl_transaction_code          ,
             consigned_flag				          ) -- FPI Consigned Inventory
        SELECT
             POL.accrue_on_receipt_flag          ,
             POL.allow_substitute_receipts_flag  ,
             POL.approved_date                   ,
             POL.approved_flag                   ,
             POL.attribute1                      ,
             POL.attribute10                     ,
             POL.attribute11                     ,
             POL.attribute12                     ,
             POL.attribute13                     ,
             POL.attribute14                     ,
             POL.attribute15                     ,
             POL.attribute2                      ,
             POL.attribute3                      ,
             POL.attribute4                      ,
             POL.attribute5                      ,
             POL.attribute6                      ,
             POL.attribute7                      ,
             POL.attribute8                      ,
             POL.attribute9                      ,
             POL.attribute_category              ,
             POL.cancelled_by                    ,
             POL.cancel_date                     ,
             POL.cancel_flag                     ,
             POL.cancel_reason                   ,
             POL.closed_by                       ,
             POL.closed_code                     ,
             POL.closed_date                     ,
             POL.closed_flag                     ,
             POL.closed_reason                   ,
             POL.created_by                      ,
             POL.creation_date                   ,
             POL.days_early_receipt_allowed      ,
             POL.days_late_receipt_allowed       ,
             POL.encumbered_date                 ,
             POL.encumbered_flag                 ,
             POL.encumber_now                    ,
             POL.end_date                        ,
             POL.enforce_ship_to_location_code   ,
             POL.estimated_tax_amount            ,
             POL.firm_status_lookup_code         ,
             POL.fob_lookup_code                 ,
             POL.freight_terms_lookup_code       ,
             POL.from_header_id                  ,
             POL.from_line_id                    ,
             POL.from_line_location_id           ,
             POL.government_context              ,
             POL.inspection_required_flag        ,
             POL.invoice_close_tolerance         ,
             POL.last_accept_date                ,
             POL.last_updated_by                 ,
             POL.last_update_date                ,
             POL.last_update_login               ,
             'Y'                                 ,
             POL.lead_time                       ,
             POL.lead_time_unit                  ,
             POL.line_location_id                ,
             POL.need_by_date                    ,
             POL.po_header_id                    ,
             POL.po_line_id                      ,
             POL.po_release_id                   ,
             POL.price_discount                  ,
             POL.price_override                  ,
             POL.program_application_id          ,
             POL.program_id                      ,
             POL.program_update_date             ,
             POL.promised_date                   ,
             POL.qty_rcv_exception_code          ,
             POL.qty_rcv_tolerance               ,
             POL.quantity                        ,
             POL.quantity_accepted               ,
             POL.quantity_billed                 ,
             POL.quantity_cancelled              ,
             POL.quantity_received               ,
             POL.quantity_rejected               ,
             POL.receipt_days_exception_code     ,
             POL.receipt_required_flag           ,
             POL.receive_close_tolerance         ,
             POL.receiving_routing_id            ,
             POL.request_id                      ,
             X_revision_num                      ,
             POL.shipment_num                    ,
             POL.shipment_type                   ,
             POL.ship_to_location_id             ,
             POL.ship_to_organization_id         ,
             POL.ship_via_lookup_code            ,
             POL.source_shipment_id              ,
             POL.start_date                      ,
             POL.taxable_flag                    ,
             POL.tax_code_id                     ,
             POL.terms_id                        ,
             POL.unencumbered_quantity           ,
             POL.unit_meas_lookup_code           ,
             POL.unit_of_measure_class           ,
             POL.ussgl_transaction_code          ,
             POL.consigned_flag                   -- FPI Consigned Inventory
             FROM PO_LINE_LOCATIONS POL,
             PO_LINE_LOCATIONS_ARCHIVE POLA
        WHERE POL.po_header_id              = X_po_header_id
        AND   POL.line_location_id          = POLA.line_location_id (+)
        AND   POLA.latest_external_flag (+) = 'Y'
        AND   POL.po_release_id is null
        AND   (
                 (POLA.line_location_id is NULL)
              OR (POL.quantity <> POLA.quantity)
              OR (POL.quantity IS NULL AND POLA.quantity IS NOT NULL)
              OR (POL.quantity IS NOT NULL AND POLA.quantity IS NULL)
              OR (POL.ship_to_location_id <> POLA.ship_to_location_id)
              OR (POL.ship_to_location_id IS NULL
                       AND POLA.ship_to_location_id IS NOT NULL)
              OR (POL.ship_to_location_id IS NOT NULL
                       AND POLA.ship_to_location_id IS NULL)
              OR (POL.need_by_date <> POLA.need_by_date)
              OR (POL.need_by_date IS NULL
                       AND POLA.need_by_date IS NOT NULL)
              OR (POL.need_by_date IS NOT NULL
                       AND POLA.need_by_date IS NULL)
              OR (POL.promised_date <> POLA.promised_date)
              OR (POL.promised_date IS NULL
                       AND POLA.promised_date IS NOT NULL)
              OR (POL.promised_date IS NOT NULL
                       AND POLA.promised_date IS NULL)
              OR (POL.last_accept_date <> POLA.last_accept_date)
              OR (POL.last_accept_date IS NULL
                       AND POLA.last_accept_date IS NOT NULL)
              OR (POL.last_accept_date IS NOT NULL
                       AND POLA.last_accept_date IS NULL)
              OR (POL.price_override <> POLA.price_override)
              OR (POL.price_override IS NULL
                       AND POLA.price_override IS NOT NULL)
              OR (POL.price_override IS NOT NULL
                       AND POLA.price_override IS NULL)
              OR (POL.taxable_flag <> POLA.taxable_flag)
              OR (POL.taxable_flag IS NULL
                       AND POLA.taxable_flag IS NOT NULL)
              OR (POL.taxable_flag IS NOT NULL
                       AND POLA.taxable_flag IS NULL)
              OR (POL.cancel_flag = 'Y'
                       AND nvl(POLA.cancel_flag,'N') = 'N')
              OR (POL.shipment_num <> POLA.shipment_num)
              OR (POL.shipment_num IS NULL
                       AND POLA.shipment_num IS NOT NULL)
              OR (POL.shipment_num IS NOT NULL
	               AND POLA.shipment_num IS NULL)
              OR (POL.start_date is not null
                       AND POLA.START_DATE IS NULL)
              OR (POL.start_date is null
                       AND POLA.START_DATE IS NOT NULL)
              OR (POL.start_date <> POLA.start_date)
              OR (POL.end_date is not null
                       AND POLA.end_date IS NULL)
              OR (POL.end_date is null
                       AND POLA.end_date IS NOT NULL)
              OR (POL.end_date <> POLA.end_date));

    select count(*) into l_second_count
    from po_line_locations_archive
    where po_header_id = x_po_header_id;

    if l_first_count = l_second_count then

	-- no row inserted
	null;

    else

        /*  Assert:  At least one row was processed in the sql statement.
        */

        /*  Set the latest_external_flag to 'N' for all rows which have:
                  - latest_external_flag = 'Y'
                  - revision_num < X_revision_num  (the new revision of the
                                                   header)
                  - have no new archived row
        */

          UPDATE PO_LINE_LOCATIONS_ARCHIVE POL1
          SET   latest_external_flag = 'N'
          WHERE po_header_id         = X_po_header_id
          AND   latest_external_flag = 'Y'
          AND   revision_num         < X_revision_num;

/*
	Do not need the fol. condition because via EDI we cannot update price breaks.
	We can only delete the existing price breaks and re-create new price breaks.
	Hence, even if the line_location_id is not the same we should reset the latest
	revision flag for older price breaks.

          AND   EXISTS
              (SELECT 'A new archived row'
               FROM   PO_LINE_LOCATIONS_ARCHIVE POL2
               WHERE  POL2.line_location_id     = POL1.line_location_id
               AND    POL2.latest_external_flag = 'Y'
               AND    POL2.revision_num         = X_revision_num);
*/

    end if;

exception
	when others then
	raise;
end;


end PO_ARCHIVE_DOCUMENT_SV;

/
