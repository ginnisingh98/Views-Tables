--------------------------------------------------------
--  DDL for Package OKL_OVD_RUL_TMLS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_OVD_RUL_TMLS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPOVTS.pls 115.6 2002/02/05 12:07:22 pkm ship       $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLcode';

  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_OVD_RUL_TMLS_PUB';

  SUBTYPE ovtv_rec_type IS okl_ovt_pvt.ovtv_rec_type;
  SUBTYPE ovtv_tbl_type IS okl_ovt_pvt.ovtv_tbl_type;

  PROCEDURE add_language;

  PROCEDURE insert_ovd_rul_tmls(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovtv_rec                     IN  ovtv_rec_type,
    x_ovtv_rec                     OUT NOCOPY ovtv_rec_type);

  PROCEDURE insert_ovd_rul_tmls(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovtv_tbl                     IN  ovtv_tbl_type,
    x_ovtv_tbl                     OUT NOCOPY ovtv_tbl_type);

  PROCEDURE lock_ovd_rul_tmls(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovtv_rec                     IN ovtv_rec_type);

  PROCEDURE lock_ovd_rul_tmls(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovtv_tbl                     IN  ovtv_tbl_type);

  PROCEDURE update_ovd_rul_tmls(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovtv_rec                     IN  ovtv_rec_type,
    x_ovtv_rec                     OUT NOCOPY ovtv_rec_type);

  PROCEDURE update_ovd_rul_tmls(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovtv_tbl                     IN  ovtv_tbl_type,
    x_ovtv_tbl                     OUT NOCOPY ovtv_tbl_type);

  PROCEDURE delete_ovd_rul_tmls(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovtv_rec                     IN  ovtv_rec_type);

  PROCEDURE delete_ovd_rul_tmls(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovtv_tbl                     IN  ovtv_tbl_type);

  PROCEDURE validate_ovd_rul_tmls(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovtv_rec                     IN  ovtv_rec_type);

  PROCEDURE validate_ovd_rul_tmls(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovtv_tbl                     IN  ovtv_tbl_type);

END OKL_OVD_RUL_TMLS_PUB;

 

/
