--------------------------------------------------------
--  DDL for Package OKL_GTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_GTS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSGTSS.pls 120.4 2007/10/15 16:46:11 dpsingh noship $ */
---------------------------------------------------------------------------
-- GLOBAL DATASTRUCTURES
---------------------------------------------------------------------------
TYPE gts_rec_type IS RECORD (
      id                     OKL_ST_GEN_TMPT_SETS.ID%TYPE DEFAULT Okl_Api.G_MISS_NUM
     ,object_version_number  NUMBER DEFAULT Okl_Api.G_MISS_NUM
     ,name                   OKL_ST_GEN_TMPT_SETS.NAME%TYPE DEFAULT Okl_Api.G_MISS_CHAR
     ,description            OKL_ST_GEN_TMPT_SETS.DESCRIPTION%TYPE DEFAULT Okl_Api.G_MISS_CHAR
     ,product_type           OKL_ST_GEN_TMPT_SETS.PRODUCT_TYPE%TYPE DEFAULT Okl_Api.G_MISS_CHAR
     ,tax_owner              OKL_ST_GEN_TMPT_SETS.TAX_OWNER%TYPE DEFAULT Okl_Api.G_MISS_CHAR
     ,deal_type              OKL_ST_GEN_TMPT_SETS.DEAL_TYPE%TYPE DEFAULT Okl_Api.G_MISS_CHAR
     ,pricing_engine         OKL_ST_GEN_TMPT_SETS.PRICING_ENGINE%TYPE DEFAULT Okl_Api.G_MISS_CHAR
     ,org_id                 NUMBER DEFAULT Okl_Api.G_MISS_NUM
     ,created_by             NUMBER DEFAULT Okl_Api.G_MISS_NUM
     ,creation_date          OKL_ST_GEN_TMPT_SETS.CREATION_DATE%TYPE DEFAULT Okl_Api.G_MISS_DATE
     ,last_updated_by        NUMBER DEFAULT Okl_Api.G_MISS_NUM
     ,last_update_date       OKL_ST_GEN_TMPT_SETS.LAST_UPDATE_DATE%TYPE DEFAULT Okl_Api.G_MISS_DATE
     ,last_update_login      NUMBER DEFAULT Okl_Api.G_MISS_NUM
     ,interest_calc_meth_code  OKL_ST_GEN_TMPT_SETS.INTEREST_CALC_METH_CODE%TYPE DEFAULT Okl_Api.G_MISS_CHAR
     ,revenue_recog_meth_code  OKL_ST_GEN_TMPT_SETS.REVENUE_RECOG_METH_CODE%TYPE  DEFAULT Okl_Api.G_MISS_CHAR
     ,days_in_month_code       OKL_ST_GEN_TMPT_SETS.DAYS_IN_MONTH_CODE%TYPE  DEFAULT Okl_Api.G_MISS_CHAR
     ,days_in_yr_code          OKL_ST_GEN_TMPT_SETS.DAYS_IN_YR_CODE%TYPE  DEFAULT Okl_Api.G_MISS_CHAR
     ,isg_arrears_pay_dates_option OKL_ST_GEN_TMPT_SETS.ISG_ARREARS_PAY_DATES_OPTION%TYPE DEFAULT Okl_Api.G_MISS_CHAR
);
G_MISS_GTS_REC  gts_rec_type;
TYPE gts_tbl_type IS TABLE OF gts_rec_type
     INDEX BY BINARY_INTEGER;

TYPE gtsv_rec_type IS RECORD(
    id                       OKL_ST_GEN_TMPT_SETS.ID%TYPE DEFAULT Okl_Api.G_MISS_NUM
    ,object_version_number   NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,name                    OKL_ST_GEN_TMPT_SETS.NAME%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,description             OKL_ST_GEN_TMPT_SETS.DESCRIPTION%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,product_type            OKL_ST_GEN_TMPT_SETS.PRODUCT_TYPE%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,tax_owner               OKL_ST_GEN_TMPT_SETS.TAX_OWNER%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,deal_type               OKL_ST_GEN_TMPT_SETS.DEAL_TYPE%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,pricing_engine          OKL_ST_GEN_TMPT_SETS.PRICING_ENGINE%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,org_id                  NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,created_by              NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,creation_date           OKL_ST_GEN_TMPT_SETS.CREATION_DATE%TYPE DEFAULT Okl_Api.G_MISS_DATE
    ,last_updated_by         NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,last_update_date        OKL_ST_GEN_TMPT_SETS.LAST_UPDATE_DATE%TYPE DEFAULT Okl_Api.G_MISS_DATE
    ,last_update_login       NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,interest_calc_meth_code  OKL_ST_GEN_TMPT_SETS.INTEREST_CALC_METH_CODE%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,revenue_recog_meth_code  OKL_ST_GEN_TMPT_SETS.REVENUE_RECOG_METH_CODE%TYPE  DEFAULT Okl_Api.G_MISS_CHAR
    ,days_in_month_code       OKL_ST_GEN_TMPT_SETS.DAYS_IN_MONTH_CODE%TYPE  DEFAULT Okl_Api.G_MISS_CHAR
    ,days_in_yr_code          OKL_ST_GEN_TMPT_SETS.DAYS_IN_YR_CODE%TYPE  DEFAULT Okl_Api.G_MISS_CHAR
    ,isg_arrears_pay_dates_option OKL_ST_GEN_TMPT_SETS.ISG_ARREARS_PAY_DATES_OPTION%TYPE DEFAULT Okl_Api.G_MISS_CHAR
);
G_MISS_GTSV_REC gtsv_rec_type;
TYPE gtsv_tbl_type IS TABLE OF gtsv_rec_type
        INDEX BY BINARY_INTEGER;
---------------------------------------------------------------------------
-- GLOBAL VARIABLES
---------------------------------------------------------------------------
G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_GTS_PVT';
G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;
G_INVESTOR_TYPE                 CONSTANT VARCHAR2(200) := 'INVESTOR';
G_FINANCIAL_TYPE                CONSTANT VARCHAR2(200) := 'FINANCIAL';
--------------------------------------------------------------------------------
  -- ERRORS AND EXCEPTIONS
  --------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
---------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
---------------------------------------------------------------------------
-- Adding MESSAGE CONSTANTs for 'Unique Key Validation','SQLCode', 'SQLErrM'
G_SQLERRM_TOKEN     CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
G_SQLCODE_TOKEN     CONSTANT VARCHAR2(200) := 'OKL_SQLcode';
G_UNEXPECTED_ERROR  CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
G_REQUIRED_VALUE	CONSTANT VARCHAR2(200) := Okl_Api.G_REQUIRED_VALUE;
G_COL_NAME_TOKEN	CONSTANT VARCHAR2(200) := Okl_Api.G_COL_NAME_TOKEN;
G_INVALID_VALUE		CONSTANT VARCHAR2(200) := Okl_Api.G_INVALID_VALUE;


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
    p_gtsv_rec                     IN gtsv_rec_type,
    x_gtsv_rec                     OUT NOCOPY gtsv_rec_type );

PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gtsv_tbl                     IN  gtsv_tbl_type,
    x_gtsv_tbl                     OUT NOCOPY gtsv_tbl_type);

PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gtsv_rec                      IN  gtsv_rec_type,
    x_gtsv_rec                      OUT NOCOPY gtsv_rec_type);

PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gtsv_tbl                     IN  gtsv_tbl_type,
    x_gtsv_tbl                     OUT NOCOPY gtsv_tbl_type);

PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gtsv_rec                     IN  gtsv_rec_type);

PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gtsv_tbl                     IN  gtsv_tbl_type);

END okl_gts_pvt;

/
