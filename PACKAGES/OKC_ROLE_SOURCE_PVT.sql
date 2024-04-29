--------------------------------------------------------
--  DDL for Package OKC_ROLE_SOURCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_ROLE_SOURCE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCCRSCS.pls 120.0 2005/05/26 09:36:02 appldev noship $ */
  -- simple entity object subtype definitions
  subtype rscv_rec_type is OKC_RSC_PVT.rscv_rec_type;
  subtype rscv_tbl_type is OKC_RSC_PVT.rscv_tbl_type;
  subtype csov_rec_type is OKC_CSO_PVT.csov_rec_type;
  subtype csov_tbl_type is OKC_CSO_PVT.csov_tbl_type;

  -- public procedure declarations
  -- for use by OKC_role_source_PUB public PL/SQL API
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
END OKC_ROLE_SOURCE_PVT;

 

/
