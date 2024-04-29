--------------------------------------------------------
--  DDL for Package OKL_GENERATE_ACCRUALS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_GENERATE_ACCRUALS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPACRS.pls 120.5.12010000.3 2008/10/20 19:40:45 apaul ship $ */

  SUBTYPE accrual_rec_type IS OKL_GENERATE_ACCRUALS_PVT.accrual_rec_type;
  SUBTYPE acceleration_rec_type IS OKL_GENERATE_ACCRUALS_PVT.acceleration_rec_type;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_GENERATE_ACCRUALS_PUB';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
  FUNCTION SUBMIT_ACCRUALS(
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    p_api_version IN NUMBER,
    p_accrual_date IN DATE,
    p_batch_name IN VARCHAR2 ) RETURN NUMBER;


  FUNCTION CALCULATE_CNTRCT_REC(p_ctr_id IN OKC_K_HEADERS_B.id%TYPE) RETURN NUMBER;

  PROCEDURE VALIDATE_ACCRUAL_RULE(x_return_status OUT NOCOPY VARCHAR2
                                 ,x_msg_count OUT NOCOPY NUMBER
								 ,x_msg_data OUT NOCOPY VARCHAR2
                                 ,x_result OUT NOCOPY VARCHAR2
                                 ,p_ctr_id IN OKL_K_HEADERS.ID%TYPE);

  PROCEDURE CATCHUP_ACCRUALS (
    p_api_version IN NUMBER,
    p_init_msg_list IN VARCHAR2,
    p_catchup_rec IN accrual_rec_type,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    x_tcnv_tbl OUT NOCOPY OKL_TRX_CONTRACTS_PUB.tcnv_tbl_type,
    x_tclv_tbl OUT NOCOPY OKL_TRX_CONTRACTS_PUB.tclv_tbl_type,
    p_representation_type IN VARCHAR2 DEFAULT 'PRIMARY'); --MGAAP 7263041);

  PROCEDURE REVERSE_ACCRUALS (
    p_api_version IN NUMBER,
	p_init_msg_list IN VARCHAR2,
    p_reverse_rec IN accrual_rec_type,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    x_tcnv_tbl OUT NOCOPY OKL_TRX_CONTRACTS_PUB.tcnv_tbl_type,
    x_tclv_tbl OUT NOCOPY OKL_TRX_CONTRACTS_PUB.tclv_tbl_type);

  PROCEDURE REVERSE_ACCRUALS (
    p_api_version IN NUMBER,
	p_init_msg_list IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    p_khr_id IN NUMBER,
    p_reversal_date IN DATE,
    p_accounting_date IN DATE,
    p_reverse_from IN DATE,
    p_reverse_to IN DATE,
    p_tcn_type IN VARCHAR2);

  PROCEDURE REVERSE_ALL_ACCRUALS (
    p_api_version IN NUMBER,
	p_init_msg_list IN VARCHAR2,
    p_khr_id IN NUMBER,
    p_reverse_date IN DATE,
    p_description IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2);

  PROCEDURE ACCELERATE_ACCRUALS (
    p_api_version IN NUMBER,
    p_init_msg_list IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
	p_acceleration_rec IN acceleration_rec_type,
    p_representation_type IN VARCHAR2 DEFAULT 'PRIMARY', --MGAAP 7263041
    x_trx_number OUT NOCOPY OKL_TRX_CONTRACTS.TRX_NUMBER%TYPE); --MGAAP 7263041


END OKL_GENERATE_ACCRUALS_PUB;

/
