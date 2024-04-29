--------------------------------------------------------
--  DDL for Package OKC_QA_PRICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_QA_PRICE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCRQARS.pls 120.0 2005/05/25 19:31:00 appldev noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';

  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'ERROR_CODE';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'ERROR_MESSAGE';
  --
  G_QA_SUCCESS   		CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_QA_SUCCESS';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(30)  := 'OKC_QA_PRICE_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------

  PROCEDURE check_price(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER);


  PROCEDURE check_covered_line_qty (
    p_chr_id             IN  okc_k_headers_b.ID%TYPE,
    x_return_status      OUT NOCOPY VARCHAR2);


END OKC_QA_PRICE_PVT;

 

/
