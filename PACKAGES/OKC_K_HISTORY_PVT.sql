--------------------------------------------------------
--  DDL for Package OKC_K_HISTORY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_K_HISTORY_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCCHSTS.pls 120.0 2005/05/25 18:34:47 appldev noship $ */

  subtype hstv_rec_type is okc_hst_pvt.hstv_rec_type;
  subtype hstv_tbl_type is okc_hst_pvt.hstv_tbl_type;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKC_K_HISTORY_PVT';
  ---------------------------------------------------------------------------

  PROCEDURE create_k_history(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_rec                     IN  OKC_HST_PVT.hstv_rec_type,
    x_hstv_rec                     OUT NOCOPY  OKC_HST_PVT.hstv_rec_type);

  PROCEDURE create_k_history(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_tbl                     IN OKC_HST_PVT.hstv_tbl_type,
    x_hstv_tbl                     OUT NOCOPY OKC_HST_PVT.hstv_tbl_type);

  PROCEDURE delete_k_history(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_rec                     IN OKC_HST_PVT.hstv_rec_type);

  PROCEDURE delete_k_history(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_tbl                     IN OKC_HST_PVT.hstv_tbl_type);

  PROCEDURE delete_all_rows(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN NUMBER);

  PROCEDURE validate_k_history(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_rec                     IN OKC_HST_PVT.hstv_rec_type);

  PROCEDURE validate_k_history(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_tbl                     IN OKC_HST_PVT.hstv_tbl_type);


  PROCEDURE add_language;

END OKC_K_HISTORY_PVT;

 

/
