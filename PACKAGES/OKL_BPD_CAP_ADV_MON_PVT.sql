--------------------------------------------------------
--  DDL for Package OKL_BPD_CAP_ADV_MON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_BPD_CAP_ADV_MON_PVT" AUTHID CURRENT_USER AS
 /* $Header: OKLRAMSS.pls 120.2 2007/08/02 07:09:14 dcshanmu ship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_APP_NAME             CONSTANT   VARCHAR2(3)   :=  Okl_api.G_APP_NAME;
  G_UNEXPECTED_ERROR     CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN        CONSTANT   VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN        CONSTANT   VARCHAR2(200) := 'SQLCODE';
  G_PKG_NAME             CONSTANT   VARCHAR2(200) := 'OKL_CASH_APPL_RULES';
  G_EXCEPTION_HALT_VALIDATION EXCEPTION;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- Record Type
  ---------------------------------------------------------------------------
   TYPE adv_rcpt_rec IS RECORD
   (currency_code         OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT NULL
   ,currency_conv_type    OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_TYPE%TYPE DEFAULT NULL
   ,currency_conv_date    OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_DATE%TYPE DEFAULT NULL
   ,currency_conv_rate    OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE%TYPE DEFAULT NULL
   ,irm_id	               OKL_TRX_CSH_RECEIPT_V.IRM_ID%TYPE DEFAULT NULL
   ,check_number          OKL_TRX_CSH_RECEIPT_V.CHECK_NUMBER%TYPE DEFAULT NULL
   ,rcpt_amount	          OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE DEFAULT NULL
   ,contract_id           OKC_K_HEADERS_V.ID%TYPE DEFAULT NULL
   ,contract_num          OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT NULL
   ,customer_id           OKL_TRX_CSH_RECEIPT_V.ILE_id%TYPE DEFAULT NULL
   ,customer_num          AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%TYPE DEFAULT NULL
   ,gl_date               OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE DEFAULT NULL
   ,receipt_date          OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE DEFAULT NULL
   ,comments              AR_CASH_RECEIPTS_ALL.COMMENTS%TYPE DEFAULT NULL
   ,rct_id                OKL_TRX_CSH_RECEIPT_V.ID%TYPE DEFAULT NULL
   ,xcr_id		              NUMBER DEFAULT NULL
   ,icr_id		              AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT NULL
   ,receipt_type          OKL_TRX_CSH_RECEIPT_V.RECEIPT_TYPE%TYPE DEFAULT NULL
   ,fully_applied_flag    OKL_TRX_CSH_RECEIPT_V.FULLY_APPLIED_FLAG%TYPE DEFAULT NULL
   ,expired_flag          OKL_TRX_CSH_RECEIPT_V.EXPIRED_FLAG%TYPE DEFAULT NULL
   );

    x_adv_rcpt_rec        adv_rcpt_rec;
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  l_xcav_tbl        Okl_Xca_Pvt.xcav_tbl_type;

---------------------------------------------------------------------------
-- PROCEDURE handle_advanced_manual_pay
---------------------------------------------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : handle_advanced_manual_pay
  -- Description     : procedure for inserting the records in
  --                   table OKL_TRX_CSH_RECEIPT_B and OKL_EXT_CSH_RCPTS_B
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status,
  --                   x_msg_count, x_msg_data, p_adv_rcpt_rec, x_adv_rcpt_rec.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE handle_advanced_manual_pay ( p_api_version         IN  NUMBER
                                        ,p_init_msg_list       IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                                        ,x_return_status       OUT NOCOPY VARCHAR2
                                        ,x_msg_count           OUT NOCOPY NUMBER
                                        ,x_msg_data            OUT NOCOPY VARCHAR2
                                        ,p_adv_rcpt_rec        IN  adv_rcpt_rec
                                        ,x_adv_rcpt_rec        OUT NOCOPY adv_rcpt_rec );
 END okl_bpd_cap_adv_mon_pvt;

/
