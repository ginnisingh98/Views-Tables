--------------------------------------------------------
--  DDL for Package OKL_VALIDATION_SET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VALIDATION_SET_PVT" AUTHID CURRENT_USER AS
  /* $Header: OKLRVLSS.pls 120.3 2005/10/03 06:41:47 ssdeshpa noship $ */

---------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
---------------------------------------------------------------------------
G_SQLERRM_TOKEN     CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
G_SQLCODE_TOKEN     CONSTANT VARCHAR2(200) := 'OKL_SQLcode';
G_UNEXPECTED_ERROR  CONSTANT VARCHAR2(200) := 'OKL_VALIDATIONS_UNEXPECTED_ERROR';
G_REQUIRED_VALUE	CONSTANT VARCHAR2(200) := Okl_Api.G_REQUIRED_VALUE;
G_COL_NAME_TOKEN	CONSTANT VARCHAR2(200) := Okl_Api.G_COL_NAME_TOKEN;
G_INVALID_VALUE		CONSTANT VARCHAR2(200) := Okl_Api.G_INVALID_VALUE;
G_INVALID_END_DATE  CONSTANT VARCHAR2(200) := 'OKL_INVALID_DATE';

  G_VERSION_OVERLAPS	CONSTANT VARCHAR2(200) := 'OKL_VERSION_OVERLAPS';
  G_DATES_MISMATCH		CONSTANT VARCHAR2(200) := 'OKL_DATES_MISMATCH';
  G_PAST_RECORDS	  	CONSTANT VARCHAR2(200) := 'OKL_PAST_RECORDS';
  G_START_DATE			CONSTANT VARCHAR2(200) := 'OKL_START_DATE';
  G_END_DATE			CONSTANT VARCHAR2(200) := 'OKL_END_DATE';
  G_SQLERRM_TOKEN		CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN		CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(100) := OKL_API.G_COL_NAME_TOKEN;


  G_INVALID_VALUE		         CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_MISS_NUM			         CONSTANT NUMBER   	    :=  OKL_API.G_MISS_NUM;
  G_MISS_CHAR			         CONSTANT VARCHAR2(1)	:=  OKL_API.G_MISS_CHAR;
  G_MISS_DATE			         CONSTANT DATE   	    :=  OKL_API.G_MISS_DATE;
  G_TRUE			             CONSTANT VARCHAR2(1)	:=  OKL_API.G_TRUE;
  G_FALSE			             CONSTANT VARCHAR2(1)	:=  OKL_API.G_FALSE;


---------------------------------------------------------------------------
-- GLOBAL VARIABLES
---------------------------------------------------------------------------
G_PKG_NAME		   CONSTANT VARCHAR2(200) := 'OKL_VALIDATION_SET_PVT';
G_API_TYPE         CONSTANT varchar2(4) := '_PVT';
G_APP_NAME		   CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;
--------------------------------------------------------------------------------
  -- ERRORS AND EXCEPTIONS
--------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
  G_EXCEPTION_HALT_PROCESSING 	EXCEPTION;
  G_EXCEPTION_ERROR		        EXCEPTION;
  G_EXCEPTION_UNEXPECTED_ERROR	EXCEPTION;

  -- Validation Set
  SUBTYPE vlsv_rec_type IS okl_vls_pvt.vlsv_rec_type;

  -- Individual Validation Lines
  SUBTYPE vldv_rec_type IS okl_vld_pvt.vldv_rec_type;

  SUBTYPE vldv_tbl_type IS okl_vld_pvt.vldv_tbl_type;

  PROCEDURE create_vls(p_api_version     IN          number
                      ,p_init_msg_list   IN          varchar2
                      ,x_return_status   OUT NOCOPY  varchar2
                      ,x_msg_count       OUT NOCOPY  number
                      ,x_msg_data        OUT NOCOPY  varchar2
                      ,p_vlsv_rec        IN          vlsv_rec_type
                      ,x_vlsv_rec        OUT NOCOPY  vlsv_rec_type
                      ,p_vldv_tbl       IN          vldv_tbl_type
                      ,x_vldv_tbl        OUT NOCOPY  vldv_tbl_type);

   PROCEDURE update_vls(p_api_version    IN          number
                      ,p_init_msg_list   IN          varchar2     DEFAULT okl_api.g_false
                      ,x_return_status   OUT NOCOPY  varchar2
                      ,x_msg_count       OUT NOCOPY  number
                      ,x_msg_data        OUT NOCOPY  varchar2
                      ,p_vlsv_rec        IN          vlsv_rec_type
                      ,x_vlsv_rec        OUT NOCOPY  vlsv_rec_type
                      ,p_vldv_tbl        IN          vldv_tbl_type
                      ,x_vldv_tbl        OUT NOCOPY  vldv_tbl_type);

   PROCEDURE delete_vls(p_api_version    IN          number
                      ,p_init_msg_list   IN          varchar2     DEFAULT okl_api.g_false
                      ,x_return_status   OUT NOCOPY  varchar2
                      ,x_msg_count       OUT NOCOPY  number
                      ,x_msg_data        OUT NOCOPY  varchar2
                      ,p_vlsv_rec        IN          vlsv_rec_type);

   PROCEDURE delete_vld(p_api_version    IN          number
                      ,p_init_msg_list   IN          varchar2     DEFAULT okl_api.g_false
                      ,x_return_status   OUT NOCOPY  varchar2
                      ,x_msg_count       OUT NOCOPY  number
                      ,x_msg_data        OUT NOCOPY  varchar2
                      ,p_vldv_rec        IN          vldv_rec_type);
  FUNCTION validate_header(p_vlsv_rec  IN  vlsv_rec_type) RETURN varchar2;
  --FUNCTION validate_duplicate(p_vldv_tbl  IN  vldv_tbl_type) RETURN varchar2;

END OKL_VALIDATION_SET_PVT;

 

/
