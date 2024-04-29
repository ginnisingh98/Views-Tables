--------------------------------------------------------
--  DDL for Package Body OKC_TERMS_UTIL_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TERMS_UTIL_GRP" AS
/* $Header: OKCGDUTB.pls 120.3.12010000.10 2013/07/16 11:30:07 skavutha ship $ */


  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                    CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_TERMS_UTIL_GRP';
  G_MODULE                     CONSTANT   VARCHAR2(200) := 'okc.plsql.'||G_PKG_NAME||'.';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;

  G_AMEND_CODE_DELETED         CONSTANT   VARCHAR2(30) := 'DELETED';
  G_ATTACHED_CONTRACT_SOURCE   CONSTANT   VARCHAR2(30) := 'ATTACHED';
  G_STRUCT_CONTRACT_SOURCE     CONSTANT   VARCHAR2(30) := 'STRUCTURED';
  G_INTERNAL_PARTY_CODE        CONSTANT   VARCHAR2(30) := 'INTERNAL_ORG';

  -- Validation string for repository.
  G_REP_CHECK_STATUS           CONSTANT   VARCHAR2(30) := 'OKC_REP_CHECK_STATUS';

  G_RET_STS_SUCCESS            CONSTANT   varchar2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   varchar2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   varchar2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

  G_UNEXPECTED_ERROR           CONSTANT   varchar2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   varchar2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   varchar2(200) := 'ERROR_CODE';


/*
-- To be used to delete Terms whenever a document is deleted.
*/
  PROCEDURE Delete_Doc (
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,
    p_commit           IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_validate_commit  IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_string IN VARCHAR2 := NULL,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER

   ,p_retain_lock_terms_yn        IN VARCHAR2 := 'N'
   ,p_retain_lock_xprt_yn         IN VARCHAR2 := 'N'
   ,p_retain_lock_deliverables_yn IN VARCHAR2 := 'N'

   -- For backward compatability
   ,p_retain_deliverables_yn IN VARCHAR2 := 'N'
   -- For backward compatability

   ,P_RELEASE_LOCKS_YN  IN VARCHAR2 := 'N'

   ) IS
    l_api_version      CONSTANT NUMBER := 1;
    l_api_name         CONSTANT VARCHAR2(30) := 'Delete_Doc';
    l_dummy            VARCHAR2(10);
   BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Entered Delete_Doc');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'200: Parameter List ');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'300: p_api_version : '||p_api_version);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'400: p_init_msg_list : '||p_init_msg_list);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'500: p_commit : '||p_commit);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'600: p_validate_commit  : '||p_validate_commit);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'700: p_validation_string : '||p_validation_string );
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'800: p_doc_type : '||p_doc_type);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'900: p_doc_id : '||p_doc_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'910: p_retain_lock_terms_yn : '||p_retain_lock_terms_yn);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'920: p_retain_lock_xprt_yn : '||p_retain_lock_xprt_yn);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'920: p_retain_lock_deliverables_yn : '||p_retain_lock_deliverables_yn);
      --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'930: p_retain_deliverables_yn : '||p_retain_deliverables_yn);
    END IF;
    -- Standard Start of API savepoint
    SAVEPOINT g_Delete_Doc;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

    IF p_validate_commit = G_TRUE THEN
      l_dummy := OKC_TERMS_UTIL_GRP.Ok_To_Commit(
        p_api_version         => p_api_version ,
        p_init_msg_list       => p_init_msg_list,
        x_msg_data            => x_msg_data  ,
        x_msg_count           => x_msg_count ,
        x_return_status       => x_return_status,

        p_validation_string   => p_validation_string,
        p_tmpl_change         => 'D',
        p_doc_id              => p_doc_id,
        p_doc_type            => p_doc_type
      );
      --------------------------------------------
      IF (l_dummy = G_FALSE OR x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;
      --------------------------------------------
    END IF;

    --  Calling Ptivate API to Delete the doc.
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1000: Calling Ptivate API to Delete the doc');
    END IF;
    OKC_TERMS_UTIL_PVT.Delete_Doc(
      x_return_status  => x_return_status,

      p_doc_type       => p_doc_type,
      p_doc_id         => p_doc_id

      ,p_retain_lock_terms_yn => p_retain_lock_terms_yn
      ,p_retain_lock_xprt_yn  => p_retain_lock_xprt_yn
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

  --IF p_retain_deliverables_yn = 'N' THEN
    --  Call Deliverable API to delete delevirable from the document.
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1100: Delete delevirable for the doc');
    END IF;
    OKC_DELIVERABLE_PROCESS_PVT.Delete_Deliverables(
      p_api_version    => l_api_version,
      p_init_msg_list  => FND_API.G_FALSE,
      p_doc_type       => p_doc_type,
      p_doc_id         => p_doc_id,
      p_doc_version    => -99,
      x_msg_data       => x_msg_data,
      x_msg_count      => x_msg_count,
      x_return_status  => x_return_status
      , p_retain_lock_deliverables_yn => p_retain_lock_deliverables_yn
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------
  --END IF;  -- p_retain_deliverables_yn = 'N'

    --  Call attachement API to delete attachements from the document.
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1200: Delete attachments for the doc');
    END IF;
    OKC_CONTRACT_DOCS_GRP.Delete_Ver_Attachments(
      p_api_version    => l_api_version,
      p_init_msg_list  => FND_API.G_FALSE,
      p_validation_level=> FND_API.G_VALID_LEVEL_FULL,
      p_commit          => FND_API.G_FALSE,
      p_business_document_type   => p_doc_type,
      p_business_document_id     => p_doc_id,
      p_business_document_version=> -99,
      x_msg_data       => x_msg_data,
      x_msg_count      => x_msg_count,
      x_return_status  => x_return_status
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    IF  P_RELEASE_LOCKS_YN = 'Y' THEN
       okc_k_entity_locks_grp.release_locks( p_api_version => 1,
                                             p_doc_type  => p_doc_type,
                                             p_doc_id  => p_doc_id,
                                             X_RETURN_STATUS  => X_RETURN_STATUS,
                                             X_MSG_COUNT  => X_MSG_COUNT,
                                             X_MSG_DATA  =>   X_MSG_DATA
                                            );
        --------------------------------------------
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR ;
        END IF;
       --------------------------------------------
    END IF;

    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1300: Leaving Delete_Doc');
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO g_Delete_Doc;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1400: Leaving Delete_Doc : OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO g_Delete_Doc;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1500: Leaving Delete_Doc : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      ROLLBACK TO g_Delete_Doc;

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1600: Leaving Delete_Doc because of EXCEPTION: '||sqlerrm);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
  END Delete_Doc ;

/*
-- To be used when doing bulk deletes of document.A very PO specific scenario.
--  This API will delete both current and all previous versions of document.
*/

 PROCEDURE Purge_Doc (
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,
    p_commit           IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_tbl          IN  doc_tbl_type
   ) IS
    l_api_version      CONSTANT NUMBER := 1;
    l_api_name         CONSTANT VARCHAR2(30) := 'Purge_Doc';

    TYPE doc_type_tbl_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
    TYPE doc_id_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

    l_doc_type_tbl   doc_type_tbl_type ;
    l_doc_id_tbl     doc_id_tbl_type ;
   BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1700: Entered Purge_Doc');
    END IF;
    -- Standard Start of API savepoint
    SAVEPOINT g_Purge_Doc;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

    IF p_doc_tbl.COUNT > 0 THEN
        FOR i IN p_doc_tbl.FIRST..p_doc_tbl.LAST LOOP
            l_doc_type_tbl(i):=p_doc_tbl(i).doc_type;
            l_doc_id_tbl(i):=p_doc_tbl(i).doc_id;
        END LOOP;
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1800: Bulk deleting Records ');
    END IF;

    IF l_doc_type_tbl.COUNT > 0 THEN
            FORALL i IN l_doc_type_tbl.FIRST..l_doc_type_tbl.LAST
             DELETE FROM OKC_K_ART_VAR_EXT_TL
                         WHERE  cat_id IN
                         ( SELECT KART.ID FROM OKC_K_ARTICLES_B KART,  OKC_K_ART_VARIABLES ARTVAR, OKC_BUS_VARIABLES_B BUSVAR
                                     WHERE document_type=l_doc_type_tbl(i)
                                     and   document_id=l_doc_id_tbl(i)
                                     AND   BUSVAR.mrv_flag='Y'
                                     AND   ARTVAR.VARIABLE_CODE=BUSVAR.VARIABLE_CODE
                                     AND   ARTVAR.CAT_ID=KART.ID);

          FORALL i IN l_doc_type_tbl.FIRST..l_doc_type_tbl.LAST
             DELETE FROM OKC_K_ART_VAR_EXT_B
                         WHERE  cat_id IN
                         ( SELECT KART.ID FROM OKC_K_ARTICLES_B KART,  OKC_K_ART_VARIABLES ARTVAR, OKC_BUS_VARIABLES_B BUSVAR
                                     WHERE document_type=l_doc_type_tbl(i)
                                     and   document_id=l_doc_id_tbl(i)
                                     AND   BUSVAR.mrv_flag='Y'
                                     AND   ARTVAR.VARIABLE_CODE=BUSVAR.VARIABLE_CODE
                                     AND   ARTVAR.CAT_ID=KART.ID);

         FORALL i IN l_doc_type_tbl.FIRST..l_doc_type_tbl.LAST
             DELETE FROM OKC_K_ART_VARIABLES
                         WHERE  cat_id IN
                         ( SELECT ID FROM OKC_K_ARTICLES_B
                                     WHERE document_type=l_doc_type_tbl(i)
                                     and   document_id=l_doc_id_tbl(i));

         /*FORALL i IN l_doc_type_tbl.FIRST..l_doc_type_tbl.LAST
             DELETE FROM OKC_K_ART_VAR_EXT_TLH
                         WHERE  cat_id IN
                         ( SELECT KART.ID FROM OKC_K_ARTICLES_BH KART,  OKC_K_ART_VARIABLES_H ARTVAR, OKC_BUS_VARIABLES_B BUSVAR
                                     WHERE document_type=l_doc_type_tbl(i)
                                     and   document_id=l_doc_id_tbl(i)
                                     AND   BUSVAR.mrv_flag='Y'
                                     AND   ARTVAR.VARIABLE_CODE=BUSVAR.VARIABLE_CODE
                                     AND   ARTVAR.CAT_ID=KART.ID);


          FORALL i IN l_doc_type_tbl.FIRST..l_doc_type_tbl.LAST
             DELETE FROM OKC_K_ART_VAR_EXT_BH
                         WHERE  cat_id IN
                         ( SELECT KART.ID FROM OKC_K_ARTICLES_BH KART,  OKC_K_ART_VARIABLES_H ARTVAR, OKC_BUS_VARIABLES_B BUSVAR
                                     WHERE document_type=l_doc_type_tbl(i)
                                     and   document_id=l_doc_id_tbl(i)
                                     AND   BUSVAR.mrv_flag='Y'
                                     AND   ARTVAR.VARIABLE_CODE=BUSVAR.VARIABLE_CODE
                                     AND   ARTVAR.CAT_ID=KART.ID);              */


         FORALL i IN l_doc_type_tbl.FIRST..l_doc_type_tbl.LAST
             DELETE FROM OKC_K_ART_VARIABLES_H
                         WHERE  cat_id IN
                         ( SELECT ID FROM OKC_K_ARTICLES_BH
                                     WHERE document_type=l_doc_type_tbl(i)
                                     and   document_id=l_doc_id_tbl(i));

         FORALL i IN l_doc_type_tbl.FIRST..l_doc_type_tbl.LAST
             DELETE FROM OKC_K_ARTICLES_B
                                      WHERE document_type=l_doc_type_tbl(i)
                                     and   document_id=l_doc_id_tbl(i);

         FORALL i IN l_doc_type_tbl.FIRST..l_doc_type_tbl.LAST
             DELETE FROM OKC_K_ARTICLES_BH
                                      WHERE document_type=l_doc_type_tbl(i)
                                     and   document_id=l_doc_id_tbl(i);

         FORALL i IN l_doc_type_tbl.FIRST..l_doc_type_tbl.LAST
             DELETE FROM OKC_SECTIONS_B
                                      WHERE document_type=l_doc_type_tbl(i)
                                      and   document_id=l_doc_id_tbl(i);

         FORALL i IN l_doc_type_tbl.FIRST..l_doc_type_tbl.LAST
             DELETE FROM OKC_SECTIONS_BH
                                      WHERE document_type=l_doc_type_tbl(i)
                                      and   document_id=l_doc_id_tbl(i);

         FORALL i IN l_doc_type_tbl.FIRST..l_doc_type_tbl.LAST
             DELETE FROM OKC_TEMPLATE_USAGES
                         WHERE document_type=l_doc_type_tbl(i)
                         and   document_id=l_doc_id_tbl(i);

         FORALL i IN l_doc_type_tbl.FIRST..l_doc_type_tbl.LAST
             DELETE FROM OKC_TEMPLATE_USAGES_H
                         WHERE document_type=l_doc_type_tbl(i)
                         and   document_id=l_doc_id_tbl(i);

	    IF nvl(fnd_profile.value('OKC_USE_CONTRACTS_RULES_ENGINE'), 'N') = 'Y' THEN
         	FORALL i IN l_doc_type_tbl.FIRST..l_doc_type_tbl.LAST
             DELETE FROM OKC_XPRT_DOC_QUES_RESPONSE
                         WHERE doc_type=l_doc_type_tbl(i)
                         and   doc_id=l_doc_id_tbl(i);
	    END IF;

    END IF;

    --  Call Deliverable API to delete delevirable from the document.
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1900: Purge delevirable for the doc');
    END IF;

    OKC_DELIVERABLE_PROCESS_PVT.Purge_Doc_Deliverables(
      p_api_version    => l_api_version,
      p_init_msg_list  => FND_API.G_FALSE,
      p_doc_table      => p_doc_tbl,
      x_msg_data       => x_msg_data,
      x_msg_count      => x_msg_count,
      x_return_status  => x_return_status
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------
    --  Call attachement API to delete attachements from the document.
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2000: Delete attachments for the doc');
    END IF;
   IF p_doc_tbl.COUNT > 0 THEN
     FOR i in p_doc_tbl.FIRST..p_doc_tbl.LAST LOOP

        OKC_CONTRACT_DOCS_GRP.Delete_doc_Attachments(
           p_api_version    => l_api_version,
           p_init_msg_list  => FND_API.G_FALSE,
           p_validation_level=> FND_API.G_VALID_LEVEL_FULL,
           p_commit          => FND_API.G_FALSE,
           p_business_document_type   => p_doc_tbl(i).doc_type,
           p_business_document_id     => p_doc_tbl(i).doc_id,
           x_msg_data       => x_msg_data,
           x_msg_count      => x_msg_count,
           x_return_status  => x_return_status
         );
         --------------------------------------------
         IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
         ELSIF (x_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR ;
         END IF;
       END LOOP;
   END IF;

    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2100: Leaving Purge_Doc');
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO g_Purge_Doc;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2200: Leaving Purge_Doc : OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO g_Purge_Doc;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2300: Leaving Purge_Doc : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      ROLLBACK TO g_Purge_Doc;

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2400: Leaving Purge_Doc because of EXCEPTION: '||sqlerrm);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
  END Purge_Doc ;

/*
-- To be used in amend flow to mark articles as amended if any of system
-- variables used in article has been changed in source document during amendment.
*/
  PROCEDURE Mark_Variable_Based_Amendment (
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,
    p_commit           IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER
  ) IS
    l_api_version      CONSTANT NUMBER := 1;
    l_api_name         CONSTANT VARCHAR2(30) := 'Mark_Variable_Based_Amendment';
    l_doc_class        VARCHAR2(30) := '?';
    l_var_codes_tbl    variable_code_tbl_type;
    i                  BINARY_INTEGER;

    CURSOR var_codes_crs IS
     select distinct var.variable_code
       from okc_k_art_variables var, okc_k_articles_b kart
       where kart.document_type = p_doc_type
         and kart.document_id = p_doc_id
         and kart.amendment_Operation_code is null
         and kart.id=var.cat_id
         and var.variable_type='S';

    CURSOR doc_cls_lst_crs IS
      SELECT document_type_class
        FROM okc_bus_doc_types_b
        WHERE document_type=p_doc_type;

   BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2500: Entered Mark_Variable_Based_Amendment');
    END IF;
    -- Standard Start of API savepoint
    SAVEPOINT g_Get_System_Variables;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;


    OPEN doc_cls_lst_crs;
    FETCH doc_cls_lst_crs INTO l_doc_class;
    CLOSE doc_cls_lst_crs;
/*
???
    -- Based on Doc type call API's provided by different integrating system and pass the pl/sql table prepared ins tep 2.These API will check which variable has changed and return list of only those variables which have changed.
    -- For example: If document type is 'BPO' then call API provided by PO team.
                -- If document type is 'BSA' then call API provided by OM team.
    -- Parameter to these API's will be p_doc_id IN Number, p_var_tbl IN/OUT pl/sql table having one column variable_code
*/

   IF l_doc_class in ('BSA','SO') THEN
   -- IF l_doc_class = 'OM' THEN
          Null;

   ELSIF l_doc_class = 'PO' THEN

      OPEN var_codes_crs;
      FETCH var_codes_crs BULK COLLECT INTO l_var_codes_tbl;
      CLOSE var_codes_crs;

      OKC_PO_INT_GRP.Get_Changed_Variables(
        p_api_version         => p_api_version ,
        p_init_msg_list       => p_init_msg_list,
        x_msg_data            => x_msg_data  ,
        x_msg_count           => x_msg_count ,
        x_return_status       => x_return_status,
        p_doc_type            => p_doc_type,
        p_doc_id              => p_doc_id,
        p_sys_var_tbl         => l_var_codes_tbl );

          --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------
   ELSIF l_doc_class = 'SOURCING' THEN

      OPEN var_codes_crs;
      FETCH var_codes_crs BULK COLLECT INTO l_var_codes_tbl;
      CLOSE var_codes_crs;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2510: Calling OKC_PON_INT_GRP.Get_Changed_Variables ');
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2510: l_var_codes_tbl.count : '||l_var_codes_tbl.count);
    END IF;

      OKC_PON_INT_GRP.Get_Changed_Variables(
        p_api_version         => p_api_version ,
        p_init_msg_list       => p_init_msg_list,
        x_msg_data            => x_msg_data  ,
        x_msg_count           => x_msg_count ,
        x_return_status       => x_return_status,
        p_doc_id              => p_doc_id,
        p_doc_type            => p_doc_type,
        p_sys_var_tbl         => l_var_codes_tbl );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2520: After Calling OKC_PON_INT_GRP.Get_Changed_Variables ');
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2520: l_var_codes_tbl.count : '||l_var_codes_tbl.count);
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2520: x_return_status : '||x_return_status);
    END IF;


          --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
       RAISE FND_API.G_EXC_ERROR ;
       END IF;
     --------------------------------------------
    ELSE
      NULL;
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2600: Calling OKC_TERMS_UTIL_PVT.Mark_Amendment in a loop');
    END IF;


    IF l_var_codes_tbl.count > 0 THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2525: l_var_codes_tbl.First : '||l_var_codes_tbl.First);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2525: l_var_codes_tbl.Last : '||NVL(l_var_codes_tbl.Last,-99));
      END IF;

        i := l_var_codes_tbl.FIRST;

        WHILE i IS NOT NULL LOOP

          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2530: l_var_codes_tbl(i) '||l_var_codes_tbl(i));
          END IF;

          OKC_TERMS_UTIL_PVT.Mark_Amendment(
            p_api_version    => l_api_version,
            p_init_msg_list  => FND_API.G_FALSE,
            x_return_status  => x_return_status,
            x_msg_data       => x_msg_data,
            x_msg_count      => x_msg_count,
            p_doc_type       => p_doc_type,
            p_doc_id         => p_doc_id,
            p_variable_code  => l_var_codes_tbl(i)
          );

          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2530: After calling OKC_TERMS_UTIL_PVT.Mark_Amendment');
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2530: x_return_status : '||x_return_status);
          END IF;

          --------------------------------------------
          IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
          ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
          END IF;
          --------------------------------------------

           i := l_var_codes_tbl.NEXT(i);

        END LOOP;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2700: Leaving Mark_Variable_Based_Amendment');
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO g_Get_System_Variables;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2800: Leaving Mark_Variable_Based_Amendment : OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO g_Get_System_Variables;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2900: Leaving Mark_Variable_Based_Amendment : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      ROLLBACK TO g_Get_System_Variables;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'3000: Leaving Mark_Variable_Based_Amendment because of EXCEPTION: '||sqlerrm);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  END Mark_Variable_Based_Amendment;

/*
--To be used to find out if a document is using articles.If yes then what type.
--Possible return values NONE, ONLY_STANDARD_EXIST, NON_STANDARD_EXIST .
*/

  FUNCTION Is_Article_Exist(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER
   ) RETURN VARCHAR2 IS
    l_api_version      CONSTANT NUMBER := 1;
    l_api_name         CONSTANT VARCHAR2(30) := 'Is_Article_exist';
    l_dummy  VARCHAR2(1) := '?';
    l_return_value    VARCHAR2(100) := G_NO_ARTICLE_EXIST;

    CURSOR find_art_crs IS
     SELECT a.standard_yn
       FROM okc_k_articles_b kart, okc_articles_all a
       WHERE kart.document_type=p_doc_type
         AND kart.document_id=p_doc_id
         AND nvl(kart.amendment_operation_code,'?')<>G_AMEND_CODE_DELETED
         AND nvl(kart.summary_amend_operation_code,'?')<>G_AMEND_CODE_DELETED
         AND a.article_id = kart.sav_sae_id
       ORDER BY Decode(a.standard_yn,'N',1) ASC ;
   BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3100: Entered Is_Article_exist');
    END IF;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

    IF Get_Contract_Source_Code(p_document_type => p_doc_type,p_document_id => p_doc_id) = 'ATTACHED' THEN
       RETURN G_NON_STANDARD_ART_EXIST;
    END IF;

    OPEN find_art_crs;
    FETCH find_art_crs INTO l_dummy;
    CLOSE find_art_crs;
    IF l_dummy='Y' THEN
      l_return_value := G_ONLY_STANDARD_ART_EXIST;
     ELSIF l_dummy='N' THEN
      l_return_value := G_NON_STANDARD_ART_EXIST;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3200: Result Is_Article_exist? : ['||l_return_value||']');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3300: Leaving Is_Article_exist');
    END IF;
    RETURN l_return_value ;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'3400: Leaving Is_Article_exist : OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      RETURN FND_API.G_FALSE ;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'3500: Leaving Is_Article_exist : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      RETURN FND_API.G_FALSE ;

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'3600: Leaving Is_Article_exist because of EXCEPTION: '||sqlerrm);
      END IF;

      IF find_art_crs%ISOPEN THEN
        CLOSE find_art_crs;
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      RETURN FND_API.G_FALSE ;
  END Is_Article_exist ;

  FUNCTION Is_Article_Exist(


    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER
   ) RETURN VARCHAR2 IS
   l_return_status Varchar2(1);
   l_msg_data      FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
   l_msg_count     NUMBER;
   l_return_value  Varchar2(30);
BEGIN
   l_return_value:=Is_Article_Exist(P_api_version => 1,
                    p_init_msg_list => FND_API.G_FALSE,
                    p_doc_type      => p_doc_type,
                    p_doc_id        => p_doc_id,
                    x_return_status => l_return_status,
                    x_msg_data      => l_msg_data,
                    x_msg_count     => l_msg_count);

    IF l_return_status <> G_RET_STS_SUCCESS THEN
       l_return_value := NULL;
    END IF;
return l_return_value;
END Is_Article_Exist;



/* 11.5.10+ code changes for COntract Repository Start
  11-OCT-2004 pnayani  updated Is_Document_Updatable FUNCTION
  Added logic to check for REPOSITORY class documents
  14-MAR-2005 andixit  Updated Repository logic.
*/

  FUNCTION Is_Document_Updatable(
    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER,
    p_validation_string IN VARCHAR2
   ) RETURN VARCHAR2 IS -- 'T' - updatable, 'F'- nonupdatable, 'E' - doesn't exist
    l_api_version      CONSTANT NUMBER := 1;
    l_api_name         CONSTANT VARCHAR2(30) := 'Is_Document_Updatable';
    l_return_status Varchar2(1);
    l_msg_data      FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
    l_msg_count     NUMBER;
    l_return_value Varchar2(1) := 'E';
    l_org_id        NUMBER := (-99);
    l_init_msg_list VARCHAR2(2000);

    CURSOR tmpl_crs(p_org_id NUMBER) IS
       SELECT Decode(STATUS_CODE,'PENDING_APPROVAL',G_FALSE,'EXPIRED',G_FALSE,
                Decode(NVL(HIDE_YN,'N'), 'N',
                  Decode(c.cnt,0,
                    Decode( NVL(t.ORG_ID,p_org_id), p_org_id,G_TRUE, G_FALSE)
                  ,G_FALSE)
                ,G_FALSE)
              ) upd
       FROM   okc_terms_templates_all t,
              (SELECT Count(*) cnt FROM OKC_TERMS_TEMPLATES_ALL i WHERE i.PARENT_TEMPLATE_ID = p_doc_id) c
       WHERE  template_id = p_doc_id;

    --11.5.10+ code changes for COntract Repository Start
    CURSOR doc_class_cur IS
    SELECT document_type_class
    FROM okc_bus_doc_types_b
    WHERE document_type = p_doc_type;

    l_doc_class  okc_bus_doc_types_b.document_type_class%TYPE;
    --11.5.10+ code changes for COntract Repository end

    CURSOR tu_csr IS
      SELECT G_TRUE
        FROM OKC_TEMPLATE_USAGES
       WHERE DOCUMENT_TYPE = p_doc_type AND DOCUMENT_ID = p_doc_id;

   BEGIN

    IF p_doc_type='TEMPLATE' THEN

      l_org_id := mo_global.get_current_org_id();

      OPEN tmpl_crs(l_org_id);
      FETCH tmpl_crs INTO l_return_value;
      CLOSE tmpl_crs;
     ELSE
        --11.5.10+ code changes for COntract Repository Start
        OPEN doc_class_cur;
        FETCH doc_class_cur INTO l_doc_class;
        CLOSE doc_class_cur;
        IF l_doc_class = 'REPOSITORY' THEN
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3650: Calling  OKC_REP_UTIL_PVT.ok_to_commit');
            END IF;
            l_return_value := OKC_REP_UTIL_PVT.ok_to_commit(
                           p_api_version   => 1,
                           p_init_msg_list => l_init_msg_list,
						   p_validation_string => G_REP_CHECK_STATUS,
                           p_doc_id        => p_doc_id,
                           x_return_status => l_return_status,
                           x_msg_count     => l_msg_count,
                           x_msg_data      => l_msg_data);

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3651: AFter Calling  OKC_REP_UTIL_PVT.ok_to_commit ');
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3652: l_return_value : '||l_return_value);
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3653: l_return_status : '||l_return_status);
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3654: l_msg_count : '||l_msg_count);
            END IF;

            IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (l_return_status = G_RET_STS_ERROR) THEN
              RAISE FND_API.G_EXC_ERROR ;
            END IF;
        --11.5.10+ code changes for COntract Repository end

        ELSE

            OPEN tu_csr;
            FETCH tu_csr INTO l_return_value;
            CLOSE tu_csr;

        END IF;   --  l_doc_class = 'REPOSITORY'
    END IF;  -- p_doc_type='TEMPLATE'
    return l_return_value;

    EXCEPTION
    WHEN OTHERS THEN
     IF tu_csr%ISOPEN THEN
         CLOSE tu_csr;
     END IF;
     IF doc_class_cur%ISOPEN THEN
         CLOSE doc_class_cur;
     END IF;
    return l_return_value;

   END Is_Document_Updatable;

FUNCTION Deviation_From_Standard(
    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER
   ) RETURN VARCHAR2 IS
   l_return_status Varchar2(1);
   l_msg_data      FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
   l_msg_count     NUMBER;
   l_return_value  Varchar2(30);
BEGIN

   l_return_value:=Deviation_From_Standard(p_api_version => 1,
                    p_init_msg_list => FND_API.G_FALSE,
                    p_doc_type      => p_doc_type,
                    p_doc_id        => p_doc_id,
                    x_return_status => l_return_status,
                    x_msg_data      => l_msg_data,
                    x_msg_count     => l_msg_count);

    IF l_return_status <> G_RET_STS_SUCCESS THEN
       l_return_value := NULL;
    END IF;
return l_return_value;
END;

/*
-- To be used to find out if Terms and deliverable has deviate any deviation as
-- compared to template that was used in the document.ocument has used.
-- Possible return values NO_CHANGE,ARTICLES_CHANGED,DELIVERABLES_CHANGED,
-- ARTICLES_AND_DELIVERABLES_CHANGED
*/
  FUNCTION Deviation_From_Standard(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER
   ) RETURN VARCHAR2 IS
    l_api_version      CONSTANT NUMBER := 1;
    l_api_name         CONSTANT VARCHAR2(30) := 'Deviation_From_Standard';
    l_return_value     VARCHAR2(100) := G_NO_CHANGE;
    l_article_changed  VARCHAR2(1) := 'N';
    l_deliverable_changed  VARCHAR2(1) := 'N';

    CURSOR find_art_crs IS
      SELECT 'Y'
        FROM okc_k_articles_b a
   WHERE ( document_type=p_doc_type AND document_id=p_doc_id AND source_flag
 IS NULL )

          OR  (
              document_type='TEMPLATE' AND document_id IN
                (SELECT template_id FROM okc_template_usages
                    WHERE document_type=p_doc_type AND document_id=p_doc_id )
              AND NOT EXISTS
                (SELECT 'x' from okc_k_articles_b b
                    WHERE b.document_type=p_doc_type AND b.document_id=p_doc_id
 AND ( b.sav_sae_id=a.sav_sae_id /*or b.ref_article_id=a.sav_sae_id*/) )
                    )
      ;

   BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3700: Entered Deviation_From_Standard');
    END IF;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

    OPEN find_art_crs;
    FETCH find_art_crs INTO l_article_changed;
    CLOSE find_art_crs;

    IF l_deliverable_changed='Y' THEN
      IF l_article_changed='Y' THEN
        l_return_value := G_ART_AND_DELIV_CHANGED;
       ELSE
        l_return_value := G_DELIVERABLES_CHANGED;
      END IF;
     ELSE
      IF l_article_changed='Y' THEN
        l_return_value := G_ARTICLES_CHANGED;
       ELSE
        l_return_value := G_NO_CHANGE;
      END IF;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3800: Result Deviation_From_Standard? : ['||l_return_value||']');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3900: Leaving Deviation_From_Standard');
    END IF;
    RETURN l_return_value ;
   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'4000: Leaving Deviation_From_Standard : OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      RETURN NULL ;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'4100: Leaving Deviation_From_Standard : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      RETURN NULL ;

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'4200: Leaving Deviation_From_Standard because of EXCEPTION: '||sqlerrm);
      END IF;

      IF find_art_crs%ISOPEN THEN
        CLOSE find_art_crs;
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      RETURN NULL ;
  END Deviation_From_Standard ;

/*
--To be used to find out if template used in document has expired.Possible return values Y,N.
-- Possible return values are
--   FND_API.G_TRUE  = Template expired
--   FND_API.G_FALSE = Template not expired.
*/
  FUNCTION Is_Template_Expired(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER
   ) RETURN VARCHAR2 IS


    l_api_version      CONSTANT NUMBER := 1;
    l_api_name         CONSTANT VARCHAR2(30) := 'Is_Template_Expired';
    l_return_value     VARCHAR2(1) := 'N';

    CURSOR find_tmpl_crs IS
     SELECT 'Y'
       FROM okc_template_usages_v tu,
            okc_terms_templates_all t
      WHERE tu.document_type = p_doc_type AND tu.document_id = p_doc_id
        AND t.template_id = tu.template_id AND t.status_code = 'APPROVED'
        AND nvl(t.end_date,sysdate+1) <= sysdate;

   BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4300: Entered Is_Template_Expired');
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4400: Looking for Template');
    END IF;

    OPEN  find_tmpl_crs;
    FETCH find_tmpl_crs INTO l_return_value;
    CLOSE find_tmpl_crs ;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4500: Result Is_Template_Expired? : ['||l_return_value||']');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4600: Leaving Is_Template_Expired');
    END IF;

    RETURN l_return_value ;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'4700: Leaving Is_Template_Expired : OKC_API.G_EXCEPTION_ERROR Exception');
   END IF;

   x_return_status := G_RET_STS_ERROR ;
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
   RETURN NULL ;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'4800: Leaving Is_Template_Expired : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
   END IF;

   x_return_status := G_RET_STS_UNEXP_ERROR ;
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
   RETURN NULL ;

 WHEN OTHERS THEN
   IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'4900: Leaving Is_Template_Expired because of EXCEPTION: '||sqlerrm);
   END IF;

   IF find_tmpl_crs%ISOPEN THEN
      CLOSE find_tmpl_crs;
   END IF;

   x_return_status := G_RET_STS_UNEXP_ERROR ;

   IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
   END IF;

   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
   RETURN NULL ;
END Is_Template_Expired;

/*
--To be used to find out if any deliverable exists on document.If Yes then what type.
-- Possible values: NONE, ONLY_CONTRACTUAL, ONLY_INTERNAL, CONTRACTUAL_AND_INTERNAL
*/


  FUNCTION Is_Deliverable_Exist(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER
   ) RETURN VARCHAR2 IS
   l_api_name         CONSTANT VARCHAR2(30) := 'Is_Deliverable_Exist';
   l_return_value varchar2(100);
   BEGIN
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5000: Entering Is_Deliverable_Exist');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5100: Parameters ');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5200: p_doc_type : '||p_doc_type);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5300: p_doc_id : '||p_doc_id);
   END IF;

     x_return_status := G_RET_STS_SUCCESS;
     l_return_value :=OKC_DELIVERABLE_PROCESS_PVT.deliverables_exist(
       p_api_version    => p_api_version,
       p_init_msg_list  => p_init_msg_list,
       x_msg_data       => x_msg_data,
       x_msg_count      => x_msg_count,
       x_return_status  => x_return_status,
       p_docid    =>  p_doc_id,
       p_doctype  => p_doc_type
     );

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5400: After Call to  OKC_DELIVERABLE_PROCESS_PVT.deliverables_exist');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5500: x_return_status : '||x_return_status);
   END IF;

     IF l_return_value IS NULL THEN
           x_return_status := G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
     END IF;

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5600: Leaving Is_Deliverable_Exist');
   END IF;

     Return l_return_value;
  END;


/*
--To be used in amend flow to find out if any article is amended.If Yes then what
-- type of article is amended.Possible values NO_ARTICLE_AMENDED,ONLY_STANDARD_AMENDED ,NON_STANDARD_AMENDED
*/

  FUNCTION Is_Article_Amended(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER
   ) RETURN VARCHAR2 IS
    l_api_version      CONSTANT NUMBER := 1;
    l_api_name         CONSTANT VARCHAR2(30) := 'Is_Article_AMENDED';
    l_dummy  VARCHAR2(1) := '?';
    l_return_value    VARCHAR2(100) := G_NO_ARTICLE_AMENDED;
    CURSOR find_art_crs IS
     SELECT a.standard_yn
       FROM okc_k_articles_b kart, okc_articles_all a
       WHERE kart.document_type=p_doc_type
         AND kart.document_id=p_doc_id
         AND kart.summary_amend_operation_code IS NOT NULL
         AND a.article_id = kart.sav_sae_id
       ORDER BY Decode(a.standard_yn,'N',1) ASC ;
   BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5700: Entered Is_Article_AMENDED');
    END IF;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

    OPEN find_art_crs;
    FETCH find_art_crs INTO l_dummy;
    CLOSE find_art_crs;

    IF l_dummy='Y' THEN
      l_return_value := G_ONLY_STANDARD_ART_AMENDED;
     ELSIF l_dummy='N' THEN
      l_return_value := G_NON_STANDARD_ART_AMENDED;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.

    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5800: Result Is_Article_AMENDED? : ['||l_return_value||']');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5900: Leaving Is_Article_AMENDED');
    END IF;

    RETURN l_return_value ;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
   IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'6000: Leaving Is_Article_AMENDED : OKC_API.G_EXCEPTION_ERROR Exception');
   END IF;
   x_return_status := G_RET_STS_ERROR ;
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
   RETURN NULL ;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'6100: Leaving Is_Article_AMENDED : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
    END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    RETURN NULL ;

  WHEN OTHERS THEN
    IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'6200: Leaving Is_Article_AMENDED because of EXCEPTION: '||sqlerrm);
    END IF;

    IF find_art_crs%ISOPEN THEN
        CLOSE find_art_crs;
    END IF;

    x_return_status := G_RET_STS_UNEXP_ERROR ;

    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      RETURN NULL ;

END Is_Article_AMENDED;

/*
-- To be used in amend flow to find out if any deliverable is amended.
-- If Yes then what type.Possible values
-- NONE,ONLY_CONTRACTUAL,ONLY_INTERNAL,CONTRACTUAL_AND_INTERNAL
*/

  FUNCTION Is_Deliverable_Amended(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER
   ) RETURN VARCHAR2 IS
    l_api_name         CONSTANT VARCHAR2(30) := 'Is_Deliverable_Amended';
    l_return_value varchar2(100);
   BEGIN
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'6300: Entering Is_Deliverable_Amended');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'6400: Parameters ');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'6500: p_doc_type : '||p_doc_type);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'6600: p_doc_id : '||p_doc_id);
   END IF;
     x_return_status := G_RET_STS_SUCCESS;
     l_return_value :=OKC_DELIVERABLE_PROCESS_PVT.deliverables_amended (
       p_api_version    => p_api_version,
       p_init_msg_list  => p_init_msg_list,
       x_msg_data       => x_msg_data,
       x_msg_count      => x_msg_count,
       x_return_status  => x_return_status,
       p_docid    =>  p_doc_id,
       p_doctype  => p_doc_type
     );

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'6700: After Call to  OKC_DELIVERABLE_PROCESS_PVT.deliverables_amended');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'6800: x_return_status : '||x_return_status);
   END IF;

     IF l_return_value IS NULL THEN
           x_return_status := G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
     END IF;
     Return l_return_value;
  END;


--This API is deprecated. Use GET_CONTRACT_DETAILS() instead.
  PROCEDURE Get_Terms_Template(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER,
    x_template_id      OUT NOCOPY NUMBER,
    x_template_name    OUT NOCOPY VARCHAR2
   ) IS

    l_api_version      CONSTANT NUMBER := 1;
    l_api_name         CONSTANT VARCHAR2(30) := 'Get_Terms_Template';
    l_dummy  VARCHAR2(1) := '?';
    l_return_value    VARCHAR2(100) := G_NO_ARTICLE_AMENDED;

    CURSOR find_tmpl_crs IS
     SELECT t.template_id, t.template_name
       FROM okc_template_usages_v tu, okc_terms_templates_all t
      WHERE tu.document_type = p_doc_type AND tu.document_id = p_doc_id
        AND t.template_id = tu.template_id;

   BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'6900: Entered Get_Terms_Template');
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

    OPEN  find_tmpl_crs;
    FETCH find_tmpl_crs INTO x_template_id, x_template_name;
    CLOSE find_tmpl_crs;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7000: Result Get_Terms_Template? : ['||l_return_value||']');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7100: Leaving Get_Terms_Template');
    END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN

    IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7200: Leaving Get_Terms_Template : OKC_API.G_EXCEPTION_ERROR Exception');
    END IF;

    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    x_return_status := G_RET_STS_ERROR ;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7300: Leaving Get_Terms_Template : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  WHEN OTHERS THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7400: Leaving Get_Terms_Template because of EXCEPTION:'||sqlerrm);
      END IF;
      IF find_tmpl_crs%ISOPEN THEN
        CLOSE find_tmpl_crs;
      END IF;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      x_return_status := G_RET_STS_UNEXP_ERROR ;

  END Get_Terms_Template;

/*
-- To be used to find out document type when document is of contract family.
*/
  FUNCTION Get_Contract_Document_Type(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_chr_id           IN  NUMBER
   ) RETURN VARCHAR2 IS
    l_api_version      CONSTANT NUMBER := 1;
    l_api_name         CONSTANT VARCHAR2(30) := 'Get_Contract_Document_Type';
    l_return_value     VARCHAR2(10);
    CURSOR find_chrtype_crs IS
     SELECT
     decode(application_id,515,'OKS',510,decode(buy_or_sell,'S','OKC_SELL','B','OKC_BUY','OKC_SELL'),871,'OKO',777,decode(buy_or_sell,'S','OKE_SELL','B','OKE_BUY','OKE_SELL'),540,'OKL',Null)
       FROM okc_k_headers_b
       WHERE id=p_chr_id;
   BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7500: Entered Get_Contract_Document_Type');
    END IF;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

    OPEN find_chrtype_crs;
    FETCH find_chrtype_crs INTO l_return_value;
    CLOSE find_chrtype_crs;

    IF l_return_value IS NULL THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7600: Result Get_Contract_Document_Type? : ['||l_return_value||']');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7700: Leaving Get_Contract_Document_Type');
    END IF;
    RETURN l_return_value ;
   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7800: Leaving Get_Contract_Document_Type : OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      RETURN NULL ;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7900: Leaving Get_Contract_Document_Type : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      RETURN NULL ;

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'8000: Leaving Get_Contract_Document_Type because of EXCEPTION: '||sqlerrm);
      END IF;

      IF find_chrtype_crs%ISOPEN THEN
        CLOSE find_chrtype_crs;
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      RETURN NULL ;
  END Get_Contract_Document_Type;
/*
-- To be used to find out document type/ID when document is of contract family.
*/
  PROCEDURE Get_Contract_Document_Type_ID(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_chr_id           IN  NUMBER,
    x_doc_id           OUT NOCOPY NUMBER,
    x_doc_type         OUT NOCOPY VARCHAR2
   ) IS
    l_api_version      CONSTANT NUMBER := 1;
    l_api_name         CONSTANT VARCHAR2(30) := 'Get_Contract_Document_Type_Id';
    l_notfound         BOOLEAN;
    CURSOR find_chrtype_crs IS
     SELECT
     decode(application_id,515,'OKS',510,decode(buy_or_sell,'S','OKC_SELL','B','OKC_BUY','OKC_SELL'),871,'OKO',777,decode(buy_or_sell,'S','OKE_SELL','B','OKE_BUY','OKE_SELL'),540,'OKL',Null),
     document_id
       FROM okc_k_headers_b
       WHERE id=p_chr_id;
   BEGIN
    x_doc_type := NULL;
    x_doc_id := NULL;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'8100: Entered Get_Contract_Document_Type_id');
    END IF;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

    OPEN find_chrtype_crs;
    FETCH find_chrtype_crs INTO x_doc_type, x_doc_id;
    l_notfound := find_chrtype_crs%NOTFOUND;
    CLOSE find_chrtype_crs;

    IF l_notfound THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'8200: Result Document_Type : ['||x_doc_type||']');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'8300: Result Document_ID : ['||x_doc_id||']');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'8400: Leaving Get_Contract_Document_Type');
    END IF;
   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'8500: Leaving Get_Contract_Document_Type_id : OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'8600: Leaving Get_Contract_Document_Type_id : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'8700: Leaving Get_Contract_Document_Type_id because of EXCEPTION: '||sqlerrm);
      END IF;

      IF find_chrtype_crs%ISOPEN THEN
        CLOSE find_chrtype_crs;
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
  END Get_Contract_Document_Type_Id;
/*
-- To be used to find out document type when document is of contract family.
*/
  PROCEDURE Get_Last_Update_Date (
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER,

    x_deliverable_changed_date OUT NOCOPY DATE,
    x_terms_changed_date OUT NOCOPY DATE
   ) IS

l_api_version      CONSTANT NUMBER := 1;
l_api_name         CONSTANT VARCHAR2(30) := 'Get_Last_Update_Date';
l_article_change_date  date;
l_section_change_date  date;
l_article_h_change_date  date;
l_section_h_change_date  date;
l_contract_source_code okc_template_usages.contract_source_code%TYPE := 'STRUCTURED';

Cursor l_get_max_art_date_csr IS
SELECT max(Nvl(LAST_AMENDMENT_DATE,CREATION_DATE))
FROM OKC_K_ARTICLES_B
WHERE DOCUMENT_TYPE=p_doc_type
AND   DOCUMENT_ID=p_doc_id;

Cursor l_get_max_scn_date_csr IS
SELECT max(Nvl(LAST_AMENDMENT_DATE,CREATION_DATE))
FROM OKC_SECTIONS_B
WHERE DOCUMENT_TYPE=p_doc_type
AND   DOCUMENT_ID=p_doc_id;

Cursor l_get_max_art_hist_date_csr IS
SELECT max(Nvl(LAST_AMENDMENT_DATE,CREATION_DATE))
FROM OKC_K_ARTICLES_BH
WHERE DOCUMENT_TYPE=p_doc_type
AND   DOCUMENT_ID=p_doc_id;

Cursor l_get_max_scn_hist_date_csr IS
SELECT max(Nvl(LAST_AMENDMENT_DATE,CREATION_DATE))
FROM OKC_SECTIONS_BH
WHERE DOCUMENT_TYPE=p_doc_type
AND   DOCUMENT_ID=p_doc_id;

Cursor l_get_contract_source_csr IS
SELECT contract_source_code
FROM okc_template_usages
WHERE document_type = p_doc_type
AND document_id = p_doc_id;

Cursor l_get_max_usg_upd_date_csr IS
SELECT MAX(last_update_date)
FROM   okc_template_usages
WHERE  document_type = p_doc_type
AND    document_id = p_doc_id;

BEGIN
  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'8800: Entered get_last_update_date');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'8900: Parameters');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'9000: p_api_version : '||p_api_version);
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'9100: p_init_msg_list : '||p_init_msg_list);
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'9200: p_doc_type : '||p_doc_type);
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'9300: p_doc_id : '||p_doc_id);
  END IF;

  -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name , G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

  OPEN l_get_contract_source_csr;
  FETCH l_get_contract_source_csr INTO l_contract_source_code;
  CLOSE l_get_contract_source_csr;


  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'9310: After fetching l_get_contract_source_csr');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'9320: Contract Source Code :'||l_contract_source_code);
  END IF;

  IF l_contract_source_code = G_ATTACHED_CONTRACT_SOURCE THEN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'9330: Before opening l_get_max_usg_upd_date_csr');
    END IF;

    OPEN l_get_max_usg_upd_date_csr;
    FETCH l_get_max_usg_upd_date_csr INTO x_terms_changed_date;
    CLOSE l_get_max_usg_upd_date_csr;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'9340: After fetching l_get_max_usg_upd_date_csr');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'9350: l_terms_changed_date :'||x_terms_changed_date);
    END IF;

  ELSE


    OPEN  l_get_max_art_date_csr;
    FETCH l_get_max_art_date_csr INTO l_article_change_date;
    CLOSE l_get_max_art_date_csr;

    OPEN  l_get_max_scn_date_csr;
    FETCH l_get_max_scn_date_csr INTO l_section_change_date;
    CLOSE l_get_max_scn_date_csr;

    OPEN  l_get_max_art_hist_date_csr;
    FETCH l_get_max_art_hist_date_csr INTO l_article_h_change_date;
    CLOSE l_get_max_art_hist_date_csr;

    OPEN  l_get_max_scn_hist_date_csr;
    FETCH l_get_max_scn_hist_date_csr INTO l_section_h_change_date;
    CLOSE l_get_max_scn_hist_date_csr;

    --Bug 3659714
    l_article_change_date := nvl(l_article_change_date,okc_api.g_miss_date);
    l_section_change_date := nvl(l_section_change_date,okc_api.g_miss_date);

    x_terms_changed_date := Greatest(l_article_change_date, l_section_change_date,
                                     NVL(l_article_h_change_date,l_article_change_date),
                                     NVL(l_section_h_change_date,l_section_change_date));

  END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'9400: x_terms_changed_date : '||x_terms_changed_date);
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'9500: Before Calling okc_deliverable_process_pvt.get_last_amendment_date');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'9600: p_busdoc_id : '||p_doc_id);
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'9700: p_busdoc_type : '||p_doc_type);
    END IF;

    x_deliverable_changed_date := okc_deliverable_process_pvt.get_last_amendment_date (
       p_api_version    => p_api_version,
       p_init_msg_list  => p_init_msg_list,
       x_msg_data       => x_msg_data,
       x_msg_count      => x_msg_count,
       x_return_status  => x_return_status,
       p_busdoc_id       => p_doc_id,
       p_busdoc_type     => p_doc_type,
       p_busdoc_version  => -99);


  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'9800: After Calling okc_deliverable_process_pvt.get_last_amendment_date');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'9900: x_return_status : '||x_return_status);
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'10000: x_deliverable_changed_date : '||x_deliverable_changed_date);
  END IF;


EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'10100: Leaving get_last_update_date : OKC_API.G_EXCEPTION_ERROR Exception');
 END IF;

 IF l_get_max_art_date_csr%ISOPEN THEN
    CLOSE l_get_max_art_date_csr;
 END IF;

 x_return_status := G_RET_STS_ERROR ;
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'10200: Leaving get_last_update_date : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
   END IF;

 IF l_get_max_art_date_csr%ISOPEN THEN
    CLOSE l_get_max_art_date_csr;
 END IF;

   x_return_status := G_RET_STS_UNEXP_ERROR ;
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN OTHERS THEN
  IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'10300: Leaving get_last_update_date because of EXCEPTION: '||sqlerrm);
  END IF;

 IF l_get_max_art_date_csr%ISOPEN THEN
    CLOSE l_get_max_art_date_csr;
 END IF;


  x_return_status := G_RET_STS_UNEXP_ERROR ;
  IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
   END IF;
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
END get_last_update_date;

  FUNCTION Ok_To_Commit (
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    p_tmpl_change      IN  VARCHAR2,
    p_validation_string IN VARCHAR2,
    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER
   ) RETURN Varchar2 IS
    l_api_version      CONSTANT NUMBER := 1;
    l_api_name         CONSTANT VARCHAR2(30) := 'ok_to_commit';
    l_ok_to_commit     Varchar2(1) := G_FALSE;
    l_doc_class        VARCHAR2(30) := '?';
    l_tmpl_status      VARCHAR2(30);
    l_end_date         DATE;

    CURSOR doc_cls_lst_crs IS
      SELECT document_type_class
        FROM okc_bus_doc_types_b
        WHERE document_type=p_doc_type;
    CURSOR l_tmpl_csr IS
     SELECT status_code,nvl(end_date,sysdate+1) end_date
     FROM okc_terms_templates_all
     WHERE template_id = p_doc_id;
   BEGIN

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'10400: Entering Ok_To_Commit');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'10500: Parameter List ');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'10600: p_api_version : '||p_api_version);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'10700: p_init_msg_list : '||p_init_msg_list);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'10800: p_tmpl_change : '||p_tmpl_change);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'10900: p_validation_string : '||p_validation_string );
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'11000: p_doc_type : '||p_doc_type);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'11100: p_doc_id : '||p_doc_id);
  END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

 IF p_doc_type = G_TMPL_DOC_TYPE THEN
  OPEN l_tmpl_csr;
  FETCH l_tmpl_csr INTO l_tmpl_status,l_end_date;
  CLOSE l_tmpl_csr;

  IF l_tmpl_status IN ('DRAFT','REJECTED','REVISION') THEN
    l_ok_to_commit := G_TRUE;
  ELSE
    l_ok_to_commit := G_FALSE;
  END IF;
 ELSE
 IF nvl(p_validation_string,'?') <> 'OKC_TEST_UI' THEN
    OPEN doc_cls_lst_crs;
    FETCH doc_cls_lst_crs INTO l_doc_class;
    CLOSE doc_cls_lst_crs;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'11200: l_doc_class : '||l_doc_class);
  END IF;

    IF l_doc_class = 'PO' THEN

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'11300: Calling  OKC_PO_INT_GRP.ok_to_commit ');
      END IF;

      l_ok_to_commit := OKC_PO_INT_GRP.ok_to_commit(
                             p_api_version   => 1,
                             p_init_msg_list => p_init_msg_list,
                             p_tmpl_change   => p_tmpl_change,
                             p_validation_string => p_validation_string,
                             p_doc_type        => p_doc_type,
                             p_doc_id        => p_doc_id,
                             x_return_status => x_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data
                           );

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'11400: AFter Calling  OKC_PO_INT_GRP.ok_to_commit ');
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'11500: l_ok_to_commit : '||l_ok_to_commit);
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'11600: x_return_status : '||x_return_status);
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'11700: x_msg_count : '||x_msg_count);
      END IF;

      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;

    ELSIF l_doc_class = 'SOURCING' THEN

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'11800: Calling  OKC_PON_INT_GRP.ok_to_commit');
      END IF;

      l_ok_to_commit := OKC_PON_INT_GRP.ok_to_commit(
                             p_api_version   => 1,
                             p_init_msg_list => p_init_msg_list,
                             p_validation_string => p_validation_string,
                             p_doc_id        => p_doc_id,
                             p_doc_type      => p_doc_type,
                             x_return_status => x_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data
                           );

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'11900: AFter Calling  OKC_PON_INT_GRP.ok_to_commit ');
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'12000: l_ok_to_commit : '||l_ok_to_commit);
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'12100: x_return_status : '||x_return_status);
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'12200: x_msg_count : '||x_msg_count);
      END IF;

      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;

     ELSIF l_doc_class in ('BSA','SO') THEN
    -- ELSIF l_doc_class = 'OM' THEN

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'12300: Calling  OKC_OM_INT_GRP.ok_to_commit');
      END IF;

         l_ok_to_commit := OKC_OM_INT_GRP.ok_to_commit(
                             p_api_version   => 1,
                             p_init_msg_list => p_init_msg_list,
                             p_tmpl_change   => p_tmpl_change,
                             p_validation_string => p_validation_string,
                             p_doc_id        => p_doc_id,
                             x_return_status => x_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data
                           );

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'12400: AFter Calling  OKC_OM_INT_GRP.ok_to_commit ');
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'12500: l_ok_to_commit : '||l_ok_to_commit);
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'12600: x_return_status : '||x_return_status);
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'12700: x_msg_count : '||x_msg_count);
      END IF;

      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;

     ELSIF l_doc_class = 'OKS' THEN

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'12800: Calling  OKC_OKS_INT_GRP.ok_to_commit');
      END IF;

         l_ok_to_commit := OKC_OKS_INT_GRP.ok_to_commit(
                             p_api_version   => 1,
                             p_init_msg_list => p_init_msg_list,
                             p_validation_string => p_validation_string,
                             p_doc_id        => p_doc_id,
                             x_return_status => x_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data
                           );

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'12900: AFter Calling  OKC_OKS_INT_GRP.ok_to_commit ');
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'13000: l_ok_to_commit : '||l_ok_to_commit);
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'13100: x_return_status : '||x_return_status);
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'13200: x_msg_count : '||x_msg_count);
      END IF;

      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;
--
     ELSIF l_doc_class = 'QUOTE' THEN

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'13300: Calling  OKC_ASO_INT_GRP.ok_to_commit');
      END IF;

         l_ok_to_commit := OKC_ASO_INT_GRP.ok_to_commit(
                             p_api_version   => 1,
                             p_init_msg_list => p_init_msg_list,
                             p_validation_string => p_validation_string,
                             p_doc_id        => p_doc_id,
                             p_doc_type      => p_doc_type,
                             x_return_status => x_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data
                           );

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'13400: AFter Calling  OKC_ASO_INT_GRP.ok_to_commit ');
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'13500: l_ok_to_commit : '||l_ok_to_commit);
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'13600: x_return_status : '||x_return_status);
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'13700: x_msg_count : '||x_msg_count);
      END IF;

      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;

--

      ELSIF l_doc_class = 'REPOSITORY' THEN

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'13800: Calling  OKC_REP_UTIL_PVT.ok_to_commit');
        END IF;

        l_ok_to_commit := OKC_REP_UTIL_PVT.ok_to_commit(
                           p_api_version   => 1,
                           p_init_msg_list => p_init_msg_list,
						   p_validation_string => p_validation_string,
                           p_doc_id        => p_doc_id,
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data);

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'13900: AFter Calling  OKC_REP_UTIL_PVT.ok_to_commit ');
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'14000: l_ok_to_commit : '||l_ok_to_commit);
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'14100: x_return_status : '||x_return_status);
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'14200: x_msg_count : '||x_msg_count);
        END IF;

        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR ;
        END IF;

     ELSE
      l_ok_to_commit := G_TRUE;
    END IF;
ELSE
    l_ok_to_commit := G_TRUE;
END IF;
END IF;

    IF l_ok_to_commit=FND_API.G_FALSE  THEN

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'13800: Issue with document header Record.Cannot commit');
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                         p_msg_name     => 'OKC_OK_TO_COMMIT'
                         );
     END IF;

     RETURN l_ok_to_commit;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'13900: Leaving ok_to_commit: OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      RETURN FND_API.G_FALSE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'14000: Leaving ok_to_commit: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      RETURN FND_API.G_FALSE;

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'14100: Leaving ok_to_commit because of EXCEPTION: '||sqlerrm);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      RETURN FND_API.G_FALSE;

  END ok_to_commit;

/*
--To be used to find out if a document has any manually added articles.
Returns FND_API.G_TRUE  => If atleast 1 article is manually added.
        FND_API.G_FALSE => If no manually added article exists.
*/

  FUNCTION is_manual_article_exist(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER
   ) RETURN VARCHAR2 IS
    l_api_version      CONSTANT NUMBER := 1;
    l_api_name         CONSTANT VARCHAR2(30) := 'is_manual_article_exist';
    l_dummy        VARCHAR2(1) := '?';
    l_return_value VARCHAR2(1) := FND_API.G_FALSE;

    CURSOR find_art_crs IS
     SELECT '!'
       FROM okc_k_articles_b kart
       WHERE kart.document_type=p_doc_type
       AND kart.document_id=p_doc_id
       AND kart.source_flag IS NULL
       AND nvl(kart.amendment_operation_code,'?')<>G_AMEND_CODE_DELETED
       AND nvl(kart.summary_amend_operation_code,'?')<>G_AMEND_CODE_DELETED;

   BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'14200: Entered is_manual_article_exist');
    END IF;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

    OPEN find_art_crs;
    FETCH find_art_crs INTO l_dummy;
    CLOSE find_art_crs;

    IF l_dummy='?' THEN
      l_return_value := FND_API.G_FALSE;
     ELSE
      l_return_value := FND_API.G_TRUE;
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'14300: Leaving is_manual_article_exist');
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    RETURN l_return_value ;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'14400: Leaving is_manual_article_exist : OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      RETURN NULL ;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'14500: Leaving is_manual_article_exist : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      RETURN NULL ;

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'14600: Leaving is_manual_article_exist because of EXCEPTION: '||sqlerrm);
      END IF;

      IF find_art_crs%ISOPEN THEN
        CLOSE find_art_crs;
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      RETURN NULL ;
  END is_manual_article_exist ;


  FUNCTION Get_Template_Name(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,
    p_template_id      IN  NUMBER,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER
  ) RETURN VARCHAR2 IS

    l_api_version      CONSTANT NUMBER := 1;
    l_api_name         CONSTANT VARCHAR2(30) := 'Get_Template_Name';
    l_return_value    VARCHAR2(500);

     CURSOR c_get_template_name IS
       SELECT template_name
       FROM   okc_terms_templates_all
       WHERE  template_id  =  p_template_id;
   BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'14700: Get_Template_Name');
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;


    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'14800: Opening cursor c_get_template_name');
    END IF;

    IF c_get_template_name%ISOPEN THEN
       CLOSE c_get_template_name;
    END IF;
    OPEN c_get_template_name;
    FETCH c_get_template_name INTO l_return_value;
    CLOSE c_get_template_name;


    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'14900: Result Get_Template_Name : ['||l_return_value||']');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'15000: Leaving Get_Template_Name');
    END IF;

    RETURN l_return_value ;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF c_get_template_name%ISOPEN THEN
        CLOSE c_get_template_name;
      END IF;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'15100: Leaving Get_Template_Name : OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      RETURN NULL ;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF c_get_template_name%ISOPEN THEN
        CLOSE c_get_template_name;
      END IF;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'15200: Leaving Get_Template_Name : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      RETURN NULL ;

    WHEN OTHERS THEN
      IF c_get_template_name%ISOPEN THEN
        CLOSE c_get_template_name;
      END IF;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'15300: Leaving Get_Template_Name because of EXCEPTION: '||sqlerrm);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      RETURN NULL ;


  END Get_Template_Name;


--This API is deprecated. Use GET_CONTRACT_DETAILS() instead.
    Function Get_Terms_Template(
    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER
  ) Return varchar2 IS
  l_template_name OKC_TERMS_TEMPLATES_ALL.TEMPLATE_NAME%TYPE;
  l_template_ID   OKC_TERMS_TEMPLATES_ALL.TEMPLATE_ID%TYPE;
  l_return_status  Varchar2(1);
  l_msg_count      NUMBER;
  l_msg_data       FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
  BEGIN
   Get_Terms_Template(p_api_version =>1,
                      p_init_msg_list => FND_API.G_FALSE,
                      x_return_status => l_return_status,
                      x_msg_count     => l_msg_count,
                      x_msg_data      => l_msg_data,
                      p_doc_type      => p_doc_type,
                      p_doc_id        => p_doc_id,
                      x_template_id   => l_template_id,
                      x_template_name => l_template_name);

      If l_return_status <>G_RET_STS_SUCCESS THEN
         l_template_name := NULL;
      END IF;
      return l_template_name;
 END Get_Terms_Template;

PROCEDURE get_item_dtl_for_expert(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER,
    x_category_tbl     OUT NOCOPY item_tbl_type,
    x_item_tbl         OUT NOCOPY item_tbl_type
  ) IS
    l_api_version      CONSTANT NUMBER := 1;
    l_api_name         CONSTANT VARCHAR2(30) := 'get_item_dtl_for_expert';
    l_doc_class        VARCHAR2(30) := '?';
    CURSOR doc_cls_lst_crs IS
      SELECT document_type_class
        FROM okc_bus_doc_types_b
        WHERE document_type=p_doc_type;
   BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'15400: Entered get_item_dtl_for_expert');
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;


    OPEN doc_cls_lst_crs;
    FETCH doc_cls_lst_crs INTO l_doc_class;
    CLOSE doc_cls_lst_crs;

    -- Based on Doc type call API's provided by different integrating system and pass the pl/sql table prepared ins tep 2.These API will check which variable has changed and return list of only those variables which have changed.
    -- For example: If document type is 'BPO' then call API provided by PO team.
                -- If document type is 'BSA' then call API provided by OM team.
    -- Parameter to these API's will be p_doc_id IN Number, p_var_tbl IN/OUT pl/sql table having one column variable_code

   IF l_doc_class in ('BSA','SO') THEN
   -- IF l_doc_class = 'OM' THEN

      OKC_OM_INT_GRP.get_item_dtl_for_expert (
                     p_api_version         => p_api_version ,
                     p_init_msg_list       => p_init_msg_list,
                     x_msg_data            => x_msg_data  ,
                     x_msg_count           => x_msg_count ,
                     x_return_status       => x_return_status,
                     p_doc_type            => p_doc_type,
                     p_doc_id              => p_doc_id,
                     x_category_tbl        => x_category_tbl,
                     x_item_tbl            => x_item_tbl
                                             );

      --------------------------------------------
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;
      --------------------------------------------

     ELSIF l_doc_class = 'PO' THEN


      OKC_PO_INT_GRP.get_item_dtl_for_expert(
        p_api_version         => p_api_version ,
        p_init_msg_list       => p_init_msg_list,
        x_msg_data            => x_msg_data  ,
        x_msg_count           => x_msg_count ,
        x_return_status       => x_return_status,
        p_doc_type            => p_doc_type,
        p_doc_id              => p_doc_id,
        x_item_tbl            => x_item_tbl,
        x_category_tbl        => x_category_tbl);

      --------------------------------------------
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;
      --------------------------------------------

     ELSIF l_doc_class = 'SOURCING' THEN

      OKC_PON_INT_GRP.get_item_dtl_for_expert(
                      p_api_version         => p_api_version,
                      p_init_msg_list       => p_init_msg_list,
                      x_msg_data            => x_msg_data  ,
                      x_msg_count           => x_msg_count ,
                      x_return_status       => x_return_status,
                      p_doc_type            => p_doc_type,
                      p_doc_id              => p_doc_id,
                      x_item_tbl            => x_item_tbl,
                      x_category_tbl        => x_category_tbl);

      --------------------------------------------
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;
      --------------------------------------------
      ELSIF l_doc_class = 'QUOTE' THEN

      OKC_ASO_INT_GRP.get_item_dtl_for_expert(
                      p_api_version         => p_api_version,
                      p_init_msg_list       => p_init_msg_list,
                      x_msg_data            => x_msg_data  ,
                      x_msg_count           => x_msg_count ,
                      x_return_status       => x_return_status,
                     -- p_doc_type            => p_doc_type,
                      p_doc_id              => p_doc_id,
                      x_item_tbl            => x_item_tbl,
                      x_category_tbl        => x_category_tbl);

      --------------------------------------------
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;
      --------------------------------------------
     ELSE
      NULL;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'15500: Leaving get_item_dtl_for_expert');
    END IF;
   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'15600: Leaving get_item_dtl_for_expert : OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'15700: Leaving get_item_dtl_for_expert : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'15800: Leaving get_item_dtl_for_expert because of EXCEPTION: '||sqlerrm);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  END get_item_dtl_for_expert;

  FUNCTION get_last_signed_revision(
    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER,
    p_revision_num           IN NUMBER
  ) RETURN NUMBER
  IS
    l_api_version      CONSTANT NUMBER := 1;
    l_api_name         CONSTANT VARCHAR2(30) := 'get_last_signed_revision';
    l_doc_class        VARCHAR2(30) := '?';
    l_signed_version   NUMBER;
    l_msg_count        NUMBER;
    l_msg_data         FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
    l_return_status    VARCHAR2(1);

    CURSOR doc_cls_lst_crs IS
      SELECT document_type_class
        FROM okc_bus_doc_types_b
        WHERE document_type=p_doc_type;
   BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'15900: Entered get_last_signed_revision');
    END IF;


    OPEN doc_cls_lst_crs;
    FETCH doc_cls_lst_crs INTO l_doc_class;
    CLOSE doc_cls_lst_crs;

    -- Based on Doc type call API's provided by different integrating system and pass the pl/sql table prepared ins tep 2.These API will check which variable has changed and return list of only those variables which have changed.
    -- For example: If document type is 'BPO' then call API provided by PO team.
                -- If document type is 'BSA' then call API provided by OM team.
    -- Parameter to these API's will be p_doc_id IN Number, p_var_tbl IN/OUT pl/sql table having one column variable_code

    IF  l_doc_class = 'PO' THEN


      OKC_PO_INT_GRP.get_last_signed_revision(
        p_api_version         => 1 ,
        p_init_msg_list       => FND_API.G_FALSE,
        x_msg_data            => l_msg_data  ,
        x_msg_count           => l_msg_count ,
        x_return_status       => l_return_status,

        p_doc_type            => p_doc_type,
        p_doc_id              => p_doc_id,
        p_revision_num        => p_revision_num,
        x_signed_revision_num => l_signed_version);

      --------------------------------------------
      IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;
      --------------------------------------------

    ELSE
      NULL;
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'16000: Leaving get_last_signed_revision');
    END IF;
   RETURN l_signed_version;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'16100: Leaving  get_last_signed_revision : OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      return NULL;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'16200: Leaving get_last_signed_revision : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      return NULL;

    WHEN OTHERS THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'16300: Leaving get_last_signed_revision because of EXCEPTION: '||sqlerrm);
      END IF;
      return NULL;
END get_last_signed_revision;


Procedure Get_Terms_Template_dtl(
     p_template_id           IN  NUMBER,
     p_template_rec          OUT NOCOPY template_rec_type,
     x_return_status    OUT NOCOPY VARCHAR2,
     x_msg_data         OUT NOCOPY VARCHAR2,
     x_msg_count        OUT NOCOPY NUMBER
  ) IS

  l_api_version      CONSTANT NUMBER := 1;
  l_api_name         CONSTANT VARCHAR2(30) := 'Get_Terms_Template_dtl';
  CURSOR l_get_template_dtl(b_template_id NUMBER) IS
  SELECT template_name,
    intent,
    status_code,
    start_date,
    end_date ,
    instruction_text ,
    description ,
    global_flag ,
    contract_expert_enabled,
    org_id
    FROM okc_terms_templates_all
    where template_id=b_template_id;
  BEGIN
      x_return_status := G_RET_STS_SUCCESS;
     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'16400: Entered Get_Terms_Template_dtl');
    END IF;
    OPEN l_get_template_dtl(p_template_id);
    FETCH l_get_template_dtl into p_template_rec.template_name,
                                  p_template_rec.intent,
                                  p_template_rec.status_code,
                                  p_template_rec.start_date,
                                  p_template_rec.end_date,
                                  p_template_rec.instruction_text,
                                  p_template_rec.description,
                                  p_template_rec.global_flag,
                                  p_template_rec.contract_expert_enabled,
                                  p_template_rec.org_id;
     IF l_get_template_dtl%NOTFOUND THEN
               Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                                   p_msg_name     => 'OKC_WRONG_TEMPLATE'
                         );
               Raise FND_API.G_EXC_ERROR;
     END IF;
     CLOSE l_get_template_dtl;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'16500: Leaving Get_Terms_Template_dtl');
    END IF;
   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'16600: Leaving Get_Terms_Template_dtl : OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      IF l_get_template_dtl%ISOPEN THEN
         CLOSE l_get_template_dtl;
      END IF;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'16700: Leaving Get_Terms_Template_dtl : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      IF l_get_template_dtl%ISOPEN THEN
         CLOSE l_get_template_dtl;
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'16800: Leaving Get_Terms_Template_dtl because of EXCEPTION: '||sqlerrm);
      END IF;
      IF l_get_template_dtl%ISOPEN THEN
         CLOSE l_get_template_dtl;
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END Get_Terms_Template_dtl;

FUNCTION empclob
RETURN CLOB IS
 c1 CLOB;
BEGIN
    DBMS_LOB.CREATETEMPORARY(c1,true);
    DBMS_LOB.OPEN(c1,dbms_lob.lob_readwrite);
    DBMS_LOB.WRITE(c1,1,1,' ');
    RETURN c1;
END empclob;

FUNCTION tempblob
RETURN BLOB IS
 c1 BLOB;
  rawbuf RAW(10);
  BEGIN
      rawbuf := '1234567890123456789';

      DBMS_LOB.CREATETEMPORARY(c1,true);
	 DBMS_LOB.OPEN(c1,dbms_lob.lob_readwrite);
	 DBMS_LOB.WRITE(c1,1,10,rawbuf);
	   RETURN c1;
 END tempblob;

--This API is deprecated. Use GET_CONTRACT_DETAILS_ALL() instead.
Procedure Get_Terms_Template_dtl(
     p_doc_id               IN  NUMBER,
     p_doc_type             IN  VARCHAR,
        x_template_id          OUT NOCOPY NUMBER,
     x_template_name        OUT NOCOPY VARCHAR2,
     x_template_description OUT NOCOPY VARCHAR2,
     x_template_instruction OUT NOCOPY VARCHAR2,
     x_return_status        OUT NOCOPY VARCHAR2,
     x_msg_data             OUT NOCOPY VARCHAR2,
     x_msg_count            OUT NOCOPY NUMBER
  ) IS

  l_api_version      CONSTANT NUMBER := 1;
  l_api_name         CONSTANT VARCHAR2(30) := 'Get_Terms_Template_dtl';

 CURSOR terms_tmpl_csr IS
     SELECT t.template_id,
            t.template_name,
            t.instruction_text ,
            t.description
     FROM okc_template_usages_v tu, okc_terms_templates_all t
     WHERE tu.document_type = p_doc_type AND tu.document_id = p_doc_id
     AND t.template_id = tu.template_id;

BEGIN
      x_return_status := G_RET_STS_SUCCESS;
     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'16900: Entered Get_Terms_Template_dtl');
    END IF;
    OPEN terms_tmpl_csr;
    FETCH terms_tmpl_csr into     x_template_id,
                                  x_template_name,
                                  x_template_instruction,
                                  x_template_description ;

     CLOSE terms_tmpl_csr;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'17000: Leaving Get_Terms_Template_dtl');
    END IF;
   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'17100: Leaving Get_Terms_Template_dtl : OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      IF terms_tmpl_csr%ISOPEN THEN
         CLOSE terms_tmpl_csr;
      END IF;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'17200: Leaving Get_Terms_Template_dtl : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      IF terms_tmpl_csr%ISOPEN THEN
         CLOSE terms_tmpl_csr;
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'17300: Leaving Get_Terms_Template_dtl because of EXCEPTION: '||sqlerrm);
      END IF;
      IF terms_tmpl_csr%ISOPEN THEN
         CLOSE terms_tmpl_csr;
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END Get_Terms_Template_dtl;

FUNCTION enable_update(
  p_object_type    IN VARCHAR2,
  p_document_type  IN VARCHAR2,
  p_standard_yn    IN VARCHAR2
 ) RETURN VARCHAR2 IS
   l_api_name         CONSTANT VARCHAR2(30) := 'enable_update';
BEGIN
   IF (p_object_type <> 'SECTION' AND p_object_type <> 'ARTICLE') THEN
      -- top most document node , always disable
      RETURN 'OkcTermsStructDtlsUpdateDisabled' ;
   ELSIF p_object_type = 'SECTION' THEN
     -- update always enabled for Sections
      RETURN 'OkcTermsStructDtlsUpdateEnabled' ;
     -- Article Cases
   ELSIF  p_document_type = 'TEMPLATE' THEN
      -- always disable for template as the logic is based on template status and is in the controller code
      RETURN 'OkcTermsStructDtlsUpdateDisabled';
   ELSIF  NVL(p_standard_yn,'N') = 'Y' THEN
      -- update always enabled for standard articles
      RETURN 'OkcTermsStructDtlsUpdateEnabled' ;
      -- non std articles
   ELSIF fnd_function.test('OKC_TERMS_AUTHOR_NON_STD','N') THEN
      -- user has access to fn and doc not template
      RETURN 'OkcTermsStructDtlsUpdateEnabled' ;
   ELSE
     -- user does NOT have access to function OKC_TERMS_AUTHOR_NON_STD
     RETURN 'OkcTermsStructDtlsUpdateDisabled' ;
   END IF;
EXCEPTION
 WHEN OTHERS THEN
   IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2000: Leaving enable_update because of EXCEPTION: '||sqlerrm);
   END IF;
 RETURN NULL;
END enable_update;

FUNCTION enable_delete(
  p_object_type    IN VARCHAR2,
  p_mandatory_yn   IN VARCHAR2,
  p_standard_yn    IN VARCHAR2,
  p_document_type  IN VARCHAR2
 ) RETURN VARCHAR2 IS
l_api_name         CONSTANT VARCHAR2(30) := 'enable_delete';
BEGIN
   IF (p_object_type <> 'SECTION' AND p_object_type <> 'ARTICLE') THEN
        -- topmost document node, so disable delete
        RETURN 'OkcTermsStructDtlsRemoveDisabled';
   ELSIF p_object_type = 'SECTION' THEN
        -- Delete always enabled for sections as the API validates for mandatory articles check
        RETURN 'OkcTermsStructDtlsRemoveEnabled' ;
        --  ARTICLES LOGIC
        --  Case 1: MANDATORY ARTICLES
   ELSIF NVL(p_mandatory_yn,'N') = 'Y' THEN
        -- article is mandatory
        --Bug 4123003 If doc_type is template, delete button should be enabled
        IF  p_document_type = 'TEMPLATE' THEN
            RETURN 'OkcTermsStructDtlsRemoveEnabled';
        ELSE
           IF (fnd_function.test('OKC_TERMS_AUTHOR_NON_STD','N') AND
               fnd_function.test('OKC_TERMS_AUTHOR_SUPERUSER','N')) THEN
               -- user has override controls, allow delete mandatory
             RETURN 'OkcTermsStructDtlsRemoveEnabled';
           ELSE
             RETURN 'OkcTermsStructDtlsRemoveDisabled';
           END IF;
        END IF;
        --  Case 2: STANDARD ARTICLES (non-mandatory)
   ELSIF NVL(p_standard_yn,'N') = 'Y' THEN
        -- for standard articles delete is always allowed
        RETURN 'OkcTermsStructDtlsRemoveEnabled' ;
        --  Case 3: NON-STANDARD ARTICLES (non-mandatory)
   ELSIF fnd_function.test('OKC_TERMS_AUTHOR_NON_STD','N') THEN
        -- for non-std articles check for function security
        -- user has access , so check allow delete for non-std articles
        RETURN 'OkcTermsStructDtlsRemoveEnabled' ;
   ELSE
        -- user does not have access to delete non-std articles
        RETURN 'OkcTermsStructDtlsRemoveDisabled';
   END IF;

EXCEPTION
 WHEN OTHERS THEN
   IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2000: Leaving enable_delete because of EXCEPTION: '||sqlerrm);
   END IF;
 RETURN NULL;
END enable_delete;



/* Following API's are added for 11.5.10+ projects*/


-- Returns 'Y' - Attached document is oracle generated and mergeable.
--         'N' - Non recognised format, non mergeable.
--         'E' - Error.
FUNCTION Is_Primary_Terms_Doc_Mergeable(
    p_document_type         IN  VARCHAR2,
    p_document_id           IN  NUMBER
) RETURN VARCHAR2 IS
l_api_name         CONSTANT VARCHAR2(30) := 'Is_Primary_Terms_Doc_Mergeable';
BEGIN
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1800: Entering Is_Primary_Terms_Doc_Mergeable');
   END IF;

   RETURN OKC_CONTRACT_DOCS_GRP.is_primary_terms_doc_mergeable(
                                    p_document_type => p_document_type,
                                    p_document_id   => p_document_id  );

EXCEPTION
 WHEN OTHERS THEN
   IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2000: Leaving Is_Primary_Terms_Doc_Mergeable because of EXCEPTION: '||sqlerrm);
   END IF;
 RETURN 'E';
END Is_Primary_Terms_Doc_Mergeable;

-- Returns FND_DOCUMENTS_TL.media_id of the Primary contract file for the current version of the document if it is non mergeable.
-- 0 if document is mergeable.
-- -1 if no primary document exists.
FUNCTION Get_Primary_Terms_Doc_File_Id(
  p_document_type    IN VARCHAR2,
  p_document_id      IN  NUMBER
 ) RETURN NUMBER IS
l_api_name         CONSTANT VARCHAR2(30) := 'Get_Primary_Terms_Doc_File_Id';
BEGIN
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1800: Entering Get_Primary_Terms_Doc_File_Id');
   END IF;

   RETURN OKC_CONTRACT_DOCS_GRP.get_primary_terms_doc_file_id(
                                    p_document_type => p_document_type,
                                    p_document_id   => p_document_id  );

EXCEPTION
 WHEN OTHERS THEN
   IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2000: Leaving Get_Primary_Terms_Doc_File_Id because of EXCEPTION: '||sqlerrm);
   END IF;
 RETURN -1;
END Get_Primary_Terms_Doc_File_Id;

-- Returns 'Y' - Document has terms.
--         'N' - No template instantiated. Primary contract file not attached.
FUNCTION Has_Terms(
  p_document_type    IN VARCHAR2,
  p_document_id      IN  NUMBER
 ) RETURN VARCHAR2 IS
l_api_name         CONSTANT VARCHAR2(30) := 'Has_Terms';
 CURSOR tmpl_usages_csr IS
     SELECT 'Y'
     FROM okc_template_usages
     WHERE document_type = p_document_type
       AND document_id = p_document_id;

  l_value VARCHAR2(1);

BEGIN
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1800: Entering Has_Terms');
   END IF;
    OPEN tmpl_usages_csr ;
    FETCH tmpl_usages_csr  into  l_value;
    CLOSE tmpl_usages_csr ;
    IF l_value = 'Y' THEN
      RETURN 'Y';
    ELSE
      RETURN 'N';
    END IF;
EXCEPTION
 WHEN OTHERS THEN
   IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2000: Leaving Has_Terms of EXCEPTION: '||sqlerrm);
   END IF;
 RETURN 'E';
END Has_Terms;


-- Returns 'Y' - Document has a template instantiated, or terms are in attached primary contract file.
--         'N' - No template instantiated. Primary contract file not attached.
FUNCTION Has_Valid_Terms(
  p_document_type    IN VARCHAR2,
  p_document_id      IN  NUMBER
 ) RETURN VARCHAR2 IS
l_api_name         CONSTANT VARCHAR2(30) := 'Has_Valid_Terms';
 CURSOR tmpl_usages_csr IS
     SELECT contract_source_code
     FROM okc_template_usages
     WHERE document_type = p_document_type
       AND document_id = p_document_id;

  l_contract_source_code OKC_TEMPLATE_USAGES.CONTRACT_SOURCE_CODE%TYPE;
  l_rownotfound BOOLEAN := FALSE;
BEGIN
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1800: Entering Has_Valid_Terms');
   END IF;
    OPEN tmpl_usages_csr ;
    FETCH tmpl_usages_csr  into  l_contract_source_code;
    l_rownotfound := tmpl_usages_csr%NOTFOUND;
    CLOSE tmpl_usages_csr ;

    IF l_rownotfound THEN
      RETURN 'N';
    ELSIF l_contract_source_code = 'STRUCTURED' THEN
      RETURN 'Y';
    ELSIF l_contract_source_code = 'ATTACHED' THEN
      RETURN OKC_CONTRACT_DOCS_GRP.has_primary_contract_doc(
                                      p_document_type => p_document_type,
                                      p_document_id   => p_document_id);
    ELSE
      RETURN 'N';
    END IF;

EXCEPTION
 WHEN OTHERS THEN
   IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2000: Leaving Has_Valid_Terms of EXCEPTION: '||sqlerrm);
   END IF;
 RETURN 'E';
END Has_Valid_Terms;


--Returns name of the authoring party, source type of the contract and the template name if a template has been instantiated.
Procedure Get_Contract_Details(
    p_api_version           IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 ,

    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_data              OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,

    p_document_type         IN  VARCHAR2,
    p_document_id           IN  NUMBER,

    x_authoring_party       OUT NOCOPY VARCHAR2,
    x_contract_source       OUT NOCOPY VARCHAR2,
    x_template_name         OUT NOCOPY VARCHAR2,
    x_template_description  OUT NOCOPY VARCHAR2
  ) IS

  l_api_version      CONSTANT NUMBER := 1;
  l_api_name         CONSTANT VARCHAR2(30) := 'Get_Contract_Details';
  l_tmpl_name        OKC_TERMS_TEMPLATES_ALL.TEMPLATE_NAME%TYPE;
  l_template_desc    OKC_TERMS_TEMPLATES_ALL.DESCRIPTION%TYPE;
  l_template_id      OKC_TERMS_TEMPLATES_ALL.TEMPLATE_ID%TYPE;
  l_document_id      OKC_TEMPLATE_USAGES.DOCUMENT_ID%TYPE;
  l_authoring_party_code  OKC_TEMPLATE_USAGES.AUTHORING_PARTY_CODE%TYPE;
  l_contract_source_code  OKC_TEMPLATE_USAGES.CONTRACT_SOURCE_CODE%TYPE;
  l_authoring_party       OKC_RESP_PARTIES_TL.ALTERNATE_NAME%TYPE;
  l_contract_source       FND_LOOKUPS.MEANING%TYPE;

 CURSOR terms_tmpl_csr IS
  SELECT tu.document_id,
         tu.authoring_party_code,
            tu.contract_source_code,
            tu.template_id,
            t.template_name,
            t.description,
            party.alternate_name authoring_party,
            src.meaning contract_source
  FROM OKC_TEMPLATE_USAGES tu,
       OKC_TERMS_TEMPLATES_ALL t,
       okc_resp_parties_vl party,
       okc_bus_doc_types_b doc,
          fnd_lookups src
  WHERE t.template_id(+) = tu.template_id
  AND tu.authoring_party_code = party.resp_party_code
  AND tu.document_type = doc.document_type
  AND doc.document_type_class = party.document_type_class
  AND NVL(doc.intent,'zzz') = NVL(party.intent,'zzz')
  AND src.lookup_type = 'OKC_CONTRACT_TERMS_SOURCES'
  AND src.lookup_code = tu.contract_source_code
  AND tu.document_type = p_document_type
  AND tu.document_id = p_document_id;

BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'15400: Entered Get_Contract_Details');
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

    OPEN terms_tmpl_csr;
    FETCH terms_tmpl_csr INTO l_document_id,l_authoring_party_code,l_contract_source_code,l_template_id,l_tmpl_name,l_template_desc,l_authoring_party,l_contract_source;
    CLOSE terms_tmpl_csr;

    IF l_document_id IS NOT NULL THEN
      x_authoring_party := l_authoring_party;
      x_contract_source := l_contract_source;
      IF l_template_id IS NOT NULL THEN
         x_template_name   := l_tmpl_name;
         x_template_description := l_template_desc;
      ELSE
         fnd_message.set_name('OKC','OKC_TERMS_TEMPLATE_NAME_NONE');
         x_template_name:= fnd_message.get;
         x_template_description := NULL;
      END IF;
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'16200: Return success Get_Contract_Details');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'16300: x_authoring_party:'||x_authoring_party);
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'16400: x_contract_source:'||x_contract_source);
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'16500: x_template_name:'||x_template_name);
      END IF;
    ELSE
      fnd_message.set_name('OKC','OKC_TERMS_AUTH_PARTY_NONE');
      x_authoring_party := fnd_message.get;
      fnd_message.set_name('OKC','OKC_TERMS_CONTRACT_SOURCE_NONE');
      x_contract_source := fnd_message.get;
      fnd_message.set_name('OKC','OKC_TERMS_TEMPLATE_NAME_NONE');
      x_template_name:= fnd_message.get;
      x_template_description := NULL;
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'16600: Return Get_Contract_Details,no terms exist');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'16700: x_authoring_party:'||x_authoring_party);
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'16800: x_contract_source:'||x_contract_source);
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'16900: x_template_name:'||x_template_name);
      END IF;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'17000: Leaving Get_Contract_Details');
    END IF;
   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'17100: Leaving Get_Contract_Details : OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
       x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'17200: Leaving Get_Contract_Details : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'17300: Leaving Get_Contract_Details because of EXCEPTION: '||sqlerrm);
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END Get_Contract_Details;

--Returns terms details for the document.
Procedure Get_Contract_Details_All(
    p_api_version           IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 ,

    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_data              OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,

    p_document_type         IN  VARCHAR2,
    p_document_id           IN  NUMBER,
    p_document_version      IN  NUMBER := NULL,

    x_has_terms                 OUT NOCOPY  VARCHAR2,
    x_authoring_party_code      OUT NOCOPY  VARCHAR2,
    x_authoring_party           OUT NOCOPY  VARCHAR2,
    x_contract_source_code      OUT NOCOPY  VARCHAR2,
    x_contract_source           OUT NOCOPY  VARCHAR2,
    x_template_id               OUT NOCOPY  NUMBER,
    x_template_name             OUT NOCOPY  VARCHAR2,
    x_template_description      OUT NOCOPY  VARCHAR2,
    x_template_instruction      OUT NOCOPY  VARCHAR2,
    x_has_primary_doc           OUT NOCOPY  VARCHAR2,
    x_is_primary_doc_mergeable  OUT NOCOPY  VARCHAR2,
    x_primary_doc_file_id       OUT NOCOPY  VARCHAR2
  ) IS

  l_api_version      CONSTANT NUMBER := 1;
  l_api_name         CONSTANT VARCHAR2(30) := 'Get_Contract_Details_All';
  l_tmpl_name        OKC_TERMS_TEMPLATES_ALL.TEMPLATE_NAME%TYPE;
  l_template_desc    OKC_TERMS_TEMPLATES_ALL.DESCRIPTION%TYPE;
  l_instruction      OKC_TERMS_TEMPLATES_ALL.INSTRUCTION_TEXT%TYPE;
  l_template_id      OKC_TEMPLATE_USAGES.TEMPLATE_ID%TYPE;
  l_document_id      OKC_TEMPLATE_USAGES.DOCUMENT_ID%TYPE := NULL;
  l_authoring_party_code  OKC_TEMPLATE_USAGES.AUTHORING_PARTY_CODE%TYPE;
  l_contract_source_code  OKC_TEMPLATE_USAGES.CONTRACT_SOURCE_CODE%TYPE;
  l_generated_flag         VARCHAR2(1) := '?';
  l_media_id               FND_DOCUMENTS_TL.MEDIA_ID%TYPE := -1;
  l_authoring_party       OKC_RESP_PARTIES_TL.ALTERNATE_NAME%TYPE;
  l_contract_source       FND_LOOKUPS.MEANING%TYPE;

  CURSOR terms_tmpl_csr IS
    SELECT tu.document_id,
           tu.authoring_party_code,
           tu.contract_source_code,
           tu.template_id,
           t.template_name,
           t.description,
           t.instruction_text,
           party.alternate_name authoring_party,
           src.meaning contract_source
    FROM OKC_TEMPLATE_USAGES tu,
         OKC_TERMS_TEMPLATES_ALL t,
         okc_resp_parties_vl party,
         okc_bus_doc_types_b doc,
         fnd_lookups src
    WHERE t.template_id(+) = tu.template_id
    AND tu.authoring_party_code = party.resp_party_code
    AND tu.document_type = doc.document_type
    AND doc.document_type_class = party.document_type_class
    AND NVL(doc.intent,'zzz') = NVL(party.intent,'zzz')
    AND src.lookup_type = 'OKC_CONTRACT_TERMS_SOURCES'
    AND src.lookup_code = tu.contract_source_code
    AND tu.document_type = p_document_type
    AND tu.document_id = p_document_id;

  CURSOR contract_doc_csr IS
     SELECT tl.media_id ,
            docs.generated_flag
     FROM  OKC_CONTRACT_DOCS docs, FND_ATTACHED_DOCUMENTS fnd,FND_DOCUMENTS_TL tl
     WHERE docs.primary_contract_doc_flag = 'Y'
       AND docs.business_document_version=-99
       AND docs.business_document_type = p_document_type
       AND docs.business_document_id = p_document_id
       AND docs.attached_document_id = fnd.attached_document_id
       AND fnd.document_id = tl.document_id
       AND tl.language = USERENV('LANG');

--Bug 4131467 Added cursor to fetch contract details from history table if document_version is passed
  CURSOR terms_tmpl_ver_csr IS
    SELECT tu.document_id,
           tu.authoring_party_code,
           tu.contract_source_code,
           tu.template_id,
           t.template_name,
           t.description,
           t.instruction_text,
           party.alternate_name authoring_party,
           src.meaning contract_source
    FROM OKC_TEMPLATE_USAGES_H tu,
         OKC_TERMS_TEMPLATES_ALL t,
         okc_resp_parties_vl party,
         okc_bus_doc_types_b doc,
         fnd_lookups src
    WHERE t.template_id(+) = tu.template_id
    AND tu.authoring_party_code = party.resp_party_code
    AND tu.document_type = doc.document_type
    AND doc.document_type_class = party.document_type_class
    AND NVL(doc.intent,'zzz') = NVL(party.intent,'zzz')
    AND src.lookup_type = 'OKC_CONTRACT_TERMS_SOURCES'
    AND src.lookup_code = tu.contract_source_code
    AND tu.document_type = p_document_type
    AND tu.document_id = p_document_id
    AND tu.major_version = p_document_version;

--Bug 4131467 Added cursor to fetch attachment details from history table if document_version is passed
  CURSOR contract_doc_ver_csr IS
     SELECT tl.media_id ,
            docs.generated_flag
     FROM  OKC_CONTRACT_DOCS docs, FND_ATTACHED_DOCUMENTS fnd,FND_DOCUMENTS_TL tl
     WHERE docs.primary_contract_doc_flag = 'Y'
       AND docs.business_document_version = p_document_version
       AND docs.business_document_type = p_document_type
       AND docs.business_document_id = p_document_id
       AND docs.attached_document_id = fnd.attached_document_id
       AND fnd.document_id = tl.document_id
       AND tl.language = USERENV('LANG');

BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'15400: Entered Get_Contract_Details_All');
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;


    --Initialising values to false/notfound.
    x_primary_doc_file_id := -1;
    x_has_primary_doc     := 'N';
    x_is_primary_doc_mergeable := 'N';

    IF p_document_version is not NULL THEN
       --Doc version has been specified, fetch from history tables.
       OPEN  terms_tmpl_ver_csr;
       FETCH terms_tmpl_ver_csr INTO l_document_id,l_authoring_party_code,
             l_contract_source_code,l_template_id,l_tmpl_name,l_template_desc,l_instruction,l_authoring_party,l_contract_source;
       IF terms_tmpl_ver_csr%NOTFOUND THEN
         --fallback to latest version if not found.
         OPEN  terms_tmpl_csr;
         FETCH terms_tmpl_csr INTO l_document_id,l_authoring_party_code,
               l_contract_source_code,l_template_id,l_tmpl_name,l_template_desc,l_instruction,l_authoring_party,l_contract_source;
         CLOSE terms_tmpl_csr;
       END IF;
       CLOSE terms_tmpl_ver_csr;
    ELSE
       --Fetch data from latest version.
       OPEN  terms_tmpl_csr;
       FETCH terms_tmpl_csr INTO l_document_id,l_authoring_party_code,
             l_contract_source_code,l_template_id,l_tmpl_name,l_template_desc,l_instruction,l_authoring_party,l_contract_source;
       CLOSE terms_tmpl_csr;
    END IF;

    IF l_document_id IS NOT NULL THEN  --template_usages record exists
       x_has_terms := 'Y';
    ELSE
       x_has_terms := 'N';
    END IF;

    x_authoring_party_code := l_authoring_party_code;
    x_contract_source_code := l_contract_source_code;
    x_template_id := l_template_id;

       IF x_has_terms = 'Y' THEN
	        --OKC_CONTRACT_DOCS_GRP.Get_Primary_Terms_Doc_File_Id logic has been substituted inline to improve performance.
	    IF p_document_version is not NULL THEN
            --Doc version has been specified, fetch from history tables.
   --  Fix for bug# 4282242. The following block of code was missing in previous checkin 115.42.11510.11 .
            OPEN  contract_doc_ver_csr;
            FETCH contract_doc_ver_csr INTO x_primary_doc_file_id, l_generated_flag;
            IF contract_doc_ver_csr%NOTFOUND THEN
	           --fallback to latest version if not found.
	            OPEN  contract_doc_csr;
	            FETCH contract_doc_csr INTO x_primary_doc_file_id,l_generated_flag;
	            CLOSE contract_doc_csr;
	       END IF;
	       CLOSE contract_doc_ver_csr;
	    ELSE
	       --Fetch data from latest version.
	       OPEN  contract_doc_csr;
	       FETCH contract_doc_csr INTO x_primary_doc_file_id, l_generated_flag;
	       CLOSE contract_doc_csr;
	    END IF;
    -- End of fix for bug# 4282242.

      IF x_primary_doc_file_id = -1 THEN  --if row not found
          x_has_primary_doc := 'N';
      ELSE
          x_has_primary_doc := 'Y';
      END IF;

      IF l_generated_flag = 'Y' THEN
        x_primary_doc_file_id := 0;
        x_is_primary_doc_mergeable := 'Y';
      END IF;

      x_authoring_party := l_authoring_party;
      x_contract_source := l_contract_source;
      IF l_template_id IS NOT NULL THEN
         x_template_name   := l_tmpl_name;
         x_template_description := l_template_desc;
         x_template_instruction := l_instruction;
      ELSE
         fnd_message.set_name('OKC','OKC_TERMS_TEMPLATE_NAME_NONE');
         x_template_name:= fnd_message.get;
         x_template_description := NULL;
         x_template_instruction := NULL;
      END IF;
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'16200: Return success Get_Contract_Details');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'16300: x_authoring_party:'||x_authoring_party);
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'16400: x_contract_source:'||x_contract_source);
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'16500: x_template_name:'||x_template_name);
      END IF;

    ELSE
      fnd_message.set_name('OKC','OKC_TERMS_AUTH_PARTY_NONE');
      x_authoring_party := fnd_message.get;
      fnd_message.set_name('OKC','OKC_TERMS_CONTRACT_SOURCE_NONE');
      x_contract_source := fnd_message.get;
      fnd_message.set_name('OKC','OKC_TERMS_TEMPLATE_NAME_NONE');
      x_template_name:= fnd_message.get;
      x_template_description := NULL;
      x_template_instruction := NULL;
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'16600: Return Get_Contract_Details,no terms exist');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'16700: x_authoring_party:'||x_authoring_party);
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'16800: x_contract_source:'||x_contract_source);
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'16900: x_template_name:'||x_template_name);
      END IF;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'17000: Leaving Get_Contract_Details_All');
    END IF;
   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'17100: Leaving Get_Contract_Details_All : OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
       x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'17200: Leaving Get_Contract_Details_All : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'17300: Leaving Get_Contract_Details_All because of EXCEPTION: '||sqlerrm);
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END Get_Contract_Details_All;

-- Returns  AUTHORING_PARTY_CODE for the document
--         'E' - for error
FUNCTION Get_Authoring_Party_Code(
  p_document_type    IN VARCHAR2,
  p_document_id      IN  NUMBER
 ) RETURN VARCHAR2 IS
 l_api_name         CONSTANT VARCHAR2(30) := 'Get_Authoring_Party_Code';
 CURSOR tmpl_usages_csr IS
     SELECT authoring_party_code
     FROM okc_template_usages
     WHERE document_type = p_document_type
       AND document_id = p_document_id;

  l_authoring_party_code OKC_TEMPLATE_USAGES.AUTHORING_PARTY_CODE%TYPE;

BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1800: Entering Get_Authoring_Party_Code ');
    END IF;
    OPEN tmpl_usages_csr ;
    FETCH tmpl_usages_csr  into  l_authoring_party_code;
    CLOSE tmpl_usages_csr ;

    RETURN l_authoring_party_code;

EXCEPTION
 WHEN OTHERS THEN
   IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2000: Leaving Get_Authoring_Party_Code of EXCEPTION: '||sqlerrm);
   END IF;
 RETURN 'E';
END Get_Authoring_Party_Code;


-- Returns  CONTRACT_SOURCE_CODE for the document
--         'E' - for error.
FUNCTION Get_Contract_Source_Code(
  p_document_type    IN VARCHAR2,
  p_document_id      IN  NUMBER
 ) RETURN VARCHAR2 IS
l_api_name         CONSTANT VARCHAR2(30) := 'Get_Contract_Source_Code';
 CURSOR tmpl_usages_csr IS
     SELECT contract_source_code
     FROM okc_template_usages
     WHERE document_type = p_document_type
       AND document_id = p_document_id;

  l_contract_source_code OKC_TEMPLATE_USAGES.CONTRACT_SOURCE_CODE%TYPE;

BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1800: Entering Get_Contract_Source_Code ');
    END IF;
    OPEN tmpl_usages_csr ;
    FETCH tmpl_usages_csr  into  l_contract_source_code;
    CLOSE tmpl_usages_csr ;

    RETURN l_contract_source_code;

EXCEPTION
 WHEN OTHERS THEN
   IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2000: Leaving Get_Contract_Source_Code of EXCEPTION: '||sqlerrm);
   END IF;
 RETURN 'E';
END Get_Contract_Source_Code;

--Returns 'Y' if the template is approved, within validity range, and is applicable to the given
--document type and org id.
--Else returns 'N'.
FUNCTION Is_Terms_Template_Valid(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_template_id      IN  NUMBER,
    p_doc_type         IN  VARCHAR2,
    p_org_id           IN  NUMBER,
    p_valid_date       IN  DATE DEFAULT SYSDATE
  ) RETURN VARCHAR2 IS

 CURSOR terms_tmpl_csr IS
  SELECT 'Y'
  FROM OKC_TERMS_TEMPLATES_ALL tmpl,
       OKC_ALLOWED_TMPL_USAGES usg,
       OKC_BUS_DOC_TYPES_B doc
  WHERE tmpl.template_id = p_template_id
  AND   doc.document_type = p_doc_type
  AND   doc.intent = tmpl.intent
  AND   usg.template_id = tmpl.template_id
  AND   usg.document_type = p_doc_type
  AND   tmpl.status_code = 'APPROVED'
  AND   tmpl.org_id = p_org_id
  AND   p_valid_date between tmpl.start_date and nvl(tmpl.end_date,p_valid_date);

  l_api_version      CONSTANT NUMBER := 1;
  l_api_name         CONSTANT VARCHAR2(30) := 'Is_Terms_Template_Valid';
  l_result           VARCHAR2(1) := 'N';

BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'6900: Entered Is_Terms_Template_Valid');
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

    OPEN  terms_tmpl_csr;
    FETCH terms_tmpl_csr INTO l_result;
    CLOSE terms_tmpl_csr;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7000: Result Is_Terms_Template_Valid? : ['||l_result||']');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7100: Leaving Is_Terms_Template_Valid');
    END IF;

    IF l_result = 'Y' THEN
       RETURN 'Y';
    ELSE
       RETURN 'N';
    END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN

    IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7200: Leaving Is_Terms_Template_Valid : OKC_API.G_EXCEPTION_ERROR Exception');
    END IF;

    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    x_return_status := G_RET_STS_ERROR ;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7300: Leaving Is_Terms_Template_Valid : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  WHEN OTHERS THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7400: Leaving Is_Terms_Template_Valid because of EXCEPTION:'||sqlerrm);
      END IF;
      IF terms_tmpl_csr%ISOPEN THEN
        CLOSE terms_tmpl_csr;
      END IF;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      x_return_status := G_RET_STS_UNEXP_ERROR ;
END Is_Terms_Template_Valid;


--Returns values used for defaulting Contract Terms Details for authoring_party,contract_source,
--template_name,template_description in OM.
PROCEDURE Get_Contract_Defaults(
  p_api_version          IN  NUMBER,
  p_init_msg_list        IN  VARCHAR2 :=  FND_API.G_FALSE,

  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_data             OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,

  p_template_id          IN  VARCHAR2,
  p_document_type        IN  VARCHAR2,

  x_authoring_party      OUT NOCOPY   VARCHAR2,
  x_contract_source      OUT NOCOPY   VARCHAR2,
  x_template_name        OUT NOCOPY   VARCHAR2,
  x_template_description OUT NOCOPY   VARCHAR2
  ) IS

 CURSOR terms_tmpl_csr IS
  SELECT tmpl.template_name,
         tmpl.description,
         okc_util.decode_lookup('OKC_CONTRACT_TERMS_SOURCES','STRUCTURED'),
         party.alternate_name
  FROM   okc_terms_templates_all tmpl,
         okc_resp_parties_vl party,
         okc_bus_doc_types_b doc
  WHERE  tmpl.template_id =  p_template_id
  and    party.document_type_class = doc.document_type_class
  and    party.intent = doc.intent
  and    doc.document_type= p_document_type
  and    party.resp_party_code = 'INTERNAL_ORG';

  l_api_version      CONSTANT NUMBER := 1;
  l_api_name         CONSTANT VARCHAR2(30) := 'Get_Contract_Defaults';

BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'6900: Entered Get_Contract_Defaults');
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

    IF p_template_id IS NOT NULL THEN
      OPEN  terms_tmpl_csr;
      FETCH terms_tmpl_csr INTO x_template_name,x_template_description,x_contract_source,x_authoring_party;
   IF terms_tmpl_csr%NOTFOUND THEN
        fnd_message.set_name('OKC','OKC_TERMS_AUTH_PARTY_NONE');
        x_authoring_party := fnd_message.get;
        fnd_message.set_name('OKC','OKC_TERMS_CONTRACT_SOURCE_NONE');
        x_contract_source := fnd_message.get;
        fnd_message.set_name('OKC','OKC_TERMS_TEMPLATE_NAME_NONE');
        x_template_name:= fnd_message.get;
        x_template_description := NULL;
   END IF;
      CLOSE terms_tmpl_csr;

    ELSE
      fnd_message.set_name('OKC','OKC_TERMS_AUTH_PARTY_NONE');
      x_authoring_party := fnd_message.get;
      fnd_message.set_name('OKC','OKC_TERMS_CONTRACT_SOURCE_NONE');
      x_contract_source := fnd_message.get;
      fnd_message.set_name('OKC','OKC_TERMS_TEMPLATE_NAME_NONE');
      x_template_name:= fnd_message.get;
      x_template_description := NULL;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7000: Result Get_Contract_Defaults? : ['||x_return_status||']');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7100: Leaving Get_Contract_Defaults');
    END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN

    IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7200: Leaving Get_Contract_Defaults : OKC_API.G_EXCEPTION_ERROR Exception');
    END IF;

    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    x_return_status := G_RET_STS_ERROR ;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7300: Leaving Get_Contract_Defaults : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  WHEN OTHERS THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7400: Leaving Get_Contract_Defaults because of EXCEPTION:'||sqlerrm);
      END IF;
      IF terms_tmpl_csr%ISOPEN THEN
        CLOSE terms_tmpl_csr;
      END IF;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      x_return_status := G_RET_STS_UNEXP_ERROR ;
END Get_Contract_Defaults;

PROCEDURE Get_Default_Template(
  p_api_version          IN  NUMBER,
  p_init_msg_list        IN  VARCHAR2 :=  FND_API.G_FALSE,

  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_data             OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,

  p_document_type        IN  VARCHAR2,
  p_org_id               IN  NUMBER,
  p_valid_date           IN  DATE,

  x_template_id          OUT NOCOPY   NUMBER,
  x_template_name        OUT NOCOPY   VARCHAR2,
  x_template_description OUT NOCOPY   VARCHAR2) IS

 CURSOR terms_tmpl_csr IS
  SELECT tmpl.template_id,
         tmpl.template_name,
         tmpl.description
  FROM OKC_TERMS_TEMPLATES_ALL tmpl,
       OKC_ALLOWED_TMPL_USAGES usg,
       OKC_BUS_DOC_TYPES_B doc
  WHERE   doc.document_type = p_document_type
  AND   doc.intent = tmpl.intent
  AND   usg.template_id = tmpl.template_id
  AND   usg.document_type = p_document_type
  AND   usg.document_type = doc.document_type
  AND   usg.default_yn = 'Y'
  AND   tmpl.status_code = 'APPROVED'
  AND   tmpl.org_id = p_org_id
  AND   p_valid_date between tmpl.start_date and nvl(tmpl.end_date,p_valid_date);

  l_api_version      CONSTANT NUMBER := 1;
  l_api_name         CONSTANT VARCHAR2(30) := 'Get_Default_Template';

BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'6900: Entered Get_Default_Template');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'6910: p_document_type='||p_document_type);
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'6920: p_org_id='||p_org_id);
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'6930: p_valid_date='||p_valid_date);
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

    OPEN  terms_tmpl_csr;
    FETCH terms_tmpl_csr INTO x_template_id,x_template_name,x_template_description;
    CLOSE terms_tmpl_csr;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7000: Result x_template_id : ['||x_template_id||']');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7010: Result x_template_name : ['||x_template_name||']');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7020: Result x_template_desription : ['||x_template_description||']');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7130: Leaving Get_Default_Template');
    END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN

    IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7200: Leaving Get_Default_Template : OKC_API.G_EXCEPTION_ERROR Exception');
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    x_return_status := G_RET_STS_ERROR ;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7300: Leaving Get_Default_Template : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  WHEN OTHERS THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7400: Leaving Get_Default_Template because of EXCEPTION:'||sqlerrm);
      END IF;
      IF terms_tmpl_csr%ISOPEN THEN
        CLOSE terms_tmpl_csr;
      END IF;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      x_return_status := G_RET_STS_UNEXP_ERROR ;
END Get_Default_Template;

--Returns 'Y' or 'N' depending on wether the API is able to generate deviation report.
FUNCTION Auto_Generate_Deviations(
    p_document_type         IN  VARCHAR2,
    p_document_id           IN  NUMBER
 ) RETURN VARCHAR2 IS
l_api_name         CONSTANT VARCHAR2(30) := 'Auto_Generate_Deviations';
 CURSOR tmpl_usages_csr IS
     SELECT usg.autogen_deviations_flag,types.application_id
     FROM  OKC_TEMPLATE_USAGES usg, OKC_BUS_DOC_TYPES_B types
     WHERE usg.document_type = p_document_type
       AND usg.document_id = p_document_id
       AND types.document_type = usg.document_type;

  l_autogen_deviations_flag OKC_TEMPLATE_USAGES.AUTOGEN_DEVIATIONS_FLAG%TYPE;
  l_application_id          OKC_BUS_DOC_TYPES_B.APPLICATION_ID%TYPE;

BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1800: Entering Auto_Generate_Deviations ');
    END IF;


    OPEN  tmpl_usages_csr ;
    FETCH tmpl_usages_csr  into  l_autogen_deviations_flag,l_application_id;
    CLOSE tmpl_usages_csr ;

    IF l_autogen_deviations_flag IS NOT NULL THEN
        RETURN l_autogen_deviations_flag;
    ELSE
        RETURN nvl(fnd_profile.VALUE_SPECIFIC(name => 'OKC_RUN_DEVREP_ON_APPROVAL',application_id => l_application_id),'N');
    END IF;

EXCEPTION
 WHEN OTHERS THEN
   IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2000: Leaving Auto_Generate_Deviations of EXCEPTION: '||sqlerrm);
   END IF;
 RETURN 'E';
END Auto_Generate_Deviations;

--Returns ID(s) of Abstract category Contract Attachments.  ID's are comma seperated in case of multiple value, NULL if not present.
FUNCTION Get_Deviations_File_Id(
    p_document_type         IN  VARCHAR2,
    p_document_id           IN  NUMBER
 ) RETURN VARCHAR2 IS
l_api_name         CONSTANT VARCHAR2(30) := 'Get_Deviations_File_Id';

 CURSOR doc_details_csr IS
  select  media_id from okc_contract_docs_details_vl
   where  business_document_id = p_document_id
    and   business_document_type = p_document_type
    and   category_code = 'OKC_REPO_APPROVAL_ABSTRACT'
    and   datatype_id = 6;

 l_file_id                VARCHAR2(2000):= NULL;
 l_media_id               FND_DOCUMENTS_TL.MEDIA_ID%TYPE := -1;

BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1800: Entering Get_Deviations_File_Id ');
    END IF;

    IF Okc_terms_util_grp.get_contract_source_code(p_document_type,p_document_id) <> 'ATTACHED' THEN
        OPEN doc_details_csr;
        LOOP
           FETCH doc_details_csr INTO l_media_id;
           IF doc_details_csr%NOTFOUND THEN
               exit;
           END IF;
           IF l_file_id IS NULL THEN
               l_file_id := l_media_id;
           ELSE
               l_file_id := l_file_id || ',' || l_media_id;
           END IF;
        END LOOP;
        CLOSE doc_details_csr;
    END IF;

    RETURN l_file_id;

EXCEPTION
 WHEN OTHERS THEN
   IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2000: Leaving Get_Deviations_File_Id of EXCEPTION: '||sqlerrm);
   END IF;
   IF doc_details_csr%ISOPEN THEN
      CLOSE doc_details_csr;
   END IF;

 RETURN NULL;
END Get_Deviations_File_Id;


PROCEDURE Has_Uploaded_Deviations_Doc(
  p_api_version          IN  NUMBER,
  p_init_msg_list        IN  VARCHAR2 :=  FND_API.G_FALSE,

  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_data             OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,

  p_document_type         IN  VARCHAR2,
  p_document_Id           IN  NUMBER,
  x_contract_source       OUT NOCOPY VARCHAR2,
  x_has_deviation_report  OUT NOCOPY VARCHAR2
) IS

  l_api_version      CONSTANT NUMBER := 1;
  l_api_name         CONSTANT VARCHAR2(30) := 'Has_Uploaded_Deviations_Doc';

BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'6900: Entered Has_Uploaded_Deviations_Doc');
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

    x_contract_source := Get_Contract_Source_Code(
                    p_document_type   => p_document_type,
                    p_document_id     => p_document_id
                    );
    x_has_deviation_report := OKC_TERMS_DEVIATIONS_PVT.has_deviation_report (
                    p_document_type   => p_document_type,
                    p_document_id     => p_document_id
                    );


    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7000: Result Has_Uploaded_Deviations_Doc? : ['||x_return_status||']');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'x_contract_source:'||x_contract_source);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'x_has_deviation_report:'||x_has_deviation_report);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7100: Leaving Has_Uploaded_Deviations_Doc');
    END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN

    IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7200: Leaving Has_Uploaded_Deviations_Doc : OKC_API.G_EXCEPTION_ERROR Exception');
    END IF;

    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    x_return_status := G_RET_STS_ERROR ;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7300: Leaving Has_Uploaded_Deviations_Doc : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  WHEN OTHERS THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7400: Leaving Has_Uploaded_Deviations_Doc because of EXCEPTION:'||sqlerrm);
      END IF;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      x_return_status := G_RET_STS_UNEXP_ERROR ;
END Has_Uploaded_Deviations_Doc;

-- Returns 'Y' if Deviations report is implemented and enabled for the particular document, else 'N' .
FUNCTION is_Deviations_enabled(
  p_document_type    IN VARCHAR2,
  p_document_id      IN  NUMBER
) RETURN VARCHAR2 IS

l_api_name         CONSTANT VARCHAR2(30) := 'is_Deviations_enabled';
l_result                    VARCHAR2(1)  := '?';

 CURSOR deviations_lookup_csr IS
  SELECT 'Y'
  FROM  FND_LOOKUP_VALUES
  WHERE lookup_code = 'REVIEW_DEV_REP'
  AND   lookup_type = 'OKC_TERMS_AUTH_ACTIONS_VIEW';

BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1800: Entering is_Deviations_enabled ');
    END IF;

    OPEN  deviations_lookup_csr;
    FETCH deviations_lookup_csr INTO l_result;
    CLOSE deviations_lookup_csr;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1900: Result is_Deviations_enabled :'||l_result);
    END IF;

    IF l_result <> 'Y' THEN
      RETURN 'N';
    ELSE
        IF get_contract_source_code(p_document_type=>p_document_type,p_document_id=>p_document_id) = 'STRUCTURED' THEN
           RETURN 'Y';
        ELSE
           RETURN 'N';
        END IF;
    END IF;

EXCEPTION
 WHEN OTHERS THEN
   IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2000: Leaving is_Deviations_Implemented  EXCEPTION: '||sqlerrm);
   END IF;
   IF deviations_lookup_csr%ISOPEN THEN
      CLOSE deviations_lookup_csr;
   END IF;

 RETURN 'N';
END is_Deviations_enabled;

  FUNCTION Contract_Terms_Amended(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER
   ) RETURN VARCHAR2 IS
    l_api_version      CONSTANT NUMBER := 1;
    l_api_name         CONSTANT VARCHAR2(30) := 'Contract_Terms_Amended';
    l_dummy  VARCHAR2(1) := '?';
    l_return_value    VARCHAR2(100) := G_NO_ARTICLE_AMENDED;
    l_contract_source_code okc_template_usages.contract_source_code%TYPE;
    CURSOR contract_source_csr IS
      SELECT contract_source_code
   FROM okc_template_usages
   WHERE document_id = p_doc_id
   AND document_type = p_doc_type;

    CURSOR primary_kdoc_csr IS
      SELECT 'Y'
     FROM okc_contract_docs
     WHERE business_document_id = p_doc_id
     AND business_document_type = p_doc_type
     AND business_document_version = -99
     AND effective_from_id = business_document_id
     AND effective_from_type = business_document_type
     AND effective_from_version = business_document_version
     AND primary_contract_doc_flag = 'Y'
   UNION ALL
      SELECT 'Y'
     FROM okc_contract_docs
     WHERE business_document_id = p_doc_id
     AND business_document_type = p_doc_type
     AND business_document_version = -99
     AND delete_flag = 'Y'
     AND primary_contract_doc_flag = 'Y';
   BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Entered Contract_Terms_Amended');
    END IF;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

    OPEN contract_source_csr;
    FETCH contract_source_csr INTO l_contract_source_code;
    CLOSE contract_source_csr;

    IF l_contract_source_code = G_ATTACHED_CONTRACT_SOURCE THEN
      OPEN primary_kdoc_csr;
   FETCH primary_kdoc_csr INTO l_dummy;
   CLOSE primary_kdoc_csr;

      IF l_dummy='Y' THEN
        l_return_value := G_PRIMARY_KDOC_AMENDED;
      END IF;
    ELSIF l_contract_source_code = G_STRUCT_CONTRACT_SOURCE THEN
      l_return_value := Is_Article_Amended(
                                p_api_version   => p_api_version,
              p_init_msg_list => p_init_msg_list,
              x_return_status => x_return_status,
              x_msg_data      => x_msg_data,
              x_msg_count     => x_msg_count,
              p_doc_type      => p_doc_type,
              p_doc_id        => p_doc_id);

    END IF;

    -- Standard call to get message count and if count is 1, get message info.

    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'200: Result Contract_Terms_Amended? : ['||l_return_value||']');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'300: Leaving Contract_Terms_Amended');
    END IF;

    RETURN l_return_value ;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
   IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'400: Leaving Contract_Terms_Amended : OKC_API.G_EXCEPTION_ERROR Exception');
   END IF;
   x_return_status := G_RET_STS_ERROR ;
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
   RETURN NULL ;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'500: Leaving Contract_Terms_Amended : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
    END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    RETURN NULL ;

  WHEN OTHERS THEN
    IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'600: Leaving Contract_Terms_Amended because of EXCEPTION: '||sqlerrm);
    END IF;

    IF contract_source_csr%ISOPEN THEN
        CLOSE contract_source_csr;
    END IF;

    IF primary_kdoc_csr%ISOPEN THEN
        CLOSE primary_kdoc_csr;
    END IF;

    x_return_status := G_RET_STS_UNEXP_ERROR ;

    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      RETURN NULL ;

END Contract_Terms_Amended;

----MLS for templates
PROCEDURE get_translated_template(
  p_api_version          IN  NUMBER,
  p_init_msg_list        IN  VARCHAR2 :=  FND_API.G_FALSE,

  p_template_id          IN  NUMBER,
  p_language             IN  VARCHAR2,
  p_document_type        IN  VARCHAR2,
  p_validity_date        IN  DATE := SYSDATE,

  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_data             OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,

  x_template_id          OUT NOCOPY NUMBER
) IS

  l_api_version      CONSTANT NUMBER := 1;
  l_api_name         CONSTANT VARCHAR2(30) := 'get_translated_template';
  l_translated_from_tmpl_id OKC_TERMS_TEMPLATES_ALL.translated_from_tmpl_id%TYPE;
  l_language                OKC_TERMS_TEMPLATES_ALL.language%TYPE;
  l_org_id                  OKC_TERMS_TEMPLATES_ALL.org_id%TYPE;
  l_parent_template_id      OKC_TERMS_TEMPLATES_ALL.parent_template_id%TYPE;

    CURSOR l_tmpl_csr IS
     SELECT translated_from_tmpl_id, language, org_id, parent_template_id
     FROM  okc_terms_templates_all
     WHERE template_id = p_template_id;

    CURSOR l_translated_csr( l_tmpl_id in number,l_org_id in number) IS
     SELECT template_id
     FROM  okc_terms_templates_all
     WHERE language = p_language
     AND org_id = l_org_id
     AND template_id = l_tmpl_id
     UNION ALL
     SELECT template_id
     FROM  okc_terms_templates_all
     WHERE language = p_language
     AND org_id = l_org_id
     AND translated_from_tmpl_id = l_tmpl_id;


BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'6900: Entered get_translated_template');
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;


    OPEN  l_tmpl_csr;
    FETCH l_tmpl_csr INTO l_translated_from_tmpl_id, l_language, l_org_id, l_parent_template_id;
    IF l_tmpl_csr%NOTFOUND THEN
       CLOSE l_tmpl_csr;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    CLOSE l_tmpl_csr;

    IF l_language = p_language THEN
        x_template_id := p_template_id;  --Input template itself is in the required language.
        RETURN;
    END IF;


    IF l_translated_from_tmpl_id is null THEN  --p_template_id is a parent template.

        OPEN  l_translated_csr(p_template_id, l_org_id);
        FETCH l_translated_csr INTO x_template_id;   --Fetch translated template.

    ELSE  --p_template_id is a translated template

        OPEN  l_translated_csr(l_translated_from_tmpl_id, l_org_id);
        FETCH l_translated_csr INTO x_template_id;   --Fetch translated template.

    END IF;

    IF l_translated_csr%FOUND THEN
        IF ( OKC_TERMS_UTIL_GRP.Is_Terms_Template_Valid(
                                   p_api_version   => 1.0,
                                   p_template_id   => x_template_id,
                                   p_doc_type      => p_document_type,
                                   p_org_id        => l_org_id,
                                   p_valid_date    => p_validity_date,
                                   x_return_status => x_return_status,
                                   x_msg_data      => x_msg_data,
                                   x_msg_count     => x_msg_count ) <> 'Y' ) THEN

             x_template_id := p_template_id;    --Template x_template_id status is invalid.
	END IF;
    ELSE

	x_template_id := p_template_id;  -- matching translated template not found.
    END IF;

    CLOSE l_translated_csr;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7300: Leaving get_translated_template');
    END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
   IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7400: Leaving Contract_Terms_Amended : OKC_API.G_EXCEPTION_ERROR Exception');
   END IF;
   x_return_status := G_RET_STS_ERROR ;
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
   RETURN ;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7500: Leaving Contract_Terms_Amended : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
    END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    RETURN ;
  WHEN OTHERS THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7700: Leaving get_translated_template because of EXCEPTION:'||sqlerrm);
      END IF;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      x_return_status := G_RET_STS_UNEXP_ERROR ;
END get_translated_template;
--MLS for templates


-- Concurrent Mod Changes Start

FUNCTION check_lock_exists ( p_object_type IN VARCHAR2, p_kart_sec_id IN VARCHAR2)
RETURN VARCHAR2
IS

CURSOR cur_art_details (cp_kart_sec_id IN NUMBER)
IS
SELECT orig_system_reference_code, orig_system_reference_id1, document_type,document_id
From okc_k_articles_b
Where id= cp_kart_sec_id ;
l_tgt_art_details_rec cur_art_details%ROWTYPE;
l_src_art_details_rec cur_art_details%ROWTYPE;


CURSOR cur_sec_details (cp_kart_sec_id IN NUMBER)
IS
SELECT orig_system_reference_code, orig_system_reference_id1, document_type,document_id
From okc_sections_b
Where id= cp_kart_sec_id ;
l_tgt_sec_details_rec cur_sec_details%ROWTYPE;
l_src_sec_details_rec cur_sec_details%ROWTYPE;

CURSOR cur_lock_exists (cp_entity_name VARCHAR2,cp_entity_pk1 VARCHAR2, cp_lock_by_doc_type VARCHAR2,cp_lock_by_doc_id VARCHAR2)
IS
SELECT 'Y'
FROM  okc_k_entity_locks
WHERE entity_name=   cp_entity_name
AND   entity_pk1=    cp_entity_pk1
AND   lock_by_document_type <>  cp_lock_by_doc_type
AND   lock_by_document_id <>  cp_lock_by_doc_id;


l_lock_exists_flag VARCHAR2(1):= NULL;


BEGIN
 IF p_object_type = 'ARTICLE' THEN
      OPEN cur_art_details(p_kart_sec_id);
      FETCH cur_art_details INTO l_tgt_art_details_rec;
      CLOSE cur_art_details;
      IF  Nvl(l_tgt_art_details_rec.orig_system_reference_code,'?') = 'COPY' THEN
           OPEN cur_art_details(l_tgt_art_details_rec.orig_system_reference_id1);
           FETCH  cur_art_details INTO l_src_art_details_rec;
           CLOSE  cur_art_details;
           -- Base document and the current document or not of same type then check for locks.
           IF   l_src_art_details_rec.document_type <> l_tgt_art_details_rec.document_type
           THEN
                OPEN cur_lock_exists('CLAUSE',l_tgt_art_details_rec.orig_system_reference_id1,l_tgt_art_details_rec.document_type,l_tgt_art_details_rec.document_id);
                FETCH cur_lock_exists INTO l_lock_exists_flag;
                CLOSE cur_lock_exists;
                RETURN Nvl(l_lock_exists_flag,'N');
           END IF;
      END IF;
   END IF;

    IF p_object_type = 'SECTION' THEN
      OPEN cur_sec_details(p_kart_sec_id);
      FETCH cur_sec_details INTO l_tgt_sec_details_rec;
      CLOSE cur_sec_details;
      IF  Nvl(l_tgt_sec_details_rec.orig_system_reference_code,'?') = 'COPY' THEN
           OPEN cur_sec_details(l_tgt_sec_details_rec.orig_system_reference_id1);
           FETCH  cur_sec_details INTO l_src_sec_details_rec;
           CLOSE  cur_sec_details;
           -- Base document and the current document or not of same type then check for locks.
           IF   l_src_sec_details_rec.document_type <> l_tgt_sec_details_rec.document_type
           THEN
                OPEN cur_lock_exists('SECTION',l_tgt_art_details_rec.orig_system_reference_id1,l_tgt_art_details_rec.document_type,l_tgt_art_details_rec.document_id);
                FETCH cur_lock_exists INTO l_lock_exists_flag;
                CLOSE cur_lock_exists;
                RETURN Nvl(l_lock_exists_flag,'N');
           END IF;
      END IF;
   END IF;
   RETURN 'N';
END check_lock_exists;

FUNCTION enable_update(
  p_object_type    IN VARCHAR2,
  p_document_type  IN VARCHAR2,
  p_standard_yn    IN VARCHAR2,
  p_kart_sec_id    in NUMBER
 ) RETURN VARCHAR2
IS

l_lock_exists VARCHAR2(1);
BEGIN

    IF (p_object_type = 'SECTION' OR  p_object_type = 'ARTICLE') THEN
      l_lock_exists := check_lock_exists(p_object_type,To_Char(p_kart_sec_id));
      IF l_lock_exists = 'Y' THEN
         RETURN 'OkcTermsStructDtlsUpdateDisabled' ;
      END IF;
    END IF;

   IF (p_object_type <> 'SECTION' AND p_object_type <> 'ARTICLE') THEN
      -- top most document node , always disable
      RETURN 'OkcTermsStructDtlsUpdateDisabled' ;
   ELSIF p_object_type = 'SECTION' THEN
     -- update always enabled for Sections
      RETURN 'OkcTermsStructDtlsUpdateEnabled' ;
     -- Article Cases
   ELSIF  p_document_type = 'TEMPLATE' THEN
      -- always disable for template as the logic is based on template status and is in the controller code
      RETURN 'OkcTermsStructDtlsUpdateDisabled';
   ELSIF  NVL(p_standard_yn,'N') = 'Y' THEN
      -- update always enabled for standard articles
      RETURN 'OkcTermsStructDtlsUpdateEnabled' ;
      -- non std articles
   ELSIF fnd_function.test('OKC_TERMS_AUTHOR_NON_STD','N') THEN
      -- user has access to fn and doc not template
      RETURN 'OkcTermsStructDtlsUpdateEnabled' ;
   ELSE
     -- user does NOT have access to function OKC_TERMS_AUTHOR_NON_STD
     RETURN 'OkcTermsStructDtlsUpdateDisabled' ;
   END IF;
END enable_update;


FUNCTION enable_delete(
  p_object_type    IN VARCHAR2,
  p_mandatory_yn   IN VARCHAR2,
  p_standard_yn    IN VARCHAR2,
  p_document_type  IN VARCHAR2 := NULL,
  p_kart_sec_id     in number
) RETURN VARCHAR2
IS

CURSOR cur_art_details
IS
SELECT orig_system_reference_code, orig_system_reference_id1
From okc_k_articles_b
Where id= p_kart_sec_id ;
l_art_details_rec cur_art_details%ROWTYPE;
     l_lock_exists VARCHAR2(1);
BEGIN

   IF (p_object_type = 'SECTION' OR  p_object_type = 'ARTICLE')  THEN
      l_lock_exists := check_lock_exists(p_object_type,To_Char(p_kart_sec_id));
      IF l_lock_exists = 'Y' THEN
         RETURN 'OkcTermsStructDtlsRemoveDisabled' ;
      END IF;
   END IF;

     IF (p_object_type <> 'SECTION' AND p_object_type <> 'ARTICLE') THEN
        -- topmost document node, so disable delete
        RETURN 'OkcTermsStructDtlsRemoveDisabled';
   ELSIF p_object_type = 'SECTION' THEN
        -- Delete always enabled for sections as the API validates for mandatory articles check
        RETURN 'OkcTermsStructDtlsRemoveEnabled' ;
        --  ARTICLES LOGIC
        --  Case 1: MANDATORY ARTICLES
   ELSIF NVL(p_mandatory_yn,'N') = 'Y' THEN
        -- article is mandatory
        --Bug 4123003 If doc_type is template, delete button should be enabled
        IF  p_document_type = 'TEMPLATE' THEN
            RETURN 'OkcTermsStructDtlsRemoveEnabled';
        ELSE
           IF (fnd_function.test('OKC_TERMS_AUTHOR_NON_STD','N') AND
               fnd_function.test('OKC_TERMS_AUTHOR_SUPERUSER','N')) THEN
               -- user has override controls, allow delete mandatory
             RETURN 'OkcTermsStructDtlsRemoveEnabled';
           ELSE
             RETURN 'OkcTermsStructDtlsRemoveDisabled';
           END IF;
        END IF;
        --  Case 2: STANDARD ARTICLES (non-mandatory)
   ELSIF NVL(p_standard_yn,'N') = 'Y' THEN
        -- for standard articles delete is always allowed
        RETURN 'OkcTermsStructDtlsRemoveEnabled' ;
        --  Case 3: NON-STANDARD ARTICLES (non-mandatory)
   ELSIF fnd_function.test('OKC_TERMS_AUTHOR_NON_STD','N') THEN
        -- for non-std articles check for function security
        -- user has access , so check allow delete for non-std articles
        RETURN 'OkcTermsStructDtlsRemoveEnabled' ;
   ELSE
        -- user does not have access to delete non-std articles
        RETURN 'OkcTermsStructDtlsRemoveDisabled';
   END IF;



   OPEN cur_art_details;
   FETCH cur_art_details INTO  l_art_details_rec;
   CLOSE  cur_art_details;

   IF Nvl(l_art_details_rec.orig_system_reference_code,'?')='COPY' THEN
   NULL;
   ELSE
    RETURN     enable_delete(
                p_object_type    ,
                p_mandatory_yn   ,
                p_standard_yn    ,
                p_document_type  );
   END IF;
END  enable_delete;

-- Concurrent Mod Changes End

FUNCTION enable_delete(
  p_object_type    IN VARCHAR2,
  p_mandatory_yn   IN VARCHAR2,
  p_standard_yn    IN VARCHAR2,
  p_document_type  IN VARCHAR2 := NULL ,
  p_kart_sec_id     in NUMBER,
  p_lockingEnabledYn IN VARCHAR2
 ) RETURN VARCHAR2
IS
BEGIN
RETURN  enable_delete(
                p_object_type    ,
                p_mandatory_yn   ,
                p_standard_yn    ,
                p_document_type  );
END enable_delete;

FUNCTION enable_update(
  p_object_type    IN VARCHAR2,
  p_document_type  IN VARCHAR2,
  p_standard_yn    IN VARCHAR2,
  p_kart_sec_id     in NUMBER,
  p_lockingEnabledYn IN VARCHAR2
 ) RETURN VARCHAR2
 IS
 BEGIN
   RETURN enable_update(
  p_object_type   ,
  p_document_type ,
  p_standard_yn
 );

 END  enable_update;


--PROCEDURE

FUNCTION Has_deliverables(
    p_document_type         IN  VARCHAR2,
    p_document_id           IN  NUMBER,
    p_doc_version           IN NUMBER DEFAULT NULL
) RETURN VARCHAR2
IS
 CURSOR cur_get_del
     IS
     SELECT 'Y'
     FROM okc_deliverables
     WHERE business_document_type = p_document_type
       AND business_document_id = p_document_id
       AND business_document_version=Nvl(p_doc_version,-99);


  l_value VARCHAR2(1);

BEGIN
      OPEN cur_get_del;
      FETCH cur_get_del INTO l_value;
      IF (cur_get_del%NOTFOUND) THEN
        CLOSE cur_get_del;
        RETURN 'N';
      END IF;
      CLOSE  cur_get_del;

      Return 'Y';

END Has_deliverables;


END OKC_TERMS_UTIL_GRP;

/
