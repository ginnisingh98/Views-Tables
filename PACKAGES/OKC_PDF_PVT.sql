--------------------------------------------------------
--  DDL for Package OKC_PDF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_PDF_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCSPDFS.pls 120.0 2005/06/01 22:56:14 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE okc_process_defs_tl_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    language                       OKC_PROCESS_DEFS_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR,
    source_lang                    OKC_PROCESS_DEFS_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR,
    sfwt_flag                      OKC_PROCESS_DEFS_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    name                           OKC_PROCESS_DEFS_TL.NAME%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKC_PROCESS_DEFS_TL.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    short_description              OKC_PROCESS_DEFS_TL.SHORT_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    comments                       OKC_PROCESS_DEFS_TL.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_PROCESS_DEFS_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_PROCESS_DEFS_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_okc_process_defs_tl_rec          okc_process_defs_tl_rec_type;
  TYPE okc_process_defs_tl_tbl_type IS TABLE OF okc_process_defs_tl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE pdf_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    pdf_type                       OKC_PROCESS_DEFS_B.PDF_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    usage                          OKC_PROCESS_DEFS_B.USAGE%TYPE := OKC_API.G_MISS_CHAR,
    creation_date                  OKC_PROCESS_DEFS_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    begin_date                     OKC_PROCESS_DEFS_B.BEGIN_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_PROCESS_DEFS_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    wf_name                        OKC_PROCESS_DEFS_B.WF_NAME%TYPE := OKC_API.G_MISS_CHAR,
    wf_process_name                OKC_PROCESS_DEFS_B.WF_PROCESS_NAME%TYPE := OKC_API.G_MISS_CHAR,
    procedure_name                 OKC_PROCESS_DEFS_B.PROCEDURE_NAME%TYPE := OKC_API.G_MISS_CHAR,
    package_name                   OKC_PROCESS_DEFS_B.PACKAGE_NAME%TYPE := OKC_API.G_MISS_CHAR,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    end_date                       OKC_PROCESS_DEFS_B.END_DATE%TYPE := OKC_API.G_MISS_DATE,
    attribute_category             OKC_PROCESS_DEFS_B.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_PROCESS_DEFS_B.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_PROCESS_DEFS_B.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_PROCESS_DEFS_B.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_PROCESS_DEFS_B.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_PROCESS_DEFS_B.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_PROCESS_DEFS_B.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_PROCESS_DEFS_B.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_PROCESS_DEFS_B.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_PROCESS_DEFS_B.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_PROCESS_DEFS_B.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_PROCESS_DEFS_B.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_PROCESS_DEFS_B.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_PROCESS_DEFS_B.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_PROCESS_DEFS_B.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_PROCESS_DEFS_B.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    application_id                 NUMBER := OKC_API.G_MISS_NUM,
    seeded_flag                    OKC_PROCESS_DEFS_B.SEEDED_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    message_name                   OKC_PROCESS_DEFS_B.MESSAGE_NAME%TYPE := OKC_API.G_MISS_CHAR,
    script_name                    OKC_PROCESS_DEFS_B.SCRIPT_NAME%TYPE := OKC_API.G_MISS_CHAR);
  g_miss_pdf_rec                          pdf_rec_type;
  TYPE pdf_tbl_type IS TABLE OF pdf_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE pdfv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    sfwt_flag                      OKC_PROCESS_DEFS_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKC_PROCESS_DEFS_V.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    short_description              OKC_PROCESS_DEFS_V.SHORT_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    comments                       OKC_PROCESS_DEFS_V.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    usage                          OKC_PROCESS_DEFS_V.USAGE%TYPE := OKC_API.G_MISS_CHAR,
    name                           OKC_PROCESS_DEFS_V.NAME%TYPE := OKC_API.G_MISS_CHAR,
    wf_name                        OKC_PROCESS_DEFS_V.WF_NAME%TYPE := OKC_API.G_MISS_CHAR,
    wf_process_name                OKC_PROCESS_DEFS_V.WF_PROCESS_NAME%TYPE := OKC_API.G_MISS_CHAR,
    procedure_name                 OKC_PROCESS_DEFS_V.PROCEDURE_NAME%TYPE := OKC_API.G_MISS_CHAR,
    package_name                   OKC_PROCESS_DEFS_V.PACKAGE_NAME%TYPE := OKC_API.G_MISS_CHAR,
    pdf_type                       OKC_PROCESS_DEFS_V.PDF_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    application_id                 NUMBER := OKC_API.G_MISS_NUM,
    seeded_flag                    OKC_PROCESS_DEFS_V.SEEDED_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category             OKC_PROCESS_DEFS_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_PROCESS_DEFS_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_PROCESS_DEFS_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_PROCESS_DEFS_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_PROCESS_DEFS_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_PROCESS_DEFS_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_PROCESS_DEFS_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_PROCESS_DEFS_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_PROCESS_DEFS_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_PROCESS_DEFS_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_PROCESS_DEFS_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_PROCESS_DEFS_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_PROCESS_DEFS_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_PROCESS_DEFS_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_PROCESS_DEFS_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_PROCESS_DEFS_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    begin_date                     OKC_PROCESS_DEFS_V.BEGIN_DATE%TYPE := OKC_API.G_MISS_DATE,
    end_date                       OKC_PROCESS_DEFS_V.END_DATE%TYPE := OKC_API.G_MISS_DATE,
    creation_date                  OKC_PROCESS_DEFS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_PROCESS_DEFS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    message_name                   OKC_PROCESS_DEFS_V.MESSAGE_NAME%TYPE := OKC_API.G_MISS_CHAR,
    script_name                    OKC_PROCESS_DEFS_V.SCRIPT_NAME%TYPE := OKC_API.G_MISS_CHAR);
  g_miss_pdfv_rec                         pdfv_rec_type;
  TYPE pdfv_tbl_type IS TABLE OF pdfv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                     CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC  CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED         CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED         CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED    CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE              CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE                       CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN              CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_COL_NAME_TOKEN1             CONSTANT VARCHAR2(200) := 'COL_NAME1';
  G_COL_NAME_TOKEN2             CONSTANT VARCHAR2(200) := 'COL_NAME2';
  G_PARENT_TABLE_TOKEN          CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN           CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'SQLcode';
  G_UPPERCASE_REQUIRED          CONSTANT VARCHAR2(200) := 'OKC_UPPERCASE_REQUIRED';
  --G_UNQS              CONSTANT VARCHAR2(200) := 'OKC_VALUES_NOT_UNIQUE';
  G_UNQS1               CONSTANT VARCHAR2(200) := 'OKC_PKG_PROC_NOT_UNIQUE';
  G_UNQS2               CONSTANT VARCHAR2(200) := 'OKC_WF_NAME_PROCESS_NOT_UNIQUE';
  G_ARC_VIOLATED                CONSTANT VARCHAR2(200) := 'OKC_ARC_VIOLATED';
  G_ARC_MANDATORY               CONSTANT VARCHAR2(200) := 'OKC_ARC_MANDATORY';
  G_INVALID_END_DATE            CONSTANT VARCHAR2(200) := 'OKC_INVALID_END_DATE';
  G_COL_NAME1           CONSTANT VARCHAR2(200) := 'OKC_COL_NAME1';
  G_COL_NAME2           CONSTANT VARCHAR2(200) := 'OKC_COL_NAME2';
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                    CONSTANT VARCHAR2(200) := 'OKC_PDF_PVT';
  G_APP_NAME                    CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_VIEW                        CONSTANT VARCHAR2(200)   :=  'OKC_PROCESS_DEFS_V';
  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

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
    p_pdfv_rec                     IN pdfv_rec_type,
    x_pdfv_rec                     OUT NOCOPY pdfv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdfv_tbl                     IN pdfv_tbl_type,
    x_pdfv_tbl                     OUT NOCOPY pdfv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdfv_rec                     IN pdfv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdfv_tbl                     IN pdfv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdfv_rec                     IN pdfv_rec_type,
    x_pdfv_rec                     OUT NOCOPY pdfv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdfv_tbl                     IN pdfv_tbl_type,
    x_pdfv_tbl                     OUT NOCOPY pdfv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdfv_rec                     IN pdfv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdfv_tbl                     IN pdfv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdfv_rec                     IN pdfv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdfv_tbl                     IN pdfv_tbl_type);

END OKC_PDF_PVT;

 

/
