--------------------------------------------------------
--  DDL for Package OKL_POPULATE_PRCENG_RESULT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_POPULATE_PRCENG_RESULT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRPERS.pls 115.9 2003/05/12 23:40:03 bakuchib noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';

  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_POPULATE_PRCENG_RESULT_PVT';

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
  G_EXCEPTION_ERROR			  		EXCEPTION;
  G_EXCEPTION_UNEXPECTED_ERROR		EXCEPTION;

  SUBTYPE sirv_rec_type IS okl_sir_pvt.sirv_rec_type;
  SUBTYPE srsv_rec_type IS okl_srs_pvt.srsv_rec_type;
  SUBTYPE srsv_tbl_type IS okl_srs_pvt.srsv_tbl_type;
  G_SRSV_TBL srsv_tbl_type;
  G_COUNTER NUMBER := 0;
  SUBTYPE srmv_rec_type IS okl_srm_pvt.srmv_rec_type;
  SUBTYPE sifv_rec_type IS okl_sif_pvt.sifv_rec_type;
  SUBTYPE srlv_rec_type IS okl_srl_pvt.okl_sif_ret_levels_v_rec_type;

  PROCEDURE populate_sif_rets (
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sirv_rec                     IN  sirv_rec_type,
    x_sirv_rec                     OUT NOCOPY sirv_rec_type);

  PROCEDURE update_sif_rets (
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sirv_rec                     IN  sirv_rec_type,
    x_sirv_rec                     OUT NOCOPY sirv_rec_type);


  PROCEDURE populate_sif_ret_strms (
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srsv_rec                     IN  srsv_rec_type,
    x_srsv_rec                     OUT NOCOPY srsv_rec_type);

  PROCEDURE populate_sif_ret_errors (
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srmv_rec                     IN  srmv_rec_type,
    x_srmv_rec                     OUT NOCOPY srmv_rec_type);

  PROCEDURE populate_sif_ret_levels (
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_srlv_rec                     IN  srlv_rec_type,
    x_srlv_rec                     OUT NOCOPY srlv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2);


  PROCEDURE update_outbound_status (
    p_api_version    IN NUMBER,
    p_init_msg_list  IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_sifv_rec       IN sifv_rec_type,
    x_sifv_rec       OUT NOCOPY sifv_rec_type,
    x_msg_count      OUT NOCOPY NUMBER,
    x_msg_data       OUT NOCOPY VARCHAR2,
    x_return_status  OUT NOCOPY VARCHAR2);

END OKL_POPULATE_PRCENG_RESULT_PVT;

 

/
