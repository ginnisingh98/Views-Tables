--------------------------------------------------------
--  DDL for Package OKS_ORDER_CONTACTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_ORDER_CONTACTS_PVT" AUTHID CURRENT_USER as
/* $Header: OKSCCOCS.pls 120.0 2005/05/25 17:59:10 appldev noship $ */

  -- simple entity object subtype definitions
  subtype cocv_rec_type is OKS_COC_PVT.cocv_rec_type;
  subtype cocv_tbl_type is OKS_COC_PVT.cocv_tbl_type;

  -- public procedure declarations
procedure create_Order_Contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cocv_rec	IN	cocv_rec_type,
                              x_cocv_rec	OUT NOCOPY	cocv_rec_type);
procedure update_Order_Contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cocv_rec	IN	cocv_rec_type,
                              x_cocv_rec	OUT NOCOPY	cocv_rec_type);
procedure delete_Order_Contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cocv_rec	IN	cocv_rec_type);
procedure lock_Order_Contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cocv_rec	IN	cocv_rec_type);
procedure validate_Order_Contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cocv_rec	IN	cocv_rec_type);
end OKS_ORDER_Contacts_PVT;

 

/
