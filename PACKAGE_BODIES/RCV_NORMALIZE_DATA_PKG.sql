--------------------------------------------------------
--  DDL for Package Body RCV_NORMALIZE_DATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_NORMALIZE_DATA_PKG" AS
/* $Header: RCVNRMDB.pls 120.15.12010000.18 2014/04/14 10:23:09 wayin ship $*/

   g_fail_if_one_line_fails   VARCHAR2(1) := nvl(fnd_profile.VALUE('RCV_FAIL_IF_LINE_FAILS'),'N'); /* lcm changes */
   g_org_id                   NUMBER;                                    -- Bug 14370850
   g_ou_name                  rcv_headers_interface.operating_unit%TYPE; -- Bug 14370850

   PROCEDURE handle_error(
      p_rti_row IN OUT NOCOPY rcv_transactions_interface%ROWTYPE
   ) IS
   BEGIN
      p_rti_row.processing_status_code  := 'ERROR';
      p_rti_row.processing_request_id   := g_request_id;

     IF (g_fail_all = 'Y') THEN
         /* Update statement called in update_rti_error
            UPDATE rcv_transactions_interface
            SET processing_status_code = 'ERROR',
                processing_request_id = g_request_id
          WHERE header_interface_id = p_rti_row.header_interface_id
         AND    processing_status_code IN('PENDING', 'RUNNING')
         AND    transaction_status_code = 'PENDING';
         */
    /*BEGIN BUG: 5598140*/
         RCV_ROI_PREPROCESSOR.update_rti_error(p_group_id                => p_rti_row.group_id,
                   p_interface_id            => NULL,
                   p_header_interface_id     => p_rti_row.header_interface_id,
                   p_lpn_group_id            => NULL
                  );
      ELSIF (p_rti_row.lpn_group_id is not null) THEN
      RCV_ROI_PREPROCESSOR.update_rti_error(p_group_id                => p_rti_row.group_id,
                         p_interface_id            => NULL,
                         p_header_interface_id     => NULL,
                         p_lpn_group_id            => p_rti_row.lpn_group_id
                        );

      ELSE
      RCV_ROI_PREPROCESSOR.update_rti_error(p_group_id                => p_rti_row.group_id,
                         p_interface_id            => p_rti_row.interface_transaction_id,
                         p_header_interface_id     => NULL,
                         p_lpn_group_id            => NULL
                        );
      /*END BUG: 5598140*/
      END IF;

      rcv_table_functions.update_rti_row(p_rti_row);

      IF (g_multiple_groups = FALSE) THEN
         COMMIT; --We don't want to erase what we've done so far
         --RAISE rcv_error_pkg.e_fatal_error;
      END IF;
   END handle_error;

   PROCEDURE check_orphan_rhi(
      p_rhi_row IN OUT NOCOPY rcv_headers_interface%ROWTYPE
   ) IS
      x_rti_count NUMBER;
      proc_code rcv_headers_interface.processing_status_code%TYPE;
   BEGIN
      SELECT count(*)
        INTO x_rti_count
        FROM rcv_transactions_interface
       WHERE header_interface_id = p_rhi_row.header_interface_id
         AND processing_status_code in ('PENDING','RUNNING')
         AND transaction_status_code = 'PENDING';

      asn_debug.put_line('count of running rtis'|| x_rti_count);

      IF x_rti_count = 0  THEN -- error out orphan rhi
         asn_debug.put_line('Erroring out orphan RHI: ' ||
                             p_rhi_row.header_interface_id);

         p_rhi_row.processing_status_code  := 'ERROR';
         p_rhi_row.processing_request_id   := g_request_id;

         rcv_table_functions.update_rhi_row(p_rhi_row);
         COMMIT;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END check_orphan_rhi;

   PROCEDURE prepare_pending_rhi(
      p_rhi_row IN OUT NOCOPY rcv_headers_interface%ROWTYPE
   ) IS
      x_org_id NUMBER;
   BEGIN --update block
      BEGIN --exception handling block
         rcv_default_pkg.default_header(p_rhi_row);
      EXCEPTION
         WHEN OTHERS THEN
            p_rhi_row.processing_status_code  := 'ERROR';
            p_rhi_row.processing_request_id   := g_request_id;

            UPDATE rcv_transactions_interface
               SET processing_status_code = 'ERROR',
                   processing_request_id = g_request_id
             WHERE header_interface_id = p_rhi_row.header_interface_id
            AND    processing_status_code IN('PENDING', 'RUNNING')
            AND    transaction_status_code = 'PENDING';
      END; --exception handling block

      rcv_table_functions.update_rhi_row(p_rhi_row);
   END prepare_pending_rhi;

   PROCEDURE prepare_pending_rti(
      p_rti_row IN OUT NOCOPY rcv_transactions_interface%ROWTYPE
   ) IS
   BEGIN --this is the update block
      BEGIN --this is the exception catching block
         IF (p_rti_row.GROUP_ID IS NULL) THEN
            p_rti_row.GROUP_ID  := g_group_id;
         END IF;

         IF (p_rti_row.validation_flag = 'Y') THEN
            rcv_default_pkg.default_transaction(p_rti_row);

	  /* Bug 7229164 Populating Order transaction id for desktop transactions also
 	     so that the records from RTI are now picked and processed in the correct order. */
 	 ELSE
 	    p_rti_row.order_transaction_id := p_rti_row.interface_transaction_id;
         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            handle_error(p_rti_row);
      END; --exception handling block

      rcv_table_functions.update_rti_row(p_rti_row);
   END prepare_pending_rti;

   PROCEDURE process_orphan_rti(
      p_rti_row IN OUT NOCOPY rcv_transactions_interface%ROWTYPE
   ) IS
   BEGIN
      rcv_error_pkg.set_error_message('RCV_IS_ORPHAN');
      rcv_error_pkg.log_interface_error('PARENT_INTERFACE_TXN_ID');
   EXCEPTION
      WHEN OTHERS THEN
         p_rti_row.processing_status_code  := 'ERROR';
         p_rti_row.processing_request_id   := g_request_id;
         rcv_table_functions.update_rti_row(p_rti_row);
   END;

   PROCEDURE process_row(
      p_rti_row IN OUT NOCOPY rcv_transactions_interface%ROWTYPE
   ) IS
      x_rhi_row rcv_headers_interface%ROWTYPE;

      -- Following 4 variables are added for BugFix 5078706
      l_parent_transaction_type        rcv_transactions.transaction_type%type;
      l_parent_transaction_id          rcv_transactions.transaction_id%type;
      l_true                           boolean;
      l_match_count                    number;

      /* lcm changes */
      l_lpn_group_rti_count            number := 0;
      x_header_record                  rcv_roi_preprocessor.header_rec_type;

      --Following 2 variables are added for bugfix 18332568
      rt                               rcv_transactions%ROWTYPE;
      rti                              rcv_transactions_interface%ROWTYPE;
      l_matching_basis                 po_line_locations_all.matching_basis%TYPE;
      l_po_line_loc_id                 NUMBER;
   BEGIN
        l_true := TRUE;  -- BugFix 5078706

      BEGIN
         asn_debug.put_line('Processing row INTERFACE_TRANSACTION_ID = ' || p_rti_row.interface_transaction_id);

-- Following code is added for BugFix 5078706
	BEGIN
		select  transaction_id,
                        transaction_type
		into	l_parent_transaction_id,
                        l_parent_transaction_type
		from    rcv_transactions
		where	transaction_type = 'UNORDERED'
		connect by prior
			parent_transaction_id = transaction_id
		start with transaction_id = p_rti_row.parent_transaction_id;

                begin
                        select  count(1)
                        into    l_match_count
                        from    rcv_transactions
                        where   transaction_type = 'MATCH'
                        and     parent_transaction_id = l_parent_transaction_id;
                exception
                        when    others
                        then
                                l_match_count := 0;
                end;

                IF (l_parent_transaction_type = 'UNORDERED' and l_match_count = 0)
                THEN
                        l_true := FALSE;
                ELSE
                        l_true := TRUE;
                END IF;

        EXCEPTION
                WHEN    OTHERS
                THEN
                        l_true := TRUE;
        END;
-- End of code for BugFix 5078706

        /*
        ** Bug#4641243 - Operating Unit information will not be available for
        ** Unordered Receipts
        */
        --Bug 8679527 For Cross OU Receipts the RTI.ORG_ID is populated as Creation OU id
        --But when MO:Security Profile is not set this causing issues. So, restricting
        --this validation for ROI txns.

        IF (p_rti_row.transaction_type <> 'UNORDERED' AND p_rti_row.source_document_code <> 'INVENTORY'
             AND p_rti_row.validation_flag='Y' and p_rti_row.mobile_txn<>'Y') THEN -- bug 5147243
          IF (l_true = TRUE) -- BugFix 5078706
	  THEN
             IF (NVL(mo_global.check_access(p_rti_row.org_id),'N') = 'N') THEN
                rcv_error_pkg.set_error_message('RCV_NOT_IN_ORG');
                rcv_error_pkg.set_token('ORG_ID', p_rti_row.org_id);
                rcv_error_pkg.set_token('OU', mo_global.get_current_org_id);
                rcv_error_pkg.log_interface_error('ORG_ID');
             END IF;
          END IF; -- BugFix 5078706
        END IF;

         /* Bugfix : 5354379 : The defaulting should not be called from here since the parent row will be in
                               status "RUNNING" at this instance and which will therefore cause the  rcv_default_pkg.default_from_parent
                               to raise an error thru rcv_default_pkg.default_rti_from_rti.
         IF (p_rti_row.parent_interface_txn_id IS NOT NULL) THEN
            rcv_default_pkg.default_from_parent(p_rti_row); -- we want to pull in any new information about the row
         END IF;
         */
         /*18332568  Return are not supported against service lines */
         IF p_rti_row.transaction_type IN ('RETURN TO VENDOR','RETURN TO RECEIVING') THEN
            rt := rcv_table_functions.get_rt_row_from_id(p_rti_row.parent_transaction_id);
            IF rt.transaction_id IS NOT NULL THEN
               l_po_line_loc_id := rt.po_line_location_id;
            ELSE
               rti := rcv_table_functions.get_rti_row_from_id(p_rti_row.parent_interface_txn_id);
               IF rti.po_line_location_id IS NULL THEN
                  rcv_error_pkg.set_error_message('RCV_NO_PARENT_TRANSACTION');
                  rcv_error_pkg.log_interface_error('RCV_TRANSACTIONS_INTERFACE',
                                                    'PARENT_TRANSACTION_ID',
                                                    p_rti_row.group_id,
                                                    p_rti_row.header_interface_id,
                                                    p_rti_row.interface_transaction_id);
               ELSE
                  l_po_line_loc_id := rti.po_line_location_id;
               END IF;
            END IF;

            BEGIN
               SELECT nvl(matching_basis,'GOODS')
                 INTO l_matching_basis
                 FROM po_line_locations_all
                WHERE line_location_id = l_po_line_loc_id;
            EXCEPTION
               WHEN OTHERS THEN
                 l_matching_basis := NULL;
            END;

            IF l_matching_basis = 'AMOUNT' THEN
              rcv_error_pkg.set_error_message('RCV_NO_RTV_FOR_SERVICE_LINES');
              rcv_error_pkg.log_interface_error('RCV_TRANSACTIONS_INTERFACE',
                                                'PARENT_TRANSACTION_ID',
                                                p_rti_row.group_id,
                                                p_rti_row.header_interface_id,
                                                p_rti_row.interface_transaction_id);
            END IF;
         END IF;
         /*End of Bug 18332568*/

      EXCEPTION
         WHEN OTHERS THEN
            handle_error(p_rti_row);
      END;

      /* EXECUTE PROCESSOR on row */
      IF (p_rti_row.processing_status_code <> 'ERROR') THEN

         /* lcm chages : Start */
         x_rhi_row := rcv_table_functions.get_rhi_row_from_id(p_rti_row.header_interface_id);

         IF  ( rcv_table_functions.is_lcm_org (p_rti_row.to_organization_id) = 'Y'
	       AND rcv_table_functions.is_pre_rcv_org (p_rti_row.to_organization_id) = 'N') Then
               --
               IF ( p_rti_row.source_document_code = 'PO'
                    AND (p_rti_row.transaction_type = 'RECEIVE'
                         OR (p_rti_row.transaction_type = 'SHIP'
                             AND p_rti_row.auto_transact_code in ('RECEIVE','DELIVER')))
                    AND rcv_table_functions.is_lcm_shipment (p_rti_row.po_line_location_id) = 'Y'
                    AND p_rti_row.lcm_shipment_line_id is null) THEN
                    --
                    asn_debug.put_line('Setting current row to status LC_PENDING');
                    p_rti_row.processing_status_code  := 'LC_PENDING';
                    --
                    -- Bug 8343811: Start
                    IF (x_rhi_row.receipt_num IS NULL) THEN
                        x_header_record.header_record := x_rhi_row;
                        rcv_roi_header_common.default_receipt_info(x_header_record);
                        IF (x_header_record.error_record.error_status = 'E') THEN
                            x_rhi_row.processing_status_code := 'ERROR';
                        ELSE
                            x_rhi_row.processing_status_code := 'LC_PENDING';
                            x_rhi_row.receipt_num := x_header_record.header_record.receipt_num;
                            asn_debug.put_line('Generated new receipt_num for rhi : ' || x_rhi_row.receipt_num, null,14);
                        END IF;
                        rcv_table_functions.update_rhi_row(x_rhi_row);
                    END IF;
                    -- Bug 8343811: End
               ELSE
                  /* If a non-lcm line and lcm line are tied to the same lpn_group_id, we
                     need to set the non-lcm line to 'WLC_PENDING' as these should be processed together. */
                  IF (p_rti_row.lpn_group_id IS NOT NULL) THEN
                        select count(1)
                        into   l_lpn_group_rti_count
                        from   rcv_transactions_interface rti
                        where  rti.group_id = p_rti_row.group_id
                        and    rti.lpn_group_id is not null
                        and    rti.lpn_group_id = p_rti_row.lpn_group_id
                        and    rti.interface_transaction_id <> p_rti_row.interface_transaction_id  -- Bug 8343139
                        and    (rti.transaction_type = 'RECEIVE'
                                or (rti.transaction_type = 'SHIP'
                                    and rti.auto_transact_code in ('RECEIVE','DELIVER')))          -- Bug 8343139
                        and    rti.source_document_code = 'PO'
                        and    exists (select 'LCM Shipment' from po_line_locations_all pll
                                       where  pll.line_location_id = rti.po_line_location_id
                                       and    lcm_flag = 'Y')
                        and    (rti.lcm_shipment_line_id is null or rti.unit_landed_cost is null);
                               --
                               asn_debug.put_line('LPN Group check : l_lpn_group_rti_count = ' ||l_lpn_group_rti_count, null,14);
                               --
                  END IF;
                  --
                  IF (x_rhi_row.asn_type = 'ASN'
		      AND g_fail_if_one_line_fails = 'Y'
		      AND l_lpn_group_rti_count = 0) THEN
                          select count(1)
                          into   l_lpn_group_rti_count
                          from   rcv_transactions_interface rti
                          where  rti.group_id = x_rhi_row.group_id
                          and    rti.header_interface_id = x_rhi_row.header_interface_id
                          and    rti.interface_transaction_id <> p_rti_row.interface_transaction_id -- Bug 8343139
                          and    (rti.transaction_type = 'RECEIVE'
                                  or (rti.transaction_type = 'SHIP'
                                      and rti.auto_transact_code in ('RECEIVE','DELIVER')))         -- Bug 8343139
                          and    rti.source_document_code = 'PO'
                          and    exists (select 'LCM Shipment' from po_line_locations_all pll
                                         where  pll.line_location_id = rti.po_line_location_id
                                         and    lcm_flag = 'Y')
                          and    (rti.lcm_shipment_line_id is null or rti.unit_landed_cost is null);
                                  --
                                  asn_debug.put_line('ASN check : l_lpn_group_rti_count = ' ||l_lpn_group_rti_count, null,14);
                                  --
                  END IF;
		  IF (l_lpn_group_rti_count > 0) THEN
                      asn_debug.put_line('Setting current row to status WLC_PENDING');
                      p_rti_row.processing_status_code  := 'WLC_PENDING';
                      p_rti_row.processing_request_id   := g_request_id;
                      IF (x_rhi_row.processing_status_code = 'ERROR') THEN
                          asn_debug.put_line('Setting header row status HEADER_INTERFACE_ID=' || x_rhi_row.header_interface_id);
                          x_rhi_row.processing_status_code  := 'PENDING';
                          x_rhi_row.processing_request_id   := g_request_id;
                          rcv_table_functions.update_rhi_row(x_rhi_row);
                      END IF;
		  ELSE
                      asn_debug.put_line('Setting current row to status RUNNING');
                      p_rti_row.processing_status_code  := 'RUNNING';
                      p_rti_row.processing_request_id   := g_request_id;
                      IF (x_rhi_row.processing_status_code IN ('PENDING', 'ERROR')) THEN
                          asn_debug.put_line('Setting header row status HEADER_INTERFACE_ID=' || x_rhi_row.header_interface_id);
                          x_rhi_row.processing_status_code  := 'RUNNING';
                          x_rhi_row.processing_request_id   := g_request_id;
                          rcv_table_functions.update_rhi_row(x_rhi_row);
                      END IF;
                  END IF;
                  --
	       END IF;
               --
	 ELSE
             asn_debug.put_line('Setting current row to status RUNNING');
             p_rti_row.processing_status_code  := 'RUNNING';
             p_rti_row.processing_request_id   := g_request_id;

             IF (x_rhi_row.processing_status_code IN('PENDING', 'ERROR')) THEN
                asn_debug.put_line('Setting header row status HEADER_INTERFACE_ID=' || x_rhi_row.header_interface_id);
                x_rhi_row.processing_status_code  := 'RUNNING';
                x_rhi_row.processing_request_id   := g_request_id;
                rcv_table_functions.update_rhi_row(x_rhi_row);
             END IF;
	 END IF;
         /* lcm chages : End */

      END IF;

      rcv_table_functions.update_rti_row(p_rti_row);
   END;

   PROCEDURE explode_all_lpn IS
      l_ret_status VARCHAR2(20);
      l_msg_count  NUMBER;
      l_msg_data   VARCHAR2(100);
   BEGIN
      asn_debug.put_line('in explode_all_lpn');

      -- Bug 14370850
      IF (g_org_id = -1) THEN
          UPDATE rcv_transactions_interface
          SET    processing_status_code = 'RUNNING',
                 processing_request_id = g_request_id
          WHERE  processing_status_code = 'PENDING'
          AND    (    processing_request_id = g_request_id
                   OR processing_request_id IS NULL)
          AND    (    mo_global.check_access(org_id) = 'Y'
                   OR org_id IS NULL)
          AND    (    lpn_group_id IS NOT NULL
                   OR lpn_id IS NOT NULL
                   OR license_plate_number IS NOT NULL
                   OR interface_transaction_id IN (SELECT interface_transaction_id
                                                   FROM   wms_lpn_contents_interface));
      ELSE
          UPDATE rcv_transactions_interface
          SET    processing_status_code = 'RUNNING',
                 processing_request_id = g_request_id
          WHERE  processing_status_code = 'PENDING'
          AND    (    processing_request_id = g_request_id
                   OR processing_request_id IS NULL)
          AND    org_id = g_org_id
          AND    (    lpn_group_id IS NOT NULL
                   OR lpn_id IS NOT NULL
                   OR license_plate_number IS NOT NULL
                   OR interface_transaction_id IN (SELECT interface_transaction_id
                                                   FROM   wms_lpn_contents_interface));

      END IF;


      inv_rcv_integration_apis.explode_lpn(1.0,
                                           fnd_api.g_true,
                                           l_ret_status,
                                           l_msg_count,
                                           l_msg_data,
                                           NULL,
                                           g_request_id
                                          );

      -- Bug 14370850
      IF (g_org_id = -1) THEN
          UPDATE rcv_transactions_interface
          SET    processing_status_code = 'PENDING'
          WHERE  processing_status_code = 'RUNNING'
          AND    processing_request_id = g_request_id;
      ELSE
          UPDATE rcv_transactions_interface
          SET    processing_status_code = 'PENDING'
          WHERE  processing_status_code = 'RUNNING'
          AND    processing_request_id = g_request_id
          AND    org_id = g_org_id;
      END IF;

      asn_debug.put_line('finished explode_all_lpn');
   EXCEPTION
      WHEN OTHERS THEN
         asn_debug.put_line('encountered an error in explode_all_lpn');
   END explode_all_lpn;

   PROCEDURE explode_lpn IS
      l_ret_status VARCHAR2(20);
      l_msg_count  NUMBER;
      l_msg_data   VARCHAR2(100);
   BEGIN
      asn_debug.put_line('in explode_lpn');

      -- Bug 14370850
      IF (g_org_id = -1) THEN
          UPDATE rcv_transactions_interface
          SET    processing_status_code = 'RUNNING',
                 processing_request_id = g_request_id,
                 group_id = g_group_id
          WHERE  processing_status_code = 'PENDING'
          AND    (   processing_request_id = g_request_id
                  OR processing_request_id IS NULL)
          AND    group_id = g_group_id
          AND    (   lpn_group_id IS NOT NULL
                  OR lpn_id IS NOT NULL
                  OR license_plate_number IS NOT NULL
                  OR interface_transaction_id IN (SELECT interface_transaction_id
                                                  FROM   wms_lpn_contents_interface));
      ELSE
          UPDATE rcv_transactions_interface
          SET    processing_status_code = 'RUNNING',
                 processing_request_id = g_request_id,
                 group_id = g_group_id
          WHERE  processing_status_code = 'PENDING'
          AND    (   processing_request_id = g_request_id
                  OR processing_request_id IS NULL)
          AND    group_id = g_group_id
          AND    org_id = g_org_id
          AND    (   lpn_group_id IS NOT NULL
                  OR lpn_id IS NOT NULL
                  OR license_plate_number IS NOT NULL
                  OR interface_transaction_id IN (SELECT interface_transaction_id
                                                  FROM   wms_lpn_contents_interface));

      END IF;

      inv_rcv_integration_apis.explode_lpn(1.0,
                                           fnd_api.g_true,
                                           l_ret_status,
                                           l_msg_count,
                                           l_msg_data,
                                           g_group_id,
                                           g_request_id
                                          );

      -- Bug 14370850
      IF (g_org_id = -1) THEN
          UPDATE rcv_transactions_interface
          SET    processing_status_code = 'PENDING'
          WHERE  processing_status_code = 'RUNNING'
          AND    processing_request_id = g_request_id
          AND    group_id = g_group_id;
      ELSE
          UPDATE rcv_transactions_interface
          SET    processing_status_code = 'PENDING'
          WHERE  processing_status_code = 'RUNNING'
          AND    processing_request_id = g_request_id
          AND    group_id = g_group_id
          AND    org_id = g_org_id;
      END IF;

      asn_debug.put_line('finished explode_lpn');
   EXCEPTION
      WHEN OTHERS THEN
         asn_debug.put_line('encountered an error in explode_lpn');
   END explode_lpn;

   PROCEDURE process_pending_rows(
      p_processing_mode IN VARCHAR2,
      p_group_id        IN NUMBER,
      p_request_id      IN NUMBER,
      p_org_id          IN NUMBER
   ) IS
      CURSOR c_get_group_id IS
         SELECT rcv_interface_groups_s.NEXTVAL
         FROM   DUAL;

      CURSOR c_get_all_pending_rhi_row IS
         SELECT *
         FROM   rcv_headers_interface
         WHERE  processing_status_code = 'PENDING'
         AND    (   mo_global.check_access(org_id) = 'Y'
                 OR org_id IS NULL)
         ORDER BY group_id, header_interface_id; -- added by bug 16393104 to avoid deadlock
         -- FOR UPDATE NOWAIT;    --Added by bug 13587955

      CURSOR c_get_pending_rhi_row IS
         SELECT *
         FROM   rcv_headers_interface
         WHERE  processing_status_code = 'PENDING'
         AND    GROUP_ID = g_group_id
         ORDER BY header_interface_id; -- added by bug 16393104 to avoid deadlock
         -- FOR UPDATE NOWAIT;    --Added by bug 13587955

      /* the order is important, which is the reason for the connect by string */
      /* this ensures defaulting from a parent row that has already been populated */
      /* however, because of this we will not collect 'orphan' rows - we need to
      /* error out the orphans */
      /* WDK - ADD INDEX ON PARENT_INTERFACE_TXN_ID */
      CURSOR c_get_all_pending_rti_row IS
         SELECT * FROM (              --Bug 12594135
		SELECT     *
		FROM       rcv_transactions_interface
		WHERE      processing_status_code = 'PENDING'
		AND        processing_mode_code = g_processing_mode  -- Bug 6311798
		AND        (   mo_global.check_access(org_id) = 'Y'
			     OR org_id IS NULL)
			) rcv
         CONNECT BY PRIOR rcv.interface_transaction_id = rcv.parent_interface_txn_id
         START WITH rcv.parent_interface_txn_id IS NULL  --Reverted the initial fix of 12718851 and keeping the original code
         ORDER BY  group_id, interface_transaction_id;   -- added by bug 16393104 to avoid deadlock
         -- FOR UPDATE NOWAIT;    --Added by bug 13587955

      CURSOR c_get_pending_rti_row IS
         SELECT * FROM (              --Bug 12594135
		SELECT     *
		FROM       rcv_transactions_interface
		WHERE      processing_status_code = 'PENDING'
		AND        processing_mode_code = g_processing_mode  -- Bug 6311798
		AND        GROUP_ID = g_group_id
			) rcv
         CONNECT BY PRIOR rcv.interface_transaction_id = rcv.parent_interface_txn_id
         START WITH rcv.parent_interface_txn_id IS  NULL --Reverted the initial fix of 12718851 and keeping the original code
         ORDER BY   interface_transaction_id;  -- added by bug 16393104 to avoid deadlock
         -- FOR UPDATE NOWAIT;    --Added by bug 13587955

      /* because we needed to include parent/child order, we introduce the possibility */
      /* of not processing 'orphan' children.  these children need to be errored out */

/** Bug: 5473673
  * There is possibility to have more than 1 orphan record exist in
  * rcv_transactions_interface table. In that case inner query will
  * multiple rows, but we are having the condition "=" in
  * the clause "START WITH". So, we have to replace the contition
  * "=" with "IN"
  */
  /* Bug 8745599 The cursors c_get_all_orphan_rti_row and c_get_orphan_rti_row were wrongly fetching
     genuine RTI records that need to be processed, due to the way the CONNECT BY clause is handling
     NULL values for parent_interface_txn_id. This was resulting in RTP errorring out with RCV_IS_ORPHAN
     error, even though these are not orphan records. Added a condition in both the cursors to ensure
     that rows are returned only when parent_transaction_id is not null, and parent record is absent.
  */

      CURSOR c_get_all_orphan_rti_row IS
         SELECT     *
         FROM       rcv_transactions_interface rti
         WHERE      rti.processing_status_code = 'PENDING'
	 AND        rti.processing_mode_code = g_processing_mode  -- Bug 6311798
         AND        (   mo_global.check_access(rti.org_id) = 'Y'
                     OR rti.org_id IS NULL)
         CONNECT BY PRIOR rti.interface_transaction_id = parent_interface_txn_id
         START WITH rti.interface_transaction_id IN (SELECT rti1.interface_transaction_id --Bug:5473673
                                                FROM   rcv_transactions_interface rti1
                                                WHERE  rti1.parent_interface_txn_id IS NOT NULL -- Bug 8745599
						                                    AND rti1.PROCESSING_MODE_CODE = g_processing_mode  --Bug 12594135
                                                AND rti1. parent_interface_txn_id NOT IN(SELECT rti2.interface_transaction_id
                                                                                      FROM   rcv_transactions_interface rti2))
         ORDER BY rti.group_id, rti.interface_transaction_id;  -- added by bug 16393104 to avoid deadlock
         -- FOR UPDATE NOWAIT;    --Added by bug 13587955

      CURSOR c_get_orphan_rti_row IS
         SELECT     *
         FROM       rcv_transactions_interface rti
         WHERE      rti.processing_status_code = 'PENDING'
	 AND        rti.processing_mode_code = g_processing_mode  -- Bug 6311798
         AND        rti.GROUP_ID = g_group_id
         CONNECT BY PRIOR rti.interface_transaction_id = rti.parent_interface_txn_id
         START WITH rti.interface_transaction_id IN (SELECT rti1.interface_transaction_id --Bug: 5473673
                                                FROM   rcv_transactions_interface rti1
                                                WHERE  rti1.parent_interface_txn_id IS NOT NULL -- Bug 8745599
						                                      AND rti1.PROCESSING_MODE_CODE = g_processing_mode  --Bug 12594135
						                                      AND rti1.GROUP_ID = g_group_id		      --Bug 12594135
                                                  AND  rti1.parent_interface_txn_id NOT IN(SELECT rti2.interface_transaction_id
                                                                                      FROM   rcv_transactions_interface rti2))
         ORDER BY rti.interface_transaction_id;  -- added by bug 16393104 to avoid deadlock
         -- FOR UPDATE NOWAIT;    --Added by bug 13587955

      -- Bug 14370850 : Start
      CURSOR c_get_all_pending_rhi_row2 IS
         SELECT *
         FROM   rcv_headers_interface
         WHERE  processing_status_code = 'PENDING'
         AND    org_id = p_org_id
         ORDER BY group_id,header_interface_id; -- added by bug 16393104 to avoid deadlock
         -- FOR UPDATE NOWAIT;    --Added by bug 13587955

      CURSOR c_get_all_pending_rti_row2 IS
         SELECT * FROM (
		           SELECT     *
		           FROM       rcv_transactions_interface
		           WHERE      processing_status_code = 'PENDING'
		           AND        processing_mode_code = g_processing_mode
		           AND        org_id = p_org_id
		        ) rcv
         CONNECT BY PRIOR rcv.interface_transaction_id = rcv.parent_interface_txn_id
         START WITH rcv.parent_interface_txn_id IS NULL
         ORDER BY  group_id, interface_transaction_id;   -- added by bug 16393104 to avoid deadlock
         -- FOR UPDATE NOWAIT;    --Added by bug 13587955

      CURSOR c_get_all_orphan_rti_row2 IS
         SELECT     *
         FROM       rcv_transactions_interface rti
         WHERE      rti.processing_status_code = 'PENDING'
         AND        rti.processing_mode_code = g_processing_mode
         AND        rti.org_id = p_org_id
         CONNECT BY PRIOR rti.interface_transaction_id = rti.parent_interface_txn_id
         START WITH rti.interface_transaction_id IN (SELECT rti1.interface_transaction_id
                                                 FROM   rcv_transactions_interface rti1
                                                 WHERE  rti1.parent_interface_txn_id IS NOT NULL
                                                 AND    rti1.processing_mode_code = g_processing_mode
                                                 AND    rti1.org_id = p_org_id
                                                 AND    rti1.parent_interface_txn_id NOT IN (SELECT rti2.interface_transaction_id
                                                                                        FROM   rcv_transactions_interface rti2))
         ORDER BY rti.group_id, rti.interface_transaction_id;  -- added by bug 16393104 to avoid deadlock
         -- FOR UPDATE NOWAIT;    --Added by bug 13587955

      CURSOR c_get_pending_rhi_row2 IS
         SELECT *
         FROM   rcv_headers_interface
         WHERE  processing_status_code = 'PENDING'
         AND    group_id = g_group_id
         AND    org_id = p_org_id
         ORDER BY header_interface_id; -- added by bug 16393104 to avoid deadlock
         -- FOR UPDATE NOWAIT;    --Added by bug 13587955

      CURSOR c_get_pending_rti_row2 IS
         SELECT * FROM (
		           SELECT     *
		           FROM       rcv_transactions_interface
		           WHERE      processing_status_code = 'PENDING'
		           AND        processing_mode_code = g_processing_mode
		           AND        group_id = g_group_id
		           AND        org_id = p_org_id
		        ) rcv
         CONNECT BY PRIOR rcv.interface_transaction_id = rcv.parent_interface_txn_id
         START WITH       rcv.parent_interface_txn_id IS  NULL
         ORDER BY   interface_transaction_id;  -- added by bug 16393104 to avoid deadlock
         -- FOR UPDATE NOWAIT;    --Added by bug 13587955

      CURSOR c_get_orphan_rti_row2 IS
         SELECT     *
         FROM       rcv_transactions_interface rti
         WHERE      rti.processing_status_code = 'PENDING'
         AND        rti.processing_mode_code = g_processing_mode
         AND        rti.org_id = p_org_id
         CONNECT BY PRIOR rti.interface_transaction_id = rti.parent_interface_txn_id
         START WITH rti.interface_transaction_id IN (SELECT rti1.interface_transaction_id
                                                 FROM   rcv_transactions_interface rti1
                                                 WHERE  rti1.parent_interface_txn_id IS NOT NULL
                                                 AND    rti1.processing_mode_code = g_processing_mode
                                                 AND    rti1.group_id = g_group_id
                                                 AND    rti1.org_id = p_org_id
                                                 AND    rti1.parent_interface_txn_id NOT IN (SELECT rti2.interface_transaction_id
                                                                                        FROM   rcv_transactions_interface rti2))
         ORDER BY rti.interface_transaction_id;  -- added by bug 16393104 to avoid deadlock
         -- FOR UPDATE NOWAIT;    --Added by bug 13587955

      -- Bug 14370850 : End

    row_locked EXCEPTION; --Added by bug 13587955
    PRAGMA EXCEPTION_INIT(row_locked, -54); --Added by bug 13587955
    x_rti_row1 rcv_transactions_interface%ROWTYPE; -- added by bug 16393104
    x_rhi_row1 rcv_headers_interface%ROWTYPE; -- added by bug 16393104

   BEGIN
      IF p_processing_mode = 'BATCH' THEN
         IF    p_group_id IS NULL
            OR p_group_id = 0 THEN
            g_multiple_groups  := TRUE;
         ELSE
            g_group_id         := p_group_id;
            g_multiple_groups  := FALSE;
         END IF;
      ELSE --p_processing = 'ONLINE' or 'IMMEDIATE'
         g_multiple_groups  := FALSE;
      END IF;

      g_group_id                            := NVL(p_group_id, 0);
      g_request_id                          := NVL(p_request_id, 0);
      g_processing_mode                     := p_processing_mode; -- Bug 6311798
      rcv_table_functions.g_default_org_id  := p_org_id;

      -- Bug 14370850
      g_org_id                              := p_org_id;

      IF (g_org_id <> -1) THEN
          IF (NVL(mo_global.check_access(g_org_id),'N') = 'N') THEN
              asn_debug.put_line ('No access allowed. Returning');
              RETURN;
          END IF;

          SELECT name
          INTO   g_ou_name
          FROM   hr_organization_units
          WHERE  organization_id = g_org_id;
      END IF;

      IF g_group_id = 0 THEN
         OPEN c_get_group_id;
         FETCH c_get_group_id INTO g_group_id;
         CLOSE c_get_group_id;
      END IF;

      asn_debug.put_line('Process Pending Rows: p_processing_mode=' || p_processing_mode || ' g_group_id=' || g_group_id || ' g_request_id=' || g_request_id || ' p_org_id=' || p_org_id);

      /* we cannot use bulk collects because we are using the tablespace as working memory */
      -- Bug 14370850 : Start
      IF (p_org_id <> -1) THEN
	      IF (g_multiple_groups = TRUE) THEN
		 asn_debug.put_line('Processing multiple groups when p_org_id is passed...');
		 explode_all_lpn;

		 UPDATE rcv_headers_interface
		 SET    org_id = p_org_id
		 WHERE  processing_status_code = 'PENDING'
		 AND    org_id IS NULL
		 AND    operating_unit = g_ou_name;

		 UPDATE rcv_transactions_interface
		 SET    org_id = p_org_id
		 WHERE  processing_status_code = 'PENDING'
		 AND    validation_flag = 'Y'
		 AND    org_id IS NULL
		 AND    operating_unit = g_ou_name;

		 asn_debug.put_line('Derived org_id');

		 FOR x_rhi_row IN c_get_all_pending_rhi_row2 LOOP
                  -- bug 16393104 start
                  SELECT *
                    INTO x_rhi_row1
                    FROM rcv_headers_interface WHERE header_interface_id = x_rhi_row.header_interface_id
                     FOR UPDATE NOWAIT;

                  prepare_pending_rhi(x_rhi_row1);
                  -- bug 16393104 end

		 END LOOP;

		 FOR x_rti_row IN c_get_all_pending_rti_row2 LOOP
                  -- bug 16393104 start
                  SELECT *
                    INTO x_rti_row1
                    FROM rcv_transactions_interface WHERE interface_transaction_id = x_rti_row.interface_transaction_id
                     FOR UPDATE NOWAIT;

                  prepare_pending_rti(x_rti_row1);
                  -- bug 16393104 end

		 END LOOP;

                 BEGIN  -- Bug 13587955
		    FOR x_rti_row IN c_get_all_orphan_rti_row2 LOOP
                  -- bug 16393104 start
                  SELECT *
                    INTO x_rti_row1
                    FROM rcv_transactions_interface WHERE interface_transaction_id = x_rti_row.interface_transaction_id
                     FOR UPDATE NOWAIT;

                  process_orphan_rti(x_rti_row1);
                  -- bug 16393104 end

		    END LOOP;
                 -- Bug 13587955 New BEGIN
                 EXCEPTION
                      WHEN row_locked THEN
                          asn_debug.put_line('Orphan records are left untouched as locks could not be obtained.');
                          RETURN;
                 END;
                 -- Bug 13587955 New END
	      ELSE
		 asn_debug.put_line('Processing single group when p_org_id is passed...');
		 explode_lpn;

		 UPDATE rcv_headers_interface
		 SET    org_id = p_org_id
		 WHERE  processing_status_code = 'PENDING'
		 AND    group_id = g_group_id
		 AND    org_id IS NULL
		 AND    operating_unit = g_ou_name;

		 UPDATE rcv_transactions_interface
		 SET    org_id = p_org_id
		 WHERE  processing_status_code = 'PENDING'
		 AND    group_id = g_group_id
		 AND    validation_flag = 'Y'
		 AND    org_id IS NULL
		 AND    operating_unit = g_ou_name;

		 asn_debug.put_line('Derived org_id');

		 FOR x_rhi_row IN c_get_pending_rhi_row2 LOOP
                  -- bug 16393104 start
                  SELECT *
                    INTO x_rhi_row1
                    FROM rcv_headers_interface WHERE header_interface_id = x_rhi_row.header_interface_id
                     FOR UPDATE NOWAIT;

                  prepare_pending_rhi(x_rhi_row1);
                  -- bug 16393104 end

		 END LOOP;

		 FOR x_rti_row IN c_get_pending_rti_row2 LOOP
                  -- bug 16393104 start
                  SELECT *
                    INTO x_rti_row1
                    FROM rcv_transactions_interface WHERE interface_transaction_id = x_rti_row.interface_transaction_id
                     FOR UPDATE NOWAIT;

                  prepare_pending_rti(x_rti_row1);
                  -- bug 16393104 end

		 END LOOP;

                 BEGIN  -- Bug 13587955
		    FOR x_rti_row IN c_get_orphan_rti_row2 LOOP
                  -- bug 16393104 start
                  SELECT *
                    INTO x_rti_row1
                    FROM rcv_transactions_interface WHERE interface_transaction_id = x_rti_row.interface_transaction_id
                     FOR UPDATE NOWAIT;

                  process_orphan_rti(x_rti_row1);
                  -- bug 16393104 end

		    END LOOP;
                 -- Bug 13587955 New BEGIN
                 EXCEPTION
                       WHEN row_locked THEN
                             asn_debug.put_line('Orphan records are left untouched as locks could not be obtained.');
                             RETURN;
                 END;
                 -- Bug 13587955 New END

	      END IF;

	      IF (g_multiple_groups = TRUE) THEN
		 FOR x_rti_row IN c_get_all_pending_rti_row2 LOOP
		    process_row(x_rti_row);
		 END LOOP;
	      ELSE
		 FOR x_rti_row IN c_get_pending_rti_row2 LOOP
		    process_row(x_rti_row);
		 END LOOP;
	      END IF;

	      asn_debug.put_line('Check orphan RHI');
	      IF (g_multiple_groups = TRUE) THEN
		 FOR x_rhi_row IN c_get_all_pending_rhi_row2 LOOP
		     check_orphan_rhi(x_rhi_row);
		 END LOOP;
	      ELSE
		 FOR x_rhi_row IN c_get_pending_rhi_row2 LOOP
		     check_orphan_rhi(x_rhi_row);
		 END LOOP;
	      END IF;

      ELSE
	      IF (g_multiple_groups = TRUE) THEN
		 asn_debug.put_line('Processing multiple groups...');
		 explode_all_lpn;

		 FOR x_rhi_row IN c_get_all_pending_rhi_row LOOP
                  -- bug 16393104 start
                  SELECT *
                    INTO x_rhi_row1
                    FROM rcv_headers_interface WHERE header_interface_id = x_rhi_row.header_interface_id
                     FOR UPDATE NOWAIT;

                  prepare_pending_rhi(x_rhi_row1);
                  -- bug 16393104 end

		 END LOOP;

		 FOR x_rti_row IN c_get_all_pending_rti_row LOOP
                  -- bug 16393104 start
                  SELECT *
                    INTO x_rti_row1
                    FROM rcv_transactions_interface WHERE interface_transaction_id = x_rti_row.interface_transaction_id
                     FOR UPDATE NOWAIT;

                  prepare_pending_rti(x_rti_row1);
                  -- bug 16393104 end

		 END LOOP;

                 BEGIN  -- Bug 13587955
		    FOR x_rti_row IN c_get_all_orphan_rti_row LOOP
                  -- bug 16393104 start
                  SELECT *
                    INTO x_rti_row1
                    FROM rcv_transactions_interface WHERE interface_transaction_id = x_rti_row.interface_transaction_id
                     FOR UPDATE NOWAIT;

                  process_orphan_rti(x_rti_row1);
                  -- bug 16393104 end

		    END LOOP;
                 -- Bug 13587955 New BEGIN
                 EXCEPTION
                   WHEN row_locked THEN
                        asn_debug.put_line('Orphan records are left untouched as locks could not be obtained.');
                        RETURN;
                  END;
                 -- Bug 13587955 New END

	      ELSE
      		 asn_debug.put_line('Processing single group...');
      		 explode_lpn;

		 FOR x_rhi_row IN c_get_pending_rhi_row LOOP
                  -- bug 16393104 start
                  SELECT *
                    INTO x_rhi_row1
                    FROM rcv_headers_interface WHERE header_interface_id = x_rhi_row.header_interface_id
                     FOR UPDATE NOWAIT;

                  prepare_pending_rhi(x_rhi_row1);
                  -- bug 16393104 end

		 END LOOP;

		 FOR x_rti_row IN c_get_pending_rti_row LOOP
                  -- bug 16393104 start
                  SELECT *
                    INTO x_rti_row1
                    FROM rcv_transactions_interface WHERE interface_transaction_id = x_rti_row.interface_transaction_id
                     FOR UPDATE NOWAIT;

                  prepare_pending_rti(x_rti_row1);
                  -- bug 16393104 end

		 END LOOP;

                 BEGIN  -- Bug 13587955
		    FOR x_rti_row IN c_get_orphan_rti_row LOOP
                  -- bug 16393104 start
                  SELECT *
                    INTO x_rti_row1
                    FROM rcv_transactions_interface WHERE interface_transaction_id = x_rti_row.interface_transaction_id
                     FOR UPDATE NOWAIT;

                  process_orphan_rti(x_rti_row1);
                  -- bug 16393104 end

		    END LOOP;
                 -- Bug 13587955 New BEGIN
                 EXCEPTION
                    WHEN row_locked THEN
                        asn_debug.put_line('Orphan records are left untouched as locks could not be obtained.');
                        RETURN;
                 END;
                 -- Bug 13587955 New END

	      END IF;

	      /* we now rerun the pending filter which will work this time because org_id has been populated */
	      IF (g_multiple_groups = TRUE) THEN
		 FOR x_rti_row IN c_get_all_pending_rti_row LOOP
		    process_row(x_rti_row);
		 END LOOP;
	      ELSE
		 FOR x_rti_row IN c_get_pending_rti_row LOOP
		    process_row(x_rti_row);
		 END LOOP;
	      END IF;

	      /* rhi could be without any pending rti at this point. */
	      asn_debug.put_line('Check orphan RHI');
	      IF (g_multiple_groups = TRUE) THEN
		 FOR x_rhi_row IN c_get_all_pending_rhi_row LOOP
		    check_orphan_rhi(x_rhi_row);
		 END LOOP;
	      ELSE
		 FOR x_rhi_row IN c_get_pending_rhi_row LOOP
		    check_orphan_rhi(x_rhi_row);
		 END LOOP;
	      END IF;

      END IF;
      -- Bug 14370850 : End

      /* lcm changes */
      asn_debug.put_line('Calling RCV_LCM_WEB_SERVICE.Get_Landed_Cost');
      -- Bug 16511283 begin
      --RCV_LCM_WEB_SERVICE.Get_Landed_Cost (g_group_id, p_processing_mode); -- Bug 16745648
      IF g_multiple_groups = TRUE THEN
         asn_debug.put_line('Calling RCV_LCM_WEB_SERVICE.Get_Landed_Cost for multiple groups.' );
         RCV_LCM_WEB_SERVICE.Get_Landed_Cost (NULL, p_processing_mode);
      ELSE
         asn_debug.put_line('Calling RCV_LCM_WEB_SERVICE.Get_Landed_Cost false for group id '|| p_group_id);
         RCV_LCM_WEB_SERVICE.Get_Landed_Cost (p_group_id, p_processing_mode);
      END IF;
      -- Bug 16511283 end

-- Bug 13587955 New BEGIN
EXCEPTION
  WHEN row_locked THEN
     asn_debug.put_line('ROI records to be processed are locked by another session. Failing current run.');
     raise_application_error(-20101, 'Records are found locked by another session.');
-- Bug 13587955 New END

   END process_pending_rows;
END rcv_normalize_data_pkg;

/
