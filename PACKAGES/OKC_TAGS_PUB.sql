--------------------------------------------------------
--  DDL for Package OKC_TAGS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_TAGS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKCPTAGS.pls 120.2 2006/02/28 14:49:30 smallya noship $ */

  subtype tagv_rec_type is OKC_TAG_PVT.tagv_rec_type;

  TYPE tagv_tbl_type IS TABLE OF tagv_rec_type
        INDEX BY BINARY_INTEGER;

  PROCEDURE add_language;

  procedure create_tag(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_tagv_rec	IN	tagv_rec_type,
                              x_tagv_rec	OUT NOCOPY	tagv_rec_type);
  procedure create_tag(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_tagv_tbl	IN	tagv_tbl_type,
                              x_tagv_tbl	OUT NOCOPY	tagv_tbl_type);

  procedure update_tag(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_tagv_rec	IN	tagv_rec_type,
                              x_tagv_rec	OUT NOCOPY	tagv_rec_type);
  procedure update_tag(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_tagv_tbl	IN	tagv_tbl_type,
                              x_tagv_tbl	OUT NOCOPY	tagv_tbl_type);

  procedure delete_tag(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_tagv_rec	IN	tagv_rec_type);
  procedure delete_tag(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_tagv_tbl	IN	tagv_tbl_type);

  procedure lock_tag(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_tagv_rec	IN	tagv_rec_type);
  procedure lock_tag(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_tagv_tbl	IN	tagv_tbl_type);

END OKC_TAGS_PUB;

 

/
