--------------------------------------------------------
--  DDL for Package ZX_VALIDATE_API_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_VALIDATE_API_PKG" AUTHID CURRENT_USER as
/* $Header: zxapdefvalpkgs.pls 120.9 2006/03/29 06:42:59 agurram ship $ */


  TYPE trx_line_id_tbl IS TABLE OF
    ZX_TRANSACTION_LINES_GT.trx_line_id%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE trx_level_type_tbl IS TABLE OF
    ZX_TRANSACTION_LINES_GT.trx_level_type%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE ship_from_party_id_tbl IS TABLE OF
    ZX_TRANSACTION_LINES_GT.ship_from_party_id%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE ship_from_party_site_id_tbl IS TABLE OF
    ZX_TRANSACTION_LINES_GT.ship_from_party_site_id%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE account_ccid_tbl IS TABLE OF
    ZX_TRANSACTION_LINES_GT.account_ccid%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE account_string_tbl IS TABLE OF
    ZX_TRANSACTION_LINES_GT.account_string%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE ship_to_location_id_tbl IS TABLE OF
    ZX_TRANSACTION_LINES_GT.ship_to_location_id%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE product_id_tbl IS TABLE OF
    ZX_TRANSACTION_LINES_GT.product_id%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE product_type_tbl IS TABLE OF
    ZX_TRANSACTION_LINES_GT.product_type%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE product_org_id_tbl IS TABLE OF
    ZX_TRANSACTION_LINES_GT.product_org_id%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE event_class_code_tbl IS TABLE OF
    ZX_TRX_HEADERS_GT.event_class_code%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE entity_code_tbl IS TABLE OF
    ZX_TRX_HEADERS_GT.entity_code%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE shipto_cust_acct_siteuseid_tbl IS TABLE OF
    ZX_TRX_HEADERS_GT.ship_to_cust_acct_site_use_id%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE billto_cust_acct_siteuseid_tbl IS TABLE OF
    ZX_TRX_HEADERS_GT.bill_to_cust_acct_site_use_id%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE internal_organization_id_tbl IS TABLE OF
    ZX_TRX_HEADERS_GT.internal_organization_id%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE ledger_id_tbl IS TABLE OF
    ZX_TRX_HEADERS_GT.ledger_id%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE trx_date_tbl IS TABLE OF
    ZX_TRX_HEADERS_GT.trx_date%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE receivables_trx_type_id_tbl IS TABLE OF
    ZX_TRX_HEADERS_GT.receivables_trx_type_id%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE trx_id_tbl IS TABLE OF
    ZX_TRX_HEADERS_GT.trx_id%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE application_id_tbl IS TABLE OF
    ZX_TRX_HEADERS_GT.application_id%TYPE
    INDEX BY BINARY_INTEGER;

   TYPE legal_entity_id_tbl IS TABLE OF
    ZX_TRX_HEADERS_GT.legal_entity_id%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE ship_third_pty_acct_id_tbl IS TABLE OF
    ZX_TRX_HEADERS_GT.ship_third_pty_acct_id%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE bill_third_pty_acct_id_tbl IS TABLE OF
    ZX_TRX_HEADERS_GT.bill_third_pty_acct_id%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE defaulting_attribute1_tbl IS TABLE OF
    ZX_TRANSACTION_LINES_GT.defaulting_attribute1%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE defaulting_attribute2_tbl IS TABLE OF
    ZX_TRANSACTION_LINES_GT.defaulting_attribute2%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE defaulting_attribute3_tbl IS TABLE OF
    ZX_TRANSACTION_LINES_GT.defaulting_attribute3%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE defaulting_attribute4_tbl IS TABLE OF
    ZX_TRANSACTION_LINES_GT.defaulting_attribute4%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE defaulting_attribute5_tbl IS TABLE OF
    ZX_TRANSACTION_LINES_GT.defaulting_attribute5%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE defaulting_attribute6_tbl IS TABLE OF
    ZX_TRANSACTION_LINES_GT.defaulting_attribute6%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE defaulting_attribute7_tbl IS TABLE OF
    ZX_TRANSACTION_LINES_GT.defaulting_attribute7%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE defaulting_attribute8_tbl IS TABLE OF
    ZX_TRANSACTION_LINES_GT.defaulting_attribute8%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE defaulting_attribute9_tbl IS TABLE OF
    ZX_TRANSACTION_LINES_GT.defaulting_attribute9%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE defaulting_attribute10_tbl IS TABLE OF
    ZX_TRANSACTION_LINES_GT.defaulting_attribute10%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE input_tax_classif_code_tbl IS TABLE OF
    ZX_TRANSACTION_LINES_GT.INPUT_TAX_CLASSIFICATION_CODE%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE output_tax_classif_code_tbl IS TABLE OF
    ZX_TRANSACTION_LINES_GT.OUTPUT_TAX_CLASSIFICATION_CODE%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE  ref_doc_application_id_tbl IS TABLE OF
    ZX_TRANSACTION_LINES_GT.REF_DOC_APPLICATION_ID%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE  ref_doc_entity_code_tbl IS TABLE OF
    ZX_TRANSACTION_LINES_GT.REF_DOC_ENTITY_CODE%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE  ref_doc_event_class_code_tbl IS TABLE OF
    ZX_TRANSACTION_LINES_GT.REF_DOC_EVENT_CLASS_CODE%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE  ref_doc_trx_id_tbl IS TABLE OF
    ZX_TRANSACTION_LINES_GT.REF_DOC_TRX_ID%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE  ref_doc_line_id_tbl IS TABLE OF
    ZX_TRANSACTION_LINES_GT.REF_DOC_LINE_ID%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE  ref_doc_trx_level_type_tbl IS TABLE OF
    ZX_TRANSACTION_LINES_GT.REF_DOC_TRX_LEVEL_TYPE%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE summary_tax_line_number_tbl IS TABLE OF
    ZX_IMPORT_TAX_LINES_GT.summary_tax_line_number%TYPE
    INDEX BY BINARY_INTEGER;

------------ Main Procedure(Called from AP) ---------------------------

PROCEDURE Default_And_Validate_Tax_Attr(
	p_api_version      IN NUMBER,
	p_init_msg_list    IN VARCHAR2,
	p_commit           IN VARCHAR2,
	p_validation_level IN VARCHAR2,
	x_return_status OUT NOCOPY VARCHAR2,
	x_msg_count     OUT NOCOPY NUMBER,
	x_msg_data      OUT NOCOPY VARCHAR2);

------------------ Procedure For Defaulting -----------------------

PROCEDURE Default_Tax_Attr(x_return_status OUT NOCOPY VARCHAR2);

------------------ Procedure For Validating -----------------------

PROCEDURE Validate_Tax_Attr(x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE pop_def_tax_classif_code(
    x_return_status            OUT NOCOPY  VARCHAR2);


END Zx_Validate_Api_Pkg;

 

/
