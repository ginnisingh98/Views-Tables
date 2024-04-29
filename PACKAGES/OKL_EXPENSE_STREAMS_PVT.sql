--------------------------------------------------------
--  DDL for Package OKL_EXPENSE_STREAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_EXPENSE_STREAMS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSGES.pls 120.2 2008/01/25 14:18:41 gboomina ship $ */

  -----------------------------------------------------------------------------
  -- PACKAGE SPECIFIC CONSTANTS
  -----------------------------------------------------------------------------
  G_PKG_NAME             CONSTANT VARCHAR2(30)  := 'OKL_EXPENSE_STREAMS_PVT';

  -----------------------------------------------------------------------------
  -- APPLICATION GLOBAL CONSTANTS
  -----------------------------------------------------------------------------
  G_APP_NAME             CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_API_VERSION          CONSTANT NUMBER        := 1;
  G_FALSE                CONSTANT VARCHAR2(1)   := OKL_API.G_FALSE;
  G_TRUE                 CONSTANT VARCHAR2(1)   := OKL_API.G_TRUE;
  G_DB_ERROR             CONSTANT VARCHAR2(12)  := 'OKL_DB_ERROR';
  G_PROG_NAME_TOKEN      CONSTANT VARCHAR2(9)   := 'PROG_NAME';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(7)   := 'SQLCODE';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(7)   := 'SQLERRM';
  G_RET_STS_SUCCESS      CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_UNEXP_ERROR  CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR        CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_ERROR;

  ---------------------------------------------------------------------------
  -- PROGRAM UNITS
  ---------------------------------------------------------------------------
 PROCEDURE generate_idc( p_khr_id         IN         NUMBER,
                          p_purpose_code   IN         VARCHAR2,
                          p_currency_code  IN         VARCHAR2,
                          p_start_date     IN         DATE,
                          p_end_date       IN         DATE,
                          p_deal_type      IN         VARCHAR2,
                          x_return_status  OUT NOCOPY VARCHAR2);

  PROCEDURE generate_expense_streams( p_api_version      IN         NUMBER,
                                      p_init_msg_list    IN         VARCHAR2,
                                      p_khr_id           IN         NUMBER,
                                      p_purpose_code     IN         VARCHAR2,
                                      p_deal_type        IN         VARCHAR2,
                                      x_return_status    OUT NOCOPY VARCHAR2,
                                      x_msg_count        OUT NOCOPY NUMBER,
                                      x_msg_data         OUT NOCOPY VARCHAR2);
  -- gboomina Bug 6763287 - Start
  PROCEDURE generate_rec_exp( p_khr_id           IN         NUMBER,
			      p_deal_type        IN         VARCHAR2,
                              p_purpose_code     IN         VARCHAR2,
                              p_currency_code    IN         VARCHAR2,
                              x_return_status    OUT NOCOPY VARCHAR2);
  -- gboomina Bug 6763287 - End

END OKL_EXPENSE_STREAMS_PVT;

/
