--------------------------------------------------------
--  DDL for Package OKC_CIM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CIM_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCSCIMS.pls 120.0 2005/05/25 22:40:38 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE cim_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    cle_id                         NUMBER := OKC_API.G_MISS_NUM,
    chr_id                         NUMBER := OKC_API.G_MISS_NUM,
    cle_id_for                     NUMBER := OKC_API.G_MISS_NUM,
    dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM,
    object1_id1                    OKC_K_ITEMS.OBJECT1_ID1%TYPE := OKC_API.G_MISS_CHAR,
    object1_id2                    OKC_K_ITEMS.OBJECT1_ID2%TYPE := OKC_API.G_MISS_CHAR,
    jtot_object1_code              OKC_K_ITEMS.JTOT_OBJECT1_CODE%TYPE := OKC_API.G_MISS_CHAR,
    uom_code                       OKC_K_ITEMS.UOM_CODE%TYPE := OKC_API.G_MISS_CHAR,
    exception_yn                   OKC_K_ITEMS.EXCEPTION_YN%TYPE := OKC_API.G_MISS_CHAR,
    number_of_items                NUMBER := OKC_API.G_MISS_NUM,
    priced_item_yn                 OKC_K_ITEMS.PRICED_ITEM_YN%TYPE := OKC_API.G_MISS_CHAR,
    upg_orig_system_ref            OKC_K_ITEMS.UPG_ORIG_SYSTEM_REF%TYPE := OKC_API.G_MISS_CHAR,
    upg_orig_system_ref_id         NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_K_ITEMS.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_K_ITEMS.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    request_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_application_id         NUMBER := OKC_API.G_MISS_NUM,
    PROGRAM_UPDATE_DATE            OKC_K_ITEMS.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE);

  g_miss_cim_rec                          cim_rec_type;
  TYPE cim_tbl_type IS TABLE OF cim_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE cimv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    cle_id                         NUMBER := OKC_API.G_MISS_NUM,
    chr_id                         NUMBER := OKC_API.G_MISS_NUM,
    cle_id_for                     NUMBER := OKC_API.G_MISS_NUM,
    dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM,
    object1_id1                    OKC_K_ITEMS_V.OBJECT1_ID1%TYPE := OKC_API.G_MISS_CHAR,
    object1_id2                    OKC_K_ITEMS_V.OBJECT1_ID2%TYPE := OKC_API.G_MISS_CHAR,
    jtot_object1_code              OKC_K_ITEMS_V.JTOT_OBJECT1_CODE%TYPE := OKC_API.G_MISS_CHAR,
    uom_code                       OKC_K_ITEMS_V.UOM_CODE%TYPE := OKC_API.G_MISS_CHAR,
    exception_yn                   OKC_K_ITEMS_V.EXCEPTION_YN%TYPE := OKC_API.G_MISS_CHAR,
    number_of_items                NUMBER := OKC_API.G_MISS_NUM,
    upg_orig_system_ref            OKC_K_ITEMS_V.UPG_ORIG_SYSTEM_REF%TYPE := OKC_API.G_MISS_CHAR,
    upg_orig_system_ref_id         NUMBER := OKC_API.G_MISS_NUM,
    priced_item_yn                 OKC_K_ITEMS_V.PRICED_ITEM_YN%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_K_ITEMS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_K_ITEMS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    request_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_application_id         NUMBER := OKC_API.G_MISS_NUM,
    PROGRAM_UPDATE_DATE            OKC_K_ITEMS_V.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE);

    g_miss_cimv_rec                cimv_rec_type;
  TYPE cimv_tbl_type IS TABLE OF cimv_rec_type
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
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_CIM_PVT';
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
    p_cimv_rec                     IN cimv_rec_type,
    x_cimv_rec                     OUT NOCOPY cimv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cimv_tbl                     IN cimv_tbl_type,
    x_cimv_tbl                     OUT NOCOPY cimv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cimv_rec                     IN cimv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cimv_tbl                     IN cimv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cimv_rec                     IN cimv_rec_type,
    x_cimv_rec                     OUT NOCOPY cimv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cimv_tbl                     IN cimv_tbl_type,
    x_cimv_tbl                     OUT NOCOPY cimv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cimv_rec                     IN cimv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cimv_tbl                     IN cimv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cimv_rec                     IN cimv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cimv_tbl                     IN cimv_tbl_type);

  PROCEDURE INSERT_ROW_UPG(x_return_status OUT NOCOPY VARCHAR2, p_cimv_tbl cimv_tbl_type);

  FUNCTION create_version(
    p_chr_id					IN NUMBER,
    p_major_version				IN NUMBER) RETURN VARCHAR2;

  FUNCTION restore_version(
    p_chr_id					IN NUMBER,
    p_major_version				IN NUMBER) RETURN VARCHAR2;

END OKC_CIM_PVT;

 

/
