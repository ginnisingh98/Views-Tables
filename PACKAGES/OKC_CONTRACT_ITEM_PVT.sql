--------------------------------------------------------
--  DDL for Package OKC_CONTRACT_ITEM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CONTRACT_ITEM_PVT" AUTHID CURRENT_USER as
/* $Header: OKCCCIMS.pls 120.0 2005/05/25 18:30:42 appldev noship $ */

  -- simple entity object subtype definitions
  subtype cimv_rec_type is OKC_CIM_PVT.cimv_rec_type;
  subtype cimv_tbl_type is OKC_CIM_PVT.cimv_tbl_type;

  -- public procedure declarations
  -- for use by OKC_CONTRACT_ITEM_PUB public PL/SQL API
procedure create_contract_item(p_api_version	IN	NUMBER,
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
                              p_cimv_rec	IN	cimv_rec_type,
                              x_cimv_rec	OUT NOCOPY	cimv_rec_type);
procedure delete_contract_item(p_api_version	IN	NUMBER,
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
                              p_cimv_rec	IN	cimv_rec_type);
procedure validate_contract_item(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cimv_rec	IN	cimv_rec_type);
end OKC_CONTRACT_ITEM_PVT;

 

/
