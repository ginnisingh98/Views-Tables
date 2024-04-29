--------------------------------------------------------
--  DDL for Package OKL_INVOKE_PRICING_ENGINE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INVOKE_PRICING_ENGINE_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPSSMS.pls 115.2 2002/02/15 18:19:40 pkm ship       $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';

  G_APP_NAME		      CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_INVOKE_PRICING_ENGINE_PUB';
  G_MISS_NUM				  CONSTANT NUMBER   	:=  OKL_API.G_MISS_NUM;
  G_MISS_CHAR				  CONSTANT VARCHAR2(1)	:=  OKL_API.G_MISS_CHAR;
  G_MISS_DATE				  CONSTANT DATE   	:=  OKL_API.G_MISS_DATE;
  G_TRUE				  CONSTANT VARCHAR2(1)	:=  OKL_API.G_TRUE;
  G_FALSE				  CONSTANT VARCHAR2(1)	:=  OKL_API.G_FALSE;

  G_EXC_NAME_ERROR		CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_ERROR';
  G_EXC_NAME_UNEXP_ERROR	CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_UNEXP_ERROR';
  G_EXC_NAME_OTHERS	        CONSTANT VARCHAR2(6) := 'OTHERS';
  G_API_TYPE	CONSTANT VARCHAR(4) := '_PUB';
  G_RET_STS_SUCCESS		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_UNEXP_ERROR;

  G_EXCEPTION_HALT_PROCESSING 		EXCEPTION;
  G_EXCEPTION_ERROR			EXCEPTION;
  G_EXCEPTION_UNEXPECTED_ERROR		EXCEPTION;


---------------------------------------------------------------------------
  -- PRCODURE  generate_streams_st
---------------------------------------------------------------------------
 PROCEDURE generate_streams_st(
          p_api_version                  IN  NUMBER,
          p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
          x_return_status                OUT NOCOPY VARCHAR2,
          x_msg_count                    OUT NOCOPY NUMBER,
          x_msg_data                     OUT NOCOPY VARCHAR2,
          p_xmlg_trx_type                IN  VARCHAR2,
          p_xmlg_trx_sub_type            IN  VARCHAR2,
          p_sifv_rec                      IN  OKL_SIF_PVT.SIFV_REC_TYPE);

END OKL_INVOKE_PRICING_ENGINE_PUB;

 

/
