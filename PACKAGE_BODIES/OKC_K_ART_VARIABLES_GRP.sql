--------------------------------------------------------
--  DDL for Package Body OKC_K_ART_VARIABLES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_K_ART_VARIABLES_GRP" AS
/* $Header: OKCGVARB.pls 120.0.12010000.4 2013/10/16 07:04:55 skavutha ship $ */
 l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                    CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_K_ART_VARIABLES__GRP';
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


Procedure update_article_var_values(
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
    p_cat_id                     IN NUMBER,
    p_amendment_description      IN VARCHAR2,
    p_print_text_yn              IN VARCHAR2,
    p_variable_code              IN VARCHAR2,
    p_variable_value_id          IN VARCHAR2,
    p_variable_value             IN VARCHAR2,
    p_lock_terms_yn              IN VARCHAR2
    ) IS

    l_api_version             CONSTANT NUMBER := 1;
    l_api_name                CONSTANT VARCHAR2(30) := 'g_update_article_var_values';
    l_ovn                    NUMBER;

Cursor l_get_art_var_csr IS
SELECT object_version_number
FROM OKC_K_ART_VARIABLES
WHERE cat_id=p_cat_id
AND   variable_code=p_variable_code;

BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.log('100: Entered update_article_var_values', 2);
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_upd_article_var_values_GRP;
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

           IF (l_debug = 'Y') THEN
                okc_debug.log('110: Issue with document header Record.Cannot commit', 2);
           END IF;
           RAISE FND_API.G_EXC_ERROR ;
        END IF;
  END IF;

    --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (l_debug = 'Y') THEN
            okc_debug.log('400: Updating k article record', 2);
    END IF;

    IF p_mode='AMEND' THEN

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
                                   p_amendment_description => p_amendment_description,
                                   p_print_text_yn            =>p_print_text_yn,
                                   p_object_version_number    => NULL,
                                   p_lock_terms_yn             => p_lock_terms_yn
                                     );
      --------------------------------------------
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR ;
      END IF;
      --------------------------------------------

    END IF;

-- Updating variable values

    OPEN   l_get_art_var_csr;
    FETCH  l_get_art_var_csr INTO l_ovn;
    IF l_get_art_var_csr%FOUND THEN

       IF (l_debug = 'Y') THEN
           okc_debug.log('700: updating article variable record  ',2);
        END IF;

        OKC_K_ART_VARIABLES_PVT.update_row(
                          p_validation_level	  => FND_API.G_VALID_LEVEL_FULL,
                          x_return_status      => x_return_status,
                          p_cat_id             => p_cat_id,
                          p_variable_code      => p_variable_code,
                          p_variable_value_id  => p_variable_value_id,
                          p_variable_value     => p_variable_value,
                          p_object_version_number=>l_ovn
                                          );
        --------------------------------------------
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR ;
        END IF;
        --------------------------------------------
        IF (l_debug = 'Y') THEN
             okc_debug.log('800: updated article variable record  ', 2);
        END IF;
   END IF;
   CLOSE l_get_art_var_csr;

-- Standard check of p_commit
IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
END IF;

-- Standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

IF (l_debug = 'Y') THEN
     okc_debug.log('900: Leaving update_article_var_values', 2);
END IF;


EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    IF (l_debug = 'Y') THEN
        okc_debug.log('300: Leaving update_article_var_values: OKC_API.G_EXCEPTION_ERROR Exception', 2);
    END IF;

    IF l_get_art_var_csr%ISOPEN THEN
       CLOSE l_get_art_var_csr;
    END IF;

    ROLLBACK TO g_upd_article_var_values_GRP;
    x_return_status := G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (l_debug = 'Y') THEN
         okc_debug.log('400: Leavingupdate_article_var_values: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
    END IF;

    IF l_get_art_var_csr%ISOPEN THEN
       CLOSE l_get_art_var_csr;
    END IF;


    ROLLBACK TO g_upd_article_var_values_GRP;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 WHEN OTHERS THEN
    IF (l_debug = 'Y') THEN
       okc_debug.log('500: Leaving update_article_var_values because of EXCEPTION: '||sqlerrm, 2);
    END IF;

    IF l_get_art_var_csr%ISOPEN THEN
       CLOSE l_get_art_var_csr;
    END IF;


    ROLLBACK TO g_upd_article_var_values_GRP;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;

    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
END update_article_var_values;


Procedure update_global_var_values(
    p_api_version                IN NUMBER,
    p_init_msg_list              IN VARCHAR2 ,
    p_validate_commit            IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_string          IN VARCHAR2,
    p_commit                     IN VARCHAR2 := FND_API.G_FALSE,
    p_mode                       IN VARCHAR2 :='NORMAL', -- Other value 'AMEND'
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    p_doc_type                   IN VARCHAR2,
    p_doc_id                     IN NUMBER,
    p_variable_code              IN VARCHAR2,
    p_global_variable_value_id   IN VARCHAR2,
    p_global_variable_value      IN VARCHAR2,
    p_lock_terms_yn              IN VARCHAR2
) IS
    l_api_version             CONSTANT NUMBER := 1;
    l_api_name                CONSTANT VARCHAR2(30) := 'g_update_global_var_values';
    l_ovn                    NUMBER;

Cursor l_get_cat_id_csr IS
SELECT DISTINCT k.id
FROM okc_k_art_variables v,
     okc_k_articles_b k
WHERE k.id = v.cat_id
  AND NVL(v.override_global_yn,'N') <> 'Y'
  AND v.variable_code = p_variable_code
  AND k.document_type = p_doc_type
  AND k.document_id = p_doc_id;

BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.log('100: Entered update_global_var_values', 2);
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_update_global_var_values_GRP;
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
                                         p_doc_type      => p_doc_type,
                                         p_doc_id        => p_doc_id,
                                         p_validation_string => p_validation_string,
                                         x_return_status => x_return_status,
                                         x_msg_data      => x_msg_data,
                                         x_msg_count     => x_msg_count)                  ) THEN

           IF (l_debug = 'Y') THEN
                okc_debug.log('110: Issue with document header Record.Cannot commit', 2);
           END IF;
           RAISE FND_API.G_EXC_ERROR ;
        END IF;
  END IF;


   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Updating variable values

UPDATE okc_k_art_variables
   SET variable_value = p_global_variable_value,
       variable_value_id = p_global_variable_value_id,
       global_variable_value = p_global_variable_value,
       global_variable_value_id = p_global_variable_value_id,
       object_version_number = object_version_number + 1
WHERE variable_code = p_variable_code
  AND NVL(override_global_yn,'N') <> 'Y'
  AND cat_id IN
(SELECT id FROM okc_k_articles_b WHERE document_type = p_doc_type AND document_id = p_doc_id);

-- Update the global value for all records with override_global_yn = Y

UPDATE okc_k_art_variables
   SET global_variable_value = p_global_variable_value,
       global_variable_value_id = p_global_variable_value_id,
       object_version_number = object_version_number + 1
WHERE variable_code = p_variable_code
  AND NVL(override_global_yn,'N') ='Y'
  AND cat_id IN
(SELECT id FROM okc_k_articles_b WHERE document_type = p_doc_type AND document_id = p_doc_id);


    IF (l_debug = 'Y') THEN
            okc_debug.log('400: Updating k article record', 2);
    END IF;

   -- for Mode = AMEND mark articles as amended
    IF p_mode='AMEND' THEN

     FOR l_cat_rec IN l_get_cat_id_csr LOOP

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
                                   p_id                => l_cat_rec.id,
                                   p_amendment_description => NULL,
                                   p_print_text_yn            =>NULL,
                                   p_object_version_number    => NULL,
                                   p_lock_terms_yn             => p_lock_terms_yn
                                     );

      --------------------------------------------
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR ;
      END IF;
      --------------------------------------------

     END LOOP;
    END IF;  -- mode = AMEND

-- Standard check of p_commit
IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
END IF;

-- Standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

IF (l_debug = 'Y') THEN
     okc_debug.log('900: Leaving update_global_var_values', 2);
END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    IF (l_debug = 'Y') THEN
        okc_debug.log('300: Leaving update_article_var_values: OKC_API.G_EXCEPTION_ERROR Exception', 2);
    END IF;

    IF l_get_cat_id_csr%ISOPEN THEN
       CLOSE l_get_cat_id_csr;
    END IF;

    ROLLBACK TO g_upd_article_var_values_GRP;
    x_return_status := G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (l_debug = 'Y') THEN
         okc_debug.log('400: Leaving update_article_var_values: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2
);
    END IF;

    IF l_get_cat_id_csr%ISOPEN THEN
       CLOSE l_get_cat_id_csr;
    END IF;


    ROLLBACK TO g_upd_article_var_values_GRP;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 WHEN OTHERS THEN
    IF (l_debug = 'Y') THEN
       okc_debug.log('500: Leaving update_article_var_values because of EXCEPTION: '||sqlerrm, 2);
    END IF;

    IF l_get_cat_id_csr%ISOPEN THEN
       CLOSE l_get_cat_id_csr;
    END IF;


    ROLLBACK TO g_upd_article_var_values_GRP;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;

    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
END update_global_var_values;


Procedure update_local_var_values(
    p_api_version                IN NUMBER,
    p_init_msg_list              IN VARCHAR2 ,
    p_validate_commit            IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_string          IN VARCHAR2,
    p_commit                     IN VARCHAR2 := FND_API.G_FALSE,
    p_mode                       IN VARCHAR2 :='NORMAL', -- Other value 'AMEND'
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    p_doc_type                   IN VARCHAR2,
    p_doc_id                     IN NUMBER,
    p_cat_id                     IN NUMBER,
    p_amendment_description      IN VARCHAR2 := NULL,
    p_print_text_yn              IN VARCHAR2 := NULL,
    p_variable_code              IN VARCHAR2,
    p_variable_value_id          IN VARCHAR2,
    p_variable_value             IN VARCHAR2,
    p_override_global_yn         IN VARCHAR2,
    p_lock_terms_yn              IN VARCHAR2
) IS

    l_api_version             CONSTANT NUMBER := 1;
    l_api_name                CONSTANT VARCHAR2(30) := 'g_update_local_var_values';

BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.log('100: Entered update_local_var_values', 2);
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_update_local_var_values_GRP;
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
                                         p_doc_type      => p_doc_type,
                                         p_doc_id        => p_doc_id,
                                         p_validation_string => p_validation_string,
                                         x_return_status => x_return_status,
                                         x_msg_data      => x_msg_data,
                                         x_msg_count     => x_msg_count)                  ) THEN

           IF (l_debug = 'Y') THEN
                okc_debug.log('110: Issue with document header Record.Cannot commit', 2);
           END IF;
           RAISE FND_API.G_EXC_ERROR ;
        END IF;
  END IF;


   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (l_debug = 'Y') THEN
            okc_debug.log('400: Updating k article record', 2);
    END IF;

   -- for Mode = AMEND mark articles as amended
    IF p_mode='AMEND' THEN

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
                                   p_amendment_description => NULL,
                                   p_print_text_yn            =>NULL,
                                   p_object_version_number    => NULL,
                                   p_lock_terms_yn             => p_lock_terms_yn
                                     );
      --------------------------------------------
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR ;
      END IF;
      --------------------------------------------

    END IF;  -- mode = AMEND



-- Updating variable values

IF NVL(p_override_global_yn,'N') = 'N' THEN
         -- override local with global values
          UPDATE okc_k_art_variables
             SET variable_value = NVL(global_variable_value,p_variable_value),
                 variable_value_id = NVL(global_variable_value_id,p_variable_value_id),
                 override_global_yn = 'N',
                 object_version_number = object_version_number + 1
          WHERE variable_code = p_variable_code
            AND cat_id = p_cat_id ;

ELSE
  -- override global with local values
   UPDATE okc_k_art_variables
      SET variable_value = p_variable_value,
          variable_value_id = p_variable_value_id,
          override_global_yn = 'Y',
          object_version_number = object_version_number + 1
   WHERE variable_code = p_variable_code
     AND cat_id = p_cat_id ;
END IF;


-- Standard check of p_commit
IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
END IF;

-- Standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

IF (l_debug = 'Y') THEN
     okc_debug.log('900: Leaving update_local_var_values', 2);
END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    IF (l_debug = 'Y') THEN
        okc_debug.log('300: Leaving update_article_var_values: OKC_API.G_EXCEPTION_ERROR Exception', 2);
    END IF;

    ROLLBACK TO g_upd_article_var_values_GRP;
    x_return_status := G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (l_debug = 'Y') THEN
         okc_debug.log('400: Leaving update_article_var_values: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2
);
    END IF;


    ROLLBACK TO g_upd_article_var_values_GRP;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 WHEN OTHERS THEN
    IF (l_debug = 'Y') THEN
       okc_debug.log('500: Leaving update_article_var_values because of EXCEPTION: '||sqlerrm, 2);
    END IF;


    ROLLBACK TO g_upd_article_var_values_GRP;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;

    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
END update_local_var_values;

Procedure update_response_var_values(
    p_api_version                IN NUMBER,
    p_init_msg_list              IN VARCHAR2 ,
    p_validate_commit            IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_string          IN VARCHAR2,
    p_commit                     IN VARCHAR2 := FND_API.G_FALSE,
    p_mode                       IN VARCHAR2 :='NORMAL', -- Other value 'AMEND'
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    p_doc_type                   IN VARCHAR2,
    p_doc_id                     IN NUMBER,
    p_old_cat_id                 IN NUMBER,
    p_amendment_description      IN VARCHAR2 := NULL,
    p_print_text_yn              IN VARCHAR2 := NULL,
    p_variable_code              IN VARCHAR2,
    p_variable_value_id          IN VARCHAR2,
    p_variable_value             IN VARCHAR2,
    p_override_global_yn         IN VARCHAR2) IS

l_api_version             CONSTANT NUMBER := 1;
l_api_name                CONSTANT VARCHAR2(30) := 'g_update_response_var_values';
l_cat_id                  NUMBER;
l_mrv_flag                VARCHAR2(10) := 'N';

x_return_status1              VARCHAR2(10);
x_msg_count1                  NUMBER;
x_msg_data1                   VARCHAR2(1000);

CURSOR csr_new_cat_id IS
SELECT id
FROM okc_k_articles_b
WHERE orig_system_reference_code = 'COPY'
  AND orig_system_reference_id1  = p_old_cat_id
  AND document_type = p_doc_type
  AND document_id = p_doc_id;



BEGIN

IF (l_debug = 'Y') THEN
    okc_debug.log('100: Entered update_response_var_values', 2);
END IF;

  OPEN csr_new_cat_id;
    FETCH csr_new_cat_id INTO l_cat_id;
  CLOSE csr_new_cat_id;

IF (l_debug = 'Y') THEN
    okc_debug.log('200: l_cat_id : '||l_cat_id, 2);
END IF;

-- now call update_local_var_values
update_local_var_values
(
    p_api_version               =>  p_api_version,
    p_init_msg_list             =>  p_init_msg_list,
    p_validate_commit           =>  p_validate_commit,
    p_validation_string         =>  p_validation_string,
    p_commit                    =>  p_commit,
    p_mode                      =>  p_mode,
    x_return_status             =>  x_return_status,
    x_msg_count                 =>  x_msg_count,
    x_msg_data                  =>  x_msg_data,
    p_doc_type                  =>  p_doc_type,
    p_doc_id                    =>  p_doc_id,
    p_cat_id                    =>  l_cat_id,
    p_amendment_description     =>  p_amendment_description,
    p_print_text_yn             =>  p_print_text_yn,
    p_variable_code             =>  p_variable_code,
    p_variable_value_id         =>  p_variable_value_id,
    p_variable_value            =>  p_variable_value,
    p_override_global_yn        =>  p_override_global_yn
);

/* this code is commneted out because the same has been written in more appropriate place i.e., in okc_terms_copy_pvt
-- IF mrv flag IS enabled THEN mrv uda data has to be copied.
SELECT Nvl(MRV_FLAG,'N')
  INTO l_mrv_flag
  FROM okc_bus_variables_b
 WHERE VARIABLE_CODE = p_variable_code;

IF l_mrv_flag = 'Y' THEN
	okc_mrv_util.copy_variable_uda_data(
                     p_from_cat_id          => p_old_cat_id,
										 p_from_variable_code   => p_variable_code,
										 p_to_cat_id            => l_cat_id,
										 p_to_variable_code     => p_variable_code,
										 x_return_status        => x_return_status1,
										 x_msg_count            => x_msg_count1,
										 x_msg_data             => x_msg_data1
										);
	IF (x_return_status1 = G_RET_STS_UNEXP_ERROR) THEN
    IF (l_debug = 'Y') THEN
        okc_debug.log('880: error while copying the MRV', 2);
    END IF;

	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	ELSIF (x_return_status1 = G_RET_STS_ERROR) THEN
    IF (l_debug = 'Y') THEN
        okc_debug.log('890: error while copying the MRV', 2);
    END IF;

    RAISE FND_API.G_EXC_ERROR ;
	END IF;
END IF;*/

IF (l_debug = 'Y') THEN
     okc_debug.log('900: Leaving update_response_var_values', 2);
END IF;

EXCEPTION
 WHEN OTHERS THEN
    IF (l_debug = 'Y') THEN
       okc_debug.log('500: Leaving update_response_var_values because of EXCEPTION: '||sqlerrm, 2);
    END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
END update_response_var_values;

PROCEDURE get_new_cat_id (
      p_old_cat_id               IN VARCHAR2,
      p_new_doc_type             IN VARCHAR2,
      p_new_doc_id               IN VARCHAR2,
      p_new_cat_id               OUT NOCOPY VARCHAR2) IS

l_count NUMBER;
BEGIN

    SELECT Count(1)
      INTO l_count
      FROM okc_k_articles_b
     WHERE id  = p_old_cat_id
       AND document_type = p_new_doc_type
       AND document_id = p_new_doc_id;

    IF l_count = 0 THEN
      SELECT id
          INTO p_new_cat_id
          FROM okc_k_articles_b
        WHERE orig_system_reference_code = 'COPY'
          AND orig_system_reference_id1  = p_old_cat_id
          AND document_type = p_new_doc_type
          AND document_id = p_new_doc_id;
    END IF;
EXCEPTION
    -- if the flow is from draft (surrogate) offers
    WHEN No_Data_Found then
      p_new_cat_id := p_old_cat_id;
END get_new_cat_id ;


END OKC_K_ART_VARIABLES_GRP;

/
