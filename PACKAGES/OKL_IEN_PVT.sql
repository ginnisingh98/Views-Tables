--------------------------------------------------------
--  DDL for Package OKL_IEN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_IEN_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSIENS.pls 115.5 2002/03/03 13:54:57 pkm ship       $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE ien_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    country_id                     OKL_INS_EXCLUSIONS_B.COUNTRY_ID%TYPE := OKC_API.G_MISS_CHAR,
    date_from                      OKL_INS_EXCLUSIONS_B.DATE_FROM%TYPE := OKC_API.G_MISS_DATE,
    coll_code                      NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          OKL_INS_EXCLUSIONS_B.OBJECT_VERSION_NUMBER%TYPE,
    sic_code                       OKL_INS_EXCLUSIONS_B.SIC_CODE%TYPE := OKC_API.G_MISS_CHAR,
    date_to                        OKL_INS_EXCLUSIONS_B.DATE_TO%TYPE := OKC_API.G_MISS_DATE,
    --comments                       OKL_INS_EXCLUSIONS_B.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category             OKL_INS_EXCLUSIONS_B.ATTRIBUTE_CATEGORY%TYPE,
    attribute1                     OKL_INS_EXCLUSIONS_B.ATTRIBUTE1%TYPE,
    attribute2                     OKL_INS_EXCLUSIONS_B.ATTRIBUTE2%TYPE,
    attribute3                     OKL_INS_EXCLUSIONS_B.ATTRIBUTE3%TYPE,
    attribute4                     OKL_INS_EXCLUSIONS_B.ATTRIBUTE4%TYPE,
    attribute5                     OKL_INS_EXCLUSIONS_B.ATTRIBUTE5%TYPE,
    attribute6                     OKL_INS_EXCLUSIONS_B.ATTRIBUTE6%TYPE,
    attribute7                     OKL_INS_EXCLUSIONS_B.ATTRIBUTE7%TYPE,
    attribute8                     OKL_INS_EXCLUSIONS_B.ATTRIBUTE8%TYPE,
    attribute9                     OKL_INS_EXCLUSIONS_B.ATTRIBUTE9%TYPE,
    attribute10                    OKL_INS_EXCLUSIONS_B.ATTRIBUTE10%TYPE,
    attribute11                    OKL_INS_EXCLUSIONS_B.ATTRIBUTE11%TYPE,
    attribute12                    OKL_INS_EXCLUSIONS_B.ATTRIBUTE12%TYPE,
    attribute13                    OKL_INS_EXCLUSIONS_B.ATTRIBUTE13%TYPE,
    attribute14                    OKL_INS_EXCLUSIONS_B.ATTRIBUTE14%TYPE,
    attribute15                    OKL_INS_EXCLUSIONS_B.ATTRIBUTE15%TYPE,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_INS_EXCLUSIONS_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_INS_EXCLUSIONS_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_ien_rec                          ien_rec_type;
  TYPE ien_tbl_type IS TABLE OF ien_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE okl_ins_exclusions_tl_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    LANGUAGE                       OKL_INS_EXCLUSIONS_TL.LANGUAGE%TYPE,
    source_lang                    OKL_INS_EXCLUSIONS_TL.SOURCE_LANG%TYPE,
    sfwt_flag                      OKL_INS_EXCLUSIONS_TL.SFWT_FLAG%TYPE,
    comments                       OKL_INS_EXCLUSIONS_TL.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_INS_EXCLUSIONS_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_INS_EXCLUSIONS_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM
	);
  GMissOklInsExclusionsTlRec              okl_ins_exclusions_tl_rec_type;
  TYPE okl_ins_exclusions_tl_tbl_type IS TABLE OF okl_ins_exclusions_tl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE ienv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          OKL_INS_EXCLUSIONS_V.OBJECT_VERSION_NUMBER%TYPE,
    sfwt_flag                      OKL_INS_EXCLUSIONS_V.SFWT_FLAG%TYPE,
    country_id                     OKL_INS_EXCLUSIONS_V.COUNTRY_ID%TYPE := OKC_API.G_MISS_CHAR,
    coll_code                      NUMBER := OKC_API.G_MISS_NUM,
    attribute_category             OKL_INS_EXCLUSIONS_V.ATTRIBUTE_CATEGORY%TYPE,
    attribute1                     OKL_INS_EXCLUSIONS_V.ATTRIBUTE1%TYPE,
    attribute2                     OKL_INS_EXCLUSIONS_V.ATTRIBUTE2%TYPE,
    attribute3                     OKL_INS_EXCLUSIONS_V.ATTRIBUTE3%TYPE,
    attribute4                     OKL_INS_EXCLUSIONS_V.ATTRIBUTE4%TYPE,
    attribute5                     OKL_INS_EXCLUSIONS_V.ATTRIBUTE5%TYPE,
    attribute6                     OKL_INS_EXCLUSIONS_V.ATTRIBUTE6%TYPE,
    attribute7                     OKL_INS_EXCLUSIONS_V.ATTRIBUTE7%TYPE,
    attribute8                     OKL_INS_EXCLUSIONS_V.ATTRIBUTE8%TYPE,
    attribute9                     OKL_INS_EXCLUSIONS_V.ATTRIBUTE9%TYPE,
    attribute10                    OKL_INS_EXCLUSIONS_V.ATTRIBUTE10%TYPE,
    attribute11                    OKL_INS_EXCLUSIONS_V.ATTRIBUTE11%TYPE,
    attribute12                    OKL_INS_EXCLUSIONS_V.ATTRIBUTE12%TYPE,
    attribute13                    OKL_INS_EXCLUSIONS_V.ATTRIBUTE13%TYPE,
    attribute14                    OKL_INS_EXCLUSIONS_V.ATTRIBUTE14%TYPE,
    attribute15                    OKL_INS_EXCLUSIONS_V.ATTRIBUTE15%TYPE,
    date_from                      OKL_INS_EXCLUSIONS_V.DATE_FROM%TYPE := OKC_API.G_MISS_DATE,
    sic_code                       OKL_INS_EXCLUSIONS_V.SIC_CODE%TYPE := OKC_API.G_MISS_CHAR,
    date_to                        OKL_INS_EXCLUSIONS_V.DATE_TO%TYPE := OKC_API.G_MISS_DATE,
    comments                       OKL_INS_EXCLUSIONS_V.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_INS_EXCLUSIONS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_INS_EXCLUSIONS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM
	);
  g_miss_ienv_rec                         ienv_rec_type;
  TYPE ienv_tbl_type IS TABLE OF ienv_rec_type
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
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_IEN_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  'OKL';
  -------------------------------------------------------------------------------
  --Post change to TAPI code
  -------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION EXCEPTION;
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  g_no_parent_record            CONSTANT VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
  ---------------------------------------------------------------------------
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
    p_ienv_rec                     IN ienv_rec_type,
    x_ienv_rec                     OUT NOCOPY ienv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ienv_tbl                     IN ienv_tbl_type,
    x_ienv_tbl                     OUT NOCOPY ienv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ienv_rec                     IN ienv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ienv_tbl                     IN ienv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ienv_rec                     IN ienv_rec_type,
    x_ienv_rec                     OUT NOCOPY ienv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ienv_tbl                     IN ienv_tbl_type,
    x_ienv_tbl                     OUT NOCOPY ienv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ienv_rec                     IN ienv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ienv_tbl                     IN ienv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ienv_rec                     IN ienv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ienv_tbl                     IN ienv_tbl_type);
END Okl_Ien_Pvt;

 

/
