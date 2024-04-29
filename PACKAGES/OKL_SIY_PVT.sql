--------------------------------------------------------
--  DDL for Package OKL_SIY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SIY_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSSIYS.pls 115.4 2002/07/22 23:17:43 mvasudev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE siy_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    yield_name                     OKL_SIF_YIELDS.YIELD_NAME%TYPE := OKC_API.G_MISS_CHAR,
    sif_id                         NUMBER := OKC_API.G_MISS_NUM,
    method                         OKL_SIF_YIELDS.METHOD%TYPE := OKC_API.G_MISS_CHAR,
    array_type                     OKL_SIF_YIELDS.ARRAY_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    roe_type                       OKL_SIF_YIELDS.ROE_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    roe_base                       OKL_SIF_YIELDS.ROE_BASE%TYPE := OKC_API.G_MISS_CHAR,
    compounded_method              OKL_SIF_YIELDS.COMPOUNDED_METHOD%TYPE := OKC_API.G_MISS_CHAR,
    target_value                   NUMBER := OKC_API.G_MISS_NUM,
    index_number                   NUMBER := OKC_API.G_MISS_NUM,
    nominal_yn                     OKL_SIF_YIELDS.NOMINAL_YN%TYPE := OKC_API.G_MISS_CHAR,
    -- 04/29/2002, mvasudev
    -- added for "Restructure" requirements
    pre_tax_yn                      OKL_SIF_YIELDS.PRE_TAX_YN%TYPE := OKC_API.G_MISS_CHAR,
	-- mvasudev, 06/26/2002
    siy_type                       OKL_SIF_YIELDS.siy_type%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute01   OKL_SIF_YIELDS.STREAM_INTERFACE_ATTRIBUTE01%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute02   OKL_SIF_YIELDS.STREAM_INTERFACE_ATTRIBUTE02%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute03   OKL_SIF_YIELDS.STREAM_INTERFACE_ATTRIBUTE03%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute04   OKL_SIF_YIELDS.STREAM_INTERFACE_ATTRIBUTE04%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute05   OKL_SIF_YIELDS.STREAM_INTERFACE_ATTRIBUTE05%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute06   OKL_SIF_YIELDS.STREAM_INTERFACE_ATTRIBUTE06%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute07   OKL_SIF_YIELDS.STREAM_INTERFACE_ATTRIBUTE07%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute08   OKL_SIF_YIELDS.STREAM_INTERFACE_ATTRIBUTE08%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute09   OKL_SIF_YIELDS.STREAM_INTERFACE_ATTRIBUTE09%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute10   OKL_SIF_YIELDS.STREAM_INTERFACE_ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute11   OKL_SIF_YIELDS.STREAM_INTERFACE_ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute12   OKL_SIF_YIELDS.STREAM_INTERFACE_ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute13   OKL_SIF_YIELDS.STREAM_INTERFACE_ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute14   OKL_SIF_YIELDS.STREAM_INTERFACE_ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute15   OKL_SIF_YIELDS.STREAM_INTERFACE_ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_SIF_YIELDS.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_date               OKL_SIF_YIELDS.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_siy_rec                          siy_rec_type;
  TYPE siy_tbl_type IS TABLE OF siy_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE siyv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    yield_name                     OKL_SIF_YIELDS_V.YIELD_NAME%TYPE := OKC_API.G_MISS_CHAR,
    sif_id                         NUMBER := OKC_API.G_MISS_NUM,
    method                         OKL_SIF_YIELDS_V.METHOD%TYPE := OKC_API.G_MISS_CHAR,
    array_type                     OKL_SIF_YIELDS_V.ARRAY_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    roe_type                       OKL_SIF_YIELDS_V.ROE_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    roe_base                       OKL_SIF_YIELDS_V.ROE_BASE%TYPE := OKC_API.G_MISS_CHAR,
    compounded_method              OKL_SIF_YIELDS_V.COMPOUNDED_METHOD%TYPE := OKC_API.G_MISS_CHAR,
    target_value                   NUMBER := OKC_API.G_MISS_NUM,
    index_number                   NUMBER := OKC_API.G_MISS_NUM,
    nominal_yn                     OKL_SIF_YIELDS_V.NOMINAL_YN%TYPE := OKC_API.G_MISS_CHAR,
    -- 04/29/2002, mvasudev
    -- added for "Restructure" requirements
    pre_tax_yn                      OKL_SIF_YIELDS_V.PRE_TAX_YN%TYPE := OKC_API.G_MISS_CHAR,
	-- mvasudev, 06/26/2002
    siy_type                       OKL_SIF_YIELDS_V.siy_type%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute01   OKL_SIF_YIELDS_V.STREAM_INTERFACE_ATTRIBUTE01%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute02   OKL_SIF_YIELDS_V.STREAM_INTERFACE_ATTRIBUTE02%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute03   OKL_SIF_YIELDS_V.STREAM_INTERFACE_ATTRIBUTE03%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute04   OKL_SIF_YIELDS_V.STREAM_INTERFACE_ATTRIBUTE04%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute05   OKL_SIF_YIELDS_V.STREAM_INTERFACE_ATTRIBUTE05%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute06   OKL_SIF_YIELDS_V.STREAM_INTERFACE_ATTRIBUTE06%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute07   OKL_SIF_YIELDS_V.STREAM_INTERFACE_ATTRIBUTE07%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute08   OKL_SIF_YIELDS_V.STREAM_INTERFACE_ATTRIBUTE08%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute09   OKL_SIF_YIELDS_V.STREAM_INTERFACE_ATTRIBUTE09%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute10   OKL_SIF_YIELDS_V.STREAM_INTERFACE_ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute11   OKL_SIF_YIELDS_V.STREAM_INTERFACE_ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute12   OKL_SIF_YIELDS_V.STREAM_INTERFACE_ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute13   OKL_SIF_YIELDS_V.STREAM_INTERFACE_ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute14   OKL_SIF_YIELDS_V.STREAM_INTERFACE_ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute15   OKL_SIF_YIELDS_V.STREAM_INTERFACE_ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_SIF_YIELDS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_date               OKL_SIF_YIELDS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_siyv_rec                         siyv_rec_type;
  TYPE siyv_tbl_type IS TABLE OF siyv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_OKC_APP			CONSTANT VARCHAR2(200) := OKC_API.G_APP_NAME;
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
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_SIY_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

  -- START CHANGE :  mvasudev -- 12/28/2001
  G_OKL_SQLERRM_TOKEN             	CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_OKL_SQLCODE_TOKEN             	CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_OKL_UNEXPECTED_ERROR          	CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_OKL_UNQS			CONSTANT VARCHAR2(200) := 'OKL_SIY_NOT_UNIQUE';

  -- 06/24/2002 , mvasudev, sno
  G_SIY_TYPE_YIELD		    CONSTANT VARCHAR2(200) := 'YLD';
  G_SIY_TYPE_INTEREST_RATE	CONSTANT VARCHAR2(200) := 'INT';
  -- end, mvasudev -- 04/23/2003

  -- Added Exception for Halt_validation
  --------------------------------------------------------------------------------
  -- ERRORS AND EXCEPTIONS
  --------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
  -- END change : mvasudev

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
    p_siyv_rec                     IN siyv_rec_type,
    x_siyv_rec                     OUT NOCOPY siyv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_siyv_tbl                     IN siyv_tbl_type,
    x_siyv_tbl                     OUT NOCOPY siyv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_siyv_rec                     IN siyv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_siyv_tbl                     IN siyv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_siyv_rec                     IN siyv_rec_type,
    x_siyv_rec                     OUT NOCOPY siyv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_siyv_tbl                     IN siyv_tbl_type,
    x_siyv_tbl                     OUT NOCOPY siyv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_siyv_rec                     IN siyv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_siyv_tbl                     IN siyv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_siyv_rec                     IN siyv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_siyv_tbl                     IN siyv_tbl_type);

END OKL_SIY_PVT;

 

/
