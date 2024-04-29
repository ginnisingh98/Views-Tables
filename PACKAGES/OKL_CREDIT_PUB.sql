--------------------------------------------------------
--  DDL for Package OKL_CREDIT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CREDIT_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPCRDS.pls 120.11 2008/02/29 10:51:29 asawanka ship $ */
/*#
 * Credit API allows users to perform actions on credit lines
 * and credit limits in Lease Management.
 * @rep:scope public
 * @rep:product OKL
 * @rep:displayname Credit API
 * @rep:category BUSINESS_ENTITY AR_CREDIT_REQUEST
 * @rep:lifecycle active
 * @rep:compatibility S
 */

/* Declarations */

  SUBTYPE khrv_rec_type IS OKL_KHR_pvt.khrv_rec_type;
  SUBTYPE khrv_tbl_type IS OKL_KHR_pvt.khrv_tbl_type;
  SUBTYPE klev_rec_type IS okl_kle_pvt.klev_rec_type;
  SUBTYPE klev_tbl_type IS okl_kle_pvt.klev_tbl_type;

  TYPE clev_rec_type IS RECORD (
    id                             NUMBER                              := OKC_API.G_MISS_NUM,
    chr_id                         NUMBER                              := OKC_API.G_MISS_NUM,
    lse_id                         NUMBER                              := OKC_API.G_MISS_NUM,
    line_number                    OKC_K_LINES_V.LINE_NUMBER%TYPE      := OKC_API.G_MISS_CHAR,
    sts_code                       OKC_K_LINES_V.STS_CODE%TYPE         := OKC_API.G_MISS_CHAR,
    display_sequence               NUMBER                              := OKC_API.G_MISS_NUM,
    dnz_chr_id                     NUMBER                              := OKC_API.G_MISS_NUM,
    item_description               OKC_K_LINES_V.ITEM_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    exception_yn                   OKC_K_LINES_V.EXCEPTION_YN%TYPE     := OKC_API.G_MISS_CHAR,
    start_date                     OKC_K_LINES_V.START_DATE%TYPE       := OKC_API.G_MISS_DATE
    );

  TYPE clev_tbl_type IS TABLE OF clev_rec_type
        INDEX BY BINARY_INTEGER;

  TYPE crdv_rec_type IS RECORD (
    id                           NUMBER                                      := OKC_API.G_MISS_NUM,
    contract_number              OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE        := OKC_API.G_MISS_CHAR,
    description                  OKC_K_HEADERS_V.DESCRIPTION%TYPE            := OKC_API.G_MISS_CHAR,
    party_roles_id               NUMBER                                      := OKC_API.G_MISS_NUM,
    customer_id1                 OKC_K_PARTY_ROLES_B.OBJECT1_ID1%TYPE        := OKC_API.G_MISS_CHAR,
    customer_id2                 OKC_K_PARTY_ROLES_B.OBJECT1_ID2%TYPE        := OKC_API.G_MISS_CHAR,
    customer_code                OKC_K_PARTY_ROLES_B.JTOT_OBJECT1_CODE%TYPE  := OKC_API.G_MISS_CHAR,
    customer_name                OKX_PARTIES_V.NAME%TYPE                     := OKC_API.G_MISS_CHAR,
    effective_from               OKC_K_HEADERS_V.START_DATE%TYPE             := OKC_API.G_MISS_DATE,
    effective_to                 OKC_K_HEADERS_V.END_DATE%TYPE               := OKC_API.G_MISS_DATE,
    currency_code                OKC_K_HEADERS_V.CURRENCY_CODE%TYPE          := OKC_API.G_MISS_CHAR,
    currency_conv_type           OKL_K_HEADERS.CURRENCY_CONVERSION_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conv_rate           NUMBER                                      := OKC_API.G_MISS_NUM,
    currency_conv_date           OKL_K_HEADERS.CURRENCY_CONVERSION_DATE%TYPE := OKC_API.G_MISS_DATE,
    revolving_credit_yn          OKL_K_HEADERS.REVOLVING_CREDIT_YN%TYPE      := OKC_API.G_MISS_CHAR,
    sts_code                     OKC_K_HEADERS_V.STS_CODE%TYPE               := OKC_API.G_MISS_CHAR,
    credit_ckl_id                NUMBER                                      := OKC_API.G_MISS_NUM,
    funding_ckl_id               NUMBER                                      := OKC_API.G_MISS_NUM,
    chklst_tpl_rgp_id            NUMBER                                      := OKC_API.G_MISS_NUM,
    chklst_tpl_rule_id           NUMBER                                      := OKC_API.G_MISS_NUM,
    cust_acct_id                 NUMBER                                      := OKC_API.G_MISS_NUM,
    cust_acct_number             OKX_CUSTOMER_ACCOUNTS_V.DESCRIPTION%TYPE    := OKC_API.G_MISS_CHAR
    );

  TYPE crdv_tbl_type IS TABLE OF crdv_rec_type
        INDEX BY BINARY_INTEGER;

  TYPE clmv_rec_type IS RECORD (
    id                           NUMBER                              := OKC_API.G_MISS_NUM,
    chr_id                       NUMBER                              := OKC_API.G_MISS_NUM,
    item_description             OKC_K_LINES_V.ITEM_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    start_date                   OKC_K_LINES_V.START_DATE%TYPE       := OKC_API.G_MISS_DATE,
    credit_nature                OKL_K_LINES.CREDIT_NATURE%TYPE      := OKC_API.G_MISS_CHAR,
    amount                       NUMBER                              := OKC_API.G_MISS_NUM
    );

  TYPE clmv_tbl_type IS TABLE OF clmv_rec_type
        INDEX BY BINARY_INTEGER;

  -------------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_CREDIT_PUB';
  G_APP_NAME			CONSTANT VARCHAR2(3)   := 'OKL';
  ---------------------------------------------------------------------------

/*#
 * Create credit line and credit limit.
 * @param p_api_version API version
 * @param p_init_msg_list  Initialize message stack
 * @param x_return_status Return status from the API
 * @param x_msg_count Message count if error messages are encountered
 * @param x_msg_data Error message data
 * @param p_crdv_rec Credit line record
 * @param p_clmv_tbl Credit limit table
 * @param x_crdv_rec Credit line record
 * @param x_clmv_tbl Credit limit table
 * @rep:displayname Create Credit Line and Credit Limit
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY OKL_UNDERWRITING
 */
  PROCEDURE create_credit(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crdv_rec                     IN  crdv_rec_type,
    p_clmv_tbl                     IN  clmv_tbl_type,
    x_crdv_rec                     OUT NOCOPY crdv_rec_type,
    x_clmv_tbl                     OUT NOCOPY clmv_tbl_type);

  PROCEDURE create_credit(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
--
    p_contract_number              IN  VARCHAR2,
    p_description                  IN  VARCHAR2,
--    p_version_no                   IN  VARCHAR2,
--    p_scs_code                     IN  VARCHAR2,
    p_customer_id1                 IN  VARCHAR2,
    p_customer_id2                 IN  VARCHAR2,
    p_customer_code                IN  VARCHAR2,
    p_customer_name                IN  VARCHAR2,
    p_effective_from               IN  DATE,
    p_effective_to                 IN  DATE,
    p_currency_code                IN  VARCHAR2,
-- multi-currency support
    p_currency_conv_type           IN  VARCHAR2,
    p_currency_conv_rate           IN  NUMBER,
    p_currency_conv_date           IN  DATE,
-- multi-currency support
    p_revolving_credit_yn          IN  VARCHAR2,
    p_sts_code                     IN  VARCHAR2,
-- funding checklist enhancement
    p_credit_ckl_id                IN  NUMBER DEFAULT NULL, -- 11.5.10 ER
    p_funding_ckl_id               IN  NUMBER DEFAULT NULL, -- 11.5.10 ER
-- funding checklist enhancement
    p_cust_acct_id                 IN  NUMBER DEFAULT NULL, -- 11.5.10 rule migration project
    p_cust_acct_number             IN  VARCHAR2 DEFAULT NULL, -- 11.5.10 rule migration project
    p_org_id                       IN  NUMBER DEFAULT NULL,
    p_organization_id              IN  NUMBER DEFAULT NULL,
    p_source_chr_id                IN  NUMBER DEFAULT NULL,
    x_chr_id                       OUT NOCOPY NUMBER);

---
   PROCEDURE create_credit_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
-- funding checklist enhancement
    p_credit_ckl_id                IN  NUMBER DEFAULT NULL, -- 11.5.10 ER
    p_funding_ckl_id               IN  NUMBER DEFAULT NULL, -- 11.5.10 ER
-- funding checklist enhancement
    p_chrv_rec                     IN  okl_okc_migration_pvt.chrv_rec_type,
    p_khrv_rec                     IN  khrv_rec_type,
    x_chrv_rec                     OUT NOCOPY okl_okc_migration_pvt.chrv_rec_type,
    x_khrv_rec                     OUT NOCOPY khrv_rec_type);

  PROCEDURE update_credit_header(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update            IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
-- funding checklist enhancement
    p_chklst_tpl_rgp_id            IN  NUMBER DEFAULT NULL, -- 11.5.10 ER
    p_chklst_tpl_rule_id           IN  NUMBER DEFAULT NULL, -- 11.5.10 ER
    p_credit_ckl_id                IN  NUMBER DEFAULT NULL, -- 11.5.10 ER
    p_funding_ckl_id               IN  NUMBER DEFAULT NULL, -- 11.5.10 ER
-- funding checklist enhancement
    p_chrv_rec                     IN  okl_okc_migration_pvt.chrv_rec_type,
    p_khrv_rec                     IN  khrv_rec_type,
    x_chrv_rec                     OUT NOCOPY okl_okc_migration_pvt.chrv_rec_type,
    x_khrv_rec                     OUT NOCOPY khrv_rec_type);

  PROCEDURE validate_credit(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_contract_number              IN  VARCHAR2,
    p_description                  IN  VARCHAR2,
    p_customer_id1                 IN  VARCHAR2,
    p_customer_id2                 IN  VARCHAR2,
    p_customer_code                IN  VARCHAR2,
    p_customer_name                IN  VARCHAR2,
    p_effective_from               IN  DATE,
    p_effective_to                 IN  DATE,
    p_currency_code                IN  VARCHAR2,
-- multi-currency support
    p_currency_conv_type           IN  VARCHAR2,
    p_currency_conv_rate           IN  NUMBER,
    p_currency_conv_date           IN  DATE,
-- multi-currency support
-- funding checklist enhancement
    p_credit_ckl_id                IN  NUMBER DEFAULT NULL, -- 11.5.10 ER
    p_funding_ckl_id               IN  NUMBER DEFAULT NULL, -- 11.5.10 ER
-- funding checklist enhancement
    p_cust_acct_id                 IN  NUMBER DEFAULT NULL, -- 11.5.10 rule migration project
    p_cust_acct_number             IN  VARCHAR2 DEFAULT NULL, -- 11.5.10 rule migration project
    p_sts_code                     IN  VARCHAR2);

  PROCEDURE validate_account_number(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_account_number               IN  VARCHAR2);

  PROCEDURE validate_credit_limit(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mode                         IN  VARCHAR2 DEFAULT 'CREATE',
    p_chr_id                       IN  NUMBER,
    p_cle_id                       IN  NUMBER   DEFAULT OKL_API.G_MISS_NUM,
    p_cle_start_date               IN  DATE,
    p_description                  IN  VARCHAR2 DEFAULT OKL_API.G_MISS_CHAR,
    p_credit_nature                IN  VARCHAR2,
    p_amount                       IN  NUMBER DEFAULT 0);

  PROCEDURE validate_credit_limit(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mode                         IN  VARCHAR2 DEFAULT 'CREATE',
    p_clev_rec                     IN  okl_okc_migration_pvt.clev_rec_type,
--    p_clev_rec                     IN  clev_rec_type,
    p_klev_rec                     IN  klev_rec_type);

  PROCEDURE validate_credit_limit(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mode                         IN  VARCHAR2 DEFAULT 'CREATE',
    p_clev_tbl                     IN  okl_okc_migration_pvt.clev_tbl_type,
--    p_clev_tbl                     IN  clev_tbl_type,
    p_klev_tbl                     IN  klev_tbl_type);

  PROCEDURE create_credit_limit(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
--    p_clev_tbl                     IN  okl_okc_migration_pvt.clev_tbl_type,
    p_clev_tbl                     IN  clev_tbl_type,
    p_klev_tbl                     IN  klev_tbl_type,
--    x_clev_tbl                     OUT NOCOPY okl_okc_migration_pvt.clev_tbl_type,
    x_clev_tbl                     OUT NOCOPY clev_tbl_type,
    x_klev_tbl                     OUT NOCOPY klev_tbl_type);

  PROCEDURE update_credit_limit(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
--    p_clev_tbl                     IN  okl_okc_migration_pvt.clev_tbl_type,
    p_clev_tbl                     IN  clev_tbl_type,
    p_klev_tbl                     IN  klev_tbl_type,
--    x_clev_tbl                     OUT NOCOPY okl_okc_migration_pvt.clev_tbl_type,
    x_clev_tbl                     OUT NOCOPY clev_tbl_type,
    x_klev_tbl                     OUT NOCOPY klev_tbl_type);

  PROCEDURE delete_credit_limit(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
--    p_clev_tbl                     IN  okl_okc_migration_pvt.clev_tbl_type,
    p_clev_tbl                     IN  clev_tbl_type,
    p_klev_tbl                     IN  klev_tbl_type);

------------------------------------------------------------------
 FUNCTION get_total_credit_limit(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER  DEFAULT OKL_API.G_MISS_NUM
 ) RETURN NUMBER;
 --PRAGMA RESTRICT_REFERENCES (get_total_credit_limit, TRUST);

 FUNCTION get_credit_remaining(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER  DEFAULT OKL_API.G_MISS_NUM
 ) RETURN NUMBER;
 --PRAGMA RESTRICT_REFERENCES (get_credit_remaining, TRUST);

 FUNCTION get_total_credit_new_limit(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER  DEFAULT OKL_API.G_MISS_NUM
 ) RETURN NUMBER;
 --PRAGMA RESTRICT_REFERENCES (get_total_credit_new_limit, TRUST);

 FUNCTION get_total_credit_addition(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER  DEFAULT OKL_API.G_MISS_NUM
 ) RETURN NUMBER;
 --PRAGMA RESTRICT_REFERENCES (get_total_credit_addition, TRUST);

 FUNCTION get_total_credit_reduction(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER  DEFAULT OKL_API.G_MISS_NUM
 ) RETURN NUMBER;
 --PRAGMA RESTRICT_REFERENCES (get_total_credit_reduction, TRUST);

 FUNCTION fnd_profile_value(
 p_opt_name                   IN VARCHAR2
 ) RETURN VARCHAR2;
 --PRAGMA RESTRICT_REFERENCES (fnd_profile_value, TRUST);

 FUNCTION get_func_curr_code
 RETURN VARCHAR2;
 --PRAGMA RESTRICT_REFERENCES (get_func_curr_code, TRUST);

------------------------------------------
 FUNCTION get_checklist_attr(
 p_chr_id                   IN NUMBER
 ,p_attr                    IN VARCHAR2
 ) RETURN VARCHAR2;
 --PRAGMA RESTRICT_REFERENCES (get_checklist_attr, TRUST);

 FUNCTION get_checklist_number(
 p_chr_id                   IN NUMBER
 ,p_attr                    IN VARCHAR2
 ) RETURN VARCHAR2;
 --PRAGMA RESTRICT_REFERENCES (get_checklist_number, TRUST);

-- start cklee bug# 2901495
 FUNCTION get_creditline_by_chrid(
  p_contract_id                       IN NUMBER                 -- contract hdr
 ) RETURN NUMBER;
 --PRAGMA RESTRICT_REFERENCES (get_creditline_by_chrid, TRUST);
-- end cklee bug# 2901495

-- start: 06-May-2005  cklee okl.h Lease App IA Authoring
  PROCEDURE update_credit_line_status(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    x_status_code                  OUT NOCOPY VARCHAR2,
    p_status_code                  IN  VARCHAR2,
    p_credit_line_id               IN  NUMBER);

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
   ,p_contract_id                  IN  NUMBER
 );
-- end: 06-May-2005  cklee okl.h Lease App IA Authoring
-- start: cklee 07/12/2005

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : activate_credit
-- Description     : activates a credit line
--
-- Business Rules  :  This procedure will validate credit line and then activate
--                    the credit line.
--                    It will return to the caller without raise error if credit
--                    has been activated already.
--
-- Parameters      :  p_chr_id   : Credit Line PK
--                    x_sts_code : Credit Line status code
--
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
/*#
 * Activates a credit line.
 * @param p_api_version API version
 * @param p_init_msg_list  Initialize message stack
 * @param x_return_status Return status from the API
 * @param x_msg_count Message count if error messages are encountered
 * @param x_msg_data Error message data
 * @param p_chr_id Credit line PK
 * @param x_sts_code Credit line status code
 * @rep:displayname Activates a credit line
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY OKL_UNDERWRITING
 */
  PROCEDURE activate_credit(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    x_sts_code                     OUT NOCOPY VARCHAR2);
-- end: cklee 07/12/2005

END OKL_CREDIT_PUB;

/
