--------------------------------------------------------
--  DDL for Package OKL_PAY_INVOICES_DISB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PAY_INVOICES_DISB_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRPIDS.pls 120.4 2007/04/17 19:21:09 rkuttiya noship $ */
 ------------------------------------------------------------------------------
 -- Global Variables
 ------------------------------------------------------------------------------
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_PAY_INVOICES_DISB_PVT';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 G_commit_after_records CONSTANT NUMBER := 500;
 G_commit_count         NUMBER := 0;
 ------------------------------------------------------------------------------
 -- Record Type
 ------------------------------------------------------------------------------
 --rkuttiya R12 B Billing Architecture changed the following record type
 TYPE disb_rec_type IS RECORD (
    cnr_id NUMBER,
    --consolidated_invoice_number okl_cnsld_ar_hdrs_b.consolidated_invoice_number%type,
    receivables_invoice_number okl_bpd_ar_inv_lines_v.receivables_invoice_number%type,
    --set_of_books_id okl_cnsld_ar_hdrs_b.set_of_books_id%type,
    set_of_books_id okl_trx_ar_invoices_b.set_of_books_id%type,
    --org_id okl_cnsld_ar_hdrs_b.org_id%type,
    org_id okl_trx_ar_invoices_b.org_id%type,
    --transaction_date okl_cnsld_ar_hdrs_b.date_consolidated%type,
    transaction_date okl_bpd_ar_invoices_v.date_consolidated%type,
    --currency_code okl_cnsld_ar_hdrs_b.currency_code%type,
    currency_code okl_bpd_ar_invoices_v.currency_code%type,
    --khr_id okl_cnsld_ar_strms_b.khr_id%type,
    khr_id okl_trx_ar_invoices_b.khr_id%type,
    --kle_id okl_cnsld_ar_strms_b.kle_id%type,
    kle_id okl_txl_ar_inv_lns_b.kle_id%type,
    --amount okl_cnsld_ar_strms_b.amount%type,
    amount okl_bpd_ar_inv_lines_v.amount%type,
    --sty_id okl_cnsld_ar_strms_b.sty_id%type,
    sty_id okl_bpd_ar_inv_lines_v.sty_id%type,
    --lsm_id okl_cnsld_ar_strms_b.id%type,
    tld_id okl_txd_ar_ln_dtls_b.id%type,
   -- receivables_invoice_id okl_cnsld_ar_strms_b.receivables_invoice_id%type,
    receivables_invoice_id okl_bpd_ar_inv_lines_v.receivables_invoice_id%type,
    sel_id okl_strm_elements.id%type,
    pph_id okl_party_payment_hdr.id%type,
    passthru_stream_type_id okl_party_payment_hdr.passthru_stream_type_id%type,
    payout_basis okl_party_payment_hdr.payout_basis%type,
    payout_basis_formula okl_party_payment_hdr.payout_basis_formula%type,
    contract_number okc_k_headers_b.contract_number%type,
 -- 31-OCT-2006 ANSETHUR  R12B - Legal Entity
    legal_entity_id                okl_k_headers.legal_entity_id%TYPE := OKL_API.G_MISS_NUM

    );

 TYPE lsm_rcpt_rec_type IS RECORD (
  --rkuttiya R12 B Billing Architecture commented out following
    --lsm_id okl_cnsld_ar_strms_b.id%type,
    tld_id  okl_txd_ar_ln_dtls_b.id%type,
  --
    receivable_application_id ar_receivable_applications_all.receivable_application_id%type);

 TYPE disb_tbl_type IS TABLE OF disb_rec_type
        INDEX BY BINARY_INTEGER;

 TYPE lsm_rcpt_tbl_type IS TABLE OF lsm_rcpt_rec_type
        INDEX BY BINARY_INTEGER;

 ---------------------------------------------------------------------------
 -- Procedures and Functions
 ---------------------------------------------------------------------------
PROCEDURE auto_disbursement(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2	DEFAULT OKL_API.G_FALSE
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		    OUT NOCOPY VARCHAR2
	,p_from_date	    IN  DATE	DEFAULT NULL
	,p_to_date		    IN  DATE	DEFAULT NULL
  ,p_contract_number IN VARCHAR2 DEFAULT NULL);

PROCEDURE invoice_disbursement (
    p_api_version   IN NUMBER,
    p_init_msg_list IN VARCHAR2,
    x_return_status OUT NOCOPY  VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY  VARCHAR2,
    p_disb_rec      IN disb_rec_type)	;

FUNCTION credit_check(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2	DEFAULT OKL_API.G_FALSE
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		    OUT NOCOPY VARCHAR2
	,p_creditline_id   IN  NUMBER
	,p_credit_max       IN  NUMBER
    ,P_trx_date         IN DATE DEFAULT SYSDATE)
    RETURN NUMBER;

FUNCTION receipt_amount(p_customer_trx_id IN NUMBER) RETURN NUMBER;

FUNCTION partial_receipt_amount(p_customer_trx_id IN NUMBER) RETURN NUMBER;

FUNCTION receipt_date(p_customer_trx_id IN NUMBER) RETURN DATE;

FUNCTION partial_receipt_date(p_customer_trx_id IN NUMBER) RETURN DATE;

FUNCTION get_next_pymt_date(p_start_date IN Date
                           ,p_frequency IN VARCHAR2
                  	       ,p_offset_date IN DATE DEFAULT SYSDATE) RETURN DATE;

FUNCTION get_kle_party_pmt_hdr(p_khr_id IN NUMBER
                              ,p_kle_id IN Number
                              ,p_lyt_code IN VARCHAR2
                              ,p_term IN VARCHAR2) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(receipt_amount, WNDS, WNPS);
PRAGMA RESTRICT_REFERENCES(partial_receipt_amount, WNDS, WNPS);
PRAGMA RESTRICT_REFERENCES(receipt_date, WNDS, WNPS);
PRAGMA RESTRICT_REFERENCES(partial_receipt_date, WNDS, WNPS);
PRAGMA RESTRICT_REFERENCES(get_kle_party_pmt_hdr, WNDS, WNPS);

END OKL_PAY_INVOICES_DISB_PVT;

/
