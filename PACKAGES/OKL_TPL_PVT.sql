--------------------------------------------------------
--  DDL for Package OKL_TPL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TPL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSTPLS.pls 120.3 2007/05/14 17:43:56 cklee ship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE tpl_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    inv_distr_line_code            OKL_TXL_AP_INV_LNS_B.INV_DISTR_LINE_CODE%TYPE := OKC_API.G_MISS_CHAR,
    tap_id                         NUMBER := OKC_API.G_MISS_NUM,
    disbursement_basis_code        OKL_TXL_AP_INV_LNS_B.DISBURSEMENT_BASIS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    tpl_id_reverses                NUMBER := OKC_API.G_MISS_NUM,
    combo_id                       NUMBER := OKC_API.G_MISS_NUM,
    lsm_id                         NUMBER := OKC_API.G_MISS_NUM,
    kle_id                         NUMBER := OKC_API.G_MISS_NUM,
    khr_id                         NUMBER := OKC_API.G_MISS_NUM,
    cnsld_ap_inv_id                NUMBER := OKC_API.G_MISS_NUM,
    itc_id                         NUMBER := OKC_API.G_MISS_NUM,
    sty_id                         NUMBER := OKC_API.G_MISS_NUM,
--    trx_type                       OKL_TXL_AP_INV_LNS_B.TRX_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    line_number                    NUMBER := OKC_API.G_MISS_NUM,
    cnsld_line_number              NUMBER := OKC_API.G_MISS_NUM,
    ref_line_number                NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    date_accounting                OKL_TXL_AP_INV_LNS_B.DATE_ACCOUNTING%TYPE := OKC_API.G_MISS_DATE,
    amount                         NUMBER := OKC_API.G_MISS_NUM,
    payables_invoice_id            NUMBER := OKC_API.G_MISS_NUM,
    request_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_application_id         NUMBER := OKC_API.G_MISS_NUM,
    program_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_update_date            OKL_TXL_AP_INV_LNS_B.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    error_message                  OKL_TXL_AP_INV_LNS_B.error_message%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category             OKL_TXL_AP_INV_LNS_B.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKL_TXL_AP_INV_LNS_B.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKL_TXL_AP_INV_LNS_B.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKL_TXL_AP_INV_LNS_B.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKL_TXL_AP_INV_LNS_B.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKL_TXL_AP_INV_LNS_B.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKL_TXL_AP_INV_LNS_B.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKL_TXL_AP_INV_LNS_B.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKL_TXL_AP_INV_LNS_B.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKL_TXL_AP_INV_LNS_B.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKL_TXL_AP_INV_LNS_B.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKL_TXL_AP_INV_LNS_B.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKL_TXL_AP_INV_LNS_B.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKL_TXL_AP_INV_LNS_B.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKL_TXL_AP_INV_LNS_B.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKL_TXL_AP_INV_LNS_B.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_TXL_AP_INV_LNS_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_TXL_AP_INV_LNS_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    funding_reference_type_code    OKL_TXL_AP_INV_LNS_B.funding_reference_type_code%TYPE := OKC_API.G_MISS_CHAR, -- added g_miss 5/14/07 cklee
    funding_reference_number       OKL_TXL_AP_INV_LNS_B.FUNDING_REFERENCE_NUMBER%TYPE := OKC_API.G_MISS_CHAR,
    code_combination_id            OKL_TXL_AP_INV_LNS_B.code_combination_id%TYPE := OKC_API.G_MISS_NUM, -- added g_miss 5/14/07 cklee
    sel_id                         OKL_TXL_AP_INV_LNS_B.sel_id%TYPE := OKC_API.G_MISS_NUM, -- added g_miss 5/14/07 cklee
    taxable_yn                     OKL_TXL_AP_INV_LNS_B.TAXABLE_YN%TYPE := OKC_API.G_MISS_CHAR,
--start:|           14-May-07 cklee -- added TLD_ID column                           |
    TLD_ID                         OKL_TXL_AP_INV_LNS_B.TLD_ID%TYPE := OKC_API.G_MISS_NUM
--end:|           14-May-07 cklee -- added TLD_ID column                           |
    );
  g_miss_tpl_rec                          tpl_rec_type;
  TYPE tpl_tbl_type IS TABLE OF tpl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE okl_txl_ap_inv_lns_tl_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    language                       OKL_TXL_AP_INV_LNS_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR,
    source_lang                    OKL_TXL_AP_INV_LNS_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR,
    sfwt_flag                      OKL_TXL_AP_INV_LNS_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKL_TXL_AP_INV_LNS_TL.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_TXL_AP_INV_LNS_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_TXL_AP_INV_LNS_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  GMissOklTxlApInvLnsTlRec                okl_txl_ap_inv_lns_tl_rec_type;
  TYPE okl_txl_ap_inv_lns_tl_tbl_type IS TABLE OF okl_txl_ap_inv_lns_tl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE tplv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    sfwt_flag                      OKL_TXL_AP_INV_LNS_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    combo_id                       NUMBER := OKC_API.G_MISS_NUM,
    itc_id                         NUMBER := OKC_API.G_MISS_NUM,
    disbursement_basis_code        OKL_TXL_AP_INV_LNS_V.DISBURSEMENT_BASIS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    kle_id                         NUMBER := OKC_API.G_MISS_NUM,
    khr_id                         NUMBER := OKC_API.G_MISS_NUM,
    cnsld_ap_inv_id                NUMBER := OKC_API.G_MISS_NUM,
    lsm_id                         NUMBER := OKC_API.G_MISS_NUM,
    tpl_id_reverses                NUMBER := OKC_API.G_MISS_NUM,
    inv_distr_line_code            OKL_TXL_AP_INV_LNS_V.INV_DISTR_LINE_CODE%TYPE := OKC_API.G_MISS_CHAR,
    sty_id                         NUMBER := OKC_API.G_MISS_NUM,
    tap_id                         NUMBER := OKC_API.G_MISS_NUM,
    date_accounting                OKL_TXL_AP_INV_LNS_V.DATE_ACCOUNTING%TYPE := OKC_API.G_MISS_DATE,
    amount                         NUMBER := OKC_API.G_MISS_NUM,
    line_number                    NUMBER := OKC_API.G_MISS_NUM,
    cnsld_line_number              NUMBER := OKC_API.G_MISS_NUM,
    ref_line_number                NUMBER := OKC_API.G_MISS_NUM,
    payables_invoice_id            NUMBER := OKC_API.G_MISS_NUM,
    description                    OKL_TXL_AP_INV_LNS_V.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    error_message                  OKL_TXL_AP_INV_LNS_V.error_message%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category             OKL_TXL_AP_INV_LNS_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKL_TXL_AP_INV_LNS_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKL_TXL_AP_INV_LNS_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKL_TXL_AP_INV_LNS_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKL_TXL_AP_INV_LNS_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKL_TXL_AP_INV_LNS_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKL_TXL_AP_INV_LNS_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKL_TXL_AP_INV_LNS_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKL_TXL_AP_INV_LNS_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKL_TXL_AP_INV_LNS_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKL_TXL_AP_INV_LNS_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKL_TXL_AP_INV_LNS_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKL_TXL_AP_INV_LNS_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKL_TXL_AP_INV_LNS_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKL_TXL_AP_INV_LNS_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKL_TXL_AP_INV_LNS_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
--    trx_type                       OKL_TXL_AP_INV_LNS_V.TRX_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    request_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_application_id         NUMBER := OKC_API.G_MISS_NUM,
    program_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_update_date            OKL_TXL_AP_INV_LNS_V.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_TXL_AP_INV_LNS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_TXL_AP_INV_LNS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    funding_reference_number       OKL_TXL_AP_INV_LNS_v.FUNDING_REFERENCE_NUMBER%TYPE := OKC_API.G_MISS_CHAR,
    funding_reference_type_code    OKL_TXL_AP_INV_LNS_B.funding_reference_type_code%TYPE := OKC_API.G_MISS_CHAR, -- added g_miss 5/14/07 cklee
    code_combination_id            OKL_TXL_AP_INV_LNS_v.code_combination_id%TYPE := OKC_API.G_MISS_NUM, -- added g_miss 5/14/07 cklee
    sel_id                         OKL_TXL_AP_INV_LNS_v.sel_id%TYPE := OKC_API.G_MISS_NUM, -- added g_miss 5/14/07 cklee
    taxable_yn                     OKL_TXL_AP_INV_LNS_V.TAXABLE_YN%TYPE  := OKC_API.G_MISS_CHAR,
--start:|           14-May-07 cklee -- added TLD_ID column                           |
    TLD_ID                         OKL_TXL_AP_INV_LNS_B.TLD_ID%TYPE := OKC_API.G_MISS_NUM
--end:|           14-May-07 cklee -- added TLD_ID column                           |
);
  g_miss_tplv_rec                         tplv_rec_type;
  TYPE tplv_tbl_type IS TABLE OF tplv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_EXCEPTION_HALT_VALIDATION 					EXCEPTION;
  G_UNEXPECTED_ERROR           CONSTANT VARCHAR2(30) := 'OKL_UNEXPECTED_ERROR';
  G_NO_PARENT_RECORD           CONSTANT VARCHAR2(30) :='OKL_NO_PARENT_RECORD';
  G_SQLERRM_TOKEN              CONSTANT VARCHAR2(30) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN              CONSTANT VARCHAR2(30) := 'OKL_SQLCODE';
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_TPL_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE add_language;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tplv_rec                     IN tplv_rec_type,
    x_tplv_rec                     OUT NOCOPY tplv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tplv_tbl                     IN tplv_tbl_type,
    x_tplv_tbl                     OUT NOCOPY tplv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tplv_rec                     IN tplv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tplv_tbl                     IN tplv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tplv_rec                     IN tplv_rec_type,
    x_tplv_rec                     OUT NOCOPY tplv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tplv_tbl                     IN tplv_tbl_type,
    x_tplv_tbl                     OUT NOCOPY tplv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tplv_rec                     IN tplv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tplv_tbl                     IN tplv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tplv_rec                     IN tplv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tplv_tbl                     IN tplv_tbl_type);

END OKL_TPL_PVT;

/
