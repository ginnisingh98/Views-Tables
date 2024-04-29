--------------------------------------------------------
--  DDL for Package OKS_DEFAULTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_DEFAULTS_PVT" AUTHID CURRENT_USER as
/* $Header: OKSCCDTS.pls 120.0 2005/05/25 17:55:21 appldev noship $ */

  -- simple entity object subtype definitions
  subtype cdtv_rec_type is OKS_cdt_PVT.cdtv_rec_type;
  subtype cdtv_tbl_type is OKS_cdt_PVT.cdtv_tbl_type;

  -- public procedure declarations
procedure INSERT_DEFAULTS(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cdtv_rec	IN	cdtv_rec_type,
                              x_cdtv_rec	OUT NOCOPY	cdtv_rec_type);
procedure update_defaults(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cdtv_rec	IN	cdtv_rec_type,
                              x_cdtv_rec	OUT NOCOPY	cdtv_rec_type);
procedure delete_defaults(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cdtv_rec	IN	cdtv_rec_type);
procedure lock_defaults(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cdtv_rec	IN	cdtv_rec_type);
procedure validate_defaults(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cdtv_rec	IN	cdtv_rec_type);
end OKS_DEFAULTS_PVT ;

 

/
