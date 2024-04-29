--------------------------------------------------------
--  DDL for Package OKL_STREAM_BILLING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_STREAM_BILLING_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRBSTS.pls 120.6 2008/02/07 13:15:10 zrehman ship $ */


  G_PKG_NAME	CONSTANT VARCHAR2(30)  := 'OKL_STREAM_BILLING_PVT';

  -- -------------------------------------------------------------------------
  -- Billing data structure
  -- -------------------------------------------------------------------------
  TYPE bill_rec_type IS RECORD (
            khr_id                  okc_k_headers_b.id%TYPE,
			bill_date               okl_strm_elements.stream_element_date%TYPE,
			kle_id			        okl_streams.kle_id%TYPE,
			sel_id				    okl_strm_elements.id%TYPE,
			sty_id			        okl_streams.sty_id%TYPE,
			contract_number         okc_k_headers_b.contract_number%TYPE,
            currency_code           okc_k_headers_b.currency_code%TYPE,
            authoring_org_id        okc_k_headers_b.authoring_org_id%TYPE,
			sty_name 			    okl_strm_type_v.NAME%TYPE,
            taxable_default_yn      okl_strm_type_v.taxable_default_yn%TYPE,
			amount			    okl_strm_elements.amount%TYPE,
            sts_code                okc_k_headers_b.sts_code%TYPE);

  TYPE bill_tbl_type IS TABLE OF bill_rec_type
        INDEX BY BINARY_INTEGER;

  -- ----------------------------------------------------------------
  -- Procedure Process_bill_tbl to bill outstanding stream elements
  -- ----------------------------------------------------------------
  PROCEDURE Process_bill_tbl
	(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		    OUT NOCOPY VARCHAR2
    ,p_commit           IN  VARCHAR2
	,p_contract_number	IN  VARCHAR2	DEFAULT NULL
	,p_from_bill_date	IN  DATE	    DEFAULT NULL
	,p_to_bill_date		IN  DATE	    DEFAULT NULL
    ,p_bill_tbl         IN  bill_tbl_type
    ,p_source           IN  VARCHAR2 DEFAULT 'STREAM_BILLING'
	,p_end_of_records   IN  VARCHAR2    DEFAULT NULL);

  -- ----------------------------------------------------------------
  -- Procedure BIL_STREAMS to bill outstanding stream elements
  -- ----------------------------------------------------------------
  PROCEDURE bill_streams
	(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2	DEFAULT Okc_Api.G_FALSE
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		    OUT NOCOPY VARCHAR2
    ,p_commit           IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,p_ia_contract_type     IN  VARCHAR2	DEFAULT NULL  --modified by zrehman for Bug#6788005 on 01-Feb-2008
	,p_contract_number	IN  VARCHAR2	DEFAULT NULL
	,p_from_bill_date	IN  DATE	DEFAULT NULL
	,p_to_bill_date		IN  DATE	DEFAULT NULL
    ,p_cust_acct_id     IN  NUMBER  DEFAULT NULL
    ,p_inv_cust_acct_id      IN NUMBER    DEFAULT NULL  --modified by zrehman for Bug#6788005 on 01-Feb-2008
    ,p_assigned_process IN VARCHAR2 DEFAULT NULL
    ,p_source           IN  VARCHAR2 DEFAULT 'STREAM_BILLING'
 );

  -- ---------------------------------------------------------------------------
  -- Function GET_PRINTING_LEAD_DAYS to extract lead days for invoice generation
  -- ---------------------------------------------------------------------------
  FUNCTION get_printing_lead_days
	(p_khr_id		NUMBER) RETURN		NUMBER;

  PRAGMA RESTRICT_REFERENCES(get_printing_lead_days, WNDS);

  -- ---------------------------------------------------------------------------
  -- Function GET_BANKRUPTCY_STATUS to get the bankruptcy status of a contract.
  -- It also returns the disposition code.
  -- ---------------------------------------------------------------------------
  FUNCTION get_bankruptcy_status
   (p_khr_id NUMBER
   ,x_disposition_code OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

END Okl_Stream_Billing_Pvt;

/
