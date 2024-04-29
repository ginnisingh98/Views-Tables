--------------------------------------------------------
--  DDL for Package OKL_INSURANCE_POLICIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INSURANCE_POLICIES_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRIPXS.pls 120.6 2007/09/13 18:31:52 smereddy ship $ */
  ---------------------------------------------------------------------------
    -- GLOBAL DATASTRUCTURES
    ---------------------------------------------------------------------------
    SUBTYPE ipyv_rec_type IS Okl_Ipy_Pvt.ipyv_rec_type;
    SUBTYPE inav_rec_type IS Okl_Ina_Pvt.inav_rec_type;

 -- Added for Credit Memo Bug 3976894
    SUBTYPE taiv_rec_type   IS    okl_trx_ar_invoices_pub.taiv_rec_type;
    SUBTYPE tilv_rec_type   IS    okl_txl_ar_inv_lns_pub.tilv_rec_type ;
    SUBTYPE bpd_acc_rec_type IS   Okl_Acc_Call_Pub.bpd_acc_rec_type;
     ---------------------------------------------------------------------------
     -- GLOBAL MESSAGE CONSTANTS
     ---------------------------------------------------------------------------
     G_FND_APP			CONSTANT VARCHAR2(200) := Okc_Api.G_FND_APP;
     G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
     G_INVALID_VALUE		CONSTANT VARCHAR2(200) := Okc_Api.G_INVALID_VALUE;
     G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := 'COL_NAME';
     G_COL_VALUE_TOKEN		CONSTANT VARCHAR2(200) := 'COL_VALUE';
     G_COL_NAME1_TOKEN		CONSTANT VARCHAR2(200) := 'COL_NAME1';
     G_COL_NAME2_TOKEN		CONSTANT VARCHAR2(200) := 'COL_NAME2';
     G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := 'PARENT_TABLE';
     G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
     G_NO_PARENT_RECORD            CONSTANT VARCHAR2(200) := 'OKL_PARENT_RECORD';
     G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
     G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
     G_INVALID_POLICY               CONSTANT VARCHAR2(200) := 'OKL_POLICY_INVALID';
     G_INVALID_QUOTE_TYPE         CONSTANT VARCHAR2(200) := 'OKL_QUOTE_TYPE_INVALID';
     G_EXPIRED_QUOTE              CONSTANT VARCHAR2(200) := 'OKL_QUOTE_EXPIRED';
     G_NO_STREAM_REC_FOUND        CONSTANT VARCHAR2(200) := 'OKL_NO_STREAM_REC_FOUND';
     G_INVALID_CONTRACT           CONSTANT VARCHAR2(200) := 'OKL_INVALID_CONTRACT';
     G_K_NOT_ACTIVE               CONSTANT VARCHAR2(200) := 'OKL_K_NOT_ACTIVE';
     G_INVALID_FOR_ACTIVE_TYPE     CONSTANT VARCHAR2(200) := 'OKL_INVALID_FOR_ACTIVE_TYPE';
     G_INVALID_FOR_ACTIVE_STATUS     CONSTANT VARCHAR2(200) := 'OKL_INVALID_FOR_ACTIVE_STATUS';
     G_STREAM_ALREADY_ACTIVE      CONSTANT VARCHAR2(200) := 'OKL_STREAM_ALREADY_ACTIVE';
     G_INVALID_CONTRACT_LINE     CONSTANT VARCHAR2(200) := 'OKL_INVALID_CONTRACT_LINE';
     G_FND_LOOKUP_PAYMENT_FREQ   CONSTANT VARCHAR2(200) := 'OKL_INS_PAYMENT_FREQUENCY';
     G_NO_CAPITAL_AMOUNT         CONSTANT VARCHAR2(200) := 'OKL_NO_CAPITAL_AMOUNT';
     G_NO_SYSTEM_PROFILE         CONSTANT VARCHAR2(200) := 'OKL_NO_SYSTEM_PROFILE';
     G_SYS_PROFILE_NAME          CONSTANT VARCHAR2(200) := 'OKL_SYS_PROFILE_NAME';
     G_NO_INSURANCE              CONSTANT VARCHAR2(200) := 'OKL_NO_INSURANCE';
     G_NO_K_TERM                  CONSTANT VARCHAR2(200) := 'OKL_NO_K_TERM';
     G_NO_K_OEC                 CONSTANT VARCHAR2(200) := 'OKL_NO_K_OEC';
     G_NO_OEC                   CONSTANT VARCHAR2(200) := 'OKL_NO_OEC';
     G_NO_KLE                   CONSTANT VARCHAR2(200) := 'OKL_NO_KLE';
     G_NO_INS_CLASS             CONSTANT VARCHAR2(200) := 'OKL_NO_INS_CLASS';
     G_FORMULA_REFUND_CALC      CONSTANT VARCHAR2(200) := 'INSURANCE REFUND';
     G_NO_TRX                   CONSTANT  VARCHAR2(200) := 'OKL_NO_TRANSACTION_TYPE';
     G_NO_STREAM               CONSTANT VARCHAR2(200) := 'OKL_NO_STREAM_TYPE';
     G_NO_THIRD_PARTY         CONSTANT VARCHAR2(200) := 'OKL_NO_THIRD_PARTY';
     G_FORMULA_PARAM_1          CONSTANT VARCHAR2(30)  := 'CANCELLATION DATE'; --++ Eff Dated Term Change +++-----
     G_FORMULA_PARAM_2          CONSTANT VARCHAR2(30)  := 'CANCELLATION REASON'; --++ Eff Dated Term Change +++-----
     G_PURPOSE_TOKEN            CONSTANT VARCHAR2(30)  := 'PURPOSE'; -- bug 4024785
     ---------------------------------------------------------------------------
     -- GLOBAL VARIABLES
     ---------------------------------------------------------------------------
     G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_INSURANCE_POLICIES_PVT';
     G_APP_NAME			CONSTANT VARCHAR2(3)   :=  'OKL';
      ---------------------------------------------------------------------------
     -- GLOBAL EXCEPTION
     ---------------------------------------------------------------------------
     G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
     ---------------------------------------------------------------------------
     -- Procedures and Functions
     ---------------------------------------------------------------------------

  -- Added for Credit Memo Bug 3976894

   PROCEDURE ON_ACCOUNT_CREDIT_MEMO
          (
          p_api_version                  IN NUMBER,
          p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
          p_try_id                       IN NUMBER,
          p_khr_id                       IN NUMBER,
          p_kle_id                       IN NUMBER,
          p_ipy_id                       IN NUMBER  DEFAULT  Okc_Api.G_MISS_NUM ,
          p_credit_date                  IN DATE,
          p_credit_amount                IN NUMBER,
          p_credit_sty_id                IN NUMBER,
          x_return_status                OUT NOCOPY VARCHAR2,
          x_msg_count                    OUT NOCOPY NUMBER,
          x_msg_data                     OUT NOCOPY VARCHAR2,
          x_tai_id                       OUT NOCOPY  NUMBER

          );

     PROCEDURE cancel_policy(
        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_ipyv_rec                  IN  ipyv_rec_type,
        x_ipyv_rec                  OUT NOCOPY  ipyv_rec_type
        );

--Bug#5955320
    PROCEDURE cancel_create_policies(
        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_khr_id                       IN  NUMBER,
        p_cancellation_date            IN  DATE,
        p_crx_code                     IN  VARCHAR2 DEFAULT NULL, --+++++++++++++ Effective Dated Term Qte changes -- start +++++++++
        p_transaction_id               IN NUMBER,
        x_ignore_flag                  OUT NOCOPY VARCHAR2 -- 3945995
        );


      --+++++++++++++ Effective Dated Term Qte changes -- start +++++++++
   PROCEDURE check_claims(
        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        x_clm_exist                    OUT NOCOPY VARCHAR2,
        p_khr_id                       IN  NUMBER,
        p_trx_date                     IN  DATE
        );
    --+++++++++++++ Effective Dated Term Qte changes -- End +++++++++


        PROCEDURE delete_policy(
        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_ipyv_rec                  IN  ipyv_rec_type,
        x_ipyv_rec                  OUT NOCOPY  ipyv_rec_type
        );




     PROCEDURE   Inactivate_open_items(

        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_contract_id                  IN  NUMBER,
        p_contract_line            IN NUMBER,
        p_policy_status            IN VARCHAR2
        );


     PROCEDURE cancel_policies(
        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_contract_id                  IN  NUMBER,
        p_cancellation_date            IN DATE
        ,p_crx_code                     IN VARCHAR2 DEFAULT NULL);--++++++++ Effective Dated Term Qte changes  +++++++++

        PROCEDURE get_refund(
        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_policy_id                  IN  NUMBER,
        p_cancellation_date          IN DATE DEFAULT NULL,--++ Eff Dated Term change +++ ---
        p_crx_code                 IN VARCHAR2 DEFAULT NULL, ---+++ Eff Dated TErmination +++----
        x_refund_amount            OUT NOCOPY NUMBER
        );

        PROCEDURE pay_cust_refund(
        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_contract_id                  IN  NUMBER,
        p_contract_line            IN NUMBER ,
        p_cancellation_date        IN DATE DEFAULT NULL, ---+++ Eff Dated TErmination +++----
        p_crx_code                 IN VARCHAR2 DEFAULT NULL, ---+++ Eff Dated TErmination +++----

        x_refund_amount           OUT NOCOPY NUMBER
        );

   PROCEDURE   insert_ap_request(
        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_tap_id          IN NUMBER,
        p_credit_amount   IN NUMBER,
        p_credit_sty_id   IN NUMBER,
        p_khr_id         IN NUMBER ,
        p_kle_id         IN NUMBER,
        p_invoice_date   IN DATE,
        p_trx_id         IN NUMBER
   );

   PROCEDURE   insert_ap_request(
        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_tap_id          IN NUMBER,
        p_credit_amount   IN NUMBER,
        p_credit_sty_id   IN NUMBER,
        p_khr_id         IN NUMBER ,
        p_kle_id         IN NUMBER,
        p_invoice_date   IN DATE,
        p_trx_id         IN NUMBER,
        p_vendor_site_id      IN NUMBER ,
        x_request_id     OUT NOCOPY NUMBER
   );



   PROCEDURE OKL_INSURANCE_PARTY_MERGE(
       p_entity_name                IN   VARCHAR2,
       p_from_id                    IN   NUMBER,
       x_to_id                      OUT NOCOPY  NUMBER,
       p_from_fk_id                 IN   NUMBER,
       p_to_fk_id                   IN   NUMBER,
       p_parent_entity_name         IN   VARCHAR2,
       p_batch_id                   IN   NUMBER,
       p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2
    );


    PROCEDURE OKL_INSURANCE_PARTY_SITE_MERGE(
               p_entity_name                IN   VARCHAR2,
               p_from_id                    IN   NUMBER,
               x_to_id                      OUT  NOCOPY NUMBER,
               p_from_fk_id                 IN   NUMBER,
               p_to_fk_id                   IN   NUMBER,
               p_parent_entity_name         IN   VARCHAR2,
               p_batch_id                   IN   NUMBER,
               p_batch_party_id             IN   NUMBER,
            x_return_status              OUT  NOCOPY VARCHAR2
    );


    PROCEDURE OKL_INSURANCE_AGENT_MERGE(
               p_entity_name                IN   VARCHAR2,
               p_from_id                    IN   NUMBER,
               x_to_id                      OUT  NOCOPY NUMBER,
               p_from_fk_id                 IN   NUMBER,
               p_to_fk_id                   IN   NUMBER,
               p_parent_entity_name         IN   VARCHAR2,
               p_batch_id                   IN   NUMBER,
               p_batch_party_id             IN   NUMBER,
            x_return_status              OUT  NOCOPY VARCHAR2
    );





    PROCEDURE OKL_INSURANCE_AGENT_SITE_MERGE(
           p_entity_name                IN   VARCHAR2,
           p_from_id                    IN   NUMBER,
           x_to_id                      OUT NOCOPY  NUMBER,
           p_from_fk_id                 IN   NUMBER,
           p_to_fk_id                   IN   NUMBER,
           p_parent_entity_name         IN   VARCHAR2,
           p_batch_id                   IN   NUMBER,
           p_batch_party_id             IN   NUMBER,
        x_return_status              OUT NOCOPY VARCHAR2
    );






END OKL_INSURANCE_POLICIES_PVT;

/
