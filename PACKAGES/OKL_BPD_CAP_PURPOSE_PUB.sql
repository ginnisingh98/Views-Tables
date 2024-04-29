--------------------------------------------------------
--  DDL for Package OKL_BPD_CAP_PURPOSE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_BPD_CAP_PURPOSE_PUB" AUTHID CURRENT_USER AS
 /* $Header: OKLPCPUS.pls 120.2 2005/10/30 04:01:32 appldev noship $ */
 SUBTYPE okl_cash_dtls_rec_type IS okl_bpd_cap_purpose_pvt.okl_cash_dtls_rec_type;
 SUBTYPE okl_cash_dtls_tbl_type IS okl_bpd_cap_purpose_pvt.okl_cash_dtls_tbl_type;

 -----------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION EXCEPTION;
 ------------------------------------------------------------------------------

 --Object type procedure for update
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

END Okl_Bpd_Cap_Purpose_Pub;

 

/
