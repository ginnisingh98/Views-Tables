--------------------------------------------------------
--  DDL for Package OKL_VP_COPY_CONTRACT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VP_COPY_CONTRACT_PUB" AUTHID CURRENT_USER AS
/*$Header: OKLPCPXS.pls 115.5 2002/12/18 12:16:31 kjinger noship $*/

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME CONSTANT VARCHAR2(200)     := 'OKL_VP_COPY_CONTRACT_PUB';
  G_APP_NAME CONSTANT VARCHAR2(3)       :=  OKL_API.G_APP_NAME;


  G_REQUIRED_VALUE                 CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE                  CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_SQLERRM_TOKEN                  CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN                  CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_UNEXPECTED_ERROR               CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_UPPERCASE_REQUIRED             CONSTANT VARCHAR2(200) := 'OKL_UPPER_CASE_REQUIRED';
  G_COL_NAME_TOKEN                 CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;

SUBTYPE copy_header_rec_type IS OKL_VP_COPY_CONTRACT_PVT.copy_header_rec_type;

PROCEDURE copy_contract(p_api_version          IN               NUMBER,
                        p_init_msg_list        IN               VARCHAR2 DEFAULT OKL_API.G_FALSE,
                        x_return_status        OUT              NOCOPY VARCHAR2,
                        x_msg_count            OUT              NOCOPY NUMBER,
                        x_msg_data             OUT              NOCOPY VARCHAR2,
                        p_copy_rec             IN               copy_header_rec_type,
                        x_new_contract_id      OUT NOCOPY              NUMBER);

END OKL_VP_COPY_CONTRACT_PUB;

 

/
