--------------------------------------------------------
--  DDL for Package OKS_BTL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_BTL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSSBTLS.pls 120.1 2006/09/19 19:00:37 hvaladip noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE btl_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    btn_id                         NUMBER := OKC_API.G_MISS_NUM,
    bsl_id                         NUMBER := OKC_API.G_MISS_NUM,
    bcl_id                         NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKS_BILL_TXN_LINES.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    trx_number                     OKS_BILL_TXN_LINES.trx_number%type := OKC_API.G_MISS_CHAR,
    trx_date                       OKS_BILL_TXN_LINES.trx_date%type := OKC_API.G_MISS_DATE,
    trx_class                      OKS_BILL_TXN_LINES.trx_class%type := OKC_API.G_MISS_CHAR,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKS_BILL_TXN_LINES.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    bill_instance_number           NUMBER := OKC_API.G_MISS_NUM,
    trx_line_amount                OKS_BILL_TXN_LINES.TRX_LINE_AMOUNT%TYPE := OKC_API.G_MISS_CHAR,
    trx_line_tax_amount            NUMBER := OKC_API.G_MISS_NUM,
    trx_amount                     NUMBER := OKC_API.G_MISS_NUM,
    manual_credit                  NUMBER := OKC_API.G_MISS_NUM,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    attribute_category             OKS_BILL_TXN_LINES.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKS_BILL_TXN_LINES.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKS_BILL_TXN_LINES.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKS_BILL_TXN_LINES.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKS_BILL_TXN_LINES.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKS_BILL_TXN_LINES.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKS_BILL_TXN_LINES.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKS_BILL_TXN_LINES.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKS_BILL_TXN_LINES.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKS_BILL_TXN_LINES.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKS_BILL_TXN_LINES.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKS_BILL_TXN_LINES.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKS_BILL_TXN_LINES.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKS_BILL_TXN_LINES.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKS_BILL_TXN_LINES.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKS_BILL_TXN_LINES.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    split_flag                     OKS_BILL_TXN_LINES.SPLIT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    cycle_refrence                 OKS_BILL_TXN_LINES.CYCLE_REFRENCE%TYPE := OKC_API.G_MISS_CHAR);

  g_miss_btl_rec                          btl_rec_type;
  TYPE btl_tbl_type IS TABLE OF btl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE btlv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    btn_id                         NUMBER := OKC_API.G_MISS_NUM,
    bsl_id                         NUMBER := OKC_API.G_MISS_NUM,
    bcl_id                         NUMBER := OKC_API.G_MISS_NUM,
    bill_instance_number           NUMBER := OKC_API.G_MISS_NUM,
    trx_number                     OKS_BILL_TXN_LINES_V.trx_number%type := OKC_API.G_MISS_CHAR,
    trx_date                       OKS_BILL_TXN_LINES_V.trx_date%type := OKC_API.G_MISS_DATE,
    trx_class                      OKS_BILL_TXN_LINES_V.trx_class%type := OKC_API.G_MISS_CHAR,
    trx_line_amount                OKS_BILL_TXN_LINES_V.TRX_LINE_AMOUNT%TYPE := OKC_API.G_MISS_CHAR,
    trx_line_tax_amount            NUMBER := OKC_API.G_MISS_NUM,
    trx_amount                     NUMBER := OKC_API.G_MISS_NUM,
    manual_credit                  NUMBER := OKC_API.G_MISS_NUM,
    attribute_category             OKS_BILL_TXN_LINES_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKS_BILL_TXN_LINES_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKS_BILL_TXN_LINES_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKS_BILL_TXN_LINES_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKS_BILL_TXN_LINES_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKS_BILL_TXN_LINES_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKS_BILL_TXN_LINES_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKS_BILL_TXN_LINES_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKS_BILL_TXN_LINES_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKS_BILL_TXN_LINES_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKS_BILL_TXN_LINES_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKS_BILL_TXN_LINES_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKS_BILL_TXN_LINES_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKS_BILL_TXN_LINES_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKS_BILL_TXN_LINES_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKS_BILL_TXN_LINES_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKS_BILL_TXN_LINES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKS_BILL_TXN_LINES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    split_flag                     OKS_BILL_TXN_LINES_V.SPLIT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    cycle_refrence                 OKS_BILL_TXN_LINES_V.CYCLE_REFRENCE%TYPE := OKC_API.G_MISS_CHAR);
  g_miss_btlv_rec                         btlv_rec_type;
  TYPE btlv_tbl_type IS TABLE OF btlv_rec_type
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
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKS_BTL_PVT';
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
    p_btlv_rec                     IN btlv_rec_type,
    x_btlv_rec                     OUT NOCOPY btlv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btlv_tbl                     IN btlv_tbl_type,
    x_btlv_tbl                     OUT NOCOPY btlv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btlv_rec                     IN btlv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btlv_tbl                     IN btlv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btlv_rec                     IN btlv_rec_type,
    x_btlv_rec                     OUT NOCOPY btlv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btlv_tbl                     IN btlv_tbl_type,
    x_btlv_tbl                     OUT NOCOPY btlv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btlv_rec                     IN btlv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btlv_tbl                     IN btlv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btlv_rec                     IN btlv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btlv_tbl                     IN btlv_tbl_type);
PROCEDURE INSERT_ROW_UPG(p_btlv_tbl     btlv_tbl_type);

END OKS_BTL_PVT;

 

/
