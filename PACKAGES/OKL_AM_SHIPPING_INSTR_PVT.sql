--------------------------------------------------------
--  DDL for Package OKL_AM_SHIPPING_INSTR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_SHIPPING_INSTR_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSHIS.pls 115.4 2002/12/20 19:21:09 gkadarka noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_AM_SHIPPING_INSTR_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_CANNOT_TERM_CNT EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

  SUBTYPE rasv_rec_type IS OKL_RELOCATE_ASSETS_PUB.rasv_rec_type;

  SUBTYPE rasv_tbl_type IS OKL_RELOCATE_ASSETS_PUB.rasv_tbl_type;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
  PROCEDURE create_shipping_instr(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_rasv_rec                      IN rasv_rec_type,
    x_rasv_rec                      OUT NOCOPY rasv_rec_type);

  -- terminates the quote for a input of tbl type
  PROCEDURE create_shipping_instr(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_rasv_tbl                      IN rasv_tbl_type,
    x_rasv_tbl                      OUT NOCOPY rasv_tbl_type);

  PROCEDURE update_shipping_instr(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_rasv_rec                      IN rasv_rec_type,
    x_rasv_rec                      OUT NOCOPY rasv_rec_type);

  -- terminates the quote for a input of tbl type
  PROCEDURE update_shipping_instr(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_rasv_tbl                      IN rasv_tbl_type,
    x_rasv_tbl                      OUT NOCOPY rasv_tbl_type);

  PROCEDURE send_shipping_instr(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_rasv_rec                      IN rasv_rec_type,
    x_rasv_rec                      OUT NOCOPY rasv_rec_type);

  PROCEDURE send_shipping_instr(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_rasv_tbl                      IN rasv_tbl_type,
    x_rasv_tbl                      OUT NOCOPY rasv_tbl_type);

END OKL_AM_SHIPPING_INSTR_PVT;

 

/
