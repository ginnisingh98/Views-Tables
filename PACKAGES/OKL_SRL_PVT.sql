--------------------------------------------------------
--  DDL for Package OKL_SRL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SRL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSSRLS.pls 115.3 2003/10/16 07:06:16 smahapat noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_SIF_RET_LEVELS_V Record Spec
  TYPE okl_sif_ret_levels_v_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,level_index_number             NUMBER := OKC_API.G_MISS_NUM
    ,number_of_periods              NUMBER := OKC_API.G_MISS_NUM
    ,sir_id                         NUMBER := OKC_API.G_MISS_NUM
    ,index_number                   NUMBER := OKC_API.G_MISS_NUM
    ,level_type                     OKL_SIF_RET_LEVELS_V.LEVEL_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,amount                         NUMBER := OKC_API.G_MISS_NUM
    ,advance_or_arrears             OKL_SIF_RET_LEVELS_V.ADVANCE_OR_ARREARS%TYPE := OKC_API.G_MISS_CHAR
    ,period                         OKL_SIF_RET_LEVELS_V.PERIOD%TYPE := OKC_API.G_MISS_CHAR
    ,lock_level_step                OKL_SIF_RET_LEVELS_V.LOCK_LEVEL_STEP%TYPE := OKC_API.G_MISS_CHAR
    ,days_in_period                 NUMBER := OKC_API.G_MISS_NUM
    ,first_payment_date             OKL_SIF_RET_LEVELS_V.FIRST_PAYMENT_DATE%TYPE := OKC_API.G_MISS_DATE
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,stream_interface_attribute1    OKL_SIF_RET_LEVELS_V.STREAM_INTERFACE_ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR
    ,stream_interface_attribute2    OKL_SIF_RET_LEVELS_V.STREAM_INTERFACE_ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR
    ,stream_interface_attribute3    OKL_SIF_RET_LEVELS_V.STREAM_INTERFACE_ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR
    ,stream_interface_attribute4    OKL_SIF_RET_LEVELS_V.STREAM_INTERFACE_ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR
    ,stream_interface_attribute5    OKL_SIF_RET_LEVELS_V.STREAM_INTERFACE_ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR
    ,stream_interface_attribute6    OKL_SIF_RET_LEVELS_V.STREAM_INTERFACE_ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR
    ,stream_interface_attribute7    OKL_SIF_RET_LEVELS_V.STREAM_INTERFACE_ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR
    ,stream_interface_attribute8    OKL_SIF_RET_LEVELS_V.STREAM_INTERFACE_ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR
    ,stream_interface_attribute9    OKL_SIF_RET_LEVELS_V.STREAM_INTERFACE_ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR
    ,stream_interface_attribute10   OKL_SIF_RET_LEVELS_V.STREAM_INTERFACE_ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR
    ,stream_interface_attribute11   OKL_SIF_RET_LEVELS_V.STREAM_INTERFACE_ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR
    ,stream_interface_attribute12   OKL_SIF_RET_LEVELS_V.STREAM_INTERFACE_ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR
    ,stream_interface_attribute13   OKL_SIF_RET_LEVELS_V.STREAM_INTERFACE_ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR
    ,stream_interface_attribute14   OKL_SIF_RET_LEVELS_V.STREAM_INTERFACE_ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR
    ,stream_interface_attribute15   OKL_SIF_RET_LEVELS_V.STREAM_INTERFACE_ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR
    ,creation_date                  OKL_SIF_RET_LEVELS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKL_SIF_RET_LEVELS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
	,rate                           NUMBER := OKC_API.G_MISS_NUM); --smahapat 10/12/03
  GMissOklSifRetLevelsVRec                okl_sif_ret_levels_v_rec_type;
  TYPE okl_sif_ret_levels_v_tbl_type IS TABLE OF okl_sif_ret_levels_v_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_SIF_RET_LEVELS Record Spec
  TYPE srl_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,sir_id                         NUMBER := OKC_API.G_MISS_NUM
    ,index_number                   NUMBER := OKC_API.G_MISS_NUM
    ,number_of_periods              NUMBER := OKC_API.G_MISS_NUM
    ,level_index_number             NUMBER := OKC_API.G_MISS_NUM
    ,level_type                     OKL_SIF_RET_LEVELS.LEVEL_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,amount                         NUMBER := OKC_API.G_MISS_NUM
    ,advance_or_arrears             OKL_SIF_RET_LEVELS.ADVANCE_OR_ARREARS%TYPE := OKC_API.G_MISS_CHAR
    ,period                         OKL_SIF_RET_LEVELS.PERIOD%TYPE := OKC_API.G_MISS_CHAR
    ,lock_level_step                OKL_SIF_RET_LEVELS.LOCK_LEVEL_STEP%TYPE := OKC_API.G_MISS_CHAR
    ,days_in_period                 NUMBER := OKC_API.G_MISS_NUM
    ,first_payment_date             OKL_SIF_RET_LEVELS.FIRST_PAYMENT_DATE%TYPE := OKC_API.G_MISS_DATE
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,stream_interface_attribute1    OKL_SIF_RET_LEVELS.STREAM_INTERFACE_ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR
    ,stream_interface_attribute2    OKL_SIF_RET_LEVELS.STREAM_INTERFACE_ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR
    ,stream_interface_attribute3    OKL_SIF_RET_LEVELS.STREAM_INTERFACE_ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR
    ,stream_interface_attribute4    OKL_SIF_RET_LEVELS.STREAM_INTERFACE_ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR
    ,stream_interface_attribute5    OKL_SIF_RET_LEVELS.STREAM_INTERFACE_ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR
    ,stream_interface_attribute6    OKL_SIF_RET_LEVELS.STREAM_INTERFACE_ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR
    ,stream_interface_attribute7    OKL_SIF_RET_LEVELS.STREAM_INTERFACE_ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR
    ,stream_interface_attribute8    OKL_SIF_RET_LEVELS.STREAM_INTERFACE_ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR
    ,stream_interface_attribute9    OKL_SIF_RET_LEVELS.STREAM_INTERFACE_ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR
    ,stream_interface_attribute10   OKL_SIF_RET_LEVELS.STREAM_INTERFACE_ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR
    ,stream_interface_attribute11   OKL_SIF_RET_LEVELS.STREAM_INTERFACE_ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR
    ,stream_interface_attribute12   OKL_SIF_RET_LEVELS.STREAM_INTERFACE_ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR
    ,stream_interface_attribute13   OKL_SIF_RET_LEVELS.STREAM_INTERFACE_ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR
    ,stream_interface_attribute14   OKL_SIF_RET_LEVELS.STREAM_INTERFACE_ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR
    ,stream_interface_attribute15   OKL_SIF_RET_LEVELS.STREAM_INTERFACE_ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR
    ,creation_date                  OKL_SIF_RET_LEVELS.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKL_SIF_RET_LEVELS.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
	,rate                           NUMBER := OKC_API.G_MISS_NUM); --smahapat 10/12/03
  G_MISS_srl_rec                          srl_rec_type;
  TYPE srl_tbl_type IS TABLE OF srl_rec_type
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_SRL_PVT';
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
    p_okl_sif_ret_levels_v_rec     IN okl_sif_ret_levels_v_rec_type,
    x_okl_sif_ret_levels_v_rec     OUT NOCOPY okl_sif_ret_levels_v_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_sif_ret_levels_v_tbl     IN okl_sif_ret_levels_v_tbl_type,
    x_okl_sif_ret_levels_v_tbl     OUT NOCOPY okl_sif_ret_levels_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_sif_ret_levels_v_tbl     IN okl_sif_ret_levels_v_tbl_type,
    x_okl_sif_ret_levels_v_tbl     OUT NOCOPY okl_sif_ret_levels_v_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_sif_ret_levels_v_rec     IN okl_sif_ret_levels_v_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_sif_ret_levels_v_tbl     IN okl_sif_ret_levels_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_sif_ret_levels_v_tbl     IN okl_sif_ret_levels_v_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_sif_ret_levels_v_rec     IN okl_sif_ret_levels_v_rec_type,
    x_okl_sif_ret_levels_v_rec     OUT NOCOPY okl_sif_ret_levels_v_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_sif_ret_levels_v_tbl     IN okl_sif_ret_levels_v_tbl_type,
    x_okl_sif_ret_levels_v_tbl     OUT NOCOPY okl_sif_ret_levels_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_sif_ret_levels_v_tbl     IN okl_sif_ret_levels_v_tbl_type,
    x_okl_sif_ret_levels_v_tbl     OUT NOCOPY okl_sif_ret_levels_v_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_sif_ret_levels_v_rec     IN okl_sif_ret_levels_v_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_sif_ret_levels_v_tbl     IN okl_sif_ret_levels_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_sif_ret_levels_v_tbl     IN okl_sif_ret_levels_v_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_sif_ret_levels_v_rec     IN okl_sif_ret_levels_v_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_sif_ret_levels_v_tbl     IN okl_sif_ret_levels_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_sif_ret_levels_v_tbl     IN okl_sif_ret_levels_v_tbl_type);
END OKL_SRL_PVT;

 

/
