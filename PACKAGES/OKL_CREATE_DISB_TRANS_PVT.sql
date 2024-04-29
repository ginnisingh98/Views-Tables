--------------------------------------------------------
--  DDL for Package OKL_CREATE_DISB_TRANS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CREATE_DISB_TRANS_PVT" AUTHID CURRENT_USER AS
 /* $Header: OKLRCDTS.pls 120.1 2007/02/16 19:53:14 pjgomes noship $ */
 ---------------------------------------------------------------------------------------------------
 -- Global Variables
 ---------------------------------------------------------------------------------------------------
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_CREATE_DISB_TRANS_PVT';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
 G_COL_NAME_TOKEN	CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
 G_REQUIRED_VALUE	CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';

 ----------------------------------------------------------------------------------------------------
 --Record, Table Type
 ----------------------------------------------------------------------------------------------------
   SUBTYPE tapv_rec_type IS okl_tap_pvt.tapv_rec_type;
   SUBTYPE tplv_tbl_type IS okl_tpl_pvt.tplv_tbl_type;

 ----------------------------------------------------------------------------------------------------
 --Procedures and Functions
 ----------------------------------------------------------------------------------------------------

 --Procedure for creating disbursement transactions
 --This procedure will create a header, lines and distributions
 --and it will return a status about the creation process.

   PROCEDURE create_disb_trx(p_api_version		IN  NUMBER
                            ,p_init_msg_list            IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
                            ,x_return_status    	OUT NOCOPY VARCHAR2
                            ,x_msg_count	        OUT NOCOPY NUMBER
                            ,x_msg_data		        OUT NOCOPY VARCHAR2
                            ,p_tapv_rec                 IN tapv_rec_type
                            ,p_tplv_tbl                 IN tplv_tbl_type
                            ,x_tapv_rec                 OUT NOCOPY tapv_rec_type
                            ,x_tplv_tbl                 OUT NOCOPY tplv_tbl_type
                            );

 --Procedure for updating transaction status

   PROCEDURE update_disb_trx(p_api_version		IN  NUMBER
                            ,p_init_msg_list	        IN  VARCHAR2	DEFAULT OKL_API.G_FALSE
                            ,x_return_status	        OUT NOCOPY VARCHAR2
                            ,x_msg_count		OUT NOCOPY NUMBER
                            ,x_msg_data		        OUT NOCOPY VARCHAR2
                            ,p_tapv_rec                  IN tapv_rec_type
                            ,x_tapv_rec                  OUT NOCOPY tapv_rec_type
                            );

  FUNCTION get_khr_line_amount(p_invoice_id IN NUMBER
                              ,p_khr_id IN NUMBER) RETURN NUMBER;

	PRAGMA RESTRICT_REFERENCES(get_khr_line_amount, WNDS, WNPS);

END OKL_CREATE_DISB_TRANS_PVT;

/
