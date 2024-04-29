--------------------------------------------------------
--  DDL for Package OKS_SLL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_SLL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSSSLLS.pls 120.3 2006/09/19 18:57:18 hvaladip noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKS_STREAM_LEVELS_V Record Spec
  TYPE sllv_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,chr_id                         NUMBER := OKC_API.G_MISS_NUM
    ,cle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM
    ,sequence_no                    NUMBER := OKC_API.G_MISS_NUM
    ,uom_code                       OKS_STREAM_LEVELS_V.UOM_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,start_date                     OKS_STREAM_LEVELS_V.START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,end_date                       OKS_STREAM_LEVELS_V.END_DATE%TYPE := OKC_API.G_MISS_DATE
    ,level_periods                  NUMBER := OKC_API.G_MISS_NUM
    ,uom_per_period                 NUMBER := OKC_API.G_MISS_NUM
    ,advance_periods                NUMBER := OKC_API.G_MISS_NUM
    ,level_amount                   NUMBER := OKC_API.G_MISS_NUM
    ,invoice_offset_days            NUMBER := OKC_API.G_MISS_NUM
    ,interface_offset_days          NUMBER := OKC_API.G_MISS_NUM
    ,comments                       OKS_STREAM_LEVELS_V.COMMENTS%TYPE := OKC_API.G_MISS_CHAR
    ,due_arr_yn                     OKS_STREAM_LEVELS_V.DUE_ARR_YN%TYPE := OKC_API.G_MISS_CHAR
    ,amount                         NUMBER := OKC_API.G_MISS_NUM
    ,lines_detailed_yn              OKS_STREAM_LEVELS_V.LINES_DETAILED_YN%TYPE := OKC_API.G_MISS_CHAR
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,security_group_id              NUMBER := OKC_API.G_MISS_NUM
    ,request_id                     NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_STREAM_LEVELS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_STREAM_LEVELS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,orig_system_id1                NUMBER := OKC_API.G_MISS_NUM
    ,orig_system_reference1         OKS_STREAM_LEVELS_V.ORIG_SYSTEM_REFERENCE1%TYPE := OKC_API.G_MISS_CHAR
    ,orig_system_source_code        OKS_STREAM_LEVELS_V.ORIG_SYSTEM_SOURCE_CODE%TYPE := OKC_API.G_MISS_CHAR);
  G_MISS_sllv_rec                         sllv_rec_type;
  TYPE sllv_tbl_type IS TABLE OF sllv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKS_STREAM_LEVELS_B Record Spec
  TYPE sll_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,chr_id                         NUMBER := OKC_API.G_MISS_NUM
    ,cle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM
    ,sequence_no                    NUMBER := OKC_API.G_MISS_NUM
    ,uom_code                       OKS_STREAM_LEVELS_B.UOM_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,start_date                     OKS_STREAM_LEVELS_B.START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,end_date                       OKS_STREAM_LEVELS_B.END_DATE%TYPE := OKC_API.G_MISS_DATE
    ,level_periods                  NUMBER := OKC_API.G_MISS_NUM
    ,uom_per_period                 NUMBER := OKC_API.G_MISS_NUM
    ,advance_periods                NUMBER := OKC_API.G_MISS_NUM
    ,level_amount                   NUMBER := OKC_API.G_MISS_NUM
    ,invoice_offset_days            NUMBER := OKC_API.G_MISS_NUM
    ,interface_offset_days          NUMBER := OKC_API.G_MISS_NUM
    ,comments                       OKS_STREAM_LEVELS_B.COMMENTS%TYPE := OKC_API.G_MISS_CHAR
    ,due_arr_yn                     OKS_STREAM_LEVELS_B.DUE_ARR_YN%TYPE := OKC_API.G_MISS_CHAR
    ,amount                         NUMBER := OKC_API.G_MISS_NUM
    ,lines_detailed_yn              OKS_STREAM_LEVELS_B.LINES_DETAILED_YN%TYPE := OKC_API.G_MISS_CHAR
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,request_id                     NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_STREAM_LEVELS_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_STREAM_LEVELS_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,orig_system_id1                NUMBER := OKC_API.G_MISS_NUM
    ,orig_system_reference1         OKS_STREAM_LEVELS_B.ORIG_SYSTEM_REFERENCE1%TYPE := OKC_API.G_MISS_CHAR
    ,orig_system_source_code        OKS_STREAM_LEVELS_B.ORIG_SYSTEM_SOURCE_CODE%TYPE := OKC_API.G_MISS_CHAR);
  G_MISS_sll_rec                          sll_rec_type;
  TYPE sll_tbl_type IS TABLE OF sll_rec_type
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
  G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200) := 'OKS_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN                CONSTANT VARCHAR2(200) := 'SQLcode';
  G_SQLERRM_TOKEN                CONSTANT VARCHAR2(200) := 'SQLerrm';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKS_SLL_PVT';
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
    p_sllv_rec                     IN sllv_rec_type,
    x_sllv_rec                     OUT NOCOPY sllv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_tbl                     IN sllv_tbl_type,
    x_sllv_tbl                     OUT NOCOPY sllv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_tbl                     IN sllv_tbl_type,
    x_sllv_tbl                     OUT NOCOPY sllv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_rec                     IN sllv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_tbl                     IN sllv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_tbl                     IN sllv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_rec                     IN sllv_rec_type,
    x_sllv_rec                     OUT NOCOPY sllv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_tbl                     IN sllv_tbl_type,
    x_sllv_tbl                     OUT NOCOPY sllv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_tbl                     IN sllv_tbl_type,
    x_sllv_tbl                     OUT NOCOPY sllv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_rec                     IN sllv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_tbl                     IN sllv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_tbl                     IN sllv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_rec                     IN sllv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_tbl                     IN sllv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_tbl                     IN sllv_tbl_type);
END OKS_SLL_PVT;

 

/
