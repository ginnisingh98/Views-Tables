--------------------------------------------------------
--  DDL for Package OKL_ARTICLE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ARTICLE_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPKATS.pls 115.2 2002/03/24 23:21:45 pkm ship        $ */

  -------------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_ARTICLE_PUB';
  G_APP_NAME			CONSTANT VARCHAR2(3)   := 'OKL';
  ---------------------------------------------------------------------------


  PROCEDURE reference_article(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sae_id			     IN  NUMBER,
    p_sae_release			     IN  VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_cle_id                       IN  NUMBER DEFAULT NULL,
    x_cat_id                       OUT NOCOPY NUMBER
  );


  PROCEDURE copy_article(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sae_id			     IN  NUMBER,
    p_sae_release			     IN  VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_cle_id                       IN  NUMBER DEFAULT NULL,
    x_cat_id                       OUT NOCOPY NUMBER
  );

  PROCEDURE delete_article(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cat_id			     IN  NUMBER
  );

END OKL_ARTICLE_PUB;

 

/
