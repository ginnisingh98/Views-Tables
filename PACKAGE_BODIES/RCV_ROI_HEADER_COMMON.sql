--------------------------------------------------------
--  DDL for Package Body RCV_ROI_HEADER_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_ROI_HEADER_COMMON" 
/* $Header: RCVOIHCB.pls 120.14.12010000.14 2012/04/10 11:06:34 sadibhat ship $ */
AS
    from_org_record    rcv_shipment_object_sv.organization_id_record_type;
    ship_to_org_record rcv_shipment_object_sv.organization_id_record_type;
    loc_record         rcv_shipment_object_sv.location_id_record_type;
    emp_record         rcv_shipment_object_sv.employee_id_record_type;
    pay_record         rcv_shipment_header_sv.payrectype;
    freight_record     rcv_shipment_header_sv.freightrectype;
    lookup_record      rcv_shipment_header_sv.lookuprectype;
    currency_record    rcv_shipment_header_sv.currectype;
    invoice_record     rcv_shipment_header_sv.invrectype;
    tax_record         rcv_shipment_header_sv.taxrectype;
    -- Read the profile option that enables/disables the debug log
    g_asn_debug        VARCHAR2(1)                                        := asn_debug.is_debug_on;  -- Bug 9152790: rcv debug enhancement
    x_sysdate          DATE                                               := SYSDATE;
    x_count            NUMBER                                             := 0;
    x_location_id      NUMBER;
    e_validation_error EXCEPTION;

    PROCEDURE derive_ship_to_org_info(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        /* Derive Ship To Organization Information
         * organization_id is uk. org_organization_definitions is a view */
        IF p_header_record.error_record.error_status IN('S', 'W') THEN
            /*
             ** If the shipment header ship to organization code is null then try
             ** to pull it off the rcv_transactions_interface to_organization_code or
             ** the ship_to_location_code.
            */
            IF (    p_header_record.header_record.ship_to_organization_code IS NULL
                AND p_header_record.header_record.ship_to_organization_id IS NULL) THEN
                derive_ship_to_org_from_rti(p_header_record);
            END IF;

            ship_to_org_record.organization_code                     := p_header_record.header_record.ship_to_organization_code;
            ship_to_org_record.organization_id                       := p_header_record.header_record.ship_to_organization_id;
            ship_to_org_record.error_record.error_status             := p_header_record.error_record.error_status;
            ship_to_org_record.error_record.error_message            := p_header_record.error_record.error_message;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('In Ship to Organization Procedure');
            END IF;

            po_orgs_sv.derive_org_info(ship_to_org_record);

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line(ship_to_org_record.organization_code);
                asn_debug.put_line(TO_CHAR(ship_to_org_record.organization_id));
                asn_debug.put_line(ship_to_org_record.error_record.error_status);
            END IF;

            p_header_record.header_record.ship_to_organization_code  := ship_to_org_record.organization_code;
            p_header_record.header_record.ship_to_organization_id    := ship_to_org_record.organization_id;
            p_header_record.error_record.error_status                := ship_to_org_record.error_record.error_status;
            p_header_record.error_record.error_message               := ship_to_org_record.error_record.error_message;
        END IF;
    END derive_ship_to_org_info;

    PROCEDURE derive_from_org_info(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        /* derive from organization information */
        IF     p_header_record.error_record.error_status IN('S', 'W')
           AND p_header_record.header_record.transaction_type <> 'CANCEL' THEN -- added for support of cancel
            from_org_record.organization_code                     := p_header_record.header_record.from_organization_code;
            from_org_record.organization_id                       := p_header_record.header_record.from_organization_id;
            from_org_record.error_record.error_status             := p_header_record.error_record.error_status;
            from_org_record.error_record.error_message            := p_header_record.error_record.error_message;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('In From Organization Procedure');
            END IF;

            po_orgs_sv.derive_org_info(from_org_record);

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line(from_org_record.organization_code);
                asn_debug.put_line(TO_CHAR(from_org_record.organization_id));
                asn_debug.put_line(from_org_record.error_record.error_status);
            END IF;

            p_header_record.header_record.from_organization_code  := from_org_record.organization_code;
            p_header_record.header_record.from_organization_id    := from_org_record.organization_id;
            p_header_record.error_record.error_status             := from_org_record.error_record.error_status;
            p_header_record.error_record.error_message            := from_org_record.error_record.error_message;
        END IF;
    END derive_from_org_info;

    PROCEDURE derive_location_info(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
         /* Derive Location Information */
        /* HR_LOCATION has 2 unique indexes
          1 -> location_id
           2 -> location_code */
        IF (    p_header_record.error_record.error_status IN('S', 'W')
            AND (   p_header_record.header_record.location_code IS NOT NULL
                 OR p_header_record.header_record.location_id IS NOT NULL)) THEN
            loc_record.location_code                     := p_header_record.header_record.location_code;
            loc_record.location_id                       := p_header_record.header_record.location_id;
            loc_record.error_record.error_status         := p_header_record.error_record.error_status;
            loc_record.error_record.error_message        := p_header_record.error_record.error_message;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('In Location Code Procedure');
            END IF;

            po_locations_s.derive_location_info(loc_record);

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line(loc_record.location_code);
                asn_debug.put_line(TO_CHAR(loc_record.location_id));
                asn_debug.put_line(loc_record.error_record.error_status);
            END IF;

            p_header_record.header_record.location_code  := loc_record.location_code;
            p_header_record.header_record.location_id    := loc_record.location_id;
            p_header_record.error_record.error_status    := loc_record.error_record.error_status;
            p_header_record.error_record.error_message   := loc_record.error_record.error_message;
        END IF;
    END derive_location_info;

    PROCEDURE derive_payment_terms_info(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
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

    PROCEDURE derive_receiver_info(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        IF     p_header_record.error_record.error_status IN('S', 'W')
           AND p_header_record.header_record.transaction_type <> 'CANCEL'
           AND -- added for support of cancel
               (   p_header_record.header_record.employee_name IS NOT NULL
                OR p_header_record.header_record.employee_id IS NOT NULL) THEN
            emp_record.employee_name                     := p_header_record.header_record.employee_name;
            emp_record.employee_id                       := p_header_record.header_record.employee_id;
            emp_record.error_record.error_status         := p_header_record.error_record.error_status;
            emp_record.error_record.error_message        := p_header_record.error_record.error_message;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('In Derive Receiver Information');
            END IF;

            po_employees_sv.derive_employee_info(emp_record);

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line(emp_record.employee_name);
                asn_debug.put_line(TO_CHAR(emp_record.employee_id));
                asn_debug.put_line(emp_record.error_record.error_status);
            END IF;

            p_header_record.header_record.employee_name  := emp_record.employee_name;
            p_header_record.header_record.employee_id    := emp_record.employee_id;
            p_header_record.error_record.error_status    := emp_record.error_record.error_status;
            p_header_record.error_record.error_message   := emp_record.error_record.error_message;
        END IF;
    END derive_receiver_info;

    PROCEDURE derive_shipment_header_id(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        /* Derive shipment_header_id if transaction type = CANCEL */

        -- added for support of cancel

        IF     p_header_record.error_record.error_status IN('S', 'W')
           AND p_header_record.header_record.transaction_type = 'CANCEL'
           AND p_header_record.header_record.shipment_num IS NOT NULL THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Derive shipment info');
            END IF;

             --rcv_core_s.derive_shipment_info(p_header_record);
            /* block from rcv_core_s.derive_shipment_info */
            IF p_header_record.header_record.receipt_header_id IS NULL THEN
                BEGIN
                    SELECT MAX(shipment_header_id) -- if we ever have 2 shipments with the same combo
                    INTO   p_header_record.header_record.receipt_header_id
                    FROM   rcv_shipment_headers
                    WHERE  NVL(vendor_site_id, -9999) = NVL(p_header_record.header_record.vendor_site_id, -9999)
                    AND    vendor_id = p_header_record.header_record.vendor_id
                    AND    ship_to_org_id = p_header_record.header_record.ship_to_organization_id
                    AND    shipment_num = p_header_record.header_record.shipment_num
                    AND    shipped_date >= ADD_MONTHS(p_header_record.header_record.shipped_date, -12);
                EXCEPTION
                    WHEN OTHERS THEN
                        IF (g_asn_debug = 'Y') THEN
                            asn_debug.put_line(SQLERRM);
                        END IF;
                END;
            ELSE
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Need to put a cursor to retrieve other values');
                    asn_debug.put_line('Shipment header Id has been provided');
                END IF;
            END IF;

            RETURN;
        -- end of the block

        END IF;
    END derive_shipment_header_id;

    PROCEDURE derive_ship_to_org_from_rti(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
        x_header_interface_id  NUMBER;
        x_to_organization_code VARCHAR2(3);
        x_to_organization_id   NUMBER; /* Bug#3909973 - (1) */
        x_shipment_header_id   RCV_TRANSACTIONS_INTERFACE.SHIPMENT_HEADER_ID%TYPE;
        x_shipment_num         RCV_TRANSACTIONS_INTERFACE.SHIPMENT_NUM%TYPE;
        x_document_num         RCV_TRANSACTIONS_INTERFACE.DOCUMENT_NUM%TYPE;
    BEGIN
        x_header_interface_id  := p_header_record.header_record.header_interface_id;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('No ship to org specified at the header');
            asn_debug.put_line('Trying to retrieve from lines');
        END IF;

        SELECT MAX(rti.to_organization_code)
        INTO   x_to_organization_code
        FROM   rcv_transactions_interface rti
        WHERE  rti.header_interface_id = x_header_interface_id;

        /* Bug# 1465730 - If Ship To Organization Code is not specified at lines
         * then derive it from the To Organization Id and if this is also not
         * specified then derive it from Ship To Location Code/Id which ever is
         * specified. */
        IF (x_to_organization_code IS NULL) THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('No ship to org specified at the lines either');
                asn_debug.put_line('Trying to retrieve from to_organization_id');
            END IF;

            /* ksareddy RVCTP performance fix 2481798 - select from mtl_parameters instead
           SELECT MAX(ORG.ORGANIZATION_CODE)
           INTO   X_TO_ORGANIZATION_CODE
           FROM   RCV_TRANSACTIONS_INTERFACE RTI,
                  ORG_ORGANIZATION_DEFINITIONS ORG
           WHERE  RTI.HEADER_INTERFACE_ID = X_HEADER_INTERFACE_ID
           AND    ORG.ORGANIZATION_ID = RTI.TO_ORGANIZATION_ID;
            */
            SELECT MAX(mtl.organization_code)
            INTO   x_to_organization_code
            FROM   rcv_transactions_interface rti,
                   mtl_parameters mtl
            WHERE  rti.header_interface_id = x_header_interface_id
            AND    mtl.organization_id = rti.to_organization_id;
        END IF;

        IF (x_to_organization_code IS NULL) THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Trying to retrieve from ship to location');
            END IF;

            SELECT MAX(org.organization_code)
            INTO   x_to_organization_code
            FROM   rcv_transactions_interface rti,
                   hr_locations hl,
                   mtl_parameters org
                   -- BugFix 5219284, replaced org_organization_definitions with mtl_parameters for better performance.
            WHERE  rti.header_interface_id = x_header_interface_id
            AND    (   rti.ship_to_location_code = hl.location_code
                    OR rti.ship_to_location_id = hl.location_id)
            AND    hl.inventory_organization_id = org.organization_id;
        END IF;

        /* Bug 3695855 - need to default org form shipping header */
        IF (x_to_organization_code IS NULL) THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Trying to retrieve from shipment header id');
            END IF;

            SELECT MAX(rti.shipment_header_id),MAX(rti.shipment_num),MAX(rti.document_num)
            INTO   x_shipment_header_id,x_shipment_num,x_document_num
            FROM   rcv_transactions_interface rti
            WHERE  rti.header_interface_id = x_header_interface_id;

            x_shipment_num  := nvl(x_shipment_num,p_header_record.header_record.shipment_num);

            IF (x_shipment_header_id IS NULL and x_shipment_num IS NOT NULL) THEN
                SELECT MAX(rsh.shipment_header_id)
                INTO   x_shipment_header_id
                FROM   rcv_shipment_headers rsh
                WHERE  rsh.shipment_num = x_shipment_num;
            END IF;

            IF (x_shipment_header_id IS NOT NULL) THEN
                SELECT MAX(rsl.to_organization_id)
                INTO   x_to_organization_id /* Bug#3909973 - (2) */
                FROM   rcv_shipment_lines rsl
                WHERE  rsl.shipment_header_id = x_shipment_header_id
                AND    (x_document_num is null or x_document_num = rsl.line_num);
            END IF;
        END IF;
        /* End bug 3695855 */

        IF (    p_header_record.header_record.ship_to_organization_code IS NULL
            AND p_header_record.header_record.ship_to_organization_id IS NULL) THEN
            IF (x_to_organization_code IS NOT NULL) THEN
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('A ship to location relating to an org was found');
                END IF;

                p_header_record.header_record.ship_to_organization_code  := x_to_organization_code;
            ELSIF (x_to_organization_id IS NOT NULL) THEN /* Bug#3909973 - (3) */
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('A ship to location relating to an org was found');
                END IF;

                p_header_record.header_record.ship_to_organization_id  := x_to_organization_id;
            ELSE
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('A ship to location relating to an org was NOT found');
                    asn_debug.put_line('This will cause an ERROR later');
                END IF;
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_header_record.error_record.error_status   := 'U';
            p_header_record.error_record.error_message  := SQLERRM;
    END derive_ship_to_org_from_rti;

    PROCEDURE derive_uom_info(
        x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
        n                IN            BINARY_INTEGER
    ) IS
    BEGIN
        asn_debug.put_line('inside derive_uom_info');

        IF     (x_cascaded_table(n).error_status IN('S', 'W'))
           AND x_cascaded_table(n).item_id IS NOT NULL
           AND x_cascaded_table(n).primary_unit_of_measure IS NULL THEN
            BEGIN
                /* BUG 608353 */
		/*Commenting defaulting of use_mtl_lot and use_mtl_serial
                  BUG 4735484
		*/
                SELECT primary_unit_of_measure
                       --NVL(x_cascaded_table(n).use_mtl_lot, lot_control_code),
                       --NVL(x_cascaded_table(n).use_mtl_serial, serial_number_control_code)
                INTO   x_cascaded_table(n).primary_unit_of_measure
                       --x_cascaded_table(n).use_mtl_lot,
                       --x_cascaded_table(n).use_mtl_serial
                FROM   mtl_system_items
                WHERE  mtl_system_items.inventory_item_id = x_cascaded_table(n).item_id
                AND    mtl_system_items.organization_id = x_cascaded_table(n).to_organization_id;

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Primary UOM: ' || x_cascaded_table(n).primary_unit_of_measure);
                END IF;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    x_cascaded_table(n).error_status   := 'W';
                    x_cascaded_table(n).error_message  := 'Need an error message';

                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('Primary UOM error');
                    END IF;
            END;
        END IF; -- set primary_uom

        /* Bug 2020269 : uom_code needs to be derived from unit_of_measure
          entered in rcv_transactions_interface.
        */
        IF (x_cascaded_table(n).unit_of_measure IS NOT NULL) THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('deriving uom_code from unit_of_measure');
            END IF;

            SELECT muom.uom_code
            INTO   x_cascaded_table(n).uom_code
            FROM   mtl_units_of_measure muom
            WHERE  muom.unit_of_measure = x_cascaded_table(n).unit_of_measure;
        ELSE
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('uom_code not dereived as unit_of_measure is null');
            END IF;
        END IF; -- set uom_code
    END derive_uom_info;

    PROCEDURE genreceiptnum(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
        l_count NUMBER;
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        BEGIN
            SELECT        (next_receipt_num + 1)
            INTO          p_header_record.header_record.receipt_num
            FROM          rcv_parameters
            WHERE         organization_id = p_header_record.header_record.ship_to_organization_id
            FOR UPDATE OF next_receipt_num;

            LOOP
                SELECT COUNT(*)
                INTO   l_count
                FROM   rcv_shipment_headers
                WHERE  receipt_num = p_header_record.header_record.receipt_num
                AND    ship_to_org_id = p_header_record.header_record.ship_to_organization_id;

                IF l_count = 0 THEN
                    UPDATE rcv_parameters
                       SET next_receipt_num = p_header_record.header_record.receipt_num
                     WHERE organization_id = p_header_record.header_record.ship_to_organization_id;

                    EXIT;
                ELSE
                    p_header_record.header_record.receipt_num  := TO_CHAR(TO_NUMBER(p_header_record.header_record.receipt_num) + 1);
                END IF;
            END LOOP;

            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
        END;
    END genreceiptnum;

    PROCEDURE commondefaultcode(
        p_trx_record IN OUT NOCOPY rcv_roi_header_common.common_default_record_type
    ) IS
    BEGIN
        IF    p_trx_record.destination_type_code IS NULL
           OR (p_trx_record.transaction_type = 'TRANSFER')
           OR -- TRANSFER
              (    p_trx_record.destination_type_code = 'INVENTORY'
               AND p_trx_record.auto_transact_code = 'RECEIVE') THEN
            p_trx_record.destination_type_code  := 'RECEIVING';

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Defaulting DESTINATION_TYPE_CODE ' || p_trx_record.destination_type_code);
            END IF;
        END IF;

        IF p_trx_record.transaction_type IS NULL THEN
            p_trx_record.transaction_type  := 'SHIP';

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Defaulting TRANSACTION_TYPE ' || p_trx_record.transaction_type);
            END IF;
        END IF;

        IF p_trx_record.processing_mode_code IS NULL THEN
            p_trx_record.processing_mode_code  := 'BATCH';

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Defaulting PROCESSING_MODE_CODE ' || p_trx_record.processing_mode_code);
            END IF;
        END IF;

        p_trx_record.processing_status_code  := 'RUNNING';

        IF p_trx_record.processing_status_code IS NULL THEN
            -- This has to be set to running otherwise C code in rvtbm
                 -- will not pick it up
            p_trx_record.processing_status_code  := 'RUNNING';

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Defaulting PROCESSING_STATUS_CODE ' || p_trx_record.processing_status_code);
            END IF;
        END IF;

        IF p_trx_record.transaction_status_code IS NULL THEN
            p_trx_record.transaction_status_code  := 'PENDING';

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Defaulting TRANSACTION_STATUS_CODE ' || p_trx_record.transaction_status_code);
            END IF;
        END IF;
    -- Default auto_transact_code if it is null
    END commondefaultcode;

    PROCEDURE default_last_update_info(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        /* last_update_date */
        IF p_header_record.header_record.last_update_date IS NULL THEN
            p_header_record.header_record.last_update_date  := x_sysdate;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('defaulting last update date');
            END IF;
        END IF;

        /* last_updated_by */
        IF p_header_record.header_record.last_updated_by IS NULL THEN
            p_header_record.header_record.last_updated_by  := fnd_global.user_id;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('defaulting last update by');
            END IF;
        END IF;

        /* last_update_login */
        IF p_header_record.header_record.last_update_login IS NULL THEN
            p_header_record.header_record.last_update_login  := fnd_global.login_id;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('defaulting last update login');
            END IF;
        END IF;
    END default_last_update_info;

    PROCEDURE default_creation_info(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        /* creation_date   */
        IF p_header_record.header_record.creation_date IS NULL THEN
            p_header_record.header_record.creation_date  := x_sysdate;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('defaulting creation date');
            END IF;
        END IF;

        /* created_by      */
        IF p_header_record.header_record.created_by IS NULL THEN
            p_header_record.header_record.created_by  := fnd_global.user_id;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('defaulting created by ');
            END IF;
        END IF;
    END default_creation_info;

    PROCEDURE default_asn_type(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        /* Default STD into asn_type for null asn_type */
        IF p_header_record.header_record.asn_type IS NULL THEN
            p_header_record.header_record.asn_type  := 'STD';

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('defaulting asn type to STD');
            END IF;
        END IF;
    END default_asn_type;

    PROCEDURE default_shipment_header_id(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        /* generate the shipment_header_id */
        /* shipment_header_id - receipt_header_id is the same */
        IF     p_header_record.header_record.receipt_header_id IS NULL
           AND p_header_record.header_record.transaction_type <> 'CANCEL' THEN -- added for support of cancel
            SELECT rcv_shipment_headers_s.NEXTVAL
            INTO   p_header_record.header_record.receipt_header_id
            FROM   SYS.DUAL;

            /* Bug#4523892 */
            IF p_header_record.header_record.receipt_source_code = 'VENDOR' THEN
                rcv_roi_header.g_txn_against_asn := 'N';
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('g_txn_against_asn in default_shipment_header_id:' || rcv_roi_header.g_txn_against_asn);
                END IF;
            END IF;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('defaulted receipt_id');
            END IF;
        END IF;
    END default_shipment_header_id;

    PROCEDURE default_receipt_info(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
        v_rcv_type po_system_parameters.user_defined_receipt_num_code%TYPE;
        v_count    NUMBER                                                    := 0;
    BEGIN
        /* receipt_num */

        -- If Receipt Generation is set to Manual then we need to default it based
        -- on the Shipment number. If shipment_num is also null then we will use the
        -- shipment_header_id. We need a Receipt num in case of RECEIVE/DELIVER as
        -- some of the views of the receiving form have the condition of receipt_num not
        -- null added to it.

        -- IF the transaction type is CANCEL then no need to generate a receipt num

        IF     p_header_record.header_record.receipt_num IS NULL
           AND p_header_record.header_record.transaction_type <> 'CANCEL' THEN -- added for support of cancel
            SELECT COUNT(*)
            INTO   v_count
            FROM   rcv_transactions_interface rti
            WHERE  rti.header_interface_id = p_header_record.header_record.header_interface_id
            AND    (   rti.auto_transact_code IN('RECEIVE', 'DELIVER')
                    OR rti.transaction_type IN('RECEIVE', 'DELIVER'));

            IF v_count > 0 THEN -- We need to generate a receipt_num
                BEGIN
                    SELECT user_defined_receipt_num_code
                    INTO   v_rcv_type
                    FROM   rcv_parameters
                    WHERE  organization_id = p_header_record.header_record.ship_to_organization_id;

                    /* assuming that the ship_to_organization_id is populated at the header level of
                         rcv_headers_interface */
                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line(v_rcv_type || ' Generation ');
                    END IF;

                    IF v_rcv_type = 'AUTOMATIC' THEN
                        --bug 2506961
                        rcv_roi_header_common.genreceiptnum(p_header_record);
                    ELSE -- MANUAL
                        IF p_header_record.header_record.shipment_num IS NOT NULL THEN
                            p_header_record.header_record.receipt_num  := p_header_record.header_record.shipment_num;
                        END IF;

                        /* If receipt_num is still null then use the shipment_header_id */
                        IF p_header_record.header_record.receipt_num IS NULL THEN
                            p_header_record.header_record.receipt_num  := TO_CHAR(p_header_record.header_record.receipt_header_id);
                        END IF;
                    END IF; -- v_rcv_type
                EXCEPTION
                    -- Added following NO_DATA_FOUND condition for bugfix #4070516
                    WHEN NO_DATA_FOUND
                    THEN
                                IF (g_asn_debug = 'Y') THEN
                                    asn_debug.put_line('NO_DATA_FOUND exception occured. Receiving options are not defined for organization = ' || p_header_record.header_record.ship_to_organization_id);
                                END IF;
                                p_header_record.error_record.error_status  := 'E';
                                rcv_error_pkg.set_error_message('RCV_NO_OPTION', p_header_record.error_record.error_message);
                                rcv_error_pkg.set_token('ORG', p_header_record.header_record.ship_to_organization_id);
                    -- End of code for bugfix #4070516
                    WHEN OTHERS THEN
                        p_header_record.error_record.error_status   := 'E';
                        p_header_record.error_record.error_message  := SQLERRM;
                END;
            ELSE -- of v_count
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('No need to generate a receipt_number');
                END IF;
            END IF; --  of v_count

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('defaulted receipt_num ' || p_header_record.header_record.receipt_num);
            END IF;
        END IF;
    END default_receipt_info;

    PROCEDURE default_ship_to_location_info(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
        temp_count     NUMBER;
        x_po_header_id NUMBER;
        x_document_num VARCHAR2(20);
    BEGIN
        /* ship_to_location_id mtl_org_organizations.default  */
        IF     p_header_record.header_record.location_code IS NULL
           AND p_header_record.header_record.location_id IS NULL
           AND p_header_record.header_record.transaction_type <> 'CANCEL'
           AND -- added for support of cancel
               p_header_record.header_record.ship_to_organization_id IS NOT NULL THEN
            /* Changed hr_locations to hr_locations_all since we are searching
             * using inventory_organization_id and for drop ship POs inventory
             * orgid does not have any meaning.
          */
            SELECT MAX(hr_locations_all.location_id),
                   COUNT(*)
            INTO   x_location_id,
                   x_count
            FROM   hr_locations_all
            WHERE  hr_locations_all.inventory_organization_id = p_header_record.header_record.ship_to_organization_id
            AND    NVL(hr_locations_all.inactive_date, x_sysdate + 1) > x_sysdate
            AND    NVL(hr_locations_all.receiving_site_flag, 'N') = 'Y';

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('count in hr_locations_all ' || x_count);
            END IF;

            IF x_count = 1 THEN
                p_header_record.header_record.location_id  := x_location_id;

                /* Bug 3250435 : The check for drop ship should be made only
                      if the receipt is against a PO. Added the following IF
                      condition so that we do not attempt to populate the
                      po_header_id when the document_num does not contain
                      a PO Number.
                */
                IF p_header_record.header_record.receipt_source_code = 'VENDOR' THEN
                    /* Bug 1904996. If this is a drop ship  PO, then we dont want
                     * to default this value since this is the location for the
                          * inventory org id in which the drop ship PO for created and
                        * not the drop ship location.
                    */
                    SELECT MAX(rti.po_header_id),
                           MAX(document_num)
                    INTO   x_po_header_id,
                           x_document_num
                    FROM   rcv_transactions_interface rti
                    WHERE  rti.header_interface_id = p_header_record.header_record.header_interface_id;

                    IF (    x_po_header_id IS NULL
                        AND x_document_num IS NOT NULL) THEN
                        BEGIN -- bugfix 4070516
                                SELECT po_header_id
                                INTO   x_po_header_id
                                FROM   po_headers
                                WHERE  segment1 = x_document_num
                                AND    type_lookup_code IN('STANDARD', 'BLANKET', 'PLANNED');
                        -- Following exception handling block is added for bugfix 4070516
                        EXCEPTION
                                WHEN    NO_DATA_FOUND
                                THEN
                                        NULL;
                                WHEN    OTHERS
                                THEN
                                        NULL;
                        END;
                        -- End of code bugfix 4070516
                    END IF;

                    IF (x_po_header_id IS NOT NULL) THEN
                        SELECT COUNT(*)
                        INTO   temp_count
                        FROM   oe_drop_ship_sources
                        WHERE  po_header_id = x_po_header_id;

                        IF (temp_count <> 0) THEN -- this is a drop ship
                            IF (g_asn_debug = 'Y') THEN
                                asn_debug.put_line('drop ship PO');
                            END IF;

                            p_header_record.header_record.location_id  := NULL;
                        END IF;
                    END IF;
                END IF;
            END IF;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('defaulted location info');
            END IF;
        END IF;
    END default_ship_to_location_info;

    PROCEDURE default_ship_from_loc_info(
       p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
       /* This is now handled by the defaulting package. No need to do it here */
       NULL;
    END default_ship_from_loc_info;

    PROCEDURE validate_trx_type(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        IF (p_header_record.error_record.error_status NOT IN('S', 'W')) THEN
            RETURN;
        END IF;

        /* Validate Transaction Type */
        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('In validate routine');
        END IF;

        lookup_record.lookup_code                 := p_header_record.header_record.transaction_type;
        lookup_record.lookup_type                 := 'TRANSACTION_TYPE';
        lookup_record.error_record.error_status   := 'S'; --p_header_record.error_record.error_status;
        lookup_record.error_record.error_message  := NULL; --p_header_record.error_record.error_message;
        po_core_s.validate_lookup_info(lookup_record);

        IF (lookup_record.error_record.error_status <> 'S') THEN
            p_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
            rcv_error_pkg.set_error_message('RCV_TRX_TYPE_INVALID', p_header_record.error_record.error_message);
            rcv_error_pkg.set_token('TYPE', lookup_record.lookup_code);
            rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE', 'TRANSACTION_TYPE');
        END IF;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('validated transaction type');
        END IF;
    EXCEPTION
        WHEN rcv_error_pkg.e_fatal_error THEN
            NULL;
    END validate_trx_type;

    PROCEDURE validate_expected_receipt_date(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        IF (p_header_record.error_record.error_status NOT IN('S', 'W')) THEN
            RETURN;
        END IF;

        /* Validation expected_receipt_date is not missing BUG 628316 */

	/* R12 Complex Work.
	* There is no concept of expected_receipt_date for Work Confirmations.
	* So expected_receipt_date can be null.
	*/
        IF (p_header_record.header_record.transaction_type <> 'CANCEL') THEN
            IF (p_header_record.header_record.expected_receipt_date IS NULL and
		 p_header_record.header_record.asn_type <> 'WC') THEN
                p_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
                rcv_error_pkg.set_error_message('RCV_ASN_EXPECTED_RECEIPT_DATE', p_header_record.error_record.error_message);
                rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE', 'EXPECTED_RECEIPT_DATE');
            END IF;
        END IF;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('validated expected_receipt_date is not missing');
        END IF;
    EXCEPTION
        WHEN rcv_error_pkg.e_fatal_error THEN
            NULL;
    END validate_expected_receipt_date;

    PROCEDURE validate_receipt_num(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    x_new_receipt      VARCHAR2(1) := 'Y'; --Bug 12719212
	x_rhi_count NUMBER := 0; --Bug 9126513
    BEGIN
        /* Validate Receipt Number */
        IF (p_header_record.error_record.error_status NOT IN('S', 'W')) THEN
            RETURN;
        END IF;

        IF     p_header_record.header_record.receipt_num IS NULL
           AND p_header_record.header_record.asn_type = 'STD'
           AND p_header_record.header_record.transaction_type <> 'CANCEL' THEN -- added for support of cancel
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Receipt Number is mandatory for STD');
            END IF;

            /* Bug 3590735.
             * When we error out with receipt number mandatory error,
             * we need to set this error in po_interface_errors.
            */
            p_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
            rcv_error_pkg.set_error_message('RCV_RECEIPT_NUM_REQ', p_header_record.error_record.error_message);
            rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE', 'RECEIPT_NUM');
        END IF;

       /* Bug 12719212
        * get the value if the shipment is new shipment (has not been received),
        * we validate duplicate receipt_num only when it is first receive against the shipment
        */
       SELECT DECODE(COUNT(*),
                     0, 'Y',
                     'N'
                    )
        INTO   x_new_receipt
        FROM   rcv_shipment_lines
        WHERE  quantity_received > 0
        AND    shipment_header_id IN
        (SELECT shipment_header_id
         FROM   rcv_shipment_headers
         WHERE  shipment_num = p_header_record.header_record.shipment_num
         AND ( vendor_site_id =
               NVL(p_header_record.header_record.vendor_site_id, vendor_site_id)
             OR vendor_site_id IS NULL)
         AND (vendor_id =
              NVL(p_header_record.header_record.vendor_id, vendor_id)
             OR vendor_id IS NULL)
         AND   ship_to_org_id =
             NVL(p_header_record.header_record.ship_to_organization_id, ship_to_org_id)
         AND  shipped_date >=
             ADD_MONTHS(NVL(p_header_record.header_record.shipped_date, SYSDATE), -12)
						 AND receipt_source_code = p_header_record.header_record.receipt_source_code);

         IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('shipment x_new_receipt '||x_new_receipt);
         END IF;

         /*End Bug 12719212 */


        IF  x_new_receipt = 'Y'       --Bug 12719212
            --p_header_record.header_record.receipt_header_id IS NULL --Bug 12719212
           AND -- bug 3508507: only check receipt_num uniqueness for new reciepts
               -- X_new_receipt is populated in default_receipt_info()
               p_header_record.header_record.receipt_num IS NOT NULL
           AND p_header_record.header_record.transaction_type <> 'CANCEL' THEN -- added for support of cancel
            SELECT COUNT(*)
            INTO   x_count
            FROM   rcv_shipment_headers
            WHERE  rcv_shipment_headers.receipt_num = p_header_record.header_record.receipt_num
            AND    ship_to_org_id = p_header_record.header_record.ship_to_organization_id;
            /* Bug 9126513 In case of concurrency issues with multiple RTP sessions running at the same time, multiple
               RSH records were getting created due to simultaneous execution of the RSH validation above. Now, we
               validate the Receipt Number/(Ship To Organization Id OR Ship To Organization Code) combination in RHI also,
               and throw an exception when there are Duplicate Records in RHI with the same combination.*/
            IF x_count = 0 THEN
                SELECT Count(*)
                INTO   x_rhi_count
                FROM   rcv_headers_interface rhi
                WHERE  rhi.receipt_num = p_header_record.header_record.receipt_num
                AND    (rhi.ship_to_organization_id   = p_header_record.header_record.ship_to_organization_id
                     OR rhi.ship_to_organization_code = p_header_record.header_record.ship_to_organization_code)
                AND    rhi.processing_status_code IN ('PENDING','RUNNING');

                IF x_rhi_count > 1 THEN
                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('Multiple RHI Records exist with Duplicate Receipt Numbers for the same Ship To Organization Id.');
                    END IF;
                END IF;
            END IF;

            IF (x_count > 0 OR x_rhi_count > 1) THEN
                p_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
                rcv_error_pkg.set_error_message('PO_PDOI_RECEIPT_NUM_UNIQUE', p_header_record.error_record.error_message);
                rcv_error_pkg.set_token('VALUE', p_header_record.header_record.receipt_num);
                rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE', 'RECEIPT_NUM');
           END IF;
            /* End of fix for Bug 9126513 */

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('validated receipt number');
            END IF;
        END IF;
    EXCEPTION
        WHEN rcv_error_pkg.e_fatal_error THEN
            NULL;
    END validate_receipt_num;

    PROCEDURE validate_ship_to_org_info(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        /* Validate Ship To Organization Information */
        IF (p_header_record.error_record.error_status NOT IN('S', 'W')) THEN
            RETURN;
        END IF;

        IF p_header_record.header_record.asn_type IN('ASN', 'ASBN', 'STD', 'LCM') THEN /* lcm changes */
            ship_to_org_record.organization_code           := p_header_record.header_record.ship_to_organization_code;
            ship_to_org_record.organization_id             := p_header_record.header_record.ship_to_organization_id;
            ship_to_org_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_success;
            ship_to_org_record.error_record.error_message  := NULL;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('In Validate Ship to Organization Procedure');
            END IF;

            po_orgs_sv.validate_org_info(ship_to_org_record);

            IF (ship_to_org_record.error_record.error_status <> 'S') THEN
                IF ship_to_org_record.error_record.error_message = 'ORG_DISABLED' THEN
                    IF p_header_record.header_record.transaction_type <> 'CANCEL' THEN
                        IF (g_asn_debug = 'Y') THEN
                            asn_debug.put_line('Error with RCV_SHIPTO_ORG_DISABLED');
                        END IF;

                        p_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
                        rcv_error_pkg.set_error_message('RCV_SHIPTO_ORG_DISABLED', p_header_record.error_record.error_message);
                        rcv_error_pkg.set_token('ORGANIZATION', ship_to_org_record.organization_id);
                        rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE', 'SHIP_TO_ORGANIZATION_ID');
                    END IF;
                ELSE
                    p_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
                    rcv_error_pkg.set_error_message('PO_PDOI_INVALID_SHIP_TO_ORG_ID', p_header_record.error_record.error_message);
                    rcv_error_pkg.set_token('VALUE', ship_to_org_record.organization_id);
                    rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE', 'SHIP_TO_ORGANIZATION_ID');
                END IF;
            END IF;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('ship_to_org_record.error_status ' || ship_to_org_record.error_record.error_status);
                asn_debug.put_line('validated ship to organization info');
            END IF;
        END IF;

        /* Bug# 3662698.
           Verify if any of the lines tied to the header have destination organization
           different to that of the header's org (which is either populated or derived).
        */
        IF (    p_header_record.header_record.asn_type IN('ASN', 'ASBN', 'STD', 'LCM') /* lcm changes */
            AND p_header_record.header_record.transaction_type <> 'CANCEL') THEN
            /* Check if there is atleast one RTI record of this header with a
               different org than the header's org. Here we consider those
               RTI records which have to_organization_code or to_organization_id
               as not null. Later below we check for those RTI records which have
               to_organization_code and to_organization_id as null.
               This logic is followed keeping in view of the performance problems.
            */
            IF (p_header_record.header_record.ship_to_organization_code IS NOT NULL) THEN
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Checking if any RTI has different destn org than that of the header');
                END IF;

                SELECT COUNT(*)
                INTO   x_count
                FROM   rcv_transactions_interface rti,
                       rcv_headers_interface rhi
                WHERE  rti.header_interface_id = p_header_record.header_record.header_interface_id
                AND    rhi.header_interface_id = rti.header_interface_id
                AND    (   (    rti.to_organization_code IS NOT NULL
                            AND rti.to_organization_code <> p_header_record.header_record.ship_to_organization_code)
                        OR (    rti.to_organization_id IS NOT NULL
                            AND rti.to_organization_id <> p_header_record.header_record.ship_to_organization_id)
                       );

                IF x_count >= 1 THEN
                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('Atleast one of the RTIs has a different org id/code than that of the header');
                    END IF;

                    p_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
                    rcv_error_pkg.set_error_message('RCV_MUL_DESTN_ORGS_FOR_LINES', p_header_record.error_record.error_message);
                    rcv_error_pkg.set_token('VALUE', p_header_record.header_record.ship_to_organization_id);
                    rcv_error_pkg.log_interface_error('SHIP_TO_ORGANIZATION_ID');
                ELSE
                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('In the ELSE part');
                    END IF;

                    /* Check if there is atleast one RTI record in this header with a different
                       ship to org than the header's org. Here we consider those RTI records
                       which have to_organization_code and to_rganization_id as null and
                       ship_to_location_id as not null. Records with all the above four columns
                       as null need not be checked as header's org will be set to the line's org
                       during  the line level organization derivation.
                    */
                    SELECT COUNT(*)
                    INTO   x_count
                    FROM   rcv_transactions_interface rti,
                           hr_locations hl,
                           mtl_parameters org
                   -- BugFix 5219284, replaced org_organization_definitions with mtl_parameters for better performance.
                    WHERE  rti.header_interface_id = p_header_record.header_record.header_interface_id
                    AND    rti.to_organization_code IS NULL
                    AND    rti.to_organization_id IS NULL
                    AND    rti.ship_to_location_id IS NOT NULL
                    AND    rti.ship_to_location_id = hl.location_id
                    AND    hl.inventory_organization_id = org.organization_id
                    AND    org.organization_code <> p_header_record.header_record.ship_to_organization_code;

                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('Count is ' || TO_CHAR(x_count));
                    END IF;

                    /* Check if there is atleast one RTI record in this header with a different
                       ship to org than the header's org. Here we consider those RTI records
                       which have to_organization_code and to_rganization_id as null and
                       ship_to_location_code as not null. A seperate sql is written using
                       ship_location_code instead of adding it to the the WHERE caluse of the
                       above sql to avoid full table scans on hr_locations.
                    */
                    IF x_count = 0 THEN
                        SELECT COUNT(*)
                        INTO   x_count
                        FROM   rcv_transactions_interface rti,
                               hr_locations hl,
                               mtl_parameters org
                   -- BugFix 5219284, replaced org_organization_definitions with mtl_parameters for better performance.
                        WHERE  rti.header_interface_id = p_header_record.header_record.header_interface_id
                        AND    rti.to_organization_code IS NULL
                        AND    rti.to_organization_id IS NULL
                        AND    rti.ship_to_location_code IS NOT NULL
                        AND    rti.ship_to_location_code = hl.location_code
                        AND    hl.inventory_organization_id = org.organization_id
                        AND    org.organization_code <> p_header_record.header_record.ship_to_organization_code;
                    END IF;

                    IF x_count >= 1 THEN
                        IF (g_asn_debug = 'Y') THEN
                            asn_debug.put_line('For one of the RTI records a different org id/code is derived');
                        END IF;

                        p_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
                        rcv_error_pkg.set_error_message('RCV_MUL_DESTN_ORGS_FOR_LINES', p_header_record.error_record.error_message);
                        rcv_error_pkg.set_token('VALUE', p_header_record.header_record.ship_to_organization_id);
                        rcv_error_pkg.log_interface_error('SHIP_TO_ORGANIZATION_ID');
                    END IF;
                END IF;

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Validated ship to org of all the RTIs tied to the header');
                END IF;
            END IF;
        END IF; --End of bug# 3662698.

    EXCEPTION
        WHEN rcv_error_pkg.e_fatal_error THEN
            NULL;
    END validate_ship_to_org_info;

    PROCEDURE validate_from_org_info(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        /* validate from organization information */
        IF (p_header_record.error_record.error_status NOT IN('S', 'W')) THEN
            RETURN;
        END IF;

        IF p_header_record.header_record.transaction_type <> 'CANCEL' THEN
            IF    from_org_record.organization_code IS NOT NULL
               OR from_org_record.organization_id IS NOT NULL THEN
                from_org_record.organization_code           := p_header_record.header_record.from_organization_code;
                from_org_record.organization_id             := p_header_record.header_record.from_organization_id;
                from_org_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_success;
                from_org_record.error_record.error_message  := NULL;

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('In Validate From Organization Procedure');
                END IF;

                po_orgs_sv.validate_org_info(from_org_record);

                IF (from_org_record.error_record.error_status <> 'S') THEN
                    IF from_org_record.error_record.error_message = 'ORG_DISABLED' THEN
                        IF p_header_record.header_record.transaction_type <> 'CANCEL' THEN
                            IF (g_asn_debug = 'Y') THEN
                                asn_debug.put_line('Error with RCV_SHIPTO_ORG_DISABLED');
                            END IF;

                            p_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
                            rcv_error_pkg.set_error_message('RCV_FROM_ORG_DISABLED', p_header_record.error_record.error_message);
                            rcv_error_pkg.set_token('ORGANIZATION', from_org_record.organization_code);
                            rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE', 'FROM_ORGANIZATION_ID');
                        END IF;
                    ELSE
                        IF (g_asn_debug = 'Y') THEN
                            asn_debug.put_line('Error with from ORG_ID');
                        END IF;

                        p_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
                        rcv_error_pkg.set_error_message('RCV_FROM_ORG_ID', p_header_record.error_record.error_message);
                        rcv_error_pkg.set_token('ORGANIZATION', from_org_record.organization_code);
                        rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE', 'FROM_ORGANIZATION_ID');
                    END IF;
                END IF;

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('validated from organization info');
                END IF;
            END IF;
        END IF;
    EXCEPTION
        WHEN rcv_error_pkg.e_fatal_error THEN
            NULL;
    END validate_from_org_info;

    PROCEDURE validate_location_info(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        /* Validate Location Information */
        IF (p_header_record.error_record.error_status NOT IN('S', 'W')) THEN
            RETURN;
        END IF;

        IF     p_header_record.header_record.transaction_type <> 'CANCEL'
           AND p_header_record.header_record.asn_type IN('ASN', 'ASBN', 'STD', 'LCM') /* lcm changes */
           AND (   p_header_record.header_record.location_code IS NOT NULL
                OR p_header_record.header_record.location_id IS NOT NULL) THEN
            loc_record.location_code               := p_header_record.header_record.location_code;
            loc_record.location_id                 := p_header_record.header_record.location_id;
            loc_record.organization_id             := p_header_record.header_record.ship_to_organization_id;
            loc_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_success;
            loc_record.error_record.error_message  := NULL;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('In Validate Location Code Procedure');
            END IF;

            po_locations_s.validate_location_info(loc_record);

            IF loc_record.error_record.error_status <> 'S' THEN
                IF loc_record.error_record.error_message = 'LOC_NOT_IN_ORG' THEN
                    p_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
                    rcv_error_pkg.set_error_message('RCV_LOC_NOT_IN_ORG', p_header_record.error_record.error_message);
                    rcv_error_pkg.set_token('LOCATION', loc_record.location_id);
                    rcv_error_pkg.set_token('ORGANIZATION', loc_record.organization_id);
                    rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE', 'LOCATION_ID');
                ELSE
                    p_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
                    rcv_error_pkg.set_error_message('PO_PDOI_INVALID_SHIP_TO_LOC_ID', p_header_record.error_record.error_message);
                    rcv_error_pkg.set_token('VALUE', loc_record.location_id);
                    rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE', 'LOCATION_ID');
                END IF;
            END IF;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line(loc_record.error_record.error_status);
                asn_debug.put_line(loc_record.error_record.error_message);
                asn_debug.put_line('Validated location info');
            END IF;
        END IF;
    EXCEPTION
        WHEN rcv_error_pkg.e_fatal_error THEN
            NULL;
    END validate_location_info;

    PROCEDURE validate_ship_from_loc_info(
       p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
       x_dummy         NUMBER;
       p_in_rec        wsh_po_integration_grp.validatesf_in_rec_type;
       x_out_rec       wsh_po_integration_grp.validatesf_out_rec_type;
       x_return_status VARCHAR2(3);
       x_msg_count     NUMBER;
       x_msg_data      VARCHAR2(2000);
       l_shipping_control VARCHAR2(30); --Bug 5263268

       CURSOR get_lines IS
          SELECT po_line_id,
                 po_line_location_id po_shipment_line_id
          FROM   rcv_transactions_interface
          WHERE  header_interface_id = p_header_record.header_record.header_interface_id;

       --Bug5263268:Cursor to fetch the value of "Shipping_control" from po_headers table.
       --Note:-ASN or ASBN can be created for multiple PO's provided they have the same
       --value for shing control.It is not possible to create a single ASN or ASBN with one PO
       --having shipping control as 'buyer' and another PO with shipping control as 'supplier' or
       --shippign control is null.
       --So there is no need to loop through the records fetched by the cursor.

       /*CURSOR c_get_shipping_control is
         select shipping_control
	 from po_headers_all
	 where po_header_id = (select po_header_id
	                       from rcv_transactions_interface
			       where header_interface_id =  p_header_record.header_record.header_interface_id
                               and    rownum=1);*/ --Bugfix 5844039
    BEGIN
       /* Validate Location Information */
       IF (p_header_record.error_record.error_status NOT IN('S', 'W')) THEN
          RETURN;
       END IF;

       --Bug 5263268:If the shipping_control is 'BUYER' and ship_from_location_id is NULL
       --the the transaction should error out.
       /*open c_get_shipping_control;
       fetch c_get_shipping_control into l_shipping_control;
       close c_get_shipping_control;

	/* Bug 8314708 : Added extra condition to check the asn_type so that the validation
	** for ship_from_location_id happens only in case of ASN's and ASBN's

       IF (nvl(l_shipping_control,'@@@') = 'BUYER' AND p_header_record.header_record.ship_from_location_id IS NULL
          AND p_header_record.header_record.asn_type in ('ASN', 'ASBN') ) THEN
             IF (g_asn_debug = 'Y') THEN
                   asn_debug.put_line('Ship from location id cannot be null if shipping_control is BUYER');
             END IF;
             p_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
             rcv_error_pkg.set_error_message('RCV_INVALID_ROI_VALUE_NE');
	     rcv_error_pkg.set_token('ROI_VALUE',p_header_record.header_record.ship_from_location_id);
             rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE', 'SHIP_FROM_LOCATION_ID');

       END IF;*/
       --End Bug 5263268

       IF p_header_record.header_record.ship_from_location_id IS NOT NULL THEN
          p_in_rec.ship_from_location_id  := p_header_record.header_record.ship_from_location_id;
          open get_lines;
          fetch get_lines bulk collect into p_in_rec.po_line_id_tbl,p_in_rec.po_shipment_line_id_tbl;
          close get_lines;

          wsh_po_integration_grp.validateasnreceiptshipfrom(1.0,
                                                            fnd_api.g_false,
                                                            p_in_rec,
                                                            fnd_api.g_false,
                                                            x_return_status,
                                                            x_out_rec,
                                                            x_msg_count,
                                                            x_msg_data
                                                           );

          IF (x_out_rec.is_valid = FALSE) THEN
             p_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
             rcv_error_pkg.set_error_message('RCV_LOC_NOT_IN_ORG', p_header_record.error_record.error_message);
             rcv_error_pkg.set_token('LOCATION', p_header_record.header_record.ship_from_location_id);
             rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE', 'SHIP_FROM_LOCATION_ID');
          END IF;

          IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('Validated location info with status=' || p_header_record.error_record.error_status);
          END IF;
       END IF;
    EXCEPTION
       WHEN rcv_error_pkg.e_fatal_error THEN
          NULL;
    END validate_ship_from_loc_info;

    PROCEDURE validate_payment_terms_info(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        /* Validate Payment Terms Information */
        IF (p_header_record.error_record.error_status NOT IN('S', 'W')) THEN
            RETURN;
        END IF;

        IF     (   p_header_record.header_record.payment_terms_name IS NOT NULL
                OR p_header_record.header_record.payment_terms_id IS NOT NULL)
           AND p_header_record.header_record.transaction_type <> 'CANCEL' THEN
            pay_record.payment_term_id             := p_header_record.header_record.payment_terms_id;
            pay_record.payment_term_name           := p_header_record.header_record.payment_terms_name;
            pay_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_success;
            pay_record.error_record.error_message  := NULL;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('In Validate Payment Terms ');
            END IF;

            po_terms_sv.validate_payment_terms_info(pay_record);

            IF (    pay_record.error_record.error_message = 'PAY_TERMS_DISABLED'
                AND NVL(p_header_record.header_record.asn_type, 'ASN') <> 'ASBN') THEN
                pay_record.error_record.error_status  := 'S';
            END IF;

            IF pay_record.error_record.error_status <> 'S' THEN
                p_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
                rcv_error_pkg.set_error_message('PO_PDOI_INVALID_PAY_TERMS', p_header_record.error_record.error_message);
                rcv_error_pkg.set_token('VALUE', pay_record.payment_term_id);
                rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE', 'PAYMENT_TERMS_ID');
            END IF;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line(pay_record.error_record.error_status);
            END IF;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Validated payment info');
            END IF;
        END IF;
    EXCEPTION
        WHEN rcv_error_pkg.e_fatal_error THEN
            NULL;
    END validate_payment_terms_info;

    PROCEDURE validate_receiver_info(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
    BEGIN
        /* validate receiver information */
        IF (p_header_record.error_record.error_status NOT IN('S', 'W')) THEN
            RETURN;
        END IF;

        IF     p_header_record.header_record.transaction_type <> 'CANCEL'
           AND p_header_record.header_record.auto_transact_code = 'RECEIVE'
           AND (   p_header_record.header_record.employee_name IS NOT NULL
                OR p_header_record.header_record.employee_id IS NOT NULL) THEN
            emp_record.employee_name               := p_header_record.header_record.employee_name;
            emp_record.employee_id                 := p_header_record.header_record.employee_id;
            emp_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_success;
            emp_record.error_record.error_message  := NULL;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('In Validate Receiver Information');
            END IF;

            po_employees_sv.validate_employee_info(emp_record);

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line(emp_record.error_record.error_status);
            END IF;

            IF emp_record.error_record.error_status <> 'S' THEN
                p_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
                rcv_error_pkg.set_error_message('RCV_RECEIVER_ID', p_header_record.error_record.error_message);
                rcv_error_pkg.set_token('NAME', emp_record.employee_name);
                rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE', 'EMPLOYEE_ID');
            END IF;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Validated receiver info');
            END IF;
        END IF;
    EXCEPTION
        WHEN rcv_error_pkg.e_fatal_error THEN
            NULL;
    END validate_receiver_info;

    PROCEDURE validate_freight_carrier_info(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS

    X_rsh_freight_carrier_code     rcv_shipment_headers.freight_carrier_code%TYPE := '-999999'; /* Bug 8366230 */

    BEGIN
        /* validate freight carrier information */
        /* ASN and ASBN, al transaction_types except CANCEL */
        /* Carrier is specified */
        IF (p_header_record.error_record.error_status NOT IN('S', 'W')) THEN
            RETURN;
        END IF;

        IF     p_header_record.header_record.transaction_type <> 'CANCEL'
           AND p_header_record.header_record.freight_carrier_code IS NOT NULL THEN
            freight_record.freight_carrier_code        := p_header_record.header_record.freight_carrier_code;
            freight_record.organization_id             := p_header_record.header_record.ship_to_organization_id;
            freight_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_success;
            freight_record.error_record.error_message  := NULL;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('In Validate Freight Carrier Information');
            END IF;

        /*Bug 8366230
          Adding IF conditions to ensure that the validation call for freight carriers is not made for
          Internal Orders and Inter-org transfers when rcv_shipment_headers.freight_carrier_code is
          already populated.
        */
            BEGIN
            IF (p_header_record.header_record.receipt_source_code IN ('INTERNAL ORDER','INVENTORY')) THEN
                SELECT Nvl(rsh.freight_carrier_code,'-999')
                INTO   X_rsh_freight_carrier_code
                FROM   rcv_shipment_headers rsh
                WHERE  rsh.shipment_num   = p_header_record.header_record.shipment_num
                AND    rsh.ship_to_org_id = p_header_record.header_record.ship_to_organization_id
                AND    rsh.receipt_source_code IN ('INVENTORY','INTERNAL ORDER');

                IF (X_rsh_freight_carrier_code = p_header_record.header_record.freight_carrier_code) THEN
                    RETURN;
                END IF;
            END IF;

            EXCEPTION
                WHEN OTHERS THEN
                    asn_debug.put_line('Erroring out in rcv_roi_header_common.validate_freight_carrier_info');
                    asn_debug.put_line(SQLERRM);
            END;
         /* End of fix for Bug 8366230 */

            po_terms_sv.validate_freight_carrier_info(freight_record);

            IF freight_record.error_record.error_status <> 'S' THEN
                p_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
                rcv_error_pkg.set_error_message('RCV_CARRIER_DISABLED', p_header_record.error_record.error_message);
                rcv_error_pkg.set_token('CARRIER', freight_record.freight_carrier_code);
                rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE', 'FREIGHT_CARRIER_CODE');
            END IF;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line(freight_record.error_record.error_status);
                asn_debug.put_line('Validated freight carrier info');
            END IF;
        END IF;
    EXCEPTION
        WHEN rcv_error_pkg.e_fatal_error THEN
            NULL;
    END validate_freight_carrier_info;

    PROCEDURE validate_shipment_date(
        p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
        x_sysdate DATE := SYSDATE;
    BEGIN
        /* Validation for Shipment Date > System Date and not NULL,blank,zero */
        IF (p_header_record.error_record.error_status NOT IN('S', 'W')) THEN
            RETURN;
        END IF;

        IF NVL(p_header_record.header_record.shipped_date, x_sysdate + 1) > x_sysdate THEN
	    /* R12 Complex Work.
	     * There is no concept of shipped_date for Work Confirmations.
	     * So shipped_date can be null.
	    */
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('asn_type ' || p_header_record.header_record.asn_type);
                END IF;
            IF     p_header_record.header_record.shipped_date IS NULL
               AND p_header_record.header_record.asn_type IN ('WC', 'STD') THEN
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Shipped date can be blank for STD '||
						'or Work Confirmations ');
                END IF;
            ELSE
                p_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
                rcv_error_pkg.set_error_message('RCV_SHIP_DATE_INVALID', p_header_record.error_record.error_message);
                rcv_error_pkg.set_token('SHIP_DATE', fnd_date.date_to_chardate(p_header_record.header_record.shipped_date));
                rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE', 'SHIPPED_DATE');
            END IF;
        END IF;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('validated for shipment_date > system date');
        END IF;
    EXCEPTION
        WHEN rcv_error_pkg.e_fatal_error THEN
            NULL;
    END validate_shipment_date;

    PROCEDURE validate_item(
        x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
        n                IN            BINARY_INTEGER
    ) IS -- bug 608353
        x_progress              VARCHAR2(3);
        l_stock_enabled_flag    mtl_system_items.stock_enabled_flag%TYPE;  -- Bugfix 5735599
        l_inventory_item_flag   mtl_system_items.inventory_item_flag%TYPE;  -- Bugfix 5735599
        x_inventory_item        mtl_system_items.inventory_item_id%TYPE   := NULL;
        x_organization_id       mtl_system_items.organization_id%TYPE     := NULL;
        x_item_id_po            po_lines.item_id%TYPE                     := NULL;
        x_error_status          VARCHAR2(1);
    BEGIN
        asn_debug.put_line('inside validate item : receipt_source_code = ' || x_cascaded_table(n).receipt_source_code);
        x_error_status  := rcv_error_pkg.g_ret_sts_error;

        SELECT NVL(MAX(inventory_item_id), -9999)
        INTO   x_inventory_item
        FROM   mtl_system_items
        WHERE  inventory_item_id = x_cascaded_table(n).item_id;

        IF (x_inventory_item = -9999) THEN
            rcv_error_pkg.set_error_message('RCV_ITEM_ID');
            RAISE e_validation_error;
        END IF;

        SELECT NVL(MAX(inventory_item_id), -9999)
        INTO   x_inventory_item
        FROM   mtl_system_items
        WHERE  SYSDATE BETWEEN NVL(start_date_active, SYSDATE - 1) AND NVL(end_date_active, SYSDATE + 1)
        AND    inventory_item_id = x_cascaded_table(n).item_id
        AND    organization_id = NVL(x_cascaded_table(n).to_organization_id,organization_id); -- Bug 12985791

        IF (x_inventory_item = -9999) THEN
            rcv_error_pkg.set_error_message('RCV_ITEM_NOT_ACTIVE');
            RAISE e_validation_error;
        END IF;

        -- Bugfix 5735599
        -- When item status is changed to INACTIVE all the flags are unchecked.
        -- Hence to check inactive item we should check for STOCK_ENABLED_FLAG.

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('x_cascaded_table(n).auto_transact_code: ' || x_cascaded_table(n).auto_transact_code);
            asn_debug.put_line('x_cascaded_table(n).TO_ORGANIZATION_ID: ' || x_cascaded_table(n).to_organization_id);
            asn_debug.put_line('x_cascaded_table(n).item_id: ' || x_cascaded_table(n).item_id);
            asn_debug.put_line('x_cascaded_table(n).TRANSACTION_TYPE  ' || x_cascaded_table(n).transaction_type );
        END IF;

        BEGIN
                SELECT  stock_enabled_flag,
                        inventory_item_flag
                INTO    l_stock_enabled_flag,
                        l_inventory_item_flag
                FROM    mtl_system_items
                WHERE   organization_id         = x_cascaded_table(n).to_organization_id
                AND     inventory_item_id       = x_cascaded_table(n).item_id;
        EXCEPTION
                WHEN    OTHERS
                THEN
                        IF (g_asn_debug = 'Y') THEN
                            asn_debug.put_line('Error occured while checking inactive item in rcv_roi_header_common procedure. Error :: ' || SQLERRM );
                        END IF;

                        x_cascaded_table(n).error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
                        rcv_error_pkg.set_sql_error_message('rcv_roi_header_common.validate_item', '000');
                        x_cascaded_table(n).error_message  := rcv_error_pkg.get_last_message;
                        rcv_error_pkg.log_interface_error('ITEM', TRUE);

                        RETURN;
        END;

        -- If the item is inactive and routing is DIRECT then we should allow the first receipt as well.

        IF l_inventory_item_flag = 'Y' AND l_stock_enabled_flag = 'N' AND
          (x_cascaded_table(n).auto_transact_code = 'DELIVER' OR x_cascaded_table(n).transaction_type = 'DELIVER')
           AND (x_cascaded_table(n).destination_type_code = 'INVENTORY') -- Bug 8433870
        THEN
            rcv_error_pkg.set_error_message('RCV_ITEM_NOT_ACTIVE');
            RAISE e_validation_error;
        END IF;

        -- End of code for Bugfix 5735599

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
        WHERE  inventory_item_id = x_cascaded_table(n).item_id
        AND    organization_id = NVL(x_cascaded_table(n).to_organization_id, organization_id);

        IF (x_organization_id = -9999) THEN
            rcv_error_pkg.set_error_message('RCV_ITEM_NOT_IN_ORG');
            RAISE e_validation_error;
        END IF;

        -- do these checks only for PO based transactions
        IF x_cascaded_table(n).receipt_source_code = 'VENDOR' THEN --{
            SELECT NVL(MAX(item_id), -9999)
            INTO   x_item_id_po
            FROM   po_lines
            WHERE  po_line_id = x_cascaded_table(n).po_line_id
            AND    item_id = x_cascaded_table(n).item_id;

            IF (x_item_id_po = -9999) THEN
                rcv_error_pkg.set_error_message('RCV_ITEM_NOT_ON_PO');
                RAISE e_validation_error;
            END IF;

            SELECT NVL(MAX(item_id), -9999)
            INTO   x_item_id_po
            FROM   po_lines
            WHERE  po_line_id = x_cascaded_table(n).po_line_id
            AND    item_id = x_cascaded_table(n).item_id;

            IF (x_item_id_po <> x_cascaded_table(n).item_id) THEN
                rcv_error_pkg.set_error_message('RCV_NOT_PO_LINE_NUM');
                RAISE e_validation_error;
            END IF;
        END IF; --}

        /* bug 608353, do not support lot and serial control if DELIVER is used */
        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Validating Item: ' || x_cascaded_table(n).auto_transact_code);
            asn_debug.put_line('Validating Item: ' || x_cascaded_table(n).use_mtl_lot);
            asn_debug.put_line('Validating Item: ' || x_cascaded_table(n).use_mtl_serial);
        END IF;
    EXCEPTION
        WHEN e_validation_error THEN
            x_cascaded_table(n).error_status   := x_error_status;
            x_cascaded_table(n).error_message  := rcv_error_pkg.get_last_message;

            IF x_cascaded_table(n).error_message = 'RCV_ITEM_ID' THEN
                rcv_error_pkg.set_token('ITEM', x_cascaded_table(n).item_id);
            ELSIF x_cascaded_table(n).error_message = 'RCV_ITEM_NOT_ACTIVE' THEN
                rcv_error_pkg.set_token('ITEM', x_cascaded_table(n).item_id);
            ELSIF x_cascaded_table(n).error_message = 'RCV_ITEM_NOT_IN_ORG' THEN
                rcv_error_pkg.set_token('ITEM', x_cascaded_table(n).item_id);
                rcv_error_pkg.set_token('ORGANIZATION', x_cascaded_table(n).to_organization_id);
            ELSIF x_cascaded_table(n).error_message = 'RCV_ITEM_NOT_ON_PO' THEN
                rcv_error_pkg.set_token('ITEM', x_cascaded_table(n).item_id);
                rcv_error_pkg.set_token('ORGANIZATION', x_cascaded_table(n).to_organization_id);
            ELSIF x_cascaded_table(n).error_message = 'RCV_NOT_PO_LINE_NUM' THEN
                rcv_error_pkg.set_token('PO_ITEM', x_item_id_po);
                rcv_error_pkg.set_token('SHIPMENT_ITEM', x_cascaded_table(n).item_id);
            END IF;
    END validate_item;

    PROCEDURE validate_substitute_item(
        x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
        n                IN            BINARY_INTEGER
    ) IS
        x_inventory_item mtl_system_items.inventory_item_id%TYPE   := NULL;
        x_progress       VARCHAR2(3);
        x_vendor_id      po_vendors.vendor_id%TYPE                 := NULL;
        x_error_status   VARCHAR2(1);
        x_allow_sub_flag VARCHAR2(1);
    BEGIN
        x_error_status  := rcv_error_pkg.g_ret_sts_error;

        SELECT NVL(MAX(inventory_item_id), 0)
        INTO   x_inventory_item
        FROM   mtl_system_items
        WHERE  inventory_item_id = x_cascaded_table(n).substitute_item_id
        AND    organization_id = NVL(x_cascaded_table(n).to_organization_id, organization_id);

        IF (x_inventory_item = 0) THEN
            rcv_error_pkg.set_error_message('RCV_ITEM_SUB_ID');
            RAISE e_validation_error;
        END IF;

        SELECT NVL(MAX(inventory_item_id), 0)
        INTO   x_inventory_item
        FROM   mtl_system_items
        WHERE  SYSDATE BETWEEN NVL(start_date_active, SYSDATE - 1) AND NVL(end_date_active, SYSDATE + 1)
        AND    inventory_item_id = x_cascaded_table(n).substitute_item_id
        AND    organization_id = NVL(x_cascaded_table(n).to_organization_id, organization_id);

        IF (x_inventory_item = 0) THEN
            rcv_error_pkg.set_error_message('RCV_ITEM_SUB_NOT_ACTIVE');
            RAISE e_validation_error;
        END IF;

        -- do these checks only for PO based transactions
        IF x_cascaded_table(n).receipt_source_code = 'VENDOR' THEN --{
            --bug 3825246, need to check the allow_substitute_flag at both the
            --item level and on the po shipment lines level
            --the MIN gives No a priority over Yes, and the NVL covers the case where they are both null
/*            SELECT NVL(MIN(allow_substitute_receipts_flag),'N')
            INTO   x_allow_sub_flag
            FROM   (SELECT allow_substitute_receipts_flag
                    FROM   mtl_system_items
                    WHERE  inventory_item_id = (SELECT item_id
                                                FROM   po_lines
                                                WHERE  po_line_id = x_cascaded_table(n).po_line_id)
                    AND    organization_id = NVL(x_cascaded_table(n).to_organization_id, organization_id)
                    UNION ALL
                    SELECT allow_substitute_receipts_flag
                    FROM   po_line_locations
                    WHERE  line_location_id = x_cascaded_table(n).po_line_location_id);
*/
-- Bugfix 5219284, Abobe query is replaced with following for performance reason.

-- Bug 13926508: Only validate allow_substitute_receipts_flag at PO shipment level during ROI Receipts

            SELECT NVL(allow_substitute_receipts_flag, 'N')
	    INTO   x_allow_sub_flag
            FROM   po_line_locations
            WHERE  line_location_id = x_cascaded_table(n).po_line_location_id;

            IF (x_allow_sub_flag = 'N') THEN
                rcv_error_pkg.set_error_message('RCV_ITEM_SUB_NOT_ALLOWED');
                RAISE e_validation_error;
            END IF;

            SELECT NVL(MAX(inventory_item_id), 0)
            INTO   x_inventory_item
            FROM   mtl_system_items
            WHERE  inventory_item_id = x_cascaded_table(n).substitute_item_id
            AND    organization_id = NVL(x_cascaded_table(n).to_organization_id, organization_id);

            IF (x_inventory_item = 0) THEN
                rcv_error_pkg.set_error_message('RCV_ITEM_SUB_NOT_IN_ORG');
                RAISE e_validation_error;
            END IF;

            -- Bug 13926508: Commenting Supplier level validation since it is not required for substitute item receipts.

	   /* SELECT NVL(MAX(vendor_id), 0)
            INTO   x_vendor_id
            FROM   po_vendors
            WHERE  vendor_id = x_cascaded_table(n).vendor_id
            AND    allow_substitute_receipts_flag = 'Y';

            IF (x_vendor_id = 0) THEN
                rcv_error_pkg.set_error_message('RCV_ITEM_SUB_VEN_NOT_ALLOWED');
                RAISE e_validation_error;
            END IF;  */

            -- Need to check for related items if reciprocal_flag is set
            -- Thus need to use union as user may not have set up both
            -- the items to substitute for each other and just used
            -- reciprocal_flag for this
            -- relationship_type_id = 2 for substitute items
            --                      = 1 for related items

          /*  SELECT NVL(MAX(inventory_item_id), 0)
            INTO   x_inventory_item
            FROM   mtl_related_items
            WHERE  inventory_item_id = (SELECT item_id
                                        FROM   po_lines
                                        WHERE  po_line_id = x_cascaded_table(n).po_line_id)
            AND    related_item_id = x_cascaded_table(n).substitute_item_id
            AND    relationship_type_id = 2; -- substitute items
                                             -- and organization_id = nvl(x_cascaded_table(n).to_organization_id,organization_id)
          */

          -- Bugfix 5219284, Above query is replaced by following query for performance issues.

            SELECT NVL(MAX(inventory_item_id), 0)
            INTO   x_inventory_item
            FROM   mtl_related_items mri,
                   po_lines_all pl
            WHERE  mri.inventory_item_id = pl.item_id
            AND    pl.po_line_id = x_cascaded_table(n).po_line_id
            AND    mri.related_item_id = x_cascaded_table(n).substitute_item_id
            AND    mri.relationship_type_id = 2; -- substitute items
                                             -- and organization_id = nvl(x_cascaded_table(n).to_organization_id,organization_id)


            IF x_inventory_item = 0 THEN
                -- Try the reciprocal relationship

/*                SELECT NVL(MAX(inventory_item_id), 0)
                INTO   x_inventory_item
                FROM   mtl_related_items
                WHERE  related_item_id = (SELECT item_id
                                          FROM   po_lines
                                          WHERE  po_line_id = x_cascaded_table(n).po_line_id)
                AND    inventory_item_id = x_cascaded_table(n).substitute_item_id
                AND    reciprocal_flag = 'Y'
                AND    relationship_type_id = 2;
            -- and    organization_id = nvl(x_cascaded_table(n).to_organization_id,organization_id)
*/
          -- Bugfix 5219284, Above query is replaced by following query for performance issues.

                SELECT NVL(MAX(inventory_item_id), 0)
                INTO   x_inventory_item
                FROM   mtl_related_items mri,
                       po_lines_all pl
                WHERE  mri.related_item_id = pl.item_id
                AND    pl.po_line_id = x_cascaded_table(n).po_line_id
                AND    mri.inventory_item_id = x_cascaded_table(n).substitute_item_id
                AND    mri.reciprocal_flag = 'Y'
                AND    mri.relationship_type_id = 2;

            END IF;

            IF (x_inventory_item = 0) THEN
                rcv_error_pkg.set_error_message('RCV_ITEM_SUB_NOT_RELATED');
                RAISE e_validation_error;
            END IF;
        END IF; --}
    EXCEPTION
        WHEN e_validation_error THEN
            x_cascaded_table(n).error_status   := x_error_status;
            x_cascaded_table(n).error_message  := rcv_error_pkg.get_last_message;

            IF x_cascaded_table(n).error_message = 'RCV_ITEM_SUB_ID' THEN
                rcv_error_pkg.set_token('ITEM', x_cascaded_table(n).substitute_item_id);
            ELSIF x_cascaded_table(n).error_message = 'RCV_ITEM_SUB_NOT_ACTIVE' THEN
                rcv_error_pkg.set_token('ITEM', x_cascaded_table(n).substitute_item_id);
            ELSIF x_cascaded_table(n).error_message = 'RCV_ITEM_SUB_NOT_ALLOWED' THEN
                rcv_error_pkg.set_token('ITEM', x_cascaded_table(n).substitute_item_id);
            ELSIF x_cascaded_table(n).error_message = 'RCV_ITEM_SUB_NOT_IN_ORG' THEN
                rcv_error_pkg.set_token('ITEM', x_cascaded_table(n).substitute_item_id);
                rcv_error_pkg.set_token('ORGANIZATION', x_cascaded_table(n).to_organization_id);
            ELSIF x_cascaded_table(n).error_message = 'RCV_ITEM_SUB_VEN_NOT_ALLOWED' THEN
                rcv_error_pkg.set_token('ITEM', x_cascaded_table(n).substitute_item_id);
                rcv_error_pkg.set_token('SUPPLIER', x_cascaded_table(n).vendor_id);
            ELSIF x_cascaded_table(n).error_message = 'RCV_ITEM_SUB_NOT_RELATED' THEN
                rcv_error_pkg.set_token('SUB_ITEM', x_cascaded_table(n).substitute_item_id);
                rcv_error_pkg.set_token('ITEM', x_inventory_item);
            END IF;
    END validate_substitute_item;

    PROCEDURE validate_item_revision(
        x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
        n                IN            BINARY_INTEGER
    ) IS
        x_inventory_item        mtl_system_items.inventory_item_id%TYPE   := NULL;
        x_progress              VARCHAR2(3);
        x_revision_control_flag VARCHAR2(1);
        x_item_revision         po_lines.item_revision%TYPE;
        x_error_status          VARCHAR2(1);

	/* Bug 5339860
 	 * Added support for substitute item revision validation
 	 * */

        l_substitute_item	BOOLEAN;
	l_active_item_id	NUMBER;
    BEGIN

        /** Bug 6055435
         *  1) Removed the validation of item revision mentioned in PO and the one
         *     stamped in RTI, as the revision mentioned in PO can be changed at any
         *     point of time. And moreover through forms we are allowing to receive/deliver
         *     different item rev than the one mentioned in PO.
         *  2) Removed all the commented piece of codes, as the code looks clumsy.
         *  3) Removed the unnecessary error code part from the 'WHEN e_validation_error'
         *     exception handler block.
         */
        x_error_status  := rcv_error_pkg.g_ret_sts_error;

	IF x_cascaded_table(n).substitute_item_id IS NOT NULL THEN
	    l_substitute_item := TRUE;
            l_active_item_id := x_cascaded_table(n).substitute_item_id;
        ELSE
	    l_substitute_item := FALSE;
            l_active_item_id := x_cascaded_table(n).item_id;
	END IF;

        -- check whether the item is under revision control
        -- If it is not then item should not have any revisions

        SELECT DECODE(msi.revision_qty_control_code,
                      1, 'N',
                      2, 'Y',
                      'N'
                     )
        INTO   x_revision_control_flag
        FROM   mtl_system_items msi
        WHERE  inventory_item_id = l_active_item_id
        AND    organization_id = x_cascaded_table(n).to_organization_id;

        IF x_revision_control_flag = 'N' THEN --BUG: 5975270
           RETURN;
        END IF;

        -- Check whether the revision number exists
        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Revision number :  ' || x_cascaded_table(n).item_revision);
        END IF;

        SELECT NVL(MAX(inventory_item_id), 0)
        INTO   x_inventory_item
        FROM   mtl_item_revisions
        WHERE  inventory_item_id = l_active_item_id
        AND    organization_id = NVL(x_cascaded_table(n).to_organization_id, organization_id)
        AND    revision = x_cascaded_table(n).item_revision;

        IF (x_inventory_item = 0) THEN
            rcv_error_pkg.set_error_message('PO_RI_INVALID_ITEM_REVISION');
            RAISE e_validation_error;
        END IF;

    EXCEPTION
        WHEN e_validation_error THEN --Bug 6055435
            x_cascaded_table(n).error_status   := x_error_status;
            x_cascaded_table(n).error_message  := rcv_error_pkg.get_last_message;

            IF x_cascaded_table(n).error_message = 'PO_RI_INVALID_ITEM_REVISION' THEN
                NULL;
            END IF;
        when others then
           IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('exception in valid_item_revision');
               asn_debug.put_line(SQLERRM);
           END IF;
            x_cascaded_table(n).error_status   := 'E';
            x_cascaded_table(n).error_message  := rcv_error_pkg.get_last_message;

    END validate_item_revision;

    /* lcm changes */
    PROCEDURE validate_lcm_info(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type)
    IS
       l_lcm_org_flag         VARCHAR2(1);
       l_pre_rcv_flag         VARCHAR2(1);
    BEGIN
	IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('In Validate LCM Info');
            asn_debug.put_line('p_header_record.error_record.error_status ' || p_header_record.error_record.error_status);
            asn_debug.put_line('p_header_record.header_record.asn_type ' || p_header_record.header_record.asn_type);
        END IF;

        IF (p_header_record.error_record.error_status NOT IN('S', 'W')) THEN
            RETURN;
        END IF;

        IF (nvl(p_header_record.header_record.asn_type,'STD') = 'LCM') THEN

            l_lcm_org_flag := rcv_table_functions.is_lcm_org(p_header_record.header_record.ship_to_organization_id);
            l_pre_rcv_flag := rcv_table_functions.is_pre_rcv_org(p_header_record.header_record.ship_to_organization_id);

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('p_header_record.header_record.ship_to_organization_id ' || p_header_record.header_record.ship_to_organization_id);
                asn_debug.put_line('l_lcm_org_flag => ' || l_lcm_org_flag);
                asn_debug.put_line('l_pre_rcv_flag => ' || l_pre_rcv_flag);
            END IF;

	    IF (l_lcm_org_flag = 'Y') THEN
               IF ( l_pre_rcv_flag = 'N') THEN
	           --
                   /* LCM import is not supported in blackbox scenario */
                   p_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
                   rcv_error_pkg.set_error_message('RCV_LCM_IMPORT_NOT_ALLOWED', p_header_record.error_record.error_message);
                   rcv_error_pkg.set_token('ORG_ID', p_header_record.header_record.ship_to_organization_id);
                   rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE', 'ASN_TYPE');
                   --
               ELSE
                   --
                   IF (g_asn_debug = 'Y') THEN
                       asn_debug.put_line('p_header_record.header_record.transaction_type ' || p_header_record.header_record.transaction_type , NULL, 11);
                   END IF;
                   IF (p_header_record.header_record.transaction_type <> 'NEW') THEN
                       p_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
                       rcv_error_pkg.set_error_message('RCV_INVALID_ROI_VALUE_NE', p_header_record.error_record.error_message);
                       rcv_error_pkg.set_token('COLUMN', 'TRANSACTION_TYPE');
                       rcv_error_pkg.set_token('ROI_VALUE', p_header_record.header_record.transaction_type);
                       rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE', 'TRANSACTION_TYPE');
		   END IF;
                   --
               END IF;
            ELSE
                    /* LCM import is not supported in a non-lcm org */
                    p_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
                    rcv_error_pkg.set_error_message('RCV_LCM_IMPORT_NOT_ALLOWED', p_header_record.error_record.error_message);
                    rcv_error_pkg.set_token('ORG_ID', p_header_record.header_record.ship_to_organization_id);
                    rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE', 'ASN_TYPE');
            END IF;
        END IF;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('p_header_record.error_record.error_status' || p_header_record.error_record.error_status);
            asn_debug.put_line('Exitting validate_lcm_info');
        END IF;

    EXCEPTION
        WHEN rcv_error_pkg.e_fatal_error THEN
            NULL;
    END validate_lcm_info;

END rcv_roi_header_common;

/
