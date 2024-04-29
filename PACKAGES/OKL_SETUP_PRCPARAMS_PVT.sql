--------------------------------------------------------
--  DDL for Package OKL_SETUP_PRCPARAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SETUP_PRCPARAMS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRPPRS.pls 115.1 2004/07/02 02:56:40 sgorantl noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_VERSION_OVERLAPS		  CONSTANT VARCHAR2(200) := 'OKL_VERSION_OVERLAPS';
  G_DATES_MISMATCH			  CONSTANT VARCHAR2(200) := 'OKL_DATES_MISMATCH';
  G_PAST_RECORDS	  		  CONSTANT VARCHAR2(200) := 'OKL_PAST_RECORDS';
  G_START_DATE				  CONSTANT VARCHAR2(200) := 'OKL_START_DATE';
  G_END_DATE				  CONSTANT VARCHAR2(200) := 'OKL_END_DATE';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_TABLE_TOKEN		  		  CONSTANT VARCHAR2(100) := 'OKL_TABLE_NAME';
  G_PARENT_TABLE_TOKEN		  CONSTANT VARCHAR2(100) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		  CONSTANT VARCHAR2(100) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_COL_NAME_TOKEN			  CONSTANT VARCHAR2(100) := OKL_API.G_COL_NAME_TOKEN;

  -- mvasudev -- 02/17/2002
  G_INVALID_VALUE		      CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  -- end, mvasudev -- 02/17/2002

  G_APP_NAME				  CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SETUP_PRCPARAMS_PVT';

  G_INIT_VERSION			  CONSTANT NUMBER := 1.0;
  G_VERSION_MAJOR_INCREMENT	  CONSTANT NUMBER := 1.0;
  G_VERSION_MINOR_INCREMENT	  CONSTANT NUMBER := 0.1;
  G_VERSION_FORMAT			  CONSTANT VARCHAR2(100) := 'FM999.0999';
  G_FORMULA_TYPE			  CONSTANT VARCHAR2(10) := 'GRNC';

  G_FALSE	CONSTANT VARCHAR2(1) := OKL_API.G_FALSE;
  G_TRUE	CONSTANT VARCHAR2(1) := OKL_API.G_TRUE;
  G_MISS_NUM	CONSTANT NUMBER := OKL_API.G_MISS_NUM;
  G_MISS_CHAR	CONSTANT VARCHAR2(1) := OKL_API.G_MISS_CHAR;
  G_MISS_DATE	CONSTANT DATE := OKL_API.G_MISS_DATE;

  G_RET_STS_SUCCESS		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_UNEXP_ERROR		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_ERROR;

  G_EXCEPTION_HALT_PROCESSING EXCEPTION;
  G_EXCEPTION_UNEXPECTED_ERROR	EXCEPTION;
  G_EXCEPTION_ERROR		EXCEPTION;

  G_API_TYPE	CONSTANT VARCHAR(4) := '_PVT';
  G_EXC_NAME_RET_STS_ERR	CONSTANT VARCHAR(25) := 'OKL_API.G_RET_STS_ERROR';
  G_EXC_NAME_RET_STS_UNEXP_ERR	CONSTANT VARCHAR(30) := 'OKL_API.G_RET_STS_UNEXP_ERROR';
  G_EXC_NAME_OTHERS	CONSTANT VARCHAR2(6) := 'OTHERS';

	 SUBTYPE sppv_rec_type IS okl_sif_price_parms_pub.sppv_rec_type;
 	SUBTYPE sppv_tbl_type IS okl_sif_price_parms_pub.sppv_tbl_type;

    PROCEDURE create_price_parm(
        p_api_version                  IN  NUMBER,
        p_init_msg_list                IN  VARCHAR2 DEFAULT G_FALSE,
        p_sppv_rec                     IN  sppv_rec_type,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        x_sppv_rec                     OUT NOCOPY sppv_rec_type);

    PROCEDURE update_price_parm(
        p_api_version                  IN  NUMBER,
        p_init_msg_list                IN  VARCHAR2 DEFAULT G_FALSE,
        p_sppv_rec                     IN  sppv_rec_type,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        x_sppv_rec                     OUT NOCOPY sppv_rec_type);

    PROCEDURE create_price_parm(
        p_api_version                  IN  NUMBER,
        p_init_msg_list                IN  VARCHAR2 DEFAULT G_FALSE,
        p_sppv_tbl                     IN  sppv_tbl_type,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        x_sppv_tbl                     OUT NOCOPY sppv_tbl_type);

    PROCEDURE update_price_parm(
        p_api_version                  IN  NUMBER,
        p_init_msg_list                IN  VARCHAR2 DEFAULT G_FALSE,
        p_sppv_tbl                     IN  sppv_tbl_type,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        x_sppv_tbl                     OUT NOCOPY sppv_tbl_type);


END OKL_SETUP_PRCPARAMS_PVT;

 

/
