--------------------------------------------------------
--  DDL for Package OKL_VP_K_ARTICLE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VP_K_ARTICLE_PUB" AUTHID CURRENT_USER AS
/*$Header: OKLPCARS.pls 120.1 2005/08/04 01:30:27 manumanu noship $*/
-- simple entity object subtype definitions
SUBTYPE catv_rec_type is OKL_VP_K_ARTICLE_PVT.catv_rec_type;
SUBTYPE catv_tbl_type is OKL_VP_K_ARTICLE_PVT.catv_tbl_type;

-- global variables for user hooks
g_catv_rec 			catv_rec_type;

  -- public procedure declarations
procedure add_language;
procedure create_k_article(p_api_version	IN	NUMBER,
                           p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                           x_return_status	OUT NOCOPY	VARCHAR2,
                           x_msg_count	OUT NOCOPY	NUMBER,
                           x_msg_data	OUT NOCOPY	VARCHAR2,
                           p_catv_rec	IN	catv_rec_type,
                           x_catv_rec	OUT NOCOPY	catv_rec_type);

procedure update_k_article(p_api_version	IN	NUMBER,
                           p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                           x_return_status	OUT NOCOPY	VARCHAR2,
                           x_msg_count	OUT NOCOPY	NUMBER,
                           x_msg_data	OUT NOCOPY	VARCHAR2,
                           p_catv_rec	IN	catv_rec_type,
                           x_catv_rec	OUT NOCOPY	catv_rec_type);

procedure delete_k_article(p_api_version	IN	NUMBER,
                           p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                           x_return_status	OUT NOCOPY	VARCHAR2,
                           x_msg_count	OUT NOCOPY	NUMBER,
                           x_msg_data	OUT NOCOPY	VARCHAR2,
                           p_catv_rec	IN	catv_rec_type);


procedure create_k_article(p_api_version	IN	NUMBER,
                           p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                           x_return_status	OUT NOCOPY	VARCHAR2,
                           x_msg_count	OUT NOCOPY	NUMBER,
                           x_msg_data	OUT NOCOPY	VARCHAR2,
                           p_catv_tbl	IN	catv_tbl_type,
                           x_catv_tbl	OUT NOCOPY	catv_tbl_type);

procedure update_k_article(p_api_version	IN	NUMBER,
                           p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                           x_return_status	OUT NOCOPY	VARCHAR2,
                           x_msg_count	OUT NOCOPY	NUMBER,
                           x_msg_data	OUT NOCOPY	VARCHAR2,
                           p_catv_tbl	IN	catv_tbl_type,
                           x_catv_tbl	OUT NOCOPY	catv_tbl_type);

procedure delete_k_article(p_api_version	IN	NUMBER,
                           p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                           x_return_status	OUT NOCOPY	VARCHAR2,
                           x_msg_count	OUT NOCOPY	NUMBER,
                           x_msg_data	OUT NOCOPY	VARCHAR2,
                           p_catv_tbl	IN	catv_tbl_type);


function std_art_name(p_sav_sae_id IN NUMBER) return varchar2;

FUNCTION Copy_Articles_Text(p_id NUMBER,lang VARCHAR2,p_text VARCHAR2 ) RETURN VARCHAR2;

END; -- Package Specification OKL_VP_K_ARTICLE_PUB

 

/
