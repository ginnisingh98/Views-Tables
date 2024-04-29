--------------------------------------------------------
--  DDL for Package AR_INVOICE_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_INVOICE_API_PUB" AUTHID CURRENT_USER AS
/* $Header: ARXPINVS.pls 120.25.12010000.5 2010/01/28 09:50:09 aghoraka ship $ */
 /*#
 * Invoice Creation API allows users to create an invoice using simple
 * calls to PL/SQL functions. Invoices can be created either in batch
 * mode with multiple invoices or a single invoice.
 * The Invoice Creation API is not intended to replace the existing
 * Transaction workbench, AutoInvoice, or the Transaction API program.
 * @rep:scope public
 * @rep:metalink 236938.1 See OracleMetaLink note 236938.1
 * @rep:product AR
 * @rep:lifecycle active
 * @rep:displayname Invoice Creation
 * @rep:category BUSINESS_ENTITY AR_INVOICE
 */

TYPE trx_header_rec_type IS RECORD (
            trx_header_id                   NUMBER,
            trx_number                      VARCHAR2(20)    DEFAULT NULL,
            trx_date                        DATE            DEFAULT NULL,
            trx_currency                    VARCHAR2(30)    DEFAULT NULL,
            reference_number                VARCHAR2(30)    DEFAULT NULL,
            trx_class                       VARCHAR2(20)    DEFAULT 'INV',
            cust_trx_type_id                NUMBER          DEFAULT NULL,
	    gl_date			    DATE	    DEFAULT NULL,
            bill_to_customer_id             NUMBER          DEFAULT NULL,
            bill_to_account_number          VARCHAR2(30)    DEFAULT NULL,
            bill_to_customer_name           VARCHAR2(260)   DEFAULT NULL,
            -- bill_to_location_id              NUMBER          DEFAULT NULL,
            bill_to_contact_id              NUMBER          DEFAULT NULL,
            bill_to_address_id              NUMBER          DEFAULT NULL,
            bill_to_site_use_id             NUMBER          DEFAULT NULL,
            ship_to_customer_id             NUMBER          DEFAULT NULL,
            ship_to_account_number          VARCHAR2(30)    DEFAULT NULL,
            ship_to_customer_name           VARCHAR2(260)   DEFAULT NULL,
            -- ship_to_location_id              NUMBER          DEFAULT NULL,
            ship_to_contact_id              NUMBER          DEFAULT NULL,
            ship_to_address_id              NUMBER          DEFAULT NULL,
            ship_to_site_use_id             NUMBER          DEFAULT NULL,
            sold_to_customer_id             NUMBER          DEFAULT NULL,
            -- sold_to_site_use_id              NUMBER          DEFAULT NULL,
            -- sold_to_contact_id               NUMBER          DEFAULT NULL,
            term_id                         NUMBER          DEFAULT NULL,
            primary_salesrep_id             NUMBER          DEFAULT NULL,
            primary_salesrep_name           VARCHAR2(240)   DEFAULT NULL,
            exchange_rate_type              VARCHAR2(60)    DEFAULT NULL,
            exchange_date                   DATE    	    DEFAULT NULL,
            exchange_rate                   NUMBER          DEFAULT NULL,
            territory_id                    NUMBER          DEFAULT NULL,
            remit_to_address_id             NUMBER          DEFAULT NULL,
            invoicing_rule_id               NUMBER          DEFAULT NULL,
            -- shipment_id	                NUMBER          DEFAULT NULL,
            printing_option	            VARCHAR2(20)    DEFAULT NULL,
	    -- printing_count	                NUMBER          DEFAULT NULL,
            purchase_order	            VARCHAR2(50)    DEFAULT NULL,
	    purchase_order_revision	    VARCHAR2(50)    DEFAULT NULL,
	    purchase_order_date	            DATE            DEFAULT NULL,
	    -- customer_reference               VARCHAR2(30)    DEFAULT NULL,
	    -- customer_reference_date          DATE            DEFAULT NULL,
	    comments	                    VARCHAR2(1760)   DEFAULT NULL, -- Bug 7484119
	    internal_notes	            VARCHAR2(240)   DEFAULT NULL,
            finance_charges	            VARCHAR2(1)     DEFAULT NULL,
	    -- credit_method_for_rules	        VARCHAR2(30)    DEFAULT NULL,
	    -- credit_method_for_installments   VARCHAR2(30)    DEFAULT NULL,
	    receipt_method_id	            NUMBER          DEFAULT NULL,
            related_customer_trx_id         NUMBER          DEFAULT NULL,
            agreement_id                    NUMBER          DEFAULT NULL,
	    ship_via	                    VARCHAR2(30)    DEFAULT NULL,
	    ship_date_actual	            DATE            DEFAULT NULL,
	    waybill_number	            VARCHAR2(50)    DEFAULT NULL,
	    fob_point	                    VARCHAR2(30)    DEFAULT NULL,
	    customer_bank_account_id	    NUMBER          DEFAULT NULL,
	    -- default_ussgl_trx_code_context	VARCHAR2(30)    DEFAULT NULL,
	    default_ussgl_transaction_code  VARCHAR2(30)    DEFAULT NULL,
	    -- recurred_from_trx_number	        VARCHAR2(20)    DEFAULT NULL,
            status_trx	                    VARCHAR2(30)    DEFAULT NULL,
	    paying_customer_id	            NUMBER          DEFAULT NULL,
	    paying_site_use_id	            NUMBER          DEFAULT NULL,
	    default_tax_exempt_flag	    VARCHAR2(1)     DEFAULT NULL,
            -- mrc_exchange_rate_type	        VARCHAR2(2000)  DEFAULT NULL,
            -- mrc_exchange_date	        VARCHAR2(2000)  DEFAULT NULL,
            -- mrc_exchange_rate	        VARCHAR2(2000)  DEFAULT NULL,
            -- doc_sequence_id                  NUMBER(15)      DEFAULT NULL,
            doc_sequence_value              NUMBER(15)      DEFAULT NULL,
            attribute_category              VARCHAR2(30)    DEFAULT NULL,
            attribute1                      VARCHAR2(150)   DEFAULT NULL,
            attribute2                      VARCHAR2(150)   DEFAULT NULL,
            attribute3                      VARCHAR2(150)   DEFAULT NULL,
            attribute4                      VARCHAR2(150)   DEFAULT NULL,
            attribute5                      VARCHAR2(150)   DEFAULT NULL,
            attribute6                      VARCHAR2(150)   DEFAULT NULL,
            attribute7                      VARCHAR2(150)   DEFAULT NULL,
            attribute8                      VARCHAR2(150)   DEFAULT NULL,
            attribute9                      VARCHAR2(150)   DEFAULT NULL,
            attribute10                     VARCHAR2(150)   DEFAULT NULL,
            attribute11                     VARCHAR2(150)   DEFAULT NULL,
            attribute12                     VARCHAR2(150)   DEFAULT NULL,
            attribute13                     VARCHAR2(150)   DEFAULT NULL,
            attribute14                     VARCHAR2(150)   DEFAULT NULL,
            attribute15                     VARCHAR2(150)   DEFAULT NULL,
            global_attribute_category       VARCHAR2(30)    DEFAULT NULL,
            global_attribute1               VARCHAR2(150)   DEFAULT NULL,
            global_attribute2               VARCHAR2(150)   DEFAULT NULL,
            global_attribute3               VARCHAR2(150)   DEFAULT NULL,
            global_attribute4               VARCHAR2(150)   DEFAULT NULL,
            global_attribute5               VARCHAR2(150)   DEFAULT NULL,
            global_attribute6               VARCHAR2(150)   DEFAULT NULL,
            global_attribute7               VARCHAR2(150)   DEFAULT NULL,
            global_attribute8               VARCHAR2(150)   DEFAULT NULL,
            global_attribute9               VARCHAR2(150)   DEFAULT NULL,
            global_attribute10              VARCHAR2(150)   DEFAULT NULL,
            global_attribute11              VARCHAR2(150)   DEFAULT NULL,
            global_attribute12              VARCHAR2(150)   DEFAULT NULL,
            global_attribute13              VARCHAR2(150)   DEFAULT NULL,
            global_attribute14              VARCHAR2(150)   DEFAULT NULL,
            global_attribute15              VARCHAR2(150)   DEFAULT NULL,
            global_attribute16              VARCHAR2(150)   DEFAULT NULL,
            global_attribute17              VARCHAR2(150)   DEFAULT NULL,
            global_attribute18              VARCHAR2(150)   DEFAULT NULL,
            global_attribute19              VARCHAR2(150)   DEFAULT NULL,
            global_attribute20              VARCHAR2(150)   DEFAULT NULL,
            global_attribute21              VARCHAR2(150)   DEFAULT NULL,
            global_attribute22              VARCHAR2(150)   DEFAULT NULL,
            global_attribute23              VARCHAR2(150)   DEFAULT NULL,
            global_attribute24              VARCHAR2(150)   DEFAULT NULL,
            global_attribute25              VARCHAR2(150)   DEFAULT NULL,
            global_attribute26              VARCHAR2(150)   DEFAULT NULL,
            global_attribute27              VARCHAR2(150)   DEFAULT NULL,
            global_attribute28              VARCHAR2(150)   DEFAULT NULL,
            global_attribute29              VARCHAR2(150)   DEFAULT NULL,
            global_attribute30              VARCHAR2(150)   DEFAULT NULL,
            interface_header_context        VARCHAR2(30)    DEFAULT NULL,
            interface_header_attribute1     VARCHAR2(150)   DEFAULT NULL,
            interface_header_attribute2     VARCHAR2(150)   DEFAULT NULL,
            interface_header_attribute3     VARCHAR2(150)   DEFAULT NULL,
            interface_header_attribute4     VARCHAR2(150)   DEFAULT NULL,
            interface_header_attribute5     VARCHAR2(150)   DEFAULT NULL,
            interface_header_attribute6     VARCHAR2(150)   DEFAULT NULL,
            interface_header_attribute7     VARCHAR2(150)   DEFAULT NULL,
            interface_header_attribute8     VARCHAR2(150)   DEFAULT NULL,
            interface_header_attribute9     VARCHAR2(150)   DEFAULT NULL,
            interface_header_attribute10    VARCHAR2(150)   DEFAULT NULL,
            interface_header_attribute11    VARCHAR2(150)   DEFAULT NULL,
            interface_header_attribute12    VARCHAR2(150)   DEFAULT NULL,
            interface_header_attribute13    VARCHAR2(150)   DEFAULT NULL,
            interface_header_attribute14    VARCHAR2(150)   DEFAULT NULL,
            interface_header_attribute15    VARCHAR2(150)   DEFAULT NULL,
            org_id                          NUMBER          DEFAULT NULL,
            legal_entity_id                 NUMBER          DEFAULT NULL,
            payment_trxn_extension_id       NUMBER          DEFAULT NULL,
            billing_date                    DATE            DEFAULT NULL,
            --Late Charges
            interest_header_id      NUMBER      DEFAULT NULL,
            late_charges_assessed   VARCHAR2(1) DEFAULT NULL,
            document_sub_type       VARCHAR2(240)   DEFAULT NULL,
            default_taxation_country   VARCHAR2(2)     DEFAULT NULL,
	    mandate_last_trx_flag	VARCHAR2(1)
			 );

TYPE trx_header_tbl_type IS TABLE OF trx_header_rec_type
	INDEX BY BINARY_INTEGER;

G_PKG_NAME     CONSTANT VARCHAR2(30) := 'AR_INVOICE_API_PUB';

TYPE trx_salescredits_rec_type  IS RECORD (
       	TRX_salescredit_ID                 NUMBER               ,
        TRX_LINE_ID                        NUMBER               ,
        SALESREP_ID	                       NUMBER               DEFAULT NULL,
        SALESREP_NUMBER	                   VARCHAR2(30)         DEFAULT NULL,
        SALES_CREDIT_TYPE_NAME	           VARCHAR2(30)	        DEFAULT NULL,
        SALES_CREDIT_TYPE_ID	           NUMBER(15)           DEFAULT NULL,
        --REVENUE_AMOUNT_SPLIT	           NUMBER               DEFAULT NULL,
        --REVENUE_PERCENT_SPLIT	           NUMBER               DEFAULT NULL,
        --NON_REVENUE_AMOUNT_SPLIT	   NUMBER               DEFAULT NULL,
        --NON_REVENUE_PERCENT_SPLIT	   NUMBER               DEFAULT NULL,
        -- REVENUE_ADJUSTMENT_ID           NUMBER               DEFAULT NULL,
        SALESCREDIT_AMOUNT_SPLIT	   NUMBER               DEFAULT NULL,
        SALESCREDIT_PERCENT_SPLIT	   NUMBER               DEFAULT NULL,
        ATTRIBUTE_CATEGORY	           VARCHAR2(30)         DEFAULT NULL,
        ATTRIBUTE1	                   VARCHAR2(150)        DEFAULT NULL,
        ATTRIBUTE2	                   VARCHAR2(150)        DEFAULT NULL,
        ATTRIBUTE3	                   VARCHAR2(150)        DEFAULT NULL,
        ATTRIBUTE4	                   VARCHAR2(150)        DEFAULT NULL,
        ATTRIBUTE5	                   VARCHAR2(150)        DEFAULT NULL,
        ATTRIBUTE6	                   VARCHAR2(150)        DEFAULT NULL,
        ATTRIBUTE7	                   VARCHAR2(150)        DEFAULT NULL,
        ATTRIBUTE8	                   VARCHAR2(150)        DEFAULT NULL,
        ATTRIBUTE9	                   VARCHAR2(150)        DEFAULT NULL,
        ATTRIBUTE10	                   VARCHAR2(150)        DEFAULT NULL,
        ATTRIBUTE11	                   VARCHAR2(150)        DEFAULT NULL,
        ATTRIBUTE12	                   VARCHAR2(150)        DEFAULT NULL,
        ATTRIBUTE13	                   VARCHAR2(150)        DEFAULT NULL,
        ATTRIBUTE14	                   VARCHAR2(150)        DEFAULT NULL,
        ATTRIBUTE15	                   VARCHAR2(150)        DEFAULT NULL);

TYPE trx_salescredits_tbl_type IS TABLE OF trx_salescredits_rec_type
	INDEX BY BINARY_INTEGER;


-- BEGIN
-- new data types introduced for "Payment Based Revenue Managment" project
-- ORASHID 20-September-2004

TYPE trx_contingencies_rec_type IS RECORD
(
  trx_contingency_id     NUMBER,
  trx_line_id            NUMBER,
  contingency_code       VARCHAR2(30),
  contingency_id         NUMBER,
  expiration_date        DATE          DEFAULT NULL,
  expiration_days        NUMBER        DEFAULT NULL,
  attribute_category	 VARCHAR2(30)  DEFAULT NULL,
  attribute1	         VARCHAR2(150) DEFAULT NULL,
  attribute2	         VARCHAR2(150) DEFAULT NULL,
  attribute3	         VARCHAR2(150) DEFAULT NULL,
  attribute4	         VARCHAR2(150) DEFAULT NULL,
  attribute5	         VARCHAR2(150) DEFAULT NULL,
  attribute6	         VARCHAR2(150) DEFAULT NULL,
  attribute7	         VARCHAR2(150) DEFAULT NULL,
  attribute8	         VARCHAR2(150) DEFAULT NULL,
  attribute9	         VARCHAR2(150) DEFAULT NULL,
  attribute10	         VARCHAR2(150) DEFAULT NULL,
  attribute11	         VARCHAR2(150) DEFAULT NULL,
  attribute12	         VARCHAR2(150) DEFAULT NULL,
  attribute13	         VARCHAR2(150) DEFAULT NULL,
  attribute14	         VARCHAR2(150) DEFAULT NULL,
  attribute15	         VARCHAR2(150) DEFAULT NULL,
  expiration_event_date  DATE          DEFAULT NULL,
  completed_flag         VARCHAR2(1)   DEFAULT 'N',
  completed_by           NUMBER        DEFAULT NULL
);

TYPE trx_contingencies_tbl_type IS TABLE OF trx_contingencies_rec_type
  INDEX BY BINARY_INTEGER;

-- END
-- ORASHID 20-September-2004


TYPE trx_line_rec_type  IS RECORD (
trx_header_id                   NUMBER,--required
trx_line_id                     NUMBER,--required
link_to_trx_line_id             NUMBER, --required if line type is TAX or freight
LINE_NUMBER	                    NUMBER, -- required
REASON_CODE	                    VARCHAR2(30)      DEFAULT NULL,
INVENTORY_ITEM_ID	            NUMBER            DEFAULT NULL,
DESCRIPTION	                    VARCHAR2(240)	  DEFAULT NULL,
QUANTITY_ORDERED	            NUMBER	          DEFAULT NULL,
-- QUANTITY_CREDITED	            NUMBER	          DEFAULT NULL,
QUANTITY_INVOICED	            NUMBER	          DEFAULT NULL,
UNIT_STANDARD_PRICE	            NUMBER	          DEFAULT NULL,
UNIT_SELLING_PRICE	            NUMBER	          DEFAULT NULL,
SALES_ORDER	                    VARCHAR2(50)	  DEFAULT NULL,
SALES_ORDER_LINE	            VARCHAR2(30)	  DEFAULT NULL,
SALES_ORDER_DATE	            DATE	          DEFAULT NULL,
ACCOUNTING_RULE_ID	            NUMBER      	  DEFAULT NULL,
LINE_TYPE	                    VARCHAR2(20),  -- required
ATTRIBUTE_CATEGORY	            VARCHAR2(30)	  DEFAULT NULL,
ATTRIBUTE1	                    VARCHAR2(150)	  DEFAULT NULL,
ATTRIBUTE2	                    VARCHAR2(150)	  DEFAULT NULL,
ATTRIBUTE3	                    VARCHAR2(150)	  DEFAULT NULL,
ATTRIBUTE4	                    VARCHAR2(150)	  DEFAULT NULL,
ATTRIBUTE5	                    VARCHAR2(150)	  DEFAULT NULL,
ATTRIBUTE6	                    VARCHAR2(150)	  DEFAULT NULL,
ATTRIBUTE7	                    VARCHAR2(150)	  DEFAULT NULL,
ATTRIBUTE8	                    VARCHAR2(150)	  DEFAULT NULL,
ATTRIBUTE9	                    VARCHAR2(150)	  DEFAULT NULL,
ATTRIBUTE10	                    VARCHAR2(150)	  DEFAULT NULL,
ATTRIBUTE11	                    VARCHAR2(150)	  DEFAULT NULL,
ATTRIBUTE12	                    VARCHAR2(150)	  DEFAULT NULL,
ATTRIBUTE13	                    VARCHAR2(150)	  DEFAULT NULL,
ATTRIBUTE14	                    VARCHAR2(150)	  DEFAULT NULL,
ATTRIBUTE15	                    VARCHAR2(150)	  DEFAULT NULL,
RULE_START_DATE	                DATE	          DEFAULT NULL,
INTERFACE_LINE_CONTEXT	        VARCHAR2(30)	  DEFAULT NULL,
INTERFACE_LINE_ATTRIBUTE1	     VARCHAR2(150)	  DEFAULT NULL,
INTERFACE_LINE_ATTRIBUTE2	     VARCHAR2(150)	  DEFAULT NULL,
INTERFACE_LINE_ATTRIBUTE3	     VARCHAR2(150)	  DEFAULT NULL,
INTERFACE_LINE_ATTRIBUTE4	     VARCHAR2(150)	  DEFAULT NULL,
INTERFACE_LINE_ATTRIBUTE5	     VARCHAR2(150)	  DEFAULT NULL,
INTERFACE_LINE_ATTRIBUTE6	     VARCHAR2(150)	  DEFAULT NULL,
INTERFACE_LINE_ATTRIBUTE7	     VARCHAR2(150)	  DEFAULT NULL,
INTERFACE_LINE_ATTRIBUTE8	     VARCHAR2(150)	  DEFAULT NULL,
INTERFACE_LINE_ATTRIBUTE9	     VARCHAR2(150)	  DEFAULT NULL,
INTERFACE_LINE_ATTRIBUTE10	    VARCHAR2(150)	  DEFAULT NULL,
INTERFACE_LINE_ATTRIBUTE11	    VARCHAR2(150)	  DEFAULT NULL,
INTERFACE_LINE_ATTRIBUTE12	    VARCHAR2(150)	  DEFAULT NULL,
INTERFACE_LINE_ATTRIBUTE13	    VARCHAR2(150)	  DEFAULT NULL,
INTERFACE_LINE_ATTRIBUTE14	    VARCHAR2(150)	  DEFAULT NULL,
INTERFACE_LINE_ATTRIBUTE15	    VARCHAR2(150)	  DEFAULT NULL,
--channel in the form
SALES_ORDER_SOURCE	            VARCHAR2(50)	  DEFAULT NULL,
AMOUNT	                NUMBER,	          -- required
-- REVENUE_AMOUNT	                NUMBER	          DEFAULT NULL,
-- AUTORULE_COMPLETE_FLAG	        VARCHAR2(1)	      DEFAULT NULL,
TAX_PRECEDENCE	                NUMBER	          DEFAULT NULL,
TAX_RATE	                    NUMBER	          DEFAULT NULL,
-- ITEM_EXCEPTION_RATE_ID	        NUMBER       	  DEFAULT NULL,
TAX_EXEMPTION_ID	            NUMBER            DEFAULT NULL,
MEMO_LINE_ID	                NUMBER            DEFAULT NULL,
-- AUTORULE_DURATION_PROCESSED	    NUMBER            DEFAULT NULL,
UOM_CODE	                    VARCHAR2(3)            DEFAULT NULL,
DEFAULT_USSGL_TRANSACTION_CODE	VARCHAR2(30)            DEFAULT NULL,
DEFAULT_USSGL_TRX_CODE_CONTEXT	VARCHAR2(30)            DEFAULT NULL,
VAT_TAX_ID	                    NUMBER(15,0)	   DEFAULT NULL,
-- AUTOTAX	                        VARCHAR2(1)	       DEFAULT NULL,
-- LAST_PERIOD_TO_CREDIT	        NUMBER	           DEFAULT NULL,
-- ITEM_CONTEXT	                VARCHAR2(30)	   DEFAULT NULL,
TAX_EXEMPT_FLAG	                VARCHAR2(1)	       DEFAULT NULL,
TAX_EXEMPT_NUMBER	            VARCHAR2(80)	   DEFAULT NULL,
TAX_EXEMPT_REASON_CODE	        VARCHAR2(30)	   DEFAULT NULL,
TAX_VENDOR_RETURN_CODE	        VARCHAR2(30)	   DEFAULT NULL,
-- LOCATION_SEGMENT_ID	            NUMBER             DEFAULT NULL,
MOVEMENT_ID	                    NUMBER             DEFAULT NULL,
GLOBAL_ATTRIBUTE1	            VARCHAR2(150)	   DEFAULT NULL,
GLOBAL_ATTRIBUTE2	            VARCHAR2(150)	   DEFAULT NULL,
GLOBAL_ATTRIBUTE3	            VARCHAR2(150)	   DEFAULT NULL,
GLOBAL_ATTRIBUTE4	            VARCHAR2(150)	   DEFAULT NULL,
GLOBAL_ATTRIBUTE5	            VARCHAR2(150)	   DEFAULT NULL,
GLOBAL_ATTRIBUTE6	            VARCHAR2(150)	   DEFAULT NULL,
GLOBAL_ATTRIBUTE7	            VARCHAR2(150)	   DEFAULT NULL,
GLOBAL_ATTRIBUTE8	            VARCHAR2(150)	   DEFAULT NULL,
GLOBAL_ATTRIBUTE9	            VARCHAR2(150)	   DEFAULT NULL,
GLOBAL_ATTRIBUTE10	            VARCHAR2(150)	   DEFAULT NULL,
GLOBAL_ATTRIBUTE11	            VARCHAR2(150)	   DEFAULT NULL,
GLOBAL_ATTRIBUTE12	            VARCHAR2(150)	   DEFAULT NULL,
GLOBAL_ATTRIBUTE13	            VARCHAR2(150)	   DEFAULT NULL,
GLOBAL_ATTRIBUTE14	            VARCHAR2(150)	   DEFAULT NULL,
GLOBAL_ATTRIBUTE15	            VARCHAR2(150)	   DEFAULT NULL,
GLOBAL_ATTRIBUTE16	            VARCHAR2(150)	   DEFAULT NULL,
GLOBAL_ATTRIBUTE17	            VARCHAR2(150)	   DEFAULT NULL,
GLOBAL_ATTRIBUTE18	            VARCHAR2(150)	   DEFAULT NULL,
GLOBAL_ATTRIBUTE19	            VARCHAR2(150)	   DEFAULT NULL,
GLOBAL_ATTRIBUTE20	            VARCHAR2(150)	   DEFAULT NULL,
GLOBAL_ATTRIBUTE_CATEGORY	    VARCHAR2(30)	   DEFAULT NULL,
-- GROSS_UNIT_SELLING_PRICE	    NUMBER	           DEFAULT NULL,
-- GROSS_EXTENDED_AMOUNT	        NUMBER	           DEFAULT NULL,
AMOUNT_INCLUDES_TAX_FLAG	    VARCHAR2(1)	       DEFAULT NULL,
-- TAXABLE_AMOUNT	                NUMBER	           DEFAULT NULL,
WAREHOUSE_ID	                NUMBER             DEFAULT NULL,
-- EXTENDED_ACCTD_AMOUNT	        NUMBER	           DEFAULT NULL,
CONTRACT_LINE_ID	            NUMBER	           DEFAULT NULL,
SOURCE_DATA_KEY1	            VARCHAR2(150)	   DEFAULT NULL,
SOURCE_DATA_KEY2	            VARCHAR2(150)	   DEFAULT NULL,
SOURCE_DATA_KEY3	            VARCHAR2(150)	   DEFAULT NULL,
SOURCE_DATA_KEY4	            VARCHAR2(150)	   DEFAULT NULL,
SOURCE_DATA_KEY5	            VARCHAR2(150)	   DEFAULT NULL,
INVOICED_LINE_ACCTG_LEVEL	    VARCHAR2(15)	   DEFAULT NULL,
-- ship_via                        varchar2(30)       DEFAULT NULL,
-- fob_point                       varchar2(30)       DEFAULT NULL,
-- waybill_number                  varchar2(50)       DEFAULT NULL,
SHIP_DATE_ACTUAL	            DATE               DEFAULT NULL,
OVERRIDE_AUTO_ACCOUNTING_FLAG	    VARCHAR2(1)	       DEFAULT NULL,
DEFERRAL_EXCLUSION_FLAG 	    VARCHAR2(1)	       DEFAULT NULL,
RULE_END_DATE                       DATE               DEFAULT NULL,
SOURCE_APPLICATION_ID               NUMBER             DEFAULT NULL,
SOURCE_EVENT_CLASS_CODE             VARCHAR2(30)       DEFAULT NULL,
SOURCE_ENTITY_CODE                  VARCHAR2(30)       DEFAULT NULL,
SOURCE_TRX_ID                       NUMBER             DEFAULT NULL,
SOURCE_TRX_LINE_ID                  NUMBER             DEFAULT NULL,
SOURCE_TRX_LINE_TYPE                VARCHAR2(30)       DEFAULT NULL,
SOURCE_TRX_DETAIL_TAX_LINE_ID       NUMBER             DEFAULT NULL,
HISTORICAL_FLAG                     VARCHAR2(1)        DEFAULT NULL,
TAXABLE_FLAG                        VARCHAR2(1)        DEFAULT NULL,
TAX_REGIME_CODE                     VARCHAR2(30)       DEFAULT NULL,
TAX                                 VARCHAR2(30)       DEFAULT NULL,
TAX_STATUS_CODE                     VARCHAR2(30)       DEFAULT NULL,
TAX_RATE_CODE                       VARCHAR2(30)       DEFAULT NULL,
TAX_JURISDICTION_CODE               VARCHAR2(30)       DEFAULT NULL,
TAX_CLASSIFICATION_CODE             VARCHAR2(30)       DEFAULT NULL,
--Late Charges
interest_line_id      NUMBER      DEFAULT NULL,
TRX_BUSINESS_CATEGORY               VARCHAR2(240)      DEFAULT NULL,
PRODUCT_FISC_CLASSIFICATION         VARCHAR2(240)      DEFAULT NULL,
PRODUCT_CATEGORY                    VARCHAR2(240)      DEFAULT NULL,
PRODUCT_TYPE                        VARCHAR2(240)      DEFAULT NULL,
LINE_INTENDED_USE                   VARCHAR2(30)       DEFAULT NULL,
ASSESSABLE_VALUE                    NUMBER
);


TYPE trx_line_tbl_type IS TABLE OF trx_line_rec_type
	INDEX BY BINARY_INTEGER;

TYPE batch_source_rec_type IS RECORD (
            batch_source_id                 NUMBER          DEFAULT NULL,
            default_date                    DATE            DEFAULT NULL);


TYPE trx_dist_rec_type  IS RECORD (
        trx_dist_id                     NUMBER(15),
	trx_header_id			NUMBER(15),
        trx_LINE_ID	                NUMBER(15),
        ACCOUNT_CLASS	                VARCHAR2(20),
        AMOUNT	                        NUMBER           DEFAULT NULL,
        acctd_amount                    number           DEFAULT NULL,
        PERCENT	                        NUMBER          DEFAULT NULL,
        CODE_COMBINATION_ID	        NUMBER(15)      DEFAULT NULL,
        -- CUST_TRX_LINE_SALESREP_ID	NUMBER(15)      DEFAULT NULL,
        ATTRIBUTE_CATEGORY	        VARCHAR2(30)    DEFAULT NULL,
        ATTRIBUTE1	                VARCHAR2(150)    DEFAULT NULL,
        ATTRIBUTE2	                VARCHAR2(150)    DEFAULT NULL,
        ATTRIBUTE3	                VARCHAR2(150)    DEFAULT NULL,
        ATTRIBUTE4	                VARCHAR2(150)    DEFAULT NULL,
        ATTRIBUTE5	                VARCHAR2(150)    DEFAULT NULL,
        ATTRIBUTE6	                VARCHAR2(150)    DEFAULT NULL,
        ATTRIBUTE7	                VARCHAR2(150)    DEFAULT NULL,
        ATTRIBUTE8	                VARCHAR2(150)    DEFAULT NULL,
        ATTRIBUTE9	                VARCHAR2(150)    DEFAULT NULL,
        ATTRIBUTE10	                VARCHAR2(150)    DEFAULT NULL,
        ATTRIBUTE11	                VARCHAR2(150)    DEFAULT NULL,
        ATTRIBUTE12	                VARCHAR2(150)    DEFAULT NULL,
        ATTRIBUTE13	                VARCHAR2(150)    DEFAULT NULL,
        ATTRIBUTE14	                VARCHAR2(150)    DEFAULT NULL,
        ATTRIBUTE15	                VARCHAR2(150)    DEFAULT NULL,
        COMMENTS	                VARCHAR2(240)    DEFAULT NULL);

TYPE trx_dist_tbl_type IS TABLE OF trx_dist_rec_type
	INDEX BY BINARY_INTEGER;


TYPE api_outputs_type IS RECORD
(
  batch_id NUMBER DEFAULT NULL
);

g_api_outputs api_outputs_type;
g_customer_trx_id           ra_customer_trx_all.customer_trx_id%type;
g_dist_exist                boolean;
g_sc_exist                  boolean;
g_cont_exist                boolean;

 /*#
 * Use this procedure to create multiple invoices in a batch.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Invoice in a Batch
 */

PROCEDURE CREATE_INVOICE(
    p_api_version           IN      	NUMBER,
    p_init_msg_list         IN      	VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN      	VARCHAR2 := FND_API.G_FALSE,
    p_batch_source_rec      IN      	batch_source_rec_type DEFAULT NULL,
    p_trx_header_tbl        IN      	trx_header_tbl_type,
    p_trx_lines_tbl         IN      	trx_line_tbl_type,
    p_trx_dist_tbl          IN          trx_dist_tbl_type,
    p_trx_salescredits_tbl  IN          trx_salescredits_tbl_type,
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2);

 /*#
 * Use this procedure to create a single invoice and return a customer transaction ID.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Single Invoice
 */

PROCEDURE CREATE_SINGLE_INVOICE(
    p_api_version           IN      	NUMBER,
    p_init_msg_list         IN      	VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN      	VARCHAR2 := FND_API.G_FALSE,
    p_batch_source_rec      IN      	batch_source_rec_type DEFAULT NULL,
    p_trx_header_tbl        IN      	trx_header_tbl_type,
    p_trx_lines_tbl         IN      	trx_line_tbl_type,
    p_trx_dist_tbl          IN          trx_dist_tbl_type,
    p_trx_salescredits_tbl  IN          trx_salescredits_tbl_type,
    x_customer_trx_id       OUT NOCOPY  NUMBER,
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2);

-- added the overloaded procedures to make the api backward compatible
-- ORASHID
-- 10/11/2004


PROCEDURE CREATE_INVOICE(
    p_api_version           IN      	NUMBER,
    p_init_msg_list         IN      	VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN      	VARCHAR2 := FND_API.G_FALSE,
    p_batch_source_rec      IN      	batch_source_rec_type DEFAULT NULL,
    p_trx_header_tbl        IN      	trx_header_tbl_type,
    p_trx_lines_tbl         IN      	trx_line_tbl_type,
    p_trx_dist_tbl          IN          trx_dist_tbl_type,
    p_trx_salescredits_tbl  IN          trx_salescredits_tbl_type,
    p_trx_contingencies_tbl IN          trx_contingencies_tbl_type,
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2);


PROCEDURE CREATE_SINGLE_INVOICE(
    p_api_version           IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
    p_batch_source_rec      IN  batch_source_rec_type DEFAULT NULL,
    p_trx_header_tbl        IN  trx_header_tbl_type,
    p_trx_lines_tbl         IN  trx_line_tbl_type,
    p_trx_dist_tbl          IN  trx_dist_tbl_type,
    p_trx_salescredits_tbl  IN  trx_salescredits_tbl_type,
    p_trx_contingencies_tbl IN  trx_contingencies_tbl_type,
    x_customer_trx_id       OUT NOCOPY  NUMBER,
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2);

    -- bug 7194381
TYPE Context_Rec_Type IS RECORD
     (
       curr_precision       fnd_currencies.precision%type,
       curr_mau             fnd_currencies.minimum_accountable_unit%type,
       set_of_books_id      gl_sets_of_books.set_of_books_id%type
                               := arp_global.set_of_books_id,
       chart_of_accounts_id gl_sets_of_books.chart_of_accounts_id%type
                               := arp_global.chart_of_accounts_id,
       salesrep_required_flag ar_system_parameters.salesrep_required_flag%type
        := arp_trx_global.system_info.system_parameters.salesrep_required_flag,
       so_organization_id   fnd_profile_option_values.profile_option_value%type
                             := oe_profile.value('SO_ORGANIZATION_ID'),
       base_currency        fnd_currencies.currency_code%type
                            := arp_trx_global.system_info.base_currency,
       receivable_gl_date   ra_cust_trx_line_gl_dist.gl_date%type,
       code_combination_id_gain
                            ar_system_parameters.code_combination_id_gain%type
                            := arp_global.sysparam.code_combination_id_gain,
       accounting_method    ar_system_parameters.accounting_method%type
                            := arp_global.sysparam.accounting_method,
       use_inv_accounting_for_cm
                           fnd_profile_option_values.profile_option_value%type
                       := arp_trx_global.profile_info.use_inv_acct_for_cm_flag,
       allow_clearing_flag  ra_batch_sources.create_clearing_flag%type,
       validation_level     VARCHAR2(10),
       operation_mode       VARCHAR2(1),
       change_cust_on_trx   VARCHAR2(1),
       unique_seq_numbers   VARCHAR2(1)
     );

     TYPE Line_Rec_Type IS RECORD
     (
       link_to_line_index                       BINARY_INTEGER,
       rev_exist				VARCHAR2(1) := 'N',
       unearn_exist				VARCHAR2(1) := 'N',
       unbill_exist				VARCHAR2(1) := 'N',
       charge_exist				VARCHAR2(1) := 'N',
       delete_flag                              VARCHAR2(1) := 'N',
       dist_amount				NUMBER := 0,
       gl_date					DATE,
       Accounting_rule_duration
            ra_customer_trx_lines.Accounting_rule_duration%type,
       Accounting_rule_id
            ra_customer_trx_lines.Accounting_rule_id%type,
       Attribute1
            ra_customer_trx_lines.Attribute1%type,
       Attribute10
            ra_customer_trx_lines.Attribute10%type,
       Attribute11
            ra_customer_trx_lines.Attribute11%type,
       Attribute12
            ra_customer_trx_lines.Attribute12%type,
       Attribute13
            ra_customer_trx_lines.Attribute13%type,
       Attribute14
            ra_customer_trx_lines.Attribute14%type,
       Attribute15
            ra_customer_trx_lines.Attribute15%type,
       Attribute2
            ra_customer_trx_lines.Attribute2%type,
       Attribute3
            ra_customer_trx_lines.Attribute3%type,
       Attribute4
            ra_customer_trx_lines.Attribute4%type,
       Attribute5
            ra_customer_trx_lines.Attribute5%type,
       Attribute6
            ra_customer_trx_lines.Attribute6%type,
       Attribute7
            ra_customer_trx_lines.Attribute7%type,
       Attribute8
            ra_customer_trx_lines.Attribute8%type,
       Attribute9
            ra_customer_trx_lines.Attribute9%type,
       Attribute_category
            ra_customer_trx_lines.Attribute_category%type,
       Autorule_complete_flag
            ra_customer_trx_lines.Autorule_complete_flag%type,
       Autorule_duration_processed
            ra_customer_trx_lines.Autorule_duration_processed%type,
       Autotax
            ra_customer_trx_lines.Autotax%type,
       Created_by
            ra_customer_trx_lines.Created_by%type,
       Creation_date
            ra_customer_trx_lines.Creation_date%type,
       Customer_trx_id
            ra_customer_trx_lines.Customer_trx_id%type,
       Customer_trx_line_id
            ra_customer_trx_lines.Customer_trx_line_id%type,
       Default_ussgl_transaction_code
            ra_customer_trx_lines.Default_ussgl_transaction_code%type,
       Default_ussgl_trx_code_context
            ra_customer_trx_lines.Default_ussgl_trx_code_context%type,
       Description
            ra_customer_trx_lines.Description%type,
       Extended_amount
            ra_customer_trx_lines.Extended_amount%type,
       Global_attribute1
            ra_customer_trx_lines.Global_attribute1%type,
       Global_attribute10
            ra_customer_trx_lines.Global_attribute10%type,
       Global_attribute11
            ra_customer_trx_lines.Global_attribute11%type,
       Global_attribute12
            ra_customer_trx_lines.Global_attribute12%type,
       Global_attribute13
            ra_customer_trx_lines.Global_attribute13%type,
       Global_attribute14
            ra_customer_trx_lines.Global_attribute14%type,
       Global_attribute15
            ra_customer_trx_lines.Global_attribute15%type,
       Global_attribute16
            ra_customer_trx_lines.Global_attribute16%type,
       Global_attribute17
            ra_customer_trx_lines.Global_attribute17%type,
       Global_attribute18
            ra_customer_trx_lines.Global_attribute18%type,
       Global_attribute19
            ra_customer_trx_lines.Global_attribute19%type,
       Global_attribute2
            ra_customer_trx_lines.Global_attribute2%type,
       Global_attribute20
            ra_customer_trx_lines.Global_attribute20%type,
       Global_attribute3
            ra_customer_trx_lines.Global_attribute3%type,
       Global_attribute4
            ra_customer_trx_lines.Global_attribute4%type,
       Global_attribute5
            ra_customer_trx_lines.Global_attribute5%type,
       Global_attribute6
            ra_customer_trx_lines.Global_attribute6%type,
       Global_attribute7
            ra_customer_trx_lines.Global_attribute7%type,
       Global_attribute8
            ra_customer_trx_lines.Global_attribute8%type,
       Global_attribute9
            ra_customer_trx_lines.Global_attribute9%type,
       Global_attribute_category
            ra_customer_trx_lines.Global_attribute_category%type,
       Initial_customer_trx_line_id
            ra_customer_trx_lines.Initial_customer_trx_line_id%type,
       Interface_line_attribute1
            ra_customer_trx_lines.Interface_line_attribute1%type,
       Interface_line_attribute10
            ra_customer_trx_lines.Interface_line_attribute10%type,
       Interface_line_attribute11
            ra_customer_trx_lines.Interface_line_attribute11%type,
       Interface_line_attribute12
            ra_customer_trx_lines.Interface_line_attribute12%type,
       Interface_line_attribute13
            ra_customer_trx_lines.Interface_line_attribute13%type,
       Interface_line_attribute14
            ra_customer_trx_lines.Interface_line_attribute14%type,
       Interface_line_attribute15
            ra_customer_trx_lines.Interface_line_attribute15%type,
       Interface_line_attribute2
            ra_customer_trx_lines.Interface_line_attribute2%type,
       Interface_line_attribute3
            ra_customer_trx_lines.Interface_line_attribute3%type,
       Interface_line_attribute4
            ra_customer_trx_lines.Interface_line_attribute4%type,
       Interface_line_attribute5
            ra_customer_trx_lines.Interface_line_attribute5%type,
       Interface_line_attribute6
            ra_customer_trx_lines.Interface_line_attribute6%type,
       Interface_line_attribute7
            ra_customer_trx_lines.Interface_line_attribute7%type,
       Interface_line_attribute8
            ra_customer_trx_lines.Interface_line_attribute8%type,
       Interface_line_attribute9
            ra_customer_trx_lines.Interface_line_attribute9%type,
       Interface_line_context
            ra_customer_trx_lines.Interface_line_context%type,
       Inventory_item_id
            ra_customer_trx_lines.Inventory_item_id%type,
       Item_context
            ra_customer_trx_lines.Item_context%type,
       Item_exception_rate_id
            ra_customer_trx_lines.Item_exception_rate_id%type,
       Last_period_to_credit
            ra_customer_trx_lines.Last_period_to_credit%type,
       Last_update_date
            ra_customer_trx_lines.Last_update_date%type,
       Last_update_login
            ra_customer_trx_lines.Last_update_login%type,
       Last_updated_by
            ra_customer_trx_lines.Last_updated_by%type,
       Line_number
            ra_customer_trx_lines.Line_number%type,
       Line_type
            ra_customer_trx_lines.Line_type%type,
       Link_to_cust_trx_line_id
            ra_customer_trx_lines.Link_to_cust_trx_line_id%type,
       Location_segment_id
            ra_customer_trx_lines.Location_segment_id%type,
       Memo_line_id
            ra_customer_trx_lines.Memo_line_id%type,
       Memo_line_type        VARCHAR2(30),
       Movement_id
            ra_customer_trx_lines.Movement_id%type,
       Org_id
            ra_customer_trx_lines.Org_id%type,
       Previous_customer_trx_id
            ra_customer_trx_lines.Previous_customer_trx_id%type,
       Previous_customer_trx_line_id
            ra_customer_trx_lines.Previous_customer_trx_line_id%type,
       Program_application_id
            ra_customer_trx_lines.Program_application_id%type,
       Program_id
            ra_customer_trx_lines.Program_id%type,
       Program_update_date
            ra_customer_trx_lines.Program_update_date%type,
       Quantity_credited
            ra_customer_trx_lines.Quantity_credited%type,
       Quantity_invoiced
            ra_customer_trx_lines.Quantity_invoiced%type,
       Quantity_ordered
            ra_customer_trx_lines.Quantity_ordered%type,
       Reason_code
            ra_customer_trx_lines.Reason_code%type,
       Request_id
            ra_customer_trx_lines.Request_id%type,
       Revenue_amount
            ra_customer_trx_lines.Revenue_amount%type,
       Rule_start_date
            ra_customer_trx_lines.Rule_start_date%type,
       Sales_order
            ra_customer_trx_lines.Sales_order%type,
       Sales_order_date
            ra_customer_trx_lines.Sales_order_date%type,
       Sales_order_line
            ra_customer_trx_lines.Sales_order_line%type,
       Sales_order_revision
            ra_customer_trx_lines.Sales_order_revision%type,
       Sales_order_source
            ra_customer_trx_lines.Sales_order_source%type,
       Sales_tax_id
            ra_customer_trx_lines.Sales_tax_id%type,
       Set_of_books_id
            ra_customer_trx_lines.Set_of_books_id%type,
       Tax_exempt_flag
            ra_customer_trx_lines.Tax_exempt_flag%type,
       Tax_exempt_number
            ra_customer_trx_lines.Tax_exempt_number%type,
       Tax_exempt_reason_code
            ra_customer_trx_lines.Tax_exempt_reason_code%type,
       Tax_exemption_id
            ra_customer_trx_lines.Tax_exemption_id%type,
       Tax_precedence
            ra_customer_trx_lines.Tax_precedence%type,
       Tax_rate
            ra_customer_trx_lines.Tax_rate%type,
       Tax_vendor_return_code
            ra_customer_trx_lines.Tax_vendor_return_code%type,
       Taxable_flag
            ra_customer_trx_lines.Taxable_flag%type,
       Unit_selling_price
            ra_customer_trx_lines.Unit_selling_price%type,
       Unit_standard_price
            ra_customer_trx_lines.Unit_standard_price%type,
       Uom_code
            ra_customer_trx_lines.Uom_code%type,
       Vat_tax_id
            ra_customer_trx_lines.Vat_tax_id%type,
       Wh_update_date
            ra_customer_trx_lines.Wh_update_date%type,
       Gross_unit_selling_price
	    ra_customer_trx_lines.gross_unit_selling_price%type,
       Gross_extended_amount
            ra_customer_trx_lines.gross_extended_amount%type,
       amount_includes_tax_flag
	    ra_customer_trx_lines.amount_includes_tax_flag%type
 );

 TYPE Line_Tbl_Type        IS TABLE OF Line_Rec_Type
                             INDEX BY BINARY_INTEGER;

 TYPE Trx_Type_Tbl_Type    IS TABLE OF ra_cust_trx_types%rowtype
                             INDEX BY BINARY_INTEGER;

 G_lines_tbl               Line_Tbl_Type;
 Type_Cache_Tbl Trx_Type_Tbl_Type;


PROCEDURE Delete_Transaction(
     p_api_name                  IN  varchar2,
     p_api_version               IN  number,
     p_init_msg_list             IN  varchar2 := FND_API.G_FALSE,
     p_commit                    IN  varchar2 := FND_API.G_FALSE,
     p_validation_level          IN  varchar2 := FND_API.G_VALID_LEVEL_FULL,
     p_customer_trx_id           IN  ra_customer_trx.customer_trx_id%type,
     p_return_status            OUT NOCOPY  varchar2,
     p_msg_count             IN OUT NOCOPY  NUMBER,
     p_msg_data              IN OUT NOCOPY  varchar2,
     p_errors                IN OUT NOCOPY  arp_trx_validate.Message_Tbl_Type);

    -- bug 7194381 END

END AR_INVOICE_API_PUB;

/
