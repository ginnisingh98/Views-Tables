--------------------------------------------------------
--  DDL for Package OKL_SETUPPSTYPES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SETUPPSTYPES_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPSPSS.pls 115.2 2002/05/15 09:11:32 pkm ship       $ */

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
  G_PARENT_TABLE_TOKEN	      CONSTANT VARCHAR2(100) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN	      CONSTANT VARCHAR2(100) := OKL_API.G_CHILD_TABLE_TOKEN;

  G_APP_NAME	              CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SETUPPSTYPES_PUB';

  G_EXCEPTION_HALT_PROCESSING EXCEPTION;

  -- Product Stream Types
  SUBTYPE psyv_rec_type IS OKL_SETUPPSTYPES_PVT.psyv_rec_type;
  SUBTYPE psyv_tbl_type IS OKL_SETUPPSTYPES_PVT.psyv_tbl_type;

  -- PRODUCT
  SUBTYPE pdtv_rec_type IS OKL_SETUPPSTYPES_PVT.pdtv_rec_type;
  SUBTYPE pdtv_tbl_type IS OKL_SETUPPSTYPES_PVT.pdtv_tbl_type;

  PROCEDURE get_rec (
    p_psyv_rec			  IN psyv_rec_type,
    x_return_status		  OUT NOCOPY VARCHAR2,
	x_msg_data			  OUT NOCOPY VARCHAR2,
    x_no_data_found       OUT NOCOPY BOOLEAN,
	x_psyv_rec			  OUT NOCOPY psyv_rec_type);

  PROCEDURE insert_pstypes(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdtv_rec                     IN  pdtv_rec_type,
    p_psyv_rec                     IN  psyv_rec_type,
    x_psyv_rec                     OUT NOCOPY psyv_rec_type
    );

  PROCEDURE update_pstypes(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdtv_rec                     IN  pdtv_rec_type,
    p_psyv_rec                     IN  psyv_rec_type,
    x_psyv_rec                     OUT NOCOPY psyv_rec_type
    );

END OKL_SETUPPSTYPES_PUB;

 

/
