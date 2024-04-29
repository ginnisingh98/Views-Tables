--------------------------------------------------------
--  DDL for Package OKL_SIF_YIELDS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SIF_YIELDS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPSIYS.pls 120.2 2005/09/13 12:23:53 asawanka noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLcode';

  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SIF_YIELDS_PUB';

  SUBTYPE siyv_rec_type IS okl_siy_pvt.siyv_rec_type;
  SUBTYPE siyv_tbl_type IS okl_siy_pvt.siyv_tbl_type;

  PROCEDURE add_language;

  PROCEDURE insert_sif_yields(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_siyv_rec                     IN  siyv_rec_type,
    x_siyv_rec                     OUT NOCOPY siyv_rec_type);

  PROCEDURE insert_sif_yields(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_siyv_tbl                     IN  siyv_tbl_type,
    x_siyv_tbl                     OUT NOCOPY siyv_tbl_type);

  PROCEDURE lock_sif_yields(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_siyv_rec                     IN siyv_rec_type);

  PROCEDURE lock_sif_yields(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_siyv_tbl                     IN  siyv_tbl_type);

  PROCEDURE update_sif_yields(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_siyv_rec                     IN  siyv_rec_type,
    x_siyv_rec                     OUT NOCOPY siyv_rec_type);

  PROCEDURE update_sif_yields(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_siyv_tbl                     IN  siyv_tbl_type,
    x_siyv_tbl                     OUT NOCOPY siyv_tbl_type);

  PROCEDURE delete_sif_yields(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_siyv_rec                     IN  siyv_rec_type,
    x_siyv_rec                     OUT NOCOPY siyv_rec_type);

  PROCEDURE delete_sif_yields(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_siyv_tbl                     IN  siyv_tbl_type,
    x_siyv_tbl                     OUT NOCOPY siyv_tbl_type);

  PROCEDURE validate_sif_yields(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_siyv_rec                     IN  siyv_rec_type,
    x_siyv_rec                     OUT NOCOPY siyv_rec_type);

  PROCEDURE validate_sif_yields(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_siyv_tbl                     IN  siyv_tbl_type,
    x_siyv_tbl                     OUT NOCOPY siyv_tbl_type);

END OKL_SIF_YIELDS_PUB;

 

/
