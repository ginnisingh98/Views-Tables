--------------------------------------------------------
--  DDL for Package OKL_SIF_RET_LEVELS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SIF_RET_LEVELS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPSRLS.pls 115.2 2002/06/14 17:01:02 pkm ship        $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLcode';

  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SIF_RET_LEVELS_PUB';

 SUBTYPE srlv_rec_type IS Okl_srl_Pvt.okl_sif_ret_levels_v_rec_type;
 SUBTYPE srlv_tbl_type IS Okl_srl_Pvt.okl_sif_ret_levels_v_tbl_type;

  PROCEDURE add_language;

  PROCEDURE insert_sif_ret_levels(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srlv_rec                     IN  srlv_rec_type,
    x_srlv_rec                     OUT NOCOPY srlv_rec_type);

  PROCEDURE insert_sif_ret_levels(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srlv_tbl                     IN  srlv_tbl_type,
    x_srlv_tbl                     OUT NOCOPY srlv_tbl_type);

  PROCEDURE lock_sif_ret_levels(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srlv_rec                     IN srlv_rec_type);

  PROCEDURE lock_sif_ret_levels(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srlv_tbl                     IN  srlv_tbl_type);

  PROCEDURE update_sif_ret_levels(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srlv_rec                     IN  srlv_rec_type,
    x_srlv_rec                     OUT NOCOPY srlv_rec_type);

  PROCEDURE update_sif_ret_levels(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srlv_tbl                     IN  srlv_tbl_type,
    x_srlv_tbl                     OUT NOCOPY srlv_tbl_type);

  PROCEDURE delete_sif_ret_levels(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srlv_rec                     IN  srlv_rec_type,
    x_srlv_rec                     OUT NOCOPY srlv_rec_type);

  PROCEDURE delete_sif_ret_levels(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srlv_tbl                     IN  srlv_tbl_type,
    x_srlv_tbl                     OUT NOCOPY srlv_tbl_type);

  PROCEDURE validate_sif_ret_levels(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srlv_rec                     IN  srlv_rec_type,
    x_srlv_rec                     OUT NOCOPY srlv_rec_type);

  PROCEDURE validate_sif_ret_levels(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srlv_tbl                     IN  srlv_tbl_type,
    x_srlv_tbl                     OUT NOCOPY srlv_tbl_type);

END OKL_SIF_RET_LEVELS_PUB;

 

/
