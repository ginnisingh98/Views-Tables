--------------------------------------------------------
--  DDL for Package OKL_VP_TERMINATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VP_TERMINATE_PUB" AUTHID CURRENT_USER AS
/*$Header: OKLPTERS.pls 115.3 2002/03/21 18:03:59 pkm ship       $*/

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME CONSTANT VARCHAR2(200)     := 'OKL_VP_TERMINATE_PUB';
  G_APP_NAME CONSTANT VARCHAR2(3)       :=  OKL_API.G_APP_NAME;


  G_REQUIRED_VALUE                 CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE                  CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_SQLERRM_TOKEN                  CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN                  CONSTANT VARCHAR2(200) := 'OKL_SQLcode';
  G_UNEXPECTED_ERROR               CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_UPPERCASE_REQUIRED             CONSTANT VARCHAR2(200) := 'OKL_UPPER_CASE_REQUIRED';
  G_COL_NAME_TOKEN                 CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;

SUBTYPE terminate_header_rec_type is okl_vp_terminate_pvt.terminate_header_rec_type;

PROCEDURE terminate_contract(p_api_version         IN               NUMBER,
                            p_init_msg_list        IN               VARCHAR2 DEFAULT OKL_API.G_FALSE,
                            x_return_status        OUT              NOCOPY VARCHAR2,
                            x_msg_count            OUT              NOCOPY NUMBER,
                            x_msg_data             OUT              NOCOPY VARCHAR2,
                            p_ter_header_rec       IN               terminate_header_rec_type);

END OKL_VP_TERMINATE_PUB;

 

/
