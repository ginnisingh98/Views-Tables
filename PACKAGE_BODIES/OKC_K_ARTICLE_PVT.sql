--------------------------------------------------------
--  DDL for Package Body OKC_K_ARTICLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_K_ARTICLE_PVT" as
/* $Header: OKCCCATB.pls 120.0 2005/05/25 19:13:43 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_K_ARTICLE_PVT';
  G_CHILD_RECORD_FOUND        CONSTANT varchar2(200) := 'OKC_CHILD_RECORD_FOUND';
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;

-- Start of comments
--
-- Procedure Name  : add_language_k_article
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure add_language_k_article is
begin
  okc_cat_pvt.add_language;
end add_language_k_article;

-- Start of comments
--
-- Procedure Name  : create_k_article
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure create_k_article(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_catv_rec	IN	catv_rec_type,
                              x_catv_rec	OUT NOCOPY	catv_rec_type) is
l_catv_rec 		catv_rec_type 	:= p_catv_rec;
--V
l_cvmv_rec  	OKC_CVM_PVT.cvmv_rec_type;
x_out_rec    	OKC_CVM_PVT.cvmv_rec_type;
--V
cursor l_std_art_exists_csr is
  select STA.NAME
  from OKC_K_ARTICLES_B CAT,
  OKC_STD_ARTICLES_V STA
  where CAT.chr_id = p_catv_rec.chr_id
  and CAT.sav_sae_id = p_catv_rec.sav_sae_id
  and STA.ID = CAT.sav_sae_id
  ;
l_dummy varchar2(150):='?';
begin
  if (l_catv_rec.CAT_TYPE = 'STA') then
    open l_std_art_exists_csr;
    fetch l_std_art_exists_csr into l_dummy;
    close l_std_art_exists_csr;
    if (l_dummy <> '?') then
      OKC_API.SET_MESSAGE(p_app_name     => 'OKC',
                      p_msg_name     => 'OKC_ARTICLE_EXISTS',
                      p_token1       => 'VALUE1',
                      p_token1_value => l_dummy);
    x_return_status := OKC_API.G_RET_STS_ERROR;
    return;
    end if;
    l_catv_rec.NAME := NULL;
    l_catv_rec.SBT_CODE := NULL;
  elsif (l_catv_rec.CAT_TYPE = 'NSD') then
    l_catv_rec.FULLTEXT_YN := NULL;
    l_catv_rec.VARIATION_DESCRIPTION := NULL;
    l_catv_rec.SAV_SAE_ID := NULL;
    l_catv_rec.SAV_SAV_RELEASE := NULL;
  end if;
  okc_cat_pvt.insert_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_catv_rec      => l_catv_rec,
                         x_catv_rec      => x_catv_rec);
--V
  if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
    return;
  end if;
  l_cvmv_rec.chr_id := p_catv_rec.DNZ_CHR_ID;
  OKC_CVM_PVT.update_contract_version(
         p_api_version    => p_api_version,
         p_init_msg_list   => OKC_API.G_FALSE,
         x_return_status  => x_return_status,
         x_msg_count     => x_msg_count,
         x_msg_data       => x_msg_data,
         p_cvmv_rec      => l_cvmv_rec,
         x_cvmv_rec      => x_out_rec);
--V
end create_k_article;

-- Start of comments
--
-- Procedure Name  : lock_k_article
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure lock_k_article(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_catv_rec	IN	catv_rec_type) is
begin
  okc_cat_pvt.lock_row(p_api_version   => p_api_version,
                       p_init_msg_list => p_init_msg_list,
                       x_msg_count     => x_msg_count,
                       x_msg_data      => x_msg_data,
                       x_return_status => x_return_status,
                       p_catv_rec      => p_catv_rec);
end lock_k_article;

-- Start of comments
--
-- Procedure Name  : update_k_article
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure update_k_article(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_catv_rec	IN	catv_rec_type,
                              x_catv_rec	OUT NOCOPY	catv_rec_type) is
l_catv_rec 		catv_rec_type 	:= p_catv_rec;
--V
l_cvmv_rec  	OKC_CVM_PVT.cvmv_rec_type;
x_out_rec    	OKC_CVM_PVT.cvmv_rec_type;
cursor dnz_csr is
  select dnz_chr_id
  from OKC_K_ARTICLES_B
  where id = p_catv_rec.id;
--V
begin
  if (l_catv_rec.CAT_TYPE = 'STA') then
    l_catv_rec.NAME := NULL;
    l_catv_rec.SBT_CODE := NULL;
  elsif (l_catv_rec.CAT_TYPE = 'NSD') then
    l_catv_rec.FULLTEXT_YN := NULL;
    l_catv_rec.VARIATION_DESCRIPTION := NULL;
    l_catv_rec.SAV_SAE_ID := NULL;
    l_catv_rec.SAV_SAV_RELEASE := NULL;
  end if;
  okc_cat_pvt.update_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_catv_rec      => l_catv_rec,
                         x_catv_rec      => x_catv_rec);
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
end update_k_article;

-- Start of comments
--
-- Procedure Name  : delete_k_article
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure delete_k_article(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_catv_rec	IN	catv_rec_type) is
l_dummy  varchar2(1);

l_scc_id okc_section_contents.id%TYPE;
l_sccv_rec okc_sections_pub.sccv_rec_type;


cursor l_cat_csr is
  select '!'
  from OKC_K_ARTICLES_B
  where cat_id = p_catv_rec.id;
CURSOR l_atn_csr IS
    SELECT '!'
	FROM Okc_Article_Trans_V
     	WHERE cat_id = p_catv_rec.id;
--V
l_cvmv_rec  	OKC_CVM_PVT.cvmv_rec_type;
x_out_rec    	OKC_CVM_PVT.cvmv_rec_type;
cursor dnz_csr is
  select dnz_chr_id
  from OKC_K_ARTICLES_B
  where id = p_catv_rec.id;
--V

cursor section_csr is
  select id
  from OKC_SECTION_CONTENTS
  where cat_id = p_catv_rec.id;

begin
--
  l_dummy := '?';
  open l_cat_csr;
  fetch l_cat_csr into l_dummy;
  close l_cat_csr;
  if (l_dummy = '!') then
      OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                      p_msg_name     => G_CHILD_RECORD_FOUND,
                      p_token1       => G_PARENT_TABLE_TOKEN,
                      p_token1_value => 'OKC_K_ARTICLES_V',
                      p_token2       => G_CHILD_TABLE_TOKEN,
                      p_token2_value => 'OKC_K_ARTICLES_V');
    x_return_status := OKC_API.G_RET_STS_ERROR;
    return;
  end if;
--
  l_dummy := '?';
  open l_atn_csr;
  fetch l_atn_csr into l_dummy;
  close l_atn_csr;
  if (l_dummy = '!') then
      OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                      p_msg_name     => G_CHILD_RECORD_FOUND,
                      p_token1       => G_PARENT_TABLE_TOKEN,
                      p_token1_value => 'OKC_K_ARTICLES_V',
                      p_token2       => G_CHILD_TABLE_TOKEN,
                      p_token2_value => 'OKC_ARTICLE_TRANS_V');
    x_return_status := OKC_API.G_RET_STS_ERROR;
    return;
  end if;
--V
  open dnz_csr;
  fetch dnz_csr into l_cvmv_rec.chr_id;
  close dnz_csr;
  if (l_cvmv_rec.chr_id is NULL) then
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    return;
  end if;
--V
  okc_cat_pvt.delete_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_catv_rec      => p_catv_rec);
--V
  if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
    return;
  else
        open  section_csr;
        fetch section_csr into l_scc_id;
        close section_csr;

        if l_scc_id IS NOT NULL then
           l_sccv_rec.id :=l_scc_id;
           OKC_SECTIONS_PUB.delete_section_content(
                         p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_sccv_rec      => l_sccv_rec);
        end if;
  end if;
  OKC_CVM_PVT.update_contract_version(
         p_api_version    => p_api_version,
         p_init_msg_list   => OKC_API.G_FALSE,
         x_return_status  => x_return_status,
         x_msg_count     => x_msg_count,
         x_msg_data       => x_msg_data,
         p_cvmv_rec      => l_cvmv_rec,
         x_cvmv_rec      => x_out_rec);

end delete_k_article;

-- Start of comments
--
-- Procedure Name  : validate_k_article
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_k_article(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_catv_rec	IN	catv_rec_type) is
begin
  okc_cat_pvt.validate_row(p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           x_return_status => x_return_status,
                           p_catv_rec      => p_catv_rec);
end validate_k_article;

-- Start of comments
--
-- Procedure Name  : create_article_translation
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure create_article_translation(p_api_version	 IN	NUMBER,
                         p_init_msg_list IN	VARCHAR2 ,
                         x_return_status OUT NOCOPY	VARCHAR2,
                         x_msg_count	 OUT NOCOPY	NUMBER,
                         x_msg_data	 OUT NOCOPY	VARCHAR2,
                         p_atnv_rec	 IN	atnv_rec_type,
                         x_atnv_rec	 OUT NOCOPY	atnv_rec_type) is
--V
l_cvmv_rec  	OKC_CVM_PVT.cvmv_rec_type;
x_out_rec    	OKC_CVM_PVT.cvmv_rec_type;
--V
begin
  okc_atn_pvt.insert_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_atnv_rec      => p_atnv_rec,
                         x_atnv_rec      => x_atnv_rec);
--V
  if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
    return;
  end if;
  l_cvmv_rec.chr_id := p_atnv_rec.DNZ_CHR_ID;
  OKC_CVM_PVT.update_contract_version(
         p_api_version    => p_api_version,
         p_init_msg_list   => OKC_API.G_FALSE,
         x_return_status  => x_return_status,
         x_msg_count     => x_msg_count,
         x_msg_data       => x_msg_data,
         p_cvmv_rec      => l_cvmv_rec,
         x_cvmv_rec      => x_out_rec);
--V
end create_article_translation;

-- Start of comments
--
-- Procedure Name  : lock_article_translation
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure lock_article_translation(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_atnv_rec	IN	atnv_rec_type) is
begin
  okc_atn_pvt.lock_row(p_api_version   => p_api_version,
                       p_init_msg_list => p_init_msg_list,
                       x_msg_count     => x_msg_count,
                       x_msg_data      => x_msg_data,
                       x_return_status => x_return_status,
                       p_atnv_rec      => p_atnv_rec);
end lock_article_translation;

-- Start of comments
--
-- Procedure Name  : delete_article_translation
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure delete_article_translation(p_api_version	 IN	NUMBER,
                         p_init_msg_list IN	VARCHAR2 ,
                         x_return_status OUT NOCOPY	VARCHAR2,
                         x_msg_count	 OUT NOCOPY	NUMBER,
                         x_msg_data	 OUT NOCOPY	VARCHAR2,
                         p_atnv_rec	 IN	atnv_rec_type) is
--V
l_cvmv_rec  	OKC_CVM_PVT.cvmv_rec_type;
x_out_rec    	OKC_CVM_PVT.cvmv_rec_type;
cursor dnz_csr is
  select dnz_chr_id
  from OKC_ARTICLE_TRANS_V
  where id = p_atnv_rec.id;
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
  okc_atn_pvt.delete_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_atnv_rec      => p_atnv_rec);
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
end delete_article_translation;

-- Start of comments
--
-- Procedure Name  : validate_article_translation
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_article_translation(p_api_version   IN	NUMBER,
                           p_init_msg_list IN	VARCHAR2 ,
                           x_return_status OUT NOCOPY	VARCHAR2,
                           x_msg_count	   OUT NOCOPY	NUMBER,
                           x_msg_data	   OUT NOCOPY	VARCHAR2,
                           p_atnv_rec	   IN	atnv_rec_type) is
begin
  okc_atn_pvt.validate_row(p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           x_return_status => x_return_status,
                           p_atnv_rec      => p_atnv_rec);
end validate_article_translation;

end OKC_K_ARTICLE_PVT;

/
