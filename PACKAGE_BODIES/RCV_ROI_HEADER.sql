--------------------------------------------------------
--  DDL for Package Body RCV_ROI_HEADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_ROI_HEADER" 
/* $Header: RCVPREHB.pls 120.5.12010000.6 2011/06/03 20:13:54 vthevark ship $*/
AS
    g_asn_debug       VARCHAR2(1)  := asn_debug.is_debug_on;  -- Bug 9152790: rcv debug enhancement
    x_interface_type  VARCHAR2(25) := 'RCV-856';
    x_sysdate         DATE         := SYSDATE;
    x_count           NUMBER       := 0;
    x_in_this_op_unit NUMBER       := 0; -- Bug 3359613

    PROCEDURE process_header(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        NULL;
    END process_header;

    PROCEDURE process_cancellation(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        asn_debug.put_line('new_roi: in process_cancellation');
        derive_vendor_header(p_header_record);

        IF p_header_record.error_record.error_status IN('S', 'W') THEN
            default_vendor_header(p_header_record);
        END IF;

        IF p_header_record.error_record.error_status IN('S', 'W') THEN
            validate_vendor_header(p_header_record);
        END IF;

        IF p_header_record.error_record.error_status IN('S', 'W') THEN
            IF NVL(p_header_record.header_record.test_flag, 'N') <> 'Y' THEN
                insert_cancelled_asn_lines(p_header_record);
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Exception in process_cancellation ');
            END IF;

            p_header_record.error_record.error_status   := 'U';
            p_header_record.error_record.error_message  := SQLERRM;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Fatal Error');
            END IF;
    END process_cancellation;

    PROCEDURE process_vendor_header(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
        l_shipment_header_id  NUMBER;
        l_receive_against_asn VARCHAR2(1) := 'N';
    BEGIN
        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('new_roi: in process_vendor_header');
        END IF;

        /* check whether there is already a row in rsh for the given
         * shipment_num . It will be there if this is a
         * Receive  against an ASN.
        */
        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('ASN_TYPE ' || NVL(p_header_record.header_record.asn_type, 'STD'));
        END IF;

        /* We need to derive vendor header for ASN receive since we can have
         * same shipment_num for different vendor/vendor_site combinations.
        */
        derive_vendor_header(p_header_record);

        IF p_header_record.error_record.error_status IN('S', 'W') THEN
            default_vendor_header(p_header_record);
        END IF;

        IF p_header_record.error_record.error_status IN('S', 'W') THEN
            validate_vendor_header(p_header_record);
        END IF;

        /* Bug#4523892 - START */
        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Transaction against ASN? ' || g_txn_against_asn);
        END IF;
        /* Bug#4523892 - END */

        IF p_header_record.error_record.error_status IN('S', 'W') THEN --{
            IF (    NVL(p_header_record.header_record.test_flag, 'N') <> 'Y'
                AND g_txn_against_asn <> 'Y') THEN --{
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Call insert_shipment_header');
                END IF;

                insert_shipment_header(p_header_record);

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('After insert_shipment_header');
                END IF;
            ELSIF(g_txn_against_asn = 'Y') THEN
                /* Some fields can be changed at the time of
                 * receiving an ASN. We need to update these
                 * in rsh.
                */
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Before update_shipment_header');
                END IF;

                update_shipment_header(p_header_record);

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('After update_shipment_header');
                END IF;
            END IF; --}
        END IF; --}
    EXCEPTION
        WHEN OTHERS THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Exception in process_vendor_header ');
            END IF;

            p_header_record.error_record.error_status   := 'U';
            p_header_record.error_record.error_message  := SQLERRM;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Fatal Error');
            END IF;
    END process_vendor_header;

    PROCEDURE process_customer_header(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        asn_debug.put_line('new_roi: in process_customer_header');
        rcv_rma_headers.derive_rma_header(p_header_record);

        IF p_header_record.error_record.error_status IN('S', 'W') THEN
            rcv_rma_headers.default_rma_header(p_header_record);
        END IF;

        IF p_header_record.error_record.error_status IN('S', 'W') THEN
            rcv_rma_headers.validate_rma_header(p_header_record);
        END IF;

        IF p_header_record.error_record.error_status IN('S', 'W') THEN
            IF NVL(p_header_record.header_record.test_flag, 'N') <> 'Y' THEN
                rcv_rma_headers.insert_rma_header(p_header_record);
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Exception in process_customer_header ');
            END IF;

            p_header_record.error_record.error_status   := 'U';
            p_header_record.error_record.error_message  := SQLERRM;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Fatal Error');
            END IF;
    END process_customer_header;

    PROCEDURE process_internal_header(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        asn_debug.put_line('new_roi: in process_internal_header');
    END process_internal_header;

    PROCEDURE process_internal_order_header(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        asn_debug.put_line('new_roi: in process_internal_order_header');
        derive_internal_order_header(p_header_record);

        IF p_header_record.error_record.error_status IN('S', 'W') THEN
            default_internal_order_header(p_header_record);
        END IF;

        IF p_header_record.error_record.error_status IN('S', 'W') THEN
            validate_internal_order_header(p_header_record);
        END IF;

        IF p_header_record.error_record.error_status IN('S', 'W') THEN
           rcv_int_order_pp_pvt.update_header(p_header_record);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Exception in process_internal_order_header ');
            END IF;

            p_header_record.error_record.error_status   := 'U';
            p_header_record.error_record.error_message  := SQLERRM;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Fatal Error');
            END IF;
    END process_internal_order_header;

    PROCEDURE derive_vendor_header(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        -- Note.: the derive receipt source code was not done. DO we need it ??
        --??? (RCVHISVB : lines 593 - 600)

        derive_vendor_info(p_header_record);
        rcv_roi_header_common.derive_ship_to_org_info(p_header_record);
        rcv_roi_header_common.derive_from_org_info(p_header_record);
        derive_vendor_site_info(p_header_record);
        rcv_roi_header_common.derive_location_info(p_header_record);
        derive_payment_terms_info(p_header_record);
        rcv_roi_header_common.derive_receiver_info(p_header_record);
        derive_shipment_header_id(p_header_record);
    END derive_vendor_header;

    PROCEDURE default_vendor_header(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        rcv_roi_header_common.default_last_update_info(p_header_record);
        rcv_roi_header_common.default_creation_info(p_header_record);
        rcv_roi_header_common.default_asn_type(p_header_record);
        rcv_roi_header_common.default_ship_from_loc_info(p_header_record);
        default_shipment_num(p_header_record);

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('asn_tyoe ' || NVL(p_header_record.header_record.asn_type, 'STD'));
            asn_debug.put_line('shipment_num ' || NVL(p_header_record.header_record.shipment_num, -999));
            asn_debug.put_line('receipt_header_id ' || NVL(p_header_record.header_record.receipt_header_id, -999));
        END IF;

        g_txn_against_asn := 'Y'; /* Bug#4523892 */
        IF (    NVL(p_header_record.header_record.asn_type, 'STD') = 'STD'
            AND (   p_header_record.header_record.shipment_num IS NOT NULL
                 AND p_header_record.header_record.receipt_header_id IS NOT NULL)) THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Into default shipment info for an ASN receive');
            END IF;

            default_shipment_info(p_header_record);
            rcv_roi_header_common.default_receipt_info(p_header_record);
        ELSE   /* For all other txns except asn receive */
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Into default shipment info for non ASN receive');
            END IF;

            default_vendor_site_id(p_header_record);
            rcv_roi_header_common.default_shipment_header_id(p_header_record);
            rcv_roi_header_common.default_receipt_info(p_header_record);
            rcv_roi_header_common.default_ship_to_location_info(p_header_record);
        END IF;

        -- added for support of cancel
        -- default any shipment info
        IF     (p_header_record.header_record.transaction_type = 'CANCEL')
           AND (   p_header_record.header_record.receipt_header_id IS NULL
                OR p_header_record.header_record.shipment_num IS NULL) THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Into default shipment info');
            END IF;

            --rcv_core_s.default_shipment_info (p_header_record);
            default_shipment_info(p_header_record);
        END IF;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('g_txn_against_asn in default_vendor_header:' || g_txn_against_asn);
            asn_debug.put_line('Out of default');
        END IF;
    END default_vendor_header;

    PROCEDURE validate_vendor_header(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        rcv_roi_header_common.validate_trx_type(p_header_record);
        validate_document_type(p_header_record);
        validate_currency_code(p_header_record);
        rcv_roi_header_common.validate_shipment_date(p_header_record);
        validate_receipt_date(p_header_record);
        rcv_roi_header_common.validate_expected_receipt_date(p_header_record);
        rcv_roi_header_common.validate_receipt_num(p_header_record);
        rcv_roi_header_common.validate_ship_from_loc_info(p_header_record);

        IF (p_header_record.header_record.receipt_source_code = 'VENDOR') THEN
            validate_vendor_info(p_header_record);
            validate_vendor_site_info(p_header_record);
        END IF;

        rcv_roi_header_common.validate_ship_to_org_info(p_header_record);
        rcv_roi_header_common.validate_from_org_info(p_header_record);
        rcv_roi_header_common.validate_location_info(p_header_record);
        rcv_roi_header_common.validate_payment_terms_info(p_header_record);
        rcv_roi_header_common.validate_receiver_info(p_header_record);
        rcv_roi_header_common.validate_freight_carrier_info(p_header_record);

        /* Bug#4523892 */
        IF (NVL(p_header_record.header_record.asn_type, 'STD') = 'STD'
            AND g_txn_against_asn = 'Y') THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('End of validations if this is an ASN receive');
            END IF;

            RETURN;
        END IF;

        IF (p_header_record.header_record.receipt_source_code = 'VENDOR') THEN
            validate_asbn_specific_info(p_header_record);
	    rcv_roi_header_common.validate_lcm_info(p_header_record); -- lcm changes
        END IF;

           /* Validate gross_weight_uom_code */
        /* Validate net_weight_uom_code */
        /* Validate tare_weight_uom_code */
        /* Validate Carrier_method */
        /* Validate Special handling code */
        /* Validate Hazard Code */
        /* Validate Hazard Class */
        /* Validate Freight Terms */
        /* Validate Excess Transportation Reason */
        /* Validate Excess Transportation Responsible */
        /* Validate Invoice Status Code */
        IF p_header_record.error_record.error_status IN('S', 'W') THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Other Validations');
            END IF;
        END IF;
    END validate_vendor_header;

    PROCEDURE derive_customer_header(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        NULL;
    END derive_customer_header;

    PROCEDURE default_customer_header(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        NULL;
    END default_customer_header;

    PROCEDURE validate_customer_header(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        NULL;
    END validate_customer_header;

    PROCEDURE derive_internal_header(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        NULL;
    END derive_internal_header;

    PROCEDURE default_internal_header(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        NULL;
    END default_internal_header;

    PROCEDURE validate_internal_header(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        NULL;
    END validate_internal_header;

    -- Wrapper to RCV_INT_ORDER_PP_PVT version, for consistency
    PROCEDURE derive_internal_order_header(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        rcv_int_order_pp_pvt.derive_internal_order_header(p_header_record);
    END derive_internal_order_header;

    -- WRAPPER to RCV_INT_ORDER_PP_PVT version, for consistency
    PROCEDURE default_internal_order_header(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        rcv_int_order_pp_pvt.default_internal_order_header(p_header_record);
    END default_internal_order_header;

    -- WRAPPER to RCV_INT_ORDER_PP_PVT version, for consistency
    PROCEDURE validate_internal_order_header(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        rcv_int_order_pp_pvt.validate_internal_order_header(p_header_record);
    END validate_internal_order_header;

    PROCEDURE derive_vendor_info(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
        vendor_record rcv_shipment_header_sv.vendorrectype;
    BEGIN
        /* Derive Vendor Information */
        IF p_header_record.error_record.error_status IN('S', 'W') THEN
            vendor_record.vendor_name                   := p_header_record.header_record.vendor_name;
            vendor_record.vendor_num                    := p_header_record.header_record.vendor_num;
            vendor_record.vendor_id                     := p_header_record.header_record.vendor_id;
            vendor_record.error_record.error_status     := p_header_record.error_record.error_status;
            vendor_record.error_record.error_message    := p_header_record.error_record.error_message;

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

            p_header_record.header_record.vendor_name   := vendor_record.vendor_name;
            p_header_record.header_record.vendor_num    := vendor_record.vendor_num;
            p_header_record.header_record.vendor_id     := vendor_record.vendor_id;
            p_header_record.error_record.error_status   := vendor_record.error_record.error_status;
            p_header_record.error_record.error_message  := vendor_record.error_record.error_message;
        END IF;
    END derive_vendor_info;

    PROCEDURE derive_vendor_site_info(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
        vendor_site_record rcv_shipment_header_sv.vendorsiterectype;
    BEGIN
        /* derive vendor site information */
        /* Call derive vendor_site_procedure here */
        /* UK1 -> vendor_site_id
         UK2 -> vendor_site_code + vendor_id + org_id  */
        IF     p_header_record.error_record.error_status IN('S', 'W')
           AND (   p_header_record.header_record.vendor_site_code IS NOT NULL
                OR p_header_record.header_record.vendor_site_id IS NOT NULL) THEN
            vendor_site_record.vendor_site_code                    := p_header_record.header_record.vendor_site_code;
            vendor_site_record.vendor_id                           := p_header_record.header_record.vendor_id;
            vendor_site_record.vendor_site_id                      := p_header_record.header_record.vendor_site_id;
            vendor_site_record.organization_id                     := p_header_record.header_record.ship_to_organization_id;
            vendor_site_record.error_record.error_status           := p_header_record.error_record.error_status;
            vendor_site_record.error_record.error_message          := p_header_record.error_record.error_message;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('In Vendor Site Procedure');
            END IF;

            po_vendor_sites_sv.derive_vendor_site_info(vendor_site_record);

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line(vendor_site_record.vendor_site_code);
                asn_debug.put_line(vendor_site_record.vendor_site_id);
            END IF;

            p_header_record.header_record.vendor_site_code         := vendor_site_record.vendor_site_code;
            p_header_record.header_record.vendor_id                := vendor_site_record.vendor_id;
            p_header_record.header_record.vendor_site_id           := vendor_site_record.vendor_site_id;
            p_header_record.header_record.ship_to_organization_id  := vendor_site_record.organization_id;
            p_header_record.error_record.error_status              := vendor_site_record.error_record.error_status;
            p_header_record.error_record.error_message             := vendor_site_record.error_record.error_message;
        END IF;
    END derive_vendor_site_info;

    PROCEDURE derive_payment_terms_info(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
        pay_record rcv_shipment_header_sv.payrectype;
    BEGIN
/* Derive Payment Terms Information */
        IF     p_header_record.error_record.error_status IN('S', 'W')
           AND p_header_record.header_record.transaction_type <> 'CANCEL'
           AND -- added for support of cancel
               (   p_header_record.header_record.payment_terms_id IS NOT NULL
                OR p_header_record.header_record.payment_terms_name IS NOT NULL) THEN
            pay_record.payment_term_id                        := p_header_record.header_record.payment_terms_id;
            pay_record.payment_term_name                      := p_header_record.header_record.payment_terms_name;
            pay_record.error_record.error_status              := p_header_record.error_record.error_status;
            pay_record.error_record.error_message             := p_header_record.error_record.error_message;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('In Derive Payment Terms ');
            END IF;

            po_terms_sv.derive_payment_terms_info(pay_record);

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line(pay_record.payment_term_name);
                asn_debug.put_line(TO_CHAR(pay_record.payment_term_id));
                asn_debug.put_line(pay_record.error_record.error_status);
            END IF;

            p_header_record.header_record.payment_terms_id    := pay_record.payment_term_id;
            p_header_record.header_record.payment_terms_name  := pay_record.payment_term_name;
            p_header_record.error_record.error_status         := pay_record.error_record.error_status;
            p_header_record.error_record.error_message        := pay_record.error_record.error_message;
        END IF;
    END derive_payment_terms_info;

    PROCEDURE derive_shipment_header_id(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        /* Derive shipment_header_id if transaction type = CANCEL */
        -- added for support of cancel
        IF     p_header_record.error_record.error_status IN('S', 'W')
           AND (   (p_header_record.header_record.transaction_type = 'CANCEL')
                OR NVL(p_header_record.header_record.asn_type, 'STD') = 'STD')
           AND p_header_record.header_record.shipment_num IS NOT NULL THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Derive shipment info for CANCEL or Receive against an ASN');
            END IF;

            --rcv_core_s.derive_shipment_info(p_header_record);
            derive_shipment_info(p_header_record);
        END IF;
    END derive_shipment_header_id;

    PROCEDURE derive_shipment_info(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        IF p_header_record.header_record.receipt_header_id IS NOT NULL THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Need to put a cursor to retrieve other values');
                asn_debug.put_line('Shipment header Id has been provided');
            END IF;

            RETURN;
        END IF;

        -- Check that the shipment_num is not null
        IF (   p_header_record.header_record.shipment_num IS NULL
            OR p_header_record.header_record.shipment_num = '0'
            OR REPLACE(p_header_record.header_record.shipment_num,
                       ' ',
                       ''
                      ) IS NULL) THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Cannot derive the shipment_header_id at this point');
            END IF;

            RETURN;
        END IF;

        -- Derive the shipment_header_id only for transaction_type = CANCEL
        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Will derive shipment_header_id if shipment_num is given');
        END IF;

        /*
         * BUGNO: 1708017
         * The where clause used to have organization_id =
         * p_header_record.header_record.ship_to_organization_id
         * This used to be populated with ship_to_organization_id.
         * Now this is populated as null since it is supposed to
         * be from organization_id. So changed it to ship_to_org_id.
        */
        IF     (   (p_header_record.header_record.transaction_type = 'CANCEL')
                OR NVL(p_header_record.header_record.asn_type, 'STD') = 'STD')
           AND p_header_record.header_record.receipt_header_id IS NULL THEN
            BEGIN
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('vendor_site_id ' || p_header_record.header_record.vendor_site_id);
                    asn_debug.put_line('vendor_id ' || p_header_record.header_record.vendor_id);
                    asn_debug.put_line('ship_to_organization_id ' || p_header_record.header_record.ship_to_organization_id);
                    asn_debug.put_line('shipment_num ' || p_header_record.header_record.shipment_num);
                    asn_debug.put_line('shipped_date ' || p_header_record.header_record.shipped_date);
                END IF;

                SELECT MAX(shipment_header_id) -- if we ever have 2 shipments with the same combo
                INTO   p_header_record.header_record.receipt_header_id
                FROM   rcv_shipment_headers
                WHERE  NVL(vendor_site_id, -9999) = NVL(p_header_record.header_record.vendor_site_id, NVL(vendor_site_id, -9999))
                AND    vendor_id = p_header_record.header_record.vendor_id
                AND    ship_to_org_id = p_header_record.header_record.ship_to_organization_id
                AND    shipment_num = p_header_record.header_record.shipment_num
                AND    (   (    p_header_record.header_record.transaction_type = 'CANCEL'
                            AND shipped_date >= ADD_MONTHS(p_header_record.header_record.shipped_date, -12))
                        OR (    p_header_record.header_record.transaction_type <> 'CANCEL'
                            AND shipped_date >= NVL(ADD_MONTHS(p_header_record.header_record.shipped_date, -12), shipped_date))
                       );

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('receipt_header_id ' || p_header_record.header_record.receipt_header_id);
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('Select stmt failed to get ship_header_id');
                        asn_debug.put_line(SQLERRM);
                    END IF;
            END;

            RETURN;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Exception in when others in derive_shipment_info ');
            END IF;

            p_header_record.error_record.error_status   := 'U';
            p_header_record.error_record.error_message  := SQLERRM;
    END derive_shipment_info;

    PROCEDURE default_shipment_num(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        /* SHIPMENT NUMBER FOR ASBN if shipment_num IS NULL  */
        /* First choice for ASBN */
        IF     p_header_record.header_record.asn_type = 'ASBN'
           AND p_header_record.header_record.shipment_num IS NULL THEN
            p_header_record.header_record.shipment_num  := p_header_record.header_record.invoice_num;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('defaulted shipment number');
            END IF;
        END IF;

        /* SHIPMENT NUMBER FOR ASBN/ASN if shipment_num IS NULL */
        /* First choice for ASN/ Second Choice for ASN */

        /* Bug3462816 Packing slip should not defaulted for normal Receipts */
        IF     NVL(p_header_record.header_record.asn_type, 'ASN') <> 'STD'
           AND p_header_record.header_record.shipment_num IS NULL THEN
            p_header_record.header_record.shipment_num  := p_header_record.header_record.packing_slip;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('defaulted shipment number');
            END IF;
        END IF;
    END default_shipment_num;

    PROCEDURE default_vendor_site_id(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS

     /* 5953480 - declared below two variables, to get proper site value. */
      count1   number :=0;
      x_ven_site_id  number;

    BEGIN
        /* vendor_site_id  po_vendor_sites_sv.default_purchasing_site */
           /* Check for whether we need more conditions in the where clause of the
           procedure like pay_site_flag etc */
           /* For transaction_type = CANCEL we should have picked up the vendor_site_id in
           the derive_shipment_info stage */

	    /* Bug 5953480 fixed. we would not default vendor_site here as it is
            taken care while processing RTI records. Hence commenting the following piece
            of code which defaults the vendor_site info if only one vendor_site exists
            for a vendor which could potentially default wrong vendor_site as in the
            bug 5953480.
            Added code to default the vendor_site info only if the corresponding RTIs
            having POs with same vendor_site info.
            */

        IF     p_header_record.header_record.vendor_site_id IS NULL
           AND p_header_record.header_record.vendor_site_code IS NULL
           AND p_header_record.header_record.vendor_id IS NOT NULL THEN -- added for support of cancel
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Need to get default vendor site id');
            END IF;


           /*
	      po_vendor_sites_sv.get_def_vendor_site(p_header_record.header_record.vendor_id,
                                                   p_header_record.header_record.vendor_site_id,
                                                   p_header_record.header_record.vendor_site_code,
                                                   'RCV'
                                                  );
	   */

	   /*Commented above code line and added below code block for 5953480 */

	   BEGIN
           SELECT Count(DISTINCT poh.vendor_site_id),poh.vendor_site_id
           INTO count1,x_ven_site_id
           FROM rcv_transactions_interface rti, po_headers poh
           WHERE ((rti.document_num IS NOT NULL AND rti.document_num = poh.segment1) OR
               (rti.po_header_id is not null AND rti.po_header_id = poh.po_header_id))
           AND rti.header_interface_id = p_header_record.header_record.header_interface_id
           GROUP BY poh.vendor_site_id;
           EXCEPTION
            WHEN TOO_MANY_ROWS THEN
             count1 := 2;
           WHEN NO_DATA_FOUND THEN
             count1 :=0;
          END;


          IF (count1 = 1) and x_ven_site_id is not null THEN
           p_header_record.header_record.vendor_site_id := x_ven_site_id;
           po_vendor_sites_sv.get_vendor_site_name(x_ven_site_id,p_header_record.header_record.vendor_site_code);
          END IF;

          /*End of added code block for 5953480 */

            IF (g_asn_debug = 'Y') THEN
	      asn_debug.put_line('Vendor Site Code is ='||p_header_record.header_record.vendor_site_code);
              asn_debug.put_line('defaulted vendor_site info');
            END IF;
        END IF;
    END default_vendor_site_id;

    PROCEDURE default_shipment_info(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
        x_count NUMBER;
    BEGIN
        -- no need to derive shipment_header_id if it is already provided
        IF p_header_record.header_record.receipt_header_id IS NOT NULL THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Shipment header Id has been provided');
            END IF;

            RETURN;
        END IF;

        -- Check for shipment number which is null, blank , zero
        IF     p_header_record.header_record.asn_type IN('ASN', 'ASBN', 'LCM') /* lcm changes */
           AND (   p_header_record.header_record.shipment_num IS NULL
                OR p_header_record.header_record.shipment_num = '0'
                OR REPLACE(p_header_record.header_record.shipment_num,
                           ' ',
                           ''
                          ) IS NULL) THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Shipment num is still null');
            END IF;

            RETURN;
        END IF;

        -- Derive the shipment_header_id based on the shipment_num for transaction_type = CANCEL
              /*
          * BUGNO: 1708017
          * The where clause used to have organization_id =
          * p_header_record.header_record.ship_to_organization_id
          * This used to be populated with ship_to_organization_id.
          * Now this is populated as null since it is supposed to
          * be from organization_id. So changed it to ship_to_org_id.
         */
        IF     (   (p_header_record.header_record.transaction_type = 'CANCEL')
                OR NVL(p_header_record.header_record.asn_type, 'STD') = 'STD')
           AND p_header_record.header_record.receipt_header_id IS NULL THEN
            BEGIN
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('vendor_site_id ' || p_header_record.header_record.vendor_site_id);
                    asn_debug.put_line('vendor_id ' || p_header_record.header_record.vendor_id);
                    asn_debug.put_line('ship_to_organization_id ' || p_header_record.header_record.ship_to_organization_id);
                    asn_debug.put_line('shipment_num ' || p_header_record.header_record.shipment_num);
                    asn_debug.put_line('shipped_date ' || p_header_record.header_record.shipped_date);
                END IF;

                SELECT MAX(shipment_header_id) -- if we ever have 2 shipments with the same combo
                INTO   p_header_record.header_record.receipt_header_id
                FROM   rcv_shipment_headers
                WHERE  NVL(vendor_site_id, -9999) = NVL(p_header_record.header_record.vendor_site_id, -9999)
                AND    vendor_id = p_header_record.header_record.vendor_id
                AND    ship_to_org_id = p_header_record.header_record.ship_to_organization_id
                AND    shipment_num = p_header_record.header_record.shipment_num
                AND    (   (    p_header_record.header_record.transaction_type = 'CANCEL'
                            AND shipped_date >= ADD_MONTHS(p_header_record.header_record.shipped_date, -12))
                        OR (    p_header_record.header_record.transaction_type <> 'CANCEL'
                            AND shipped_date >= NVL(ADD_MONTHS(p_header_record.header_record.shipped_date, -12), shipped_date))
                       );
            EXCEPTION
                WHEN OTHERS THEN
                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('Exception in derive ship_header in default shipment_info');
                        asn_debug.put_line(SQLERRM);
                    END IF;
            END;

            RETURN;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Exception in when others in default_shipment_info ');
            END IF;

            p_header_record.error_record.error_status   := 'U';
            p_header_record.error_record.error_message  := SQLERRM;
    END default_shipment_info;

    PROCEDURE validate_document_type(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
        lookup_record rcv_shipment_header_sv.lookuprectype;
    BEGIN
        /* Validate Document type */
        IF p_header_record.error_record.error_status IN('S', 'W') THEN
            IF     p_header_record.header_record.asn_type IS NOT NULL
               AND p_header_record.header_record.asn_type <> 'STD' THEN
                lookup_record.lookup_code                   := p_header_record.header_record.asn_type;
                lookup_record.lookup_type                   := 'ASN_TYPE';
                lookup_record.error_record.error_status     := p_header_record.error_record.error_status;
                lookup_record.error_record.error_message    := p_header_record.error_record.error_message;
                po_core_s.validate_lookup_info(lookup_record);

                IF lookup_record.error_record.error_status IN('E') THEN
                    lookup_record.error_record.error_message  := 'PO_PDOI_INVALID_TYPE_LKUP_CD';
                    rcv_error_pkg.set_error_message(lookup_record.error_record.error_message);
                    rcv_error_pkg.set_token('VALUE', lookup_record.lookup_code);
                    rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE',
                                                      'ASN_TYPE',
                                                      FALSE
                                                     );
                END IF;

                p_header_record.error_record.error_status   := lookup_record.error_record.error_status;
                p_header_record.error_record.error_message  := lookup_record.error_record.error_message;

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('validated asn type');
                END IF;
            ELSE
                p_header_record.header_record.asn_type  := 'STD'; -- Not an ASN/ASBN
            END IF;
        END IF;
    END validate_document_type;

    PROCEDURE validate_currency_code(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
        currency_record rcv_shipment_header_sv.currectype;
    BEGIN
        /* Validate Currency Code */
        IF     p_header_record.error_record.error_status IN('S', 'W')
           AND p_header_record.header_record.transaction_type <> 'CANCEL'
           AND p_header_record.header_record.asn_type = 'ASBN'
           AND p_header_record.header_record.currency_code IS NOT NULL THEN
            currency_record.currency_code               := p_header_record.header_record.currency_code;
            currency_record.error_record.error_status   := p_header_record.error_record.error_status;
            currency_record.error_record.error_message  := p_header_record.error_record.error_message;
            po_currency_sv.validate_currency_info(currency_record);

            IF currency_record.error_record.error_status = 'E' THEN
                IF currency_record.error_record.error_message IN('CURRENCY_DISABLED', 'CURRENCY_INVALID') THEN
                    currency_record.error_record.error_message  := 'PO_PDOI_INVALID_CURRENCY';
                    rcv_error_pkg.set_error_message(currency_record.error_record.error_message);
                    rcv_error_pkg.set_token('VALUE', currency_record.currency_code);
                    rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE',
                                                      'CURRECTYPE',
                                                      FALSE
                                                     );
                END IF;
            END IF;

            p_header_record.error_record.error_status   := currency_record.error_record.error_status;
            p_header_record.error_record.error_message  := currency_record.error_record.error_message;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('validated currency info');
            END IF;
        END IF;
    END validate_currency_code;

    PROCEDURE validate_receipt_date(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        /* Validation for Receipt Date > Shipped Date if Receipt Date is specified */
        IF     p_header_record.error_record.error_status IN('S', 'W')
           AND p_header_record.header_record.transaction_type <> 'CANCEL' THEN
            IF p_header_record.header_record.expected_receipt_date IS NOT NULL THEN
                IF p_header_record.header_record.expected_receipt_date <   /* nwang: allow expected_receipt_date to be the same as shipped_date */
                                                                        p_header_record.header_record.shipped_date THEN
                    p_header_record.error_record.error_status   := 'E';
                    p_header_record.error_record.error_message  := 'RCV_DELIV_DATE_INVALID';
                    rcv_error_pkg.set_error_message(p_header_record.error_record.error_message);
                    rcv_error_pkg.set_token('DELIVERY DATE', fnd_date.date_to_chardate(p_header_record.header_record.expected_receipt_date));
                    rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE',
                                                      'SHIPPED_DATE',
                                                      FALSE
                                                     );
                END IF;
            END IF;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('validated for Receipt Date > Shipped Date if Receipt Date is specified');
            END IF;
        END IF;
    END validate_receipt_date;

    PROCEDURE validate_vendor_info(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
        vendor_record rcv_shipment_header_sv.vendorrectype;
    BEGIN
/* Validate Vendor Information */
        IF     p_header_record.header_record.vendor_id IS NULL
           AND p_header_record.header_record.vendor_name IS NULL
           AND p_header_record.header_record.vendor_num IS NULL THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('validated vendor info is all null');
            END IF;

            p_header_record.error_record.error_status   := 'E';
            p_header_record.error_record.error_message  := 'TBD';
        END IF;

        IF p_header_record.error_record.error_status IN('S', 'W') THEN
            vendor_record.vendor_name                   := p_header_record.header_record.vendor_name;
            vendor_record.vendor_num                    := p_header_record.header_record.vendor_num;
            vendor_record.vendor_id                     := p_header_record.header_record.vendor_id;
            vendor_record.error_record.error_status     := p_header_record.error_record.error_status;
            vendor_record.error_record.error_message    := p_header_record.error_record.error_message;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('In Vendor Validation Procedure');
            END IF;

            po_vendors_sv.validate_vendor_info(vendor_record);

            IF vendor_record.error_record.error_status = 'E' THEN
                IF vendor_record.error_record.error_message = 'VEN_DISABLED' THEN
                    vendor_record.error_record.error_message  := 'PO_PDOI_INVALID_VENDOR';
                    rcv_error_pkg.set_error_message(vendor_record.error_record.error_message);
                    rcv_error_pkg.set_token('VALUE', vendor_record.vendor_id);
                    rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE',
                                                      'VENDOR_ID',
                                                      FALSE
                                                     );
                ELSIF vendor_record.error_record.error_message = 'VEN_HOLD' THEN
                    IF p_header_record.header_record.transaction_type <> 'CANCEL' THEN
                        vendor_record.error_record.error_message  := 'PO_PO_VENDOR_ON_HOLD';
                        rcv_error_pkg.set_error_message(vendor_record.error_record.error_message);
                        rcv_error_pkg.set_token('VALUE', vendor_record.vendor_id);
                        rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE',
                                                          'VENDOR_ID',
                                                          FALSE
                                                         );
                    ELSE
                        vendor_record.error_record.error_message  := NULL;
                        vendor_record.error_record.error_status   := 'S';
                    END IF;
                ELSIF vendor_record.error_record.error_message = 'VEN_ID' THEN
                    vendor_record.error_record.error_message  := 'RCV_VEN_ID';
                    rcv_error_pkg.set_error_message(vendor_record.error_record.error_message);
                    rcv_error_pkg.set_token('SUPPLIER', vendor_record.vendor_id);
                    rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE',
                                                      'VENDOR_ID',
                                                      FALSE
                                                     );
                END IF;
            END IF;

            p_header_record.error_record.error_status   := vendor_record.error_record.error_status;
            p_header_record.error_record.error_message  := vendor_record.error_record.error_message;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line(vendor_record.error_record.error_status);
                asn_debug.put_line(vendor_record.error_record.error_message);
            END IF;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Validated vendor info');
            END IF;
        END IF;
    END validate_vendor_info;

    PROCEDURE validate_vendor_site_info(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
        vendor_site_record rcv_shipment_header_sv.vendorsiterectype;
        l_proc             VARCHAR2(100);
    BEGIN
/* validate vendor site information */
        IF     p_header_record.error_record.error_status IN('S', 'W')
           AND (   p_header_record.header_record.vendor_site_code IS NOT NULL
                OR p_header_record.header_record.vendor_site_id IS NOT NULL) THEN
            vendor_site_record.vendor_site_code            := p_header_record.header_record.vendor_site_code;
            vendor_site_record.vendor_id                   := p_header_record.header_record.vendor_id;
            vendor_site_record.vendor_site_id              := p_header_record.header_record.vendor_site_id;
            vendor_site_record.organization_id             := NULL;
            vendor_site_record.error_record.error_status   := p_header_record.error_record.error_status;
            vendor_site_record.error_record.error_message  := p_header_record.error_record.error_message;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('In Validate Vendor Site Procedure');
                asn_debug.put_line('Remit_to_site_id ' || NVL(p_header_record.header_record.remit_to_site_id, -999));
            END IF;

            /* Bug 3590488.
             * We need to send remit_to_site_id since certain flags like
             * hold_all_payment_flag and pay_on_site_id should be validated
             * using remit_to_site_id instead of vendor_site_id for ASBNs.
            */
            po_vendor_sites_sv.validate_vendor_site_info(vendor_site_record, p_header_record.header_record.remit_to_site_id);

            /* if supplier site is not defined as pay on receipt site then
               the validate_vendor_site proc returns error_message =
               'VEN_SITE_NOT_POR_SITE'. This error is applicable only for asn_type=ASBN.
               Also invoice_status_code needs to be set to a predefined value in case we hit this
               error as invoice cannot be auto created.

               In case asn_type = ASN then we reset the error_status and message */

            /*
             * Bug #933119
             * When the hold_all_payments flag is set for a vendor site,
             * the pre-processor used to error out which was incorrect. This error
             * is applicable only for asn_type=ASBN. In case asn_type=ASN then we
             * now we reset the error_status and message.
            */
            /* Bug 8643650 In case of ASBNs, if the supplier site on the PO has pay site disabled and it has an
               alternative pay site enabled, the preprocessor logic should not insert a record into po_interface_errors
               table or update the value of invoice_status_code on the header record. Fix done to handle such a scenario
               by setting the error_status to 'S' and error_message to NULL.
            */
            IF (    vendor_site_record.error_record.error_status = 'E'
                AND vendor_site_record.error_record.error_message = 'VEN_SITE_HOLD_PMT') THEN
                IF     p_header_record.header_record.asn_type = 'ASBN'
                   AND p_header_record.header_record.transaction_type <> 'CANCEL' THEN
                    vendor_site_record.error_record.error_message      := 'PO_INV_CR_INVALID_PAY_SITE';
                    vendor_site_record.error_record.error_status       := 'W';
                    rcv_error_pkg.set_error_message(vendor_site_record.error_record.error_message);
                    rcv_error_pkg.set_token('VENDOR_SITE_ID', vendor_site_record.vendor_site_id);
                    rcv_error_pkg.log_interface_warning('RCV_HEADERS_INTERFACE', 'VENDOR_SITE_ID');
                    p_header_record.header_record.invoice_status_code  := 'RCV_ASBN_NO_AUTO_INVOICE';
                ELSE
                    vendor_site_record.error_record.error_status   := 'S';
                    vendor_site_record.error_record.error_message  := NULL;
                END IF;
            ELSIF (    vendor_site_record.error_record.error_status = 'E'
                   AND vendor_site_record.error_record.error_message = 'VEN_SITE_NOT_POR_SITE') THEN
                    vendor_site_record.error_record.error_status   := 'S';
                    vendor_site_record.error_record.error_message  := NULL;
            END IF;
            /* End of Fix for Bug 8643650 */

            IF vendor_site_record.error_record.error_status = 'E' THEN
                IF vendor_site_record.error_record.error_message IN('VEN_SITE_DISABLED', 'VEN_SITE_NOT_PURCH') THEN
		  /* Fix for bug 5953480, replicating and enhancing fix by
		     2830103.Validation for inactive vendor site and
		     vendor site not purchasable from anymore should happen
		     only for ASNs and ASBNs. Hence adding the IF condition
                     below so that no validation happens for STD receipts.
		     And in ELSE bock added we make error status as success,
		     so as to continue normally.
                  */
                  IF NVL(p_header_record.header_record.asn_type, 'STD') IN('ASN', 'ASBN', 'LCM') THEN /* lcm changes */
                    vendor_site_record.error_record.error_message  := 'PO_PDOI_INVALID_VENDOR_SITE';
                    rcv_error_pkg.set_error_message(vendor_site_record.error_record.error_message);
                    rcv_error_pkg.set_token('VALUE', vendor_site_record.vendor_site_id);
                    rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE',
                                                      'VENDOR_SITE_ID',
                                                      FALSE
                                                     );
		   ELSE
                    vendor_site_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_success;
                    vendor_site_record.error_record.error_message  := NULL;
                  END IF;

		  /*End of fix added for 5953480, while replicating fix by 2830103*/

		ELSIF vendor_site_record.error_record.error_message = 'VEN_SITE_ID' THEN
                    x_in_this_op_unit  := 1;

                    /*Start Bug#3359613 */
		    /* R12 Complex Work.
                     * Added WC to the if stmt below.
                    */
                    IF NVL(p_header_record.header_record.asn_type, 'STD') IN('ASN', 'ASBN','WC', 'LCM') THEN /* lcm changes */ --{
                        BEGIN
                            SELECT COUNT(*)
                            INTO   x_in_this_op_unit
                            FROM   po_headers poh,
                                   rcv_transactions_interface rti
                            WHERE  poh.vendor_id = p_header_record.header_record.vendor_id
                            AND    poh.segment1 = rti.document_num
                            AND    rti.header_interface_id = p_header_record.header_record.header_interface_id
                            AND    NVL(rti.source_document_code, 'PO') = 'PO';

                            asn_debug.put_line('The chance of this PO belonging to this operating unit is =' || TO_CHAR(x_in_this_op_unit));
                            asn_debug.put_line('Vendor Id is  =' || TO_CHAR(p_header_record.header_record.vendor_id));

                            IF x_in_this_op_unit = 0 THEN --{
                                asn_debug.put_line('Setting the RHI and RTI to Pending as this PO belongs to other operating unit ');
                                asn_debug.put_line('Updating for Header Interface Id = ' || TO_CHAR(p_header_record.header_record.header_interface_id));

                                UPDATE rcv_headers_interface
                                   SET processing_status_code = 'PENDING'
                                 WHERE header_interface_id = p_header_record.header_record.header_interface_id;

                                UPDATE rcv_transactions_interface
                                   SET processing_status_code = 'PENDING'
                                 WHERE header_interface_id = p_header_record.header_record.header_interface_id
                                AND    processing_status_code = 'RUNNING'
                                AND    processing_mode_code = 'BATCH';

                                p_header_record.error_record.error_status             := 'P';
                                p_header_record.header_record.processing_status_code  := 'PENDING';
                                p_header_record.error_record.error_message            := 'DIFFERENT_OU';

                                IF (g_asn_debug = 'Y') THEN
                                    asn_debug.put_line(vendor_site_record.error_record.error_status);
                                    asn_debug.put_line(vendor_site_record.error_record.error_message);
                                END IF;

                                IF (g_asn_debug = 'Y') THEN
                                    asn_debug.put_line('Validated vendor site info');
                                END IF;

                                RETURN;
                            else
                                /*
                                **9475696
                                **When this Supplier Site is not under the current OU, insert one error message in po_interface_errors.
                                */
                                vendor_site_record.error_record.error_message  := 'PO_PDOI_VENDOR_SITE_NOTFOUND';
                                rcv_error_pkg.set_error_message(vendor_site_record.error_record.error_message);
                                rcv_error_pkg.set_token('SUPPLIER_SITE', vendor_site_record.vendor_site_id);
                                rcv_error_pkg.set_token('OU', MO_GLOBAL.get_current_org_id());
                                rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE',
                                                                  'VENDOR_SITE_ID',
                                                                  FALSE );
                                /* end bug 9475696 */
                            END IF; -- x_in_this_op_unit = 0 --}
                        END;
                    ELSE --}{
                        /*End Bug#3359613 */
                        vendor_site_record.error_record.error_message  := 'PO_PDOI_INVALID_VENDOR_SITE';
                        rcv_error_pkg.set_error_message(vendor_site_record.error_record.error_message);
                        rcv_error_pkg.set_token('VALUE', vendor_site_record.vendor_site_id);
                        rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE',
                                                          'VENDOR_SITE_ID',
                                                          FALSE
                                                         );
                    END IF; -- Bug#3359613 NVL(p_header_record.header_record.asn_type,'STD') in ('ASN','ASBN')--}
                END IF;
            END IF;

            p_header_record.error_record.error_status      := vendor_site_record.error_record.error_status;
            p_header_record.error_record.error_message     := vendor_site_record.error_record.error_message;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line(vendor_site_record.error_record.error_status);
                asn_debug.put_line(vendor_site_record.error_record.error_message);
            END IF;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Validated vendor site info');
            END IF;
        END IF;
    END validate_vendor_site_info;

    PROCEDURE validate_asbn_specific_info(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
        invoice_record rcv_shipment_header_sv.invrectype;
        tax_record     rcv_shipment_header_sv.taxrectype;
    BEGIN
        /* Validate Invoice Amount > 0 */
        /* Invoice amount Vs Supplier Site Limit */
        IF     p_header_record.error_record.error_status IN('S', 'W')
           AND p_header_record.header_record.transaction_type <> 'CANCEL'
           AND p_header_record.header_record.asn_type = 'ASBN' THEN --{
            invoice_record.total_invoice_amount         := p_header_record.header_record.total_invoice_amount;
            invoice_record.vendor_id                    := p_header_record.header_record.vendor_id;
            invoice_record.vendor_site_id               := p_header_record.header_record.vendor_site_id;
            invoice_record.error_record.error_status    := p_header_record.error_record.error_status;
            invoice_record.error_record.error_message   := p_header_record.error_record.error_message;
            rcv_headers_interface_sv.validate_invoice_amount(invoice_record);

            IF invoice_record.error_record.error_status = 'E' THEN --{
                IF invoice_record.error_record.error_message = 'RCV_ASBN_INVOICE_AMT' THEN --{
                    rcv_error_pkg.set_error_message(invoice_record.error_record.error_message);
                    rcv_error_pkg.set_token('AMOUNT', invoice_record.total_invoice_amount);
                    rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE',
                                                      'TOTAL_INVOICE_AMOUNT',
                                                      FALSE
                                                     );
                ELSIF invoice_record.error_record.error_message = 'RCV_ASBN_INVOICE_AMT_LIMIT' THEN --} {
                    rcv_error_pkg.set_error_message(invoice_record.error_record.error_message);
                    rcv_error_pkg.set_token('AMOUNT', invoice_record.total_invoice_amount);
                    rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE',
                                                      'TOTAL_INVOICE_AMOUNT',
                                                      FALSE
                                                     );
                END IF; --} matches if invoice record error status E
            END IF;

            p_header_record.error_record.error_status   := invoice_record.error_record.error_status;
            p_header_record.error_record.error_message  := invoice_record.error_record.error_message;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Validated invoice amount');
            END IF;
        END IF;

        /* Validate that both Invoice number and shipment number are not missing */
        IF     p_header_record.error_record.error_status IN('S', 'W')
           AND p_header_record.header_record.transaction_type <> 'CANCEL'
           AND p_header_record.header_record.asn_type = 'ASBN' THEN --{
            IF     p_header_record.header_record.shipment_num IS NULL
               AND -- Should we assign shipment_num to null.invoice_num
                   p_header_record.header_record.invoice_num IS NULL THEN --{
                p_header_record.error_record.error_status   := 'E';
                p_header_record.error_record.error_message  := 'RCV_ASBN_INVOICE_NUM';
                rcv_error_pkg.set_error_message(p_header_record.error_record.error_message);
                rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE',
                                                  'INVOICE_NUM',
                                                  FALSE
                                                 );
            END IF; --}

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Validated invoice number/shipment number are not missing');
            END IF;
        END IF; --}

        /* Validate invoice_date is not missing */
        /* bug 628316 make sure invoice_date is not missing for ASBN */
        IF     p_header_record.error_record.error_status IN('S', 'W')
           AND p_header_record.header_record.transaction_type <> 'CANCEL'
           AND p_header_record.header_record.asn_type = 'ASBN' THEN --{
            IF p_header_record.header_record.invoice_date IS NULL THEN --{
                p_header_record.error_record.error_status   := 'E';
                p_header_record.error_record.error_message  := 'RCV_ASBN_INVOICE_DATE';
                rcv_error_pkg.set_error_message(p_header_record.error_record.error_message);
                rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE',
                                                  'INVOICE_DATE',
                                                  FALSE
                                                 );
            END IF; --}

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Validated invoice date is not missing');
            END IF;
        END IF; --}

        /* Validate Invoice Tax Code */
        IF     p_header_record.error_record.error_status IN('S', 'W')
           AND p_header_record.header_record.transaction_type <> 'CANCEL'
           AND p_header_record.header_record.asn_type = 'ASBN' THEN --{
            IF p_header_record.header_record.tax_name IS NOT NULL THEN --{
                tax_record.tax_name                         := p_header_record.header_record.tax_name;
                tax_record.tax_amount                       := p_header_record.header_record.tax_amount;
                tax_record.error_record.error_status        := p_header_record.error_record.error_status;
                tax_record.error_record.error_message       := p_header_record.error_record.error_message;
                po_locations_s.validate_tax_info(tax_record);

                IF tax_record.error_record.error_status = 'E' THEN --{
                    IF tax_record.error_record.error_message IN('TAX_CODE_INVALID', 'TAX_CODE_DISABLED') THEN --{
                        tax_record.error_record.error_message  := 'PO_PDOI_INVALID_TAX_NAME';
                        rcv_error_pkg.set_error_message(tax_record.error_record.error_message);
                        rcv_error_pkg.set_token('VALUE', tax_record.tax_name);
                        rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE',
                                                          'TAX_NAME',
                                                          FALSE
                                                         );
                    END IF; --}
                END IF; --} matches error status =E

                p_header_record.error_record.error_status   := tax_record.error_record.error_status;
                p_header_record.error_record.error_message  := tax_record.error_record.error_message;
            END IF; --}

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Validated tax info');
            END IF;
        END IF; --}

        /* Validations on shipment number */
        IF p_header_record.error_record.error_status IN('S', 'W') THEN
            -- rcv_core_s.validate_shipment_number(p_header_record);
            validate_shipment_number(p_header_record);

            IF p_header_record.error_record.error_status = 'E' THEN --{
                IF p_header_record.error_record.error_message IN('RCV_NO_MATCHING_ASN', 'RCV_ASN_MISMATCH_SHIP_ID', 'RCV_ASN_QTY_RECEIVED') THEN --{
                    rcv_error_pkg.set_error_message(p_header_record.error_record.error_message);
                    rcv_error_pkg.set_token('SHIPMENT', p_header_record.header_record.shipment_num);
                    rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE',
                                                      'SHIPMENT_NUM',
                                                      FALSE
                                                     );
                ELSIF p_header_record.error_record.error_message = 'RCV_NO_SHIPMENT_NUM' THEN --} {
                    rcv_error_pkg.set_error_message(p_header_record.error_record.error_message);
                    rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE',
                                                      'SHIPMENT_NUM',
                                                      FALSE
                                                     );
                ELSIF p_header_record.error_record.error_message = 'RCV_RCV_BEFORE_ASN' THEN --} {
                    rcv_error_pkg.set_error_message(p_header_record.error_record.error_message);
                    rcv_error_pkg.set_token('SHIPMENT', p_header_record.header_record.shipment_num);
                    rcv_error_pkg.set_token('ITEM', '');
                    rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE',
                                                      'SHIPMENT_NUM',
                                                      FALSE
                                                     );
                /* Bug# 1413880
                As per the manual Shipment number should be unique for one year period for
                given supplier. Commenting out lines below */

                --      END IF;
                --    ELSIF p_header_record.error_record.error_status = 'W' then
                ELSIF p_header_record.error_record.error_message = 'RCV_DUP_SHIPMENT_NUM' THEN --}{
                    p_header_record.error_record.error_message  := 'PO_PDOI_SHIPMENT_NUM_UNIQUE';
                    rcv_error_pkg.set_error_message(p_header_record.error_record.error_message);
                    rcv_error_pkg.set_token('VALUE', p_header_record.header_record.shipment_num);
                    rcv_error_pkg.log_interface_warning('RCV_HEADERS_INTERFACE', 'SHIPMENT_NUM');
                END IF; --}
            END IF;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line(p_header_record.header_record.shipment_num);
                asn_debug.put_line('Validations for shipment_number');
            END IF;
        END IF; --}
    END validate_asbn_specific_info;

    PROCEDURE validate_shipment_number(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
        x_shipment_header_id NUMBER;
    BEGIN
        -- Check for shipment number which is null, blank , zero
        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Check for shipment number which is null, blank , zero ');
        END IF;

        /*dbms_output.put_line(nvl(p_header_record.header_record.shipment_num,'@@@'));*/
        /* R12 Complex Work.
         * Add WC in addition to ASN and ASBN to validate unique
         * shipment numbers.
        */
        IF     p_header_record.header_record.asn_type IN('ASN', 'ASBN','WC', 'LCM') /* lcm changes */
           AND (   p_header_record.header_record.shipment_num IS NULL
                OR p_header_record.header_record.shipment_num = '0'
                OR REPLACE(p_header_record.header_record.shipment_num,
                           ' ',
                           ''
                          ) IS NULL) THEN
            p_header_record.error_record.error_status   := 'E';
            p_header_record.error_record.error_message  := 'RCV_NO_SHIPMENT_NUM';
            RETURN;
        END IF;

        -- Check for Receipts before ASN
        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Check for Receipts before ASN ');
        END IF;

         /*
         * BUGNO: 1708017
         * The where clause used to have organization_id =
         * p_header_record.header_record.ship_to_organization_id
         * This used to be populated with ship_to_organization_id.
         * Now this is populated as null since it is supposed to
         * be from organization_id. So changed it to ship_to_org_id.
        */
        /* Bug 2485699- commented the condn trunc(Shipped_date) = trunc(header.record.shipped_date).
           Added  the shipped date is null since we are not populating the same in rcv_shipment_headers
          while receiving thru forms.*/
        /* R12 Complex Work.
         * Add WC in addition to ASN and ASBN to validate unique
         * shipment numbers.
        */
        IF     p_header_record.header_record.asn_type IN('ASN', 'ASBN','WC', 'LCM') /* lcm changes */
           AND p_header_record.header_record.transaction_type <> 'CANCEL' THEN -- added this for CANCEL
            SELECT COUNT(*)
            INTO   x_count
            FROM   rcv_shipment_headers
            WHERE  NVL(vendor_site_id, -9999) = NVL(p_header_record.header_record.vendor_site_id, -9999)
            AND    vendor_id = p_header_record.header_record.vendor_id
            AND --trunc(shipped_date) = trunc(p_header_record.header_record.shipped_date) and
                   (   shipped_date IS NULL
                    OR shipped_date >= ADD_MONTHS(x_sysdate, -12))
            AND    shipment_num = p_header_record.header_record.shipment_num
            AND    ship_to_org_id = p_header_record.header_record.ship_to_organization_id
            AND    receipt_num IS NOT NULL;

            IF x_count > 0 THEN
                p_header_record.error_record.error_status   := 'E';
                p_header_record.error_record.error_message  := 'RCV_RCV_BEFORE_ASN';
                RETURN;
            END IF;
        END IF;

        -- Change transaction_type to NEW if transaction_type is REPLACE and
        -- we cannot locate the shipment notice for the vendor site with the
        -- same shipped date
         /*
         * BUGNO: 1708017
         * The where clause used to have organization_id =
         * p_header_record.header_record.ship_to_organization_id
         * This used to be populated with ship_to_organization_id.
         * Now this is populated as null since it is supposed to
         * be from organization_id. So changed it to ship_to_org_id.
        */
        IF p_header_record.header_record.transaction_type = 'REPLACE' THEN
            SELECT COUNT(*)
            INTO   x_count
            FROM   rcv_shipment_headers
            WHERE  NVL(vendor_site_id, -9999) = NVL(p_header_record.header_record.vendor_site_id, -9999)
            AND    vendor_id = p_header_record.header_record.vendor_id
            AND    TRUNC(shipped_date) = TRUNC(p_header_record.header_record.shipped_date)
            AND    shipped_date >= ADD_MONTHS(x_sysdate, -12)
            AND    ship_to_org_id = p_header_record.header_record.ship_to_organization_id
            AND    shipment_num = p_header_record.header_record.shipment_num;

            IF x_count = 0 THEN
                p_header_record.header_record.transaction_type  := 'NEW';
            END IF;
        END IF;

        -- Check for any shipment_num which exist for the same vendor site and within a year
        -- of the previous shipment with the same num. This is only done for transaction_type = NEW
         /*
         * BUGNO: 1708017
         * The where clause used to have organization_id =
         * p_header_record.header_record.ship_to_organization_id
         * This used to be populated with ship_to_organization_id.
         * Now this is populated as null since it is supposed to
         * be from organization_id. So changed it to ship_to_org_id.
        */

        /* Fix for bug 2682881.
            * No validation on shipment_num was happening if a new ASN
            * is created with the same supplier,supplier site, shipment
            * num, but with different shipped_date. Shipment_num should
            * be unique from the supplier,supplier site for a period of
            * one year. Hence commented the condition "trunc(shipped_date)
            * = trunc(p_header_record.header_record.shipped_date) and"
            * from the following sql which is not required.
       */
        IF     p_header_record.header_record.transaction_type = 'NEW'
           AND p_header_record.header_record.asn_type IN('ASN', 'ASBN', 'LCM') THEN /* lcm changes */
            SELECT COUNT(*)
            INTO   x_count
            FROM   rcv_shipment_headers
            WHERE  NVL(vendor_site_id, -9999) = NVL(p_header_record.header_record.vendor_site_id, -9999)
            AND    vendor_id = p_header_record.header_record.vendor_id
            AND    ship_to_org_id = p_header_record.header_record.ship_to_organization_id
            AND    shipment_num = p_header_record.header_record.shipment_num
            AND --trunc(shipped_date) = trunc(p_header_record.header_record.shipped_date) and
                   shipped_date >= ADD_MONTHS(x_sysdate, -12);

            IF x_count > 0 THEN
                /* Bug# 1413880
                   As per the manual Shipment number should be unique for one year period for
                   given supplier.Changing Warning to Error.  */
                p_header_record.error_record.error_status   := 'E';
                p_header_record.error_record.error_message  := 'RCV_DUP_SHIPMENT_NUM';
                RETURN;
            END IF;
        END IF;

        /*bug 2123721. bgopired
        We were not checking the uniqueness of shipment number incase of
        Standard Receipts. Used the same logic of Enter Receipt form to check
        the uniqueness */
        IF     p_header_record.header_record.transaction_type = 'NEW'
           AND p_header_record.header_record.asn_type IN('STD') THEN
            IF NOT rcv_core_s.val_unique_shipment_num(p_header_record.header_record.shipment_num, p_header_record.header_record.vendor_id) THEN
                p_header_record.error_record.error_status   := 'E';
                p_header_record.error_record.error_message  := 'RCV_DUP_SHIPMENT_NUM';
                RETURN;
            END IF;
        END IF;

        -- Check for matching ASN if ADD, CANCEL
        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Check for matching ASN if ADD, CANCEL');
        END IF;

        /*
         * BUGNO: 1708017
         * The where clause used to have organization_id =
         * p_header_record.header_record.ship_to_organization_id
         * This used to be populated with ship_to_organization_id.
         * Now this is populated as null since it is supposed to
         * be from organization_id. So changed it to ship_to_org_id.
        */
        IF     p_header_record.header_record.transaction_type IN('ADD', 'CANCEL')
           AND p_header_record.header_record.asn_type IN('ASN', 'ASBN') THEN
            SELECT COUNT(*)
            INTO   x_count
            FROM   rcv_shipment_headers
            WHERE  NVL(vendor_site_id, -9999) = NVL(p_header_record.header_record.vendor_site_id, -9999)
            AND    vendor_id = p_header_record.header_record.vendor_id
            AND    ship_to_org_id = p_header_record.header_record.ship_to_organization_id
            AND    shipment_num = p_header_record.header_record.shipment_num
            AND    TRUNC(shipped_date) = TRUNC(p_header_record.header_record.shipped_date)
            AND    shipped_date >= ADD_MONTHS(x_sysdate, -12);

            IF x_count = 0 THEN
                p_header_record.error_record.error_status   := 'E';
                p_header_record.error_record.error_message  := 'RCV_NO_MATCHING_ASN';
                RETURN;
            END IF;
        END IF;

        -- Check that there are no receipts against the ASN for ADD, CANCEL
        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Check that there are no receipts against the ASN for ADD, CANCEL');
        END IF;

        IF     p_header_record.header_record.transaction_type IN('ADD', 'CANCEL')
           AND p_header_record.header_record.asn_type IN('ASN', 'ASBN') THEN
            IF p_header_record.header_record.receipt_header_id IS NOT NULL THEN
                SELECT SUM(quantity_received)
                INTO   x_count
                FROM   rcv_shipment_lines
                WHERE  rcv_shipment_lines.shipment_header_id = p_header_record.header_record.receipt_header_id;
            ELSE
                /*
             * BUGNO: 1708017
             * The where clause used to have organization_id =
             * p_header_record.header_record.ship_to_organization_id
             * This used to be populated with ship_to_organization_id.
             * Now this is populated as null since it is supposed to
             * be from organization_id. So changed it to ship_to_org_id.
             */
                SELECT SUM(quantity_received)
                INTO   x_count
                FROM   rcv_shipment_lines
                WHERE  EXISTS(SELECT 'x'
                              FROM   rcv_shipment_headers
                              WHERE  rcv_shipment_headers.shipment_header_id = rcv_shipment_lines.shipment_header_id
                              AND    NVL(vendor_site_id, -9999) = NVL(p_header_record.header_record.vendor_site_id, -9999)
                              AND    vendor_id = p_header_record.header_record.vendor_id
                              AND    ship_to_org_id = p_header_record.header_record.ship_to_organization_id
                              AND    shipment_num = p_header_record.header_record.shipment_num
                              AND    TRUNC(shipped_date) = TRUNC(p_header_record.header_record.shipped_date)
                              AND    shipped_date >= ADD_MONTHS(x_sysdate, -12));
            END IF;

            IF NVL(x_count, 0) > 0 THEN -- Some quantity has been received
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('There are receipts against the ASN ' || p_header_record.header_record.shipment_num);
                END IF;

                p_header_record.error_record.error_status   := 'E';
                p_header_record.error_record.error_message  := 'RCV_ASN_QTY_RECEIVED';
                RETURN;
            END IF;
        END IF;

        -- If we have reached this place that means the shipment exists
        -- Make sure we have a shipment header id
        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Make sure we have a shipment_header_id');
        END IF;

        /*
         * BUGNO: 1708017
         * The where clause used to have organization_id =
         * p_header_record.header_record.ship_to_organization_id
         * This used to be populated with ship_to_organization_id.
         * Now this is populated as null since it is supposed to
         * be from organization_id. So changed it to ship_to_org_id.
        */
        IF     p_header_record.header_record.transaction_type IN('CANCEL')
           AND p_header_record.header_record.receipt_header_id IS NULL THEN
            SELECT MAX(shipment_header_id)
            INTO   p_header_record.header_record.receipt_header_id
            FROM   rcv_shipment_headers
            WHERE  NVL(vendor_site_id, -9999) = NVL(p_header_record.header_record.vendor_site_id, -9999)
            AND    vendor_id = p_header_record.header_record.vendor_id
            AND    ship_to_org_id = p_header_record.header_record.ship_to_organization_id
            AND    shipment_num = p_header_record.header_record.shipment_num
            AND    TRUNC(shipped_date) = TRUNC(p_header_record.header_record.shipped_date)
            AND    shipped_date >= ADD_MONTHS(x_sysdate, -12);
        END IF;

        -- Verify that the shipment_header_id matches the derived/defaulted shipment_header_id
        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Verify that the shipment_header_id matches the derived/defaulted shipment_header_id');
        END IF;

        /*
         * BUGNO: 1708017
         * The where clause used to have organization_id =
         * p_header_record.header_record.ship_to_organization_id
         * This used to be populated with ship_to_organization_id.
         * Now this is populated as null since it is supposed to
         * be from organization_id. So changed it to ship_to_org_id.
        */
        IF     p_header_record.header_record.transaction_type IN('CANCEL')
           AND p_header_record.header_record.receipt_header_id IS NOT NULL THEN
            SELECT MAX(shipment_header_id)
            INTO   x_shipment_header_id
            FROM   rcv_shipment_headers
            WHERE  NVL(vendor_site_id, -9999) = NVL(p_header_record.header_record.vendor_site_id, -9999)
            AND    vendor_id = p_header_record.header_record.vendor_id
            AND    ship_to_org_id = p_header_record.header_record.ship_to_organization_id
            AND    shipment_num = p_header_record.header_record.shipment_num
            AND    TRUNC(shipped_date) = TRUNC(p_header_record.header_record.shipped_date)
            AND    shipped_date >= ADD_MONTHS(x_sysdate, -12);

            IF x_shipment_header_id <> p_header_record.header_record.receipt_header_id THEN
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('The shipment_header_id do not match ');
                END IF;

                p_header_record.error_record.error_status   := 'E';
                p_header_record.error_record.error_message  := 'RCV_ASN_MISMATCH_SHIP_ID';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Exception in validate_shipment_header ');
            END IF;

            p_header_record.error_record.error_status   := 'U';
            p_header_record.error_record.error_message  := SQLERRM;
    END validate_shipment_number;

    PROCEDURE insert_shipment_header(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        -- Set asn_type to null if asn_type is STD as the UI gets confused

        IF NVL(p_header_record.header_record.asn_type, 'STD') = 'STD' THEN
            p_header_record.header_record.asn_type  := NULL;
        END IF;

        /* Bug - 1086088 - Ship_to_org_id needs to get populated in the
        *  RCV_SHIPMENT_HEADERS table      */
        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Before insert into rsh ');
        END IF;

        INSERT INTO rcv_shipment_headers
                    (shipment_header_id,
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     last_update_login,
                     receipt_source_code,
                     vendor_id,
                     vendor_site_id,
                     organization_id,
                     shipment_num,
                     receipt_num,
                     ship_to_location_id,
                     ship_to_org_id,
                     bill_of_lading,
                     packing_slip,
                     shipped_date,
                     freight_carrier_code,
                     expected_receipt_date,
                     employee_id,
                     num_of_containers,
                     waybill_airbill_num,
                     comments,
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
                     ussgl_transaction_code,
                     government_context,
                     request_id,
                     program_application_id,
                     program_id,
                     program_update_date,
                     asn_type,
                     edi_control_num,
                     notice_creation_date,
                     gross_weight,
                     gross_weight_uom_code,
                     net_weight,
                     net_weight_uom_code,
                     tar_weight,
                     tar_weight_uom_code,
                     packaging_code,
                     carrier_method,
                     carrier_equipment,
                     carrier_equipment_num,
                     carrier_equipment_alpha,
                     special_handling_code,
                     hazard_code,
                     hazard_class,
                     hazard_description,
                     freight_terms,
                     freight_bill_number,
                     invoice_date,
                     invoice_amount,
                     tax_name,
                     tax_amount,
                     freight_amount,
                     invoice_status_code,
                     asn_status,
                     currency_code,
                     conversion_rate_type,
                     conversion_rate,
                     conversion_date,
                     payment_terms_id,
                     invoice_num,
                     remit_to_site_id,
                     ship_from_location_id,
		     performance_period_from, --Complex Work
                     performance_period_to,    --Complex Work
                     request_date             --Complex Work
                    )
             VALUES (p_header_record.header_record.receipt_header_id,
                     p_header_record.header_record.last_update_date,
                     p_header_record.header_record.last_updated_by,
                     p_header_record.header_record.creation_date,
                     p_header_record.header_record.created_by,
                     p_header_record.header_record.last_update_login,
                     p_header_record.header_record.receipt_source_code,
                     p_header_record.header_record.vendor_id,
                     p_header_record.header_record.vendor_site_id,
                     TO_NUMBER(NULL), -- this is the from organization id and shld be null instead of ship_to_org_id
                     p_header_record.header_record.shipment_num,
                     p_header_record.header_record.receipt_num,
                     p_header_record.header_record.location_id,
                     p_header_record.header_record.ship_to_organization_id,
                     p_header_record.header_record.bill_of_lading,
                     p_header_record.header_record.packing_slip,
                     p_header_record.header_record.shipped_date,
                     p_header_record.header_record.freight_carrier_code,
                     p_header_record.header_record.expected_receipt_date,
                     p_header_record.header_record.employee_id,
                     p_header_record.header_record.num_of_containers,
                     p_header_record.header_record.waybill_airbill_num,
                     p_header_record.header_record.comments,
                     p_header_record.header_record.attribute_category,
                     p_header_record.header_record.attribute1,
                     p_header_record.header_record.attribute2,
                     p_header_record.header_record.attribute3,
                     p_header_record.header_record.attribute4,
                     p_header_record.header_record.attribute5,
                     p_header_record.header_record.attribute6,
                     p_header_record.header_record.attribute7,
                     p_header_record.header_record.attribute8,
                     p_header_record.header_record.attribute9,
                     p_header_record.header_record.attribute10,
                     p_header_record.header_record.attribute11,
                     p_header_record.header_record.attribute12,
                     p_header_record.header_record.attribute13,
                     p_header_record.header_record.attribute14,
                     p_header_record.header_record.attribute15,
                     p_header_record.header_record.usggl_transaction_code,
                     NULL, -- p_header_record.header_record.Government_Context
                     fnd_global.conc_request_id,
                     fnd_global.prog_appl_id,
                     fnd_global.conc_program_id,
                     x_sysdate,
                     p_header_record.header_record.asn_type,
                     p_header_record.header_record.edi_control_num,
                     p_header_record.header_record.notice_creation_date,
                     p_header_record.header_record.gross_weight,
                     p_header_record.header_record.gross_weight_uom_code,
                     p_header_record.header_record.net_weight,
                     p_header_record.header_record.net_weight_uom_code,
                     p_header_record.header_record.tar_weight,
                     p_header_record.header_record.tar_weight_uom_code,
                     p_header_record.header_record.packaging_code,
                     p_header_record.header_record.carrier_method,
                     p_header_record.header_record.carrier_equipment,
                     NULL, -- p_header_record.header_record.Carrier_Equipment_Num
                     NULL, -- p_header_record.header_record.Carrier_Equipment_Alpha
                     p_header_record.header_record.special_handling_code,
                     p_header_record.header_record.hazard_code,
                     p_header_record.header_record.hazard_class,
                     p_header_record.header_record.hazard_description,
                     p_header_record.header_record.freight_terms,
                     p_header_record.header_record.freight_bill_number,
                     p_header_record.header_record.invoice_date,
                     p_header_record.header_record.total_invoice_amount,
                     p_header_record.header_record.tax_name,
                     p_header_record.header_record.tax_amount,
                     p_header_record.header_record.freight_amount,
                     p_header_record.header_record.invoice_status_code,
                     'NEW_SHIP', -- p_header_record.header_record.Asn_Status
                     p_header_record.header_record.currency_code,
                     p_header_record.header_record.conversion_rate_type,
                     p_header_record.header_record.conversion_rate,
                     p_header_record.header_record.conversion_rate_date,
                     p_header_record.header_record.payment_terms_id,
                     p_header_record.header_record.invoice_num,
                     p_header_record.header_record.remit_to_site_id,
                     p_header_record.header_record.ship_from_location_id,
		     /* Complex Work. Added new columns */
                     p_header_record.header_record.performance_period_from,
                     p_header_record.header_record.performance_period_to,
                     p_header_record.header_record.request_date
                    );

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('After insert into rsh ');
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Exception in insert_shipment_header ');
            END IF;

            p_header_record.error_record.error_status   := 'U';
            p_header_record.error_record.error_message  := SQLERRM;
    END insert_shipment_header;

    PROCEDURE update_shipment_header(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Enter in update_shipment_header ');
            asn_debug.put_line(' Shipment_header_id  ' || p_header_record.header_record.receipt_header_id);
        END IF;

        UPDATE rcv_shipment_headers
           SET receipt_num = NVL(receipt_num, p_header_record.header_record.receipt_num),
               bill_of_lading = p_header_record.header_record.bill_of_lading,
               packing_slip = p_header_record.header_record.packing_slip,
               freight_carrier_code = p_header_record.header_record.freight_carrier_code,
               expected_receipt_date = p_header_record.header_record.expected_receipt_date,
               employee_id = p_header_record.header_record.employee_id,
               num_of_containers = p_header_record.header_record.num_of_containers,
               waybill_airbill_num = p_header_record.header_record.waybill_airbill_num,
               comments = p_header_record.header_record.comments,
               attribute1 = p_header_record.header_record.attribute1,
               attribute2 = p_header_record.header_record.attribute2,
               attribute3 = p_header_record.header_record.attribute3,
               attribute4 = p_header_record.header_record.attribute4,
               attribute5 = p_header_record.header_record.attribute5,
               attribute6 = p_header_record.header_record.attribute6,
               attribute7 = p_header_record.header_record.attribute7,
               attribute8 = p_header_record.header_record.attribute8,
               attribute9 = p_header_record.header_record.attribute9,
               attribute10 = p_header_record.header_record.attribute10,
               attribute11 = p_header_record.header_record.attribute11,
               attribute12 = p_header_record.header_record.attribute12,
               attribute13 = p_header_record.header_record.attribute13,
               attribute14 = p_header_record.header_record.attribute14,
               attribute15 = p_header_record.header_record.attribute15
         WHERE shipment_header_id = p_header_record.header_record.receipt_header_id;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('After updating rsh ');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Exception in update_shipment_header ');
            END IF;

            p_header_record.error_record.error_status   := 'U';
            p_header_record.error_record.error_message  := SQLERRM;
    END update_shipment_header;

    PROCEDURE insert_cancelled_asn_lines(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        -- delete any asn lines that have been sent

        asn_debug.put_line('Delete any asn lines that have been sent');

        DELETE FROM rcv_transactions_interface
              WHERE header_interface_id = p_header_record.header_record.header_interface_id;

        -- Insert lines from rcv_shipment_lines into rcv_transactions_interface

        -- Make sure we don't inset cancelled lines and lines that are waiting to
        -- be cancelled in rti
        -- The transaction processor will then cancel the lines

        -- Bug 587603 Inserting processing request id for CANCEL otherwise
        -- transaction processor will not look at it.

        /* <R12 MOAC START>
         * Populate the org_id column in rcv_transactions_interface with org_id from
         * po_headers_all table
         */

        INSERT INTO rcv_transactions_interface
                    (interface_transaction_id,
                     header_interface_id,
                     GROUP_ID,
                     last_update_date,
                     last_updated_by,
                     last_update_login,
                     creation_date,
                     created_by,
                     transaction_type,
                     transaction_date,
                     processing_status_code,
                     processing_mode_code,
                     transaction_status_code,
                     category_id,
                     quantity,
                     unit_of_measure,
                     interface_source_code,
                     item_id,
                     item_description,
                     employee_id,
                     auto_transact_code,
                     receipt_source_code,
                     vendor_id,
                     to_organization_id,
                     source_document_code,
                     po_header_id,
                     po_line_id,
                     po_line_location_id,
                     shipment_header_id,
                     shipment_line_id,
                     destination_type_code,
                     processing_request_id,
                     org_id
                    )
            SELECT rcv_transactions_interface_s.NEXTVAL,
                   p_header_record.header_record.header_interface_id,
                   p_header_record.header_record.GROUP_ID,
                   p_header_record.header_record.last_update_date,
                   p_header_record.header_record.last_updated_by,
                   p_header_record.header_record.last_update_login,
                   p_header_record.header_record.creation_date,
                   p_header_record.header_record.created_by,
                   'CANCEL',
                   NVL(p_header_record.header_record.notice_creation_date, SYSDATE),
                   'RUNNING',           -- This has to be set to running otherwise C code in rvtbm
                              -- will not pick it up
                   'BATCH',
                   'PENDING',
                   rsl.category_id,
                   rsl.quantity_shipped,
                   rsl.unit_of_measure,
                   'RCV',
                   rsl.item_id,
                   rsl.item_description,
                   rsl.employee_id,
                   'CANCEL',
                   'VENDOR',
                   p_header_record.header_record.vendor_id,
                   rsl.to_organization_id,
                   'PO',
                   rsl.po_header_id,
                   rsl.po_line_id,
                   rsl.po_line_location_id,
                   rsl.shipment_header_id,
                   rsl.shipment_line_id,
                   rsl.destination_type_code,
                   p_header_record.header_record.processing_request_id,
                   poh.org_id
            FROM   rcv_shipment_lines rsl,
                   po_headers_all poh
            WHERE  rsl.shipment_header_id = p_header_record.header_record.receipt_header_id
            AND    rsl.shipment_line_status_code <> 'CANCELLED'
            AND    rsl.po_header_id = poh.po_header_id
            AND    NOT EXISTS(SELECT 'x'
                              FROM   rcv_transactions_interface rti
                              WHERE  rti.shipment_line_id = rsl.shipment_line_id
                              AND    rti.shipment_header_id = rsl.shipment_header_id
                              AND    rti.transaction_type = 'CANCEL'
                              AND    rti.shipment_header_id = p_header_record.header_record.receipt_header_id);
        --<R12 MOAC END>
    END insert_cancelled_asn_lines;
END rcv_roi_header;

/
