--------------------------------------------------------
--  DDL for Package OKL_SETUPDQUALITYS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SETUPDQUALITYS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSDQS.pls 120.2 2007/03/04 10:05:21 dcshanmu ship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_DATES_MISMATCH	          CONSTANT VARCHAR2(200) := 'OKL_DATES_MISMATCH';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_PAST_RECORDS	          CONSTANT VARCHAR2(200) := 'OKL_PAST_RECORDS';
  G_START_DATE		          CONSTANT VARCHAR2(200) := 'OKL_START_DATE';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_IN_USE                    CONSTANT VARCHAR2(100) := 'OKL_IN_USE';
  G_PARENT_TABLE_TOKEN	      CONSTANT VARCHAR2(100) :=  OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN	      CONSTANT VARCHAR2(100) :=  OKL_API.G_CHILD_TABLE_TOKEN;

  G_APP_NAME	              CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SETUPDQUALITYS_PVT';

  G_EXCEPTION_HALT_PROCESSING EXCEPTION;

  SUBTYPE pdqv_rec_type IS okl_pdt_pqys_pub.pdqv_rec_type;
  SUBTYPE pdqv_tbl_type IS okl_pdt_pqys_pub.pdqv_tbl_type;

  SUBTYPE ptlv_rec_type IS okl_pdt_templates_pub.ptlv_rec_type;
  SUBTYPE ptlv_tbl_type IS okl_pdt_templates_pub.ptlv_tbl_type;

  PROCEDURE get_rec (
    p_pdqv_rec                     IN pdqv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_return_status				   OUT NOCOPY VARCHAR2,
	x_pdqv_rec					   OUT NOCOPY pdqv_rec_type);

  PROCEDURE insert_dqualitys(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptlv_rec                     IN  ptlv_rec_type,
    p_pdqv_rec                     IN  pdqv_rec_type,
    x_pdqv_rec                     OUT NOCOPY pdqv_rec_type);

  PROCEDURE insert_dqualitys(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptlv_rec                     IN  ptlv_rec_type,
    p_pdqv_tbl                     IN  pdqv_tbl_type,
    x_pdqv_tbl                     OUT NOCOPY pdqv_tbl_type);


  PROCEDURE delete_dqualitys(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptlv_rec                     IN  ptlv_rec_type,
    p_pdqv_tbl                     IN  pdqv_tbl_type);

END OKL_SETUPDQUALITYS_PVT;

/
