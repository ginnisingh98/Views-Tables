--------------------------------------------------------
--  DDL for Package OKL_VP_K_ARTICLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VP_K_ARTICLE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRCARS.pls 115.2 2002/03/21 18:04:02 pkm ship       $ */
  -- simple entity object subtype definitions migrated through migration api.
SUBTYPE catv_rec_type IS okl_okc_migration_a_pvt.catv_rec_type;
SUBTYPE catv_tbl_type IS okl_okc_migration_a_pvt.catv_tbl_type;

procedure add_language_k_article;
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
function emptyClob return clob;

END; -- Package Specification OKL_VP_K_ARTICLE_PVT

 

/
