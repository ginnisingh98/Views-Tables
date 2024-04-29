--------------------------------------------------------
--  DDL for Package OKL_BCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_BCH_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSBCHS.pls 115.4 2002/03/29 17:43:44 pkm ship        $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE bch_rec_type IS RECORD (
    id                             NUMBER := Okc_Api.G_MISS_NUM,
    sequence_number                NUMBER := Okc_Api.G_MISS_NUM,
    bgh_id                         NUMBER := Okc_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okc_Api.G_MISS_NUM,
    contract_id                    NUMBER := Okc_Api.G_MISS_NUM,
    asset_id                       NUMBER := Okc_Api.G_MISS_NUM,
    charge_date                    OKL_BILLING_CHARGES_B.CHARGE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    amount                         NUMBER := Okc_Api.G_MISS_NUM,
    currency_code                  OKL_BILLING_CHARGES_B.CURRENCY_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    customer_id                    NUMBER := Okc_Api.G_MISS_NUM,
    customer_ref                   OKL_BILLING_CHARGES_B.CUSTOMER_REF%TYPE := Okc_Api.G_MISS_CHAR,
    customer_address_id            NUMBER := Okc_Api.G_MISS_NUM,
    customer_address_ref           OKL_BILLING_CHARGES_B.CUSTOMER_ADDRESS_REF%TYPE := Okc_Api.G_MISS_CHAR,
    request_id                     NUMBER := Okc_Api.G_MISS_NUM,
    program_application_id         NUMBER := Okc_Api.G_MISS_NUM,
    program_id                     NUMBER := Okc_Api.G_MISS_NUM,
    program_update_date            OKL_BILLING_CHARGES_B.PROGRAM_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    org_id                         NUMBER := Okc_Api.G_MISS_NUM,
    sty_id                         NUMBER := Okc_Api.G_MISS_NUM,
    sty_name                       OKL_BILLING_CHARGES_B.STY_NAME%TYPE := Okc_Api.G_MISS_CHAR,
    attribute_category             OKL_BILLING_CHARGES_B.ATTRIBUTE_CATEGORY%TYPE := Okc_Api.G_MISS_CHAR,
    attribute1                     OKL_BILLING_CHARGES_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    attribute2                     OKL_BILLING_CHARGES_B.ATTRIBUTE2%TYPE := Okc_Api.G_MISS_CHAR,
    attribute3                     OKL_BILLING_CHARGES_B.ATTRIBUTE3%TYPE := Okc_Api.G_MISS_CHAR,
    attribute4                     OKL_BILLING_CHARGES_B.ATTRIBUTE4%TYPE := Okc_Api.G_MISS_CHAR,
    attribute5                     OKL_BILLING_CHARGES_B.ATTRIBUTE5%TYPE := Okc_Api.G_MISS_CHAR,
    attribute6                     OKL_BILLING_CHARGES_B.ATTRIBUTE6%TYPE := Okc_Api.G_MISS_CHAR,
    attribute7                     OKL_BILLING_CHARGES_B.ATTRIBUTE7%TYPE := Okc_Api.G_MISS_CHAR,
    attribute8                     OKL_BILLING_CHARGES_B.ATTRIBUTE8%TYPE := Okc_Api.G_MISS_CHAR,
    attribute9                     OKL_BILLING_CHARGES_B.ATTRIBUTE9%TYPE := Okc_Api.G_MISS_CHAR,
    attribute10                    OKL_BILLING_CHARGES_B.ATTRIBUTE10%TYPE := Okc_Api.G_MISS_CHAR,
    attribute11                    OKL_BILLING_CHARGES_B.ATTRIBUTE11%TYPE := Okc_Api.G_MISS_CHAR,
    attribute12                    OKL_BILLING_CHARGES_B.ATTRIBUTE12%TYPE := Okc_Api.G_MISS_CHAR,
    attribute13                    OKL_BILLING_CHARGES_B.ATTRIBUTE13%TYPE := Okc_Api.G_MISS_CHAR,
    attribute14                    OKL_BILLING_CHARGES_B.ATTRIBUTE14%TYPE := Okc_Api.G_MISS_CHAR,
    attribute15                    OKL_BILLING_CHARGES_B.ATTRIBUTE15%TYPE := Okc_Api.G_MISS_CHAR,
    interface_attribute1           OKL_BILLING_CHARGES_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    interface_attribute2           OKL_BILLING_CHARGES_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    interface_attribute3           OKL_BILLING_CHARGES_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    interface_attribute4           OKL_BILLING_CHARGES_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    interface_attribute5           OKL_BILLING_CHARGES_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    interface_attribute6           OKL_BILLING_CHARGES_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    interface_attribute7           OKL_BILLING_CHARGES_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    interface_attribute8           OKL_BILLING_CHARGES_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    interface_attribute9           OKL_BILLING_CHARGES_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    interface_attribute10          OKL_BILLING_CHARGES_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    interface_attribute11          OKL_BILLING_CHARGES_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    interface_attribute12          OKL_BILLING_CHARGES_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    interface_attribute13          OKL_BILLING_CHARGES_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    interface_attribute14          OKL_BILLING_CHARGES_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    interface_attribute15          OKL_BILLING_CHARGES_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okc_Api.G_MISS_NUM,
    creation_date                  OKL_BILLING_CHARGES_B.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okc_Api.G_MISS_NUM,
    last_update_date               OKL_BILLING_CHARGES_B.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okc_Api.G_MISS_NUM);
  g_miss_bch_rec                          bch_rec_type;
  TYPE bch_tbl_type IS TABLE OF bch_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE OklBillingChargesTlRecType IS RECORD (
    id                             NUMBER := Okc_Api.G_MISS_NUM,
    LANGUAGE                       OKL_BILLING_CHARGES_TL.LANGUAGE%TYPE := Okc_Api.G_MISS_CHAR,
    source_lang                    OKL_BILLING_CHARGES_TL.SOURCE_LANG%TYPE := Okc_Api.G_MISS_CHAR,
    sfwt_flag                      OKL_BILLING_CHARGES_TL.SFWT_FLAG%TYPE := Okc_Api.G_MISS_CHAR,
    charge_type                    OKL_BILLING_CHARGES_TL.CHARGE_TYPE%TYPE := Okc_Api.G_MISS_CHAR,
    description                    OKL_BILLING_CHARGES_TL.DESCRIPTION%TYPE := Okc_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okc_Api.G_MISS_NUM,
    creation_date                  OKL_BILLING_CHARGES_TL.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okc_Api.G_MISS_NUM,
    last_update_date               OKL_BILLING_CHARGES_TL.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okc_Api.G_MISS_NUM);
  GMissOklBillingChargesTlRec             OklBillingChargesTlRecType;
  TYPE OklBillingChargesTlTblType IS TABLE OF OklBillingChargesTlRecType
        INDEX BY BINARY_INTEGER;
  TYPE bchv_rec_type IS RECORD (
    id                             NUMBER := Okc_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okc_Api.G_MISS_NUM,
    sfwt_flag                      OKL_BILLING_CHARGES_V.SFWT_FLAG%TYPE := Okc_Api.G_MISS_CHAR,
    bgh_id                         NUMBER := Okc_Api.G_MISS_NUM,
    sequence_number                NUMBER := Okc_Api.G_MISS_NUM,
    contract_id                    NUMBER := Okc_Api.G_MISS_NUM,
    asset_id                       NUMBER := Okc_Api.G_MISS_NUM,
    charge_type                    OKL_BILLING_CHARGES_V.CHARGE_TYPE%TYPE := Okc_Api.G_MISS_CHAR,
    charge_date                    OKL_BILLING_CHARGES_V.CHARGE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    amount                         NUMBER := Okc_Api.G_MISS_NUM,
    currency_code                  OKL_BILLING_CHARGES_V.CURRENCY_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    description                    OKL_BILLING_CHARGES_V.DESCRIPTION%TYPE := Okc_Api.G_MISS_CHAR,
    customer_id                    NUMBER := Okc_Api.G_MISS_NUM,
    customer_ref                   OKL_BILLING_CHARGES_V.CUSTOMER_REF%TYPE := Okc_Api.G_MISS_CHAR,
    customer_address_id            NUMBER := Okc_Api.G_MISS_NUM,
    customer_address_ref           OKL_BILLING_CHARGES_V.CUSTOMER_ADDRESS_REF%TYPE := Okc_Api.G_MISS_CHAR,
    sty_id                         NUMBER := Okc_Api.G_MISS_NUM,
    sty_name                       OKL_BILLING_CHARGES_V.STY_NAME%TYPE := Okc_Api.G_MISS_CHAR,
    attribute_category             OKL_BILLING_CHARGES_V.ATTRIBUTE_CATEGORY%TYPE := Okc_Api.G_MISS_CHAR,
    attribute1                     OKL_BILLING_CHARGES_V.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    attribute2                     OKL_BILLING_CHARGES_V.ATTRIBUTE2%TYPE := Okc_Api.G_MISS_CHAR,
    attribute3                     OKL_BILLING_CHARGES_V.ATTRIBUTE3%TYPE := Okc_Api.G_MISS_CHAR,
    attribute4                     OKL_BILLING_CHARGES_V.ATTRIBUTE4%TYPE := Okc_Api.G_MISS_CHAR,
    attribute5                     OKL_BILLING_CHARGES_V.ATTRIBUTE5%TYPE := Okc_Api.G_MISS_CHAR,
    attribute6                     OKL_BILLING_CHARGES_V.ATTRIBUTE6%TYPE := Okc_Api.G_MISS_CHAR,
    attribute7                     OKL_BILLING_CHARGES_V.ATTRIBUTE7%TYPE := Okc_Api.G_MISS_CHAR,
    attribute8                     OKL_BILLING_CHARGES_V.ATTRIBUTE8%TYPE := Okc_Api.G_MISS_CHAR,
    attribute9                     OKL_BILLING_CHARGES_V.ATTRIBUTE9%TYPE := Okc_Api.G_MISS_CHAR,
    attribute10                    OKL_BILLING_CHARGES_V.ATTRIBUTE10%TYPE := Okc_Api.G_MISS_CHAR,
    attribute11                    OKL_BILLING_CHARGES_V.ATTRIBUTE11%TYPE := Okc_Api.G_MISS_CHAR,
    attribute12                    OKL_BILLING_CHARGES_V.ATTRIBUTE12%TYPE := Okc_Api.G_MISS_CHAR,
    attribute13                    OKL_BILLING_CHARGES_V.ATTRIBUTE13%TYPE := Okc_Api.G_MISS_CHAR,
    attribute14                    OKL_BILLING_CHARGES_V.ATTRIBUTE14%TYPE := Okc_Api.G_MISS_CHAR,
    attribute15                    OKL_BILLING_CHARGES_V.ATTRIBUTE15%TYPE := Okc_Api.G_MISS_CHAR,
    interface_attribute1           OKL_BILLING_CHARGES_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    interface_attribute2           OKL_BILLING_CHARGES_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    interface_attribute3           OKL_BILLING_CHARGES_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    interface_attribute4           OKL_BILLING_CHARGES_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    interface_attribute5           OKL_BILLING_CHARGES_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    interface_attribute6           OKL_BILLING_CHARGES_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    interface_attribute7           OKL_BILLING_CHARGES_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    interface_attribute8           OKL_BILLING_CHARGES_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    interface_attribute9           OKL_BILLING_CHARGES_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    interface_attribute10          OKL_BILLING_CHARGES_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    interface_attribute11          OKL_BILLING_CHARGES_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    interface_attribute12          OKL_BILLING_CHARGES_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    interface_attribute13          OKL_BILLING_CHARGES_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    interface_attribute14          OKL_BILLING_CHARGES_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    interface_attribute15          OKL_BILLING_CHARGES_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    request_id                     NUMBER := Okc_Api.G_MISS_NUM,
    program_application_id         NUMBER := Okc_Api.G_MISS_NUM,
    program_id                     NUMBER := Okc_Api.G_MISS_NUM,
    program_update_date            OKL_BILLING_CHARGES_V.PROGRAM_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    org_id                         NUMBER := Okc_Api.G_MISS_NUM,
    created_by                     NUMBER := Okc_Api.G_MISS_NUM,
    creation_date                  OKL_BILLING_CHARGES_V.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okc_Api.G_MISS_NUM,
    last_update_date               OKL_BILLING_CHARGES_V.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okc_Api.G_MISS_NUM);
  g_miss_bchv_rec                         bchv_rec_type;
  TYPE bchv_tbl_type IS TABLE OF bchv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := Okc_Api.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := Okc_Api.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := Okc_Api.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := Okc_Api.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := Okc_Api.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := Okc_Api.G_REQUIRED_VALUE;
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := Okc_Api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := Okc_Api.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okc_Api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okc_Api.G_CHILD_TABLE_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_BCH_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okc_Api.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE add_language;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bchv_rec                     IN bchv_rec_type,
    x_bchv_rec                     OUT NOCOPY bchv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bchv_tbl                     IN bchv_tbl_type,
    x_bchv_tbl                     OUT NOCOPY bchv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bchv_rec                     IN bchv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bchv_tbl                     IN bchv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bchv_rec                     IN bchv_rec_type,
    x_bchv_rec                     OUT NOCOPY bchv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bchv_tbl                     IN bchv_tbl_type,
    x_bchv_tbl                     OUT NOCOPY bchv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bchv_rec                     IN bchv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bchv_tbl                     IN bchv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bchv_rec                     IN bchv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bchv_tbl                     IN bchv_tbl_type);

END Okl_Bch_Pvt;

 

/
