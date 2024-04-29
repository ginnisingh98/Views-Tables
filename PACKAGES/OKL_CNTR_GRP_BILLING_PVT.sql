--------------------------------------------------------
--  DDL for Package OKL_CNTR_GRP_BILLING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CNTR_GRP_BILLING_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRCLBS.pls 120.2 2006/11/23 16:27:13 dpsingh noship $ */
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below

  ------------------------------------------------------------------------------
 SUBTYPE tilv_rec_type is okl_til_pvt.tilv_rec_type;
 SUBTYPE tilv_tbl_type is okl_til_pvt.tilv_tbl_type;

 SUBTYPE tryv_rec_type IS okl_try_pvt.tryv_rec_type;
 SUBTYPE tryv_tbl_type IS okl_try_pvt.tryv_tbl_type;

 SUBTYPE taiv_rec_type IS okl_tai_pvt.taiv_rec_type;
 SUBTYPE taiv_tbl_type IS okl_tai_pvt.taiv_tbl_type;

 SUBTYPE tldv_rec_type IS Okl_Tld_Pvt.tldv_rec_type;
 SUBTYPE tldv_tbl_type IS Okl_Tld_Pvt.tldv_tbl_type;

 SUBTYPE Bill_Rec_Type IS oks_bill_util_pub.Bill_Rec_Type;
 SUBTYPE Bill_Tbl_Type IS oks_bill_util_pub.Bill_Tbl_Type;

 SUBTYPE crdg_rec_type IS CS_CTR_CAPTURE_READING_PUB.CTR_GRP_LOG_REC_TYPE;
 SUBTYPe crdg_tbl_type IS CS_CTR_CAPTURE_READING_PUB.CTR_RDG_TBL_TYPE;
 SUBTYPE prdg_tbl_type IS CS_CTR_CAPTURE_READING_PUB.PROP_RDG_TBL_TYPE;

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE cntr_bill_rec_type IS RECORD (
    clg_id                         NUMBER := Okl_Api.G_MISS_NUM,
    counter_group                  OKL_CNTR_LVLNG_GRPS_TL.NAME%TYPE := Okl_Api.G_MISS_CHAR,
    counter_number                 NUMBER := Okl_Api.G_MISS_NUM,
    counter_name                   CS_COUNTERS.NAME%TYPE := Okl_Api.G_MISS_CHAR,
    contract_number                OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE := Okl_Api.G_MISS_CHAR,
    asset_number                   OKC_K_LINES_TL.NAME%TYPE := Okl_Api.G_MISS_CHAR,
    asset_serial_number            OKX_ASSETS_V.SERIAL_NUMBER%TYPE := Okl_Api.G_MISS_CHAR,
    asset_description              OKX_ASSETS_V.DESCRIPTION%TYPE := Okl_Api.G_MISS_CHAR,
    effective_date_from            OKL_CNTR_LVLNG_GRPS_B.EFFECTIVE_DATE_FROM%TYPE := Okl_Api.G_MISS_DATE,
    effective_date_to              OKL_CNTR_LVLNG_GRPS_B.EFFECTIVE_DATE_TO%TYPE := Okl_Api.G_MISS_DATE,
    counter_reading                NUMBER := Okl_Api.G_MISS_NUM,
    counter_reading_date           DATE := Okl_Api.G_MISS_DATE,
    counter_bill_amount            NUMBER := Okl_Api.G_MISS_NUM,
    legal_entity_id                NUMBER := Okl_Api.G_MISS_NUM
	);
  TYPE cntr_bill_tbl_type IS TABLE OF cntr_bill_rec_type
        INDEX BY BINARY_INTEGER;


  -- Global Variables
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_CNTR_GRP_BILLING_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(3)   :=  Okc_Api.G_APP_NAME;
  G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
  ------------------------------------------------------------------------------
   --Global Exception
  ------------------------------------------------------------------------------
   G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
  ------------------------------------------------------------------------------

  l_msg_data VARCHAR2(4000);

  --PROCEDURE ADD_LANGUAGE;


  PROCEDURE counter_grp_billing_calc(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
	,p_cntr_bill_rec                IN cntr_bill_rec_type
    ,x_cntr_bill_rec                OUT NOCOPY cntr_bill_rec_type
	);

  PROCEDURE counter_grp_billing_calc(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
	,p_cntr_bill_tbl                IN cntr_bill_tbl_type
    ,x_cntr_bill_tbl                OUT NOCOPY cntr_bill_tbl_type
	);

  PROCEDURE counter_grp_billing_insert(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
	,p_cntr_bill_rec                IN cntr_bill_rec_type
    ,x_cntr_bill_rec                OUT NOCOPY cntr_bill_rec_type
	);

  PROCEDURE counter_grp_billing_insert(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
	,p_cntr_bill_tbl                IN cntr_bill_tbl_type
    ,x_cntr_bill_tbl                OUT NOCOPY cntr_bill_tbl_type
	);

END OKL_CNTR_GRP_BILLING_PVT; -- Package spec

/
