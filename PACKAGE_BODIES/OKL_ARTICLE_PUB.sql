--------------------------------------------------------
--  DDL for Package Body OKL_ARTICLE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ARTICLE_PUB" AS
/* $Header: OKLPKATB.pls 115.2 2002/03/24 23:21:43 pkm ship        $ */
	G_API_TYPE	VARCHAR2(3) := 'PUB';
      G_UNEXPECTED_ERROR CONSTANT	VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
      G_SQLERRM_TOKEN	 CONSTANT	VARCHAR2(200) := 'SQLerrm';
      G_SQLCODE_TOKEN	 CONSTANT	VARCHAR2(200) := 'SQLcode';


  ----------------------------------------------------------------------------
  --Function to populate the articles record to be copied.
  ----------------------------------------------------------------------------
    FUNCTION    get_catv_rec(p_cat_id IN NUMBER,
				x_catv_rec OUT NOCOPY okc_k_article_pub.catv_rec_type)
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
		TEXT,
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
		x_catv_rec.TEXT,
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
				x_catv_rec OUT NOCOPY okc_k_article_pub.catv_rec_type)
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
		saev.TEXT,
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
		x_catv_rec.TEXT,
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
-- Procedure Name  : reference_article
-- Description     : creates a reference to a standard article
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
PROCEDURE reference_article(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sae_id			     IN  NUMBER,
    p_sae_release			     IN  VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_cle_id                       IN  NUMBER DEFAULT NULL,
    x_cat_id                       OUT NOCOPY NUMBER
  ) AS

    l_api_name	VARCHAR2(30) := 'reference_article';
    l_api_version	CONSTANT NUMBER	  := 1.0;

    l_catv_rec OKC_K_ARTICLE_PUB.catv_rec_type;
    x_catv_rec OKC_K_ARTICLE_PUB.catv_rec_type;

  BEGIN

    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
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


    OKC_K_ARTICLE_PUB.create_k_article(
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

    x_cat_id := x_catv_rec.id;

    OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
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
-- Procedure Name  : copy_article
-- Description     : creates a copy of a standard article
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
PROCEDURE copy_article(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sae_id			     IN  NUMBER,
    p_sae_release			     IN  VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_cle_id                       IN  NUMBER DEFAULT NULL,
    x_cat_id                       OUT NOCOPY NUMBER
  ) AS

    l_api_name	VARCHAR2(30) := 'copy_article';
    l_api_version	CONSTANT NUMBER	  := 1.0;

    l_catv_rec OKC_K_ARTICLE_PUB.catv_rec_type;
    x_catv_rec OKC_K_ARTICLE_PUB.catv_rec_type;

  BEGIN

    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
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

    OKC_K_ARTICLE_PUB.create_k_article(
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

    x_cat_id := x_catv_rec.id;

    OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
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
-- Procedure Name  : delete_article
-- Description     : deletes an article from a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
PROCEDURE delete_article(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cat_id			     IN  NUMBER
  ) AS

    l_api_name	VARCHAR2(30) := 'delete_article';
    l_api_version	CONSTANT NUMBER	  := 1.0;

    l_catv_rec OKC_K_ARTICLE_PUB.catv_rec_type;

  BEGIN

    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    x_return_status := get_catv_rec(p_cat_id 	=> p_cat_id,
					      x_catv_rec 	=> l_catv_rec);

    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    OKC_K_ARTICLE_PUB.delete_k_article(
         p_api_version     => l_api_version,
         p_init_msg_list   => p_init_msg_list,
         x_return_status   => x_return_status,
         x_msg_count       => x_msg_count,
         x_msg_data        => x_msg_data,
         p_catv_rec        => l_catv_rec);

    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
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


END OKL_ARTICLE_PUB;

/
