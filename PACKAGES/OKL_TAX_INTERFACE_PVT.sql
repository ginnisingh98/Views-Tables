--------------------------------------------------------
--  DDL for Package OKL_TAX_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TAX_INTERFACE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRTEIS.pls 120.7 2007/07/31 22:25:30 rravikir noship $ */
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
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_TAX_INTERFACE_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

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
  SUBTYPE transaction_rec_type IS ZX_API_PUB.transaction_rec_type;
  TYPE zx_trx_lines_tbl_type IS TABLE OF ZX_REVERSE_TRX_LINES_GT%ROWTYPE INDEX BY BINARY_INTEGER;

  TYPE hdr_params_rec_type IS RECORD
  ( application_id                  NUMBER,
    trx_id                          NUMBER,
    internal_organization_id        NUMBER,
    entity_code                     VARCHAR2(30),
    event_class_code                VARCHAR2(30),
    event_type_code                 VARCHAR2(30),
    quote_flag                      VARCHAR2(1));

  TYPE line_params_rec_type  IS RECORD
  ( application_id                    NUMBER,
    trx_id                            NUMBER,
    internal_organization_id          NUMBER,
    entity_code                       VARCHAR2(30),
    event_class_code                  VARCHAR2(30),
    event_type_code                   VARCHAR2(30), --check
    trx_date                          DATE,
    ledger_id                         NUMBER,
    legal_entity_id                   NUMBER,
    trx_level_type                    VARCHAR2(30),
    line_level_action                 VARCHAR2(30),  --check
    trx_line_id                       NUMBER,
    line_amt                          NUMBER,
    tax_reporting_flag                VARCHAR2(1),
    default_taxation_country          VARCHAR2(2),
    product_type                      VARCHAR2(240),
    output_tax_classification_code    VARCHAR2(50),
    assessable_value                  NUMBER,
    receivables_trx_type_id           NUMBER,
    product_id                        NUMBER,
    adjusted_doc_entity_code          VARCHAR2(30),
    adjusted_doc_event_class_code     VARCHAR2(30),
    adjusted_doc_trx_id               NUMBER,
    adjusted_doc_line_id              NUMBER,
    adjusted_doc_trx_level_type       VARCHAR2(30),
    adjusted_doc_number               VARCHAR2(150),
    adjusted_doc_date                 DATE,
    line_amt_includes_tax_flag        VARCHAR2(1),
    trx_business_category             VARCHAR2(240),
    product_category                  VARCHAR2(240),
    user_defined_fisc_class           VARCHAR2(240),
    line_intended_use                 VARCHAR2(240),
    ship_to_cust_acct_site_use_id     NUMBER,
    bill_to_cust_acct_site_use_id     NUMBER,
    bill_to_party_site_id             NUMBER,
    bill_to_location_id               NUMBER,
    bill_to_party_id                  NUMBER,
    ship_to_party_site_id             NUMBER,
    ship_to_location_id               NUMBER,
    ship_to_party_id                  NUMBER,
    rounding_ship_to_party_id         NUMBER,
    rounding_bill_to_party_id         NUMBER,
    trx_currency_code                 VARCHAR2(15),
    precision                         NUMBER,
    minimum_accountable_unit          NUMBER,
    currency_conversion_date          DATE,
    currency_conversion_rate          NUMBER,
    currency_conversion_type	      VARCHAR2(30),
    provnl_tax_determination_date     DATE,
    ctrl_total_hdr_tax_amt            NUMBER);

  TYPE line_params_tbl_type IS TABLE OF line_params_rec_type INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  -- GLOBAL DATA
  ---------------------------------------------------------------------------
  G_USER_ID             NUMBER       := FND_GLOBAL.USER_ID;
  G_LOGIN_ID			NUMBER       := FND_GLOBAL.LOGIN_ID;
  ---------------------------------------------------------------------------
  -- PROCEDURES
  ---------------------------------------------------------------------------

  PROCEDURE calculate_tax(
    p_api_version                  	IN  NUMBER,
    p_init_msg_list                	IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_hdr_params_rec                IN  hdr_params_rec_type,
    p_line_params_tbl				IN  line_params_tbl_type);

  PROCEDURE mark_reporting_flag(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_trx_id              IN  NUMBER,
    p_application_id      IN  NUMBER,
    p_entity_code         IN  VARCHAR2,
    p_event_class_code    IN  VARCHAR2);

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
    p_api_version                   IN  NUMBER,
    p_init_msg_list                 IN  VARCHAR2,
    x_return_status                 OUT NOCOPY VARCHAR2 ,
    x_msg_count                     OUT NOCOPY NUMBER ,
    x_msg_data                      OUT NOCOPY VARCHAR2,
    p_trx_id                        IN  NUMBER,
    p_tax_sources_id                IN  NUMBER,
    p_trx_business_category         IN  VARCHAR2,
    p_product_category			 	IN  VARCHAR2,
    p_user_defined_fisc_class       IN  VARCHAR2,
    p_line_intended_use             IN  VARCHAR2,
    p_transaction_rec               IN  transaction_rec_type,
    x_doc_level_recalc_flag         OUT NOCOPY VARCHAR2) ;

  PROCEDURE process_tax_details_override(
    p_api_version           IN         NUMBER,
    p_init_msg_list         IN         VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2 ,
    x_msg_count             OUT NOCOPY NUMBER ,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_transaction_rec       IN         transaction_rec_type,
    p_override_level        IN         VARCHAR2,
    p_event_id              IN         NUMBER) ;

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

  PROCEDURE update_document (
    p_api_version                   IN NUMBER,
    p_init_msg_list                 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                 OUT NOCOPY VARCHAR2,
    x_msg_count                     OUT NOCOPY NUMBER,
    x_msg_data                      OUT NOCOPY VARCHAR2,
    p_transaction_rec               transaction_rec_type);

  PROCEDURE reverse_document (
    p_api_version                   IN NUMBER,
    p_init_msg_list                 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                 OUT NOCOPY VARCHAR2,
    x_msg_count                     OUT NOCOPY NUMBER,
    x_msg_data                      OUT NOCOPY VARCHAR2,
    p_rev_trx_hdr_rec               IN  line_params_rec_type,
    p_rev_trx_lines_tbl             IN  zx_trx_lines_tbl_type);

  PROCEDURE get_tax_classification_code (
    x_return_status                 OUT NOCOPY VARCHAR2,
    p_ship_to_site_use_id           IN  NUMBER,
    p_bill_to_site_use_id           IN  NUMBER,
    p_inventory_item_id             IN  NUMBER,
    p_organization_id               IN  NUMBER,
    p_set_of_books_id               IN  NUMBER,
    p_trx_date                      IN  DATE,
    p_trx_type_id                   IN  NUMBER,
    p_entity_code                   IN  VARCHAR2,
    p_event_class_code              IN  VARCHAR2,
    p_application_id                IN  NUMBER,
    p_internal_organization_id      IN  NUMBER,
    p_vendor_id                     IN  NUMBER DEFAULT NULL,
    p_vendor_site_id                IN  NUMBER DEFAULT NULL,
    x_tax_classification_code       OUT NOCOPY VARCHAR2 );

END OKL_TAX_INTERFACE_PVT;

/
