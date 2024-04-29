--------------------------------------------------------
--  DDL for Package OKL_SAO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SAO_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSSAOS.pls 120.6.12010000.3 2009/06/02 10:54:03 racheruv ship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE sao_rec_type IS RECORD (
    id                             NUMBER := Okc_Api.G_MISS_NUM,
    cc_rep_currency_code                    OKL_SYS_ACCT_OPTS.CC_REP_CURRENCY_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    code_combination_id            NUMBER := Okc_Api.G_MISS_NUM,
    ael_rep_currency_code                   OKL_SYS_ACCT_OPTS.AEL_REP_CURRENCY_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    set_of_books_id                NUMBER := Okc_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okc_Api.G_MISS_NUM,
    rec_ccid                       NUMBER := Okc_Api.G_MISS_NUM,
    realized_gain_ccid             NUMBER := Okc_Api.G_MISS_NUM,
    realized_loss_ccid             NUMBER := Okc_Api.G_MISS_NUM,
    tax_ccid                       NUMBER := Okc_Api.G_MISS_NUM,
    cross_currency_ccid                NUMBER := Okc_Api.G_MISS_NUM,
    rounding_ccid                  NUMBER := Okc_Api.G_MISS_NUM,
    ar_clearing_ccid               NUMBER := Okc_Api.G_MISS_NUM,
    payables_ccid                  NUMBER := Okc_Api.G_MISS_NUM,
    liablity_ccid                  NUMBER := Okc_Api.G_MISS_NUM,
    pre_payment_ccid               NUMBER := Okc_Api.G_MISS_NUM,
    fut_date_pay_ccid              NUMBER := Okc_Api.G_MISS_NUM,
    cc_rounding_rule               OKL_SYS_ACCT_OPTS.CC_ROUNDING_RULE%TYPE := Okc_Api.G_MISS_CHAR,
    cc_precision                   NUMBER := Okc_Api.G_MISS_NUM,
    cc_min_acct_unit               NUMBER := Okc_Api.G_MISS_NUM,
    dis_taken_ccid                 NUMBER := Okc_Api.G_MISS_NUM,
    ap_clearing_ccid               NUMBER := Okc_Api.G_MISS_NUM,
    ael_rounding_rule              OKL_SYS_ACCT_OPTS.AEL_ROUNDING_RULE%TYPE := Okc_Api.G_MISS_CHAR,
    ael_precision                  NUMBER := Okc_Api.G_MISS_NUM,
    ael_min_acct_unit              NUMBER := Okc_Api.G_MISS_NUM,
    org_id                         NUMBER := Okc_Api.G_MISS_NUM,
    attribute_category             OKL_SYS_ACCT_OPTS.ATTRIBUTE_CATEGORY%TYPE := Okc_Api.G_MISS_CHAR,
    attribute1                     OKL_SYS_ACCT_OPTS.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    attribute2                     OKL_SYS_ACCT_OPTS.ATTRIBUTE2%TYPE := Okc_Api.G_MISS_CHAR,
    attribute3                     OKL_SYS_ACCT_OPTS.ATTRIBUTE3%TYPE := Okc_Api.G_MISS_CHAR,
    attribute4                     OKL_SYS_ACCT_OPTS.ATTRIBUTE4%TYPE := Okc_Api.G_MISS_CHAR,
    attribute5                     OKL_SYS_ACCT_OPTS.ATTRIBUTE5%TYPE := Okc_Api.G_MISS_CHAR,
    attribute6                     OKL_SYS_ACCT_OPTS.ATTRIBUTE6%TYPE := Okc_Api.G_MISS_CHAR,
    attribute7                     OKL_SYS_ACCT_OPTS.ATTRIBUTE7%TYPE := Okc_Api.G_MISS_CHAR,
    attribute8                     OKL_SYS_ACCT_OPTS.ATTRIBUTE8%TYPE := Okc_Api.G_MISS_CHAR,
    attribute9                     OKL_SYS_ACCT_OPTS.ATTRIBUTE9%TYPE := Okc_Api.G_MISS_CHAR,
    attribute10                    OKL_SYS_ACCT_OPTS.ATTRIBUTE10%TYPE := Okc_Api.G_MISS_CHAR,
    attribute11                    OKL_SYS_ACCT_OPTS.ATTRIBUTE11%TYPE := Okc_Api.G_MISS_CHAR,
    attribute12                    OKL_SYS_ACCT_OPTS.ATTRIBUTE12%TYPE := Okc_Api.G_MISS_CHAR,
    attribute13                    OKL_SYS_ACCT_OPTS.ATTRIBUTE13%TYPE := Okc_Api.G_MISS_CHAR,
    attribute14                    OKL_SYS_ACCT_OPTS.ATTRIBUTE14%TYPE := Okc_Api.G_MISS_CHAR,
    attribute15                    OKL_SYS_ACCT_OPTS.ATTRIBUTE15%TYPE := Okc_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okc_Api.G_MISS_NUM,
    creation_date                  OKL_SYS_ACCT_OPTS.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okc_Api.G_MISS_NUM,
    last_update_date               OKL_SYS_ACCT_OPTS.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okc_Api.G_MISS_NUM,
    /* Changed Made by Kanti on 06/21/2001. The following two fields are available in the
       table but missing from here.
       Changes start here  */
    cc_apply_rounding_difference   OKL_SYS_ACCT_OPTS.CC_APPLY_ROUNDING_DIFFERENCE%TYPE := Okc_Api.G_MISS_CHAR,
    ael_apply_rounding_difference  OKL_SYS_ACCT_OPTS.AEL_APPLY_ROUNDING_DIFFERENCE%TYPE := Okc_Api.G_MISS_CHAR,
    /* Changes End Here    */
    accrual_reversal_days          NUMBER := OKC_API.G_MISS_NUM ,
    -- Added a new field for the bug 2331564 Santonyr
    lke_hold_days                  NUMBER := OKC_API.G_MISS_NUM ,
       /*Changes added by Keerthi 10-Sep-2003 for Rounding the Amounts in Streams */
    stm_apply_rounding_difference  OKL_SYS_ACCT_OPTS.STM_APPLY_ROUNDING_DIFFERENCE%TYPE := Okc_Api.G_MISS_CHAR,
    stm_rounding_rule              OKL_SYS_ACCT_OPTS.STM_ROUNDING_RULE%TYPE := Okc_Api.G_MISS_CHAR
    /*Added new field for bug 4884618(H) */
    ,validate_khr_start_date       OKL_SYS_ACCT_OPTS.validate_khr_start_date%TYPE := Okc_Api.G_MISS_CHAR
    -- R12 SLA Uptake
    ,account_derivation            OKL_SYS_ACCT_OPTS.ACCOUNT_DERIVATION%TYPE := Okc_Api.G_MISS_CHAR
    ,isg_arrears_pay_dates_option    OKL_SYS_ACCT_OPTS.ISG_ARREARS_PAY_DATES_OPTION%TYPE := Okc_Api.G_MISS_CHAR
    ,PAY_DIST_SET_ID                   OKL_SYS_ACCT_OPTS.PAY_DIST_SET_ID%TYPE :=OKC_API.G_MISS_NUM,
    /*Added new field for bug Multi-GAAP bug 7225249 */
    SECONDARY_REP_METHOD                OKL_SYS_ACCT_OPTS.SECONDARY_REP_METHOD%type := Okc_Api.G_MISS_CHAR
    /* Bug# 8370699 */
    ,amort_inc_adj_rev_dt_yn    OKL_SYS_ACCT_OPTS.amort_inc_adj_rev_dt_yn%TYPE := Okc_Api.G_MISS_CHAR
    );
  g_miss_sao_rec                          sao_rec_type;
  TYPE sao_tbl_type IS TABLE OF sao_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE saov_rec_type IS RECORD (
    id                             NUMBER := Okc_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okc_Api.G_MISS_NUM,
    set_of_books_id                NUMBER := Okc_Api.G_MISS_NUM,
    code_combination_id            NUMBER := Okc_Api.G_MISS_NUM,
    cc_rep_currency_code                    OKL_SYS_ACCT_OPTS.CC_REP_CURRENCY_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    ael_rep_currency_code                   OKL_SYS_ACCT_OPTS.AEL_REP_CURRENCY_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    rec_ccid                       NUMBER := Okc_Api.G_MISS_NUM,
    realized_gain_ccid             NUMBER := Okc_Api.G_MISS_NUM,
    realized_loss_ccid             NUMBER := Okc_Api.G_MISS_NUM,
    tax_ccid                       NUMBER := Okc_Api.G_MISS_NUM,
    cross_currency_ccid                NUMBER := Okc_Api.G_MISS_NUM,
    rounding_ccid                  NUMBER := Okc_Api.G_MISS_NUM,
    ar_clearing_ccid               NUMBER := Okc_Api.G_MISS_NUM,
    payables_ccid                  NUMBER := Okc_Api.G_MISS_NUM,
    liablity_ccid                  NUMBER := Okc_Api.G_MISS_NUM,
    pre_payment_ccid               NUMBER := Okc_Api.G_MISS_NUM,
    fut_date_pay_ccid              NUMBER := Okc_Api.G_MISS_NUM,
    dis_taken_ccid                 NUMBER := Okc_Api.G_MISS_NUM,
    ap_clearing_ccid               NUMBER := Okc_Api.G_MISS_NUM,
    ael_rounding_rule              OKL_SYS_ACCT_OPTS.AEL_ROUNDING_RULE%TYPE := Okc_Api.G_MISS_CHAR,
    ael_precision                  NUMBER := Okc_Api.G_MISS_NUM,
    ael_min_acct_unit              NUMBER := Okc_Api.G_MISS_NUM,
    cc_rounding_rule               OKL_SYS_ACCT_OPTS.CC_ROUNDING_RULE%TYPE := Okc_Api.G_MISS_CHAR,
    cc_precision                   NUMBER := Okc_Api.G_MISS_NUM,
    cc_min_acct_unit               NUMBER := Okc_Api.G_MISS_NUM,
    attribute_category             OKL_SYS_ACCT_OPTS.ATTRIBUTE_CATEGORY%TYPE := Okc_Api.G_MISS_CHAR,
    attribute1                     OKL_SYS_ACCT_OPTS.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    attribute2                     OKL_SYS_ACCT_OPTS.ATTRIBUTE2%TYPE := Okc_Api.G_MISS_CHAR,
    attribute3                     OKL_SYS_ACCT_OPTS.ATTRIBUTE3%TYPE := Okc_Api.G_MISS_CHAR,
    attribute4                     OKL_SYS_ACCT_OPTS.ATTRIBUTE4%TYPE := Okc_Api.G_MISS_CHAR,
    attribute5                     OKL_SYS_ACCT_OPTS.ATTRIBUTE5%TYPE := Okc_Api.G_MISS_CHAR,
    attribute6                     OKL_SYS_ACCT_OPTS.ATTRIBUTE6%TYPE := Okc_Api.G_MISS_CHAR,
    attribute7                     OKL_SYS_ACCT_OPTS.ATTRIBUTE7%TYPE := Okc_Api.G_MISS_CHAR,
    attribute8                     OKL_SYS_ACCT_OPTS.ATTRIBUTE8%TYPE := Okc_Api.G_MISS_CHAR,
    attribute9                     OKL_SYS_ACCT_OPTS.ATTRIBUTE9%TYPE := Okc_Api.G_MISS_CHAR,
    attribute10                    OKL_SYS_ACCT_OPTS.ATTRIBUTE10%TYPE := Okc_Api.G_MISS_CHAR,
    attribute11                    OKL_SYS_ACCT_OPTS.ATTRIBUTE11%TYPE := Okc_Api.G_MISS_CHAR,
    attribute12                    OKL_SYS_ACCT_OPTS.ATTRIBUTE12%TYPE := Okc_Api.G_MISS_CHAR,
    attribute13                    OKL_SYS_ACCT_OPTS.ATTRIBUTE13%TYPE := Okc_Api.G_MISS_CHAR,
    attribute14                    OKL_SYS_ACCT_OPTS.ATTRIBUTE14%TYPE := Okc_Api.G_MISS_CHAR,
    attribute15                    OKL_SYS_ACCT_OPTS.ATTRIBUTE15%TYPE := Okc_Api.G_MISS_CHAR,
    org_id                         NUMBER := Okc_Api.G_MISS_NUM,
    created_by                     NUMBER := Okc_Api.G_MISS_NUM,
    creation_date                  OKL_SYS_ACCT_OPTS.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okc_Api.G_MISS_NUM,
    last_update_date               OKL_SYS_ACCT_OPTS.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okc_Api.G_MISS_NUM,
    /* Changed Made by Kanti on 06/21/2001. The following two fields are available in the
           table but missing from here.
           Changes start here  */
    cc_apply_rounding_difference   OKL_SYS_ACCT_OPTS.CC_APPLY_ROUNDING_DIFFERENCE%TYPE := Okc_Api.G_MISS_CHAR,
    ael_apply_rounding_difference  OKL_SYS_ACCT_OPTS.AEL_APPLY_ROUNDING_DIFFERENCE%TYPE := Okc_Api.G_MISS_CHAR,
        /* Changes End Here    */
    accrual_reversal_days          NUMBER := OKC_API.G_MISS_NUM ,
    -- Added a new field for the bug 2331564 Santonyr
    lke_hold_days		   NUMBER := OKC_API.G_MISS_NUM ,
    /*Changes added by Keerthi 10-Sep-2003 for Rounding the Amounts in Streams*/
    stm_apply_rounding_difference  OKL_SYS_ACCT_OPTS.STM_APPLY_ROUNDING_DIFFERENCE%TYPE := Okc_Api.G_MISS_CHAR,
    stm_rounding_rule              OKL_SYS_ACCT_OPTS.STM_ROUNDING_RULE%TYPE := Okc_Api.G_MISS_CHAR
     /*Added new field for bug 4884618(H) */
    ,validate_khr_start_date       OKL_SYS_ACCT_OPTS.validate_khr_start_date%TYPE := Okc_Api.G_MISS_CHAR
    ,account_derivation            OKL_SYS_ACCT_OPTS.ACCOUNT_DERIVATION%TYPE := Okc_Api.G_MISS_CHAR
    ,isg_arrears_pay_dates_option    OKL_SYS_ACCT_OPTS.ISG_ARREARS_PAY_DATES_OPTION%TYPE := Okc_Api.G_MISS_CHAR
    ,PAY_DIST_SET_ID                   OKL_SYS_ACCT_OPTS.PAY_DIST_SET_ID%TYPE :=OKC_API.G_MISS_NUM,
    /*Added new field for bug Multi-GAAP bug 7225249 */
    SECONDARY_REP_METHOD                OKL_SYS_ACCT_OPTS.SECONDARY_REP_METHOD%type := Okc_Api.G_MISS_CHAR
    /* Bug# 8370699 */
    ,amort_inc_adj_rev_dt_yn    OKL_SYS_ACCT_OPTS.amort_inc_adj_rev_dt_yn%TYPE := Okc_Api.G_MISS_CHAR
    );
    g_miss_saov_rec                         saov_rec_type;
  TYPE saov_tbl_type IS TABLE OF saov_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := Okc_Api.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := Okc_Api.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := Okc_Api.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := Okc_Api.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := Okc_Api.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := Okc_Api.G_REQUIRED_VALUE;
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := Okc_Api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := Okc_Api.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okc_Api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okc_Api.G_CHILD_TABLE_TOKEN;
  -- START CHANGE : mvasudev -- 05/02/2001
  -- Adding MESSAGE CONSTANTs for 'Unique Key Validation','SQLCode', 'SQLErrM'
  G_SQLERRM_TOKEN             	CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN             	CONSTANT VARCHAR2(200) := 'OKL_SQLcode';
  G_UNEXPECTED_ERROR          	CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  -- END CHANGE : mvasudev
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_SAO_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okc_Api.G_APP_NAME;

  -- START change : mvasudev, 05/02/2001
  -- Added Exception for Halt_validation
  --------------------------------------------------------------------------------
  -- ERRORS AND EXCEPTIONS
  --------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
  -- END change : mvasudev

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saov_rec                     IN saov_rec_type,
    x_saov_rec                     OUT NOCOPY saov_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saov_tbl                     IN saov_tbl_type,
    x_saov_tbl                     OUT NOCOPY saov_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saov_rec                     IN saov_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saov_tbl                     IN saov_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saov_rec                     IN saov_rec_type,
    x_saov_rec                     OUT NOCOPY saov_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saov_tbl                     IN saov_tbl_type,
    x_saov_tbl                     OUT NOCOPY saov_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saov_rec                     IN saov_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saov_tbl                     IN saov_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saov_rec                     IN saov_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saov_tbl                     IN saov_tbl_type);

END OKL_SAO_PVT;

/
