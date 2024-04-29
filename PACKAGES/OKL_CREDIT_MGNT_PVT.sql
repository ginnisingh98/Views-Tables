--------------------------------------------------------
--  DDL for Package OKL_CREDIT_MGNT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CREDIT_MGNT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRCMTS.pls 115.1 2003/02/04 23:34:56 rgalipo noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR           CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXP_ERROR';
  G_SQLCODE_TOKEN              CONSTANT VARCHAR2(200) := 'SQLCODE';
  G_SQLERRM_TOKEN              CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_PKG_NAME                   CONSTANT VARCHAR2(200) := 'OKL_CREDIT_MANGEMENT_PVT';
  G_APP_NAME                   CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

  G_API_TYPE                    CONSTANT   VARCHAR2(4)   := '_PVT';
  G_API_VERSION                 CONSTANT   NUMBER        := 1;

  G_COMMIT                      CONSTANT   VARCHAR2(1)   := FND_API.G_TRUE;
  G_INIT_MSG_LIST               CONSTANT   VARCHAR2(1)   := FND_API.G_TRUE;
  G_VALIDATION_LEVEL            CONSTANT   NUMBER        := FND_API.G_VALID_LEVEL_FULL;

  G_EXC_NAME_ERROR		        CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_ERROR';
  G_EXC_NAME_UNEXP_ERROR	     CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_UNEXP_ERROR';
  G_EXC_NAME_OTHERS	           CONSTANT VARCHAR2(6) := 'OTHERS';

  G_RET_STS_SUCCESS             CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR               CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR	        CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_UNEXP_ERROR;
  G_EXCEPTION_HALT_VALIDATION   EXCEPTION;
  G_EXCEPTION_HALT_PROCESSING   EXCEPTION;
  G_EXCEPTION_ERROR             EXCEPTION;
  G_EXCEPTION_UNEXPECTED_ERROR  EXCEPTION;

  -- Records --
  TYPE rule_amounts_rec IS RECORD
   (contract_id              NUMBER
   ,service_amount           NUMBER
   ,fee_amount               NUMBER
   );

  TYPE l_chr_rec IS RECORD
      (party_id          NUMBER
      ,cust_acct_id      NUMBER
      ,cust_acct_site_id NUMBER
      ,site_use_id       NUMBER
      ,contract_id       NUMBER
      ,contract_number   VARCHAR2(120)
      ,credit_khr_id     NUMBER
      ,currency          VARCHAR2(15)
      ,txn_amount        NUMBER
      ,requested_amount  NUMBER
      ,term              NUMBER
      ,party_contact_id  NUMBER
      ,org_id            NUMBER
      );


  PROCEDURE submit_credit_request
                    (p_api_version                  IN  NUMBER
                    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
                    ,x_return_status                OUT NOCOPY VARCHAR2
                    ,x_msg_count                    OUT NOCOPY NUMBER
                    ,x_msg_data                     OUT NOCOPY VARCHAR2
                    ,p_contract_id                  IN  NUMBER
                    ,p_review_type                  IN  VARCHAR2  -- application purpose
                    ,p_credit_classification        IN  VARCHAR2
                    ,p_requested_amount             IN  NUMBER
                    ,p_contact_party_id             IN  NUMBER
                    ,p_notes                        IN  VARCHAR2
                    ,p_chr_rec                      IN  l_chr_rec
                    );


/* using okl_so_credit_request_pub to get event
  -- called by workflow business event subscription.
  FUNCTION credit_request_outcome
                    (p_subscription_guid  IN  RAW
                    ,p_event              OUT WF_EVENT_T
                    ) RETURN VARCHAR2;
*/

  PROCEDURE compile_credit_request
                    (p_api_version                  IN  NUMBER
                    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
                    ,x_return_status                OUT NOCOPY VARCHAR2
                    ,x_msg_count                    OUT NOCOPY NUMBER
                    ,x_msg_data                     OUT NOCOPY VARCHAR2
                    ,p_contract_id                  IN  NUMBER
                    ,x_chr_rec                      OUT NOCOPY l_chr_rec
                    );


END OKL_CREDIT_MGNT_PVT;

 

/
