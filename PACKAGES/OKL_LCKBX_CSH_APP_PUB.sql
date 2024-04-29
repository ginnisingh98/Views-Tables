--------------------------------------------------------
--  DDL for Package OKL_LCKBX_CSH_APP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LCKBX_CSH_APP_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPLBXS.pls 115.0 2002/03/21 18:49:31 pkm ship        $ */

 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_LCKBX_CSH_APP_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------

 PROCEDURE handle_auto_pay   ( p_api_version	  IN	NUMBER
  				              ,p_init_msg_list    IN	VARCHAR2 DEFAULT Okc_Api.G_FALSE
                              ,x_return_status    OUT	NOCOPY VARCHAR2
                              ,x_msg_count	      OUT	NOCOPY NUMBER
                              ,x_msg_data	      OUT	NOCOPY VARCHAR2
                              ,p_trans_req_id     IN   AR_PAYMENTS_INTERFACE.TRANSMISSION_REQUEST_ID%TYPE
                             );


END OKL_LCKBX_CSH_APP_PUB;

 

/
