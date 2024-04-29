--------------------------------------------------------
--  DDL for Package OKL_SETUPPRODUCTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SETUPPRODUCTS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPSPDS.pls 120.4 2008/02/29 10:49:58 asawanka ship $ */


  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';

  G_APP_NAME				  CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SETUPPRODUCTS_PUB';

  SUBTYPE pdtv_rec_type IS okl_setupproducts_pvt.pdtv_rec_type;
  SUBTYPE pdtv_tbl_type IS okl_setupproducts_pvt.pdtv_tbl_type;

  SUBTYPE pdt_parameters_rec_type IS okl_setupproducts_pvt.pdt_parameters_rec_type;
  SUBTYPE pdt_parameters_tbl_type IS okl_setupproducts_pvt.pdt_parameters_tbl_type;

  PROCEDURE get_rec(
  	p_pdtv_rec					   IN pdtv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
	x_msg_data					   OUT NOCOPY VARCHAR2,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_pdtv_rec					   OUT NOCOPY pdtv_rec_type);


  PROCEDURE Getpdt_parameters(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
	x_no_data_found                OUT NOCOPY BOOLEAN,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdtv_rec                     IN  pdtv_rec_type,
    p_product_date                 IN  DATE DEFAULT SYSDATE,
    p_pdt_parameter_rec            OUT NOCOPY pdt_parameters_rec_type);


  PROCEDURE insert_products(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdtv_rec                     IN  pdtv_rec_type,
    x_pdtv_rec                     OUT NOCOPY pdtv_rec_type);

  PROCEDURE update_products(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdtv_rec                     IN  pdtv_rec_type,
    x_pdtv_rec                     OUT NOCOPY pdtv_rec_type);

END OKL_SETUPPRODUCTS_PUB;

/
