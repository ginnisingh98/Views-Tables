--------------------------------------------------------
--  DDL for Package OKL_BILL_UPFRONT_TAX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_BILL_UPFRONT_TAX_PVT" AUTHID CURRENT_USER as
/* $Header: OKLRBUTS.pls 120.1 2007/06/06 14:20:30 akrangan ship $ */

-- Global variables for user hooks
  G_PKG_NAME   CONSTANT VARCHAR2(200) := 'OKL_BILL_UPFRONT_TAX_PVT';
  G_APP_NAME   CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

  SUCCESS_MESSAGE EXCEPTION;
 --akrangan ebtax billing impacts coding start
  G_USER_ID   CONSTANT NUMBER := FND_GLOBAL.USER_ID;
  G_LOGIN_ID  CONSTANT NUMBER := FND_GLOBAL.LOGIN_ID;
 --akrangan ebtax billing impacts coding end
  PROCEDURE Bill_Upfront_Tax(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            p_khr_id             IN  NUMBER,
            p_trx_id             IN  NUMBER,
            p_invoice_date       IN  DATE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2);

End okl_bill_upfront_tax_pvt;


/
