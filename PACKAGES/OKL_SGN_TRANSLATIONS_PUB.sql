--------------------------------------------------------
--  DDL for Package OKL_SGN_TRANSLATIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SGN_TRANSLATIONS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPSGTS.pls 115.2 2002/07/22 23:38:49 smahapat noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLcode';

  G_APP_NAME                  CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SGN_TRANSLATIONS_PUB';

  SUBTYPE sgnv_rec_type IS okl_sgt_pvt.sgnv_rec_type;
  SUBTYPE sgnv_tbl_type IS okl_sgt_pvt.sgnv_tbl_type;

  PROCEDURE add_language;

  PROCEDURE insert_sgn_translations(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgnv_rec                     IN  sgnv_rec_type,
    x_sgnv_rec                     OUT NOCOPY sgnv_rec_type);

  PROCEDURE insert_sgn_translations(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgnv_tbl                     IN  sgnv_tbl_type,
    x_sgnv_tbl                     OUT NOCOPY sgnv_tbl_type);

  PROCEDURE lock_sgn_translations(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgnv_rec                     IN sgnv_rec_type);

  PROCEDURE lock_sgn_translations(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgnv_tbl                     IN  sgnv_tbl_type);

  PROCEDURE update_sgn_translations(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgnv_rec                     IN  sgnv_rec_type,
    x_sgnv_rec                     OUT NOCOPY sgnv_rec_type);

  PROCEDURE update_sgn_translations(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgnv_tbl                     IN  sgnv_tbl_type,
    x_sgnv_tbl                     OUT NOCOPY sgnv_tbl_type);

  PROCEDURE delete_sgn_translations(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgnv_rec                     IN  sgnv_rec_type);

  PROCEDURE delete_sgn_translations(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgnv_tbl                     IN  sgnv_tbl_type);

  PROCEDURE validate_sgn_translations(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgnv_rec                     IN  sgnv_rec_type,
    x_sgnv_rec                     OUT NOCOPY sgnv_rec_type);

  PROCEDURE validate_sgn_translations(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgnv_tbl                     IN  sgnv_tbl_type,
    x_sgnv_tbl                     OUT NOCOPY sgnv_tbl_type);

END OKL_SGN_TRANSLATIONS_PUB;

 

/
