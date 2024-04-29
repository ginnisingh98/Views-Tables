--------------------------------------------------------
--  DDL for Package OKL_SETUPFUNCTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SETUPFUNCTIONS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPSDFS.pls 115.1 2002/02/06 20:29:30 pkm ship       $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';

  G_APP_NAME				  CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SETUPFUNCTIONS_PUB';

  SUBTYPE dsfv_rec_type IS okl_setupfunctions_pvt.dsfv_rec_type;
  SUBTYPE dsfv_tbl_type IS okl_setupfunctions_pvt.dsfv_tbl_type;

  PROCEDURE get_rec(
  	p_dsfv_rec					   IN dsfv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
	x_msg_data					   OUT NOCOPY VARCHAR2,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_dsfv_rec					   OUT NOCOPY dsfv_rec_type);

  PROCEDURE insert_functions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsfv_rec                     IN  dsfv_rec_type,
    x_dsfv_rec                     OUT NOCOPY dsfv_rec_type);

  PROCEDURE update_functions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsfv_rec                     IN  dsfv_rec_type,
    x_dsfv_rec                     OUT NOCOPY dsfv_rec_type);

END OKL_SETUPFUNCTIONS_PUB;

 

/
