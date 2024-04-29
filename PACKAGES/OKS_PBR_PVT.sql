--------------------------------------------------------
--  DDL for Package OKS_PBR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_PBR_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSSPBRS.pls 120.0 2005/05/27 15:27:03 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKS_PRICE_BREAKS_V Record Spec
  TYPE pbrv_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,bsl_id                         NUMBER := OKC_API.G_MISS_NUM
    ,bcl_id                         NUMBER := OKC_API.G_MISS_NUM
    ,cle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,chr_id                         NUMBER := OKC_API.G_MISS_NUM
    ,line_detail_index              NUMBER := OKC_API.G_MISS_NUM
    ,line_index                     NUMBER := OKC_API.G_MISS_NUM
    ,pricing_context                OKS_PRICE_BREAKS_V.PRICING_CONTEXT%TYPE := OKC_API.G_MISS_CHAR
    ,pricing_method                 OKS_PRICE_BREAKS_V.PRICING_METHOD%TYPE := OKC_API.G_MISS_CHAR
    ,quantity_from                  NUMBER := OKC_API.G_MISS_NUM
    ,quantity_to                    NUMBER := OKC_API.G_MISS_NUM
    ,quantity                       NUMBER := OKC_API.G_MISS_NUM
    ,break_uom                      OKS_PRICE_BREAKS_V.BREAK_UOM%TYPE := OKC_API.G_MISS_CHAR
    ,prorate                        OKS_PRICE_BREAKS_V.PRORATE%TYPE := OKC_API.G_MISS_CHAR
    ,unit_price                     NUMBER := OKC_API.G_MISS_NUM
    ,amount                         NUMBER := OKC_API.G_MISS_NUM
    ,price_list_id                  NUMBER := OKC_API.G_MISS_NUM
    ,validated_flag                 OKS_PRICE_BREAKS_V.VALIDATED_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,status_code                    OKS_PRICE_BREAKS_V.STATUS_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,status_text                    OKS_PRICE_BREAKS_V.STATUS_TEXT%TYPE := OKC_API.G_MISS_CHAR
    ,lock_flag                      OKS_PRICE_BREAKS_V.LOCK_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,locked_price_list_id           NUMBER := OKC_API.G_MISS_NUM
    ,locked_price_list_line_id      NUMBER := OKC_API.G_MISS_NUM
    ,price_list_line_id             NUMBER := OKC_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_PRICE_BREAKS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_PRICE_BREAKS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_pbrv_rec                         pbrv_rec_type;
  TYPE pbrv_tbl_type IS TABLE OF pbrv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKS_PRICE_BREAKS Record Spec
  TYPE pbr_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,bsl_id                         NUMBER := OKC_API.G_MISS_NUM
    ,bcl_id                         NUMBER := OKC_API.G_MISS_NUM
    ,cle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,chr_id                         NUMBER := OKC_API.G_MISS_NUM
    ,line_detail_index              NUMBER := OKC_API.G_MISS_NUM
    ,line_index                     NUMBER := OKC_API.G_MISS_NUM
    ,pricing_context                OKS_PRICE_BREAKS.PRICING_CONTEXT%TYPE := OKC_API.G_MISS_CHAR
    ,pricing_method                 OKS_PRICE_BREAKS.PRICING_METHOD%TYPE := OKC_API.G_MISS_CHAR
    ,quantity_from                  NUMBER := OKC_API.G_MISS_NUM
    ,quantity_to                    NUMBER := OKC_API.G_MISS_NUM
    ,quantity                       NUMBER := OKC_API.G_MISS_NUM
    ,break_uom                      OKS_PRICE_BREAKS.BREAK_UOM%TYPE := OKC_API.G_MISS_CHAR
    ,prorate                        OKS_PRICE_BREAKS.PRORATE%TYPE := OKC_API.G_MISS_CHAR
    ,unit_price                     NUMBER := OKC_API.G_MISS_NUM
    ,amount                         NUMBER := OKC_API.G_MISS_NUM
    ,price_list_id                  NUMBER := OKC_API.G_MISS_NUM
    ,validated_flag                 OKS_PRICE_BREAKS.VALIDATED_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,status_code                    OKS_PRICE_BREAKS.STATUS_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,status_text                    OKS_PRICE_BREAKS.STATUS_TEXT%TYPE := OKC_API.G_MISS_CHAR
    ,lock_flag                      OKS_PRICE_BREAKS.LOCK_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,locked_price_list_id           NUMBER := OKC_API.G_MISS_NUM
    ,locked_price_list_line_id      NUMBER := OKC_API.G_MISS_NUM
    ,price_list_line_id             NUMBER := OKC_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_PRICE_BREAKS.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_PRICE_BREAKS.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_pbr_rec                          pbr_rec_type;
  TYPE pbr_tbl_type IS TABLE OF pbr_rec_type
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKS_PBR_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pbrv_rec                     IN pbrv_rec_type,
    x_pbrv_rec                     OUT NOCOPY pbrv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pbrv_tbl                     IN pbrv_tbl_type,
    x_pbrv_tbl                     OUT NOCOPY pbrv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pbrv_tbl                     IN pbrv_tbl_type,
    x_pbrv_tbl                     OUT NOCOPY pbrv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pbrv_rec                     IN pbrv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pbrv_tbl                     IN pbrv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pbrv_tbl                     IN pbrv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pbrv_rec                     IN pbrv_rec_type,
    x_pbrv_rec                     OUT NOCOPY pbrv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pbrv_tbl                     IN pbrv_tbl_type,
    x_pbrv_tbl                     OUT NOCOPY pbrv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pbrv_tbl                     IN pbrv_tbl_type,
    x_pbrv_tbl                     OUT NOCOPY pbrv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pbrv_rec                     IN pbrv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pbrv_tbl                     IN pbrv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pbrv_tbl                     IN pbrv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pbrv_rec                     IN pbrv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pbrv_tbl                     IN pbrv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pbrv_tbl                     IN pbrv_tbl_type);
END OKS_PBR_PVT;

 

/
