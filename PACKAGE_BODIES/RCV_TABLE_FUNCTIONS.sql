--------------------------------------------------------
--  DDL for Package Body RCV_TABLE_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_TABLE_FUNCTIONS" AS
/* $Header: RCVTBFNB.pls 120.4.12010000.10 2013/12/17 04:17:32 honwei ship $*/
   g_debug_flag CONSTANT VARCHAR2(1)                           := asn_debug.is_debug_on; -- Bug 9152790
   g_rhi_row             rcv_headers_interface%ROWTYPE;
   g_rti_row             rcv_transactions_interface%ROWTYPE;
   g_rt_row              rcv_transactions%ROWTYPE;
   g_rsh_row             rcv_shipment_headers%ROWTYPE;
   g_rsl_row             rcv_shipment_lines%ROWTYPE;
   g_poh_row             po_headers_all%ROWTYPE;
   g_pol_row             po_lines_all%ROWTYPE;
   g_pll_row             po_line_locations_all%ROWTYPE;
   g_pod_row             po_distributions_all%ROWTYPE;
   g_oeh_row             oe_order_headers_all%ROWTYPE;
   g_oel_row             oe_order_lines_all%ROWTYPE;
   g_prl_row             po_requisition_lines_all%ROWTYPE;
   g_prd_row             po_req_distributions_all%ROWTYPE;
   g_msi_row             mtl_system_items%ROWTYPE;
   g_mic_row             mtl_item_categories%ROWTYPE;
   g_mp_row              mtl_parameters%ROWTYPE;
   g_rp_row              rcv_parameters%ROWTYPE;
   g_fc_row              fnd_currencies%ROWTYPE;
   g_sob_row             gl_sets_of_books%ROWTYPE;
   g_fsp_row             financials_system_parameters%ROWTYPE;
   g_fspa_row            financials_system_params_all%ROWTYPE;
   g_pvs_row             po_vendor_sites_all%ROWTYPE;
   g_muom_row            mtl_units_of_measure%ROWTYPE;

   g_po_lookups          lookup_table_type;

/* Bug 5246147: Removed the following function definitions,
                get_fspa_row_from_org() and
                get_sob_row_from_id() */

   PROCEDURE invalid_value(
      p_value  IN VARCHAR2,
      p_column IN VARCHAR2
   ) IS
   BEGIN
      rcv_error_pkg.set_error_message('RCV_INVALID_ROI_VALUE_NE');
      rcv_error_pkg.set_token('COLUMN', p_column);
      rcv_error_pkg.set_token('ROI_VALUE', p_value);
      g_error_column  := p_column;
      asn_debug.put_line('Invalid value ' || p_value || ' for ' || p_column || ' in RCV_TABLE_FUNCTIONS');
      RAISE e_fatal_error;
   END invalid_value;

   /* NOTE:  All functions except IS_ORG_ID_IN_OU are operating unit (OU) agnostic */
   /* It is the caller's responsibility to check if the OU is correct and the org_id is in the OU */

   /*******/
   /* RHI */
   /*******/
   FUNCTION get_rhi_row_from_id(
      p_header_interface_id IN rcv_headers_interface.header_interface_id%TYPE
   )
      RETURN rcv_headers_interface%ROWTYPE IS
   BEGIN
      IF (p_header_interface_id IS NULL) THEN
         RETURN NULL;
      END IF;

      IF (p_header_interface_id = g_rhi_row.header_interface_id) THEN
         RETURN g_rhi_row;
      END IF;

      SELECT *
      INTO   g_rhi_row
      FROM   rcv_headers_interface
      WHERE  header_interface_id = p_header_interface_id;

      RETURN g_rhi_row;
   EXCEPTION
      WHEN OTHERS THEN
         invalid_value(p_header_interface_id, 'HEADER_INTERFACE_ID');
   END get_rhi_row_from_id;

   PROCEDURE update_rhi_row(
      p_rhi_row IN rcv_headers_interface%ROWTYPE
   ) IS
   BEGIN
      asn_debug.put_line('Updating RHI HEADER_INTERFACE_ID=' || p_rhi_row.header_interface_id);

      UPDATE rcv_headers_interface
         SET ROW = p_rhi_row
       WHERE header_interface_id = p_rhi_row.header_interface_id;

      g_rhi_row  := p_rhi_row;
   END;

   /*******/
   /* RTI */
   /*******/
   FUNCTION get_rti_row_from_id(
      p_interface_transaction_id IN rcv_transactions_interface.interface_transaction_id%TYPE
   )
      RETURN rcv_transactions_interface%ROWTYPE IS
   BEGIN
      IF (p_interface_transaction_id IS NULL) THEN
         RETURN NULL;
      END IF;

      IF (p_interface_transaction_id = g_rti_row.interface_transaction_id) THEN
         RETURN g_rti_row;
      END IF;

      SELECT *
      INTO   g_rti_row
      FROM   rcv_transactions_interface
      WHERE  interface_transaction_id = p_interface_transaction_id;

      RETURN g_rti_row;
   EXCEPTION
      WHEN OTHERS THEN
         invalid_value(p_interface_transaction_id, 'INTERFACE_TRANSACTION_ID');
   END;

   PROCEDURE update_rti_row(
      p_rti_row IN rcv_transactions_interface%ROWTYPE
   ) IS
   BEGIN
      asn_debug.put_line('Updating RTI INTERFACE_TRANSACTION_ID=' || p_rti_row.interface_transaction_id);

      UPDATE rcv_transactions_interface
         SET ROW = p_rti_row
       WHERE interface_transaction_id = p_rti_row.interface_transaction_id
             AND processing_status_code <> 'ERROR'; --BUG: 5598140

      g_rti_row  := p_rti_row;
   END;

   /*******/
   /* RT  */
   /*******/
   FUNCTION get_rt_row_from_id(
      p_transaction_id IN rcv_transactions.transaction_id%TYPE
   )
      RETURN rcv_transactions%ROWTYPE IS
   BEGIN
      IF (p_transaction_id IS NULL) THEN
         RETURN NULL;
      END IF;

      IF (p_transaction_id = g_rt_row.transaction_id) THEN
         RETURN g_rt_row;
      END IF;

      SELECT *
      INTO   g_rt_row
      FROM   rcv_transactions
      WHERE  transaction_id = p_transaction_id;

      RETURN g_rt_row;
   EXCEPTION
      WHEN OTHERS THEN
         invalid_value(p_transaction_id, 'TRANSACTION_ID');
   END;

   /*******/
   /* RSH */
   /*******/
   FUNCTION get_rsh_row_from_num(
      p_shipment_num         IN rcv_shipment_headers.shipment_num%TYPE,
      p_vendor_id            IN rcv_shipment_headers.vendor_id%TYPE,
      p_vendor_site_id       IN rcv_shipment_headers.vendor_site_id%TYPE,
      p_ship_to_org_id       IN rcv_shipment_headers.ship_to_org_id%TYPE,
      p_shipped_date         IN rcv_shipment_headers.shipped_date%TYPE,
      p_receipt_source_code  IN rcv_shipment_headers.receipt_source_code%TYPE,
      no_data_found_is_error IN BOOLEAN
   )
      RETURN rcv_shipment_headers%ROWTYPE IS
   BEGIN
      IF (p_shipment_num IS NULL) THEN
         RETURN NULL;
      END IF;

      IF     (p_shipment_num = g_rsh_row.shipment_num)
         AND (   NVL(p_ship_to_org_id, g_rsh_row.ship_to_org_id) = g_rsh_row.ship_to_org_id
              OR g_rsh_row.ship_to_org_id IS NULL)
         AND (   NVL(p_vendor_id, g_rsh_row.vendor_id) = g_rsh_row.vendor_id
              OR g_rsh_row.vendor_id IS NULL)
         AND (   NVL(p_vendor_site_id, g_rsh_row.vendor_site_id) = g_rsh_row.vendor_site_id
              OR g_rsh_row.vendor_site_id IS NULL)
         AND (   TRUNC(NVL(p_shipped_date, g_rsh_row.shipped_date)) = TRUNC(g_rsh_row.shipped_date)
              OR g_rsh_row.shipped_date IS NULL)
         AND (   p_receipt_source_code = g_rsh_row.receipt_source_code)  THEN
         RETURN g_rsh_row;
      END IF;

      SELECT *
      INTO   g_rsh_row
      FROM   rcv_shipment_headers
      WHERE  shipment_num = p_shipment_num
      AND    (   vendor_site_id = NVL(p_vendor_site_id, vendor_site_id)
              OR vendor_site_id IS NULL)
      AND    (   vendor_id = NVL(p_vendor_id, vendor_id)
              OR vendor_id IS NULL)
      AND    ship_to_org_id = NVL(p_ship_to_org_id, ship_to_org_id)
      AND    shipped_date >= ADD_MONTHS(NVL(p_shipped_date, SYSDATE), -12)
      AND    receipt_source_code=p_receipt_source_code;

      RETURN g_rsh_row;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         IF (no_data_found_is_error = TRUE) THEN
            invalid_value(p_shipment_num, 'SHIPMENT_NUM');
         ELSE
            RETURN NULL;
         END IF;
      WHEN TOO_MANY_ROWS THEN
         IF (g_debug_flag = 'Y') THEN
            asn_debug.put_line('too many rows in get_rsh_row_from_num(' || p_shipment_num || ',' || p_vendor_id || ');');
         END IF;

         RETURN NULL;
   END get_rsh_row_from_num;

   --Add to Receipt 17962808  begin
   FUNCTION get_rsh_row_from_receipt_num(
      p_receipt_num          IN rcv_shipment_headers.receipt_num%TYPE,
      p_ship_to_org_id       IN rcv_shipment_headers.ship_to_org_id%TYPE,
      no_data_found_is_error IN BOOLEAN
   )
      RETURN rcv_shipment_headers%ROWTYPE IS
   BEGIN
      IF (p_receipt_num IS NULL) THEN
         RETURN NULL;
      END IF;

      IF (   p_receipt_num = g_rsh_row.receipt_num)
         AND (   NVL(p_ship_to_org_id, g_rsh_row.ship_to_org_id) = g_rsh_row.ship_to_org_id
              OR g_rsh_row.ship_to_org_id IS NULL) THEN
         RETURN g_rsh_row;
      END IF;

      SELECT *
      INTO   g_rsh_row
      FROM   rcv_shipment_headers
      WHERE  receipt_num = p_receipt_num
      AND    ship_to_org_id = NVL(p_ship_to_org_id, ship_to_org_id);

      RETURN g_rsh_row;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         IF (no_data_found_is_error = TRUE) THEN
            invalid_value(p_receipt_num, 'RECEIPT_NUM');
         ELSE
            RETURN NULL;
         END IF;
      WHEN TOO_MANY_ROWS THEN
         IF (g_debug_flag = 'Y') THEN
            asn_debug.put_line('too many rows in get_rsh_row_from_receipt_num(' || p_receipt_num || ',' || p_ship_to_org_id || ');');
         END IF;

         RETURN NULL;
   END get_rsh_row_from_receipt_num;
   --Add to Receipt 17962808 end

   FUNCTION get_rsh_row_from_id(
      p_shipment_header_id IN rcv_shipment_headers.shipment_header_id%TYPE
   )
      RETURN rcv_shipment_headers%ROWTYPE IS
   BEGIN
      IF (p_shipment_header_id IS NULL) THEN
         RETURN NULL;
      END IF;

      IF (p_shipment_header_id = g_rsh_row.shipment_header_id) THEN
         RETURN g_rsh_row;
      END IF;

      SELECT *
      INTO   g_rsh_row
      FROM   rcv_shipment_headers
      WHERE  shipment_header_id = p_shipment_header_id;

      RETURN g_rsh_row;
   EXCEPTION
      WHEN OTHERS THEN
         invalid_value(p_shipment_header_id, 'SHIPMENT_HEADER_ID');
   END get_rsh_row_from_id;

   /*******/
   /* RSL */
   /*******/
   FUNCTION get_rsl_row_from_num(
      p_line_num           rcv_shipment_lines.line_num%TYPE,
      p_shipment_header_id rcv_shipment_lines.shipment_header_id%TYPE
   )
      RETURN rcv_shipment_lines%ROWTYPE IS
   BEGIN
      IF (   p_line_num IS NULL
          OR p_shipment_header_id IS NULL) THEN
         RETURN NULL;
      END IF;

      IF (    p_line_num = g_rsl_row.line_num
          AND p_shipment_header_id = g_rsl_row.shipment_header_id) THEN
         RETURN g_rsl_row;
      END IF;

      SELECT *
      INTO   g_rsl_row
      FROM   rcv_shipment_lines
      WHERE  line_num = p_line_num
      AND    shipment_header_id = p_shipment_header_id;

      RETURN g_rsl_row;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         invalid_value(p_line_num, 'LINE_NUM');
      WHEN TOO_MANY_ROWS THEN
         IF (g_debug_flag = 'Y') THEN
            asn_debug.put_line('too many rows in get_rsl_row_from_num(' || p_line_num || ',' || p_shipment_header_id || ');');
         END IF;

         RETURN NULL;
   END get_rsl_row_from_num;

   FUNCTION get_rsl_row_from_id(
      p_shipment_line_id IN rcv_shipment_lines.shipment_line_id%TYPE
   )
      RETURN rcv_shipment_lines%ROWTYPE IS
   BEGIN
      IF (p_shipment_line_id IS NULL) THEN
         RETURN NULL;
      END IF;

      IF (p_shipment_line_id = g_rsl_row.shipment_line_id) THEN
         RETURN g_rsl_row;
      END IF;

      SELECT *
      INTO   g_rsl_row
      FROM   rcv_shipment_lines
      WHERE  shipment_line_id = p_shipment_line_id;

      RETURN g_rsl_row;
   EXCEPTION
      WHEN OTHERS THEN
         invalid_value(p_shipment_line_id, 'SHIPMENT_LINE_ID');
   END get_rsl_row_from_id;

   PROCEDURE update_rsl_row(
      p_rsl_row IN rcv_shipment_lines%ROWTYPE
   ) IS
   BEGIN
      asn_debug.put_line('Updating RSL SHIPMENT_LINE_ID=' || p_rsl_row.shipment_line_id);

      UPDATE rcv_shipment_lines
       	 SET ROW = p_rsl_row
      WHERE shipment_line_id = p_rsl_row.shipment_line_id;

      g_rsl_row  := p_rsl_row;
   END;

   /*******/
   /* poh */
   /*******/
   FUNCTION get_poh_row_from_num(
      p_po_num po_headers_all.segment1%TYPE,
      p_org_id po_headers_all.org_id%TYPE
   )
      RETURN po_headers_all%ROWTYPE IS
   BEGIN
      IF (p_po_num IS NULL) THEN
         RETURN NULL;
      END IF;

      IF (p_po_num = g_poh_row.segment1) THEN
         RETURN g_poh_row;
      END IF;

      --first check if there is a singular match in the current OU
      SELECT *
      INTO   g_poh_row
      FROM   po_headers_all
      WHERE  po_header_id IN(SELECT po_header_id
                             FROM   po_headers
                             WHERE  segment1 = p_po_num
                             -- Bug 13720644 Begin: type_lookup_code for Planned Purchase Order is 'PLANNED'
                             --AND    type_lookup_code IN('STANDARD', 'BLANKET', 'SCHEDULED')
                             AND    type_lookup_code IN('STANDARD', 'BLANKET', 'PLANNED')
                             --Bug 13720644 End
                             AND    org_id = NVL(p_org_id, org_id));

      RETURN g_poh_row;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN --check if this exists in a different OU
         BEGIN
            SELECT *
            INTO   g_poh_row
            FROM   po_headers_all
            WHERE  segment1 = p_po_num
            -- Bug 13720644: type_lookup_code for Planned Purchase Order is 'PLANNED'
            --AND    type_lookup_code IN('STANDARD', 'BLANKET', 'SCHEDULED')
            AND    type_lookup_code IN('STANDARD', 'BLANKET', 'PLANNED')
            --Bug 13720644 End
            AND    org_id = NVL(p_org_id, org_id);

            RETURN g_poh_row;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               invalid_value(p_po_num, 'PO_HEADER_NUM');
            WHEN TOO_MANY_ROWS THEN
               IF (g_debug_flag = 'Y') THEN
                  asn_debug.put_line('too many rows in get_poh_row_from_num(' || p_po_num || ',' || p_org_id || ');');
               END IF;

               RETURN NULL;
         END;
      WHEN TOO_MANY_ROWS THEN
         IF (g_default_org_id IS NOT NULL) THEN
            BEGIN
               SELECT *
               INTO   g_poh_row
               FROM   po_headers_all
               WHERE  segment1 = p_po_num
               -- Bug 13720644: type_lookup_code for Planned Purchase Order is 'PLANNED'
               --AND    type_lookup_code IN('STANDARD', 'BLANKET', 'SCHEDULED')
               AND    type_lookup_code IN('STANDARD', 'BLANKET', 'PLANNED')
               --Bug 13720644 End
               AND    org_id = g_default_org_id;

               RETURN g_poh_row;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;
         END IF;

         IF (g_debug_flag = 'Y') THEN
            asn_debug.put_line('too many rows in get_poh_row_from_num(' || p_po_num || ',' || p_org_id || ');');
         END IF;

         RETURN NULL;
   END get_poh_row_from_num;

   FUNCTION get_poh_row_from_id(
      p_header_id IN po_headers_all.po_header_id%TYPE
   )
      RETURN po_headers_all%ROWTYPE IS
   BEGIN
      IF (p_header_id IS NULL) THEN
         RETURN NULL;
      END IF;

      IF (p_header_id = g_poh_row.po_header_id) THEN
         RETURN g_poh_row;
      END IF;

      SELECT *
      INTO   g_poh_row
      FROM   po_headers_all
      WHERE  po_header_id = p_header_id;

      RETURN g_poh_row;
   EXCEPTION
      WHEN OTHERS THEN
         invalid_value(p_header_id, 'PO_HEADER_ID');
   END get_poh_row_from_id;

   /*******/
   /* pol */
   /*******/
   FUNCTION get_pol_row_from_num(
      p_line_num           po_lines_all.line_num%TYPE,
      p_header_id          po_lines_all.po_header_id%TYPE,
      p_item_description   po_lines_all.item_description%TYPE,
      p_vendor_product_num po_lines_all.vendor_product_num%TYPE,
      p_item_id            po_lines_all.item_id%TYPE
   )
      RETURN po_lines_all%ROWTYPE IS
      x_line_num           po_lines_all.line_num%TYPE;
      x_item_id            po_lines_all.item_id%TYPE;
      x_item_description   po_lines_all.item_description%TYPE;
      x_vendor_product_num po_lines_all.vendor_product_num%TYPE;
      --Bug 7645326 Added the item_id to find the po line num along with the existing
 	       -- input parameters and modified the statement accordingly.
   BEGIN
      IF (   (    p_line_num IS NULL
              AND p_item_id IS NULL
              AND p_item_description IS NULL
              AND p_vendor_product_num IS NULL)
          OR p_header_id IS NULL) THEN
         RETURN NULL;
      END IF;

      IF (    p_line_num = g_pol_row.line_num
          AND p_header_id = g_pol_row.po_header_id) THEN
         RETURN g_pol_row;
      END IF;

      IF (p_line_num IS NOT NULL) THEN
         x_line_num            := p_line_num;
         x_item_id             :=NULL;
         x_item_description    := NULL;
         x_vendor_product_num  := NULL;
      ELSIF (p_item_id IS NOT NULL ) THEN
         x_item_id             :=p_item_id;
         x_line_num            :=NULL;
         x_item_description    := NULL;
         x_vendor_product_num  := NULL;
      ELSIF(p_item_description IS NOT NULL) THEN
         x_line_num            := NULL;
         x_item_id             := NULL;
         x_item_description    := p_item_description;
         x_vendor_product_num  := NULL;
      ELSIF(p_vendor_product_num IS NOT NULL) THEN
         x_line_num            := NULL;
         x_item_id             := NULL;
         x_item_description    := NULL;
         x_vendor_product_num  := p_vendor_product_num;
      ELSE
         x_line_num            := 1;
         x_item_id             := NULL;
         x_item_description    := NULL;
         x_vendor_product_num  := NULL;
      END IF;

      --first check if there is a singular match in the current OU
      SELECT *
      INTO   g_pol_row
      FROM   po_lines_all
      WHERE  po_line_id IN(SELECT po_line_id
                           FROM   po_lines
                           WHERE  po_header_id = p_header_id
                           AND    (   line_num = x_line_num
                                   OR x_line_num IS NULL)
                           AND    (  item_id   = x_item_id
 	                                OR x_item_id IS NULL )
                           AND    (   item_description = x_item_description
                                   OR x_item_description IS NULL)
                           AND    (   vendor_product_num = x_vendor_product_num
                                   OR x_vendor_product_num IS NULL));

      RETURN g_pol_row;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN --check if this exists in a different OU
         BEGIN
            SELECT *
            INTO   g_pol_row
            FROM   po_lines_all
            WHERE  po_header_id = p_header_id
            AND    (   line_num = x_line_num
                    OR x_line_num IS NULL)
            AND    (  item_id   = x_item_id
                    OR x_item_id IS NULL )
            AND    (   item_description = x_item_description
                    OR x_item_description IS NULL)
            AND    (   vendor_product_num = x_vendor_product_num
                    OR x_vendor_product_num IS NULL);

            RETURN g_pol_row;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               invalid_value(p_line_num, 'PO_LINE_NUM');
            WHEN TOO_MANY_ROWS THEN
               IF (g_debug_flag = 'Y') THEN
                  asn_debug.put_line('too many rows in get_pol_row_from_num(' || p_line_num || ',' || p_header_id || ');');
               END IF;

               /*Bug 12618848 Do not error out the RTI if it fetches more than one PO line.
                 In preprocessor, it will be decided*/
               --RETURN NULL;
               g_pol_row.po_line_id := -99;
               RETURN g_pol_row;
               /*End of Bug 12618848 */
         END;
      WHEN TOO_MANY_ROWS THEN
         IF (g_debug_flag = 'Y') THEN
            asn_debug.put_line('too many rows in get_pol_row_from_num(' || p_line_num || ',' || p_header_id || ');');
         END IF;

         /*Bug 12618848 Do not error out the RTI if it fetches more than one PO line.
           In preprocessor, it will be decided*/
           --RETURN NULL;
           g_pol_row.po_line_id := -99;
           RETURN g_pol_row;
         /*End of Bug 12618848 */

   END get_pol_row_from_num;

   FUNCTION get_pol_row_from_id(
      p_line_id IN po_lines_all.po_line_id%TYPE
   )
      RETURN po_lines_all%ROWTYPE IS
   BEGIN
      IF (p_line_id IS NULL) THEN
         RETURN NULL;
      END IF;

      IF (p_line_id = g_pol_row.po_line_id) THEN
         RETURN g_pol_row;
      END IF;

      SELECT *
      INTO   g_pol_row
      FROM   po_lines_all
      WHERE  po_line_id = p_line_id;

      RETURN g_pol_row;
   EXCEPTION
      WHEN OTHERS THEN
         invalid_value(p_line_id, 'PO_LINE_ID');
   END get_pol_row_from_id;

   /*******/
   /* pll */
   /*******/
   FUNCTION get_pll_row_from_num(
      p_shipment_num po_line_locations_all.shipment_num%TYPE,
      p_line_id      po_line_locations_all.po_line_id%TYPE
   )
      RETURN po_line_locations_all%ROWTYPE IS
   BEGIN
      IF (   p_shipment_num IS NULL
          OR p_line_id IS NULL) THEN
         RETURN NULL;
      END IF;

      IF (    p_shipment_num = g_pll_row.shipment_num
          AND p_line_id = g_pll_row.po_line_id) THEN
         RETURN g_pll_row;
      END IF;

      --first check if there is a singular match in the current OU
      SELECT *
      INTO   g_pll_row
      FROM   po_line_locations_all
      WHERE  line_location_id IN(SELECT line_location_id
                                 FROM   po_line_locations
                                 WHERE  shipment_num = p_shipment_num
                                 AND    po_line_id = p_line_id);

      RETURN g_pll_row;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN --check if this exists in a different OU
         BEGIN
            SELECT *
            INTO   g_pll_row
            FROM   po_line_locations_all
            WHERE  shipment_num = p_shipment_num
            AND    po_line_id = p_line_id;

            RETURN g_pll_row;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               invalid_value(p_shipment_num, 'PO_LINE_LOCATION_NUM');
            WHEN TOO_MANY_ROWS THEN
               IF (g_debug_flag = 'Y') THEN
                  asn_debug.put_line('too many rows in get_pll_row_from_num(' || p_shipment_num || ',' || p_line_id || ');');
               END IF;

               g_pll_row := NULL;   -- bug#12568219 null out g_pll_row otherwise it will be populated with value even for TOO_MANY_ROWS exception.

               RETURN NULL;
         END;
      WHEN TOO_MANY_ROWS THEN
         IF (g_debug_flag = 'Y') THEN
            asn_debug.put_line('too many rows in get_pll_row_from_num(' || p_shipment_num || ',' || p_line_id || ');');
         END IF;

         g_pll_row := NULL;   -- bug#12568219 null out g_pll_row otherwise it will be populated with value even for TOO_MANY_ROWS exception.

         RETURN NULL;
   END get_pll_row_from_num;

   FUNCTION get_pll_row_from_id(
      p_line_location_id IN po_line_locations_all.line_location_id%TYPE
   )
      RETURN po_line_locations_all%ROWTYPE IS
   BEGIN
      IF (p_line_location_id IS NULL) THEN
         RETURN NULL;
      END IF;

      IF (p_line_location_id = g_pll_row.line_location_id) THEN
         RETURN g_pll_row;
      END IF;

      SELECT *
      INTO   g_pll_row
      FROM   po_line_locations_all
      WHERE  line_location_id = p_line_location_id;

      RETURN g_pll_row;
   EXCEPTION
      WHEN OTHERS THEN
         invalid_value(p_line_location_id, 'PO_LINE_LOCATION_ID');
   END get_pll_row_from_id;

   /*******/
   /* POD */
   /*******/
   FUNCTION get_pod_row_from_num(
      p_distribution_num po_distributions_all.distribution_num%TYPE,
      p_line_location_id po_distributions_all.line_location_id%TYPE
   )
      RETURN po_distributions_all%ROWTYPE IS
   BEGIN
      IF (   p_distribution_num IS NULL
          OR p_line_location_id IS NULL) THEN
         RETURN NULL;
      END IF;

      IF (    p_distribution_num = g_pod_row.distribution_num
          AND p_line_location_id = g_pod_row.line_location_id) THEN
         RETURN g_pod_row;
      END IF;

      --first check if there is a singular match in the current OU
      SELECT *
      INTO   g_pod_row
      FROM   po_distributions_all
      WHERE  po_distribution_id IN(SELECT po_distribution_id
                                   FROM   po_distributions
                                   WHERE  distribution_num = p_distribution_num
                                   AND    line_location_id = p_line_location_id);

      RETURN g_pod_row;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN --check if this exists in a different OU
         BEGIN
            SELECT *
            INTO   g_pod_row
            FROM   po_distributions_all
            WHERE  distribution_num = p_distribution_num
            AND    line_location_id = p_line_location_id;

            RETURN g_pod_row;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               invalid_value(p_distribution_num, 'PO_DISTRIBUTION_NUM');
            WHEN TOO_MANY_ROWS THEN
               IF (g_debug_flag = 'Y') THEN
                  asn_debug.put_line('too many rows in get_pod_row_from_num(' || p_distribution_num || ',' || p_line_location_id || ');');
               END IF;

               RETURN NULL;
         END;
      WHEN TOO_MANY_ROWS THEN
         IF (g_debug_flag = 'Y') THEN
            asn_debug.put_line('too many rows in get_pod_row_from_num(' || p_distribution_num || ',' || p_line_location_id || ');');
         END IF;

         RETURN NULL;
   END get_pod_row_from_num;

   FUNCTION get_pod_row_from_id(
      p_distribution_id IN po_distributions_all.po_distribution_id%TYPE
   )
      RETURN po_distributions_all%ROWTYPE IS
   BEGIN
      IF (p_distribution_id IS NULL) THEN
         RETURN NULL;
      END IF;

      IF (p_distribution_id = g_pod_row.po_distribution_id) THEN
         RETURN g_pod_row;
      END IF;

      SELECT *
      INTO   g_pod_row
      FROM   po_distributions_all
      WHERE  po_distribution_id = p_distribution_id;

      RETURN g_pod_row;
   EXCEPTION
      WHEN OTHERS THEN
         invalid_value(p_distribution_id, 'PO_DISTRIBUTION_ID');
   END get_pod_row_from_id;

   /*******/
   /* oeh */
   /*******/
   FUNCTION get_oeh_row_from_num(
      p_order_number   oe_order_headers_all.order_number%TYPE,
      p_order_type_id  oe_order_headers_all.order_type_id%TYPE,
      p_version_number oe_order_headers_all.version_number%TYPE,
      p_org_id         oe_order_headers_all.org_id%TYPE
   )
      RETURN oe_order_headers_all%ROWTYPE IS
   BEGIN
      IF (p_order_number IS NULL) THEN
         RETURN NULL;
      END IF;

      IF (    p_order_number = g_oeh_row.order_number
          AND (   p_order_type_id IS NULL
               OR p_order_type_id = g_oeh_row.order_type_id)
          AND (   p_version_number IS NULL
               OR p_version_number = g_oeh_row.version_number)) THEN
         RETURN g_oeh_row;
      END IF;

      --first check if there is a singular match in the current OU
      /* WDK: NOTE - THIS QUERY IS NOT UNIQUE!!!  REQUIRES ORDER_TYPE_ID and VERSION_NUMBER.
         WE CAN FIX ONLY IF WE ADD THESE COLUMNS */
      SELECT   *
      INTO     g_oeh_row
      FROM     oe_order_headers_all
      WHERE    header_id IN(SELECT header_id
                            FROM   oe_order_headers
                            WHERE  order_number = p_order_number
                            AND    order_type_id = NVL(p_order_type_id, order_type_id)
                            AND    version_number = NVL(p_version_number, version_number)
                            AND    org_id = NVL(p_org_id, org_id))
      AND      ROWNUM = 1
      ORDER BY version_number DESC;

      RETURN g_oeh_row;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN --check if this exists in a different OU
         BEGIN
            SELECT   *
            INTO     g_oeh_row
            FROM     oe_order_headers_all
            WHERE    order_number = p_order_number
            AND      order_type_id = NVL(p_order_type_id, order_type_id)
            AND      version_number = NVL(p_version_number, version_number)
            AND      org_id = NVL(p_org_id, org_id)
            AND      ROWNUM = 1
            ORDER BY version_number DESC;

            RETURN g_oeh_row;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               invalid_value(p_order_number, 'OE_ORDER_HEADER_NUM');
            WHEN TOO_MANY_ROWS THEN
               IF (g_debug_flag = 'Y') THEN
                  asn_debug.put_line('too many rows in get_oeh_row_from_num(' || p_order_number || ',' || p_order_type_id || ');');
               END IF;

               RETURN NULL;
         END;
      WHEN TOO_MANY_ROWS THEN
         IF (g_default_org_id IS NOT NULL) THEN
            BEGIN
               SELECT   *
               INTO     g_oeh_row
               FROM     oe_order_headers_all
               WHERE    order_number = p_order_number
               AND      order_type_id = NVL(p_order_type_id, order_type_id)
               AND      version_number = NVL(p_version_number, version_number)
               AND      org_id = g_default_org_id
               AND      ROWNUM = 1
               ORDER BY version_number DESC;

               RETURN g_oeh_row;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;
         END IF;

         IF (g_debug_flag = 'Y') THEN
            asn_debug.put_line('too many rows in get_oeh_row_from_num(' || p_order_number || ',' || p_order_type_id || ');');
         END IF;

         RETURN NULL;
   END get_oeh_row_from_num;

   FUNCTION get_oeh_row_from_id(
      p_header_id IN oe_order_headers_all.header_id%TYPE
   )
      RETURN oe_order_headers_all%ROWTYPE IS
   BEGIN
      IF (p_header_id IS NULL) THEN
         RETURN NULL;
      END IF;

      IF (p_header_id = g_oeh_row.header_id) THEN
         RETURN g_oeh_row;
      END IF;

      SELECT *
      INTO   g_oeh_row
      FROM   oe_order_headers_all
      WHERE  header_id = p_header_id;

      RETURN g_oeh_row;
   EXCEPTION
      WHEN OTHERS THEN
         invalid_value(p_header_id, 'OE_ORDER_HEADER_ID');
   END get_oeh_row_from_id;

   /*******/
   /* oel */
   /*******/
   FUNCTION get_oel_row_from_num(
      p_line_number oe_order_lines_all.line_number%TYPE,
      p_header_id   oe_order_lines_all.header_id%TYPE
   )
      RETURN oe_order_lines_all%ROWTYPE IS
   BEGIN
      IF (   p_line_number IS NULL
          OR p_header_id IS NULL) THEN
         RETURN NULL;
      END IF;

      IF (    p_line_number = g_oel_row.line_number
          AND p_header_id = g_oel_row.header_id) THEN
         RETURN g_oel_row;
      END IF;

      --first check if there is a singular match in the current OU
      SELECT *
      INTO   g_oel_row
      FROM   oe_order_lines_all
      WHERE  line_id IN(SELECT line_id
                        FROM   oe_order_lines
                        WHERE  line_number = p_line_number
                        AND    header_id = p_header_id
                        AND    flow_status_code = 'AWAITING_RETURN');

      RETURN g_oel_row;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN --check if this exists in a different OU
         BEGIN
            SELECT *
            INTO   g_oel_row
            FROM   oe_order_lines_all
            WHERE  line_number = p_line_number
            AND    header_id = p_header_id
            AND    flow_status_code = 'AWAITING_RETURN';

            RETURN g_oel_row;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               invalid_value(p_line_number, 'OE_ORDER_LINE_NUM');
            WHEN TOO_MANY_ROWS THEN
               IF (g_debug_flag = 'Y') THEN
                  asn_debug.put_line('too many rows in get_oel_row_from_num(' || p_line_number || ',' || p_header_id || ');');
               END IF;

               RETURN NULL;
         END;
      WHEN TOO_MANY_ROWS THEN
         IF (g_debug_flag = 'Y') THEN
            asn_debug.put_line('too many rows in get_oel_row_from_num(' || p_line_number || ',' || p_header_id || ');');
         END IF;

         RETURN NULL;
   END get_oel_row_from_num;

   FUNCTION get_oel_row_from_id(
      p_line_id IN oe_order_lines_all.line_id%TYPE
   )
      RETURN oe_order_lines_all%ROWTYPE IS
   BEGIN
      IF (p_line_id IS NULL) THEN
         RETURN NULL;
      END IF;

      IF (p_line_id = g_oel_row.line_id) THEN
         RETURN g_oel_row;
      END IF;

      SELECT *
      INTO   g_oel_row
      FROM   oe_order_lines_all
      WHERE  line_id = p_line_id;

      RETURN g_oel_row;
   EXCEPTION
      WHEN OTHERS THEN
         invalid_value(p_line_id, 'OE_ORDER_LINE_ID');
   END get_oel_row_from_id;

   FUNCTION get_prl_row_from_id(
      p_requisition_line_id IN po_requisition_lines_all.requisition_line_id%TYPE
   )
      RETURN po_requisition_lines_all%ROWTYPE IS
   BEGIN
      IF (p_requisition_line_id IS NULL) THEN
         RETURN NULL;
      END IF;

      IF (p_requisition_line_id = g_prl_row.requisition_line_id) THEN
         RETURN g_prl_row;
      END IF;

      SELECT *
      INTO   g_prl_row
      FROM   po_requisition_lines_all
      WHERE  requisition_line_id = p_requisition_line_id;

      RETURN g_prl_row;
   EXCEPTION
      WHEN OTHERS THEN
         invalid_value(p_requisition_line_id, 'REQUISITION_LINE_ID');
   END;

   FUNCTION get_prd_row_from_id(
      p_req_distribution_id IN po_req_distributions_all.distribution_id%TYPE
   )
      RETURN po_req_distributions_all%ROWTYPE IS
   BEGIN
      IF (p_req_distribution_id IS NULL) THEN
         RETURN NULL;
      END IF;

      IF (p_req_distribution_id = g_prd_row.distribution_id) THEN
         RETURN g_prd_row;
      END IF;

      SELECT *
      INTO   g_prd_row
      FROM   po_req_distributions_all
      WHERE  distribution_id = p_req_distribution_id;

      RETURN g_prd_row;
   EXCEPTION
      WHEN OTHERS THEN
         invalid_value(p_req_distribution_id, 'REQ_DISTRIBUTION_ID');
   END;

	FUNCTION get_msi_row_from_num
		( p_item_id IN mtl_system_items.inventory_item_id%TYPE
		, p_org_id IN mtl_system_items.organization_id%TYPE
		)
      RETURN mtl_system_items%ROWTYPE IS
	BEGIN
		IF ( p_item_id IS NULL OR p_org_id IS NULL ) THEN
			RETURN NULL;
		END IF;

		IF p_item_id = g_msi_row.inventory_item_id AND p_org_id = g_msi_row.organization_id THEN
			RETURN g_msi_row;
		END IF;

		SELECT *
		INTO   g_msi_row
		FROM   mtl_system_items
		WHERE  inventory_item_id = p_item_id
		AND	   organization_id = p_org_id;

		RETURN g_msi_row;
	EXCEPTION
		WHEN OTHERS THEN
			invalid_value('(' || p_item_id || ', ' || p_org_id || ')', '(ITEM_ID,TO_ORGANIZATION_ID)');
	END get_msi_row_from_num;

	FUNCTION get_mic_row_from_num
		( p_item_id IN mtl_item_categories.inventory_item_id%TYPE
		, p_org_id IN mtl_item_categories.organization_id%TYPE
		)
		RETURN mtl_item_categories%ROWTYPE IS
	BEGIN
		IF ( p_item_id IS NULL OR p_org_id IS NULL ) THEN
			RETURN NULL;
		END IF;

		IF p_item_id = g_mic_row.inventory_item_id AND p_org_id = g_mic_row.organization_id THEN
			RETURN g_mic_row;
		END IF;

		SELECT *
		INTO   g_mic_row
		FROM   mtl_item_categories
		WHERE  inventory_item_id = p_item_id
		AND	   organization_id = p_org_id;

		RETURN g_mic_row;
	EXCEPTION
		WHEN OTHERS THEN
			invalid_value(p_item_id, 'ITEM_ID');
	END get_mic_row_from_num;

	FUNCTION get_mp_row_from_org( p_org_id IN mtl_parameters.organization_id%TYPE )
		RETURN mtl_parameters%ROWTYPE IS
	BEGIN
		IF ( p_org_id IS NULL ) THEN
			RETURN NULL;
		END IF;

		IF p_org_id = g_mp_row.organization_id THEN
			RETURN g_mp_row;
		END IF;

		SELECT *
		INTO   g_mp_row
		FROM   mtl_parameters
		WHERE  organization_id = p_org_id
		AND    rownum = 1;

		RETURN g_mp_row;
	EXCEPTION
		WHEN OTHERS THEN
			invalid_value(p_org_id, 'ORG_ID');
	END get_mp_row_from_org;

	FUNCTION get_rp_row_from_org( p_org_id IN rcv_parameters.organization_id%TYPE )
		RETURN rcv_parameters%ROWTYPE IS
	BEGIN
		IF ( p_org_id IS NULL ) THEN
			RETURN NULL;
		END IF;

		IF p_org_id = g_rp_row.organization_id THEN
			RETURN g_rp_row;
		END IF;

		SELECT *
		INTO   g_rp_row
		FROM   rcv_parameters
		WHERE  organization_id = p_org_id
		AND    rownum = 1;

		RETURN g_rp_row;
	EXCEPTION
		WHEN OTHERS THEN
			invalid_value(p_org_id, 'ORG_ID');
	END get_rp_row_from_org;

	FUNCTION get_fc_row_from_code( p_currency_code IN fnd_currencies.currency_code%TYPE )
		RETURN fnd_currencies%ROWTYPE IS
	BEGIN
		IF ( p_currency_code IS NULL ) THEN
			RETURN NULL;
		END IF;

		IF p_currency_code = g_fc_row.currency_code THEN
			RETURN g_fc_row;
		END IF;

		SELECT *
		INTO   g_fc_row
		FROM   fnd_currencies
		WHERE  currency_code = p_currency_code;

		RETURN g_fc_row;
	EXCEPTION
		WHEN OTHERS THEN
			invalid_value(p_currency_code, 'CURRENCY_CODE');
	END get_fc_row_from_code;

	FUNCTION get_fsp_row
		RETURN financials_system_parameters%ROWTYPE IS
	BEGIN
		IF g_fsp_row.set_of_books_id IS NULL THEN
			SELECT *
			INTO   g_fsp_row
			FROM   financials_system_parameters;
		END IF;

		RETURN g_fsp_row;
	END get_fsp_row;

	FUNCTION get_pvs_row_from_id( p_vendor_site_id IN po_vendor_sites_all.vendor_site_id%TYPE )
		RETURN po_vendor_sites_all%ROWTYPE IS
	BEGIN
		IF p_vendor_site_id IS NULL THEN
			RETURN NULL;
		END IF;

    /* Bug 11834044
     * In Online receiving mode, when the supplier site setup was changed
     * for the Pay On code value, the change is not reflected during receiving
     * when the receipt is against the same supplier/supplier site. Instead the
     * previously cached value was being used which is incorrect. So commenting
     * the logic that is caching, now we get the Pay On code value from
     * supplier site setup every time.
     */

		--IF g_pvs_row.vendor_site_id = p_vendor_site_id THEN
		--	RETURN g_pvs_row;
		--END IF;

		SELECT *
		INTO   g_pvs_row
		FROM   po_vendor_sites_all
		WHERE  vendor_site_id = p_vendor_site_id;

		RETURN g_pvs_row;
	END get_pvs_row_from_id;

	FUNCTION get_muom_row_from_name( p_unit_of_measure IN mtl_units_of_measure.unit_of_measure%TYPE )
		RETURN mtl_units_of_measure%ROWTYPE IS
	BEGIN
		IF p_unit_of_measure IS NULL THEN
			RETURN NULL;
		END IF;

		IF g_muom_row.unit_of_measure = p_unit_of_measure THEN
			RETURN g_muom_row;
		END IF;

		SELECT *
		INTO   g_muom_row
		FROM   mtl_units_of_measure
		WHERE  unit_of_measure = p_unit_of_measure;

		RETURN g_muom_row;
	END get_muom_row_from_name;

	FUNCTION get_po_lookup
		( p_lookup_type IN po_lookup_codes.lookup_type%TYPE
		, p_lookup_code IN po_lookup_codes.lookup_code%TYPE
		) RETURN po_lookup_codes.displayed_field%TYPE IS
			l_key VARCHAR2(80) := p_lookup_type || '-' || p_lookup_code;
	BEGIN
		IF NOT g_po_lookups.EXISTS(l_key) THEN
			SELECT displayed_field
			  INTO g_po_lookups(l_key)
			  FROM po_lookup_codes
			 WHERE lookup_type = p_lookup_type
			   AND lookup_code = p_lookup_code
			   AND enabled_flag = 'Y';
		END IF;

		RETURN g_po_lookups(l_key);
	EXCEPTION
		WHEN OTHERS THEN
			RETURN NULL;
	END get_po_lookup;

	FUNCTION is_lcm_shipment (p_po_line_location_id IN NUMBER )
	RETURN VARCHAR2 IS
	  BEGIN
  	    IF ( nvl(g_pll_id,-99) <> p_po_line_location_id) THEN

	       SELECT nvl(lcm_flag,'N')
	       INTO   g_lcm_flag
	       FROM   po_line_locations_all
	       WHERE  line_location_id = p_po_line_location_id;

	       g_pll_id := p_po_line_location_id;
            END IF;

            RETURN g_lcm_flag;
	  EXCEPTION
	    WHEN OTHERS THEN
	         RETURN 'N';
	END is_lcm_shipment;

	FUNCTION is_lcm_org ( p_organization_id IN NUMBER )
	RETURN VARCHAR2 IS
	  BEGIN
	    IF ( nvl(g_mp_org_id,-99) <> p_organization_id) THEN
	       SELECT nvl(lcm_enabled_flag,'N')
	       INTO   g_lcm_enabled_flag
	       FROM   mtl_parameters
	       WHERE  organization_id = p_organization_id;

	       g_mp_org_id := p_organization_id;
            END IF;

            RETURN g_lcm_enabled_flag;
	  EXCEPTION
	    WHEN OTHERS THEN
	         RETURN 'N';
	END is_lcm_org;

	FUNCTION is_pre_rcv_org	( p_organization_id IN NUMBER )
	RETURN VARCHAR2 IS
	  BEGIN
	    IF ( nvl(g_rp_org_id,-99) <> p_organization_id) THEN
	       SELECT nvl(pre_receive,'N')
	       INTO   g_pre_rcv_flag
	       FROM   rcv_parameters
	       WHERE  organization_id = p_organization_id;

	       g_rp_org_id := p_organization_id;
            END IF;

            RETURN g_pre_rcv_flag;
	  EXCEPTION
	    WHEN OTHERS THEN
	         RETURN 'N';
	END is_pre_rcv_org;

END rcv_table_functions;

/
