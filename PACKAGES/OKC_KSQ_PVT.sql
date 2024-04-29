--------------------------------------------------------
--  DDL for Package OKC_KSQ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_KSQ_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCSKSQS.pls 120.0 2005/05/25 22:35:00 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE ksq_rec_type IS RECORD (
    line_code                      OKC_K_SEQ_HEADER.LINE_CODE%TYPE := OKC_API.G_MISS_CHAR,
    site_yn                        OKC_K_SEQ_HEADER.SITE_YN%TYPE := OKC_API.G_MISS_CHAR,
    bg_ou_none                     OKC_K_SEQ_HEADER.BG_OU_NONE%TYPE := OKC_API.G_MISS_CHAR,
    cls_scs_none                   OKC_K_SEQ_HEADER.CLS_SCS_NONE%TYPE := OKC_API.G_MISS_CHAR,
    user_function_yn               OKC_K_SEQ_HEADER.USER_FUNCTION_YN%TYPE := OKC_API.G_MISS_CHAR,
    manual_override_yn             OKC_K_SEQ_HEADER.MANUAL_OVERRIDE_YN%TYPE := OKC_API.G_MISS_CHAR,
    pdf_id                         NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_K_SEQ_HEADER.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_K_SEQ_HEADER.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_ksq_rec                   ksq_rec_type;
  TYPE ksq_tbl_type IS TABLE OF ksq_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE ksqv_rec_type IS RECORD (
    line_code                      OKC_K_SEQ_HEADER_V.LINE_CODE%TYPE := OKC_API.G_MISS_CHAR,
    site_yn                        OKC_K_SEQ_HEADER_V.SITE_YN%TYPE := OKC_API.G_MISS_CHAR,
    bg_ou_none                     OKC_K_SEQ_HEADER_V.BG_OU_NONE%TYPE := OKC_API.G_MISS_CHAR,
    cls_scs_none                   OKC_K_SEQ_HEADER_V.CLS_SCS_NONE%TYPE := OKC_API.G_MISS_CHAR,
    user_function_yn               OKC_K_SEQ_HEADER_V.USER_FUNCTION_YN%TYPE := OKC_API.G_MISS_CHAR,
    manual_override_yn             OKC_K_SEQ_HEADER_V.MANUAL_OVERRIDE_YN%TYPE := OKC_API.G_MISS_CHAR,
    pdf_id                         NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_K_SEQ_HEADER_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_K_SEQ_HEADER_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_ksqv_rec                  ksqv_rec_type;
  TYPE ksqv_tbl_type IS TABLE OF ksqv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_NO_PARENT_RECORD CONSTANT	VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR CONSTANT	VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN	 CONSTANT	VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN	 CONSTANT	VARCHAR2(200) := 'SQLcode';
  G_FND_APP			       CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC  CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED	  	  CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		  CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	  CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		       CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE			  CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		       CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		  CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		  CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_KSQ_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_EXCEPTION_HALT_VALIDATION	exception;
  G_SETUP_FOUND                 CONSTANT VARCHAR2(30) := 'OKC_SEQ_SETUP_FOUND';
  G_NO_SETUP_FOUND              CONSTANT VARCHAR2(30) := 'OKC_SEQ_NO_SETUP_FOUND';
  G_NO_PDF_FOUND                CONSTANT VARCHAR2(30) := 'OKC_SEQ_NO_PDF_FOUND';
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_rec                     IN ksqv_rec_type,
    x_ksqv_rec                     OUT NOCOPY ksqv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_tbl                     IN ksqv_tbl_type,
    x_ksqv_tbl                     OUT NOCOPY ksqv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_rec                     IN ksqv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_tbl                     IN ksqv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_rec                     IN ksqv_rec_type,
    x_ksqv_rec                     OUT NOCOPY ksqv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_tbl                     IN ksqv_tbl_type,
    x_ksqv_tbl                     OUT NOCOPY ksqv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_rec                     IN ksqv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_tbl                     IN ksqv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_rec                     IN ksqv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_tbl                     IN ksqv_tbl_type);

  PROCEDURE Is_K_Autogenerated(
    p_scs_code Varchar2,
    x_return_status OUT NOCOPY Varchar2);

  PROCEDURE Get_K_Number(
    p_scs_code                     IN VARCHAR2,
    p_contract_number_modifier     IN VARCHAR2,
    x_contract_number              OUT NOCOPY VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2);

END OKC_KSQ_PVT;

 

/
