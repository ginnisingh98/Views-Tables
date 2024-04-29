--------------------------------------------------------
--  DDL for Package OKS_REV_DISTR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_REV_DISTR_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSCRDSS.pls 120.0 2005/05/25 18:01:48 appldev noship $ */

  -- simple entity object subtype definitions
  subtype rdsv_rec_type is OKS_rds_PVT.rdsv_rec_type;
  subtype rdsv_tbl_type is OKS_rds_PVT.rdsv_tbl_type;

  -- public procedure declarations
procedure create_Revenue_Distr(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_rdsv_rec	IN	rdsv_rec_type,
                              x_rdsv_rec	OUT NOCOPY	rdsv_rec_type);
procedure update_Revenue_Distr(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_rdsv_rec	IN	rdsv_rec_type,
                              x_rdsv_rec	OUT NOCOPY	rdsv_rec_type);
procedure delete_Revenue_Distr(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_rdsv_rec	IN	rdsv_rec_type);
procedure lock_Revenue_Distr(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_rdsv_rec	IN	rdsv_rec_type);
procedure validate_Revenue_Distr(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_rdsv_rec	IN	rdsv_rec_type);


END OKS_REV_DISTR_PVT ;



 

/
