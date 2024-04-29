--------------------------------------------------------
--  DDL for Package OKL_LOAN_BAL_UPDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LOAN_BAL_UPDATE_PVT" AUTHID CURRENT_USER AS
  /* $Header: OKLRLBUS.pls 120.2 2005/11/29 23:38:54 pjgomes noship $ */

  ------------------------------------------------------------------------------
  --Record Types
  ------------------------------------------------------------------------------
  TYPE khr_rec_type IS RECORD (
    khr_id okc_k_headers_b.id%type,
    contract_number okc_k_headers_b.contract_number%type,
    status okc_k_headers_b.sts_code%type,
    deal_type okl_product_parameters_v.deal_type%type,
    interest_calculation_basis okl_product_parameters_v.interest_calculation_basis%type,
    revenue_recognition_method okl_product_parameters_v.revenue_recognition_method%type);

  SUBTYPE okl_cblv_rec is okl_cbl_pvt.cblv_rec_type;
  SUBTYPE okl_cblv_tbl is okl_cbl_pvt.cblv_tbl_type;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME       CONSTANT VARCHAR2(200) := 'OKL_LOAN_BAL_UPDATE_PVT';
  G_APP_NAME       CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_API_TYPE       CONSTANT VARCHAR2(30)  := '_PVT';

  ------------------------------------------------------------------------------
   --Global Exception
  ------------------------------------------------------------------------------
   G_EXCEPTION_HALT_VALIDATION  EXCEPTION;

  PROCEDURE get_loan_amounts(
                              p_api_version      IN         NUMBER
                            , p_init_msg_list    IN         VARCHAR2 DEFAULT OKL_API.G_FALSE
                            , x_return_status    OUT NOCOPY VARCHAR2
                            , x_msg_count        OUT NOCOPY NUMBER
                            , x_msg_data         OUT NOCOPY VARCHAR2
                            , p_khr_rec          IN         khr_rec_type
                            , p_as_of_date       IN         DATE);

  PROCEDURE calculate_loan_amounts(
                              errbuf             OUT NOCOPY VARCHAR2
                            , retcode            OUT NOCOPY NUMBER
                            , p_contract_number  IN         VARCHAR2
                            , p_as_of_date       IN         VARCHAR2 );

END OKL_LOAN_BAL_UPDATE_PVT; -- end of Spec

/
