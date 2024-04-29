--------------------------------------------------------
--  DDL for Package OKS_RENEW_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_RENEW_UTIL_PUB" AUTHID CURRENT_USER AS
/* $Header: OKSPRUTS.pls 120.3 2005/07/22 11:53:22 anjkumar noship $*/

    SUBTYPE Rnrl_rec_type IS OKS_RENEW_UTIL_PVT.Rnrl_rec_type;

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGES
  ---------------------------------------------------------------------------
    G_UNEXPECTED_ERROR CONSTANT VARCHAR2(30) := 'OKS_RENEW_UTIL_UNEXP_ERR';
    G_SQLCODE_TOKEN CONSTANT VARCHAR2(30) := 'SQLcode';
    G_REQUIRED_VALUE CONSTANT VARCHAR2(30) := OKC_API.G_REQUIRED_VALUE;
    G_SQLERRM_TOKEN CONSTANT VARCHAR2(30) := 'SQLerrm';
    G_COL_NAME_TOKEN CONSTANT VARCHAR2(30) := OKC_API.G_COL_NAME_TOKEN;
    G_FND_APP CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
    G_INVALID_VALUE CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
    G_EXCEPTION_HALT_VALIDATION EXCEPTION;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
    G_PKG_NAME CONSTANT VARCHAR2(30) := 'OKS_RENEW_UTIL_PUB';
    G_APP_NAME CONSTANT VARCHAR2(3) := OKC_API.G_APP_NAME;
    G_OKS_APP_NAME CONSTANT VARCHAR2(3) := 'OKS'; --all new nessages should use this

    G_RNRL_REC Rnrl_rec_type;

    PROCEDURE GET_RENEW_RULES(p_api_version IN NUMBER,
                              p_init_msg_list IN VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count OUT NOCOPY NUMBER,
                              x_msg_data OUT NOCOPY VARCHAR2,
                              P_Chr_Id IN NUMBER,
                              P_PARTY_ID IN NUMBER,
                              P_ORG_ID IN NUMBER,
                              P_Date IN DATE DEFAULT SYSDATE,
                              P_RNRL_Rec IN RNRL_REC_TYPE,
                              X_RNRL_Rec OUT NOCOPY RNRL_REC_TYPE);

    PROCEDURE UPDATE_RENEWAL_STATUS (p_api_version IN NUMBER,
                                     p_init_msg_list IN VARCHAR2,
                                     x_return_status OUT NOCOPY VARCHAR2,
                                     x_msg_count OUT NOCOPY NUMBER,
                                     x_msg_data OUT NOCOPY VARCHAR2,
                                     P_CHR_ID IN NUMBER,
                                     P_RENEW_STATUS IN VARCHAR2,
                                     P_CHR_STATUS IN VARCHAR2);

    PROCEDURE Can_Update_Contract(p_api_version IN NUMBER,
                                  p_init_msg_list IN VARCHAR2,
                                  p_chr_id IN NUMBER,
                                  x_can_update_yn OUT NOCOPY VARCHAR2,
                                  x_can_submit_yn OUT NOCOPY VARCHAR2,
                                  x_msg_count OUT NOCOPY NUMBER,
                                  x_msg_data OUT NOCOPY VARCHAR2,
                                  x_return_status OUT NOCOPY VARCHAR2);

    -- New API to get payment terms from Global defaults
    -- ER 2532872
    PROCEDURE get_payment_terms (
                                 p_api_version IN NUMBER,
                                 p_init_msg_list IN VARCHAR2,
                                 p_chr_id IN NUMBER DEFAULT FND_API.G_MISS_NUM,
                                 p_party_id IN NUMBER DEFAULT FND_API.G_MISS_NUM,
                                 p_org_id IN NUMBER DEFAULT FND_API.G_MISS_NUM,
                                 p_effective_date IN DATE DEFAULT SYSDATE,
                                 x_pay_term_id1 OUT NOCOPY VARCHAR2,
                                 x_pay_term_id2 OUT NOCOPY VARCHAR2,
                                 x_msg_count OUT NOCOPY NUMBER,
                                 x_msg_data OUT NOCOPY VARCHAR2,
                                 x_return_status OUT NOCOPY VARCHAR2);

    PROCEDURE get_period_defaults(p_hdr_id IN NUMBER DEFAULT NULL,
                                  p_org_id IN VARCHAR2 DEFAULT NULL,
                                  x_period_type OUT NOCOPY VARCHAR2,
                                  x_period_start OUT NOCOPY VARCHAR2,
                                  x_price_uom OUT NOCOPY VARCHAR2,
                                  x_return_status OUT NOCOPY VARCHAR2);

    /* stripped down version of get_renew_rules, only gets the template set id and template lang */
    PROCEDURE get_template_set(p_api_version IN NUMBER DEFAULT 1,
                               p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                               p_chr_id IN NUMBER,
                               x_template_set_id OUT NOCOPY NUMBER,
                               x_template_lang OUT NOCOPY VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_count OUT NOCOPY NUMBER,
                               x_msg_data OUT NOCOPY VARCHAR2);

    /* utility function to get template set id */
    FUNCTION get_template_set_id(p_chr_id IN NUMBER
                                 ) RETURN NUMBER;

    /* utility function to get template set lang */
    FUNCTION get_template_lang(p_chr_id IN NUMBER
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

END OKS_RENEW_UTIL_PUB;

 

/
