--------------------------------------------------------
--  DDL for Package OKL_FUNDING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_FUNDING_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLCFUNS.pls 120.17 2007/11/20 08:23:56 dcshanmu noship $ */
 ----------------------------------------------------------------------------
 -- GLOBAL VARIABLES
 ----------------------------------------------------------------------------
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_FUNDING_PVT';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
 G_OKL_FUNDING_APPROVER             CONSTANT VARCHAR2(200) := 'OKL_FUNDING_APPROVER';
 G_TRANSACTION_TYPE                 CONSTANT VARCHAR2(200) := 'Funding'; -- okl_trx_types_tl.name
 -- sjalasut, changed the constant value to point to OKL_TXL_AP_INV_LNS_B
 -- changes made as part of OKLR12B disbursements project
 G_OKL_FUNDING_SOURCE_TABLE         CONSTANT VARCHAR2(200) := 'OKL_TXL_AP_INV_LNS_B';
 G_OKL_SUBSIDY_SOURCE_TABLE         CONSTANT VARCHAR2(200) := 'OKL_TXL_AP_INV_LNS_B';
 G_STREAM_PREFUNDING                CONSTANT VARCHAR2(200) := 'PRE-FUNDING';
 G_STREAM_FUNDING                   CONSTANT VARCHAR2(200) := 'FUNDING';
 G_STREAM_PRINCIPAL_B_PAYMENT       CONSTANT VARCHAR2(200) := 'PRINCIPAL BALANCE';
 G_PREFUNDING_TYPE_CODE             CONSTANT VARCHAR2(200) := 'PREFUNDING';
 G_SUPPLIER_RETENTION_TYPE_CODE     CONSTANT VARCHAR2(200) := 'SUPPLIER_RETENTION';
 G_BORROWER_PAYMENT_TYPE_CODE       CONSTANT VARCHAR2(200) := 'BORROWER_PAYMENT';
 G_TRANSACTION_FUNDING              CONSTANT VARCHAR2(200) := 'Funding';
 G_TRANSACTION_DEBIT_MEMO           CONSTANT VARCHAR2(200) := 'Debit Memo';
 G_TRANSACTION_DISBURSEMENT         CONSTANT VARCHAR2(200) := 'Disbursement';
 G_ASSET_SUBSIDY                    CONSTANT VARCHAR2(200) := 'ASSET_SUBSIDY';
 G_ASSET_TYPE_CODE                  CONSTANT VARCHAR2(200) := 'ASSET';
 G_APPROVED                         CONSTANT VARCHAR2(200) := 'APPROVED';

 G_STANDARD                         CONSTANT VARCHAR2(200) := 'STANDARD';
 G_MANUAL_DISB                      CONSTANT VARCHAR2(200) := 'MANUAL_DISB';
 G_CREDIT                           CONSTANT VARCHAR2(200) := 'CREDIT';
 G_EXPENSE                          CONSTANT VARCHAR2(200) := 'EXPENSE';
 G_OKL_MANUAL_DISB_SOURCE_TABLE     CONSTANT VARCHAR2(200) := 'OKL_TXL_AP_INV_LNS_B';


 ----------------------------------------------------------------------------
 -- Data Structures
 ----------------------------------------------------------------------------
 subtype tapv_rec_type is okl_tap_pvt.tapv_rec_type;
 subtype tapv_tbl_type is okl_tap_pvt.tapv_tbl_type;
 subtype tplv_rec_type is okl_tpl_pvt.tplv_rec_type;
 subtype tplv_tbl_type is okl_tpl_pvt.tplv_tbl_type;
   type fnd_rec_type is RECORD
     (TOTAL_FUNDABLE_AMOUNT NUMBER,
      TOTAL_PRE_FUNDED NUMBER,
      TOTAL_ASSETS_FUNDED NUMBER,
      TOTAL_EXPENSES_FUNDED NUMBER,
      TOTAL_ADJUSTMENTS NUMBER,
      TOTAL_REMAINING_TO_FUND NUMBER,
      TOTAL_SUPPLIER_RETENTION NUMBER,
      TOTAL_BORROWER_PAYMENTS NUMBER,
      TOTAL_SUBSIDIES_FUNDED NUMBER,
      TOTAL_MANUAL_DISBURSEMENT NUMBER)
     ;

 ----------------------------------------------------------------------------
 -- Global Exception
 ----------------------------------------------------------------------------
 G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

 ----------------------------------------------------------------------------
 -- Procedures and Functions
 ------------------------------------------------------------------------------

 PROCEDURE get_fund_summary(
                p_api_version       IN NUMBER,
                p_init_msg_list     IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
                x_return_status     OUT NOCOPY VARCHAR2,
                x_msg_count         OUT NOCOPY NUMBER,
                x_msg_data          OUT NOCOPY VARCHAR2,
                p_contract_id       IN NUMBER,
		x_fnd_rec           OUT NOCOPY fnd_rec_type
                );

 PROCEDURE create_funding_header(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_tapv_rec                     IN tapv_rec_type
   ,x_tapv_rec                     OUT NOCOPY tapv_rec_type
 );

 PROCEDURE update_funding_header(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_tapv_rec                     IN tapv_rec_type
   ,x_tapv_rec                     OUT NOCOPY tapv_rec_type
 );

 PROCEDURE create_funding_lines(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_tplv_tbl                     IN tplv_tbl_type
   ,x_tplv_tbl                     OUT NOCOPY tplv_tbl_type
 );

 PROCEDURE create_funding_lines(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_hdr_id				IN NUMBER
   ,p_khr_id                     IN NUMBER
   ,p_vendor_site_id		IN NUMBER
   ,x_tplv_tbl                     OUT NOCOPY tplv_tbl_type
 );

 PROCEDURE update_funding_lines(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_tplv_tbl                     IN tplv_tbl_type
   ,x_tplv_tbl                     OUT NOCOPY tplv_tbl_type
 );

 PROCEDURE create_funding_assets(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_fund_id                      IN NUMBER
 );

 PROCEDURE SYNC_HEADER_AMOUNT(
  p_api_version                  IN NUMBER
 ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
 ,x_return_status                OUT NOCOPY VARCHAR2
 ,x_msg_count                    OUT NOCOPY NUMBER
 ,x_msg_data                     OUT NOCOPY VARCHAR2
 ,p_tplv_tbl                     IN tplv_tbl_type
 );

 PROCEDURE reverse_funding_requests(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_contract_id                  IN NUMBER
 );

-- Total contract funded adjustments
 FUNCTION get_chr_funded_adjs(
  p_contract_id                       IN NUMBER                 -- contract hdr
-- 12-09-2003 cklee
 ,p_vendor_site_id               IN NUMBER   DEFAULT OKL_API.G_MISS_NUM
 ) RETURN NUMBER;
 --PRAGMA RESTRICT_REFERENCES (get_chr_funded_adjs, TRUST);
------------------

-- Total contract allowable funded remaining
 FUNCTION get_chr_canbe_funded_rem(
  p_contract_id                       IN NUMBER                 -- contract hdr
 ) RETURN NUMBER;
 --PRAGMA RESTRICT_REFERENCES (get_chr_canbe_funded_rem, TRUST);

-- Total contract can be funded : used for pre-funding only
 FUNCTION get_chr_canbe_funded(
  p_contract_id                       IN NUMBER                 -- contract hdr
 ) RETURN NUMBER;
 --PRAGMA RESTRICT_REFERENCES (get_chr_canbe_funded, TRUST);

------------------
-- Total contract allowable oec funded remaining
 FUNCTION get_chr_oec_canbe_funded_rem(
  p_contract_id                       IN NUMBER                 -- contract hdr
 ) RETURN NUMBER;
 --PRAGMA RESTRICT_REFERENCES (get_chr_oec_canbe_funded_rem, TRUST);

-- Total contract can be funded oec amount
 FUNCTION get_chr_oec_canbe_funded(
  p_contract_id                       IN NUMBER                 -- contract hdr
 ) RETURN NUMBER;
 --PRAGMA RESTRICT_REFERENCES (get_chr_oec_canbe_funded, TRUST);

-- Total contract has been funded oec amount
 FUNCTION get_chr_oec_hasbeen_funded_amt(
  p_contract_id                       IN NUMBER                 -- contract hdr
 ,p_vendor_site_id               IN NUMBER   DEFAULT OKL_API.G_MISS_NUM
 ) RETURN NUMBER;
 --PRAGMA RESTRICT_REFERENCES (get_chr_oec_hasbeen_funded_amt, TRUST);

------------------

-- Total contract allowable expnese funded remaining
 FUNCTION get_chr_exp_canbe_funded_rem(
  p_contract_id                       IN NUMBER                 -- contract hdr
  ,p_vendor_site_id               IN NUMBER                 -- vendor_site_id
 ) RETURN NUMBER;
 --PRAGMA RESTRICT_REFERENCES (get_chr_exp_canbe_funded_rem, TRUST);

-- Total contract has been funded expense amount
 FUNCTION get_chr_exp_hasbeen_funded_amt(
  p_contract_id                       IN NUMBER                 -- contract hdr
  ,p_vendor_site_id               IN NUMBER                 -- vendor_site_id
 ) RETURN NUMBER;
 --PRAGMA RESTRICT_REFERENCES (get_chr_exp_hasbeen_funded_amt, TRUST);

-- Total contract can be funded expense amount
 FUNCTION get_chr_exp_canbe_funded_amt(
  p_contract_id                       IN NUMBER                 -- contract hdr
  ,p_vendor_site_id               IN NUMBER                 -- vendor_site_id
 ,p_due_date                     IN date  default sysdate   --cklee added) RETURN NUMBER
 ) RETURN NUMBER;
 --PRAGMA RESTRICT_REFERENCES (get_chr_exp_canbe_funded_amt, TRUST);

-- Total contract can be funded expense amount
 FUNCTION get_chr_exp_canbe_funded_amt(
  p_contract_id                       IN NUMBER                 -- contract hdr
  ,p_due_date                         IN date  default sysdate  --cklee added
 ) RETURN NUMBER;
 --PRAGMA RESTRICT_REFERENCES (get_chr_exp_canbe_funded_amt, TRUST);

-- Total contract has been funded expense amount
 FUNCTION get_chr_exp_hasbeen_funded_amt(
  p_contract_id                       IN NUMBER                 -- contract hdr
 ) RETURN NUMBER;
 --PRAGMA RESTRICT_REFERENCES (get_chr_exp_hasbeen_funded_amt, TRUST);

------------------
-- get line oec for contract funded
 FUNCTION get_contract_line_amt(
  p_khr_id                       IN NUMBER                 -- contract hdr
 ,p_kle_id                       IN NUMBER   DEFAULT OKL_API.G_MISS_NUM              -- contract line
 ,p_vendor_site_id               IN NUMBER   DEFAULT OKL_API.G_MISS_NUM
 ) RETURN NUMBER;
 --PRAGMA RESTRICT_REFERENCES (get_contract_line_amt, TRUST);

 FUNCTION get_contract_line_funded_amt(
    p_khr_id                       IN NUMBER
   ,p_kle_id                       IN NUMBER
   ,p_ref_type_code                IN VARCHAR2 DEFAULT OKL_API.G_MISS_CHAR
 ) RETURN NUMBER;
 --PRAGMA RESTRICT_REFERENCES (get_contract_line_funded_amt, TRUST);

 FUNCTION get_contract_line_funded_amt(
    p_fund_id                       IN NUMBER
    ,p_fund_type                    IN VARCHAR2
 ) RETURN NUMBER;
 --PRAGMA RESTRICT_REFERENCES (get_contract_line_funded_amt, TRUST);

 FUNCTION is_funding_unique(
  p_vendor_id                    IN NUMBER
 ,p_fund_number                  IN VARCHAR2
 ,p_org_id                       IN NUMBER  DEFAULT OKL_API.G_MISS_NUM
 ) RETURN VARCHAR2;

 FUNCTION is_contract_line_unique(
  p_kle_id                       IN NUMBER -- contract_line_id
 ,p_fund_id                      IN NUMBER
 ,p_fund_line_id                 IN NUMBER
 ,p_mode                         IN VARCHAR2 DEFAULT 'C'
 ,p_org_id                       IN NUMBER  DEFAULT OKL_API.G_MISS_NUM
 ) RETURN VARCHAR2;

 FUNCTION is_kle_id_unique(
    p_tplv_tbl                 IN tplv_tbl_type
 ) RETURN VARCHAR2;

-- Check to see if contract is legal to fund
 FUNCTION is_chr_fundable_status(
  p_contract_id                       IN NUMBER                 -- contract hdr
 ) RETURN NUMBER;
 --PRAGMA RESTRICT_REFERENCES (is_chr_fundable_status, TRUST);

------------------------------------------------------------------
 FUNCTION get_amount_prefunded(
 p_contract_id                   IN NUMBER
 ,p_vendor_site_id               IN NUMBER   DEFAULT OKL_API.G_MISS_NUM
 ) RETURN NUMBER;
 --PRAGMA RESTRICT_REFERENCES (get_amount_prefunded, TRUST);

 FUNCTION get_total_funded(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER  DEFAULT OKL_API.G_MISS_NUM
 ) RETURN NUMBER;
 --PRAGMA RESTRICT_REFERENCES (get_total_funded, TRUST);

 FUNCTION get_total_retention(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER  DEFAULT OKL_API.G_MISS_NUM
 ) RETURN NUMBER;
 --PRAGMA RESTRICT_REFERENCES (get_total_retention, TRUST);

-- added for bug 2604862
 FUNCTION get_amount_borrowerPay(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER  DEFAULT OKL_API.G_MISS_NUM
 ) RETURN NUMBER;
 --PRAGMA RESTRICT_REFERENCES (get_amount_borrowerPay, TRUST);

 FUNCTION get_creditRem_by_chrid(
  p_contract_id                       IN NUMBER                 -- contract hdr
 ) RETURN NUMBER;
 --PRAGMA RESTRICT_REFERENCES (get_creditRem_by_chrid, TRUST);
-- added for bug 2604862

  PROCEDURE CREATE_ACCOUNTING_DIST(p_api_version      IN  NUMBER,
                              p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                              x_return_status  OUT NOCOPY VARCHAR2,
                              x_msg_count      OUT NOCOPY NUMBER,
                              x_msg_data       OUT NOCOPY VARCHAR2,
                              p_status         IN  OKL_TRX_AP_INVOICES_B.trx_status_code%TYPE,
                              p_fund_id        IN  OKL_TRX_AP_INVOICES_B.ID%TYPE);--,| 21-May-2007 cklee    OKLR12B Accounting CR                                 |
--start:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |
-- 11.5.10 cklee subsidy
--                              p_fund_line_id   IN  OKL_TXL_AP_INV_LNS_B.ID%TYPE DEFAULT NULL,
--                              p_subsidy_amt    IN  NUMBER DEFAULT NULL,
--                              p_sty_id         IN  NUMBER DEFAULT NULL);
--end:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |

-- added for 11.5.10 subsidy
 FUNCTION get_funding_subsidy_amount(
    p_chr_id                       IN  NUMBER,
    p_asset_cle_id                 IN  NUMBER,
    p_vendor_site_id               IN  NUMBER DEFAULT NULL
 ) RETURN NUMBER;
 --PRAGMA RESTRICT_REFERENCES (get_funding_subsidy_amount, TRUST);

 FUNCTION get_partial_subsidy_amount(
    p_asset_cle_id                 IN  NUMBER,
    p_req_fund_amount              IN  NUMBER
 ) RETURN NUMBER;
 --PRAGMA RESTRICT_REFERENCES (get_partial_subsidy_amount, TRUST);

 FUNCTION get_amount_subsidy(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER  DEFAULT OKL_API.G_MISS_NUM  -- fixed asset ID
 ) RETURN NUMBER;
 --PRAGMA RESTRICT_REFERENCES (get_amount_subsidy, TRUST);

  PROCEDURE create_fund_asset_subsidies
                             (p_api_version    IN  NUMBER,
                              p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                              x_return_status  OUT NOCOPY VARCHAR2,
                              x_msg_count      OUT NOCOPY NUMBER,
                              x_msg_data       OUT NOCOPY VARCHAR2,
                              p_status         IN  OKL_TRX_AP_INVOICES_B.trx_status_code%TYPE,
                              p_fund_id        IN  OKL_TRX_AP_INVOICES_B.ID%TYPE);
-- added for 11.5.10 subsidy

 PROCEDURE refresh_fund_chklst(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_chr_id                       IN  okc_k_headers_b.id%type
   ,p_MLA_id                       IN  okc_k_headers_b.id%type DEFAULT NULL
   ,p_creditline_id                IN  okc_k_headers_b.id%type DEFAULT NULL
 );

 FUNCTION get_amount_manu_disb(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER  DEFAULT OKL_API.G_MISS_NUM  -- fixed asset ID
 ) RETURN NUMBER;
 --PRAGMA RESTRICT_REFERENCES (get_amount_manu_disb, TRUST);

-- strat: T and A 11/04/2004
-- Total contract can be funded fee amount
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : Total contract can be funded fee amount
-- Description     : Total contract can be funded fee amount for a fee line
--                   by an given date
--                   IN: p_contract_id is the lease contract ID
--                   IN: p_fee_line_id is the lease contract fee line ID
--                   IN: p_effective_date is the effective date of the total fee amount
--                   OUT: x_value is the fee amount
-- Business Rules  : x_value will be 0 if fee line has not meet the following requirements
--                 : 1. Effective date greater than line start date
--                      (or contract start date if line start date is null)
--                   2. contract okc_k_headers_b.ste_code
--                      in ('ENTERED', 'ACTIVE','SIGNED')
--                   3. fee line is not passthrough
--                   4. fee line is associated with vendor
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE contract_fee_canbe_funded(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,x_value                        OUT NOCOPY NUMBER
   ,p_contract_id                  IN NUMBER
   ,p_fee_line_id                  IN NUMBER
   ,p_effective_date               IN DATE
 );

 FUNCTION get_chr_fee_canbe_funded_amt(
  p_contract_id                IN NUMBER                 -- contract hdr
  ,p_fee_line_id               IN NUMBER
  ,p_effective_date            IN DATE
) RETURN NUMBER;
-- end: T and A 11/04/2004

-- strat: T and A bug#4151222
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : Is contract fully funded
-- Description     : Is contract fully funded
--                   IN: p_contract_id is the lease contract ID
--                   OUT: x_value is the flag to indicate if contract is fully funded
-- Business Rules  : x_value will be false if error occurred
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE is_contract_fully_funded(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,x_value                        OUT NOCOPY BOOLEAN
   ,p_contract_id                  IN NUMBER
 );

--Added procedure get_checklist_source as part of bug 5912358, Funding OA Migration Issues
 ----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : get_checklist_source
-- Description     : Returns checklist source details whether contract was originated from lease app, whether checklist exists or not and get source checklist template.
--                   IN: p_chr_id is the contract ID
--                   OUT: x_lease_app_found returns where contract was originated from leaseapp or not
--                   OUT: x_lease_app_list_found returns whether lease checklist exists or not
--                   OUT: x_funding_checklist_tpl returns source checklist template ID
--                   OUT: x_lease_app_id returns lease application id
--                   OUT: x_credit_id returns credit template id
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE get_checklist_source(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_chr_id                        IN okc_k_headers_b.id%type
   ,x_lease_app_found       OUT NOCOPY VARCHAR2
   ,x_lease_app_list_found OUT NOCOPY VARCHAR2
   ,x_funding_checklist_tpl OUT NOCOPY okc_rules_b.rule_information2%TYPE
   ,x_lease_app_id          OUT NOCOPY NUMBER
   ,x_credit_id                OUT NOCOPY NUMBER
 );

 FUNCTION is_contract_fully_funded(
  p_contract_id                IN NUMBER
 ) RETURN boolean;
-- end: T and A bug#4151222

-- start: 06-May-2005  cklee okl.h Lease App IA Authoring
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_checklist_function
-- Description     : This API will execute function for each item and
--                   update the execution results for the function.
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_checklist_function(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_fund_req_id                  IN  NUMBER
 );
-- end: 06-May-2005  cklee okl.h Lease App IA Authoring

END OKL_FUNDING_PVT;

/
