--------------------------------------------------------
--  DDL for Package OKL_PROCESS_SALES_TAX_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PROCESS_SALES_TAX_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPPSTS.pls 120.2 2007/07/12 22:20:12 rravikir ship $ */
 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_PROCESS_SALES_TAX_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------

PROCEDURE calculate_sales_tax(
    p_api_version                  	IN  NUMBER,
    p_init_msg_list                	IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_source_trx_id				 	IN  NUMBER,
    p_source_trx_name               IN  VARCHAR2,
    p_source_table                  IN  VARCHAR2,
    p_tax_call_type                 IN  VARCHAR2 DEFAULT NULL,
    p_serialized_asset              IN  VARCHAR2 DEFAULT NULL,
    p_request_id                    IN  NUMBER   DEFAULT NULL,
    p_alc_final_call                IN  VARCHAR2 DEFAULT NULL);

END OKL_PROCESS_SALES_TAX_PUB;

/
