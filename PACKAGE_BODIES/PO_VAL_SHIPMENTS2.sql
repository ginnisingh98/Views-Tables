--------------------------------------------------------
--  DDL for Package Body PO_VAL_SHIPMENTS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_VAL_SHIPMENTS2" AS
  -- $Header: PO_VAL_SHIPMENTS2.plb 120.17.12010000.5 2013/10/25 11:32:38 inagdeo ship $
  c_entity_type_line_location CONSTANT VARCHAR2(30) := PO_VALIDATIONS.c_entity_type_LINE_LOCATION;
  -- The module base for this package.
  d_package_base CONSTANT VARCHAR2(50) := po_log.get_package_base('PO_VAL_SHIPMENTS2');

  -- The module base for the subprogram.
  d_need_by_date CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'NEED_BY_DATE');
  d_promised_date CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'PROMISED_DATE');
  d_shipment_type CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'SHIPMENT_TYPE');
  d_payment_type CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'PAYMENT_TYPE');  -- PDOI for Complex PO Project
  d_shipment_num CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'SHIPMENT_NUM');
  d_quantity CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'QUANTITY');
  d_amount CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'AMOUNT');  -- PDOI for Complex PO Project
  d_price_override CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'PRICE_OVERRIDE');
  d_price_discount CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'PRICE_DISCOUNT');
  d_ship_to_organization_id CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'SHIP_TO_ORGANIZATION_ID');
  d_price_break_attributes CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'PRICE_BREAK_ATTRIBUTES');
  d_effective_dates CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'EFFECTIVE_DATES');
  d_qty_rcv_exception_code CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'QTY_RCV_EXCEPTION_CODE');
  d_enforce_ship_to_loc_code CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'ENFORCE_SHIP_TO_LOC_CODE');
  d_allow_sub_receipts_flag CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'ALLOW_SUB_RECEIPTS_FLAG');
  d_days_early_receipt_allowed CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'DAYS_EARLY_RECEIPT_ALLOWD');
  d_receipt_days_exception_code CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'RECEIPT_DAYS_EXCEPTION_CODE');
  d_invoice_close_tolerance CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'INVOICE_CLOSE_TOLERANCE');
  d_receive_close_tolerance CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'RECEIVE_CLOSE_TOLERANCE');
  d_receiving_routing_id CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'RECEIVING_ROUTING_ID');
  d_accrue_on_receipt_flag CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'ACCRUE_ON_RECEIPT_FLAG');
  d_advance_amt_le_amt CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'ADVANCE_AMT_LE_AMT');  -- PDOI for Complex PO Project
  d_fob_lookup_code CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'FOB_LOOKUP_CODE');
  d_freight_terms CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'FREIGHT_TERMS');
  d_freight_carrier CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'FREIGHT_CARRIER');
  d_style_related_info CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'STYLE_RELATED_INFO');
  d_tax_name CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'TAX_NAME');
  d_price_break CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'PRICE_BREAK');

  -- <PDOI Enhancement Bug#17063664 Start>
  d_inspection_reqd_flag CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'INSPECTION_REQD_FLAG');
  d_days_late_rcpt_allowed CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'DAYS_LATE_RCPT_ALLOWED');
  -- <PDOI Enhancement Bug#17063664 End>

  -- Indicates that the calling program is PDOI.
  c_program_pdoi CONSTANT VARCHAR2(10) := 'PDOI';
  -- The application name of PO.
  c_po CONSTANT VARCHAR2(2) := 'PO';

-------------------------------------------------------------------------
-- if purchase_basis is 'TEMP LABOR', the need_by_date column must be null
-------------------------------------------------------------------------
  PROCEDURE need_by_date(
    p_id_tbl               IN              po_tbl_number,
    p_purchase_basis_tbl   IN              po_tbl_varchar30,
    p_need_by_date_tbl     IN              po_tbl_date,
    x_results              IN OUT NOCOPY   po_validation_results_type,
    x_result_type          OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_need_by_date;
  BEGIN
    IF (x_results IS NULL) THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_purchase_basis_tbl', p_purchase_basis_tbl);
      po_log.proc_begin(d_mod, 'p_need_by_date_tbl', p_need_by_date_tbl);
      po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
    END IF;

    -- if purchase_basis is 'TEMP LABOR', the need_by_date column must be null
    FOR i IN 1 .. p_id_tbl.COUNT LOOP
      IF p_purchase_basis_tbl(i) = 'TEMP LABOR' AND p_need_by_date_tbl(i) IS NOT NULL THEN
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'NEED_BY_DATE',
                             p_column_val       => p_need_by_date_tbl(i),
                             p_message_name     => 'PO_SVC_NO_NEED_PROMISE_DATE',
							 p_validation_id    => PO_VAL_CONSTANTS.c_loc_need_by_date);
        x_result_type := po_validations.c_result_type_failure;
      END IF;
    END LOOP;

    IF po_log.d_proc THEN
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END need_by_date;

-------------------------------------------------------------------------
-- if purchase_basis is 'TEMP LABOR', the promised_date must be null
-------------------------------------------------------------------------
  PROCEDURE promised_date(
    p_id_tbl               IN              po_tbl_number,
    p_purchase_basis_tbl   IN              po_tbl_varchar30,
    p_promised_date_tbl    IN              po_tbl_date,
    x_results              IN OUT NOCOPY   po_validation_results_type,
    x_result_type          OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_promised_date;
  BEGIN
    IF (x_results IS NULL) THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_purchase_basis_tbl', p_purchase_basis_tbl);
      po_log.proc_begin(d_mod, 'p_promised_date_tbl', p_promised_date_tbl);
      po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
    END IF;

    -- if purchase_basis is 'TEMP LABOR', the need_by_date column must be null
    FOR i IN 1 .. p_id_tbl.COUNT LOOP
      IF p_purchase_basis_tbl(i) = 'TEMP LABOR' AND p_promised_date_tbl(i) IS NOT NULL THEN
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'PROMISE_DATE',
                             p_column_val       => p_promised_date_tbl(i),
                             p_message_name     => 'PO_SVC_NO_NEED_PROMISE_DATE',
							 p_validation_id    => PO_VAL_CONSTANTS.c_loc_promised_date);
        x_result_type := po_validations.c_result_type_failure;
      END IF;
    END LOOP;

    IF po_log.d_proc THEN
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END promised_date;

-------------------------------------------------------------------------
-- validate shipment type
-------------------------------------------------------------------------
  PROCEDURE shipment_type(
    p_id_tbl              IN              po_tbl_number,
    p_shipment_type_tbl   IN              po_tbl_varchar30,
    p_style_id_tbl        IN              po_tbl_number, -- PDOI for Complex PO Project
    p_doc_type            IN              VARCHAR2,
    x_results             IN OUT NOCOPY   po_validation_results_type,
    x_result_type         OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_shipment_type;
    l_is_complex_work_style BOOLEAN;  -- PDOI for Complex PO Project
  BEGIN
    IF (x_results IS NULL) THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_shipment_type_tbl', p_shipment_type_tbl);
      po_log.proc_begin(d_mod, 'p_style_id_tbl', p_style_id_tbl);  -- PDOI for Complex PO Project
      po_log.proc_begin(d_mod, 'p_doc_type', p_doc_type);
      po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
    END IF;

    -- if shipment_type is Null
    FOR i IN 1 .. p_id_tbl.COUNT LOOP
    /* PDOI for Complex PO Project: Allow Other Shipment Types for Complex PO -- START */
      l_is_complex_work_style := FALSE;

      l_is_complex_work_style := PO_COMPLEX_WORK_PVT.is_complex_work_style(p_style_id => p_style_id_tbl(i));
      /* PDOI for Complex PO Project: Allow Other Shipment Types for Complex PO -- END */
      IF p_shipment_type_tbl(i) IS NULL THEN
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'SHIPMENT_TYPE',
                             p_column_val       => p_shipment_type_tbl(i),
                             p_message_name     => 'PO_PDOI_COLUMN_NOT_NULL',
							 p_validation_id    => PO_VAL_CONSTANTS.c_shipment_type_not_null);
        x_result_type := po_validations.c_result_type_failure;
      ELSIF    (p_doc_type = 'QUOTATION' AND p_shipment_type_tbl(i) <> 'QUOTATION')
            OR (p_doc_type = 'BLANKET' AND p_shipment_type_tbl(i) <> 'PRICE BREAK')
            OR (p_doc_type = 'STANDARD' AND l_is_complex_work_style = FALSE AND p_shipment_type_tbl(i) <> 'STANDARD') THEN
            /* PDOI for Complex PO Project: Allow Other Shipment Types for Complex PO */
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'SHIPMENT_TYPE',
                             p_column_val       => p_shipment_type_tbl(i),
                             p_message_name     => 'PO_PDOI_INVALID_SHIPMENT_TYPE',
							 p_validation_id    => PO_VAL_CONSTANTS.c_shipment_type_valid);
        x_result_type := po_validations.c_result_type_failure;
      END IF;
    END LOOP;

    IF po_log.d_proc THEN
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END shipment_type;

  -------------------------------------------------------------------------
-- PDOI for Complex PO Project: Validate payment type.
-------------------------------------------------------------------------
  PROCEDURE payment_type(
    p_id_tbl              IN              po_tbl_number,
    po_line_id_tbl        IN              po_tbl_number,
    p_style_id_tbl        IN              po_tbl_number,
    p_payment_type_tbl    IN              po_tbl_varchar30,
    p_shipment_type_tbl   IN              po_tbl_varchar30,
    x_results             IN OUT NOCOPY   po_validation_results_type,
    x_result_type         OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_payment_type;
    l_line_id NUMBER;
    l_line_location_id NUMBER;
    l_previous_style_id NUMBER := 1;
    l_financing_exists BOOLEAN := FALSE;
    l_payitem_exists   BOOLEAN := FALSE;
    l_complex_work_flag        VARCHAR2(1) := 'N';
    l_financing_payments_flag  VARCHAR2(1) := 'N';
    l_retainage_allowed_flag   VARCHAR2(1) := 'N';
    l_advance_allowed_flag     VARCHAR2(1) := 'N';
    l_milestone_allowed_flag   VARCHAR2(1) := 'N';
    l_lumpsum_allowed_flag     VARCHAR2(1) := 'N';
    l_rate_allowed_flag        VARCHAR2(1) := 'N';
  BEGIN
    IF (x_results IS NULL) THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'po_line_id_tbl', po_line_id_tbl);
      po_log.proc_begin(d_mod, 'p_style_id_tbl', p_style_id_tbl);
      po_log.proc_begin(d_mod, 'p_payment_type_tbl', p_payment_type_tbl);
      po_log.proc_begin(d_mod, 'p_shipment_type_tbl', p_shipment_type_tbl);
      po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
    END IF;

    FOR i IN 1 .. p_id_tbl.COUNT LOOP

      IF l_previous_style_id <> Nvl(p_style_id_tbl(i),1) THEN
        l_previous_style_id := p_style_id_tbl(i);
        PO_COMPLEX_WORK_PVT.get_payment_style_settings(
          p_style_id                => Nvl(p_style_id_tbl(i),1)
        , x_complex_work_flag       => l_complex_work_flag
        , x_financing_payments_flag => l_financing_payments_flag
        , x_retainage_allowed_flag  => l_retainage_allowed_flag
        , x_advance_allowed_flag    => l_advance_allowed_flag
        , x_milestone_allowed_flag  => l_milestone_allowed_flag
        , x_lumpsum_allowed_flag    => l_lumpsum_allowed_flag
        , x_rate_allowed_flag       => l_rate_allowed_flag
        );
      END IF;

      IF (l_advance_allowed_flag = 'N' AND Nvl(p_payment_type_tbl(i),'MILESTONE') = 'ADVANCE') THEN
      -- If Advance is not allowed for the style, ADVANCE shipment is not allowed.
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'PAYMENT_TYPE',
                             p_column_val       => p_payment_type_tbl(i),
                             p_message_name     => 'PO_PDOI_ADVANCE_NOT_ALLOWED',
                             p_token1_name      => 'STYLE_ID',
                             p_token1_value     => p_style_id_tbl(i),
			                       p_validation_id    => PO_VAL_CONSTANTS.c_loc_payment_type);
        x_result_type := po_validations.c_result_type_failure;
      ELSIF (l_financing_payments_flag = 'N' AND Nvl(p_payment_type_tbl(i),'MILESTONE') = 'DELIVERY') THEN
      -- If Financing is not allowed for the style, DELIVERY shipment is not allowed.
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'PAYMENT_TYPE',
                             p_column_val       => p_payment_type_tbl(i),
                             p_message_name     => 'PO_PDOI_DELIVERY_NOT_ALLOWED',
                             p_token1_name      => 'STYLE_ID',
                             p_token1_value     => p_style_id_tbl(i),
			                       p_validation_id    => PO_VAL_CONSTANTS.c_loc_payment_type);
        x_result_type := po_validations.c_result_type_failure;
     ELSIF (l_complex_work_flag = 'Y' AND
            ((Nvl(p_payment_type_tbl(i),'MILESTONE') = 'ADVANCE' AND Nvl(p_shipment_type_tbl(i),'STANDARD') <> 'PREPAYMENT') OR
             (Nvl(p_payment_type_tbl(i),'MILESTONE') = 'DELIVERY' AND Nvl(p_shipment_type_tbl(i),'PREPAYMENT') <> 'STANDARD'))) THEN
      -- For a Complex PO shipment, if Payment type is ADVANCE, then Shipment type should be PREPAYMENT.
      -- For a Complex PO shipment, if Payment type is DELIVERY, then Shipment type should be STANDARD.
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'SHIPMENT_TYPE',
                             p_column_val       => p_shipment_type_tbl(i),
                             p_message_name     => 'PO_PDOI_INVALID_SHIPMENT_TYPE',
                             p_token1_name      => 'TYPE',
                             p_token1_value     => p_shipment_type_tbl(i),
                             p_token2_name      => 'VALUE',
                             p_token2_value     => p_payment_type_tbl(i),
			                       p_validation_id    => PO_VAL_CONSTANTS.c_shipment_type_valid);
        x_result_type := po_validations.c_result_type_failure;
      ELSIF (l_complex_work_flag = 'Y' AND (p_payment_type_tbl(i) IS NULL OR
                                            p_payment_type_tbl(i) NOT IN ('ADVANCE','DELIVERY','MILESTONE','LUMPSUM','RATE'))) THEN
      -- For a Complex PO shipment, Payment type should not be NULL.
      -- For a Complex PO shipment, Payment type should be one of ADVANCE, DELIVERY, MILESTONE, LUMPSUM and RATE.
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'PAYMENT_TYPE',
                             p_column_val       =>  p_payment_type_tbl(i),
                             p_message_name     => 'PO_PDOI_INVALID_PAYMENT_TYPE',
                             p_token1_name      => 'STYLE_ID',
                             p_token1_value     => p_style_id_tbl(i),
			                       p_validation_id    => PO_VAL_CONSTANTS.c_loc_payment_type);
        x_result_type := po_validations.c_result_type_failure;
      END IF;

      IF l_complex_work_flag = 'Y' THEN
      -- If a PO Line belongs to complex style, there should be atleast one Pay item corresponding to that line.
        l_line_id := po_line_id_tbl(i);
        l_payitem_exists := FALSE;
        FOR i IN 1 .. p_id_tbl.COUNT LOOP
          IF (po_line_id_tbl(i) = l_line_id AND Nvl(p_payment_type_tbl(i),'MILESTONE') <> 'ADVANCE'
              AND ((l_financing_payments_flag = 'Y' AND Nvl(p_shipment_type_tbl(i),'STANDARD') = 'PREPAYMENT')
                    OR (l_financing_payments_flag = 'N' AND Nvl(p_shipment_type_tbl(i),'PREPAYMENT') = 'STANDARD'))) THEN
            l_payitem_exists := TRUE;
          END IF;
        END LOOP;

        IF NOT l_payitem_exists THEN
          x_results.add_result(p_entity_type      => c_entity_type_line_location,
                               p_entity_id        => p_id_tbl(i),
                               p_column_name      => 'PAYMENT_TYPE',
                               p_column_val       => p_payment_type_tbl(i),
                               p_message_name     => 'PO_PDOI_PAY_ITEM_NOT_PRESENT',
                               p_token1_name      => 'STYLE_ID',
                               p_token1_value     => p_style_id_tbl(i),
			                         p_validation_id    => PO_VAL_CONSTANTS.c_loc_payment_type);
          x_result_type := po_validations.c_result_type_failure;
        END IF;
      END IF;

      IF l_financing_payments_flag = 'Y' AND Nvl(p_payment_type_tbl(i),'MILESTONE') <> 'DELIVERY' THEN
      -- If Financing is allowed for the style, there should be one DELIVERY shipment for each PO line.
        l_line_id := po_line_id_tbl(i);
        l_financing_exists := FALSE;
        FOR i IN 1 .. p_id_tbl.COUNT LOOP
          IF (po_line_id_tbl(i) = l_line_id AND Nvl(p_payment_type_tbl(i),'MILESTONE') = 'DELIVERY') THEN
            l_financing_exists := TRUE;
          END IF;
        END LOOP;

        IF NOT l_financing_exists THEN
          x_results.add_result(p_entity_type      => c_entity_type_line_location,
                               p_entity_id        => p_id_tbl(i),
                               p_column_name      => 'PAYMENT_TYPE',
                               p_column_val       => p_payment_type_tbl(i),
                               p_message_name     => 'PO_PDOI_DELIVERY_NOT_PRESENT',
                               p_token1_name      => 'STYLE_ID',
                               p_token1_value     => p_style_id_tbl(i),
			                         p_validation_id    => PO_VAL_CONSTANTS.c_loc_payment_type);
          x_result_type := po_validations.c_result_type_failure;
        END IF;
      END IF;

      IF Nvl(p_payment_type_tbl(i),'MILESTONE') = 'DELIVERY' THEN
      -- For a Complex PO Line more than one DELIVERY shipment is not allowed.
        l_line_id := po_line_id_tbl(i);
        l_line_location_id := p_id_tbl(i);
        FOR i IN 1 .. p_id_tbl.COUNT LOOP
          IF (p_id_tbl(i) <> l_line_location_id AND po_line_id_tbl(i) = l_line_id
              AND Nvl(p_payment_type_tbl(i),'MILESTONE') = 'DELIVERY') THEN
            x_results.add_result(p_entity_type      => c_entity_type_line_location,
                                 p_entity_id        => p_id_tbl(i),
                                 p_column_name      => 'PAYMENT_TYPE',
                                 p_column_val       => p_payment_type_tbl(i),
                                 p_message_name     => 'PO_PDOI_DUP_DELIVERY_DISALLOW',
                                 p_token1_name      => 'STYLE_ID',
                                 p_token1_value     => p_style_id_tbl(i),
			                           p_validation_id    => PO_VAL_CONSTANTS.c_loc_payment_type);
            x_result_type := po_validations.c_result_type_failure;
          END IF;
        END LOOP;
      ELSIF Nvl(p_payment_type_tbl(i),'MILESTONE') = 'ADVANCE' THEN
      -- For a Complex PO Line more than one ADVANCE shipment is not allowed.
        l_line_id := po_line_id_tbl(i);
        l_line_location_id := p_id_tbl(i);
        FOR i IN 1 .. p_id_tbl.COUNT LOOP
          IF (p_id_tbl(i) <> l_line_location_id AND po_line_id_tbl(i) = l_line_id
              AND Nvl(p_payment_type_tbl(i),'MILESTONE') = 'ADVANCE') THEN
            x_results.add_result(p_entity_type      => c_entity_type_line_location,
                                 p_entity_id        => p_id_tbl(i),
                                 p_column_name      => 'PAYMENT_TYPE',
                                 p_column_val       => p_payment_type_tbl(i),
                                 p_message_name     => 'PO_PDOI_DUP_ADVANCE_DISALLOW',
                                 p_token1_name      => 'STYLE_ID',
                                 p_token1_value     => p_style_id_tbl(i),
			                           p_validation_id    => PO_VAL_CONSTANTS.c_loc_payment_type);
            x_result_type := po_validations.c_result_type_failure;
          END IF;
        END LOOP;
      END IF;

    END LOOP;

    IF po_log.d_proc THEN
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END payment_type;

-------------------------------------------------------------------------
-- validate shipment num is not null, greater than zero and unique
-------------------------------------------------------------------------
  PROCEDURE shipment_num(
    p_id_tbl              IN              po_tbl_number,
    p_shipment_num_tbl    IN              po_tbl_number,
    p_shipment_type_tbl   IN              po_tbl_varchar30,
    p_po_header_id_tbl    IN              po_tbl_number,
    p_po_line_id_tbl      IN              po_tbl_number,
    p_draft_id_tbl        IN              PO_TBL_NUMBER, -- bug 4642348
    p_style_id_tbl        IN              po_tbl_number, -- PDOI for Complex PO Project
    p_doc_type            IN              VARCHAR2,      -- bug 4642348
    x_result_set_id       IN OUT NOCOPY   NUMBER,
    x_results             IN OUT NOCOPY   po_validation_results_type,
    x_result_type         OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_shipment_num;
     l_is_complex_work_style BOOLEAN;  -- PDOI for Complex PO Project
  BEGIN
    IF x_result_set_id IS NULL THEN
      x_result_set_id := po_validations.next_result_set_id();
    END IF;

    IF (x_results IS NULL) THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_shipment_num_tbl', p_shipment_num_tbl);
      po_log.proc_begin(d_mod, 'p_shipment_type_tbl', p_shipment_type_tbl);
      po_log.proc_begin(d_mod, 'p_po_header_id_tbl', p_po_header_id_tbl);
      po_log.proc_begin(d_mod, 'p_po_line_id_tbl', p_po_line_id_tbl);
      po_log.proc_begin(d_mod, 'p_draft_id_tbl', p_draft_id_tbl);
      po_log.proc_begin(d_mod, 'p_style_id_tbl', p_style_id_tbl);  -- PDOI for Complex PO Project
      po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
      po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;

    x_result_type := po_validations.c_result_type_success;

    -- if shipment_type is Null
    FOR i IN 1 .. p_id_tbl.COUNT LOOP
     /* PDOI for Complex PO Project: Allow Shipment Num zero for Complex PO -- START */
      l_is_complex_work_style := FALSE;

      l_is_complex_work_style := PO_COMPLEX_WORK_PVT.is_complex_work_style(p_style_id => p_style_id_tbl(i));
      /* PDOI for Complex PO Project: Allow Shipment Num zero for Complex PO -- END */
      IF p_shipment_num_tbl(i) IS NULL THEN
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'SHIPMENT_NUM',
                             p_column_val       => p_shipment_num_tbl(i),
                             p_message_name     => 'PO_PDOI_COLUMN_NOT_NULL',
                             p_token1_name      => 'COLUMN_NAME',
                             p_token1_value     => 'SHIPMENT_NUM',
							 p_validation_id    => PO_VAL_CONSTANTS.c_shipment_num_not_null);
        x_result_type := po_validations.c_result_type_failure;
    /* PDOI for Complex PO Project: Allow Shipment Num zero for Complex PO */
      ELSIF ((l_is_complex_work_style = FALSE AND p_shipment_num_tbl(i) <= 0)
              OR (l_is_complex_work_style = TRUE AND p_shipment_num_tbl(i) < 0))THEN
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'SHIPMENT_NUM',
                             p_column_val       => p_shipment_num_tbl(i),
                             p_message_name     => 'PO_PDOI_LT_ZERO',
                             p_token1_name      => 'COLUMN_NAME',
                             p_token1_value     => 'SHIPMENT_NUM',
                             p_token2_name      => 'VALUE',
                             p_token2_value     => p_shipment_num_tbl(i),
							 p_validation_id    => PO_VAL_CONSTANTS.c_shipment_num_gt_zero);
        x_result_type := po_validations.c_result_type_failure;
      END IF;
    END LOOP;

    -- Validate shipment number is unique
    FORALL i IN 1 .. p_id_tbl.COUNT
      INSERT INTO po_validation_results_gt
                  (result_set_id,
                   result_type,
                   entity_type,
                   entity_id,
                   message_name,
                   column_name,
                   column_val,
                   token1_name,
                   token1_value,
	           validation_id)
        SELECT x_result_set_id,
               po_validations.c_result_type_failure,
               'PO_LINE_LOCATIONS_DRAFT_ALL',
               p_id_tbl(i),
               'PO_PDOI_SHIPMENT_NUM_UNIQUE',
               'SHIPMENT_NUM',
               p_shipment_num_tbl(i),
               'VALUE',
               p_shipment_num_tbl(i),
               PO_VAL_CONSTANTS.c_shipment_num_unique
          FROM DUAL
         WHERE p_shipment_num_tbl(i) IS NOT NULL AND
               p_po_header_id_tbl(i) IS NOT NULL AND
               p_po_line_id_tbl(i) IS NOT NULL AND
               p_shipment_type_tbl(i) IS NOT NULL AND
               (EXISTS(SELECT 1
                            FROM po_line_locations_all
                           WHERE po_header_id = p_po_header_id_tbl(i)
                             AND po_line_id = p_po_line_id_tbl(i)
                             AND shipment_num = p_shipment_num_tbl(i)
                             and p_doc_type = 'BLANKET' -- bug 4642348
                             AND shipment_type = 'PRICE BREAK') -- Bug#16501849
                OR EXISTS(SELECT 1
                          FROM po_line_locations_draft_all
                         WHERE po_header_id = p_po_header_id_tbl(i)
                           AND po_line_id = p_po_line_id_tbl(i)
                           AND draft_id = p_draft_id_tbl(i) -- bug 4642348
                           AND shipment_num = p_shipment_num_tbl(i)
                           AND NVL(delete_flag, 'N') = 'N')); -- bug 4642348


    IF (SQL%ROWCOUNT > 0) THEN
      x_result_type := po_validations.c_result_type_failure;
    END IF;

    IF po_log.d_proc THEN
      po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
      po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END shipment_num;

-------------------------------------------------------------------------
-- If order_type_lookup_code is RATE or FIXED PRICE, quantity must be null;
-- If order_type_lookup_code is not RATE or FIXED PRICE and quantity is
-- not null, quantity must be greater than or equal to zero.
-------------------------------------------------------------------------
  PROCEDURE quantity(
    p_id_tbl                       IN              po_tbl_number,
    p_quantity_tbl                 IN              po_tbl_number,
    p_order_type_lookup_code_tbl   IN              po_tbl_varchar30,
    p_shipment_type_tbl            IN              po_tbl_varchar30, -- PDOI for Complex PO Project
    p_style_id_tbl                 IN              po_tbl_number,    -- PDOI for Complex PO Project
    p_payment_type_tbl             IN              po_tbl_varchar30, -- PDOI for Complex PO Project
    p_line_quantity_tbl            IN              po_tbl_number,    -- PDOI for Complex PO Project
    x_results                      IN OUT NOCOPY   po_validation_results_type,
    x_result_type                  OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_quantity;
     l_is_financing_style BOOLEAN;  -- PDOI for Complex PO Project
  BEGIN
    IF (x_results IS NULL) THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_quantity_tbl', p_quantity_tbl);
      po_log.proc_begin(d_mod, 'p_order_type_lookup_code_tbl', p_order_type_lookup_code_tbl);
      po_log.proc_begin(d_mod, 'p_shipment_type_tbl', p_shipment_type_tbl); -- PDOI for Complex PO Project
      po_log.proc_begin(d_mod, 'p_style_id_tbl', p_style_id_tbl);           -- PDOI for Complex PO Project
      po_log.proc_begin(d_mod, 'p_payment_type_tbl', p_payment_type_tbl);   -- PDOI for Complex PO Project
      po_log.proc_begin(d_mod, 'p_line_quantity_tbl', p_line_quantity_tbl); -- PDOI for Complex PO Project
      po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
    END IF;


    -- If order_type_lookup_code is RATE or FIXED PRICE,
    -- validate quantity must be null
    FOR i IN 1 .. p_id_tbl.COUNT LOOP

    /* PDOI for Complex PO Project: START */
      l_is_financing_style := FALSE;
      l_is_financing_style := PO_COMPLEX_WORK_PVT.is_financing_payment_style(p_style_id => p_style_id_tbl(i));
      /* PDOI for Complex PO Project: END */

    IF (p_order_type_lookup_code_tbl(i) = 'RATE' OR p_order_type_lookup_code_tbl(i) = 'FIXED PRICE')
         AND Nvl(p_shipment_type_tbl(i),'STANDARD') <> 'PREPAYMENT' AND p_quantity_tbl(i) IS NOT NULL THEN
                                                                            -- PDOI for Complex PO Project
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'QUANTITY',
                             p_column_val       => p_quantity_tbl(i),
                             p_message_name     => 'PO_PDOI_SVC_PB_NO_QTY',
			     p_validation_id    => PO_VAL_CONSTANTS.c_loc_quantity);
        x_result_type := po_validations.c_result_type_failure;
      ELSIF (p_order_type_lookup_code_tbl(i) NOT IN ('FIXED PRICE', 'RATE')
             AND p_quantity_tbl(i) IS NOT NULL
             AND p_quantity_tbl(i) < 0) THEN
            x_results.add_result(p_entity_type       => c_entity_type_line_location,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'QUANTITY',
                                 p_column_val        => p_quantity_tbl(i),
                                 p_message_name      => 'PO_PDOI_LT_ZERO',
                                 p_token1_name       => 'COLUMN_NAME',
                                 p_token1_value      => 'QUANTITY',
                                 p_token2_name       => 'VALUE',
                                 p_token2_value      => p_quantity_tbl(i),
                                 p_validation_id     => PO_VAL_CONSTANTS.c_loc_quantity_ge_zero);
            x_result_type := po_validations.c_result_type_failure;
       -- <PDOI for Complex PO Project: Start>
      ELSIF (l_is_financing_style AND Nvl(p_shipment_type_tbl(i),'PREPAYMENT') = 'STANDARD'
             AND  Nvl(p_payment_type_tbl(i),'MILESTONE') = 'DELIVERY'
             AND Nvl(p_quantity_tbl(i),0) <> Nvl(p_line_quantity_tbl(i),0)) THEN
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'QUANTITY',
                             p_column_val       => p_quantity_tbl(i),
                             p_message_name     => 'PO_PDOI_DEL_SHIP_LINE_MISMATCH',
                             p_token1_name      => 'COLUMN',
                             p_token1_value     => 'QUANTITY',
                             p_token2_name      => 'VALUE',
                             p_token2_value     => p_quantity_tbl(i),
			                       p_validation_id    => PO_VAL_CONSTANTS.c_loc_quantity);
        x_result_type := po_validations.c_result_type_failure;
      -- <PDOI for Complex PO Project: End>
      END IF;
    END LOOP;

    IF po_log.d_proc THEN
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END quantity;

  -------------------------------------------------------------------------
-- PDOI for Complex PO Project: Validate amount at shipment, for DELIVERY
-- type shipment of 'complex PO with contract financing enabled'.
-------------------------------------------------------------------------
  PROCEDURE amount(
    p_id_tbl                       IN              po_tbl_number,
    p_amount_tbl                   IN              po_tbl_number,
    p_shipment_type_tbl            IN              po_tbl_varchar30,
    p_style_id_tbl                 IN              po_tbl_number,
    p_payment_type_tbl             IN              po_tbl_varchar30,
    p_line_amount_tbl              IN              po_tbl_number,
    x_results                      IN OUT NOCOPY   po_validation_results_type,
    x_result_type                  OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_amount;
    l_is_financing_style BOOLEAN;
  BEGIN
    IF (x_results IS NULL) THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_amount_tbl', p_amount_tbl);
      po_log.proc_begin(d_mod, 'p_shipment_type_tbl', p_shipment_type_tbl);
      po_log.proc_begin(d_mod, 'p_style_id_tbl', p_style_id_tbl);
      po_log.proc_begin(d_mod, 'p_payment_type_tbl', p_payment_type_tbl);
      po_log.proc_begin(d_mod, 'p_line_amount_tbl', p_line_amount_tbl);
      po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
    END IF;

    FOR i IN 1 .. p_id_tbl.COUNT LOOP

      l_is_financing_style := FALSE;
      l_is_financing_style := PO_COMPLEX_WORK_PVT.is_financing_payment_style(p_style_id => p_style_id_tbl(i));

      IF (l_is_financing_style AND Nvl(p_shipment_type_tbl(i),'PREPAYMENT') = 'STANDARD'
          AND Nvl(p_payment_type_tbl(i),'MILESTONE') = 'DELIVERY'
          AND Nvl(p_amount_tbl(i),0) <> Nvl(p_line_amount_tbl(i),0)) THEN
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'AMOUNT',
                             p_column_val       => p_amount_tbl(i),
                             p_message_name     => 'PO_PDOI_DEL_SHIP_LINE_MISMATCH',
                             p_token1_name      => 'COLUMN',
                             p_token1_value     => 'AMOUNT',
                             p_token2_name      => 'VALUE',
                             p_token2_value     => p_amount_tbl(i),
			                       p_validation_id    => PO_VAL_CONSTANTS.c_loc_amount);
        x_result_type := po_validations.c_result_type_failure;
      END IF;
    END LOOP;

    IF po_log.d_proc THEN
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END amount;

-------------------------------------------------------------------------
-- If order_type_lookup_code is not FIXED PRICE, price_override cannot be null
-------------------------------------------------------------------------
PROCEDURE price_override(
    p_id_tbl                       IN              po_tbl_number,
    p_price_override_tbl           IN              po_tbl_number,
    p_order_type_lookup_code_tbl   IN              po_tbl_varchar30,
    p_shipment_type_tbl            IN              po_tbl_varchar30, -- PDOI for Complex PO Project
    p_style_id_tbl                 IN              po_tbl_number,    -- PDOI for Complex PO Project
    p_payment_type_tbl             IN              po_tbl_varchar30, -- PDOI for Complex PO Project
    p_line_unit_price_tbl          IN              po_tbl_number,    -- PDOI for Complex PO Project
    x_results                      IN OUT NOCOPY   po_validation_results_type,
    x_result_type                  OUT NOCOPY      VARCHAR2)
  IS

    d_mod CONSTANT VARCHAR2(100) := d_price_override;
    l_is_financing_style BOOLEAN; -- PDOI for Complex PO Project
  BEGIN
    IF (x_results IS NULL) THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_price_override_tbl', p_price_override_tbl);
      po_log.proc_begin(d_mod, 'p_order_type_lookup_code_tbl', p_order_type_lookup_code_tbl);
      po_log.proc_begin(d_mod, 'p_shipment_type_tbl', p_shipment_type_tbl);     -- PDOI for Complex PO Project
      po_log.proc_begin(d_mod, 'p_style_id_tbl', p_style_id_tbl);               -- PDOI for Complex PO Project
      po_log.proc_begin(d_mod, 'p_payment_type_tbl', p_payment_type_tbl);       -- PDOI for Complex PO Project
      po_log.proc_begin(d_mod, 'p_line_unit_price_tbl', p_line_unit_price_tbl); -- PDOI for Complex PO Project
      po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
    END IF;

    -- If order_type_lookup_code is not FIXED PRICE, price_override cannot be null
    FOR i IN 1 .. p_id_tbl.COUNT LOOP

       /* PDOI for Complex PO Project: START */
      l_is_financing_style := FALSE;
      l_is_financing_style := PO_COMPLEX_WORK_PVT.is_financing_payment_style(p_style_id => p_style_id_tbl(i));
      /* PDOI for Complex PO Project: END */

      IF (p_order_type_lookup_code_tbl(i) <> 'FIXED PRICE' AND p_price_override_tbl(i) IS NULL) THEN
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'PRICE_OVERRIDE',
                             p_column_val       => p_price_override_tbl(i),
                             p_message_name     => 'PO_PDOI_COLUMN_NOT_NULL',
                             p_token1_name      => 'COLUMN_NAME',
                             p_token1_value     => 'PRICE_OVERRIDE',
							 p_validation_id    => PO_VAL_CONSTANTS.c_loc_price_override_not_null);
        x_result_type := po_validations.c_result_type_failure;
      ELSIF p_price_override_tbl(i) < 0 THEN
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'PRICE_OVERRIDE',
                             p_column_val       => p_price_override_tbl(i),
                             p_message_name     => 'PO_PDOI_LT_ZERO',
                             p_token1_name      => 'COLUMN_NAME',
                             p_token1_value     => 'PRICE_OVERRIDE',
                             p_token2_name      => 'VALUE',
                             p_token2_value     => p_price_override_tbl(i),
							 p_validation_id    => PO_VAL_CONSTANTS.c_loc_price_override_ge_zero);
        x_result_type := po_validations.c_result_type_failure;
	  -- <PDOI for Complex PO Project: Start>
      ELSIF (l_is_financing_style AND Nvl(p_shipment_type_tbl(i),'PREPAYMENT') = 'STANDARD'
             AND Nvl(p_payment_type_tbl(i),'MILESTONE') = 'DELIVERY'
             AND Nvl(p_price_override_tbl(i),0) <> Nvl(p_line_unit_price_tbl(i),0)) THEN
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'PRICE_OVERRIDE',
                             p_column_val       => p_price_override_tbl(i),
                             p_message_name     => 'PO_PDOI_DEL_SHIP_LINE_MISMATCH',
                             p_token1_name      => 'COLUMN',
                             p_token1_value     => 'PRICE_OVERRIDE',
                             p_token2_name      => 'VALUE',
                             p_token2_value     => p_price_override_tbl(i),
							 p_validation_id    => PO_VAL_CONSTANTS.c_loc_price_override_not_null);
        x_result_type := po_validations.c_result_type_failure;
        -- <PDOI for Complex PO Project: End>
      END IF;
    END LOOP;

    IF po_log.d_proc THEN
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END price_override;

-------------------------------------------------------------------------
-- If order_type_lookup_code is not FIXED PRICE, price_discount cannot be null
-- and price discount cannot be greater than 100
-------------------------------------------------------------------------
  PROCEDURE price_discount(
    p_id_tbl                       IN              po_tbl_number,
    p_price_discount_tbl           IN              po_tbl_number,
    p_price_override_tbl           IN              po_tbl_number,
    p_order_type_lookup_code_tbl   IN              po_tbl_varchar30,
    x_results                      IN OUT NOCOPY   po_validation_results_type,
    x_result_type                  OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_price_discount;
  BEGIN
    IF (x_results IS NULL) THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_price_discount_tbl', p_price_discount_tbl);
      po_log.proc_begin(d_mod, 'p_price_override_tbl', p_price_override_tbl);
      po_log.proc_begin(d_mod, 'p_order_type_lookup_code_tbl', p_order_type_lookup_code_tbl);
      po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
    END IF;

    -- If order_type_lookup_code is not FIXED PRICE and price_discount/price override cannot both be null
    -- and price discount cannot be greater than 100
    FOR i IN 1 .. p_id_tbl.COUNT LOOP
      IF (p_order_type_lookup_code_tbl(i) <> 'FIXED PRICE' AND
          p_price_discount_tbl(i) IS NULL AND p_price_override_tbl(i) IS NULL) THEN
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'PRICE_DISCOUNT',
                             p_column_val       => p_price_discount_tbl(i),
                             p_message_name     => 'PO_PDOI_COLUMN_NOT_NULL',
                             p_token1_name      => 'COLUMN_NAME',
                             p_token1_value     => 'PRICE_DISCOUNT',
							 p_validation_id    => PO_VAL_CONSTANTS.c_loc_price_discount_not_null);
        x_result_type := po_validations.c_result_type_failure;

      -- Bug 6614819 -- Commented the code below --
      -- Since negative price break discount is allowed from the form,
      -- now it is allowed from PDOI also.
      -- Therefore removing the check for negative price discount below.
      ELSIF(  p_order_type_lookup_code_tbl(i) <> 'FIXED PRICE' AND p_price_discount_tbl(i) IS NOT NULL AND
             (/*p_price_discount_tbl(i) < 0 OR */p_price_discount_tbl(i) > 100)) THEN
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'PRICE_DISCOUNT',
                             p_column_val       => p_price_discount_tbl(i),
                             p_message_name     => 'PO_PDOI_INVALID_DISCOUNT',
                             p_token1_name      => 'VALUE',
                             p_token1_value     => p_price_discount_tbl(i),
							 p_validation_id    => PO_VAL_CONSTANTS.c_loc_price_discount_valid);
        x_result_type := po_validations.c_result_type_failure;
      END IF;
    END LOOP;

    IF po_log.d_proc THEN
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END price_discount;

-------------------------------------------------------------------------
-- validate ship_to_organization_id
-------------------------------------------------------------------------
  PROCEDURE ship_to_organization_id(
    p_id_tbl                        IN              po_tbl_number,
    p_ship_to_organization_id_tbl   IN              po_tbl_number,
    p_item_id_tbl                   IN              po_tbl_number,
    p_item_revision_tbl             IN              po_tbl_varchar5,
    p_ship_to_location_id_tbl       IN              po_tbl_number,
    x_result_set_id                 IN OUT NOCOPY   NUMBER,
    x_result_type                   OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_ship_to_organization_id;
  BEGIN
    IF x_result_set_id IS NULL THEN
      x_result_set_id := po_validations.next_result_set_id();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_ship_to_organization_id_tbl', p_ship_to_organization_id_tbl);
      po_log.proc_begin(d_mod, 'p_item_id_tbl', p_item_id_tbl);
      po_log.proc_begin(d_mod, 'p_item_revision_tbl', p_item_revision_tbl);
      po_log.proc_begin(d_mod, 'p_ship_to_location_id_tbl', p_ship_to_location_id_tbl);
      po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;

    -- If item_id is not null and ship_to_organization_id is not null, and
    -- item_revision is not null and no record exists in mtl_item_revisions.
    FORALL i IN 1 .. p_id_tbl.COUNT
      INSERT INTO po_validation_results_gt
                  (result_set_id,
                   result_type,
                   entity_type,
                   entity_id,
                   message_name,
                   column_name,
                   column_val,
                   token1_name,
                   token1_value,
				   validation_id)
        SELECT x_result_set_id,
               po_validations.c_result_type_failure,
               c_entity_type_line_location,
               p_id_tbl(i),
               'PO_PDOI_INVALID_SHIP_TO_ORG_ID',
               'SHIP_TO_ORGANIZATION_ID',
               p_ship_to_organization_id_tbl(i),
               'SHIP_TO_ORGANIZATION_ID',
               p_ship_to_organization_id_tbl(i),
               PO_VAL_CONSTANTS.c_ship_to_organization_id
          FROM DUAL
         WHERE p_ship_to_organization_id_tbl(i) IS NOT NULL
           AND p_item_revision_tbl(i) IS NOT NULL
           AND p_item_id_tbl(i) IS NOT NULL
           AND NOT EXISTS(
                 SELECT 1
                   FROM mtl_item_revisions mir
                  WHERE mir.inventory_item_id = p_item_id_tbl(i)
                    AND mir.revision = p_item_revision_tbl(i)
                    AND mir.organization_id = p_ship_to_organization_id_tbl(i));

    IF (SQL%ROWCOUNT > 0) THEN
      x_result_type := po_validations.c_result_type_failure;
    END IF;

    -- If item_id is not null and ship_to_organization_id is not null, and
    -- item_revision is null, and no record exists in mtl_system_items.
    -- Bug7513119 - Non revision controlled items were also getting validated
    -- against mtl_item_revisions, changed this to mtl_system_items.
    FORALL i IN 1 .. p_id_tbl.COUNT
      INSERT INTO po_validation_results_gt
                  (result_set_id,
                   result_type,
                   entity_type,
                   entity_id,
                   message_name,
                   column_name,
                   column_val,
                   token1_name,
                   token1_value,
				   validation_id)
        SELECT x_result_set_id,
               po_validations.c_result_type_failure,
               c_entity_type_line_location,
               p_id_tbl(i),
               'PO_PDOI_INVALID_SHIP_TO_ORG_ID',
               'SHIP_TO_ORGANIZATION_ID',
               p_ship_to_organization_id_tbl(i),
               'SHIP_TO_ORGANIZATION_ID',
               p_ship_to_organization_id_tbl(i),
               PO_VAL_CONSTANTS.c_ship_to_organization_id
          FROM DUAL
         WHERE p_ship_to_organization_id_tbl(i) IS NOT NULL
           AND p_item_revision_tbl(i) IS NULL
           AND p_item_id_tbl(i) IS NOT NULL
           AND NOT EXISTS(SELECT 1
                            FROM mtl_system_items msi --Bug7513119
                           WHERE msi.inventory_item_id = p_item_id_tbl(i)
                             AND msi.organization_id = p_ship_to_organization_id_tbl(i));


    IF (SQL%ROWCOUNT > 0) THEN
      x_result_type := po_validations.c_result_type_failure;
    END IF;

    -- If item_id is null, and ship_to_organization_id is not null,
    -- validate ship_to_organization_id against org_organization_definitions
    FORALL i IN 1 .. p_id_tbl.COUNT
      INSERT INTO po_validation_results_gt
                  (result_set_id,
                   result_type,
                   entity_type,
                   entity_id,
                   message_name,
                   column_name,
                   column_val,
                   token1_name,
                   token1_value,
				   validation_id)
        SELECT x_result_set_id,
               po_validations.c_result_type_failure,
               c_entity_type_line_location,
               p_id_tbl(i),
               'PO_PDOI_INVALID_SHIP_TO_ORG_ID',
               'SHIP_TO_ORGANIZATION_ID',
               p_ship_to_organization_id_tbl(i),
               'SHIP_TO_ORGANIZATION_ID',
               p_ship_to_organization_id_tbl(i),
               PO_VAL_CONSTANTS.c_ship_to_organization_id
          FROM DUAL
         WHERE p_ship_to_organization_id_tbl(i) IS NOT NULL
           AND p_item_id_tbl(i) IS NULL
           AND NOT EXISTS(
                 SELECT 1
                   FROM org_organization_definitions ood
                  WHERE ood.organization_id = p_ship_to_organization_id_tbl(i)
                    AND SYSDATE < NVL(ood.disable_date, SYSDATE + 1)
                    AND ood.inventory_enabled_flag = 'Y');

    IF (SQL%ROWCOUNT > 0) THEN
      x_result_type := po_validations.c_result_type_failure;
    END IF;

    -- If ship_to_location_id is not null, check if record exists in
    -- po_locations_val_v by ship_to_location_id and ship_to_organization_id.
    -- If no record exists, or multiple records exist, then error.
    FORALL i IN 1 .. p_id_tbl.COUNT
      INSERT INTO po_validation_results_gt
                  (result_set_id,
                   result_type,
                   entity_type,
                   entity_id,
                   message_name,
                   column_name,
                   column_val,
                   token1_name,
                   token1_value,
				   validation_id)
        SELECT x_result_set_id,
               po_validations.c_result_type_failure,
               c_entity_type_line_location,
               p_id_tbl(i),
               'PO_PDOI_INVALID_SHIP_TO_LOC_ID',
               'SHIP_TO_LOCATION_ID',
               p_ship_to_location_id_tbl(i),
               'SHIP_TO_LOCATION_ID',
               p_ship_to_location_id_tbl(i),
               PO_VAL_CONSTANTS.c_loc_ship_to_loc_id_valid
          FROM DUAL
         WHERE p_ship_to_location_id_tbl(i) IS NOT NULL
           AND NOT EXISTS(
                 SELECT 1
                   FROM po_locations_val_v PLV
                  WHERE PLV.location_id = p_ship_to_location_id_tbl(i)
                    AND ship_to_site_flag = 'Y'
                    AND (   PLV.inventory_organization_id IS NULL
                         OR PLV.inventory_organization_id = p_ship_to_organization_id_tbl(i)
                         OR p_ship_to_organization_id_tbl(i) IS NULL));

    IF (SQL%ROWCOUNT > 0) THEN
      x_result_type := po_validations.c_result_type_failure;
    END IF;

    IF po_log.d_proc THEN
      po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END ship_to_organization_id;

-------------------------------------------------------------------------
-- validate price break attributes
-------------------------------------------------------------------------
  PROCEDURE price_break_attributes(
    p_id_tbl                     IN              po_tbl_number,
    p_from_date_tbl              IN              po_tbl_date,
    p_to_date_tbl                IN              po_tbl_date,
    p_quantity_tbl               IN              po_tbl_number,
    p_ship_to_org_id_tbl         IN              po_tbl_number,
    p_ship_to_location_id_tbl    IN              po_tbl_number,
    x_results                    IN OUT NOCOPY   po_validation_results_type,
    x_result_type                OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_price_break_attributes;
  BEGIN
    IF (x_results IS NULL) THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_from_date_tbl', p_from_date_tbl);
      po_log.proc_begin(d_mod, 'p_to_date_tbl', p_to_date_tbl);
      po_log.proc_begin(d_mod, 'p_quantity_tbl', p_quantity_tbl);
      po_log.proc_begin(d_mod, 'p_ship_to_org_id_tbl', p_ship_to_org_id_tbl);
      po_log.proc_begin(d_mod, 'p_ship_to_location_id_tbl', p_ship_to_location_id_tbl);
      po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
    END IF;

    -- validate price break attributes
    FOR i IN 1 .. p_id_tbl.COUNT LOOP
      IF (    p_from_date_tbl(i) IS NULL
          AND p_to_date_tbl(i) IS NULL
          AND (p_quantity_tbl(i) IS NULL OR p_quantity_tbl(i) <= 0)
          AND p_ship_to_org_id_tbl(i) IS NULL
          AND p_ship_to_location_id_tbl(i) IS NULL) THEN
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'PRICE_BREAK_ATTRIBUTES',
                             p_message_name     => 'POX_PRICEBREAK_ITEM_FAILED');
        x_result_type := po_validations.c_result_type_failure;
      END IF;
    END LOOP;

    IF po_log.d_proc THEN
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END price_break_attributes;

-------------------------------------------------------------------------
-- validate_effective_dates
-------------------------------------------------------------------------
  PROCEDURE effective_dates(
    p_id_tbl                     IN              po_tbl_number,
    p_line_expiration_date_tbl   IN              po_tbl_date,
    p_to_date_tbl                IN              po_tbl_date,
    p_from_date_tbl              IN              po_tbl_date,
    p_header_start_date_tbl      IN              po_tbl_date,
    p_header_end_date_tbl        IN              po_tbl_date,
    p_price_break_lookup_code_tbl IN PO_TBL_VARCHAR30, -- bug5016163
    x_results                    IN OUT NOCOPY   po_validation_results_type,
    x_result_type                OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_effective_dates;
  BEGIN
    IF (x_results IS NULL) THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_line_expiration_date_tbl', p_line_expiration_date_tbl);
      po_log.proc_begin(d_mod, 'p_to_date_tbl', p_to_date_tbl);
      po_log.proc_begin(d_mod, 'p_from_date_tbl', p_from_date_tbl);
      po_log.proc_begin(d_mod, 'p_header_start_date_tbl', p_header_start_date_tbl);
      po_log.proc_begin(d_mod, 'p_header_end_date_tbl', p_header_end_date_tbl);
      po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
    END IF;

    FOR i IN 1 .. p_id_tbl.COUNT LOOP
      -- Pricebreak effective from date cannot be earlier than blanket
      -- agreement header start date
      IF (p_from_date_tbl(i) IS NOT NULL AND p_from_date_tbl(i) < p_header_start_date_tbl(i)) THEN
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'EFFECTIVE_DATE',
                             p_column_val       => p_from_date_tbl(i),
                             p_message_name     => 'POX_EFFECTIVE_DATES1',
							 p_validation_id    => PO_VAL_CONSTANTS.c_loc_from_date_ge_hdr_start);
        x_result_type := po_validations.c_result_type_failure;
      END IF;

      -- Pricebreak effective from date cannot be later than blanket
      -- agreement header end date
      IF (p_from_date_tbl(i) IS NOT NULL AND p_from_date_tbl(i) > p_header_end_date_tbl(i)) THEN
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'EFFECTIVE_DATE',
                             p_column_val       => p_from_date_tbl(i),
                             p_message_name     => 'POX_EFFECTIVE_DATES4',
							 p_validation_id    => PO_VAL_CONSTANTS.c_loc_from_date_le_hdr_end);
        x_result_type := po_validations.c_result_type_failure;
      END IF;

      -- Pricebreak effective From Date cannot be later than pricebreak
      -- effective To Date
      IF (p_from_date_tbl(i) IS NOT NULL AND p_to_date_tbl(i) IS NOT NULL
          AND p_from_date_tbl(i) > p_to_date_tbl(i)) THEN
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'EFFECTIVE_DATE',
                             p_column_val       => p_from_date_tbl(i),
                             p_message_name     => 'POX_EFFECTIVE_DATES3',
							 p_validation_id    => PO_VAL_CONSTANTS.c_loc_from_date_le_loc_end);
        x_result_type := po_validations.c_result_type_failure;
      END IF;

      -- Pricebreak From Date cannot be greater than the pricebreak line
      -- expiration Date
      IF (p_from_date_tbl(i) IS NOT NULL AND p_from_date_tbl(i) > p_line_expiration_date_tbl(i)) THEN
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'EFFECTIVE_DATE',
                             p_column_val       => p_from_date_tbl(i),
                             p_message_name     => 'POX_EFFECTIVE_DATES6',
							 p_validation_id    => PO_VAL_CONSTANTS.c_loc_from_date_le_line_end);
        x_result_type := po_validations.c_result_type_failure;
      END IF;

      -- Pricebreak effective To Date cannot be later than
      -- expiration Date, if expiration date exists
      IF (p_line_expiration_date_tbl(i) IS NOT NULL AND p_to_date_tbl(i) > p_line_expiration_date_tbl(i)) THEN
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'EXPIRATION_DATE',
                             p_column_val       => p_line_expiration_date_tbl(i),
                             p_message_name     => 'POX_EFFECTIVE_DATES2',
							 p_validation_id    => PO_VAL_CONSTANTS.c_loc_end_date_le_line_end);
        x_result_type := po_validations.c_result_type_failure;
      END IF;

      -- Pricebreak To Date is greater than Header End date
      IF (p_header_end_date_tbl(i) IS NOT NULL AND p_to_date_tbl(i) > p_header_end_date_tbl(i)) THEN
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'EXPIRATION_DATE',
                             p_column_val       => p_line_expiration_date_tbl(i),
                             p_message_name     => 'POX_EFFECTIVE_DATES',
							 p_validation_id    => PO_VAL_CONSTANTS.c_loc_end_date_le_hdr_end);
        x_result_type := po_validations.c_result_type_failure;
      END IF;

      -- Pricebreak To Date cannot be earlier than Header Start date
      IF (p_header_start_date_tbl(i) IS NOT NULL AND p_to_date_tbl(i) < p_header_start_date_tbl(i)) THEN
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'START_DATE',
                             p_column_val       => p_header_start_date_tbl(i),
                             p_message_name     => 'POX_EFFECTIVE_DATES5',
							 p_validation_id    => PO_VAL_CONSTANTS.c_loc_end_date_ge_hdr_start);
        x_result_type := po_validations.c_result_type_failure;
      END IF;

      -- Pricebreak effective To Date cannot be earlier than Pricebreak
      -- effective From Date
      IF (p_to_date_tbl(i) IS NOT NULL AND p_from_date_tbl(i) IS NOT NULL
          AND p_to_date_tbl(i) < p_from_date_tbl(i)) THEN
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'EFFECTIVE_DATE',
                             p_column_val       => p_to_date_tbl(i),
                             p_message_name     => 'POX_EFFECTIVE_DATES3',
							 p_validation_id    => PO_VAL_CONSTANTS.c_loc_from_date_le_loc_end);
        x_result_type := po_validations.c_result_type_failure;
      END IF;

      -- bug5016163
      -- Time phased pricing cannot go with cumulative pricing
      IF (p_price_break_lookup_code_tbl(i) = 'CUMULATIVE') THEN
        IF (p_from_date_tbl(i) IS NOT NULL) THEN

          -- bug5262146
          -- Added p_validation_id

          x_results.add_result
          ( p_entity_type      => c_entity_type_line_location,
            p_entity_id        => p_id_tbl(i),
            p_column_name      => 'EFFECTIVE_DATE',
            p_column_val       => p_from_date_tbl(i),
            p_message_name     => 'PO_PDOI_CUMULATIVE_FAILED',
            p_validation_id    => PO_VAL_CONSTANTS.c_dates_cumulative_failed);

          x_result_type := po_validations.c_result_type_failure;

        ELSIF (p_to_date_tbl(i) IS NOT NULL) THEN

          -- bug5262146
          -- Added p_validation_id

          x_results.add_result
          ( p_entity_type      => c_entity_type_line_location,
            p_entity_id        => p_id_tbl(i),
            p_column_name      => 'EFFECTIVE_DATE',
            p_column_val       => p_to_date_tbl(i),
            p_message_name     => 'PO_PDOI_CUMULATIVE_FAILED',
            p_validation_id    => PO_VAL_CONSTANTS.c_dates_cumulative_failed);

          x_result_type := po_validations.c_result_type_failure;
        END IF;
      END IF;

    END LOOP;

    IF po_log.d_proc THEN
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END effective_dates;

-------------------------------------------------------------------------
-- validate qty_rcv_exception_code against PO_LOOKUP_CODES
-------------------------------------------------------------------------
  PROCEDURE qty_rcv_exception_code(
    p_id_tbl                       IN              po_tbl_number,
    p_qty_rcv_exception_code_tbl   IN              po_tbl_varchar30,
    x_result_set_id                IN OUT NOCOPY   NUMBER,
    x_result_type                  OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_qty_rcv_exception_code;
  BEGIN
    IF x_result_set_id IS NULL THEN
      x_result_set_id := po_validations.next_result_set_id();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_qty_rcv_exception_code_tbl', p_qty_rcv_exception_code_tbl);
      po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;

    FORALL i IN 1 .. p_id_tbl.COUNT
      INSERT INTO po_validation_results_gt
                  (result_set_id,
                   result_type,
                   entity_type,
                   entity_id,
                   message_name,
                   column_name,
                   column_val,
                   token1_name,
                   token1_value,
      	           validation_id)
        SELECT x_result_set_id,
               po_validations.c_result_type_failure,
               c_entity_type_line_location,
               p_id_tbl(i),
               'PO_PDOI_INVALID_RCV_EXCEP_CD',
               'QTY_RCV_EXCEPTION_CODE',
               p_qty_rcv_exception_code_tbl(i),
               'QTY_RCV_EXCEPTION_CODE',
               p_qty_rcv_exception_code_tbl(i),
               PO_VAL_CONSTANTS.c_qty_ecv_exception_code
          FROM DUAL
         WHERE p_qty_rcv_exception_code_tbl(i) IS NOT NULL
           AND NOT EXISTS(
                 SELECT 1
                   FROM po_lookup_codes plc
                  WHERE p_qty_rcv_exception_code_tbl(i) = plc.lookup_code
                    AND plc.lookup_type = 'RECEIVING CONTROL LEVEL'
                    AND SYSDATE < NVL(plc.inactive_date, SYSDATE + 1));

    IF (SQL%ROWCOUNT > 0) THEN
      x_result_type := po_validations.c_result_type_failure;
    ELSE
      x_result_type := po_validations.c_result_type_success;
    END IF;

    IF po_log.d_proc THEN
      po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END qty_rcv_exception_code;

-------------------------------------------------------------------------
-- If shipment_type is STANDARD and enforce_ship_to_loc_code is not equal
-- to NONE, REJECT or WARNING
-- <<PDOI Enhancement Bug#17063664>>
-- ENFORCE_SHIP_TO_LOC_CODE should be NULL for Fixed Price and Rate based lines.
-------------------------------------------------------------------------
  PROCEDURE enforce_ship_to_loc_code(
    p_id_tbl                         IN              po_tbl_number,
    p_enforce_ship_to_loc_code_tbl   IN              po_tbl_varchar30,
    p_shipment_type_tbl              IN              po_tbl_varchar30,
    p_order_type_lookup_tbl          IN              po_tbl_varchar30, -- <<PDOI Enhancement Bug#17063664>>
    x_results                        IN OUT NOCOPY   po_validation_results_type,
    x_result_type                    OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_enforce_ship_to_loc_code;
  BEGIN
    IF (x_results IS NULL) THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_enforce_ship_to_loc_code_tbl', p_enforce_ship_to_loc_code_tbl);
      po_log.proc_begin(d_mod, 'p_shipment_type_tbl', p_shipment_type_tbl);
      po_log.proc_begin(d_mod, 'p_order_type_lookup_tbl', p_order_type_lookup_tbl);
      po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
    END IF;

    -- If shipment_type is STANDARD and enforce_ship_to_loc_code is not equal
    -- to NONE, REJECT or WARNING
    FOR i IN 1 .. p_id_tbl.COUNT LOOP
      IF (    p_shipment_type_tbl(i) = 'STANDARD'
          AND p_enforce_ship_to_loc_code_tbl(i) IS NOT NULL
          AND (p_enforce_ship_to_loc_code_tbl(i) NOT IN('NONE', 'REJECT', 'WARNING'))) THEN
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'ENFORCE_SHIP_TO_LOC_CODE',
                             p_column_val       => p_enforce_ship_to_loc_code_tbl(i),
                             p_message_name     => 'PO_PDOI_INVALID_EN_SH_LOC_CODE'
							 );
        x_result_type := po_validations.c_result_type_failure;

     -- <<PDOI Enhancement Bug#17063664>>
     -- ENFORCE_SHIP_TO_LOC_CODE should be NULL for Fixed Price and Rate based lines.
      ELSIF ( p_shipment_type_tbl(i) = 'STANDARD'
              AND p_order_type_lookup_tbl(i) IN ('FIXED PRICE', 'RATE')
              AND p_enforce_ship_to_loc_code_tbl(i) IS NOT NULL) THEN
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'ENFORCE_SHIP_TO_LOC_CODE',
                             p_column_val       => p_enforce_ship_to_loc_code_tbl(i),
                             p_message_name     => 'PO_PDOI_COLUMN_NULL',
                             p_token1_name      => 'COLUMN_NAME',
                             p_token1_value     => 'ENFORCE_SHIP_TO_LOC_CODE',
                             p_token2_name      => 'VALUE',
                             p_token2_value     => p_enforce_ship_to_loc_code_tbl(i)
							 );
        x_result_type := po_validations.c_result_type_failure;
      END IF;
    END LOOP;

    IF po_log.d_proc THEN
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END enforce_ship_to_loc_code;

-------------------------------------------------------------------------
-- If shipment_type is STANDARD and allow_sub_receipts_flag is not equal
-- to NONE, REJECT or WARNING
-- <<PDOI Enhancement Bug#17063664>>
-- ALLOW_SUB_RECEIPTS_FLAG should be NULL for Fixed Price and Rate based lines.
-------------------------------------------------------------------------
  PROCEDURE allow_sub_receipts_flag(
    p_id_tbl                        IN              po_tbl_number,
    p_shipment_type_tbl             IN              po_tbl_varchar30,
    p_allow_sub_receipts_flag_tbl   IN              po_tbl_varchar1,
    p_order_type_lookup_tbl         IN              po_tbl_varchar30, -- <<PDOI Enhancement Bug#17063664>>
    x_results                       IN OUT NOCOPY   po_validation_results_type,
    x_result_type                   OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_allow_sub_receipts_flag;
  BEGIN
    IF (x_results IS NULL) THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_shipment_type_tbl', p_shipment_type_tbl);
      po_log.proc_begin(d_mod, 'p_allow_sub_receipts_flag_tbl', p_allow_sub_receipts_flag_tbl);
      po_log.proc_begin(d_mod, 'p_order_type_lookup_tbl', p_order_type_lookup_tbl);
      po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
    END IF;

    -- If shipment_type is STANDARD and allow_sub_receipts_flag is not null and
    -- not equal to NONE, REJECT or WARNING
    FOR i IN 1 .. p_id_tbl.COUNT LOOP
      IF p_shipment_type_tbl(i) = 'STANDARD' AND p_allow_sub_receipts_flag_tbl(i) IS NOT NULL
         AND p_allow_sub_receipts_flag_tbl(i) NOT IN('Y', 'N') THEN
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'ALLOW_SUB_RECEIPTS_FLAG',
                             p_column_val       => p_allow_sub_receipts_flag_tbl(i),
                             p_message_name     => 'PO_PDOI_ALLOW_SUB_REC_FLAG');
        x_result_type := po_validations.c_result_type_failure;

    -- <<PDOI Enhancement Bug#17063664>>
     -- ALLOW_SUB_RECEIPTS_FLAG should be NULL for Fixed Price and Rate based lines.
      ELSIF ( p_shipment_type_tbl(i) = 'STANDARD'
              AND p_order_type_lookup_tbl(i) IN ('FIXED PRICE', 'RATE')
              AND p_allow_sub_receipts_flag_tbl(i) IS NOT NULL) THEN
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'ALLOW_SUB_RECEIPTS_FLAG',
                             p_column_val       => p_allow_sub_receipts_flag_tbl(i),
                             p_message_name     => 'PO_PDOI_COLUMN_NULL',
                             p_token1_name      => 'COLUMN_NAME',
                             p_token1_value     => 'ALLOW_SUB_RECEIPTS_FLAG',
                             p_token2_name      => 'VALUE',
                             p_token2_value     => p_allow_sub_receipts_flag_tbl(i));
        x_result_type := po_validations.c_result_type_failure;
      END IF;
    END LOOP;

    IF po_log.d_proc THEN
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END allow_sub_receipts_flag;

-------------------------------------------------------------------------
-- If shipment_type is STANDARD and days_early_receipt_allowed is not null
-- and less than zero.
-- <<PDOI Enhancement Bug#17063664>>
-- DAYS_EARLY_RECEIPT_ALLOWED should be NULL for Fixed Price and Rate based lines.
-------------------------------------------------------------------------
  PROCEDURE days_early_receipt_allowed(
    p_id_tbl                        IN              po_tbl_number,
    p_shipment_type_tbl             IN              po_tbl_varchar30,
    p_days_early_rcpt_allowed_tbl   IN              po_tbl_number,
    p_order_type_lookup_tbl         IN              po_tbl_varchar30, -- <<PDOI Enhancement Bug#17063664>>
    x_results                       IN OUT NOCOPY   po_validation_results_type,
    x_result_type                   OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_days_early_receipt_allowed;
  BEGIN
    IF (x_results IS NULL) THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_shipment_type_tbl', p_shipment_type_tbl);
      po_log.proc_begin(d_mod, 'p_days_early_rcpt_allowed_tbl', p_days_early_rcpt_allowed_tbl);
      po_log.proc_begin(d_mod, 'p_order_type_lookup_tbl', p_order_type_lookup_tbl);
      po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
    END IF;

    -- If shipment_type is STANDARD and days_early_receipt_allowed is not null
    -- and less than zero.
    FOR i IN 1 .. p_id_tbl.COUNT LOOP
      IF (p_shipment_type_tbl(i) = 'STANDARD'
          AND p_days_early_rcpt_allowed_tbl(i) IS NOT NULL
          AND p_days_early_rcpt_allowed_tbl(i) < 0) THEN
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'DAYS_EARLY_RECEIPT_ALLOWED',
                             p_column_val       => p_days_early_rcpt_allowed_tbl(i),
                             p_message_name     => 'PO_PDOI_DAYS_EARLY_REC_ALLOWED');
        x_result_type := po_validations.c_result_type_failure;
    -- <<PDOI Enhancement Bug#17063664>>
     -- DAYS_EARLY_RECEIPT_ALLOWED should be NULL for Fixed Price and Rate based lines.
      ELSIF ( p_shipment_type_tbl(i) = 'STANDARD'
              AND p_order_type_lookup_tbl(i) IN ('FIXED PRICE', 'RATE')
              AND p_days_early_rcpt_allowed_tbl(i) IS NOT NULL) THEN
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'DAYS_EARLY_RECEIPT_ALLOWED',
                             p_column_val       => p_days_early_rcpt_allowed_tbl(i),
                             p_message_name     => 'PO_PDOI_COLUMN_NULL',
                             p_token1_name      => 'COLUMN_NAME',
                             p_token1_value     => 'DAYS_EARLY_RECEIPT_ALLOWED',
                             p_token2_name      => 'VALUE',
                             p_token2_value     => p_days_early_rcpt_allowed_tbl(i));
        x_result_type := po_validations.c_result_type_failure;
      END IF;
    END LOOP;

    IF po_log.d_proc THEN
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END days_early_receipt_allowed;

-------------------------------------------------------------------------
-- If shipment_type is STANDARD and receipt_days_expection_code is not null
-- and not 'NONE', 'REJECT' not 'WARNING'
-- <<PDOI Enhancement Bug#17063664>>
-- RECEIPT_DAYS_EXPECTION_CODE should be NULL for Fixed Price and Rate based lines.
-------------------------------------------------------------------------
  PROCEDURE receipt_days_exception_code(
    p_id_tbl                         IN              po_tbl_number,
    p_shipment_type_tbl              IN              po_tbl_varchar30,
    p_rcpt_days_exception_code_tbl   IN              po_tbl_varchar30,
    p_order_type_lookup_tbl          IN              po_tbl_varchar30, -- <<PDOI Enhancement Bug#17063664>>
    x_results                        IN OUT NOCOPY   po_validation_results_type,
    x_result_type                    OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_receipt_days_exception_code;
  BEGIN
    IF (x_results IS NULL) THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_shipment_type_tbl', p_shipment_type_tbl);
      po_log.proc_begin(d_mod, 'p_days_early_exception_code_tbl', p_rcpt_days_exception_code_tbl);
      po_log.proc_begin(d_mod, 'p_order_type_lookup_tbl', p_order_type_lookup_tbl);
      po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
    END IF;

    -- If shipment_type is STANDARD and receipt_days_expection_code is not null
    -- and not 'NONE', 'REJECT' not 'WARNING'
    FOR i IN 1 .. p_id_tbl.COUNT LOOP
      IF     p_shipment_type_tbl(i) = 'STANDARD'
         AND p_rcpt_days_exception_code_tbl(i) IS NOT NULL
         AND p_rcpt_days_exception_code_tbl(i) NOT IN('NONE', 'REJECT', 'WARNING') THEN
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'RECEIPT_DAYS_EXPECTION_CODE',
                             p_column_val       => p_rcpt_days_exception_code_tbl(i),
                             p_message_name     => 'PO_PDOI_INV_REC_DAYS_EX_CODE');
        x_result_type := po_validations.c_result_type_failure;
    -- <<PDOI Enhancement Bug#17063664>>
     -- RECEIPT_DAYS_EXPECTION_CODE should be NULL for Fixed Price and Rate based lines.
      ELSIF ( p_shipment_type_tbl(i) = 'STANDARD'
              AND p_order_type_lookup_tbl(i) IN ('FIXED PRICE', 'RATE')
              AND p_rcpt_days_exception_code_tbl(i) IS NOT NULL) THEN
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'RECEIPT_DAYS_EXPECTION_CODE',
                             p_column_val       => p_rcpt_days_exception_code_tbl(i),
                             p_message_name     => 'PO_PDOI_COLUMN_NULL',
                             p_token1_name      => 'COLUMN_NAME',
                             p_token1_value     => 'RECEIPT_DAYS_EXPECTION_CODE',
                             p_token2_name      => 'VALUE',
                             p_token2_value     => p_rcpt_days_exception_code_tbl(i));
        x_result_type := po_validations.c_result_type_failure;
      END IF;
    END LOOP;

    IF po_log.d_proc THEN
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END receipt_days_exception_code;

-------------------------------------------------------------------------
-- If shipment_type is STANDARD and invoice_close_tolerance is not null
-- and less than or equal to zero or greater than or equal to 100.
-------------------------------------------------------------------------
  PROCEDURE invoice_close_tolerance(
    p_id_tbl                        IN              po_tbl_number,
    p_shipment_type_tbl             IN              po_tbl_varchar30,
    p_invoice_close_tolerance_tbl   IN              po_tbl_number,
    x_results                       IN OUT NOCOPY   po_validation_results_type,
    x_result_type                   OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_invoice_close_tolerance;
  BEGIN
    IF (x_results IS NULL) THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_shipment_type_tbl', p_shipment_type_tbl);
      po_log.proc_begin(d_mod, 'p_invoice_close_tolerance_tbl', p_invoice_close_tolerance_tbl);
      po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
    END IF;

    -- If shipment_type is STANDARD and invoice_close_tolerance is not null
    -- and less than or equal to zero or greater than or equal to 100.
    FOR i IN 1 .. p_id_tbl.COUNT LOOP
      IF p_shipment_type_tbl(i) = 'STANDARD' AND
         p_invoice_close_tolerance_tbl(i) IS NOT NULL AND
         (p_invoice_close_tolerance_tbl(i) < 0 OR p_invoice_close_tolerance_tbl(i) > 100) THEN
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_invoice_close_tolerance_tbl(i),
                             p_column_name      => 'INVOICE_CLOSE_TOLERANCE',
                             p_column_val       => p_invoice_close_tolerance_tbl(i),
                             p_message_name     => 'PO_PDOI_INV_CLOSE_TOLERANCE');
        x_result_type := po_validations.c_result_type_failure;
      END IF;
    END LOOP;

    IF po_log.d_proc THEN
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END invoice_close_tolerance;

-------------------------------------------------------------------------
-- If shipment_type is STANDARD and receive_close_tolerance is not null
-- and less than or equal to zero or greater than or equal to 100.
-------------------------------------------------------------------------
  PROCEDURE receive_close_tolerance(
    p_id_tbl                        IN              po_tbl_number,
    p_shipment_type_tbl             IN              po_tbl_varchar30,
    p_receive_close_tolerance_tbl   IN              po_tbl_number,
    x_results                       IN OUT NOCOPY   po_validation_results_type,
    x_result_type                   OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_receive_close_tolerance;
  BEGIN
    IF (x_results IS NULL) THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_shipment_type_tbl', p_shipment_type_tbl);
      po_log.proc_begin(d_mod, 'p_receive_close_tolerance_tbl', p_receive_close_tolerance_tbl);
      po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
    END IF;

    -- If shipment_type is STANDARD and receive_close_tolerance is not null
    -- and less than or equal to zero or greater than or equal to 100.
    FOR i IN 1 .. p_id_tbl.COUNT LOOP
      IF p_shipment_type_tbl(i) = 'STANDARD' AND
         p_receive_close_tolerance_tbl(i) IS NOT NULL AND
         (p_receive_close_tolerance_tbl(i) < 0 OR p_receive_close_tolerance_tbl(i) > 100) THEN
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'RECEIVE_CLOSE_TOLERANCE',
                             p_column_val       => p_receive_close_tolerance_tbl(i),
                             p_message_name     => 'PO_PDOI_RCT_CLOSE_TOLERANCE');
        x_result_type := po_validations.c_result_type_failure;
      END IF;
    END LOOP;

    IF po_log.d_proc THEN
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END receive_close_tolerance;

-------------------------------------------------------------------------
-- Validate that receiving routing id exists in rcv_routing_headers
-- <<PDOI Enhancement Bug#17063664>>
-- Validate that receiving routing id is 3 for FIXED PRICE / RATE
-------------------------------------------------------------------------
  PROCEDURE receiving_routing_id(
    p_id_tbl                     IN              po_tbl_number,
    p_shipment_type_tbl          IN              po_tbl_varchar30,
    p_receiving_routing_id_tbl   IN              po_tbl_number,
    p_order_type_lookup_tbl      IN              po_tbl_varchar30, -- <<PDOI Enhancement Bug#17063664>>
    x_result_set_id              IN OUT NOCOPY   NUMBER,
    x_result_type                OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_receiving_routing_id;
  BEGIN
    IF x_result_set_id IS NULL THEN
      x_result_set_id := po_validations.next_result_set_id();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_shipment_type_tbl', p_shipment_type_tbl);
      po_log.proc_begin(d_mod, 'p_receiving_routing_id_tbl', p_receiving_routing_id_tbl);
      po_log.proc_begin(d_mod, 'p_order_type_lookup_tbl', p_order_type_lookup_tbl);
      po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;

    -- Validate that receiving routing id exists in rcv_routing_headers
    FORALL i IN 1 .. p_id_tbl.COUNT
      INSERT INTO po_validation_results_gt
                  (result_set_id,
                   result_type,
                   entity_type,
                   entity_id,
                   message_name,
                   column_name,
                   column_val,
                   token1_name,
                   token1_value)
        SELECT x_result_set_id,
               po_validations.c_result_type_failure,
               'PO_LINE_LOCATIONS_INTERFACE',
               p_id_tbl(i),
               'PO_PDOI_INVALID_ROUTING_ID',
               'RECEIVING_ROUTING_ID',
               p_receiving_routing_id_tbl(i),
               'RECEIVING_ROUTING_ID',
               p_receiving_routing_id_tbl(i)
          FROM DUAL
         WHERE p_receiving_routing_id_tbl(i) IS NOT NULL
           AND p_shipment_type_tbl(i) = 'STANDARD'
           AND NOT EXISTS(SELECT 1
                            FROM rcv_routing_headers rrh
                           WHERE rrh.routing_header_id = p_receiving_routing_id_tbl(i));

    IF (SQL%ROWCOUNT > 0) THEN
      x_result_type := po_validations.c_result_type_failure;
    END IF;

    -- <<PDOI Enhancement Bug#17063664>>
    -- Validate that receiving routing id is 3 for FIXED PRICE / RATE
    FORALL i IN 1 .. p_id_tbl.COUNT
      INSERT INTO po_validation_results_gt
                  (result_set_id,
                   result_type,
                   entity_type,
                   entity_id,
                   message_name,
                   column_name,
                   column_val)
        SELECT x_result_set_id,
               po_validations.c_result_type_failure,
               'PO_LINE_LOCATIONS_INTERFACE',
               p_id_tbl(i),
               'PO_PDOI_RECV_ROUTING',
               'RECEIVING_ROUTING_ID',
               p_receiving_routing_id_tbl(i)
          FROM DUAL
         WHERE p_receiving_routing_id_tbl(i) <> 3
           AND p_shipment_type_tbl(i) = 'STANDARD'
           AND p_order_type_lookup_tbl(i) IN ('FIXED PRICE', 'RATE');

    IF (SQL%ROWCOUNT > 0) THEN
      x_result_type := po_validations.c_result_type_failure;
    END IF;

    IF po_log.d_proc THEN
      po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END receiving_routing_id;

-------------------------------------------------------------------------
-- Validate accrue_on_receipt_flag is Y or N, if not null.
-------------------------------------------------------------------------
  PROCEDURE accrue_on_receipt_flag(
    p_id_tbl                       IN              po_tbl_number,
    p_accrue_on_receipt_flag_tbl   IN              po_tbl_varchar1,
    x_results                      IN OUT NOCOPY   po_validation_results_type,
    x_result_type                  OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_accrue_on_receipt_flag;
  BEGIN
    IF (x_results IS NULL) THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_accrue_on_receipt_flag_tbl', p_accrue_on_receipt_flag_tbl);
      po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
    END IF;

    FOR i IN 1 .. p_id_tbl.COUNT LOOP
      IF (p_accrue_on_receipt_flag_tbl(i) IS NOT NULL AND p_accrue_on_receipt_flag_tbl(i) NOT IN('N', 'Y')) THEN
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'ACCRUE_ON_RECEIPT_FLAG',
                             p_column_val       => p_accrue_on_receipt_flag_tbl(i),
                             p_message_name     => 'PO_PDOI_INVALID_VALUE');
        x_result_type := po_validations.c_result_type_failure;
      END IF;
    END LOOP;

    IF po_log.d_proc THEN
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END accrue_on_receipt_flag;

  -------------------------------------------------------------------------
-- PDOI for Complex PO Project: Validate advance amount at shipment.
-------------------------------------------------------------------------
  PROCEDURE advance_amt_le_amt(
    p_id_tbl                        IN            PO_TBL_NUMBER,
    p_payment_type_tbl              IN            PO_TBL_VARCHAR30,
    p_advance_tbl                   IN            PO_TBL_NUMBER,
    p_amount_tbl                    IN            PO_TBL_NUMBER,
    p_quantity_tbl                  IN            PO_TBL_NUMBER,
    p_price_tbl                     IN            PO_TBL_NUMBER,
    x_results                       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
    x_result_type                   OUT NOCOPY    VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_advance_amt_le_amt;
  BEGIN
    IF (x_results IS NULL) THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_payment_type_tbl', p_payment_type_tbl);
      po_log.proc_begin(d_mod, 'p_advance_tbl', p_advance_tbl);
      po_log.proc_begin(d_mod, 'p_amount_tbl', p_amount_tbl);
      po_log.proc_begin(d_mod, 'p_quantity_tbl', p_quantity_tbl);
      po_log.proc_begin(d_mod, 'p_price_tbl', p_price_tbl);
      po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
    END IF;

    FOR i IN 1 .. p_id_tbl.COUNT LOOP
      IF (p_advance_tbl(i) IS NOT NULL AND Nvl(p_payment_type_tbl(i),'DELIVERY') = 'ADVANCE') THEN
        IF (p_advance_tbl(i) > nvl(p_amount_tbl(i), p_quantity_tbl(i) * p_price_tbl(i))) THEN
          x_results.add_result(
            p_entity_type => c_entity_type_line_location
          , p_entity_id => p_id_tbl(i)
          , p_column_name => 'AMOUNT'
          , p_column_val => p_advance_tbl(i)
          , p_message_name => PO_MESSAGE_S.PO_ADVANCE_GT_LINE_AMOUNT
          );
          x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
        END IF;
      END IF;
    END LOOP;

    IF po_log.d_proc THEN
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END advance_amt_le_amt;

-------------------------------------------------------------------------------------
-- Validate price_breaks_flag = Y for the given style
-------------------------------------------------------------------------------------
   PROCEDURE style_related_info(
      p_id_tbl                       IN              po_tbl_number,
      p_style_id_tbl                 IN              po_tbl_number,
      x_result_set_id                IN OUT NOCOPY   NUMBER,
      x_result_type                  OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_style_related_info;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_style_id_tbl', p_style_id_tbl);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      -- bug5262146
      -- Added NVL() around pdsh.price_breaks_flag

      FORALL i IN 1 .. p_id_tbl.COUNT
         INSERT INTO po_validation_results_gt
                     (result_set_id,
                      result_type,
                      entity_type,
                      entity_id,
                      message_name,
                      column_name,
                      column_val,
                      token1_name,
                      token1_value,
                      validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_line_location,
                   p_id_tbl(i),
                   'PO_PDOI_PRICE_BREAK_STYLE',
                   'STYLE_ID',
                   p_style_id_tbl(i),
                   'STYLE_ID',
                   p_style_id_tbl(i),
                   PO_VAL_CONSTANTS.c_loc_style_related_info
              FROM DUAL
             WHERE EXISTS(SELECT 1
                          FROM  po_doc_style_headers pdsh
                          WHERE pdsh.style_id = p_style_id_tbl(i) AND
                                NVL(pdsh.price_breaks_flag, 'N') = 'N');

    IF (SQL%ROWCOUNT > 0) THEN
      x_result_type := po_validations.c_result_type_failure;
    END IF;

    IF po_log.d_proc THEN
      po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;
      RAISE;

  END style_related_info;

-------------------------------------------------------------------------
-- tax_name must be valid if it is not null;
-- If tax_name and tax_code_id are both not null,
-- then tax_code_id and tax_name must be a valid combination in zx_id_tcc_mapping
-------------------------------------------------------------------------
   PROCEDURE tax_name(
      p_id_tbl            IN              po_tbl_number,
      p_tax_name_tbl      IN              po_tbl_varchar30,
      p_tax_code_id_tbl   IN              po_tbl_number,
      p_need_by_date_tbl  IN              po_tbl_date,
      p_allow_tax_code_override IN        VARCHAR2,
      p_operating_unit    IN              NUMBER,
      x_result_set_id     IN OUT NOCOPY   NUMBER,
      x_result_type       OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_tax_name;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_tax_code_id_tbl', p_tax_code_id_tbl);
         po_log.proc_begin(d_mod, 'p_tax_name_tbl', p_tax_name_tbl);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      -- Bug 4965755. Modified both queries to include -99 as valid orgs in zx
      -- tax_name must be valid if not null
      FORALL i IN 1 .. p_id_tbl.COUNT
         INSERT INTO po_validation_results_gt
                     (result_set_id,
                      result_type,
                      entity_type,
                      entity_id,
                      message_name,
                      column_name,
                      column_val,
                      token1_name,
                      token1_value,
                      validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_line_location,
                   p_id_tbl(i),
                   'PO_PDOI_INVALID_TAX_NAME',
                   'TAX_NAME',
                   p_tax_name_tbl(i),
                   'VALUE',
                   p_tax_name_tbl(i),
                   PO_VAL_CONSTANTS.c_tax_name
              FROM DUAL
             WHERE p_tax_name_tbl(i) IS NOT NULL
               AND p_tax_code_id_tbl(i) IS NULL
               AND NOT EXISTS(SELECT  'Y'
                              FROM  ZX_INPUT_CLASSIFICATIONS_V zicv
                              WHERE zicv.lookup_code = p_tax_name_tbl(i)
                              AND   zicv.org_id in (p_operating_unit, -99)
                              AND   zicv.enabled_flag = 'Y'
                              AND   NVL(p_need_by_date_tbl(i),SYSDATE) BETWEEN
                                    NVL(zicv.start_date_active, SYSDATE) AND
                                    COALESCE(zicv.end_date_active,
                                             p_need_by_date_tbl(i),
                                             SYSDATE)
                              AND   p_allow_tax_code_override = 'Y');

      IF (SQL%ROWCOUNT > 0) THEN
         x_result_type := po_validations.c_result_type_failure;
      END IF;

      -- tax_code_id and tax_name must be a valid combination in zx_id_tcc_mapping
      -- if both are not null
      FORALL i IN 1 .. p_id_tbl.COUNT
         INSERT INTO po_validation_results_gt
                     (result_set_id,
                      result_type,
                      entity_type,
                      entity_id,
                      message_name,
                      column_name,
                      column_val,
                      token1_name,
                      token1_value,
                      validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_line_location,
                   p_id_tbl(i),
                   'PO_PDOI_INVALID_TAX_NAME',
                   'TAX_NAME',
                   p_tax_name_tbl(i),
                   'VALUE',
                   p_tax_name_tbl(i),
                   PO_VAL_CONSTANTS.c_tax_name
              FROM DUAL
             WHERE p_tax_code_id_tbl(i) IS NOT NULL
               AND p_tax_name_tbl(i) IS NOT NULL
               AND NOT EXISTS(SELECT 'Y'
                              FROM ZX_ID_TCC_MAPPING
                              WHERE tax_rate_code_id = p_tax_code_id_tbl(i)
                              AND   tax_classification_code = p_tax_name_tbl(i)
                              AND   NVL(p_need_by_date_tbl(i),SYSDATE) BETWEEN
                                    NVL(effective_from, SYSDATE) AND
                                    COALESCE(effective_to,
                                             p_need_by_date_tbl(i),
                                             SYSDATE)
                              AND   tax_class = 'INPUT'
                              AND   org_id IN (p_operating_unit, -99)
                              AND   source = 'AP'
                              AND   active_flag = 'Y'
                              AND   p_allow_tax_code_override = 'Y');

      IF (SQL%ROWCOUNT > 0) THEN
         x_result_type := po_validations.c_result_type_failure;
      END IF;

      IF po_log.d_proc THEN
         po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END tax_name;

-------------------------------------------------------------------------
-- fob_lookup_code must be valid in PO_LOOKUP_CODES
-------------------------------------------------------------------------
   PROCEDURE fob_lookup_code(p_id_tbl                IN              po_tbl_number,
                             p_fob_lookup_code_tbl   IN              po_tbl_varchar30,
                             x_result_set_id         IN OUT NOCOPY   NUMBER,
                             x_result_type           OUT NOCOPY      VARCHAR2)
   IS
      d_mod CONSTANT VARCHAR2(100) := d_fob_lookup_code;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_fob_lookup_code_tbl', p_fob_lookup_code_tbl);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      -- fob_lookup_code must be valid if not null
      FORALL i IN 1 .. p_id_tbl.COUNT
         INSERT INTO po_validation_results_gt
                     (result_set_id,
                      result_type,
                      entity_type,
                      entity_id,
                      message_name,
                      column_name,
                      column_val,
                      token1_name,
                      token1_value,
					  validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_line_location,
                   p_id_tbl(i),
                   'PO_PDOI_INVALID_FOB',
                   'FOB_LOOKUP_CODE',
                   p_fob_lookup_code_tbl(i),
                   'VALUE',
                   p_fob_lookup_code_tbl(i),
                   PO_VAL_CONSTANTS.c_loc_fob_lookup_code
              FROM DUAL
             WHERE p_fob_lookup_code_tbl(i) IS NOT NULL
               AND NOT EXISTS(SELECT 1
                              FROM  PO_LOOKUP_CODES
                              WHERE lookup_type = 'FOB' AND
                                    sysdate < nvl(inactive_date, sysdate + 1) AND
                                    lookup_code = p_fob_lookup_code_tbl(i));

    IF (SQL%ROWCOUNT > 0) THEN
      x_result_type := po_validations.c_result_type_failure;
    END IF;

    IF po_log.d_proc THEN
      po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;
      RAISE;

  END fob_lookup_code;

-------------------------------------------------------------------------
-- freight_terms must be valid in PO_LOOKUP_CODES
-------------------------------------------------------------------------
   PROCEDURE freight_terms(p_id_tbl              IN              po_tbl_number,
                           p_freight_terms_tbl   IN              po_tbl_varchar30,
                           x_result_set_id       IN OUT NOCOPY   NUMBER,
                           x_result_type         OUT NOCOPY      VARCHAR2)
   IS
      d_mod CONSTANT VARCHAR2(100) := d_freight_terms;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_freight_terms_tbl', p_freight_terms_tbl);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      -- freight_terms must be valid if not null
      FORALL i IN 1 .. p_id_tbl.COUNT
         INSERT INTO po_validation_results_gt
                     (result_set_id,
                      result_type,
                      entity_type,
                      entity_id,
                      message_name,
                      column_name,
                      column_val,
                      token1_name,
                      token1_value,
					  validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_line_location,
                   p_id_tbl(i),
                   'PO_PDOI_INVALID_FREIGHT_TERMS',
                   'FREIGHT_TERMS',
                   p_freight_terms_tbl(i),
                   'VALUE',
                   p_freight_terms_tbl(i),
                   PO_VAL_CONSTANTS.c_loc_freight_terms
              FROM DUAL
             WHERE p_freight_terms_tbl(i) IS NOT NULL
               AND NOT EXISTS(SELECT 1
                              FROM  PO_LOOKUP_CODES
                              WHERE lookup_type = 'FREIGHT TERMS' AND
                                    sysdate < nvl(inactive_date, sysdate + 1) AND
                                    lookup_code = p_freight_terms_tbl(i));

    IF (SQL%ROWCOUNT > 0) THEN
      x_result_type := po_validations.c_result_type_failure;
    END IF;

    IF po_log.d_proc THEN
      po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;
      RAISE;

  END freight_terms;

-------------------------------------------------------------------------
-- freight_carrier must be valid in ORG_FREIGHT
-------------------------------------------------------------------------
   PROCEDURE freight_carrier(p_id_tbl                IN              po_tbl_number,
                             p_freight_carrier_tbl   IN              po_tbl_varchar30,
                             p_inventory_org_id      IN              NUMBER,
                             x_result_set_id         IN OUT NOCOPY   NUMBER,
                             x_result_type           OUT NOCOPY      VARCHAR2)
   IS
      d_mod CONSTANT VARCHAR2(100) := d_freight_carrier;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_freight_carrier_tbl', p_freight_carrier_tbl);
         po_log.proc_begin(d_mod, 'p_inventory_org_id', p_inventory_org_id);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      -- freight_carrier must be valid if not null
      FORALL i IN 1 .. p_id_tbl.COUNT
         INSERT INTO po_validation_results_gt
                     (result_set_id,
                      result_type,
                      entity_type,
                      entity_id,
                      message_name,
                      column_name,
                      column_val,
                      token1_name,
                      token1_value,
					  validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_line_location,
                   p_id_tbl(i),
                   'PO_PDOI_INVALID_FREIGHT_CARR',
                   'FREIGHT_CARRIER',
                   p_freight_carrier_tbl(i),
                   'VALUE',
                   p_freight_carrier_tbl(i),
                   PO_VAL_CONSTANTS.c_loc_freight_carrier
              FROM DUAL
             WHERE p_freight_carrier_tbl(i) IS NOT NULL
               AND NOT EXISTS(SELECT 1
                              FROM  ORG_FREIGHT
                              WHERE freight_code = p_freight_carrier_tbl(i) AND
                                    organization_id = p_inventory_org_id AND
                                    nvl(disable_date, sysdate + 1) > sysdate);

    IF (SQL%ROWCOUNT > 0) THEN
      x_result_type := po_validations.c_result_type_failure;
    END IF;

    IF po_log.d_proc THEN
      po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;
      RAISE;

  END freight_carrier;

-------------------------------------------------------------------------
-- Cannot create price breaks for Amount-Based or Fixed Price lines in a
-- Blanket Purchase Agreement.
-------------------------------------------------------------------------
  PROCEDURE price_break(
    p_id_tbl                       IN              po_tbl_number,
    p_order_type_lookup_code_tbl   IN              po_tbl_varchar30,
    x_results                      IN OUT NOCOPY   po_validation_results_type,
    x_result_type                  OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_price_break;
  BEGIN
    IF (x_results IS NULL) THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_order_type_lookup_code_tbl', p_order_type_lookup_code_tbl);
      po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
    END IF;

    FOR i IN 1 .. p_id_tbl.COUNT LOOP
      IF (p_order_type_lookup_code_tbl(i) IN ('AMOUNT', 'FIXED PRICE')) THEN
        x_results.add_result(p_entity_type      => c_entity_type_line_location,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => NULL,
                             p_column_val       => NULL,
                             p_message_name     => 'PO_PDOI_PRICE_BRK_AMT_BASED_LN',
                             p_validation_id    => PO_VAL_CONSTANTS.c_price_break_not_allowed);
        x_result_type := po_validations.c_result_type_failure;
      END IF;
    END LOOP;

    IF po_log.d_proc THEN
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END price_break;

-------------------------------------------------------------------------
-- <<PDOI Enhancement Bug#17063664>>
-- Validate that inspection_reqd_flag is N for Fixed Price and Rate based lines.
-------------------------------------------------------------------------
  PROCEDURE inspection_reqd_flag(
    p_id_tbl                     IN              po_tbl_number,
    p_shipment_type_tbl          IN              po_tbl_varchar30,
    p_inspection_reqd_flag_tbl   IN              po_tbl_varchar1,
    p_order_type_lookup_tbl      IN              po_tbl_varchar30,
    x_result_set_id              IN OUT NOCOPY   NUMBER,
    x_result_type                OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_inspection_reqd_flag;
  BEGIN
    IF x_result_set_id IS NULL THEN
      x_result_set_id := po_validations.next_result_set_id();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_shipment_type_tbl', p_shipment_type_tbl);
      po_log.proc_begin(d_mod, 'p_inspection_reqd_flag_tbl', p_inspection_reqd_flag_tbl);
      po_log.proc_begin(d_mod, 'p_order_type_lookup_tbl', p_order_type_lookup_tbl);
      po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;

    -- <<PDOI Enhancement Bug#17063664>>
    -- Validate that inspection required flag is N for FIXED PRICE / RATE
    FORALL i IN 1 .. p_id_tbl.COUNT
      INSERT INTO po_validation_results_gt
                  (result_set_id,
                   result_type,
                   entity_type,
                   entity_id,
                   message_name,
                   column_name,
                   column_val)
        SELECT x_result_set_id,
               po_validations.c_result_type_failure,
               'PO_LINE_LOCATIONS_INTERFACE',
               p_id_tbl(i),
               'PO_PDOI_INSP_REQ_N',
               'INSPECTION_REQUIRED_FLAG',
               p_inspection_reqd_flag_tbl(i)
          FROM DUAL
         WHERE NVL(p_inspection_reqd_flag_tbl(i),'Y') <> 'N'
           AND p_shipment_type_tbl(i) = 'STANDARD'
           AND p_order_type_lookup_tbl(i) IN ('FIXED PRICE', 'RATE');

    IF (SQL%ROWCOUNT > 0) THEN
      x_result_type := po_validations.c_result_type_failure;
    END IF;

    IF po_log.d_proc THEN
      po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END inspection_reqd_flag;

-------------------------------------------------------------------------
-- <<PDOI Enhancement Bug#17063664>>
-- Validate that days_late_rcpt_allowed is N for Fixed Price and Rate based lines.
-------------------------------------------------------------------------
  PROCEDURE days_late_rcpt_allowed(
    p_id_tbl                     IN              po_tbl_number,
    p_shipment_type_tbl          IN              po_tbl_varchar30,
    p_days_late_rcpt_allowed_tbl IN              po_tbl_number,
    p_order_type_lookup_tbl      IN              po_tbl_varchar30,
    x_result_set_id              IN OUT NOCOPY   NUMBER,
    x_result_type                OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_days_late_rcpt_allowed;
  BEGIN
    IF x_result_set_id IS NULL THEN
      x_result_set_id := po_validations.next_result_set_id();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_shipment_type_tbl', p_shipment_type_tbl);
      po_log.proc_begin(d_mod, 'p_days_late_rcpt_allowed_tbl', p_days_late_rcpt_allowed_tbl);
      po_log.proc_begin(d_mod, 'p_order_type_lookup_tbl', p_order_type_lookup_tbl);
      po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;

    -- <<PDOI Enhancement Bug#17063664>>
    -- Validate that days_late_rcpt_allowed is NULL for FIXED PRICE / RATE
    FORALL i IN 1 .. p_id_tbl.COUNT
      INSERT INTO po_validation_results_gt
                  (result_set_id,
                   result_type,
                   entity_type,
                   entity_id,
                   message_name,
                   column_name,
                   column_val,
                   token1_name,
                   token1_value,
                   token2_name,
                   token2_value)
        SELECT x_result_set_id,
               po_validations.c_result_type_failure,
               'PO_LINE_LOCATIONS_INTERFACE',
               p_id_tbl(i),
               'PO_PDOI_COLUMN_NOT_NULL',
               'DAYS_LATE_RECEIPT_ALLOWED',
               p_days_late_rcpt_allowed_tbl(i),
               'COLUMN_NAME',
               'DAYS_LATE_RECEIPT_ALLOWED',
               'VALUE',
               p_days_late_rcpt_allowed_tbl(i)
          FROM DUAL
         WHERE p_days_late_rcpt_allowed_tbl(i) IS NOT NULL
           AND p_shipment_type_tbl(i) = 'STANDARD'
           AND p_order_type_lookup_tbl(i) IN ('FIXED PRICE', 'RATE');

    IF (SQL%ROWCOUNT > 0) THEN
      x_result_type := po_validations.c_result_type_failure;
    END IF;

    IF po_log.d_proc THEN
      po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END days_late_rcpt_allowed;

END PO_VAL_SHIPMENTS2;

/
