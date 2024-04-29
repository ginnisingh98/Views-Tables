--------------------------------------------------------
--  DDL for Package OKL_CASH_APPLN_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CASH_APPLN_RULE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRCSLS.pls 115.2 2002/12/24 00:07:36 pjgomes noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- Sub type cash application rules header record
  subtype cauv_rec_type is okl_cau_pvt.cauv_rec_type;
  subtype cauv_tbl_type is okl_cau_pvt.cauv_tbl_type;

  -- Sub type cash application rules line record
  subtype catv_rec_type is okl_cat_pvt.catv_rec_type;
  subtype catv_tbl_type is okl_cat_pvt.catv_tbl_type;

  ------------------------------------------------------------------------------
  -- Global Variables
  ------------------------------------------------------------------------------
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_CASH_APPLN_RULE_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(3)   := 'OKL';
  G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';

  ------------------------------------------------------------------------------
   --Global Exception
  ------------------------------------------------------------------------------
   G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

  PROCEDURE maint_cash_appln_rule(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_catv_tbl                 IN catv_tbl_type,
     x_catv_tbl                 OUT NOCOPY catv_tbl_type,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2);

  --returns stream type allocation info
  --if p_out_field='SEQ', sequence_number is returned
  --if p_out_field='SAT', stream_allc_type is returned
  --if p_out_field='ALL', $sequence_number$stream_allc_type is returned
  FUNCTION get_strm_typ_allocs(
     p_cat_id IN NUMBER,
     p_sty_id IN NUMBER,
     p_stream_allc_type IN VARCHAR2,
     p_out_field IN VARCHAR2 DEFAULT 'ALL') RETURN VARCHAR2;

  PRAGMA RESTRICT_REFERENCES(get_strm_typ_allocs, wnds, wnps);
END OKL_CASH_APPLN_RULE_PVT;

 

/
