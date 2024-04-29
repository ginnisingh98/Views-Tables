--------------------------------------------------------
--  DDL for Package OKC_QA_GENERAL_CHECKLISTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_QA_GENERAL_CHECKLISTS" AUTHID CURRENT_USER AS
/* $Header: OKCRQAGS.pls 120.0 2005/05/25 19:30:45 appldev noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'ERROR_CODE';
  G_QA_SUCCESS   		CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_QA_SUCCESS';

  ------------------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME		CONSTANT VARCHAR2(30) := 'OKC_QA_GENERAL_CHECKLISTS';
  G_APP_NAME		CONSTANT VARCHAR2(3)  :=  OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------

PROCEDURE check_euro_currency(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) ;

PROCEDURE check_email_address(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER);

PROCEDURE check_email_address_role(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER,
    p_rle_code                 IN  VARCHAR2);

END OKC_QA_GENERAL_CHECKLISTS;

 

/
