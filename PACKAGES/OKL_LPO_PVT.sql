--------------------------------------------------------
--  DDL for Package OKL_LPO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LPO_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSLPOS.pls 115.5 2003/11/06 01:41:44 pjgomes noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE lpov_rec_type IS RECORD (
     id                             NUMBER := Okc_Api.G_MISS_NUM
    ,org_id                         NUMBER := Okc_Api.G_MISS_NUM
    ,name                           OKL_LATE_POLICIES_V.NAME%TYPE := Okc_Api.G_MISS_CHAR
    ,description                    OKL_LATE_POLICIES_V.DESCRIPTION%TYPE := Okc_Api.G_MISS_CHAR
    ,ise_id                         NUMBER := Okc_Api.G_MISS_NUM
    ,tdf_id                         NUMBER := Okc_Api.G_MISS_NUM
    ,idx_id                         NUMBER := Okc_Api.G_MISS_NUM
    ,late_policy_type_code          OKL_LATE_POLICIES_V.LATE_POLICY_TYPE_CODE%TYPE := Okc_Api.G_MISS_CHAR
    ,object_version_number          NUMBER := Okc_Api.G_MISS_NUM
    ,late_chrg_allowed_yn           OKL_LATE_POLICIES_V.LATE_CHRG_ALLOWED_YN%TYPE := Okc_Api.G_MISS_CHAR
    ,late_chrg_fixed_yn             OKL_LATE_POLICIES_V.LATE_CHRG_FIXED_YN%TYPE := Okc_Api.G_MISS_CHAR
    ,late_chrg_amount               NUMBER := Okc_Api.G_MISS_NUM
    ,late_chrg_rate                 NUMBER := Okc_Api.G_MISS_NUM
    ,late_chrg_grace_period         NUMBER := Okc_Api.G_MISS_NUM
    ,late_chrg_minimum_balance      NUMBER := Okc_Api.G_MISS_NUM
    ,minimum_late_charge            NUMBER := Okc_Api.G_MISS_NUM
    ,maximum_late_charge            NUMBER := Okc_Api.G_MISS_NUM
    ,late_int_allowed_yn            OKL_LATE_POLICIES_V.LATE_INT_ALLOWED_YN%TYPE := Okc_Api.G_MISS_CHAR
    ,late_int_fixed_yn              OKL_LATE_POLICIES_V.LATE_INT_FIXED_YN%TYPE := Okc_Api.G_MISS_CHAR
    ,late_int_rate                  NUMBER := Okc_Api.G_MISS_NUM
    ,adder_rate                     NUMBER := Okc_Api.G_MISS_NUM
    ,late_int_grace_period          NUMBER := Okc_Api.G_MISS_NUM
    ,late_int_minimum_balance       NUMBER := Okc_Api.G_MISS_NUM
    ,minimum_late_interest          NUMBER := Okc_Api.G_MISS_NUM
    ,maximum_late_interest          NUMBER := Okc_Api.G_MISS_NUM
    ,attribute_category             OKL_LATE_POLICIES_V.ATTRIBUTE_CATEGORY%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute1                     OKL_LATE_POLICIES_V.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute2                     OKL_LATE_POLICIES_V.ATTRIBUTE2%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute3                     OKL_LATE_POLICIES_V.ATTRIBUTE3%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute4                     OKL_LATE_POLICIES_V.ATTRIBUTE4%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute5                     OKL_LATE_POLICIES_V.ATTRIBUTE5%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute6                     OKL_LATE_POLICIES_V.ATTRIBUTE6%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute7                     OKL_LATE_POLICIES_V.ATTRIBUTE7%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute8                     OKL_LATE_POLICIES_V.ATTRIBUTE8%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute9                     OKL_LATE_POLICIES_V.ATTRIBUTE9%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute10                    OKL_LATE_POLICIES_V.ATTRIBUTE10%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute11                    OKL_LATE_POLICIES_V.ATTRIBUTE11%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute12                    OKL_LATE_POLICIES_V.ATTRIBUTE12%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute13                    OKL_LATE_POLICIES_V.ATTRIBUTE13%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute14                    OKL_LATE_POLICIES_V.ATTRIBUTE14%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute15                    OKL_LATE_POLICIES_V.ATTRIBUTE15%TYPE := Okc_Api.G_MISS_CHAR
    ,created_by                     NUMBER := Okc_Api.G_MISS_NUM
    ,creation_date                  OKL_LATE_POLICIES_V.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE
    ,last_updated_by                NUMBER := Okc_Api.G_MISS_NUM
    ,last_update_date               OKL_LATE_POLICIES_V.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE
    ,last_update_login              NUMBER := Okc_Api.G_MISS_NUM
    ,DAYS_IN_YEAR                   OKL_LATE_POLICIES_V.DAYS_IN_YEAR%TYPE := Okc_Api.G_MISS_CHAR);
  G_MISS_lpov_rec                         lpov_rec_type;
  TYPE lpov_tbl_type IS TABLE OF lpov_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE lpo_rec_type IS RECORD (
     id                             NUMBER := Okc_Api.G_MISS_NUM
    ,org_id                         NUMBER := Okc_Api.G_MISS_NUM
    ,ise_id                         NUMBER := Okc_Api.G_MISS_NUM
    ,tdf_id                         NUMBER := Okc_Api.G_MISS_NUM
    ,idx_id                         NUMBER := Okc_Api.G_MISS_NUM
    ,late_policy_type_code          OKL_LATE_POLICIES_B.LATE_POLICY_TYPE_CODE%TYPE := Okc_Api.G_MISS_CHAR
    ,object_version_number          NUMBER := Okc_Api.G_MISS_NUM
    ,late_chrg_allowed_yn           OKL_LATE_POLICIES_B.LATE_CHRG_ALLOWED_YN%TYPE := Okc_Api.G_MISS_CHAR
    ,late_chrg_fixed_yn             OKL_LATE_POLICIES_B.LATE_CHRG_FIXED_YN%TYPE := Okc_Api.G_MISS_CHAR
    ,late_chrg_amount               NUMBER := Okc_Api.G_MISS_NUM
    ,late_chrg_rate                 NUMBER := Okc_Api.G_MISS_NUM
    ,late_chrg_grace_period         NUMBER := Okc_Api.G_MISS_NUM
    ,late_chrg_minimum_balance      NUMBER := Okc_Api.G_MISS_NUM
    ,minimum_late_charge            NUMBER := Okc_Api.G_MISS_NUM
    ,maximum_late_charge            NUMBER := Okc_Api.G_MISS_NUM
    ,late_int_allowed_yn            OKL_LATE_POLICIES_B.LATE_INT_ALLOWED_YN%TYPE := Okc_Api.G_MISS_CHAR
    ,late_int_fixed_yn              OKL_LATE_POLICIES_B.LATE_INT_FIXED_YN%TYPE := Okc_Api.G_MISS_CHAR
    ,late_int_rate                  NUMBER := Okc_Api.G_MISS_NUM
    ,adder_rate                     NUMBER := Okc_Api.G_MISS_NUM
    ,late_int_grace_period          NUMBER := Okc_Api.G_MISS_NUM
    ,late_int_minimum_balance       NUMBER := Okc_Api.G_MISS_NUM
    ,minimum_late_interest          NUMBER := Okc_Api.G_MISS_NUM
    ,maximum_late_interest          NUMBER := Okc_Api.G_MISS_NUM
    ,attribute_category             OKL_LATE_POLICIES_B.ATTRIBUTE_CATEGORY%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute1                     OKL_LATE_POLICIES_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute2                     OKL_LATE_POLICIES_B.ATTRIBUTE2%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute3                     OKL_LATE_POLICIES_B.ATTRIBUTE3%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute4                     OKL_LATE_POLICIES_B.ATTRIBUTE4%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute5                     OKL_LATE_POLICIES_B.ATTRIBUTE5%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute6                     OKL_LATE_POLICIES_B.ATTRIBUTE6%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute7                     OKL_LATE_POLICIES_B.ATTRIBUTE7%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute8                     OKL_LATE_POLICIES_B.ATTRIBUTE8%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute9                     OKL_LATE_POLICIES_B.ATTRIBUTE9%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute10                    OKL_LATE_POLICIES_B.ATTRIBUTE10%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute11                    OKL_LATE_POLICIES_B.ATTRIBUTE11%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute12                    OKL_LATE_POLICIES_B.ATTRIBUTE12%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute13                    OKL_LATE_POLICIES_B.ATTRIBUTE13%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute14                    OKL_LATE_POLICIES_B.ATTRIBUTE14%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute15                    OKL_LATE_POLICIES_B.ATTRIBUTE15%TYPE := Okc_Api.G_MISS_CHAR
    ,created_by                     NUMBER := Okc_Api.G_MISS_NUM
    ,creation_date                  OKL_LATE_POLICIES_B.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE
    ,last_updated_by                NUMBER := Okc_Api.G_MISS_NUM
    ,last_update_date               OKL_LATE_POLICIES_B.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE
    ,last_update_login              NUMBER := Okc_Api.G_MISS_NUM
    ,DAYS_IN_YEAR                   OKL_LATE_POLICIES_B.DAYS_IN_YEAR%TYPE := Okc_Api.G_MISS_CHAR);

  G_MISS_lpo_rec                          lpo_rec_type;
  TYPE lpo_tbl_type IS TABLE OF lpo_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE okl_late_policies_tl_rec_type IS RECORD (
     id                             NUMBER := Okc_Api.G_MISS_NUM
    ,LANGUAGE                       OKL_LATE_POLICIES_TL.LANGUAGE%TYPE := Okc_Api.G_MISS_CHAR
    ,source_lang                    OKL_LATE_POLICIES_TL.SOURCE_LANG%TYPE := Okc_Api.G_MISS_CHAR
    ,name                           OKL_LATE_POLICIES_TL.NAME%TYPE := Okc_Api.G_MISS_CHAR
    ,description                    OKL_LATE_POLICIES_TL.DESCRIPTION%TYPE := Okc_Api.G_MISS_CHAR
    ,created_by                     NUMBER := Okc_Api.G_MISS_NUM
    ,creation_date                  OKL_LATE_POLICIES_TL.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE
    ,last_updated_by                NUMBER := Okc_Api.G_MISS_NUM
    ,last_update_date               OKL_LATE_POLICIES_TL.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE
    ,last_update_login              NUMBER := Okc_Api.G_MISS_NUM);
  GMissOklLatePoliciesTlRec               okl_late_policies_tl_rec_type;
  TYPE okl_late_policies_tl_tbl_type IS TABLE OF okl_late_policies_tl_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                      CONSTANT VARCHAR2(200) := Okc_Api.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC   CONSTANT VARCHAR2(200) := Okc_Api.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED          CONSTANT VARCHAR2(200) := Okc_Api.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED          CONSTANT VARCHAR2(200) := Okc_Api.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED     CONSTANT VARCHAR2(200) := Okc_Api.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE               CONSTANT VARCHAR2(200) := Okc_Api.G_REQUIRED_VALUE;
  G_INVALID_VALUE                CONSTANT VARCHAR2(200) := Okc_Api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN               CONSTANT VARCHAR2(200) := Okc_Api.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN           CONSTANT VARCHAR2(200) := Okc_Api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN            CONSTANT VARCHAR2(200) := Okc_Api.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200) := 'OKS_SERVICE_AVAILABILITY_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN                CONSTANT VARCHAR2(200) := 'SQLcode';
  G_SQLERRM_TOKEN                CONSTANT VARCHAR2(200) := 'SQLerrm';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_LPO_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := Okc_Api.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE add_language;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lpov_rec                     IN lpov_rec_type,
    x_lpov_rec                     OUT NOCOPY lpov_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lpov_tbl                     IN lpov_tbl_type,
    x_lpov_tbl                     OUT NOCOPY lpov_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lpov_rec                     IN lpov_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lpov_tbl                     IN lpov_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lpov_rec                     IN lpov_rec_type,
    x_lpov_rec                     OUT NOCOPY lpov_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lpov_tbl                     IN lpov_tbl_type,
    x_lpov_tbl                     OUT NOCOPY lpov_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lpov_rec                     IN lpov_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lpov_tbl                     IN lpov_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lpov_rec                     IN lpov_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lpov_tbl                     IN lpov_tbl_type);
END Okl_Lpo_Pvt;

 

/
