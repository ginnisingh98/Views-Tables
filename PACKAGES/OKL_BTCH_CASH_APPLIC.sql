--------------------------------------------------------
--  DDL for Package OKL_BTCH_CASH_APPLIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_BTCH_CASH_APPLIC" AUTHID CURRENT_USER AS
/* $Header: OKLRBAPS.pls 120.3 2007/09/19 06:16:09 varangan ship $ */


  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------

  G_APP_NAME             CONSTANT   VARCHAR2(3)   :=  Okl_api.G_APP_NAME;
  G_UNEXPECTED_ERROR     CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN        CONSTANT   VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN        CONSTANT   VARCHAR2(200) := 'SQLCODE';

  G_PKG_NAME             CONSTANT   VARCHAR2(200) := 'OKL_BTCH_CASH_APPLIC';
  G_COL_NAME_TOKEN       CONSTANT   VARCHAR2(200) :=  OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN   CONSTANT   VARCHAR2(200) :=  Okl_Api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN    CONSTANT   VARCHAR2(200) :=  Okl_Api.G_CHILD_TABLE_TOKEN;
  G_NO_PARENT_RECORD     CONSTANT   VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
  G_INVALID_VALUE        CONSTANT   VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_REQUIRED_VALUE	     CONSTANT   VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_EXCEPTION_HALT_VALIDATION EXCEPTION;
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

  TYPE okl_batch_dtls_rec_type IS RECORD (
    id                                   NUMBER,        --DEFAULT Okl_Api.G_MISS_NUM,
    irm_id                               NUMBER,        --DEFAULT Okl_Api.G_MISS_NUM,
    btc_id                               NUMBER,        --DEFAULT Okl_Api.G_MISS_NUM,
    btc_status                           VARCHAR2(30),
    consolidated_invoice_number          VARCHAR2(90),  --DEFAULT Okl_Api.G_MISS_CHAR,
    currency_code                        VARCHAR2(15),  --DEFAULT Okl_Api.G_MISS_CHAR,
    check_number                         VARCHAR2(90),  --DEFAULT Okl_Api.G_MISS_CHAR,
    receipt_date                         DATE,          --DEFAULT Okl_Api.G_MISS_DATE,
    amount                               NUMBER(14,3),  --DEFAULT Okl_Api.G_MISS_NUM,
    ile_id                               NUMBER,        --DEFAULT Okl_Api.G_MISS_NUM,
    consolidated_invoice_id              NUMBER,        --DEFAULT Okl_Api.G_MISS_NUM,
    khr_id                               NUMBER,        --DEFAULT Okl_Api.G_MISS_NUM,
    contract_number                      VARCHAR2(120), --DEFAULT Okl_Api.G_MISS_CHAR,
--Added by nikshah as part of Receipts Project
    ar_invoice_id                      NUMBER, --DEFAULT Okl_Api.G_MISS_NUM,
    customer_number                      VARCHAR2(90),
-- Added by varangan for DFF in Batch Receipts
	dff_attribute_category ar_cash_receipts.attribute_category%TYPE,
	dff_attribute1 ar_cash_receipts.attribute1%TYPE,
	dff_attribute2 ar_cash_receipts.attribute2%TYPE,
	dff_attribute3 ar_cash_receipts.attribute3%TYPE,
	dff_attribute4 ar_cash_receipts.attribute4%TYPE,
	dff_attribute5 ar_cash_receipts.attribute5%TYPE,
	dff_attribute6 ar_cash_receipts.attribute6%TYPE,
	dff_attribute7 ar_cash_receipts.attribute7%TYPE,
	dff_attribute8 ar_cash_receipts.attribute8%TYPE,
	dff_attribute9 ar_cash_receipts.attribute9%TYPE,
	dff_attribute10 ar_cash_receipts.attribute10%TYPE,
	dff_attribute11 ar_cash_receipts.attribute11%TYPE,
	dff_attribute12 ar_cash_receipts.attribute12%TYPE,
	dff_attribute13 ar_cash_receipts.attribute13%TYPE,
	dff_attribute14 ar_cash_receipts.attribute14%TYPE,
	dff_attribute15 ar_cash_receipts.attribute15%TYPE
    );  --DEFAULT Okl_Api.G_MISS_CHAR);

  TYPE okl_btch_dtls_tbl_type IS TABLE OF okl_batch_dtls_rec_type
        INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE handle_batch_pay  ( p_api_version	   IN	NUMBER                  -- TEMPORARY SOLUTION
				               ,p_init_msg_list    IN	VARCHAR2 DEFAULT Okc_Api.G_FALSE
				               ,x_return_status    OUT  NOCOPY VARCHAR2
				               ,x_msg_count	       OUT  NOCOPY NUMBER
				               ,x_msg_data	       OUT  NOCOPY VARCHAR2
                               ,p_btch_tbl         IN   okl_btch_dtls_tbl_type
                               ,x_btch_tbl         OUT  NOCOPY okl_btch_dtls_tbl_type
							  );


END OKL_BTCH_CASH_APPLIC;

/
