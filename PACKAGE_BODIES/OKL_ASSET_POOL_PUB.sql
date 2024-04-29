--------------------------------------------------------
--  DDL for Package Body OKL_ASSET_POOL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ASSET_POOL_PUB" AS
/* $Header: OKLPAPLB.pls 115.4 2002/07/29 21:02:42 avsingh noship $ */
PROCEDURE create_asset_pool(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN NUMBER,
    p_asset_id                     IN NUMBER) IS
Begin
    null;
end create_asset_pool;

PROCEDURE update_asset_pool(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN NUMBER,
    p_asset_id                     IN NUMBER) IS
Begin
    null;
end update_asset_pool;

PROCEDURE validate_asset_pool(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN NUMBER,
    p_asset_id                     IN NUMBER) IS
Begin
    null;
end validate_asset_pool;

PROCEDURE process_asset_pool(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN NUMBER,
    p_asset_id                     IN NUMBER) IS
Begin
    null;
end process_asset_pool;

END OKL_ASSET_POOL_PUB;

/
