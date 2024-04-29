--------------------------------------------------------
--  DDL for Package OKL_SETUPPMVALUES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SETUPPMVALUES_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSMVS.pls 120.2 2007/03/04 09:53:24 dcshanmu ship $ */

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
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SETUPPMVALUES_PVT';

  G_EXCEPTION_HALT_PROCESSING EXCEPTION;

  SUBTYPE pmvv_rec_type IS okl_ptq_values_pub.pmvv_rec_type;
  SUBTYPE pmvv_tbl_type IS okl_ptq_values_pub.pmvv_tbl_type;

  SUBTYPE ptlv_rec_type IS okl_pdt_templates_pub.ptlv_rec_type;
  SUBTYPE ptlv_tbl_type IS okl_pdt_templates_pub.ptlv_tbl_type;

  PROCEDURE get_rec (
    p_pmvv_rec                     IN pmvv_rec_type,
    x_return_status				   OUT NOCOPY VARCHAR2,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_pmvv_rec					   OUT NOCOPY pmvv_rec_type);

  PROCEDURE insert_pmvalues(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptlv_rec                     IN  ptlv_rec_type,
    p_pmvv_rec                     IN  pmvv_rec_type,
    x_pmvv_rec                     OUT NOCOPY pmvv_rec_type);

  PROCEDURE insert_pmvalues(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptlv_rec                     IN  ptlv_rec_type,
    p_pmvv_tbl                     IN  pmvv_tbl_type,
    x_pmvv_tbl                     OUT NOCOPY pmvv_tbl_type);

  PROCEDURE delete_pmvalues(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptlv_rec                     IN  ptlv_rec_type,
    p_pmvv_tbl                     IN  pmvv_tbl_type);

END OKL_SETUPPMVALUES_PVT;

/
