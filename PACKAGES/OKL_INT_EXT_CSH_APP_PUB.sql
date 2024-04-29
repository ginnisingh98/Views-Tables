--------------------------------------------------------
--  DDL for Package OKL_INT_EXT_CSH_APP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INT_EXT_CSH_APP_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPIECS.pls 115.4 2002/12/18 12:20:47 kjinger noship $ */

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

 PROCEDURE int_ext_csh_app_pub ( p_api_version	  IN	NUMBER
 				                ,p_init_msg_list  IN	VARCHAR2 DEFAULT Okc_Api.G_FALSE
                                ,x_return_status  OUT	NOCOPY VARCHAR2
                                ,x_msg_count	  OUT	NOCOPY NUMBER
                                ,x_msg_data	      OUT	NOCOPY VARCHAR2
                                );

 PROCEDURE int_ext_csh_app_conc( errbuf  		  OUT NOCOPY   VARCHAR2
                                ,retcode 		  OUT NOCOPY   NUMBER
	                            );

END OKL_INT_EXT_CSH_APP_PUB; -- Package spec

 

/
