--------------------------------------------------------
--  DDL for Package OKL_UPDT_CASH_DTLS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_UPDT_CASH_DTLS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPCUPS.pls 115.5 2002/04/17 07:27:17 pkm ship        $ */

 SUBTYPE okl_cash_dtls_tbl_type IS Okl_Updt_Cash_Dtls.okl_cash_dtls_tbl_type;
 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_UPDT_CASH_DTLS_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  Okc_Api.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------


 PROCEDURE updt_cash_dtls_pub  ( p_api_version	   IN  NUMBER
		                       ,p_init_msg_list    IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
				               ,x_return_status    OUT NOCOPY VARCHAR2
				               ,x_msg_count	       OUT NOCOPY NUMBER
				               ,x_msg_data	       OUT NOCOPY VARCHAR2
                               ,p_strm_tbl         IN  okl_cash_dtls_tbl_type
                               ,x_strm_tbl         OUT NOCOPY okl_cash_dtls_tbl_type
                               );



END Okl_Updt_Cash_Dtls_Pub;

 

/
