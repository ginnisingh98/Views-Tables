--------------------------------------------------------
--  DDL for Package OKL_OVERRIDE_TAX_BASIS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_OVERRIDE_TAX_BASIS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLROTBS.pls 120.0 2005/08/26 19:56:27 sechawla noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  SUBTYPE tbov_rec_type IS OKL_TAX_BASIS_OVERRIDE_PUB.tbov_rec_type;
  SUBTYPE tbov_tbl_type IS OKL_TAX_BASIS_OVERRIDE_PUB.tbov_tbl_type;

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_INVALID_VALUE	 CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN	 CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_UNEXPECTED_ERROR CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN    CONSTANT VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN    CONSTANT VARCHAR2(200) := 'ERROR_CODE';

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME            CONSTANT VARCHAR2(200) := 'OKL_OVERRIDE_TAX_BASIS_PVT';
  G_APP_NAME            CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_APP_NAME_1          CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
  G_RET_STS_UNEXP_ERROR CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR       CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_ERROR;
  G_RET_STS_SUCCESS     CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
  G_API_VERSION         CONSTANT NUMBER        := 1;
  G_MISS_CHAR           CONSTANT VARCHAR2(1)   := OKL_API.G_MISS_CHAR;
  G_MISS_NUM            CONSTANT NUMBER        := OKL_API.G_MISS_NUM;
  G_MISS_DATE           CONSTANT DATE          := OKL_API.G_MISS_DATE;
  G_TRUE                CONSTANT VARCHAR2(1)   := OKL_API.G_TRUE;
  G_FALSE               CONSTANT VARCHAR2(1)   := OKL_API.G_FALSE;

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_UNEXPECTED_ERROR  EXCEPTION;
  G_EXCEPTION_ERROR EXCEPTION;
  G_EXCEPTION_HALT  EXCEPTION;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
  PROCEDURE override_tax_basis(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbov_rec                     IN  tbov_rec_type,
    x_tbov_rec                     OUT NOCOPY tbov_rec_type);


PROCEDURE override_tax_basis(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbov_tbl                     IN  tbov_tbl_type,
    x_tbov_tbl                     OUT NOCOPY tbov_tbl_type);

END OKL_OVERRIDE_TAX_BASIS_PVT;

 

/
