--------------------------------------------------------
--  DDL for Package Body OZF_RESALE_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_RESALE_LINES_PKG" as
/* $Header: ozftrslb.pls 120.1.12000000.2 2007/05/28 10:44:23 ateotia ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_RESALE_LINES_PKG
-- Purpose
--
-- History
-- Anuj Teotia              28/05/2007       bug # 5997978 fixed
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_RESALE_LINES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozftrslb.pls';


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createInsertBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Insert_Row(
          p_resale_line_id    NUMBER,
          p_resale_header_id    NUMBER,
          p_resale_transfer_type    VARCHAR2,
          px_object_version_number   IN OUT NOCOPY  NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_request_id    NUMBER,
          p_created_by    NUMBER,
          p_created_from    VARCHAR2,
          p_last_update_login    NUMBER,
          p_program_application_id    NUMBER,
          p_program_update_date    DATE,
          p_program_id    NUMBER,
          p_status_code    VARCHAR2,
          p_product_trans_movement_type    VARCHAR2,
          p_product_transfer_date    DATE,
          p_end_cust_party_id    NUMBER,
          p_end_cust_site_use_id    NUMBER,
          p_end_cust_site_use_code   VARCHAR2,
          p_end_cust_party_site_id    NUMBER,
          p_end_cust_party_name    VARCHAR2,
          p_end_cust_location    VARCHAR2,
          p_end_cust_address    VARCHAR2,
          p_end_cust_city    VARCHAR2,
          p_end_cust_state    VARCHAR2,
          p_end_cust_postal_code    VARCHAR2,
          p_end_cust_country    VARCHAR2,
          p_end_cust_contact_party_id    NUMBER,
	  p_end_cust_contact_name    VARCHAR2,
	  p_end_cust_email    VARCHAR2,
          p_end_cust_phone    VARCHAR2,
          p_end_cust_fax    VARCHAR2,
          p_bill_to_cust_account_id    NUMBER,
          p_bill_to_site_use_id    NUMBER,
          p_bill_to_PARTY_NAME    VARCHAR2,
          p_bill_to_PARTY_ID      NUMBER,
          p_bill_to_PARTY_site_id NUMBER,
          p_bill_to_duns_number     VARCHAR2,
	  p_bill_to_location    VARCHAR2,
          p_bill_to_address    VARCHAR2,
          p_bill_to_city    VARCHAR2,
          p_bill_to_state    VARCHAR2,
          p_bill_to_postal_code    VARCHAR2,
          p_bill_to_country    VARCHAR2,
          p_bill_to_contact_party_id    NUMBER,
          p_bill_to_contact_name    VARCHAR2,
          p_bill_to_email  VARCHAR2,
          p_bill_to_phone  VARCHAR2,
          p_bill_to_fax   VARCHAR2,
          p_ship_to_cust_account_id    NUMBER,
          p_ship_to_site_use_id    NUMBER,
          p_ship_to_PARTY_NAME    VARCHAR2,
          p_ship_to_PARTY_ID      NUMBER,
          p_ship_to_PARTY_site_id NUMBER,
          p_ship_to_duns_number     VARCHAR2,
          p_ship_to_location    VARCHAR2,
          p_ship_to_address    VARCHAR2,
          p_ship_to_city    VARCHAR2,
          p_ship_to_state    VARCHAR2,
          p_ship_to_postal_code    VARCHAR2,
          p_ship_to_country    VARCHAR2,
          p_ship_to_contact_party_id    NUMBER,
          p_ship_to_contact_name    VARCHAR2,
          p_ship_to_email  VARCHAR2,
          p_ship_to_phone  VARCHAR2,
          p_ship_to_fax   VARCHAR2,
          p_ship_from_cust_account_id    NUMBER,
          p_ship_from_site_id    NUMBER,
          p_ship_from_PARTY_NAME    VARCHAR2,
          p_ship_from_location    VARCHAR2,
          p_ship_from_address    VARCHAR2,
          p_ship_from_city    VARCHAR2,
          p_ship_from_state    VARCHAR2,
          p_ship_from_postal_code    VARCHAR2,
          p_ship_from_country    VARCHAR2,
          p_ship_from_contact_party_id    NUMBER,
          p_ship_from_contact_name    VARCHAR2,
          p_ship_from_email  VARCHAR2,
          p_ship_from_phone  VARCHAR2,
          p_ship_from_fax   VARCHAR2,
          p_sold_from_cust_account_id    NUMBER,
          p_sold_from_site_id    NUMBER,
          p_sold_from_PARTY_NAME    VARCHAR2,
          p_sold_from_location    VARCHAR2,
          p_sold_from_address    VARCHAR2,
          p_sold_from_city    VARCHAR2,
          p_sold_from_state    VARCHAR2,
          p_sold_from_postal_code    VARCHAR2,
          p_sold_from_country    VARCHAR2,
          p_sold_from_contact_party_id    NUMBER,
          p_sold_from_contact_name    VARCHAR2,
          p_sold_from_email  VARCHAR2,
          p_sold_from_phone  VARCHAR2,
          p_sold_from_fax   VARCHAR2,
          p_price_list_id    NUMBER,
          p_price_list_name    VARCHAR2,
          p_invoice_number    VARCHAR2,
          p_date_invoiced   DATE,
          p_po_number    VARCHAR2,
          p_po_release_number    VARCHAR2,
          p_po_type    VARCHAR2,
          p_order_number    VARCHAR2,
          p_date_ordered    DATE,
          p_date_shipped    DATE,
	  p_purchase_uom_code    VARCHAR2,
          p_quantity    NUMBER,
          p_uom_code    VARCHAR2,
          p_currency_code    VARCHAR2,
          p_exchange_rate    NUMBER,
          p_exchange_rate_type    VARCHAR2,
          p_exchange_rate_date    DATE,
          p_selling_price    NUMBER,
          p_acctd_selling_price    NUMBER,
          p_purchase_price    NUMBER,
          p_acctd_purchase_price    NUMBER,
	  p_tracing_flag     VARCHAR2,
          p_orig_system_quantity    NUMBER,
          p_orig_system_uom    VARCHAR2,
          p_orig_system_currency_code    VARCHAR2,
          p_orig_system_selling_price    NUMBER,
          p_orig_system_reference    VARCHAR2,
          p_orig_system_line_reference    VARCHAR2,
	  p_orig_system_purchase_uom  varchar2,
	  p_orig_system_purchase_curr      VARCHAR2,
          p_orig_system_purchase_price      NUMBER,
          p_orig_system_purchase_quant   NUMBER,
          p_orig_system_item_number  varchar2,
          p_product_category_id    NUMBER,
          p_category_name    VARCHAR2,
          p_inventory_item_segment1    VARCHAR2,
          p_inventory_item_segment2    VARCHAR2,
          p_inventory_item_segment3    VARCHAR2,
          p_inventory_item_segment4    VARCHAR2,
          p_inventory_item_segment5    VARCHAR2,
          p_inventory_item_segment6    VARCHAR2,
          p_inventory_item_segment7    VARCHAR2,
          p_inventory_item_segment8    VARCHAR2,
          p_inventory_item_segment9    VARCHAR2,
          p_inventory_item_segment10    VARCHAR2,
          p_inventory_item_segment11    VARCHAR2,
          p_inventory_item_segment12    VARCHAR2,
          p_inventory_item_segment13    VARCHAR2,
          p_inventory_item_segment14    VARCHAR2,
          p_inventory_item_segment15    VARCHAR2,
          p_inventory_item_segment16    VARCHAR2,
          p_inventory_item_segment17    VARCHAR2,
          p_inventory_item_segment18    VARCHAR2,
          p_inventory_item_segment19    VARCHAR2,
          p_inventory_item_segment20    VARCHAR2,
          p_inventory_item_id    NUMBER,
          p_item_description    VARCHAR2,
          p_upc_code    VARCHAR2,
          p_item_number    VARCHAR2,
          p_direct_customer_flag    VARCHAR2,
          p_attribute_category    VARCHAR2,
          p_attribute1    VARCHAR2,
          p_attribute2    VARCHAR2,
          p_attribute3    VARCHAR2,
          p_attribute4    VARCHAR2,
          p_attribute5    VARCHAR2,
          p_attribute6    VARCHAR2,
          p_attribute7    VARCHAR2,
          p_attribute8    VARCHAR2,
          p_attribute9    VARCHAR2,
          p_attribute10    VARCHAR2,
          p_attribute11    VARCHAR2,
          p_attribute12    VARCHAR2,
          p_attribute13    VARCHAR2,
          p_attribute14    VARCHAR2,
          p_attribute15    VARCHAR2,
          p_line_attribute_category    VARCHAR2,
          p_line_attribute1    VARCHAR2,
          p_line_attribute2    VARCHAR2,
          p_line_attribute3    VARCHAR2,
          p_line_attribute4    VARCHAR2,
          p_line_attribute5    VARCHAR2,
          p_line_attribute6    VARCHAR2,
          p_line_attribute7    VARCHAR2,
          p_line_attribute8    VARCHAR2,
          p_line_attribute9    VARCHAR2,
          p_line_attribute10    VARCHAR2,
          p_line_attribute11    VARCHAR2,
          p_line_attribute12    VARCHAR2,
          p_line_attribute13    VARCHAR2,
          p_line_attribute14    VARCHAR2,
          p_line_attribute15    VARCHAR2,
          px_org_id   IN OUT NOCOPY  NUMBER)

 IS
   x_rowid    VARCHAR2(30);
   l_batch_org_id NUMBER; -- bug # 5997978 fixed


BEGIN
   -- Start: bug # 5997978 fixed
   IF px_org_id IS NULL THEN
      OPEN OZF_RESALE_COMMON_PVT.g_resale_header_org_id_csr(p_resale_header_id);
      FETCH OZF_RESALE_COMMON_PVT.g_resale_header_org_id_csr INTO l_batch_org_id;
      CLOSE OZF_RESALE_COMMON_PVT.g_resale_header_org_id_csr;
      px_org_id := MO_GLOBAL.get_valid_org(l_batch_org_id);
      IF (l_batch_org_id IS NULL OR px_org_id IS NULL) THEN
         OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_ORG_ID_NOTFOUND');
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      /* IF (px_org_id IS NULL OR px_org_id = FND_API.G_MISS_NUM) THEN
      SELECT NVL(SUBSTRB(USERENV('CLIENT_INFO'),1,10),-99)
      INTO px_org_id
      FROM DUAL;*/
   END IF;
   -- End: bug # 5997978 fixed


   px_object_version_number := 1;


   INSERT INTO OZF_RESALE_LINES_ALL(
           resale_line_id,
           resale_header_id,
           resale_transfer_type,
           object_version_number,
           last_update_date,
           last_updated_by,
           creation_date,
           request_id,
           created_by,
           created_from,
           last_update_login,
           program_application_id,
           program_update_date,
           program_id,
           status_code,
           product_transfer_movement_type,
           product_transfer_date,
           end_cust_party_id,
           end_cust_site_use_id,
	   end_cust_site_use_code,
           end_cust_party_site_id,
           end_cust_party_name,
           end_cust_location,
           end_cust_address,
           end_cust_city,
           end_cust_state,
           end_cust_postal_code,
           end_cust_country,
           end_cust_contact_party_id,
	   end_cust_contact_name,
           end_cust_email,
           end_cust_phone,
           end_cust_fax,
           bill_to_cust_account_id,
           bill_to_site_use_id,
           bill_to_PARTY_NAME,
	   bill_to_PARTY_ID,
           bill_to_PARTY_site_id,
           bill_to_duns_number,
           bill_to_location,
           bill_to_address,
           bill_to_city,
           bill_to_state,
           bill_to_postal_code,
           bill_to_country,
           bill_to_contact_party_id,
           bill_to_contact_name,
           bill_to_email,
           bill_to_phone,
           bill_to_fax,
           ship_to_cust_account_id,
           ship_to_site_use_id,
           ship_to_PARTY_NAME,
	   ship_to_PARTY_ID,
           ship_to_PARTY_site_id,
           ship_to_duns_number,
           ship_to_location,
           ship_to_address,
           ship_to_city,
           ship_to_state,
           ship_to_postal_code,
           ship_to_country,
           ship_to_contact_party_id,
           ship_to_contact_name,
           ship_to_email,
           ship_to_phone,
           ship_to_fax,
           ship_from_cust_account_id,
           ship_from_site_id,
           ship_from_PARTY_NAME,
           ship_from_location,
           ship_from_address,
           ship_from_city,
           ship_from_state,
           ship_from_postal_code,
           ship_from_country,
           ship_from_contact_party_id,
	   ship_from_contact_name,
           ship_from_email,
           ship_from_phone,
           ship_from_fax,
           sold_from_cust_account_id,
           sold_from_site_id,
           sold_from_PARTY_NAME,
           sold_from_location,
           sold_from_address,
           sold_from_city,
           sold_from_state,
           sold_from_postal_code,
           sold_from_country,
           sold_from_contact_party_id,
           sold_from_contact_name,
           sold_from_email,
           sold_from_phone,
           sold_from_fax,
           price_list_id,
           price_list_name,
           invoice_number,
           date_invoiced,
           po_number,
           po_release_number,
           po_type,
           order_number,
           date_ordered,
           date_shipped,
           purchase_uom_code,
           quantity,
           uom_code,
           currency_code,
           exchange_rate,
           exchange_rate_type,
           exchange_rate_date,
           selling_price,
           acctd_selling_price,
           purchase_price,
           acctd_purchase_price,
	   tracing_flag,
           orig_system_quantity,
           orig_system_uom,
           orig_system_currency_code,
           orig_system_selling_price,
           orig_system_reference,
	   orig_system_line_reference,
	   orig_system_purchase_uom,
	   orig_system_purchase_curr,
           orig_system_purchase_price,
           orig_system_purchase_quantity,
	   orig_system_item_number,
           product_category_id,
           category_name,
           inventory_item_segment1,
           inventory_item_segment2,
           inventory_item_segment3,
           inventory_item_segment4,
           inventory_item_segment5,
           inventory_item_segment6,
           inventory_item_segment7,
           inventory_item_segment8,
           inventory_item_segment9,
           inventory_item_segment10,
           inventory_item_segment11,
           inventory_item_segment12,
           inventory_item_segment13,
           inventory_item_segment14,
           inventory_item_segment15,
           inventory_item_segment16,
           inventory_item_segment17,
           inventory_item_segment18,
           inventory_item_segment19,
           inventory_item_segment20,
           inventory_item_id,
           item_description,
           upc_code,
           item_number,
           direct_customer_flag,
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
           line_attribute_category,
           line_attribute1,
           line_attribute2,
           line_attribute3,
           line_attribute4,
           line_attribute5,
           line_attribute6,
           line_attribute7,
           line_attribute8,
           line_attribute9,
           line_attribute10,
           line_attribute11,
           line_attribute12,
           line_attribute13,
           line_attribute14,
           line_attribute15,
           org_id
   ) VALUES (
           p_resale_line_id,
           p_resale_header_id,
           p_resale_transfer_type,
           px_object_version_number,
           p_last_update_date,
           p_last_updated_by,
           p_creation_date,
           p_request_id,
           p_created_by,
           p_created_from,
           p_last_update_login,
           p_program_application_id,
           p_program_update_date,
           p_program_id,
           p_status_code,
           p_product_trans_movement_type,
           p_product_transfer_date,
           p_end_cust_party_id,
           p_end_cust_site_use_id,
           p_end_cust_site_use_code,
           p_end_cust_party_site_id,
           p_end_cust_party_name,
           p_end_cust_location,
           p_end_cust_address,
           p_end_cust_city,
           p_end_cust_state,
           p_end_cust_postal_code,
           p_end_cust_country,
           p_end_cust_contact_party_id,
           p_end_cust_contact_name,
           p_end_cust_email,
           p_end_cust_phone,
           p_end_cust_fax,
	   p_bill_to_cust_account_id,
           p_bill_to_site_use_id,
           p_bill_to_PARTY_NAME,
           p_bill_to_PARTY_ID,
           p_bill_to_PARTY_site_id,
           p_bill_to_duns_number,
	   p_bill_to_location,
           p_bill_to_address,
           p_bill_to_city,
           p_bill_to_state,
           p_bill_to_postal_code,
           p_bill_to_country,
           p_bill_to_contact_party_id,
           p_bill_to_contact_name,
	   p_bill_to_email,
           p_bill_to_phone,
           p_bill_to_fax,
           p_ship_to_cust_account_id,
           p_ship_to_site_use_id,
           p_ship_to_PARTY_NAME,
           p_ship_to_PARTY_ID,
           p_ship_to_PARTY_site_id,
           p_ship_to_duns_number,
           p_ship_to_location,
           p_ship_to_address,
           p_ship_to_city,
           p_ship_to_state,
           p_ship_to_postal_code,
           p_ship_to_country,
           p_ship_to_contact_party_id,
           p_ship_to_contact_name,
	   p_ship_to_email,
           p_ship_to_phone,
           p_ship_to_fax,
           p_ship_from_cust_account_id,
           p_ship_from_site_id,
           p_ship_from_PARTY_NAME,
	   p_ship_from_location,
           p_ship_from_address,
           p_ship_from_city,
           p_ship_from_state,
           p_ship_from_postal_code,
           p_ship_from_country,
           p_ship_from_contact_party_id,
           p_ship_from_contact_name,
	   p_ship_from_email,
           p_ship_from_phone,
           p_ship_from_fax,
           p_sold_from_cust_account_id,
           p_sold_from_site_id,
           p_sold_from_PARTY_NAME,
           p_sold_from_location,
           p_sold_from_address,
           p_sold_from_city,
           p_sold_from_state,
           p_sold_from_postal_code,
           p_sold_from_country,
           p_sold_from_contact_party_id,
           p_sold_from_contact_name,
	   p_sold_from_email,
           p_sold_from_phone,
           p_sold_from_fax,
	   p_price_list_id,
           p_price_list_name,
           p_invoice_number,
           p_date_invoiced,
           p_po_number,
           p_po_release_number,
           p_po_type,
           p_order_number,
           p_date_ordered,
           p_date_shipped,
	   p_purchase_uom_code,
           p_quantity,
           p_uom_code,
           p_currency_code,
           p_exchange_rate,
           p_exchange_rate_type,
           p_exchange_rate_date,
           p_selling_price,
           p_acctd_selling_price,
	   p_purchase_price,
	   p_acctd_purchase_price,
           p_tracing_flag,
	   p_orig_system_quantity,
           p_orig_system_uom,
           p_orig_system_currency_code,
           p_orig_system_selling_price,
	   p_orig_system_reference,
           p_orig_system_line_reference,
	   p_orig_system_purchase_uom,
	   p_orig_system_purchase_curr,
           p_orig_system_purchase_price,
           p_orig_system_purchase_quant,
           p_orig_system_item_number,
           p_product_category_id,
           p_category_name,
           p_inventory_item_segment1,
           p_inventory_item_segment2,
           p_inventory_item_segment3,
           p_inventory_item_segment4,
           p_inventory_item_segment5,
           p_inventory_item_segment6,
           p_inventory_item_segment7,
           p_inventory_item_segment8,
           p_inventory_item_segment9,
           p_inventory_item_segment10,
           p_inventory_item_segment11,
           p_inventory_item_segment12,
           p_inventory_item_segment13,
           p_inventory_item_segment14,
           p_inventory_item_segment15,
           p_inventory_item_segment16,
           p_inventory_item_segment17,
           p_inventory_item_segment18,
           p_inventory_item_segment19,
           p_inventory_item_segment20,
           p_inventory_item_id,
           p_item_description,
           p_upc_code,
           p_item_number,
           p_direct_customer_flag,
           p_attribute_category,
           p_attribute1,
           p_attribute2,
           p_attribute3,
           p_attribute4,
           p_attribute5,
           p_attribute6,
           p_attribute7,
           p_attribute8,
           p_attribute9,
           p_attribute10,
           p_attribute11,
           p_attribute12,
           p_attribute13,
           p_attribute14,
           p_attribute15,
           p_line_attribute_category,
           p_line_attribute1,
           p_line_attribute2,
           p_line_attribute3,
           p_line_attribute4,
           p_line_attribute5,
           p_line_attribute6,
           p_line_attribute7,
           p_line_attribute8,
           p_line_attribute9,
           p_line_attribute10,
           p_line_attribute11,
           p_line_attribute12,
           p_line_attribute13,
           p_line_attribute14,
           p_line_attribute15,
           px_org_id);
END Insert_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createUpdateBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Row(
          p_resale_line_id    NUMBER,
          p_resale_header_id    NUMBER,
          p_resale_transfer_type    VARCHAR2,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_request_id    NUMBER,
          p_created_from    VARCHAR2,
          p_last_update_login    NUMBER,
          p_program_application_id    NUMBER,
          p_program_update_date    DATE,
          p_program_id    NUMBER,
          p_status_code    VARCHAR2,
          p_product_trans_movement_type    VARCHAR2,
          p_product_transfer_date    DATE,
          p_end_cust_party_id    NUMBER,
          p_end_cust_site_use_id    NUMBER,
          p_end_cust_site_use_code   VARCHAR2,
          p_end_cust_party_site_id    NUMBER,
          p_end_cust_party_name    VARCHAR2,
          p_end_cust_location    VARCHAR2,
          p_end_cust_address    VARCHAR2,
          p_end_cust_city    VARCHAR2,
          p_end_cust_state    VARCHAR2,
          p_end_cust_postal_code    VARCHAR2,
          p_end_cust_country    VARCHAR2,
          p_end_cust_contact_party_id   NUMBER,
          p_end_cust_contact_name    VARCHAR2,
	  p_end_cust_email    VARCHAR2,
          p_end_cust_phone    VARCHAR2,
          p_end_cust_fax    VARCHAR2,
          p_bill_to_cust_account_id    NUMBER,
          p_bill_to_site_use_id    NUMBER,
          p_bill_to_PARTY_NAME    VARCHAR2,
	  p_bill_to_PARTY_ID      NUMBER,
          p_bill_to_PARTY_site_id NUMBER,
          p_bill_to_duns_number     VARCHAR2,
          p_bill_to_location    VARCHAR2,
          p_bill_to_address    VARCHAR2,
          p_bill_to_city    VARCHAR2,
          p_bill_to_state    VARCHAR2,
          p_bill_to_postal_code    VARCHAR2,
          p_bill_to_country    VARCHAR2,
          p_bill_to_contact_party_id   NUMBER,
          p_bill_to_contact_name    VARCHAR2,
	  p_bill_to_email  VARCHAR2,
          p_bill_to_phone  VARCHAR2,
          p_bill_to_fax   VARCHAR2,
          p_ship_to_cust_account_id    NUMBER,
          p_ship_to_site_use_id    NUMBER,
          p_ship_to_PARTY_NAME    VARCHAR2,
          p_ship_to_PARTY_ID      NUMBER,
          p_ship_to_PARTY_site_id NUMBER,
          p_ship_to_duns_number     VARCHAR2,
          p_ship_to_location    VARCHAR2,
          p_ship_to_address    VARCHAR2,
          p_ship_to_city    VARCHAR2,
          p_ship_to_state    VARCHAR2,
          p_ship_to_postal_code    VARCHAR2,
          p_ship_to_country    VARCHAR2,
          p_ship_to_contact_party_id  number,
          p_ship_to_contact_name    VARCHAR2,
	  p_ship_to_email  VARCHAR2,
          p_ship_to_phone  VARCHAR2,
          p_ship_to_fax   VARCHAR2,
          p_ship_from_cust_account_id    NUMBER,
          p_ship_from_site_id    NUMBER,
          p_ship_from_PARTY_NAME    VARCHAR2,
          p_ship_from_location    VARCHAR2,
          p_ship_from_address    VARCHAR2,
          p_ship_from_city    VARCHAR2,
          p_ship_from_state    VARCHAR2,
          p_ship_from_postal_code    VARCHAR2,
          p_ship_from_country    VARCHAR2,
          p_ship_from_contact_party_id   NUMBER,
          p_ship_from_contact_name    VARCHAR2,
	  p_ship_from_email  VARCHAR2,
          p_ship_from_phone  VARCHAR2,
          p_ship_from_fax   VARCHAR2,
          p_sold_from_cust_account_id    NUMBER,
          p_sold_from_site_id    NUMBER,
          p_sold_from_PARTY_NAME    VARCHAR2,
          p_sold_from_location    VARCHAR2,
          p_sold_from_address    VARCHAR2,
          p_sold_from_city    VARCHAR2,
          p_sold_from_state    VARCHAR2,
          p_sold_from_postal_code    VARCHAR2,
          p_sold_from_country    VARCHAR2,
          p_sold_from_contact_party_id number,
          p_sold_from_contact_name    VARCHAR2,
	  p_sold_from_email  VARCHAR2,
          p_sold_from_phone  VARCHAR2,
          p_sold_from_fax   VARCHAR2,
          p_price_list_id    NUMBER,
          p_price_list_name    VARCHAR2,
          p_invoice_number    VARCHAR2,
          p_date_invoiced   DATE,
          p_po_number    VARCHAR2,
          p_po_release_number    VARCHAR2,
          p_po_type    VARCHAR2,
          p_order_number    VARCHAR2,
          p_date_ordered    DATE,
          p_date_shipped    DATE,
	  p_purchase_uom_code    VARCHAR2,
          p_quantity    NUMBER,
          p_uom_code    VARCHAR2,
          p_currency_code    VARCHAR2,
          p_exchange_rate    NUMBER,
          p_exchange_rate_type    VARCHAR2,
          p_exchange_rate_date    DATE,
          p_selling_price    NUMBER,
          p_acctd_selling_price    NUMBER,
          p_purchase_price    NUMBER,
          p_acctd_purchase_price    NUMBER,
	  p_tracing_flag     VARCHAR2,
          p_orig_system_quantity    NUMBER,
          p_orig_system_uom    VARCHAR2,
          p_orig_system_currency_code    VARCHAR2,
          p_orig_system_selling_price    NUMBER,
          p_orig_system_reference    VARCHAR2,
          p_orig_system_line_reference    VARCHAR2,
	  p_orig_system_purchase_uom  varchar2,
	  p_orig_system_purchase_curr      VARCHAR2,
          p_orig_system_purchase_price      NUMBER,
          p_orig_system_purchase_quant   NUMBER,
          p_orig_system_item_number  varchar2,
          p_product_category_id    NUMBER,
          p_category_name    VARCHAR2,
          p_inventory_item_segment1    VARCHAR2,
          p_inventory_item_segment2    VARCHAR2,
          p_inventory_item_segment3    VARCHAR2,
          p_inventory_item_segment4    VARCHAR2,
          p_inventory_item_segment5    VARCHAR2,
          p_inventory_item_segment6    VARCHAR2,
          p_inventory_item_segment7    VARCHAR2,
          p_inventory_item_segment8    VARCHAR2,
          p_inventory_item_segment9    VARCHAR2,
          p_inventory_item_segment10    VARCHAR2,
          p_inventory_item_segment11    VARCHAR2,
          p_inventory_item_segment12    VARCHAR2,
          p_inventory_item_segment13    VARCHAR2,
          p_inventory_item_segment14    VARCHAR2,
          p_inventory_item_segment15    VARCHAR2,
          p_inventory_item_segment16    VARCHAR2,
          p_inventory_item_segment17    VARCHAR2,
          p_inventory_item_segment18    VARCHAR2,
          p_inventory_item_segment19    VARCHAR2,
          p_inventory_item_segment20    VARCHAR2,
          p_inventory_item_id    NUMBER,
          p_item_description    VARCHAR2,
          p_upc_code    VARCHAR2,
          p_item_number    VARCHAR2,
          p_direct_customer_flag    VARCHAR2,
          p_attribute_category    VARCHAR2,
          p_attribute1    VARCHAR2,
          p_attribute2    VARCHAR2,
          p_attribute3    VARCHAR2,
          p_attribute4    VARCHAR2,
          p_attribute5    VARCHAR2,
          p_attribute6    VARCHAR2,
          p_attribute7    VARCHAR2,
          p_attribute8    VARCHAR2,
          p_attribute9    VARCHAR2,
          p_attribute10    VARCHAR2,
          p_attribute11    VARCHAR2,
          p_attribute12    VARCHAR2,
          p_attribute13    VARCHAR2,
          p_attribute14    VARCHAR2,
          p_attribute15    VARCHAR2,
          p_line_attribute_category    VARCHAR2,
          p_line_attribute1    VARCHAR2,
          p_line_attribute2    VARCHAR2,
          p_line_attribute3    VARCHAR2,
          p_line_attribute4    VARCHAR2,
          p_line_attribute5    VARCHAR2,
          p_line_attribute6    VARCHAR2,
          p_line_attribute7    VARCHAR2,
          p_line_attribute8    VARCHAR2,
          p_line_attribute9    VARCHAR2,
          p_line_attribute10    VARCHAR2,
          p_line_attribute11    VARCHAR2,
          p_line_attribute12    VARCHAR2,
          p_line_attribute13    VARCHAR2,
          p_line_attribute14    VARCHAR2,
          p_line_attribute15    VARCHAR2,
          p_org_id    NUMBER)

 IS
 BEGIN
    Update OZF_RESALE_LINES_ALL
    SET
              resale_line_id = p_resale_line_id,
              resale_header_id = p_resale_header_id,
              resale_transfer_type = p_resale_transfer_type,
              object_version_number = p_object_version_number,
              last_update_date = p_last_update_date,
              last_updated_by = p_last_updated_by,
              request_id = p_request_id,
              created_from = p_created_from,
              last_update_login = p_last_update_login,
              program_application_id = p_program_application_id,
              program_update_date = p_program_update_date,
              program_id = p_program_id,
              status_code = p_status_code,
              product_transfer_movement_type = p_product_trans_movement_type,
              product_transfer_date = p_product_transfer_date,
              end_cust_party_id = p_end_cust_party_id,
              end_cust_site_use_id = p_end_cust_site_use_id,
              end_cust_site_use_code = p_end_cust_site_use_code ,
	      end_cust_party_site_id = p_end_cust_party_site_id,
              end_cust_party_name = p_end_cust_party_name,
              end_cust_location = p_end_cust_location,
              end_cust_address = p_end_cust_address,
              end_cust_city = p_end_cust_city,
              end_cust_state = p_end_cust_state,
              end_cust_postal_code = p_end_cust_postal_code,
              end_cust_country = p_end_cust_country,
              end_cust_contact_party_id = p_end_cust_contact_party_id,
              end_cust_contact_name = p_end_cust_contact_name,
              end_cust_email = p_end_cust_email,
              end_cust_phone = p_end_cust_phone,
              end_cust_fax = p_end_cust_fax,
	      bill_to_cust_account_id = p_bill_to_cust_account_id,
              bill_to_site_use_id = p_bill_to_site_use_id,
              bill_to_PARTY_NAME = p_bill_to_PARTY_NAME,
	      bill_to_PARTY_ID = p_bill_to_PARTY_ID,
              bill_to_PARTY_site_id = p_bill_to_PARTY_site_id,
              bill_to_duns_number = p_bill_to_duns_number,
              bill_to_location = p_bill_to_location,
              bill_to_address = p_bill_to_address,
              bill_to_city = p_bill_to_city,
              bill_to_state = p_bill_to_state,
              bill_to_postal_code = p_bill_to_postal_code,
              bill_to_country = p_bill_to_country,
              bill_to_contact_party_id = p_bill_to_contact_party_id,
              bill_to_contact_name = p_bill_to_contact_name,
	      bill_to_email = p_bill_to_email,
              bill_to_phone = p_bill_to_phone,
              bill_to_fax = p_bill_to_fax,
              ship_to_cust_account_id = p_ship_to_cust_account_id,
              ship_to_site_use_id = p_ship_to_site_use_id,
              ship_to_PARTY_NAME = p_ship_to_PARTY_NAME,
	      ship_to_PARTY_ID = p_ship_to_PARTY_ID,
              ship_to_PARTY_site_id = p_ship_to_PARTY_site_id,
              ship_to_duns_number = p_ship_to_duns_number,
              ship_to_location = p_ship_to_location,
              ship_to_address = p_ship_to_address,
              ship_to_city = p_ship_to_city,
              ship_to_state = p_ship_to_state,
              ship_to_postal_code = p_ship_to_postal_code,
              ship_to_country = p_ship_to_country,
              ship_to_contact_party_id = p_ship_to_contact_party_id,
              ship_to_contact_name = p_ship_to_contact_name,
              ship_to_email = p_ship_to_email,
              ship_to_phone = p_ship_to_phone,
              ship_to_fax = p_ship_to_fax,
              ship_from_cust_account_id = p_ship_from_cust_account_id,
              ship_from_site_id = p_ship_from_site_id,
              ship_from_PARTY_NAME = p_ship_from_PARTY_NAME,
              ship_from_location = p_ship_from_location,
	      ship_from_address = p_ship_from_address,
              ship_from_city = p_ship_from_city,
              ship_from_state = p_ship_from_state,
              ship_from_postal_code = p_ship_from_postal_code,
              ship_from_country = p_ship_from_country,
              ship_from_contact_party_id = p_ship_from_contact_party_id,
	      ship_from_contact_name = p_ship_from_contact_name,
	      ship_from_email = p_ship_from_email,
              ship_from_phone = p_ship_from_phone,
              ship_from_fax = p_ship_from_fax,
              sold_from_cust_account_id = p_sold_from_cust_account_id,
              sold_from_site_id = p_sold_from_site_id,
              sold_from_PARTY_NAME = p_sold_from_PARTY_NAME,
              sold_from_location = p_sold_from_location,
              sold_from_address = p_sold_from_address,
              sold_from_city = p_sold_from_city,
              sold_from_state = p_sold_from_state,
              sold_from_postal_code = p_sold_from_postal_code,
              sold_from_country = p_sold_from_country,
              sold_from_contact_party_id = p_sold_from_contact_party_id,
              sold_from_contact_name = p_sold_from_contact_name,
	      sold_from_email = p_sold_from_email,
              sold_from_phone = p_sold_from_phone,
              sold_from_fax = p_sold_from_fax,
              price_list_id = p_price_list_id,
              price_list_name = p_price_list_name,
              invoice_number = p_invoice_number,
              date_invoiced= p_date_invoiced,
              po_number = p_po_number,
              po_release_number = p_po_release_number,
              po_type = p_po_type,
              order_number = p_order_number,
              date_ordered = p_date_ordered,
              date_shipped = p_date_shipped,
              purchase_uom_code = p_purchase_uom_code,
              quantity = p_quantity,
              uom_code = p_uom_code,
              currency_code = p_currency_code,
              exchange_rate = p_exchange_rate,
              exchange_rate_type = p_exchange_rate_type,
              exchange_rate_date = p_exchange_rate_date,
              selling_price = p_selling_price,
              acctd_selling_price = p_acctd_selling_price,
              purchase_price = p_purchase_price,
              acctd_purchase_price = p_acctd_purchase_price,
	      tracing_flag = p_tracing_flag,
              orig_system_quantity = p_orig_system_quantity,
              orig_system_uom = p_orig_system_uom,
              orig_system_currency_code = p_orig_system_currency_code,
              orig_system_selling_price = p_orig_system_selling_price,
              orig_system_reference = p_orig_system_reference,
	      orig_system_line_reference = p_orig_system_line_reference,
	      orig_system_purchase_uom = p_orig_system_purchase_uom,
	      orig_system_purchase_curr = p_orig_system_purchase_curr,
              orig_system_purchase_price = p_orig_system_purchase_price,
              orig_system_purchase_quantity = p_orig_system_purchase_quant,
              orig_system_item_number = p_orig_system_item_number,
              product_category_id = p_product_category_id,
              category_name = p_category_name,
              inventory_item_segment1 = p_inventory_item_segment1,
              inventory_item_segment2 = p_inventory_item_segment2,
              inventory_item_segment3 = p_inventory_item_segment3,
              inventory_item_segment4 = p_inventory_item_segment4,
              inventory_item_segment5 = p_inventory_item_segment5,
              inventory_item_segment6 = p_inventory_item_segment6,
              inventory_item_segment7 = p_inventory_item_segment7,
              inventory_item_segment8 = p_inventory_item_segment8,
              inventory_item_segment9 = p_inventory_item_segment9,
              inventory_item_segment10 = p_inventory_item_segment10,
              inventory_item_segment11 = p_inventory_item_segment11,
              inventory_item_segment12 = p_inventory_item_segment12,
              inventory_item_segment13 = p_inventory_item_segment13,
              inventory_item_segment14 = p_inventory_item_segment14,
              inventory_item_segment15 = p_inventory_item_segment15,
              inventory_item_segment16 = p_inventory_item_segment16,
              inventory_item_segment17 = p_inventory_item_segment17,
              inventory_item_segment18 = p_inventory_item_segment18,
              inventory_item_segment19 = p_inventory_item_segment19,
              inventory_item_segment20 = p_inventory_item_segment20,
              inventory_item_id = p_inventory_item_id,
              item_description = p_item_description,
              upc_code = p_upc_code,
              item_number = p_item_number,
              direct_customer_flag = p_direct_customer_flag,
              attribute_category = p_attribute_category,
              attribute1 = p_attribute1,
              attribute2 = p_attribute2,
              attribute3 = p_attribute3,
              attribute4 = p_attribute4,
              attribute5 = p_attribute5,
              attribute6 = p_attribute6,
              attribute7 = p_attribute7,
              attribute8 = p_attribute8,
              attribute9 = p_attribute9,
              attribute10 = p_attribute10,
              attribute11 = p_attribute11,
              attribute12 = p_attribute12,
              attribute13 = p_attribute13,
              attribute14 = p_attribute14,
              attribute15 = p_attribute15,
              line_attribute_category = p_line_attribute_category,
              line_attribute1 = p_line_attribute1,
              line_attribute2 = p_line_attribute2,
              line_attribute3 = p_line_attribute3,
              line_attribute4 = p_line_attribute4,
              line_attribute5 = p_line_attribute5,
              line_attribute6 = p_line_attribute6,
              line_attribute7 = p_line_attribute7,
              line_attribute8 = p_line_attribute8,
              line_attribute9 = p_line_attribute9,
              line_attribute10 = p_line_attribute10,
              line_attribute11 = p_line_attribute11,
              line_attribute12 = p_line_attribute12,
              line_attribute13 = p_line_attribute13,
              line_attribute14 = p_line_attribute14,
              line_attribute15 = p_line_attribute15,
              org_id = p_org_id
   WHERE RESALE_LINE_ID = p_RESALE_LINE_ID
   AND   object_version_number = p_object_version_number;

   IF (SQL%NOTFOUND) THEN
RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
END Update_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createDeleteBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Row(
    p_RESALE_LINE_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM OZF_RESALE_LINES_ALL
    WHERE RESALE_LINE_ID = p_RESALE_LINE_ID;
   If (SQL%NOTFOUND) then
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
 END Delete_Row ;



----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createLockBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Lock_Row(
          p_resale_line_id    NUMBER,
          p_resale_header_id    NUMBER,
          p_resale_transfer_type    VARCHAR2,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_request_id    NUMBER,
          p_created_by    NUMBER,
          p_created_from    VARCHAR2,
          p_last_update_login    NUMBER,
          p_program_application_id    NUMBER,
          p_program_update_date    DATE,
          p_program_id    NUMBER,
          p_status_code    VARCHAR2,
          p_product_trans_movement_type    VARCHAR2,
          p_product_transfer_date    DATE,
          p_end_cust_party_id    NUMBER,
          p_end_cust_site_use_id    NUMBER,
          p_end_cust_site_use_code   VARCHAR2,
          p_end_cust_party_site_id    NUMBER,
          p_end_cust_party_name    VARCHAR2,
          p_end_cust_location    VARCHAR2,
          p_end_cust_address    VARCHAR2,
          p_end_cust_city    VARCHAR2,
          p_end_cust_state    VARCHAR2,
          p_end_cust_postal_code    VARCHAR2,
          p_end_cust_country    VARCHAR2,
          p_end_cust_contact_party_id   NUMBER,
          p_end_cust_contact_name    VARCHAR2,
	  p_end_cust_email    VARCHAR2,
          p_end_cust_phone    VARCHAR2,
          p_end_cust_fax    VARCHAR2,
          p_bill_to_cust_account_id    NUMBER,
          p_bill_to_site_use_id    NUMBER,
          p_bill_to_PARTY_NAME    VARCHAR2,
	  p_bill_to_PARTY_ID      NUMBER,
          p_bill_to_PARTY_site_id NUMBER,
          p_bill_to_duns_number    VARCHAR2,
          p_bill_to_location    VARCHAR2,
          p_bill_to_address    VARCHAR2,
          p_bill_to_city    VARCHAR2,
          p_bill_to_state    VARCHAR2,
          p_bill_to_postal_code    VARCHAR2,
          p_bill_to_country    VARCHAR2,
          p_bill_to_contact_party_id   NUMBER,
          p_bill_to_contact_name    VARCHAR2,
	  p_bill_to_email  VARCHAR2,
          p_bill_to_phone  VARCHAR2,
          p_bill_to_fax   VARCHAR2,
          p_ship_to_cust_account_id    NUMBER,
          p_ship_to_site_use_id    NUMBER,
          p_ship_to_PARTY_NAME    VARCHAR2,
          p_ship_to_PARTY_ID      NUMBER,
          p_ship_to_PARTY_site_id NUMBER,
          p_ship_to_duns_number     VARCHAR2,
          p_ship_to_location    VARCHAR2,
          p_ship_to_address    VARCHAR2,
          p_ship_to_city    VARCHAR2,
          p_ship_to_state    VARCHAR2,
          p_ship_to_postal_code    VARCHAR2,
          p_ship_to_country    VARCHAR2,
          p_ship_to_contact_party_id   NUMBER,
          p_ship_to_contact_name    VARCHAR2,
	  p_ship_to_email  VARCHAR2,
          p_ship_to_phone  VARCHAR2,
          p_ship_to_fax   VARCHAR2,
          p_ship_from_cust_account_id    NUMBER,
          p_ship_from_site_id    NUMBER,
          p_ship_from_PARTY_NAME    VARCHAR2,
          p_ship_from_location    VARCHAR2,
          p_ship_from_address    VARCHAR2,
          p_ship_from_city    VARCHAR2,
          p_ship_from_state    VARCHAR2,
          p_ship_from_postal_code    VARCHAR2,
          p_ship_from_country    VARCHAR2,
          p_ship_from_contact_party_id   NUMBER,
          p_ship_from_contact_name    VARCHAR2,
	  p_ship_from_email  VARCHAR2,
          p_ship_from_phone  VARCHAR2,
          p_ship_from_fax   VARCHAR2,
          p_sold_from_cust_account_id    NUMBER,
          p_sold_from_site_id    NUMBER,
          p_sold_from_PARTY_NAME    VARCHAR2,
          p_sold_from_location    VARCHAR2,
          p_sold_from_address    VARCHAR2,
          p_sold_from_city    VARCHAR2,
          p_sold_from_state    VARCHAR2,
          p_sold_from_postal_code    VARCHAR2,
          p_sold_from_country    VARCHAR2,
          p_sold_from_contact_party_id   NUMBER,
          p_sold_from_contact_name    VARCHAR2,
	  p_sold_from_email  VARCHAR2,
          p_sold_from_phone  VARCHAR2,
          p_sold_from_fax   VARCHAR2,
          p_price_list_id    NUMBER,
          p_price_list_name    VARCHAR2,
          p_invoice_number    VARCHAR2,
          p_date_invoiced   DATE,
          p_po_number    VARCHAR2,
          p_po_release_number    VARCHAR2,
          p_po_type    VARCHAR2,
          p_order_number    VARCHAR2,
          p_date_ordered    DATE,
          p_date_shipped    DATE,
	  p_purchase_uom_code    VARCHAR2,
          p_quantity    NUMBER,
          p_uom_code    VARCHAR2,
          p_currency_code    VARCHAR2,
          p_exchange_rate    NUMBER,
          p_exchange_rate_type    VARCHAR2,
          p_exchange_rate_date    DATE,
          p_selling_price    NUMBER,
          p_acctd_selling_price    NUMBER,
          p_purchase_price    NUMBER,
          p_acctd_purchase_price    NUMBER,
	  p_tracing_flag     VARCHAR2,
          p_orig_system_quantity    NUMBER,
          p_orig_system_uom    VARCHAR2,
          p_orig_system_currency_code    VARCHAR2,
          p_orig_system_selling_price    NUMBER,
          p_orig_system_reference    VARCHAR2,
          p_orig_system_line_reference    VARCHAR2,
	  p_orig_system_purchase_uom  varchar2,
	  p_orig_system_purchase_curr      VARCHAR2,
          p_orig_system_purchase_price      NUMBER,
          p_orig_system_purchase_quant   NUMBER,
          p_orig_system_item_number  varchar2,
          p_product_category_id    NUMBER,
          p_category_name    VARCHAR2,
          p_inventory_item_segment1    VARCHAR2,
          p_inventory_item_segment2    VARCHAR2,
          p_inventory_item_segment3    VARCHAR2,
          p_inventory_item_segment4    VARCHAR2,
          p_inventory_item_segment5    VARCHAR2,
          p_inventory_item_segment6    VARCHAR2,
          p_inventory_item_segment7    VARCHAR2,
          p_inventory_item_segment8    VARCHAR2,
          p_inventory_item_segment9    VARCHAR2,
          p_inventory_item_segment10    VARCHAR2,
          p_inventory_item_segment11    VARCHAR2,
          p_inventory_item_segment12    VARCHAR2,
          p_inventory_item_segment13    VARCHAR2,
          p_inventory_item_segment14    VARCHAR2,
          p_inventory_item_segment15    VARCHAR2,
          p_inventory_item_segment16    VARCHAR2,
          p_inventory_item_segment17    VARCHAR2,
          p_inventory_item_segment18    VARCHAR2,
          p_inventory_item_segment19    VARCHAR2,
          p_inventory_item_segment20    VARCHAR2,
          p_inventory_item_id    NUMBER,
          p_item_description    VARCHAR2,
          p_upc_code    VARCHAR2,
          p_item_number    VARCHAR2,
          p_direct_customer_flag    VARCHAR2,
          p_attribute_category    VARCHAR2,
          p_attribute1    VARCHAR2,
          p_attribute2    VARCHAR2,
          p_attribute3    VARCHAR2,
          p_attribute4    VARCHAR2,
          p_attribute5    VARCHAR2,
          p_attribute6    VARCHAR2,
          p_attribute7    VARCHAR2,
          p_attribute8    VARCHAR2,
          p_attribute9    VARCHAR2,
          p_attribute10    VARCHAR2,
          p_attribute11    VARCHAR2,
          p_attribute12    VARCHAR2,
          p_attribute13    VARCHAR2,
          p_attribute14    VARCHAR2,
          p_attribute15    VARCHAR2,
          p_line_attribute_category    VARCHAR2,
          p_line_attribute1    VARCHAR2,
          p_line_attribute2    VARCHAR2,
          p_line_attribute3    VARCHAR2,
          p_line_attribute4    VARCHAR2,
          p_line_attribute5    VARCHAR2,
          p_line_attribute6    VARCHAR2,
          p_line_attribute7    VARCHAR2,
          p_line_attribute8    VARCHAR2,
          p_line_attribute9    VARCHAR2,
          p_line_attribute10    VARCHAR2,
          p_line_attribute11    VARCHAR2,
          p_line_attribute12    VARCHAR2,
          p_line_attribute13    VARCHAR2,
          p_line_attribute14    VARCHAR2,
          p_line_attribute15    VARCHAR2,
          p_org_id    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM OZF_RESALE_LINES_ALL
        WHERE RESALE_LINE_ID =  p_RESALE_LINE_ID
        FOR UPDATE of RESALE_LINE_ID NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN
    OPEN c;
    FETCH c INTO Recinfo;
    If (c%NOTFOUND) then
        CLOSE c;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;
    IF (
           (      Recinfo.resale_line_id = p_resale_line_id)
       AND (    ( Recinfo.resale_header_id = p_resale_header_id)
            OR (    ( Recinfo.resale_header_id IS NULL )
                AND (  p_resale_header_id IS NULL )))
       AND (    ( Recinfo.resale_transfer_type = p_resale_transfer_type)
            OR (    ( Recinfo.resale_transfer_type IS NULL )
                AND (  p_resale_transfer_type IS NULL )))
       AND (    ( Recinfo.object_version_number = p_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  p_object_version_number IS NULL )))
       AND (    ( Recinfo.last_update_date = p_last_update_date)
            OR (    ( Recinfo.last_update_date IS NULL )
                AND (  p_last_update_date IS NULL )))
       AND (    ( Recinfo.last_updated_by = p_last_updated_by)
            OR (    ( Recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
       AND (    ( Recinfo.creation_date = p_creation_date)
            OR (    ( Recinfo.creation_date IS NULL )
                AND (  p_creation_date IS NULL )))
       AND (    ( Recinfo.request_id = p_request_id)
            OR (    ( Recinfo.request_id IS NULL )
                AND (  p_request_id IS NULL )))
       AND (    ( Recinfo.created_by = p_created_by)
            OR (    ( Recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
       AND (    ( Recinfo.created_from = p_created_from)
            OR (    ( Recinfo.created_from IS NULL )
                AND (  p_created_from IS NULL )))
       AND (    ( Recinfo.last_update_login = p_last_update_login)
            OR (    ( Recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( Recinfo.program_application_id = p_program_application_id)
            OR (    ( Recinfo.program_application_id IS NULL )
                AND (  p_program_application_id IS NULL )))
       AND (    ( Recinfo.program_update_date = p_program_update_date)
            OR (    ( Recinfo.program_update_date IS NULL )
                AND (  p_program_update_date IS NULL )))
       AND (    ( Recinfo.program_id = p_program_id)
            OR (    ( Recinfo.program_id IS NULL )
                AND (  p_program_id IS NULL )))
       AND (    ( Recinfo.status_code = p_status_code)
            OR (    ( Recinfo.status_code IS NULL )
                AND (  p_status_code IS NULL )))
       AND (    ( Recinfo.product_transfer_movement_type = p_product_trans_movement_type)
            OR (    ( Recinfo.product_transfer_movement_type IS NULL )
                AND (  p_product_trans_movement_type IS NULL )))
       AND (    ( Recinfo.product_transfer_date = p_product_transfer_date)
            OR (    ( Recinfo.product_transfer_date IS NULL )
                AND (  p_product_transfer_date IS NULL )))
       AND (    ( Recinfo.end_cust_party_id = p_end_cust_party_id)
            OR (    ( Recinfo.end_cust_party_id IS NULL )
                AND (  p_end_cust_party_id IS NULL )))
       AND (    ( Recinfo.end_cust_site_use_id = p_end_cust_site_use_id)
            OR (    ( Recinfo.end_cust_site_use_id IS NULL )
                AND (  p_end_cust_site_use_id IS NULL )))
       AND (    ( Recinfo.end_cust_site_use_code = p_end_cust_site_use_code)
            OR (    ( Recinfo.end_cust_site_use_code IS NULL )
                AND (  p_end_cust_site_use_code IS NULL )))
       AND (    ( Recinfo.end_cust_party_site_id = p_end_cust_party_site_id)
            OR (    ( Recinfo.end_cust_party_site_id IS NULL )
                AND (  p_end_cust_party_site_id IS NULL )))
       AND (    ( Recinfo.end_cust_party_name = p_end_cust_party_name)
            OR (    ( Recinfo.end_cust_party_name IS NULL )
                AND (  p_end_cust_party_name IS NULL )))
       AND (    ( Recinfo.end_cust_location = p_end_cust_location)
            OR (    ( Recinfo.end_cust_location IS NULL )
                AND (  p_end_cust_location IS NULL )))
       AND (    ( Recinfo.end_cust_address = p_end_cust_address)
            OR (    ( Recinfo.end_cust_address IS NULL )
                AND (  p_end_cust_address IS NULL )))
       AND (    ( Recinfo.end_cust_city = p_end_cust_city)
            OR (    ( Recinfo.end_cust_city IS NULL )
                AND (  p_end_cust_city IS NULL )))
       AND (    ( Recinfo.end_cust_state = p_end_cust_state)
            OR (    ( Recinfo.end_cust_state IS NULL )
                AND (  p_end_cust_state IS NULL )))
       AND (    ( Recinfo.end_cust_postal_code = p_end_cust_postal_code)
            OR (    ( Recinfo.end_cust_postal_code IS NULL )
                AND (  p_end_cust_postal_code IS NULL )))
       AND (    ( Recinfo.end_cust_country = p_end_cust_country)
            OR (    ( Recinfo.end_cust_country IS NULL )
                AND (  p_end_cust_country IS NULL )))
       AND (    ( Recinfo.end_cust_contact_party_id = p_end_cust_contact_party_id)
            OR (    ( Recinfo.end_cust_contact_party_id IS NULL )
                AND (  p_end_cust_contact_party_id IS NULL )))
       AND (    ( Recinfo.end_cust_contact_name = p_end_cust_contact_name)
            OR (    ( Recinfo.end_cust_contact_name IS NULL )
                AND (  p_end_cust_contact_name IS NULL )))
       AND (    ( Recinfo.end_cust_email = p_end_cust_email)
            OR (    ( Recinfo.end_cust_email IS NULL )
                AND (  p_end_cust_email IS NULL )))
       AND (    ( Recinfo.end_cust_phone = p_end_cust_phone)
            OR (    ( Recinfo.end_cust_phone IS NULL )
                AND (  p_end_cust_phone IS NULL )))
       AND (    ( Recinfo.end_cust_fax = p_end_cust_fax)
            OR (    ( Recinfo.end_cust_fax IS NULL )
                AND (  p_end_cust_fax IS NULL )))
       AND (    ( Recinfo.bill_to_cust_account_id = p_bill_to_cust_account_id)
            OR (    ( Recinfo.bill_to_cust_account_id IS NULL )
                AND (  p_bill_to_cust_account_id IS NULL )))
       AND (    ( Recinfo.bill_to_site_use_id = p_bill_to_site_use_id)
            OR (    ( Recinfo.bill_to_site_use_id IS NULL )
                AND (  p_bill_to_site_use_id IS NULL )))
       AND (    ( Recinfo.bill_to_PARTY_NAME = p_bill_to_PARTY_NAME)
            OR (    ( Recinfo.bill_to_PARTY_NAME IS NULL )
                AND (  p_bill_to_PARTY_NAME IS NULL )))
       AND (    ( Recinfo.bill_to_PARTY_ID = p_bill_to_PARTY_ID)
            OR (    ( Recinfo.bill_to_PARTY_ID IS NULL )
                AND (  p_bill_to_PARTY_ID IS NULL )))
       AND (    ( Recinfo.bill_to_PARTY_site_id = p_bill_to_PARTY_site_id)
            OR (    ( Recinfo.bill_to_PARTY_site_id IS NULL )
                AND (  p_bill_to_PARTY_site_id IS NULL )))
       AND (    ( Recinfo.bill_to_duns_number = p_bill_to_duns_number)
            OR (    ( Recinfo.bill_to_duns_number IS NULL )
                AND (  p_bill_to_duns_number IS NULL )))
       AND (    ( Recinfo.bill_to_location = p_bill_to_location)
            OR (    ( Recinfo.bill_to_location IS NULL )
                AND (  p_bill_to_location IS NULL )))
       AND (    ( Recinfo.bill_to_address = p_bill_to_address)
            OR (    ( Recinfo.bill_to_address IS NULL )
                AND (  p_bill_to_address IS NULL )))
       AND (    ( Recinfo.bill_to_city = p_bill_to_city)
            OR (    ( Recinfo.bill_to_city IS NULL )
                AND (  p_bill_to_city IS NULL )))
       AND (    ( Recinfo.bill_to_state = p_bill_to_state)
            OR (    ( Recinfo.bill_to_state IS NULL )
                AND (  p_bill_to_state IS NULL )))
       AND (    ( Recinfo.bill_to_postal_code = p_bill_to_postal_code)
            OR (    ( Recinfo.bill_to_postal_code IS NULL )
                AND (  p_bill_to_postal_code IS NULL )))
       AND (    ( Recinfo.bill_to_country = p_bill_to_country)
            OR (    ( Recinfo.bill_to_country IS NULL )
                AND (  p_bill_to_country IS NULL )))
       AND (    ( Recinfo.bill_to_contact_party_id = p_bill_to_contact_party_id)
            OR (    ( Recinfo.bill_to_contact_party_id IS NULL )
                AND (  p_bill_to_contact_party_id IS NULL )))
       AND (    ( Recinfo.bill_to_contact_name = p_bill_to_contact_name)
            OR (    ( Recinfo.bill_to_contact_name IS NULL )
                AND (  p_bill_to_contact_name IS NULL )))
       AND (    ( Recinfo.bill_to_email = p_bill_to_email)
            OR (    ( Recinfo.bill_to_email IS NULL )
                AND (  p_bill_to_email IS NULL )))
       AND (    ( Recinfo.bill_to_phone = p_bill_to_phone)
            OR (    ( Recinfo.bill_to_phone IS NULL )
                AND (  p_bill_to_phone IS NULL )))
       AND (    ( Recinfo.bill_to_fax = p_bill_to_fax)
            OR (    ( Recinfo.bill_to_fax IS NULL )
                AND (  p_bill_to_fax IS NULL )))
       AND (    ( Recinfo.ship_to_cust_account_id = p_ship_to_cust_account_id)
            OR (    ( Recinfo.ship_to_cust_account_id IS NULL )
                AND (  p_ship_to_cust_account_id IS NULL )))
       AND (    ( Recinfo.ship_to_site_use_id = p_ship_to_site_use_id)
            OR (    ( Recinfo.ship_to_site_use_id IS NULL )
                AND (  p_ship_to_site_use_id IS NULL )))
       AND (    ( Recinfo.ship_to_PARTY_NAME = p_ship_to_PARTY_NAME)
            OR (    ( Recinfo.ship_to_PARTY_NAME IS NULL )
                AND (  p_ship_to_PARTY_NAME IS NULL )))
       AND (    ( Recinfo.ship_to_PARTY_ID = p_ship_to_PARTY_ID)
            OR (    ( Recinfo.ship_to_PARTY_ID IS NULL )
                AND (  p_ship_to_PARTY_ID IS NULL )))
       AND (    ( Recinfo.ship_to_PARTY_site_id = p_ship_to_PARTY_site_id)
            OR (    ( Recinfo.ship_to_PARTY_site_id IS NULL )
                AND (  p_ship_to_PARTY_site_id IS NULL )))
       AND (    ( Recinfo.ship_to_duns_number = p_ship_to_duns_number)
            OR (    ( Recinfo.ship_to_duns_number IS NULL )
                AND (  p_ship_to_duns_number IS NULL )))
       AND (    ( Recinfo.ship_to_location = p_ship_to_location)
            OR (    ( Recinfo.ship_to_location IS NULL )
                AND (  p_ship_to_location IS NULL )))
       AND (    ( Recinfo.ship_to_address = p_ship_to_address)
            OR (    ( Recinfo.ship_to_address IS NULL )
                AND (  p_ship_to_address IS NULL )))
       AND (    ( Recinfo.ship_to_city = p_ship_to_city)
            OR (    ( Recinfo.ship_to_city IS NULL )
                AND (  p_ship_to_city IS NULL )))
       AND (    ( Recinfo.ship_to_state = p_ship_to_state)
            OR (    ( Recinfo.ship_to_state IS NULL )
                AND (  p_ship_to_state IS NULL )))
       AND (    ( Recinfo.ship_to_postal_code = p_ship_to_postal_code)
            OR (    ( Recinfo.ship_to_postal_code IS NULL )
                AND (  p_ship_to_postal_code IS NULL )))
       AND (    ( Recinfo.ship_to_country = p_ship_to_country)
            OR (    ( Recinfo.ship_to_country IS NULL )
                AND (  p_ship_to_country IS NULL )))
       AND (    ( Recinfo.ship_to_contact_party_id = p_ship_to_contact_party_id)
            OR (    ( Recinfo.ship_to_contact_party_id IS NULL )
                AND (  p_ship_to_contact_party_id IS NULL )))
       AND (    ( Recinfo.ship_to_contact_name = p_ship_to_contact_name)
            OR (    ( Recinfo.ship_to_contact_name IS NULL )
                AND (  p_ship_to_contact_name IS NULL )))
       AND (    ( Recinfo.ship_to_email = p_ship_to_email)
            OR (    ( Recinfo.ship_to_email IS NULL )
                AND (  p_ship_to_email IS NULL )))
       AND (    ( Recinfo.ship_to_phone = p_ship_to_phone)
            OR (    ( Recinfo.ship_to_phone IS NULL )
                AND (  p_ship_to_phone IS NULL )))
       AND (    ( Recinfo.ship_to_fax = p_ship_to_fax)
            OR (    ( Recinfo.ship_to_fax IS NULL )
                AND (  p_ship_to_fax IS NULL )))
       AND (    ( Recinfo.ship_from_cust_account_id = p_ship_from_cust_account_id)
            OR (    ( Recinfo.ship_from_cust_account_id IS NULL )
                AND (  p_ship_from_cust_account_id IS NULL )))
       AND (    ( Recinfo.ship_from_site_id = p_ship_from_site_id)
            OR (    ( Recinfo.ship_from_site_id IS NULL )
                AND (  p_ship_from_site_id IS NULL )))
       AND (    ( Recinfo.ship_from_PARTY_NAME = p_ship_from_PARTY_NAME)
            OR (    ( Recinfo.ship_from_PARTY_NAME IS NULL )
                AND (  p_ship_from_PARTY_NAME IS NULL )))
       AND (    ( Recinfo.ship_from_location = p_ship_from_location)
            OR (    ( Recinfo.ship_from_location IS NULL )
                AND (  p_ship_from_location IS NULL )))
       AND (    ( Recinfo.ship_from_address = p_ship_from_address)
            OR (    ( Recinfo.ship_from_address IS NULL )
                AND (  p_ship_from_address IS NULL )))
       AND (    ( Recinfo.ship_from_city = p_ship_from_city)
            OR (    ( Recinfo.ship_from_city IS NULL )
                AND (  p_ship_from_city IS NULL )))
       AND (    ( Recinfo.ship_from_state = p_ship_from_state)
            OR (    ( Recinfo.ship_from_state IS NULL )
                AND (  p_ship_from_state IS NULL )))
       AND (    ( Recinfo.ship_from_postal_code = p_ship_from_postal_code)
            OR (    ( Recinfo.ship_from_postal_code IS NULL )
                AND (  p_ship_from_postal_code IS NULL )))
       AND (    ( Recinfo.ship_from_country = p_ship_from_country)
            OR (    ( Recinfo.ship_from_country IS NULL )
                AND (  p_ship_from_country IS NULL )))
       AND (    ( Recinfo.ship_from_contact_party_id = p_ship_from_contact_party_id)
            OR (    ( Recinfo.ship_from_contact_party_id IS NULL )
                AND (  p_ship_from_contact_party_id IS NULL )))
       AND (    ( Recinfo.ship_from_contact_name = p_ship_from_contact_name)
            OR (    ( Recinfo.ship_from_contact_name IS NULL )
                AND (  p_ship_from_contact_name IS NULL )))
       AND (    ( Recinfo.ship_from_email = p_ship_from_email)
            OR (    ( Recinfo.ship_from_email IS NULL )
                AND (  p_ship_from_email IS NULL )))
       AND (    ( Recinfo.ship_from_phone = p_ship_from_phone)
            OR (    ( Recinfo.ship_from_phone IS NULL )
                AND (  p_ship_from_phone IS NULL )))
       AND (    ( Recinfo.ship_from_fax = p_ship_from_fax)
            OR (    ( Recinfo.ship_from_fax IS NULL )
                AND (  p_ship_from_fax IS NULL )))
       AND (    ( Recinfo.sold_from_cust_account_id = p_sold_from_cust_account_id)
            OR (    ( Recinfo.sold_from_cust_account_id IS NULL )
                AND (  p_sold_from_cust_account_id IS NULL )))
       AND (    ( Recinfo.sold_from_site_id = p_sold_from_site_id)
            OR (    ( Recinfo.sold_from_site_id IS NULL )
                AND (  p_sold_from_site_id IS NULL )))
       AND (    ( Recinfo.sold_from_PARTY_NAME = p_sold_from_PARTY_NAME)
            OR (    ( Recinfo.sold_from_PARTY_NAME IS NULL )
                AND (  p_sold_from_PARTY_NAME IS NULL )))
       AND (    ( Recinfo.sold_from_location = p_sold_from_location)
            OR (    ( Recinfo.sold_from_location IS NULL )
                AND (  p_sold_from_location IS NULL )))
       AND (    ( Recinfo.sold_from_address = p_sold_from_address)
            OR (    ( Recinfo.sold_from_address IS NULL )
                AND (  p_sold_from_address IS NULL )))
       AND (    ( Recinfo.sold_from_city = p_sold_from_city)
            OR (    ( Recinfo.sold_from_city IS NULL )
                AND (  p_sold_from_city IS NULL )))
       AND (    ( Recinfo.sold_from_state = p_sold_from_state)
            OR (    ( Recinfo.sold_from_state IS NULL )
                AND (  p_sold_from_state IS NULL )))
       AND (    ( Recinfo.sold_from_postal_code = p_sold_from_postal_code)
            OR (    ( Recinfo.sold_from_postal_code IS NULL )
                AND (  p_sold_from_postal_code IS NULL )))
       AND (    ( Recinfo.sold_from_country = p_sold_from_country)
            OR (    ( Recinfo.sold_from_country IS NULL )
                AND (  p_sold_from_country IS NULL )))
       AND (    ( Recinfo.sold_from_contact_party_id = p_sold_from_contact_party_id)
            OR (    ( Recinfo.sold_from_contact_party_id IS NULL )
                AND (  p_sold_from_contact_party_id IS NULL )))
       AND (    ( Recinfo.sold_from_contact_name = p_sold_from_contact_name)
            OR (    ( Recinfo.sold_from_contact_name IS NULL )
                AND (  p_sold_from_contact_name IS NULL )))
       AND (    ( Recinfo.sold_from_email = p_sold_from_email)
            OR (    ( Recinfo.sold_from_email IS NULL )
                AND (  p_sold_from_email IS NULL )))
       AND (    ( Recinfo.sold_from_phone = p_sold_from_phone)
            OR (    ( Recinfo.sold_from_phone IS NULL )
                AND (  p_sold_from_phone IS NULL )))
       AND (    ( Recinfo.sold_from_fax = p_sold_from_fax)
            OR (    ( Recinfo.sold_from_fax IS NULL )
                AND (  p_sold_from_fax IS NULL )))
       AND (    ( Recinfo.price_list_id = p_price_list_id)
            OR (    ( Recinfo.price_list_id IS NULL )
                AND (  p_price_list_id IS NULL )))
       AND (    ( Recinfo.price_list_name = p_price_list_name)
            OR (    ( Recinfo.price_list_name IS NULL )
                AND (  p_price_list_name IS NULL )))
       AND (    ( Recinfo.invoice_number = p_invoice_number)
            OR (    ( Recinfo.invoice_number IS NULL )
                AND (  p_invoice_number IS NULL )))
       AND (    ( Recinfo.date_invoiced= p_date_invoiced)
            OR (    ( Recinfo.date_invoiced IS NULL )
                AND (  p_date_invoiced IS NULL )))
       AND (    ( Recinfo.po_number = p_po_number)
            OR (    ( Recinfo.po_number IS NULL )
                AND (  p_po_number IS NULL )))
       AND (    ( Recinfo.po_release_number = p_po_release_number)
            OR (    ( Recinfo.po_release_number IS NULL )
                AND (  p_po_release_number IS NULL )))
       AND (    ( Recinfo.po_type = p_po_type)
            OR (    ( Recinfo.po_type IS NULL )
                AND (  p_po_type IS NULL )))
       AND (    ( Recinfo.order_number = p_order_number)
            OR (    ( Recinfo.order_number IS NULL )
                AND (  p_order_number IS NULL )))
       AND (    ( Recinfo.date_ordered = p_date_ordered)
            OR (    ( Recinfo.date_ordered IS NULL )
                AND (  p_date_ordered IS NULL )))
       AND (    ( Recinfo.date_shipped = p_date_shipped)
            OR (    ( Recinfo.date_shipped IS NULL )
                AND (  p_date_shipped IS NULL )))
       AND (    ( Recinfo.purchase_uom_code = p_purchase_uom_code)
            OR (    ( Recinfo.purchase_uom_code IS NULL )
                AND (  p_purchase_uom_code IS NULL )))
       AND (    ( Recinfo.quantity = p_quantity)
            OR (    ( Recinfo.quantity IS NULL )
                AND (  p_quantity IS NULL )))
       AND (    ( Recinfo.uom_code = p_uom_code)
            OR (    ( Recinfo.uom_code IS NULL )
                AND (  p_uom_code IS NULL )))
       AND (    ( Recinfo.currency_code = p_currency_code)
            OR (    ( Recinfo.currency_code IS NULL )
                AND (  p_currency_code IS NULL )))
       AND (    ( Recinfo.exchange_rate = p_exchange_rate)
            OR (    ( Recinfo.exchange_rate IS NULL )
                AND (  p_exchange_rate IS NULL )))
       AND (    ( Recinfo.exchange_rate_type = p_exchange_rate_type)
            OR (    ( Recinfo.exchange_rate_type IS NULL )
                AND (  p_exchange_rate_type IS NULL )))
       AND (    ( Recinfo.exchange_rate_date = p_exchange_rate_date)
            OR (    ( Recinfo.exchange_rate_date IS NULL )
                AND (  p_exchange_rate_date IS NULL )))
       AND (    ( Recinfo.selling_price = p_selling_price)
            OR (    ( Recinfo.selling_price IS NULL )
                AND (  p_selling_price IS NULL )))
       AND (    ( Recinfo.acctd_selling_price = p_acctd_selling_price)
            OR (    ( Recinfo.acctd_selling_price IS NULL )
                AND (  p_acctd_selling_price IS NULL )))
       AND (    ( Recinfo.purchase_price = p_purchase_price)
            OR (    ( Recinfo.purchase_price IS NULL )
                AND (  p_purchase_price IS NULL )))
       AND (    ( Recinfo.acctd_purchase_price = p_acctd_purchase_price)
            OR (    ( Recinfo.acctd_purchase_price IS NULL )
                AND (  p_acctd_purchase_price IS NULL )))
       AND (    ( Recinfo.tracing_flag = p_tracing_flag)
            OR (    ( Recinfo.tracing_flag IS NULL )
                AND (  p_tracing_flag IS NULL )))
       AND (    ( Recinfo.orig_system_quantity = p_orig_system_quantity)
            OR (    ( Recinfo.orig_system_quantity IS NULL )
                AND (  p_orig_system_quantity IS NULL )))
       AND (    ( Recinfo.orig_system_uom = p_orig_system_uom)
            OR (    ( Recinfo.orig_system_uom IS NULL )
                AND (  p_orig_system_uom IS NULL )))
       AND (    ( Recinfo.orig_system_currency_code = p_orig_system_currency_code)
            OR (    ( Recinfo.orig_system_currency_code IS NULL )
                AND (  p_orig_system_currency_code IS NULL )))
       AND (    ( Recinfo.orig_system_selling_price = p_orig_system_selling_price)
            OR (    ( Recinfo.orig_system_selling_price IS NULL )
                AND (  p_orig_system_selling_price IS NULL )))
       AND (    ( Recinfo.orig_system_reference = p_orig_system_reference)
            OR (    ( Recinfo.orig_system_reference IS NULL )
                AND (  p_orig_system_reference IS NULL )))
       AND (    ( Recinfo.orig_system_line_reference = p_orig_system_line_reference)
            OR (    ( Recinfo.orig_system_line_reference IS NULL )
                AND (  p_orig_system_line_reference IS NULL )))
       AND (    ( Recinfo.orig_system_purchase_uom = p_orig_system_purchase_uom)
            OR (    ( Recinfo.orig_system_purchase_uom IS NULL )
                AND (  p_orig_system_purchase_uom IS NULL )))
       AND (    ( Recinfo.orig_system_purchase_curr = p_orig_system_purchase_curr)
            OR (    ( Recinfo.orig_system_purchase_curr IS NULL )
                AND (  p_orig_system_purchase_curr IS NULL )))
       AND (    ( Recinfo.orig_system_purchase_price = p_orig_system_purchase_price)
            OR (    ( Recinfo.orig_system_purchase_price IS NULL )
                AND (  p_orig_system_purchase_price IS NULL )))
       AND (    ( Recinfo.orig_system_purchase_quantity = p_orig_system_purchase_quant)
            OR (    ( Recinfo.orig_system_purchase_quantity IS NULL )
                AND (  p_orig_system_purchase_quant IS NULL )))
       AND (    ( Recinfo.orig_system_item_number = p_orig_system_item_number)
            OR (    ( Recinfo.orig_system_item_number IS NULL )
                AND (  p_orig_system_item_number IS NULL )))
       AND (    ( Recinfo.product_category_id = p_product_category_id)
            OR (    ( Recinfo.product_category_id IS NULL )
                AND (  p_product_category_id IS NULL )))
       AND (    ( Recinfo.category_name = p_category_name)
            OR (    ( Recinfo.category_name IS NULL )
                AND (  p_category_name IS NULL )))
       AND (    ( Recinfo.inventory_item_segment1 = p_inventory_item_segment1)
            OR (    ( Recinfo.inventory_item_segment1 IS NULL )
                AND (  p_inventory_item_segment1 IS NULL )))
       AND (    ( Recinfo.inventory_item_segment2 = p_inventory_item_segment2)
            OR (    ( Recinfo.inventory_item_segment2 IS NULL )
                AND (  p_inventory_item_segment2 IS NULL )))
       AND (    ( Recinfo.inventory_item_segment3 = p_inventory_item_segment3)
            OR (    ( Recinfo.inventory_item_segment3 IS NULL )
                AND (  p_inventory_item_segment3 IS NULL )))
       AND (    ( Recinfo.inventory_item_segment4 = p_inventory_item_segment4)
            OR (    ( Recinfo.inventory_item_segment4 IS NULL )
                AND (  p_inventory_item_segment4 IS NULL )))
       AND (    ( Recinfo.inventory_item_segment5 = p_inventory_item_segment5)
            OR (    ( Recinfo.inventory_item_segment5 IS NULL )
                AND (  p_inventory_item_segment5 IS NULL )))
       AND (    ( Recinfo.inventory_item_segment6 = p_inventory_item_segment6)
            OR (    ( Recinfo.inventory_item_segment6 IS NULL )
                AND (  p_inventory_item_segment6 IS NULL )))
       AND (    ( Recinfo.inventory_item_segment7 = p_inventory_item_segment7)
            OR (    ( Recinfo.inventory_item_segment7 IS NULL )
                AND (  p_inventory_item_segment7 IS NULL )))
       AND (    ( Recinfo.inventory_item_segment8 = p_inventory_item_segment8)
            OR (    ( Recinfo.inventory_item_segment8 IS NULL )
                AND (  p_inventory_item_segment8 IS NULL )))
       AND (    ( Recinfo.inventory_item_segment9 = p_inventory_item_segment9)
            OR (    ( Recinfo.inventory_item_segment9 IS NULL )
                AND (  p_inventory_item_segment9 IS NULL )))
       AND (    ( Recinfo.inventory_item_segment10 = p_inventory_item_segment10)
            OR (    ( Recinfo.inventory_item_segment10 IS NULL )
                AND (  p_inventory_item_segment10 IS NULL )))
       AND (    ( Recinfo.inventory_item_segment11 = p_inventory_item_segment11)
            OR (    ( Recinfo.inventory_item_segment11 IS NULL )
                AND (  p_inventory_item_segment11 IS NULL )))
       AND (    ( Recinfo.inventory_item_segment12 = p_inventory_item_segment12)
            OR (    ( Recinfo.inventory_item_segment12 IS NULL )
                AND (  p_inventory_item_segment12 IS NULL )))
       AND (    ( Recinfo.inventory_item_segment13 = p_inventory_item_segment13)
            OR (    ( Recinfo.inventory_item_segment13 IS NULL )
                AND (  p_inventory_item_segment13 IS NULL )))
       AND (    ( Recinfo.inventory_item_segment14 = p_inventory_item_segment14)
            OR (    ( Recinfo.inventory_item_segment14 IS NULL )
                AND (  p_inventory_item_segment14 IS NULL )))
       AND (    ( Recinfo.inventory_item_segment15 = p_inventory_item_segment15)
            OR (    ( Recinfo.inventory_item_segment15 IS NULL )
                AND (  p_inventory_item_segment15 IS NULL )))
       AND (    ( Recinfo.inventory_item_segment16 = p_inventory_item_segment16)
            OR (    ( Recinfo.inventory_item_segment16 IS NULL )
                AND (  p_inventory_item_segment16 IS NULL )))
       AND (    ( Recinfo.inventory_item_segment17 = p_inventory_item_segment17)
            OR (    ( Recinfo.inventory_item_segment17 IS NULL )
                AND (  p_inventory_item_segment17 IS NULL )))
       AND (    ( Recinfo.inventory_item_segment18 = p_inventory_item_segment18)
            OR (    ( Recinfo.inventory_item_segment18 IS NULL )
                AND (  p_inventory_item_segment18 IS NULL )))
       AND (    ( Recinfo.inventory_item_segment19 = p_inventory_item_segment19)
            OR (    ( Recinfo.inventory_item_segment19 IS NULL )
                AND (  p_inventory_item_segment19 IS NULL )))
       AND (    ( Recinfo.inventory_item_segment20 = p_inventory_item_segment20)
            OR (    ( Recinfo.inventory_item_segment20 IS NULL )
                AND (  p_inventory_item_segment20 IS NULL )))
       AND (    ( Recinfo.inventory_item_id = p_inventory_item_id)
            OR (    ( Recinfo.inventory_item_id IS NULL )
                AND (  p_inventory_item_id IS NULL )))
       AND (    ( Recinfo.item_description = p_item_description)
            OR (    ( Recinfo.item_description IS NULL )
                AND (  p_item_description IS NULL )))
       AND (    ( Recinfo.upc_code = p_upc_code)
            OR (    ( Recinfo.upc_code IS NULL )
                AND (  p_upc_code IS NULL )))
       AND (    ( Recinfo.item_number = p_item_number)
            OR (    ( Recinfo.item_number IS NULL )
                AND (  p_item_number IS NULL )))
       AND (    ( Recinfo.direct_customer_flag = p_direct_customer_flag)
            OR (    ( Recinfo.direct_customer_flag IS NULL )
                AND (  p_direct_customer_flag IS NULL )))
       AND (    ( Recinfo.attribute_category = p_attribute_category)
            OR (    ( Recinfo.attribute_category IS NULL )
                AND (  p_attribute_category IS NULL )))
       AND (    ( Recinfo.attribute1 = p_attribute1)
            OR (    ( Recinfo.attribute1 IS NULL )
                AND (  p_attribute1 IS NULL )))
       AND (    ( Recinfo.attribute2 = p_attribute2)
            OR (    ( Recinfo.attribute2 IS NULL )
                AND (  p_attribute2 IS NULL )))
       AND (    ( Recinfo.attribute3 = p_attribute3)
            OR (    ( Recinfo.attribute3 IS NULL )
                AND (  p_attribute3 IS NULL )))
       AND (    ( Recinfo.attribute4 = p_attribute4)
            OR (    ( Recinfo.attribute4 IS NULL )
                AND (  p_attribute4 IS NULL )))
       AND (    ( Recinfo.attribute5 = p_attribute5)
            OR (    ( Recinfo.attribute5 IS NULL )
                AND (  p_attribute5 IS NULL )))
       AND (    ( Recinfo.attribute6 = p_attribute6)
            OR (    ( Recinfo.attribute6 IS NULL )
                AND (  p_attribute6 IS NULL )))
       AND (    ( Recinfo.attribute7 = p_attribute7)
            OR (    ( Recinfo.attribute7 IS NULL )
                AND (  p_attribute7 IS NULL )))
       AND (    ( Recinfo.attribute8 = p_attribute8)
            OR (    ( Recinfo.attribute8 IS NULL )
                AND (  p_attribute8 IS NULL )))
       AND (    ( Recinfo.attribute9 = p_attribute9)
            OR (    ( Recinfo.attribute9 IS NULL )
                AND (  p_attribute9 IS NULL )))
       AND (    ( Recinfo.attribute10 = p_attribute10)
            OR (    ( Recinfo.attribute10 IS NULL )
                AND (  p_attribute10 IS NULL )))
       AND (    ( Recinfo.attribute11 = p_attribute11)
            OR (    ( Recinfo.attribute11 IS NULL )
                AND (  p_attribute11 IS NULL )))
       AND (    ( Recinfo.attribute12 = p_attribute12)
            OR (    ( Recinfo.attribute12 IS NULL )
                AND (  p_attribute12 IS NULL )))
       AND (    ( Recinfo.attribute13 = p_attribute13)
            OR (    ( Recinfo.attribute13 IS NULL )
                AND (  p_attribute13 IS NULL )))
       AND (    ( Recinfo.attribute14 = p_attribute14)
            OR (    ( Recinfo.attribute14 IS NULL )
                AND (  p_attribute14 IS NULL )))
       AND (    ( Recinfo.attribute15 = p_attribute15)
            OR (    ( Recinfo.attribute15 IS NULL )
                AND (  p_attribute15 IS NULL )))
       AND (    ( Recinfo.line_attribute_category = p_line_attribute_category)
            OR (    ( Recinfo.line_attribute_category IS NULL )
                AND (  p_line_attribute_category IS NULL )))
       AND (    ( Recinfo.line_attribute1 = p_line_attribute1)
            OR (    ( Recinfo.line_attribute1 IS NULL )
                AND (  p_line_attribute1 IS NULL )))
       AND (    ( Recinfo.line_attribute2 = p_line_attribute2)
            OR (    ( Recinfo.line_attribute2 IS NULL )
                AND (  p_line_attribute2 IS NULL )))
       AND (    ( Recinfo.line_attribute3 = p_line_attribute3)
            OR (    ( Recinfo.line_attribute3 IS NULL )
                AND (  p_line_attribute3 IS NULL )))
       AND (    ( Recinfo.line_attribute4 = p_line_attribute4)
            OR (    ( Recinfo.line_attribute4 IS NULL )
                AND (  p_line_attribute4 IS NULL )))
       AND (    ( Recinfo.line_attribute5 = p_line_attribute5)
            OR (    ( Recinfo.line_attribute5 IS NULL )
                AND (  p_line_attribute5 IS NULL )))
       AND (    ( Recinfo.line_attribute6 = p_line_attribute6)
            OR (    ( Recinfo.line_attribute6 IS NULL )
                AND (  p_line_attribute6 IS NULL )))
       AND (    ( Recinfo.line_attribute7 = p_line_attribute7)
            OR (    ( Recinfo.line_attribute7 IS NULL )
                AND (  p_line_attribute7 IS NULL )))
       AND (    ( Recinfo.line_attribute8 = p_line_attribute8)
            OR (    ( Recinfo.line_attribute8 IS NULL )
                AND (  p_line_attribute8 IS NULL )))
       AND (    ( Recinfo.line_attribute9 = p_line_attribute9)
            OR (    ( Recinfo.line_attribute9 IS NULL )
                AND (  p_line_attribute9 IS NULL )))
       AND (    ( Recinfo.line_attribute10 = p_line_attribute10)
            OR (    ( Recinfo.line_attribute10 IS NULL )
                AND (  p_line_attribute10 IS NULL )))
       AND (    ( Recinfo.line_attribute11 = p_line_attribute11)
            OR (    ( Recinfo.line_attribute11 IS NULL )
                AND (  p_line_attribute11 IS NULL )))
       AND (    ( Recinfo.line_attribute12 = p_line_attribute12)
            OR (    ( Recinfo.line_attribute12 IS NULL )
                AND (  p_line_attribute12 IS NULL )))
       AND (    ( Recinfo.line_attribute13 = p_line_attribute13)
            OR (    ( Recinfo.line_attribute13 IS NULL )
                AND (  p_line_attribute13 IS NULL )))
       AND (    ( Recinfo.line_attribute14 = p_line_attribute14)
            OR (    ( Recinfo.line_attribute14 IS NULL )
                AND (  p_line_attribute14 IS NULL )))
       AND (    ( Recinfo.line_attribute15 = p_line_attribute15)
            OR (    ( Recinfo.line_attribute15 IS NULL )
                AND (  p_line_attribute15 IS NULL )))
       AND (    ( Recinfo.org_id = p_org_id)
            OR (    ( Recinfo.org_id IS NULL )
                AND (  p_org_id IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

END OZF_RESALE_LINES_PKG;

/
