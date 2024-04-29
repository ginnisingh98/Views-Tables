--------------------------------------------------------
--  DDL for Package OKL_BILLING_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_BILLING_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRBULS.pls 120.5.12010000.2 2009/01/30 05:53:15 rpillay ship $ */
 ----------------------------------------------------------------------------
 -- GLOBAL VARIABLES
 ----------------------------------------------------------------------------
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_BILLING_UTIL_PVT';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

 G_RET_STS_SUCCESS		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_SUCCESS;
 G_RET_STS_UNEXP_ERROR		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_UNEXP_ERROR;
 G_RET_STS_ERROR		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_ERROR;
 G_EXCEPTION_ERROR		 EXCEPTION;
 G_EXCEPTION_UNEXPECTED_ERROR	 EXCEPTION;

 G_UNEXPECTED_ERROR           CONSTANT VARCHAR2(30) := 'OKL_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN              CONSTANT VARCHAR2(30) := 'OKL_SQLERRM';
 G_SQLCODE_TOKEN              CONSTANT VARCHAR2(30) := 'OKL_SQLCODE';

 G_EXC_NAME_OTHERS	        CONSTANT VARCHAR2(6) := 'OTHERS';
 G_API_TYPE	CONSTANT VARCHAR(4) := '_PVT';
 G_UI_DATE_MASK      VARCHAR2(15) := fnd_profile.value('ICX_DATE_FORMAT_MASK');
 G_OKL_LLA_INVALID_DATE_FORMAT CONSTANT VARCHAR2(30) := 'OKL_LLA_INVALID_DATE_FORMAT';
 G_NOT_UNIQUE                 CONSTANT VARCHAR2(30) := 'OKL_LLA_NOT_UNIQUE';
 G_REQUIRED_VALUE             CONSTANT VARCHAR2(30) := 'OKL_REQUIRED_VALUE';
 G_LLA_RANGE_CHECK            CONSTANT VARCHAR2(30) := 'OKL_LLA_RANGE_CHECK';
 G_INVALID_VALUE              CONSTANT VARCHAR2(30) := OKL_API.G_INVALID_VALUE;
 G_COL_NAME_TOKEN             CONSTANT VARCHAR2(30) := OKL_API.G_COL_NAME_TOKEN;

TYPE contract_invoice_rec IS RECORD (
  khr_id NUMBER := Okl_Api.G_MISS_NUM,
  AMOUNT NUMBER := Okl_Api.G_MISS_NUM
);

TYPE contract_invoice_tbl IS TABLE OF contract_invoice_rec INDEX BY BINARY_INTEGER;
 ----------------------------------------------------------------------------
 -- Data Structures
 ----------------------------------------------------------------------------
 ----------------------------------------------------------------------------
 -- Global Exception
 ----------------------------------------------------------------------------
 G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

 ----------------------------------------------------------------------------
 -- Procedures and Functions
 ------------------------------------------------------------------------------

-- **** Authoring requirement APIs ****
-------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : LAST_INVOICE_DATE
-- Description     : api to return last(max) invoice date for a contract
-- Business Rules  :
-- Parameters      :
--                 p_contract_id - Contract ID
--
--                 x_invoice_date - Last invoice date
--
-- Version         : 1.0
-- End of comments
--select max(ractrx.trx_date) from RA_CUSTOMER_TRX_LINES ractrx
--where exists (
--select 'x' from RA_CUSTOMER_TRX_LINES_ALL ractrl
--where ractrx.customer_trx_id = ractrl.customer_trx_id
--and   ractrl.interface_line_attribute6 = (select contract_number from
--                     okc_k_headers_b where id = p_contract_id)
--)
-------------------------------------------------------------------------------
 PROCEDURE LAST_INVOICE_DATE(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_contract_id                  IN  NUMBER
   ,x_invoice_date                 OUT NOCOPY DATE
 );

-------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : INVOICE_AMOUNT_FOR_STREAM
-- Description     : api to return all the the total invoice line amount for
-- stream type purpose = p_stream_purpose ('UNSCHEDULED_PRINCIPAL_PAYMENT') for
-- each contract.
-- Select khr_id, sum(line_amount) group by khr_id where OKL invoice
-- and stream type purpose matches with invice line context field.
-- Business Rules  :
-- Parameters      :
--                 p_stream_purpose - Stream type purpose
--
--                 x_contract_invoice_tbl         - table containing contract_id
--                 and invoice amount
--
-- Version         : 1.0
-- End of comments
--select a.id, sum(amount_due_original) from okl_bpd_ar_inv_lines_v ractrl,
--okc_k_headers_b a
--where  a.contract_number = ractrl.interface_line_attribute6
--and    ractrl.interface_line_attribute13(this is stream_type_purpose) =  ( -- Join with okl_strm_type_b to match with stream type purpose)
--group by id;
-------------------------------------------------------------------------------
 PROCEDURE INVOICE_AMOUNT_FOR_STREAM(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_stream_purpose               IN  VARCHAR2
   ,x_contract_invoice_tbl         OUT NOCOPY contract_invoice_tbl
 );


FUNCTION INVOICE_LINE_AMOUNT_ORIG(
          p_customer_trx_id IN NUMBER,
          p_customer_trx_line_id NUMBER) RETURN NUMBER;

FUNCTION INVOICE_LINE_AMOUNT_APPLIED(
          p_customer_trx_id IN NUMBER,
          p_customer_trx_line_id NUMBER) RETURN NUMBER;

FUNCTION INVOICE_LINE_AMOUNT_CREDITED(
          p_customer_trx_id IN NUMBER,
          p_customer_trx_line_id NUMBER) RETURN NUMBER;

FUNCTION INVOICE_LINE_AMOUNT_REMAINING(
          p_customer_trx_id IN NUMBER,
          p_customer_trx_line_id NUMBER) RETURN NUMBER;

FUNCTION INVOICE_AMOUNT_ORIG(
          p_customer_trx_id IN NUMBER) RETURN NUMBER;

FUNCTION INVOICE_AMOUNT_APPLIED(
          p_customer_trx_id IN NUMBER) RETURN NUMBER;

FUNCTION INVOICE_AMOUNT_CREDITED(
          p_customer_trx_id IN NUMBER) RETURN NUMBER;

FUNCTION INVOICE_AMOUNT_REMAINING(
          p_customer_trx_id IN NUMBER) RETURN NUMBER;

FUNCTION LINE_ID_APPLIED(p_cash_receipt_id IN NUMBER,
                         p_customer_trx_id IN NUMBER) RETURN NUMBER;

FUNCTION LINE_NUMBER_APPLIED(p_cash_receipt_id IN NUMBER,
                             p_customer_trx_id IN NUMBER) RETURN NUMBER;

--FUNCTION DEBUG_PROC(msg varchar2) RETURN VARCHAR2;

 FUNCTION get_tld_amount_orig( p_tld_id IN  NUMBER ) RETURN NUMBER;
 FUNCTION get_tld_amount_applied( p_tld_id IN  NUMBER ) RETURN NUMBER;
 FUNCTION get_tld_amount_credited( p_tld_id IN  NUMBER ) RETURN NUMBER;
 FUNCTION get_tld_amount_remaining( p_tld_id IN  NUMBER ) RETURN NUMBER;

 PROCEDURE get_tld_balance(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,p_tld_id                       IN  NUMBER
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,x_orig_amount                  OUT NOCOPY NUMBER
   ,x_applied_amount               OUT NOCOPY NUMBER
   ,x_credited_amount              OUT NOCOPY NUMBER
   ,x_remaining_amount             OUT NOCOPY NUMBER
   ,x_tax_amount                   OUT NOCOPY NUMBER
 );

PROCEDURE get_contract_invoice_balance(
   p_api_version                  IN NUMBER
  ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
  ,p_contract_number              IN  VARCHAR2
  ,p_trx_number                   IN  VARCHAR2
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,x_remaining_amount             OUT NOCOPY NUMBER
);


FUNCTION INVOICE_LINE_TAX_AMOUNT(p_customer_trx_line_id NUMBER) RETURN NUMBER;


 -------------------------------------------------------------------------------
  -- PROCEDURE CHECK_PREUPGRADE_DATA
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : CHECK_PREUPGRADE_DATA
  -- Description     : Procedure to list In Process Billing Transactions
  --  					pre-upgrade script
  -- Business Rules  :
  -- Parameters      :x_errbuf,x_retcode,x_any_data_exists:Standard out parameters
  -- Version         : 1.0
  -- History         : 05-Sep-2007 VPANWAR created
  -- End of comments
  -------------------------------------------------------------------------------
PROCEDURE  CHECK_PREUPGRADE_DATA(x_errbuf    OUT NOCOPY VARCHAR2,
                                    x_retcode   OUT NOCOPY NUMBER,
									x_any_data_exists OUT NOCOPY BOOLEAN );

FUNCTION get_tld_amt_remaining_WOTAX( p_tld_id IN  NUMBER ) RETURN NUMBER;

FUNCTION INV_LN_AMT_APPLIED_WOTAX(
          p_customer_trx_id IN NUMBER,
          p_customer_trx_line_id NUMBER) RETURN NUMBER ;

FUNCTION INV_LN_AMT_CREDITED_WOTAX(
          p_customer_trx_id IN NUMBER,
          p_customer_trx_line_id NUMBER) RETURN NUMBER;

FUNCTION INV_LN_AMT_ORIG_WOTAX(
          p_customer_trx_id IN NUMBER,
          p_customer_trx_line_id NUMBER) RETURN NUMBER;

FUNCTION INV_AMT_REMAINING_WOTAX(
          p_customer_trx_id IN NUMBER) RETURN NUMBER;


FUNCTION INV_LN_AMT_REMAINING_WOTAX(
          p_customer_trx_id IN NUMBER,
          p_customer_trx_line_id NUMBER) RETURN NUMBER;

--dkagrawa added function to get adjusted amount at header level
FUNCTION INVOICE_AMOUNT_ADJUSTED(
          p_customer_trx_id IN NUMBER) RETURN NUMBER;

--dkagrawa added function to get adjusted amount at line level
FUNCTION INVOICE_LINE_AMOUNT_ADJUSTED(
          p_customer_trx_id IN NUMBER,
	  p_customer_trx_line_id IN NUMBER) RETURN NUMBER;

--Bug# 7720775
FUNCTION INV_LN_AMT_ADJUSTED_WOTAX(
          p_customer_trx_id IN NUMBER,
          p_customer_trx_line_id IN NUMBER) RETURN NUMBER;

--Bug# 7720775
-- Functions to return Invoice Line amount with Inclusive Tax Line amount
FUNCTION INV_LN_AMT_APPLIED_W_INCTAX(
          p_customer_trx_id IN NUMBER,
          p_customer_trx_line_id NUMBER) RETURN NUMBER ;

FUNCTION INV_LN_AMT_CREDITED_W_INCTAX(
          p_customer_trx_id IN NUMBER,
          p_customer_trx_line_id NUMBER) RETURN NUMBER;

FUNCTION INV_LN_AMT_ORIG_W_INCTAX(
          p_customer_trx_id IN NUMBER,
          p_customer_trx_line_id NUMBER) RETURN NUMBER;

FUNCTION INV_LN_AMT_REMAINING_W_INCTAX(
          p_customer_trx_id IN NUMBER,
          p_customer_trx_line_id NUMBER) RETURN NUMBER;

FUNCTION INV_LN_AMT_ADJUSTED_W_INCTAX(
          p_customer_trx_id IN NUMBER,
          p_customer_trx_line_id IN NUMBER) RETURN NUMBER;

END OKL_BILLING_UTIL_PVT;

/
