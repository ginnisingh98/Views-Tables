--------------------------------------------------------
--  DDL for Package Body OKL_VP_K_ARTICLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VP_K_ARTICLE_PVT" AS
/* $Header: OKLRCARB.pls 120.1 2005/08/04 01:31:11 manumanu noship $ */
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_VP_K_ARTICLE_PVT';
  G_CHILD_RECORD_FOUND        CONSTANT varchar2(200) := 'OKC_CHILD_RECORD_FOUND';
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;

  G_UNEXPECTED_ERROR CONSTANT	VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN	 CONSTANT	VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN	 CONSTANT	VARCHAR2(200) := 'SQLCODE';
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_API_TYPE	VARCHAR2(3) := 'PVT';
  ----------------------------------------------------------------------------
  --Function to populate the articles record to be copied.
  ----------------------------------------------------------------------------
    FUNCTION    get_catv_rec(p_cat_id IN NUMBER,
				x_catv_rec OUT NOCOPY catv_rec_type)
    				RETURN  VARCHAR2 IS
      l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_no_data_found BOOLEAN := TRUE;
      CURSOR c_catv_rec IS
      SELECT	ID,
		CHR_ID,
		CLE_ID,
		CAT_ID,
		SFWT_FLAG,
		SAV_SAE_ID,
		SAV_SAV_RELEASE,
		SBT_CODE,
		DNZ_CHR_ID,
		COMMENTS,
		FULLTEXT_YN,
		VARIATION_DESCRIPTION,
		NAME,
--		TEXT,
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15,
		CAT_TYPE
	FROM    OKC_K_ARTICLES_V
	WHERE 	ID = p_cat_id;
    BEGIN
      OPEN c_catv_rec;
      FETCH c_catv_rec
      INTO	x_catv_rec.ID,
		x_catv_rec.CHR_ID,
		x_catv_rec.CLE_ID,
		x_catv_rec.CAT_ID,
		x_catv_rec.SFWT_FLAG,
		x_catv_rec.SAV_SAE_ID,
		x_catv_rec.SAV_SAV_RELEASE,
		x_catv_rec.SBT_CODE,
		x_catv_rec.DNZ_CHR_ID,
		x_catv_rec.COMMENTS,
		x_catv_rec.FULLTEXT_YN,
		x_catv_rec.VARIATION_DESCRIPTION,
		x_catv_rec.NAME,
--		x_catv_rec.TEXT,
		x_catv_rec.ATTRIBUTE_CATEGORY,
		x_catv_rec.ATTRIBUTE1,
		x_catv_rec.ATTRIBUTE2,
		x_catv_rec.ATTRIBUTE3,
		x_catv_rec.ATTRIBUTE4,
		x_catv_rec.ATTRIBUTE5,
		x_catv_rec.ATTRIBUTE6,
		x_catv_rec.ATTRIBUTE7,
		x_catv_rec.ATTRIBUTE8,
		x_catv_rec.ATTRIBUTE9,
		x_catv_rec.ATTRIBUTE10,
		x_catv_rec.ATTRIBUTE11,
		x_catv_rec.ATTRIBUTE12,
		x_catv_rec.ATTRIBUTE13,
		x_catv_rec.ATTRIBUTE14,
		x_catv_rec.ATTRIBUTE15,
		x_catv_rec.CAT_TYPE;
      l_no_data_found := c_catv_rec%NOTFOUND;
      CLOSE c_catv_rec;
      IF l_no_data_found THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        return(l_return_status);
      ELSE
        return(l_return_status);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        return(l_return_status);
    END get_catv_rec;
  ----------------------------------------------------------------------------
  --Function to populate the articles record to be copied.
  ----------------------------------------------------------------------------
    FUNCTION    get_catv_rec(p_sae_id IN NUMBER,
                             p_sav_release IN VARCHAR2,
				x_catv_rec OUT NOCOPY catv_rec_type)
    				RETURN  VARCHAR2 IS
      l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_no_data_found BOOLEAN := TRUE;
      CURSOR c_catv_rec IS
      SELECT null,
		null,
		null,
		null,
		OKC_API.G_TRUE,
		null,
		null,
		sae.SBT_CODE,
		null,
		null,
		'Y',
		null,
		sae.NAME,
--		saev.TEXT,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		'NSD'
	FROM    okc_std_art_versions_v  saev
      ,       okc_std_articles_v      sae
	WHERE   sae.ID = p_sae_id
      AND     saev.sav_release = p_sav_release
      AND     sae.ID = saev.sae_id;
    BEGIN
      OPEN c_catv_rec;
      FETCH c_catv_rec
      INTO	x_catv_rec.ID,
		x_catv_rec.CHR_ID,
		x_catv_rec.CLE_ID,
		x_catv_rec.CAT_ID,
		x_catv_rec.SFWT_FLAG,
		x_catv_rec.SAV_SAE_ID,
		x_catv_rec.SAV_SAV_RELEASE,
		x_catv_rec.SBT_CODE,
		x_catv_rec.DNZ_CHR_ID,
		x_catv_rec.COMMENTS,
		x_catv_rec.FULLTEXT_YN,
		x_catv_rec.VARIATION_DESCRIPTION,
		x_catv_rec.NAME,
--		x_catv_rec.TEXT,
		x_catv_rec.ATTRIBUTE_CATEGORY,
		x_catv_rec.ATTRIBUTE1,
		x_catv_rec.ATTRIBUTE2,
		x_catv_rec.ATTRIBUTE3,
		x_catv_rec.ATTRIBUTE4,
		x_catv_rec.ATTRIBUTE5,
		x_catv_rec.ATTRIBUTE6,
		x_catv_rec.ATTRIBUTE7,
		x_catv_rec.ATTRIBUTE8,
		x_catv_rec.ATTRIBUTE9,
		x_catv_rec.ATTRIBUTE10,
		x_catv_rec.ATTRIBUTE11,
		x_catv_rec.ATTRIBUTE12,
		x_catv_rec.ATTRIBUTE13,
		x_catv_rec.ATTRIBUTE14,
		x_catv_rec.ATTRIBUTE15,
		x_catv_rec.CAT_TYPE;
      l_no_data_found := c_catv_rec%NOTFOUND;
      CLOSE c_catv_rec;
      IF l_no_data_found THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        return(l_return_status);
      ELSE
        return(l_return_status);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        return(l_return_status);
    END get_catv_rec;

-- Start of comments
--
-- Procedure Name  : create_article_by_reference
-- Description     : creates a reference to a standard article
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
PROCEDURE create_article_by_reference(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sae_id			           IN  NUMBER,
    p_sae_release			       IN  VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_cle_id                       IN  NUMBER DEFAULT NULL,
    p_comments                     IN VARCHAR2
  ) AS
    l_api_name	VARCHAR2(30) := 'create_article_by_reference';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_catv_rec catv_rec_type;
    x_catv_rec catv_rec_type;
  BEGIN
    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);
    -- check if activity started successfully
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    x_return_status := get_catv_rec(p_sae_id 	=> p_sae_id,
                                    p_sav_release => p_sae_release,
                                    x_catv_rec 	=> l_catv_rec);
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    l_catv_rec.dnz_chr_id := p_chr_id;
    if (p_cle_id is null) then
    	l_catv_rec.chr_id := p_chr_id;
      l_catv_rec.cle_id := null;
    else
	l_catv_rec.chr_id := null;
      l_catv_rec.cle_id := p_cle_id;
    end if;
    l_catv_rec.object_version_number := 1.0;
    l_catv_rec.sfwt_flag := OKC_API.G_TRUE;
    l_catv_rec.sav_sae_id := p_sae_id;
    l_catv_rec.sav_sav_release := p_sae_release;
    l_catv_rec.cat_type := 'STA';
    l_catv_rec.fulltext_yn := 'Y';
    l_catv_rec.comments := p_comments;
    l_catv_rec.NAME := NULL;
    l_catv_rec.SBT_CODE := NULL;


    OKL_OKC_MIGRATION_A_PVT.insert_row(
         p_api_version     => l_api_version,
         p_init_msg_list   => p_init_msg_list,
         x_return_status   => x_return_status,
         x_msg_count       => x_msg_count,
         x_msg_data        => x_msg_data,
         p_catv_rec        => l_catv_rec,
         x_catv_rec        => x_catv_rec);
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;
--    x_cat_id := x_catv_rec.id;
    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
			 x_msg_data	=> x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END;


-- Start of comments
--
-- Procedure Name  : copy_article
-- Description     : creates a copy of a standard article
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
PROCEDURE create_article_by_copy(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sae_id			     IN  NUMBER,
    p_sae_release			     IN  VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_cle_id                       IN  NUMBER DEFAULT NULL,
    p_comments                     IN VARCHAR2
  ) AS
    l_api_name	VARCHAR2(30) := 'create_article_by_copy';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_catv_rec catv_rec_type;
    x_catv_rec catv_rec_type;

CURSOR cur_text IS
SELECT text
FROM okc_std_art_versions_v
WHERE sae_id = p_sae_id
AND sav_release = p_sae_release;

l_clob_text CLOB;

  BEGIN
    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);
    -- check if activity started successfully
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;
    x_return_status := get_catv_rec(p_sae_id 	=> p_sae_id,
                                    p_sav_release => p_sae_release,
                                    x_catv_rec 	=> l_catv_rec);
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;
    l_catv_rec.dnz_chr_id := p_chr_id;
    if (p_cle_id is null) then
    	l_catv_rec.chr_id := p_chr_id;
      l_catv_rec.cle_id := null;
    else
	l_catv_rec.chr_id := null;
      l_catv_rec.cle_id := p_cle_id;
    end if;
    l_catv_rec.object_version_number := 1.0;
    l_catv_rec.sfwt_flag := OKC_API.G_TRUE;
    l_catv_rec.comments := p_comments;
    l_catv_rec.FULLTEXT_YN := NULL;
    l_catv_rec.VARIATION_DESCRIPTION := NULL;
    l_catv_rec.SAV_SAE_ID := NULL;
    l_catv_rec.SAV_SAV_RELEASE := NULL;


    OKL_OKC_MIGRATION_A_PVT.insert_row(
         p_api_version     => l_api_version,
         p_init_msg_list   => p_init_msg_list,
         x_return_status   => x_return_status,
         x_msg_count       => x_msg_count,
         x_msg_data        => x_msg_data,
         p_catv_rec        => l_catv_rec,
         x_catv_rec        => x_catv_rec);
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;
  -- Begin updating text
  OPEN cur_text;
  FETCH cur_text INTO l_clob_text;
  IF(cur_text%found) THEN
    NULL;
    CLOSE cur_text;
  ELSE
    CLOSE cur_text;
    --OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name => 'article text cannot copy');
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  -- Fix for bug 3254597. OKC 11.5.10 COMPATIBLE FIXES

    --UPDATE okc_k_articles_v SET text = l_clob_text
    --WHERE id = x_catv_rec.id;

      x_return_status := OKC_UTIL.Copy_Articles_Varied_Text(
      			p_article_id  => x_catv_rec.id,  -- contract article id
      			p_sae_id      => p_sae_id,      -- standard article id
      			lang          => USERENV('LANG'));
      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      End If;

  -- END FIX 3254597 --

--    x_cat_id := x_catv_rec.id;
    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
			 x_msg_data	=> x_msg_data);
  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
     		p_api_type  => g_api_type);
    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END;


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
null;
--  okl_okc_migration_a_pvt.add_language;
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
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_catv_rec	IN	catv_rec_type,
                              x_catv_rec	OUT NOCOPY	catv_rec_type) is
l_catv_rec 		catv_rec_type 	:= p_catv_rec;
l_cvmv_rec  	OKC_CVM_PVT.cvmv_rec_type;
x_out_rec    	OKC_CVM_PVT.cvmv_rec_type;
l_api_name	VARCHAR2(30) := 'create_k_article';
l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
begin

x_return_status := OKL_API.G_RET_STS_SUCCESS;
    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => p_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);
    -- check if activity started successfully
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

-- Not null Validation for Article Name
IF ((l_catv_rec.name = OKL_API.G_MISS_CHAR) OR (l_catv_rec.name IS NULL)) THEN
  OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name => 'OKL_ARTICLE_NAME_REQUIRED');
  x_return_status :=okl_api.g_ret_sts_error;
  RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

IF (p_catv_rec.cat_type = 'STA') THEN
create_article_by_reference(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_catv_rec.sav_sae_id,
    p_catv_rec.sav_sav_release,
    p_catv_rec.chr_id,
    p_catv_rec.cle_id,
    p_catv_rec.comments
  );
ELSIF (p_catv_rec.cat_type = 'NSD') THEN
create_article_by_copy(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_catv_rec.sav_sae_id,
    p_catv_rec.sav_sav_release,
    p_catv_rec.chr_id,
    p_catv_rec.cle_id,
    p_catv_rec.comments
  );
ELSE
-- raise an error saying that the parameter cat_type can only have values in ('STA','NSD')
       OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'cat_type values in (STA,NSD)');
       RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

    /* Manu 29-Jun-2005 Begin */
  IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
    OKL_VENDOR_PROGRAM_PVT.passed_to_incomplete(p_api_version    => p_api_version
                         ,p_init_msg_list => p_init_msg_list
                         ,x_return_status => x_return_status
                         ,x_msg_count     => x_msg_count
                         ,x_msg_data      => x_msg_data
                         ,p_program_id    => p_catv_rec.chr_id
                        );
  END IF;
    /* Manu 29-Jun-2005 END */


    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
			 x_msg_data	=> x_msg_data);
EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
end create_k_article;


-- Start of comments
--
-- Procedure Name  : update_k_article
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure update_k_article(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_catv_rec	IN	catv_rec_type,
                              x_catv_rec	OUT NOCOPY	catv_rec_type) is
l_catv_rec 		catv_rec_type 	:= p_catv_rec;

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
  okl_okc_migration_a_pvt.update_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_catv_rec      => l_catv_rec,
                         x_catv_rec      => x_catv_rec);

    /* Manu 29-Jun-2005 Begin */
  IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
    OKL_VENDOR_PROGRAM_PVT.passed_to_incomplete(p_api_version    => p_api_version
                         ,p_init_msg_list => p_init_msg_list
                         ,x_return_status => x_return_status
                         ,x_msg_count     => x_msg_count
                         ,x_msg_data      => x_msg_data
                         ,p_program_id    => x_catv_rec.chr_id
                        );
  END IF;
    /* Manu 29-Jun-2005 END */


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
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_catv_rec	IN	catv_rec_type) is
     l_return_status     VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
     l_chr_id            OKL_VP_ASSOCIATIONS.CHR_ID%TYPE;


     CURSOR cur_get_chr_id IS
     SELECT dnz_chr_id
     FROM   okc_k_articles_v
     WHERE  id = p_catv_rec.id;
BEGIN


    /* Manu 29-Jun-2005 Begin */
    OPEN  cur_get_chr_id;
    FETCH cur_get_chr_id INTO l_chr_id;
    CLOSE cur_get_chr_id;
    /* Manu 29-Jun-2005 END */

  okl_okc_migration_a_pvt.delete_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_catv_rec      => p_catv_rec);


    /* Manu 29-Jun-2005 Begin */
  IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
    OKL_VENDOR_PROGRAM_PVT.passed_to_incomplete(p_api_version    => p_api_version
                         ,p_init_msg_list => p_init_msg_list
                         ,x_return_status => x_return_status
                         ,x_msg_count     => x_msg_count
                         ,x_msg_data      => x_msg_data
                         ,p_program_id    => l_chr_id
                        );
  END IF;
    /* Manu 29-Jun-2005 END */



END delete_k_article;

function emptyClob return clob is
c1 clob;
begin
dbms_lob.createtemporary(c1,true);
-- c1 := empty_clob();
dbms_lob.open(c1,dbms_lob.lob_readwrite);
dbms_lob.write(c1,1,1,' ');
return c1;
end;

END; -- Package Body OKL_VP_K_ARTICLE_PVT

/
