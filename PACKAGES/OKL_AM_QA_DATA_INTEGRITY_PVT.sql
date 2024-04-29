--------------------------------------------------------
--  DDL for Package OKL_AM_QA_DATA_INTEGRITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_QA_DATA_INTEGRITY_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRAMQS.pls 115.3 2002/08/19 20:01:30 rdraguil noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

  SUBTYPE rgr_rec_type IS okl_rgrp_rules_process_pub.rgr_rec_type;

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
					'OKL_AM_QA_DATA_INTEGRITY_PVT';

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

  -- Mandatory checks for values of contract rules used by AM
  PROCEDURE check_rule_constraints (
	x_return_status	OUT NOCOPY VARCHAR2,
	p_chr_id	IN  NUMBER);

  -- Optional checks for values of contract rules used by AM
  PROCEDURE check_warning_constraints (
	x_return_status	OUT NOCOPY VARCHAR2,
	p_chr_id	IN  NUMBER);

  -- Check correct format of Formula-Amount rules used by AM
  PROCEDURE check_am_rule_format (
	x_return_status	OUT NOCOPY VARCHAR2,
	p_chr_id	IN  NUMBER,
	p_rgr_rec	IN  rgr_rec_type);

END okl_am_qa_data_integrity_pvt;

 

/
