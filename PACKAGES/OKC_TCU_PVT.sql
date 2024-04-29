--------------------------------------------------------
--  DDL for Package OKC_TCU_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_TCU_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCSTCUS.pls 120.0 2005/05/25 23:10:54 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  G_UPPERCASE_REQUIRED         CONSTANT   VARCHAR2(200) := 'OKC_UPPER_CASE_REQUIRED';
  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'SQLcode';
  --G_UNQS                       CONSTANT   VARCHAR2(200) := 'OKC_VALUES_NOT_UNIQUE';
  G_UNQS1                       CONSTANT   VARCHAR2(200) := 'OKC_TCE_UOM_CODE_NOT_UNIQUE';
  G_UNQS2                       CONSTANT   VARCHAR2(200) := 'OKC_QTY_UOM_CODE_NOT_UNIQUE';
  G_RETURN_STATUS                         VARCHAR2(1)   :=  OKC_API.G_RET_STS_SUCCESS;
  G_EXCEPTION_HALT_VALIDATION  EXCEPTION;
  G_RECORD_STATUS                         VARCHAR2(1) := OKC_API.G_MISS_CHAR;
  G_QUANTITY                         NUMBER  := OKC_API.G_MISS_NUM;
  TYPE tcu_rec_type IS RECORD (
    tce_code                       OKC_TIME_CODE_UNITS_B.TCE_CODE%TYPE := OKC_API.G_MISS_CHAR,
    uom_code                OKC_TIME_CODE_UNITS_B.uom_code%TYPE := OKC_API.G_MISS_CHAR,
    quantity                       NUMBER := OKC_API.G_MISS_NUM,
    active_flag                    OKC_TIME_CODE_UNITS_B.ACTIVE_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_TIME_CODE_UNITS_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_TIME_CODE_UNITS_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    attribute_category             OKC_TIME_CODE_UNITS_B.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_TIME_CODE_UNITS_B.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_TIME_CODE_UNITS_B.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_TIME_CODE_UNITS_B.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_TIME_CODE_UNITS_B.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_TIME_CODE_UNITS_B.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_TIME_CODE_UNITS_B.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_TIME_CODE_UNITS_B.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_TIME_CODE_UNITS_B.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_TIME_CODE_UNITS_B.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_TIME_CODE_UNITS_B.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_TIME_CODE_UNITS_B.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_TIME_CODE_UNITS_B.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_TIME_CODE_UNITS_B.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_TIME_CODE_UNITS_B.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_TIME_CODE_UNITS_B.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR);
  g_miss_tcu_rec                          tcu_rec_type;
  TYPE tcu_tbl_type IS TABLE OF tcu_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE OkcTimeCodeUnitsTlRecType IS RECORD (
    uom_code                OKC_TIME_CODE_UNITS_TL.uom_code%TYPE := OKC_API.G_MISS_CHAR,
    tce_code                       OKC_TIME_CODE_UNITS_TL.TCE_CODE%TYPE := OKC_API.G_MISS_CHAR,
    language                       OKC_TIME_CODE_UNITS_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR,
    source_lang                    OKC_TIME_CODE_UNITS_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR,
    sfwt_flag                      OKC_TIME_CODE_UNITS_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    short_description              OKC_TIME_CODE_UNITS_TL.SHORT_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKC_TIME_CODE_UNITS_TL.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    comments                       OKC_TIME_CODE_UNITS_TL.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_TIME_CODE_UNITS_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_TIME_CODE_UNITS_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  GMissOkcTimeCodeUnitsTlRec              OkcTimeCodeUnitsTlRecType;
  TYPE OkcTimeCodeUnitsTlTblType IS TABLE OF OkcTimeCodeUnitsTlRecType
        INDEX BY BINARY_INTEGER;
  TYPE tcuv_rec_type IS RECORD (
    uom_code                OKC_TIME_CODE_UNITS_V.uom_code%TYPE := OKC_API.G_MISS_CHAR,
    tce_code                       OKC_TIME_CODE_UNITS_V.TCE_CODE%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    sfwt_flag                      OKC_TIME_CODE_UNITS_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    quantity                       NUMBER := OKC_API.G_MISS_NUM,
    active_flag                    OKC_TIME_CODE_UNITS_V.ACTIVE_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    short_description              OKC_TIME_CODE_UNITS_V.SHORT_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKC_TIME_CODE_UNITS_V.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    comments                       OKC_TIME_CODE_UNITS_V.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category             OKC_TIME_CODE_UNITS_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_TIME_CODE_UNITS_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_TIME_CODE_UNITS_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_TIME_CODE_UNITS_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_TIME_CODE_UNITS_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_TIME_CODE_UNITS_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_TIME_CODE_UNITS_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_TIME_CODE_UNITS_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_TIME_CODE_UNITS_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_TIME_CODE_UNITS_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_TIME_CODE_UNITS_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_TIME_CODE_UNITS_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_TIME_CODE_UNITS_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_TIME_CODE_UNITS_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_TIME_CODE_UNITS_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_TIME_CODE_UNITS_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_TIME_CODE_UNITS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_TIME_CODE_UNITS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_tcuv_rec                         tcuv_rec_type;
  TYPE tcuv_tbl_type IS TABLE OF tcuv_rec_type
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
  G_COL_NAME_TOKEN1		CONSTANT VARCHAR2(30) := 'COL_NAME1';
  G_COL_NAME_TOKEN2		CONSTANT VARCHAR2(30) := 'COL_NAME2';
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_TCU_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE add_language;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcuv_rec                     IN tcuv_rec_type,
    x_tcuv_rec                     OUT NOCOPY tcuv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcuv_tbl                     IN tcuv_tbl_type,
    x_tcuv_tbl                     OUT NOCOPY tcuv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcuv_rec                     IN tcuv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcuv_tbl                     IN tcuv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcuv_rec                     IN tcuv_rec_type,
    x_tcuv_rec                     OUT NOCOPY tcuv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcuv_tbl                     IN tcuv_tbl_type,
    x_tcuv_tbl                     OUT NOCOPY tcuv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcuv_rec                     IN tcuv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcuv_tbl                     IN tcuv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcuv_rec                     IN tcuv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcuv_tbl                     IN tcuv_tbl_type);

END OKC_TCU_PVT;

 

/
