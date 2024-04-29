--------------------------------------------------------
--  DDL for Package Body PO_LINES_SV7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_LINES_SV7" AS
/* $Header: POXPIVLB.pls 120.1.12000000.2 2007/07/18 12:25:58 puppulur ship $ */

-- Read the profile option that enables/disables the debug log
g_po_pdoi_write_to_file VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_PDOI_WRITE_TO_FILE'),'N');

/*================================================================

  PROCEDURE NAME:       validate_item_related_info()

==================================================================*/
PROCEDURE validate_item_related_info(X_interface_header_id     IN NUMBER,
                                     X_interface_line_id       IN NUMBER,
                                     X_item_id                 IN NUMBER,
				     X_item_description	       IN VARCHAR2,
                                     X_unit_of_measure         IN VARCHAR2,
                                     X_item_revision           IN VARCHAR2,
                                     X_category_id             IN NUMBER,
                                     X_def_inv_org_id          IN NUMBER,
                                     X_outside_operation_flag  IN VARCHAR2,
				     X_create_or_update_item_flag IN VARCHAR2,
                                     X_header_processable_flag IN OUT NOCOPY VARCHAR2,
                                     X_global_agreement_flag   IN VARCHAR2,  -- FPI GA
                                     X_type_lookup_code        IN  VARCHAR2) -- Bug 3362369
IS
   X_progress        varchar2(3) := NULL;
   X_valid           BOOLEAN;
   X_allow_item_desc_update_flag
		 mtl_system_items.allow_item_desc_update_flag%TYPE;
   X_msi_item_description   mtl_system_items.description%TYPE;
   l_bom_item_type          mtl_system_items.bom_item_type%TYPE;

BEGIN
   X_progress := '010';
   IF (X_item_id is NOT NULL) THEN
      X_progress := '020';

      Begin
        select bom_item_type
        into l_bom_item_type
        from mtl_system_items
        where inventory_item_id = X_item_id
        and organization_id = X_def_inv_org_id;
      Exception
        When others then
          l_bom_item_type := null;
      End;

      -- Bug 3362369 : ATO models are not purchasable
      IF X_type_lookup_code = 'STANDARD' and
         l_bom_item_type in (1,2) THEN
          po_interface_errors_sv1.handle_interface_errors(
                                         'PO_DOCS_OPEN_INTERFACE',
                                         'FATAL',
                                          null,
                                          X_interface_header_id,
                                          X_interface_line_id,
                                         'PO_ATO_ITEM_NA',
                                         'PO_LINES_INTERFACE',
                                         'ITEM_ID',
                                          null,
                                          null,null,null,null,null,
                                          null,
                                          null,null,null,null,null,
                                          X_header_processable_flag);
      END IF;

      IF X_global_agreement_flag = 'Y' and X_outside_operation_flag = 'Y' THEN
          po_interface_errors_sv1.handle_interface_errors(
                                         'PO_DOCS_OPEN_INTERFACE',
                                         'FATAL',
                                          null,
                                          X_interface_header_id,
                                          X_interface_line_id,
                                         'PO_PDOI_GA_ITEM_NA',
                                         'PO_LINES_INTERFACE',
                                         'ITEM_ID',
                                          null,
                                          null,null,null,null,null,
                                          null,
                                          null,null,null,null,null,
                                          X_header_processable_flag);
      END IF;

      x_valid := po_items_sv1.val_item_id(X_item_id,
                                          X_def_inv_org_id,
                                          X_outside_operation_flag);

      IF (x_valid = FALSE) THEN
         IF (X_outside_operation_flag = 'N') THEN
            X_progress := '030';
            po_interface_errors_sv1.handle_interface_errors(
                                         'PO_DOCS_OPEN_INTERFACE',
                                         'FATAL',
                                          null,
                                          X_interface_header_id,
                                          X_interface_line_id,
                                         'PO_PDOI_INVALID_ITEM_ID',
                                         'PO_LINES_INTERFACE',
                                         'ITEM_ID',
                                         'VALUE',
                                          null,null,null,null,null,
                                          X_item_id,
                                          null,null,null,null,null,
                                          X_header_processable_flag);

         ELSIF (X_outside_operation_flag = 'Y') THEN
            X_progress := '040';
            po_interface_errors_sv1.handle_interface_errors(
                                         'PO_DOCS_OPEN_INTERFACE',
                                         'FATAL',
                                          null,
                                          X_interface_header_id,
                                          X_interface_line_id,
                                         'PO_PDOI_INVALID_OP_ITEM_ID',
                                         'PO_LINES_INTERFACE',
                                         'ITEM_ID',
                                         'VALUE',
                                          null,null,null,null,null,
                                          X_item_id,
                                          null,null,null,null,null,
                                          X_header_processable_flag);
         END IF;
      ELSE  /* x_valid = TRUE  Bug 3109243*/

      /*** also need to find out if item_description is different from
      what is setup for the item. Would not allow item_description update
      if item attribute allow_item_desc_update_flag is N
       ****/
      X_progress := '090';

      /** Bug 5366732 If foreign language is used then item_desc comparision was always
Failing because derived value of X_item_description was coming from
mtl_system_items_tl to keep consistency changing below SQL to fetch item desc
from mtl_system_items_tl **/


      SELECT    msi.allow_item_desc_update_flag,
               mtl.description
        INTO    X_allow_item_desc_update_flag,
                X_msi_item_description
       FROM     mtl_system_items msi, mtl_system_items_tl mtl
       WHERE    mtl.inventory_item_id = msi.inventory_item_id
              and mtl.organization_id = msi.organization_id
              and mtl.language = USERENV('LANG')
              and mtl.inventory_item_id = X_item_id
              and msi.organization_id = X_def_inv_org_id;
/* Bug 5366732 End */


      X_progress :=  '100';
      IF (X_allow_item_desc_update_flag = 'N') AND
         (X_item_description <> X_msi_item_description) AND
         (X_create_or_update_item_flag = 'N')
      THEN
                /*** error because descriptions do not match and item attribute
                does not allow item description update  and update item runtime
                parameter is not set.
                ***/

          X_progress :=  '110';
          po_interface_errors_sv1.handle_interface_errors(
                                         'PO_DOCS_OPEN_INTERFACE',
                                         'FATAL',
                                          null,
                                          X_interface_header_id,
                                          X_interface_line_id,
                                         'PO_PDOI_DIFF_ITEM_DESC',
                                         'PO_LINES_INTERFACE',
                                         'ITEM_DESCRIPTION',
                                          null, null, null, null, null, null,
                                          null, null, null, null, null, null,
                                          X_header_processable_flag);
      END IF;

      END IF; -- x_valid

      X_progress := '050';
      IF (X_unit_of_measure is not null) THEN
         X_progress := '060';
         x_valid := po_unit_of_measures_sv1.val_item_unit_of_measure(
                                                       X_unit_of_measure,
                                                       X_item_id,
                                                       X_def_inv_org_id);
         IF (x_valid = FALSE) THEN
            po_interface_errors_sv1.handle_interface_errors(
                                            'PO_DOCS_OPEN_INTERFACE',
                                            'FATAL',
                                             null,
                                             X_interface_header_id,
                                             X_interface_line_id,
                                            'PO_PDOI_ITEM_RELATED_INFO',
                                            'PO_LINES_INTERFACE',
                                            'UNIT_OF_MEASURE',
                                            'COLUMN_NAME',
                                            'VALUE',
                                            'ITEM',
                                             null, null, null,
                                            'UNIT_OF_MEASURE',
                                             X_unit_of_measure,
                                             X_item_id,
                                             null, null, null,
                                             X_header_processable_flag);
        END IF;
      END IF;

      X_progress := '070';
      IF (X_item_revision is not null) THEN
         x_valid := mtl_item_revisions_sv1.val_item_revision(
                                                       X_item_revision,
                                                       X_item_id,
                                                       X_def_inv_org_id);
         IF (x_valid = FALSE) THEN
            po_interface_errors_sv1.handle_interface_errors(
                                            'PO_DOCS_OPEN_INTERFACE',
                                            'FATAL',
                                             null,
                                             X_interface_header_id,
                                             X_interface_line_id,
                                            'PO_PDOI_ITEM_RELATED_INFO',
                                            'PO_LINES_INTERFACE',
                                            'ITEM_REVISION',
                                            'COLUMN_NAME',
                                            'VALUE',
                                            'ITEM',
                                             null, null, null,
                                            'ITEM_REVISION',
                                             X_item_revision,
                                             X_item_id,
                                             null, null, null,
                                             X_header_processable_flag);
         END IF;
      END IF;

      X_progress := '080';
      IF (X_category_id is not null) THEN
         x_valid := po_categories_sv1.val_item_category_id(
                                                        X_category_id,
                                                        X_item_id,
                                                        X_def_inv_org_id);
         IF (x_valid = FALSE) THEN
            po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            X_interface_header_id,
                                            X_interface_line_id,
                                           'PO_PDOI_ITEM_RELATED_INFO',
                                           'PO_LINES_INTERFACE',
                                           'CATEGORY_ID',
                                           'COLUMN_NAME',
                                           'VALUE',
                                           'ITEM',
                                            null,null,null,
                                           'CATEGORY_ID',
                                            X_category_id,
                                            X_item_id,
                                            null,null,null,
                                            X_header_processable_flag);
         END IF;
      END IF;

   ELSE /* if x_item_id is null */
      X_progress := '120';
      IF (X_unit_of_measure is not null) THEN
         x_valid := po_unit_of_measures_sv1.val_unit_of_measure(
                                               X_unit_of_measure,
                                               NULL);
         IF (x_valid = FALSE) THEN
            po_interface_errors_sv1.handle_interface_errors(
                                         'PO_DOCS_OPEN_INTERFACE',
                                         'FATAL',
                                          null,
                                          X_interface_header_id,
                                          X_interface_line_id,
                                         'PO_PDOI_INVALID_UOM_CODE',
                                         'PO_LINES_INTERFACE',
                                         'UNIT_OF_MEASURE',
                                         'VALUE',
                                          null, null, null, null, null,
                                          X_unit_of_measure,
                                          null, null, null, null, null,
                                          X_header_processable_flag);
         END IF;
      END IF;

      X_progress := '110';
      IF (X_item_revision is not null) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            X_interface_header_id,
                                            X_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'ITEM_REVISION',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'ITEM_REVISION',
                                            X_item_revision,
                                            null,null,null,null,
                                            X_header_processable_flag);
      END IF;

      X_progress := '120';
      IF (X_category_id is not null) THEN
         x_valid := po_categories_sv1.val_category_id(X_category_id);

         IF (x_valid = FALSE) THEN
            po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            X_interface_header_id,
                                            X_interface_line_id,
                                           'PO_PDOI_INVALID_CATEGORY_ID',
                                           'PO_LINES_INTERFACE',
                                           'CATEGORY_ID',
                                           'VALUE',
                                            null,null,null,null,null,
                                            X_category_id,
                                            null,null,null,null,null,
                                            X_header_processable_flag);
         END IF;
      END IF;
   END IF;  /* item_id */

EXCEPTION
   WHEN others THEN
        po_message_s.sql_error('validate_item_related_info',
                                X_progress, sqlcode);
        raise;
END validate_item_related_info;

/*================================================================

  PROCEDURE NAME:       validate_item_with_line_type()

==================================================================*/
PROCEDURE validate_item_with_line_type(
                                   X_interface_header_id     IN NUMBER,
                                   X_interface_line_id       IN NUMBER,
                                   X_line_type_id            IN NUMBER,
                                   X_category_id             IN NUMBER,
                                   X_unit_of_measure         IN VARCHAR2,
                                   X_unit_price              IN NUMBER,
                                   X_item_id                 IN NUMBER,
				   X_item_description	     IN VARCHAR2,
                                   X_item_revision           IN VARCHAR2,
                                   X_def_inv_org_id          IN NUMBER,
				   X_create_or_update_item_flag IN VARCHAR2,
                                   X_header_processable_flag IN OUT NOCOPY VARCHAR2,
                                   X_global_agreement_flag   IN VARCHAR2,  -- FPI GA
                                   X_type_lookup_code        IN  VARCHAR2) -- Bug 3362369
IS
   X_progress                     varchar2(3) := null;
   X_vs_order_type_lookup_code    varchar2(25) := NULL;
   X_vs_category_id               number := NULL;
   X_vs_unit_meas_lookup_code     varchar2(25) := NULL;
   X_vs_unit_price                number := NULL;
   X_vs_outside_operation_flag    varchar2(1) := NULL;
   X_vs_receiving_flag            varchar2(1) := NULL;
   X_vs_receive_close_tolerance   number := null;    -- Bug: 1189629
BEGIN
   X_progress := '010';
  -- Bug: 1189629 Added receive close tolerance to the list of parameters
   po_line_types_sv.get_line_type_def(X_line_type_id,
                                      X_vs_order_type_lookup_code,
                                      X_vs_category_id,
                                      X_vs_unit_meas_lookup_code,
                                      X_vs_unit_price,
                                      X_vs_outside_operation_flag,
                                      X_vs_receiving_flag,
                                      X_vs_receive_close_tolerance);

   X_progress := '020';
   IF (X_vs_order_type_lookup_code = 'AMOUNT') THEN

      X_progress := '023';
      IF (X_item_id IS NOT NULL) THEN
	  /** cannot specify item for amount based line type ***/
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            X_interface_header_id,
                                            X_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'ITEM_ID',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'ITEM_ID',
                                            X_item_id,
                                            null,null,null,null,
                                            X_header_processable_flag);

      END IF;

      X_progress := '025';
      IF (X_unit_of_measure <> X_vs_unit_meas_lookup_code) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            X_interface_header_id,
                                            X_interface_line_id,
                                           'PO_PDOI_INVALID_LINE_TYPE_INFO',
                                           'PO_LINES_INTERFACE',
                                           'UNIT_OF_MEASURE',
                                           'COLUMN_NAME',
                                           'VALUE',
                                           'LINE_TYPE',
                                            null,null,null,
                                           'UNIT_OF_MEASURE',
                                            X_unit_of_measure,
                                            X_vs_unit_meas_lookup_code,
                                            null,null,null,
                                            X_header_processable_flag);
      END IF;

      X_progress := '030';
      IF (X_unit_price <> X_vs_unit_price) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            X_interface_header_id,
                                            X_interface_line_id,
                                           'PO_PDOI_INVALID_LINE_TYPE_INFO',
                                           'PO_LINES_INTERFACE',
                                           'UNIT_PRICE',
                                           'COLUMN_NAME',
                                           'VALUE',
                                           'LINE_TYPE',
                                            null,null,null,
                                           'UNIT_PRICE',
                                            X_unit_price,
                                            X_vs_unit_price,
                                            null,null,null,
                                            X_header_processable_flag);
      END IF;

   ELSIF (X_vs_order_type_lookup_code = 'QUANTITY') AND
         (X_vs_outside_operation_flag = 'Y') THEN
      /*  item_id must be not null,
          item must be an outside processing item and puurchasable item.
          all the item related fields must match what is setup for
          the item
       */

      X_progress := '040';
      IF (X_item_id is NULL) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_ITEM_NOT_NULL',
                                           'PO_LINES_INTERFACE',
                                           'ITEM_ID',
                                            null,null,null,null,null,null,
                                            null,null,null,null,null,null,
                                            x_header_processable_flag);
      END IF;
    END IF;

    /* FPI GA start*/
    /* For a global agreement OSP lines are not allowed */

    IF nvl(X_vs_outside_operation_flag,'N') = 'Y' AND
       nvl(X_global_agreement_flag,'N') = 'Y' THEN
        po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_GA_OSP_NA',
                                           'PO_LINES_INTERFACE',
                                           null,
                                            null,null,null,null,null,null,
                                            null,null,null,null,null,null,
                                            x_header_processable_flag);

    END IF;
   /* FPI GA end */

      /*** Next is to perform all the common validations regardless of the
      line type ***/

    X_progress := '050';

    --<SERVICES FPJ>
    --Do not perform the item related validations for the new services
    --line types.

    IF (X_vs_order_type_lookup_code NOT IN ('FIXED PRICE', 'RATE')) THEN --<SERVICES FPJ>
      po_lines_sv7.validate_item_related_info(
                                     X_interface_header_id,
                                     X_interface_line_id,
                                     X_item_id,
				     X_item_description,
                                     X_unit_of_measure,
                                     X_item_revision,
                                     X_category_id,
                                     X_def_inv_org_id,
                                     X_vs_outside_operation_flag,
				     X_create_or_update_item_flag,
                                     X_header_processable_flag,
                                     X_global_agreement_flag, -- FPI GA
                                     X_type_lookup_code);   -- Bug 3362369
    END IF; --<SERVICES FPJ>

EXCEPTION
   WHEN others THEN
        po_message_s.sql_error('validate_item_with_line_type',
                                X_progress, sqlcode);
        raise;
END validate_item_with_line_type;

/*================================================================

  PROCEDURE NAME: 	validate_po_lines()

==================================================================*/
 PROCEDURE validate_po_lines(x_interface_header_id            IN NUMBER,
                             x_interface_line_id              IN NUMBER,
                             x_current_po_header_id           IN NUMBER,
                             x_po_line_id                     IN NUMBER,
                             x_last_update_date               IN DATE,
                             x_last_updated_by                IN NUMBER,
                             x_po_header_id                   IN NUMBER,
                             x_line_type_id                   IN NUMBER,
                             x_line_num                       IN NUMBER,
                             x_last_update_login              IN NUMBER,
                             x_creation_date                  IN DATE,
                             x_created_by                     IN NUMBER,
                             x_item_id                        IN NUMBER,
                             x_item_revision                  IN VARCHAR2,
                             x_category_id                    IN NUMBER,
                             x_item_description               IN VARCHAR2,
                             x_unit_meas_lookup_code          IN VARCHAR2,
                             x_quantity_committed             IN NUMBER,
                             x_committed_amount               IN NUMBER,
                             x_allow_price_override_flag      IN VARCHAR2,
                             x_not_to_exceed_price            IN NUMBER,
                             x_list_price_per_unit            IN NUMBER,
                             X_base_unit_price                IN NUMBER,	-- <FPJ Advanced Price>
                             x_unit_price                     IN NUMBER,
                             x_quantity                       IN NUMBER,
                             x_un_number_id                   IN NUMBER,
                             x_hazard_class_id                IN NUMBER,
                             x_note_to_vendor                 IN VARCHAR2,
                             x_from_header_id                 IN NUMBER,
                             x_from_line_id                   IN NUMBER,
                             x_min_order_quantity             IN NUMBER,
                             x_max_order_quantity             IN NUMBER,
                             x_qty_rcv_tolerance              IN NUMBER,
                             x_over_tolerance_error_flag      IN VARCHAR2,
                             x_market_price                   IN NUMBER,
                             x_unordered_flag                 IN VARCHAR2,
                             x_closed_flag                    IN VARCHAR2,
                             x_cancel_flag                    IN VARCHAR2,
                             x_cancelled_by                   IN NUMBER,
                             x_cancel_date                    IN DATE,
                             x_cancel_reason                  IN VARCHAR2,
                             x_vendor_product_num             IN VARCHAR2,
                             x_contract_num                   IN VARCHAR2,
                             x_taxable_flag                   IN VARCHAR2,
                             x_tax_name                       IN VARCHAR2,
			     x_tax_code_id		      IN NUMBER,
                             x_type_1099                      IN VARCHAR2,
                             x_capital_expense_flag           IN VARCHAR2,
                             x_negotiated_by_preparer_flag    IN VARCHAR2,
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
                             x_min_release_amount             IN NUMBER,
                             x_price_type_lookup_code         IN VARCHAR2,
                             x_closed_code                    IN VARCHAR2,
                             x_price_break_lookup_code        IN VARCHAR2,
                             x_ussgl_transaction_code         IN VARCHAR2,
                             x_government_context             IN VARCHAR2,
                             x_request_id                     IN NUMBER,
                             x_program_application_id         IN NUMBER,
                             x_program_id                     IN NUMBER,
                             x_program_update_date            IN DATE,
                             x_closed_date                    IN DATE,
                             x_closed_reason                  IN VARCHAR2,
                             x_closed_by                      IN NUMBER,
                             x_transaction_reason_code        IN VARCHAR2,
                             x_org_id                         IN NUMBER,
                             x_line_reference_num             IN VARCHAR2,
                             x_terms_id                       IN NUMBER,
                             x_qty_rcv_exception_code         IN VARCHAR2,
                             x_lead_time_unit                 IN VARCHAR2,
                             x_freight_carrier                IN VARCHAR2,
                             x_fob                            IN VARCHAR2,
                             x_freight_terms                  IN VARCHAR2,
                             x_release_num                    IN NUMBER,
                             x_po_release_id                  IN NUMBER,
                             x_source_shipment_id             IN NUMBER,
                             x_inspection_required_flag       IN VARCHAR2,
                             x_receipt_required_flag          IN VARCHAR2,
                             x_receipt_days_exception_code    IN VARCHAR2,
                             x_need_by_date                   IN DATE,
                             x_promised_date                  IN DATE,
                             x_lead_time                      IN NUMBER,
                             x_invoice_close_tolerance        IN NUMBER,
                             x_receive_close_tolerance        IN NUMBER,
                             x_firm_flag                      IN VARCHAR2,
                             x_days_early_receipt_allowed     IN NUMBER,
                             x_days_late_receipt_allowed      IN NUMBER,
                             x_enforce_ship_to_loc_code       IN VARCHAR2,
                             x_allow_sub_receipts_flag        IN VARCHAR2,
                             x_receiving_routing              IN VARCHAR2,
                             x_receiving_routing_id           IN NUMBER,
                             x_header_processable_flag        IN OUT NOCOPY VARCHAR2,
                             x_def_inv_org_id                 IN NUMBER,
                             x_uom_code                       IN VARCHAR2,
                             x_hd_type_lookup_code            IN VARCHAR2,
			     x_create_or_update_item_flag     IN VARCHAR2,
                             X_global_agreement_flag          IN VARCHAR2,  -- FPI GA
                             p_shipment_num                   IN NUMBER,     /* <TIMEPHASED FPI> */
                             p_contract_id                    IN NUMBER, -- <GC FPJ>
                             --<SERVICES FPJ START>
                             p_job_id                         IN NUMBER,
                             p_effective_date                 IN DATE,
                             p_expiration_date                IN DATE,
                             p_amount                         IN NUMBER,
                             p_order_type_lookup_code         IN VARCHAR2,
                             p_purchase_basis                 IN VARCHAR2,
                             p_service_uom_class              IN VARCHAR2
                             --<SERVICES FPJ END>
                             -- <bug 3325447 start>
                             , p_contractor_first_name        IN VARCHAR2
                             , p_contractor_last_name         IN VARCHAR2
                             -- <bug 3325447 end>
                             , p_job_business_group_id        IN NUMBER  --<BUG 3296145>
)
 IS

  x_progress                 VARCHAR2(3) := null;
  x_valid                    BOOLEAN;
  x_res_terms_id             varchar2(25) := null;
  x_count		     number;

  /* Bug 2137906. added the below two variables */
  x_chart_of_accounts_id     number;
  x_temp_val                 BOOLEAN;

  /* <TIMEPHASED FPI START> */
  l_header_start_date        date := null;
  l_header_end_date          date := null;
  l_exp_date                 date := null;
  l_errormsg                 varchar2(80) := null;
  l_rate_type                PO_HEADERS_ALL.RATE_TYPE%TYPE;
  /* <TIMEPHASED FPI END> */

  l_valid_business_group_id  VARCHAR2(1) := 'Y'; --<BUG 3296145>

 BEGIN

   x_progress := '010';
   IF (x_current_po_header_id <> x_po_header_id) THEN
      /* since the relationship between po_header and po_line
         is mater-detail relationship, so we need to make sure
         that they have the same po_header_id */

      po_interface_errors_sv1.handle_interface_errors(
                                 'PO_DOCS_OPEN_INTERFACE',
                                 'FATAL',
                                  null,
                                  X_interface_header_id,
                                  X_interface_line_id,
                                 'PO_PDOI_SPECIF_DIFF_IN_LINES',
                                 'PO_LINES_INTERFACE',
                                 'PO_HEADER_ID',
                                 'COLUMN_NAME',
                                 'PO_HEADER_ID',
                                 'VALUE',
                                  null,null,null,
                                 'PO_HEADER_ID',
                                  X_po_header_id,
                                  X_current_po_header_id,
                                  null,null,null,
                                  x_header_processable_flag);
   END IF;

   x_progress := '012';
   IF (x_hd_type_lookup_code = 'STANDARD') THEN

      IF (x_over_tolerance_error_flag is not null) THEN
           x_valid :=po_headers_sv6.val_lookup_code(
                                                  x_over_tolerance_error_flag,
                                                  'RECEIVING CONTROL LEVEL');
            IF (x_valid = FALSE) THEN
            po_interface_errors_sv1.handle_interface_errors(
                               'PO_DOCS_OPEN_INTERFACE',
                                'FATAL',
                                null,
                                x_interface_header_id,
                                x_interface_line_id,
                               'PO_PDOI_INVALID_OVER_TOL_ERROR',
                               'PO_LINES_INTERFACE',
                               'OVER_TOLERANCE_ERROR_FLAG',
                               null,
                               null,
                                null,null,null,null,
                               null,
                               null,
                                null,null,null,null,
                                x_header_processable_flag);
            END IF;
      END IF;

    END IF;

   x_progress := '015';
   IF (x_hd_type_lookup_code = 'QUOTATION') THEN
      /* check to see if these fields are null , if are not,
         make a error mark in interface_errors_handle */

      x_progress := '017';
      IF (x_closed_code is not null) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'CLOSED_CODE',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'CLOSED_CODE',
                                            x_closed_code,
                                            null,null,null,null,
                                            x_header_processable_flag);
      END IF;


      IF (x_committed_amount is not null) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'COMMITTED_AMOUNT',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'COMMITTED_AMOUNT',
                                            x_committed_amount,
                                            null,null,null,null,
                                            x_header_processable_flag);
      END IF;

      x_progress := '020';
      IF (x_market_price is not null) AND
	 (x_create_or_update_item_flag <> 'Y')
		/*** allow market price to have NOT NULL values because
		     Item Open Interface is to be called ***/
      THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'MARKET_PRICE',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'MARKET_PRICE',
                                            x_market_price,
                                            null,null,null,null,
                                            x_header_processable_flag);
      END IF;

      x_progress := '030';
      IF (x_allow_price_override_flag is not null) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'ALLOW_PRICE_OVERRIDE_FLAG',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'ALLOW_PRICE_OVERRIDE_FLAG',
                                            x_allow_price_override_flag,
                                            null,null,null,null,
                                            x_header_processable_flag);
      END IF;

      x_progress := '040';
      IF (x_not_to_exceed_price is not null) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'NOT_TO_EXCEED_PRICE',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'NOT_TO_EXCEED_PRICE',
                                            x_not_to_exceed_price,
                                            null,null,null,null,
                                            x_header_processable_flag);
      END IF;

      x_progress := '050';
      IF (x_negotiated_by_preparer_flag is not null) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'NEGOTIATED_BY_PREPARER_FLAG',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'NEGOTIATED_BY_PREPARER_FLAG',
                                            x_negotiated_by_preparer_flag,
                                            null,null,null,null,
                                            x_header_processable_flag);
      END IF;

      x_progress := '060';
      IF (x_capital_expense_flag is not null) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'CAPITAL_EXPENSE_FLAG',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'CAPITAL_EXPENSE_FLAG',
                                            x_capital_expense_flag,
                                            null,null,null,null,
                                            x_header_processable_flag);
      END IF;

      x_progress := '070';
      IF (x_min_release_amount is not null) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'MIN_AMOUNT_RELEASE',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'MIN_AMOUNT_RELEASE',
                                            x_min_release_amount,
                                            null,null,null,null,
                                            x_header_processable_flag);
      END IF;

      x_progress := '500';
      IF (x_min_order_quantity < 0) AND (x_min_order_quantity is not null)
      THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_LT_ZERO',
                                           'PO_LINES_INTERFACE',
                                           'MIN_ORDER_QUANTITY',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'MIN_ORDER_QUANTITY',
                                            x_min_order_quantity,
                                            null,null,null,null,
                                            x_header_processable_flag);
      END IF;

      x_progress := '510';
      IF (x_max_order_quantity < 0) AND (x_max_order_quantity is not null)
      THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_LT_ZERO',
                                           'PO_LINES_INTERFACE',
                                           'MAX_ORDER_QUANTITY',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'MAX_ORDER_QUANTITY',
                                            x_max_order_quantity,
                                            null,null,null,null,
                                            x_header_processable_flag);
      END IF;

      x_progress := '520';
      IF (x_min_order_quantity is not null) AND
         (x_max_order_quantity is not null) THEN
         x_valid := po_core_sv1.val_max_and_min_qty(x_min_order_quantity,
                                                    x_max_order_quantity);
         IF (x_valid = FALSE) THEN
            po_interface_errors_sv1.handle_interface_errors(
                                              'PO_DOCS_OPEN_INTERFACE',
                                              'FATAL',
                                               null,
                                               x_interface_header_id,
                                               x_interface_line_id,
                                              'PO_PDOI_QT_MIN_GT_MAX',
                                              'PO_LINES_INTERFACE',
                                              'MIN_ORDER_QUANTITY',
                                              'MIN',
                                              'MAX',
                                               null,null,null,null,
                                               x_min_order_quantity,
                                               x_max_order_quantity,
                                               null,null,null,null,
                                               x_header_processable_flag);
         END IF;
      END IF;


      x_progress := '540';
      IF (x_over_tolerance_error_flag is not null) THEN
          x_valid :=po_headers_sv6.val_lookup_code(
                                                  x_over_tolerance_error_flag,
                                                  'RECEIVING CONTROL LEVEL');
            IF (x_valid = FALSE) THEN

            po_interface_errors_sv1.handle_interface_errors(
                               'PO_DOCS_OPEN_INTERFACE',
                                'FATAL',
                                null,
                                x_interface_header_id,
                                x_interface_line_id,
                               'PO_PDOI_INVALID_OVER_TOL_ERROR',
                               'PO_LINES_INTERFACE',
                               'OVER_TOLERANCE_ERROR_FLAG',
                               null,
                               null,
                                null,null,null,null,
                               null,
                                null,
                                null,null,null,null,
                                x_header_processable_flag);
         END IF;
      END IF;
   END IF; --quote

   IF (x_hd_type_lookup_code = 'BLANKET') THEN
      x_progress := '080';
      /* check to see if these fields are null , if are not,
         make a error mark in interface_errors_handle */

      IF (x_qty_rcv_tolerance is not null) AND
	 (x_create_or_update_item_flag <> 'Y')
      THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
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

      x_progress := '090';
      IF (x_over_tolerance_error_flag is not null) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'OVER_TOLERANCE_ERROR_FLAG',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'OVER_TOLERANCE_ERROR_FLAG',
                                            x_over_tolerance_error_flag,
                                            null,null,null,null,
                                            x_header_processable_flag);
      END IF;

      x_progress := '100';
      IF (x_qty_rcv_exception_code is not null) AND
	 (X_create_or_update_item_flag <> 'Y')
      THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'QTY_RCV_EXCEPTION_CODE',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'QTY_RCV_EXCEPTION_CODE',
                                            x_qty_rcv_exception_code,
                                            null,null,null,null,
                                            x_header_processable_flag);
      END IF;
       -- BUG 588911
       -- Remove the check to see if lead time unit is NULL
   /*
      x_progress := '110';
      IF (x_lead_time_unit is not null) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'LEAD_TIME_UNIT',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'LEAD_TIME_UNIT',
                                            x_lead_time_unit,
                                            null,null,null,null,
                                            x_header_processable_flag);
      END IF;
   */
      x_progress := '120';
      IF (x_freight_carrier is not null) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'FREIGHT_CARRIER',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'FREIGHT_CARRIER',
                                            x_freight_carrier,
                                            null,null,null,null,
                                            x_header_processable_flag);
      END IF;

      x_progress := '130';
      IF (x_fob is not null) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'FOB',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'FOB',
                                            x_fob,
                                            null,null,null,null,
                                            x_header_processable_flag);
      END IF;

      x_progress := '140';
      IF (x_freight_terms is not null) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'FREIGHT_TERMS',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'FREIGHT_TERMS',
                                            x_freight_terms,
                                            null,null,null,null,
                                            x_header_processable_flag);
      END IF;

      X_progress := '150';
      IF (x_receipt_required_flag is not null) AND
	 (x_create_or_update_item_flag <> 'Y' )
      THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'RECEIPT_REQUIRED_FLAG',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'RECEIPT_REQUIRED_FLAG',
                                            x_receipt_required_flag,
                                            null,null,null,null,
                                            x_header_processable_flag);
     END IF;

     X_progress := '155';
     IF (x_inspection_required_flag is not null) AND
        (x_create_or_update_item_flag <> 'Y')
     THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'INSPECTION_REQUIRED_FLAG',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'INSPECTION_REQUIRED_FLAG',
                                            x_inspection_required_flag,
                                            null,null,null,null,
                                            x_header_processable_flag);
     END IF;

     IF (x_min_release_amount < 0) AND (x_min_release_amount is not null)
         THEN
            po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
                                         null,
                                         x_interface_header_id,
                                         x_interface_line_id,
                                        'PO_PDOI_LT_ZERO',
                                        'PO_LINES_INTERFACE',
                                        'MIN_RELEASE_AMOUNT',
                                        'COLUMN_NAME',
                                        'VALUE',
                                         null,null,null,null,
                                        'MIN_RELEASE_AMOUNT',
                                         x_min_release_amount,
                                         null,null,null,null,
                                         x_header_processable_flag);
     END IF;

     /* <TIMEPHASED FPI START> */
     X_progress := '156';
     if (p_shipment_num is not null) then
        po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_CREATE_SUBMISSION',
                                           'PO_LINES_INTERFACE',
                                           'SHIPMENT_NUM',
                                           'COLUMN_NAME',
                                            null,null,null,null,null,
                                           'SHIPMENT_NUM',
                                            null,null,null,null,null,
                                            x_header_processable_flag);
     end if;

     X_progress := '157';
     /* Get the header and line values from the database */
     BEGIN
        select poh.effective_date, poh.expiration_date, pol.expiration_date
        into   l_header_start_date, l_header_end_date, l_exp_date
        from   po_headers_interface poh,
               po_lines_interface pol
        where  poh.interface_header_id = x_interface_header_id
        and    pol.interface_line_id = x_interface_line_id
        and    poh.interface_header_id = pol.interface_header_id;
     EXCEPTION
        when others then
           null;
     END;

     PO_DEBUG.put_line ('Before calling validate_effective_dates()');

     /*
        Validating the expiration date. Since this is a line, there is no
        pricebreak effective dates. Hence, null is being passed.
     */
     po_shipments_sv8.validate_effective_dates(
        l_header_start_date,
        l_header_end_date,
        null,
        null,
        l_exp_date,
        l_errormsg);

     PO_DEBUG.put_line ('After calling validate_effective_dates()');

     if (l_errormsg is not null) then
        po_interface_errors_sv1.handle_interface_errors(
                                          'PO_DOCS_OPEN_INTERFACE',
                                          'FATAL',
                                           null,
                                           x_interface_header_id,
                                           x_interface_line_id,
                                           l_errormsg,
                                          'PO_LINES_INTERFACE',
                                          'EXPIRATION_DATE',
                                          'COLUMN_NAME',
                                           null,null,null,null,null,
                                          'EXPIRATION_DATE',
                                           null,null,null,null,null,
                                           x_header_processable_flag);
     end if;
     /* <TIMEPHASED FPI END> */

   END IF;  --if blanket


   --<SERVICES FPJ START>
   PO_DEBUG.put_line ('Start validating services line types');

   -- Bug 3652094:
   -- Services enabled check is extended to all new line types
   IF (p_order_type_lookup_code IN ('FIXED PRICE', 'RATE')) THEN

        IF (PO_SETUP_S1.get_services_enabled_flag = 'N') THEN

    	    PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
               X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
               X_Error_type              => 'FATAL',
               X_Batch_id                => NULL,
               X_Interface_Header_Id     => x_interface_header_id,
               X_Interface_Line_id       => x_interface_line_id,
               X_Error_message_name      => 'PO_SVC_NOT_ENABLED',
               X_Table_name              => 'PO_LINES_INTERFACE',
               X_Column_name             => NULL,
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

   IF (p_purchase_basis = 'TEMP LABOR') THEN

         IF (x_hd_type_lookup_code = 'BLANKET'
             AND NVL(x_global_agreement_flag, 'N') = 'N') THEN
            --New error: line type not supported for blanket
    	    PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
               X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
               X_Error_type              => 'FATAL',
               X_Batch_id                => NULL,
               X_Interface_Header_Id     => x_interface_header_id,
               X_Interface_Line_id       => x_interface_line_id,
               X_Error_message_name      => 'PO_PDOI_SVC_NO_LOCAL_BLANKET',
               X_Table_name              => 'PO_LINES_INTERFACE',
               X_Column_name             => NULL,
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

         --<BUG 3296145 START>
         --check that business_group_id is valid.

         IF (p_job_business_group_id IS NOT NULL) THEN

           IF (g_po_pdoi_write_to_file = 'Y') THEN
             PO_DEBUG.put_line('**Start validating job_business_group_id: '||
                                p_job_business_group_id);
           END IF;

           IF nvl(HR_GENERAL.get_xbg_profile,'N') = 'N' THEN

             IF (g_po_pdoi_write_to_file = 'Y') THEN
               PO_DEBUG.put_line('Validate against FSP');
             END IF;

             SELECT COUNT(FSP.business_group_id)
             INTO   x_count
             FROM   FINANCIALS_SYSTEM_PARAMETERS FSP
             WHERE  FSP.business_group_id = p_job_business_group_id;

             IF x_count < 1 THEN

               IF (g_po_pdoi_write_to_file = 'Y') THEN
                 PO_DEBUG.put_line('ERROR: xbg profile is N but ' ||
                                   'job_business_group_id not in FSP');
               END IF;

               l_valid_business_group_id := 'N';

               PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
                      X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
                      X_Error_type              => 'FATAL',
                      X_Batch_id                => NULL,
                      X_Interface_Header_Id     => X_interface_header_id,
                      X_Interface_Line_id       => X_interface_line_id,
                      X_Error_message_name      => 'PO_PDOI_SVC_CANNOT_CROSS_BG',
                      X_Table_name              => 'PO_LINES_INTERFACE',
                      X_Column_name             => 'JOB_BUSINESS_GROUP_ID',
                      X_TokenName1              => 'JOB_BG_ID',
                      X_TokenName2              => NULL,
                      X_TokenName3              => NULL,
                      X_TokenName4              => NULL,
                      X_TokenName5              => NULL,
                      X_TokenName6              => NULL,
                      X_TokenValue1             => p_job_business_group_id,
                      X_TokenValue2             => NULL,
                      X_TokenValue3             => NULL,
                      X_TokenValue4             => NULL,
                      X_TokenValue5             => NULL,
                      X_TokenValue6             => NULL,
                      X_header_processable_flag => x_header_processable_flag);
             END IF;

           ELSE --nvl(HR_GENERAL.get_xbg_profile,'N') = 'N'

             IF (g_po_pdoi_write_to_file = 'Y') THEN
               PO_DEBUG.put_line('Validate against PBG');
             END IF;

             SELECT COUNT(PBG.business_group_id)
             INTO   x_count
             FROM   PER_BUSINESS_GROUPS_PERF PBG
             WHERE  PBG.business_group_id = p_job_business_group_id
                    AND TRUNC(sysdate) BETWEEN NVL(TRUNC(PBG.date_from), TRUNC(sysdate))
                                       AND NVL(TRUNC(PBG.date_to), TRUNC(sysdate));

             IF (x_count < 1) THEN

               IF (g_po_pdoi_write_to_file = 'Y') THEN
                 PO_DEBUG.put_line('ERROR: xbg profile is Y and ' ||
                                   'job_business_group_id not in PBG');
               END IF;

               l_valid_business_group_id := 'N';

               PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
                      X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
                      X_Error_type              => 'FATAL',
                      X_Batch_id                => NULL,
                      X_Interface_Header_Id     => X_interface_header_id,
                      X_Interface_Line_id       => X_interface_line_id,
                      X_Error_message_name      => 'PO_PDOI_SVC_INVALID_BG',
                      X_Table_name              => 'PO_LINES_INTERFACE',
                      X_Column_name             => 'JOB_BUSINESS_GROUP_ID',
                      X_TokenName1              => 'JOB_BG_ID',
                      X_TokenName2              => NULL,
                      X_TokenName3              => NULL,
                      X_TokenName4              => NULL,
                      X_TokenName5              => NULL,
                      X_TokenName6              => NULL,
                      X_TokenValue1             => p_job_business_group_id,
                      X_TokenValue2             => NULL,
                      X_TokenValue3             => NULL,
                      X_TokenValue4             => NULL,
                      X_TokenValue5             => NULL,
                      X_TokenValue6             => NULL,
                      X_header_processable_flag => x_header_processable_flag);
             END IF;

           END IF; --nvl(HR_GENERAL.get_xbg_profile,'N') = 'N'

           IF (g_po_pdoi_write_to_file = 'Y') THEN
             PO_DEBUG.put_line('**Done validating job_business_group_id');
           END IF;

         END IF; --IF (p_job_business_group_id IS NOT NULL)
         --<BUG 3296145 END>

         --Job is mandatory for Temp Labor Lines.
         IF (p_job_id IS NULL) THEN

    	    PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
               X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
               X_Error_type              => 'FATAL',
               X_Batch_id                => NULL,
               X_Interface_Header_Id     => x_interface_header_id,
               X_Interface_Line_id       => x_interface_line_id,
               X_Error_message_name      => 'PO_PDOI_SVC_MUST_JOB',
               X_Table_name              => 'PO_LINES_INTERFACE',
               X_Column_name             => 'JOB_ID',
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

         ELSE --p_job_id is not null

           --<BUG 3296145 START>
  	   --check that job_id is valid within the relevant business group.

  	   IF l_valid_business_group_id = 'Y' THEN

  	     IF (g_po_pdoi_write_to_file = 'Y') THEN
   	       PO_DEBUG.put_line('**Start validating job_id: '||p_job_id ||
                                 ' against job_business_group_id: '||
                                 p_job_business_group_id);
             END IF;

   	     IF nvl(HR_GENERAL.get_xbg_profile,'N') = 'N'
   	        OR p_job_business_group_id IS NULL THEN

   	       IF (g_po_pdoi_write_to_file = 'Y') THEN
   	         PO_DEBUG.put_line('Validate against FSP since xbg_profile=N '||
   	                           'or job_business_group_id is null');
   	       END IF;

   	       SELECT COUNT(PJ.job_id)
   	       INTO   x_count
   	       FROM   PER_JOBS_VL PJ,
   	              FINANCIALS_SYSTEM_PARAMETERS FSP
   	       WHERE  PJ.job_id = p_job_id
   	              AND PJ.business_group_id = FSP.business_group_id
   	              AND FSP.business_group_id = NVL(p_job_business_group_id,
   	                                              FSP.business_group_id)
   	              AND TRUNC(sysdate) BETWEEN NVL(TRUNC(PJ.date_from), TRUNC(sysdate))
   	                                 AND NVL(TRUNC(PJ.date_to), TRUNC(sysdate));
   	     ELSE --if HR: xbg profile = 'Y' and x_job_business_group_id not null

   	        IF (g_po_pdoi_write_to_file = 'Y') THEN
   	          PO_DEBUG.put_line('Validate against PBG since xbg_profile=Y '||
   	                           'and job_business_group_id not null');
                END IF;

   	        SELECT COUNT(PJ.job_id)
   	        INTO   x_count
   	        FROM   PER_JOBS_VL PJ,
   	               PER_BUSINESS_GROUPS_PERF PBG
   	        WHERE  PJ.job_id = p_job_id
   	               AND PJ.business_group_id = p_job_business_group_id
                       AND PJ.business_group_id = PBG.business_group_id
                       AND TRUNC(sysdate) BETWEEN NVL(TRUNC(PJ.date_from), TRUNC(sysdate))
                                          AND NVL(TRUNC(PJ.date_to), TRUNC(sysdate))
                       AND TRUNC(sysdate) BETWEEN NVL(TRUNC(PBG.date_from), TRUNC(sysdate))
                                          AND NVL(TRUNC(PBG.date_to), TRUNC(sysdate));

            END IF; --IF nvl(HR_GENERAL.get_xbg_profile,'N')...

            IF (x_count < 1) THEN

              IF (g_po_pdoi_write_to_file = 'Y') THEN
                PO_DEBUG.put_line('ERROR: job_id/business_group_id combination '||
                                  'is invalid');
              END IF;

              PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
                  X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
                  X_Error_type              => 'FATAL',
                  X_Batch_id                => NULL,
                  X_Interface_Header_Id     => X_interface_header_id,
                  X_Interface_Line_id       => X_interface_line_id,
                  X_Error_message_name      => 'PO_PDOI_SVC_INVALID_JOB',
                  X_Table_name              => 'PO_LINES_INTERFACE',
                  X_Column_name             => 'JOB_ID',
                  X_TokenName1              => 'JOB_ID',
                  X_TokenName2              => 'JOB_BG_ID',
                  X_TokenName3              => NULL,
                  X_TokenName4              => NULL,
                  X_TokenName5              => NULL,
                  X_TokenName6              => NULL,
                  X_TokenValue1             => p_job_id,
                  X_TokenValue2             => p_job_business_group_id,
                  X_TokenValue3             => NULL,
                  X_TokenValue4             => NULL,
                  X_TokenValue5             => NULL,
                  X_TokenValue6             => NULL,
                  X_header_processable_flag => x_header_processable_flag);
              END IF;

              IF (g_po_pdoi_write_to_file = 'Y') THEN
                PO_DEBUG.put_line('**Done validating job_id/business_group_id');
              END IF;

            END IF; --IF l_valid_business_group_id = 'Y'
            --<BUG 3296145 END>

            IF x_category_id IS NOT NULL THEN

                 --job should be Valid for the Purchasing category
                 SELECT COUNT(*)
                 INTO   x_count
                 FROM   PO_JOB_ASSOCIATIONS_B PJA,
                        PER_JOBS_VL PJ
                 WHERE  PJA.job_id = p_job_id
                        AND PJA.category_id = x_category_id
                        AND PJA.job_id = PJ.job_id
                        AND NVL(TRUNC(PJA.inactive_date), TRUNC(sysdate)) >= TRUNC(sysdate)
                        AND NVL(TRUNC(PJ.date_from), TRUNC(sysdate)) <= TRUNC(sysdate)
                        AND NVL(TRUNC(PJ.date_to), TRUNC(sysdate)) >= TRUNC(sysdate);

                IF (x_count < 1) THEN
        	   PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
                      X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
                      X_Error_type              => 'FATAL',
                      X_Batch_id                => NULL,
                      X_Interface_Header_Id     => X_interface_header_id,
                      X_Interface_Line_id       => X_interface_line_id,
                      X_Error_message_name      => 'PO_PDOI_SVC_INVALID_JOB_CAT',
                      X_Table_name              => 'PO_LINES_INTERFACE',
                      X_Column_name             => 'JOB_ID',
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
         END IF; --if p_job_id is null

        -- Bug 3308164 : capital expense flag is not applicable to
        -- temp labor lines
        IF (x_capital_expense_flag = 'Y') THEN
    	    PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
               X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
               X_Error_type              => 'FATAL',
               X_Batch_id                => NULL,
               X_Interface_Header_Id     => x_interface_header_id,
               X_Interface_Line_id       => x_interface_line_id,
               X_Error_message_name      => 'PO_SVC_NO_CAP_EXPENSE',
               X_Table_name              => 'PO_LINES_INTERFACE',
               X_Column_name             => 'CAPITAL_EXPENSE_FLAG',
               X_TokenName1              => 'COLUMN_NAME',
               X_TokenName2              => 'VALUE',
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

         /* Bug 3323281 Start */
         -- UN NUmber and Hazard Class not applicable for TEMP LABOR lines

         If (x_un_number_id is not NULL) then
             PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
               X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
               X_Error_type              => 'FATAL',
               X_Batch_id                => NULL,
               X_Interface_Header_Id     => x_interface_header_id,
               X_Interface_Line_id       => x_interface_line_id,
               X_Error_message_name      => 'PO__PDOI_SVC_NO_UNNUMBER',
               X_Table_name              => 'PO_LINES_INTERFACE',
               X_Column_name             => 'UN_NUMBER',
               X_TokenName1              => 'COLUMN_NAME',
               X_TokenName2              => 'VALUE',
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
          End if;

          If (x_hazard_class_id is not NULL) then
               PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
               X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
               X_Error_type              => 'FATAL',
               X_Batch_id                => NULL,
               X_Interface_Header_Id     => x_interface_header_id,
               X_Interface_Line_id       => x_interface_line_id,
               X_Error_message_name      => 'PO_PDOI_SVC_NO_HAZARD_CLASS',
               X_Table_name              => 'PO_LINES_INTERFACE',
               X_Column_name             => 'HAZARD_CLASS',
               X_TokenName1              => 'COLUMN_NAME',
               X_TokenName2              => 'VALUE',
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
           End if;

           /* Bug 3323281  End   */

         -- Bug 3320741 START
         --------------------------------------------------------------------
         -- Check: Do not allow Need-By Date if purchase basis is Temp Labor.
         --------------------------------------------------------------------
         IF (x_need_by_date IS NOT NULL) THEN
             PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
                X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
                X_Error_type              => 'FATAL',
                X_Batch_id                => NULL,
                X_Interface_Header_Id     => x_interface_header_id,
                X_Interface_Line_id       => x_interface_line_id,
                X_Error_message_name      => 'PO_SVC_NO_NEED_PROMISE_DATE',
                X_Table_name              => 'PO_LINES_INTERFACE',
                X_Column_name             => 'NEED_BY_DATE',
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

         --------------------------------------------------------------------
         -- Check: Do not allow Promised Date if purchase basis is Temp Labor.
         --------------------------------------------------------------------
         IF (x_promised_date IS NOT NULL) THEN
             PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
                X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
                X_Error_type              => 'FATAL',
                X_Batch_id                => NULL,
                X_Interface_Header_Id     => x_interface_header_id,
                X_Interface_Line_id       => x_interface_line_id,
                X_Error_message_name      => 'PO_SVC_NO_NEED_PROMISE_DATE',
                X_Table_name              => 'PO_LINES_INTERFACE',
                X_Column_name             => 'PROMISED_DATE',
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
         -- Bug 3320741 END

         IF (x_hd_type_lookup_code = 'STANDARD') THEN

            --Effective date is required for Standard PO with purchase basis
            --'TEMP LABOR'

            IF (p_effective_date IS NULL) THEN
      	       PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
                  X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
                  X_Error_type              => 'FATAL',
                  X_Batch_id                => NULL,
                  X_Interface_Header_Id     => X_interface_header_id,
                  X_Interface_Line_id       => X_interface_line_id,
                  X_Error_message_name      => 'PO_PDOI_SVC_MUST_START_DATE',
                  X_Table_name              => 'PO_LINES_INTERFACE',
                  X_Column_name             => 'EFFECTIVE_DATE',
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
            End If;

            -- Expiration date if provided should be later than the effective date
            IF ((p_expiration_date IS NOT NULL)
                 AND (p_expiration_date < p_effective_date)) THEN
     	       PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
                  X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
                  X_Error_type              => 'FATAL',
                  X_Batch_id                => NULL,
                  X_Interface_Header_Id     => X_interface_header_id,
                  X_Interface_Line_id       => X_interface_line_id,
                  X_Error_message_name      => 'PO_SVC_END_GE_START',
                  X_Table_name              => 'PO_LINES_INTERFACE',
                  X_Column_name             => 'EXPIRATION_DATE',
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

         END IF; --IF (x_hd_type_lookup_code = 'STANDARD')

    ELSE  --p_purchase_basis is not 'TEMP LABOR'

        -- For non TEMP LABOR Purchase basis, job should not be provided.
        IF (p_job_id IS NOT NULL) THEN
    	   PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
              X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
              X_Error_type              => 'FATAL',
              X_Batch_id                => NULL,
              X_Interface_Header_Id     => X_interface_header_id,
              X_Interface_Line_id       => X_interface_line_id,
              X_Error_message_name      => 'PO_PDOI_SVC_NO_JOB',
              X_Table_name              => 'PO_LINES_INTERFACE',
              X_Column_name             => 'JOB_ID',
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

        IF (x_hd_type_lookup_code = 'STANDARD') THEN
            IF (p_effective_date IS NOT NULL
                OR p_expiration_date IS NOT NULL) THEN
        	    PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
                       X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
                       X_Error_type              => 'FATAL',
                       X_Batch_id                => NULL,
             	       X_Interface_Header_Id     => X_interface_header_id,
                       X_Interface_Line_id       => X_interface_line_id,
                       X_Error_message_name      => 'PO_SVC_NO_START_END_DATE',
                       X_Table_name              => 'PO_LINES_INTERFACE',
                       X_Column_name             => 'EFFECTIVE_DATE',
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
        END IF; --IF (x_hd_type_lookup_code = 'STANDARD')

        -- <bug 3325447 start>
        -- For non TEMP LABOR Purchase basis, contractor first name or
        -- contractor last name should not be provided.
        IF (p_contractor_first_name IS NOT NULL) OR
            (p_contractor_last_name IS NOT NULL) THEN
    	   PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
              X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
              X_Error_type              => 'FATAL',
              X_Batch_id                => NULL,
              X_Interface_Header_Id     => X_interface_header_id,
              X_Interface_Line_id       => X_interface_line_id,
              X_Error_message_name      => 'PO_PDOI_SVC_NO_NAME',
              X_Table_name              => 'PO_LINES_INTERFACE',
              X_Column_name             => 'CONTRACTOR_FIRST/LAST_NAME',
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
        -- <bug 3325447 end>

   END IF;  -- End of Purchase basis TEMP LABOR


   IF (p_order_type_lookup_code IN ('FIXED PRICE', 'RATE')) THEN

         IF (x_item_id IS NOT NULL) THEN
    	    PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
               X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
               X_Error_type              => 'FATAL',
               X_Batch_id                => NULL,
               X_Interface_Header_Id     => X_interface_header_id,
               X_Interface_Line_id       => X_interface_line_id,
               X_Error_message_name      => 'PO_PDOI_SVC_NO_ITEM',
               X_Table_name              => 'PO_LINES_INTERFACE',
               X_Column_name             => 'ITEM_ID',
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

         IF (X_item_revision is not null) THEN
            PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
               X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
               X_Error_type              => 'FATAL',
               X_Batch_id                => NULL,
               X_Interface_Header_Id     => X_interface_header_id,
               X_Interface_Line_id       => X_interface_line_id,
               X_Error_message_name      => 'PO_PDOI_COLUMN_NULL',
               X_Table_name              => 'PO_LINES_INTERFACE',
               X_Column_name             => 'ITEM_REVISION',
               X_TokenName1              => 'COLUMN_NAME',
               X_TokenName2              => 'VALUE',
               X_TokenName3              => NULL,
               X_TokenName4              => NULL,
               X_TokenName5              => NULL,
               X_TokenName6              => NULL,
               X_TokenValue1             => 'ITEM_REVISION',
               X_TokenValue2             => X_item_revision,
               X_TokenValue3             => NULL,
               X_TokenValue4             => NULL,
               X_TokenValue5             => NULL,
               X_TokenValue6             => NULL,
               X_header_processable_flag => x_header_processable_flag);
         END IF;

         IF (x_quantity IS NOT NULL) THEN
    	    PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
               X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
               X_Error_type              => 'FATAL',
               X_Batch_id                => NULL,
               X_Interface_Header_Id     => X_interface_header_id,
               X_Interface_Line_id       => X_interface_line_id,
               X_Error_message_name      => 'PO_SVC_NO_QTY',
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

        IF ((p_amount IS NULL)
            AND (x_hd_type_lookup_code = 'STANDARD')) THEN
      	       PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
                  X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
                  X_Error_type              => 'FATAL',
                  X_Batch_id                => NULL,
                  X_Interface_Header_Id     => X_interface_header_id,
                  X_Interface_Line_id       => X_interface_line_id,
                  X_Error_message_name      => 'PO_PDOI_SVC_MUST_AMT',
                  X_Table_name              => 'PO_LINES_INTERFACE',
                  X_Column_name             => 'AMOUNT',
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

        IF (p_order_type_lookup_code = 'FIXED PRICE') THEN

            -- <BUG 3248161 START> For 'Fixed Price/Services' line types,
            -- need to ensure that Oracle AP is on a sufficient family pack
            -- to handle the "amount"-based matching.
            --
            IF ( p_purchase_basis = 'SERVICES' ) THEN   -- Fixed Price/Services

                IF ( PO_SERVICES_PVT.get_ap_compatibility_flag = 'N' ) THEN

                    PO_INTERFACE_ERRORS_SV1.handle_interface_errors
                    (   X_interface_type          => 'PO_DOCS_OPEN_INTERFACE'
                    ,   X_Error_type              => 'FATAL'
                    ,   X_Batch_id                => NULL
                    ,   X_Interface_Header_Id     => X_interface_header_id
                    ,   X_Interface_Line_id       => X_interface_line_id
                    ,   X_Error_message_name      => 'PO_SVC_AP_NOT_COMPATIBLE'
                    ,   X_Table_name              => 'PO_LINES_INTERFACE'
                    ,   X_Column_name             => NULL
                    ,   X_TokenName1              => NULL
                    ,   X_TokenName2              => NULL
                    ,   X_TokenName3              => NULL
                    ,   X_TokenName4              => NULL
                    ,   X_TokenName5              => NULL
                    ,   X_TokenName6              => NULL
                    ,   X_TokenValue1             => NULL
                    ,   X_TokenValue2             => NULL
                    ,   X_TokenValue3             => NULL
                    ,   X_TokenValue4             => NULL
                    ,   X_TokenValue5             => NULL
                    ,   X_TokenValue6             => NULL
                    ,   X_header_processable_flag => x_header_processable_flag
                    );
                END IF;

            END IF;                                     -- Fixed Price/Services
            --
            -- <BUG 3248161 END>

            IF (x_unit_price IS NOT NULL) THEN
     	      PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
                 X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
                 X_Error_type              => 'FATAL',
                 X_Batch_id                => NULL,
                 X_Interface_Header_Id     => X_interface_header_id,
                 X_Interface_Line_id       => X_interface_line_id,
                 X_Error_message_name      => 'PO_PDOI_SVC_NO_PRICE',
                 X_Table_name              => 'PO_LINES_INTERFACE',
                 X_Column_name             => 'UNIT_PRICE',
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

           IF (x_unit_meas_lookup_code IS NOT NULL) THEN

      	    PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
               X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
               X_Error_type              => 'FATAL',
               X_Batch_id                => NULL,
               X_Interface_Header_Id     => X_interface_header_id,
               X_Interface_Line_id       => X_interface_line_id,
               X_Error_message_name      => 'PO_PDOI_SVC_NO_UOM',
               X_Table_name              => 'PO_LINES_INTERFACE',
               X_Column_name             => 'UOM_CODE',
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

        ELSE --p_order_type_lookup_code is 'RATE'

           /* Bug 3307438 START-- For Rate Based Temp Labor Line, the Currency rate_type
           cannot be USER   */

           Begin
            select rate_type
              into l_rate_type
            from po_headers_all
            where po_header_id = X_po_header_id;

            Exception

            When others then
                 l_rate_type := Null;
            End;

            if (l_rate_type = 'User') then
                PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
                     X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
                     X_Error_type              => 'FATAL',
                     X_Batch_id                => NULL,
                     X_Interface_Header_Id     => X_interface_header_id,
                     X_Interface_Line_id       => X_interface_line_id,
                     X_Error_message_name      => 'PO_PDOI_SVC_RATE_TYPE_NO_USR',
                     X_Table_name              => 'PO_LINES_INTERFACE',
                     X_Column_name             => 'Line Type',
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
            end if;

           /* Bug 3307438  End   */

           IF (x_hd_type_lookup_code = 'BLANKET') THEN
               IF (p_amount IS NOT NULL) THEN
         	  PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
                     X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
                     X_Error_type              => 'FATAL',
                     X_Batch_id                => NULL,
                     X_Interface_Header_Id     => X_interface_header_id,
                     X_Interface_Line_id       => X_interface_line_id,
                     X_Error_message_name      => 'PO_PDOI_SVC_BLKT_NO_AMT',
                     X_Table_name              => 'PO_LINES_INTERFACE',
          	     X_Column_name             => 'AMOUNT',
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

           IF (x_unit_meas_lookup_code IS NOT NULL) THEN
              --Validate UOM against the UOM class specified in profile
              SELECT  count(*)
              INTO    x_count
              FROM    MTL_UNITS_OF_MEASURE_VL
              WHERE   uom_class = p_service_uom_class
                      AND unit_of_measure = x_unit_meas_lookup_code
                      AND sysdate < NVL(disable_date, sysdate + 1);

              IF x_count < 1 THEN
      	         PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
                    X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
                    X_Error_type              => 'FATAL',
                    X_Batch_id                => NULL,
                    X_Interface_Header_Id     => X_interface_header_id,
                    X_Interface_Line_id       => X_interface_line_id,
                    X_Error_message_name      => 'PO_PDOI_SVC_INVALID_UOM',
                    X_Table_name              => 'PO_LINES_INTERFACE',
                    X_Column_name             => 'UOM_CODE',
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
           END IF; --IF (x_unit_meas_lookup_code IS NOT NULL)

       END IF;  --if p_order_type_lookup_code = 'FIXED PRICE'

   ELSE --p_order_type_lookup_code NOT IN ('FIXED PRICE', 'RATE')

       IF (p_amount IS NOT NULL) THEN
    	   PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
               X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
               X_Error_type              => 'FATAL',
               X_Batch_id                => NULL,
               X_Interface_Header_Id     => X_interface_header_id,
               X_Interface_Line_id       => X_interface_line_id,
               X_Error_message_name      => 'PO_SVC_NO_AMT',
               X_Table_name              => 'PO_LINES_INTERFACE',
               X_Column_name             => 'AMOUNT',
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

   END IF;  --   For Order_type_lookup in FIXED PRICE , RATE

   --<SERVICES FPJ END>


--for all lookup types
      x_progress := '160';
      /* make sure that these fields are being populated */
      IF (x_line_num is null) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NOT_NULL',
                                           'PO_LINES_INTERFACE',
                                           'LINE_NUM',
                                           'COLUMN_NAME',
                                            null,null,null,null,null,
                                            'LINE_NUM',
                                            null,null,null,null,null,
                                            x_header_processable_flag);
      END IF;

      X_progress := '163';
      IF (X_po_header_id IS NULL) THEN
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


      X_progress := '165';
      IF (X_po_line_id IS NULL) THEN
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

      x_progress := '170';
      IF (x_line_type_id is null) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NOT_NULL',
                                           'PO_LINES_INTERFACE',
                                           'LINE_TYPE_ID',
                                           'COLUMN_NAME',
                                            null,null,null,null,null,
                                           'LINE_TYPE_ID',
                                            null,null,null,null,null,
                                            x_header_processable_flag);
      END IF;

      x_progress := '180';
      IF (x_category_id is null) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NOT_NULL',
                                           'PO_LINES_INTERFACE',
                                           'CATEGORY_ID',
                                           'COLUMN_NAME',
                                            null,null,null,null,null,
                                           'CATEGORY_ID',
                                            null,null,null,null,null,
                                            x_header_processable_flag);
      END IF;

      x_progress := '190';
      IF (x_item_description is null) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NOT_NULL',
                                           'PO_LINES_INTERFACE',
                                           'ITEM_DESCRIPTION',
                                           'COLUMN_NAME',
                                            null,null,null,null,null,
                                           'ITEM_DESCRIPTION',
                                            null,null,null,null,null,
                                            x_header_processable_flag);
      END IF;

      x_progress := '195';
      IF ((x_unit_meas_lookup_code IS NULL)
         AND (p_order_type_lookup_code <> 'FIXED PRICE')) THEN --<SERVICES FPJ>
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NOT_NULL',
                                           'PO_LINES_INTERFACE',
                                           'UNIT_OF_MEASURE',
                                           'COLUMN_NAME',
                                            null,null,null,null,null,
                                           'UNIT_OF_MEASURE',
                                            null,null,null,null,null,
                                            x_header_processable_flag);
      END IF;

      x_progress := '200';
      IF ((x_unit_price IS NULL)
         AND (p_order_type_lookup_code <> 'FIXED PRICE')) THEN --<SERVICES FPJ>
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NOT_NULL',
                                           'PO_LINES_INTERFACE',
                                           'UNIT_PRICE',
                                           'COLUMN_NAME',
                                            null,null,null,null,null,
                                           'UNIT_PRICE',
                                            null,null,null,null,null,
                                            x_header_processable_flag);
      END IF;
--bug 1341322
      x_progress := '205';
      IF ((x_unit_price < 0)
         AND (p_order_type_lookup_code <> 'FIXED PRICE')) THEN --<SERVICES FPJ>
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_LT_ZERO',
                                           'PO_LINES_INTERFACE',
                                           'UNIT_PRICE',
                                           'COLUMN_NAME',
                                           'VALUE',null,null,null,null,
                                           'UNIT_PRICE',
                                            x_unit_price,null,null,null,null,
                                            x_header_processable_flag);
      END IF;
      x_progress := '210';
      IF (x_release_num is not null) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'RELEASE_NUM',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'RELEASE_NUM',
                                            x_release_num,
                                            null,null,null,null,
                                            x_header_processable_flag);
      END IF;

      x_progress := '220';
      IF (x_po_release_id is not null) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'PO_RELEASE_ID',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'PO_RELEASE_ID',
                                            x_po_release_id,
                                            null,null,null,null,
                                            x_header_processable_flag);
      END IF;

      x_progress := '230';
      IF (x_source_shipment_id is not null) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'SOURCE_SHIPMENT_ID',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'SOURCE_SHIPMENT_ID',
                                            x_source_shipment_id,
                                            null,null,null,null,
                                            x_header_processable_flag);
      END IF;

      x_progress := '240';
      IF (x_contract_num is not null) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'CONTRACT_NUM',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'CONTRACT_NUM',
                                            x_contract_num,
                                            null,null,null,null,
                                            x_header_processable_flag);
      END IF;

      -- <GC FPJ START>
      -- PDOI does not support importing contract reference info

      x_progress := '245';
      IF (p_contract_id IS NOT NULL) THEN
         PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'CONTRACT_ID',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'CONTRACT_ID',
                                            p_contract_id,
                                            null,null,null,null,
                                            x_header_processable_flag);
      END IF;

      -- <GC FPJ END>

      x_progress := '250';
      IF (x_type_1099 is not null) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                            'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'TYPE_1099',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'TYPE_1099',
                                            x_type_1099,
                                            null,null,null,null,
                                            x_header_processable_flag);
      END IF;

      x_progress := '270';
--frkhan not for standards
      IF (x_hd_type_lookup_code in ('QUOTATION', 'BLANKET')) THEN

         IF (x_receipt_days_exception_code is not null) AND
         (x_create_or_update_item_flag <> 'Y')
         THEN
            po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'RECEIPT_DAYS_EXCEPTION_CODE',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'RECEIPT_DAYS_EXCEPTION_CODE',
                                            x_receipt_days_exception_code,
                                            null,null,null,null,
                                            x_header_processable_flag);
         END IF;

         x_progress := '280';
      	 IF (x_need_by_date is not null) THEN -- Bug 3320741

            po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'NEED_BY_DATE',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'NEED_BY_DATE',
                                            x_need_by_date,
                                            null,null,null,null,
                                            x_header_processable_flag);
         END IF;

         x_progress := '290';
         IF (x_promised_date is not null) THEN -- Bug 3320741

            po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'PROMISED_DATE',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'PROMISED_DATE',
                                            x_promised_date,
                                            null,null,null,null,
                                            x_header_processable_flag);
         END IF;

         x_progress := '360';
         IF (x_invoice_close_tolerance is not null) AND
            (x_create_or_update_item_flag <> 'Y')
         THEN
            po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'INVOICE_CLOSE_TOLERANCE',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'INVOICE_CLOSE_TOLERANCE',
                                            x_invoice_close_tolerance,
                                            null,null,null,null,
                                            x_header_processable_flag);
         END IF;

         x_progress := '370';
         IF (x_receive_close_tolerance is not null)  AND
         (x_create_or_update_item_flag <> 'Y')
         THEN
            po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'RECEIVE_CLOSE_TOLERANCE',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'RECEIVE_CLOSE_TOLERANCE',
                                            x_receive_close_tolerance,
                                            null,null,null,null,
                                            x_header_processable_flag);
         END IF;

         x_progress := '390';
         IF (x_days_early_receipt_allowed is not null) AND
	    (x_create_or_update_item_flag <> 'Y')
         THEN
            po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'DAYS_EARLY_RECEIPT_ALLOWED',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'DAYS_EARLY_RECEIPT_ALLOWED',
                                            x_days_early_receipt_allowed,
                                            null,null,null,null,
                                            x_header_processable_flag);
         END IF;

         x_progress := '400';
         IF (x_days_late_receipt_allowed is not null) AND
	    (x_create_or_update_item_flag <> 'Y')
         THEN
            po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'DAYS_LATE_RECEIPT_ALLOWED',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'DAYS_LATE_RECEIPT_ALLOWED',
                                            x_days_late_receipt_allowed,
                                            null,null,null,null,
                                            x_header_processable_flag);
         END IF;

         x_progress := '410';
         IF (x_enforce_ship_to_loc_code is not null) AND
            (x_create_or_update_item_flag <> 'Y')
         THEN
            po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'ENFORCE_SHIP_TO_LOCATION_CODE',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'ENFORCE_SHIP_TO_LOCATION_CODE',
                                            x_enforce_ship_to_loc_code,
                                            null,null,null,null,
                                            x_header_processable_flag);
         END IF;

         x_progress := '420';
         IF (x_allow_sub_receipts_flag is not null) AND
            (x_create_or_update_item_flag <> 'Y')
         THEN
            po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'ALLOW_SUBSTITUTE_RECEIPTS_FLAG',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'ALLOW_SUBSTITUTE_RECEIPTS_FLAG',
                                            x_allow_sub_receipts_flag,
                                            null,null,null,null,
                                            x_header_processable_flag);
         END IF;

         x_progress := '430';
         IF (x_receiving_routing is not null) AND
            (x_create_or_update_item_flag <> 'Y')
         THEN
            po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'RECEIVING_ROUTING',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'RECEIVING_ROUTING',
                                            x_receiving_routing,
                                            null,null,null,null,
                                            x_header_processable_flag);
         END IF;

      END IF; --lookup in blanket, quote
       -- BUG 588911
       -- Remove the check to see if lead time is NULL
/*
      x_progress := '300';
      IF (x_lead_time is not null) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'LEAD_TIME',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'LEAD_TIME',
                                            x_lead_time,
                                            null,null,null,null,
                                            x_header_processable_flag);
      END IF;
*/
      x_progress := '310';

      x_progress := '330';
      IF (x_closed_reason is not null) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'CLOSED_REASON',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'CLOSED_REASON',
                                            x_closed_reason,
                                            null,null,null,null,
                                            x_header_processable_flag);
      END IF;

      x_progress := '340';
      IF (x_closed_date is not null) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'CLOSED_DATE',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'CLOSED_DATE',
                                            x_closed_date,
                                            null,null,null,null,
                                            x_header_processable_flag);
      END IF;

      x_progress := '350';
      IF (x_closed_by is not null) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'CLOSED_BY',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'CLOSED_BY',
                                            x_closed_by,
                                            null,null,null,null,
                                            x_header_processable_flag);
      END IF;


      x_progress := '380';
      IF (x_firm_flag is not null) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_COLUMN_NULL',
                                           'PO_LINES_INTERFACE',
                                           'FIRM_FLAG',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'FIRM_FLAG',
                                            x_firm_flag,
                                            null,null,null,null,
                                            x_header_processable_flag);
      END IF;

      X_progress := '445';
      /* validate item related attibutes with line_type */
      IF (X_line_type_id is not NULL) THEN
          po_lines_sv7.validate_item_with_line_type(
                                   X_interface_header_id,
                                   X_interface_line_id,
                                   X_line_type_id,
                                   X_category_id,
                                   X_unit_meas_lookup_code,
                                   X_unit_price,
                                   X_item_id,
				   X_item_description,
                                   X_item_revision,
                                   X_def_inv_org_id,
				   X_create_or_update_item_flag,
                                   X_header_processable_flag,
                                   X_global_agreement_flag,  -- FPI GA
                                   x_hd_type_lookup_code);   -- Bug 3362369

      END IF;

      x_progress := '450';
      IF ((x_quantity < 0) AND (x_quantity is not null)
         AND (p_order_type_lookup_code NOT IN ('RATE', 'FIXED PRICE'))) THEN --<SERVICES FPJ>
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_LT_ZERO',
                                           'PO_LINES_INTERFACE',
                                           'QUANTITY',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'QUANTITY',
                                            x_quantity,
                                            null,null,null,null,
                                            x_header_processable_flag);
      END IF;

   /* check to see if the line num is unique */
   x_progress := '460';
   IF (x_line_num is not null) AND (x_po_header_id is not null) THEN
      x_valid := po_lines_sv1.val_line_num_uniqueness(x_line_num,
                                                      null,
                                                      x_po_header_id);
      IF (x_valid = FALSE) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_LINE_NUM_UNIQUE',
                                           'PO_LINES_INTERFACE',
                                           'LINE_NUM',
                                           'VALUE',
                                            null,null,null,null,null,
                                            x_line_num,
                                            null,null,null,null,null,
                                            x_header_processable_flag);
      END IF;

      x_progress := '470';
      IF (x_line_num <= 0) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_LT_ZERO',
                                           'PO_LINES_INTERFACE',
                                           'LINE_NUM',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'LINE_NUM',
                                            x_line_num,
                                            null,null,null,null,
                                            x_header_processable_flag);
      END IF;
   END IF; /* x_line_num is not null */

   x_progress := '480';
   IF (x_po_line_id is not null) AND (x_po_header_id is not null) THEN
      x_valid := po_lines_sv1.val_line_id_uniqueness(x_po_line_id,
                                                     null,
                                                     x_po_header_id);
      IF (x_valid = FALSE) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_LINE_ID_UNIQUE',
                                           'PO_LINES_INTERFACE',
                                           'PO_LINE_ID',
                                           'VALUE',
                                            null,null,null,null,null,
                                            x_po_line_id,
                                            null,null,null,null,null,
                                            x_header_processable_flag);
      END IF;
   END IF;

   x_progress := '490';
   IF (x_line_type_id is not null) THEN
      x_valid := po_line_types_sv1.val_line_type_id(x_line_type_id);
      IF (x_valid = FALSE) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_INVALID_LINE_TYPE_ID',
                                           'PO_LINES_INTERFACE',
                                           'LINE_TYPE_ID',
                                           'VALUE',
                                            null,null,null,null,null,
                                            x_line_type_id,
                                            null,null,null,null,null,
                                            x_header_processable_flag);
      END IF;
   END IF;

--frkhan add standard
   IF (x_hd_type_lookup_code in ('BLANKET','STANDARD')) THEN
      x_progress := '550';
      IF (x_committed_amount < 0) AND (x_committed_amount is not null) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_LT_ZERO',
                                           'PO_LINES_INTERFACE',
                                           'COMMITTED_AMOUNT',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                          'COMMITTED_AMOUNT',
                                            x_committed_amount,
                                            null,null,null,null,
                                            x_header_processable_flag);
      END IF;

      x_progress := '560';
      IF (x_market_price < 0) AND (x_market_price is not null) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_LT_ZERO',
                                           'PO_LINES_INTERFACE',
                                           'MARKET_PRICE',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'MARKET_PRICE',
                                            x_market_price,
                                            null,null,null,null,
                                            x_header_processable_flag);
      END IF;

      x_progress := '570';
      IF (x_negotiated_by_preparer_flag is not null) THEN
         x_valid := po_core_sv1.val_flag_value(
                                           x_negotiated_by_preparer_flag);
         IF (x_valid = FALSE) THEN
           po_interface_errors_sv1.handle_interface_errors(
                                             'PO_DOCS_OPEN_INTERFACE',
                                             'FATAL',
                                              null,
                                              x_interface_header_id,
                                              x_interface_line_id,
                                             'PO_PDOI_INVALID_FLAG_VALUE',
                                             'PO_LINES_INTERFACE',
                                             'NEGOTIATED_BY_PREPARER_FLAG',
                                             'COLUMN_NAME',
                                             'VALUE',
                                              null,null,null,null,
                                             'NEGOTIATED_BY_PREPARER_FLAG',
                                              x_negotiated_by_preparer_flag,
                                              null,null,null,null,
                                              x_header_processable_flag);
        END IF;
      END IF;

      x_progress := '580';
      IF (x_capital_expense_flag is not null) THEN
         x_valid := po_core_sv1.val_flag_value(x_capital_expense_flag);
         IF (x_valid = FALSE) THEN
            po_interface_errors_sv1.handle_interface_errors(
                                     'PO_DOCS_OPEN_INTERFACE',
                                     'FATAL',
                                      null,
                                      x_interface_header_id,
                                      x_interface_line_id,
                                     'PO_PDOI_INVALID_FLAG_VALUE',
                                     'PO_LINES_INTERFACE',
                                     'CAPITAL_EXPENSE_FLAG',
                                     'COLUMN_NAME',
                                     'VALUE',
                                      null,null,null,null,
                                     'CAPITAL_EXPENSE_FLAG',
                                      x_capital_expense_flag,
                                      null,null,null,null,
                                      x_header_processable_flag);
         END IF;
      END IF;

      X_progress := '600';
      IF (x_allow_price_override_flag = 'N') THEN
         IF (x_not_to_exceed_price IS NOT NULL) THEN
           po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_EXCEED_PRICE_NULL',
                                           'PO_LINES_INTERFACE',
                                           'NOT_TO_EXCEED_PRICE',
                                           'VALUE',
                                            null,null,null,null,null,
                                            x_not_to_exceed_price,
                                            null,null,null,null,null,
                                            x_header_processable_flag);
         END IF;
      END IF;

      X_progress := '610';
      IF (x_not_to_exceed_price IS NOT NULL) THEN
         IF (x_not_to_exceed_price < x_unit_price) THEN
           po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_INVALID_PRICE',
                                           'PO_LINES_INTERFACE',
                                           'NOT_TO_EXCEED_PRICE',
                                           'VALUE',
                                           'UNIT_PRICE',
                                            null,null,null,null,
                                            x_not_to_exceed_price,
                                            x_unit_price,
                                            null,null,null,null,
                                            x_header_processable_flag);
         END IF;
      END IF;
   END IF; --blanket,standard
--FRKHAN
   IF (x_hd_type_lookup_code = 'STANDARD') THEN
	x_progress := '620';
      IF (x_quantity = 0) AND (x_quantity is not null) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_ZERO_QTY',
                                           'PO_LINES_INTERFACE',
                                           'QUANTITY',
                                            null,null,null,null,null,null,
                                            null,null,null,null,null,null,
                                            x_header_processable_flag);
      END IF;

/* Bug# 1934962
   Removed the validation on need_by_date and promised_date to make
   it consistent with the Enter PO form */

/*
	x_progress := '630';
      IF (x_need_by_date < trunc(sysdate)) AND (x_need_by_date is not null) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_NEED_BY_DATE',
                                           'PO_LINES_INTERFACE',
                                           'NEED_BY_DATE',
                                           'NEED_BY_DATE',
                                           null,null,null,null,null,
                                            x_Need_by_date,
                                            null,null,null,null,null,
                                            x_header_processable_flag);
      END IF;

	x_progress := '630';
      IF (x_promised_date < trunc(sysdate)) AND (x_promised_date is not null) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_PROMISED_DATE',
                                           'PO_LINES_INTERFACE',
                                           'PROMISED_DATE',
                                           'PROMISED_DATE',
                                            null,null,null,null,null,
                                            x_promised_date,
                                            null,null,null,null,null,
                                            x_header_processable_flag);
      END IF;
*/

   END IF; --standard

   /*** The following are validation rules for both blanket and quote ***/
   X_progress := '615';

--Bug 1881762:Changing the '<>' to 'is not' in the following IF condiditon

   if (NVL(x_taxable_flag, 'NULL') = 'N' and x_tax_name is not null and
       x_tax_code_id is not null) then

            po_interface_errors_sv1.handle_interface_errors(
                                              'PO_DOCS_OPEN_INTERFACE',
                                              'FATAL',
                                               null,
                                               x_interface_header_id,
                                               x_interface_line_id,
                                              'PO_PDOI_INVALID_TAXABLE_FLAG',
                                              'PO_LINES_INTERFACE',
                                              'TAXABLE_FLAG',
                                              'VALUE',
                                               null,null,null,null,null,
                                               x_taxable_flag,
                                               null,null,null,null,null,
                                               x_header_processable_flag);
   end if;

   -- IF (x_tax_name is not null or x_tax_code_id is not null) THEN
   -- x_valid := po_ap_tax_codes_sv.val_tax_name(x_tax_name);
   -- IF (x_valid = FALSE) THEN

   if (x_tax_name is not null and x_tax_code_id is null) then

	    -- something went wrong
            po_interface_errors_sv1.handle_interface_errors(
                                              'PO_DOCS_OPEN_INTERFACE',
                                              'FATAL',
                                               null,
                                               x_interface_header_id,
                                               x_interface_line_id,
                                              'PO_PDOI_INVALID_TAX_NAME',
                                              'PO_LINES_INTERFACE',
                                              'TAX_NAME',
                                              'VALUE',
                                               null,null,null,null,null,
                                               x_tax_name,
                                               null,null,null,null,null,
                                               x_header_processable_flag);

   elsif (x_tax_name is null and x_tax_code_id is not null) then

	    -- something went wrong
            po_interface_errors_sv1.handle_interface_errors(
                                              'PO_DOCS_OPEN_INTERFACE',
                                              'FATAL',
                                               null,
                                               x_interface_header_id,
                                               x_interface_line_id,
                                              'PO_PDOI_INVALID_TAX_CODE_ID',
                                              'PO_LINES_INTERFACE',
                                              'TAX_CODE_ID',
                                              'VALUE',
                                               null,null,null,null,null,
                                               x_tax_code_id,
                                               null,null,null,null,null,
                                               x_header_processable_flag);

   elsif (x_tax_name is not null and x_tax_code_id is not null) then

		-- validate tax id

		select count(*) into x_count
		from ap_tax_codes
		where tax_id = x_tax_code_id
		and enabled_flag = 'Y';

		if x_count = 0 then

			-- invalid tax id

            		po_interface_errors_sv1.handle_interface_errors(
                                              'PO_DOCS_OPEN_INTERFACE',
                                              'FATAL',
                                               null,
                                               x_interface_header_id,
                                               x_interface_line_id,
                                              'PO_PDOI_INVALID_TAX_CODE_ID',
                                              'PO_LINES_INTERFACE',
                                              'TAX_NAME',
                                              'VALUE',
                                               null,null,null,null,null,
                                               x_tax_name,
                                               null,null,null,null,null,
                                               x_header_processable_flag);
		end if;


   end if;

   X_progress := '620';
   IF (x_terms_id is not null) THEN
      po_terms_sv.val_ap_terms(x_terms_id, x_res_terms_id);
      IF (x_res_terms_id is null) THEN
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

   x_progress := '630';
   IF (x_un_number_id is not null) THEN
      x_valid := po_un_numbers_sv1.val_un_number_id(x_un_number_id);
     IF (x_valid = FALSE) THEN
        po_interface_errors_sv1.handle_interface_errors(
                                          'PO_DOCS_OPEN_INTERFACE',
                                          'FATAL',
                                           null,
                                           x_interface_header_id,
                                           x_interface_line_id,
                                          'PO_PDOI_INVALID_UN_NUMBER_ID',
                                          'PO_LINES_INTERFACE',
                                          'UN_NUMBER_ID',
                                          'VALUE',
                                           null,null,null,null,null,
                                           x_un_number_id,
                                           null,null,null,null,null,
                                           x_header_processable_flag);
     END IF;
   END IF;

   x_progress := '640';
   IF (x_hazard_class_id is not null) THEN
      x_valid := po_hazard_classes_sv1.val_hazard_class_id(
                                                       x_hazard_class_id);
      IF (x_valid = FALSE) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                          'PO_DOCS_OPEN_INTERFACE',
                                          'FATAL',
                                           null,
                                           x_interface_header_id,
                                           x_interface_line_id,
                                          'PO_PDOI_INVALID_HAZ_ID',
                                          'PO_LINES_INTERFACE',
                                          'HAZARD_CLASS_ID',
                                          'VALUE',
                                           null,null,null,null,null,
                                           x_hazard_class_id,
                                           null,null,null,null,null,
                                           x_header_processable_flag);
      END IF;
   END IF;

   x_progress := '650';

/*
   IF (x_taxable_flag is not null) THEN
      x_valid := po_core_sv1.val_flag_value(x_taxable_flag);
      IF (x_valid = FALSE) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_INVALID_FLAG_VALUE',
                                           'PO_LINES_INTERFACE',
                                           'TAXABLE_FLAG',
                                           'COLUMN_NAME',
                                           'VALUE',
                                            null,null,null,null,
                                           'TAXABLE_FLAG',
                                            x_taxable_flag,
                                            null,null,null,null,
                                            x_header_processable_flag);
      END IF;
   END IF;
*/
   x_progress := '660';
   IF (x_price_type_lookup_code is not null) THEN
      x_valid :=po_headers_sv6.val_lookup_code(x_price_type_lookup_code,
                                               'PRICE TYPE');
      IF (x_valid = FALSE) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_INVALID_PRICE_TYPE',
                                           'PO_LINES_INTERFACE',
                                           'PRICE_TYPE_LOOKUP_CODE',
                                           'VALUE',
                                            null,null,null,null,null,
                                            x_price_type_lookup_code,
                                            null,null,null,null,null,
                                            x_header_processable_flag);
      END IF;
   END IF;

   x_progress := '670';
   IF (x_price_break_lookup_code is not null) THEN
      x_valid :=po_headers_sv6.val_lookup_code(x_price_break_lookup_code,
                                               'PRICE BREAK TYPE');
      IF (x_valid = FALSE) THEN
         po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_INVALID_PRICE_BREAK',
                                           'PO_LINES_INTERFACE',
                                           'PRICE_BREAK_LOOKUP_CODE',
                                           'VALUE',
                                            null,null,null,null,null,
                                            x_price_break_lookup_code,
                                            null,null,null,null,null,
                                            x_header_processable_flag);
      END IF;

    /* FPI GA start*/
    /* For a global agreement cumulative price break lines are not allowed */
      IF x_price_break_lookup_code = 'CUMULATIVE' THEN
         IF nvl(X_global_agreement_flag,'N') = 'Y' THEN
           po_interface_errors_sv1.handle_interface_errors(
                                           'PO_DOCS_OPEN_INTERFACE',
                                           'FATAL',
                                            null,
                                            x_interface_header_id,
                                            x_interface_line_id,
                                           'PO_PDOI_GA_PRICE_BREAK_NA',
                                           'PO_LINES_INTERFACE',
                                           null,
                                           null,
                                            null,null,null,null,null,
                                            x_price_break_lookup_code,
                                            null,null,null,null,null,
                                            x_header_processable_flag);
         --<SERVICES FPJ START>
         ELSIF (p_order_type_lookup_code = 'FIXED PRICE'
                AND p_purchase_basis = 'SERVICES') THEN

            --You cannot have cumulative price breaks on
            --FIXED PRICE/SERVICES line types.
    	    PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
               X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
               X_Error_type              => 'FATAL',
               X_Batch_id                => NULL,
               X_Interface_Header_Id     => x_interface_header_id,
               X_Interface_Line_id       => x_interface_line_id,
               X_Error_message_name      => 'PO_PDOI_SVC_NO_CUMULATIVE_PB',
               X_Table_name              => 'PO_LINES_INTERFACE',
               X_Column_name             => 'PRICE_BREAK_LOOKUP_CODE',
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
         END IF; --IF nvl(X_global_agreement_flag,'N') = 'Y'
         --<SERVICES FPJ END>

      END IF; --IF x_price_break_lookup_code = 'CUMULATIVE'
     /* FPI GA end */

   END IF;

EXCEPTION
   WHEN others THEN
        po_message_s.sql_error('validate_po_lines', x_progress, sqlcode);
        raise;
END validate_po_lines;

END PO_LINES_SV7;

/
