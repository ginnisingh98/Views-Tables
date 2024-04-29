--------------------------------------------------------
--  DDL for Package OKL_SETUPTQYVALUES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SETUPTQYVALUES_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPSEVS.pls 115.2 2002/02/06 20:29:38 pkm ship       $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_DATES_MISMATCH	          CONSTANT VARCHAR2(200) := 'OKL_DATES_MISMATCH';
  G_PAST_RECORDS	  		  CONSTANT VARCHAR2(200) := 'OKL_PAST_RECORDS';
  G_START_DATE				  CONSTANT VARCHAR2(200) := 'OKL_START_DATE';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_INVALID_DATES             CONSTANT VARCHAR2(200) := 'OKL_INVALID_DATES';
  G_PARENT_TABLE_TOKEN	      CONSTANT VARCHAR2(100) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN	      CONSTANT VARCHAR2(100) := OKL_API.G_CHILD_TABLE_TOKEN;

  G_APP_NAME	              CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SETUPTQYVALUES_PUB';

  G_EXCEPTION_HALT_PROCESSING EXCEPTION;

  SUBTYPE ptvv_rec_type IS OKL_SETUPTQYVALUES_PVT.ptvv_rec_type;
  SUBTYPE ptvv_tbl_type IS OKL_SETUPTQYVALUES_PVT.ptvv_tbl_type;

  --TEMPLATE QUALITY
  SUBTYPE ptqv_rec_type IS OKL_SETUPTQYVALUES_PVT.ptqv_rec_type;
  SUBTYPE ptqv_tbl_type IS OKL_SETUPTQYVALUES_PVT.ptqv_tbl_type;

  PROCEDURE get_rec (
    p_ptvv_rec			  IN ptvv_rec_type,
	x_return_status		  OUT NOCOPY VARCHAR2,
	x_msg_data			  OUT NOCOPY VARCHAR2,
    x_no_data_found       OUT NOCOPY BOOLEAN,
	x_ptvv_rec			  OUT NOCOPY ptvv_rec_type);

  PROCEDURE insert_tqyvalues(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
	 p_ptqv_rec                     IN  ptqv_rec_type,
     p_ptvv_rec                     IN  ptvv_rec_type,
     x_ptvv_rec                     OUT NOCOPY ptvv_rec_type
     );

  PROCEDURE update_tqyvalues(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
 	 p_ptqv_rec                     IN  ptqv_rec_type,
     p_ptvv_rec                     IN  ptvv_rec_type,
     x_ptvv_rec                     OUT NOCOPY ptvv_rec_type);

END OKL_SETUPTQYVALUES_PUB;

 

/
