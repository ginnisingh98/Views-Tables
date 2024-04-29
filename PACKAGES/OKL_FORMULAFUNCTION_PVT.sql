--------------------------------------------------------
--  DDL for Package OKL_FORMULAFUNCTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_FORMULAFUNCTION_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRFNCS.pls 115.2 2002/02/18 20:16:19 pkm ship       $ */

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN		CONSTANT VARCHAR2(200) := 'OKC_SQLerrm';
  G_SQLCODE_TOKEN		CONSTANT VARCHAR2(200) := 'OKC_SQLcode';
  G_UPPERCASE_REQUIRED		CONSTANT VARCHAR2(200) := 'OKC_UPPER_CASE_REQUIRED';
  G_ONE_DOI			CONSTANT VARCHAR2(200) := 'OKC_ONE_DOI';

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_FORMULAFUNCTION_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;


  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION  EXCEPTION;


  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

 -- PROCEDURE qc;
 -- PROCEDURE change_version;
 -- PROCEDURE api_copy;
 -- PROCEDURE add_language;

 FUNCTION GET_TAX_VALUE(
       p_contract_id   IN NUMBER,
       p_line_id       IN NUMBER )
 RETURN NUMBER;

 FUNCTION GET_BONUS_VALUE(
       p_contract_id   IN NUMBER,
       p_line_id       IN NUMBER )
 RETURN NUMBER;

 FUNCTION GET_REVENUE_VALUE(
       p_contract_id   IN NUMBER,
       p_line_id       IN NUMBER )
 RETURN NUMBER;

END OKL_FORMULAFUNCTION_PVT;

 

/
