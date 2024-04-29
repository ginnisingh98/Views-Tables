--------------------------------------------------------
--  DDL for Package OKL_SETUP_TRXPARAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SETUP_TRXPARAMS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRTXRS.pls 115.1 2004/07/02 02:57:03 sgorantl noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_REQUIRED_VALUE            CONSTANT VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_OKL_LLA_ASSET_REQUIRED    CONSTANT VARCHAR2(200) := 'OKL_LLA_ASSET_REQUIRED';
  G_COL_NAME_TOKEN	      CONSTANT VARCHAR2(100) := OKL_API.G_COL_NAME_TOKEN;

  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SETUP_TRXPARAMS_PVT';

  G_APP_NAME				  CONSTANT VARCHAR2(3)  :=  OKL_API.G_APP_NAME;
  G_MISS_NUM				  CONSTANT NUMBER   	:=  OKL_API.G_MISS_NUM;
  G_MISS_CHAR				  CONSTANT VARCHAR2(1)	:=  OKL_API.G_MISS_CHAR;
  G_MISS_DATE				  CONSTANT DATE   	:=  OKL_API.G_MISS_DATE;
  G_TRUE				  CONSTANT VARCHAR2(1)	:=  OKL_API.G_TRUE;
  G_FALSE				  CONSTANT VARCHAR2(1)	:=  OKL_API.G_FALSE;


  G_EXC_NAME_ERROR		CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_ERROR';
  G_EXC_NAME_UNEXP_ERROR	CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_UNEXP_ERROR';
  G_RET_STS_SUCCESS		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_UNEXP_ERROR;


  G_EXCEPTION_HALT_PROCESSING 		EXCEPTION;
  G_EXCEPTION_ERROR		 	EXCEPTION;
  G_EXCEPTION_UNEXPECTED_ERROR		EXCEPTION;


  SUBTYPE sxpv_rec_type IS okl_sif_trx_parms_pub.sxpv_rec_type;
  SUBTYPE sxpv_tbl_type IS okl_sif_trx_parms_pub.sxpv_tbl_type;

    PROCEDURE create_trx_parm(
        p_api_version                  IN  NUMBER,
        p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_sxpv_rec                     IN  sxpv_rec_type,
        x_sxpv_rec                     OUT NOCOPY sxpv_rec_type);

    PROCEDURE update_trx_parm(
        p_api_version                  IN  NUMBER,
        p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_sxpv_rec                     IN  sxpv_rec_type,
        x_sxpv_rec                     OUT NOCOPY sxpv_rec_type);

    PROCEDURE delete_trx_parm(
        p_api_version                  IN  NUMBER,
        p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_sxpv_rec                     IN  sxpv_rec_type,
        x_sxpv_rec                     OUT NOCOPY sxpv_rec_type);

    PROCEDURE create_trx_parm(
        p_api_version                  IN  NUMBER,
        p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_sxpv_tbl                     IN  sxpv_tbl_type,
        x_sxpv_tbl                     OUT NOCOPY sxpv_tbl_type);

    PROCEDURE update_trx_parm(
        p_api_version                  IN  NUMBER,
        p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_sxpv_tbl                     IN  sxpv_tbl_type,
        x_sxpv_tbl                     OUT NOCOPY sxpv_tbl_type);

    PROCEDURE delete_trx_parm(
        p_api_version                  IN  NUMBER,
        p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_sxpv_tbl                     IN  sxpv_tbl_type,
        x_sxpv_tbl                     OUT NOCOPY sxpv_tbl_type);

    PROCEDURE create_trx_asset_parm(
        p_api_version                  IN  NUMBER,
        p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_sxpv_rec                     IN  sxpv_rec_type,
        x_sxpv_rec                     OUT NOCOPY sxpv_rec_type);

    PROCEDURE update_trx_asset_parm(
        p_api_version                  IN  NUMBER,
        p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_sxpv_rec                     IN  sxpv_rec_type,
        x_sxpv_rec                     OUT NOCOPY sxpv_rec_type);

    PROCEDURE create_trx_asset_parm(
        p_api_version                  IN  NUMBER,
        p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_sxpv_tbl                     IN  sxpv_tbl_type,
        x_sxpv_tbl                     OUT NOCOPY sxpv_tbl_type);

    PROCEDURE update_trx_asset_parm(
        p_api_version                  IN  NUMBER,
        p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_sxpv_tbl                     IN  sxpv_tbl_type,
        x_sxpv_tbl                     OUT NOCOPY sxpv_tbl_type);

END OKL_SETUP_TRXPARAMS_PVT;

 

/
