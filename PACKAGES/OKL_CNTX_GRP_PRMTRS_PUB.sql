--------------------------------------------------------
--  DDL for Package OKL_CNTX_GRP_PRMTRS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CNTX_GRP_PRMTRS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPCGMS.pls 115.6 2002/02/05 12:04:44 pkm ship       $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLcode';

  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_CNTX_GRP_PRMTRS_PUB';

  SUBTYPE cgmv_rec_type IS okl_cgm_pvt.cgmv_rec_type;
  SUBTYPE cgmv_tbl_type IS okl_cgm_pvt.cgmv_tbl_type;

  PROCEDURE add_language;

  PROCEDURE insert_cntx_grp_prmtrs(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgmv_rec                     IN  cgmv_rec_type,
    x_cgmv_rec                     OUT NOCOPY cgmv_rec_type);

  PROCEDURE insert_cntx_grp_prmtrs(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgmv_tbl                     IN  cgmv_tbl_type,
    x_cgmv_tbl                     OUT NOCOPY cgmv_tbl_type);

  PROCEDURE lock_cntx_grp_prmtrs(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgmv_rec                     IN cgmv_rec_type);

  PROCEDURE lock_cntx_grp_prmtrs(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgmv_tbl                     IN  cgmv_tbl_type);

  PROCEDURE update_cntx_grp_prmtrs(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgmv_rec                     IN  cgmv_rec_type,
    x_cgmv_rec                     OUT NOCOPY cgmv_rec_type);

  PROCEDURE update_cntx_grp_prmtrs(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgmv_tbl                     IN  cgmv_tbl_type,
    x_cgmv_tbl                     OUT NOCOPY cgmv_tbl_type);

  PROCEDURE delete_cntx_grp_prmtrs(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgmv_rec                     IN  cgmv_rec_type);

  PROCEDURE delete_cntx_grp_prmtrs(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgmv_tbl                     IN  cgmv_tbl_type);

  PROCEDURE validate_cntx_grp_prmtrs(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgmv_rec                     IN  cgmv_rec_type);

  PROCEDURE validate_cntx_grp_prmtrs(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgmv_tbl                     IN  cgmv_tbl_type);

END OKL_CNTX_GRP_PRMTRS_PUB;

 

/
