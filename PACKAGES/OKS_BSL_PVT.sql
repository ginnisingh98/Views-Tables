--------------------------------------------------------
--  DDL for Package OKS_BSL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_BSL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSSBSLS.pls 120.1 2006/09/19 18:56:12 hvaladip noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE bsl_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    bcl_id                         NUMBER := OKC_API.G_MISS_NUM,
    cle_id                         NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKS_BILL_SUB_LINES.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKS_BILL_SUB_LINES.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    average                        NUMBER := OKC_API.G_MISS_NUM,
    amount                         NUMBER := OKC_API.G_MISS_NUM,
    manual_credit                  NUMBER := OKC_API.G_MISS_NUM,
    date_billed_from               OKS_BILL_SUB_LINES.DATE_BILLED_FROM%TYPE := OKC_API.G_MISS_DATE,
    date_billed_to                 OKS_BILL_SUB_LINES.DATE_BILLED_TO%TYPE := OKC_API.G_MISS_DATE,
    date_to_interface	           OKS_BILL_SUB_LINES.DATE_TO_INTERFACE%TYPE   := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    attribute_category             OKS_BILL_SUB_LINES.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKS_BILL_SUB_LINES.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKS_BILL_SUB_LINES.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKS_BILL_SUB_LINES.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKS_BILL_SUB_LINES.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKS_BILL_SUB_LINES.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKS_BILL_SUB_LINES.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKS_BILL_SUB_LINES.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKS_BILL_SUB_LINES.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKS_BILL_SUB_LINES.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKS_BILL_SUB_LINES.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKS_BILL_SUB_LINES.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKS_BILL_SUB_LINES.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKS_BILL_SUB_LINES.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKS_BILL_SUB_LINES.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKS_BILL_SUB_LINES.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR);
  g_miss_bsl_rec                          bsl_rec_type;
  TYPE bsl_tbl_type IS TABLE OF bsl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE bslv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    bcl_id                         NUMBER := OKC_API.G_MISS_NUM,
    cle_id                         NUMBER := OKC_API.G_MISS_NUM,
    average                        NUMBER := OKC_API.G_MISS_NUM,
    amount                         NUMBER := OKC_API.G_MISS_NUM,
    manual_credit                  NUMBER := OKC_API.G_MISS_NUM,
    date_billed_from               OKS_BILL_SUB_LINES_V.DATE_BILLED_FROM%TYPE := OKC_API.G_MISS_DATE,
    date_billed_to                 OKS_BILL_SUB_LINES_V.DATE_BILLED_TO%TYPE := OKC_API.G_MISS_DATE,
    date_to_interface              OKS_BILL_SUB_LINES_V.DATE_TO_INTERFACE%TYPE := OKC_API.G_MISS_DATE,
    attribute_category             OKS_BILL_SUB_LINES_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKS_BILL_SUB_LINES_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKS_BILL_SUB_LINES_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKS_BILL_SUB_LINES_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKS_BILL_SUB_LINES_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKS_BILL_SUB_LINES_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKS_BILL_SUB_LINES_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKS_BILL_SUB_LINES_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKS_BILL_SUB_LINES_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKS_BILL_SUB_LINES_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKS_BILL_SUB_LINES_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKS_BILL_SUB_LINES_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKS_BILL_SUB_LINES_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKS_BILL_SUB_LINES_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKS_BILL_SUB_LINES_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKS_BILL_SUB_LINES_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKS_BILL_SUB_LINES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKS_BILL_SUB_LINES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_bslv_rec                         bslv_rec_type;
  TYPE bslv_tbl_type IS TABLE OF bslv_rec_type
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
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKS_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN              CONSTANT VARCHAR2(200) := 'SQLcode';
  G_SQLERRM_TOKEN              CONSTANT VARCHAR2(200) := 'SQLerrm';
  ---------------------------------------------------------------------------
	   -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
   G_EXCEPTION_HALT_VALIDATION 	EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKS_BSL_PVT';
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
    p_bslv_rec                     IN bslv_rec_type,
    x_bslv_rec                     OUT NOCOPY bslv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bslv_tbl                     IN bslv_tbl_type,
    x_bslv_tbl                     OUT NOCOPY bslv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bslv_rec                     IN bslv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bslv_tbl                     IN bslv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bslv_rec                     IN bslv_rec_type,
    x_bslv_rec                     OUT NOCOPY bslv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bslv_tbl                     IN bslv_tbl_type,
    x_bslv_tbl                     OUT NOCOPY bslv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bslv_rec                     IN bslv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bslv_tbl                     IN bslv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bslv_rec                     IN bslv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bslv_tbl                     IN bslv_tbl_type);

END OKS_BSL_PVT;

 

/
