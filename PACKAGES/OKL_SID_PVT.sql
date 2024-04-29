--------------------------------------------------------
--  DDL for Package OKL_SID_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SID_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSSIDS.pls 115.1 2002/03/18 01:12:34 pkm ship        $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE sidv_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,cle_id                         NUMBER := OKL_API.G_MISS_NUM
    ,fa_cle_id                      NUMBER := OKL_API.G_MISS_NUM
    ,invoice_number                 OKL_SUPP_INVOICE_DTLS_V.INVOICE_NUMBER%TYPE := OKL_API.G_MISS_CHAR
    ,date_invoiced                  OKL_SUPP_INVOICE_DTLS_V.DATE_INVOICED%TYPE := OKL_API.G_MISS_DATE
    ,date_due                       OKL_SUPP_INVOICE_DTLS_V.DATE_DUE%TYPE := OKL_API.G_MISS_DATE
    ,shipping_address_id1           NUMBER := OKL_API.G_MISS_NUM
    ,shipping_address_id2           OKL_SUPP_INVOICE_DTLS_V.SHIPPING_ADDRESS_ID2%TYPE := OKL_API.G_MISS_CHAR
    ,shipping_address_code          OKL_SUPP_INVOICE_DTLS_V.SHIPPING_ADDRESS_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,attribute_category             OKL_SUPP_INVOICE_DTLS_V.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_SUPP_INVOICE_DTLS_V.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_SUPP_INVOICE_DTLS_V.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_SUPP_INVOICE_DTLS_V.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_SUPP_INVOICE_DTLS_V.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_SUPP_INVOICE_DTLS_V.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_SUPP_INVOICE_DTLS_V.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_SUPP_INVOICE_DTLS_V.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_SUPP_INVOICE_DTLS_V.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_SUPP_INVOICE_DTLS_V.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_SUPP_INVOICE_DTLS_V.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_SUPP_INVOICE_DTLS_V.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_SUPP_INVOICE_DTLS_V.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_SUPP_INVOICE_DTLS_V.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_SUPP_INVOICE_DTLS_V.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_SUPP_INVOICE_DTLS_V.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_SUPP_INVOICE_DTLS_V.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_SUPP_INVOICE_DTLS_V.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM);
  G_MISS_sidv_rec                         sidv_rec_type;
  TYPE sidv_tbl_type IS TABLE OF sidv_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE sid_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,cle_id                         NUMBER := OKL_API.G_MISS_NUM
    ,fa_cle_id                      NUMBER := OKL_API.G_MISS_NUM
    ,invoice_number                 OKL_SUPP_INVOICE_DTLS.INVOICE_NUMBER%TYPE := OKL_API.G_MISS_CHAR
    ,date_invoiced                  OKL_SUPP_INVOICE_DTLS.DATE_INVOICED%TYPE := OKL_API.G_MISS_DATE
    ,date_due                       OKL_SUPP_INVOICE_DTLS.DATE_DUE%TYPE := OKL_API.G_MISS_DATE
    ,shipping_address_id1           NUMBER := OKL_API.G_MISS_NUM
    ,shipping_address_id2           OKL_SUPP_INVOICE_DTLS.SHIPPING_ADDRESS_ID2%TYPE := OKL_API.G_MISS_CHAR
    ,shipping_address_code          OKL_SUPP_INVOICE_DTLS.SHIPPING_ADDRESS_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,attribute_category             OKL_SUPP_INVOICE_DTLS.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_SUPP_INVOICE_DTLS.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_SUPP_INVOICE_DTLS.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_SUPP_INVOICE_DTLS.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_SUPP_INVOICE_DTLS.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_SUPP_INVOICE_DTLS.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_SUPP_INVOICE_DTLS.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_SUPP_INVOICE_DTLS.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_SUPP_INVOICE_DTLS.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_SUPP_INVOICE_DTLS.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_SUPP_INVOICE_DTLS.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_SUPP_INVOICE_DTLS.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_SUPP_INVOICE_DTLS.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_SUPP_INVOICE_DTLS.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_SUPP_INVOICE_DTLS.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_SUPP_INVOICE_DTLS.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_SUPP_INVOICE_DTLS.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_SUPP_INVOICE_DTLS.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM);
  G_MISS_sid_rec                          sid_rec_type;
  TYPE sid_tbl_type IS TABLE OF sid_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE okl_sidh_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,major_version                  NUMBER := OKC_API.G_MISS_NUM
    ,cle_id                         NUMBER := OKL_API.G_MISS_NUM
    ,fa_cle_id                      NUMBER := OKL_API.G_MISS_NUM
    ,invoice_number                 OKL_SUPP_INVOICE_DTLS_H.INVOICE_NUMBER%TYPE := OKL_API.G_MISS_CHAR
    ,date_invoiced                  OKL_SUPP_INVOICE_DTLS_H.DATE_INVOICED%TYPE := OKL_API.G_MISS_DATE
    ,date_due                       OKL_SUPP_INVOICE_DTLS_H.DATE_DUE%TYPE := OKL_API.G_MISS_DATE
    ,shipping_address_id1           NUMBER := OKL_API.G_MISS_NUM
    ,shipping_address_id2           OKL_SUPP_INVOICE_DTLS_H.SHIPPING_ADDRESS_ID2%TYPE := OKL_API.G_MISS_CHAR
    ,shipping_address_code          OKL_SUPP_INVOICE_DTLS_H.SHIPPING_ADDRESS_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,attribute_category             OKL_SUPP_INVOICE_DTLS_H.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_SUPP_INVOICE_DTLS_H.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_SUPP_INVOICE_DTLS_H.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_SUPP_INVOICE_DTLS_H.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_SUPP_INVOICE_DTLS_H.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_SUPP_INVOICE_DTLS_H.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_SUPP_INVOICE_DTLS_H.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_SUPP_INVOICE_DTLS_H.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_SUPP_INVOICE_DTLS_H.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_SUPP_INVOICE_DTLS_H.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_SUPP_INVOICE_DTLS_H.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_SUPP_INVOICE_DTLS_H.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_SUPP_INVOICE_DTLS_H.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_SUPP_INVOICE_DTLS_H.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_SUPP_INVOICE_DTLS_H.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_SUPP_INVOICE_DTLS_H.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_SUPP_INVOICE_DTLS_H.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_SUPP_INVOICE_DTLS_H.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM);
  g_miss_okl_sidh_rec                okl_sidh_rec_type;
  TYPE okl_sidh_tbl_type IS TABLE OF okl_sidh_rec_type
        INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                      CONSTANT VARCHAR2(200) := OKL_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKL_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKL_API.G_RECORD_LOGICALLY_DELETED;
  G_COL_NAME_TOKEN              CONSTANT  VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_COL_NAME_TOKEN1		CONSTANT VARCHAR2(200) := 'COL_NAME1';
  G_COL_NAME_TOKEN2		CONSTANT VARCHAR2(200) := 'COL_NAME2';
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_SID_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_rec                     IN sidv_rec_type,
    x_sidv_rec                     OUT NOCOPY sidv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_tbl                     IN sidv_tbl_type,
    x_sidv_tbl                     OUT NOCOPY sidv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_rec                     IN sidv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_tbl                     IN sidv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_rec                     IN sidv_rec_type,
    x_sidv_rec                     OUT NOCOPY sidv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_tbl                     IN sidv_tbl_type,
    x_sidv_tbl                     OUT NOCOPY sidv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_rec                     IN sidv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_tbl                     IN sidv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_rec                     IN sidv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_tbl                     IN sidv_tbl_type);

  FUNCTION create_version(p_chr_id        IN OKC_K_LINES_B.ID%TYPE,
                           p_major_version IN OKL_SUPP_INVOICE_DTLS_H.MAJOR_VERSION%TYPE)
  RETURN VARCHAR2;
  FUNCTION restore_version(p_chr_id        OKC_K_LINES_B.ID%TYPE,
                            p_major_version OKL_SUPP_INVOICE_DTLS_H.MAJOR_VERSION%TYPE)
  RETURN VARCHAR2;
END OKL_SID_PVT;

 

/
