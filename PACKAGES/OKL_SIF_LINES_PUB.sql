--------------------------------------------------------
--  DDL for Package OKL_SIF_LINES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SIF_LINES_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPSILS.pls 115.1 2002/02/05 12:09:14 pkm ship       $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLcode';

  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SIF_LINES_PUB';

  SUBTYPE silv_rec_type IS okl_sil_pvt.silv_rec_type;
  SUBTYPE silv_tbl_type IS okl_sil_pvt.silv_tbl_type;

  PROCEDURE add_language;

  PROCEDURE insert_sif_lines(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_silv_rec                     IN  silv_rec_type,
    x_silv_rec                     OUT NOCOPY silv_rec_type);

  PROCEDURE insert_sif_lines(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_silv_tbl                     IN  silv_tbl_type,
    x_silv_tbl                     OUT NOCOPY silv_tbl_type);

  PROCEDURE lock_sif_lines(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_silv_rec                     IN silv_rec_type);

  PROCEDURE lock_sif_lines(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_silv_tbl                     IN  silv_tbl_type);

  PROCEDURE update_sif_lines(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_silv_rec                     IN  silv_rec_type,
    x_silv_rec                     OUT NOCOPY silv_rec_type);

  PROCEDURE update_sif_lines(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_silv_tbl                     IN  silv_tbl_type,
    x_silv_tbl                     OUT NOCOPY silv_tbl_type);

  PROCEDURE delete_sif_lines(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_silv_rec                     IN  silv_rec_type,
    x_silv_rec                     OUT NOCOPY silv_rec_type);

  PROCEDURE delete_sif_lines(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_silv_tbl                     IN  silv_tbl_type,
    x_silv_tbl                     OUT NOCOPY silv_tbl_type);

  PROCEDURE validate_sif_lines(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_silv_rec                     IN  silv_rec_type,
    x_silv_rec                     OUT NOCOPY silv_rec_type);

  PROCEDURE validate_sif_lines(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_silv_tbl                     IN  silv_tbl_type,
    x_silv_tbl                     OUT NOCOPY silv_tbl_type);

END OKL_SIF_LINES_PUB;

 

/
