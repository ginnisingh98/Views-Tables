--------------------------------------------------------
--  DDL for Package OKL_COMMON_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_COMMON_FUNCTIONS" AUTHID CURRENT_USER AS
/* $Header: OKLRCOMS.pls 115.1 2002/08/09 16:48:05 pdevaraj noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			      CONSTANT VARCHAR2(200) := okl_api.G_FND_APP;
  G_INVALID_VALUE		      CONSTANT VARCHAR2(200) := okl_api.G_INVALID_VALUE;
  G_ERROR		            CONSTANT VARCHAR2(200) := 'OKL_ERROR';
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_COMMON_FUNCTIONS';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  'OKL';

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  -- Returns Unrefunded Cures
  ---------------------------------------------------------------------------
  FUNCTION get_unrefunded_cures(
     p_contract_id		IN NUMBER,
     x_unrefunded_cures	      OUT NOCOPY NUMBER)
  RETURN VARCHAR2;

  ---------------------------------------------------------------------------
  -- Returns get_cured_status
  ---------------------------------------------------------------------------
  FUNCTION get_cured_status (p_contract_number IN NUMBER)
  RETURN VARCHAR2;

  pragma restrict_references(get_cured_status, WNDS,WNPS,RNPS);

END OKL_COMMON_FUNCTIONS;

 

/
