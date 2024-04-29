--------------------------------------------------------
--  DDL for Package OKL_ACCRUAL_DEPRN_ADJ_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ACCRUAL_DEPRN_ADJ_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPADAS.pls 115.1 2003/10/08 17:46:47 sgiyer noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_ACCRUAL_DEPRN_ADJ_PUB';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
  FUNCTION SUBMIT_DEPRN_ADJUSTMENT(
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    p_api_version IN NUMBER,
    p_batch_name IN VARCHAR2,
    p_date_from IN DATE,
    p_date_to IN DATE ) RETURN NUMBER;


END OKL_ACCRUAL_DEPRN_ADJ_PUB;

 

/
