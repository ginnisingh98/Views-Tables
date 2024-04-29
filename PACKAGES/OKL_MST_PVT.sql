--------------------------------------------------------
--  DDL for Package OKL_MST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_MST_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSMSTS.pls 115.3 2004/02/24 22:42:38 dedey noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_RBK_SELECTED_CONTRACT_V Record Spec
  TYPE mstv_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,request_name                   OKL_RBK_SELECTED_CONTRACT.REQUEST_NAME%TYPE := OKC_API.G_MISS_CHAR
    ,khr_id                         NUMBER := OKC_API.G_MISS_NUM
    ,contract_number                OKL_RBK_SELECTED_CONTRACT_V.CONTRACT_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,contract_description           OKL_RBK_SELECTED_CONTRACT_V.CONTRACT_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR
    ,kle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,transaction_id                 NUMBER := OKC_API.G_MISS_NUM
    ,selected_flag                  OKL_RBK_SELECTED_CONTRACT_V.SELECTED_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,status                         VARCHAR2(30) := OKC_API.G_MISS_CHAR
    ,attribute_category             OKL_RBK_SELECTED_CONTRACT_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR
    ,attribute1                     OKL_RBK_SELECTED_CONTRACT_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR
    ,attribute2                     OKL_RBK_SELECTED_CONTRACT_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR
    ,attribute3                     OKL_RBK_SELECTED_CONTRACT_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR
    ,attribute4                     OKL_RBK_SELECTED_CONTRACT_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR
    ,attribute5                     OKL_RBK_SELECTED_CONTRACT_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR
    ,attribute6                     OKL_RBK_SELECTED_CONTRACT_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR
    ,attribute7                     OKL_RBK_SELECTED_CONTRACT_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR
    ,attribute8                     OKL_RBK_SELECTED_CONTRACT_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR
    ,attribute9                     OKL_RBK_SELECTED_CONTRACT_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR
    ,attribute10                    OKL_RBK_SELECTED_CONTRACT_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR
    ,attribute11                    OKL_RBK_SELECTED_CONTRACT_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR
    ,attribute12                    OKL_RBK_SELECTED_CONTRACT_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR
    ,attribute13                    OKL_RBK_SELECTED_CONTRACT_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR
    ,attribute14                    OKL_RBK_SELECTED_CONTRACT_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR
    ,attribute15                    OKL_RBK_SELECTED_CONTRACT_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKL_RBK_SELECTED_CONTRACT_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKL_RBK_SELECTED_CONTRACT_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,transaction_date               OKL_RBK_SELECTED_CONTRACT_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE);
  G_MISS_mstv_rec                         mstv_rec_type;
  TYPE mstv_tbl_type IS TABLE OF mstv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_RBK_SELECTED_CONTRACT Record Spec
  TYPE mst_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,request_name                   OKL_RBK_SELECTED_CONTRACT.REQUEST_NAME%TYPE := OKC_API.G_MISS_CHAR
    ,khr_id                         NUMBER := OKC_API.G_MISS_NUM
    ,contract_number                OKL_RBK_SELECTED_CONTRACT.CONTRACT_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,contract_description           OKL_RBK_SELECTED_CONTRACT.contract_description%TYPE := OKC_API.G_MISS_CHAR
    ,kle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,transaction_id                 NUMBER := OKC_API.G_MISS_NUM
    ,selected_flag                  OKL_RBK_SELECTED_CONTRACT.SELECTED_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,status                         VARCHAR2(30) := OKC_API.G_MISS_CHAR
    ,attribute_category             OKL_RBK_SELECTED_CONTRACT.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR
    ,attribute1                     OKL_RBK_SELECTED_CONTRACT.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR
    ,attribute2                     OKL_RBK_SELECTED_CONTRACT.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR
    ,attribute3                     OKL_RBK_SELECTED_CONTRACT.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR
    ,attribute4                     OKL_RBK_SELECTED_CONTRACT.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR
    ,attribute5                     OKL_RBK_SELECTED_CONTRACT.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR
    ,attribute6                     OKL_RBK_SELECTED_CONTRACT.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR
    ,attribute7                     OKL_RBK_SELECTED_CONTRACT.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR
    ,attribute8                     OKL_RBK_SELECTED_CONTRACT.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR
    ,attribute9                     OKL_RBK_SELECTED_CONTRACT.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR
    ,attribute10                    OKL_RBK_SELECTED_CONTRACT.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR
    ,attribute11                    OKL_RBK_SELECTED_CONTRACT.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR
    ,attribute12                    OKL_RBK_SELECTED_CONTRACT.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR
    ,attribute13                    OKL_RBK_SELECTED_CONTRACT.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR
    ,attribute14                    OKL_RBK_SELECTED_CONTRACT.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR
    ,attribute15                    OKL_RBK_SELECTED_CONTRACT.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKL_RBK_SELECTED_CONTRACT.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKL_RBK_SELECTED_CONTRACT.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,transaction_date               OKL_RBK_SELECTED_CONTRACT_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE);
  G_MISS_mst_rec                          mst_rec_type;
  TYPE mst_tbl_type IS TABLE OF mst_rec_type
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

  -- The following variable is not in use
  -- Fix for Bug# , dedey, 06/27/2002
  G_NO_MATCHING_RECORD           CONSTANT VARCHAR2(200) := 'OKL_LLA_NO_MATCHING_RECORD';


  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_MST_PVT';
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
    p_mstv_rec                     IN mstv_rec_type,
    x_mstv_rec                     OUT NOCOPY mstv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mstv_tbl                     IN mstv_tbl_type,
    x_mstv_tbl                     OUT NOCOPY mstv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mstv_rec                     IN mstv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mstv_tbl                     IN mstv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mstv_rec                     IN mstv_rec_type,
    x_mstv_rec                     OUT NOCOPY mstv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mstv_tbl                     IN mstv_tbl_type,
    x_mstv_tbl                     OUT NOCOPY mstv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mstv_rec                     IN mstv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mstv_tbl                     IN mstv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mstv_rec                     IN mstv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mstv_tbl                     IN mstv_tbl_type);
END OKL_MST_PVT;

 

/
