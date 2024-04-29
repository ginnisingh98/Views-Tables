--------------------------------------------------------
--  DDL for Package OKL_AM_CONSOLIDATED_QTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_CONSOLIDATED_QTE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRCNQS.pls 115.1 2002/12/24 23:17:44 rmunjulu noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_PKG_NAME         CONSTANT VARCHAR2(200) := 'OKL_AM_CONSOLIDATED_QTE_PVT';
  G_APP_NAME         CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_UNEXPECTED_ERROR CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN    CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN    CONSTANT VARCHAR2(200) := 'SQLcode';
  G_REQUIRED_VALUE   CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE	   CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN   CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_YES              CONSTANT VARCHAR2(1)   := 'Y';
  G_NO               CONSTANT VARCHAR2(1)   := 'N';

  G_EXCEPTION_HALT_VALIDATION EXCEPTION;

  SUBTYPE qtev_rec_type IS OKL_TRX_QUOTES_PUB.qtev_rec_type;
  SUBTYPE qtev_tbl_type IS OKL_TRX_QUOTES_PUB.qtev_tbl_type;

  PROCEDURE create_consolidate_quote (
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_qtev_tbl                    IN  qtev_tbl_type,
           x_cons_rec                    OUT NOCOPY qtev_rec_type);

  PROCEDURE update_consolidate_quote (
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_cons_rec                    IN  qtev_rec_type,
           x_cons_rec                    OUT NOCOPY qtev_rec_type,
           x_qtev_tbl                    OUT NOCOPY qtev_tbl_type);


END OKL_AM_CONSOLIDATED_QTE_PVT;

 

/
