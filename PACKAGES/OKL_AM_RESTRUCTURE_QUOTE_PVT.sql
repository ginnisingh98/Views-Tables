--------------------------------------------------------
--  DDL for Package OKL_AM_RESTRUCTURE_QUOTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_RESTRUCTURE_QUOTE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRRTQS.pls 115.2 2002/08/16 01:04:58 rdraguil noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_AM_RESTRUCTURE_QUOTE_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';

  G_YES                  CONSTANT VARCHAR2(1)   := 'Y';
  G_NO                   CONSTANT VARCHAR2(1)   := 'N';

  G_EXCEPTION_HALT_VALIDATION EXCEPTION;

  G_OKC_APP_NAME	CONSTANT VARCHAR2(3)	:= OKC_API.G_APP_NAME;
  G_INVALID_VALUE	CONSTANT VARCHAR2(200)	:= OKC_API.G_INVALID_VALUE;
  G_REQUIRED_VALUE	CONSTANT VARCHAR2(200)	:= OKC_API.G_REQUIRED_VALUE;
  G_COL_NAME_TOKEN	CONSTANT VARCHAR2(200)	:= OKC_API.G_COL_NAME_TOKEN;

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  SUBTYPE  quot_rec_type IS OKL_TRX_QUOTES_PUB.qtev_rec_type;
  SUBTYPE  quot_tbl_type IS OKL_TRX_QUOTES_PUB.qtev_tbl_type;

  ---------------------------------------------------------------------------
  -- PROCEDURES
  ---------------------------------------------------------------------------
  PROCEDURE create_restructure_quote(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_quot_rec                      IN quot_rec_type,
    x_quot_rec                      OUT NOCOPY quot_rec_type);

  PROCEDURE create_restructure_quote(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_quot_tbl                      IN quot_tbl_type,
    x_quot_tbl                      OUT NOCOPY quot_tbl_type);

  PROCEDURE update_restructure_quote(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_quot_rec                      IN quot_rec_type,
    x_quot_rec                      OUT NOCOPY quot_rec_type);

  PROCEDURE update_restructure_quote(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_quot_tbl                      IN quot_tbl_type,
    x_quot_tbl                      OUT NOCOPY quot_tbl_type);


END OKL_AM_RESTRUCTURE_QUOTE_PVT;

 

/
