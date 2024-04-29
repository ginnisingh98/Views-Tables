--------------------------------------------------------
--  DDL for Package Body RCV_TRANSACTIONS_INTERFACE_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_TRANSACTIONS_INTERFACE_SV" AS
/* $Header: RCVTISVB.pls 120.3.12010000.2 2010/01/25 23:36:21 vthevark ship $*/

-- Read the profile option that enables/disables the debug log
    g_asn_debug                 VARCHAR2(1)                                        := asn_debug.is_debug_on; -- Bug 9152790
    cascaded_table              rcv_shipment_object_sv.cascaded_trans_tab_type;
    transaction_record          rcv_shipment_line_sv.transaction_record_type;
    item_id_record              rcv_shipment_line_sv.item_id_record_type;
    document_num_record         rcv_shipment_line_sv.document_num_record_type;
    release_id_record           rcv_shipment_line_sv.release_id_record_type;
    po_line_id_record           rcv_shipment_line_sv.po_line_id_record_type;
    po_line_location_id_record  rcv_shipment_line_sv.po_line_location_id_rtype;
    ship_to_org_record          rcv_shipment_object_sv.organization_id_record_type;
    organization_id_record      rcv_shipment_object_sv.organization_id_record_type;
    intransit_owning_org_record rcv_shipment_line_sv.intransit_owning_org_rtype;
    location_id_record          rcv_shipment_object_sv.location_id_record_type;
    sub_item_id_record          rcv_shipment_line_sv.sub_item_id_record_type;
    category_id_record          rcv_shipment_line_sv.category_id_record_type;
    employee_id_record          rcv_shipment_object_sv.employee_id_record_type;
    routing_header_id_record    rcv_shipment_line_sv.routing_header_id_rec_type;
    routing_step_id_record      rcv_shipment_line_sv.routing_step_id_rec_type;
    deliver_to_person_id_record rcv_shipment_line_sv.deliver_to_person_id_rtype;
    locator_id_record           rcv_shipment_line_sv.locator_id_record_type;
    reason_id_record            rcv_shipment_line_sv.reason_id_record_type;
    quantity_shipped_record     rcv_shipment_line_sv.quantity_shipped_record_type;
    expected_receipt_record     rcv_shipment_line_sv.expected_receipt_record_type;
    quantity_invoiced_record    rcv_shipment_line_sv.quantity_invoiced_record_type;
    ref_integrity_record        rcv_shipment_line_sv.ref_integrity_record_type;
    asl_record                  rcv_shipment_line_sv.ref_integrity_record_type;
    freight_carrier_record      rcv_shipment_line_sv.freight_carrier_record_type;
    tax_name_record             rcv_shipment_line_sv.tax_name_record_type;
--FRKHAN 12/18/98 add record type for country of origin
    country_of_origin_record    rcv_shipment_line_sv.country_of_origin_record_type;
    vendor_record               rcv_shipment_header_sv.vendorrectype;
    vendor_site_record          rcv_shipment_header_sv.vendorsiterectype;
    cum_quantity_record         rcv_shipment_line_sv.cum_quantity_record_type;
    uom_record                  rcv_shipment_line_sv.quantity_shipped_record_type;
    employee_record             rcv_shipment_line_sv.employee_record_type;
    po_lookup_code_record       rcv_shipment_line_sv.po_lookup_code_record_type;
    location_record             rcv_shipment_line_sv.location_record_type;
    subinventory_record         rcv_shipment_line_sv.subinventory_record_type;
    locator_record              rcv_shipment_line_sv.locator_record_type;
    item_revision_record        rcv_shipment_line_sv.item_id_record_type;
/* <Consigned Inventory Pre-Processor FPI START> */
    l_consigned_po_rec          rcv_shipment_line_sv.po_line_location_id_rtype;
    l_consumption_po_rec        rcv_shipment_line_sv.document_num_record_type;
    l_consumption_release_rec   rcv_shipment_line_sv.release_id_record_type;
    e_validation_error          EXCEPTION;

/* <Consigned Inventory Pre-Processor FPI END> */


/*===========================================================================

  PROCEDURE NAME: derive_shipment_line()

===========================================================================*/
    PROCEDURE derive_shipment_line(
        x_cascaded_table    IN OUT NOCOPY rcv_shipment_object_sv.cascaded_trans_tab_type,
        n                   IN OUT NOCOPY BINARY_INTEGER,
        temp_cascaded_table IN OUT NOCOPY rcv_shipment_object_sv.cascaded_trans_tab_type,
        x_header_record     IN            rcv_shipment_header_sv.headerrectype
    ) IS
/*
** Debug: Needed to add all the columns selected in the distributions cursor
**        so the definition of the shipments and distributions cursors were
**        identical.
*/
/* 1887728 - IN ASN closed for receiving PO's were also being
   received . In the Enter Receipts form the closed for
   receiving  PO's can be received only if Include Closed PO
   profile option is set . Modified the cursors shipments,
   count shipments, distributions,count distributions
   to restrict the shipments and distributions based on the
   profile option.
   The fnd_profile.get_specfic(x,y,z,w) returns the value
   of profile option starting from user. If there is no value
   at the user value ,then the value at responsibility
   level is returned and so on. */
        x_include_closed_po       VARCHAR2(1); -- Bug 1887728

        CURSOR shipments(
            header_id             NUMBER,
            v_item_id             NUMBER,
            v_po_line_num         NUMBER,
            v_po_release_id       NUMBER,
            v_shipment_num        NUMBER,
            v_ship_to_org_id      NUMBER,
            v_ship_to_location_id NUMBER,
            v_vendor_product_num  VARCHAR2
        ) IS
            SELECT   pll.line_location_id,
                     pll.unit_meas_lookup_code,
                     pll.unit_of_measure_class,
                     NVL(pll.promised_date, pll.need_by_date) promised_date,
                     pll.ship_to_organization_id,
                     pll.quantity quantity_ordered,
                     pll.quantity_shipped,
                     pll.receipt_days_exception_code,
                     pll.qty_rcv_tolerance,
                     pll.qty_rcv_exception_code,
                     pll.days_early_receipt_allowed,
                     pll.days_late_receipt_allowed,
                     NVL(pll.price_override, pl.unit_price) unit_price,
                     pll.match_option, -- 1845702
                     pl.category_id,
                     pl.item_description,
                     pl.po_line_id,
                     ph.currency_code,
                     ph.rate_type, -- 1845702
                     0 po_distribution_id,
                     0 code_combination_id,
                     0 req_distribution_id,
                     0 deliver_to_location_id,
                     0 deliver_to_person_id,
                     ph.rate_date rate_date, --1845702
                     ph.rate rate, --1845702
                     '' destination_type_code,
                     0 destination_organization_id,
                     '' destination_subinventory,
                     0 wip_entity_id,
                     0 wip_operation_seq_num,
                     0 wip_resource_seq_num,
                     0 wip_repetitive_schedule_id,
                     0 wip_line_id,
                     0 bom_resource_id,
                     '' ussgl_transaction_code,
                     pll.ship_to_location_id,
                     NVL(pll.enforce_ship_to_location_code, 'NONE') enforce_ship_to_location_code,
                     pl.item_id
            FROM     po_line_locations pll,
                     po_lines pl,
                     po_headers ph
            WHERE    ph.po_header_id = header_id
            AND      pll.po_header_id = header_id
            AND      pl.line_num = NVL(v_po_line_num, pl.line_num)
            AND      NVL(pll.po_release_id, 0) = NVL(v_po_release_id, NVL(pll.po_release_id, 0))
            AND      pll.shipment_num = NVL(v_shipment_num, pll.shipment_num)
            AND      pll.po_line_id = pl.po_line_id
            AND      NVL(pl.item_id, 0) = NVL(v_item_id, NVL(pl.item_id, 0)) -- v_item_id could be null
            AND      NVL(pll.approved_flag, 'N') = 'Y'
            AND      NVL(pll.cancel_flag, 'N') = 'N'
            AND      (   (    NVL(x_include_closed_po, 'N') = 'Y'
                          AND NVL(pll.closed_code, 'OPEN') <> 'FINALLY CLOSED')
                      OR (    NVL(x_include_closed_po, 'N') = 'N'
                          AND (NVL(pll.closed_code, 'OPEN') NOT IN('FINALLY CLOSED', 'CLOSED', 'CLOSED FOR RECEIVING'))))
            AND      pll.shipment_type IN('STANDARD', 'BLANKET', 'SCHEDULED')
            AND      pll.ship_to_organization_id = NVL(v_ship_to_org_id, pll.ship_to_organization_id)
            AND      pll.ship_to_location_id = NVL(v_ship_to_location_id, pll.ship_to_location_id)
            AND      NVL(pl.vendor_product_num, '-999') = NVL(v_vendor_product_num, NVL(pl.vendor_product_num, '-999'))
            ORDER BY NVL(pll.promised_date, pll.need_by_date);

        CURSOR count_shipments(
            header_id             NUMBER,
            v_item_id             NUMBER,
            v_po_line_num         NUMBER,
            v_po_release_id       NUMBER,
            v_shipment_num        NUMBER,
            v_ship_to_org_id      NUMBER,
            v_ship_to_location_id NUMBER,
            v_vendor_product_num  VARCHAR2
        ) IS
            SELECT COUNT(*)
            FROM   po_line_locations pll,
                   po_lines pl,
                   po_headers ph
            WHERE  ph.po_header_id = header_id
            AND    pll.po_header_id = header_id
            AND    pl.line_num = NVL(v_po_line_num, pl.line_num)
            AND    NVL(pll.po_release_id, 0) = NVL(v_po_release_id, NVL(pll.po_release_id, 0))
            AND    pll.shipment_num = NVL(v_shipment_num, pll.shipment_num)
            AND    pll.po_line_id = pl.po_line_id
            AND    NVL(pl.item_id, 0) = NVL(v_item_id, NVL(pl.item_id, 0)) -- v_item_id could be null
            AND    NVL(pll.approved_flag, 'N') = 'Y'
            AND    NVL(pll.cancel_flag, 'N') = 'N'
            AND    (   (    NVL(x_include_closed_po, 'N') = 'Y'
                        AND NVL(pll.closed_code, 'OPEN') <> 'FINALLY CLOSED')
                    OR (    NVL(x_include_closed_po, 'N') = 'N'
                        AND (NVL(pll.closed_code, 'OPEN') NOT IN('FINALLY CLOSED', 'CLOSED', 'CLOSED FOR RECEIVING'))))
            AND    pll.shipment_type IN('STANDARD', 'BLANKET', 'SCHEDULED')
            AND    pll.ship_to_organization_id = NVL(v_ship_to_org_id, pll.ship_to_organization_id)
            AND    pll.ship_to_location_id = NVL(v_ship_to_location_id, pll.ship_to_location_id)
            AND    NVL(pl.vendor_product_num, '-999') = NVL(v_vendor_product_num, NVL(pl.vendor_product_num, '-999'));

/***** Bug # 1553154
 ***** There was a performance issue since the cursor COUNT_DISTRIBUTIONS
 ***** was driving through PO_LINE_LOCATIONS_ALL. Modified the Select
 ***** statement so that it will drive through PO_HEADERS_ALL
 ***** followed by PO_LINES_ALL which is followed by PO_LINE_LOCATIONS_ALL
 ***** so that there is an improvement in performance.
 *****/
        CURSOR distributions(
            header_id             NUMBER,
            v_item_id             NUMBER,
            v_po_line_num         NUMBER,
            v_po_release_id       NUMBER,
            v_shipment_num        NUMBER,
            v_distribution_num    NUMBER,
            v_ship_to_org_id      NUMBER,
            v_ship_to_location_id NUMBER,
            v_vendor_product_num  VARCHAR2
        ) IS
            SELECT   pll.line_location_id,
                     pll.unit_meas_lookup_code,
                     pll.unit_of_measure_class,
                     NVL(pll.promised_date, pll.need_by_date) promised_date,
                     pll.ship_to_organization_id,
                     pll.quantity quantity_ordered,
                     pll.quantity_shipped,
                     pll.receipt_days_exception_code,
                     pll.qty_rcv_tolerance,
                     pll.qty_rcv_exception_code,
                     pll.days_early_receipt_allowed,
                     pll.days_late_receipt_allowed,
                     NVL(pll.price_override, pl.unit_price) unit_price,
                     pll.match_option, -- 1845702
                     pl.category_id,
                     pl.item_description,
                     pl.po_line_id,
                     ph.currency_code,
                     ph.rate_type, -- 1845702
                     pod.po_distribution_id,
                     pod.code_combination_id,
                     pod.req_distribution_id,
                     pod.deliver_to_location_id,
                     pod.deliver_to_person_id,
                     pod.rate_date,
                     pod.rate,
                     pod.destination_type_code,
                     pod.destination_organization_id,
                     pod.destination_subinventory,
                     pod.wip_entity_id,
                     pod.wip_operation_seq_num,
                     pod.wip_resource_seq_num,
                     pod.wip_repetitive_schedule_id,
                     pod.wip_line_id,
                     pod.bom_resource_id,
                     pod.ussgl_transaction_code,
                     pll.ship_to_location_id,
                     NVL(pll.enforce_ship_to_location_code, 'NONE') enforce_ship_to_location_code,
                     pl.item_id
            FROM     po_distributions pod,
                     po_line_locations pll,
                     po_lines pl,
                     po_headers ph
            WHERE    ph.po_header_id = header_id
            AND      pl.po_header_id = ph.po_header_id
            AND      pll.po_line_id = pl.po_line_id
            AND      pod.line_location_id = pll.line_location_id
            AND      pl.line_num = NVL(v_po_line_num, pl.line_num)
            AND      NVL(pll.po_release_id, 0) = NVL(v_po_release_id, NVL(pll.po_release_id, 0))
            AND      pll.shipment_num = NVL(v_shipment_num, pll.shipment_num)
            AND      NVL(pl.item_id, 0) = NVL(v_item_id, NVL(pl.item_id, 0)) -- v_item_id could be null
            AND      NVL(pll.approved_flag, 'N') = 'Y'
            AND      NVL(pll.cancel_flag, 'N') = 'N'
            AND      (   (    NVL(x_include_closed_po, 'N') = 'Y'
                          AND NVL(pll.closed_code, 'OPEN') <> 'FINALLY CLOSED')
                      OR (    NVL(x_include_closed_po, 'N') = 'N'
                          AND (NVL(pll.closed_code, 'OPEN') NOT IN('FINALLY CLOSED', 'CLOSED', 'CLOSED FOR RECEIVING'))))
            AND      pll.shipment_type IN('STANDARD', 'BLANKET', 'SCHEDULED')
            AND      pod.distribution_num = NVL(v_distribution_num, pod.distribution_num)
            AND      pll.ship_to_organization_id = NVL(v_ship_to_org_id, pll.ship_to_organization_id)
            AND      pll.ship_to_location_id = NVL(v_ship_to_location_id, pll.ship_to_location_id)
            AND      NVL(pl.vendor_product_num, '-999') = NVL(v_vendor_product_num, NVL(pl.vendor_product_num, '-999'))
            ORDER BY NVL(pll.promised_date, pll.need_by_date);

/***** Bug # 1553154
 ***** There was a performance issue since the cursor DISTRIBUTIONS
 ***** was driving through PO_HEADERS_ALL followed by PO_DISTRIBUTIONS_ALL
 ***** Modified the Select statement so that it will drive through
 ***** PO_HEADERS_ALL followed by PO_LINES_ALL which is followed by
 ***** PO_LINE_LOCATIONS_ALL which in turn is followed by
 ***** PO_DISTRIBUTIONS_ALL so that there is an improvement in
 ***** Performance
 *****/
        CURSOR count_distributions(
            header_id             NUMBER,
            v_item_id             NUMBER,
            v_po_line_num         NUMBER,
            v_po_release_id       NUMBER,
            v_shipment_num        NUMBER,
            v_distribution_num    NUMBER,
            v_ship_to_org_id      NUMBER,
            v_ship_to_location_id NUMBER,
            v_vendor_product_num  VARCHAR2
        ) IS
            SELECT COUNT(*)
            FROM   po_distributions pod,
                   po_line_locations pll,
                   po_lines pl,
                   po_headers ph
            WHERE  ph.po_header_id = header_id
            AND    pl.po_header_id = ph.po_header_id
            AND    pll.po_line_id = pl.po_line_id
            AND    pod.line_location_id = pll.line_location_id
            AND    pl.line_num = NVL(v_po_line_num, pl.line_num)
            AND    NVL(pll.po_release_id, 0) = NVL(v_po_release_id, NVL(pll.po_release_id, 0))
            AND    pll.shipment_num = NVL(v_shipment_num, pll.shipment_num)
            AND    pod.distribution_num = NVL(v_distribution_num, pod.distribution_num)
            AND    NVL(pl.item_id, 0) = NVL(v_item_id, NVL(pl.item_id, 0)) -- v_item_id could be null
            AND    NVL(pll.approved_flag, 'N') = 'Y'
            AND    NVL(pll.cancel_flag, 'N') = 'N'
            AND    (   (    NVL(x_include_closed_po, 'N') = 'Y'
                        AND NVL(pll.closed_code, 'OPEN') <> 'FINALLY CLOSED')
                    OR (    NVL(x_include_closed_po, 'N') = 'N'
                        AND (NVL(pll.closed_code, 'OPEN') NOT IN('FINALLY CLOSED', 'CLOSED', 'CLOSED FOR RECEIVING'))))
            AND    pll.shipment_type IN('STANDARD', 'BLANKET', 'SCHEDULED')
            AND    pll.ship_to_organization_id = NVL(v_ship_to_org_id, pll.ship_to_organization_id)
            AND    pll.ship_to_location_id = NVL(v_ship_to_location_id, pll.ship_to_location_id)
            AND    NVL(pl.vendor_product_num, '-999') = NVL(v_vendor_product_num, NVL(pl.vendor_product_num, '-999'));

/*
** Debug: had to change this to the distribution record
** Might be a compatibility issue between the two record definitions
*/
        x_shipmentdistributionrec distributions%ROWTYPE;
        x_record_count            NUMBER;
        x_remaining_quantity      NUMBER                                                  := 0;
        x_remaining_qty_po_uom    NUMBER                                                  := 0;
        x_bkp_qty                 NUMBER                                                  := 0;
        x_progress                VARCHAR2(3);
        x_to_organization_code    VARCHAR2(5);
        x_converted_trx_qty       NUMBER                                                  := 0;
        transaction_ok            BOOLEAN                                                 := FALSE;
        x_expected_date           rcv_transactions_interface.expected_receipt_date%TYPE;
        high_range_date           DATE;
        low_range_date            DATE;
        rows_fetched              NUMBER                                                  := 0;
        x_tolerable_qty           NUMBER                                                  := 0;
        x_first_trans             BOOLEAN                                                 := TRUE;
        x_sysdate                 DATE                                                    := SYSDATE;
        current_n                 BINARY_INTEGER                                          := 0;
        insert_into_table         BOOLEAN                                                 := FALSE;
        x_qty_rcv_exception_code  po_line_locations.qty_rcv_exception_code%TYPE;
        tax_amount_factor         NUMBER;
        lastrecord                BOOLEAN                                                 := FALSE;
        po_asn_uom_qty            NUMBER;
        po_primary_uom_qty        NUMBER;
        already_allocated_qty     NUMBER                                                  := 0;
        x_item_id                 NUMBER;
        x_approved_flag           VARCHAR(1);
        x_cancel_flag             VARCHAR(1);
        x_closed_code             VARCHAR(25);
        x_shipment_type           VARCHAR(25);
        x_ship_to_organization_id NUMBER;
        x_ship_to_location_id     NUMBER;
/* temp_ship_to_location_id       number;
 temp_mirror_ship_to_loc_id number ;
 temp_enf_ship_to_loc_code varchar(25) ; */
/* The above 3 variables added for bug 1898283 */
        x_vendor_product_num      VARCHAR(25);
        x_temp_count              NUMBER;
        x_full_name               VARCHAR2(240)                                           := NULL; -- Bug 2392074
        /* 1887728 -Added the following variables */
        profile_user_id           NUMBER                                                  := -1;
        profile_appl_id           NUMBER                                                  := -1;
        profile_resp_id           NUMBER                                                  := -1;
        defined                   BOOLEAN;
        /* 1845702 */
        x_sob_id                  NUMBER                                                  := NULL;
        x_rate                    NUMBER;
        x_allow_rate_override     VARCHAR2(1);
        /* Bug# 1548597 */
        x_secondary_available_qty NUMBER                                                  := 0;
    BEGIN
        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Enter derive_shipment_line');
            asn_debug.put_line('Current pointer in actual table ' || TO_CHAR(n));
            asn_debug.put_line('Current error status ' || x_cascaded_table(n).error_status);
            asn_debug.put_line('To Organization Id ' || NVL(TO_CHAR(x_cascaded_table(n).to_organization_id), 'DUH'));
            asn_debug.put_line('To Organization Code ' || NVL(x_cascaded_table(n).to_organization_code, 'XMA'));
        END IF;

        /* 1887728- Getting the profile option value based on the user_id,
         resp_id,appl_id
        */
        profile_user_id  := fnd_profile.VALUE('USER_ID');
        profile_resp_id  := fnd_profile.VALUE('RESPONSIBILITY_ID');
        profile_appl_id  := fnd_profile.VALUE('APPLICATION_ID');
        fnd_profile.get_specific('RCV_CLOSED_PO_DEFAULT_OPTION',
                                 profile_user_id,
                                 profile_resp_id,
                                 profile_appl_id,
                                 x_include_closed_po,
                                 defined
                                );

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Include closed PO profile value ' || x_include_closed_po);
        END IF;

        x_progress       := '000';

        -- default org from header in case it is null at the line level

        IF     x_cascaded_table(n).to_organization_code IS NULL
           AND x_cascaded_table(n).error_status IN('S', 'W') THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Attempting to default the org from the ship to location');
            END IF;

            IF (x_cascaded_table(n).ship_to_location_code IS NOT NULL) THEN
                SELECT MAX(org.organization_code)
                INTO   x_to_organization_code
                FROM   hr_locations hl,
                       mtl_parameters org -- Bugfix 5217098
                WHERE  x_cascaded_table(n).ship_to_location_code = hl.location_code
                AND    hl.inventory_organization_id = org.organization_id;

                x_cascaded_table(n).to_organization_code  := x_to_organization_code;

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Set Org Code using location code = ' || x_cascaded_table(n).to_organization_code);
                END IF;
            END IF;

            IF (x_cascaded_table(n).to_organization_code IS NULL) THEN
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Will default org change DUH to ' || x_header_record.header_record.ship_to_organization_code);
                END IF;

                x_cascaded_table(n).to_organization_code  := x_header_record.header_record.ship_to_organization_code;
            END IF;
        END IF;

        -- call derivation procedures if conditions are met

        IF     (x_cascaded_table(n).error_status IN('S', 'W'))
           AND (    x_cascaded_table(n).to_organization_id IS NULL
                AND x_cascaded_table(n).to_organization_code IS NOT NULL) THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('X_Progress ' || x_progress);
            END IF;

            ship_to_org_record.organization_code           := x_cascaded_table(n).to_organization_code;
            ship_to_org_record.organization_id             := x_cascaded_table(n).to_organization_id;
            ship_to_org_record.error_record.error_status   := 'S';
            ship_to_org_record.error_record.error_message  := NULL;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Into Derive Organization Record Procedure');
            END IF;

            po_orgs_sv.derive_org_info(ship_to_org_record);

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Debug Output after organization procedure');
                asn_debug.put_line(ship_to_org_record.organization_code);
                asn_debug.put_line(TO_CHAR(ship_to_org_record.organization_id));
                asn_debug.put_line(ship_to_org_record.error_record.error_status);
                asn_debug.put_line('Debug organization output over');
            END IF;

            x_cascaded_table(n).to_organization_code       := ship_to_org_record.organization_code;
            x_cascaded_table(n).to_organization_id         := ship_to_org_record.organization_id;
            x_cascaded_table(n).error_status               := ship_to_org_record.error_record.error_status;
            rcv_error_pkg.set_error_message(ship_to_org_record.error_record.error_message, x_cascaded_table(n).error_message);
        END IF;

        /* Derive Vendor Information */
        x_progress       := '002';

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('X_progress ' || x_progress);
        END IF;

        IF (x_cascaded_table(n).error_status IN('S', 'W')) THEN
            IF (   x_cascaded_table(n).vendor_name IS NOT NULL
                OR x_cascaded_table(n).vendor_num IS NOT NULL
                OR x_cascaded_table(n).vendor_id IS NOT NULL) THEN
                vendor_record.vendor_name                 := x_cascaded_table(n).vendor_name;
                vendor_record.vendor_num                  := x_cascaded_table(n).vendor_num;
                vendor_record.vendor_id                   := x_cascaded_table(n).vendor_id;
                vendor_record.error_record.error_message  := x_cascaded_table(n).error_message;
                vendor_record.error_record.error_status   := x_cascaded_table(n).error_status;

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('In Vendor Procedure');
                END IF;

                po_vendors_sv.derive_vendor_info(vendor_record);

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line(TO_CHAR(vendor_record.vendor_id));
                    asn_debug.put_line(vendor_record.vendor_name);
                    asn_debug.put_line(vendor_record.vendor_num);
                    asn_debug.put_line(vendor_record.error_record.error_status);
                    asn_debug.put_line(vendor_record.error_record.error_message);
                END IF;

                x_cascaded_table(n).vendor_name           := vendor_record.vendor_name;
                x_cascaded_table(n).vendor_num            := vendor_record.vendor_num;
                x_cascaded_table(n).vendor_id             := vendor_record.vendor_id;
                rcv_error_pkg.set_error_message(vendor_record.error_record.error_message, x_cascaded_table(n).error_message);
                x_cascaded_table(n).error_status          := vendor_record.error_record.error_status;
            END IF;
        END IF;

        /* derive vendor site information */
        /* Call derive vendor_site_procedure here */
        /* UK1 -> vendor_site_id
           UK2 -> vendor_site_code + vendor_id + org_id  */
        x_progress       := '004';

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('X_progress ' || x_progress);
        END IF;

        IF     x_cascaded_table(n).error_status IN('S', 'W')
           AND (   x_cascaded_table(n).vendor_site_code IS NOT NULL
                OR x_cascaded_table(n).vendor_site_id IS NOT NULL) THEN
            vendor_site_record.vendor_site_code            := x_cascaded_table(n).vendor_site_code;
            vendor_site_record.vendor_id                   := x_cascaded_table(n).vendor_id;
            vendor_site_record.vendor_site_id              := x_cascaded_table(n).vendor_site_id;
            vendor_site_record.organization_id             := x_cascaded_table(n).to_organization_id;
            vendor_site_record.error_record.error_message  := x_cascaded_table(n).error_message;
            vendor_site_record.error_record.error_status   := x_cascaded_table(n).error_status;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('In Vendor Site Procedure');
            END IF;

            po_vendor_sites_sv.derive_vendor_site_info(vendor_site_record);

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line(vendor_site_record.vendor_site_code);
                asn_debug.put_line(vendor_site_record.vendor_site_id);
            END IF;

            x_cascaded_table(n).vendor_site_code           := vendor_site_record.vendor_site_code;
            x_cascaded_table(n).vendor_id                  := vendor_site_record.vendor_id;
            x_cascaded_table(n).vendor_site_id             := vendor_site_record.vendor_site_id;
            x_cascaded_table(n).to_organization_id         := vendor_site_record.organization_id;
            rcv_error_pkg.set_error_message(vendor_site_record.error_record.error_message, x_cascaded_table(n).error_message);
            x_cascaded_table(n).error_status               := vendor_site_record.error_record.error_status;
        END IF;

        x_progress       := '005';

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('X_progress ' || x_progress);
        END IF;

        IF     (x_cascaded_table(n).error_status IN('S', 'W'))
           AND (    x_cascaded_table(n).po_header_id IS NULL
                AND x_cascaded_table(n).document_num IS NOT NULL) THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('X_progress ' || x_progress);
            END IF;

            document_num_record.document_num                := x_cascaded_table(n).document_num;
            document_num_record.error_record.error_status   := 'S';
            document_num_record.error_record.error_message  := NULL;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Derive po_header_id');
            END IF;

            rcv_transactions_interface_sv.get_po_header_id(document_num_record);
            x_cascaded_table(n).po_header_id                := document_num_record.po_header_id;
            x_cascaded_table(n).error_status                := document_num_record.error_record.error_status;
            rcv_error_pkg.set_error_message(document_num_record.error_record.error_message, x_cascaded_table(n).error_message);

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line(TO_CHAR(x_cascaded_table(n).po_header_id));
            END IF;

            rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status,
                                                'DOCUMENT_NUM',
                                                FALSE
                                               );
        END IF;

        x_progress       := '010';

        IF     (x_cascaded_table(n).error_status IN('S', 'W'))
           AND (    x_cascaded_table(n).item_id IS NULL
                AND (x_cascaded_table(n).item_num IS NOT NULL)) THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('X_progress ' || x_progress);
            END IF;

            item_id_record.item_num                      := x_cascaded_table(n).item_num;
            item_id_record.vendor_item_num               := NULL; -- x_cascaded_table(n).vendor_item_num;
            item_id_record.to_organization_id            := x_cascaded_table(n).to_organization_id;
            item_id_record.error_record.error_status     := 'S';
            item_id_record.error_record.error_message    := NULL;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Derive item_id');
            END IF;

            rcv_transactions_interface_sv.get_item_id(item_id_record);
            x_cascaded_table(n).item_id                  := item_id_record.item_id;
            x_cascaded_table(n).primary_unit_of_measure  := item_id_record.primary_unit_of_measure;
            x_cascaded_table(n).use_mtl_lot              := item_id_record.use_mtl_lot; -- bug 608353
            x_cascaded_table(n).use_mtl_serial           := item_id_record.use_mtl_serial; -- bug 608353
            x_cascaded_table(n).error_status             := item_id_record.error_record.error_status;
            rcv_error_pkg.set_error_message(item_id_record.error_record.error_message, x_cascaded_table(n).error_message);
            rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status,
                                                'ITEM_NUM',
                                                FALSE
                                               );
        END IF;

/*
** DEBUG: Primary UOM is not being set
*/
   /* x_cascaded_table(n).primary_unit_of_measure  := 'Each';  */

/*
** DEBUG: Need to set the employee_id from the header
*/
        x_progress       := '015';

        IF     (x_cascaded_table(n).error_status IN('S', 'W'))
           AND (    x_cascaded_table(n).substitute_item_id IS NULL
                AND (x_cascaded_table(n).substitute_item_num IS NOT NULL)) THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('X_progress ' || x_progress);
            END IF;

            sub_item_id_record.substitute_item_num         := x_cascaded_table(n).substitute_item_num;
            sub_item_id_record.vendor_item_num             := NULL; -- x_cascaded_table(n).vendor_item_num;
            sub_item_id_record.error_record.error_status   := 'S';
            sub_item_id_record.error_record.error_message  := NULL;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Derive Substitute Item Id');
            END IF;

            rcv_transactions_interface_sv.get_sub_item_id(sub_item_id_record);
            x_cascaded_table(n).substitute_item_id         := sub_item_id_record.substitute_item_id;
            x_cascaded_table(n).error_status               := sub_item_id_record.error_record.error_status;
            rcv_error_pkg.set_error_message(sub_item_id_record.error_record.error_message, x_cascaded_table(n).error_message);
            rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status,
                                                'SUBSTITUTE_ITEM_NUM',
                                                FALSE
                                               );

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line(TO_CHAR(x_cascaded_table(n).substitute_item_id));
            END IF;
        END IF;

        x_progress       := '020';

        IF     (x_cascaded_table(n).error_status IN('S', 'W'))
           AND (    x_cascaded_table(n).po_line_id IS NULL
                AND x_cascaded_table(n).po_header_id IS NOT NULL
                AND x_cascaded_table(n).document_line_num IS NOT NULL) THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('X_progress ' || x_progress);
            END IF;

            po_line_id_record.po_header_id                := x_cascaded_table(n).po_header_id;
            po_line_id_record.document_line_num           := x_cascaded_table(n).document_line_num;
            po_line_id_record.po_line_id                  := x_cascaded_table(n).po_line_id;
            po_line_id_record.item_id                     := x_cascaded_table(n).item_id;
            po_line_id_record.error_record.error_status   := 'S';
            po_line_id_record.error_record.error_message  := NULL;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Derive po_line_id');
            END IF;

            rcv_transactions_interface_sv.get_po_line_id(po_line_id_record);

            IF x_cascaded_table(n).item_id IS NULL THEN
                x_cascaded_table(n).item_id  := po_line_id_record.item_id;
            END IF;

            x_cascaded_table(n).po_line_id                := po_line_id_record.po_line_id;
            x_cascaded_table(n).error_status              := po_line_id_record.error_record.error_status;
            rcv_error_pkg.set_error_message(po_line_id_record.error_record.error_message, x_cascaded_table(n).error_message);
            rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status,
                                                'DOCUMENT_LINE_NUM',
                                                FALSE
                                               );

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line(TO_CHAR(x_cascaded_table(n).po_line_id));
            END IF;
        END IF;

        -- Get the primary uom in case item_id was determined on the basis of the po_line_id

        IF     (x_cascaded_table(n).error_status IN('S', 'W'))
           AND x_cascaded_table(n).item_id IS NOT NULL
           AND x_cascaded_table(n).primary_unit_of_measure IS NULL THEN
            BEGIN
                /* BUG 608353 */
                SELECT primary_unit_of_measure,
                       NVL(x_cascaded_table(n).use_mtl_lot, lot_control_code),
                       NVL(x_cascaded_table(n).use_mtl_serial, serial_number_control_code)
                INTO   x_cascaded_table(n).primary_unit_of_measure,
                       x_cascaded_table(n).use_mtl_lot,
                       x_cascaded_table(n).use_mtl_serial
                FROM   mtl_system_items
                WHERE  mtl_system_items.inventory_item_id = x_cascaded_table(n).item_id
                AND    mtl_system_items.organization_id = x_cascaded_table(n).to_organization_id;

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Primary UOM: ' || x_cascaded_table(n).primary_unit_of_measure);
                END IF;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_warning;
                    rcv_error_pkg.set_error_message('RCV_UOM_NO_CONV_PRIMARY', x_cascaded_table(n).error_message);
                    rcv_error_pkg.set_token('PRIMARY_UNIT', '');
                    rcv_error_pkg.set_token('SHIPMENT_UNIT', '');
                    rcv_error_pkg.log_interface_warning('ITEM_ID');

                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('Primary UOM error');
                    END IF;
            END;
        END IF;

        x_progress       := '025';

        /* Bug 1830177. If the po_line_id is null then we do not populate the correct
         * po_release_id even if we specify the release_num since we do not enter
         * this block. Removed the condition x_cascaded_table(n).po_line_id is not null
        */

        /* Bug 2020269 : uom_code needs to be derived from unit_of_measure
           entered in rcv_transactions_interface.
        */
        IF (x_cascaded_table(n).unit_of_measure IS NOT NULL) THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('X_progress ' || x_progress);
            END IF;

            SELECT muom.uom_code
            INTO   x_cascaded_table(n).uom_code
            FROM   mtl_units_of_measure muom
            WHERE  muom.unit_of_measure = x_cascaded_table(n).unit_of_measure;
        ELSE
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('uom_code not dereived as unit_of_measure is null');
            END IF;
        END IF;

        x_progress       := '026';

        IF     (x_cascaded_table(n).error_status IN('S', 'W'))
           AND x_cascaded_table(n).po_release_id IS NULL
           AND -- Maybe we need an or with shipnum,relnum
               x_cascaded_table(n).po_header_id IS NOT NULL THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('X_progress ' || x_progress);
            END IF;

            release_id_record.po_header_id                := x_cascaded_table(n).po_header_id;
            release_id_record.release_num                 := x_cascaded_table(n).release_num;
            release_id_record.po_line_id                  := x_cascaded_table(n).po_line_id;
            release_id_record.shipment_num                := x_cascaded_table(n).document_shipment_line_num;
            release_id_record.error_record.error_status   := 'S';
            release_id_record.error_record.error_message  := NULL;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Derive po_line_location_id, shipment_num, po_release_id');
            END IF;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('### po_header_id ' || release_id_record.po_header_id);
                asn_debug.put_line('### release_num  ' || release_id_record.release_num);
                asn_debug.put_line('### po_line_id   ' || release_id_record.po_line_id);
                asn_debug.put_line('### shipment_num ' || release_id_record.shipment_num);
                asn_debug.put_line('### po_rel_id    ' || release_id_record.po_release_id);
            END IF;

            po_releases_sv4.get_po_release_id(release_id_record);

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('^^^ po_header_id ' || release_id_record.po_header_id);
                asn_debug.put_line('^^^ release_num  ' || release_id_record.release_num);
                asn_debug.put_line('^^^ po_line_id   ' || release_id_record.po_line_id);
                asn_debug.put_line('^^^ shipment_num ' || release_id_record.shipment_num);
                asn_debug.put_line('^^^ po_rel_id    ' || release_id_record.po_release_id);
            END IF;

            IF x_cascaded_table(n).po_line_location_id IS NULL THEN
                x_cascaded_table(n).po_line_location_id  := release_id_record.po_line_location_id;

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('PO_LINE_LOCATION_ID ' || TO_CHAR(x_cascaded_table(n).po_line_location_id));
                END IF;
            END IF;

            IF x_cascaded_table(n).document_shipment_line_num IS NULL THEN
                x_cascaded_table(n).document_shipment_line_num  := release_id_record.shipment_num;

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('DOCUMENT_SHIPMENT_NUM ' || TO_CHAR(x_cascaded_table(n).document_shipment_line_num));
                END IF;
            END IF;

            x_cascaded_table(n).po_release_id             := release_id_record.po_release_id;
            x_cascaded_table(n).error_status              := release_id_record.error_record.error_status;
            rcv_error_pkg.set_error_message(release_id_record.error_record.error_message, x_cascaded_table(n).error_message);

            IF (x_cascaded_table(n).error_message = 'RCV_ITEM_PO_REL_ID') THEN
                rcv_error_pkg.set_token('NUMBER', x_cascaded_table(n).release_num);
            END IF;

            rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status,
                                                'DOCUMENT_LINE_NUM',
                                                FALSE
                                               );

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('PO_RELEASE_ID ' || TO_CHAR(x_cascaded_table(n).po_release_id));
            END IF;
        END IF;

        x_progress       := '030';

        IF     (x_cascaded_table(n).error_status IN('S', 'W'))
           AND (    x_cascaded_table(n).from_organization_id IS NULL
                AND x_cascaded_table(n).from_organization_code IS NOT NULL) THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('X_progress ' || x_progress);
            END IF;

            ship_to_org_record.organization_code           := x_cascaded_table(n).from_organization_code;
            ship_to_org_record.organization_id             := x_cascaded_table(n).from_organization_id;
            ship_to_org_record.error_record.error_status   := 'S';
            ship_to_org_record.error_record.error_message  := NULL;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('In From Organization Procedure');
            END IF;

            po_orgs_sv.derive_org_info(ship_to_org_record);

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('From organization code ' || ship_to_org_record.organization_code);
                asn_debug.put_line('From organization id ' || TO_CHAR(ship_to_org_record.organization_id));
                asn_debug.put_line('From organization error status ' || ship_to_org_record.error_record.error_status);
            END IF;

            x_cascaded_table(n).from_organization_code     := ship_to_org_record.organization_code;
            x_cascaded_table(n).from_organization_id       := ship_to_org_record.organization_id;
            x_cascaded_table(n).error_status               := ship_to_org_record.error_record.error_status;
            rcv_error_pkg.set_error_message(ship_to_org_record.error_record.error_message, x_cascaded_table(n).error_message);
            rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status,
                                                'FROM_ORGANIZATION_ID',
                                                FALSE
                                               );
        END IF;

        x_progress       := '035';

        IF     (x_cascaded_table(n).error_status IN('S', 'W'))
           AND (    x_cascaded_table(n).intransit_owning_org_id IS NULL
                AND x_cascaded_table(n).intransit_owning_org_code IS NOT NULL) THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('X_progress ' || x_progress);
            END IF;

            ship_to_org_record.organization_code           := x_cascaded_table(n).intransit_owning_org_code;
            ship_to_org_record.organization_id             := x_cascaded_table(n).intransit_owning_org_id;
            ship_to_org_record.error_record.error_status   := 'S';
            ship_to_org_record.error_record.error_message  := NULL;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('In Intransit Owning Org Record Procedure');
            END IF;

            po_orgs_sv.derive_org_info(ship_to_org_record);

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Intransit organization code ' || ship_to_org_record.organization_code);
                asn_debug.put_line('Intransit organization id ' || TO_CHAR(ship_to_org_record.organization_id));
                asn_debug.put_line('Intransit error status ' || ship_to_org_record.error_record.error_status);
            END IF;

            x_cascaded_table(n).intransit_owning_org_code  := ship_to_org_record.organization_code;
            x_cascaded_table(n).intransit_owning_org_id    := ship_to_org_record.organization_id;
            x_cascaded_table(n).error_status               := ship_to_org_record.error_record.error_status;
            rcv_error_pkg.set_error_message(ship_to_org_record.error_record.error_message, x_cascaded_table(n).error_message);
            rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status,
                                                'INTRANSIT_OWNING_ORG_ID',
                                                FALSE
                                               );
        END IF;

        x_progress       := '040';

        IF     (x_cascaded_table(n).error_status IN('S', 'W'))
           AND (    x_cascaded_table(n).location_id IS NULL
                AND x_cascaded_table(n).location_code IS NOT NULL) THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('X_progress ' || x_progress);
            END IF;

            location_id_record.location_code               := x_cascaded_table(n).location_code;
            location_id_record.error_record.error_status   := 'S';
            location_id_record.error_record.error_message  := NULL;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Derive location_id');
            END IF;

            rcv_transactions_interface_sv.get_location_id(location_id_record);
            x_cascaded_table(n).location_id                := location_id_record.location_id;
            x_cascaded_table(n).error_status               := location_id_record.error_record.error_status;
            rcv_error_pkg.set_error_message(location_id_record.error_record.error_message, x_cascaded_table(n).error_message);
            rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status,
                                                'LOCATION_CODE',
                                                FALSE
                                               );
        END IF;

        -- Derive ship_to_location record if information is provided at line level

        x_progress       := '045';

        IF     (x_cascaded_table(n).error_status IN('S', 'W'))
           AND (    x_cascaded_table(n).ship_to_location_id IS NULL
                AND x_cascaded_table(n).ship_to_location_code IS NOT NULL) THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('X_progress ' || x_progress);
            END IF;

            location_id_record.location_code               := x_cascaded_table(n).ship_to_location_code;
            location_id_record.error_record.error_status   := 'S';
            location_id_record.error_record.error_message  := NULL;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Derive ship to location_id');
            END IF;

            rcv_transactions_interface_sv.get_location_id(location_id_record);
            x_cascaded_table(n).ship_to_location_id        := location_id_record.location_id;
            x_cascaded_table(n).error_status               := location_id_record.error_record.error_status;
            rcv_error_pkg.set_error_message(location_id_record.error_record.error_message, x_cascaded_table(n).error_message);
            rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status,
                                                'SHIP_TO_LOCATION_CODE',
                                                FALSE
                                               );
        END IF;

        x_progress       := '050';

        IF     (x_cascaded_table(n).error_status IN('S', 'W'))
           AND (    x_cascaded_table(n).routing_header_id IS NULL
                AND x_cascaded_table(n).routing_code IS NOT NULL) THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('X_progress ' || x_progress);
            END IF;

            routing_header_id_record.routing_code                := x_cascaded_table(n).routing_code;
            routing_header_id_record.error_record.error_status   := 'S';
            routing_header_id_record.error_record.error_message  := NULL;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Derive routing_header_id');
            END IF;

            rcv_transactions_interface_sv.get_routing_header_id(routing_header_id_record);
            x_cascaded_table(n).routing_header_id                := routing_header_id_record.routing_header_id;
            x_cascaded_table(n).error_status                     := routing_header_id_record.error_record.error_status;
            rcv_error_pkg.set_error_message(routing_header_id_record.error_record.error_message, x_cascaded_table(n).error_message);
            rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status,
                                                'ROUTING_CODE',
                                                FALSE
                                               );
        END IF;

        x_progress       := '070';

        IF     (x_cascaded_table(n).error_status IN('S', 'W'))
           AND (    x_cascaded_table(n).routing_step_id IS NULL
                AND x_cascaded_table(n).routing_step IS NOT NULL) THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('X_progress ' || x_progress);
            END IF;

            routing_step_id_record.routing_step                := x_cascaded_table(n).routing_step;
            routing_step_id_record.error_record.error_status   := 'S';
            routing_step_id_record.error_record.error_message  := NULL;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Derive routing Step Id');
            END IF;

            rcv_transactions_interface_sv.get_routing_step_id(routing_step_id_record);
            x_cascaded_table(n).routing_step_id                := routing_step_id_record.routing_step_id;
            x_cascaded_table(n).error_status                   := routing_step_id_record.error_record.error_status;
            rcv_error_pkg.set_error_message(routing_step_id_record.error_record.error_message, x_cascaded_table(n).error_message);
            rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status,
                                                'ROUTING_STEP',
                                                FALSE
                                               );
        END IF;

        x_progress       := '080';

        IF     (x_cascaded_table(n).error_status IN('S', 'W'))
           AND (    x_cascaded_table(n).deliver_to_person_id IS NULL
                AND x_cascaded_table(n).deliver_to_person_name IS NOT NULL) THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('X_progress ' || x_progress);
            END IF;

            employee_id_record.employee_name               := x_cascaded_table(n).deliver_to_person_name;
            employee_id_record.employee_id                 := x_cascaded_table(n).deliver_to_person_id;
            employee_id_record.error_record.error_status   := 'S';
            employee_id_record.error_record.error_message  := NULL;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('In Derive deliver_to_person_id Information');
            END IF;

            po_employees_sv.derive_employee_info(employee_id_record);

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Employee name ' || employee_id_record.employee_name);
                asn_debug.put_line('Employee id ' || TO_CHAR(employee_id_record.employee_id));
                asn_debug.put_line('Employee error status ' || employee_id_record.error_record.error_status);
            END IF;

            x_cascaded_table(n).deliver_to_person_name     := employee_id_record.employee_name;
            x_cascaded_table(n).deliver_to_person_id       := employee_id_record.employee_id;
            x_cascaded_table(n).error_status               := employee_id_record.error_record.error_status;
            rcv_error_pkg.set_error_message(employee_id_record.error_record.error_message, x_cascaded_table(n).error_message);
            rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status,
                                                'DELIVER_TO_PERSON_ID',
                                                FALSE
                                               );
        END IF;

        x_progress       := '085';

        IF     (x_cascaded_table(n).error_status IN('S', 'W'))
           AND (    x_cascaded_table(n).deliver_to_location_id IS NULL
                AND x_cascaded_table(n).deliver_to_location_code IS NOT NULL) THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('X_progress ' || x_progress);
            END IF;

            location_id_record.location_code               := x_cascaded_table(n).deliver_to_location_code;
            location_id_record.error_record.error_status   := 'S';
            location_id_record.error_record.error_message  := NULL;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Derive deliver_to_location_id');
            END IF;

            rcv_transactions_interface_sv.get_location_id(location_id_record);
            x_cascaded_table(n).deliver_to_location_id     := location_id_record.location_id;
            x_cascaded_table(n).error_status               := location_id_record.error_record.error_status;
            rcv_error_pkg.set_error_message(location_id_record.error_record.error_message, x_cascaded_table(n).error_message);
            rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status,
                                                'DELIVER_TO_LOCATION_CODE',
                                                FALSE
                                               );
        END IF;

        x_progress       := '090';

        IF     (x_cascaded_table(n).error_status IN('S', 'W'))
           AND (    x_cascaded_table(n).locator_id IS NULL
                AND x_cascaded_table(n).LOCATOR IS NOT NULL) THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('X_progress ' || x_progress);
            END IF;

            locator_id_record.LOCATOR                     := x_cascaded_table(n).LOCATOR;
            locator_id_record.subinventory                := x_cascaded_table(n).subinventory;
            locator_id_record.to_organization_id          := x_cascaded_table(n).to_organization_id;
            locator_id_record.error_record.error_status   := 'S';
            locator_id_record.error_record.error_message  := NULL;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Derive locator_id for ' || x_cascaded_table(n).LOCATOR);
                asn_debug.put_line('  subinventory is  ' || x_cascaded_table(n).subinventory);
            END IF;

            /*
             *  bug 724495 add derivation of locator in the preprocessor
                  */
            rcv_transactions_interface_sv.get_locator_id(locator_id_record);
            x_cascaded_table(n).locator_id                := locator_id_record.locator_id;
            x_cascaded_table(n).error_status              := locator_id_record.error_record.error_status;
            rcv_error_pkg.set_error_message(locator_id_record.error_record.error_message, x_cascaded_table(n).error_message);
            rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status,
                                                'LOCATOR',
                                                FALSE
                                               );
        END IF;

        x_progress       := '091';

        IF     (x_cascaded_table(n).error_status IN('S', 'W'))
           AND (    x_cascaded_table(n).reason_id IS NULL
                AND x_cascaded_table(n).reason_name IS NOT NULL) THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('X_progress ' || x_progress);
            END IF;

            reason_id_record.reason_name                 := x_cascaded_table(n).reason_name;
            reason_id_record.error_record.error_status   := 'S';
            reason_id_record.error_record.error_message  := NULL;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Derive Reason_id');
            END IF;

            rcv_transactions_interface_sv.get_reason_id(reason_id_record);
            x_cascaded_table(n).reason_id                := reason_id_record.reason_id;
            x_cascaded_table(n).error_status             := reason_id_record.error_record.error_status;
            rcv_error_pkg.set_error_message(reason_id_record.error_record.error_message, x_cascaded_table(n).error_message);
            rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status,
                                                'REASON_NAME',
                                                FALSE
                                               );
        END IF;

        x_progress       := '092';

        -- Derive auto_transact_code from transaction_type if it is null

        IF     (x_cascaded_table(n).error_status IN('S', 'W'))
           AND x_cascaded_table(n).auto_transact_code IS NULL THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('X_progress ' || x_progress);
                asn_debug.put_line('Setting auto_transact_code to transaction_type ' || x_cascaded_table(n).transaction_type);
            END IF;

            x_cascaded_table(n).auto_transact_code  := x_cascaded_table(n).transaction_type;
        END IF;

        x_progress       := '093';

        -- Change transaction type based on combination of
        -- transaction_type and auto_transact_code

        IF (x_cascaded_table(n).error_status IN('S', 'W')) THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('X_progress ' || x_progress);
            END IF;

            IF     x_cascaded_table(n).transaction_type = 'SHIP'
               AND x_cascaded_table(n).auto_transact_code = 'DELIVER' THEN
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Changing the transaction_type to RECEIVE FROM SHIP');
                END IF;

                x_cascaded_table(n).transaction_type  := 'RECEIVE';
            END IF;
        END IF;

        -- Check whether Qty > 0

        x_progress       := '097';

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('X_progress ' || x_progress);
        END IF;

        IF     x_cascaded_table(n).error_status IN('S', 'W')
           AND x_cascaded_table(n).quantity <= 0 THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Quantity is <= zero. Cascade will fail');
            END IF;

            x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
            rcv_error_pkg.set_error_message('RCV_ITEM_NO_SHIP_QTY', x_cascaded_table(n).error_message);
            rcv_error_pkg.set_token('ITEM', x_cascaded_table(n).item_num);
            rcv_error_pkg.log_interface_error('QUANTITY', FALSE);
        END IF;

        -- the following steps will create a set of rows linking the line_record with
        -- its corresponding po_line_location rows until the quantity value from
        -- the asn is consumed.  (Cascade)

/* 2119137 : If the user populates rcv_transactions_interface
   with po_line_id, then ROI errors out with
   RCV_ASN_NO_PO_LINE_LOCATION_ID when the docment_line_num
   is not provided for one time items. Modified the "if" criteria in
   such a way that the ROI validation does'nt error out when
   po_line_id is populated for one time items. */
        x_progress       := '098';

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('X_progress ' || x_progress);
        END IF;

        IF (    x_cascaded_table(n).po_header_id IS NOT NULL
            AND (   x_cascaded_table(n).item_id IS NOT NULL
                 OR x_cascaded_table(n).vendor_item_num IS NOT NULL
                 OR x_cascaded_table(n).po_line_id IS NOT NULL
                 OR x_cascaded_table(n).document_line_num IS NOT NULL)
            AND x_cascaded_table(n).error_status IN('S', 'W')
           ) THEN
            -- Copy record from main table to temp table

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Copy record from main table to temp table');
            END IF;

            current_n                       := 1;
            temp_cascaded_table(current_n)  := x_cascaded_table(n);

            -- Get all rows which meet this condition
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Get all rows which meet this condition');
                asn_debug.put_line('Transaction Type = ' || x_cascaded_table(n).transaction_type);
                asn_debug.put_line('Auto Transact Code = ' || x_cascaded_table(n).auto_transact_code);
            END IF;

                 -- bug 1362237  Deriving the document_line_num
            -- and document_shipment_line_num when line_id and/or line_location_id
            -- are provided.

            IF     temp_cascaded_table(current_n).document_line_num IS NULL
               AND temp_cascaded_table(current_n).po_line_id IS NOT NULL THEN
                BEGIN
                    SELECT line_num
                    INTO   temp_cascaded_table(current_n).document_line_num
                    FROM   po_lines
                    WHERE  po_line_id = temp_cascaded_table(current_n).po_line_id;
                EXCEPTION
                    WHEN OTHERS THEN
                        IF (g_asn_debug = 'Y') THEN
                            asn_debug.put_line('wrong po_line_id entered in rcv_transactions_interface');
                        END IF;
                END;
            END IF;

            IF     temp_cascaded_table(current_n).document_shipment_line_num IS NULL
               AND temp_cascaded_table(current_n).po_line_location_id IS NOT NULL THEN
                BEGIN
                    SELECT shipment_num
                    INTO   temp_cascaded_table(current_n).document_shipment_line_num
                    FROM   po_line_locations
                    WHERE  line_location_id = temp_cascaded_table(current_n).po_line_location_id;
                EXCEPTION
                    WHEN OTHERS THEN
                        IF (g_asn_debug = 'Y') THEN
                            asn_debug.put_line('wrong po_line_location_id entered in rcv_transactions_interface');
                        END IF;
                END;
            END IF;

            IF     temp_cascaded_table(current_n).document_distribution_num IS NULL
               AND temp_cascaded_table(current_n).po_distribution_id IS NOT NULL THEN
                BEGIN
                    SELECT distribution_num
                    INTO   temp_cascaded_table(current_n).document_distribution_num
                    FROM   po_distributions
                    WHERE  po_distribution_id = temp_cascaded_table(current_n).po_distribution_id;
                EXCEPTION
                    WHEN OTHERS THEN
                        IF (g_asn_debug = 'Y') THEN
                            asn_debug.put_line('wrong po_distribution_id entered in rcv_transactions_interface');
                        END IF;
                END;
            END IF;

        -- 1362237
/* Bug 1898283 : The Receiving control of "Enforce Ship to Location was
   not working for ROI. So corrected the code so that it now behaves the same way as
   the Form Behaves. i.e.,
   Proceed without any error messages if the enforcement is set to "None"
   Enter error message in po_interface_errors if the enforcement is "Warning"
   Enter error message in po_interface_errors if the enforcement is "Reject"
   and error out.
   This validation is done by comparing the enforce_ship_location_code from
   po_line_locations and assigning the proper ship_location_id into a
   temporary variable temp_mirror_ship_to_loc_id  and passing the temp
   variable as a parameter to open the cursor "Distributions".
*/

/* Bug 2208664 : The fix done as part of 1898283 was reverted back and
   performed at a different location.
*/
            IF (    x_cascaded_table(n).transaction_type <> 'DELIVER'
                AND NVL(x_cascaded_table(n).auto_transact_code, 'RECEIVE') <> 'DELIVER') THEN
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Open Shipment records');
                    asn_debug.put_line('PO Header id ' || TO_CHAR(temp_cascaded_table(current_n).po_header_id));
                    asn_debug.put_line('Item Id ' || TO_CHAR(temp_cascaded_table(current_n).item_id));
                    asn_debug.put_line('PO Line Num ' || TO_CHAR(temp_cascaded_table(current_n).document_line_num));
                    asn_debug.put_line('PO Release Id ' || TO_CHAR(temp_cascaded_table(current_n).po_release_id));
                    asn_debug.put_line('Shipment Line num ' || TO_CHAR(temp_cascaded_table(current_n).document_shipment_line_num));
                    asn_debug.put_line('PO LINE LOCATION ID ' || TO_CHAR(temp_cascaded_table(current_n).document_distribution_num));
                    asn_debug.put_line('Ship To Organization ID ' || TO_CHAR(temp_cascaded_table(current_n).to_organization_id));
                    asn_debug.put_line('Ship To Location Id ' || TO_CHAR(NVL(temp_cascaded_table(current_n).ship_to_location_id, x_header_record.header_record.location_id)));
                    asn_debug.put_line('Vendor Item Num ' || temp_cascaded_table(current_n).vendor_item_num);
                    asn_debug.put_line('Proceed to open cursor');
                END IF;

/* Bug 2208664 : Nullified the ship_to_location_id when calling
the cursors shipments, count_shipments, distributions and
count_distributions. The proper value of ship_to_location_id will
be set after values are fetched and validated for the
location control code set at PO.
*/
                OPEN shipments(temp_cascaded_table(current_n).po_header_id,
                               temp_cascaded_table(current_n).item_id,
                               temp_cascaded_table(current_n).document_line_num,
                               temp_cascaded_table(current_n).po_release_id,
                               temp_cascaded_table(current_n).document_shipment_line_num,
                               temp_cascaded_table(current_n).to_organization_id,
                               NULL,       -- ship_to_location_id
                                     --  nvl(temp_mirror_ship_to_loc_id,
                                     --  nvl(temp_cascaded_table(current_n).ship_to_location_id,
                                         --  X_header_record.header_record.location_id),
                               temp_cascaded_table(current_n).vendor_item_num
                              );
                -- count_shipments just gets the count of rows found in shipments

                OPEN count_shipments(temp_cascaded_table(current_n).po_header_id,
                                     temp_cascaded_table(current_n).item_id,
                                     temp_cascaded_table(current_n).document_line_num,
                                     temp_cascaded_table(current_n).po_release_id,
                                     temp_cascaded_table(current_n).document_shipment_line_num,
                                     temp_cascaded_table(current_n).to_organization_id,
                                     NULL,       -- ship_to_location_id
                                           --  nvl(temp_mirror_ship_to_loc_id,
                                           --  nvl(temp_cascaded_table(current_n).ship_to_location_id,
                                               --  X_header_record.header_record.location_id),
                                     temp_cascaded_table(current_n).vendor_item_num
                                    );
            ELSIF(   x_cascaded_table(n).transaction_type = 'DELIVER'
                  OR NVL(x_cascaded_table(n).auto_transact_code, 'RECEIVE') = 'DELIVER') THEN
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Open Distribution records');
                    asn_debug.put_line('PO Header id ' || TO_CHAR(temp_cascaded_table(current_n).po_header_id));
                    asn_debug.put_line('Item Id ' || TO_CHAR(temp_cascaded_table(current_n).item_id));
                    asn_debug.put_line('PO Line Num ' || TO_CHAR(temp_cascaded_table(current_n).document_line_num));
                    asn_debug.put_line('PO Release Id ' || TO_CHAR(temp_cascaded_table(current_n).po_release_id));
                    asn_debug.put_line('Shipment Line num ' || TO_CHAR(temp_cascaded_table(current_n).document_shipment_line_num));
                    asn_debug.put_line('Distribution num ' || TO_CHAR(temp_cascaded_table(current_n).document_distribution_num));
                    asn_debug.put_line('Ship To Organization ID ' || TO_CHAR(temp_cascaded_table(current_n).to_organization_id));
                    asn_debug.put_line('Ship To Location Id ' || TO_CHAR(NVL(temp_cascaded_table(current_n).ship_to_location_id, x_header_record.header_record.location_id)));
                    asn_debug.put_line('Vendor Item Num ' || temp_cascaded_table(current_n).vendor_item_num);
                    asn_debug.put_line('Proceed to open cursor');
                END IF;

                OPEN distributions(temp_cascaded_table(current_n).po_header_id,
                                   temp_cascaded_table(current_n).item_id,
                                   temp_cascaded_table(current_n).document_line_num,
                                   temp_cascaded_table(current_n).po_release_id,
                                   temp_cascaded_table(current_n).document_shipment_line_num,
                                   temp_cascaded_table(current_n).document_distribution_num,
                                   temp_cascaded_table(current_n).to_organization_id,
                                   NULL,       -- ship_to_location_id
                                         --  nvl(temp_mirror_ship_to_loc_id,
                                         --  nvl(temp_cascaded_table(current_n).ship_to_location_id,
                                             --  X_header_record.header_record.location_id),
                                   temp_cascaded_table(current_n).vendor_item_num
                                  );
                -- count_distributions just gets the count of rows found in distributions

                OPEN count_distributions(temp_cascaded_table(current_n).po_header_id,
                                         temp_cascaded_table(current_n).item_id,
                                         temp_cascaded_table(current_n).document_line_num,
                                         temp_cascaded_table(current_n).po_release_id,
                                         temp_cascaded_table(current_n).document_shipment_line_num,
                                         temp_cascaded_table(current_n).document_distribution_num,
                                         temp_cascaded_table(current_n).to_organization_id,
                                         NULL,       -- ship_to_location_id
                                               --  nvl(temp_mirror_ship_to_loc_id,
                                               --  nvl(temp_cascaded_table(current_n).ship_to_location_id,
                                                   --  X_header_record.header_record.location_id),
                                         temp_cascaded_table(current_n).vendor_item_num
                                        );
            END IF;

            -- Assign shipped quantity to remaining quantity
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Assign shipped quantity to remaining quantity');
                asn_debug.put_line('Pointer in temp_cascade ' || TO_CHAR(current_n));
            END IF;

            x_remaining_quantity            := temp_cascaded_table(current_n).quantity;
            x_bkp_qty                       := x_remaining_quantity; -- used for decrementing cum qty for first record
            x_remaining_qty_po_uom          := 0;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Have assigned the quantity');
            END IF;

            -- Calculate tax_amount_factor for calculating tax_amount for
            -- each cascaded line

            IF NVL(temp_cascaded_table(current_n).tax_amount, 0) <> 0 THEN
                tax_amount_factor  := temp_cascaded_table(current_n).tax_amount / x_remaining_quantity;
            ELSE
                tax_amount_factor  := 0;
            END IF;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Tax Factor ' || TO_CHAR(tax_amount_factor));
                asn_debug.put_line('Shipped Quantity : ' || TO_CHAR(x_remaining_quantity));
            END IF;

            x_first_trans                   := TRUE;
            transaction_ok                  := FALSE;

            /*
            ** Get the count of the number of records depending on the
            ** the transaction type
            */
            IF (    x_cascaded_table(n).transaction_type <> 'DELIVER'
                AND NVL(x_cascaded_table(n).auto_transact_code, 'RECEIVE') <> 'DELIVER') THEN
                FETCH count_shipments INTO x_record_count;
            ELSE
                FETCH count_distributions INTO x_record_count;
            END IF;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Before starting Cascade');
            END IF;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Record Count = ' || x_record_count);
            END IF;

            LOOP
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Backup Qty ' || TO_CHAR(x_bkp_qty));
                    asn_debug.put_line('Remaining Quantity ASN UOM ' || TO_CHAR(x_remaining_quantity));
                END IF;

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('open shipments and fetch');
                END IF;

                /*
                ** Fetch the appropriate record
                */
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('DEBUG: transaction_type = ' || x_cascaded_table(n).transaction_type);
                END IF;

                IF (    x_cascaded_table(n).transaction_type <> 'DELIVER'
                    AND NVL(x_cascaded_table(n).auto_transact_code, 'RECEIVE') <> 'DELIVER') THEN
                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('Fetching Shipments Cursor');
                    END IF;

                    FETCH shipments INTO x_shipmentdistributionrec;

                    /*
                    ** Check if this is the last record
                    */
                    IF (shipments%NOTFOUND) THEN
                        lastrecord  := TRUE;
                    END IF;

                    rows_fetched  := shipments%ROWCOUNT;

                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('Shipment Rows fetched ' || TO_CHAR(rows_fetched));
                    END IF;
                ELSE
                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('Fetching Distributions Cursor');
                    END IF;

                    FETCH distributions INTO x_shipmentdistributionrec;

                    /*
                    ** Check if this is the last record
                    */
                    IF (distributions%NOTFOUND) THEN
                        lastrecord  := TRUE;
                    END IF;

                    rows_fetched  := distributions%ROWCOUNT;

                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('Distribution Rows fetched ' || TO_CHAR(rows_fetched));
                    END IF;
                END IF;

                IF (   lastrecord
                    OR x_remaining_quantity <= 0) THEN
                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('Hit exit condition');
                    END IF;

                    IF NOT x_first_trans THEN -- x_first_trans has been reset which means some cascade has
                                              -- happened. Otherwise current_n = 1
                        current_n  := current_n - 1;
                    END IF;

                    -- do the tolerance act here
                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('Temp table pointer ' || TO_CHAR(current_n));
                        asn_debug.put_line('Check which condition has occured');
                    END IF;

                    -- lastrecord...we have run out of rows and we still have quantity to allocate
                    IF x_remaining_quantity > 0 THEN
                        IF (g_asn_debug = 'Y') THEN
                            asn_debug.put_line('There is quantity remaining');
                            asn_debug.put_line('Need to check qty tolerances');
                        END IF;

                        IF     rows_fetched > 0
                           AND NOT x_first_trans THEN  -- we had got atleast some rows from our shipments cursor
                                                      -- we have atleast one row cascaded (not null line_location_id)
                            SELECT NVL(po_line_locations.qty_rcv_exception_code, 'NONE')
                            INTO   x_qty_rcv_exception_code
                            FROM   po_line_locations
                            WHERE  line_location_id = temp_cascaded_table(current_n).po_line_location_id;

                            IF (g_asn_debug = 'Y') THEN
                                asn_debug.put_line('Qty tolerance exception code ' || NVL(x_qty_rcv_exception_code, 'NONE1'));
                            END IF;

                            IF x_qty_rcv_exception_code IN('NONE', 'WARNING') THEN
                                /* Bug# 1807842 */
                                IF (temp_cascaded_table(current_n).quantity < x_converted_trx_qty) THEN
                                    IF (g_asn_debug = 'Y') THEN
                                        asn_debug.put_line('Tolerable quantity ' || TO_CHAR(x_converted_trx_qty));
                                        asn_debug.put_line('Current quantity ' || TO_CHAR(temp_cascaded_table(current_n).quantity));
                                        asn_debug.put_line('Current shipped quantity ' || TO_CHAR(temp_cascaded_table(current_n).quantity_shipped));
                                        asn_debug.put_line('Assign remaining ASN UOM qty ' || TO_CHAR(x_remaining_quantity) || ' to last record');
                                        asn_debug.put_line('Assign remaining PO UOM qty ' || TO_CHAR(x_remaining_qty_po_uom) || ' to last record');
                                    END IF;

                                    temp_cascaded_table(current_n).quantity             := temp_cascaded_table(current_n).quantity + x_remaining_quantity;
                                    temp_cascaded_table(current_n).quantity_shipped     := temp_cascaded_table(current_n).quantity_shipped + x_remaining_quantity;
                                    temp_cascaded_table(current_n).source_doc_quantity  := temp_cascaded_table(current_n).source_doc_quantity + x_remaining_qty_po_uom;
                                    temp_cascaded_table(current_n).primary_quantity     :=   temp_cascaded_table(current_n).primary_quantity
                                                                                           + convert_into_correct_qty(x_remaining_quantity,
                                                                                                                      temp_cascaded_table(1).unit_of_measure,
                                                                                                                      temp_cascaded_table(1).item_id,
                                                                                                                      temp_cascaded_table(1).primary_unit_of_measure
                                                                                                                     );
                                END IF;   /* Bug# 1807842 */

                                -- Vendor Cum Qty
                                IF NVL(temp_cascaded_table(current_n).vendor_cum_shipped_qty, 0) <> 0 THEN
                                    temp_cascaded_table(current_n).vendor_cum_shipped_qty  := temp_cascaded_table(current_n).vendor_cum_shipped_qty + temp_cascaded_table(current_n).primary_quantity;
                                END IF;

                                temp_cascaded_table(current_n).tax_amount  := ROUND(temp_cascaded_table(current_n).quantity * tax_amount_factor, 6);

                                IF (g_asn_debug = 'Y') THEN
                                    asn_debug.put_line('Current quantity ' || TO_CHAR(temp_cascaded_table(current_n).quantity));
                                    asn_debug.put_line('Current shipped quantity ' || TO_CHAR(temp_cascaded_table(current_n).quantity_shipped));
                                    asn_debug.put_line('Current source document quantity ' || TO_CHAR(temp_cascaded_table(current_n).source_doc_quantity));
                                    asn_debug.put_line('Current primary quantity ' || TO_CHAR(temp_cascaded_table(current_n).primary_quantity));
                                    asn_debug.put_line('Current Tax Amount ' || TO_CHAR(temp_cascaded_table(current_n).tax_amount));
                                END IF;

                                IF x_qty_rcv_exception_code = 'WARNING' THEN
                                    IF (g_asn_debug = 'Y') THEN
                                        asn_debug.put_line('IN WARNING');
                                    END IF;

                                    temp_cascaded_table(current_n).error_status   := 'W';
                                    temp_cascaded_table(current_n).error_message  := 'RCV_SHIP_QTY_OVER_TOLERANCE';

                                    IF (g_asn_debug = 'Y') THEN
                                        asn_debug.put_line('Group Id ' || TO_CHAR(temp_cascaded_table(current_n).GROUP_ID));
                                        asn_debug.put_line('Header Interface Id ' || TO_CHAR(temp_cascaded_table(current_n).header_interface_id));
                                        asn_debug.put_line('IN Trans Id ' || TO_CHAR(temp_cascaded_table(current_n).interface_transaction_id));
                                    END IF;

                                    x_cascaded_table(n).error_status              := rcv_error_pkg.g_ret_sts_warning;
                                    rcv_error_pkg.set_error_message('RCV_SHIP_QTY_OVER_TOLERANCE', x_cascaded_table(n).error_message);
                                    rcv_error_pkg.set_token('QTY_A', temp_cascaded_table(current_n).quantity);
                                    rcv_error_pkg.set_token('QTY_B', temp_cascaded_table(current_n).quantity - x_remaining_quantity);
                                    rcv_error_pkg.log_interface_warning('QUANTITY');

                                    IF (g_asn_debug = 'Y') THEN
                                        asn_debug.put_line('Error Status ' || temp_cascaded_table(current_n).error_status);
                                        asn_debug.put_line('Error message ' || temp_cascaded_table(current_n).error_message);
                                        asn_debug.put_line('Need to insert into po_interface_errors');
                                    END IF;
                                END IF;

                                IF (g_asn_debug = 'Y') THEN
                                    asn_debug.put_line('Current quantity ' || TO_CHAR(temp_cascaded_table(current_n).quantity));
                                    asn_debug.put_line('Current shipped quantity ' || TO_CHAR(temp_cascaded_table(current_n).quantity_shipped));
                                    asn_debug.put_line('Current source document quantity ' || TO_CHAR(temp_cascaded_table(current_n).source_doc_quantity));
                                    asn_debug.put_line('Current primary quantity ' || TO_CHAR(temp_cascaded_table(current_n).primary_quantity));
                                    asn_debug.put_line('Current Tax Amount ' || TO_CHAR(temp_cascaded_table(current_n).tax_amount));
                                END IF;
                            ELSIF x_qty_rcv_exception_code = 'REJECT' THEN
                                IF (g_asn_debug = 'Y') THEN
                                    asn_debug.put_line('Extra ASN UOM Quantity ' || TO_CHAR(x_remaining_quantity));
                                    asn_debug.put_line('Extra PO UOM Quantity ' || TO_CHAR(x_remaining_qty_po_uom));
                                END IF;

                                IF (g_asn_debug = 'Y') THEN
                                    asn_debug.put_line('delete the temp table ');
                                END IF;

                                x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
                                rcv_error_pkg.set_error_message('RCV_SHIP_QTY_OVER_TOLERANCE', x_cascaded_table(n).error_message);
                                rcv_error_pkg.set_token('QTY_A', x_cascaded_table(n).quantity);
                                rcv_error_pkg.set_token('QTY_B', x_cascaded_table(n).quantity - x_remaining_quantity);
                                rcv_error_pkg.log_interface_error('QUANTITY', FALSE);

                                IF temp_cascaded_table.COUNT > 0 THEN
                                    FOR i IN 1 .. temp_cascaded_table.COUNT LOOP
                                        temp_cascaded_table.DELETE(i);
                                    END LOOP;
                                END IF;

                                IF (g_asn_debug = 'Y') THEN
                                    asn_debug.put_line('mark the actual table with error status');
                                    asn_debug.put_line('Error Status ' || x_cascaded_table(n).error_status);
                                    asn_debug.put_line('Error message ' || x_cascaded_table(n).error_message);
                                END IF;

                                IF (g_asn_debug = 'Y') THEN
                                    asn_debug.put_line('Need to insert a row into po_interface_errors');
                                END IF;
                            END IF;
                        ELSE
                            IF rows_fetched = 0 THEN
                                IF (g_asn_debug = 'Y') THEN
                                    asn_debug.put_line('No rows were retrieved from cursor.');
                                END IF;
                            ELSIF x_first_trans THEN
                                IF (g_asn_debug = 'Y') THEN
                                    asn_debug.put_line('No rows were cascaded');
                                END IF;
                            END IF;

                            x_temp_count                      := 1;
                            x_cascaded_table(n).error_status  := 'E';

                            /* nwang add error messages */

                            /* Bug 2340533 - Added a message RCV_ASN_NO_OPEN_SHIPMENTS which conveys that
                                no shipments exists for receiving for the given PO.
                             */
                            IF (    x_cascaded_table(n).transaction_type <> 'DELIVER'
                                AND NVL(x_cascaded_table(n).auto_transact_code, 'RECEIVE') <> 'DELIVER') THEN
                                -- Bug 2551443 Removed po_distributions from the FROM clause
                                SELECT COUNT(*)
                                INTO   x_temp_count
                                FROM   po_line_locations pll,
                                       po_lines pl,
                                       po_headers ph
                                WHERE  ph.po_header_id = temp_cascaded_table(current_n).po_header_id
                                AND    pll.po_header_id = ph.po_header_id
                                AND    pl.line_num = NVL(temp_cascaded_table(current_n).document_line_num, pl.line_num)
                                AND    NVL(pll.po_release_id, 0) = NVL(temp_cascaded_table(current_n).po_release_id, NVL(pll.po_release_id, 0))
                                AND    pll.shipment_num = NVL(temp_cascaded_table(current_n).document_shipment_line_num, pll.shipment_num)
                                AND    pll.po_line_id = pl.po_line_id;

                                IF x_temp_count = 0 THEN
                                    x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
                                    rcv_error_pkg.set_error_message('RCV_ASN_NO_OPEN_SHIPMENTS', x_cascaded_table(n).error_message);
                                    rcv_error_pkg.set_token('PONUM', temp_cascaded_table(current_n).document_num);
                                    rcv_error_pkg.log_interface_error('DOCUMENT_NUM', FALSE);
                                ELSE
                                    SELECT NVL(pl.item_id, 0),
                                           NVL(pll.approved_flag, 'N'),
                                           NVL(pll.cancel_flag, 'N'),
                                           NVL(pll.closed_code, 'OPEN'),
                                           pll.shipment_type,
                                           pll.ship_to_organization_id,
                                           pll.ship_to_location_id,
                                           NVL(pl.vendor_product_num, '-999')
                                    INTO   x_item_id,
                                           x_approved_flag,
                                           x_cancel_flag,
                                           x_closed_code,
                                           x_shipment_type,
                                           x_ship_to_organization_id,
                                           x_ship_to_location_id,
                                           x_vendor_product_num
                                    FROM   po_line_locations pll,
                                           po_lines pl,
                                           po_headers ph
                                    WHERE  ph.po_header_id = temp_cascaded_table(current_n).po_header_id
                                    AND    pll.po_header_id = ph.po_header_id
                                    AND    pl.line_num = NVL(temp_cascaded_table(current_n).document_line_num, pl.line_num)
                                    AND    NVL(pll.po_release_id, 0) = NVL(temp_cascaded_table(current_n).po_release_id, NVL(pll.po_release_id, 0))
                                    AND    pll.shipment_num = NVL(temp_cascaded_table(current_n).document_shipment_line_num, pll.shipment_num)
                                    AND    pll.po_line_id = pl.po_line_id;
                                END IF; -- x_temp_count = 0
                            ELSIF(   x_cascaded_table(n).transaction_type = 'DELIVER'
                                  OR NVL(x_cascaded_table(n).auto_transact_code, 'RECEIVE') = 'DELIVER') THEN
                                SELECT COUNT(*)
                                INTO   x_temp_count
                                FROM   po_distributions pod,
                                       po_line_locations pll,
                                       po_lines pl,
                                       po_headers ph
                                WHERE  ph.po_header_id = temp_cascaded_table(current_n).po_header_id
                                AND    pll.po_header_id = ph.po_header_id
                                AND    pll.line_location_id = pod.line_location_id
                                AND    pl.line_num = NVL(temp_cascaded_table(current_n).document_line_num, pl.line_num)
                                AND    NVL(pll.po_release_id, 0) = NVL(temp_cascaded_table(current_n).po_release_id, NVL(pll.po_release_id, 0))
                                AND    pll.shipment_num = NVL(temp_cascaded_table(current_n).document_shipment_line_num, pll.shipment_num)
                                AND    pll.po_line_id = pl.po_line_id
                                AND    pod.distribution_num = NVL(temp_cascaded_table(current_n).document_distribution_num, pod.distribution_num);

                                IF x_temp_count = 0 THEN
                                    x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
                                    rcv_error_pkg.set_error_message('RCV_ASN_INVALID_DIST_NUM', x_cascaded_table(n).error_message);
                                    rcv_error_pkg.set_token('NUMBER', temp_cascaded_table(current_n).document_distribution_num);
                                    rcv_error_pkg.log_interface_error('DOCUMENT_DISTRIBUTION_NUM', FALSE);
                                ELSE
                                    SELECT NVL(pl.item_id, 0),
                                           NVL(pll.approved_flag, 'N'),
                                           NVL(pll.cancel_flag, 'N'),
                                           NVL(pll.closed_code, 'OPEN'),
                                           pll.shipment_type,
                                           pll.ship_to_organization_id,
                                           pll.ship_to_location_id,
                                           NVL(pl.vendor_product_num, '-999')
                                    INTO   x_item_id,
                                           x_approved_flag,
                                           x_cancel_flag,
                                           x_closed_code,
                                           x_shipment_type,
                                           x_ship_to_organization_id,
                                           x_ship_to_location_id,
                                           x_vendor_product_num
                                    FROM   po_distributions pod,
                                           po_line_locations pll,
                                           po_lines pl,
                                           po_headers ph
                                    WHERE  ph.po_header_id = temp_cascaded_table(current_n).po_header_id
                                    AND    pll.po_header_id = ph.po_header_id
                                    AND    pll.line_location_id = pod.line_location_id
                                    AND    pl.line_num = NVL(temp_cascaded_table(current_n).document_line_num, pl.line_num)
                                    AND    NVL(pll.po_release_id, 0) = NVL(temp_cascaded_table(current_n).po_release_id, NVL(pll.po_release_id, 0))
                                    AND    pll.shipment_num = NVL(temp_cascaded_table(current_n).document_shipment_line_num, pll.shipment_num)
                                    AND    pll.po_line_id = pl.po_line_id
                                    AND    pod.distribution_num = NVL(temp_cascaded_table(current_n).document_distribution_num, pod.distribution_num);
                                END IF; -- x_temp_count = 0;
                            END IF; -- transaction_type <> 'DELIVER'

                            IF (x_temp_count <> 0) THEN
                                IF x_item_id <> NVL(temp_cascaded_table(current_n).item_id, x_item_id) THEN
                                    x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
                                    rcv_error_pkg.set_error_message('RCV_ASN_ITEM_NOT_ALLOWED', x_cascaded_table(n).error_message);
                                    rcv_error_pkg.set_token('NUMBER', temp_cascaded_table(current_n).item_num);
                                    rcv_error_pkg.log_interface_error('ITEM_NUM', FALSE);
                                END IF;

                                IF x_approved_flag <> 'Y' THEN
                                    x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
                                    rcv_error_pkg.set_error_message('RCV_ASN_SHIPMT_NOT_APPROVED', x_cascaded_table(n).error_message);
                                    rcv_error_pkg.set_token('NUMBER', temp_cascaded_table(current_n).document_shipment_line_num);
                                    rcv_error_pkg.set_token('PO_NUM', temp_cascaded_table(current_n).document_num);
                                    rcv_error_pkg.log_interface_error('DOCUMENT_SHIPMENT_LINE_NUM', FALSE);
                                END IF;

                                IF x_cancel_flag <> 'N' THEN
                                    x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
                                    rcv_error_pkg.set_error_message('RCV_ASN_SHIPMT_CANCELLED', x_cascaded_table(n).error_message);
                                    rcv_error_pkg.set_token('NUMBER', temp_cascaded_table(current_n).document_shipment_line_num);
                                    rcv_error_pkg.log_interface_error('DOCUMENT_SHIPMENT_LINE_NUM', FALSE);
                                END IF;

                                IF x_closed_code = 'FINALLY_CLOSED' THEN
                                    x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
                                    rcv_error_pkg.set_error_message('RCV_ASN_SHIPMT_FINALLY_CLOSED', x_cascaded_table(n).error_message);
                                    rcv_error_pkg.set_token('NUMBER', temp_cascaded_table(current_n).document_shipment_line_num);
                                    rcv_error_pkg.log_interface_error('DOCUMENT_SHIPMENT_LINE_NUM', FALSE);
                                END IF;

                                IF x_shipment_type NOT IN('STANDARD', 'BLANKET', 'SCHEDULED') THEN
                                    x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
                                    rcv_error_pkg.set_error_message('RCV_ASN_INVAL_SHIPMT_TYPE', x_cascaded_table(n).error_message);
                                    rcv_error_pkg.set_token('NUMBER', temp_cascaded_table(current_n).document_shipment_line_num);
                                    rcv_error_pkg.log_interface_error('DOCUMENT_SHIPMENT_LINE_NUM', FALSE);
                                END IF;

                                IF x_ship_to_organization_id <> NVL(temp_cascaded_table(current_n).to_organization_id, x_ship_to_organization_id) THEN
                                    x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
                                    rcv_error_pkg.set_error_message('RCV_ASN_INVAL_SHIP_TO_ORG', x_cascaded_table(n).error_message);
                                    rcv_error_pkg.set_token('VALUE', temp_cascaded_table(current_n).to_organization_code);
                                    rcv_error_pkg.log_interface_error('TO_ORGANIZATION_CODE', FALSE);
                                END IF;

                                IF x_ship_to_location_id <> NVL(NVL(temp_cascaded_table(current_n).ship_to_location_id, x_header_record.header_record.location_id), x_ship_to_location_id) THEN
                                    x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
                                    rcv_error_pkg.set_error_message('RCV_ASN_INVAL_SHIP_TO_LOC', x_cascaded_table(n).error_message);
                                    rcv_error_pkg.set_token('VALUE', temp_cascaded_table(current_n).ship_to_location_code);
                                    rcv_error_pkg.log_interface_error('SHIP_TO_LOCATION_CODE', FALSE);
                                END IF;

                                IF x_vendor_product_num <> NVL(temp_cascaded_table(current_n).vendor_item_num, x_vendor_product_num) THEN
                                    x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
                                    rcv_error_pkg.set_error_message('RCV_ASN_INVAL_VENDOR_PROD_NUM', x_cascaded_table(n).error_message);
                                    rcv_error_pkg.set_token('NUMBER', temp_cascaded_table(current_n).vendor_item_num);
                                    rcv_error_pkg.log_interface_error('VENDOR_ITEM_NUM', FALSE);
                                END IF;
                            END IF; -- x_temp_count = 0;



                                    -- Delete the temp_cascaded_table just to be sure

                            IF temp_cascaded_table.COUNT > 0 THEN
                                FOR i IN 1 .. temp_cascaded_table.COUNT LOOP
                                    temp_cascaded_table.DELETE(i);
                                END LOOP;
                            END IF;
                        END IF;
                    ELSE
                        IF (g_asn_debug = 'Y') THEN
                            asn_debug.put_line('Remaining ASN UOM quantity is zero ' || TO_CHAR(x_remaining_quantity));
                            asn_debug.put_line('Remaining PO UOM quantity is zero ' || TO_CHAR(x_remaining_qty_po_uom));
                            asn_debug.put_line('Return the cascaded rows back to the calling procedure');
                        END IF;
                    END IF;

                    -- close cursors
                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('Close cursors shipments, count_shipments, distributions, count_disributions');
                    END IF;

                    IF shipments%ISOPEN THEN
                        CLOSE shipments;
                    END IF;

                    IF count_shipments%ISOPEN THEN
                        CLOSE count_shipments;
                    END IF;

                    IF distributions%ISOPEN THEN
                        CLOSE distributions;
                    END IF;

                    IF count_distributions%ISOPEN THEN
                        CLOSE count_distributions;
                    END IF;

                    EXIT;
                END IF;

                -- eliminate the row if it fails the date check

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Count in temp_cascade_table : ' || TO_CHAR(temp_cascaded_table.COUNT));
                    asn_debug.put_line('Cursor record ' || TO_CHAR(rows_fetched));
                    asn_debug.put_line('Check date tolerance');
                END IF;

                check_date_tolerance(NVL(temp_cascaded_table(1).expected_receipt_date, x_header_record.header_record.expected_receipt_date), -- Bug 487222
                                     x_shipmentdistributionrec.promised_date,
                                     x_shipmentdistributionrec.days_early_receipt_allowed,
                                     x_shipmentdistributionrec.days_late_receipt_allowed,
                                     x_shipmentdistributionrec.receipt_days_exception_code
                                    );

                /* bug 1060261 - added error message to be shown when the expected date is outside tolerance range */
                IF (x_shipmentdistributionrec.receipt_days_exception_code = 'REJECT') THEN
                    x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
                    rcv_error_pkg.set_error_message('RCV_ASN_DATE_OUT_TOL', x_cascaded_table(n).error_message);
                    rcv_error_pkg.set_token('DELIVERY DATE', NVL(temp_cascaded_table(1).expected_receipt_date, x_header_record.header_record.expected_receipt_date));
                    rcv_error_pkg.log_interface_error('EXPECTED_RECEIPT_DATE', FALSE);
                END IF;

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Days exception Code ' || NVL(x_shipmentdistributionrec.receipt_days_exception_code, 'XXX'));
                END IF;

                -- Check shipto_location enforcement

                check_shipto_enforcement(x_shipmentdistributionrec.ship_to_location_id,
                                         NVL(temp_cascaded_table(1).ship_to_location_id, x_header_record.header_record.location_id),
                                         x_shipmentdistributionrec.enforce_ship_to_location_code
                                        );

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Enforce ShipToLocation ' || NVL(x_shipmentdistributionrec.enforce_ship_to_location_code, 'XXX'));
                END IF;

/* Bug 2208664 : Enter error message in po_interface_errors if enforce_ship_to_location_code is 'WARNING', and
 Enter error message in po_interface_errors if enforce_ship_to_location_code is 'REJECT' and error out
*/
                IF (x_shipmentdistributionrec.enforce_ship_to_location_code = 'REJECT') THEN
                    BEGIN
                        x_cascaded_table(n).error_status               := rcv_error_pkg.g_ret_sts_error;
                        rcv_error_pkg.set_error_message('RCV_ASN_INVAL_SHIP_TO_LOC', x_cascaded_table(n).error_message);
                        rcv_error_pkg.set_token('VALUE', temp_cascaded_table(current_n).ship_to_location_code);
                        rcv_error_pkg.log_interface_error('SHIP_TO_LOCATION_CODE', FALSE);
                        x_shipmentdistributionrec.ship_to_location_id  := NVL(temp_cascaded_table(1).ship_to_location_id, x_header_record.header_record.location_id);
                    END;
                ELSIF(x_shipmentdistributionrec.enforce_ship_to_location_code = 'WARNING') THEN
                    BEGIN
                        x_cascaded_table(n).error_status               := rcv_error_pkg.g_ret_sts_warning;
                        rcv_error_pkg.set_error_message('RCV_ASN_INVAL_SHIP_TO_LOC', x_cascaded_table(n).error_message);
                        rcv_error_pkg.set_token('VALUE', temp_cascaded_table(current_n).ship_to_location_code);
                        rcv_error_pkg.log_interface_warning('SHIP_TO_LOCATION_CODE');
                        x_shipmentdistributionrec.ship_to_location_id  := NVL(temp_cascaded_table(1).ship_to_location_id, x_header_record.header_record.location_id);
                    END;
                END IF;

                IF     (x_shipmentdistributionrec.receipt_days_exception_code = 'NONE')
                   AND -- derived by the date tolerance procedure
                       (x_shipmentdistributionrec.enforce_ship_to_location_code IN('NONE', 'WARNING')) THEN
                    -- derived by shipto_enforcement

                    -- Changes to accept Vendor_Item_num without ITEM_ID/NUM
                    -- Item_id could be null if the ASN has the vendor_item_num provided
                    -- We need to put a value into item_id based on the cursor
                    -- We need to also figure out the primary unit for the item_id
                    -- We will do it for the first record only. Subsequent records in the
                    -- temp_table are copies of the previous one

                    -- Assuming that vendor_item_num refers to a single item. If the items
                    -- could be different then we need to move this somewhere below

                    IF     (x_first_trans)
                       AND temp_cascaded_table(current_n).item_id IS NULL THEN
                        temp_cascaded_table(current_n).item_id  := x_shipmentdistributionrec.item_id;

                        IF (g_asn_debug = 'Y') THEN
                            asn_debug.put_line('Cursor Item Id is ' || TO_CHAR(temp_cascaded_table(current_n).item_id));
                        END IF;

                        /* Start Bug# 3193969 - For one time items or EAM items which donot have an
                           item_id, primary uom should be the base uom of the class to which the
                           transaction uom is associated to */
                        IF x_cascaded_table(n).primary_unit_of_measure IS NULL THEN
                            IF temp_cascaded_table(current_n).item_id IS NULL THEN
                                BEGIN
                                    SELECT muom.unit_of_measure
                                    INTO   temp_cascaded_table(current_n).primary_unit_of_measure
                                    FROM   mtl_units_of_measure muom,
                                           mtl_units_of_measure tuom
                                    WHERE  tuom.unit_of_measure = temp_cascaded_table(current_n).unit_of_measure
                                    AND    tuom.uom_class = muom.uom_class
                                    AND    muom.base_uom_flag = 'Y';

                                    IF (g_asn_debug = 'Y') THEN
                                        asn_debug.put_line('Transaction UOM: ' || temp_cascaded_table(current_n).unit_of_measure);
                                        asn_debug.put_line('Primary UOM for one time item: ' || temp_cascaded_table(current_n).primary_unit_of_measure);
                                    END IF;
                                EXCEPTION
                                    WHEN NO_DATA_FOUND THEN
                                        temp_cascaded_table(current_n).error_status   := 'W';
                                        temp_cascaded_table(current_n).error_message  := 'Need an error message';

                                        IF (g_asn_debug = 'Y') THEN
                                            asn_debug.put_line('Primary UOM error for one time items');
                                        END IF;
                                END;
                            ELSE
                                BEGIN
                                    SELECT primary_unit_of_measure
                                    INTO   temp_cascaded_table(current_n).primary_unit_of_measure
                                    FROM   mtl_system_items
                                    WHERE  mtl_system_items.inventory_item_id = temp_cascaded_table(current_n).item_id
                                    AND    mtl_system_items.organization_id = temp_cascaded_table(current_n).to_organization_id;

                                    IF (g_asn_debug = 'Y') THEN
                                        asn_debug.put_line('Primary UOM: ' || temp_cascaded_table(current_n).primary_unit_of_measure);
                                    END IF;
                                EXCEPTION
                                    WHEN NO_DATA_FOUND THEN
                                        temp_cascaded_table(current_n).error_status   := 'W';
                                        temp_cascaded_table(current_n).error_message  := 'Need an error message';

                                        IF (g_asn_debug = 'Y') THEN
                                            asn_debug.put_line('Primary UOM error');
                                        END IF;
                                END;
                            END IF;
                        END IF;
                    /* End Bug# 3193969 */
                    END IF;

                    insert_into_table       := FALSE;
                    already_allocated_qty   := 0;

                    /*
                    ** Get the available quantity for the shipment or distribution
                    ** that is available for allocation by this interface transaction
                    */
                    IF (    x_cascaded_table(n).transaction_type <> 'DELIVER'
                        AND NVL(x_cascaded_table(n).auto_transact_code, 'RECEIVE') <> 'DELIVER') THEN
                        /*Bug# 1548597 */
                        rcv_quantities_s.get_available_quantity('RECEIVE',
                                                                x_shipmentdistributionrec.line_location_id,
                                                                'VENDOR',
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                x_converted_trx_qty,
                                                                x_tolerable_qty,
                                                                x_shipmentdistributionrec.unit_meas_lookup_code,
                                                                x_secondary_available_qty
                                                               );

                        -- If qtys have already been allocated for this po_line_location_id during
                        -- a cascade process which has not been written to the db yet, we need to
                        -- decrement it from the total available quantity
                        -- We traverse the actual pl/sql table and accumulate the quantity by matching the
                        -- po_line_location_id

                        IF n > 1 THEN -- We will do this for all rows except the 1st
                            FOR i IN 1 ..(n - 1) LOOP
                                IF x_cascaded_table(i).po_line_location_id = x_shipmentdistributionrec.line_location_id THEN
                                    already_allocated_qty  := already_allocated_qty + x_cascaded_table(i).source_doc_quantity;
                                END IF;
                            END LOOP;
                        END IF;
                    ELSE
                        /* Bug# 1548597*/
                        rcv_quantities_s.get_available_quantity('DIRECT RECEIPT',
                                                                x_shipmentdistributionrec.po_distribution_id,
                                                                'VENDOR',
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                x_converted_trx_qty,
                                                                x_tolerable_qty,
                                                                x_shipmentdistributionrec.unit_meas_lookup_code,
                                                                x_secondary_available_qty
                                                               );

                        /* Bug# 1337787 - Calculated the x_tolerable_qty in
                        rcv_quantities_s.get_available_quantity procedure */

                        -- x_tolerable_qty := x_converted_trx_qty;

                        -- If qtys have already been allocated for this po_distribution_id during
                        -- a cascade process which has not been written to the db yet, we need to
                        -- decrement it from the total available quantity
                        -- We traverse the actual pl/sql table and accumulate the quantity by matching the
                        -- po_distribution_id

                        IF n > 1 THEN -- We will do this for all rows except the 1st
                            FOR i IN 1 ..(n - 1) LOOP
                                IF x_cascaded_table(i).po_distribution_id = x_shipmentdistributionrec.po_distribution_id THEN
                                    already_allocated_qty  := already_allocated_qty + x_cascaded_table(i).source_doc_quantity;
                                END IF;
                            END LOOP;
                        END IF;
                    END IF;

                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('After call to get_available quantity');
                        asn_debug.put_line('Available Quantity ' || TO_CHAR(x_converted_trx_qty));
                        asn_debug.put_line('Tolerable Quantity ' || TO_CHAR(x_tolerable_qty));
                        asn_debug.put_line('Already Shipped Quantity ' || TO_CHAR(NVL(x_shipmentdistributionrec.quantity_shipped, 0)));
                        asn_debug.put_line('Pointer to temp table ' || TO_CHAR(current_n));
                    END IF;

                    -- if qty has already been allocated then reduce available and tolerable
                    -- qty by the allocated amount

                    IF NVL(already_allocated_qty, 0) > 0 THEN
                        x_converted_trx_qty  := x_converted_trx_qty - already_allocated_qty;
                        x_tolerable_qty      := x_tolerable_qty - already_allocated_qty;

                        IF x_converted_trx_qty < 0 THEN
                            x_converted_trx_qty  := 0;
                        END IF;

                        IF x_tolerable_qty < 0 THEN
                            x_tolerable_qty  := 0;
                        END IF;

                        IF (g_asn_debug = 'Y') THEN
                            asn_debug.put_line('Have some allocated quantity. Will reduce qty');
                            asn_debug.put_line('Allocated Qty ' || TO_CHAR(already_allocated_qty));
                            asn_debug.put_line('After reducing by allocated qty');
                            asn_debug.put_line('Available Quantity ' || TO_CHAR(x_converted_trx_qty));
                            asn_debug.put_line('Tolerable Quantity ' || TO_CHAR(x_tolerable_qty));
                            asn_debug.put_line('Already Shipped Quantity ' || TO_CHAR(NVL(x_shipmentdistributionrec.quantity_shipped, 0)));
                            asn_debug.put_line('Pointer to temp table ' || TO_CHAR(current_n));
                        END IF;
                    END IF;

                    -- We can use the first record since the item_id and uom are not going to change
                    -- Check that we can convert between ASN-> PO  uom
                    --                                   PO -> ASN uom
                    --                                   PO -> PRIMARY uom
                    -- If any of the conversions fail then we cannot use that record

                    x_remaining_qty_po_uom  := 0; -- initialize
                    po_asn_uom_qty          := 0; -- initialize
                    po_primary_uom_qty      := 0; -- initialize
                    x_remaining_qty_po_uom  := convert_into_correct_qty(x_remaining_quantity,
                                                                        temp_cascaded_table(1).unit_of_measure,
                                                                        temp_cascaded_table(1).item_id,
                                                                        x_shipmentdistributionrec.unit_meas_lookup_code
                                                                       );
                    -- using arbit qty for PO->ASN, PO->PRIMARY UOM conversion as this is just a check

                    po_asn_uom_qty          := convert_into_correct_qty(1000,
                                                                        x_shipmentdistributionrec.unit_meas_lookup_code,
                                                                        temp_cascaded_table(1).item_id,
                                                                        temp_cascaded_table(1).unit_of_measure
                                                                       );
                    po_primary_uom_qty      := convert_into_correct_qty(1000,
                                                                        x_shipmentdistributionrec.unit_meas_lookup_code,
                                                                        temp_cascaded_table(1).item_id,
                                                                        temp_cascaded_table(1).primary_unit_of_measure
                                                                       );

                    IF    x_remaining_qty_po_uom = 0
                       OR -- no point in going further for this record
                          po_asn_uom_qty = 0
                       OR -- as we cannot convert between the ASN -> PO uoms
                          po_primary_uom_qty = 0 THEN -- PO -> ASN uom, PO -> PRIMARY UOM
                        IF (g_asn_debug = 'Y') THEN
                            asn_debug.put_line('Need an error message in the interface tables');
                            asn_debug.put_line('Cannot interconvert between diff UOMs');
                            asn_debug.put_line('This po_line cannot be used as the uoms ');
                            asn_debug.put_line(temp_cascaded_table(1).unit_of_measure || ' ' || x_shipmentdistributionrec.unit_meas_lookup_code);
                            asn_debug.put_line('cannot be converted for item ' || TO_CHAR(temp_cascaded_table(1).item_id));
                        END IF;
                    ELSE -- we have converted the qty between uoms succesfully
                        IF (g_asn_debug = 'Y') THEN
                            asn_debug.put_line('Current Item Id ' || TO_CHAR(temp_cascaded_table(1).item_id));
                            asn_debug.put_line('Current ASN Quantity ' || TO_CHAR(x_remaining_quantity));
                            asn_debug.put_line('Current ASN UOM ' || temp_cascaded_table(1).unit_of_measure);
                            asn_debug.put_line('Converted PO UOM Quantity ' || TO_CHAR(x_remaining_qty_po_uom));
                            asn_debug.put_line('PO UOM ' || x_shipmentdistributionrec.unit_meas_lookup_code);
                        END IF;

                      -- If last row set available = tolerable - shipped
                      -- else                      = available - shipped
/*
** Debug: We're a bit screwed here.  How do we know if the shipment is taken into account here.  I guess if the transaction
** has the shipment line id then we should take the quantity from the shipped quantity.  Need to walk through the different
** scenarios
*/
                        IF rows_fetched = x_record_count THEN
                            x_converted_trx_qty  := x_tolerable_qty - NVL(x_shipmentdistributionrec.quantity_shipped, 0);

                            IF (g_asn_debug = 'Y') THEN
                                asn_debug.put_line('Last Row : ' || TO_CHAR(x_converted_trx_qty));
                            END IF;
                        ELSE
                            x_converted_trx_qty  := x_converted_trx_qty - NVL(x_shipmentdistributionrec.quantity_shipped, 0);

                            IF (g_asn_debug = 'Y') THEN
                                asn_debug.put_line('Not Last Row : ' || TO_CHAR(x_converted_trx_qty));
                            END IF;
                        END IF;

                        IF x_converted_trx_qty > 0 THEN
                            IF (x_converted_trx_qty < x_remaining_qty_po_uom) THEN -- compare like uoms
                                IF (g_asn_debug = 'Y') THEN
                                    asn_debug.put_line('We are in > Qty branch');
                                END IF;

                                x_remaining_qty_po_uom  := x_remaining_qty_po_uom - x_converted_trx_qty;
                                -- change asn uom qty so both qtys are in sync

                                x_remaining_quantity    := convert_into_correct_qty(x_remaining_qty_po_uom,
                                                                                    x_shipmentdistributionrec.unit_meas_lookup_code,
                                                                                    temp_cascaded_table(1).item_id,
                                                                                    temp_cascaded_table(1).unit_of_measure
                                                                                   );
                                insert_into_table       := TRUE;
                            ELSE
                                IF (g_asn_debug = 'Y') THEN
                                    asn_debug.put_line('We are in <= Qty branch ');
                                END IF;

                                x_converted_trx_qty     := x_remaining_qty_po_uom;
                                insert_into_table       := TRUE;
                                x_remaining_qty_po_uom  := 0;
                                x_remaining_quantity    := 0;
                            END IF;
                        ELSE -- no qty for this record but if last row we need it
                            IF rows_fetched = x_record_count THEN -- last row needs to be inserted anyway
                                                                  -- so that the row can be used based on qty tolerance
                                                                  -- checks
                                IF (g_asn_debug = 'Y') THEN
                                    asn_debug.put_line('Quantity is less then 0 but last record');
                                END IF;

                                insert_into_table    := TRUE;
                                x_converted_trx_qty  := 0;
                            ELSE
                                IF (g_asn_debug = 'Y') THEN
                                    asn_debug.put_line('<= 0 Quantity but more records in cursor');
                                END IF;

                                x_remaining_qty_po_uom  := 0; -- we may have a diff uom on the next iteration

                                IF (g_asn_debug = 'Y') THEN
                                    asn_debug.put_line('We have to deal with remaining_qty > 0 and x_converted_trx_qty -ve');
                                END IF;

                                insert_into_table       := FALSE;
                            END IF;
                        END IF;
                    END IF; -- remaining_qty_po_uom <> 0

                    IF insert_into_table THEN
                        IF (x_first_trans) THEN
                            IF (g_asn_debug = 'Y') THEN
                                asn_debug.put_line('First Time ' || TO_CHAR(current_n));
                            END IF;

                            x_first_trans  := FALSE;

                            IF NVL(temp_cascaded_table(current_n).vendor_cum_shipped_qty, 0) <> 0 THEN
                                IF (g_asn_debug = 'Y') THEN
                                    asn_debug.put_line('The cum qty from vendor is ' || TO_CHAR(temp_cascaded_table(current_n).vendor_cum_shipped_qty));
                                END IF;

                                /* The vendor sends us cum_qty which also includes the current shipment ???.
                                   We need to allocate the correct cum_qty to each row as the cascade happens
                                   The algorithm is as follows

                                      reset cum_qty = cum_qty - total_shipped_qty (x_bkp_qty) in the 1st run
                                      Later reset cum_qty = cum_qty +  primary_qty for each insert.Since we always
                                      copy the previous record this should work pretty well */
                                temp_cascaded_table(current_n).vendor_cum_shipped_qty  :=   temp_cascaded_table(current_n).vendor_cum_shipped_qty
                                                                                          - convert_into_correct_qty(x_bkp_qty,
                                                                                                                     temp_cascaded_table(current_n).unit_of_measure,
                                                                                                                     temp_cascaded_table(current_n).item_id,
                                                                                                                     temp_cascaded_table(current_n).primary_unit_of_measure
                                                                                                                    );

                                IF (g_asn_debug = 'Y') THEN
                                    asn_debug.put_line('Cum qty - current shipment ' || TO_CHAR(temp_cascaded_table(current_n).vendor_cum_shipped_qty));
                                END IF;
                            END IF;
                        ELSE
                            IF (g_asn_debug = 'Y') THEN
                                asn_debug.put_line('Next Time ' || TO_CHAR(current_n));
                            END IF;

                            temp_cascaded_table(current_n)  := temp_cascaded_table(current_n - 1);
                        END IF;

                        /* source_doc_quantity -> in po_uom
                           primary_quantity    -> in primary_uom
                           cum_qty             -> in primary_uom
                           quantity,quantity_shipped -> in ASN uom */
                        temp_cascaded_table(current_n).source_doc_quantity         := x_converted_trx_qty; -- in po uom
                        temp_cascaded_table(current_n).source_doc_unit_of_measure  := x_shipmentdistributionrec.unit_meas_lookup_code;

                        -- bug 1363369 fix carried forward FROM bug# 1337314
                          -- No need to do the following conversion if the cursor returns one row
                          -- for a corresponding record in the interface, as the quantity is already in asn uom.
                          -- If the cursor fetches more than one row then the quantity in the interface will be
                          -- distributed accross the fetched rows and hence need to do the following conversion.
                        IF x_record_count > 1 THEN
                            temp_cascaded_table(current_n).quantity  := convert_into_correct_qty(x_converted_trx_qty,
                                                                                                 x_shipmentdistributionrec.unit_meas_lookup_code,
                                                                                                 temp_cascaded_table(current_n).item_id,
                                                                                                 temp_cascaded_table(current_n).unit_of_measure
                                                                                                ); -- in asn uom
                        END IF;

                        temp_cascaded_table(current_n).quantity_shipped            := temp_cascaded_table(current_n).quantity; -- in asn uom

                                                                                                                               -- Primary qty in Primary UOM
                        temp_cascaded_table(current_n).primary_quantity            := convert_into_correct_qty(x_converted_trx_qty,
                                                                                                               x_shipmentdistributionrec.unit_meas_lookup_code,
                                                                                                               temp_cascaded_table(current_n).item_id,
                                                                                                               temp_cascaded_table(current_n).primary_unit_of_measure
                                                                                                              );

                        -- Assuming vendor_cum_shipped_qty is in PRIMARY UOM

                        IF NVL(temp_cascaded_table(current_n).vendor_cum_shipped_qty, 0) <> 0 THEN
                            temp_cascaded_table(current_n).vendor_cum_shipped_qty  := temp_cascaded_table(current_n).vendor_cum_shipped_qty + temp_cascaded_table(current_n).primary_quantity;
                        END IF;

                        temp_cascaded_table(current_n).inspection_status_code      := 'NOT INSPECTED';
                        temp_cascaded_table(current_n).interface_source_code       := 'RCV';
                        temp_cascaded_table(current_n).currency_code               := x_shipmentdistributionrec.currency_code;
                        temp_cascaded_table(current_n).po_unit_price               := x_shipmentdistributionrec.unit_price;
                        temp_cascaded_table(current_n).tax_amount                  := ROUND(temp_cascaded_table(current_n).quantity * tax_amount_factor, 4);

                        IF (g_asn_debug = 'Y') THEN
                            asn_debug.put_line('Current Tax Amount ' || TO_CHAR(temp_cascaded_table(current_n).tax_amount));
                        END IF;

                        temp_cascaded_table(current_n).category_id                 := x_shipmentdistributionrec.category_id;
                        temp_cascaded_table(current_n).item_description            := x_shipmentdistributionrec.item_description;
                        temp_cascaded_table(current_n).unit_of_measure_class       := x_shipmentdistributionrec.unit_of_measure_class;

                        IF temp_cascaded_table(current_n).to_organization_id IS NULL THEN
                            temp_cascaded_table(current_n).to_organization_id  := x_shipmentdistributionrec.ship_to_organization_id;
                        END IF;

                        temp_cascaded_table(current_n).po_line_id                  := x_shipmentdistributionrec.po_line_id;
                        temp_cascaded_table(current_n).po_line_location_id         := x_shipmentdistributionrec.line_location_id;

                        IF x_shipmentdistributionrec.enforce_ship_to_location_code = 'WARNING' THEN
                            IF (g_asn_debug = 'Y') THEN
                                asn_debug.put_line('Message to warn about different shiptolocations');
                            END IF;
                        END IF;

                        /* Bug 1845702
                         * Currency rate and date can be changed at the time of receipt
                         * depending on the profile ALLOW_RATE_OVERRIDE_FOR_USER_RATE_TYPE.
                         * This was not handled in the open interface. Introduced code
                         * to handle the changes at the time of receipt
                        */
                        fnd_profile.get('ALLOW_RATE_OVERRIDE_FOR_USER_RATE_TYPE', x_allow_rate_override);

                        /* ksareddy - 2329928 Ported changes by bao in branch to cache set_of_books_id */
                        IF (rcv_transactions_interface_sv.x_set_of_books_id IS NULL) THEN
                            SELECT set_of_books_id
                            INTO   rcv_transactions_interface_sv.x_set_of_books_id
                            FROM   financials_system_parameters;
                        END IF;

                        x_sob_id                                                   := rcv_transactions_interface_sv.x_set_of_books_id;

                        /*
                       SELECT set_of_books_id
                           INTO   x_sob_id
                           FROM  financials_system_parameters;
                        */
                        IF (x_shipmentdistributionrec.match_option = 'P') THEN
                            IF (    x_shipmentdistributionrec.rate_type = 'User'
                                AND x_allow_rate_override = 'Y') THEN
                                temp_cascaded_table(current_n).currency_conversion_date  := x_shipmentdistributionrec.rate_date;
                            ELSIF(    x_shipmentdistributionrec.rate_type = 'User'
                                  AND x_allow_rate_override = 'N') THEN
                                temp_cascaded_table(current_n).currency_conversion_date  := x_shipmentdistributionrec.rate_date;
                                temp_cascaded_table(current_n).currency_conversion_rate  := x_shipmentdistributionrec.rate;
                            ELSIF(x_shipmentdistributionrec.rate_type <> 'User') THEN
                                temp_cascaded_table(current_n).currency_conversion_date  := x_shipmentdistributionrec.rate_date;
                                temp_cascaded_table(current_n).currency_conversion_rate  := x_shipmentdistributionrec.rate;
                            END IF;
                        ELSIF(x_shipmentdistributionrec.match_option = 'R') THEN
                            IF (    x_shipmentdistributionrec.rate_type = 'User'
                                AND x_allow_rate_override = 'N') THEN
                                temp_cascaded_table(current_n).currency_conversion_rate  := x_shipmentdistributionrec.rate;
                            ELSIF(x_shipmentdistributionrec.rate_type <> 'User') THEN
                                x_rate                                                   := gl_currency_api.get_rate(x_sob_id,
                                                                                                                     x_shipmentdistributionrec.currency_code,
                                                                                                                     NVL(temp_cascaded_table(current_n).currency_conversion_date, SYSDATE),
                                                                                                                     x_shipmentdistributionrec.rate_type
                                                                                                                    );
                                x_rate                                                   := ROUND(x_rate, 15);
                                temp_cascaded_table(current_n).currency_conversion_rate  := x_rate;
                            END IF;
                        END IF;

                        IF (temp_cascaded_table(current_n).currency_conversion_rate IS NULL) THEN
                            temp_cascaded_table(current_n).currency_conversion_rate  := x_shipmentdistributionrec.rate;
                        END IF;

                        --Bug#2708861.Added the following so that rate_type gets defaulted from po_headers.
                        IF (temp_cascaded_table(current_n).currency_conversion_type IS NULL) THEN
                            temp_cascaded_table(current_n).currency_conversion_type  := x_shipmentdistributionrec.rate_type;
                        END IF;

                        IF (temp_cascaded_table(current_n).currency_conversion_date IS NULL) THEN
                            IF (x_shipmentdistributionrec.rate_type = 'User') THEN
                                temp_cascaded_table(current_n).currency_conversion_date  := x_shipmentdistributionrec.rate_date;
                            ELSE
                                temp_cascaded_table(current_n).currency_conversion_date  := SYSDATE;
                            END IF;
                        END IF;

                        /*
                        ** Copy the distribution specific information only if this is a direct receipt.
                        */
                        IF (   x_cascaded_table(n).transaction_type = 'DELIVER'
                            OR NVL(x_cascaded_table(n).auto_transact_code, 'RECEIVE') = 'DELIVER') THEN
                            temp_cascaded_table(current_n).po_distribution_id          := x_shipmentdistributionrec.po_distribution_id;
                            temp_cascaded_table(current_n).charge_account_id           := x_shipmentdistributionrec.code_combination_id;
                            temp_cascaded_table(current_n).req_distribution_id         := x_shipmentdistributionrec.req_distribution_id;
                            --          temp_cascaded_table(current_n).currency_conversion_date  := x_ShipmentDistributionRec.rate_date;
                             --         temp_cascaded_table(current_n).currency_conversion_rate  := x_ShipmentDistributionRec.rate;
                            temp_cascaded_table(current_n).destination_type_code       := x_shipmentdistributionrec.destination_type_code;
                            temp_cascaded_table(current_n).destination_context         := x_shipmentdistributionrec.destination_type_code;

                            IF (NVL(temp_cascaded_table(current_n).deliver_to_location_id, 0) = 0) THEN
                                temp_cascaded_table(current_n).deliver_to_location_id  := x_shipmentdistributionrec.deliver_to_location_id;
                            END IF;

                            /* Bug 2392074 - If the deliver_to_person mentioned in the po_distributions is
                               invalid or inactive at the time of Receipt we need to clear the deliver to person,
                               as this is an optional field. */
                            IF (NVL(temp_cascaded_table(current_n).deliver_to_person_id, 0) = 0) THEN
                                temp_cascaded_table(current_n).deliver_to_person_id  := x_shipmentdistributionrec.deliver_to_person_id;

                                IF (temp_cascaded_table(current_n).deliver_to_person_id IS NOT NULL) THEN
                                    BEGIN
                                        SELECT NVL(MAX(hre.full_name), 'notfound')
                                        INTO   x_full_name
                                        FROM   hr_employees_current_v hre
                                        WHERE  (   hre.inactive_date IS NULL
                                                OR hre.inactive_date > SYSDATE)
                                        AND    hre.employee_id = temp_cascaded_table(current_n).deliver_to_person_id;

                                        IF (x_full_name = 'notfound') THEN
                                            temp_cascaded_table(current_n).deliver_to_person_id  := NULL;
                                        END IF;
                                    EXCEPTION
                                        WHEN NO_DATA_FOUND THEN
                                            temp_cascaded_table(current_n).deliver_to_person_id  := NULL;

                                            IF (g_asn_debug = 'Y') THEN
                                                asn_debug.put_line('The deliver to person entered in  PO is currently inactive');
                                                asn_debug.put_line(' So it is cleared off');
                                            END IF;
                                        WHEN OTHERS THEN
                                            temp_cascaded_table(current_n).deliver_to_person_id  := NULL;

                                            IF (g_asn_debug = 'Y') THEN
                                                asn_debug.put_line('Some exception has occured');
                                                asn_debug.put_line('This exception is due to the PO deliver to person');
                                                asn_debug.put_line('The deliver to person is optional');
                                                asn_debug.put_line('So cleared off the deliver to person');
                                            END IF;
                                    END;
                                END IF;
                            END IF;

                            IF (temp_cascaded_table(current_n).subinventory IS NULL) THEN
                                temp_cascaded_table(current_n).subinventory  := x_shipmentdistributionrec.destination_subinventory;
                            END IF;

                            temp_cascaded_table(current_n).wip_entity_id               := x_shipmentdistributionrec.wip_entity_id;
                            temp_cascaded_table(current_n).wip_operation_seq_num       := x_shipmentdistributionrec.wip_operation_seq_num;
                            temp_cascaded_table(current_n).wip_resource_seq_num        := x_shipmentdistributionrec.wip_resource_seq_num;
                            temp_cascaded_table(current_n).wip_repetitive_schedule_id  := x_shipmentdistributionrec.wip_repetitive_schedule_id;
                            temp_cascaded_table(current_n).wip_line_id                 := x_shipmentdistributionrec.wip_line_id;
                            temp_cascaded_table(current_n).bom_resource_id             := x_shipmentdistributionrec.bom_resource_id;

                            -- bug 1361786
                            IF (temp_cascaded_table(current_n).ussgl_transaction_code IS NULL) THEN
                                temp_cascaded_table(current_n).ussgl_transaction_code  := x_shipmentdistributionrec.ussgl_transaction_code;
                            END IF;
                        END IF;

                        current_n                                                  := current_n + 1;

                        IF (g_asn_debug = 'Y') THEN
                            asn_debug.put_line('Increment pointer by 1 ' || TO_CHAR(current_n));
                        END IF;
                    END IF;
                END IF;
            END LOOP;
        -- current_n := current_n - 1;   -- point to the last row in the record structure before going back

        ELSE
            -- error_status and error_message are set after validate_quantity_shipped
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('No po_header_id/item_id ');
            END IF;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Status = ' || x_cascaded_table(n).error_status);
            END IF;

            IF x_cascaded_table(n).error_status IN('S', 'W', 'F') THEN
                x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;

                IF (x_cascaded_table(n).error_message IS NULL) THEN
                    rcv_error_pkg.set_error_message('RCV_ASN_NO_PO_LINE_LOCATION_ID', x_cascaded_table(n).error_message);
                    rcv_error_pkg.set_token('DOCUMENT_NUM', x_cascaded_table(n).document_num);
                END IF;

                rcv_error_pkg.log_interface_error('DOCUMENT_NUM', FALSE);
            END IF;

            RETURN;
        END IF; -- of (asn quantity_shipped was valid)

        IF shipments%ISOPEN THEN
            CLOSE shipments;
        END IF;

        IF count_shipments%ISOPEN THEN
            CLOSE count_shipments;
        END IF;

        IF distributions%ISOPEN THEN
            CLOSE distributions;
        END IF;

        IF count_distributions%ISOPEN THEN
            CLOSE count_distributions;
        END IF;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Exit derive_shipment_line');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            IF shipments%ISOPEN THEN
                CLOSE shipments;
            END IF;

            IF count_shipments%ISOPEN THEN
                CLOSE count_shipments;
            END IF;

            IF distributions%ISOPEN THEN
                CLOSE distributions;
            END IF;

            IF count_distributions%ISOPEN THEN
                CLOSE count_distributions;
            END IF;

            x_cascaded_table(n).error_status  := 'F';

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line(TO_CHAR(n));
                asn_debug.put_line(SQLERRM);
                asn_debug.put_line('error ' || x_progress);
            END IF;
    END derive_shipment_line;

/*===========================================================================

  PROCEDURE NAME: default_shipment_line()

===========================================================================*/
    PROCEDURE default_shipment_line(
        x_cascaded_table IN OUT NOCOPY rcv_shipment_object_sv.cascaded_trans_tab_type,
        n                IN            BINARY_INTEGER,
        x_header_id      IN            rcv_headers_interface.header_interface_id%TYPE,
        x_header_record  IN            rcv_shipment_header_sv.headerrectype
    ) IS
        x_progress             VARCHAR2(3);
        x_locator_control      NUMBER;
        x_default_subinventory VARCHAR2(10);
        x_default_locator_id   NUMBER;
        x_success              BOOLEAN;
        x_tax_name             VARCHAR2(50); -- Bug 6331613
        x_vendor_site_id       NUMBER;
        x_vendor_site_code     VARCHAR2(20);

/* bug2382337
 * Change the name of the parameters passed into the cursor
 */
        CURSOR shipments(
            v_header_id        NUMBER,
            v_line_id          NUMBER,
            v_line_location_id NUMBER
        ) IS
            SELECT ph.revision_num,
                   pl.line_num,
                   pl.item_description,
                   pll.tax_code_id,
                   pll.po_release_id,
                   pll.ship_to_location_id,
                   pll.ship_to_organization_id,
                   pll.shipment_num,
                   pll.receiving_routing_id,
                   pll.country_of_origin_code
            FROM   po_line_locations pll,
                   po_lines pl,
                   po_headers ph
            WHERE  ph.po_header_id = pl.po_header_id
            AND    pl.po_line_id = pll.po_line_id
            AND    ph.po_header_id = v_header_id
            AND    pl.po_line_id = v_line_id
            AND    pll.line_location_id = v_line_location_id
            AND    NVL(pll.approved_flag, 'N') = 'Y'
            AND    NVL(pll.cancel_flag, 'N') = 'N'
            AND    NVL(pll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
            AND    pll.shipment_type IN('STANDARD', 'BLANKET', 'SCHEDULED');

        default_po_info        shipments%ROWTYPE;
    BEGIN
        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Enter default_shipment_line');
        END IF;

        x_progress                                     := '000';
        -- set default_shipment_line values

        x_cascaded_table(n).header_interface_id        := x_header_id;
        x_cascaded_table(n).shipment_line_status_code  := 'OPEN';

        IF x_cascaded_table(n).receipt_source_code IS NULL THEN
            x_cascaded_table(n).receipt_source_code  := NVL(x_header_record.header_record.receipt_source_code, 'VENDOR');

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Defaulting from HEADER RECEIPT_SOURCE_CODE ' || x_cascaded_table(n).receipt_source_code);
            END IF;
        END IF;

        IF x_cascaded_table(n).source_document_code IS NULL THEN
            x_cascaded_table(n).source_document_code  := 'PO';

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Defaulting SOURCE_DOCUMENT_CODE ' || x_cascaded_table(n).source_document_code);
            END IF;
        END IF;

        /*  Fix for bug 2564646.
           If AUTO_TRANSACT_CODE is RECEIVE then it means it is a receive
           transaction and destination_type_code should be RECEIVING. Even
           if the end user populates destination_type_code as INVENTORY
           when AUTO_TRANSACT_CODE is RECEIVE, we now overwrite the value
           of DESTINATION_TYPE_CODE to RECEIVING by adding the OR condition
           to the following IF statement.
        */
        IF    x_cascaded_table(n).destination_type_code IS NULL
           OR (    x_cascaded_table(n).destination_type_code = 'INVENTORY'
               AND x_cascaded_table(n).auto_transact_code = 'RECEIVE') THEN
            x_cascaded_table(n).destination_type_code  := 'RECEIVING';

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Defaulting DESTINATION_TYPE_CODE ' || x_cascaded_table(n).destination_type_code);
            END IF;
        END IF;

        IF x_cascaded_table(n).transaction_type IS NULL THEN
            x_cascaded_table(n).transaction_type  := 'SHIP';

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Defaulting TRANSACTION_TYPE ' || x_cascaded_table(n).transaction_type);
            END IF;
        END IF;

        IF x_cascaded_table(n).processing_mode_code IS NULL THEN
            x_cascaded_table(n).processing_mode_code  := 'BATCH';

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Defaulting PROCESSING_MODE_CODE ' || x_cascaded_table(n).processing_mode_code);
            END IF;
        END IF;

        x_cascaded_table(n).processing_status_code     := 'RUNNING';

        IF x_cascaded_table(n).processing_status_code IS NULL THEN
            -- This has to be set to running otherwise C code in rvtbm
                 -- will not pick it up
            x_cascaded_table(n).processing_status_code  := 'RUNNING';

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Defaulting PROCESSING_STATUS_CODE ' || x_cascaded_table(n).processing_status_code);
            END IF;
        END IF;

        IF x_cascaded_table(n).transaction_status_code IS NULL THEN
            x_cascaded_table(n).transaction_status_code  := 'PENDING';

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Defaulting TRANSACTION_STATUS_CODE ' || x_cascaded_table(n).transaction_status_code);
            END IF;
        END IF;

        -- Default auto_transact_code if it is null

        IF x_cascaded_table(n).auto_transact_code IS NULL THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Setting auto_transact_code to transaction_type ' || x_cascaded_table(n).transaction_type);
            END IF;

            x_cascaded_table(n).auto_transact_code  := x_cascaded_table(n).transaction_type;
        END IF;

        -- default only if all attributes are null

        IF     x_cascaded_table(n).vendor_id IS NULL
           AND x_cascaded_table(n).vendor_name IS NULL
           AND x_cascaded_table(n).vendor_num IS NULL THEN
            x_cascaded_table(n).vendor_id    := x_header_record.header_record.vendor_id;
            x_cascaded_table(n).vendor_name  := x_header_record.header_record.vendor_name;
            x_cascaded_table(n).vendor_num   := x_header_record.header_record.vendor_num;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Defaulting from HEADER VENDOR_ID ' || TO_CHAR(x_cascaded_table(n).vendor_id));
                asn_debug.put_line('Defaulting from HEADER VENDOR_NAME ' || x_cascaded_table(n).vendor_name);
                asn_debug.put_line('Defaulting from HEADER VENDOR_NUM ' || x_cascaded_table(n).vendor_num);
            END IF;
        END IF;

        -- default only if all attributes are null

        IF     x_cascaded_table(n).vendor_site_id IS NULL
           AND x_cascaded_table(n).vendor_site_code IS NULL THEN
            x_cascaded_table(n).vendor_site_id    := x_header_record.header_record.vendor_site_id;
            x_cascaded_table(n).vendor_site_code  := x_header_record.header_record.vendor_site_code;

            /* Fix for bug 2296720.
               If both vendor_site_id and vendor_site_code are not populated
               in interface tables, and if there are multiple vendor sites
               associated to a particular vendor then we default them from PO
               using the po_header_id of rcv_transactions_interface for each
               line.
            */
            IF     x_cascaded_table(n).vendor_site_id IS NULL
               AND x_cascaded_table(n).vendor_site_code IS NULL THEN
                SELECT vendor_site_id
                INTO   x_vendor_site_id
                FROM   po_headers
                WHERE  po_header_id = x_cascaded_table(n).po_header_id
                AND    vendor_id = x_cascaded_table(n).vendor_id;

                SELECT vendor_site_code
                INTO   x_vendor_site_code
                FROM   po_vendor_sites
                WHERE  vendor_site_id = x_vendor_site_id
                AND    vendor_id = x_cascaded_table(n).vendor_id;

                x_cascaded_table(n).vendor_site_id    := x_vendor_site_id;
                x_cascaded_table(n).vendor_site_code  := x_vendor_site_code;
            END IF;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Defaulting from HEADER VENDOR_SITE_ID ' || TO_CHAR(x_cascaded_table(n).vendor_site_id));
                asn_debug.put_line('Defaulting from HEADER VENDOR_SITE_CODE ' || x_cascaded_table(n).vendor_site_code);
            END IF;
        END IF;

        -- default only if all attributes are null

        IF     x_cascaded_table(n).from_organization_id IS NULL
           AND x_cascaded_table(n).from_organization_code IS NULL THEN
            x_cascaded_table(n).from_organization_id    := x_header_record.header_record.from_organization_id;
            x_cascaded_table(n).from_organization_code  := x_header_record.header_record.from_organization_code;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Defaulting from HEADER FROM_ORGANIZATION_ID ' || TO_CHAR(x_cascaded_table(n).from_organization_id));
                asn_debug.put_line('Defaulting from HEADER FROM_ORGANIZATION_CODE ' || x_cascaded_table(n).from_organization_code);
            END IF;
        END IF;

        -- default only if all attributes are null

        IF     x_cascaded_table(n).to_organization_id IS NULL
           AND x_cascaded_table(n).to_organization_code IS NULL THEN
            x_cascaded_table(n).to_organization_id    := x_header_record.header_record.ship_to_organization_id;
            x_cascaded_table(n).to_organization_code  := x_header_record.header_record.ship_to_organization_code;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Defaulting from HEADER TO_ORGANIZATION_ID ' || TO_CHAR(x_cascaded_table(n).to_organization_id));
                asn_debug.put_line('Defaulting from HEADER TO_ORGANIZATION_CODE ' || x_cascaded_table(n).to_organization_code);
            END IF;
        END IF;

        -- default only if all attributes are null

        IF     x_cascaded_table(n).currency_code IS NULL
           AND x_cascaded_table(n).currency_conversion_type IS NULL
           AND x_cascaded_table(n).currency_conversion_rate IS NULL
           AND x_cascaded_table(n).currency_conversion_date IS NULL THEN
            x_cascaded_table(n).currency_code             := x_header_record.header_record.currency_code;
            x_cascaded_table(n).currency_conversion_type  := x_header_record.header_record.conversion_rate_type;
            x_cascaded_table(n).currency_conversion_rate  := x_header_record.header_record.conversion_rate;
            x_cascaded_table(n).currency_conversion_date  := x_header_record.header_record.conversion_rate_date;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Defaulting from HEADER CURRENCY_CODE ' || x_cascaded_table(n).currency_code);
                asn_debug.put_line('Defaulting from HEADER CURRENCY_CONVERSION_TYPE ' || x_cascaded_table(n).currency_conversion_type);
                asn_debug.put_line('Defaulting from HEADER CURRENCY_CONVERSION_RATE ' || TO_CHAR(x_cascaded_table(n).currency_conversion_rate));
                asn_debug.put_line('Defaulting from HEADER CURRENCY_CONVERSION_DATE ' || TO_CHAR(x_cascaded_table(n).currency_conversion_date, 'DD/MM/YYYY'));
            END IF;
        END IF;

        IF (    x_cascaded_table(n).ship_to_location_id IS NULL
            AND x_cascaded_table(n).ship_to_location_code IS NULL) THEN -- Check this with George
            x_cascaded_table(n).ship_to_location_code  := x_header_record.header_record.location_code;
            x_cascaded_table(n).ship_to_location_id    := x_header_record.header_record.location_id;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Defaulting from HEADER LOCATION_ID ' || TO_CHAR(x_cascaded_table(n).location_id));
            END IF;
        END IF;

        IF x_cascaded_table(n).shipment_num IS NULL THEN
            x_cascaded_table(n).shipment_num  := x_header_record.header_record.shipment_num;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Defaulting from HEADER SHIPMENT_NUM ' || x_cascaded_table(n).shipment_num);
            END IF;
        END IF;

        IF x_cascaded_table(n).freight_carrier_code IS NULL THEN
            x_cascaded_table(n).freight_carrier_code  := x_header_record.header_record.freight_carrier_code;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Defaulting from HEADER FREIGHT_CARRIER_CODE ' || x_cascaded_table(n).freight_carrier_code);
            END IF;
        END IF;

        IF x_cascaded_table(n).bill_of_lading IS NULL THEN
            x_cascaded_table(n).bill_of_lading  := x_header_record.header_record.bill_of_lading;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Defaulting from HEADER BILL_OF_LADING ' || x_cascaded_table(n).bill_of_lading);
            END IF;
        END IF;

        IF x_cascaded_table(n).packing_slip IS NULL THEN
            x_cascaded_table(n).packing_slip  := x_header_record.header_record.packing_slip;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Defaulting from HEADER PACKING_SLIP ' || x_cascaded_table(n).packing_slip);
            END IF;
        END IF;

        IF x_cascaded_table(n).shipped_date IS NULL THEN
            x_cascaded_table(n).shipped_date  := x_header_record.header_record.shipped_date;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Defaulting from HEADER SHIPPED_DATE ' || TO_CHAR(x_cascaded_table(n).shipped_date, 'DD/MM/YYYY'));
            END IF;
        END IF;

        IF x_cascaded_table(n).expected_receipt_date IS NULL THEN
            x_cascaded_table(n).expected_receipt_date  := x_header_record.header_record.expected_receipt_date;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Defaulting from HEADER EXPECTED_RECEIPT_DATE ' || TO_CHAR(x_cascaded_table(n).expected_receipt_date, 'DD/MM/YYYY'));
            END IF;
        END IF;

        IF x_cascaded_table(n).num_of_containers IS NULL THEN
            x_cascaded_table(n).num_of_containers  := x_header_record.header_record.num_of_containers;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Defaulting from HEADER NUM_OF_CONTAINERS ' || TO_CHAR(x_cascaded_table(n).num_of_containers));
            END IF;
        END IF;

        IF x_cascaded_table(n).waybill_airbill_num IS NULL THEN
            x_cascaded_table(n).waybill_airbill_num  := x_header_record.header_record.waybill_airbill_num;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Defaulting from HEADER WAYBILL_AIRBILL_NUM ' || x_cascaded_table(n).waybill_airbill_num);
            END IF;
        END IF;

        IF x_cascaded_table(n).tax_name IS NULL THEN
            x_cascaded_table(n).tax_name  := x_header_record.header_record.tax_name;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Defaulting from HEADER TAX_NAME ' || x_cascaded_table(n).tax_name);
            END IF;
        END IF;

        IF x_cascaded_table(n).item_revision IS NULL THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Enter defaulting item revision');
            END IF;

            item_id_record.item_id                     := x_cascaded_table(n).item_id;
            item_id_record.po_line_id                  := x_cascaded_table(n).po_line_id;
            item_id_record.po_line_location_id         := x_cascaded_table(n).po_line_location_id;
            item_id_record.to_organization_id          := x_cascaded_table(n).to_organization_id;
            item_id_record.item_revision               := x_cascaded_table(n).item_revision;
            item_id_record.error_record.error_status   := 'S';
            item_id_record.error_record.error_message  := NULL;
            default_item_revision(item_id_record);
            x_cascaded_table(n).item_revision          := item_id_record.item_revision;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line(NVL(item_id_record.item_revision, 'Item Revision is null'));
            END IF;

            x_cascaded_table(n).error_status           := item_id_record.error_record.error_status;
            rcv_error_pkg.set_error_message(item_id_record.error_record.error_message, x_cascaded_table(n).error_message);
        END IF;

        IF    x_cascaded_table(n).po_revision_num IS NULL
           OR x_cascaded_table(n).freight_carrier_code IS NULL
           OR x_cascaded_table(n).document_line_num IS NULL
           OR x_cascaded_table(n).item_description IS NULL
           OR x_cascaded_table(n).tax_name IS NULL
           OR
--FRKHAN 12/18/98 add country of origin check
              x_cascaded_table(n).country_of_origin_code IS NULL
           OR x_cascaded_table(n).po_release_id IS NULL
           OR (    x_cascaded_table(n).ship_to_location_id IS NULL
               AND x_cascaded_table(n).ship_to_location_code IS NULL)
           OR (    x_cascaded_table(n).to_organization_id IS NULL
               AND x_cascaded_table(n).to_organization_code IS NULL)
           OR x_cascaded_table(n).document_shipment_line_num IS NULL
           OR (    x_cascaded_table(n).routing_header_id IS NULL
               AND x_cascaded_table(n).routing_code IS NULL) THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Defaulting values from PO ');
            END IF;

            OPEN shipments(x_cascaded_table(n).po_header_id,
                           x_cascaded_table(n).po_line_id,
                           x_cascaded_table(n).po_line_location_id
                          );
            FETCH shipments INTO default_po_info;

            IF shipments%FOUND THEN
                IF x_cascaded_table(n).po_revision_num IS NULL THEN
                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('Defaulting PO HEADER revision num ' || default_po_info.revision_num);
                    END IF;

                    x_cascaded_table(n).po_revision_num  := default_po_info.revision_num;
                END IF;

                IF x_cascaded_table(n).document_line_num IS NULL THEN
                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('Defaulting po line num ' || TO_CHAR(default_po_info.line_num));
                    END IF;

                    x_cascaded_table(n).document_line_num  := default_po_info.line_num;
                END IF;

                IF x_cascaded_table(n).item_description IS NULL THEN
                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('Defaulting item description from PO ' || default_po_info.item_description);
                    END IF;

                    x_cascaded_table(n).item_description  := default_po_info.item_description;
                END IF;

                IF     x_cascaded_table(n).tax_name IS NULL
                   AND default_po_info.tax_code_id IS NOT NULL THEN
                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('Defaulting tax name based on PO ' || TO_CHAR(default_po_info.tax_code_id));
                    END IF;

                    -- Need to join to ap_tax_codes to get tax_name

                    BEGIN
                        SELECT NAME
                        INTO   x_tax_name
                        FROM   ap_tax_codes
                        WHERE  ap_tax_codes.tax_id = default_po_info.tax_code_id;

                        x_cascaded_table(n).tax_name  := x_tax_name;
                    EXCEPTION
                        WHEN OTHERS THEN
                            IF (g_asn_debug = 'Y') THEN
                                asn_debug.put_line('Some error occured in the tax name derivation');
                            END IF;
                    END;
                END IF;

--FRKHAN 12/18/98 default country of origin from PO
                IF x_cascaded_table(n).country_of_origin_code IS NULL THEN
                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('Defaulting country of origin from PO ' || default_po_info.country_of_origin_code);
                    END IF;

                    x_cascaded_table(n).country_of_origin_code  := default_po_info.country_of_origin_code;
                END IF;

                IF x_cascaded_table(n).po_release_id IS NULL THEN
                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('Defaulting PO Release ID from PO ' || TO_CHAR(default_po_info.po_release_id));
                    END IF;

                    x_cascaded_table(n).po_release_id  := default_po_info.po_release_id;
                END IF;

                IF x_cascaded_table(n).ship_to_location_id IS NULL THEN
                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('Defaulting PO ship_to_location_id ' || TO_CHAR(default_po_info.ship_to_location_id));
                    END IF;

                    x_cascaded_table(n).ship_to_location_id  := default_po_info.ship_to_location_id;
                END IF;

                IF x_cascaded_table(n).to_organization_id IS NULL THEN
                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('Defaulting PO to_organization_id ' || TO_CHAR(default_po_info.ship_to_organization_id));
                    END IF;

                    x_cascaded_table(n).to_organization_id  := default_po_info.ship_to_organization_id;
                END IF;

                IF x_cascaded_table(n).document_shipment_line_num IS NULL THEN
                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('Defaulting PO shipment_line_num ' || TO_CHAR(default_po_info.shipment_num));
                    END IF;

                    x_cascaded_table(n).document_shipment_line_num  := default_po_info.shipment_num;
                END IF;

                IF x_cascaded_table(n).routing_header_id IS NULL THEN
                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('Defaulting PO routing_header_id ' || TO_CHAR(default_po_info.receiving_routing_id));
                    END IF;

                    x_cascaded_table(n).routing_header_id  := default_po_info.receiving_routing_id;
                END IF;
            END IF;
        END IF;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Primary UOM = ' || x_cascaded_table(n).primary_unit_of_measure);
        END IF;

        /*
        ** Default the subinventory and locator if they have not been set either through the interface
        ** or defaulted from the purchase order
        */
        IF (    x_cascaded_table(n).destination_type_code = 'INVENTORY'
            AND (   NVL(x_cascaded_table(n).auto_transact_code, 'RECEIVE') = 'DELIVER'
                 OR x_cascaded_table(n).transaction_type = 'DELIVER')) THEN
            /*
            ** A subinventory must have been defined on the po or a default
            ** must be available for the item.  If it's not already defined
            ** then go get it out of inventory.  If you're using express
            ** then it's ok to get the default rather than having it be
            ** defined on the record
            */
            IF (x_cascaded_table(n).subinventory IS NULL) THEN
                /*
                ** If you're using express then it's ok to get the default
                ** rather than having it be defined on the record
                */
                x_progress  := '120';
                po_subinventories_s.get_default_subinventory(x_cascaded_table(n).to_organization_id,
                                                             x_cascaded_table(n).item_id,
                                                             x_cascaded_table(n).subinventory
                                                            );

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Defaulting subinventory from item: Sub = ' || x_cascaded_table(n).subinventory);
                END IF;
            END IF; -- (X_cascaded_table(n).subinventory IS NULL)

            /*
            ** See if org/sub/item is under locator control.  If the sub is
            ** not available then don't do this call since it won't matter
            ** because the row will fail without a sub
            */
            IF (x_cascaded_table(n).subinventory IS NOT NULL) THEN
                x_progress  := '122';
                po_subinventories_s.get_locator_control(x_cascaded_table(n).to_organization_id,
                                                        x_cascaded_table(n).subinventory,
                                                        x_cascaded_table(n).item_id,
                                                        x_locator_control
                                                       );

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Locator Control = ' || TO_CHAR(x_locator_control));
                END IF;

                /*
                ** If locator control is 2 which means it is under predefined
                ** locator contol or 3 which means it's under dynamic (any value)
                ** locator control then you need to go get the default locator id
                */
                IF (    (   x_locator_control = 2
                         OR x_locator_control = 3)
                    AND x_cascaded_table(n).locator_id IS NULL) THEN
                    x_progress  := '123';
                    po_subinventories_s.get_default_locator(x_cascaded_table(n).to_organization_id,
                                                            x_cascaded_table(n).item_id,
                                                            x_cascaded_table(n).subinventory,
                                                            x_cascaded_table(n).locator_id
                                                           );

                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('Defaulting locator from Sub: Locator_id  = ' || TO_CHAR(x_cascaded_table(n).locator_id));
                    END IF;
                END IF;
            END IF;

            x_default_subinventory  := x_cascaded_table(n).subinventory;
            x_default_locator_id    := x_cascaded_table(n).locator_id;
            /*
            ** Call the put away function
            */
            x_success               := rcv_sub_locator_sv.put_away_api(x_cascaded_table(n).po_line_location_id,
                                                                       x_cascaded_table(n).po_distribution_id,
                                                                       x_cascaded_table(n).shipment_line_id,
                                                                       x_cascaded_table(n).receipt_source_code,
                                                                       x_cascaded_table(n).from_organization_id,
                                                                       x_cascaded_table(n).to_organization_id,
                                                                       x_cascaded_table(n).item_id,
                                                                       x_cascaded_table(n).item_revision,
                                                                       x_cascaded_table(n).vendor_id,
                                                                       x_cascaded_table(n).ship_to_location_id,
                                                                       x_cascaded_table(n).deliver_to_location_id,
                                                                       x_cascaded_table(n).deliver_to_person_id,
                                                                       x_cascaded_table(n).quantity,
                                                                       x_cascaded_table(n).primary_quantity,
                                                                       x_cascaded_table(n).primary_unit_of_measure,
                                                                       x_cascaded_table(n).quantity,
                                                                       x_cascaded_table(n).unit_of_measure,
                                                                       x_cascaded_table(n).routing_header_id,
                                                                       x_default_subinventory,
                                                                       x_default_locator_id,
                                                                       x_cascaded_table(n).subinventory,
                                                                       x_cascaded_table(n).locator_id
                                                                      );
        END IF; -- (X_cascaded_table(n).destination_type_code = 'INVENTORY' AND...)

        /*
        ** Make sure to set the location_id properly
        */
        IF (   NVL(x_cascaded_table(n).auto_transact_code, 'RECEIVE') = 'DELIVER'
            OR x_cascaded_table(n).transaction_type = 'DELIVER') THEN
            x_cascaded_table(n).location_id  := x_cascaded_table(n).deliver_to_location_id;
        ELSE
            x_cascaded_table(n).location_id  := x_cascaded_table(n).ship_to_location_id;
        END IF;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Set Location_id  = ' || TO_CHAR(x_cascaded_table(n).location_id));
        END IF;

        IF x_cascaded_table(n).waybill_airbill_num IS NULL THEN
            x_cascaded_table(n).waybill_airbill_num  := x_header_record.header_record.waybill_airbill_num;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Defaulting from HEADER WAYBILL_AIRBILL_NUM ' || x_cascaded_table(n).waybill_airbill_num);
            END IF;
        END IF;

        -- if not a one-time purchase item
        -- This may not be needed as we would have encoutered problems during cascade
        -- if primary_unit_of_measure was absent ???

        -- if (x_cascaded_table(n).item_id is not null) then

         -- null;
        --     select min(primary_unit_of_measure)
        --     into   x_cascaded_table(n).primary_unit_of_measure
        --     from   mtl_system_items
        --     where  inventory_item_id = x_cascaded_table(n).item_id and
        --            organization_id   = x_cascaded_table(n).to_organization_id;
         -- else

        -- if it's a one-time item, use the base uom for the class

        -- begin

        -- SELECT  min(unit_of_measure)
        -- INTO    x_cascaded_table(n).primary_unit_of_measure
        -- FROM    mtl_units_of_measure mum
        -- WHERE   uom_class      = x_cascaded_table(n).unit_of_measure_class
        -- AND     mum.base_uom_flag = 'Y';

        -- exception

        -- when no_data_found then null;

        -- end;


        -- end if;

        x_progress                                     := '010';

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Exit default_shipment_line');
        END IF;
    END default_shipment_line;

/*===========================================================================

  PROCEDURE NAME: validate_shipment_line()

===========================================================================*/
    PROCEDURE validate_shipment_line(
        x_cascaded_table IN OUT NOCOPY rcv_shipment_object_sv.cascaded_trans_tab_type,
        n                IN            BINARY_INTEGER,
        x_asn_type       IN            rcv_headers_interface.asn_type%TYPE,
        x_header_record  IN            rcv_shipment_header_sv.headerrectype
    ) IS
        x_progress                  VARCHAR2(3) := NULL;
        x_sob_id                    NUMBER      := NULL;
        x_val_open_ok               BOOLEAN     := NULL;
/* Added the following variable for bug 3009663 */
        x_allow_substitute_receipts VARCHAR2(1) := 'N';
    BEGIN
        IF (x_cascaded_table(n).error_status NOT IN('S', 'W')) THEN
            RETURN;
        END IF;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Enter validate_shipment_line');
        END IF;

        x_progress                                        := '000';

        /*Bug 2327318 Implemented the validation Transaction date should not be greater than
          sysdate */
        IF (x_cascaded_table(n).transaction_date > SYSDATE) THEN
            rcv_error_pkg.set_error_message('RCV_TRX_FUTURE_DATE_NA', x_cascaded_table(n).error_message);
            rcv_error_pkg.log_interface_error('TRANSACTION_DATE');
        END IF;

        -- bug 642624 validate if PO and GL periods are open in pre-processor


/* Bug 2653229 - To check if the transaction date falls in the open period only
  when the auto transact code is not SHIP. */
        IF (x_cascaded_table(n).auto_transact_code <> 'SHIP') THEN
            -- need this block to handle the exception when no period is defined for the txn date

/*
          BEGIN
               SELECT set_of_books_id
               INTO   x_sob_id
               FROM  financials_system_parameters;

               x_val_open_ok := PO_DATES_S.val_open_period(x_cascaded_table(n).transaction_date,x_sob_id,'PO',
                    x_cascaded_table(n).to_organization_id) AND
                                PO_DATES_S.val_open_period(x_cascaded_table(n).transaction_date,x_sob_id,'SQLGL',
                    x_cascaded_table(n).to_organization_id);
          EXCEPTION
             WHEN OTHERS THEN
               x_val_open_ok := FALSE;

          END;
*/
          /* Bug# 2379848 - We were only checking for GL and PO periods
             and not for INV periods. Also we were displaying the same
             error message always */
            BEGIN
                SELECT set_of_books_id
                INTO   x_sob_id
                FROM   financials_system_parameters;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    NULL;

                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('Set of books id not defined');
                    END IF;
            END;

            BEGIN
                x_val_open_ok  := po_dates_s.val_open_period(x_cascaded_table(n).transaction_date,
                                                             x_sob_id,
                                                             'SQLGL',
                                                             x_cascaded_table(n).to_organization_id
                                                            );
            EXCEPTION
                WHEN OTHERS THEN
                    x_val_open_ok  := FALSE;
            END;

            IF NOT(x_val_open_ok) THEN
                rcv_error_pkg.set_error_message('PO_CNL_NO_PERIOD', x_cascaded_table(n).error_message);
                rcv_error_pkg.log_interface_error('TRANSACTION_DATE');
            END IF;

            BEGIN
                x_val_open_ok  := po_dates_s.val_open_period(x_cascaded_table(n).transaction_date,
                                                             x_sob_id,
                                                             'INV',
                                                             x_cascaded_table(n).to_organization_id
                                                            );
            EXCEPTION
                WHEN OTHERS THEN
                    x_val_open_ok  := FALSE;
            END;

            IF NOT(x_val_open_ok) THEN
                rcv_error_pkg.set_error_message('PO_INV_NO_OPEN_PERIOD', x_cascaded_table(n).error_message);
                rcv_error_pkg.log_interface_error('TRANSACTION_DATE');
            END IF;

            BEGIN
                x_val_open_ok  := po_dates_s.val_open_period(x_cascaded_table(n).transaction_date,
                                                             x_sob_id,
                                                             'PO',
                                                             x_cascaded_table(n).to_organization_id
                                                            );
            EXCEPTION
                WHEN OTHERS THEN
                    x_val_open_ok  := FALSE;
            END;

            IF NOT(x_val_open_ok) THEN
                rcv_error_pkg.set_error_message('PO_PO_ENTER_OPEN_GL_DATE', x_cascaded_table(n).error_message);
                rcv_error_pkg.log_interface_error('TRANSACTION_DATE');
            END IF;   /* End of Bug# 2379848 */
        END IF; -- auto transact code = SHIP

        IF (x_asn_type = 'ASBN') THEN
            quantity_invoiced_record.quantity_invoiced           := x_cascaded_table(n).quantity_invoiced;
            quantity_invoiced_record.error_record.error_status   := 'S';
            quantity_invoiced_record.error_record.error_message  := NULL;
            rcv_transactions_interface_sv1.validate_quantity_invoiced(quantity_invoiced_record);
            x_cascaded_table(n).error_status                     := quantity_invoiced_record.error_record.error_status;
            rcv_error_pkg.set_error_message(quantity_invoiced_record.error_record.error_message, x_cascaded_table(n).error_message);
            rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status, 'QUANTITY_INVOICED');
        END IF;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Before call to validate UOM');
            asn_debug.put_line('Quantity ' || TO_CHAR(x_cascaded_table(n).quantity));
        END IF;

        uom_record.quantity_shipped                       := x_cascaded_table(n).quantity;
        uom_record.unit_of_measure                        := x_cascaded_table(n).unit_of_measure;
        uom_record.item_id                                := x_cascaded_table(n).item_id;
        uom_record.po_line_id                             := x_cascaded_table(n).po_line_id;
        uom_record.to_organization_id                     := x_cascaded_table(n).to_organization_id;
        uom_record.po_header_id                           := x_cascaded_table(n).po_header_id;
        uom_record.primary_unit_of_measure                := x_cascaded_table(n).primary_unit_of_measure;
        uom_record.error_record.error_status              := 'S';
        uom_record.error_record.error_message             := NULL;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Validating UOM');
        END IF;

        rcv_transactions_interface_sv1.validate_uom(uom_record);
        x_cascaded_table(n).error_status                  := uom_record.error_record.error_status;
        rcv_error_pkg.set_error_message(uom_record.error_record.error_message, x_cascaded_table(n).error_message);
        rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status, 'UNIT_OF_MEASURE');
        item_id_record.item_id                            := x_cascaded_table(n).item_id;
        item_id_record.po_line_id                         := x_cascaded_table(n).po_line_id;
        item_id_record.to_organization_id                 := x_cascaded_table(n).to_organization_id;
        item_id_record.item_description                   := x_cascaded_table(n).item_description;
        item_id_record.item_num                           := x_cascaded_table(n).item_num;
        item_id_record.vendor_item_num                    := NULL; -- x_cascaded_table(n).vendor_item_num;
        /* bug 608353 */
        item_id_record.use_mtl_lot                        := x_cascaded_table(n).use_mtl_lot;
        item_id_record.use_mtl_serial                     := x_cascaded_table(n).use_mtl_serial;
        item_id_record.error_record.error_status          := 'S';
        item_id_record.error_record.error_message         := NULL;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Validating Item');
            asn_debug.put_line(TO_CHAR(x_cascaded_table(n).item_id));
        END IF;

        /*
        ** If this is a one time item shipment and you've matched up based on a
             ** document line num then skip the processing based on setting the validation
        ** for the item to be the same as what is set on the line.
             */
        IF (    x_cascaded_table(n).item_id IS NULL
            AND x_cascaded_table(n).po_line_id IS NOT NULL) THEN
            item_id_record.error_record.error_status   := x_cascaded_table(n).error_status;
            item_id_record.error_record.error_message  := x_cascaded_table(n).error_message;
        ELSE
            rcv_transactions_interface_sv1.validate_item(item_id_record, x_cascaded_table(n).auto_transact_code); -- bug 608353
        END IF;

        x_cascaded_table(n).error_status                  := item_id_record.error_record.error_status;
        rcv_error_pkg.set_error_message(item_id_record.error_record.error_message, x_cascaded_table(n).error_message);
        rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status, 'ITEM_NUM');
        item_id_record.item_description                   := x_cascaded_table(n).item_description;
        item_id_record.error_record.error_status          := 'S';
        item_id_record.error_record.error_message         := NULL;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Validating Item Description ' || x_cascaded_table(n).item_description);
        END IF;

        rcv_transactions_interface_sv1.validate_item_description(item_id_record);
        x_cascaded_table(n).error_status                  := item_id_record.error_record.error_status;
        rcv_error_pkg.set_error_message(item_id_record.error_record.error_message, x_cascaded_table(n).error_message);

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Error status after validate item description ' || x_cascaded_table(n).error_status);
        END IF;

        rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status, 'ITEM_DESCRIPTION');

        IF (x_cascaded_table(n).substitute_item_id IS NOT NULL) THEN
            sub_item_id_record.substitute_item_num         := x_cascaded_table(n).substitute_item_num;
            sub_item_id_record.substitute_item_id          := x_cascaded_table(n).substitute_item_id;
            sub_item_id_record.po_line_id                  := x_cascaded_table(n).po_line_id;
            sub_item_id_record.to_organization_id          := x_cascaded_table(n).to_organization_id;
            sub_item_id_record.vendor_id                   := x_cascaded_table(n).vendor_id;
            sub_item_id_record.error_record.error_status   := 'S';
            sub_item_id_record.error_record.error_message  := NULL;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Validating Substitute Item');
            END IF;

            /* Added the check on po shipments allow_substitute_receipt flag - Bug 3009663. */
            BEGIN
                SELECT NVL(pll.allow_substitute_receipts_flag, 'N')
                INTO   x_allow_substitute_receipts
                FROM   po_line_locations pll
                WHERE  pll.line_location_id = x_cascaded_table(n).po_line_location_id;
            EXCEPTION
                WHEN OTHERS THEN
                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('Hit an exception');
                        asn_debug.put_line(SQLERRM);
                        asn_debug.put_line(' While validating substitute item');
                    END IF;

                    rcv_error_pkg.set_sql_error_message('validate_shipment_line', x_progress);
                    x_cascaded_table(n).error_message  := rcv_error_pkg.get_last_message;
                    rcv_error_pkg.log_interface_error('PO_LINE_LOCATION_ID');
            END;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Allow substitute receipts flag in PO shipments ' || x_allow_substitute_receipts);
            END IF;

            IF (x_allow_substitute_receipts = 'Y') THEN
                rcv_transactions_interface_sv1.validate_substitute_item(sub_item_id_record);
                x_cascaded_table(n).error_status  := sub_item_id_record.error_record.error_status;
                rcv_error_pkg.set_error_message(sub_item_id_record.error_record.error_message, x_cascaded_table(n).error_message);
            ELSE
                x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
                rcv_error_pkg.set_error_message('RCV_ITEM_SUB_NOT_ALLOWED', x_cascaded_table(n).error_message);
                rcv_error_pkg.set_token('ITEM', x_cascaded_table(n).substitute_item_num);
            END IF;

            rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status, 'SUBSTITUTE_ITEM_NUM');
        END IF;

        IF (x_cascaded_table(n).item_revision IS NOT NULL) THEN
            item_revision_record.item_revision               := x_cascaded_table(n).item_revision;
            item_revision_record.po_line_id                  := x_cascaded_table(n).po_line_id;
            item_revision_record.to_organization_id          := x_cascaded_table(n).to_organization_id;
            item_revision_record.item_id                     := x_cascaded_table(n).item_id;
            item_revision_record.error_record.error_status   := 'S';
            item_revision_record.error_record.error_message  := NULL;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Validating Item Revision');
            END IF;

            rcv_transactions_interface_sv1.validate_item_revision(item_revision_record);
            x_cascaded_table(n).error_status                 := item_revision_record.error_record.error_status;
            rcv_error_pkg.set_error_message(item_revision_record.error_record.error_message, x_cascaded_table(n).error_message);
            x_cascaded_table(n).item_revision                := item_revision_record.item_revision;
            rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status, 'ITEM_REVISION');
        END IF;

        IF (x_cascaded_table(n).freight_carrier_code IS NOT NULL) THEN
            freight_carrier_record.to_organization_id          := x_cascaded_table(n).to_organization_id;
            freight_carrier_record.freight_carrier_code        := x_cascaded_table(n).freight_carrier_code;
            freight_carrier_record.po_header_id                := x_cascaded_table(n).po_header_id;
            freight_carrier_record.error_record.error_status   := 'S';
            freight_carrier_record.error_record.error_message  := NULL;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Validating Freight Carrier');
            END IF;

            rcv_transactions_interface_sv1.validate_freight_carrier(freight_carrier_record);
            x_cascaded_table(n).error_status                   := freight_carrier_record.error_record.error_status;
            rcv_error_pkg.set_error_message(freight_carrier_record.error_record.error_message, x_cascaded_table(n).error_message);
            rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status, 'FREIGHT_CARRIER_CODE');
        END IF;

        /*
        ** Validate Destination Type.  This value is always required
        */
        po_lookup_code_record.lookup_code                 := x_cascaded_table(n).destination_type_code;
        po_lookup_code_record.lookup_type                 := 'RCV DESTINATION TYPE';
        po_lookup_code_record.error_record.error_status   := 'S';
        po_lookup_code_record.error_record.error_message  := NULL;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Validating Destination Type Code');
        END IF;

        rcv_transactions_interface_sv1.validate_po_lookup_code(po_lookup_code_record);
        x_cascaded_table(n).error_status                  := po_lookup_code_record.error_record.error_status;
        rcv_error_pkg.set_error_message(po_lookup_code_record.error_record.error_message, x_cascaded_table(n).error_message);
        rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status, 'DESTINATION_TYPE_CODE');
        /*
        ** Validate ship_to_location.  This value is always required
        */
        location_record.location_id                       := x_cascaded_table(n).ship_to_location_id;
        location_record.to_organization_id                := x_cascaded_table(n).to_organization_id;
        location_record.destination_type_code             := x_cascaded_table(n).destination_type_code;
        location_record.location_type_code                := 'SHIP_TO';
        location_record.transaction_date                  := x_cascaded_table(n).transaction_date;
        location_record.error_record.error_status         := 'S';
        location_record.error_record.error_message        := NULL;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Validating Ship To Location');
        END IF;

        rcv_transactions_interface_sv1.validate_location(location_record);
        x_cascaded_table(n).error_status                  := location_record.error_record.error_status;
        rcv_error_pkg.set_error_message(location_record.error_record.error_message, x_cascaded_table(n).error_message);
        rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status, 'SHIP_TO_LOCATION_ID');
        /*
        ** Validate deliver to person.  This value is always optional
        */
        employee_record.employee_id                       := x_cascaded_table(n).deliver_to_person_id;
        employee_record.to_organization_id                := x_cascaded_table(n).to_organization_id;
        employee_record.destination_type_code             := x_cascaded_table(n).destination_type_code;
        employee_record.transaction_date                  := x_cascaded_table(n).transaction_date;
        employee_record.error_record.error_status         := 'S';
        employee_record.error_record.error_message        := NULL;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Validating Deliver to Person');
        END IF;

        rcv_transactions_interface_sv1.validate_employee(employee_record);
        x_cascaded_table(n).error_status                  := employee_record.error_record.error_status;
        rcv_error_pkg.set_error_message(employee_record.error_record.error_message, x_cascaded_table(n).error_message);
        rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status, 'DELIVER_TO_PERSON_ID');

        /*
        ** Validate deliver to person.  This value is always optional
        */
        /* removing validation of deliver to person 2 - the code is exactly the same resulting
        ** in double error messages - whatever validation this was meant to be
        ** it is currently incorrect
        */

        /*
        ** Validate routing record  bug 639750
        */
        IF (   x_cascaded_table(n).transaction_type = 'DELIVER'
            OR NVL(x_cascaded_table(n).auto_transact_code, 'RECEIVE') = 'DELIVER') THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Validating routing_header_id');
            END IF;

            /* 1 is Standard Receipt, 2 is Inspection Required */
            IF (    (x_cascaded_table(n).routing_header_id) IN(1, 2)
                AND NVL(rcv_setup_s.get_override_routing, 'N') = 'N') THEN
                x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
                rcv_error_pkg.set_error_message('RCV_ASN_DELIVER_ROUTING_FAILED', x_cascaded_table(n).error_message);
                rcv_error_pkg.log_interface_error('ROUTING_HEADER_ID');
            END IF;
        END IF;

        /*
        ** Validate deliver_to_location.  If this is an expense or shop floor
        ** destination then the value is required
        */
        IF (   x_cascaded_table(n).transaction_type = 'DELIVER'
            OR NVL(x_cascaded_table(n).auto_transact_code, 'RECEIVE') = 'DELIVER') THEN
            location_record.location_id                 := x_cascaded_table(n).deliver_to_location_id;
            location_record.to_organization_id          := x_cascaded_table(n).to_organization_id;
            location_record.destination_type_code       := x_cascaded_table(n).destination_type_code;
            location_record.location_type_code          := 'DELIVER_TO';
            location_record.transaction_date            := x_cascaded_table(n).transaction_date;
            location_record.error_record.error_status   := 'S';
            location_record.error_record.error_message  := NULL;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Validating Deliver To Location');
            END IF;

            rcv_transactions_interface_sv1.validate_location(location_record);
            x_cascaded_table(n).error_status            := location_record.error_record.error_status;
            rcv_error_pkg.set_error_message(location_record.error_record.error_message, x_cascaded_table(n).error_message);
            rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status, 'DELIVER_TO_LOCATION_ID');
        END IF;

        /*
        ** Validate subinventory if inventory destination or if not inventory
        ** destintion make sure to null out the subinventory
        */
        IF (   x_cascaded_table(n).transaction_type = 'DELIVER'
            OR NVL(x_cascaded_table(n).auto_transact_code, 'RECEIVE') = 'DELIVER') THEN
            IF (x_cascaded_table(n).destination_type_code = 'INVENTORY') THEN
                subinventory_record.subinventory                := x_cascaded_table(n).subinventory;
                subinventory_record.to_organization_id          := x_cascaded_table(n).to_organization_id;
                subinventory_record.destination_type_code       := x_cascaded_table(n).destination_type_code;
                subinventory_record.item_id                     := x_cascaded_table(n).item_id;
                subinventory_record.transaction_date            := x_cascaded_table(n).transaction_date;
                subinventory_record.error_record.error_status   := 'S';
                subinventory_record.error_record.error_message  := NULL;

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Validating Subinventory');
                END IF;

                rcv_transactions_interface_sv1.validate_subinventory(subinventory_record);
                x_cascaded_table(n).error_status                := subinventory_record.error_record.error_status;
                rcv_error_pkg.set_error_message(subinventory_record.error_record.error_message, x_cascaded_table(n).error_message);
                rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status, 'SUBINVENTORY');
            ELSE
                x_cascaded_table(n).subinventory  := NULL;
            END IF;
        END IF;

        /*
        ** Validate locator if inventory destination or if not inventory
        ** destintion make sure to null out the locator_id
        */
        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Trx Type = ' || x_cascaded_table(n).transaction_type || 'Auto Trx Code = ' || x_cascaded_table(n).auto_transact_code);
        END IF;

        IF (   x_cascaded_table(n).transaction_type = 'DELIVER'
            OR NVL(x_cascaded_table(n).auto_transact_code, 'RECEIVE') = 'DELIVER') THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Valid Loc - Destination Type Code = ' || x_cascaded_table(n).destination_type_code);
            END IF;

            IF (x_cascaded_table(n).destination_type_code = 'INVENTORY') THEN
                locator_record.locator_id                  := x_cascaded_table(n).locator_id;
                locator_record.subinventory                := x_cascaded_table(n).subinventory;
                locator_record.to_organization_id          := x_cascaded_table(n).to_organization_id;
                locator_record.destination_type_code       := x_cascaded_table(n).destination_type_code;
                locator_record.item_id                     := x_cascaded_table(n).item_id;
                locator_record.transaction_date            := x_cascaded_table(n).transaction_date;

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Locator = ' || TO_CHAR(locator_record.locator_id));
                    asn_debug.put_line('Subinventory = ' || locator_record.subinventory);
                    asn_debug.put_line('To Org = ' || locator_record.to_organization_id);
                    asn_debug.put_line('Dest Type = ' || locator_record.destination_type_code);
                    asn_debug.put_line('Item Id = ' || locator_record.item_id);
                END IF;

                locator_record.error_record.error_status   := 'S';
                locator_record.error_record.error_message  := NULL;

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Validating Locator');
                END IF;

                rcv_transactions_interface_sv1.validate_locator(locator_record);
                x_cascaded_table(n).error_status           := locator_record.error_record.error_status;
                rcv_error_pkg.set_error_message(locator_record.error_record.error_message, x_cascaded_table(n).error_message);

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Loc Error Status  = ' || locator_record.error_record.error_status);
                    asn_debug.put_line('Loc Error Msg  = ' || locator_record.error_record.error_message);
                END IF;

                rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status, 'LOCATOR');
            ELSE
                x_cascaded_table(n).locator_id  := NULL;
                x_cascaded_table(n).LOCATOR     := NULL;
            END IF;
        END IF;

        IF (x_cascaded_table(n).tax_name IS NOT NULL) THEN
            IF (x_asn_type = 'ASBN') THEN
                tax_name_record.tax_name                    := x_cascaded_table(n).tax_name;
                tax_name_record.error_record.error_status   := 'S';
                tax_name_record.error_record.error_message  := NULL;

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Validating Tax Code');
                END IF;

                rcv_transactions_interface_sv1.validate_tax_code(tax_name_record);
                x_cascaded_table(n).error_status            := tax_name_record.error_record.error_status;
                rcv_error_pkg.set_error_message(tax_name_record.error_record.error_message, x_cascaded_table(n).error_message);
                rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status, 'TAX_NAME');
            END IF;
        END IF;

--FRKHAN 12/18/98 validate country of origin code
        IF (x_cascaded_table(n).country_of_origin_code IS NOT NULL) THEN
            country_of_origin_record.country_of_origin_code      := x_cascaded_table(n).country_of_origin_code;
            country_of_origin_record.error_record.error_status   := 'S';
            country_of_origin_record.error_record.error_message  := NULL;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Validating Country of Origin Code');
            END IF;

            rcv_transactions_interface_sv1.validate_country_of_origin(country_of_origin_record);
            x_cascaded_table(n).error_status                     := country_of_origin_record.error_record.error_status;
            rcv_error_pkg.set_error_message(country_of_origin_record.error_record.error_message, x_cascaded_table(n).error_message);
            rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status, 'COUNTRY_OF_ORIGIN_CODE');
        END IF;

        asl_record.po_header_id                           := x_cascaded_table(n).po_header_id;
        asl_record.vendor_id                              := x_cascaded_table(n).vendor_id;
        asl_record.vendor_site_id                         := x_cascaded_table(n).vendor_site_id;
        asl_record.item_id                                := x_cascaded_table(n).item_id;
        asl_record.to_organization_id                     := x_cascaded_table(n).to_organization_id;
        asl_record.error_record.error_status              := 'S';
        asl_record.error_record.error_message             := NULL;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Validating ASL');
        END IF;

        rcv_transactions_interface_sv1.validate_asl(asl_record);
        x_cascaded_table(n).error_status                  := asl_record.error_record.error_status;
        rcv_error_pkg.set_error_message(asl_record.error_record.error_message, x_cascaded_table(n).error_message);
        rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status, 'SUPPLY_AGREEMENT_FLAG');

        IF NVL(x_cascaded_table(n).vendor_cum_shipped_qty, 0) <> 0 THEN
            cum_quantity_record.to_organization_id          := x_cascaded_table(n).to_organization_id;
            cum_quantity_record.po_header_id                := x_cascaded_table(n).po_header_id;
            cum_quantity_record.vendor_cum_shipped_qty      := x_cascaded_table(n).vendor_cum_shipped_qty;
            cum_quantity_record.item_id                     := x_cascaded_table(n).item_id;
            cum_quantity_record.vendor_id                   := x_cascaded_table(n).vendor_id;
            cum_quantity_record.vendor_site_id              := x_cascaded_table(n).vendor_site_id;
            cum_quantity_record.primary_unit_of_measure     := x_cascaded_table(n).primary_unit_of_measure;
            cum_quantity_record.quantity_shipped            := x_cascaded_table(n).quantity;
            cum_quantity_record.unit_of_measure             := x_cascaded_table(n).unit_of_measure;
            cum_quantity_record.transaction_date            := x_cascaded_table(n).transaction_date;
            cum_quantity_record.error_record.error_status   := 'S';
            cum_quantity_record.error_record.error_message  := NULL;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Validating Cum Qty Shipped');
            END IF;

            rcv_transactions_interface_sv1.validate_cum_quantity_shipped(cum_quantity_record);
            x_cascaded_table(n).error_status                := cum_quantity_record.error_record.error_status;
            rcv_error_pkg.set_error_message(cum_quantity_record.error_record.error_message, x_cascaded_table(n).error_message);

/* WDK - hack, errors are downgraded to warning */
            IF (x_cascaded_table(n).error_status = rcv_error_pkg.g_ret_sts_error) THEN
                x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_warning;
            END IF;

            rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status, 'VENDOR_CUM_SHIPPED_QTY');
        END IF; -- vendor_cum_shipped_qty <> 0

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Validating ref integrity');
        END IF;

        ref_integrity_record.to_organization_id           := x_cascaded_table(n).to_organization_id;
        ref_integrity_record.po_line_location_id          := x_cascaded_table(n).po_line_location_id;
        ref_integrity_record.po_header_id                 := x_cascaded_table(n).po_header_id;
        ref_integrity_record.po_line_id                   := x_cascaded_table(n).po_line_id;
        ref_integrity_record.vendor_id                    := x_cascaded_table(n).vendor_id;
        ref_integrity_record.vendor_site_id               := x_cascaded_table(n).vendor_site_id;
        ref_integrity_record.vendor_item_num              := x_cascaded_table(n).vendor_item_num;
        ref_integrity_record.po_revision_num              := x_cascaded_table(n).po_revision_num;
        ref_integrity_record.error_record.error_status    := 'S';
        ref_integrity_record.error_record.error_message   := NULL;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Validating Ref Integ');
        END IF;

        rcv_transactions_interface_sv1.validate_ref_integ(ref_integrity_record, x_header_record);
        x_cascaded_table(n).error_status                  := ref_integrity_record.error_record.error_status;
        rcv_error_pkg.set_error_message(ref_integrity_record.error_record.error_message, x_cascaded_table(n).error_message);
        rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status, 'DOCUMENT_NUM');

        -- If substitute item has been specified then we need to switch the item_id with the
        -- substitute item. Also make sure that we can receive the substitute item in the
        -- ASN UOM. Convert the primary_quantity in item.primary uom to the substitute_item.primary_uom
        -- If this fails then the transaction is in error


        IF x_cascaded_table(n).substitute_item_id IS NOT NULL THEN
            exchange_sub_item(x_cascaded_table, n);
            rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status, 'SUBSTITUTE_ITEM_ID');

            IF x_cascaded_table(n).error_status NOT IN('S', 'W') THEN
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Some problems in exchange');
                END IF;
            END IF;
        END IF;

        /* <Consigned Inventory Pre-Processor FPI START> */

        /* Reject ASBN transaction if it's a shipment against Consigned PO */
        IF     (x_asn_type = 'ASBN')
           AND (x_cascaded_table(n).po_line_location_id IS NOT NULL) THEN
            l_consigned_po_rec.po_line_location_id         := x_cascaded_table(n).po_line_location_id;
            l_consigned_po_rec.error_record.error_status   := 'S';
            l_consigned_po_rec.error_record.error_message  := NULL;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Validating ASBN for Consigned PO');
            END IF;

            rcv_transactions_interface_sv1.validate_consigned_po(l_consigned_po_rec);

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('After Validating ASBN for Consigned PO');
            END IF;

            x_cascaded_table(n).error_status               := l_consigned_po_rec.error_record.error_status;
            rcv_error_pkg.set_error_message(l_consigned_po_rec.error_record.error_message, x_cascaded_table(n).error_message);

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Error status  ' || l_consigned_po_rec.error_record.error_status);
                asn_debug.put_line('Error name:  ' || l_consigned_po_rec.error_record.error_message);
            END IF;

            rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status, 'PO_LINE_LOCATION_ID');
        END IF; -- IF (x_cascaded_table(n).error_status in ('S','W')) AND (X_asn_type = 'ASBN')

        /*
        ** Reject ASN, ASBN or Receipt transactions against Consumption PO
        */
        IF     (x_cascaded_table(n).po_header_id IS NOT NULL)
           AND (x_cascaded_table(n).po_release_id IS NULL) THEN
            l_consumption_po_rec.po_header_id                := x_cascaded_table(n).po_header_id;
            l_consumption_po_rec.error_record.error_status   := 'S';
            l_consumption_po_rec.error_record.error_message  := NULL;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Validating Consumption PO');
            END IF;

            rcv_transactions_interface_sv1.validate_consumption_po(l_consumption_po_rec);

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('After Validating Consumption PO');
            END IF;

            x_cascaded_table(n).error_status                 := l_consumption_po_rec.error_record.error_status;
            rcv_error_pkg.set_error_message(l_consumption_po_rec.error_record.error_message, x_cascaded_table(n).error_message);

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Error status  ' || l_consumption_po_rec.error_record.error_status);
                asn_debug.put_line('Error name:  ' || l_consumption_po_rec.error_record.error_message);
            END IF;

            rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status, 'PO_HEADER_ID');
        END IF; -- IF (x_cascaded_table(n).error_status in ('S','W'))

        /*
        ** Reject ASN, ASBN or Receipt transactions against Consumption Release
        */
        IF (x_cascaded_table(n).po_release_id IS NOT NULL) THEN
            l_consumption_release_rec.po_release_id               := x_cascaded_table(n).po_release_id;
            l_consumption_release_rec.error_record.error_status   := 'S';
            l_consumption_release_rec.error_record.error_message  := NULL;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Validating Consumption Release');
            END IF;

            rcv_transactions_interface_sv1.validate_consumption_release(l_consumption_release_rec);

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('After Validating Consumption Release');
            END IF;

            x_cascaded_table(n).error_status                      := l_consumption_release_rec.error_record.error_status;
            rcv_error_pkg.set_error_message(l_consumption_release_rec.error_record.error_message, x_cascaded_table(n).error_message);

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Error status  ' || l_consumption_release_rec.error_record.error_status);
                asn_debug.put_line('Error name:  ' || l_consumption_release_rec.error_record.error_message);
            END IF;

            rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status, 'PO_RELEASE_ID');
        END IF; -- IF (x_cascaded_table(n).error_status in ('S','W'))
    /* <Consigned Inventory Pre-Processor FPI END> */
    EXCEPTION
        WHEN rcv_error_pkg.e_fatal_error THEN
            x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
        WHEN OTHERS THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('I have hit an exception');
                asn_debug.put_line(SQLERRM);
                asn_debug.put_line('Exit validate_shipment_line');
            END IF;

            x_cascaded_table(n).error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
            rcv_error_pkg.set_sql_error_message('validate_shipment_line', x_progress);
            x_cascaded_table(n).error_message  := rcv_error_pkg.get_last_message;
            rcv_error_pkg.log_interface_error('TRANSACTIONS_INTERFACE_ID');
    END validate_shipment_line;

/*===========================================================================

  PROCEDURE NAME: get_location_id()

===========================================================================*/
    PROCEDURE get_location_id(
        x_location_id_record IN OUT NOCOPY rcv_shipment_object_sv.location_id_record_type
    ) IS
    BEGIN
        SELECT MAX(location_id)
        INTO   x_location_id_record.location_id
        FROM   hr_locations
        WHERE  location_code = x_location_id_record.location_code;

        IF (x_location_id_record.location_id IS NULL) THEN
            x_location_id_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
            rcv_error_pkg.set_error_message('RCV_ASN_LOCATION_ID', x_location_id_record.error_record.error_message);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            x_location_id_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
            rcv_error_pkg.set_sql_error_message('get_location_id', '000');
            x_location_id_record.error_record.error_message  := rcv_error_pkg.get_last_message;
    END get_location_id;

/*===========================================================================

  PROCEDURE NAME: get_locator_id()

===========================================================================*/
    PROCEDURE get_locator_id(
        x_locator_id_record IN OUT NOCOPY rcv_shipment_line_sv.locator_id_record_type
    ) IS
    BEGIN
        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('inside get_locator_id');
        END IF;

        /* Bug 3017707 - As locators with the same name can exist in two different organizations, added a filter on organization_id  */
        SELECT NVL(MAX(ml.inventory_location_id), -999)
        INTO   x_locator_id_record.locator_id
        FROM   mtl_item_locations_kfv ml
        WHERE  ml.concatenated_segments = x_locator_id_record.LOCATOR
        AND    (   ml.disable_date > SYSDATE
                OR ml.disable_date IS NULL)
        AND    NVL(ml.subinventory_code, 'z') = NVL(x_locator_id_record.subinventory, 'z')
        AND    x_locator_id_record.to_organization_id = ml.organization_id;

        IF (x_locator_id_record.locator_id IS NULL) THEN
            x_locator_id_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
            rcv_error_pkg.set_error_message('RCV_ALL_INVALID_LOCATOR', x_locator_id_record.error_record.error_message);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            x_locator_id_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
            rcv_error_pkg.set_sql_error_message('get_locator_id', '000');
            x_locator_id_record.error_record.error_message  := rcv_error_pkg.get_last_message;
    END get_locator_id;

/*===========================================================================

  PROCEDURE NAME: get_routing_header_id()

===========================================================================*/
    PROCEDURE get_routing_header_id(
        x_routing_header_id_record IN OUT NOCOPY rcv_shipment_line_sv.routing_header_id_rec_type
    ) IS
    BEGIN
        SELECT MAX(routing_header_id)
        INTO   x_routing_header_id_record.routing_header_id
        FROM   rcv_routing_headers
        WHERE  routing_name = x_routing_header_id_record.routing_code;

        IF (x_routing_header_id_record.routing_header_id IS NULL) THEN
            x_routing_header_id_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
            rcv_error_pkg.set_error_message('RCV_ASN_ROUTING_HEADER_ID', x_routing_header_id_record.error_record.error_message);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            x_routing_header_id_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
            rcv_error_pkg.set_sql_error_message('get_routing_header_id', '000');
            x_routing_header_id_record.error_record.error_message  := rcv_error_pkg.get_last_message;
    END get_routing_header_id;

/*===========================================================================

  PROCEDURE NAME: get_routing_step_id()

===========================================================================*/
    PROCEDURE get_routing_step_id(
        x_routing_step_id_record IN OUT NOCOPY rcv_shipment_line_sv.routing_step_id_rec_type
    ) IS
    BEGIN
        SELECT MAX(routing_step_id)
        INTO   x_routing_step_id_record.routing_step_id
        FROM   rcv_routing_steps
        WHERE  step_name = x_routing_step_id_record.routing_step;

        IF (x_routing_step_id_record.routing_step_id IS NULL) THEN
            x_routing_step_id_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
            rcv_error_pkg.set_error_message('RCV_ASN_ROUTING_STEP_ID', x_routing_step_id_record.error_record.error_message);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            x_routing_step_id_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
            rcv_error_pkg.set_sql_error_message('get_routing_step_id', '000');
            x_routing_step_id_record.error_record.error_message  := rcv_error_pkg.get_last_message;
    END get_routing_step_id;

/*===========================================================================

  PROCEDURE NAME: get_reason_id()

===========================================================================*/
    PROCEDURE get_reason_id(
        x_reason_id_record IN OUT NOCOPY rcv_shipment_line_sv.reason_id_record_type
    ) IS
    BEGIN
        SELECT MAX(reason_id)
        INTO   x_reason_id_record.reason_id
        FROM   mtl_transaction_reasons
        WHERE  reason_name = x_reason_id_record.reason_name;

        IF (x_reason_id_record.reason_id IS NULL) THEN
            x_reason_id_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
            rcv_error_pkg.set_error_message('RCV_ASN_REASON_ID', x_reason_id_record.error_record.error_message);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            x_reason_id_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
            rcv_error_pkg.set_sql_error_message('get_reason_id', '000');
            x_reason_id_record.error_record.error_message  := rcv_error_pkg.get_last_message;
    END get_reason_id;

/*==========================================================================

  PROCEDURE NAME:       default_item_revision()

============================================================================*/
    PROCEDURE default_item_revision(
        x_item_revision_record IN OUT NOCOPY rcv_shipment_line_sv.item_id_record_type
    ) IS
        x_revision_control_flag VARCHAR2(1);
        x_number_of_inv_dest    NUMBER;
        x_item_rev_exists       BOOLEAN;
    BEGIN
        /* Check whether item is under revision control */
        SELECT DECODE(msi.revision_qty_control_code,
                      1, 'N',
                      2, 'Y',
                      'N'
                     )
        INTO   x_revision_control_flag
        FROM   mtl_system_items msi
        WHERE  inventory_item_id = x_item_revision_record.item_id
        AND    organization_id = x_item_revision_record.to_organization_id;

        /* If item is under revision control

                 if revision is null then try to pick up item_revision from po_lines

                 if revision is still null and
                    there are any destination_type=INVENTORY then

                        try to pick up latest revision from mtl_item_revisions

                 end if
           else
              item should not have any revisions which we will validate in the validation phase */
        IF x_revision_control_flag = 'Y' THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Item is under revision control');
            END IF;

            IF x_item_revision_record.item_revision IS NULL THEN -- pick up revision from source document
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Picking up from source document');
                END IF;

                SELECT item_revision
                INTO   x_item_revision_record.item_revision
                FROM   po_lines
                WHERE  po_lines.po_line_id = x_item_revision_record.po_line_id;
            END IF;

            IF x_item_revision_record.item_revision IS NULL THEN -- see whether any destination_type = 'INVENTORY'
                SELECT COUNT(*)
                INTO   x_number_of_inv_dest
                FROM   po_distributions pd
                WHERE  pd.line_location_id = x_item_revision_record.po_line_location_id
                AND    pd.destination_type_code = 'INVENTORY';
            END IF;

            IF     x_item_revision_record.item_revision IS NULL
               AND x_number_of_inv_dest > 0 THEN -- still null and destination_type = INVENTORY
                                                 -- default latest implementation
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Picking up latest implementation since source doc is null');
                END IF;

                po_items_sv2.get_latest_item_rev(x_item_revision_record.item_id,
                                                 x_item_revision_record.to_organization_id,
                                                 x_item_revision_record.item_revision,
                                                 x_item_rev_exists
                                                );
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('In procedure default item_revision');
            END IF;
    END default_item_revision;

/*===========================================================================

  PROCEDURE NAME: check_date_tolerance()

===========================================================================*/
    PROCEDURE check_date_tolerance(
        expected_receipt_date       IN            DATE,
        promised_date               IN            DATE,
        days_early_receipt_allowed  IN            NUMBER,
        days_late_receipt_allowed   IN            NUMBER,
        receipt_days_exception_code IN OUT NOCOPY VARCHAR2
    ) IS
        x_sysdate       DATE := SYSDATE;
        high_range_date DATE;
        low_range_date  DATE;
    BEGIN
        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Check date tolerance');
        END IF;

        IF (expected_receipt_date IS NOT NULL) THEN
            IF (promised_date IS NOT NULL) THEN
                low_range_date   := promised_date - NVL(days_early_receipt_allowed, 0);
                high_range_date  := promised_date + NVL(days_late_receipt_allowed, 0);
            ELSE
                low_range_date   := x_sysdate - NVL(days_early_receipt_allowed, 0);
                high_range_date  := x_sysdate + NVL(days_late_receipt_allowed, 0);
            END IF;

            IF (    expected_receipt_date >= low_range_date
                AND expected_receipt_date <= high_range_date) THEN
                receipt_days_exception_code  := 'NONE';
            ELSE
                IF receipt_days_exception_code = 'REJECT' THEN
                    receipt_days_exception_code  := 'REJECT';
                ELSIF receipt_days_exception_code = 'WARNING' THEN
                    receipt_days_exception_code  := 'NONE';
                END IF;
            END IF;
        ELSE
            receipt_days_exception_code  := 'NONE';
        END IF;

        IF receipt_days_exception_code IS NULL THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('In null days exception code');
            END IF;

            receipt_days_exception_code  := 'NONE';
        END IF;
    END check_date_tolerance;

    FUNCTION convert_into_correct_qty(
        source_qty IN NUMBER,
        source_uom IN VARCHAR2,
        item_id    IN NUMBER,
        dest_uom   IN VARCHAR2
    )
        RETURN NUMBER IS
        correct_qty NUMBER;
    BEGIN
        IF source_uom <> dest_uom THEN

            /*
            ** Bug 4898703 -
            ** Reverted the fix made in Bug 4145660. Modified code in
            ** RCVPRETB.pls to handle the rounding issues rather than
            ** modifying this procedure which gets called from too many
            ** other places.
            */
            po_uom_s.uom_convert(source_qty,
                                 source_uom,
                                 item_id,
                                 dest_uom,
                                 correct_qty
                                );
        ELSE
            correct_qty  := source_qty;
        END IF;

        RETURN(correct_qty);
    EXCEPTION
        WHEN OTHERS THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Could not convert between UOMs');
                asn_debug.put_line('Will return 0');
            END IF;

            correct_qty  := 0;
            RETURN(correct_qty);
    END;

    PROCEDURE check_shipto_enforcement(
        po_ship_to_location_id        IN            NUMBER,
        asn_ship_to_location_id       IN            NUMBER,
        enforce_ship_to_location_code IN OUT NOCOPY VARCHAR2
    ) IS
    BEGIN
        IF enforce_ship_to_location_code <> 'NONE' THEN
            IF enforce_ship_to_location_code = 'REJECT' THEN
                IF NVL(asn_ship_to_location_id, po_ship_to_location_id) = po_ship_to_location_id THEN
                    enforce_ship_to_location_code  := 'NONE';
                ELSE
                    enforce_ship_to_location_code  := 'REJECT';
                END IF;
            END IF;

            IF enforce_ship_to_location_code = 'WARNING' THEN
                IF NVL(asn_ship_to_location_id, po_ship_to_location_id) = po_ship_to_location_id THEN
                    enforce_ship_to_location_code  := 'NONE';
                ELSE
                    enforce_ship_to_location_code  := 'WARNING';
                END IF;
            END IF;
        END IF;
    END check_shipto_enforcement;

    PROCEDURE exchange_sub_item(
        v_cascaded_table IN OUT NOCOPY rcv_shipment_object_sv.cascaded_trans_tab_type,
        n                IN            BINARY_INTEGER
    ) IS
        x_item_id      NUMBER;
        x_primary_uom  mtl_system_items.primary_unit_of_measure%TYPE   := NULL;
        x_uom_class    VARCHAR2(10);
        x_uom_count    NUMBER(10);
        prim_uom_qty   NUMBER;
        x_error_status VARCHAR2(1);
    BEGIN
        x_error_status                          := rcv_error_pkg.g_ret_sts_error;

        SELECT COUNT(*)
        INTO   x_uom_count
        FROM   mtl_item_uoms_view
        WHERE  organization_id = v_cascaded_table(n).to_organization_id
        AND    inventory_item_id(+) = v_cascaded_table(n).substitute_item_id
        AND    unit_of_measure = v_cascaded_table(n).unit_of_measure;

        IF x_uom_count = 0 THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('The substitute item cannot be received in ASN uom' || v_cascaded_table(n).unit_of_measure);
            END IF;

            rcv_error_pkg.set_error_message('RCV_ITEM_SUB_NOT_ALLOWED');
            RAISE e_validation_error;
        END IF;

        SELECT MAX(primary_unit_of_measure)
        INTO   x_primary_uom
        FROM   mtl_system_items
        WHERE  mtl_system_items.inventory_item_id = v_cascaded_table(n).item_id
        AND    mtl_system_items.organization_id = v_cascaded_table(n).to_organization_id;

        IF x_primary_uom IS NULL THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('No Primary UOM for substitute item');
            END IF;

            rcv_error_pkg.set_error_message('RCV_UOM_NO_CONV_PRIMARY');
            RAISE e_validation_error;
        END IF;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Primary UOM for substitute item is ' || x_primary_uom);
        END IF;

        IF x_primary_uom <> v_cascaded_table(n).primary_unit_of_measure THEN
            prim_uom_qty                                 := convert_into_correct_qty(v_cascaded_table(n).quantity,
                                                                                     v_cascaded_table(n).unit_of_measure,
                                                                                     v_cascaded_table(n).item_id,
                                                                                     x_primary_uom
                                                                                    );

            IF prim_uom_qty = 0 THEN
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Not possible to convert between asn and primary UOM');
                END IF;

                rcv_error_pkg.set_error_message('RCV_UOM_NO_CONV_PRIMARY');
                RAISE e_validation_error;
            END IF;

            v_cascaded_table(n).primary_unit_of_measure  := x_primary_uom;
            v_cascaded_table(n).primary_quantity         := prim_uom_qty;
        END IF;

        x_item_id                               := v_cascaded_table(n).item_id;
        v_cascaded_table(n).item_id             := v_cascaded_table(n).substitute_item_id;
        v_cascaded_table(n).substitute_item_id  := x_item_id; -- Just for debugging purposes.

                                                              -- Check other fields that need to be reassigned/nulled out possibly
    EXCEPTION
        WHEN e_validation_error THEN
            v_cascaded_table(n).error_status   := x_error_status;
            v_cascaded_table(n).error_message  := rcv_error_pkg.get_last_message;

            IF v_cascaded_table(n).error_message = 'RCV_ITEM_SUB_NOT_ALLOWED' THEN
                rcv_error_pkg.set_token('ITEM', v_cascaded_table(n).substitute_item_id);
            ELSIF v_cascaded_table(n).error_message = 'RCV_UOM_NO_CONV_PRIMARY' THEN
                rcv_error_pkg.set_token('SHIPMENT_UNIT', v_cascaded_table(n).primary_unit_of_measure);
                rcv_error_pkg.set_token('PRIMARY_UNIT', x_primary_uom);
            END IF;
    END exchange_sub_item;

/*===========================================================================

  PROCEDURE NAME: get_po_header_id()

===========================================================================*/
    PROCEDURE get_po_header_id(
        x_po_header_id_record IN OUT NOCOPY rcv_shipment_line_sv.document_num_record_type
    ) IS
    BEGIN
        /* type_lookup_code will never be SCHEDULED in po_headers. This
          * should be PLANNED. Because of this, for PLANNED POs get_po_header_id
          * used to fail and hence open interface used to fail.
          * Changing SCHEDULED to PLANNED.
         */
        SELECT MAX(po_header_id)
        INTO   x_po_header_id_record.po_header_id
        FROM   po_headers
        WHERE  segment1 = x_po_header_id_record.document_num
        AND    type_lookup_code IN('STANDARD', 'BLANKET', 'PLANNED'); -- Could be a quotation with same number

        IF (x_po_header_id_record.po_header_id IS NULL) THEN
            x_po_header_id_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
            rcv_error_pkg.set_error_message('RCV_ITEM_PO_ID', x_po_header_id_record.error_record.error_message);
            rcv_error_pkg.set_token('PO_NUMBER', x_po_header_id_record.document_num);
            rcv_error_pkg.set_token('SHIPMENT', '');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            x_po_header_id_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
            rcv_error_pkg.set_sql_error_message('get_po_header_id', '000');
            x_po_header_id_record.error_record.error_message  := rcv_error_pkg.get_last_message;
    END get_po_header_id;

/*===========================================================================

  PROCEDURE NAME: get_item_id()

===========================================================================*/
    PROCEDURE get_item_id(
        x_item_id_record IN OUT NOCOPY rcv_shipment_line_sv.item_id_record_type
    ) IS
    BEGIN
        IF (x_item_id_record.item_num IS NOT NULL) THEN
            SELECT MIN(inventory_item_id),
                   MIN(primary_unit_of_measure),
                   MIN(lot_control_code), -- bug 608353
                   MIN(serial_number_control_code)
            INTO   x_item_id_record.item_id,
                   x_item_id_record.primary_unit_of_measure,
                   x_item_id_record.use_mtl_lot, -- bug 608353
                   x_item_id_record.use_mtl_serial
            FROM   mtl_item_flexfields
            WHERE  item_number = x_item_id_record.item_num
            AND    organization_id = x_item_id_record.to_organization_id;

            IF (x_item_id_record.item_id IS NULL) THEN
                SELECT MIN(inventory_item_id),
                       MIN(primary_unit_of_measure),
                       MIN(lot_control_code), -- bug 608353
                       MIN(serial_number_control_code)
                INTO   x_item_id_record.item_id,
                       x_item_id_record.primary_unit_of_measure,
                       x_item_id_record.use_mtl_lot,
                       x_item_id_record.use_mtl_serial
                FROM   mtl_item_flexfields
                WHERE  item_number = x_item_id_record.vendor_item_num
                AND    organization_id = x_item_id_record.to_organization_id;
            END IF;
        END IF;

        IF (x_item_id_record.item_id IS NULL) THEN
            x_item_id_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_warning;
            rcv_error_pkg.set_error_message('RCV_ITEM_PO_ID', x_item_id_record.error_record.error_message);
            rcv_error_pkg.set_token('ITEM', x_item_id_record.item_num);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            x_item_id_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
            rcv_error_pkg.set_sql_error_message('get_item_id', '000');
            x_item_id_record.error_record.error_message  := rcv_error_pkg.get_last_message;
    END get_item_id;

/*===========================================================================

  PROCEDURE NAME: get_sub_item_id()

===========================================================================*/
    PROCEDURE get_sub_item_id(
        x_sub_item_id_record IN OUT NOCOPY rcv_shipment_line_sv.sub_item_id_record_type
    ) IS
    BEGIN
        IF (x_sub_item_id_record.substitute_item_num IS NOT NULL) THEN
            SELECT MAX(inventory_item_id)
            INTO   x_sub_item_id_record.substitute_item_id
            FROM   mtl_system_items_kfv
            WHERE  concatenated_segments = x_sub_item_id_record.substitute_item_num;
        ELSE
            SELECT MAX(inventory_item_id)
            INTO   x_sub_item_id_record.substitute_item_id
            FROM   mtl_system_items_kfv
            WHERE  concatenated_segments = x_sub_item_id_record.vendor_item_num;
        END IF;

        IF (x_sub_item_id_record.substitute_item_id IS NULL) THEN
            x_sub_item_id_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
            rcv_error_pkg.set_error_message('RCV_ITEM_SUB_ID', x_sub_item_id_record.error_record.error_message);
            rcv_error_pkg.set_token('ITEM', x_sub_item_id_record.substitute_item_num);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            x_sub_item_id_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
            rcv_error_pkg.set_sql_error_message('get_sub_item_id', '000');
            x_sub_item_id_record.error_record.error_message  := rcv_error_pkg.get_last_message;
    END get_sub_item_id;

/*===========================================================================

  PROCEDURE NAME: get_po_line_id()

===========================================================================*/
    PROCEDURE get_po_line_id(
        x_po_line_id_record IN OUT NOCOPY rcv_shipment_line_sv.po_line_id_record_type
    ) IS
    BEGIN
        SELECT po_line_id,
               item_id
        INTO   x_po_line_id_record.po_line_id,
               x_po_line_id_record.item_id
        FROM   po_lines
        WHERE  po_header_id = x_po_line_id_record.po_header_id
        AND    line_num = x_po_line_id_record.document_line_num;

        IF (x_po_line_id_record.po_line_id IS NULL) THEN
            RAISE NO_DATA_FOUND;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            x_po_line_id_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
            rcv_error_pkg.set_error_message('RCV_ITEM_PO_LINE_ID', x_po_line_id_record.error_record.error_message);
            rcv_error_pkg.set_token('NUMBER', x_po_line_id_record.document_line_num);
        WHEN OTHERS THEN
            x_po_line_id_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
            rcv_error_pkg.set_sql_error_message('get_po_line_id', '000');
            x_po_line_id_record.error_record.error_message  := rcv_error_pkg.get_last_message;
    END get_po_line_id;

/*===========================================================================

  PROCEDURE NAME: get_org_id()

  This call is done by EDI to obtain the org_id give the location id

===========================================================================*/
    PROCEDURE get_org_id_from_hr_loc_id(
        p_hr_location_id  IN            NUMBER,
        x_organization_id OUT NOCOPY    NUMBER
    ) IS
    BEGIN
        SELECT inventory_organization_id
        INTO   x_organization_id
        FROM   hr_locations
        WHERE  location_id = p_hr_location_id;
    EXCEPTION
        WHEN OTHERS THEN
            x_organization_id  := NULL;
    END get_org_id_from_hr_loc_id;
END rcv_transactions_interface_sv;

/
