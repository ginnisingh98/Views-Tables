--------------------------------------------------------
--  DDL for Package Body RCV_SHIPMENT_HEADER_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_SHIPMENT_HEADER_SV" AS
/* $Header: RCVSHCB.pls 120.0.12010000.2 2010/01/25 23:29:26 vthevark ship $ */

-- Read the profile option that enables/disables the debug log
   g_asn_debug VARCHAR2(1) := asn_debug.is_debug_on; -- Bug 9152790

   PROCEDURE create_shipment_header(
      x_header_record IN OUT NOCOPY rcv_shipment_header_sv.headerrectype
   ) IS
   BEGIN
      rcv_headers_interface_sv.derive_shipment_header(x_header_record);

      IF x_header_record.error_record.error_status IN('S', 'W') THEN
         rcv_headers_interface_sv.default_shipment_header(x_header_record);
      END IF;

      IF x_header_record.error_record.error_status IN('S', 'W') THEN
         rcv_headers_interface_sv.validate_shipment_header(x_header_record);
      END IF;

      IF x_header_record.error_record.error_status IN('S', 'W') THEN
         IF NVL(x_header_record.header_record.test_flag, 'N') <> 'Y' THEN
            rcv_headers_interface_sv.insert_shipment_header(x_header_record);
         END IF;
      END IF;
    /* Check for test flag and make sure the records are not inserted for
       the test flag = 'Y' case */
    /* If no fatal errors were detected at the header_level and at least
       one line did not have fatal errors and TEST_FLAG = 'P', populate
       the RCV_SHIPMENT_HEADERS with the header info. */
   /* If type != ASBN set processing_status_code =
         "Not processable for invoice creation" */

   /* If type = ASBN and any lines fail validation then
        set processing_status_code =
          "Not processable for invoice creation" */
   EXCEPTION
      WHEN OTHERS THEN
         rcv_error_pkg.set_sql_error_message('create_shipment_header', '000');
         x_header_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
         x_header_record.error_record.error_message  := rcv_error_pkg.get_last_message;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Fatal Error');
         END IF;
   END create_shipment_header;

/* --------------------------------------------
      Cancel Shipment Procedure

   --------------------------------------------*/
   PROCEDURE cancel_shipment(
      x_header_record IN OUT NOCOPY rcv_shipment_header_sv.headerrectype
   ) IS
   BEGIN
      rcv_headers_interface_sv.derive_shipment_header(x_header_record);

      IF x_header_record.error_record.error_status IN('S', 'W') THEN
         rcv_headers_interface_sv.default_shipment_header(x_header_record);
      END IF;

      IF x_header_record.error_record.error_status IN('S', 'W') THEN
         rcv_headers_interface_sv.validate_shipment_header(x_header_record);
      END IF;

      IF x_header_record.error_record.error_status IN('S', 'W') THEN
         IF NVL(x_header_record.header_record.test_flag, 'N') <> 'Y' THEN
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Start the process of cancellation');
            END IF;

            rcv_asn_trx_insert.insert_cancelled_asn_lines(x_header_record);
         END IF;
      END IF;
   /* Check for test flag and make sure the actions are not carried for
      the test flag = 'Y' case */
   EXCEPTION
      WHEN OTHERS THEN
         rcv_error_pkg.set_sql_error_message('create_shipment_header', '000');
         x_header_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
         x_header_record.error_record.error_message  := rcv_error_pkg.get_last_message;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Fatal Error');
         END IF;
   END cancel_shipment;
END rcv_shipment_header_sv;

/
