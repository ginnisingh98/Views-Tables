--------------------------------------------------------
--  DDL for Package OKL_SUBSIDY_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SUBSIDY_PROCESS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSBPS.pls 120.3 2006/04/05 21:45:25 stmathew noship $ */

   -- OKL_ASSET_SUBSIDIES_UV Record Spec
  TYPE asbv_rec_type IS RECORD (
       subsidy_id               NUMBER := OKL_API.G_MISS_NUM,
       subsidy_cle_id           NUMBER := OKL_API.G_MISS_NUM,
       name                     OKL_SUBSIDIES_B.NAME%TYPE := OKL_API.G_MISS_CHAR,
       description              OKL_SUBSIDIES_TL.SHORT_DESCRIPTION%TYPE := OKL_API.G_MISS_CHAR,
       amount                   NUMBER := OKL_API.G_MISS_NUM,
       stream_type_id           NUMBER := OKL_API.G_MISS_NUM,
       accounting_method_code   OKL_SUBSIDIES_B.ACCOUNTING_METHOD_CODE%TYPE := OKL_API.G_MISS_CHAR,
       maximum_term             NUMBER := OKL_API.G_MISS_NUM,
       subsidy_override_amount  NUMBER := OKL_API.G_MISS_NUM,
       dnz_chr_id               NUMBER := OKL_API.G_MISS_NUM,
       asset_cle_id             NUMBER := OKL_API.G_MISS_NUM,
       cpl_id                   NUMBER := OKL_API.G_MISS_NUM,
       vendor_id                NUMBER := OKL_API.G_MISS_NUM,
       vendor_name              PO_VENDORS.VENDOR_NAME%TYPE := OKL_API.G_MISS_CHAR,
       pay_site_id              NUMBER := OKL_API.G_MISS_NUM,
       payment_term_id          NUMBER := OKL_API.G_MISS_NUM,
       payment_method_code      FND_LOOKUPS.LOOKUP_CODE%TYPE := OKL_API.G_MISS_CHAR,
       pay_group_code           PO_VENDORS.PAY_GROUP_LOOKUP_CODE%TYPE := OKL_API.G_MISS_CHAR,
       --extra attributes picked up from subsidy setup may be required downstream
       start_date               OKC_K_LINES_B.start_date%TYPE := OKL_API.G_MISS_DATE,
       end_date                 OKC_K_LINES_B.end_date%TYPE   := OKL_API.G_MISS_DATE,
       expire_after_days        NUMBER := OKL_API.G_MISS_NUM,
       currency_code            OKC_K_LINES_B.currency_code%TYPE := OKL_API.G_MISS_CHAR,
       exclusive_yn             OKL_SUBSIDIES_B.EXCLUSIVE_YN%TYPE := OKL_API.G_MISS_CHAR,
       applicable_to_release_yn OKL_SUBSIDIES_B.APPLICABLE_TO_RELEASE_YN%TYPE := OKL_API.G_MISS_CHAR,
       recourse_yn              OKL_SUBSIDIES_B.RECOURSE_YN%TYPE := OKL_API.G_MISS_CHAR,
       termination_refund_basis OKL_SUBSIDIES_B.termination_refund_basis%TYPE := OKL_API.G_MISS_CHAR,
       refund_formula_id        NUMBER := OKL_API.G_MISS_NUM,
       receipt_method_code      OKL_SUBSIDIES_B.receipt_method_code%TYPE := OKL_API.G_MISS_CHAR,
       customer_visible_yn      OKL_SUBSIDIES_B.customer_visible_yn%TYPE := OKL_API.G_MISS_CHAR
       );

   TYPE asbv_tbl_type IS TABLE OF asbv_rec_type
        INDEX BY BINARY_INTEGER;


  G_SUBLINE_LTY_CODE OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'SUBSIDY';
  G_STREAM_TYPE_CLASS OKL_STRM_TYPE_B.STREAM_TYPE_CLASS%TYPE := 'SUBSIDY';
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
  G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXP_ERROR';
  G_SQLCODE_TOKEN                CONSTANT VARCHAR2(200) := 'SQLcode';
  G_SQLERRM_TOKEN                CONSTANT VARCHAR2(200) := 'SQLerrm';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_SUBSIDY_PROCESS_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;


PROCEDURE is_contract_subsidized(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    x_subsidized                   OUT NOCOPY VARCHAR2);

PROCEDURE is_asset_subsidized(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asset_cle_id                 IN  NUMBER,
    x_subsidized                   OUT NOCOPY VARCHAR2);

PROCEDURE calculate_subsidy_amount(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subsidy_cle_id               IN  NUMBER,
    x_subsidy_amount               OUT NOCOPY NUMBER);

PROCEDURE get_subsidy_amount(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subsidy_cle_id               IN  NUMBER,
    x_asbv_rec                     OUT NOCOPY asbv_rec_type);

PROCEDURE get_subsidy_amount(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subsidy_cle_id               IN  NUMBER,
    x_subsidy_amount               OUT NOCOPY NUMBER);


PROCEDURE get_asset_subsidy_amount(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asset_cle_id                 IN  NUMBER,
    x_asbv_tbl                     OUT NOCOPY asbv_tbl_type);

PROCEDURE get_asset_subsidy_amount(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asset_cle_id                 IN  NUMBER,
    p_accounting_method            IN  VARCHAR2 default NULL,
    x_subsidy_amount               OUT NOCOPY NUMBER);


PROCEDURE calculate_asset_subsidy(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asset_cle_id                 IN  NUMBER,
    x_subsidy_amount               OUT NOCOPY NUMBER);

PROCEDURE get_contract_subsidy_amount(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    x_asbv_tbl                     OUT NOCOPY asbv_tbl_type);

PROCEDURE get_contract_subsidy_amount(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_accounting_method            IN  VARCHAR2 default NULL,
    x_subsidy_amount               OUT NOCOPY NUMBER);

PROCEDURE calculate_contract_subsidy(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    x_subsidy_amount               OUT NOCOPY NUMBER);

PROCEDURE get_funding_subsidy_amount(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_asset_cle_id                 IN  NUMBER,
    p_vendor_id                    IN  NUMBER DEFAULT NULL,
    x_subsidy_amount               OUT NOCOPY NUMBER);

PROCEDURE get_partial_subsidy_amount(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asset_cle_id                 IN  NUMBER,
    p_req_fund_amount              IN  NUMBER,
    x_asbv_tbl                     OUT NOCOPY asbv_tbl_type);

PROCEDURE rebook_synchronize(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rbk_chr_id                   in number,
    p_orig_chr_id                  in number
    );

Procedure Create_Billing_Trx
           (p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_chr_id         IN  NUMBER);

--Bug# 3948361
Procedure get_relk_termn_basis
          (p_api_version    IN  NUMBER,
           p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
           x_return_status  OUT NOCOPY VARCHAR2,
           x_msg_count      OUT NOCOPY NUMBER,
           x_msg_data       OUT NOCOPY VARCHAR2,
           p_chr_id         IN  NUMBER,
           p_subsidy_id     IN  NUMBER,
           x_release_basis  OUT NOCOPY varchar2);
END OKL_SUBSIDY_PROCESS_PVT;

 

/
