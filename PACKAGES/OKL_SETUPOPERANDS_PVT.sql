--------------------------------------------------------
--  DDL for Package OKL_SETUPOPERANDS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SETUPOPERANDS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSOPS.pls 115.1 2002/02/06 20:33:39 pkm ship       $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_OPD_VERSION_OVERLAPS	  CONSTANT VARCHAR2(200) := 'OKL_OPD_VERSION_OVERLAPS';
  G_VERSION_OVERLAPS		  CONSTANT VARCHAR2(200) := 'OKL_VERSION_OVERLAPS';
  G_DATES_MISMATCH			  CONSTANT VARCHAR2(200) := 'OKL_DATES_MISMATCH';
  G_START_DATE				  CONSTANT VARCHAR2(200) := 'OKL_START_DATE';
  G_PAST_RECORDS			  CONSTANT VARCHAR2(200) := 'OKL_PAST_RECORDS';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_PARENT_TABLE_TOKEN		  CONSTANT VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		  CONSTANT VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;

  G_APP_NAME				  CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SETUPOPERANDS_PVT';

  G_INIT_VERSION			  CONSTANT NUMBER := OKL_ACCOUNTING_UTIL.G_INIT_VERSION;
  G_VERSION_MAJOR_INCREMENT	  CONSTANT NUMBER := OKL_ACCOUNTING_UTIL.G_VERSION_MAJOR_INCREMENT;
  G_VERSION_MINOR_INCREMENT	  CONSTANT NUMBER := OKL_ACCOUNTING_UTIL.G_VERSION_MINOR_INCREMENT;
  G_VERSION_FORMAT			  CONSTANT VARCHAR2(100) := OKL_ACCOUNTING_UTIL.G_VERSION_FORMAT;
  G_FINAL_DATE                CONSTANT DATE := OKL_ACCOUNTING_UTIL.G_FINAL_DATE;
  G_FORMULA_TYPE			  CONSTANT VARCHAR2(10) := 'FMLA';
  G_FUNCTION_TYPE			  CONSTANT VARCHAR2(10) := 'FCNT';
  G_CONSTANT_TYPE			  CONSTANT VARCHAR2(10) := 'CNST';

  G_EXCEPTION_HALT_PROCESSING EXCEPTION;

  SUBTYPE opdv_rec_type IS okl_operands_pub.opdv_rec_type;
  SUBTYPE opdv_tbl_type IS okl_operands_pub.opdv_tbl_type;

  PROCEDURE get_rec(
  	p_opdv_rec					   IN opdv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_opdv_rec					   OUT NOCOPY opdv_rec_type);

  PROCEDURE insert_operands(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opdv_rec                     IN  opdv_rec_type,
    x_opdv_rec                     OUT NOCOPY opdv_rec_type);

  PROCEDURE update_operands(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opdv_rec                     IN  opdv_rec_type,
    x_opdv_rec                     OUT NOCOPY opdv_rec_type);

END OKL_SETUPOPERANDS_PVT;

 

/
