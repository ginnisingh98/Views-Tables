--------------------------------------------------------
--  DDL for Package Body OZF_CLAIMS_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_CLAIMS_HISTORY_PKG" as
/* $Header: ozftchib.pls 120.2 2005/09/09 06:05:24 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_CLAIMS_HISTORY_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_CLAIMS_HISTORY_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozftchib.pls';


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
          px_claim_history_id   IN OUT NOCOPY NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_request_id    NUMBER,
          p_program_application_id    NUMBER,
          p_program_update_date    DATE,
          p_program_id    NUMBER,
          p_created_from    VARCHAR2,
          p_batch_id    NUMBER,
          p_claim_id    NUMBER,
          p_claim_number    VARCHAR2,
          p_claim_type_id    NUMBER,
          p_claim_class    VARCHAR2,
          p_claim_date    DATE,
          p_due_date    DATE,
          p_owner_id    NUMBER,
          p_history_event    VARCHAR2,
          p_history_event_date    DATE,
          p_history_event_description    VARCHAR2,
          p_split_from_claim_id    NUMBER,
          p_duplicate_claim_id    NUMBER,
          p_split_date    DATE,
          p_root_claim_id    NUMBER,
          p_amount    NUMBER,
          p_amount_adjusted    NUMBER,
          p_amount_remaining    NUMBER,
          p_amount_settled    NUMBER,
          p_acctd_amount    NUMBER,
          p_acctd_amount_remaining    NUMBER,
	       p_acctd_amount_adjusted    NUMBER,
          p_acctd_amount_settled    NUMBER,
          p_tax_amount    NUMBER,
          p_tax_code    VARCHAR2,
          p_tax_calculation_flag    VARCHAR2,
          p_currency_code    VARCHAR2,
          p_exchange_rate_type    VARCHAR2,
          p_exchange_rate_date    DATE,
          p_exchange_rate    NUMBER,
          p_set_of_books_id    NUMBER,
          p_original_claim_date    DATE,
          p_source_object_id    NUMBER,
          p_source_object_class    VARCHAR2,
          p_source_object_type_id    NUMBER,
          p_source_object_number    VARCHAR2,
          p_cust_account_id    NUMBER,
          p_cust_billto_acct_site_id    NUMBER,
          p_cust_shipto_acct_site_id    NUMBER,
          p_location_id    NUMBER,
          p_pay_related_account_flag    VARCHAR2,
          p_related_cust_account_id    NUMBER,
          p_related_site_use_id    NUMBER,
          p_relationship_type    VARCHAR2,
          p_vendor_id    NUMBER,
          p_vendor_site_id    NUMBER,
          p_reason_type    VARCHAR2,
          p_reason_code_id    NUMBER,
          p_task_template_group_id    NUMBER,
          p_status_code    VARCHAR2,
          p_user_status_id    NUMBER,
          p_sales_rep_id    NUMBER,
          p_collector_id    NUMBER,
          p_contact_id    NUMBER,
          p_broker_id    NUMBER,
          p_territory_id    NUMBER,
          p_customer_ref_date    DATE,
          p_customer_ref_number    VARCHAR2,
          p_assigned_to    NUMBER,
          p_receipt_id    NUMBER,
          p_receipt_number    VARCHAR2,
          p_doc_sequence_id    NUMBER,
          p_doc_sequence_value    VARCHAR2,
          p_gl_date    DATE,
          p_payment_method    VARCHAR2,
          p_voucher_id    NUMBER,
          p_voucher_number    VARCHAR2,
          p_payment_reference_id    NUMBER,
          p_payment_reference_number    VARCHAR2,
          p_payment_reference_date    DATE,
          p_payment_status    VARCHAR2,
          p_approved_flag    VARCHAR2,
          p_approved_date    DATE,
          p_approved_by    NUMBER,
          p_settled_date    DATE,
          p_settled_by    NUMBER,
          p_effective_date    DATE,
          p_custom_setup_id    NUMBER,
          p_task_id    NUMBER,
          p_country_id    NUMBER,
	       p_order_type_id    NUMBER,
          p_comments    VARCHAR2,
          p_letter_id    NUMBER,
          p_letter_date    DATE,
          p_task_source_object_id    NUMBER,
          p_task_source_object_type_code    VARCHAR2,
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
          p_deduction_attribute_category    VARCHAR2,
          p_deduction_attribute1    VARCHAR2,
          p_deduction_attribute2    VARCHAR2,
          p_deduction_attribute3    VARCHAR2,
          p_deduction_attribute4    VARCHAR2,
          p_deduction_attribute5    VARCHAR2,
          p_deduction_attribute6    VARCHAR2,
          p_deduction_attribute7    VARCHAR2,
          p_deduction_attribute8    VARCHAR2,
          p_deduction_attribute9    VARCHAR2,
          p_deduction_attribute10    VARCHAR2,
          p_deduction_attribute11    VARCHAR2,
          p_deduction_attribute12    VARCHAR2,
          p_deduction_attribute13    VARCHAR2,
          p_deduction_attribute14    VARCHAR2,
          p_deduction_attribute15    VARCHAR2,
          px_org_id   IN OUT NOCOPY NUMBER,
          p_write_off_flag             VARCHAR2,
          p_write_off_threshold_amount NUMBER,
          p_under_write_off_threshold  VARCHAR2,
          p_customer_reason            VARCHAR2,
          p_ship_to_cust_account_id    NUMBER,
          p_amount_applied             NUMBER,
          p_applied_receipt_id         NUMBER,
          p_applied_receipt_number     VARCHAR2,
          p_wo_rec_trx_id              NUMBER,
          p_group_claim_id             NUMBER,
          p_appr_wf_item_key           VARCHAR2,
          p_cstl_wf_item_key           VARCHAR2,
          p_batch_type                 VARCHAR2
          )

 IS
   x_rowid    VARCHAR2(30);


BEGIN

   -- R12 Enhancements
   IF (px_org_id IS NULL OR px_org_id = FND_API.G_MISS_NUM) THEN
      px_org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();
   END IF;


   px_object_version_number := 1;


   INSERT INTO OZF_CLAIMS_HISTORY_ALL(
           claim_history_id,
           object_version_number,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           request_id,
           program_application_id,
           program_update_date,
           program_id,
           created_from,
           batch_id,
           claim_id,
           claim_number,
           claim_type_id,
           claim_class,
           claim_date,
           due_date,
           owner_id,
           history_event,
           history_event_date,
           history_event_description,
           split_from_claim_id,
           duplicate_claim_id,
           split_date,
           root_claim_id,
           amount,
           amount_adjusted,
           amount_remaining,
           amount_settled,
           acctd_amount,
           acctd_amount_remaining,
	        acctd_amount_adjusted,
           acctd_amount_settled,
           tax_amount,
           tax_code,
           tax_calculation_flag,
           currency_code,
           exchange_rate_type,
           exchange_rate_date,
           exchange_rate,
           set_of_books_id,
           original_claim_date,
           source_object_id,
           source_object_class,
           source_object_type_id,
           source_object_number,
           cust_account_id,
           cust_billto_acct_site_id,
           cust_shipto_acct_site_id,
           location_id,
           pay_related_account_flag,
           related_cust_account_id,
           related_site_use_id,
           relationship_type,
           vendor_id,
           vendor_site_id,
           reason_type,
           reason_code_id,
           task_template_group_id,
           status_code,
           user_status_id,
           sales_rep_id,
           collector_id,
           contact_id,
           broker_id,
           territory_id,
           customer_ref_date,
           customer_ref_number,
           assigned_to,
           receipt_id,
           receipt_number,
           doc_sequence_id,
           doc_sequence_value,
           gl_date,
           payment_method,
           voucher_id,
           voucher_number,
           payment_reference_id,
           payment_reference_number,
           payment_reference_date,
           payment_status,
           approved_flag,
           approved_date,
           approved_by,
           settled_date,
           settled_by,
           effective_date,
           custom_setup_id,
           task_id,
           country_id,
	        order_type_id,
           comments,
           letter_id,
           letter_date,
           task_source_object_id,
           task_source_object_type_code,
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
           deduction_attribute_category,
           deduction_attribute1,
           deduction_attribute2,
           deduction_attribute3,
           deduction_attribute4,
           deduction_attribute5,
           deduction_attribute6,
           deduction_attribute7,
           deduction_attribute8,
           deduction_attribute9,
           deduction_attribute10,
           deduction_attribute11,
           deduction_attribute12,
           deduction_attribute13,
           deduction_attribute14,
           deduction_attribute15,
           org_id,
           write_off_flag,
           write_off_threshold_amount,
           under_write_off_threshold,
           customer_reason,
           ship_to_cust_account_id,
           amount_applied,
           applied_receipt_id,
           applied_receipt_number,
           wo_rec_trx_id,
           group_claim_id,
           appr_wf_item_key,
           cstl_wf_item_key,
           batch_type
   ) VALUES (
           px_claim_history_id,
           px_object_version_number,
           p_last_update_date,
           p_last_updated_by,
           p_creation_date,
           p_created_by,
           p_last_update_login,
           p_request_id,
           p_program_application_id,
           p_program_update_date,
           p_program_id,
           p_created_from,
           p_batch_id,
           p_claim_id,
           p_claim_number,
           p_claim_type_id,
           p_claim_class,
           p_claim_date,
           p_due_date,
           p_owner_id,
           p_history_event,
           p_history_event_date,
           p_history_event_description,
           p_split_from_claim_id,
           p_duplicate_claim_id,
           p_split_date,
           p_root_claim_id,
           p_amount,
           p_amount_adjusted,
           p_amount_remaining,
           p_amount_settled,
           p_acctd_amount,
           p_acctd_amount_remaining,
           p_acctd_amount_adjusted,
           p_acctd_amount_settled,
           p_tax_amount,
           p_tax_code,
           p_tax_calculation_flag,
           p_currency_code,
           p_exchange_rate_type,
           p_exchange_rate_date,
           p_exchange_rate,
           p_set_of_books_id,
           p_original_claim_date,
           p_source_object_id,
           p_source_object_class,
           p_source_object_type_id,
           p_source_object_number,
           p_cust_account_id,
           p_cust_billto_acct_site_id,
           p_cust_shipto_acct_site_id,
           p_location_id,
           p_pay_related_account_flag,
           p_related_cust_account_id,
           p_related_site_use_id,
           p_relationship_type,
           p_vendor_id,
           p_vendor_site_id,
           p_reason_type,
           p_reason_code_id,
           p_task_template_group_id,
           p_status_code,
           p_user_status_id,
           p_sales_rep_id,
           p_collector_id,
           p_contact_id,
           p_broker_id,
           p_territory_id,
           p_customer_ref_date,
           p_customer_ref_number,
           p_assigned_to,
           p_receipt_id,
           p_receipt_number,
           p_doc_sequence_id,
           p_doc_sequence_value,
           p_gl_date,
           p_payment_method,
           p_voucher_id,
           p_voucher_number,
           p_payment_reference_id,
           p_payment_reference_number,
           p_payment_reference_date,
           p_payment_status,
           p_approved_flag,
           p_approved_date,
           p_approved_by,
           p_settled_date,
           p_settled_by,
           p_effective_date,
           p_custom_setup_id,
           p_task_id,
           p_country_id,
           p_order_type_id,
	        p_comments,
           p_letter_id,
           p_letter_date,
           p_task_source_object_id,
           p_task_source_object_type_code,
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
           p_deduction_attribute_category,
           p_deduction_attribute1,
           p_deduction_attribute2,
           p_deduction_attribute3,
           p_deduction_attribute4,
           p_deduction_attribute5,
           p_deduction_attribute6,
           p_deduction_attribute7,
           p_deduction_attribute8,
           p_deduction_attribute9,
           p_deduction_attribute10,
           p_deduction_attribute11,
           p_deduction_attribute12,
           p_deduction_attribute13,
           p_deduction_attribute14,
           p_deduction_attribute15,
           px_org_id,
           p_write_off_flag,
           p_write_off_threshold_amount,
           p_under_write_off_threshold,
           p_customer_reason,
           p_ship_to_cust_account_id,
           p_amount_applied,
           p_applied_receipt_id,
           p_applied_receipt_number,
           p_wo_rec_trx_id,
           p_group_claim_id,
           p_appr_wf_item_key,
           p_cstl_wf_item_key,
           p_batch_type
);
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
          p_claim_history_id    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_request_id    NUMBER,
          p_program_application_id    NUMBER,
          p_program_update_date    DATE,
          p_program_id    NUMBER,
          p_created_from    VARCHAR2,
          p_batch_id    NUMBER,
          p_claim_id    NUMBER,
          p_claim_number    VARCHAR2,
          p_claim_type_id    NUMBER,
          p_claim_class    VARCHAR2,
          p_claim_date    DATE,
          p_due_date    DATE,
          p_owner_id    NUMBER,
          p_history_event    VARCHAR2,
          p_history_event_date    DATE,
          p_history_event_description    VARCHAR2,
          p_split_from_claim_id    NUMBER,
          p_duplicate_claim_id    NUMBER,
          p_split_date    DATE,
          p_root_claim_id    NUMBER,
          p_amount    NUMBER,
          p_amount_adjusted    NUMBER,
          p_amount_remaining    NUMBER,
          p_amount_settled    NUMBER,
          p_acctd_amount    NUMBER,
          p_acctd_amount_remaining    NUMBER,
          p_acctd_amount_adjusted    NUMBER,
          p_acctd_amount_settled    NUMBER,
	       p_tax_amount    NUMBER,
          p_tax_code    VARCHAR2,
          p_tax_calculation_flag    VARCHAR2,
          p_currency_code    VARCHAR2,
          p_exchange_rate_type    VARCHAR2,
          p_exchange_rate_date    DATE,
          p_exchange_rate    NUMBER,
          p_set_of_books_id    NUMBER,
          p_original_claim_date    DATE,
          p_source_object_id    NUMBER,
          p_source_object_class    VARCHAR2,
          p_source_object_type_id    NUMBER,
          p_source_object_number    VARCHAR2,
          p_cust_account_id    NUMBER,
          p_cust_billto_acct_site_id    NUMBER,
          p_cust_shipto_acct_site_id    NUMBER,
          p_location_id    NUMBER,
          p_pay_related_account_flag    VARCHAR2,
          p_related_cust_account_id    NUMBER,
          p_related_site_use_id    NUMBER,
          p_relationship_type    VARCHAR2,
          p_vendor_id    NUMBER,
          p_vendor_site_id    NUMBER,
          p_reason_type    VARCHAR2,
          p_reason_code_id    NUMBER,
          p_task_template_group_id    NUMBER,
          p_status_code    VARCHAR2,
          p_user_status_id    NUMBER,
          p_sales_rep_id    NUMBER,
          p_collector_id    NUMBER,
          p_contact_id    NUMBER,
          p_broker_id    NUMBER,
          p_territory_id    NUMBER,
          p_customer_ref_date    DATE,
          p_customer_ref_number    VARCHAR2,
          p_assigned_to    NUMBER,
          p_receipt_id    NUMBER,
          p_receipt_number    VARCHAR2,
          p_doc_sequence_id    NUMBER,
          p_doc_sequence_value    VARCHAR2,
          p_gl_date    DATE,
          p_payment_method    VARCHAR2,
          p_voucher_id    NUMBER,
          p_voucher_number    VARCHAR2,
          p_payment_reference_id    NUMBER,
          p_payment_reference_number    VARCHAR2,
          p_payment_reference_date    DATE,
          p_payment_status    VARCHAR2,
          p_approved_flag    VARCHAR2,
          p_approved_date    DATE,
          p_approved_by    NUMBER,
          p_settled_date    DATE,
          p_settled_by    NUMBER,
          p_effective_date    DATE,
          p_custom_setup_id    NUMBER,
          p_task_id    NUMBER,
          p_country_id    NUMBER,
	       p_order_type_id NUMBER,
          p_comments    VARCHAR2,
          p_letter_id    NUMBER,
          p_letter_date    DATE,
          p_task_source_object_id    NUMBER,
          p_task_source_object_type_code    VARCHAR2,
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
          p_deduction_attribute_category    VARCHAR2,
          p_deduction_attribute1    VARCHAR2,
          p_deduction_attribute2    VARCHAR2,
          p_deduction_attribute3    VARCHAR2,
          p_deduction_attribute4    VARCHAR2,
          p_deduction_attribute5    VARCHAR2,
          p_deduction_attribute6    VARCHAR2,
          p_deduction_attribute7    VARCHAR2,
          p_deduction_attribute8    VARCHAR2,
          p_deduction_attribute9    VARCHAR2,
          p_deduction_attribute10    VARCHAR2,
          p_deduction_attribute11    VARCHAR2,
          p_deduction_attribute12    VARCHAR2,
          p_deduction_attribute13    VARCHAR2,
          p_deduction_attribute14    VARCHAR2,
          p_deduction_attribute15    VARCHAR2,
          p_org_id    NUMBER,
          p_write_off_flag             VARCHAR2,
          p_write_off_threshold_amount NUMBER,
          p_under_write_off_threshold  VARCHAR2,
          p_customer_reason            VARCHAR2,
          p_ship_to_cust_account_id    NUMBER,
          p_amount_applied             NUMBER,
          p_applied_receipt_id         NUMBER,
          p_applied_receipt_number     VARCHAR2,
          p_wo_rec_trx_id              NUMBER,
          p_group_claim_id             NUMBER,
          p_appr_wf_item_key           VARCHAR2,
          p_cstl_wf_item_key           VARCHAR2,
          p_batch_type                 VARCHAR2

          )

 IS
 BEGIN
    Update OZF_CLAIMS_HISTORY_ALL
    SET
              claim_history_id = p_claim_history_id,
              object_version_number = p_object_version_number,
              last_update_date = p_last_update_date,
              last_updated_by = p_last_updated_by,
              last_update_login = p_last_update_login,
              request_id = p_request_id,
              program_application_id = p_program_application_id,
              program_update_date = p_program_update_date,
              program_id = p_program_id,
              created_from = p_created_from,
              batch_id = p_batch_id,
              claim_id = p_claim_id,
              claim_number = p_claim_number,
              claim_type_id = p_claim_type_id,
              claim_class = p_claim_class,
              claim_date = p_claim_date,
              due_date = p_due_date,
              owner_id = p_owner_id,
              history_event = p_history_event,
              history_event_date = p_history_event_date,
              history_event_description = p_history_event_description,
              split_from_claim_id = p_split_from_claim_id,
              duplicate_claim_id = p_duplicate_claim_id,
              split_date = p_split_date,
              root_claim_id = p_root_claim_id,
              amount = p_amount,
              amount_adjusted = p_amount_adjusted,
              amount_remaining = p_amount_remaining,
              amount_settled = p_amount_settled,
              acctd_amount = p_acctd_amount,
              acctd_amount_remaining = p_acctd_amount_remaining,
              acctd_amount_adjusted = p_acctd_amount_adjusted,
              acctd_amount_settled = p_acctd_amount_settled,
              tax_amount = p_tax_amount,
              tax_code = p_tax_code,
              tax_calculation_flag = p_tax_calculation_flag,
              currency_code = p_currency_code,
              exchange_rate_type = p_exchange_rate_type,
              exchange_rate_date = p_exchange_rate_date,
              exchange_rate = p_exchange_rate,
              set_of_books_id = p_set_of_books_id,
              original_claim_date = p_original_claim_date,
              source_object_id = p_source_object_id,
              source_object_class = p_source_object_class,
              source_object_type_id = p_source_object_type_id,
              source_object_number = p_source_object_number,
              cust_account_id = p_cust_account_id,
              cust_billto_acct_site_id = p_cust_billto_acct_site_id,
              cust_shipto_acct_site_id = p_cust_shipto_acct_site_id,
              location_id = p_location_id,
              pay_related_account_flag = p_pay_related_account_flag,
              related_cust_account_id = p_related_cust_account_id,
              related_site_use_id = p_related_site_use_id,
              relationship_type = p_relationship_type,
              vendor_id = p_vendor_id,
              vendor_site_id = p_vendor_site_id,
              reason_type = p_reason_type,
              reason_code_id = p_reason_code_id,
              task_template_group_id = p_task_template_group_id,
              status_code = p_status_code,
              user_status_id = p_user_status_id,
              sales_rep_id = p_sales_rep_id,
              collector_id = p_collector_id,
              contact_id = p_contact_id,
              broker_id = p_broker_id,
              territory_id = p_territory_id,
              customer_ref_date = p_customer_ref_date,
              customer_ref_number = p_customer_ref_number,
              assigned_to = p_assigned_to,
              receipt_id = p_receipt_id,
              receipt_number = p_receipt_number,
              doc_sequence_id = p_doc_sequence_id,
              doc_sequence_value = p_doc_sequence_value,
              gl_date = p_gl_date,
              payment_method = p_payment_method,
              voucher_id = p_voucher_id,
              voucher_number = p_voucher_number,
              payment_reference_id = p_payment_reference_id,
              payment_reference_number = p_payment_reference_number,
              payment_reference_date = p_payment_reference_date,
              payment_status = p_payment_status,
              approved_flag = p_approved_flag,
              approved_date = p_approved_date,
              approved_by = p_approved_by,
              settled_date = p_settled_date,
              settled_by = p_settled_by,
              effective_date = p_effective_date,
              custom_setup_id = p_custom_setup_id,
              task_id = p_task_id,
              country_id = p_country_id,
	           order_type_id = p_order_type_id,
              comments = p_comments,
              letter_id = p_letter_id,
              letter_date = p_letter_date,
              task_source_object_id = p_task_source_object_id,
              task_source_object_type_code = p_task_source_object_type_code,
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
              deduction_attribute_category = p_deduction_attribute_category,
              deduction_attribute1 = p_deduction_attribute1,
              deduction_attribute2 = p_deduction_attribute2,
              deduction_attribute3 = p_deduction_attribute3,
              deduction_attribute4 = p_deduction_attribute4,
              deduction_attribute5 = p_deduction_attribute5,
              deduction_attribute6 = p_deduction_attribute6,
              deduction_attribute7 = p_deduction_attribute7,
              deduction_attribute8 = p_deduction_attribute8,
              deduction_attribute9 = p_deduction_attribute9,
              deduction_attribute10 = p_deduction_attribute10,
              deduction_attribute11 = p_deduction_attribute11,
              deduction_attribute12 = p_deduction_attribute12,
              deduction_attribute13 = p_deduction_attribute13,
              deduction_attribute14 = p_deduction_attribute14,
              deduction_attribute15 = p_deduction_attribute15,
              org_id = p_org_id,
              write_off_flag =  p_write_off_flag,
              write_off_threshold_amount = p_write_off_threshold_amount,
              under_write_off_threshold = p_under_write_off_threshold,
              customer_reason = p_customer_reason,
              ship_to_cust_account_id = p_ship_to_cust_account_id,
              amount_applied = p_amount_applied,
              applied_receipt_id = p_applied_receipt_id,
              applied_receipt_number = p_applied_receipt_number,
              wo_rec_trx_id = p_wo_rec_trx_id,
              group_claim_id = p_group_claim_id,
              appr_wf_item_key = p_appr_wf_item_key,
              cstl_wf_item_key = p_cstl_wf_item_key,
              batch_type = p_batch_type
   WHERE CLAIM_HISTORY_ID = p_CLAIM_HISTORY_ID;
--   AND   object_version_number = p_object_version_number;

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
    p_CLAIM_HISTORY_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM OZF_CLAIMS_HISTORY_ALL
    WHERE CLAIM_HISTORY_ID = p_CLAIM_HISTORY_ID;
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
          p_claim_history_id    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_request_id    NUMBER,
          p_program_application_id    NUMBER,
          p_program_update_date    DATE,
          p_program_id    NUMBER,
          p_created_from    VARCHAR2,
          p_batch_id    NUMBER,
          p_claim_id    NUMBER,
          p_claim_number    VARCHAR2,
          p_claim_type_id    NUMBER,
          p_claim_class    VARCHAR2,
          p_claim_date    DATE,
          p_due_date    DATE,
          p_owner_id    NUMBER,
          p_history_event    VARCHAR2,
          p_history_event_date    DATE,
          p_history_event_description    VARCHAR2,
          p_split_from_claim_id    NUMBER,
          p_duplicate_claim_id    NUMBER,
          p_split_date    DATE,
          p_root_claim_id    NUMBER,
          p_amount    NUMBER,
          p_amount_adjusted    NUMBER,
          p_amount_remaining    NUMBER,
          p_amount_settled    NUMBER,
          p_acctd_amount    NUMBER,
          p_acctd_amount_remaining    NUMBER,
          p_acctd_amount_adjusted    NUMBER,
          p_acctd_amount_settled    NUMBER,
	       p_tax_amount    NUMBER,
          p_tax_code    VARCHAR2,
          p_tax_calculation_flag    VARCHAR2,
          p_currency_code    VARCHAR2,
          p_exchange_rate_type    VARCHAR2,
          p_exchange_rate_date    DATE,
          p_exchange_rate    NUMBER,
          p_set_of_books_id    NUMBER,
          p_original_claim_date    DATE,
          p_source_object_id    NUMBER,
          p_source_object_class    VARCHAR2,
          p_source_object_type_id    NUMBER,
          p_source_object_number    VARCHAR2,
          p_cust_account_id    NUMBER,
          p_cust_billto_acct_site_id    NUMBER,
          p_cust_shipto_acct_site_id    NUMBER,
          p_location_id    NUMBER,
          p_pay_related_account_flag    VARCHAR2,
          p_related_cust_account_id    NUMBER,
          p_related_site_use_id    NUMBER,
          p_relationship_type    VARCHAR2,
          p_vendor_id    NUMBER,
          p_vendor_site_id    NUMBER,
          p_reason_type    VARCHAR2,
          p_reason_code_id    NUMBER,
          p_task_template_group_id    NUMBER,
          p_status_code    VARCHAR2,
          p_user_status_id    NUMBER,
          p_sales_rep_id    NUMBER,
          p_collector_id    NUMBER,
          p_contact_id    NUMBER,
          p_broker_id    NUMBER,
          p_territory_id    NUMBER,
          p_customer_ref_date    DATE,
          p_customer_ref_number    VARCHAR2,
          p_assigned_to    NUMBER,
          p_receipt_id    NUMBER,
          p_receipt_number    VARCHAR2,
          p_doc_sequence_id    NUMBER,
          p_doc_sequence_value    VARCHAR2,
          p_gl_date    DATE,
          p_payment_method    VARCHAR2,
          p_voucher_id    NUMBER,
          p_voucher_number    VARCHAR2,
          p_payment_reference_id    NUMBER,
          p_payment_reference_number    VARCHAR2,
          p_payment_reference_date    DATE,
          p_payment_status    VARCHAR2,
          p_approved_flag    VARCHAR2,
          p_approved_date    DATE,
          p_approved_by    NUMBER,
          p_settled_date    DATE,
          p_settled_by    NUMBER,
          p_effective_date    DATE,
          p_custom_setup_id    NUMBER,
          p_task_id    NUMBER,
          p_country_id    NUMBER,
	       p_order_type_id NUMBER,
          p_comments    VARCHAR2,
          p_letter_id    NUMBER,
          p_letter_date    DATE,
          p_task_source_object_id    NUMBER,
          p_task_source_object_type_code    VARCHAR2,
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
          p_deduction_attribute_category    VARCHAR2,
          p_deduction_attribute1    VARCHAR2,
          p_deduction_attribute2    VARCHAR2,
          p_deduction_attribute3    VARCHAR2,
          p_deduction_attribute4    VARCHAR2,
          p_deduction_attribute5    VARCHAR2,
          p_deduction_attribute6    VARCHAR2,
          p_deduction_attribute7    VARCHAR2,
          p_deduction_attribute8    VARCHAR2,
          p_deduction_attribute9    VARCHAR2,
          p_deduction_attribute10    VARCHAR2,
          p_deduction_attribute11    VARCHAR2,
          p_deduction_attribute12    VARCHAR2,
          p_deduction_attribute13    VARCHAR2,
          p_deduction_attribute14    VARCHAR2,
          p_deduction_attribute15    VARCHAR2,
          p_org_id    NUMBER,
          p_write_off_flag                VARCHAR2,
          p_write_off_threshold_amount    NUMBER,
          p_under_write_off_threshold     VARCHAR2,
          p_customer_reason               VARCHAR2,
          p_ship_to_cust_account_id       NUMBER,
          p_amount_applied                NUMBER,
          p_applied_receipt_id            NUMBER,
          p_applied_receipt_number        VARCHAR2,
          p_wo_rec_trx_id                 NUMBER,
          p_group_claim_id             NUMBER,
          p_appr_wf_item_key           VARCHAR2,
          p_cstl_wf_item_key           VARCHAR2,
          p_batch_type                 VARCHAR2
          )

 IS
   CURSOR C IS
        SELECT *
         FROM OZF_CLAIMS_HISTORY_ALL
        WHERE CLAIM_HISTORY_ID =  p_CLAIM_HISTORY_ID
        FOR UPDATE of CLAIM_HISTORY_ID NOWAIT;
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
           (      Recinfo.claim_history_id = p_claim_history_id)
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
       AND (    ( Recinfo.created_by = p_created_by)
            OR (    ( Recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
       AND (    ( Recinfo.last_update_login = p_last_update_login)
            OR (    ( Recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( Recinfo.request_id = p_request_id)
            OR (    ( Recinfo.request_id IS NULL )
                AND (  p_request_id IS NULL )))
       AND (    ( Recinfo.program_application_id = p_program_application_id)
            OR (    ( Recinfo.program_application_id IS NULL )
                AND (  p_program_application_id IS NULL )))
       AND (    ( Recinfo.program_update_date = p_program_update_date)
            OR (    ( Recinfo.program_update_date IS NULL )
                AND (  p_program_update_date IS NULL )))
       AND (    ( Recinfo.program_id = p_program_id)
            OR (    ( Recinfo.program_id IS NULL )
                AND (  p_program_id IS NULL )))
       AND (    ( Recinfo.created_from = p_created_from)
            OR (    ( Recinfo.created_from IS NULL )
                AND (  p_created_from IS NULL )))
       AND (    ( Recinfo.batch_id = p_batch_id)
            OR (    ( Recinfo.batch_id IS NULL )
                AND (  p_batch_id IS NULL )))
       AND (    ( Recinfo.claim_id = p_claim_id)
            OR (    ( Recinfo.claim_id IS NULL )
                AND (  p_claim_id IS NULL )))
       AND (    ( Recinfo.claim_number = p_claim_number)
            OR (    ( Recinfo.claim_number IS NULL )
                AND (  p_claim_number IS NULL )))
       AND (    ( Recinfo.claim_type_id = p_claim_type_id)
            OR (    ( Recinfo.claim_type_id IS NULL )
                AND (  p_claim_type_id IS NULL )))
       AND (    ( Recinfo.claim_class = p_claim_class)
            OR (    ( Recinfo.claim_class IS NULL )
                AND (  p_claim_class IS NULL )))
       AND (    ( Recinfo.claim_date = p_claim_date)
            OR (    ( Recinfo.claim_date IS NULL )
                AND (  p_claim_date IS NULL )))
       AND (    ( Recinfo.due_date = p_due_date)
            OR (    ( Recinfo.due_date IS NULL )
                AND (  p_due_date IS NULL )))
       AND (    ( Recinfo.owner_id = p_owner_id)
            OR (    ( Recinfo.owner_id IS NULL )
                AND (  p_owner_id IS NULL )))
       AND (    ( Recinfo.history_event = p_history_event)
            OR (    ( Recinfo.history_event IS NULL )
                AND (  p_history_event IS NULL )))
       AND (    ( Recinfo.history_event_date = p_history_event_date)
            OR (    ( Recinfo.history_event_date IS NULL )
                AND (  p_history_event_date IS NULL )))
       AND (    ( Recinfo.history_event_description = p_history_event_description)
            OR (    ( Recinfo.history_event_description IS NULL )
                AND (  p_history_event_description IS NULL )))
       AND (    ( Recinfo.split_from_claim_id = p_split_from_claim_id)
            OR (    ( Recinfo.split_from_claim_id IS NULL )
                AND (  p_split_from_claim_id IS NULL )))
       AND (    ( Recinfo.duplicate_claim_id = p_duplicate_claim_id)
            OR (    ( Recinfo.duplicate_claim_id IS NULL )
                AND (  p_duplicate_claim_id IS NULL )))
       AND (    ( Recinfo.split_date = p_split_date)
            OR (    ( Recinfo.split_date IS NULL )
                AND (  p_split_date IS NULL )))
       AND (    ( Recinfo.root_claim_id = p_root_claim_id)
            OR (    ( Recinfo.root_claim_id IS NULL )
                AND (  p_root_claim_id IS NULL )))
       AND (    ( Recinfo.amount = p_amount)
            OR (    ( Recinfo.amount IS NULL )
                AND (  p_amount IS NULL )))
       AND (    ( Recinfo.amount_adjusted = p_amount_adjusted)
            OR (    ( Recinfo.amount_adjusted IS NULL )
                AND (  p_amount_adjusted IS NULL )))
       AND (    ( Recinfo.amount_remaining = p_amount_remaining)
            OR (    ( Recinfo.amount_remaining IS NULL )
                AND (  p_amount_remaining IS NULL )))
       AND (    ( Recinfo.amount_settled = p_amount_settled)
            OR (    ( Recinfo.amount_settled IS NULL )
                AND (  p_amount_settled IS NULL )))
       AND (    ( Recinfo.acctd_amount = p_acctd_amount)
            OR (    ( Recinfo.acctd_amount IS NULL )
                AND (  p_acctd_amount IS NULL )))
       AND (    ( Recinfo.acctd_amount_remaining = p_acctd_amount_remaining)
            OR (    ( Recinfo.acctd_amount_remaining IS NULL )
                AND (  p_acctd_amount_remaining IS NULL )))
       AND (    ( Recinfo.acctd_amount_adjusted = p_acctd_amount_adjusted)
            OR (    ( Recinfo.acctd_amount_adjusted IS NULL )
                AND (  p_acctd_amount_adjusted IS NULL )))
       AND (    ( Recinfo.acctd_amount_settled = p_acctd_amount_settled)
            OR (    ( Recinfo.acctd_amount_settled IS NULL )
                AND (  p_acctd_amount_settled IS NULL )))
       AND (    ( Recinfo.tax_amount = p_tax_amount)
            OR (    ( Recinfo.tax_amount IS NULL )
                AND (  p_tax_amount IS NULL )))
       AND (    ( Recinfo.tax_code = p_tax_code)
            OR (    ( Recinfo.tax_code IS NULL )
                AND (  p_tax_code IS NULL )))
       AND (    ( Recinfo.tax_calculation_flag = p_tax_calculation_flag)
            OR (    ( Recinfo.tax_calculation_flag IS NULL )
                AND (  p_tax_calculation_flag IS NULL )))
       AND (    ( Recinfo.currency_code = p_currency_code)
            OR (    ( Recinfo.currency_code IS NULL )
                AND (  p_currency_code IS NULL )))
       AND (    ( Recinfo.exchange_rate_type = p_exchange_rate_type)
            OR (    ( Recinfo.exchange_rate_type IS NULL )
                AND (  p_exchange_rate_type IS NULL )))
       AND (    ( Recinfo.exchange_rate_date = p_exchange_rate_date)
            OR (    ( Recinfo.exchange_rate_date IS NULL )
                AND (  p_exchange_rate_date IS NULL )))
       AND (    ( Recinfo.exchange_rate = p_exchange_rate)
            OR (    ( Recinfo.exchange_rate IS NULL )
                AND (  p_exchange_rate IS NULL )))
       AND (    ( Recinfo.set_of_books_id = p_set_of_books_id)
            OR (    ( Recinfo.set_of_books_id IS NULL )
                AND (  p_set_of_books_id IS NULL )))
       AND (    ( Recinfo.original_claim_date = p_original_claim_date)
            OR (    ( Recinfo.original_claim_date IS NULL )
                AND (  p_original_claim_date IS NULL )))
       AND (    ( Recinfo.source_object_id = p_source_object_id)
            OR (    ( Recinfo.source_object_id IS NULL )
                AND (  p_source_object_id IS NULL )))
       AND (    ( Recinfo.source_object_class = p_source_object_class)
            OR (    ( Recinfo.source_object_class IS NULL )
                AND (  p_source_object_class IS NULL )))
       AND (    ( Recinfo.source_object_type_id = p_source_object_type_id)
            OR (    ( Recinfo.source_object_type_id IS NULL )
                AND (  p_source_object_type_id IS NULL )))
       AND (    ( Recinfo.source_object_number = p_source_object_number)
            OR (    ( Recinfo.source_object_number IS NULL )
                AND (  p_source_object_number IS NULL )))
       AND (    ( Recinfo.cust_account_id = p_cust_account_id)
            OR (    ( Recinfo.cust_account_id IS NULL )
                AND (  p_cust_account_id IS NULL )))
       AND (    ( Recinfo.cust_billto_acct_site_id = p_cust_billto_acct_site_id)
            OR (    ( Recinfo.cust_billto_acct_site_id IS NULL )
                AND (  p_cust_billto_acct_site_id IS NULL )))
       AND (    ( Recinfo.cust_shipto_acct_site_id = p_cust_shipto_acct_site_id)
            OR (    ( Recinfo.cust_shipto_acct_site_id IS NULL )
                AND (  p_cust_shipto_acct_site_id IS NULL )))
       AND (    ( Recinfo.location_id = p_location_id)
            OR (    ( Recinfo.location_id IS NULL )
                AND (  p_location_id IS NULL )))
       AND (    ( Recinfo.pay_related_account_flag = p_pay_related_account_flag)
            OR (    ( Recinfo.pay_related_account_flag IS NULL )
                AND (  p_pay_related_account_flag IS NULL )))
       AND (    ( Recinfo.related_cust_account_id = p_related_cust_account_id)
            OR (    ( Recinfo.related_cust_account_id IS NULL )
                AND (  p_related_cust_account_id IS NULL )))
       AND (    ( Recinfo.related_site_use_id = p_related_site_use_id)
            OR (    ( Recinfo.related_site_use_id IS NULL )
                AND (  p_related_site_use_id IS NULL )))
       AND (    ( Recinfo.relationship_type = p_relationship_type)
            OR (    ( Recinfo.relationship_type IS NULL )
                AND (  p_relationship_type IS NULL )))
       AND (    ( Recinfo.vendor_id = p_vendor_id)
            OR (    ( Recinfo.vendor_id IS NULL )
                AND (  p_vendor_id IS NULL )))
       AND (    ( Recinfo.vendor_site_id = p_vendor_site_id)
            OR (    ( Recinfo.vendor_site_id IS NULL )
                AND (  p_vendor_site_id IS NULL )))
       AND (    ( Recinfo.reason_type = p_reason_type)
            OR (    ( Recinfo.reason_type IS NULL )
                AND (  p_reason_type IS NULL )))
       AND (    ( Recinfo.reason_code_id = p_reason_code_id)
            OR (    ( Recinfo.reason_code_id IS NULL )
                AND (  p_reason_code_id IS NULL )))
       AND (    ( Recinfo.task_template_group_id = p_task_template_group_id)
            OR (    ( Recinfo.task_template_group_id IS NULL )
                AND (  p_task_template_group_id IS NULL )))
       AND (    ( Recinfo.status_code = p_status_code)
            OR (    ( Recinfo.status_code IS NULL )
                AND (  p_status_code IS NULL )))
       AND (    ( Recinfo.user_status_id = p_user_status_id)
            OR (    ( Recinfo.user_status_id IS NULL )
                AND (  p_user_status_id IS NULL )))
       AND (    ( Recinfo.sales_rep_id = p_sales_rep_id)
            OR (    ( Recinfo.sales_rep_id IS NULL )
                AND (  p_sales_rep_id IS NULL )))
       AND (    ( Recinfo.collector_id = p_collector_id)
            OR (    ( Recinfo.collector_id IS NULL )
                AND (  p_collector_id IS NULL )))
       AND (    ( Recinfo.contact_id = p_contact_id)
            OR (    ( Recinfo.contact_id IS NULL )
                AND (  p_contact_id IS NULL )))
       AND (    ( Recinfo.broker_id = p_broker_id)
            OR (    ( Recinfo.broker_id IS NULL )
                AND (  p_broker_id IS NULL )))
       AND (    ( Recinfo.territory_id = p_territory_id)
            OR (    ( Recinfo.territory_id IS NULL )
                AND (  p_territory_id IS NULL )))
       AND (    ( Recinfo.customer_ref_date = p_customer_ref_date)
            OR (    ( Recinfo.customer_ref_date IS NULL )
                AND (  p_customer_ref_date IS NULL )))
       AND (    ( Recinfo.customer_ref_number = p_customer_ref_number)
            OR (    ( Recinfo.customer_ref_number IS NULL )
                AND (  p_customer_ref_number IS NULL )))
       AND (    ( Recinfo.assigned_to = p_assigned_to)
            OR (    ( Recinfo.assigned_to IS NULL )
                AND (  p_assigned_to IS NULL )))
       AND (    ( Recinfo.receipt_id = p_receipt_id)
            OR (    ( Recinfo.receipt_id IS NULL )
                AND (  p_receipt_id IS NULL )))
       AND (    ( Recinfo.receipt_number = p_receipt_number)
            OR (    ( Recinfo.receipt_number IS NULL )
                AND (  p_receipt_number IS NULL )))
       AND (    ( Recinfo.doc_sequence_id = p_doc_sequence_id)
            OR (    ( Recinfo.doc_sequence_id IS NULL )
                AND (  p_doc_sequence_id IS NULL )))
       AND (    ( Recinfo.doc_sequence_value = p_doc_sequence_value)
            OR (    ( Recinfo.doc_sequence_value IS NULL )
                AND (  p_doc_sequence_value IS NULL )))
       AND (    ( Recinfo.gl_date = p_gl_date)
            OR (    ( Recinfo.gl_date IS NULL )
                AND (  p_gl_date IS NULL )))
       AND (    ( Recinfo.payment_method = p_payment_method)
            OR (    ( Recinfo.payment_method IS NULL )
                AND (  p_payment_method IS NULL )))
       AND (    ( Recinfo.voucher_id = p_voucher_id)
            OR (    ( Recinfo.voucher_id IS NULL )
                AND (  p_voucher_id IS NULL )))
       AND (    ( Recinfo.voucher_number = p_voucher_number)
            OR (    ( Recinfo.voucher_number IS NULL )
                AND (  p_voucher_number IS NULL )))
       AND (    ( Recinfo.payment_reference_id = p_payment_reference_id)
            OR (    ( Recinfo.payment_reference_id IS NULL )
                AND (  p_payment_reference_id IS NULL )))
       AND (    ( Recinfo.payment_reference_number = p_payment_reference_number)
            OR (    ( Recinfo.payment_reference_number IS NULL )
                AND (  p_payment_reference_number IS NULL )))
       AND (    ( Recinfo.payment_reference_date = p_payment_reference_date)
            OR (    ( Recinfo.payment_reference_date IS NULL )
                AND (  p_payment_reference_date IS NULL )))
       AND (    ( Recinfo.payment_status = p_payment_status)
            OR (    ( Recinfo.payment_status IS NULL )
                AND (  p_payment_status IS NULL )))
       AND (    ( Recinfo.approved_flag = p_approved_flag)
            OR (    ( Recinfo.approved_flag IS NULL )
                AND (  p_approved_flag IS NULL )))
       AND (    ( Recinfo.approved_date = p_approved_date)
            OR (    ( Recinfo.approved_date IS NULL )
                AND (  p_approved_date IS NULL )))
       AND (    ( Recinfo.approved_by = p_approved_by)
            OR (    ( Recinfo.approved_by IS NULL )
                AND (  p_approved_by IS NULL )))
       AND (    ( Recinfo.settled_date = p_settled_date)
            OR (    ( Recinfo.settled_date IS NULL )
                AND (  p_settled_date IS NULL )))
       AND (    ( Recinfo.settled_by = p_settled_by)
            OR (    ( Recinfo.settled_by IS NULL )
                AND (  p_settled_by IS NULL )))
       AND (    ( Recinfo.effective_date = p_effective_date)
            OR (    ( Recinfo.effective_date IS NULL )
                AND (  p_effective_date IS NULL )))
       AND (    ( Recinfo.custom_setup_id = p_custom_setup_id)
            OR (    ( Recinfo.custom_setup_id IS NULL )
                AND (  p_custom_setup_id IS NULL )))
       AND (    ( Recinfo.task_id = p_task_id)
            OR (    ( Recinfo.task_id IS NULL )
                AND (  p_task_id IS NULL )))
       AND (    ( Recinfo.country_id = p_country_id)
            OR (    ( Recinfo.country_id IS NULL )
                AND (  p_country_id IS NULL )))
       AND (    ( Recinfo.order_type_id = p_order_type_id)
            OR (    ( Recinfo.order_type_id IS NULL )
                AND (  p_order_type_id IS NULL )))
       AND (    ( Recinfo.comments = p_comments)
            OR (    ( Recinfo.comments IS NULL )
                AND (  p_comments IS NULL )))
       AND (    ( Recinfo.letter_id = p_letter_id)
            OR (    ( Recinfo.letter_id IS NULL )
                AND (  p_letter_id IS NULL )))
       AND (    ( Recinfo.letter_date = p_letter_date)
            OR (    ( Recinfo.letter_date IS NULL )
                AND (  p_letter_date IS NULL )))
       AND (    ( Recinfo.task_source_object_id = p_task_source_object_id)
            OR (    ( Recinfo.task_source_object_id IS NULL )
                AND (  p_task_source_object_id IS NULL )))
       AND (    ( Recinfo.task_source_object_type_code = p_task_source_object_type_code)
            OR (    ( Recinfo.task_source_object_type_code IS NULL )
                AND (  p_task_source_object_type_code IS NULL )))
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
       AND (    ( Recinfo.deduction_attribute_category = p_deduction_attribute_category)
            OR (    ( Recinfo.deduction_attribute_category IS NULL )
                AND (  p_deduction_attribute_category IS NULL )))
       AND (    ( Recinfo.deduction_attribute1 = p_deduction_attribute1)
            OR (    ( Recinfo.deduction_attribute1 IS NULL )
                AND (  p_deduction_attribute1 IS NULL )))
       AND (    ( Recinfo.deduction_attribute2 = p_deduction_attribute2)
            OR (    ( Recinfo.deduction_attribute2 IS NULL )
                AND (  p_deduction_attribute2 IS NULL )))
       AND (    ( Recinfo.deduction_attribute3 = p_deduction_attribute3)
            OR (    ( Recinfo.deduction_attribute3 IS NULL )
                AND (  p_deduction_attribute3 IS NULL )))
       AND (    ( Recinfo.deduction_attribute4 = p_deduction_attribute4)
            OR (    ( Recinfo.deduction_attribute4 IS NULL )
                AND (  p_deduction_attribute4 IS NULL )))
       AND (    ( Recinfo.deduction_attribute5 = p_deduction_attribute5)
            OR (    ( Recinfo.deduction_attribute5 IS NULL )
                AND (  p_deduction_attribute5 IS NULL )))
       AND (    ( Recinfo.deduction_attribute6 = p_deduction_attribute6)
            OR (    ( Recinfo.deduction_attribute6 IS NULL )
                AND (  p_deduction_attribute6 IS NULL )))
       AND (    ( Recinfo.deduction_attribute7 = p_deduction_attribute7)
            OR (    ( Recinfo.deduction_attribute7 IS NULL )
                AND (  p_deduction_attribute7 IS NULL )))
       AND (    ( Recinfo.deduction_attribute8 = p_deduction_attribute8)
            OR (    ( Recinfo.deduction_attribute8 IS NULL )
                AND (  p_deduction_attribute8 IS NULL )))
       AND (    ( Recinfo.deduction_attribute9 = p_deduction_attribute9)
            OR (    ( Recinfo.deduction_attribute9 IS NULL )
                AND (  p_deduction_attribute9 IS NULL )))
       AND (    ( Recinfo.deduction_attribute10 = p_deduction_attribute10)
            OR (    ( Recinfo.deduction_attribute10 IS NULL )
                AND (  p_deduction_attribute10 IS NULL )))
       AND (    ( Recinfo.deduction_attribute11 = p_deduction_attribute11)
            OR (    ( Recinfo.deduction_attribute11 IS NULL )
                AND (  p_deduction_attribute11 IS NULL )))
       AND (    ( Recinfo.deduction_attribute12 = p_deduction_attribute12)
            OR (    ( Recinfo.deduction_attribute12 IS NULL )
                AND (  p_deduction_attribute12 IS NULL )))
       AND (    ( Recinfo.deduction_attribute13 = p_deduction_attribute13)
            OR (    ( Recinfo.deduction_attribute13 IS NULL )
                AND (  p_deduction_attribute13 IS NULL )))
       AND (    ( Recinfo.deduction_attribute14 = p_deduction_attribute14)
            OR (    ( Recinfo.deduction_attribute14 IS NULL )
                AND (  p_deduction_attribute14 IS NULL )))
       AND (    ( Recinfo.deduction_attribute15 = p_deduction_attribute15)
            OR (    ( Recinfo.deduction_attribute15 IS NULL )
                AND (  p_deduction_attribute15 IS NULL )))
       AND (    ( Recinfo.org_id = p_org_id)
            OR (    ( Recinfo.org_id IS NULL )
                AND (  p_org_id IS NULL )))
       AND (    ( Recinfo.write_off_flag = p_write_off_flag)
            OR (    ( Recinfo.write_off_flag IS NULL )
                AND (  p_write_off_flag IS NULL )))
       AND (    ( Recinfo.write_off_threshold_amount = p_write_off_threshold_amount)
            OR (    ( Recinfo.write_off_threshold_amount IS NULL )
                AND (  p_write_off_threshold_amount IS NULL )))
       AND (    ( Recinfo.under_write_off_threshold = p_under_write_off_threshold)
            OR (    ( Recinfo.under_write_off_threshold IS NULL )
                AND (  p_under_write_off_threshold IS NULL )))
       AND (    ( Recinfo.customer_reason = p_customer_reason)
            OR (    ( Recinfo.customer_reason IS NULL )
                AND (  p_customer_reason IS NULL )))
       AND (    ( Recinfo.ship_to_cust_account_id = p_ship_to_cust_account_id)
            OR (    ( Recinfo.ship_to_cust_account_id IS NULL )
                AND (  p_ship_to_cust_account_id IS NULL )))
       AND (    ( Recinfo.amount_applied = p_amount_applied)
            OR (    ( Recinfo.amount_applied IS NULL )
                AND (  p_amount_applied IS NULL )))
       AND (    ( Recinfo.applied_receipt_id = p_applied_receipt_id)
            OR (    ( Recinfo.applied_receipt_id IS NULL )
                AND (  p_applied_receipt_id IS NULL )))
       AND (    ( Recinfo.applied_receipt_number = p_applied_receipt_number)
            OR (    ( Recinfo.applied_receipt_number IS NULL )
                AND (  p_applied_receipt_number IS NULL )))
       AND (    ( Recinfo.wo_rec_trx_id = p_wo_rec_trx_id)
            OR (    ( Recinfo.wo_rec_trx_id IS NULL )
                AND (  p_wo_rec_trx_id IS NULL )))
       AND (    ( Recinfo.group_claim_id = p_group_claim_id)
            OR (    ( Recinfo.group_claim_id IS NULL )
                AND (  p_group_claim_id IS NULL )))
       AND (    ( Recinfo.appr_wf_item_key = p_appr_wf_item_key)
            OR (    ( Recinfo.appr_wf_item_key IS NULL )
                AND (  p_appr_wf_item_key IS NULL )))
       AND (    ( Recinfo.cstl_wf_item_key = p_cstl_wf_item_key)
            OR (    ( Recinfo.cstl_wf_item_key IS NULL )
                AND (  p_cstl_wf_item_key IS NULL )))
       AND (    ( Recinfo.batch_type = p_batch_type)
            OR (    ( Recinfo.batch_type IS NULL )
                AND (  p_batch_type IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

END OZF_CLAIMS_HISTORY_PKG;

/
