--------------------------------------------------------
--  DDL for Package Body OKC_K_HISTORY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_K_HISTORY_PVT" AS
/* $Header: OKCCHSTB.pls 120.0 2005/06/01 22:55:31 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_NO_PARENT_RECORD CONSTANT   VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR CONSTANT   VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_PARENT_TABLE_TOKEN  CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN   CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_SQLERRM_TOKEN        CONSTANT       VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN        CONSTANT       VARCHAR2(200) := 'SQLcode';
  G_TABLE_TOKEN      CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_EXCEPTION_HALT_VALIDATION exception;
  NO_CONTRACT_FOUND exception;
  G_NO_UPDATE_ALLOWED_EXCEPTION exception;
  G_NO_UPDATE_ALLOWED CONSTANT VARCHAR2(200) := 'OKC_NO_UPDATE_ALLOWED';
  G_EXCEPTION_HALT_PROCESS exception;
  ---------------------------------------------------------------------------


  PROCEDURE create_k_history(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_rec                     IN  OKC_HST_PVT.hstv_rec_type,
    x_hstv_rec                     OUT NOCOPY  OKC_HST_PVT.hstv_rec_type) IS

    l_hstv_rec          OKC_HST_PVT.hstv_rec_type := p_hstv_rec;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    OKC_HST_PVT.Insert_Row(
               p_api_version    => p_api_version,
               p_init_msg_list  => p_init_msg_list,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_hstv_rec          => l_hstv_rec,
            x_hstv_rec          => x_hstv_rec);

  END create_k_history;

  PROCEDURE create_k_history(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_tbl                     IN  OKC_HST_PVT.hstv_tbl_type,
    x_hstv_tbl                     OUT NOCOPY  OKC_HST_PVT.hstv_tbl_type) IS

  BEGIN
    OKC_HST_PVT.Insert_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_hstv_tbl                => p_hstv_tbl,
      x_hstv_tbl                => x_hstv_tbl);
  END create_k_history;


  PROCEDURE delete_k_history(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_rec                     IN OKC_HST_PVT.hstv_rec_type) IS

  BEGIN

    OKC_HST_PVT.Delete_Row(
                        p_api_version           => p_api_version,
                        p_init_msg_list => p_init_msg_list,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data,
                p_hstv_rec              => p_hstv_rec);
  exception
    when OTHERS then
          -- store SQL error message on message stack
          OKC_API.SET_MESSAGE(p_app_name                => g_app_name,
                                          p_msg_name            => g_unexpected_error,
                                          p_token1              => g_sqlcode_token,
                                          p_token1_value        => sqlcode,
                                          p_token2              => g_sqlerrm_token,
                                          p_token2_value        => sqlerrm);

           -- notify caller of an UNEXPETED error
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END delete_k_history;

  PROCEDURE delete_k_history(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_tbl                     IN OKC_HST_PVT.hstv_tbl_type) IS

  BEGIN
    OKC_HST_PVT.Delete_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_hstv_tbl                => p_hstv_tbl);
  END delete_k_history;

  PROCEDURE delete_all_rows(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN NUMBER) IS

  BEGIN

    OKC_HST_PVT.Delete_all_rows(
                        p_api_version           => p_api_version,
                        p_init_msg_list => p_init_msg_list,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data,
                p_chr_id              => p_chr_id);
  exception
    when OTHERS then
          -- store SQL error message on message stack
          OKC_API.SET_MESSAGE(p_app_name                => g_app_name,
                                          p_msg_name            => g_unexpected_error,
                                          p_token1              => g_sqlcode_token,
                                          p_token1_value        => sqlcode,
                                          p_token2              => g_sqlerrm_token,
                                          p_token2_value        => sqlerrm);

           -- notify caller of an UNEXPETED error
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END delete_all_rows;

  PROCEDURE validate_k_history(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_rec                     IN OKC_HST_PVT.hstv_rec_type) IS

  BEGIN
    OKC_HST_PVT.Validate_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_hstv_rec                => p_hstv_rec);
  END validate_k_history;

  PROCEDURE validate_k_history(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_tbl                     IN OKC_HST_PVT.hstv_tbl_type) IS

  BEGIN
    OKC_HST_PVT.Validate_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_hstv_tbl                => p_hstv_tbl);
  END validate_k_history;


  PROCEDURE add_language IS
  BEGIN
        OKC_HST_PVT.add_language;
  END add_language;

END OKC_K_HISTORY_PVT;

/
