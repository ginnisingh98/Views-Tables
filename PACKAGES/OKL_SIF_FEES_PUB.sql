--------------------------------------------------------
--  DDL for Package OKL_SIF_FEES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SIF_FEES_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPSFES.pls 120.2 2005/09/09 04:47:39 dkagrawa noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLcode';

  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SIF_FEES_PUB';

  SUBTYPE sfev_rec_type IS okl_sfe_pvt.sfev_rec_type;
  SUBTYPE sfev_tbl_type IS okl_sfe_pvt.sfev_tbl_type;

  PROCEDURE add_language;

  PROCEDURE insert_sif_fees(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sfev_rec                     IN  sfev_rec_type,
    x_sfev_rec                     OUT NOCOPY sfev_rec_type);

  PROCEDURE insert_sif_fees(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sfev_tbl                     IN  sfev_tbl_type,
    x_sfev_tbl                     OUT NOCOPY sfev_tbl_type);

  PROCEDURE lock_sif_fees(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sfev_rec                     IN sfev_rec_type);

  PROCEDURE lock_sif_fees(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sfev_tbl                     IN  sfev_tbl_type);

  PROCEDURE update_sif_fees(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sfev_rec                     IN  sfev_rec_type,
    x_sfev_rec                     OUT NOCOPY sfev_rec_type);

  PROCEDURE update_sif_fees(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sfev_tbl                     IN  sfev_tbl_type,
    x_sfev_tbl                     OUT NOCOPY sfev_tbl_type);

  PROCEDURE delete_sif_fees(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sfev_rec                     IN  sfev_rec_type,
    x_sfev_rec                     OUT NOCOPY sfev_rec_type);

  PROCEDURE delete_sif_fees(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sfev_tbl                     IN  sfev_tbl_type,
    x_sfev_tbl                     OUT NOCOPY sfev_tbl_type);

  PROCEDURE validate_sif_fees(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sfev_rec                     IN  sfev_rec_type,
    x_sfev_rec                     OUT NOCOPY sfev_rec_type);

  PROCEDURE validate_sif_fees(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sfev_tbl                     IN  sfev_tbl_type,
    x_sfev_tbl                     OUT NOCOPY sfev_tbl_type);

END OKL_SIF_FEES_PUB;

 

/
