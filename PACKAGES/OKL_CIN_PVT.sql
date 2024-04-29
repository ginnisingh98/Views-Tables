--------------------------------------------------------
--  DDL for Package OKL_CIN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CIN_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSCINS.pls 120.0 2007/03/13 21:19:10 pjgomes noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_CNSLD_AP_INVS Record Spec
  TYPE cin_rec_type IS RECORD (
     cnsld_ap_inv_id                NUMBER
    ,trx_status_code                OKL_CNSLD_AP_INVS.TRX_STATUS_CODE%TYPE
    ,vendor_invoice_number          OKL_CNSLD_AP_INVS.VENDOR_INVOICE_NUMBER%TYPE
    ,currency_code                  OKL_CNSLD_AP_INVS.CURRENCY_CODE%TYPE
    ,currency_conversion_type       OKL_CNSLD_AP_INVS.CURRENCY_CONVERSION_TYPE%TYPE
    ,currency_conversion_rate       NUMBER
    ,currency_conversion_date       OKL_CNSLD_AP_INVS.CURRENCY_CONVERSION_DATE%TYPE
    ,payment_method_code            OKL_CNSLD_AP_INVS.PAYMENT_METHOD_CODE%TYPE
    ,pay_group_lookup_code          OKL_CNSLD_AP_INVS.PAY_GROUP_LOOKUP_CODE%TYPE
    ,invoice_type                   OKL_CNSLD_AP_INVS.INVOICE_TYPE%TYPE
    ,set_of_books_id                NUMBER
    ,try_id                         NUMBER
    ,ipvs_id                        NUMBER
    ,ippt_id                        NUMBER
    ,date_invoiced                  OKL_CNSLD_AP_INVS.DATE_INVOICED%TYPE
    ,amount                         NUMBER
    ,invoice_number                 OKL_CNSLD_AP_INVS.INVOICE_NUMBER%TYPE
    ,date_gl                        OKL_CNSLD_AP_INVS.DATE_GL%TYPE
    ,vendor_id                      NUMBER
    ,org_id                         NUMBER
    ,legal_entity_id                NUMBER
    ,vpa_id                         NUMBER
    ,accts_pay_cc_id                NUMBER
    ,fee_charged_yn                 OKL_CNSLD_AP_INVS.FEE_CHARGED_YN%TYPE
    ,self_bill_yn                   OKL_CNSLD_AP_INVS.SELF_BILL_YN%TYPE
    ,self_bill_inv_num              OKL_CNSLD_AP_INVS.SELF_BILL_INV_NUM%TYPE
    ,match_required_yn              OKL_CNSLD_AP_INVS.MATCH_REQUIRED_YN%TYPE
    ,object_version_number          NUMBER
    ,request_id                     NUMBER
    ,program_application_id         NUMBER
    ,program_id                     NUMBER
    ,program_update_date            OKL_CNSLD_AP_INVS.PROGRAM_UPDATE_DATE%TYPE
    ,attribute_category             OKL_CNSLD_AP_INVS.ATTRIBUTE_CATEGORY%TYPE
    ,attribute1                     OKL_CNSLD_AP_INVS.ATTRIBUTE1%TYPE
    ,attribute2                     OKL_CNSLD_AP_INVS.ATTRIBUTE2%TYPE
    ,attribute3                     OKL_CNSLD_AP_INVS.ATTRIBUTE3%TYPE
    ,attribute4                     OKL_CNSLD_AP_INVS.ATTRIBUTE4%TYPE
    ,attribute5                     OKL_CNSLD_AP_INVS.ATTRIBUTE5%TYPE
    ,attribute6                     OKL_CNSLD_AP_INVS.ATTRIBUTE6%TYPE
    ,attribute7                     OKL_CNSLD_AP_INVS.ATTRIBUTE7%TYPE
    ,attribute8                     OKL_CNSLD_AP_INVS.ATTRIBUTE8%TYPE
    ,attribute9                     OKL_CNSLD_AP_INVS.ATTRIBUTE9%TYPE
    ,attribute10                    OKL_CNSLD_AP_INVS.ATTRIBUTE10%TYPE
    ,attribute11                    OKL_CNSLD_AP_INVS.ATTRIBUTE11%TYPE
    ,attribute12                    OKL_CNSLD_AP_INVS.ATTRIBUTE12%TYPE
    ,attribute13                    OKL_CNSLD_AP_INVS.ATTRIBUTE13%TYPE
    ,attribute14                    OKL_CNSLD_AP_INVS.ATTRIBUTE14%TYPE
    ,attribute15                    OKL_CNSLD_AP_INVS.ATTRIBUTE15%TYPE
    ,created_by                     NUMBER
    ,creation_date                  OKL_CNSLD_AP_INVS.CREATION_DATE%TYPE
    ,last_updated_by                NUMBER
    ,last_update_date               OKL_CNSLD_AP_INVS.LAST_UPDATE_DATE%TYPE
    ,last_update_login              NUMBER);
  G_MISS_cin_rec                          cin_rec_type;
  TYPE cin_tbl_type IS TABLE OF cin_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                      CONSTANT VARCHAR2(200) := OKL_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC   CONSTANT VARCHAR2(200) := OKL_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED          CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED          CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED     CONSTANT VARCHAR2(200) := OKL_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE               CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE                CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN               CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN           CONSTANT VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN            CONSTANT VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200) := 'OKS_SERVICE_AVAILABILITY_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN                CONSTANT VARCHAR2(200) := 'SQLcode';
  G_SQLERRM_TOKEN                CONSTANT VARCHAR2(200) := 'SQLerrm';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_CIN_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cin_rec                      IN cin_rec_type,
    x_cin_rec                      OUT NOCOPY cin_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cin_tbl                      IN cin_tbl_type,
    x_cin_tbl                      OUT NOCOPY cin_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cin_tbl                      IN cin_tbl_type,
    x_cin_tbl                      OUT NOCOPY cin_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cin_rec                      IN cin_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cin_tbl                      IN cin_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cin_tbl                      IN cin_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cin_rec                      IN cin_rec_type,
    x_cin_rec                      OUT NOCOPY cin_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cin_tbl                      IN cin_tbl_type,
    x_cin_tbl                      OUT NOCOPY cin_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cin_tbl                      IN cin_tbl_type,
    x_cin_tbl                      OUT NOCOPY cin_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cin_rec                      IN cin_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cin_tbl                      IN cin_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cin_tbl                      IN cin_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cin_rec                      IN cin_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cin_tbl                      IN cin_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cin_tbl                      IN cin_tbl_type);
END OKL_CIN_PVT;

/
