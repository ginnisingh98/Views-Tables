--------------------------------------------------------
--  DDL for Package OKL_LA_PAYMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LA_PAYMENTS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRPYTS.pls 120.5.12010000.2 2009/01/05 20:35:55 rkuttiya ship $ */
  /* *************************************** */
  /* 2003-OCT-15    Payment Details Enhancement bug 2757289 */
  /* 2003-NOV-14    bug 3253989 */
/*-------------------------------------------------------------------------------------+
| --start of comments                                                                  |
| --Description  :                ashariff - Created                                   |
| -- History     :                2003-OCT-15 ashariff - bug 2757289                   |
| -- History     :                2003-NOV-14 ashariff - bug 3253989                   |
| -- end of comments                                                                   |
| 06-02-2005 cklee/mvasudev -- Fixed Bug#4392051/okl.h 4437938                         |
| 15-Sep-05 apaul 4542290                                                     |
| Variable interest schedules made public with ICB and RRM to be called from  |
| OKL_CONTRACT_PVT create API                                                 |
| 24-Aug-2006 cklee/rajose R12 bug#5514073-OKL.H bug#5441811 for incorrect payment     |
| structure when adding stub days.                                                     |
| 24-Oct-2007 rpillay   Bug# 6438785: Added procedure update_pymt_start_date to        |
|                       update the payment start dates when the contract or            |
|                       line start dates are changed.                                  |
| 25-Oct-2007 rpillay   Bug# 6438785: Added parameter p_validate_date_yn to procedure  |
|                       calculate_details                                              |
| 05-JAN-09   rkuttiya  Bug # 7498330 Added parameter p_source_trx to procedure|
|                       delete_payment                                        |
|-------------------------------------------------------------------------------------*/


TYPE pym_rec_type IS RECORD (
    RULE_ID                            OKC_RULES_V.ID%TYPE := OKL_API.G_MISS_NUM,
    STUB_DAYS                          OKC_RULES_V.RULE_INFORMATION7%TYPE := OKL_API.G_MISS_CHAR,
    STUB_AMOUNT                        OKC_RULES_V.RULE_INFORMATION8%TYPE := OKL_API.G_MISS_CHAR,
    PERIOD                             OKC_RULES_V.RULE_INFORMATION3%TYPE := OKL_API.G_MISS_CHAR,
    AMOUNT                             OKC_RULES_V.RULE_INFORMATION4%TYPE := OKL_API.G_MISS_CHAR,
    SORT_DATE                          OKC_RULES_V.RULE_INFORMATION2%TYPE := OKL_API.G_MISS_CHAR,
    UPDATE_TYPE                        VARCHAR2(20) := OKL_API.G_MISS_CHAR
    );


TYPE pym_del_rec_type IS RECORD (
    CHR_ID                            OKC_K_HEADERS_B.ID%TYPE := OKL_API.G_MISS_NUM,
    RGP_ID                            OKC_RULES_V.RGP_ID%TYPE := OKL_API.G_MISS_NUM,
    SLH_ID                            OKC_RULES_V.ID%TYPE := OKL_API.G_MISS_NUM
    );

TYPE pym_hdr_rec_type IS RECORD (
    STRUCTURE                    VARCHAR2(1) DEFAULT NULL,
    STRUCTURE_NAME               VARCHAR2(2000) := OKL_API.G_MISS_CHAR,
    FREQUENCY                    VARCHAR2(1) DEFAULT NULL,
    FREQUENCY_NAME               VARCHAR2(2000) := OKL_API.G_MISS_CHAR,
    ARREARS                      VARCHAR2(1) DEFAULT NULL,
    ARREARS_NAME                 VARCHAR2(2000) := OKL_API.G_MISS_CHAR
    );


  TYPE pym_tbl_type IS TABLE OF pym_rec_type INDEX BY BINARY_INTEGER;
  TYPE pym_del_tbl_type IS TABLE OF pym_del_rec_type INDEX BY BINARY_INTEGER;
  subtype rulv_rec_type is OKL_RULE_PUB.rulv_rec_type;
  subtype rulv_tbl_type is OKL_RULE_PUB.rulv_tbl_type;


    G_AK_REGION_NAME varchar2(19) := 'OKL_LA_PAYMENTS';


PROCEDURE process_payment(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  OKC_K_HEADERS_B.ID%TYPE,
    p_service_fee_id               IN  OKC_K_LINES_B.ID%TYPE := OKL_API.G_MISS_NUM,
    p_asset_id                     IN  OKC_K_LINES_B.ID%TYPE := OKL_API.G_MISS_NUM,
    p_payment_id                   IN  OKL_STRMTYP_SOURCE_V.ID1%TYPE,
    p_pym_hdr_rec                  IN  pym_hdr_rec_type,
    p_pym_tbl                      IN  pym_tbl_type,
    p_update_type                  IN  VARCHAR2 DEFAULT 'UPDATE',
    x_rulv_tbl                     OUT NOCOPY rulv_tbl_type);


PROCEDURE process_payment(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                           OKC_K_HEADERS_B.ID%TYPE,
    p_service_fee_id                   OKC_K_LINES_B.ID%TYPE := OKL_API.G_MISS_NUM,
    p_asset_id                         OKC_K_LINES_B.ID%TYPE := OKL_API.G_MISS_NUM,
    p_payment_id                       OKL_STRMTYP_SOURCE_V.ID1%TYPE,
    p_update_type                  IN  VARCHAR2,
    x_rulv_tbl                     OUT NOCOPY rulv_tbl_type);


FUNCTION get_display_end_date(
    p_start_date      IN  VARCHAR2,
    p_stub_days       IN  VARCHAR2 DEFAULT NULL,
    p_frequency       IN  VARCHAR2,
    p_period          IN  VARCHAR2 DEFAULT NULL,
    ---- mvasudev,06-02-2005,Bug#4392051
    p_start_day   IN NUMBER DEFAULT NULL,
    p_contract_end_date IN DATE DEFAULT NULL --Bug#5441811
   )
    RETURN VARCHAR2;

FUNCTION get_order_sequence(
    p_sequence        IN  VARCHAR2)
    RETURN number;

PROCEDURE calculate_details(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN NUMBER,
    p_rgp_id                       IN NUMBER,
    p_slh_id                       IN VARCHAR2,
    structure                      IN VARCHAR2 DEFAULT NULL,
    frequency                      IN VARCHAR2 DEFAULT NULL,
    arrears                        IN VARCHAR2 DEFAULT NULL,
    -- Bug# 6438785
    p_validate_date_yn             IN VARCHAR2 DEFAULT 'Y');

PROCEDURE delete_payment(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_pym_tbl                  IN  pym_del_tbl_type,
   -- Bug # 7498330
    p_source_trx                   IN VARCHAR2 DEFAULT 'NA');

FUNCTION get_start_day(
    p_rule_id      IN  NUMBER
   ,p_dnz_chr_id IN NUMBER
   ,p_rgp_id IN NUMBER
   ,p_slh_id IN NUMBER
   ,p_start_date IN VARCHAR2)
RETURN NUMBER;

PROCEDURE variable_interest_schedule(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN NUMBER,
    x_rulv_tbl                     OUT NOCOPY rulv_tbl_type
                                   );

-- Bug# 6438785
-- Update the start dates for payments when the Contract start date
-- or Line start date is changed.
PROCEDURE update_pymt_start_date(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN NUMBER,
    p_cle_id                       IN NUMBER DEFAULT NULL);


    /* *************************************** */
END OKL_LA_PAYMENTS_PVT;

/
