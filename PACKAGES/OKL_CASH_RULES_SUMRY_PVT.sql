--------------------------------------------------------
--  DDL for Package OKL_CASH_RULES_SUMRY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CASH_RULES_SUMRY_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRCSYS.pls 120.2 2006/07/11 09:45:04 dkagrawa noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------

  G_APP_NAME             CONSTANT   VARCHAR2(3)   :=  Okl_api.G_APP_NAME;
  G_UNEXPECTED_ERROR     CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN        CONSTANT   VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN        CONSTANT   VARCHAR2(200) := 'SQLCODE';

  G_PKG_NAME             CONSTANT   VARCHAR2(200) := 'OKL_CASH_RULES_SUMRY_PVT';
  G_COL_NAME_TOKEN       CONSTANT   VARCHAR2(200) :=  OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN   CONSTANT   VARCHAR2(200) :=  Okl_Api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN    CONSTANT   VARCHAR2(200) :=  Okl_Api.G_CHILD_TABLE_TOKEN;
  G_NO_PARENT_RECORD     CONSTANT   VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
  G_INVALID_VALUE        CONSTANT   VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_REQUIRED_VALUE	     CONSTANT   VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_EXCEPTION_HALT_VALIDATION EXCEPTION;
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

  TYPE okl_cash_rl_sumry_rec_type IS RECORD (
    ID                              OKL_CASH_ALLCTN_RLS.ID%TYPE);

  TYPE okl_cash_rl_sumry_tbl_type IS TABLE OF okl_cash_rl_sumry_rec_type INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE handle_cash_rl_sumry(  p_api_version	 IN	  NUMBER
				                  ,p_init_msg_list   IN	  VARCHAR2 DEFAULT Okc_Api.G_FALSE
				                  ,x_return_status   OUT  NOCOPY VARCHAR2
				                  ,x_msg_count	     OUT  NOCOPY NUMBER
				                  ,x_msg_data	     OUT  NOCOPY VARCHAR2
                                  ,p_cash_rl_tbl     IN   okl_cash_rl_sumry_tbl_type
							    );


END OKL_CASH_RULES_SUMRY_PVT;

/
