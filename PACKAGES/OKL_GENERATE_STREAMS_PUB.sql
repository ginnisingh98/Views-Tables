--------------------------------------------------------
--  DDL for Package OKL_GENERATE_STREAMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_GENERATE_STREAMS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPGSMS.pls 115.5 2002/04/21 23:46:03 pkm ship        $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';

  G_APP_NAME		      CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_GENERATE_STREAMS_PUB';

  ---------------------------------------------------------------------------
  -- GLOBAL RETURN STATUSES
  ---------------------------------------------------------------------------
  G_RET_STS_SUCCESS		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_UNEXP_ERROR		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_ERROR;

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION  EXCEPTION;
  G_EXCEPTION_HALT_PROCESSING EXCEPTION;
  G_EXCEPTION_UNEXPECTED_ERROR	EXCEPTION;
  G_EXCEPTION_ERROR		EXCEPTION;

  G_EXC_NAME_RET_STS_ERR	CONSTANT VARCHAR(25) := 'OKL_API.G_RET_STS_ERROR';
  G_EXC_NAME_RET_STS_UNEXP_ERR	CONSTANT VARCHAR(30) := 'OKL_API.G_RET_STS_UNEXP_ERROR';
  G_EXC_NAME_OTHERS	        CONSTANT VARCHAR2(6) := 'OTHERS';
  G_API_TYPE	CONSTANT VARCHAR(4) := '_PUB';

  ---------------------------------------------------------------------------
  -- SUBTYPES
  ---------------------------------------------------------------------------
  --SUBTYPE sif_vrec_type IS OKL_STREAM_INTERFACES_PUB.sifv_rec_type;

  PROCEDURE GENERATE_STREAMS(p_api_version          IN         NUMBER
                             ,p_init_msg_list       IN         VARCHAR2
                             ,p_khr_id              IN         NUMBER
                             ,p_generation_ctx_code IN         VARCHAR2
                             ,x_trx_number          OUT NOCOPY NUMBER
                             ,x_trx_status          OUT NOCOPY VARCHAR2
                             ,x_return_status       OUT NOCOPY VARCHAR2
                             ,x_msg_count           OUT NOCOPY NUMBER
                             ,x_msg_data            OUT NOCOPY VARCHAR2);

  PROCEDURE POPULATE_HEADER_DATA(p_api_version          IN         NUMBER
                                 ,p_init_msg_list       IN         VARCHAR2
                                 ,p_khr_id              IN         NUMBER
                                 ,p_generation_ctx_code IN         VARCHAR2
                                 ,x_trx_number          OUT NOCOPY NUMBER
                                 ,x_return_status       OUT NOCOPY VARCHAR2
                                 ,x_msg_count           OUT NOCOPY NUMBER
                                 ,x_msg_data            OUT NOCOPY VARCHAR2);

  PROCEDURE INVOKE_PRICING_ENGINE(p_api_version          IN         NUMBER
                                  ,p_init_msg_list       IN         VARCHAR2
                                  ,p_trx_number          in  NUMBER
                                  ,x_trx_number          OUT NOCOPY NUMBER
                                  ,x_trx_status          OUT NOCOPY VARCHAR2
                                  ,x_return_status       OUT NOCOPY VARCHAR2
                                  ,x_msg_count           OUT NOCOPY NUMBER
                                  ,x_msg_data            OUT NOCOPY VARCHAR2);

END OKL_GENERATE_STREAMS_PUB;

 

/
