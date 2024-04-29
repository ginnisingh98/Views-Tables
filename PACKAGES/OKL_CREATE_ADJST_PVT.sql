--------------------------------------------------------
--  DDL for Package OKL_CREATE_ADJST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CREATE_ADJST_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLROCAS.pls 120.1.12010000.2 2009/08/06 08:43:34 nikshah ship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

  subtype ajlv_rec_type is okl_ajl_pvt.ajlv_rec_type;
  subtype adjv_rec_type is okl_adj_pvt.adjv_rec_type;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------

  G_APP_NAME             CONSTANT   VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_UNEXPECTED_ERROR     CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN        CONSTANT   VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN        CONSTANT   VARCHAR2(200) := 'SQLCODE';

  G_PKG_NAME             CONSTANT   VARCHAR2(200) := 'OKL_CREATE_ADJST_PVT';
  G_COL_NAME_TOKEN       CONSTANT   VARCHAR2(200) :=  OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN   CONSTANT   VARCHAR2(200) :=  Okl_Api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN    CONSTANT   VARCHAR2(200) :=  Okl_Api.G_CHILD_TABLE_TOKEN;
  G_NO_PARENT_RECORD     CONSTANT   VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
  G_INVALID_VALUE        CONSTANT   VARCHAR2(200) :=  OKC_API.G_INVALID_VALUE;
  G_REQUIRED_VALUE	     CONSTANT   VARCHAR2(200) :=  OKC_API.G_REQUIRED_VALUE;
  G_NO                   CONSTANT   VARCHAR2(1)   := 'N';
  G_EXCEPTION_HALT_VALIDATION EXCEPTION;


   PROCEDURE create_adjustments     ( p_api_version	        IN  NUMBER
  				                           ,p_init_msg_list       IN	VARCHAR2 DEFAULT OKL_API.G_FALSE
                                     ,p_psl_id              IN  NUMBER   DEFAULT NULL
                                     ,p_commit_flag         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
                                     ,p_chk_approval_limits IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
                                     ,x_return_status       OUT NOCOPY VARCHAR2
                                     ,x_msg_count	          OUT NOCOPY NUMBER
                                     ,x_msg_data	          OUT NOCOPY VARCHAR2
                                     ,x_new_adj_id          OUT NOCOPY NUMBER --Will be used only for IEX call
                                    );

   PROCEDURE iex_create_adjustments ( p_api_version	        IN  NUMBER
  				                     ,p_init_msg_list       IN	VARCHAR2 DEFAULT OKL_API.G_FALSE
                                     ,p_commit_flag         IN  VARCHAR2 DEFAULT OKL_API.G_TRUE
                                     ,p_psl_id              IN  NUMBER
                                     ,p_chk_approval_limits IN  VARCHAR2 DEFAULT OKL_API.G_TRUE
                                     ,x_new_adj_id          OUT NOCOPY NUMBER
                                     ,x_return_status       OUT NOCOPY VARCHAR2
                                     ,x_msg_count	        OUT NOCOPY NUMBER
                                     ,x_msg_data	        OUT NOCOPY VARCHAR2
                                    );


END OKL_CREATE_ADJST_PVT;

/
