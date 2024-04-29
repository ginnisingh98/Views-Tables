--------------------------------------------------------
--  DDL for Package OKL_MULTI_GAAP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_MULTI_GAAP_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRGAPS.pls 120.5 2006/07/11 09:46:31 dkagrawa noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE ae_lines_rec_type IS RECORD (ccid OKL_AE_TMPT_LNES.code_combination_id%TYPE,
                                    line_type OKL_AE_TMPT_LNES.ae_line_type%TYPE,
                                    crd_code OKL_AE_TMPT_LNES.crd_code%TYPE);

  TYPE asset_deprn_rec_type IS RECORD
      (category_name       VARCHAR2(2000),
	   accrual_activity    OKL_TRX_CONTRACTS.accrual_activity%TYPE,
	   deprn_amount        NUMBER);

  TYPE rep_prd_summary_rec_type IS RECORD
      (product_name OKL_PRODUCTS_V.name%TYPE,
       stream_type OKL_STRM_TYPE_V.name%TYPE,
       currency_code OKL_K_HEADERS_FULL_V.currency_code%TYPE,
	   accrual_activity OKL_TRX_CONTRACTS.accrual_activity%TYPE,
       total_amount NUMBER);

  TYPE asset_deprn_tbl_type IS TABLE OF asset_deprn_rec_type INDEX BY BINARY_INTEGER;

  TYPE ae_lines_tbl_type IS TABLE OF ae_lines_rec_type INDEX BY BINARY_INTEGER;

  TYPE rep_prd_summary_tbl_type IS TABLE OF rep_prd_summary_rec_type INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_COL_NAME_TOKEN          CONSTANT  VARCHAR2(2000) := OKL_API.G_COL_NAME_TOKEN;
  G_UNEXPECTED_ERROR        CONSTANT  VARCHAR2(2000) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN           CONSTANT  VARCHAR2(2000) := 'SQLerrm';
  G_SQLCODE_TOKEN           CONSTANT  VARCHAR2(2000) := 'SQLcode';
  G_REQUIRED_VALUE          CONSTANT  VARCHAR2(2000) := 'OKL_REQUIRED_VALUE';
  G_NO_MATCHING_RECORD      CONSTANT  VARCHAR2(2000) := 'OKL_LLA_NO_MATCHING_RECORD';
  G_CONTRACT_NUMBER_TOKEN    CONSTANT VARCHAR2(2000) := 'CONTRACT_NUMBER';
  G_INVALID_VALUE           CONSTANT  VARCHAR2(2000) := 'OKL_CONTRACTS_INVALID_VALUE';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------


  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_MULTI_GAAP_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  FUNCTION SUBMIT_MULTI_GAAP(
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    p_api_version IN NUMBER,
    p_date_from IN DATE,
    p_date_to IN DATE,
    p_batch_name IN VARCHAR2 ) RETURN NUMBER;

  FUNCTION CHECK_MULTI_GAAP(p_khr_id IN NUMBER) RETURN VARCHAR2;


  PROCEDURE MULTI_GAAP_SUPPORT(errbuf OUT NOCOPY VARCHAR2
                              ,retcode OUT NOCOPY NUMBER
                              ,p_period_from IN VARCHAR2
                              ,p_period_to IN VARCHAR2
                              ,p_batch_name IN VARCHAR2);

  FUNCTION get_category_name(p_category_id IN NUMBER) RETURN VARCHAR2;

END OKL_MULTI_GAAP_PVT;

/
