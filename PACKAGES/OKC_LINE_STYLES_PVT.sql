--------------------------------------------------------
--  DDL for Package OKC_LINE_STYLES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_LINE_STYLES_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCCLSES.pls 120.0 2005/05/25 22:45:35 appldev noship $ */
 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_LINE_STYLES
 --------------------------------------------------------------------------

 G_UNEXPECTED_ERROR           CONSTANT   varchar2(200) := 'OKC_UNEXPECTED_ERROR';
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKC_LINE_STYTLES_PVT';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_SQLERRM_TOKEN              CONSTANT   varchar2(200) := 'ERROR_MESSAGE';
 G_SQLCODE_TOKEN              CONSTANT   varchar2(200) := 'ERROR_CODE';
  SUBTYPE lsev_rec_type is okc_lse_pvt.lsev_rec_type;


  PROCEDURE add_language;

  PROCEDURE CREATE_LINE_STYLES(
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
    p_lsev_rec		    IN lsev_rec_type,
    x_lsev_rec              OUT NOCOPY lsev_rec_type) ;

  PROCEDURE DELETE_LINE_STYLES(
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
    p_lsev_rec		    IN lsev_rec_type) ;

  PROCEDURE VALID_LINE_STYLES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lsev_rec		    IN lsev_rec_type) ;

 FUNCTION USED_IN_K_LINES(p_id IN NUMBER) RETURN VARCHAR2;
 FUNCTION USED_IN_SETUPS(p_id IN NUMBER) RETURN VARCHAR2;
 FUNCTION USED_IN_SRC_OPS(p_id IN NUMBER) RETURN VARCHAR2;
 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_LINE_STYLE_SOURCES
 --------------------------------------------------------------------------

  SUBTYPE lssv_rec_type is okc_lss_pvt.lssv_rec_type;

  PROCEDURE CREATE_LINE_STYLE_SOURCES(
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
    p_lssv_rec		    IN lssv_rec_type,
    x_lssv_rec              OUT NOCOPY lssv_rec_type) ;

  PROCEDURE DELETE_LINE_STYLE_SOURCES(
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
    p_lssv_rec		    IN lssv_rec_type) ;

  PROCEDURE VALID_LINE_STYLE_SOURCES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lssv_rec		    IN lssv_rec_type) ;


-- following code added by smhanda
 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_VALID_LINE_OPERATIONS
 --------------------------------------------------------------------------

  SUBTYPE vlov_rec_type is okc_vlo_pvt.vlov_rec_type;
  SUBTYPE vlov_tbl_type is okc_vlo_pvt.vlov_tbl_type;

  PROCEDURE CREATE_VAL_LINE_OPERATION(
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
    p_vlov_rec		    IN vlov_rec_type,
    x_vlov_rec              OUT NOCOPY vlov_rec_type) ;

  PROCEDURE DELETE_VAL_LINE_OPERATION(
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
    p_vlov_rec		    IN vlov_rec_type) ;

  PROCEDURE VALIDATE_VAL_LINE_OPERATION(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_vlov_rec		    IN vlov_rec_type) ;


END OKC_LINE_STYLES_PVT;

 

/
