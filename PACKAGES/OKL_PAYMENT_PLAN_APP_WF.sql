--------------------------------------------------------
--  DDL for Package OKL_PAYMENT_PLAN_APP_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PAYMENT_PLAN_APP_WF" AUTHID CURRENT_USER AS
/* $Header: OKLRQPSS.pls 115.4 2003/02/11 03:47:52 rfedane noship $ */

  -----------------------------------------------------------------------------
  -- PACKAGE SPECIFIC GLOBAL CONSTANTS
  -----------------------------------------------------------------------------
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_PAYMENT_PLAN_APP_WF';
  G_API_TYPE             CONSTANT VARCHAR2(4)   := '_PVT';

  -----------------------------------------------------------------------------
  -- APPLICATION GLOBAL CONSTANTS
  -----------------------------------------------------------------------------
  G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_API_VERSION          CONSTANT NUMBER        := 1;
  G_FALSE                CONSTANT VARCHAR2(1)   := OKL_API.G_FALSE;
  G_TRUE                 CONSTANT VARCHAR2(1)   := OKL_API.G_TRUE;
  G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(25)  := 'OKL_CONTRACTS_UNEXP_ERROR';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(7)   := 'SQLCODE';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(7)   := 'SQLERRM';
  G_RET_STS_SUCCESS      CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_UNEXP_ERROR  CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR        CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_ERROR;

  -----------------------------------------------------------------------------
  -- PROGRAM UNITS
  -----------------------------------------------------------------------------

  PROCEDURE raise_payment_plan_app_event (p_rul_id        IN  NUMBER,
                                          x_return_status OUT NOCOPY VARCHAR2);


  PROCEDURE populate_attributes (itemtype  IN  VARCHAR2,
                                 itemkey   IN  VARCHAR2,
                                 actid     IN  NUMBER,
                                 funcmode  IN  VARCHAR2,
                                 resultout OUT NOCOPY VARCHAR2);


END okl_payment_plan_app_wf;

 

/
