--------------------------------------------------------
--  DDL for Package OKL_TXL_ASSETS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TXL_ASSETS_PVT" AUTHID CURRENT_USER as
/* $Header: OKLCTALS.pls 120.2 2005/10/30 04:04:35 appldev noship $ */

  subtype tltv_rec_type is okl_tal_pvt.tal_rec_type;
  subtype tltv_tbl_type is okl_tal_pvt.tal_tbl_type;
  subtype tlvv_rec_type is okl_tal_pvt.talv_rec_type;
  subtype tlvv_tbl_type is okl_tal_pvt.talv_tbl_type;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS , VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_TXL_ASSETS_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'SQLcode';

 ----------------------------------------------------------------------------------
  --Global Exception
 ----------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ----------------------------------------------------------------------------------
  --Public Procedures and Functions
 ----------------------------------------------------------------------------------
--  PROCEDURE add_language;
  PROCEDURE Create_txl_asset_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_rec                     IN tlvv_rec_type,
    x_talv_rec                     OUT NOCOPY tlvv_rec_type);

  PROCEDURE Create_txl_asset_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_tbl                     IN tlvv_tbl_type,
    x_talv_tbl                     OUT NOCOPY tlvv_tbl_type);

  PROCEDURE lock_txl_asset_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_rec                     IN tlvv_rec_type);

  PROCEDURE lock_txl_asset_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_tbl                     IN tlvv_tbl_type);

  PROCEDURE update_txl_asset_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_rec                     IN tlvv_rec_type,
    x_talv_rec                     OUT NOCOPY tlvv_rec_type);

  PROCEDURE update_txl_asset_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_tbl                     IN tlvv_tbl_type,
    x_talv_tbl                     OUT NOCOPY tlvv_tbl_type);

  PROCEDURE delete_txl_asset_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_rec                     IN tlvv_rec_type);

  PROCEDURE delete_txl_asset_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_tbl                     IN tlvv_tbl_type);

  PROCEDURE validate_txl_asset_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_rec                     IN tlvv_rec_type);

  PROCEDURE validate_txl_asset_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_tbl                     IN tlvv_tbl_type);

END OKL_TXL_ASSETS_PVT;

 

/
