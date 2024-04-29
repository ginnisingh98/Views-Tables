--------------------------------------------------------
--  DDL for Package OKL_TXL_ITM_INSTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TXL_ITM_INSTS_PVT" AUTHID CURRENT_USER as
/* $Header: OKLCITIS.pls 115.3 2004/05/08 00:11:22 dedey noship $ */

  subtype iitv_rec_type is okl_iti_pvt.iti_rec_type;
  subtype iitv_tbl_type is okl_iti_pvt.iti_tbl_type;
  subtype iivv_rec_type is okl_iti_pvt.itiv_rec_type;
  subtype iivv_tbl_type is okl_iti_pvt.itiv_tbl_type;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS , VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_TXL_ITM_INSTS_PVT';
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
  PROCEDURE Create_txl_itm_insts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iivv_rec                     IN iivv_rec_type,
    x_iivv_rec                     OUT NOCOPY iivv_rec_type);

  PROCEDURE Create_txl_itm_insts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iivv_tbl                     IN iivv_tbl_type,
    x_iivv_tbl                     OUT NOCOPY iivv_tbl_type);

  PROCEDURE lock_txl_itm_insts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iivv_rec                     IN iivv_rec_type);

  PROCEDURE lock_txl_itm_insts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iivv_tbl                     IN iivv_tbl_type);

  PROCEDURE update_txl_itm_insts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iivv_rec                     IN iivv_rec_type,
    x_iivv_rec                     OUT NOCOPY iivv_rec_type);

  PROCEDURE update_txl_itm_insts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iivv_tbl                     IN iivv_tbl_type,
    x_iivv_tbl                     OUT NOCOPY iivv_tbl_type);

  PROCEDURE delete_txl_itm_insts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iivv_rec                     IN iivv_rec_type);

  PROCEDURE delete_txl_itm_insts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iivv_tbl                     IN iivv_tbl_type);

  PROCEDURE validate_txl_itm_insts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iivv_rec                     IN iivv_rec_type);

  PROCEDURE validate_txl_itm_insts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iivv_tbl                     IN iivv_tbl_type);

   PROCEDURE reset_item_srl_number(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_chr_id                       IN NUMBER,
     p_asset_line_id                IN NUMBER
   );

END OKL_TXL_ITM_INSTS_PVT;

 

/
