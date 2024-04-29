--------------------------------------------------------
--  DDL for Package OKL_CASH_APPLN_RULE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CASH_APPLN_RULE_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPCSLS.pls 115.1 2002/12/17 00:02:23 pjgomes noship $ */
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
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_CASH_APPLN_RULE_PUB';
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

END OKL_CASH_APPLN_RULE_PUB;

 

/
