--------------------------------------------------------
--  DDL for Package OKL_SETUPOVDTEMPLATES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SETUPOVDTEMPLATES_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSVTS.pls 115.1 2002/02/06 20:34:23 pkm ship       $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_PAST_RECORDS	  		  CONSTANT VARCHAR2(200) := 'OKL_PAST_RECORDS';
  G_IN_USE                    CONSTANT VARCHAR2(200) := 'OKL_IN_USE';
  G_DATES_MISMATCH            CONSTANT VARCHAR2(200) := 'OKL_DATES_MISMATCH';
  G_MISS_DATA				  CONSTANT VARCHAR2(200) := 'OKL_MISS_DATA';
  G_RULE_MISMATCH		      CONSTANT VARCHAR2(200) := 'OKL_RULE_MISMATCH';
  G_CONTEXT_MISMATCH		  CONSTANT VARCHAR2(200) := 'OKL_CONTEXT_MISMATCH';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_TABLE_TOKEN		  		  CONSTANT VARCHAR2(100) := 'OKL_TABLE_NAME';
  G_PARENT_TABLE_TOKEN		  CONSTANT VARCHAR2(100) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		  CONSTANT VARCHAR2(100) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_COL_NAME_TOKEN			  CONSTANT VARCHAR2(100) := OKL_API.G_COL_NAME_TOKEN;
  G_CONTEXT_TOKEN		  	  CONSTANT VARCHAR2(100) := 'OKL_CONTEXT_NAME';

  G_APP_NAME				  CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SETUPOVDTEMPLATES_PVT';

  G_EXCEPTION_HALT_PROCESSING EXCEPTION;

  SUBTYPE optv_rec_type IS okl_options_pub.optv_rec_type;
  SUBTYPE optv_tbl_type IS okl_options_pub.optv_tbl_type;

  SUBTYPE ovev_rec_type IS okl_options_pub.ovev_rec_type;
  SUBTYPE ovev_tbl_type IS okl_options_pub.ovev_tbl_type;

  SUBTYPE ovdv_rec_type IS okl_option_rules_pub.ovdv_rec_type;
  SUBTYPE ovdv_tbl_type IS okl_option_rules_pub.ovdv_tbl_type;

  SUBTYPE ovtv_rec_type IS okl_ovd_rul_tmls_pub.ovtv_rec_type;
  SUBTYPE ovtv_tbl_type IS okl_ovd_rul_tmls_pub.ovtv_tbl_type;

  SUBTYPE rulv_rec_type is okl_rule_apis_pvt.rulv_rec_type;
  SUBTYPE rulv_disp_rec_type IS okl_rule_apis_pvt.rulv_disp_rec_type;

  PROCEDURE get_rec(
  	p_ovtv_rec					   IN ovtv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_ovtv_rec					   OUT NOCOPY ovtv_rec_type);

  PROCEDURE insert_ovdtemplates(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_optv_rec                     IN  optv_rec_type,
    p_ovev_rec                     IN  ovev_rec_type,
    p_ovdv_rec                     IN  ovdv_rec_type,
    p_ovtv_rec                     IN  ovtv_rec_type,
    x_ovtv_rec                     OUT NOCOPY ovtv_rec_type);

  PROCEDURE delete_ovdtemplates(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_optv_rec                     IN  optv_rec_type,
    p_ovev_rec                     IN  ovev_rec_type,
    p_ovdv_rec                     IN  ovdv_rec_type,
    p_ovtv_tbl                     IN  ovtv_tbl_type);

END OKL_SETUPOVDTEMPLATES_PVT;

 

/
