--------------------------------------------------------
--  DDL for Package OKS_COD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_COD_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSRCODS.pls 120.1 2006/05/26 22:29:23 jvarghes noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKS_K_ORDER_DETAILS_V Record Spec
  TYPE codv_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,cod_id                         NUMBER := OKC_API.G_MISS_NUM
    ,apply_all_yn                   OKS_K_ORDER_DETAILS_V.APPLY_ALL_YN%TYPE := OKC_API.G_MISS_CHAR
    ,line_renewal_type              OKS_K_ORDER_DETAILS_V.LINE_RENEWAL_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,renewal_type                   OKS_K_ORDER_DETAILS_V.RENEWAL_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,po_required_yn                 OKS_K_ORDER_DETAILS_V.PO_REQUIRED_YN%TYPE := OKC_API.G_MISS_CHAR
    ,renewal_pricing_type           OKS_K_ORDER_DETAILS_V.RENEWAL_PRICING_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,markup_percent                 NUMBER := OKC_API.G_MISS_NUM
    ,link_order_header_id           NUMBER := OKC_API.G_MISS_NUM
    ,end_date                       OKS_K_ORDER_DETAILS_V.END_DATE%TYPE := OKC_API.G_MISS_DATE
    ,cod_type                       OKS_K_ORDER_DETAILS_V.COD_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,order_line_id1                 OKS_K_ORDER_DETAILS_V.ORDER_LINE_ID1%TYPE := OKC_API.G_MISS_CHAR
    ,order_line_id2                 OKS_K_ORDER_DETAILS_V.ORDER_LINE_ID2%TYPE := OKC_API.G_MISS_CHAR
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_K_ORDER_DETAILS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_K_ORDER_DETAILS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,link_ord_line_id1              OKS_K_ORDER_DETAILS_V.LINK_ORD_LINE_ID1%TYPE := OKC_API.G_MISS_CHAR
    ,link_ord_line_id2              OKS_K_ORDER_DETAILS_V.LINK_ORD_LINE_ID2%TYPE := OKC_API.G_MISS_CHAR
    ,link_chr_id                    NUMBER := OKC_API.G_MISS_NUM
    ,link_cle_id                    NUMBER := OKC_API.G_MISS_NUM
    ,price_list_id1                 OKS_K_ORDER_DETAILS_V.PRICE_LIST_ID1%TYPE := OKC_API.G_MISS_CHAR
    ,price_list_id2                 OKS_K_ORDER_DETAILS_V.PRICE_LIST_ID2%TYPE := OKC_API.G_MISS_CHAR
    ,chr_id                         NUMBER := OKC_API.G_MISS_NUM
    ,cle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,contact_id                     NUMBER := OKC_API.G_MISS_NUM
    ,site_id                        NUMBER := OKC_API.G_MISS_NUM
    ,email_id                       NUMBER := OKC_API.G_MISS_NUM
    ,phone_id                       NUMBER := OKC_API.G_MISS_NUM
    ,fax_id                         NUMBER := OKC_API.G_MISS_NUM
    ,billing_profile_id             NUMBER := OKC_API.G_MISS_NUM
    ,RENEWAL_APPROVAL_FLAG          OKS_K_ORDER_DETAILS_V.RENEWAL_APPROVAL_FLAG%TYPE := OKC_API.G_MISS_CHAR);

  G_MISS_codv_rec                         codv_rec_type;

  TYPE codv_tbl_type IS TABLE OF codv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKS_K_ORDER_DETAILS Record Spec
  TYPE cod_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,cod_type                       OKS_K_ORDER_DETAILS.COD_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,link_order_header_id           NUMBER := OKC_API.G_MISS_NUM
    ,order_line_id1                 OKS_K_ORDER_DETAILS.ORDER_LINE_ID1%TYPE := OKC_API.G_MISS_CHAR
    ,order_line_id2                 OKS_K_ORDER_DETAILS.ORDER_LINE_ID2%TYPE := OKC_API.G_MISS_CHAR
    ,apply_all_yn                   OKS_K_ORDER_DETAILS.APPLY_ALL_YN%TYPE := OKC_API.G_MISS_CHAR
    ,renewal_type                   OKS_K_ORDER_DETAILS.RENEWAL_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,line_renewal_type              OKS_K_ORDER_DETAILS.LINE_RENEWAL_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,end_date                       OKS_K_ORDER_DETAILS.END_DATE%TYPE := OKC_API.G_MISS_DATE
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_K_ORDER_DETAILS.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_K_ORDER_DETAILS.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,po_required_yn                 OKS_K_ORDER_DETAILS.PO_REQUIRED_YN%TYPE := OKC_API.G_MISS_CHAR
    ,renewal_pricing_type           OKS_K_ORDER_DETAILS.RENEWAL_PRICING_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,markup_percent                 NUMBER := OKC_API.G_MISS_NUM
    ,price_list_id1                 OKS_K_ORDER_DETAILS.PRICE_LIST_ID1%TYPE := OKC_API.G_MISS_CHAR
    ,price_list_id2                 OKS_K_ORDER_DETAILS.PRICE_LIST_ID2%TYPE := OKC_API.G_MISS_CHAR
    ,link_ord_line_id1              OKS_K_ORDER_DETAILS.LINK_ORD_LINE_ID1%TYPE := OKC_API.G_MISS_CHAR
    ,link_ord_line_id2              OKS_K_ORDER_DETAILS.LINK_ORD_LINE_ID2%TYPE := OKC_API.G_MISS_CHAR
    ,link_chr_id                    NUMBER := OKC_API.G_MISS_NUM
    ,link_cle_id                    NUMBER := OKC_API.G_MISS_NUM
    ,chr_id                         NUMBER := OKC_API.G_MISS_NUM
    ,cle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,cod_id                         NUMBER := OKC_API.G_MISS_NUM
    ,contact_id                     NUMBER := OKC_API.G_MISS_NUM
    ,site_id                        NUMBER := OKC_API.G_MISS_NUM
    ,email_id                       NUMBER := OKC_API.G_MISS_NUM
    ,phone_id                       NUMBER := OKC_API.G_MISS_NUM
    ,fax_id                         NUMBER := OKC_API.G_MISS_NUM
    ,billing_profile_id             NUMBER := OKC_API.G_MISS_NUM
    ,RENEWAL_APPROVAL_FLAG          OKS_K_ORDER_DETAILS_V.RENEWAL_APPROVAL_FLAG%TYPE := OKC_API.G_MISS_CHAR);

  G_MISS_cod_rec                          cod_rec_type;
  TYPE cod_tbl_type IS TABLE OF cod_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                      CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC   CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED          CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED          CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED     CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE               CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE                CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN               CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN           CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN            CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200) := 'OKS_SERVICE_AVAILABILITY_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN                CONSTANT VARCHAR2(200) := 'SQLcode';
  G_SQLERRM_TOKEN                CONSTANT VARCHAR2(200) := 'SQLerrm';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKS_COD_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
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
    p_codv_rec                     IN codv_rec_type,
    x_codv_rec                     OUT NOCOPY codv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_tbl                     IN codv_tbl_type,
    x_codv_tbl                     OUT NOCOPY codv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_tbl                     IN codv_tbl_type,
    x_codv_tbl                     OUT NOCOPY codv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_rec                     IN codv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_tbl                     IN codv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_tbl                     IN codv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_rec                     IN codv_rec_type,
    x_codv_rec                     OUT NOCOPY codv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_tbl                     IN codv_tbl_type,
    x_codv_tbl                     OUT NOCOPY codv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_tbl                     IN codv_tbl_type,
    x_codv_tbl                     OUT NOCOPY codv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_rec                     IN codv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_tbl                     IN codv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_tbl                     IN codv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_rec                     IN codv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_tbl                     IN codv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_tbl                     IN codv_tbl_type);
END OKS_COD_PVT;

 

/
