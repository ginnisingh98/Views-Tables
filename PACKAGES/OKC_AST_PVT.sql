--------------------------------------------------------
--  DDL for Package OKC_AST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_AST_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCSASTS.pls 120.0 2005/05/25 23:08:34 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE ast_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    sts_code                       OKC_ASSENTS.STS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    opn_code                       OKC_ASSENTS.OPN_CODE%TYPE := OKC_API.G_MISS_CHAR,
    ste_code                       OKC_ASSENTS.STE_CODE%TYPE := OKC_API.G_MISS_CHAR,
    scs_code                       OKC_ASSENTS.SCS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    allowed_yn                     OKC_ASSENTS.ALLOWED_YN%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_ASSENTS.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_ASSENTS.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    attribute_category             OKC_ASSENTS.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_ASSENTS.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_ASSENTS.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_ASSENTS.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_ASSENTS.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_ASSENTS.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_ASSENTS.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_ASSENTS.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_ASSENTS.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_ASSENTS.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_ASSENTS.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_ASSENTS.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_ASSENTS.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_ASSENTS.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_ASSENTS.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_ASSENTS.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR);
  g_miss_ast_rec                          ast_rec_type;
  TYPE ast_tbl_type IS TABLE OF ast_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE astv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    sts_code                       OKC_ASSENTS_V.STS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    opn_code                       OKC_ASSENTS_V.OPN_CODE%TYPE := OKC_API.G_MISS_CHAR,
    ste_code                       OKC_ASSENTS_V.STE_CODE%TYPE := OKC_API.G_MISS_CHAR,
    scs_code                       OKC_ASSENTS_V.SCS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    allowed_yn                     OKC_ASSENTS_V.ALLOWED_YN%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category             OKC_ASSENTS_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_ASSENTS_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_ASSENTS_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_ASSENTS_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_ASSENTS_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_ASSENTS_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_ASSENTS_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_ASSENTS_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_ASSENTS_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_ASSENTS_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_ASSENTS_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_ASSENTS_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_ASSENTS_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_ASSENTS_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_ASSENTS_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_ASSENTS_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_ASSENTS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_ASSENTS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_astv_rec                         astv_rec_type;
  TYPE astv_tbl_type IS TABLE OF astv_rec_type
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
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'SQLCODE';
  G_UPPERCASE_REQUIRED		CONSTANT VARCHAR2(200) := 'OKC_UPPER_CASE_REQUIRED';

  ------------------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_AST_PVT';
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
    p_astv_rec                     IN astv_rec_type,
    x_astv_rec                     OUT NOCOPY astv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_astv_tbl                     IN astv_tbl_type,
    x_astv_tbl                     OUT NOCOPY astv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_astv_rec                     IN astv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_astv_tbl                     IN astv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_astv_rec                     IN astv_rec_type,
    x_astv_rec                     OUT NOCOPY astv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_astv_tbl                     IN astv_tbl_type,
    x_astv_tbl                     OUT NOCOPY astv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_astv_rec                     IN astv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_astv_tbl                     IN astv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_astv_rec                     IN astv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_astv_tbl                     IN astv_tbl_type);

  FUNCTION header_operation_allowed(
    p_header_id                    IN NUMBER,
    p_opn_code                     IN VARCHAR2,
    p_crt_id                       IN NUMBER DEFAULT NULL) return varchar2;

  FUNCTION line_operation_allowed(
    p_line_id                      IN NUMBER,
    p_opn_code                     IN VARCHAR2) return varchar2;

END OKC_AST_PVT;

 

/
