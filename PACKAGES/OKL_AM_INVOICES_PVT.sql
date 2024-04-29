--------------------------------------------------------
--  DDL for Package OKL_AM_INVOICES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_INVOICES_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRAMIS.pls 120.3 2008/05/16 04:58:04 akrangan ship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

  SUBTYPE taiv_rec_type IS okl_trx_ar_invoices_pub.taiv_rec_type;
  SUBTYPE taiv_tbl_type IS okl_trx_ar_invoices_pub.taiv_tbl_type;

  TYPE ariv_rec_type IS RECORD (
	P_ACN_ID		NUMBER		:= OKC_API.G_MISS_NUM,
	P_ACS_CODE		VARCHAR2(200)	:= OKC_API.G_MISS_CHAR,
	P_PART_NAME		VARCHAR2(2000)	:= OKC_API.G_MISS_CHAR,
	P_CONDITION_TYPE	VARCHAR2(2000)	:= OKC_API.G_MISS_CHAR,
	P_DAMAGE_TYPE		VARCHAR2(2000)	:= OKC_API.G_MISS_CHAR,
	P_ACTUAL_REPAIR_COST	NUMBER		:= OKC_API.G_MISS_NUM,
	P_DATE_APPROVED		DATE		:= OKC_API.G_MISS_DATE,
	P_BILL_TO		NUMBER		:= OKC_API.G_MISS_NUM,
	P_DATE_INVOICE		DATE		:= OKC_API.G_MISS_DATE,
	P_APPROVED_YN		VARCHAR2(1)	:= OKC_API.G_MISS_CHAR,
	P_ACD_ID_COST 		NUMBER		:= OKC_API.G_MISS_NUM,
	P_OBJECT_VERSION_NUMBER	NUMBER		:= OKC_API.G_MISS_NUM);

  TYPE tld_rec_type IS RECORD (
	inv_tld_id		NUMBER		:= OKC_API.G_MISS_NUM,
	cm_tld_id		NUMBER		:= OKC_API.G_MISS_NUM);

  TYPE sdd_rec_type IS RECORD (
	lsm_id			NUMBER		:= OKC_API.G_MISS_NUM,
	tld_id			NUMBER		:= OKC_API.G_MISS_NUM,
	amount			NUMBER		:= OKC_API.G_MISS_NUM);

  TYPE ariv_tbl_type IS TABLE OF ariv_rec_type
    INDEX BY BINARY_INTEGER;

  TYPE tld_tbl_type IS TABLE OF tld_rec_type
    INDEX BY BINARY_INTEGER;

  TYPE sdd_tbl_type IS TABLE OF sdd_rec_type
    INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------

  -- Transaction type used for AR Invoices in Accounting Engine
  G_AR_INV_TRX_TYPE	CONSTANT VARCHAR2(30)	:= 'BILLING';
  G_AR_CM_TRX_TYPE	CONSTANT VARCHAR2(30)	:= 'CREDIT MEMO';

  -- Transaction statuses for AR Invoice transactions
  G_SUBMIT_STATUS	CONSTANT VARCHAR2(30)	:= 'SUBMITTED';
  G_ERROR_STATUS	CONSTANT VARCHAR2(30)	:= 'ERROR';

  -- AR Invoice Line Code
  G_AR_INV_LINE_CODE	CONSTANT VARCHAR2(30)	:= 'LINE';

  -- Asset Repair Stream Type
  --G_REPAIR_STREAM	CONSTANT VARCHAR2(30)	:= 'ASSET REPAIR CHARGE'; -- bug 4631541
  G_REPAIR_STREAM	CONSTANT VARCHAR2(30)	:= 'REPAIR_CHARGE';  -- bug 4631541

  -- Remarket Sale Invoice uses Sale Price Quote Line to get Stream Type
  --dkagrawa  Bug 4616460 Use new seeded purpose ASSET_SALE_RECEIVABLE for remarketing
  --G_REMARKET_QUOTE_LINE	CONSTANT VARCHAR2(30)	:= 'AMBSPR';
  G_REMARKET_QUOTE_LINE        CONSTANT VARCHAR2(30)        := 'ASSET_SALE_RECEIVABLE';
  --dkagrawa end

  -- Source table for Accounting Engine calls
  G_AR_LINES_SOURCE	CONSTANT VARCHAR2(30)	:= 'OKL_TXL_AR_INV_LNS_B';

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS FOR ERROR HANDLING
  ---------------------------------------------------------------------------

  G_MISS_NUM		CONSTANT NUMBER		:= OKL_API.G_MISS_NUM;
  G_MISS_CHAR		CONSTANT VARCHAR2(1)	:= OKL_API.G_MISS_CHAR;
  G_MISS_DATE		CONSTANT DATE		:= OKL_API.G_MISS_DATE;

  G_APP_NAME		CONSTANT VARCHAR2(3)	:=  OKL_API.G_APP_NAME;
  G_API_VERSION		CONSTANT NUMBER		:= 1;
  G_PKG_NAME		CONSTANT VARCHAR2(200)	:= 'OKL_AM_INVOICES_PVT';

  G_SQLCODE_TOKEN	CONSTANT VARCHAR2(200)	:= 'SQLCODE';
  G_SQLERRM_TOKEN	CONSTANT VARCHAR2(200)	:= 'SQLERRM';
  G_UNEXPECTED_ERROR	CONSTANT VARCHAR2(200)	:=
					 'OKL_CONTRACTS_UNEXPECTED_ERROR';

  G_OKC_APP_NAME	CONSTANT VARCHAR2(3)	:= OKC_API.G_APP_NAME;
  G_INVALID_VALUE	CONSTANT VARCHAR2(200)	:= OKC_API.G_INVALID_VALUE;
  G_REQUIRED_VALUE	CONSTANT VARCHAR2(200)	:= OKC_API.G_REQUIRED_VALUE;
  G_COL_NAME_TOKEN	CONSTANT VARCHAR2(200)	:= OKC_API.G_COL_NAME_TOKEN;

  G_EXCEPTION_HALT_VALIDATION	 EXCEPTION;

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  -- Extract Vendor Billing Information
  -- If p_cpl_id is given, use vendor attached as a Party Role to Lease
  -- If p_cpl_id is empty, use vendor from Vendor Program linked to Lease
  PROCEDURE Get_Vendor_Billing_Info (
	p_cpl_id		IN NUMBER DEFAULT NULL,
	px_taiv_rec		IN OUT NOCOPY taiv_rec_type,
	x_return_status		OUT NOCOPY VARCHAR2);

  -- Calculate Security Deposit Disposition
  PROCEDURE Contract_Remaining_Sec_Dep (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER,
	x_sdd_tbl		OUT NOCOPY sdd_tbl_type,
	x_tld_tbl		OUT NOCOPY tld_tbl_type,
	x_total_amount		OUT NOCOPY NUMBER);

  -- Create Invoice for Asset Repair
  PROCEDURE Create_Repair_Invoice (
	p_api_version		IN  NUMBER,
	p_init_msg_list		IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	x_return_status		OUT NOCOPY VARCHAR2,
	p_ariv_tbl		IN  ariv_tbl_type,
	x_taiv_tbl		OUT NOCOPY taiv_tbl_type);

  -- Create Invoice for Remarket Sale
  PROCEDURE Create_Remarket_Invoice (
	p_api_version		IN  NUMBER,
	p_init_msg_list		IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	x_return_status		OUT NOCOPY VARCHAR2,
	p_order_line_id		IN  NUMBER,
	x_taiv_tbl		OUT NOCOPY taiv_tbl_type);

  -- Create Invoice from Termination or Repurchase Quote
  PROCEDURE Create_Quote_Invoice (
	p_api_version		IN  NUMBER,
	p_init_msg_list		IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	x_return_status		OUT NOCOPY VARCHAR2,
	p_quote_id		IN  NUMBER,
	x_taiv_tbl		OUT NOCOPY taiv_tbl_type);

  -- Create Credit Memo for Security Deposit Disposition
  PROCEDURE Create_Scrt_Dpst_Dsps_Inv (
	p_api_version		IN  NUMBER,
	p_init_msg_list		IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	x_return_status		OUT NOCOPY VARCHAR2,
	p_contract_id		IN  NUMBER,
	p_contract_line_id	IN  NUMBER DEFAULT NULL,
	p_dispose_amount	IN  NUMBER DEFAULT NULL,
	p_quote_id IN  NUMBER DEFAULT NULL, --akrangan added for bug 7036873
	x_taiv_tbl		OUT NOCOPY taiv_tbl_type);

END OKL_AM_INVOICES_PVT;

/
