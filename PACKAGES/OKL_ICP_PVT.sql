--------------------------------------------------------
--  DDL for Package OKL_ICP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ICP_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSICPS.pls 120.3 2005/07/07 22:12:51 smadhava noship $ */

  -----------------------------------------------------------------------------
  -- PACKAGE CONSTANTS
  -----------------------------------------------------------------------------
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_ICP_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_API_VERSION          CONSTANT NUMBER        := 1;
  G_FALSE                CONSTANT VARCHAR2(1)   := FND_API.G_FALSE;
  G_TRUE                 CONSTANT VARCHAR2(1)   := FND_API.G_TRUE;
  G_DB_ERROR             CONSTANT VARCHAR2(12)  := 'OKL_DB_ERROR';
  G_PROG_NAME_TOKEN      CONSTANT VARCHAR2(9)   := 'PROG_NAME';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(7)   := 'SQLCODE';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(7)   := 'SQLERRM';
  G_RET_STS_SUCCESS      CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_UNEXP_ERROR  CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR        CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_ERROR;
  G_MISS_CHAR            CONSTANT VARCHAR2(1)   := FND_API.G_MISS_CHAR;
  G_MISS_NUM             CONSTANT NUMBER        := FND_API.G_MISS_NUM;
  G_MISS_DATE            CONSTANT DATE          := FND_API.G_MISS_DATE;

  G_FND_APP                      CONSTANT VARCHAR2(200) := OKL_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC   CONSTANT VARCHAR2(200) := OKL_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED          CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED          CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED     CONSTANT VARCHAR2(200) := OKL_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE               CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE                CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN               CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN           CONSTANT VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN            CONSTANT VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200) := 'OKS_SERVICE_AVAILABILITY_UNEXPECTED_ERROR';

  ---------------------------------------------------------------------------
  -- DATA STRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_ITM_CAT_RV_PRCS_V Record Spec
  TYPE icpv_rec_type IS RECORD (
     id                             NUMBER
    ,object_version_number          NUMBER
    ,cat_id1                        NUMBER
    ,cat_id2                        OKL_ITM_CAT_RV_PRCS_V.CAT_ID2%TYPE
    ,term_in_months                 NUMBER
    ,residual_value_percent         NUMBER
    ,item_residual_id               OKL_ITM_CAT_RV_PRCS_V.ITEM_RESIDUAL_ID%TYPE
    ,sts_code                       OKL_ITM_CAT_RV_PRCS_V.STS_CODE%TYPE
    ,version_number                 OKL_ITM_CAT_RV_PRCS_V.VERSION_NUMBER%TYPE
    ,start_date                     OKL_ITM_CAT_RV_PRCS_V.START_DATE%TYPE
    ,end_date                       OKL_ITM_CAT_RV_PRCS_V.END_DATE%TYPE
    ,created_by                     NUMBER
    ,creation_date                  OKL_ITM_CAT_RV_PRCS_V.CREATION_DATE%TYPE
    ,last_updated_by                NUMBER
    ,last_update_date               OKL_ITM_CAT_RV_PRCS_V.LAST_UPDATE_DATE%TYPE
    ,last_update_login              NUMBER
    ,attribute_category             OKL_ITM_CAT_RV_PRCS_V.ATTRIBUTE_CATEGORY%TYPE
    ,attribute1                     OKL_ITM_CAT_RV_PRCS_V.ATTRIBUTE1%TYPE
    ,attribute2                     OKL_ITM_CAT_RV_PRCS_V.ATTRIBUTE2%TYPE
    ,attribute3                     OKL_ITM_CAT_RV_PRCS_V.ATTRIBUTE3%TYPE
    ,attribute4                     OKL_ITM_CAT_RV_PRCS_V.ATTRIBUTE4%TYPE
    ,attribute5                     OKL_ITM_CAT_RV_PRCS_V.ATTRIBUTE5%TYPE
    ,attribute6                     OKL_ITM_CAT_RV_PRCS_V.ATTRIBUTE6%TYPE
    ,attribute7                     OKL_ITM_CAT_RV_PRCS_V.ATTRIBUTE7%TYPE
    ,attribute8                     OKL_ITM_CAT_RV_PRCS_V.ATTRIBUTE8%TYPE
    ,attribute9                     OKL_ITM_CAT_RV_PRCS_V.ATTRIBUTE9%TYPE
    ,attribute10                    OKL_ITM_CAT_RV_PRCS_V.ATTRIBUTE10%TYPE
    ,attribute11                    OKL_ITM_CAT_RV_PRCS_V.ATTRIBUTE11%TYPE
    ,attribute12                    OKL_ITM_CAT_RV_PRCS_V.ATTRIBUTE12%TYPE
    ,attribute13                    OKL_ITM_CAT_RV_PRCS_V.ATTRIBUTE13%TYPE
    ,attribute14                    OKL_ITM_CAT_RV_PRCS_V.ATTRIBUTE14%TYPE
    ,attribute15                    OKL_ITM_CAT_RV_PRCS_V.ATTRIBUTE15%TYPE);

  TYPE icpv_tbl_type IS TABLE OF icpv_rec_type INDEX BY BINARY_INTEGER;

  -- OKL_ITM_CAT_RV_PRCS Record Spec
  TYPE icp_rec_type IS RECORD (
     id                             NUMBER
    ,object_version_number          NUMBER
    ,cat_id1                        NUMBER
    ,cat_id2                        OKL_ITM_CAT_RV_PRCS.CAT_ID2%TYPE
    ,term_in_months                 NUMBER
    ,residual_value_percent         NUMBER
    ,start_date                     OKL_ITM_CAT_RV_PRCS.START_DATE%TYPE
    ,end_date                       OKL_ITM_CAT_RV_PRCS.END_DATE%TYPE
    ,created_by                     NUMBER
    ,creation_date                  OKL_ITM_CAT_RV_PRCS.CREATION_DATE%TYPE
    ,last_updated_by                NUMBER
    ,last_update_date               OKL_ITM_CAT_RV_PRCS.LAST_UPDATE_DATE%TYPE
    ,last_update_login              NUMBER
    ,attribute_category             OKL_ITM_CAT_RV_PRCS.ATTRIBUTE_CATEGORY%TYPE
    ,attribute1                     OKL_ITM_CAT_RV_PRCS.ATTRIBUTE1%TYPE
    ,attribute2                     OKL_ITM_CAT_RV_PRCS.ATTRIBUTE2%TYPE
    ,attribute3                     OKL_ITM_CAT_RV_PRCS.ATTRIBUTE3%TYPE
    ,attribute4                     OKL_ITM_CAT_RV_PRCS.ATTRIBUTE4%TYPE
    ,attribute5                     OKL_ITM_CAT_RV_PRCS.ATTRIBUTE5%TYPE
    ,attribute6                     OKL_ITM_CAT_RV_PRCS.ATTRIBUTE6%TYPE
    ,attribute7                     OKL_ITM_CAT_RV_PRCS.ATTRIBUTE7%TYPE
    ,attribute8                     OKL_ITM_CAT_RV_PRCS.ATTRIBUTE8%TYPE
    ,attribute9                     OKL_ITM_CAT_RV_PRCS.ATTRIBUTE9%TYPE
    ,attribute10                    OKL_ITM_CAT_RV_PRCS.ATTRIBUTE10%TYPE
    ,attribute11                    OKL_ITM_CAT_RV_PRCS.ATTRIBUTE11%TYPE
    ,attribute12                    OKL_ITM_CAT_RV_PRCS.ATTRIBUTE12%TYPE
    ,attribute13                    OKL_ITM_CAT_RV_PRCS.ATTRIBUTE13%TYPE
    ,attribute14                    OKL_ITM_CAT_RV_PRCS.ATTRIBUTE14%TYPE
    ,attribute15                    OKL_ITM_CAT_RV_PRCS.ATTRIBUTE15%TYPE);

  TYPE icp_tbl_type IS TABLE OF icp_rec_type INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  -- PROGRAM UNITS
  ---------------------------------------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_icpv_rec                     IN icpv_rec_type,
    x_icpv_rec                     OUT NOCOPY icpv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_icpv_tbl                     IN icpv_tbl_type,
    x_icpv_tbl                     OUT NOCOPY icpv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_icpv_rec                     IN icpv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_icpv_tbl                     IN icpv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_icpv_rec                     IN icpv_rec_type,
    x_icpv_rec                     OUT NOCOPY icpv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_icpv_tbl                     IN icpv_tbl_type,
    x_icpv_tbl                     OUT NOCOPY icpv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_icpv_rec                     IN icpv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_icpv_tbl                     IN icpv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_icpv_rec                     IN icpv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_icpv_tbl                     IN icpv_tbl_type);

END OKL_ICP_PVT;

 

/
