--------------------------------------------------------
--  DDL for Package OKS_RENEW_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_RENEW_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSRRUTS.pls 120.7.12000000.1 2007/01/16 22:11:57 appldev ship $*/

    /* anjkumar see new type definition for r12
    type rnrl_rec_type is record (renewal_type varchar2(3),
                                  renewal_pricing_type varchar2(3),
                                  markup_percent number(5, 2),
                                  price_list_id1 varchar2(40),
                                  price_list_id2 varchar2(40),
                                  pdf_id number,
                                  qcl_id number,
                                  cgp_new_id number,
                                  cgp_renew_id number,
                                  po_required_yn varchar2(1),
                                  credit_amount varchar2(50),
                                  rle_code varchar2(30),
                                  revenue_estimated_percent number(5, 2),
                                  revenue_estimated_duration number,
                                  revenue_estimated_period varchar2(20),
                                  function_name varchar2(50),
                                  salesrep_name varchar2(150),
                                  template_set_id number,
                                  threshold_currency varchar2(30),
                                  threshold_amount number,
                                  email_address varchar2(2000),
                                  billing_profile_id number,
                                  user_id number,
                                  threshold_enabled_yn varchar2(1),
                                  grace_period varchar2(20),
                                  grace_duration number,
                                  payment_terms_id1 varchar2(40),
                                  payment_terms_id2 varchar2(40),
                                  evergreen_threshold_curr varchar2(30),
                                  evergreen_threshold_amt number,
                                  payment_method varchar2(3),
                                  payment_threshold_curr varchar2(30),
                                  payment_threshold_amt number,
                                  interface_price_break varchar2(30));
    */

    /* anjkumar, for r12 added the following new fields
        cdt_type
        jtot_object_code
        base_currency
        approval_type
        evergreen_approval_type
        online_approval_type
        purchase_order_flag
        credit_card_flag
        wire_flag
        commitment_number_flag
        check_flag
        period_type
        period_start
        period_uom
        template_language

    */
    TYPE rnrl_rec_type IS RECORD(
                                 cdt_type oks_k_defaults.cdt_type%TYPE,
                                 jtot_object_code oks_k_defaults.jtot_object_code%TYPE,
                                 renewal_type oks_k_defaults.renewal_type%TYPE,
                                 renewal_pricing_type VARCHAR2(30),  -- oks_k_defaults.renewal_pricing_type%type, oks_k_defaults is varchar2(3) while oks_k_headers_b is varchar(30)
                                 markup_percent NUMBER,  --oks_k_defaults.markup_percent%type, oks_k_defaults is number(5,2) while oks_k_headers_b is nukber
                                 price_list_id1 oks_k_defaults.price_list_id1%TYPE,
                                 price_list_id2 oks_k_defaults.price_list_id2%TYPE,
                                 pdf_id oks_k_defaults.pdf_id%TYPE,
                                 qcl_id oks_k_defaults.qcl_id%TYPE,
                                 cgp_new_id oks_k_defaults.cgp_new_id%TYPE,
                                 cgp_renew_id oks_k_defaults.cgp_renew_id%TYPE,
                                 po_required_yn oks_k_defaults.po_required_yn%TYPE,
                                 credit_amount oks_k_defaults.credit_amount%TYPE,
                                 rle_code oks_k_defaults.rle_code%TYPE,
                                 revenue_estimated_percent NUMBER,  --oks_k_defaults.revenue_estimated_percent%type, oks_k_defaults is number(5,2) while oks_k_headers_b is number
                                 revenue_estimated_duration oks_k_defaults.revenue_estimated_duration%TYPE,
                                 revenue_estimated_period VARCHAR(30),  --oks_k_defaults.revenue_estimated_period%type, oks_k_defaults is varchar2(20)while oks_k_headers_b is varchar(30)
                                 function_name VARCHAR2(50),
                                 salesrep_name VARCHAR2(150),
                                 template_set_id oks_k_defaults.template_set_id%TYPE,
                                 threshold_currency oks_k_defaults.base_currency%TYPE,  --obsolete field, replace by base_currency
                                 threshold_amount oks_k_defaults.threshold_amount%TYPE,
                                 email_address oks_k_defaults.email_address%TYPE,
                                 billing_profile_id oks_k_defaults.billing_profile_id%TYPE,
                                 user_id oks_k_defaults.user_id%TYPE,
                                 threshold_enabled_yn oks_k_defaults.threshold_enabled_yn%TYPE,
                                 grace_period VARCHAR(30),  --oks_k_defaults.grace_period%type, oks_k_defaults is varchar2(20) while oks_k_headers_b is varchar(30)
                                 grace_duration oks_k_defaults.grace_duration%TYPE,
                                 payment_terms_id1 oks_k_defaults.payment_terms_id1%TYPE,
                                 payment_terms_id2 oks_k_defaults.payment_terms_id2%TYPE,
                                 evergreen_threshold_curr oks_k_defaults.base_currency%TYPE,  --obsolete field, replace by base_currency
                                 evergreen_threshold_amt oks_k_defaults.evergreen_threshold_amt%TYPE,
                                 payment_method oks_k_defaults.payment_method%TYPE,
                                 payment_threshold_curr oks_k_defaults.base_currency%TYPE,  --obsolete field, replace by base_currency
                                 payment_threshold_amt oks_k_defaults.payment_threshold_amt%TYPE,
                                 interface_price_break oks_k_defaults.interface_price_break%TYPE,
                                 base_currency oks_k_defaults.base_currency%TYPE,
                                 approval_type oks_k_defaults.approval_type%TYPE,
                                 evergreen_approval_type oks_k_defaults.evergreen_approval_type%TYPE,
                                 online_approval_type oks_k_defaults.online_approval_type%TYPE,
                                 purchase_order_flag oks_k_defaults.purchase_order_flag%TYPE,
                                 credit_card_flag oks_k_defaults.credit_card_flag%TYPE,
                                 wire_flag oks_k_defaults.wire_flag%TYPE,
                                 commitment_number_flag oks_k_defaults.commitment_number_flag%TYPE,
                                 check_flag oks_k_defaults.check_flag%TYPE,
                                 period_type oks_k_defaults.period_type%TYPE,
                                 period_start oks_k_defaults.period_start%TYPE,
                                 price_uom oks_k_defaults.price_uom%TYPE,
                                 template_language oks_k_defaults.template_language%TYPE
                                 );

    G_UNEXPECTED_ERROR CONSTANT VARCHAR2(30) := 'OKS_RENEW_UTIL_UNEXP_ERR';
    G_SQLCODE_TOKEN CONSTANT VARCHAR2(30) := 'SQLcode';
    G_REQUIRED_VALUE CONSTANT VARCHAR2(30) := OKC_API.G_REQUIRED_VALUE;
    G_SQLERRM_TOKEN CONSTANT VARCHAR2(30) := 'SQLerrm';
    G_COL_NAME_TOKEN CONSTANT VARCHAR2(30) := OKC_API.G_COL_NAME_TOKEN;
    G_REQUIRED_PARAM CONSTANT VARCHAR2(30) := 'OKS_REQUIRED_VALUE';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
    G_EXCEPTION_HALT_VALIDATION EXCEPTION;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------

    G_PKG_NAME CONSTANT VARCHAR2(30) := 'OKS_RENEW_UTIL_PVT';
    G_APP_NAME CONSTANT VARCHAR2(3) := OKC_API.G_APP_NAME; --retained for old okc messages
    G_OKS_APP_NAME CONSTANT VARCHAR2(3) := 'OKS'; --all new nessages should use this
    G_MODULE       CONSTANT VARCHAR2(250) := 'oks.plsql.'||g_pkg_name||'.';

    ---------------------------------------------------------------------------
    -- global rules constants
    ---------------------------------------------------------------------------
    G_INPUT_LEVEL CONSTANT INTEGER := 0;
    G_CONTRACT_LEVEL CONSTANT INTEGER := 1;
    G_PARTY_LEVEL CONSTANT INTEGER := 2;
    G_ORG_LEVEL CONSTANT INTEGER := 3;
    G_GLOBAL_LEVEL CONSTANT INTEGER := 4;



    /*
    rewritten r12 traversal api that fetches all the rules from gcd
    following the hierarchy - input->contract->party->org->global

    it recoginzes the new attributes introduced for r12, groups
    fetches interdependent attributes from the same level and improves
    logging.

    */
    PROCEDURE GET_RENEW_RULES(x_return_status OUT NOCOPY VARCHAR2,
                              -- new parameter with default value added to follow standards
                              p_api_version IN NUMBER DEFAULT 1,
                              p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                              p_chr_id IN NUMBER,
                              p_party_id IN NUMBER,
                              p_org_id IN NUMBER,
                              p_date IN DATE DEFAULT SYSDATE,
                              p_rnrl_rec IN rnrl_rec_type,
                              x_rnrl_rec OUT NOCOPY rnrl_rec_type,
                              x_msg_count OUT NOCOPY NUMBER,
                              x_msg_data OUT NOCOPY VARCHAR2);

    PROCEDURE UPDATE_RENEWAL_STATUS (X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                                     P_CHR_ID IN NUMBER,
                                     P_RENEW_STATUS IN VARCHAR2,
                                     P_CHR_STATUS IN VARCHAR2);

    PROCEDURE GET_PAYMENT_TERMS (
                                 p_chr_id IN NUMBER DEFAULT NULL,
                                 p_party_id IN NUMBER DEFAULT NULL,
                                 p_org_id IN NUMBER DEFAULT NULL,
                                 p_effective_date IN DATE DEFAULT SYSDATE,
                                 x_pay_term_id1 OUT NOCOPY VARCHAR2,
                                 x_pay_term_id2 OUT NOCOPY VARCHAR2,
                                 x_msg_count OUT NOCOPY NUMBER,
                                 x_msg_data OUT NOCOPY VARCHAR2,
                                 x_return_status OUT NOCOPY VARCHAR2);

    PROCEDURE CAN_UPDATE_CONTRACT(p_chr_id IN NUMBER,
                                  x_can_update_yn OUT NOCOPY VARCHAR2,
                                  x_can_submit_yn OUT NOCOPY VARCHAR2,
                                  x_msg_count OUT NOCOPY NUMBER,
                                  x_msg_data OUT NOCOPY VARCHAR2,
                                  x_return_status OUT NOCOPY VARCHAR2);

    PROCEDURE GET_PERIOD_DEFAULTS(p_hdr_id IN NUMBER DEFAULT NULL,
                                  p_org_id IN VARCHAR2 DEFAULT NULL,
                                  x_period_type OUT NOCOPY VARCHAR2,
                                  x_period_start OUT NOCOPY VARCHAR2,
                                  x_price_uom OUT NOCOPY VARCHAR2,
                                  x_return_status OUT NOCOPY VARCHAR2);

    --utility method to log all the rules
    PROCEDURE LOG_RULES(p_module IN VARCHAR2,
                        p_rnrl_rec IN rnrl_rec_type);

    /* stripped down version of get_renew_rules, only gets the template set id and template lang */
    PROCEDURE GET_TEMPLATE_SET(p_api_version IN NUMBER DEFAULT 1,
                               p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                               p_chr_id IN NUMBER,
                               x_template_set_id OUT NOCOPY NUMBER,
                               x_template_lang OUT NOCOPY VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_count OUT NOCOPY NUMBER,
                               x_msg_data OUT NOCOPY VARCHAR2);

    /* utility function to get template set id */
    FUNCTION GET_TEMPLATE_SET_ID(p_chr_id IN NUMBER
                                 ) RETURN NUMBER;

    /* utility function to get template set lang */
    FUNCTION GET_TEMPLATE_LANG(p_chr_id IN NUMBER
                               ) RETURN VARCHAR2;

    /*
    Procedure evaluates the renewal rules setup in Contract or GCD to determine
    the effective renewal type for a contract.

    Parameters
        p_chr_id        :   id of the contract whose renewal type needs to be determined, mandatory
        p_amount        :   contract amount, optional, if not passed derived from p_chr_id
        p_currency_code :   contract currency, optional, if not passed derived from p_chr_id
        p_rnrl_rec      :   record containing the effective renewal rules for the contract,
                            optional, if not populated, derived from p_chr_id
        x_renewal_type  :   renewal type as determined
        x_approval_type :   approval type associated with the renewal type
        x_threshold_used :  Y|N indicating if GCD threshold where used to determine the renewal type
    */
    PROCEDURE GET_RENEWAL_TYPE
    (
     p_api_version IN NUMBER,
     p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data OUT NOCOPY VARCHAR2,
     p_chr_id IN NUMBER,
     p_amount IN NUMBER DEFAULT NULL,
     p_currency_code IN VARCHAR2 DEFAULT NULL,
     p_rnrl_rec IN rnrl_rec_type DEFAULT NULL,
     x_renewal_type OUT NOCOPY VARCHAR2,
     x_approval_type OUT NOCOPY VARCHAR2,
     x_threshold_used OUT NOCOPY VARCHAR2
    );

-- This API checks if function is accessible under current responsibility.
-- by calling fnd_function.test. This is a wrapper on fnd_function.test
-- parameters
-- function_name - function to test
-- RETURNS
-- Y if function is accessible else N
    FUNCTION get_function_access (p_function_name VARCHAR2)
        return VARCHAR2;

    PROCEDURE get_language_info
    (
     p_api_version          IN         NUMBER,
     p_init_msg_list        IN         VARCHAR2,
     p_contract_id          IN         NUMBER,
     p_document_type        IN         VARCHAR2  DEFAULT 'QUOTE',
     p_template_id          IN         NUMBER    DEFAULT NULL,
     p_template_language    IN         VARCHAR2  DEFAULT NULL,
     x_fnd_language         OUT NOCOPY VARCHAR2,
     x_fnd_iso_language     OUT NOCOPY VARCHAR2,
     x_fnd_iso_territory    OUT NOCOPY VARCHAR2,
     x_gcd_template_lang    OUT NOCOPY VARCHAR2,
     x_return_status        OUT NOCOPY VARCHAR2,
     x_msg_count            OUT NOCOPY NUMBER,
     x_msg_data             OUT NOCOPY VARCHAR2
    );

END OKS_RENEW_UTIL_PVT;

 

/
