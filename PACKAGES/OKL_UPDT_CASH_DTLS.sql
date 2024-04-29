--------------------------------------------------------
--  DDL for Package OKL_UPDT_CASH_DTLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_UPDT_CASH_DTLS" AUTHID CURRENT_USER AS
/* $Header: OKLRCUPS.pls 120.2 2007/08/02 16:01:14 dcshanmu ship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------

  G_APP_NAME             CONSTANT   VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_UNEXPECTED_ERROR     CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN        CONSTANT   VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN        CONSTANT   VARCHAR2(200) := 'SQLCODE';

  G_PKG_NAME             CONSTANT   VARCHAR2(200) := 'OKL_UPDT_CASH_DTLS';
  G_COL_NAME_TOKEN       CONSTANT   VARCHAR2(200) :=  OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN   CONSTANT   VARCHAR2(200) :=  Okl_Api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN    CONSTANT   VARCHAR2(200) :=  Okl_Api.G_CHILD_TABLE_TOKEN;
  G_NO_PARENT_RECORD     CONSTANT   VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
  G_INVALID_VALUE        CONSTANT   VARCHAR2(200) :=  OKC_API.G_INVALID_VALUE;
  G_REQUIRED_VALUE	     CONSTANT   VARCHAR2(200) :=  OKC_API.G_REQUIRED_VALUE;
  G_EXCEPTION_HALT_VALIDATION EXCEPTION;


  TYPE okl_cash_dtls_rec_type IS RECORD (
    customer_id                    Okl_cnsld_ar_hdrs_b.ixx_Id%TYPE := Okl_Api.G_MISS_NUM,
    customer_name                  hz_Parties.Party_Name%TYPE := Okl_Api.G_MISS_CHAR,
    customer_number                hz_cUst_Accounts.Account_Number%TYPE := Okl_Api.G_MISS_CHAR,
    consolidated_invoice_id        Okl_cnsld_ar_hdrs_b.ID%TYPE := Okl_Api.G_MISS_NUM,
    consolidated_invoice_number    Okl_cnsld_ar_hdrs_b.CONSOLIDATED_INVOICE_NUMBER%TYPE := Okl_Api.G_MISS_CHAR,
    contract_id                    Okl_cnsld_ar_strms_b.KHR_ID%TYPE := Okl_Api.G_MISS_NUM,
    contract_number                Okc_k_Headers_All_b.CONTRACT_NUMBER%TYPE := Okl_Api.G_MISS_CHAR,
    contract_line_id               Okl_cnsld_ar_strms_b.KLE_ID%TYPE := Okl_Api.G_MISS_NUM,
    receipt_number                 AR_CASH_RECEIPTS_ALL.RECEIPT_NUMBER%TYPE := Okl_Api.G_MISS_CHAR,
    ext_cash_apps_id               NUMBER,
    xtl_cash_apps_id               NUMBER,
    receivables_invoice_id         Okl_cnsld_ar_strms_b.RECEIVABLES_INVOICE_ID%TYPE := Okl_Api.G_MISS_NUM,
    ar_invoice_number              ar_Payment_Schedules_All.TRX_NUMBER%TYPE := Okl_Api.G_MISS_CHAR,
    asset_id                       fa_Additions_v.ASSET_ID%TYPE, --:= Okl_Api.G_MISS_NUM,  -- causes an error.
    asset_number                   fa_Additions_v.ASSET_NUMBER%TYPE := Okl_Api.G_MISS_CHAR,
    asset_name                     fa_Additions_v.description%TYPE := Okl_Api.G_MISS_CHAR,
    lsm_id                         Okl_cnsld_ar_strms_b.ID%TYPE := Okl_Api.G_MISS_NUM,
    stream_id                      Okl_strm_Type_v.ID%TYPE := Okl_Api.G_MISS_NUM,
    stream_name                    Okl_strm_Type_v.NAME%TYPE := Okl_Api.G_MISS_CHAR,
    outstanding_stream_amount      OKL_RECEIPT_APPLICATIONS_UV.line_applied%TYPE := Okl_Api.G_MISS_NUM,
    applied_stream_amount          OKL_RECEIPT_APPLICATIONS_UV.line_applied%TYPE := Okl_Api.G_MISS_NUM);

  TYPE okl_cash_dtls_tbl_type IS TABLE OF okl_cash_dtls_rec_type
        INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE update_cash_details ( p_api_version	     IN	 NUMBER
				                 ,p_init_msg_list    IN	 VARCHAR2 DEFAULT Okc_Api.G_FALSE
				                 ,x_return_status    OUT NOCOPY VARCHAR2
				                 ,x_msg_count	     OUT NOCOPY NUMBER
				                 ,x_msg_data	     OUT NOCOPY VARCHAR2
                                 ,p_strm_tbl         IN  okl_cash_dtls_tbl_type
                                 ,x_strm_tbl         OUT NOCOPY okl_cash_dtls_tbl_type
							    );

END Okl_Updt_Cash_Dtls;

/
