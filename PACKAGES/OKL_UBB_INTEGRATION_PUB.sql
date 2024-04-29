--------------------------------------------------------
--  DDL for Package OKL_UBB_INTEGRATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_UBB_INTEGRATION_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPUBIS.pls 115.1 2002/05/10 12:12:32 pkm ship     $*/

  -- GLOBAL VARIABLES

  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_UBB_INTEGRATION_PUB';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_API_TYPE		        CONSTANT VARCHAR2(4)   := '_PUB';

  PROCEDURE create_ubb_contract(
                                p_api_version    IN  NUMBER,
                                p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                x_return_status  OUT NOCOPY VARCHAR2,
                                x_msg_count      OUT NOCOPY NUMBER,
                                x_msg_data       OUT NOCOPY VARCHAR2,
                                p_chr_id         IN  OKC_K_HEADERS_V.ID%TYPE,
                                x_chr_id         OUT NOCOPY OKC_K_HEADERS_V.ID%TYPE
                               );

END OKL_UBB_INTEGRATION_PUB;

 

/
