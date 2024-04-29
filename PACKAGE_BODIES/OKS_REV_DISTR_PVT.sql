--------------------------------------------------------
--  DDL for Package Body OKS_REV_DISTR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_REV_DISTR_PVT" AS
/* $Header: OKSCRDSB.pls 120.0 2005/05/25 18:11:29 appldev noship $ */

  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKS_REV_DISTR_PVT';
  G_CHILD_RECORD_FOUND        CONSTANT   varchar2(200) := 'OKC_CHILD_RECORD_FOUND';
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;


procedure create_Revenue_Distr(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_rdsv_rec	IN	rdsv_rec_type,
                              x_rdsv_rec	OUT NOCOPY	rdsv_rec_type) is
begin
  oks_rds_pvt.insert_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_rdsv_rec      => p_rdsv_rec,
                         x_rdsv_rec      => x_rdsv_rec);
--V
  if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
    return;
  end if;
end create_Revenue_Distr;


procedure update_Revenue_Distr(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_rdsv_rec	IN	rdsv_rec_type,
                              x_rdsv_rec	OUT NOCOPY	rdsv_rec_type) is
begin
  oks_rds_pvt.update_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_rdsv_rec      => p_rdsv_rec,
                         x_rdsv_rec      => x_rdsv_rec);
--V
  if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
    return;
  end if;
end update_Revenue_Distr;




procedure delete_Revenue_Distr(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_rdsv_rec	IN	rdsv_rec_type) is
begin
  oks_rds_pvt.delete_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_rdsv_rec      => p_rdsv_rec);
--V
  if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
    return;
  end if;
exception
    WHEN OTHERS THEN
	NULL;
end delete_Revenue_Distr;


procedure lock_Revenue_Distr(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_rdsv_rec	IN	rdsv_rec_type) is
begin
  oks_rds_pvt.lock_row(p_api_version   => p_api_version,
                       p_init_msg_list => p_init_msg_list,
                       x_msg_count     => x_msg_count,
                       x_msg_data      => x_msg_data,
                       x_return_status => x_return_status,
                       p_rdsv_rec      => p_rdsv_rec);
end lock_Revenue_Distr;



procedure validate_Revenue_Distr(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_rdsv_rec	IN	rdsv_rec_type) is
begin
  oks_rds_pvt.validate_row(p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           x_return_status => x_return_status,
                           p_rdsv_rec      => p_rdsv_rec);
end validate_Revenue_Distr;


END OKS_REV_DISTR_PVT ;

/
