--------------------------------------------------------
--  DDL for Package OKL_SETUPPOPTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SETUPPOPTIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSPOS.pls 115.3 2002/03/14 16:08:17 pkm ship       $ */

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
  G_OPTION_DUPLICATE_RULE     CONSTANT VARCHAR2(100) := 'OKL_OPTION_DUPLICATE_RULE';

  G_APP_NAME	         	  CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SETUPPOPTIONS_PVT';

  G_EXCEPTION_HALT_PROCESSING EXCEPTION;

  SUBTYPE ponv_rec_type IS  OKL_PRODUCT_OPTIONS_PUB.ponv_rec_type;
  SUBTYPE ponv_tbl_type IS  OKL_PRODUCT_OPTIONS_PUB.ponv_tbl_type;

  -- FOR PRODUCTS
  SUBTYPE pdtv_rec_type IS OKL_PRODUCTS_PUB.pdtv_rec_type;
  SUBTYPE pdtv_tbl_type IS OKL_PRODUCTS_PUB.pdtv_tbl_type;

  PROCEDURE get_rec (
    p_ponv_rec                     IN ponv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_return_status				   OUT NOCOPY VARCHAR2,
	x_ponv_rec					   OUT NOCOPY ponv_rec_type);

  PROCEDURE insert_poptions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdtv_rec                     IN  pdtv_rec_type,
	p_ponv_rec                     IN  ponv_rec_type,
	x_ponv_rec                     OUT NOCOPY ponv_rec_type);

  PROCEDURE delete_poptions(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdtv_rec                     IN  pdtv_rec_type,
    p_ponv_tbl                     IN ponv_tbl_type);

END OKL_SETUPPOPTIONS_PVT;

 

/
