--------------------------------------------------------
--  DDL for Package Body RCV_ROI_PREPROCESSOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_ROI_PREPROCESSOR" AS
/* $Header: RCVPREPB.pls 120.19.12010000.24 2014/07/22 19:01:50 smididud ship $*/
-- Read the profile option that enables/disables the debug log
    g_asn_debug      VARCHAR2(1)  := asn_debug.is_debug_on; -- Bug 9152790
    x_interface_type VARCHAR2(25) := 'RCV-856';

   /* Shikyu Project This helping function is needed for cursor*/
   FUNCTION get_oe_osa_flag(
      p_oe_order_line_id NUMBER
   )
      RETURN NUMBER IS
      x_return_status VARCHAR2(1);
      x_msg_count     NUMBER;
      x_msg_data      VARCHAR2(2000);
      x_is_enabled    VARCHAR2(1);
   BEGIN
      IF (p_oe_order_line_id IS NULL) THEN
         RETURN 2;
      ELSE
         jmf_shikyu_grp.is_so_line_shikyu_enabled(1,
                                                  fnd_api.g_false,
                                                  x_return_status,
                                                  x_msg_count,
                                                  x_msg_data,
                                                  p_oe_order_line_id,
                                                  x_is_enabled
                                                 );

         IF x_is_enabled = 'Y' THEN
            RETURN 1;
         ELSE
            RETURN 2;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 2;
   END get_oe_osa_flag;

    /* Checking if the transaction type is supported by ROI
     * */
    FUNCTION is_valid_txn_type(
                 p_txn_type rcv_transactions_interface.transaction_type%TYPE
    ) RETURN BOOLEAN IS
        TYPE txn_type_table IS TABLE OF rcv_transactions_interface.transaction_type%TYPE;
        -- define supported transaction types
        l_txn_type_tbl txn_type_table := txn_type_table ('SHIP'
                                                        ,'RECEIVE'
                                                        ,'DELIVER'
                                                        ,'TRANSFER'
                                                        ,'ACCEPT'
                                                        ,'REJECT'
                                                        ,'CORRECT'
                                                        ,'CANCEL'
                                                        ,'RETURN TO VENDOR'
                                                        ,'RETURN TO RECEIVING'
                                                        ,'RETURN TO CUSTOMER'
                                                        );
        i NUMBER;
     BEGIN
        FOR i in 1..l_txn_type_tbl.COUNT LOOP
            IF p_txn_type = l_txn_type_tbl(i) THEN
                RETURN TRUE;
            END IF;
        END LOOP;
        RETURN FALSE;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN FALSE;
    END is_valid_txn_type;

/*    FUNCTION get_header_record(
                  p_header_id rcv_transactions_interface.interface_header_id%TYPE
    ) RETURN header_record_type IS

    END get_header_record;
*/
    -- Bug 10227549 : Start
    PROCEDURE derive_destination_info
           (  x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
              n                IN OUT NOCOPY BINARY_INTEGER) IS

    l_destination_type VARCHAR2(10);
    BEGIN
        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('In derive_destination_info');
            asn_debug.put_line('x_cascaded_table(n).transaction_type      = ' || x_cascaded_table(n).transaction_type);
            asn_debug.put_line('x_cascaded_table(n).auto_transact_code    = ' || x_cascaded_table(n).auto_transact_code);
            asn_debug.put_line('x_cascaded_table(n).destination_type_code = ' || x_cascaded_table(n).destination_type_code);
            asn_debug.put_line('x_cascaded_table(n).destination_context   = ' || x_cascaded_table(n).destination_context);
        END IF;

        IF ( ( x_cascaded_table(n).transaction_type IN ('TRANSFER', 'ACCEPT', 'REJECT', 'UNORDERED', 'RETURN TO CUSTOMER'))  --bug 16360423
             OR
             ( x_cascaded_table(n).transaction_type = 'SHIP' AND
               x_cascaded_table(n).auto_transact_code = 'RECEIVE' )
             OR
             ( x_cascaded_table(n).transaction_type = 'RECEIVE' AND
               nvl(x_cascaded_table(n).auto_transact_code, 'RECEIVE') = 'RECEIVE')  )THEN
               x_cascaded_table(n).destination_type_code := 'RECEIVING';
               x_cascaded_table(n).destination_context   := 'RECEIVING';

        ELSIF ( x_cascaded_table(n).transaction_type IN  ('CORRECT', 'RETURN TO VENDOR')) THEN  --bug16360423,change the way to derive destination_type_code for RTV

                IF (x_cascaded_table(n).parent_transaction_id IS NOT NULL) THEN
                    SELECT destination_type_code,
                           destination_context
                    INTO   x_cascaded_table(n).destination_type_code,
                           x_cascaded_table(n).destination_context
                    FROM   rcv_transactions
                    WHERE  transaction_id = x_cascaded_table(n).parent_transaction_id;

                ELSE
                    rcv_roi_transaction.derive_parent_id (x_cascaded_table, n);

                    IF (x_cascaded_table(n).error_status <> 'E') THEN
                        IF ( x_cascaded_table(n).derive = 'Y'      AND
                             x_cascaded_table(n).derive_index > 0) THEN
                             -- Parent rti is loaded into x_cascaded_table (derive_index)
                             x_cascaded_table(n).destination_type_code := x_cascaded_table(x_cascaded_table(n).derive_index).destination_type_code;
                             x_cascaded_table(n).destination_context := x_cascaded_table(x_cascaded_table(n).derive_index).destination_context;

                        ELSIF ( x_cascaded_table(n).derive = 'Y'      AND
                                x_cascaded_table(n).derive_index = 0) THEN
                                -- Parent rti is not loaded into x_cascaded_table.
                                SELECT destination_type_code,
                                       destination_context
                                INTO   x_cascaded_table(n).destination_type_code,
                                       x_cascaded_table(n).destination_context
                                FROM   rcv_transactions_interface
                                WHERE  interface_transaction_id = x_cascaded_table(n).parent_interface_txn_id;
                        END IF;
                    END IF;
                END IF;

        ELSIF ( ( x_cascaded_table(n).transaction_type IN  ('DELIVER', 'RETURN TO RECEIVING'))
                OR
                ( x_cascaded_table(n).transaction_type IN ('SHIP', 'RECEIVE') AND
                  x_cascaded_table(n).auto_transact_code = 'DELIVER' ) )THEN

                IF (x_cascaded_table(n).source_document_code IN ('INVENTORY', 'RMA')) THEN
                    x_cascaded_table(n).destination_type_code := 'INVENTORY';
                    x_cascaded_table(n).destination_context   := 'INVENTORY';

                ELSIF (x_cascaded_table(n).source_document_code = 'REQ') THEN
                    SELECT destination_type_code,
                           destination_type_code
                    INTO   x_cascaded_table(n).destination_type_code,
                           x_cascaded_table(n).destination_context
                    FROM   po_requisition_lines_all
                    WHERE  requisition_line_id = x_cascaded_table(n).requisition_line_id;

                ELSIF (x_cascaded_table(n).source_document_code = 'PO' AND
                       x_cascaded_table(n).po_distribution_id IS NOT NULL) THEN
                    SELECT destination_type_code,
                           destination_type_code
                    INTO   x_cascaded_table(n).destination_type_code,
                           x_cascaded_table(n).destination_context
                    FROM   po_distributions_all
                    WHERE  po_distribution_id = x_cascaded_table(n).po_distribution_id;
                END IF;
        END IF;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('New x_cascaded_table(n).destination_type_code = ' || x_cascaded_table(n).destination_type_code);
            asn_debug.put_line('New x_cascaded_table(n).destination_context   = ' || x_cascaded_table(n).destination_context);
            asn_debug.put_line('Leaving derive_destination_info');
        END IF;

    EXCEPTION
    WHEN OTHERS THEN
        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Exception in derive_destination_info');
            asn_debug.put_line('sqlerrm : ' || SQLERRM);
        END IF;
        x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;

    END derive_destination_info;
    -- Bug 10227549 : End

    /* Preprocess replaces rcv_shipment_object_sv.create_object with a cleaner structure. */
    PROCEDURE preprocessor(
        x_request_id NUMBER,
        x_group_id   NUMBER
    ) IS
        x_error_record           rcv_roi_preprocessor.error_rec_type;
        x_header_record          rcv_roi_preprocessor.header_rec_type;
        x_cascaded_table         rcv_roi_preprocessor.cascaded_trans_tab_type;
        x_progress               VARCHAR2(3)                                                := '000';
        x_fail_all_lines         VARCHAR2(1)                                                := 'N';
        x_fail_if_one_line_fails BOOLEAN                                                    := FALSE;
        n                        BINARY_INTEGER                                             := 0;
        x_empty_header_record    rcv_roi_preprocessor.header_rec_type;
--added for lpn support
        l_lpn_grp_id             rcv_transactions_interface.lpn_group_id%TYPE;
        l_proc_status_code       rcv_transactions_interface.processing_status_code%TYPE;
        l_group_id               rcv_transactions_interface.GROUP_ID%TYPE; -- used in local query
        p_group_id               rcv_transactions_interface.GROUP_ID%TYPE; -- matches the passed in value
        p_request_id             rcv_transactions_interface.processing_request_id%TYPE;
        l_update_lpn_group       BOOLEAN                                                    := FALSE;
        l_failed_rows_exist      NUMBER                                                     := 0;
        l_txn_code               VARCHAR2(10);
        l_lpn_group_id           NUMBER;
        l_ship_header_id         NUMBER;
        l_ret_status             VARCHAR2(20);
        l_msg_count              NUMBER;
        l_msg_data               VARCHAR2(100);
        l_temp                   NUMBER;
        l_group_count            NUMBER;
        l_return_status1         VARCHAR2(1);
        l_msg_count1             NUMBER;
        l_msg_data1              fnd_new_messages.MESSAGE_TEXT%TYPE;
        l_to_org_id              rcv_transactions_interface.to_organization_id%TYPE;
        l_drop_ship_exists       NUMBER; /* Bug3705658 */
        l_auto_deliver           VARCHAR2(1) := 'N'; /* Bug3705658 */
        x_site_id_count          NUMBER := 0; -- Bug 4355172
        l_count                  NUMBER;  --Bug 4881909
        l_fsc_enabled            VARCHAR2(1)    := NVL(fnd_profile.VALUE('RCV_FSC_ENABLED'), 'N');
        l_prev_org_id MO_GLOB_ORG_ACCESS_TMP.ORGANIZATION_ID%TYPE;  --<R12 MOAC>
        l_transaction_type_old   VARCHAR2(40); -- Bug 7684677

        TYPE group_id_pool IS TABLE OF NUMBER
            INDEX BY BINARY_INTEGER;

        l_exception_group_id     group_id_pool;
	l_return_status          VARCHAR2(1);
	l_check_dcp                  NUMBER;
	x_empty_error_record           rcv_roi_preprocessor.error_rec_type;

/*        TYPE header_record_cache IS TABLE OF rcv_roi_preprocessor.header_rec_type
            INDEX BY BINARY_INTEGER;

        l_header_record_cache    header_record_cache;
*/
        CURSOR distinct_groups(
            p_request_id NUMBER
        ) IS
            SELECT DISTINCT (GROUP_ID)
            FROM            rcv_transactions_interface
            WHERE           processing_request_id = p_request_id
            AND             processing_status_code = 'RUNNING';

/* Bug 3434460.
 * We need to set transfer_lpn_ids for all deliver transactions
 * for non-wms orgs. Get all the org_ids that belong to this group.
*/
        CURSOR distinct_org_id(
            p_request_id NUMBER,
            p_group_id   NUMBER
        ) IS
            SELECT DISTINCT (to_organization_id)
            FROM            rcv_transactions_interface
            WHERE           processing_request_id = p_request_id
            AND             (group_id = p_group_id or p_group_id = 0)
            AND             processing_status_code = 'RUNNING'
            AND             to_organization_id IS NOT NULL;

        CURSOR get_bad_asbn_shikyu IS --Shikyu project
           SELECT   header_interface_id
           FROM     (SELECT rsh.header_interface_id,
                            DECODE(NVL(poll.outsourced_assembly, get_oe_osa_flag(rti.oe_order_line_id)),
                                   1, 1,
                                   NULL
                                  ) osa_flag
                     FROM   rcv_headers_interface rsh,
                            rcv_transactions_interface rti,
                            po_line_locations_all poll
                     WHERE  rsh.asn_type = 'ASBN'
                     AND    rsh.header_interface_id = rti.header_interface_id
                     AND    poll.line_location_id (+) = rti.po_line_location_id
                     AND    rti.processing_status_code = 'RUNNING')
           GROUP BY header_interface_id
           HAVING   COUNT(*) > COUNT(osa_flag)
           AND      COUNT(osa_flag) > 0;

	/*Added for the RCV DCP. This cursors is used to loop through the
	 * * records in RHI*/
/* Moved this cursor as well as its for loop to the rcv_dcp_pvt package */
/*	CURSOR headers_cur_dcp(x_request_id NUMBER, x_group_id NUMBER) IS
		SELECT *
		FROM rcv_headers_interface
		WHERE NVL(asn_type, 'STD') IN('ASN', 'ASBN', 'STD', 'WC')
			AND processing_status_code IN('RUNNING', 'SUCCESS','ERROR','PENDING')
			AND(NVL(validation_flag, 'N') = 'Y'
				OR processing_status_code = 'SUCCESS') -- include success row for multi-line asn
			AND(processing_request_id IS NULL
				OR processing_request_id = x_request_id)
			AND GROUP_ID = DECODE(x_group_id, 0, GROUP_ID, x_group_id); */
        -- Bug 8831292
        CURSOR errored_asn_rhi_cursor IS
           SELECT *
           FROM   rcv_headers_interface rhi
           WHERE  asn_type IN ('ASN', 'ASBN')
           AND    processing_request_id = p_request_id
           AND    (group_id = p_group_id or p_group_id = 0)
           AND    (processing_status_code = 'ERROR'
                   OR
                   EXISTS (SELECT 1
                           FROM   rcv_transactions_interface rti
                           WHERE  rti.header_interface_id = rhi.header_interface_id
                           AND    rti.processing_status_code = 'ERROR'));

           x_asn_rhi_record   rcv_roi_preprocessor.header_rec_type;

    BEGIN
         <<dcp_pre_processor_start>>
	 g_asn_debug := asn_debug.is_debug_on; -- Bug 9152790


        /* For online mode, we send request_id as null. Consider it as -999 if
         * it is null.
        */
        p_request_id := NVL(x_request_id, 0);
        p_group_id   := NVL(x_group_id, 0);

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Entering preprocessor. Request_id = ' || p_request_id || ',Group_id=' || p_group_id);
        END IF;

	SAVEPOINT dcp_preprocessor_start;
	l_check_dcp := rcv_dcp_pvt.g_check_dcp;

	IF l_check_dcp IS NULL THEN
		l_check_dcp := rcv_dcp_pvt.is_dcp_enabled;
	END IF;

        -- Cache basic configuration options
        IF (g_is_edi_installed IS NULL) THEN
            g_is_edi_installed  := po_core_s.get_product_install_status('EC');
        END IF;

        /* get the profile option */
        fnd_profile.get('RCV_FAIL_IF_LINE_FAILS', x_fail_all_lines);

        IF x_fail_all_lines = 'Y' THEN
            x_fail_if_one_line_fails  := TRUE;
        END IF;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('RCV_FAIL_IF_LINE_FAILS profile option =' || x_fail_all_lines);
        END IF;

        /* the garbage collector is no longer needed by essential character of the normalization package.
           if a row belongs to an org, run it, else fail it (or leave it pending).
           LPN explosion has to happen before defaulting so it was moved into the normalization package.
           The order_transaction_id is set by the default package
        */


        l_prev_org_id := -999;  --<R12 MOAC>

        /* 3434460.
         * We need to set transfer_lpn_ids to null for all Deliver type
         * of transactions (Deliver/Direct Delivery). This needs to
         * be done for all non-wms orgs.
        */

/* Bug#6862487: Performance issue fix.
   1) The following update statement performs badly in ONLINE mode,
      as the processing_request_id of RTI will be null.
      This update statement is required only in case of BATCH mode
      to clear off the lpn references for Non-WMS organizations in case
      user populated the lpn references by mistake.
      ONLINE mode is used programatically by the application code, so it is
      not possible to get lpn references for Non wms orgn.
      So, we can safely skip the following code in case of ONLINE mode.
      For ONLINE mode, request_id will be null and ProC treats null value as
      zero. So,if p_request_id is zero, then it is ONLINE mode.
  2)  Removed the group_id condition added as part of this bug fix.
      If RTP is launched without group_id, then p_group_id of preprocessor()
      would be null. So, removed that condition.
  3)  Added close distinct_org_id, as there is no close cursor statement.
 */
      if p_request_id <> 0 then --Bug#6862487
        OPEN distinct_org_id(p_request_id, p_group_id);

        LOOP
            FETCH distinct_org_id INTO l_to_org_id;
            EXIT WHEN distinct_org_id%NOTFOUND;

            IF (    NOT wms_install.check_install(l_return_status1,
                                                  l_msg_count1,
                                                  l_msg_data1,
                                                  l_to_org_id
                                                 )
                AND l_return_status1 = fnd_api.g_ret_sts_success) THEN
                UPDATE rcv_transactions_interface
                   SET transfer_lpn_id = NULL,
                       transfer_license_plate_number = NULL
                 WHERE processing_request_id = p_request_id
                AND    to_organization_id = l_to_org_id
                AND    (   (transaction_type = 'DELIVER')
                        OR (    transaction_type = 'RECEIVE'
                            AND auto_transact_code = 'DELIVER'));

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Set transfer_lpn_id and transfer_license_plate_number to null for deliver transactions for the non-wms org ' || l_to_org_id);
                END IF;
            END IF;
        END LOOP;
        CLOSE distinct_org_id;--Bug#6862487
      else--Online mode transaction
         if (g_asn_debug = 'Y') then
            asn_debug.put_line('Skipped Set transfer_lpn_id and transfer_license_plate_number to null for ONLINE mode txn '||p_request_id);
         end if;
      end if;--Bug#6862487
        /* End of 3434460. */
        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('After update to order_transaction_id');
        END IF;

        /* this belongs before the transaction looping */
        FOR bad_shikyu IN get_bad_asbn_shikyu LOOP --Shikyu project
           BEGIN
              rcv_error_pkg.set_error_message('RCV_BAD_ASBN_SHIKYU');
              rcv_error_pkg.set_token('HEADER_INTERFACE_ID', bad_shikyu.header_interface_id);
              rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE',
                                                'HEADER_INTERFACE_ID',
                                                x_group_id,
                                                bad_shikyu.header_interface_id,
                                                NULL,
                                                FALSE
                                               );

              UPDATE rcv_headers_interface
                 SET processing_status_code = 'ERROR'
               WHERE header_interface_id = bad_shikyu.header_interface_id;

              UPDATE rcv_transactions_interface
                 SET processing_status_code = 'ERROR'
               WHERE header_interface_id = bad_shikyu.header_interface_id;
           EXCEPTION
              WHEN OTHERS THEN
                 NULL;
           END;
        END LOOP;

        OPEN rcv_roi_preprocessor.txns_cur(p_request_id, p_group_id);

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Opened transactions cursor.');
        END IF;

        x_progress  := '010';
        n           := 0;
        x_cascaded_table.DELETE;

        -- Loop through the entries in rcv_transactions_interface.
        LOOP --{
            asn_debug.put_line('enter loop');
            n                                   := n + 1;
            FETCH rcv_roi_preprocessor.txns_cur INTO x_cascaded_table(n);
            EXIT WHEN rcv_roi_preprocessor.txns_cur%NOTFOUND;
            x_cascaded_table(n).error_status    := 'S';
            x_cascaded_table(n).error_message   := NULL;
            x_cascaded_table(n).derive          := 'N';
            x_cascaded_table(n).matching_basis  := 'QUANTITY';
            x_cascaded_table(n).purchase_basis  := 'GOODS';
            x_cascaded_table(n).derive_index    := 0;
            l_proc_status_code                  := 'SUCCESS';
            l_update_lpn_group                  := FALSE;
            l_transaction_type_old :=      x_cascaded_table(n).transaction_type; -- Bug 7684677

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Current counter is ' || TO_CHAR(n));
                asn_debug.put_line('No of records in cascaded table ' || TO_CHAR(x_cascaded_table.COUNT));
                asn_debug.put_line('header interface id is ' || TO_CHAR(x_cascaded_table(n).header_interface_id));
            END IF;

            x_progress                          := '040';
            rcv_error_pkg.initialize(x_cascaded_table(n).GROUP_ID,
                                     x_cascaded_table(n).header_interface_id,
                                     x_cascaded_table(n).interface_transaction_id
                                    );


            -- Check if it's a valid transaction type
            IF NOT is_valid_txn_type(x_cascaded_table(n).transaction_type) THEN
                x_cascaded_table(n).error_status  := 'E';
                x_cascaded_table(n).error_message := 'RCV_ROI_INVALID_TXN_TYPE';
                rcv_error_pkg.set_error_message('RCV_ROI_INVALID_TXN_TYPE');
                rcv_error_pkg.set_token('TXN_TYPE', x_cascaded_table(n).transaction_type);
                rcv_error_pkg.log_interface_error('TRANSACTION_TYPE', FALSE);
                -- mark it's a line error
                l_update_lpn_group := TRUE;
            END IF ;

            --<R12 MOAC START>

            IF ( (l_prev_org_id = -999) OR (l_prev_org_id <>  x_cascaded_table(n).org_id )
             AND ( x_cascaded_table(n).org_id is NOT NULL ) ) THEN

               MO_GLOBAL.set_policy_context('S',TO_NUMBER(x_cascaded_table(n).org_id));

               IF (g_asn_debug = 'Y') THEN
                   asn_debug.put_line('Setting Operating unit context to ' ||x_cascaded_table(n).org_id);
               END IF;

               l_prev_org_id := x_cascaded_table(n).org_id;

            END IF;

           --<R12 MOAC END>

            -- added for parent child support
            BEGIN
                IF x_cascaded_table(n).parent_interface_txn_id IS NOT NULL THEN --{
                    BEGIN
                        SELECT processing_status_code
                        INTO   l_proc_status_code
                        FROM   rcv_transactions_interface
                        WHERE  interface_transaction_id = x_cascaded_table(n).parent_interface_txn_id;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            rcv_error_pkg.set_error_message('RCV_NO_PARENT_TRANSACTION');
                            rcv_error_pkg.log_interface_error('PARENT_INTERFACE_TXN_ID');
                    END;

                    IF l_proc_status_code = 'ERROR' THEN
                        RAISE rcv_error_pkg.e_fatal_error;
                    END IF;
                --END IF; --}  --bug 17207201,to inclue the following code in the condition since it's for parent child support

                -- Bug 7651646:
                -- Parent_source_transaction_num should be referenced to Source_transaction_num in RT.
                -- Removing the code that checks rti.parent_source_transaction_num against RTI.source_transaction_num.
                -- end added for parent child support(*)

                -- if parent not errored out, see if this row is already errored out in rti because of something else
                BEGIN
                    SELECT processing_status_code
                    INTO   l_proc_status_code
                    FROM   rcv_transactions_interface
                    WHERE  interface_transaction_id = x_cascaded_table(n).interface_transaction_id;

                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        rcv_error_pkg.set_error_message('RCV_INVALID_TRANSACTION_TYPE');
                        rcv_error_pkg.log_interface_error('INTERFACE_TRANSACTION_ID');
                END;

                IF l_proc_status_code = 'ERROR' THEN
                    RAISE rcv_error_pkg.e_fatal_error;
                END IF;
                END IF;       --bug 17207201
            EXCEPTION
                WHEN rcv_error_pkg.e_fatal_error THEN
                    x_cascaded_table(n).error_status            := 'E';
                    x_cascaded_table(n).error_message           := rcv_error_pkg.get_last_message;
                    x_cascaded_table(n).processing_status_code  := 'ERROR';
            END;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('l_proc_status_code ' || l_proc_status_code);
            END IF;

            -- begin processing of the header
            -- does the row have a header
            IF (    (x_cascaded_table(n).header_interface_id IS NOT NULL)
                AND (x_cascaded_table(n).error_status NOT IN ('P', 'E'))) THEN --{
                -- find out if failed lines exist for this header in rti
                SELECT COUNT(*)
                INTO   l_failed_rows_exist
                FROM   rcv_transactions_interface
                WHERE  processing_status_code = 'ERROR'
                AND    header_interface_id = x_cascaded_table(n).header_interface_id;

                -- if this is an asn which has failed lines and
                IF     l_failed_rows_exist >= 1
                   AND x_fail_if_one_line_fails
                   AND x_cascaded_table(n).transaction_type = 'SHIP'
                   /* bug 7684677 rcv:fail all asn lines if one line fails doesn't work for ship */
                   AND x_cascaded_table(n).auto_transact_code in ('SHIP','RECEIVE','DELIVER') THEN
                    x_error_record.error_status   := 'E';
                    x_error_record.error_message  := NULL;
                    x_cascaded_table(n).error_status:='E';
                    l_update_lpn_group  := TRUE;
                    /* end bug 7684677 */
                ELSE
                    x_error_record.error_status   := 'S';
                    x_error_record.error_message  := NULL;
                END IF;

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('x_error_record.error_status: '|| x_error_record.error_status);
                    asn_debug.put_line('transaction_type: '||x_cascaded_table(n).transaction_type);
                    asn_debug.put_line('header_record.header_id: '||x_header_record.header_record.header_interface_id);
                    asn_debug.put_line('x_cascaded_table(n).header_interface_id: '||x_cascaded_table(n).header_interface_id);
                END IF;

                /* If rhi is success and all the other processed rti rows
                 * in the same header id is also successful.
                */

                IF (x_error_record.error_status IN('S', 'W')) THEN --{
                    IF x_cascaded_table(n).header_interface_id <>
                            nvl(x_header_record.header_record.header_interface_id, -1) THEN
                    --{ exclude the case where the current trxn shares header with the previous trxn.
                           IF (g_asn_debug = 'Y') THEN
                               asn_debug.put_line('Initialize header record for RTI id: '||
                                                   to_char(x_cascaded_table(n).interface_transaction_id));
                           END IF;
                           x_header_record  := x_empty_header_record;
                           -- initialize error_record
                           x_header_record.error_record  := x_error_record;

                        OPEN rcv_roi_preprocessor.headers_cur(p_request_id,
                                                              p_group_id,
                                                              x_cascaded_table(n).header_interface_id
                                                             );
                        IF (g_asn_debug = 'Y') THEN
                            asn_debug.put_line('Before processing header');
                        END IF;

                        FETCH rcv_roi_preprocessor.headers_cur INTO x_header_record.header_record;
                            -- there should be 1 header record for this transaction
                        asn_debug.put_line('Processing header for interface txn id =' ||
                                            TO_CHAR(x_cascaded_table(n).interface_transaction_id));
                        -- header cursor found, header is not processed yet : process the header
                        IF RCV_ROI_PREPROCESSOR.headers_cur%FOUND THEN --{
                          IF x_header_record.header_record.processing_status_code = 'RUNNING' THEN --{
                            IF (x_cascaded_table(n).transaction_type IN ('SHIP', 'RECEIVE')) THEN --{

                                IF x_header_record.header_record.transaction_type = 'NEW' THEN --{
                                    -- Second, switch on the header receipt source code
                                    IF x_header_record.header_record.receipt_source_code = 'VENDOR' THEN
                                        -- This is either a PO, ASN, or ASBN RECEIVE or SHIP
                                        rcv_roi_header.process_vendor_header(x_header_record);
                                    ELSIF x_header_record.header_record.receipt_source_code = 'CUSTOMER' THEN
                                        -- This is an RMA RECEIVE
                                        rcv_roi_header.process_customer_header(x_header_record);
                                    /* Bug 3314675.
                                     * Change the receipt_source_code to INVENTORY from INTERNAL and
                                     * Call process_internal_order_header to process inter-org shipment
                                     * receipts.
                                    */
                                    ELSIF x_header_record.header_record.receipt_source_code = 'INVENTORY' THEN
                                        -- This is an Inter-Org Transfer RECEIVE
                                        rcv_roi_header.process_internal_order_header(x_header_record);
                                    ELSIF x_header_record.header_record.receipt_source_code = 'INTERNAL ORDER' THEN
                                        -- This is an Internal Order RECEIVE
                                        rcv_roi_header.process_internal_order_header(x_header_record);
                                    END IF; -- Switch on receipt source code
                                ELSE --}{ txn not new
                                    IF (x_header_record.header_record.transaction_type = 'CANCEL') THEN --{
                                    -- Cancelling an ASN or ASBN
                                        rcv_roi_header.process_cancellation(x_header_record);

                                        IF (x_header_record.error_record.error_status NOT IN('S', 'W')) THEN --{
                                            -- the cancellation failed
                                            IF (g_asn_debug = 'Y') THEN
                                                asn_debug.put_line('RCV_ASN_NOT_ACCEPT');
                                                asn_debug.put_line('The header has failed ' || TO_CHAR(x_header_record.header_record.header_interface_id));
                                                asn_debug.put_line('ASN could not be cancelled');
                                            END IF;

                                            rcv_error_pkg.set_error_message('RCV_ASN_NOT_ACCEPT');
                                            rcv_error_pkg.set_token('SHIPMENT', x_header_record.header_record.shipment_num);
                                            rcv_error_pkg.log_interface_error('SHIPMENT_NUM', FALSE);
                                        END IF; --}
                                    END IF; -- }
                                END IF; -- } switch on transaction type (supporting new/cancel)
                            ELSE --}{ if transaction_type is receive or ship
                                -- Any other trxns here would be a transaction with fault header record
                                -- Keep the header_interface_id so that if the txn fails the header can be errored.
                                -- x_cascaded_table(n).header_interface_id := NULL;
                                x_header_record  := x_empty_header_record;
                                x_header_record.error_record.error_status := 'W';
                                rcv_error_pkg.set_error_message('RCV_ROI_FAULT_HEADER');
                                rcv_error_pkg.set_token('TXN_TYPE', x_cascaded_table(n).transaction_type);
                                rcv_error_pkg.log_interface_error('TRANSACTION_HEADER_ID', FALSE);

                            END IF; --}
                          END IF; --} if processing_status_code is running
                        ELSE   -- } { no header row is picked up by header cursor
                            -- header record is missing. need to error out this trxn.
                            IF (g_asn_debug = 'Y') THEN
                                 asn_debug.put_line('Header missing for trxn '||
                                                     to_char(x_cascaded_table(n).interface_transaction_id) ||', set error_status to E');
                            END IF;
                            x_header_record.error_record.error_status := 'E';
                            -- need to insert po_inerface_errors
                            rcv_error_pkg.set_error_message('RCV_ROI_HEADER_MISSING');
                            rcv_error_pkg.set_token('TXN_TYPE', x_cascaded_table(n).transaction_type);
                            rcv_error_pkg.log_interface_error('HEADER_INTERFACE_ID', FALSE);
                        END IF; --} this is the check for whether header is processed

                        asn_debug.put_line('closing the header cursor for txn = ' || TO_CHAR(x_cascaded_table(n).interface_transaction_id));
                        CLOSE rcv_roi_preprocessor.headers_cur;
                    END IF; --} matches excluding shared header.

                    -- after processing header update rhi/rti
                    -- IF (x_header_record.error_record.error_status = 'E') THEN -- Bugfix 5592848
                    IF (x_header_record.error_record.error_status NOT IN ('S', 'W', 'P') ) THEN --{ -- Bugfix 5592848
                                                                              -- header errored out
                                                                              -- 1) update rhi
                        -- x_header_record.header_record might still be null in this case
                        -- if no row found in RHI, a no_data_found exception will be raised
                        UPDATE rcv_headers_interface
                           SET processing_status_code = 'ERROR'
                        WHERE header_interface_id = x_cascaded_table(n).header_interface_id;

                        x_header_record.header_record.processing_status_code  := 'ERROR';
                        x_header_record.error_record.error_status             := 'E';

                        /* Bug 4344351: Log a message indicating an error in RCV_HEADERS_INTERFACE table.*/
                        rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE','',FALSE);

                        -- 2) update rti
                        IF (g_asn_debug = 'Y') THEN
                            asn_debug.put_line('update_rti_error after rhi error ');
                        END IF;

                        update_rti_error(p_group_id                => x_cascaded_table(n).GROUP_ID,
                                         p_interface_id            => NULL,
                                         p_header_interface_id     => x_header_record.header_record.header_interface_id,
                                         p_lpn_group_id            => NULL
                                        );
                        -- 3) should update the error status for this row
                        x_cascaded_table(n).error_status                      := 'E';
                    /* Bug 3359613.
                     * Set error_Status to P in x_cascaded_table so that
                     * we dont process the rti row which belongs to a
                     * different OU.
                    */
                    ELSIF (x_header_record.error_record.error_status = 'P') THEN --}{
                        IF (g_asn_debug = 'Y') THEN
                            asn_debug.put_line('Set x_cascaded_table.error_status to P');
                        END IF;

                        x_cascaded_table(n).error_status            := 'P';
                        x_cascaded_table(n).processing_status_code  := 'PENDING';
                    ELSE -- }{ the header was processed successfully
                        UPDATE rcv_headers_interface
                           SET processing_status_code = 'SUCCESS',
                               validation_flag = 'N',
                               receipt_header_id = x_header_record.header_record.receipt_header_id
                         WHERE header_interface_id = x_header_record.header_record.header_interface_id
                           AND processing_status_code <> 'SUCCESS';

                        IF (g_asn_debug = 'Y') THEN
                            asn_debug.put_line('RCV_ASN_ACCEPT_NO_ERR');
                        END IF;
                    END IF; --} header errored out
                 /** Bug 8717477 when x_error_record.error_status is error, we also need x_header_record.header_record for following code **/
                 ELSE    -- IF (x_error_record.error_status IN('S', 'W')) THEN
                        IF x_cascaded_table(n).header_interface_id <>
                            nvl(x_header_record.header_record.header_interface_id, -1) THEN
                            IF (g_asn_debug = 'Y') THEN
                               asn_debug.put_line('x_error_record.error_status:' || x_error_record.error_status);
                               asn_debug.put_line('Initialize header record for RTI id: '||
                                                   to_char(x_cascaded_table(n).interface_transaction_id));
                            END IF;
                            x_header_record  := x_empty_header_record;
                            x_header_record.error_record  := x_error_record;
                            OPEN rcv_roi_preprocessor.headers_cur(p_request_id,
                                                              p_group_id,
                                                              x_cascaded_table(n).header_interface_id
                                                             );
                            FETCH rcv_roi_preprocessor.headers_cur INTO x_header_record.header_record;
                            IF RCV_ROI_PREPROCESSOR.headers_cur%NOTFOUND THEN --{
                               -- header record is missing. need to error out this trxn.
                              IF (g_asn_debug = 'Y') THEN
                                  asn_debug.put_line('Header missing for trxn '||
                                                      to_char(x_cascaded_table(n).interface_transaction_id) ||', set error_status to E');
                              END IF;
                              x_header_record.error_record.error_status := 'E';
                              -- need to insert po_inerface_errors
                              rcv_error_pkg.set_error_message('RCV_ROI_HEADER_MISSING');
                              rcv_error_pkg.set_token('TXN_TYPE', x_cascaded_table(n).transaction_type);
                              rcv_error_pkg.log_interface_error('HEADER_INTERFACE_ID', FALSE);

                            END IF;
                            asn_debug.put_line('closing the header cursor for txn = ' || TO_CHAR(x_cascaded_table(n).interface_transaction_id));
                            CLOSE rcv_roi_preprocessor.headers_cur;

                        END IF;
                  /**End Bug 8717477 **/
                END IF; --}  matches with x_error_record.error_record <> E
            ELSE --}{
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('reset header record to empty for headerless trxns or errored out trxns '||
                                        to_char(x_cascaded_table(n).interface_transaction_id) );
                END IF;
                x_header_record  := x_empty_header_record;
            END IF;         --} matches with whether transaction has header
                    -- end processing of the header

                    -- if this row is still not error => if it is later in status error => it failed because of process line

            IF x_cascaded_table(n).error_status IN('S', 'W') THEN
                l_update_lpn_group  := TRUE;
            END IF;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('After processing header for this transaction:');
                asn_debug.put_line('X_cascaded_table(n).header_interface_id=' || x_cascaded_table(n).header_interface_id);
                asn_debug.put_line('X_header_record.error_record.error_status=' || x_header_record.error_record.error_status);
                asn_debug.put_line('x_cascaded_table(n).error_status=' || x_cascaded_table(n).error_status);
                asn_debug.put_line('x_cascaded_table(n).error_message=' || x_cascaded_table(n).error_message);
            END IF;

          /* bug 4368726, for asn cancel's the call rcv_roi_header.process_cancellation(x_header_record)
             will delete all the pending RTI rows and insert new RTI rows ready for the processor.
             Processing these deleted rows causes an unhandled exception when deleting the ROWID later on
             which will produce the invalid transaction error and then will cause all the subsequent transactions
             in the group to fail. What's the point of even having transactions to a cancel because it's entirely
             determined by the header. The only thing a transaction is needed for it to produce an entry in the
             looping cursor.
          */
          IF (NVL(x_header_record.header_record.transaction_type,'NEW') <> 'CANCEL') THEN --{
            BEGIN --{ processing lines
                IF (    x_cascaded_table(n).header_interface_id IS NOT NULL
                    AND x_header_record.error_record.error_status IN('S', 'W')
                    AND x_cascaded_table(n).error_status IN('S', 'W')) THEN                                                          --{
                                                                            -- header has been processed and is valid
                                                                            -- process the line
                    /* Receipt_source_code is mandatory for
                     * rhi. Get the value and default it if it is null
                     * in x_Cascaded_table.
                   */
                    IF (x_cascaded_table(n).receipt_source_code IS NULL) THEN
                        x_cascaded_table(n).receipt_source_code  := x_header_record.header_record.receipt_source_code;
                    END IF;

                    process_line(x_cascaded_table,
                                 n,
                                 x_header_record.header_record.header_interface_id,
                                 x_header_record.header_record.asn_type,
                                 x_header_record
                                );
                END IF; --} end for a valid processed header

                        -- this is the case for a headerless transaction

                IF (    x_cascaded_table(n).header_interface_id IS NULL
                    AND x_cascaded_table(n).error_status IN('S', 'W')) THEN                                                         --{
                                                                            -- 1) process the childless transaction
                                                                            -- process the line
                    /* Error out if receipt_source_code is null. We need it
                     * to process rti row.
                    */
                    rcv_error_pkg.test_is_null(x_cascaded_table(n).receipt_source_code,
                                               'RECEIPT_SOURCE_CODE',
                                               'RCV_RECEIPT_SOURCE_CODE_REQ'
                                              );
                    process_line(x_cascaded_table,
                                 n,
                                 x_header_record.header_record.header_interface_id,
                                 x_header_record.header_record.asn_type,
                                 x_header_record
                                );
                END IF; --} end of processing a headerless transaction

                -- R12: Freight and Special Charges
                -- Preprocess charges for receipt or ASN if charges coresponding
                -- to this transaction exist in RCI.
                 IF (x_cascaded_table(n).transaction_type IN ('SHIP', 'RECEIVE')
                     AND x_header_record.error_record.error_status IN('S', 'W')
	             AND rcv_table_functions.is_lcm_shipment(x_cascaded_table(n).po_line_location_id) = 'N'  -- lcm changes
                     AND x_cascaded_table(n).error_status IN('S', 'W')) THEN --{

                      /* Bug 7830436: Code changes to Freight and Special Charges flow */
		      if nvl(l_fsc_enabled,'N') = 'N' then
		         asn_debug.put_line('Freight and Special Charges is disabled, so charges are not processed');
		      else
		      RCV_CHARGES_GRP.preprocess_charges
                           ( p_api_version        => 1.0
                           , p_init_msg_list      => 'Y'
                           , x_return_status      => x_cascaded_table(n).error_status
                           , x_msg_count          => l_msg_count
                           , x_msg_data           => l_msg_data
                           , p_header_record      => x_header_record.header_record
                           , p_transaction_record => x_cascaded_table(n)
                           );
		      end if;

                 END IF; --}

            EXCEPTION
                WHEN rcv_error_pkg.e_fatal_error THEN
                    x_cascaded_table(n).error_status   := 'E';
                    x_cascaded_table(n).error_message  := rcv_error_pkg.get_last_message;
            END; --} processing lines
                 -- update the rti row to error

            IF (    x_cascaded_table(n).error_status NOT IN('S', 'W')
                AND l_update_lpn_group) THEN
                -- write to po_interface_errors for all shipments
                IF ( --(X_cascaded_table(n).header_interface_id is not null) and
                         (    x_fail_if_one_line_fails
                          AND x_cascaded_table(n).transaction_type = 'SHIP')
                      OR (   x_cascaded_table(n).error_message = 'RCV_REJECT_ASBN_CONSIGNED_PO'
                          OR x_cascaded_table(n).error_message = 'RCV_REJECT_CONSUMPTION_PO'
                          OR x_cascaded_table(n).error_message = 'RCV_REJECT_CONSUMPTION_RELEASE')
                   ) THEN
                    rcv_error_pkg.set_error_message('RCV_ASN_NOT_ACCEPT');
                    rcv_error_pkg.set_token('SHIPMENT', x_header_record.header_record.shipment_num);
                    rcv_error_pkg.log_interface_error('SHIPMENT_NUM', FALSE);
                END IF;
            END IF;

            -- insert the split rti rows back into rti
            -- also call the wms api to split their lot serial info

            /* Bug 4881909 : Call handle_rcv_asn_transactions() only if the
            **               error_status is 'S' or 'W'
            */
            IF (x_cascaded_table(n).error_status NOT IN('S', 'W')) THEN

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Skipping call to handle_rcv_asn_txn ');
                END IF;
                x_cascaded_table(n).processing_status_code  := 'ERROR';
                l_proc_status_code                          := 'ERROR';
            ELSE

                /* If the txn is successful, set rsh.asn_status to null if it is marked as a 'NEW_SHIP'
                 * so that the rsh record will not be deleted later on.
                 *
                 * rsh.asn_status will remain as 'NEW_SHIP' until one line goes through. If all the
                 * lines have failed, the asn_status will remain as 'NEW_SHIP' and the rsh will be deleted.
                **/
                UPDATE rcv_shipment_headers
                   SET asn_status = null
                 WHERE (shipment_header_id = x_cascaded_table(n).shipment_header_id
                        OR shipment_num = (select shipment_num
                                             from rcv_headers_interface
                                            where header_interface_id =
                                                  x_cascaded_table(n).header_interface_id)
                        OR shipment_header_id =  (select receipt_header_id
                                                    from rcv_headers_interface
                                                   where header_interface_id =
                                                         x_cascaded_table(n).header_interface_id))
                   AND asn_status = 'NEW_SHIP';

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line(sql%rowcount || ' new_ship RSH updated');
                    asn_debug.put_line('Before handle_rcv_asn_txn ');
                END IF;
                rcv_roi_transaction.handle_rcv_asn_transactions(x_cascaded_table, x_header_record);
            END IF;


            /* Bug3705658 - START */

	    /* Receipt Number should be generated for Drop Ship ASN's and ASBN's
	    ** with profile option 'PO: Automatically Deliver Drop Ship ASNs' set to
            ** 'Y'. This is because at header level when default_receipt_num is called the
	    ** transaction_type and auto_transact_code in RTI would be 'SHIP' and hence
	    ** receipt_num would not have been created. So we need to create the
	    ** receipt_num over here.
	    */
            IF ((x_header_record.header_record.asn_type in ('ASN','ASBN')) AND
	        (x_header_record.header_record.receipt_num is NULL) AND
		(x_header_record.error_record.error_status IN('S', 'W'))
               ) THEN --{
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('ASN or ASBN Transaction');
                END IF;

		SELECT count(*)
                INTO   l_drop_ship_exists
                FROM   po_line_locations_all plla,
                       rcv_transactions_interface rti
                WHERE  rti.header_interface_id = x_header_record.header_record.header_interface_id
                and    rti.po_line_location_id = plla.line_location_id
                and    plla.drop_ship_flag = 'Y';

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Number of Drop Ship Lines:' || l_drop_ship_exists);
                END IF;
                IF l_drop_ship_exists > 0 THEN --{
                    FND_PROFILE.GET('PO_AUTO_DELIVER_DROPSHIP_ASN', l_auto_deliver);
                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('Profile Option PO_AUTO_DELIVER_DROPSHIP_ASN:' || l_auto_deliver);
                    END IF;
                    IF l_auto_deliver = 'Y' THEN --{
                        IF (g_asn_debug = 'Y') THEN
                            asn_debug.put_line('Generate Receipt Number');
                        END IF;

			RCV_ROI_HEADER_COMMON.default_receipt_info(x_header_record);

                        IF (g_asn_debug = 'Y') THEN
                            asn_debug.put_line('Generated Receipt Number:' || x_header_record.header_record.receipt_num);
                        END IF;

                        UPDATE RCV_SHIPMENT_HEADERS
			SET RECEIPT_NUM = x_header_record.header_record.receipt_num
			WHERE SHIPMENT_HEADER_ID = x_header_record.header_record.receipt_header_id;

                    END IF; --}
    	        END IF;--}
             END IF; --}

	     /* Bug3705658 - END */
            -- Erroring out RHI/RTI when line processing failed
            -- Deleting RSH rows that are created for the errored out txn.
            IF (    l_proc_status_code = 'ERROR'
                AND l_update_lpn_group) THEN --{ line processing failed

                l_ship_header_id := nvl(x_cascaded_table(n).shipment_header_id,
                                        x_header_record.header_record.receipt_header_id);

                IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line('Erroring out RHI/RTI');
                     asn_debug.put_line('shipment_header_id : '|| l_ship_header_id);
                END IF;
                /* Bug 4779020. A line is ASN/Non ASN is decided by transaction tye */
                /* need to check auto_transact_code as well to exclude inv shipments */
                /* Bug 7684677  rcv:fail all asn lines if one line fails doesn't work for ship */
                IF (    x_fail_if_one_line_fails
                    AND (x_cascaded_table(n).transaction_type = 'SHIP' or l_transaction_type_old = 'SHIP')
                    /* Add a new variable l_transaction_type_old which will have the original value of RTI.transaction_type */
                    AND x_cascaded_table(n).auto_transact_code in ('SHIP','RECEIVE','DELIVER'))  THEN --{ asn case
                     /* End bug 7684677 */
                    -- delete rsh and rsl
                    DELETE FROM rcv_shipment_headers
                     WHERE shipment_header_id = l_ship_header_id;

                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line(sql%rowcount || ' RSH record deleted');
                    END IF;

                    DELETE FROM rcv_shipment_lines
                     WHERE shipment_header_id = l_ship_header_id;

                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line(sql%rowcount || ' RSL record deleted');
                    END IF;

                    -- update rti
                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('update_rti_error for a fail all ASN transaction ');
                    END IF;

                    update_rti_error(p_group_id                => x_cascaded_table(n).group_id,
                                     p_interface_id            => NULL,
                                     p_header_interface_id     => x_cascaded_table(n).header_interface_id, -- bug 7684677
                                     p_lpn_group_id            => NULL
                                    );

                     /* Bug 4779020 .Update the RHI to error.Exit the Loop to prevent processing the line */
                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('error out rhi for a fail all ASN transaction ');
                    END IF;

                    UPDATE rcv_headers_interface
                       SET processing_status_code = 'ERROR',
                           validation_flag = 'Y',
                           receipt_header_id = NULL
                     WHERE header_interface_id = x_cascaded_table(n).header_interface_id;-- bug 7684677

                    x_header_record.error_record.error_status := 'E';

                    /* Bug 4779020 End */
                ELSE --}{ not an asn with fail all option turned on
                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('update_rti_error for an non fail all ASN transaction ');
                    END IF;

                    update_rti_error(p_group_id                => x_cascaded_table(n).group_id,
                                     p_interface_id            => x_cascaded_table(n).interface_transaction_id,
                                     p_header_interface_id     => NULL,
                                     p_lpn_group_id            => x_cascaded_table(n).lpn_group_id
                                    );

                    -- update the rhi to error if all of its line processing failed
                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('update rhi for non fail-all-ASN transaction ');
                    END IF;

                    -- Bug 9268956
                    IF (NVL(x_header_record.header_record.asn_type, 'STD') = 'STD' AND  x_header_record.header_record.receipt_source_code = 'VENDOR'
                        AND (x_header_record.header_record.shipment_num IS NOT NULL AND x_header_record.header_record.receipt_header_id IS NOT NULL)) THEN
                       IF (x_cascaded_table(n).transaction_type = 'RECEIVE' OR l_transaction_type_old = 'RECEIVE')
                         AND x_cascaded_table(n).auto_transact_code in ('RECEIVE','DELIVER') THEN
                           IF (g_asn_debug = 'Y') THEN
                             asn_debug.put_line('Rollback receipt num if new receipt against ASN/ASBN failed.');
                             asn_debug.put_line('Shipment num: ' || x_header_record.header_record.shipment_num);
                             asn_debug.put_line('Receipt header id: ' || x_header_record.header_record.receipt_header_id);
                             asn_debug.put_line('Transaction type: ' || x_cascaded_table(n).transaction_type);
                             asn_debug.put_line('l_transaction_type_old: ' || l_transaction_type_old);
                             asn_debug.put_line('Auto transact code: ' || x_cascaded_table(n).auto_transact_code);
                           END IF;

                           UPDATE rcv_shipment_headers
                           SET receipt_num = NULL
                           WHERE shipment_header_id = x_header_record.header_record.receipt_header_id
                           AND (asn_type = 'ASN' OR asn_type = 'ASBN')
                           AND (receipt_num IS NOT NULL)
                           AND NOT EXISTS(SELECT rt.transaction_id
                                          FROM   rcv_transactions rt
                                          WHERE  shipment_header_id = x_header_record.header_record.receipt_header_id)
                           AND NOT EXISTS(SELECT rti.interface_transaction_id "Running rows in RTI" -- take care of multi RECEIVE txns under one header
                                          FROM   rcv_transactions_interface rti, rcv_headers_interface rhi
                                          WHERE  rhi.header_interface_id = rti.header_interface_id
                                          AND    rti.processing_status_code in ('RUNNING', 'PENDING')
                                          AND    rhi.receipt_header_id = x_header_record.header_record.receipt_header_id);

                           IF (g_asn_debug = 'Y') THEN
                             asn_debug.put_line(sql%rowcount || ' RSH updated.');
                           END IF;
                       END IF;
                    END IF;
                    -- End bug 9268956

                    IF x_cascaded_table(n).header_interface_id IS NOT NULL THEN --{
                       UPDATE rcv_headers_interface rhi
                          SET rhi.processing_status_code = 'ERROR',
                              rhi.validation_flag = 'Y',
                              rhi.receipt_header_id = NULL
                          WHERE header_interface_id = x_cascaded_table(n).header_interface_id
                          AND NOT EXISTS ( SELECT  rti.interface_transaction_id
                                             FROM  rcv_transactions_interface rti
                                            WHERE  rhi.header_interface_id = rti.header_interface_id
                                              AND  rti.processing_status_code in ('RUNNING', 'PENDING'));

                       IF (g_asn_debug = 'Y') THEN
                          asn_debug.put_line(sql%rowcount || ' RHI record updated to error. ');
                       END IF;

		       -- Bug 13259799
 	               IF (sql%rowcount > 0) THEN
 	                   x_header_record.error_record.error_status := 'E';
 	               END IF;

                    END IF; --}

                    /* Bug 4191118: Need to remove the rsh row if line transaction fails.
                     * Only delete the shipment header that was created in this trxn loop
                     * for PO/RMA receipt or ASN import.
                     *
                     * Bug 5024414: Only delete shipment headers where there is no running
                     * or pending interface line under the interface header, so that we only
                     * delete rsh after all rti lines have failed.
                     * */
                    DELETE FROM rcv_shipment_headers
                     WHERE shipment_header_id = l_ship_header_id
                      AND  asn_status = 'NEW_SHIP'
                      AND NOT EXISTS ( SELECT  rti.interface_transaction_id
                                         FROM  rcv_transactions_interface rti,
                                               rcv_headers_interface rhi
                                        WHERE  rhi.header_interface_id = rti.header_interface_id
                                          AND  rti.processing_status_code in ('RUNNING', 'PENDING')
                                          AND  rhi.receipt_header_id = l_ship_header_id );

                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line(sql%rowcount || ' rsh record deleted');
                    END IF;

                END IF; --} not asn and fail all case

            END IF; --} line processing failed

          END IF; --} header_record.transaction_type <> 'CANCEL'  --bug 4368726

            -- set n back to 0
            n                                   := 0;

        END LOOP; --} end loop of transaction rows in rti

        /* Forward port for Bug 4355172 vendor_site_id was not getting defaulted to rcv_shipment_headers.
           As a result skip_lot if setup against a supplier site will not work.
           since vendor_site_id is derived and populated into RTI get the same and update
           RSH */
                if (x_header_record.header_record.transaction_type <> 'CANCEL') and
                   (x_header_record.header_record.vendor_site_id is null) and
                   (x_header_record.header_record.header_interface_id is not null) and
                      (x_header_record.error_record.error_status IN('S', 'W')) then
                   if (x_header_record.header_record.receipt_source_code='VENDOR') then

                       select count(count(vendor_site_id))
                       into x_site_id_count
                       from rcv_transactions_interface
                       where shipment_header_id=x_header_record.header_record.receipt_header_id
                       and vendor_site_id is not null
                       group by vendor_site_id;
                                              -- Update only if all shipments have same vendor site id
                       if (x_site_id_count = 1) then
                       Begin
                          update rcv_shipment_headers
                          set vendor_site_id=(select distinct vendor_site_id
                                              from rcv_transactions_interface
                                              where shipment_header_id=x_header_record.header_record.receipt_header_id
                                              and vendor_site_id is not null)
                          where shipment_header_id=x_header_record.header_record.receipt_header_id;
                       Exception
                       when others then null;
                       end;
                       end if;
                    end if;
                 end if;

         /* End 4355172 */


        CLOSE rcv_roi_preprocessor.txns_cur;
        asn_debug.put_line('after loop');

	/* Bug 8831292
        * Need to call 824 Interface to insert records into ECE_ADVO_HEADERS
        * and ECE_ADVO_DETAILS for errored out transactions if it was an ASN
        * import and EDI is installed. Data in these 2 tables will be extracted
        * to generate outbound 824 Application Advice.*/

        /* Bug 19212569 - Added request_id to be not null condition so that
         * ONLINE receipts do not execute the foll. piece of code as that is
         * specific to and ASN and ASBN functionality whose txns can only be
         * done in BATCH mode */

        IF (g_is_edi_installed = 'I' AND Nvl(p_request_id,0) > 0) THEN
           IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('EDI installed. Checking for errored ASNs');
           END IF;

           OPEN errored_asn_rhi_cursor;
           LOOP
               FETCH errored_asn_rhi_cursor INTO x_asn_rhi_record.header_record;
               EXIT WHEN errored_asn_rhi_cursor%NOTFOUND;
               IF (g_asn_debug = 'Y') THEN
                   asn_debug.put_line('Calling 824 API for rhi: ' || x_asn_rhi_record.header_record.header_interface_id);
               END IF;
               rcv_824_sv.rcv_824_insert(x_asn_rhi_record, 'ASN');
           END LOOP;
           CLOSE errored_asn_rhi_cursor;
        END IF;

	--DCP call
	BEGIN
		IF (g_asn_debug = 'Y') THEN
			asn_debug.put_line('l_check_dcp ' || l_check_dcp);
			asn_debug.put_line('g_check_dcp ' || rcv_dcp_pvt.g_check_dcp);
		END IF;

		IF l_check_dcp  > 0 THEN
			-- Moved the driving cursor to the DCP package itself
			-- FOR header_cur_rec IN headers_cur_dcp(x_request_id, x_group_id) LOOP
			rcv_dcp_pvt.validate_data(p_dcp_event => 'PREPROCESSOR', p_request_id => x_request_id, p_group_id => x_group_id, p_raise_exception => 'Y', x_return_status => l_return_status);
			--END LOOP;
		END IF;
	EXCEPTION
		WHEN rcv_dcp_pvt.data_inconsistency_exception THEN
			IF (g_asn_debug = 'Y') THEN
				asn_debug.put_line('Data Inconsistency Exception');
			END IF;
			IF  distinct_org_id%ISOPEN THEN
				CLOSE  distinct_org_id;
			END IF;
			x_error_record := x_empty_error_record;
			x_header_record  := x_empty_header_record;
			-- initialize error_record
			x_header_record.error_record  := x_error_record;

			ROLLBACK TO dcp_preprocessor_start;
			GOTO dcp_pre_processor_start;
		WHEN OTHERS THEN
			IF (g_asn_debug = 'Y') THEN
				asn_debug.put_line('When Others ' || SQLERRM);
			END IF;
			NULL;
	END;
	--End DCP call

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Exit preprocessor');
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            rcv_error_pkg.set_sql_error_message('RCV_ROI_PREPROCESSOR.preprocessor','sqlcode');
            rcv_error_pkg.log_interface_error('PARENT_SOURCE_TRANSACTION_NUM', FALSE);

            IF rcv_roi_preprocessor.txns_cur%ISOPEN THEN
                CLOSE rcv_roi_preprocessor.txns_cur;
            END IF;

            --pjiang, close header cursor explicitly
            IF rcv_roi_preprocessor.headers_cur%ISOPEN THEN
                CLOSE rcv_roi_preprocessor.headers_cur;
            END IF;
        WHEN rcv_error_pkg.e_fatal_error THEN --we didn't catch an error that we should have caught
            asn_debug.put_line('uncaught e_fatal_error in rcv_roi_preprocess.preprocessor - abnormal execution');
            asn_debug.put_line('last error message = ' || rcv_error_pkg.get_last_message);

            rcv_error_pkg.set_sql_error_message('RCV_ROI_PREPROCESSOR.preprocessor','sqlcode');		 -- Bug 13093917
            rcv_error_pkg.log_interface_error('INTERFACE_TRANSACTION_ID', FALSE);	-- Bug 13093917

        WHEN OTHERS THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Exception in preprocessor:');
                asn_debug.put_line('sqlerrm: ' || SQLERRM);
                asn_debug.put_line('l_msg_count: ' || l_msg_count);
                asn_debug.put_line('l_msg_data: ' || l_msg_data);
                asn_debug.put_line('Set rti rows to error for this and call txn complete');
            END IF;

            rcv_error_pkg.set_sql_error_message('RCV_ROI_PREPROCESSOR.preprocessor','sqlcode');		 -- Bug 13093917
            rcv_error_pkg.log_interface_error('INTERFACE_TRANSACTION_ID', FALSE);	-- Bug 13093917

            IF rcv_roi_preprocessor.txns_cur%ISOPEN THEN
                CLOSE rcv_roi_preprocessor.txns_cur;
            END IF;

            --pjiang, close header cursor explicitly
            IF rcv_roi_preprocessor.headers_cur%ISOPEN THEN
                CLOSE rcv_roi_preprocessor.headers_cur;
            END IF;

            /*We default p_group_id to 0 */
            IF (    p_group_id IS NOT NULL
                AND p_group_id <> 0) THEN
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('update_rti_error in exception with group_id ');
                END IF;

                update_rti_error(p_group_id                => p_group_id,
                                 p_interface_id            => NULL,
                                 p_header_interface_id     => NULL,
                                 p_lpn_group_id            => NULL
                                );
            ELSIF(p_request_id IS NOT NULL) THEN
                OPEN distinct_groups(p_request_id);
                l_group_count  := 1;

                LOOP
                    FETCH distinct_groups INTO l_exception_group_id(n);
                    EXIT WHEN distinct_groups%NOTFOUND;

                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('update_rti_error in exception with request_id ');
                    END IF;

                    update_rti_error(p_group_id                => l_exception_group_id(n),
                                     p_interface_id            => NULL,
                                     p_header_interface_id     => NULL,
                                     p_lpn_group_id            => NULL
                                    );
                    l_group_count  := l_group_count + 1;
                END LOOP;

                CLOSE distinct_groups;
            END IF;
    END preprocessor;

    PROCEDURE default_from_parent_trx(
        x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
        n                IN OUT NOCOPY BINARY_INTEGER
    ) IS
        CURSOR get_parent_row_from_rt(
            p_transaction_id rcv_transactions.transaction_id%TYPE
        ) IS
            SELECT --mandatory matching values
                    rt.shipment_header_id,
                    rt.shipment_line_id,
                    rt.source_document_code,
                    rt.po_header_id,
                    rt.po_release_id,
                    rt.po_line_id,
                    rt.po_line_location_id,
                    rt.po_distribution_id,
                    rt.po_revision_num,
                    rt.requisition_line_id,
                    rt.po_unit_price,
                    rt.currency_code,
                    rt.currency_conversion_type,
                    rt.vendor_id,
                    rt.vendor_site_id,
                    rt.source_doc_unit_of_measure,
                    rt.oe_order_header_id,
                    rt.oe_order_line_id,
                    rt.customer_id,
                    rt.customer_site_id,
                    rt.job_id,
                    rt.timecard_id,
                    rt.timecard_ovn,
                    rt.project_id,
                    rt.task_id,
                    rsl.category_id,
                    rsl.item_description,
                    rsl.item_id,
                    rsl.item_revision,
                    rsl.vendor_item_num,
                    rsl.vendor_lot_num,
                    rsl.from_organization_id,
                    rsl.to_organization_id,
                    --defaulting values
                    rt.unit_of_measure,
                    rt.primary_unit_of_measure,
                    rt.uom_code,
                    rt.employee_id,
                    rt.currency_conversion_rate,
                    rt.currency_conversion_date,
                    rt.deliver_to_person_id,
                    rt.deliver_to_location_id,
                    rt.secondary_unit_of_measure,
                    rt.secondary_uom_code
            FROM   rcv_transactions rt,
                   rcv_shipment_lines rsl
            WHERE  transaction_id = p_transaction_id
            AND    rt.shipment_line_id = rsl.shipment_line_id(+);

        CURSOR get_parent_row_from_rti(
            p_transaction_id rcv_transactions.transaction_id%TYPE
        ) IS
            SELECT --mandatory matching values
                    shipment_header_id,
                    shipment_line_id,
                    source_document_code,
                    po_header_id,
                    po_release_id,
                    po_line_id,
                    po_line_location_id,
                    po_distribution_id,
                    po_revision_num,
                    requisition_line_id,
                    po_unit_price,
                    currency_code,
                    currency_conversion_type,
                    vendor_id,
                    vendor_site_id,
                    source_doc_unit_of_measure,
                    oe_order_header_id,
                    oe_order_line_id,
                    customer_id,
                    customer_site_id,
                    job_id,
                    timecard_id,
                    timecard_ovn,
                    project_id,
                    task_id,
                    category_id,
                    item_description,
                    item_id,
                    item_revision,
                    vendor_item_num,
                    vendor_lot_num,
                    from_organization_id,
                    to_organization_id,
                    --defaulting values
                    unit_of_measure,
                    primary_unit_of_measure,
                    uom_code,
                    employee_id,
                    currency_conversion_rate,
                    currency_conversion_date,
                    deliver_to_person_id,
                    deliver_to_location_id,
                    secondary_unit_of_measure,
                    secondary_uom_code
            FROM   rcv_transactions_interface
            WHERE  interface_transaction_id = p_transaction_id;

        CURSOR get_parent_row_from_cascade(
            p_parent_index NUMBER
        ) IS
            SELECT --mandatory matching values
                    x_cascaded_table(p_parent_index).shipment_header_id shipment_header_id,
                    x_cascaded_table(p_parent_index).shipment_line_id shipment_line_id,
                    x_cascaded_table(p_parent_index).source_document_code source_document_code,
                    x_cascaded_table(p_parent_index).po_header_id po_header_id,
                    x_cascaded_table(p_parent_index).po_release_id po_release_id,
                    x_cascaded_table(p_parent_index).po_line_id po_line_id,
                    x_cascaded_table(p_parent_index).po_line_location_id po_line_location_id,
                    x_cascaded_table(p_parent_index).po_distribution_id po_distribution_id,
                    x_cascaded_table(p_parent_index).po_revision_num po_revision_num,
                    x_cascaded_table(p_parent_index).requisition_line_id requisition_line_id,
                    x_cascaded_table(p_parent_index).po_unit_price po_unit_price,
                    x_cascaded_table(p_parent_index).currency_code currency_code,
                    x_cascaded_table(p_parent_index).currency_conversion_type currency_conversion_type,
                    x_cascaded_table(p_parent_index).vendor_id vendor_id,
                    x_cascaded_table(p_parent_index).vendor_site_id vendor_site_id,
                    x_cascaded_table(p_parent_index).source_doc_unit_of_measure source_doc_unit_of_measure,
                    x_cascaded_table(p_parent_index).oe_order_header_id oe_order_header_id,
                    x_cascaded_table(p_parent_index).oe_order_line_id oe_order_line_id,
                    x_cascaded_table(p_parent_index).customer_id customer_id,
                    x_cascaded_table(p_parent_index).customer_site_id customer_site_id,
                    x_cascaded_table(p_parent_index).job_id job_id,
                    x_cascaded_table(p_parent_index).timecard_id timecard_id,
                    x_cascaded_table(p_parent_index).timecard_ovn timecard_ovn,
                    x_cascaded_table(p_parent_index).project_id project_id,
                    x_cascaded_table(p_parent_index).task_id task_id,
                    x_cascaded_table(p_parent_index).category_id category_id,
                    x_cascaded_table(p_parent_index).item_description item_description,
                    x_cascaded_table(p_parent_index).item_id item_id,
                    x_cascaded_table(p_parent_index).item_revision item_revision,
                    x_cascaded_table(p_parent_index).vendor_item_num vendor_item_num,
                    x_cascaded_table(p_parent_index).vendor_lot_num vendor_lot_num,
                    x_cascaded_table(p_parent_index).from_organization_id from_organization_id,
                    x_cascaded_table(p_parent_index).to_organization_id to_organization_id,
                    --defaulting values
                    x_cascaded_table(p_parent_index).unit_of_measure unit_of_measure,
                    x_cascaded_table(p_parent_index).primary_unit_of_measure primary_unit_of_measure,
                    x_cascaded_table(p_parent_index).uom_code uom_code,
                    x_cascaded_table(p_parent_index).employee_id employee_id,
                    x_cascaded_table(p_parent_index).currency_conversion_rate currency_conversion_rate,
                    x_cascaded_table(p_parent_index).currency_conversion_date currency_conversion_date,
                    x_cascaded_table(p_parent_index).deliver_to_person_id deliver_to_person_id,
                    x_cascaded_table(p_parent_index).deliver_to_location_id deliver_to_location_id,
                    x_cascaded_table(p_parent_index).secondary_unit_of_measure secondary_unit_of_measure,
                    x_cascaded_table(p_parent_index).secondary_uom_code secondary_uom_code
            FROM   DUAL;

        x_parent_row get_parent_row_from_rt%ROWTYPE;

        PROCEDURE default_no_check(
            p_src_value IN            VARCHAR2,
            p_dst_value IN OUT NOCOPY VARCHAR2
        ) IS
        BEGIN
            IF     p_dst_value IS NULL
               AND p_src_value IS NOT NULL THEN
                p_dst_value  := p_src_value;
            END IF;
        END default_no_check;

        PROCEDURE default_no_check(
            p_src_value IN            NUMBER,
            p_dst_value IN OUT NOCOPY NUMBER
        ) IS
        BEGIN
            IF     p_dst_value IS NULL
               AND p_src_value IS NOT NULL THEN
                p_dst_value  := p_src_value;
            END IF;
        END default_no_check;
    BEGIN
        IF (x_cascaded_table(n).derive = 'Y') THEN --{
            IF (x_cascaded_table(n).derive_index <> 0) THEN --{
                OPEN get_parent_row_from_cascade(x_cascaded_table(n).derive_index);
                FETCH get_parent_row_from_cascade INTO x_parent_row;

                IF (get_parent_row_from_cascade%NOTFOUND) THEN
                    CLOSE get_parent_row_from_cascade;
                    RETURN;
                END IF;

                CLOSE get_parent_row_from_cascade;
            ELSIF (x_cascaded_table(n).parent_interface_txn_id IS NOT NULL) THEN
                OPEN get_parent_row_from_rti(x_cascaded_table(n).parent_interface_txn_id);
                FETCH get_parent_row_from_rti INTO x_parent_row;

                IF (get_parent_row_from_rti%NOTFOUND) THEN
                    CLOSE get_parent_row_from_rti;
                    RETURN;
                END IF;

                CLOSE get_parent_row_from_rti;
            ELSE
                RETURN;
            END IF;
        ELSIF (x_cascaded_table(n).parent_transaction_id IS NOT NULL) THEN
            OPEN get_parent_row_from_rt(x_cascaded_table(n).parent_transaction_id);
            FETCH get_parent_row_from_rt INTO x_parent_row;

            IF (get_parent_row_from_rt%NOTFOUND) THEN
                CLOSE get_parent_row_from_rt;
                RETURN;
            END IF;

            CLOSE get_parent_row_from_rt;
        ELSE
            RETURN;
        END IF;

        --mandatory matching values
        rcv_error_pkg.default_and_check(x_parent_row.shipment_header_id,
                                        x_cascaded_table(n).shipment_header_id,
                                        'SHIPMENT_HEADER_ID'
                                       );
        rcv_error_pkg.default_and_check(x_parent_row.shipment_line_id,
                                        x_cascaded_table(n).shipment_line_id,
                                        'SHIPMENT_LINE_ID'
                                       );
        rcv_error_pkg.default_and_check(x_parent_row.source_document_code,
                                        x_cascaded_table(n).source_document_code,
                                        'SOURCE_DOCUMENT_CODE'
                                       );
        rcv_error_pkg.default_and_check(x_parent_row.po_header_id,
                                        x_cascaded_table(n).po_header_id,
                                        'PO_HEADER_ID'
                                       );
        rcv_error_pkg.default_and_check(x_parent_row.po_release_id,
                                        x_cascaded_table(n).po_release_id,
                                        'PO_RELEASE_ID'
                                       );
        rcv_error_pkg.default_and_check(x_parent_row.po_line_id,
                                        x_cascaded_table(n).po_line_id,
                                        'PO_LINE_ID'
                                       );
        rcv_error_pkg.default_and_check(x_parent_row.po_line_location_id,
                                        x_cascaded_table(n).po_line_location_id,
                                        'PO_LINE_LOCATION_ID'
                                       );
        rcv_error_pkg.default_and_check(x_parent_row.po_distribution_id,
                                        x_cascaded_table(n).po_distribution_id,
                                        'PO_DISTRIBUTION_ID'
                                       );
        rcv_error_pkg.default_and_check(x_parent_row.po_revision_num,
                                        x_cascaded_table(n).po_revision_num,
                                        'PO_REVISION_NUM'
                                       );
        rcv_error_pkg.default_and_check(x_parent_row.requisition_line_id,
                                        x_cascaded_table(n).requisition_line_id,
                                        'REQUISITION_LINE_ID'
                                       );
        rcv_error_pkg.default_and_check(x_parent_row.po_unit_price,
                                        x_cascaded_table(n).po_unit_price,
                                        'PO_UNIT_PRICE'
                                       );
        rcv_error_pkg.default_and_check(x_parent_row.currency_code,
                                        x_cascaded_table(n).currency_code,
                                        'CURRENCY_CODE'
                                       );
        rcv_error_pkg.default_and_check(x_parent_row.currency_conversion_type,
                                        x_cascaded_table(n).currency_conversion_type,
                                        'CURRENCY_CONVERSION_TYPE'
                                       );
        rcv_error_pkg.default_and_check(x_parent_row.vendor_id,
                                        x_cascaded_table(n).vendor_id,
                                        'VENDOR_ID'
                                       );
        rcv_error_pkg.default_and_check(x_parent_row.vendor_site_id,
                                        x_cascaded_table(n).vendor_site_id,
                                        'VENDOR_SITE_ID'
                                       );
        rcv_error_pkg.default_and_check(x_parent_row.source_doc_unit_of_measure,
                                        x_cascaded_table(n).source_doc_unit_of_measure,
                                        'SOURCE_DOC_UNIT_OF_MEASURE'
                                       );
        rcv_error_pkg.default_and_check(x_parent_row.oe_order_header_id,
                                        x_cascaded_table(n).oe_order_header_id,
                                        'OE_ORDER_HEADER_ID'
                                       );
        rcv_error_pkg.default_and_check(x_parent_row.oe_order_line_id,
                                        x_cascaded_table(n).oe_order_line_id,
                                        'OE_ORDER_LINE_ID'
                                       );
        rcv_error_pkg.default_and_check(x_parent_row.customer_id,
                                        x_cascaded_table(n).customer_id,
                                        'CUSTOMER_ID'
                                       );
        rcv_error_pkg.default_and_check(x_parent_row.customer_site_id,
                                        x_cascaded_table(n).customer_site_id,
                                        'CUSTOMER_SITE_ID'
                                       );
        rcv_error_pkg.default_and_check(x_parent_row.job_id,
                                        x_cascaded_table(n).job_id,
                                        'JOB_ID'
                                       );
        rcv_error_pkg.default_and_check(x_parent_row.timecard_id,
                                        x_cascaded_table(n).timecard_id,
                                        'TIMECARD_ID'
                                       );
        /* For bug 7112839, no need to do this check.
        * rcv_error_pkg.default_and_check(x_parent_row.timecard_ovn,
        *                                 x_cascaded_table(n).timecard_ovn,
        *                                 'TIMECARD_OVN'
        *                                );
        */
        rcv_error_pkg.default_and_check(x_parent_row.project_id,
                                        x_cascaded_table(n).project_id,
                                        'PROJECT_ID'
                                       );
        rcv_error_pkg.default_and_check(x_parent_row.task_id,
                                        x_cascaded_table(n).task_id,
                                        'TASK_ID'
                                       );
        rcv_error_pkg.default_and_check(x_parent_row.category_id,
                                        x_cascaded_table(n).category_id,
                                        'CATEGORY_ID'
                                       );
        --Bug 9308272 No need to validate for Item description
        /*rcv_error_pkg.default_and_check(x_parent_row.item_description,
                                        x_cascaded_table(n).item_description,
                                        'ITEM_DESCRIPTION'
                                       );*/
        rcv_error_pkg.default_and_check(x_parent_row.item_id,
                                        x_cascaded_table(n).item_id,
                                        'ITEM_ID'
                                       );
        rcv_error_pkg.default_and_check(x_parent_row.item_revision,
                                        x_cascaded_table(n).item_revision,
                                        'ITEM_REVISION'
                                       );
        rcv_error_pkg.default_and_check(x_parent_row.vendor_item_num,
                                        x_cascaded_table(n).vendor_item_num,
                                        'VENDOR_ITEM_NUM'
                                       );
        rcv_error_pkg.default_and_check(x_parent_row.vendor_lot_num,
                                        x_cascaded_table(n).vendor_lot_num,
                                        'VENDOR_LOT_NUM'
                                       );
        rcv_error_pkg.default_and_check(x_parent_row.from_organization_id,
                                        x_cascaded_table(n).from_organization_id,
                                        'FROM_ORGANIZATION_ID'
                                       );
        rcv_error_pkg.default_and_check(x_parent_row.to_organization_id,
                                        x_cascaded_table(n).to_organization_id,
                                        'TO_ORGANIZATION_ID'
                                       );
        --defaulting values
        default_no_check(x_parent_row.unit_of_measure, x_cascaded_table(n).unit_of_measure);
        default_no_check(x_parent_row.primary_unit_of_measure, x_cascaded_table(n).primary_unit_of_measure);
        default_no_check(x_parent_row.uom_code, x_cascaded_table(n).uom_code);
        default_no_check(x_parent_row.employee_id, x_cascaded_table(n).employee_id);
        default_no_check(x_parent_row.currency_conversion_rate, x_cascaded_table(n).currency_conversion_rate);
        default_no_check(x_parent_row.currency_conversion_date, x_cascaded_table(n).currency_conversion_date);
        default_no_check(x_parent_row.deliver_to_person_id, x_cascaded_table(n).deliver_to_person_id);
        default_no_check(x_parent_row.deliver_to_location_id, x_cascaded_table(n).deliver_to_location_id);
        default_no_check(x_parent_row.secondary_unit_of_measure, x_cascaded_table(n).secondary_unit_of_measure);
        default_no_check(x_parent_row.secondary_uom_code, x_cascaded_table(n).secondary_uom_code);
    EXCEPTION
        WHEN rcv_error_pkg.e_fatal_error THEN
            x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
            x_cascaded_table(n).error_message := rcv_error_pkg.get_last_message;
    END default_from_parent_trx;

    PROCEDURE process_line(
        x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
        n                IN OUT NOCOPY BINARY_INTEGER,
        x_header_id      IN            rcv_headers_interface.header_interface_id%TYPE,
        x_asn_type       IN            rcv_headers_interface.asn_type%TYPE,
        v_header_record  IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
    ) IS
        x_parent_id            NUMBER;
        x_progress             VARCHAR2(3);
        x_error_record         rcv_shipment_object_sv.errorrectype;
        x_start_indice         BINARY_INTEGER                                       := NULL;
        i                      BINARY_INTEGER                                       := NULL;
        used_for_cascaded_rows rcv_roi_preprocessor.cascaded_trans_tab_type;
        /* Bug 3434460 */
        l_return_status        VARCHAR2(1);
        l_msg_count            NUMBER;
        l_msg_data             fnd_new_messages.MESSAGE_TEXT%TYPE;
        l_to_org_id            rcv_transactions_interface.to_organization_id%TYPE;
    BEGIN
        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Enter create shipment line');
        END IF;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Initialize the table structure used for storing the cascaded rows' || x_cascaded_table(n).transaction_type);
            asn_debug.put_line('receipt source code' || x_cascaded_table(n).receipt_source_code);
        END IF;

        -- delete all records from used_for_cascaded_rows
        used_for_cascaded_rows.DELETE;
        x_progress      := '000';
        x_start_indice  := n;

        -- default information from the parent trx
        default_from_parent_trx(x_cascaded_table,n);

        -- Bug 10227549: derive destination type and context
        derive_destination_info(x_cascaded_table,n);


        -- derive the shipment line information
        IF (x_cascaded_table(n).error_status IN ('S','W') ) THEN --Bug: 5586062
            IF (x_cascaded_table(n).receipt_source_code = 'VENDOR') THEN --{
                IF (x_cascaded_table(n).transaction_type IN('SHIP', 'RECEIVE')) THEN
                    rcv_roi_transaction.derive_vendor_rcv_line(x_cascaded_table,
                                                               n,
                                                               used_for_cascaded_rows,
                                                               v_header_record
                                                              );
                ELSIF(x_cascaded_table(n).transaction_type IN('TRANSFER', 'ACCEPT', 'REJECT', 'DELIVER')) THEN
                    asn_debug.put_line('calling derive routine for transaction ' || x_cascaded_table(n).transaction_type);
                    rcv_roi_transaction.derive_vendor_trans_del(x_cascaded_table,
                                                                n,
                                                                used_for_cascaded_rows,
                                                                v_header_record
                                                               );
                ELSIF(x_cascaded_table(n).transaction_type =('CORRECT')) THEN
                    asn_debug.put_line('calling derive routine for transaction ' || x_cascaded_table(n).transaction_type);
                    rcv_roi_transaction.derive_correction_line(x_cascaded_table,
                                                               n,
                                                               used_for_cascaded_rows,
                                                               v_header_record
                                                              );
                ELSIF(x_cascaded_table(n).transaction_type = 'RETURN TO VENDOR') THEN
                    asn_debug.put_line('calling derive routine for transaction ' || x_cascaded_table(n).transaction_type);
                    rcv_roi_return.derive_return_line(x_cascaded_table,
                                                      n,
                                                      used_for_cascaded_rows,
                                                      v_header_record
                                                     );
                ELSIF(x_cascaded_table(n).transaction_type = 'RETURN TO RECEIVING') THEN
                    asn_debug.put_line('calling derive routine for transaction ' || x_cascaded_table(n).transaction_type);
                    rcv_roi_return.derive_return_line(x_cascaded_table,
                                                      n,
                                                      used_for_cascaded_rows,
                                                      v_header_record
                                                     );
                ELSE
                    asn_debug.put_line('We do not support transaction type ' || x_cascaded_table(n).transaction_type);
                    rcv_error_pkg.set_error_message('RCV_INVALID_TRANSACTION_TYPE');
                    rcv_error_pkg.log_interface_error('TRANSACTION_TYPE');
                END IF;
            ELSIF(x_cascaded_table(n).receipt_source_code = 'INTERNAL ORDER') THEN
                IF (x_cascaded_table(n).transaction_type = 'RECEIVE') THEN
                    asn_debug.put_line('calling derive routine for transaction ' || x_cascaded_table(n).transaction_type);
                    rcv_int_order_pp_pvt.derive_io_receive_line(x_cascaded_table,
                                                                n,
                                                                used_for_cascaded_rows,
                                                                v_header_record
                                                               );
                ELSIF(x_cascaded_table(n).transaction_type IN('TRANSFER', 'ACCEPT', 'REJECT', 'DELIVER')) THEN
                    asn_debug.put_line('calling derive routine for transaction ' || x_cascaded_table(n).transaction_type);
                    rcv_int_order_pp_pvt.derive_io_trans_line(x_cascaded_table,
                                                              n,
                                                              used_for_cascaded_rows,
                                                              v_header_record
                                                             );
                ELSIF(x_cascaded_table(n).transaction_type =('CORRECT')) THEN
                    asn_debug.put_line('calling derive routine for transaction ' || x_cascaded_table(n).transaction_type);
                    rcv_int_order_pp_pvt.derive_io_correct_line(x_cascaded_table,
                                                                n,
                                                                used_for_cascaded_rows,
                                                                v_header_record
                                                               );
                ELSE
                    asn_debug.put_line('We do not support transaction type ' || x_cascaded_table(n).transaction_type);
                    rcv_error_pkg.set_error_message('RCV_INVALID_TRANSACTION_TYPE');
                    rcv_error_pkg.log_interface_error('TRANSACTION_TYPE');
                END IF; -- IF INTERNAL ORDER
            ELSIF(x_cascaded_table(n).receipt_source_code = 'INVENTORY') THEN --} {
                IF (x_cascaded_table(n).transaction_type = 'RECEIVE') THEN
                    rcv_int_org_transfer.derive_int_org_rcv_line(x_cascaded_table,
                                                                 n,
                                                                 used_for_cascaded_rows,
                                                                 v_header_record
                                                                );
                ELSIF(x_cascaded_table(n).transaction_type IN('TRANSFER', 'ACCEPT', 'REJECT', 'DELIVER')) THEN
                    asn_debug.put_line('calling derive routine for transaction ' || x_cascaded_table(n).transaction_type);
                    rcv_int_org_transfer.derive_int_org_trans_del(x_cascaded_table,
                                                                  n,
                                                                  used_for_cascaded_rows,
                                                                  v_header_record
                                                                 );
                ELSIF(x_cascaded_table(n).transaction_type =('CORRECT')) THEN
                    asn_debug.put_line('calling derive routine for transaction ' || x_cascaded_table(n).transaction_type);
                    rcv_int_org_transfer.derive_int_org_cor_line(x_cascaded_table,
                                                                 n,
                                                                 used_for_cascaded_rows,
                                                                 v_header_record
                                                                );
                ELSE
                    asn_debug.put_line('We do not support transaction type ' || x_cascaded_table(n).transaction_type);
                    rcv_error_pkg.set_error_message('RCV_INVALID_TRANSACTION_TYPE');
                    rcv_error_pkg.log_interface_error('TRANSACTION_TYPE');
                END IF;
            ELSIF(x_cascaded_table(n).receipt_source_code = 'CUSTOMER') THEN --} {
                asn_debug.put_line('calling derive routine for RMA transaction ' || x_cascaded_table(n).transaction_type);

                IF (x_cascaded_table(n).transaction_type = 'RECEIVE') THEN --{
                    rcv_rma_transactions.derive_rma_line(x_cascaded_table,
                                                         n,
                                                         used_for_cascaded_rows,
                                                         v_header_record
                                                        );
                ELSIF(x_cascaded_table(n).transaction_type IN('TRANSFER', 'ACCEPT', 'REJECT', 'DELIVER')) THEN
                    rcv_rma_transactions.derive_rma_trans_del(x_cascaded_table,
                                                              n,
                                                              used_for_cascaded_rows,
                                                              v_header_record
                                                             );
                ELSIF(x_cascaded_table(n).transaction_type = 'RETURN TO CUSTOMER') THEN
                    rcv_roi_return.derive_return_line(x_cascaded_table,
                                                      n,
                                                      used_for_cascaded_rows,
                                                      v_header_record
                                                     );
                ELSIF(x_cascaded_table(n).transaction_type = 'CORRECT') THEN
                    rcv_rma_transactions.derive_rma_correction_line(x_cascaded_table,
                                                                    n,
                                                                    used_for_cascaded_rows,
                                                                    v_header_record
                                                                   );
                ELSE
                    asn_debug.put_line('We do not support transaction type ' || x_cascaded_table(n).transaction_type);
                    rcv_error_pkg.set_error_message('RCV_INVALID_TRANSACTION_TYPE');
                    rcv_error_pkg.log_interface_error('TRANSACTION_TYPE');
                END IF; --}
            ELSE --}{
                asn_debug.put_line('We do not support receipt_source_code ' || x_cascaded_table(n).receipt_source_code);
                rcv_error_pkg.set_error_message('RCV_INVALID_TRANSACTION_TYPE');
                rcv_error_pkg.log_interface_error('TRANSACTION_TYPE');
            END IF; --}
        END IF;
        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Back from derive routine with ' || TO_CHAR(used_for_cascaded_rows.COUNT) || ' rows');
            asn_debug.put_line('Error Status ' || x_cascaded_table(n).error_status);
            asn_debug.put_line('Error Message ' || x_cascaded_table(n).error_message);
        END IF;

        x_progress      := '010';

        IF     (x_cascaded_table(n).error_status IN('S', 'W'))
           AND used_for_cascaded_rows.COUNT > 0 THEN --{ we have returned with a cascaded table
            FOR i IN 1 .. used_for_cascaded_rows.COUNT LOOP --{
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Defaulting for cascaded row ' || TO_CHAR(i));
                END IF;

                -- default shipment line information
                IF (x_cascaded_table(n).receipt_source_code = 'VENDOR') THEN --{
                    IF (x_cascaded_table(n).transaction_type IN('SHIP', 'RECEIVE')) THEN --{
                        rcv_roi_transaction.default_vendor_rcv_line(used_for_cascaded_rows,
                                                                    i,
                                                                    x_header_id,
                                                                    v_header_record
                                                                   );
                    ELSIF(x_cascaded_table(n).transaction_type IN('TRANSFER', 'ACCEPT', 'REJECT', 'DELIVER')) THEN --}{
                        asn_debug.put_line('Defaulting for cascaded row ' || TO_CHAR(i));
                        asn_debug.put_line('Defaulting for cascaded row ' || x_cascaded_table(n).transaction_type);
                        rcv_roi_transaction.default_vendor_trans_del(used_for_cascaded_rows, i);
                    ELSIF(x_cascaded_table(n).transaction_type = 'CORRECT') THEN --}{
                        asn_debug.put_line('Defaulting for cascaded row ' || TO_CHAR(i));
                        asn_debug.put_line('Defaulting for cascaded row ' || x_cascaded_table(n).transaction_type);
                        rcv_roi_transaction.default_vendor_correct(used_for_cascaded_rows, i);
                    ELSIF(x_cascaded_table(n).transaction_type = 'RETURN TO VENDOR') THEN --}{
                        asn_debug.put_line('Defaulting for cascaded row ' || TO_CHAR(i));
                        asn_debug.put_line('Defaulting for cascaded row ' || x_cascaded_table(n).transaction_type);
                        rcv_roi_return.default_return_line(used_for_cascaded_rows, i);
                    ELSIF(x_cascaded_table(n).transaction_type = 'RETURN TO RECEIVING') THEN --}{
                        asn_debug.put_line('Defaulting for cascaded row ' || TO_CHAR(i));
                        rcv_roi_return.default_return_line(used_for_cascaded_rows, i);
                    END IF; --}
                ELSIF(x_cascaded_table(n).receipt_source_code = 'INTERNAL ORDER') THEN
                    IF (x_cascaded_table(n).transaction_type = 'RECEIVE') THEN
                        rcv_int_order_pp_pvt.default_io_receive_line(used_for_cascaded_rows, i);
                    ELSIF(x_cascaded_table(n).transaction_type IN('TRANSFER', 'ACCEPT', 'REJECT', 'DELIVER')) THEN
                        asn_debug.put_line('Defaulting for cascaded row ' || TO_CHAR(i) || ' TYPE: ' || x_cascaded_table(n).transaction_type);
                        rcv_int_order_pp_pvt.default_io_trans_line(used_for_cascaded_rows, i);
                    ELSIF(x_cascaded_table(n).transaction_type = 'CORRECT') THEN
                        asn_debug.put_line('Defaulting for cascaded row ' || TO_CHAR(i) || ' TYPE: ' || x_cascaded_table(n).transaction_type);
                        rcv_int_order_pp_pvt.default_io_correct_line(used_for_cascaded_rows, i);
                    ELSIF(x_cascaded_table(n).transaction_type IN('RETURN TO VENDOR', 'RETURN TO RECEIVING')) THEN
                        asn_debug.put_line('Defaulting for cascaded row ' || TO_CHAR(i) || ' TYPE: ' || x_cascaded_table(n).transaction_type);
                        rcv_roi_return.default_return_line(used_for_cascaded_rows, i);
                    END IF; -- FOR default INTERNAL ORDER
                ELSIF(x_cascaded_table(n).receipt_source_code = 'INVENTORY') THEN -- } {
                    IF (x_cascaded_table(n).transaction_type = 'RECEIVE') THEN --{
                        rcv_int_org_transfer.default_int_org_rcv_line(used_for_cascaded_rows, i);
                    ELSIF(x_cascaded_table(n).transaction_type IN('TRANSFER', 'ACCEPT', 'REJECT', 'DELIVER')) THEN --}{
                        asn_debug.put_line('Defaulting for cascaded row ' || TO_CHAR(i));
                        asn_debug.put_line('Defaulting for cascaded row ' || x_cascaded_table(n).transaction_type);
                        rcv_int_org_transfer.default_int_org_trans_del(used_for_cascaded_rows, i);
                    ELSIF(x_cascaded_table(n).transaction_type IN('CORRECT')) THEN --}{
                        asn_debug.put_line('Defaulting for cascaded row ' || TO_CHAR(i));
                        rcv_int_org_transfer.default_int_org_cor_line(used_for_cascaded_rows, i);
                    ELSIF(x_cascaded_table(n).transaction_type = 'RETURN TO VENDOR') THEN --}{
                        asn_debug.put_line('Defaulting for cascaded row ' || TO_CHAR(i));
                        asn_debug.put_line('Defaulting for cascaded row ' || x_cascaded_table(n).transaction_type);
                        rcv_roi_return.default_return_line(used_for_cascaded_rows, i);
                    ELSIF(x_cascaded_table(n).transaction_type = 'RETURN TO RECEIVING') THEN --}{
                        asn_debug.put_line('Defaulting for cascaded row ' || TO_CHAR(i));
                        rcv_roi_return.default_return_line(used_for_cascaded_rows, i);
                    END IF; --}
                ELSIF(x_cascaded_table(n).receipt_source_code = 'CUSTOMER') THEN -- } {
                    asn_debug.put_line('Defaulting for cascaded row ' || TO_CHAR(i));

                    IF (x_cascaded_table(n).transaction_type = 'RECEIVE') THEN --{
                        rcv_rma_transactions.default_rma_line(used_for_cascaded_rows,
                                                              i,
                                                              x_header_id,
                                                              v_header_record
                                                             );
                    ELSIF(x_cascaded_table(n).transaction_type = 'RETURN TO CUSTOMER') THEN --}{
                        rcv_roi_return.default_return_line(used_for_cascaded_rows, i);
                    ELSIF(x_cascaded_table(n).transaction_type IN('TRANSFER', 'ACCEPT', 'REJECT', 'DELIVER')) THEN
                        rcv_roi_transaction.default_vendor_trans_del(used_for_cascaded_rows, i);
                    ELSIF(x_cascaded_table(n).transaction_type = 'CORRECT') THEN
                        rcv_roi_transaction.default_vendor_correct(used_for_cascaded_rows, i);
                    END IF; --}
                END IF; --}

                /* 3434460.
                 * We need to set transfer_lpn_ids to null for all Deliver type
                 * of transactions (Deliver/Direct Delivery). This needs to
                 * be done for all non-wms orgs. If to_org_id was given by
                 * the user, then this would have been done already after
                 * explode_lpn. So check for transfer_lpn_id not null.
                */
                IF (    (   (    used_for_cascaded_rows(i).transaction_type = 'RECEIVE'
                             AND used_for_cascaded_rows(i).auto_transact_code = 'DELIVER')
                         OR (used_for_cascaded_rows(i).transaction_type = 'DELIVER'))
                    AND (   used_for_cascaded_rows(i).transfer_lpn_id IS NOT NULL
                         OR used_for_cascaded_rows(i).transfer_license_plate_number IS NOT NULL)
                   ) THEN
                    IF (    NOT wms_install.check_install(l_return_status,
                                                          l_msg_count,
                                                          l_msg_data,
                                                          used_for_cascaded_rows(i).to_organization_id
                                                         )
                        AND l_return_status = fnd_api.g_ret_sts_success) THEN
                        used_for_cascaded_rows(i).transfer_lpn_id                := NULL;
                        used_for_cascaded_rows(i).transfer_license_plate_number  := NULL;

                        IF (g_asn_debug = 'Y') THEN
                            asn_debug.put_line('Set transfer_lpn_id and transfer_licese_plate_number to null for a deliver transaction in an non-WMS org for interface_trx_id ' || used_for_cascaded_rows(i).order_transaction_id);
                        END IF;
                    END IF;
                END IF;

                -- Bug 8584133: Start
                /*
                 *If do the return txn and the target org is non-WMS org, set the lpn related info to Null.
                */
                IF ( used_for_cascaded_rows(i).transaction_type = 'RETURN TO RECEIVING'
                     or  used_for_cascaded_rows(i).transaction_type = 'RETURN TO VENDOR'
                     or  used_for_cascaded_rows(i).transaction_type = 'CORRECT') THEN -- 9466603
                     --
                     IF ( used_for_cascaded_rows(i).lpn_id is NOT NULL
                          AND NOT wms_install.check_install(l_return_status,
                                                            l_msg_count,
                                                            l_msg_data,
                                                            used_for_cascaded_rows(i).to_organization_id
                                                            )
                          AND l_return_status = fnd_api.g_ret_sts_success) THEN
                          --
                          used_for_cascaded_rows(i).lpn_id               := NULL;
                          used_for_cascaded_rows(i).transfer_lpn_id      := NULL;
                          used_for_cascaded_rows(i).lpn_group_id         := NULL;
                          used_for_cascaded_rows(i).license_plate_number := NULL;

                          IF (g_asn_debug = 'Y') THEN
                              asn_debug.put_line('Set lpn_id and license_plate_number to null for a RETURN/CORRECTION transaction in an non-WMS org for interface_trx_id ' || used_for_cascaded_rows(i).order_transaction_id);
                          END IF;
                     END IF;
                END IF;
                -- Bug 8584133: End

                /* Bug 3434460 */
                x_progress                               := '020';
                used_for_cascaded_rows(i).error_status   := 'S';
                used_for_cascaded_rows(i).error_message  := NULL;

                -- validate shipment line information
                -- Bug 7651646
 	                 rcv_roi_transaction.validate_src_txn (used_for_cascaded_rows,i);
                --if(X_cascaded_table(n).receipt_source_code = 'VENDOR' and X_cascaded_table(n).transaction_type = 'RECEIVE') then
                IF (x_cascaded_table(n).receipt_source_code = 'VENDOR') THEN
                    rcv_roi_transaction.validate_vendor_rcv_line(used_for_cascaded_rows,
                                                                 i,
                                                                 x_asn_type,
                                                                 v_header_record
                                                                );
                ELSIF(x_cascaded_table(n).receipt_source_code = 'INTERNAL ORDER') THEN
                    rcv_int_order_pp_pvt.validate_io_receive_line(used_for_cascaded_rows,
                                                                  i,
                                                                  v_header_record
                                                                 );
                ELSIF(x_cascaded_table(n).receipt_source_code = 'INVENTORY') THEN
                    -- and X_cascaded_table(n).transaction_type = 'RECEIVE') then
                    rcv_int_org_transfer.validate_int_org_rcv_line(used_for_cascaded_rows,
                                                                   i,
                                                                   v_header_record
                                                                  );
                ELSIF(x_cascaded_table(n).receipt_source_code = 'CUSTOMER') THEN
                    rcv_rma_transactions.validate_rma_line(used_for_cascaded_rows,
                                                           i,
                                                           v_header_record
                                                          );
                END IF;

                x_progress                               := '030';

                IF (used_for_cascaded_rows(i).error_status NOT IN('S', 'W')) THEN --{
                    used_for_cascaded_rows(i).processing_status_code  := 'ERROR';
                    x_cascaded_table(n).processing_status_code        := 'ERROR';
                    x_cascaded_table(n).error_status                  := used_for_cascaded_rows(i).error_status;
                    x_cascaded_table(n).error_message                 := used_for_cascaded_rows(i).error_message;

                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('Have hit error condition in validation');
                        asn_debug.put_line('Mark needed flags and error message');
                        asn_debug.put_line('Delete the cascaded rows');
                    END IF;

                    used_for_cascaded_rows.DELETE;
                    EXIT;
                ELSIF(used_for_cascaded_rows(i).error_status IN('S', 'W')) THEN --}{
                    /* update interface_available_qty in rti .We now will look at
                     * this column to get the available qty if the current row
                     * is a child of another row in rti.
                    */
                    IF used_for_cascaded_rows(i).matching_basis = 'AMOUNT' THEN
                        asn_debug.put_line('calling update interface amt ');
                        rcv_roi_transaction.update_interface_available_amt(used_for_cascaded_rows, i);
                    ELSE
                        asn_debug.put_line('calling update interface qty ');
                        rcv_roi_transaction.update_interface_available_qty(used_for_cascaded_rows, i);
                    END IF;
                END IF; --}
            END LOOP; --}

            IF x_cascaded_table(n).processing_status_code = 'ERROR' THEN --{
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Have hit error condition in validation');
                    asn_debug.put_line('Mark needed flags and error message');
                    asn_debug.put_line('Delete the cascaded rows');
                END IF;

                used_for_cascaded_rows.DELETE;
            ELSE --} {
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Have finished default and validation');
                    asn_debug.put_line('Process has encountered no fatal errors');
                    asn_debug.put_line('Will write the cascaded rows into actual table');
                    asn_debug.put_line('Count of cascaded rows ' || TO_CHAR(used_for_cascaded_rows.COUNT));
                END IF;

                FOR j IN 1 .. used_for_cascaded_rows.COUNT LOOP --{
                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('Current counter in actual table is at ' || TO_CHAR(n));
                    END IF;

                    x_cascaded_table(n)  := used_for_cascaded_rows(j);
                    used_for_cascaded_rows.DELETE(j);
                    n                    := n + 1;
                END LOOP; --}

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Current counter before decrementing in actual table is at ' || TO_CHAR(n));
                END IF;

                n  := n - 1; -- Get the counter in sync

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Current counter in actual table is at ' || TO_CHAR(n));
                END IF;
            END IF; --}
        ELSE --} {
            x_cascaded_table(n).processing_status_code  := 'ERROR'; --  changed (i) -> (n)
            RETURN;
        END IF; --}

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Exit create shipment line');
        END IF;
    EXCEPTION
        WHEN rcv_error_pkg.e_fatal_error THEN
            x_cascaded_table(n).error_status   := 'E';
            x_cascaded_table(n).error_message  := rcv_error_pkg.get_last_message;
        WHEN OTHERS THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Exception in process_line');
            END IF;
    END process_line;

    PROCEDURE explode_lpn_failed(
        x_interface_txn_id IN OUT NOCOPY rcv_transactions_interface.interface_transaction_id%TYPE,
        x_group_id                       NUMBER,
        x_lpn_group_id                   NUMBER
    ) IS
    BEGIN
        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('update_rti_error in explode_lpn_failed   ');
        END IF;

        update_rti_error(p_group_id                => x_group_id,
                         p_interface_id            => x_interface_txn_id,
                         p_header_interface_id     => NULL,
                         p_lpn_group_id            => x_lpn_group_id
                        );
        rcv_error_pkg.set_error_message('RCV_LPN_EXPLOSION_FAILED');
        rcv_error_pkg.set_token('LPN_GROUP_ID', x_lpn_group_id);
        rcv_error_pkg.log_interface_warning('LPN_GROUP_ID');
    EXCEPTION
        WHEN OTHERS THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Exception in explode_lpn_failed');
            END IF;
    END explode_lpn_failed;

    PROCEDURE update_rti_error(
        p_group_id            IN rcv_transactions_interface.GROUP_ID%TYPE,
        p_interface_id        IN rcv_transactions_interface.interface_transaction_id%TYPE,
        p_header_interface_id IN rcv_transactions_interface.header_interface_id%TYPE,
        p_lpn_group_id        IN rcv_transactions_interface.lpn_group_id%TYPE
    ) IS
        l_return_status        VARCHAR2(1);
        l_msg_data             VARCHAR2(2000);
        l_msg_count            NUMBER;
        l_inventory_id         NUMBER;
        l_txn_mode             VARCHAR2(25);
        l_processing_mode_code rcv_transactions_interface.processing_mode_code%TYPE;
    BEGIN
        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Set rti row to error');
            asn_debug.put_line('p_group_id ' || p_group_id);
            asn_debug.put_line('p_interface_id ' || p_interface_id);
            asn_debug.put_line('p_header_interface_id ' || p_header_interface_id);
            asn_debug.put_line('p_lpn_group_id ' || p_lpn_group_id);
        END IF;

        -- bug 3676436, if there is a pending error message than we log it
        rcv_error_pkg.log_interface_error('INTERFACE_TRANSACTION_ID',FALSE);

        IF (p_header_interface_id IS NOT NULL) THEN
            SELECT DISTINCT (processing_mode_code)
            INTO            l_processing_mode_code
            FROM            rcv_transactions_interface
            WHERE           header_interface_id = p_header_interface_id;
        ELSIF(p_interface_id IS NOT NULL) THEN
            SELECT processing_mode_code
            INTO   l_processing_mode_code
            FROM   rcv_transactions_interface
            WHERE  interface_transaction_id = p_interface_id;
        ELSIF(p_group_id IS NOT NULL) THEN
            /* Bug 3361395.
             * When there is an when others exception in the
             * pre-processor we should not process any of the
             * Get the processing_mode here to use it later in
             * in this procedure.
            */
            SELECT DISTINCT (processing_mode_code)
            INTO            l_processing_mode_code
            FROM            rcv_transactions_interface
            WHERE           GROUP_ID = p_group_id;
        END IF;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Processing_mode_code ' || l_processing_mode_code);
        END IF;

        IF (l_processing_mode_code = 'ONLINE') THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('online error ');
            END IF;

            UPDATE rcv_transactions_interface
               SET processing_status_code = 'ERROR'
             WHERE GROUP_ID = p_group_id;

            inv_receiving_transaction.txn_complete(p_group_id          => p_group_id,
                                                   p_txn_status        => 'FALSE',
                                                   p_txn_mode          => 'ONLINE',
                                                   x_return_status     => l_return_status,
                                                   x_msg_data          => l_msg_data,
                                                   x_msg_count         => l_msg_count
                                                  );
        ELSE   /* For Batch and immediate */
            IF (p_header_interface_id IS NOT NULL) THEN
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('header_interface_id not null ');
                END IF;

                UPDATE rcv_transactions_interface
                   SET processing_status_code = 'ERROR'
                 WHERE header_interface_id = p_header_interface_id;

                l_inventory_id  := p_header_interface_id;
                l_txn_mode      := 'HEADER';
            ELSIF(p_lpn_group_id IS NOT NULL) THEN
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('lpn_group_id not null ');
                END IF;

                UPDATE rcv_transactions_interface
                   SET processing_status_code = 'ERROR'
                 WHERE lpn_group_id = p_lpn_group_id;

                l_inventory_id  := p_lpn_group_id;
                l_txn_mode      := 'LPN_GROUP';
            ELSIF(p_interface_id IS NOT NULL) THEN
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('interface_id not null ');
                END IF;

                UPDATE rcv_transactions_interface
                   SET processing_status_code = 'ERROR'
                 WHERE interface_transaction_id = p_interface_id;

                l_inventory_id  := p_interface_id;
                l_txn_mode      := 'PREPROCESSOR';
            ELSIF(p_group_id IS NOT NULL) THEN
                /* Bug 3361395.
                 * When there is an when others exception in the
                 * pre-processor we should not process any of the
                 * the rti or rhi rows. Call txn_complete with
                 * group_id and txn_mode as the processing mode.
                 * WMS assumes that when we call them with
                 * ONLINE/BATCH/IMMEDIATE then we call them with
                 * only group_id.
                */
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('update all rti rows to error');
                END IF;

                UPDATE rcv_headers_interface
                   SET processing_status_code = 'ERROR'
                 WHERE GROUP_ID = p_group_id;

                UPDATE rcv_transactions_interface
                   SET processing_status_code = 'ERROR'
                 WHERE GROUP_ID = p_group_id;

                l_inventory_id  := p_group_id;
                l_txn_mode      := l_processing_mode_code;
            END IF;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Before call to txn_complete');
            END IF;

            inv_receiving_transaction.txn_complete(p_group_id          => l_inventory_id,
                                                   p_txn_status        => 'FALSE',
                                                   p_txn_mode          => l_txn_mode,
                                                   x_return_status     => l_return_status,
                                                   x_msg_data          => l_msg_data,
                                                   x_msg_count         => l_msg_count
                                                  );

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('After call to txn_complete');
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Exception in update_rti_error');
            END IF;
    END update_rti_error;
END rcv_roi_preprocessor;

/
