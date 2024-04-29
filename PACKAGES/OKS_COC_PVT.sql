--------------------------------------------------------
--  DDL for Package OKS_COC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_COC_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSRCOCS.pls 120.0 2005/05/25 18:15:19 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE coc_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    cod_id                         NUMBER := OKC_API.G_MISS_NUM,
    cro_code                       OKS_K_ORDER_CONTACTS.CRO_CODE%TYPE := OKC_API.G_MISS_CHAR,
    jtot_object_code               OKS_K_ORDER_CONTACTS.JTOT_OBJECT_CODE%TYPE := OKC_API.G_MISS_CHAR,
    object1_id1                    OKS_K_ORDER_CONTACTS.OBJECT1_ID1%TYPE := OKC_API.G_MISS_CHAR,
    object1_id2                    OKS_K_ORDER_CONTACTS.OBJECT1_ID2%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKS_K_ORDER_CONTACTS.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKS_K_ORDER_CONTACTS.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE);
    --security_group_id              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_coc_rec                          coc_rec_type;
  TYPE coc_tbl_type IS TABLE OF coc_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE COCV_REC_TYPE IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    cod_id                         NUMBER := OKC_API.G_MISS_NUM,
    cro_code                       OKS_K_ORDER_CONTACTS_V.CRO_CODE%TYPE := OKC_API.G_MISS_CHAR,
    jtot_object_code               OKS_K_ORDER_CONTACTS_V.JTOT_OBJECT_CODE%TYPE := OKC_API.G_MISS_CHAR,
    object1_id1                    OKS_K_ORDER_CONTACTS_V.OBJECT1_ID1%TYPE := OKC_API.G_MISS_CHAR,
    object1_id2                    OKS_K_ORDER_CONTACTS_V.OBJECT1_ID2%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKS_K_ORDER_CONTACTS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKS_K_ORDER_CONTACTS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE);
  G_Miss_COCV_REC              	COCV_REC_TYPE;
  TYPE COCV_TBL_TYPE IS TABLE OF COCV_REC_TYPE
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
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKS_ORD_CONTACTS_UNEXP_ERR';
  G_SQLCODE_TOKEN              CONSTANT VARCHAR2(200) := 'SQLcode';
  G_SQLERRM_TOKEN              CONSTANT VARCHAR2(200) := 'SQLerrm';
---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION 	EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKS_COC_PVT';
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
    p_cocv_rec   			     IN  COCV_REC_TYPE,
    x_cocv_rec   OUT NOCOPY COCV_REC_TYPE);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cocv_tbl   			     IN COCV_TBL_TYPE,
    x_cocv_tbl   OUT NOCOPY COCV_TBL_TYPE);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cocv_rec   			     IN cocv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cocv_tbl   				IN cocv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cocv_rec   			     IN COCV_REC_TYPE,
    x_cocv_rec   			     OUT NOCOPY COCV_REC_TYPE);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cocv_tbl   			     IN cocv_tbl_Type,
    x_cocv_tbl   			     OUT NOCOPY cocv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cocv_rec   				IN COCV_REC_TYPE);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cocv_tbl   				IN cocv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cocv_rec   				IN COCV_REC_TYPE);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cocv_tbl   				IN cocv_tbl_type);

END OKS_COC_PVT;

 

/
