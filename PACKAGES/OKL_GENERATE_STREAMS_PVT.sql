--------------------------------------------------------
--  DDL for Package OKL_GENERATE_STREAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_GENERATE_STREAMS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRGSMS.pls 115.5 2002/04/21 23:46:13 pkm ship        $ */
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := Okl_Api.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okl_Api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okl_Api.G_CHILD_TABLE_TOKEN;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := Okl_Api.G_REQUIRED_VALUE;
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := Okl_Api.G_INVALID_VALUE;
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN		CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN		CONSTANT VARCHAR2(200) := 'OKL_SQLcode';

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

  ---------------------------------------------------------------------------
  -- GLOBAL NAMES
  ---------------------------------------------------------------------------
  G_PKG_NAME CONSTANT VARCHAR2(30)     := 'OKL_GENERATE_STREAMS_PVT' ;
  G_APP_NAME CONSTANT VARCHAR2(3)      :=  OKL_API.G_APP_NAME;

  ---------------------------------------------------------------------------
  -- GLOBAL CODES
  ---------------------------------------------------------------------------
  G_ORP_CODE_AUTH CONSTANT VARCHAR2(4) :=  'AUTH';
  G_ORP_CODE_RBOK CONSTANT VARCHAR2(4) :=  'RBOK';
  G_ORP_CODE_QUOT CONSTANT VARCHAR2(4) :=  'QUOT';
  G_ORP_CODE_TERM CONSTANT VARCHAR2(4) :=  'TERM';

  ---------------------------------------------------------------------------
  -- OTHER GLOBALS
  ---------------------------------------------------------------------------
  G_FALSE	                CONSTANT VARCHAR(1) := OKL_API.G_FALSE;
  G_TRUE	                CONSTANT VARCHAR(1) := OKL_API.G_TRUE;
  G_API_TYPE	                CONSTANT VARCHAR(4) := '_PVT';
  G_EXC_NAME_RET_STS_ERR	CONSTANT VARCHAR(25) := 'OKL_API.G_RET_STS_ERROR';
  G_EXC_NAME_RET_STS_UNEXP_ERR	CONSTANT VARCHAR(30) := 'OKL_API.G_RET_STS_UNEXP_ERROR';
  G_EXC_NAME_OTHERS	        CONSTANT VARCHAR2(6) := 'OTHERS';

  ---------------------------------------------------------------------------
  -- SUBTYPES
  ---------------------------------------------------------------------------
  SUBTYPE sifv_rec_type IS OKL_STREAM_INTERFACES_PUB.sifv_rec_type;


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

END OKL_GENERATE_STREAMS_PVT;

 

/
