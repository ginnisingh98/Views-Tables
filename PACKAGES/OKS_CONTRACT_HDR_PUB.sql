--------------------------------------------------------
--  DDL for Package OKS_CONTRACT_HDR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_CONTRACT_HDR_PUB" AUTHID CURRENT_USER AS
/* $Header: OKSPKHRS.pls 120.3.12010000.2 2008/11/07 09:46:04 serukull ship $ */
  -- OKS_K_HEADERS_HV Record Spec
    TYPE khrhv_rec_type IS RECORD (
                                   id NUMBER := OKC_API.G_MISS_NUM
                                   , major_version NUMBER := OKC_API.G_MISS_NUM
                                   , chr_id NUMBER := OKC_API.G_MISS_NUM
                                   , acct_rule_id NUMBER := OKC_API.G_MISS_NUM
                                   , payment_type OKS_K_HEADERS_V.PAYMENT_TYPE%TYPE := OKC_API.G_MISS_CHAR
                                   , cc_no OKS_K_HEADERS_V.CC_NO%TYPE := OKC_API.G_MISS_CHAR
                                   , cc_expiry_date OKS_K_HEADERS_V.CC_EXPIRY_DATE%TYPE := OKC_API.G_MISS_DATE
                                   , cc_bank_acct_id NUMBER := OKC_API.G_MISS_NUM
                                   , cc_auth_code OKS_K_HEADERS_V.CC_AUTH_CODE%TYPE := OKC_API.G_MISS_CHAR
                                   , commitment_id NUMBER := OKC_API.G_MISS_NUM
                                   , grace_duration NUMBER := OKC_API.G_MISS_NUM
                                   , grace_period OKS_K_HEADERS_V.GRACE_PERIOD%TYPE := OKC_API.G_MISS_CHAR
                                   , est_rev_percent NUMBER := OKC_API.G_MISS_NUM
                                   , est_rev_date OKS_K_HEADERS_V.EST_REV_DATE%TYPE := OKC_API.G_MISS_DATE
                                   , tax_amount NUMBER := OKC_API.G_MISS_NUM
                                   , tax_status OKS_K_HEADERS_V.TAX_STATUS%TYPE := OKC_API.G_MISS_CHAR
                                   , tax_code NUMBER := OKC_API.G_MISS_NUM
                                   , tax_exemption_id NUMBER := OKC_API.G_MISS_NUM
                                   , billing_profile_id NUMBER := OKC_API.G_MISS_NUM
                                   , renewal_status OKS_K_HEADERS_V.RENEWAL_STATUS%TYPE := OKC_API.G_MISS_CHAR
                                   , electronic_renewal_flag OKS_K_HEADERS_V.ELECTRONIC_RENEWAL_FLAG%TYPE := OKC_API.G_MISS_CHAR
                                   , quote_to_contact_id NUMBER := OKC_API.G_MISS_NUM
                                   , quote_to_site_id NUMBER := OKC_API.G_MISS_NUM
                                   , quote_to_email_id NUMBER := OKC_API.G_MISS_NUM
                                   , quote_to_phone_id NUMBER := OKC_API.G_MISS_NUM
                                   , quote_to_fax_id NUMBER := OKC_API.G_MISS_NUM
                                   , renewal_po_required OKS_K_HEADERS_V.RENEWAL_PO_REQUIRED%TYPE := OKC_API.G_MISS_CHAR
                                   , renewal_po_number OKS_K_HEADERS_V.RENEWAL_PO_NUMBER%TYPE := OKC_API.G_MISS_CHAR
                                   , renewal_price_list NUMBER := OKC_API.G_MISS_NUM
                                   , renewal_pricing_type OKS_K_HEADERS_V.RENEWAL_PRICING_TYPE%TYPE := OKC_API.G_MISS_CHAR
                                   , renewal_markup_percent NUMBER := OKC_API.G_MISS_NUM
                                   , renewal_grace_duration NUMBER := OKC_API.G_MISS_NUM
                                   , renewal_grace_period OKS_K_HEADERS_V.RENEWAL_GRACE_PERIOD%TYPE := OKC_API.G_MISS_CHAR
                                   , renewal_est_rev_percent NUMBER := OKC_API.G_MISS_NUM
                                   , renewal_est_rev_duration NUMBER := OKC_API.G_MISS_NUM
                                   , renewal_est_rev_period OKS_K_HEADERS_V.RENEWAL_EST_REV_PERIOD%TYPE := OKC_API.G_MISS_CHAR
                                   , renewal_price_list_used NUMBER := OKC_API.G_MISS_NUM
                                   , renewal_type_used OKS_K_HEADERS_V.RENEWAL_TYPE_USED%TYPE := OKC_API.G_MISS_CHAR
                                   , renewal_notification_to NUMBER := OKC_API.G_MISS_NUM
                                   , renewal_po_used OKS_K_HEADERS_V.RENEWAL_PO_USED%TYPE := OKC_API.G_MISS_CHAR
                                   , renewal_pricing_type_used OKS_K_HEADERS_V.RENEWAL_PRICING_TYPE_USED%TYPE := OKC_API.G_MISS_CHAR
                                   , renewal_markup_percent_used NUMBER := OKC_API.G_MISS_NUM
                                   , rev_est_percent_used NUMBER := OKC_API.G_MISS_NUM
                                   , rev_est_duration_used NUMBER := OKC_API.G_MISS_NUM
                                   , rev_est_period_used OKS_K_HEADERS_V.REV_EST_PERIOD_USED%TYPE := OKC_API.G_MISS_CHAR
                                   , billing_profile_used NUMBER := OKC_API.G_MISS_NUM
                                   , ern_flag_used_yn OKS_K_HEADERS_V.ERN_FLAG_USED_YN%TYPE := OKC_API.G_MISS_CHAR
                                   , evn_threshold_amt NUMBER := OKC_API.G_MISS_NUM
                                   , evn_threshold_cur OKS_K_HEADERS_V.EVN_THRESHOLD_CUR%TYPE := OKC_API.G_MISS_CHAR
                                   , ern_threshold_amt NUMBER := OKC_API.G_MISS_NUM
                                   , ern_threshold_cur OKS_K_HEADERS_V.ERN_THRESHOLD_CUR%TYPE := OKC_API.G_MISS_CHAR
                                   , renewal_grace_duration_used NUMBER := OKC_API.G_MISS_NUM
                                   , renewal_grace_period_used OKS_K_HEADERS_V.RENEWAL_GRACE_PERIOD_USED%TYPE := OKC_API.G_MISS_CHAR
                                   , inv_trx_type OKS_K_HEADERS_V.INV_TRX_TYPE%TYPE := OKC_API.G_MISS_CHAR
                                   , inv_print_profile OKS_K_HEADERS_V.inv_print_profile%TYPE := OKC_API.G_MISS_CHAR
                                   , ar_interface_yn OKS_K_HEADERS_V.AR_INTERFACE_YN%TYPE := OKC_API.G_MISS_CHAR
                                   , hold_billing OKS_K_HEADERS_V.HOLD_BILLING%TYPE := OKC_API.G_MISS_CHAR
                                   , summary_trx_yn OKS_K_HEADERS_V.SUMMARY_TRX_YN%TYPE := OKC_API.G_MISS_CHAR
                                   , service_po_number OKS_K_HEADERS_V.SERVICE_PO_NUMBER%TYPE := OKC_API.G_MISS_CHAR
                                   , service_po_required OKS_K_HEADERS_V.SERVICE_PO_REQUIRED%TYPE := OKC_API.G_MISS_CHAR
                                   , billing_schedule_type OKS_K_HEADERS_V.BILLING_SCHEDULE_TYPE%TYPE := OKC_API.G_MISS_CHAR
                                   , object_version_number NUMBER := OKC_API.G_MISS_NUM
                                   , security_group_id NUMBER := OKC_API.G_MISS_NUM
                                   , request_id NUMBER := OKC_API.G_MISS_NUM
                                   , created_by NUMBER := OKC_API.G_MISS_NUM
                                   , creation_date OKS_K_HEADERS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
                                   , last_updated_by NUMBER := OKC_API.G_MISS_NUM
                                   , last_update_date OKS_K_HEADERS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
                                   , last_update_login NUMBER := OKC_API.G_MISS_NUM
                                   , period_type OKS_K_HEADERS_V.PERIOD_TYPE%TYPE := OKC_API.G_MISS_CHAR
                                   , period_start OKS_K_HEADERS_V.PERIOD_START%TYPE := OKC_API.G_MISS_CHAR
                                   , price_uom OKS_K_HEADERS_V.PRICE_UOM%TYPE := OKC_API.G_MISS_CHAR
                                   , follow_up_action OKS_K_HEADERS_V.FOLLOW_UP_ACTION%TYPE := OKC_API.G_MISS_CHAR
                                   , follow_up_date OKS_K_HEADERS_V.FOLLOW_UP_DATE%TYPE := OKC_API.G_MISS_DATE
                                   , trxn_extension_id NUMBER := OKC_API.G_MISS_NUM
                                   , date_accepted OKS_K_HEADERS_V.DATE_ACCEPTED%TYPE := OKC_API.G_MISS_DATE
                                   , accepted_by NUMBER := OKC_API.G_MISS_NUM
                                   , rmndr_suppress_flag OKS_K_HEADERS_V.RMNDR_SUPPRESS_FLAG%TYPE := OKC_API.G_MISS_CHAR
                                   , rmndr_sent_flag OKS_K_HEADERS_V.RMNDR_SENT_FLAG%TYPE := OKC_API.G_MISS_CHAR
                                   , quote_sent_flag OKS_K_HEADERS_V.QUOTE_SENT_FLAG%TYPE := OKC_API.G_MISS_CHAR
                                   , process_request_id NUMBER := OKC_API.G_MISS_NUM
                                   , wf_item_key OKS_K_HEADERS_V.WF_ITEM_KEY%TYPE := OKC_API.G_MISS_CHAR
                                   , person_party_id NUMBER := OKC_API.G_MISS_NUM
                                   , tax_classification_code OKS_K_HEADERS_V.TAX_CLASSIFICATION_CODE%TYPE := OKC_API.G_MISS_CHAR
                                   , exempt_certificate_number OKS_K_HEADERS_V.EXEMPT_CERTIFICATE_NUMBER%TYPE := OKC_API.G_MISS_CHAR
                                   , exempt_reason_code OKS_K_HEADERS_V.EXEMPT_REASON_CODE%TYPE := OKC_API.G_MISS_CHAR
                                   , approval_type_used OKS_K_HEADERS_V.APPROVAL_TYPE_USED%TYPE := OKC_API.G_MISS_CHAR
                                   , renewal_comment OKS_K_HEADERS_V.RENEWAL_COMMENT%TYPE := OKC_API.G_MISS_CHAR );
    G_MISS_khrhv_rec khrhv_rec_type;
    TYPE khrhv_tbl_type IS TABLE OF khrhv_rec_type
    INDEX BY BINARY_INTEGER;

    SUBTYPE khrv_rec_type IS oks_khr_pvt.khrv_rec_type;
    SUBTYPE khrv_tbl_type IS oks_khr_pvt.khrv_tbl_type;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
    G_PKG_NAME CONSTANT VARCHAR2(200) := 'OKC_CONTRACT_HDR_PUB';
    G_APP_NAME CONSTANT VARCHAR2(3) := OKC_API.G_APP_NAME;
    G_RET_STS_SUCCESS CONSTANT VARCHAR2(20) := OKC_API.G_RET_STS_SUCCESS;
    G_RET_STS_ERROR CONSTANT VARCHAR2(20) := OKC_API.G_RET_STS_ERROR;
    G_RET_STS_UNEXP_ERROR CONSTANT VARCHAR2(20) := OKC_API.G_RET_STS_UNEXP_ERROR;
    G_UNEXPECTED_ERROR CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
    G_SQLERRM_TOKEN CONSTANT VARCHAR2(200) := 'SQLerrm';
    G_SQLCODE_TOKEN CONSTANT VARCHAR2(200) := 'SQLcode';
    G_FALSE CONSTANT VARCHAR2(10) := OKC_API.G_FALSE;
    G_TRUE CONSTANT VARCHAR2(10) := OKC_API.G_TRUE;
  ---------------------------------------------------------------------------

    PROCEDURE create_header(
                            p_api_version IN NUMBER,
                            p_init_msg_list IN VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count OUT NOCOPY NUMBER,
                            x_msg_data OUT NOCOPY VARCHAR2,
                            p_khrv_rec IN khrv_rec_type,
                            x_khrv_rec OUT NOCOPY khrv_rec_type,
                            p_validate_yn IN VARCHAR2);
    PROCEDURE create_header(
                            p_api_version IN NUMBER,
                            p_init_msg_list IN VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count OUT NOCOPY NUMBER,
                            x_msg_data OUT NOCOPY VARCHAR2,
                            p_khrv_tbl IN khrv_tbl_type,
                            x_khrv_tbl OUT NOCOPY khrv_tbl_type,
                            px_error_tbl IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE,
                            p_validate_yn IN VARCHAR2);
    PROCEDURE create_header(
                            p_api_version IN NUMBER,
                            p_init_msg_list IN VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count OUT NOCOPY NUMBER,
                            x_msg_data OUT NOCOPY VARCHAR2,
                            p_khrv_tbl IN khrv_tbl_type,
                            x_khrv_tbl OUT NOCOPY khrv_tbl_type,
                            p_validate_yn IN VARCHAR2);
    PROCEDURE lock_header(
                          p_api_version IN NUMBER,
                          p_init_msg_list IN VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count OUT NOCOPY NUMBER,
                          x_msg_data OUT NOCOPY VARCHAR2,
                          p_khrv_rec IN khrv_rec_type);
    PROCEDURE lock_header(
                          p_api_version IN NUMBER,
                          p_init_msg_list IN VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count OUT NOCOPY NUMBER,
                          x_msg_data OUT NOCOPY VARCHAR2,
                          p_khrv_tbl IN khrv_tbl_type,
                          px_error_tbl IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
    PROCEDURE lock_header(
                          p_api_version IN NUMBER,
                          p_init_msg_list IN VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count OUT NOCOPY NUMBER,
                          x_msg_data OUT NOCOPY VARCHAR2,
                          p_khrv_tbl IN khrv_tbl_type);
    PROCEDURE update_header(
                            p_api_version IN NUMBER,
                            p_init_msg_list IN VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count OUT NOCOPY NUMBER,
                            x_msg_data OUT NOCOPY VARCHAR2,
                            p_khrv_rec IN khrv_rec_type,
                            x_khrv_rec OUT NOCOPY khrv_rec_type,
                            p_validate_yn IN VARCHAR2);
    PROCEDURE update_header(
                            p_api_version IN NUMBER,
                            p_init_msg_list IN VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count OUT NOCOPY NUMBER,
                            x_msg_data OUT NOCOPY VARCHAR2,
                            p_khrv_tbl IN khrv_tbl_type,
                            x_khrv_tbl OUT NOCOPY khrv_tbl_type,
                            px_error_tbl IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE,
                            p_validate_yn IN VARCHAR2);
    PROCEDURE update_header(
                            p_api_version IN NUMBER,
                            p_init_msg_list IN VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count OUT NOCOPY NUMBER,
                            x_msg_data OUT NOCOPY VARCHAR2,
                            p_khrv_tbl IN khrv_tbl_type,
                            x_khrv_tbl OUT NOCOPY khrv_tbl_type,
                            p_validate_yn IN VARCHAR2);
    PROCEDURE delete_header(
                            p_api_version IN NUMBER,
                            p_init_msg_list IN VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count OUT NOCOPY NUMBER,
                            x_msg_data OUT NOCOPY VARCHAR2,
                            p_khrv_rec IN khrv_rec_type);
    PROCEDURE delete_header(
                            p_api_version IN NUMBER,
                            p_init_msg_list IN VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count OUT NOCOPY NUMBER,
                            x_msg_data OUT NOCOPY VARCHAR2,
                            p_khrv_tbl IN khrv_tbl_type,
                            px_error_tbl IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
    PROCEDURE delete_header(
                            p_api_version IN NUMBER,
                            p_init_msg_list IN VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count OUT NOCOPY NUMBER,
                            x_msg_data OUT NOCOPY VARCHAR2,
                            p_khrv_tbl IN khrv_tbl_type);
    PROCEDURE validate_header(
                              p_api_version IN NUMBER,
                              p_init_msg_list IN VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count OUT NOCOPY NUMBER,
                              x_msg_data OUT NOCOPY VARCHAR2,
                              p_khrv_rec IN khrv_rec_type);
    PROCEDURE validate_header(
                              p_api_version IN NUMBER,
                              p_init_msg_list IN VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count OUT NOCOPY NUMBER,
                              x_msg_data OUT NOCOPY VARCHAR2,
                              p_khrv_tbl IN khrv_tbl_type,
                              px_error_tbl IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
    PROCEDURE validate_header(
                              p_api_version IN NUMBER,
                              p_init_msg_list IN VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count OUT NOCOPY NUMBER,
                              x_msg_data OUT NOCOPY VARCHAR2,
                              p_khrv_tbl IN khrv_tbl_type);
    PROCEDURE create_version(
                             p_api_version IN NUMBER,
                             p_init_msg_list IN VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count OUT NOCOPY NUMBER,
                             x_msg_data OUT NOCOPY VARCHAR2,
                             p_chr_id IN NUMBER);
    PROCEDURE create_version(
                             p_chr_id IN NUMBER,
                             x_return_status OUT NOCOPY VARCHAR2);
    PROCEDURE save_version(
                           p_api_version IN NUMBER,
                           p_init_msg_list IN VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count OUT NOCOPY NUMBER,
                           x_msg_data OUT NOCOPY VARCHAR2,
                           p_chr_id IN NUMBER);
    PROCEDURE delete_saved_version(
                                   p_api_version IN NUMBER,
                                   p_init_msg_list IN VARCHAR2,
                                   x_return_status OUT NOCOPY VARCHAR2,
                                   x_msg_count OUT NOCOPY NUMBER,
                                   x_msg_data OUT NOCOPY VARCHAR2,
                                   p_chr_id IN NUMBER);
    PROCEDURE delete_saved_version(
                                   p_chr_id IN NUMBER,
                                   x_return_status OUT NOCOPY VARCHAR2);
    PROCEDURE restore_version(
                              p_api_version IN NUMBER,
                              p_init_msg_list IN VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count OUT NOCOPY NUMBER,
                              x_msg_data OUT NOCOPY VARCHAR2,
                              p_chr_id IN NUMBER);
    PROCEDURE delete_history(
                             p_api_version IN NUMBER,
                             p_init_msg_list IN VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count OUT NOCOPY NUMBER,
                             x_msg_data OUT NOCOPY VARCHAR2,
                             p_chr_id IN NUMBER);

    PROCEDURE INSERT_ROW_UPG(x_return_status OUT NOCOPY VARCHAR2,
                             p_khrv_tbl IN khrv_tbl_type);

    PROCEDURE CREATE_HDR_VERSION_UPG(x_return_status OUT NOCOPY VARCHAR2,
                                     p_khrhv_tbl IN khrhv_tbl_type );

END oks_contract_hdr_pub;


/
