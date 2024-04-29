--------------------------------------------------------
--  DDL for Package OKL_ACCT_SOURCES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ACCT_SOURCES_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPASES.pls 120.2 2005/10/30 04:01:23 appldev noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';

  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okc_Api.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_ACCT_SOURCES_PUB';

  SUBTYPE asev_rec_type IS Okl_Ase_Pvt.asev_rec_type;
  SUBTYPE asev_tbl_type IS Okl_Ase_Pvt.asev_tbl_type;


/*============================================================================
|                                                                            |
|  Procedure    : update_acct_src_custom_status                              |
|  Description  : Procedure to update only the custom status. This will be   |
|                 updated once the accounting sources are processed by the   |
|                 customer. This will be used at customization.              |
|  Parameters   : p_account_source_id - ID of the account sources record     |
|		  which requires to be updated.				     |
|		  p_custom_status - New status to which the account sources  |
|		  record to be updated					     |
|  History      : 07-05-04 santonyr    -- Created                            |
|                                                                            |
*============================================================================*/


  PROCEDURE update_acct_src_custom_status(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_account_source_id		   IN NUMBER,
    p_custom_status		   IN VARCHAR2);

END Okl_acct_sources_Pub;

 

/
