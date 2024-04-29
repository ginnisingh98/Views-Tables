--------------------------------------------------------
--  DDL for Package OKC_LSQ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_LSQ_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCSLSQS.pls 120.0 2005/05/25 19:13:46 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE lsq_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    line_code                      OKC_K_SEQ_LINES.LINE_CODE%TYPE := OKC_API.G_MISS_CHAR,
    doc_sequence_id                NUMBER := OKC_API.G_MISS_NUM,
    business_group_id              NUMBER := OKC_API.G_MISS_NUM,
    operating_unit_id              NUMBER := OKC_API.G_MISS_NUM,
    cls_code                       OKC_K_SEQ_LINES.CLS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    scs_code                       OKC_K_SEQ_LINES.SCS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    contract_number_prefix         OKC_K_SEQ_LINES.CONTRACT_NUMBER_PREFIX%TYPE := OKC_API.G_MISS_CHAR,
    contract_number_suffix         OKC_K_SEQ_LINES.CONTRACT_NUMBER_SUFFIX%TYPE := OKC_API.G_MISS_CHAR,
    number_format_length           NUMBER := OKC_API.G_MISS_NUM,
    start_seq_no                   NUMBER := OKC_API.G_MISS_NUM,
    end_seq_no                     NUMBER := OKC_API.G_MISS_NUM,
    manual_override_yn             OKC_K_SEQ_LINES.MANUAL_OVERRIDE_YN%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_K_SEQ_LINES.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_K_SEQ_LINES.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_lsq_rec                   lsq_rec_type;
  TYPE lsq_tbl_type IS TABLE OF lsq_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE lsqv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    line_code                      OKC_K_SEQ_LINES_V.LINE_CODE%TYPE := OKC_API.G_MISS_CHAR,
    doc_sequence_id                NUMBER := OKC_API.G_MISS_NUM,
    business_group_id              NUMBER := OKC_API.G_MISS_NUM,
    operating_unit_id              NUMBER := OKC_API.G_MISS_NUM,
    cls_code                       OKC_K_SEQ_LINES_V.CLS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    scs_code                       OKC_K_SEQ_LINES_V.SCS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    contract_number_prefix         OKC_K_SEQ_LINES_V.CONTRACT_NUMBER_PREFIX%TYPE := OKC_API.G_MISS_CHAR,
    contract_number_suffix         OKC_K_SEQ_LINES_V.CONTRACT_NUMBER_SUFFIX%TYPE := OKC_API.G_MISS_CHAR,
    number_format_length           NUMBER := OKC_API.G_MISS_NUM,
    start_seq_no                   NUMBER := OKC_API.G_MISS_NUM,
    end_seq_no                     NUMBER := OKC_API.G_MISS_NUM,
    manual_override_yn             OKC_K_SEQ_LINES_V.MANUAL_OVERRIDE_YN%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_K_SEQ_LINES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_K_SEQ_LINES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_lsqv_rec                  lsqv_rec_type;
  TYPE lsqv_tbl_type IS TABLE OF lsqv_rec_type
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
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_LSQ_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_EXCEPTION_HALT_VALIDATION	exception;
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
    p_lsqv_rec                     IN lsqv_rec_type,
    x_lsqv_rec                     OUT NOCOPY lsqv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_tbl                     IN lsqv_tbl_type,
    x_lsqv_tbl                     OUT NOCOPY lsqv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_rec                     IN lsqv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_tbl                     IN lsqv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_rec                     IN lsqv_rec_type,
    x_lsqv_rec                     OUT NOCOPY lsqv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_tbl                     IN lsqv_tbl_type,
    x_lsqv_tbl                     OUT NOCOPY lsqv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_rec                     IN lsqv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_tbl                     IN lsqv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_rec                     IN lsqv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_tbl                     IN lsqv_tbl_type);

END OKC_LSQ_PVT;

 

/
