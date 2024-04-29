--------------------------------------------------------
--  DDL for Package OKL_SETUPPOVALUES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SETUPPOVALUES_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPSDVS.pls 115.2 2002/02/06 20:29:35 pkm ship       $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_DATES_MISMATCH	          CONSTANT VARCHAR2(200) := 'OKL_DATES_MISMATCH';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_PAST_RECORDS	  		  CONSTANT VARCHAR2(200) := 'OKL_PAST_RECORDS';
  G_START_DATE				  CONSTANT VARCHAR2(200) := 'OKL_START_DATE';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_IN_USE                    CONSTANT VARCHAR2(100) := 'OKL_IN_USE';
  G_PARENT_TABLE_TOKEN		  CONSTANT VARCHAR2(100) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		  CONSTANT VARCHAR2(100) := OKL_API.G_CHILD_TABLE_TOKEN;

  G_APP_NAME	         	  CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SETUPPOVALUES_PUB';

  G_EXCEPTION_HALT_PROCESSING EXCEPTION;

  SUBTYPE povv_rec_type IS OKL_SETUPPOVALUES_PVT.povv_rec_type;
  SUBTYPE povv_tbl_type IS OKL_SETUPPOVALUES_PVT.povv_tbl_type;

  --- PRODUCT
  SUBTYPE pdtv_rec_type IS OKL_SETUPPOVALUES_PVT.pdtv_rec_type;
  SUBTYPE pdtv_tbl_type IS OKL_SETUPPOVALUES_PVT.pdtv_tbl_type;

  --- OPTION
  SUBTYPE optv_rec_type IS OKL_SETUPPOVALUES_PVT.optv_rec_type;
  SUBTYPE optv_tbl_type IS OKL_SETUPPOVALUES_PVT.optv_tbl_type;

  PROCEDURE get_rec (p_povv_rec			  IN povv_rec_type,
			        x_return_status		  OUT NOCOPY VARCHAR2,
					x_msg_data			  OUT NOCOPY VARCHAR2,
    				x_no_data_found       OUT NOCOPY BOOLEAN,
					x_povv_rec			  OUT NOCOPY povv_rec_type);

  PROCEDURE insert_povalues(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdtv_rec                     IN  pdtv_rec_type,
    p_optv_rec                     IN  optv_rec_type,
    p_povv_rec                     IN  povv_rec_type,
    x_povv_rec                     OUT NOCOPY povv_rec_type);

  PROCEDURE delete_povalues(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdtv_rec                     IN  pdtv_rec_type,
    p_optv_rec                     IN  optv_rec_type,
    p_povv_tbl                     IN povv_tbl_type);

END OKL_SETUPPOVALUES_PUB;

 

/
