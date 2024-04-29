--------------------------------------------------------
--  DDL for Package IEX_CO_TRANSFER_EA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_CO_TRANSFER_EA_PVT" AUTHID CURRENT_USER AS
/* $Header: IEXRTEAS.pls 120.0 2004/01/24 03:15:45 appldev noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE case_rec_type is RECORD (
    cas_id                 NUMBER,
    case_number            VARCHAR2(240),
    case_owner             VARCHAR2(360),
    case_status            VARCHAR2(80),
    party_name             VARCHAR2(360),
    party_type             VARCHAR2(80),
    party_address          VARCHAR2(1995),
    last_transfer_date     DATE,
    case_review_date       DATE,
    ext_agncy_name         VARCHAR2(80)
  );

  TYPE case_tbl_type IS TABLE OF case_rec_type INDEX BY BINARY_INTEGER;

  TYPE form_contract_rec_type is RECORD (
    khr_id                 NUMBER,
    contract_number        VARCHAR2(120),
    contract_type          VARCHAR2(80),
    contract_status        VARCHAR2(80),
    original_amount        NUMBER(14, 3),
    start_date             DATE,
    close_date             DATE,
    term_duration          NUMBER(10),
    monthly_payment_amount NUMBER(14, 3),
    last_payment_date      DATE,
    delinquency_occurance_date DATE,
    past_due_amount        NUMBER(14, 3),
    past_due_days          NUMBER(10),
    outstanding_receivable NUMBER(14, 3)
  );

  TYPE form_contract_tbl_type IS TABLE OF form_contract_rec_type INDEX BY BINARY_INTEGER;


  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                     CONSTANT VARCHAR2(200) := Okc_Api.G_FND_APP;
  G_REQUIRED_VALUE              CONSTANT VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
  G_INVALID_VALUE               CONSTANT VARCHAR2(200) := Okc_Api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN              CONSTANT VARCHAR2(200) := 'COL_NAME';
  G_COL_NAME1_TOKEN             CONSTANT VARCHAR2(200) := 'COL_NAME1';
  G_COL_NAME2_TOKEN             CONSTANT VARCHAR2(200) := 'COL_NAME2';
  G_PARENT_TABLE_TOKEN	        CONSTANT VARCHAR2(200) := 'PARENT_TABLE';
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                    CONSTANT VARCHAR2(200) := 'IEX_CO_TRANSFER_EA_PVT';
  G_APP_NAME                    CONSTANT VARCHAR2(3)   := 'IEX';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION   EXCEPTION;
  G_INVALID_PARAMETERS          EXCEPTION;

  PROCEDURE get_case_details (
     p_cas_id                   IN NUMBER,
     x_case_rec                 OUT NOCOPY case_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2);

  PROCEDURE get_contract_details (
     p_khr_id                   IN NUMBER,
     x_form_contract_rec             OUT NOCOPY form_contract_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2);

END IEX_CO_TRANSFER_EA_PVT;

 

/
