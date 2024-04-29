--------------------------------------------------------
--  DDL for Package AP_RETRO_PRICING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_RETRO_PRICING_PKG" AUTHID CURRENT_USER AS
/* $Header: apretros.pls 120.7.12010000.1 2008/07/28 06:04:38 appldev ship $ */
TYPE id_list_type          IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;  --Bug6328827
TYPE vendor_num_list_type  IS TABLE OF VARCHAR2(30)  INDEX BY BINARY_INTEGER;
TYPE vendor_name_list_type IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
TYPE po_number_list_type   IS TABLE OF VARCHAR2(20)  INDEX BY BINARY_INTEGER;


TYPE instruction_lines_rec_type IS RECORD(
    invoice_id               AP_INVOICE_LINES_INTERFACE.invoice_id%TYPE,
    invoice_line_id          AP_INVOICE_LINES_INTERFACE.invoice_line_id%TYPE,
    po_line_location_id      AP_INVOICE_LINES_INTERFACE.po_line_location_id%TYPE,
    accounting_date          AP_INVOICE_LINES_INTERFACE.accounting_date%TYPE,
    unit_price               AP_INVOICE_LINES_INTERFACE.unit_price%TYPE,
    requester_id             AP_INVOICE_LINES_INTERFACE.requester_id%TYPE,
    description              AP_INVOICE_LINES_INTERFACE.description%TYPE,
    award_id                 AP_INVOICE_LINES_INTERFACE.award_id%TYPE,
    created_by               AP_INVOICE_LINES_INTERFACE.created_by%TYPE);

TYPE instruction_lines_list_type IS TABLE OF instruction_lines_rec_type
     INDEX by BINARY_INTEGER;

TYPE invoice_rec_type IS RECORD (
    invoice_id                    AP_INVOICES_ALL.invoice_id%TYPE,
    vendor_id                     AP_INVOICES_ALL.vendor_id%TYPE,
    invoice_num                   AP_INVOICES_ALL.invoice_num%TYPE,
    set_of_books_id               AP_INVOICES_ALL.set_of_books_id%TYPE,
    invoice_currency_code         AP_INVOICES_ALL.invoice_currency_code%TYPE,
    payment_currency_code         AP_INVOICES_ALL.payment_currency_code%TYPE,
    payment_cross_rate            AP_INVOICES_ALL.payment_cross_rate%TYPE,
    invoice_amount                AP_INVOICES_ALL.invoice_amount%TYPE,
    vendor_site_id                AP_INVOICES_ALL.vendor_site_id%TYPE,
    invoice_date                  AP_INVOICES_ALL.invoice_date%TYPE,
    source                        AP_INVOICES_ALL.source%TYPE,
    invoice_type_lookup_code      AP_INVOICES_ALL.invoice_type_lookup_code%TYPE,
    description                   AP_INVOICES_ALL.description%TYPE,
    amount_applicable_to_discount AP_INVOICES_ALL.amount_applicable_to_discount%TYPE,
    terms_id                      AP_INVOICES_ALL.terms_id%TYPE,
    terms_date                    AP_INVOICES_ALL.terms_date%TYPE,
    payment_method_code           AP_INVOICES_ALL.payment_method_code%TYPE, --4552701
    pay_group_lookup_code         AP_INVOICES_ALL.pay_group_lookup_code%TYPE,
    accts_pay_code_combination_id AP_INVOICES_ALL.accts_pay_code_combination_id%TYPE,
    payment_status_flag           AP_INVOICES_ALL.payment_status_flag%TYPE,
    creation_date                 AP_INVOICES_ALL.creation_date%TYPE,
    created_by                    AP_INVOICES_ALL.created_by%TYPE,
    base_amount                   AP_INVOICES_ALL.base_amount%TYPE,
    exclusive_payment_flag        AP_INVOICES_ALL.exclusive_payment_flag%TYPE,
    goods_received_date           AP_INVOICES_ALL.goods_received_date%TYPE,
    invoice_received_date         AP_INVOICES_ALL.invoice_received_date%TYPE,
    exchange_rate                 AP_INVOICES_ALL.exchange_rate%TYPE,
    exchange_rate_type            AP_INVOICES_ALL.exchange_rate_type%TYPE,
    exchange_date                 AP_INVOICES_ALL.exchange_date%TYPE,
    attribute1                    AP_INVOICES_ALL.attribute1%TYPE,
    attribute2                    AP_INVOICES_ALL.attribute2%TYPE,
    attribute3                    AP_INVOICES_ALL.attribute3%TYPE,
    attribute4                    AP_INVOICES_ALL.attribute4%TYPE,
    attribute5                    AP_INVOICES_ALL.attribute5%TYPE,
    attribute6                    AP_INVOICES_ALL.attribute6%TYPE,
    attribute7                    AP_INVOICES_ALL.attribute7%TYPE,
    attribute8                    AP_INVOICES_ALL.attribute8%TYPE,
    attribute9                    AP_INVOICES_ALL.attribute9%TYPE,
    attribute10                   AP_INVOICES_ALL.attribute10%TYPE,
    attribute11                   AP_INVOICES_ALL.attribute11%TYPE,
    attribute12                   AP_INVOICES_ALL.attribute12%TYPE,
    attribute13                   AP_INVOICES_ALL.attribute13%TYPE,
    attribute14                   AP_INVOICES_ALL.attribute14%TYPE,
    attribute15                   AP_INVOICES_ALL.attribute15%TYPE,
    attribute_category            AP_INVOICES_ALL.attribute_category%TYPE,
 -- Removed references to USSGL for bug 4277744
 -- ussgl_transaction_code        AP_INVOICES_ALL.ussgl_transaction_code%TYPE,
 -- ussgl_trx_code_context        AP_INVOICES_ALL.ussgl_trx_code_context%TYPE,
    project_id                    AP_INVOICES_ALL.project_id%TYPE,
    task_id                       AP_INVOICES_ALL.task_id%TYPE,
    expenditure_type              AP_INVOICES_ALL.expenditure_type%TYPE,
    expenditure_item_date         AP_INVOICES_ALL.expenditure_item_date%TYPE,
    expenditure_organization_id   AP_INVOICES_ALL.expenditure_organization_id%TYPE,
    pa_default_dist_ccid          AP_INVOICES_ALL.pa_default_dist_ccid%TYPE,
    awt_flag                      AP_INVOICES_ALL.awt_flag%TYPE,
    awt_group_id                  AP_INVOICES_ALL.awt_group_id%TYPE,
    pay_awt_group_id              AP_INVOICES_ALL.pay_awt_group_id%TYPE,--bug6817107
    org_id                        AP_INVOICES_ALL.org_id%TYPE,
    award_id                      AP_INVOICES_ALL.award_id%TYPE,
    approval_ready_flag           AP_INVOICES_ALL.approval_ready_flag%TYPE,
    wfapproval_status             AP_INVOICES_ALL.wfapproval_status%TYPE,
    requester_id                  AP_INVOICES_ALL.requester_id%TYPE,
    global_attribute_category     AP_INVOICES_ALL.global_attribute_category%TYPE,
    global_attribute1             AP_INVOICES_ALL.global_attribute1%TYPE,
    global_attribute2             AP_INVOICES_ALL.global_attribute2%TYPE,
    global_attribute3             AP_INVOICES_ALL.global_attribute3%TYPE,
    global_attribute4             AP_INVOICES_ALL.global_attribute4%TYPE,
    global_attribute5             AP_INVOICES_ALL.global_attribute5%TYPE,
    global_attribute6             AP_INVOICES_ALL.global_attribute6%TYPE,
    global_attribute7             AP_INVOICES_ALL.global_attribute7%TYPE,
    global_attribute8             AP_INVOICES_ALL.global_attribute8%TYPE,
    global_attribute9             AP_INVOICES_ALL.global_attribute9%TYPE,
    global_attribute10            AP_INVOICES_ALL.global_attribute10%TYPE,
    global_attribute11            AP_INVOICES_ALL.global_attribute11%TYPE,
    global_attribute12            AP_INVOICES_ALL.global_attribute12%TYPE,
    global_attribute13            AP_INVOICES_ALL.global_attribute13%TYPE,
    global_attribute14            AP_INVOICES_ALL.global_attribute14%TYPE,
    global_attribute15            AP_INVOICES_ALL.global_attribute15%TYPE,
    global_attribute16            AP_INVOICES_ALL.global_attribute16%TYPE,
    global_attribute17            AP_INVOICES_ALL.global_attribute17%TYPE,
    global_attribute18            AP_INVOICES_ALL.global_attribute18%TYPE,
    global_attribute19            AP_INVOICES_ALL.global_attribute19%TYPE,
    global_attribute20            AP_INVOICES_ALL.global_attribute20%TYPE,
    instruction_id                NUMBER(15),
    instr_status_flag             VARCHAR2(1),
    batch_id                      NUMBER(15),
    doc_sequence_id               AP_INVOICES_ALL.doc_sequence_id%TYPE,
    doc_sequence_value            AP_INVOICES_ALL.doc_sequence_value%TYPE,
    doc_category_code             AP_INVOICES_ALL.doc_category_code%TYPE,
    APPLICATION_ID                number(15),
    BANK_CHARGE_BEARER            varchar2(30),
    DELIVERY_CHANNEL_CODE         varchar2(30),
    DISC_IS_INV_LESS_TAX_FLAG     varchar2(1),
    DOCUMENT_SUB_TYPE             VARCHAR2(150),
    EXCLUDE_FREIGHT_FROM_DISCOUNT VARCHAR2(1),
    EXTERNAL_BANK_ACCOUNT_ID      NUMBER(15),
    GL_DATE                       DATE,
    LEGAL_ENTITY_ID               NUMBER(15),
    NET_OF_RETAINAGE_FLAG         VARCHAR2(1),
    PARTY_ID                      NUMBER(15),
    PARTY_SITE_ID                 NUMBER(15),
    PAYMENT_CROSS_RATE_DATE       DATE,
    PAYMENT_CROSS_RATE_TYPE       VARCHAR2(30),
    PAYMENT_FUNCTION              VARCHAR2(30),
    PAYMENT_REASON_CODE           VARCHAR2(30),
    PAYMENT_REASON_COMMENTS       VARCHAR2(240),
    PAY_CURR_INVOICE_AMOUNT       NUMBER,
    PAY_PROC_TRXN_TYPE_CODE       VARCHAR2(30),
    PORT_OF_ENTRY_CODE            VARCHAR2(30),
    POSTING_STATUS                VARCHAR2(15),
    PO_HEADER_ID                  NUMBER(15),
    PRODUCT_TABLE                 VARCHAR2(30),
    PROJECT_ACCOUNTING_CONTEXT    VARCHAR2(30),
    QUICK_PO_HEADER_ID            NUMBER(15),
    REFERENCE_1                   VARCHAR2(30),
    REFERENCE_2                   VARCHAR2(30),
    REFERENCE_KEY1                VARCHAR2(150),
    REFERENCE_KEY2                VARCHAR2(150),
    REFERENCE_KEY3                VARCHAR2(150),
    REFERENCE_KEY4                VARCHAR2(150),
    REFERENCE_KEY5                VARCHAR2(150),
    REMITTANCE_MESSAGE1           VARCHAR2(150),
    REMITTANCE_MESSAGE2           VARCHAR2(150),
    REMITTANCE_MESSAGE3           VARCHAR2(150),
    SETTLEMENT_PRIORITY           VARCHAR2(30),
    SUPPLIER_TAX_EXCHANGE_RATE    NUMBER,
    SUPPLIER_TAX_INVOICE_DATE     DATE,
    SUPPLIER_TAX_INVOICE_NUMBER   VARCHAR2(150),
    TAXATION_COUNTRY              VARCHAR2(30),
    TAX_INVOICE_INTERNAL_SEQ      VARCHAR2(15),
    TAX_INVOICE_RECORDING_DATE    DATE,
    TAX_RELATED_INVOICE_ID        NUMBER,
    TRX_BUSINESS_CATEGORY         VARCHAR2(240),
    UNIQUE_REMITTANCE_IDENTIFIER  VARCHAR2(30),
    URI_CHECK_DIGIT               VARCHAR2(2),
    USER_DEFINED_FISC_CLASS       VARCHAR2(240));

TYPE invoice_header_list_type IS TABLE OF invoice_rec_type
     INDEX BY BINARY_INTEGER;

TYPE invoice_lines_rec_type IS RECORD(
     invoice_id                   AP_INVOICE_LINES_ALL.invoice_id%TYPE,
     line_number                  AP_INVOICE_LINES_ALL.line_number%TYPE,
     line_type_lookup_code        AP_INVOICE_LINES_ALL.line_type_lookup_code%TYPE,
     requester_id                 AP_INVOICE_LINES_ALL.requester_id%TYPE,
     description                  AP_INVOICE_LINES_ALL.description%TYPE,
     line_source                  AP_INVOICE_LINES_ALL.line_source%TYPE,
     org_id                       AP_INVOICE_LINES_ALL.org_id%TYPE,
     inventory_item_id            AP_INVOICE_LINES_ALL.inventory_item_id%TYPE,
     item_description             AP_INVOICE_LINES_ALL.item_description%TYPE,
     serial_number                AP_INVOICE_LINES_ALL.serial_number%TYPE,
     manufacturer                 AP_INVOICE_LINES_ALL.manufacturer%TYPE,
     model_number                 AP_INVOICE_LINES_ALL.model_number%TYPE,
     generate_dists               AP_INVOICE_LINES_ALL.generate_dists%TYPE,
     match_type                   AP_INVOICE_LINES_ALL.match_type%TYPE,
     default_dist_ccid            AP_INVOICE_LINES_ALL.default_dist_ccid%TYPE,
     prorate_across_all_items     AP_INVOICE_LINES_ALL.prorate_across_all_items%TYPE,
     accounting_date              AP_INVOICE_LINES_ALL.accounting_date%TYPE,
     period_name                  AP_INVOICE_LINES_ALL.period_name%TYPE,
     deferred_acctg_flag          AP_INVOICE_LINES_ALL.deferred_acctg_flag%TYPE,
     set_of_books_id              AP_INVOICE_LINES_ALL.set_of_books_id%TYPE,
     amount                       AP_INVOICE_LINES_ALL.amount%TYPE,
     base_amount                  AP_INVOICE_LINES_ALL.base_amount%TYPE,
     rounding_amt                 AP_INVOICE_LINES_ALL.rounding_amt%TYPE,
     quantity_invoiced            AP_INVOICE_LINES_ALL.quantity_invoiced%TYPE,
     unit_meas_lookup_code        AP_INVOICE_LINES_ALL.unit_meas_lookup_code%TYPE,
     unit_price                   AP_INVOICE_LINES_ALL.unit_price%TYPE,
  -- Removed references to USSGL for bug 4277744
  -- ussgl_transaction_code       AP_INVOICE_LINES_ALL.ussgl_transaction_code%TYPE,
     discarded_flag               AP_INVOICE_LINES_ALL.discarded_flag%TYPE,
     cancelled_flag               AP_INVOICE_LINES_ALL.cancelled_flag%TYPE,
     income_tax_region            AP_INVOICE_LINES_ALL.income_tax_region%TYPE,
     type_1099                    AP_INVOICE_LINES_ALL.type_1099%TYPE,
     corrected_inv_id             AP_INVOICE_LINES_ALL.corrected_inv_id%TYPE,
     corrected_line_number        AP_INVOICE_LINES_ALL.corrected_line_number%TYPE,
     po_header_id                 AP_INVOICE_LINES_ALL.po_header_id%TYPE,
     po_line_id                   AP_INVOICE_LINES_ALL.po_line_id%TYPE,
     po_release_id                AP_INVOICE_LINES_ALL.po_release_id%TYPE,
     po_line_location_id          AP_INVOICE_LINES_ALL.po_line_location_id%TYPE,
     po_distribution_id           AP_INVOICE_LINES_ALL.po_distribution_id%TYPE,
     rcv_transaction_id           AP_INVOICE_LINES_ALL.rcv_transaction_id%TYPE,
     final_match_flag             AP_INVOICE_LINES_ALL.final_match_flag%TYPE,
     assets_tracking_flag         AP_INVOICE_LINES_ALL.assets_tracking_flag%TYPE,
     asset_book_type_code         AP_INVOICE_LINES_ALL.asset_book_type_code%TYPE,
     asset_category_id            AP_INVOICE_LINES_ALL.asset_category_id%TYPE,
     project_id                   AP_INVOICE_LINES_ALL.project_id%TYPE,
     task_id                      AP_INVOICE_LINES_ALL.task_id%TYPE,
     expenditure_type             AP_INVOICE_LINES_ALL.expenditure_type%TYPE,
     expenditure_item_date        AP_INVOICE_LINES_ALL.expenditure_item_date%TYPE,
     expenditure_organization_id  AP_INVOICE_LINES_ALL.expenditure_organization_id%TYPE,
     award_id                     AP_INVOICE_LINES_ALL.award_id%TYPE,
     awt_group_id                 AP_INVOICE_LINES_ALL.awt_group_id%TYPE,
     pay_awt_group_id             AP_INVOICE_LINES_ALL.pay_awt_group_id%TYPE,--bug6817107
     receipt_verified_flag        AP_INVOICE_LINES_ALL.receipt_verified_flag%TYPE,
     receipt_required_flag        AP_INVOICE_LINES_ALL.receipt_required_flag%TYPE,
     receipt_missing_flag         AP_INVOICE_LINES_ALL.receipt_missing_flag%TYPE,
     justification                AP_INVOICE_LINES_ALL.justification%TYPE,
     expense_group                AP_INVOICE_LINES_ALL.expense_group%TYPE,
     start_expense_date           AP_INVOICE_LINES_ALL.start_expense_date%TYPE,
     end_expense_date             AP_INVOICE_LINES_ALL.end_expense_date%TYPE,
     receipt_currency_code        AP_INVOICE_LINES_ALL.receipt_currency_code%TYPE,
     receipt_conversion_rate      AP_INVOICE_LINES_ALL.receipt_conversion_rate%TYPE,
     receipt_currency_amount      AP_INVOICE_LINES_ALL.receipt_conversion_rate%TYPE,
     daily_amount                 AP_INVOICE_LINES_ALL.daily_amount%TYPE,
     web_parameter_id             AP_INVOICE_LINES_ALL.web_parameter_id%TYPE,
     adjustment_reason            AP_INVOICE_LINES_ALL.adjustment_reason%TYPE,
     merchant_document_number     AP_INVOICE_LINES_ALL.merchant_document_number%TYPE,
     merchant_name                AP_INVOICE_LINES_ALL.merchant_name%TYPE,
     merchant_reference           AP_INVOICE_LINES_ALL.merchant_reference%TYPE,
     merchant_tax_reg_number      AP_INVOICE_LINES_ALL.merchant_tax_reg_number%TYPE,
     merchant_taxpayer_id         AP_INVOICE_LINES_ALL.merchant_taxpayer_id%TYPE,
     country_of_supply            AP_INVOICE_LINES_ALL.country_of_supply%TYPE,
     credit_card_trx_id           AP_INVOICE_LINES_ALL.credit_card_trx_id%TYPE,
     company_prepaid_invoice_id   AP_INVOICE_LINES_ALL.company_prepaid_invoice_id%TYPE,
     cc_reversal_flag             AP_INVOICE_LINES_ALL.cc_reversal_flag%TYPE,
     creation_date                AP_INVOICE_LINES_ALL.creation_date%TYPE,
     created_by                   AP_INVOICE_LINES_ALL.created_by%TYPE,
     attribute_category           AP_INVOICE_LINES_ALL.attribute_category%TYPE,
     attribute1                   AP_INVOICE_LINES_ALL.attribute1%TYPE,
     attribute2                   AP_INVOICE_LINES_ALL.attribute2%TYPE,
     attribute3                   AP_INVOICE_LINES_ALL.attribute3%TYPE,
     attribute4                   AP_INVOICE_LINES_ALL.attribute4%TYPE,
     attribute5                   AP_INVOICE_LINES_ALL.attribute5%TYPE,
     attribute6                   AP_INVOICE_LINES_ALL.attribute6%TYPE,
     attribute7                   AP_INVOICE_LINES_ALL.attribute7%TYPE,
     attribute8                   AP_INVOICE_LINES_ALL.attribute8%TYPE,
     attribute9                   AP_INVOICE_LINES_ALL.attribute9%TYPE,
     attribute10                  AP_INVOICE_LINES_ALL.attribute10%TYPE,
     attribute11                  AP_INVOICE_LINES_ALL.attribute11%TYPE,
     attribute12                  AP_INVOICE_LINES_ALL.attribute12%TYPE,
     attribute13                  AP_INVOICE_LINES_ALL.attribute13%TYPE,
     attribute14                  AP_INVOICE_LINES_ALL.attribute14%TYPE,
     attribute15                  AP_INVOICE_LINES_ALL.attribute15%TYPE,
     global_attribute_category    AP_INVOICE_LINES_ALL.global_attribute_category%TYPE,
     global_attribute1            AP_INVOICE_LINES_ALL.global_attribute1%TYPE,
     global_attribute2            AP_INVOICE_LINES_ALL.global_attribute2%TYPE,
     global_attribute3            AP_INVOICE_LINES_ALL.global_attribute3%TYPE,
     global_attribute4            AP_INVOICE_LINES_ALL.global_attribute4%TYPE,
     global_attribute5            AP_INVOICE_LINES_ALL.global_attribute5%TYPE,
     global_attribute6            AP_INVOICE_LINES_ALL.global_attribute6%TYPE,
     global_attribute7            AP_INVOICE_LINES_ALL.global_attribute7%TYPE,
     global_attribute8            AP_INVOICE_LINES_ALL.global_attribute8%TYPE,
     global_attribute9            AP_INVOICE_LINES_ALL.global_attribute9%TYPE,
     global_attribute10           AP_INVOICE_LINES_ALL.global_attribute10%TYPE,
     global_attribute11           AP_INVOICE_LINES_ALL.global_attribute11%TYPE,
     global_attribute12           AP_INVOICE_LINES_ALL.global_attribute12%TYPE,
     global_attribute13           AP_INVOICE_LINES_ALL.global_attribute13%TYPE,
     global_attribute14           AP_INVOICE_LINES_ALL.global_attribute14%TYPE,
     global_attribute15           AP_INVOICE_LINES_ALL.global_attribute15%TYPE,
     global_attribute16           AP_INVOICE_LINES_ALL.global_attribute16%TYPE,
     global_attribute17           AP_INVOICE_LINES_ALL.global_attribute17%TYPE,
     global_attribute18           AP_INVOICE_LINES_ALL.global_attribute18%TYPE,
     global_attribute19           AP_INVOICE_LINES_ALL.global_attribute19%TYPE,
     global_attribute20           AP_INVOICE_LINES_ALL.global_attribute20%TYPE,
     primary_intended_use         AP_INVOICE_LINES_ALL.primary_intended_use%TYPE,
     ship_to_location_id          AP_INVOICE_LINES_ALL.ship_to_location_id%TYPE,
     product_type                 AP_INVOICE_LINES_ALL.product_type%TYPE,
     product_category             AP_INVOICE_LINES_ALL.product_category%TYPE,
     product_fisc_classification  AP_INVOICE_LINES_ALL.product_fisc_classification%TYPE,
     user_defined_fisc_class      AP_INVOICE_LINES_ALL.user_defined_fisc_class%TYPE,
     trx_business_category        AP_INVOICE_LINES_ALL.trx_business_category%TYPE,
     summary_tax_line_id          AP_INVOICE_LINES_ALL.summary_tax_line_id%TYPE,
     tax_regime_code              AP_INVOICE_LINES_ALL.tax_regime_code%TYPE,
     tax                          AP_INVOICE_LINES_ALL.tax%TYPE,
     tax_jurisdiction_code        AP_INVOICE_LINES_ALL.tax_jurisdiction_code%TYPE,
     tax_status_code              AP_INVOICE_LINES_ALL.tax_status_code%TYPE,
     tax_rate_id                  AP_INVOICE_LINES_ALL.tax_rate_id%TYPE,
     tax_rate_code                AP_INVOICE_LINES_ALL.tax_rate_code%TYPE,
     tax_rate                     AP_INVOICE_LINES_ALL.tax_rate%TYPE,
     wfapproval_status            AP_INVOICE_LINES_ALL.wfapproval_status%TYPE,
     pa_quantity                  AP_INVOICE_LINES_ALL.pa_quantity%TYPE,
     instruction_id               NUMBER(15),
     adj_type                     VARCHAR2(3),
     cost_factor_id		  AP_INVOICE_LINES_ALL.cost_factor_id%TYPE,
     TAX_CLASSIFICATION_CODE      VARCHAR2(30),
     SOURCE_APPLICATION_ID        NUMBER,
     SOURCE_EVENT_CLASS_CODE      VARCHAR2(30),
     SOURCE_ENTITY_CODE           VARCHAR2(30),
     SOURCE_TRX_ID                NUMBER,
     SOURCE_LINE_ID               NUMBER,
     SOURCE_TRX_LEVEL_TYPE        VARCHAR2(30),
     PA_CC_AR_INVOICE_ID          NUMBER(15),
     PA_CC_AR_INVOICE_LINE_NUM    NUMBER,
     PA_CC_PROCESSED_CODE         VARCHAR2(1),
     REFERENCE_1                  VARCHAR2(30),
     REFERENCE_2                  VARCHAR2(30),
     DEF_ACCTG_START_DATE         DATE,
     DEF_ACCTG_END_DATE           DATE,
     DEF_ACCTG_NUMBER_OF_PERIODS  NUMBER,
     DEF_ACCTG_PERIOD_TYPE        VARCHAR2(30),
     REFERENCE_KEY5               VARCHAR2(150),
     PURCHASING_CATEGORY_ID       NUMBER(15),
     LINE_GROUP_NUMBER            NUMBER,
     WARRANTY_NUMBER              VARCHAR2(15),
     REFERENCE_KEY3               VARCHAR2(150),
     REFERENCE_KEY4               VARCHAR2(150),
     APPLICATION_ID               NUMBER(15),
     PRODUCT_TABLE                VARCHAR2(30),
     REFERENCE_KEY1               VARCHAR2(150),
     REFERENCE_KEY2               VARCHAR2(150),
     RCV_SHIPMENT_LINE_ID         NUMBER(22));

TYPE invoice_lines_list_type IS TABLE OF invoice_lines_rec_type
     INDEX BY BINARY_INTEGER;

TYPE invoice_dists_rec_type IS RECORD (
    accounting_date            AP_INVOICE_DISTRIBUTIONS_ALL.accounting_date%TYPE,
    accrual_posted_flag        AP_INVOICE_DISTRIBUTIONS_ALL.accrual_posted_flag%TYPE,
    amount                     AP_INVOICE_DISTRIBUTIONS_ALL.amount%TYPE,
    asset_book_type_code       AP_INVOICE_DISTRIBUTIONS_ALL.asset_book_type_code%TYPE,
    asset_category_id          AP_INVOICE_DISTRIBUTIONS_ALL.asset_category_id%TYPE,
    assets_addition_flag       AP_INVOICE_DISTRIBUTIONS_ALL.assets_addition_flag%TYPE,
    assets_tracking_flag       AP_INVOICE_DISTRIBUTIONS_ALL.assets_tracking_flag%TYPE,
    attribute_category         AP_INVOICE_DISTRIBUTIONS_ALL.attribute_category%TYPE,
    attribute1                 AP_INVOICE_DISTRIBUTIONS_ALL.attribute1%TYPE,
    attribute10                AP_INVOICE_DISTRIBUTIONS_ALL.attribute10%TYPE,
    attribute11                AP_INVOICE_DISTRIBUTIONS_ALL.attribute11%TYPE,
    attribute12                AP_INVOICE_DISTRIBUTIONS_ALL.attribute12%TYPE,
    attribute13                AP_INVOICE_DISTRIBUTIONS_ALL.attribute13%TYPE,
    attribute14                AP_INVOICE_DISTRIBUTIONS_ALL.attribute14%TYPE,
    attribute15                AP_INVOICE_DISTRIBUTIONS_ALL.attribute15%TYPE,
    attribute2                 AP_INVOICE_DISTRIBUTIONS_ALL.attribute2%TYPE,
    attribute3                 AP_INVOICE_DISTRIBUTIONS_ALL.attribute3%TYPE,
    attribute4                 AP_INVOICE_DISTRIBUTIONS_ALL.attribute4%TYPE,
    attribute5                 AP_INVOICE_DISTRIBUTIONS_ALL.attribute5%TYPE,
    attribute6                 AP_INVOICE_DISTRIBUTIONS_ALL.attribute6%TYPE,
    attribute7                 AP_INVOICE_DISTRIBUTIONS_ALL.attribute7%TYPE,
    attribute8                 AP_INVOICE_DISTRIBUTIONS_ALL.attribute8%TYPE,
    attribute9                 AP_INVOICE_DISTRIBUTIONS_ALL.attribute9%TYPE,
    award_id                   AP_INVOICE_DISTRIBUTIONS_ALL.award_id%TYPE,
    awt_flag                   AP_INVOICE_DISTRIBUTIONS_ALL.awt_flag%TYPE,
    awt_group_id               AP_INVOICE_DISTRIBUTIONS_ALL.awt_group_id%TYPE,
    awt_tax_rate_id            AP_INVOICE_DISTRIBUTIONS_ALL.awt_tax_rate_id%TYPE,
    base_amount                AP_INVOICE_DISTRIBUTIONS_ALL.base_amount%TYPE,
    batch_id                   AP_INVOICE_DISTRIBUTIONS_ALL.batch_id%TYPE,
    cancellation_flag          AP_INVOICE_DISTRIBUTIONS_ALL.cancellation_flag%TYPE,
    cash_posted_flag           AP_INVOICE_DISTRIBUTIONS_ALL.cash_posted_flag%TYPE,
    corrected_invoice_dist_id  AP_INVOICE_DISTRIBUTIONS_ALL.corrected_invoice_dist_id%TYPE,
    corrected_quantity         AP_INVOICE_DISTRIBUTIONS_ALL.corrected_quantity%TYPE,
    country_of_supply          AP_INVOICE_DISTRIBUTIONS_ALL.country_of_supply%TYPE,
    created_by                 AP_INVOICE_DISTRIBUTIONS_ALL.created_by%TYPE,
    description                AP_INVOICE_DISTRIBUTIONS_ALL.description%TYPE,
    dist_code_combination_id   AP_INVOICE_DISTRIBUTIONS_ALL.dist_code_combination_id%TYPE,
    dist_match_type            AP_INVOICE_DISTRIBUTIONS_ALL.dist_match_type%TYPE,
    distribution_class         AP_INVOICE_DISTRIBUTIONS_ALL.distribution_class%TYPE,
    distribution_line_number   AP_INVOICE_DISTRIBUTIONS_ALL.distribution_line_number%TYPE,
    encumbered_flag            AP_INVOICE_DISTRIBUTIONS_ALL.encumbered_flag%TYPE,
    expenditure_item_date      AP_INVOICE_DISTRIBUTIONS_ALL.expenditure_item_date%TYPE,
    expenditure_organization_id AP_INVOICE_DISTRIBUTIONS_ALL.expenditure_organization_id%TYPE,
    expenditure_type           AP_INVOICE_DISTRIBUTIONS_ALL.expenditure_type%TYPE,
    final_match_flag           AP_INVOICE_DISTRIBUTIONS_ALL.final_match_flag%TYPE,
    global_attribute_category  AP_INVOICE_DISTRIBUTIONS_ALL.global_attribute_category%TYPE,
    global_attribute1          AP_INVOICE_DISTRIBUTIONS_ALL.global_attribute1%TYPE,
    global_attribute10         AP_INVOICE_DISTRIBUTIONS_ALL.global_attribute10%TYPE,
    global_attribute11         AP_INVOICE_DISTRIBUTIONS_ALL.global_attribute11%TYPE,
    global_attribute12         AP_INVOICE_DISTRIBUTIONS_ALL.global_attribute12%TYPE,
    global_attribute13         AP_INVOICE_DISTRIBUTIONS_ALL.global_attribute13%TYPE,
    global_attribute14         AP_INVOICE_DISTRIBUTIONS_ALL.global_attribute14%TYPE,
    global_attribute15         AP_INVOICE_DISTRIBUTIONS_ALL.global_attribute15%TYPE,
    global_attribute16         AP_INVOICE_DISTRIBUTIONS_ALL.global_attribute16%TYPE,
    global_attribute17         AP_INVOICE_DISTRIBUTIONS_ALL.global_attribute17%TYPE,
    global_attribute18         AP_INVOICE_DISTRIBUTIONS_ALL.global_attribute18%TYPE,
    global_attribute19         AP_INVOICE_DISTRIBUTIONS_ALL.global_attribute19%TYPE,
    global_attribute2          AP_INVOICE_DISTRIBUTIONS_ALL.global_attribute2%TYPE,
    global_attribute20         AP_INVOICE_DISTRIBUTIONS_ALL.global_attribute20%TYPE,
    global_attribute3          AP_INVOICE_DISTRIBUTIONS_ALL.global_attribute3%TYPE,
    global_attribute4          AP_INVOICE_DISTRIBUTIONS_ALL.global_attribute4%TYPE,
    global_attribute5          AP_INVOICE_DISTRIBUTIONS_ALL.global_attribute5%TYPE,
    global_attribute6          AP_INVOICE_DISTRIBUTIONS_ALL.global_attribute6%TYPE,
    global_attribute7          AP_INVOICE_DISTRIBUTIONS_ALL.global_attribute7%TYPE,
    global_attribute8          AP_INVOICE_DISTRIBUTIONS_ALL.global_attribute8%TYPE,
    global_attribute9          AP_INVOICE_DISTRIBUTIONS_ALL.global_attribute9%TYPE,
    income_tax_region          AP_INVOICE_DISTRIBUTIONS_ALL.income_tax_region%TYPE,
    inventory_transfer_status  AP_INVOICE_DISTRIBUTIONS_ALL.inventory_transfer_status%TYPE,
    invoice_distribution_id    AP_INVOICE_DISTRIBUTIONS_ALL.invoice_distribution_id%TYPE,
    invoice_id                 AP_INVOICE_DISTRIBUTIONS_ALL.invoice_id%TYPE,
    invoice_line_number        AP_INVOICE_DISTRIBUTIONS_ALL.invoice_line_number%TYPE,
    line_type_lookup_code      AP_INVOICE_DISTRIBUTIONS_ALL.line_type_lookup_code%TYPE,
    match_status_flag          AP_INVOICE_DISTRIBUTIONS_ALL.match_status_flag%TYPE,
    matched_uom_lookup_code    AP_INVOICE_DISTRIBUTIONS_ALL.matched_uom_lookup_code%TYPE,
    merchant_document_number   AP_INVOICE_DISTRIBUTIONS_ALL.merchant_document_number%TYPE,
    merchant_name              AP_INVOICE_DISTRIBUTIONS_ALL.merchant_name%TYPE,
    merchant_reference         AP_INVOICE_DISTRIBUTIONS_ALL.merchant_reference%TYPE,
    merchant_tax_reg_number    AP_INVOICE_DISTRIBUTIONS_ALL.merchant_tax_reg_number%TYPE,
    merchant_taxpayer_id       AP_INVOICE_DISTRIBUTIONS_ALL.merchant_taxpayer_id%TYPE,
    org_id                     AP_INVOICE_DISTRIBUTIONS_ALL.org_id%TYPE,
    pa_addition_flag           AP_INVOICE_DISTRIBUTIONS_ALL.pa_addition_flag%TYPE,
    pa_quantity                AP_INVOICE_DISTRIBUTIONS_ALL.pa_quantity%TYPE,
    period_name                AP_INVOICE_DISTRIBUTIONS_ALL.period_name%TYPE,
    po_distribution_id         AP_INVOICE_DISTRIBUTIONS_ALL.po_distribution_id%TYPE,
    posted_flag                AP_INVOICE_DISTRIBUTIONS_ALL.posted_flag%TYPE,
    project_id                 AP_INVOICE_DISTRIBUTIONS_ALL.project_id%TYPE,
    quantity_invoiced          AP_INVOICE_DISTRIBUTIONS_ALL.quantity_invoiced%TYPE,
    rcv_transaction_id         AP_INVOICE_DISTRIBUTIONS_ALL.rcv_transaction_id%TYPE,
    related_id                 AP_INVOICE_DISTRIBUTIONS_ALL.related_id%TYPE,
    reversal_flag              AP_INVOICE_DISTRIBUTIONS_ALL.reversal_flag%TYPE,
    rounding_amt               AP_INVOICE_DISTRIBUTIONS_ALL.rounding_amt%TYPE,
    set_of_books_id            AP_INVOICE_DISTRIBUTIONS_ALL.set_of_books_id%TYPE,
    task_id                    AP_INVOICE_DISTRIBUTIONS_ALL.task_id%TYPE,
    type_1099                  AP_INVOICE_DISTRIBUTIONS_ALL.type_1099%TYPE,
    unit_price                 AP_INVOICE_DISTRIBUTIONS_ALL.unit_price%TYPE,
 -- Removed references to USSGL for bug 4277744
 -- ussgl_transaction_code     AP_INVOICE_DISTRIBUTIONS_ALL.ussgl_transaction_code%TYPE,
    instruction_id             NUMBER(15),
    charge_applicable_to_dist_id AP_INVOICE_DISTRIBUTIONS_ALL.charge_applicable_to_dist_id%TYPE,
    INTENDED_USE               VARCHAR2(30),
    WITHHOLDING_TAX_CODE_ID    NUMBER(15),
    PROJECT_ACCOUNTING_CONTEXT VARCHAR2(30),
    REQ_DISTRIBUTION_ID        NUMBER(15),
    REFERENCE_1                VARCHAR2(30),
    REFERENCE_2                VARCHAR2(30),
    LINE_GROUP_NUMBER          NUMBER,
    PA_CC_AR_INVOICE_ID        NUMBER(15),
    PA_CC_AR_INVOICE_LINE_NUM  NUMBER,
    PA_CC_PROCESSED_CODE       VARCHAR2(1),
    pay_awt_group_id           AP_INVOICE_DISTRIBUTIONS_ALL.pay_awt_group_id%TYPE);  --bug6817107

TYPE invoice_dists_list_type IS TABLE OF invoice_dists_rec_type
     INDEX BY BINARY_INTEGER;


/*=============================================================================
 |  FUNCTION - Create_Instructions()
 |
 |  DESCRIPTION
 |      Main Public procedure for the CADIP called from before report trigger
 |      of APXCADIP. The parameters to the program can limit the process to a
 |      single supplier, site, PO, or release.This program overloads the Invoice
 |      Interface with Instructions. CADIP then initiates the Payables Open
 |      Interface Import program for the instruction records in the interface
 |      using the GROUP_ID(Gateway Batch) as a program parameter. If the
 |      instructions are rejected then CADIP can be resubmitted. Open Interface
 |      Import on resubmission runs for all Instruction rejections(GROUP_ID
 |      is NULL).
 |
 |  PARAMETERS
 |      p_org_id           - Org Id of the PO User
 |      p_po_user_id       - PO's User Id
 |      p_vendor_id        - Vendor Id: Concurrent program parameter
 |      p_vendor_site_id   - Vendor Site Id: Concurrent program parameter
 |      p_po_header_id     - Valid PO's Header Id: Concurrent program parameter
 |      p_po_release_id    - Valid PO Release Id: Concurrent program parameter
 |      P_calling_sequence - Calling sequence
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION Create_Instructions (
           p_vendor_id              IN            NUMBER,
           p_vendor_site_id         IN            NUMBER,
           p_po_header_id           IN            NUMBER,
           p_po_release_id          IN            NUMBER,
           p_po_user_id             IN            NUMBER,
           p_resubmit_flag          IN            VARCHAR2,
           errbuf                      OUT NOCOPY VARCHAR2,
           retcode                     OUT NOCOPY NUMBER,
           p_import_conc_request_id    OUT NOCOPY NUMBER,
           p_calling_sequence       IN            VARCHAR2) RETURN BOOLEAN;


/*=============================================================================
 |  FUNCTION - Import_Retroprice_Adjustments()
 |
 |  DESCRIPTION
 |     Main Public procedure called from the Payables Open Interface Import
 |     Program ("import") which treats the records in the interface tables
 |     as "invoice instructions" rather than each record as an individual
 |     invoice. For recods with source='PPA' the program makes all necessary
 |     adjustments to original invoices and will create the new adjustment
 |     documents in Global Temp Tables.This program will then leverage the
 |     the import validations for the new adjustment docs in the temp tables.
 |     For every instruction the control will return to the Import Program
 |     resulting in Instruction with the status of PROCESSED or REJECTED.
 |     PROCESSED Instructions results in adjustment correction being made
 |     to the original Invoices alongwith the creation of PPA Documents.
 |
 |
 |  IN-PARAMETERS
 |   p_instruction_rec -- Record in the AP_INVOICE_INTERFACE with source=PPA
 |   p_base_currency_code
 |   p_multi_currency_flag
 |   p_set_of_books_id
 |   p_default_exchange_rate_type
 |   p_make_rate_mandatory_flag
 |   p_gl_date_from_get_info
 |   p_gl_date_from_receipt_flag
 |   p_positive_price_tolerance
 |   p_pa_installed
 |   p_qty_tolerance
 |   p_max_qty_ord_tolerance
 |   p_base_min_acct_unit
 |   p_base_precision
 |   p_chart_of_accounts_id
 |   p_freight_code_combination_id
 |   p_purch_encumbrance_flag
 |   p_calc_user_xrate
 |   p_default_last_updated_by
 |   p_default_last_update_login
 |   p_instr_status_flag -- status of the Instruction
 |   p_invoices_count --OUT Count of PPA Invoices Created
 |   p_invoices_total --OUT PPA Invoice Total --to be updated in the Inv Batch
 |   p_invoices_base_amt_total  --OUT PPA Invoice Total
 |   P_calling_sequence - Calling Sequence
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION Import_Retroprice_Adjustments(
           p_instruction_rec   IN     AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
           p_base_currency_code            IN            VARCHAR2,
           p_multi_currency_flag           IN            VARCHAR2,
           p_set_of_books_id               IN            NUMBER,
           p_default_exchange_rate_type    IN            VARCHAR2,
           p_make_rate_mandatory_flag      IN            VARCHAR2,
           p_gl_date_from_get_info         IN            DATE,
           p_gl_date_from_receipt_flag     IN            VARCHAR2,
           p_positive_price_tolerance      IN            NUMBER,
           p_pa_installed                  IN            VARCHAR2,
           p_qty_tolerance                 IN            NUMBER,
           p_max_qty_ord_tolerance         IN            NUMBER,
           p_base_min_acct_unit            IN            NUMBER,
           p_base_precision                IN            NUMBER,
           p_chart_of_accounts_id          IN            NUMBER,
           p_freight_code_combination_id   IN            NUMBER,
           p_purch_encumbrance_flag        IN            VARCHAR2,
           p_calc_user_xrate               IN            VARCHAR2,
           p_default_last_updated_by       IN            NUMBER,
           p_default_last_update_login     IN            NUMBER,
           p_instr_status_flag                OUT NOCOPY VARCHAR2,
           p_invoices_count                   OUT NOCOPY NUMBER,
           p_invoices_total                   OUT NOCOPY NUMBER,
           P_calling_sequence              IN            VARCHAR2) RETURN BOOLEAN;

END AP_RETRO_PRICING_PKG;

/
