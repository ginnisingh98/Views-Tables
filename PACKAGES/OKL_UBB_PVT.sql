--------------------------------------------------------
--  DDL for Package OKL_UBB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_UBB_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRUBBS.pls 115.4 2003/10/20 20:49:49 sanahuja noship $ */
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
  TYPE bill_stat_rec_type IS RECORD (
    transaction_type        VARCHAR2(200),
    last_bill_date          DATE,
    last_schedule_bill_date DATE);

  TYPE bill_stat_tbl_type IS TABLE OF bill_stat_rec_type
        INDEX BY BINARY_INTEGER;

 SUBTYPE tilv_rec_type is okl_til_pvt.tilv_rec_type;
 SUBTYPE tilv_tbl_type is okl_til_pvt.tilv_tbl_type;

 SUBTYPE tryv_rec_type IS okl_try_pvt.tryv_rec_type;
 SUBTYPE tryv_tbl_type IS okl_try_pvt.tryv_tbl_type;

 SUBTYPE taiv_rec_type IS okl_tai_pvt.taiv_rec_type;
 SUBTYPE taiv_tbl_type IS okl_tai_pvt.taiv_tbl_type;

 SUBTYPE tldv_rec_type IS Okl_Tld_Pvt.tldv_rec_type;
 SUBTYPE tldv_tbl_type IS Okl_Tld_Pvt.tldv_tbl_type;


  -- Global Variables
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_UBB_PVT';
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


  PROCEDURE calculate_ubb_amount(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
     );

  PROCEDURE bill_service_contract(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_contract_number              IN  VARCHAR2
     );

  PROCEDURE billing_status(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,x_bill_stat_tbl                OUT NOCOPY bill_stat_tbl_type
    ,p_khr_id                       IN  NUMBER
    ,p_transaction_date             IN  DATE
    );

END OKL_UBB_PVT; -- Package spec



 

/
