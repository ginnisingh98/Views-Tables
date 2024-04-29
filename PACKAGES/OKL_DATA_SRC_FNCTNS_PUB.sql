--------------------------------------------------------
--  DDL for Package OKL_DATA_SRC_FNCTNS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_DATA_SRC_FNCTNS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPDSFS.pls 115.6 2002/02/05 12:05:25 pkm ship       $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLcode';

  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_DATA_SRC_FNCTNS_PUB';

  SUBTYPE dsfv_rec_type IS okl_dsf_pvt.dsfv_rec_type;
  SUBTYPE dsfv_tbl_type IS okl_dsf_pvt.dsfv_tbl_type;

  PROCEDURE add_language;

  PROCEDURE insert_data_src_fnctns(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsfv_rec                     IN  dsfv_rec_type,
    x_dsfv_rec                     OUT NOCOPY dsfv_rec_type);

  PROCEDURE insert_data_src_fnctns(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsfv_tbl                     IN  dsfv_tbl_type,
    x_dsfv_tbl                     OUT NOCOPY dsfv_tbl_type);

  PROCEDURE lock_data_src_fnctns(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsfv_rec                     IN dsfv_rec_type);

  PROCEDURE lock_data_src_fnctns(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsfv_tbl                     IN  dsfv_tbl_type);

  PROCEDURE update_data_src_fnctns(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsfv_rec                     IN  dsfv_rec_type,
    x_dsfv_rec                     OUT NOCOPY dsfv_rec_type);

  PROCEDURE update_data_src_fnctns(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsfv_tbl                     IN  dsfv_tbl_type,
    x_dsfv_tbl                     OUT NOCOPY dsfv_tbl_type);

  PROCEDURE delete_data_src_fnctns(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsfv_rec                     IN  dsfv_rec_type);

  PROCEDURE delete_data_src_fnctns(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsfv_tbl                     IN  dsfv_tbl_type);

  PROCEDURE validate_data_src_fnctns(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsfv_rec                     IN  dsfv_rec_type);

  PROCEDURE validate_data_src_fnctns(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsfv_tbl                     IN  dsfv_tbl_type);

END OKL_DATA_SRC_FNCTNS_PUB;

 

/
