--------------------------------------------------------
--  DDL for Package OKL_LTE_INT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LTE_INT_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPLINS.pls 115.6 2002/12/18 12:23:45 kjinger noship $ */
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below

  ------------------------------------------------------------------------------
  -- Global Variables
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_LTE_INT_PUB';
  G_APP_NAME             CONSTANT VARCHAR2(3)   :=  Okc_Api.G_APP_NAME;
  G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
  ------------------------------------------------------------------------------
   --Global Exception
  ------------------------------------------------------------------------------
   G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
  ------------------------------------------------------------------------------

  l_msg_data VARCHAR2(4000);

  --PROCEDURE ADD_LANGUAGE;

  --Object type procedure for calling calculate_late_charge

  PROCEDURE calculate_late_interest(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
     );


   PROCEDURE calculate_late_interest(	ERRBUF                  OUT NOCOPY 	VARCHAR2,
                                        RETCODE                 OUT NOCOPY     VARCHAR2 ,
                                        p_api_version           IN  	NUMBER,
           			                    p_init_msg_list         IN  	VARCHAR2 DEFAULT OKC_API.G_FALSE
                                     )   ;

END OKL_LTE_INT_PUB; -- Package spec

 

/
