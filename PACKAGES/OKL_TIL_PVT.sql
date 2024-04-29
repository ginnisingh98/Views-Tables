--------------------------------------------------------
--  DDL for Package OKL_TIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TIL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSTILS.pls 120.7 2008/05/15 18:19:19 sechawla ship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE til_rec_type IS RECORD (
    id                             NUMBER := Okl_Api.G_MISS_NUM,
    inv_receiv_line_code           OKL_TXL_AR_INV_LNS_B.INV_RECEIV_LINE_CODE%TYPE := Okl_Api.G_MISS_CHAR,
    tai_id                         NUMBER := Okl_Api.G_MISS_NUM,
    kle_id                         NUMBER := Okl_Api.G_MISS_NUM,
    tpl_id                         NUMBER := Okl_Api.G_MISS_NUM,
    sty_id                         NUMBER := Okl_Api.G_MISS_NUM,
    acn_id_cost                    NUMBER := Okl_Api.G_MISS_NUM,
    til_id_reverses                NUMBER := Okl_Api.G_MISS_NUM,
    line_number                    NUMBER := Okl_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okl_Api.G_MISS_NUM,
    amount                         NUMBER := Okl_Api.G_MISS_NUM,
    quantity                       NUMBER := Okl_Api.G_MISS_NUM,
    receivables_invoice_id         NUMBER := Okl_Api.G_MISS_NUM,
    amount_applied                 NUMBER := Okl_Api.G_MISS_NUM,
    date_bill_period_start         OKL_TXL_AR_INV_LNS_B.DATE_BILL_PERIOD_START%TYPE := Okl_Api.G_MISS_DATE,
    date_bill_period_end           OKL_TXL_AR_INV_LNS_B.DATE_BILL_PERIOD_END%TYPE := Okl_Api.G_MISS_DATE,
    request_id                     NUMBER := Okl_Api.G_MISS_NUM,
    program_application_id         NUMBER := Okl_Api.G_MISS_NUM,
    program_id                     NUMBER := Okl_Api.G_MISS_NUM,
    program_update_date            OKL_TXL_AR_INV_LNS_B.PROGRAM_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    org_id                         NUMBER := Okl_Api.G_MISS_NUM,
    inventory_org_id                         NUMBER := Okl_Api.G_MISS_NUM,
    isl_id                         NUMBER := Okl_Api.G_MISS_NUM,
	ibt_id						   NUMBER := Okl_Api.G_MISS_NUM,
	LATE_CHARGE_REC_ID             NUMBER := Okl_Api.G_MISS_NUM,
	CLL_ID						   NUMBER := Okl_Api.G_MISS_NUM,
-- Start changes on remarketing by fmiao on 10/18/04 --
    inventory_item_id              NUMBER := Okl_Api.G_MISS_NUM,
-- End changes on remarketing by fmiao on 10/18/04 --
    qte_line_id                    NUMBER := Okl_Api.G_MISS_NUM,
    txs_trx_id                     NUMBER := Okl_Api.G_MISS_NUM,
    -- Start Bug 4673593
    bank_acct_id                   NUMBER := Okl_Api.G_MISS_NUM,
    -- End Bug 4673593
    attribute_category             OKL_TXL_AR_INV_LNS_B.ATTRIBUTE_CATEGORY%TYPE := Okl_Api.G_MISS_CHAR,
    attribute1                     OKL_TXL_AR_INV_LNS_B.ATTRIBUTE1%TYPE := Okl_Api.G_MISS_CHAR,
    attribute2                     OKL_TXL_AR_INV_LNS_B.ATTRIBUTE2%TYPE := Okl_Api.G_MISS_CHAR,
    attribute3                     OKL_TXL_AR_INV_LNS_B.ATTRIBUTE3%TYPE := Okl_Api.G_MISS_CHAR,
    attribute4                     OKL_TXL_AR_INV_LNS_B.ATTRIBUTE4%TYPE := Okl_Api.G_MISS_CHAR,
    attribute5                     OKL_TXL_AR_INV_LNS_B.ATTRIBUTE5%TYPE := Okl_Api.G_MISS_CHAR,
    attribute6                     OKL_TXL_AR_INV_LNS_B.ATTRIBUTE6%TYPE := Okl_Api.G_MISS_CHAR,
    attribute7                     OKL_TXL_AR_INV_LNS_B.ATTRIBUTE7%TYPE := Okl_Api.G_MISS_CHAR,
    attribute8                     OKL_TXL_AR_INV_LNS_B.ATTRIBUTE8%TYPE := Okl_Api.G_MISS_CHAR,
    attribute9                     OKL_TXL_AR_INV_LNS_B.ATTRIBUTE9%TYPE := Okl_Api.G_MISS_CHAR,
    attribute10                    OKL_TXL_AR_INV_LNS_B.ATTRIBUTE10%TYPE := Okl_Api.G_MISS_CHAR,
    attribute11                    OKL_TXL_AR_INV_LNS_B.ATTRIBUTE11%TYPE := Okl_Api.G_MISS_CHAR,
    attribute12                    OKL_TXL_AR_INV_LNS_B.ATTRIBUTE12%TYPE := Okl_Api.G_MISS_CHAR,
    attribute13                    OKL_TXL_AR_INV_LNS_B.ATTRIBUTE13%TYPE := Okl_Api.G_MISS_CHAR,
    attribute14                    OKL_TXL_AR_INV_LNS_B.ATTRIBUTE14%TYPE := Okl_Api.G_MISS_CHAR,
    attribute15                    OKL_TXL_AR_INV_LNS_B.ATTRIBUTE15%TYPE := Okl_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okl_Api.G_MISS_NUM,
    creation_date                  OKL_TXL_AR_INV_LNS_B.CREATION_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_Api.G_MISS_NUM,
    last_update_date               OKL_TXL_AR_INV_LNS_B.LAST_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_Api.G_MISS_NUM,

-- start: 30-Jan-07 cklee  Billing R12 project                             |
TXL_AR_LINE_NUMBER                  OKL_TXL_AR_INV_LNS_B.TXL_AR_LINE_NUMBER%TYPE := Okl_Api.G_MISS_NUM,
TXS_TRX_LINE_ID                  OKL_TXL_AR_INV_LNS_B.TXS_TRX_LINE_ID%TYPE := Okl_Api.G_MISS_NUM ,
-- end: 30-Jan-07 cklee  Billing R12 project                             |
TAX_LINE_ID                      OKL_TXL_AR_INV_LNS_B.TAX_LINE_ID%TYPE := Okl_Api.G_MISS_NUM --14-May-08 sechawla 6619311
);

  g_miss_til_rec                          til_rec_type;
  TYPE til_tbl_type IS TABLE OF til_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE okl_txl_ar_inv_lns_tl_rec_type IS RECORD (
    id                             NUMBER := Okl_Api.G_MISS_NUM,
    LANGUAGE                       OKL_TXL_AR_INV_LNS_TL.LANGUAGE%TYPE := Okl_Api.G_MISS_CHAR,
    source_lang                    OKL_TXL_AR_INV_LNS_TL.SOURCE_LANG%TYPE := Okl_Api.G_MISS_CHAR,
    ERROR_MESSAGE                  OKL_TXL_AR_INV_LNS_TL.ERROR_MESSAGE%TYPE := Okl_Api.G_MISS_CHAR,
    sfwt_flag                      OKL_TXL_AR_INV_LNS_TL.SFWT_FLAG%TYPE := Okl_Api.G_MISS_CHAR,
    description                    OKL_TXL_AR_INV_LNS_TL.DESCRIPTION%TYPE := Okl_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okl_Api.G_MISS_NUM,
    creation_date                  OKL_TXL_AR_INV_LNS_TL.CREATION_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_Api.G_MISS_NUM,
    last_update_date               OKL_TXL_AR_INV_LNS_TL.LAST_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_Api.G_MISS_NUM);
  GMissOklTxlArInvLnsTlRec                okl_txl_ar_inv_lns_tl_rec_type;
  TYPE okl_txl_ar_inv_lns_tl_tbl_type IS TABLE OF okl_txl_ar_inv_lns_tl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE tilv_rec_type IS RECORD (
    id                             NUMBER := Okl_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okl_Api.G_MISS_NUM,
    ERROR_MESSAGE                  OKL_TXL_AR_INV_LNS_TL.ERROR_MESSAGE%TYPE := Okl_Api.G_MISS_CHAR,
    sfwt_flag                      OKL_TXL_AR_INV_LNS_V.SFWT_FLAG%TYPE := Okl_Api.G_MISS_CHAR,
    kle_id                         NUMBER := Okl_Api.G_MISS_NUM,
    tpl_id                         NUMBER := Okl_Api.G_MISS_NUM,
    til_id_reverses                NUMBER := Okl_Api.G_MISS_NUM,
    inv_receiv_line_code           OKL_TXL_AR_INV_LNS_V.INV_RECEIV_LINE_CODE%TYPE := Okl_Api.G_MISS_CHAR,
    sty_id                         NUMBER := Okl_Api.G_MISS_NUM,
    tai_id                         NUMBER := Okl_Api.G_MISS_NUM,
    acn_id_cost                    NUMBER := Okl_Api.G_MISS_NUM,
    amount                         NUMBER := Okl_Api.G_MISS_NUM,
    line_number                    NUMBER := Okl_Api.G_MISS_NUM,
    quantity                       NUMBER := Okl_Api.G_MISS_NUM,
    description                    OKL_TXL_AR_INV_LNS_V.DESCRIPTION%TYPE := Okl_Api.G_MISS_CHAR,
    receivables_invoice_id         NUMBER := Okl_Api.G_MISS_NUM,
    date_bill_period_start         OKL_TXL_AR_INV_LNS_V.DATE_BILL_PERIOD_START%TYPE := Okl_Api.G_MISS_DATE,
    amount_applied                 NUMBER := Okl_Api.G_MISS_NUM,
    date_bill_period_end           OKL_TXL_AR_INV_LNS_V.DATE_BILL_PERIOD_END%TYPE := Okl_Api.G_MISS_DATE,
    isl_id                         NUMBER := Okl_Api.G_MISS_NUM,
    ibt_id                         NUMBER := Okl_Api.G_MISS_NUM,
	LATE_CHARGE_REC_ID			   NUMBER := Okl_Api.G_MISS_NUM,
	CLL_ID			   			   NUMBER := Okl_Api.G_MISS_NUM,
-- Start changes on remarketing by fmiao on 10/18/04 --
    inventory_item_id              NUMBER := Okl_Api.G_MISS_NUM,
-- End changes on remarketing by fmiao on 10/18/04 --
    qte_line_id                    NUMBER := Okl_Api.G_MISS_NUM,
    txs_trx_id                     NUMBER := Okl_Api.G_MISS_NUM,
    -- Start Bug 4594310
    bank_acct_id                   NUMBER := Okl_Api.G_MISS_NUM,
    -- End Bug 4594310
    attribute_category             OKL_TXL_AR_INV_LNS_V.ATTRIBUTE_CATEGORY%TYPE := Okl_Api.G_MISS_CHAR,
    attribute1                     OKL_TXL_AR_INV_LNS_V.ATTRIBUTE1%TYPE := Okl_Api.G_MISS_CHAR,
    attribute2                     OKL_TXL_AR_INV_LNS_V.ATTRIBUTE2%TYPE := Okl_Api.G_MISS_CHAR,
    attribute3                     OKL_TXL_AR_INV_LNS_V.ATTRIBUTE3%TYPE := Okl_Api.G_MISS_CHAR,
    attribute4                     OKL_TXL_AR_INV_LNS_V.ATTRIBUTE4%TYPE := Okl_Api.G_MISS_CHAR,
    attribute5                     OKL_TXL_AR_INV_LNS_V.ATTRIBUTE5%TYPE := Okl_Api.G_MISS_CHAR,
    attribute6                     OKL_TXL_AR_INV_LNS_V.ATTRIBUTE6%TYPE := Okl_Api.G_MISS_CHAR,
    attribute7                     OKL_TXL_AR_INV_LNS_V.ATTRIBUTE7%TYPE := Okl_Api.G_MISS_CHAR,
    attribute8                     OKL_TXL_AR_INV_LNS_V.ATTRIBUTE8%TYPE := Okl_Api.G_MISS_CHAR,
    attribute9                     OKL_TXL_AR_INV_LNS_V.ATTRIBUTE9%TYPE := Okl_Api.G_MISS_CHAR,
    attribute10                    OKL_TXL_AR_INV_LNS_V.ATTRIBUTE10%TYPE := Okl_Api.G_MISS_CHAR,
    attribute11                    OKL_TXL_AR_INV_LNS_V.ATTRIBUTE11%TYPE := Okl_Api.G_MISS_CHAR,
    attribute12                    OKL_TXL_AR_INV_LNS_V.ATTRIBUTE12%TYPE := Okl_Api.G_MISS_CHAR,
    attribute13                    OKL_TXL_AR_INV_LNS_V.ATTRIBUTE13%TYPE := Okl_Api.G_MISS_CHAR,
    attribute14                    OKL_TXL_AR_INV_LNS_V.ATTRIBUTE14%TYPE := Okl_Api.G_MISS_CHAR,
    attribute15                    OKL_TXL_AR_INV_LNS_V.ATTRIBUTE15%TYPE := Okl_Api.G_MISS_CHAR,
    request_id                     NUMBER := Okl_Api.G_MISS_NUM,
    program_application_id         NUMBER := Okl_Api.G_MISS_NUM,
    program_id                     NUMBER := Okl_Api.G_MISS_NUM,
    program_update_date            OKL_TXL_AR_INV_LNS_V.PROGRAM_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    org_id                         NUMBER := Okl_Api.G_MISS_NUM,
    inventory_org_id                         NUMBER := Okl_Api.G_MISS_NUM,
    created_by                     NUMBER := Okl_Api.G_MISS_NUM,
    creation_date                  OKL_TXL_AR_INV_LNS_V.CREATION_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_Api.G_MISS_NUM,
    last_update_date               OKL_TXL_AR_INV_LNS_V.LAST_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_Api.G_MISS_NUM,

-- start: 30-Jan-07 cklee  Billing R12 project                             |
TXL_AR_LINE_NUMBER                  OKL_TXL_AR_INV_LNS_B.TXL_AR_LINE_NUMBER%TYPE := Okl_Api.G_MISS_NUM,
TXS_TRX_LINE_ID                  OKL_TXL_AR_INV_LNS_B.TXS_TRX_LINE_ID%TYPE := Okl_Api.G_MISS_NUM,
-- end: 30-Jan-07 cklee  Billing R12 project
TAX_LINE_ID                  OKL_TXL_AR_INV_LNS_B.TAX_LINE_ID%TYPE := Okl_Api.G_MISS_NUM --14-May-08 sechawla 6619311                            |
);
  g_miss_tilv_rec                         tilv_rec_type;
  TYPE tilv_tbl_type IS TABLE OF tilv_rec_type
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
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_TIL_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;

/******************ADDED AFTER TAPI, Sunil T. Mathew (04/16/2001) ****************/
  --GLOBAL MESSAGES
   G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
   G_NO_PARENT_RECORD           CONSTANT   VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
   G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
   G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
   G_NOT_SAME              		CONSTANT   VARCHAR2(200) := 'OKL_CANNOT_BE_SAME';


--GLOBAL VARIABLES
  G_VIEW			CONSTANT   VARCHAR2(30) := 'OKL_TRX_AR_INVOICES_V';
  G_EXCEPTION_HALT_VALIDATION           EXCEPTION;

  ---------------------------------------------------------------------------
  -- validation Procedures and Functions
  ---------------------------------------------------------------------------
 --PROCEDURE validate_unique(p_saiv_rec 	IN 	saiv_rec_type,
 --                     x_return_status OUT NOCOPY VARCHAR2);

/****************END ADDED AFTER TAPI, Sunil T. Mathew (04/16/2001)**************/

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
    p_tilv_rec                     IN tilv_rec_type,
    x_tilv_rec                     OUT NOCOPY tilv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tilv_tbl                     IN tilv_tbl_type,
    x_tilv_tbl                     OUT NOCOPY tilv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tilv_rec                     IN tilv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tilv_tbl                     IN tilv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tilv_rec                     IN tilv_rec_type,
    x_tilv_rec                     OUT NOCOPY tilv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tilv_tbl                     IN tilv_tbl_type,
    x_tilv_tbl                     OUT NOCOPY tilv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tilv_rec                     IN tilv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tilv_tbl                     IN tilv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tilv_rec                     IN tilv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tilv_tbl                     IN tilv_tbl_type);

END Okl_Til_Pvt;

/
