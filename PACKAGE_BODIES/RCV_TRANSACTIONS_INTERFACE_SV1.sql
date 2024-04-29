--------------------------------------------------------
--  DDL for Package Body RCV_TRANSACTIONS_INTERFACE_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_TRANSACTIONS_INTERFACE_SV1" AS
/* $Header: RCVTIS2B.pls 120.0.12010000.11 2012/11/22 10:19:37 liayang ship $*/

-- Read the profile option that enables/disables the debug log
    g_asn_debug        VARCHAR2(1) := asn_debug.is_debug_on; -- Bug 9152790
    e_validation_error EXCEPTION;

/*===========================================================================

  PROCEDURE NAME: validate_quantity_shipped()

===========================================================================*/
    PROCEDURE validate_quantity_shipped(
        x_quantity_shipped_record IN OUT NOCOPY rcv_shipment_line_sv.quantity_shipped_record_type
    ) IS
        x_progress                VARCHAR2(3);
        x_available_qty           NUMBER      := 0;
        x_tolerable_qty           NUMBER      := 0;
        /* Bug# 1548597 */
        x_secondary_available_qty NUMBER      := 0;
        x_error_status            VARCHAR2(1);
    BEGIN
        x_error_status  := rcv_error_pkg.g_ret_sts_error;

        IF (x_quantity_shipped_record.quantity_shipped IS NULL) THEN
            rcv_error_pkg.set_error_message('RCV_ITEM_NO_SHIP_QTY');
            RAISE e_validation_error;
        END IF;

        IF (x_quantity_shipped_record.quantity_shipped < 0) THEN
            rcv_error_pkg.set_error_message('RCV_ITEM_SUBZERO_SHIP_QTY');
            RAISE e_validation_error;
        END IF;

        -- get the tolerable quantity first
        /* Bug# 1548597 */
        rcv_quantities_s.get_available_quantity('RECEIVE',
                                                x_quantity_shipped_record.po_line_location_id,
                                                'VENDOR',
                                                NULL,
                                                NULL,
                                                NULL,
                                                x_available_qty,
                                                x_tolerable_qty,
                                                x_quantity_shipped_record.unit_of_measure,
                                                x_secondary_available_qty
                                               );

        IF (x_quantity_shipped_record.quantity_shipped > x_tolerable_qty) THEN
            x_error_status  := rcv_error_pkg.g_ret_sts_warning;
            rcv_error_pkg.set_error_message('RCV_ALL_QTY_OVER_TOLERANCE');
            RAISE e_validation_error;
        END IF;
    EXCEPTION
        WHEN e_validation_error THEN
            x_quantity_shipped_record.error_record.error_status   := x_error_status;
            x_quantity_shipped_record.error_record.error_message  := rcv_error_pkg.get_last_message;

            IF x_quantity_shipped_record.error_record.error_message = 'RCV_ITEM_NO_SHIP_QTY' THEN
                rcv_error_pkg.set_token('ITEM', x_quantity_shipped_record.item_id);
            ELSIF x_quantity_shipped_record.error_record.error_message = 'RCV_ITEM_SUBZERO_SHIP_QTY' THEN
                rcv_error_pkg.set_token('QTY_SHIPPED', x_quantity_shipped_record.quantity_shipped);
            ELSIF x_quantity_shipped_record.error_record.error_message = 'RCV_ALL_QTY_OVER_TOLERANCE' THEN
                rcv_error_pkg.set_token('QTY_A', x_quantity_shipped_record.quantity_shipped);
                rcv_error_pkg.set_token('QTY_B', x_tolerable_qty);
            END IF;
    END validate_quantity_shipped;

/*===========================================================================

  PROCEDURE NAME: validate_expected_receipt_date()

===========================================================================*/
    PROCEDURE validate_expected_receipt_date(
        x_expected_receipt_rec IN OUT NOCOPY rcv_shipment_line_sv.expected_receipt_record_type
    ) IS
        x_progress     VARCHAR2(3);
        x_error_status VARCHAR2(1);
    BEGIN
        x_error_status  := rcv_error_pkg.g_ret_sts_error;

        -- in RCVTXDAB.pls
        IF NOT(rcv_dates_s.val_receipt_date_tolerance(x_expected_receipt_rec.line_location_id, x_expected_receipt_rec.expected_receipt_date)) THEN
            x_error_status  := rcv_error_pkg.g_ret_sts_warning;
            rcv_error_pkg.set_error_message('RCV_ASN_DATE_OUT_TOL');
            RAISE e_validation_error;
        END IF;
    EXCEPTION
        WHEN e_validation_error THEN
            x_expected_receipt_rec.error_record.error_status   := x_error_status;
            x_expected_receipt_rec.error_record.error_message  := rcv_error_pkg.get_last_message;

            IF x_expected_receipt_rec.error_record.error_message = 'RCV_ASN_DATE_OUT_TOL' THEN
                rcv_error_pkg.set_token('DELIVERY DATE', x_expected_receipt_rec.expected_receipt_date);
            END IF;
    END validate_expected_receipt_date;

/*===========================================================================

  PROCEDURE NAME: validate_quantity_invoiced (ASBN only)

===========================================================================*/
    PROCEDURE validate_quantity_invoiced(
        x_quantity_invoiced_record IN OUT NOCOPY rcv_shipment_line_sv.quantity_invoiced_record_type
    ) IS
        x_progress     VARCHAR2(3);
        x_error_status VARCHAR2(1);
    BEGIN
        x_error_status  := rcv_error_pkg.g_ret_sts_error;

        IF (x_quantity_invoiced_record.quantity_invoiced < 0) THEN
            rcv_error_pkg.set_error_message('RCV_ITEM_INVOICE_QTY');
            RAISE e_validation_error;
        END IF;
    EXCEPTION
        WHEN e_validation_error THEN
            x_quantity_invoiced_record.error_record.error_status   := x_error_status;
            x_quantity_invoiced_record.error_record.error_message  := rcv_error_pkg.get_last_message;

            IF x_quantity_invoiced_record.error_record.error_message = 'RCV_ITEM_INVOICE_QTY' THEN
                NULL;
            END IF;
    END validate_quantity_invoiced;

/*===========================================================================

  PROCEDURE NAME: validate_uom()

===========================================================================*/
    PROCEDURE validate_uom(
        x_uom_record IN OUT NOCOPY rcv_shipment_line_sv.quantity_shipped_record_type
    ) IS
        x_unit_of_measure             rcv_transactions_interface.unit_of_measure%TYPE   := NULL;
        x_unit_meas_lookup_code_lines po_lines.unit_meas_lookup_code%TYPE               := NULL;
        x_progress                    VARCHAR2(3);
        x_new_conversion              NUMBER                                            := 0;
        x_cum_enabled                 chv_org_options.enable_cum_flag%TYPE              := NULL;
        x_supply_agreement_flag       po_headers.supply_agreement_flag%TYPE             := NULL;
--  x_asl_uom        chv_cum_period_items.purchasing_unit_of_measure%type := null;
        x_asl_uom                     VARCHAR2(80)                                      := NULL;
        x_primary_unit_of_measure     mtl_system_items.primary_unit_of_measure%TYPE     := NULL;
        x_error_status                VARCHAR2(1);
    BEGIN
        -- check that the uom is valid
        x_error_status  := rcv_error_pkg.g_ret_sts_error;

        SELECT NVL(MAX(unit_of_measure), 'notfound')
        INTO   x_unit_of_measure
        FROM   mtl_units_of_measure
        WHERE  unit_of_measure = x_uom_record.unit_of_measure;

        IF (x_unit_of_measure = 'notfound') THEN
            rcv_error_pkg.set_error_message('PO_PDOI_INVALID_UOM_CODE');
            RAISE e_validation_error;
        END IF;

        -- check that system date is less than the disabled_date

        IF (NOT(po_uom_s.val_unit_of_measure(x_uom_record.unit_of_measure))) THEN
            rcv_error_pkg.set_error_message('PO_PDOI_INVALID_UOM_CODE');
            RAISE e_validation_error;
        END IF;

        -- one-time purchase item

        IF (x_uom_record.item_id IS NOT NULL) THEN
            -- must have a primary uom at this point since the first select stmt succeeded

            SELECT primary_unit_of_measure
            INTO   x_primary_unit_of_measure
            FROM   mtl_system_items_kfv
            WHERE  inventory_item_id = x_uom_record.item_id
            AND    organization_id = NVL(x_uom_record.to_organization_id, organization_id); -- Raj added as org_id is part of uk

            IF (NVL(x_uom_record.primary_unit_of_measure, x_primary_unit_of_measure) <> x_primary_unit_of_measure) THEN
                x_uom_record.error_record.error_status  := 'W';
                rcv_error_pkg.set_error_message('RCV_UOM_NOT_PRIMARY');
                RAISE e_validation_error;
            END IF;

            x_new_conversion  := 0;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line(TO_CHAR(x_uom_record.quantity_shipped));
                asn_debug.put_line(x_uom_record.unit_of_measure);
                asn_debug.put_line(TO_CHAR(x_uom_record.item_id));
                asn_debug.put_line(x_primary_unit_of_measure);
                asn_debug.put_line(x_uom_record.primary_unit_of_measure);
            END IF;

            po_uom_s.uom_convert(x_uom_record.quantity_shipped,
                                 x_uom_record.unit_of_measure,
                                 x_uom_record.item_id,
                                 x_primary_unit_of_measure,
                                 x_new_conversion
                                );

            IF (x_new_conversion = 0) THEN
                rcv_error_pkg.set_error_message('RCV_UOM_NO_CONV_PRIMARY');
                RAISE e_validation_error;
            ELSIF(x_new_conversion <> x_uom_record.primary_quantity) THEN
                rcv_error_pkg.set_error_message('RCV_QTY_NOT_PRIMARY');
                RAISE e_validation_error;
            END IF;
        END IF;

        SELECT NVL(MAX(unit_meas_lookup_code), 'notfound')
        INTO   x_unit_meas_lookup_code_lines
        FROM   po_lines
        WHERE  po_line_id = x_uom_record.po_line_id;

        IF     (x_unit_meas_lookup_code_lines <> 'notfound')
           AND (x_unit_meas_lookup_code_lines <> x_uom_record.unit_of_measure) THEN
            x_new_conversion  := 0;
            po_uom_s.uom_convert(x_uom_record.quantity_shipped,
                                 x_uom_record.unit_of_measure,
                                 x_uom_record.item_id,
                                 x_unit_meas_lookup_code_lines,
                                 x_new_conversion
                                );

            IF (x_new_conversion = 0) THEN
                rcv_error_pkg.set_error_message('RCV_UOM_NO_CONV_PO');
                RAISE e_validation_error;
            END IF;
        END IF;

        SELECT NVL(MAX(enable_cum_flag), 'F')
        INTO   x_cum_enabled
        FROM   chv_org_options
        WHERE  organization_id = NVL(x_uom_record.to_organization_id, organization_id);

        SELECT NVL(MAX(supply_agreement_flag), 'N')
        INTO   x_supply_agreement_flag
        FROM   po_headers
        WHERE  po_header_id = x_uom_record.po_header_id
        AND    type_lookup_code = 'BLANKET'
        AND    supply_agreement_flag = 'Y';

        IF (    x_cum_enabled = 'Y'
            AND x_supply_agreement_flag = 'Y') THEN
            SELECT NVL(MAX(NULL), 'notfound') -- purchasing_unit_of_measure doesn't exist!!
            INTO   x_asl_uom
            FROM   chv_cum_period_items
            WHERE  organization_id = NVL(x_uom_record.to_organization_id, organization_id);

            IF (x_asl_uom <> 'notfound') THEN
                x_new_conversion  := 0;
                po_uom_s.uom_convert(x_uom_record.quantity_shipped,
                                     x_uom_record.unit_of_measure,
                                     x_uom_record.item_id,
                                     x_asl_uom,
                                     x_new_conversion
                                    );

                IF (x_new_conversion = 0) THEN
                    rcv_error_pkg.set_error_message('RCV_UOM_NO_CONV_ASL');
                    RAISE e_validation_error;
                END IF;
            END IF;
        END IF;
    EXCEPTION
        WHEN e_validation_error THEN
            x_uom_record.error_record.error_status   := x_error_status;
            x_uom_record.error_record.error_message  := rcv_error_pkg.get_last_message;

            IF x_uom_record.error_record.error_message = 'PO_PDOI_INVALID_UOM_CODE' THEN
                rcv_error_pkg.set_token('VALUE', x_uom_record.unit_of_measure);
            ELSIF x_uom_record.error_record.error_message = 'RCV_UOM_NOT_PRIMARY' THEN
                NULL;
            ELSIF x_uom_record.error_record.error_message = 'RCV_UOM_NO_CONV_PRIMARY' THEN
                rcv_error_pkg.set_token('SHIPMENT_UNIT', x_uom_record.unit_of_measure);
                rcv_error_pkg.set_token('PRIMARY_UNIT', x_primary_unit_of_measure);
            ELSIF x_uom_record.error_record.error_message = 'RCV_QTY_NOT_PRIMARY' THEN
                NULL;
            ELSIF x_uom_record.error_record.error_message = 'RCV_UOM_NO_CONV_PO' THEN
                rcv_error_pkg.set_token('SHIPMENT_UNIT', x_uom_record.unit_of_measure);
                rcv_error_pkg.set_token('PO_UNIT', x_unit_meas_lookup_code_lines);
            ELSIF x_uom_record.error_record.error_message = 'RCV_UOM_NO_CONV_ASL' THEN
                rcv_error_pkg.set_token('UNIT', x_uom_record.unit_of_measure);
            END IF;
    END validate_uom;

/*===========================================================================

  PROCEDURE NAME: validate_item()

===========================================================================*/
    PROCEDURE validate_item(
        x_item_id_record     IN OUT NOCOPY rcv_shipment_line_sv.item_id_record_type,
        x_auto_transact_code IN            rcv_transactions_interface.auto_transact_code%TYPE
    ) IS -- bug 608353
        x_progress        VARCHAR2(3);
        x_inventory_item  mtl_system_items.inventory_item_id%TYPE   := NULL;
        x_organization_id mtl_system_items.organization_id%TYPE     := NULL;
        x_item_id_po      po_lines.item_id%TYPE                     := NULL;
        x_error_status    VARCHAR2(1);
    BEGIN
        x_error_status  := rcv_error_pkg.g_ret_sts_error;

        SELECT NVL(MAX(inventory_item_id), -9999)
        INTO   x_inventory_item
        FROM   mtl_system_items
        WHERE  inventory_item_id = x_item_id_record.item_id;

        IF (x_inventory_item = -9999) THEN
            rcv_error_pkg.set_error_message('RCV_ITEM_ID');
            RAISE e_validation_error;
        END IF;

        SELECT NVL(MAX(inventory_item_id), -9999)
        INTO   x_inventory_item
        FROM   mtl_system_items
        WHERE  SYSDATE BETWEEN NVL(start_date_active, SYSDATE - 1) AND NVL(end_date_active, SYSDATE + 1)
        AND    inventory_item_id = x_item_id_record.item_id;

        IF (x_inventory_item = -9999) THEN
            rcv_error_pkg.set_error_message('RCV_ITEM_NOT_ACTIVE');
            RAISE e_validation_error;
        END IF;

        /* Bug 2160314.
          * We used to have nvl(max(organization_id),0) here before. But if the
          * organization_id is itself 0, then this will give us a problem in
          * the next step when we check if  x_organization_id = 0. So changed
          * the statement to nvl(max(organization_id),-9999) and also the
          * check below. Similarly changed the select statement and the
          * check for nvl(max(item_id),0).
         */
        SELECT NVL(MAX(organization_id), -9999)
        INTO   x_organization_id
        FROM   mtl_system_items
        WHERE  inventory_item_id = x_item_id_record.item_id
        AND    organization_id = NVL(x_item_id_record.to_organization_id, organization_id);

        IF (x_organization_id = -9999) THEN
            rcv_error_pkg.set_error_message('RCV_ITEM_NOT_IN_ORG');
            RAISE e_validation_error;
        END IF;

        SELECT NVL(MAX(item_id), -9999)
        INTO   x_item_id_po
        FROM   po_lines
        WHERE  po_line_id = x_item_id_record.po_line_id
        AND    item_id = x_item_id_record.item_id;

        IF (x_item_id_po = -9999) THEN
            rcv_error_pkg.set_error_message('RCV_ITEM_NOT_ON_PO');
            RAISE e_validation_error;
        END IF;

        /* Bug 2898324 The non-purchasable items were allowed to be
           received thru ROI. The validation on purchasable flag
           is not based on the receving org. Added a filter condition
           based on organization id.
            */

        /* Fix for bug 2989299.
           Commenting the following sql as we should not validate an item
           based on it's purchasing flags at the time of receipt creation.
           Only at the time of creating the Purchase Order this flag has
           to be checked upon. Please see bug 2706571 for more details.
           For the time being we are not checking on item's stockable flag
           thru ROI. If required we will incorporate later.
        */
        SELECT NVL(MAX(item_id), -9999)
        INTO   x_item_id_po
        FROM   po_lines
        WHERE  po_line_id = x_item_id_record.po_line_id
        AND    item_id = x_item_id_record.item_id;

        IF (x_item_id_po <> x_item_id_record.item_id) THEN
            rcv_error_pkg.set_error_message('RCV_NOT_PO_LINE_NUM');
            RAISE e_validation_error;
        END IF;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Validating Item: ' || x_auto_transact_code);
            asn_debug.put_line('Validating Item: ' || x_item_id_record.use_mtl_lot);
            asn_debug.put_line('Validating Item: ' || x_item_id_record.use_mtl_serial);
        END IF;
    EXCEPTION
        WHEN e_validation_error THEN
            x_item_id_record.error_record.error_status   := x_error_status;
            x_item_id_record.error_record.error_message  := rcv_error_pkg.get_last_message;

            IF x_item_id_record.error_record.error_message = 'RCV_ITEM_ID' THEN
                rcv_error_pkg.set_token('ITEM', x_item_id_record.item_id);
            ELSIF x_item_id_record.error_record.error_message = 'RCV_ITEM_NOT_ACTIVE' THEN
                rcv_error_pkg.set_token('ITEM', x_item_id_record.item_id);
            ELSIF x_item_id_record.error_record.error_message = 'RCV_UOM_NO_CONV_PRIMARY' THEN
                rcv_error_pkg.set_token('ITEM', x_item_id_record.item_id);
                rcv_error_pkg.set_token('ORGANIZATION', x_item_id_record.to_organization_id);
            ELSIF x_item_id_record.error_record.error_message = 'RCV_ITEM_NOT_ON_PO' THEN
                rcv_error_pkg.set_token('ITEM', x_item_id_record.item_id);
                rcv_error_pkg.set_token('PO_NUMBER', x_item_id_record.po_line_id);
            ELSIF x_item_id_record.error_record.error_message = 'RCV_NOT_PO_LINE_NUM' THEN
                rcv_error_pkg.set_token('PO_ITEM', x_item_id_po);
                rcv_error_pkg.set_token('SHIPMENT_ITEM', x_item_id_record.item_id);
            END IF;
    END validate_item;

/*===========================================================================

  PROCEDURE NAME: validate_item_description()

===========================================================================*/
    PROCEDURE validate_item_description(
        x_item_id_record IN OUT NOCOPY rcv_shipment_line_sv.item_id_record_type
    ) IS
        x_progress     VARCHAR2(3);
        x_error_status VARCHAR2(1);
    BEGIN
        x_error_status  := rcv_error_pkg.g_ret_sts_error;

        IF (x_item_id_record.item_description IS NULL) THEN
            rcv_error_pkg.set_error_message('RCV_ITEM_NO_DESCRIPTION');
            RAISE e_validation_error;
        END IF;
    EXCEPTION
        WHEN e_validation_error THEN
            x_item_id_record.error_record.error_status   := x_error_status;
            x_item_id_record.error_record.error_message  := rcv_error_pkg.get_last_message;

            IF x_item_id_record.error_record.error_message = 'RCV_ITEM_NO_DESCRIPTION' THEN
                rcv_error_pkg.set_token('ITEM', x_item_id_record.item_id);
            END IF;
    END validate_item_description;

/*===========================================================================

  PROCEDURE NAME: validate_substitute_item()

===========================================================================*/
    PROCEDURE validate_substitute_item(
        x_sub_item_id_record IN OUT NOCOPY rcv_shipment_line_sv.sub_item_id_record_type
    ) IS
        x_inventory_item mtl_system_items.inventory_item_id%TYPE   := NULL;
        x_progress       VARCHAR2(3);
        x_vendor_id      po_vendors.vendor_id%TYPE                 := NULL;
        x_error_status   VARCHAR2(1);
    BEGIN
        x_error_status  := rcv_error_pkg.g_ret_sts_error;

        SELECT NVL(MAX(inventory_item_id), 0)
        INTO   x_inventory_item
        FROM   mtl_system_items
        WHERE  inventory_item_id = x_sub_item_id_record.substitute_item_id
        AND    organization_id = NVL(x_sub_item_id_record.to_organization_id, organization_id);

        IF (x_inventory_item = 0) THEN
            rcv_error_pkg.set_error_message('RCV_ITEM_SUB_ID');
            RAISE e_validation_error;
        END IF;

        SELECT NVL(MAX(inventory_item_id), 0)
        INTO   x_inventory_item
        FROM   mtl_system_items
        WHERE  SYSDATE BETWEEN NVL(start_date_active, SYSDATE - 1) AND NVL(end_date_active, SYSDATE + 1)
        AND    inventory_item_id = x_sub_item_id_record.substitute_item_id
        AND    organization_id = NVL(x_sub_item_id_record.to_organization_id, organization_id);

        IF (x_inventory_item = 0) THEN
            rcv_error_pkg.set_error_message('RCV_ITEM_SUB_NOT_ACTIVE');
            RAISE e_validation_error;
        END IF;

/* Bug 3009663- Commented the check on allow_substitute_receipts_flag at the item level.
  only the value at PO shipments need to be checked instead of the values at the item
  level or the supplier level. */
        SELECT NVL(MAX(inventory_item_id), 0)
        INTO   x_inventory_item
        FROM   mtl_system_items
        WHERE  inventory_item_id = x_sub_item_id_record.substitute_item_id
        AND    organization_id = NVL(x_sub_item_id_record.to_organization_id, organization_id);

        IF (x_inventory_item = 0) THEN
            rcv_error_pkg.set_error_message('RCV_ITEM_SUB_NOT_IN_ORG');
            RAISE e_validation_error;
        END IF;

        SELECT NVL(MAX(inventory_item_id), 0)
        INTO   x_inventory_item
        FROM   mtl_system_items
        WHERE  inventory_item_id = x_sub_item_id_record.substitute_item_id
        AND    organization_id = NVL(x_sub_item_id_record.to_organization_id, organization_id)
        AND    purchasing_item_flag = 'Y';

        IF (x_inventory_item = 0) THEN
            rcv_error_pkg.set_error_message('RCV_ITEM_SUB_NOT_PO_ENABLED');
            RAISE e_validation_error;
        END IF;

        SELECT NVL(MAX(inventory_item_id), 0)
        INTO   x_inventory_item
        FROM   mtl_system_items
        WHERE  inventory_item_id = x_sub_item_id_record.substitute_item_id
        AND    organization_id = NVL(x_sub_item_id_record.to_organization_id, organization_id)
        AND    purchasing_enabled_flag = 'Y';

        IF (x_inventory_item = 0) THEN
            rcv_error_pkg.set_error_message('RCV_ITEM_SUB_NOT_PO_ENABLED');
            RAISE e_validation_error;
        END IF;

        /* Bug 3009663- Commented the check on the allow_substitute_receipt flag at the supplier level */

        -- Need to check for related items if reciprocal_flag is set
        -- Thus need to use union as user may not have set up both
        -- the items to substitute for each other and just used
        -- reciprocal_flag for this
        -- relationship_type_id = 2 for substitute items
        --                      = 1 for related items

        SELECT NVL(MAX(inventory_item_id), 0)
        INTO   x_inventory_item
        FROM   mtl_related_items
        WHERE  inventory_item_id = (SELECT item_id
                                    FROM   po_lines
                                    WHERE  po_line_id = x_sub_item_id_record.po_line_id)
        AND    related_item_id = x_sub_item_id_record.substitute_item_id
        AND    relationship_type_id = 2; -- substitute items
                                         -- and organization_id = nvl(x_sub_item_id_record.to_organization_id,organization_id)

        IF x_inventory_item = 0 THEN
            -- Try the reciprocal relationship

            SELECT NVL(MAX(inventory_item_id), 0)
            INTO   x_inventory_item
            FROM   mtl_related_items
            WHERE  related_item_id = (SELECT item_id
                                      FROM   po_lines
                                      WHERE  po_line_id = x_sub_item_id_record.po_line_id)
            AND    inventory_item_id = x_sub_item_id_record.substitute_item_id
            AND    reciprocal_flag = 'Y'
            AND    relationship_type_id = 2;
        -- and    organization_id = nvl(x_sub_item_id_record.to_organization_id,organization_id)

        END IF;

        IF (x_inventory_item = 0) THEN
            rcv_error_pkg.set_error_message('RCV_ITEM_SUB_NOT_RELATED');
            RAISE e_validation_error;
        END IF;
    EXCEPTION
        WHEN e_validation_error THEN
            x_sub_item_id_record.error_record.error_status   := x_error_status;
            x_sub_item_id_record.error_record.error_message  := rcv_error_pkg.get_last_message;

            IF x_sub_item_id_record.error_record.error_message = 'RCV_ITEM_SUB_ID' THEN
                rcv_error_pkg.set_token('ITEM', x_sub_item_id_record.substitute_item_id);
            ELSIF x_sub_item_id_record.error_record.error_message = 'RCV_ITEM_SUB_NOT_ACTIVE' THEN
                rcv_error_pkg.set_token('ITEM', x_sub_item_id_record.substitute_item_id);
            ELSIF x_sub_item_id_record.error_record.error_message = 'RCV_ITEM_SUB_NOT_ALLOWED' THEN
                rcv_error_pkg.set_token('ITEM', x_sub_item_id_record.substitute_item_id);
            ELSIF x_sub_item_id_record.error_record.error_message = 'RCV_ITEM_SUB_NOT_IN_ORG' THEN
                rcv_error_pkg.set_token('ITEM', x_sub_item_id_record.substitute_item_id);
                rcv_error_pkg.set_token('ORGANIZATION', x_sub_item_id_record.to_organization_id);
            ELSIF x_sub_item_id_record.error_record.error_message = 'RCV_ITEM_SUB_VEN_NOT_ALLOWED' THEN
                rcv_error_pkg.set_token('ITEM', x_sub_item_id_record.substitute_item_id);
                rcv_error_pkg.set_token('SUPPLIER', x_sub_item_id_record.vendor_id);
            ELSIF x_sub_item_id_record.error_record.error_message = 'RCV_ITEM_SUB_NOT_PO_ENABLED' THEN
                rcv_error_pkg.set_token('ITEM', x_sub_item_id_record.substitute_item_id);
            ELSIF x_sub_item_id_record.error_record.error_message = 'RCV_ITEM_SUB_NOT_RELATED' THEN
                rcv_error_pkg.set_token('SUB_ITEM', x_sub_item_id_record.substitute_item_id);
                rcv_error_pkg.set_token('ITEM', x_inventory_item);
            END IF;
    END validate_substitute_item;

/*===========================================================================

  PROCEDURE NAME: validate_item_revision()

===========================================================================*/
    PROCEDURE validate_item_revision(
        x_item_revision_record IN OUT NOCOPY rcv_shipment_line_sv.item_id_record_type
    ) IS
        x_inventory_item        mtl_system_items.inventory_item_id%TYPE   := NULL;
        x_progress              VARCHAR2(3);
        x_revision_control_flag VARCHAR2(1);
        x_error_status          VARCHAR2(1);
    BEGIN
        x_error_status  := rcv_error_pkg.g_ret_sts_error;

        -- check whether the item is under revision control
        -- If it is not then item should not have any revisions

        SELECT DECODE(msi.revision_qty_control_code,
                      1, 'N',
                      2, 'Y',
                      'N'
                     )
        INTO   x_revision_control_flag
        FROM   mtl_system_items msi
        WHERE  inventory_item_id = x_item_revision_record.item_id
        AND    organization_id = x_item_revision_record.to_organization_id;

        IF x_revision_control_flag = 'N' THEN
/*  Bug 1913887 : Check if the item is Non-revision controlled
    and the revision entered matches with the one in PO, then
    return without any error, else return with error
*/
            SELECT NVL(MAX(po_line_id), 0)
            INTO   x_inventory_item
            FROM   po_lines
            WHERE  po_line_id = x_item_revision_record.po_line_id
            AND    NVL(item_revision, x_item_revision_record.item_revision) = x_item_revision_record.item_revision;

            IF (x_inventory_item <> 0) THEN
                RETURN;
            END IF;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Item is not under revision control');
            END IF;

            rcv_error_pkg.set_error_message('RCV_ITEM_REV_NOT_ALLOWED');
            RAISE e_validation_error;
        END IF;

        -- Check whether the revision number exists

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Revision number :  ' || x_item_revision_record.item_revision);
        END IF;

        SELECT NVL(MAX(inventory_item_id), 0)
        INTO   x_inventory_item
        FROM   mtl_item_revisions
        WHERE  inventory_item_id = x_item_revision_record.item_id
        AND    organization_id = NVL(x_item_revision_record.to_organization_id, organization_id)
        AND    revision = x_item_revision_record.item_revision;

        IF (x_inventory_item = 0) THEN
            rcv_error_pkg.set_error_message('PO_RI_INVALID_ITEM_REVISION');
            RAISE e_validation_error;
        END IF;

        -- Check whether revision is still active

        SELECT NVL(MAX(inventory_item_id), 0) -- does this accurately check for active revisions??
        INTO   x_inventory_item
        FROM   mtl_item_revisions_org_val_v mir
        WHERE  mir.inventory_item_id = x_item_revision_record.item_id
        AND    mir.organization_id = NVL(x_item_revision_record.to_organization_id, mir.organization_id)
        AND    mir.revision = x_item_revision_record.item_revision;

        IF (x_inventory_item = 0) THEN
            rcv_error_pkg.set_error_message('PO_RI_INVALID_ITEM_REVISION');
            RAISE e_validation_error;
        END IF;

        -- Check whether po_revision matches this revision if po_revision is not null

        SELECT NVL(MAX(po_line_id), 0)
        INTO   x_inventory_item
        FROM   po_lines
        WHERE  po_line_id = x_item_revision_record.po_line_id
        AND    NVL(item_revision, x_item_revision_record.item_revision) = x_item_revision_record.item_revision;

        IF (x_inventory_item = 0) THEN
            x_error_status  := rcv_error_pkg.g_ret_sts_warning;
            rcv_error_pkg.set_error_message('RCV_NOT_PO_REVISION');
            RAISE e_validation_error;
        END IF;
    EXCEPTION
        WHEN e_validation_error THEN
            x_item_revision_record.error_record.error_status   := x_error_status;
            x_item_revision_record.error_record.error_message  := rcv_error_pkg.get_last_message;

            IF x_item_revision_record.error_record.error_message = 'RCV_ITEM_REV_NOT_ALLOWED' THEN
                rcv_error_pkg.set_token('ITEM', x_item_revision_record.item_id);
            ELSIF x_item_revision_record.error_record.error_message = 'PO_RI_INVALID_ITEM_REVISION' THEN
                NULL;
            ELSIF x_item_revision_record.error_record.error_message = 'RCV_NOT_PO_REVISION' THEN
                rcv_error_pkg.set_token('PO_REV', '');
                rcv_error_pkg.set_token('SHIPMENT_REV', x_item_revision_record.item_revision);
            END IF;
    END validate_item_revision;

/*===========================================================================

  PROCEDURE NAME: validate_ref_integ()

===========================================================================*/
    PROCEDURE validate_ref_integ(
        x_ref_integrity_rec IN OUT NOCOPY rcv_shipment_line_sv.ref_integrity_record_type,
        v_header_record     IN            rcv_shipment_header_sv.headerrectype
    ) IS
        x_po_vendor_id      po_headers.vendor_id%TYPE        := NULL;
        x_po_line_id        po_lines.po_line_id%TYPE;
        x_po_vendor_site_id po_headers.vendor_site_id%TYPE   := NULL;
        x_progress          VARCHAR2(3);
        x_error_status      VARCHAR2(1);
    BEGIN
        x_error_status  := rcv_error_pkg.g_ret_sts_error;

        IF (x_ref_integrity_rec.vendor_item_num IS NOT NULL) THEN
            SELECT NVL(MAX(po_line_id), 0)
            INTO   x_po_line_id
            FROM   po_lines
            WHERE  po_line_id = x_ref_integrity_rec.po_line_id
            AND    vendor_product_num = x_ref_integrity_rec.vendor_item_num;

            IF (x_po_line_id = 0) THEN
                rcv_error_pkg.set_error_message('RCV_NOT_PO_VEN_ITEM');
                RAISE e_validation_error;
            END IF;
        END IF;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Validating vendor id in PO ' || TO_CHAR(x_ref_integrity_rec.vendor_id));
            asn_debug.put_line('PO Header Id ' || TO_CHAR(x_ref_integrity_rec.po_header_id));
        END IF;

        IF x_ref_integrity_rec.vendor_id IS NOT NULL THEN
            SELECT NVL(MAX(vendor_id), 0)
            INTO   x_po_vendor_id
            FROM   po_headers
            WHERE  po_header_id = x_ref_integrity_rec.po_header_id
            AND    vendor_id = x_ref_integrity_rec.vendor_id;

            IF (x_po_vendor_id = 0) THEN
                rcv_error_pkg.set_error_message('RCV_NOT_PO_VEN');
                RAISE e_validation_error;
            END IF;
        END IF;

        -- Check for header.vendor = lines.vendor

        IF v_header_record.header_record.vendor_id IS NOT NULL THEN
            IF v_header_record.header_record.vendor_id <> NVL(x_ref_integrity_rec.vendor_id, v_header_record.header_record.vendor_id) THEN
                rcv_error_pkg.set_error_message('RCV_ERC_MISMATCH_PO_VENDOR');
                RAISE e_validation_error;
            END IF;
        END IF;

        IF x_ref_integrity_rec.vendor_site_id IS NOT NULL THEN
            SELECT NVL(MAX(vendor_site_id), 0)
            INTO   x_po_vendor_site_id
            FROM   po_headers
            WHERE  po_header_id = x_ref_integrity_rec.po_header_id
            AND    vendor_site_id = x_ref_integrity_rec.vendor_site_id;

            IF (x_po_vendor_site_id = 0) THEN
                rcv_error_pkg.set_error_message('RCV_NOT_PO_VEN_SITE');
                RAISE e_validation_error;
            END IF;
        END IF;

        IF x_ref_integrity_rec.po_revision_num IS NOT NULL THEN
            SELECT NVL(MAX(vendor_site_id), 0)
            INTO   x_po_vendor_site_id
            FROM   po_headers
            WHERE  po_header_id = x_ref_integrity_rec.po_header_id
            AND    revision_num = x_ref_integrity_rec.po_revision_num;

            IF (x_po_vendor_site_id = 0) THEN
                rcv_error_pkg.set_error_message('RCV_NOT_PO_REVISION');
                RAISE e_validation_error;
            END IF;
        END IF;
    EXCEPTION
        WHEN e_validation_error THEN
            x_ref_integrity_rec.error_record.error_status   := x_error_status;
            x_ref_integrity_rec.error_record.error_message  := rcv_error_pkg.get_last_message;

            IF x_ref_integrity_rec.error_record.error_message = 'RCV_NOT_PO_VEN_ITEM' THEN
                rcv_error_pkg.set_token('PO_SUPPLIER_ITEM', '');
                rcv_error_pkg.set_token('SHIPMENT_SUPPLIER_ITEM', x_ref_integrity_rec.vendor_item_num);
            ELSIF x_ref_integrity_rec.error_record.error_message = 'RCV_NOT_PO_VEN' THEN
                rcv_error_pkg.set_token('PO_SUPPLIER', x_po_vendor_id);
                rcv_error_pkg.set_token('SHIPMENT_SUPPLIER', x_ref_integrity_rec.vendor_id);
            ELSIF x_ref_integrity_rec.error_record.error_message = 'RCV_ERC_MISMATCH_PO_VENDOR' THEN
                NULL;
            ELSIF x_ref_integrity_rec.error_record.error_message = 'RCV_NOT_PO_REVISION' THEN
                rcv_error_pkg.set_token('PO_REV', '');
                rcv_error_pkg.set_token('SHIPMENT_REV', x_ref_integrity_rec.po_revision_num);
            END IF;
    END validate_ref_integ;

/*===========================================================================

  PROCEDURE NAME: validate_freight_carrier()

===========================================================================*/
    PROCEDURE validate_freight_carrier(
        x_freight_carrier_record IN OUT NOCOPY rcv_shipment_line_sv.freight_carrier_record_type
    ) IS
        x_freight_code org_freight_code_val_v.freight_code%TYPE;
        x_progress     VARCHAR2(3);
        x_error_status VARCHAR2(1);
    BEGIN
        x_error_status  := rcv_error_pkg.g_ret_sts_error;

        SELECT NVL(MAX(freight_code), 'notfound')
        INTO   x_freight_code
        FROM   org_freight_code_val_v
        WHERE  freight_code = x_freight_carrier_record.freight_carrier_code
        AND    organization_id = NVL(x_freight_carrier_record.to_organization_id, organization_id);

        IF (x_freight_code = 'notfound') THEN
            rcv_error_pkg.set_error_message('RCV_CARRIER_DISABLED');
            RAISE e_validation_error;
        END IF;

        SELECT NVL(MAX(freight_code), 'notfound')
        INTO   x_freight_code
        FROM   org_freight
        WHERE  organization_id = NVL(x_freight_carrier_record.to_organization_id, organization_id)
        AND    freight_code = x_freight_carrier_record.freight_carrier_code
        AND    NVL(disable_date, SYSDATE + 1) > SYSDATE;

        IF (x_freight_code = 'notfound') THEN
            rcv_error_pkg.set_error_message('RCV_CARRIER_DISABLED');
            RAISE e_validation_error;
        END IF;
    EXCEPTION
        WHEN e_validation_error THEN
            x_freight_carrier_record.error_record.error_status   := x_error_status;
            x_freight_carrier_record.error_record.error_message  := rcv_error_pkg.get_last_message;

            IF x_freight_carrier_record.error_record.error_message = 'RCV_NOT_PO_VEN_ITEM' THEN
                rcv_error_pkg.set_token('CARRIER', x_freight_carrier_record.freight_carrier_code);
            END IF;
    END validate_freight_carrier;

/*===========================================================================

  PROCEDURE NAME: validate_tax_code()   (ASBN only)

===========================================================================*/
    PROCEDURE validate_tax_code(
        x_tax_name_record IN OUT NOCOPY rcv_shipment_line_sv.tax_name_record_type
    ) IS
        x_name         ap_tax_codes.NAME%TYPE   := NULL;
        x_progress     VARCHAR2(3);
        x_error_status VARCHAR2(1);
    BEGIN
        x_error_status  := rcv_error_pkg.g_ret_sts_error;

        SELECT NVL(MAX(NAME), 'notfound')
        INTO   x_name
        FROM   ap_tax_codes
        WHERE  NAME = x_tax_name_record.tax_name;

        IF (x_name = 'notfound') THEN
            rcv_error_pkg.set_error_message('RCV_ASBN_ITEM_TAX_CODE_DISABLE');
            RAISE e_validation_error;
        END IF;

        SELECT NVL(MAX(NAME), 'notfound')
        INTO   x_name
        FROM   ap_tax_codes
        WHERE  NAME = x_tax_name_record.tax_name
        AND    NVL(inactive_date, SYSDATE + 1) > SYSDATE;

        IF (x_name = 'notfound') THEN
            rcv_error_pkg.set_error_message('RCV_ASBN_ITEM_TAX_CODE_DISABLE');
            RAISE e_validation_error;
        END IF;
    EXCEPTION
        WHEN e_validation_error THEN
            x_tax_name_record.error_record.error_status   := x_error_status;
            x_tax_name_record.error_record.error_message  := rcv_error_pkg.get_last_message;

            IF x_tax_name_record.error_record.error_message = 'RCV_ASBN_ITEM_TAX_CODE_DISABLE' THEN
                rcv_error_pkg.set_token('TAX_CODE', x_tax_name_record.tax_name);
            END IF;
        WHEN OTHERS THEN
            x_tax_name_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_unexp_error;
            rcv_error_pkg.set_sql_error_message('validate_tax_code', 000);
            x_tax_name_record.error_record.error_status  := rcv_error_pkg.get_last_message;
    END validate_tax_code;

/*===========================================================================

  PROCEDURE NAME: validate_asl()

===========================================================================*/
    PROCEDURE validate_asl(
        x_asl_record IN OUT NOCOPY rcv_shipment_line_sv.ref_integrity_record_type
    ) IS
        x_supply_agreement_flag po_headers.supply_agreement_flag%TYPE   := 'Y';
        x_success               VARCHAR2(10)                            := NULL;
        x_progress              VARCHAR2(3);
        x_error_status          VARCHAR2(1);
    BEGIN
        x_error_status  := rcv_error_pkg.g_ret_sts_error;

        -- first check if the po from the shipment is a supply agreement blanket purchase

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('In validate ASL');
        END IF;

        SELECT NVL(MAX(supply_agreement_flag), 'N')
        INTO   x_supply_agreement_flag
        FROM   po_headers
        WHERE  po_header_id = x_asl_record.po_header_id
        AND    type_lookup_code = 'BLANKET'
        AND    supply_agreement_flag = 'Y';

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Supply agreement Flag ' || x_supply_agreement_flag);
        END IF;

        IF (x_supply_agreement_flag <> 'N') THEN
            SELECT NVL(MAX('found'), 'notfound')
            INTO   x_success
            FROM   po_approved_supplier_lis_val_v
            WHERE  vendor_id = x_asl_record.vendor_id
            AND    vendor_site_id = x_asl_record.vendor_site_id
            AND    item_id = x_asl_record.item_id
            AND    (   using_organization_id = NVL(x_asl_record.to_organization_id, using_organization_id)
                    OR using_organization_id = -1); -- per discussion with cindy
        END IF;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('PO Approved supplier list ' || x_success);
        END IF;

        IF (x_success = 'notfound') THEN
            rcv_error_pkg.set_error_message('RCV_ASL_NOT_FOUND');
            RAISE e_validation_error;
        END IF;
    EXCEPTION
        WHEN e_validation_error THEN
            x_asl_record.error_record.error_status   := x_error_status;
            x_asl_record.error_record.error_message  := rcv_error_pkg.get_last_message;

            IF x_asl_record.error_record.error_message = 'RCV_ASL_NOT_FOUND' THEN
                rcv_error_pkg.set_token('ITEM', x_asl_record.item_id);
            END IF;
    END validate_asl;

/*===========================================================================

  PROCEDURE NAME: validate_cum_quantity_shipped()

===========================================================================*/
    PROCEDURE validate_cum_quantity_shipped(
        x_cum_quantity_record IN OUT NOCOPY rcv_shipment_line_sv.cum_quantity_record_type
    ) IS
        x_supply_agreement_flag   po_headers.supply_agreement_flag%TYPE        := 'Y';
        x_success                 VARCHAR2(1)                                  := NULL;
        x_progress                VARCHAR2(3);
        x_rtv_update_cum_flag     chv_org_options.rtv_update_cum_flag%TYPE;
        x_cum_period_start_date   chv_cum_periods.cum_period_start_date%TYPE;
        x_cum_period_end_date     chv_cum_periods.cum_period_end_date%TYPE;
        x_continue                BOOLEAN                                      := TRUE;
        x_qty_received_primary    NUMBER;
        x_qty_received_purchasing NUMBER;
        x_total_cum_shipped       NUMBER;
        x_new_conversion          NUMBER                                       := 0;
        x_error_status            VARCHAR2(1);
    BEGIN
        x_error_status  := rcv_error_pkg.g_ret_sts_error;

        -- first check if the po from the shipment is a supply agreement blanket purchase

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Validating cum quantity ');
        END IF;

        SELECT NVL(MAX(supply_agreement_flag), 'N')
        INTO   x_supply_agreement_flag
        FROM   po_headers
        WHERE  po_header_id = x_cum_quantity_record.po_header_id
        AND    type_lookup_code = 'BLANKET'
        AND    supply_agreement_flag = 'Y';

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Check for supply agreement flag ' || x_supply_agreement_flag);
        END IF;

        IF (x_supply_agreement_flag <> 'N') THEN
            SELECT MAX(enable_cum_flag)
            INTO   x_success
            FROM   chv_org_options
            WHERE  organization_id = NVL(x_cum_quantity_record.to_organization_id, organization_id);

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Enable cum flag ' || x_success);
            END IF;

            IF (x_success = 'Y') THEN
                IF (x_cum_quantity_record.vendor_cum_shipped_qty < 0) THEN
                    rcv_error_pkg.set_error_message('RCV_ASL_NO_CUM_QTY');
                    RAISE e_validation_error;
                END IF;
            END IF;
        END IF;

        -- check that the cum quantity from the vendor matches our cum quantity
        -- first get the extra params you need to call get_cum_qty_received

        SELECT NVL(MAX(rtv_update_cum_flag), 'N')
        INTO   x_rtv_update_cum_flag
        FROM   chv_org_options
        WHERE  organization_id = x_cum_quantity_record.to_organization_id;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('RTV update cum flag ' || x_rtv_update_cum_flag);
        END IF;

        IF (x_rtv_update_cum_flag = 'Y') THEN
            BEGIN
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Org Id ' || TO_CHAR(x_cum_quantity_record.to_organization_id));
                    asn_debug.put_line('Transaction date ' || TO_CHAR(x_cum_quantity_record.transaction_date, 'DDMONYY'));
                END IF;

                SELECT cum_period_start_date,
                       cum_period_end_date
                INTO   x_cum_period_start_date,
                       x_cum_period_end_date
                FROM   chv_cum_periods
                WHERE  organization_id = x_cum_quantity_record.to_organization_id
                AND    x_cum_quantity_record.transaction_date BETWEEN cum_period_start_date AND cum_period_end_date;

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Cum period start date ' || TO_CHAR(x_cum_period_start_date, 'DDMONYY'));
                    asn_debug.put_line('Cum Period End date ' || TO_CHAR(x_cum_period_end_date, 'DDMONYY'));
                END IF;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    x_continue  := FALSE;
                WHEN OTHERS THEN
                    RAISE;
            END;
        END IF;

        -- what if item_id is null ????

        IF (x_cum_quantity_record.item_id IS NOT NULL) THEN
            IF (x_continue) THEN
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Call to chv_cum_periods_s1.get_cum_qty_received');
                END IF;

                chv_cum_periods_s1.get_cum_qty_received(x_cum_quantity_record.vendor_id,
                                                        x_cum_quantity_record.vendor_site_id,
                                                        x_cum_quantity_record.item_id,
                                                        x_cum_quantity_record.to_organization_id,
                                                        x_rtv_update_cum_flag,
                                                        x_cum_period_start_date,
                                                        x_cum_period_end_date,
                                                        x_cum_quantity_record.primary_unit_of_measure,
                                                        x_qty_received_primary,
                                                        x_qty_received_purchasing
                                                       );

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Primary Quantity Received ' || TO_CHAR(NVL(x_qty_received_primary, 0)));
                    asn_debug.put_line('Purchasing Quantity Received ' || TO_CHAR(NVL(x_qty_received_purchasing, 0)));
                END IF;

                po_uom_s.uom_convert(x_cum_quantity_record.quantity_shipped,
                                     x_cum_quantity_record.unit_of_measure,
                                     x_cum_quantity_record.item_id,
                                     x_cum_quantity_record.primary_unit_of_measure,
                                     x_new_conversion
                                    );
                x_total_cum_shipped  := x_qty_received_primary + x_new_conversion;

                -- assumption:  the vendor_cum_shipped_qty is in the primary uom

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Check for quantity discrepancy ');
                END IF;

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Vendor Cum quantity ' || TO_CHAR(NVL(x_cum_quantity_record.vendor_cum_shipped_qty, 0)));
                    asn_debug.put_line('Derived Cum Quantity ' || TO_CHAR(NVL(x_total_cum_shipped, -999)));
                END IF;

                IF (x_total_cum_shipped <> NVL(x_cum_quantity_record.vendor_cum_shipped_qty, 0)) THEN
                    rcv_error_pkg.set_error_message('RCV_RCV_NO_MATCH_ASN_CUM');
                    RAISE e_validation_error;
                END IF;
            END IF;
        END IF;
    EXCEPTION
        WHEN e_validation_error THEN
            x_cum_quantity_record.error_record.error_status   := x_error_status;
            x_cum_quantity_record.error_record.error_message  := rcv_error_pkg.get_last_message;

            IF x_cum_quantity_record.error_record.error_message = 'RCV_ASL_NO_CUM_QTY' THEN
                rcv_error_pkg.set_token('ITEM', x_cum_quantity_record.item_id);
            ELSIF x_cum_quantity_record.error_record.error_message = 'RCV_RCV_NO_MATCH_ASN_CUM' THEN
                rcv_error_pkg.set_token('SHIPMENT', '');
                rcv_error_pkg.set_token('ITEM', x_cum_quantity_record.item_id);
            END IF;
    END validate_cum_quantity_shipped;

/*===========================================================================

  PROCEDURE NAME: validate_po_lookup_code()

===========================================================================*/
    PROCEDURE validate_po_lookup_code(
        x_po_lookup_code_record IN OUT NOCOPY rcv_shipment_line_sv.po_lookup_code_record_type
    ) IS
        x_progress     VARCHAR2(3)  := NULL;
        x_lookup_code  VARCHAR2(25) := NULL;
        x_error_status VARCHAR2(1);
    BEGIN
        x_error_status  := rcv_error_pkg.g_ret_sts_error;
        x_progress      := '005';

        SELECT NVL(MAX(pol.lookup_code), 'notfound')
        INTO   x_lookup_code
        FROM   po_lookup_codes pol
        WHERE  pol.lookup_code = x_po_lookup_code_record.lookup_code
        AND    pol.lookup_type = x_po_lookup_code_record.lookup_type;

        IF (    x_lookup_code = 'notfound'
            AND x_po_lookup_code_record.lookup_type = 'RCV DESTINATION TYPE') THEN
            rcv_error_pkg.set_error_message('RCV_DEST_TYPE_CODE_INVALID');
            RAISE e_validation_error;
        END IF;
    EXCEPTION
        WHEN e_validation_error THEN
            x_po_lookup_code_record.error_record.error_status   := x_error_status;
            x_po_lookup_code_record.error_record.error_message  := rcv_error_pkg.get_last_message;

            IF x_po_lookup_code_record.error_record.error_message = 'RCV_DEST_TYPE_CODE_INVALID' THEN
                NULL;
            END IF;
        WHEN OTHERS THEN
            x_po_lookup_code_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_unexp_error;
            rcv_error_pkg.set_sql_error_message('validate_po_lookup_code', 000);
            x_po_lookup_code_record.error_record.error_status  := rcv_error_pkg.get_last_message;
    END validate_po_lookup_code;

/*===========================================================================

  PROCEDURE NAME: validate_subinventory()

===========================================================================*/
    PROCEDURE validate_subinventory(
        x_subinventory_record IN OUT NOCOPY rcv_shipment_line_sv.subinventory_record_type
    ) IS
        x_progress     VARCHAR2(3)  := NULL;
        x_subinventory VARCHAR2(10) := NULL;
        x_error_status VARCHAR2(1);
    BEGIN
        x_error_status  := rcv_error_pkg.g_ret_sts_error;
        x_progress      := '005';

        /*
        ** Only go through these validation routines if the destination type
        ** is inventory
        */
        IF (x_subinventory_record.destination_type_code <> 'INVENTORY') THEN
            x_subinventory_record.subinventory  := NULL;
            RETURN;
        END IF;

        IF (x_subinventory_record.subinventory IS NULL) THEN
            rcv_error_pkg.set_error_message('RCV_DEST_SUB_NA');
            RAISE e_validation_error;
        END IF;

        /*
        ** Validate the subinventory
        */
        x_progress      := '010';

        SELECT NVL(MAX(secondary_inventory_name), 'notfound')
        INTO   x_subinventory
        FROM   mtl_secondary_inventories msub,
               mtl_system_items msi
        WHERE  msub.secondary_inventory_name = x_subinventory_record.subinventory
        AND    msub.organization_id = x_subinventory_record.to_organization_id
        AND    x_subinventory_record.transaction_date < NVL(msub.disable_date, x_subinventory_record.transaction_date + 1)
        AND    msi.inventory_item_id = x_subinventory_record.item_id
        AND    msi.organization_id = x_subinventory_record.to_organization_id
        AND    (   msi.restrict_subinventories_code = 2
                OR (    msi.restrict_subinventories_code = 1
                    AND EXISTS(SELECT NULL
                               FROM   mtl_item_sub_inventories mis
                               WHERE  mis.organization_id = x_subinventory_record.to_organization_id
                               AND    mis.inventory_item_id = x_subinventory_record.item_id
                               AND    mis.secondary_inventory = x_subinventory_record.subinventory)
                   )
               );

        IF (x_subinventory = 'notfound') THEN
            rcv_error_pkg.set_error_message('RCV_DEST_SUB_INVALID');
            RAISE e_validation_error;
        END IF;
    EXCEPTION
        WHEN e_validation_error THEN
            x_subinventory_record.error_record.error_status   := x_error_status;
            x_subinventory_record.error_record.error_message  := rcv_error_pkg.get_last_message;

            IF x_subinventory_record.error_record.error_message = 'RCV_DEST_SUB_NA' THEN
                NULL;
            ELSIF x_subinventory_record.error_record.error_message = 'RCV_DEST_SUB_INVALID' THEN
                NULL;
            END IF;
        WHEN OTHERS THEN
            x_subinventory_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_unexp_error;
            rcv_error_pkg.set_sql_error_message('validate_subinventory', x_progress);
            x_subinventory_record.error_record.error_status  := rcv_error_pkg.get_last_message;
    END validate_subinventory;

/*===========================================================================

  PROCEDURE NAME: validate_location()

===========================================================================*/
    PROCEDURE validate_location(
        x_location_record IN OUT NOCOPY rcv_shipment_line_sv.location_record_type
    ) IS
        x_progress     VARCHAR2(3) := NULL;
        x_location     NUMBER;
        x_error_status VARCHAR2(1);
    BEGIN
        x_error_status  := rcv_error_pkg.g_ret_sts_error;
        x_progress      := '005';

        /*
        ** The location id must be set if you're delivering items to either an
        ** expense or shop floor location.  If must also be set if you're validating
        ** a ship-to location since it's a required field.  If it's not one of these
        ** two cases then just return if the value is null
        */
        IF (    x_location_record.location_id IS NULL
            AND x_location_record.destination_type_code IN('EXPENSE', 'SHOP FLOOR')
            AND x_location_record.location_type_code = 'DELIVER_TO') THEN
            rcv_error_pkg.set_error_message('RCV_DELIVER_TO_LOC_NA');
            RAISE e_validation_error;
        ELSIF(    x_location_record.location_id IS NULL
              AND x_location_record.location_type_code = 'SHIP_TO') THEN
            rcv_error_pkg.set_error_message('RCV_SHIP_TO_LOC_NA');
            RAISE e_validation_error;
        ELSIF(x_location_record.location_id IS NULL) THEN
            RETURN;
        END IF;

        /*
        ** Validate the location
        */
        x_progress      := '010';

        /* Bug 1904631
         * Since location_code for drop ship locations are null in hr_locations,
         * max(location_code) will give an incorrect value even if the location_id
         * exists in hr_locations. Now select from hr_locations_all
         */
        BEGIN
            SELECT location_id
            INTO   x_location
            FROM   hr_locations_all hrl --1942696
            WHERE  (   hrl.inventory_organization_id = x_location_record.to_organization_id
                    OR NVL(hrl.inventory_organization_id, 0) = 0)
            AND    (   hrl.inactive_date IS NULL
                    OR hrl.inactive_date > SYSDATE)
            AND    (hrl.location_id = x_location_record.location_id);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                BEGIN
                    SELECT location_id
                    INTO   x_location
                    FROM   hz_locations hz
                    WHERE  (   hz.address_expiration_date IS NULL
                            OR hz.address_expiration_date > SYSDATE)
                    AND    (hz.location_id = x_location_record.location_id);
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        IF (x_location_record.location_type_code = 'DELIVER_TO') THEN
                            rcv_error_pkg.set_error_message('RCV_DELIVER_TO_LOC_INVALID');
                            RAISE e_validation_error;
                        ELSE
                            rcv_error_pkg.set_error_message('RCV_SHIP_TO_LOC_NA');
                            RAISE e_validation_error;
                        END IF;
                END;
        END;
    EXCEPTION
        WHEN e_validation_error THEN
            x_location_record.error_record.error_status   := x_error_status;
            x_location_record.error_record.error_message  := rcv_error_pkg.get_last_message;

            IF x_location_record.error_record.error_message = 'RCV_DELIVER_TO_LOC_NA' THEN
                NULL;
            ELSIF x_location_record.error_record.error_message = 'RCV_SHIP_TO_LOC_NA' THEN
                NULL;
            ELSIF x_location_record.error_record.error_message = 'RCV_DELIVER_TO_LOC_INVALID' THEN
                NULL;
            END IF;
        WHEN OTHERS THEN
            x_location_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_unexp_error;
            rcv_error_pkg.set_sql_error_message('validate_location', x_progress);
            x_location_record.error_record.error_status  := rcv_error_pkg.get_last_message;
    END validate_location;

/*===========================================================================

  PROCEDURE NAME: validate_employee()

===========================================================================*/
    PROCEDURE validate_employee(
        x_employee_record IN OUT NOCOPY rcv_shipment_line_sv.employee_record_type
    ) IS
        x_progress     VARCHAR2(3)   := NULL;
        x_full_name    VARCHAR2(240) := NULL;
        x_error_status VARCHAR2(1);
    BEGIN
        x_error_status  := rcv_error_pkg.g_ret_sts_error;
        x_progress      := '005';

        IF (x_employee_record.employee_id IS NULL) THEN
            RETURN;
        END IF;

        /*
        ** Validate the employee
        */
        x_progress      := '010';

        SELECT NVL(MAX(hre.full_name), 'notfound')
        INTO   x_full_name
        FROM   hr_employees_current_v hre
        WHERE  (   hre.inactive_date IS NULL
                OR hre.inactive_date > SYSDATE)
        AND    hre.employee_id = x_employee_record.employee_id;

        IF (x_full_name = 'notfound') THEN
            /*
            ** DEBUG: Need another message for an invalid person
            */
            rcv_error_pkg.set_error_message('RCV_ALL_MISSING_DELIVER_PERSON');
            RAISE e_validation_error;
        END IF;
    EXCEPTION
        WHEN e_validation_error THEN
            x_employee_record.error_record.error_status   := x_error_status;
            x_employee_record.error_record.error_message  := rcv_error_pkg.get_last_message;

            IF x_employee_record.error_record.error_message = 'RCV_ALL_MISSING_DELIVER_PERSON' THEN
                NULL;
            END IF;
        WHEN OTHERS THEN
            x_employee_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_unexp_error;
            rcv_error_pkg.set_sql_error_message('validate_employee', x_progress);
            x_employee_record.error_record.error_status  := rcv_error_pkg.get_last_message;
    END validate_employee;

/*===========================================================================

  PROCEDURE NAME: validate_locator()

===========================================================================*/
    PROCEDURE validate_locator(
        x_locator_record IN OUT NOCOPY rcv_shipment_line_sv.locator_record_type
    ) IS
        x_progress     VARCHAR2(3)  := NULL;
        x_locator      VARCHAR2(81) := NULL;
        x_error_status VARCHAR2(1);
    BEGIN
        x_error_status  := rcv_error_pkg.g_ret_sts_error;
        x_progress      := '005';

        /*
        ** Only go through these validation routines if the destination type
        ** is inventory
        */
        /* FPJ WMS Change.
         * Changed the code to support receiving subinventory and locator.
        */
        IF (    (x_locator_record.destination_type_code <> 'INVENTORY')
            AND (x_locator_record.subinventory IS NULL)) THEN
            x_locator_record.locator_id  := NULL;
            RETURN;
        END IF;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Before Get Locator');
        END IF;

        /*
        ** Get the locator controls
        */
        po_subinventories_s.get_locator_control(x_locator_record.to_organization_id,
                                                x_locator_record.subinventory,
                                                x_locator_record.item_id,
                                                x_locator_record.subinventory_locator_control,
                                                x_locator_record.restrict_locator_control
                                               );

        /*
        ** If this org/item/sub is not under locator control
        ** then simply clear the locator and return
        */
        IF (x_locator_record.subinventory_locator_control = 1) THEN
            /* begin changes for bug 7488437*/
            IF (x_locator_record.locator_id IS NOT NULL) THEN
               IF (g_asn_debug = 'Y') THEN
                   asn_debug.put_line('Error: Subinventory is not locator controlled, but locator info is given');
               END IF;
               rcv_error_pkg.set_error_message('RCV_NO_LOCATOR_CONTROL');
            	 RAISE e_validation_error;
            END IF;
            return;
            /* end changes for bug 7488437*/
        END IF;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Loc Cont = ' || TO_CHAR(x_locator_record.subinventory_locator_control));
            asn_debug.put_line('Rest Cont = ' || x_locator_record.restrict_locator_control);
        END IF;

        /*
        ** bug 724495, the else part now runs only if the
        ** subinventory_locator_control is in (2,3)
        */

        /* FPJ WMS Change. We do not support locator restrictions for receiving
         * subinventory and locators. Hence make restrict_locator_control as 2
         * (no restriction).
        */
        IF (x_locator_record.destination_type_code <> 'INVENTORY') THEN
            x_locator_record.restrict_locator_control  := 2;
        END IF;

        /*
        ** If locator control is 2 or 3 and the item is not under restricted locator
        ** control then do simple unrestricted check
        */
        IF (x_locator_record.subinventory_locator_control IN(2, 3)) THEN
            IF (NVL(x_locator_record.restrict_locator_control, 2) = 2) THEN
                /* 3017707 - We need to validate the locator in the receiving organization. Added the filter on
                   organization id */
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Sub is not under restricted locator control');
                END IF;

                SELECT NVL(MAX(ml.concatenated_segments), 'notfound')
                INTO   x_locator
                FROM   mtl_item_locations_kfv ml
                WHERE  ml.inventory_location_id = x_locator_record.locator_id
                AND    (   ml.disable_date > SYSDATE
                        OR ml.disable_date IS NULL)
                AND    NVL(ml.subinventory_code, 'z') = NVL(x_locator_record.subinventory, 'z')
                AND    ml.organization_id = x_locator_record.to_organization_id;
            /*
            ** ELSE If locator control is 2 or 3 and the item is under restricted locator
            ** control then do restricted check
            */
            ELSE
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Sub is under restricted locator control');
                END IF;

                SELECT NVL(MAX(ml.concatenated_segments), 'notfound')
                INTO   x_locator
                FROM   mtl_item_locations_kfv ml
                WHERE  ml.inventory_location_id = x_locator_record.locator_id
                AND    (   ml.disable_date > SYSDATE
                        OR ml.disable_date IS NULL)
                AND    NVL(ml.subinventory_code, 'z') = NVL(x_locator_record.subinventory, 'z')
                AND    ml.inventory_location_id IN(SELECT secondary_locator
                                                   FROM   mtl_secondary_locators msl
                                                   WHERE  msl.inventory_item_id = x_locator_record.item_id
                                                   AND    msl.organization_id = x_locator_record.to_organization_id
                                                   AND    msl.subinventory_code = x_locator_record.subinventory);
            END IF;
        END IF;

        IF (x_locator = 'notfound') THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('In locator Errors');
            END IF;

            rcv_error_pkg.set_error_message('RCV_ALL_REQUIRED_LOCATOR');
            RAISE e_validation_error;
        END IF;
    EXCEPTION
        WHEN e_validation_error THEN
            x_locator_record.error_record.error_status   := x_error_status;
            x_locator_record.error_record.error_message  := rcv_error_pkg.get_last_message;

            IF x_locator_record.error_record.error_message = 'RCV_ALL_REQUIRED_LOCATOR' THEN
                NULL;
            END IF;
        WHEN OTHERS THEN
            x_locator_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_unexp_error;
            rcv_error_pkg.set_sql_error_message('validate_locator', x_progress);
            x_locator_record.error_record.error_status  := rcv_error_pkg.get_last_message;
    END validate_locator;


/*===========================================================================

  PROCEDURE NAME: validate_project_locator()  --Bug13844195

===========================================================================*/
PROCEDURE VALIDATE_PROJECT_LOCATOR(X_LOCATOR_RECORD IN OUT NOCOPY RCV_SHIPMENT_LINE_SV.LOCATOR_RECORD_TYPE) IS
  X_PROGRESS     VARCHAR2(3) := NULL;
  X_LOCATOR      VARCHAR2(81) := NULL;
  X_ERROR_STATUS VARCHAR2(1);
  --BUG 13844195
  VALID_LOCATOR          BOOLEAN := TRUE;
  X_PROJECT_ID           NUMBER := NULL;
  X_TASK_ID              NUMBER := NULL;
  V_PROJECT_ENABLED      NUMBER := 0;
  X_ORG_ID               NUMBER := 0;
  L_PREV_OU_ID           FINANCIALS_SYSTEM_PARAMS_ALL.ORG_ID%TYPE;
  L_PJM_VALIDATION_OU_ID FINANCIALS_SYSTEM_PARAMS_ALL.ORG_ID%TYPE := NULL;
  L_RETURN_STATUS        VARCHAR2(1);
  L_MODE                 VARCHAR2(10) := 'SPECIFIC'; --BUG 9742249
  L_REQUIRED_FLAG        VARCHAR2(10) := 'Y'; --BUG 9742249
BEGIN
  X_ERROR_STATUS := RCV_ERROR_PKG.G_RET_STS_ERROR;
  X_PROGRESS     := '005';

  IF X_LOCATOR_RECORD.ERROR_RECORD.ERROR_STATUS NOT IN ('S','W') THEN
  RETURN;
  END IF;

  IF (X_LOCATOR_RECORD.RECEIPT_SOURCE_CODE = 'INVENTORY') THEN
    L_MODE          := 'ANY';
    L_REQUIRED_FLAG := 'N';
  END IF;

  IF ((X_LOCATOR_RECORD.DESTINATION_TYPE_CODE <> 'INVENTORY') AND
     (X_LOCATOR_RECORD.SUBINVENTORY IS NULL)) THEN
    X_LOCATOR_RECORD.LOCATOR_ID := NULL;
    RETURN;
  END IF;

  IF (G_ASN_DEBUG = 'Y') THEN
    ASN_DEBUG.PUT_LINE('BEFORE GET PROJECT TASK LOCATOR');
  END IF;


   SELECT NVL(PROJECT_REFERENCE_ENABLED, 0)
        INTO V_PROJECT_ENABLED
        FROM MTL_PARAMETERS
       WHERE ORGANIZATION_ID = X_LOCATOR_RECORD.TO_ORGANIZATION_ID;

  IF V_PROJECT_ENABLED = 1 THEN
  /*
  ** GET THE LOCATOR CONTROLS
  */
  PO_SUBINVENTORIES_S.GET_LOCATOR_CONTROL(X_LOCATOR_RECORD.TO_ORGANIZATION_ID,
                                          X_LOCATOR_RECORD.SUBINVENTORY,
                                          X_LOCATOR_RECORD.ITEM_ID,
                                          X_LOCATOR_RECORD.SUBINVENTORY_LOCATOR_CONTROL,
                                          X_LOCATOR_RECORD.RESTRICT_LOCATOR_CONTROL);

  IF NVL(X_LOCATOR_RECORD.LOCATOR_ID, '0') NOT IN (-1, 0) THEN

    ASN_DEBUG.PUT_LINE('X_LOCATOR_RECORD.PO_DISTRIBUTION_ID' ||
                       X_LOCATOR_RECORD.PO_DISTRIBUTION_ID);
    ASN_DEBUG.PUT_LINE('X_LOCATOR_RECORD.SOURCE_DOCUMENT_CODE' ||
                       X_LOCATOR_RECORD.SOURCE_DOCUMENT_CODE);

    IF (X_LOCATOR_RECORD.SOURCE_DOCUMENT_CODE = 'PO' AND
       X_LOCATOR_RECORD.PO_DISTRIBUTION_ID IS NOT NULL) THEN

      SELECT PROJECT_ID, TASK_ID, ORG_ID -- BUG 13709880
        INTO X_PROJECT_ID, X_TASK_ID, L_PJM_VALIDATION_OU_ID -- BUG 13709880
        FROM PO_DISTRIBUTIONS_ALL
       WHERE PO_DISTRIBUTION_ID = X_LOCATOR_RECORD.PO_DISTRIBUTION_ID;

      ASN_DEBUG.PUT_LINE('X_LOCATOR_RECORD.PO_DISTRIBUTION_ID' ||
                         X_LOCATOR_RECORD.PO_DISTRIBUTION_ID);

    END IF;

    BEGIN

      IF (G_ASN_DEBUG = 'Y') THEN
        ASN_DEBUG.PUT_LINE('BEFORE PROJECT ENABLED  ');
      END IF;


       --BUG 14538546

        FND_PROFILE.PUT('MFG_ORGANIZATION_ID',
                        X_LOCATOR_RECORD.TO_ORGANIZATION_ID);


        VALID_LOCATOR := INV_PROJECTLOCATOR_PUB.CHECK_PROJECT_REFERENCES(X_LOCATOR_RECORD.TO_ORGANIZATION_ID,
                                                                         X_LOCATOR_RECORD.LOCATOR_ID,
                                                                         L_MODE,
                                                                         L_REQUIRED_FLAG,
                                                                         X_LOCATOR_RECORD.PROJECT_ID,
                                                                         X_LOCATOR_RECORD.TASK_ID);



      IF (NVL(X_LOCATOR_RECORD.PROJECT_ID, X_PROJECT_ID) <> X_PROJECT_ID OR
         NVL(X_LOCATOR_RECORD.TASK_ID, X_TASK_ID) <> X_TASK_ID) THEN
        RCV_ERROR_PKG.SET_ERROR_MESSAGE('RCV_ALL_INVALID_LOCATOR');
        RCV_ERROR_PKG.SET_TOKEN('LOCATOR',X_LOCATOR_RECORD.LOCATOR);
        ASN_DEBUG.PUT_LINE('ROI PROJECT TASK ID <> POD PROJECT TASK ID');
        ASN_DEBUG.PUT_LINE('INVALID PROJECT TASK ID FOR PROJECT ENABLED LOCATOR');

        RAISE E_VALIDATION_ERROR;

      END IF;

      IF (NOT VALID_LOCATOR) THEN
        RCV_ERROR_PKG.SET_ERROR_MESSAGE('RCV_ALL_INVALID_LOCATOR');
        RCV_ERROR_PKG.SET_TOKEN('LOCATOR',X_LOCATOR_RECORD.LOCATOR);
        ASN_DEBUG.PUT_LINE('INVALID PROJECT TASK LOCATOR FOR PROJECT ENABLED LOCATOR  ');
        RAISE E_VALIDATION_ERROR;
      ELSE
        ASN_DEBUG.PUT_LINE('VALID PROJECT TASK LOCATOR ');
      END IF;

    EXCEPTION
      WHEN E_VALIDATION_ERROR THEN
        X_LOCATOR_RECORD.ERROR_RECORD.ERROR_STATUS  := X_ERROR_STATUS;
        X_LOCATOR_RECORD.ERROR_RECORD.ERROR_MESSAGE := RCV_ERROR_PKG.GET_LAST_MESSAGE;

      WHEN OTHERS THEN
        X_LOCATOR_RECORD.ERROR_RECORD.ERROR_STATUS := RCV_ERROR_PKG.G_RET_STS_UNEXP_ERROR;
        RCV_ERROR_PKG.SET_SQL_ERROR_MESSAGE('VALIDATE_PRO_TASK_LOCATOR',
                                            X_PROGRESS);
        X_LOCATOR_RECORD.ERROR_RECORD.ERROR_STATUS := RCV_ERROR_PKG.GET_LAST_MESSAGE;

    END;

  END IF;

    END IF;

END VALIDATE_PROJECT_LOCATOR;



/*===========================================================================

  PROCEDURE NAME: validate_country_of_origin()

===========================================================================*/
    PROCEDURE validate_country_of_origin(
        x_country_of_origin_record IN OUT NOCOPY rcv_shipment_line_sv.country_of_origin_record_type
    ) IS
        x_code         fnd_territories_vl.territory_code%TYPE   := NULL;
        x_progress     VARCHAR2(3);
        x_error_status VARCHAR2(1);
    BEGIN
        x_error_status  := rcv_error_pkg.g_ret_sts_error;

        SELECT NVL(MAX(territory_code), 'FF')
        INTO   x_code
        FROM   fnd_territories_vl
        WHERE  territory_code = x_country_of_origin_record.country_of_origin_code;

        IF (x_code = 'FF') THEN
            rcv_error_pkg.set_error_message('RCV_ASN_ORIGIN_COUNTRY_INVALID');
            RAISE e_validation_error;
        END IF;
    EXCEPTION
        WHEN e_validation_error THEN
            x_country_of_origin_record.error_record.error_status   := x_error_status;
            x_country_of_origin_record.error_record.error_message  := rcv_error_pkg.get_last_message;

            IF x_country_of_origin_record.error_record.error_message = 'RCV_ASN_ORIGIN_COUNTRY_INVALID' THEN
                rcv_error_pkg.set_token('COUNTRY_OF_ORIGIN_CODE', x_country_of_origin_record.country_of_origin_code);
                rcv_error_pkg.set_token('SHIPMENT', '');
            END IF;
        WHEN OTHERS THEN
            x_country_of_origin_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_unexp_error;
            rcv_error_pkg.set_sql_error_message('validate_country_of_origin', x_progress);
            x_country_of_origin_record.error_record.error_status  := rcv_error_pkg.get_last_message;
    END validate_country_of_origin;

/* <Consigned Inventory Pre-Processor FPI START> */

/*===========================================================================
PROCEDURE NAME:   validate_consigned_po()
===========================================================================*/
    PROCEDURE validate_consigned_po(
        x_consigned_po_rec IN OUT NOCOPY rcv_shipment_line_sv.po_line_location_id_rtype
    ) IS
        l_consigned_po_flag po_line_locations_all.consigned_flag%TYPE;
        x_error_status      VARCHAR2(1);
    BEGIN
        x_error_status  := rcv_error_pkg.g_ret_sts_error;

        SELECT consigned_flag
        INTO   l_consigned_po_flag
        FROM   po_line_locations
        WHERE  line_location_id = x_consigned_po_rec.po_line_location_id;

        IF (l_consigned_po_flag = 'Y') THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('in RCVTIS2B.pls' || l_consigned_po_flag);
            END IF;

            rcv_error_pkg.set_error_message('RCV_REJECT_ASBN_CONSIGNED_PO');
            RAISE e_validation_error;
        END IF;
    EXCEPTION
        WHEN e_validation_error THEN
            x_consigned_po_rec.error_record.error_status   := x_error_status;
            x_consigned_po_rec.error_record.error_message  := rcv_error_pkg.get_last_message;

            IF x_consigned_po_rec.error_record.error_message = 'RCV_REJECT_ASBN_CONSIGNED_PO' THEN
                NULL;
            END IF;
        WHEN OTHERS THEN
            x_consigned_po_rec.error_record.error_status  := rcv_error_pkg.g_ret_sts_unexp_error;
            rcv_error_pkg.set_sql_error_message('validate_consigned_po', '000');
            x_consigned_po_rec.error_record.error_status  := rcv_error_pkg.get_last_message;
    END validate_consigned_po;

/*===========================================================================
PROCEDURE NAME:   validate_consumption_po()
===========================================================================*/
    PROCEDURE validate_consumption_po(
        x_consumption_po_rec IN OUT NOCOPY rcv_shipment_line_sv.document_num_record_type
    ) IS
        l_consumption_po_flag po_headers_all.consigned_consumption_flag%TYPE;
        x_error_status        VARCHAR2(1);
    BEGIN
        x_error_status  := rcv_error_pkg.g_ret_sts_error;

        SELECT consigned_consumption_flag
        INTO   l_consumption_po_flag
        FROM   po_headers
        WHERE  po_header_id = x_consumption_po_rec.po_header_id;

        IF (l_consumption_po_flag = 'Y') THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('in RCVTIS2B.pls' || l_consumption_po_flag);
            END IF;

            rcv_error_pkg.set_error_message('RCV_REJECT_CONSUMPTION_PO');
            RAISE e_validation_error;
        END IF;
    EXCEPTION
        WHEN e_validation_error THEN
            x_consumption_po_rec.error_record.error_status   := x_error_status;
            x_consumption_po_rec.error_record.error_message  := rcv_error_pkg.get_last_message;

            IF x_consumption_po_rec.error_record.error_message = 'RCV_REJECT_CONSUMPTION_PO' THEN
                NULL;
            END IF;
        WHEN OTHERS THEN
            x_consumption_po_rec.error_record.error_status  := rcv_error_pkg.g_ret_sts_unexp_error;
            rcv_error_pkg.set_sql_error_message('validate_consumption_po', '000');
            x_consumption_po_rec.error_record.error_status  := rcv_error_pkg.get_last_message;
    END validate_consumption_po;

/*===========================================================================
PROCEDURE NAME:   validate_consumption_release()
===========================================================================*/
    PROCEDURE validate_consumption_release(
        x_consumption_release_rec IN OUT NOCOPY rcv_shipment_line_sv.release_id_record_type
    ) IS
        l_consumption_release_flag po_releases_all.consigned_consumption_flag%TYPE;
        x_error_status             VARCHAR2(1);
    BEGIN
        x_error_status  := rcv_error_pkg.g_ret_sts_error;

        SELECT consigned_consumption_flag
        INTO   l_consumption_release_flag
        FROM   po_releases
        WHERE  po_release_id = x_consumption_release_rec.po_release_id;

        IF (l_consumption_release_flag = 'Y') THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('in RCVTIS2B.pls, consumption release' || l_consumption_release_flag);
            END IF;

            rcv_error_pkg.set_error_message('RCV_REJECT_CONSUMPTION_RELEASE');
            RAISE e_validation_error;
        END IF;
    EXCEPTION
        WHEN e_validation_error THEN
            x_consumption_release_rec.error_record.error_status   := x_error_status;
            x_consumption_release_rec.error_record.error_message  := rcv_error_pkg.get_last_message;

            IF x_consumption_release_rec.error_record.error_message = 'RCV_REJECT_CONSUMPTION_RELEASE' THEN
                NULL;
            END IF;
        WHEN OTHERS THEN
            x_consumption_release_rec.error_record.error_status  := rcv_error_pkg.g_ret_sts_unexp_error;
            rcv_error_pkg.set_sql_error_message('validate_consumption_release', '000');
            x_consumption_release_rec.error_record.error_status  := rcv_error_pkg.get_last_message;
    END validate_consumption_release;


 /*##########################################################################
  #
  #  PROCEDURE
  #   VALIDATE_SECONDARY_PARAMETERS
  #
  #  DESCRIPTION
  #
  #      For Dual UOM controlled items validate the secondary UOM code and
  #      Secondary UOM. Derive them if either/both are not specified.
  #	   For  Receipt if secondary quantity is there then it will validate it
  #      (will do the deviation check for it )else it will derive it.
  #
  #    Method of logging errors:
  #
  #    1) If business logic fails:
  #       Message is set and exception is raised.
  #       In exception block return status is set to "Error"
  #       The last message is retrieved and the program ends there.
  #
  #   2) If an unexpected failure occours:
  #       Messge is set.
  #       Last message is retrieved at that place only.
  #       return status is set to "Unexpected Error" and control is
  #       returned back to the calling program.
  #
  #    3) Messages are also added to error stack.
  #
  #   DESIGN REFERENCES:
  #   INVCONV.
  #   http://files.oraclecorp.com/content/AllPublic/Workspaces/
  #   Inventory%20Convergence-Public/Design/Oracle%20Purchasing/TDD/PO_ROI_TDD.zip
  #
  #
  # MODIFICATION HISTORY
  # 23-AUG-2004  Punit Kumar 	Created
  #
  #########################################################################*/


PROCEDURE VALIDATE_SECONDARY_PARAMETERS(
                                 p_api_version	   IN  	 NUMBER                                                           ,
                                 p_init_msg_lst	   IN  	 VARCHAR2         ,
                                 x_att_rec         IN OUT NOCOPY RCV_TRANSACTIONS_INTERFACE_SV1.attributes_record_type     ,
                                 x_return_status  	OUT 	 NOCOPY	VARCHAR2                                                 ,
                                 x_msg_count       OUT 	 NOCOPY	NUMBER                                                   ,
                                 x_msg_data        OUT 	 NOCOPY	VARCHAR2                                            ,
                                 p_transaction_id  IN        NUMBER      /*BUG#10380635 */
                                 )
   IS

   l_api_name                    VARCHAR2(30) := 'VALIDATE_SECONDARY_PARAMETERS'         ;
   l_api_version                 CONSTANT NUMBER := 1.0                                  ;

   l_return_status               VARCHAR2(1)                                             ;
   l_msg_data                    VARCHAR2(3000)                                          ;
   l_msg_count                   NUMBER                                                  ;

   l_check_dev                   NUMBER                                                  ;
   l_TRACKING_QUANTITY_IND       VARCHAR2(30)                                            ;
   l_secondary_default_ind       VARCHAR2(10)                                            ;
   l_secondary_uom_code          VARCHAR2(3)                                             ;
   l_secondary_unit_of_measure   VARCHAR2(25)                                            ;
   l_progress                    VARCHAR2(10) := '0000'                                  ;
   l_lot_number                  VARCHAR2(80)                                            ;        /*BUG#10380635 */
   l_conv_exist                  NUMBER :=0                                              ;      --Bug13934928 initialized  --Bug#13401431

   /*Bug 13938193*/
   l_sec_lot_dev_tqty             NUMBER :=0                                              ;
   l_sec_lot_spe_qty              NUMBER :=0                                              ;
   l_sec_lot_spe_tqty             NUMBER :=0                                              ;
   /*End Bug 13938193*/

 CURSOR   lot_num_cur(l_transaction_id  NUMBER)  IS
  SELECT LOT_NUMBER  FROM  mtl_transaction_lots_interface WHERE product_transaction_id=l_transaction_id;

   /*Bug 13938193*/
 CURSOR   lot_num_cur1(l_transaction_id  NUMBER)  IS
  SELECT transaction_quantity, LOT_NUMBER ,SECONDARY_TRANSACTION_QUANTITY FROM  mtl_transaction_lots_interface WHERE product_transaction_id=l_transaction_id;
  /*End Bug 13938193*/

BEGIN
   l_progress :='0001';
   IF (g_asn_debug = 'Y') THEN
       asn_debug.put_line('VALIDATE_SECONDARY_PARAMETERS: Entering' || l_progress);
   END IF;


    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(
                                       l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       'PO_VALIDATE_PARAMETERS'
                                       ) THEN
       l_progress :='0002';
       IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('FND_API not compatible rcv_transactions_interface_sv1.VALIDATE_SECONDARY_PARAMETERS'||l_progress);
       END IF;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_lst) THEN
       fnd_msg_pub.initialize;
    END IF;

    --Initialize the return status
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_att_rec.error_record.error_status := FND_API.G_RET_STS_SUCCESS;
    x_att_rec.error_record.error_message   := NULL;

    /*BUG#10380635 : fetching lot number for current transaction--starts here*/


   OPEN lot_num_cur(p_transaction_id);
     if lot_num_cur%NOTFOUND then
       l_lot_number := NULL;
     else
       FETCH lot_num_cur INTO l_lot_number;
     end if;
   CLOSE lot_num_cur;
    /*BUG#10380635---ends here */



    /*Defaulting of  origination type to 'Purchasing' to be done
      in INV_RCV_INTEGRATION_PVT.MOVE_LOT_SERIAL_INFO */


    l_progress := '001';

   BEGIN
      l_progress :='0003';
      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('Inside rcv_transactions_interface_sv1.VALIDATE_SECONDARY_PARAMETERS:' || l_progress);
      END IF;

      -------Checking if the item is dual UOM controlled. If not then Return .
      SELECT tracking_quantity_ind , secondary_default_ind
         INTO l_TRACKING_QUANTITY_IND ,l_secondary_default_ind
         FROM mtl_system_items_b
         WHERE INVENTORY_ITEM_ID = x_att_rec.inventory_item_id
         AND  ORGANIZATION_ID = x_att_rec.to_organization_id;

      l_progress :='0004';
      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('Value of tracking_quantity_ind is ' ||l_TRACKING_QUANTITY_IND ||':'||l_progress);
      END IF;


   EXCEPTION
      WHEN OTHERS THEN
         l_progress :='0005';
         IF g_asn_debug = 'Y' THEN
            asn_debug.put_line('Dual UOM check failed:' || l_progress);
         END IF;

         x_att_rec.error_record.error_status  := fnd_api.g_ret_sts_unexp_error;
         rcv_error_pkg.set_sql_error_message('Unexpected Exception in validate_secondary_parameters', l_progress);
         x_att_rec.error_record.error_message  := rcv_error_pkg.get_last_message;

         RETURN;

   END;

   /*For non dual items.*/
   IF l_TRACKING_QUANTITY_IND <> 'PS'  THEN
      l_progress :='0006';
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Item is not dual UOM controlled.:'|| l_progress);
      END IF;

      /*Error out if secondary parameters are specified and item is not dual uom controlled*/
      IF  x_att_rec.secondary_uom_code IS NOT NULL THEN
         /*
         rcv_error_pkg.set_error_message('PO_SECONDARY_UOM_NOT_REQUIRED');
         RAISE e_validation_error;
         */
         x_att_rec.error_record.error_status  := fnd_api.g_ret_sts_error;
         rcv_error_pkg.set_error_message('PO_SECONDARY_UOM_NOT_REQUIRED');
         x_att_rec.error_record.error_message  := rcv_error_pkg.get_last_message;

         RETURN;


      ELSIF x_att_rec.secondary_unit_of_measure IS NOT NULL THEN
         /*
         rcv_error_pkg.set_error_message('PO_SECONDARY_UOM_NOT_REQUIRED');
         RAISE e_validation_error;
         */
         x_att_rec.error_record.error_status  := fnd_api.g_ret_sts_error;
         rcv_error_pkg.set_error_message('PO_SECONDARY_UOM_NOT_REQUIRED');
         x_att_rec.error_record.error_message  := rcv_error_pkg.get_last_message;

         RETURN;


      ELSIF x_att_rec.secondary_quantity IS NOT NULL THEN
         /*
         rcv_error_pkg.set_error_message('PO_SECONDARY_QTY_NOT_REQUIRED');
         RAISE e_validation_error;
        */
         x_att_rec.error_record.error_status  := fnd_api.g_ret_sts_error;
         rcv_error_pkg.set_error_message('PO_SECONDARY_QTY_NOT_REQUIRED');
         x_att_rec.error_record.error_message  := rcv_error_pkg.get_last_message;

         RETURN;


      ELSE
         /* Having this return statement so that program exits as successful if no secondary parameter has been input for a non dual item*/
         x_att_rec.error_record.error_status  := FND_API.G_RET_STS_SUCCESS;
         RETURN;
      END IF;
   END IF;

      /* If it is dual UOM controlled then only proceed */


   IF x_att_rec.secondary_uom_code IS NOT NULL AND x_att_rec.secondary_unit_of_measure IS NULL THEN

      l_progress :='0007';

      BEGIN

      SELECT   SECONDARY_UOM_CODE
         INTO  l_secondary_uom_code
         FROM  MTL_SYSTEM_ITEMS_B
         WHERE MTL_SYSTEM_ITEMS_B.INVENTORY_ITEM_ID = x_att_rec.inventory_item_id
         AND   MTL_SYSTEM_ITEMS_B.ORGANIZATION_ID = x_att_rec.to_organization_id;

      IF g_asn_debug = 'Y' THEN
         asn_debug.put_line('Secondary uom code derived in VALIDATE_SECONDARY_PARAMETERS is ' ||l_secondary_uom_code||':'||l_progress );
      END IF;

      IF l_secondary_uom_code <> x_att_rec.secondary_uom_code THEN
         l_progress :='0008JN';
         IF g_asn_debug = 'Y' THEN
            asn_debug.put_line('Secondary uom code validation failed in VALIDATE_SECONDARY_PARAMETERS:' || l_progress);
         END IF;

         /*Log error into po_interface_error*/
         /*
         rcv_error_pkg.set_error_message('PO_INCORRECT_SECONDARY_UOM');
         RAISE e_validation_error;
         */
         x_att_rec.error_record.error_status  := fnd_api.g_ret_sts_error;
         rcv_error_pkg.set_error_message('PO_INCORRECT_SECONDARY_UOM');
         x_att_rec.error_record.error_message  := rcv_error_pkg.get_last_message;

         RETURN;

      ELSE
         Select UNIT_OF_MEASURE
            INTO  x_att_rec.secondary_unit_of_measure
            FROM  mtl_units_of_measure
            WHERE uom_code = x_att_rec.secondary_uom_code;

         l_progress :='0009';
         IF g_asn_debug = 'Y' THEN
            asn_debug.put_line('Secondary unit of measure derived in VALIDATE_SECONDARY_PARAMETERS is ' ||x_att_rec.secondary_unit_of_measure||':'||l_progress );
         END IF;
      END IF;

      EXCEPTION
         WHEN OTHERS THEN
            IF g_asn_debug = 'Y' THEN
               asn_debug.put_line('SQL in validate_secondary_parameters failed:' || l_progress);
            END IF;
            x_att_rec.error_record.error_status  := fnd_api.g_ret_sts_unexp_error;
            rcv_error_pkg.set_sql_error_message('Unexpected Exception:validate_secondary_parameters', l_progress);
            x_att_rec.error_record.error_message  := rcv_error_pkg.get_last_message;

            RETURN;
      END;

   ELSIF x_att_rec.secondary_uom_code IS NULL AND x_att_rec.secondary_unit_of_measure IS NOT NULL THEN

      l_progress :='0010';

      BEGIN

      SELECT   SECONDARY_UOM_CODE
         INTO  x_att_rec.secondary_uom_code
         FROM  MTL_SYSTEM_ITEMS_B
         WHERE MTL_SYSTEM_ITEMS_B.INVENTORY_ITEM_ID=x_att_rec.inventory_item_id
         AND   MTL_SYSTEM_ITEMS_B.ORGANIZATION_ID=x_att_rec.to_organization_id;

          IF g_asn_debug = 'Y' THEN
             asn_debug.put_line('Secondary uom code derived in VALIDATE_SECONDARY_PARAMETERS is ' ||x_att_rec.secondary_uom_code ||':'||l_progress);
          END IF;

      SELECT   UNIT_OF_MEASURE
         INTO  l_secondary_unit_of_measure
         FROM  mtl_units_of_measure
         WHERE uom_code = x_att_rec.secondary_uom_code;

       l_progress :='0011';
       IF g_asn_debug = 'Y' THEN
          asn_debug.put_line('Secondary unit of measure derived in VALIDATE_SECONDARY_PARAMETERS is ' ||l_secondary_unit_of_measure||':'|| l_progress );
       END IF;

      IF l_secondary_unit_of_measure <> x_att_rec.secondary_unit_of_measure THEN

         l_progress :='0012';
         IF g_asn_debug = 'Y' THEN
            asn_debug.put_line('Secondary unit of measure validation failed in VALIDATE_SECONDARY_PARAMETERS'||':'||l_progress);
         END IF;

         /*Log error into po_interface_error*/
         /*
         rcv_error_pkg.set_error_message('PO_INCORRECT_SECONDARY_UOM');
         RAISE e_validation_error;
         */
         x_att_rec.error_record.error_status  := fnd_api.g_ret_sts_error;
         rcv_error_pkg.set_error_message('PO_INCORRECT_SECONDARY_UOM');
         x_att_rec.error_record.error_message  := rcv_error_pkg.get_last_message;

         RETURN;

      END IF;

      EXCEPTION
         WHEN OTHERS THEN
            IF g_asn_debug = 'Y' THEN
               asn_debug.put_line('SQL in validate_secondary_parameters failed:' || l_progress);
            END IF;
            x_att_rec.error_record.error_status  := fnd_api.g_ret_sts_unexp_error;
            rcv_error_pkg.set_sql_error_message('Unexpected Exception:validate_secondary_parameters', l_progress);
            x_att_rec.error_record.error_message  := rcv_error_pkg.get_last_message;

            RETURN;
      END;

   ELSIF  x_att_rec.secondary_uom_code IS NULL AND x_att_rec.secondary_unit_of_measure IS NULL THEN

      l_progress :='0013';

      BEGIN

      SELECT   SECONDARY_UOM_CODE
         INTO  x_att_rec.secondary_uom_code
         FROM  MTL_SYSTEM_ITEMS_B
         WHERE MTL_SYSTEM_ITEMS_B.INVENTORY_ITEM_ID=x_att_rec.inventory_item_id
         AND   MTL_SYSTEM_ITEMS_B.ORGANIZATION_ID=x_att_rec.to_organization_id;

      IF g_asn_debug = 'Y' THEN
         asn_debug.put_line('Secondary uom code derived in VALIDATE_SECONDARY_PARAMETERS is ' ||x_att_rec.secondary_uom_code||':'||l_progress );
      END IF;

      Select   UNIT_OF_MEASURE
         INTO  x_att_rec.secondary_unit_of_measure
         FROM  mtl_units_of_measure
         WHERE uom_code = x_att_rec.secondary_uom_code;

      l_progress :='0014';
      IF g_asn_debug = 'Y' THEN
         asn_debug.put_line('Secondary unit of measure derived in VALIDATE_SECONDARY_PARAMETERS is ' ||x_att_rec.secondary_unit_of_measure ||':'||l_progress);
      END IF;

      EXCEPTION
         WHEN OTHERS THEN
            IF g_asn_debug = 'Y' THEN
               asn_debug.put_line('SQL in validate_secondary_parameters failed:' || l_progress);
            END IF;
            x_att_rec.error_record.error_status  := fnd_api.g_ret_sts_unexp_error;
            rcv_error_pkg.set_sql_error_message('Unexpected Exception:validate_secondary_parameters', l_progress);
            x_att_rec.error_record.error_message  := rcv_error_pkg.get_last_message;

            RETURN;
      END;

   ELSIF  x_att_rec.secondary_uom_code IS NOT NULL AND x_att_rec.secondary_unit_of_measure IS NOT NULL THEN

      l_progress :='0015';

      BEGIN

      SELECT   SECONDARY_UOM_CODE
         INTO  l_secondary_uom_code
         FROM  MTL_SYSTEM_ITEMS_B
         WHERE MTL_SYSTEM_ITEMS_B.INVENTORY_ITEM_ID=x_att_rec.inventory_item_id
         AND   MTL_SYSTEM_ITEMS_B.ORGANIZATION_ID=x_att_rec.to_organization_id;

      IF g_asn_debug = 'Y' THEN
         asn_debug.put_line('Secondary uom code derived in VALIDATE_SECONDARY_PARAMETERS is ' ||l_secondary_uom_code||':'||l_progress );
      END IF;

      IF l_secondary_uom_code <>x_att_rec.secondary_uom_code THEN
         l_progress :='0016';
         IF g_asn_debug = 'Y' THEN
            asn_debug.put_line('Secondary uom code validation failed in VALIDATE_SECONDARY_PARAMETERS:'||l_progress);
         END IF;

         /*Log error into po_interface_error*/
         /*
         rcv_error_pkg.set_error_message('PO_INCORRECT_SECONDARY_UOM');
         RAISE e_validation_error;
         */
         x_att_rec.error_record.error_status  := fnd_api.g_ret_sts_error;
         rcv_error_pkg.set_error_message('PO_INCORRECT_SECONDARY_UOM');
         x_att_rec.error_record.error_message  := rcv_error_pkg.get_last_message;

         RETURN;


      ELSE
         /*Secondary uom code matches so now validate the secondary unit of measure*/
         l_progress :='0017';

         SELECT   UNIT_OF_MEASURE
            INTO  l_secondary_unit_of_measure
            FROM  mtl_units_of_measure
            WHERE uom_code = x_att_rec.secondary_uom_code;

         l_progress :='0171';
         IF g_asn_debug = 'Y' THEN
            asn_debug.put_line('Secondary unit of measure derived in VALIDATE_SECONDARY_PARAMETERS is ' ||l_secondary_unit_of_measure||':'|| l_progress );
         END IF;

         IF l_secondary_unit_of_measure <> x_att_rec.secondary_unit_of_measure THEN

            l_progress :='0172';

            IF g_asn_debug = 'Y' THEN
               asn_debug.put_line('Secondary unit of measure validation failed in VALIDATE_SECONDARY_PARAMETERS'||':'||l_progress);
            END IF;

            /*Log error into po_interface_error*/
            /*
            rcv_error_pkg.set_error_message('PO_INCORRECT_SECONDARY_UOM');
            RAISE e_validation_error;
            */
            x_att_rec.error_record.error_status  := fnd_api.g_ret_sts_error;
            rcv_error_pkg.set_error_message('PO_INCORRECT_SECONDARY_UOM');
            x_att_rec.error_record.error_message  := rcv_error_pkg.get_last_message;

            RETURN;


         END IF; -----IF l_secondary_unit_of_measure <> x_att_rec.secondary_unit_of_measure THEN

      END IF; ------------IF l_secondary_uom_code <>x_att_rec.secondary_uom_code THEN

      EXCEPTION
         WHEN OTHERS THEN
            IF g_asn_debug = 'Y' THEN
               asn_debug.put_line('SQL in validate_secondary_parameters failed:' || l_progress);
            END IF;
            x_att_rec.error_record.error_status  := fnd_api.g_ret_sts_unexp_error;
            rcv_error_pkg.set_sql_error_message('Unexpected Exception:validate_secondary_parameters', l_progress);
            x_att_rec.error_record.error_message  := rcv_error_pkg.get_last_message;

            RETURN;
      END;

   END IF; --------IF x_att_rec.secondary_uom_code IS NOT NULL AND x_att_rec.secondary_unit_of_measure IS NULL THEN

  IF l_lot_number is null then  --Bug 13938193 add this filter

--BUG#13401431 added the l_conv_exist to check lot specific conversion is existing or not.
--if its existing then by pass this check. as already deviation is checked.
   IF  x_att_rec.secondary_quantity IS  NOT NULL  AND l_secondary_default_ind IN ('D','N')AND l_conv_exist <>1  THEN
      l_progress :='0018';
      IF g_asn_debug = 'Y' THEN
         asn_debug.put_line('Before calling within deviation check  in VALIDATE_SECONDARY_PARAMETERS:' ||l_progress);
      END IF;

      l_check_dev := INV_CONVERT.Within_deviation(
                                                  p_organization_id     => X_ATT_REC.to_organization_id           ,
                                                  p_inventory_item_id   => X_ATT_REC.inventory_item_id            ,
                                                  p_lot_number  		=> NULL  ,  --as no lot is defined
                                                  p_precision   	      => 5                                      ,
                                                  p_quantity			   => X_ATT_REC.transaction_quantity         ,
                                                  p_uom_code1		 	   => NULL                                   ,
                                                  p_quantity2     	   => X_ATT_REC.secondary_quantity           ,
                                                  p_uom_code2		 	   => NULL                                   ,
                                                  p_unit_of_measure1    => X_ATT_REC.transaction_unit_of_measure  ,
                                                  p_unit_of_measure2    => X_ATT_REC.Secondary_unit_of_measure
                                                  );

      /* Returns  1 for True and  0 for False*/

      IF  l_check_dev=0 THEN
         l_progress :='0019';
         IF g_asn_debug = 'Y' THEN
            asn_debug.put_line('within deviation check failed in VALIDATE_SECONDARY_PARAMETERS:' || l_progress);
         END IF;
         /*Log error into po_interface_error */
         x_att_rec.error_record.error_status  := fnd_api.g_ret_sts_error;
         rcv_error_pkg.set_error_message('PO_SRCE_ORG_OUT_OF_DEV');
         x_att_rec.error_record.error_message  := rcv_error_pkg.get_last_message;

         RETURN;
      END IF;

      l_progress :='0020';
      IF g_asn_debug = 'Y' THEN
         asn_debug.put_line('After successfully calling within deviation check  in VALIDATE_SECONDARY_PARAMETERS:' || l_progress);
      END IF;


   ELSE -------- x_att_rec.secondary_quantity IS  NULL OR l_secondary_default_ind = 'F' THEN
      /*Calculate the secondary quantity if it is null or the item is of fixed type.
      As for fixed type we do not check deviation but the secondary quantity has
      to be fixed according to a predefined conversion*/

      l_progress :='0021';

      IF g_asn_debug = 'Y' THEN
         asn_debug.put_line('Befordesc inv_e calling INV_CONVERT.Inv_um_convert for fetching secondary quantity in VALIDATE_SECONDARY_PARAMETERS:'||l_progress);
      END IF;

      x_att_rec.secondary_quantity:= INV_CONVERT.Inv_um_convert (
                                                                 item_id           => x_att_rec.inventory_item_id            ,
                                                                 lot_number        => NULL	                            ,
                                                                 organization_id	  => x_att_rec.to_organization_id           ,
                                                                 precision	        => 5                                      ,
                                                                 from_quantity     => x_att_rec.transaction_quantity         ,
                                                                 from_unit	        => NULL                                   ,
                                                                 to_unit   		  => NULL                                   ,
                                                                 from_name         => x_att_rec.transaction_unit_of_measure  ,
                                                                 to_name           => x_att_rec.secondary_unit_of_measure
                                                                 );



      IF x_att_rec.secondary_quantity = -99999  THEN
         l_progress :='0022';
         IF g_asn_debug = 'Y' THEN
            asn_debug.put_line('fetch secondary quantity failed in VALIDATE_SECONDARY_PARAMETERS:' || l_progress);
         END IF;
         /*Log error into po_interface_error */
         x_att_rec.error_record.error_status  := fnd_api.g_ret_sts_unexp_error;
         rcv_error_pkg.set_sql_error_message('Unexpected exception :fetch secondary quantity failed in validate_secondary_parameters', l_progress);
         x_att_rec.error_record.error_message  := rcv_error_pkg.get_last_message;

         RETURN;
      END IF;

      l_progress :='0023';
      IF g_asn_debug = 'Y' THEN
         asn_debug.put_line('After successfully calling INV_CONVERT.Inv_um_convert for fetching secondary quantity in VALIDATE_SECONDARY_PARAMETERS:' || l_progress);
         asn_debug.put_line('value of secondary quantity derived by INV_CONVERT.Inv_um_convert is:'|| x_att_rec.secondary_quantity);
      END IF;


   END IF;-----IF x_att_rec.secondary_quantity IS  NOT NULL  AND l_secondary_default_ind IN ('D','N') THEN

   --Bug 13938193 add below part to handle multiple lots in one transaction of RTI.
  ELSE
   FOR lot_rec1 IN lot_num_cur1(p_transaction_id)
    LOOP
    BEGIN
     SELECT 1 INTO l_conv_exist
       FROM   mtl_lot_uom_class_conversions
       WHERE  organization_id = x_att_rec.to_organization_id
       AND    lot_number = lot_rec1.LOT_NUMBER
       AND    inventory_item_id = x_att_rec.inventory_item_id
       AND    FROM_UNIT_OF_MEASURE=X_ATT_REC.transaction_unit_of_measure
       AND    TO_UNIT_OF_MEASURE=x_att_rec.Secondary_UNIT_OF_MEASURE;
     EXCEPTION
       WHEN No_Data_Found  THEN
       l_conv_exist:=0;
     END  ;

   IF  lot_rec1.secondary_transaction_quantity IS  NOT NULL  AND l_secondary_default_ind IN ('D','N')AND l_conv_exist <>1  THEN
      l_progress :='0018';
      IF g_asn_debug = 'Y' THEN
         asn_debug.put_line('Before calling within deviation check  in VALIDATE_SECONDARY_PARAMETERS:' ||l_progress);
      END IF;

      l_check_dev := INV_CONVERT.Within_deviation(
                                                  p_organization_id     => X_ATT_REC.to_organization_id           ,
                                                  p_inventory_item_id   => X_ATT_REC.inventory_item_id            ,
                                                   /*  p_lot_number  		=> NULL   as no lot is defined */
                                                  p_lot_number  		    =>lot_rec1.LOT_NUMBER                            ,      /*BUG#13938193*/
                                                  p_precision   	      => 5                                      ,
                                                  p_quantity			      => lot_rec1.transaction_quantity         ,
                                                  p_uom_code1		 	      => NULL                                   ,
                                                  p_quantity2     	    => lot_rec1.secondary_transaction_quantity,
                                                  p_uom_code2		 	      => NULL                                   ,
                                                  p_unit_of_measure1    => X_ATT_REC.transaction_unit_of_measure  ,
                                                  p_unit_of_measure2    => X_ATT_REC.Secondary_unit_of_measure
                                                  );



      /* Returns  1 for True and  0 for False*/

      IF  l_check_dev=0 THEN
         l_progress :='0019';
         IF g_asn_debug = 'Y' THEN
            asn_debug.put_line('within deviation check failed in VALIDATE_SECONDARY_PARAMETERS:' || l_progress);
         END IF;
         /*Log error into po_interface_error */
         x_att_rec.error_record.error_status  := fnd_api.g_ret_sts_error;
         rcv_error_pkg.set_error_message('PO_SRCE_ORG_OUT_OF_DEV');
         x_att_rec.error_record.error_message  := rcv_error_pkg.get_last_message;

         RETURN;
      END IF;

      l_sec_lot_dev_tqty := lot_rec1.secondary_transaction_quantity + l_sec_lot_dev_tqty ;

      l_progress :='0020';
      IF g_asn_debug = 'Y' THEN
         asn_debug.put_line('After successfully calling within deviation check  in VALIDATE_SECONDARY_PARAMETERS:' || l_progress);
      END IF;


   ELSE -------- x_att_rec.secondary_quantity IS  NULL OR l_secondary_default_ind = 'F' THEN
      /*Calculate the secondary quantity if it is null or the item is of fixed type.
      As for fixed type we do not check deviation but the secondary quantity has
      to be fixed according to a predefined conversion*/

      l_progress :='0021';

      IF g_asn_debug = 'Y' THEN
         asn_debug.put_line('Befordesc inv_e calling INV_CONVERT.Inv_um_convert for fetching secondary quantity in VALIDATE_SECONDARY_PARAMETERS:'||l_progress);
      END IF;


       l_sec_lot_spe_qty := INV_CONVERT.Inv_um_convert (
                                                                 item_id           => X_ATT_REC.inventory_item_id            ,
                                                                  /* lot_number        => NULL	                            ,      */
                                                                 lot_number  	     =>lot_rec1.LOT_NUMBER                           ,
                                                                 organization_id	  => X_ATT_REC.to_organization_id           ,
                                                                 precision	        => 5                                      ,
                                                                 from_quantity     => lot_rec1.transaction_quantity         ,
                                                                 from_unit	        => NULL                                   ,
                                                                 to_unit   		  => NULL                                   ,
                                                                 from_name         => X_ATT_REC.transaction_unit_of_measure  ,
                                                                 to_name           => X_ATT_REC.secondary_unit_of_measure
                                                                 );


        l_sec_lot_spe_tqty := l_sec_lot_spe_qty + l_sec_lot_spe_tqty;



   END IF;-----IF x_att_rec.secondary_quantity IS  NOT NULL  AND l_secondary_default_ind IN ('D','N') THEN


   END LOOP ; --FOR lot_rec1 IN lot_num_cur1(p_transaction_id)

     x_att_rec.secondary_quantity := l_sec_lot_dev_tqty + l_sec_lot_spe_tqty;

     --End Bug 13938193
  END IF ;-- IF l_lot_number is null


   l_progress :='0024';
   IF g_asn_debug = 'Y' THEN
      asn_debug.put_line('End of  VALIDATE_SECONDARY_PARAMETERS:' || l_progress);
   END IF;


EXCEPTION
   WHEN e_validation_error THEN
      x_att_rec.error_record.error_status   := fnd_api.g_ret_sts_error;
      x_att_rec.error_record.error_message  := rcv_error_pkg.get_last_message;

   WHEN OTHERS THEN
         x_att_rec.error_record.error_status  := fnd_api.g_ret_sts_unexp_error;
         rcv_error_pkg.set_sql_error_message('Unexpected exception:validate_secondary_parameters', l_progress);
         x_att_rec.error_record.error_message  := rcv_error_pkg.get_last_message;


END VALIDATE_SECONDARY_PARAMETERS;

/* <Consigned Inventory Pre-Processor FPI END> */
END rcv_transactions_interface_sv1;



/
