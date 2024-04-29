--------------------------------------------------------
--  DDL for Package OKL_STREAM_INTERFACES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_STREAM_INTERFACES_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPSIFS.pls 115.1 2002/02/05 12:09:11 pkm ship       $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLcode';

  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_STREAM_INTERFACES_PUB';

  SUBTYPE sifv_rec_type IS okl_sif_pvt.sifv_rec_type;
  SUBTYPE sifv_tbl_type IS okl_sif_pvt.sifv_tbl_type;

  PROCEDURE add_language;

  PROCEDURE insert_stream_interfaces(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sifv_rec                     IN  sifv_rec_type,
    x_sifv_rec                     OUT NOCOPY sifv_rec_type);

  PROCEDURE insert_stream_interfaces(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sifv_tbl                     IN  sifv_tbl_type,
    x_sifv_tbl                     OUT NOCOPY sifv_tbl_type);

  PROCEDURE lock_stream_interfaces(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sifv_rec                     IN sifv_rec_type);

  PROCEDURE lock_stream_interfaces(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sifv_tbl                     IN  sifv_tbl_type);

  PROCEDURE update_stream_interfaces(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sifv_rec                     IN  sifv_rec_type,
    x_sifv_rec                     OUT NOCOPY sifv_rec_type);

  PROCEDURE update_stream_interfaces(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sifv_tbl                     IN  sifv_tbl_type,
    x_sifv_tbl                     OUT NOCOPY sifv_tbl_type);

  PROCEDURE delete_stream_interfaces(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sifv_rec                     IN  sifv_rec_type,
    x_sifv_rec                     OUT NOCOPY sifv_rec_type);

  PROCEDURE delete_stream_interfaces(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sifv_tbl                     IN  sifv_tbl_type,
    x_sifv_tbl                     OUT NOCOPY sifv_tbl_type);

  PROCEDURE validate_stream_interfaces(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sifv_rec                     IN  sifv_rec_type,
    x_sifv_rec                     OUT NOCOPY sifv_rec_type);

  PROCEDURE validate_stream_interfaces(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sifv_tbl                     IN  sifv_tbl_type,
    x_sifv_tbl                     OUT NOCOPY sifv_tbl_type);

END OKL_STREAM_INTERFACES_PUB;

 

/
