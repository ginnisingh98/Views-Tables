--------------------------------------------------------
--  DDL for Package OKL_AM_REPURCHASE_ASSET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_REPURCHASE_ASSET_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRRQUS.pls 115.2 2002/08/21 18:17:28 rmunjulu noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_AM_REPURCHASE_ASSET_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';
  G_FALSE                CONSTANT VARCHAR2(1)   :=  OKL_API.G_FALSE;
  G_TRUE                 CONSTANT VARCHAR2(1)   :=  OKL_API.G_TRUE;
  G_INVALID_VALUE        CONSTANT VARCHAR2(200) :=  OKC_API.G_INVALID_VALUE;
  G_REQUIRED_VALUE       CONSTANT VARCHAR2(200) :=  OKC_API.G_REQUIRED_VALUE;
  G_COL_NAME_TOKEN       CONSTANT VARCHAR2(200) :=  OKC_API.G_COL_NAME_TOKEN;
  G_MAX_DATE_TOKEN       CONSTANT VARCHAR2(200) := 'DATE_EFF_TO_MAX';
  G_QUOTE_NUMBER_TOKEN   CONSTANT VARCHAR2(200) := 'QUOTE_NUMBER';
  G_YES		         CONSTANT VARCHAR2(1)   := 'Y';
  G_NO		         CONSTANT VARCHAR2(1)   := 'N';

  G_EXCEPTION_HALT_VALIDATION EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

  SUBTYPE  qtev_rec_type IS okl_trx_quotes_pub.qtev_rec_type;
  SUBTYPE  tqlv_tbl_type IS okl_txl_quote_lines_pub.tqlv_tbl_type;

  ---------------------------------------------------------------------------
  -- PROCEDURES
  ---------------------------------------------------------------------------

  PROCEDURE create_repurchase_quote(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qtev_rec                     IN qtev_rec_type,
    p_tqlv_tbl                     IN tqlv_tbl_type,
    x_qtev_rec                     OUT NOCOPY qtev_rec_type,
    x_tqlv_tbl                     OUT NOCOPY tqlv_tbl_type);

  PROCEDURE update_repurchase_quote(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qtev_rec                     IN qtev_rec_type,
    p_tqlv_tbl                     IN tqlv_tbl_type,
    x_qtev_rec                     OUT NOCOPY qtev_rec_type,
    x_tqlv_tbl                     OUT NOCOPY tqlv_tbl_type);

END OKL_AM_REPURCHASE_ASSET_PVT;

 

/
