--------------------------------------------------------
--  DDL for Package OKC_LINE_STYLES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_LINE_STYLES_PUB" AUTHID CURRENT_USER AS
/* $Header: OKCPLSES.pls 120.0 2005/06/02 03:45:41 appldev noship $ */

 --------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKC_LINE_STYLES_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';
 --------------------------------------------------------------------------
  --Global Exception
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_LINE_STYLES
 --------------------------------------------------------------------------

  SUBTYPE lsev_rec_type is okc_line_styles_pvt.lsev_rec_type;
  TYPE lsev_tbl_type is table of okc_line_styles_pvt.lsev_rec_type index by binary_integer;

  g_lsev_rec lsev_rec_type;
  g_lsev_tbl lsev_tbl_type;


  PROCEDURE add_language;

  PROCEDURE CREATE_LINE_STYLES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lsev_rec		    IN lsev_rec_type,
    x_lsev_rec              OUT NOCOPY lsev_rec_type) ;

  PROCEDURE CREATE_LINE_STYLES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lsev_tbl		    IN lsev_tbl_type,
    x_lsev_tbl              OUT NOCOPY lsev_tbl_type) ;

  PROCEDURE UPDATE_LINE_STYLES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lsev_rec		    IN lsev_rec_type,
    x_lsev_rec              OUT NOCOPY lsev_rec_type) ;

  PROCEDURE UPDATE_LINE_STYLES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lsev_tbl		    IN lsev_tbl_type,
    x_lsev_tbl              OUT NOCOPY lsev_tbl_type) ;

  PROCEDURE DELETE_LINE_STYLES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lsev_rec		    IN lsev_rec_type) ;

  PROCEDURE DELETE_LINE_STYLES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lsev_tbl		    IN lsev_tbl_type) ;

  PROCEDURE LOCK_LINE_STYLES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lsev_rec		    IN lsev_rec_type) ;

  PROCEDURE LOCK_LINE_STYLES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lsev_tbl		    IN lsev_tbl_type) ;

  PROCEDURE VALID_LINE_STYLES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lsev_rec		    IN lsev_rec_type) ;

  PROCEDURE VALID_LINE_STYLES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lsev_tbl		    IN lsev_tbl_type) ;

--finds if theline style is being used by a contract line. returns error if yes
FUNCTION USED_IN_K_LINES( p_lsev_tbl  IN lsev_tbl_type) RETURN VARCHAR2;
--finds if theline style is being used by roles,rule groups or subclass top line. returns error if yes
FUNCTION USED_IN_SETUPS( p_lsev_tbl  IN lsev_tbl_type) RETURN VARCHAR2;
--finds if theline style is being used by line style sources or valid line operations. returns error if yes
FUNCTION USED_IN_SRC_OPS( p_lsev_tbl  IN lsev_tbl_type) RETURN VARCHAR2;

 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_LINE_STYLE_SOURCES
 --------------------------------------------------------------------------

  SUBTYPE lssv_rec_type is okc_line_styles_pvt.lssv_rec_type;
  TYPE lssv_tbl_type is table of okc_line_styles_pvt.lssv_rec_type index by binary_integer;

  g_lssv_rec lssv_rec_type;
  g_lssv_tbl lssv_tbl_type;

  PROCEDURE CREATE_LINE_STYLE_SOURCES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lssv_rec		    IN lssv_rec_type,
    x_lssv_rec              OUT NOCOPY lssv_rec_type) ;

  PROCEDURE CREATE_LINE_STYLE_SOURCES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lssv_tbl		    IN lssv_tbl_type,
    x_lssv_tbl              OUT NOCOPY lssv_tbl_type) ;

  PROCEDURE UPDATE_LINE_STYLE_SOURCES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lssv_rec		    IN lssv_rec_type,
    x_lssv_rec              OUT NOCOPY lssv_rec_type) ;

  PROCEDURE UPDATE_LINE_STYLE_SOURCES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lssv_tbl		    IN lssv_tbl_type,
    x_lssv_tbl              OUT NOCOPY lssv_tbl_type) ;

  PROCEDURE DELETE_LINE_STYLE_SOURCES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lssv_rec		    IN lssv_rec_type) ;

  PROCEDURE DELETE_LINE_STYLE_SOURCES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lssv_tbl		    IN lssv_tbl_type) ;

  PROCEDURE LOCK_LINE_STYLE_SOURCES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lssv_rec		    IN lssv_rec_type) ;

  PROCEDURE LOCK_LINE_STYLE_SOURCES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lssv_tbl		    IN lssv_tbl_type) ;

  PROCEDURE VALID_LINE_STYLE_SOURCES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lssv_rec		    IN lssv_rec_type) ;

  PROCEDURE VALID_LINE_STYLE_SOURCES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lssv_tbl		    IN lssv_tbl_type) ;

--added by smhanda

 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_VAL_LINE_OPERATION
 --------------------------------------------------------------------------

  SUBTYPE vlov_rec_type is okc_line_styles_pvt.vlov_rec_type;
  SUBTYPE vlov_tbl_type is okc_line_styles_pvt.vlov_tbl_type ;

  g_vlov_rec vlov_rec_type;
  g_vlov_tbl vlov_tbl_type;

  PROCEDURE CREATE_VAL_LINE_OPERATION(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_vlov_rec		    IN vlov_rec_type,
    x_vlov_rec              OUT NOCOPY vlov_rec_type) ;

  PROCEDURE CREATE_VAL_LINE_OPERATION(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_vlov_tbl		    IN vlov_tbl_type,
    x_vlov_tbl              OUT NOCOPY vlov_tbl_type) ;

  PROCEDURE UPDATE_VAL_LINE_OPERATION(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_vlov_rec		    IN vlov_rec_type,
    x_vlov_rec              OUT NOCOPY vlov_rec_type) ;

  PROCEDURE UPDATE_VAL_LINE_OPERATION(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_vlov_tbl		    IN vlov_tbl_type,
    x_vlov_tbl              OUT NOCOPY vlov_tbl_type) ;

  PROCEDURE DELETE_VAL_LINE_OPERATION(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_vlov_rec		    IN vlov_rec_type) ;

  PROCEDURE DELETE_VAL_LINE_OPERATION(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_vlov_tbl		    IN vlov_tbl_type) ;

  PROCEDURE LOCK_VAL_LINE_OPERATION(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_vlov_rec		    IN vlov_rec_type) ;

  PROCEDURE LOCK_VAL_LINE_OPERATION(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_vlov_tbl		    IN vlov_tbl_type) ;

  PROCEDURE VALIDATE_VAL_LINE_OPERATION(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_vlov_rec		    IN vlov_rec_type) ;

  PROCEDURE VALIDATE_VAL_LINE_OPERATION(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_vlov_tbl		    IN vlov_tbl_type) ;


END OKC_LINE_STYLES_PUB;

 

/
