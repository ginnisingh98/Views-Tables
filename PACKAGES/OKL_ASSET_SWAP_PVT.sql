--------------------------------------------------------
--  DDL for Package OKL_ASSET_SWAP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ASSET_SWAP_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRASPS.pls 115.0 2002/07/29 20:53:29 avsingh noship $ */
  PROCEDURE create_asset_swap(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id_1                     IN NUMBER,
    p_chr_id_2                     IN NUMBER,
    p_asset_id_1                   IN NUMBER,
    p_asset_id_2                   IN NUMBER);

  PROCEDURE update_asset_swap(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id_1                     IN NUMBER,
    p_chr_id_2                     IN NUMBER,
    p_asset_id_1                   IN NUMBER,
    p_asset_id_2                   IN NUMBER);

  PROCEDURE validate_asset_swap(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id_1                     IN NUMBER,
    p_chr_id_2                     IN NUMBER,
    p_asset_id_1                   IN NUMBER,
    p_asset_id_2                   IN NUMBER);

  PROCEDURE process_asset_swap(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id_1                     IN NUMBER,
    p_chr_id_2                     IN NUMBER,
    p_asset_id_1                   IN NUMBER,
    p_asset_id_2                   IN NUMBER);

END OKL_ASSET_SWAP_PVT;

 

/
