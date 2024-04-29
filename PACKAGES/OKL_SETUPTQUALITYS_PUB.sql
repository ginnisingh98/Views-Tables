--------------------------------------------------------
--  DDL for Package OKL_SETUPTQUALITYS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SETUPTQUALITYS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPSTQS.pls 115.2 2002/02/06 20:30:26 pkm ship       $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_DATES_MISMATCH	      CONSTANT VARCHAR2(200) := 'OKL_DATES_MISMATCH';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_PAST_RECORDS	      CONSTANT VARCHAR2(200) := 'OKL_PAST_RECORDS';
  G_START_DATE		      CONSTANT VARCHAR2(200) := 'OKL_START_DATE';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_INVALID_DATES             CONSTANT VARCHAR2(200) := 'OKL_INVALID_DATES';
  G_PARENT_TABLE_TOKEN	      CONSTANT VARCHAR2(100) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN	      CONSTANT VARCHAR2(100) := OKL_API.G_CHILD_TABLE_TOKEN;

  G_APP_NAME	              CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SETUPTQUALITYS_PVT';

  G_EXCEPTION_HALT_PROCESSING EXCEPTION;

  SUBTYPE ptqv_rec_type IS OKL_SETUPTQUALITYS_PVT.ptqv_rec_type;
  SUBTYPE ptqv_tbl_type IS OKL_SETUPTQUALITYS_PVT.ptqv_tbl_type;

  PROCEDURE get_rec (
    p_ptqv_rec			  IN ptqv_rec_type,
    x_return_status		  OUT NOCOPY VARCHAR2,
    x_msg_data			  OUT NOCOPY VARCHAR2,
    x_no_data_found        OUT NOCOPY BOOLEAN,
    x_ptqv_rec			  OUT NOCOPY ptqv_rec_type);

  PROCEDURE insert_tqualitys(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptqv_rec                     IN  ptqv_rec_type,
    x_ptqv_rec                     OUT NOCOPY ptqv_rec_type
    );

  PROCEDURE update_tqualitys(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptqv_rec                     IN  ptqv_rec_type,
    x_ptqv_rec                     OUT NOCOPY ptqv_rec_type);

END OKL_SETUPTQUALITYS_PUB;

 

/
