--------------------------------------------------------
--  DDL for Package OKL_BPD_MAN_RCT_HANDLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_BPD_MAN_RCT_HANDLE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRMRHS.pls 120.3 2007/08/02 07:12:43 dcshanmu noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

  SUBTYPE xcav_tbl_type IS OKL_EXTRN_PVT.xcav_tbl_type;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------

  G_APP_NAME             CONSTANT   VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_UNEXPECTED_ERROR     CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN        CONSTANT   VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN        CONSTANT   VARCHAR2(200) := 'SQLCODE';

  G_PKG_NAME       CONSTANT VARCHAR2(200) := 'OKL_BPD_MAN_RCT_HANDLE_PVT';
  G_API_TYPE       CONSTANT VARCHAR2(30)  := '_PVT';
  G_EXCEPTION_HALT_VALIDATION EXCEPTION;

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE man_receipt_apply      ( p_api_version      IN  NUMBER
   	                                ,p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_Api.G_FALSE
   	                                ,x_return_status    OUT NOCOPY VARCHAR2
	                                   ,x_msg_count	       OUT NOCOPY NUMBER
	                                   ,x_msg_data	       OUT NOCOPY VARCHAR2
                                    ,p_xcav_tbl         IN  xcav_tbl_type
                                    ,p_receipt_id       IN  AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT NULL
                                    ,p_receipt_amount   IN  AR_CASH_RECEIPTS_ALL.AMOUNT%TYPE
                                    ,p_receipt_date     IN  AR_CASH_RECEIPTS_ALL.RECEIPT_DATE%TYPE DEFAULT NULL
                                    ,p_receipt_currency IN  AR_CASH_RECEIPTS_ALL.CURRENCY_CODE%TYPE DEFAULT NULL
                                   );


PROCEDURE man_receipt_unapply     (  p_api_version       IN  NUMBER
                                    ,p_init_msg_list     IN  VARCHAR2 DEFAULT OkL_Api.G_FALSE
                                    ,x_return_status     OUT NOCOPY VARCHAR2
                                    ,x_msg_count         OUT NOCOPY NUMBER
                                    ,x_msg_data          OUT NOCOPY VARCHAR2
                                    ,p_xcav_tbl          IN  xcav_tbl_type
                                    ,p_receipt_id        IN  AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT NULL -- cash receipt id
                                    ,p_receipt_date      IN  AR_CASH_RECEIPTS_ALL.RECEIPT_DATE%TYPE DEFAULT NULL
                                  );


  END OKL_BPD_MAN_RCT_HANDLE_PVT;

/
