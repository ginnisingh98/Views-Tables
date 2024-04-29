--------------------------------------------------------
--  DDL for Package OKL_MISC_TRANS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_MISC_TRANS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRMSCS.pls 120.3 2006/07/11 09:51:02 dkagrawa noship $ */

SUBTYPE tclv_rec_type IS OKL_TRX_CONTRACTS_PUB.TCLV_REC_TYPE;
SUBTYPE tabv_tbl_type IS OKL_TRNS_ACC_DSTRS_PUB.tabv_tbl_type;


  -----------------------------------------------------------------------------
  -- APPLICATION GLOBAL CONSTANTS
  -----------------------------------------------------------------------------

  G_API_VERSION          CONSTANT NUMBER        := 1;
  G_FALSE                CONSTANT VARCHAR2(1)   := OKL_API.G_FALSE;
  G_TRUE                 CONSTANT VARCHAR2(1)   := OKL_API.G_TRUE;
  G_DB_ERROR             CONSTANT VARCHAR2(12)  := 'OKL_DB_ERROR';
  G_PROG_NAME_TOKEN      CONSTANT VARCHAR2(9)   := 'PROG_NAME';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(7)   := 'SQLCODE';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(7)   := 'SQLERRM';
  G_RET_STS_SUCCESS      CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_UNEXP_ERROR  CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR        CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_ERROR;

  -----------------------------------------------------------------------------
  -- DATA STRUCTURES
  -----------------------------------------------------------------------------
  TYPE jrnl_hdr_rec_type IS RECORD (ID                          OKL_TRX_CONTRACTS.ID%TYPE,
                                    KHR_ID                      OKL_TRX_CONTRACTS.KHR_ID%TYPE,
                                    PDT_ID                      OKL_TRX_CONTRACTS.PDT_ID%TYPE,
                                    AMOUNT                      OKL_TRX_CONTRACTS.AMOUNT%TYPE,
                                    TSU_CODE                    OKL_TRX_CONTRACTS.TSU_CODE%TYPE,
                                    CURRENCY_CODE               OKL_TRX_CONTRACTS.CURRENCY_CODE%TYPE,
                                    TRX_NUMBER                  OKL_TRX_CONTRACTS.TRX_NUMBER%TYPE,
                                    DESCRIPTION                 OKL_TRX_CONTRACTS.DESCRIPTION%TYPE,
                                    DATE_TRANSACTION_OCCURRED   OKL_TRX_CONTRACTS.DATE_TRANSACTION_OCCURRED%TYPE);

  TYPE jrnl_line_rec_type IS RECORD (ID               OKL_TXL_CNTRCT_LNS.ID%TYPE,
                                     KHR_ID           OKL_TXL_CNTRCT_LNS.KHR_ID%TYPE,
                                     LINE_NUMBER      OKL_TXL_CNTRCT_LNS.LINE_NUMBER%TYPE,
                                     TCN_ID           OKL_TXL_CNTRCT_LNS.TCN_ID%TYPE,
                                     DESCRIPTION      OKL_TXL_CNTRCT_LNS.DESCRIPTION%TYPE,
                                     AVL_ID           OKL_TXL_CNTRCT_LNS.AVL_ID%TYPE,
                                     STY_ID           OKL_TXL_CNTRCT_LNS.STY_ID%TYPE,
                                     CURRENCY_CODE    OKL_TXL_CNTRCT_LNS.CURRENCY_CODE%TYPE,
                                     AMOUNT           OKL_TXL_CNTRCT_LNS.AMOUNT%TYPE);

  TYPE jrnl_line_tbl_type IS TABLE OF jrnl_line_rec_type INDEX BY BINARY_INTEGER;


PROCEDURE CREATE_MISC_DSTR_LINE(p_api_version        IN     NUMBER,
                                p_init_msg_list      IN     VARCHAR2,
                                x_return_status      OUT    NOCOPY VARCHAR2,
                                x_msg_count          OUT    NOCOPY NUMBER,
                                x_msg_data           OUT    NOCOPY VARCHAR2,
                                p_tclv_rec           IN     tclv_rec_type,
                                x_tclv_rec           OUT    NOCOPY tclv_rec_type);


PROCEDURE CREATE_DIST_LINE(p_tclv_rec        IN  tclv_rec_type,
			   x_return_status   OUT NOCOPY VARCHAR2);


  -----------------------------------------------------------------------------
  -- PROGRAM UNITS
  -----------------------------------------------------------------------------
  PROCEDURE create_misc_transaction(p_api_version        IN     NUMBER,
                                    p_init_msg_list      IN     VARCHAR2,
                                    x_return_status      OUT    NOCOPY VARCHAR2,
                                    x_msg_count          OUT    NOCOPY NUMBER,
                                    x_msg_data           OUT    NOCOPY VARCHAR2,
                                    p_jrnl_hdr_rec       IN     jrnl_hdr_rec_type,
                                    p_jrnl_line_tbl      IN     jrnl_line_tbl_type,
                                    x_jrnl_hdr_rec       OUT    NOCOPY jrnl_hdr_rec_type);

  PROCEDURE update_misc_transaction(p_api_version        IN     NUMBER,
                                    p_init_msg_list      IN     VARCHAR2,
                                    x_return_status      OUT    NOCOPY VARCHAR2,
                                    x_msg_count          OUT    NOCOPY NUMBER,
                                    x_msg_data           OUT    NOCOPY VARCHAR2,
                                    p_jrnl_hdr_rec       IN     jrnl_hdr_rec_type,
                                    p_jrnl_line_tbl      IN     jrnl_line_tbl_type);


G_PKG_NAME CONSTANT VARCHAR2(200)       := 'OKL_MISC_TRANS_PVT' ;
G_APP_NAME CONSTANT VARCHAR2(3)         :=  OKL_API.G_APP_NAME;
G_INVALID_VALUE  CONSTANT VARCHAR2(200) := Okc_Api.G_INVALID_VALUE;
G_REQUIRED_VALUE              CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
G_COL_NAME_TOKEN CONSTANT VARCHAR2(200) := Okc_Api.G_COL_NAME_TOKEN;



END OKL_MISC_TRANS_PVT;


/
