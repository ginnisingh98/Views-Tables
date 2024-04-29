--------------------------------------------------------
--  DDL for Package OKL_CASE_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CASE_UTIL_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPCUTS.pls 115.2 2002/04/18 11:27:15 pkm ship        $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_CASE_UTIL_PUB';
  G_APP_NAME			CONSTANT VARCHAR2(3)   := 'OKL';

   ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
  ---------------------------------------------------------------------------

  PROCEDURE CREATE_CASE(
     p_api_version      IN NUMBER,
     p_init_msg_list    IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_contract_id	IN NUMBER,
     x_return_status    OUT NOCOPY VARCHAR2,
     x_msg_count        OUT NOCOPY NUMBER,
     x_msg_data         OUT NOCOPY VARCHAR2
  );

END OKL_CASE_UTIL_PUB;

 

/
