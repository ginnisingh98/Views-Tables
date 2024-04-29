--------------------------------------------------------
--  DDL for Package OKL_SETUPCONTEXTGROUPS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SETUPCONTEXTGROUPS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPSCGS.pls 115.1 2002/02/06 20:29:25 pkm ship       $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';

  G_APP_NAME				  CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SETUPCONTEXTGROUPS_PUB';

  SUBTYPE cgrv_rec_type IS okl_setupcontextgroups_pvt.cgrv_rec_type;
  SUBTYPE cgrv_tbl_type IS okl_setupcontextgroups_pvt.cgrv_tbl_type;

  PROCEDURE get_rec(
  	p_cgrv_rec					   IN cgrv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
	x_msg_data					   OUT NOCOPY VARCHAR2,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_cgrv_rec					   OUT NOCOPY cgrv_rec_type);

  PROCEDURE insert_contextgroups(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgrv_rec                     IN  cgrv_rec_type,
    x_cgrv_rec                     OUT NOCOPY cgrv_rec_type);

  PROCEDURE update_contextgroups(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgrv_rec                     IN  cgrv_rec_type,
    x_cgrv_rec                     OUT NOCOPY cgrv_rec_type);

END OKL_SETUPCONTEXTGROUPS_PUB;

 

/