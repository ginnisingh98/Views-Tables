--------------------------------------------------------
--  DDL for Package OKL_SETUPPOVALUES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SETUPPOVALUES_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSDVS.pls 115.2 2002/02/06 20:33:14 pkm ship       $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_DATES_MISMATCH	          CONSTANT VARCHAR2(200) := 'OKL_DATES_MISMATCH';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_PAST_RECORDS	  		  CONSTANT VARCHAR2(200) := 'OKL_PAST_RECORDS';
  G_START_DATE				  CONSTANT VARCHAR2(200) := 'OKL_START_DATE';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_IN_USE                    CONSTANT VARCHAR2(100) := 'OKL_IN_USE';
  G_PARENT_TABLE_TOKEN		  CONSTANT VARCHAR2(100) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		  CONSTANT VARCHAR2(100) := OKL_API.G_CHILD_TABLE_TOKEN;

  G_APP_NAME	         	  CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SETUPPOVALUES_PVT';

  G_EXCEPTION_HALT_PROCESSING EXCEPTION;

  -- product option value
  SUBTYPE povv_rec_type IS okl_pdt_opt_vals_pub.povv_rec_type;
  SUBTYPE povv_tbl_type IS okl_pdt_opt_vals_pub.povv_tbl_type;

   -- product option
  SUBTYPE ponv_rec_type IS OKL_PRODUCT_OPTIONS_PUB.ponv_rec_type;

  --- PRODUCT
  SUBTYPE pdtv_rec_type IS okl_products_pub.pdtv_rec_type;
  SUBTYPE pdtv_tbl_type IS okl_products_pub.pdtv_tbl_type;

  --- OPTION
  SUBTYPE optv_rec_type IS okl_options_pub.optv_rec_type;
  SUBTYPE optv_tbl_type IS okl_options_pub.optv_tbl_type;

  PROCEDURE get_rec (
    p_povv_rec                     IN povv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN,
   	x_return_status				   OUT NOCOPY VARCHAR2,
	x_povv_rec					   OUT NOCOPY povv_rec_type);

  PROCEDURE insert_povalues(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
	p_pdtv_rec                     IN  pdtv_rec_type,
	p_optv_rec                     IN  optv_rec_type,
    p_povv_rec                     IN  povv_rec_type,
    x_povv_rec                     OUT NOCOPY povv_rec_type);

  PROCEDURE delete_povalues(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
	p_pdtv_rec                     IN  pdtv_rec_type,
	p_optv_rec                     IN  optv_rec_type,
    p_povv_tbl                     IN povv_tbl_type);

END OKL_SETUPPOVALUES_PVT;

 

/
