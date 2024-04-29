--------------------------------------------------------
--  DDL for Package OKL_SEC_INVESTOR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SEC_INVESTOR_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSZIS.pls 115.5 2003/10/22 23:14:11 ashariff noship $ */
  /* *************************************** */

TYPE inv_rec_type IS RECORD (
    cpl_id                             NUMBER := OKC_API.G_MISS_NUM,
    cpl_cpl_id                         NUMBER := OKC_API.G_MISS_NUM,
    cpl_chr_id                         NUMBER := OKC_API.G_MISS_NUM,
    cpl_cle_id                         NUMBER := OKC_API.G_MISS_NUM,
    cpl_rle_code                       OKC_K_PARTY_ROLES_V.RLE_CODE%TYPE := OKC_API.G_MISS_CHAR,
    cpl_dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM,
    cpl_object1_id1                    OKC_K_PARTY_ROLES_V.OBJECT1_ID1%TYPE := OKC_API.G_MISS_CHAR,
    cpl_object1_id2                    OKC_K_PARTY_ROLES_V.OBJECT1_ID2%TYPE := OKC_API.G_MISS_CHAR,
    cpl_jtot_object1_code              OKC_K_PARTY_ROLES_V.jtot_object1_code%TYPE := OKC_API.G_MISS_CHAR,
    cle_id                             NUMBER := OKC_API.G_MISS_NUM,
    cle_lse_id                         NUMBER := OKC_API.G_MISS_NUM,
    cle_line_number                    OKC_K_LINES_V.LINE_NUMBER%TYPE := OKC_API.G_MISS_CHAR,
    cle_sts_code                       OKC_K_LINES_V.STS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    cle_comments                       OKC_K_LINES_V.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    cle_date_terminated                OKC_K_LINES_V.DATE_TERMINATED%TYPE := OKC_API.G_MISS_DATE,
    cle_start_date                     OKC_K_LINES_V.START_DATE%TYPE := OKC_API.G_MISS_DATE,
    cle_end_date                       OKC_K_LINES_V.END_DATE%TYPE := OKC_API.G_MISS_DATE,
    KLE_ID                             NUMBER := OKL_API.G_MISS_NUM,
    KLE_PERCENT_STAKE                   NUMBER := OKL_API.G_MISS_NUM,
    KLE_PERCENT                         NUMBER := OKL_API.G_MISS_NUM,
    KLE_EVERGREEN_PERCENT               NUMBER := OKL_API.G_MISS_NUM,
    KLE_AMOUNT_STAKE                    NUMBER := OKL_API.G_MISS_NUM,
    KLE_DATE_SOLD                       OKL_K_LINES.DATE_SOLD%TYPE := OKL_API.G_MISS_DATE,
    KLE_DELIVERED_DATE                  OKL_K_LINES.DELIVERED_DATE%TYPE := OKL_API.G_MISS_DATE,
    KLE_AMOUNT                          NUMBER  := OKL_API.G_MISS_NUM,
    KLE_DATE_FUNDING                    OKL_K_LINES.DATE_FUNDING%TYPE := OKL_API.G_MISS_DATE,
    KLE_DATE_FUNDING_REQUIRED           OKL_K_LINES.DATE_FUNDING_REQUIRED%TYPE := OKL_API.G_MISS_DATE,
    KLE_DATE_ACCEPTED                   OKL_K_LINES.DATE_ACCEPTED%TYPE := OKL_API.G_MISS_DATE,
    KLE_DATE_DELIVERY_EXPECTED          OKL_K_LINES.DATE_DELIVERY_EXPECTED%TYPE := OKL_API.G_MISS_DATE,
    KLE_CAPITAL_AMOUNT                  NUMBER := OKL_API.G_MISS_NUM,
    NAME                                OKX_PARTIES_V.NAME%TYPE  := OKL_API.G_MISS_CHAR,
    DESCRIPTION                         OKX_PARTIES_V.DESCRIPTION%TYPE  := OKL_API.G_MISS_CHAR,
    DATE_PAY_INVESTOR_START             OKL_K_LINES_V.DATE_PAY_INVESTOR_START%TYPE := OKL_API.G_MISS_DATE,
    PAY_INVESTOR_FREQUENCY              OKL_K_LINES_V.PAY_INVESTOR_FREQUENCY%TYPE := OKL_API.G_MISS_CHAR,
    PAY_INVESTOR_EVENT                  OKL_K_LINES_V.PAY_INVESTOR_EVENT%TYPE := OKL_API.G_MISS_CHAR,
    PAY_INVESTOR_REMITTANCE_DAYS        NUMBER := OKL_API.G_MISS_NUM,
    START_DATE                          OKC_K_LINES_V.START_DATE%TYPE := OKC_API.G_MISS_DATE,
    BILL_TO_SITE_USE_ID                 NUMBER := OKL_API.G_MISS_NUM,
    CUST_ACCT_ID                        NUMBER := OKL_API.G_MISS_NUM);


    TYPE inv_tbl_type IS TABLE OF inv_rec_type INDEX BY BINARY_INTEGER;


  subtype clev_rec_type is OKL_OKC_MIGRATION_PVT.clev_rec_type;
  subtype clev_tbl_type is OKL_OKC_MIGRATION_PVT.clev_tbl_type;

  subtype klev_rec_type is OKL_CONTRACT_PUB.klev_rec_type;
  subtype cplv_rec_type is OKL_OKC_MIGRATION_PVT.cplv_rec_type;

  TYPE hdr_tbl_type IS TABLE OF VARCHAR2(256) INDEX BY BINARY_INTEGER;

  G_TOPLINE_LTY_CODE varchar2(10) := 'INVESTMENT';
  G_INVESTOR_RLE_CODE varchar2(8) := 'INVESTOR';
  G_INVESTOR_OBJECT_CODE varchar2(9) := 'OKX_PARTY';
  G_AK_REGION_NAME varchar2(19) := 'OKL_LA_SEC_INVESTOR';



PROCEDURE create_investor(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inv_tbl                      IN  inv_tbl_type,
    x_inv_tbl                      OUT NOCOPY inv_tbl_type);


PROCEDURE update_investor(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inv_tbl                      IN  inv_tbl_type,
    x_inv_tbl                      OUT NOCOPY inv_tbl_type);

PROCEDURE delete_investor(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inv_tbl                      IN  inv_tbl_type);

END OKL_SEC_INVESTOR_PVT;

 

/
