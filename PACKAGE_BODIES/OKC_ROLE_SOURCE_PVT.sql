--------------------------------------------------------
--  DDL for Package Body OKC_ROLE_SOURCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_ROLE_SOURCE_PVT" AS
/* $Header: OKCCRSCB.pls 120.0 2005/05/26 09:40:35 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_ROLE_SOURCES_PVT';

-- Start of comments
--
-- Procedure Name  : create_role_source
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure create_role_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_rscv_rec	IN	rscv_rec_type,
                              x_rscv_rec	OUT NOCOPY	rscv_rec_type) is
begin
  okc_rsc_pvt.insert_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_rscv_rec      => p_rscv_rec,
                         x_rscv_rec      => x_rscv_rec);
end create_role_source;

-- Start of comments
--
-- Procedure Name  : update_role_source
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure update_role_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_rscv_rec	IN	rscv_rec_type,
                              x_rscv_rec	OUT NOCOPY	rscv_rec_type) is
begin
  okc_rsc_pvt.update_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_rscv_rec      => p_rscv_rec,
                         x_rscv_rec      => x_rscv_rec);
end update_role_source;

-- Start of comments
--
-- Procedure Name  : lock_role_source
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure lock_role_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_rscv_rec	IN	rscv_rec_type) is
begin
  okc_rsc_pvt.lock_row(p_api_version   => p_api_version,
                       p_init_msg_list => p_init_msg_list,
                       x_msg_count     => x_msg_count,
                       x_msg_data      => x_msg_data,
                       x_return_status => x_return_status,
                       p_rscv_rec      => p_rscv_rec);
end lock_role_source;

-- Start of comments
--
-- Procedure Name  : validate_role_source
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_role_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_rscv_rec	IN	rscv_rec_type) is
begin
  okc_rsc_pvt.validate_row(p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           x_return_status => x_return_status,
                           p_rscv_rec      => p_rscv_rec);
end validate_role_source;

-- Start of comments
--
-- Procedure Name  : create_contact_source
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure create_contact_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_csov_rec	IN	csov_rec_type,
                              x_csov_rec	OUT NOCOPY	csov_rec_type) is
begin
  okc_cso_pvt.insert_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_csov_rec      => p_csov_rec,
                         x_csov_rec      => x_csov_rec);
end create_contact_source;

-- Start of comments
--
-- Procedure Name  : update_contact_source
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure update_contact_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_csov_rec	IN	csov_rec_type,
                              x_csov_rec	OUT NOCOPY	csov_rec_type) is
begin
  okc_cso_pvt.update_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_csov_rec      => p_csov_rec,
                         x_csov_rec      => x_csov_rec);
end update_contact_source;

-- Start of comments
--
-- Procedure Name  : lock_contact_source
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure lock_contact_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_csov_rec	IN	csov_rec_type) is
begin
  okc_cso_pvt.lock_row(p_api_version   => p_api_version,
                       p_init_msg_list => p_init_msg_list,
                       x_msg_count     => x_msg_count,
                       x_msg_data      => x_msg_data,
                       x_return_status => x_return_status,
                       p_csov_rec      => p_csov_rec);
end lock_contact_source;

-- Start of comments
--
-- Procedure Name  : validate_contact_source
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_contact_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_csov_rec	IN	csov_rec_type) is
begin
  okc_cso_pvt.validate_row(p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           x_return_status => x_return_status,
                           p_csov_rec      => p_csov_rec);
end validate_contact_source;

END OKC_ROLE_SOURCE_PVT;

/
