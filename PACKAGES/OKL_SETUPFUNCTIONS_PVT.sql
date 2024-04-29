--------------------------------------------------------
--  DDL for Package OKL_SETUPFUNCTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SETUPFUNCTIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSDFS.pls 115.1 2002/02/06 20:33:06 pkm ship       $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_START_DATE				  CONSTANT VARCHAR2(200) := 'OKL_START_DATE';
  G_DSF_VERSION_OVERLAPS	  CONSTANT VARCHAR2(200) := 'OKL_DSF_VERSION_OVERLAPS';
  G_DATES_MISMATCH			  CONSTANT VARCHAR2(200) := 'OKL_DATES_MISMATCH';
  G_PAST_RECORDS			  CONSTANT VARCHAR2(200) := 'OKL_PAST_RECORDS';

  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_PARENT_TABLE_TOKEN		  CONSTANT VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		  CONSTANT VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;

  G_APP_NAME				  CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SETUPFUNCTIONS_PVT';

  G_INIT_VERSION			  CONSTANT NUMBER := 1.0;
  G_VERSION_MAJOR_INCREMENT	  CONSTANT NUMBER := 1.0;
  G_VERSION_MINOR_INCREMENT	  CONSTANT NUMBER := 0.1;
  G_VERSION_FORMAT			  CONSTANT VARCHAR2(100) := 'FM999.0099';
  G_FUNCTION_TYPE			  CONSTANT VARCHAR2(10) := 'PLSQL';

  G_EXCEPTION_HALT_PROCESSING EXCEPTION;

  SUBTYPE dsfv_rec_type IS okl_data_src_fnctns_pub.dsfv_rec_type;
  SUBTYPE dsfv_tbl_type IS okl_data_src_fnctns_pub.dsfv_tbl_type;

  SUBTYPE fprv_rec_type IS okl_fnctn_prmtrs_pub.fprv_rec_type;
  SUBTYPE fprv_tbl_type IS okl_fnctn_prmtrs_pub.fprv_tbl_type;

  PROCEDURE get_rec(
  	p_dsfv_rec					   IN dsfv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_dsfv_rec					   OUT NOCOPY dsfv_rec_type);

  PROCEDURE insert_functions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsfv_rec                     IN  dsfv_rec_type,
    x_dsfv_rec                     OUT NOCOPY dsfv_rec_type);

  PROCEDURE update_functions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsfv_rec                     IN  dsfv_rec_type,
    x_dsfv_rec                     OUT NOCOPY dsfv_rec_type);

END OKL_SETUPFUNCTIONS_PVT;

 

/
