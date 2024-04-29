--------------------------------------------------------
--  DDL for Package OKL_SETUPOPTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SETUPOPTIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSOTS.pls 115.1 2002/02/06 20:33:47 pkm ship       $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_DATES_MISMATCH			  CONSTANT VARCHAR2(200) := 'OKL_DATES_MISMATCH';
  G_PAST_RECORDS	  		  CONSTANT VARCHAR2(200) := 'OKL_PAST_RECORDS';
  G_START_DATE				  CONSTANT VARCHAR2(200) := 'OKL_START_DATE';
  G_NOT_ALLOWED               CONSTANT VARCHAR2(200) := 'OKL_NOT_ALLOWED';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_TABLE_TOKEN		  		  CONSTANT VARCHAR2(100) := 'OKL_TABLE_NAME';
  G_PARENT_TABLE_TOKEN		  CONSTANT VARCHAR2(100) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		  CONSTANT VARCHAR2(100) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_COL_NAME_TOKEN			  CONSTANT VARCHAR2(100) := OKL_API.G_COL_NAME_TOKEN;

  G_APP_NAME				  CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SETUPOPTIONS_PVT';

  G_EXCEPTION_HALT_PROCESSING EXCEPTION;

  SUBTYPE optv_rec_type IS okl_options_pub.optv_rec_type;
  SUBTYPE optv_tbl_type IS okl_options_pub.optv_tbl_type;

  PROCEDURE get_rec(
  	p_optv_rec					   IN optv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_optv_rec					   OUT NOCOPY optv_rec_type);

  PROCEDURE insert_options(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_optv_rec                     IN  optv_rec_type,
    x_optv_rec                     OUT NOCOPY optv_rec_type);

  PROCEDURE update_options(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_optv_rec                     IN  optv_rec_type,
    x_optv_rec                     OUT NOCOPY optv_rec_type);

END OKL_SETUPOPTIONS_PVT;

 

/
