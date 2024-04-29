--------------------------------------------------------
--  DDL for Package OKL_COMBI_CASH_APP_RLS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_COMBI_CASH_APP_RLS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRCAAS.pls 120.3 2007/08/14 11:51:47 sosharma ship $ */
  --
  -- Purpose: Cash Application for Lock Box.
  --
  -- MODIFICATION HISTORY
  -- Person      Date        Comments
  -- ---------   ----------  ------------------------------------------
  -- Bruno.V     02/10/2002  Created.

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

  l_rcpt_tbl     okl_auto_cash_appl_rules_pvt.okl_rcpt_dtls_tbl_type;
  l_scn_rcpt_tbl okl_auto_cash_appl_rules_pvt.okl_rcpt_dtls_tbl_type;
  l_tmc_rcpt_tbl okl_auto_cash_appl_rules_pvt.okl_rcpt_dtls_tbl_type;
  l_initialize   okl_auto_cash_appl_rules_pvt.okl_rcpt_dtls_tbl_type;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

PROCEDURE handle_combi_pay( p_api_version	     IN	 NUMBER
  				             ,p_init_msg_list    IN	 VARCHAR2 DEFAULT Okc_Api.G_FALSE
				             ,x_return_status    OUT NOCOPY VARCHAR2
				             ,x_msg_count	     OUT NOCOPY NUMBER
				             ,x_msg_data	     OUT NOCOPY VARCHAR2
                             ,p_customer_number  IN  VARCHAR2 DEFAULT NULL
                             ,p_rcpt_amount      IN  NUMBER DEFAULT NULL
                             ,p_org_id           IN  NUMBER
                             ,p_currency_code    IN VARCHAR2
                             ,x_appl_tbl         OUT NOCOPY okl_auto_cash_appl_rules_pvt.okl_appl_dtls_tbl_type
							);

  PROCEDURE search_combi    ( p_api_version	     IN  NUMBER
   	                         ,p_init_msg_list    IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                             ,x_return_status    OUT NOCOPY VARCHAR2
                             ,x_msg_count	     OUT NOCOPY NUMBER
                             ,x_msg_data	     OUT NOCOPY VARCHAR2
                             ,p_customer_number  IN  VARCHAR2
                             ,p_cons_inv_number  IN  VARCHAR2
                             ,p_contract_number  IN  VARCHAR2
                             ,p_ar_inv_number    IN  VARCHAR2
                             ,p_org_id           IN  NUMBER
                             ,p_rcpt_amount      IN  NUMBER
                              ,p_currency_code    IN VARCHAR2
                             ,x_match_found      OUT NOCOPY NUMBER
                             ,x_appl_tbl         OUT NOCOPY okl_auto_cash_appl_rules_pvt.okl_appl_dtls_tbl_type
 						    );

END OKL_COMBI_CASH_APP_RLS_PVT;

/
