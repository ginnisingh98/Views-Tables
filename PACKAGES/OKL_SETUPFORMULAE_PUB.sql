--------------------------------------------------------
--  DDL for Package OKL_SETUPFORMULAE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SETUPFORMULAE_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPSFMS.pls 115.1 2002/02/06 20:29:44 pkm ship       $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';

  G_APP_NAME				  CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SETUPFORMULAE_PUB';

  SUBTYPE fmav_rec_type IS okl_setupformulae_pvt.fmav_rec_type;
  SUBTYPE fmav_tbl_type IS okl_setupformulae_pvt.fmav_tbl_type;

  PROCEDURE get_rec(
  	p_fmav_rec					   IN fmav_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
	x_msg_data					   OUT NOCOPY VARCHAR2,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_fmav_rec					   OUT NOCOPY fmav_rec_type);

  PROCEDURE insert_formulae(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fmav_rec                     IN  fmav_rec_type,
    x_fmav_rec                     OUT NOCOPY fmav_rec_type);

  PROCEDURE update_formulae(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fmav_rec                     IN  fmav_rec_type,
    x_fmav_rec                     OUT NOCOPY fmav_rec_type);

END OKL_SETUPFORMULAE_PUB;

 

/
