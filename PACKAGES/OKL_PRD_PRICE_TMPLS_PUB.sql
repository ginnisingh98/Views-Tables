--------------------------------------------------------
--  DDL for Package OKL_PRD_PRICE_TMPLS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PRD_PRICE_TMPLS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPPITS.pls 115.6 2002/02/05 12:07:40 pkm ship       $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLcode';

  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_PRD_PRICE_TMPLS_PUB';

  SUBTYPE pitv_rec_type IS okl_pit_pvt.pitv_rec_type;
  SUBTYPE pitv_tbl_type IS okl_pit_pvt.pitv_tbl_type;

  PROCEDURE add_language;

  PROCEDURE insert_prd_price_tmpls(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pitv_rec                     IN  pitv_rec_type,
    x_pitv_rec                     OUT NOCOPY pitv_rec_type);

  PROCEDURE insert_prd_price_tmpls(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pitv_tbl                     IN  pitv_tbl_type,
    x_pitv_tbl                     OUT NOCOPY pitv_tbl_type);

  PROCEDURE lock_prd_price_tmpls(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pitv_rec                     IN pitv_rec_type);

  PROCEDURE lock_prd_price_tmpls(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pitv_tbl                     IN  pitv_tbl_type);

  PROCEDURE update_prd_price_tmpls(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pitv_rec                     IN  pitv_rec_type,
    x_pitv_rec                     OUT NOCOPY pitv_rec_type);

  PROCEDURE update_prd_price_tmpls(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pitv_tbl                     IN  pitv_tbl_type,
    x_pitv_tbl                     OUT NOCOPY pitv_tbl_type);

  PROCEDURE delete_prd_price_tmpls(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pitv_rec                     IN  pitv_rec_type);

  PROCEDURE delete_prd_price_tmpls(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pitv_tbl                     IN  pitv_tbl_type);

  PROCEDURE validate_prd_price_tmpls(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pitv_rec                     IN  pitv_rec_type);

  PROCEDURE validate_prd_price_tmpls(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pitv_tbl                     IN  pitv_tbl_type);

END OKL_PRD_PRICE_TMPLS_PUB;

 

/
