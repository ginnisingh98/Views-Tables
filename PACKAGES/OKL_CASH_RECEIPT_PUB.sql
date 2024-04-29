--------------------------------------------------------
--  DDL for Package OKL_CASH_RECEIPT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CASH_RECEIPT_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPRTCS.pls 115.4 2003/03/17 23:24:27 bvaghela noship $ */

 ------------------------------------------------------------------------------
 -- Global Variables

G_PKG_NAME              CONSTANT    VARCHAR2(200)   := 'OKL_CASH_RECEIPT_PUB';
G_APP_NAME              CONSTANT    VARCHAR2(3)     :=  OKC_API.G_APP_NAME;
G_UNEXPECTED_ERROR      CONSTANT    VARCHAR2(200)   := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
G_SQLERRM_TOKEN         CONSTANT    VARCHAR2(200)   := 'SQLERRM';
G_SQLCODE_TOKEN         CONSTANT    VARCHAR2(200)   := 'SQLCODE';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
G_EXCEPTION_HALT_VALIDATION	    EXCEPTION;
 ------------------------------------------------------------------------------

SUBTYPE xcrv_rec_type IS Okl_Extrn_Pvt.xcrv_rec_type;
SUBTYPE xcav_tbl_type IS Okl_Extrn_Pvt.xcav_tbl_type;

   PROCEDURE CASH_RECEIPT_PUB( p_api_version      IN  NUMBER   := 1.0
                              ,p_init_msg_list    IN  VARCHAR2 := OKC_API.G_FALSE
                              ,x_return_status    OUT NOCOPY  VARCHAR2
                              ,x_msg_count        OUT NOCOPY  NUMBER
                              ,x_msg_data         OUT NOCOPY  VARCHAR2
                              ,p_over_pay         IN  VARCHAR2
                              ,p_conc_proc        IN  VARCHAR2
                              ,p_xcrv_rec         IN  xcrv_rec_type
                              ,p_xcav_tbl         IN  xcav_tbl_type
                              ,x_cash_receipt_id  OUT NOCOPY NUMBER
                             );

END okl_cash_receipt_pub;

 

/
