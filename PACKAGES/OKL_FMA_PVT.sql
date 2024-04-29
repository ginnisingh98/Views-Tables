--------------------------------------------------------
--  DDL for Package OKL_FMA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_FMA_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSFMAS.pls 120.2 2006/12/07 06:13:21 ssdeshpa noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE fma_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    name                           OKL_FORMULAE_B.NAME%TYPE := OKC_API.G_MISS_CHAR,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    there_can_be_only_one_yn       OKL_FORMULAE_B.THERE_CAN_BE_ONLY_ONE_YN%TYPE := OKC_API.G_MISS_CHAR,
    cgr_id                         NUMBER := OKC_API.G_MISS_NUM,
    fyp_code                       OKL_FORMULAE_B.FYP_CODE%TYPE := OKC_API.G_MISS_CHAR,
    version                        OKL_FORMULAE_B.VERSION%TYPE := OKC_API.G_MISS_CHAR,
    formula_string                 OKL_FORMULAE_B.FORMULA_STRING%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    start_date                     OKL_FORMULAE_B.START_DATE%TYPE := OKC_API.G_MISS_DATE,
    attribute_category             OKL_FORMULAE_B.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    end_date                       OKL_FORMULAE_B.END_DATE%TYPE := OKC_API.G_MISS_DATE,
    attribute1                     OKL_FORMULAE_B.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKL_FORMULAE_B.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKL_FORMULAE_B.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKL_FORMULAE_B.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKL_FORMULAE_B.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKL_FORMULAE_B.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKL_FORMULAE_B.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKL_FORMULAE_B.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKL_FORMULAE_B.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKL_FORMULAE_B.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKL_FORMULAE_B.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKL_FORMULAE_B.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKL_FORMULAE_B.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKL_FORMULAE_B.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKL_FORMULAE_B.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_FORMULAE_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_FORMULAE_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_fma_rec                          fma_rec_type;
  TYPE fma_tbl_type IS TABLE OF fma_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE okl_formulae_tl_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    language                       OKL_FORMULAE_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR,
    source_lang                    OKL_FORMULAE_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR,
    sfwt_flag                      OKL_FORMULAE_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKL_FORMULAE_TL.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_FORMULAE_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_FORMULAE_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_okl_formulae_tl_rec              okl_formulae_tl_rec_type;
  TYPE okl_formulae_tl_tbl_type IS TABLE OF okl_formulae_tl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE fmav_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    sfwt_flag                      OKL_FORMULAE_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    cgr_id                         NUMBER := OKC_API.G_MISS_NUM,
    fyp_code                       OKL_FORMULAE_V.FYP_CODE%TYPE := OKC_API.G_MISS_CHAR,
    name                           OKL_FORMULAE_V.NAME%TYPE := OKC_API.G_MISS_CHAR,
    formula_string                 OKL_FORMULAE_V.FORMULA_STRING%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKL_FORMULAE_V.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    version                        OKL_FORMULAE_V.VERSION%TYPE := OKC_API.G_MISS_CHAR,
    start_date                     OKL_FORMULAE_V.START_DATE%TYPE := OKC_API.G_MISS_DATE,
    end_date                       OKL_FORMULAE_V.END_DATE%TYPE := OKC_API.G_MISS_DATE,
    attribute_category             OKL_FORMULAE_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKL_FORMULAE_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKL_FORMULAE_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKL_FORMULAE_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKL_FORMULAE_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKL_FORMULAE_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKL_FORMULAE_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKL_FORMULAE_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKL_FORMULAE_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKL_FORMULAE_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKL_FORMULAE_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKL_FORMULAE_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKL_FORMULAE_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKL_FORMULAE_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKL_FORMULAE_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKL_FORMULAE_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    there_can_be_only_one_yn       OKL_FORMULAE_V.THERE_CAN_BE_ONLY_ONE_YN%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_FORMULAE_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_FORMULAE_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_fmav_rec                         fmav_rec_type;
  TYPE fmav_tbl_type IS TABLE OF fmav_rec_type
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

  -- RPOONUGA001: Add new message constants
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN		CONSTANT VARCHAR2(200) := 'OKC_SQLERRM';
  G_SQLCODE_TOKEN		CONSTANT VARCHAR2(200) := 'OKC_SQLCODE';
  G_TABLE_TOKEN		CONSTANT VARCHAR2(200) := 'OKL_TABLE_NAME';
  G_UPPERCASE_REQUIRED	CONSTANT VARCHAR2(200) := 'OKC_UPPER_CASE_REQUIRED';
  G_ONE_DOI	CONSTANT VARCHAR2(200) := 'OKC_ONE_DOI';
---  G_UNQS	CONSTANT VARCHAR2(200) := 'OKL_FMA_NOT_UNIQUE';  ---CHG001
  G_UNQS	CONSTANT VARCHAR2(200) := 'OKL_NOT_UNIQUE';  ---CHG001
  G_TO_DATE_ERROR	    CONSTANT VARCHAR2(200) := 'OKL_TO_DATE_ERROR';
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_FMA_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- RPOONUGA001: Add new global exception
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION  EXCEPTION;

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
    p_fmav_rec                     IN fmav_rec_type,
    x_fmav_rec                     OUT NOCOPY fmav_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fmav_tbl                     IN fmav_tbl_type,
    x_fmav_tbl                     OUT NOCOPY fmav_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fmav_rec                     IN fmav_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fmav_tbl                     IN fmav_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fmav_rec                     IN fmav_rec_type,
    x_fmav_rec                     OUT NOCOPY fmav_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fmav_tbl                     IN fmav_tbl_type,
    x_fmav_tbl                     OUT NOCOPY fmav_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fmav_rec                     IN fmav_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fmav_tbl                     IN fmav_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fmav_rec                     IN fmav_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fmav_tbl                     IN fmav_tbl_type);

  PROCEDURE LOAD_SEED_ROW(
    p_upload_mode                   IN VARCHAR2,
    p_formulae_id                   IN VARCHAR2,
    p_name                          IN VARCHAR2,
    p_version                       IN VARCHAR2,
    p_org_id                        IN VARCHAR2,
    p_there_can_be_only_one_yn      IN VARCHAR2,
    p_cgr_id                        IN VARCHAR2,
    p_fyp_code                      IN VARCHAR2,
    p_formula_string                IN VARCHAR2,
    p_object_version_number         IN VARCHAR2,
    p_start_date                    IN VARCHAR2,
    p_end_date                      IN VARCHAR2,
    p_attribute_category            IN VARCHAR2,
    p_attribute1                    IN VARCHAR2,
    p_attribute2                    IN VARCHAR2,
    p_attribute3                    IN VARCHAR2,
    p_attribute4                    IN VARCHAR2,
    p_attribute5                    IN VARCHAR2,
    p_attribute6                    IN VARCHAR2,
    p_attribute7                    IN VARCHAR2,
    p_attribute8                    IN VARCHAR2,
    p_attribute9                    IN VARCHAR2,
    p_attribute10                   IN VARCHAR2,
    p_attribute11                   IN VARCHAR2,
    p_attribute12                   IN VARCHAR2,
    p_attribute13                   IN VARCHAR2,
    p_attribute14                   IN VARCHAR2,
    p_attribute15                   IN VARCHAR2,
    p_description                   IN VARCHAR2,
    p_owner                         IN VARCHAR2,
    p_last_update_date              IN VARCHAR2);


END OKL_FMA_PVT;

/
