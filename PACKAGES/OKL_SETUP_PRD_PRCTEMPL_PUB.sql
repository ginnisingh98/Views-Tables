--------------------------------------------------------
--  DDL for Package OKL_SETUP_PRD_PRCTEMPL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SETUP_PRD_PRCTEMPL_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPPPES.pls 115.2 2002/02/15 18:19:27 pkm ship       $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_VERSION_OVERLAPS		  CONSTANT VARCHAR2(200) := 'OKL_VERSION_OVERLAPS';
  G_DATES_MISMATCH			  CONSTANT VARCHAR2(200) := 'OKL_DATES_MISMATCH';
  G_PAST_RECORDS	  		  CONSTANT VARCHAR2(200) := 'OKL_PAST_RECORDS';
  G_START_DATE				  CONSTANT VARCHAR2(200) := 'OKL_START_DATE';
  G_END_DATE				  CONSTANT VARCHAR2(200) := 'OKL_END_DATE';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_TABLE_TOKEN		  		  CONSTANT VARCHAR2(100) := 'OKL_TABLE_NAME';
  G_PARENT_TABLE_TOKEN		  CONSTANT VARCHAR2(100) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		  CONSTANT VARCHAR2(100) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_COL_NAME_TOKEN			  CONSTANT VARCHAR2(100) := OKL_API.G_COL_NAME_TOKEN;

  G_APP_NAME				  CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SETUP_PRD_PRCTEMPL_PUB';

  G_INIT_VERSION			  CONSTANT NUMBER := 1.0;
  G_VERSION_MAJOR_INCREMENT	  CONSTANT NUMBER := 1.0;
  G_VERSION_MINOR_INCREMENT	  CONSTANT NUMBER := 0.1;
  G_VERSION_FORMAT			  CONSTANT VARCHAR2(100) := 'FM999.0999';

  G_EXC_NAME_ERROR		CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_ERROR';
  G_EXC_NAME_UNEXP_ERROR	CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_UNEXP_ERROR';
  G_EXC_NAME_OTHERS	        CONSTANT VARCHAR2(6) := 'OTHERS';
  G_API_TYPE	CONSTANT VARCHAR(4) := '_PUB';
  G_RET_STS_SUCCESS		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_UNEXP_ERROR;


  G_EXCEPTION_HALT_PROCESSING 		EXCEPTION;
  G_EXCEPTION_ERROR			  		EXCEPTION;
  G_EXCEPTION_UNEXPECTED_ERROR		EXCEPTION;

  SUBTYPE pitv_rec_type IS okl_prd_price_tmpls_pub.pitv_rec_type;
  SUBTYPE pitv_tbl_type IS okl_prd_price_tmpls_pub.pitv_tbl_type;

  SUBTYPE pdtv_rec_type IS okl_products_pub.pdtv_rec_type;
  SUBTYPE pdtv_tbl_type IS okl_products_pub.pdtv_tbl_type;

 PROCEDURE insert_prd_price_tmpls(
         p_api_version                  IN  NUMBER,
         p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_pitv_rec                     IN  pitv_rec_type,
         x_pitv_rec                     OUT NOCOPY pitv_rec_type);


 PROCEDURE update_prd_price_tmpls(
        p_api_version                  IN  NUMBER,
        p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_pitv_rec                     IN  pitv_rec_type,
        x_pitv_rec                     OUT NOCOPY pitv_rec_type);

 PROCEDURE insert_prd_price_tmpls(
         p_api_version                  IN  NUMBER,
         p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_pitv_tbl                     IN  pitv_tbl_type,
         x_pitv_tbl                     OUT NOCOPY pitv_tbl_type);


 PROCEDURE update_prd_price_tmpls(
        p_api_version                  IN  NUMBER,
        p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_pitv_tbl                     IN  pitv_tbl_type,
        x_pitv_tbl                     OUT NOCOPY pitv_tbl_type);

 PROCEDURE check_product_constraints(
        p_api_version                  IN  NUMBER,
        p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
	p_pdtv_rec			IN  pdtv_rec_type,
        x_validated		       OUT NOCOPY VARCHAR2);

  PROCEDURE check_product_constraints(
         p_api_version                  IN  NUMBER,
         p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_pdtv_tbl			IN  pdtv_tbl_type,
        x_validated		       OUT NOCOPY VARCHAR2);


END OKL_SETUP_PRD_PRCTEMPL_PUB;

 

/
