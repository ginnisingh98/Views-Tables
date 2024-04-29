--------------------------------------------------------
--  DDL for Package OKC_CONTRACT_ITEM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CONTRACT_ITEM_PUB" AUTHID CURRENT_USER as
/* $Header: OKCPCIMS.pls 120.0 2005/05/25 19:22:21 appldev noship $ */

  -- simple entity object subtype definitions
  subtype cimv_rec_type is OKC_CONTRACT_ITEM_PVT.cimv_rec_type;
  subtype cimv_tbl_type is OKC_CONTRACT_ITEM_PVT.cimv_tbl_type;

  -- global variables
  g_cimv_rec 			cimv_rec_type;

  -- public procedure declarations
procedure create_contract_item(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cimv_rec	IN	cimv_rec_type,
                              x_cimv_rec	OUT NOCOPY	cimv_rec_type);
procedure create_contract_item(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cimv_tbl	IN	cimv_tbl_type,
                              x_cimv_tbl	OUT NOCOPY	cimv_tbl_type);
procedure update_contract_item(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cimv_rec	IN	cimv_rec_type,
                              x_cimv_rec	OUT NOCOPY	cimv_rec_type);
procedure update_contract_item(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cimv_tbl	IN	cimv_tbl_type,
                              x_cimv_tbl	OUT NOCOPY	cimv_tbl_type);
procedure delete_contract_item(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cimv_rec	IN	cimv_rec_type);
procedure delete_contract_item(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cimv_tbl	IN	cimv_tbl_type);
procedure lock_contract_item(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cimv_rec	IN	cimv_rec_type);
procedure lock_contract_item(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cimv_tbl	IN	cimv_tbl_type);
procedure validate_contract_item(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cimv_rec	IN	cimv_rec_type);
procedure validate_contract_item(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cimv_tbl	IN	cimv_tbl_type);
end OKC_CONTRACT_ITEM_PUB;

 

/
