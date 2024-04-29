--------------------------------------------------------
--  DDL for Package OKC_OLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_OLE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCSOLES.pls 120.0 2005/05/30 04:14:35 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE ole_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    select_yn                      OKC_OPERATION_LINES.SELECT_YN%TYPE := OKC_API.G_MISS_CHAR,
    active_yn                      OKC_OPERATION_LINES.ACTIVE_YN%TYPE := OKC_API.G_MISS_CHAR,
    process_flag                   OKC_OPERATION_LINES.PROCESS_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    oie_id                         NUMBER := OKC_API.G_MISS_NUM,
    parent_ole_id                  NUMBER := OKC_API.G_MISS_NUM,
    subject_chr_id                 NUMBER := OKC_API.G_MISS_NUM,
    object_chr_id                  NUMBER := OKC_API.G_MISS_NUM,
    subject_cle_id                 NUMBER := OKC_API.G_MISS_NUM,
    object_cle_id                  NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_OPERATION_LINES.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_OPERATION_LINES.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    request_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_application_id         NUMBER := OKC_API.G_MISS_NUM,
    program_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_update_date            OKC_OPERATION_LINES.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    message_code                   OKC_OPERATION_LINES.MESSAGE_CODE%TYPE := OKC_API.G_MISS_CHAR);
  g_miss_ole_rec                          ole_rec_type;
  TYPE ole_tbl_type IS TABLE OF ole_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE olev_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    select_yn                      OKC_OPERATION_LINES_V.SELECT_YN%TYPE := OKC_API.G_MISS_CHAR,
    active_yn                      OKC_OPERATION_LINES_V.ACTIVE_YN%TYPE := OKC_API.G_MISS_CHAR,
    process_flag                   OKC_OPERATION_LINES_V.PROCESS_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    oie_id                         NUMBER := OKC_API.G_MISS_NUM,
    parent_ole_id                  NUMBER := OKC_API.G_MISS_NUM,
    subject_chr_id                 NUMBER := OKC_API.G_MISS_NUM,
    object_chr_id                  NUMBER := OKC_API.G_MISS_NUM,
    subject_cle_id                 NUMBER := OKC_API.G_MISS_NUM,
    object_cle_id                  NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_OPERATION_LINES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_OPERATION_LINES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    request_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_application_id         NUMBER := OKC_API.G_MISS_NUM,
    program_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_update_date            OKC_OPERATION_LINES_V.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    message_code                   OKC_OPERATION_LINES_V.MESSAGE_CODE%TYPE := OKC_API.G_MISS_CHAR);
  g_miss_olev_rec                          olev_rec_type;
  TYPE olev_tbl_type IS TABLE OF olev_rec_type
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
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_OLE_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
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
    p_olev_rec                      IN olev_rec_type,
    x_olev_rec                      OUT NOCOPY olev_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_tbl                      IN olev_tbl_type,
    x_olev_tbl                      OUT NOCOPY olev_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_rec                      IN olev_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_tbl                      IN olev_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_rec                      IN olev_rec_type,
    x_olev_rec                      OUT NOCOPY olev_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_tbl                      IN olev_tbl_type,
    x_olev_tbl                      OUT NOCOPY olev_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_rec                      IN olev_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_tbl                      IN olev_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_rec                      IN olev_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_tbl                      IN olev_tbl_type);

END OKC_OLE_PVT;

 

/
