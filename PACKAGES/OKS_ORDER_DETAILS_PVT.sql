--------------------------------------------------------
--  DDL for Package OKS_ORDER_DETAILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_ORDER_DETAILS_PVT" AUTHID CURRENT_USER as
/* $Header: OKSCCODS.pls 120.0 2005/05/25 22:32:07 appldev noship $ */

  -- simple entity object subtype definitions
  subtype codv_rec_type is OKS_cod_PVT.codv_rec_type;
  subtype codv_tbl_type is OKS_cod_PVT.codv_tbl_type;

  -- public procedure declarations
procedure create_Order_Detail(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_codv_rec	IN	codv_rec_type,
                              x_codv_rec	OUT NOCOPY	codv_rec_type);
procedure update_Order_Detail(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_codv_rec	IN	codv_rec_type,
                              x_codv_rec	OUT NOCOPY	codv_rec_type);
procedure delete_Order_Detail(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_codv_rec	IN	codv_rec_type);
procedure lock_Order_Detail(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_codv_rec	IN	codv_rec_type);
procedure validate_Order_Detail(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_codv_rec	IN	codv_rec_type);
end OKS_ORDER_DETAILS_PVT;

 

/
