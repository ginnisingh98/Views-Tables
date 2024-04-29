--------------------------------------------------------
--  DDL for Package OKL_CONTRACT_PARTY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CONTRACT_PARTY_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPCPCS.pls 115.5 2002/03/21 18:03:33 pkm ship       $ */
-- complex entity object subtype definitions
SUBTYPE ctcv_rec_type is OKL_CONTRACT_PARTY_PVT.ctcv_rec_type;
SUBTYPE ctcv_tbl_type is OKL_CONTRACT_PARTY_PVT.ctcv_tbl_type;
SUBTYPE cplv_rec_type is OKL_CONTRACT_PARTY_PVT.cplv_rec_type;
SUBTYPE cplv_tbl_type is OKL_CONTRACT_PARTY_PVT.cplv_tbl_type;
-- global variables
g_ctcv_rec 			ctcv_rec_type;
g_cplv_rec 			cplv_rec_type;
-- public procedure declarations
PROCEDURE create_contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_ctcv_rec	IN	ctcv_rec_type,
                              x_ctcv_rec	OUT NOCOPY	ctcv_rec_type);
PROCEDURE create_contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_ctcv_tbl	IN	ctcv_tbl_type,
                              x_ctcv_tbl	OUT NOCOPY	ctcv_tbl_type);
PROCEDURE update_contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_ctcv_rec	IN	ctcv_rec_type,
                              x_ctcv_rec	OUT NOCOPY	ctcv_rec_type);
PROCEDURE update_contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_ctcv_tbl	IN	ctcv_tbl_type,
                              x_ctcv_tbl	OUT NOCOPY	ctcv_tbl_type);
PROCEDURE delete_contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_ctcv_rec	IN	ctcv_rec_type);
PROCEDURE delete_contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_ctcv_tbl	IN	ctcv_tbl_type);

PROCEDURE create_k_party_role(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cplv_rec	IN	cplv_rec_type,
                              x_cplv_rec	OUT NOCOPY	cplv_rec_type);
PROCEDURE create_k_party_role(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cplv_tbl	IN	cplv_tbl_type,
                              x_cplv_tbl	OUT NOCOPY	cplv_tbl_type);
PROCEDURE update_k_party_role(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cplv_rec	IN	cplv_rec_type,
                              x_cplv_rec	OUT NOCOPY	cplv_rec_type);
PROCEDURE update_k_party_role(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cplv_tbl	IN	cplv_tbl_type,
                              x_cplv_tbl	OUT NOCOPY	cplv_tbl_type);
PROCEDURE delete_k_party_role(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cplv_rec	IN	cplv_rec_type);
PROCEDURE delete_k_party_role(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cplv_tbl	IN	cplv_tbl_type);

END; -- Package Specification OKL_CONTRACT_PARTY_PUB

 

/
