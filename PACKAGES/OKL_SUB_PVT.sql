--------------------------------------------------------
--  DDL for Package OKL_SUB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SUB_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSSUBS.pls 120.4 2005/10/30 04:44:49 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_SUBSIDIES_V Record Spec
  TYPE subv_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,sfwt_flag                      OKL_SUBSIDIES_V.SFWT_FLAG%TYPE := OKL_API.G_MISS_CHAR
    ,org_id                         NUMBER := OKL_API.G_MISS_NUM
    ,name                           OKL_SUBSIDIES_V.NAME%TYPE := OKL_API.G_MISS_CHAR
    ,short_description              OKL_SUBSIDIES_V.SHORT_DESCRIPTION%TYPE := OKL_API.G_MISS_CHAR
    ,description                    OKL_SUBSIDIES_V.DESCRIPTION%TYPE := OKL_API.G_MISS_CHAR
    ,effective_from_date            OKL_SUBSIDIES_V.EFFECTIVE_FROM_DATE%TYPE := OKL_API.G_MISS_DATE
    ,effective_to_date              OKL_SUBSIDIES_V.EFFECTIVE_TO_DATE%TYPE := OKL_API.G_MISS_DATE
    ,expire_after_days              NUMBER := OKL_API.G_MISS_NUM
    ,currency_code                  OKL_SUBSIDIES_V.CURRENCY_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,exclusive_yn                   OKL_SUBSIDIES_V.EXCLUSIVE_YN%TYPE := OKL_API.G_MISS_CHAR
    ,applicable_to_release_yn       OKL_SUBSIDIES_V.APPLICABLE_TO_RELEASE_YN%TYPE := OKL_API.G_MISS_CHAR
    ,subsidy_calc_basis             OKL_SUBSIDIES_V.SUBSIDY_CALC_BASIS%TYPE := OKL_API.G_MISS_CHAR
    ,amount                         NUMBER := OKL_API.G_MISS_NUM
    ,percent                        NUMBER := OKL_API.G_MISS_NUM
    ,formula_id                     NUMBER := OKL_API.G_MISS_NUM
    ,rate_points                    NUMBER := OKL_API.G_MISS_NUM
    ,maximum_term                   NUMBER := OKL_API.G_MISS_NUM
    ,vendor_id                      NUMBER := OKL_API.G_MISS_NUM
    ,accounting_method_code         OKL_SUBSIDIES_V.ACCOUNTING_METHOD_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,recourse_yn                    OKL_SUBSIDIES_V.RECOURSE_YN%TYPE := OKL_API.G_MISS_CHAR
    ,termination_refund_basis       OKL_SUBSIDIES_V.TERMINATION_REFUND_BASIS%TYPE := OKL_API.G_MISS_CHAR
    ,refund_formula_id              NUMBER := OKL_API.G_MISS_NUM
    ,stream_type_id                 NUMBER := OKL_API.G_MISS_NUM
    ,receipt_method_code            OKL_SUBSIDIES_V.RECEIPT_METHOD_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,customer_visible_yn            OKL_SUBSIDIES_V.CUSTOMER_VISIBLE_YN%TYPE := OKL_API.G_MISS_CHAR
    ,maximum_financed_amount        NUMBER := OKL_API.G_MISS_NUM
    ,maximum_subsidy_amount         NUMBER := OKL_API.G_MISS_NUM
	   --Start code changes for Subsidy by fmiao on 10/25/2004--
    ,transfer_basis_code            OKL_SUBSIDIES_V.TRANSFER_BASIS_CODE%TYPE := OKL_API.G_MISS_CHAR
    --End code changes for Subsidy by fmiao on 10/25/2004--
	   ,attribute_category             OKL_SUBSIDIES_V.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_SUBSIDIES_V.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_SUBSIDIES_V.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_SUBSIDIES_V.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_SUBSIDIES_V.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_SUBSIDIES_V.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_SUBSIDIES_V.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_SUBSIDIES_V.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_SUBSIDIES_V.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_SUBSIDIES_V.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_SUBSIDIES_V.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_SUBSIDIES_V.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_SUBSIDIES_V.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_SUBSIDIES_V.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_SUBSIDIES_V.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_SUBSIDIES_V.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_SUBSIDIES_V.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_SUBSIDIES_V.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM
    -- sjalasut added new column for subsidy pools enhancement. start
    ,subsidy_pool_id                NUMBER := OKL_API.G_MISS_NUM
    -- sjalasut added new column for subsidy pools enhancement. end
    );
  G_MISS_subv_rec                         subv_rec_type;
  TYPE subv_tbl_type IS TABLE OF subv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_SUBSIDIES_TL Record Spec
  TYPE subt_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,short_description              OKL_SUBSIDIES_TL.SHORT_DESCRIPTION%TYPE := OKL_API.G_MISS_CHAR
    ,description                    OKL_SUBSIDIES_TL.DESCRIPTION%TYPE := OKL_API.G_MISS_CHAR
    ,language                       OKL_SUBSIDIES_TL.LANGUAGE%TYPE := OKL_API.G_MISS_CHAR
    ,source_lang                    OKL_SUBSIDIES_TL.SOURCE_LANG%TYPE := OKL_API.G_MISS_CHAR
    ,sfwt_flag                      OKL_SUBSIDIES_TL.SFWT_FLAG%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_SUBSIDIES_TL.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_SUBSIDIES_TL.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM);
  G_MISS_subt_rec                         subt_rec_type;
  TYPE subt_tbl_type IS TABLE OF subt_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_SUBSIDIES_B Record Spec
  TYPE subb_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,org_id                         NUMBER := OKL_API.G_MISS_NUM
    ,name                           OKL_SUBSIDIES_B.NAME%TYPE := OKL_API.G_MISS_CHAR
    ,effective_from_date            OKL_SUBSIDIES_B.EFFECTIVE_FROM_DATE%TYPE := OKL_API.G_MISS_DATE
    ,effective_to_date              OKL_SUBSIDIES_B.EFFECTIVE_TO_DATE%TYPE := OKL_API.G_MISS_DATE
    ,expire_after_days              NUMBER := OKL_API.G_MISS_NUM
    ,currency_code                  OKL_SUBSIDIES_B.CURRENCY_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,exclusive_yn                   OKL_SUBSIDIES_B.EXCLUSIVE_YN%TYPE := OKL_API.G_MISS_CHAR
    ,applicable_to_release_yn       OKL_SUBSIDIES_B.APPLICABLE_TO_RELEASE_YN%TYPE := OKL_API.G_MISS_CHAR
    ,subsidy_calc_basis             OKL_SUBSIDIES_B.SUBSIDY_CALC_BASIS%TYPE := OKL_API.G_MISS_CHAR
    ,amount                         NUMBER := OKL_API.G_MISS_NUM
    ,percent                        NUMBER := OKL_API.G_MISS_NUM
    ,formula_id                     NUMBER := OKL_API.G_MISS_NUM
    ,rate_points                    NUMBER := OKL_API.G_MISS_NUM
    ,maximum_term                   NUMBER := OKL_API.G_MISS_NUM
    ,vendor_id                      NUMBER := OKL_API.G_MISS_NUM
    ,accounting_method_code         OKL_SUBSIDIES_B.ACCOUNTING_METHOD_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,recourse_yn                    OKL_SUBSIDIES_B.RECOURSE_YN%TYPE := OKL_API.G_MISS_CHAR
    ,termination_refund_basis       OKL_SUBSIDIES_B.TERMINATION_REFUND_BASIS%TYPE := OKL_API.G_MISS_CHAR
    ,refund_formula_id              NUMBER := OKL_API.G_MISS_NUM
    ,stream_type_id                 NUMBER := OKL_API.G_MISS_NUM
    ,receipt_method_code            OKL_SUBSIDIES_B.RECEIPT_METHOD_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,customer_visible_yn            OKL_SUBSIDIES_B.CUSTOMER_VISIBLE_YN%TYPE := OKL_API.G_MISS_CHAR
    ,maximum_financed_amount        NUMBER := OKL_API.G_MISS_NUM
    ,maximum_subsidy_amount         NUMBER := OKL_API.G_MISS_NUM
	   --Start code changes for Subsidy by fmiao on 10/25/2004--
    ,transfer_basis_code            OKL_SUBSIDIES_B.TRANSFER_BASIS_CODE%TYPE := OKL_API.G_MISS_CHAR
    --End code changes for Subsidy by fmiao on 10/25/2004--
	   ,attribute_category             OKL_SUBSIDIES_B.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_SUBSIDIES_B.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_SUBSIDIES_B.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_SUBSIDIES_B.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_SUBSIDIES_B.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_SUBSIDIES_B.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_SUBSIDIES_B.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_SUBSIDIES_B.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_SUBSIDIES_B.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_SUBSIDIES_B.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_SUBSIDIES_B.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_SUBSIDIES_B.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_SUBSIDIES_B.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_SUBSIDIES_B.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_SUBSIDIES_B.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_SUBSIDIES_B.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_SUBSIDIES_B.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_SUBSIDIES_B.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM
    -- sjalasut added new column for subsidy pools enhancement. start
    ,subsidy_pool_id                NUMBER := OKL_API.G_MISS_NUM
    -- sjalasut added new column for subsidy pools enhancement. end
    );
  G_MISS_subb_rec                         subb_rec_type;
  TYPE subb_tbl_type IS TABLE OF subb_rec_type
        INDEX BY BINARY_INTEGER;
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_SUB_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE add_language;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_rec                     IN subv_rec_type,
    x_subv_rec                     OUT NOCOPY subv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_tbl                     IN subv_tbl_type,
    x_subv_tbl                     OUT NOCOPY subv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_tbl                     IN subv_tbl_type,
    x_subv_tbl                     OUT NOCOPY subv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_rec                     IN subv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_tbl                     IN subv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_tbl                     IN subv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_rec                     IN subv_rec_type,
    x_subv_rec                     OUT NOCOPY subv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_tbl                     IN subv_tbl_type,
    x_subv_tbl                     OUT NOCOPY subv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_tbl                     IN subv_tbl_type,
    x_subv_tbl                     OUT NOCOPY subv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_rec                     IN subv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_tbl                     IN subv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_tbl                     IN subv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_rec                     IN subv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_tbl                     IN subv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_tbl                     IN subv_tbl_type);
END OKL_SUB_PVT;

 

/
