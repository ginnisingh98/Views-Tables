--------------------------------------------------------
--  DDL for Package OKC_K_ARTICLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_K_ARTICLE_PVT" AUTHID CURRENT_USER as
/* $Header: OKCCCATS.pls 120.0 2005/05/25 22:59:33 appldev noship $ */

  -- simple entity object subtype definitions
  subtype catv_rec_type is OKC_CAT_PVT.catv_rec_type;
  subtype catv_tbl_type is OKC_CAT_PVT.catv_tbl_type;
  subtype atnv_rec_type is OKC_ATN_PVT.atnv_rec_type;
  subtype atnv_tbl_type is OKC_ATN_PVT.atnv_tbl_type;

  -- public procedure declarations
  -- for use by OKC_K_ARTICLE_PUB public PL/SQL API
procedure add_language_k_article;
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
end OKC_K_ARTICLE_PVT;

 

/
