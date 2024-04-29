--------------------------------------------------------
--  DDL for Package OKL_SPM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SPM_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSSPMS.pls 120.3 2006/07/11 10:27:25 dkagrawa noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE spm_rec_type IS RECORD (
     id                     NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,object_version_number  NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,sif_id                 NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,khr_id                 NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,name                   OKL_SIF_PRICING_PARAMS.NAME%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,display_yn             OKL_SIF_PRICING_PARAMS.DISPLAY_YN%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,update_yn              OKL_SIF_PRICING_PARAMS.UPDATE_YN%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,default_value          OKL_SIF_PRICING_PARAMS.DEFAULT_VALUE%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,parameter_value        OKL_SIF_PRICING_PARAMS.PARAMETER_VALUE%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,prc_eng_ident          OKL_SIF_PRICING_PARAMS.PRC_ENG_IDENT%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,description            OKL_ST_GEN_PRC_PARAMS.DESCRIPTION%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,created_by             NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,creation_date          OKL_SIF_PRICING_PARAMS.CREATION_DATE%TYPE DEFAULT Okl_Api.G_MISS_DATE
    ,last_updated_by        NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,last_update_date       OKL_SIF_PRICING_PARAMS.LAST_UPDATE_DATE%TYPE DEFAULT Okl_Api.G_MISS_DATE
    ,last_update_login      NUMBER DEFAULT Okl_Api.G_MISS_NUM
  );

  G_MISS_spm_REC  spm_rec_type;
  TYPE spm_tbl_type IS TABLE OF spm_rec_type
     INDEX BY BINARY_INTEGER;

  TYPE spmv_rec_type IS RECORD (
     id                     NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,object_version_number  NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,sif_id                 NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,khr_id                 NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,name                   OKL_SIF_PRICING_PARAMS_V.NAME%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,display_yn             OKL_SIF_PRICING_PARAMS_V.DISPLAY_YN%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,update_yn              OKL_SIF_PRICING_PARAMS_V.UPDATE_YN%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,default_value          OKL_SIF_PRICING_PARAMS_V.DEFAULT_VALUE%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,parameter_value        OKL_SIF_PRICING_PARAMS_V.PARAMETER_VALUE%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,prc_eng_ident          OKL_SIF_PRICING_PARAMS_V.PRC_ENG_IDENT%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,description            OKL_ST_GEN_PRC_PARAMS.DESCRIPTION%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,created_by             NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,creation_date          OKL_SIF_PRICING_PARAMS_V.CREATION_DATE%TYPE DEFAULT Okl_Api.G_MISS_DATE
    ,last_updated_by        NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,last_update_date       OKL_SIF_PRICING_PARAMS_V.LAST_UPDATE_DATE%TYPE DEFAULT Okl_Api.G_MISS_DATE
    ,last_update_login      NUMBER DEFAULT Okl_Api.G_MISS_NUM
  );

  G_MISS_spmv_REC  spmv_rec_type;
  TYPE spmv_tbl_type IS TABLE OF spmv_rec_type
     INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_SPM_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- ERRORS AND EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  -- Adding MESSAGE CONSTANTs for 'Unique Key Validation','SQLCode', 'SQLErrM'
  G_SQLERRM_TOKEN             	CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN             	CONSTANT VARCHAR2(200) := 'OKL_SQLcode';
  G_UNEXPECTED_ERROR          	CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_REQUIRED_VALUE		        CONSTANT VARCHAR2(200) := Okl_Api.G_REQUIRED_VALUE;
  G_COL_NAME_TOKEN		        CONSTANT VARCHAR2(200) := Okl_Api.G_COL_NAME_TOKEN;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_spmv_rec                     IN  spmv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_spmv_tbl                     IN  spmv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_spmv_rec                     IN  spmv_rec_type);


  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_spmv_tbl                     IN  spmv_tbl_type);

END; -- Package spec OKL_spm_PVT

/
