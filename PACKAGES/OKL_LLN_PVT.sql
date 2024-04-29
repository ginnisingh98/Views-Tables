--------------------------------------------------------
--  DDL for Package OKL_LLN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LLN_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSLLNS.pls 115.5 2002/04/16 15:26:27 pkm ship        $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE lln_rec_type IS RECORD (
    id                             NUMBER := Okc_Api.G_MISS_NUM,
    sequence_number                NUMBER := Okc_Api.G_MISS_NUM,
    lln_id_parent                  NUMBER := Okc_Api.G_MISS_NUM,
    kle_id                         NUMBER := Okc_Api.G_MISS_NUM,
    khr_id                         NUMBER := Okc_Api.G_MISS_NUM,
    cnr_id                         NUMBER := Okc_Api.G_MISS_NUM,
    ilt_id                         NUMBER := Okc_Api.G_MISS_NUM,
    line_type                      OKL_CNSLD_AR_LINES_B.LINE_TYPE%TYPE := Okc_Api.G_MISS_CHAR,
    amount                         NUMBER := Okc_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okc_Api.G_MISS_NUM,
    request_id                     NUMBER := Okc_Api.G_MISS_NUM,
    program_application_id         NUMBER := Okc_Api.G_MISS_NUM,
    program_id                     NUMBER := Okc_Api.G_MISS_NUM,
    program_update_date            OKL_CNSLD_AR_LINES_B.PROGRAM_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    org_id                         NUMBER := Okc_Api.G_MISS_NUM,
    tax_amount                     NUMBER := Okc_Api.G_MISS_NUM,
    attribute_category             OKL_CNSLD_AR_LINES_B.ATTRIBUTE_CATEGORY%TYPE := Okc_Api.G_MISS_CHAR,
    attribute1                     OKL_CNSLD_AR_LINES_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    attribute2                     OKL_CNSLD_AR_LINES_B.ATTRIBUTE2%TYPE := Okc_Api.G_MISS_CHAR,
    attribute3                     OKL_CNSLD_AR_LINES_B.ATTRIBUTE3%TYPE := Okc_Api.G_MISS_CHAR,
    attribute4                     OKL_CNSLD_AR_LINES_B.ATTRIBUTE4%TYPE := Okc_Api.G_MISS_CHAR,
    attribute5                     OKL_CNSLD_AR_LINES_B.ATTRIBUTE5%TYPE := Okc_Api.G_MISS_CHAR,
    attribute6                     OKL_CNSLD_AR_LINES_B.ATTRIBUTE6%TYPE := Okc_Api.G_MISS_CHAR,
    attribute7                     OKL_CNSLD_AR_LINES_B.ATTRIBUTE7%TYPE := Okc_Api.G_MISS_CHAR,
    attribute8                     OKL_CNSLD_AR_LINES_B.ATTRIBUTE8%TYPE := Okc_Api.G_MISS_CHAR,
    attribute9                     OKL_CNSLD_AR_LINES_B.ATTRIBUTE9%TYPE := Okc_Api.G_MISS_CHAR,
    attribute10                    OKL_CNSLD_AR_LINES_B.ATTRIBUTE10%TYPE := Okc_Api.G_MISS_CHAR,
    attribute11                    OKL_CNSLD_AR_LINES_B.ATTRIBUTE11%TYPE := Okc_Api.G_MISS_CHAR,
    attribute12                    OKL_CNSLD_AR_LINES_B.ATTRIBUTE12%TYPE := Okc_Api.G_MISS_CHAR,
    attribute13                    OKL_CNSLD_AR_LINES_B.ATTRIBUTE13%TYPE := Okc_Api.G_MISS_CHAR,
    attribute14                    OKL_CNSLD_AR_LINES_B.ATTRIBUTE14%TYPE := Okc_Api.G_MISS_CHAR,
    attribute15                    OKL_CNSLD_AR_LINES_B.ATTRIBUTE15%TYPE := Okc_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okc_Api.G_MISS_NUM,
    creation_date                  OKL_CNSLD_AR_LINES_B.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okc_Api.G_MISS_NUM,
    last_update_date               OKL_CNSLD_AR_LINES_B.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okc_Api.G_MISS_NUM);
  g_miss_lln_rec                          lln_rec_type;
  TYPE lln_tbl_type IS TABLE OF lln_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE okl_cnsld_ar_lines_tl_rec_type IS RECORD (
    id                             NUMBER := Okc_Api.G_MISS_NUM,
    LANGUAGE                       OKL_CNSLD_AR_LINES_TL.LANGUAGE%TYPE := Okc_Api.G_MISS_CHAR,
    source_lang                    OKL_CNSLD_AR_LINES_TL.SOURCE_LANG%TYPE := Okc_Api.G_MISS_CHAR,
    sfwt_flag                      OKL_CNSLD_AR_LINES_TL.SFWT_FLAG%TYPE := Okc_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okc_Api.G_MISS_NUM,
    creation_date                  OKL_CNSLD_AR_LINES_TL.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okc_Api.G_MISS_NUM,
    last_update_date               OKL_CNSLD_AR_LINES_TL.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okc_Api.G_MISS_NUM);
  GMissOklCnsldArLinesTlRec               okl_cnsld_ar_lines_tl_rec_type;
  TYPE okl_cnsld_ar_lines_tl_tbl_type IS TABLE OF okl_cnsld_ar_lines_tl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE llnv_rec_type IS RECORD (
    id                             NUMBER := Okc_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okc_Api.G_MISS_NUM,
    sfwt_flag                      OKL_CNSLD_AR_LINES_V.SFWT_FLAG%TYPE := Okc_Api.G_MISS_CHAR,
    khr_id                         NUMBER := Okc_Api.G_MISS_NUM,
    cnr_id                         NUMBER := Okc_Api.G_MISS_NUM,
    kle_id                         NUMBER := Okc_Api.G_MISS_NUM,
    lln_id_parent                  NUMBER := Okc_Api.G_MISS_NUM,
    ilt_id                         NUMBER := Okc_Api.G_MISS_NUM,
    sequence_number                NUMBER := Okc_Api.G_MISS_NUM,
    amount                         NUMBER := Okc_Api.G_MISS_NUM,
    tax_amount                     NUMBER := Okc_Api.G_MISS_NUM,
    attribute_category             OKL_CNSLD_AR_LINES_V.ATTRIBUTE_CATEGORY%TYPE := Okc_Api.G_MISS_CHAR,
    attribute1                     OKL_CNSLD_AR_LINES_V.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    attribute2                     OKL_CNSLD_AR_LINES_V.ATTRIBUTE2%TYPE := Okc_Api.G_MISS_CHAR,
    attribute3                     OKL_CNSLD_AR_LINES_V.ATTRIBUTE3%TYPE := Okc_Api.G_MISS_CHAR,
    attribute4                     OKL_CNSLD_AR_LINES_V.ATTRIBUTE4%TYPE := Okc_Api.G_MISS_CHAR,
    attribute5                     OKL_CNSLD_AR_LINES_V.ATTRIBUTE5%TYPE := Okc_Api.G_MISS_CHAR,
    attribute6                     OKL_CNSLD_AR_LINES_V.ATTRIBUTE6%TYPE := Okc_Api.G_MISS_CHAR,
    attribute7                     OKL_CNSLD_AR_LINES_V.ATTRIBUTE7%TYPE := Okc_Api.G_MISS_CHAR,
    attribute8                     OKL_CNSLD_AR_LINES_V.ATTRIBUTE8%TYPE := Okc_Api.G_MISS_CHAR,
    attribute9                     OKL_CNSLD_AR_LINES_V.ATTRIBUTE9%TYPE := Okc_Api.G_MISS_CHAR,
    attribute10                    OKL_CNSLD_AR_LINES_V.ATTRIBUTE10%TYPE := Okc_Api.G_MISS_CHAR,
    attribute11                    OKL_CNSLD_AR_LINES_V.ATTRIBUTE11%TYPE := Okc_Api.G_MISS_CHAR,
    attribute12                    OKL_CNSLD_AR_LINES_V.ATTRIBUTE12%TYPE := Okc_Api.G_MISS_CHAR,
    attribute13                    OKL_CNSLD_AR_LINES_V.ATTRIBUTE13%TYPE := Okc_Api.G_MISS_CHAR,
    attribute14                    OKL_CNSLD_AR_LINES_V.ATTRIBUTE14%TYPE := Okc_Api.G_MISS_CHAR,
    attribute15                    OKL_CNSLD_AR_LINES_V.ATTRIBUTE15%TYPE := Okc_Api.G_MISS_CHAR,
    line_type                      OKL_CNSLD_AR_LINES_V.LINE_TYPE%TYPE := Okc_Api.G_MISS_CHAR,
    request_id                     NUMBER := Okc_Api.G_MISS_NUM,
    program_application_id         NUMBER := Okc_Api.G_MISS_NUM,
    program_id                     NUMBER := Okc_Api.G_MISS_NUM,
    program_update_date            OKL_CNSLD_AR_LINES_V.PROGRAM_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    org_id                         NUMBER := Okc_Api.G_MISS_NUM,
    created_by                     NUMBER := Okc_Api.G_MISS_NUM,
    creation_date                  OKL_CNSLD_AR_LINES_V.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okc_Api.G_MISS_NUM,
    last_update_date               OKL_CNSLD_AR_LINES_V.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okc_Api.G_MISS_NUM);
  g_miss_llnv_rec                         llnv_rec_type;
  TYPE llnv_tbl_type IS TABLE OF llnv_rec_type
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
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := Okc_Api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := Okc_Api.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okc_Api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okc_Api.G_CHILD_TABLE_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_LLN_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okc_Api.G_APP_NAME;

/*************ADDED AFTER TAPI, Sunil T. Mathew (04/19/2001) ****************/
  --GLOBAL MESSAGES
   G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
   G_NO_PARENT_RECORD           CONSTANT   VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
   G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
   G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
   G_NOT_SAME              		CONSTANT   VARCHAR2(200) := 'OKL_CANNOT_BE_SAME';


--GLOBAL VARIABLES
  G_VIEW			CONSTANT   VARCHAR2(30) := 'OKL_CNSLD_AR_LINES_V';
  G_EXCEPTION_HALT_VALIDATION           EXCEPTION;


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
    p_llnv_rec                     IN llnv_rec_type,
    x_llnv_rec                     OUT NOCOPY llnv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_llnv_tbl                     IN llnv_tbl_type,
    x_llnv_tbl                     OUT NOCOPY llnv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_llnv_rec                     IN llnv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_llnv_tbl                     IN llnv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_llnv_rec                     IN llnv_rec_type,
    x_llnv_rec                     OUT NOCOPY llnv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_llnv_tbl                     IN llnv_tbl_type,
    x_llnv_tbl                     OUT NOCOPY llnv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_llnv_rec                     IN llnv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_llnv_tbl                     IN llnv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_llnv_rec                     IN llnv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_llnv_tbl                     IN llnv_tbl_type);

END Okl_Lln_Pvt;

 

/
