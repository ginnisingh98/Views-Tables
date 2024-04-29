--------------------------------------------------------
--  DDL for Package Body RCV_SHIPMENT_OBJECT_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_SHIPMENT_OBJECT_SV" AS
/* $Header: RCVCHTIB.pls 120.1.12010000.2 2010/01/25 21:15:08 vthevark ship $ */

-- Read the profile option that enables/disables the debug log
   g_asn_debug VARCHAR2(1) := asn_debug.is_debug_on; -- Bug 9152790

/*===========================================================================

  PROCEDURE NAME: create_object()

===========================================================================*/
/* ksareddy - parallel processing support for RVCTP */
   PROCEDURE create_object(
      x_request_id NUMBER,
      x_group_id   NUMBER
   ) IS
      x_progress               VARCHAR2(3)                                    := NULL;
      x_all_lines_fatal        BOOLEAN                                        := TRUE;
      x_error_record           rcv_shipment_object_sv.errorrectype;
      x_header_record          rcv_shipment_header_sv.headerrectype;
      x_transaction_record     rcv_shipment_line_sv.transaction_record_type;
      x_cascaded_table         rcv_shipment_object_sv.cascaded_trans_tab_type;
      document_num_record      rcv_shipment_line_sv.document_num_record_type;
      x_first_doc_num          rcv_transactions_interface.document_num%TYPE;
      x_first_record           BOOLEAN                                        := TRUE;
      x_any_line_error_flag    BOOLEAN                                        := FALSE;
      n                        BINARY_INTEGER                                 := 0;
      x_current_line_status    VARCHAR2(1)                                    := 'S';
      x_fail_if_one_line_fails VARCHAR2(1)                                    := 'N';
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Enter shipment object create');
      END IF;

      x_progress  := '000';

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Enter garbage processor');
      END IF;

      -- Need to do garbage collection before anything else
      -- as we may have some ASNs that are entirely invalid
      -- as they have either invalid POs or missing PO numbers

      -- Also need to update all transaction_interface rows for
      -- a header_interface row that is marked as running.
      -- The call to garbage collector is for Bug 2367174.

      x_progress  := '001';

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Calling the Garbage collector');
      END IF;

      -- bug2626270 - pass x_group_id into collect_garbage procedure also
      rcv_garbage_collector_sv.collect_garbage(x_request_id, x_group_id);

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Enter shipment object create');
      END IF;

      fnd_profile.get('RCV_FAIL_IF_LINE_FAILS', x_fail_if_one_line_fails);

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('RCV_FAIL_IF_LINE_FAILS profile option =' || x_fail_if_one_line_fails);
      END IF;

      --ksareddy 2506961 - performance bug - cache the install status of EC
      --X_edi_install :=  po_core_s.get_product_install_status('EC'); --2187209
      IF (g_is_edi_installed IS NULL) THEN
         g_is_edi_installed  := po_core_s.get_product_install_status('EC');
      END IF;

      --ksareddy - 2506961 support for parallel processing - group_id based
      OPEN rcv_shipment_object_sv.c1(x_request_id, x_group_id);
      x_progress  := '010';

      LOOP
         FETCH rcv_shipment_object_sv.c1 INTO x_header_record.header_record;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line(TO_CHAR(rcv_shipment_object_sv.c1%ROWCOUNT));
         END IF;

         EXIT WHEN rcv_shipment_object_sv.c1%NOTFOUND;
         x_progress                    := '020';
         x_error_record.error_status   := 'S';
         x_error_record.error_message  := NULL;
         x_header_record.error_record  := x_error_record;

         IF x_header_record.header_record.transaction_type = 'CANCEL' THEN
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Enter Cancel Shipment ');
            END IF;

            rcv_shipment_header_sv.cancel_shipment(x_header_record);

            IF x_header_record.error_record.error_status IN('S', 'W') THEN
               UPDATE rcv_headers_interface
                  SET processing_status_code = 'SUCCESS',
                      validation_flag = 'N',
                      receipt_header_id = x_header_record.header_record.receipt_header_id
                WHERE header_interface_id = x_header_record.header_record.header_interface_id;

               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('RCV_ASN_ACCEPT_NO_ERR');
               END IF;

               -- bug 654099, should not insert into PO Interface Errors table if there is no error
               -- otherwise, 824 will pick it up and send to customers
               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('ASN cancelled without errors');
               END IF;
            ELSE
               -- the header failed
               -- error status for the header is either 'E' or 'U'

               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('RCV_ASN_NOT_ACCEPT');
                  asn_debug.put_line('The header has failed ' || TO_CHAR(x_header_record.header_record.header_interface_id));
                  asn_debug.put_line('ASN could not be cancelled');
               END IF;

               UPDATE rcv_headers_interface
                  SET processing_status_code = 'ERROR'
                WHERE header_interface_id = x_header_record.header_record.header_interface_id;

               UPDATE rcv_transactions_interface
                  SET processing_status_code = 'ERROR'
                WHERE header_interface_id = x_header_record.header_record.header_interface_id;

               x_progress                                 := '060';
               /* WDK - we've already inserted an error into po_interface_errors. isn't this redundant? */
               x_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
               rcv_error_pkg.set_error_message('RCV_ASN_NOT_ACCEPT', x_header_record.error_record.error_message);
               rcv_error_pkg.set_token('SHIPMENT', x_header_record.header_record.shipment_num);
               rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE',
                                                  'SHIPMENT_NUM',
                                                  FALSE
                                                 );
            END IF;
         ELSE
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Enter create shipment header');
            END IF;

            rcv_shipment_header_sv.create_shipment_header(x_header_record);

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line(x_header_record.error_record.error_status);
               asn_debug.put_line(x_header_record.error_record.error_message);
            END IF;

            IF (x_header_record.error_record.error_status IN('S', 'W')) THEN
               x_progress             := '030';
               x_all_lines_fatal      := TRUE;
               x_any_line_error_flag  := FALSE;

               -- x_header_record.header_interface_id is not null thru table....
               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('In lines');
                  asn_debug.put_line(TO_CHAR(x_header_record.header_record.header_interface_id));
               END IF;

               OPEN rcv_shipment_object_sv.c2(x_header_record.header_record.header_interface_id);
               n                      := 0;
               x_first_record         := TRUE;
               x_cascaded_table.DELETE;
               x_current_line_status  := 'S'; -- Bug 610233, resetting to 'S' for a new ASN

               LOOP
                  n                                  := n + 1;

                  IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line('Current counter is ' || TO_CHAR(n));
                     asn_debug.put_line('No of records in cascaded table ' || TO_CHAR(x_cascaded_table.COUNT));
                  END IF;

                  FETCH rcv_shipment_object_sv.c2 INTO x_cascaded_table(n);
                  EXIT WHEN(   rcv_shipment_object_sv.c2%NOTFOUND
                            OR x_cascaded_table(n).error_status NOT IN('S', 'W'));
                  x_progress                         := '040';
                  x_cascaded_table(n).error_status   := x_current_line_status;
                  x_cascaded_table(n).error_message  := NULL;

                  IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line('Shipment number ' || x_header_record.header_record.shipment_num);
                  END IF;

                  rcv_shipment_line_sv.create_shipment_line(x_cascaded_table,
                                                            n,
                                                            x_header_record.header_record.header_interface_id,
                                                            x_header_record.header_record.asn_type,
                                                            x_header_record
                                                           );

                  IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line('Back from create shipment line');
                     asn_debug.put_line('Current counter is ' || TO_CHAR(n));
                  END IF;

                  IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line('Error Status For Create Shipment Line=' || x_cascaded_table(n).error_status);
                  END IF;

                  /*
                  ** If one line has failed, check if the profile value that
                  ** controls whether you should fail all lines if one line
                  ** fails is set.  If so set all line to be failed.
                            */
                  IF (    x_cascaded_table(n).error_status NOT IN('S', 'W')
                      AND x_fail_if_one_line_fails = 'Y') THEN
                     FOR i IN 1 .. n LOOP
                        x_cascaded_table(i).error_status  := 'E';
                     END LOOP;

                     x_current_line_status  := 'E';
                     x_all_lines_fatal      := TRUE;
                  END IF;

                  /* <Consigned Inventory Pre-Processor FPI START> */

                  /*
                  ** If one rti line fails line-level validation, and the
                  ** failure reason is because the transaction contains either
                  ** one of the document type:
                  ** 1) ASBN for consigned PO,
                  ** 2) ASN/ASBN/STD for Consumption PO, or
                  ** 3) ASN/ASBN/STD for Consumption Release
                  ** pre-processsor will fail all the transactions
                  */
                  IF     (x_cascaded_table(n).error_status NOT IN('S', 'W'))
                     AND (   (x_cascaded_table(n).error_message = 'RCV_REJECT_ASBN_CONSIGNED_PO')
                          OR (x_cascaded_table(n).error_message = 'RCV_REJECT_CONSUMPTION_PO')
                          OR (x_cascaded_table(n).error_message = 'RCV_REJECT_CONSUMPTION_RELEASE')) THEN
                     FOR i IN 1 .. n LOOP
                        x_cascaded_table(i).error_status  := 'E';
                     END LOOP;

                     IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('Since some of the transaction lines are related to Consigned Inventory');
                        asn_debug.put_line('Set all the transaction lines error_status E');
                     END IF;

                     x_current_line_status  := 'E';
                     x_all_lines_fatal      := TRUE;
                  END IF; --IF (X_cascaded_table(n).error_status not in ('S','W')
               /* <Consigned Inventory Pre-Processor FPI END> */
               END LOOP;

               --  Loop thru the plsql table for any success/warning at line level
               --  If any line is a success then we need to insert the line level data

               FOR i IN 1 .. x_cascaded_table.COUNT LOOP
                  IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line(x_cascaded_table(i).error_status);
                  END IF;

                  IF (x_cascaded_table(i).error_status IN('S', 'W')) THEN
                     x_all_lines_fatal                    := FALSE;
                     x_cascaded_table(i).validation_flag  := 'N'; -- Success so RVCTP can take this
                  ELSE
                     x_any_line_error_flag  := TRUE; -- if any line is in error
                  END IF;
               END LOOP;

               IF (x_all_lines_fatal) THEN
                  IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line('All lines were in error for the shipment ' || x_header_record.header_record.shipment_num);
                  END IF;

                  -- Need to insert an error condition into the poi

                  IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line('RCV_ASN_NOT_ACCEPT');
                  END IF;

                  x_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
                  rcv_error_pkg.set_error_message('RCV_ASN_NOT_ACCEPT', x_header_record.error_record.error_message);
                  rcv_error_pkg.set_token('SHIPMENT', x_header_record.header_record.shipment_num);
                  rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE',
                                                     'SHIPMENT_NUM',
                                                     FALSE
                                                    );

                  -- If this is a test, then we have not inserted the header record

                  IF NVL(x_header_record.header_record.test_flag, 'N') <> 'Y' THEN
                     DELETE FROM rcv_shipment_headers
                           WHERE shipment_header_id = x_header_record.header_record.receipt_header_id;
                  END IF;

                  UPDATE rcv_headers_interface
                     SET processing_status_code = 'ERROR'
                   WHERE header_interface_id = x_header_record.header_record.header_interface_id;

                  UPDATE rcv_transactions_interface
                     SET processing_status_code = 'ERROR'
                   WHERE header_interface_id = x_header_record.header_record.header_interface_id;

                  x_progress                                 := '050';
               ELSE
                            -- if this is not a test, then
                  -- delete the first original transactions_interface row and
                  -- insert the pl/sql table into the transactions_interface

                  IF NVL(x_header_record.header_record.test_flag, 'N') <> 'Y' THEN
                     rcv_asn_trx_insert.handle_rcv_asn_transactions(x_cascaded_table, x_header_record);
                  END IF;

                  IF NOT x_any_line_error_flag THEN -- all lines were fine
                     IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('RCV_ASN_ACCEPT_NO_ERR');
                     END IF;

                     -- bug 654099, should not insert into PO Interface Errors table if
                     -- there is no error.  Otherwise, 824 will pick it up and send to customers

                     IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('ASN accepted without errors');
                     END IF;
                  ELSE
                     IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('ASN accepted with errors RCV_ASN_ACCEPT_W_ERR');
                     END IF;

                     x_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_warning;
                     rcv_error_pkg.set_error_message('RCV_ASN_ACCEPT_W_ERR', x_header_record.error_record.error_message);
                     rcv_error_pkg.set_token('SHIPMENT', x_header_record.header_record.shipment_num);
                     rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE',
                                                        'SHIPMENT_NUM',
                                                        FALSE
                                                       );
                  END IF;

                  IF     x_header_record.header_record.asn_type = 'ASBN'
                     AND x_any_line_error_flag THEN -- if any line is in error and type = ASBN
                                                    -- use this flag to reset invoice_status_code

                                                    -- update the interface table
                     IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('RCV_ASBN_NO_AUTO_INVOICE');
                     END IF;

                     x_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_warning;
                     rcv_error_pkg.set_error_message('RCV_ASBN_NO_AUTO_INVOICE', x_header_record.error_record.error_message);
                     rcv_error_pkg.set_token('SHIPMENT', x_header_record.header_record.shipment_num);
                     rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE',
                                                        'SHIPMENT_NUM',
                                                        FALSE
                                                       );

                     UPDATE rcv_headers_interface
                        SET invoice_status_code = 'RCV_ASBN_NO_AUTO_INVOICE',
                            processing_status_code = 'SUCCESS',
                            validation_flag = 'N',
                            receipt_header_id = x_header_record.header_record.receipt_header_id
                      WHERE header_interface_id = x_header_record.header_record.header_interface_id;

                     -- update the rcv_shipment_headers table

                     UPDATE rcv_shipment_headers
                        SET invoice_status_code = 'RCV_ASBN_NO_AUTO_INVOICE'
                      WHERE shipment_header_id = x_header_record.header_record.receipt_header_id;
                  ELSE
                     UPDATE rcv_headers_interface
                        SET processing_status_code = 'SUCCESS',
                            validation_flag = 'N',
                            receipt_header_id = x_header_record.header_record.receipt_header_id
                      WHERE header_interface_id = x_header_record.header_record.header_interface_id;
                  END IF;
               END IF;

               CLOSE rcv_shipment_object_sv.c2;
            ELSE
               -- the header failed
               -- error status for the header is either 'E' or 'U'

               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('RCV_ASN_NOT_ACCEPT');
               END IF;

               x_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
               rcv_error_pkg.set_error_message('RCV_ASN_NOT_ACCEPT', x_header_record.error_record.error_message);
               rcv_error_pkg.set_token('SHIPMENT', x_header_record.header_record.shipment_num);
               rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE',
                                                  'SHIPMENT_NUM',
                                                  FALSE
                                                 );

               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('The header has failed ' || TO_CHAR(x_header_record.header_record.header_interface_id));
               END IF;

               UPDATE rcv_headers_interface
                  SET processing_status_code = 'ERROR'
                WHERE header_interface_id = x_header_record.header_record.header_interface_id;

               UPDATE rcv_transactions_interface
                  SET processing_status_code = 'ERROR'
                WHERE header_interface_id = x_header_record.header_record.header_interface_id;

               x_progress                                 := '060';
            END IF;
         END IF; -- CANCEL/CREATE

         /* Bug#2187209
          * Before calling the 824 Interface, we need to check whether EDI is
          * installed or not. If EDI is not installed we need not call 824
          * Interface and it in turn will not call any  EC packages which
          * will insert records into ECE_ADVO_HEADERS and ECE_ADVO_DETAILS.
          */

         /* ksareddy call this for ASN or ASBNS */
         IF (x_header_record.header_record.asn_type IN('ASN', 'ASBN')) THEN
            IF g_is_edi_installed = 'I' THEN
               rcv_824_sv.rcv_824_insert(x_header_record, 'ASN');   /* NWANG: changed to two parameters for RCV824 */
            END IF;
         END IF;
      END LOOP;

      CLOSE rcv_shipment_object_sv.c1;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Exit shipment object create');
      END IF;
   END create_object;
END rcv_shipment_object_sv;

/
