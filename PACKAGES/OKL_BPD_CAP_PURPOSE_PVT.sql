--------------------------------------------------------
--  DDL for Package OKL_BPD_CAP_PURPOSE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_BPD_CAP_PURPOSE_PVT" AUTHID CURRENT_USER AS
 /* $Header: OKLRCPUS.pls 120.2 2005/10/30 04:02:23 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------

  G_APP_NAME                  CONSTANT   VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT   VARCHAR2(200) := 'OKL_UPDT_CASH_DTLS';
  G_EXCEPTION_HALT_VALIDATION EXCEPTION;


  TYPE okl_cash_dtls_rec_type IS RECORD (
    id                             OKL_TXL_RCPT_APPS_B.ID%TYPE DEFAULT NULL,
    customer_id                    OKL_TXL_RCPT_APPS_B.ILE_ID%TYPE DEFAULT NULL,
    contract_id                    OKL_TXL_RCPT_APPS_B.KHR_ID%TYPE  DEFAULT NULL,
    receipt_id                     OKL_TXL_RCPT_APPS_B.RCT_ID_DETAILS%TYPE  DEFAULT NULL,
    sty_id                         OKL_TXL_RCPT_APPS_B.STY_ID%TYPE  DEFAULT NULL,
    amount                         OKL_TXL_RCPT_APPS_B.AMOUNT%TYPE  DEFAULT NULL
    );



  TYPE okl_cash_dtls_tbl_type IS TABLE OF okl_cash_dtls_rec_type
     INDEX BY BINARY_INTEGER;

---------------------------------------------------------------------------
-- Procedures and Functions
---------------------------------------------------------------------------
 ---------------------------------------------------------------------------
 -- PROCEDURE create_purpose
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_purpose
  -- Description     : procedure for inserting the records in
  --                   table OKL_TXL_RCPT_APPS_B
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_strm_tbl, x_strm_tbl.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE create_purpose      ( p_api_version      IN  NUMBER
                                 ,p_init_msg_list    IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                                 ,x_return_status    OUT NOCOPY VARCHAR2
                                 ,x_msg_count        OUT NOCOPY NUMBER
                                 ,x_msg_data         OUT NOCOPY VARCHAR2
                                 ,p_strm_tbl         IN  okl_cash_dtls_tbl_type
                                 ,x_strm_tbl         OUT NOCOPY okl_cash_dtls_tbl_type
                                );
 ---------------------------------------------------------------------------
 -- PROCEDURE update_purpose
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_purpose
  -- Description     : procedure for updating the records in
  --                   table OKL_TXL_RCPT_APPS_B
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_strm_tbl, x_strm_tbl.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE update_purpose      ( p_api_version      IN  NUMBER
                                 ,p_init_msg_list    IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                                 ,x_return_status    OUT NOCOPY VARCHAR2
                                 ,x_msg_count        OUT NOCOPY NUMBER
                                 ,x_msg_data         OUT NOCOPY VARCHAR2
                                 ,p_strm_tbl         IN  okl_cash_dtls_tbl_type
                                 ,x_strm_tbl         OUT NOCOPY okl_cash_dtls_tbl_type
                                );

 ---------------------------------------------------------------------------
 -- PROCEDURE delete_purpose
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : delete_purpose
  -- Description     : procedure for deleting the records in
  --                   table OKL_TXL_RCPT_APPS_B
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_strm_tbl, x_strm_tbl.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE delete_purpose      ( p_api_version      IN  NUMBER
                                 ,p_init_msg_list    IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                                 ,x_return_status    OUT NOCOPY VARCHAR2
                                 ,x_msg_count        OUT NOCOPY NUMBER
                                 ,x_msg_data         OUT NOCOPY VARCHAR2
                                 ,p_strm_tbl         IN  okl_cash_dtls_tbl_type
                                 ,x_strm_tbl         OUT NOCOPY okl_cash_dtls_tbl_type
                                );

END okl_bpd_cap_purpose_pvt;

 

/
