--------------------------------------------------------
--  DDL for Package OKL_PAY_INVOICES_CONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PAY_INVOICES_CONS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPPICS.pls 120.4 2007/05/07 23:04:22 ssiruvol ship $ */

------------------------------------------------------------------------------
 -- Global Variables
 ------------------------------------------------------------------------------

 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_PAY_INVOICES_CONS_PVT';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';

 ---------------------------------------------------------------------------
 -- Procedures and Functions
 ---------------------------------------------------------------------------

PROCEDURE consolidation(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2	DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		    OUT NOCOPY VARCHAR2
--start:|  24-APR-2007  cklee Disbursement changes for R12B                          |
    ,p_contract_number     IN VARCHAR2    DEFAULT NULL
 	,p_vendor           IN VARCHAR2      DEFAULT NULL
	,p_vendor_site      IN VARCHAR2      DEFAULT NULL
    ,p_vpa_number              IN VARCHAR2      DEFAULT NULL
    ,p_stream_type_purpose IN VARCHAR2    DEFAULT NULL
--end:|  24-APR-2007  cklee Disbursement changes for R12B                          |
    ,p_from_date        IN  DATE DEFAULT NULL -- set p_from_date and p_to_date as not required
    ,p_to_date          IN  DATE DEFAULT NULL); -- set p_from_date and p_to_date as not required

  PROCEDURE consolidation_inv
  ( errbuf             OUT NOCOPY VARCHAR2
   ,retcode            OUT NOCOPY NUMBER
--start:|  24-APR-2007  cklee Disbursement changes for R12B                          |
    ,p_contract_number     IN VARCHAR2    DEFAULT NULL
 	,p_vendor           IN VARCHAR2      DEFAULT NULL
	,p_vendor_site      IN VARCHAR2      DEFAULT NULL
    ,p_vpa_number              IN VARCHAR2      DEFAULT NULL
    ,p_stream_type_purpose IN VARCHAR2    DEFAULT NULL
--end:|  24-APR-2007  cklee Disbursement changes for R12B                          |
   ,p_from_date        IN  VARCHAR2 DEFAULT NULL -- set p_from_date and p_to_date as not required
   ,p_to_date          IN  VARCHAR2 DEFAULT NULL); -- set p_from_date and p_to_date as not required


END;

/
