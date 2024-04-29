--------------------------------------------------------
--  DDL for Package OKL_SETUPCGRPARAMETERS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SETUPCGRPARAMETERS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPSCMS.pls 120.1 2005/06/03 05:30:02 rirawat noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';

  G_APP_NAME				  CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SETUPCGRPARAMETERS_PUB';

  SUBTYPE cgmv_rec_type IS okl_setupcgrparameters_pvt.cgmv_rec_type;
  SUBTYPE cgmv_tbl_type IS okl_setupcgrparameters_pvt.cgmv_tbl_type;

  PROCEDURE get_rec(
  	p_cgmv_rec					   IN cgmv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
	x_msg_data					   OUT NOCOPY VARCHAR2,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_cgmv_rec					   OUT NOCOPY cgmv_rec_type);

  PROCEDURE insert_cgrparameters(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgmv_rec                     IN  cgmv_rec_type,
    x_cgmv_rec                     OUT NOCOPY cgmv_rec_type);

  PROCEDURE update_cgrparameters(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgmv_rec                     IN  cgmv_rec_type,
    x_cgmv_rec                     OUT NOCOPY cgmv_rec_type);

  PROCEDURE delete_cgrparameters(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgmv_tbl                     IN  cgmv_tbl_type);

-- rirawat 03-Feb-05 4149748: Added the following procedure to insert into OKL_CNTX_GRP_PRMTRS_V - TBL : begin
  PROCEDURE insert_cgrparameters(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgmv_tbl                     IN  cgmv_tbl_type,
    x_cgmv_tbl                     OUT NOCOPY cgmv_tbl_type);
-- rirawat 03-Feb-05 4149748: Added the following procedure to insert into OKL_CNTX_GRP_PRMTRS_V - TBL : end

-- rirawat 03-Feb-05 4149748: Added the following procedure to update into OKL_CNTX_GRP_PRMTRS_V - TBL : begin
   PROCEDURE update_cgrparameters(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgmv_tbl                     IN  cgmv_tbl_type,
    x_cgmv_tbl                     OUT NOCOPY cgmv_tbl_type);
-- rirawat 03-Feb-05 4149748: Added the following procedure to update into OKL_CNTX_GRP_PRMTRS_V - TBL : end

END OKL_SETUPCGRPARAMETERS_PUB;

 

/
