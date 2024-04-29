--------------------------------------------------------
--  DDL for Package OKL_TXD_ASSETS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TXD_ASSETS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPASDS.pls 115.3 2002/02/04 19:05:49 pkm ship       $ */

  subtype adpv_rec_type is okl_txd_assets_pvt.advv_rec_type;
  subtype adpv_tbl_type is okl_txd_assets_pvt.advv_tbl_type;


  G_EXCEPTION_HALT_VALIDATION   EXCEPTION;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN		CONSTANT VARCHAR2(200) := 'SQLCODE';
  G_SQLERRM_TOKEN		CONSTANT VARCHAR2(200) := 'SQLERRM';

-- Global variables for user hooks
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_TXD_ASSETS_PUB';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  g_adpv_rec			adpv_rec_type;
  g_adpv_tbl			adpv_tbl_type;


  PROCEDURE create_txd_asset_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adpv_rec                     IN adpv_rec_type,
    x_adpv_rec                     OUT NOCOPY adpv_rec_type);

  PROCEDURE create_txd_asset_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adpv_tbl                     IN adpv_tbl_type,
    x_adpv_tbl                     OUT NOCOPY adpv_tbl_type);


  PROCEDURE update_txd_asset_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adpv_rec                     IN adpv_rec_type,
    x_adpv_rec                     OUT NOCOPY adpv_rec_type);

  PROCEDURE update_txd_asset_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adpv_tbl                     IN adpv_tbl_type,
    x_adpv_tbl                     OUT NOCOPY adpv_tbl_type);

  PROCEDURE delete_txd_asset_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adpv_rec                     IN adpv_rec_type);

  PROCEDURE delete_txd_asset_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adpv_tbl                     IN adpv_tbl_type);

  PROCEDURE lock_txd_asset_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adpv_rec                     IN adpv_rec_type);

  procedure lock_txd_asset_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adpv_tbl                     IN adpv_tbl_type);

  PROCEDURE validate_txd_asset_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adpv_rec                     IN adpv_rec_type);

  procedure validate_txd_asset_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adpv_tbl                     IN adpv_tbl_type);


END OKL_TXD_ASSETS_PUB;

 

/
