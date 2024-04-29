--------------------------------------------------------
--  DDL for Package OKL_SIF_STREAM_TYPES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SIF_STREAM_TYPES_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPSITS.pls 120.2 2005/09/13 12:23:30 asawanka noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLcode';

  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SIF_stream_types_PUB';

  SUBTYPE sitv_rec_type IS okl_sit_pvt.sitv_rec_type;
  SUBTYPE sitv_tbl_type IS okl_sit_pvt.sitv_tbl_type;

  PROCEDURE add_language;

  PROCEDURE insert_sif_stream_types(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sitv_rec                     IN  sitv_rec_type,
    x_sitv_rec                     OUT NOCOPY sitv_rec_type);

  PROCEDURE insert_sif_stream_types(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sitv_tbl                     IN  sitv_tbl_type,
    x_sitv_tbl                     OUT NOCOPY sitv_tbl_type);

  PROCEDURE lock_sif_stream_types(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sitv_rec                     IN sitv_rec_type);

  PROCEDURE lock_sif_stream_types(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sitv_tbl                     IN  sitv_tbl_type);

  PROCEDURE update_sif_stream_types(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sitv_rec                     IN  sitv_rec_type,
    x_sitv_rec                     OUT NOCOPY sitv_rec_type);

  PROCEDURE update_sif_stream_types(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sitv_tbl                     IN  sitv_tbl_type,
    x_sitv_tbl                     OUT NOCOPY sitv_tbl_type);

  PROCEDURE delete_sif_stream_types(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sitv_rec                     IN  sitv_rec_type,
    x_sitv_rec                     OUT NOCOPY sitv_rec_type);

  PROCEDURE delete_sif_stream_types(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sitv_tbl                     IN  sitv_tbl_type,
    x_sitv_tbl                     OUT NOCOPY sitv_tbl_type);

  PROCEDURE validate_sif_stream_types(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sitv_rec                     IN  sitv_rec_type,
    x_sitv_rec                     OUT NOCOPY sitv_rec_type);

  PROCEDURE validate_sif_stream_types(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sitv_tbl                     IN  sitv_tbl_type,
    x_sitv_tbl                     OUT NOCOPY sitv_tbl_type);

END OKL_SIF_STREAM_TYPES_PUB;

 

/
