--------------------------------------------------------
--  DDL for Package OKL_SLA_PROCESSING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SLA_PROCESSING_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLACHKS.pls 120.0 2007/05/14 19:05:40 racheruv noship $ */

PROCEDURE preaccounting
(
  p_application_id               IN            NUMBER,
  p_ledger_id                    IN            INTEGER,
  p_process_category             IN            VARCHAR2,
  p_end_date                     IN            DATE,
  p_accounting_mode              IN            VARCHAR2,
  p_valuation_method             IN            VARCHAR2,
  p_security_id_int_1            IN            INTEGER,
  p_security_id_int_2            IN            INTEGER,
  p_security_id_int_3            IN            INTEGER,
  p_security_id_char_1           IN            VARCHAR2,
  p_security_id_char_2           IN            VARCHAR2,
  p_security_id_char_3           IN            VARCHAR2,
  p_report_request_id            IN            INTEGER
);


PROCEDURE postprocessing
(
  p_application_id               IN            NUMBER,
  p_accounting_mode              IN            VARCHAR2
);

PROCEDURE extract
(
  p_application_id               IN            NUMBER,
  p_accounting_mode              IN            VARCHAR2
);

PROCEDURE postaccounting
(
  p_application_id               IN            NUMBER,
  p_ledger_id                    IN            INTEGER,
  p_process_category             IN            VARCHAR2,
  p_end_date                     IN            DATE,
  p_accounting_mode              IN            VARCHAR2,
  p_valuation_method             IN            VARCHAR2,
  p_security_id_int_1            IN            INTEGER,
  p_security_id_int_2            IN            INTEGER,
  p_security_id_int_3            IN            INTEGER,
  p_security_id_char_1           IN            VARCHAR2,
  p_security_id_char_2           IN            VARCHAR2,
  p_security_id_char_3           IN            VARCHAR2,
  p_report_request_id            IN            INTEGER
);

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN           CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN           CONSTANT VARCHAR2(200) := 'OKL_SQLcode';

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			    CONSTANT VARCHAR2(200) := 'OKL_SLA_PROCESSING_PVT';
  G_APP_NAME			    CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;

END okl_sla_processing_pvt;

/
