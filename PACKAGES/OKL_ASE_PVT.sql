--------------------------------------------------------
--  DDL for Package OKL_ASE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ASE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSASES.pls 120.4 2006/07/11 10:10:08 dkagrawa noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_ACCT_SOURCES_V Record Spec
  TYPE asev_rec_type IS RECORD (
     -- udhenuko Bug#5042061 - Modified - Start
     -- id                             NUMBER := Okc_Api.G_MISS_NUM
     id                             OKL_ACCT_SOURCES.ID%TYPE := Okc_Api.G_MISS_CHAR
     -- udhenuko Bug#5042061 - Modified - End
    ,source_table                   OKL_ACCT_SOURCES.SOURCE_TABLE%TYPE := Okc_Api.G_MISS_CHAR
    ,source_id                      NUMBER := Okc_Api.G_MISS_NUM
    ,pdt_id                         NUMBER := Okc_Api.G_MISS_NUM
    ,try_id                         NUMBER := Okc_Api.G_MISS_NUM
    ,sty_id                         NUMBER := Okc_Api.G_MISS_NUM
    ,memo_yn                        OKL_ACCT_SOURCES.MEMO_YN%TYPE := Okc_Api.G_MISS_CHAR
    ,factor_investor_flag           OKL_ACCT_SOURCES.FACTOR_INVESTOR_FLAG%TYPE := Okc_Api.G_MISS_CHAR
    ,factor_investor_code           OKL_ACCT_SOURCES.FACTOR_INVESTOR_CODE%TYPE := Okc_Api.G_MISS_CHAR
    ,amount                         NUMBER := Okc_Api.G_MISS_NUM
    ,formula_used                   OKL_ACCT_SOURCES.FORMULA_USED%TYPE := Okc_Api.G_MISS_CHAR
    ,entered_date                   OKL_ACCT_SOURCES.ENTERED_DATE%TYPE := Okc_Api.G_MISS_DATE
    ,accounting_date                OKL_ACCT_SOURCES.ACCOUNTING_DATE%TYPE := Okc_Api.G_MISS_DATE
    ,gl_reversal_flag               OKL_ACCT_SOURCES.GL_REVERSAL_FLAG%TYPE := Okc_Api.G_MISS_CHAR
    ,post_to_gl                     OKL_ACCT_SOURCES.POST_TO_GL%TYPE := Okc_Api.G_MISS_CHAR
    ,currency_code                  OKL_ACCT_SOURCES.CURRENCY_CODE%TYPE := Okc_Api.G_MISS_CHAR
    ,currency_conversion_type       OKL_ACCT_SOURCES.CURRENCY_CONVERSION_TYPE%TYPE := Okc_Api.G_MISS_CHAR
    ,currency_conversion_date       OKL_ACCT_SOURCES.CURRENCY_CONVERSION_DATE%TYPE := Okc_Api.G_MISS_DATE
    ,currency_conversion_rate       NUMBER := Okc_Api.G_MISS_NUM
    ,khr_id                         NUMBER := Okc_Api.G_MISS_NUM
    ,kle_id                         NUMBER := Okc_Api.G_MISS_NUM
    ,pay_vendor_sites_pk            OKL_ACCT_SOURCES.PAY_VENDOR_SITES_PK%TYPE := Okc_Api.G_MISS_CHAR
    ,rec_site_uses_pk               OKL_ACCT_SOURCES.REC_SITE_USES_PK%TYPE := Okc_Api.G_MISS_CHAR
    ,asset_category_id_pk1          OKL_ACCT_SOURCES.ASSET_CATEGORY_ID_PK1%TYPE := Okc_Api.G_MISS_CHAR
    ,asset_book_pk2                 OKL_ACCT_SOURCES.ASSET_BOOK_PK2%TYPE := Okc_Api.G_MISS_CHAR
    ,pay_financial_options_pk       OKL_ACCT_SOURCES.PAY_FINANCIAL_OPTIONS_PK%TYPE := Okc_Api.G_MISS_CHAR
    ,jtf_sales_reps_pk              OKL_ACCT_SOURCES.JTF_SALES_REPS_PK%TYPE := Okc_Api.G_MISS_CHAR
    ,inventory_item_id_pk1          OKL_ACCT_SOURCES.INVENTORY_ITEM_ID_PK1%TYPE := Okc_Api.G_MISS_CHAR
    ,inventory_org_id_pk2           OKL_ACCT_SOURCES.INVENTORY_ORG_ID_PK2%TYPE := Okc_Api.G_MISS_CHAR
    ,rec_trx_types_pk               OKL_ACCT_SOURCES.REC_TRX_TYPES_PK%TYPE := Okc_Api.G_MISS_CHAR
    ,avl_id                         NUMBER := Okc_Api.G_MISS_NUM
    ,local_product_yn               OKL_ACCT_SOURCES.LOCAL_PRODUCT_YN%TYPE := Okc_Api.G_MISS_CHAR
    ,internal_status                OKL_ACCT_SOURCES.INTERNAL_STATUS%TYPE := Okc_Api.G_MISS_CHAR
    ,custom_status                  OKL_ACCT_SOURCES.CUSTOM_STATUS%TYPE := Okc_Api.G_MISS_CHAR
    ,source_indicator_flag          OKL_ACCT_SOURCES.SOURCE_INDICATOR_FLAG%TYPE := Okc_Api.G_MISS_CHAR
    ,org_id                         NUMBER := Okc_Api.G_MISS_NUM
    ,program_id                     NUMBER := Okc_Api.G_MISS_NUM
    ,program_application_id         NUMBER := Okc_Api.G_MISS_NUM
    ,request_id                     NUMBER := Okc_Api.G_MISS_NUM
    ,program_update_date            OKL_ACCT_SOURCES.PROGRAM_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE
    ,created_by                     NUMBER := Okc_Api.G_MISS_NUM
    ,creation_date                  OKL_ACCT_SOURCES.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE
    ,last_updated_by                NUMBER := Okc_Api.G_MISS_NUM
    ,last_update_date               OKL_ACCT_SOURCES.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE
    ,last_update_login              NUMBER := Okc_Api.G_MISS_NUM);
  G_MISS_asev_rec                         asev_rec_type;
  TYPE asev_tbl_type IS TABLE OF asev_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_ACCT_SOURCES Record Spec
  TYPE ase_rec_type IS RECORD (
     -- udhenuko Bug#5042061 - Modified - Start
     -- id                             NUMBER := Okc_Api.G_MISS_NUM
     id                             OKL_ACCT_SOURCES.ID%TYPE := Okc_Api.G_MISS_CHAR
     -- udhenuko Bug#5042061 - Modified - Start
    ,source_table                   OKL_ACCT_SOURCES.SOURCE_TABLE%TYPE := Okc_Api.G_MISS_CHAR
    ,source_id                      NUMBER := Okc_Api.G_MISS_NUM
    ,pdt_id                         NUMBER := Okc_Api.G_MISS_NUM
    ,try_id                         NUMBER := Okc_Api.G_MISS_NUM
    ,sty_id                         NUMBER := Okc_Api.G_MISS_NUM
    ,memo_yn                        OKL_ACCT_SOURCES.MEMO_YN%TYPE := Okc_Api.G_MISS_CHAR
    ,factor_investor_flag           OKL_ACCT_SOURCES.FACTOR_INVESTOR_FLAG%TYPE := Okc_Api.G_MISS_CHAR
    ,factor_investor_code           OKL_ACCT_SOURCES.FACTOR_INVESTOR_CODE%TYPE := Okc_Api.G_MISS_CHAR
    ,amount                         NUMBER := Okc_Api.G_MISS_NUM
    ,formula_used                   OKL_ACCT_SOURCES.FORMULA_USED%TYPE := Okc_Api.G_MISS_CHAR
    ,entered_date                   OKL_ACCT_SOURCES.ENTERED_DATE%TYPE := Okc_Api.G_MISS_DATE
    ,accounting_date                OKL_ACCT_SOURCES.ACCOUNTING_DATE%TYPE := Okc_Api.G_MISS_DATE
    ,gl_reversal_flag               OKL_ACCT_SOURCES.GL_REVERSAL_FLAG%TYPE := Okc_Api.G_MISS_CHAR
    ,post_to_gl                     OKL_ACCT_SOURCES.POST_TO_GL%TYPE := Okc_Api.G_MISS_CHAR
    ,currency_code                  OKL_ACCT_SOURCES.CURRENCY_CODE%TYPE := Okc_Api.G_MISS_CHAR
    ,currency_conversion_type       OKL_ACCT_SOURCES.CURRENCY_CONVERSION_TYPE%TYPE := Okc_Api.G_MISS_CHAR
    ,currency_conversion_date       OKL_ACCT_SOURCES.CURRENCY_CONVERSION_DATE%TYPE := Okc_Api.G_MISS_DATE
    ,currency_conversion_rate       NUMBER := Okc_Api.G_MISS_NUM
    ,khr_id                         NUMBER := Okc_Api.G_MISS_NUM
    ,kle_id                         NUMBER := Okc_Api.G_MISS_NUM
    ,pay_vendor_sites_pk            OKL_ACCT_SOURCES.PAY_VENDOR_SITES_PK%TYPE := Okc_Api.G_MISS_CHAR
    ,rec_site_uses_pk               OKL_ACCT_SOURCES.REC_SITE_USES_PK%TYPE := Okc_Api.G_MISS_CHAR
    ,asset_category_id_pk1          OKL_ACCT_SOURCES.ASSET_CATEGORY_ID_PK1%TYPE := Okc_Api.G_MISS_CHAR
    ,asset_book_pk2                 OKL_ACCT_SOURCES.ASSET_BOOK_PK2%TYPE := Okc_Api.G_MISS_CHAR
    ,pay_financial_options_pk       OKL_ACCT_SOURCES.PAY_FINANCIAL_OPTIONS_PK%TYPE := Okc_Api.G_MISS_CHAR
    ,jtf_sales_reps_pk              OKL_ACCT_SOURCES.JTF_SALES_REPS_PK%TYPE := Okc_Api.G_MISS_CHAR
    ,inventory_item_id_pk1          OKL_ACCT_SOURCES.INVENTORY_ITEM_ID_PK1%TYPE := Okc_Api.G_MISS_CHAR
    ,inventory_org_id_pk2           OKL_ACCT_SOURCES.INVENTORY_ORG_ID_PK2%TYPE := Okc_Api.G_MISS_CHAR
    ,rec_trx_types_pk               OKL_ACCT_SOURCES.REC_TRX_TYPES_PK%TYPE := Okc_Api.G_MISS_CHAR
    ,avl_id                         NUMBER := Okc_Api.G_MISS_NUM
    ,local_product_yn               OKL_ACCT_SOURCES.LOCAL_PRODUCT_YN%TYPE := Okc_Api.G_MISS_CHAR
    ,internal_status                OKL_ACCT_SOURCES.INTERNAL_STATUS%TYPE := Okc_Api.G_MISS_CHAR
    ,custom_status                  OKL_ACCT_SOURCES.CUSTOM_STATUS%TYPE := Okc_Api.G_MISS_CHAR
    ,source_indicator_flag          OKL_ACCT_SOURCES.SOURCE_INDICATOR_FLAG%TYPE := Okc_Api.G_MISS_CHAR
    ,org_id                         NUMBER := Okc_Api.G_MISS_NUM
    ,program_id                     NUMBER := Okc_Api.G_MISS_NUM
    ,program_application_id         NUMBER := Okc_Api.G_MISS_NUM
    ,request_id                     NUMBER := Okc_Api.G_MISS_NUM
    ,program_update_date            OKL_ACCT_SOURCES.PROGRAM_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE
    ,created_by                     NUMBER := Okc_Api.G_MISS_NUM
    ,creation_date                  OKL_ACCT_SOURCES.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE
    ,last_updated_by                NUMBER := Okc_Api.G_MISS_NUM
    ,last_update_date               OKL_ACCT_SOURCES.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE
    ,last_update_login              NUMBER := Okc_Api.G_MISS_NUM);
  G_MISS_ase_rec                          ase_rec_type;
  TYPE ase_tbl_type IS TABLE OF ase_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                      CONSTANT VARCHAR2(200) := Okc_Api.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC   CONSTANT VARCHAR2(200) := Okc_Api.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED          CONSTANT VARCHAR2(200) := Okc_Api.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED          CONSTANT VARCHAR2(200) := Okc_Api.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED     CONSTANT VARCHAR2(200) := Okc_Api.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE               CONSTANT VARCHAR2(200) := Okc_Api.G_REQUIRED_VALUE;
  G_INVALID_VALUE                CONSTANT VARCHAR2(200) := Okc_Api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN               CONSTANT VARCHAR2(200) := Okc_Api.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN           CONSTANT VARCHAR2(200) := Okc_Api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN            CONSTANT VARCHAR2(200) := Okc_Api.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN                CONSTANT VARCHAR2(200) := 'SQLCODE';
  G_SQLERRM_TOKEN                CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_NO_PARENT_RECORD            CONSTANT VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_ASE_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := Okc_Api.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asev_rec                     IN asev_rec_type,
    x_asev_rec                     OUT NOCOPY asev_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asev_tbl                     IN asev_tbl_type,
    x_asev_tbl                     OUT NOCOPY asev_tbl_type);

     --Added by gboomina on 14-Oct-2005 for Accruals Performance Tuning
     --Bug 4662173 - Start of Changes
     PROCEDURE insert_row_bulk(
       p_api_version                  IN NUMBER,
       p_init_msg_list                IN VARCHAR2,
       x_return_status                OUT NOCOPY VARCHAR2,
       x_msg_count                    OUT NOCOPY NUMBER,
       x_msg_data                     OUT NOCOPY VARCHAR2,
       p_asev_tbl                     IN asev_tbl_type,
       x_asev_tbl                     OUT NOCOPY asev_tbl_type);
     --Bug 4662173 - End of Changes

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asev_rec                     IN asev_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asev_tbl                     IN asev_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asev_rec                     IN asev_rec_type,
    x_asev_rec                     OUT NOCOPY asev_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asev_tbl                     IN asev_tbl_type,
    x_asev_tbl                     OUT NOCOPY asev_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asev_rec                     IN asev_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asev_tbl                     IN asev_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asev_rec                     IN asev_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asev_tbl                     IN asev_tbl_type);
END Okl_Ase_Pvt;

/
