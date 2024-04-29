--------------------------------------------------------
--  DDL for Package OKL_BTCH_CASH_SUMRY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_BTCH_CASH_SUMRY_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRBASS.pls 115.3 2003/11/10 23:37:47 bvaghela noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------

  G_APP_NAME             CONSTANT   VARCHAR2(3)   :=  Okl_api.G_APP_NAME;
  G_UNEXPECTED_ERROR     CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN        CONSTANT   VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN        CONSTANT   VARCHAR2(200) := 'SQLCODE';

  G_PKG_NAME             CONSTANT   VARCHAR2(200) := 'OKL_BTCH_CASH_APPLIC';
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

  TYPE okl_batch_sumry_rec_type IS RECORD (
    id                              OKL_TRX_CSH_BATCH_B.ID%TYPE,
    trx_status_code                 OKL_TRX_CSH_BATCH_B.TRX_STATUS_CODE%TYPE);

  TYPE okl_btch_sumry_tbl_type IS TABLE OF okl_batch_sumry_rec_type
        INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE handle_batch_sumry( p_api_version	   IN	NUMBER                  -- TEMPORARY SOLUTION
				               ,p_init_msg_list    IN	VARCHAR2 DEFAULT Okc_Api.G_FALSE
				               ,x_return_status    OUT  NOCOPY VARCHAR2
				               ,x_msg_count	       OUT  NOCOPY NUMBER
				               ,x_msg_data	       OUT  NOCOPY VARCHAR2
                               ,p_btch_tbl         IN   okl_btch_sumry_tbl_type
							  );


END OKL_BTCH_CASH_SUMRY_PVT;

 

/
