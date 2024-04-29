--------------------------------------------------------
--  DDL for Package OKL_INSURANCE_POLICIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INSURANCE_POLICIES_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPIPXS.pls 120.4 2007/09/13 18:34:57 smereddy ship $ */

     ---------------------------------------------------------------------------
        -- GLOBAL DATASTRUCTURES
      ---------------------------------------------------------------------------
         SUBTYPE ipyv_rec_type IS Okl_Ipy_Pvt.ipyv_rec_type;

           ------------------------------------------------------------------------------
         -- Global Variables
         G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
         G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
         G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';

          ---------------------------------------------------------------------------
          -- GLOBAL VARIABLES
          ---------------------------------------------------------------------------
          G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_INSURANCE_POLICIES_PUB';
          G_APP_NAME			CONSTANT VARCHAR2(3)   :=  'OKL';
           ---------------------------------------------------------------------------
          -- GLOBAL EXCEPTION
          ---------------------------------------------------------------------------
          G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
          ---------------------------------------------------------------------------
          -- Procedures and Functions
          ---------------------------------------------------------------------------




          PROCEDURE cancel_policy(
             p_api_version                  IN NUMBER,
             p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
             x_return_status                OUT NOCOPY VARCHAR2,
             x_msg_count                    OUT NOCOPY NUMBER,
             x_msg_data                     OUT NOCOPY VARCHAR2,
             p_ipyv_rec                  IN  ipyv_rec_type,
             x_ipyv_rec                  OUT NOCOPY  ipyv_rec_type
             );

             PROCEDURE delete_policy(
             p_api_version                  IN NUMBER,
             p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
             x_return_status                OUT NOCOPY VARCHAR2,
             x_msg_count                    OUT NOCOPY NUMBER,
             x_msg_data                     OUT NOCOPY VARCHAR2,
             p_ipyv_rec                  IN  ipyv_rec_type,
             x_ipyv_rec                  OUT NOCOPY  ipyv_rec_type
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

        PROCEDURE cancel_create_policies(
        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_khr_id                       IN  NUMBER,
        p_cancellation_date            IN  DATE,
        p_crx_code                     IN VARCHAR2 DEFAULT NULL, -- Effective Dated Term Qte changes
        p_transaction_id               IN NUMBER
        );


        -- 3945995 Start
        PROCEDURE cancel_create_policies(
        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_khr_id                       IN  NUMBER,
        p_cancellation_date            IN  DATE,
        p_crx_code                     IN VARCHAR2 DEFAULT NULL, --Effective Dated Term Qte changes
        p_transaction_id               IN NUMBER,
	x_ignore_flag                 OUT NOCOPY VARCHAR2
        );
        -- 3945995 End

        --+++++++++++++ Effective Dated Term Qte changes -- start +++++++++
        PROCEDURE check_claims(
        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        x_clm_exist                    OUT NOCOPY VARCHAR2,
        p_khr_id                       IN  NUMBER,
        p_trx_date                 IN  DATE
        );
        --+++++++++++++ Effective Dated Term Qte changes -- End +++++++++

        PROCEDURE cancel_policies(
             p_api_version                  IN NUMBER,
             p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
             x_return_status                OUT NOCOPY VARCHAR2,
             x_msg_count                    OUT NOCOPY NUMBER,
             x_msg_data                     OUT NOCOPY VARCHAR2,
             p_contract_id                  IN  NUMBER,
             p_cancellation_date            IN DATE,
              p_crx_code                     IN VARCHAR2 DEFAULT NULL ); --++++++++ Effective Dated Term Qte changes  +++++++++


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
             p_vendor_site_id      IN NUMBER DEFAULT Okc_Api.G_MISS_NUM,
             x_request_id     OUT NOCOPY NUMBER
        );

END OKL_INSURANCE_POLICIES_PUB;

/
