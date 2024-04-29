--------------------------------------------------------
--  DDL for Package Body OKS_ORDER_DETAILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_ORDER_DETAILS_PVT" AS
/* $Header: OKSCCODB.pls 120.0 2005/05/25 18:32:29 appldev noship $ */

  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKS_ORDER_DETAILS_PVT';
  G_CHILD_RECORD_FOUND        CONSTANT   varchar2(200) := 'OKC_CHILD_RECORD_FOUND';
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;


-- Start of comments
--
-- Procedure Name  : create_Order_Detail
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure create_Order_Detail(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_codv_rec	IN	codv_rec_type,
                              x_codv_rec	OUT NOCOPY	codv_rec_type) is
begin
  oks_cod_pvt.insert_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_codv_rec      => p_codv_rec,
                         x_codv_rec      => x_codv_rec);
--V
  if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
    return;
  end if;
end create_Order_Detail;

-- Start of comments
--
-- Procedure Name  : update_Order_Detail
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure update_Order_Detail(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_codv_rec	IN	codv_rec_type,
                              x_codv_rec	OUT NOCOPY	codv_rec_type) is
begin
  oks_cod_pvt.update_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_codv_rec      => p_codv_rec,
                         x_codv_rec      => x_codv_rec);
  if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
    return;
  end if;
end update_Order_Detail;

-- Start of comments
--
-- Procedure Name  : delete_Order_Detail
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure delete_Order_Detail(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_codv_rec	IN	codv_rec_type) is
BEGIN
  oks_cod_pvt.delete_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_codv_rec      => p_codv_rec);

  if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
    return;
  end if;
exception
    WHEN OTHERS THEN
	NULL;
end delete_Order_Detail;

-- Start of comments
--
-- Procedure Name  : lock_Order_Detail
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure lock_Order_Detail(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_codv_rec	IN	codv_rec_type) is
begin
  oks_cod_pvt.lock_row(p_api_version   => p_api_version,
                       p_init_msg_list => p_init_msg_list,
                       x_msg_count     => x_msg_count,
                       x_msg_data      => x_msg_data,
                       x_return_status => x_return_status,
                       p_codv_rec      => p_codv_rec);
end lock_Order_Detail;

-- Start of comments
--
-- Procedure Name  : validate_Order_Detail
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_Order_Detail(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_codv_rec	IN	codv_rec_type) is
begin
  oks_cod_pvt.validate_row(p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           x_return_status => x_return_status,
                           p_codv_rec      => p_codv_rec);
end validate_Order_Detail;

end OKS_Order_Details_PVT;

/
