--------------------------------------------------------
--  DDL for Package Body OKC_K_ARTICLES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_K_ARTICLES_GRP" AS
/* $Header: OKCGCATB.pls 120.0.12010000.6 2013/11/29 13:44:31 serukull ship $ */

    l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                    CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_K_ARTICLES_GRP';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_FALSE	               CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;

  G_RET_STS_SUCCESS            CONSTANT   varchar2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   varchar2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   varchar2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

  G_UNEXPECTED_ERROR           CONSTANT   varchar2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   varchar2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   varchar2(200) := 'ERROR_CODE';
  G_AMEND_CODE_UPDATED         CONSTANT   varchar2(30) := 'UPDATED';
  G_AMEND_CODE_ADDED         CONSTANT   varchar2(30) := 'ADDED';
  G_AMEND_CODE_DELETED         CONSTANT   varchar2(30) := 'DELETED';

  -------------------------------------
  -- PROCEDURE create_article
  -------------------------------------
  PROCEDURE create_article(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER ,
    p_commit                       IN VARCHAR2,
    p_mode                       IN VARCHAR2,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_id                         IN NUMBER,
    p_sav_sae_id                 IN NUMBER,
    p_cat_type                   IN VARCHAR2, --Bug 3341342
    p_document_type              IN VARCHAR2,
    p_document_id                IN NUMBER,
    p_cle_id                     IN NUMBER,
    p_source_flag                IN VARCHAR2,
    p_mandatory_yn               IN VARCHAR2,
    p_scn_id                     IN NUMBER,
    p_label                      IN VARCHAR2,
    p_amendment_description      IN VARCHAR2,
    p_article_version_id         IN NUMBER,
    p_change_nonstd_yn           IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN NUMBER,
    p_orig_system_reference_id2  IN NUMBER,
    p_display_sequence           IN NUMBER,

    p_attribute_category         IN VARCHAR2 ,
    p_attribute1                 IN VARCHAR2 ,
    p_attribute2                 IN VARCHAR2 ,
    p_attribute3                 IN VARCHAR2 ,
    p_attribute4                 IN VARCHAR2 ,
    p_attribute5                 IN VARCHAR2 ,
    p_attribute6                 IN VARCHAR2 ,
    p_attribute7                 IN VARCHAR2 ,
    p_attribute8                 IN VARCHAR2 ,
    p_attribute9                 IN VARCHAR2 ,
    p_attribute10                IN VARCHAR2 ,
    p_attribute11                IN VARCHAR2 ,
    p_attribute12                IN VARCHAR2 ,
    p_attribute13                IN VARCHAR2 ,
    p_attribute14                IN VARCHAR2 ,
    p_attribute15                IN VARCHAR2 ,
    p_print_text_yn              IN VARCHAR2 ,
    p_ref_article_id             IN NUMBER,
    p_ref_article_version_id     IN NUMBER,
    p_mandatory_rwa               IN VARCHAR2,
    x_id                         OUT NOCOPY NUMBER

  ) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'g_create_article';
    l_cat_id                      NUMBER;
    l_del_cat_id                  NUMBER;
    l_variable_code               OKC_K_ART_VARIABLES.VARIABLE_CODE%TYPE;
    l_amendment_operation_code    OKC_K_ARTICLES_B.AMENDMENT_OPERATION_CODE%TYPE;
    l_summary_amend_operation_code OKC_K_ARTICLES_B.SUMMARY_AMEND_OPERATION_CODE%TYPE;
    l_amendment_description       OKC_K_ARTICLES_B.AMENDMENT_DESCRIPTION%TYPE;

   l_orig_system_reference_code  OKC_SECTIONS_B.orig_system_reference_code%type;
   l_orig_system_reference_id1  OKC_SECTIONS_B.orig_system_reference_id1%type;

   CURSOR l_article_var_csr(b_article_version_id NUMBER) IS
   SELECT VAR.VARIABLE_CODE, BUSVAR.VARIABLE_TYPE, BUSVAR.EXTERNAL_YN, BUSVAR.VALUE_SET_ID
   FROM OKC_ARTICLE_VARIABLES VAR,
        OKC_BUS_VARIABLES_B BUSVAR
   WHERE VAR.ARTICLE_VERSION_ID = b_article_version_id
   AND BUSVAR.VARIABLE_CODE=VAR.VARIABLE_CODE;

   CURSOR l_get_deleted_rec_csr IS
   SELECT id FROM okc_k_articles_b
   WHERE  document_type=p_document_type
   AND    document_id  =p_document_id
   AND   ( sav_sae_id  = p_sav_sae_id
          OR sav_sae_id=p_ref_article_id
          OR ref_article_id=p_sav_sae_id
          OR ref_article_id = p_ref_article_id)
  AND   ( amendment_operation_code=G_AMEND_CODE_DELETED OR summary_amend_operation_code=G_AMEND_CODE_DELETED) ;


  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.log('600: Entered create_article', 2);
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_create_article_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_mode='AMEND' THEN

       OPEN  l_get_deleted_rec_csr;
       FETCH l_get_deleted_rec_csr INTO l_del_cat_id;
       CLOSE l_get_deleted_rec_csr;

           IF l_del_cat_id IS NOT NULL THEN
                l_amendment_operation_code:=G_AMEND_CODE_UPDATED;
                l_amendment_description   := p_amendment_description;
                l_summary_amend_operation_code:=G_AMEND_CODE_UPDATED;
           ELSE
                l_amendment_operation_code:= G_AMEND_CODE_ADDED;
                l_amendment_description   := p_amendment_description;
                l_summary_amend_operation_code:=OKC_TERMS_UTIL_PVT.get_summary_amend_code(p_existing_summary_code =>NULL,
          p_existing_operation_code=>NULL,
          p_amend_operation_code=> G_AMEND_CODE_ADDED);

          END IF;
    ELSE
       l_amendment_operation_code:= NULL;
       l_amendment_description   := NULL;
       l_summary_amend_operation_code:=NULL;
    END IF;

    IF l_del_cat_id IS NOT NULL THEN
      OKC_K_ARTICLES_GRP.delete_article(
                       p_api_version  => 1,
                       p_init_msg_list => FND_API.G_FALSE,
                       p_validate_commit => FND_API.G_FALSE,
                       p_validation_string => NULL,
                       p_commit            => FND_API.G_FALSE,
                       p_mode              => 'NORMAL',
                       x_return_status     => x_return_status,
                       x_msg_count         => x_msg_count,
                       x_msg_data          => x_msg_data,
                       p_super_user_yn     => 'N',
                       p_amendment_description  => NULL,
                       p_id                     => l_del_cat_id,
                       p_object_version_number  => NULL
              );
       --------------------------------------------
       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR ;
       END IF;
      --------------------------------------------
    END IF;

   IF p_mode='AMEND' AND  SubStr(p_document_type,-3,3) = 'MOD' AND p_scn_id IS NOT NULL  THEN

    SELECT  orig_system_reference_code, orig_system_reference_id1
     INTO   l_orig_system_reference_code,  l_orig_system_reference_id1
    FROM  okc_sections_b
    WHERE id=p_scn_id;

   IF  l_orig_system_reference_code = 'COPY' THEN
    okc_k_entity_locks_grp.lock_entity (
      p_api_version             => 1,
      p_entity_name             => 'DUMMYSEC',
      p_entity_pk1              => l_orig_system_reference_id1, -- > Base Section id.
      p_lock_by_entity_id       => p_scn_id,   -- > Section Id on the document.
      p_lock_by_document_type   => p_document_type,
      p_lock_by_document_id     => p_document_id,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data);
    END IF;

      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR ;
       END IF;

   END IF;

    --------------------------------------------
    -- Calling Simple API for Creating A Row
    --------------------------------------------
    OKC_K_ARTICLES_PVT.insert_row(
      p_validation_level           => p_validation_level,
      x_return_status              => x_return_status,
      p_id                         => p_id,
      p_sav_sae_id                 => p_sav_sae_id,
      p_cat_type                   => p_cat_type, --Bug 3341342
      p_document_type              => p_document_type,
      p_document_id                => p_document_id,
      p_cle_id                     => p_cle_id,
      p_source_flag                => p_source_flag,
      p_mandatory_yn               => p_mandatory_yn,
      p_scn_id                     => p_scn_id,
      p_label                      => p_label,
      p_amendment_description      => l_amendment_description,
      p_amendment_operation_code   => l_amendment_operation_code,
      p_summary_amend_operation_code => l_summary_amend_operation_code,
      p_article_version_id         => p_article_version_id,
      p_change_nonstd_yn           => p_change_nonstd_yn,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1  => p_orig_system_reference_id1,
      p_orig_system_reference_id2  => p_orig_system_reference_id2,
      p_display_sequence           => p_display_sequence,
      p_attribute_category         => p_attribute_category,
      p_attribute1                 => p_attribute1,
      p_attribute2                 => p_attribute2,
      p_attribute3                 => p_attribute3,
      p_attribute4                 => p_attribute4,
      p_attribute5                 => p_attribute5,
      p_attribute6                 => p_attribute6,
      p_attribute7                 => p_attribute7,
      p_attribute8                 => p_attribute8,
      p_attribute9                 => p_attribute9,
      p_attribute10                => p_attribute10,
      p_attribute11                => p_attribute11,
      p_attribute12                => p_attribute12,
      p_attribute13                => p_attribute13,
      p_attribute14                => p_attribute14,
      p_attribute15                => p_attribute15,
      p_print_text_yn              => p_print_text_yn,
      p_ref_article_id             => p_ref_article_id,
      p_ref_article_version_id     => p_ref_article_version_id,
      x_id                         => x_id,
      p_mandatory_rwa               => p_mandatory_rwa
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------
    IF p_document_type <> 'TEMPLATE' THEN

               IF (l_debug = 'Y') THEN
                  okc_debug.log('120: Variables of article '||p_sav_sae_id||' is being created',2);
               END IF;

               FOR  l_article_var_rec IN l_article_var_csr(p_article_version_id) LOOP
                   OKC_K_ART_VARIABLES_PVT.insert_row(
                                           p_validation_level       => p_validation_level,
                                           x_return_status          => x_return_status,
                                           p_cat_id                 => x_id,
                                           p_variable_code          => l_article_var_rec.variable_code,
                                           p_variable_type          => l_article_var_rec.variable_type,
                                           p_external_yn            => l_article_var_rec.external_yn,
                                           p_variable_value_id      => NULL,
                                           p_variable_value         => NULL,
                                           p_attribute_value_set_id => l_article_var_rec.value_set_id,
                                           x_cat_id                 => l_cat_id,
                                           x_variable_code          => l_variable_code
                                         );
                    --------------------------------------------
                    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                           RAISE FND_API.G_EXC_ERROR ;
                     END IF;
                      --------------------------------------------
                    IF (l_debug = 'Y') THEN
                      okc_debug.log('130: Variables  '||l_variable_code||' for cat_id '||l_cat_id||' is created',2);
                    END IF;
                END LOOP;
         END IF;

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    IF (l_debug = 'Y') THEN
       okc_debug.log('700: Leaving create_article', 2);
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('800: Leaving create_article: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;

      IF l_article_var_csr%ISOPEN THEN
         CLOSE l_article_var_csr;
      END IF;

      ROLLBACK TO g_create_article_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('900: Leaving create_article: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;

      IF l_article_var_csr%ISOPEN THEN
         CLOSE l_article_var_csr;
      END IF;


      ROLLBACK TO g_create_article_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('1000: Leaving create_article because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      IF l_article_var_csr%ISOPEN THEN
         CLOSE l_article_var_csr;
      END IF;

      ROLLBACK TO g_create_article_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  END create_article;
  ---------------------------------------
  -- PROCEDURE validate_row  --
  ---------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_id                         IN NUMBER,
    p_sav_sae_id                 IN NUMBER,
    p_document_type              IN VARCHAR2,
    p_document_id                IN NUMBER,
    p_cle_id                     IN NUMBER,
    p_source_flag                IN VARCHAR2,
    p_mandatory_yn               IN VARCHAR2,
    p_scn_id                     IN NUMBER,
    p_label                      IN VARCHAR2,
    p_amendment_description      IN VARCHAR2,
    p_amendment_operation_code   IN VARCHAR2,
    p_article_version_id         IN NUMBER,
    p_change_nonstd_yn           IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN NUMBER,
    p_orig_system_reference_id2  IN NUMBER,
    p_display_sequence           IN NUMBER,
    p_attribute_category         IN VARCHAR2 := NULL,
    p_attribute1                 IN VARCHAR2 := NULL,
    p_attribute2                 IN VARCHAR2 := NULL,
    p_attribute3                 IN VARCHAR2 := NULL,
    p_attribute4                 IN VARCHAR2 := NULL,
    p_attribute5                 IN VARCHAR2 := NULL,
    p_attribute6                 IN VARCHAR2 := NULL,
    p_attribute7                 IN VARCHAR2 := NULL,
    p_attribute8                 IN VARCHAR2 := NULL,
    p_attribute9                 IN VARCHAR2 := NULL,
    p_attribute10                IN VARCHAR2 := NULL,
    p_attribute11                IN VARCHAR2 := NULL,
    p_attribute12                IN VARCHAR2 := NULL,
    p_attribute13                IN VARCHAR2 := NULL,
    p_attribute14                IN VARCHAR2 := NULL,
    p_attribute15                IN VARCHAR2 := NULL,
    p_print_text_yn              IN VARCHAR2 := 'N',
    p_summary_amend_operation_code IN VARCHAR2 := NULL,
    p_ref_article_id               IN NUMBER := NULL,
    p_ref_article_version_id       IN NUMBER := NULL,
    p_object_version_number      IN NUMBER,
    p_mandatory_rwa               IN VARCHAR2
  ) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'g_validate_row';

  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.log('100: Entered validate_row', 2);
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_validate_row_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --------------------------------------------
    -- Calling Simple API for Validation
    --------------------------------------------
    OKC_K_ARTICLES_PVT.Validate_Row(
      p_validation_level           => p_validation_level,
      x_return_status              => x_return_status,
      p_id                         => p_id,
      p_sav_sae_id                 => p_sav_sae_id,
      p_document_type              => p_document_type,
      p_document_id                => p_document_id,
      p_cle_id                     => p_cle_id,
      p_source_flag                => p_source_flag,
      p_mandatory_yn               => p_mandatory_yn,
      p_scn_id                     => p_scn_id,
      p_label                      => p_label,
      p_amendment_description      => p_amendment_description,
      p_amendment_operation_code   => p_amendment_operation_code,
      p_article_version_id         => p_article_version_id,
      p_change_nonstd_yn           => p_change_nonstd_yn,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1  => p_orig_system_reference_id1,
      p_orig_system_reference_id2  => p_orig_system_reference_id2,
      p_display_sequence           => p_display_sequence,
      p_attribute_category         => p_attribute_category,
      p_attribute1                 => p_attribute1,
      p_attribute2                 => p_attribute2,
      p_attribute3                 => p_attribute3,
      p_attribute4                 => p_attribute4,
      p_attribute5                 => p_attribute5,
      p_attribute6                 => p_attribute6,
      p_attribute7                 => p_attribute7,
      p_attribute8                 => p_attribute8,
      p_attribute9                 => p_attribute9,
      p_attribute10                => p_attribute10,
      p_attribute11                => p_attribute11,
      p_attribute12                => p_attribute12,
      p_attribute13                => p_attribute13,
      p_attribute14                => p_attribute14,
      p_attribute15                => p_attribute15,
      p_print_text_yn              => p_print_text_yn,
      p_summary_amend_operation_code => p_summary_amend_operation_code,
      p_ref_article_id              => p_ref_article_id,
      p_ref_article_version_id      => p_ref_article_version_id,
      p_object_version_number      => p_object_version_number,
     p_mandatory_rwa               => p_mandatory_rwa
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    IF (l_debug = 'Y') THEN
       okc_debug.log('200: Leaving validate_row', 2);
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('300: Leaving Validate_Row: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_validate_row_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('400: Leaving Validate_Row: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_validate_row_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('500: Leaving Validate_Row because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      ROLLBACK TO g_validate_row_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  END validate_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_id                         IN NUMBER,
    p_object_version_number      IN NUMBER
   ) IS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'g_lock_row';
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.log('1100: Entered lock_row', 2);
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_lock_row_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --------------------------------------------
    -- Calling Simple API for Locking A Row
    --------------------------------------------
    OKC_K_ARTICLES_PVT.lock_row(
      x_return_status              =>   x_return_status,
      p_id                         => p_id,
      p_object_version_number      => p_object_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    IF (l_debug = 'Y') THEN
      okc_debug.log('1200: Leaving lock_row', 2);
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('1300: Leaving lock_Row: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_lock_row_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('1400: Leaving lock_Row: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_lock_row_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('1500: Leaving lock_Row because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      ROLLBACK TO g_lock_row_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  END lock_row;
  ---------------------------------------------------------------------------
  -- PROCEDURE update_article
  ---------------------------------------------------------------------------
  PROCEDURE update_article(
    p_api_version                IN NUMBER,
    p_init_msg_list              IN VARCHAR2 ,
    p_validation_level	         IN NUMBER,
    p_validate_commit            IN VARCHAR2,
    p_validation_string          IN VARCHAR2,
    p_commit                     IN VARCHAR2,
    p_mode                       IN VARCHAR2,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    p_id                         IN NUMBER,
    p_sav_sae_id                 IN NUMBER,
    p_document_type              IN VARCHAR2,
    p_document_id                IN NUMBER,
    p_cle_id                     IN NUMBER,
    p_source_flag                IN VARCHAR2,
    p_mandatory_yn               IN VARCHAR2,
    p_mandatory_rwa              IN VARCHAR2,
    p_scn_id                     IN NUMBER,
    p_label                      IN VARCHAR2,
    p_amendment_description      IN VARCHAR2,
    p_article_version_id         IN NUMBER,
    p_change_nonstd_yn           IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN NUMBER,
    p_orig_system_reference_id2  IN NUMBER,
    p_display_sequence           IN NUMBER,
    p_attribute_category         IN VARCHAR2 ,
    p_attribute1                 IN VARCHAR2 ,
    p_attribute2                 IN VARCHAR2 ,
    p_attribute3                 IN VARCHAR2 ,
    p_attribute4                 IN VARCHAR2 ,
    p_attribute5                 IN VARCHAR2 ,
    p_attribute6                 IN VARCHAR2 ,
    p_attribute7                 IN VARCHAR2 ,
    p_attribute8                 IN VARCHAR2 ,
    p_attribute9                 IN VARCHAR2 ,
    p_attribute10                IN VARCHAR2 ,
    p_attribute11                IN VARCHAR2 ,
    p_attribute12                IN VARCHAR2 ,
    p_attribute13                IN VARCHAR2 ,
    p_attribute14                IN VARCHAR2 ,
    p_attribute15                IN VARCHAR2 ,
    p_print_text_yn              IN VARCHAR2 ,
    p_ref_article_id               IN NUMBER ,
    p_ref_article_version_id       IN NUMBER ,
    p_object_version_number        IN NUMBER ,
    p_lock_terms_yn                IN VARCHAR2

   ) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'g_update_article';
    l_ok_to_commit                 VARCHAR2(1);
    l_document_id                  NUMBER;
    l_cle_id                       NUMBER;
    l_document_type                VARCHAR2(30);
    l_article_version_id           NUMBER;
    l_standard_yn                  VARCHAR2(1);
    l_sync_variable                VARCHAR2(1) := FND_API.G_FALSE;
    l_amendment_operation_code     OKC_K_ARTICLES_B.AMENDMENT_OPERATION_CODE%TYPE;
    l_summary_amend_operation_code OKC_K_ARTICLES_B.AMENDMENT_OPERATION_CODE%TYPE;
    l_existing_summary_code      OKC_SECTIONS_B.SUMMARY_AMEND_OPERATION_CODE%TYPE;
    l_existing_operation_code    OKC_SECTIONS_B.SUMMARY_AMEND_OPERATION_CODE%TYPE;
    l_amendment_description        OKC_K_ARTICLES_B.AMENDMENT_DESCRIPTION%TYPE;
    x_cat_id                       okc_k_art_variables.cat_id%type;
    x_variable_code                okc_k_art_variables.variable_code%type;
    l_orig_system_reference_id1 NUMBER;

    CURSOR l_document_id_csr IS
    SELECT DOCUMENT_ID,DOCUMENT_TYPE,orig_system_reference_id1
    FROM OKC_K_ARTIClES_B
    WHERE ID=P_ID;

    CURSOR l_art_version_csr IS
    SELECT ARTICLE_VERSION_ID,standard_yn
    FROM OKC_K_ARTIClES_B kart,okc_articles_all art
    WHERE ID=P_ID
    AND   art.article_id=kart.sav_sae_id;

    CURSOR l_create_variable_csr is
    SELECT KART.ID CAT_ID,
           VAR.VARIABLE_CODE,
           BUSVAR.VARIABLE_TYPE,
           BUSVAR.EXTERNAL_YN,
           BUSVAR.VALUE_SET_ID,
           NULL VARIABLE_VALUE,
           NULL VARIABLE_VALUE_ID
   FROM  OKC_ARTICLE_VARIABLES VAR,
         OKC_K_ARTICLES_B KART,
         OKC_BUS_VARIABLES_B BUSVAR
   WHERE KART.ARTICLE_VERSION_ID=VAR.ARTICLE_VERSION_ID
   AND KART.ID = P_ID
   AND BUSVAR.VARIABLE_CODE=VAR.VARIABLE_CODE AND NOT EXISTS
   ( SELECT 'X' FROM OKC_K_ART_VARIABLES
     WHERE CAT_ID=KART.ID
     AND VARIABLE_CODE = BUSVAR.VARIABLE_CODE);

    CURSOR l_update_variable_csr is
    SELECT KART.ID CAT_ID,
           VAR.VARIABLE_CODE,
           BUSVAR.VARIABLE_TYPE,
           BUSVAR.EXTERNAL_YN,
           BUSVAR.VALUE_SET_ID,
           ARTVAR.VARIABLE_VALUE,
           ARTVAR.VARIABLE_VALUE_ID,
           ARTVAR.OBJECT_VERSION_NUMBER
   FROM  OKC_ARTICLE_VARIABLES VAR,
         OKC_K_ARTICLES_B KART,
         OKC_BUS_VARIABLES_B BUSVAR,
         OKC_K_ART_VARIABLES ARTVAR
   WHERE KART.ARTICLE_VERSION_ID=VAR.ARTICLE_VERSION_ID
   AND BUSVAR.VARIABLE_CODE=VAR.VARIABLE_CODE
   AND ARTVAR.CAT_ID = KART.ID
   AND ARTVAR.VARIABLE_CODE = VAR.VARIABLE_CODE
   AND KART.ID = P_ID
   AND ARTVAR.VARIABLE_VALUE IS NULL;

    CURSOR l_delete_variable_csr is
    SELECT ARTVAR.CAT_ID,
           ARTVAR.VARIABLE_CODE,
           ARTVAR.OBJECT_VERSION_NUMBER
    FROM OKC_K_ART_VARIABLES ARTVAR,
         OKC_K_ARTICLES_B KART
    WHERE KART.ID = ARTVAR.CAT_ID
    AND   KART.ID = P_ID
    AND   NOT EXISTS ( SELECT 'X' FROM  OKC_ARTICLE_VARIABLES VAR
                      WHERE VAR.ARTICLE_VERSION_ID = KART.ARTICLE_VERSION_ID
                      AND   VAR.VARIABLE_CODE = ARTVAR.VARIABLE_CODE );

    CURSOR l_get_summary_code_csr IS
    SELECT SUMMARY_AMEND_OPERATION_CODE ,amendment_operation_code
    FROM OKC_K_ARTICLES_B
    WHERE ID=P_ID;


  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.log('1600: Entered update_article', 2);
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_update_article_grp;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF p_document_id IS NULL OR p_document_type IS NULL OR p_orig_system_reference_id1 IS NULL THEN
       OPEN  l_document_id_csr;
       FETCH l_document_id_csr into l_document_id,l_document_type,l_orig_system_reference_id1;
       CLOSE l_document_id_csr;
    ELSE
        l_document_id := p_document_id;
        l_document_type := p_document_type;
        l_orig_system_reference_id1 := p_orig_system_reference_id1;
    END IF;


    IF FND_API.To_Boolean( p_validate_commit ) THEN

       IF NOT FND_API.To_Boolean(OKC_TERMS_UTIL_GRP.ok_to_commit (
                                         p_api_version => l_api_version,
                                         p_init_msg_list => FND_API.G_FALSE,
                                         p_doc_type	 => l_document_type,
                                         p_doc_id	 => l_document_id,
                                         p_validation_string => p_validation_string,
                                         x_return_status => x_return_status,
                                         x_msg_data	 => x_msg_data,
                                         x_msg_count	 => x_msg_count)                  ) THEN

             IF (l_debug = 'Y') THEN
                okc_debug.log('700: Issue with document header Record.Cannot commit', 2);
             END IF;
             RAISE FND_API.G_EXC_ERROR ;
      END IF;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- Check if this update going to update article version also.If yes then article variables will be created.

    OPEN  l_art_version_csr;
    FETCH l_art_version_csr into l_article_version_id,l_standard_yn;
    CLOSE l_art_version_csr;

    IF (p_article_version_id IS NOT NULL AND
       p_article_version_id <>FND_API.G_MISS_NUM AND
       l_article_version_id <> p_article_version_id ) OR l_standard_yn='N' THEN

          l_sync_variable := FND_API.G_TRUE;

   END IF;

   IF p_mode='AMEND' THEN

       l_amendment_description   := p_amendment_description;
       OPEN  l_get_summary_code_csr;
       FETCH l_get_summary_code_csr INTO l_existing_summary_code,l_existing_operation_code;
       CLOSE l_get_summary_code_csr;
        l_amendment_operation_code := nvl(l_existing_operation_code,G_AMEND_CODE_UPDATED);

       l_summary_amend_operation_code := OKC_TERMS_UTIL_PVT.get_summary_amend_code(p_existing_summary_code =>l_existing_summary_code,
   p_existing_operation_code=>l_existing_operation_code,
   p_amend_operation_code=>G_AMEND_CODE_UPDATED);

    ELSE
       l_amendment_operation_code:= NULL;
       l_amendment_description   := NULL;
       l_summary_amend_operation_code := NULL;
    END IF;

    -----------------------------------------------------------------
    -- Concurrent Mod Changes
    -- Call the Lock entity API only in AMEND mode
    --                  and when p_lock_terms_yn is 'Y' .
    -----------------------------------------------------------------
    IF (      p_mode='AMEND'
         AND  l_amendment_operation_code = G_AMEND_CODE_UPDATED
         AND  p_lock_terms_yn = 'Y'
         AND  l_orig_system_reference_id1 IS NOT null
        )
    THEN




     -- Try to lock the base record. for real time concurrency:
      lock_row(
                p_api_version                  => 1,
                p_init_msg_list                => FND_API.G_FALSE,
                x_return_status                => x_return_status,
                x_msg_count                    => x_msg_count,
                x_msg_data                     => x_msg_data,
                p_id                           => l_orig_system_reference_id1,
                p_object_version_number        => NULL
                );

       --------------------------------------------
         IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
         ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR ;
        END IF;
       --------------------------------------------

          IF (l_debug = 'Y') THEN
                okc_debug.log('710: Before Calling Lock Entity', 2);
          END IF;


       okc_k_entity_locks_grp.lock_entity
                      ( p_api_version     => 1,
                       p_init_msg_list    => FND_API.G_FALSE ,
                       p_commit           => FND_API.G_FALSE,
                       p_entity_name      => okc_k_entity_locks_grp.G_CLAUSE_ENTITY,
                       p_entity_pk1       => To_Char(l_orig_system_reference_id1),
                       P_LOCK_BY_ENTITY_ID => p_id,
                       p_LOCK_BY_DOCUMENT_TYPE => l_document_type,
                       p_LOCK_BY_DOCUMENT_ID => l_document_id,
                       X_RETURN_STATUS => X_RETURN_STATUS,
                       X_MSG_COUNT => X_MSG_COUNT,
                       X_MSG_DATA => X_MSG_DATA
                      );
        --------------------------------------------
         IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
         ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR ;
        END IF;
       --------------------------------------------
    END IF;



    --------------------------------------------
    -- Calling Simple API for Updating A Row
    --------------------------------------------
    OKC_K_ARTICLES_PVT.Update_Row(
      p_validation_level           => p_validation_level,
      x_return_status              => x_return_status,
      p_id                         => p_id,
      p_sav_sae_id                 => p_sav_sae_id,
      p_document_type              => p_document_type,
      p_document_id                => p_document_id,
      p_cle_id                     => p_cle_id,
      p_source_flag                => p_source_flag,
      p_mandatory_yn               => p_mandatory_yn,
     p_mandatory_rwa              => p_mandatory_rwa,
      p_scn_id                     => p_scn_id,
      p_label                      => p_label,
      p_amendment_description      => l_amendment_description,
      p_amendment_operation_code   => l_amendment_operation_code,
      p_summary_amend_operation_code   => l_summary_amend_operation_code,
      p_article_version_id         => p_article_version_id,
      p_change_nonstd_yn           => p_change_nonstd_yn,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1  => p_orig_system_reference_id1,
      p_orig_system_reference_id2  => p_orig_system_reference_id2,
      p_display_sequence           => p_display_sequence,
      p_attribute_category         => p_attribute_category,
      p_attribute1                 => p_attribute1,
      p_attribute2                 => p_attribute2,
      p_attribute3                 => p_attribute3,
      p_attribute4                 => p_attribute4,
      p_attribute5                 => p_attribute5,
      p_attribute6                 => p_attribute6,
      p_attribute7                 => p_attribute7,
      p_attribute8                 => p_attribute8,
      p_attribute9                 => p_attribute9,
      p_attribute10                => p_attribute10,
      p_attribute11                => p_attribute11,
      p_attribute12                => p_attribute12,
      p_attribute13                => p_attribute13,
      p_attribute14                => p_attribute14,
      p_attribute15                => p_attribute15,
      p_print_text_yn              => p_print_text_yn,
      p_ref_article_id             => p_ref_article_id,
      p_ref_article_version_id     => p_ref_article_version_id,
      p_object_version_number      => p_object_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------
    IF FND_API.To_Boolean(l_sync_variable) THEN

    -- If Article is changed then
    --  1.Create record in okc_k_art_variables for those variables which are present in new article version but were absent in old article version.
    --  2.Delete record in okc_k_art_variables for those variables which are present in old article version but absent in new article version.
    --  3.Update record in okc_k_art_variables for those variables which are present in both version and for which value has been entered previously.


--  creating new article variables
        IF (l_debug = 'Y') THEN
          okc_debug.log('1710: Creating New article variables for article version '|| l_article_version_id, 2);
        END IF;

        FOR l_create_variable_rec IN l_create_variable_csr LOOP
                OKC_K_ART_VARIABLES_PVT.insert_row(
                                  x_return_status          => x_return_status,
                                  p_cat_id                 => p_id,
                                  p_variable_code          => l_create_variable_rec.variable_code,
                                  p_variable_type          => l_create_variable_rec.variable_type,
                                  p_external_yn            => l_create_variable_rec.external_yn,
                                  p_variable_value_id      => l_create_variable_rec.variable_value_id,
                                  p_variable_value         => l_create_variable_rec.variable_value,
                                  p_attribute_value_set_id => l_create_variable_rec.value_set_id,
                                  x_cat_id                 => x_cat_id,
                                  x_variable_code          => x_variable_code
                                       );

                  IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                  ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                      RAISE FND_API.G_EXC_ERROR ;
                  END IF;
        END LOOP;

--  deleting old article variables
        IF (l_debug = 'Y') THEN
          okc_debug.log('1710: Deleing old article variables for article version '|| p_article_version_id||' which are not present in new article version', 2);
        END IF;

        FOR l_delete_variable_rec IN l_delete_variable_csr LOOP
                  OKC_K_ART_VARIABLES_PVT.delete_row(
                                    x_return_status         => x_return_status,
                                    p_cat_id                => l_delete_variable_rec.cat_id,
                                    p_variable_code         => l_delete_variable_rec.variable_code,
                                    p_object_version_number => l_delete_variable_rec.object_version_number
                                             );

                  IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                  ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                      RAISE FND_API.G_EXC_ERROR ;
                  END IF;
        END LOOP;


--  Update old article variable values
        IF (l_debug = 'Y') THEN
          okc_debug.log('1710: Updating article variables values for article version '|| p_article_version_id, 2);
        END IF;

        FOR l_update_variable_rec IN l_update_variable_csr LOOP

                OKC_K_ART_VARIABLES_PVT.update_row(
                                            x_return_status          => x_return_status,
                                            p_cat_id                 => p_id,
                                            p_variable_code          => l_update_variable_rec.variable_code,
                                            p_variable_type          => l_update_variable_rec.variable_type,
                                            p_external_yn            => l_update_variable_rec.external_yn,
                                            p_variable_value_id      => l_update_variable_rec.variable_value_id,
                                            p_variable_value         => l_update_variable_rec.variable_value,
                                            p_attribute_value_set_id => l_update_variable_rec.value_set_id,
                                            p_object_version_number  => l_update_variable_rec.object_version_number
                                            );

                  IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                  ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                      RAISE FND_API.G_EXC_ERROR ;
                  END IF;
        END LOOP;

    END IF;

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    IF (l_debug = 'Y') THEN
      okc_debug.log('1800: Leaving update_article', 2);
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('1900: Leaving update_article: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;

      IF l_document_id_csr%ISOPEN THEN
         CLOSE l_document_id_csr;
      END IF;

      IF l_art_version_csr%ISOPEN THEN
         CLOSE l_art_version_csr;
      END IF;

      IF l_update_variable_csr%ISOPEN THEN
         CLOSE  l_update_variable_csr;
      END IF;

      IF l_delete_variable_csr%ISOPEN THEN
         CLOSE  l_delete_variable_csr;
      END IF;

      IF l_create_variable_csr%ISOPEN THEN
         CLOSE  l_create_variable_csr;
      END IF;

      ROLLBACK TO g_update_article_grp;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('2000: Leaving update_article: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;

      IF l_document_id_csr%ISOPEN THEN
         CLOSE l_document_id_csr;
      END IF;

      IF l_art_version_csr%ISOPEN THEN
         CLOSE l_art_version_csr;
      END IF;

      IF l_update_variable_csr%ISOPEN THEN
         CLOSE  l_update_variable_csr;
      END IF;

      IF l_delete_variable_csr%ISOPEN THEN
         CLOSE  l_delete_variable_csr;
      END IF;

      IF l_create_variable_csr%ISOPEN THEN
         CLOSE  l_create_variable_csr;
      END IF;

      ROLLBACK TO g_update_article_grp;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('2100: Leaving update_article because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      IF l_document_id_csr%ISOPEN THEN
         CLOSE l_document_id_csr;
      END IF;

      IF l_art_version_csr%ISOPEN THEN
         CLOSE l_art_version_csr;
      END IF;

      IF l_update_variable_csr%ISOPEN THEN
         CLOSE  l_update_variable_csr;
      END IF;

      IF l_delete_variable_csr%ISOPEN THEN
         CLOSE  l_delete_variable_csr;
      END IF;

      IF l_create_variable_csr%ISOPEN THEN
         CLOSE  l_create_variable_csr;
      END IF;

      ROLLBACK TO g_update_article_grp;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  END update_article;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_article
  ---------------------------------------------------------------------------
  PROCEDURE delete_article(
    p_api_version                IN NUMBER,
    p_init_msg_list              IN VARCHAR2,
    p_validate_commit            IN VARCHAR2,
    p_validation_string          IN VARCHAR2,
    p_commit                     IN VARCHAR2,
    p_mode                       IN VARCHAR2,

    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    p_super_user_yn              IN VARCHAR2,
    p_amendment_description      IN VARCHAR2,
    p_print_text_yn              IN VARCHAR2,
    p_id                         IN NUMBER,
    p_object_version_number      IN NUMBER,
    p_mandatory_clause_delete    IN VARCHAR2,
    p_lock_terms_yn                IN VARCHAR2
  ) IS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'g_delete_article';
    l_ok_to_commit                 VARCHAR2(1);
    l_document_id                  NUMBER;
    l_cle_id                      NUMBER;
    l_document_type                VARCHAR2(30);
    l_mandatory_yn                 VARCHAR2(1);
    l_standard_yn                  VARCHAR2(1);
    l_amendment_operation_code    OKC_K_ARTICLES_B.AMENDMENT_OPERATION_CODE%TYPE;
    l_amendment_description       OKC_K_ARTICLES_B.AMENDMENT_DESCRIPTION%TYPE;

    l_summary_amend_operation_code OKC_SECTIONS_B.SUMMARY_AMEND_OPERATION_CODE%TYPE;
    l_existing_summary_code      OKC_SECTIONS_B.SUMMARY_AMEND_OPERATION_CODE%TYPE;
    l_existing_operation_code    OKC_SECTIONS_B.SUMMARY_AMEND_OPERATION_CODE%TYPE;
    l_delete_rec                 BOOLEAN := FALSE;
    l_orig_system_reference_id1   NUMBER;

    CURSOR l_document_id_csr IS
    SELECT kart.DOCUMENT_ID,kart.DOCUMENT_TYPE,kart.mandatory_yn, art.standard_yn
    FROM OKC_K_ARTIClES_B kart, OKC_ARTICLES_ALL art
    WHERE kart.sav_sae_id = art.article_id
      AND ID=P_ID;

    CURSOR l_get_summary_code_csr IS
    SELECT SUMMARY_AMEND_OPERATION_CODE,AMENDMENT_OPERATION_CODE,orig_system_reference_id1
    FROM OKC_K_ARTICLES_B
    WHERE ID=P_ID;


  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.log('2200: Entered delete_article', 2);
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_delete_article_grp;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    OPEN  l_document_id_csr;
    FETCH l_document_id_csr INTO l_document_id,l_document_type,l_mandatory_yn, l_standard_yn;
    CLOSE l_document_id_csr;

    IF l_mandatory_yn='Y' and l_document_type<>'TEMPLATE' and p_super_user_yn='N' and p_mandatory_clause_delete='N' THEN

        okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKC_DEL_MAND_ARTICLE');

         raise FND_API.G_EXC_ERROR;

    END IF;

    -- if user does NOT have non-std access, don't allow delete of non-std articles
    IF (NOT fnd_function.test('OKC_TERMS_AUTHOR_NON_STD','N'))  AND
       l_standard_yn ='N' THEN
        okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKC_DEL_NON_STD_ARTICLE');

         raise FND_API.G_EXC_ERROR;
    END IF;


    IF FND_API.To_Boolean( p_validate_commit ) THEN


       IF NOT FND_API.To_Boolean(OKC_TERMS_UTIL_GRP.ok_to_commit (
                                         p_api_version => l_api_version,
                                         p_init_msg_list => FND_API.G_FALSE,
                                         p_doc_type      => l_document_type,
                                         p_doc_id        => l_document_id,
                                         p_validation_string => p_validation_string,
                                         x_return_status => x_return_status,
                                         x_msg_data      => x_msg_data,
                                         x_msg_count     => x_msg_count)
  ) THEN

             IF (l_debug = 'Y') THEN
                okc_debug.log('2250: Issue with document header Record.Cannot commit', 2) ;
             END IF;
             RAISE FND_API.G_EXC_ERROR ;
      END IF;
    END IF;


   IF p_mode='AMEND' THEN

       OPEN  l_get_summary_code_csr;
       FETCH l_get_summary_code_csr INTO l_existing_summary_code,l_existing_operation_code,l_orig_system_reference_id1;
       CLOSE l_get_summary_code_csr;

       l_amendment_operation_code:=G_AMEND_CODE_DELETED;
       l_amendment_description   := p_amendment_description;

       IF nvl(l_existing_operation_code,'?') <> G_AMEND_CODE_ADDED THEN

            l_summary_amend_operation_code := OKC_TERMS_UTIL_PVT.get_summary_amend_code(p_existing_summary_code =>l_existing_summary_code,
        p_existing_operation_code=>l_existing_operation_code,
        p_amend_operation_code=>G_AMEND_CODE_DELETED);

            -----------------------------------------------------------------
            -- Concurrent Mod Changes
            -- Call the Lock entity API only in AMEND mode
            --                  and when p_lock_terms_yn is 'Y' .
            -----------------------------------------------------------------
            IF (      p_mode='AMEND'
                AND  p_lock_terms_yn = 'Y'
                AND  l_orig_system_reference_id1 IS NOT null
                )
            THEN


                 -- Try to lock the base record. for real time concurrency:
              lock_row(
                p_api_version                  => 1,
                p_init_msg_list                => FND_API.G_FALSE,
                x_return_status                => x_return_status,
                x_msg_count                    => x_msg_count,
                x_msg_data                     => x_msg_data,
                p_id                           => l_orig_system_reference_id1,
                p_object_version_number        => NULL
                );

              --------------------------------------------
              IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
              ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR ;
              END IF;
             --------------------------------------------

              okc_k_entity_locks_grp.lock_entity
                              ( p_api_version     => 1,
                              p_init_msg_list    => FND_API.G_FALSE ,
                              p_commit           => FND_API.G_FALSE,
                              p_entity_name      => okc_k_entity_locks_grp.G_CLAUSE_ENTITY,
                              p_entity_pk1       => To_Char(l_orig_system_reference_id1),
                              P_LOCK_BY_ENTITY_ID => p_id,
                              p_LOCK_BY_DOCUMENT_TYPE => l_document_type,
                              p_LOCK_BY_DOCUMENT_ID => l_document_id,
                              X_RETURN_STATUS => X_RETURN_STATUS,
                              X_MSG_COUNT => X_MSG_COUNT,
                              X_MSG_DATA => X_MSG_DATA
                              );
                --------------------------------------------
                IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                  RAISE FND_API.G_EXC_ERROR ;
                END IF;
              --------------------------------------------
          END IF;


            OKC_K_ARTICLES_PVT.Update_Row(
                         x_return_status              => x_return_status,
                         p_id                         => p_id,
                         p_amendment_operation_code   => l_amendment_operation_code,
                         p_amendment_description        => l_amendment_description,
                         p_print_text_yn                => p_print_text_yn,
                         p_summary_amend_operation_code => l_summary_amend_operation_code,
                         p_object_version_number        => NULL
                               );

          IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
          ELSIF (x_return_status = G_RET_STS_ERROR) THEN
              RAISE FND_API.G_EXC_ERROR ;
          END IF;
       ELSE
           l_delete_rec := TRUE;
       END IF;
   END IF;

   IF p_mode<>'AMEND' or l_delete_rec THEN
      -- Delete Child records from OKC_K_ART_VARIABLES_TABLE
      IF (l_debug = 'Y') THEN
          okc_debug.log('2260: Deleting Child record from okc_k_art_varibles', 2) ;
      END IF;

      OKC_K_ART_VARIABLES_PVT.delete_set(
                                    x_return_status         => x_return_status,
                                    p_cat_id                => p_id
                                       );

     IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
     ELSIF (x_return_status = G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR ;
     END IF;

     IF (l_debug = 'Y') THEN
          okc_debug.log('760: Deleting Record from okc_k_articles', 2) ;
     END IF;
     --------------------------------------------
     -- Calling Simple API for Deleting A Row
     --------------------------------------------
     OKC_K_ARTICLES_PVT.Delete_Row(
           x_return_status              => x_return_status,
           p_id                         => p_id,
           p_object_version_number      => p_object_version_number
         );
     --------------------------------------------
     IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
     ELSIF (x_return_status = G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR ;
     END IF;
     --------------------------------------------
   END IF;
    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    IF (l_debug = 'Y') THEN
       okc_debug.log('2300: Leaving delete_article', 2);
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('2400: Leaving delete_article: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;

      IF l_document_id_csr%ISOPEN THEN
         CLOSE l_document_id_csr;
      END IF;


      ROLLBACK TO g_delete_article_grp;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('2500: Leaving delete_article: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;

      IF l_document_id_csr%ISOPEN THEN
         CLOSE l_document_id_csr;
      END IF;


      ROLLBACK TO g_delete_article_grp;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('2600: Leaving delete_article because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      IF l_document_id_csr%ISOPEN THEN
         CLOSE l_document_id_csr;
      END IF;


      ROLLBACK TO g_delete_article_grp;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  END delete_article;

   PROCEDURE delete_articles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validate_commit              IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_string            IN VARCHAR2,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,
    p_mode                         IN VARCHAR2 := 'NORMAL', -- Other value 'AMEND'
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_super_user_yn              IN VARCHAR2 :='N',
    p_amendment_description      IN VARCHAR2 := NULL,
    p_print_text_yn              IN VARCHAR2 := 'N',
    p_id_tbl                     IN id_tbl_type,
    p_object_version_number      IN id_tbl_type,
    p_mandatory_clause_delete    IN VARCHAR2 := 'N' ,
    p_lock_terms_yn                IN VARCHAR2 := 'N'
    )
    IS

    l_amend_code VARCHAR2(240);
    l_amend_descr VARCHAR2(500) := p_amendment_description;
    l_mode VARCHAR2(240) := p_mode;
    l_print_text_yn VARCHAR2(1) :=p_print_text_yn;

    BEGIN

      FOR i IN 1..p_id_tbl.Count()
       LOOP

       /* The following logic exists in  OA layer for a single object delete*/
       IF p_mode = 'AMEND'
       then

          SELECT   amendment_operation_code,print_text_yn INTO  l_amend_code,l_print_text_yn
          from okc_k_articles_b where id = p_id_tbl(i);

          IF  l_amend_code = 'ADDED' THEN
               l_amend_descr := NULL;
               l_mode :=  'NORMAL';

          END IF;

      END IF;


           delete_article(
        p_api_version                => 1.0,
        p_init_msg_list              => p_init_msg_list,
    p_validate_commit            => p_validate_commit,
    p_validation_string          => p_validation_string,
    p_commit                     => p_commit,
    p_mode                       => p_mode,
    x_return_status              => x_return_status,
    x_msg_count                  => x_msg_count,
    x_msg_data                   => x_msg_data,
    p_super_user_yn              => p_super_user_yn,
    p_amendment_description      => p_amendment_description,
    p_print_text_yn              => l_print_text_yn,
    p_id                         => p_id_tbl(i),
    p_object_version_number      => p_object_version_number(i),
    p_mandatory_clause_delete    => p_mandatory_clause_delete,
    p_lock_terms_yn              => p_lock_terms_yn
  )    ;


            IF (x_return_status<>'S') THEN
                 EXIT;
            END IF;

       END LOOP;
    END   delete_articles;




END OKC_K_ARTICLES_GRP;

/
