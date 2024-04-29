--------------------------------------------------------
--  DDL for Package Body OZF_AR_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_AR_INTERFACE_PVT" AS
/*$Header: ozfvarib.pls 120.12.12010000.2 2009/11/21 16:16:43 muthsubr ship $*/


   -- Standard Stuff  ------------------

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'ozf_ar_interface_pvt';
G_FILE_NAME     CONSTANT VARCHAR2(12) := 'ozfvaris.pls';
G_OBJECT_TYPE  CONSTANT VARCHAR2(10) := 'OZF_????';
G_OWNER_OBJECT CONSTANT VARCHAR2(30) := 'RS_EMPLOYEE';

OZF_DEBUG_LOW_ON BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);

   --------------------------------------


/* ---------------------------------------------- *
 * Populate the Claim Record
 * ---------------------------------------------- */
PROCEDURE Query_Claim
(   p_claim_id           IN NUMBER
   ,x_claim_rec          IN OUT NOCOPY Claim_Rec_Type
   ,x_return_status      OUT NOCOPY VARCHAR2
)
IS
BEGIN

   SELECT
       CLAIM_ID
      ,OBJECT_VERSION_NUMBER
      ,LAST_UPDATE_DATE
      ,LAST_UPDATED_BY
      ,CREATION_DATE
      ,CREATED_BY
      ,LAST_UPDATE_LOGIN
      ,REQUEST_ID
      ,PROGRAM_APPLICATION_ID
      ,PROGRAM_UPDATE_DATE
      ,PROGRAM_ID
      ,CREATED_FROM
      ,BATCH_ID
      ,CLAIM_NUMBER
      ,CLAIM_TYPE_ID
      ,CLAIM_CLASS
      ,CLAIM_DATE
      ,DUE_DATE
      ,OWNER_ID
      ,HISTORY_EVENT
      ,HISTORY_EVENT_DATE
      ,HISTORY_EVENT_DESCRIPTION
      ,SPLIT_FROM_CLAIM_ID
      ,DUPLICATE_CLAIM_ID
      ,SPLIT_DATE
      ,ROOT_CLAIM_ID
      ,AMOUNT
      ,AMOUNT_ADJUSTED
      ,AMOUNT_REMAINING
      ,AMOUNT_SETTLED
      ,ACCTD_AMOUNT
      ,ACCTD_AMOUNT_REMAINING
      ,TAX_AMOUNT
      ,TAX_CODE
      ,TAX_CALCULATION_FLAG
      ,CURRENCY_CODE
      ,EXCHANGE_RATE_TYPE
      ,EXCHANGE_RATE_DATE
      ,EXCHANGE_RATE
      ,SET_OF_BOOKS_ID
      ,ORIGINAL_CLAIM_DATE
      ,SOURCE_OBJECT_ID
      ,SOURCE_OBJECT_CLASS
      ,SOURCE_OBJECT_TYPE_ID
      ,SOURCE_OBJECT_NUMBER
      ,CUST_ACCOUNT_ID
      ,CUST_BILLTO_ACCT_SITE_ID
      ,CUST_SHIPTO_ACCT_SITE_ID
      ,LOCATION_ID
      ,PAY_RELATED_ACCOUNT_FLAG
      ,RELATED_CUST_ACCOUNT_ID
      ,RELATED_SITE_USE_ID
      ,RELATIONSHIP_TYPE
      ,VENDOR_ID
      ,VENDOR_SITE_ID
      ,REASON_TYPE
      ,REASON_CODE_ID
      ,TASK_TEMPLATE_GROUP_ID
      ,STATUS_CODE
      ,USER_STATUS_ID
      ,SALES_REP_ID
      ,COLLECTOR_ID
      ,CONTACT_ID
      ,BROKER_ID
      ,TERRITORY_ID
      ,CUSTOMER_REF_DATE
      ,CUSTOMER_REF_NUMBER
      ,ASSIGNED_TO
      ,RECEIPT_ID
      ,RECEIPT_NUMBER
      ,DOC_SEQUENCE_ID
      ,DOC_SEQUENCE_VALUE
      ,GL_DATE
      ,PAYMENT_METHOD
      ,VOUCHER_ID
      ,VOUCHER_NUMBER
      ,PAYMENT_REFERENCE_ID
      ,PAYMENT_REFERENCE_NUMBER
      ,PAYMENT_REFERENCE_DATE
      ,PAYMENT_STATUS
      ,APPROVED_FLAG
      ,APPROVED_DATE
      ,APPROVED_BY
      ,SETTLED_DATE
      ,SETTLED_BY
      ,EFFECTIVE_DATE
      ,CUSTOM_SETUP_ID
      ,TASK_ID
      ,COUNTRY_ID
      ,COMMENTS
      ,ATTRIBUTE_CATEGORY
      ,ATTRIBUTE1
      ,ATTRIBUTE2
      ,ATTRIBUTE3
      ,ATTRIBUTE4
      ,ATTRIBUTE5
      ,ATTRIBUTE6
      ,ATTRIBUTE7
      ,ATTRIBUTE8
      ,ATTRIBUTE9
      ,ATTRIBUTE10
      ,ATTRIBUTE11
      ,ATTRIBUTE12
      ,ATTRIBUTE13
      ,ATTRIBUTE14
      ,ATTRIBUTE15
      ,DEDUCTION_ATTRIBUTE_CATEGORY
      ,DEDUCTION_ATTRIBUTE1
      ,DEDUCTION_ATTRIBUTE2
      ,DEDUCTION_ATTRIBUTE3
      ,DEDUCTION_ATTRIBUTE4
      ,DEDUCTION_ATTRIBUTE5
      ,DEDUCTION_ATTRIBUTE6
      ,DEDUCTION_ATTRIBUTE7
      ,DEDUCTION_ATTRIBUTE8
      ,DEDUCTION_ATTRIBUTE9
      ,DEDUCTION_ATTRIBUTE10
      ,DEDUCTION_ATTRIBUTE11
      ,DEDUCTION_ATTRIBUTE12
      ,DEDUCTION_ATTRIBUTE13
      ,DEDUCTION_ATTRIBUTE14
      ,DEDUCTION_ATTRIBUTE15
      ,ORG_ID
      ,CUSTOMER_REASON -- 11.5.10 Enhancements. TM should pass.
      ,SHIP_TO_CUST_ACCOUNT_ID
      ,LEGAL_ENTITY_ID
   INTO
       x_claim_rec.claim_id
      ,x_claim_rec.object_version_number
      ,x_claim_rec.last_update_date
      ,x_claim_rec.last_updated_by
      ,x_claim_rec.creation_date
      ,x_claim_rec.created_by
      ,x_claim_rec.last_update_login
      ,x_claim_rec.request_id
      ,x_claim_rec.program_application_id
      ,x_claim_rec.program_update_date
      ,x_claim_rec.program_id
      ,x_claim_rec.created_from
      ,x_claim_rec.batch_id
      ,x_claim_rec.claim_number
      ,x_claim_rec.claim_type_id
      ,x_claim_rec.claim_class
      ,x_claim_rec.claim_date
      ,x_claim_rec.due_date
      ,x_claim_rec.owner_id
      ,x_claim_rec.history_event
      ,x_claim_rec.history_event_date
      ,x_claim_rec.history_event_description
      ,x_claim_rec.split_from_claim_id
      ,x_claim_rec.duplicate_claim_id
      ,x_claim_rec.split_date
      ,x_claim_rec.root_claim_id
      ,x_claim_rec.amount
      ,x_claim_rec.amount_adjusted
      ,x_claim_rec.amount_remaining
      ,x_claim_rec.amount_settled
      ,x_claim_rec.acctd_amount
      ,x_claim_rec.acctd_amount_remaining
      ,x_claim_rec.tax_amount
      ,x_claim_rec.tax_code
      ,x_claim_rec.tax_calculation_flag
      ,x_claim_rec.currency_code
      ,x_claim_rec.exchange_rate_type
      ,x_claim_rec.exchange_rate_date
      ,x_claim_rec.exchange_rate
      ,x_claim_rec.set_of_books_id
      ,x_claim_rec.original_claim_date
      ,x_claim_rec.source_object_id
      ,x_claim_rec.source_object_class
      ,x_claim_rec.source_object_type_id
      ,x_claim_rec.source_object_number
      ,x_claim_rec.cust_account_id
      ,x_claim_rec.cust_billto_acct_site_id
      ,x_claim_rec.cust_shipto_acct_site_id
      ,x_claim_rec.location_id
      ,x_claim_rec.pay_related_account_flag
      ,x_claim_rec.related_cust_account_id
      ,x_claim_rec.related_site_use_id
      ,x_claim_rec.relationship_type
      ,x_claim_rec.vendor_id
      ,x_claim_rec.vendor_site_id
      ,x_claim_rec.reason_type
      ,x_claim_rec.reason_code_id
      ,x_claim_rec.task_template_group_id
      ,x_claim_rec.status_code
      ,x_claim_rec.user_status_id
      ,x_claim_rec.sales_rep_id
      ,x_claim_rec.collector_id
      ,x_claim_rec.contact_id
      ,x_claim_rec.broker_id
      ,x_claim_rec.territory_id
      ,x_claim_rec.customer_ref_date
      ,x_claim_rec.customer_ref_number
      ,x_claim_rec.assigned_to
      ,x_claim_rec.receipt_id
      ,x_claim_rec.receipt_number
      ,x_claim_rec.doc_sequence_id
      ,x_claim_rec.doc_sequence_value
      ,x_claim_rec.gl_date
      ,x_claim_rec.payment_method
      ,x_claim_rec.voucher_id
      ,x_claim_rec.voucher_number
      ,x_claim_rec.payment_reference_id
      ,x_claim_rec.payment_reference_number
      ,x_claim_rec.payment_reference_date
      ,x_claim_rec.payment_status
      ,x_claim_rec.approved_flag
      ,x_claim_rec.approved_date
      ,x_claim_rec.approved_by
      ,x_claim_rec.settled_date
      ,x_claim_rec.settled_by
      ,x_claim_rec.effective_date
      ,x_claim_rec.custom_setup_id
      ,x_claim_rec.task_id
      ,x_claim_rec.country_id
      ,x_claim_rec.comments
      ,x_claim_rec.attribute_category
      ,x_claim_rec.attribute1
      ,x_claim_rec.attribute2
      ,x_claim_rec.attribute3
      ,x_claim_rec.attribute4
      ,x_claim_rec.attribute5
      ,x_claim_rec.attribute6
      ,x_claim_rec.attribute7
      ,x_claim_rec.attribute8
      ,x_claim_rec.attribute9
      ,x_claim_rec.attribute10
      ,x_claim_rec.attribute11
      ,x_claim_rec.attribute12
      ,x_claim_rec.attribute13
      ,x_claim_rec.attribute14
      ,x_claim_rec.attribute15
      ,x_claim_rec.deduction_attribute_category
      ,x_claim_rec.deduction_attribute1
      ,x_claim_rec.deduction_attribute2
      ,x_claim_rec.deduction_attribute3
      ,x_claim_rec.deduction_attribute4
      ,x_claim_rec.deduction_attribute5
      ,x_claim_rec.deduction_attribute6
      ,x_claim_rec.deduction_attribute7
      ,x_claim_rec.deduction_attribute8
      ,x_claim_rec.deduction_attribute9
      ,x_claim_rec.deduction_attribute10
      ,x_claim_rec.deduction_attribute11
      ,x_claim_rec.deduction_attribute12
      ,x_claim_rec.deduction_attribute13
      ,x_claim_rec.deduction_attribute14
      ,x_claim_rec.deduction_attribute15
      ,x_claim_rec.org_id
      ,x_claim_rec.customer_reason -- 11.5.10 Enhancements. TM should pass.
      ,x_claim_rec.ship_to_cust_account_id
      ,x_claim_rec.legal_entity_id
   FROM  ozf_claims_all
   WHERE claim_id = p_claim_id ;

   x_return_status := FND_API.g_ret_sts_success;
EXCEPTION
   WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_QUERY_ERROR');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;
END Query_Claim;

PROCEDURE Insert_Int_Distributions
(  p_int_distributions_rec   IN  RA_Int_Distributions_Rec_Type
  ,x_return_status           OUT NOCOPY VARCHAR2
) IS
BEGIN
   INSERT INTO RA_INTERFACE_DISTRIBUTIONS_ALL
   (
      INTERFACE_DISTRIBUTION_ID,
      INTERFACE_LINE_ID,
      INTERFACE_LINE_CONTEXT,
      INTERFACE_LINE_ATTRIBUTE1,
      INTERFACE_LINE_ATTRIBUTE2,
      INTERFACE_LINE_ATTRIBUTE3,
      INTERFACE_LINE_ATTRIBUTE4,
      INTERFACE_LINE_ATTRIBUTE5,
      INTERFACE_LINE_ATTRIBUTE6,
      INTERFACE_LINE_ATTRIBUTE7,
      INTERFACE_LINE_ATTRIBUTE8,
      INTERFACE_LINE_ATTRIBUTE9,
      INTERFACE_LINE_ATTRIBUTE10,
      INTERFACE_LINE_ATTRIBUTE11,
      INTERFACE_LINE_ATTRIBUTE12,
      INTERFACE_LINE_ATTRIBUTE13,
      INTERFACE_LINE_ATTRIBUTE14,
      INTERFACE_LINE_ATTRIBUTE15,
      ACCOUNT_CLASS,
      AMOUNT,
      ACCTD_AMOUNT,
      PERCENT,
      INTERFACE_STATUS,
      REQUEST_ID,
      CODE_COMBINATION_ID,
      SEGMENT1,
      SEGMENT2,
      SEGMENT3,
      SEGMENT4,
      SEGMENT5,
      SEGMENT6,
      SEGMENT7,
      SEGMENT8,
      SEGMENT9,
      SEGMENT10,
      SEGMENT11,
      SEGMENT12,
      SEGMENT13,
      SEGMENT14,
      SEGMENT15,
      SEGMENT16,
      SEGMENT17,
      SEGMENT18,
      SEGMENT19,
      SEGMENT20,
      SEGMENT21,
      SEGMENT22,
      SEGMENT23,
      SEGMENT24,
      SEGMENT25,
      SEGMENT26,
      SEGMENT27,
      SEGMENT28,
      SEGMENT29,
      SEGMENT30,
      COMMENTS,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      ORG_ID,
      INTERIM_TAX_CCID,
      INTERIM_TAX_SEGMENT1,
      INTERIM_TAX_SEGMENT2,
      INTERIM_TAX_SEGMENT3,
      INTERIM_TAX_SEGMENT4,
      INTERIM_TAX_SEGMENT5,
      INTERIM_TAX_SEGMENT6,
      INTERIM_TAX_SEGMENT7,
      INTERIM_TAX_SEGMENT8,
      INTERIM_TAX_SEGMENT9,
      INTERIM_TAX_SEGMENT10,
      INTERIM_TAX_SEGMENT11,
      INTERIM_TAX_SEGMENT12,
      INTERIM_TAX_SEGMENT13,
      INTERIM_TAX_SEGMENT14,
      INTERIM_TAX_SEGMENT15,
      INTERIM_TAX_SEGMENT16,
      INTERIM_TAX_SEGMENT17,
      INTERIM_TAX_SEGMENT18,
      INTERIM_TAX_SEGMENT19,
      INTERIM_TAX_SEGMENT20,
      INTERIM_TAX_SEGMENT21,
      INTERIM_TAX_SEGMENT22,
      INTERIM_TAX_SEGMENT23,
      INTERIM_TAX_SEGMENT24,
      INTERIM_TAX_SEGMENT25,
      INTERIM_TAX_SEGMENT26,
      INTERIM_TAX_SEGMENT27,
      INTERIM_TAX_SEGMENT28,
      INTERIM_TAX_SEGMENT29,
      INTERIM_TAX_SEGMENT30
   )
   VALUES
   (
      p_int_distributions_rec.interface_distribution_id,
      p_int_distributions_rec.interface_line_id,
      p_int_distributions_rec.interface_line_context,
      p_int_distributions_rec.interface_line_attribute1,
      p_int_distributions_rec.interface_line_attribute2,
      p_int_distributions_rec.interface_line_attribute3,
      p_int_distributions_rec.interface_line_attribute4,
      p_int_distributions_rec.interface_line_attribute5,
      p_int_distributions_rec.interface_line_attribute6,
      p_int_distributions_rec.interface_line_attribute7,
      p_int_distributions_rec.interface_line_attribute8,
      p_int_distributions_rec.interface_line_attribute9,
      p_int_distributions_rec.interface_line_attribute10,
      p_int_distributions_rec.interface_line_attribute11,
      p_int_distributions_rec.interface_line_attribute12,
      p_int_distributions_rec.interface_line_attribute13,
      p_int_distributions_rec.interface_line_attribute14,
      p_int_distributions_rec.interface_line_attribute15,
      p_int_distributions_rec.account_class,
      p_int_distributions_rec.amount,
      p_int_distributions_rec.acctd_amount,
      p_int_distributions_rec.percent,
      p_int_distributions_rec.interface_status,
      p_int_distributions_rec.request_id,
      p_int_distributions_rec.code_combination_id,
      p_int_distributions_rec.segment1,
      p_int_distributions_rec.segment2,
      p_int_distributions_rec.segment3,
      p_int_distributions_rec.segment4,
      p_int_distributions_rec.segment5,
      p_int_distributions_rec.segment6,
      p_int_distributions_rec.segment7,
      p_int_distributions_rec.segment8,
      p_int_distributions_rec.segment9,
      p_int_distributions_rec.segment10,
      p_int_distributions_rec.segment11,
      p_int_distributions_rec.segment12,
      p_int_distributions_rec.segment13,
      p_int_distributions_rec.segment14,
      p_int_distributions_rec.segment15,
      p_int_distributions_rec.segment16,
      p_int_distributions_rec.segment17,
      p_int_distributions_rec.segment18,
      p_int_distributions_rec.segment19,
      p_int_distributions_rec.segment20,
      p_int_distributions_rec.segment21,
      p_int_distributions_rec.segment22,
      p_int_distributions_rec.segment23,
      p_int_distributions_rec.segment24,
      p_int_distributions_rec.segment25,
      p_int_distributions_rec.segment26,
      p_int_distributions_rec.segment27,
      p_int_distributions_rec.segment28,
      p_int_distributions_rec.segment29,
      p_int_distributions_rec.segment30,
      p_int_distributions_rec.comments,
      p_int_distributions_rec.attribute_category,
      p_int_distributions_rec.attribute1,
      p_int_distributions_rec.attribute2,
      p_int_distributions_rec.attribute3,
      p_int_distributions_rec.attribute4,
      p_int_distributions_rec.attribute5,
      p_int_distributions_rec.attribute6,
      p_int_distributions_rec.attribute7,
      p_int_distributions_rec.attribute8,
      p_int_distributions_rec.attribute9,
      p_int_distributions_rec.attribute10,
      p_int_distributions_rec.attribute11,
      p_int_distributions_rec.attribute12,
      p_int_distributions_rec.attribute13,
      p_int_distributions_rec.attribute14,
      p_int_distributions_rec.attribute15,
      p_int_distributions_rec.created_by,
      p_int_distributions_rec.creation_date,
      p_int_distributions_rec.last_updated_by,
      p_int_distributions_rec.last_update_date,
      p_int_distributions_rec.last_update_login,
      p_int_distributions_rec.org_id,
      p_int_distributions_rec.interim_tax_ccid,
      p_int_distributions_rec.interim_tax_segment1,
      p_int_distributions_rec.interim_tax_segment2,
      p_int_distributions_rec.interim_tax_segment3,
      p_int_distributions_rec.interim_tax_segment4,
      p_int_distributions_rec.interim_tax_segment5,
      p_int_distributions_rec.interim_tax_segment6,
      p_int_distributions_rec.interim_tax_segment7,
      p_int_distributions_rec.interim_tax_segment8,
      p_int_distributions_rec.interim_tax_segment9,
      p_int_distributions_rec.interim_tax_segment10,
      p_int_distributions_rec.interim_tax_segment11,
      p_int_distributions_rec.interim_tax_segment12,
      p_int_distributions_rec.interim_tax_segment13,
      p_int_distributions_rec.interim_tax_segment14,
      p_int_distributions_rec.interim_tax_segment15,
      p_int_distributions_rec.interim_tax_segment16,
      p_int_distributions_rec.interim_tax_segment17,
      p_int_distributions_rec.interim_tax_segment18,
      p_int_distributions_rec.interim_tax_segment19,
      p_int_distributions_rec.interim_tax_segment20,
      p_int_distributions_rec.interim_tax_segment21,
      p_int_distributions_rec.interim_tax_segment22,
      p_int_distributions_rec.interim_tax_segment23,
      p_int_distributions_rec.interim_tax_segment24,
      p_int_distributions_rec.interim_tax_segment25,
      p_int_distributions_rec.interim_tax_segment26,
      p_int_distributions_rec.interim_tax_segment27,
      p_int_distributions_rec.interim_tax_segment28,
      p_int_distributions_rec.interim_tax_segment29,
      p_int_distributions_rec.interim_tax_segment30
   );

   x_return_status := FND_API.g_ret_sts_success;

EXCEPTION
   WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_AR_DISTRIBUTE_ERROR');
         FND_MSG_PUB.add;
      END IF;
      IF OZF_DEBUG_LOW_ON THEN
         FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
         FND_MESSAGE.Set_Token('TEXT',sqlerrm);
         FND_MSG_PUB.Add;
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;
END Insert_Int_Distributions ;

PROCEDURE Insert_Interface_Line
(  p_interface_line_rec   IN  RA_Interface_Lines_Rec_Type
  ,x_return_status        OUT NOCOPY VARCHAR2
) IS
BEGIN

   INSERT INTO RA_INTERFACE_LINES_ALL
      ( CREATED_BY
      , CREATION_DATE
      , LAST_UPDATED_BY
      , LAST_UPDATE_DATE
      , INTERFACE_LINE_ATTRIBUTE1
      , INTERFACE_LINE_ATTRIBUTE2
      , INTERFACE_LINE_ATTRIBUTE3
      , INTERFACE_LINE_ATTRIBUTE4
      , INTERFACE_LINE_ATTRIBUTE5
      , INTERFACE_LINE_ATTRIBUTE6
      , INTERFACE_LINE_ATTRIBUTE7
      , INTERFACE_LINE_ATTRIBUTE8
      , INTERFACE_LINE_ATTRIBUTE9
      , INTERFACE_LINE_ATTRIBUTE10
      , INTERFACE_LINE_ATTRIBUTE11
      , INTERFACE_LINE_ATTRIBUTE12
      , INTERFACE_LINE_ATTRIBUTE13
      , INTERFACE_LINE_ATTRIBUTE14
      , INTERFACE_LINE_ATTRIBUTE15
      , INTERFACE_LINE_CONTEXT
      , BATCH_SOURCE_NAME
      , GL_DATE
      , SET_OF_BOOKS_ID
      , LINE_TYPE
      , DESCRIPTION
      , CURRENCY_CODE
      , AMOUNT
      , CONVERSION_TYPE
      , CONVERSION_DATE
      , CONVERSION_RATE
      , CUST_TRX_TYPE_ID
      , TERM_ID
      , ORIG_SYSTEM_BILL_CUSTOMER_ID
      , ORIG_SYSTEM_BILL_ADDRESS_ID
      , ORIG_SYSTEM_BILL_CONTACT_ID
      , ORIG_SYSTEM_SHIP_CUSTOMER_ID
      , ORIG_SYSTEM_SHIP_ADDRESS_ID
      , ORIG_SYSTEM_SHIP_CONTACT_ID
      , ORIG_SYSTEM_SOLD_CUSTOMER_ID
      , ORG_ID
      , AGREEMENT_ID
      , COMMENTS
      , CREDIT_METHOD_FOR_ACCT_RULE
      , CREDIT_METHOD_FOR_INSTALLMENTS
      , CUSTOMER_BANK_ACCOUNT_ID
      , DOCUMENT_NUMBER
      , DOCUMENT_NUMBER_SEQUENCE_ID
      , HEADER_ATTRIBUTE_CATEGORY
      , HEADER_ATTRIBUTE1
      , HEADER_ATTRIBUTE2
      , HEADER_ATTRIBUTE3
      , HEADER_ATTRIBUTE4
      , HEADER_ATTRIBUTE5
      , HEADER_ATTRIBUTE6
      , HEADER_ATTRIBUTE7
      , HEADER_ATTRIBUTE8
      , HEADER_ATTRIBUTE9
      , HEADER_ATTRIBUTE10
      , HEADER_ATTRIBUTE11
      , HEADER_ATTRIBUTE12
      , HEADER_ATTRIBUTE13
      , HEADER_ATTRIBUTE14
      , HEADER_ATTRIBUTE15
      , INITIAL_CUSTOMER_TRX_ID
      , INTERNAL_NOTES
      , INVOICING_RULE_ID
      , ORIG_SYSTEM_BATCH_NAME
      , PREVIOUS_CUSTOMER_TRX_ID
      , PRIMARY_SALESREP_ID
      , PRINTING_OPTION
      , PURCHASE_ORDER
      , PURCHASE_ORDER_REVISION
      , PURCHASE_ORDER_DATE
      , REASON_CODE
      , RECEIPT_METHOD_ID
      , RELATED_CUSTOMER_TRX_ID
      , TERRITORY_ID
      , TRX_DATE
      , TRX_NUMBER
      , MEMO_LINE_ID
      , TAX_CODE
      , INVENTORY_ITEM_ID
      , QUANTITY
      , UOM_CODE
      , UNIT_SELLING_PRICE
      , LEGAL_ENTITY_ID
      , SOURCE_APPLICATION_ID
      , SOURCE_ENTITY_CODE
       ,SOURCE_EVENT_CLASS_CODE
   )
   VALUES (
      p_interface_line_rec.created_by
      , p_interface_line_rec.creation_date
      , p_interface_line_rec.last_updated_by
      , p_interface_line_rec.last_update_date
      , p_interface_line_rec.interface_line_attribute1
      , p_interface_line_rec.interface_line_attribute2
      , p_interface_line_rec.interface_line_attribute3
      , p_interface_line_rec.interface_line_attribute4
      , p_interface_line_rec.interface_line_attribute5
      , p_interface_line_rec.interface_line_attribute6
      , p_interface_line_rec.interface_line_attribute7
      , p_interface_line_rec.interface_line_attribute8
      , p_interface_line_rec.interface_line_attribute9
      , p_interface_line_rec.interface_line_attribute10
      , p_interface_line_rec.interface_line_attribute11
      , p_interface_line_rec.interface_line_attribute12
      , p_interface_line_rec.interface_line_attribute13
      , p_interface_line_rec.interface_line_attribute14
      , p_interface_line_rec.interface_line_attribute15
      , p_interface_line_rec.interface_line_context
      , p_interface_line_rec.batch_source_name
      , p_interface_line_rec.gl_date
      , p_interface_line_rec.set_of_books_id
      , p_interface_line_rec.line_type
      , p_interface_line_rec.description
      , p_interface_line_rec.currency_code
      , p_interface_line_rec.amount
      , p_interface_line_rec.conversion_type
      , p_interface_line_rec.conversion_date
      , p_interface_line_rec.conversion_rate
      , p_interface_line_rec.cust_trx_type_id
      , p_interface_line_rec.term_id
      , p_interface_line_rec.orig_system_bill_customer_id
      , p_interface_line_rec.orig_system_bill_address_id
      , p_interface_line_rec.orig_system_bill_contact_id
      , p_interface_line_rec.orig_system_ship_customer_id
      , p_interface_line_rec.orig_system_ship_address_id
      , p_interface_line_rec.orig_system_ship_contact_id
      , p_interface_line_rec.orig_system_sold_customer_id
      , p_interface_line_rec.org_id
      , p_interface_line_rec.agreement_id
      , p_interface_line_rec.comments
      , p_interface_line_rec.credit_method_for_acct_rule
      , p_interface_line_rec.credit_method_for_installments
      , p_interface_line_rec.customer_bank_account_id
      , p_interface_line_rec.document_number
      , p_interface_line_rec.document_number_sequence_id
      , p_interface_line_rec.header_attribute_category
      , p_interface_line_rec.header_attribute1
      , p_interface_line_rec.header_attribute2
      , p_interface_line_rec.header_attribute3
      , p_interface_line_rec.header_attribute4
      , p_interface_line_rec.header_attribute5
      , p_interface_line_rec.header_attribute6
      , p_interface_line_rec.header_attribute7
      , p_interface_line_rec.header_attribute8
      , p_interface_line_rec.header_attribute9
      , p_interface_line_rec.header_attribute10
      , p_interface_line_rec.header_attribute11
      , p_interface_line_rec.header_attribute12
      , p_interface_line_rec.header_attribute13
      , p_interface_line_rec.header_attribute14
      , p_interface_line_rec.header_attribute15
      , p_interface_line_rec.initial_customer_trx_id
      , p_interface_line_rec.internal_notes
      , p_interface_line_rec.invoicing_rule_id
      , p_interface_line_rec.orig_system_batch_name
      , p_interface_line_rec.previous_customer_trx_id
      , p_interface_line_rec.primary_salesrep_id
      , p_interface_line_rec.printing_option
      , p_interface_line_rec.purchase_order
      , p_interface_line_rec.purchase_order_revision
      , p_interface_line_rec.purchase_order_date
      , p_interface_line_rec.reason_code
      , p_interface_line_rec.receipt_method_id
      , p_interface_line_rec.related_customer_trx_id
      , p_interface_line_rec.territory_id
      , p_interface_line_rec.trx_date
      , p_interface_line_rec.trx_number
      , p_interface_line_rec.memo_line_id
      , p_interface_line_rec.tax_code
      , p_interface_line_rec.inventory_item_id
      , p_interface_line_rec.quantity
      , p_interface_line_rec.uom_code
      , p_interface_line_rec.unit_selling_price
      , p_interface_line_rec.legal_entity_id
      , 682
      ,'OZF_CLAIMS'
      , 'TRADE_MGT_RECEIVABLES'
   );

   x_return_status := FND_API.g_ret_sts_success;
EXCEPTION
   WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_AR_INTERFACE_ERROR');
         FND_MSG_PUB.add;
      END IF;
      IF OZF_DEBUG_LOW_ON THEN
         FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
         FND_MESSAGE.Set_Token('TEXT',sqlerrm);
         FND_MSG_PUB.Add;
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;
END Insert_Interface_Line ;


PROCEDURE Insert_Interface_Tax
(  p_interface_tax_rec   IN  RA_Interface_Lines_Rec_Type
  ,x_return_status       OUT NOCOPY VARCHAR2
) IS
BEGIN

   INSERT INTO RA_INTERFACE_LINES_ALL
      ( CREATED_BY
      , CREATION_DATE
      , LAST_UPDATED_BY
      , LAST_UPDATE_DATE
      , INTERFACE_LINE_ATTRIBUTE1
      , INTERFACE_LINE_ATTRIBUTE2
      , INTERFACE_LINE_ATTRIBUTE3
      , INTERFACE_LINE_ATTRIBUTE4
      , INTERFACE_LINE_ATTRIBUTE5
      , INTERFACE_LINE_ATTRIBUTE6
      , INTERFACE_LINE_ATTRIBUTE7
      , INTERFACE_LINE_ATTRIBUTE8
      , INTERFACE_LINE_ATTRIBUTE9
      , INTERFACE_LINE_ATTRIBUTE10
      , INTERFACE_LINE_ATTRIBUTE11
      , INTERFACE_LINE_ATTRIBUTE12
      , INTERFACE_LINE_ATTRIBUTE13
      , INTERFACE_LINE_ATTRIBUTE14
      , INTERFACE_LINE_ATTRIBUTE15
      , INTERFACE_LINE_CONTEXT
      , LINK_TO_LINE_ATTRIBUTE1
      , LINK_TO_LINE_ATTRIBUTE2
      , LINK_TO_LINE_ATTRIBUTE3
      , LINK_TO_LINE_ATTRIBUTE4
      , LINK_TO_LINE_ATTRIBUTE5
      , LINK_TO_LINE_ATTRIBUTE6
      , LINK_TO_LINE_ATTRIBUTE7
      , LINK_TO_LINE_ATTRIBUTE8
      , LINK_TO_LINE_ATTRIBUTE9
      , LINK_TO_LINE_ATTRIBUTE10
      , LINK_TO_LINE_ATTRIBUTE11
      , LINK_TO_LINE_ATTRIBUTE12
      , LINK_TO_LINE_ATTRIBUTE13
      , LINK_TO_LINE_ATTRIBUTE14
      , LINK_TO_LINE_ATTRIBUTE15
      , LINK_TO_LINE_CONTEXT
      , LINE_TYPE
      , TAX_CODE
      , TAX_RATE
      , DESCRIPTION
      , BATCH_SOURCE_NAME
      , SET_OF_BOOKS_ID
      , CUST_TRX_TYPE_ID
      , GL_DATE
      , CURRENCY_CODE
      , CONVERSION_TYPE
      , CONVERSION_RATE
      , ORG_ID
      ,LEGAL_ENTITY_ID
   )
   VALUES (
        p_interface_tax_rec.created_by
      , p_interface_tax_rec.creation_date
      , p_interface_tax_rec.last_updated_by
      , p_interface_tax_rec.last_update_date
      , p_interface_tax_rec.interface_line_attribute1
      , p_interface_tax_rec.interface_line_attribute2
      , p_interface_tax_rec.interface_line_attribute3
      , p_interface_tax_rec.interface_line_attribute4
      , p_interface_tax_rec.interface_line_attribute5
      , p_interface_tax_rec.interface_line_attribute6
      , p_interface_tax_rec.interface_line_attribute7
      , p_interface_tax_rec.interface_line_attribute8
      , p_interface_tax_rec.interface_line_attribute9
      , p_interface_tax_rec.interface_line_attribute10
      , p_interface_tax_rec.interface_line_attribute11
      , p_interface_tax_rec.interface_line_attribute12
      , p_interface_tax_rec.interface_line_attribute13
      , p_interface_tax_rec.interface_line_attribute14
      , p_interface_tax_rec.interface_line_attribute15
      , p_interface_tax_rec.interface_line_context
      , p_interface_tax_rec.link_to_line_attribute1
      , p_interface_tax_rec.link_to_line_attribute2
      , p_interface_tax_rec.link_to_line_attribute3
      , p_interface_tax_rec.link_to_line_attribute4
      , p_interface_tax_rec.link_to_line_attribute5
      , p_interface_tax_rec.link_to_line_attribute6
      , p_interface_tax_rec.link_to_line_attribute7
      , p_interface_tax_rec.link_to_line_attribute8
      , p_interface_tax_rec.link_to_line_attribute9
      , p_interface_tax_rec.link_to_line_attribute10
      , p_interface_tax_rec.link_to_line_attribute11
      , p_interface_tax_rec.link_to_line_attribute12
      , p_interface_tax_rec.link_to_line_attribute13
      , p_interface_tax_rec.link_to_line_attribute14
      , p_interface_tax_rec.link_to_line_attribute15
      , p_interface_tax_rec.link_to_line_context
      , p_interface_tax_rec.line_type
      , p_interface_tax_rec.tax_code
      , p_interface_tax_rec.tax_rate
      , p_interface_tax_rec.description
      , p_interface_tax_rec.batch_source_name
      , p_interface_tax_rec.set_of_books_id
      , p_interface_tax_rec.cust_trx_type_id
      , p_interface_tax_rec.gl_date
      , p_interface_tax_rec.currency_code
      , p_interface_tax_rec.conversion_type
      , p_interface_tax_rec.conversion_rate
      , p_interface_tax_rec.org_id
      , p_interface_tax_rec.legal_entity_id
   );

   x_return_status := FND_API.g_ret_sts_success;
EXCEPTION
   WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_AR_INTERFACE_ERROR');
         FND_MSG_PUB.add;
      END IF;
      IF OZF_DEBUG_LOW_ON THEN
         FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
         FND_MESSAGE.Set_Token('TEXT',sqlerrm);
         FND_MSG_PUB.Add;
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;
END Insert_Interface_Tax;


PROCEDURE Insert_Interface_Sales_Credits(
   p_int_sales_credits_rec  IN  RA_Int_Sales_Credits_Rec_Type
  ,x_return_status          OUT NOCOPY VARCHAR2
)
IS
BEGIN
   INSERT INTO RA_INTERFACE_SALESCREDITS_ALL(
        CREATED_BY                      ,
        CREATION_DATE                   ,
        LAST_UPDATED_BY                 ,
        LAST_UPDATE_DATE                ,
        LAST_UPDATE_LOGIN               ,
        SALESREP_ID                     ,
        SALES_CREDIT_TYPE_ID            ,
        SALES_CREDIT_PERCENT_SPLIT      ,
        ATTRIBUTE_CATEGORY              ,
        ATTRIBUTE1                      ,
        ATTRIBUTE2                      ,
        ATTRIBUTE3                      ,
        ATTRIBUTE4                      ,
        ATTRIBUTE5                      ,
        ATTRIBUTE6                      ,
        ATTRIBUTE7                      ,
        ATTRIBUTE8                      ,
        ATTRIBUTE9                      ,
        ATTRIBUTE10                     ,
        ATTRIBUTE11                     ,
        ATTRIBUTE12                     ,
        ATTRIBUTE13                     ,
        ATTRIBUTE14                     ,
        ATTRIBUTE15                     ,
        INTERFACE_LINE_CONTEXT          ,
        INTERFACE_LINE_ATTRIBUTE1       ,
        INTERFACE_LINE_ATTRIBUTE2       ,
        INTERFACE_LINE_ATTRIBUTE3       ,
        INTERFACE_LINE_ATTRIBUTE4       ,
        INTERFACE_LINE_ATTRIBUTE5       ,
        INTERFACE_LINE_ATTRIBUTE6       ,
        INTERFACE_LINE_ATTRIBUTE7       ,
        INTERFACE_LINE_ATTRIBUTE8       ,
        INTERFACE_LINE_ATTRIBUTE9       ,
        INTERFACE_LINE_ATTRIBUTE10      ,
        INTERFACE_LINE_ATTRIBUTE11      ,
        INTERFACE_LINE_ATTRIBUTE12      ,
        INTERFACE_LINE_ATTRIBUTE13      ,
        INTERFACE_LINE_ATTRIBUTE14      ,
        INTERFACE_LINE_ATTRIBUTE15      ,
        ORG_ID
   )
   VALUES (
        p_int_sales_credits_rec.CREATED_BY                      ,
        p_int_sales_credits_rec.CREATION_DATE                   ,
        p_int_sales_credits_rec.LAST_UPDATED_BY                 ,
        p_int_sales_credits_rec.LAST_UPDATE_DATE                ,
        p_int_sales_credits_rec.LAST_UPDATE_LOGIN               ,
        p_int_sales_credits_rec.SALESREP_ID                     ,
        p_int_sales_credits_rec.SALES_CREDIT_TYPE_ID            ,
        p_int_sales_credits_rec.SALES_CREDIT_PERCENT_SPLIT      ,
        p_int_sales_credits_rec.ATTRIBUTE_CATEGORY              ,
        p_int_sales_credits_rec.ATTRIBUTE1                      ,
        p_int_sales_credits_rec.ATTRIBUTE2                      ,
        p_int_sales_credits_rec.ATTRIBUTE3                      ,
        p_int_sales_credits_rec.ATTRIBUTE4                      ,
        p_int_sales_credits_rec.ATTRIBUTE5                      ,
        p_int_sales_credits_rec.ATTRIBUTE6                      ,
        p_int_sales_credits_rec.ATTRIBUTE7                      ,
        p_int_sales_credits_rec.ATTRIBUTE8                      ,
        p_int_sales_credits_rec.ATTRIBUTE9                      ,
        p_int_sales_credits_rec.ATTRIBUTE10                     ,
        p_int_sales_credits_rec.ATTRIBUTE11                     ,
        p_int_sales_credits_rec.ATTRIBUTE12                     ,
        p_int_sales_credits_rec.ATTRIBUTE13                     ,
        p_int_sales_credits_rec.ATTRIBUTE14                     ,
        p_int_sales_credits_rec.ATTRIBUTE15                     ,
        p_int_sales_credits_rec.INTERFACE_LINE_CONTEXT          ,
        p_int_sales_credits_rec.INTERFACE_LINE_ATTRIBUTE1       ,
        p_int_sales_credits_rec.INTERFACE_LINE_ATTRIBUTE2       ,
        p_int_sales_credits_rec.INTERFACE_LINE_ATTRIBUTE3       ,
        p_int_sales_credits_rec.INTERFACE_LINE_ATTRIBUTE4       ,
        p_int_sales_credits_rec.INTERFACE_LINE_ATTRIBUTE5       ,
        p_int_sales_credits_rec.INTERFACE_LINE_ATTRIBUTE6       ,
        p_int_sales_credits_rec.INTERFACE_LINE_ATTRIBUTE7       ,
        p_int_sales_credits_rec.INTERFACE_LINE_ATTRIBUTE8       ,
        p_int_sales_credits_rec.INTERFACE_LINE_ATTRIBUTE9       ,
        p_int_sales_credits_rec.INTERFACE_LINE_ATTRIBUTE10      ,
        p_int_sales_credits_rec.INTERFACE_LINE_ATTRIBUTE11      ,
        p_int_sales_credits_rec.INTERFACE_LINE_ATTRIBUTE12      ,
        p_int_sales_credits_rec.INTERFACE_LINE_ATTRIBUTE13      ,
        p_int_sales_credits_rec.INTERFACE_LINE_ATTRIBUTE14      ,
        p_int_sales_credits_rec.INTERFACE_LINE_ATTRIBUTE15      ,
        p_int_sales_credits_rec.ORG_ID
   );

   x_return_status := FND_API.g_ret_sts_success;
EXCEPTION
   WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_AR_INTERFACE_ERROR');
         FND_MSG_PUB.add;
      END IF;
      IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
         FND_MESSAGE.Set_Token('TEXT',sqlerrm);
         FND_MSG_PUB.Add;
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;
END Insert_Interface_Sales_Credits;


/* ---------------------------------------------- *
 * Function that returns the memo_line_id
 * for a given claim_line_id.
 * ---------------------------------------------- */

FUNCTION Get_Memo_Line_Id(p_claim_line_id  IN NUMBER)
RETURN NUMBER IS

CURSOR csr_memo_line(cv_claim_line_id IN NUMBER) IS
  SELECT item_id
  FROM ozf_claim_lines
  WHERE claim_line_id = cv_claim_line_id
  AND item_type = 'MEMO_LINE';--11.5.10 Enhancements.
l_memo_line_id NUMBER;

BEGIN
   OPEN csr_memo_line (p_claim_line_id);
   FETCH csr_memo_line INTO l_memo_line_id;
   CLOSE csr_memo_line;

   IF (l_memo_line_id IS NULL) THEN
       -- Make sure that if no memo line is found, then
       -- always return 0..
       --l_memo_line_id := p_claim_id;
       l_memo_line_id := 0;
   END IF;

     RETURN l_memo_line_id;

END Get_Memo_Line_Id;

/* ---------------------------------------------- *
 * Populate the Interface Line Record
 * ---------------------------------------------- */
PROCEDURE Populate_Interface_Line_Rec
(   p_claim_rec            IN Claim_Rec_Type
   ,p_memo_line_id         IN NUMBER
   ,p_claim_line_id        IN NUMBER
   ,p_line_claim_curr_amt  IN NUMBER
   ,p_line_tax_code        IN VARCHAR2
   ,p_line_cc_id_flag      IN VARCHAR2
   ,p_x_interface_line_rec IN OUT NOCOPY RA_Interface_Lines_Rec_Type
   ,x_return_status        OUT NOCOPY VARCHAR2
) IS

CURSOR sys_param_csr IS
  SELECT sp.batch_source_id,
         sp.billback_trx_type_id,
         sp.cm_trx_type_id
  FROM   ozf_sys_parameters sp ;

CURSOR batch_source_csr (p_id IN NUMBER) IS
  SELECT name
  FROM   ra_batch_sources
  WHERE  batch_source_id = p_id ;
/*
CURSOR claim_type_csr(p_id IN NUMBER) IS
  SELECT NVL(transaction_type,0)
  FROM   ozf_claim_types
  WHERE  claim_type_id = p_id ;
*/
CURSOR claim_type_csr(cv_claim_type_id IN NUMBER) IS
   SELECT cm_trx_type_id
   ,      dm_trx_type_id
   ,      cb_trx_type_id
   FROM ozf_claim_types_all_b
   WHERE claim_type_id = cv_claim_type_id;

CURSOR memo_line_csr(p_id IN NUMBER) IS
  SELECT description
  FROM   ar_memo_lines
  WHERE  memo_line_id = p_id;

CURSOR party_site_csr(p_id IN NUMBER) IS
  SELECT cust_acct_site_id
  FROM   hz_cust_site_uses
  WHERE  site_use_id = p_id ;

CURSOR csr_shipto_site(p_shipto_site_id IN NUMBER) IS
  SELECT cas.cust_account_id
  ,      cas.cust_acct_site_id
  FROM hz_cust_acct_sites cas
  ,    hz_cust_site_uses csu
  WHERE cas.cust_acct_site_id = csu.cust_acct_site_id
  AND csu.site_use_id = p_shipto_site_id;


CURSOR reason_code_csr(p_id IN NUMBER) IS
  SELECT reason_code
  FROM   ozf_reason_codes_all_b
  WHERE  reason_code_id = p_id;

CURSOR invoice_reason_code_csr(p_id IN NUMBER) IS
  SELECT invoicing_reason_code
  FROM   ozf_reason_codes_all_b
  WHERE  reason_code_id = p_id;

CURSOR trx_type_gl_flag_csr(p_trx_type_id IN NUMBER) IS
  SELECT post_to_gl
  FROM   ra_cust_trx_types
  WHERE  cust_trx_type_id = p_trx_type_id;

CURSOR csr_trx_type_payment_term(cv_claim_type_id IN NUMBER) IS
  SELECT default_term
  FROM ra_cust_trx_types trx
  ,    ozf_claim_types_all_b ct
  WHERE trx.cust_trx_type_id = ct.dm_trx_type_id
  AND ct.claim_type_id = cv_claim_type_id;

CURSOR csr_cust_payment_term(cv_cust_account_id IN NUMBER) IS
  SELECT standard_terms
  FROM hz_customer_profiles
  WHERE cust_account_id  = cv_cust_account_id
  AND site_use_id IS NULL;
/*
  SELECT payment_term_id
  FROM hz_cust_accounts
  WHERE cust_account_id = cv_cust_account_id;
*/

CURSOR csr_cust_address_pay_term(cv_cust_account_id IN NUMBER, cv_site_use_id IN NUMBER) IS
  SELECT standard_terms
  FROM hz_customer_profiles
  WHERE cust_account_id  = cv_cust_account_id
  AND site_use_id = cv_site_use_id;

CURSOR csr_cust_site_pay_term(cv_cust_account_id IN NUMBER, cv_site_use_id IN NUMBER) IS
  SELECT use.payment_term_id
  FROM hz_cust_site_uses use
  , hz_cust_acct_sites site
  WHERE site.cust_acct_site_id = use.cust_acct_site_id
  AND site.cust_account_id = cv_cust_account_id
  AND use.site_use_id = cv_site_use_id;

CURSOR csr_claim_line_product(cv_claim_line_id IN NUMBER) IS
  SELECT item_id
  ,      quantity
  ,      quantity_uom
  ,      rate
  ,      item_type
  ,      item_description
  ,      source_object_class -- added for bug 4716020
  FROM ozf_claim_lines
  WHERE claim_line_id = cv_claim_line_id;

l_batch_source_id      NUMBER;
l_billback_trx_type_id NUMBER;
l_cm_trx_type_id       NUMBER;
l_post_gl_flag         VARCHAR2(1);
l_claim_cm_trx_type_id NUMBER;
l_claim_dm_trx_type_id NUMBER;
l_claim_cb_trx_type_id NUMBER;
l_reason_code          VARCHAR2(30);
l_invoicing_reason_code VARCHAR2(30);
l_inventory_item_id    NUMBER; --11.5.10 Enhancements.
l_item_type            VARCHAR2(30); --11.5.10 Enhancements.
l_claim_line_item_desc VARCHAR2(240);
l_source_object_class  VARCHAR2(30); -- added for bug 4716020

-- Cursor to get claim reason name -- 11.5.10 Enhancements.
CURSOR csr_get_reason_name (cv_reason_code_id IN NUMBER) IS
     SELECT SUBSTRB(name,1,30) name
     FROM   ozf_reason_codes_vl
     WHERE  reason_code_id = cv_reason_code_id;

CURSOR csr_product_desc(cv_inventory_item_id IN NUMBER) IS
  SELECT SUBSTRB(description, 1, 240)
  FROM mtl_system_items_vl
  WHERE inventory_item_id = cv_inventory_item_id
  AND organization_id = FND_PROFILE.VALUE('AMS_ITEM_ORGANIZATION_ID');

CURSOR csr_offer_name(cv_claim_line_id IN NUMBER)IS
  SELECT SUBSTR(offer_code,1,50)
  FROM   ozf_offers offer, ozf_claim_lines_all line
  WHERE  qp_list_header_id = line.offer_id
  AND    claim_line_id     = cv_claim_line_id;

-- Introduced for Bug4348163
CURSOR csr_category_desc(cv_category_id IN NUMBER) IS
   SELECT SUBSTRB(category_desc,1,240)
    FROM  eni_prod_den_hrchy_parents_v
    WHERE category_id = cv_category_id;
l_line_description VARCHAR2(240);

CURSOR csr_media_desc(cv_media_channel_id IN NUMBER) IS
   SELECT  channel_name
     FROM  ams_media_channels_vl
    WHERE  channel_id = cv_media_channel_id;

BEGIN
   -- Start populating the interface record values
   x_return_status := FND_API.g_ret_sts_success;

   /* -- Standard Who Columns ------------------------- */
   p_x_interface_line_rec.CREATED_BY    := FND_GLOBAL.USER_ID;
   p_x_interface_line_rec.CREATION_DATE := SYSDATE ;
   p_x_interface_line_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
   p_x_interface_line_rec.LAST_UPDATE_DATE := SYSDATE;

   /* -- Fixed Values from unchangeble profiles ------- */
   p_x_interface_line_rec.INTERFACE_LINE_CONTEXT := 'CLAIM';

   /* -- Batch Source --------------------------------- */
   -- This is set at the system parameter level
   -- System parameter will have only one record for an org
   -- No need to handle when no data found.
   OPEN sys_param_csr;
      FETCH sys_param_csr INTO l_batch_source_id,
                               l_billback_trx_type_id,
                               l_cm_trx_type_id ;
   CLOSE sys_param_csr;

   IF (l_batch_source_id IS NULL) THEN
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('OZF','OZF_BATCH_SRC_REQ_FOR_INTF');
      FND_MSG_PUB.add;
     END IF;
     x_return_status := FND_API.g_ret_sts_error;
   ELSE
     OPEN batch_source_csr(l_batch_source_id) ;
        FETCH batch_source_csr INTO p_x_interface_line_rec.batch_source_name;
     CLOSE batch_source_csr;
   END IF;

   /* -- All Interface line attributes enabled for the context CLAIM --- */
   p_x_interface_line_rec.INTERFACE_LINE_ATTRIBUTE1 := p_claim_rec.claim_number ;
   p_x_interface_line_rec.INTERFACE_LINE_ATTRIBUTE2 := TO_CHAR(p_claim_rec.claim_id) ;
   p_x_interface_line_rec.INTERFACE_LINE_ATTRIBUTE3 := TO_CHAR(p_claim_line_id);
   p_x_interface_line_rec.INTERFACE_LINE_ATTRIBUTE4 := p_line_cc_id_flag;

   /* -- 11.5.10 Enhancements. TM should pass claim comments. */
   p_x_interface_line_rec.comments := SUBSTRB(p_claim_rec.comments, 1, 240);

   /* -- 11.5.10 Enhancements. TM should pass. */
   OPEN  csr_get_reason_name(p_claim_rec.reason_code_id);
   FETCH csr_get_reason_name INTO p_x_interface_line_rec.INTERFACE_LINE_ATTRIBUTE7;   --reason name
   CLOSE csr_get_reason_name;
   p_x_interface_line_rec.INTERFACE_LINE_ATTRIBUTE5 := NVL(p_claim_rec.customer_ref_number, '-');
   p_x_interface_line_rec.INTERFACE_LINE_ATTRIBUTE6 := NVL(p_claim_rec.customer_reason, '-') ;

  /* -- Only four attributes used for now
   p_x_interface_line_rec.INTERFACE_LINE_ATTRIBUTE5 := '0';
   p_x_interface_line_rec.INTERFACE_LINE_ATTRIBUTE6 := '0';
   p_x_interface_line_rec.INTERFACE_LINE_ATTRIBUTE7 := '0';
   p_x_interface_line_rec.INTERFACE_LINE_ATTRIBUTE8 := '0';
   p_x_interface_line_rec.INTERFACE_LINE_ATTRIBUTE9 := '0';
   p_x_interface_line_rec.INTERFACE_LINE_ATTRIBUTE10 := '0';
   p_x_interface_line_rec.INTERFACE_LINE_ATTRIBUTE11 := '0';
   p_x_interface_line_rec.INTERFACE_LINE_ATTRIBUTE12 := '0';
   p_x_interface_line_rec.INTERFACE_LINE_ATTRIBUTE13 := '0';
   p_x_interface_line_rec.INTERFACE_LINE_ATTRIBUTE14 := '0';
   p_x_interface_line_rec.INTERFACE_LINE_ATTRIBUTE15 := '0';
   */

   --  Bugfix 6115698: FP:11510-R12 5663890
   /* ------------------------------------------------- */
   -- Populate this mandatory attribute with the unique claim_id to group all
   -- lines from the claim into one Transaction in AR
   -- p_x_interface_line_rec.HEADER_ATTRIBUTE1 := TO_CHAR(p_claim_rec.claim_id);


   /* -- Claim Header Record Values ------------------- */
   p_x_interface_line_rec.SET_OF_BOOKS_ID := p_claim_rec.set_of_books_id;
   p_x_interface_line_rec.LINE_TYPE       := 'LINE';
   p_x_interface_line_rec.CURRENCY_CODE   := p_claim_rec.currency_code;
   IF p_claim_rec.exchange_rate_type IS NULL THEN
     p_x_interface_line_rec.CONVERSION_TYPE := 'User';
     p_x_interface_line_rec.CONVERSION_RATE := 1;
   ELSE
     p_x_interface_line_rec.CONVERSION_TYPE := p_claim_rec.exchange_rate_type;
     IF p_claim_rec.exchange_rate_type = 'User' THEN
       p_x_interface_line_rec.CONVERSION_RATE := p_claim_rec.exchange_rate;
     ELSE
       p_x_interface_line_rec.CONVERSION_RATE := NULL;
     END IF;
   END IF;
   p_x_interface_line_rec.CONVERSION_DATE := p_claim_rec.exchange_rate_date;
   -- 13-MAR-2002 mchang updated: assing value of conversion_rate is depending on conversion_rate
   --p_x_interface_line_rec.CONVERSION_RATE := p_claim_rec.exchange_rate;
   p_x_interface_line_rec.PRIMARY_SALESREP_ID := p_claim_rec.sales_rep_id;

   p_x_interface_line_rec.ORG_ID          :=  p_claim_rec.org_id;
   p_x_interface_line_rec.legal_entity_id        :=  p_claim_rec.legal_entity_id;


   /* -- Populate Customer and Bill To site ------------------ */
   -- Figure out which customer/site to bill
   -- If pay_related_account_flag is T
   -- then
   --    customer_id will be related_cust_account_id and
   --    bill_to should be derived from related_site_use_id
   -- else
   --    customer_id will be cust_account_id and
   --    bill_to should be derived from cust_billto_acct_site_id
   --    ship_to should be derived from cust_shipto_acct_site_id
   --
   IF (p_claim_rec.pay_related_account_flag = 'T' ) THEN
      p_x_interface_line_rec.ORIG_SYSTEM_BILL_CUSTOMER_ID :=
                          p_claim_rec.related_cust_account_id;

      -- Get the bill_address_id
      OPEN party_site_csr(p_claim_rec.related_site_use_id);
         FETCH party_site_csr INTO
                 p_x_interface_line_rec.ORIG_SYSTEM_BILL_ADDRESS_ID ;
      CLOSE party_site_csr;


      -- Get the ship_to_address_id and ship to customer
      OPEN csr_shipto_site(p_claim_rec.cust_shipto_acct_site_id);
      FETCH csr_shipto_site into p_x_interface_line_rec.orig_system_ship_customer_id
                               , p_x_interface_line_rec.orig_system_ship_address_id;
      CLOSE csr_shipto_site;
      p_x_interface_line_rec.orig_system_ship_customer_id := p_claim_rec.ship_to_cust_account_id;
   ELSE
      p_x_interface_line_rec.ORIG_SYSTEM_BILL_CUSTOMER_ID :=
                          p_claim_rec.cust_account_id;

      -- Get the bill_address_id
      OPEN party_site_csr(p_claim_rec.cust_billto_acct_site_id);
         FETCH party_site_csr INTO
                 p_x_interface_line_rec.ORIG_SYSTEM_BILL_ADDRESS_ID ;
      CLOSE party_site_csr;

      -- Get the ship_to_address_id and ship to customer
      OPEN csr_shipto_site(p_claim_rec.cust_shipto_acct_site_id);
      FETCH csr_shipto_site into p_x_interface_line_rec.orig_system_ship_customer_id
                               , p_x_interface_line_rec.orig_system_ship_address_id;
      CLOSE csr_shipto_site;
   END IF;



   /* -- Get Reason Code ----------------------------------- */
   -- This is optional
   -- Derive it from ozf_reason_codes_all_b
   -- reason_code should be passed only for credit memos.
   -- It should not be passed for debit memos.
   IF p_claim_rec.payment_method = 'CREDIT_MEMO' AND
      p_claim_rec.reason_code_id IS NOT NULL THEN
     OPEN reason_code_csr(p_claim_rec.reason_code_id);
     FETCH reason_code_csr INTO l_reason_code;
     CLOSE reason_code_csr;

     IF l_reason_code IS NOT NULL THEN
	    p_x_interface_line_rec.REASON_CODE := l_reason_code;
	   END IF;
   END IF;

  /* -- Get Invoicing Reason Code ----------------------------------- */
   -- R12 Enhancements
   -- Invoicing Reason code should be passed only for debit memos.

   IF p_claim_rec.payment_method = 'DEBIT_MEMO' AND
     p_claim_rec.reason_code_id IS NOT NULL THEN
     OPEN invoice_reason_code_csr(p_claim_rec.reason_code_id);
     FETCH invoice_reason_code_csr INTO l_invoicing_reason_code;
     CLOSE invoice_reason_code_csr;

     IF l_invoicing_reason_code IS NOT NULL THEN
	    p_x_interface_line_rec.REASON_CODE := l_invoicing_reason_code;
	   END IF;
    END IF;


   /* -- Derive and Validate the transaction type ---------- */
   -- Check for Payment Method First
   IF ( p_claim_rec.payment_method IS NULL  OR
        p_claim_rec.payment_method = FND_API.G_MISS_CHAR )
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_MISSING_PAYMENT_METHOD');
         FND_MSG_PUB.add;
      END IF;
   ELSIF  p_claim_rec.payment_method IS NOT NULL THEN
      -- Now get Trx_type from the claim type
      OPEN claim_type_csr(p_claim_rec.claim_type_id) ;
         --FETCH claim_type_csr INTO p_x_interface_line_rec.cust_trx_type_id ;
      FETCH claim_type_csr INTO l_claim_cm_trx_type_id
                           ,    l_claim_dm_trx_type_id
                           ,    l_claim_cb_trx_type_id;
      CLOSE claim_type_csr;

      --Bug4249629: Effective date should be used as trx_date
      p_x_interface_line_rec.trx_date := p_claim_rec.effective_date;
      IF p_claim_rec.payment_method = 'CREDIT_MEMO' THEN
         p_x_interface_line_rec.cust_trx_type_id := l_claim_cm_trx_type_id;

         -- amount sign is changed for on account credit memos
         p_x_interface_line_rec.AMOUNT          := p_line_claim_curr_amt  * -1;

      ELSIF p_claim_rec.payment_method = 'DEBIT_MEMO' THEN
         p_x_interface_line_rec.cust_trx_type_id := l_claim_dm_trx_type_id;

         -- For Regular and on-acc CM .. do not enter
         -- Others, its optional. ( In our case it is a DM )
         -- Receivable uses the following hierarchy to determine the default payment term,
         -- stopping when one is found
         -- 1. customer bill-to site level
         -- 2. customer address level
         -- 3. customer level
         -- 4. transaction type

         OPEN  csr_cust_site_pay_term(p_claim_rec.cust_account_id, p_claim_rec.cust_billto_acct_site_id);
         FETCH csr_cust_site_pay_term INTO p_x_interface_line_rec.TERM_ID;
         CLOSE csr_cust_site_pay_term;

         IF p_x_interface_line_rec.TERM_ID IS NULL THEN
            OPEN  csr_cust_address_pay_term(p_claim_rec.cust_account_id, p_claim_rec.cust_billto_acct_site_id);
            FETCH csr_cust_address_pay_term INTO p_x_interface_line_rec.TERM_ID;
            CLOSE csr_cust_address_pay_term;
         END IF;

         IF p_x_interface_line_rec.TERM_ID IS NULL THEN
            OPEN csr_cust_payment_term(p_claim_rec.cust_account_id);
            FETCH csr_cust_payment_term INTO p_x_interface_line_rec.TERM_ID;
            CLOSE csr_cust_payment_term;
         END IF;

         IF p_x_interface_line_rec.TERM_ID IS NULL THEN
            OPEN csr_trx_type_payment_term(p_claim_rec.claim_type_id);
            FETCH csr_trx_type_payment_term INTO p_x_interface_line_rec.TERM_ID;
            CLOSE csr_trx_type_payment_term;
         END IF;

         IF p_x_interface_line_rec.TERM_ID IS NULL THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('OZF', 'OZF_MISSING_PAYMENT_TERM');
               FND_MSG_PUB.add;
            END IF;
            x_return_status := FND_API.g_ret_sts_error;
         END IF;

         -- Overpayment amount is negative; Creation sign for debit memo should be positive.
         p_x_interface_line_rec.AMOUNT          := p_line_claim_curr_amt * -1;

      ELSIF p_claim_rec.payment_method = 'CHARGEBACK' THEN
         p_x_interface_line_rec.cust_trx_type_id := l_claim_cb_trx_type_id;

         p_x_interface_line_rec.AMOUNT          := p_line_claim_curr_amt;

      ELSE
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_SETL_INT_ERR_PAYMETHOD');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      -- If trx_type is not defined at claim type level, get it from
      -- system parameters
      IF p_x_interface_line_rec.cust_trx_type_id IS NULL THEN
         -- Verify the payment_method against the trx_type
         -- l_billback_trx_type_id and l_cm_trx_type_id are fetched
         -- from the sys_param_csr above
         IF ( p_claim_rec.payment_method IN ('CHARGEBACK','DEBIT_MEMO') )
         THEN
            IF l_billback_trx_type_id IS NULL THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                  FND_MESSAGE.set_name('OZF', 'OZF_MISSING_BILLBACK_TRX_TYPE');
                  FND_MSG_PUB.add;
                END IF;
                x_return_status := FND_API.g_ret_sts_error;
            ELSE
               p_x_interface_line_rec.cust_trx_type_id :=l_billback_trx_type_id;
            END IF;
         ELSIF  p_claim_rec.payment_method = 'CREDIT_MEMO' THEN
            IF l_cm_trx_type_id IS NULL THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                  FND_MESSAGE.set_name('OZF', 'OZF_MISSING_CM_TRX_TYPE');
                  FND_MSG_PUB.add;
               END IF;
               x_return_status := FND_API.g_ret_sts_error;
            ELSE
               p_x_interface_line_rec.cust_trx_type_id :=  l_cm_trx_type_id;
            END IF;
         END IF;
      END IF; -- End getting trx_type from system parameters
   END IF; -- End Trx_Type validation



   /* ------------ Populate GL_DATE ------------------------------ */
   -- If the Post To Gl option on the transaction type is set to NO,
   -- the GL_DATE column should be NULL.
   OPEN trx_type_gl_flag_csr(p_x_interface_line_rec.cust_trx_type_id);
   FETCH trx_type_gl_flag_csr INTO l_post_gl_flag;
   CLOSE trx_type_gl_flag_csr;

   IF l_post_gl_flag = 'Y' THEN
     IF OZF_CLAIM_SETTLEMENT_VAL_PVT.gl_date_in_open(222, p_claim_rec.claim_id) THEN
         p_x_interface_line_rec.GL_DATE         := p_claim_rec.gl_date;
     END IF;
   END IF;

   -- 11.5.10 Enhancements. AR should default
   IF p_claim_rec.payment_method IS NOT NULL
      AND p_claim_rec.payment_method = 'DEBIT_MEMO' THEN
       p_x_interface_line_rec.GL_DATE         := NULL;
   END IF;


   /* ------ Tax Code ----------------------------*/
   p_x_interface_line_rec.tax_code := p_line_tax_code;



   /* ------ Bug4348163: Populate Product  Information ----------------------------*/
   OPEN csr_claim_line_product(p_claim_line_id);
   FETCH csr_claim_line_product INTO l_inventory_item_id
                                   , p_x_interface_line_rec.quantity
                                   , p_x_interface_line_rec.uom_code
                                   , p_x_interface_line_rec.unit_selling_price
                                   , l_item_type
                                   , l_claim_line_item_desc
                                   , l_source_object_class; -- added for bug 4716020
   CLOSE csr_claim_line_product;
   IF l_inventory_item_id IS NOT NULL THEN
      -- fix for bug 4716020
      IF l_source_object_class in ('INVOICE', 'CM', 'DM', 'CB', 'ORDER') THEN
         OPEN  csr_product_desc(l_inventory_item_id);
         FETCH csr_product_desc INTO l_line_description;
         CLOSE csr_product_desc;
         p_x_interface_line_rec.inventory_item_id := l_inventory_item_id;
      END IF;
      -- end of fix for bug 4716020

      IF  l_item_type = 'PRODUCT' THEN
         OPEN  csr_product_desc(l_inventory_item_id);
         FETCH csr_product_desc INTO l_line_description;
         CLOSE csr_product_desc;
         p_x_interface_line_rec.inventory_item_id := l_inventory_item_id;

      ELSIF l_item_type  = 'FAMILY' THEN
         OPEN  csr_category_desc(l_inventory_item_id);
         FETCH csr_category_desc INTO l_line_description;
         CLOSE csr_category_desc;

      ELSIF l_item_type = 'MEMO_LINE' THEN
          OPEN memo_line_csr(l_inventory_item_id);
          FETCH memo_line_csr INTO l_line_description;
          CLOSE memo_line_csr;
          p_x_interface_line_rec.memo_line_id := l_inventory_item_id;
	  -- Fix for bug#8866818 - Start
	  p_x_interface_line_rec.inventory_item_id := null;
	  -- Fix for bug#8866818 - End

      ELSIF l_item_type = 'MEDIA' THEN
         OPEN  csr_media_desc(l_inventory_item_id);
         FETCH csr_media_desc INTO l_line_description;
         CLOSE csr_media_desc;

      END IF;

   END IF;
   IF l_line_description IS NULL THEN
         l_line_description := NVL(l_claim_line_item_desc, p_claim_rec.claim_number) ;
   END IF;
   p_x_interface_line_rec.description := SUBSTRB(l_line_description,1,240) ;
   p_x_interface_line_rec.quantity := p_x_interface_line_rec.quantity * -1;



   /* ------ Bug4348163: Populate Offer Information -------------------------------*/
   /*OPEN  csr_offer_name(p_claim_line_id);
   FETCH csr_offer_name INTO  p_x_interface_line_rec.purchase_order;
   CLOSE csr_offer_name;*/


   -- bug4436227: The below statement is the culprit, as it causes datatype mismatch
   --p_x_interface_line_rec.comments := p_claim_rec.comments;

EXCEPTION
   WHEN OTHERS THEN
      IF sys_param_csr%ISOPEN THEN
         CLOSE sys_param_csr ;
      END IF;
      IF batch_source_csr%ISOPEN THEN
         CLOSE batch_source_csr ;
      END IF;
      IF claim_type_csr%ISOPEN THEN
         CLOSE claim_type_csr ;
      END IF;
      IF memo_line_csr%ISOPEN THEN
         CLOSE memo_line_csr ;
      END IF;
      IF party_site_csr%ISOPEN THEN
         CLOSE party_site_csr ;
      END IF;
      IF reason_code_csr%ISOPEN THEN
         CLOSE reason_code_csr ;
      END IF;
      IF trx_type_gl_flag_csr%ISOPEN THEN
         CLOSE trx_type_gl_flag_csr ;
      END IF;
      IF csr_trx_type_payment_term%ISOPEN THEN
         CLOSE csr_trx_type_payment_term ;
      END IF;
      IF csr_cust_payment_term%ISOPEN THEN
         CLOSE csr_cust_payment_term ;
      END IF;
      IF csr_cust_address_pay_term%ISOPEN THEN
         CLOSE csr_cust_address_pay_term ;
      END IF;
      IF csr_cust_site_pay_term%ISOPEN THEN
         CLOSE csr_cust_site_pay_term ;
      END IF;
      IF csr_claim_line_product%ISOPEN THEN
         CLOSE csr_claim_line_product ;
      END IF;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_POPULATE_INTF_ERROR');
         FND_MSG_PUB.add;
      END IF;
      IF OZF_DEBUG_LOW_ON THEN
         FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
         FND_MESSAGE.Set_Token('TEXT',sqlerrm);
         FND_MSG_PUB.Add;
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;
END Populate_Interface_Line_Rec;


/* ---------------------------------------------- *
 * Populate the Interface Tax Record
 * ---------------------------------------------- */
PROCEDURE Populate_Interface_Tax_Rec
(   p_line_tax_code        IN  VARCHAR2
   ,p_interface_line_rec   IN  RA_Interface_Lines_Rec_Type
   ,x_interface_tax_rec    OUT NOCOPY RA_Interface_Lines_Rec_Type
   ,x_return_status        OUT NOCOPY VARCHAR2
) IS

l_tax_rate   NUMBER;
l_tax_name   VARCHAR2(60);

BEGIN
  -- Start populating the interface record values
  x_return_status := FND_API.g_ret_sts_success;

  /* -- Standard Who Columns ------------------------- */
  x_interface_tax_rec.CREATED_BY    := FND_GLOBAL.USER_ID;
  x_interface_tax_rec.CREATION_DATE := SYSDATE ;
  x_interface_tax_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
  x_interface_tax_rec.LAST_UPDATE_DATE := SYSDATE;
  /* ------------------------------------------------- */

  /* -- required fields for tax lines -- */

  x_interface_tax_rec.LINE_TYPE := 'TAX';
  x_interface_tax_rec.TAX_CODE := p_line_tax_code;
  x_interface_tax_rec.TAX_RATE := l_tax_rate;

  /* -- use "claim_number || printed_tax_name" as a description for tax line. -- */
  x_interface_tax_rec.DESCRIPTION := p_interface_line_rec.INTERFACE_LINE_ATTRIBUTE1 || l_tax_name;

  /* -- some other required fields -- */
  x_interface_tax_rec.BATCH_SOURCE_NAME := p_interface_line_rec.BATCH_SOURCE_NAME;
  x_interface_tax_rec.SET_OF_BOOKS_ID := p_interface_line_rec.SET_OF_BOOKS_ID;
  x_interface_tax_rec.CUST_TRX_TYPE_ID := p_interface_line_rec.CUST_TRX_TYPE_ID;
  x_interface_tax_rec.GL_DATE := p_interface_line_rec.GL_DATE;
  x_interface_tax_rec.CURRENCY_CODE := p_interface_line_rec.CURRENCY_CODE;
  x_interface_tax_rec.CONVERSION_TYPE := p_interface_line_rec.CONVERSION_TYPE;
  x_interface_tax_rec.CONVERSION_RATE := p_interface_line_rec.CONVERSION_RATE;
  x_interface_tax_rec.ORG_ID := p_interface_line_rec.ORG_ID;
  x_interface_tax_rec.LEGAL_ENTITY_ID := p_interface_line_rec.LEGAL_ENTITY_ID;

  /* -- Fixed Values from unchangeble profiles ------- */
  x_interface_tax_rec.INTERFACE_LINE_CONTEXT := 'CLAIM';

  /* -- All Interface line attributes enabled for the context CLAIM --- */
  x_interface_tax_rec.INTERFACE_LINE_ATTRIBUTE1 := p_interface_line_rec.INTERFACE_LINE_ATTRIBUTE1;
  x_interface_tax_rec.INTERFACE_LINE_ATTRIBUTE2 := p_interface_line_rec.INTERFACE_LINE_ATTRIBUTE2;
  x_interface_tax_rec.INTERFACE_LINE_ATTRIBUTE3 := p_interface_line_rec.INTERFACE_LINE_ATTRIBUTE3 || 'TAX';
  x_interface_tax_rec.INTERFACE_LINE_ATTRIBUTE4 := p_interface_line_rec.INTERFACE_LINE_ATTRIBUTE4;
  /* -- Only four attributes used for now
  x_interface_tax_rec.INTERFACE_LINE_ATTRIBUTE5 := '0';
  x_interface_tax_rec.INTERFACE_LINE_ATTRIBUTE6 := '0';
  x_interface_tax_rec.INTERFACE_LINE_ATTRIBUTE7 := '0';
  x_interface_tax_rec.INTERFACE_LINE_ATTRIBUTE8 := '0';
  x_interface_tax_rec.INTERFACE_LINE_ATTRIBUTE9 := '0';
  x_interface_tax_rec.INTERFACE_LINE_ATTRIBUTE10 := '0';
  x_interface_tax_rec.INTERFACE_LINE_ATTRIBUTE11 := '0';
  x_interface_tax_rec.INTERFACE_LINE_ATTRIBUTE12 := '0';
  x_interface_tax_rec.INTERFACE_LINE_ATTRIBUTE13 := '0';
  x_interface_tax_rec.INTERFACE_LINE_ATTRIBUTE14 := '0';
  x_interface_tax_rec.INTERFACE_LINE_ATTRIBUTE15 := '0';
  */

  /* -- Use Link_To Transaction flexfields to link transaction lines together -- */
  x_interface_tax_rec.LINK_TO_LINE_CONTEXT := p_interface_line_rec.INTERFACE_LINE_CONTEXT;
  x_interface_tax_rec.LINK_TO_LINE_ATTRIBUTE1 := p_interface_line_rec.INTERFACE_LINE_ATTRIBUTE1;
  x_interface_tax_rec.LINK_TO_LINE_ATTRIBUTE2 := p_interface_line_rec.INTERFACE_LINE_ATTRIBUTE2;
  x_interface_tax_rec.LINK_TO_LINE_ATTRIBUTE3 := p_interface_line_rec.INTERFACE_LINE_ATTRIBUTE3;
  x_interface_tax_rec.LINK_TO_LINE_ATTRIBUTE4 := p_interface_line_rec.INTERFACE_LINE_ATTRIBUTE4;
  /* -- Only four attributes used for now
  x_interface_tax_rec.LINK_TO_LINE_ATTRIBUTE5 := p_interface_line_rec.INTERFACE_LINE_ATTRIBUTE5;
  x_interface_tax_rec.LINK_TO_LINE_ATTRIBUTE6 := p_interface_line_rec.INTERFACE_LINE_ATTRIBUTE6;
  x_interface_tax_rec.LINK_TO_LINE_ATTRIBUTE7 := p_interface_line_rec.INTERFACE_LINE_ATTRIBUTE7;
  x_interface_tax_rec.LINK_TO_LINE_ATTRIBUTE8 := p_interface_line_rec.INTERFACE_LINE_ATTRIBUTE8;
  x_interface_tax_rec.LINK_TO_LINE_ATTRIBUTE9 := p_interface_line_rec.INTERFACE_LINE_ATTRIBUTE9;
  x_interface_tax_rec.LINK_TO_LINE_ATTRIBUTE10 := p_interface_line_rec.INTERFACE_LINE_ATTRIBUTE10;
  x_interface_tax_rec.LINK_TO_LINE_ATTRIBUTE11 := p_interface_line_rec.INTERFACE_LINE_ATTRIBUTE11;
  x_interface_tax_rec.LINK_TO_LINE_ATTRIBUTE12 := p_interface_line_rec.INTERFACE_LINE_ATTRIBUTE12;
  x_interface_tax_rec.LINK_TO_LINE_ATTRIBUTE13 := p_interface_line_rec.INTERFACE_LINE_ATTRIBUTE13;
  x_interface_tax_rec.LINK_TO_LINE_ATTRIBUTE14 := p_interface_line_rec.INTERFACE_LINE_ATTRIBUTE14;
  x_interface_tax_rec.LINK_TO_LINE_ATTRIBUTE15 := p_interface_line_rec.INTERFACE_LINE_ATTRIBUTE15;
  */

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('OZF', 'OZF_POPULATE_INTF_ERROR');
      FND_MSG_PUB.add;
    END IF;
    IF OZF_DEBUG_LOW_ON THEN
      FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT',sqlerrm);
      FND_MSG_PUB.Add;
    END IF;
    x_return_status := FND_API.g_ret_sts_unexp_error;
END Populate_Interface_Tax_Rec;


/* ---------------------------------------------- *
 * Populate the Interface Distributions Record
 * ---------------------------------------------- */
PROCEDURE Populate_Distributions_Rec
(   p_claim_rec               IN Claim_Rec_Type
   ,p_claim_line_id           IN NUMBER
   ,p_cc_id_rec               IN OZF_GL_INTERFACE_PVT.CC_ID_REC
   ,p_x_int_distributions_rec IN OUT NOCOPY RA_Int_Distributions_Rec_Type
   ,x_return_status           OUT NOCOPY VARCHAR2
) IS
   -- Cursor to get claim reason name -- 11.5.10 Enhancements.
   CURSOR csr_get_reason_name (cv_reason_code_id IN NUMBER) IS
     -- [BEGIN OF BUG 3500049 FIXING]
     -- SELECT substr(name,1,30) name
     SELECT SUBSTRB(name,1,30) name
     -- [END OF BUG 3500049 FIXING]
     FROM   ozf_reason_codes_vl
     WHERE  reason_code_id = cv_reason_code_id;

BEGIN
   -- Start populating the interface record values
   x_return_status := FND_API.g_ret_sts_success;

   /* -- Standard Who Columns ------------------------- */
   p_x_int_distributions_rec.CREATED_BY    := FND_GLOBAL.USER_ID;
   p_x_int_distributions_rec.CREATION_DATE := SYSDATE ;
   p_x_int_distributions_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
   p_x_int_distributions_rec.LAST_UPDATE_DATE := SYSDATE;
   /* ------------------------------------------------- */

   /* -- Fixed Values from unchangeble profiles ------- */
   p_x_int_distributions_rec.INTERFACE_LINE_CONTEXT := 'CLAIM';

   /* ------------------------------------------------- */

   /* -- All Interface line attributes enabled for the context CLAIM --- */
   p_x_int_distributions_rec.INTERFACE_LINE_ATTRIBUTE1 := p_claim_rec.claim_number ;
   p_x_int_distributions_rec.INTERFACE_LINE_ATTRIBUTE2 := TO_CHAR(p_claim_rec.claim_id) ;
   p_x_int_distributions_rec.INTERFACE_LINE_ATTRIBUTE3 := TO_CHAR(p_claim_line_id);
   p_x_int_distributions_rec.INTERFACE_LINE_ATTRIBUTE4 := 'Y';

   p_x_int_distributions_rec.INTERFACE_LINE_ATTRIBUTE5 := NVL(p_claim_rec.customer_ref_number, '-');
   p_x_int_distributions_rec.INTERFACE_LINE_ATTRIBUTE6 := NVL(p_claim_rec.customer_reason, '-') ;

   OPEN  csr_get_reason_name(p_claim_rec.reason_code_id);
   FETCH csr_get_reason_name INTO p_x_int_distributions_rec.INTERFACE_LINE_ATTRIBUTE7;   --reason name
   CLOSE csr_get_reason_name;

   /* -- Only four attributes used for now
   p_x_int_distributions_rec.INTERFACE_LINE_ATTRIBUTE5 := '0';
   p_x_int_distributions_rec.INTERFACE_LINE_ATTRIBUTE6 := '0';
   p_x_int_distributions_rec.INTERFACE_LINE_ATTRIBUTE7 := '0';
   p_x_int_distributions_rec.INTERFACE_LINE_ATTRIBUTE8 := '0';
   p_x_int_distributions_rec.INTERFACE_LINE_ATTRIBUTE9 := '0';
   p_x_int_distributions_rec.INTERFACE_LINE_ATTRIBUTE10 := '0';
   p_x_int_distributions_rec.INTERFACE_LINE_ATTRIBUTE11 := '0';
   p_x_int_distributions_rec.INTERFACE_LINE_ATTRIBUTE12 := '0';
   p_x_int_distributions_rec.INTERFACE_LINE_ATTRIBUTE13 := '0';
   p_x_int_distributions_rec.INTERFACE_LINE_ATTRIBUTE14 := '0';
   p_x_int_distributions_rec.INTERFACE_LINE_ATTRIBUTE15 := '0';
   */

   p_x_int_distributions_rec.CODE_COMBINATION_ID := p_cc_id_rec.code_combination_id;
   p_x_int_distributions_rec.ACCOUNT_CLASS       := 'REV';

   /* -- Set Org Id ------------------- */
   p_x_int_distributions_rec.ORG_ID          :=  p_claim_rec.org_id;

   /* ---- Finally populate the Amount ---------------------------- */
   /*
   IF p_claim_rec.payment_method = 'CREDIT_MEMO' THEN
      -- amount signs are changed for on account credit memos
      p_x_int_distributions_rec.AMOUNT          := p_cc_id_rec.amount  * -1;
      p_x_int_distributions_rec.ACCTD_AMOUNT    := p_cc_id_rec.acctd_amount  * -1;
   ELSIF p_claim_rec.payment_method = 'DEBIT_MEMO' THEN
      -- creation sign for debit memo is positive
      p_x_int_distributions_rec.AMOUNT          := p_cc_id_rec.amount;
      p_x_int_distributions_rec.ACCTD_AMOUNT    := p_cc_id_rec.acctd_amount;
   ELSIF p_claim_rec.payment_method = 'CHARGEBACK' THEN
      -- amount signs are changed for on account credit memos
      p_x_int_distributions_rec.AMOUNT          := p_cc_id_rec.amount;
      p_x_int_distributions_rec.ACCTD_AMOUNT    := p_cc_id_rec.acctd_amount;
   END IF;
   */

   -- set the percent for amount
   p_x_int_distributions_rec.PERCENT         := 100;
   /* ------------------------------------------------------------- */

EXCEPTION
   WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_POPULATE_DIST_ERROR');
         FND_MSG_PUB.add;
      END IF;
      IF OZF_DEBUG_LOW_ON THEN
         FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
         FND_MESSAGE.Set_Token('TEXT',sqlerrm);
         FND_MSG_PUB.Add;
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;
END Populate_Distributions_Rec;

PROCEDURE Interface_Claim_Line
(   p_claim_id            IN   NUMBER
   ,p_memo_line_id        IN   NUMBER
   ,p_claim_line_id       IN   NUMBER
   ,p_line_claim_curr_amt IN   NUMBER
   ,p_line_tax_code       IN   VARCHAR2
   ,p_line_cc_id_flag     IN   VARCHAR2
   ,x_return_status   OUT NOCOPY  VARCHAR2
) IS

l_interface_line_rec      RA_Interface_Lines_Rec_Type;
l_interface_tax_rec       RA_Interface_Lines_Rec_Type;
l_int_sales_credits_rec   RA_Int_Sales_Credits_Rec_Type;
l_claim_rec               Claim_Rec_Type;

CURSOR csr_sales_credit_type(cv_salesrep_id IN NUMBER) IS
  SELECT sales_credit_type_id
  FROM ra_salesreps
  WHERE salesrep_id = cv_salesrep_id;

BEGIN

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   Query_Claim ( p_claim_id      => p_claim_id,
                x_claim_rec     => l_claim_rec,
                x_return_status => x_return_status);

   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   --Populate the interface record with information from claim header and line
   Populate_Interface_Line_Rec(p_claim_rec            => l_claim_rec,
                               p_memo_line_id         => p_memo_line_id,
                               p_claim_line_id        => p_claim_line_id,
                               p_line_claim_curr_amt  => p_line_claim_curr_amt,
                               p_line_tax_code        => p_line_tax_code,
                               p_line_cc_id_flag      => p_line_cc_id_flag,
                               p_x_interface_line_rec => l_interface_line_rec,
                               x_return_status        => x_return_status
                              );
   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   --Insert the line into RA_INTERFACE_LINES_ALL
   Insert_Interface_Line(l_interface_line_rec,
                         x_return_status);

   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -------------------
   -- Sales Credits --
   -------------------
   IF l_claim_rec.sales_rep_id IS NOT NULL THEN
      l_int_sales_credits_rec.CREATED_BY    := FND_GLOBAL.USER_ID;
      l_int_sales_credits_rec.CREATION_DATE := SYSDATE ;
      l_int_sales_credits_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_int_sales_credits_rec.LAST_UPDATE_DATE := SYSDATE;

      l_int_sales_credits_rec.INTERFACE_LINE_CONTEXT := l_interface_line_rec.INTERFACE_LINE_CONTEXT;
      l_int_sales_credits_rec.INTERFACE_LINE_ATTRIBUTE1 := l_interface_line_rec.INTERFACE_LINE_ATTRIBUTE1;
      l_int_sales_credits_rec.INTERFACE_LINE_ATTRIBUTE2 := l_interface_line_rec.INTERFACE_LINE_ATTRIBUTE2;
      l_int_sales_credits_rec.INTERFACE_LINE_ATTRIBUTE3 := l_interface_line_rec.INTERFACE_LINE_ATTRIBUTE3;
      l_int_sales_credits_rec.INTERFACE_LINE_ATTRIBUTE4 := l_interface_line_rec.INTERFACE_LINE_ATTRIBUTE4;
      l_int_sales_credits_rec.INTERFACE_LINE_ATTRIBUTE5 := l_interface_line_rec.INTERFACE_LINE_ATTRIBUTE5;
      l_int_sales_credits_rec.INTERFACE_LINE_ATTRIBUTE6 := l_interface_line_rec.INTERFACE_LINE_ATTRIBUTE6;
      l_int_sales_credits_rec.INTERFACE_LINE_ATTRIBUTE7 := l_interface_line_rec.INTERFACE_LINE_ATTRIBUTE7;

      l_int_sales_credits_rec.SALESREP_ID := l_claim_rec.sales_rep_id;
      OPEN csr_sales_credit_type(l_claim_rec.sales_rep_id);
      FETCH csr_sales_credit_type INTO l_int_sales_credits_rec.SALES_CREDIT_TYPE_ID;
      CLOSE csr_sales_credit_type;
      l_int_sales_credits_rec.SALES_CREDIT_PERCENT_SPLIT := 100;
      l_int_sales_credits_rec.ORG_ID := l_claim_rec.org_id;

      Insert_Interface_Sales_Credits(
            l_int_sales_credits_rec,
            x_return_status
      );
      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   /* passing tax lines through AutoInvoice if tax_code exists in claim line. */
   /*
   IF p_line_tax_code IS NOT NULL THEN
     --prepare tax line interface record
     Populate_Interface_Tax_Rec( p_line_tax_code        => p_line_tax_code,
                                 p_interface_line_rec   => l_interface_line_rec,
                                 x_interface_tax_rec    => l_interface_tax_rec,
                                 x_return_status        => x_return_status
                               );
     IF x_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
     ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
     END IF;

     --Insert the tax into RA_INTERFACE_LINES_ALL
     Insert_Interface_Tax( l_interface_tax_rec,
                           x_return_status
                         );
     IF x_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
     ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
     END IF;
   END IF; -- end of passing tax interface record.
   */

END Interface_Claim_Line;

PROCEDURE Distribute_Claim_Line
(   p_claim_id            IN   NUMBER
   ,p_claim_line_id       IN   NUMBER
   ,p_cc_id_rec           IN   OZF_GL_INTERFACE_PVT.CC_ID_REC
   ,x_return_status       OUT NOCOPY  VARCHAR2
) IS

l_int_distributions_rec   RA_Int_Distributions_Rec_Type;
l_claim_rec               Claim_Rec_Type;

BEGIN

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   Query_Claim ( p_claim_id      => p_claim_id,
                x_claim_rec     => l_claim_rec,
                x_return_status => x_return_status);

   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   --Populate the distribution record with info from claim header and line
   Populate_Distributions_Rec(p_claim_rec               => l_claim_rec,
                           p_claim_line_id           => p_claim_line_id,
                           p_cc_id_rec               => p_cc_id_rec,
                           p_x_int_distributions_rec => l_int_distributions_rec,
                           x_return_status           => x_return_status
                          );
   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- Insert the line into RA_INTERFACE_DISTRIBUTIONS_ALL
   Insert_Int_Distributions(l_int_distributions_rec,
                            x_return_status);
   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

END Distribute_Claim_Line;


PROCEDURE Interface_Claim
(   p_api_version      IN NUMBER
   ,p_init_msg_list    IN VARCHAR2
   ,p_commit           IN VARCHAR2
   ,p_validation_level IN VARCHAR2
   ,p_claim_id         IN NUMBER
   ,x_return_status   OUT NOCOPY VARCHAR2
   ,x_msg_data        OUT NOCOPY VARCHAR2
   ,x_msg_count       OUT NOCOPY NUMBER
) IS

--
l_api_name       CONSTANT VARCHAR2(30) := 'Interface_Claim' ;
l_api_version    CONSTANT NUMBER       := 1.0;
l_full_name      CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id            NUMBER;
l_user_id                NUMBER;
l_login_user_id          NUMBER;
l_login_user_status      VARCHAR2(30);
l_Error_Msg              VARCHAR2(2000);
l_Error_Token            VARCHAR2(80);
l_object_version_number  NUMBER    := 1;
--x_msg_count              NUMBER;
--x_msg_data               VARCHAR2(240);
l_return_status          VARCHAR2(1);
l_result_out             VARCHAR2(30);

/*
CURSOR grouped_claim_line_csr IS
   SELECT  SUM(NVL(cll.claim_currency_amount,0)),
           NVL(cll.claim_currency_amount,0)
   FROM    ozf_claim_lines cll
   WHERE   cll.claim_id = p_claim_id;
   GROUP BY Get_Memo_Line_Id(cll.claim_id);
*/
--12.1 Price Protection Enhancement
CURSOR claim_line_csr IS
   SELECT  cll.claim_line_id
   ,       NVL(cll.claim_currency_amount,0)
   ,       cll.tax_code
   ,       Get_Memo_Line_Id(cll.claim_line_id)
   ,       cll.earnings_associated_flag
   ,       cll.source_object_class
   FROM    ozf_claim_lines cll
   WHERE   cll.claim_id = p_claim_id;

l_memo_line_id           NUMBER;
l_grpd_claim_curr_amt    NUMBER;
l_claim_line_id          NUMBER;
l_line_claim_curr_amt    NUMBER;
l_line_tax_code          VARCHAR2(50);
l_line_cc_id_flag        VARCHAR2(1);
l_earnings_asso_flag     VARCHAR2(1);
l_cc_id_tbl              OZF_GL_INTERFACE_PVT.CC_ID_TBL;

--Bug3928503 - post_to_gl flag not considered for promotional claims
l_post_to_gl            varchar2(1);
--12.1 Price Protection Enhancement
l_source_object_class varchar2(25);

CURSOR claim_gl_posting_csr(p_id in number) IS
SELECT osp.post_to_gl
FROM   ozf_sys_parameters_all osp
,      ozf_claims_all oc
WHERE  NVL(osp.org_id, -99) = NVL(oc.org_id, -99)
AND    oc.claim_id = p_id;


BEGIN

/* ------- Begin Standard API Calls --------------------------- */
   -- Standard begin of API savepoint
   SAVEPOINT Interface_Claim_PVT ;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (
      l_api_version,
      p_api_version,
      l_api_name,
      G_PKG_NAME)
   THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
      FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
      FND_MSG_PUB.Add;
   END IF;
   --Initialize message list if p_init_msg_list is TRUE.
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;
   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

/* ------- End Standard API Calls ----------------------------- */

/* ------- Begin API Logic ------------------------------------ */

   OPEN  claim_gl_posting_csr(p_claim_id) ;
   FETCH claim_gl_posting_csr INTO l_post_to_gl;
   CLOSE claim_gl_posting_csr;


   OPEN claim_line_csr;
   LOOP
      l_line_cc_id_flag := NULL;

      FETCH claim_line_csr INTO l_claim_line_id
                              , l_line_claim_curr_amt
                              , l_line_tax_code
                              , l_memo_line_id
                              , l_earnings_asso_flag
			      , l_source_object_class;
      EXIT WHEN claim_line_csr%NOTFOUND;
--12.1 Price Protection Enhancement
      IF ((l_earnings_asso_flag = 'T' AND l_post_to_gl = 'T') OR (l_source_object_class = 'PPCUSTOMER'))
      THEN
        OZF_GL_INTERFACE_PVT.Get_GL_Account(
            p_api_version      => l_api_version
           ,p_init_msg_list    => FND_API.g_false
           ,p_commit           => FND_API.g_false
           ,p_validation_level => FND_API.g_valid_level_full
           ,x_return_status    => l_return_status
           ,x_msg_data         => x_msg_data
           ,x_msg_count        => x_msg_count
           ,p_source_id        => l_claim_line_id
           ,p_source_table     => 'OZF_CLAIM_LINES_ALL'
           ,p_account_type     => 'REC_CLEARING'
           ,x_cc_id_tbl        => l_cc_id_tbl
        );
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        l_line_cc_id_flag := 'Y';
      ELSE
        l_line_cc_id_flag := 'N';
      END IF;

      Interface_Claim_Line( p_claim_id,
                            l_memo_line_id,
                            l_claim_line_id,
                            l_line_claim_curr_amt,
                            l_line_tax_code,
                            l_line_cc_id_flag,
                            l_return_status);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF l_line_cc_id_flag = 'Y' THEN
        FOR i IN 1..(l_cc_id_tbl.COUNT) LOOP
           Distribute_Claim_Line(p_claim_id,
                                 l_claim_line_id,
                                 l_cc_id_tbl(i),
                                 l_return_status
                                );
          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END LOOP;
      END IF;
   END LOOP;

   CLOSE claim_line_csr;

/* ------- End API Logic ------------------------------------- */

/* ------- Begin Update Claim Payment Status ----------------- */
    UPDATE ozf_claims_all
    SET payment_status = 'INTERFACED'
    WHERE claim_id = p_claim_id;
/* ------- End Update Claim Payment Status ------------------- */

/* ------- Begin Standard API Calls --------------------------- */

   --Standard check of commit
   IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
      FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
      FND_MSG_PUB.Add;
   END IF;
   --Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count => x_msg_count,
   p_data  => x_msg_data
   );

/* ------- End Standard API Calls ----------------------------- */
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      IF (claim_line_csr%ISOPEN) THEN
         CLOSE claim_line_csr;
      END IF;
      ROLLBACK TO  Interface_Claim_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (claim_line_csr%ISOPEN) THEN
         CLOSE claim_line_csr;
      END IF;
      ROLLBACK TO  Interface_Claim_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count => x_msg_count,
   p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      IF (claim_line_csr%ISOPEN) THEN
         CLOSE claim_line_csr;
      END IF;
      ROLLBACK TO  Interface_Claim_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

END Interface_Claim ;

END OZF_Ar_Interface_PVT ;

/
