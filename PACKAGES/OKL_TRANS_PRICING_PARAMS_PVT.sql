--------------------------------------------------------
--  DDL for Package OKL_TRANS_PRICING_PARAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TRANS_PRICING_PARAMS_PVT" AUTHID CURRENT_USER as
/* $Header: OKLRSPMS.pls 120.3 2005/10/30 03:17:23 appldev noship $*/

  TYPE tpp_rec_type IS RECORD (
    gtp_id                    NUMBER DEFAULT Okl_Api.G_MISS_NUM
   ,parameter_value           OKL_SIF_PRICING_PARAMS.PARAMETER_VALUE%TYPE DEFAULT Okl_Api.G_MISS_CHAR);

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_VERSION_OVERLAPS          CONSTANT VARCHAR2(200) := 'OKL_VERSION_OVERLAPS';
  G_DATES_MISMATCH            CONSTANT VARCHAR2(200) := 'OKL_DATES_MISMATCH';
  G_PAST_RECORDS	  		  CONSTANT VARCHAR2(200) := 'OKL_PAST_RECORDS';
  G_START_DATE				  CONSTANT VARCHAR2(200) := 'OKL_START_DATE';
  G_END_DATE				  CONSTANT VARCHAR2(200) := 'OKL_END_DATE';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_TABLE_TOKEN		  		  CONSTANT VARCHAR2(100) := 'OKL_TABLE_NAME';
  G_PARENT_TABLE_TOKEN	      CONSTANT VARCHAR2(100) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN         CONSTANT VARCHAR2(100) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_COL_NAME_TOKEN			  CONSTANT VARCHAR2(100) := OKL_API.G_COL_NAME_TOKEN;
  G_INVALID_VALUE	          CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_APP_NAME				  CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_TRANS_PRICING_PARAMS_PVT';
  G_MISS_NUM				  CONSTANT NUMBER   	:=  OKL_API.G_MISS_NUM;
  G_MISS_CHAR				  CONSTANT VARCHAR2(1)	:=  OKL_API.G_MISS_CHAR;
  G_MISS_DATE				  CONSTANT DATE   	:=  OKL_API.G_MISS_DATE;
  G_TRUE				      CONSTANT VARCHAR2(1)	:=  OKL_API.G_TRUE;
  G_FALSE				      CONSTANT VARCHAR2(1)	:=  OKL_API.G_FALSE;
  G_INIT_VERSION			  CONSTANT NUMBER := 1.0;
  G_VERSION_MAJOR_INCREMENT	  CONSTANT NUMBER := 1.0;
  G_VERSION_FORMAT			  CONSTANT VARCHAR2(100) := 'FM999.0999';
  G_EXC_NAME_ERROR	          CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_ERROR';
  G_EXC_NAME_UNEXP_ERROR	  CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_UNEXP_ERROR';
  G_RET_STS_SUCCESS	          CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR	          CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR	      CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_UNEXP_ERROR;
  G_REQUIRED_VALUE	          CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;

  G_EXCEPTION_HALT_VALIDATION   EXCEPTION;
  G_EXCEPTION_HALT_PROCESSING   EXCEPTION;
  G_EXCEPTION_ERROR			    EXCEPTION;
  G_EXCEPTION_UNEXPECTED_ERROR  EXCEPTION;

  -- Trasnsactions Pricing Parameters
  SUBTYPE spmv_rec_type IS okl_spm_pvt.spmv_rec_type;
  SUBTYPE spmv_tbl_type IS okl_spm_pvt.spmv_tbl_type;

  TYPE tpp_tbl_type IS TABLE OF tpp_rec_type
     INDEX BY BINARY_INTEGER;

  PROCEDURE create_trans_pricing_params(
                     p_api_version             IN  NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
                    ,p_tpp_rec                 IN  tpp_rec_type
                    ,p_chr_id                  IN  NUMBER DEFAULT Okl_Api.G_MISS_NUM
                    ,p_gts_id                  IN  NUMBER DEFAULT Okl_Api.G_MISS_NUM
                    ,p_sif_id                  IN  NUMBER
  );

  PROCEDURE create_trans_pricing_params(
                     p_api_version             IN  NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
                    ,p_tpp_tbl                 IN  tpp_tbl_type
                    ,p_chr_id                  IN  NUMBER DEFAULT Okl_Api.G_MISS_NUM
                    ,p_gts_id                  IN  NUMBER DEFAULT Okl_Api.G_MISS_NUM
                    ,p_sif_id                  IN  NUMBER
  );

  PROCEDURE delete_pricing_params (
                     p_chr_id                  IN NUMBER
                     ,x_return_status           OUT NOCOPY VARCHAR2);

End; -- OKL_TRANS_PRICING_PARAMS_PVT
--SHOW ERRORS;

 

/
