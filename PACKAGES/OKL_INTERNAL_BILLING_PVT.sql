--------------------------------------------------------
--  DDL for Package OKL_INTERNAL_BILLING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INTERNAL_BILLING_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRIARS.pls 120.1.12010000.4 2010/04/07 17:07:09 sachandr ship $ */
 ----------------------------------------------------------------------------
 -- GLOBAL VARIABLES
 ----------------------------------------------------------------------------
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_INTERNAL_BILLING_PVT';
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
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : CREATE_BILLING_TRX
-- Description     : wrapper api to create internal billing transactions
-- Business Rules  :
--                 Usage:
--                 (1) Caller pass 3 layers of billing data:
--                 -----------------------------------------
--
--                       If caller pass the following parameters with data,
--                       ,p_taiv_rec                     IN  okl_tai_pvt.taiv_rec_type
--                       ,p_tilv_tbl                     IN  okl_til_pvt.tilv_tbl_type
--                       ,p_tldv_tbl                     IN  okl_tld_pvt.tldv_tbl_type
--                       then system assume caller is intend to create stream based (with stream element)
--                       internal billing transactions.
--
--                       In this scenario, the following rules applied:
--                 R1): If p_tilv_tbl(n).TXL_AR_LINE_NUMBER exists, but p_tldv_tbl(n).TXL_AR_LINE_NUMBER
--                      doesn't exists, throw error.
--                 R2): If p_tldv_tbl(n).TXL_AR_LINE_NUMBER exists, but p_tilv_tbl(n).TXL_AR_LINE_NUMBER
--                      doesn't exists, throw error.
--
--                 Note:
--                 p_tilv_tbl(n).TXL_AR_LINE_NUMBER :
--                 User key to link between p_tilv_rec and p_tldv_tbl
--
--                 p_tldv_tbl(n).TXL_AR_LINE_NUMBER :
--                 User key to link between p_tldv_rec and p_tilv_rec
--
--                 Note: In order to process this API properly, you need to pass user enter TXL_AR_LINE_NUMBER
--                 to link between p_tilv_rec and p_tldv_tbl.
--
--                 (2) Caller pass 2 layers of billing data:
--                 -----------------------------------------
--
--                       If caller pass the following parameters with data,
--                       ,p_taiv_rec                     IN  okl_tai_pvt.taiv_rec_type
--                       ,p_tilv_tbl                     IN  okl_til_pvt.tilv_tbl_type
--                       then system assume caller is intend to create non-stream based (without stream element)
--                       internal billing transactions.
--
--                       In this scenario, p_tilv_tbl(n).TXL_AR_LINE_NUMBER is not a required attribute.
--                       If user does pass p_tilv_tbl(n).TXL_AR_LINE_NUMBER, system will assume this is a
--                       redundant data.
--                       System will copy the major attributes (STY_ID, AMOUNT, etc) from p_tilv_rec to
--                       create record in OKL_TXD_AR_LN_DTLS_b/tl table (Internal billing invoice/invoce line)
--
--                 (3) Caller pass 1 layer of billing data:
--                 -----------------------------------------
--                       If p_tilv_tbl.count = 0, throw error.
--
--                 Note: 1. Assume all calling API will validate attributes before make the call. This is
--                       the current architecture and we will adopt all validation logic from calling API
--                       to this central API in the future.
-- Parameters      :
--
--                 p_taiv_rec: Internal billing contract transaction header (okl_trx_ar_invoices_v)
--                 p_tilv_tbl: Internal billing contract transaction line (OKL_TXL_AR_INV_LNS_V)
--                 p_tldv_tbl: Internal billing invoice/invoce line (OKL_TXD_AR_LN_DTLS_V)
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE CREATE_BILLING_TRX(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_taiv_rec                     IN  okl_tai_pvt.taiv_rec_type
   ,p_tilv_tbl                     IN  okl_til_pvt.tilv_tbl_type
   ,p_tldv_tbl                     IN  okl_tld_pvt.tldv_tbl_type
   ,x_taiv_rec                     OUT NOCOPY okl_tai_pvt.taiv_rec_type
   ,x_tilv_tbl                     OUT NOCOPY okl_til_pvt.tilv_tbl_type
   ,x_tldv_tbl                     OUT NOCOPY okl_tld_pvt.tldv_tbl_type
   ,p_cpl_id                       IN  NUMBER DEFAULT NULL
 );

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : Get_Invoice_format
-- Description     : wrapper api to retrieve OKL invoice format type and
--                   invoice format line type
-- Business Rules  :
--  1. If passed in inf_id and sty_id matches, get the invoice_format_type and
--     invoice format line type
--  2. If passed in inf_id matches, but stream is missing, get the defaulted
--     invoice_format_type and invoice format line type
--  3 If passed in inf_id and sty_id are null, assign null to the
--    invoice_format_type and invoice format line type
-- Parameters      :
--
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE Get_Invoice_format(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_inf_id                       IN NUMBER DEFAULT NULL
   ,p_sty_id                       IN NUMBER DEFAULT NULL
   ,x_invoice_format_type          OUT NOCOPY VARCHAR2
   ,x_invoice_format_line_type     OUT NOCOPY VARCHAR2
 );

-- Start of comments

  -- API name       : update_manual_invoice
  -- Pre-reqs       : None
  -- Function       :  It is Used to Update header in TAI and Insert/Update line
  --                    in TIL/TLD. And if the trx_status_code is submitted then
  --                    make a accounting call for all TLD records.
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --                  p_taiv_rec - Record type for OKL_TRX_AR_INVOICES_B.
  --                  p_tilv_tbl -- Table type for OKL_TXL_AR_INV_LNS_B.
  -- Version        : 1.0
  -- History        : gkhuntet created.
  -- End of comments

PROCEDURE  update_manual_invoice(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_taiv_rec                     IN  okl_tai_pvt.taiv_rec_type
   ,p_tilv_tbl                     IN  okl_til_pvt.tilv_tbl_type
   ,x_taiv_rec                     OUT NOCOPY okl_tai_pvt.taiv_rec_type
   ,x_tilv_tbl                     OUT NOCOPY okl_til_pvt.tilv_tbl_type
   ,x_tldv_tbl                     OUT NOCOPY okl_tld_pvt.tldv_tbl_type
);



PROCEDURE  delete_manual_invoice(
                                 p_api_version                  IN NUMBER
                                 ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
                                 ,x_return_status                OUT NOCOPY VARCHAR2
                                 ,x_msg_count                    OUT NOCOPY NUMBER
                                 ,x_msg_data                     OUT NOCOPY VARCHAR2
                                 ,p_taiv_id                      NUMBER
                                 ,p_tilv_id                      NUMBER
                                 );

PROCEDURE create_accounting_dist(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_tldv_tbl                     IN  okl_tld_pvt.tldv_tbl_type
   ,p_tai_id                       IN  OKL_TRX_AR_INVOICES_B.ID%TYPE
);






END OKL_INTERNAL_BILLING_PVT;

/
