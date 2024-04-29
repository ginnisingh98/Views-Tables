--------------------------------------------------------
--  DDL for Package OKL_XLS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_XLS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSXLSS.pls 120.3 2005/10/30 03:47:33 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE xls_rec_type IS RECORD (
    id                             NUMBER := Okl_Api.G_MISS_NUM,
    ill_id                         NUMBER := Okl_Api.G_MISS_NUM,
    tld_id                         NUMBER := Okl_Api.G_MISS_NUM,
    lsm_id                         NUMBER := Okl_Api.G_MISS_NUM,
    til_id                         NUMBER := Okl_Api.G_MISS_NUM,
    xsi_id_details                 NUMBER := Okl_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okl_Api.G_MISS_NUM,
    line_type                      OKL_XTL_SELL_INVS_B.LINE_TYPE%TYPE := Okl_Api.G_MISS_CHAR,
    amount                         NUMBER := Okl_Api.G_MISS_NUM,
    quantity                       NUMBER := Okl_Api.G_MISS_NUM,
    xtrx_cons_line_number          NUMBER := Okl_Api.G_MISS_NUM,
    xtrx_cons_stream_id            NUMBER := Okl_Api.G_MISS_NUM,
    request_id                     NUMBER := Okl_Api.G_MISS_NUM,
    program_application_id         NUMBER := Okl_Api.G_MISS_NUM,
    program_id                     NUMBER := Okl_Api.G_MISS_NUM,
    program_update_date            OKL_XTL_SELL_INVS_B.PROGRAM_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    org_id                         NUMBER := Okl_Api.G_MISS_NUM,
    inventory_org_id                         NUMBER := Okl_Api.G_MISS_NUM,
    isl_id                         NUMBER := Okl_Api.G_MISS_NUM,
    sel_id                         NUMBER := Okl_Api.G_MISS_NUM,
-- Start changes on remarketing by fmiao on 10/18/04 --
    inventory_item_id              NUMBER := Okl_Api.G_MISS_NUM,
-- End changes on remarketing by fmiao on 10/18/04 --
    attribute_category             OKL_XTL_SELL_INVS_B.ATTRIBUTE_CATEGORY%TYPE := Okl_Api.G_MISS_CHAR,
    attribute1                     OKL_XTL_SELL_INVS_B.ATTRIBUTE1%TYPE := Okl_Api.G_MISS_CHAR,
    attribute2                     OKL_XTL_SELL_INVS_B.ATTRIBUTE2%TYPE := Okl_Api.G_MISS_CHAR,
    attribute3                     OKL_XTL_SELL_INVS_B.ATTRIBUTE3%TYPE := Okl_Api.G_MISS_CHAR,
    attribute4                     OKL_XTL_SELL_INVS_B.ATTRIBUTE4%TYPE := Okl_Api.G_MISS_CHAR,
    attribute5                     OKL_XTL_SELL_INVS_B.ATTRIBUTE5%TYPE := Okl_Api.G_MISS_CHAR,
    attribute6                     OKL_XTL_SELL_INVS_B.ATTRIBUTE6%TYPE := Okl_Api.G_MISS_CHAR,
    attribute7                     OKL_XTL_SELL_INVS_B.ATTRIBUTE7%TYPE := Okl_Api.G_MISS_CHAR,
    attribute8                     OKL_XTL_SELL_INVS_B.ATTRIBUTE8%TYPE := Okl_Api.G_MISS_CHAR,
    attribute9                     OKL_XTL_SELL_INVS_B.ATTRIBUTE9%TYPE := Okl_Api.G_MISS_CHAR,
    attribute10                    OKL_XTL_SELL_INVS_B.ATTRIBUTE10%TYPE := Okl_Api.G_MISS_CHAR,
    attribute11                    OKL_XTL_SELL_INVS_B.ATTRIBUTE11%TYPE := Okl_Api.G_MISS_CHAR,
    attribute12                    OKL_XTL_SELL_INVS_B.ATTRIBUTE12%TYPE := Okl_Api.G_MISS_CHAR,
    attribute13                    OKL_XTL_SELL_INVS_B.ATTRIBUTE13%TYPE := Okl_Api.G_MISS_CHAR,
    attribute14                    OKL_XTL_SELL_INVS_B.ATTRIBUTE14%TYPE := Okl_Api.G_MISS_CHAR,
    attribute15                    OKL_XTL_SELL_INVS_B.ATTRIBUTE15%TYPE := Okl_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okl_Api.G_MISS_NUM,
    creation_date                  OKL_XTL_SELL_INVS_B.CREATION_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_Api.G_MISS_NUM,
    last_update_date               OKL_XTL_SELL_INVS_B.LAST_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_Api.G_MISS_NUM);
  g_miss_xls_rec                          xls_rec_type;
  TYPE xls_tbl_type IS TABLE OF xls_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE okl_xtl_sell_invs_tl_rec_type IS RECORD (
    id                             NUMBER := Okl_Api.G_MISS_NUM,
    LANGUAGE                       OKL_XTL_SELL_INVS_TL.LANGUAGE%TYPE := Okl_Api.G_MISS_CHAR,
    source_lang                    OKL_XTL_SELL_INVS_TL.SOURCE_LANG%TYPE := Okl_Api.G_MISS_CHAR,
    sfwt_flag                      OKL_XTL_SELL_INVS_TL.SFWT_FLAG%TYPE := Okl_Api.G_MISS_CHAR,
    description                    OKL_XTL_SELL_INVS_TL.DESCRIPTION%TYPE := Okl_Api.G_MISS_CHAR,
    xtrx_contract                  OKL_XTL_SELL_INVS_TL.XTRX_CONTRACT%TYPE := Okl_Api.G_MISS_CHAR,
    xtrx_asset                     OKL_XTL_SELL_INVS_TL.XTRX_ASSET%TYPE := Okl_Api.G_MISS_CHAR,
    xtrx_stream_group              OKL_XTL_SELL_INVS_TL.XTRX_STREAM_GROUP%TYPE := Okl_Api.G_MISS_CHAR,
    xtrx_stream_type               OKL_XTL_SELL_INVS_TL.XTRX_STREAM_TYPE%TYPE := Okl_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okl_Api.G_MISS_NUM,
    creation_date                  OKL_XTL_SELL_INVS_TL.CREATION_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_Api.G_MISS_NUM,
    last_update_date               OKL_XTL_SELL_INVS_TL.LAST_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_Api.G_MISS_NUM);
  GMissOklXtlSellInvsTlRec                okl_xtl_sell_invs_tl_rec_type;
  TYPE okl_xtl_sell_invs_tl_tbl_type IS TABLE OF okl_xtl_sell_invs_tl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE xlsv_rec_type IS RECORD (
    id                             NUMBER := Okl_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okl_Api.G_MISS_NUM,
    sfwt_flag                      OKL_XTL_SELL_INVS_V.SFWT_FLAG%TYPE := Okl_Api.G_MISS_CHAR,
    tld_id                         NUMBER := Okl_Api.G_MISS_NUM,
    lsm_id                         NUMBER := Okl_Api.G_MISS_NUM,
    til_id                         NUMBER := Okl_Api.G_MISS_NUM,
    ill_id                         NUMBER := Okl_Api.G_MISS_NUM,
    xsi_id_details                 NUMBER := Okl_Api.G_MISS_NUM,
    line_type                      OKL_XTL_SELL_INVS_V.LINE_TYPE%TYPE := Okl_Api.G_MISS_CHAR,
    description                    OKL_XTL_SELL_INVS_V.DESCRIPTION%TYPE := Okl_Api.G_MISS_CHAR,
    amount                         NUMBER := Okl_Api.G_MISS_NUM,
    quantity                       NUMBER := Okl_Api.G_MISS_NUM,
    xtrx_cons_line_number          NUMBER := Okl_Api.G_MISS_NUM,
    xtrx_contract                  OKL_XTL_SELL_INVS_V.XTRX_CONTRACT%TYPE := Okl_Api.G_MISS_CHAR,
    xtrx_asset                     OKL_XTL_SELL_INVS_V.XTRX_ASSET%TYPE := Okl_Api.G_MISS_CHAR,
    xtrx_stream_group              OKL_XTL_SELL_INVS_V.XTRX_STREAM_GROUP%TYPE := Okl_Api.G_MISS_CHAR,
    xtrx_stream_type               OKL_XTL_SELL_INVS_V.XTRX_STREAM_TYPE%TYPE := Okl_Api.G_MISS_CHAR,
    xtrx_cons_stream_id            NUMBER := Okl_Api.G_MISS_NUM,
    isl_id            			   NUMBER := Okl_Api.G_MISS_NUM,
    sel_id            			   NUMBER := Okl_Api.G_MISS_NUM,
-- Start changes on remarketing by fmiao on 10/18/04 --
    inventory_item_id  			   NUMBER := Okl_Api.G_MISS_NUM,
-- End changes on remarketing by fmiao on 10/18/04 --
    attribute_category             OKL_XTL_SELL_INVS_V.ATTRIBUTE_CATEGORY%TYPE := Okl_Api.G_MISS_CHAR,
    attribute1                     OKL_XTL_SELL_INVS_V.ATTRIBUTE1%TYPE := Okl_Api.G_MISS_CHAR,
    attribute2                     OKL_XTL_SELL_INVS_V.ATTRIBUTE2%TYPE := Okl_Api.G_MISS_CHAR,
    attribute3                     OKL_XTL_SELL_INVS_V.ATTRIBUTE3%TYPE := Okl_Api.G_MISS_CHAR,
    attribute4                     OKL_XTL_SELL_INVS_V.ATTRIBUTE4%TYPE := Okl_Api.G_MISS_CHAR,
    attribute5                     OKL_XTL_SELL_INVS_V.ATTRIBUTE5%TYPE := Okl_Api.G_MISS_CHAR,
    attribute6                     OKL_XTL_SELL_INVS_V.ATTRIBUTE6%TYPE := Okl_Api.G_MISS_CHAR,
    attribute7                     OKL_XTL_SELL_INVS_V.ATTRIBUTE7%TYPE := Okl_Api.G_MISS_CHAR,
    attribute8                     OKL_XTL_SELL_INVS_V.ATTRIBUTE8%TYPE := Okl_Api.G_MISS_CHAR,
    attribute9                     OKL_XTL_SELL_INVS_V.ATTRIBUTE9%TYPE := Okl_Api.G_MISS_CHAR,
    attribute10                    OKL_XTL_SELL_INVS_V.ATTRIBUTE10%TYPE := Okl_Api.G_MISS_CHAR,
    attribute11                    OKL_XTL_SELL_INVS_V.ATTRIBUTE11%TYPE := Okl_Api.G_MISS_CHAR,
    attribute12                    OKL_XTL_SELL_INVS_V.ATTRIBUTE12%TYPE := Okl_Api.G_MISS_CHAR,
    attribute13                    OKL_XTL_SELL_INVS_V.ATTRIBUTE13%TYPE := Okl_Api.G_MISS_CHAR,
    attribute14                    OKL_XTL_SELL_INVS_V.ATTRIBUTE14%TYPE := Okl_Api.G_MISS_CHAR,
    attribute15                    OKL_XTL_SELL_INVS_V.ATTRIBUTE15%TYPE := Okl_Api.G_MISS_CHAR,
    request_id                     NUMBER := Okl_Api.G_MISS_NUM,
    program_application_id         NUMBER := Okl_Api.G_MISS_NUM,
    program_id                     NUMBER := Okl_Api.G_MISS_NUM,
    program_update_date            OKL_XTL_SELL_INVS_V.PROGRAM_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    org_id                         NUMBER := Okl_Api.G_MISS_NUM,
    inventory_org_id                         NUMBER := Okl_Api.G_MISS_NUM,
    created_by                     NUMBER := Okl_Api.G_MISS_NUM,
    creation_date                  OKL_XTL_SELL_INVS_V.CREATION_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_Api.G_MISS_NUM,
    last_update_date               OKL_XTL_SELL_INVS_V.LAST_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_Api.G_MISS_NUM);
  g_miss_xlsv_rec                         xlsv_rec_type;
  TYPE xlsv_tbl_type IS TABLE OF xlsv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := Okl_Api.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := Okl_Api.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := Okl_Api.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := Okl_Api.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := Okl_Api.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := Okl_Api.G_REQUIRED_VALUE;
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := Okl_Api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := Okl_Api.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okl_Api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okl_Api.G_CHILD_TABLE_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_XLS_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;

  /******************ADDED AFTER TAPI, Sunil T. Mathew (04/18/2001) ****************/
  --GLOBAL MESSAGES
   G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
   G_NO_PARENT_RECORD           CONSTANT   VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
   G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
   G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
   G_NOT_SAME              		CONSTANT   VARCHAR2(200) := 'OKL_CANNOT_BE_SAME';


--GLOBAL VARIABLES
  G_VIEW			CONSTANT   VARCHAR2(30) := 'OKL_XTL_SELL_INVS_V';
  G_EXCEPTION_HALT_VALIDATION           EXCEPTION;

  ---------------------------------------------------------------------------
  -- validation Procedures and Functions
  ---------------------------------------------------------------------------
 --PROCEDURE validate_unique(p_saiv_rec 	IN 	saiv_rec_type,
 --                     x_return_status OUT NOCOPY VARCHAR2);

/****************END ADDED AFTER TAPI, Sunil T. Mathew (04/18/2001)**************/

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
    p_xlsv_rec                     IN xlsv_rec_type,
    x_xlsv_rec                     OUT NOCOPY xlsv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlsv_tbl                     IN xlsv_tbl_type,
    x_xlsv_tbl                     OUT NOCOPY xlsv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlsv_rec                     IN xlsv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlsv_tbl                     IN xlsv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlsv_rec                     IN xlsv_rec_type,
    x_xlsv_rec                     OUT NOCOPY xlsv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlsv_tbl                     IN xlsv_tbl_type,
    x_xlsv_tbl                     OUT NOCOPY xlsv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlsv_rec                     IN xlsv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlsv_tbl                     IN xlsv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlsv_rec                     IN xlsv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlsv_tbl                     IN xlsv_tbl_type);

END Okl_Xls_Pvt;

 

/
