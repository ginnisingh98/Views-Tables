--------------------------------------------------------
--  DDL for Package OKL_AGB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AGB_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSAGBS.pls 115.1 2002/02/05 12:14:23 pkm ship       $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE agb_rec_type IS RECORD (
    id                         NUMBER := OKC_API.G_MISS_NUM,
    khr_id                     OKL_ACC_GROUP_BAL.KHR_ID%TYPE := OKC_API.G_MISS_NUM,
    object_version_number      NUMBER := OKC_API.G_MISS_NUM,
    date_balance               OKL_ACC_GROUP_BAL.DATE_BALANCE%TYPE := OKC_API.G_MISS_DATE,
    acc_group_id               OKL_ACC_GROUP_BAL.ACC_GROUP_ID%TYPE := OKC_API.G_MISS_NUM,
    amount                     NUMBER := OKC_API.G_MISS_NUM,
    created_by                 NUMBER := OKC_API.G_MISS_NUM,
    creation_date              OKL_ACC_GROUP_BAL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by            NUMBER := OKC_API.G_MISS_NUM,
    last_update_date           OKL_ACC_GROUP_BAL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login          NUMBER := OKC_API.G_MISS_NUM);

  g_miss_agb_rec               agb_rec_type;
  TYPE agb_tbl_type IS TABLE OF agb_rec_type
        INDEX BY BINARY_INTEGER;

  TYPE agbv_rec_type IS RECORD (
    id                         NUMBER := OKC_API.G_MISS_NUM,
    object_version_number      NUMBER := OKC_API.G_MISS_NUM,
    acc_group_id               OKL_ACC_GROUP_BAL_V.ACC_GROUP_ID%TYPE := OKC_API.G_MISS_NUM,
    khr_id                     OKL_ACC_GROUP_BAL_V.KHR_ID%TYPE := OKC_API.G_MISS_NUM,
    date_balance               OKL_ACC_GROUP_BAL_V.DATE_BALANCE%TYPE := OKC_API.G_MISS_DATE,
    amount                     NUMBER := OKC_API.G_MISS_NUM,
    created_by                 NUMBER := OKC_API.G_MISS_NUM,
    creation_date              OKL_ACC_GROUP_BAL_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by            NUMBER := OKC_API.G_MISS_NUM,
    last_update_date           OKL_ACC_GROUP_BAL_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login          NUMBER := OKC_API.G_MISS_NUM);

  g_miss_agbv_rec              agbv_rec_type;

  TYPE agbv_tbl_type IS TABLE OF agbv_rec_type
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
  G_INVALID_VALUE	        CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200):='OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';

  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'OKL_SQLcode';


  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_AGB_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_UNQS		        CONSTANT VARCHAR2(200) := 'OKL_AGB_ELEMENT_NOT_UNIQUE';

  ---------------------------------------------------------------------------

  -----------------  GLOBAL EXCEPTION
  --------------------------------------------------------

  G_EXCEPTION_HALT_VALIDATION EXCEPTION;

  --------------------------------------------------------------------------------------
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
    p_agbv_rec                     IN agbv_rec_type,
    x_agbv_rec                     OUT NOCOPY agbv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agbv_tbl                     IN agbv_tbl_type,
    x_agbv_tbl                     OUT NOCOPY agbv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agbv_rec                     IN agbv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agbv_tbl                     IN agbv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agbv_rec                     IN agbv_rec_type,
    x_agbv_rec                     OUT NOCOPY agbv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agbv_tbl                     IN agbv_tbl_type,
    x_agbv_tbl                     OUT NOCOPY agbv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agbv_rec                     IN agbv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agbv_tbl                     IN agbv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agbv_rec                     IN agbv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agbv_tbl                     IN agbv_tbl_type);

END OKL_AGB_PVT;

 

/
