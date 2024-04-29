--------------------------------------------------------
--  DDL for Package OKS_BSD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_BSD_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSSBSDS.pls 120.1 2006/09/19 18:51:25 hvaladip noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE bsd_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    bsl_id                         NUMBER := OKC_API.G_MISS_NUM,
    bsl_id_averaged                NUMBER := OKC_API.G_MISS_NUM,
    bsd_id                         NUMBER := OKC_API.G_MISS_NUM,
    bsd_id_applied                 NUMBER := OKC_API.G_MISS_NUM,
    ccr_id	                   NUMBER := OKC_API.G_MISS_NUM,
    cgr_id	                   NUMBER := OKC_API.G_MISS_NUM,
    start_reading                  NUMBER := OKC_API.G_MISS_NUM,
    end_reading                    NUMBER := OKC_API.G_MISS_NUM,
    base_reading                   NUMBER := OKC_API.G_MISS_NUM,
    estimated_quantity             NUMBER := OKC_API.G_MISS_NUM,
    unit_of_measure                OKS_BILL_SUB_LINE_DTLS.UNIT_OF_MEASURE%TYPE := OKC_API.G_MISS_CHAR,
    amcv_yn                        OKS_BILL_SUB_LINE_DTLS.AMCV_YN%TYPE := OKC_API.G_MISS_CHAR,
    result                         NUMBER := OKC_API.G_MISS_NUM,
    amount                         NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKS_BILL_SUB_LINE_DTLS.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKS_BILL_SUB_LINE_DTLS.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    fixed                          NUMBER := OKC_API.G_MISS_NUM,
    actual                         NUMBER := OKC_API.G_MISS_NUM,
    default_default                NUMBER := OKC_API.G_MISS_NUM,
    adjustment_level               NUMBER := OKC_API.G_MISS_NUM,
    adjustment_minimum             NUMBER := OKC_API.G_MISS_NUM,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    attribute_category             OKS_BILL_SUB_LINE_DTLS.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKS_BILL_SUB_LINE_DTLS.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKS_BILL_SUB_LINE_DTLS.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKS_BILL_SUB_LINE_DTLS.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKS_BILL_SUB_LINE_DTLS.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKS_BILL_SUB_LINE_DTLS.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKS_BILL_SUB_LINE_DTLS.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKS_BILL_SUB_LINE_DTLS.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKS_BILL_SUB_LINE_DTLS.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKS_BILL_SUB_LINE_DTLS.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKS_BILL_SUB_LINE_DTLS.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKS_BILL_SUB_LINE_DTLS.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKS_BILL_SUB_LINE_DTLS.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKS_BILL_SUB_LINE_DTLS.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKS_BILL_SUB_LINE_DTLS.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKS_BILL_SUB_LINE_DTLS.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR);
  g_miss_bsd_rec                          bsd_rec_type;
  TYPE bsd_tbl_type IS TABLE OF bsd_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE bsdv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    bsl_id                         NUMBER := OKC_API.G_MISS_NUM,
    bsl_id_averaged                NUMBER := OKC_API.G_MISS_NUM,
    bsd_id                         NUMBER := OKC_API.G_MISS_NUM,
    bsd_id_applied                 NUMBER := OKC_API.G_MISS_NUM,
    ccr_id	                   NUMBER := OKC_API.G_MISS_NUM,
    cgr_id	                   NUMBER := OKC_API.G_MISS_NUM,
    start_reading                  NUMBER := OKC_API.G_MISS_NUM,
    end_reading                    NUMBER := OKC_API.G_MISS_NUM,
    base_reading                   NUMBER := OKC_API.G_MISS_NUM,
    estimated_quantity             NUMBER := OKC_API.G_MISS_NUM,
    unit_of_measure                OKS_BILL_SUBLINE_DTLS_V.UNIT_OF_MEASURE%TYPE := OKC_API.G_MISS_CHAR,
    fixed                          NUMBER := OKC_API.G_MISS_NUM,
    actual                         NUMBER := OKC_API.G_MISS_NUM,
    default_default                NUMBER := OKC_API.G_MISS_NUM,
    amcv_yn                        OKS_BILL_SUBLINE_DTLS_V.AMCV_YN%TYPE := OKC_API.G_MISS_CHAR,
    adjustment_level               NUMBER := OKC_API.G_MISS_NUM,
    adjustment_minimum             NUMBER := OKC_API.G_MISS_NUM,
    result                         NUMBER := OKC_API.G_MISS_NUM,
    amount                         NUMBER := OKC_API.G_MISS_NUM,
    attribute_category             OKS_BILL_SUBLINE_DTLS_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKS_BILL_SUBLINE_DTLS_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKS_BILL_SUBLINE_DTLS_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKS_BILL_SUBLINE_DTLS_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKS_BILL_SUBLINE_DTLS_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKS_BILL_SUBLINE_DTLS_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKS_BILL_SUBLINE_DTLS_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKS_BILL_SUBLINE_DTLS_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKS_BILL_SUBLINE_DTLS_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKS_BILL_SUBLINE_DTLS_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKS_BILL_SUBLINE_DTLS_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKS_BILL_SUBLINE_DTLS_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKS_BILL_SUBLINE_DTLS_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKS_BILL_SUBLINE_DTLS_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKS_BILL_SUBLINE_DTLS_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKS_BILL_SUBLINE_DTLS_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKS_BILL_SUBLINE_DTLS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKS_BILL_SUBLINE_DTLS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_bsdv_rec                         bsdv_rec_type;
  TYPE bsdv_tbl_type IS TABLE OF bsdv_rec_type
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
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKS_BSD_PVT';
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
    p_bsdv_rec                     IN bsdv_rec_type,
    x_bsdv_rec                     OUT NOCOPY bsdv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bsdv_tbl                     IN bsdv_tbl_type,
    x_bsdv_tbl                     OUT NOCOPY bsdv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bsdv_rec                     IN bsdv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bsdv_tbl                     IN bsdv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bsdv_rec                     IN bsdv_rec_type,
    x_bsdv_rec                     OUT NOCOPY bsdv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bsdv_tbl                     IN bsdv_tbl_type,
    x_bsdv_tbl                     OUT NOCOPY bsdv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bsdv_rec                     IN bsdv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bsdv_tbl                     IN bsdv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bsdv_rec                     IN bsdv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bsdv_tbl                     IN bsdv_tbl_type);

END OKS_BSD_PVT;

 

/
