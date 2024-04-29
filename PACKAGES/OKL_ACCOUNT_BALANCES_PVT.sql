--------------------------------------------------------
--  DDL for Package OKL_ACCOUNT_BALANCES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ACCOUNT_BALANCES_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRACBS.pls 120.2 2005/10/30 03:37:28 appldev noship $ */
G_PKG_NAME CONSTANT VARCHAR2(200)      := 'OKL_ACCOUNT_REP_PVT' ;
G_APP_NAME CONSTANT VARCHAR2(3)        :=  OKC_API.G_APP_NAME;
G_RET_STS_SUCCESS		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_SUCCESS;
G_RET_STS_UNEXP_ERROR		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_UNEXP_ERROR;
G_RET_STS_ERROR		         CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_ERROR;
G_REQUIRED_VALUE                 CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
G_INVALID_VALUE                  CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
G_SQLERRM_TOKEN                  CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
G_SQLCODE_TOKEN                  CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
G_UNEXPECTED_ERROR               CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
G_COL_NAME_TOKEN                 CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
G_EXCEPTION_ERROR		 EXCEPTION;
G_EXCEPTION_UNEXPECTED_ERROR	 EXCEPTION;
SUBTYPE error_message_type IS Okl_Accounting_Util.ERROR_MESSAGE_TYPE;
-- This API should be called for calculation of Periodic Interest for the contracts which
-- have capitalization flag = ''N'

PROCEDURE Get_Account_Balances(p_errbuf OUT NOCOPY VARCHAR2,
		         p_retcode OUT NOCOPY NUMBER,
		         p_contract_number IN VARCHAR2,
		         p_account_from IN VARCHAR2,
		         p_account_to IN VARCHAR2,
		         p_period_from IN VARCHAR2,
		         p_period_to IN VARCHAR2,
		         p_format IN VARCHAR2 );


FUNCTION Submit_Account_Balances(
    p_api_version       IN NUMBER,
    p_init_msg_list 	IN VARCHAR2,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count 		OUT NOCOPY NUMBER,
    x_msg_data 			OUT NOCOPY VARCHAR2,
    p_contract_number IN VARCHAR2,
    p_account_from IN VARCHAR2,
    p_account_to IN VARCHAR2,
    p_period_from IN VARCHAR2,
    p_period_to IN VARCHAR2,
    p_format IN VARCHAR2 )
RETURN NUMBER;

END OKL_ACCOUNT_BALANCES_PVT;

 

/
