--------------------------------------------------------
--  DDL for Package PON_EMD_AR_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_EMD_AR_INTEGRATION_GRP" AUTHID CURRENT_USER AS
/* $Header: PONGARIS.pls 120.0.12010000.16 2012/04/16 06:38:10 rakearun noship $ */


g_fnd_debug     CONSTANT VARCHAR2(1)  :=  NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
g_pkg_name      CONSTANT VARCHAR2(50) := 'PON_EMD_AR_INTEGRATION_GRP';
g_module_prefix CONSTANT VARCHAR2(50) := 'pon.plsql.' || g_pkg_name || '.';


--Constants for Transaction_type_codes

G_EMD_DEPOSIT   CONSTANT  VARCHAR2(50)  :=  'EMD_DEPOSIT';
G_EMD_REFUND    CONSTANT  VARCHAR2(50)  :=  'EMD_REFUND';
G_EMD_FORFEIT   CONSTANT  VARCHAR2(50)  :=  'EMD_FORFEIT';


--Constants for Payment_type_codes

G_CASH            CONSTANT  VARCHAR2(50)  :=  'CASH';
G_CHECK           CONSTANT  VARCHAR2(50)  :=  'CHECK';
G_DEMAND_DRAFT    CONSTANT  VARCHAR2(50)  :=  'DEMAND_DRAFT';
G_CREDIT_CARD     CONSTANT  VARCHAR2(50)  :=  'CREDIT_CARD';
G_BANK_ACCT_XFER  CONSTANT  VARCHAR2(50)  :=  'BANK_ACCT_XFER';
G_CORPORATE_EMD   CONSTANT  VARCHAR2(50)  :=  'CORPORATE_EMD';

TYPE DEPOSIT_INFO_IN_RECTYPE IS RECORD
( deposit_date              ra_customer_trx.trx_date%type,
  party_id                  hz_parties.party_id%type,
  party_site_id             hz_party_sites.party_site_id%type,
  party_contact_id          hz_parties.party_id%TYPE,
  vendor_id                 ap_suppliers.vendor_id%type,
  vendor_site_id            ap_supplier_sites.vendor_site_id%type,
  vendor_name               pon_bidding_parties.trading_partner_name%TYPE,
  vendor_site_name          hz_party_sites.party_site_name%TYPE,
  vendor_contact_name       pon_bidding_parties.trading_partner_contact_name%TYPE,
  customer_id               ra_customer_trx.bill_to_customer_id%TYPE,
  bill_to_site_use_id       ra_customer_trx.bill_to_site_use_id%TYPE,
  deposit_amount            NUMBER,
  deposit_currency          pon_emd_transactions.transaction_currency_code%type,
  exchange_rate_type        pon_emd_transactions.exchange_rate_type%type,
  exchange_date             pon_emd_transactions.exchange_date%type,
  exchange_rate             pon_emd_transactions.exchange_rate%type,
  receipt_method_id         ar_receipt_methods.RECEIPT_METHOD_ID%TYPE,
  customer_bank_account_id  ra_customer_trx.customer_bank_account_id%TYPE,
  org_id                    NUMBER,
  auction_header_id         pon_auction_headers_all.auction_header_id%TYPE,
  document_number           pon_auction_headers_all.document_number%TYPE,
  batch_source_id           ra_batch_sources.batch_source_id%TYPE,
  trx_type_id               ra_cust_trx_types.cust_trx_type_id%TYPE,
  memo_line_id              NUMBER,
  paying_location           hz_locations.city%TYPE,
  in_favor_of               pon_emd_transactions.in_favor_of%type,
  cheque_number             pon_emd_transactions.cheque_number%type,
  cash_bearer_name          pon_emd_transactions.cash_bearer_name%type,
  payable_at                pon_emd_transactions.payable_at%type,
  demand_draft_num          pon_emd_transactions.demand_draft_num%type,
  bank_name                 pon_emd_transactions.bank_name%TYPE,
  bank_branch_name          pon_emd_transactions.bank_branch_name%TYPE,
  bank_account_num          pon_emd_transactions.bank_account_num%TYPE,
  payment_trxn_extension_id NUMBER,
  payment_type_code         pon_emd_transactions.payment_type_code%TYPE,
  emd_transaction_id        pon_emd_transactions.emd_transaction_id%TYPE,
  EMD_TRX_GROUP_ID          pon_emd_transactions.emd_transaction_group_id%TYPE
);

TYPE DEPOSIT_INFO_OUT_RECTYPE IS RECORD
( deposit_trx_number  ra_customer_trx.trx_number%TYPE,
  deposit_trx_id      ra_customer_trx.customer_trx_id%TYPE,
  deposit_trx_line_id  ra_customer_trx_lines.customer_trx_line_id%TYPE
);

TYPE RECEIPT_INFO_IN_RECTYPE IS RECORD
( party_id                  hz_parties.party_id%type,
  vendor_site_id            ap_supplier_sites.vendor_site_id%type,
  customer_id               ra_customer_trx.bill_to_customer_id%TYPE,
  party_site_id             hz_party_sites.party_site_id%type,
  vendor_contact_id         ap_supplier_contacts.vendor_contact_id%type,
  exchange_rate_type        ra_customer_trx.exchange_rate_type%type,
  exchange_date             ra_customer_trx.exchange_date%type,
  exchange_rate             ra_customer_trx.exchange_rate%type,
  receipt_method_id         ar_receipt_methods.RECEIPT_METHOD_ID%TYPE,
  receipt_amount            ar_cash_receipts.amount%TYPE,
  receipt_date              ar_cash_receipts.receipt_date%TYPE,
  deposit_date              ar_cash_receipts.deposit_date%TYPE,
  org_id                    NUMBER
);

TYPE RECEIPT_INFO_OUT_RECTYPE IS RECORD
( receipt_id number
);

TYPE UNAPPLY_INFO_IN_RECTYPE IS RECORD
(
  cash_receipt_id     NUMBER,
  deposit_trx_id      ra_customer_trx.customer_trx_id%TYPE,
  transaction_date    DATE,
  receivable_app_id   NUMBER,
  org_id              NUMBER
);


TYPE UNAPPLY_INFO_OUT_RECTYPE IS RECORD
(
 receipt_id NUMBER
);


TYPE REFUND_INFO_IN_RECTYPE IS RECORD
(
  receipt_num                   ar_cash_receipts.receipt_number%TYPE,
  cash_receipt_id               NUMBER,
  amount_applied                NUMBER,
  apply_date                    ar_receivable_applications.apply_date%TYPE,
  apply_gl_date                 ar_receivable_applications.gl_date%TYPE,
  payment_method_code           ap_invoices.payment_method_code%TYPE,
  applied_payment_schedule_id   ar_payment_schedules.payment_schedule_id%TYPE,
  org_id                        NUMBER
);

TYPE REFUND_INFO_OUT_RECTYPE IS RECORD
(
  application_ref_id          ar_receivable_applications.application_ref_id%TYPE,
  application_ref_type        ar_receivable_applications.application_ref_type%TYPE,
  application_ref_num         ar_receivable_applications.application_ref_type%TYPE
);

TYPE FORFEIT_INFO_IN_RECTYPE IS RECORD
(
  trx_type_id               ra_cust_trx_types.cust_trx_type_id%TYPE,
  deposit_trx_id            ra_customer_trx.customer_trx_id%TYPE,
  transaction_currency_code ra_customer_trx.invoice_currency_code%TYPE,
  transaction_date          DATE,
  cust_account_id           ra_customer_trx.bill_to_customer_id%TYPE,
  cust_acct_site_id         HZ_CUST_ACCT_SITES.cust_acct_site_id%TYPE,
  site_use_id               ra_customer_trx.bill_to_site_use_id%TYPE,
  exchange_rate_type        ra_customer_trx.exchange_rate_type%type,
  exchange_date             ra_customer_trx.exchange_date%type,
  exchange_rate             ra_customer_trx.exchange_rate%type,
  receipt_method_id         ar_receipt_methods.receipt_method_id%TYPE,
  org_id                    NUMBER,
  auction_header_id         pon_auction_headers_all.auction_header_id%TYPE,
  document_number           pon_auction_headers_all.document_number%TYPE,
  party_id                  hz_parties.party_id%type,
  party_site_id             hz_party_sites.party_site_id%type,
  party_contact_id          hz_parties.party_id%TYPE,
  vendor_id                 ap_suppliers.vendor_id%type,
  vendor_site_id            ap_supplier_sites.vendor_site_id%type,
  vendor_name               pon_bidding_parties.trading_partner_name%TYPE,
  vendor_site_name          hz_party_sites.party_site_name%TYPE,
  vendor_contact_name       pon_bidding_parties.trading_partner_contact_name%TYPE,
  amount                    NUMBER,
  memo_line_id              NUMBER,
  batch_source_id           ra_batch_sources.batch_source_id%TYPE,
  payment_term_id           NUMBER,
  emd_trx_group_id          pon_emd_transactions.emd_transaction_group_id%TYPE,
  emd_transaction_id        pon_emd_transactions.emd_transaction_id%TYPE,
  trx_count_in_group        NUMBER,
  current_trx_number        NUMBER
);

TYPE FORFEIT_INFO_OUT_RECTYPE IS RECORD
(
 inv_trx_number  NUMBER,
 inv_trx_id      NUMBER,
 error_message   VARCHAR2(4000)
);


TYPE CM_INFO_IN_RECTYPE IS RECORD
(
  customer_trx_id       NUMBER,
  customer_trx_line_id   NUMBER,
  line_amount           NUMBER,
  org_id                NUMBER,
  batch_source_id       NUMBER,
  document_number           pon_auction_headers_all.document_number%TYPE,
  party_id                  hz_parties.party_id%type,
  party_site_id             hz_party_sites.party_site_id%type,
  party_contact_id          hz_parties.party_id%TYPE,
  emd_transaction_id        pon_emd_transactions.emd_transaction_id%TYPE,
  emd_trx_group_id          pon_emd_transactions.emd_transaction_group_id%TYPE
);

TYPE CM_INFO_OUT_RECTYPE IS RECORD
(
    cm_trx_number             NUMBER,
    cm_customer_trx_id        NUMBER,
    cm_customer_trx_line_id   NUMBER
);


TYPE PARTY_INFO_IN_RECTYPE IS RECORD
(
  party_id        hz_parties.party_id%TYPE,
  party_name      hz_parties.party_name%TYPE,
  terms_id         NUMBER
);

TYPE PARTY_INFO_OUT_RECTYPE IS RECORD
(
  party_id                hz_parties.party_id%TYPE,
  party_NUMBER            hz_parties.party_number%TYPE,
  cust_account_id         hz_cust_accounts.cust_account_id%TYPE,
  account_number          hz_cust_accounts.account_number%TYPE
);

TYPE PARTY_SITE_INFO_IN_RECTYPE IS RECORD
(
  party_id            hz_parties.party_id%TYPE,
  party_name          hz_parties.party_name%TYPE,
  party_site_id       hz_party_sites.party_site_id%TYPE,
  cust_account_id     hz_cust_accounts.cust_account_id%TYPE,
  org_id              NUMBER,
  location            hz_locations.city%TYPE,
  terms_id             NUMBER

);

TYPE PARTY_SITE_INFO_OUT_RECTYPE IS RECORD
(
  cust_acct_site_id       HZ_CUST_ACCT_SITES.cust_acct_site_id%TYPE,
  site_use_id             HZ_CUST_SITE_USES.site_use_id%TYPE
);


TYPE pon_emd_trx_rec IS RECORD
 (
  TRADING_PARTNER_ID            PON_BIDDING_PARTIES.TRADING_PARTNER_ID%TYPE,
  TRADING_PARTNER_CONTACT_ID    PON_BIDDING_PARTIES.TRADING_PARTNER_CONTACT_ID%TYPE,
  TRADING_PARTNER_NAME          PON_BIDDING_PARTIES.TRADING_PARTNER_NAME%TYPE,
  TRADING_PARTNER_CONTACT_NAME  PON_BIDDING_PARTIES.TRADING_PARTNER_CONTACT_NAME%TYPE,
  VENDOR_SITE_ID                PON_BIDDING_PARTIES.VENDOR_SITE_ID%TYPE,
  EMD_TRANSACTION_ID            PON_EMD_TRANSACTIONS.EMD_TRANSACTION_ID%TYPE,
  TRANSACTION_TYPE_CODE         PON_EMD_TRANSACTIONS.TRANSACTION_TYPE_CODE%TYPE,
  TRANSACTION_DATE              PON_EMD_TRANSACTIONS.TRANSACTION_DATE%TYPE,
  PAYMENT_TYPE_CODE             PON_EMD_TRANSACTIONS.PAYMENT_TYPE_CODE%TYPE,
  COUNTRY_CODE                  PON_EMD_TRANSACTIONS.COUNTRY_CODE%TYPE,
  BANK_NAME                     PON_EMD_TRANSACTIONS.BANK_NAME%TYPE,
  BANK_BRANCH_NAME              PON_EMD_TRANSACTIONS.BANK_BRANCH_NAME%TYPE,
  BANK_ACCOUNT_NUM              PON_EMD_TRANSACTIONS.BANK_ACCOUNT_NUM%TYPE,
  BANK_ACCOUNT_CURRENCY         PON_EMD_TRANSACTIONS.BANK_ACCOUNT_CURRENCY%TYPE,
  BANK_GURANTEE_NUMBER          PON_EMD_TRANSACTIONS.BANK_GURANTEE_NUMBER%TYPE,
  IN_FAVOR_OF                   PON_EMD_TRANSACTIONS.IN_FAVOR_OF%TYPE,
  CHEQUE_NUMBER                 PON_EMD_TRANSACTIONS.CHEQUE_NUMBER%TYPE,
  CASH_BEARER_NAME              PON_EMD_TRANSACTIONS.CASH_BEARER_NAME%TYPE,
  PAYABLE_AT                    PON_EMD_TRANSACTIONS.PAYABLE_AT%TYPE,
  DEMAND_DRAFT_NUM              PON_EMD_TRANSACTIONS.DEMAND_DRAFT_NUM%TYPE,
  CREDIT_CARD_NUM               PON_EMD_TRANSACTIONS.CREDIT_CARD_NUM%TYPE,
  NAME_ON_CARD                  PON_EMD_TRANSACTIONS.NAME_ON_CARD%TYPE,
  CARD_ISSUER_CODE              PON_EMD_TRANSACTIONS.CARD_ISSUER_CODE%TYPE,
  PURCHASE_CARD_FLAG            PON_EMD_TRANSACTIONS.PURCHASE_CARD_FLAG%TYPE,
  SINGLE_USE_FLAG               PON_EMD_TRANSACTIONS.SINGLE_USE_FLAG%TYPE,
  EXPIRY_DATE                   PON_EMD_TRANSACTIONS.EXPIRY_DATE%TYPE,
  TRANSACTION_CURRENCY_CODE     PON_EMD_TRANSACTIONS.TRANSACTION_CURRENCY_CODE%TYPE,
  EXCHANGE_RATE_TYPE            PON_EMD_TRANSACTIONS.EXCHANGE_RATE_TYPE%TYPE,
  EXCHANGE_DATE                 PON_EMD_TRANSACTIONS.EXCHANGE_DATE%TYPE,
  EXCHANGE_RATE                 PON_EMD_TRANSACTIONS.EXCHANGE_RATE%TYPE,
  AMOUNT                        PON_EMD_TRANSACTIONS.AMOUNT%TYPE,
  POSTED_TO_FINANCE             PON_EMD_TRANSACTIONS.POSTED_TO_FINANCE%TYPE,
  PARENT_EMD_TRANSACTION_ID     PON_EMD_TRANSACTIONS.PARENT_EMD_TRANSACTION_ID%TYPE,
  ORG_ID                        PON_EMD_TRANSACTIONS.ORG_ID%TYPE,
  AUCTION_HEADER_ID             PON_EMD_TRANSACTIONS.AUCTION_HEADER_ID%TYPE,
  STATUS_LOOKUP_CODE            PON_EMD_TRANSACTIONS.STATUS_LOOKUP_CODE%TYPE,
  DOCUMENT_NUMBER               PON_AUCTION_HEADERS_ALL.DOCUMENT_NUMBER%TYPE,
  EMD_ENABLE_FLAG               PON_AUCTION_HEADERS_ALL.EMD_ENABLE_FLAG%TYPE,
  EMD_AMOUNT                    PON_AUCTION_HEADERS_ALL.EMD_AMOUNT%TYPE,
  EMD_DUE_DATE                  PON_AUCTION_HEADERS_ALL.EMD_DUE_DATE%TYPE,
  EMD_TYPE                      PON_AUCTION_HEADERS_ALL.EMD_TYPE%TYPE,
  EMD_GUARANTEE_EXPIRY_DATE     PON_AUCTION_HEADERS_ALL.EMD_GUARANTEE_EXPIRY_DATE%TYPE,
  EMD_ADDITIONAL_INFORMATION    PON_AUCTION_HEADERS_ALL.EMD_ADDITIONAL_INFORMATION%TYPE,
  POST_EMD_TO_FINANCE           PON_AUCTION_HEADERS_ALL.POST_EMD_TO_FINANCE%TYPE,
  VENDOR_ID                     AP_SUPPLIERS.VENDOR_ID%TYPE,
  CURRENCY_CODE                 PON_AUCTION_HEADERS_ALL.CURRENCY_CODE%TYPE,
  ERROR_MESSAGE                 PON_EMD_TRANSACTIONS.ERROR_MESSAGE%TYPE,
  EMD_TRX_GROUP_ID              PON_EMD_TRANSACTIONS.EMD_TRANSACTION_GROUP_ID%TYPE

);

TYPE pon_emd_trx_info_Tbl_Type  IS TABLE OF pon_emd_trx_rec
                             INDEX BY BINARY_INTEGER;



CURSOR emd_transactions_info(x_emd_trx_group_id       NUMBER,
                             x_auction_header_id      NUMBER,
                             x_transaction_type_code  VARCHAR2)
IS
SELECT BP.TRADING_PARTNER_ID,
BP.TRADING_PARTNER_CONTACT_ID,
BP.TRADING_PARTNER_NAME,
BP.TRADING_PARTNER_CONTACT_NAME,
BP.VENDOR_SITE_ID,
ET.EMD_TRANSACTION_ID,
ET.TRANSACTION_TYPE_CODE,
ET.TRANSACTION_DATE,
ET.PAYMENT_TYPE_CODE,
ET.COUNTRY_CODE,
ET.BANK_NAME,
ET.BANK_BRANCH_NAME,
ET.BANK_ACCOUNT_NUM,
ET.BANK_ACCOUNT_CURRENCY,
ET.BANK_GURANTEE_NUMBER,
ET.IN_FAVOR_OF,
ET.CHEQUE_NUMBER,
ET.CASH_BEARER_NAME,
ET.PAYABLE_AT,
ET.DEMAND_DRAFT_NUM,
ET.CREDIT_CARD_NUM,
ET.NAME_ON_CARD,
ET.CARD_ISSUER_CODE,
ET.PURCHASE_CARD_FLAG,
ET.SINGLE_USE_FLAG,
ET.EXPIRY_DATE,
ET.TRANSACTION_CURRENCY_CODE,
ET.EXCHANGE_RATE_TYPE,
ET.EXCHANGE_DATE,
ET.EXCHANGE_RATE,
ET.AMOUNT,
ET.POSTED_TO_FINANCE,
ET.PARENT_EMD_TRANSACTION_ID,
ET.ORG_ID,
ET.AUCTION_HEADER_ID,
ET.STATUS_LOOKUP_CODE,
PUH.DOCUMENT_NUMBER,
PUH.EMD_ENABLE_FLAG,
PUH.EMD_AMOUNT,
PUH.EMD_DUE_DATE,
PUH.EMD_TYPE,
PUH.EMD_GUARANTEE_EXPIRY_DATE,
PUH.EMD_ADDITIONAL_INFORMATION,
PUH.POST_EMD_TO_FINANCE,
SUP.VENDOR_ID,
PUH.CURRENCY_CODE,
ET.ERROR_MESSAGE,
ET.EMD_TRANSACTION_GROUP_ID
FROM PON_EMD_TRANSACTIONS ET,
     PON_BIDDING_PARTIES  BP,
     PON_AUCTION_HEADERS_ALL PUH,
     AP_SUPPLIERS sup
WHERE ET.AUCTION_HEADER_ID = BP.AUCTION_HEADER_ID
AND   PUH.AUCTION_HEADER_ID = ET.AUCTION_HEADER_ID
AND   ET.SUPPLIER_SEQUENCE = BP.SEQUENCE
AND   Nvl(BP.EXEMPT_FLAG,'N') = 'N'
AND   Nvl(ET.POSTED_TO_FINANCE,'N') = 'N'
AND   Nvl(PUH.POST_EMD_TO_FINANCE,'N') = 'Y'
AND   Nvl(PUH.EMD_ENABLE_FLAG,'N') = 'Y'
AND   Nvl(ET.DELETE_FLAG,'N') = 'N'
AND   ET.AUCTION_HEADER_ID = x_auction_header_id
AND   ET.EMD_TRANSACTION_GROUP_ID = x_emd_trx_group_id
AND   BP.TRADING_PARTNER_ID = SUP.PARTY_ID
AND   TRANSACTION_TYPE_CODE = x_transaction_type_code
AND   ET.STATUS_LOOKUP_CODE NOT IN ('RECEIVED','REFUNDED','FORFEITED');


CURSOR payment_type_info(x_payment_type_code VARCHAR2,
                         x_org_id NUMBER)
IS
SELECT
PAYMENT_TYPE_CODE,
RECEIPT_METHOD_ID,
REFUND_PAYMENT_METHOD
FROM PON_EMD_PAYMENT_TYPES_ALL
WHERE PAYMENT_TYPE_CODE = x_payment_type_code
AND ORG_ID = x_org_id
AND ENABLED_FLAG = 'Y';


CURSOR pon_emd_fin_parameters(x_org_id NUMBER)
IS
SELECT
RA_TRX_TYPE_ID,
RA_BATCH_SOURCE_ID,
RA_IMPORT_BATCH_SOURCE_ID,
MEMO_LINE_ID,
MEMO_LINE_INVOICE_ID,
EMD_FINANCE_INTEGRATION,
PAYMENT_TERMS_ID
FROM PON_EMD_FIN_PARAMETERS_ALL
WHERE ORG_ID = x_org_id;



PROCEDURE create_emd_deposit
( p_api_version   IN         NUMBER,
  p_init_msg_list IN         VARCHAR2,
  p_commit        IN         VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  p_in_rec        IN         DEPOSIT_INFO_IN_RECTYPE,
  x_out_rec       OUT NOCOPY DEPOSIT_INFO_OUT_RECTYPE);

PROCEDURE create_emd_receipt_and_apply
( p_api_version   IN         NUMBER,
  p_init_msg_list IN         VARCHAR2,
  p_commit        IN         VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  p_in_rec        IN         RECEIPT_INFO_IN_RECTYPE,
  x_out_rec       OUT NOCOPY RECEIPT_INFO_OUT_RECTYPE);

PROCEDURE unapply_emd_receipt
( p_api_version   IN         NUMBER,
  p_init_msg_list IN         VARCHAR2,
  p_commit        IN         VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  p_in_rec        IN         UNAPPLY_INFO_IN_RECTYPE,
  x_out_rec       OUT NOCOPY UNAPPLY_INFO_OUT_RECTYPE);

PROCEDURE refund_activity_on_emd_receipt
( p_api_version   IN         NUMBER,
  p_init_msg_list IN         VARCHAR2,
  p_commit        IN         VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  p_in_rec        IN         REFUND_INFO_IN_RECTYPE,
  x_out_rec       OUT NOCOPY REFUND_INFO_OUT_RECTYPE);

PROCEDURE create_cm_on_emd_deposit
( p_api_version   IN         NUMBER,
  p_init_msg_list IN         VARCHAR2,
  p_commit        IN         VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  p_in_rec        IN         CM_INFO_IN_RECTYPE,
  x_out_rec       OUT NOCOPY CM_INFO_OUT_RECTYPE);


PROCEDURE create_cust_account
( p_api_version   IN         NUMBER,
  p_init_msg_list IN         VARCHAR2,
  p_commit        IN         VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  p_in_rec        IN         PARTY_INFO_IN_RECTYPE,
  x_out_rec       OUT NOCOPY PARTY_INFO_OUT_RECTYPE);


PROCEDURE create_cust_acc_site_and_usage
( p_api_version   IN         NUMBER,
  p_init_msg_list IN         VARCHAR2,
  p_commit        IN         VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  p_in_rec        IN         PARTY_SITE_INFO_IN_RECTYPE,
  x_out_rec       OUT NOCOPY PARTY_SITE_INFO_OUT_RECTYPE);



PROCEDURE get_customer_info
( p_party_id              IN        NUMBER,
  p_vendor_site_id        IN        NUMBER,
  p_org_id                IN        NUMBER,
  p_payment_terms_id       IN        NUMBER,
  x_cust_account_id       OUT NOCOPY NUMBER,
  x_cust_acct_site_id     OUT NOCOPY NUMBER,
  x_party_name            OUT NOCOPY VARCHAR2,
  x_party_site_id         OUT NOCOPY NUMBER,
  x_party_site_name       OUT NOCOPY VARCHAR2,
  x_site_use_id           OUT NOCOPY NUMBER,
  x_location              OUT NOCOPY VARCHAR2,
  x_return_status         OUT NOCOPY VARCHAR2);
/*
PROCEDURE get_bank_info(p_cust_account_id      IN     NUMBER,
                        p_cust_acct_site_id    IN     NUMBER,
                        p_site_use_id            IN     NUMBER,
                        p_org_id                 IN     NUMBER,
                        p_party_id             IN     NUMBER,
                        p_party_site_id        IN     NUMBER,
                        p_country_code         IN     VARCHAR2,
                        p_bank_name            IN     VARCHAR2,
                        p_bank_branch_name     IN     VARCHAR2,
                        p_bank_account_num     IN     VARCHAR2,
                        p_accountcurrency      IN     VARCHAR2,
                        x_bank_id              OUT NOCOPY   NUMBER,
                        x_branch_id            OUT NOCOPY   NUMBER,
                        x_acct_id              OUT NOCOPY   NUMBER,
                        x_account_assignment_id  OUT NOCOPY NUMBER,
                        x_return_status        OUT NOCOPY   VARCHAR2);


PROCEDURE get_credit_card_info(p_cust_account_id        IN     NUMBER,
                               p_cust_acct_site_id      IN     NUMBER,
                               p_site_use_id            IN     NUMBER,
                               p_party_id               IN     NUMBER,
                               p_party_site_id          IN     NUMBER,
                               p_org_id                 IN     NUMBER,
                               p_country_code           IN     VARCHAR2,
                               p_credit_card_num        IN     VARCHAR2,
                               p_expiry_date            IN     DATE,
                               p_name_on_card           IN     VARCHAR2,
                               p_card_issuer_code       IN     VARCHAR2,
                               p_purchase_card_flag     IN     VARCHAR2,
                               p_single_use_flag        IN     VARCHAR2,
                               x_card_assignment_id     OUT NOCOPY     NUMBER,
                               x_return_status          OUT NOCOPY   VARCHAR2);
*/
PROCEDURE getTrxInfoFromParentTrx(p_parent_emd_transaction_id IN  NUMBER,
                                  x_parent_trx_number         OUT NOCOPY pon_emd_transactions.CUST_TRX_NUMBER%TYPE,
                                  x_parent_trx_id             OUT NOCOPY pon_emd_transactions.CUST_TRX_ID%TYPE,
                                  x_parent_trx_line_id        OUT NOCOPY pon_emd_transactions.CUST_TRX_LINE_ID%TYPE,
                                  x_deposit_payment_type_code OUT NOCOPY VARCHAR2,
                                  x_org_id                    OUT NOCOPY NUMBER,
                                  x_return_status             OUT NOCOPY VARCHAR2);


PROCEDURE getReceiptInfoOfParentTrx(p_parent_trx_id       IN  NUMBER,
                                      p_parent_trx_number   IN  VARCHAR2,
                                      p_org_id              IN  NUMBER,
                                      x_receipt_num         OUT NOCOPY VARCHAR2,
                                      x_cash_receipt_id     OUT NOCOPY NUMBER,
                                      x_receivable_app_id   OUT NOCOPY NUMBER,
                                      x_receipt_status      OUT NOCOPY VARCHAR2,
                                      x_return_status       OUT NOCOPY VARCHAR2);

PROCEDURE validate_trx_info(p_emd_transaction_rec     IN    pon_emd_trx_rec,
                            p_transaction_type_code   IN    VARCHAR2,
                            x_return_status           OUT   NOCOPY VARCHAR2);


PROCEDURE validate_pon_emd_fin(p_emd_fin_integration        IN  VARCHAR2,
                               p_ra_trx_type_id             IN  NUMBER,
                               p_ra_batch_source_id         IN  NUMBER,
                               p_ra_import_batch_source_id  IN  NUMBER,
                               p_memo_line_id               IN  NUMBER,
                               p_memo_line_invoice_id       IN  NUMBER,
                               p_payment_terms_id           IN  NUMBER,
                               p_transaction_type_code      IN  VARCHAR2,
                               p_org_id                     IN  NUMBER,
                               x_return_status              OUT NOCOPY VARCHAR2);

PROCEDURE validate_trx_payment_type_info(p_receipt_method_id      IN   NUMBER,
                                         p_refund_payment_method  IN   VARCHAR2,
                                         p_payment_type_code      IN   VARCHAR2,
                                         p_transaction_type_code  IN   VARCHAR2,
                                         p_org_id                   IN   NUMBER,
                                         x_return_status          OUT  NOCOPY VARCHAR2);


PROCEDURE verify_finance_installation(x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE post_emd_deposit_transactions(p_api_version        IN   NUMBER,
                                        p_emd_trx_group_id   IN   NUMBER,
                                        p_auction_header_id  IN   NUMBER,
                                        x_process_complete   OUT  NOCOPY VARCHAR2);

PROCEDURE post_emd_refund_transactions(p_api_version        IN   NUMBER,
                                       p_emd_trx_group_id   IN   NUMBER,
                                       p_auction_header_id  IN   NUMBER,
                                       x_process_complete   OUT  NOCOPY VARCHAR2);

PROCEDURE post_emd_forfeit_transactions(p_api_version        IN   NUMBER,
                                        p_emd_trx_group_id   IN   NUMBER,
                                        p_auction_header_id  IN   NUMBER,
                                        x_process_complete   OUT NOCOPY VARCHAR2);

PROCEDURE process_emd_forfeit_trans ( p_api_version        IN   NUMBER,
                                      p_emd_trx_group_id   IN   NUMBER,
                                      p_auction_header_id  IN   NUMBER);

PROCEDURE process_emd_refund_trans ( p_api_version        IN   NUMBER,
                                     p_emd_trx_group_id   IN   NUMBER,
                                     p_auction_header_id  IN   NUMBER);


PROCEDURE emd_refund_forfeit_conc(errbuf            OUT NOCOPY VARCHAR2,
                                  retcode           OUT NOCOPY VARCHAR2,
                                  p_api_version        IN   NUMBER,
                                  p_emd_trx_group_id   IN   NUMBER,
                                  p_auction_header_id  IN   NUMBER,
                                  p_emd_trx_type       IN   VARCHAR2);



PROCEDURE update_emd_trx_error_status(p_emd_transaction_id  IN  NUMBER,
                                      p_msg_data            IN  VARCHAR2);

PROCEDURE update_trx_status_lookup_code(p_emd_transaction_id  IN NUMBER);

PROCEDURE insert_and_call_autoinvoice(p_in_rec            IN         FORFEIT_INFO_IN_RECTYPE,
                                      p_in_emd_trx        IN         pon_emd_trx_info_Tbl_Type,
                                      x_return_status     OUT NOCOPY  VARCHAR2);


PROCEDURE print_log(p_message IN VARCHAR2);

END PON_EMD_AR_INTEGRATION_GRP;

/
