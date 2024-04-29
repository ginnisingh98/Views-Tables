--------------------------------------------------------
--  DDL for Package Body OKC_TERMS_MULTIREC_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TERMS_MULTIREC_GRP" AS
/* $Header: OKCGMULB.pls 120.11.12010000.9 2011/12/09 13:33:14 serukull ship $ */

    l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                    CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_TERMS_MULTIREC_GRP';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_FALSE	               CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;
  G_MISS_NUM                   CONSTANT   NUMBER      := FND_API.G_MISS_NUM;
  G_RET_STS_SUCCESS            CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
  G_AMEND_CODE_ADDED           CONSTANT   VARCHAR2(30) := 'ADDED';
  G_AMEND_CODE_UPDATED         CONSTANT   VARCHAR2(30) := 'UPDATED';

  G_DBG_LEVEL							  NUMBER 		:= FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_PROC_LEVEL							  NUMBER		:= FND_LOG.LEVEL_PROCEDURE;
  G_EXCP_LEVEL							  NUMBER		:= FND_LOG.LEVEL_EXCEPTION;

  TYPE scn_child_rec_type IS RECORD (
    id                        OKC_K_ARTICLES_B.id%type,
    display_sequence          OKC_K_ARTICLES_B.display_sequence%type,
    OBJECT_TYPE               VARCHAR2(30)
    );

   TYPE scn_child_tbl_type IS TABLE OF scn_child_rec_type INDEX BY BINARY_INTEGER;

PROCEDURE create_article(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    p_mode                         IN VARCHAR2,
    p_validation_level	           IN NUMBER,
    p_validate_commit              IN VARCHAR2,
    p_validation_string            IN VARCHAR2,
    p_commit                       IN VARCHAR2 ,
    p_ref_type                     IN VARCHAR2 := 'SECTION', -- 'ARTICLE' or 'SECTION'
    p_ref_id                       IN NUMBER, -- Id of okc_sections_b or okc_articles_b depending upon ref type
    p_doc_type                     IN VARCHAR2,
    p_doc_id                       IN NUMBER,

    p_kart_tbl                     IN kart_tbl_type,
    x_kart_tbl                     OUT NOCOPY kart_tbl_type,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2
    ) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'create_article';
    l_id                          NUMBER;
    l_scn_id                       NUMBER;
    i                             NUMBER := 0;
    l_ref_count                   NUMBER := 0;
    l_ref_sequence                NUMBER := 0;
    l_amendment_description       OKC_K_ARTICLES_B.amendment_description%TYPE;
    l_print_text_yn               OKC_K_ARTICLES_B.amendment_description%TYPE;


    CURSOR l_get_scn_child_csr(b_scn_id NUMBER) IS
    SELECT ID,SECTION_SEQUENCE DISPLAY_SEQ,'SECTION' obj_type
    FROM   OKC_SECTIONS_B
    WHERE  document_type = p_doc_type
    AND    document_id   = p_doc_id
    AND    scn_id=b_scn_id
    UNION ALL
    SELECT ID,DISPLAY_SEQUENCE DISPLAY_SEQ,'ARTICLE' obj_type
    FROM   OKC_K_ARTICLES_B
    WHERE  document_type = p_doc_type
    AND    document_id   = p_doc_id
    AND    scn_id=b_scn_id
    ORDER  BY 2;

    CURSOR l_get_scn_csr(b_cat_id NUMBER) IS
    SELECT SCN_ID FROM OKC_K_ARTICLES_B
    WHERE ID=b_cat_id;

    scn_child_rec     l_get_scn_child_csr%ROWTYPE;
    scn_child_tbl     scn_child_tbl_type;

  BEGIN

    /*IF (l_debug = 'Y') THEN
      okc_debug.log('100: Entered create_article', 2);
      okc_debug.log('100: Parameter List ', 2);
      okc_debug.log('100: p_api_version : '||p_api_version, 2);
      okc_debug.log('100: p_init_msg_list : '||p_init_msg_list, 2);
      okc_debug.log('100: p_mode : '||p_mode, 2);
      okc_debug.log('100: p_validation_level : '||p_validation_level, 2);
      okc_debug.log('100: p_validate_commit : '||p_validate_commit, 2);
      okc_debug.log('100: p_validation_string : '||p_validation_string, 2);
      okc_debug.log('100: p_commit : '||p_commit, 2);
      okc_debug.log('100: p_ref_type : '||p_ref_type, 2);
      okc_debug.log('100: p_ref_id : '||p_ref_id, 2);
      okc_debug.log('100: p_doc_type : '||p_doc_type, 2);
      okc_debug.log('100: p_doc_id : '||p_doc_id, 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
       FND_LOG.STRING(G_PROC_LEVEL,
           G_PKG_NAME, '100: Entered create_article' );
       FND_LOG.STRING(G_PROC_LEVEL,
           G_PKG_NAME, '100: Parameter List ' );
       FND_LOG.STRING(G_PROC_LEVEL,
           G_PKG_NAME, '100: p_api_version : '||p_api_version );
       FND_LOG.STRING(G_PROC_LEVEL,
           G_PKG_NAME, '100: p_init_msg_list : '||p_init_msg_list );
       FND_LOG.STRING(G_PROC_LEVEL,
           G_PKG_NAME, '100: p_mode : '||p_mode );
       FND_LOG.STRING(G_PROC_LEVEL,
           G_PKG_NAME, '100: p_validation_level : '||p_validation_level );
       FND_LOG.STRING(G_PROC_LEVEL,
           G_PKG_NAME, '100: p_validate_commit : '||p_validate_commit );
       FND_LOG.STRING(G_PROC_LEVEL,
           G_PKG_NAME, '100: p_validation_string : '||p_validation_string );
       FND_LOG.STRING(G_PROC_LEVEL,
           G_PKG_NAME, '100: p_commit : '||p_commit );
       FND_LOG.STRING(G_PROC_LEVEL,
           G_PKG_NAME, '100: p_ref_type : '||p_ref_type );
       FND_LOG.STRING(G_PROC_LEVEL,
           G_PKG_NAME, '100: p_ref_id : '||p_ref_id );
       FND_LOG.STRING(G_PROC_LEVEL,
           G_PKG_NAME, '100: p_doc_type : '||p_doc_type );
       FND_LOG.STRING(G_PROC_LEVEL,
           G_PKG_NAME, '100: p_doc_id : '||p_doc_id );
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_create_article_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

   IF p_kart_tbl.COUNT >0
      AND FND_API.To_Boolean( p_validate_commit ) THEN

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

   IF p_kart_tbl.COUNT > 0 THEN

       IF p_ref_type='ARTICLE' THEN

          OPEN  l_get_scn_csr(p_ref_id);
          FETCH l_get_scn_csr INTO l_scn_id;
          CLOSE l_get_scn_csr;

       ELSIF p_ref_type='SECTION' THEN
           l_scn_id := p_ref_id;
       ELSE
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

       END IF;

       OPEN l_get_scn_child_csr(l_scn_id);
       LOOP
          FETCH l_get_scn_child_csr INTO scn_child_rec;
          EXIT WHEN l_get_scn_child_csr%NOTFOUND;
          i := i+1;
          scn_child_tbl(i).id                    := scn_child_rec.id;
          scn_child_tbl(i).display_sequence      := scn_child_rec.display_seq;
          scn_child_tbl(i).object_type := scn_child_rec.obj_type;

          IF p_ref_type='ARTICLE' AND scn_child_tbl(i).object_type='ARTICLE' AND scn_child_tbl(i).id = p_ref_id  THEN
             l_ref_count := i;
          END IF;

       END LOOP;
       CLOSE l_get_scn_child_csr;


       IF p_ref_type ='SECTION' THEN
            l_ref_count := i;
       END IF;

       IF i=0 THEN
          l_ref_sequence := 0;
       ELSE
          l_ref_sequence := scn_child_tbl(l_ref_count).display_sequence;
       END IF;

       FOR i IN p_kart_tbl.FIRST..p_kart_tbl.LAST LOOP

          /*IF (l_debug = 'Y') THEN
              okc_debug.log('110: Creating Article No '||p_kart_tbl(i).sav_sae_id, 2);
          END IF;*/

	  IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
	     FND_LOG.STRING(G_PROC_LEVEL,
		 G_PKG_NAME, '110: Creating Article No '||p_kart_tbl(i).sav_sae_id );
	  END IF;

              l_ref_sequence := l_ref_sequence + 10;

              IF p_mode='AMEND' THEN
                 l_amendment_description    := p_kart_tbl(i).amendment_description;
                 l_print_text_yn            := p_kart_tbl(i).print_text_yn;
              ELSE
                 l_amendment_description    := NULL;
                 l_print_text_yn            := 'N';
              END IF;

              OKC_K_ARTICLES_GRP.create_article(
                    p_api_version           => 1,
                    p_init_msg_list         => FND_API.G_FALSE,
                    p_validation_level      => 0,
                    p_mode                  => p_mode,
                    x_return_status         => x_return_status,
                    x_msg_count             => x_msg_count,
                    x_msg_data              => x_msg_data,
                    p_id                    => NULL,
                    p_sav_sae_id            => p_kart_tbl(i).sav_sae_id,
                    p_document_type         => p_doc_type,
                    p_document_id           => p_doc_id,
                    p_scn_id                => l_scn_id,
                    p_article_version_id    => p_kart_tbl(i).article_version_id,
                    p_display_sequence      => l_ref_sequence,
                    p_amendment_description => l_amendment_description,
                    p_print_text_yn         => l_print_text_yn,
                    p_ref_article_version_id=> p_kart_tbl(i).ref_article_version_id,
                    p_ref_article_id        => p_kart_tbl(i).ref_article_id,
                    x_id                    => l_id
                 );

       --------------------------------------------
            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
              RAISE FND_API.G_EXC_ERROR ;
            END IF;
       --------------------------------------------
             x_kart_tbl(i).id := l_id;
       END LOOP;
    END IF;

    IF scn_child_tbl.COUNT > 0 THEN
       FOR k IN scn_child_tbl.FIRST..scn_child_tbl.LAST LOOP
           IF k > l_ref_count THEN

                l_ref_sequence := l_ref_sequence + 10;
                IF scn_child_tbl(k).object_type='ARTICLE' THEN

                    /*IF (l_debug = 'Y') THEN
                       okc_debug.log('120: Updating Display Sequence of cat_id '||scn_child_tbl(k).id, 2);
                    END IF;*/

		    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
			     FND_LOG.STRING(G_PROC_LEVEL,
				    G_PKG_NAME, '120: Updating Display Sequence of cat_id '||scn_child_tbl(k).id );
	   	    END IF;

                    OKC_K_ARTICLES_GRP.update_article(
                          p_api_version          =>1,
                          p_init_msg_list        => OKC_API.G_FALSE,
                          x_return_status        => x_return_status,
                          x_msg_count            => x_msg_count,
                          x_msg_data             => x_msg_data,
                          p_id                   => scn_child_tbl(k).id,
                          p_display_sequence     => l_ref_sequence,
                          p_object_version_number => Null
                                                );
                   --------------------------------------------
                  IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                  ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR ;
                  END IF;
                   --------------------------------------------
                ELSIF scn_child_tbl(k).object_type='SECTION' THEN

                   /*IF (l_debug = 'Y') THEN
                       okc_debug.log('1000: Updating Display Sequence of scn_id '||scn_child_tbl(k).id, 2);
                   END IF;*/

		   IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
			     FND_LOG.STRING(G_PROC_LEVEL,
				    G_PKG_NAME, '1000: Updating Display Sequence of scn_id '||scn_child_tbl(k).id );
	   	   END IF;

                   OKC_TERMS_SECTIONS_GRP.update_section(
                         p_api_version          =>1,
                         p_init_msg_list        => OKC_API.G_FALSE,
                         x_return_status        => x_return_status,
                         x_msg_count            => x_msg_count,
                         x_msg_data             => x_msg_data,
                         p_id                   => scn_child_tbl(k).id,
                         p_section_sequence     => l_ref_sequence,
                         p_object_version_number =>Null
                                                );
                   --------------------------------------------
                  IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                  ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR ;
                  END IF;

                END IF; -- IF scn_child_tbl(k).object_type='ARTICLE' THEN
           END IF;
       END LOOP;
    END IF;

       -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    /*IF (l_debug = 'Y') THEN
       okc_debug.log('200: Leaving create_article', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
	FND_LOG.STRING(G_PROC_LEVEL,
	    G_PKG_NAME, '200: Leaving create_article' );
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('300: Leaving create_article: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
    	  FND_LOG.STRING(G_EXCP_LEVEL,
 	      G_PKG_NAME, '300: Leaving create_article: OKC_API.G_EXCEPTION_ERROR Exception' );
      END IF;

      IF l_get_scn_child_csr%ISOPEN THEN
         CLOSE l_get_scn_child_csr;
      END IF;

      IF l_get_scn_csr%ISOPEN THEN
         CLOSE l_get_scn_csr;
      END IF;

      ROLLBACK TO g_create_article_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('400: Leaving create_article: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
    	  FND_LOG.STRING(G_EXCP_LEVEL,
 	      G_PKG_NAME, '400: Leaving create_article: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception' );
      END IF;

      IF l_get_scn_child_csr%ISOPEN THEN
         CLOSE l_get_scn_child_csr;
      END IF;

      IF l_get_scn_csr%ISOPEN THEN
         CLOSE l_get_scn_csr;
      END IF;

      ROLLBACK TO g_create_article_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
        okc_debug.log('500: Leaving create_article because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
    	  FND_LOG.STRING(G_EXCP_LEVEL,
 	      G_PKG_NAME, '500: Leaving create_article because of EXCEPTION: '||sqlerrm );
      END IF;

      IF l_get_scn_child_csr%ISOPEN THEN
         CLOSE l_get_scn_child_csr;
      END IF;

      IF l_get_scn_csr%ISOPEN THEN
         CLOSE l_get_scn_csr;
      END IF;

      ROLLBACK TO g_create_article_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  END create_article;

PROCEDURE update_article_variable(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER ,
    p_validate_commit              IN VARCHAR2 ,
    p_validation_string            IN VARCHAR2,
    p_commit                       IN VARCHAR2 ,
    p_art_var_tbl                  IN art_var_tbl_type,
    p_mode                         IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lock_terms_yn                IN VARCHAR2
    ) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'update_article_variable';
    l_doc_type                    VARCHAR2(30);
    l_doc_id                      NUMBER;
    l_dummy                       NUMBER := FND_API.G_MISS_NUM;

    CURSOR l_doc_csr(b_cat_id NUMBER) IS
    SELECT DOCUMENT_TYPE,DOCUMENT_ID
    FROM OKC_K_ARTICLES_B
    WHERE id=b_cat_id;

    CURSOR l_amend_art_csr(b_cat_id NUMBER) IS
    SELECT object_version_number
    FROM OKC_K_ARTICLES_B
    WHERE ID=b_cat_id
    AND   AMENDMENT_OPERATION_CODE<>G_AMEND_CODE_UPDATED;

  BEGIN

    /*IF (l_debug = 'Y') THEN
      okc_debug.log('100: Entered update_article_variable', 2);
      okc_debug.log('100: Parameter List ', 2);
      okc_debug.log('100: p_api_version : '||p_api_version, 2);
      okc_debug.log('100: p_init_msg_list : '||p_init_msg_list, 2);
      okc_debug.log('100: p_mode : '||p_mode, 2);
      okc_debug.log('100: p_validation_level : '||p_validation_level, 2);
      okc_debug.log('100: p_validate_commit : '||p_validate_commit, 2);
      okc_debug.log('100: p_validation_string : '||p_validation_string, 2);
      okc_debug.log('100: p_commit : '||p_commit, 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
       FND_LOG.STRING(G_PROC_LEVEL,
           G_PKG_NAME, '100: Entered update_article_variable' );
       FND_LOG.STRING(G_PROC_LEVEL,
           G_PKG_NAME, '100: Parameter List ' );
       FND_LOG.STRING(G_PROC_LEVEL,
           G_PKG_NAME, '100: p_api_version : '||p_api_version );
       FND_LOG.STRING(G_PROC_LEVEL,
           G_PKG_NAME, '100: p_init_msg_list : '||p_init_msg_list );
       FND_LOG.STRING(G_PROC_LEVEL,
           G_PKG_NAME, '100: p_mode : '||p_mode );
       FND_LOG.STRING(G_PROC_LEVEL,
           G_PKG_NAME, '100: p_validation_level : '||p_validation_level );
       FND_LOG.STRING(G_PROC_LEVEL,
           G_PKG_NAME, '100: p_validate_commit : '||p_validate_commit );
       FND_LOG.STRING(G_PROC_LEVEL,
           G_PKG_NAME, '100: p_validation_string : '||p_validation_string );
       FND_LOG.STRING(G_PROC_LEVEL,
           G_PKG_NAME, '100: p_commit : '||p_commit );
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_update_article_variable_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF p_art_var_tbl.FIRST IS NOT NULL
      AND FND_API.To_Boolean( p_validate_commit ) THEN

      OPEN  l_doc_csr(p_art_var_tbl(1).cat_id);
      FETCH l_doc_csr INTO l_doc_type,l_doc_id;
      CLOSE l_doc_csr;
      IF  NOT FND_API.To_Boolean(OKC_TERMS_UTIL_GRP.ok_to_commit (
                                         p_api_version   => l_api_version,
                                         p_init_msg_list => FND_API.G_FALSE,
                                         p_doc_type      => l_doc_type,
                                         p_doc_id        => l_doc_id,
                                         p_validation_string => p_validation_string,
                                         x_return_status => x_return_status,
                                         x_msg_data      => x_msg_data,
                                         x_msg_count     => x_msg_count)                  ) THEN

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

    IF p_art_var_tbl.FIRST IS NOT NULL THEN
       FOR i IN p_art_var_tbl.FIRST..p_art_var_tbl.LAST LOOP
         /*IF (l_debug = 'Y') THEN
              okc_debug.log('115: Updating variable '||p_art_var_tbl(i).variable_code, 2);
         END IF;*/

	 IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
	        FND_LOG.STRING(G_PROC_LEVEL,
  	            G_PKG_NAME, '115: Updating variable '||p_art_var_tbl(i).variable_code );
	 END IF;

         OKC_K_ART_VARIABLES_PVT.update_row(
                             p_validation_level	          => 0,
                             x_return_status              => x_return_status,
                             p_cat_id                     => p_art_var_tbl(i).cat_id,
                             p_variable_code              => p_art_var_tbl(i).variable_code,
                             p_variable_type              => p_art_var_tbl(i).variable_type,
                             p_external_yn                => p_art_var_tbl(i).external_yn,
                             p_variable_value_id          => p_art_var_tbl(i).variable_value_id,
                             p_variable_value             => p_art_var_tbl(i).variable_value,
                             p_attribute_value_set_id     => p_art_var_tbl(i).attribute_value_set_id,
                             p_object_version_number      => p_art_var_tbl(i).object_version_number
                                          );

              --------------------------------------------
              IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
              ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
              END IF;
              --------------------------------------------
             IF p_mode ='AMEND' THEN
                  l_dummy := FND_API.G_MISS_NUM;
                  OPEN  l_amend_art_csr(p_art_var_tbl(i).cat_id);
                  FETCH l_amend_art_csr into l_dummy;
                  CLOSE l_amend_art_csr;
                  IF l_dummy <> FND_API.G_MISS_NUM THEN

                     /*IF (l_debug = 'Y') THEN
                          okc_debug.log('125: Updating Amend Operation Code for cat_id '||p_art_var_tbl(i).cat_id, 2);
                     END IF;*/

		     IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
	      		    FND_LOG.STRING(G_PROC_LEVEL,
	  	            G_PKG_NAME, '125: Updating Amend Operation Code for cat_id '||p_art_var_tbl(i).cat_id );
		     END IF;
                    OKC_K_ARTICLES_GRP.Update_article(
                                     p_api_version                => 1,
                                     p_init_msg_list              => FND_API.G_FALSE,
                                     p_validation_level           => 0,
                                     p_mode                       => p_mode,
                                     x_msg_count                  => x_msg_count,
                                     x_msg_data                   => x_msg_data,
                                     x_return_status              => x_return_status,
                                     p_id                         => p_art_var_tbl(i).cat_id,
                                     p_object_version_number      => l_dummy,
                                     p_lock_terms_yn              => p_lock_terms_yn
                                                 );

                     --------------------------------------------
                      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                          RAISE FND_API.G_EXC_ERROR ;
                      END IF;
                  --------------------------------------------
                 END IF;
             END IF;
       END LOOP;
    END IF;

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    /*IF (l_debug = 'Y') THEN
       okc_debug.log('200: Leaving update_article_variable', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
	    G_PKG_NAME, '200: Leaving update_article_variable' );
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('300: Leaving update_article_variable: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_EXCP_LEVEL,
             G_PKG_NAME, '300: Leaving update_article_variable: OKC_API.G_EXCEPTION_ERROR Exception' );
      END IF;

      IF l_doc_csr%ISOPEN THEN
         CLOSE l_doc_csr;
      END IF;

      ROLLBACK TO g_update_article_variable_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('400: Leaving update_article_variable: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_EXCP_LEVEL,
             G_PKG_NAME, '400: Leaving update_article_variable: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception' );
      END IF;

      IF l_doc_csr%ISOPEN THEN
         CLOSE l_doc_csr;
      END IF;

      ROLLBACK TO g_update_article_variable_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
        okc_debug.log('500: Leaving update_article_variable because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_EXCP_LEVEL,
             G_PKG_NAME, '500: Leaving update_article_variable because of EXCEPTION: '||sqlerrm );
      END IF;

      IF l_doc_csr%ISOPEN THEN
         CLOSE l_doc_csr;
      END IF;

      ROLLBACK TO g_update_article_variable_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  END update_article_variable;

PROCEDURE update_structure(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER ,
    p_validate_commit              IN VARCHAR2 ,
    p_validation_string            IN VARCHAR2,
    p_commit                       IN VARCHAR2 ,
    p_structure_tbl                IN structure_tbl_type,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2
    ) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'update_structure';
    l_doc_type                    VARCHAR2(30);
    l_doc_id                      NUMBER;

    CURSOR l_doc_art_csr(b_id NUMBER) IS
    SELECT DOCUMENT_TYPE,DOCUMENT_ID
    FROM OKC_K_ARTICLES_B
    WHERE id=b_id;

    CURSOR l_doc_scn_csr(b_id NUMBER) IS
    SELECT DOCUMENT_TYPE,DOCUMENT_ID
    FROM OKC_SECTIONS_B
    WHERE id=b_id;

  BEGIN

    /*IF (l_debug = 'Y') THEN
      okc_debug.log('100: Entered update_structure', 2);
      okc_debug.log('100: Parameter List ', 2);
      okc_debug.log('100: p_api_version : '||p_api_version, 2);
      okc_debug.log('100: p_init_msg_list : '||p_init_msg_list, 2);
      okc_debug.log('100: p_validation_level : '||p_validation_level, 2);
      okc_debug.log('100: p_validate_commit : '||p_validate_commit, 2);
      okc_debug.log('100: p_validation_string : '||p_validation_string, 2);
      okc_debug.log('100: p_commit : '||p_commit, 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
	    G_PKG_NAME, '100: Entered update_structure' );
        FND_LOG.STRING(G_PROC_LEVEL,
	    G_PKG_NAME, '100: Parameter List ' );
        FND_LOG.STRING(G_PROC_LEVEL,
	    G_PKG_NAME, '100: p_api_version : '||p_api_version );
        FND_LOG.STRING(G_PROC_LEVEL,
	    G_PKG_NAME, '100: p_init_msg_list : '||p_init_msg_list );
        FND_LOG.STRING(G_PROC_LEVEL,
	    G_PKG_NAME, '100: p_validation_level : '||p_validation_level );
        FND_LOG.STRING(G_PROC_LEVEL,
	    G_PKG_NAME, '100: p_validate_commit : '||p_validate_commit );
        FND_LOG.STRING(G_PROC_LEVEL,
	    G_PKG_NAME, '100: p_validation_string : '||p_validation_string );
        FND_LOG.STRING(G_PROC_LEVEL,
	    G_PKG_NAME, '100: p_commit : '||p_commit );
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_update_structure_GRP;
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

    IF p_structure_tbl.FIRST IS NOT NULL
      AND FND_API.To_Boolean( p_validate_commit ) THEN

      IF p_structure_tbl(1).type ='ARTICLE' THEN
           OPEN  l_doc_art_csr(p_structure_tbl(1).id);
           FETCH l_doc_art_csr INTO l_doc_type,l_doc_id;
           CLOSE l_doc_art_csr;
      END IF;

      IF p_structure_tbl(1).type ='SECTION' THEN
           OPEN  l_doc_scn_csr(p_structure_tbl(1).id);
           FETCH l_doc_scn_csr INTO l_doc_type,l_doc_id;
           CLOSE l_doc_scn_csr;
      END IF;

      IF  NOT FND_API.To_Boolean(OKC_TERMS_UTIL_GRP.ok_to_commit (
                                         p_api_version   => l_api_version,
                                         p_init_msg_list => FND_API.G_FALSE,
                                         p_doc_type      => l_doc_type,
                                         p_doc_id        => l_doc_id,
                                         x_return_status => x_return_status,
                                         x_msg_data      => x_msg_data,
                                         x_msg_count     => x_msg_count)                  ) THEN

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


    IF p_structure_tbl.FIRST IS NOT NULL THEN

       FOR i IN p_structure_tbl.FIRST..p_structure_tbl.LAST LOOP

             IF p_structure_tbl(i).type = 'SECTION' THEN

                   OKC_TERMS_SECTIONS_GRP.update_section(
                             p_api_version                => 1,
                             p_init_msg_list              => FND_API.G_FALSE,
                             x_msg_count                  => x_msg_count,
                             x_msg_data                   => x_msg_data,
                             p_validation_level           => 0,
                             x_return_status              => x_return_status,
                             p_id                         => p_structure_tbl(i).id,
                             p_section_sequence           => p_structure_tbl(i).display_sequence,
                             p_label                      => p_structure_tbl(i).label,
                             p_scn_id                     => p_structure_tbl(i).scn_id,
                             p_object_version_number      => p_structure_tbl(i).object_version_number
                                                      );

                   --------------------------------------------
                   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                   ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                     RAISE FND_API.G_EXC_ERROR ;
                   END IF;
                   --------------------------------------------

             END IF;

             IF p_structure_tbl(i).type = 'ARTICLE' THEN

                    OKC_K_ARTICLES_GRP.Update_article(
                                     p_api_version                => 1,
                                     p_init_msg_list              => FND_API.G_FALSE,
                                     p_validation_level           => 0,
                                     x_msg_count                  => x_msg_count,
                                     x_msg_data                   => x_msg_data,
                                     x_return_status              => x_return_status,
                                     p_id                         => p_structure_tbl(i).id,
                                     p_mandatory_yn               => p_structure_tbl(i).mandatory_yn,
                                     p_scn_id                     => p_structure_tbl(i).scn_id,
                                     p_label                      => p_structure_tbl(i).label,
                                     p_display_sequence           => p_structure_tbl(i).display_sequence,
                                     p_object_version_number      => p_structure_tbl(i).object_version_number
                                                 );

                    --------------------------------------------
                    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                      RAISE FND_API.G_EXC_ERROR ;
                    END IF;
                    --------------------------------------------
             END IF;
       END LOOP;

    END IF;
       -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    /*IF (l_debug = 'Y') THEN
       okc_debug.log('200: Leaving update_structure', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
	FND_LOG.STRING(G_PROC_LEVEL,
	    G_PKG_NAME, '200: Leaving update_structure' );
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('300: Leaving update_structure: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_EXCP_LEVEL,
	     G_PKG_NAME, '300: Leaving update_structure: OKC_API.G_EXCEPTION_ERROR Exception' );
      END IF;

      IF l_doc_art_csr%ISOPEN THEN
         CLOSE l_doc_art_csr;
      END IF;

      IF l_doc_scn_csr%ISOPEN THEN
         CLOSE l_doc_scn_csr;
      END IF;

      ROLLBACK TO g_update_structure_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('400: Leaving update_structure: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_EXCP_LEVEL,
	     G_PKG_NAME, '400: Leaving update_structure: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception' );
      END IF;

      IF l_doc_art_csr%ISOPEN THEN
         CLOSE l_doc_art_csr;
      END IF;

      IF l_doc_scn_csr%ISOPEN THEN
         CLOSE l_doc_scn_csr;
      END IF;

      ROLLBACK TO g_update_structure_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
        okc_debug.log('500: Leaving update_structure because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_EXCP_LEVEL,
	     G_PKG_NAME, '500: Leaving update_structure because of EXCEPTION: '||sqlerrm );
      END IF;

      IF l_doc_art_csr%ISOPEN THEN
         CLOSE l_doc_art_csr;
      END IF;

      IF l_doc_scn_csr%ISOPEN THEN
         CLOSE l_doc_scn_csr;
      END IF;

      ROLLBACK TO g_update_structure_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  END update_structure;

PROCEDURE sync_doc_with_expert(
    p_api_version            IN  NUMBER,
    p_init_msg_list          IN  VARCHAR2,
    p_validate_commit        IN  VARCHAR2,
    p_validation_string      IN VARCHAR2,
    p_commit                 IN  VARCHAR2,
    p_doc_type	             IN  VARCHAR2,
    p_doc_id	             IN  NUMBER,
    p_article_id_tbl	     IN  article_id_tbl_type,
    p_mode                   IN VARCHAR2 ,
    x_articles_dropped       OUT NOCOPY NUMBER,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2,
    p_lock_terms_yn                IN VARCHAR2
    ) IS

    l_api_version             CONSTANT NUMBER := 1;
    l_api_name                CONSTANT VARCHAR2(30) := 'sync_doc_with_expert';
    l_insert_tbl              article_id_tbl_type;
    l_dummy_var               VARCHAR2(1);
    l_article_id              NUMBER;
    l_ovn                     NUMBER;
    k                         NUMBER := 0;
    TYPE csrType  IS REF CURSOR;
    l_check_existing_csr      csrType;
    l_query                   VARCHAR2(3900);
    l_query1                   VARCHAR2(3900);
    l_query2                   VARCHAR2(3900);
    l_article_effective_date  DATE;
    l_scn_seq                 NUMBER;
    l_scn_id                  OKC_SECTIONS_B.ID%TYPE;
    l_art_id                  OKC_K_ARTICLES_B.ID%TYPE;
    l_art_seq                 NUMBER;
    l_articles_dropped        NUMBER :=0;
    l_max_sec_seq             NUMBER;

CURSOR l_check_presence_csr( b_article_id NUMBER) IS
 SELECT 'x' FROM
    OKC_K_ARTICLES_B KART
 WHERE document_type=p_doc_type
 AND   document_id=p_doc_id
 AND   source_flag='R'
 AND   orig_article_id = b_article_id
 AND nvl(KART.AMENDMENT_OPERATION_CODE,'?')<>'DELETED'
 AND nvl(KART.SUMMARY_AMEND_OPERATION_CODE,'?')<>'DELETED';

CURSOR l_get_effective_date_csr IS
   SELECT nvl(article_effective_date,sysdate)
   FROM OKC_TEMPLATE_USAGES
   WHERE DOCUMENT_TYPE  = p_doc_type
   AND   DOCUMENT_ID    = p_doc_id;

CURSOR l_get_active_article_csr(b_article_id NUMBER,b_article_effective_date DATE) IS
 SELECT vers.article_id article_id,
        vers.article_version_id article_version_id,
        nvl(vers.default_section,'UNASSIGNED') scn_code,
        nvl(PROVISION_YN,'N') provision_yn
 FROM OKC_ARTICLE_VERSIONS VERS
 WHERE vers.article_id = b_article_id
 AND    article_status in ('ON_HOLD','APPROVED')
 AND   b_article_effective_date >= vers.start_date
 AND   b_article_effective_date <= nvl(vers.end_date,b_article_effective_date+1);

CURSOR l_get_max_article_csr(b_article_id NUMBER) IS
SELECT article_id,
       article_version_id,
       nvl(vers.default_section,'UNASSIGNED') scn_code,
       nvl(PROVISION_YN,'N') provision_yn
FROM OKC_ARTICLE_VERSIONS VERS
WHERE  article_id= b_article_id
AND    article_status in ('ON_HOLD','APPROVED')
AND    start_date = (select max(start_date) FROM OKC_ARTICLE_VERSIONS
WHERE  article_id= b_article_id
AND    article_status in ('ON_HOLD','APPROVED') );

CURSOR l_get_scn_csr(b_scn_code VARCHAR2) IS
SELECT id FROM OKC_SECTIONS_B
WHERE document_type=p_doc_type
AND   document_id =p_doc_id
AND   scn_code     = b_scn_code
AND nvl(AMENDMENT_OPERATION_CODE,'?')<>'DELETED'
AND nvl(SUMMARY_AMEND_OPERATION_CODE,'?')<>'DELETED'
AND   rownum=1 ;

CURSOR l_get_section_seq_csr IS
SELECT nvl(max(section_sequence),0)+10 FROM OKC_SECTIONS_B
WHERE document_type = p_doc_type
AND   document_id   = p_doc_id
AND   NVL(scn_code,'XWY') <> 'UNASSIGNED'
AND   scn_id IS NULL;

CURSOR l_get_art_seq_csr(b_scn_id NUMBER) IS
SELECT nvl(max(display_sequence),0)+10 FROM OKC_K_ARTICLES_B
WHERE document_type=p_doc_type
AND   document_id =p_doc_id
AND   SCN_ID = b_scn_id;

--Bug#5160892 added below cursor
CURSOR l_get_sec_seq_csr(b_scn_id NUMBER) IS
SELECT nvl(max(section_sequence),0)+10 FROM OKC_SECTIONS_B
WHERE document_type=p_doc_type
AND   document_id =p_doc_id
AND   SCN_ID = b_scn_id;

CURSOR l_get_prov_csr IS
SELECT name,
       nvl(PROVISION_ALLOWED_YN,'Y')
FROM OKC_BUS_DOC_TYPES_V
WHERE  DOCUMENT_TYPE=p_doc_type;

CURSOR csr_mandatory_flag IS
SELECT NVL(t.xprt_clause_mandatory_flag,'N'),
       NVL(t.xprt_scn_code,'UNASSIGNED')
  FROM okc_template_usages u,
       okc_terms_templates_all t
 WHERE u.template_id = t.template_id
   AND u.document_type = p_doc_type
   AND u.document_id = p_doc_id ;
--CLM changes  start
CURSOR art_def_scn_csr(p_article_id NUMBER,p_article_version_id NUMBER) IS
SELECT 'x' FROM okc_art_var_sections
WHERE article_id = p_article_id
AND article_version_id = p_article_version_id
AND ROWNUM=1;
l_art_var_exists VARCHAR2(1) := 'N';
--CLM changes end


l_xprt_clause_mandatory_flag   okc_terms_templates_all.xprt_clause_mandatory_flag%TYPE;
l_xprt_scn_code                okc_terms_templates_all.xprt_scn_code%TYPE;

l_article_rec      l_get_active_article_csr%ROWTYPE;
l_max_article_rec  l_get_max_article_csr%ROWTYPE;
l_prov_allowed     VARCHAR2(1) ;
l_art_title        VARCHAR2(450);
l_bus_doc_name     VARCHAR2(450);
l_num_scheme_id    NUMBER:=0;
l_msg_data         VARCHAR2(4000);
l_msg_count        NUMBER;
l_renumber_flag    VARCHAR2(1) :='N';

CURSOR l_get_num_scheme_id IS
SELECT doc_numbering_scheme
FROM okc_template_usages
WHERE document_type = p_doc_type
  AND document_id = p_doc_id;

l_article_org_id  NUMBER;
l_current_org_id VARCHAR2(100);

CURSOR l_get_article_org_csr(b_article_id NUMBER) IS
SELECT org_id
FROM OKC_ARTICLES_ALL
WHERE article_id = b_article_id;

CURSOR l_get_local_article_csr(b_article_id IN NUMBER,
                               b_local_org_id IN NUMBER,
						 b_article_effective_date IN DATE) IS
SELECT VERS.ARTICLE_ID article_id,
       ADP.GLOBAL_ARTICLE_VERSION_ID article_version_id,
	  NVL(VERS.default_section,'UNASSIGNED') scn_code,
       NVL(VERS.PROVISION_YN,'N') provision_yn
FROM   OKC_ARTICLE_VERSIONS VERS,
       OKC_ARTICLE_ADOPTIONS  ADP
WHERE ADP.GLOBAL_ARTICLE_VERSION_ID = VERS.ARTICLE_VERSION_ID
AND   VERS.ARTICLE_ID         = b_article_id
AND   nvl(b_article_effective_date,sysdate) >=  VERS.START_DATE
AND   nvl(b_article_effective_date,sysdate) <= nvl(VERS.end_date, nvl(b_article_effective_date,sysdate) +1)
AND   VERS.ARTICLE_STATUS     IN ('ON_HOLD','APPROVED')
AND   ADP.ADOPTION_TYPE = 'ADOPTED'
AND   ADP.LOCAL_ORG_ID = b_local_org_id
AND   ADP.adoption_status IN ( 'APPROVED', 'ON_HOLD') ;

CURSOR l_get_max_local_article_csr(b_article_id IN NUMBER,
                                   b_local_org_id IN NUMBER) IS
SELECT VERS.ARTICLE_ID article_id,
       ADP.GLOBAL_ARTICLE_VERSION_ID article_version_id,
	  NVL(VERS.default_section,'UNASSIGNED') scn_code,
       NVL(VERS.PROVISION_YN,'N') provision_yn
FROM   OKC_ARTICLE_VERSIONS VERS,
       OKC_ARTICLE_ADOPTIONS  ADP
WHERE ADP.GLOBAL_ARTICLE_VERSION_ID = VERS.ARTICLE_VERSION_ID
AND   VERS.ARTICLE_ID         = b_article_id
AND   VERS.ARTICLE_STATUS     IN ('ON_HOLD','APPROVED')
AND   ADP.ADOPTION_TYPE = 'ADOPTED'
AND   ADP.LOCAL_ORG_ID = b_local_org_id
AND   ADP.adoption_status IN ( 'APPROVED', 'ON_HOLD')
ORDER BY ADP.creation_date desc;

l_local_article_rec l_get_local_article_csr%ROWTYPE;
l_max_local_article_rec l_get_max_local_article_csr%ROWTYPE;

CURSOR get_articles_order_art_num is
SELECT id,scn_id
FROM okc_k_articles_b,okc_articles_all
WHERE document_type=p_doc_type AND
document_id=p_doc_id AND
sav_sae_id=article_id
ORDER BY scn_id,article_number;

l_disp_seq NUMBER := 10;
l_section_id NUMBER := NULL;
l_order_by_column VARCHAR2(80);
l_hook_used NUMBER;

BEGIN

    /*IF (l_debug = 'Y') THEN
      okc_debug.log('100: Entered sync_doc_with_expert', 2);
      okc_debug.log('100: Parameter List ', 2);
      okc_debug.log('100: p_api_version : '||p_api_version, 2);
      okc_debug.log('100: p_init_msg_list : '||p_init_msg_list, 2);
      okc_debug.log('100: p_validate_commit : '||p_validate_commit, 2);
      okc_debug.log('100: p_validation_string : '||p_validation_string, 2);
      okc_debug.log('100: p_commit : '||p_commit, 2);
      okc_debug.log('100: p_doc_type : '||p_doc_type, 2);
      okc_debug.log('100: p_doc_id : '||p_doc_id, 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
	FND_LOG.STRING(G_PROC_LEVEL,
	    G_PKG_NAME, '100: Entered sync_doc_with_expert' );
	FND_LOG.STRING(G_PROC_LEVEL,
	    G_PKG_NAME, '100: Parameter List ' );
	FND_LOG.STRING(G_PROC_LEVEL,
	    G_PKG_NAME, '100: p_api_version : '||p_api_version );
	FND_LOG.STRING(G_PROC_LEVEL,
	    G_PKG_NAME, '100: p_init_msg_list : '||p_init_msg_list );
	FND_LOG.STRING(G_PROC_LEVEL,
	    G_PKG_NAME, '100: p_validate_commit : '||p_validate_commit );
	FND_LOG.STRING(G_PROC_LEVEL,
	    G_PKG_NAME, '100: p_validation_string : '||p_validation_string );
	FND_LOG.STRING(G_PROC_LEVEL,
	    G_PKG_NAME, '100: p_commit : '||p_commit );
	FND_LOG.STRING(G_PROC_LEVEL,
	    G_PKG_NAME, '100: p_doc_type : '||p_doc_type );
	FND_LOG.STRING(G_PROC_LEVEL,
	    G_PKG_NAME, '100: p_doc_id : '||p_doc_id );
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_sync_doc_with_expert_GRP;
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

    -- Begin: Added code for bug 5406515
    l_current_org_id := OKC_TERMS_UTIL_PVT.get_current_org_id(p_doc_type, p_doc_id);
    MO_GLOBAL.set_policy_context('S',l_current_org_id);
    -- End: Added code for bug 5406515

    IF FND_API.To_Boolean( p_validate_commit )
       AND NOT FND_API.To_Boolean(OKC_TERMS_UTIL_GRP.ok_to_commit (
                                         p_api_version   => l_api_version,
                                         p_init_msg_list => FND_API.G_FALSE,
                                         p_doc_type	 => p_doc_type,
                                         p_doc_id	 => p_doc_id,
                                         p_validation_string => p_validation_string,
                                         x_return_status => x_return_status,
                                         x_msg_data	 => x_msg_data,
                                         x_msg_count	 => x_msg_count)                  ) THEN

             /*IF (l_debug = 'Y') THEN
                okc_debug.log('200: Issue with document header Record.Cannot commit', 2);
             END IF;*/

	     IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
		FND_LOG.STRING(G_PROC_LEVEL,
		    G_PKG_NAME, '200: Issue with document header Record.Cannot commit' );
	     END IF;
             RAISE FND_API.G_EXC_ERROR ;
    END IF;

  OPEN  l_get_prov_csr;
  FETCH l_get_prov_csr into l_bus_doc_name, l_prov_allowed;
  CLOSE l_get_prov_csr;

  -- Check if the expert clauses would be mandatory or optional
   OPEN csr_mandatory_flag;
     FETCH csr_mandatory_flag INTO l_xprt_clause_mandatory_flag,l_xprt_scn_code;
   CLOSE csr_mandatory_flag;


  /*IF (l_debug = 'Y') THEN
     okc_Debug.Log('100: l_prov_allowed : '||l_prov_allowed,2);
     okc_Debug.Log('100: l_xprt_clause_mandatory_flag : '||l_xprt_clause_mandatory_flag,2);
  END IF;*/

  IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
     FND_LOG.STRING(G_PROC_LEVEL,
         G_PKG_NAME, '100: l_prov_allowed : '||l_prov_allowed );
     FND_LOG.STRING(G_PROC_LEVEL,
         G_PKG_NAME, '100: l_xprt_clause_mandatory_flag : '||l_xprt_clause_mandatory_flag );
  END IF;

   l_query1 := 'Select kart.id ,kart.object_version_number from okc_k_articles_b kart where document_type=:l_doc_type and document_id=:l_doc_id and source_flag=''R'' and orig_article_id not in (';

   k := 0;

   /*IF (l_debug = 'Y') THEN
       okc_debug.log('200: Article Count from Expert : '||p_article_id_tbl.COUNT,2);
   END IF;*/

   IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
       FND_LOG.STRING(G_PROC_LEVEL,
         G_PKG_NAME, '200: Article Count from Expert : '||p_article_id_tbl.COUNT );
   END IF;

   IF p_article_id_tbl.COUNT > 0 THEN
      FOR i IN p_article_id_tbl.FIRST..p_article_id_tbl.LAST LOOP

          -- Finding out article which was returned by Expert but
          -- is not present in document

          OPEN  l_check_presence_csr(p_article_id_tbl(i));
          FETCH l_check_presence_csr INTO l_dummy_var;
          IF l_check_presence_csr%NOTFOUND THEN
             l_insert_tbl(k):= p_article_id_tbl(i);
             k := k +1;
          END IF;
          CLOSE l_check_presence_csr;

          IF i=p_article_id_tbl.FIRST THEN
              l_query1 := l_query1||p_article_id_tbl(i);
          ELSE
              l_query1 := l_query1||','||p_article_id_tbl(i);
          END IF;

      END LOOP;
      l_query := l_query1||')';
   ELSE
      l_query := 'Select kart.id ,kart.object_version_number from okc_k_articles_b kart where document_type=:l_doc_type and document_id=:l_doc_id and source_flag=''R'' ';

   END IF;

   /*IF (l_debug = 'Y') THEN
           okc_debug.log('300: Query Is '||l_query);
   END IF;*/

   IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
       FND_LOG.STRING(G_PROC_LEVEL,
         G_PKG_NAME, '300: Query Is '||l_query );
   END IF;

-- Find out article which
   /*IF (l_debug = 'Y') THEN
           okc_debug.log('400: Going to delete Articles which came from expert last time but not present in expert this time');
   END IF;*/

   IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
       FND_LOG.STRING(G_PROC_LEVEL,
         G_PKG_NAME, '400: Going to delete Articles which came from expert last time but not present in expert this time' );
   END IF;

   OPEN l_check_existing_csr FOR l_query USING p_doc_type,p_doc_id;

   LOOP

     FETCH l_check_existing_csr INTO l_article_id,l_ovn;
     EXIT WHEN l_check_existing_csr%NOTFOUND;
     -- since we are deleting articles from expert, renumber
     l_renumber_flag :='Y';

     OKC_K_ARTICLES_GRP.delete_article(
                                 p_api_version           => l_api_version,
                                 p_init_msg_list         => FND_API.G_FALSE,
                                 p_validate_commit       => FND_API.G_FALSE,
                                 p_validation_string     => Null,
                                 p_commit                => FND_API.G_FALSE,
                                 p_mode                  => p_mode,
                                 p_id                    => l_article_id,
                                 p_object_version_number => l_ovn,
						   p_mandatory_clause_delete => 'Y',
                                 x_return_status         => x_return_status,
                                 x_msg_count             => x_msg_count,
                                 x_msg_data              => x_msg_data,
                                 p_lock_terms_yn         => p_lock_terms_yn
                                     );
     --------------------------------------------
     IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
     ELSIF (x_return_status = G_RET_STS_ERROR) THEN
       RAISE FND_API.G_EXC_ERROR ;
     END IF;
     --------------------------------------------

  END LOOP;

  CLOSE l_check_existing_csr;

  /*IF (l_debug = 'Y') THEN
          okc_debug.log('500: Articles Delete ',2);
          okc_debug.log('600: Going to insert new Articles retunred by expert',2);
          okc_debug.log('600: Inserting Articles : '||l_insert_tbl.COUNT,2);
  END IF;*/

  IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '500: Articles Delete ' );
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '600: Going to insert new Articles retunred by expert' );
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '600: Inserting Articles : '||l_insert_tbl.COUNT );
  END IF;

  IF l_insert_tbl.COUNT > 0 THEN

       OPEN  l_get_effective_date_csr;
       FETCH l_get_effective_date_csr INTO l_article_effective_date;

       IF l_get_effective_date_csr%NOTFOUND THEN
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       CLOSE l_get_effective_date_csr;

       FOR i IN l_insert_tbl.FIRST..l_insert_tbl.LAST LOOP

      	   -- bug 4162255
              -- check if Article is global or local
              OPEN l_get_article_org_csr(l_insert_tbl(i));
                FETCH l_get_article_org_csr INTO l_article_org_id;
              CLOSE l_get_article_org_csr;

              -- current Org Id
              -- fnd_profile.get('ORG_ID',l_current_org_id);
              l_current_org_id := OKC_TERMS_UTIL_PVT.get_current_org_id(p_doc_type, p_doc_id);

		IF nvl(l_current_org_id,'?') = l_article_org_id THEN

          -- Find out latest active version of article to be inserted
              OPEN  l_get_active_article_csr(l_insert_tbl(i),l_article_effective_date);
              FETCH l_get_active_article_csr INTO l_article_rec;

              IF l_get_active_article_csr%NOTFOUND THEN

             -- If no active version found then find out last active version.

                  OPEN  l_get_max_article_csr(l_insert_tbl(i));
                  FETCH l_get_max_article_csr INTO l_max_article_rec;

                  IF l_get_max_article_csr%NOTFOUND THEN
                      raise FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;

                  l_article_rec.article_id := l_max_article_rec.article_id;
                  l_article_rec.article_version_id := l_max_article_rec.article_version_id;
                  l_article_rec.scn_code := l_max_article_rec.scn_code;
                  l_article_rec.provision_yn := l_max_article_rec.provision_yn;
                  CLOSE l_get_max_article_csr;

              END IF;

              CLOSE l_get_active_article_csr;

		ELSE
		   --  Current Org Id and Article Org ID are different
		   -- This is a ADOPTED Article
		    OPEN l_get_local_article_csr(b_article_id => l_insert_tbl(i),
                               b_local_org_id => l_current_org_id,
						 b_article_effective_date => l_article_effective_date );
			 FETCH l_get_local_article_csr INTO l_local_article_rec;

		        IF l_get_local_article_csr%NOTFOUND THEN
			     -- get the Max Version of Approved Adopted Article
				OPEN l_get_max_local_article_csr(b_article_id => l_insert_tbl(i),
                               b_local_org_id => l_current_org_id );
				   FETCH l_get_max_local_article_csr INTO l_max_local_article_rec;

				   IF l_get_max_local_article_csr%NOTFOUND THEN
					CLOSE l_get_max_local_article_csr;
					CLOSE l_get_local_article_csr;
				     raise FND_API.G_EXC_UNEXPECTED_ERROR;
                       END IF;

                       l_article_rec.article_id := l_max_local_article_rec.article_id;
                       l_article_rec.article_version_id := l_max_local_article_rec.article_version_id;
                       l_article_rec.scn_code := l_max_local_article_rec.scn_code;
                       l_article_rec.provision_yn := l_max_local_article_rec.provision_yn;


				CLOSE l_get_max_local_article_csr;
		        ELSE
			      -- local article version found
                     l_article_rec.article_id := l_local_article_rec.article_id;
                     l_article_rec.article_version_id := l_local_article_rec.article_version_id;
                     l_article_rec.scn_code := l_local_article_rec.scn_code;
                     l_article_rec.provision_yn := l_local_article_rec.provision_yn;
			   END IF;

		    CLOSE l_get_local_article_csr;
		END IF; -- nvl(l_current_org_id,'?') = l_article_org_id

  -- check if the current article version is Provision and if provision
  -- is not allowed on the document, drop this article
     IF l_article_rec.provision_yn='Y' and l_prov_allowed='N' THEN
           l_articles_dropped := l_articles_dropped + 1;
         /*
           We are unable to display these messages on fnd message stack on structure pg
           So we will decide the number of articles dropped for now
           l_art_title := okc_terms_util_pvt.get_article_name
                                      (l_article_rec.article_id,
                                       l_article_rec.article_version_id);
           okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKC_PROV_ART_DROPPED',
                               p_token1       => 'ARTICLE_TITLE',
                               p_token1_value => l_art_title,
                               p_token2       => 'DOCUMENT_TYPE',
                               p_token2_value => l_bus_doc_name);
          */

     ELSE
        -- article is not provison or provision is allowed on document
        -- since we are inserting one or more articles, renumber
        -- we will renumber ONLY if article is Not added to unassigned section
	   /*
	     Added new column xprt_scn_code to okc_terms_templates_all
		If the article does not have a default scn_code in library then
		we will put the article in xprt_scn_code
		We always have to run renumber
	   */
         -- IF NVL(l_article_rec.scn_code,'UNASSIGNED') <> 'UNASSIGNED' THEN
--CLM changes start
 OPEN art_def_scn_csr(l_article_rec.article_id,l_article_rec.article_version_id);
 FETCH art_def_scn_csr INTO l_art_var_exists;
 CLOSE art_def_scn_csr;

 IF (l_art_var_exists = 'x') THEN
 OKC_CLM_PKG.get_default_scn_code (
 p_api_version        => p_api_version,
 p_init_msg_list      => p_init_msg_list,
 p_article_id         => l_article_rec.article_id,
 p_article_version_id => l_article_rec.article_version_id,
 p_doc_id             => p_doc_id,
 p_doc_type           => p_doc_type,
 x_default_scn_code   => l_article_rec.scn_code,
 x_return_status      => x_return_status
 ) ;

END IF;
 --CLM changes end

         IF NVL(l_article_rec.scn_code,'UNASSIGNED') = 'UNASSIGNED' THEN
	       l_article_rec.scn_code := l_xprt_scn_code;
            -- l_renumber_flag := 'Y';
         END IF;

		-- As the expert articles will always have a section, always run renumber
		-- if expert returns clauses
            l_renumber_flag := 'Y';

       --Find OUT IF section under which this article needs to be created exists

              OPEN l_get_scn_csr(l_article_rec.scn_code);
              FETCH l_get_scn_csr INTO l_scn_id;

              IF l_get_scn_csr%NOTFOUND THEN

              -- Section doesnt exists.It needs to be created

                  OPEN  l_get_section_seq_csr;
                  FETCH l_get_section_seq_csr INTO l_scn_seq;
                  CLOSE l_get_section_seq_csr;

                  /*IF (l_debug = 'Y') THEN
                        okc_debug.log('700: Going to create section '|| l_article_rec.scn_code);
                  END IF;*/

		  IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
			 FND_LOG.STRING(G_PROC_LEVEL,
		         G_PKG_NAME, '700: Going to create section '|| l_article_rec.scn_code );
		  END IF;

                  OKC_TERMS_SECTIONS_GRP.create_section(
                                        p_api_version        => l_api_version,
                                        p_init_msg_list      => FND_API.G_FALSE,
                                        p_commit             => FND_API.G_FALSE,
                                        x_return_status      => x_return_status,
                                        x_msg_count          => x_msg_count,
                                        x_msg_data           => x_msg_data,
                                        p_id                 => NULL,
                                        p_section_sequence   => l_scn_seq,
                                        p_scn_id             => NULL,
                                        p_heading            => OKC_UTIL.decode_lookup('OKC_ARTICLE_SECTION',l_article_rec.scn_code),
                                        p_description        => OKC_UTIL.decode_lookup('OKC_ARTICLE_SECTION',l_article_rec.scn_code),
                                        p_document_type      => p_doc_type,
                                        p_document_id        => p_doc_id,
                                        p_scn_code           => l_article_rec.scn_code,
                                        p_mode               => p_mode,
                                        x_id                 => l_scn_id
                                       );
                 --------------------------------------------
                 IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                 ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                           RAISE FND_API.G_EXC_ERROR ;
                 END IF;
                 --------------------------------------------
                  /*IF (l_debug = 'Y') THEN
                        okc_debug.log('800: section created');
                  END IF;*/

		  IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
			 FND_LOG.STRING(G_PROC_LEVEL,
		         G_PKG_NAME, '800: section created' );
		  END IF;

              END IF;
              CLOSE l_get_scn_csr;

             -- Creating the article
              OPEN  l_get_art_seq_csr(l_scn_id);
              FETCH l_get_art_seq_csr INTO l_art_seq;
              CLOSE l_get_art_seq_csr;

              --START:Bug#5160892 added below code
              OPEN  l_get_sec_seq_csr(l_scn_id);
              FETCH l_get_sec_seq_csr INTO l_max_sec_seq;
              CLOSE l_get_sec_seq_csr;

	        IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
	          FND_LOG.STRING(G_PROC_LEVEL,
	          G_PKG_NAME, '801: l_art_seq = '||l_art_seq);
	          FND_LOG.STRING(G_PROC_LEVEL,
	          G_PKG_NAME, '801: l_max_sec_seq = '||l_max_sec_seq);
              END IF;

              IF(l_max_sec_seq > l_art_seq) then
                    l_art_seq := l_max_sec_seq;
              END IF;
             --END:Bug#5160892

              OKC_K_ARTICLES_GRP.create_article(
                                        p_api_version        => l_api_version,
                                        p_init_msg_list      => FND_API.G_FALSE,
                                        p_commit             => FND_API.G_FALSE,
                                        x_return_status      => x_return_status,
                                        x_msg_count          => x_msg_count,
                                        x_msg_data           => x_msg_data,
                                        p_id                 => NULL,
                                        p_sav_sae_id         => l_article_rec.article_id,
                                        p_document_type      => p_doc_type,
                                        p_document_id        => p_doc_id,
                                        p_source_flag        => 'R',
                                        p_mandatory_yn       => l_xprt_clause_mandatory_flag,
                                        p_scn_id             => l_scn_id,
                                        p_article_version_id => l_article_rec.article_version_id,
                                        p_display_sequence   => l_art_seq,
                                        p_mode               => p_mode,
                                        x_id                 => l_art_id
                                              );
              --------------------------------------------
              IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
              ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                         RAISE FND_API.G_EXC_ERROR ;
              END IF;
              --------------------------------------------

          END IF; -- l_article_rec.provision_yn='Y' and l_prov_allowed='N'

       END LOOP;

  END IF; -- l_insert_tbl.COUNT > 0

  /*IF (l_debug = 'Y') THEN
          okc_debug.log('900: New Articles Inserted');
  END IF;*/

  IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
       FND_LOG.STRING(G_PROC_LEVEL,
	   G_PKG_NAME, '900: New Articles Inserted' );
  END IF;


  IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
       FND_LOG.STRING(G_PROC_LEVEL,
		   G_PKG_NAME, '950:Calling Code Hook to check if ordering by clause number has to be done');
  END IF;

  OKC_CODE_HOOK.GET_XPRT_CLAUSE_ORDER(
      x_return_status        => x_return_status,
      x_msg_count            => l_msg_count,
      x_msg_data             => l_msg_data,
      x_order_by_column      => l_order_by_column,
      x_hook_used            => l_hook_used
                                     );

  IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
       FND_LOG.STRING(G_PROC_LEVEL,
		   G_PKG_NAME, '975:Update the Clause Display Sequence if the code hook is being used');
  END IF;

  IF l_hook_used = 1 AND l_order_by_column='CLAUSE_NUMBER' THEN

    FOR articles_order_art_num IN  get_articles_order_art_num
    LOOP
      IF articles_order_art_num.scn_id = l_section_id THEN
        l_disp_seq := l_disp_seq + 10;
      ELSE
        l_disp_seq := 10;
        l_section_id:=articles_order_art_num.scn_id;
      END IF;
      OKC_K_ARTICLES_GRP.update_article(
            p_api_version          =>1,
            p_init_msg_list        => OKC_API.G_FALSE,
            x_return_status        => x_return_status,
            x_msg_count            => l_msg_count,
            x_msg_data             => l_msg_data,
            p_id                   => articles_order_art_num.id,
            p_display_sequence     => l_disp_seq,
            p_object_version_number => Null
                                 );
    END LOOP;
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    -------------------------------------------

END IF; -- l_hook_used = 1

  IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
       FND_LOG.STRING(G_PROC_LEVEL,
		   G_PKG_NAME, '980:Calling Code Hook to sync Rwa and Mandatory flags');
  END IF;

  IF  p_article_id_tbl.Count > 0 THEN
        OKC_CODE_HOOK.sync_rwa_with_document
          (p_api_version                => 1,
           p_init_msg_list              => FND_API.G_FALSE,
           p_doc_type                   => p_doc_type,
           p_doc_id                     => p_doc_id,
           p_article_id_tbl             => p_article_id_tbl,
           x_return_status              => x_return_status,
           x_msg_count                  => l_msg_count,
           x_msg_data                   => l_msg_data
          );
  END IF;

 -- call renumber automatically if any articles have been added or deleted
    IF NVL(l_renumber_flag,'N') = 'Y' THEN

      OPEN l_get_num_scheme_id;
         FETCH l_get_num_scheme_id INTO l_num_scheme_id;
      CLOSE l_get_num_scheme_id;

      /*IF (l_debug = 'Y') THEN
          okc_debug.log('150: l_num_scheme_id : '||l_num_scheme_id, 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	   FND_LOG.STRING(G_PROC_LEVEL,
	   	G_PKG_NAME, '150: l_num_scheme_id : '||l_num_scheme_id );
      END IF;

      IF NVL(l_num_scheme_id,0) <> 0 THEN

          /*IF (l_debug = 'Y') THEN
              okc_debug.log('150: Calling apply_numbering_scheme for num_scheme_id : '||l_num_scheme_id, 2);
          END IF;*/

	  IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
 	      FND_LOG.STRING(G_PROC_LEVEL,
	 	  G_PKG_NAME, '150: Calling apply_numbering_scheme for num_scheme_id : '||l_num_scheme_id );
	  END IF;

          OKC_NUMBER_SCHEME_GRP.apply_numbering_scheme(
           p_api_version        => p_api_version,
           p_init_msg_list      => FND_API.G_FALSE,
           x_return_status      => x_return_status,
           x_msg_count          => l_msg_count,
           x_msg_data           => l_msg_data,
           p_validate_commit    => p_validate_commit,
           p_validation_string  => p_validation_string,
           p_commit             => FND_API.G_FALSE,
           p_doc_type           => p_doc_type,
           p_doc_id             => p_doc_id,
           p_num_scheme_id      => l_num_scheme_id
         );

          /*IF (l_debug = 'Y') THEN
              okc_debug.log('150: After Calling apply_numbering_scheme ', 2);
              okc_debug.log('150: x_return_status : '||x_return_status, 2);
              okc_debug.log('150: x_msg_count  : '||l_msg_count, 2);
              okc_debug.log('150: x_msg_data : '||l_msg_data, 2);
          END IF;*/

	  IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
 	      FND_LOG.STRING(G_PROC_LEVEL,
	 	  G_PKG_NAME, '150: After Calling apply_numbering_scheme' );
 	      FND_LOG.STRING(G_PROC_LEVEL,
	 	  G_PKG_NAME, '150: x_return_status : '||x_return_status );
 	      FND_LOG.STRING(G_PROC_LEVEL,
	 	  G_PKG_NAME, '150: x_msg_count  : '||l_msg_count );
 	      FND_LOG.STRING(G_PROC_LEVEL,
	 	  G_PKG_NAME, '150: x_msg_data : '||l_msg_data );
	  END IF;

       END IF; --l_num_scheme_id is not 0
    END IF; -- call renumber automatically


 -- set the OUT parameter to indicate the number of provisional articles dropped
    x_articles_dropped := l_articles_dropped;

 -- Standard check of p_commit
  IF FND_API.To_Boolean( p_commit ) THEN
     COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  /*IF (l_debug = 'Y') THEN
      okc_debug.log('200: Leaving sync_doc_with_expert', 2);
  END IF;*/

  IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_PROC_LEVEL,
 	  G_PKG_NAME, '200: Leaving sync_doc_with_expert' );
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
   /*IF (l_debug = 'Y') THEN
      okc_debug.log('300: Leaving sync_doc_with_expert: OKC_API.G_EXCEPTION_ERROR Exception', 2);
   END IF;*/

   IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
       FND_LOG.STRING(G_EXCP_LEVEL,
           G_PKG_NAME, '300: Leaving sync_doc_with_expert: OKC_API.G_EXCEPTION_ERROR Exception' );
   END IF;

   IF l_get_max_local_article_csr%ISOPEN THEN
       CLOSE l_get_max_local_article_csr;
   END IF;

   IF l_get_local_article_csr%ISOPEN THEN
       CLOSE l_get_local_article_csr;
   END IF;

   IF l_get_max_article_csr%ISOPEN THEN
       CLOSE l_get_max_article_csr;
   END IF;

   IF l_get_active_article_csr%ISOPEN THEN
       CLOSE l_get_active_article_csr;
   END IF;

   IF l_get_effective_date_csr%ISOPEN THEN
       CLOSE l_get_effective_date_csr;
   END IF;

   IF l_get_active_article_csr%ISOPEN THEN
       CLOSE l_get_active_article_csr;
   END IF;

   IF l_check_presence_csr%ISOPEN THEN
       CLOSE l_check_presence_csr;
   END IF;

   IF l_get_max_article_csr%ISOPEN THEN
       CLOSE l_get_max_article_csr;
   END IF;

   IF l_get_max_article_csr%ISOPEN THEN
       CLOSE l_get_max_article_csr;
   END IF;

   IF l_get_section_seq_csr%ISOPEN THEN
       CLOSE l_get_section_seq_csr;
   END IF;

   IF l_get_art_seq_csr%ISOPEN THEN
       CLOSE l_get_art_seq_csr;
   END IF;

   ROLLBACK TO g_sync_doc_with_expert_GRP;
   x_return_status := G_RET_STS_ERROR ;
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   /*IF (l_debug = 'Y') THEN
       okc_debug.log('400: Leaving sync_doc_with_expert: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
   END IF;*/

   IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
       FND_LOG.STRING(G_EXCP_LEVEL,
           G_PKG_NAME, '400: Leaving sync_doc_with_expert: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception' );
   END IF;

   IF l_get_max_local_article_csr%ISOPEN THEN
       CLOSE l_get_max_local_article_csr;
   END IF;

   IF l_get_local_article_csr%ISOPEN THEN
       CLOSE l_get_local_article_csr;
   END IF;

   IF l_get_max_article_csr%ISOPEN THEN
       CLOSE l_get_max_article_csr;
   END IF;

   IF l_get_active_article_csr%ISOPEN THEN
       CLOSE l_get_active_article_csr;
   END IF;

   IF l_get_effective_date_csr%ISOPEN THEN
       CLOSE l_get_effective_date_csr;
   END IF;

   IF l_get_active_article_csr%ISOPEN THEN
       CLOSE l_get_active_article_csr;
   END IF;

   IF l_check_presence_csr%ISOPEN THEN
       CLOSE l_check_presence_csr;
   END IF;

   IF l_get_max_article_csr%ISOPEN THEN
       CLOSE l_get_max_article_csr;
   END IF;

   IF l_get_max_article_csr%ISOPEN THEN
       CLOSE l_get_max_article_csr;
   END IF;

   IF l_get_section_seq_csr%ISOPEN THEN
       CLOSE l_get_section_seq_csr;
   END IF;

   IF l_get_art_seq_csr%ISOPEN THEN
       CLOSE l_get_art_seq_csr;
   END IF;

   ROLLBACK TO g_sync_doc_with_expert_GRP;
   x_return_status := G_RET_STS_UNEXP_ERROR ;
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 WHEN OTHERS THEN
   /*IF (l_debug = 'Y') THEN
     okc_debug.log('500: Leaving sync_doc_with_expert because of EXCEPTION: '||sqlerrm, 2);
   END IF;*/

   IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
       FND_LOG.STRING(G_EXCP_LEVEL,
           G_PKG_NAME, '500: Leaving sync_doc_with_expert because of EXCEPTION: '||sqlerrm );
   END IF;

   IF l_get_max_local_article_csr%ISOPEN THEN
       CLOSE l_get_max_local_article_csr;
   END IF;

   IF l_get_local_article_csr%ISOPEN THEN
       CLOSE l_get_local_article_csr;
   END IF;

   IF l_get_max_article_csr%ISOPEN THEN
       CLOSE l_get_max_article_csr;
   END IF;

   IF l_get_active_article_csr%ISOPEN THEN
       CLOSE l_get_active_article_csr;
   END IF;

   IF l_get_effective_date_csr%ISOPEN THEN
       CLOSE l_get_effective_date_csr;
   END IF;

   IF l_get_active_article_csr%ISOPEN THEN
       CLOSE l_get_active_article_csr;
   END IF;

   IF l_check_presence_csr%ISOPEN THEN
       CLOSE l_check_presence_csr;
   END IF;

   IF l_get_max_article_csr%ISOPEN THEN
       CLOSE l_get_max_article_csr;
   END IF;

   IF l_get_max_article_csr%ISOPEN THEN
       CLOSE l_get_max_article_csr;
   END IF;

   IF l_get_section_seq_csr%ISOPEN THEN
       CLOSE l_get_section_seq_csr;
   END IF;

   IF l_get_art_seq_csr%ISOPEN THEN
       CLOSE l_get_art_seq_csr;
   END IF;

   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

   ROLLBACK TO g_sync_doc_with_expert_GRP;

   x_return_status := G_RET_STS_UNEXP_ERROR ;

   IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
   END IF;
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 END sync_doc_with_expert;

PROCEDURE refresh_articles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validate_commit              IN VARCHAR2,
    p_validation_string            IN VARCHAR2,
    p_commit                       IN VARCHAR2 ,
    p_mode                         IN VARCHAR2 ,
    p_doc_type                     IN VARCHAR2,
    p_doc_id                       IN NUMBER,
    p_article_tbl                  IN article_tbl_type,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lock_terms_yn                IN VARCHAR2
    )
IS

    l_api_version             CONSTANT NUMBER := 1;
    l_api_name                CONSTANT VARCHAR2(30) := 'refresh_articles';
    l_dummy                   VARCHAR2(1) := '?';

    l_article_id              NUMBER;

CURSOR l_check_version(b_article_version_id NUMBER) IS
SELECT article_id , 'x' FROM OKC_ARTICLE_VERSIONS
WHERE   article_version_id=b_article_version_id;

BEGIN

/*IF (l_debug = 'Y') THEN
      okc_debug.log('100: Entered refresh_articles', 2);
      okc_debug.log('100: Parameter List ', 2);
      okc_debug.log('100: p_api_version : '||p_api_version, 2);
      okc_debug.log('100: p_init_msg_list : '||p_init_msg_list, 2);
      okc_debug.log('100: p_mode : '||p_mode, 2);
      okc_debug.log('100: p_validate_commit : '||p_validate_commit, 2);
      okc_debug.log('100: p_validation_string : '||p_validation_string, 2);
      okc_debug.log('100: p_commit : '||p_commit, 2);
      okc_debug.log('100: p_doc_type : '||p_doc_type, 2);
      okc_debug.log('100: p_doc_id : '||p_doc_id, 2);
END IF;*/

IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: Entered refresh_articles' );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: Parameter List ' );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: p_api_version : '||p_api_version );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: p_init_msg_list : '||p_init_msg_list );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: p_mode : '||p_mode );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: p_validate_commit : '||p_validate_commit );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: p_validation_string : '||p_validation_string );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: p_commit : '||p_commit );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: p_doc_type : '||p_doc_type );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: p_doc_id : '||p_doc_id );
END IF;

-- Standard Start of API savepoint
SAVEPOINT g_refresh_articles_GRP;
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

IF FND_API.To_Boolean( p_validate_commit )
   AND NOT FND_API.To_Boolean(OKC_TERMS_UTIL_GRP.ok_to_commit (
                                        p_api_version   => l_api_version,
                                        p_init_msg_list => FND_API.G_FALSE,
                                        p_doc_type	 => p_doc_type,
                                        p_doc_id	 => p_doc_id,
                                        p_validation_string => p_validation_string,
                                        x_return_status => x_return_status,
                                        x_msg_data	 => x_msg_data,
                                        x_msg_count	 => x_msg_count)                  ) THEN

        /*IF (l_debug = 'Y') THEN
           okc_debug.log('200: Issue with document header Record.Cannot commit', 2);
        END IF;*/

	IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
 	   FND_LOG.STRING(G_PROC_LEVEL,
	       G_PKG_NAME, '200: Issue with document header Record.Cannot commit' );
	END IF;
        RAISE FND_API.G_EXC_ERROR ;
END IF;

FOR i IN p_article_tbl.FIRST..p_article_tbl.LAST LOOP

         l_dummy := '?';
         OPEN  l_check_version(p_article_tbl(i).article_version_id);
         FETCH l_check_version INTO l_article_id,l_dummy;
         CLOSE l_check_version;

         IF l_dummy <>'?' THEN
           OKC_K_ARTICLES_GRP.update_article(
                       p_api_version          =>1,
                       p_init_msg_list        => OKC_API.G_FALSE,
                       x_return_status        => x_return_status,
                       x_msg_count            => x_msg_count,
                       x_msg_data             => x_msg_data,
                       p_mode                 => p_mode,
                       p_id                   => p_article_tbl(i).cat_id,
                       p_sav_sae_id           => l_article_id,
                       p_article_version_id   => p_article_tbl(i).article_version_id,
                       p_object_version_number => p_article_tbl(i).ovn,
                       p_lock_terms_yn         => p_lock_terms_yn
                                                );
            --------------------------------------------
             IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
             ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                   RAISE FND_API.G_EXC_ERROR ;
             END IF;
           --------------------------------------------
      END IF;

END LOOP;

 -- Standard check of p_commit
IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
END IF;

-- Standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

/*IF (l_debug = 'Y') THEN
     okc_debug.log('200: Leaving refresh_articles', 2);
END IF;*/

IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
   FND_LOG.STRING(G_PROC_LEVEL,
       G_PKG_NAME, '200: Leaving refresh_articles' );
END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
   /*IF (l_debug = 'Y') THEN
       okc_debug.log('300: Leaving refresh_articles: OKC_API.G_EXCEPTION_ERROR Exception', 2);
   END IF;*/

   IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_EXCP_LEVEL,
          G_PKG_NAME, '300: Leaving refresh_articles: OKC_API.G_EXCEPTION_ERROR Exception' );
   END IF;

   IF l_check_version%ISOPEN THEN
      close l_check_version;
   END IF;

   ROLLBACK TO g_refresh_articles_GRP;
   x_return_status := G_RET_STS_ERROR ;
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   /*IF (l_debug = 'Y') THEN
      okc_debug.log('400: Leaving refresh_articles: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
   END IF;*/

   IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_EXCP_LEVEL,
          G_PKG_NAME, '400: Leaving refresh_articles: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception' );
   END IF;

   IF l_check_version%ISOPEN THEN
      close l_check_version;
   END IF;

   ROLLBACK TO g_refresh_articles_GRP;
   x_return_status := G_RET_STS_UNEXP_ERROR ;
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN OTHERS THEN
   /*IF (l_debug = 'Y') THEN
      okc_debug.log('500: Leaving refresh_articles because of EXCEPTION: '||sqlerrm, 2);
   END IF;*/

   IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_EXCP_LEVEL,
          G_PKG_NAME, '500: Leaving refresh_articles because of EXCEPTION: '||sqlerrm );
   END IF;

   IF l_check_version%ISOPEN THEN
      close l_check_version;
   END IF;


   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                       p_msg_name     => G_UNEXPECTED_ERROR,
                       p_token1       => G_SQLCODE_TOKEN,
                       p_token1_value => sqlcode,
                       p_token2       => G_SQLERRM_TOKEN,
                       p_token2_value => sqlerrm);

  ROLLBACK TO g_refresh_articles_GRP;

  x_return_status := G_RET_STS_UNEXP_ERROR ;

  IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
  END IF;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END refresh_articles;

PROCEDURE organize_layout(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_validate_commit              IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_string            IN VARCHAR2,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,
    p_organize_tbl                IN ORGANIZE_TBL_TYPE,
    p_ref_point                    IN VARCHAR2 := 'A',  -- Possible values
                                       -- 'A'=After,'B'=Before,'S' = Subsection
    p_doc_type                     IN VARCHAR2,
    p_doc_id                       IN NUMBER,
    p_to_object_type               IN VARCHAR2,
    p_to_object_id                 IN NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2
    ) IS

     l_api_version                 CONSTANT NUMBER := 1;
     l_api_name                    CONSTANT VARCHAR2(30) := 'organize_layout';
     l_organize_tbl                ORGANIZE_TBL_TYPE;
     l_scn_id                      NUMBER;
     l_parent_scn_id               NUMBER;
     l_ref_is_set                  BOOLEAN :=FALSE;
     l_not_deleted                 BOOLEAN;
     l_ref_sequence                NUMBER;
     l_ref_sequence1               NUMBER;
     j                             NUMBER := 0;
     l_ref_count                   NUMBER;
     l_dont_move                   Boolean;

 TYPE del_list_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
 l_del_list_tbl del_list_tbl_type;

 scn_child_tbl scn_child_tbl_type;

CURSOR l_get_max_seq_csr(b_scn_id NUMBER) is
SELECT nvl(max(SECTION_SEQUENCE),0) FROM OKC_SECTIONS_B
WHERE  document_type=p_doc_type
AND    document_id=p_doc_id
AND     ( (b_scn_id is Null and scn_id is Null)
                 OR
           (b_scn_id is Not Null and scn_id=b_scn_id)
         );


CURSOR l_get_max_art_seq_csr(b_scn_id NUMBER) is
SELECT nvl(max(display_SEQUENCE),0) FROM OKC_K_ARTICLES_B
WHERE  document_type=p_doc_type
AND    document_id=p_doc_id
and    b_scn_id is not null
and    scn_id=b_scn_id;

CURSOR l_get_scn_csr(b_cat_id NUMBER) IS
SELECT SCN_ID FROM OKC_K_ARTICLES_B WHERE Id=b_cat_id;

CURSOR l_get_parent_scn_csr(b_scn_id NUMBER) IS
SELECT SCN_ID FROM OKC_SECTIONS_B WHERE Id=b_scn_id;

CURSOR l_get_parents_csr(b_id NUMBER) IS
SELECT ID FROM OKC_SECTIONS_B
where id<>b_id
AND  document_type=p_doc_type
AND    document_id=p_doc_id
start with Id=b_id
connect by id=prior scn_id;


CURSOR l_get_scn_child(b_scn_id NUMBER) IS
SELECT ID,SECTION_SEQUENCE DISPLAY_SEQ,'SECTION' obj_type
FROM   OKC_SECTIONS_B
WHERE  document_type = p_doc_type
AND    document_id   = p_doc_id
AND    ( (b_scn_id is Null and scn_id is Null)
                 OR
           (b_scn_id is Not Null and scn_id=b_scn_id)
         )
UNION ALL
SELECT ID,DISPLAY_SEQUENCE DISPLAY_SEQ,'ARTICLE' obj_type
FROM   OKC_K_ARTICLES_B
WHERE  document_type = p_doc_type
AND    document_id   = p_doc_id
AND    scn_id=b_scn_id
ORDER  BY 2;

BEGIN

/*IF (l_debug = 'Y') THEN
      okc_debug.log('100: Entered organize_layout', 2);
      okc_debug.log('100: Parameter List ', 2);
      okc_debug.log('100: p_api_version : '||p_api_version, 2);
      okc_debug.log('100: p_init_msg_list : '||p_init_msg_list, 2);
      okc_debug.log('100: p_validate_commit : '||p_validate_commit, 2);
      okc_debug.log('100: p_validation_string : '||p_validation_string, 2);
      okc_debug.log('100: p_commit : '||p_commit, 2);
      okc_debug.log('100: p_ref_point : '||p_ref_point, 2);
      okc_debug.log('100: p_doc_type : '||p_doc_type, 2);
      okc_debug.log('100: p_doc_id : '||p_doc_id, 2);
      okc_debug.log('100: p_to_object_type : '||p_to_object_type, 2);
      okc_debug.log('100: p_to_object_id : '||p_to_object_id, 2);
END IF;*/

IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: Entered organize_layout' );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: Parameter List ' );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: p_api_version : '||p_api_version );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: p_init_msg_list : '||p_init_msg_list );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: p_validate_commit : '||p_validate_commit );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: p_validation_string : '||p_validation_string );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: p_commit : '||p_commit );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: p_ref_point : '||p_ref_point );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: p_doc_type : '||p_doc_type );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: p_doc_id : '||p_doc_id );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: p_to_object_type : '||p_to_object_type );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: p_to_object_id : '||p_to_object_id );
END IF;

-- Standard Start of API savepoint
SAVEPOINT g_organize_layout_GRP;
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

IF FND_API.To_Boolean( p_validate_commit )
   AND NOT FND_API.To_Boolean(OKC_TERMS_UTIL_GRP.ok_to_commit (
                                        p_api_version   => l_api_version,
                                        p_init_msg_list => FND_API.G_FALSE,
                                        p_doc_type	 => p_doc_type,
                                        p_doc_id	 => p_doc_id,
                                        p_validation_string => p_validation_string,
                                        x_return_status => x_return_status,
                                        x_msg_data	 => x_msg_data,
                                        x_msg_count	 => x_msg_count)                  ) THEN

        /*IF (l_debug = 'Y') THEN
           okc_debug.log('200: Issue with document header Record.Cannot commit', 2);
        END IF;*/

	IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
 	   FND_LOG.STRING(G_PROC_LEVEL,
	        G_PKG_NAME, '200: Issue with document header Record.Cannot commit' );
	END IF;
        RAISE FND_API.G_EXC_ERROR ;
END IF;

IF p_ref_point NOT IN ('A','B','S') THEN
        /*IF (l_debug = 'Y') THEN
           okc_debug.log('800: Error: Ref point should be either A,B or S', 2);
        END IF;*/

	IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
 	   FND_LOG.STRING(G_PROC_LEVEL,
	        G_PKG_NAME, '800: Error: Ref point should be either A,B or S' );
	END IF;

       Okc_Api.Set_Message( G_FND_APP, 'OKC_WRONG_REF_POINT');
       RAISE FND_API.G_EXC_ERROR ;

END IF;

IF p_to_object_type = p_doc_type AND p_ref_point <>'S' THEN
        /*IF (l_debug = 'Y') THEN
           okc_debug.log('300: Wrong Selection of Item Location', 2);
        END IF;*/

	IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
 	   FND_LOG.STRING(G_PROC_LEVEL,
	        G_PKG_NAME, '300: Wrong Selection of Item Location' );
	END IF;

         Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                             p_msg_name     => 'OKC_WRONG_ITEM_LOCATION'
                             );

        RAISE FND_API.G_EXC_ERROR ;
END IF;

IF p_to_object_type = 'ARTICLE' AND p_ref_point ='S' THEN
        /*IF (l_debug = 'Y') THEN
           okc_debug.log('400: Wrong Selection of Item Location', 2);
        END IF;*/

	IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
 	   FND_LOG.STRING(G_PROC_LEVEL,
	        G_PKG_NAME, '400: Wrong Selection of Item Location' );
	END IF;

         Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                             p_msg_name     => 'OKC_WRONG_ITEM_LOCATION1'
                             );

        RAISE FND_API.G_EXC_ERROR ;
END IF;

l_organize_tbl := p_organize_tbl;

IF p_organize_tbl.COUNT>0 THEN
   FOR i IN p_organize_tbl.FIRST..p_organize_tbl.LAST LOOP
        IF p_organize_tbl(i).object_type NOT in ('SECTION','ARTICLE') THEN
             /*IF (l_debug = 'Y') THEN
                 okc_debug.log('500: Wrong Selection ', 2);
             END IF;*/

	     IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
	         FND_LOG.STRING(G_PROC_LEVEL,
	             G_PKG_NAME, '500: Wrong Selection ' );
    	     END IF;

             Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKC_WRONG_SELECTION'
                                 );
             RAISE FND_API.G_EXC_ERROR ;
        END IF;
        -- Finding out those records whose parents are already in Table.
        -- These records will be deleted.If parents are moved there is no need to move children.
        IF p_organize_tbl(i).object_type='ARTICLE' THEN
            OPEN  l_get_scn_csr(p_organize_tbl(i).id);
            FETCH l_get_scn_csr INTO l_scn_id;
            CLOSE l_get_scn_csr;
            IF l_organize_tbl.COUNT >0 THEN
            FOR k in l_organize_tbl.FIRST..l_organize_tbl.LAST LOOP
                 IF l_organize_tbl(k).object_type='SECTION' and l_organize_tbl(k).id= l_scn_id THEN
                     l_del_list_tbl(l_del_list_tbl.count+1) := i;
                 END IF;
            END LOOP;
            END IF;
        ELSE
            l_scn_id := p_organize_tbl(i).id;
        END IF;

        FOR cr in l_get_parents_csr(l_scn_id) LOOP
            IF l_organize_tbl.COUNT >0 THEN
            FOR k in l_organize_tbl.FIRST..l_organize_tbl.LAST LOOP
                 IF l_organize_tbl(k).object_type='SECTION' and l_organize_tbl(k).id= cr.id THEN
                     l_del_list_tbl(l_del_list_tbl.count+1) := i;
                 END IF;
            END LOOP;
            END IF;
        END LOOP;

   END LOOP;
END IF;


IF p_to_object_type ='ARTICLE' THEN
  OPEN  l_get_scn_csr(p_to_object_id);
  FETCH l_get_scn_csr INTO l_parent_scn_id;
  CLOSE l_get_scn_csr;

ELSIF p_to_object_type ='SECTION' THEN
  OPEN l_get_parent_scn_csr(p_to_object_id);
  FETCH l_get_parent_scn_csr INTO l_parent_scn_id;
  CLOSE l_get_parent_scn_csr;

ELSIF p_to_object_type = p_doc_type THEN

   -- Case of Adding a section at TOP Level.

  OPEN  l_get_max_seq_csr(Null);
  FETCH l_get_max_seq_csr INTO l_ref_sequence;
  CLOSE l_get_max_seq_csr;
  l_ref_is_set  := TRUE;
  l_parent_scn_id := NULL;

ELSE
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
END IF;


IF NOT l_ref_is_set THEN

  IF p_ref_point IN ('A','B') THEN
    FOR cr IN l_get_scn_child(l_parent_scn_id) LOOP

      j := j+1;
      scn_child_tbl(j).id                    := cr.id;
      scn_child_tbl(j).display_sequence      := cr.display_seq;
      scn_child_tbl(j).object_type           := cr.obj_type;

      IF scn_child_tbl(j).object_type=p_to_object_type AND scn_child_tbl(j).id = p_to_object_id  THEN
          l_ref_count := j;
      END IF;

    END LOOP;

    IF p_ref_point ='B' THEN
       l_ref_count := l_ref_count -1 ;

       IF l_ref_count = 0 THEN
          l_ref_sequence := 0;
       ELSIF l_ref_count > 0 THEN
          l_ref_sequence :=  scn_child_tbl(l_ref_count).display_sequence;
       ELSE
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       END IF;
    ELSIF p_ref_point ='A' THEN
       IF l_ref_count > 0 THEN
          l_ref_sequence :=  scn_child_tbl(l_ref_count).display_sequence;
       ELSE
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       END IF;
    ELSE
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    l_ref_is_set := TRUE;

 ELSIF p_ref_point='S' THEN
    IF p_to_object_type ='SECTION' THEN

         l_parent_scn_id := p_to_object_id;
         OPEN  l_get_max_seq_csr(l_parent_scn_id );
         FETCH l_get_max_seq_csr INTO l_ref_sequence;
         CLOSE l_get_max_seq_csr;

         OPEN l_get_max_art_seq_csr(l_parent_scn_id );
         FETCH l_get_max_art_seq_csr INTO l_ref_sequence1;
         CLOSE l_get_max_art_seq_csr;

          IF l_ref_sequence1>l_ref_sequence THEN
              l_ref_sequence :=l_ref_sequence1;
          END IF;
         l_ref_is_set  := TRUE;

    ELSE
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
 ELSE
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
 END IF;

END IF;

IF p_organize_tbl.COUNT>0 THEN
   FOR i IN p_organize_tbl.FIRST..p_organize_tbl.LAST LOOP
         l_not_deleted := TRUE;
         IF l_del_list_tbl.COUNT > 0 THEN
              FOR k IN l_del_list_tbl.FIRST..l_del_list_tbl.LAST LOOP
                     IF i = l_del_list_tbl(k) THEN
                        l_not_deleted := FALSE;
                     END IF;
              END LOOP;
         END IF;

         IF l_not_deleted THEN
               IF p_organize_tbl(i).object_type='ARTICLE' THEN

                    /*IF (l_debug = 'Y') THEN
                       okc_debug.log('600: Updating Display Sequence of cat_id '||p_organize_tbl(i).id, 2);
                    END IF;*/

	     		IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
	       		   FND_LOG.STRING(G_PROC_LEVEL,
	          		   G_PKG_NAME, '600: Updating Display Sequence of cat_id '||p_organize_tbl(i).id );
	 	    END IF;

                    IF l_parent_scn_id IS NULL THEN
                          Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                                              p_msg_name     => 'OKC_ART_MOVE_TO_DOC'
                                              );
                          RAISE FND_API.G_EXC_ERROR ;
                     END IF;
                     l_ref_sequence := l_ref_sequence+10;

                     OKC_K_ARTICLES_GRP.update_article(
                               p_api_version          =>1,
                               p_init_msg_list        => OKC_API.G_FALSE,
                               x_return_status        => x_return_status,
                               x_msg_count            => x_msg_count,
                               x_msg_data             => x_msg_data,
                               p_id                   => p_organize_tbl(i).id,
                               p_scn_id               => l_parent_scn_id,
                               p_display_sequence     => l_ref_sequence,
                               p_object_version_number => Null
                                                );
                    --------------------------------------------
                    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                        RAISE FND_API.G_EXC_ERROR ;
                    END IF;
                    --------------------------------------------
                ELSIF p_organize_tbl(i).object_type='SECTION' THEN

                   /*IF (l_debug = 'Y') THEN
                       okc_debug.log('700: Updating Display Sequence of scn_id '||p_organize_tbl(i).id, 2);
                   END IF;*/

     		   IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
	       		   FND_LOG.STRING(G_PROC_LEVEL,
	          		   G_PKG_NAME, '700: Updating Display Sequence of scn_id '||p_organize_tbl(i).id );
	 	   END IF;

                   l_ref_sequence := l_ref_sequence+10;
                   OKC_TERMS_SECTIONS_GRP.update_section(
                         p_api_version          =>1,
                         p_init_msg_list        => OKC_API.G_FALSE,
                         x_return_status        => x_return_status,
                         x_msg_count            => x_msg_count,
                         x_msg_data             => x_msg_data,
                         p_id                   => p_organize_tbl(i).id,
                         p_scn_id               => nvl(l_parent_scn_id,OKC_API.G_MISS_NUM),
                         p_section_sequence     => l_ref_sequence,
                         p_object_version_number =>Null
                                                );
                   --------------------------------------------
                  IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                  ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR ;
                  END IF;

                END IF; -- IF p_organize_tbl(i).object_type='ARTICLE' THEN

         END IF;

   END LOOP;
END IF;


IF scn_child_tbl.COUNT > 0 THEN
       FOR k IN scn_child_tbl.FIRST..scn_child_tbl.LAST LOOP
           IF k > l_ref_count THEN

               l_dont_move := FALSE;
               For m IN p_organize_tbl.FIRST..p_organize_tbl.last LOOP
                   IF scn_child_tbl(k).id=p_organize_tbl(m).id and scn_child_tbl(k).object_type=p_organize_tbl(m).object_type THEN
                            l_dont_move := TRUE;
                            exit;
                    END IF;
               END LOOP;
               IF not l_dont_move THEN

                l_ref_sequence := l_ref_sequence + 10;
                IF scn_child_tbl(k).object_type='ARTICLE' THEN

                    /*IF (l_debug = 'Y') THEN
                       okc_debug.log('800: Updating Display Sequence of cat_id '||scn_child_tbl(k).id, 2);
                    END IF;*/

      		    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
	       		   FND_LOG.STRING(G_PROC_LEVEL,
	          		   G_PKG_NAME, '800: Updating Display Sequence of cat_id '||scn_child_tbl(k).id );
	 	    END IF;

                    OKC_K_ARTICLES_GRP.update_article(
                          p_api_version          =>1,
                          p_init_msg_list        => OKC_API.G_FALSE,
                          x_return_status        => x_return_status,
                          x_msg_count            => x_msg_count,
                          x_msg_data             => x_msg_data,
                          p_id                   => scn_child_tbl(k).id,
                          p_display_sequence     => l_ref_sequence,
                          p_object_version_number => Null
                                                );
                   --------------------------------------------
                  IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                  ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR ;
                  END IF;
                   --------------------------------------------
                ELSIF scn_child_tbl(k).object_type='SECTION' THEN

                   /*IF (l_debug = 'Y') THEN
                       okc_debug.log('900: Updating Display Sequence of scn_id '||scn_child_tbl(k).id, 2);
                   END IF;*/

      		   IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
	       		   FND_LOG.STRING(G_PROC_LEVEL,
	          		   G_PKG_NAME, '900: Updating Display Sequence of scn_id '||scn_child_tbl(k).id );
	 	   END IF;

                   OKC_TERMS_SECTIONS_GRP.update_section(
                         p_api_version          =>1,
                         p_init_msg_list        => OKC_API.G_FALSE,
                         x_return_status        => x_return_status,
                         x_msg_count            => x_msg_count,
                         x_msg_data             => x_msg_data,
                         p_id                   => scn_child_tbl(k).id,
                         p_section_sequence     => l_ref_sequence,
                         p_object_version_number =>Null
                                                );
                   --------------------------------------------
                  IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                  ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR ;
                  END IF;

                END IF; -- IF scn_child_tbl(k).object_type='ARTICLE' THEN
            END IF;
           END IF;
       END LOOP;
    END IF;

 -- Standard check of p_commit
IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
END IF;

-- Standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

/*IF (l_debug = 'Y') THEN
     okc_debug.log('1000: Leaving organize_layout', 2);
END IF;*/

IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    FND_LOG.STRING(G_PROC_LEVEL,
	G_PKG_NAME, '1000: Leaving organize_layout' );
END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
   /*IF (l_debug = 'Y') THEN
       okc_debug.log('1100: Leaving organize_layout: OKC_API.G_EXCEPTION_ERROR Exception', 2);
   END IF;*/

   IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
       FND_LOG.STRING(G_EXCP_LEVEL,
           G_PKG_NAME, '1100: Leaving organize_layout: OKC_API.G_EXCEPTION_ERROR Exception' );
   END IF;

   IF l_get_scn_child%ISOPEN THEN
      CLOSE l_get_scn_child;
   END IF;

   IF l_get_parents_csr%ISOPEN THEN
      CLOSE l_get_scn_child;
   END IF;

   IF l_get_parent_scn_csr%ISOPEN THEN
      CLOSE l_get_scn_child;
   END IF;

   IF l_get_scn_csr%ISOPEN THEN
      CLOSE l_get_scn_child;
   END IF;

   IF l_get_max_seq_csr%ISOPEN THEN
      CLOSE l_get_scn_child;
   ROLLBACK TO g_organize_layout_GRP;
   END IF;
   ROLLBACK TO g_organize_layout_GRP;
   x_return_status := G_RET_STS_ERROR ;
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   /*IF (l_debug = 'Y') THEN
      okc_debug.log('1200: Leaving organize_layout: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
   END IF;*/

   IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
       FND_LOG.STRING(G_EXCP_LEVEL,
           G_PKG_NAME, '1200: Leaving organize_layout: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception' );
   END IF;

   IF l_get_scn_child%ISOPEN THEN
      CLOSE l_get_scn_child;
   END IF;

   IF l_get_parents_csr%ISOPEN THEN
      CLOSE l_get_scn_child;
   END IF;

   IF l_get_parent_scn_csr%ISOPEN THEN
      CLOSE l_get_scn_child;
   END IF;

   IF l_get_scn_csr%ISOPEN THEN
      CLOSE l_get_scn_child;
   END IF;

   IF l_get_max_seq_csr%ISOPEN THEN
      CLOSE l_get_scn_child;
   ROLLBACK TO g_organize_layout_GRP;
   END IF;

   x_return_status := G_RET_STS_UNEXP_ERROR ;
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN OTHERS THEN
   /*IF (l_debug = 'Y') THEN
      okc_debug.log('1300: Leaving organize_layout because of EXCEPTION: '||sqlerrm, 2);
   END IF;*/

   IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
       FND_LOG.STRING(G_EXCP_LEVEL,
           G_PKG_NAME, '1300: Leaving organize_layout because of EXCEPTION: '||sqlerrm );
   END IF;

   IF l_get_scn_child%ISOPEN THEN
      CLOSE l_get_scn_child;
   END IF;

   IF l_get_parents_csr%ISOPEN THEN
      CLOSE l_get_scn_child;
   END IF;

   IF l_get_parent_scn_csr%ISOPEN THEN
      CLOSE l_get_scn_child;
   END IF;

   IF l_get_scn_csr%ISOPEN THEN
      CLOSE l_get_scn_child;
   END IF;

   IF l_get_max_seq_csr%ISOPEN THEN
      CLOSE l_get_scn_child;
   END IF;

   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                       p_msg_name     => G_UNEXPECTED_ERROR,
                       p_token1       => G_SQLCODE_TOKEN,
                       p_token1_value => sqlcode,
                       p_token2       => G_SQLERRM_TOKEN,
                       p_token2_value => sqlerrm);

  ROLLBACK TO g_organize_layout_GRP;

  x_return_status := G_RET_STS_UNEXP_ERROR ;

  IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
  END IF;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
 END organize_layout;




PROCEDURE merge_review_clauses(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_validate_commit              IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_string            IN VARCHAR2,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,
    p_merge_review_tbl             IN MERGE_REVIEW_TBL_TYPE,
    p_doc_type                     IN  VARCHAR2,
    p_doc_id                       IN  NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2
    ) IS

     l_api_version                 CONSTANT NUMBER := 1;
     l_api_name                    CONSTANT VARCHAR2(30) := 'merge_review_clauses';
     l_merge_review_tbl            MERGE_REVIEW_TBL_TYPE;
     l_scn_id                      NUMBER;
     l_parent_scn_id               NUMBER;
     l_ref_is_set                  BOOLEAN :=FALSE;
     l_not_deleted                 BOOLEAN;
     l_ref_sequence                NUMBER;
     l_ref_sequence1               NUMBER;
     j                             NUMBER := 0;
     l_ref_count                   NUMBER;
     l_dont_move                   Boolean;
     l_article_ibr                 VARCHAR2(1);
     l_article_mandatory           VARCHAR2(1);
     l_article_text_locked         VARCHAR2(1);
     l_final_article_text          OKC_REVIEW_UPLD_TERMS.OBJECT_TEXT%TYPE;
     l_temp_article_text           OKC_REVIEW_UPLD_TERMS.OBJECT_TEXT%TYPE;
     l_doc_num_scheme              NUMBER;
     l_user_access VARCHAR2(30);
     l_new_action                  OKC_REVIEW_UPLD_TERMS.ACTION%TYPE := 'UPDATED';
     l_temp_action                  OKC_REVIEW_UPLD_TERMS.ACTION%TYPE;
     l_final_err_msg_count         OKC_REVIEW_UPLD_TERMS.ERROR_MESSAGE_COUNT%TYPE := 0;
     l_temp_err_msg_count           OKC_REVIEW_UPLD_TERMS.ERROR_MESSAGE_COUNT%TYPE := 0;
     l_final_wrn_msg_count         OKC_REVIEW_UPLD_TERMS.WARNING_MESSAGE_COUNT%TYPE := 0;
     l_temp_wrn_msg_count           OKC_REVIEW_UPLD_TERMS.WARNING_MESSAGE_COUNT%TYPE := 0;

CURSOR l_get_article_text_csr(b_review_upld_terms_id NUMBER) is
SELECT object_text,
       action,
       NVL(error_message_count,0) error_message_count,
       NVL(warning_message_count,0) warning_message_count
FROM   okc_review_upld_terms
WHERE  review_upld_terms_id = b_review_upld_terms_id;

--As part of fix for bug# 4779506, added this cursor replacing the previously used cursors
CURSOR article_properties(b_review_upld_terms_id NUMBER) is
SELECT av.insert_by_reference,
       akb.mandatory_yn,
	  av.lock_text
FROM   okc_article_versions av, okc_review_upld_terms ar, okc_k_articles_b akb
WHERE  av.article_version_id = ar.article_version_id
AND    akb.id = ar.object_id
AND    ar.review_upld_terms_id = b_review_upld_terms_id;

CURSOR current_num_scheme is
SELECT doc_numbering_scheme from okc_template_usages
WHERE  document_type = p_doc_type
AND    document_id = p_doc_id;


BEGIN

IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: Entered merge_review_clauses' );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: Parameter List ' );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: p_api_version : '||p_api_version );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: p_init_msg_list : '||p_init_msg_list );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: p_validate_commit : '||p_validate_commit );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: p_validation_string : '||p_validation_string );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: p_commit : '||p_commit );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: p_doc_type : '||p_doc_type );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: p_doc_id : '||p_doc_id );
END IF;

-- Standard Start of API savepoint
SAVEPOINT g_merge_review_clauses_GRP;
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

IF FND_FUNCTION.TEST('OKC_TERMS_AUTHOR_STD','N') THEN
      l_user_access := 'STD_AUTHOR';
      IF FND_FUNCTION.TEST('OKC_TERMS_AUTHOR_NON_STD','N') THEN
	    l_user_access := 'NON_STD_AUTHOR';
	    IF FND_FUNCTION.TEST('OKC_TERMS_AUTHOR_SUPERUSER','N') THEN
	       l_user_access := 'SUPER_USER';
	    END IF;
	 END IF;
ELSE
     l_user_access := 'NO_ACCESS';
END IF;

IF FND_API.To_Boolean( p_validate_commit )
   AND NOT FND_API.To_Boolean(OKC_TERMS_UTIL_GRP.ok_to_commit (
                                        p_api_version   => l_api_version,
                                        p_init_msg_list => FND_API.G_FALSE,
                                        p_doc_type	 => p_doc_type,
                                        p_doc_id	 => p_doc_id,
                                        p_validation_string => p_validation_string,
                                        x_return_status => x_return_status,
                                        x_msg_data	 => x_msg_data,
                                        x_msg_count	 => x_msg_count)                  ) THEN


	IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
 	   FND_LOG.STRING(G_PROC_LEVEL,
  	       G_PKG_NAME, '200: Issue with document header Record.Cannot commit' );
	END IF;
        RAISE FND_API.G_EXC_ERROR ;
END IF;

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    Process the records to update the first clause text with the clause text
    of the rest of the clauses.
    Check is made for clause not being IBR, lock_text, mandatory
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*/
IF p_merge_review_tbl.COUNT>0 THEN
    OPEN  l_get_article_text_csr(p_merge_review_tbl(1).review_upld_terms_id);
    FETCH l_get_article_text_csr INTO
               l_final_article_text,
               l_new_action,
               l_final_err_msg_count,
               l_final_wrn_msg_count;
    CLOSE l_get_article_text_csr;


    l_article_ibr := 'N';
    l_article_mandatory := 'N';
    l_article_text_locked := 'N';
    IF p_merge_review_tbl(1).object_type <> 'ARTICLE' THEN

	     IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
 	        FND_LOG.STRING(G_PROC_LEVEL,
  	            G_PKG_NAME, '500: Wrong Selection ' );
	     END IF;
          Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKC_WRONG_SELECTION'
                                 );
          RAISE FND_API.G_EXC_ERROR ;
    END IF;

    OPEN  article_properties(p_merge_review_tbl(1).review_upld_terms_id);
    FETCH article_properties INTO
          l_article_ibr,
		l_article_mandatory,
		l_article_text_locked;
    CLOSE article_properties;

    IF l_article_ibr = 'Y' and (l_user_access <> 'SUPER_USER') THEN

	 IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
 	        FND_LOG.STRING(G_PROC_LEVEL,
  	        G_PKG_NAME, '500: Article is IBR enabled ' );
	 END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKC_ARTICLE_IS_IBR'
                                 );
      RAISE FND_API.G_EXC_ERROR ;
    END IF;

    IF l_article_text_locked = 'Y' AND (l_user_access <> 'SUPER_USER') THEN

	 IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
 	        FND_LOG.STRING(G_PROC_LEVEL,
  	        G_PKG_NAME, '500: Article is Text Locked ' );
	 END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKC_ARTICLE_IS_LOCK_TEXT');
      RAISE FND_API.G_EXC_ERROR ;
    END IF;

    FOR i IN 2 ..p_merge_review_tbl.LAST LOOP
        l_article_ibr := 'N';
        l_article_mandatory := 'N';
        l_article_text_locked := 'N';
        IF p_merge_review_tbl(i).object_type <> 'ARTICLE' THEN

	     IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
 	        FND_LOG.STRING(G_PROC_LEVEL,
  	        G_PKG_NAME, '500: Wrong Selection ' );
	     END IF;
          Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKC_WRONG_SELECTION');
          RAISE FND_API.G_EXC_ERROR ;
        END IF;
	   OPEN article_properties(p_merge_review_tbl(i).review_upld_terms_id);
	   FETCH article_properties into l_article_ibr, l_article_mandatory, l_article_text_locked;
        CLOSE article_properties;

        -- Fix for bug# 4779506. Changed check to NOT and changed parameter for fnd_function.test
        IF l_article_mandatory = 'Y'  AND (l_user_access <> 'SUPER_USER') THEN

	     IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
 	        FND_LOG.STRING(G_PROC_LEVEL,
  	        G_PKG_NAME, '500: Article is Mandatory ' );
	     END IF;
             Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKC_REVIEW_MERGE_MANDATORY'
                                 );
             RAISE FND_API.G_EXC_ERROR ;
        END IF;

        IF p_merge_review_tbl(i).object_type='ARTICLE' THEN
            OPEN  l_get_article_text_csr(p_merge_review_tbl(i).review_upld_terms_id);
            FETCH l_get_article_text_csr INTO
                  l_temp_article_text,
                  l_temp_action,
                  l_temp_err_msg_count,
                  l_temp_wrn_msg_count;
            CLOSE l_get_article_text_csr;
	     IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
               FND_LOG.STRING(G_PROC_LEVEL,
               G_PKG_NAME, '500: l_temp_action : '||l_temp_action );
               FND_LOG.STRING(G_PROC_LEVEL,
               G_PKG_NAME, '500: l_temp_err_msg_count : '||l_temp_err_msg_count);
               FND_LOG.STRING(G_PROC_LEVEL,
               G_PKG_NAME, '500: l_temp_wrn_msg_count : '||l_temp_wrn_msg_count);
	     END IF;
            l_final_article_text := l_final_article_text || l_temp_article_text;
            l_final_err_msg_count := l_final_err_msg_count + l_temp_err_msg_count;
            l_final_wrn_msg_count := l_final_wrn_msg_count + l_temp_wrn_msg_count;

        END IF;

      /**********************************************************************
	   Update the records being merged with ACTION=MERGED (Soft Delete)
	 ***********************************************************************/
       -- Added for Bug 5339759
	   UPDATE okc_review_upld_terms
	   SET
	   old_review_upld_terms_id = review_upld_terms_id
	   WHERE review_upld_terms_id = p_merge_review_tbl(i).review_upld_terms_id;

        OKC_REVIEW_UPLD_TERMS_PVT.update_row(
        x_return_status         => x_return_status,
        p_review_upld_terms_id  => p_merge_review_tbl(i).review_upld_terms_id,
        p_action                => 'MERGED',
        p_object_version_number => p_merge_review_tbl(i).object_version_number,
        p_new_parent_id         => G_MISS_NUM
         );
        ----------------------------------------------------------------------
             IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
             ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR ;
             END IF;
        ----------------------------------------------------------------------

       -- Added for Bug 5339759
	   UPDATE okc_review_var_values
	   SET
	   old_review_upld_terms_id = review_upld_terms_id,
	   review_upld_terms_id = p_merge_review_tbl(1).review_upld_terms_id
	   WHERE review_upld_terms_id = p_merge_review_tbl(i).review_upld_terms_id;
   END LOOP;

  /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
   Update the OKC_REVIEW_UPLD_TERMS table for the first clause
  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
   -- Added for bug# 4897442

    IF(l_new_action = 'ADDED') THEN
        l_new_action := 'ADDED';
    ELSE
        l_new_action := 'UPDATED';
    END IF;


        IF l_final_err_msg_count <= 0 THEN
	   l_final_err_msg_count := G_MISS_NUM;
        END IF;
        IF l_final_wrn_msg_count <= 0 THEN
	   l_final_wrn_msg_count := G_MISS_NUM;
        END IF;

	     IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
               FND_LOG.STRING(G_PROC_LEVEL,
               G_PKG_NAME, '500: l_new_action : '||l_new_action );
               FND_LOG.STRING(G_PROC_LEVEL,
               G_PKG_NAME, '500: l_final_err_msg_count : '||l_final_err_msg_count);
               FND_LOG.STRING(G_PROC_LEVEL,
               G_PKG_NAME, '500: l_final_wrn_msg_count : '||l_final_wrn_msg_count);
	     END IF;

        OKC_REVIEW_UPLD_TERMS_PVT.update_row(
        x_return_status => x_return_status,
        p_review_upld_terms_id  => p_merge_review_tbl(1).review_upld_terms_id,
	   p_action                => l_new_action,
        p_object_text           => l_final_article_text,
        p_object_version_number => NULL,
        p_error_message_count   => l_final_err_msg_count,
        p_warning_message_count => l_final_wrn_msg_count );
        ----------------------------------------------------------------------
             IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
             ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                  RAISE FND_API.G_EXC_ERROR ;
             END IF;
        ----------------------------------------------------------------------


  OPEN current_num_scheme;
  FETCH current_num_scheme into l_doc_num_scheme;
  CLOSE current_num_scheme;

  IF (l_doc_num_scheme is NOT NULL) then
      OKC_NUMBER_SCHEME_GRP.apply_num_scheme_4_review(
      p_api_version => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      p_commit => p_commit,
      p_validation_string => p_validation_string,
      p_doc_type => p_doc_type,
      p_doc_id => p_doc_id,
      p_num_scheme_id => l_doc_num_scheme);
  END IF;

END IF; -- IF p_merge_review_tbl.COUNT>0

 -- Standard check of p_commit
IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
END IF;

-- Standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );


IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '1000: Leaving merge_review_clauses' );
END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

   IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_EXCP_LEVEL,
          G_PKG_NAME, '1100: Leaving merge_review_clauses: OKC_API.G_EXCEPTION_ERROR Exception' );
   END IF;

   IF article_properties%ISOPEN THEN
      CLOSE article_properties;
   END IF;



   ROLLBACK TO g_merge_review_clauses_GRP;
   x_return_status := G_RET_STS_ERROR ;
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

   IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_EXCP_LEVEL,
          G_PKG_NAME, '1200: Leaving organize_layout: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception' );
   END IF;

   IF article_properties%ISOPEN THEN
      CLOSE article_properties;
   END IF;


   ROLLBACK TO g_merge_review_clauses_GRP;

   x_return_status := G_RET_STS_UNEXP_ERROR ;
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN OTHERS THEN
   IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_EXCP_LEVEL,
          G_PKG_NAME, '1300: Leaving organize_layout because of EXCEPTION: '||sqlerrm );
   END IF;

   IF article_properties%ISOPEN THEN
      CLOSE article_properties;
   END IF;

   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                       p_msg_name     => G_UNEXPECTED_ERROR,
                       p_token1       => G_SQLCODE_TOKEN,
                       p_token1_value => sqlcode,
                       p_token2       => G_SQLERRM_TOKEN,
                       p_token2_value => sqlerrm);

  ROLLBACK TO g_merge_review_clauses_GRP;

  x_return_status := G_RET_STS_UNEXP_ERROR ;

  IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
  END IF;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
 END merge_review_clauses;


PROCEDURE sort_clauses(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_validate_commit              IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_string            IN VARCHAR2,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,
    p_doc_type                     IN  VARCHAR2,
    p_doc_id                       IN  NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2
    ) IS

     l_api_version                 CONSTANT NUMBER := 1;
     l_api_name                    CONSTANT VARCHAR2(30) := 'sort_clauses';

CURSOR l_get_num_scheme_id IS
SELECT doc_numbering_scheme
FROM okc_template_usages
WHERE document_type = p_doc_type
  AND document_id = p_doc_id;


l_disp_seq NUMBER := 10;
l_section_id NUMBER := NULL;
l_renumber_flag    VARCHAR2(1) :='Y';
l_num_scheme_id    NUMBER:=0;
cont_art_tbl OKC_CODE_HOOK.cont_art_sort_tbl;



BEGIN

IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: Entered sort_clauses' );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: Parameter List ' );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: p_api_version : '||p_api_version );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: p_init_msg_list : '||p_init_msg_list );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: p_validate_commit : '||p_validate_commit );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: p_validation_string : '||p_validation_string );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: p_commit : '||p_commit );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: p_doc_type : '||p_doc_type );
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: p_doc_id : '||p_doc_id );
END IF;

-- Standard Start of API savepoint
SAVEPOINT g_sort_clauses_GRP;
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

IF FND_API.To_Boolean( p_validate_commit )
   AND NOT FND_API.To_Boolean(OKC_TERMS_UTIL_GRP.ok_to_commit (
                                        p_api_version   => l_api_version,
                                        p_init_msg_list => FND_API.G_FALSE,
                                        p_doc_type	 => p_doc_type,
                                        p_doc_id	 => p_doc_id,
                                        p_validation_string => p_validation_string,
                                        x_return_status => x_return_status,
                                        x_msg_data	 => x_msg_data,
                                        x_msg_count	 => x_msg_count)                  ) THEN

        /*IF (l_debug = 'Y') THEN
           okc_debug.log('200: Issue with document header Record.Cannot commit', 2);
        END IF;*/

	IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
 	   FND_LOG.STRING(G_PROC_LEVEL,
	        G_PKG_NAME, '200: Issue with document header Record.Cannot commit' );
	END IF;
        RAISE FND_API.G_EXC_ERROR ;
END IF;

    OKC_CODE_HOOK.sort_clauses(p_doc_type => p_doc_type,
                               p_doc_id => p_doc_id,
                               x_return_status => x_return_status,
                               x_msg_count => x_msg_count,
                               x_msg_data => x_msg_data,
                               x_cont_art_tbl => cont_art_tbl);



    FOR i IN cont_art_tbl.first..cont_art_tbl.last
    LOOP
      IF cont_art_tbl(i).scn_id = l_section_id THEN
        l_disp_seq := l_disp_seq + 10;
      ELSE
        l_disp_seq := 10;
        l_section_id:=cont_art_tbl(i).scn_id;
      END IF;
      OKC_K_ARTICLES_GRP.update_article(
            p_api_version          =>1,
            p_init_msg_list        => OKC_API.G_FALSE,
            x_return_status        => x_return_status,
            x_msg_count            => x_msg_count,
            x_msg_data             => x_msg_data,
            p_id                   => cont_art_tbl(i).id,
            p_display_sequence     => l_disp_seq,
            p_object_version_number => Null
                                 );
    END LOOP;
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    -------------------------------------------


    IF NVL(l_renumber_flag,'N') = 'Y' THEN

      OPEN l_get_num_scheme_id;
         FETCH l_get_num_scheme_id INTO l_num_scheme_id;
      CLOSE l_get_num_scheme_id;

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	   FND_LOG.STRING(G_PROC_LEVEL,
	   	G_PKG_NAME, '150: l_num_scheme_id : '||l_num_scheme_id );
      END IF;

      IF NVL(l_num_scheme_id,0) <> 0 THEN


	  IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
 	      FND_LOG.STRING(G_PROC_LEVEL,
	 	  G_PKG_NAME, '150: Calling apply_numbering_scheme for num_scheme_id : '||l_num_scheme_id );
	  END IF;

          OKC_NUMBER_SCHEME_GRP.apply_numbering_scheme(
           p_api_version        => p_api_version,
           p_init_msg_list      => FND_API.G_FALSE,
           x_return_status      => x_return_status,
           x_msg_count          => x_msg_count,
           x_msg_data           => x_msg_data,
           p_validate_commit    => p_validate_commit,
           p_validation_string  => p_validation_string,
           p_commit             => FND_API.G_FALSE,
           p_doc_type           => p_doc_type,
           p_doc_id             => p_doc_id,
           p_num_scheme_id      => l_num_scheme_id
         );


	  IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
 	      FND_LOG.STRING(G_PROC_LEVEL,
	 	  G_PKG_NAME, '150: After Calling apply_numbering_scheme' );
 	      FND_LOG.STRING(G_PROC_LEVEL,
	 	  G_PKG_NAME, '150: x_return_status : '||x_return_status );
 	      FND_LOG.STRING(G_PROC_LEVEL,
	 	  G_PKG_NAME, '150: x_msg_count  : '||x_msg_count );
 	      FND_LOG.STRING(G_PROC_LEVEL,
	 	  G_PKG_NAME, '150: x_msg_data : '||x_msg_data );
	  END IF;

       END IF; --l_num_scheme_id is not 0
    END IF; -- call renumber automatically


IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
END IF;

IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    FND_LOG.STRING(G_PROC_LEVEL,
	G_PKG_NAME, '1000: Leaving sort_clauses' );
END IF;

EXCEPTION
WHEN OTHERS THEN

   IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
       FND_LOG.STRING(G_EXCP_LEVEL,
           G_PKG_NAME, '1300: Leaving sort_clauses because of EXCEPTION: '||sqlerrm );
   END IF;
   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                       p_msg_name     => G_UNEXPECTED_ERROR,
                       p_token1       => G_SQLCODE_TOKEN,
                       p_token1_value => sqlcode,
                       p_token2       => G_SQLERRM_TOKEN,
                       p_token2_value => sqlerrm);

  ROLLBACK TO g_sort_clauses_GRP;

  x_return_status := G_RET_STS_UNEXP_ERROR ;

  IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
  END IF;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END sort_clauses;



END OKC_TERMS_MULTIREC_GRP;

/
