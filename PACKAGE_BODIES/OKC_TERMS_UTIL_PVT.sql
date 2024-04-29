--------------------------------------------------------
--  DDL for Package Body OKC_TERMS_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TERMS_UTIL_PVT" AS
/* $Header: OKCVDUTB.pls 120.26.12010000.11 2013/02/26 06:26:38 serukull ship $ */
  g_concat_art_no  VARCHAR2(1) := NVL(FND_PROFILE.VALUE('OKC_CONCAT_ART_NO'),'N');

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                    CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_UNABLE_TO_RESERVE_REC      CONSTANT VARCHAR2(200) := OKC_API.G_UNABLE_TO_RESERVE_REC;
  G_RECORD_DELETED             CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_DELETED;
  G_RECORD_CHANGED             CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED   CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE             CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE              CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN             CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN         CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN          CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_TERMS_UTIL_PVT';
  G_MODULE                     CONSTANT   VARCHAR2(250)   := 'okc.plsql.'||G_PKG_NAME||'.';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   := OKC_API.G_APP_NAME;

  G_TMPL_DOC_TYPE              CONSTANT   VARCHAR2(30)  := OKC_TERMS_UTIL_GRP.G_TMPL_DOC_TYPE;
  G_UNASSIGNED_SECTION_CODE    CONSTANT   VARCHAR2(30)  := 'UNASSIGNED';
  G_AMEND_CODE_UPDATED         CONSTANT   VARCHAR2(30)  := 'UPDATED';
  G_ATTACHED_CONTRACT_SOURCE   CONSTANT   VARCHAR2(30) := 'ATTACHED';
  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;

  G_RET_STS_SUCCESS            CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
  ------------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ------------------------------------------------------------------------------
  E_Resource_Busy               EXCEPTION;
  PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);

  -- 11.5.10+ change
  -- Global variable set by the original Merge_Template_Working_Copy procedure
  -- Returned by the overloaded Merge_Template_Working_Copy
  g_parent_template_id          NUMBER;


--==================== INTERNAL PROCEDURES ============================
 PROCEDURE ALLOWED_TMPL_USAGES_Delete_Set(
          x_return_status         OUT NOCOPY VARCHAR2,
          x_msg_data              OUT NOCOPY VARCHAR2,
          x_msg_count             OUT NOCOPY NUMBER,
          p_template_id           IN NUMBER
  ) IS
    l_api_name         CONSTANT VARCHAR2(30) := 'ALLOWED_TMPL_USAGES_Delete_Set';


    CURSOR l_get_rec IS
      SELECT allowed_tmpl_usages_id,object_version_number
        FROM OKC_ALLOWED_TMPL_USAGES
       WHERE TEMPLATE_ID = p_template_id;
   BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Entered ALLOWED_TMPL_USAGES_Delete_Set');
    END IF;

    FOR cr IN l_get_rec LOOP

      OKC_ALLOWED_TMPL_USAGES_GRP.Delete_Allowed_Tmpl_Usages(
                            p_api_version   => 1,
                            p_init_msg_list => FND_API.G_FALSE,
                            p_commit        => FND_API.G_FALSE,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,

                            p_allowed_tmpl_usages_id => cr.allowed_tmpl_usages_id,

                            p_object_version_number  => cr.object_version_number
                         );

        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
             RAISE FND_API.G_EXC_ERROR ;
        END IF;
    END LOOP;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'400: Leaving ALLOWED_TMPL_USAGES_Delete_Set');
    END IF;
   EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      IF (l_get_rec%ISOPEN) THEN
        CLOSE l_get_rec;
      END IF;

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'500: Leaving ALLOWED_TMPL_USAGES_Delete_Set:FND_API.G_EXC_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_ERROR ;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_get_rec%ISOPEN) THEN
        CLOSE l_get_rec;
      END IF;

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'500: Leaving ALLOWED_TMPL_USAGES_Delete_Set:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;


   WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'600: Leaving ALLOWED_TMPL_USAGES_Delete_Set because of EXCEPTION: '||sqlerrm);
      END IF;

      IF (l_get_rec%ISOPEN) THEN
        CLOSE l_get_rec;
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
  END ALLOWED_TMPL_USAGES_Delete_Set;
---

 PROCEDURE Update_Allowed_Tmpl_Usages_Id(
          x_return_status         OUT NOCOPY VARCHAR2,
          x_msg_data              OUT NOCOPY VARCHAR2,
          x_msg_count             OUT NOCOPY NUMBER,
          p_old_template_id       IN NUMBER,
          p_new_template_id       IN NUMBER
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'Update_Allowed_Tmpl_Usages_Id';
    CURSOR l_get_rec IS
      SELECT allowed_tmpl_usages_id,object_version_number,document_type,default_yn
        FROM OKC_ALLOWED_TMPL_USAGES
       WHERE TEMPLATE_ID = p_old_template_id;
   BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1100: Entered Update_Allowed_Tmpl_Usages_Id');

    END IF;

 FOR cr in l_get_rec LOOP

         OKC_ALLOWED_TMPL_USAGES_GRP.update_Allowed_Tmpl_Usages(
                            p_api_version   => 1,
                            p_init_msg_list => FND_API.G_FALSE,
                            p_commit        => FND_API.G_FALSE,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_template_id => p_new_template_id,
                            p_document_type => cr.document_type,
                            p_default_yn    => cr.default_yn,
                            p_allowed_tmpl_usages_id => cr.allowed_tmpl_usages_id,

                            p_object_version_number  => cr.object_version_number
                         );

        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
             RAISE FND_API.G_EXC_ERROR ;
        END IF;

  END LOOP;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1400: Update_Allowed_Tmpl_Usages_Id');
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      IF (l_get_rec%ISOPEN) THEN
        CLOSE l_get_rec;
      END IF;

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'500: Leaving Update_Allowed_Tmpl_Usages_Id :FND_API.G_EXC_ERROR');
      END IF;
      x_return_status := G_RET_STS_ERROR ;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_get_rec%ISOPEN) THEN
        CLOSE l_get_rec;
      END IF;

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'500: Leaving Update_Allowed_Tmpl_Usages_Id : FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;


   WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1600: Leaving Update_Allowed_Tmpl_Usages_Id because of EXCEPTION: '||sqlerrm);
      END IF;

      IF (l_get_rec%ISOPEN) THEN
        CLOSE l_get_rec;
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;


  END Update_Allowed_Tmpl_Usages_Id;

--==================== INTERNAL PROCEDURES ============================


/*
-- PROCEDURE Delete_Doc
-- To be used to delete Terms whenever a document is deleted.
*/
  PROCEDURE Delete_Doc (
    x_return_status    OUT NOCOPY VARCHAR2,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER

    ,p_retain_lock_terms_yn        IN VARCHAR2 := 'N'
    ,p_retain_lock_xprt_yn         IN VARCHAR2 := 'N'

  ) IS
    l_api_version      CONSTANT NUMBER := 1;
    l_api_name         CONSTANT VARCHAR2(30) := 'Delete_Doc';
    l_found            BOOLEAN;
    l_status           OKC_TERMS_TEMPLATES.STATUS_CODE%TYPE;
    l_flag             VARCHAR2(1);
    l_objnum           NUMBER;
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(2000);

    CURSOR tmpl_sts_crs IS
      SELECT STATUS_CODE FROM okc_terms_templates
        WHERE TEMPLATE_ID = p_doc_id;

    CURSOR tmpl_prnt_crs IS
      SELECT '!' FROM okc_terms_templates
        WHERE parent_template_id = p_doc_id;

    CURSOR tmpl_usd_crs IS
      SELECT '!' FROM okc_template_usages_v
        WHERE TEMPLATE_ID = p_doc_id AND ROWNUM=1;

    CURSOR tt_csr IS
      SELECT TEMPLATE_ID, object_version_number,template_model_id
        FROM okc_terms_templates
       WHERE template_id=p_doc_id;

    CURSOR objnum_tu_csr IS
      SELECT object_version_number
        FROM OKC_TEMPLATE_USAGES
       WHERE DOCUMENT_TYPE = p_doc_type AND DOCUMENT_ID = p_doc_id;

    CURSOR objnum_mlp_tu_csr IS
      SELECT object_version_number
        FROM OKC_MLP_TEMPLATE_USAGES
       WHERE DOCUMENT_TYPE = p_doc_type AND DOCUMENT_ID = p_doc_id;

   BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2900: Entered Delete_Doc');
    END IF;
    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

    IF p_doc_type=G_TMPL_DOC_TYPE THEN

      OPEN tmpl_sts_crs;
      FETCH tmpl_sts_crs INTO l_status;
      l_found := tmpl_sts_crs%FOUND;
      CLOSE tmpl_sts_crs;

      IF NOT l_found THEN
        --?? Put some Message output
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3000: Template has not been found');
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      OPEN tmpl_prnt_crs;
      FETCH tmpl_prnt_crs INTO l_status;
      l_found := tmpl_prnt_crs%FOUND;
      CLOSE tmpl_prnt_crs;

      IF l_status NOT IN ('DRAFT', 'REJECTED','REVISION')
       OR l_found THEN  -- true if there's a revision for the template
        --?? Put some Message output
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3100: Template Status is not valid to delete it');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      OPEN tmpl_usd_crs;
      FETCH tmpl_usd_crs INTO l_flag;
      l_found := tmpl_usd_crs%FOUND;
      CLOSE tmpl_usd_crs;

      IF l_found THEN
        --?? Put some Message output
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3200: Template is already used - so can not be deleted');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --------------------------------------------
      -- Delete the record from OKC_ALLOWED_TMPL_USAGES_V
      --------------------------------------------
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3300: Delete each record from OKC_ALLOWED_TMPL_USAGES_V in a loop');
      END IF;
      --------------------------------------------
      ALLOWED_TMPL_USAGES_Delete_Set(
          x_return_status         => x_return_status,
          x_msg_data              => l_msg_data,
          x_msg_count             => l_msg_count,
          p_template_id           => p_doc_id
      );
      --------------------------------------------
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;
      --------------------------------------------

      -- Delete record from okc_terms_templates
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3400: Delete each record from okc_terms_templates in a loop');
      END IF;
      FOR cr IN tt_csr LOOP
        --------------------------------------------
        -- Delete each record from okc_terms_templates for
        --------------------------------------------
        OKC_TERMS_TEMPLATES_PVT.Delete_Row(
          x_return_status         => x_return_status,
          p_template_id           => cr.template_id,
          p_object_version_number => cr.object_version_number
        );
        --------------------------------------------
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR ;
        END IF;
        --------------------------------------------
        /*
      * Removed call to OKC_EXPRT_UTIL_GRP for 11.5.10+: Contract Expert Changes
      */
        --------------------------------------------

--Added 11.5.10+ CE
        --------------------------------------------
       OKC_XPRT_TMPL_RULE_ASSNS_PVT.delete_template_rule_assns(
                             p_api_version            => 1,
                             p_init_msg_list          => OKC_API.G_FALSE,
                             p_commit                 => OKC_API.G_FALSE,
                             p_template_id            => cr.template_id,
                             x_return_status          => x_return_status,
                             x_msg_data               => l_msg_data,
                             x_msg_count                  => l_msg_count);
         --------------------------------------------
       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR ;
       END IF;
      --------------------------------------------

      END LOOP;

    END IF;

    --------------------------------------------
    --    Delete record from okc_k_art_varaibles
    --------------------------------------------
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3500: Delete records from okc_k_art_varaibles for the doc');
    END IF;
    OKC_K_ART_VARIABLES_PVT.delete_set(
      x_return_status => x_return_status,
      p_doc_type      => p_doc_type,
      p_doc_id        => p_doc_id
      ,p_retain_lock_terms_yn => p_retain_lock_terms_yn
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    --------------------------------------------
    --    Delete record from okc_k_articles_v
    --------------------------------------------
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3600: Delete records from okc_k_articles_v for the doc');
    END IF;
    OKC_K_ARTICLES_PVT.delete_set(
      x_return_status => x_return_status,
      p_doc_type      => p_doc_type,
      p_doc_id        => p_doc_id
      ,p_retain_lock_terms_yn => p_retain_lock_terms_yn
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    --------------------------------------------
    --    Delete record from okc_sections_v
    --------------------------------------------
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3700: Delete records from okc_sections_v for the doc');
    END IF;
    OKC_TERMS_SECTIONS_PVT.delete_set(
      x_return_status => x_return_status,
      p_doc_type      => p_doc_type,
      p_doc_id        => p_doc_id
      ,p_retain_lock_terms_yn => p_retain_lock_terms_yn
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

   -------------------------------------------------
   -- Remove any uploaded terms under review
   ------------------------------------------------

    OKC_REVIEW_UPLD_TERMS_PVT.delete_uploaded_terms(
      p_api_version       => l_api_version,
      p_document_type     => p_doc_type,
      p_document_id      => p_doc_id,
      x_return_status    => x_return_status,
	 x_msg_data         => l_msg_data,
	 x_msg_count        => l_msg_count);
      --------------------------------------------
	   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
	        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	   ELSIF (x_return_status = G_RET_STS_ERROR) THEN
	        RAISE FND_API.G_EXC_ERROR ;
	   END IF;
	 --------------------------------------------

   ------------------------------------------------

    --------------------------------------------
    --    Delete record form okc_template_usages
    --------------------------------------------
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3800: Delete a record from okc_template_usages for the doc');
    END IF;
    l_objnum := -1;
    OPEN objnum_tu_csr;
    FETCH objnum_tu_csr INTO l_objnum;
    l_found := objnum_tu_csr%FOUND;
    CLOSE objnum_tu_csr;
    IF l_found THEN
      OKC_TEMPLATE_USAGES_PVT.delete_row(
        x_return_status         => x_return_status,
        p_document_type         => p_doc_type,
        p_document_id           => p_doc_id,
        p_object_version_number => l_objnum
        , p_retain_lock_xprt_yn   => p_retain_lock_xprt_yn
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
    -- kkolukul: CLM changes: Delete records from okc_mlp_template_usages
    --Delete records from okc_mlp_template_usages when removing terms.
    --------------------------------------------
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3900: Delete a record from okc_template_usages for the doc');
    END IF;

    l_objnum := -1;
    OPEN objnum_mlp_tu_csr;
    FETCH objnum_mlp_tu_csr INTO l_objnum;
    l_found := objnum_mlp_tu_csr%FOUND;
    CLOSE objnum_mlp_tu_csr;
    IF l_found THEN
      OKC_CLM_PKG.Delete_Usages_Row(
        x_return_status         => x_return_status,
        p_document_type         => p_doc_type,
        p_document_id           => p_doc_id,
        p_object_version_number => l_objnum
      );
      --------------------------------------------
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;
      --------------------------------------------
    END IF;

    ---end clm changes.

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4000: Leaving Delete_Doc');
    END IF;
   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF tmpl_sts_crs%ISOPEN THEN
        CLOSE tmpl_sts_crs;
      END IF;

      IF tmpl_usd_crs%ISOPEN THEN
        CLOSE tmpl_usd_crs;
      END IF;

      IF tmpl_prnt_crs%ISOPEN THEN
        CLOSE tmpl_prnt_crs;
      END IF;

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'4100: Leaving Delete_Doc : OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_ERROR ;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF tmpl_sts_crs%ISOPEN THEN
        CLOSE tmpl_sts_crs;
      END IF;

      IF tmpl_usd_crs%ISOPEN THEN
        CLOSE tmpl_usd_crs;
      END IF;

      IF tmpl_prnt_crs%ISOPEN THEN
        CLOSE tmpl_prnt_crs;
      END IF;

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'4200: Leaving Delete_Doc : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;

    WHEN OTHERS THEN
      IF tmpl_sts_crs%ISOPEN THEN
        CLOSE tmpl_sts_crs;
      END IF;

      IF tmpl_usd_crs%ISOPEN THEN
        CLOSE tmpl_usd_crs;
      END IF;

      IF tmpl_prnt_crs%ISOPEN THEN
        CLOSE tmpl_prnt_crs;
      END IF;

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'4300: Leaving Delete_Doc because of EXCEPTION: '||sqlerrm);
      END IF;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
  END Delete_Doc ;
/*
-- PROCEDURE delete_doc_version
-- To be used to delete Terms whenever a document is deleted.
*/
  PROCEDURE delete_doc_version (
    x_return_status    OUT NOCOPY VARCHAR2,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER,
    p_version_number   IN  NUMBER

  ) IS
    l_api_version      CONSTANT NUMBER := 1;
    l_api_name         CONSTANT VARCHAR2(30) := 'delete_doc_version';
    l_found            BOOLEAN;
    l_status           OKC_TERMS_TEMPLATES.STATUS_CODE%TYPE;
    l_flag             VARCHAR2(1);
    l_objnum           NUMBER;
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(2000);

   BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2900: Entered delete_doc_version');
    END IF;
    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;


    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3500: Delete records from okc_k_art_varaibles_h for the doc');
    END IF;

    x_return_status:=OKC_K_ART_VARIABLES_PVT.delete_version(
      p_doc_type      => p_doc_type,
      p_doc_id        => p_doc_id,
      p_major_version => p_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3600: Delete records from okc_k_articles_bh for the doc');
    END IF;

    x_return_status:=OKC_K_ARTICLES_PVT.delete_version(
      p_doc_type      => p_doc_type,
      p_doc_id        => p_doc_id,
      p_major_version => p_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3700: Delete records from okc_sections_h for the doc');
    END IF;
    x_return_status:=OKC_TERMS_SECTIONS_PVT.delete_version(
      p_doc_type      => p_doc_type,
      p_doc_id        => p_doc_id,
      p_major_version => p_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3800: Delete a record from okc_template_usages_h for the doc');
    END IF;

     x_return_status:=OKC_TEMPLATE_USAGES_PVT.delete_version(
        p_doc_type         => p_doc_type,
        p_doc_id           => p_doc_id,
        p_major_version => p_version_number
      );
      --------------------------------------------
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;
      --------------------------------------------

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4000: Leaving delete_doc_version');
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'4100: Leaving delete_doc_version : OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_ERROR ;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'4200: Leaving delete_doc_version : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;

    WHEN OTHERS THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'4300: Leaving delete_doc_version because of EXCEPTION: '||sqlerrm);
      END IF;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
  END Delete_Doc_version ;

/*
-- PROCEDURE Mark_Amendment
-- This API will be used to mark any article as amended if any of variables have been changed.
*/
  PROCEDURE Mark_Amendment (
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_data          OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,

    p_doc_type          IN  VARCHAR2,
    p_doc_id            IN  NUMBER,
    p_variable_code     IN  VARCHAR2
  ) IS
    l_api_version       CONSTANT NUMBER := 1;
    l_api_name          CONSTANT VARCHAR2(30) := 'Mark_Amendment';
    CURSOR idlist_crs IS
    SELECT distinct id, kart.object_version_number
      FROM okc_k_articles_b kart, okc_k_art_variables var
     WHERE document_type = p_doc_type
       AND document_id = p_doc_id
       AND var.cat_id = kart.id
       AND kart.amendment_operation_code IS NULL
       and var.variable_code = p_variable_code;
   BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4400: Entered Mark_Amendment');
    END IF;
    -- Standard Start of API savepoint
    SAVEPOINT g_Mark_Amendment;
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

    -- Delete record from okc_K_ARTICLES
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4500: Update each record from okc_K_ARTICLES in a loop');
    END IF;
    FOR cr IN idlist_crs LOOP
      --------------------------------------------
      -- Update each record from okc_terms_templates for
      --------------------------------------------
      OKC_K_ARTICLES_GRP.Update_article(
        p_api_version                => 1,
        p_init_msg_list              => FND_API.G_FALSE ,
        x_return_status              => x_return_status,
        x_msg_data                   => x_msg_data,
        x_msg_count                  => x_msg_count,
        p_mode                       => 'AMEND',
        p_id                         => cr.id,
        p_object_version_number      => cr.object_version_number
      );
      --------------------------------------------
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;
      --------------------------------------------
    END LOOP;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4600: Leaving Mark_Amendment');
    END IF;
   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO g_Mark_Amendment;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'4700: Leaving Mark_Amendment : OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO g_Mark_Amendment;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'4800: Leaving Mark_Amendment : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      ROLLBACK TO g_Mark_Amendment;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'4900: Leaving Mark_Amendment because of EXCEPTION: '||sqlerrm);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
  END Mark_Amendment;

    /*
    -- PROCEDURE Merge_Template_Working_Copy
    -- To be used to merge a working copy of a template is approved and old copy
    -- and working copy
    -- 11.5.10+ changes
        1. Store the parent template id in a package global variable. This will retrieved
            and returned by the overaloaded procedure.
        2. Update the table OKC_TMPL_DRAFT_CLAUSES with the merged/parent template id.
    */
    PROCEDURE Merge_Template_Working_Copy (
        p_api_version      IN  NUMBER,
        p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
        p_commit           IN  VARCHAR2 := FND_API.G_FALSE,

        x_return_status    OUT NOCOPY VARCHAR2,
        x_msg_data         OUT NOCOPY VARCHAR2,
        x_msg_count        OUT NOCOPY NUMBER,

        p_template_id      IN  NUMBER
    ) IS
        l_api_version      CONSTANT NUMBER := 1;
        l_api_name         CONSTANT VARCHAR2(30) := 'Merge_Template_Working_Copy';

        l_base_template_id NUMBER;
        l_found            BOOLEAN;

        CURSOR get_par_id_csr IS
            SELECT parent_template_id
            FROM okc_terms_templates_all
            WHERE template_id=p_template_id;

        CURSOR atu_csr IS
            SELECT template_id, document_type
            FROM OKC_ALLOWED_TMPL_USAGES
            WHERE TEMPLATE_ID = l_base_template_id;

        CURSOR kart_csr IS
            SELECT id, object_version_number
            FROM okc_k_articles_b
            WHERE document_type=G_TMPL_DOC_TYPE
                AND document_id = p_template_id;

        CURSOR sect_csr IS
            SELECT id, object_version_number
            FROM okc_sections_b
            WHERE document_type=G_TMPL_DOC_TYPE
                AND document_id = p_template_id;

    BEGIN
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5000: Entered Merge_Template_Working_Copy');
        END IF;
        -- Standard Start of API savepoint
        SAVEPOINT g_Merge_Template_Working_Copy;
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

        -- ================ Actual Procedure Code Start =======================

        --------------------------------------------
        -- Get template id of original template
        --------------------------------------------
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5100: - get template id of original template');
        END IF;
        --------------------------------------------
        OPEN get_par_id_csr;
        FETCH get_par_id_csr INTO l_base_template_id;
        l_found := get_par_id_csr%FOUND;
        CLOSE get_par_id_csr;
        IF not l_found THEN
            Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'p_template_id');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        --------------------------------------------
        -- Delete Base Template
        --------------------------------------------
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5200: - Delete Base Template');
        END IF;
        --------------------------------------------
        OKC_TERMS_TEMPLATES_PVT.Delete_Row(
            x_return_status         => x_return_status,
            p_template_id           => l_base_template_id,
            p_object_version_number => NULL ,
      p_delete_parent_yn      => 'Y'
        );
        --------------------------------------------
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;
        --------------------------------------------

        --------------------------------------------
        -- Delete Allowed template usage record for base template:
        --------------------------------------------
        ALLOWED_TMPL_USAGES_Delete_Set(
            x_return_status         => x_return_status,
            x_msg_data            => x_msg_data,
            x_msg_count           => x_msg_count,
            p_template_id           => l_base_template_id
        );
        --------------------------------------------
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;
        --------------------------------------------

        --------------------------------------------
        --    Delete record from okc_k_art_varaibles
        --------------------------------------------
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5300: Delete records from okc_k_art_varaibles for the doc');
        END IF;
        --------------------------------------------
        OKC_K_ART_VARIABLES_PVT.delete_set(
            x_return_status => x_return_status,
            p_doc_type      => G_TMPL_DOC_TYPE,
            p_doc_id        => l_base_template_id
        );
        --------------------------------------------
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;
        --------------------------------------------

        --------------------------------------------
        --    Delete record from okc_k_articles_v
        --------------------------------------------
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5400: Delete records from okc_k_articles_v for the doc');
        END IF;
        --------------------------------------------
        OKC_K_ARTICLES_PVT.delete_set(
            x_return_status => x_return_status,
            p_doc_type      => G_TMPL_DOC_TYPE,
            p_doc_id        => l_base_template_id
        );
        --------------------------------------------
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;
        --------------------------------------------

        --------------------------------------------
        --    Delete record from okc_sections_v
        --------------------------------------------
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5500: Delete records from okc_sections_v for the doc');
        END IF;
        OKC_TERMS_SECTIONS_PVT.delete_set(
            x_return_status => x_return_status,
            p_doc_type      => G_TMPL_DOC_TYPE,
            p_doc_id        => l_base_template_id
        );
        --------------------------------------------
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;
        --------------------------------------------

        --------------------------------------------
        -- Delete base template's Deliverables: Call Deliverable API to delete delevirable from the base template.
        --------------------------------------------
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5600: Delete delevirable from the base template');
        END IF;
        Okc_Deliverable_Process_Pvt.Delete_Deliverables(
            p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            p_doc_type      => G_TMPL_DOC_TYPE,
            p_doc_id        => l_base_template_id,
            p_doc_version    => -99,
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


        --------------------------------------------
        -- Update Template Id of working template:
        --------------------------------------------
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5700: Update Template Id of working template to old template');
        END IF;

        OKC_TERMS_TEMPLATES_PVT.Update_Template_Id(
            x_return_status      => x_return_status,
            p_old_template_id    => p_template_id,
            p_new_template_id    => l_base_template_id
        );
        --------------------------------------------
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;
        --------------------------------------------

        --------------------------------------------
        -- Update Allowed template Usages Record:
        --------------------------------------------
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5800: Update Template Id of working template to old template for the template Usages ');
        END IF;
        Update_Allowed_Tmpl_Usages_Id(
            x_return_status      => x_return_status,
            x_msg_data           => x_msg_data,
            x_msg_count          => x_msg_count,
            p_old_template_id    => p_template_id,
            p_new_template_id    => l_base_template_id
        );
        --------------------------------------------
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;
        --------------------------------------------

        --------------------------------------------
        -- Update sections of working template:
        --------------------------------------------
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5900: Update Template Id of working template to old template for the sections');
        END IF;
        FOR cr IN sect_csr LOOP
            --------------------------------------------
            -- Update each record from okc_K_ARTICLES for
            --------------------------------------------
            OKC_TERMS_SECTIONS_PVT.Update_Row(
                x_return_status         => x_return_status,
                p_id                    => cr.id,
                p_document_id           => l_base_template_id,
                p_object_version_number => cr.object_version_number
            );
            --------------------------------------------
            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
            END IF;
            --------------------------------------------
        END LOOP;

        --------------------------------------------
        -- Update articles of working template:
        --------------------------------------------
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'6000: Update Template Id of working template to old template for the articles');
        END IF;
        FOR cr IN kart_csr LOOP
            --------------------------------------------
            -- Update each record from okc_K_ARTICLES for
            --------------------------------------------
            OKC_K_ARTICLES_PVT.Update_Row(
                x_return_status         => x_return_status,
                p_id                    => cr.id,
                p_document_id           => l_base_template_id,
                p_object_version_number => cr.object_version_number
            );
            --------------------------------------------
            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
            END IF;
            --------------------------------------------
        END LOOP;

        --------------------------------------------
        -- Call deliverable APIs to update deliverable records with l_base_template_id
        --------------------------------------------
        OKC_DELIVERABLE_PROCESS_PVT.update_del_for_template_merge (
            p_api_version         => p_api_version ,
            p_init_msg_list       => p_init_msg_list,
            x_msg_data            => x_msg_data  ,
            x_msg_count           => x_msg_count ,
            x_return_status       => x_return_status,

            p_base_template_id    => l_base_template_id,
            p_working_template_id  => p_template_id
        );
        --------------------------------------------
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;
        --------------------------------------------

--Added 11.5.10+ CE
        --------------------------------------------
        -- Call merge_template_rule_assns to merge CE rules
        --------------------------------------------
        OKC_XPRT_TMPL_RULE_ASSNS_PVT.merge_template_rule_assns (
            p_api_version         => p_api_version ,
            p_init_msg_list       => p_init_msg_list,
            p_commit              => FND_API.G_FALSE,
            x_msg_data            => x_msg_data  ,
            x_msg_count           => x_msg_count ,
            x_return_status       => x_return_status,

            p_template_id         => p_template_id,
            p_parent_template_id  => l_base_template_id
        );
        --------------------------------------------
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;
        --------------------------------------------

        --------------------------------------------
        -- Update OKC_TMPL_DRAFT_CLAUSES
        --------------------------------------------
        UPDATE OKC_TMPL_DRAFT_CLAUSES
            SET template_id = l_base_template_id
            WHERE   template_id = p_template_id;

        -- Store the l_base_template_id in the package global variable for
        -- retrieval by the overloaded procedure.
        g_parent_template_id := l_base_template_id;

        -- ================ Actual Procedure Code end =======================

        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'6100: Leaving Merge_Template_Working_Copy');
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO g_Merge_Template_Working_Copy;
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'6200: Leaving Merge_Template_Working_Copy : OKC_API.G_EXCEPTION_ERROR Exception');
            END IF;
            x_return_status := G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO g_Merge_Template_Working_Copy;
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'6300: Leaving Merge_Template_Working_Copy : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
            END IF;
            x_return_status := G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

        WHEN OTHERS THEN
            ROLLBACK TO g_Merge_Template_Working_Copy;
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'6400: Leaving Merge_Template_Working_Copy because of EXCEPTION: '||sqlerrm);
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;
            IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
            END IF;
            FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    END Merge_Template_Working_Copy ;

/*
-- PROCEDURE Get_System_Variables
-- Based on doc type this API will call different integrating API and will
-- get values of all variables being used in Terms and Conditions of a document
*/

  PROCEDURE Get_System_Variables (
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_data          OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,

    p_doc_type          IN  VARCHAR2,
    p_doc_id            IN  NUMBER,
    p_only_doc_variables IN  VARCHAR2 := FND_API.G_TRUE,

    x_sys_var_value_tbl OUT NOCOPY OKC_TERMS_UTIL_GRP.sys_var_value_tbl_type
  ) IS
    l_api_version       CONSTANT NUMBER := 1;
    l_api_name          CONSTANT VARCHAR2(30) := 'Get_System_Variables';
    i NUMBER := 1;
    l_doc_class         VARCHAR2(30) := '?';
    CURSOR var_doc_lst_crs IS
     SELECT distinct var.variable_code
       FROM okc_k_articles_b kart, okc_k_art_variables var
       WHERE kart.document_type=p_doc_type AND kart.document_id=p_doc_id
         and var.cat_id=kart.id AND variable_type='S';

    CURSOR var_def_lst_crs IS
      SELECT busvar.variable_code
         FROM OKC_BUS_DOC_TYPES_B vo, OKC_BUS_VARIABLES_B busvar
         WHERE vo.document_type=p_doc_type AND busvar.contract_expert_yn='Y'
           AND busvar.variable_intent=vo.intent;
    CURSOR doc_cls_lst_crs IS
      SELECT document_type_class
        FROM okc_bus_doc_types_v
        WHERE document_type=p_doc_type;
   BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'6500: Entered Get_System_Variables');
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

    IF p_only_doc_variables = FND_API.G_TRUE THEN
      FOR cr IN var_doc_lst_crs LOOP
       x_sys_var_value_tbl(i).Variable_code := cr.variable_code;
       i := i+1;
      END LOOP;
     ELSE
      FOR cr IN var_def_lst_crs LOOP
       x_sys_var_value_tbl(i).Variable_code := cr.variable_code;
       i := i+1;
      END LOOP;
    END IF;

    OPEN doc_cls_lst_crs;
    FETCH doc_cls_lst_crs INTO l_doc_class;
    CLOSE doc_cls_lst_crs;

    IF l_doc_class in ('BSA','SO') THEN
    --IF l_doc_class = 'OM' THEN
      OKC_OM_INT_GRP.get_article_variable_values(
        p_api_version         => p_api_version ,
        p_init_msg_list       => p_init_msg_list,
        x_msg_data            => x_msg_data  ,
        x_msg_count           => x_msg_count ,
        x_return_status       => x_return_status,

        p_doc_type            => p_doc_type,
        p_doc_id              => p_doc_id,
        p_sys_var_value_tbl   => x_sys_var_value_tbl);

      --------------------------------------------
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;
      --------------------------------------------
     ELSIF l_doc_class = 'PO' THEN
      OKC_PO_INT_GRP.get_article_variable_values(
        p_api_version         => p_api_version ,
        p_init_msg_list       => p_init_msg_list,
        x_msg_data            => x_msg_data  ,
        x_msg_count           => x_msg_count ,
        x_return_status       => x_return_status,

        p_doc_type            => p_doc_type,
        p_doc_id              => p_doc_id,
        p_sys_var_value_tbl   => x_sys_var_value_tbl);
      --------------------------------------------
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;
      --------------------------------------------
     ELSIF l_doc_class = 'SOURCING' THEN

      OKC_PON_INT_GRP.get_article_variable_values(
        p_api_version         => p_api_version ,
        p_init_msg_list       => p_init_msg_list,
        x_msg_data            => x_msg_data  ,
        x_msg_count           => x_msg_count ,
        x_return_status       => x_return_status,

        p_doc_type            => p_doc_type,
        p_doc_id              => p_doc_id,
        p_sys_var_value_tbl   => x_sys_var_value_tbl);
      --------------------------------------------
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;
      --------------------------------------------
     ELSIF l_doc_class = 'QUOTE' THEN

      OKC_ASO_INT_GRP.get_article_variable_values(
        p_api_version         => p_api_version ,
        p_init_msg_list       => p_init_msg_list,
        x_msg_data            => x_msg_data  ,
        x_msg_count           => x_msg_count ,
        x_return_status       => x_return_status,
      --  p_doc_type            => p_doc_type,
        p_doc_id              => p_doc_id,
        p_sys_var_value_tbl   => x_sys_var_value_tbl);

      --------------------------------------------
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;
      --------------------------------------------
          --kkolukul:bug 6924032 Modified for Repository Enhancement
      ELSIF l_doc_class = 'REPOSITORY' THEN

       OKC_XPRT_REP_INT_PVT.get_clause_variable_values(
          p_api_version          => p_api_version,
          p_init_msg_list        => p_init_msg_list,
          p_doc_type             => p_doc_type,
          p_doc_id               => p_doc_id,
          p_sys_var_value_tbl    => x_sys_var_value_tbl,
          x_return_status        => x_return_status,
          x_msg_data             => x_msg_data,
          x_msg_count            => x_msg_count );

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
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'6600: Leaving Get_System_Variables');
    END IF;
   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO g_Get_System_Variables;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'6700: Leaving Get_System_Variables : OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO g_Get_System_Variables;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'6800: Leaving Get_System_Variables : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      ROLLBACK TO g_Get_System_Variables;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'6900: Leaving Get_System_Variables because of EXCEPTION: '||sqlerrm);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
  END Get_System_Variables ;

/*
-- PROCEDURE Substitute_Var_Value_Globally
-- to be called from T and C authoring UI to substitute variable value of any value
-- for every occurance of variable on document
*/
  PROCEDURE Substitute_Var_Value_Globally (
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_data          OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,

    p_doc_type          IN  VARCHAR2,
    p_doc_id            IN  NUMBER,
    p_variable_code     IN  VARCHAR2,
    p_variable_value    IN  VARCHAR2,
    p_variable_value_id IN  VARCHAR2,
    p_mode              IN  VARCHAR2,
    p_validate_commit   IN  VARCHAR2 :=  FND_API.G_TRUE,
    p_validation_string IN VARCHAR2 := NULL
  ) IS
    l_api_version       CONSTANT NUMBER := 1;
    l_api_name          CONSTANT VARCHAR2(30) := 'Substitute_Var_Value_Globally';
    l_dummy             VARCHAR2(10);
    CURSOR var_lst_crs IS
     SELECT cat_id, object_version_number
      FROM okc_k_art_variables
      WHERE variable_code=p_variable_code
        AND cat_id IN (SELECT id FROM okc_k_articles_b
                       WHERE document_type=p_doc_type AND document_id=p_doc_id);
    CURSOR art_lst_crs IS
     SELECT id, object_version_number
       FROM okc_k_articles_b a
       WHERE document_type=p_doc_type AND document_id=p_doc_id
         and EXISTS (SELECT '!' FROM okc_k_art_variables v
                      WHERE v.variable_code=p_variable_code AND v.cat_id = a.cat_id );
   BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7000: Entered Substitute_Var_Value_Globally');
    END IF;
    -- Standard Start of API savepoint
    SAVEPOINT g_Subst_Var_Value_Globally;
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
--        p_tmpl_change         => 'D',

        p_doc_id              => p_doc_id,
        p_doc_type            => p_doc_type
      );
      --------------------------------------------
      IF (l_dummy = 'N' OR x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;
      --------------------------------------------
    END IF;

    FOR cr IN var_lst_crs LOOP
      OKC_K_ART_VARIABLES_PVT.update_row(
        x_return_status          => x_return_status,
        p_cat_id                 => cr.cat_id,
        p_variable_code          => p_variable_code,
        p_variable_type          => NULL,
        p_external_yn            => NULL,
        p_variable_value_id      => p_variable_value_id,
        p_variable_value         => p_variable_value,
        p_attribute_value_set_id => NULL,
        p_object_version_number  => cr.object_version_number
      );
      --------------------------------------------
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;
      --------------------------------------------
    END LOOP;

    IF p_mode = 'AMEND' THEN
      FOR cr IN art_lst_crs LOOP
        OKC_K_ARTICLES_PVT.update_row(
          x_return_status              => x_return_status,
          p_id                         => cr.id,
          p_sav_sae_id                 => NULL,
          p_document_type              => NULL,
          p_document_id                => NULL,
          p_source_flag                => NULL,
          p_mandatory_yn               => NULL,
          p_scn_id                     => NULL,
          p_label                      => NULL,
          p_amendment_description      => NULL,
          p_amendment_operation_code   => G_AMEND_CODE_UPDATED,
          p_article_version_id         => NULL,
          p_change_nonstd_yn           => NULL,
          p_orig_system_reference_code => NULL,
          p_orig_system_reference_id1  => NULL,
          p_orig_system_reference_id2  => NULL,
          p_display_sequence           => NULL,
          p_print_text_yn              => NULL,
          p_object_version_number      => cr.object_version_number
        );
        --------------------------------------------
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR ;
        END IF;
        --------------------------------------------
      END LOOP;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7100: Leaving Substitute_Var_Value_Globally');
    END IF;
   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO g_Subst_Var_Value_Globally;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7200: Leaving Substitute_Var_Value_Globally : OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO g_Subst_Var_Value_Globally;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7300: Leaving Substitute_Var_Value_Globally : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      ROLLBACK TO g_Subst_Var_Value_Globally;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7400: Leaving Substitute_Var_Value_Globally because of EXCEPTION: '||sqlerrm);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
  END Substitute_Var_Value_Globally ;
/*
-- PROCEDURE Create_Unassigned_Section
-- creating un-assigned sections in a document
*/
  PROCEDURE Create_Unassigned_Section (
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 :=  FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_data          OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,

    p_doc_type          IN  VARCHAR2,
    p_doc_id            IN  NUMBER,

    x_scn_id            OUT NOCOPY NUMBER
  ) IS
    l_api_version       CONSTANT NUMBER := 1;
    l_api_name          CONSTANT VARCHAR2(30) := 'Create_Unassigned_Section';
    l_meaning           VARCHAR2(100);
    l_sequence          NUMBER;

Cursor l_get_max_seq_csr IS
SELECT nvl(max(section_sequence),0)+10
FROM OKC_SECTIONS_B
WHERE DOCUMENT_TYPE= p_doc_type
AND   DOCUMENT_ID  = p_doc_id
AND   SCN_ID IS NULL;

   BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7500: Entered Create_Unassigned_Section');
    END IF;
    -- Standard Start of API savepoint
    SAVEPOINT g_Create_Unassigned_Section;
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

    --------------------------------------------
    -- Call Simple API of okc_sections_b with following input
    -- doc_type=p_doc_type, doc_id=p_doc_id, scn_code=G_UNASSIGNED_SECTION_CODE,
    -- heading = < get meaning of G_UNASSIGNED_SECTION_CODE by quering fnd_lookups>.
    -- Set x_scn_id to id returned by simpel API.
    --------------------------------------------
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7600: Calling Simple API to Create a Section');
    END IF;
    --------------------------------------------
    l_meaning := Okc_Util.Decode_Lookup('OKC_ARTICLE_SECTION',G_UNASSIGNED_SECTION_CODE);

--Bug 3669528 Unassigned section should always come at the bottom, so use a 'high' value
/*
    OPEN  l_get_max_seq_csr;
    FETCH l_get_max_seq_csr INTO l_sequence;
    CLOSE l_get_max_seq_csr;
*/
    l_sequence:= 9999;

    OKC_TERMS_SECTIONS_PVT.insert_row(
      x_return_status              => x_return_status,
      p_id                         => NULL,
      p_section_sequence           => l_sequence,
      p_label                      => NULL,
      p_scn_id                     => NULL,
      p_heading                    => l_meaning,
      p_description                => l_meaning,
      p_document_type              => p_doc_type,
      p_document_id                => p_doc_id,
      p_scn_code                   => G_UNASSIGNED_SECTION_CODE,
      p_amendment_description      => NULL,
      p_amendment_operation_code   => NULL,
      p_orig_system_reference_code => NULL,
      p_orig_system_reference_id1  => NULL,
      p_orig_system_reference_id2  => NULL,
      p_print_yn                   => 'N',
      x_id                         => x_scn_id
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7700: Leaving Create_Unassigned_Section');
    END IF;
   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO g_Create_Unassigned_Section;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7800: Leaving Create_Unassigned_Section : OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;

      IF l_get_max_seq_csr%ISOPEN THEN
         CLOSE l_get_max_seq_csr;
      END IF;

      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO g_Create_Unassigned_Section;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7900: Leaving Create_Unassigned_Section : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;

      IF l_get_max_seq_csr%ISOPEN THEN
         CLOSE l_get_max_seq_csr;
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      ROLLBACK TO g_Create_Unassigned_Section;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'8000: Leaving Create_Unassigned_Section because of EXCEPTION: '||sqlerrm);
      END IF;

      IF l_get_max_seq_csr%ISOPEN THEN
         CLOSE l_get_max_seq_csr;
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
  END Create_Unassigned_Section ;
/*
-- To Check if document type is valid
*/
FUNCTION is_doc_type_valid(
p_doc_type      IN  VARCHAR2,
x_return_status OUT NOCOPY VARCHAR2
) RETURN  VARCHAR2 IS
l_dummy    VARCHAR2(1)  := '?';
l_return   VARCHAR2(1) := FND_API.G_TRUE;
cursor l_check_doc_type_crs IS
SELECT 'X' FROM OKC_BUS_DOC_TYPES_B
           WHERE document_type=p_doc_type;
BEGIN

OPEN  l_check_doc_type_crs;
FETCH l_check_doc_type_crs INTO l_dummy;
IF l_check_doc_type_crs%NOTFOUND THEN
   return FND_API.G_FALSE;
ELSE
   return FnD_API.G_TRUE;
END IF;

CLOSE l_check_doc_type_crs;

return l_return;
x_return_status := G_RET_STS_SUCCESS ;

EXCEPTION
WHEN OTHERS THEN

IF l_check_doc_type_crs%ISOPEN THEN
   CLOSE l_check_doc_type_crs;
END IF;
return  FND_API.G_FALSE;
x_return_status := G_RET_STS_UNEXP_ERROR ;

END;
/*
-- FUNCTION Get_Message
-- to be used to put tokens in messages code and return translated messaged.
-- It will be mainly used by QA API.                  |
*/
  FUNCTION Get_Message (
    p_app_name       IN VARCHAR2,
    p_msg_name       IN VARCHAR2,
    p_token1         IN VARCHAR2,
    p_token1_value   IN VARCHAR2,
    p_token2         IN VARCHAR2,
    p_token2_value   IN VARCHAR2,
    p_token3         IN VARCHAR2,
    p_token3_value   IN VARCHAR2,
    p_token4         IN VARCHAR2,
    p_token4_value   IN VARCHAR2,
    p_token5         IN VARCHAR2,
    p_token5_value   IN VARCHAR2,
    p_token6         IN VARCHAR2,
    p_token6_value   IN VARCHAR2,
    p_token7         IN VARCHAR2,
    p_token7_value   IN VARCHAR2,
    p_token8         IN VARCHAR2,
    p_token8_value   IN VARCHAR2,
    p_token9         IN VARCHAR2,
    p_token9_value   IN VARCHAR2,
    p_token10        IN VARCHAR2,
    p_token10_value  IN VARCHAR2
  ) RETURN VARCHAR2 IS
  BEGIN
    Fnd_Message.Set_Name( p_app_name, p_msg_name );
    IF (p_token1 IS NOT NULL) AND (p_token1_value IS NOT NULL) THEN
      Fnd_Message.Set_Token( token => p_token1, value => p_token1_value);
    END IF;
    IF (p_token2 IS NOT NULL) AND (p_token2_value IS NOT NULL) THEN
      Fnd_Message.Set_Token( token => p_token2, value => p_token2_value);
    END IF;
    IF (p_token3 IS NOT NULL) AND (p_token3_value IS NOT NULL) THEN
      Fnd_Message.Set_Token( token => p_token3, value => p_token3_value);
    END IF;
    IF (p_token4 IS NOT NULL) AND (p_token4_value IS NOT NULL) THEN
      Fnd_Message.Set_Token( token => p_token4, value => p_token4_value);
    END IF;
    IF (p_token5 IS NOT NULL) AND (p_token5_value IS NOT NULL) THEN
      Fnd_Message.Set_Token( token => p_token5, value => p_token5_value);
    END IF;
    IF (p_token6 IS NOT NULL) AND (p_token6_value IS NOT NULL) THEN
      Fnd_Message.Set_Token( token => p_token6, value => p_token6_value);
    END IF;
    IF (p_token7 IS NOT NULL) AND (p_token7_value IS NOT NULL) THEN
      Fnd_Message.Set_Token( token => p_token7, value => p_token7_value);
    END IF;
    IF (p_token8 IS NOT NULL) AND (p_token8_value IS NOT NULL) THEN
      Fnd_Message.Set_Token( token => p_token8, value => p_token8_value);
    END IF;
    IF (p_token9 IS NOT NULL) AND (p_token9_value IS NOT NULL) THEN
      Fnd_Message.Set_Token( token => p_token9, value => p_token9_value);
    END IF;
    IF (p_token10 IS NOT NULL) AND (p_token10_value IS NOT NULL) THEN
      Fnd_Message.Set_Token( token => p_token10, value => p_token10_value);
    END IF;
    RETURN Fnd_Message.Get;

  END Get_Message;

/* Modified Cursor for Bug 4956969 */
Function Get_latest_art_version(p_article_id  IN NUMBER,
                            p_org_id IN NUMBER,
                            p_eff_date IN DATE)
  RETURN Varchar2 IS
  l_display_name okc_article_versions.display_name%TYPE;
  l_global_org_id number;
  CURSOR ver_csr IS
  SELECT nvl(ver.display_name,art.article_title) name
  FROM okc_articles_all art,
       okc_article_versions ver
  WHERE art.org_id = p_org_id
  AND art.article_id = p_article_id
  AND art.article_id = ver.article_id
  AND ver.start_date <= nvl(p_eff_date,sysdate)
  AND ver.start_date = (select max(start_date)
                            from okc_article_versions ver1
                            where ver1.article_id = ver.article_id
                            and ver1.start_date <= nvl(p_eff_date,sysdate)
					   and ver1.article_status = ver.article_status)
  AND (ver.article_status = 'APPROVED' OR
      not exists (select 1
                  from okc_article_versions ver2
                  where ver2.article_id = art.article_id
                  and ver2.start_date <= nvl(p_eff_date,sysdate)
                  and ver2.article_status = 'APPROVED'));

BEGIN
    Open ver_csr;
    Fetch ver_csr Into l_display_name;
    Close ver_csr;
    Return l_display_name;
End Get_latest_art_version;

/* Modified Cursor for Bug 4956969 */
Function Get_latest_tmpl_art_version_id(p_article_id  IN NUMBER,
           p_eff_date IN DATE)
  RETURN NUMBER IS
  l_article_version_id okc_article_versions.article_version_id%TYPE;
  CURSOR ver_csr IS
  SELECT ver.article_version_id
  FROM okc_articles_all art,
       okc_article_versions ver
  WHERE art.article_id = p_article_id
  AND art.article_id = ver.article_id
  AND ver.start_date <= nvl(p_eff_date,sysdate)
  AND ver.start_date = (select max(start_date)
                            from okc_article_versions ver1
                            where ver1.article_id = ver.article_id
                            and ver1.start_date <= nvl(p_eff_date,sysdate)
					   and ver1.article_status = ver.article_status)
  AND (ver.article_status = 'APPROVED' OR
       not exists (select 1
                  from okc_article_versions ver2
                  where ver2.article_id = art.article_id
                  and ver2.start_date <= nvl(p_eff_date,sysdate)
                  and ver2.article_status = 'APPROVED'));
BEGIN
  Open ver_csr;
  Fetch ver_csr Into l_article_version_id;
  Close ver_csr;
  Return l_article_version_id;
End Get_latest_tmpl_art_version_id;


/*********************************
-- FUNCTION Get_alternate_yn
--
*********************************/
Function Get_alternate_yn(p_article_id  IN NUMBER,
                            p_org_id IN NUMBER)
  RETURN Varchar2 IS

  l_alternate_yn varchar(1) := 'N';
  l_global_org_id number;

  CURSOR alt_csr IS
  SELECT 1
  FROM dual
  WHERE exists (select 1
                from OKC_ARTICLE_RELATNS_ALL
                where org_id = p_org_id
                and source_article_id = p_article_id
                and relationship_type = 'ALTERNATE');
BEGIN
    Open alt_csr;
    Fetch alt_csr Into l_alternate_yn;
    if alt_csr%found then
      l_alternate_yn := 'Y';
    else
      l_alternate_yn := 'N';
    end if;
    Close alt_csr;
    Return l_alternate_yn;

End Get_alternate_yn;


/*********************************
-- FUNCTION Tmpl_Intent_Editable
--
*********************************/
Function Tmpl_Intent_Editable(p_template_id  IN NUMBER)
  RETURN Varchar2 IS

  l_editable_yn varchar(1) := 'N';
  l_deliverables_exist varchar2(250);
  x_return_status varchar2(150);
  x_msg_data varchar2(2000);
  x_msg_count number;

  CURSOR editable_csr IS
  SELECT 1
  FROM okc_terms_templates_all
  WHERE template_id = p_template_id
  AND working_copy_flag = 'Y'
  UNION ALL
  SELECT 1
  FROM okc_allowed_tmpl_usages
  WHERE template_id = p_template_id
  UNION ALL
  SELECT 1
  FROM okc_k_articles_b
  WHERE document_type = 'TEMPLATE'
  AND   document_id = p_template_id;

BEGIN
  Open editable_csr;
  Fetch editable_csr Into l_editable_yn;
    if editable_csr%found then
      l_editable_yn := 'N';
    else
      l_editable_yn := 'Y';
    end if;
  Close editable_csr;
  IF l_editable_yn = 'Y' THEN
    l_deliverables_exist :=  okc_terms_util_grp.Is_Deliverable_Exist(
         p_api_version      => 1,
         p_init_msg_list    =>  FND_API.G_FALSE,
         x_return_status    => x_return_status,
         x_msg_data         => x_msg_data,
         x_msg_count        => x_msg_count,
         p_doc_type         => 'TEMPLATE',
         p_doc_id           => p_template_id);
    IF  UPPER(nvl(l_deliverables_exist,'NONE')) <> 'NONE' THEN
      l_editable_yn := 'N';
    END IF;
  END IF;
  Return l_editable_yn;

End Tmpl_Intent_Editable;



/*********************************
-- FUNCTION Has_Alternates
--
*********************************/
Function Has_Alternates(p_article_id  IN NUMBER,
                        p_eff_date IN DATE,
                        p_document_type IN VARCHAR2)
  RETURN Varchar2 IS

  l_alternate_yn varchar(1) := 'N';

  CURSOR alt_csr IS
  SELECT 1
  FROM okc_article_relatns_all reln,
       okc_article_versions ver
  WHERE reln.source_article_id = p_article_id
  AND reln.relationship_type = 'ALTERNATE'
  AND reln.target_article_id = ver.article_id
  AND NVL(p_eff_date,SYSDATE) BETWEEN ver.start_date AND NVL(ver.end_date, nvl(p_eff_date,SYSDATE))
  AND ver.article_status = 'APPROVED'
  AND reln.org_id = mo_global.get_current_org_id()
  AND ( ver.provision_yn = 'N' OR
        ( p_document_type IN (select document_type
                                from okc_bus_doc_types_b
                               where provision_allowed_yn = 'Y'
                             )
        )
      );

BEGIN
    Open alt_csr;
    Fetch alt_csr Into l_alternate_yn;
    if alt_csr%found then
      l_alternate_yn := 'Y';
    else
      l_alternate_yn := 'N';
    end if;
    Close alt_csr;
    Return l_alternate_yn;

End Has_alternates;

FUNCTION Has_Alternates(p_article_id  IN NUMBER,
                        p_start_date IN DATE,
                        p_end_date IN DATE,
                        p_org_id IN NUMBER,
                        p_document_type IN VARCHAR2)
  RETURN Varchar2 IS

  l_effective_date DATE;
  l_alternate_yn varchar(1) := 'N';

  CURSOR alt_csr(cp_effective_date DATE) IS
  SELECT 1
  FROM   okc_article_relatns_all reln,
         okc_article_versions ver,
     okc_articles_all art
  WHERE  reln.source_article_id = p_article_id
  AND    reln.relationship_type = 'ALTERNATE'
  AND    reln.target_article_id = art.article_id
  AND    art.article_id = ver.article_id
  AND    cp_effective_date BETWEEN ver.start_date AND NVL(ver.end_date, cp_effective_date)
  AND ( ( p_document_type = 'TEMPLATE')  OR  ( ver.article_status IN ('APPROVED','ON_HOLD')) )
  AND reln.org_id = p_org_id
  AND ( (p_org_id = art.org_id
    )
        OR
        ( exists ( SELECT 1
                   FROM   okc_article_ADOPTIONS ADP
                   WHERE  adp.global_article_version_id = ver.article_version_id
                   AND    adp.adoption_type = 'ADOPTED'
                   AND    adp.local_org_id = p_org_id
                   AND    adp.adoption_status IN ( 'APPROVED', 'ON_HOLD')
         )
        )
      )
  AND ( ver.provision_yn = 'N' OR
        ( p_document_type
      IN ( SELECT document_type
               FROM okc_bus_doc_types_b
               WHERE provision_allowed_yn = 'Y'
             )
        )
      );

BEGIN
  IF p_document_type = 'TEMPLATE' THEN
    IF ((p_end_date IS NULL) OR (TRUNC(p_end_date) >= TRUNC(SYSDATE)))  THEN
      IF TRUNC(p_start_date) < TRUNC(SYSDATE) THEN
        l_effective_date := TRUNC(SYSDATE);
      ELSE
        l_effective_date := TRUNC(p_start_date);
      END IF;
    ELSIF TRUNC(p_end_date) < TRUNC(SYSDATE) THEN
      l_effective_date := TRUNC(p_end_date);
    END IF;
  ELSE
    l_effective_date := NVL(p_start_date,TRUNC(SYSDATE));
  END IF;

  OPEN alt_csr(l_effective_date);
  FETCH alt_csr Into l_alternate_yn;
    IF alt_csr%found then
      l_alternate_yn := 'Y';
    ELSE
      l_alternate_yn := 'N';
    END IF;
  CLOSE alt_csr;
  RETURN l_alternate_yn;

END Has_alternates;

FUNCTION Has_amendments(p_document_id  IN NUMBER,
                        p_document_type IN VARCHAR2,
            p_document_version IN NUMBER)
  RETURN Varchar2 IS
  l_amendment VARCHAR2(150);
  l_return_status VARCHAR2(150);
  l_msg_data VARCHAR2(2000);
  l_msg_count NUMBER;

  CURSOR l_art_amendment_csr IS
  SELECT 1
  FROM okc_k_articles_b kart,
       okc_template_usages usg
  WHERE usg.document_type = p_document_type
  AND usg.document_id = p_document_id
  AND usg.document_type = kart.document_type
  AND usg.document_id = kart.document_id
  AND NVL(usg.contract_source_code,'STRUCTURED') = 'STRUCTURED'
  AND (kart.amendment_operation_code IS NOT NULL OR
      kart.summary_amend_operation_code IS NOT NULL)
  UNION ALL
  SELECT 1
  FROM okc_sections_b scn,
       okc_template_usages usg
  WHERE usg.document_type = p_document_type
  AND usg.document_id = p_document_id
  AND NVL(usg.contract_source_code,'STRUCTURED') = 'STRUCTURED'
  AND usg.document_type = scn.document_type
  AND usg.document_id = scn.document_id
  AND (scn.amendment_operation_code IS NOT NULL OR
      scn.summary_amend_operation_code IS NOT NULL)
  UNION ALL
  SELECT 1
  FROM okc_contract_docs kdoc,
       okc_template_usages usg
  WHERE usg.document_type = p_document_type
  AND usg.document_id = p_document_id
  AND usg.document_type = kdoc.business_document_type
  AND usg.document_id = kdoc.business_document_id
  AND NVL(usg.contract_source_code,'STRUCTURED') = 'ATTACHED'
  AND kdoc.primary_contract_doc_flag = 'Y'
  AND kdoc.delete_flag = 'Y'
  AND kdoc.effective_from_version = p_document_version
  AND ((NVL(p_document_version, -99) = -99)
        OR
        (
     exists (SELECT 1
             FROM
         OKC_TEMPLATE_USAGES_H usgH
       WHERE
         usgH.document_type = p_document_type
         AND usgH.document_id = p_document_id
         AND usgH.major_version < p_document_version
      )
      )
   )
  UNION ALL
  SELECT 1
  FROM okc_contract_docs kdoc,
       okc_template_usages usg
  WHERE usg.document_type = p_document_type
  AND usg.document_id = p_document_id
  AND usg.document_type = kdoc.business_document_type
  AND usg.document_id = kdoc.business_document_id
  AND NVL(usg.contract_source_code,'STRUCTURED') = 'ATTACHED'
  AND kdoc.primary_contract_doc_flag = 'Y'
  AND kdoc.business_document_type = kdoc.effective_from_type
  AND kdoc.business_document_id = kdoc.effective_from_id
  AND kdoc.business_document_version = kdoc.effective_from_version
  AND ((kdoc.effective_from_version > 0 and
        kdoc.effective_from_version = p_document_version)OR
        kdoc.effective_from_version = -99)
  AND ((NVL(p_document_version, -99) = -99)
        OR
        (
     exists (SELECT 1
             FROM
         OKC_TEMPLATE_USAGES_H usgH
       WHERE
         usgH.document_type = p_document_type
         AND usgH.document_id = p_document_id
         AND usgH.major_version < p_document_version
      )
      )
   )
    ;
BEGIN
  OPEN l_art_amendment_csr;
  FETCH l_art_amendment_csr INTO l_amendment;
  IF l_art_amendment_csr%FOUND THEN
    RETURN 'Y';
  END IF;
  CLOSE l_art_amendment_csr;


  l_amendment :=
  OKC_DELIVERABLE_PROCESS_PVT.deliverables_amended(
                 p_api_version      => 1,
                 p_init_msg_list    => FND_API.G_FALSE,

                 x_return_status    => l_return_status,
                 x_msg_data        => l_msg_data,
                 x_msg_count        => l_msg_count,

                 p_doctype  => p_document_type,
                 p_docid => p_document_id);


  IF NVL(l_amendment,'NONE') = 'NONE' THEN
    RETURN 'N';
  ELSE
    RETURN 'Y';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'N';
END Has_amendments;





/*********************************
-- FUNCTION get_summary_amend_code
--
*********************************/
FUNCTION get_summary_amend_code(
   p_existing_summary_code IN VARCHAR2,
   p_existing_operation_code IN VARCHAR2, -- we don't need the parameter, but keep it for compatibility
   p_amend_operation_code  IN VARCHAR2
  ) return  VARCHAR2 IS
  l_new_summary_code OKC_K_ARTICLES_B.SUMMARY_AMEND_OPERATION_CODE%TYPE;

BEGIN

   IF p_existing_summary_code='ADDED' AND p_amend_operation_code ='DELETED' THEN
     l_new_summary_code:=FND_API.G_MISS_CHAR; -- Summary should be set to NULL
    ELSIF p_existing_summary_code='ADDED' AND p_amend_operation_code = 'UPDATED' THEN
     l_new_summary_code:=p_existing_summary_code;
    ELSIF p_existing_summary_code='DELETED' AND p_amend_operation_code = 'UPDATED' THEN
     l_new_summary_code:=p_existing_summary_code;
    ELSIF p_existing_summary_code='DELETED' AND p_amend_operation_code = 'ADDED' THEN
     l_new_summary_code:=FND_API.G_MISS_CHAR;
    ELSE
     l_new_summary_code := p_amend_operation_code;
   END IF;

   return l_new_summary_code;

END get_summary_amend_code;

/*********************************
-- FUNCTION get_actual_summary_amend_code
-- Wraps get_summary_amend_code and replaces G_MISS_CHAR with null
*********************************/
FUNCTION get_actual_summary_amend_code(
   p_existing_summary_code IN VARCHAR2,
   p_existing_operation_code IN VARCHAR2,
   p_amend_operation_code  IN VARCHAR2
  ) return  VARCHAR2 IS
  l_new_summary_code OKC_K_ARTICLES_B.SUMMARY_AMEND_OPERATION_CODE%TYPE;

BEGIN
         l_new_summary_code:=get_summary_amend_code(p_existing_summary_code=>p_existing_summary_code,
                  p_existing_operation_code=>p_existing_operation_code,
                  p_amend_operation_code=>p_amend_operation_code);

     if l_new_summary_code = FND_API.G_MISS_CHAR then
    return NULL;
     end if;

     return l_new_summary_code;
END get_actual_summary_amend_code;



/*********************************
-- FUNCTION get_article_version_number
--
*********************************/
FUNCTION get_article_version_number(p_art_version_id IN NUMBER)
  RETURN Varchar2 IS
CURSOR csr_art_ver IS
SELECT article_version_number
FROM okc_article_versions
WHERE article_version_id = p_art_version_id;

l_article_version_number VARCHAR2(240);

BEGIN
 OPEN csr_art_ver;
   FETCH csr_art_ver INTO l_article_version_number;
 CLOSE csr_art_ver;
 RETURN l_article_version_number;
END get_article_version_number;

/*********************************
-- FUNCTION get_section_label
--
*********************************/
FUNCTION get_section_label(p_scn_id IN NUMBER)
  RETURN Varchar2 IS
CURSOR csr_section_label IS
SELECT heading
FROM okc_sections_b
WHERE id = p_scn_id;

l_label VARCHAR2(240);

BEGIN
 OPEN csr_section_label;
   FETCH csr_section_label INTO l_label;
 CLOSE csr_section_label;
 RETURN l_label;
END get_section_label;

/*********************************
-- FUNCTION get_latest_art_version_no
--
*********************************/
FUNCTION get_latest_art_version_no(
  p_article_id IN NUMBER,
  p_document_type IN VARCHAR2,
  p_document_id IN NUMBER )
RETURN Varchar2 IS

l_article_version_number VARCHAR2(240);
l_article_version_id  NUMBER;
l_local_article_id NUMBER;
l_adoption_type VARCHAR2(100);

BEGIN

 get_latest_article_details
 (
  p_article_id  => p_article_id,
  p_document_type => p_document_type,
  p_document_id => p_document_id,
  x_article_version_id => l_article_version_id,
  x_article_version_number => l_article_version_number,
  x_local_article_id => l_local_article_id,
  x_adoption_type => l_adoption_type
 );

 RETURN l_article_version_number;

END get_latest_art_version_no;

/*********************************
-- FUNCTION get_latest_art_version_id
--
*********************************/
FUNCTION get_latest_art_version_id(
  p_article_id IN NUMBER,
  p_document_type IN VARCHAR2,
  p_document_id IN NUMBER )
RETURN NUMBER IS

l_article_version_number VARCHAR2(240);
l_article_version_id  NUMBER;
l_local_article_id NUMBER;
l_adoption_type VARCHAR2(100);

BEGIN

 get_latest_article_details
 (
  p_article_id  => p_article_id,
  p_document_type => p_document_type,
  p_document_id => p_document_id,
  x_article_version_id => l_article_version_id,
  x_article_version_number => l_article_version_number,
  x_local_article_id => l_local_article_id,
  x_adoption_type => l_adoption_type
 );

 RETURN l_article_version_id;

END get_latest_art_version_id;

/*********************************
-- FUNCTION get_article_name
--
*********************************/
FUNCTION get_article_name(
 p_article_id IN NUMBER,
 p_article_version_id IN NUMBER)
RETURN Varchar2 IS

CURSOR csr_article_title IS
SELECT a.article_title, a.article_number
FROM okc_articles_all a
WHERE a.article_id = p_article_id;

CURSOR csr_article_display_name IS
SELECT a.display_name
FROM okc_article_versions a
WHERE a.article_version_id = p_article_version_id;

l_article_title VARCHAR2(450) :='';
l_article_number VARCHAR2(450) :='';
l_display_name VARCHAR2(450) :='';
l_article_name VARCHAR2(1000) :='';

BEGIN

  OPEN csr_article_title;
    FETCH csr_article_title INTO l_article_title, l_article_number;
  CLOSE csr_article_title;

  OPEN csr_article_display_name;
    FETCH csr_article_display_name INTO l_display_name;
  CLOSE csr_article_display_name;

 IF g_concat_art_no = 'Y' THEN
    IF l_article_number IS NOT NULL THEN
       l_article_number := l_article_number||':';
    END IF;
    l_article_name := NVL(l_article_number,'')||NVL(l_display_name,l_article_title);
 ELSE
    l_article_name := NVL(l_display_name,l_article_title);
 END IF;

 RETURN l_article_name;
END get_article_name;

/*********************************
-- FUNCTION GET_SECTION_NAME
--
*********************************/
FUNCTION GET_SECTION_NAME(
            p_CONTEXT IN VARCHAR2,
            p_ID IN NUMBER
                )
    RETURN VARCHAR2 IS

       -- Fix for Bug 5377982
	  -- l_name varchar2(80) := null;
	     l_name   OKC_SECTIONS_B.HEADING%TYPE := null;



         cursor section_cur(l_section_id NUMBER) is
         select HEADING FROM OKC_SECTIONS_B WHERE ID = l_section_id ;

         cursor section_for_article_id(l_article_id NUMBER) is
         select HEADING FROM OKC_SECTIONS_B WHERE ID = (select scn_id from okc_k_articles_b where id = l_article_id) ;


    BEGIN

    if p_CONTEXT = 'SECTION' THEN
        Open  section_cur(p_ID);
        fetch section_cur into l_name;
        close section_cur;
    elsif p_CONTEXT = 'ARTICLE' THEN
        Open  section_for_article_id(p_ID);
        fetch section_for_article_id into l_name;
        close section_for_article_id;
    else
        l_name := null;
    end if;

    return(l_name);


    END GET_SECTION_NAME;

/*********************************
-- FUNCTION GET_SECTION_NAME - given article_version_id returns the default section or the Unassinged Section name
--
*********************************/


  FUNCTION GET_SECTION_NAME(p_article_version_id NUMBER)
    RETURN VARCHAR2 IS

    --l_name varchar2(80) := null;
    l_name   FND_LOOKUPS.MEANING%TYPE := null;
    l_article_version_id NUMBER;
    cursor get_default_section_name(l_article_version_id NUMBER) is
    select meaning from fnd_lookups where lookup_type = 'OKC_ARTICLE_SECTION' and lookup_code = (
    select default_section from okc_article_versions where article_version_id = l_article_version_id);

    cursor get_unassigned_section_name is
      select meaning from fnd_lookups where lookup_type = 'OKC_ARTICLE_SECTION' and
         lookup_code = 'UNASSIGNED';


    BEGIN

           open get_default_section_name(p_article_version_id);
           fetch get_default_section_name into l_name;
           if get_default_section_name%NOTFOUND or l_name is null THEN
             open get_unassigned_section_name;
              fetch get_unassigned_section_name into l_name;
              close get_unassigned_section_name;
           end if;
           close get_default_section_name;
    return(l_name);
    END GET_SECTION_NAME;

/*********************************
  FUNCTION GET_SECTION_NAME - returns Default section for article_version
  or one defined in expert enabled template.
  Parameters: p_article_version_id
          p_template_id
**********************************/

function get_section_name(p_article_version_id IN Number,
           p_template_id in Number)
 return varchar2 is
 --l_name varchar2(80);
 l_name FND_LOOKUPS.MEANING%TYPE;

 cursor get_article_section_name(l_article_version_id NUMBER) is
 select meaning from fnd_lookups
  where lookup_type = 'OKC_ARTICLE_SECTION'
    and lookup_code = (select default_section from okc_article_versions
                        where article_version_id = l_article_version_id);

 cursor get_expert_section_name(l_template_id NUMBER) is
 select meaning from fnd_lookups
  where lookup_type = 'OKC_ARTICLE_SECTION'
    and lookup_code = (select xprt_scn_code from okc_terms_templates_all
                        where template_id = l_template_id);

 cursor get_unassigned_section_name is
 select meaning from fnd_lookups where lookup_type = 'OKC_ARTICLE_SECTION'
    and lookup_code = 'UNASSIGNED';

 Begin

    Open get_article_section_name(p_article_version_id);
    Fetch get_article_section_name into l_name;

    If get_article_section_name%FOUND and l_name is NOT NULL then
        close get_article_section_name;
        return l_name;
    end if;

    Open get_expert_section_name (p_template_id);
    Fetch get_expert_section_name into l_name;

    If get_expert_section_name%FOUND and l_name is NOT NULL then
        close get_expert_section_name;
        return l_name;
    end if;

    Open get_unassigned_section_name;
    Fetch get_unassigned_section_name into l_name;

    If get_unassigned_section_name%FOUND and l_name is NOT NULL then
        close get_unassigned_section_name;
        return l_name;
    end if;

Exception
WHEN OTHERS then
    if  get_article_section_name%ISOPEN then
        close get_article_section_name;
    end if;
    if get_expert_section_name%ISOPEN then
        close get_expert_section_name;
    end if;
    if get_unassigned_section_name%ISOPEN then
        close get_unassigned_section_name;
    end if;

end get_section_name;



/*********************************
-- FUNCTION GET_VALUE_SET_VARIABLE_VALUE
--
*********************************/
    FUNCTION  GET_VALUE_SET_VARIABLE_VALUE (
    p_CONTEXT            IN VARCHAR2,
      p_VALUE_SET_ID                  IN NUMBER,
    p_FLEX_VALUE_ID            IN VARCHAR2 )
    RETURN VARCHAR2 IS

    --l_name varchar2(80) := null;
    l_name FND_FLEX_VALUES_VL.FLEX_VALUE%TYPE := null;

      cursor flex_value_vl_csr(l_value_set_id NUMBER, l_flex_value_id VARCHAR2) is
          select value.flex_value
             from   fnd_flex_values_vl value,
                fnd_flex_value_sets val_set
             where
                      value.FLEX_VALUE_SET_ID = val_set.FLEX_VALUE_SET_ID
              and val_set.flex_value_set_id = l_value_set_id
                  and to_char(value.flex_value_id)= l_flex_value_id;

    BEGIN

    if p_CONTEXT = 'I' THEN
        Open  flex_value_vl_csr(p_VALUE_SET_ID, p_FLEX_VALUE_ID);
        fetch flex_value_vl_csr into l_name;
        close flex_value_vl_csr;
      else
        l_name := null;
    end if;

    return(l_name);
    END GET_VALUE_SET_VARIABLE_VALUE;


/*********************************
-- PROCEDURE get_latest_article_details
--
*********************************/
PROCEDURE get_latest_article_details(
  p_article_id IN NUMBER,
  p_document_type IN VARCHAR2,
  p_document_id IN NUMBER,
  x_article_version_id OUT NOCOPY NUMBER,
  x_article_version_number OUT NOCOPY VARCHAR2,
  x_local_article_id OUT NOCOPY NUMBER,
  x_adoption_type OUT NOCOPY VARCHAR2 ) IS

CURSOR csr_effective_date IS
SELECT tu.article_effective_date
FROM okc_template_usages tu
WHERE tu.document_type = p_document_type
  AND tu.document_id = p_document_id;

-- effectivity date for templates
CURSOR csr_template_effective_date IS
SELECT start_date, end_date
FROM OKC_TERMS_TEMPLATES_ALL
WHERE template_id=p_document_id;

CURSOR l_get_latest_article_csr(p_article_effective_date IN DATE) IS
SELECT article_version_id ,
       article_version_number
FROM okc_article_versions
WHERE  article_id= p_article_id
AND    article_status in ('ON_HOLD','APPROVED')
AND    sysdate >= Start_date
AND    sysdate <= nvl(end_date,sysdate+1)
AND    p_document_type <> 'TEMPLATE'
UNION ALL
SELECT article_version_id ,
       article_version_number
FROM okc_article_versions
WHERE  article_id= p_article_id
AND    nvl(p_article_effective_date,sysdate) >= Start_date
AND    nvl(p_article_effective_date,sysdate) <= nvl(end_date, nvl(p_article_effective_date,sysdate) +1)
AND    p_document_type = 'TEMPLATE'
;

CURSOR l_get_local_article_csr(p_article_effective_date IN DATE, b_local_org_id IN NUMBER) IS
SELECT ADP.LOCAL_ARTICLE_VERSION_ID LOCAL_ARTICLE_VERSION_ID,
       ADP.ADOPTION_TYPE,
       VERS1.ARTICLE_ID
FROM   OKC_ARTICLE_VERSIONS VERS,
       OKC_ARTICLE_ADOPTIONS  ADP,
       OKC_ARTICLE_VERSIONS  VERS1
WHERE ADP.GLOBAL_ARTICLE_VERSION_ID = VERS.ARTICLE_VERSION_ID
AND    VERS.ARTICLE_ID         = p_article_id
AND    nvl(p_article_effective_date,sysdate) >=  VERS.START_DATE
AND    nvl(p_article_effective_date,sysdate) <= nvl(VERS.end_date, nvl(p_article_effective_date,sysdate) +1)
AND    VERS.ARTICLE_STATUS     IN ('ON_HOLD','APPROVED')
AND    VERS1.ARTICLE_VERSION_ID     =ADP.LOCAL_ARTICLE_VERSION_ID
AND    ADP.ADOPTION_TYPE = 'LOCALIZED'
AND    ADP.LOCAL_ORG_ID = b_local_org_id
AND  ADP.adoption_status IN ( 'APPROVED', 'ON_HOLD')
AND  p_document_type <> 'TEMPLATE'
UNION ALL
SELECT ADP.GLOBAL_ARTICLE_VERSION_ID LOCAL_ARTICLE_VERSION_ID,
       ADP.ADOPTION_TYPE,
       VERS.ARTICLE_ID
FROM   OKC_ARTICLE_VERSIONS VERS,
       OKC_ARTICLE_ADOPTIONS  ADP
WHERE ADP.GLOBAL_ARTICLE_VERSION_ID = VERS.ARTICLE_VERSION_ID
AND    VERS.ARTICLE_ID         = p_article_id
AND    nvl(p_article_effective_date,sysdate) >=  VERS.START_DATE
AND    nvl(p_article_effective_date,sysdate) <= nvl(VERS.end_date, nvl(p_article_effective_date,sysdate) +1)
AND    VERS.ARTICLE_STATUS     IN ('ON_HOLD','APPROVED')
AND    ADP.ADOPTION_TYPE = 'ADOPTED'
AND    ADP.LOCAL_ORG_ID = b_local_org_id
AND  ADP.adoption_status IN ( 'APPROVED', 'ON_HOLD')
AND  p_document_type <> 'TEMPLATE'
UNION ALL
SELECT ADP.LOCAL_ARTICLE_VERSION_ID LOCAL_ARTICLE_VERSION_ID,
       ADP.ADOPTION_TYPE,
       VERS1.ARTICLE_ID
FROM   OKC_ARTICLE_VERSIONS VERS,
       OKC_ARTICLE_ADOPTIONS  ADP,
       OKC_ARTICLE_VERSIONS  VERS1
WHERE ADP.GLOBAL_ARTICLE_VERSION_ID = VERS.ARTICLE_VERSION_ID
AND    VERS.ARTICLE_ID         = p_article_id
AND    nvl(p_article_effective_date,sysdate) >=  VERS.START_DATE
AND    nvl(p_article_effective_date,sysdate) <= nvl(VERS.end_date, nvl(p_article_effective_date,sysdate) +1)
AND    VERS1.ARTICLE_VERSION_ID     =ADP.LOCAL_ARTICLE_VERSION_ID
AND    ADP.ADOPTION_TYPE = 'LOCALIZED'
AND    ADP.LOCAL_ORG_ID = b_local_org_id
AND  ADP.adoption_status IN ( 'APPROVED', 'ON_HOLD')
AND  p_document_type = 'TEMPLATE'
UNION ALL
SELECT ADP.GLOBAL_ARTICLE_VERSION_ID LOCAL_ARTICLE_VERSION_ID,
       ADP.ADOPTION_TYPE,
       VERS.ARTICLE_ID
FROM   OKC_ARTICLE_VERSIONS VERS,
       OKC_ARTICLE_ADOPTIONS  ADP
WHERE ADP.GLOBAL_ARTICLE_VERSION_ID = VERS.ARTICLE_VERSION_ID
AND    VERS.ARTICLE_ID         = p_article_id
AND    nvl(p_article_effective_date,sysdate) >=  VERS.START_DATE
AND    nvl(p_article_effective_date,sysdate) <= nvl(VERS.end_date, nvl(p_article_effective_date,sysdate) +1)
AND    ADP.ADOPTION_TYPE = 'ADOPTED'
AND    ADP.LOCAL_ORG_ID = b_local_org_id
AND  ADP.adoption_status IN ( 'APPROVED', 'ON_HOLD')
AND  p_document_type = 'TEMPLATE'
;

CURSOR l_get_article_org_csr IS
SELECT org_id
FROM OKC_ARTICLES_ALL
WHERE article_id = p_article_id;

CURSOR l_article_number (b_article__version_id IN NUMBER) IS
SELECT article_version_number
FROM okc_article_versions
WHERE article_version_id= b_article__version_id;
 l_api_name                     CONSTANT VARCHAR2(30) := 'get_latest_article_details';
l_effective_date DATE := null;
l_article_version_id NUMBER;
l_article_version_number VARCHAR2(240);
l_adoption_type  VARCHAR2(100);
l_local_article_id  NUMBER;
l_current_org_id VARCHAR2(100);
l_article_org_id  NUMBER;
l_template_start_date  DATE :=null;
l_template_end_date DATE :=null;

BEGIN

 IF p_document_type = 'TEMPLATE' THEN
   OPEN csr_template_effective_date;
     FETCH csr_template_effective_date INTO l_template_start_date, l_template_end_date;
   CLOSE csr_template_effective_date;

    IF NVL(l_template_end_date,sysdate) >= sysdate  THEN
       IF l_template_start_date > sysdate THEN
          l_effective_date := l_template_start_date;
       ELSE
          l_effective_date := sysdate;
       END IF;
    ELSE
       l_effective_date := l_template_end_date;
    END IF;

 ELSE
   -- document type not TEMPLATE
   OPEN csr_effective_date;
     FETCH csr_effective_date INTO l_effective_date;
   CLOSE csr_effective_date;
 END IF;

 -- check if Article is global or local
    OPEN l_get_article_org_csr;
      FETCH l_get_article_org_csr INTO l_article_org_id;
    CLOSE l_get_article_org_csr;

 -- current Org Id
    -- fnd_profile.get('ORG_ID',l_current_org_id);
    l_current_org_id := OKC_TERMS_UTIL_PVT.get_current_org_id(p_document_type, p_document_id);

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: l_article_org_id : '||l_article_org_id);
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: l_current_org_id : '||l_current_org_id);
    END IF;

    IF nvl(l_current_org_id,'?') <> l_article_org_id THEN
       -- this is a ADOPTED OR LOCALIZED ARTICLE
       OPEN  l_get_local_article_csr(l_effective_date , l_current_org_id);
         FETCH l_get_local_article_csr INTO l_article_version_id, l_adoption_type, l_local_article_id;
       CLOSE l_get_local_article_csr;
       -- get article version number
       OPEN l_article_number(l_article_version_id);
         FETCH l_article_number INTO l_article_version_number;
       CLOSE l_article_number;

        x_article_version_id  := l_article_version_id;
        x_article_version_number := l_article_version_number;
        x_local_article_id := l_local_article_id;
        x_adoption_type  := l_adoption_type;

    ELSE
      -- normal case
        OPEN l_get_latest_article_csr (l_effective_date);
          FETCH l_get_latest_article_csr INTO l_article_version_id,l_article_version_number;
        CLOSE l_get_latest_article_csr;

        x_article_version_id  := l_article_version_id;
        x_article_version_number := l_article_version_number;
        x_local_article_id := p_article_id;
        x_adoption_type  := NULL;

    END IF;

END get_latest_article_details;

/*********************************
-- FUNCTION get_local_article_id
--
*********************************/
FUNCTION get_local_article_id(
  p_article_id IN NUMBER,
  p_document_type IN VARCHAR2,
  p_document_id IN NUMBER )
RETURN NUMBER IS
   l_api_name                     CONSTANT VARCHAR2(30) := 'get_local_article_id';
l_article_version_number VARCHAR2(240);
l_article_version_id  NUMBER;
l_local_article_id NUMBER;
l_adoption_type VARCHAR2(100);

BEGIN

 get_latest_article_details
 (
  p_article_id  => p_article_id,
  p_document_type => p_document_type,
  p_document_id => p_document_id,
  x_article_version_id => l_article_version_id,
  x_article_version_number => l_article_version_number,
  x_local_article_id => l_local_article_id,
  x_adoption_type => l_adoption_type
 );

 RETURN l_local_article_id;

END get_local_article_id;

/*********************************
-- FUNCTION get_adoption_type
--
*********************************/

FUNCTION get_adoption_type(
  p_article_id IN NUMBER,
  p_document_type IN VARCHAR2,
  p_document_id IN NUMBER )
RETURN Varchar2 IS
l_api_name                     CONSTANT VARCHAR2(30) := 'get_adoption_type';
l_article_version_number VARCHAR2(240);
l_article_version_id  NUMBER;
l_local_article_id NUMBER;
l_adoption_type VARCHAR2(100);

BEGIN

 get_latest_article_details
 (
  p_article_id  => p_article_id,
  p_document_type => p_document_type,
  p_document_id => p_document_id,
  x_article_version_id => l_article_version_id,
  x_article_version_number => l_article_version_number,
  x_local_article_id => l_local_article_id,
  x_adoption_type => l_adoption_type
 );

 RETURN l_adoption_type;

END get_adoption_type;

/*********************************
-- FUNCTION get_print_template_name
--
*********************************/
FUNCTION get_print_template_name(p_print_template_id IN NUMBER)
RETURN VARCHAR2 IS
  l_api_name                     CONSTANT VARCHAR2(30) := 'get_print_template_name';
l_sql_stmt VARCHAR2(4000);
l_print_template_name VARCHAR2(255);
l_dummy VARCHAR2(1);
TYPE name_csr IS REF CURSOR;
l_tmpl_csr NAME_CSR;
l_apps_user VARCHAR2(150);

CURSOR l_apps_user_csr IS
  SELECT oracle_username
  FROM fnd_oracle_userid
  WHERE read_only_flag = 'U';

CURSOR l_xdo_view_csr(pc_user VARCHAR2) IS
SELECT 1
FROM all_views
WHERE view_name like 'XDO_TEMPLATES_VL'
AND owner = pc_user;

BEGIN

  OPEN l_apps_user_csr;
  FETCH l_apps_user_csr INTO l_apps_user;
  CLOSE l_apps_user_csr;

  OPEN l_xdo_view_csr(l_apps_user);
  FETCH l_xdo_view_csr INTO l_dummy;
  IF l_xdo_view_csr%FOUND THEN
    l_sql_stmt := 'SELECT SUBSTR(TEMPLATE_NAME,1,255) FROM XDO_TEMPLATES_VL WHERE TEMPLATE_ID = :1';

    OPEN l_tmpl_csr FOR l_sql_stmt USING p_print_template_id;
    FETCH l_tmpl_csr INTO l_print_template_name;
    CLOSE l_tmpl_csr;
  END IF;
  CLOSE l_xdo_view_csr;

  RETURN l_print_template_name;

END get_print_template_name;


/*********************************
-- FUNCTION get_current_org_id
--
*********************************/
FUNCTION get_current_org_id
(
 p_doc_type   IN  VARCHAR2,
 p_doc_id     IN  NUMBER
) RETURN NUMBER IS

CURSOR l_org_id_csr IS
SELECT t.org_id
FROM okc_terms_templates_all t,
     okc_template_usages u
WHERE t.template_id = u.template_id
  AND u.document_type = p_doc_type
  AND u.document_id =   p_doc_id ;

CURSOR l_tmpl_org_id_csr IS
SELECT  t.org_id
FROM okc_terms_templates_all t
WHERE t.template_id = p_doc_id ;

l_current_org_id NUMBER;
 l_api_name                     CONSTANT VARCHAR2(30) := 'get_current_org_id';
BEGIN
 IF p_doc_type = G_TMPL_DOC_TYPE  THEN
   OPEN l_tmpl_org_id_csr;
     FETCH l_tmpl_org_id_csr INTO l_current_org_id;
   CLOSE l_tmpl_org_id_csr;
 ELSE
   -- doc is not template
   OPEN l_org_id_csr;
     FETCH l_org_id_csr INTO l_current_org_id;
   CLOSE l_org_id_csr;
 END IF;

 RETURN l_current_org_id;

END get_current_org_id;


FUNCTION get_template_model_name
(
 p_template_id   IN  NUMBER,
 p_template_model_id     IN  NUMBER
) RETURN VARCHAR2 IS
x_return_status VARCHAR2(50);
x_msg_count NUMBER;
x_msg_data VARCHAR2(4000);
x_template_model_name VARCHAR2(255) NULL;
x_published_by VARCHAR2(255) := NULL;
x_publish_date DATE := NULL;
x_publication_id NUMBER := NULL;
 l_api_name                     CONSTANT VARCHAR2(30) := 'get_template_model_name';
BEGIN
  BEGIN
        /*
      * Removed call to OKC_EXPRT_UTIL_GRP for 11.5.10+: Contract Expert Changes
      */
      x_template_model_name := NULL;
  EXCEPTION
    WHEN OTHERS THEN
      x_template_model_name := NULL;
  END;

RETURN x_template_model_name;
END;

FUNCTION get_tmpl_model_published_by
(
 p_template_id   IN  NUMBER,
 p_template_model_id     IN  NUMBER
) RETURN VARCHAR2 IS
x_return_status VARCHAR2(50);
x_msg_count NUMBER;
x_msg_data VARCHAR2(4000);
x_template_model_name VARCHAR2(255) NULL;
x_published_by VARCHAR2(255) := NULL;
x_publish_date DATE := NULL;
x_publication_id NUMBER := NULL;

BEGIN
  BEGIN

        /*
      * Removed call to OKC_EXPRT_UTIL_GRP for 11.5.10+: Contract Expert Changes
      */
      x_published_by := NULL;
  EXCEPTION
    WHEN OTHERS THEN
      x_published_by := NULL;
  END;

RETURN x_published_by;
END;

FUNCTION get_tmpl_model_publish_date
(
 p_template_id   IN  NUMBER,
 p_template_model_id     IN  NUMBER
) RETURN DATE IS
x_return_status VARCHAR2(50);
x_msg_count NUMBER;
x_msg_data VARCHAR2(4000);
x_template_model_name VARCHAR2(255) NULL;
x_published_by VARCHAR2(255) := NULL;
x_publish_date DATE := NULL;
x_publication_id NUMBER := NULL;
 l_api_name                     CONSTANT VARCHAR2(30) := 'get_tmpl_model_publish_date';
BEGIN
  BEGIN

        /*
      * Removed call to OKC_EXPRT_UTIL_GRP for 11.5.10+: Contract Expert Changes
      */
      x_publish_date := NULL;
  EXCEPTION
    WHEN OTHERS THEN
      x_publish_date := NULL;
  END;

RETURN x_publish_date;
END;
FUNCTION get_chr_id_for_doc_id
(
 p_document_id    IN  NUMBER
 ) RETURN NUMBER IS
 l_api_name                     CONSTANT VARCHAR2(30) := 'get_chr_id_for_doc_id';
 CURSOR l_get_id IS
SELECT  id
FROM okc_k_headers_b
WHERE document_id = p_document_id ;
l_chr_id   NUMBER;
 BEGIN
    open l_get_id;
    fetch l_get_id into l_chr_id;
    close l_get_id;
    return l_chr_id;
  END;

--Checks if the given function is accessible to the user and returns 'Y' if accessible else 'N'
FUNCTION is_Function_Accessible(
  p_function_name    IN VARCHAR2
 ) RETURN VARCHAR2 IS
 l_api_name                     CONSTANT VARCHAR2(30) := 'is_Function_Accessible';
BEGIN
   IF (p_function_name is null) THEN
      RETURN 'N' ;
   ELSIF fnd_function.test(p_function_name,'N') THEN
          RETURN 'Y' ;
   ELSE
     RETURN 'N' ;
   END IF;
EXCEPTION
 WHEN OTHERS THEN
   IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2000: Leaving is_Function_Accessible because of EXCEPTION: '||sqlerrm);
   END IF;
 RETURN NULL;
END is_Function_Accessible;

/************************************************************************************
--Procedure that checks for template information for a given documentId, documentType
  Input: p_document_type,
         p_document_id,
         p_mode
         p_eff_date
         p_org_id

   Returns: x_template_exists
            x_template_id
            x_template_name
            x_enable_expert_button
            x_template_org_id
            x_doc_numbering_scheme
            x_config_header_id
            x_config_revision_number
            x_valid_config_yn
   Purpose: For the given document_type, document_id,
            a.if there is no record in
              template_usages, returns the default template details if one exists
            b.else it returns the template information as listed in the Out variables
              If the mode is not 'VIEW', it updates the template usages record based on
              business rules.

   Where Used: In Authoring page: Structure page invokes this procedure
*************************************************************************************/
PROCEDURE get_template_details (
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 :=  FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_data          OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,

    p_document_type          IN  VARCHAR2,
    p_document_id            IN  NUMBER,
    p_mode in VARCHAR2,
  p_eff_date IN DATE,
  p_org_id   IN NUMBER,
  x_template_exists OUT NOCOPY VARCHAR2,
  x_template_id OUT NOCOPY NUMBER,
  x_template_name OUT NOCOPY VARCHAR2,
  x_enable_expert_button OUT NOCOPY VARCHAR2,
  x_template_org_id OUT NOCOPY NUMBER,
  x_doc_numbering_scheme OUT NOCOPY VARCHAR2,
  x_config_header_id OUT NOCOPY NUMBER,
  x_config_revision_number OUT NOCOPY NUMBER,
    x_valid_config_yn OUT NOCOPY VARCHAR2
  ) IS
    l_api_version       CONSTANT NUMBER := 1;
    l_api_name          CONSTANT VARCHAR2(30) := 'get_template_details';
    l_meaning           VARCHAR2(100);
    l_sequence          NUMBER;

    l_template_exists VARCHAR2(5) := 'false';
    l_template_id NUMBER := 0;
    l_template_name  VARCHAR2(2000);
    l_enable_expert_button VARCHAR2(5) := 'false';
    l_template_org_id NUMBER;

    l_doc_numbering_scheme VARCHAR(2000);
    l_config_header_id  NUMBER;
    l_config_revision_number NUMBER;
    l_valid_config_yn VARCHAR2(2000);
    l_article_effective_date DATE;
    l_update_date BOOLEAN := false;
    l_update_date_with DATE := FND_API.G_MISS_DATE;


Cursor l_get_template_details_csr IS
select a.template_id, b.template_name, a.article_effective_date,
a.doc_numbering_scheme,
a.config_header_id, a.config_revision_number,
a.valid_config_yn, b.org_id
from okc_template_usages a ,okc_terms_templates_all b
where a.template_id = b.template_id
and a.document_id = p_document_id and a.document_type = p_document_type;

cursor l_get_dflt_tmpl_dtls_csr is
select a.template_id, b.template_name
    from
    okc_allowed_tmpl_usages a, okc_terms_templates_all b
    where a.template_id = b.template_id
    and a.default_yn = 'Y'
    and b.status_code = 'APPROVED'
    and a.document_type = p_document_type
    and b.org_id = p_org_id
    and nvl(p_eff_date,trunc(sysdate)) between start_date and nvl(end_date, trunc(sysdate));

   BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7500: Entered get_template_details');
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

        x_template_exists  := 'false';
        x_template_id := 0;
        x_enable_expert_button  := 'false';
        x_template_org_id  := 0;


    --------------------------------------------
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7600: get_template_details');
    END IF;
    --------------------------------------------



    open l_get_template_details_csr;
    fetch l_get_template_details_csr into l_template_id, l_template_name,
    l_article_effective_date,
      x_doc_numbering_scheme,
    l_config_header_id, l_config_revision_number,
    l_valid_config_yn, l_template_org_id;
    IF l_get_template_details_csr%NOTFOUND  THEN
        if(p_mode <> 'UPDATE') THEN
         close l_get_template_details_csr;
        else
            open l_get_dflt_tmpl_dtls_csr;
            fetch l_get_dflt_tmpl_dtls_csr into l_template_id, l_template_name;
            if l_get_dflt_tmpl_dtls_csr%NOTFOUND THEN
                x_template_exists := 'false';
            else
                x_template_exists :='false';
                x_enable_expert_button := 'false';
                x_template_id := l_template_id;
                x_template_name := l_template_name;
            end if;
            close l_get_dflt_tmpl_dtls_csr;
        end if;
    else
        x_template_exists := 'true';
        x_template_id := l_template_id;
        x_template_name := l_template_name;
        x_template_org_id := l_template_org_id;

        x_config_header_id := l_config_header_id;
        x_config_revision_number := l_config_revision_number;
        x_doc_numbering_scheme :=l_doc_numbering_scheme;
        x_valid_config_yn := l_valid_config_yn;

        if( p_mode is not null and p_mode <> 'VIEW') THEN
               OKC_XPRT_UTIL_PVT.enable_expert_button(
                p_api_version                         => p_api_version,
                p_init_msg_list           => NULL,
                p_template_id                      => x_template_id,
                p_document_id                     => p_document_id,
                p_document_type                    => p_document_type,
                x_enable_expert_button                => x_enable_expert_button,
                x_return_status              => x_return_status,
                x_msg_count                => x_msg_count,
                x_msg_data                   => x_msg_data );
        l_update_date := false;
        if(l_article_effective_date is NULL) then
            l_update_date := true;
            l_update_date_with := p_eff_date;
        elsif(l_article_effective_date <> p_eff_date and p_eff_date is NULL) then
            l_update_date := true;
            l_update_date_with := FND_API.G_MISS_DATE;
        elsif(l_article_effective_date <> p_eff_date ) then
            l_update_date := true;
            l_update_date_with := p_eff_date;
        end if;
        if(l_update_date) then
       UPDATE okc_template_usages
          SET article_effective_date = l_update_date_with
          WHERE document_type = p_document_type
          AND document_id = p_document_id;
        end if;
      end if;
    end if;
    IF l_get_template_details_csr%ISOPEN THEN
        CLOSE l_get_template_details_csr;
    END IF;




    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7700: Leaving get_template_details');
    END IF;
   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7800: Leaving get_template_details : OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;

      IF l_get_template_details_csr%ISOPEN THEN
         CLOSE l_get_template_details_csr;
      END IF;

      IF l_get_dflt_tmpl_dtls_csr%ISOPEN THEN
         CLOSE l_get_dflt_tmpl_dtls_csr;
      END IF;


      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7900: Leaving get_template_details : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;

      IF l_get_template_details_csr%ISOPEN THEN
         CLOSE l_get_template_details_csr;
      END IF;
      IF l_get_dflt_tmpl_dtls_csr%ISOPEN THEN
         CLOSE l_get_dflt_tmpl_dtls_csr;
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'8000: Leaving get_template_details because of EXCEPTION: '||sqlerrm);
      END IF;

      IF l_get_template_details_csr%ISOPEN THEN
         CLOSE l_get_template_details_csr;
      END IF;
      IF l_get_dflt_tmpl_dtls_csr%ISOPEN THEN
         CLOSE l_get_dflt_tmpl_dtls_csr;
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
  END get_template_details ;


--Checks if the given section is deleted
FUNCTION is_section_deleted(
  p_scn_id    IN NUMBER
 ) RETURN VARCHAR2 IS
 /*
  This function will be called from Update Section Page
  Given a scn_id it will return the following:
  'D' If the section is deleted i.e AMENDMENT_OPERATION_CODE or SUMMARY_AMEND_OPERATION_CODE is 'DELETED'
  'E' If the scn_id does not exists which will result in Stale Data Error
  'S' If the scn_id is NOT deleted and exists
 */
 CURSOR csr_check_section IS
 SELECT amendment_operation_code,summary_amend_operation_code
 FROM okc_sections_b
 WHERE id = p_scn_id;
 l_api_name                     CONSTANT VARCHAR2(30) := 'is_section_deleted';
 l_amendment_operation_code        VARCHAR2(30);
 l_summary_amend_operation_code    VARCHAR2(30);
 l_return                          VARCHAR2(1);

BEGIN
   OPEN csr_check_section;
     FETCH csr_check_section INTO l_amendment_operation_code, l_summary_amend_operation_code;
     IF csr_check_section%NOTFOUND THEN
       l_return := 'E';
     ELSE
        IF (NVL(l_amendment_operation_code,'x') = 'DELETED' OR
           NVL(l_summary_amend_operation_code,'x') = 'DELETED') THEN
           l_return := 'D';
        ELSE
            l_return := 'S';
        END IF;
     END IF;
   CLOSE csr_check_section;

   RETURN l_return;

EXCEPTION
 WHEN OTHERS THEN
   IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2000: Leaving is_section_deleted because of EXCEPTION: '||sqlerrm);
   END IF;
 RETURN NULL;

END is_section_deleted;

--Checks if the given article is deleted
FUNCTION is_article_deleted(
  p_cat_id    IN NUMBER,
  p_article_id IN NUMBER
 ) RETURN VARCHAR2 IS
 /*
  This function will be called from Update Article Page
  Given a cat_id and sav_sae_id it will return the following:
  'D' If the article is deleted i.e AMENDMENT_OPERATION_CODE or SUMMARY_AMEND_OPERATION_CODE is 'DELETED'
  'E' If the sav_sae_id does not match the sav_sae_id in record
  'S' If the article record is NOT deleted and exists
 */
 CURSOR csr_check_article IS
 SELECT amendment_operation_code,summary_amend_operation_code
 FROM okc_k_articles_b
 WHERE id = p_cat_id
   AND sav_sae_id = p_article_id ;
 l_api_name                     CONSTANT VARCHAR2(30) := 'is_article_deleted';
 l_amendment_operation_code        VARCHAR2(30);
 l_summary_amend_operation_code    VARCHAR2(30);
 l_return                          VARCHAR2(1);

BEGIN
  OPEN csr_check_article;
    FETCH csr_check_article INTO  l_amendment_operation_code, l_summary_amend_operation_code;
     IF csr_check_article%NOTFOUND THEN
        l_return := 'E';
     ELSE
        IF (NVL(l_amendment_operation_code,'x') = 'DELETED' OR
           NVL(l_summary_amend_operation_code,'x') = 'DELETED') THEN
           l_return := 'D';
        ELSE
            l_return := 'S';
        END IF;
     END IF;

EXCEPTION
 WHEN OTHERS THEN
   IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2000: Leaving is_article_deleted because of EXCEPTION: '||sqlerrm);
   END IF;
 RETURN NULL;

END is_article_deleted;


--Checks if the given article has deliverable type variables and the deliverable is amended
--To be used by the Printing program
 FUNCTION deliverable_amendment_exists(
  p_cat_id    IN NUMBER,
  p_document_id IN NUMBER,
  p_document_type IN VARCHAR2
 ) RETURN VARCHAR2 IS
 /*
  This function will be called from Printing Program
  Given a cat_id, document_type and document_id it will return the following:
  'Y' If the clause has deliverable type variables and deliverable amendments exist
  'N' If (the clause has no deliverable type variables) OR
         (has deliverable type variables AND deliverable amendments do not exist)
 */

 CURSOR l_doc_variable_csr IS
 SELECT variable_code
 FROM okc_k_art_variables
 WHERE cat_id = p_cat_id
 AND variable_type = 'D';
 l_api_name                     CONSTANT VARCHAR2(30) := 'deliverable_amendment_exists';
 l_variable_type        okc_k_art_variables.variable_type%TYPE;
 l_return               VARCHAR2(1) := 'N';
 l_msg_data             VARCHAR2(2000);
 l_msg_count            NUMBER;
 l_return_status        VARCHAR2(30);

BEGIN
  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1000: Entered OKC_TERMS_UTIL_PVT.deliverable_amendment_exists');
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1010: p_cat_id='||p_cat_id);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1020: p_document_id='||p_document_id);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1030: p_document_type='||p_document_type);
  END IF;
  FOR rec IN l_doc_variable_csr LOOP
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1040: Before calling OKC_DELIVERABLE_PROCESS_PVT.deliverable_amendment_exists');
    END IF;
    l_return :=  OKC_DELIVERABLE_PROCESS_PVT.deliverable_amendment_exists
                            ( p_api_version       => 1,
                              p_init_msg_list     => FND_API.G_FALSE,
                              p_bus_doc_type      => p_document_type,
                              p_bus_doc_id        => p_document_id,
                              p_variable_code     => rec.variable_code,
                              x_msg_data          => l_msg_data,
                              x_msg_count         => l_msg_count,
                              x_return_status     => l_return_status);
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1050: After calling OKC_DELIVERABLE_PROCESS_PVT.deliverable_amendment_exists');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1060: x_return_status='||l_return_status);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1070: l_return='||l_return);
    END IF;
    IF l_return = 'Y' THEN
      RETURN l_return;
    END IF;
  END LOOP;
  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1090: l_return='||l_return);
  END IF;

  RETURN l_return;

EXCEPTION
 WHEN OTHERS THEN
   IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1090: Leaving OKC_TERMS_UTIL_PVT.deliverable_amendment_exists because of EXCEPTION: '||sqlerrm);
   END IF;
 RETURN 'N';

END deliverable_amendment_exists;

/*
-- PROCEDURE purge_qa_results
-- Called by concurrent program to purge old QA error data.
-- Parameter p_num_days is how far in the past to start the purge
*/
   PROCEDURE purge_qa_results (
    errbuf  OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY VARCHAR2,
    p_num_days IN NUMBER default 3)
    IS
    l_api_name      CONSTANT VARCHAR2(30) :='purge_qa_validation_results';
    l_api_version     CONSTANT VARCHAR2(30) := 1.0;
    l_init_msg_list   VARCHAR2(3) := 'T';
    l_return_status   VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(1000);
    l_num_days        NUMBER;

    E_Resource_Busy   EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy,  -00054);

    BEGIN
         IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,l_api_name,'100: Inside OKC_TERMS_UTIL_PVT.PURGE_QA_RESULTS');
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,l_api_name,'Parameters:  p_num_days='||p_num_days);
     END IF;

     FND_FILE.PUT_LINE(FND_FILE.LOG,'Parameters:  p_num_days='||p_num_days);
    if p_num_days < 1 then
      l_num_days := 1;
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Setting p_num_days to 1 to prevent any current data from being deleted');
    else
      l_num_days := p_num_days;
    end if;

    --Initialize the return code
        retcode := 0;

    delete from OKC_QA_ERRORS_T qa
    where creation_date <= sysdate - l_num_days;

    commit;

         IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,l_api_name,'100: leaving OKC_TERMS_UTIL_PVT.PURGE_QA_RESULTS');
         END IF;
EXCEPTION
    WHEN E_Resource_Busy THEN
      l_return_status := fnd_api.g_ret_sts_error;
         IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_api_name,'200: Resource busy exception');
         END IF;
      IF FND_MSG_PUB.Count_Msg > 0 Then
        FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
        END LOOP;

      END IF;
      FND_MSG_PUB.initialize;
      RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    WHEN OTHERS THEN
      retcode := 2;
      errbuf  := substr(sqlerrm,1,200);
      IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_api_name,'200: Other exception');
         END IF;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF;
      IF FND_MSG_PUB.Count_Msg > 0 Then
        FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
        END LOOP;
      END IF;
      FND_MSG_PUB.initialize;

    END PURGE_QA_RESULTS;

    ------------------------------------------------------
    -- FUNCTION get_latest_tmpl_art_version_id
    -------------------------------------------------------
    /*
    -- 11.5.10+
    -- 2004/8/20 ANJKUMAR: overloaded function with additional params
    -- p_doc_type and p_doc_id, changes logic only for p_doc_type = 'TEMPLATE'
    -- looks in first in new table OKC_TMPL_DRAFT_CLAUSES if status
    -- DRAFT/REJECTED/PENDING_APPROVAL for article versions
    --
    */
    FUNCTION get_latest_tmpl_art_version_id(
        p_article_id    IN NUMBER,
        p_start_date    IN DATE,
        p_end_date        IN DATE,
        p_status_code    IN VARCHAR2,
        p_doc_type        IN VARCHAR2 DEFAULT NULL,
        p_doc_id        IN NUMBER DEFAULT NULL
        ,p_org_id        in number default null) RETURN NUMBER
    IS
        l_article_version_id okc_article_versions.article_version_id%TYPE;
        l_effective_date DATE;
        l_article_org_id NUMBER;
        l_current_org_id NUMBER;
 l_api_name                     CONSTANT VARCHAR2(30) := 'get_latest_tmpl_art_version_id';
        -- new variable
        l_stop BOOLEAN := TRUE;

        -- new cursor to get draft/rejected versions from table OKC_TMPL_DRAFT_CLAUSES
        CURSOR l_draft_selected_ver_csr IS
        SELECT ARTV.article_version_id
        FROM OKC_TMPL_DRAFT_CLAUSES TMPLC,
             OKC_ARTICLE_VERSIONS ARTV
        WHERE TMPLC.template_id = p_doc_id
            AND TMPLC.article_id = p_article_id
            AND TMPLC.selected_yn     = 'Y'
              AND ARTV.article_id = TMPLC.article_id
            AND ARTV.article_version_id = TMPLC.article_version_id
            AND ARTV.article_status in ('DRAFT', 'REJECTED')
            AND EXISTS (SELECT 1 FROM OKC_K_ARTICLES_B KART
                    WHERE  KART.document_type = p_doc_type
                    AND KART.document_id = p_doc_id
                    AND KART.sav_sae_id = TMPLC.article_id);

        -- modify this cursor to exclude versions from the the table OKC_DRAFT_CLAUSES
        CURSOR l_draft_ver_csr(cp_effective_date DATE) IS
            SELECT ver.article_version_id
            FROM okc_articles_all art,
                okc_article_versions ver
            WHERE art.article_id = p_article_id
                AND art.article_id = ver.article_id
                AND cp_effective_date BETWEEN ver.start_date AND NVL(ver.end_date,cp_effective_date+1)
                -- begin change
                -- Bug 4021182, we cannot include pending approval, on hold or expired clauses here
                AND VER.article_status IN ('APPROVED', 'DRAFT', 'REJECTED')
                AND NOT EXISTS (SELECT 1 from OKC_TMPL_DRAFT_CLAUSES TMPLC
                    WHERE TMPLC.template_id = p_doc_id
                    AND TMPLC.article_id = p_article_id
                    AND    TMPLC.article_version_id = VER.article_version_id)
                -- end change
                ORDER BY ver.article_version_number DESC;

        -- last effort to get a clause for template in draft status
        CURSOR l_draft_latest_ver_csr(cp_effective_date DATE) IS
            SELECT ver.article_version_id
            FROM okc_articles_all art,
                okc_article_versions ver
            WHERE art.article_id = p_article_id
                AND art.article_id = ver.article_id
                -- Bugs 4018610, 4018467, the start date of draft clause can be
                -- changed to a future date, making this cursor return nothing
                -- The draft clause status can also change to pending approval
                -- or an approved clause can be put on hold after including in the template
                -- AND ver.start_date <= cp_effective_date
                AND ver.start_date = (SELECT max(start_date)
                    FROM okc_article_versions ver1
                    WHERE ver1.article_id = ver.article_id
                    --AND ver1.start_date <= cp_effective_date
                    --AND ver1.article_status = 'APPROVED'
                    );

        -- new cursor to get draft/rejected versions from table OKC_TMPL_DRAFT_CLAUSES
        CURSOR l_pen_app_selected_ver_csr IS
            SELECT ARTV.article_version_id
            FROM OKC_TMPL_DRAFT_CLAUSES TMPLC,
                OKC_ARTICLE_VERSIONS ARTV
            WHERE TMPLC.template_id = p_doc_id
                AND TMPLC.article_id = p_article_id
                AND TMPLC.selected_yn     = 'Y'
                AND ARTV.article_id = TMPLC.article_id
                AND ARTV.article_version_id = TMPLC.article_version_id
                AND ARTV.article_status = 'PENDING_APPROVAL'
                AND EXISTS (SELECT 1 FROM OKC_K_ARTICLES_B KART
                    WHERE  KART.document_type = p_doc_type
                    AND KART.document_id = p_doc_id
                    AND KART.sav_sae_id = TMPLC.article_id);


        CURSOR l_approved_ver_csr(cp_effective_date DATE) IS
            SELECT ver.article_version_id
            FROM okc_articles_all art,
                okc_article_versions ver
            WHERE art.article_id = p_article_id
                AND art.article_id = ver.article_id
                AND ver.article_status IN  ('APPROVED','EXPIRED','ON_HOLD')
                AND cp_effective_date BETWEEN ver.start_date AND NVL(ver.end_date,cp_effective_date+1);

        CURSOR l_approved_latest_ver_csr(cp_effective_date DATE) IS
            SELECT ver.article_version_id
            FROM okc_articles_all art,
                okc_article_versions ver
            WHERE art.article_id = p_article_id
                AND art.article_id = ver.article_id
                AND ver.start_date <= cp_effective_date
                AND ver.article_status IN ('APPROVED','EXPIRED','ON_HOLD')
                AND ver.start_date = (SELECT max(start_date)
                    FROM okc_article_versions ver1
                    WHERE ver1.article_id = ver.article_id
                    AND ver1.start_date <= cp_effective_date
                    AND ver1.article_status IN ('APPROVED','EXPIRED','ON_HOLD'));

        -- cursor to get article org id and local org id
        CURSOR l_get_article_org_csr(b_article_id NUMBER) IS
            SELECT org_id,
            mo_global.get_current_org_id() current_org_id
            FROM OKC_ARTICLES_ALL
            WHERE article_id = b_article_id;

        -- cursor to get latest adopted article version id for global article
        CURSOR l_get_max_adopted_article_csr(b_article_id IN NUMBER, b_current_org_id IN NUMBER) IS
            SELECT ADP.GLOBAL_ARTICLE_VERSION_ID
                FROM OKC_ARTICLE_ADOPTIONS  ADP,
                    OKC_ARTICLE_VERSIONS VER
                WHERE ADP.GLOBAL_ARTICLE_VERSION_ID = VER.article_version_id
                    AND   VER.article_id = b_article_id
                    AND   ADP.LOCAL_ORG_ID = b_current_org_id
                    --AND   ADP.adoption_status IN ( 'APPROVED', 'ON_HOLD')
                    AND   ADP.ADOPTION_TYPE IN ('ADOPTED','AVAILABLE')
                    ORDER BY VER.article_version_number desc,
                 DECODE(ADP.adoption_status,'APPROVED','001','ON_HOLD','001','002') desc;


    BEGIN
        -- determine the effective date
        IF ((p_end_date IS NULL) OR (TRUNC(p_end_date) >= TRUNC(SYSDATE)))  THEN
            IF TRUNC(p_start_date) < TRUNC(SYSDATE) THEN
                l_effective_date := TRUNC(sysdate);
            ELSE
                l_effective_date := TRUNC(p_start_date);
            END IF;

        ELSIF TRUNC(p_end_date) < TRUNC(SYSDATE) THEN
            l_effective_date := TRUNC(p_end_date);
        END IF;


 -- check if this is a global article in local template
        OPEN l_get_article_org_csr(p_article_id);
        FETCH l_get_article_org_csr INTO l_article_org_id, l_current_org_id;
        CLOSE l_get_article_org_csr;

         -- For bug fix 15875890
         if p_org_id is not null then
            l_current_org_id :=  p_org_id;
         end if;

        -- if the org ids are different then display the lastest adopted version
        IF l_article_org_id <> l_current_org_id THEN
            OPEN l_get_max_adopted_article_csr(p_article_id, l_current_org_id);
            FETCH l_get_max_adopted_article_csr INTO l_article_version_id;
            CLOSE l_get_max_adopted_article_csr;

            RETURN l_article_version_id;
        END IF; -- global article in local template


        IF p_status_code IN ('DRAFT','REJECTED','REVISION') THEN

            -- begin changes
            IF (NVL(p_doc_type,'*') = 'TEMPLATE' AND p_doc_id is not null) THEN
                OPEN l_draft_selected_ver_csr;
                FETCH l_draft_selected_ver_csr INTO l_article_version_id;

                IF l_draft_selected_ver_csr%NOTFOUND THEN
                    l_stop := FALSE;
                END IF;
                CLOSE l_draft_selected_ver_csr;
            ELSE
                l_stop := FALSE;
            END IF;

            IF NOT l_stop THEN
            -- end changes

                OPEN l_draft_ver_csr(l_effective_date);
                FETCH l_draft_ver_csr INTO l_article_version_id;
                IF l_draft_ver_csr%NOTFOUND THEN

                    OPEN l_draft_latest_ver_csr(l_effective_date);
                    FETCH l_draft_latest_ver_csr INTO l_article_version_id;
                    CLOSE l_draft_latest_ver_csr;

                END IF;
                CLOSE l_draft_ver_csr;

            END IF;

        ELSIF p_status_code IN ('APPROVED','ON_HOLD','PENDING_APPROVAL') THEN
            -- begin changes
            IF (p_status_code = 'PENDING_APPROVAL' AND
                NVL(p_doc_type,'*') = 'TEMPLATE' AND
                p_doc_id is not null) THEN

                OPEN l_pen_app_selected_ver_csr;
                FETCH l_pen_app_selected_ver_csr INTO l_article_version_id;

                IF l_pen_app_selected_ver_csr%NOTFOUND THEN
                    l_stop := FALSE;
                END IF;
                CLOSE l_pen_app_selected_ver_csr;
            ELSE
                l_stop := FALSE;
            END IF;

            IF NOT l_stop THEN
            -- end changes

                OPEN l_approved_ver_csr(l_effective_date);
                FETCH l_approved_ver_csr INTO l_article_version_id;
                IF l_approved_ver_csr%NOTFOUND THEN

                    OPEN l_approved_latest_ver_csr(l_effective_date);
                    FETCH l_approved_latest_ver_csr INTO l_article_version_id;
                    CLOSE l_approved_latest_ver_csr;
                END IF;
                CLOSE l_approved_ver_csr;
            END IF;

        END IF;

        RETURN l_article_version_id;

    END Get_latest_tmpl_art_version_id;


    ------------------------------------------------------
    -- PROCEDURE create_tmpl_clauses_to_submit
    -------------------------------------------------------
    /*
    --11.5.10+
    --finds draft clauses to be submitted with template and creates rows in OKC_TMPL_DRAFT_CLAUSES
    --returns whether there is a draft clause through x_drafts_present
    */
    PROCEDURE create_tmpl_clauses_to_submit  (
        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2,
        p_template_id                  IN VARCHAR2,
        p_template_start_date          IN DATE DEFAULT NULL,
        p_template_end_date            IN DATE DEFAULT NULL,
        p_org_id                       IN NUMBER,
        x_drafts_present               OUT NOCOPY VARCHAR2,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2)
    IS
         l_api_name                     CONSTANT VARCHAR2(30) := 'create_tmpl_clauses_to_submit';
        l_effective_date           DATE;
        l_article_id               OKC_ARTICLES_ALL.ARTICLE_ID%TYPE;
        l_section_name             OKC_SECTIONS_B.HEADING%TYPE;
        l_article_label            OKC_SECTIONS_B.LABEL%TYPE;
        l_multiple_sections        VARCHAR2(1);
        l_return_status            VARCHAR2(1);
        l_start_date               OKC_TERMS_TEMPLATES_ALL.START_DATE%TYPE;
        l_end_date                 OKC_TERMS_TEMPLATES_ALL.END_DATE%TYPE;
        l_row_notfound             BOOLEAN;
        l_user_id                  NUMBER;
        l_login_id                 NUMBER;


        CURSOR template_csr  (cp_template_id NUMBER) is
            SELECT START_DATE, END_DATE
            FROM OKC_TERMS_TEMPLATES_ALL
            WHERE TEMPLATE_ID = cp_template_id;

        /* no longer used
        CURSOR expert_clauses_csr (cp_org_id NUMBER, cp_effective_date DATE,
            cp_template_id NUMBER) IS
            SELECT
                oav.article_version_id,
                oav.article_id,
                oav.start_date,
                oav.end_date
            FROM  okc_article_Versions oav,
                okc_articles_all oaa
            WHERE oav.article_id  = oaa.article_id
                AND oaa.org_id = cp_org_id
                AND oav.article_status IN  ('DRAFT','REJECTED')
                AND oav.start_date <= cp_effective_date
                AND nvl(oav.end_date, nvl(cp_effective_date,sysdate) +1) >= nvl(cp_effective_date,sysdate)
                AND oaa.article_id in
                    (SELECT clause_id from okc_xprt_clauses_v oxc
                    WHERE   oxc.template_id = cp_template_id);
        */

        CURSOR sec_name_csr (cp_template_id NUMBER, cp_article_id NUMBER)IS
            SELECT osb.heading, nvl(oka.label, '-98766554433.77'),osb.label section_label
            FROM okc_sections_b osb,okc_k_articles_b oka
            WHERE oka.document_id = cp_template_id
                AND oka.sav_sae_id = cp_article_id
                AND oka.scn_id = osb.id
                AND rownum < 3;

        --this cursor returns distinct article_ids
        CURSOR draft_articles_csr (cp_org_id  NUMBER, cp_effective_date  DATE,
            cp_template_id  NUMBER)IS
            SELECT  oav.article_version_id,
                oav.article_id
            FROM    okc_article_Versions oav,
                okc_articles_all oaa
            WHERE oav.article_id  = oaa.article_id
                AND oaa.org_id = cp_org_id
                AND oav.article_status IN  ('DRAFT','REJECTED')
                AND oaa.standard_yn = 'Y'
                AND oav.start_date <= cp_effective_date
                AND nvl(oav.end_date, nvl(cp_effective_date,sysdate) +1) >= nvl(cp_effective_date,sysdate)
                AND oaa.article_id in
                    (SELECT  sav_sae_id from okc_k_articles_b oka
                    WHERE   oka.document_id = cp_template_id
                    AND     oka.document_type='TEMPLATE');

        CURSOR valid_ver_csr (cp_article_id NUMBER, cp_article_version_id NUMBER,
            cp_template_effective_date DATE) IS
            SELECT 'Y' from okc_Article_versions
            WHERE article_id = cp_article_id
                AND article_version_id <> cp_article_version_id
                AND article_status = 'APPROVED'
                AND start_date <= cp_template_effective_date
                AND nvl(end_date, nvl(cp_template_effective_date,sysdate) +1) >= nvl(cp_template_effective_date,sysdate)
                AND rownum < 2;

        CURSOR fnd_section_name_csr is
            SELECT meaning
            FROM fnd_lookups
            WHERE lookup_code = 'UNASSIGNED' and lookup_type = 'OKC_ARTICLE_SECTION';

-- muteshev bug#4327485 begin
-- created new cursor selected_yn_csr
-- it takes selected_yn flag value from table OKC_TMPL_DRAFT_CLAUSES
        cursor selected_yn_csr( cp_template_id number,
                                cp_article_id number,
                                cp_article_version_id number) is
            select selected_yn
            from OKC_TMPL_DRAFT_CLAUSES
            where template_id = cp_template_id
            and article_id = cp_article_id
            and article_version_id = cp_article_version_id;
-- muteshev bug#4327485 end

        TYPE  draft_articles_tbl_type   is TABLE of draft_articles_csr%ROWTYPE  INDEX BY BINARY_INTEGER;
        TYPE sec_details_tbl_type       is TABLE of sec_name_csr%ROWTYPE   INDEX BY BINARY_INTEGER ;
        TYPE section_label_tbl_type    IS TABLE of OKC_SECTIONS_B.LABEL%TYPE INDEX BY BINARY_INTEGER ;
        TYPE article_id_tbl_type    IS TABLE of OKC_TMPL_DRAFT_CLAUSES.ARTICLE_ID%TYPE INDEX BY BINARY_INTEGER ;
        TYPE article_version_id_tbl_type    IS TABLE of OKC_TMPL_DRAFT_CLAUSES.ARTICLE_VERSION_ID%TYPE INDEX BY BINARY_INTEGER ;
        TYPE section_name_tbl_type    IS TABLE of OKC_TMPL_DRAFT_CLAUSES.SECTION_NAME%TYPE INDEX BY BINARY_INTEGER ;
        TYPE article_label_tbl_type    IS TABLE of OKC_TMPL_DRAFT_CLAUSES.ARTICLE_LABEL%TYPE INDEX BY BINARY_INTEGER ;
        TYPE multiple_scns_yn_tbl_type    IS TABLE of OKC_TMPL_DRAFT_CLAUSES.MULTIPLE_SCNS_YN%TYPE INDEX BY BINARY_INTEGER ;
        TYPE prev_val_version_yn_tbl_type    IS TABLE of OKC_TMPL_DRAFT_CLAUSES.PREV_VAL_VERSION_YN%TYPE INDEX BY BINARY_INTEGER ;
        TYPE selected_yn_tbl_type    IS TABLE of OKC_TMPL_DRAFT_CLAUSES.SELECTED_YN%TYPE INDEX BY BINARY_INTEGER ;

        draft_articles_tbl              draft_articles_tbl_type;
        sec_details_tbl                 sec_details_tbl_type;

        article_id_tbl                  article_id_tbl_type;
        article_version_id_tbl          article_version_id_tbl_type;
        section_name_tbl                section_name_tbl_type;
        article_label_tbl               article_label_tbl_type;
        t_section_name_tbl                section_name_tbl_type;
        t_article_label_tbl               article_label_tbl_type;
        multiple_scns_yn_tbl            multiple_scns_yn_tbl_type;
        prev_val_version_yn_tbl         prev_val_version_yn_tbl_type;
        selected_yn_tbl                 selected_yn_tbl_type;
        t_section_label_tbl             section_label_tbl_type;
    BEGIN

        x_return_status            := G_RET_STS_SUCCESS;
        x_drafts_present           := 'N';
        l_row_notfound             := false;

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Entering create_tmpl_clauses_to_submit');
        END IF;


        IF p_template_start_date is NULL THEN

            OPEN template_csr (p_template_id);
            FETCH template_csr into l_start_date, l_end_date;
            l_row_notfound := template_csr%NOTFOUND;
            CLOSE template_csr;

            IF l_row_notfound THEN
                Okc_Api.Set_Message(
                    p_app_name     => G_APP_NAME,
                    p_msg_name     => 'OKC_TERM_INVALID_TEMPLATE_ID');
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        ELSE
            l_start_date := p_template_start_date;
            l_end_date := p_template_end_date;
        END IF;

        IF NVL(l_end_date,sysdate) >= sysdate  THEN
            IF l_start_date > sysdate THEN
                l_effective_date := l_start_date;
            ELSE
                l_effective_date := sysdate;
            END IF;
        ELSE
            l_effective_date := l_end_date;
        END IF;

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'200: Effective date is '||l_effective_date);
        END IF;


        OPEN draft_articles_csr(p_org_id, l_effective_date, p_template_id);
        FETCH draft_articles_csr BULK COLLECT INTO article_version_id_tbl, article_id_tbl;
        CLOSE draft_articles_csr;

        IF article_id_tbl.COUNT = 0  THEN
            x_drafts_present := 'N';
        ELSIF article_id_tbl.COUNT > 0 THEN
            x_drafts_present := 'Y';
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'300: Draft clauses exist. Number of Draft clauses: '||draft_articles_tbl.COUNT);
            END IF;


            FOR i IN article_id_tbl.FIRST..article_id_tbl.LAST LOOP

                -- initiliaze all tables so that subscripts are always in sync
                section_name_tbl(i)             := NULL;
                article_label_tbl(i)            := NULL;
                t_section_name_tbl(i)             := NULL;
                t_article_label_tbl(i)            := NULL;
                multiple_scns_yn_tbl(i)         := 'N';
                prev_val_version_yn_tbl(i)      := NULL;
                selected_yn_tbl(i)              := NULL;

                OPEN sec_name_csr(p_template_id , article_id_tbl(i));
                FETCH sec_name_csr BULK COLLECT INTO t_section_name_tbl, t_article_label_tbl, t_section_label_tbl;
                CLOSE sec_name_csr;

                IF t_section_name_tbl.COUNT > 0 Then
                    IF t_section_name_tbl.COUNT = 2  then
                        multiple_scns_yn_tbl(i)  := 'Y';
                    ELSE
                        multiple_scns_yn_tbl(i)  := 'N';
                    END IF;
                             article_label_tbl(i) := t_article_label_tbl(1);
           section_name_tbl(i) :=  t_section_label_tbl(1) || ' ' || t_section_name_tbl(1);
                ELSE
                    --retrieve 'Unassigned' if there is no section name
                    OPEN fnd_section_name_csr;
                    FETCH fnd_section_name_csr INTO section_name_tbl(i);
                    CLOSE fnd_section_name_csr;
                END IF;

                OPEN valid_ver_csr(article_id_tbl(i),
                    article_version_id_tbl(i), l_effective_date);
                FETCH valid_ver_csr into prev_val_version_yn_tbl(i);
                l_row_notfound := valid_ver_csr%NOTFOUND;
                CLOSE valid_ver_csr;

                IF l_row_notfound THEN
                    prev_val_version_yn_tbl(i) := 'N';
                ELSE
                    prev_val_version_yn_tbl(i) := 'Y';
                END IF;

-- muteshev bug#4327485 begin
-- instead of unconditionally setting selected_yn := 'Y'
-- use selected_yn_csr and set selected_yn flag accordingly:
-- if %found use cursor result value for selected_yn,
-- if %notfound use selected_yn := 'Y' (by default)
                open selected_yn_csr(   p_template_id,
                                        article_id_tbl(i),
                                        article_version_id_tbl(i));
                fetch selected_yn_csr into selected_yn_tbl(i);
                if selected_yn_csr%NOTFOUND then
                    selected_yn_tbl(i) := 'Y';
                end if;
                close selected_yn_csr;
-- muteshev bug#4327485 end

            END LOOP;

        END IF ;

        draft_articles_tbl.DELETE;


        --delete old records associated with the template id
        DELETE FROM OKC_TMPL_DRAFT_CLAUSES
            WHERE template_id = p_template_id;

        IF  article_id_tbl.COUNT > 0 THEN
            l_user_id                  := Fnd_Global.user_id;
            l_login_id                 := Fnd_Global.login_id;

            FORALL i IN article_id_tbl.FIRST .. article_id_tbl.LAST

            INSERT INTO OKC_TMPL_DRAFT_CLAUSES
            (
                TEMPLATE_ID,
                ARTICLE_ID,
                ARTICLE_VERSION_ID,
                SECTION_NAME,
                ARTICLE_LABEL,
                MULTIPLE_SCNS_YN,
                PREV_VAL_VERSION_YN,
                SELECTED_YN,
                WF_SEQ_ID,
                OBJECT_VERSION_NUMBER,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN
            )
            VALUES
            (
                p_template_id,
                article_id_tbl(i),
                article_version_id_tbl(i),
                section_name_tbl(i),
                decode(article_label_tbl(i),'-98766554433.77',NULL,article_label_tbl(i)),
                multiple_scns_yn_tbl(i),
                prev_val_version_yn_tbl(i),
                selected_yn_tbl(i),
                null,
                1,
                l_user_id,
                sysdate,
                sysdate,
                l_user_id,
                l_login_id);
            --COMMIT;
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'300: Leaving create_tmpl_clauses_to_submit: OKC_API.G_EXCEPTION_ERROR Exception');
            END IF;
            x_return_status := G_RET_STS_ERROR;

        WHEN OTHERS THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'500: Leaving create_tmpl_clauses_to_submit because of EXCEPTION: '||sqlerrm);
            END IF;
            Okc_Api.Set_Message(
                p_app_name     => G_APP_NAME,
                p_msg_name     => G_UNEXPECTED_ERROR,
                p_token1       => G_SQLCODE_TOKEN,
                p_token1_value => sqlcode,
                p_token2       => G_SQLERRM_TOKEN,
                p_token2_value => sqlerrm);
                x_return_status := G_RET_STS_ERROR;

    END create_tmpl_clauses_to_submit;


    ---------------------------------------------------------------------------
    -- Overloaded Procedure merge_template_working_copy
    ---------------------------------------------------------------------------
    /*
    -- PROCEDURE merge_template_working_copy, 11.5.10+ overloaded version
    -- To be used to merge a working copy of a template is approved and old copy
    -- and working copy
    -- new out parameter x_parent_template_id returns the template id of the merged template
    */
    PROCEDURE merge_template_working_copy (
        p_api_version           IN  NUMBER,
        p_init_msg_list         IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_commit                IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_data              OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,

        p_template_id           IN  NUMBER,
        x_parent_template_id    OUT NOCOPY NUMBER)
    IS
 l_api_name                     CONSTANT VARCHAR2(30) := 'merge_template_working_copy';
    BEGIN

        -- call the existing procedure
        merge_template_working_copy (
        p_api_version           => p_api_version,
        p_init_msg_list         => p_init_msg_list,
        p_commit                => p_commit,

        x_return_status         => x_return_status,
        x_msg_data              => x_msg_data,
        x_msg_count             => x_msg_count,

        p_template_id           => p_template_id);

        -- set the out param from the global variable set by the
        -- existing procedure
        x_parent_template_id := g_parent_template_id;

    END merge_template_working_copy;

    FUNCTION unadopted_art_exist_on_tmpl(
            p_template_id          IN NUMBER,
      p_org_id               IN NUMBER )
    RETURN VARCHAR2 IS
    l_dummy VARCHAR2(1) := 'N';
    l_api_name CONSTANT VARCHAR2(30) := 'unadopted_art_exist_on_tmpl';

-- Fix for the bug# 5011432, reframed the cursor query
    CURSOR unadopted_art_chk_csr(lc_tmpl_id NUMBER,
                                 lc_org_id NUMBER) IS
SELECT 'Y'
    FROM okc_terms_templates_all tmpl,
         okc_k_articles_b kart,
	    okc_article_versions ver
    WHERE tmpl.template_id = lc_tmpl_id
    AND   kart.document_id = tmpl.template_id
    AND   kart.document_type = 'TEMPLATE'
    AND   ver.article_id = kart.sav_sae_id
    AND   ver.global_yn = 'Y'
    AND NOT EXISTS (SELECT 1
                    FROM okc_article_adoptions  adp,
                         okc_article_versions ver1
                    WHERE adp.global_article_version_id = ver1.article_version_id
                    AND   ver1.article_id = ver.article_id
                    AND   adp.local_org_id =   lc_org_id
                    AND   adp.adoption_status IN ( 'APPROVED', 'ON_HOLD')
                    AND   adp.adoption_type = 'ADOPTED');
-- End of Fix for the bug# 5011432
BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Entered unadopted_art_exist_on_tmpl');
    END IF;

   OPEN unadopted_art_chk_csr(p_template_id,p_org_id);
   FETCH unadopted_art_chk_csr INTO l_dummy;
   CLOSE unadopted_art_chk_csr;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'200: Fetched unadopted_art_chk_csr');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'300: l_dummy='||l_dummy);
    END IF;

      RETURN l_dummy;

    EXCEPTION
      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'400: Leaving unadopted_art_exist_on_tmpl because of EXCEPTION: '||sqlerrm);
        END IF;

      IF (unadopted_art_chk_csr%ISOPEN) THEN
        CLOSE unadopted_art_chk_csr;
      END IF;
      RETURN l_dummy;

    END unadopted_art_exist_on_tmpl;


    -- Start of comments
    --API name      : update_contract_admin
    --Type          : Private.
    --Function      : API to update Contract Administrator of Blanket Sales
    --                Agreements, Sales Orders and Sales Quotes
    --Pre-reqs      : None.
    --Parameters    :
    --IN            : p_api_version         IN NUMBER       Required
    --              : p_init_msg_list       IN VARCHAR2     Optional
    --                   Default = FND_API.G_FALSE
    --              : p_commit              IN VARCHAR2     Optional
    --                   Default = FND_API.G_FALSE
    --              : p_doc_ids_tbl         IN doc_ids_tbl       Required
    --                   List of document ids whose Contract Administrator to be changed
    --              : p_doc_types_tbl       IN doc_types_tbl       Required
    --                   List of document types whose Contract Administrator to be changed
    --              : p_new_con_admin_user_ids_tbl IN new_con_admin_user_ids_tbl       Required
    --                   List of new Contract Administrator ids
    --OUT           : x_return_status       OUT  VARCHAR2(1)
    --              : x_msg_count           OUT  NUMBER
    --              : x_msg_data            OUT  VARCHAR2(2000)
    --Note          :
    -- End of comments
    PROCEDURE update_contract_admin(
                                    p_api_version     IN   NUMBER,
                                    p_init_msg_list   IN   VARCHAR2,
                                    p_commit          IN   VARCHAR2,
                                    p_doc_ids_tbl     IN   doc_ids_tbl,
                                    p_doc_types_tbl              IN   doc_types_tbl,
                                    p_new_con_admin_user_ids_tbl IN   new_con_admin_user_ids_tbl,
                                    x_return_status   OUT NOCOPY   VARCHAR2,
                                    x_msg_count       OUT NOCOPY  NUMBER,
                                    x_msg_data        OUT NOCOPY  VARCHAR2)
    IS

      l_api_name          VARCHAR2(30);
      l_api_version       NUMBER;
      dml_errors exception;

    BEGIN

      l_api_name := 'update_contract_admin';
      l_api_version := 1.0;

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
              'Entered OKC_TERMS_UTIL_PVT.update_contract_admin');
      END IF;

      -- Standard Start of API savepoint
      SAVEPOINT update_contract_admin;

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

      FORALL  i  IN  p_doc_ids_tbl.FIRST..p_doc_ids_tbl.LAST
        UPDATE  okc_template_usages
        SET     contract_admin_id = p_new_con_admin_user_ids_tbl(i)
        WHERE   document_id = p_doc_ids_tbl(i)
        AND     document_type = p_doc_types_tbl(i);

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                 'Leaving OKC_TERMS_UTIL_PVT.update_contract_admin');
      END IF;

      EXCEPTION

        WHEN OTHERS THEN
          IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                   g_module || l_api_name,
                   'Leaving OKC_TERMS_UTIL_PVT.update_contract_admin because of EXCEPTION: ' || sqlerrm);
          END IF;

          ROLLBACK TO update_contract_admin;

          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get(
                  p_count =>  x_msg_count,
                  p_data  =>  x_msg_data);


    END update_contract_admin;


    -- Start of comments
    --API name      : get_sales_group_con_admin
    --Type          : Private.
    --Function      : API to get Contract Administrator of a business document
    --                according to Sales Group Assignment
    --Pre-reqs      : None.
    --Parameters    :
    --IN            : p_api_version         IN NUMBER       Required
    --              : p_init_msg_list       IN VARCHAR2     Optional
    --                   Default = FND_API.G_FALSE
    --              : p_doc_id         IN NUMBER       Required
    --                   Id of document whose Contract Administrator is required
    --              : p_doc_type       IN VARCHAR2       Required
    --                   Type of document whose Contract Administrator is required
    --OUT           : x_new_con_admin_user_id OUT NUMBER
    --                   New Contract Administrator id
    --              : x_return_status       OUT  VARCHAR2(1)
    --              : x_msg_count           OUT  NUMBER
    --              : x_msg_data            OUT  VARCHAR2(2000)
    --Note          :
    -- End of comments
    PROCEDURE get_sales_group_con_admin(
                                    p_api_version             IN  NUMBER,
                                    p_init_msg_list           IN  VARCHAR2,
                                    p_doc_id                  IN  NUMBER,
                                    p_doc_type                IN  VARCHAR2,
                                    x_new_con_admin_user_id   OUT NOCOPY  NUMBER,
                                    x_return_status           OUT NOCOPY  VARCHAR2,
                                    x_msg_count               OUT NOCOPY  NUMBER,
                                    x_msg_data                OUT NOCOPY  VARCHAR2)
    IS

      l_api_name          VARCHAR2(30);
      l_api_version       NUMBER;
      l_primary_salesperson_id  aso_quote_headers_all.resource_id%TYPE;
      l_sales_group_id  aso_quote_headers_all.resource_grp_id%TYPE;
      l_quote_org_id  aso_quote_headers_all.org_id%TYPE;
      l_quote_number  aso_quote_headers_all.quote_number%TYPE;

      CURSOR quote_details_csr IS
        SELECT resource_id,
               resource_grp_id,
               quote_number
        FROM   aso_quote_headers_all
        WHERE  quote_header_id = p_doc_id;

      CURSOR quote_sales_team_csr(p_quote_number IN aso_quote_headers_all.quote_number%TYPE) IS
        SELECT sre.user_id
        FROM   aso_quote_accesses sales_team,
                jtf_rs_role_relations rr,
                jtf_rs_roles_b rl,
                jtf_rs_resource_extns sre
        WHERE  sales_team.quote_number = p_quote_number
        AND    rr.ROLE_ID = rl.ROLE_ID
        AND    NVL(rr.delete_flag,'N')  <> 'Y'
        AND    rr.Role_resource_type = 'RS_INDIVIDUAL'
-- For Bug# 6343627         AND    (rr.end_date_active IS NULL  OR  rr.end_date_active >= SYSDATE)
	AND    (rr.end_date_active IS NULL  OR  rr.end_date_active > SYSDATE)
        AND    (
                 (rl.role_type_code = 'CONTRACTS' AND rl.role_code = 'CONTRACTS_ADMIN')
               OR
                 (rl.role_type_code = 'SALES'     AND rl.role_code = 'CONTRACTS_ADMIN')
               OR
                 (rl.role_code = 'CONTRACTS_ADMIN')
               )
        AND    rr.role_resource_id = sales_team.resource_id
        AND    sre.resource_id = sales_team.resource_id;

      CURSOR con_admin_role_member_csr(p_sales_group_id IN aso_quote_headers_all.resource_grp_id%TYPE) IS
        SELECT sre.user_id
        FROM  jtf_rs_group_members srg,
              jtf_rs_resource_extns sre,
              jtf_rs_role_relations rr,
              jtf_rs_roles_b rl
        WHERE  srg.group_id = p_sales_group_id
        AND    srg.resource_id = sre.resource_id
        AND    NVL(srg.delete_flag,'N')  <> 'Y'
        AND    rr.ROLE_ID = rl.ROLE_ID
        AND    NVL(rr.delete_flag,'N')  <> 'Y'
	 -- For Bug# 6343627 AND            AND    rr.Role_resource_type = 'RS_INDIVIDUAL'
        AND    rr.Role_resource_type = 'RS_GROUP_MEMBER'
 -- For Bug# 6343627        AND    (rr.end_date_active IS NULL  OR  rr.end_date_active >= SYSDATE)
        AND    (rr.end_date_active IS NULL  OR  rr.end_date_active > SYSDATE)
        AND    rl.role_type_code = 'CONTRACTS'
        AND    rl.role_code = 'CONTRACTS_ADMIN'
	 -- For Bug# 6343627       AND    rr.role_resource_id = sre.resource_id;
        AND    rr.role_resource_id = srg.GROUP_MEMBER_ID;

      CURSOR parent_group_csr(p_sales_group_id IN aso_quote_headers_all.resource_grp_id%TYPE) IS
        SELECT related_group_id
        FROM  jtf_rs_grp_relations
        WHERE group_id = p_sales_group_id
        AND   relation_type = 'PARENT_GROUP';

    BEGIN

      l_api_name := 'get_sales_group_con_admin';
      l_api_version := 1.0;

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
          'Entered OKC_TERMS_UTIL_PVT.get_sales_group_con_admin');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'p_doc_id: ' || p_doc_id);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'p_doc_type: ' || p_doc_type);
      END IF;

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Getting current Sales Quote details');
      END IF;

      -- Get details of the current Sales Quote
      OPEN quote_details_csr;
      FETCH quote_details_csr INTO l_primary_salesperson_id, l_sales_group_id, l_quote_number;
      CLOSE quote_details_csr;

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Getting Contract Administrator from Sales Quote''s Sales Team');
      END IF;

      -- From Sales Team of the Quote, pick the user with a role type of Contracts and
      -- a role of Contract Administrator, if this isn't available, pick the user with
      -- a role type of Sales and a role of Contract Administrator, and if this isn't
      -- available, pick the user with any role type and a role of Contract Administrator
      OPEN quote_sales_team_csr(l_quote_number);

      -- Even though the cursor returns multiple rows we'll consider only the first row in
      -- the resultset, so we're not looping through the resultset
      FETCH quote_sales_team_csr INTO x_new_con_admin_user_id;
      CLOSE quote_sales_team_csr;


      -- If no Contract Administrator defined on the sales team,
      IF(x_new_con_admin_user_id IS NULL) THEN

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'No Contract Administrator found in Sales Quote''s Sales Team');
        END IF;

        -- If current Quote has a Primary Sales Group selected
        IF(l_sales_group_id IS NOT NULL) THEN

          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
               'Getting Contract Administrator from current Quote''s Primary Salesperson''s Primary Sales Group');
          END IF;

          -- Look at the primary sales group in the Quote for a Contract Administrator
          OPEN con_admin_role_member_csr(l_sales_group_id);
          FETCH con_admin_role_member_csr INTO x_new_con_admin_user_id;
          CLOSE con_admin_role_member_csr;

          -- In the case where neither the sales team nor the primary sales group have a contract administrator defined,
          IF(x_new_con_admin_user_id IS NULL) THEN

            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                 'No Contract Administrator found in the current Quote''s Primary Salesperson''s Primary Sales Group');
              FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                 'Getting parent group of the current Quote''s Primary Salesperson''s Primary Sales Group');
            END IF;

            -- Get parent of the primary Salesperson's primary sales group in the Quote
            OPEN parent_group_csr(l_sales_group_id);
            FETCH parent_group_csr INTO l_sales_group_id;
            CLOSE parent_group_csr;

            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                   'Getting Contract Administrator from parent of current Quote''s Primary Salesperson''s Primary Sales Group');
            END IF;

            -- Check the parent sales group for a Contract Administrator
            OPEN con_admin_role_member_csr(l_sales_group_id);
            FETCH con_admin_role_member_csr INTO x_new_con_admin_user_id;
            CLOSE con_admin_role_member_csr;

          END IF; -- End of (x_new_con_admin_user_id IS NULL)

        END IF; -- End of (l_sales_group_id IS NOT NULL)

      END IF; -- End of (x_new_con_admin_user_id IS NULL)

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
           'New Contract Administrator Id ' || x_new_con_admin_user_id);
      END IF;


      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
             'Leaving OKC_TERMS_UTIL_PVT.get_sales_group_con_admin');
      END IF;

    EXCEPTION

        WHEN OTHERS THEN
          IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                   g_module || l_api_name,
                   'Leaving OKC_TERMS_UTIL_PVT.get_sales_group_con_admin because of EXCEPTION: ' || sqlerrm);
          END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get(
                  p_count =>  x_msg_count,
                  p_data  =>  x_msg_data);

        --close cursors
        IF (quote_details_csr%ISOPEN) THEN
          CLOSE quote_details_csr ;
        END IF;
        IF (quote_sales_team_csr%ISOPEN) THEN
          CLOSE quote_sales_team_csr ;
        END IF;
        IF (con_admin_role_member_csr%ISOPEN) THEN
          CLOSE con_admin_role_member_csr ;
        END IF;
        IF (parent_group_csr%ISOPEN) THEN
          CLOSE parent_group_csr ;
        END IF;

    END get_sales_group_con_admin;

FUNCTION has_uploaded_terms(p_document_type IN VARCHAR2,
                        p_document_id   IN NUMBER
            )
  RETURN Varchar2 IS
  l_has_uploaded_terms VARCHAR2(1);

  CURSOR l_review_uploaded_terms_csr IS
  SELECT 'Y'
  FROM okc_review_upld_terms rev
  WHERE rev.document_type = p_document_type
  AND rev.document_id = p_document_id
    ;
BEGIN
  OPEN l_review_uploaded_terms_csr;
  FETCH l_review_uploaded_terms_csr INTO l_has_uploaded_terms;
  IF l_has_uploaded_terms = 'Y' THEN
    RETURN 'Y';
  else
    RETURN 'N';
  END IF;
  CLOSE l_review_uploaded_terms_csr;

EXCEPTION
  WHEN OTHERS THEN
    RETURN 'N';
END has_uploaded_terms;


FUNCTION is_terms_locked(p_document_type IN VARCHAR2,
                        p_document_id   IN NUMBER
            )
  RETURN Varchar2 IS
  l_terms_locked VARCHAR2(1);

  CURSOR l_terms_locked_csr IS
  SELECT  lock_terms_flag
  FROM okc_template_usages usg
  WHERE usg.document_type = p_document_type
  AND usg.document_id = p_document_id
    ;
BEGIN
  OPEN l_terms_locked_csr;
  FETCH l_terms_locked_csr INTO l_terms_locked;
  IF l_terms_locked = 'Y' THEN
    RETURN 'Y';
  else
    RETURN 'N';
  END IF;
  CLOSE l_terms_locked_csr;

EXCEPTION
  WHEN OTHERS THEN
    RETURN 'N';
END is_terms_locked;



FUNCTION get_default_contract_admin_id(p_document_type IN VARCHAR2,
         p_document_id IN NUMBER)
  RETURN NUMBER IS
  l_api_version      CONSTANT NUMBER := 1;
  l_default_ctrt_admin_id NUMBER;
  l_return_status VARCHAR2(150);
  l_msg_data VARCHAR2(2000);
  l_msg_count NUMBER;
  BEGIN

  IF (p_document_type <> 'QUOTE') THEN
     RETURN NULL;
  END IF;
   get_sales_group_con_admin(
       p_api_version             => l_api_version,
	  p_init_msg_list           => FND_API.G_FALSE,
	  p_doc_id                  => p_document_id,
	  p_doc_type                => p_document_type,
	  x_new_con_admin_user_id   => l_default_ctrt_admin_id,
	  x_return_status           => l_return_status,
	  x_msg_count               => l_msg_count,
	  x_msg_data                => l_msg_data);

    RETURN l_default_ctrt_admin_id;
   EXCEPTION
      WHEN OTHERS THEN
	    RETURN NULL;
END get_default_contract_admin_id;

FUNCTION get_contract_admin_name(p_contract_admin_id NUMBER)
  RETURN VARCHAR2 IS
  l_contract_admin_name PER_ALL_PEOPLE_F.FULL_NAME%TYPE := NULL;

  CURSOR get_ctrt_admin_name IS
    select adminppl.full_name
      from fnd_user ctrtadm, PER_ALL_PEOPLE_F adminppl
	 where p_contract_admin_id = ctrtadm.user_id(+)
	 and ctrtadm.employee_id = adminppl.person_id(+)
	 and adminppl.effective_start_date = adminppl.start_date;
  BEGIN

  IF (p_contract_admin_id is NULL) THEN
     RETURN NULL;
  END IF;

     OPEN get_ctrt_admin_name;
	FETCH get_ctrt_admin_name into l_contract_admin_name;
	CLOSE get_ctrt_admin_name;
    RETURN l_contract_admin_name;
   EXCEPTION
      WHEN OTHERS THEN
	    RETURN NULL;
END get_contract_admin_name;

PROCEDURE get_default_contract_admin(
  p_api_version          IN  NUMBER,
  p_init_msg_list        IN  VARCHAR2 :=  FND_API.G_FALSE,

  p_document_type        IN  VARCHAR2,
  p_document_id           IN  NUMBER,
  x_has_default_contract_admin OUT NOCOPY VARCHAR2,
  x_def_contract_admin_name OUT NOCOPY VARCHAR2,
  x_def_contract_admin_id OUT NOCOPY NUMBER,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_data             OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER
  )

  IS
    l_api_version      CONSTANT NUMBER := 1;
  l_api_name         CONSTANT VARCHAR2(30) := 'get_default_contract_admin';
BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'8000: Entered get_default_contract_admin');
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
    x_def_contract_admin_id := NULL;
    x_def_contract_admin_name := NULL;
    x_has_default_contract_admin := 'N';
    x_def_contract_admin_id := get_default_contract_admin_id(p_document_type, p_document_id );
    if(x_def_contract_admin_id is not null) then
         x_has_default_contract_admin := 'Y';
         x_def_contract_admin_name := get_contract_admin_name(x_def_contract_admin_id);
    end if;


    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'8100: get_default_contract_admin');
    END IF;

EXCEPTION
  WHEN OTHERS THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'8200: Leaving get_default_contract_admin because of EXCEPTION:'||sqlerrm);
      END IF;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      x_return_status := G_RET_STS_UNEXP_ERROR ;
END get_default_contract_admin;

-- This is a temporary api that has been created to be
-- used only when the layout template code is not present in session
-- The layout template code is fetched based on the
-- Business Document Type
-- Business Document Type class
-- Business Document Id
-- Operating Unit
FUNCTION get_layout_template_code(
    p_doc_type IN VARCHAR2,
    p_doc_type_class IN VARCHAR2,
    p_doc_id   IN NUMBER,
    p_org_id IN NUMBER)
    RETURN Varchar2 IS
    l_doc_type varchar2(10);
    l_doc_sub_type varchar2(30);
    l_layout_template_code varchar2(30) := 'E';

 cursor get_po_lay_templ_csr(l_doc_type VARCHAR2,l_doc_sub_type VARCHAR2) is
 -- Fix for bug# 5010387, replaced po_document_types_v with  po_document_types_all_b and added org_id condition
SELECT
    contract_template_code
FROM po_document_types_all_b
WHERE org_id = p_org_id
    AND document_type_code = l_doc_type
    AND document_subtype= l_doc_sub_type;

 cursor get_souring_lay_templ_csr is
SELECT
    podoctypes.contract_template_code
FROM pon_auction_headers_all pah,
    po_document_types_all_b podoctypes,
    pon_auc_doctypes pac
WHERE auction_header_id = p_doc_id
    AND pah.doctype_id = pac.doctype_id
    AND pah.org_id = podoctypes.org_id
    AND pac.document_type_code = podoctypes.document_type_code;

 cursor get_bsa_lay_templ_csr is
SELECT
    xdb.template_code
FROM oe_blanket_headers_all oeb,
    oe_transaction_types_all otl,
    xdo_templates_b xdb
WHERE oeb.order_type_id = otl.transaction_type_id
    AND oeb.header_id = p_doc_id
    AND otl.layout_template_id = xdb.template_id;

 cursor get_order_lay_templ_csr is
SELECT
    xdb.template_code
FROM oe_order_headers_all oeb,
    oe_transaction_types_vl otl,
    xdo_templates_b xdb
WHERE oeb.order_type_id = otl.transaction_type_id
    AND oeb.header_id = p_doc_id
    AND otl.layout_template_id = xdb.template_id;

--ER Structured Terms Authoring in Repository - strivedi
  CURSOR get_rep_lay_templ_csr IS
SELECT
    xdb.template_code
FROM
    okc_terms_templates_all otta,
    okc_template_usages_v otuv,
    xdo_templates_b xdb
WHERE otuv.document_id = p_doc_id
    AND otuv.document_type = p_doc_type
    AND otuv.template_id =  otta.template_id
    AND otta.print_template_id = xdb.template_id;

 BEGIN
 IF p_doc_type_class = 'PO' THEN
    MO_GLOBAL.INIT('PO');
    mo_global.set_policy_context('S',p_org_id);
    l_doc_type := substr(p_doc_type,1,instr(p_doc_type,'_')-1);
    l_doc_sub_type := substr(p_doc_type,instr(p_doc_type,'_')+1,length(p_doc_type)- instr(p_doc_type,'_'));
    open get_po_lay_templ_csr(l_doc_type,l_doc_sub_type);
    fetch get_po_lay_templ_csr into l_layout_template_code;
    close get_po_lay_templ_csr;
 ELSIF p_doc_type_class = 'SOURCING' THEN
    MO_GLOBAL.INIT('PON');
    mo_global.set_policy_context('S',p_org_id);
    open get_souring_lay_templ_csr;
    fetch get_souring_lay_templ_csr into l_layout_template_code;
    close get_souring_lay_templ_csr;
 ELSIF p_doc_type_class = 'SO' or p_doc_type_class = 'BSA' THEN
    MO_GLOBAL.INIT('ONT');
    mo_global.set_policy_context('S',204);
    IF p_doc_type = 'O' THEN
        open get_order_lay_templ_csr;
        fetch get_order_lay_templ_csr into l_layout_template_code;
        close get_order_lay_templ_csr;
    ELSIF p_doc_type = 'B' THEN
        open get_bsa_lay_templ_csr;
        fetch get_bsa_lay_templ_csr into l_layout_template_code;
        close get_bsa_lay_templ_csr;
    END IF;
 ELSIF p_doc_type_class = 'QUOTE' THEN
    select fnd_profile.value('ASO_DEFAULT_LAYOUT_TEMPLATE') into l_layout_template_code from dual;

--ER Structured Terms Authoring in Repository - strivedi
 ELSIF p_doc_type_class = 'REPOSITORY' THEN
        OPEN get_rep_lay_templ_csr;
        fetch get_rep_lay_templ_csr into l_layout_template_code;
        CLOSE get_rep_lay_templ_csr;
 ELSE
     l_layout_template_code := 'E';
 END IF;
return l_layout_template_code;

EXCEPTION
  WHEN OTHERS THEN
    RETURN 'E';
END get_layout_template_code;


--For R12 MSWord@WaySync

PROCEDURE lock_contract(
  p_api_version          IN  NUMBER,
  p_init_msg_list        IN  VARCHAR2 :=  FND_API.G_FALSE,

  p_commit               IN  Varchar2,
  p_document_type        IN  VARCHAR2,
  p_document_id           IN  NUMBER,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_data             OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER)
  IS
  l_api_version      CONSTANT NUMBER := 1;
  l_api_name         CONSTANT VARCHAR2(30) := 'lock_contract';

BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'8000: Entered lock_contract');
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
OKC_TEMPLATE_USAGES_GRP.update_template_usages(
    p_api_version                  => l_api_version,
    p_init_msg_list                => p_init_msg_list ,
    p_validation_level             => FND_API.G_VALID_LEVEL_FULL,
    p_commit                       => FND_API.G_FALSE,
    x_return_status                => x_return_status,
    x_msg_count                    => x_msg_count,
    x_msg_data                     => x_msg_data,
    p_document_type          => p_document_type,
    p_document_id            => p_document_id,
    p_lock_terms_flag        => 'Y',
    p_locked_by_user_id      => FND_GLOBAL.user_id);


    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'8100: Leaving lock_contract');
    END IF;

EXCEPTION
  WHEN OTHERS THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'8200: Leaving lock_contract because of EXCEPTION:'||sqlerrm);
      END IF;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      x_return_status := G_RET_STS_UNEXP_ERROR ;
END lock_contract;

--For R12: MSWord2WaySync
PROCEDURE unlock_contract(
  p_api_version          IN  NUMBER,
  p_init_msg_list        IN  VARCHAR2 :=  FND_API.G_FALSE,

  p_commit               IN  Varchar2,
  p_document_type        IN  VARCHAR2,
  p_document_id           IN  NUMBER,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_data             OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER)
  IS
    l_api_version      CONSTANT NUMBER := 1;
  l_api_name         CONSTANT VARCHAR2(30) := 'unlock_contract';
BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'8000: Entered lock_contract');
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
OKC_TEMPLATE_USAGES_GRP.update_template_usages(
    p_api_version                  => l_api_version,
    p_init_msg_list                => p_init_msg_list ,
    p_validation_level             => FND_API.G_VALID_LEVEL_FULL,
    p_commit                       => FND_API.G_FALSE,
    x_return_status                => x_return_status,
    x_msg_count                    => x_msg_count,
    x_msg_data                     => x_msg_data,
    p_document_type          => p_document_type,
    p_document_id            => p_document_id,
    p_lock_terms_flag        => 'N');


    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'8100: Leaving lock_contract');
    END IF;

EXCEPTION
  WHEN OTHERS THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'8200: Leaving lock_contract because of EXCEPTION:'||sqlerrm);
      END IF;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
      x_return_status := G_RET_STS_UNEXP_ERROR ;
END unlock_contract;

FUNCTION get_sys_last_upd_date (
  p_document_type         IN  VARCHAR2,
  p_document_id           IN  NUMBER)
  RETURN DATE IS

		 l_article_change_date  date;
		 l_section_change_date  date;
		 l_variable_change_date date;
		 l_sys_last_update_date date;
		 l_contract_source_code OKC_TEMPLATE_USAGES.CONTRACT_SOURCE_CODE%TYPE;

		 Cursor l_get_max_art_date_csr IS
		 SELECT max(Nvl(LAST_UPDATE_DATE,CREATION_DATE))
		 FROM OKC_K_ARTICLES_B
		 WHERE DOCUMENT_TYPE=p_document_type
		 AND   DOCUMENT_ID=p_document_id;

		 Cursor l_get_max_scn_date_csr IS
		 SELECT max(Nvl(LAST_UPDATE_DATE,CREATION_DATE))
		 FROM OKC_SECTIONS_B
		 WHERE DOCUMENT_TYPE=p_document_type
		 AND   DOCUMENT_ID=p_document_id;

           Cursor l_get_max_var_date_csr IS
		 SELECT MAX(NVL(LAST_UPDATE_DATE,CREATION_DATE))
		 FROM OKC_K_ART_VARIABLES WHERE CAT_ID IN (
		 SELECT ID FROM OKC_K_ARTICLES_B
		   WHERE DOCUMENT_TYPE = p_document_type
		   AND DOCUMENT_ID = document_id);

		 Cursor l_get_max_usg_upd_date_csr IS
		 SELECT MAX(LAST_UPDATE_DATE)
		 FROM   okc_template_usages
		 WHERE  document_type = p_document_type
		 AND    document_id = p_document_id;

		 Cursor l_get_contract_source_csr IS
		 SELECT contract_source_code
		 FROM okc_template_usages
		 WHERE document_type = p_document_type
		 AND document_id = p_document_id;

		 BEGIN
		   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE,'9200: get_sys_last_upd_date p_doc_type : '||p_document_type);
				       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE,'9300: get_sys_last_upd_date p_doc_id : '||p_document_id);
	        END IF;


		   OPEN l_get_contract_source_csr;
			   FETCH l_get_contract_source_csr INTO l_contract_source_code;
		        CLOSE l_get_contract_source_csr;


		   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE,'9310: After fetching l_get_contract_source_csr');
		         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE,'9320: Contract Source Code :'||l_contract_source_code);
		   END IF;

		   IF l_contract_source_code = G_ATTACHED_CONTRACT_SOURCE THEN
			    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE,'9330: Before opening l_get_max_usg_upd_date_csr');
		         END IF;

			    OPEN l_get_max_usg_upd_date_csr;
			        FETCH l_get_max_usg_upd_date_csr INTO l_sys_last_update_date;
			    CLOSE l_get_max_usg_upd_date_csr;

			    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE,'9340: After fetching l_get_max_usg_upd_date_csr');
			        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE,'9350: l_terms_changed_date :'||l_sys_last_update_date);
			    END IF;

		    ELSE
                  OPEN  l_get_max_art_date_csr;
			   FETCH l_get_max_art_date_csr INTO l_article_change_date;
			   CLOSE l_get_max_art_date_csr;

                  OPEN  l_get_max_scn_date_csr;
			     FETCH l_get_max_scn_date_csr INTO l_section_change_date;
			   CLOSE l_get_max_scn_date_csr;

                  OPEN  l_get_max_var_date_csr;
			     FETCH l_get_max_var_date_csr INTO l_variable_change_date;
			   CLOSE l_get_max_var_date_csr;

                  OPEN l_get_max_usg_upd_date_csr;
			      FETCH l_get_max_usg_upd_date_csr INTO l_sys_last_update_date;
		        CLOSE l_get_max_usg_upd_date_csr;

                 --Begin:Fix for bug# 4909079. Added nvl check for article, section, variable, usages dates
                   l_article_change_date  := nvl(l_article_change_date ,okc_api.g_miss_date);
                   l_section_change_date  := nvl(l_section_change_date ,okc_api.g_miss_date);
                   l_variable_change_date := nvl(l_variable_change_date,okc_api.g_miss_date);
                   l_sys_last_update_date := nvl(l_sys_last_update_date,okc_api.g_miss_date);
			  --End:Fix for bug# 4909079

			  l_sys_last_update_date := Greatest(l_article_change_date, l_section_change_date,l_variable_change_date,l_sys_last_update_date);
			  if(l_sys_last_update_date = OKC_API.G_MISS_DATE) THEN
			     l_sys_last_update_date := sysdate;
			  end if;
             END IF;

             IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE,'9700: l_sys_last_update_date : '||l_sys_last_update_date);
	        END IF;
		   return l_sys_last_update_date;
          EXCEPTION
		  WHEN OTHERS THEN
		    RETURN NULL;
END get_sys_last_upd_date;

/*
  Function Name : get_revert_art_version_id
  Purpose       : This function returns the latest article_version_id of the ref_article_id queried using id
                  of OKC_K_ARTICLES_B.
  Usage         : This function is used in the Revert to Standard UI to query the latest article_version_id
                  for the ref_article_id of the article in OKC_K_ARTICLES_B queried using the id (primary_key).
*/

  FUNCTION get_revert_art_version_id(
        p_id IN NUMBER,
        p_document_type IN VARCHAR2,
        p_document_id IN NUMBER ) RETURN NUMBER
	    IS

	    l_article_version_number OKC_ARTICLES_ALL.ARTICLE_NUMBER%TYPE;
	    l_article_version_id  OKC_ARTICLE_VERSIONS.ARTICLE_VERSION_ID%TYPE;
	    l_local_article_id OKC_K_ARTICLES_B.ORIG_ARTICLE_ID%TYPE;
	    l_adoption_type OKC_ARTICLE_VERSIONS.ADOPTION_TYPE%TYPE;
	    l_ref_article_id OKC_K_ARTICLES_B.REF_ARTICLE_ID%TYPE;


        -- Fix for bug# 5235082. Changed the query to use id instead of sav_sae_id
	    cursor get_ref_article_id is
	      select ref_article_id from okc_k_articles_b
		  where id = p_id;

	    BEGIN
	      open get_ref_article_id;
		  fetch get_ref_article_id into l_ref_article_id;
		 close get_ref_article_id;

	     get_latest_article_details
		 (
		   p_article_id  => l_ref_article_id,
		   p_document_type => p_document_type,
		   p_document_id => p_document_id,
	        x_article_version_id => l_article_version_id,
		   x_article_version_number => l_article_version_number,
		   x_local_article_id => l_local_article_id,
		   x_adoption_type => l_adoption_type);

	     RETURN l_article_version_id;
END get_revert_art_version_id;


    -- Start of comments
    --API name      : set_udv_with_procedures
    --Type          : Private.
    --Function      : API to set the user defined variables with procedures,
    --                with values and insert them in a temporary table used in printing terms and review messages when the modified terms are uploaded
    --Pre-reqs      : None.
    --Parameters    :
    --IN            : p_api_version         IN NUMBER       Required
    --              : p_init_msg_list       IN VARCHAR2     Optional
    --                   Default = FND_API.G_FALSE
    --              : p_document_id         IN NUMBER       Required
    --                   Id of document whose udv with procs are to be set
    --              : p_doc_type            IN VARCHAR2       Required
    --                   Type of document whose udv with procs are to be set
    --              : p_output_error        IN VARCHAR2     Optional
    --              : x_return_status       OUT  VARCHAR2(1)
    --              : x_msg_count           OUT  NUMBER
    --              : x_msg_data            OUT  VARCHAR2(2000)
    --Note          :
    -- End of comments


PROCEDURE set_udv_with_procedures (
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 :=  FND_API.G_FALSE,

    p_document_type     IN  VARCHAR2,
    p_document_id       IN  NUMBER,
    p_output_error      IN  VARCHAR2 :=  FND_API.G_TRUE,

    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_data          OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER

  ) IS
    l_api_version       CONSTANT NUMBER := 1.0;
    l_api_name          CONSTANT VARCHAR2(30) := 'set_udv_with_procedures';

    l_variable_value        VARCHAR2(2500) := NULL;
    l_previous_var_code		okc_bus_variables_b.variable_code%TYPE := '-99';
	l_return_status			VARCHAR2(10) := NULL;

CURSOR csr_get_udv_with_procs IS
SELECT VB.variable_code,
       KA.id,
       KA.article_version_id
FROM okc_k_articles_b KA,
     okc_k_art_variables KV,
     okc_bus_variables_b VB
WHERE VB.variable_code = KV.variable_code
AND KA.id = KV.cat_id
AND VB.variable_source = 'P'
AND KA.document_type = p_document_type
AND KA.document_id = p_document_id
ORDER BY VB.variable_code;

   BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Entered set_udv_with_procedures');
		FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: p_document_type:'||p_document_type);
		FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: p_document_id:'||p_document_id);
    END IF;

    /* Standard call to check for call compatibility */
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /* Initialize message list if p_init_msg_list is set to TRUE */
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
    END IF;

    /* Initialize API return status to success */
    x_return_status := G_RET_STS_SUCCESS;

    /* Clear the temp table */
    DELETE FROM OKC_TERMS_UDV_WITH_PROCEDURE_T;

    FOR csr_udv_with_procs_rec IN csr_get_udv_with_procs LOOP

        /* Get the variable value */
		IF l_previous_var_code <> csr_udv_with_procs_rec.variable_code THEN

		    l_variable_value := NULL;

			get_udv_with_proc_value (
				p_document_type => p_document_type,
				p_document_id  => p_document_id,
				p_variable_code => csr_udv_with_procs_rec.variable_code,
				p_output_error => p_output_error,
				x_variable_value =>	l_variable_value,
				x_return_status	=> l_return_status,
				x_msg_data => x_msg_data,
				x_msg_count	=> x_msg_count );

		END IF;

		/* Insert data into the temp table */
		IF l_variable_value IS NOT NULL THEN

			INSERT INTO OKC_TERMS_UDV_WITH_PROCEDURE_T
			(
				VARIABLE_CODE,
				VARIABLE_VALUE,
				DOC_TYPE,
				DOC_ID,
				ARTICLE_VERSION_ID,
				CAT_ID
			)
			VALUES
			(
				csr_udv_with_procs_rec.variable_code,		-- VARIABLE_CODE
				l_variable_value,	 						-- VARIABLE_VALUE
				p_document_type, 							-- DOCUMENT_TYPE
				p_document_id, 								-- DOCUMENT_ID
				csr_udv_with_procs_rec.article_version_id,  -- ARTICLE_VERSION_ID
				csr_udv_with_procs_rec.id					-- CAT_ID
			);
		END IF;

		l_previous_var_code := csr_udv_with_procs_rec.variable_code;

    END LOOP;

	IF p_output_error = FND_API.G_TRUE AND FND_MSG_PUB.Count_Msg > 0 THEN

		x_return_status := G_RET_STS_ERROR;
		RAISE FND_API.G_EXC_ERROR;
	END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'200: Leaving set_udv_with_procedures');
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1000: Leaving set_udv_with_procedures : OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;

      IF csr_get_udv_with_procs%ISOPEN THEN
         CLOSE csr_get_udv_with_procs;
      END IF;

      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2000: Leaving set_udv_with_procedures : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;

      IF csr_get_udv_with_procs%ISOPEN THEN
         CLOSE csr_get_udv_with_procs;
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'3000: Leaving set_udv_with_procedures because of EXCEPTION: '||sqlerrm);
      END IF;

      IF csr_get_udv_with_procs%ISOPEN THEN
         CLOSE csr_get_udv_with_procs;
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END set_udv_with_procedures ;

    -- Start of comments
    --API name      : get_udv_with_proc_value
    --Function      : This API returns the value for a user defined variable with procedure as source.
    --                This API is used in print terms and validate terms
    --Pre-reqs      : None.
    --Parameters    :
    --IN            : p_document_id         IN NUMBER       Required
    --              : p_doc_type            IN VARCHAR2		Required
	--		        : p_variable_code       IN VARCHAR2		Required
	--				: p_output_error		IN VARCHAR2     Optional
	--				: x_variable_value		OUT  VARCHAR2
    --              : x_return_status       OUT  VARCHAR2(1)
    --              : x_msg_count           OUT  NUMBER
    --              : x_msg_data            OUT  VARCHAR2(2000)
    --Note          :
    -- End of comments

PROCEDURE get_udv_with_proc_value (
        p_document_type         IN  VARCHAR2,
        p_document_id           IN  NUMBER,
        p_variable_code         IN  VARCHAR2,
		p_output_error			IN  VARCHAR2 :=  FND_API.G_FALSE,
		x_variable_value		OUT NOCOPY VARCHAR2,
	    x_return_status			OUT NOCOPY VARCHAR2,
		x_msg_data				OUT NOCOPY VARCHAR2,
	    x_msg_count				OUT NOCOPY NUMBER

	) IS


    l_api_name            CONSTANT VARCHAR2(30) := 'get_udv_with_proc_value';

    l_variable_value      VARCHAR2(2500) := NULL;

	l_procedure_name      okc_bus_variables_b.procedure_name%TYPE;
    l_value_set_id        okc_bus_variables_b.value_set_id%TYPE;
	l_variable_name       okc_bus_variables_tl.variable_name%TYPE;
    l_variable_value_id	  VARCHAR2(2500) := NULL;
    l_return_status       VARCHAR2(10);
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2500);
    l_dynamic_sql_stmt	  LONG;

    l_procedure_spec_status     ALL_OBJECTS.status%TYPE;
    l_procedure_body_status     ALL_OBJECTS.status%TYPE;
    l_dummy                     VARCHAR2(1);

	l_validation_type           fnd_flex_value_sets.validation_type%TYPE;
    l_table_name                fnd_flex_validation_tables.application_table_name%TYPE;
    l_name_col                  fnd_flex_validation_tables.value_column_name%TYPE;
    l_id_col                    fnd_flex_validation_tables.id_column_name%TYPE;
    l_additional_where_clause   fnd_flex_validation_tables.additional_where_clause%TYPE;
    l_sql_stmt                  LONG;
    TYPE cur_typ IS REF CURSOR;
    c_cursor cur_typ;

CURSOR csr_get_udv_with_proc_dtls IS
SELECT VB.procedure_name,
       VB.value_set_id,
	   VT.variable_name
FROM okc_bus_variables_b VB,
     okc_bus_variables_tl VT
WHERE VB.variable_code = VT.variable_code
AND VT.language =  USERENV('LANG')
AND VB.variable_code = p_variable_code
AND VB.variable_source = 'P';

CURSOR csr_get_validation_type(p_value_set_id IN NUMBER) IS
SELECT validation_type
FROM FND_FLEX_VALUE_SETS
WHERE  flex_value_set_id = p_value_set_id;

CURSOR csr_value_set_table(p_value_set_id IN NUMBER) IS
SELECT  application_table_name,
        value_column_name,
        id_column_name,
        additional_where_clause
FROM fnd_flex_validation_tables
WHERE flex_value_set_id = p_value_set_id;

--Expected procedure name is SCHEMA.PACKAGENAME.PROCEDURENAME

CURSOR csr_check_proc_spec_status (p_procedure_name VARCHAR2) IS
SELECT status
FROM all_objects
WHERE object_name = SUBSTR(p_procedure_name,
                           INSTR(p_procedure_name,'.')+1,
                           (INSTR(p_procedure_name,'.',1,2) -
                            INSTR(p_procedure_name,'.') - 1))
AND object_type = 'PACKAGE'
AND owner = SUBSTR(p_procedure_name,1,INSTR(p_procedure_name,'.')-1);


CURSOR csr_check_proc_body_status (p_procedure_name VARCHAR2) IS
SELECT status
FROM all_objects
WHERE object_name = SUBSTR(p_procedure_name,
                           INSTR(p_procedure_name,'.')+1,
                           (INSTR(p_procedure_name,'.',1,2) -
                            INSTR(p_procedure_name,'.') - 1))
AND object_type = 'PACKAGE BODY'
AND owner = SUBSTR(p_procedure_name,1,INSTR(p_procedure_name,'.')-1);

CURSOR csr_check_proc_exists (p_procedure_name VARCHAR2) IS
SELECT 'X'
FROM all_source
WHERE name = SUBSTR(p_procedure_name,
                           INSTR(p_procedure_name,'.')+1,
                           (INSTR(p_procedure_name,'.',1,2) -
                            INSTR(p_procedure_name,'.') - 1))
AND type = 'PACKAGE'
AND owner = SUBSTR(p_procedure_name,1,INSTR(p_procedure_name,'.')-1)
AND text LIKE '%' || SUBSTR(p_procedure_name,INSTR(p_procedure_name,'.',1,2)+1) || '%';


	BEGIN
		IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Entered get_udv_with_proc_value');
	    END IF;

	    /* Initialize API return status to success */
		x_return_status := G_RET_STS_SUCCESS;

		BEGIN
			OPEN csr_get_udv_with_proc_dtls;
            FETCH csr_get_udv_with_proc_dtls INTO l_procedure_name, l_value_set_id, l_variable_name;
            CLOSE csr_get_udv_with_proc_dtls;


		    /* Execute the procedure */
		    l_dynamic_sql_stmt := 'BEGIN '||l_procedure_name || '(' ||
				'x_return_status =>     '|| ':1' || ',' ||
				'x_msg_data =>          '|| ':2' || ',' ||
				'x_msg_count =>         '|| ':3' || ',' ||
				'p_doc_type =>          '|| ':4' || ',' ||
				'p_doc_id =>            '|| ':5' || ',' ||
				'p_variable_code =>     '|| ':6' || ',' ||
				'x_variable_value_id => '|| ':7' || '); END;';

			IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,'200: l_dynamic_sql_stmt '|| l_dynamic_sql_stmt);
				FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'200: variable_code:'||p_variable_code);
			END IF;

	        l_variable_value_id := NULL;

			EXECUTE IMMEDIATE l_dynamic_sql_stmt
				USING OUT l_return_status, OUT l_msg_data, OUT l_msg_count,
			    p_document_type, p_document_id, p_variable_code,
			    IN OUT l_variable_value_id;

	        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
				FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'300: Procedure return status:'||l_return_status);
			    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'300: Variable value id:'||l_variable_value_id);
	        END IF;

	        IF (l_return_status = G_RET_STS_ERROR) THEN

				l_variable_value_id := NULL;

				IF p_output_error = FND_API.G_TRUE THEN
					FND_MESSAGE.set_name('OKC','OKC_UDV_PROC_EXEC');
	                FND_MESSAGE.set_token('VAR_NAME', l_variable_name);
		            FND_MESSAGE.set_token('PROC_NAME', l_procedure_name);
			        FND_MSG_PUB.ADD;
				END IF;
	        ELSIF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN

				l_variable_value_id := NULL;

				IF p_output_error = FND_API.G_TRUE THEN
					FND_MESSAGE.set_name('OKC','OKC_UDV_PROC_UNEXP');
					FND_MESSAGE.set_token('VAR_NAME', l_variable_name);
	                FND_MESSAGE.set_token('PROC_NAME', l_procedure_name);
		            FND_MSG_PUB.ADD;
				END IF;
			END IF;

	    EXCEPTION
	    WHEN OTHERS THEN

			l_variable_value_id := NULL;

			IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'400: Error in procedure execution:'||sqlerrm);
			END IF;

			IF p_output_error = FND_API.G_TRUE THEN

				l_dummy := '?';
                OPEN csr_check_proc_exists(p_procedure_name => l_procedure_name);
                FETCH csr_check_proc_exists INTO l_dummy;

                OPEN csr_check_proc_spec_status(p_procedure_name => l_procedure_name);
                FETCH csr_check_proc_spec_status INTO l_procedure_spec_status;

                OPEN csr_check_proc_body_status(p_procedure_name => l_procedure_name);
                FETCH csr_check_proc_body_status INTO l_procedure_body_status;

                CLOSE csr_check_proc_exists;
                CLOSE csr_check_proc_spec_status;
                CLOSE csr_check_proc_body_status;

                IF l_dummy <> 'X' THEN
                    FND_MESSAGE.set_name('OKC','OKC_UDV_PROC_NOT_EXIST');
                    FND_MESSAGE.set_token('VAR_NAME', l_variable_name);
                    FND_MESSAGE.set_token('PROC_NAME', l_procedure_name);
                    FND_MSG_PUB.ADD;
                ELSIF l_procedure_spec_status = 'INVALID' OR l_procedure_body_status = 'INVALID' THEN
                    FND_MESSAGE.set_name('OKC','OKC_UDV_PROC_INVALID');
                    FND_MESSAGE.set_token('VAR_NAME', l_variable_name);
                    FND_MESSAGE.set_token('PROC_NAME', l_procedure_name);
                    FND_MSG_PUB.ADD;
                END IF;
			END IF;

	    END;

        /* Get the variable value from the variable value id using the value set */

		IF l_variable_value_id IS NOT NULL THEN

	        BEGIN

	            l_variable_value := NULL;

				OPEN csr_get_validation_type(p_value_set_id => l_value_set_id);
				FETCH csr_get_validation_type INTO l_validation_type;
				CLOSE csr_get_validation_type;

	            /* Valueset is Table type, execute the dynamic sql to get the variable value */
	            IF l_validation_type = 'F' THEN

					OPEN csr_value_set_table(p_value_set_id => l_value_set_id);
					FETCH csr_value_set_table INTO l_table_name, l_name_col, l_id_col, l_additional_where_clause;
					CLOSE csr_value_set_table;

					l_sql_stmt :=   'SELECT '||l_name_col||
									' FROM ('||
									' SELECT '||l_name_col||' , '||l_id_col||
									' FROM  '||l_table_name||' ';

					IF TRIM(l_additional_where_clause) IS NOT NULL THEN
						IF INSTR(UPPER(l_additional_where_clause),'WHERE') > 0 THEN
							l_sql_stmt := l_sql_stmt || l_additional_where_clause;
						ELSE
							l_sql_stmt :=  l_sql_stmt || 'WHERE '||l_additional_where_clause;
						END IF;
					END IF;

					l_sql_stmt := l_sql_stmt ||  ' ) WHERE to_char('||l_id_col|| ') = '''|| l_variable_value_id || '''';

	                OPEN c_cursor FOR l_sql_stmt;
	                FETCH c_cursor INTO l_variable_value;
	                CLOSE c_cursor;

	            /* Valueset is Independent type */
	            ELSIF l_validation_type = 'I' THEN

					l_variable_value := OKC_TERMS_UTIL_PVT.GET_VALUE_SET_VARIABLE_VALUE (
										p_CONTEXT => l_validation_type,
										p_VALUE_SET_ID => l_value_set_id,
										p_FLEX_VALUE_ID => l_variable_value_id);

				/* Valueset is None type */
				ELSE

					l_variable_value := l_variable_value_id;
				END IF;

	        EXCEPTION
            WHEN OTHERS THEN

				l_variable_value := NULL;

				IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
					FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'500: Error while fetching value from valueset:'||sqlerrm);
				END IF;

				IF p_output_error = FND_API.G_TRUE THEN
					FND_MESSAGE.set_name('OKC','OKC_UDV_VSET_INVALID');
					FND_MESSAGE.set_token('VAR_NAME', l_variable_name);
					FND_MSG_PUB.ADD;
				END IF;
	        END;

	    END IF;   /* IF l_variable_value_id IS NOT NULL*/

		x_variable_value := l_variable_value;

		IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'600: Variable value:'||l_variable_value);
			FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'700: Leaving  get_udv_with_proc_value');
		END IF;

	EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN

		IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		 FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1000: Leaving get_udv_with_proc_value : OKC_API.G_EXCEPTION_ERROR Exception');
		END IF;

		IF csr_get_udv_with_proc_dtls%ISOPEN THEN
		 CLOSE csr_get_udv_with_proc_dtls;
		END IF;

		x_return_status := G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		 FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2000: Leaving get_udv_with_proc_value : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
		END IF;

		IF csr_get_udv_with_proc_dtls%ISOPEN THEN
		 CLOSE csr_get_udv_with_proc_dtls;
		END IF;

		x_return_status := G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

	WHEN OTHERS THEN

		IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'3000: Leaving get_udv_with_proc_value because of EXCEPTION: '||sqlerrm);
		END IF;

		IF csr_get_udv_with_proc_dtls%ISOPEN THEN
		 CLOSE csr_get_udv_with_proc_dtls;
		END IF;

		x_return_status := G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
		FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
		END IF;
		FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END get_udv_with_proc_value;


END OKC_TERMS_UTIL_PVT;

/
