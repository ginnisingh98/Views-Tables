--------------------------------------------------------
--  DDL for Package OKL_SETUPFMACONSTRAINTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SETUPFMACONSTRAINTS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPSFCS.pls 120.1 2005/06/03 05:28:55 rirawat noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';

  G_APP_NAME				  CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SETUPFMACONSTRAINTS_PUB';

  SUBTYPE fmav_rec_type IS okl_setupfmaconstraints_pvt.fmav_rec_type;
  SUBTYPE fmav_tbl_type IS okl_setupfmaconstraints_pvt.fmav_tbl_type;

  SUBTYPE fodv_rec_type IS okl_setupfmaconstraints_pvt.fodv_rec_type;
  SUBTYPE fodv_tbl_type IS okl_setupfmaconstraints_pvt.fodv_tbl_type;

  PROCEDURE get_rec(
  	p_fodv_rec					   IN fodv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
	x_msg_data					   OUT NOCOPY VARCHAR2,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_fodv_rec					   OUT NOCOPY fodv_rec_type);

  PROCEDURE insert_fmaconstraints(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fmav_rec                     IN  fmav_rec_type,
    p_fodv_rec                     IN  fodv_rec_type,
    x_fodv_rec                     OUT NOCOPY fodv_rec_type);

  PROCEDURE update_fmaconstraints(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fmav_rec                     IN  fmav_rec_type,
    p_fodv_rec                     IN  fodv_rec_type,
    x_fodv_rec                     OUT NOCOPY fodv_rec_type);

  PROCEDURE delete_fmaconstraints(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fodv_tbl                     IN  fodv_tbl_type);

-- rirawat 03-Feb-05 4149748: Added the following procedure to insert into OKL_FMLA_OPRNDS - TBL : begin
 PROCEDURE insert_fmaconstraints(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fmav_rec                     IN  fmav_rec_type,
    p_fodv_tbl                     IN  fodv_tbl_type,
    x_fodv_tbl                     OUT NOCOPY fodv_tbl_type);
-- rirawat 03-Feb-05 4149748: Added the following procedure to insert into OKL_FMLA_OPRNDS - TBL : end

-- rirawat 03-Feb-05 4149748: Added the following procedure to update into OKL_FMLA_OPRNDS - TBL : begin
  PROCEDURE update_fmaconstraints(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fmav_rec                     IN  fmav_rec_type,
    p_fodv_tbl                     IN  fodv_tbl_type,
    x_fodv_tbl                     OUT NOCOPY fodv_tbl_type);
-- rirawat 03-Feb-05 4149748: Added the following procedure to update into OKL_FMLA_OPRNDS - TBL : end

END OKL_SETUPFMACONSTRAINTS_PUB;

 

/
