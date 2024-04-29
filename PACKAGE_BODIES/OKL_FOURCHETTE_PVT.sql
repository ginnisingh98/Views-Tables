--------------------------------------------------------
--  DDL for Package Body OKL_FOURCHETTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_FOURCHETTE_PVT" AS
/* $Header: OKLRFCTB.pls 115.0 2002/07/29 20:53:31 avsingh noship $ */
PROCEDURE create_fourchette(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN NUMBER,
    p_asset_id                     IN NUMBER) IS
Begin
    null;
end create_fourchette;

PROCEDURE update_fourchette(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_asset_id                     IN  NUMBER) IS
Begin
    null;
end update_fourchette;

PROCEDURE validate_fourchette(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_asset_id                     IN  NUMBER) IS
Begin
    null;
end validate_fourchette;

PROCEDURE process_fourchette(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_asset_id                     IN  NUMBER) IS
Begin
    null;
end process_fourchette;

END OKL_FOURCHETTE_PVT;

/
