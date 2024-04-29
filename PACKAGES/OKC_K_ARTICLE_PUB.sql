--------------------------------------------------------
--  DDL for Package OKC_K_ARTICLE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_K_ARTICLE_PUB" AUTHID CURRENT_USER as
/*$Header: OKCPCATS.pls 120.0 2005/05/25 23:05:05 appldev noship $*/
  -- simple entity object subtype definitions
  subtype catv_rec_type is OKC_K_ARTICLE_PVT.catv_rec_type;
  subtype catv_tbl_type is OKC_K_ARTICLE_PVT.catv_tbl_type;
  subtype atnv_rec_type is OKC_K_ARTICLE_PVT.atnv_rec_type;
  subtype atnv_tbl_type is OKC_K_ARTICLE_PVT.atnv_tbl_type;

  -- global variables for user hooks
  g_catv_rec 			catv_rec_type;
  g_atnv_rec 			atnv_rec_type;

  -- public procedure declarations
procedure add_language;
procedure create_k_article(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_catv_rec	IN	catv_rec_type,
                              x_catv_rec	OUT NOCOPY	catv_rec_type);
procedure lock_k_article(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_catv_rec	IN	catv_rec_type);
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
procedure validate_k_article(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_catv_rec	IN	catv_rec_type);
procedure create_article_translation(p_api_version	 IN	NUMBER,
                         p_init_msg_list IN	VARCHAR2 default OKC_API.G_FALSE,
                         x_return_status OUT NOCOPY	VARCHAR2,
                         x_msg_count	 OUT NOCOPY	NUMBER,
                         x_msg_data	 OUT NOCOPY	VARCHAR2,
                         p_atnv_rec	 IN	atnv_rec_type,
                         x_atnv_rec	 OUT NOCOPY	atnv_rec_type);
procedure lock_article_translation(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_atnv_rec	IN	atnv_rec_type);
procedure delete_article_translation(p_api_version	 IN	NUMBER,
                         p_init_msg_list IN	VARCHAR2 default OKC_API.G_FALSE,
                         x_return_status OUT NOCOPY	VARCHAR2,
                         x_msg_count	 OUT NOCOPY	NUMBER,
                         x_msg_data	 OUT NOCOPY	VARCHAR2,
                         p_atnv_rec	 IN	atnv_rec_type);
procedure validate_article_translation(p_api_version   IN	NUMBER,
                           p_init_msg_list IN	VARCHAR2 default OKC_API.G_FALSE,
                           x_return_status OUT NOCOPY	VARCHAR2,
                           x_msg_count	   OUT NOCOPY	NUMBER,
                           x_msg_data	   OUT NOCOPY	VARCHAR2,
                           p_atnv_rec	   IN	atnv_rec_type);
procedure create_k_article(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_catv_tbl	IN	catv_tbl_type,
                              x_catv_tbl	OUT NOCOPY	catv_tbl_type);
procedure lock_k_article(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_catv_tbl	IN	catv_tbl_type);
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
procedure validate_k_article(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_catv_tbl	IN	catv_tbl_type);
procedure create_article_translation(p_api_version	 IN	NUMBER,
                         p_init_msg_list IN	VARCHAR2 default OKC_API.G_FALSE,
                         x_return_status OUT NOCOPY	VARCHAR2,
                         x_msg_count	 OUT NOCOPY	NUMBER,
                         x_msg_data	 OUT NOCOPY	VARCHAR2,
                         p_atnv_tbl	 IN	atnv_tbl_type,
                         x_atnv_tbl	 OUT NOCOPY	atnv_tbl_type);
procedure lock_article_translation(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_atnv_tbl	IN	atnv_tbl_type);
procedure delete_article_translation(p_api_version	 IN	NUMBER,
                         p_init_msg_list IN	VARCHAR2 default OKC_API.G_FALSE,
                         x_return_status OUT NOCOPY	VARCHAR2,
                         x_msg_count	 OUT NOCOPY	NUMBER,
                         x_msg_data	 OUT NOCOPY	VARCHAR2,
                         p_atnv_tbl	 IN	atnv_tbl_type);
procedure validate_article_translation(p_api_version   IN	NUMBER,
                           p_init_msg_list IN	VARCHAR2 default OKC_API.G_FALSE,
                           x_return_status OUT NOCOPY	VARCHAR2,
                           x_msg_count	   OUT NOCOPY	NUMBER,
                           x_msg_data	   OUT NOCOPY	VARCHAR2,
                           p_atnv_tbl	   IN	atnv_tbl_type);
function std_art_name(p_sav_sae_id IN NUMBER) return varchar2;

  FUNCTION get_rec (
    p_id                     IN NUMBER,
    p_major_version          IN NUMBER := NULL,
    x_no_data_found          OUT NOCOPY BOOLEAN
  ) RETURN catv_rec_type;
  FUNCTION get_rec (
    p_id                     IN NUMBER,
    p_major_version          IN NUMBER := NULL
  ) RETURN catv_rec_type;

end OKC_K_ARTICLE_PUB;

 

/
