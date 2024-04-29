--------------------------------------------------------
--  DDL for Package OKL_ARINTF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ARINTF_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRAINS.pls 120.7.12010000.2 2010/04/08 11:44:31 nikshah ship $ */

--start:           15-FEB-07 cklee  R12 Billing enhancement project                 |
-- Comment out the reference to OKL billing external tables
/*
subtype xsiv_rec_type is okl_ext_sell_invs_pub.xsiv_rec_type;
subtype xsiv_tbl_type is okl_ext_sell_invs_pub.xsiv_tbl_type;

G_ExtHdrRec          OKL_EXT_SELL_INVS_V%ROWTYPE;
G_ExtLineRec         OKL_XTL_SELL_INVS_V%ROWTYPE;
G_ExtDistrRec        OKL_XTD_SELL_INVS_V%ROWTYPE;

init_ExtHdrRec       OKL_EXT_SELL_INVS_V%ROWTYPE;
init_ExtLineRec      OKL_XTL_SELL_INVS_V%ROWTYPE;
init_ExtDistrRec     OKL_XTD_SELL_INVS_V%ROWTYPE;
*/
--end:           15-FEB-07 cklee  R12 Billing enhancement project                 |

G_batch_source       varchar2(50) := 'OKL_CONTRACTS';
G_request_id         number       := FND_GLOBAL.CONC_REQUEST_ID;
G_user_id            number       := FND_global.user_id;
--G_sysdate            date         := sysdate;


G_COMMIT_SIZE        NUMBER       := 500;

--x_return_status      VARCHAR2(3);
--x_msg_count          NUMBER;
--x_msg_data           VARCHAR2(2000);

G_EXCEPTION_HALT_PROCESS    EXCEPTION;

-- Record definitions
type error_rec_type is record (
id number);

--start:           15-FEB-07 cklee  R12 Billing enhancement project                 |
-- Comment out the reference to OKL billing external tables
/*
TYPE xfer_rec_type IS RECORD (
   XSI_ID                       OKL_EXT_SELL_INVS_V.ID%TYPE
  ,XLS_ID                       OKL_XTL_SELL_INVS_V.ID%TYPE
  ,XLS_AMOUNT                   OKL_XTL_SELL_INVS_V.AMOUNT%TYPE
  ,LINE_DESCRIPTION             OKL_XTL_SELL_INVS_V.DESCRIPTION%TYPE
  ,INVENTORY_ITEM_ID            OKL_XTL_SELL_INVS_V.INVENTORY_ITEM_ID%TYPE
  ,LINE_TYPE                    OKL_XTL_SELL_INVS_V.LINE_TYPE%TYPE
  ,QUANTITY                     OKL_XTL_SELL_INVS_V.QUANTITY%TYPE
  ,XTRX_CONS_LINE_NUMBER        OKL_XTL_SELL_INVS_V.XTRX_CONS_LINE_NUMBER%TYPE
  ,XTRX_CONS_STREAM_ID          OKL_XTL_SELL_INVS_V.XTRX_CONS_STREAM_ID%TYPE
  ,XTRX_CONTRACT                OKL_XTL_SELL_INVS_V.XTRX_CONTRACT%TYPE
  ,XTRX_ASSET                   OKL_XTL_SELL_INVS_V.XTRX_ASSET%TYPE
  ,XTRX_STREAM_GROUP            OKL_XTL_SELL_INVS_V.XTRX_STREAM_GROUP%TYPE
  ,XTRX_STREAM_TYPE             OKL_XTL_SELL_INVS_V.XTRX_STREAM_TYPE%TYPE
  ,CURRENCY_CODE                OKL_EXT_SELL_INVS_V.CURRENCY_CODE%TYPE
  ,currency_conversion_date     OKL_EXT_SELL_INVS_V.currency_conversion_date%TYPE
  ,currency_conversion_rate     OKL_EXT_SELL_INVS_V.currency_conversion_rate%TYPE
  ,currency_conversion_type     OKL_EXT_SELL_INVS_V.currency_conversion_type%TYPE
  ,CUST_TRX_TYPE_ID             OKL_EXT_SELL_INVS_V.CUST_TRX_TYPE_ID%TYPE
  ,CUSTOMER_ADDRESS_ID          OKL_EXT_SELL_INVS_V.CUSTOMER_ADDRESS_ID%TYPE
  ,CUSTOMER_BANK_ACCOUNT_ID     OKL_EXT_SELL_INVS_V.CUSTOMER_BANK_ACCOUNT_ID%TYPE
  ,CUSTOMER_ID                  OKL_EXT_SELL_INVS_V.CUSTOMER_ID%TYPE
  ,HDR_DESCRIPTION              OKL_EXT_SELL_INVS_V.DESCRIPTION%TYPE
  ,INVOICE_MESSAGE              OKL_EXT_SELL_INVS_V.INVOICE_MESSAGE%TYPE
  ,ORG_ID                       OKL_EXT_SELL_INVS_V.ORG_ID%TYPE
  ,RECEIPT_METHOD_ID            OKL_EXT_SELL_INVS_V.RECEIPT_METHOD_ID%TYPE
  ,SET_OF_BOOKS_ID              OKL_EXT_SELL_INVS_V.SET_OF_BOOKS_ID%TYPE
  ,TAX_EXEMPT_FLAG              OKL_EXT_SELL_INVS_V.TAX_EXEMPT_FLAG%TYPE
  ,TERM_ID                      OKL_EXT_SELL_INVS_V.TERM_ID%TYPE
  ,TRX_DATE                     OKL_EXT_SELL_INVS_V.TRX_DATE%TYPE
  ,TRX_NUMBER                   OKL_EXT_SELL_INVS_V.TRX_NUMBER%TYPE
  ,XTRX_CONS_INVOICE_NUMBER     OKL_EXT_SELL_INVS_V.XTRX_CONS_INVOICE_NUMBER%TYPE
  ,XTRX_FORMAT_TYPE             OKL_EXT_SELL_INVS_V.XTRX_FORMAT_TYPE%TYPE
  ,XTRX_INVOICE_PULL_YN         OKL_EXT_SELL_INVS_V.XTRX_INVOICE_PULL_YN%TYPE
  ,XTRX_PRIVATE_LABEL           OKL_EXT_SELL_INVS_V.XTRX_PRIVATE_LABEL%TYPE
  ,LEGAL_ENTITY_ID              OKL_EXT_SELL_INVS_V.LEGAL_ENTITY_ID%TYPE -- for LE Uptake project 08-11-2006
  ,ACCOUNT_CLASS                OKL_XTD_SELL_INVS_V.ACCOUNT_CLASS%TYPE
  ,DIST_AMOUNT                  OKL_XTD_SELL_INVS_V.AMOUNT%TYPE
  ,DIST_PERCENT                 OKL_XTD_SELL_INVS_V.PERCENT%TYPE
  ,CODE_COMBINATION_ID          OKL_XTD_SELL_INVS_V.CODE_COMBINATION_ID%TYPE
  ,LSM_ID                       OKL_CNSLD_AR_STRMS_B.ID%TYPE
   -- New additional non base table fields to support Bulk inserts
  ,rev_rec_basis                okl_strm_type_b.accrual_yn%type
  ,cm_acct_rule                 ra_interface_lines_all.CREDIT_METHOD_FOR_ACCT_RULE%TYPE
  ,rev_txn_id                   NUMBER
  ,rev_lsm_id                   okl_cnsld_ar_strms_b.id%TYPE
  ,INVENTORY_ORG_ID             okl_xtl_sell_invs_v.inventory_org_id%TYPE
  ,ware_house_id                ra_interface_lines_all.warehouse_id%TYPE
  ,kle_id                       NUMBER
  ,ship_to                      NUMBER
  ,l_inv_id                     NUMBER
  ,uom_code                     mtl_system_items.primary_uom_code%TYPE
  ,txn_id                       NUMBER
  );

type xfer_tbl_type is table of xfer_rec_type index by binary_integer;
*/

TYPE xfer_rec_type IS RECORD (
  TAI_ID                       OKL_TRX_AR_INVOICES_V.ID%TYPE
  ,AMOUNT                       OKL_TXL_AR_INV_LNS_V.AMOUNT%TYPE
  ,LINE_DESCRIPTION             OKL_TXL_AR_INV_LNS_V.DESCRIPTION%TYPE
  ,INVENTORY_ITEM_ID            OKL_TXL_AR_INV_LNS_V.INVENTORY_ITEM_ID%TYPE
  ,LINE_TYPE                    OKL_TXL_AR_INV_LNS_V.inv_receiv_line_code%TYPE
  ,QUANTITY                     OKL_TXL_AR_INV_LNS_V.QUANTITY%TYPE
  ,LINE_NUMBER                  OKL_TXL_AR_INV_LNS_V.LINE_NUMBER%TYPE
  ,STY_ID                       OKL_TXL_AR_INV_LNS_V.STY_ID%TYPE
  ,KHR_ID                       OKC_K_HEADERS_B.ID%TYPE
  ,CONTRACT_NUMBER              OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE
  ,ASSET_NUMBER                 OKC_K_LINES_V.NAME%TYPE
  ,INVOICE_FORMAT_LINE_TYPE     okl_invc_line_types_v.NAME%TYPE
  ,STREAM_TYPE                  OKL_STRM_TYPE_V.NAME%TYPE
  ,CURRENCY_CODE                OKL_TRX_AR_INVOICES_V.CURRENCY_CODE%TYPE
  ,currency_conversion_date     OKL_TRX_AR_INVOICES_V.currency_conversion_date%TYPE
  ,currency_conversion_rate     OKL_TRX_AR_INVOICES_V.currency_conversion_rate%TYPE
  ,currency_conversion_type     OKL_TRX_AR_INVOICES_V.currency_conversion_type%TYPE
  ,CUST_TRX_TYPE_ID             OKL_TRX_AR_INVOICES_V.CUST_TRX_TYPE_ID%TYPE
  ,CUSTOMER_ADDRESS_ID          OKL_TRX_AR_INVOICES_V.IBT_ID%TYPE
  ,CUSTOMER_BANK_ACCOUNT_ID     OKL_TRX_AR_INVOICES_V.CUSTOMER_BANK_ACCOUNT_ID%TYPE
  ,CUSTOMER_ID                  OKL_TRX_AR_INVOICES_V.IXX_ID%TYPE
  ,HDR_DESCRIPTION              OKL_TRX_AR_INVOICES_V.DESCRIPTION%TYPE
  ,INVOICE_MESSAGE              VARCHAR2(4000)
  ,ORG_ID                       OKL_TRX_AR_INVOICES_V.ORG_ID%TYPE
  ,RECEIPT_METHOD_ID            OKL_TRX_AR_INVOICES_V.IRM_ID%TYPE
  ,SET_OF_BOOKS_ID              OKL_TRX_AR_INVOICES_V.SET_OF_BOOKS_ID%TYPE
  ,TAX_EXEMPT_FLAG              OKL_TRX_AR_INVOICES_V.TAX_EXEMPT_FLAG%TYPE
  ,TERM_ID                      OKL_TRX_AR_INVOICES_V.IRT_ID%TYPE
  ,TRX_DATE                     OKL_TRX_AR_INVOICES_V.DATE_INVOICED%TYPE
  ,TRX_NUMBER                   OKL_TRX_AR_INVOICES_V.TRX_NUMBER%TYPE
  ,CONSOLIDATED_INVOICE_NUMBER  OKL_TRX_AR_INVOICES_V.CONSOLIDATED_INVOICE_NUMBER%TYPE
  ,INVOICE_FORMAT_TYPE          OKL_TXD_AR_LN_DTLS_V.INVOICE_FORMAT_TYPE%TYPE
  ,INVOICE_PULL_YN              OKL_TRX_AR_INVOICES_V.INVOICE_PULL_YN%TYPE
  ,PRIVATE_LABEL                OKL_TRX_AR_INVOICES_V.PRIVATE_LABEL%TYPE
  ,LEGAL_ENTITY_ID              OKL_TRX_AR_INVOICES_V.LEGAL_ENTITY_ID%TYPE -- for LE Uptake project 08-11-2006
  ,ACCOUNT_CLASS                ra_interface_distributions_all.ACCOUNT_CLASS%TYPE
  ,DIST_AMOUNT                  okl_trns_acc_dstrs.AMOUNT%TYPE
  ,DIST_PERCENT                 okl_trns_acc_dstrs.PERCENTAGE%TYPE
  ,CODE_COMBINATION_ID          okl_trns_acc_dstrs.CODE_COMBINATION_ID%TYPE
--  ,LSM_ID                       OKL_CNSLD_AR_STRMS_B.ID%TYPE
   -- New additional non base table fields to support Bulk inserts
  ,rev_rec_basis                okl_strm_type_b.accrual_yn%type
  ,cm_acct_rule                 ra_interface_lines_all.CREDIT_METHOD_FOR_ACCT_RULE%TYPE
  ,rev_txn_id                   NUMBER
--  ,rev_lsm_id                   okl_cnsld_ar_strms_b.id%TYPE
  ,INVENTORY_ORG_ID             OKL_TXL_AR_INV_LNS_V.inventory_org_id%TYPE
  ,ware_house_id                ra_interface_lines_all.warehouse_id%TYPE
  ,kle_id                       NUMBER
  ,ship_to                      NUMBER
  ,l_inv_id                     NUMBER
  ,uom_code                     mtl_system_items.primary_uom_code%TYPE
  ,txn_id                       NUMBER
--
-- R12 additional columns pass to AR interface
  ,OKL_SOURCE_BILLING_TRX          OKL_TRX_AR_INVOICES_V.OKL_SOURCE_BILLING_TRX%TYPE
  ,Investor_Agreement_Number       OKL_TRX_AR_INVOICES_V.Investor_Agreement_Number%TYPE
  ,Investor_Name                   OKL_TRX_AR_INVOICES_V.Investor_Name%TYPE
  ,Quote_number                    OKL_TRX_QUOTES_B.quote_number%type
  ,rbk_request_number              NUMBER
  ,RBK_ORI_INVOICE_NUMBER          OKL_TXD_AR_LN_DTLS_V.RBK_ORI_INVOICE_NUMBER%TYPE
  ,RBK_ORI_INVOICE_LINE_NUMBER     OKL_TXD_AR_LN_DTLS_V.RBK_ORI_INVOICE_LINE_NUMBER%TYPE
  ,RBK_ADJUSTMENT_DATE             OKL_TXD_AR_LN_DTLS_V.RBK_ADJUSTMENT_DATE%TYPE
  ,INF_ID                          OKL_TRX_AR_INVOICES_V.INF_ID%TYPE
  ,TRY_ID                          OKL_TRX_TYPES_B.ID%TYPE
  ,TRY_NAME                        OKL_TRX_TYPES_TL.NAME%TYPE
  -- Bug 6744584: contingency fix, added contingency_id. racheruv
  ,CONTINGENCY_ID                  OKL_STRM_TYPE_B.CONTINGENCY_ID%TYPE
  ,INVOICE_LINE_TYPE               OKL_TXD_AR_LN_DTLS_V.INVOICE_FORMAT_LINE_TYPE%TYPE
  );

type xfer_tbl_type is table of xfer_rec_type index by binary_integer;
--end:           15-FEB-07 cklee  R12 Billing enhancement project                 |

bulk_errors   EXCEPTION;
PRAGMA EXCEPTION_INIT (bulk_errors, -24381);


PROCEDURE Get_REC_FEEDER
  ( p_api_version                  IN  NUMBER
  , p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
  , x_return_status                OUT NOCOPY VARCHAR2
  , x_msg_count                    OUT NOCOPY NUMBER
  , x_msg_data                     OUT NOCOPY VARCHAR2
  , p_trx_date_from                IN  DATE DEFAULT NULL
  , p_trx_date_to                  IN  DATE DEFAULT NULL
  , p_assigned_process             IN  VARCHAR2 DEFAULT NULL
  ) ;

--Added for bug 7623549 to call this API from advanced billing pvt
PROCEDURE get_cust_config_from_line(
   p_kle_id                       IN NUMBER
  ,p_customer_address_id          IN NUMBER
  ,p_customer_bank_account_id     IN NUMBER
  ,p_receipt_method_id            IN NUMBER
  ,x_customer_address_id          OUT NOCOPY NUMBER
  ,x_customer_bank_account_id     OUT NOCOPY NUMBER
  ,x_receipt_method_id            OUT NOCOPY NUMBER
  ,x_creation_method_code         OUT NOCOPY VARCHAR2
  ,x_bank_line_id1                OUT NOCOPY NUMBER
);

--Added for bug 7623549 to call this API from advanced billing pvt
PROCEDURE get_auto_bank_dtls(
  p_api_version                IN NUMBER,
  p_init_msg_list              IN VARCHAR2,
  p_khr_id                     IN NUMBER,
  p_customer_address_id        IN NUMBER,
  p_bank_id                    IN VARCHAR2,
  p_trx_date                   IN DATE,
  x_payment_trxn_extension_id  OUT NOCOPY NUMBER,
  x_customer_bank_account_id   OUT NOCOPY NUMBER,
  x_return_status              OUT NOCOPY VARCHAR2,
  x_msg_count                  OUT NOCOPY NUMBER,
  x_msg_data                   OUT NOCOPY VARCHAR2
);

END OKL_ARIntf_Pvt;

/
