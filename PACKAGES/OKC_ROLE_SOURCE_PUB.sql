--------------------------------------------------------
--  DDL for Package OKC_ROLE_SOURCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_ROLE_SOURCE_PUB" AUTHID CURRENT_USER AS
/* $Header: OKCPRSCS.pls 120.0 2005/05/25 18:48:59 appldev noship $ */

  -- simple entity object subtype definitions
  subtype rscv_rec_type is OKC_RSC_PVT.rscv_rec_type;
  subtype rscv_tbl_type is OKC_RSC_PVT.rscv_tbl_type;
  subtype csov_rec_type is OKC_CSO_PVT.csov_rec_type;
  subtype csov_tbl_type is OKC_CSO_PVT.csov_tbl_type;

  -- global variables
  g_rscv_rec 			rscv_rec_type;
  g_csov_rec 			csov_rec_type;

  -- public procedure declarations
function contact_role_meaning(p_cro_code in varchar2) return varchar2;
function source_name(p_jtot_object_code in varchar2) return varchar2;
procedure one_role_source_atime(x_return_status	OUT NOCOPY	VARCHAR2,
					p_rle_code in varchar2);
procedure one_contact_source_atime(x_return_status	OUT NOCOPY	VARCHAR2,
					p_rle_code in varchar2);
procedure create_role_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_rscv_rec	IN	rscv_rec_type,
                              x_rscv_rec	OUT NOCOPY	rscv_rec_type);
procedure update_role_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_rscv_rec	IN	rscv_rec_type,
                              x_rscv_rec	OUT NOCOPY	rscv_rec_type);
procedure lock_role_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_rscv_rec	IN	rscv_rec_type);
procedure validate_role_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_rscv_rec	IN	rscv_rec_type);
--
procedure create_contact_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_csov_rec	IN	csov_rec_type,
                              x_csov_rec	OUT NOCOPY	csov_rec_type);
procedure update_contact_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_csov_rec	IN	csov_rec_type,
                              x_csov_rec	OUT NOCOPY	csov_rec_type);
procedure lock_contact_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_csov_rec	IN	csov_rec_type);
procedure validate_contact_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_csov_rec	IN	csov_rec_type);
procedure create_role_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_rscv_tbl	IN	rscv_tbl_type,
                              x_rscv_tbl	OUT NOCOPY	rscv_tbl_type);
procedure update_role_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_rscv_tbl	IN	rscv_tbl_type,
                              x_rscv_tbl	OUT NOCOPY	rscv_tbl_type);
procedure lock_role_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_rscv_tbl	IN	rscv_tbl_type);
procedure validate_role_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_rscv_tbl	IN	rscv_tbl_type);
--
procedure create_contact_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_csov_tbl	IN	csov_tbl_type,
                              x_csov_tbl	OUT NOCOPY	csov_tbl_type);
procedure update_contact_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_csov_tbl	IN	csov_tbl_type,
                              x_csov_tbl	OUT NOCOPY	csov_tbl_type);
procedure lock_contact_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_csov_tbl	IN	csov_tbl_type);
procedure validate_contact_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_csov_tbl	IN	csov_tbl_type);
END OKC_ROLE_SOURCE_PUB;

 

/
