--------------------------------------------------------
--  DDL for Package OKS_AUTH_INT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_AUTH_INT_PUB" AUTHID CURRENT_USER AS
/* $Header: OKSPAITS.pls 120.0 2005/05/25 18:33:56 appldev noship $*/

-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- Enter package declarations as shown below
-- GLOBAL VARIABLES
   -------------------------------------------------------------------------------
   G_PKG_NAME	                   CONSTANT VARCHAR2(200) := 'OKS_AUTH_INT_PUB';
   G_APP_NAME_OKS	           CONSTANT VARCHAR2(3)   :=  'OKS';
   G_APP_NAME_OKC	           CONSTANT VARCHAR2(3)   :=  'OKC';
   -------------------------------------------------------------------------------
   -- GLOBAL_MESSAGE_CONSTANTS
   ---------------------------------------------------------------------------------------------
   G_TRUE                          CONSTANT VARCHAR2(1)   :=  OKC_API.G_TRUE;
   G_FALSE                         CONSTANT VARCHAR2(1)   :=  OKC_API.G_FALSE;
   G_RET_STS_SUCCESS		   CONSTANT VARCHAR2(1)   :=  OKC_API.G_RET_STS_SUCCESS;
   G_RET_STS_ERROR		   CONSTANT VARCHAR2(1)   :=  OKC_API.G_RET_STS_ERROR;
   G_RET_STS_UNEXP_ERROR           CONSTANT VARCHAR2(1)   :=  OKC_API.G_RET_STS_UNEXP_ERROR;
   G_UNEXPECTED_ERROR              CONSTANT VARCHAR2(30)  := 'OKS_CONTRACTS_UNEXPECTED_ERROR';
   G_SQLERRM_TOKEN                 CONSTANT VARCHAR2(30)  := 'SQLerrm';
   G_SQLCODE_TOKEN                 CONSTANT VARCHAR2(30)  := 'SQLcode';
   G_REQUIRED_VALUE                CONSTANT VARCHAR2(30)  :=OKC_API.G_REQUIRED_VALUE;
   G_COL_NAME_TOKEN                CONSTANT VARCHAR2(30)  :=OKC_API.G_COL_NAME_TOKEN;
   ---------------------------------------------------------------------------------------------
   G_EXCEPTION_HALT_VALIDATION 	EXCEPTION;

   FUNCTION ok_to_commit (p_api_version             IN  NUMBER
                         ,p_init_msg_list           IN  VARCHAR2
                         ,p_doc_id                  IN  NUMBER
                         ,p_doc_validation_string   IN  VARCHAR2
                         ,x_return_status           OUT NOCOPY VARCHAR2
                         ,x_msg_count               OUT NOCOPY NUMBER
                         ,x_msg_data                OUT NOCOPY VARCHAR2
                         )RETURN BOOLEAN;

   Function Check_For_Active_Process
                  (p_contract_number          VARCHAR2
                  ,p_contract_number_modifier VARCHAR2
                  )Return Boolean;



END OKS_AUTH_INT_PUB; -- Package Specification OKS_AUTH_INT_PUB


 

/
