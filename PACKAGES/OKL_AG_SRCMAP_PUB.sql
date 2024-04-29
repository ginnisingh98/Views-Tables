--------------------------------------------------------
--  DDL for Package OKL_AG_SRCMAP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AG_SRCMAP_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPALSS.pls 115.0 2002/02/25 17:04:47 pkm ship      $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';

  G_APP_NAME			CONSTANT VARCHAR2(3) :=  OKC_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_AG_SRCMAP_PUB';

  SUBTYPE alsv_rec_type IS okl_als_pvt.alsv_rec_type;
  SUBTYPE alsv_tbl_type IS okl_als_pvt.alsv_tbl_type;

  PROCEDURE add_language;

  PROCEDURE insert_acc_gen_src_map(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_alsv_rec                     IN  alsv_rec_type,
    x_alsv_rec                     OUT NOCOPY alsv_rec_type);

  PROCEDURE insert_acc_gen_src_map(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_alsv_tbl                     IN  alsv_tbl_type,
    x_alsv_tbl                     OUT NOCOPY alsv_tbl_type);

  PROCEDURE lock_acc_gen_src_map(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_alsv_rec                     IN alsv_rec_type);

  PROCEDURE lock_acc_gen_src_map(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_alsv_tbl                     IN  alsv_tbl_type);

  PROCEDURE update_acc_gen_src_map(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_alsv_rec                     IN  alsv_rec_type,
    x_alsv_rec                     OUT NOCOPY alsv_rec_type);

  PROCEDURE update_acc_gen_src_map(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_alsv_tbl                     IN  alsv_tbl_type,
    x_alsv_tbl                     OUT NOCOPY alsv_tbl_type);

  PROCEDURE delete_acc_gen_src_map(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_alsv_rec                     IN  alsv_rec_type);

  PROCEDURE delete_acc_gen_src_map(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_alsv_tbl                     IN  alsv_tbl_type);

  PROCEDURE validate_acc_gen_src_map(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_alsv_rec                     IN  alsv_rec_type);

  PROCEDURE validate_acc_gen_src_map(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_alsv_tbl                     IN  alsv_tbl_type);

END OKL_AG_SRCMAP_PUB;

 

/
