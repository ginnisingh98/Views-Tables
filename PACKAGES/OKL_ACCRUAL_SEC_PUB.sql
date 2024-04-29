--------------------------------------------------------
--  DDL for Package OKL_ACCRUAL_SEC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ACCRUAL_SEC_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPASCS.pls 115.0 2003/03/06 22:12:37 sgiyer noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------


  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN		CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN		CONSTANT VARCHAR2(200) := 'OKL_SQLcode';

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_ACCRUAL_SEC_PUB';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE CREATE_STREAMS(p_api_version    IN  NUMBER,
                           p_init_msg_list   IN  VARCHAR2,
                           x_return_status   OUT NOCOPY VARCHAR2,
                           x_msg_count       OUT NOCOPY NUMBER,
                           x_msg_data        OUT NOCOPY VARCHAR2,
					       p_khr_id          IN NUMBER);

  PROCEDURE CANCEL_STREAMS(p_api_version     IN  NUMBER,
                           p_init_msg_list   IN  VARCHAR2,
                           x_return_status   OUT NOCOPY VARCHAR2,
                           x_msg_count       OUT NOCOPY NUMBER,
                           x_msg_data        OUT NOCOPY VARCHAR2,
					       p_khr_id          IN NUMBER,
                           p_cancel_date     IN DATE);

END OKL_ACCRUAL_SEC_PUB;

 

/
