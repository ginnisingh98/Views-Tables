--------------------------------------------------------
--  DDL for Package OKL_SVF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SVF_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSSVFS.pls 120.2 2006/07/31 13:11:41 varangan noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE svf_rec_type IS RECORD (
    id                             NUMBER := Okl_Api.G_MISS_NUM,
    srv_code                       OKL_SERVICE_FEES_B.SRV_CODE%TYPE := Okl_Api.G_MISS_CHAR,
    object_version_number          NUMBER := Okl_Api.G_MISS_NUM,
    amount                         NUMBER := Okl_Api.G_MISS_NUM,
    start_date                     OKL_SERVICE_FEES_B.START_DATE%TYPE := Okl_Api.G_MISS_DATE,
    end_date                       OKL_SERVICE_FEES_B.END_DATE%TYPE := Okl_Api.G_MISS_DATE,
    organization_id		           NUMBER := Okl_Api.G_MISS_NUM,
    attribute_category             OKL_SERVICE_FEES_B.ATTRIBUTE_CATEGORY%TYPE := Okl_Api.G_MISS_CHAR,
    attribute1                     OKL_SERVICE_FEES_B.ATTRIBUTE1%TYPE := Okl_Api.G_MISS_CHAR,
    attribute2                     OKL_SERVICE_FEES_B.ATTRIBUTE2%TYPE := Okl_Api.G_MISS_CHAR,
    attribute3                     OKL_SERVICE_FEES_B.ATTRIBUTE3%TYPE := Okl_Api.G_MISS_CHAR,
    attribute4                     OKL_SERVICE_FEES_B.ATTRIBUTE4%TYPE := Okl_Api.G_MISS_CHAR,
    attribute5                     OKL_SERVICE_FEES_B.ATTRIBUTE5%TYPE := Okl_Api.G_MISS_CHAR,
    attribute6                     OKL_SERVICE_FEES_B.ATTRIBUTE6%TYPE := Okl_Api.G_MISS_CHAR,
    attribute7                     OKL_SERVICE_FEES_B.ATTRIBUTE7%TYPE := Okl_Api.G_MISS_CHAR,
    attribute8                     OKL_SERVICE_FEES_B.ATTRIBUTE8%TYPE := Okl_Api.G_MISS_CHAR,
    attribute9                     OKL_SERVICE_FEES_B.ATTRIBUTE9%TYPE := Okl_Api.G_MISS_CHAR,
    attribute10                    OKL_SERVICE_FEES_B.ATTRIBUTE10%TYPE := Okl_Api.G_MISS_CHAR,
    attribute11                    OKL_SERVICE_FEES_B.ATTRIBUTE11%TYPE := Okl_Api.G_MISS_CHAR,
    attribute12                    OKL_SERVICE_FEES_B.ATTRIBUTE12%TYPE := Okl_Api.G_MISS_CHAR,
    attribute13                    OKL_SERVICE_FEES_B.ATTRIBUTE13%TYPE := Okl_Api.G_MISS_CHAR,
    attribute14                    OKL_SERVICE_FEES_B.ATTRIBUTE14%TYPE := Okl_Api.G_MISS_CHAR,
    attribute15                    OKL_SERVICE_FEES_B.ATTRIBUTE15%TYPE := Okl_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okl_Api.G_MISS_NUM,
    creation_date                  OKL_SERVICE_FEES_B.CREATION_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_Api.G_MISS_NUM,
    last_update_date               OKL_SERVICE_FEES_B.LAST_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_Api.G_MISS_NUM,
    org_id                        NUMBER := Okl_Api.G_MISS_NUM);
  g_miss_svf_rec                          svf_rec_type;
  TYPE svf_tbl_type IS TABLE OF svf_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE okl_service_fees_tl_rec_type IS RECORD (
    id                             NUMBER := Okl_Api.G_MISS_NUM,
    LANGUAGE                       OKL_SERVICE_FEES_TL.LANGUAGE%TYPE := Okl_Api.G_MISS_CHAR,
    source_lang                    OKL_SERVICE_FEES_TL.SOURCE_LANG%TYPE := Okl_Api.G_MISS_CHAR,
    sfwt_flag                      OKL_SERVICE_FEES_TL.SFWT_FLAG%TYPE := Okl_Api.G_MISS_CHAR,
    name                           OKL_SERVICE_FEES_TL.NAME%TYPE := Okl_Api.G_MISS_CHAR,
    description                    OKL_SERVICE_FEES_TL.DESCRIPTION%TYPE := Okl_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okl_Api.G_MISS_NUM,
    creation_date                  OKL_SERVICE_FEES_TL.CREATION_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_Api.G_MISS_NUM,
    last_update_date               OKL_SERVICE_FEES_TL.LAST_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_Api.G_MISS_NUM);
  g_miss_okl_service_fees_tl_rec          okl_service_fees_tl_rec_type;
  TYPE okl_service_fees_tl_tbl_type IS TABLE OF okl_service_fees_tl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE svfv_rec_type IS RECORD (
    id                             NUMBER := Okl_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okl_Api.G_MISS_NUM,
    sfwt_flag                      OKL_SERVICE_FEES_V.SFWT_FLAG%TYPE := Okl_Api.G_MISS_CHAR,
    srv_code                       OKL_SERVICE_FEES_V.SRV_CODE%TYPE := Okl_Api.G_MISS_CHAR,
    name                           OKL_SERVICE_FEES_V.NAME%TYPE := Okl_Api.G_MISS_CHAR,
    description                    OKL_SERVICE_FEES_V.DESCRIPTION%TYPE := Okl_Api.G_MISS_CHAR,
    amount                         NUMBER := Okl_Api.G_MISS_NUM,
    start_date                     OKL_SERVICE_FEES_V.START_DATE%TYPE := Okl_Api.G_MISS_DATE,
    end_date                       OKL_SERVICE_FEES_V.END_DATE%TYPE := Okl_Api.G_MISS_DATE,
    organization_id		   NUMBER := Okl_Api.G_MISS_NUM,
    attribute_category             OKL_SERVICE_FEES_V.ATTRIBUTE_CATEGORY%TYPE := Okl_Api.G_MISS_CHAR,
    attribute1                     OKL_SERVICE_FEES_V.ATTRIBUTE1%TYPE := Okl_Api.G_MISS_CHAR,
    attribute2                     OKL_SERVICE_FEES_V.ATTRIBUTE2%TYPE := Okl_Api.G_MISS_CHAR,
    attribute3                     OKL_SERVICE_FEES_V.ATTRIBUTE3%TYPE := Okl_Api.G_MISS_CHAR,
    attribute4                     OKL_SERVICE_FEES_V.ATTRIBUTE4%TYPE := Okl_Api.G_MISS_CHAR,
    attribute5                     OKL_SERVICE_FEES_V.ATTRIBUTE5%TYPE := Okl_Api.G_MISS_CHAR,
    attribute6                     OKL_SERVICE_FEES_V.ATTRIBUTE6%TYPE := Okl_Api.G_MISS_CHAR,
    attribute7                     OKL_SERVICE_FEES_V.ATTRIBUTE7%TYPE := Okl_Api.G_MISS_CHAR,
    attribute8                     OKL_SERVICE_FEES_V.ATTRIBUTE8%TYPE := Okl_Api.G_MISS_CHAR,
    attribute9                     OKL_SERVICE_FEES_V.ATTRIBUTE9%TYPE := Okl_Api.G_MISS_CHAR,
    attribute10                    OKL_SERVICE_FEES_V.ATTRIBUTE10%TYPE := Okl_Api.G_MISS_CHAR,
    attribute11                    OKL_SERVICE_FEES_V.ATTRIBUTE11%TYPE := Okl_Api.G_MISS_CHAR,
    attribute12                    OKL_SERVICE_FEES_V.ATTRIBUTE12%TYPE := Okl_Api.G_MISS_CHAR,
    attribute13                    OKL_SERVICE_FEES_V.ATTRIBUTE13%TYPE := Okl_Api.G_MISS_CHAR,
    attribute14                    OKL_SERVICE_FEES_V.ATTRIBUTE14%TYPE := Okl_Api.G_MISS_CHAR,
    attribute15                    OKL_SERVICE_FEES_V.ATTRIBUTE15%TYPE := Okl_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okl_Api.G_MISS_NUM,
    creation_date                  OKL_SERVICE_FEES_V.CREATION_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_Api.G_MISS_NUM,
    last_update_date               OKL_SERVICE_FEES_V.LAST_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_Api.G_MISS_NUM);
  g_miss_svfv_rec                         svfv_rec_type;
  TYPE svfv_tbl_type IS TABLE OF svfv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------

  G_FND_APP			             CONSTANT VARCHAR2(200) := Okl_Api.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	 CONSTANT VARCHAR2(200) := Okl_Api.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		     CONSTANT VARCHAR2(200) := Okl_Api.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		     CONSTANT VARCHAR2(200) := Okl_Api.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	 CONSTANT VARCHAR2(200) := Okl_Api.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		         CONSTANT VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
  G_INVALID_VALUE			     CONSTANT VARCHAR2(200) := 'OKL_INVALID_VALUE';
  G_COL_NAME_TOKEN		         CONSTANT VARCHAR2(200) := 'COL_NAME';
  G_PARENT_TABLE_TOKEN		     CONSTANT VARCHAR2(200) := 'PARENT_TABLE';
  G_CHILD_TABLE_TOKEN		     CONSTANT VARCHAR2(200) := 'CHILD_TABLE';
  G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN                CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN                CONSTANT VARCHAR2(200) := 'SQLCODE';
  G_FND_LOOKUP_SERVICE_FEE_TYPE  CONSTANT VARCHAR2(200) := 'SERVICE_FEES';
  G_NO_PARENT_RECORD             CONSTANT VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
  G_OKL_SERVICE_FEES             CONSTANT VARCHAR2(200) := 'OKL_SERVICE_FEES';
  G_OKL_AMOUNT_GREATER_THAN_ZERO CONSTANT VARCHAR2(200) := 'OKL_AMOUNT_GREATER_THAN_ZERO';
  G_OKL_INVALID_END_DATE         CONSTANT VARCHAR2(200) := 'OKL_INVALID_END_DATE';
  G_OKL_DUPLICATE_SERVICE_FEE    CONSTANT VARCHAR2(200) := 'OKL_DUPLICATE_SERVICE_FEE';
  G_OKL_START_DATE               CONSTANT VARCHAR2(200) := 'OKL_START_DATE';

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_SVF_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;

  --------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE add_language;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_svfv_rec                     IN svfv_rec_type,
    x_svfv_rec                     OUT NOCOPY svfv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_svfv_tbl                     IN svfv_tbl_type,
    x_svfv_tbl                     OUT NOCOPY svfv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_svfv_rec                     IN svfv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_svfv_tbl                     IN svfv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_svfv_rec                     IN svfv_rec_type,
    x_svfv_rec                     OUT NOCOPY svfv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_svfv_tbl                     IN svfv_tbl_type,
    x_svfv_tbl                     OUT NOCOPY svfv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_svfv_rec                     IN svfv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_svfv_tbl                     IN svfv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_svfv_rec                     IN svfv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_svfv_tbl                     IN svfv_tbl_type);

END Okl_Svf_Pvt;

/
