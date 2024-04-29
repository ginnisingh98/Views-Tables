--------------------------------------------------------
--  DDL for Package OKL_LTE_INT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LTE_INT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRLINS.pls 115.3 2003/02/11 23:26:41 stmathew noship $ */
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

 subtype lsmv_rec_type is okl_lsm_pvt.lsmv_rec_type;
 subtype lsmv_tbl_type is okl_lsm_pvt.lsmv_tbl_type;


  -- Global Variables
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_LTE_INT_PVT';
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


  PROCEDURE calculate_late_interest(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
     );
END OKL_LTE_INT_PVT; -- Package spec

 

/
