--------------------------------------------------------
--  DDL for Package OKL_PAY_INVOICES_CONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PAY_INVOICES_CONS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRPICS.pls 120.5 2007/11/08 21:34:59 cklee ship $ */
 ------------------------------------------------------------------------------
 -- Global Variables
 ------------------------------------------------------------------------------

 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_PAY_INVOICES_CONS_PVT';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';

 ----------------------------------------------------------------------------
 -- Data Structures
 ----------------------------------------------------------------------------
    TYPE disb_rules_type IS RECORD (
        dra_rec   OKL_DRA_PVT.dra_rec_type,
        drv_rec   OKL_DRV_PVT.drv_rec_type,
        drs_rec   OKL_DRS_PVT.drs_rec_type
      );

    TYPE disb_rules_tbl_type IS TABLE OF disb_rules_type
        INDEX BY BINARY_INTEGER;


 ---------------------------------------------------------------------------
 -- Procedures and Functions
 ---------------------------------------------------------------------------

PROCEDURE consolidation(p_api_version     IN  NUMBER
	               ,p_init_msg_list	      IN  VARCHAR2   DEFAULT OKC_API.G_FALSE
	               ,x_return_status	      OUT NOCOPY     VARCHAR2
	               ,x_msg_count           OUT NOCOPY     NUMBER
	               ,x_msg_data	          OUT NOCOPY     VARCHAR2
                   ,p_contract_number     IN VARCHAR2    DEFAULT NULL
 	               ,p_vendor              IN VARCHAR2    DEFAULT NULL
	               ,p_vendor_site         IN VARCHAR2    DEFAULT NULL
                   ,p_vpa_number          IN VARCHAR2    DEFAULT NULL
                   ,p_stream_type_purpose IN VARCHAR2    DEFAULT NULL
                   ,p_from_date           IN  DATE       DEFAULT NULL -- set p_from_date and p_to_date as not required
                   ,p_to_date             IN  DATE       DEFAULT NULL); -- set p_from_date and p_to_date as not required


--start: 31-Oct-2007  cklee -- bug: 6508575 fixed
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : get_ap_invoice_date
-- Description     : Get the AP invoice date based on the following:
--                  In p_transaction_date    : OKL internal invoice transaction date
--                  In p_vendor_id           : vendor id
--                  In p_vendor_site_id      : vendor site id
--                  In p_stream_type_purpose : stream type purpose
--                  In p_adv_grouping_flag   : advance grouping flag
--                   OUT: Consolidation invoice date
-- Business Rules  :
-- Business logic:
--   If criteria meet, set new invoice date as a grouping cirteria. Otherwise, set
--   invoice date as passed in transaction date.
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 FUNCTION get_ap_invoice_date(
 p_transaction_date            IN DATE
 ,p_vendor_id                  IN NUMBER
 ,p_vendor_site_id             IN NUMBER
 ,p_stream_type_purpose        IN VARCHAR2
 ,p_adv_grouping_flag          IN VARCHAR2 DEFAULT 'Y' -- reserved for future use
 ) RETURN DATE;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : get_Disbursement_group
-- Description     : Get Disbursement group
--                  In p_transaction_date    : OKL internal invoice transaction date
--                  In p_vendor_id           : vendor id
--                  In p_vendor_site_id      : vendor site id
--                  In p_stream_type_purpose : stream type purpose
--                  In p_adv_grouping_flag   : advance grouping flag
--                   OUT: Disbursement term
-- Business Rules  :
-- Business logic:
--   If criteria meet, set Term name as a grouping cirteria. Otherwise, set
--   stream type purpose as a grouping criteria.
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 FUNCTION get_Disbursement_group(
 p_transaction_date            IN DATE -- reserved for future use
 ,p_vendor_id                  IN NUMBER
 ,p_vendor_site_id             IN NUMBER
 ,p_stream_type_purpose        IN VARCHAR2
 ,p_adv_grouping_flag          IN VARCHAR2 DEFAULT 'Y' -- reserved for future use
 ) RETURN VARCHAR2;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : get_contract_group
-- Description     : get_contract_group
--                  In p_transaction_date    : OKL internal invoice transaction date
--                  In p_vendor_id           : vendor id
--                  In p_vendor_site_id      : vendor site id
--                  In p_stream_type_purpose : stream type purpose
--                  In p_adv_grouping_flag   : advance grouping flag
--                   OUT: Disbursement term
-- Business Rules  :
-- Business logic:
--   If criteria meet, set contract number as a grouping cirteria. Otherwise, set
-- contract number as null.
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 FUNCTION get_contract_group(
 p_transaction_date            IN DATE -- reserved for future use
 ,p_vendor_id                  IN NUMBER
 ,p_vendor_site_id             IN NUMBER
 ,p_stream_type_purpose        IN VARCHAR2
 ,p_contract_number            IN VARCHAR2
 ,p_adv_grouping_flag          IN VARCHAR2 DEFAULT 'Y' -- reserved for future use
 ) RETURN VARCHAR2;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : get_Disbursement_rule
-- Description     : Get Disbursement rule
--                  In p_transaction_date    : OKL internal invoice transaction date
--                  In p_vendor_id           : vendor id
--                  In p_vendor_site_id      : vendor site id
--                  In p_stream_type_purpose : stream type purpose
--                  In p_adv_grouping_flag   : advance grouping flag
--                   OUT: Disbursement term
-- Business Rules  :
-- Business logic:
--   If criteria meet, set Term name as a grouping cirteria. Otherwise, set
--   okl_txl_ap_inv_lns_all_b.id as a grouping criteria.
--   Note: No rule, no consolidation
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 FUNCTION get_Disbursement_rule(
 p_transaction_date            IN DATE -- reserved for future use
 ,p_okl_invoice_line_id        IN NUMBER -- okl_txl_ap_inv_lns_all_b.id
 ,p_vendor_id                  IN NUMBER
 ,p_vendor_site_id             IN NUMBER
 ,p_stream_type_purpose        IN VARCHAR2
 ,p_adv_grouping_flag          IN VARCHAR2 DEFAULT 'Y' -- reserved for future use
 ) RETURN VARCHAR2;

--end: 31-Oct-2007  cklee -- bug: 6508575 fixed

END OKL_PAY_INVOICES_CONS_PVT;

/
