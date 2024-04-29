--------------------------------------------------------
--  DDL for Package OKL_SETUPFORMULAE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SETUPFORMULAE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSFMS.pls 115.1 2002/02/06 20:33:24 pkm ship       $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_VERSION_OVERLAPS		  CONSTANT VARCHAR2(200) := 'OKL_VERSION_OVERLAPS';
  G_DATES_MISMATCH			  CONSTANT VARCHAR2(200) := 'OKL_DATES_MISMATCH';
  G_FMA_VERSION_OVERLAPS	  CONSTANT VARCHAR2(200) := 'OKL_FMA_VERSION_OVERLAPS';
  G_PAST_RECORDS	  		  CONSTANT VARCHAR2(200) := 'OKL_PAST_RECORDS';
  G_START_DATE				  CONSTANT VARCHAR2(200) := 'OKL_START_DATE';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_TABLE_TOKEN		  		  CONSTANT VARCHAR2(100) := 'OKL_TABLE_NAME';
  G_PARENT_TABLE_TOKEN		  CONSTANT VARCHAR2(100) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		  CONSTANT VARCHAR2(100) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_COL_NAME_TOKEN			  CONSTANT VARCHAR2(100) := OKL_API.G_COL_NAME_TOKEN;

  G_APP_NAME				  CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SETUPFORMULAE_PVT';

  G_INIT_VERSION			  CONSTANT NUMBER := 1.0;
  G_VERSION_MAJOR_INCREMENT	  CONSTANT NUMBER := 1.0;
  G_VERSION_MINOR_INCREMENT	  CONSTANT NUMBER := 0.1;
  G_VERSION_FORMAT			  CONSTANT VARCHAR2(100) := 'FM999.0999';
  G_FORMULA_TYPE			  CONSTANT VARCHAR2(10) := 'GRNC';

  G_EXCEPTION_HALT_PROCESSING EXCEPTION;

  SUBTYPE fmav_rec_type IS okl_formulae_pub.fmav_rec_type;
  SUBTYPE fmav_tbl_type IS okl_formulae_pub.fmav_tbl_type;

  SUBTYPE fodv_rec_type IS okl_fmla_oprnds_pub.fodv_rec_type;
  SUBTYPE fodv_tbl_type IS okl_fmla_oprnds_pub.fodv_tbl_type;

  PROCEDURE get_rec(
  	p_fmav_rec					   IN fmav_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_fmav_rec					   OUT NOCOPY fmav_rec_type);

  PROCEDURE insert_formulae(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fmav_rec                     IN  fmav_rec_type,
    x_fmav_rec                     OUT NOCOPY fmav_rec_type);

  PROCEDURE update_formulae(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fmav_rec                     IN  fmav_rec_type,
    x_fmav_rec                     OUT NOCOPY fmav_rec_type);

END OKL_SETUPFORMULAE_PVT;

 

/
