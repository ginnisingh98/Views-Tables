--------------------------------------------------------
--  DDL for Package OKL_ITI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ITI_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSITIS.pls 115.6 2002/12/07 18:53:29 avsingh noship $ */
-- Badrinath Kuchibholta
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE iti_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    tas_id                         NUMBER := OKC_API.G_MISS_NUM,
    tal_id                         NUMBER := OKC_API.G_MISS_NUM,
    kle_id                         NUMBER := OKC_API.G_MISS_NUM,
    tal_type                       OKL_TXL_ITM_INSTS.TAL_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    line_number                    NUMBER := OKC_API.G_MISS_NUM,
    instance_number_ib             OKL_TXL_ITM_INSTS.INSTANCE_NUMBER_IB%TYPE := OKC_API.G_MISS_CHAR,
    object_id1_new                 OKL_TXL_ITM_INSTS.OBJECT_ID1_NEW%TYPE := OKC_API.G_MISS_CHAR,
    object_id2_new                 OKL_TXL_ITM_INSTS.OBJECT_ID2_NEW%TYPE := OKC_API.G_MISS_CHAR,
    jtot_object_code_new           OKL_TXL_ITM_INSTS.JTOT_OBJECT_CODE_NEW%TYPE := OKC_API.G_MISS_CHAR,
    object_id1_old                 OKL_TXL_ITM_INSTS.OBJECT_ID1_OLD%TYPE := OKC_API.G_MISS_CHAR,
    object_id2_old                 OKL_TXL_ITM_INSTS.OBJECT_ID2_OLD%TYPE := OKC_API.G_MISS_CHAR,
    jtot_object_code_old           OKL_TXL_ITM_INSTS.JTOT_OBJECT_CODE_OLD%TYPE := OKC_API.G_MISS_CHAR,
    inventory_org_id               NUMBER := OKC_API.G_MISS_NUM,
    serial_number                  OKL_TXL_ITM_INSTS.SERIAL_NUMBER%TYPE := OKC_API.G_MISS_CHAR,
    mfg_serial_number_yn           OKL_TXL_ITM_INSTS.MFG_SERIAL_NUMBER_YN%TYPE := OKC_API.G_MISS_CHAR,
    inventory_item_id              NUMBER := OKC_API.G_MISS_NUM,
    inv_master_org_id              NUMBER := OKC_API.G_MISS_NUM,
    attribute_category             OKL_TXL_ITM_INSTS.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKL_TXL_ITM_INSTS.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKL_TXL_ITM_INSTS.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKL_TXL_ITM_INSTS.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKL_TXL_ITM_INSTS.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKL_TXL_ITM_INSTS.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKL_TXL_ITM_INSTS.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKL_TXL_ITM_INSTS.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKL_TXL_ITM_INSTS.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKL_TXL_ITM_INSTS.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKL_TXL_ITM_INSTS.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKL_TXL_ITM_INSTS.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKL_TXL_ITM_INSTS.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKL_TXL_ITM_INSTS.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKL_TXL_ITM_INSTS.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKL_TXL_ITM_INSTS.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_TXL_ITM_INSTS.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_TXL_ITM_INSTS.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    dnz_cle_id                     NUMBER := OKC_API.G_MISS_NUM,
--Bug# Bug# 2697681 schema change : 11.5.9 enhacement - split asset by serial numbers
    instance_id                    NUMBER := OKC_API.G_MISS_NUM,
    selected_for_split_flag        OKL_TXL_ITM_INSTS.SELECTED_FOR_SPLIT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    asd_id                         NUMBER := OKC_API.G_MISS_NUM);
  g_miss_iti_rec                   iti_rec_type;
  TYPE iti_tbl_type IS TABLE OF iti_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE itiv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    tas_id                         NUMBER := OKC_API.G_MISS_NUM,
    tal_id                         NUMBER := OKC_API.G_MISS_NUM,
    kle_id                         NUMBER := OKC_API.G_MISS_NUM,
    tal_type                       OKL_TXL_ITM_INSTS.TAL_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    line_number                    NUMBER := OKC_API.G_MISS_NUM,
    instance_number_ib             OKL_TXL_ITM_INSTS_V.INSTANCE_NUMBER_IB%TYPE := OKC_API.G_MISS_CHAR,
    object_id1_new                 OKL_TXL_ITM_INSTS_V.OBJECT_ID1_NEW%TYPE := OKC_API.G_MISS_CHAR,
    object_id2_new                 OKL_TXL_ITM_INSTS_V.OBJECT_ID2_NEW%TYPE := OKC_API.G_MISS_CHAR,
    jtot_object_code_new           OKL_TXL_ITM_INSTS_V.JTOT_OBJECT_CODE_NEW%TYPE := OKC_API.G_MISS_CHAR,
    object_id1_old                 OKL_TXL_ITM_INSTS_V.OBJECT_ID1_OLD%TYPE := OKC_API.G_MISS_CHAR,
    object_id2_old                 OKL_TXL_ITM_INSTS_V.OBJECT_ID2_OLD%TYPE := OKC_API.G_MISS_CHAR,
    jtot_object_code_old           OKL_TXL_ITM_INSTS_V.JTOT_OBJECT_CODE_OLD%TYPE := OKC_API.G_MISS_CHAR,
    inventory_org_id               NUMBER := OKC_API.G_MISS_NUM,
    serial_number                  OKL_TXL_ITM_INSTS_V.SERIAL_NUMBER%TYPE := OKC_API.G_MISS_CHAR,
    mfg_serial_number_yn           OKL_TXL_ITM_INSTS_V.MFG_SERIAL_NUMBER_YN%TYPE := OKC_API.G_MISS_CHAR,
    inventory_item_id              NUMBER := OKC_API.G_MISS_NUM,
    inv_master_org_id              NUMBER := OKC_API.G_MISS_NUM,
    attribute_category             OKL_TXL_ITM_INSTS_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKL_TXL_ITM_INSTS_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKL_TXL_ITM_INSTS_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKL_TXL_ITM_INSTS_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKL_TXL_ITM_INSTS_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKL_TXL_ITM_INSTS_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKL_TXL_ITM_INSTS_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKL_TXL_ITM_INSTS_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKL_TXL_ITM_INSTS_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKL_TXL_ITM_INSTS_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKL_TXL_ITM_INSTS_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKL_TXL_ITM_INSTS_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKL_TXL_ITM_INSTS_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKL_TXL_ITM_INSTS_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKL_TXL_ITM_INSTS_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKL_TXL_ITM_INSTS_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_TXL_ITM_INSTS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_TXL_ITM_INSTS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    dnz_cle_id                     NUMBER := OKC_API.G_MISS_NUM,
--Bug#Bug# 2697681 schema change : 11.5.9 enhacement - split asset by serial numbers
    instance_id                    NUMBER := OKC_API.G_MISS_NUM,
    selected_for_split_flag        OKL_TXL_ITM_INSTS_V.SELECTED_FOR_SPLIT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    asd_id                         NUMBER := OKC_API.G_MISS_NUM);
  g_miss_itiv_rec                  itiv_rec_type;
  TYPE itiv_tbl_type IS TABLE OF itiv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_ITI_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
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
    p_itiv_rec                     IN itiv_rec_type,
    x_itiv_rec                     OUT NOCOPY itiv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_itiv_tbl                     IN itiv_tbl_type,
    x_itiv_tbl                     OUT NOCOPY itiv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_itiv_rec                     IN itiv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_itiv_tbl                     IN itiv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_itiv_rec                     IN itiv_rec_type,
    x_itiv_rec                     OUT NOCOPY itiv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_itiv_tbl                     IN itiv_tbl_type,
    x_itiv_tbl                     OUT NOCOPY itiv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_itiv_rec                     IN itiv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_itiv_tbl                     IN itiv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_itiv_rec                     IN itiv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_itiv_tbl                     IN itiv_tbl_type);

END OKL_ITI_PVT;

 

/
