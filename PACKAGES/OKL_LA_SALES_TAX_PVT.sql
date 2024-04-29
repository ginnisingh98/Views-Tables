--------------------------------------------------------
--  DDL for Package OKL_LA_SALES_TAX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LA_SALES_TAX_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSTXS.pls 120.4.12010000.2 2010/03/25 12:32:03 smadhava ship $ */

-- GLOBAL VARIABLES
---------------------------------------------------------------------------
g_api_type    CONSTANT VARCHAR2(4)      := '_PVT';
g_pkg_name    CONSTANT VARCHAR2(30)     := 'OKL_LA_SALES_TAX_PVT';
G_APP_NAME    CONSTANT VARCHAR2(3)      :=  OKL_API.G_APP_NAME;
G_BILLED      CONSTANT VARCHAR2(30)     :=  'BILLED';
G_FINANCED      CONSTANT VARCHAR2(30)   :=  'FINANCE';
G_CAPITALIZED     CONSTANT VARCHAR2(30) :=  'CAPITALIZE';
G_QA_SUCCESS   		CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_QA_SUCCESS';

---------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
-----------------------------------------------------------------------------------
  G_NO_PARENT_RECORD    CONSTANT  VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
  G_FND_APP		        CONSTANT  VARCHAR2(200) := OKL_API.G_FND_APP;
  G_REQUIRED_VALUE	    CONSTANT  VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE	    CONSTANT  VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_UNEXPECTED_ERROR    CONSTANT  VARCHAR2(200) := 'OKL_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN       CONSTANT  VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN       CONSTANT  VARCHAR2(200) := 'SQLcode';
  G_UPPERCASE_REQUIRED	CONSTANT  VARCHAR2(200) := 'OKL_CONTRACTS_UPPERCASE_REQ';
  G_COL_NAME_TOKEN      CONSTANT  VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
------------------------------------------------------------------------------------
-- GLOBAL EXCEPTION
------------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION             EXCEPTION;
  G_EXCEPTION_STOP_VALIDATION             EXCEPTION;
-----------------------------------------------------------------------------------
-- GLOBAL VARIABLES
-----------------------------------------------------------------------------------
--  G_API_TYPE                CONSTANT  VARCHAR2(4) := '_PVT';
  G_API_VERSION             CONSTANT  NUMBER      := 1.0;
  G_SCOPE                   CONSTANT  VARCHAR2(4) := '_PVT';

  subtype rgpv_rec_type IS OKL_RULE_PUB.rgpv_rec_type;
  subtype rulv_rec_type IS OKL_RULE_PUB.rulv_rec_type;
  subtype rulv_tbl_type IS OKL_RULE_PUB.rulv_tbl_type;

  subtype rgr_rec_type  IS okl_rgrp_rules_process_pvt.rgr_rec_type;

  PROCEDURE create_sales_tax_rules(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_chr_id                 IN  NUMBER,
            p_cle_id                 IN  NUMBER);

  PROCEDURE sync_contract_sales_tax(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_chr_id                 IN  NUMBER);
/*
  PROCEDURE sync_contract_sales_tax(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_chr_id                 IN  NUMBER,
            p_cle_id                 IN NUMBER);

  PROCEDURE validate_rules(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_chr_id                 IN  NUMBER,
            p_rgr_rec                IN  rgr_rec_type);
*/

  -- Main Sales Tax API to be called LLA Processes
  PROCEDURE process_sales_tax(
                      p_api_version      IN  NUMBER,
                      p_init_msg_list    IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      p_commit           IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      p_contract_id      IN  NUMBER,
                      p_transaction_type IN  VARCHAR2,
                      p_transaction_id   IN  NUMBER DEFAULT NULL,
                      p_transaction_date IN  DATE DEFAULT NULL,
                      p_rbk_contract_id  IN  NUMBER DEFAULT NULL,
                      x_return_status    OUT NOCOPY VARCHAR2,
                      x_msg_count        OUT NOCOPY NUMBER,
                      x_msg_data         OUT NOCOPY VARCHAR2);

  PROCEDURE check_sales_tax(
                            p_chr_id        IN NUMBER,
                            x_return_status OUT NOCOPY VARCHAR2
                           );
--Bug#4658944 ramurt
PROCEDURE check_sales_tax_asset_rules(
                     p_api_version       IN NUMBER,
                     p_init_msg_list     IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                     x_return_status     OUT NOCOPY VARCHAR2,
                     x_msg_count         OUT NOCOPY NUMBER,
                     x_msg_data          OUT NOCOPY VARCHAR2,
                     p_chr_id            IN NUMBER,
                     p_line_id           IN NUMBER,
                     p_rule_group_id     IN NUMBER,
                     p_rgr_rec           IN rgr_rec_type);

-----------------------------------------------------------------------------
 -- PROCEDURE validate_upfront_tax_fee
 -----------------------------------------------------------------------------
 -- Start of comments
 --
 -- Procedure Name  : validate_upfront_tax_fee
 -- Description     : Procedure will be called to validate upfront tax fee and
 --                   payments during online and batch contract activation.
 -- Business Rules  :
 -- Parameters      : p_chr_id
 -- Version         : 1.0
 -- History         : 24-Apr-2007 rpillay Created
 -- End of comments

  PROCEDURE validate_upfront_tax_fee(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_chr_id          IN  VARCHAR2);


-----------------------------------------------------------------------------
 -- PROCEDURE process_tax_override
 -----------------------------------------------------------------------------
 -- Start of comments
 --
 -- Procedure Name  : process_tax_override
 -- Description     : Procedure will be called to update upfront tax fee and
 --                   covered asset lines, and the contract and process statuses
 --                   when upfront tax overrides are performed.
 -- Business Rules  :
 -- Parameters      : p_chr_id
 --                   p_transaction_id
 -- Version         : 1.0
 -- History         : 24-Apr-2007 rpillay Created
 -- End of comments
 PROCEDURE process_tax_override(
            p_api_version      IN  NUMBER,
            p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            p_chr_id           IN  NUMBER,
            p_transaction_id   IN  NUMBER,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2
            );

-----------------------------------------------------------------------------
 -- PROCEDURE get_upfront_tax
 -----------------------------------------------------------------------------
 -- Start of comments
 --
 -- Procedure Name  : get_upfront_tax
 -- Description     : Function will be called to fetch the upfront tax amount
 --                   that has been Capitalized, Billed or Financed.
 -- Business Rules  :
 -- Parameters      : p_chr_id
 --                   p_tax_treatment
 -- Version         : 1.0
 -- History         : 10-May-2007 rpillay Created
 -- End of comments
FUNCTION get_upfront_tax(p_chr_id  IN NUMBER,
                         p_tax_treatment IN VARCHAR2)
RETURN NUMBER;

-----------------------------------------------------------------------------
 -- PROCEDURE check_prior_upfront_tax
 -----------------------------------------------------------------------------
 -- Start of comments
 --
 -- Procedure Name  : check_prior_upfront_tax
 -- Description     : Function to check if upfront tax has already been
 --                       calculated for this contract.
 -- Business Rules  :
 -- Parameters      : p_chr_id
  -- Version         : 1.0
 -- History         : 23-Mar-10 smadhava Created
 -- End of comments
FUNCTION check_prior_upfront_tax(p_chr_id  IN OKC_K_HEADERS_B.ID%TYPE)
RETURN BOOLEAN;

END OKL_LA_SALES_TAX_PVT;

/
