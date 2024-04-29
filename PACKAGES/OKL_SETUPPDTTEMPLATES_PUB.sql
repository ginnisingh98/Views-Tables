--------------------------------------------------------
--  DDL for Package OKL_SETUPPDTTEMPLATES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SETUPPDTTEMPLATES_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPSPTS.pls 120.5 2008/02/29 10:14:34 veramach ship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';

  G_APP_NAME				  CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SETUPPDTTEMPLATES_PUB';

  SUBTYPE ptlv_rec_type IS okl_setuppdttemplates_pvt.ptlv_rec_type;
  SUBTYPE ptlv_tbl_type IS okl_setuppdttemplates_pvt.ptlv_tbl_type;

  PROCEDURE get_rec(
  	p_ptlv_rec					   IN ptlv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
	x_msg_data					   OUT NOCOPY VARCHAR2,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_ptlv_rec					   OUT NOCOPY ptlv_rec_type);

  PROCEDURE insert_pdttemplates(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptlv_rec                     IN  ptlv_rec_type,
    x_ptlv_rec                     OUT NOCOPY ptlv_rec_type);

  PROCEDURE update_pdttemplates(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptlv_rec                     IN  ptlv_rec_type,
    x_ptlv_rec                     OUT NOCOPY ptlv_rec_type);

END OKL_SETUPPDTTEMPLATES_PUB;

/
