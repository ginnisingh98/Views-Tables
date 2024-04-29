--------------------------------------------------------
--  DDL for Package Body OKC_CONTRACT_PARTY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CONTRACT_PARTY_PVT" as
/* $Header: OKCCCPLB.pls 120.0 2005/05/25 19:21:18 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_CONTRACT_PARTY_PVT';
  G_CHILD_RECORD_FOUND        CONSTANT   varchar2(200) := 'OKC_CHILD_RECORD_FOUND';
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;

-- Start of comments
--
-- Procedure Name  : create_contact
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure create_contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_ctcv_rec	IN	ctcv_rec_type,
                              x_ctcv_rec	OUT NOCOPY	ctcv_rec_type) is
--V
l_cvmv_rec  	OKC_CVM_PVT.cvmv_rec_type;
x_out_rec    	OKC_CVM_PVT.cvmv_rec_type;
--V
begin
  okc_ctc_pvt.insert_row(p_api_version =>	p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count => x_msg_count,
                              x_msg_data => x_msg_data,
                              p_ctcv_rec => p_ctcv_rec,
                              x_ctcv_rec => x_ctcv_rec);
--V
  if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
    return;
  end if;
  l_cvmv_rec.chr_id := p_ctcv_rec.DNZ_CHR_ID;
  OKC_CVM_PVT.update_contract_version(
         p_api_version    => p_api_version,
         p_init_msg_list   => OKC_API.G_FALSE,
         x_return_status  => x_return_status,
         x_msg_count     => x_msg_count,
         x_msg_data       => x_msg_data,
         p_cvmv_rec      => l_cvmv_rec,
         x_cvmv_rec      => x_out_rec);
--V
end create_contact;

-- Start of comments
--
-- Procedure Name  : update_contact
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure update_contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_ctcv_rec	IN	ctcv_rec_type,
                              x_ctcv_rec	OUT NOCOPY	ctcv_rec_type) is
--V
l_cvmv_rec  	OKC_CVM_PVT.cvmv_rec_type;
x_out_rec    	OKC_CVM_PVT.cvmv_rec_type;
cursor dnz_csr is
  select dnz_chr_id
  from OKC_CONTACTS_V
  where id = p_ctcv_rec.id;
--V
begin
  okc_ctc_pvt.update_row(p_api_version =>	p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count => x_msg_count,
                              x_msg_data => x_msg_data,
                              p_ctcv_rec => p_ctcv_rec,
                              x_ctcv_rec => x_ctcv_rec);
--V
  if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
    return;
  end if;
  open dnz_csr;
  fetch dnz_csr into l_cvmv_rec.chr_id;
  close dnz_csr;
  OKC_CVM_PVT.update_contract_version(
         p_api_version    => p_api_version,
         p_init_msg_list   => OKC_API.G_FALSE,
         x_return_status  => x_return_status,
         x_msg_count     => x_msg_count,
         x_msg_data       => x_msg_data,
         p_cvmv_rec      => l_cvmv_rec,
         x_cvmv_rec      => x_out_rec);
--V
end update_contact;

-- Start of comments
--
-- Procedure Name  : delete_contact
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure delete_contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_ctcv_rec	IN	ctcv_rec_type) is
--V
l_cvmv_rec  	OKC_CVM_PVT.cvmv_rec_type;
x_out_rec    	OKC_CVM_PVT.cvmv_rec_type;
cursor dnz_csr is
  select dnz_chr_id
  from OKC_contacts_V
  where id = p_ctcv_rec.id;
--V
begin
--V
  open dnz_csr;
  fetch dnz_csr into l_cvmv_rec.chr_id;
  close dnz_csr;
  if (l_cvmv_rec.chr_id is NULL) then
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    return;
  end if;
--V
  okc_ctc_pvt.delete_row(p_api_version =>	p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count => x_msg_count,
                              x_msg_data => x_msg_data,
                              p_ctcv_rec => p_ctcv_rec);
--V
  if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
    return;
  end if;
  OKC_CVM_PVT.update_contract_version(
         p_api_version    => p_api_version,
         p_init_msg_list   => OKC_API.G_FALSE,
         x_return_status  => x_return_status,
         x_msg_count     => x_msg_count,
         x_msg_data       => x_msg_data,
         p_cvmv_rec      => l_cvmv_rec,
         x_cvmv_rec      => x_out_rec);
--V
end delete_contact;

-- Start of comments
--
-- Procedure Name  : lock_contact
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure lock_contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_ctcv_rec	IN	ctcv_rec_type) is
begin
  okc_ctc_pvt.lock_row(p_api_version =>	p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count => x_msg_count,
                              x_msg_data => x_msg_data,
                              p_ctcv_rec => p_ctcv_rec);
end lock_contact;

-- Start of comments
--
-- Procedure Name  : validate_contact
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_ctcv_rec	IN	ctcv_rec_type) is
begin
  okc_ctc_pvt.validate_row(p_api_version =>	p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count => x_msg_count,
                              x_msg_data => x_msg_data,
                              p_ctcv_rec => p_ctcv_rec);
end validate_contact;

-- Start of comments
--
-- Procedure Name  : create_k_party_role
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure create_k_party_role(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cplv_rec	IN	cplv_rec_type,
                              x_cplv_rec	OUT NOCOPY	cplv_rec_type) is
--V
l_cvmv_rec  	OKC_CVM_PVT.cvmv_rec_type;
x_out_rec    	OKC_CVM_PVT.cvmv_rec_type;
--V
begin
  okc_cpl_pvt.insert_row(p_api_version =>	p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count => x_msg_count,
                              x_msg_data => x_msg_data,
                              p_cplv_rec => p_cplv_rec,
                              x_cplv_rec => x_cplv_rec);
--V
  if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
    return;
  end if;
  l_cvmv_rec.chr_id := p_cplv_rec.DNZ_CHR_ID;
  OKC_CVM_PVT.update_contract_version(
         p_api_version    => p_api_version,
         p_init_msg_list   => OKC_API.G_FALSE,
         x_return_status  => x_return_status,
         x_msg_count     => x_msg_count,
         x_msg_data       => x_msg_data,
         p_cvmv_rec      => l_cvmv_rec,
         x_cvmv_rec      => x_out_rec);
--V
end create_k_party_role;

-- Start of comments
--
-- Procedure Name  : lock_k_party_role
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure lock_k_party_role(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cplv_rec	IN	cplv_rec_type) is
begin
  okc_cpl_pvt.lock_row(p_api_version =>	p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count => x_msg_count,
                              x_msg_data => x_msg_data,
                              p_cplv_rec => p_cplv_rec);
end lock_k_party_role;

-- Start of comments
--
-- Procedure Name  : update_k_party_role
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure update_k_party_role(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cplv_rec	IN	cplv_rec_type,
                              x_cplv_rec	OUT NOCOPY	cplv_rec_type) is
--V
l_cvmv_rec  	OKC_CVM_PVT.cvmv_rec_type;
x_out_rec    	OKC_CVM_PVT.cvmv_rec_type;
cursor dnz_csr is
  select dnz_chr_id
  from OKC_K_PARTY_ROLES_B
  where id = p_cplv_rec.id;
--V
begin
  okc_cpl_pvt.update_row(p_api_version =>	p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count => x_msg_count,
                              x_msg_data => x_msg_data,
                              p_cplv_rec => p_cplv_rec,
                              x_cplv_rec => x_cplv_rec);
--V
  if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
    return;
  end if;
  open dnz_csr;
  fetch dnz_csr into l_cvmv_rec.chr_id;
  close dnz_csr;
  OKC_CVM_PVT.update_contract_version(
         p_api_version    => p_api_version,
         p_init_msg_list   => OKC_API.G_FALSE,
         x_return_status  => x_return_status,
         x_msg_count     => x_msg_count,
         x_msg_data       => x_msg_data,
         p_cvmv_rec      => l_cvmv_rec,
         x_cvmv_rec      => x_out_rec);
--V
end update_k_party_role;

-- Start of comments
--
-- Procedure Name  : delete_k_party_role
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure delete_k_party_role(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cplv_rec	IN	cplv_rec_type) is
l_dummy_var                 varchar2(1) := '?';
cursor l_cpl_csr is
  select 'x'
  from OKC_CONTACTS_V
  where CPL_id = p_cplv_rec.id;
--V
l_cvmv_rec  	OKC_CVM_PVT.cvmv_rec_type;
x_out_rec    	OKC_CVM_PVT.cvmv_rec_type;
cursor dnz_csr is
  select dnz_chr_id
  from OKC_K_PARTY_ROLES_B
  where id = p_cplv_rec.id;
--V
begin
  open l_cpl_csr;
  fetch l_cpl_csr into l_dummy_var;
  close l_cpl_csr;
  if (l_dummy_var = 'x') then
      OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                      p_msg_name     => 'OKC_NO_DELETE_IF_CTC_EXIST');
    x_return_status := OKC_API.G_RET_STS_ERROR;
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
--V
  open dnz_csr;
  fetch dnz_csr into l_cvmv_rec.chr_id;
  close dnz_csr;
  if (l_cvmv_rec.chr_id is NULL) then
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    return;
  end if;
--V
  okc_cpl_pvt.delete_row(p_api_version =>	p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count => x_msg_count,
                              x_msg_data => x_msg_data,
                              p_cplv_rec => p_cplv_rec);
--V
  if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
    return;
  end if;
  OKC_CVM_PVT.update_contract_version(
         p_api_version    => p_api_version,
         p_init_msg_list   => OKC_API.G_FALSE,
         x_return_status  => x_return_status,
         x_msg_count     => x_msg_count,
         x_msg_data       => x_msg_data,
         p_cvmv_rec      => l_cvmv_rec,
         x_cvmv_rec      => x_out_rec);
--V
exception
    WHEN OTHERS THEN NULL;
end delete_k_party_role;

-- Start of comments
--
-- Procedure Name  : validate_k_party_role
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_k_party_role(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cplv_rec	IN	cplv_rec_type) is
begin
  okc_cpl_pvt.validate_row(p_api_version =>	p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count => x_msg_count,
                              x_msg_data => x_msg_data,
                              p_cplv_rec => p_cplv_rec);
end validate_k_party_role;

-- Start of comments
--
-- Procedure Name  : add_language
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure add_language is
begin
  okc_cpl_pvt.add_language;
end add_language;

end OKC_CONTRACT_PARTY_PVT;

/
