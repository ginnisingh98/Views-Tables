--------------------------------------------------------
--  DDL for Package OKL_SETUPOPTRULES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SETUPOPTRULES_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPSORS.pls 115.1 2002/02/06 20:30:02 pkm ship       $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';

  G_APP_NAME				  CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SETUPOPTRULES_PUB';

  SUBTYPE optv_rec_type IS okl_setupoptrules_pvt.optv_rec_type;
  SUBTYPE optv_tbl_type IS okl_setupoptrules_pvt.optv_tbl_type;
  SUBTYPE orlv_rec_type IS okl_setupoptrules_pvt.orlv_rec_type;
  SUBTYPE orlv_tbl_type IS okl_setupoptrules_pvt.orlv_tbl_type;

  PROCEDURE get_rec(
  	p_orlv_rec					   IN orlv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
	x_msg_data					   OUT NOCOPY VARCHAR2,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_orlv_rec					   OUT NOCOPY orlv_rec_type);

  PROCEDURE insert_optrules(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_optv_rec                     IN  optv_rec_type,
    p_orlv_rec                     IN  orlv_rec_type,
    x_orlv_rec                     OUT NOCOPY orlv_rec_type);

  PROCEDURE delete_optrules(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_optv_rec                     IN  optv_rec_type,
    p_orlv_tbl                     IN  orlv_tbl_type);

END OKL_SETUPOPTRULES_PUB;

 

/
