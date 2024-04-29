--------------------------------------------------------
--  DDL for Package Body RCV_RMA_HEADERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_RMA_HEADERS" 
/* $Header: RCVRMAHB.pls 120.3.12010000.2 2010/01/25 23:23:26 vthevark ship $ */
AS
   -- Read the profile option that enables/disables the debug log
   g_asn_debug VARCHAR2(1) := asn_debug.is_debug_on; -- Bug 9152790

/*===========================================================================+
 |                                                                           |
 | PROCEDURE NAME:          derive_rma_header()                              |
 |                                                                           |
 +===========================================================================*/
   PROCEDURE derive_rma_header(
      p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('In derive_rma_header');
      END IF;

      rcv_roi_header_common.derive_ship_to_org_info(p_header_record);
      rcv_roi_header_common.derive_from_org_info(p_header_record);
      rcv_roi_header_common.derive_location_info(p_header_record);
      rcv_roi_header_common.derive_payment_terms_info(p_header_record);
      rcv_roi_header_common.derive_receiver_info(p_header_record);
      derive_customer_info(p_header_record);
      derive_customer_site_info(p_header_record);

      IF (g_asn_debug = 'Y') THEN
         IF (p_header_record.error_record.error_status NOT IN('S', 'W')) THEN
            asn_debug.put_line('Error in derive_rma_header');
            asn_debug.put_line('status = ' || p_header_record.error_record.error_status);
            asn_debug.put_line('message = ' || p_header_record.error_record.error_message);
         END IF;

         asn_debug.put_line('Done derive_rma_header');
      END IF;
   END derive_rma_header;

/*===========================================================================+
 |                                                                           |
 | PROCEDURE NAME:          default_rma_header()                             |
 |                                                                           |
 +===========================================================================*/
   PROCEDURE default_rma_header(
      p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('In default_rma_header');
      END IF;

      default_customer_info(p_header_record);
      default_customer_site_info(p_header_record);
      default_trx_info(p_header_record);
      rcv_roi_header_common.default_last_update_info(p_header_record);
      rcv_roi_header_common.default_creation_info(p_header_record);
      rcv_roi_header_common.default_asn_type(p_header_record);
      default_shipment_num(p_header_record);
      rcv_roi_header_common.default_shipment_header_id(p_header_record);
      rcv_roi_header_common.default_receipt_info(p_header_record);
      rcv_roi_header_common.default_ship_to_location_info(p_header_record);

      IF (g_asn_debug = 'Y') THEN
         IF (p_header_record.error_record.error_status NOT IN('S', 'W')) THEN
            asn_debug.put_line('Error in default_rma_header');
            asn_debug.put_line('status = ' || p_header_record.error_record.error_status);
            asn_debug.put_line('message = ' || p_header_record.error_record.error_message);
         END IF;

         asn_debug.put_line('Out of default_rma_header');
      END IF;
   END default_rma_header;

/*===========================================================================+
 |                                                                           |
 | PROCEDURE NAME:          validate_rma_header()                            |
 |                                                                           |
 +===========================================================================*/
   PROCEDURE validate_rma_header(
      p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('In validate_rma_header');
      END IF;

      validate_receipt_source_code(p_header_record);
      validate_customer_info(p_header_record);
      validate_customer_site_info(p_header_record);
      rcv_roi_header_common.validate_trx_type(p_header_record);
      rcv_roi_header_common.validate_expected_receipt_date(p_header_record);
      rcv_roi_header_common.validate_receipt_num(p_header_record);
      rcv_roi_header_common.validate_ship_to_org_info(p_header_record);
      rcv_roi_header_common.validate_from_org_info(p_header_record);
      rcv_roi_header_common.validate_location_info(p_header_record);
      rcv_roi_header_common.validate_payment_terms_info(p_header_record);
      rcv_roi_header_common.validate_receiver_info(p_header_record);
      rcv_roi_header_common.validate_freight_carrier_info(p_header_record);

      IF (g_asn_debug = 'Y') THEN
         IF (p_header_record.error_record.error_status NOT IN('S', 'W')) THEN
            asn_debug.put_line('Error in validate_rma_header');
            asn_debug.put_line('status = ' || p_header_record.error_record.error_status);
            asn_debug.put_line('message = ' || p_header_record.error_record.error_message);
         END IF;

         asn_debug.put_line('Out of validate_rma_header');
      END IF;
   END validate_rma_header;

   PROCEDURE insert_rma_header(
      p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
   ) IS
      x_sysdate         DATE           := SYSDATE;
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
                   customer_id,
                   customer_site_id,
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
                   p_header_record.header_record.ship_to_organization_id,
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
                   p_header_record.header_record.customer_id,
                   p_header_record.header_record.customer_site_id,
                   p_header_record.header_record.ship_from_location_id
                  );
   EXCEPTION
      WHEN OTHERS THEN
         rcv_error_pkg.set_sql_error_message('insert_rma_header', '000');
         p_header_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
         p_header_record.error_record.error_message  := rcv_error_pkg.get_last_message;
   END insert_rma_header;

/* Private helper procedures */
   PROCEDURE derive_customer_info(
      p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      IF     p_header_record.error_record.error_status IN('S', 'W')
         AND p_header_record.header_record.customer_id IS NULL THEN
         -- derive customer name from customer id
         IF     p_header_record.header_record.customer_party_name IS NULL
            AND p_header_record.header_record.customer_id IS NOT NULL THEN
            SELECT party.party_name
            INTO   p_header_record.header_record.customer_party_name
            FROM   hz_parties party,
                   hz_cust_accounts acct
            WHERE  acct.party_id = party.party_id
            AND    acct.cust_account_id = p_header_record.header_record.customer_id;
         END IF;

               -- derive customer id from customer name and account number
         /* Bug 3648886.
          * The sql below had the where condition as
          * AND party.party_name = party_name
               * AND acct.account_number = account_number;
          * This needs to be
          * AND party.party_name = p_header_record.header_record.customer_party_name
               * AND acct.account_number = p_header_record.header_record.customer_account_number;
          * This will give error and also there was a performance problem.
         */
         IF     p_header_record.header_record.customer_id IS NULL
            AND p_header_record.header_record.customer_account_number IS NOT NULL
            AND p_header_record.header_record.customer_party_name IS NOT NULL THEN
            SELECT acct.cust_account_id
            INTO   p_header_record.header_record.customer_id
            FROM   hz_parties party,
                   hz_cust_accounts acct
            WHERE  party.party_id = acct.party_id
            AND    party.party_name = p_header_record.header_record.customer_party_name
            AND    acct.account_number = p_header_record.header_record.customer_account_number;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         rcv_error_pkg.set_sql_error_message('derive_customer_info', '000');
         p_header_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
         p_header_record.error_record.error_message  := rcv_error_pkg.get_last_message;
   END derive_customer_info;

   /* We do not insert customer_site_id now from forms */
   /* customer_site_id = from_org_id */
   PROCEDURE derive_customer_site_info(
      p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      NULL;
   END derive_customer_site_info;

   PROCEDURE default_customer_info(
      p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      NULL;
-- For RMA, we can default customer_id which is actually the cust_account_id in hz_cust_accounts.
-- If party_name is given and for that party_id, if there exists only one account_id in the accounts table
-- then we can default that value.
-- If both party_id and party_name is given, then we consider only party_id. If party_id has a wrong value but party_name has a correct value what do we do? Ask PM. In validate
-- we use all  the values for vendors .Do we need to do the same here also?
-- Then it does not make sense to use party_name since even if we derive it will fail validation later when we use both party_id and party_name value.


-- If (customer_id is null and (party_id is not null) then
--      select  count(*) into l_count
-- from hz_cust_accounts acct
-- where acct.party_id = acct.party_id;

-- If (l_count = 1) then  /* There is only one acct for this party hence default*/
--  select acct.cust_account_id
--  from hz_cust_accounts acct
--  where acct.party_id = party_id;
-- end if;
--  end if;

-- If (customer_id is null and (party_name is not null) then
--      select  count(*)
--      from hz_parties party, hz_cust_accounts acct
--      where acct.party_id = party.party_id and
-- party.party_name = party_name;

-- If (l_count = 1) then  /* There is only one acct for this party hence default*/
--  select acct.cust_account_id
--          from hz_parties party, hz_cust_accounts acct
--          where acct.party_id = party.party_id and
-- party.party_name = party_name;
-- end if;

--  end if;
   END default_customer_info;

   PROCEDURE default_customer_site_info(
      p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      IF (    p_header_record.header_record.customer_site_id IS NULL
          AND p_header_record.header_record.from_organization_id IS NOT NULL) THEN
         p_header_record.header_record.customer_site_id  := p_header_record.header_record.from_organization_id;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('defaulted customer_site_id');
         END IF;
      END IF;
   END default_customer_site_info;

   PROCEDURE default_trx_info(
      p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      IF p_header_record.header_record.transaction_type IS NULL THEN
         p_header_record.header_record.transaction_type  := 'NEW';

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('defaulted transaction_type');
         END IF;
      END IF;
   END default_trx_info;

   PROCEDURE default_shipment_num(
      p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      /* SHIPMENT NUMBER FOR ASBN/ASN if shipment_num IS NULL */
      /* First choice for ASN/ Second Choice for ASN */
      IF p_header_record.header_record.shipment_num IS NULL THEN
         p_header_record.header_record.shipment_num  := p_header_record.header_record.packing_slip;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('defaulted shipment number');
         END IF;
      END IF;
   END default_shipment_num;

   PROCEDURE validate_receipt_source_code(
      p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
-- validate that the receipt source code is CUSTOMER
-- and that the txn type and asn type makes sense
-- Do we need to do this?
      NULL;
   END validate_receipt_source_code;

   PROCEDURE validate_customer_info(
      p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
   ) IS
      l_status hz_cust_accounts.status%TYPE;
      l_validation_failed BOOLEAN;  /*Bug 4344351*/
   BEGIN
      l_validation_failed := FALSE;

      IF p_header_record.header_record.customer_id IS NOT NULL THEN

         SELECT status
         INTO   l_status
         FROM   hz_cust_accounts acct
         WHERE  acct.cust_account_id = p_header_record.header_record.customer_id;

         IF l_status <> 'A' THEN
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Customer status is not ACTIVE');
            END IF;
            l_validation_failed := TRUE;
         END IF;
      ELSE
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Customer_id is null in header record');
         END IF;

        -- Bug 4344351: The header record should be errored out if customer_id is null.
        l_validation_failed := TRUE;

      END IF;

      IF ( l_validation_failed ) THEN
         p_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
         rcv_error_pkg.set_error_message('PO_PDOI_DERV_ERROR', p_header_record.error_record.error_message);
         rcv_error_pkg.set_token('COLUMN_NAME', 'CUSTOMER_ID');
         rcv_error_pkg.set_token('VALUE', p_header_record.header_record.customer_id);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         rcv_error_pkg.set_sql_error_message('validate_customer_info', '000');
         /* Bug 4344351: Setting error staus to Error instead of Unexpected Error.
         **              This is to ensure that we error out rti and stop further processing.
         */
         p_header_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_error;
         p_header_record.error_record.error_message  := rcv_error_pkg.get_last_message;
   END validate_customer_info;

   PROCEDURE validate_customer_site_info(
      p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      NULL;
   END validate_customer_site_info;
END rcv_rma_headers;

/
