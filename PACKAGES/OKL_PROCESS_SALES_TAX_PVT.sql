--------------------------------------------------------
--  DDL for Package OKL_PROCESS_SALES_TAX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PROCESS_SALES_TAX_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRPSTS.pls 120.11 2007/08/27 22:36:55 rravikir ship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP				CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN	CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN	CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_NO_PARENT_RECORD    CONSTANT VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR    CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN       CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN       CONSTANT VARCHAR2(200) := 'SQLcode';

  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_ESTIMATED_CALL_TYPE		CONSTANT VARCHAR2(120) := 'ESTIMATED';
  G_ACTUAL_CALL_TYPE		CONSTANT VARCHAR2(120) := 'ACTUAL';

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_PROCESS_SALES_TAX_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

  G_USER_ID             NUMBER       := FND_GLOBAL.USER_ID;
  G_LOGIN_ID			NUMBER       := FND_GLOBAL.LOGIN_ID;

  G_EVENT_CLASS_CODE	CONSTANT VARCHAR2(30) := 'SALES_TRANSACTION_TAX_QUOTE';
  G_TRX_LEVEL_TYPE		CONSTANT VARCHAR2(30) := 'LINE';

  G_ACTIVE_STATUS		CONSTANT VARCHAR2(30) := 'ACTIVE';
  G_INACTIVE_STATUS		CONSTANT VARCHAR2(30) := 'INACTIVE';
  G_CANCELLED_STATUS    CONSTANT VARCHAR2(30) := 'CANCELLED';

  G_UPFRONT_TAX			 CONSTANT VARCHAR2(30) := 'UPFRONT_TAX';
  G_INVOICE_TAX			 CONSTANT VARCHAR2(30) := 'INVOICE_TAX';
  G_TAX_SCHEDULE		 CONSTANT VARCHAR2(30) := 'TAX_SCHEDULE';

  G_OKL_APPLICATION_ID                 CONSTANT NUMBER := 540;
  G_UPDATE_LINE_LEVEL_ACTION           CONSTANT VARCHAR2(30) := 'UPDATE';
  G_CREATE_LINE_LEVEL_ACTION           CONSTANT VARCHAR2(30) := 'CREATE';

  G_BOOK_UPD_EVENT_CODE                CONSTANT VARCHAR2(30) := 'BOOKING_UPDATE';
  G_BOOKING_CRE_EVT_TYPE_CODE          CONSTANT VARCHAR2(30) := 'BOOKING_CREATE';
  G_BOOK_OVERRIDE_EVENT                CONSTANT VARCHAR2(30) := 'BOOKING_OVERRIDE_TAX';
  G_BOOK_DEL_EVENT_CODE                CONSTANT VARCHAR2(30) := 'BOOKING_DELETE';
  G_BOOKING_CANCEL                     CONSTANT VARCHAR2(30) := 'BOOKING_CANCEL';

  G_REBOOK_UPD_EVENT_CODE              CONSTANT VARCHAR2(30) := 'REBOOK_UPDATE';
  G_REBOOK_OVERRIDE_EVENT              CONSTANT VARCHAR2(30) := 'REBOOK_OVERRIDE_TAX';
  G_REBOOK_CRE_EVT_TYPE_CODE           CONSTANT VARCHAR2(30) := 'REBOOK_CREATE';
  G_REBOOK_DEL_EVENT_CODE              CONSTANT VARCHAR2(30) := 'REBOOK_DELETE';
  G_REBOOK_CANCEL                      CONSTANT VARCHAR2(30) := 'REBOOK_CANCEL';

  G_AM_QTE_CRE_EVT_TYPE_CODE           CONSTANT VARCHAR2(30) := 'ESTIMATED_BILLING_CREATE';

  G_ALC_EVENT_CODE                     CONSTANT VARCHAR2(30) := 'ASSET_RELOCATION';
  G_ALC_CRE_EVENT_CODE                 CONSTANT VARCHAR2(30) := 'ASSET_RELOCATION_CREATE';
  G_ALC_UPD_EVENT_CODE                 CONSTANT VARCHAR2(30) := 'ASSET_RELOCATION_UPDATE';
  G_ALC_DEL_EVENT_CODE                 CONSTANT VARCHAR2(30) := 'ASSET_RELOCATION_DELETE';
  G_ALC_OVERRIDE_EVENT                 CONSTANT VARCHAR2(30) := 'ASSET_RELOCATION_OVERRIDE_TAX';

  G_OVERRIDE_LEVEL                     CONSTANT VARCHAR2(30) := 'DETAIL_OVERRIDE';

  G_ASSETS_ENTITY_CODE                 CONSTANT VARCHAR2(30) := 'ASSETS';
  G_CONTRACTS_ENTITY_CODE              CONSTANT VARCHAR2(30) := 'CONTRACTS';
  G_AM_QUOTES_ENTITY_CODE              CONSTANT VARCHAR2(30) := 'AM_QUOTES';

  G_TAX_SCH_ENTITY_CODE                CONSTANT VARCHAR2(30) := 'TAX_SCHEDULE_REQUESTS';
  G_TAX_SCH_CRE_EVT_TYPE_CODE          CONSTANT VARCHAR2(30) := 'TAX_SCHEDULE_CREATE';

  G_BOOKING_EVENT_CLASS_CODE           CONSTANT VARCHAR2(30) := 'BOOKING';
  G_REBOOK_EVENT_CLASS_CODE            CONSTANT VARCHAR2(30) := 'REBOOK';
  G_AM_QTE_EVENT_CLASS_CODE            CONSTANT VARCHAR2(30) := 'ESTIMATED_BILLING';

  G_SQ_ENTITY_CODE                     CONSTANT VARCHAR2(30) := 'SALES_QUOTES';
  G_SQ_EVENT_CLASS_CODE                CONSTANT VARCHAR2(30) := 'SALES_QUOTE';
  G_SQ_CRE_EVT_TYPE_CODE               CONSTANT VARCHAR2(30) := 'SALES_QUOTE_CREATE';

  G_SERVICES                           CONSTANT VARCHAR2(30) := 'SERVICES';
  G_GOODS                              CONSTANT VARCHAR2(30) := 'GOODS';
  G_DEFAULT_PRODUCT_TYPE               CONSTANT VARCHAR2(30) := 'SERVICES';

  G_AR_APPLICATION_ID                  CONSTANT NUMBER := 222;
  G_AR_ENTITY_CODE                     CONSTANT VARCHAR2(30) := 'TRANSACTIONS';
  G_INVOICE_EVENT_CLASS_CODE           CONSTANT VARCHAR2(30) := 'INVOICE';
  G_CRE_MEM_EVENT_CLASS_CODE           CONSTANT VARCHAR2(30) := 'CREDIT_MEMO';

  G_AP_APPLICATION_ID                  CONSTANT NUMBER := 200;
  G_AP_ENTITY_CODE                     CONSTANT VARCHAR2(30) := 'AP_INVOICES';
  G_AP_EVENT_CLASS_CODE                CONSTANT VARCHAR2(30) := 'STANDARD INVOICES';

  ---------------------------------------------------------------------------
  -- GLOBAL PROCESSING VARIABLES
  ---------------------------------------------------------------------------
  G_UFC_CODE                           VARCHAR2(240);
  G_TBC_CODE                           VARCHAR2(240);
  G_PC_CODE                            VARCHAR2(240);
  G_TAX_CLASS_CODE                     VARCHAR2(50);

  ---------------------------------------------------------------------------
  -- GLOBAL DEBUG VARIABLES
  ---------------------------------------------------------------------------
  G_DEBUG_LEVEL_PROCEDURE     		CONSTANT	NUMBER  := FND_LOG.LEVEL_PROCEDURE;
  G_DEBUG_CURRENT_RUNTIME_LEVEL		CONSTANT 	NUMBER  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_DEBUG_LEVEL_STATEMENT			CONSTANT	NUMBER  := FND_LOG.LEVEL_STATEMENT;
  G_DEBUG_LEVEL_EXCEPTION			CONSTANT	NUMBER  := FND_LOG.LEVEL_EXCEPTION;
  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_INSURANCE_ERROR EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  SUBTYPE txsv_rec_type IS OKL_TAX_SOURCES_PUB.txsv_rec_type;
  SUBTYPE txsv_tbl_type IS OKL_TAX_SOURCES_PUB.txsv_tbl_type;
  SUBTYPE transaction_rec_type IS ZX_API_PUB.transaction_rec_type;
  SUBTYPE legal_entity_rec_type IS XLE_UTILITIES_GRP.LegalEntity_Rec;
  SUBTYPE zx_trx_lines_tbl_type IS OKL_TAX_INTERFACE_PVT.zx_trx_lines_tbl_type;
  SUBTYPE tax_src_params_rec_type IS OKL_TAX_SOURCES%ROWTYPE;
  SUBTYPE line_params_tbl_type  IS OKL_TAX_INTERFACE_PVT.line_params_tbl_type;
  TYPE tax_sources_tbl_type IS TABLE OF OKL_TAX_SOURCES%ROWTYPE INDEX BY BINARY_INTEGER;
  SUBTYPE hdr_params_rec_type IS OKL_TAX_INTERFACE_PVT.hdr_params_rec_type;
  SUBTYPE line_params_rec_type IS OKL_TAX_INTERFACE_PVT.line_params_rec_type;
  TYPE tax_lines_tbl_type IS TABLE OF OKL_TAX_TRX_DETAILS%ROWTYPE INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  -- LOCAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE prev_tx_src_rec_type IS RECORD
  ( id                              NUMBER,
    org_id                          NUMBER,
    application_id                  NUMBER,
    entity_code                     VARCHAR2(30),
    event_class_code                VARCHAR2(30));

  TYPE sty_id_rec_type IS RECORD(
           sty_id    		NUMBER,
           sty_code  		VARCHAR2(150),
           sty_purpose		VARCHAR2(80));

  TYPE tax_det_rec_type IS RECORD(
           x_tax_code                   VARCHAR2(50), -- 'TAX_CLASSIFICATION_CODE' in AP interface  and 'TAX_CODE' of AR Interface
           x_trx_business_category      VARCHAR2(240),
           x_product_category           VARCHAR2(240),
           x_product_type               VARCHAR2(240),
           x_line_intended_use          VARCHAR2(240),
           x_user_defined_fisc_class    VARCHAR2(240),
           x_assessable_value           NUMBER,
           x_default_taxation_country   VARCHAR2(2),
           x_upstream_trx_reported_flag VARCHAR2(1));

  TYPE tax_codes_rec_type IS RECORD (
	   khr_id                  NUMBER,
	   kle_id                  NUMBER,
	   sty_id                  NUMBER,
	   tbc_code                VARCHAR2(240),
       pc_code                 VARCHAR2(240),
       ufc_code                VARCHAR2(240),
       tax_class_code          VARCHAR2(240));

  TYPE tax_codes_tbl_type IS TABLE OF tax_codes_rec_type INDEX BY BINARY_INTEGER;
  TYPE sty_id_tbl_type IS TABLE OF sty_id_rec_type INDEX BY BINARY_INTEGER;
  TYPE prev_tx_src_tbl_type IS TABLE OF prev_tx_src_rec_type INDEX BY BINARY_INTEGER;

  TYPE asset_level_det_rec_type IS RECORD
	(fin_asset_id					NUMBER,
	 asset_number					VARCHAR2(150),
	 transfer_of_title				VARCHAR2(30),
	 sale_lease_back				VARCHAR2(30),
	 purchase_of_lease				VARCHAR2(30),
	 usage_of_equipment				VARCHAR2(30),
	 vendor_site_id					NUMBER,
	 age_of_equipment				NUMBER,
	 inv_item_id					NUMBER,
	 inv_org_id						NUMBER,
	 ship_to_site_use_id			NUMBER,
	 asset_pymnt_exist				VARCHAR2(1),
     bill_to_party_site_id          NUMBER,
     bill_to_location_id            NUMBER,
     bill_to_party_id	            NUMBER,
     bill_to_site_use_id            NUMBER,
     ship_to_party_site_id          NUMBER,
     ship_to_location_id            NUMBER,
     ship_to_party_id               NUMBER,
     sty_id                         NUMBER,
     amount                         NUMBER,
     try_id                         NUMBER,
     trx_line_id                    NUMBER	);
  TYPE asset_level_det_tbl_type IS TABLE OF asset_level_det_rec_type INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  -- PROCEDURES
  ---------------------------------------------------------------------------
  PROCEDURE calculate_sales_tax(
    p_api_version                  	IN  NUMBER,
    p_init_msg_list                	IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_source_trx_id				 	IN  NUMBER,
    p_source_trx_name               IN  VARCHAR2,
    p_source_table                  IN  VARCHAR2,
    p_tax_call_type                 IN  VARCHAR2 DEFAULT NULL,
    p_serialized_asset              IN  VARCHAR2 DEFAULT NULL,
    p_request_id                    IN  NUMBER   DEFAULT NULL,
    p_alc_final_call                IN  VARCHAR2 DEFAULT NULL);

  PROCEDURE get_billing_stream_types(
    p_api_version                  	IN  NUMBER,
    p_init_msg_list                	IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_org_id						IN  NUMBER,
    p_sty_code						IN  VARCHAR2,
	x_sty_id_tbl					OUT NOCOPY sty_id_tbl_type);

  PROCEDURE set_tax_security_context(
    p_api_version                  	IN  NUMBER,
    p_init_msg_list                	IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_internal_org_id			 	IN  NUMBER,
    p_legal_entity_id               IN  NUMBER,
    p_transaction_date              IN  DATE);

  PROCEDURE process_tax_determ_override(
    p_api_version                  	IN  NUMBER,
    p_init_msg_list                	IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_trx_id                        IN  NUMBER,
    p_tax_sources_id                IN  NUMBER,
    p_trx_business_category         IN  VARCHAR2,
    p_product_category			 	IN  VARCHAR2,
    p_user_defined_fisc_class       IN  VARCHAR2,
    p_line_intended_use             IN  VARCHAR2,
    p_request_id                    IN  NUMBER DEFAULT NULL,
    p_asset_id                      IN  NUMBER DEFAULT NULL);

  PROCEDURE process_tax_details_override(
    p_api_version                  	IN  NUMBER,
    p_init_msg_list                	IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_event_id                      IN  NUMBER,
    p_internal_organization_id      IN  NUMBER,
    p_trx_id                        IN  NUMBER,
    p_application_id                IN  NUMBER,
    p_entity_code			 	    IN  VARCHAR2,
    p_event_class_code              IN  VARCHAR2);

  PROCEDURE get_tax_determinants(
    p_api_version                  	IN  NUMBER,
    p_init_msg_list                	IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_source_trx_id                 IN  NUMBER,
    p_source_trx_name               IN  VARCHAR2,
    p_source_table                  IN  VARCHAR2,
    x_tax_det_rec                   OUT NOCOPY tax_det_rec_type);

  PROCEDURE get_location_party_ids(
	p_api_version                 	IN  NUMBER,
    p_init_msg_list                	IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_cust_acct_id                  IN  NUMBER,
    p_fin_asset_id                  IN  NUMBER,
    p_khr_id                        IN  NUMBER,
    x_bill_to_party_site_id         OUT NOCOPY NUMBER,
    x_bill_to_location_id           OUT NOCOPY NUMBER,
    x_bill_to_party_id	            OUT NOCOPY NUMBER,
    x_bill_to_site_use_id			OUT NOCOPY NUMBER,
    x_ship_to_party_site_id         OUT NOCOPY NUMBER,
    x_ship_to_location_id           OUT NOCOPY NUMBER,
    x_ship_to_party_id              OUT NOCOPY NUMBER,
    x_ship_to_site_use_id			OUT NOCOPY NUMBER);

  PROCEDURE cancel_document_tax (
    p_api_version                   IN NUMBER,
    p_init_msg_list                 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                 OUT NOCOPY VARCHAR2,
    x_msg_count                     OUT NOCOPY NUMBER,
    x_msg_data                      OUT NOCOPY VARCHAR2,
    p_source_trx_id                 IN  NUMBER, -->  ID of Pre-Rebook or of Rebook transaction in okl_trx_contracts
    p_source_trx_name               IN  VARCHAR2, -->  Pre-Rebook or Rebook
    p_source_table                  IN  VARCHAR2);

  PROCEDURE copy_global_tax_data (
    p_api_version                   IN NUMBER,
    p_init_msg_list                 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                 OUT NOCOPY VARCHAR2,
    x_msg_count                     OUT NOCOPY NUMBER,
    x_msg_data                      OUT NOCOPY VARCHAR2,
    p_trx_id                        IN  NUMBER,
    p_trx_line_id                   IN  NUMBER,
    p_application_id                IN  NUMBER,
    p_trx_level_type		 	    IN  VARCHAR2,
    p_entity_code			 	    IN  VARCHAR2,
    p_event_class_code              IN  VARCHAR2);

  FUNCTION get_default_taxation_country(x_return_status     OUT NOCOPY VARCHAR2,
                                        x_msg_count         OUT NOCOPY NUMBER,
                                        x_msg_data          OUT NOCOPY VARCHAR2,
                                        p_legal_entity_id   IN NUMBER)
  RETURN VARCHAR2;

  FUNCTION get_line_intended_use_name(p_intend_use_code   IN VARCHAR2)
  RETURN VARCHAR2;

  FUNCTION is_serialized_and_alc(p_contract_id   IN NUMBER)
  RETURN VARCHAR2;

END OKL_PROCESS_SALES_TAX_PVT;

/
