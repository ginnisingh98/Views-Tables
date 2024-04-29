--------------------------------------------------------
--  DDL for Package OKC_K_HISTORY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_K_HISTORY_PUB" AUTHID CURRENT_USER AS
/* $Header: OKCPHSTS.pls 120.0 2005/05/25 19:43:11 appldev noship $ */

  subtype hstv_rec_type is okc_k_history_pvt.hstv_rec_type;
  subtype hstv_tbl_type is okc_k_history_pvt.hstv_tbl_type;


  -- Global variables for user hooks
  g_pkg_name        CONSTANT  VARCHAR2(200)  := 'OKC_K_HISTORY_PUB';
  g_app_name        CONSTANT  VARCHAR2(3)    := OKC_API.G_APP_NAME;

  g_hstv_rec        hstv_rec_type;
  g_hstv_tbl        hstv_tbl_type;


  PROCEDURE create_k_history(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_rec                     IN  hstv_rec_type,
    x_hstv_rec                     OUT NOCOPY  hstv_rec_type);

  PROCEDURE create_k_history(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_tbl                     IN hstv_tbl_type,
    x_hstv_tbl                     OUT NOCOPY hstv_tbl_type);

  PROCEDURE delete_k_history(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_rec                     IN hstv_rec_type);

  PROCEDURE delete_k_history(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_tbl                     IN hstv_tbl_type);

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
    p_hstv_rec                     IN hstv_rec_type);

  PROCEDURE validate_k_history(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_tbl                     IN hstv_tbl_type);

  PROCEDURE add_language;

END OKC_K_HISTORY_PUB;

 

/
