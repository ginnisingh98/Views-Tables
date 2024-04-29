--------------------------------------------------------
--  DDL for Package OKL_TRNS_ACC_DSTRS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TRNS_ACC_DSTRS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPTABS.pls 120.2 2007/02/12 13:35:55 zrehman ship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLcode';

  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_TRNS_ACC_DSTRS_PUB';
  -- Added as part of SLA Uptake Bug#5707866 by zrehman on 7-Feb-2006 start
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
    -- Added as part of SLA Uptake Bug#5707866 by zrehman on 7-Feb-2006 end
  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION EXCEPTION;

  SUBTYPE tabv_rec_type IS okl_tab_pvt.tabv_rec_type;
  SUBTYPE tabv_tbl_type IS okl_tab_pvt.tabv_tbl_type;

  PROCEDURE add_language;

  PROCEDURE insert_trns_acc_dstrs(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tabv_rec                     IN  tabv_rec_type,
    x_tabv_rec                     OUT NOCOPY tabv_rec_type);

  PROCEDURE insert_trns_acc_dstrs(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tabv_tbl                     IN  tabv_tbl_type,
    x_tabv_tbl                     OUT NOCOPY tabv_tbl_type);

  PROCEDURE lock_trns_acc_dstrs(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tabv_rec                     IN tabv_rec_type);

  PROCEDURE lock_trns_acc_dstrs(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tabv_tbl                     IN  tabv_tbl_type);

  PROCEDURE update_trns_acc_dstrs(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tabv_rec                     IN  tabv_rec_type,
    x_tabv_rec                     OUT NOCOPY tabv_rec_type);

  PROCEDURE update_trns_acc_dstrs(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tabv_tbl                     IN  tabv_tbl_type,
    x_tabv_tbl                     OUT NOCOPY tabv_tbl_type);

  PROCEDURE delete_trns_acc_dstrs(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tabv_rec                     IN  tabv_rec_type);

  PROCEDURE delete_trns_acc_dstrs(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tabv_tbl                     IN  tabv_tbl_type);

  PROCEDURE validate_trns_acc_dstrs(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tabv_rec                     IN  tabv_rec_type);

  PROCEDURE validate_trns_acc_dstrs(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tabv_tbl                     IN  tabv_tbl_type);

END OKL_TRNS_ACC_DSTRS_PUB;

/
