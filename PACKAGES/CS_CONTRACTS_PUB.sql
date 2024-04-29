--------------------------------------------------------
--  DDL for Package CS_CONTRACTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CONTRACTS_PUB" AUTHID CURRENT_USER AS
/* $Header: csctpaps.pls 115.3 99/07/16 08:53:14 porting ship $ */
--------------------------------------------------------------------------------
-- GLOBAL DATASTRUCTURES
--------------------------------------------------------------------------------
  SUBTYPE contract_rec_type 		IS CS_CONTRACTS_ALL%ROWTYPE;
  TYPE contract_tbl_type IS TABLE OF contract_rec_type
	INDEX BY BINARY_INTEGER;
  SUBTYPE contracts_billing_rec_type 	IS CS_CONTRACTS_BILLING%ROWTYPE;
  TYPE contracts_billing_tbl_type IS TABLE OF contracts_billing_rec_type
	INDEX BY BINARY_INTEGER;
  SUBTYPE services_all_rec_type 	IS CS_CP_SERVICES_ALL%ROWTYPE;
  TYPE services_all_tbl_type IS TABLE OF services_all_rec_type
	INDEX BY BINARY_INTEGER;
  SUBTYPE contract_cov_lvls_rec_type 	IS CS_CONTRACT_COV_LEVELS%ROWTYPE;
  TYPE contract_cov_lvls_tbl_type IS TABLE OF contract_cov_lvls_rec_type
	INDEX BY BINARY_INTEGER;
  SUBTYPE covered_Products_rec_type 	IS CS_COVERED_PRODUCTS%ROWTYPE;
  TYPE covered_products_tbl_type IS TABLE OF covered_products_rec_type
	INDEX BY BINARY_INTEGER;
  SUBTYPE service_txns_rec_type 	IS CS_CP_SERVICE_TRANSACTIONS%ROWTYPE;
  TYPE service_txns_tbl_type IS TABLE OF service_txns_rec_type
	INDEX BY BINARY_INTEGER;
  SUBTYPE contract_Line_Templts_rec_type IS CS_CONTRACT_LINE_TPLTS%ROWTYPE;
  TYPE contract_line_templts_tbl_type IS TABLE OF contract_line_templts_rec_type
	INDEX BY BINARY_INTEGER;
  SUBTYPE coverages_rec_type 		IS CS_COVERAGES%ROWTYPE;
  TYPE coverages_tbl_type IS TABLE OF coverages_rec_type
	INDEX BY BINARY_INTEGER;
-- COMMENTED OUT 30-SEP-98 JSU
--  SUBTYPE coverages_Used_rec_type 	IS CS_COVERAGES_USED%ROWTYPE;
--  TYPE coverages_used_tbl_type IS TABLE OF coverages_used_rec_type
--	INDEX BY BINARY_INTEGER;
  SUBTYPE coverage_txn_groups_rec_type	IS CS_COVERAGE_TXN_GROUPS%ROWTYPE;
  TYPE coverage_txn_groups_tbl_type IS TABLE OF coverage_txn_groups_rec_type
	INDEX BY BINARY_INTEGER;
  SUBTYPE cov_reactn_times_rec_type IS CS_COV_REACTION_TIMES%ROWTYPE;
  TYPE cov_reactn_times_tbl_type IS TABLE OF cov_reactn_times_rec_type
	INDEX BY BINARY_INTEGER;
  SUBTYPE cov_bill_types_rec_type 	IS CS_COV_BILLING_TYPES%ROWTYPE;
  TYPE cov_bill_types_tbl_type IS TABLE OF cov_bill_types_rec_type
	INDEX BY BINARY_INTEGER;
  SUBTYPE cov_bill_rates_rec_type	IS CS_COV_BILL_RATES%ROWTYPE;
  TYPE cov_bill_rates_tbl_type IS TABLE OF cov_bill_rates_rec_type
	INDEX BY BINARY_INTEGER;
-- COMMENTED OUT 14-OCT-98 SKARUPPA
 ---SUBTYPE coverage_events_rec_type	IS CS_COVERAGE_EVENTS%ROWTYPE;
 ---TYPE coverage_events_tbl_type IS TABLE OF coverage_events_rec_type
---INDEX BY BINARY_INTEGER;
-- COMMENTED OUT 30-SEP-98 JSU
--  SUBTYPE cov_txn_grp_count_rec_type 	IS CS_COVERAGE_TXN_GRP_CTRS%ROWTYPE;
--  TYPE cov_txn_grp_count_tbl_type IS TABLE OF cov_txn_grp_count_rec_type
--	INDEX BY BINARY_INTEGER;
--------------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
--------------------------------------------------------------------------------
G_FND_APP			CONSTANT VARCHAR2(200) := TAPI_DEV_KIT.G_FND_APP;
G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := TAPI_DEV_KIT.G_FORM_UNABLE_TO_RESERVE_REC;
G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := TAPI_DEV_KIT.G_FORM_RECORD_DELETED;
G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := TAPI_DEV_KIT.G_FORM_RECORD_CHANGED;
G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := TAPI_DEV_KIT.G_RECORD_LOGICALLY_DELETED;
G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := TAPI_DEV_KIT.G_REQUIRED_VALUE;
G_INVALID_VALUE			CONSTANT VARCHAR2(200) := TAPI_DEV_KIT.G_INVALID_VALUE;
G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := TAPI_DEV_KIT.G_COL_NAME_TOKEN;
G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := TAPI_DEV_KIT.G_PARENT_TABLE_TOKEN;
G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := TAPI_DEV_KIT.G_CHILD_TABLE_TOKEN;
--------------------------------------------------------------------------------
-- GLOBAL VARIABLES
--------------------------------------------------------------------------------
G_PKG_NAME		CONSTANT	VARCHAR2(200) := 'CS_CONTRACTS_PUB';
G_APP_NAME		CONSTANT 	VARCHAR2(3) :=  TAPI_DEV_KIT.G_APP_NAME;
--------------------------------------------------------------------------------
-- Procedures and Functions
--------------------------------------------------------------------------------
PROCEDURE validate_contract
(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_contract_rec                 IN contract_rec_type
);
PROCEDURE validate_contract
(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_contract_id                  IN CS_CONTRACTS.CONTRACT_ID%TYPE
/*, -- COMMENTED OUT 17-SEP-98 DEVELOPER/2000 FORMS uses PL/SQL 1.6 which cannot
    -- handle selective parameter passing
    p_contract_number              IN CS_CONTRACTS.CONTRACT_NUMBER%TYPE := NULL,
    p_workflow                     IN CS_CONTRACTS.WORKFLOW%TYPE := NULL,
    p_agreement_id                 IN CS_CONTRACTS.AGREEMENT_ID%TYPE := NULL,
    p_price_list_id                IN CS_CONTRACTS.PRICE_LIST_ID%TYPE := NULL,
    p_currency_code                IN CS_CONTRACTS.CURRENCY_CODE%TYPE := NULL,
    p_conversion_type_code         IN CS_CONTRACTS.CONVERSION_TYPE_CODE%TYPE := NULL,
    p_conversion_rate              IN CS_CONTRACTS.CONVERSION_RATE%TYPE := NULL,
    p_conversion_date              IN CS_CONTRACTS.CONVERSION_DATE%TYPE := NULL,
    p_invoicing_rule_id            IN CS_CONTRACTS.INVOICING_RULE_ID%TYPE := NULL,
    p_accounting_rule_id           IN CS_CONTRACTS.ACCOUNTING_RULE_ID%TYPE := NULL,
    p_billing_frequency_period     IN CS_CONTRACTS.BILLING_FREQUENCY_PERIOD%TYPE := NULL,
    p_first_bill_date              IN CS_CONTRACTS.FIRST_BILL_DATE%TYPE := NULL,
    p_next_bill_date               IN CS_CONTRACTS.NEXT_BILL_DATE%TYPE := NULL,
    p_create_sales_order           IN CS_CONTRACTS.CREATE_SALES_ORDER%TYPE := NULL,
    p_renewal_rule                 IN CS_CONTRACTS.RENEWAL_RULE%TYPE := NULL,
    p_termination_rule             IN CS_CONTRACTS.TERMINATION_RULE%TYPE := NULL,
    p_bill_to_site_use_id          IN CS_CONTRACTS.BILL_TO_SITE_USE_ID%TYPE := NULL,
    p_contract_status_id           IN CS_CONTRACTS.CONTRACT_STATUS_ID%TYPE := NULL,
    p_contract_type_id             IN CS_CONTRACTS.CONTRACT_TYPE_ID%TYPE := NULL,
    p_contract_template_id         IN CS_CONTRACTS.CONTRACT_TEMPLATE_ID%TYPE := NULL,
    p_contract_group_id            IN CS_CONTRACTS.CONTRACT_GROUP_ID%TYPE := NULL,
    p_customer_id                  IN CS_CONTRACTS.CUSTOMER_ID%TYPE := NULL,
    p_duration                     IN CS_CONTRACTS.DURATION%TYPE := NULL,
    p_period_code                  IN CS_CONTRACTS.PERIOD_CODE%TYPE := NULL,
    p_ship_to_site_use_id          IN CS_CONTRACTS.SHIP_TO_SITE_USE_ID%TYPE := NULL,
    p_salesperson_id               IN CS_CONTRACTS.SALESPERSON_ID%TYPE := NULL,
    p_ordered_by_contact_id        IN CS_CONTRACTS.ORDERED_BY_CONTACT_ID%TYPE := NULL,
    p_source_code                  IN CS_CONTRACTS.SOURCE_CODE%TYPE := NULL,
    p_source_reference             IN CS_CONTRACTS.SOURCE_REFERENCE%TYPE := NULL,
    p_terms_id                     IN CS_CONTRACTS.TERMS_ID%TYPE := NULL,
    p_po_number                    IN CS_CONTRACTS.PO_NUMBER%TYPE := NULL,
    p_bill_on                      IN CS_CONTRACTS.BILL_ON%TYPE := NULL,
    p_tax_handling                 IN CS_CONTRACTS.TAX_HANDLING%TYPE := NULL,
    p_tax_exempt_num               IN CS_CONTRACTS.TAX_EXEMPT_NUM%TYPE := NULL,
    p_tax_exempt_reason_code       IN CS_CONTRACTS.TAX_EXEMPT_REASON_CODE%TYPE := NULL,
    p_contract_amount              IN CS_CONTRACTS.CONTRACT_AMOUNT%TYPE := NULL,
    p_auto_renewal_flag            IN CS_CONTRACTS.AUTO_RENEWAL_FLAG%TYPE := NULL,
    p_original_end_date            IN CS_CONTRACTS.ORIGINAL_END_DATE%TYPE := NULL,
    p_terminate_reason_code        IN CS_CONTRACTS.TERMINATE_REASON_CODE%TYPE := NULL,
    p_discount_id                  IN CS_CONTRACTS.DISCOUNT_ID%TYPE := NULL,
    p_po_required_to_service       IN CS_CONTRACTS.PO_REQUIRED_TO_SERVICE%TYPE := NULL,
    p_pre_payment_required         IN CS_CONTRACTS.PRE_PAYMENT_REQUIRED%TYPE := NULL,
    p_last_update_date             IN CS_CONTRACTS.LAST_UPDATE_DATE%TYPE := NULL,
    p_last_updated_by              IN CS_CONTRACTS.LAST_UPDATED_BY%TYPE := NULL,
    p_creation_date                IN CS_CONTRACTS.CREATION_DATE%TYPE := NULL,
    p_created_by                   IN CS_CONTRACTS.CREATED_BY%TYPE := NULL,
    p_last_update_login            IN CS_CONTRACTS.LAST_UPDATE_LOGIN%TYPE := NULL,
    p_start_date_active            IN CS_CONTRACTS.START_DATE_ACTIVE%TYPE := NULL,
    p_end_date_active              IN CS_CONTRACTS.END_DATE_ACTIVE%TYPE := NULL,
    p_attribute1                   IN CS_CONTRACTS.ATTRIBUTE1%TYPE := NULL,
    p_attribute2                   IN CS_CONTRACTS.ATTRIBUTE2%TYPE := NULL,
    p_attribute3                   IN CS_CONTRACTS.ATTRIBUTE3%TYPE := NULL,
    p_attribute4                   IN CS_CONTRACTS.ATTRIBUTE4%TYPE := NULL,
    p_attribute5                   IN CS_CONTRACTS.ATTRIBUTE5%TYPE := NULL,
    p_attribute6                   IN CS_CONTRACTS.ATTRIBUTE6%TYPE := NULL,
    p_attribute7                   IN CS_CONTRACTS.ATTRIBUTE7%TYPE := NULL,
    p_attribute8                   IN CS_CONTRACTS.ATTRIBUTE8%TYPE := NULL,
    p_attribute9                   IN CS_CONTRACTS.ATTRIBUTE9%TYPE := NULL,
    p_attribute10                  IN CS_CONTRACTS.ATTRIBUTE10%TYPE := NULL,
    p_attribute11                  IN CS_CONTRACTS.ATTRIBUTE11%TYPE := NULL,
    p_attribute12                  IN CS_CONTRACTS.ATTRIBUTE12%TYPE := NULL,
    p_attribute13                  IN CS_CONTRACTS.ATTRIBUTE13%TYPE := NULL,
    p_attribute14                  IN CS_CONTRACTS.ATTRIBUTE14%TYPE := NULL,
    p_attribute15                  IN CS_CONTRACTS.ATTRIBUTE15%TYPE := NULL,
    p_context                      IN CS_CONTRACTS.CONTEXT%TYPE := NULL,
    p_object_version_number        IN CS_CONTRACTS.OBJECT_VERSION_NUMBER%TYPE := NULL
*/
);

   Procedure update_contract
   (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_contract_id                  IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_contract_number              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_workflow                     IN CS_CONTRACTS.WORKFLOW%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_workflow_process_id          IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_agreement_id                 IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_price_list_id                IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_currency_code                IN CS_CONTRACTS.CURRENCY_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_conversion_type_code         IN CS_CONTRACTS.CONVERSION_TYPE_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_conversion_rate              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_conversion_date              IN CS_CONTRACTS.CONVERSION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_invoicing_rule_id            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_accounting_rule_id           IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_billing_frequency_period     IN CS_CONTRACTS.BILLING_FREQUENCY_PERIOD%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_first_bill_date              IN CS_CONTRACTS.FIRST_BILL_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_next_bill_date               IN CS_CONTRACTS.NEXT_BILL_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_create_sales_order           IN CS_CONTRACTS.CREATE_SALES_ORDER%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_renewal_rule                 IN CS_CONTRACTS.RENEWAL_RULE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_termination_rule             IN CS_CONTRACTS.TERMINATION_RULE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_bill_to_site_use_id          IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_contract_status_id           IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_contract_type_id             IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_contract_template_id         IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_contract_group_id            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_customer_id                  IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_duration                     IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_period_code                  IN CS_CONTRACTS.PERIOD_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_ship_to_site_use_id          IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_salesperson_id               IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_ordered_by_contact_id        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_source_code                  IN CS_CONTRACTS.SOURCE_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_source_reference             IN CS_CONTRACTS.SOURCE_REFERENCE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_terms_id                     IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_po_number                    IN CS_CONTRACTS.PO_NUMBER%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_bill_on                      IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_tax_handling                 IN CS_CONTRACTS.TAX_HANDLING%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_tax_exempt_num               IN CS_CONTRACTS.TAX_EXEMPT_NUM%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_tax_exempt_reason_code       IN CS_CONTRACTS.TAX_EXEMPT_REASON_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_contract_amount              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_auto_renewal_flag            IN CS_CONTRACTS.AUTO_RENEWAL_FLAG%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_original_end_date            IN CS_CONTRACTS.ORIGINAL_END_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_terminate_reason_code        IN CS_CONTRACTS.TERMINATE_REASON_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_discount_id                  IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_po_required_to_service       IN CS_CONTRACTS.PO_REQUIRED_TO_SERVICE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pre_payment_required         IN CS_CONTRACTS.PRE_PAYMENT_REQUIRED%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_last_update_date             IN CS_CONTRACTS.LAST_UPDATE_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_last_updated_by              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_creation_date                IN CS_CONTRACTS.CREATION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_created_by                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_last_update_login            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_start_date_active            IN CS_CONTRACTS.START_DATE_ACTIVE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_end_date_active              IN CS_CONTRACTS.END_DATE_ACTIVE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_attribute1                   IN CS_CONTRACTS.ATTRIBUTE1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute2                   IN CS_CONTRACTS.ATTRIBUTE2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute3                   IN CS_CONTRACTS.ATTRIBUTE3%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute4                   IN CS_CONTRACTS.ATTRIBUTE4%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute5                   IN CS_CONTRACTS.ATTRIBUTE5%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute6                   IN CS_CONTRACTS.ATTRIBUTE6%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute7                   IN CS_CONTRACTS.ATTRIBUTE7%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute8                   IN CS_CONTRACTS.ATTRIBUTE8%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute9                   IN CS_CONTRACTS.ATTRIBUTE9%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute10                  IN CS_CONTRACTS.ATTRIBUTE10%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute11                  IN CS_CONTRACTS.ATTRIBUTE11%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute12                  IN CS_CONTRACTS.ATTRIBUTE12%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute13                  IN CS_CONTRACTS.ATTRIBUTE13%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute14                  IN CS_CONTRACTS.ATTRIBUTE14%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute15                  IN CS_CONTRACTS.ATTRIBUTE15%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_context                      IN CS_CONTRACTS.CONTEXT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_object_version_number        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    x_object_version_number        OUT NUMBER);


END CS_CONTRACTS_PUB;

 

/
