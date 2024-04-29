--------------------------------------------------------
--  DDL for Package OKC_PO_QA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_PO_QA_PVT" AUTHID CURRENT_USER AS
 /* $Header: OKCRPQAS.pls 120.0 2005/05/25 18:51:22 appldev noship $ */


  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'ERROR_CODE';
  G_INVALID_END_DATE            CONSTANT VARCHAR2(200) := 'OKC_INVALID_END_DATE';
--
  G_QA_SUCCESS   		CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_QA_SUCCESS';

  ------------------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME		CONSTANT VARCHAR2(30) := 'OKC_PO_QA_PVT';
  G_APP_NAME		CONSTANT VARCHAR2(3)  :=  OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------


----------------------------------------------------------------------------------
-- Start of comments
--
-- API Name     : OKC_PO_QA_PVT.Validate_K_FOR_PO
--
-- Type         : Private
--
-- Pre-reqs     : None
--
-- Function : This procedure is called from the contract authoring screen.
-- It accepts a Contract Identifier as a
-- parameter and uses it to check QA validations required for PO

--
-- Parameters   : Please see specification below. No special parameters.
--
-- Version      : Initial version
--
-- End of comments
----------------------------------------------------------------------------------

  PROCEDURE Validate_K_FOR_PO(
	    	x_return_status   OUT NOCOPY VARCHAR2,
	    	p_chr_id          IN  NUMBER);


----------------------------------------------------------------------------------
END OKC_PO_QA_PVT; -- Package Specification OKC_CREATE_PO_FROM_K_PVT

 

/
