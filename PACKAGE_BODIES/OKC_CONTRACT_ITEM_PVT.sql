--------------------------------------------------------
--  DDL for Package Body OKC_CONTRACT_ITEM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CONTRACT_ITEM_PVT" as
/* $Header: OKCCCIMB.pls 120.0 2005/05/26 09:44:03 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_CONTRACT_ITEM_PVT';
  G_CHILD_RECORD_FOUND        CONSTANT   varchar2(200) := 'OKC_CHILD_RECORD_FOUND';
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;

-- Start of comments
--
-- Procedure Name  : create_contract_item
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure create_contract_item(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cimv_rec	IN	cimv_rec_type,
                              x_cimv_rec	OUT NOCOPY	cimv_rec_type) is
--V
l_cvmv_rec  	OKC_CVM_PVT.cvmv_rec_type;
x_out_rec    	OKC_CVM_PVT.cvmv_rec_type;
--V
begin
  okc_cim_pvt.insert_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_cimv_rec      => p_cimv_rec,
                         x_cimv_rec      => x_cimv_rec);
--V
  if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
    return;
  end if;
  l_cvmv_rec.chr_id := p_cimv_rec.DNZ_CHR_ID;
  OKC_CVM_PVT.update_contract_version(
         p_api_version    => p_api_version,
         p_init_msg_list   => OKC_API.G_FALSE,
         x_return_status  => x_return_status,
         x_msg_count     => x_msg_count,
         x_msg_data       => x_msg_data,
         p_cvmv_rec      => l_cvmv_rec,
         x_cvmv_rec      => x_out_rec);
--V
end create_contract_item;

-- Start of comments
--
-- Procedure Name  : update_contract_item
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure update_contract_item(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cimv_rec	IN	cimv_rec_type,
                              x_cimv_rec	OUT NOCOPY	cimv_rec_type) is
--V
l_cvmv_rec  	OKC_CVM_PVT.cvmv_rec_type;
x_out_rec    	OKC_CVM_PVT.cvmv_rec_type;
cursor dnz_csr is
  select dnz_chr_id
  from OKC_K_ITEMS_V
  where id = p_cimv_rec.id;
--V
begin
  okc_cim_pvt.update_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_cimv_rec      => p_cimv_rec,
                         x_cimv_rec      => x_cimv_rec);
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
end update_contract_item;

-- Start of comments
--
-- Procedure Name  : delete_contract_item
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure delete_contract_item(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cimv_rec	IN	cimv_rec_type) is
i NUMBER :=0;
--V
l_cvmv_rec  	OKC_CVM_PVT.cvmv_rec_type;
x_out_rec    	OKC_CVM_PVT.cvmv_rec_type;
cursor dnz_csr is
  select dnz_chr_id
  from OKC_K_ITEMS_V
  where id = p_cimv_rec.id;
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

  okc_cim_pvt.delete_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_cimv_rec      => p_cimv_rec);
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
    WHEN OTHERS THEN
    null;
end delete_contract_item;

-- Start of comments
--
-- Procedure Name  : lock_contract_item
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure lock_contract_item(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cimv_rec	IN	cimv_rec_type) is
begin
  okc_cim_pvt.lock_row(p_api_version   => p_api_version,
                       p_init_msg_list => p_init_msg_list,
                       x_msg_count     => x_msg_count,
                       x_msg_data      => x_msg_data,
                       x_return_status => x_return_status,
                       p_cimv_rec      => p_cimv_rec);
end lock_contract_item;

-- Start of comments
--
-- Procedure Name  : validate_contract_item
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_contract_item(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cimv_rec	IN	cimv_rec_type) is
begin
  okc_cim_pvt.validate_row(p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           x_return_status => x_return_status,
                           p_cimv_rec      => p_cimv_rec);
end validate_contract_item;

end OKC_CONTRACT_ITEM_PVT;

/
