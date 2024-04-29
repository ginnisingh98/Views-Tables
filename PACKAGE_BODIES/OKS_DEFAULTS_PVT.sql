--------------------------------------------------------
--  DDL for Package Body OKS_DEFAULTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_DEFAULTS_PVT" AS
/* $Header: OKSCCDTB.pls 120.0 2005/05/25 18:15:20 appldev noship $ */

  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKS_DEFAULTS_PVT';
  G_CHILD_RECORD_FOUND        CONSTANT   varchar2(200) := 'OKC_CHILD_RECORD_FOUND';
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;

-- Start of comments
--
-- Procedure Name  : create_defaults
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure Insert_defaults(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cdtv_rec	IN	cdtv_rec_type,
                              X_cdtv_rec	OUT NOCOPY	cdtv_rec_type) is
begin
  oks_cdt_pvt.insert_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_cdtv_rec      => p_cdtv_rec,
                         x_cdtv_rec      => x_cdtv_rec);

--V
  if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
    return;
  end if;
end Insert_defaults;

-- Start of comments
--
-- Procedure Name  : update_defaults
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure update_defaults(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cdtv_rec	IN	cdtv_rec_type,
                              x_cdtv_rec    OUT NOCOPY cdtv_rec_type) is
--V
--V
begin
  oks_cdt_pvt.update_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_cdtv_rec      => p_cdtv_rec,
                         x_cdtv_rec      => x_cdtv_rec);
--V
  if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
    return;
  end if;
end update_defaults;

-- Start of comments
--
-- Procedure Name  : delete_defaults
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure delete_defaults(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cdtv_rec	IN	cdtv_rec_type) is
begin
  oks_cdt_pvt.delete_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_cdtv_rec      => p_cdtv_rec);
--V
  if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
    return;
  end if;
exception
    WHEN OTHERS THEN
    NULL;
end delete_defaults;

-- Start of comments
--
-- Procedure Name  : lock_defaults
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure lock_defaults(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cdtv_rec	IN	cdtv_rec_type) is
begin
  oks_cdt_pvt.lock_row(p_api_version   => p_api_version,
                       p_init_msg_list => p_init_msg_list,
                       x_return_status => x_return_status,
                       x_msg_count     => x_msg_count,
                       x_msg_data      => x_msg_data,
                       p_cdtv_rec      => p_cdtv_rec);
end lock_defaults;

-- Start of comments
--
-- Procedure Name  : validate_defaults
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_defaults(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cdtv_rec	IN	cdtv_rec_type) is
begin
  oks_cdt_pvt.validate_row(p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           p_cdtv_rec      => p_cdtv_rec);
end validate_defaults;

end OKS_defaults_PVT;

/
