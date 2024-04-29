--------------------------------------------------------
--  DDL for Package OKL_PTM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PTM_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSPTMS.pls 120.3 2007/01/30 14:08:42 ansethur noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE ptm_rec_type IS RECORD (
    id                             NUMBER                                       := OKL_API.G_MISS_NUM,
    org_id                         NUMBER                                       := OKL_API.G_MISS_NUM,
    ptm_code                       OKL_PROCESS_TMPLTS_B.PTM_CODE%TYPE           := OKL_API.G_MISS_CHAR,
/*  13-OCT-2006 ANSETHUR BUILD: R12 B  Start Changes           */
--  jtf_amv_item_id                NUMBER                                       := OKL_API.G_MISS_NUM,
    jtf_amv_item_id                NUMBER                                       := -1,
/*      END Changes */
    start_date                     OKL_PROCESS_TMPLTS_B.START_DATE%TYPE         := OKL_API.G_MISS_DATE,
    end_date                       OKL_PROCESS_TMPLTS_B.END_DATE%TYPE           := OKL_API.G_MISS_DATE,
    object_version_number          NUMBER                                       := OKL_API.G_MISS_NUM,
    attribute_category             OKL_PROCESS_TMPLTS_B.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR,
    attribute1                     OKL_PROCESS_TMPLTS_B.ATTRIBUTE1%TYPE         := OKL_API.G_MISS_CHAR,
    attribute2                     OKL_PROCESS_TMPLTS_B.ATTRIBUTE2%TYPE         := OKL_API.G_MISS_CHAR,
    attribute3                     OKL_PROCESS_TMPLTS_B.ATTRIBUTE3%TYPE         := OKL_API.G_MISS_CHAR,
    attribute4                     OKL_PROCESS_TMPLTS_B.ATTRIBUTE4%TYPE         := OKL_API.G_MISS_CHAR,
    attribute5                     OKL_PROCESS_TMPLTS_B.ATTRIBUTE5%TYPE         := OKL_API.G_MISS_CHAR,
    attribute6                     OKL_PROCESS_TMPLTS_B.ATTRIBUTE6%TYPE         := OKL_API.G_MISS_CHAR,
    attribute7                     OKL_PROCESS_TMPLTS_B.ATTRIBUTE7%TYPE         := OKL_API.G_MISS_CHAR,
    attribute8                     OKL_PROCESS_TMPLTS_B.ATTRIBUTE8%TYPE         := OKL_API.G_MISS_CHAR,
    attribute9                     OKL_PROCESS_TMPLTS_B.ATTRIBUTE9%TYPE         := OKL_API.G_MISS_CHAR,
    attribute10                    OKL_PROCESS_TMPLTS_B.ATTRIBUTE10%TYPE        := OKL_API.G_MISS_CHAR,
    attribute11                    OKL_PROCESS_TMPLTS_B.ATTRIBUTE11%TYPE        := OKL_API.G_MISS_CHAR,
    attribute12                    OKL_PROCESS_TMPLTS_B.ATTRIBUTE12%TYPE        := OKL_API.G_MISS_CHAR,
    attribute13                    OKL_PROCESS_TMPLTS_B.ATTRIBUTE13%TYPE        := OKL_API.G_MISS_CHAR,
    attribute14                    OKL_PROCESS_TMPLTS_B.ATTRIBUTE14%TYPE        := OKL_API.G_MISS_CHAR,
    attribute15                    OKL_PROCESS_TMPLTS_B.ATTRIBUTE15%TYPE        := OKL_API.G_MISS_CHAR,
    created_by                     NUMBER                                       := OKL_API.G_MISS_NUM,
    creation_date                  OKL_PROCESS_TMPLTS_B.CREATION_DATE%TYPE      := OKL_API.G_MISS_DATE,
    last_updated_by                NUMBER                                       := OKL_API.G_MISS_NUM,
    last_update_date               OKL_PROCESS_TMPLTS_B.LAST_UPDATE_DATE%TYPE   := OKL_API.G_MISS_DATE,
    last_update_login              NUMBER                                       := OKL_API.G_MISS_NUM,
/*  13-OCT-2006 ANSETHUR BUILD: R12 B  Start Changes           */
    recipient_type_code            OKL_PROCESS_TMPLTS_B.RECIPIENT_TYPE_CODE%TYPE  :=OKL_API.G_MISS_CHAR,
    xml_tmplt_code                 OKL_PROCESS_TMPLTS_B.XML_TMPLT_CODE%TYPE       :=OKL_API.G_MISS_CHAR);
/*      End Changes   : R12 B   */
  g_miss_ptm_rec                   ptm_rec_type;

  TYPE ptm_tbl_type IS TABLE OF ptm_rec_type
        INDEX BY BINARY_INTEGER;

  TYPE okl_process_tmplts_tl_rec_type IS RECORD (
    id                             NUMBER                                        := OKL_API.G_MISS_NUM,
    language                       OKL_PROCESS_TMPLTS_TL.LANGUAGE%TYPE           := OKL_API.G_MISS_CHAR,
    source_lang                    OKL_PROCESS_TMPLTS_TL.SOURCE_LANG%TYPE        := OKL_API.G_MISS_CHAR,
    sfwt_flag                      OKL_PROCESS_TMPLTS_TL.SFWT_FLAG%TYPE          := OKL_API.G_MISS_CHAR,
    email_subject_line             OKL_PROCESS_TMPLTS_TL.EMAIL_SUBJECT_LINE%TYPE := OKL_API.G_MISS_CHAR,
    created_by                     NUMBER                                        := OKL_API.G_MISS_NUM,
    creation_date                  OKL_PROCESS_TMPLTS_TL.CREATION_DATE%TYPE      := OKL_API.G_MISS_DATE,
    last_updated_by                NUMBER                                        := OKL_API.G_MISS_NUM,
    last_update_date               OKL_PROCESS_TMPLTS_TL.LAST_UPDATE_DATE%TYPE   := OKL_API.G_MISS_DATE,
    last_update_login              NUMBER                                        := OKL_API.G_MISS_NUM);

  GMissOklProcessTmpltsTlRec              okl_process_tmplts_tl_rec_type;

  TYPE okl_process_tmplts_tl_tbl_type IS TABLE OF okl_process_tmplts_tl_rec_type
        INDEX BY BINARY_INTEGER;


  TYPE ptmv_rec_type IS RECORD (
    id                             NUMBER                                        := OKL_API.G_MISS_NUM,
    org_id                         NUMBER                                        := OKL_API.G_MISS_NUM,
    ptm_code                       OKL_PROCESS_TMPLTS_B.PTM_CODE%TYPE            := OKL_API.G_MISS_CHAR,
/*  13-OCT-2006 ANSETHUR BUILD: R12 B  Start Changes           */
--  jtf_amv_item_id                NUMBER                                        := OKL_API.G_MISS_NUM,
    jtf_amv_item_id                NUMBER                                        := -1,
/*      End Changes   : R12 B   */
    sfwt_flag                      OKL_PROCESS_TMPLTS_V.SFWT_FLAG%TYPE           := OKL_API.G_MISS_CHAR,
    email_subject_line             OKL_PROCESS_TMPLTS_V.EMAIL_SUBJECT_LINE%TYPE  := OKL_API.G_MISS_CHAR,
    start_date                     OKL_PROCESS_TMPLTS_B.START_DATE%TYPE          := OKL_API.G_MISS_DATE,
    end_date                       OKL_PROCESS_TMPLTS_B.END_DATE%TYPE            := OKL_API.G_MISS_DATE,
    object_version_number          NUMBER                                        := OKL_API.G_MISS_NUM,
    attribute_category             OKL_PROCESS_TMPLTS_V.ATTRIBUTE_CATEGORY%TYPE  := OKL_API.G_MISS_CHAR,
    attribute1                     OKL_PROCESS_TMPLTS_V.ATTRIBUTE1%TYPE          := OKL_API.G_MISS_CHAR,
    attribute2                     OKL_PROCESS_TMPLTS_V.ATTRIBUTE2%TYPE          := OKL_API.G_MISS_CHAR,
    attribute3                     OKL_PROCESS_TMPLTS_V.ATTRIBUTE3%TYPE          := OKL_API.G_MISS_CHAR,
    attribute4                     OKL_PROCESS_TMPLTS_V.ATTRIBUTE4%TYPE          := OKL_API.G_MISS_CHAR,
    attribute5                     OKL_PROCESS_TMPLTS_V.ATTRIBUTE5%TYPE          := OKL_API.G_MISS_CHAR,
    attribute6                     OKL_PROCESS_TMPLTS_V.ATTRIBUTE6%TYPE          := OKL_API.G_MISS_CHAR,
    attribute7                     OKL_PROCESS_TMPLTS_V.ATTRIBUTE7%TYPE          := OKL_API.G_MISS_CHAR,
    attribute8                     OKL_PROCESS_TMPLTS_V.ATTRIBUTE8%TYPE          := OKL_API.G_MISS_CHAR,
    attribute9                     OKL_PROCESS_TMPLTS_V.ATTRIBUTE9%TYPE          := OKL_API.G_MISS_CHAR,
    attribute10                    OKL_PROCESS_TMPLTS_V.ATTRIBUTE10%TYPE         := OKL_API.G_MISS_CHAR,
    attribute11                    OKL_PROCESS_TMPLTS_V.ATTRIBUTE11%TYPE         := OKL_API.G_MISS_CHAR,
    attribute12                    OKL_PROCESS_TMPLTS_V.ATTRIBUTE12%TYPE         := OKL_API.G_MISS_CHAR,
    attribute13                    OKL_PROCESS_TMPLTS_V.ATTRIBUTE13%TYPE         := OKL_API.G_MISS_CHAR,
    attribute14                    OKL_PROCESS_TMPLTS_V.ATTRIBUTE14%TYPE         := OKL_API.G_MISS_CHAR,
    attribute15                    OKL_PROCESS_TMPLTS_V.ATTRIBUTE15%TYPE         := OKL_API.G_MISS_CHAR,
    created_by                     NUMBER                                        := OKL_API.G_MISS_NUM,
    creation_date                  OKL_PROCESS_TMPLTS_V.CREATION_DATE%TYPE       := OKL_API.G_MISS_DATE,
    last_updated_by                NUMBER                                        := OKL_API.G_MISS_NUM,
    last_update_date               OKL_PROCESS_TMPLTS_V.LAST_UPDATE_DATE%TYPE    := OKL_API.G_MISS_DATE,
    last_update_login              NUMBER                                        := OKL_API.G_MISS_NUM,
/*  13-OCT-2006 ANSETHUR BUILD: R12 B  Start Changes           */
    recipient_type_code            OKL_PROCESS_TMPLTS_V.RECIPIENT_TYPE_CODE%TYPE  :=OKL_API.G_MISS_CHAR,
    xml_tmplt_code                 OKL_PROCESS_TMPLTS_V.XML_TMPLT_CODE%TYPE       :=OKL_API.G_MISS_CHAR);
/*      End Changes   : R12 B   */

  g_miss_ptmv_rec                  ptmv_rec_type;

  TYPE ptmv_tbl_type IS TABLE OF ptmv_rec_type
        INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                         CONSTANT VARCHAR2(200) := OKL_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC      CONSTANT VARCHAR2(200) := OKL_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED             CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKL_API.G_RECORD_LOGICALLY_DELETED;
--  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
--  OKL_API bug (points to OKL_CONTRACTS_REQUIRED_VALUE instead of OKL_REQUIRED_VALUE)

  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := 'OKL_REQUIRED_VALUE';

  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS - Post TAPI generation
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR   CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_NO_PARENT_RECORD CONSTANT VARCHAR2(200)  := 'OKC_NO_PARENT_RECORD';
  G_SQLERRM_TOKEN CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN CONSTANT VARCHAR2(200) := 'SQLCODE';
  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS - Post TAPI generation
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION EXCEPTION;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'Okl_Ptm_Pvt';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
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
    p_ptmv_rec                     IN ptmv_rec_type,
    x_ptmv_rec                     OUT NOCOPY ptmv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptmv_tbl                     IN ptmv_tbl_type,
    x_ptmv_tbl                     OUT NOCOPY ptmv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptmv_rec                     IN ptmv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptmv_tbl                     IN ptmv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptmv_rec                     IN ptmv_rec_type,
    x_ptmv_rec                     OUT NOCOPY ptmv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptmv_tbl                     IN ptmv_tbl_type,
    x_ptmv_tbl                     OUT NOCOPY ptmv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptmv_rec                     IN ptmv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptmv_tbl                     IN ptmv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptmv_rec                     IN ptmv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptmv_tbl                     IN ptmv_tbl_type);

END Okl_Ptm_Pvt;


/
