--------------------------------------------------------
--  DDL for Package Body RCV_FTE_CALL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_FTE_CALL_PVT" AS
/* $Header: RCVFTECB.pls 120.2 2006/03/21 15:35:51 pparthas noship $ */

PROCEDURE call_fte(
    p_action                IN VARCHAR2,
    p_shipment_header_id    IN NUMBER,
    p_shipment_line_id      IN NUMBER DEFAULT NULL,
    p_interface_id          IN NUMBER DEFAULT NULL)
IS
    l_is_asn            VARCHAR2(25);
    l_has_receipt       NUMBER;

    l_action            VARCHAR2(255);
    l_txn_id            NUMBER;
    l_txn_type          VARCHAR2(255);
    l_rcv_txn           VARCHAR2(255);

    l_valid_lines       NUMBER;

    l_return_status     VARCHAR2(255);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(255);
BEGIN

    asn_debug.put_line('action: ' || p_action || ' header_id: ' || p_shipment_header_id || ' line_id: ' || p_shipment_line_id || ' interface_id: ' || p_interface_id);

    -- If this is a regular RECEIPT_ADD transaction,
    -- we just need to note it

    IF (WSH_UTIL_CORE.FTE_IS_INSTALLED <> 'Y') THEN
        asn_debug.put_line('RCV_FTE_CALL_PVT.call_fte: fte not installed, skipping fte call');
        RETURN;
    END IF;

    IF (p_action = 'RECEIPT_ADD')
    THEN
        asn_debug.put_line('action: '|| p_action);
        rcv_fte_txn_lines_pvt.insert_row(
            p_shipment_header_id,
            p_shipment_line_id,
            l_txn_id,
            p_action,
            'Y');
        RETURN;
    END IF;

    l_action := p_action;

    IF (l_action = 'ASN')
    THEN l_rcv_txn := 'SHIP';
    ELSIF (l_action = 'RTV')
    THEN l_rcv_txn := 'RETURN TO VENDOR';
    ELSIF (l_action = 'MATCH')
    THEN l_rcv_txn := 'MATCH';
    ELSIF (l_action = 'RECEIPT')
    THEN l_rcv_txn := 'RECEIVE';
    ELSIF (l_action = 'CORRECT')
    THEN l_rcv_txn := 'CORRECT';
    ELSIF (l_action = 'CANCEL_ASN')
    THEN l_rcv_txn := 'CANCEL';
    END IF;

    IF (p_interface_id IS NOT NULL AND l_rcv_txn <> 'CANCEL')
    THEN
        SELECT transaction_id
        INTO l_txn_id
        FROM rcv_transactions
        WHERE shipment_header_id = p_shipment_header_id
        AND transaction_type = l_rcv_txn
        AND interface_transaction_id = p_interface_id
        AND rownum = 1;
    END IF;

    IF (p_action = 'CORRECT') THEN
        SELECT parent.transaction_type
        INTO l_txn_type
        FROM rcv_transactions parent, rcv_transactions child
        WHERE child.transaction_id = l_txn_id
        AND parent.transaction_id = child.parent_transaction_id;

        IF (l_txn_type = 'RECEIVE') THEN
            l_action := 'RECEIPT_CORRECTION';
        ELSIF (l_txn_type = 'RETURN TO VENDOR') THEN
            l_action := 'RTV_CORRECTION';
        ELSE RETURN;
        END IF;
    END IF;

    IF(p_action IN ('RECEIPT', 'SHIP', 'MATCH')) THEN
        SELECT count(rsl.shipment_line_id)
        INTO l_valid_lines
        FROM rcv_shipment_lines rsl,
             rcv_shipment_headers rsh,
             po_headers_all poh,
             po_lines_all pol,
             po_line_types_b plb
        WHERE
            rsh.shipment_header_id = p_shipment_header_id
        AND (rsl.shipment_line_id = p_shipment_line_id OR p_shipment_line_id IS NULL)
        AND rsl.shipment_header_id = rsh.shipment_header_id
        AND rsl.po_header_id = poh.po_header_id
        AND rsl.po_line_id = pol.po_line_id
        AND poh.type_lookup_code IN ('STANDARD', 'BLANKET')
        AND poh.shipping_control IS NOT NULL
        AND pol.line_type_id = plb.line_type_id
        AND plb.order_type_lookup_code = 'QUANTITY';

        IF (l_valid_lines = 0)
        THEN RETURN;
        END IF;
    END IF;

    IF (p_action = 'RECEIPT') THEN
        -- Check for RECEIPT_ADD
        -- If this is a Receipt against an ASN
        -- And there is an existing Receipt against an ASN
        -- Then this should be a RECEIPT_ADD
        -- Rather than a 'RECEIPT'
        SELECT asn_type
        INTO l_is_asn
        FROM rcv_shipment_headers
        WHERE shipment_header_id = p_shipment_header_id;

        IF (l_is_asn IS NOT NULL)
        THEN
            SELECT count(*)
            INTO l_has_receipt
            FROM rcv_fte_transaction_lines
            WHERE action = 'RECEIPT'
            AND reported_flag = 'Y'
            AND header_id = p_shipment_header_id;

            IF (l_has_receipt > 0)
            THEN
                l_action := 'RECEIPT_ADD';
            END IF; -- there is an existing receipt
        END IF; -- this is a receipt against ASN

        -- One more check for RECEIPT_ADD
        -- If there is a RECEIPT_ADD transaction
        -- with the same header_id as this receipt,
        -- then this is a RECEIPT_ADD
        SELECT count(*)
        INTO l_has_receipt
        FROM rcv_fte_transaction_lines
        WHERE action = 'RECEIPT_ADD'
        AND header_id = p_shipment_header_id;

        IF (l_has_receipt > 0)
        THEN
            l_action := 'RECEIPT_ADD';
        END IF;
    END IF; -- this is a receipt

    IF(p_action = 'MATCH') THEN
        -- This will be represented as a Match
        l_action := 'MATCH';
    END IF;


    rcv_fte_txn_lines_pvt.insert_row(
        p_shipment_header_id,
        p_shipment_line_id,
        l_txn_id,
        l_action);

    IF(l_action IN ('RTV_CORRECTION', 'RECEIPT_CORRECTION', 'RTV'))
    THEN
        po_delrec_pvt.create_update_delrec(
            1.0,
            l_return_status,
            l_msg_count,
            l_msg_data,
            l_action,
            'RCV',
            l_action,
            p_shipment_header_id,
            p_shipment_line_id,
            null);
        asn_debug.put_line('action: ' || p_action || 'l_action: ' || l_action || ' header_id: ' || p_shipment_header_id || ' line_id: ' || p_shipment_line_id || ' output: ' || l_return_status);
        asn_debug.put_line('error msg: ' || l_msg_data);
        IF (l_return_status = 'S')
        THEN
            rcv_fte_txn_lines_pvt.update_record_to_reported(
                p_shipment_header_id,
                p_shipment_line_id,
                l_action);
        ELSE
            rcv_fte_txn_lines_pvt.update_record_to_failed(
                p_shipment_header_id,
                p_shipment_line_id,
                l_action);
        END IF;
    END IF;

    asn_debug.put_line('action: ' || p_action || 'header_id: ' || p_shipment_header_id || ' line_id: ' || p_shipment_line_id || ' interface_id: ' || p_interface_id);


END call_fte;

PROCEDURE aggregate_calls
IS
    l_return_status     VARCHAR2(255);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    CURSOR all_calls IS
        SELECT a.header_id, a.action
        FROM rcv_fte_transaction_lines a, rcv_fte_transaction_lines b
        WHERE a.reported_flag  IN ('N','U')
        AND a.header_id = b.header_id
        AND b.reported_flag = 'N'
        GROUP BY a.header_id, a.action;
BEGIN
-- INSERT INTO ben_test VALUES ('IN AG CALLS ', SYSDATE);
    FOR call IN all_calls
    LOOP
        po_delrec_pvt.create_update_delrec(
            1.0,
            l_return_status,
            l_msg_count,
            l_msg_data,
            call.action,
            'RCV',
            call.action,
            call.header_id,
            null,
            null);
        asn_debug.put_line('action: ' || call.action || ' header_id: ' || call.header_id || ' output: ' || l_return_status);
        asn_debug.put_line('error msg: ' || l_msg_data);

        IF (l_return_status = 'S')
        THEN
            rcv_fte_txn_lines_pvt.update_record_to_reported(
                call.header_id,
                null,
                call.action);
        ELSE
            rcv_fte_txn_lines_pvt.update_record_to_unreported(
                call.header_id,
                null,
                call.action);
        END IF;
    END LOOP;
END aggregate_calls;

END RCV_FTE_CALL_PVT;

/
