--------------------------------------------------------
--  DDL for Package OKL_ASSET_SUBSIDY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ASSET_SUBSIDY_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRASBS.pls 120.6 2005/12/12 20:25:30 cklee noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_ASSET_SUBSIDIES_UV Record Spec
  TYPE asb_rec_type IS RECORD (
       subsidy_id               NUMBER := OKL_API.G_MISS_NUM,
       subsidy_cle_id           NUMBER := OKL_API.G_MISS_NUM,
       name                     OKL_SUBSIDIES_B.NAME%TYPE := OKL_API.G_MISS_CHAR,
       description              OKL_SUBSIDIES_TL.SHORT_DESCRIPTION%TYPE := OKL_API.G_MISS_CHAR,
       amount                   NUMBER := OKL_API.G_MISS_NUM,
       subsidy_override_amount  NUMBER := OKL_API.G_MISS_NUM,
       dnz_chr_id               NUMBER := OKL_API.G_MISS_NUM,
       asset_cle_id             NUMBER := OKL_API.G_MISS_NUM,
       cpl_id                   NUMBER := OKL_API.G_MISS_NUM,
       vendor_id                NUMBER := OKL_API.G_MISS_NUM,
       vendor_name              PO_VENDORS.VENDOR_NAME%TYPE := OKL_API.G_MISS_CHAR
       );

   TYPE asb_tbl_type IS TABLE OF asb_rec_type
        INDEX BY BINARY_INTEGER;

  G_SUBLINE_LTY_CODE OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'SUBSIDY';
  G_STREAM_TYPE_CLASS OKL_STRM_TYPE_B.STREAM_TYPE_CLASS%TYPE := 'SUBSIDY';

   ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                      CONSTANT VARCHAR2(200) := OKL_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC   CONSTANT VARCHAR2(200) := OKL_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED          CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED          CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED     CONSTANT VARCHAR2(200) := OKL_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE               CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE                CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN               CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN           CONSTANT VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN            CONSTANT VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXP_ERROR';
  G_SQLCODE_TOKEN                CONSTANT VARCHAR2(200) := 'SQLcode';
  G_SQLERRM_TOKEN                CONSTANT VARCHAR2(200) := 'SQLerrm';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_ASSET_SUBSIDY_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  -- FUNCTION validate_subsidy_applicability
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : validate_subsidy_applicability
  -- Description     : function returns Y if the subsidy applicability criteria are met
  --                 : N otherwise
  --
  -- Parameters      : requires p_subsidy_id to be passed
  --                 : p_asset_cle_id , the asset id
  --                 : p_qa_checker_call - this parameter is defaulted for backward compatibility
  --                   the value is N for all cases except when called from OKL_QA_DATA_INTEGRITY.check_subsidies_errors
  -- Version         : 1.0
  -- History         : 07-FEB-2005 SJALASUT modified
  -- End of comments

  FUNCTION validate_subsidy_applicability(p_subsidy_id    IN  NUMBER
                                          ,p_asset_cle_id  IN  NUMBER
                                          ,p_qa_checker_call IN VARCHAR2 DEFAULT 'N') RETURN VARCHAR2;

  --Bug# 3320760 :
  Function validate_subsidy_applicability(p_subsidy_id          IN  NUMBER,
                                          p_chr_id              IN  NUMBER,
                                          p_start_date          IN  DATE,
                                          p_inv_item_id         IN  NUMBER,
                                          p_inv_org_id          IN  NUMBER,
                                          p_install_site_use_id IN NUMBER
                                          ) Return Varchar2;

-- start 29-June-2005 cklee -  okl.h Sales Quote IA Subsidies
  -------------------------------------------------------------------------------
  -- FUNCTION validate_subsidy_applicability
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : validate_subsidy_applicability
  -- Description     : function returns Y if the subsidy is applicable for the
  --                 : passed in Sales Quote/Lease Application asset
  --                 : N otherwise
  --
  -- Parameters      : requires parameters:
  --                   p_subsidy_id         : Subsidy ID
  --                   p_start_date         : Sales Quote/Lease App's asset start date
  --                   p_inv_item_id        : Inventory Item ID
  --obsolete                   p_install_site_use_id: Install Site use ID
  --                   p_currency_code      : Sales Quote/Lease App's currency code
  --                   p_authoring_org_id   : Sales Quote/Lease App's operating unit ID
  --                   p_cust_account_id    : Sales Quote/Lease App's customer account ID
  --                   p_pdt_id             : Financial product ID
  --                   p_sales_rep_id       : Sales Representative ID
  --
  --                   p_tot_subsidy_amount : The total asset subsidy amount for the Quote/Lease
  --                                          application up to the validation point.
  --
  --                                         For example,
  --                                         Quote has 3 assets with subsidy
  --                                         Asset1, sub1, $1,000 : p_tot_subsidy_amount = $1,000
  --                                         Asset2, sub1, $1,000 : p_tot_subsidy_amount = $2,000
  --                                         Asset3, sub1, $1,000 : p_tot_subsidy_amount = $3,000
  --
  --                                         API will check if the accumulated subsidy amount exceed
  --                                         the pool balance.
  --                   p_subsidy_amount     : Calculated subsidy amount based on Quote/Lease
  --                                          application system. API will also check if
  --                                          subsidy amount exceed the pool balance
  --                   p_filter_flag        : Y/N to indicate if used for LOV filterring
  --                   p_dnz_asset_number   : Quote/Lease app asset number used for error message
  --
  -- Validation rules:
  --                   System will not have FK check for the passed in parameters.
  --                   Instead, system will check the applicability between the passed
  --                   in parametrs and the details criteria for the passed in
  --                   Subsidy.
  --
  -- Version         : 1.0
  -- History         : 29-June-2005 cklee created
  -- End of comments
  Function validate_subsidy_applicability(p_subsidy_id          IN  NUMBER,
                                          p_start_date          IN  DATE,
                                          p_inv_item_id         IN  NUMBER,
                                          p_inv_org_id          IN  NUMBER,
--obsolete                                          p_install_site_use_id IN  NUMBER,
                                          p_currency_code       IN  VARCHAR2,
                                          p_authoring_org_id    IN  NUMBER,
                                          p_cust_account_id     IN  NUMBER,
                                          p_pdt_id              IN  NUMBER,
                                          p_sales_rep_id        IN  NUMBER,
--START: 09-Dec-2005  cklee - Fixed bug#4874385                           |
                                          p_tot_subsidy_amount  IN  NUMBER DEFAULT 0,
                                          p_subsidy_amount      IN  NUMBER DEFAULT 0,
                                          p_filter_flag         IN  VARCHAR2 DEFAULT 'Y',
                                          p_dnz_asset_number    IN  VARCHAR2 DEFAULT NULL
--END: 09-Dec-2005  cklee - Fixed bug#4874385                           |
                                          ) Return Varchar2;
-- end:  29-June-2005 cklee -  okl.h Sales Quote IA Subsidies


  -- sjalasut added new function for subsidy pools enhancement
  -------------------------------------------------------------------------------
  -- FUNCTION validate_subsidy_pool_applic
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : validate_subsidy_pool_applic
  -- Description     : function returns Y if the subsidy is associated with a subsidy pool
  --                 : is valid for the pool transaction
  --                 : N otherwise
  --
  -- Parameters      : requires p_subsidy_id to be passed
  --                 : for contract p_asset_cle_id is required
  --                 : for sales quote, p_asset_cle_id is not required but need to pass
  --                   p_ast_date_sq and p_trx_curr_code_sq
  -- Version         : 1.0
  -- History         : 07-FEB-2005 SJALASUT created
  -- End of comments

  FUNCTION validate_subsidy_pool_applic(p_subsidy_id          IN okl_subsidies_b.id%TYPE,
                                        p_asset_cle_id        IN okc_k_lines_b.id%TYPE,
                                        p_ast_date_sq         IN okc_k_lines_b.start_date%TYPE,
                                        p_trx_curr_code_sq    IN okc_k_lines_b.currency_code%TYPE,
--START: 09-Dec-2005  cklee - Fixed bug#4874385                           |
                                        p_tot_subsidy_amount  IN  NUMBER DEFAULT 0,
                                        p_subsidy_amount      IN  NUMBER DEFAULT 0,
                                        p_filter_flag         IN  VARCHAR2 DEFAULT 'Y',
                                        p_dnz_asset_number    IN  VARCHAR2 DEFAULT NULL
--END: 09-Dec-2005  cklee - Fixed bug#4874385                           |
                                        ) RETURN VARCHAR2;
  -------------------------------------------------------------------------------
  -- FUNCTION is_sub_assoc_with_pool
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : is_sub_assoc_with_pool
  -- Description     : function returns Y if the subsidy is associated with a subsidy pool
  --                 : N otherwise
  --
  -- Parameters      : requires p_subsidy_id to be passed
  --                   OUT x_subsidy_pool_id is returned with the subsidy pool id if the
  --                   subsidy is associated with a pool
  -- Version         : 1.0
  -- History         : 07-FEB-2005 SJALASUT created
  -- End of comments

  FUNCTION is_sub_assoc_with_pool(p_subsidy_id IN okl_subsidies_b.id%TYPE
                                  ,x_subsidy_pool_id OUT NOCOPY okl_subsidy_pools_b.id%TYPE
                                  ,x_sub_pool_curr_code OUT NOCOPY okl_subsidy_pools_b.currency_code%TYPE) RETURN VARCHAR2;

  -------------------------------------------------------------------------------
  -- FUNCTION is_sub_pool_active
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : is_sub_pool_active
  -- Description     : function returns Y if the decision_status_code for the subsidy pool id is ACTIVE
  --                   and sysdate lies between the effective dates of the subsidy pool
  --                   N otherwise
  --
  -- Parameters      : IN p_subsidy_pool_id
  --                   OUT x_pool_status on the pool record.
  -- Version         : 1.0
  -- History         : 07-FEB-2005 SJALASUT created
  -- End of comments

  FUNCTION is_sub_pool_active (p_subsidy_pool_id IN okl_subsidy_pools_b.id%TYPE
                                       ,x_pool_status OUT NOCOPY okl_subsidy_pools_b.decision_status_code%TYPE) RETURN VARCHAR2;

  -------------------------------------------------------------------------------
  -- FUNCTION is_sub_pool_active_by_date
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : is_sub_pool_active_by_date
  -- Description     : function returns Y if the asset date falls between the subsidy pool effective dates
  --                 : N otherwise
  --
  -- Business Rules  :
  --
  -- Parameters      : IN p_subsidy_pool_id
  --                   IN p_asset_date
  -- Version         : 1.0
  -- History         : 07-FEB-2005 SJALASUT created
  -- End of comments

  FUNCTION is_sub_pool_active_by_date (p_subsidy_pool_id IN okl_subsidy_pools_b.id%TYPE
                                       ,p_asset_date IN okc_k_lines_b.start_date%TYPE
                                       ) RETURN VARCHAR2;

  -------------------------------------------------------------------------------
  -- FUNCTION is_sub_pool_conv_rate_valid
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : is_sub_pool_conv_rate_valid
  -- Description     : returns Y if the conversion rate as on the specified asset date is available
  --                   N therwise
  --
  -- Parameters      : IN p_subsidy_pool_id
  --                   IN p_asset_date this is defaulted to sysdate as of this enhancement
  --                   IN p_trx_currency_code
  --                   OUT x_conversion_rate
  -- Version         : 1.0
  -- History         : 07-FEB-2005 SJALASUT created
  -- End of comments

  FUNCTION is_sub_pool_conv_rate_valid(p_subsidy_pool_id IN okl_subsidy_pools_b.id%TYPE
                                       ,p_asset_date IN okc_k_lines_b.start_date%TYPE
                                       ,p_trx_currency_code IN okc_k_headers_b.currency_code%TYPE
                                       ,x_conversion_rate OUT NOCOPY NUMBER) RETURN VARCHAR2;
  -------------------------------------------------------------------------------
  -- FUNCTION is_balance_valid_before_add
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : is_balance_valid_before_add
  -- Description     : for the context subsidy pool, this function returns Y if there exists a valid
  --                   pool balance, N otherwise
  -- Parameters      : IN p_subsidy_pool_id
  --                   OUT x_pool_balance
  -- Version         : 1.0
  -- History         : 07-FEB-2005 SJALASUT created
  -- End of comments

  FUNCTION is_balance_valid_before_add (p_subsidy_pool_id IN okl_subsidy_pools_b.id%TYPE
                                      , x_pool_balance OUT NOCOPY NUMBER) RETURN VARCHAR2;


  -------------------------------------------------------------------------------
  -- PROCEDURE is_balance_valid_after_add
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : is_balance_valid_after_add
  -- Description     : for the context subsidy pool, this function returns Y if there exists a valid
  --                   pool balance after adding the subsidy amount to the pool in pool currency, N otherwise
  -- Parameters      : IN p_asb_rec asb_rec_type
  -- Version         : 1.0
  -- History         : 07-FEB-2005 SJALASUT created
  -- End of comments

  PROCEDURE is_balance_valid_after_add (p_subsidy_id      IN okl_subsidies_b.id%TYPE
                                        ,p_asset_id       IN okc_k_lines_b.id%TYPE
                                        ,p_subsidy_amount IN NUMBER
                                        ,p_subsidy_name   IN okl_subsidies_b.name%TYPE
                                        ,x_return_status  OUT NOCOPY VARCHAR2
                                        ,x_msg_count      OUT NOCOPY NUMBER
                                        ,x_msg_data       OUT NOCOPY VARCHAR2
                                      );

--START: 09-Dec-2005  cklee - Fixed bug#4874385                           |
  -------------------------------------------------------------------------------
  -- PROCEDURE is_balance_valid_after_add : for Sales Quote and Lease application
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : is_balance_valid_after_add
  -- Description     : for the context subsidy pool, this function returns Y if there exists a valid
  --                   pool balance after adding the subsidy amount to the pool in pool currency, N otherwise
  -- Parameters      : IN p_asb_rec asb_rec_type
  -- Version         : 1.0
  -- History         : 07-Dec-2005 cklee created
  -- End of comments

  PROCEDURE is_balance_valid_after_add (p_subsidy_id          IN  okl_subsidies_b.id%TYPE
                                        ,p_currency_code      IN  VARCHAR2
                                        ,p_subsidy_amount     IN  NUMBER
                                        ,p_tot_subsidy_amount IN  NUMBER
                                        ,p_dnz_asset_number   IN  VARCHAR2
                                        ,x_return_status      OUT NOCOPY VARCHAR2
                                        ,x_msg_count          OUT NOCOPY NUMBER
                                        ,x_msg_data           OUT NOCOPY VARCHAR2
                                      );
--END: 09-Dec-2005  cklee - Fixed bug#4874385                           |

  PROCEDURE create_asset_subsidy(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_asb_rec                      IN  asb_rec_type,
      x_asb_rec                      OUT NOCOPY  asb_rec_type);

  PROCEDURE create_asset_subsidy(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_asb_tbl                      IN  asb_tbl_type,
      x_asb_tbl                      OUT NOCOPY  asb_tbl_type);

  PROCEDURE update_asset_subsidy(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_asb_rec                      IN  asb_rec_type,
      x_asb_rec                      OUT NOCOPY  asb_rec_type);

  PROCEDURE update_asset_subsidy(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_asb_tbl                      IN  asb_tbl_type,
      x_asb_tbl                      OUT NOCOPY  asb_tbl_type);


  PROCEDURE delete_asset_subsidy(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_asb_rec                      IN  asb_rec_type);

  PROCEDURE delete_asset_subsidy(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_asb_tbl                      IN  asb_tbl_type);

  PROCEDURE validate_asset_subsidy(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_asb_rec                      IN  asb_rec_type);

  PROCEDURE validate_asset_subsidy(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_asb_tbl                      IN  asb_tbl_type);

  PROCEDURE calculate_asset_subsidy(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_asb_rec                      IN  asb_rec_type,
      x_asb_rec                      OUT NOCOPY  asb_rec_type);

  PROCEDURE calculate_asset_subsidy(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_asb_tbl                      IN  asb_tbl_type,
      x_asb_tbl                      OUT NOCOPY  asb_tbl_type);


END OKL_ASSET_SUBSIDY_PVT;

 

/
