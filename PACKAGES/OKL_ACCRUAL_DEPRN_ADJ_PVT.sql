--------------------------------------------------------
--  DDL for Package OKL_ACCRUAL_DEPRN_ADJ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ACCRUAL_DEPRN_ADJ_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRADAS.pls 115.4 2004/02/19 01:22:23 sgiyer noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------


  TYPE asset_deprn_rec_type IS RECORD
      (category_name       VARCHAR2(2000),
	   period_name         VARCHAR2(2000),
	   deprn_amount        NUMBER);


  TYPE asset_deprn_tbl_type IS TABLE OF asset_deprn_rec_type INDEX BY BINARY_INTEGER;


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
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_ACCRUAL_DEPR_ADJ_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  FUNCTION get_period_name(p_date IN DATE) RETURN VARCHAR2;

  FUNCTION get_category_name(p_category_id IN NUMBER) RETURN VARCHAR2;

  FUNCTION SUBMIT_DEPRN_ADJUSTMENT(
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    p_api_version IN NUMBER,
    p_batch_name IN VARCHAR2,
    p_date_from IN DATE,
    p_date_to IN DATE ) RETURN NUMBER;


  PROCEDURE ADJUST_DEPRECIATION (errbuf OUT NOCOPY VARCHAR2
                                ,retcode OUT NOCOPY NUMBER
                                ,p_batch_name IN VARCHAR2
							    ,p_period_from IN VARCHAR2
							    ,p_period_to IN VARCHAR2);


END OKL_ACCRUAL_DEPRN_ADJ_PVT;

 

/
