--------------------------------------------------------
--  DDL for Package OKL_ACCRUAL_SEC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ACCRUAL_SEC_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRASCS.pls 120.5.12010000.2 2008/10/20 18:26:27 apaul ship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------


  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN		CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN		CONSTANT VARCHAR2(200) := 'OKL_SQLcode';
  G_CONTRACT_NUMBER_TOKEN CONSTANT VARCHAR2(200) := 'CONTRACT_NUMBER';

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_ACCRUAL_SEC_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  TYPE p_line_id_rec_type IS RECORD(
        id OKC_K_LINES_B.ID%TYPE);

  TYPE p_line_id_tbl_type IS TABLE OF p_line_id_rec_type
        INDEX BY BINARY_INTEGER;

  TYPE p_accrual_adjustment_rec_type IS RECORD(
        line_id OKC_K_LINES_B.ID%TYPE,
		sty_id OKL_STRM_TYPE_B.ID%TYPE,
		amount NUMBER);

  TYPE p_accrual_adjustment_tbl_type IS TABLE OF p_accrual_adjustment_rec_type
        INDEX BY BINARY_INTEGER;


  PROCEDURE CREATE_STREAMS(p_api_version    IN  NUMBER,
                           p_init_msg_list   IN  VARCHAR2,
                           x_return_status   OUT NOCOPY VARCHAR2,
                           x_msg_count       OUT NOCOPY NUMBER,
                           x_msg_data        OUT NOCOPY VARCHAR2,
					                      p_khr_id          IN NUMBER,
--sosharma added Bug 6691554, Added for generating streams on transient pool submission
                           p_mode             IN VARCHAR2 DEFAULT NULL);

  PROCEDURE CANCEL_STREAMS(p_api_version     IN  NUMBER,
                           p_init_msg_list   IN  VARCHAR2,
                           x_return_status   OUT NOCOPY VARCHAR2,
                           x_msg_count       OUT NOCOPY NUMBER,
                           x_msg_data        OUT NOCOPY VARCHAR2,
                           p_khr_id          IN NUMBER,
                           p_cancel_date     IN DATE);
/* Commented as T&A requirement changed
  PROCEDURE Create_Adjustment_Streams(
                           p_api_version     IN NUMBER
                          ,p_init_msg_list   IN VARCHAR2 DEFAULT OKL_API.G_FALSE
                          ,x_return_status   OUT NOCOPY VARCHAR2
                          ,x_msg_count       OUT NOCOPY NUMBER
                          ,x_msg_data        OUT NOCOPY VARCHAR2
                          ,p_contract_id     IN NUMBER
                          ,p_line_id_tbl     IN p_line_id_tbl_type
                          ,p_adjustment_date IN DATE);
*/
  PROCEDURE Get_Accrual_Adjustment(
                           p_api_version     IN NUMBER
                          ,p_init_msg_list   IN VARCHAR2 DEFAULT OKL_API.G_FALSE
                          ,x_return_status   OUT NOCOPY VARCHAR2
                          ,x_msg_count       OUT NOCOPY NUMBER
                          ,x_msg_data        OUT NOCOPY VARCHAR2
                          ,p_contract_id     IN NUMBER
                          ,p_line_id_tbl     IN p_line_id_tbl_type
                          ,p_adjustment_date IN DATE
						  ,x_accrual_adjustment_tbl    OUT NOCOPY p_accrual_adjustment_tbl_type
			  ,p_product_id      IN NUMBER DEFAULT NULL); -- MGAAP

END OKL_ACCRUAL_SEC_PVT;

/
