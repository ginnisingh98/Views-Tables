--------------------------------------------------------
--  DDL for Package OKC_CNH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CNH_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCSCNHS.pls 120.0 2005/05/25 23:05:09 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE cnh_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    acn_id                         NUMBER := OKC_API.G_MISS_NUM,
    counter_group_id               NUMBER := OKC_API.G_MISS_NUM,
    one_time_yn                    OKC_CONDITION_HEADERS_B.ONE_TIME_YN%TYPE := OKC_API.G_MISS_CHAR,
    before_after                   OKC_CONDITION_HEADERS_B.BEFORE_AFTER%TYPE := OKC_API.G_MISS_CHAR,
    cnh_variance                   NUMBER := OKC_API.G_MISS_NUM,
    condition_valid_yn             OKC_CONDITION_HEADERS_B.CONDITION_VALID_YN%TYPE := OKC_API.G_MISS_CHAR,
    tracked_yn                     OKC_CONDITION_HEADERS_B.TRACKED_YN%TYPE := OKC_API.G_MISS_CHAR,
    date_active                    OKC_CONDITION_HEADERS_B.DATE_ACTIVE%TYPE := OKC_API.G_MISS_DATE,
    date_inactive                  OKC_CONDITION_HEADERS_B.DATE_INACTIVE%TYPE := OKC_API.G_MISS_DATE,
    cnh_type                       OKC_CONDITION_HEADERS_B.CNH_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    template_yn                    OKC_CONDITION_HEADERS_B.TEMPLATE_YN%TYPE := OKC_API.G_MISS_CHAR,
    dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM,
    object_id                      NUMBER := OKC_API.G_MISS_NUM,
    jtot_object_code               OKC_CONDITION_HEADERS_B.JTOT_OBJECT_CODE%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    task_owner_id                  NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_CONDITION_HEADERS_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_CONDITION_HEADERS_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    attribute_category             OKC_CONDITION_HEADERS_B.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_CONDITION_HEADERS_B.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_CONDITION_HEADERS_B.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_CONDITION_HEADERS_B.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_CONDITION_HEADERS_B.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_CONDITION_HEADERS_B.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_CONDITION_HEADERS_B.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_CONDITION_HEADERS_B.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_CONDITION_HEADERS_B.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_CONDITION_HEADERS_B.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_CONDITION_HEADERS_B.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_CONDITION_HEADERS_B.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_CONDITION_HEADERS_B.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_CONDITION_HEADERS_B.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_CONDITION_HEADERS_B.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_CONDITION_HEADERS_B.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    application_id                 NUMBER := OKC_API.G_MISS_NUM,
    seeded_flag                    OKC_CONDITION_HEADERS_B.SEEDED_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    last_rundate                  OKC_CONDITION_HEADERS_B.LAST_RUNDATE%TYPE := OKC_API.G_MISS_DATE);
  g_miss_cnh_rec                          cnh_rec_type;
  TYPE cnh_tbl_type IS TABLE OF cnh_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE OkcConditionHeadersTlRecType IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    language                       OKC_CONDITION_HEADERS_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR,
    source_lang                    OKC_CONDITION_HEADERS_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR,
    sfwt_flag                      OKC_CONDITION_HEADERS_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    name                           OKC_CONDITION_HEADERS_TL.NAME%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKC_CONDITION_HEADERS_TL.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    short_description              OKC_CONDITION_HEADERS_TL.SHORT_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    comments                       OKC_CONDITION_HEADERS_TL.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_CONDITION_HEADERS_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_CONDITION_HEADERS_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  GMissOkcConditionHeadersTlRec           OkcConditionHeadersTlRecType;
  TYPE OkcConditionHeadersTlTblType IS TABLE OF OkcConditionHeadersTlRecType
        INDEX BY BINARY_INTEGER;
  TYPE cnhv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    sfwt_flag                      OKC_CONDITION_HEADERS_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    acn_id                         NUMBER := OKC_API.G_MISS_NUM,
    counter_group_id               NUMBER := OKC_API.G_MISS_NUM,
    description                    OKC_CONDITION_HEADERS_V.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    short_description              OKC_CONDITION_HEADERS_V.SHORT_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    comments                       OKC_CONDITION_HEADERS_V.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    one_time_yn                    OKC_CONDITION_HEADERS_V.ONE_TIME_YN%TYPE := OKC_API.G_MISS_CHAR,
    name                           OKC_CONDITION_HEADERS_V.NAME%TYPE := OKC_API.G_MISS_CHAR,
    condition_valid_yn             OKC_CONDITION_HEADERS_V.CONDITION_VALID_YN%TYPE := OKC_API.G_MISS_CHAR,
    before_after                   OKC_CONDITION_HEADERS_V.BEFORE_AFTER%TYPE := OKC_API.G_MISS_CHAR,
    tracked_yn                     OKC_CONDITION_HEADERS_V.TRACKED_YN%TYPE := OKC_API.G_MISS_CHAR,
    cnh_variance                   NUMBER := OKC_API.G_MISS_NUM,
    dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM,
    template_yn                    OKC_CONDITION_HEADERS_V.TEMPLATE_YN%TYPE := OKC_API.G_MISS_CHAR,
    date_active                    OKC_CONDITION_HEADERS_V.DATE_ACTIVE%TYPE := OKC_API.G_MISS_DATE,
    object_id                      NUMBER := OKC_API.G_MISS_NUM,
    date_inactive                  OKC_CONDITION_HEADERS_V.DATE_INACTIVE%TYPE := OKC_API.G_MISS_DATE,
    jtot_object_code               OKC_CONDITION_HEADERS_V.JTOT_OBJECT_CODE%TYPE := OKC_API.G_MISS_CHAR,
    task_owner_id                  NUMBER := OKC_API.G_MISS_NUM,
    cnh_type                       OKC_CONDITION_HEADERS_V.CNH_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    application_id                 NUMBER := OKC_API.G_MISS_NUM,
    seeded_flag                    OKC_CONDITION_HEADERS_V.SEEDED_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    last_rundate                   OKC_CONDITION_HEADERS_V.LAST_RUNDATE%TYPE := OKC_API.G_MISS_DATE,
    attribute_category             OKC_CONDITION_HEADERS_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_CONDITION_HEADERS_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_CONDITION_HEADERS_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_CONDITION_HEADERS_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_CONDITION_HEADERS_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_CONDITION_HEADERS_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_CONDITION_HEADERS_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_CONDITION_HEADERS_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_CONDITION_HEADERS_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_CONDITION_HEADERS_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_CONDITION_HEADERS_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_CONDITION_HEADERS_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_CONDITION_HEADERS_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_CONDITION_HEADERS_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_CONDITION_HEADERS_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_CONDITION_HEADERS_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_CONDITION_HEADERS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_CONDITION_HEADERS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_cnhv_rec                         cnhv_rec_type;
  TYPE cnhv_tbl_type IS TABLE OF cnhv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE	      	CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN   		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_COL_NAME_TOKEN1   		CONSTANT VARCHAR2(30) := 'COL_NAME1';
  G_COL_NAME_TOKEN2   		CONSTANT VARCHAR2(30) := 'COL_NAME2';
  G_COL_NAME_TOKEN3   		CONSTANT VARCHAR2(30) := 'COL_NAME3';
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN   		CONSTANT VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN   		CONSTANT VARCHAR2(200) := 'ERROR_CODE';
  G_UPPERCASE_REQUIRED		CONSTANT VARCHAR2(200) := 'OKC_UPPERCASE_REQUIRED';
  --G_UNQS	CONSTANT VARCHAR2(200) := 'OKC_VALUES_NOT_UNIQUE';
  G_UNQS	CONSTANT VARCHAR2(200) := 'OKC_CNH_OBJECT_JTOT_NOT_UNIQUE';
  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_CNH_PVT';
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
    p_cnhv_rec                     IN cnhv_rec_type,
    x_cnhv_rec                     OUT NOCOPY cnhv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnhv_tbl                     IN cnhv_tbl_type,
    x_cnhv_tbl                     OUT NOCOPY cnhv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnhv_rec                     IN cnhv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnhv_tbl                     IN cnhv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnhv_rec                     IN cnhv_rec_type,
    x_cnhv_rec                     OUT NOCOPY cnhv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnhv_tbl                     IN cnhv_tbl_type,
    x_cnhv_tbl                     OUT NOCOPY cnhv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnhv_rec                     IN cnhv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnhv_tbl                     IN cnhv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnhv_rec                     IN cnhv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnhv_tbl                     IN cnhv_tbl_type);

  PROCEDURE INSERT_ROW_UPG(x_return_status OUT NOCOPY VARCHAR2, p_cnhv_tbl cnhv_tbl_type);

  FUNCTION create_version(
    p_chr_id					IN NUMBER,
    p_major_version				IN NUMBER) RETURN VARCHAR2;

  FUNCTION restore_version(
    p_chr_id					IN NUMBER,
    p_major_version				IN NUMBER) RETURN VARCHAR2;

END OKC_CNH_PVT;

 

/
