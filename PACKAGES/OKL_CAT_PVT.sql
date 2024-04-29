--------------------------------------------------------
--  DDL for Package OKL_CAT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CAT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSCATS.pls 120.4 2006/07/11 10:12:33 dkagrawa noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
/*  -- history tables not supported -- 04 APR 2002
  TYPE okl_cash_allctn_rls_h_rec_type IS RECORD (
    id                             NUMBER := Okl_Api.G_MISS_NUM,
    major_version                  NUMBER := Okl_Api.G_MISS_NUM,
    name                           OKL_CASH_ALLCTN_RLS_H.NAME%TYPE := Okl_Api.G_MISS_CHAR,
    object_version_number          NUMBER := Okl_Api.G_MISS_NUM,
    description                    OKL_CASH_ALLCTN_RLS_H.DESCRIPTION%TYPE := Okl_Api.G_MISS_CHAR,
    amount_tolerance_percent       NUMBER, -- := Okl_Api.G_MISS_NUM,
    days_past_quote_valid_toleranc  NUMBER, -- := Okl_Api.G_MISS_NUM,
    months_to_bill_ahead           NUMBER, -- := Okl_Api.G_MISS_NUM,
   	under_payment_allocation_code  OKL_CASH_ALLCTN_RLS_H.UNDER_PAYMENT_ALLOCATION_CODE%TYPE := Okl_Api.G_MISS_CHAR,
	   over_payment_allocation_code   OKL_CASH_ALLCTN_RLS_H.OVER_PAYMENT_ALLOCATION_CODE%TYPE := Okl_Api.G_MISS_CHAR,
   	receipt_msmtch_allocation_code OKL_CASH_ALLCTN_RLS_H.RECEIPT_MSMTCH_ALLOCATION_CODE%TYPE := Okl_Api.G_MISS_CHAR,
    attribute_category             OKL_CASH_ALLCTN_RLS_H.ATTRIBUTE_CATEGORY%TYPE := Okl_Api.G_MISS_CHAR,
    attribute1                     OKL_CASH_ALLCTN_RLS_H.ATTRIBUTE1%TYPE := Okl_Api.G_MISS_CHAR,
    attribute2                     OKL_CASH_ALLCTN_RLS_H.ATTRIBUTE2%TYPE := Okl_Api.G_MISS_CHAR,
    attribute3                     OKL_CASH_ALLCTN_RLS_H.ATTRIBUTE3%TYPE := Okl_Api.G_MISS_CHAR,
    attribute4                     OKL_CASH_ALLCTN_RLS_H.ATTRIBUTE4%TYPE := Okl_Api.G_MISS_CHAR,
    attribute5                     OKL_CASH_ALLCTN_RLS_H.ATTRIBUTE5%TYPE := Okl_Api.G_MISS_CHAR,
    attribute6                     OKL_CASH_ALLCTN_RLS_H.ATTRIBUTE6%TYPE := Okl_Api.G_MISS_CHAR,
    attribute7                     OKL_CASH_ALLCTN_RLS_H.ATTRIBUTE7%TYPE := Okl_Api.G_MISS_CHAR,
    attribute8                     OKL_CASH_ALLCTN_RLS_H.ATTRIBUTE8%TYPE := Okl_Api.G_MISS_CHAR,
    attribute9                     OKL_CASH_ALLCTN_RLS_H.ATTRIBUTE9%TYPE := Okl_Api.G_MISS_CHAR,
    attribute10                    OKL_CASH_ALLCTN_RLS_H.ATTRIBUTE10%TYPE := Okl_Api.G_MISS_CHAR,
    attribute11                    OKL_CASH_ALLCTN_RLS_H.ATTRIBUTE11%TYPE := Okl_Api.G_MISS_CHAR,
    attribute12                    OKL_CASH_ALLCTN_RLS_H.ATTRIBUTE12%TYPE := Okl_Api.G_MISS_CHAR,
    attribute13                    OKL_CASH_ALLCTN_RLS_H.ATTRIBUTE13%TYPE := Okl_Api.G_MISS_CHAR,
    attribute14                    OKL_CASH_ALLCTN_RLS_H.ATTRIBUTE14%TYPE := Okl_Api.G_MISS_CHAR,
    attribute15                    OKL_CASH_ALLCTN_RLS_H.ATTRIBUTE15%TYPE := Okl_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okl_Api.G_MISS_NUM,
    creation_date                  OKL_CASH_ALLCTN_RLS_H.CREATION_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_Api.G_MISS_NUM,
    last_update_date               OKL_CASH_ALLCTN_RLS_H.LAST_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_Api.G_MISS_NUM);
  GMissOklCashAllctnRlsHRec               okl_cash_allctn_rls_h_rec_type;
  TYPE okl_cash_allctn_rls_h_tbl_type IS TABLE OF okl_cash_allctn_rls_h_rec_type
        INDEX BY BINARY_INTEGER;
*/
  TYPE cat_rec_type IS RECORD (
    id                              NUMBER := Okl_Api.G_MISS_NUM,
    name                            OKL_CASH_ALLCTN_RLS.NAME%TYPE := Okl_Api.G_MISS_CHAR,
    object_version_number           NUMBER := Okl_Api.G_MISS_NUM,
    description                     OKL_CASH_ALLCTN_RLS.DESCRIPTION%TYPE := Okl_Api.G_MISS_CHAR,
    start_date                      OKL_CASH_ALLCTN_RLS.START_DATE%TYPE := Okl_Api.G_MISS_DATE,
    end_date                        OKL_CASH_ALLCTN_RLS.END_DATE%TYPE := Okl_Api.G_MISS_DATE,
    amount_tolerance_percent        NUMBER := Okl_Api.G_MISS_NUM,
    days_past_quote_valid_toleranc  NUMBER := Okl_Api.G_MISS_NUM,
    months_to_bill_ahead            NUMBER := Okl_Api.G_MISS_NUM,
    under_payment_allocation_code   OKL_CASH_ALLCTN_RLS.UNDER_PAYMENT_ALLOCATION_CODE%TYPE := Okl_Api.G_MISS_CHAR,
    over_payment_allocation_code    OKL_CASH_ALLCTN_RLS.OVER_PAYMENT_ALLOCATION_CODE%TYPE := Okl_Api.G_MISS_CHAR,
    receipt_msmtch_allocation_code   OKL_CASH_ALLCTN_RLS.RECEIPT_MSMTCH_ALLOCATION_CODE%TYPE := Okl_Api.G_MISS_CHAR,
    default_rule                    OKL_CASH_ALLCTN_RLS.DEFAULT_RULE%TYPE := Okl_Api.G_MISS_CHAR,
    attribute_category              OKL_CASH_ALLCTN_RLS.ATTRIBUTE_CATEGORY%TYPE := Okl_Api.G_MISS_CHAR,
    attribute1                      OKL_CASH_ALLCTN_RLS.ATTRIBUTE1%TYPE := Okl_Api.G_MISS_CHAR,
    attribute2                      OKL_CASH_ALLCTN_RLS.ATTRIBUTE2%TYPE := Okl_Api.G_MISS_CHAR,
    attribute3                      OKL_CASH_ALLCTN_RLS.ATTRIBUTE3%TYPE := Okl_Api.G_MISS_CHAR,
    attribute4                      OKL_CASH_ALLCTN_RLS.ATTRIBUTE4%TYPE := Okl_Api.G_MISS_CHAR,
    attribute5                      OKL_CASH_ALLCTN_RLS.ATTRIBUTE5%TYPE := Okl_Api.G_MISS_CHAR,
    attribute6                      OKL_CASH_ALLCTN_RLS.ATTRIBUTE6%TYPE := Okl_Api.G_MISS_CHAR,
    attribute7                      OKL_CASH_ALLCTN_RLS.ATTRIBUTE7%TYPE := Okl_Api.G_MISS_CHAR,
    attribute8                      OKL_CASH_ALLCTN_RLS.ATTRIBUTE8%TYPE := Okl_Api.G_MISS_CHAR,
    attribute9                      OKL_CASH_ALLCTN_RLS.ATTRIBUTE9%TYPE := Okl_Api.G_MISS_CHAR,
    attribute10                     OKL_CASH_ALLCTN_RLS.ATTRIBUTE10%TYPE := Okl_Api.G_MISS_CHAR,
    attribute11                     OKL_CASH_ALLCTN_RLS.ATTRIBUTE11%TYPE := Okl_Api.G_MISS_CHAR,
    attribute12                     OKL_CASH_ALLCTN_RLS.ATTRIBUTE12%TYPE := Okl_Api.G_MISS_CHAR,
    attribute13                     OKL_CASH_ALLCTN_RLS.ATTRIBUTE13%TYPE := Okl_Api.G_MISS_CHAR,
    attribute14                     OKL_CASH_ALLCTN_RLS.ATTRIBUTE14%TYPE := Okl_Api.G_MISS_CHAR,
    attribute15                     OKL_CASH_ALLCTN_RLS.ATTRIBUTE15%TYPE := Okl_Api.G_MISS_CHAR,
    org_id                          OKL_CASH_ALLCTN_RLS.ORG_ID%TYPE := Okl_Api.G_MISS_NUM,
    created_by                      NUMBER := Okl_Api.G_MISS_NUM,
    creation_date                   OKL_CASH_ALLCTN_RLS.CREATION_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_updated_by                 NUMBER := Okl_Api.G_MISS_NUM,
    last_update_date                OKL_CASH_ALLCTN_RLS.LAST_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_update_login               NUMBER := Okl_Api.G_MISS_NUM,
    CAU_ID                          NUMBER := Okl_Api.G_MISS_NUM,
-- new column  to hold number of days to reserve advanced payment for contract.
    num_days_hold_adv_pay     NUMBER := Okl_Api.G_MISS_NUM );
  g_miss_cat_rec                          cat_rec_type;
  TYPE cat_tbl_type IS TABLE OF cat_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE catv_rec_type IS RECORD (
    id                             NUMBER := Okl_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okl_Api.G_MISS_NUM,
    name                           OKL_CASH_ALLCTN_RLS.NAME%TYPE := Okl_Api.G_MISS_CHAR,
    description                    OKL_CASH_ALLCTN_RLS.DESCRIPTION%TYPE := Okl_Api.G_MISS_CHAR,
    start_date                     OKL_CASH_ALLCTN_RLS.START_DATE%TYPE := Okl_Api.G_MISS_DATE,
    end_date                       OKL_CASH_ALLCTN_RLS.END_DATE%TYPE := Okl_Api.G_MISS_DATE,
    amount_tolerance_percent       NUMBER := Okl_Api.G_MISS_NUM,
    days_past_quote_valid_toleranc NUMBER := Okl_Api.G_MISS_NUM,
    months_to_bill_ahead           NUMBER := Okl_Api.G_MISS_NUM,
   	under_payment_allocation_code  OKL_CASH_ALLCTN_RLS.UNDER_PAYMENT_ALLOCATION_CODE%TYPE := Okl_Api.G_MISS_CHAR,
   	over_payment_allocation_code   OKL_CASH_ALLCTN_RLS.OVER_PAYMENT_ALLOCATION_CODE%TYPE := Okl_Api.G_MISS_CHAR,
   	receipt_msmtch_allocation_code OKL_CASH_ALLCTN_RLS.RECEIPT_MSMTCH_ALLOCATION_CODE%TYPE := Okl_Api.G_MISS_CHAR,
    default_rule                   OKL_CASH_ALLCTN_RLS.DEFAULT_RULE%TYPE := Okl_Api.G_MISS_CHAR,
    attribute_category             OKL_CASH_ALLCTN_RLS.ATTRIBUTE_CATEGORY%TYPE := Okl_Api.G_MISS_CHAR,
    attribute1                     OKL_CASH_ALLCTN_RLS.ATTRIBUTE1%TYPE := Okl_Api.G_MISS_CHAR,
    attribute2                     OKL_CASH_ALLCTN_RLS.ATTRIBUTE2%TYPE := Okl_Api.G_MISS_CHAR,
    attribute3                     OKL_CASH_ALLCTN_RLS.ATTRIBUTE3%TYPE := Okl_Api.G_MISS_CHAR,
    attribute4                     OKL_CASH_ALLCTN_RLS.ATTRIBUTE4%TYPE := Okl_Api.G_MISS_CHAR,
    attribute5                     OKL_CASH_ALLCTN_RLS.ATTRIBUTE5%TYPE := Okl_Api.G_MISS_CHAR,
    attribute6                     OKL_CASH_ALLCTN_RLS.ATTRIBUTE6%TYPE := Okl_Api.G_MISS_CHAR,
    attribute7                     OKL_CASH_ALLCTN_RLS.ATTRIBUTE7%TYPE := Okl_Api.G_MISS_CHAR,
    attribute8                     OKL_CASH_ALLCTN_RLS.ATTRIBUTE8%TYPE := Okl_Api.G_MISS_CHAR,
    attribute9                     OKL_CASH_ALLCTN_RLS.ATTRIBUTE9%TYPE := Okl_Api.G_MISS_CHAR,
    attribute10                    OKL_CASH_ALLCTN_RLS.ATTRIBUTE10%TYPE := Okl_Api.G_MISS_CHAR,
    attribute11                    OKL_CASH_ALLCTN_RLS.ATTRIBUTE11%TYPE := Okl_Api.G_MISS_CHAR,
    attribute12                    OKL_CASH_ALLCTN_RLS.ATTRIBUTE12%TYPE := Okl_Api.G_MISS_CHAR,
    attribute13                    OKL_CASH_ALLCTN_RLS.ATTRIBUTE13%TYPE := Okl_Api.G_MISS_CHAR,
    attribute14                    OKL_CASH_ALLCTN_RLS.ATTRIBUTE14%TYPE := Okl_Api.G_MISS_CHAR,
    attribute15                    OKL_CASH_ALLCTN_RLS.ATTRIBUTE15%TYPE := Okl_Api.G_MISS_CHAR,
    org_id                         OKL_CASH_ALLCTN_RLS.ORG_ID%TYPE := Okl_Api.G_MISS_NUM,
    created_by                     NUMBER := Okl_Api.G_MISS_NUM,
    creation_date                  OKL_CASH_ALLCTN_RLS.CREATION_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_Api.G_MISS_NUM,
    last_update_date               OKL_CASH_ALLCTN_RLS.LAST_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_Api.G_MISS_NUM,
    CAU_ID                         NUMBER := Okl_Api.G_MISS_NUM,
-- new column  to hold number of days to reserve advanced payment for contract.
    num_days_hold_adv_pay    NUMBER := Okl_Api.G_MISS_NUM );
  g_miss_catv_rec                         catv_rec_type;
  TYPE catv_tbl_type IS TABLE OF catv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := Okl_Api.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := Okl_Api.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := Okl_Api.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := Okl_Api.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := Okl_Api.G_RECORD_LOGICALLY_DELETED;

  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := Okc_Api.G_REQUIRED_VALUE;

  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := Okl_Api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := Okl_Api.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okl_Api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okl_Api.G_CHILD_TABLE_TOKEN;

  /****************** ADDED AFTER TAPI ************************************/

  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
   G_NO_PARENT_RECORD           CONSTANT   VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'OKC_SQLerrm';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'OKC_SQLcode';
  G_UPPERCASE_REQUIRED   CONSTANT VARCHAR2(200) := 'OKC_UPPER_CASE_REQUIRED';
  --G_UNQS     CONSTANT VARCHAR2(200) := 'OKC_VALUES_NOT_UNIQUE';
  G_UNQS  CONSTANT VARCHAR2(200) := 'OKL_VALUES_NOT_UNIQUE';
  G_ONE_DOI    CONSTANT VARCHAR2(200) := 'OKC_ONE_DOI';
  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION  EXCEPTION;
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_VIEW                        CONSTANT   VARCHAR2(30) := 'OKL_CASH_ALLCTN_RLS';
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_CAT_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_rec                     IN catv_rec_type,
    x_catv_rec                     OUT NOCOPY catv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_tbl                     IN catv_tbl_type,
    x_catv_tbl                     OUT NOCOPY catv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_rec                     IN catv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_tbl                     IN catv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_rec                     IN catv_rec_type,
    x_catv_rec                     OUT NOCOPY catv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_tbl                     IN catv_tbl_type,
    x_catv_tbl                     OUT NOCOPY catv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_rec                     IN catv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_tbl                     IN catv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_rec                     IN catv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_tbl                     IN catv_tbl_type);

END Okl_Cat_Pvt;

/
