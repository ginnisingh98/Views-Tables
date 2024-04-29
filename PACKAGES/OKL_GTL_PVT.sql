--------------------------------------------------------
--  DDL for Package OKL_GTL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_GTL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSGTLS.pls 120.2 2006/07/11 10:19:28 dkagrawa noship $ */

---------------------------------------------------------------------------
-- GLOBAL DATASTRUCTURES
---------------------------------------------------------------------------

TYPE gtl_rec_type IS RECORD (
	id                      NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,object_version_number  NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,gtt_id                 NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,primary_yn             OKL_ST_GEN_TMPT_LNS.primary_yn%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,primary_sty_id         NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,dependent_sty_id       NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,pricing_name           OKL_ST_GEN_TMPT_LNS.pricing_name%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,org_id                 NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,created_by             NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,creation_date          OKL_ST_GEN_TMPT_LNS.creation_date%TYPE DEFAULT Okl_Api.G_MISS_DATE
    ,last_updated_by        NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,last_update_date       OKL_ST_GEN_TMPT_LNS.last_update_date%TYPE DEFAULT Okl_Api.G_MISS_DATE
    ,last_update_login      NUMBER DEFAULT Okl_Api.G_MISS_NUM
);


G_MISS_GTL_REC  gtl_rec_type;
TYPE gtl_tbl_type IS TABLE OF gtl_rec_type
     INDEX BY BINARY_INTEGER;

TYPE gtlv_rec_type IS RECORD (
	id                      NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,object_version_number  NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,gtt_id                 NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,primary_yn             OKL_ST_GEN_TMPT_LNS.primary_yn%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,primary_sty_id         NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,dependent_sty_id       NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,pricing_name           OKL_ST_GEN_TMPT_LNS.pricing_name%TYPE DEFAULT Okl_Api.G_MISS_CHAR
    ,org_id                 NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,created_by             NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,creation_date          OKL_ST_GEN_TMPT_LNS.creation_date%TYPE DEFAULT Okl_Api.G_MISS_DATE
    ,last_updated_by        NUMBER DEFAULT Okl_Api.G_MISS_NUM
    ,last_update_date       OKL_ST_GEN_TMPT_LNS.last_update_date%TYPE DEFAULT Okl_Api.G_MISS_DATE
    ,last_update_login      NUMBER DEFAULT Okl_Api.G_MISS_NUM
);


G_MISS_GTLV_REC  gtlv_rec_type;
TYPE gtlv_tbl_type IS TABLE OF gtlv_rec_type
     INDEX BY BINARY_INTEGER;

---------------------------------------------------------------------------
-- GLOBAL VARIABLES
---------------------------------------------------------------------------
G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_GTL_PVT';
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
    p_gtlv_rec                     IN  gtlv_rec_type,
    x_gtlv_rec                     OUT NOCOPY gtlv_rec_type );

PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gtlv_tbl                     IN  gtlv_tbl_type,
    x_gtlv_tbl                     OUT NOCOPY gtlv_tbl_type);

PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gtlv_rec                     IN  gtlv_rec_type,
    x_gtlv_rec                     OUT NOCOPY gtlv_rec_type);

PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gtlv_tbl                     IN  gtlv_tbl_type,
    x_gtlv_tbl                     OUT NOCOPY gtlv_tbl_type);

PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gtlv_rec                     IN  gtlv_rec_type);

PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gtlv_tbl                     IN  gtlv_tbl_type);

END okl_gtl_pvt;

/
