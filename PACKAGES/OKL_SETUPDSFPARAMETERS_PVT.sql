--------------------------------------------------------
--  DDL for Package OKL_SETUPDSFPARAMETERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SETUPDSFPARAMETERS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSFRS.pls 120.1 2005/06/03 05:31:21 rirawat noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SEQUENCE_NUMBER		  	  CONSTANT VARCHAR2(200) := 'OKL_SEQUENCE_NUMBER';

  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_COL_NAME_TOKEN			  CONSTANT VARCHAR2(100) := OKL_API.G_COL_NAME_TOKEN;

  G_APP_NAME				  CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SETUPDSFPARAMETERS_PVT';
  G_PCT_TYPE				  CONSTANT VARCHAR2(30) := 'CONTEXT';	-- parameter context
  G_PSC_TYPE				  CONSTANT VARCHAR2(30) := 'STATIC';	-- parameter static

  G_EXCEPTION_HALT_PROCESSING EXCEPTION;

  SUBTYPE dsfv_rec_type IS okl_data_src_fnctns_pub.dsfv_rec_type;
  SUBTYPE dsfv_tbl_type IS okl_data_src_fnctns_pub.dsfv_tbl_type;

  SUBTYPE fprv_rec_type IS okl_fnctn_prmtrs_pub.fprv_rec_type;
  SUBTYPE fprv_tbl_type IS okl_fnctn_prmtrs_pub.fprv_tbl_type;

  PROCEDURE get_rec(
  	p_fprv_rec					   IN fprv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_fprv_rec					   OUT NOCOPY fprv_rec_type);

  PROCEDURE insert_dsfparameters(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
	p_dsfv_rec					   IN  dsfv_rec_type,
    p_fprv_rec                     IN  fprv_rec_type,
    x_fprv_rec                     OUT NOCOPY fprv_rec_type);

  PROCEDURE update_dsfparameters(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
	p_dsfv_rec					   IN dsfv_rec_type,
    p_fprv_rec                     IN  fprv_rec_type,
    x_fprv_rec                     OUT NOCOPY fprv_rec_type);

  PROCEDURE delete_dsfparameters(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fprv_tbl                     IN  fprv_tbl_type);

-- rirawat 03-Feb-05 4149748: Added the following procedure to insert into OKL_FNCTN_PRMTRS_V - TBL : begin
  PROCEDURE insert_dsfparameters(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
	p_dsfv_rec					   IN dsfv_rec_type,
    p_fprv_tbl                     IN  fprv_tbl_type,
    x_fprv_tbl                     OUT NOCOPY fprv_tbl_type);
-- rirawat 03-Feb-05 4149748: Added the following procedure to insert into OKL_FNCTN_PRMTRS_V - TBL : end

-- rirawat 03-Feb-05 4149748: Added the following procedure to update into OKL_FNCTN_PRMTRS_V - TBL : begin
  PROCEDURE update_dsfparameters(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
	p_dsfv_rec					   IN dsfv_rec_type,
    p_fprv_tbl                     IN  fprv_tbl_type,
    x_fprv_tbl                     OUT NOCOPY fprv_tbl_type);
-- rirawat 03-Feb-05 4149748: Added the following procedure to update into OKL_FNCTN_PRMTRS_V - TBL : end


END OKL_SETUPDSFPARAMETERS_PVT;

 

/
