--------------------------------------------------------
--  DDL for Package OKL_SETUPPDTTEMPLATES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SETUPPDTTEMPLATES_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSPTS.pls 115.1 2002/02/06 20:34:01 pkm ship       $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_VERSION_OVERLAPS		  CONSTANT VARCHAR2(200) := 'OKL_VERSION_OVERLAPS';
  G_DATES_MISMATCH			  CONSTANT VARCHAR2(200) := 'OKL_DATES_MISMATCH';
  G_PAST_RECORDS	  		  CONSTANT VARCHAR2(200) := 'OKL_PAST_RECORDS';
  G_START_DATE				  CONSTANT VARCHAR2(200) := 'OKL_START_DATE';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_TABLE_TOKEN		  		  CONSTANT VARCHAR2(100) := 'OKL_TABLE_NAME';
  G_PARENT_TABLE_TOKEN		  CONSTANT VARCHAR2(100) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		  CONSTANT VARCHAR2(100) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_COL_NAME_TOKEN			  CONSTANT VARCHAR2(100) := OKL_API.G_COL_NAME_TOKEN;

  G_APP_NAME				  CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SETUPPDTTEMPLATES_PVT';

  G_INIT_VERSION			  CONSTANT NUMBER := 1.0;
  G_VERSION_MAJOR_INCREMENT	  CONSTANT NUMBER := 1.0;
  G_VERSION_MINOR_INCREMENT	  CONSTANT NUMBER := 0.1;
  G_VERSION_FORMAT			  CONSTANT VARCHAR2(100) := 'FM999.0999';
  G_COPY                      CONSTANT VARCHAR2(10) := 'COPY';
  G_UPDATE                    CONSTANT VARCHAR2(10) := 'UPDATE';

  G_EXCEPTION_HALT_PROCESSING EXCEPTION;

  SUBTYPE ptlv_rec_type IS okl_pdt_templates_pub.ptlv_rec_type;
  SUBTYPE ptlv_tbl_type IS okl_pdt_templates_pub.ptlv_tbl_type;

  SUBTYPE pmvv_rec_type IS okl_ptq_values_pub.pmvv_rec_type;
  SUBTYPE pmvv_tbl_type IS okl_ptq_values_pub.pmvv_tbl_type;

  SUBTYPE pdqv_rec_type IS okl_pdt_pqys_pub.pdqv_rec_type;
  SUBTYPE pdqv_tbl_type IS okl_pdt_pqys_pub.pdqv_tbl_type;

  PROCEDURE get_rec(
  	p_ptlv_rec					   IN ptlv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_ptlv_rec					   OUT NOCOPY ptlv_rec_type);

  PROCEDURE get_version(
    p_name				           IN VARCHAR2,
  	p_cur_version		           IN VARCHAR2,
	p_from_date		               IN DATE,
	p_to_date			           IN DATE,
	p_table				           IN VARCHAR2,
  	x_return_status		           OUT NOCOPY VARCHAR2,
	x_new_version		           OUT NOCOPY VARCHAR2);

  PROCEDURE check_overlaps (
    p_id			               IN NUMBER,
  	p_name			               IN VARCHAR2,
  	p_from_date   	               IN DATE,
	p_to_date	   	               IN DATE,
	p_table			               IN VARCHAR2,
	x_return_status	               OUT NOCOPY VARCHAR2,
	x_valid			               OUT NOCOPY BOOLEAN);

  PROCEDURE insert_pdttemplates(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptlv_rec                     IN  ptlv_rec_type,
    x_ptlv_rec                     OUT NOCOPY ptlv_rec_type);

  PROCEDURE update_pdttemplates(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptlv_rec                     IN  ptlv_rec_type,
    x_ptlv_rec                     OUT NOCOPY ptlv_rec_type);

END OKL_SETUPPDTTEMPLATES_PVT;

 

/
