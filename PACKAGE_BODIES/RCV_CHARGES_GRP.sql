--------------------------------------------------------
--  DDL for Package Body RCV_CHARGES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_CHARGES_GRP" AS
/* $Header: RCVGFSCB.pls 120.11.12010000.2 2010/01/25 22:43:25 vthevark ship $*/

-- package globals
g_base_weight_uom mtl_units_of_measure.unit_of_measure%TYPE;
g_base_volume_uom mtl_units_of_measure.unit_of_measure%TYPE;
g_asn_debug VARCHAR2(1) := asn_debug.is_debug_on; -- Bug 9152790

UNKNOWN_ALLOCATION_METHOD EXCEPTION;

FUNCTION get_base_weight_uom
RETURN VARCHAR2
IS
BEGIN
    IF g_base_weight_uom IS NULL THEN
        SELECT unit_of_measure
          INTO g_base_weight_uom
          FROM mtl_units_of_measure_tl
         WHERE base_uom_flag = 'Y'
           AND uom_class = 'Weight'
           AND ROWNUM < 2;
    END IF;

    RETURN g_base_weight_uom;
END get_base_weight_uom;

FUNCTION get_base_volume_uom
RETURN VARCHAR2
IS
BEGIN
    IF g_base_volume_uom IS NULL THEN
        SELECT unit_of_measure
          INTO g_base_volume_uom
          FROM mtl_units_of_measure_tl
         WHERE base_uom_flag = 'Y'
           AND uom_class = 'Volume'
           AND ROWNUM < 2;
    END IF;

    RETURN g_base_volume_uom;
END get_base_volume_uom;

PROCEDURE Derive_Cost_Factor
( p_charge_record         IN OUT NOCOPY rcv_charges_interface%ROWTYPE
, p_header_record      IN            RCV_ROI_PREPROCESSOR.headers_cur%ROWTYPE
, p_transaction_record IN            RCV_ROI_PREPROCESSOR.txns_cur%ROWTYPE
) IS
BEGIN
    IF p_charge_record.processing_status_code NOT IN ('S','W') THEN
        RETURN;
    END IF;

    IF     p_charge_record.cost_factor_id IS NULL
       AND p_charge_record.cost_factor_code IS NOT NULL
    THEN
        p_charge_record.cost_factor_id :=
            pon_cf_type_grp.get_cost_factor_details(p_charge_record.cost_factor_code).price_element_type_id;
    END IF;
END Derive_Cost_Factor;

Procedure default_vendor_info
( p_charge_record         IN OUT NOCOPY rcv_charges_interface%ROWTYPE
, p_header_record      IN            RCV_ROI_PREPROCESSOR.headers_cur%ROWTYPE
, p_transaction_record IN            RCV_ROI_PREPROCESSOR.txns_cur%ROWTYPE
) IS
BEGIN
    IF p_charge_record.processing_status_code NOT IN ('S','W') THEN
        RETURN;
    END IF;

    IF p_charge_record.parent_interface_id IS NULL THEN
        -- header-level charge
        IF p_charge_record.vendor_id IS NULL THEN
            p_charge_record.vendor_id := p_header_record.vendor_id;
        END IF;

        IF p_charge_record.vendor_site_id IS NULL THEN
            p_charge_record.vendor_site_id := p_header_record.vendor_site_id;
        END IF;
    ELSE
        -- line-level charge
        IF p_charge_record.vendor_id IS NULL THEN
            p_charge_record.vendor_id := p_transaction_record.vendor_id;
        END IF;

        IF p_charge_record.vendor_site_id IS NULL THEN
            p_charge_record.vendor_site_id := p_transaction_record.vendor_site_id;
        END IF;
    END IF;
END;

Procedure default_currency_info
( p_charge_record         IN OUT NOCOPY rcv_charges_interface%ROWTYPE
, p_header_record      IN            RCV_ROI_PREPROCESSOR.headers_cur%ROWTYPE
, p_transaction_record IN            RCV_ROI_PREPROCESSOR.txns_cur%ROWTYPE
) IS
BEGIN
    IF p_charge_record.processing_status_code NOT IN ('S','W') THEN
        RETURN;
    END IF;

    IF p_charge_record.parent_interface_id IS NOT NULL THEN
       -- line-level charge
        IF      p_charge_record.currency_code IS NOT NULL
            AND p_charge_record.currency_conversion_type IS NULL
            AND p_charge_record.currency_conversion_rate IS NULL
            AND p_charge_record.currency_conversion_date IS NULL
        THEN
            p_charge_record.currency_code := p_transaction_record.currency_code;
            p_charge_record.currency_conversion_type := p_transaction_record.currency_conversion_type;
            p_charge_record.currency_conversion_rate := p_transaction_record.currency_conversion_rate;
            p_charge_record.currency_conversion_date := p_transaction_record.currency_conversion_date;
        END IF;
    END IF;
END;

-- make sure cost factor is defined in cost factor setup.
Procedure Validate_cost_factor
( p_charge_record      IN OUT NOCOPY rcv_charges_interface%ROWTYPE
, p_header_record      IN            RCV_ROI_PREPROCESSOR.headers_cur%ROWTYPE
, p_transaction_record IN            RCV_ROI_PREPROCESSOR.txns_cur%ROWTYPE
) IS
BEGIN
    -- errored out already
    IF p_charge_record.processing_status_code NOT IN ('S','W') THEN
        RETURN;
    END IF;

    IF pon_cf_type_grp.get_cost_factor_details(p_charge_record.cost_factor_id)
           .price_element_type_id IS NULL
    THEN
        asn_debug.put_line('Invalid cost factor id: ' || p_charge_record.cost_factor_id);
        rcv_error_pkg.set_error_message('RCV_INVALID_ROI_VALUE');
        rcv_error_pkg.set_token('COLUMN', 'COST_FACTOR_ID');
        rcv_error_pkg.set_token('ROI_VALUE', p_charge_record.cost_factor_id);
        rcv_error_pkg.set_token('SYS_VALUE', '');
        rcv_error_pkg.log_interface_error( 'RCV_CHARGES_INTERFACE'
                                         , 'COST_FACTOR_ID'
                                         , FALSE
                                         );

        p_charge_record.processing_status_code := 'E';
    END IF;
END;

-- validate vendor_id and vendor_site_id exist.
Procedure Validate_vendor_info
( p_charge_record         IN OUT NOCOPY rcv_charges_interface%ROWTYPE
, p_header_record      IN            RCV_ROI_PREPROCESSOR.headers_cur%ROWTYPE
, p_transaction_record IN            RCV_ROI_PREPROCESSOR.txns_cur%ROWTYPE
) IS
    l_vendor_record      RCV_SHIPMENT_HEADER_SV.vendorrectype;
BEGIN
    -- errored out already
    IF p_charge_record.processing_status_code NOT IN ('S','W') THEN
        RETURN;
    END IF;

    -- validated for item already
    IF p_charge_record.vendor_id = p_header_record.vendor_id THEN
        RETURN;
    END IF;

    -- validate vendor info
    l_vendor_record.vendor_id := p_charge_record.vendor_id;
    po_vendors_sv.validate_vendor_info(l_vendor_record);

    IF l_vendor_record.error_record.error_status = 'E' THEN
        asn_debug.put_line('validate_vendor_info returned error: vendor_id: ' || p_charge_record.vendor_id);
        IF l_vendor_record.error_record.error_message = 'VEN_DISABLED' THEN
            asn_debug.put_line('Invalid vendor id: ' || p_charge_record.vendor_id);
            rcv_error_pkg.set_error_message('PO_PDOI_INVALID_VENDOR');
            rcv_error_pkg.set_token('VALUE', l_vendor_record.vendor_id);
            rcv_error_pkg.log_interface_error( 'RCV_CHARGES_INTERFACE'
                                             , 'VENDOR_ID'
                                             , FALSE
                                             );
        ELSIF l_vendor_record.error_record.error_message = 'VEN_HOLD' THEN
            asn_debug.put_line('Invalid vendor id: ' || p_charge_record.vendor_id);
            rcv_error_pkg.set_error_message('PO_PO_VENDOR_ON_HOLD');
            rcv_error_pkg.set_token('VALUE', l_vendor_record.vendor_id);
            rcv_error_pkg.log_interface_error( 'RCV_CHARGES_INTERFACE'
                                             , 'VENDOR_ID'
                                             , FALSE
                                             );
        ELSIF l_vendor_record.error_record.error_message = 'VEN_ID' THEN
            asn_debug.put_line('Invalid vendor id: ' || p_charge_record.vendor_id);
            rcv_error_pkg.set_error_message('RCV_VEN_ID');
            rcv_error_pkg.set_token('SUPPLIER', l_vendor_record.vendor_id);
            rcv_error_pkg.log_interface_error( 'RCV_CHARGES_INTERFACE'
                                             , 'VENDOR_ID'
                                             , FALSE
                                             );
        END IF;

        p_charge_record.processing_status_code := 'E';
    END IF;
END Validate_vendor_info;

Procedure Validate_vendor_site_info
( p_charge_record         IN OUT NOCOPY rcv_charges_interface%ROWTYPE
, p_header_record      IN            RCV_ROI_PREPROCESSOR.headers_cur%ROWTYPE
, p_transaction_record IN            RCV_ROI_PREPROCESSOR.txns_cur%ROWTYPE
) IS
    l_vendor_site_record RCV_SHIPMENT_HEADER_SV.vendorsiterectype;
BEGIN
    IF p_charge_record.processing_status_code NOT IN ('S','W') THEN
        RETURN;
    END IF;

    -- validated for item already
    IF p_charge_record.vendor_site_id = p_header_record.vendor_site_id THEN
        RETURN;
    END IF;

    -- validate vendor site info
    l_vendor_site_record.vendor_id := p_charge_record.vendor_id;
    l_vendor_site_record.vendor_site_id := p_charge_record.vendor_site_id;
    po_vendor_sites_sv.validate_vendor_site_info(l_vendor_site_record);

    IF l_vendor_site_record.error_record.error_status = 'E' THEN
        asn_debug.put_line('validate_vendor_site_info returned error: vendor_id: ' || p_charge_record.vendor_id || ' vendor_site_id: ' || p_charge_record.vendor_site_id);
        IF l_vendor_site_record.error_record.error_message IN
                   ('VEN_SITE_ID', 'VEN_SITE_DISABLED', 'VEN_SITE_NOT_PURCH')
        THEN
            asn_debug.put_line('Invalid vendor site id: ' || p_charge_record.vendor_site_id);
            rcv_error_pkg.set_error_message('PO_PDOI_INVALID_VENDOR_SITE');
            rcv_error_pkg.set_token('VALUE', l_vendor_site_record.vendor_site_id);
            rcv_error_pkg.log_interface_error( 'RCV_HEADERS_INTERFACE'
                                             , 'VENDOR_SITE_ID'
                                             , FALSE
                                             );
        END IF;

        p_charge_record.processing_status_code := 'E';
    END IF;
END Validate_vendor_site_info;

-- validate positive amount
Procedure Validate_amount
( p_charge_record         IN OUT NOCOPY rcv_charges_interface%ROWTYPE
, p_header_record      IN            RCV_ROI_PREPROCESSOR.headers_cur%ROWTYPE
, p_transaction_record IN            RCV_ROI_PREPROCESSOR.txns_cur%ROWTYPE
) IS
BEGIN
    IF p_charge_record.processing_status_code NOT IN ('S','W') THEN
        RETURN;
    END IF;

    IF p_charge_record.amount <= 0 THEN
        rcv_error_pkg.set_error_message('RCV_ROI_INVALID_VALUE');
        rcv_error_pkg.set_token('COLUMN', 'AMOUNT');
        rcv_error_pkg.set_token('ROI_VALUE', p_charge_record.amount);
        rcv_error_pkg.set_token('SYS_VALUE', 'a positive value');
        rcv_error_pkg.log_interface_error( 'RCV_CHARGES_INTERFACE'
                                        , 'ESTIMATED_AMOUNT'
                                        , FALSE);

        p_charge_record.processing_status_code := 'E';
    END IF;
END;

-- validate currency code exists in system
Procedure Validate_currency_info
( p_charge_record         IN OUT NOCOPY rcv_charges_interface%ROWTYPE
, p_header_record      IN            RCV_ROI_PREPROCESSOR.headers_cur%ROWTYPE
, p_transaction_record IN            RCV_ROI_PREPROCESSOR.txns_cur%ROWTYPE
) IS
    l_currency_record rcv_shipment_header_sv.currectype;
BEGIN
    IF p_charge_record.processing_status_code NOT IN ('S','W') THEN
        RETURN;
    END IF;

    l_currency_record.currency_code := p_charge_record.currency_code;
    po_currency_sv.validate_currency_info(l_currency_record);

    IF l_currency_record.error_record.error_status = 'E' THEN
        IF l_currency_record.error_record.error_message IN
               ('CURRENCY_DISABLED', 'CURRENCY_INVALID')
        THEN
            rcv_error_pkg.set_error_message('PO_PDOI_INVALID_CURRENCY');
            rcv_error_pkg.set_token('VALUE', l_currency_record.currency_code);
            rcv_error_pkg.log_interface_error( 'RCV_HEADERS_INTERFACE'
                                             , 'CURRENCY_CODE'
                                             , FALSE
                                             );

            p_charge_record.processing_status_code := 'E';
        END IF;
    END IF;
END;

Procedure Derive_Charge_Info
( p_charge_record         IN OUT NOCOPY rcv_charges_interface%ROWTYPE
, p_header_record      IN            RCV_ROI_PREPROCESSOR.headers_cur%ROWTYPE
, p_transaction_record IN            RCV_ROI_PREPROCESSOR.txns_cur%ROWTYPE
) IS
BEGIN
    derive_cost_factor( p_charge_record
                      , p_header_record
                      , p_transaction_record
                      );
END Derive_Charge_Info;

Procedure Default_charge_info
( p_charge_record         IN OUT NOCOPY rcv_charges_interface%ROWTYPE
, p_header_record      IN            RCV_ROI_PREPROCESSOR.headers_cur%ROWTYPE
, p_transaction_record IN            RCV_ROI_PREPROCESSOR.txns_cur%ROWTYPE
) IS
BEGIN
    default_vendor_info(p_charge_record, p_header_record, p_transaction_record);
    default_currency_info(p_charge_record, p_header_record, p_transaction_record);
END;

Procedure Validate_charge_info
( p_charge_record      IN OUT NOCOPY rcv_charges_interface%ROWTYPE
, p_header_record      IN            RCV_ROI_PREPROCESSOR.headers_cur%ROWTYPE
, p_transaction_record IN            RCV_ROI_PREPROCESSOR.txns_cur%ROWTYPE
) IS
BEGIN
    Validate_cost_factor( p_charge_record, p_header_record, p_transaction_record );
    Validate_vendor_info( p_charge_record, p_header_record, p_transaction_record );
    Validate_amount( p_charge_record, p_header_record, p_transaction_record );
    Validate_currency_info( p_charge_record, p_header_record, p_transaction_record );
END;

Procedure Update_Interface_Charges
( p_charge_interface_table IN charge_interface_table_type
) IS
    l_interface_charge_id_tbl dbms_utility.number_array;
BEGIN
    FOR i IN 1..p_charge_interface_table.COUNT LOOP
        l_interface_charge_id_tbl(i) := p_charge_interface_table(i).interface_charge_id;
    END LOOP;

    FORALL i IN 1..p_charge_interface_table.COUNT
        UPDATE rcv_charges_interface
           SET ROW = p_charge_interface_table(i)
         WHERE interface_charge_id = l_interface_charge_id_tbl(i);
END Update_Interface_Charges;

Procedure Add_Charge_From_Interface
( p_charge_interface IN rcv_charges_interface%ROWTYPE
, p_charge_table IN OUT NOCOPY PO_CHARGES_GRP.charge_table_type
, p_shipment_header_id IN rcv_shipment_headers.shipment_header_id%TYPE
, p_shipment_line_id IN rcv_shipment_lines.shipment_line_id%TYPE
) IS
    l_charge po_rcv_charges%ROWTYPE;
    l_cost_factor_details pon_price_element_types_vl%ROWTYPE;
BEGIN
    SELECT po_rcv_charges_s.NEXTVAL
      INTO l_charge.charge_id
      FROM dual;

    l_charge.creation_date := SYSDATE;
    l_charge.created_by := FND_GLOBAL.user_id;
    l_charge.last_update_date := SYSDATE;
    l_charge.last_updated_by := FND_GLOBAL.user_id;

    l_charge.interface_charge_id := p_charge_interface.interface_charge_id;
    l_charge.shipment_header_id := p_shipment_header_id;
    IF p_charge_interface.parent_interface_id IS NOT NULL THEN
        l_charge.shipment_line_id := p_shipment_line_id;
    END IF;

    l_charge.cost_factor_id := p_charge_interface.cost_factor_id;
    l_charge.estimated_amount := p_charge_interface.amount;
    l_charge.vendor_id := p_charge_interface.vendor_id;
    l_charge.vendor_site_id := p_charge_interface.vendor_site_id;
    l_charge.currency_code := p_charge_interface.currency_code;
    l_charge.currency_conversion_type := p_charge_interface.currency_conversion_type;
    l_charge.currency_conversion_rate := p_charge_interface.currency_conversion_rate;
    l_charge.currency_conversion_date := p_charge_interface.currency_conversion_date;

    l_cost_factor_details := pon_cf_type_grp.get_cost_factor_details(p_charge_interface.cost_factor_id);
    l_charge.allocation_method := l_cost_factor_details.allocation_basis;
    l_charge.cost_component_class_id := l_cost_factor_details.cost_component_class_id;
    l_charge.cost_analysis_code := l_cost_factor_details.cost_analysis_code;
    l_charge.include_in_acquisition_cost := l_cost_factor_details.cost_acquisition_code;

     -- add to table at the end to avoid orphaned row on error
    p_charge_table(p_charge_table.COUNT+1) := l_charge;
END Add_Charge_From_Interface;

PROCEDURE Add_Allocation_From_Charge
( p_charge IN po_rcv_charges%ROWTYPE
, p_charge_allocation_table IN OUT NOCOPY PO_CHARGES_GRP.charge_allocation_table_type
) IS
    l_charge_allocation po_rcv_charge_allocations%ROWTYPE;
BEGIN
    SELECT po_rcv_charge_allocations_s.NEXTVAL
      INTO l_charge_allocation.charge_allocation_id
      FROM dual;

    l_charge_allocation.creation_date := SYSDATE;
    l_charge_allocation.created_by := FND_GLOBAL.user_id;
    l_charge_allocation.last_update_date := SYSDATE;
    l_charge_allocation.last_updated_by := FND_GLOBAL.user_id;

    l_charge_allocation.charge_id := p_charge.charge_id;
    l_charge_allocation.shipment_line_id := p_charge.shipment_line_id;
    l_charge_allocation.estimated_amount := p_charge.estimated_amount;
    l_charge_allocation.actual_amount := p_charge.actual_amount;

--    l_charge_allocation.est_recoverable_tax
--    l_charge_allocation.est_non_recoverable_tax
--    l_charge_allocation.act_recoverable_tax
--    l_charge_allocation.act_non_recoverable_tax

    -- add to table at the end to avoid orphaned row on error
    p_charge_allocation_table(p_charge_allocation_table.COUNT+1) := l_charge_allocation;
END Add_Allocation_From_Charge;

PROCEDURE Allocate_Line_Level_Charge
( p_charge IN po_rcv_charges%ROWTYPE
, p_charge_allocation_table IN OUT NOCOPY PO_CHARGES_GRP.charge_allocation_table_type
) IS
BEGIN
    -- all we need to do is instantiate a new allocation based on the charge
    Add_Allocation_From_Charge
        ( p_charge
        , p_charge_allocation_table
        );
END Allocate_Line_Level_Charge;

PROCEDURE Prorate_Charge
( p_charge IN po_rcv_charges%ROWTYPE
, p_charge_allocation_table IN OUT NOCOPY PO_CHARGES_GRP.charge_allocation_table_type
, p_id_table IN dbms_utility.number_array
, p_prorate_table IN dbms_utility.number_array
) IS
    l_total NUMBER := 0;
    l_ratio NUMBER;
    l_remaining_estimated_amount NUMBER;
    l_remaining_actual_amount NUMBER;
    l_precision NUMBER;
    j NUMBER;
BEGIN
    asn_debug.put_line('Prorating across ' || p_prorate_table.COUNT || ' rows');

    IF p_id_table.COUNT < 1 OR p_prorate_table.COUNT < 1 THEN
        RETURN;
    END IF;

    IF p_id_table.COUNT <> p_prorate_table.COUNT THEN
        RETURN;
    END IF;

    -- get the precision for rounding
    DECLARE
        l_ext_precision NUMBER;
        l_min_acct_unit NUMBER;
    BEGIN
        FND_CURRENCY_CACHE.get_info( currency_code => p_charge.currency_code
                                   , precision => l_precision
                                   , ext_precision => l_ext_precision
                                   , min_acct_unit => l_min_acct_unit
                                   );
    END;

    -- get the total for proration
    FOR i IN 1..p_prorate_table.COUNT LOOP
        l_total := l_total + p_prorate_table(i);
    END LOOP;

    -- initialize the remaining amounts for the last row
    l_remaining_estimated_amount := p_charge.estimated_amount;
    l_remaining_actual_amount := p_charge.actual_amount;

    -- allocate the charge amounts based on the prorate table
    FOR i IN 1..p_id_table.COUNT LOOP
        -- default fields from the charge
        Add_Allocation_From_Charge( p_charge, p_charge_allocation_table );

        -- set the shipment line for this allocation
        p_charge_allocation_table(p_charge_allocation_table.COUNT).shipment_line_id := p_id_table(i);

        -- assign the prorated amounts
        l_ratio := p_prorate_table(i) / l_total;
        p_charge_allocation_table(p_charge_allocation_table.COUNT).estimated_amount :=
            ROUND( p_charge.estimated_amount * l_ratio
                 , l_precision);
        p_charge_allocation_table(p_charge_allocation_table.COUNT).actual_amount :=
            ROUND( p_charge.actual_amount * l_ratio
                 , l_precision);
        l_remaining_estimated_amount :=
            l_remaining_estimated_amount - p_charge_allocation_table(p_charge_allocation_table.COUNT).estimated_amount;
        l_remaining_actual_amount :=
            l_remaining_actual_amount - p_charge_allocation_table(p_charge_allocation_table.COUNT).actual_amount;
    END LOOP;

    -- the last row needs to take the remaining amount to keep the sum the same
    p_charge_allocation_table(p_charge_allocation_table.COUNT).estimated_amount :=
        p_charge_allocation_table(p_charge_allocation_table.COUNT).estimated_amount + l_remaining_estimated_amount;
    p_charge_allocation_table(p_charge_allocation_table.COUNT).actual_amount :=
        p_charge_allocation_table(p_charge_allocation_table.COUNT).actual_amount + l_remaining_actual_amount;
END Prorate_Charge;

PROCEDURE Allocate_Charge_By_Volume
( p_charge IN po_rcv_charges%ROWTYPE
, p_charge_allocation_table IN OUT NOCOPY PO_CHARGES_GRP.charge_allocation_table_type
) IS
    TYPE uom_table_type IS TABLE OF mtl_units_of_measure.unit_of_measure%TYPE;
    TYPE uom_class_table_type IS TABLE OF mtl_uom_classes.uom_class%TYPE;

    -- tables of values
    l_shipment_line_ids dbms_utility.number_array;
    l_organization_ids dbms_utility.number_array;
    l_item_ids dbms_utility.number_array;
    l_quantities dbms_utility.number_array;
    l_units_of_measure uom_table_type;
    l_uom_classes uom_class_table_type;
    l_primary_units_of_measure uom_table_type;
    l_unit_volumes dbms_utility.number_array;
    l_volume_uoms uom_table_type;
    l_volumes dbms_utility.number_array;

    -- simplifying conditions
    l_all_null_items boolean := TRUE;
    l_all_volume_uoms boolean := TRUE;
    l_all_same_item boolean := TRUE;
    l_all_same_uom boolean := TRUE;

    -- transient variables
    l_primary_quantity NUMBER;
    l_base_volume NUMBER;
BEGIN
    -- fetch the relevant shipments
    SELECT rsl.shipment_line_id
         , rsl.to_organization_id
         , rsl.item_id
         , decode(rsl.quantity_received, 0, rsl.quantity_shipped, rsl.quantity_received)
         , rsl.unit_of_measure
         , muom_rsl.uom_class
         , msi.primary_unit_of_measure
         , msi.unit_volume
         , muom_unit.unit_of_measure
      BULK COLLECT INTO l_shipment_line_ids
                      , l_organization_ids
                      , l_item_ids
                      , l_quantities
                      , l_units_of_measure
                      , l_uom_classes
                      , l_primary_units_of_measure
                      , l_unit_volumes
                      , l_volume_uoms
      FROM rcv_shipment_lines rsl
         , mtl_system_items msi
         , mtl_units_of_measure muom_rsl
         , mtl_units_of_measure muom_unit
     WHERE rsl.shipment_header_id = p_charge.shipment_header_id
       AND msi.inventory_item_id (+) = rsl.item_id
       AND msi.organization_id (+) = rsl.to_organization_id
       AND muom_unit.uom_code (+) = msi.volume_uom_code
       AND muom_rsl.unit_of_measure = rsl.unit_of_measure;

    FOR i IN 1..l_shipment_line_ids.COUNT LOOP
        l_all_null_items := l_all_null_items AND l_item_ids(i) IS NULL;
        l_all_volume_uoms := l_all_volume_uoms AND l_uom_classes(i) = 'Volume';

        IF i > 1 THEN
            l_all_same_uom := l_all_same_uom AND l_units_of_measure(i) = l_units_of_measure(i-1);
            l_all_same_item := l_all_same_item
                        AND l_item_ids(i) = l_item_ids(i-1)
                        AND l_organization_ids(i) = l_organization_ids(i-1);
        END IF;
    END LOOP;

    -- simplifying cases
    IF l_all_same_item AND l_all_same_uom THEN
        Prorate_Charge( p_charge
                      , p_charge_allocation_table
                      , l_shipment_line_ids
                      , l_quantities
                      );
        RETURN;
    END IF;

    FOR i IN 1..l_shipment_line_ids.COUNT LOOP
        -- convert quantity to primary uom and get volume from unit volume
        IF l_uom_classes(i) <> 'Volume' THEN
            po_uom_s.uom_convert( l_quantities(i)
                                , l_units_of_measure(i)
                                , l_item_ids(i)
                                , l_primary_units_of_measure(i)
                                , l_primary_quantity
                                );
            po_uom_s.uom_convert( l_primary_quantity * l_unit_volumes(i)
                                , l_volume_uoms(i)
                                , l_item_ids(i)
                                , get_base_volume_uom
                                , l_volumes(i)
                                );
        ELSE
            -- uom is already a volume, use intraclass conversion directly to base volume
            po_uom_s.uom_convert( l_quantities(i)
                                , l_units_of_measure(i)
                                , l_item_ids(i)
                                , get_base_volume_uom
                                , l_volumes(i)
                                );
        END IF;
    END LOOP;

    -- prorate the charge according to the volumes
    Prorate_Charge( p_charge
                  , p_charge_allocation_table
                  , l_shipment_line_ids
                  , l_volumes
                  );
END Allocate_Charge_By_Volume;

PROCEDURE Allocate_Charge_By_Weight
( p_charge IN po_rcv_charges%ROWTYPE
, p_charge_allocation_table IN OUT NOCOPY PO_CHARGES_GRP.charge_allocation_table_type
) IS
    TYPE uom_table_type IS TABLE OF mtl_units_of_measure.unit_of_measure%TYPE;
    TYPE uom_class_table_type IS TABLE OF mtl_uom_classes.uom_class%TYPE;

    -- tables of values
    l_shipment_line_ids dbms_utility.number_array;
    l_organization_ids dbms_utility.number_array;
    l_item_ids dbms_utility.number_array;
    l_quantities dbms_utility.number_array;
    l_units_of_measure uom_table_type;
    l_uom_classes uom_class_table_type;
    l_primary_units_of_measure uom_table_type;
    l_unit_weights dbms_utility.number_array;
    l_weight_uoms uom_table_type;
    l_weights dbms_utility.number_array;

    -- simplifying conditions
    l_all_null_items boolean := TRUE;
    l_all_weight_uoms boolean := TRUE;
    l_all_same_item boolean := TRUE;
    l_all_same_uom boolean := TRUE;

    -- transient variables
    l_primary_quantity NUMBER;
    l_base_weight NUMBER;
BEGIN
    -- fetch the relevant shipments
    SELECT rsl.shipment_line_id
         , rsl.to_organization_id
         , rsl.item_id
         , decode(rsl.quantity_received, 0, rsl.quantity_shipped, rsl.quantity_received)
         , rsl.unit_of_measure
         , muom_rsl.uom_class
         , msi.primary_unit_of_measure
         , msi.unit_weight
         , muom_unit.unit_of_measure
      BULK COLLECT INTO l_shipment_line_ids
                      , l_organization_ids
                      , l_item_ids
                      , l_quantities
                      , l_units_of_measure
                      , l_uom_classes
                      , l_primary_units_of_measure
                      , l_unit_weights
                      , l_weight_uoms
      FROM rcv_shipment_lines rsl
         , mtl_system_items msi
         , mtl_units_of_measure muom_rsl
         , mtl_units_of_measure muom_unit
     WHERE rsl.shipment_header_id = p_charge.shipment_header_id
       AND msi.inventory_item_id (+) = rsl.item_id
       AND msi.organization_id (+) = rsl.to_organization_id
       AND muom_unit.uom_code (+) = msi.weight_uom_code
       AND muom_rsl.unit_of_measure = rsl.unit_of_measure;

    FOR i IN 1..l_shipment_line_ids.COUNT LOOP
        l_all_null_items := l_all_null_items AND l_item_ids(i) IS NULL;
        l_all_weight_uoms := l_all_weight_uoms AND l_uom_classes(i) = 'Weight';

        IF i > 1 THEN
            l_all_same_uom := l_all_same_uom AND l_units_of_measure(i) = l_units_of_measure(i-1);
            l_all_same_item := l_all_same_item
                        AND l_item_ids(i) = l_item_ids(i-1)
                        AND l_organization_ids(i) = l_organization_ids(i-1);
        END IF;
    END LOOP;

    -- simplifying cases
    IF l_all_same_item AND l_all_same_uom THEN
        Prorate_Charge( p_charge
                      , p_charge_allocation_table
                      , l_shipment_line_ids
                      , l_quantities
                      );
        RETURN;
    END IF;

    FOR i IN 1..l_shipment_line_ids.COUNT LOOP
        -- convert quantity to primary uom and get weight from unit weight
        IF l_uom_classes(i) <> 'Weight' THEN
            po_uom_s.uom_convert( l_quantities(i)
                                , l_units_of_measure(i)
                                , l_item_ids(i)
                                , l_primary_units_of_measure(i)
                                , l_primary_quantity
                                );
            po_uom_s.uom_convert( l_primary_quantity * l_unit_weights(i)
                                , l_weight_uoms(i)
                                , l_item_ids(i)
                                , get_base_weight_uom
                                , l_weights(i)
                                );
        ELSE
            -- uom is already a weight, use intraclass conversion directly to base weight
            po_uom_s.uom_convert( l_quantities(i)
                                , l_units_of_measure(i)
                                , l_item_ids(i)
                                , get_base_weight_uom
                                , l_weights(i)
                                );
        END IF;
    END LOOP;

    -- prorate the charge according to the weights
    Prorate_Charge( p_charge
                  , p_charge_allocation_table
                  , l_shipment_line_ids
                  , l_weights
                  );
END Allocate_Charge_By_Weight;

PROCEDURE Allocate_Charge_By_Quantity
( p_charge IN po_rcv_charges%ROWTYPE
, p_charge_allocation_table IN OUT NOCOPY PO_CHARGES_GRP.charge_allocation_table_type
) IS
    l_shipment_line_ids dbms_utility.number_array;
    l_shipment_line_quantities dbms_utility.number_array;
BEGIN
    -- get the quantities to allocate across
    SELECT shipment_line_id
         , decode(quantity_received, 0, quantity_shipped, quantity_received)
      BULK COLLECT INTO l_shipment_line_ids
                      , l_shipment_line_quantities
      FROM rcv_shipment_lines
     WHERE shipment_header_id = p_charge.shipment_header_id;

    -- prorate the charge according to the quantities
    Prorate_Charge( p_charge
                  , p_charge_allocation_table
                  , l_shipment_line_ids
                  , l_shipment_line_quantities
                  );
END Allocate_Charge_By_Quantity;

PROCEDURE Allocate_Charge_By_Value
( p_charge IN po_rcv_charges%ROWTYPE
, p_charge_allocation_table IN OUT NOCOPY PO_CHARGES_GRP.charge_allocation_table_type
) IS
    l_shipment_line_ids dbms_utility.number_array;
    l_shipment_line_amounts dbms_utility.number_array;
BEGIN
    asn_debug.put_line('Allocating header level charge by value for shipment header id ' || p_charge.shipment_header_id);

    -- get the item values to allocate across
    SELECT rsl.shipment_line_id
         , decode(rsl.quantity_received, 0, rsl.quantity_shipped, rsl.quantity_received) * pol.unit_price
      BULK COLLECT INTO l_shipment_line_ids
                      , l_shipment_line_amounts
      FROM rcv_shipment_lines rsl
         , po_lines_all pol
     WHERE rsl.shipment_header_id = p_charge.shipment_header_id
       AND pol.po_line_id = rsl.po_line_id;

    asn_debug.put_line('id: ' || l_shipment_line_ids.count || ' amt: ' || l_shipment_line_amounts.count);

    -- prorate the charge according to the amounts
    Prorate_Charge( p_charge
                  , p_charge_allocation_table
                  , l_shipment_line_ids
                  , l_shipment_line_amounts
                  );
END Allocate_Charge_By_Value;

PROCEDURE Allocate_Header_Level_Charge
( p_charge IN OUT NOCOPY po_rcv_charges%ROWTYPE
, p_charge_allocation_table IN OUT NOCOPY PO_CHARGES_GRP.charge_allocation_table_type
) IS
BEGIN
    IF p_charge.allocation_method IS NULL THEN
        p_charge.allocation_method := 'VALUE';
    END IF;

    CASE p_charge.allocation_method
        WHEN 'WEIGHT' THEN
            Allocate_Charge_By_Weight( p_charge
                                     , p_charge_allocation_table
                                     );
        WHEN 'VOLUME' THEN
            Allocate_Charge_By_Volume( p_charge
                                     , p_charge_allocation_table
                                     );
        WHEN 'QUANTITY' THEN
            Allocate_Charge_By_Quantity( p_charge
                                       , p_charge_allocation_table
                                       );
        WHEN 'VALUE' THEN
            Allocate_Charge_By_Value( p_charge
                                    , p_charge_allocation_table
                                    );
        ELSE
            asn_debug.put_line('Unknown allocation method: ' || p_charge.allocation_method);
            rcv_error_pkg.set_error_message('RCV_UNKNOWN_ALLOCATION_METHOD');
            rcv_error_pkg.set_token('VALUE', p_charge.allocation_method);
            rcv_error_pkg.log_interface_error( 'RCV_CHARGES'
                                             , 'ALLOCATION_METHOD'
                                             , FALSE
                                             );
            RAISE UNKNOWN_ALLOCATION_METHOD;
    END CASE;
END Allocate_Header_Level_Charge;

PROCEDURE Allocate_Charges
( p_charge_table IN OUT NOCOPY PO_CHARGES_GRP.charge_table_type
, p_charge_allocation_table IN OUT NOCOPY PO_CHARGES_GRP.charge_allocation_table_type
, p_charge_interface_table IN OUT NOCOPY charge_interface_table_type
) IS
    l_rci_idx BINARY_INTEGER := 1;
BEGIN
    asn_debug.put_line('Allocating ' || p_charge_table.COUNT || ' charges');

    FOR i IN 1..p_charge_table.COUNT LOOP
    BEGIN
        asn_debug.put_line('Allocating charge ' || i);

        -- synchronize rci index
        WHILE l_rci_idx <= p_charge_interface_table.COUNT AND
              p_charge_table(i).interface_charge_id <> p_charge_interface_table(l_rci_idx).interface_charge_id
        LOOP
            l_rci_idx := l_rci_idx + 1;
        END LOOP;

        IF p_charge_table(i).shipment_line_id IS NULL THEN
            asn_debug.put_line('Header level charge');
            Allocate_Header_Level_Charge( p_charge_table(i)
                                        , p_charge_allocation_table
                                        );
        ELSE
            asn_debug.put_line('Line level charge');
            Allocate_Line_Level_Charge( p_charge_table(i)
                                      , p_charge_allocation_table
                                      );
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            asn_debug.put_line('Caught exception in Allocate_Charges: i=' || i || ' SQLERRM=' || SQLERRM);

            -- mark the error on the current charge interface row
            IF p_charge_interface_table.EXISTS(l_rci_idx) THEN
                p_charge_interface_table(l_rci_idx).transaction_status_code := 'E';
            END IF;

            -- delete any allocations tied to the current charge
            FOR j IN REVERSE 1..p_charge_allocation_table.COUNT LOOP
                IF p_charge_allocation_table(j).charge_id = p_charge_table(i).charge_id THEN
                    p_charge_allocation_table.DELETE(j);
                ELSE
                    EXIT;
                END IF;
            END LOOP;
    END;
    END LOOP;

    asn_debug.put_line('Done allocating charges');
END Allocate_Charges;

Procedure Preprocess_Charge_Line
( p_charge_record      IN OUT NOCOPY rcv_charges_interface%ROWTYPE
, p_header_record      IN            RCV_ROI_PREPROCESSOR.headers_cur%ROWTYPE
, p_transaction_record IN            RCV_ROI_PREPROCESSOR.txns_cur%ROWTYPE
) IS
BEGIN
    Derive_charge_info(p_charge_record, p_header_record, p_transaction_record);
    Default_charge_info(p_charge_record, p_header_record, p_transaction_record);
    Validate_charge_info(p_charge_record, p_header_record, p_transaction_record);
END Preprocess_charge_line;

Procedure Preprocess_Charges
( p_api_version        IN NUMBER
, p_init_msg_list      IN VARCHAR2
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
, p_header_record      IN RCV_ROI_PREPROCESSOR.headers_cur%ROWTYPE
, p_transaction_record IN RCV_ROI_PREPROCESSOR.txns_cur%ROWTYPE
) IS
    l_charge_interface_table charge_interface_table_type;
BEGIN
    asn_debug.put_line('In preprocess_charges');

    -- initialize return status
    x_return_status := FND_API.g_ret_sts_success;

    --fetch relevant charges into the temporary charge interface table
    SELECT *
      BULK COLLECT INTO l_charge_interface_table
      FROM rcv_charges_interface
     WHERE ( parent_header_interface_id = p_transaction_record.header_interface_id OR
             parent_interface_id = p_transaction_record.interface_transaction_id
           )
       AND processing_status_code = 'P'
     ORDER BY interface_charge_id
       FOR UPDATE;

    asn_debug.put_line('Found ' || l_charge_interface_table.COUNT || ' charges to preprocess');

    -- return if there is no qualified RCI row.
    IF l_charge_interface_table.COUNT  < 1 THEN
        asn_debug.put_line('No RCI row to preprocess, returning');
        RETURN;
    END IF;

    -- loop through all charges associated to the item transaction
    FOR i IN 1..l_charge_interface_table.COUNT LOOP
        l_charge_interface_table(i).processing_status_code := 'S';
        asn_debug.put_line('Preprocessing charge line ' || i);

        -- default derive and validate this charge line
        Preprocess_charge_line( l_charge_interface_table(i)
                              , p_header_record
                              , p_transaction_record
                              );

        asn_debug.put_line('Preprocessed charge line ' || l_charge_interface_table(i).processing_status_code);

        -- If charge preprocessing returns error, pass out 'E' to item error status.
        IF l_charge_interface_table(i).processing_status_code NOT IN ('S', 'W') THEN
             x_return_status := l_charge_interface_table(i).processing_status_code;
        END IF;
    END LOOP;

    asn_debug.put_line('Done preprocessing, updating RCI');

    -- Update the preprocessed charge interface data on rcv_charges_interface.
    Update_Interface_Charges(l_charge_interface_table);

    asn_debug.put_line('Done preprocessing charges');
EXCEPTION
    WHEN OTHERS THEN
        asn_debug.put_line('Exception in Preprocess_Charges:');
        asn_debug.put_line(SQLERRM);
        x_return_status := FND_API.g_ret_sts_error;
END Preprocess_Charges;

PROCEDURE Process_Charges
( p_api_version        IN NUMBER
, p_init_msg_list      IN VARCHAR2
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
, p_rhi_id             IN RCV_HEADERS_INTERFACE.header_interface_id%TYPE
, p_rti_id             IN RCV_TRANSACTIONS_INTERFACE.interface_transaction_id%TYPE
, p_shipment_header_id IN RCV_SHIPMENT_HEADERS.shipment_header_id%TYPE
, p_shipment_line_id   IN RCV_SHIPMENT_LINES.shipment_line_id%TYPE
) IS
    l_charge_interface_table charge_interface_table_type;
    l_charge_table PO_CHARGES_GRP.charge_table_type;
    l_charge_allocation_table PO_CHARGES_GRP.charge_allocation_table_type;
    l_fail_all_charges EXCEPTION;
    l_rti_t_status varchar2(50);
    l_rti_p_status varchar2(50);
BEGIN
    asn_debug.put_line('In Process_Charges: *' || p_rhi_id || '*' || p_rti_id || '*' || p_shipment_header_id || '*' || p_shipment_line_id || '*');

    -- initialize return status
    x_return_status := FND_API.g_ret_sts_success;

    -- fetch relevant charges into the temporary charge interface table
    SELECT   *
        BULK COLLECT INTO l_charge_interface_table
        FROM rcv_charges_interface
       WHERE (   parent_interface_id = p_rti_id
              OR (    parent_header_interface_id = p_rhi_id
                  AND parent_interface_id IS NULL
                  AND NOT EXISTS (
                         SELECT NULL
                           FROM rcv_transactions_interface
                          WHERE header_interface_id = p_rhi_id
                            AND interface_transaction_id <> p_rti_id)
                 )
             )
         AND processing_status_code IN ('S', 'W')
         AND transaction_status_code = 'P'
    ORDER BY interface_charge_id;

    asn_debug.put_line('Found ' || l_charge_interface_table.COUNT || ' charges to process');

    -- return if there is no qualified RCI row.
    IF l_charge_interface_table.COUNT < 1 THEN
        asn_debug.put_line('No RCI row to process, returning');
        RETURN;
    END IF;

    -- populate the PL/SQL table l_charge_table
    FOR i IN 1..l_charge_interface_table.COUNT LOOP --{
    BEGIN
        asn_debug.put_line('Processing charge line ' || i);
        l_charge_interface_table(i).transaction_status_code := 'S';
        Add_Charge_From_Interface
            ( l_charge_interface_table(i)
            , l_charge_table
            , p_shipment_header_id
            , p_shipment_line_id
            );
    EXCEPTION
        WHEN others THEN
            l_charge_interface_table(i).transaction_status_code := 'E';
            asn_debug.put_line('RCV_CHARGES_GRP: Process_Charges: interface charge'||
                               l_charge_interface_table(i).interface_charge_id ||' failed');
    END;
    END LOOP; --}

    asn_debug.put_line('Done creating charges, allocating...');

    -- if profile option RCV_CHARGE_FAIL_ITEM is Y and there is a failure
    -- then fail all the charges as well as the backing item transaction.
    -- otherwise, only fail the errored out charge.
    IF NVL(fnd_profile.VALUE('RCV_CHARGE_FAIL_ITEM'), 'N') = 'Y'
       AND l_charge_interface_table.COUNT > l_charge_table.COUNT
    THEN
        asn_debug.put_line('Fail all charges');
        -- Error out all charges
        FOR i IN 1..l_charge_interface_table.COUNT LOOP
            l_charge_interface_table(i).transaction_status_code := 'E';
        END LOOP;

        -- update interface table
        Update_Interface_Charges(l_charge_interface_table);

        RAISE l_fail_all_charges;
    END IF;

    -- populate po_rcv_charge_allocations
    Allocate_Charges( l_charge_table, l_charge_allocation_table , l_charge_interface_table );

    -- populate po_rcv_charges
    FORALL i IN 1..l_charge_table.COUNT
        INSERT INTO po_rcv_charges
        VALUES l_charge_table(i);

    asn_debug.put_line('Inserted ' || SQL%ROWCOUNT || ' rows into PO_RCV_CHARGES');

    FORALL i IN 1..l_charge_allocation_table.COUNT
        INSERT INTO po_rcv_charge_allocations
        VALUES l_charge_allocation_table(i);

    asn_debug.put_line('Inserted ' || SQL%ROWCOUNT || ' rows into PO_RCV_CHARGE_ALLOCATIONS');

    -- update rcv_charges_interface with status code
    Update_Interface_Charges(l_charge_interface_table);

    -- delete all successfully processed rows from interfacet table
    DELETE FROM rcv_charges_interface
     WHERE transaction_status_code IN ('S','W');

    asn_debug.put_line('Deleted ' || SQL%ROWCOUNT || ' successful rows from rcv_charges_interface');

    asn_debug.put_line('Done processing charges');
EXCEPTION
    WHEN OTHERS THEN
        -- pass out an error return status to fail the item transaction
        x_return_status := FND_API.g_ret_sts_error;
        IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('RCV_CHARGES_GRP.Process_Charges: Unexpected exception:');
             asn_debug.put_line(SQLERRM);
        END IF;

END Process_Charges;

END RCV_CHARGES_GRP;


/
