--------------------------------------------------------
--  DDL for Package OKL_BTCH_CASH_APPLIC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_BTCH_CASH_APPLIC_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPBAPS.pls 115.3 2002/10/25 19:06:47 bvaghela noship $ */

 SUBTYPE okl_btch_dtls_tbl_type IS Okl_btch_cash_applic.okl_btch_dtls_tbl_type;
 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_BTCH_CASH_APPLIC_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  Okc_Api.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

 ------------------------------------------------------------------------------


 PROCEDURE okl_batch_cash_applic ( p_api_version	   IN	NUMBER
				                  ,p_init_msg_list     IN	VARCHAR2 DEFAULT Okc_Api.G_FALSE
				                  ,x_return_status     OUT  NOCOPY VARCHAR2
				                  ,x_msg_count	       OUT  NOCOPY NUMBER
				                  ,x_msg_data	       OUT  NOCOPY VARCHAR2
                                  ,p_btch_tbl          IN   okl_btch_dtls_tbl_type
                                  ,x_btch_tbl          OUT  NOCOPY okl_btch_dtls_tbl_type
							     );

END OKL_BTCH_CASH_APPLIC_PUB;

 

/
