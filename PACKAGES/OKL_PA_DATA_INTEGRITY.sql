--------------------------------------------------------
--  DDL for Package OKL_PA_DATA_INTEGRITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PA_DATA_INTEGRITY" AUTHID CURRENT_USER AS
/* $Header: OKLRPAQS.pls 120.0 2005/08/11 09:54:22 abindal noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'SQLcode';
--
  G_QA_SUCCESS   		CONSTANT VARCHAR2(200) := 'OKL_PROGRAM_QA_SUCCESS';
  ------------------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_PA_DATA_INTEGRITY';
  G_APP_NAME   CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  ---------------------------------------------------------------------------

--------------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : check_functional_constraints
  -- Description     : This procedure checks for the valid effective dates of the associated
  --                   objects and the valid status for lease application template and lease
  --                   contract template associated to vendor agreement
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
--------------------------------------------------------------------------------------
  PROCEDURE check_functional_constraints(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER);

END OKL_PA_DATA_INTEGRITY;

 

/
