--------------------------------------------------------
--  DDL for Package OKC_QA_DATA_INTEGRITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_QA_DATA_INTEGRITY" AUTHID CURRENT_USER AS
/* $Header: OKCRQADS.pls 120.0 2005/05/25 22:54:17 appldev noship $ */

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
  G_PARTY_COUNT   		CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_PARTY_COUNT';
  G_REQUIRED_RULE   		CONSTANT VARCHAR2(200) := 'OKC_REQUIRED_RULE';
  G_REQUIRED_RULE_GROUP         CONSTANT VARCHAR2(200) := 'OKC_REQUIRED_RULE_GROUP';
  G_REQUIRED_RULE_VALUES        CONSTANT VARCHAR2(200) := 'OKC_REQUIRED_RULE_VALUES';
  G_REQUIRED_RULE_PARTY_ROLE    CONSTANT VARCHAR2(200) := 'OKC_REQUIRED_RULE_PARTY_ROLE';
  G_RULE_DEPENDENT_VALUE        CONSTANT VARCHAR2(200) := 'OKC_RULE_DEPENDENT_VALUE';
  G_INVALID_LINE_DATES          CONSTANT VARCHAR2(200) := 'OKC_INVALID_LINE_DATES';
  G_INVALID_COVERAGELINE_DATES  CONSTANT VARCHAR2(200) := 'OKC_INVALID_COVERAGELINE_DATES';
  G_REQUIRED_LINE_VALUE		CONSTANT VARCHAR2(200) := 'OKC_REQUIRED_LINE_FIELD';
  G_INVALID_LINE_CURRENCY       CONSTANT VARCHAR2(200) := 'OKC_INVALID_LINE_CURRENCY';
  G_RULE_ROLE_DELETED   	CONSTANT VARCHAR2(200) := 'OKC_RULE_ROLE_DELETED';
  G_RULE_ROLE_CHANGED   	CONSTANT VARCHAR2(200) := 'OKC_RULE_ROLE_CHANGED';
  G_NO_SUBLINE_PARTY   		CONSTANT VARCHAR2(200) := 'OKC_NO_PARTY_SUBLINE';
  G_NO_HEADER_PARTY   		CONSTANT VARCHAR2(200) := 'OKC_NO_PARTY_HEADER';
  G_NO_SUBLINE_RULE   		CONSTANT VARCHAR2(200) := 'OKC_NO_RULE_SUBLINE';

  ------------------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME		CONSTANT VARCHAR2(30) := 'OKC_QA_DATA_INTEGRITY';
  G_APP_NAME		CONSTANT VARCHAR2(3)  :=  OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------

  PROCEDURE check_required_values(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER);

  PROCEDURE check_art_compatible(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  );

  PROCEDURE check_rule_groups(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER);

  PROCEDURE check_rule_group_parties(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER);

  PROCEDURE check_effectivity_dates(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER);

END OKC_QA_DATA_INTEGRITY;

 

/
