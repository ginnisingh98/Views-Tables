--------------------------------------------------------
--  DDL for Package OKL_FRENCH_TAX_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_FRENCH_TAX_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPFWTS.pls 115.1 2002/07/29 22:20:33 avsingh noship $ */
  ---------------------------------------------------------------------------
  -- SUBTYPES
  ---------------------------------------------------------------------------
 subtype fwtv_rec_type is okl_fwt_pvt.fwtv_rec_type;
 subtype fwtv_tbl_type is okl_fwt_pvt.fwtv_tbl_type;
   ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_FRENCH_TAX_PUB';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

  g_chrv_rec		fwtv_rec_type;
  g_chrv_tbl		fwtv_tbl_type;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------


  PROCEDURE create_french_tax(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_rec                     IN fwtv_rec_type,
    x_fwtv_rec                     OUT NOCOPY fwtv_rec_type);

  PROCEDURE create_french_tax(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_tbl                     IN fwtv_tbl_type,
    x_fwtv_tbl                     OUT NOCOPY fwtv_tbl_type);


  PROCEDURE update_french_tax(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update            IN VARCHAR2,
    p_fwtv_rec                     IN fwtv_rec_type,
    x_fwtv_rec                     OUT NOCOPY fwtv_rec_type);

  PROCEDURE update_french_tax(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update            IN VARCHAR2,
    p_fwtv_tbl                     IN fwtv_tbl_type,
    x_fwtv_tbl                     OUT NOCOPY fwtv_tbl_type);

  PROCEDURE delete_french_tax(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_rec                     IN fwtv_rec_type);

  PROCEDURE delete_french_tax(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_tbl                     IN fwtv_tbl_type);

  PROCEDURE validate_french_tax(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_rec                     IN fwtv_rec_type);

  PROCEDURE validate_french_tax(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_tbl                     IN fwtv_tbl_type);

END OKL_FRENCH_TAX_PUB;

 

/
