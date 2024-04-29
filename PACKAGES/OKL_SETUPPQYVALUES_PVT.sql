--------------------------------------------------------
--  DDL for Package OKL_SETUPPQYVALUES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SETUPPQYVALUES_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSQVS.pls 115.3 2002/02/06 20:34:04 pkm ship       $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_DATES_MISMATCH	          CONSTANT VARCHAR2(200) := 'OKL_DATES_MISMATCH';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_PAST_RECORDS	  		  CONSTANT VARCHAR2(200) := 'OKL_PAST_RECORDS';
  G_START_DATE				  CONSTANT VARCHAR2(200) := 'OKL_START_DATE';
  G_INVALID_DATES             CONSTANT VARCHAR2(200) := 'OKL_INVALID_DATES';
  G_NOT_ALLOWED               CONSTANT VARCHAR2(200) := 'OKL_NOT_ALLOWED';
  G_COL_NAME_TOKEN			  CONSTANT VARCHAR2(100) := OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN	      CONSTANT VARCHAR2(100) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN	      CONSTANT VARCHAR2(100) := OKL_API.G_CHILD_TABLE_TOKEN;

  G_APP_NAME	              CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SETUPPQYVALUES_PVT';

  G_EXCEPTION_HALT_PROCESSING EXCEPTION;

  SUBTYPE qvev_rec_type IS okl_pdt_qualitys_pub.qvev_rec_type;
  SUBTYPE qvev_tbl_type IS okl_pdt_qualitys_pub.qvev_tbl_type;

  SUBTYPE pqyv_rec_type IS okl_pdt_qualitys_pub.pqyv_rec_type;
  SUBTYPE pqyv_tbl_type IS okl_pdt_qualitys_pub.pqyv_tbl_type;

 PROCEDURE get_rec (
    p_qvev_rec                     IN qvev_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_return_status				   OUT NOCOPY VARCHAR2,
	x_qvev_rec					   OUT NOCOPY qvev_rec_type);

 PROCEDURE insert_pqyvalues(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pqyv_rec                     IN  pqyv_rec_type,
    p_qvev_rec                     IN  qvev_rec_type,
    x_qvev_rec                     OUT NOCOPY qvev_rec_type);

  PROCEDURE update_pqyvalues(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pqyv_rec                     IN  pqyv_rec_type,
     p_qvev_rec                     IN  qvev_rec_type,
     x_qvev_rec                     OUT NOCOPY qvev_rec_type);

END OKL_SETUPPQYVALUES_PVT;

 

/
