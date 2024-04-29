--------------------------------------------------------
--  DDL for Package OKS_AVL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_AVL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSSAVLS.pls 120.0 2005/05/25 18:16:31 appldev noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE sav_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object1_id1                    OKS_SERV_AVAILS.OBJECT1_ID1%TYPE := OKC_API.G_MISS_CHAR,
    object1_id2                    OKS_SERV_AVAILS.OBJECT1_ID2%TYPE := OKC_API.G_MISS_CHAR,
    jtot_object1_code              OKS_SERV_AVAILS_V.JTOT_OBJECT1_CODE%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKS_SERV_AVAILS.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKS_SERV_AVAILS.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    general_yn                     OKS_SERV_AVAILS.GENERAL_YN%TYPE := OKC_API.G_MISS_CHAR,
    except_object_type             OKS_SERV_AVAILS.EXCEPT_OBJECT_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    start_date_active              OKS_SERV_AVAILS.START_DATE_ACTIVE%TYPE := OKC_API.G_MISS_DATE,
    end_date_active                OKS_SERV_AVAILS.END_DATE_ACTIVE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    attribute_category             OKS_SERV_AVAILS.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKS_SERV_AVAILS.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKS_SERV_AVAILS.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKS_SERV_AVAILS.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKS_SERV_AVAILS.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKS_SERV_AVAILS.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKS_SERV_AVAILS.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKS_SERV_AVAILS.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKS_SERV_AVAILS.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKS_SERV_AVAILS.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKS_SERV_AVAILS.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKS_SERV_AVAILS.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKS_SERV_AVAILS.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKS_SERV_AVAILS.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKS_SERV_AVAILS.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKS_SERV_AVAILS.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR);
  g_miss_sav_rec                          sav_rec_type;
  TYPE sav_tbl_type IS TABLE OF sav_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE savv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object1_id1                    OKS_SERV_AVAILS_V.OBJECT1_ID1%TYPE := OKC_API.G_MISS_CHAR,
    object1_id2                    OKS_SERV_AVAILS_V.OBJECT1_ID2%TYPE := OKC_API.G_MISS_CHAR,
    jtot_object1_code              OKS_SERV_AVAILS_V.JTOT_OBJECT1_CODE%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKS_SERV_AVAILS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKS_SERV_AVAILS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    general_yn                     OKS_SERV_AVAILS_V.GENERAL_YN%TYPE := OKC_API.G_MISS_CHAR,
    except_object_type             OKS_SERV_AVAILS_V.EXCEPT_OBJECT_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    start_date_active              OKS_SERV_AVAILS_V.START_DATE_ACTIVE%TYPE := OKC_API.G_MISS_DATE,
    end_date_active                OKS_SERV_AVAILS_V.END_DATE_ACTIVE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    attribute_category             OKS_SERV_AVAILS_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKS_SERV_AVAILS_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKS_SERV_AVAILS_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKS_SERV_AVAILS_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKS_SERV_AVAILS_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKS_SERV_AVAILS_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKS_SERV_AVAILS_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKS_SERV_AVAILS_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKS_SERV_AVAILS_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKS_SERV_AVAILS_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKS_SERV_AVAILS_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKS_SERV_AVAILS_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKS_SERV_AVAILS_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKS_SERV_AVAILS_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKS_SERV_AVAILS_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKS_SERV_AVAILS_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR);
  g_miss_savv_rec                         savv_rec_type;
  TYPE savv_tbl_type IS TABLE OF savv_rec_type
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
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKS_SERVICE_AVAILABILITY_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN              CONSTANT VARCHAR2(200) := 'SQLcode';
  G_SQLERRM_TOKEN              CONSTANT VARCHAR2(200) := 'SQLerrm';

---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION 	EXCEPTION;


  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKS_AVL_PVT';
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
    p_savv_rec                     IN savv_rec_type,
    x_savv_rec                     OUT NOCOPY savv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_tbl                     IN savv_tbl_type,
    x_savv_tbl                     OUT NOCOPY savv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_rec                     IN savv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_tbl                     IN savv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_rec                     IN savv_rec_type,
    x_savv_rec                     OUT NOCOPY savv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_tbl                     IN savv_tbl_type,
    x_savv_tbl                     OUT NOCOPY savv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_rec                     IN savv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_tbl                     IN savv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_rec                     IN savv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_tbl                     IN savv_tbl_type);
PROCEDURE INSERT_ROW_UPG(p_savv_tbl savv_tbl_type );

END OKS_AVL_PVT;

 

/
