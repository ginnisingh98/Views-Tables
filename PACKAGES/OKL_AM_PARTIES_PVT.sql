--------------------------------------------------------
--  DDL for Package OKL_AM_PARTIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_PARTIES_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRAMPS.pls 115.9 2003/11/10 23:19:07 rsrivast noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

  TYPE	q_party_uv_rec_type IS RECORD (
	quote_id	NUMBER,
	contract_id	NUMBER,
	k_buy_or_sell	VARCHAR2(3),
	qp_party_id	NUMBER,			-- Quote Party Info
	qp_role_code	VARCHAR2(30),
	qp_party_role	VARCHAR2(80),
	qp_date_sent	DATE,
	qp_date_hold	DATE,
	qp_created_by		NUMBER,	-- Quote Party WHO columns
	qp_creation_date	DATE,
	qp_last_updated_by	NUMBER,
	qp_last_update_date	DATE,
	qp_last_update_login	NUMBER,
	kp_party_id	NUMBER,			-- Contract Party Info
	kp_role_code	VARCHAR2(30),
	kp_party_role	VARCHAR2(80),
	po_party_id1	VARCHAR2(40),		-- Party Object Info
	po_party_id2	VARCHAR2(200),
	po_party_object	VARCHAR2(30),
	po_party_name	VARCHAR2(360),
	po_party_desc	VARCHAR2(2000),
	co_contact_id1	VARCHAR2(40),		-- Contact Object Info
	co_contact_id2	VARCHAR2(200),
	co_contact_object VARCHAR2(30),
	co_contact_name	VARCHAR2(360),
	co_contact_desc	VARCHAR2(2000),
	co_email	VARCHAR2(2000),
	co_order_num	NUMBER,
	co_date_sent	DATE,
	cp_point_id	NUMBER,			-- Contact Point Info
	cp_point_type	VARCHAR2(30),
	cp_primary_flag	VARCHAR2(3),
	cp_email	VARCHAR2(2000),
	cp_details	VARCHAR2(2000),
	cp_order_num	NUMBER,
	cp_date_sent	DATE);

  TYPE	party_object_rec_type IS RECORD (
	p_code		VARCHAR2(30),		-- Party Info
	p_id1		VARCHAR2(40),
	p_id2		VARCHAR2(200),
	p_name		VARCHAR2(360),
	p_desc		VARCHAR2(2000),
	s_code		VARCHAR2(30),		-- Site Info
	s_id1		VARCHAR2(40),
	s_id2		VARCHAR2(200),
	s_name		VARCHAR2(360),
	s_desc		VARCHAR2(2000),
	c_code		VARCHAR2(30),		-- Contact Info
	c_id1		VARCHAR2(40),
	c_id2		VARCHAR2(200),
	c_name		VARCHAR2(360),
	c_desc		VARCHAR2(2000),
	c_email		VARCHAR2(2000),
	c_person_id	NUMBER,
	pcp_id		NUMBER(15),		-- Contact Point Info
	pcp_primary	VARCHAR2(3),
	pcp_email	VARCHAR2(2000));

  TYPE	q_party_uv_tbl_type	IS TABLE OF q_party_uv_rec_type
				INDEX BY BINARY_INTEGER;

  TYPE	party_object_tbl_type	IS TABLE OF party_object_rec_type
				INDEX BY BINARY_INTEGER;

  SUBTYPE qtev_rec_type	IS okl_trx_quotes_pub.qtev_rec_type;
  SUBTYPE qpyv_tbl_type IS okl_quote_parties_pub.qpyv_tbl_type;
  SUBTYPE qpyv_rec_type IS okl_quote_parties_pub.qpyv_rec_type;

  G_EMPTY_QPYV_TBL	qpyv_tbl_type;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------

  -- Validation for missing fields
  G_MISS_NUM		CONSTANT NUMBER		:= OKL_API.G_MISS_NUM;
  G_MISS_CHAR		CONSTANT VARCHAR2(1)	:= OKL_API.G_MISS_CHAR;
  G_MISS_DATE		CONSTANT DATE		:= OKL_API.G_MISS_DATE;

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS FOR ERROR HANDLING
  ---------------------------------------------------------------------------

  G_APP_NAME		CONSTANT VARCHAR2(3)	:=  OKL_API.G_APP_NAME;
  G_API_VERSION		CONSTANT NUMBER		:= 1;
  G_PKG_NAME		CONSTANT VARCHAR2(200)	:=
					'OKL_AM_PARTIES_PVT';

  G_SQLCODE_TOKEN	CONSTANT VARCHAR2(200)	:= 'SQLCODE';
  G_SQLERRM_TOKEN	CONSTANT VARCHAR2(200)	:= 'SQLERRM';
  G_UNEXPECTED_ERROR	CONSTANT VARCHAR2(200)	:=
					 'OKL_CONTRACTS_UNEXPECTED_ERROR';

  G_OKC_APP_NAME	CONSTANT VARCHAR2(3)	:= OKC_API.G_APP_NAME;
  G_INVALID_VALUE	CONSTANT VARCHAR2(200)	:= OKC_API.G_INVALID_VALUE;
  G_REQUIRED_VALUE	CONSTANT VARCHAR2(200)	:= OKC_API.G_REQUIRED_VALUE;
  G_COL_NAME_TOKEN	CONSTANT VARCHAR2(200)	:= OKC_API.G_COL_NAME_TOKEN;

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  -- Return quote parties using setup rules
  PROCEDURE fetch_rule_quote_parties (
	p_api_version		IN  NUMBER,
	p_init_msg_list		IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	x_return_status		OUT NOCOPY VARCHAR2,
	p_qtev_rec		IN  qtev_rec_type,
	x_qpyv_tbl		OUT NOCOPY qpyv_tbl_type,
	x_q_party_uv_tbl	OUT NOCOPY q_party_uv_tbl_type,
	x_record_count		OUT NOCOPY NUMBER);

  -- Assign a vendor partner as a quote recipient
  PROCEDURE create_partner_as_recipient (
	p_qtev_rec		IN  qtev_rec_type,
	p_validate_only		IN  BOOLEAN DEFAULT FALSE,
	x_qpyv_tbl		OUT NOCOPY qpyv_tbl_type,
	x_return_status		OUT NOCOPY VARCHAR2);

  -- Create all quote parties using setup rules
  PROCEDURE create_quote_parties (
	p_qtev_rec		IN  qtev_rec_type,
	p_qpyv_tbl		IN  qpyv_tbl_type DEFAULT G_EMPTY_QPYV_TBL,
	p_validate_only		IN  BOOLEAN DEFAULT FALSE,
	x_qpyv_tbl		OUT NOCOPY qpyv_tbl_type,
	x_return_status		OUT NOCOPY VARCHAR2);

  -- Return OKX party, vendor, site, contact information
  PROCEDURE get_party_details (
	p_id_code		IN VARCHAR2,
	p_id_value		IN VARCHAR2,
	x_party_object_tbl	OUT NOCOPY party_object_tbl_type,
	x_return_status		OUT NOCOPY VARCHAR2);

  -- Return quote party information
  PROCEDURE get_quote_parties (
	p_api_version		IN NUMBER,
	p_init_msg_list		IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	x_return_status		OUT NOCOPY VARCHAR2,
	p_q_party_uv_rec	IN q_party_uv_rec_type,
	x_q_party_uv_tbl	OUT NOCOPY q_party_uv_tbl_type,
	x_record_count		OUT NOCOPY NUMBER);

  -- Return quote party contact information
  PROCEDURE get_quote_party_contacts (
	p_api_version		IN NUMBER,
	p_init_msg_list		IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	x_return_status		OUT NOCOPY VARCHAR2,
	p_q_party_uv_rec	IN q_party_uv_rec_type,
	x_q_party_uv_tbl	OUT NOCOPY q_party_uv_tbl_type,
	x_record_count		OUT NOCOPY NUMBER);

  -- Return quote party contact point information
  PROCEDURE get_quote_contact_points (
	p_api_version		IN NUMBER,
	p_init_msg_list		IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	x_return_status		OUT NOCOPY VARCHAR2,
	p_q_party_uv_rec	IN q_party_uv_rec_type,
	x_q_party_uv_tbl	OUT NOCOPY q_party_uv_tbl_type,
	x_record_count		OUT NOCOPY NUMBER);

END okl_am_parties_pvt;

 

/
