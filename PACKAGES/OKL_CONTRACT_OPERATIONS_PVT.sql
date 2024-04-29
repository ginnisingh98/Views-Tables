--------------------------------------------------------
--  DDL for Package OKL_CONTRACT_OPERATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CONTRACT_OPERATIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRCOCS.pls 115.0 2003/02/14 00:47:43 bakuchib noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP          CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_REQUIRED_VALUE   CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE    CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN   CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_UNEXPECTED_ERROR CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN    CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN    CONSTANT VARCHAR2(200) := 'SQLcode';

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME		CONSTANT VARCHAR2(200) := 'OKL_CONTRACT_OPERATIONS_PVT';
  G_APP_NAME		CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_INSURANCE_ERROR EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  -- PROCEDURES
  ---------------------------------------------------------------------------



END OKL_CONTRACT_OPERATIONS_PVT;

 

/
