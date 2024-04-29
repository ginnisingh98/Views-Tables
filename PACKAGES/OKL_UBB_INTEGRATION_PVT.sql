--------------------------------------------------------
--  DDL for Package OKL_UBB_INTEGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_UBB_INTEGRATION_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRUBIS.pls 115.1 2002/05/10 12:13:31 pkm ship     $*/

  -- GLOBAL VARIABLES

  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_UBB_INTEGRATION_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_API_TYPE		        CONSTANT VARCHAR2(4) := '_PVT';

  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(1000) := 'OKL_UNEXPECTED_ERROR';
  G_OKL_NO_TOP_LINE             CONSTANT VARCHAR2(1000) := 'OKL_NO_TOP_LINE';
  G_OKL_NO_USAGE_LINE           CONSTANT VARCHAR2(1000) := 'OKL_NO_USAGE_LINE';
  G_OKL_NO_LINK_ASSET_LINE      CONSTANT VARCHAR2(1000) := 'OKL_NO_LINK_ASSET_LINE';
  G_OKL_NO_IB_LINE              CONSTANT VARCHAR2(1000) := 'OKL_NO_IB_LINE';
  G_OKL_NO_COUNTER_INSTANCE     CONSTANT VARCHAR2(1000) := 'OKL_NO_COUNTER_INSTANCE_LINE';
  G_OKL_NO_CONTRACT_HEADER      CONSTANT VARCHAR2(1000) := 'OKL_NO_CONTRACT_HEADER';
  G_OKL_RULE_ERROR              CONSTANT VARCHAR2(1000) := 'OKL_RULE_ERROR';
  G_OKL_PARTY_ROLE_ERROR        CONSTANT VARCHAR2(1000) := 'OKL_PARTY_ROLE_ERROR';
  G_OKL_NO_ITEM_LINK            CONSTANT VARCHAR2(1000) := 'OKL_NO_ITEM_LINK';
  G_INVALID_VALUE               CONSTANT VARCHAR2(1000) := 'OKL_INVALID_VALUE';

  PROCEDURE create_ubb_contract(
                                p_api_version    IN  NUMBER,
                                p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                x_return_status  OUT NOCOPY VARCHAR2,
                                x_msg_count      OUT NOCOPY NUMBER,
                                x_msg_data       OUT NOCOPY VARCHAR2,
                                p_chr_id         IN  OKC_K_HEADERS_V.ID%TYPE,
                                x_chr_id         OUT NOCOPY OKC_K_HEADERS_V.ID%TYPE
                               );

  PROCEDURE link_oks_header(
                            x_return_status     OUT NOCOPY VARCHAR2,
                            x_msg_count         OUT NOCOPY NUMBER,
                            x_msg_data          OUT NOCOPY VARCHAR2,
                            p_okl_header_id     IN  OKC_K_HEADERS_V.ID%TYPE,
                            p_oks_header_id     IN  OKC_K_HEADERS_V.ID%TYPE
                           );

  PROCEDURE link_oks_line(
                          x_return_status     OUT NOCOPY VARCHAR2,
                          x_msg_count         OUT NOCOPY NUMBER,
                          x_msg_data          OUT NOCOPY VARCHAR2,
                          p_okl_header_id     IN  OKC_K_HEADERS_V.ID%TYPE,
                          p_okl_usage_line_id IN  OKC_K_LINES_V.ID%TYPE,
                          p_oks_usage_line_id IN  OKC_K_LINES_V.ID%TYPE
                         );

END OKL_UBB_INTEGRATION_PVT;

 

/
