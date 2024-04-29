--------------------------------------------------------
--  DDL for Package OKL_CREDIT_MGNT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CREDIT_MGNT_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPCMTS.pls 115.1 2003/02/05 18:32:21 rgalipo noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXP_ERROR';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'SQLCODE';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_PKG_NAME                    CONSTANT VARCHAR2(200) := 'OKL_CREDIT_MGNT_PUB';
  G_APP_NAME                    CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_API_TYPE                    CONSTANT   VARCHAR2(4) := '_PVT';
  G_API_VERSION                 CONSTANT   NUMBER      := 1;

  G_COMMIT                      CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;
  G_INIT_MSG_LIST               CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;
  G_VALIDATION_LEVEL            CONSTANT   NUMBER      := FND_API.G_VALID_LEVEL_FULL;

  G_EXC_NAME_ERROR              CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_ERROR';
  G_EXC_NAME_UNEXP_ERROR        CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_UNEXP_ERROR';
  G_EXC_NAME_OTHERS	           CONSTANT VARCHAR2(6)  := 'OTHERS';

  G_RET_STS_SUCCESS             CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR               CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR	        CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_UNEXP_ERROR;
  G_EXCEPTION_HALT_VALIDATION   EXCEPTION;
  G_EXCEPTION_HALT_PROCESSING   EXCEPTION;
  G_EXCEPTION_ERROR             EXCEPTION;
  G_EXCEPTION_UNEXPECTED_ERROR  EXCEPTION;

  PROCEDURE submit_credit_request
                    (p_api_version                IN  NUMBER
                    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
                    ,x_return_status              OUT NOCOPY VARCHAR2
                    ,x_msg_count                  OUT NOCOPY NUMBER
                    ,x_msg_data                   OUT NOCOPY VARCHAR2
                    ,p_contract_id                IN  NUMBER
                    ,p_review_type                IN  VARCHAR2  -- application purpose
                    ,p_credit_classification      IN  VARCHAR2
                    ,p_requested_amount           IN  NUMBER
                    ,p_contact_party_id           IN  NUMBER
                    ,p_notes                      IN  VARCHAR2
                    ,p_chr_rec                    IN  okl_credit_mgnt_pvt.l_chr_rec
                    );

  PROCEDURE compile_credit_request
                    (p_api_version                IN  NUMBER
                    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
                    ,x_return_status              OUT NOCOPY VARCHAR2
                    ,x_msg_count                  OUT NOCOPY NUMBER
                    ,x_msg_data                   OUT NOCOPY VARCHAR2
                    ,p_contract_id                IN  NUMBER
                    ,x_chr_rec                    OUT NOCOPY okl_credit_mgnt_pvt.l_chr_rec
                    );


END OKL_CREDIT_MGNT_PUB;

 

/
