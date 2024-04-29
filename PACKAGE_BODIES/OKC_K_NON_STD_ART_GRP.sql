--------------------------------------------------------
--  DDL for Package Body OKC_K_NON_STD_ART_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_K_NON_STD_ART_GRP" AS
/* $Header: OKCGNSAB.pls 120.3.12010000.7 2011/12/09 13:36:23 serukull ship $ */
 l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                    CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_K_NON_STD_ART_GRP';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_FALSE	               CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;
  G_RET_STS_SUCCESS            CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
  G_AMEND_CODE_ADDED           CONSTANT   VARCHAR2(30) := 'ADDED';
  G_AMEND_CODE_UPDATED         CONSTANT   VARCHAR2(30) := 'UPDATED';

  G_MISS_NUM                   CONSTANT   NUMBER      := FND_API.G_MISS_NUM;
  G_MISS_CHAR                  CONSTANT   VARCHAR2(1) := FND_API.G_MISS_CHAR;
  G_MISS_DATE                  CONSTANT   DATE        := FND_API.G_MISS_DATE;

  G_DBG_LEVEL							  NUMBER 		:= FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_PROC_LEVEL							  NUMBER		:= FND_LOG.LEVEL_PROCEDURE;
  G_EXCP_LEVEL							  NUMBER		:= FND_LOG.LEVEL_EXCEPTION;

Procedure create_non_std_article(
    p_api_version                IN NUMBER,
    p_init_msg_list              IN VARCHAR2,
    p_validate_commit            IN VARCHAR2,
    p_validation_string          IN VARCHAR2,
    p_commit                     IN VARCHAR2,
    p_mode                       IN VARCHAR2, -- Values 'NORMAL' and  'AMEND'
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    p_article_title              IN VARCHAR2,
    p_article_type               IN VARCHAR2,

-- Article Version Attributes
    p_article_text               IN CLOB,
    p_provision_yn               IN VARCHAR2,
    p_std_article_version_id     IN NUMBER,
    p_display_name               IN VARCHAR2,
    p_article_description        IN VARCHAR2,
    p_edited_in_word             IN VARCHAR2 DEFAULT 'N',
 	  p_article_text_in_word       IN BLOB DEFAULT NULL,

-- K Article Attributes
    p_ref_type                   IN VARCHAR2,
    p_ref_id                     IN NUMBER,
    p_doc_type                   IN VARCHAR2,
    p_doc_id                     IN NUMBER,
    p_cat_id                     IN NUMBER, -- Should be passed when existing std is modified to make non-std.If it is passed then ref_type and ref_id doesnt need to be passed.

    p_amendment_description      IN VARCHAR2,
    p_print_text_yn              IN VARCHAR2,
    x_cat_id                     OUT NOCOPY NUMBER,
    x_article_version_id         OUT NOCOPY NUMBER,
    p_lock_terms_yn              IN  VARCHAR2
    ) IS

    l_api_version             CONSTANT NUMBER := 1;
    l_api_name                CONSTANT VARCHAR2(30) := 'g_create_non_std_article';
    l_intent                 VARCHAR2(1);
    lx_article_id             NUMBER;
    l_std_article_id          NUMBER;
    lx_article_number         okc_articles_all.article_number%TYPE;
    -- Fix for bug# 5158268. Added variable for  article_number
    l_article_number         okc_articles_all.article_number%TYPE;
    l_amendment_description   okc_k_articles_b.amendment_description%TYPE;
    l_kart_tbl                OKC_TERMS_MULTIREC_GRP.kart_tbl_type;
    lx_kart_tbl               OKC_TERMS_MULTIREC_GRP.kart_tbl_type;
    l_ref_article_id          okc_k_articles_b.ref_article_id%TYPE := NULL;
    l_ref_article_version_id  okc_k_articles_b.ref_article_version_id%TYPE := NULL;
Cursor l_get_intent_csr IS
SELECT intent FROM OKC_BUS_DOC_TYPES_B
WHERE DOCUMENT_TYPE=P_DOC_TYPE;


-- Fix for bug# 5158268. Modified the cursor to query okc_articles_all for article_number
Cursor l_get_std_article IS
SELECT ver.article_id,ver.article_version_id, art.article_number
FROM OKC_ARTICLE_VERSIONS ver, okc_articles_all art
WHERE ver.ARTICLE_VERSION_ID=p_std_article_version_id
      and art.article_id = ver.article_id;


BEGIN

    /*IF (l_debug = 'Y') THEN
       okc_debug.log('100: Entered create_non_std_article', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '100: Entered create_non_std_article' );
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_create_non_std_article_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

   IF FND_API.To_Boolean( p_validate_commit ) THEN

      IF  NOT FND_API.To_Boolean(OKC_TERMS_UTIL_GRP.ok_to_commit (
                                         p_api_version => l_api_version,
                                         p_init_msg_list => FND_API.G_FALSE,
                                         p_doc_type	 => p_doc_type,
                                         p_doc_id	 => p_doc_id,
                                         p_validation_string => p_validation_string,
                                         x_return_status => x_return_status,
                                         x_msg_data	 => x_msg_data,
                                         x_msg_count	 => x_msg_count)                  ) THEN

           /*IF (l_debug = 'Y') THEN
                okc_debug.log('110: Issue with document header Record.Cannot commit', 2);
           END IF;*/

	   IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
 	       FND_LOG.STRING(G_PROC_LEVEL,
  	           G_PKG_NAME, '110: Issue with document header Record.Cannot commit' );
	   END IF;
           RAISE FND_API.G_EXC_ERROR ;
        END IF;
  END IF;

    --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*IF (l_debug = 'Y') THEN
      okc_debug.log('200: Creating non-std article', 2);
  END IF;*/

  IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '200: Creating non-std article' );
  END IF;
  OPEN  l_get_intent_csr;
  FETCH l_get_intent_csr INTO l_intent;
  CLOSE l_get_intent_csr;

-- Fix for bug# 5158268. added variable for article_number
  OPEN  l_get_std_article;
  FETCH l_get_std_article INTO l_ref_article_id,l_ref_article_version_id, l_article_number;
  CLOSE l_get_std_article;


  OKC_ARTICLES_GRP.create_article(
                       p_api_version                  => 1,
                       p_init_msg_list                => FND_API.G_FALSE,
                       p_validation_level	          => FND_API.G_VALID_LEVEL_FULL,
                       p_commit                       => FND_API.G_FALSE,
                       x_return_status                => x_return_status,
                       x_msg_count                    => x_msg_count,
                       x_msg_data                     => x_msg_data,
                       p_article_title                => p_article_title,
                       p_article_number               => l_article_number,
                       p_standard_yn                  =>'N',
                       p_article_intent               => l_intent,
                       p_article_language             => USERENV('LANG'),
                       p_article_type                 => p_article_type,
                       p_orig_system_reference_code   => NULL,
                       p_orig_system_reference_id1    => NULL,
                       p_orig_system_reference_id2    => NULL,
                       p_cz_transfer_status_flag      => 'N',
                       x_article_id                   => lx_article_id,
                       x_article_number               => lx_article_number,
                       -- Article Version Attributes
                       p_article_text                 => p_article_text,
                       p_provision_yn                 => p_provision_yn,
                       p_insert_by_reference          => 'N',
                       p_lock_text                    => 'N',
                       p_global_yn                    =>'N',
                       p_article_status               => NULL,
                       p_sav_release                  => NULL,
                       p_start_date                   => NULL,
                       p_end_date                     => NULL,
                       p_std_article_version_id       => p_std_article_version_id,
                       p_display_name                 => p_display_name,
                       p_translated_yn                => 'N',
                       p_article_description          => p_article_description,
                       p_date_approved                => NULL,
                       p_default_section              => NULL,
                       p_reference_source             => NULL,
                       p_reference_text               => NULL,
                       p_additional_instructions      => NULL,
                       p_variation_description        => NULL,
                       p_v_orig_system_reference_code => NULL,
                       p_v_orig_system_reference_id1  => NULL,
                       p_v_orig_system_reference_id2  => NULL,
                       p_global_article_version_id    => NULL,
                       p_edited_in_word               => p_edited_in_word,
 	                     p_article_text_in_word         => p_article_text_in_word,
                       x_article_version_id           => x_article_version_id
                               );

    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------


    /*IF (l_debug = 'Y') THEN
        okc_debug.log('300: non-std article created.Version id is '||x_article_version_id, 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '300: non-std article created.Version id is '||x_article_version_id );
    END IF;

    IF p_cat_id IS NOT NULL THEN

      /*IF (l_debug = 'Y') THEN
            okc_debug.log('400: Updating k article record', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '400: Updating k article record' );
      END IF;

      OKC_K_ARTICLES_GRP.update_article(
                                   p_api_version       =>1,
                                   p_init_msg_list     => FND_API.G_FALSE,
                                   p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
                                   p_validate_commit   => FND_API.G_FALSE,
                                   p_validation_string => NULL,
                                   p_commit            => FND_API.G_FALSE,
                                   p_mode              => p_mode,
                                   x_return_status     => x_return_status,
                                   x_msg_count         => x_msg_count,
                                   x_msg_data          => x_msg_data,
                                   p_id                => p_cat_id,
                                   p_sav_sae_id        => lx_article_id,
                                   p_amendment_description => p_amendment_description,
                                   p_print_text_yn         => p_print_text_yn,
                                   p_article_version_id    => x_article_version_id,
                                   p_ref_article_id        => l_ref_article_id ,
                                   p_ref_article_version_id=> l_ref_article_version_id,
                                   p_change_nonstd_yn      => 'N',
                                   p_object_version_number => NULL,
                                   p_lock_terms_yn         =>  p_lock_terms_yn
                                     );
      --------------------------------------------
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR ;
      END IF;
      --------------------------------------------

      x_cat_id := p_cat_id;

    ELSE

       l_kart_tbl(0).sav_sae_id            := lx_article_id;
       l_kart_tbl(0).article_version_id    := x_article_version_id;
       l_kart_tbl(0).print_text_yn         := p_print_text_yn;
       l_kart_tbl(0).ref_article_id        := l_ref_article_id;
       l_kart_tbl(0).ref_article_version_id:= l_ref_article_version_id;
       l_kart_tbl(0).amendment_description := p_amendment_description;

       /*IF (l_debug = 'Y') THEN
           okc_debug.log('500: Creating k article record', 2);
       END IF;*/

       IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
           FND_LOG.STRING(G_PROC_LEVEL,
               G_PKG_NAME, '500: Creating k article record' );
       END IF;

       OKC_TERMS_MULTIREC_GRP.create_article(
             p_api_version        =>1,
             p_init_msg_list      => FND_API.G_FALSE,
             p_mode               => p_mode,
             p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
             p_validate_commit    => FND_API.G_FALSE,
             p_validation_string  => NULL,
             p_commit             => FND_API.G_FALSE,
             p_ref_type           => p_ref_type,
             p_ref_id             => p_ref_id,
             p_doc_type           => p_doc_type,
             p_doc_id             => p_doc_id,
             p_kart_tbl           => l_kart_tbl,
             x_kart_tbl           => lx_kart_tbl,
             x_return_status      => x_return_status,
             x_msg_count          => x_msg_count,
             x_msg_data           => x_msg_count
                 );

       --------------------------------------------
       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR ;
       END IF;
       --------------------------------------------

       x_cat_id := lx_kart_tbl(0).id;

    END IF;


-- Standard check of p_commit
IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
END IF;

-- Standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

/*IF (l_debug = 'Y') THEN
     okc_debug.log('900: Leaving create_non_std_article', 2);
END IF;*/

IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '900: Leaving create_non_std_article' );
END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    /*IF (l_debug = 'Y') THEN
        okc_debug.log('300: Leaving create_non_std_article: OKC_API.G_EXCEPTION_ERROR Exception', 2);
    END IF;*/

    IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_EXCP_LEVEL,
    	    G_PKG_NAME, '300: Leaving create_non_std_article: OKC_API.G_EXCEPTION_ERROR Exception' );
    END IF;

    IF l_get_intent_csr%ISOPEN THEN
       CLOSE l_get_intent_csr;
    END IF;

    ROLLBACK TO g_create_non_std_article_GRP;
    x_return_status := G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    /*IF (l_debug = 'Y') THEN
         okc_debug.log('400: Leaving create_non_std_article: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
    END IF;*/

    IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_EXCP_LEVEL,
    	    G_PKG_NAME, '400: Leaving create_non_std_article: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception' );
    END IF;

    IF l_get_intent_csr%ISOPEN THEN
       CLOSE l_get_intent_csr;
    END IF;

    ROLLBACK TO g_create_non_std_article_GRP;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 WHEN OTHERS THEN
    /*IF (l_debug = 'Y') THEN
       okc_debug.log('500: Leaving create_non_std_article because of EXCEPTION: '||sqlerrm, 2);
    END IF;*/

    IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_EXCP_LEVEL,
    	    G_PKG_NAME, '500: Leaving create_non_std_article because of EXCEPTION: '||sqlerrm );
    END IF;

    IF l_get_intent_csr%ISOPEN THEN
       CLOSE l_get_intent_csr;
    END IF;

    ROLLBACK TO g_create_non_std_article_GRP;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;

    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END  create_non_std_article;

Procedure update_non_std_article(
    p_api_version                IN NUMBER,
    p_init_msg_list              IN VARCHAR2 ,
    p_validate_commit            IN VARCHAR2,
    p_validation_string          IN VARCHAR2,
    p_commit                     IN VARCHAR2,
    p_mode                       IN VARCHAR2,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    p_article_title              IN VARCHAR2,
    p_article_type               IN VARCHAR2,

-- Article Version Attributes
    p_article_text               IN CLOB,
    p_provision_yn               IN VARCHAR2,
    p_display_name               IN VARCHAR2,
    p_article_description        IN VARCHAR2,
    p_edited_in_word             IN VARCHAR2 DEFAULT 'N',
 	  p_article_text_in_word       IN BLOB DEFAULT NULL,

-- K Article Attributes
    p_doc_type                   IN VARCHAR2,
    p_doc_id                     IN NUMBER,
    p_cat_id                     IN NUMBER,
    p_amendment_description      IN VARCHAR2,
    p_print_text_yn              IN VARCHAR2,
    x_cat_id                     OUT NOCOPY NUMBER,
    x_article_version_id         OUT NOCOPY NUMBER,
    p_lock_terms_yn              IN  VARCHAR2
    ) IS

    l_api_version             CONSTANT NUMBER := 1;
    l_api_name                CONSTANT VARCHAR2(30) := 'g_update_non_std_article';
    l_article_id             NUMBER;
    l_ref_article_version_id NUMBER;
    l_change_nonstd_yn       VARCHAR2(1);
    l_ovn                    NUMBER;



Cursor l_get_kart_dtl_csr IS
SELECT sav_sae_id,
       article_version_id,
       ref_article_version_id,
       change_nonstd_yn,
       object_version_number
FROM OKC_K_ARTICLES_B
WHERE id=p_cat_id;

l_display_name          okc_article_versions.display_name%TYPE;
l_article_description   okc_article_versions.article_description%TYPE;


BEGIN
    /*IF (l_debug = 'Y') THEN
       okc_debug.log('100: Entered update_non_std_article', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '100: Entered update_non_std_article' );
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_update_non_std_article_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

   IF FND_API.To_Boolean( p_validate_commit ) THEN

      IF  NOT FND_API.To_Boolean(OKC_TERMS_UTIL_GRP.ok_to_commit (
                                         p_api_version => l_api_version,
                                         p_init_msg_list => FND_API.G_FALSE,
                                         p_doc_type	 => p_doc_type,
                                         p_doc_id	 => p_doc_id,
                                         p_validation_string => p_validation_string,
                                         x_return_status => x_return_status,
                                         x_msg_data	 => x_msg_data,
                                         x_msg_count	 => x_msg_count)                  ) THEN

           /*IF (l_debug = 'Y') THEN
                okc_debug.log('110: Issue with document header Record.Cannot commit', 2);
           END IF;*/

           IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
               FND_LOG.STRING(G_PROC_LEVEL,
                   G_PKG_NAME, '110: Issue with document header Record.Cannot commit' );
           END IF;
           RAISE FND_API.G_EXC_ERROR ;
        END IF;
  END IF;

    --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*IF (l_debug = 'Y') THEN
      okc_debug.log('200: Updating non-std article', 2);
  END IF;*/

  IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '200: Updating non-std article' );
  END IF;

  OPEN  l_get_kart_dtl_csr;
  FETCH l_get_kart_dtl_csr INTO l_article_id,x_article_version_id,l_ref_article_version_id,l_change_nonstd_yn,l_ovn;
  CLOSE l_get_kart_dtl_csr;
  IF l_change_nonstd_yn='Y' THEN

      -- check if any parameters are NULL from UI
      IF (p_display_name = G_MISS_CHAR) THEN
          l_display_name := NULL;
      ELSIF (p_display_name IS NOT NULL) THEN
          l_display_name := p_display_name;
      END IF;

      IF (p_article_description = G_MISS_CHAR) THEN
          l_article_description := NULL;
      ELSIF (p_article_description IS NOT NULL ) THEN
          l_article_description := p_article_description;
      END IF;

      create_non_std_article(
                p_api_version     =>1,
                p_init_msg_list   => FND_API.G_FALSE,
                p_validate_commit => FND_API.G_FALSE,
                p_validation_string => NULL,
                p_commit            => FND_API.G_FALSE,
                p_mode              => p_mode,
                x_return_status     => x_return_status,
                x_msg_count         => x_msg_count,
                x_msg_data          => x_msg_data,
                p_article_title     => p_article_title,
                p_article_text      => p_article_text,
                p_provision_yn      => p_provision_yn,
                p_std_article_version_id => l_ref_article_version_id,
                p_display_name           => l_display_name,
                p_article_type           => p_article_type,
                p_article_description     => l_article_description,
                p_edited_in_word          => p_edited_in_word,
 	              p_article_text_in_word    => p_article_text_in_word,
                p_ref_type                => NULL,
                p_ref_id                  =>NULL,
                p_doc_type                =>P_doc_type,
                p_doc_id                  =>P_doc_id,
                p_cat_id                  => p_cat_id,
                p_amendment_description   => p_amendment_description,
                p_print_text_yn           => p_print_text_yn,
                x_cat_id                  => x_cat_id,
                x_article_version_id      => x_article_version_id,
                p_lock_terms_yn           => p_lock_terms_yn
             );
  ELSE
  OKC_ARTICLES_GRP.update_article(
                       p_api_version                  => 1,
                       p_init_msg_list                => FND_API.G_FALSE,
                       p_validation_level	          => FND_API.G_VALID_LEVEL_FULL,
                       p_commit                       => FND_API.G_FALSE,
                       x_return_status                => x_return_status,
                       x_msg_count                    => x_msg_count,
                       x_msg_data                     => x_msg_data,
                       p_article_id                   => l_article_id,
                       p_article_title                => p_article_title,
                       p_article_number               => NULL,
                       p_standard_yn                  => NULL,
                       p_article_intent               => NULL,
                       p_article_language             => NULL,
                       p_article_type                 => p_article_type,
                       p_orig_system_reference_code   => NULL,
                       p_orig_system_reference_id1    => NULL,
                       p_orig_system_reference_id2    => NULL,
                       p_cz_transfer_status_flag      => NULL,
                       p_object_version_number        => NULL,
                       -- Article Version Attributes
                       p_article_version_id           => x_article_version_id,
                       p_article_text                 => p_article_text,
                       p_provision_yn                 => p_provision_yn,
                       p_insert_by_reference          => NULL,
                       p_lock_text                    => NULL,
                       p_global_yn                    => NULL,
                       p_article_status               => NULL,
                       p_sav_release                  => NULL,
                       p_start_date                   => NULL,
                       p_end_date                     => NULL,
                       p_std_article_version_id       => NULL,
                       p_display_name                 => p_display_name,
                       p_translated_yn                => NULL,
                       p_article_description          => p_article_description,
                       p_date_approved                => NULL,
                       p_default_section              => NULL,
                       p_reference_source             => NULL,
                       p_reference_text               => NULL,
                       p_additional_instructions      => NULL,
                       p_variation_description        => NULL,
                       p_v_orig_system_reference_code => NULL,
                       p_v_orig_system_reference_id1  => NULL,
                       p_v_orig_system_reference_id2  => NULL,
                       p_v_object_version_number      => NULL,
                       p_edited_in_word               => p_edited_in_word,
 	                     p_article_text_in_word         => p_article_text_in_word
                               );


    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------


    /*IF (l_debug = 'Y') THEN
        okc_debug.log('300: non-std article created.Version id is '||x_article_version_id, 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '300: non-std article created.Version id is '||x_article_version_id );
    END IF;

    /*IF (l_debug = 'Y') THEN
            okc_debug.log('400: Updating k article record', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '400: Updating k article record' );
    END IF;

      OKC_K_ARTICLES_GRP.update_article(
                                   p_api_version       =>1,
                                   p_init_msg_list     => FND_API.G_FALSE,
                                   p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
                                   p_validate_commit   => FND_API.G_FALSE,
                                   p_validation_string => NULL,
                                   p_commit            => FND_API.G_FALSE,
                                   p_mode              => p_mode,
                                   x_return_status     => x_return_status,
                                   x_msg_count         => x_msg_count,
                                   x_msg_data          => x_msg_data,
                                   p_id                => p_cat_id,
                                   p_sav_sae_id        => l_article_id,
                                   p_amendment_description => p_amendment_description,
                                   p_print_text_yn            =>p_print_text_yn,
                                   p_article_version_id       => x_article_version_id,
                                   p_object_version_number    => l_ovn,
                                   p_lock_terms_yn            => p_lock_terms_yn
                                     );
      --------------------------------------------
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR ;
      END IF;
      --------------------------------------------
 END IF; -- IF change_nonstd_yn='Y' THEN

-- Standard check of p_commit
IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
END IF;

-- Standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

/*IF (l_debug = 'Y') THEN
     okc_debug.log('900: Leavingupdate_non_std_article', 2);
END IF;*/

IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '900: Leavingupdate_non_std_article' );
END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    /*IF (l_debug = 'Y') THEN
        okc_debug.log('300: Leaving update_non_std_article: OKC_API.G_EXCEPTION_ERROR Exception', 2);
    END IF;*/

    IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_EXCP_LEVEL,
    	    G_PKG_NAME, '300: Leaving update_non_std_article: OKC_API.G_EXCEPTION_ERROR Exception' );
    END IF;

    IF l_get_kart_dtl_csr%ISOPEN THEN
       CLOSE l_get_kart_dtl_csr;
    END IF;


    ROLLBACK TO g_update_non_std_article_GRP;
    x_return_status := G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    /*IF (l_debug = 'Y') THEN
         okc_debug.log('400: Leavingupdate_non_std_article: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
    END IF;*/

    IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_EXCP_LEVEL,
    	    G_PKG_NAME, '400: Leavingupdate_non_std_article: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception' );
    END IF;

    IF l_get_kart_dtl_csr%ISOPEN THEN
       CLOSE l_get_kart_dtl_csr;
    END IF;


    ROLLBACK TO g_update_non_std_article_GRP;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 WHEN OTHERS THEN
    /*IF (l_debug = 'Y') THEN
       okc_debug.log('500: Leaving update_non_std_article because of EXCEPTION: '||sqlerrm, 2);
    END IF;*/

    IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_EXCP_LEVEL,
    	    G_PKG_NAME, '500: Leaving update_non_std_article because of EXCEPTION: '||sqlerrm );
    END IF;

    IF l_get_kart_dtl_csr%ISOPEN THEN
       CLOSE l_get_kart_dtl_csr;
    END IF;


    ROLLBACK TO g_update_non_std_article_GRP;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;

    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
END update_non_std_article;

Procedure revert_to_standard(
    p_api_version                IN NUMBER,
    p_init_msg_list              IN VARCHAR2 ,
    p_validate_commit            IN VARCHAR2,
    p_validation_string          IN VARCHAR2,
    p_commit                     IN VARCHAR2,
    p_mode                       IN VARCHAR2,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    p_doc_type                   IN VARCHAR2,
    p_doc_id                     IN NUMBER,
    p_k_art_id                   IN NUMBER,
    x_cat_id                     OUT NOCOPY NUMBER,
    x_article_version_id         OUT NOCOPY NUMBER,
    p_lock_terms_yn              IN  VARCHAR2
    ) IS

    l_api_version             CONSTANT NUMBER := 1;
    l_api_name                CONSTANT VARCHAR2(30) := 'revert_to_standard';
    l_sav_sae_id              OKC_K_ARTICLES_B.sav_sae_id%TYPE;
    l_scn_id                  OKC_K_ARTICLES_B.scn_id%TYPE;
    l_orig_article_id         OKC_K_ARTICLES_B.orig_article_id%TYPE;
    l_ref_article_version_id  OKC_K_ARTICLES_B.ref_article_version_id%TYPE;
    l_display_sequence        OKC_K_ARTICLES_B.display_sequence%TYPE;
    l_ovn                     OKC_K_ARTICLES_B.object_version_number%TYPE;
    l_variable_value_id       OKC_K_ART_VARIABLES.variable_value_id%TYPE;
    l_variable_value          OKC_K_ART_VARIABLES.variable_value%TYPE;
    l_x_cat_id                OKC_K_ART_VARIABLES.cat_id%TYPE;
    l_x_variable_code         OKC_K_ART_VARIABLES.variable_code%TYPE;
    l_ref_article_id          OKC_K_ARTICLES_B.ref_article_id%TYPE;


Cursor l_get_kart_dtl_csr IS
SELECT sav_sae_id, scn_id , orig_article_id, display_sequence, object_Version_number,
       ref_article_id
FROM OKC_K_ARTICLES_B
WHERE id=p_k_art_id ;

cursor l_get_delete_var IS
    select variable_code, object_Version_number from okc_k_art_variables
    where variable_code not in (
        select artvar.variable_code
        from okc_k_art_variables artvar, okc_article_variables ar
        where ar.variable_code = artvar.variable_code
        and artvar.cat_id = p_k_art_id
        and ar.article_version_id = x_article_version_id)
    and cat_id = p_k_art_id;

cursor l_get_insert_var IS
  select  var.variable_code, bus.variable_type,bus.external_yn,bus.value_set_id
          from okc_article_variables var, okc_bus_variables_b bus
          where var.variable_code not in (
                        select artvar.variable_code
                        from okc_k_art_variables artvar, okc_article_variables ar
                        where ar.variable_code = artvar.variable_code
                        and artvar.cat_id = p_k_art_id
                        and ar.article_version_id = x_article_version_id
                  )
          and var.article_version_id = x_article_version_id
          and var.variable_code = bus.variable_code;



BEGIN
    /*IF (l_debug = 'Y') THEN
       okc_debug.log('100: Entered revert_to_standard', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '100: Entered revert_to_standard' );
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_revert_to_standard_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

   IF FND_API.To_Boolean( p_validate_commit ) THEN

      IF  NOT FND_API.To_Boolean(OKC_TERMS_UTIL_GRP.ok_to_commit (
                                         p_api_version => l_api_version,
                                         p_init_msg_list => FND_API.G_FALSE,
                                         p_doc_type	 => p_doc_type,
                                         p_doc_id	 => p_doc_id,
                                         p_validation_string => p_validation_string,
                                         x_return_status => x_return_status,
                                         x_msg_data	 => x_msg_data,
                                         x_msg_count	 => x_msg_count)                  ) THEN

           /*IF (l_debug = 'Y') THEN
                okc_debug.log('110: Issue with document header Record.Cannot commit', 2);
           END IF;*/

	   IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
 	       FND_LOG.STRING(G_PROC_LEVEL,
  	           G_PKG_NAME, '110: Issue with document header Record.Cannot commit' );
	   END IF;
           RAISE FND_API.G_EXC_ERROR ;
        END IF;
  END IF;

    --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*IF (l_debug = 'Y') THEN
      okc_debug.log('200: revert_to_standard', 2);
  END IF;*/

  IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '200: revert_to_standard' );
  END IF;

  OPEN  l_get_kart_dtl_csr;
  FETCH l_get_kart_dtl_csr
  INTO  l_sav_sae_id, l_scn_id, l_orig_article_id,l_display_sequence, l_ovn, l_ref_article_id;

  if(l_ref_article_id is NOT NULL)THEN
     l_orig_article_id := l_ref_article_id;
  end if;
--  x_article_version_id := l_ref_article_version_id;
  x_article_version_id := OKC_TERMS_UTIL_PVT.get_latest_art_version_id(l_orig_article_id,
  p_doc_type, p_doc_id);
  CLOSE l_get_kart_dtl_csr;

    /*IF (l_debug = 'Y') THEN
            okc_debug.log('400: Before invoking OKC_K_ARTICLES_GRP.delete_article record for p_id = ' || p_k_art_id, 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '400: Before invoking OKC_K_ARTICLES_GRP.delete_article record for p_id = ' || p_k_art_id );
    END IF;

/*
    OKC_K_ARTICLES_GRP.delete_article(
    p_api_version                  =>1,
    p_init_msg_list                => FND_API.G_FALSE,
    p_validate_commit              => FND_API.G_FALSE,
    p_validation_string            => NULL,
    p_commit                       => FND_API.G_FALSE,
    p_mode                         => p_mode, -- Other value 'AMEND'
    x_return_status                => x_return_status,
    x_msg_count                    => x_msg_count,
    x_msg_data                     => x_msg_data,
    p_id                           => p_k_art_id,
    p_object_version_number        => l_ovn); */

    /*IF (l_debug = 'Y') THEN
            okc_debug.log('500: After invoking OKC_K_ARTICLES_GRP.delete_article record x_return_status = ' || x_return_status, 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '500: After invoking OKC_K_ARTICLES_GRP.delete_article record x_return_status = ' || x_return_status );
    END IF;

      --------------------------------------------
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR ;
      END IF;
      --------------------------------------------


    /*IF (l_debug = 'Y') THEN
            okc_debug.log('600: Before invoking OKC_K_ARTICLES_GRP.create_article record for orig_article_id = ' || l_orig_article_id, 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '600: Before invoking OKC_K_ARTICLES_GRP.create_article record for orig_article_id = ' || l_orig_article_id );
    END IF;
/*
      OKC_K_ARTICLES_GRP.create_article(
                                   p_api_version       =>1,
                                   p_init_msg_list     => FND_API.G_FALSE,
                                   p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
                                   p_mode              => p_mode,
                                   x_return_status     => x_return_status,
                                   x_msg_count         => x_msg_count,
                                   x_msg_data          => x_msg_data,
                                   p_id                => null,
                                   p_sav_sae_id        => l_ref_article_id,
                                   p_document_type     => p_doc_type,
                                   p_document_id       => p_doc_id,
                                   p_scn_id            => l_scn_id,
                                   p_article_version_id => x_article_version_id,
                                   p_display_sequence   => l_display_sequence,
                                   x_id                 => x_cat_id
                                     );

    */

 /*   update okc_k_articles_b
    set sav_sae_id = l_orig_article_id,
        article_version_id = x_article_version_id
    where id = p_k_art_id; */
    OKC_K_ARTICLES_GRP.update_article(
    p_api_version                  => 1.0,
    p_init_msg_list                => p_init_msg_list ,
    p_validate_commit              => p_validate_commit,
    p_validation_string            => p_validation_string,
    p_commit                       => p_commit,
    p_mode                         => p_mode, -- Other value 'AMEND'
    x_return_status                => x_return_status,
    x_msg_count                    => x_msg_count,
    x_msg_data                     => x_msg_data,
    p_id                           => p_k_art_id,
    p_sav_sae_id                 => l_orig_article_id,
    p_article_version_id         => x_article_version_id,
    p_object_version_number      => NULL,
    p_ref_article_id             => G_MISS_NUM,
    p_ref_article_version_id     => G_MISS_NUM,
    p_lock_terms_yn              => p_lock_terms_yn);

     --------------------------------------------
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR ;
      END IF;
      --------------------------------------------


    /*IF (l_debug = 'Y') THEN
            okc_debug.log('700: After invoking OKC_K_ARTICLES_GRP.create_article record x_return_status = ' || x_return_status, 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '700: After invoking OKC_K_ARTICLES_GRP.create_article record x_return_status = ' || x_return_status );
    END IF;
    /*
        Delete those variables that are not in the Standard Article Version
        to which we are reverting to
    */
    for del_var_csr in l_get_delete_var loop
        OKC_K_ART_VARIABLES_PVT.Delete_Row(
            x_return_status          => x_return_status,
            p_cat_id                 => p_k_art_id,
            p_variable_code          => del_var_csr.variable_code,
            p_object_version_number  => del_var_csr.object_version_number);
            --------------------------------------------
            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                   RAISE FND_API.G_EXC_ERROR ;
            END IF;
            --------------------------------------------
    end loop;


    /*
        Insert those variables that are not in the Current Clause, but are
        available in the Standard Article Version to which we are reverting to
    */


    for ins_var_csr in l_get_insert_var loop
        OKC_K_ART_VARIABLES_PVT.insert_row(
        x_return_status          => x_return_status,
        p_cat_id                 => p_k_art_id,
        p_variable_code          => ins_var_csr.variable_code,
        p_variable_type          => ins_var_csr.variable_type,
        p_external_yn            => ins_var_csr.external_yn,
        p_attribute_value_set_id => ins_var_csr.value_set_id,
        p_variable_value_id      => l_variable_value_id,
        p_variable_value         => l_variable_value,
        x_cat_id                 => l_x_cat_id,
        x_variable_code          => l_x_variable_code);
    --------------------------------------------
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR ;
      END IF;
    --------------------------------------------


    end loop;

-- Standard check of p_commit
IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
END IF;

-- Standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

/*IF (l_debug = 'Y') THEN
     okc_debug.log('900: Leaving revert_to_standard', 2);
END IF;*/

IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '900: Leaving revert_to_standard' );
END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    /*IF (l_debug = 'Y') THEN
        okc_debug.log('300: Leaving revert_to_standard: OKC_API.G_EXCEPTION_ERROR Exception', 2);
    END IF;*/

    IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_EXCP_LEVEL,
    	    G_PKG_NAME, '300: Leaving revert_to_standard: OKC_API.G_EXCEPTION_ERROR Exception' );
    END IF;

    IF l_get_kart_dtl_csr%ISOPEN THEN
       CLOSE l_get_kart_dtl_csr;
    END IF;


    ROLLBACK TO g_revert_to_standard_GRP;
    x_return_status := G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    /*IF (l_debug = 'Y') THEN
         okc_debug.log('400: Leaving revert_to_standard: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
    END IF;*/

    IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_EXCP_LEVEL,
    	    G_PKG_NAME, '400: Leaving revert_to_standard: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception' );
    END IF;

    IF l_get_kart_dtl_csr%ISOPEN THEN
       CLOSE l_get_kart_dtl_csr;
    END IF;


    ROLLBACK TO g_revert_to_standard_GRP;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 WHEN OTHERS THEN
    /*IF (l_debug = 'Y') THEN
       okc_debug.log('500: Leaving revert_to_standard because of EXCEPTION: '||sqlerrm, 2);
    END IF;*/

    IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_EXCP_LEVEL,
    	    G_PKG_NAME, '500: Leaving revert_to_standard because of EXCEPTION: '||sqlerrm );
    END IF;

    IF l_get_kart_dtl_csr%ISOPEN THEN
       CLOSE l_get_kart_dtl_csr;
    END IF;


    ROLLBACK TO g_revert_to_standard_GRP;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;

    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
END revert_to_standard;

END OKC_K_NON_STD_ART_GRP;

/
