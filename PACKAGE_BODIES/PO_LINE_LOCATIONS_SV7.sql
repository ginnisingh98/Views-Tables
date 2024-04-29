--------------------------------------------------------
--  DDL for Package Body PO_LINE_LOCATIONS_SV7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_LINE_LOCATIONS_SV7" AS
/* $Header: POXPISVB.pls 120.1.12000000.1 2007/01/16 23:04:46 appldev ship $ */

/*================================================================

  PROCEDURE NAME:       validate_po_line_coordination()

==================================================================*/
PROCEDURE validate_po_line_coordination(
                           X_interface_header_id      IN NUMBER,
                           X_interface_line_id        IN NUMBER,
                           X_item_id                  IN NUMBER,
                           X_item_description         IN VARCHAR2,
                           X_item_revision            IN VARCHAR2,
                           X_po_line_id               IN NUMBER,
                           X_po_header_id             IN NUMBER,
                           X_unit_of_measure          IN VARCHAR2,
                           X_line_type_id             IN NUMBER,
                           X_category_id              IN NUMBER,
                           X_type_lookup_code         IN VARCHAR2,
                           X_header_processable_flag  IN OUT NOCOPY VARCHAR2,
                           p_line_num                 IN NUMBER,
                           p_job_id                   IN NUMBER --<FPJ SERVICES>
)
IS
     X_progress        varchar2(3) := NULL;
     X_count           binary_integer;
     X_order_type      varchar2(25) := NULL;
     l_line_num        po_lines_interface.line_num%TYPE := NULL;

BEGIN
  X_progress := '010';
  /* if the create_po_line_loc_flag is Y and the order_type
     lookup_code is AMOUNT and type_lookup_code is BLANKET
     , then it should be an error, since we can not create
     price break for amount-based lines
   */

  BEGIN
    SELECT order_type_lookup_code
      INTO X_order_type
      FROM po_line_types
     WHERE line_type_id = X_line_type_id;
  EXCEPTION
    WHEN no_data_found THEN
         X_order_type := NULL;
  END;

  X_progress := '020';

  --<SERVICES FPJ>
  --Price breaks not allowed for FIXED PRICE line types as well
  IF (X_type_lookup_code = 'BLANKET') AND
     (X_order_type IN ('AMOUNT', 'FIXED PRICE')) --<SERVICES FPJ>
  THEN
     po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_PRICE_BRK_AMT_BASED_LN',
                                           'PO_LINES_INTERFACE',
                                            null,
                                            null,null,null,null,null,null,
                                            null,null,null,null,null,null,
                                            x_header_processable_flag);
  END IF;

  /* check to see if we can find the match in po_lines table
     based on the information that we had . Note we do not match
     unit_of_measure ... because for quotes we can specify UOM different from
     what is specified in po_lines, as long as it is a valid UOM.
  */
  --<SERVICES FPJ>
  --Search po_lines table based on job_id
  X_progress := '030';
  IF (X_item_id is NOT NULL) THEN

     SELECT count(*)
       INTO X_count
       FROM po_lines
      WHERE po_header_id = X_po_header_id
        AND po_line_id = X_po_line_id
        AND item_id = X_item_id
        AND (item_revision = X_item_revision
             OR
             (item_revision is NULL AND X_item_revision is NULL)
            )
        AND line_type_id = X_line_type_id
        AND category_id = X_category_id;

     IF X_count = 0 THEN
        po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_INVALID_LOCATION_REC',
                                           'PO_LINES_INTERFACE',
                                            null,
                                            null,null,null,null,null,null,
                                            null,null,null,null,null,null,
                                            x_header_processable_flag);
     END IF;

  /*
     Bug 2845962
     Check that X_item_description is not null
  */
  ELSIF (X_item_description is NOT NULL) THEN  /* item_id is null */
     X_progress := '040';

     SELECT count(*)
       INTO X_count
       FROM po_lines
      WHERE po_header_id = X_po_header_id
        AND po_line_id = X_po_line_id
        AND item_description = X_item_description
        AND line_type_id = X_line_type_id
        AND category_id = X_category_id;

     IF (X_count = 0) THEN
        po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_INVALID_LOCATION_REC',
                                           'PO_LINES_INTERFACE',
                                            null,
                                            null,null,null,null,null,null,
                                            null,null,null,null,null,null,
                                            x_header_processable_flag);
     END IF;

  --<SERVICES FPJ START>
  ELSIF (p_job_id IS NOT NULL) THEN

    SELECT count(*)
    INTO   X_count
    FROM   PO_LINES
    WHERE  po_header_id = X_po_header_id
           AND po_line_id = X_po_line_id
	   AND job_id = p_job_id
           AND line_type_id = X_line_type_id
           AND category_id = X_category_id;

    IF X_count = 0 THEN
      PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
               X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
               X_Error_type              => 'FATAL',
               X_Batch_id                => NULL,
               X_Interface_Header_Id     => x_interface_header_id,
               X_Interface_Line_id       => x_interface_line_id,
               X_Error_message_name      => 'PO_PDOI_INVALID_LOCATION_REC',
               X_Table_name              => 'PO_LINES_INTERFACE',
               X_Column_name             => 'NULL',
               X_TokenName1              => NULL,
               X_TokenName2              => NULL,
               X_TokenName3              => NULL,
               X_TokenName4              => NULL,
               X_TokenName5              => NULL,
               X_TokenName6              => NULL,
               X_TokenValue1             => NULL,
               X_TokenValue2             => NULL,
               X_TokenValue3             => NULL,
               X_TokenValue4             => NULL,
               X_TokenValue5             => NULL,
               X_TokenValue6             => NULL,
               X_header_processable_flag => x_header_processable_flag);
    END IF;
  --<SERVICES FPJ END>

  /*
     Bug 2845962 START
     When matching a shipment to a line, either line number, item ID or
     item description needs to be available. If all of them are null,
     an error message will be given.
  */
  ELSE
     X_progress := '050';

     SELECT count(*)
       INTO X_count
       FROM po_lines
      WHERE po_header_id = X_po_header_id
        AND po_line_id = X_po_line_id
        AND line_num = p_line_num;

     IF (X_count = 0) THEN
        po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_INVALID_LOCATION_REC',
                                           'PO_LINES_INTERFACE',
                                            null,
                                            null,null,null,null,null,null,
                                            null,null,null,null,null,null,
                                            x_header_processable_flag);
     END IF;
  END IF;
  /* Bug 2845962 END */

EXCEPTION
  WHEN others THEN
       po_message_s.sql_error('validate_po_line_coordination',
                                x_progress, sqlcode);
        raise;
END validate_po_line_coordination;

/*================================================================

  PROCEDURE NAME: 	validate_po_line_locations()

==================================================================*/
PROCEDURE validate_po_line_locations(
                             x_interface_header_id            IN NUMBER,
                             x_interface_line_id              IN NUMBER,
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
                             x_tax_name                       IN VARCHAR2,
                             x_estimated_tax_amount           IN NUMBER,
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
                             x_approved_date                  IN DATE,
                             x_closed_flag                    IN VARCHAR2,
                             x_cancel_flag                    IN VARCHAR2,
                             x_cancelled_by                   IN NUMBER,
                             x_cancel_date                    IN DATE,
                             x_cancel_reason                  IN VARCHAR2,
                             x_firm_status_lookup_code        IN VARCHAR2,
                             x_firm_date                      IN DATE,
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
                             x_unit_of_measure_class          IN VARCHAR2,
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
                             x_days_early_receipt_allowed     IN NUMBER,
                             x_days_late_receipt_allowed      IN NUMBER,
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
                             x_def_inv_org_id                 IN NUMBER,
                             x_header_processable_flag        IN OUT NOCOPY VARCHAR2,
                             x_hd_type_lookup_code            IN VARCHAR2,
                             X_item_id                        IN NUMBER,
                             X_item_revision                  IN VARCHAR2,
                             p_item_category_id               IN NUMBER,          --< Shared Proc FPJ >
                             x_transaction_flow_header_id     OUT NOCOPY NUMBER,  --< Shared Proc FPJ >
                             p_order_type_lookup_code         IN VARCHAR2, --<SERVICES FPJ>
                             p_purchase_basis                 IN VARCHAR2, --<SERVICES FPJ>
                             p_job_id                         IN NUMBER
)
IS

   x_progress                 VARCHAR2(3) := null;
   x_valid                    BOOLEAN;
   x_res_terms_id             number := null;
-- Bug: 1710995 Define the codes according to the definition in the po_lookup_codes table.
   x_res_fob                   po_lookup_codes.lookup_code%TYPE := null;
   x_res_freight               po_lookup_codes.lookup_code%TYPE := null;
   x_res_carrier              varchar2(25) := null;
   X_temp_count               binary_integer;
   l_header_start_date        date := null;                                       /* <TIMEPHASED FPI> */
   l_header_end_date          date := null;                                       /* <TIMEPHASED FPI> */
   l_exp_date                 date := null;                                       /* <TIMEPHASED FPI> */
   l_errormsg                 varchar2(80) := null;                               /* <TIMEPHASED FPI> */
   l_pb_lookup_code           po_lines_all.price_break_lookup_code%TYPE := null;  /* <TIMEPHASED FPI> */
   l_is_ship_to_org_valid     BOOLEAN;      --< Shared Proc FPJ >
   l_in_current_sob           BOOLEAN;      --< Shared Proc FPJ >
   l_check_txn_flow           BOOLEAN;      --< Shared Proc FPJ >
   l_return_status            VARCHAR2(1);  --< Shared Proc FPJ >
   l_line_price               PO_LINES_ALL.unit_price%TYPE; -- Bug 3348047

 BEGIN

   /*** first need to make sure all the required columns are populated ***/
   X_progress := '010';
   IF (x_shipment_type IS NULL) THEN
      po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NOT_NULL',
                                           'PO_LINES_INTERFACE',
                                           'SHIPMENT_TYPE',
                                           'COLUMN_NAME',
                                            null,null,null,null,null,
                                           'SHIPMENT_TYPE',
                                            null,null,null,null,null,
                                            x_header_processable_flag);
   END IF;

   X_progress := '020';
   IF (X_shipment_num IS NULL) THEN
      po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NOT_NULL',
                                           'PO_LINES_INTERFACE',
                                           'SHIPMENT_NUM',
                                           'COLUMN_NAME',
                                            null,null,null,null,null,
                                           'SHIPMENT_NUM',
                                            null,null,null,null,null,
                                            x_header_processable_flag);


   END IF;

   X_progress := '030';
   IF (X_line_location_id IS NULL) THEN
      po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NOT_NULL',
                                           'PO_LINES_INTERFACE',
                                           'PO_LINE_LOCATION_ID',
                                           'COLUMN_NAME',
                                            null,null,null,null,null,
                                           'PO_LINE_LOCATION_ID',
                                            null,null,null,null,null,
                                            x_header_processable_flag);

   END IF;


   X_progress := '040';
   IF (X_po_line_id IS NULL) THEN
      po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NOT_NULL',
                                           'PO_LINES_INTERFACE',
                                           'PO_LINE_ID',
                                           'COLUMN_NAME',
                                            null,null,null,null,null,
                                           'PO_LINE_ID',
                                            null,null,null,null,null,
                                            x_header_processable_flag);

   END IF;


   X_progress := '050';
   IF (X_po_header_id IS NULL) THEN
      po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NOT_NULL',
                                           'PO_LINES_INTERFACE',
                                           'PO_HEADER_ID',
                                           'COLUMN_NAME',
                                            null,null,null,null,null,
                                           'PO_HEADER_ID',
                                            null,null,null,null,null,
                                            x_header_processable_flag);
   END IF;


   X_progress := '060';

   --<SERVICES FPJ START>
   --Allow only 1 shipment for Temp Labor line types.

   IF (x_hd_type_lookup_code = 'STANDARD'
       AND p_purchase_basis = 'TEMP LABOR') THEN

     --check if there is already a shipment
     SELECT COUNT(*)
     INTO   x_temp_count
     FROM   PO_LINE_LOCATIONS
     WHERE  po_line_id = x_po_line_id;

     IF x_temp_count >= 1 THEN
       PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
               X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
               X_Error_type              => 'FATAL',
               X_Batch_id                => NULL,
               X_Interface_Header_Id     => x_interface_header_id,
               X_Interface_Line_id       => x_interface_line_id,
               X_Error_message_name      => 'PO_PDOI_SVC_NO_MULTI_SHIP',
               X_Table_name              => 'PO_LINES_INTERFACE',
               X_Column_name             => 'NULL',
               X_TokenName1              => NULL,
               X_TokenName2              => NULL,
               X_TokenName3              => NULL,
               X_TokenName4              => NULL,
               X_TokenName5              => NULL,
               X_TokenName6              => NULL,
               X_TokenValue1             => NULL,
               X_TokenValue2             => NULL,
               X_TokenValue3             => NULL,
               X_TokenValue4             => NULL,
               X_TokenValue5             => NULL,
               X_TokenValue6             => NULL,
               X_header_processable_flag => x_header_processable_flag);
     END IF;
   END IF;

   X_progress := '065';

   IF (p_order_type_lookup_code in ('RATE', 'FIXED PRICE')) THEN

     IF (x_quantity IS NOT NULL) THEN
	 PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
               X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
               X_Error_type              => 'FATAL',
               X_Batch_id                => NULL,
               X_Interface_Header_Id     => x_interface_header_id,
               X_Interface_Line_id       => x_interface_line_id,
               X_Error_message_name      => 'PO_PDOI_SVC_PB_NO_QTY',
               X_Table_name              => 'PO_LINES_INTERFACE',
               X_Column_name             => 'QUANTITY',
               X_TokenName1              => NULL,
               X_TokenName2              => NULL,
               X_TokenName3              => NULL,
               X_TokenName4              => NULL,
               X_TokenName5              => NULL,
               X_TokenName6              => NULL,
               X_TokenValue1             => NULL,
               X_TokenValue2             => NULL,
               X_TokenValue3             => NULL,
               X_TokenValue4             => NULL,
               X_TokenValue5             => NULL,
               X_TokenValue6             => NULL,
               X_header_processable_flag => x_header_processable_flag);
     END IF;

   ELSE
   --<SERVICES FPJ END>

      if (x_hd_type_lookup_code <> 'BLANKET') then   /* <TIMEPHASED FPI> */
         IF (X_quantity IS NULL) THEN
            po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NOT_NULL',
                                           'PO_LINES_INTERFACE',
                                           'QUANTITY',
                                           'COLUMN_NAME',
                                            null,null,null,null,null,
                                           'QUANTITY',
                                            null,null,null,null,null,
                                            x_header_processable_flag);
         END IF;
      end if;   /* <TIMEPHASED FPI> */
   END IF; --p_order_type_lookup_code in ('RATE', 'FIXED PRICE')

   X_progress := '070';

   /* <TIMEPHASED FPI> */
   /* Added x_price_discount as part of the condition */

   IF (p_order_type_lookup_code <> 'FIXED PRICE') THEN --<SERVICES FPJ>
     IF (X_price_override IS NULL AND x_price_discount IS NULL) THEN   /* <TIMEPHASED FPI> */
        po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NOT_NULL',
                                           'PO_LINES_INTERFACE',
                                           'PRICE_OVERRIDE',
                                           'COLUMN_NAME',
                                            null,null,null,null,null,
                                           'PRICE_OVERRIDE',
                                            null,null,null,null,null,
                                            x_header_processable_flag);
     END IF;
   END IF; --<SERVICES FPJ>


   /* <TIMEPHASED FPI START> */
   if (x_hd_type_lookup_code = 'BLANKET') then

      /* Get the header and line values from the database */
      BEGIN
         select poh.start_date, poh.end_date, pol.expiration_date
         into   l_header_start_date, l_header_end_date, l_exp_date
         from   po_headers poh,
                po_lines pol
         where  poh.po_header_id = x_po_header_id
         and    pol.po_line_id = x_po_line_id;
      EXCEPTION
         when others then
            null;
      END;

      /* Pricebreak effective dates validations */
      po_shipments_sv8.validate_effective_dates(
         l_header_start_date,
         l_header_end_date,
         x_start_date,
         x_end_date,
         l_exp_date,
         l_errormsg);
      if (l_errormsg is not null) then
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                            l_errormsg,
                                           'PO_LINES_INTERFACE',
                                           'null',
                                           'null',
                                            null,null,null,null,null,
                                           'null',
                                            null,null,null,null,null,
                                            x_header_processable_flag);
      end if;

      /* Pricebreak attributes validations */
      po_shipments_sv8.validate_pricebreak_attributes(
         x_start_date,
         x_end_date,
         x_quantity,
         x_ship_to_organization_id,
         x_ship_to_location_id,
         l_errormsg);
      if (l_errormsg is not null) then
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                            l_errormsg,
                                           'PO_LINES_INTERFACE',
                                           'null',
                                           'null',
                                            null,null,null,null,null,
                                           'null',
                                            null,null,null,null,null,
                                            x_header_processable_flag);
      end if;

      /* Validations for cummulative pricing. If effective dates are present,
         this record will not be entered */
      if (x_start_date is not null OR x_end_date is not null) then
         BEGIN
            select price_break_lookup_code
            into   l_pb_lookup_code
            from   po_lines
            where  po_header_id = x_po_header_id
            and    po_line_id = x_po_line_id;
         EXCEPTION
            when others then
               null;
         END;
         if (l_pb_lookup_code = 'CUMULATIVE') then
            po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_CUMULATIVE_FAILED',
                                           'PO_LINES_INTERFACE',
                                           'null',
                                           'null',
                                            null,null,null,null,null,
                                           'null',
                                            null,null,null,null,null,
                                            x_header_processable_flag);
         end if;

      end if;

   end if;
   /* <TIMEPHASED FPI END> */

   X_progress := '080';
   /*** validate ship_to_organization ***/
   IF (X_item_id is not NULL) AND (x_ship_to_organization_id is not NULL)
   THEN
      IF (X_item_revision is not NULL) THEN
         /* only allow those org_id when item_id  and item_revision
            is defined in mtl_item_revisions table */

         X_progress := '090';
         SELECT count(*)
           INTO X_temp_count
           FROM mtl_item_revisions
          WHERE inventory_item_id = X_item_id
            AND organization_id = x_ship_to_organization_id
            AND revision = X_item_revision;

         IF (X_temp_count = 0) THEN
            X_progress := '100';
            po_interface_errors_sv1.handle_interface_errors(
                                  'PO_DOCS_OPEN_INTERFACE',
                                  'FATAL',
                                   null,
                                   x_interface_header_id,
                                   x_interface_line_id,
                                  'PO_PDOI_INVALID_SHIP_TO_ORG_ID',
                                  'PO_LINES_INTERFACE',
                                  'SHIP_TO_ORGANIZATION_ID',
                                  'VALUE',
                                   null,null,null,null,null,
                                   x_ship_to_organization_id,
                                   null,null,null,null,null,
                                   x_header_processable_flag);
         END IF;
       ELSIF (X_item_revision is NULL) THEN
         /* only allow those orgs in which the item_id is
            defined in mtl_system_items table */

         X_progress := '110';
         SELECT count(*)
           INTO X_temp_count
           FROM mtl_system_items
          WHERE inventory_item_id = X_item_id
            AND organization_id = x_ship_to_organization_id;

         IF (X_temp_count = 0) THEN
            X_progress := '120';
            po_interface_errors_sv1.handle_interface_errors(
                                  'PO_DOCS_OPEN_INTERFACE',
                                  'FATAL',
                                   null,
                                   x_interface_header_id,
                                   x_interface_line_id,
                                  'PO_PDOI_INVALID_SHIP_TO_ORG_ID',
                                  'PO_LINES_INTERFACE',
                                  'SHIP_TO_ORGANIZATION_ID',
                                  'VALUE',
                                   null,null,null,null,null,
                                   x_ship_to_organization_id,
                                   null,null,null,null,null,
                                   x_header_processable_flag);
         END IF;
       END IF;
   ELSIF (X_item_id is NULL) AND
         (x_ship_to_organization_id is not null) THEN

         X_progress := '130';
         X_valid := hr_organizations_sv1.val_inv_organization_id(
                                               x_ship_to_organization_id);
         IF (x_valid = FALSE) THEN
            X_progress := '140';
            po_interface_errors_sv1.handle_interface_errors(
                                  'PO_DOCS_OPEN_INTERFACE',
                                  'FATAL',
                                   null,
                                   x_interface_header_id,
                                   x_interface_line_id,
                                  'PO_PDOI_INVALID_SHIP_TO_ORG_ID',
                                  'PO_LINES_INTERFACE',
                                  'SHIP_TO_ORGANIZATION_ID',
                                  'VALUE',
                                   null,null,null,null,null,
                                   x_ship_to_organization_id,
                                   null,null,null,null,null,
                                   x_header_processable_flag);
         END IF;
   END IF;

   --< Shared Proc FPJ Start >
   IF (x_hd_type_lookup_code = 'STANDARD') AND
      (x_ship_to_organization_id IS NOT NULL)
   THEN
       x_progress := '145';

       -- Validate ship-to Org, which gets txn flow header if one exists
       PO_SHARED_PROC_PVT.validate_ship_to_org
            (p_init_msg_list              => FND_API.g_false,
             x_return_status              => l_return_status,
             p_ship_to_org_id             => x_ship_to_organization_id,
             p_item_category_id           => p_item_category_id,
             p_item_id                    => x_item_id, -- Bug 3433867
             x_is_valid                   => l_is_ship_to_org_valid,
             x_in_current_sob             => l_in_current_sob,
             x_check_txn_flow             => l_check_txn_flow,
             x_transaction_flow_header_id => x_transaction_flow_header_id);

       IF (l_return_status = FND_API.g_ret_sts_unexp_error) THEN
           x_progress := '147';
           RAISE FND_API.g_exc_unexpected_error;
       END IF;

       IF (l_return_status <> FND_API.g_ret_sts_success) OR
          (NOT l_is_ship_to_org_valid)
       THEN
           -- The ship-to org is not valid
           PO_INTERFACE_ERRORS_SV1.handle_interface_errors
               (x_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
                x_error_type              => 'FATAL',
                x_batch_id                => NULL,
                x_interface_header_id     => x_interface_header_id,
                x_interface_line_id       => x_interface_line_id,
                x_error_message_name      => 'PO_PDOI_INVALID_SHIP_TO_ORG_ID',
                x_table_name              => 'PO_LINES_INTERFACE',
                x_column_name             => 'SHIP_TO_ORGANIZATION_ID',
                x_tokenname1              => 'VALUE',
                x_tokenname2              => NULL,
                x_tokenname3              => NULL,
                x_tokenname4              => NULL,
                x_tokenname5              => NULL,
                x_tokenname6              => NULL,
                x_tokenvalue1             => x_ship_to_organization_id,
                x_tokenvalue2             => NULL,
                x_tokenvalue3             => NULL,
                x_tokenvalue4             => NULL,
                x_tokenvalue5             => NULL,
                x_tokenvalue6             => NULL,
                x_header_processable_flag => x_header_processable_flag,
                x_interface_dist_id       => NULL);
       END IF;

   END IF; --<if STANDARD and x_ship_to_org...>
   --< Shared Proc FPJ End >

   --< Services FPJ Start >
   IF (x_ship_to_organization_id IS NOT NULL) AND (p_job_id IS NOT NULL) THEN

       x_progress := '148';

       -- Validate ship-to Org with respect to job on PO line
       PO_SERVICES_PVT.validate_ship_to_org
            (x_return_status  => l_return_status,
             p_job_id         => p_job_id,
             p_ship_to_org_id => x_ship_to_organization_id,
             x_is_valid       => l_is_ship_to_org_valid);

       IF (l_return_status = FND_API.g_ret_sts_unexp_error) THEN
           x_progress := '149';
           RAISE FND_API.g_exc_unexpected_error;
       END IF;

       IF (l_return_status <> FND_API.g_ret_sts_success) OR
          (NOT l_is_ship_to_org_valid)
       THEN
           -- The ship-to org is not valid
           PO_INTERFACE_ERRORS_SV1.handle_interface_errors
               (x_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
                x_error_type              => 'FATAL',
                x_batch_id                => NULL,
                x_interface_header_id     => x_interface_header_id,
                x_interface_line_id       => x_interface_line_id,
                x_error_message_name      => 'PO_PDOI_INVALID_SHIP_TO_ORG_ID',
                x_table_name              => 'PO_LINES_INTERFACE',
                x_column_name             => 'SHIP_TO_ORGANIZATION_ID',
                x_tokenname1              => 'VALUE',
                x_tokenname2              => NULL,
                x_tokenname3              => NULL,
                x_tokenname4              => NULL,
                x_tokenname5              => NULL,
                x_tokenname6              => NULL,
                x_tokenvalue1             => x_ship_to_organization_id,
                x_tokenvalue2             => NULL,
                x_tokenvalue3             => NULL,
                x_tokenvalue4             => NULL,
                x_tokenvalue5             => NULL,
                x_tokenvalue6             => NULL,
                x_header_processable_flag => x_header_processable_flag,
                x_interface_dist_id       => NULL);
       END IF;

   END IF; --<if x_ship_to_org and job not null>
   --< Services FPJ End >

   X_progress := '150';
   IF (X_ship_to_location_id IS NOT NULL)
   THEN
      /* allow those which location_id does not have inv org
         or ship_to_org_id matches the org specified in po_locations_val_v
       */

      X_progress := '160';
      SELECT count(*)
        INTO X_temp_count
        FROM po_locations_val_v
       WHERE location_id = X_ship_to_location_id
         AND ship_to_site_flag = 'Y'
         AND (inventory_organization_id IS NULL
              OR
              inventory_organization_id = X_ship_to_organization_id
   	      OR
	      X_ship_to_organization_id IS NULL
		);

      IF (X_temp_count <> 1 ) THEN
         X_progress := '170';
         po_interface_errors_sv1.handle_interface_errors(
                                  'PO_DOCS_OPEN_INTERFACE',
                                  'FATAL',
                                   null,
                                   x_interface_header_id,
                                   x_interface_line_id,
                                  'PO_PDOI_INVALID_SHIP_TO_LOC_ID',
                                  'PO_LINES_INTERFACE',
                                  'SHIP_TO_LOCATION_ID',
                                  'VALUE',
                                   null,null,null,null,null,
                                   x_ship_to_location_id,
                                   null,null,null,null,null,
                                   x_header_processable_flag);
      END IF;
   END IF;

   IF (x_terms_id is not null) THEN
      x_progress := '180';
      po_terms_sv.val_ap_terms(x_terms_id, x_res_terms_id);
      IF (x_res_terms_id is null) THEN
         x_progress := '190';
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_INVALID_PAY_TERMS',
                                           'PO_LINES_INTERFACE',
                                           'TERMS_ID',
                                           'VALUE',
                                            null,null,null,null,null,
                                            x_terms_id,
                                            null,null,null,null,null,
                                            x_header_processable_flag);
      END IF;
   END IF;

   x_progress := '200';
   IF (x_hd_type_lookup_code = 'QUOTATION') THEN
      x_progress := '210';
      IF (x_qty_rcv_tolerance < 0)
      THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_LT_ZERO',
                                           'PO_LINES_INTERFACE',
                                           'QTY_RCV_TOLERANCE',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'QTY_RCV_TOLERANCE',
                                            x_qty_rcv_tolerance,
                                            null,null,null,null,
                                            x_header_processable_flag);
      END IF;

      IF (x_qty_rcv_exception_code is not null) THEN
         x_progress := '220';
         x_valid :=po_headers_sv6.val_lookup_code(
                                                  x_qty_rcv_exception_code,
                                                  'RECEIVING CONTROL LEVEL');
         IF (x_valid = FALSE) THEN
            po_interface_errors_sv1.handle_interface_errors(
                                   'PO_DOCS_OPEN_INTERFACE',
                                   'FATAL',
                                    null,
                                    x_interface_header_id,
                                    x_interface_line_id,
                                   'PO_PDOI_INVALID_RCV_EXCEP_CD',
                                   'PO_LINES_INTERFACE',
                                   'QTY_RCV_EXCEPTION_CODE',
                                   'VALUE',
                                    null,null,null,null,null,
                                    x_qty_rcv_exception_code,
                                    null,null,null,null,null,
                                    x_header_processable_flag);
         END IF;
      END IF;

      x_progress := '230';
      IF (x_ship_via_lookup_code is not null) AND
         (x_def_inv_org_id is not null)
      THEN
         po_vendors_sv.val_freight_carrier(x_ship_via_lookup_code,
                                           x_def_inv_org_id, x_res_carrier);
         IF (x_res_carrier is null) THEN
            x_progress := '240';
            po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_INVALID_FREIGHT_CARR',
                                           'PO_LINES_INTERFACE',
                                           'SHIP_VIA_LOOKUP_CODE',
                                           'VALUE',
                                            null,null,null,null,null,
                                            x_ship_via_lookup_code,
                                            null,null,null,null,null,
                                            x_header_processable_flag);
         END IF;
      END IF;

      IF (x_fob_lookup_code is not null) THEN
         x_progress := '240';
         po_vendors_sv.val_fob(x_fob_lookup_code, x_res_fob);
         IF (x_res_fob is null) THEN
            po_interface_errors_sv1.handle_interface_errors(
                                              'PO_DOCS_OPEN_INTERFACE',
                                              'FATAL',
                                               null,
                                               x_interface_header_id,
                                               x_interface_line_id,
                                              'PO_PDOI_INVALID_FOB',
                                              'PO_LINES_INTERFACE',
                                              'FOB_LOOKUP_CODE',
                                              'VALUE',
                                               null,null,null,null,null,
                                               x_fob_lookup_code,
                                               null,null,null,null,null,
                                               x_header_processable_flag);
         END IF;
      END IF;

      x_progress := '250';
      IF (x_freight_terms_lookup_code is not null) THEN
         x_progress := '260';
         po_vendors_sv.val_freight_terms(x_freight_terms_lookup_code,
                                         x_res_freight);
         IF (x_res_freight is null) THEN
            po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_INVALID_FREIGHT_TERMS',
                                           'PO_LINES_INTERFACE',
                                           'FREIGHT_TERMS_LOOKUP_CODE',
                                           'VALUE',
                                            null,null,null,null,null,
                                            x_freight_terms_lookup_code,
                                            null,null,null,null,null,
                                            x_header_processable_flag);
         END IF;
      END IF;
   END IF; /* document_type = 'QUOTATION' */

   x_progress := '270';
   IF (x_price_override < 0)  THEN
      po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
                                         null,
                                         x_interface_header_id,
                                         x_interface_line_id,
                                        'PO_PDOI_LT_ZERO',
                                        'PO_LINES_INTERFACE',
                                        'PRICE_OVERRIDE',
                                        'COLUMN_NAME',
                                        'VALUE',
                                         null,null,null,null,
                                        'PRICE_OVERRIDE',
                                         x_price_override,
                                         null,null,null,null,
                                         x_header_processable_flag);
   END IF;

   x_progress := '280';
   IF (x_lead_time_unit is not null) THEN
      x_progress := '290';
      x_valid := po_unit_of_measures_sv1.val_unit_of_measure(x_lead_time_unit,
							NULL);
      IF (x_valid = FALSE) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
                                         null,
                                         x_interface_header_id,
                                         x_interface_line_id,
                                        'PO_PDOI_INVALID_LEAD_TIME',
                                        'PO_LINES_INTERFACE',
                                        'LEAD_TIME_UNIT',
                                        'VALUE',
                                         null,null,null,null,null,
                                         x_lead_time_unit,
                                         null,null,null,null,null,
                                         x_header_processable_flag);
      END IF;
   END IF;

   x_progress := '300';
   IF (x_price_discount is not null) THEN
      x_progress := '310';
      x_valid := po_core_sv1.val_discount(x_price_discount);
      IF (x_valid = FALSE) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_INVALID_DISCOUNT',
                                           'PO_LINES_INTERFACE',
                                           'PRICE_DISCOUNT',
                                           'VALUE',
                                            null,null,null,null,null,
                                            x_price_discount,
                                            null,null,null,null,null,
                                            x_header_processable_flag);
      END IF;
   END IF;

   x_progress := '320';
   IF (x_start_date is not null) AND (x_end_date is not null) THEN
      x_progress := '330';
      x_valid := po_core_sv1.val_start_and_end_date(x_start_date, x_end_date);
      IF (x_valid = FALSE) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
                                         null,
                                         x_interface_header_id,
                                         x_interface_line_id,
                                        'PO_PDOI_INVALID_START_DATE',
                                        'PO_LINES_INTERFACE',
                                        'START_DATE',
                                        'VALUE',
                                         null,null,null,null,null,
                                         fnd_date.date_to_chardate(x_start_date),
                                         null,null,null,null,null,
                                         x_header_processable_flag);
      END IF;
   END IF;

   X_progress := '340';
   IF (x_po_header_id IS NOT null) AND
      (x_start_date IS NOT NULL)
   THEN
         x_progress := '350';
		/** validate start_date is greater than effective date
		of the header ***/
         x_valid := po_core_sv1.val_effective_date(x_start_date,
                                                   x_po_header_id);
         IF (x_valid = FALSE) THEN
            po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
                                         null,
                                         x_interface_header_id,
                                         x_interface_line_id,
                                        'PO_PDOI_EFF_DATE_GT_HEADER',
                                        'PO_LINES_INTERFACE',
                                        'EFFECTIVE_DATE',
                                        'VALUE',
                                         null,null,null,null,null,
                                         fnd_date.date_to_chardate(x_start_date),
                                         null,null,null,null,null,
                                         x_header_processable_flag);
         END IF;
    END IF;

    IF (X_po_header_id IS NOT NULL) AND (X_end_date IS NOT NULL) THEN
         x_progress := '360';
         x_valid := po_core_sv1.val_effective_date(x_end_date,
                                                   x_po_header_id);
         IF (x_valid = FALSE) THEN
            po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                         'FATAL',
                                         null,
                                         x_interface_header_id,
                                         x_interface_line_id,
                                        'PO_PDOI_EFF_DATE_GT_HEADER',
                                        'PO_LINES_INTERFACE',
                                        'EXPIRATION_DATE',
                                        'VALUE',
                                         null,null,null,null,null,
                                         fnd_date.date_to_chardate(x_end_date),
                                         null,null,null,null,null,
                                         x_header_processable_flag);
         END IF;
   END IF; /* if x_end_date is not null */

   x_progress := '370';
   IF (X_hd_type_lookup_code is not null) AND
      (X_shipment_type is not null) THEN

      X_progress := '380';
      X_valid := po_line_locations_sv1.val_shipment_type(X_shipment_type,
                                                   X_hd_type_lookup_code);
      IF (X_valid = FALSE) THEN
         X_progress := '390';
         po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
                                         null,
                                         x_interface_header_id,
                                         x_interface_line_id,
                                        'PO_PDOI_INVALID_SHIPMENT_TYPE',
                                        'PO_LINES_INTERFACE',
                                        'SHIPMENT_TYPE',
                                        'TYPE',
                                        'VALUE',
                                         null,null,null,null,
                                         x_shipment_type,
                                         x_hd_type_lookup_code,
                                         null,null,null,null,
                                         x_header_processable_flag);
      END IF;
   END IF;

   X_progress := '400';
   IF (x_shipment_num is not null) AND (x_po_header_id is not null) AND
      (x_po_line_id is not null) AND (x_shipment_type is not null) THEN

      X_progress := '410';
      x_valid := po_line_locations_sv1.val_shipment_num(x_shipment_num,
                                                           x_shipment_type,
                                                           x_po_header_id,
                                                           x_po_line_id,
                                                           null);
      IF (x_valid = FALSE) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
                                         null,
                                         x_interface_header_id,
                                         x_interface_line_id,
                                        'PO_PDOI_SHIPMENT_NUM_UNIQUE',
                                        'PO_LINES_INTERFACE',
                                        'SHIPMENT_NUM',
                                        'VALUE',
                                         null,null,null,null,null,
                                         x_shipment_num,
                                         null,null,null,null,null,
                                         x_header_processable_flag);
      END IF;

      X_progress := '420';
      IF (x_shipment_num <= 0) THEN
         X_progress := '430';
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_LT_ZERO',
                                           'PO_LINES_INTERFACE',
                                           'SHIPMENT_NUM',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'SHIPMENT_NUM',
                                            x_shipment_num,
                                            null,null,null,null,
                                            x_header_processable_flag);
      END IF;
   END IF;

   X_progress := '420';
   /*** validate uniqueness of po_line_location_id ***/
   X_valid := po_line_locations_sv7.val_line_location_id_unique(
							X_line_location_id);

   IF (X_valid = FALSE) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
                                         null,
                                         x_interface_header_id,
                                         x_interface_line_id,
                                        'PO_PDOI_LINE_LOC_ID_UNIQUE',
                                        'PO_LINES_INTERFACE',
                                        'LINE_LOCATION_ID',
                                        'VALUE',
                                         null,null,null,null,null,
                                         x_line_location_id,
                                         null,null,null,null,null,
                                         x_header_processable_flag);
    END IF;

--VRANKAIY -> validation for std PO
 IF (x_shipment_type = 'STANDARD') THEN

   x_progress := '430';
   IF (x_enforce_ship_to_loc_code is not null) THEN
      x_progress := '440';

      IF (x_enforce_ship_to_loc_code <> 'NONE' AND
		x_enforce_ship_to_loc_code <> 'REJECT' AND
		x_enforce_ship_to_loc_code <> 'WARNING' ) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_INVALID_EN_SH_LOC_CODE',
                                           'PO_LINES_INTERFACE',
                                           'ENFORCE_SHIP_TO_LOCATION_CODE',
                                           'VALUE',
                                            null,null,null,null,null,
                                            x_enforce_ship_to_loc_code,
                                            null,null,null,null,null,
                                            x_header_processable_flag);
      END IF;
   END IF;

   x_progress := '450';
   IF (x_allow_sub_receipts_flag is not null) THEN
      x_progress := '460';
      IF (x_allow_sub_receipts_flag <> 'Y' AND
		x_allow_sub_receipts_flag <> 'N' ) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_ALLOW_SUB_REC_FLAG',
                                           'PO_LINES_INTERFACE',
                                           'ALLOW_SUBSTITUE_RECEIPTS_FLAG',
                                           'VALUE',
                                            null,null,null,null,null,
                                            x_allow_sub_receipts_flag,
                                            null,null,null,null,null,
                                            x_header_processable_flag);
      END IF;
   END IF;

   x_progress := '470';
   IF (x_days_early_receipt_allowed is not null) THEN
      x_progress := '480';
      IF (x_days_early_receipt_allowed < 0 ) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_DAYS_EARLY_REC_ALLOWED',
                                           'PO_LINES_INTERFACE',
                                           'DAYS_EARLY_RECEIPT_ALLOWED',
                                           'VALUE',
                                            null,null,null,null,null,
                                            x_days_early_receipt_allowed,
                                            null,null,null,null,null,
                                            x_header_processable_flag);
      END IF;
   END IF;

   x_progress := '490';
   IF (x_receipt_days_exception_code is not null) THEN
      x_progress := '500';

      IF (x_receipt_days_exception_code <> 'NONE' AND
		x_receipt_days_exception_code <> 'REJECT' AND
		x_receipt_days_exception_code <> 'WARNING' ) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_INV_REC_DAYS_EX_CODE',
                                           'PO_LINES_INTERFACE',
                                           'RECEIPT_DAYS_EXCEPTION_CODE',
                                           'VALUE',
                                            null,null,null,null,null,
                                            x_receipt_days_exception_code,
                                            null,null,null,null,null,
                                            x_header_processable_flag);
      END IF;
   END IF;

   x_progress := '510';
   IF (x_invoice_close_tolerance is not null) THEN
      x_progress := '520';
      IF (x_invoice_close_tolerance >= 0 and
		x_invoice_close_tolerance <= 100) THEN
	x_valid := TRUE;
      ELSE
	x_valid := FALSE;
      END IF;

      IF (x_valid = FALSE) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_INV_CLOSE_TOLERANCE',
                                           'PO_LINES_INTERFACE',
                                           'INVOICE_CLOSE_TOLERANCE',
                                           --PBWC Message Change Impact:
                                           --Removing a token.
                                            null,null,null,null,null,null,
                                            null,null,null,null,null,null,
                                            x_header_processable_flag);
      END IF;
   END IF;

   x_progress := '530';
   IF (x_receive_close_tolerance is not null) THEN
      x_progress := '540';
      IF (x_receive_close_tolerance >= 0 and
		x_receive_close_tolerance <= 100) THEN
	x_valid := TRUE;
      ELSE
	x_valid := FALSE;
      END IF;

      IF (x_valid = FALSE) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_RCT_CLOSE_TOLERANCE',
                                           'PO_LINES_INTERFACE',
                                           'RECEIPT_CLOSE_TOLERANCE',
                                           'VALUE',
                                            null,null,null,null,null,
                                            x_receive_close_tolerance,
                                            null,null,null,null,null,
                                            x_header_processable_flag);
      END IF;
   END IF;

   x_progress := '550';
   IF (x_receiving_routing_id is not null) THEN
      x_progress := '560';
      select count(*) into X_temp_count
      from rcv_routing_headers
      where routing_header_id = x_receiving_routing_id;

      IF (X_temp_count = 0) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_INVALID_ROUTING_ID',
                                           'PO_LINES_INTERFACE',
                                           'RECEIVING_ROUTING_ID',
                                           'VALUE',
                                            null,null,null,null,null,
                                            x_receiving_routing_id,
                                            null,null,null,null,null,
                                            x_header_processable_flag);
      END IF;
   END IF;

   x_progress := '570';
   IF (x_accrue_on_receipt_flag is not null) THEN
      x_progress := '580';
      IF (x_accrue_on_receipt_flag <> 'Y' AND
		x_accrue_on_receipt_flag <> 'N' ) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_ACCRUE_ON_RCT',
                                           'PO_LINES_INTERFACE',
                                           'ACCRUE_ON_RECEIPT_FLAG',
                                           'VALUE',
                                            null,null,null,null,null,
                                            x_accrue_on_receipt_flag,
                                            null,null,null,null,null,
                                            x_header_processable_flag);
      END IF;
   END IF;

   x_progress := '590';
   IF (x_firm_status_lookup_code is not null) THEN
      x_progress := '600';
      IF (x_firm_status_lookup_code <> 'Y' AND
		x_firm_status_lookup_code <> 'N' ) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_INVALID_FIRM_FLAG',
                                           'PO_LINES_INTERFACE',
                                           'FIRM_FLAG',
                                           'VALUE',
                                            null,null,null,null,null,
                                            x_firm_status_lookup_code,
                                            null,null,null,null,null,
                                            x_header_processable_flag);
      END IF;
   END IF;

   -- Bug 3348047 START
   ---------------------------------------------------------------------------
   -- Check: The price on a Standard PO shipment must be equal to the price
   -- on the corresponding line.
   ---------------------------------------------------------------------------
   IF (x_price_override is not null) THEN

     BEGIN
       SELECT unit_price
       INTO l_line_price
       FROM po_lines
       WHERE po_header_id = x_po_header_id
       AND   po_line_id = x_po_line_id;

       IF (x_price_override <> NVL(l_line_price,-1)) THEN
         PO_INTERFACE_ERRORS_SV1.handle_interface_errors
             (x_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
              x_error_type              => 'FATAL',
              x_batch_id                => NULL,
              x_interface_header_id     => x_interface_header_id,
              x_interface_line_id       => x_interface_line_id,
              x_error_message_name      => 'PO_PDOI_SHIP_PRICE_NE_LINE',
              x_table_name              => 'PO_LINES_INTERFACE',
              x_column_name             => 'UNIT_PRICE',
              x_tokenname1              => 'SHIP_PRICE',
              x_tokenname2              => 'LINE_PRICE',
              x_tokenname3              => NULL,
              x_tokenname4              => NULL,
              x_tokenname5              => NULL,
              x_tokenname6              => NULL,
              x_tokenvalue1             => x_price_override,
              x_tokenvalue2             => l_line_price,
              x_tokenvalue3             => NULL,
              x_tokenvalue4             => NULL,
              x_tokenvalue5             => NULL,
              x_tokenvalue6             => NULL,
              x_header_processable_flag => x_header_processable_flag,
              x_interface_dist_id       => NULL);
       END IF;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         null;
     END;

   END IF; -- x_price_override
   -- Bug 3348047 END

END IF; -- x_shipment_type = 'STANDARD'

EXCEPTION
   WHEN others THEN
        po_message_s.sql_error('validate_po_line_locations',
                                x_progress, sqlcode);
        raise;
END validate_po_line_locations;


/*================================================================

  FUNCTION NAME:       val_line_location_id_unique()

==================================================================*/
FUNCTION val_line_location_id_unique(X_line_location_id IN NUMBER)
        RETURN	 BOOLEAN  IS

    	X_temp     NUMBER;
	X_progress VARCHAR2(3) := NULL;
BEGIN
	X_progress := '010';
	SELECT  COUNT(*)
	INTO    X_temp
	FROM	po_line_locations
	WHERE	line_location_id = X_line_location_id;

	X_progress := '020';
	IF (X_temp = 0) THEN
		RETURN TRUE;
	ELSE
		RETURN FALSE;
	END IF;

EXCEPTION
   WHEN others THEN
        po_message_s.sql_error('val_line_location_id_unqiue',
                                x_progress, sqlcode);
        raise;
END val_line_location_id_unique;

END PO_LINE_LOCATIONS_SV7;

/
