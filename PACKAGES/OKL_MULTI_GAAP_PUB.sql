--------------------------------------------------------
--  DDL for Package OKL_MULTI_GAAP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_MULTI_GAAP_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPGAPS.pls 115.0 2002/12/17 20:00:50 sgiyer noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_MULTI_GAAP_PUB';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
  FUNCTION SUBMIT_MULTI_GAAP(
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    p_api_version IN NUMBER,
    p_date_from IN DATE,
    p_date_to IN DATE,
    p_batch_name IN VARCHAR2 ) RETURN NUMBER;


END OKL_MULTI_GAAP_PUB;

 

/
