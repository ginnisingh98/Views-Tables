--------------------------------------------------------
--  DDL for Package OKC_CHANGE_REQUEST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CHANGE_REQUEST_PVT" AUTHID CURRENT_USER as
/* $Header: OKCCCRTS.pls 120.0 2005/05/26 09:56:51 appldev noship $ */

  -- simple entity object subtype definitions
  subtype crtv_rec_type is OKC_CRT_PVT.crtv_rec_type;
  subtype crtv_tbl_type is OKC_CRT_PVT.crtv_tbl_type;
  subtype corv_rec_type is OKC_COR_PVT.corv_rec_type;
  subtype corv_tbl_type is OKC_COR_PVT.corv_tbl_type;
  subtype cprv_rec_type is OKC_CPR_PVT.cprv_rec_type;
  subtype cprv_tbl_type is OKC_CPR_PVT.cprv_tbl_type;

  -- public procedure declarations
  -- for use by OKC_CHANGE_REQUEST_PUB public PL/SQL API
procedure add_language_change_request;
procedure add_language_change;
procedure create_change_request(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_crtv_rec	IN	crtv_rec_type,
                              x_crtv_rec	OUT NOCOPY	crtv_rec_type);
procedure update_change_request(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_crtv_rec	IN	crtv_rec_type,
                              x_crtv_rec	OUT NOCOPY	crtv_rec_type);
procedure delete_change_request(p_api_version	 IN	NUMBER,
                         p_init_msg_list IN	VARCHAR2 default OKC_API.G_FALSE,
                         x_return_status OUT NOCOPY	VARCHAR2,
                         x_msg_count	 OUT NOCOPY	NUMBER,
                         x_msg_data	 OUT NOCOPY	VARCHAR2,
                         p_crtv_rec	 IN	crtv_rec_type);
procedure lock_change_request(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
    					p_restricted IN VARCHAR2 default OKC_API.G_TRUE,
                              p_crtv_rec	IN	crtv_rec_type);
procedure validate_change_request(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_crtv_rec	IN	crtv_rec_type);
procedure create_change(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_corv_rec	IN	corv_rec_type,
                              x_corv_rec	OUT NOCOPY	corv_rec_type);
procedure update_change(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_corv_rec	IN	corv_rec_type,
                              x_corv_rec	OUT NOCOPY	corv_rec_type);
procedure delete_change(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_corv_rec	IN	corv_rec_type);
procedure lock_change(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_corv_rec	IN	corv_rec_type);
procedure validate_change(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_corv_rec	IN	corv_rec_type);
procedure create_change_party_role(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cprv_rec	IN	cprv_rec_type,
                              x_cprv_rec	OUT NOCOPY	cprv_rec_type);
procedure update_change_party_role(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cprv_rec	IN	cprv_rec_type,
                              x_cprv_rec	OUT NOCOPY	cprv_rec_type);
procedure delete_change_party_role(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cprv_rec	IN	cprv_rec_type);
procedure lock_change_party_role(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cprv_rec	IN	cprv_rec_type);
procedure validate_change_party_role(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cprv_rec	IN	cprv_rec_type);
end OKC_CHANGE_REQUEST_PVT;

 

/
