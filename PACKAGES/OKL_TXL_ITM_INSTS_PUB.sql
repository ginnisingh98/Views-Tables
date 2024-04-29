--------------------------------------------------------
--  DDL for Package OKL_TXL_ITM_INSTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TXL_ITM_INSTS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPITIS.pls 115.3 2004/05/08 00:09:19 dedey noship $ */

  subtype iipv_rec_type is okl_txl_itm_insts_pvt.iivv_rec_type;
  subtype iipv_tbl_type is okl_txl_itm_insts_pvt.iivv_tbl_type;


  G_EXCEPTION_HALT_VALIDATION   EXCEPTION;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN		CONSTANT VARCHAR2(200) := 'SQLCODE';
  G_SQLERRM_TOKEN		CONSTANT VARCHAR2(200) := 'SQLERRM';

-- Global variables for user hooks
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_TXL_ITM_INSTS_PUB';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  g_iipv_rec			iipv_rec_type;
  g_iipv_tbl			iipv_tbl_type;


  PROCEDURE create_txl_itm_insts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iipv_rec                     IN iipv_rec_type,
    x_iipv_rec                     OUT NOCOPY iipv_rec_type);

  PROCEDURE create_txl_itm_insts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iipv_tbl                     IN iipv_tbl_type,
    x_iipv_tbl                     OUT NOCOPY iipv_tbl_type);


  PROCEDURE update_txl_itm_insts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iipv_rec                     IN iipv_rec_type,
    x_iipv_rec                     OUT NOCOPY iipv_rec_type);

  PROCEDURE update_txl_itm_insts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iipv_tbl                     IN iipv_tbl_type,
    x_iipv_tbl                     OUT NOCOPY iipv_tbl_type);

  PROCEDURE delete_txl_itm_insts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iipv_rec                     IN iipv_rec_type);

  PROCEDURE delete_txl_itm_insts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iipv_tbl                     IN iipv_tbl_type);

  PROCEDURE lock_txl_itm_insts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iipv_rec                     IN iipv_rec_type);

  procedure lock_txl_itm_insts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iipv_tbl                     IN iipv_tbl_type);

  PROCEDURE validate_txl_itm_insts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iipv_rec                     IN iipv_rec_type);

  procedure validate_txl_itm_insts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iipv_tbl                     IN iipv_tbl_type);

  PROCEDURE reset_item_srl_number(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_chr_id                       IN NUMBER,
     p_asset_line_id                IN NUMBER
   );


END OKL_TXL_ITM_INSTS_PUB;

 

/
