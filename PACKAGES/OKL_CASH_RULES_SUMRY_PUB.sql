--------------------------------------------------------
--  DDL for Package OKL_CASH_RULES_SUMRY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CASH_RULES_SUMRY_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPCSYS.pls 115.0 2002/12/10 18:04:37 stmathew noship $ */

 SUBTYPE okl_cash_rl_sumry_tbl_type IS Okl_cash_rules_sumry_pvt.okl_cash_rl_sumry_tbl_type;
 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_BTCH_CASH_SUMRY_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  Okc_Api.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

 ------------------------------------------------------------------------------


 PROCEDURE okl_cash_rl_sumry ( p_api_version	 IN	  NUMBER
				              ,p_init_msg_list   IN	  VARCHAR2 DEFAULT Okc_Api.G_FALSE
				              ,x_return_status   OUT  NOCOPY VARCHAR2
				              ,x_msg_count	     OUT  NOCOPY NUMBER
				              ,x_msg_data	     OUT  NOCOPY VARCHAR2
                              ,p_cash_rl_tbl     IN   okl_cash_rl_sumry_tbl_type
							     );

END OKL_CASH_RULES_SUMRY_PUB;

 

/
