--------------------------------------------------------
--  DDL for Package OKC_CONTRACT_PARTY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CONTRACT_PARTY_PUB" AUTHID CURRENT_USER as
/* $Header: OKCPCPLS.pls 120.0 2005/05/25 18:52:37 appldev noship $ */
  -- complex entity object subtype definitions
  subtype ctcv_rec_type is OKC_CONTRACT_PARTY_PVT.ctcv_rec_type;
  subtype ctcv_tbl_type is OKC_CONTRACT_PARTY_PVT.ctcv_tbl_type;
  subtype cplv_rec_type is OKC_CONTRACT_PARTY_PVT.cplv_rec_type;
  subtype cplv_tbl_type is OKC_CONTRACT_PARTY_PVT.cplv_tbl_type;
  -- global variables
  g_ctcv_rec 			ctcv_rec_type;
  g_cplv_rec 			cplv_rec_type;
  -- public procedure declarations
procedure create_contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_ctcv_rec	IN	ctcv_rec_type,
                              x_ctcv_rec	OUT NOCOPY	ctcv_rec_type);
procedure create_contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_ctcv_tbl	IN	ctcv_tbl_type,
                              x_ctcv_tbl	OUT NOCOPY	ctcv_tbl_type);
procedure update_contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_ctcv_rec	IN	ctcv_rec_type,
                              x_ctcv_rec	OUT NOCOPY	ctcv_rec_type);
procedure update_contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_ctcv_tbl	IN	ctcv_tbl_type,
                              x_ctcv_tbl	OUT NOCOPY	ctcv_tbl_type);
procedure delete_contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_ctcv_rec	IN	ctcv_rec_type);
procedure delete_contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_ctcv_tbl	IN	ctcv_tbl_type);
procedure lock_contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_ctcv_rec	IN	ctcv_rec_type);
procedure lock_contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_ctcv_tbl	IN	ctcv_tbl_type);
procedure validate_contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_ctcv_rec	IN	ctcv_rec_type);
procedure validate_contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_ctcv_tbl	IN	ctcv_tbl_type);
procedure create_k_party_role(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cplv_rec	IN	cplv_rec_type,
                              x_cplv_rec	OUT NOCOPY	cplv_rec_type);
procedure create_k_party_role(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cplv_tbl	IN	cplv_tbl_type,
                              x_cplv_tbl	OUT NOCOPY	cplv_tbl_type);
procedure update_k_party_role(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cplv_rec	IN	cplv_rec_type,
                              x_cplv_rec	OUT NOCOPY	cplv_rec_type);
procedure update_k_party_role(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cplv_tbl	IN	cplv_tbl_type,
                              x_cplv_tbl	OUT NOCOPY	cplv_tbl_type);
procedure delete_k_party_role(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cplv_rec	IN	cplv_rec_type);
procedure delete_k_party_role(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cplv_tbl	IN	cplv_tbl_type);
procedure lock_k_party_role(p_api_version	IN	NUMBER,
                            p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                            p_cplv_rec	IN	cplv_rec_type);
procedure lock_k_party_role(p_api_version	IN	NUMBER,
                            p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                            p_cplv_tbl	IN	cplv_tbl_type);
procedure validate_k_party_role(p_api_version	IN	NUMBER,
                                p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                                p_cplv_rec	IN	cplv_rec_type);
procedure validate_k_party_role(p_api_version	IN	NUMBER,
                                p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                                p_cplv_tbl	IN	cplv_tbl_type);
procedure add_language;

end OKC_CONTRACT_PARTY_PUB;

 

/
