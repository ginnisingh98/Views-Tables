--------------------------------------------------------
--  DDL for Package OKL_INTEREST_CALC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INTEREST_CALC_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRITUS.pls 120.3 2005/10/30 03:39:25 appldev noship $ */

  G_PKG_NAME CONSTANT VARCHAR2(200)      := 'OKL_INTEREST_CALC_PVT' ;
  G_APP_NAME CONSTANT VARCHAR2(3)        :=  OKL_API.G_APP_NAME;
  G_REQUIRED_VALUE                 CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE                  CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_SQLERRM_TOKEN                  CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN                  CONSTANT VARCHAR2(200) := 'OKL_SQLcode';
  G_UNEXPECTED_ERROR               CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_UPPERCASE_REQUIRED             CONSTANT VARCHAR2(200) := 'OKL_UPPER_CASE_REQUIRED';
  G_COL_NAME_TOKEN                 CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;

  PROCEDURE CALC_INTEREST_ACTIVATE(p_api_version 	IN 	NUMBER,
                                   p_init_msg_list 	IN 	VARCHAR2,
                                   x_return_status 	OUT NOCOPY VARCHAR2,
                                   x_msg_count 		OUT NOCOPY NUMBER,
				   x_msg_data 		OUT NOCOPY VARCHAR2,
				   p_contract_number    IN  VARCHAR2,
				   p_activation_date    IN  DATE,
                                   x_amount             OUT NOCOPY NUMBER,
				   x_source_id          OUT NOCOPY NUMBER);

  PROCEDURE CALC_INTEREST_PERD(p_errbuf      OUT NOCOPY VARCHAR2,
		  	       p_retcode     OUT NOCOPY NUMBER,
                               p_calc_upto    IN VARCHAR2);

  FUNCTION SUBMIT_CALCULATE_INTEREST(p_api_version      IN NUMBER,
                                     p_init_msg_list 	IN VARCHAR2,
                                     x_return_status    OUT NOCOPY VARCHAR2,
                                     x_msg_count 	OUT NOCOPY NUMBER,
                                     x_msg_data 	OUT NOCOPY VARCHAR2,
                                     p_period_name 	IN VARCHAR2 )
  RETURN NUMBER;


END OKL_INTEREST_CALC_PVT;

 

/
