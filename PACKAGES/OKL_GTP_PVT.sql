--------------------------------------------------------
--  DDL for Package OKL_GTP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_GTP_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSGTPS.pls 120.2 2006/07/11 10:19:46 dkagrawa noship $ */

---------------------------------------------------------------------------
-- GLOBAL DATASTRUCTURES
---------------------------------------------------------------------------

TYPE gtp_rec_type IS RECORD (
     id                     NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,object_version_number  NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,name                   OKL_ST_GEN_PRC_PARAMS.NAME%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,description            OKL_ST_GEN_PRC_PARAMS.DESCRIPTION%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,display_yn             OKL_ST_GEN_PRC_PARAMS.DISPLAY_YN%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,update_yn              OKL_ST_GEN_PRC_PARAMS.UPDATE_YN%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,prc_eng_ident          OKL_ST_GEN_PRC_PARAMS.PRC_ENG_IDENT%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,default_value          OKL_ST_GEN_PRC_PARAMS.DEFAULT_VALUE%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,org_id                 NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,created_by             NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,creation_date          OKL_ST_GEN_PRC_PARAMS.CREATION_DATE%TYPE DEFAULT Okl_Api.G_MISS_DATE
    ,last_updated_by        NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,last_update_date       OKL_ST_GEN_PRC_PARAMS.LAST_UPDATE_DATE%TYPE DEFAULT Okl_Api.G_MISS_DATE
    ,last_update_login      NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,gtt_id                 NUMBER DEFAULT Okl_Api.G_MISS_NUM
);


G_MISS_gtp_REC  gtp_rec_type;
TYPE gtp_tbl_type IS TABLE OF gtp_rec_type
     INDEX BY BINARY_INTEGER;

TYPE gtpv_rec_type IS RECORD (
     id                     NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,object_version_number  NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,name                   OKL_ST_GEN_PRC_PARAMS.NAME%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,description            OKL_ST_GEN_PRC_PARAMS.DESCRIPTION%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,display_yn             OKL_ST_GEN_PRC_PARAMS.DISPLAY_YN%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,update_yn              OKL_ST_GEN_PRC_PARAMS.UPDATE_YN%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,prc_eng_ident          OKL_ST_GEN_PRC_PARAMS.PRC_ENG_IDENT%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,default_value          OKL_ST_GEN_PRC_PARAMS.DEFAULT_VALUE%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,org_id                 NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,created_by             NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,creation_date          OKL_ST_GEN_PRC_PARAMS.CREATION_DATE%TYPE DEFAULT Okl_Api.G_MISS_DATE
    ,last_updated_by        NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,last_update_date       OKL_ST_GEN_PRC_PARAMS.LAST_UPDATE_DATE%TYPE DEFAULT Okl_Api.G_MISS_DATE
    ,last_update_login      NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,gtt_id                 NUMBER DEFAULT Okl_Api.G_MISS_NUM
);


G_MISS_gtpv_REC  gtpv_rec_type;
TYPE gtpv_tbl_type IS TABLE OF gtpv_rec_type
     INDEX BY BINARY_INTEGER;

---------------------------------------------------------------------------
-- GLOBAL VARIABLES
---------------------------------------------------------------------------
G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_GTP_PVT';
G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;
--------------------------------------------------------------------------------
  -- ERRORS AND EXCEPTIONS
  --------------------------------------------------------------------------------
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
    p_gtpv_rec                     IN  gtpv_rec_type,
    x_gtpv_rec                     OUT NOCOPY gtpv_rec_type );

PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gtpv_tbl                     IN  gtpv_tbl_type,
    x_gtpv_tbl                     OUT NOCOPY gtpv_tbl_type);

PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gtpv_rec                     IN  gtpv_rec_type,
    x_gtpv_rec                     OUT NOCOPY gtpv_rec_type);

 PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gtpv_tbl                     IN  gtpv_tbl_type,
    x_gtpv_tbl                     OUT NOCOPY gtpv_tbl_type);

PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gtpv_rec                     IN  gtpv_rec_type);

PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gtpv_tbl                     IN  gtpv_tbl_type);

END okl_gtp_pvt;

/
