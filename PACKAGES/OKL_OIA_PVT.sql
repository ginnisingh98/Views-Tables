--------------------------------------------------------
--  DDL for Package OKL_OIA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_OIA_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSOIAS.pls 120.2 2006/07/11 10:23:02 dkagrawa noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE oiav_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,khr_id                         NUMBER := OKC_API.G_MISS_NUM
    ,instance_number                OKL_OPEN_INT_ASST.INSTANCE_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,asset_id                       NUMBER := OKC_API.G_MISS_NUM
    ,asset_number                   OKL_OPEN_INT_ASST.ASSET_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,description                    OKL_OPEN_INT_ASST.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR
    ,asset_type                     OKL_OPEN_INT_ASST.ASSET_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,manufacturer_name              OKL_OPEN_INT_ASST.MANUFACTURER_NAME%TYPE := OKC_API.G_MISS_CHAR
    ,model_number                   OKL_OPEN_INT_ASST.MODEL_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,serial_number                  OKL_OPEN_INT_ASST.SERIAL_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,tag_number                     OKL_OPEN_INT_ASST.TAG_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,original_cost                  NUMBER := OKC_API.G_MISS_NUM
    ,quantity                       OKL_OPEN_INT_ASST.QUANTITY%TYPE := OKC_API.G_MISS_CHAR
    ,country                        OKL_OPEN_INT_ASST.COUNTRY%TYPE := OKC_API.G_MISS_CHAR
    ,address1                       OKL_OPEN_INT_ASST.ADDRESS1%TYPE := OKC_API.G_MISS_CHAR
    ,address2                       OKL_OPEN_INT_ASST.ADDRESS2%TYPE := OKC_API.G_MISS_CHAR
    ,address3                       OKL_OPEN_INT_ASST.ADDRESS3%TYPE := OKC_API.G_MISS_CHAR
    ,address4                       OKL_OPEN_INT_ASST.ADDRESS4%TYPE := OKC_API.G_MISS_CHAR
    ,city                           OKL_OPEN_INT_ASST.CITY%TYPE := OKC_API.G_MISS_CHAR
    ,postal_code                    OKL_OPEN_INT_ASST.POSTAL_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,state                          OKL_OPEN_INT_ASST.STATE%TYPE := OKC_API.G_MISS_CHAR
    ,province                       OKL_OPEN_INT_ASST.PROVINCE%TYPE := OKC_API.G_MISS_CHAR
    ,county                         OKL_OPEN_INT_ASST.COUNTY%TYPE := OKC_API.G_MISS_CHAR
    ,po_box_number                  OKL_OPEN_INT_ASST.PO_BOX_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,house_number                   OKL_OPEN_INT_ASST.HOUSE_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,street_suffix                  OKL_OPEN_INT_ASST.STREET_SUFFIX%TYPE := OKC_API.G_MISS_CHAR
    ,apartment_number               OKL_OPEN_INT_ASST.APARTMENT_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,street                         OKL_OPEN_INT_ASST.STREET%TYPE := OKC_API.G_MISS_CHAR
    ,rural_route_number             OKL_OPEN_INT_ASST.RURAL_ROUTE_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,street_number                  OKL_OPEN_INT_ASST.STREET_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,building                       OKL_OPEN_INT_ASST.BUILDING%TYPE := OKC_API.G_MISS_CHAR
    ,floor                          OKL_OPEN_INT_ASST.FLOOR%TYPE := OKC_API.G_MISS_CHAR
    ,suite                          OKL_OPEN_INT_ASST.SUITE%TYPE := OKC_API.G_MISS_CHAR
    ,room                           OKL_OPEN_INT_ASST.ROOM%TYPE := OKC_API.G_MISS_CHAR
    ,postal_plus4_code              OKL_OPEN_INT_ASST.POSTAL_PLUS4_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,org_id                         NUMBER := OKC_API.G_MISS_NUM
    ,request_id                     NUMBER := OKC_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKC_API.G_MISS_NUM
    ,program_id                     NUMBER := OKC_API.G_MISS_NUM
    ,program_update_date            OKL_OPEN_INT_ASST.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,attribute_category             OKL_OPEN_INT_ASST.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR
    ,attribute1                     OKL_OPEN_INT_ASST.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR
    ,attribute2                     OKL_OPEN_INT_ASST.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR
    ,attribute3                     OKL_OPEN_INT_ASST.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR
    ,attribute4                     OKL_OPEN_INT_ASST.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR
    ,attribute5                     OKL_OPEN_INT_ASST.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR
    ,attribute6                     OKL_OPEN_INT_ASST.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR
    ,attribute7                     OKL_OPEN_INT_ASST.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR
    ,attribute8                     OKL_OPEN_INT_ASST.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR
    ,attribute9                     OKL_OPEN_INT_ASST.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR
    ,attribute10                    OKL_OPEN_INT_ASST.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR
    ,attribute11                    OKL_OPEN_INT_ASST.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR
    ,attribute12                    OKL_OPEN_INT_ASST.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR
    ,attribute13                    OKL_OPEN_INT_ASST.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR
    ,attribute14                    OKL_OPEN_INT_ASST.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR
    ,attribute15                    OKL_OPEN_INT_ASST.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKL_OPEN_INT_ASST.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKL_OPEN_INT_ASST.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_oiav_rec                         oiav_rec_type;
  TYPE oiav_tbl_type IS TABLE OF oiav_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE oia_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,khr_id                         NUMBER := OKC_API.G_MISS_NUM
    ,instance_number                OKL_OPEN_INT_ASST.INSTANCE_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,asset_id                       NUMBER := OKC_API.G_MISS_NUM
    ,asset_number                   OKL_OPEN_INT_ASST.ASSET_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,description                    OKL_OPEN_INT_ASST.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR
    ,asset_type                     OKL_OPEN_INT_ASST.ASSET_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,manufacturer_name              OKL_OPEN_INT_ASST.MANUFACTURER_NAME%TYPE := OKC_API.G_MISS_CHAR
    ,model_number                   OKL_OPEN_INT_ASST.MODEL_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,serial_number                  OKL_OPEN_INT_ASST.SERIAL_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,tag_number                     OKL_OPEN_INT_ASST.TAG_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,original_cost                  NUMBER := OKC_API.G_MISS_NUM
    ,quantity                       OKL_OPEN_INT_ASST.QUANTITY%TYPE := OKC_API.G_MISS_CHAR
    ,country                        OKL_OPEN_INT_ASST.COUNTRY%TYPE := OKC_API.G_MISS_CHAR
    ,address1                       OKL_OPEN_INT_ASST.ADDRESS1%TYPE := OKC_API.G_MISS_CHAR
    ,address2                       OKL_OPEN_INT_ASST.ADDRESS2%TYPE := OKC_API.G_MISS_CHAR
    ,address3                       OKL_OPEN_INT_ASST.ADDRESS3%TYPE := OKC_API.G_MISS_CHAR
    ,address4                       OKL_OPEN_INT_ASST.ADDRESS4%TYPE := OKC_API.G_MISS_CHAR
    ,city                           OKL_OPEN_INT_ASST.CITY%TYPE := OKC_API.G_MISS_CHAR
    ,postal_code                    OKL_OPEN_INT_ASST.POSTAL_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,state                          OKL_OPEN_INT_ASST.STATE%TYPE := OKC_API.G_MISS_CHAR
    ,province                       OKL_OPEN_INT_ASST.PROVINCE%TYPE := OKC_API.G_MISS_CHAR
    ,county                         OKL_OPEN_INT_ASST.COUNTY%TYPE := OKC_API.G_MISS_CHAR
    ,po_box_number                  OKL_OPEN_INT_ASST.PO_BOX_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,house_number                   OKL_OPEN_INT_ASST.HOUSE_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,street_suffix                  OKL_OPEN_INT_ASST.STREET_SUFFIX%TYPE := OKC_API.G_MISS_CHAR
    ,apartment_number               OKL_OPEN_INT_ASST.APARTMENT_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,street                         OKL_OPEN_INT_ASST.STREET%TYPE := OKC_API.G_MISS_CHAR
    ,rural_route_number             OKL_OPEN_INT_ASST.RURAL_ROUTE_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,street_number                  OKL_OPEN_INT_ASST.STREET_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,building                       OKL_OPEN_INT_ASST.BUILDING%TYPE := OKC_API.G_MISS_CHAR
    ,floor                          OKL_OPEN_INT_ASST.FLOOR%TYPE := OKC_API.G_MISS_CHAR
    ,suite                          OKL_OPEN_INT_ASST.SUITE%TYPE := OKC_API.G_MISS_CHAR
    ,room                           OKL_OPEN_INT_ASST.ROOM%TYPE := OKC_API.G_MISS_CHAR
    ,postal_plus4_code              OKL_OPEN_INT_ASST.POSTAL_PLUS4_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,org_id                         NUMBER := OKC_API.G_MISS_NUM
    ,request_id                     NUMBER := OKC_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKC_API.G_MISS_NUM
    ,program_id                     NUMBER := OKC_API.G_MISS_NUM
    ,program_update_date            OKL_OPEN_INT_ASST.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,attribute_category             OKL_OPEN_INT_ASST.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR
    ,attribute1                     OKL_OPEN_INT_ASST.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR
    ,attribute2                     OKL_OPEN_INT_ASST.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR
    ,attribute3                     OKL_OPEN_INT_ASST.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR
    ,attribute4                     OKL_OPEN_INT_ASST.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR
    ,attribute5                     OKL_OPEN_INT_ASST.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR
    ,attribute6                     OKL_OPEN_INT_ASST.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR
    ,attribute7                     OKL_OPEN_INT_ASST.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR
    ,attribute8                     OKL_OPEN_INT_ASST.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR
    ,attribute9                     OKL_OPEN_INT_ASST.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR
    ,attribute10                    OKL_OPEN_INT_ASST.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR
    ,attribute11                    OKL_OPEN_INT_ASST.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR
    ,attribute12                    OKL_OPEN_INT_ASST.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR
    ,attribute13                    OKL_OPEN_INT_ASST.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR
    ,attribute14                    OKL_OPEN_INT_ASST.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR
    ,attribute15                    OKL_OPEN_INT_ASST.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKL_OPEN_INT_ASST.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKL_OPEN_INT_ASST.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_oia_rec                          oia_rec_type;
  TYPE oia_tbl_type IS TABLE OF oia_rec_type
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
  --G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200) := 'OKS_SERVICE_AVAILABILITY_UNEXPECTED_ERROR';
  --G_SQLCODE_TOKEN                CONSTANT VARCHAR2(200) := 'SQLcode';
  --G_SQLERRM_TOKEN                CONSTANT VARCHAR2(200) := 'SQLerrm';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_OIA_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
  -------------------------------------------------------------------------------
  --Post change to TAPI code
  -------------------------------------------------------------------------------
  --G_EXCEPTION_HALT_VALIDATION EXCEPTION;
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'SQLCODE';
  g_no_parent_record            CONSTANT VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
  ---------------------------------------------------------------------------
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
    p_oiav_rec                     IN oiav_rec_type,
    x_oiav_rec                     OUT NOCOPY oiav_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiav_tbl                     IN oiav_tbl_type,
    x_oiav_tbl                     OUT NOCOPY oiav_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiav_tbl                     IN oiav_tbl_type,
    x_oiav_tbl                     OUT NOCOPY oiav_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiav_rec                     IN oiav_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiav_tbl                     IN oiav_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiav_tbl                     IN oiav_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiav_rec                     IN oiav_rec_type,
    x_oiav_rec                     OUT NOCOPY oiav_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiav_tbl                     IN oiav_tbl_type,
    x_oiav_tbl                     OUT NOCOPY oiav_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiav_tbl                     IN oiav_tbl_type,
    x_oiav_tbl                     OUT NOCOPY oiav_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiav_rec                     IN oiav_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiav_tbl                     IN oiav_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiav_tbl                     IN oiav_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiav_rec                     IN oiav_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiav_tbl                     IN oiav_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiav_tbl                     IN oiav_tbl_type);
END OKL_OIA_PVT;

/
