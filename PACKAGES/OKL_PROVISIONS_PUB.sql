--------------------------------------------------------
--  DDL for Package OKL_PROVISIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PROVISIONS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPPVNS.pls 115.6 2002/02/05 12:08:15 pkm ship       $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLcode';

  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_PROVISIONS_PUB';

  SUBTYPE pvnv_rec_type IS okl_pvn_pvt.pvnv_rec_type;
  SUBTYPE pvnv_tbl_type IS okl_pvn_pvt.pvnv_tbl_type;

  PROCEDURE add_language;

  PROCEDURE insert_provisions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_rec                     IN  pvnv_rec_type,
    x_pvnv_rec                     OUT NOCOPY pvnv_rec_type);

  PROCEDURE insert_provisions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_tbl                     IN  pvnv_tbl_type,
    x_pvnv_tbl                     OUT NOCOPY pvnv_tbl_type);

  PROCEDURE lock_provisions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_rec                     IN pvnv_rec_type);

  PROCEDURE lock_provisions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_tbl                     IN  pvnv_tbl_type);

  PROCEDURE update_provisions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_rec                     IN  pvnv_rec_type,
    x_pvnv_rec                     OUT NOCOPY pvnv_rec_type);

  PROCEDURE update_provisions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_tbl                     IN  pvnv_tbl_type,
    x_pvnv_tbl                     OUT NOCOPY pvnv_tbl_type);

  PROCEDURE delete_provisions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_rec                     IN  pvnv_rec_type);

  PROCEDURE delete_provisions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_tbl                     IN  pvnv_tbl_type);

  PROCEDURE validate_provisions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_rec                     IN  pvnv_rec_type);

  PROCEDURE validate_provisions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_tbl                     IN  pvnv_tbl_type);

END OKL_PROVISIONS_PUB;

 

/
