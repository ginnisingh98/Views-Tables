--------------------------------------------------------
--  DDL for Package OKL_CASE_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CASE_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRCUTS.pls 115.4 2003/09/04 02:47:19 pdevaraj noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			      CONSTANT VARCHAR2(200) := okl_api.G_FND_APP;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
  G_INVALID_VALUE		      CONSTANT VARCHAR2(200) := okl_api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := 'COL_NAME';
  G_COL_NAME1_TOKEN		CONSTANT VARCHAR2(200) := 'COL_NAME1';
  G_COL_NAME2_TOKEN		CONSTANT VARCHAR2(200) := 'COL_NAME2';
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := 'PARENT_TABLE';
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_CASE_UTIL_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  'OKL';

   ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE CREATE_CASE(
     p_api_version      IN NUMBER,
     p_init_msg_list    IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_contract_id	IN NUMBER,
     x_return_status    OUT NOCOPY VARCHAR2,
     x_msg_count        OUT NOCOPY NUMBER,
     x_msg_data         OUT NOCOPY VARCHAR2
  );

END OKL_CASE_UTIL_PVT;


 

/
