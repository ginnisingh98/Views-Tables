--------------------------------------------------------
--  DDL for Package Body RCV_HEADERS_INTERFACE_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_HEADERS_INTERFACE_SV" AS
/* $Header: RCVHISVB.pls 120.1.12010000.3 2010/01/25 22:47:00 vthevark ship $ */

-- Read the profile option that enables/disables the debug log
   g_asn_debug        VARCHAR2(1)                                        := asn_debug.is_debug_on; -- Bug 9152790

   -- Bug 2506961
   PROCEDURE genreceiptnum(
      p_header_record IN OUT NOCOPY rcv_shipment_header_sv.headerrectype
   );

   vendor_record      rcv_shipment_header_sv.vendorrectype;
   vendor_site_record rcv_shipment_header_sv.vendorsiterectype;
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
   x_sysdate          DATE                                               := SYSDATE;
   x_count            NUMBER                                             := 0;
   x_location_id      NUMBER;

/*===========================================================================+
 |                                                                           |
 | PROCEDURE NAME:          derive_shipment_header()                         |
 |                                                                           |
 +===========================================================================*/
   PROCEDURE derive_shipment_header(
      p_header_record IN OUT NOCOPY rcv_shipment_header_sv.headerrectype
   ) IS
   BEGIN
      /* Derive Vendor Information */
      IF p_header_record.error_record.error_status IN('S', 'W') THEN
         vendor_record.vendor_name                  := p_header_record.header_record.vendor_name;
         vendor_record.vendor_num                   := p_header_record.header_record.vendor_num;
         vendor_record.vendor_id                    := p_header_record.header_record.vendor_id;
         vendor_record.error_record                 := p_header_record.error_record;

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

         p_header_record.header_record.vendor_name  := vendor_record.vendor_name;
         p_header_record.header_record.vendor_num   := vendor_record.vendor_num;
         p_header_record.header_record.vendor_id    := vendor_record.vendor_id;
         p_header_record.error_record               := vendor_record.error_record;
      END IF;

      /* Derive Ship To Organization Information */
      /* organization_id is uk. org_organization_definitions is a view */
      IF p_header_record.error_record.error_status IN('S', 'W') THEN
         /*
         ** If the shipment header ship to organization code is null then try
         ** to pull it off the rcv_transactions_interface to_organization_code or
         ** the ship_to_location_code.
         */
         IF (    p_header_record.header_record.ship_to_organization_code IS NULL
             AND p_header_record.header_record.ship_to_organization_id IS NULL) THEN
            rcv_headers_interface_sv.derive_ship_to_org_from_rti(p_header_record);
         END IF;

         ship_to_org_record.organization_code                     := p_header_record.header_record.ship_to_organization_code;
         ship_to_org_record.organization_id                       := p_header_record.header_record.ship_to_organization_id;
         ship_to_org_record.error_record                          := p_header_record.error_record;

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
         p_header_record.error_record                             := ship_to_org_record.error_record;
      END IF;

      /* derive from organization information */
      IF     p_header_record.error_record.error_status IN('S', 'W')
         AND p_header_record.header_record.transaction_type <> 'CANCEL' THEN -- added for support of cancel
         from_org_record.organization_code                     := p_header_record.header_record.from_organization_code;
         from_org_record.organization_id                       := p_header_record.header_record.from_organization_id;
         from_org_record.error_record                          := p_header_record.error_record;

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
         p_header_record.error_record                          := from_org_record.error_record;
      END IF;

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
         vendor_site_record.error_record                        := p_header_record.error_record;

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
         p_header_record.error_record                           := vendor_site_record.error_record;
      END IF;

      /* Derive Location Information */
      /* HR_LOCATION has 2 unique indexes
         1 -> location_id
         2 -> location_code */
      IF     p_header_record.error_record.error_status IN('S', 'W')
         AND (   p_header_record.header_record.location_code IS NOT NULL
              OR p_header_record.header_record.location_id IS NOT NULL) THEN
         loc_record.location_code                     := p_header_record.header_record.location_code;
         loc_record.location_id                       := p_header_record.header_record.location_id;
         loc_record.error_record                      := p_header_record.error_record;

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
         p_header_record.error_record                 := loc_record.error_record;
      END IF;

      /* Derive Payment Terms Information */
      IF     p_header_record.error_record.error_status IN('S', 'W')
         AND p_header_record.header_record.transaction_type <> 'CANCEL'
         AND -- added for support of cancel
             (   p_header_record.header_record.payment_terms_id IS NOT NULL
              OR p_header_record.header_record.payment_terms_name IS NOT NULL) THEN
         pay_record.payment_term_id                        := p_header_record.header_record.payment_terms_id;
         pay_record.payment_term_name                      := p_header_record.header_record.payment_terms_name;
         pay_record.error_record                           := p_header_record.error_record;

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
         p_header_record.error_record                      := pay_record.error_record;
      END IF;

      /* derive receiver information */
      IF     p_header_record.error_record.error_status IN('S', 'W')
         AND p_header_record.header_record.transaction_type <> 'CANCEL'
         AND -- added for support of cancel
             (   p_header_record.header_record.employee_name IS NOT NULL
              OR p_header_record.header_record.employee_id IS NOT NULL) THEN
         emp_record.employee_name                     := p_header_record.header_record.employee_name;
         emp_record.employee_id                       := p_header_record.header_record.employee_id;
         emp_record.error_record                      := p_header_record.error_record;

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
         p_header_record.error_record                 := emp_record.error_record;
      END IF;

      /* Derive shipment_header_id if transaction type = CANCEL */

      -- added for support of cancel

      IF     p_header_record.error_record.error_status IN('S', 'W')
         AND p_header_record.header_record.transaction_type = 'CANCEL'
         AND p_header_record.header_record.shipment_num IS NOT NULL THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Derive shipment info');
         END IF;

         rcv_core_s.derive_shipment_info(p_header_record);
      END IF;
   END derive_shipment_header;

/*===========================================================================+
 |                                                                           |
 | PROCEDURE NAME:          default_shipment_header()                        |
 |                                                                           |
 +===========================================================================*/
   PROCEDURE default_shipment_header(
      p_header_record IN OUT NOCOPY rcv_shipment_header_sv.headerrectype
   ) IS
      v_rcv_type     po_system_parameters.user_defined_receipt_num_code%TYPE;
      v_count        NUMBER                                                    := 0;
      temp_count     NUMBER;
      x_po_header_id NUMBER;
      x_document_num VARCHAR2(20);
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('In default');
      END IF;

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

      /* last_update_login */
      IF p_header_record.header_record.last_update_login IS NULL THEN
         p_header_record.header_record.last_update_login  := fnd_global.login_id;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('defaulting last update login');
         END IF;
      END IF;

      /* Default STD into asn_type for null asn_type */
      IF p_header_record.header_record.asn_type IS NULL THEN
         p_header_record.header_record.asn_type  := 'STD';

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('defaulting asn type to STD');
         END IF;
      END IF;

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
      IF p_header_record.header_record.shipment_num IS NULL THEN
         p_header_record.header_record.shipment_num  := p_header_record.header_record.packing_slip;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('defaulted shipment number');
         END IF;
      END IF;

      /* generate the shipment_header_id */
      /* shipment_header_id - receipt_header_id is the same */
      IF     p_header_record.header_record.receipt_header_id IS NULL
         AND p_header_record.header_record.transaction_type <> 'CANCEL' THEN -- added for support of cancel
         SELECT rcv_shipment_headers_s.NEXTVAL
         INTO   p_header_record.header_record.receipt_header_id
         FROM   SYS.DUAL;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('defaulted receipt_id');
         END IF;
      END IF;

      /* receipt_num */

      -- We will not generate a receipt num for auto transact code = SHIP
      -- This will help minimise locking problems

      -- If Receipt Generation is set to Manual then we need to default it based
      -- on the Shipment number. If shipment_num is also null then we will use the
      -- shipment_header_id. We need a Receipt num in case of RECEIVE/DELIVER as
      -- some of the views of the receiving form have the condition of receipt_num not
      -- null added to it.

      -- IF the transaction type is CANCEL then no need to generate a receipt num

      -- We cannot depend on the auto_transact_code from the rcv_headers_interface
      -- to figure out whether we need to generate a receipt_num
      -- We will look at the transactions_interface.auto_transact_code/transaction_type
      -- to figure out whether we need to do the generation

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
                  rcv_headers_interface_sv.genreceiptnum(p_header_record);
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
               WHEN OTHERS THEN
                  p_header_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
                  rcv_error_pkg.set_sql_error_message('default_shipment_header', '010');
                  p_header_record.error_record.error_message  := rcv_error_pkg.get_last_message;
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

      /* vendor_site_id  po_vendor_sites_sv.default_purchasing_site */
      /* Check for whether we need more conditions in the where clause of the
         procedure like pay_site_flag etc */

      /* For transaction_type = CANCEL we should have picked up the vendor_site_id in
         the derive_shipment_info stage */
      IF     p_header_record.header_record.vendor_site_id IS NULL
         AND p_header_record.header_record.vendor_site_code IS NULL
         AND p_header_record.header_record.vendor_id IS NOT NULL THEN -- added for support of cancel
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Need to get default vendor site id');
         END IF;

         po_vendor_sites_sv.get_def_vendor_site(p_header_record.header_record.vendor_id,
                                                p_header_record.header_record.vendor_site_id,
                                                p_header_record.header_record.vendor_site_code,
                                                'RCV'
                                               );

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('defaulted vendor_site info');
         END IF;
      END IF;

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
               SELECT po_header_id
               INTO   x_po_header_id
               FROM   po_headers
               WHERE  segment1 = x_document_num
               AND    type_lookup_code IN('STANDARD', 'BLANKET', 'PLANNED');
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

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('defaulted location info');
         END IF;
      END IF;

      /* Currency Code if ASBN invoice_currency_code po_vendor_sites_sv.default */

      /* RECEIPT SOURCE CODE */
      IF p_header_record.header_record.receipt_source_code IS NULL THEN
         p_header_record.header_record.receipt_source_code  := 'VENDOR';

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('defaulted receipt_source_code info');
         END IF;
      END IF;

      -- added for support of cancel
      -- default any shipment info

      IF     p_header_record.header_record.transaction_type = 'CANCEL'
         AND (   p_header_record.header_record.receipt_header_id IS NULL
              OR p_header_record.header_record.shipment_num IS NULL) THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Into default shipment info');
         END IF;

         rcv_core_s.default_shipment_info(p_header_record);
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Out of default');
      END IF;
   END default_shipment_header;

/*===========================================================================+
 |                                                                           |
 | PROCEDURE NAME:          validate_shipment_header()                       |
 |                                                                           |
 +===========================================================================*/
   PROCEDURE validate_shipment_header(
      p_header_record IN OUT NOCOPY rcv_shipment_header_sv.headerrectype
   ) IS
   BEGIN
      /* Validate Transaction Type */
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('In validate routine');
      END IF;

      IF p_header_record.error_record.error_status NOT IN('S', 'W') THEN
         RETURN;
      END IF;

      lookup_record.lookup_code                  := p_header_record.header_record.transaction_type;
      lookup_record.lookup_type                  := 'TRANSACTION_TYPE';
      lookup_record.error_record                 := p_header_record.error_record;
      po_core_s.validate_lookup_info(lookup_record);
      p_header_record.error_record.error_status  := lookup_record.error_record.error_status;
/* po_core_s doesn't follow error paradigm */
      rcv_error_pkg.set_error_message(lookup_record.error_record.error_message, p_header_record.error_record.error_message);

      IF (p_header_record.error_record.error_message = 'RCV_TRX_TYPE_INVALID') THEN
         rcv_error_pkg.set_token('TYPE', lookup_record.lookup_code);
      END IF;

      rcv_error_pkg.log_interface_message(p_header_record.error_record.error_status,
                                          'RCV_HEADERS_INTERFACE',
                                          'TRANSACTION_TYPE'
                                         );

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('validated transaction type');
      END IF;

      /* Validate Document type */
      IF     p_header_record.header_record.asn_type IS NOT NULL
         AND p_header_record.header_record.asn_type <> 'STD' THEN
         lookup_record.lookup_code                  := p_header_record.header_record.asn_type;
         lookup_record.lookup_type                  := 'ASN_TYPE';
         lookup_record.error_record                 := p_header_record.error_record;
         po_core_s.validate_lookup_info(lookup_record);
         p_header_record.error_record.error_status  := lookup_record.error_record.error_status;
/* po_core_s doesn't follow error paradigm */
         rcv_error_pkg.set_error_message(lookup_record.error_record.error_message, p_header_record.error_record.error_message);

         IF (p_header_record.error_record.error_message = 'PO_PDOI_INVALID_TYPE_LKUP_CD') THEN
            rcv_error_pkg.set_token('TYPE', lookup_record.lookup_code);
         END IF;

         rcv_error_pkg.log_interface_message(p_header_record.error_record.error_status,
                                             'RCV_HEADERS_INTERFACE',
                                             'ASN_TYPE'
                                            );

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('validated asn type');
         END IF;
      ELSE
         p_header_record.header_record.asn_type  := 'STD'; -- Not an ASN/ASBN
      END IF;

      /* Validate Currency Code */
      IF     p_header_record.header_record.transaction_type <> 'CANCEL'
         AND p_header_record.header_record.asn_type = 'ASBN'
         AND p_header_record.header_record.currency_code IS NOT NULL THEN
         currency_record.currency_code              := p_header_record.header_record.currency_code;
         currency_record.error_record               := p_header_record.error_record;
         po_currency_sv.validate_currency_info(currency_record);
         p_header_record.error_record.error_status  := currency_record.error_record.error_status;

/* po_currency_s doesn't follow error paradigm */
         IF (currency_record.error_record.error_message IN('CURRENCY_DISABLED', 'CURRENCY_INVALID')) THEN
            rcv_error_pkg.set_error_message('PO_PDOI_INVALID_CURRENCY', p_header_record.error_record.error_message);
            rcv_error_pkg.set_token('VALUE', p_header_record.header_record.currency_code);
         ELSE
            rcv_error_pkg.set_error_message(currency_record.error_record.error_message, p_header_record.error_record.error_message);
         END IF;

         rcv_error_pkg.log_interface_message(p_header_record.error_record.error_status,
                                             'RCV_HEADERS_INTERFACE',
                                             'CURRENCY_CODE'
                                            );

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('validated currency info');
         END IF;
      END IF;

      /* Validation for Shipment Date > System Date and not NULL,blank,zero */
      IF NVL(p_header_record.header_record.shipped_date, x_sysdate + 1) > x_sysdate THEN
         IF     p_header_record.header_record.shipped_date IS NULL
            AND p_header_record.header_record.asn_type = 'STD' THEN
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Shipped date can be blank for STD');
            END IF;
         ELSE
            p_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
            rcv_error_pkg.set_error_message('RCV_SHIP_DATE_INVALID', p_header_record.error_record.error_message);
            rcv_error_pkg.set_token('SHIP_DATE', p_header_record.header_record.shipped_date);
            rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE', 'SHIPPED_DATE');
         END IF;
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('validated for shipment_date > system date');
      END IF;

      /* Validation for Receipt Date > Shipped Date if Receipt Date is specified */
      IF p_header_record.header_record.transaction_type <> 'CANCEL' THEN
         IF p_header_record.header_record.expected_receipt_date IS NOT NULL THEN
            IF p_header_record.header_record.expected_receipt_date <   /* nwang: allow expected_receipt_date to be the same as shipped_date */
                                                                    p_header_record.header_record.shipped_date THEN
               p_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
               rcv_error_pkg.set_error_message('RCV_DELIV_DATE_INVALID', p_header_record.error_record.error_message);
               rcv_error_pkg.set_token('DELIVERY DATE', p_header_record.header_record.shipped_date);
               rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE', 'EXPECTED_RECEIPT_DATE');
            END IF;
         END IF;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('validated for Receipt Date > Shipped Date if Receipt Date is specified');
         END IF;
      END IF;

      /* Validation expected_receipt_date is not missing BUG 628316 */
      IF p_header_record.header_record.transaction_type <> 'CANCEL' THEN
         IF p_header_record.header_record.expected_receipt_date IS NULL THEN
            p_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
            rcv_error_pkg.set_error_message('RCV_ASN_EXPECTED_RECEIPT_DATE', p_header_record.error_record.error_message);
            rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE', 'EXPECTED_RECEIPT_DATE');
         END IF;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('validated expected_receipt_date is not missing');
         END IF;
      END IF;

      /* Validate Receipt Number */
      IF     p_header_record.header_record.receipt_num IS NULL
         AND p_header_record.header_record.asn_type = 'STD'
         AND p_header_record.header_record.transaction_type <> 'CANCEL' THEN -- added for support of cancel
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Receipt Number is mandatory for STD');
         END IF;

         p_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
         rcv_error_pkg.set_error_message('RCV_RECEIPT_NUM_REQ', p_header_record.error_record.error_message);
         rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE', 'RECEIPT_NUM');
      END IF;

      IF     p_header_record.header_record.receipt_num IS NOT NULL
         AND p_header_record.header_record.transaction_type <> 'CANCEL' THEN -- added for support of cancel
         SELECT COUNT(*)
         INTO   x_count
         FROM   rcv_shipment_headers
         WHERE  rcv_shipment_headers.receipt_num = p_header_record.header_record.receipt_num
         AND    ship_to_org_id = p_header_record.header_record.ship_to_organization_id;

         IF x_count > 0 THEN
            p_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
            rcv_error_pkg.set_error_message('PO_PDOI_RECEIPT_NUM_UNIQUE', p_header_record.error_record.error_message);
            rcv_error_pkg.set_token('VALUE', p_header_record.header_record.receipt_num);
            rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE', 'RECEIPT_NUM');
         END IF;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('validated receipt number');
         END IF;
      END IF;

      /* Validate Vendor Information */
      IF     p_header_record.header_record.vendor_id IS NULL
         AND p_header_record.header_record.vendor_name IS NULL
         AND p_header_record.header_record.vendor_num IS NULL THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('validated vendor info is all null');
         END IF;

         p_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
         rcv_error_pkg.set_error_message('PO_PDOI_COLUMN_NOT_NULL', p_header_record.error_record.error_message);
         rcv_error_pkg.set_token('COLUMN_NAME', 'VENDOR_ID');
         rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE', 'VENDOR_ID');
      END IF;

      vendor_record.vendor_name                  := p_header_record.header_record.vendor_name;
      vendor_record.vendor_num                   := p_header_record.header_record.vendor_num;
      vendor_record.vendor_id                    := p_header_record.header_record.vendor_id;
      vendor_record.error_record                 := p_header_record.error_record;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('In Vendor Validation Procedure');
      END IF;

      po_vendors_sv.validate_vendor_info(vendor_record);
      p_header_record.error_record.error_status  := vendor_record.error_record.error_status;

/* po_core_s doesn't follow error paradigm */
      IF (vendor_record.error_record.error_message = 'VEN_DISABLED') THEN
         IF NVL(p_header_record.header_record.asn_type,'STD') = 'STD' THEN
            p_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_success;
         ELSE
            rcv_error_pkg.set_error_message('PO_PDOI_INVALID_VENDOR', p_header_record.error_record.error_message);
            rcv_error_pkg.set_token('VALUE', vendor_record.vendor_id);
         END IF;
      ELSIF(vendor_record.error_record.error_message = 'VEN_HOLD') THEN
         IF    p_header_record.header_record.transaction_type = 'CANCEL'
            OR NVL(p_header_record.header_record.asn_type,'STD') = 'STD' THEN
            p_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_success;
         ELSE
            rcv_error_pkg.set_error_message('PO_PO_VENDOR_ON_HOLD', p_header_record.error_record.error_message);
            rcv_error_pkg.set_token('VALUE', vendor_record.vendor_id);
         END IF;
      ELSIF(vendor_record.error_record.error_message = 'VEN_ID') THEN
         rcv_error_pkg.set_error_message('RCV_VEN_ID', p_header_record.error_record.error_message);
         rcv_error_pkg.set_token('SUPPLIER', vendor_record.vendor_id);
      END IF;

      rcv_error_pkg.log_interface_message(p_header_record.error_record.error_status,
                                          'RCV_HEADERS_INTERFACE',
                                          'VENDOR_ID'
                                         );

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Validated vendor info');
      END IF;

      /* Validate Ship To Organization Information */
      IF p_header_record.header_record.asn_type IN('ASN', 'ASBN', 'STD') THEN
         ship_to_org_record.organization_code       := p_header_record.header_record.ship_to_organization_code;
         ship_to_org_record.organization_id         := p_header_record.header_record.ship_to_organization_id;
         ship_to_org_record.error_record            := p_header_record.error_record;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('In Validate Ship to Organization Procedure');
         END IF;

         po_orgs_sv.validate_org_info(ship_to_org_record);
         p_header_record.error_record.error_status  := ship_to_org_record.error_record.error_status;

/* po_core_s doesn't follow error paradigm */
         IF (ship_to_org_record.error_record.error_message = 'ORG_ID') THEN
            rcv_error_pkg.set_error_message('PO_PDOI_INVALID_SHIP_TO_ORG_ID', p_header_record.error_record.error_message);
            rcv_error_pkg.set_token('VALUE', ship_to_org_record.organization_id);
         ELSIF(ship_to_org_record.error_record.error_message = 'ORG_DISABLED') THEN
            IF p_header_record.header_record.transaction_type = 'CANCEL' THEN
               p_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_success;
            ELSE
               rcv_error_pkg.set_error_message('RCV_SHIPTO_ORG_DISABLED', p_header_record.error_record.error_message);
               rcv_error_pkg.set_token('ORGANIZATION', ship_to_org_record.organization_id);
            END IF;
         END IF;

         rcv_error_pkg.log_interface_message(p_header_record.error_record.error_status,
                                             'RCV_HEADERS_INTERFACE',
                                             'SHIP_TO_ORGANIZATION_ID'
                                            );

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('validated ship to organization info');
         END IF;
      END IF;

/* Bug# 3662698.
   Verify if any of the lines tied to the header have destination organization
   different to that of the header's org (which is either populated or derived).
*/
      IF (    p_header_record.header_record.asn_type IN('ASN', 'ASBN', 'STD')
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
               rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE', 'SHIP_TO_ORGANIZATION_ID');
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
                      hr_locations_all hl, --Bug 5219141. Replace hr_locations by hr_locations_all
                      mtl_parameters org --Replaced org_organization_definitions
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
                         hr_locations_all hl, --Bug 5219141. Replace hr_locations by hr_locations_all
                         mtl_parameters org   --Replaced org_organization_definitions
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
                  rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE', 'SHIP_TO_ORGANIZATION_ID');
               END IF;
            END IF;

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Validated ship to org of all the RTIs tied to the header');
            END IF;
         END IF;
      END IF; --End of bug# 3662698.

      /* validate from organization information */
      IF p_header_record.header_record.transaction_type <> 'CANCEL' THEN
         IF    from_org_record.organization_code IS NOT NULL
            OR from_org_record.organization_id IS NOT NULL THEN
            from_org_record.organization_code          := p_header_record.header_record.from_organization_code;
            from_org_record.organization_id            := p_header_record.header_record.from_organization_id;
            from_org_record.error_record               := p_header_record.error_record;

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('In Validate From Organization Procedure');
            END IF;

            po_orgs_sv.validate_org_info(from_org_record);
            p_header_record.error_record.error_status  := from_org_record.error_record.error_status;

/* po_core_s doesn't follow error paradigm */
            IF (from_org_record.error_record.error_message = 'ORG_ID') THEN
               rcv_error_pkg.set_error_message('RCV_FROM_ORG_ID', p_header_record.error_record.error_message);
               rcv_error_pkg.set_token('VALUE', from_org_record.organization_id);
            ELSIF(from_org_record.error_record.error_message = 'ORG_DISABLED') THEN
               IF p_header_record.header_record.transaction_type = 'CANCEL' THEN
                  p_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_success;
               ELSE
                  rcv_error_pkg.set_error_message('RCV_FROM_ORG_DISABLED', p_header_record.error_record.error_message);
                  rcv_error_pkg.set_token('ORGANIZATION', from_org_record.organization_id);
               END IF;
            END IF;

            rcv_error_pkg.log_interface_message(p_header_record.error_record.error_status,
                                                'RCV_HEADERS_INTERFACE',
                                                'SHIP_TO_ORGANIZATION_ID'
                                               );
         END IF;
      END IF;

      /* validate vendor site information */
      IF     p_header_record.error_record.error_status IN('S', 'W')
         AND (   p_header_record.header_record.vendor_site_code IS NOT NULL
              OR p_header_record.header_record.vendor_site_id IS NOT NULL) THEN
         vendor_site_record.vendor_site_code  := p_header_record.header_record.vendor_site_code;
         vendor_site_record.vendor_id         := p_header_record.header_record.vendor_id;
         vendor_site_record.vendor_site_id    := p_header_record.header_record.vendor_site_id;
         vendor_site_record.organization_id   := NULL;
         vendor_site_record.error_record      := p_header_record.error_record;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('In Validate Vendor Site Procedure');
         END IF;

         po_vendor_sites_sv.validate_vendor_site_info(vendor_site_record);

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
         IF (   vendor_site_record.error_record.error_message = 'VEN_SITE_NOT_POR_SITE'
             OR vendor_site_record.error_record.error_message = 'VEN_SITE_HOLD_PMT') THEN
            IF     p_header_record.header_record.asn_type = 'ASBN'
               AND p_header_record.header_record.transaction_type <> 'CANCEL' THEN
               vendor_site_record.error_record.error_message      := 'PO_INV_CR_INVALID_PAY_SITE';
               vendor_site_record.error_record.error_status       := rcv_error_pkg.g_ret_sts_warning;
               rcv_error_pkg.set_error_message('PO_INV_CR_INVALID_PAY_SITE', vendor_site_record.error_record.error_message);
               rcv_error_pkg.set_token('VENDOR_SITE_ID', vendor_site_record.vendor_site_id);
               p_header_record.header_record.invoice_status_code  := 'RCV_ASBN_NO_AUTO_INVOICE';
            ELSE
               vendor_site_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_success;
               vendor_site_record.error_record.error_message  := NULL;
            END IF;
         ELSIF vendor_site_record.error_record.error_message = 'VEN_SITE_DISABLED' THEN
            /* Fix for bug 2830103.
               Validation for inactive vendor site should happen only for
               ASNs and ASBNs. Hence adding the following IF condition
               below so that no validation happens for STD receipts.
            */
            IF NVL(p_header_record.header_record.asn_type, 'STD') IN('ASN', 'ASBN') THEN
               rcv_error_pkg.set_error_message('PO_PDOI_INVALID_VENDOR_SITE', vendor_site_record.error_record.error_message);
               rcv_error_pkg.set_token('VALUE', vendor_site_record.vendor_site_id);
            ELSE
               vendor_site_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_success;
               vendor_site_record.error_record.error_message  := NULL;
            END IF;
         ELSIF vendor_site_record.error_record.error_message IN('VEN_SITE_NOT_PURCH', 'VEN_SITE_ID') THEN
            rcv_error_pkg.set_error_message('PO_PDOI_INVALID_VENDOR_SITE', vendor_site_record.error_record.error_message);
            rcv_error_pkg.set_token('VALUE', vendor_site_record.vendor_site_id);
         ELSIF vendor_site_record.error_record.error_status <> rcv_error_pkg.g_ret_sts_success THEN
            rcv_error_pkg.set_error_message(vendor_site_record.error_record.error_message, vendor_site_record.error_record.error_message); -- to set any other errors
         END IF;

         p_header_record.error_record         := vendor_site_record.error_record;
         rcv_error_pkg.log_interface_message(p_header_record.error_record.error_status,
                                             'RCV_HEADERS_INTERFACE',
                                             'VENDOR_ID'
                                            );

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Validated vendor site info');
         END IF;
      END IF;

      /* Validate Location Information */
      IF     p_header_record.header_record.transaction_type <> 'CANCEL'
         AND p_header_record.header_record.asn_type IN('ASN', 'ASBN', 'STD')
         AND (   p_header_record.header_record.location_code IS NOT NULL
              OR p_header_record.header_record.location_id IS NOT NULL) THEN
         loc_record.location_code      := p_header_record.header_record.location_code;
         loc_record.location_id        := p_header_record.header_record.location_id;
         loc_record.organization_id    := p_header_record.header_record.ship_to_organization_id;
         loc_record.error_record       := p_header_record.error_record;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('In Validate Location Code Procedure');
         END IF;

         po_locations_s.validate_location_info(loc_record);

         IF loc_record.error_record.error_message IN('LOC_ID', 'LOC_DISABLED') THEN
            rcv_error_pkg.set_error_message('PO_PDOI_INVALID_SHIP_TO_LOC_ID', loc_record.error_record.error_message);
            rcv_error_pkg.set_token('VALUE', loc_record.location_id);
         ELSIF loc_record.error_record.error_message = 'LOC_NOT_RCV_SITE' THEN
            rcv_error_pkg.set_error_message('RCV_LOC_NOT_RCV_SITE', loc_record.error_record.error_message);
            rcv_error_pkg.set_token('LOCATION', loc_record.location_id);
         ELSIF loc_record.error_record.error_message = 'LOC_NOT_IN_ORG' THEN
            rcv_error_pkg.set_error_message('RCV_LOC_NOT_IN_ORG', loc_record.error_record.error_message);
            rcv_error_pkg.set_token('LOCATION', loc_record.location_id);
            rcv_error_pkg.set_token('ORGANIZATION', loc_record.organization_id);
         ELSIF loc_record.error_record.error_status <> rcv_error_pkg.g_ret_sts_success THEN
            rcv_error_pkg.set_error_message(loc_record.error_record.error_message, loc_record.error_record.error_message); -- to set any other errors
         END IF;

         p_header_record.error_record  := loc_record.error_record;
         rcv_error_pkg.log_interface_message(p_header_record.error_record.error_status,
                                             'RCV_HEADERS_INTERFACE',
                                             'LOCATION_ID'
                                            );

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line(loc_record.error_record.error_status);
            asn_debug.put_line(loc_record.error_record.error_message);
            asn_debug.put_line('Validated location info');
         END IF;
      END IF;

      /* Validate Payment Terms Information */
      IF     (   p_header_record.header_record.payment_terms_name IS NOT NULL
              OR p_header_record.header_record.payment_terms_id IS NOT NULL)
         AND p_header_record.header_record.transaction_type <> 'CANCEL' THEN
         pay_record.payment_term_id    := p_header_record.header_record.payment_terms_id;
         pay_record.payment_term_name  := p_header_record.header_record.payment_terms_name;
         pay_record.error_record       := p_header_record.error_record;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('In Validate Payment Terms ');
         END IF;

         po_terms_sv.validate_payment_terms_info(pay_record);

         IF pay_record.error_record.error_message = 'PAY_TERMS_DISABLED' THEN
            IF p_header_record.header_record.asn_type = 'ASBN' THEN
               rcv_error_pkg.set_error_message('PO_PDOI_INVALID_PAY_TERMS', pay_record.error_record.error_message);
               rcv_error_pkg.set_token('VALUE', pay_record.payment_term_id);
            ELSE
               pay_record.error_record.error_message  := NULL;
               pay_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_success;
            END IF;
         ELSIF pay_record.error_record.error_message = 'PAY_TERMS_ID' THEN
            rcv_error_pkg.set_error_message('PO_PDOI_INVALID_PAY_TERMS', pay_record.error_record.error_message);
            rcv_error_pkg.set_token('VALUE', pay_record.payment_term_id);
         ELSIF pay_record.error_record.error_status <> rcv_error_pkg.g_ret_sts_success THEN
            rcv_error_pkg.set_error_message(pay_record.error_record.error_message, pay_record.error_record.error_message); -- to set any other errors
         END IF;

         p_header_record.error_record  := pay_record.error_record;
         rcv_error_pkg.log_interface_message(p_header_record.error_record.error_status,
                                             'RCV_HEADERS_INTERFACE',
                                             'PAYMENT_TERM_ID'
                                            );

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Validated payment info');
         END IF;
      END IF;

      /* validate receiver information */
      IF     p_header_record.header_record.transaction_type <> 'CANCEL'
         AND p_header_record.header_record.auto_transact_code = 'RECEIVE'
         AND (   p_header_record.header_record.employee_name IS NOT NULL
              OR p_header_record.header_record.employee_id IS NOT NULL) THEN
         emp_record.employee_name      := p_header_record.header_record.employee_name;
         emp_record.employee_id        := p_header_record.header_record.employee_id;
         emp_record.error_record       := p_header_record.error_record;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('In Validate Receiver Information');
         END IF;

         po_employees_sv.validate_employee_info(emp_record);

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line(emp_record.error_record.error_status);
         END IF;

         IF emp_record.error_record.error_message = 'RECEIVER_ID' THEN
            rcv_error_pkg.set_error_message('RCV_RECEIVER_ID', emp_record.error_record.error_message);
            rcv_error_pkg.set_token('NAME', emp_record.employee_name);
         ELSIF emp_record.error_record.error_status <> rcv_error_pkg.g_ret_sts_success THEN
            rcv_error_pkg.set_error_message(emp_record.error_record.error_message, emp_record.error_record.error_message); -- to set any other errors
         END IF;

         p_header_record.error_record  := emp_record.error_record;
         rcv_error_pkg.log_interface_message(p_header_record.error_record.error_status,
                                             'RCV_HEADERS_INTERFACE',
                                             'EMPLOYEE_ID'
                                            );

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Validated receiver info');
         END IF;
      END IF;

      /* validate freight carrier information */
      /* ASN and ASBN, al transaction_types except CANCEL */
      /* Carrier is specified */
      IF     p_header_record.header_record.transaction_type <> 'CANCEL'
         AND p_header_record.header_record.freight_carrier_code IS NOT NULL THEN
         freight_record.freight_carrier_code  := p_header_record.header_record.freight_carrier_code;
         freight_record.organization_id       := p_header_record.header_record.ship_to_organization_id;
         freight_record.error_record          := p_header_record.error_record;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('In Validate Freight Carrier Information');
         END IF;

         po_terms_sv.validate_freight_carrier_info(freight_record);

         IF freight_record.error_record.error_message IN('CARRIER_DISABLED', 'CARRIER_INVALID') THEN
            rcv_error_pkg.set_error_message('RCV_CARRIER_DISABLED', freight_record.error_record.error_message);
            rcv_error_pkg.set_token('CARRIER', freight_record.freight_carrier_code);
         ELSIF freight_record.error_record.error_status <> rcv_error_pkg.g_ret_sts_success THEN
            rcv_error_pkg.set_error_message(freight_record.error_record.error_message, freight_record.error_record.error_message); -- to set any other errors
         END IF;

         p_header_record.error_record         := freight_record.error_record;
         rcv_error_pkg.log_interface_message(p_header_record.error_record.error_status,
                                             'RCV_HEADERS_INTERFACE',
                                             'FREIGHT_CARRIER_CODE'
                                            );

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Validated freight carrier info');
         END IF;
      END IF;

      /* Validate Invoice Amount > 0 */
      /* Invoice amount Vs Supplier Site Limit */
      IF     p_header_record.header_record.transaction_type <> 'CANCEL'
         AND p_header_record.header_record.asn_type = 'ASBN' THEN
         invoice_record.total_invoice_amount  := p_header_record.header_record.total_invoice_amount;
         invoice_record.vendor_id             := p_header_record.header_record.vendor_id;
         invoice_record.vendor_site_id        := p_header_record.header_record.vendor_site_id;
         invoice_record.error_record          := p_header_record.error_record;
         rcv_headers_interface_sv.validate_invoice_amount(invoice_record);
         p_header_record.error_record         := invoice_record.error_record;
         rcv_error_pkg.log_interface_message(p_header_record.error_record.error_status,
                                             'RCV_HEADERS_INTERFACE',
                                             'TOTAL_INVOICE_AMOUNT'
                                            );

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Validated invoice amount');
         END IF;
      END IF;

      /* Validate that both Invoice number and shipment number are not
         missing */
      IF     p_header_record.header_record.transaction_type <> 'CANCEL'
         AND p_header_record.header_record.asn_type = 'ASBN' THEN
         IF     p_header_record.header_record.shipment_num IS NULL
            AND -- Should we assign shipment_num to null.invoice_num
                p_header_record.header_record.invoice_num IS NULL THEN
            p_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
            rcv_error_pkg.set_error_message('RCV_ASBN_INVOICE_NUM', p_header_record.error_record.error_message);
         END IF;

         rcv_error_pkg.log_interface_message(p_header_record.error_record.error_status,
                                             'RCV_HEADERS_INTERFACE',
                                             'SHIPMENT_NUM'
                                            );

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Validated invoice number/shipment number are not missing');
         END IF;
      END IF;

      /* Validate invoice_date is not missing */

      /* bug 628316 make sure invoice_date is not missing for ASBN */
      IF     p_header_record.header_record.transaction_type <> 'CANCEL'
         AND p_header_record.header_record.asn_type = 'ASBN' THEN
         IF p_header_record.header_record.invoice_date IS NULL THEN
            p_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
            rcv_error_pkg.set_error_message('RCV_ASBN_INVOICE_DATE', p_header_record.error_record.error_message);
         END IF;

         rcv_error_pkg.log_interface_message(p_header_record.error_record.error_status,
                                             'RCV_HEADERS_INTERFACE',
                                             'INVOICE_DATE'
                                            );

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Validated invoice date is not missing');
         END IF;
      END IF;

      /* Validate Invoice Tax Code */
      IF     p_header_record.header_record.transaction_type <> 'CANCEL'
         AND p_header_record.header_record.asn_type = 'ASBN' THEN
         IF p_header_record.header_record.tax_name IS NOT NULL THEN
            tax_record.tax_name           := p_header_record.header_record.tax_name;
            tax_record.tax_amount         := p_header_record.header_record.tax_amount;
            tax_record.error_record       := p_header_record.error_record;
            po_locations_s.validate_tax_info(tax_record);

            IF tax_record.error_record.error_message IN('TAX_CODE_INVALID', 'TAX_CODE_DISABLED') THEN
               rcv_error_pkg.set_error_message('PO_PDOI_INVALID_TAX_NAME', tax_record.error_record.error_message);
               rcv_error_pkg.set_token('VALUE', tax_record.tax_name);
            ELSIF tax_record.error_record.error_status <> rcv_error_pkg.g_ret_sts_success THEN
               rcv_error_pkg.set_error_message(tax_record.error_record.error_message, tax_record.error_record.error_message); -- to set any other errors
            END IF;

            p_header_record.error_record  := tax_record.error_record;
            rcv_error_pkg.log_interface_message(p_header_record.error_record.error_status,
                                                'RCV_HEADERS_INTERFACE',
                                                'TAX_NAME'
                                               );
         END IF;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Validated tax info');
         END IF;
      END IF;

      /* Validations on shipment number */
      rcv_core_s.validate_shipment_number(p_header_record);
      rcv_error_pkg.log_interface_message(p_header_record.error_record.error_status,
                                          'RCV_HEADERS_INTERFACE',
                                          'SHIPMENT_NUM'
                                         );

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Validations for shipment_number ' || p_header_record.header_record.shipment_num);
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
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Other Validations');
      END IF;
   EXCEPTION
      WHEN rcv_error_pkg.e_fatal_error THEN
         NULL;
   END validate_shipment_header;

   PROCEDURE validate_invoice_amount(
      p_inv_rec IN OUT NOCOPY rcv_shipment_header_sv.invrectype
   ) IS
      CURSOR c IS
         SELECT invoice_amount_limit
         FROM   po_vendor_sites_all --Bug 5219141 Replace po_vendor_sites by po_vendor_sites_all
         WHERE  po_vendor_sites_all.vendor_site_id = p_inv_rec.vendor_site_id
         AND    po_vendor_sites_all.vendor_id = p_inv_rec.vendor_id;

      x_inv_rec c%ROWTYPE;
   BEGIN
      /*Commenting out the following check because if this is called
        from the web supliers, the amount will be null. This amount is
        explicitly calculated before creating the invoice header .*/
      IF p_inv_rec.vendor_site_id IS NOT NULL THEN
         OPEN c;
         FETCH c INTO x_inv_rec;

         IF NVL(x_inv_rec.invoice_amount_limit, 0) > 0 THEN
            IF x_inv_rec.invoice_amount_limit < p_inv_rec.total_invoice_amount THEN
               p_inv_rec.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
               rcv_error_pkg.set_error_message('RCV_ASBN_INVOICE_AMT_LIMIT', p_inv_rec.error_record.error_message);
               rcv_error_pkg.set_token('AMOUNT', p_inv_rec.total_invoice_amount);
            END IF;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         rcv_error_pkg.set_sql_error_message('validate_invoice_amount', '000');
         p_inv_rec.error_record.error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
         p_inv_rec.error_record.error_message  := rcv_error_pkg.get_last_message;
   END validate_invoice_amount;

   PROCEDURE insert_shipment_header(
      p_header_record IN OUT NOCOPY rcv_shipment_header_sv.headerrectype
   ) IS
   BEGIN
      -- Set asn_type to null if asn_type is STD as the UI gets confused

      IF NVL(p_header_record.header_record.asn_type, 'STD') = 'STD' THEN
         p_header_record.header_record.asn_type  := NULL;
      END IF;

      /* Bug - 1086088 - Ship_to_org_id needs to get populated in the
      *  RCV_SHIPMENT_HEADERS table      */
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
                   ship_from_location_id
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
                   NULL, -- p_header_record.header_record.Asn_Status
                   p_header_record.header_record.currency_code,
                   p_header_record.header_record.conversion_rate_type,
                   p_header_record.header_record.conversion_rate,
                   p_header_record.header_record.conversion_rate_date,
                   p_header_record.header_record.payment_terms_id,
                   p_header_record.header_record.invoice_num,
                   p_header_record.header_record.ship_from_location_id
                  );
   EXCEPTION
      WHEN OTHERS THEN
         rcv_error_pkg.set_sql_error_message('insert_shipment_header', '000');
         p_header_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
         p_header_record.error_record.error_message  := rcv_error_pkg.get_last_message;
   END insert_shipment_header;

/*===========================================================================+
 |                                                                           |
 | PROCEDURE NAME:          derive_ship_to_org_from_rti()                    |
 |                                                                           |
 +===========================================================================*/
   PROCEDURE derive_ship_to_org_from_rti(
      p_header_record IN OUT NOCOPY rcv_shipment_header_sv.headerrectype
   ) IS
      x_header_interface_id  NUMBER;
      x_to_organization_code VARCHAR2(3);
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

        /* Bug#	3924530 FP from 11i9 fix. Replaced the sql statement below with a
         * new one where we select the organization_code from table MTL_PARAMETERS
         * instead of the expensive nonmergible view ORG_ORGANIZATION_DEFINITIONS.

         SELECT MAX(org.organization_code)
         INTO   x_to_organization_code
         FROM   rcv_transactions_interface rti,
                hr_locations hl,
                org_organization_definitions org
         WHERE  rti.header_interface_id = x_header_interface_id
         AND    (   rti.ship_to_location_code = hl.location_code
                 OR rti.ship_to_location_id = hl.location_id)
         AND    hl.inventory_organization_id = org.organization_id;*/

         SELECT MAX(MTL.ORGANIZATION_CODE)
         INTO   X_TO_ORGANIZATION_CODE
         FROM   RCV_TRANSACTIONS_INTERFACE RTI,
                 HR_LOCATIONS_ALL HL, --BUG 5219141 Replaced HR_LOCATIONS
                 MTL_PARAMETERS MTL
         WHERE  RTI.HEADER_INTERFACE_ID = X_HEADER_INTERFACE_ID
         AND    (RTI.SHIP_TO_LOCATION_CODE = HL.LOCATION_CODE
                  OR RTI.SHIP_TO_LOCATION_ID = HL.LOCATION_ID)
         AND    HL.INVENTORY_ORGANIZATION_ID = MTL.ORGANIZATION_ID;
      END IF;

      IF (    p_header_record.header_record.ship_to_organization_code IS NULL
          AND p_header_record.header_record.ship_to_organization_id IS NULL) THEN
         IF (x_to_organization_code IS NOT NULL) THEN
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('A ship to location relating to an org was found');
            END IF;

            p_header_record.header_record.ship_to_organization_code  := x_to_organization_code;
         ELSE
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('A ship to location relating to an org was NOT found');
               asn_debug.put_line('This will cause an ERROR later');
            END IF;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         rcv_error_pkg.set_sql_error_message('insert_shipment_header', '000');
         p_header_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
         p_header_record.error_record.error_message  := rcv_error_pkg.get_last_message;
   END derive_ship_to_org_from_rti;

/* ksareddy - 2506961 - need to support automatic receipt in parallel processing
         lock and release the rcv_parameters table only to get the receipt number
*/
   PROCEDURE genreceiptnum(
      p_header_record IN OUT NOCOPY rcv_shipment_header_sv.headerrectype
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
END rcv_headers_interface_sv;

/
