--------------------------------------------------------
--  DDL for Package OKL_INVESTOR_BILLING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INVESTOR_BILLING_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRBCAS.pls 115.6 2003/08/04 20:55:12 pjgomes noship $ */

  ------------------------------------------------------------------------------
  -- Global Variables
  ------------------------------------------------------------------------------
  G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
  G_PKG_NAME	CONSTANT VARCHAR2(30)  := 'Okl_Investor_Billing_Pvt';
  G_APP_NAME CONSTANT VARCHAR2(30)  := 'OKL';

  ------------------------------------------------------------------------------
   --Global Exception
  ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION EXCEPTION;

  PROCEDURE create_billing_transaction
	(p_api_version		  IN  NUMBER
	,p_init_msg_list	  IN  VARCHAR2	DEFAULT Okl_Api.G_FALSE
	,x_return_status	  OUT NOCOPY VARCHAR2
	,x_msg_count		  OUT NOCOPY NUMBER
	,x_msg_data			  OUT NOCOPY VARCHAR2
	,p_tai_rec            IN  okl_tai_pvt.taiv_rec_type
	,p_til_tbl            IN  okl_til_pvt.tilv_tbl_type
    );

  PROCEDURE create_bill_txn_conc
        (errbuf	 OUT NOCOPY  VARCHAR2
	,retcode OUT NOCOPY  NUMBER
	,p_inv_agr            IN  NUMBER DEFAULT NULL
        ,p_investor_line_id   IN  NUMBER DEFAULT NULL
        );

  PROCEDURE create_investor_bill
	(p_api_version		  IN  NUMBER
	,p_init_msg_list	  IN  VARCHAR2	DEFAULT Okl_Api.G_FALSE
	,x_return_status	  OUT NOCOPY VARCHAR2
	,x_msg_count      OUT NOCOPY NUMBER
	,x_msg_data	  OUT NOCOPY VARCHAR2
	,p_inv_agr        IN  NUMBER DEFAULT NULL
        ,p_investor_line_id   IN  NUMBER DEFAULT NULL
    );

END Okl_Investor_Billing_Pvt;

 

/
