--------------------------------------------------------
--  DDL for Package Body OKC_CHANGE_REQUEST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CHANGE_REQUEST_PVT" as
/* $Header: OKCCCRTB.pls 120.0 2005/05/26 09:37:55 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_CHANGE_REQUEST_PVT';
  G_FND_APP				CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_CRT_ON_APPROVAL CONSTANT   varchar2(200) := 'OKC_IS_ON_APPROVAL';
  G_WF_NAME_TOKEN CONSTANT   varchar2(200) := 'WF_ITEM';
  G_KEY_TOKEN CONSTANT   varchar2(200) := 'WF_KEY';
  G_CHILD_RECORD_FOUND        CONSTANT varchar2(200) := 'OKC_CHILD_RECORD_FOUND';
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_DUPLICATE_CR    CONSTANT   varchar2(200) := 'OKC_DUPLICATE_CHANGE_REQUEST';
  G_CR_TOKEN     CONSTANT   varchar2(200) := 'CR_NAME';

-- Start of comments
--
-- Procedure Name  : add_language_change_request
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure add_language_change_request is
begin
  okc_crt_pvt.add_language;
end add_language_change_request;

-- Start of comments
--
-- Procedure Name  : create_change_request
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure create_change_request(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_crtv_rec	IN	crtv_rec_type,
                              x_crtv_rec	OUT NOCOPY	crtv_rec_type) is

-- Bug 3162918 Following cursor is used to check for duplicate CR name for a contract.

l_dummy varchar2(1);

cursor chk_dup_cr_csr is
select '!' from okc_change_requests_v
where chr_id = p_crtv_rec.chr_id
and  name = p_crtv_rec.name
and datetime_applied is null;

-- added for Bug 3162918

begin

-- added for Bug 3162918
   l_dummy := '?' ;
  open chk_dup_cr_csr;
  fetch chk_dup_cr_csr into l_dummy;
  close chk_dup_cr_csr;
  If (l_dummy = '!') then
  OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                      p_msg_name     => G_DUPLICATE_CR,
                      p_token1       => G_CR_TOKEN,
                      p_token1_value => p_crtv_rec.name
                     );
    x_return_status := OKC_API.G_RET_STS_ERROR;
    return;
  End If;
-- added for Bug 3162918

  okc_crt_pvt.insert_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_crtv_rec      => p_crtv_rec,
                         x_crtv_rec      => x_crtv_rec);
end create_change_request;

-- Start of comments
--
-- Procedure Name  : update_change_request
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure update_change_request(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_crtv_rec	IN	crtv_rec_type,
                              x_crtv_rec	OUT NOCOPY	crtv_rec_type) is
begin
  okc_crt_pvt.update_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_crtv_rec      => p_crtv_rec,
                         x_crtv_rec      => x_crtv_rec);
end update_change_request;

-- Start of comments
--
-- Procedure Name  : delete_change_request
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure delete_change_request(p_api_version	 IN	NUMBER,
                         p_init_msg_list IN	VARCHAR2 ,
                         x_return_status OUT NOCOPY	VARCHAR2,
                         x_msg_count	 OUT NOCOPY	NUMBER,
                         x_msg_data	 OUT NOCOPY	VARCHAR2,
                         p_crtv_rec	 IN	crtv_rec_type) is
l_dummy varchar2(1);
cursor l1_csr is
  select '!'
  from OKC_CHANGES_B
  where crt_id = p_crtv_rec.id;
cursor l2_csr is
  select '!'
  from OKC_CHANGE_PARTY_ROLE
  where crt_id = p_crtv_rec.id;
begin
--
  l_dummy := '?';
  open l1_csr;
  fetch l1_csr into l_dummy;
  close l1_csr;
  if (l_dummy = '!') then
      OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                      p_msg_name     => G_CHILD_RECORD_FOUND,
                      p_token1       => G_PARENT_TABLE_TOKEN,
                      p_token1_value => 'OKC_CHANGE_REQUESTS_V',
                      p_token2       => G_CHILD_TABLE_TOKEN,
                      p_token2_value => 'OKC_CHANGES_V');
    x_return_status := OKC_API.G_RET_STS_ERROR;
    return;
  end if;
--
  l_dummy := '?';
  open l2_csr;
  fetch l2_csr into l_dummy;
  close l2_csr;
  if (l_dummy = '!') then
      OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                      p_msg_name     => G_CHILD_RECORD_FOUND,
                      p_token1       => G_PARENT_TABLE_TOKEN,
                      p_token1_value => 'OKC_CHANGE_REQUESTS_V',
                      p_token2       => G_CHILD_TABLE_TOKEN,
                      p_token2_value => 'OKC_CHANGE_PARTY_ROLE_V');
    x_return_status := OKC_API.G_RET_STS_ERROR;
    return;
  end if;
--
  okc_crt_pvt.delete_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_crtv_rec      => p_crtv_rec);
end delete_change_request;

-- Start of comments
--
-- Procedure Name  : lock_change_request
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure lock_change_request(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
    					p_restricted IN VARCHAR2 ,
                              p_crtv_rec	IN	crtv_rec_type) is
--
l_key varchar2(240);
l_wf_name_active varchar2(150);
--
l_crtv_rec  OKC_CHANGE_REQUEST_PUB.crtv_rec_type;

Cursor cur_crt_details is
select id,name,chr_id,crs_code,datetime_applied,object_version_number
from okc_change_requests_v
where id = p_crtv_rec.id;

cursor key_csr is
  select substr(CONTRACT_NUMBER||CONTRACT_NUMBER_MODIFIER||l_crtv_rec.NAME,1,240) key
  from OKC_K_HDR_AGREEDS_V
  where ID = l_crtv_rec.chr_id;
--
cursor approval_active_csr is
  select item_type
  from WF_ITEMS
  where item_type in
   ( select wf_name
     from OKC_PROCESS_DEFS_B
     where USAGE='CHG_REQ_APPROVE' and PDF_TYPE='WPS')
   and item_key = l_key
   and end_date is NULL;
--
begin
  open cur_crt_details;
  fetch cur_crt_details into l_crtv_rec.id,l_crtv_rec.name,l_crtv_rec.chr_id,l_crtv_rec.crs_code,l_crtv_rec.datetime_applied,l_crtv_rec.object_version_number;
  close cur_crt_details;
  if (l_crtv_rec.crs_code='APP') then
    if (p_restricted = OKC_API.G_TRUE
	or l_crtv_rec.datetime_applied is not NULL) then
      OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
      x_return_status := OKC_API.G_RET_STS_ERROR;
      return;
    end if;
  end if;
  open key_csr;
  fetch key_csr into L_KEY;
  close key_csr;
  open approval_active_csr;
  fetch approval_active_csr into l_wf_name_active;
  close approval_active_csr;
  if (L_WF_NAME_ACTIVE is not NULL) then
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => G_CRT_ON_APPROVAL,
                        p_token1       => G_WF_NAME_TOKEN,
                        p_token1_value => L_WF_NAME_ACTIVE,
                        p_token2       => G_KEY_TOKEN,
                        p_token2_value => L_KEY);
    OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
    x_return_status := OKC_API.G_RET_STS_ERROR;
    return;
  end if;
  okc_crt_pvt.lock_row(p_api_version   => p_api_version,
                       p_init_msg_list => p_init_msg_list,
                       x_msg_count     => x_msg_count,
                       x_msg_data      => x_msg_data,
                       x_return_status => x_return_status,
                       p_crtv_rec      => l_crtv_rec);
end lock_change_request;

-- Start of comments
--
-- Procedure Name  : validate_change_request
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_change_request(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_crtv_rec	IN	crtv_rec_type) is
begin
  okc_crt_pvt.validate_row(p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           x_return_status => x_return_status,
                           p_crtv_rec      => p_crtv_rec);
end validate_change_request;

-- Start of comments
--
-- Procedure Name  : add_language_change
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure add_language_change is
begin
  okc_cor_pvt.add_language;
end add_language_change;

-- Start of comments
--
-- Procedure Name  : create_change
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure create_change(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_corv_rec	IN	corv_rec_type,
                              x_corv_rec	OUT NOCOPY	corv_rec_type) is
begin
  okc_cor_pvt.insert_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_corv_rec      => p_corv_rec,
                         x_corv_rec      => x_corv_rec);
end create_change;

-- Start of comments
--
-- Procedure Name  : update_change
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure update_change(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_corv_rec	IN	corv_rec_type,
                              x_corv_rec	OUT NOCOPY	corv_rec_type) is
begin
  okc_cor_pvt.update_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_corv_rec      => p_corv_rec,
                         x_corv_rec      => x_corv_rec);
end update_change;

-- Start of comments
--
-- Procedure Name  : delete_change
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure delete_change(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_corv_rec	IN	corv_rec_type) is
begin
  okc_cor_pvt.delete_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_corv_rec      => p_corv_rec);
end delete_change;

-- Start of comments
--
-- Procedure Name  : lock_change
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure lock_change(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_corv_rec	IN	corv_rec_type) is
--
l_status varchar2(20);
l_key varchar2(240);
l_wf_name_active varchar2(150);
--
cursor key_csr is
  select C.crs_code,
	substr(K.CONTRACT_NUMBER||K.CONTRACT_NUMBER_MODIFIER||C.NAME,1,240) key
  from
	OKC_CHANGE_REQUESTS_V C,
	OKC_K_HDR_AGREEDS_V K
  where C.ID = p_corv_rec.CRT_ID
    and K.ID = C.chr_id;
--
cursor approval_active_csr is
  select item_type
  from WF_ITEMS
  where item_type in
   ( select wf_name
     from OKC_PROCESS_DEFS_B
     where USAGE='CHG_REQ_APPROVE' and PDF_TYPE='WPS')
   and item_key = l_key
   and end_date is NULL;
--
begin
  open key_csr;
  fetch key_csr into l_status, L_KEY;
  close key_csr;
  if (l_status='APP') then
    OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
    x_return_status := OKC_API.G_RET_STS_ERROR;
    return;
  end if;
  open approval_active_csr;
  fetch approval_active_csr into l_wf_name_active;
  close approval_active_csr;
  if (L_WF_NAME_ACTIVE is not NULL) then
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => G_CRT_ON_APPROVAL,
                        p_token1       => G_WF_NAME_TOKEN,
                        p_token1_value => L_WF_NAME_ACTIVE,
                        p_token2       => G_KEY_TOKEN,
                        p_token2_value => L_KEY);
    OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
    x_return_status := OKC_API.G_RET_STS_ERROR;
    return;
  end if;
  okc_cor_pvt.lock_row(p_api_version   => p_api_version,
                       p_init_msg_list => p_init_msg_list,
                       x_msg_count     => x_msg_count,
                       x_msg_data      => x_msg_data,
                       x_return_status => x_return_status,
                       p_corv_rec      => p_corv_rec);
end lock_change;

-- Start of comments
--
-- Procedure Name  : validate_change
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_change(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_corv_rec	IN	corv_rec_type) is
begin
  okc_cor_pvt.validate_row(p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           x_return_status => x_return_status,
                           p_corv_rec      => p_corv_rec);
end validate_change;

-- Start of comments
--
-- Procedure Name  : create_change_party_role
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure create_change_party_role(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cprv_rec	IN	cprv_rec_type,
                              x_cprv_rec	OUT NOCOPY	cprv_rec_type) is
begin
  okc_cpr_pvt.insert_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_cprv_rec      => p_cprv_rec,
                         x_cprv_rec      => x_cprv_rec);
end create_change_party_role;

-- Start of comments
--
-- Procedure Name  : update_change_party_role
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure update_change_party_role(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cprv_rec	IN	cprv_rec_type,
                              x_cprv_rec	OUT NOCOPY	cprv_rec_type) is
begin
  okc_cpr_pvt.update_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_cprv_rec      => p_cprv_rec,
                         x_cprv_rec      => x_cprv_rec);
end update_change_party_role;

-- Start of comments
--
-- Procedure Name  : delete_change_party_role
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure delete_change_party_role(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cprv_rec	IN	cprv_rec_type) is
begin
  okc_cpr_pvt.delete_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_cprv_rec      => p_cprv_rec);
end delete_change_party_role;

-- Start of comments
--
-- Procedure Name  : lock_change_party_role
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure lock_change_party_role(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cprv_rec	IN	cprv_rec_type) is
begin
  okc_cpr_pvt.lock_row(p_api_version   => p_api_version,
                       p_init_msg_list => p_init_msg_list,
                       x_msg_count     => x_msg_count,
                       x_msg_data      => x_msg_data,
                       x_return_status => x_return_status,
                       p_cprv_rec      => p_cprv_rec);
end lock_change_party_role;

-- Start of comments
--
-- Procedure Name  : validate_change_party_role
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_change_party_role(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cprv_rec	IN	cprv_rec_type) is
begin
  okc_cpr_pvt.validate_row(p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           x_return_status => x_return_status,
                           p_cprv_rec      => p_cprv_rec);
end validate_change_party_role;

end OKC_CHANGE_REQUEST_PVT;

/
