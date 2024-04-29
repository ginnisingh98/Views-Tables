--------------------------------------------------------
--  DDL for Package Body OKC_TERMS_COPY_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TERMS_COPY_GRP" AS
/* $Header: OKCGDCPB.pls 120.6.12010000.5 2011/12/09 13:29:36 serukull ship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                    CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_TERMS_COPY_GRP';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  g_module          CONSTANT VARCHAR2(250) := 'okc.plsql.'||g_pkg_name||'.';
  G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;

  G_RET_STS_SUCCESS            CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
  G_UNABLE_TO_RESERVE_REC      CONSTANT   VARCHAR2(200) := OKC_API.G_UNABLE_TO_RESERVE_REC;
  G_TEMPLATE_MISS_REC          OKC_TERMS_TEMPLATES_PVT.template_rec_type;

/*
--To be used when copying/transitioning a document

--p_keep_version should be passed as 'Y' in case of document transition.
--p_keep_version should be passed as 'N' in case of document copy where target
--document is expected to have same version of article as source document .
--p_copy_for_amendment should be passed as 'Y' when making amendment in
--sourcing.All other systems should pass it as 'N'.
--p_copy_deliverable should be passed as 'Y' when deliverable also needs to be
--copied.
--p_copy_abstract_yn should be 'Y' if there is a need to carry forward the approval_abstract_text onto the new document. Default:N.
*/

Procedure copy_doc     (
                        p_api_version             IN    Number,
                        p_init_msg_list           IN    Varchar2 ,
                        p_commit                  IN    Varchar2 ,
                        p_source_doc_type         IN    Varchar2,
                        p_source_doc_id           IN    Number,
                        p_target_doc_type         IN OUT NOCOPY Varchar2,
                        p_target_doc_id           IN OUT NOCOPY Number,
                        p_keep_version            IN    Varchar2 ,
                        p_article_effective_date  IN    Date ,
                        p_initialize_status_yn    IN    Varchar2 ,
                        p_reset_fixed_date_yn     IN    Varchar2 ,
                        p_internal_party_id       IN    Number ,
                        p_internal_contact_id     IN    Number ,
                        p_target_contractual_doctype  IN  Varchar2 ,
                        p_copy_del_attachments_yn     IN   Varchar2 ,
                        p_external_party_id       IN    Number ,
                        p_external_contact_id     IN    Number ,
                        p_copy_deliverables       IN    Varchar2 ,
                        p_document_number         IN    Varchar2 ,
                        p_copy_for_amendment      IN    Varchar2 ,
                        p_copy_doc_attachments    IN    Varchar2 ,
                        p_allow_duplicate_terms   IN    Varchar2,
                        p_copy_attachments_by_ref IN    Varchar2,
                        x_return_status           OUT   NOCOPY VARCHAR2,
                        x_msg_data                OUT   NOCOPY VARCHAR2,
                        x_msg_count               OUT   NOCOPY Number,
                        p_external_party_site_id          IN    Number,
                        p_copy_abstract_yn        IN    Varchar2,
				    p_contract_admin_id   IN NUMBER := NULL,
				    p_legal_contact_id    IN NUMBER := NULL
            -- Conc Mod Changes Start
            ,p_retain_lock_terms_yn        IN VARCHAR2 := 'N'
            ,p_retain_lock_xprt_yn         IN VARCHAR2 := 'N'
            ,p_add_only_amend_deliverables IN VARCHAR2 := 'N'
            ,p_rebuild_locks  IN VARCHAR2 := 'N'
            -- Conc Mod Changes End

                        )
IS
l_api_version                CONSTANT NUMBER := 1;
l_api_name                   CONSTANT VARCHAR2(30) := 'copy_doc';
l_contract_source            VARCHAR2(30);
l_copy_primary_doc_flag      VARCHAR2(1) := 'N' ;

CURSOR target_response_cur IS
SELECT TARGET_RESPONSE_DOC_TYPE
FROM   okc_bus_doc_types_b
WHERE  document_type = p_target_doc_type
AND    document_type_class = 'SOURCING';
l_target_response_doctype  okc_bus_doc_types_b.TARGET_RESPONSE_DOC_TYPE%TYPE;
--11.5.10+ derive deliverables_enabled_yn flag from okc_bus_doc_types_b
-- do not use the p_copy_deliverables param bug#3984339
CURSOR DEL_COPY_CUR IS
SELECT enable_deliverables_yn
FROM okc_bus_doc_types_b
where document_type = p_target_doc_type;

-- CLM changes Begins
CURSOR l_get_num_scheme_id(p_doc_type IN VARCHAR2, p_doc_id IN NUMBER) IS
SELECT doc_numbering_scheme
FROM okc_template_usages
WHERE document_type = p_doc_type
  AND document_id = p_doc_id;

l_num_scheme_id    NUMBER:=0;
-- CLM changes Ends


l_deliverables_enabled   VARCHAR2(1);
l_copy_deliverables      VARCHAR2(1);


BEGIN



    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Entered OKC_TERMS_COPY_GRP.copy_doc');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Parameter List ');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_api_version : '||p_api_version);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_init_msg_list : '||p_init_msg_list);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_commit : '||p_commit);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_source_doc_type : '||p_source_doc_type);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_source_doc_id : '||p_source_doc_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_target_doc_type : '||p_target_doc_type);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_target_doc_id : '||p_target_doc_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_keep_version : '||p_keep_version);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_article_effective_date : '||p_article_effective_date);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_initialize_status_yn : '||p_initialize_status_yn);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_reset_fixed_date_yn : '||p_reset_fixed_date_yn);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_internal_party_id : '||p_internal_party_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_internal_contact_id : '||p_internal_contact_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_target_contractual_doctype : '||p_target_contractual_doctype);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_copy_del_attachments_yn : '||p_copy_del_attachments_yn);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_external_party_id : '||p_external_party_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_external_party_site_id : '||p_external_party_site_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_external_contact_id : '||p_external_contact_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_copy_deliverables : '||p_copy_deliverables);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_document_number : '||p_document_number);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_copy_for_amendment : '||p_copy_for_amendment);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_copy_doc_attachments : '||p_copy_doc_attachments);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_allow_duplicate_terms : '||p_allow_duplicate_terms);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_copy_attachments_by_ref : '||p_copy_attachments_by_ref);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_retain_lock_terms_yn : '||p_retain_lock_terms_yn);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_retain_lock_xprt_yn : '||p_retain_lock_xprt_yn);
      --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_retain_lock_deliverables_yn : '||p_retain_lock_deliverables_yn);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_add_only_amend_deliverables : '||p_add_only_amend_deliverables);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_rebuild_locks : '||p_rebuild_locks);
    END IF;


    -- Standard Start of API savepoint
    SAVEPOINT g_copy_doc_GRP;

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


    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: calling OKC_TERMS_COPY_PVT.copy_tc');
    END IF;

    OKC_TERMS_COPY_PVT.copy_tc(
                                  p_api_version            => 1,
                                  p_init_msg_list          => FND_API.G_FALSE,
                                  p_commit                 => FND_API.G_FALSE,
                                  p_source_doc_type        => p_source_doc_type,
                                  p_source_doc_id          => p_source_doc_id ,
                                  p_target_doc_type        => p_target_doc_type,
                                  p_target_doc_id          => p_target_doc_id,
                                  p_keep_version           => p_keep_version,
                                  p_article_effective_date => p_article_effective_date,
                                  p_target_template_rec    => G_TEMPLATE_MISS_REC,
                                  p_document_number        => p_document_number,
                                  p_allow_duplicates       => p_allow_duplicate_terms,
                                  x_return_status          => x_return_status,
                                  x_msg_data               => x_msg_data,
                                  x_msg_count              => x_msg_count,
                                  p_copy_abstract_yn       => p_copy_abstract_yn,
				              p_copy_for_amendment     => p_copy_for_amendment,
						    p_contract_admin_id      => p_contract_admin_id,
						    p_legal_contact_id       => p_legal_contact_id
                -- Conc Mod changes start
                ,p_retain_lock_terms_yn   => p_retain_lock_terms_yn
                ,p_retain_lock_xprt_yn    => p_retain_lock_xprt_yn
                -- Conc Mod changes end
                );
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Finished OKC_TERMS_COPY_PVT.copy_tc, return status'||x_return_status);
   END IF;

   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   ELSIF (x_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR ;
   END IF;

          IF p_rebuild_locks = 'Y' THEN
            /* When merging the data from mod to award
               Source doc type is mod and target doc type is award.
               After merge we will get new ids  on the Award.
               So need to rebuild the locks with the new information
            */
            okc_k_entity_locks_grp.rebuild_locks
                       ( p_api_version     => 1,
                         p_update_from_doc_type  => p_source_doc_type,
                         p_update_from_doc_id  => p_source_doc_id,
                         p_update_to_doc_type    => p_target_doc_type,
                         p_update_to_doc_id      => p_target_doc_id,
                         X_RETURN_STATUS => x_return_status,
                         X_MSG_COUNT => X_MSG_COUNT,
                         X_MSG_DATA => X_MSG_DATA
                        );
                   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Finished okc_k_entity_locks_grp.rebuild_locks , return status '||x_return_status);
                  END IF;


              IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
             ELSIF (x_return_status = G_RET_STS_ERROR) THEN
              RAISE FND_API.G_EXC_ERROR ;
            END IF;


          END IF;




-----------------------------------------------------

    /* get the deliverables_enabled_yn flag before calling copy_deliverables bug#3984339 */


            OPEN del_copy_cur;
            FETCH del_copy_cur INTO l_deliverables_enabled;
            IF del_copy_cur%NOTFOUND THEN
                l_deliverables_enabled := null;
            END IF;
            CLOSE del_copy_cur;

                  If (l_deliverables_enabled = 'N') then
                   l_copy_deliverables := l_deliverables_enabled;
                  Elsif (l_deliverables_enabled = 'Y') then
             l_copy_deliverables := p_copy_deliverables;
                  End If;

  IF (l_copy_deliverables ='Y' AND p_copy_for_amendment='N') THEN

     /*  Call Deliverable API to copy Deliverables */
            -- get the target response doctype if the target is a
            -- Sourcing document (RFQ,RFI,AUCTION)Bug#3270742
            OPEN target_response_cur;
            FETCH target_response_cur INTO l_target_response_doctype;
            IF target_response_cur%NOTFOUND THEN
                l_target_response_doctype := null;
            END IF;
            CLOSE target_response_cur;


            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000:Entering OKC_DELIVERABLE_PROCESS_PVT.copy_deliverables.  ');
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000:source  busdoc id: '||to_char(p_source_doc_id));
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000:target busdoc id: '||to_char(p_target_doc_id));
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000:target busdoc type: '||p_target_doc_type);
            END IF;


            OKC_DELIVERABLE_PROCESS_PVT.copy_deliverables (
            p_api_version         => 1,
            p_init_msg_list       => FND_API.G_FALSE,
            p_source_doc_id       => p_source_doc_id,
            p_source_doc_type     => p_source_doc_type,
            p_target_doc_id       => p_target_doc_id,
            p_target_doc_type     => p_target_doc_type,
            p_initialize_status_yn => p_initialize_status_yn,
            p_reset_fixed_date_yn   => p_reset_fixed_date_yn,
            p_target_contractual_doctype  => p_target_contractual_doctype,
            p_target_response_doctype  => l_target_response_doctype,
            p_target_doc_number     => p_document_number,
            p_copy_del_attachments_yn     => p_copy_del_attachments_yn,
            p_internal_party_id   => p_internal_party_id,
            p_internal_contact_id => p_internal_contact_id,
            p_external_party_id   => p_external_party_id,
            p_external_party_site_id   => p_external_party_site_id,
            p_external_contact_id => p_external_contact_id,
            x_msg_data       => x_msg_data,
            x_msg_count       => x_msg_count,
            x_return_status       => x_return_status
            ,p_add_only_amend_deliverables => p_add_only_amend_deliverables
             );

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1100:Finished OKC_DELIVERABLE_PROCESS_PVT.copy_deliverables  ');
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1100: OKC_DELIVERABLE_PROCESS_PVT.copy_deliverables x_return_status :  '||x_return_status);
            END IF;

            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
            END IF;

  END IF;
-------------------------------------------------------

  IF (l_copy_deliverables ='Y' AND p_copy_for_amendment='Y') THEN

         IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000:Entering OKC_DELIVERABLE_PROCESS_PVT.copy_del_for_amendment.');
         END IF;


         OKC_DELIVERABLE_PROCESS_PVT.copy_del_for_amendment (
         p_api_version         => 1,
         p_init_msg_list       => FND_API.G_FALSE,
         p_source_doc_id       => p_source_doc_id,
         p_source_doc_type     => p_source_doc_type,
         p_target_doc_id       => p_target_doc_id,
         p_target_doc_type     => p_target_doc_type,
         p_reset_fixed_date_yn   => p_reset_fixed_date_yn,
         p_target_doc_number     => p_document_number,
         x_msg_data            => x_msg_data,
         x_msg_count           => x_msg_count,
         x_return_status       => x_return_status,
         p_copy_del_attachments_yn => p_copy_del_attachments_yn,
         p_target_contractual_doctype  => p_target_contractual_doctype);

         IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1100:Finished OKC_DELIVERABLE_PROCESS_PVT.copy_del_for_amendment.  ');
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1100:OKC_DELIVERABLE_PROCESS_PVT.copy_del_for_amendment x_return_status :  '||x_return_status);
         END IF;

         IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
         ELSIF (x_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR ;
         END IF;

  END IF;

--Added l_copy_primary_doc_flag for 10+ word integration
---------------------------------------------------------
    l_contract_source := OKC_TERMS_UTIL_GRP.Get_Contract_Source_code(
                                    p_document_type    => p_source_doc_type,
                                    p_document_id      => p_source_doc_id
                                    );
    IF (l_contract_source = 'E') THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

---------------------------------------------------------

  IF (p_copy_doc_attachments ='N' AND l_contract_source = 'ATTACHED') THEN
  /* Copy only primary contract doc, p_copy_primary_doc_flag is set to 'Y'*/
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1150:Entering OKC_CONTRACT_DOCS_GRP.Copy_Attachments  ');
    END IF;

    OKC_CONTRACT_DOCS_GRP.Copy_Attachments (
                          p_api_version  =>1,
                          p_init_msg_list =>FND_API.G_FALSE,
                          x_msg_data            => x_msg_data,
                          x_msg_count           => x_msg_count,
                          x_return_status       => x_return_status,
                          p_from_bus_doc_type => p_source_doc_type ,
                          p_from_bus_doc_id   => p_source_doc_id,
                          p_from_bus_doc_version => -99,
                          p_to_bus_doc_type    => p_target_doc_type,
                          p_to_bus_doc_id     => p_target_doc_id,
                          p_to_bus_doc_version => -99,
                          p_copy_by_ref => p_copy_attachments_by_ref,
                          p_copy_primary_doc_flag => 'Y') ;

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1151:Finished OKC_CONTRACT_DOCS_GRP.Copy_Attachments ');
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1151:OKC_CONTRACT_DOCS_GRP.Copy_Attachments x_return_status : '||x_return_status);
       END IF;

       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR ;
       END IF;
  ELSIF (p_copy_doc_attachments ='Y' ) THEN
  /* Copy all attachments*/
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1156:Entering OKC_CONTRACT_DOCS_GRP.Copy_Attachments  ');
    END IF;

    OKC_CONTRACT_DOCS_GRP.Copy_Attachments (
                          p_api_version  =>1,
                          p_init_msg_list =>FND_API.G_FALSE,
                          x_msg_data            => x_msg_data,
                          x_msg_count           => x_msg_count,
                          x_return_status       => x_return_status,
                          p_from_bus_doc_type => p_source_doc_type ,
                          p_from_bus_doc_id   => p_source_doc_id,
                          p_from_bus_doc_version => -99,
                          p_to_bus_doc_type    => p_target_doc_type,
                          p_to_bus_doc_id     => p_target_doc_id,
                          p_to_bus_doc_version => -99,
                          p_copy_by_ref => p_copy_attachments_by_ref,
                          p_copy_primary_doc_flag => 'N',
						  p_copy_for_amendment => p_copy_for_amendment) ;

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1157:Finished OKC_CONTRACT_DOCS_GRP.Copy_Attachments ');
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1158:OKC_CONTRACT_DOCS_GRP.Copy_Attachments x_return_status : '||x_return_status);
       END IF;

       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR ;
       END IF;
  END IF;

-------------------------------------------------------------


-- CLM changes Begins  Call renumber after applying template on a document

      OPEN l_get_num_scheme_id(p_doc_type => p_target_doc_type, p_doc_id => p_target_doc_id) ;
         FETCH l_get_num_scheme_id INTO l_num_scheme_id;
      CLOSE l_get_num_scheme_id;

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: l_num_scheme_id : '||l_num_scheme_id);
   END IF;


IF NVL(l_num_scheme_id,0) <> 0 THEN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Calling apply_numbering_scheme for num_scheme_id : '||l_num_scheme_id);
    END IF;

          OKC_NUMBER_SCHEME_GRP.apply_numbering_scheme(
           p_api_version        => p_api_version,
           p_init_msg_list      => FND_API.G_FALSE,
           x_return_status      => x_return_status,
           x_msg_count          => x_msg_count,
           x_msg_data           => x_msg_data,
           p_validate_commit    => FND_API.G_FALSE,
           p_validation_string  => null,
           p_commit             => FND_API.G_FALSE,
           p_doc_type           => p_target_doc_type,
           p_doc_id             => p_target_doc_id,
           p_num_scheme_id      => l_num_scheme_id
         );


   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: returned from OKC_NUMBER_SCHEME_GRP.apply_numbering_scheme , return status : '||x_return_status);
   END IF;

          IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
          ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                  RAISE FND_API.G_EXC_ERROR ;
          END IF;


END IF; --l_num_scheme_id is not 0

-- CLM changes Ends

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

-- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000: Leaving copy_doc');
   END IF;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN

 IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'800: Leaving copy_doc: OKC_API.G_EXCEPTION_ERROR Exception');
 END IF;

 ROLLBACK TO g_copy_doc_grp;
 x_return_status := G_RET_STS_ERROR ;
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
 IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'900: Leaving copy_doc: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
 END IF;

 ROLLBACK TO g_copy_doc_grp;
 x_return_status := G_RET_STS_UNEXP_ERROR ;
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN OTHERS THEN
IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving copy_doc because of EXCEPTION: '||sqlerrm);
END IF;

ROLLBACK TO g_copy_doc_grp;
x_return_status := G_RET_STS_UNEXP_ERROR ;
IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
END IF;
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
END copy_doc;

/*
--To be used when copying a terms template to make a new template or to make a
-- woring copy.

*/

Procedure copy_terms_template   (
                        p_api_version       IN       Number,
                        p_init_msg_list     IN       Varchar2,
                        p_commit            IN       Varchar2,
                        p_template_id       IN       Number,
                        p_tmpl_name         IN       Varchar2,
                        p_intent            IN       Varchar2,
                        p_start_date        IN       Date,
                        p_end_date          IN       Date,
                        p_instruction_text  IN       Varchar2,
                        p_description       IN       Varchar2,
                        p_print_Template_Id IN       Number,
                        p_global_flag       IN       Varchar2,
                        p_contract_expert_enabled IN Varchar2,
                        p_xprt_clause_mandatory_flag IN VARCHAR2 := NULL,
                        p_xprt_scn_code      IN      VARCHAR2 := NULL,
                        p_attribute_category IN      Varchar2,
                        p_attribute1         IN      Varchar2,
                        p_attribute2         IN      Varchar2,
                        p_attribute3         IN      Varchar2,
                        p_attribute4         IN      Varchar2,
                        p_attribute5         IN      Varchar2,
                        p_attribute6         IN      Varchar2,
                        p_attribute7         IN      Varchar2,
                        p_attribute8         IN      Varchar2,
                        p_attribute9         IN      Varchar2,
                        p_attribute10        IN      Varchar2,
                        p_attribute11        IN      Varchar2,
                        p_attribute12        IN      Varchar2,
                        p_attribute13        IN      Varchar2,
                        p_attribute14        IN      Varchar2,
                        p_attribute15        IN      Varchar2,
                        p_copy_deliverables  IN      Varchar2,
                        p_translated_from_tmpl_id IN       Number,
                        p_language                IN       Varchar2,
                        x_template_id        OUT     NOCOPY  Number,
                        x_return_status      OUT     NOCOPY Varchar2,
                        x_msg_data           OUT     NOCOPY Varchar2,
                        x_msg_count          OUT     NOCOPY Number
                        )IS
l_api_version                CONSTANT NUMBER := 1;
l_api_name                   CONSTANT VARCHAR2(30) := 'copy_terms_template';
l_template_rec               OKC_TERMS_TEMPLATES_PVT.template_rec_type;
l_document_type            OKC_BUS_DOC_TYPES_B.DOCUMENT_TYPE%TYPE := OKC_TERMS_UTIL_GRP.G_TMPL_DOC_TYPE;
l_dummy                      VARCHAR2(1) :='?';
l_deliverables_exist        VARCHAR2(100);

CURSOR l_get_tmpl_csr IS
SELECT * FROM OKC_TERMS_TEMPLATES_ALL
WHERE template_id=p_template_id;

CURSOR l_check_tmpl_name_csr(b_org_id NUMBER) IS
SELECT 'x' FROM OKC_TERMS_TEMPLATES_ALL
WHERE org_id=b_org_id
AND   template_name=p_tmpl_name;

l_tmpl_rec l_get_tmpl_csr%ROWTYPE;

l_article_effective_date  DATE;

BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Entered OKC_TERMS_COPY_GRP.copy_terms_template');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Parameter List ');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_api_version : '||p_api_version);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_init_msg_list : '||p_init_msg_list);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_commit : '||p_commit);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_template_id : '||p_template_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_tmpl_name : '||p_tmpl_name);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_intent : '||p_intent);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_start_date : '||p_start_date);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_end_date : '||p_end_date);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_print_Template_Id : '||p_print_Template_Id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_global_flag : '||p_global_flag);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_contract_expert_enabled : '||p_contract_expert_enabled);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_copy_deliverables : '||p_copy_deliverables);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_attribute_category : '||p_attribute_category);
    END IF;


    -- Standard Start of API savepoint
    SAVEPOINT g_copy_terms_template_GRP;

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

    OPEN  l_get_tmpl_csr;
    FETCH l_get_tmpl_csr INTO l_tmpl_rec;
    CLOSE l_get_tmpl_csr;

    SELECT mo_global.get_current_org_id()
          INTO l_template_rec.org_id from dual;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'110: Current Org Id : '||l_template_rec.org_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'110: Global Org Id : '||nvl(fnd_profile.value('OKC_GLOBAL_ORG_ID'),'-99'));
    END IF;

    -- check if copy from Global to Local Org
    -- In that case make global_yn for Local Org template to N

    IF nvl(fnd_profile.value('OKC_GLOBAL_ORG_ID'),'-99') <> l_template_rec.org_id THEN
       l_template_rec.global_flag := 'N';
    ELSE
       -- keep flag as is as this is within the same org copy
      l_template_rec.global_flag             := p_global_flag;
    END IF; -- check orgs


    OPEN  l_check_tmpl_name_csr(l_template_rec.org_id);
    FETCH l_check_tmpl_name_csr INTO l_dummy;

    IF l_check_tmpl_name_csr%FOUND THEN

       okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKC_SAME_TMPL_NAME');
       RAISE FND_API.G_EXC_ERROR ;

    END IF;

    CLOSE l_check_tmpl_name_csr;


    l_template_rec.template_name           := p_tmpl_name;
    l_template_rec.working_copy_flag       := 'N';
    l_template_rec.parent_template_id      := NULL;
    l_template_rec.intent                  := p_intent;
    l_template_rec.status_code             := 'DRAFT';
    l_template_rec.start_date              := p_start_date;
    l_template_rec.end_date                := p_end_date;
 --   l_template_rec.global_flag             := p_global_flag;
    l_template_rec.contract_expert_enabled := p_contract_expert_enabled;

    l_template_rec.xprt_clause_mandatory_flag := p_xprt_clause_mandatory_flag;
    l_template_rec.xprt_scn_code           := p_xprt_scn_code;
    l_template_rec.instruction_text        := p_instruction_text;
    l_template_rec.description             := p_description;
    l_template_rec.print_Template_Id       := p_print_Template_Id;
    l_template_rec.tmpl_numbering_scheme   := l_tmpl_rec.tmpl_numbering_scheme;
    l_template_rec.attribute_category      := p_attribute_category;
    l_template_rec.attribute1              := p_attribute1;
    l_template_rec.attribute2              := p_attribute2;
    l_template_rec.attribute3              := p_attribute3;
    l_template_rec.attribute4              := p_attribute4;
    l_template_rec.attribute5              := p_attribute5;
    l_template_rec.attribute6              := p_attribute6;
    l_template_rec.attribute7              := p_attribute7;
    l_template_rec.attribute8              := p_attribute8;
    l_template_rec.attribute9              := p_attribute9;
    l_template_rec.attribute10             := p_attribute10;
    l_template_rec.attribute11             := p_attribute11;
    l_template_rec.attribute12             := p_attribute12;
    l_template_rec.attribute13             := p_attribute13;
    l_template_rec.attribute14             := p_attribute14;
    l_template_rec.attribute15             := p_attribute15;
--MLS for templates
    l_template_rec.language                := p_language;


    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: calling OKC_TERMS_COPY_PVT.copy_tc');
    END IF;

/*
   New Business Rules for p_article_effective_date in template to template copy
*/
    IF NVL(p_end_date,sysdate) >= sysdate  THEN
       IF p_start_date > sysdate THEN
          l_article_effective_date := p_start_date;
       ELSE
          l_article_effective_date := sysdate;
       END IF;
    ELSE
       l_article_effective_date := p_end_date;
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: l_article_effective_date : '||l_article_effective_date);
    END IF;


    OKC_TERMS_COPY_PVT.copy_tc(
                                  p_api_version            => 1,
                                  p_init_msg_list          => FND_API.G_FALSE,
                                  p_commit                 => FND_API.G_FALSE,
                                  p_source_doc_type        => OKC_TERMS_UTIL_GRP.G_TMPL_DOC_TYPE,
                                  p_source_doc_id          => p_template_id,
                                  p_target_doc_type        => l_document_type,
                                  p_target_doc_id          => x_template_id,
                                  p_keep_version           => 'N',
                                  p_article_effective_date => l_article_effective_date,
                                  p_target_template_rec    => l_template_rec,
                                  x_return_status          => x_return_status,
                                  x_msg_data               => x_msg_data,
                                  x_msg_count              => x_msg_count);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Finished OKC_TERMS_COPY_PVT.copy_tc, return status : '||x_return_status);
   END IF;

   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   ELSIF (x_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR ;
   END IF;
-----------------------------------
  /* Fix for the Bug# 4113678, check whether if the deliverables exist before copying deliverables */

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: calling okc_terms_util_grp.Is_Deliverable_Exist');
   END IF;

  l_deliverables_exist :=  okc_terms_util_grp.Is_Deliverable_Exist(
         p_api_version      => 1,
         p_init_msg_list    =>  FND_API.G_FALSE,
         x_return_status    => x_return_status,
         x_msg_data         => x_msg_data,
         x_msg_count        => x_msg_count,
         p_doc_type         => 'TEMPLATE',
         p_doc_id           => p_template_id);

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'700: Finished okc_terms_util_grp.Is_Deliverable_Exist, return status : '||x_return_status);
   END IF;

  l_deliverables_exist := UPPER(nvl(l_deliverables_exist,'NONE'));

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'700: l_deliverables_exist: ' || l_deliverables_exist);
   END IF;

  IF ( p_copy_deliverables='Y' AND l_deliverables_exist <> 'NONE') THEN

     /*  Call Deliverable API to copy Deliverables */

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000:Entering OKC_DELIVERABLE_PROCESS_PVT.copy_deliverables.  ');
            END IF;


            OKC_DELIVERABLE_PROCESS_PVT.copy_deliverables (
            p_api_version            => 1,
            p_init_msg_list          => FND_API.G_FALSE,
            p_source_doc_type        => OKC_TERMS_UTIL_GRP.G_TMPL_DOC_TYPE,
            p_source_doc_id          => p_template_id,
            p_target_doc_type        => l_document_type,
            p_target_doc_id          => x_template_id,
            p_internal_party_id      => l_template_rec.org_id, -- bug#4335441
            p_internal_contact_id    => Null,
            p_external_party_id      => Null,
            p_external_contact_id    => Null,
            p_target_doc_number     => x_template_id, -- bug#3722131
            p_copy_del_attachments_yn     => 'Y',
            x_msg_data            => x_msg_data,
            x_msg_count           => x_msg_count,
            x_return_status       => x_return_status );

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1100:Finished OKC_DELIVERABLE_PROCESS_PVT.copy_deliverables ');
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1100:OKC_DELIVERABLE_PROCESS_PVT.copy_deliverables x_return_status : '||x_return_status);
            END IF;

            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
            END IF;

 END IF;




-----------------------------------
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

-- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000: Leaving copy_terms_template');
   END IF;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN

 IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'800: Leaving copy_terms_template: OKC_API.G_EXCEPTION_ERROR Exception');
 END IF;

 IF l_get_tmpl_csr%ISOPEN THEN
    CLOSE l_get_tmpl_csr;
 END IF;

 IF l_check_tmpl_name_csr%ISOPEN THEN
    CLOSE l_check_tmpl_name_csr;
 END IF;

 ROLLBACK TO g_copy_terms_template_grp;
 x_return_status := G_RET_STS_ERROR ;
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
 IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'900: Leaving copy_terms_template: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
 END IF;

 IF l_get_tmpl_csr%ISOPEN THEN
    CLOSE l_get_tmpl_csr;
 END IF;

 IF l_check_tmpl_name_csr%ISOPEN THEN
    CLOSE l_check_tmpl_name_csr;
 END IF;

 ROLLBACK TO g_copy_terms_template_grp;
 x_return_status := G_RET_STS_UNEXP_ERROR ;
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN OTHERS THEN
IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving copy_terms_template because of EXCEPTION: '||sqlerrm);
END IF;

IF l_get_tmpl_csr%ISOPEN THEN
   CLOSE l_get_tmpl_csr;
END IF;

 IF l_check_tmpl_name_csr%ISOPEN THEN
    CLOSE l_check_tmpl_name_csr;
 END IF;

ROLLBACK TO g_copy_terms_template_grp;
x_return_status := G_RET_STS_UNEXP_ERROR ;
IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
END IF;
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
END copy_terms_template;

/*
--To be used when instantiating a term on a document.
*/
Procedure copy_terms   (
                        p_api_version             IN    Number,
                        p_init_msg_list               IN        Varchar2 ,
                        p_commit                      IN        Varchar2 ,
                        p_template_id             IN    Number,
                        p_target_doc_type             IN        Varchar2,
                        p_target_doc_id           IN    Number,
                        p_article_effective_date  IN    Date ,
                        p_retain_deliverable      IN    Varchar2 ,
                        p_target_contractual_doctype IN Varchar2,
                        p_target_response_doctype    IN Varchar2,
                        p_internal_party_id              IN     Number ,
                        p_internal_contact_id        IN Number ,
                        p_external_party_id              IN     Number ,
                        p_external_party_site_id                 IN     Number ,
                        p_external_contact_id        IN Number ,
                        p_validate_commit                IN     Varchar2 ,
                        p_validation_string          IN Varchar2,
                        p_document_number                IN     Varchar2 ,
                        x_return_status              OUT        NOCOPY Varchar2,
                        x_msg_data                       OUT    NOCOPY Varchar2,
                        x_msg_count                      OUT    NOCOPY Number,
                        p_retain_clauses      IN    Varchar2 ,                --kkolukul: clm changes
			p_contract_admin_id   IN NUMBER := NULL,
			p_legal_contact_id   IN NUMBER := NULL
                        ) IS

l_api_version                CONSTANT NUMBER := 1;
l_api_name                   CONSTANT VARCHAR2(30) := 'copy_terms';
l_ok_to_commit               VARCHAR2(1);
l_document_id              OKC_TEMPLATE_USAGES.DOCUMENT_ID%TYPE := p_target_doc_id;
l_document_type            OKC_BUS_DOC_TYPES_B.DOCUMENT_TYPE%TYPE := p_target_doc_type;
l_template_exists          VARCHAR2(1);

CURSOR target_response_cur IS
SELECT TARGET_RESPONSE_DOC_TYPE
FROM   okc_bus_doc_types_b
WHERE  document_type = p_target_doc_type
AND    document_type_class = 'SOURCING';

l_target_response_doctype  okc_bus_doc_types_b.TARGET_RESPONSE_DOC_TYPE%TYPE;

CURSOR l_get_num_scheme_id(p_doc_type IN VARCHAR2, p_doc_id IN NUMBER) IS
SELECT doc_numbering_scheme
FROM okc_template_usages
WHERE document_type = p_doc_type
  AND document_id = p_doc_id;

l_num_scheme_id    NUMBER:=0;
-- bug#4113619
CURSOR enable_deliverables_cur IS
SELECT enable_deliverables_yn
FROM   okc_bus_doc_types_b
WHERE  document_type = p_target_doc_type;
l_enable_deliverables  VARCHAR2(1);

BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Entered OKC_TERMS_COPY_GRP.copy_terms');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Parameter List ');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_api_version : '||p_api_version);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_init_msg_list : '||p_init_msg_list);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_commit : '||p_commit);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_template_id : '||p_template_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_target_doc_type : '||p_target_doc_type);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_target_doc_id : '||p_target_doc_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_article_effective_date : '||p_article_effective_date);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_retain_deliverable : '||p_retain_deliverable);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_target_contractual_doctype : '||p_target_contractual_doctype);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_target_response_doctype : '||p_target_response_doctype);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_validate_commit : '||p_validate_commit);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_validation_string : '||p_validation_string);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_document_number : '||p_document_number);
    END IF;


    -- Standard Start of API savepoint
    SAVEPOINT g_copy_terms_GRP;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF FND_API.To_Boolean( p_validate_commit )  AND
       NOT FND_API.To_Boolean(OKC_TERMS_UTIL_GRP.ok_to_commit (
                                         p_api_version => l_api_version,
                                         p_init_msg_list => FND_API.G_FALSE,
                                         p_doc_type      => p_target_doc_type,
                                         p_doc_id        => p_target_doc_id,
                                         p_validation_string =>p_validation_string,
                                         p_tmpl_change   => 'Y',
                                         x_return_status => x_return_status,
                                         x_msg_data      => x_msg_data,
                                         x_msg_count     => x_msg_count)                  ) THEN

             IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'700: Issue with document header Record.Cannot commit');
             END IF;
             RAISE FND_API.G_EXC_ERROR ;
    END IF;

    /*Clm Changes : Donot apply multiple templates if the template is already applied on the doc. */
    IF (p_retain_clauses = 'Y') THEN
      l_template_exists := OKC_CLM_PKG.check_dup_templates(p_document_type  => p_target_doc_type,
                               p_document_id        =>p_target_doc_id,
                               p_template_id        => p_template_id);

      IF l_template_exists = 'Y' THEN
       okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKC_SAME_TMPL_NAME');
       RAISE FND_API.G_EXC_ERROR ;
      END IF;
    END IF;
   -- end CLM Changes

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: calling OKC_TERMS_COPY_PVT.copy_tc');
    END IF;

    OKC_TERMS_COPY_PVT.copy_tc(
                                  p_api_version            => 1,
                                  p_init_msg_list          => FND_API.G_FALSE,
                                  p_commit                 => FND_API.G_FALSE,
                                  p_source_doc_type        => OKC_TERMS_UTIL_GRP.G_TMPL_DOC_TYPE,
                                  p_source_doc_id          => p_template_id,
                                  p_target_doc_type        => l_document_type,
                                  p_target_doc_id          => l_document_id,
                                  p_document_number        => p_document_number,
                                  p_keep_version           => 'N',
                                  p_article_effective_date => p_article_effective_date,
                                  p_target_template_rec    => G_TEMPLATE_MISS_REC,
                                  p_retain_deliverable     => p_retain_deliverable,
                                  x_return_status          => x_return_status,
                                  x_msg_data               => x_msg_data,
                                  x_msg_count              => x_msg_count,
						    p_contract_admin_id      => p_contract_admin_id,
						    p_legal_contact_id       => p_legal_contact_id,
                                  p_retain_clauses         => p_retain_clauses);

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: returned from OKC_TERMS_COPY_PVT.copy_tc, return status : '||x_return_status);
   END IF;

   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   ELSIF (x_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR ;
   END IF;


----------------------------------
     /*  Call Deliverable API to copy Deliverables */
            -- check if deliverables are enables for this document bug#4113619
            OPEN  enable_deliverables_cur;
            FETCH enable_deliverables_cur into l_enable_deliverables;
            CLOSE enable_deliverables_cur;

        IF l_enable_deliverables = 'Y' THEN

            -- get the target response doctype if the target is a
            -- Sourcing document (RFQ,RFI,AUCTION)Bug#3270742
            OPEN target_response_cur;
            FETCH target_response_cur INTO l_target_response_doctype;
            CLOSE target_response_cur;

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000:Entering OKC_DELIVERABLE_PROCESS_PVT.copy_deliverables ');
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000:l_target_response_doctype: '||l_target_response_doctype);
            END IF;


            OKC_DELIVERABLE_PROCESS_PVT.copy_deliverables (
            p_api_version         => 1,
            p_init_msg_list       => FND_API.G_FALSE,
            p_source_doc_type        => OKC_TERMS_UTIL_GRP.G_TMPL_DOC_TYPE,
            p_source_doc_id          => p_template_id,
            p_target_doc_type        => l_document_type,
            p_target_doc_id          => l_document_id,
            p_target_doc_number      => p_document_number,
            p_internal_party_id      => p_internal_party_id,
            p_internal_contact_id    => p_internal_contact_id,
            p_external_party_id      => p_external_party_id,
            p_external_party_site_id      => p_external_party_site_id,
            p_external_contact_id    => p_external_contact_id,
            p_target_contractual_doctype    => p_target_contractual_doctype,
            p_target_response_doctype       => l_target_response_doctype,
            p_copy_del_attachments_yn       => 'Y',
            x_msg_data            => x_msg_data,
            x_msg_count           => x_msg_count,
            x_return_status       => x_return_status );

          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1100:Finished OKC_DELIVERABLE_PROCESS_PVT.copy_deliverables ');
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1100:OKC_DELIVERABLE_PROCESS_PVT.copy_deliverables x_return_status : '||x_return_status);
          END IF;

          IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
          ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR ;
          END IF;

        END IF; -- l_enable_deliverables = 'Y' THEN

-- Bug 3674173 : Call renumber after applying template on a document

      OPEN l_get_num_scheme_id(p_doc_type => l_document_type, p_doc_id => l_document_id) ;
         FETCH l_get_num_scheme_id INTO l_num_scheme_id;
      CLOSE l_get_num_scheme_id;

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: l_num_scheme_id : '||l_num_scheme_id);
   END IF;

--kkolukul: clm changes: to re-apply empty numbering scheme
IF (NVL(l_num_scheme_id,0) <> 0 OR p_retain_clauses = 'Y') THEN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Calling apply_numbering_scheme for num_scheme_id : '||l_num_scheme_id);
    END IF;

          OKC_NUMBER_SCHEME_GRP.apply_numbering_scheme(
           p_api_version        => p_api_version,
           p_init_msg_list      => FND_API.G_FALSE,
           x_return_status      => x_return_status,
           x_msg_count          => x_msg_count,
           x_msg_data           => x_msg_data,
           p_validate_commit    => FND_API.G_FALSE,
           p_validation_string  => p_validation_string,
           p_commit             => FND_API.G_FALSE,
           p_doc_type           => l_document_type,
           p_doc_id             => l_document_id,
           p_num_scheme_id      => l_num_scheme_id
         );


   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: returned from OKC_NUMBER_SCHEME_GRP.apply_numbering_scheme , return status : '||x_return_status);
   END IF;

          IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
          ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                  RAISE FND_API.G_EXC_ERROR ;
          END IF;


END IF; --l_num_scheme_id is not 0



-- End Bug 3674173


------------------------------------
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

-- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000: Leaving copy_terms');
   END IF;



EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN

 IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'800: Leaving copy_terms: OKC_API.G_EXCEPTION_ERROR Exception');
 END IF;

 ROLLBACK TO g_copy_terms_grp;
 x_return_status := G_RET_STS_ERROR ;
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
 IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'900: Leaving copy_terms: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
 END IF;


 ROLLBACK TO g_copy_terms_grp;
 x_return_status := G_RET_STS_UNEXP_ERROR ;
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN OTHERS THEN
IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving copy_terms because of EXCEPTION: '||sqlerrm);
END IF;

ROLLBACK TO g_copy_terms_grp;
x_return_status := G_RET_STS_UNEXP_ERROR ;
IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
END IF;
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );


END copy_terms;

/* To be used to create Revision of a Template */

Procedure create_template_revision  (
                        p_api_version       IN       Number,
                        p_init_msg_list     IN       Varchar2 default FND_API.G_FALSE,
                        p_commit            IN       Varchar2 default FND_API.G_FALSE,
                        p_template_id       IN       Number,
                        p_copy_deliverables IN      Varchar2 default 'Y',
                        x_template_id       OUT NOCOPY  Number,
                        x_return_status     OUT        NOCOPY Varchar2,
                        x_msg_data          OUT        NOCOPY Varchar2,
                        x_msg_count         OUT        NOCOPY Number) IS

l_api_version                CONSTANT NUMBER := 1;
l_api_name                   CONSTANT VARCHAR2(30) := 'create_template_revision';
l_template_rec               OKC_TERMS_TEMPLATES_PVT.template_rec_type;
l_document_type            OKC_BUS_DOC_TYPES_B.DOCUMENT_TYPE%TYPE := OKC_TERMS_UTIL_GRP.G_TMPL_DOC_TYPE;
l_copy_deliverables          VARCHAR2(1);

CURSOR l_get_tmpl_csr IS
SELECT * FROM OKC_TERMS_TEMPLATES_ALL
WHERE template_id=p_template_id;

l_tmpl_rec l_get_tmpl_csr%ROWTYPE;
BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Entered OKC_TERMS_COPY_GRP.create_template_revision');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Parameter List ');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_api_version : '||p_api_version);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_init_msg_list : '||p_init_msg_list);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_commit : '||p_commit);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_template_id : '||p_template_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_copy_deliverables : '||p_copy_deliverables);
    END IF;


    -- Standard Start of API savepoint
    SAVEPOINT g_create_template_revision_GRP;

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

    OPEN  l_get_tmpl_csr;
    FETCH l_get_tmpl_csr INTO l_tmpl_rec;
    CLOSE l_get_tmpl_csr;

    l_template_rec.template_name          := l_tmpl_rec.template_name;
    l_template_rec.working_copy_flag      := 'Y';
    l_template_rec.parent_template_id     := p_template_id;
    l_template_rec.intent                 := l_tmpl_rec.intent;
    l_template_rec.status_code            := 'REVISION';
    l_template_rec.start_date             := l_tmpl_rec.start_date;
    l_template_rec.end_date               := l_tmpl_rec.end_date;
    l_template_rec.global_flag            := l_tmpl_rec.global_flag;
    l_template_rec.print_template_id      := l_tmpl_rec.print_template_id;
    l_template_rec.contract_expert_enabled:= l_tmpl_rec.contract_expert_enabled;
    l_template_rec.instruction_text       := l_tmpl_rec.instruction_text;
    l_template_rec.description            := l_tmpl_rec.description;
    l_template_rec.org_id                 := l_tmpl_rec.org_id;
    l_template_rec.tmpl_numbering_scheme  := l_tmpl_rec.tmpl_numbering_scheme;
    l_template_rec.template_model_id      := l_tmpl_rec.template_model_id;
    l_template_rec.orig_system_reference_code:=l_tmpl_rec.orig_system_reference_code;
    l_template_rec.orig_system_reference_id1:=l_tmpl_rec.orig_system_reference_id1;
    l_template_rec.orig_system_reference_id2:=l_tmpl_rec.orig_system_reference_id2;
    l_template_rec.attribute_category     := l_tmpl_rec.attribute_category;
    l_template_rec.attribute1             := l_tmpl_rec.attribute1;
    l_template_rec.attribute2             := l_tmpl_rec.attribute2;
    l_template_rec.attribute3             := l_tmpl_rec.attribute3;
    l_template_rec.attribute4             := l_tmpl_rec.attribute4;
    l_template_rec.attribute5             := l_tmpl_rec.attribute5;
    l_template_rec.attribute6             := l_tmpl_rec.attribute6;
    l_template_rec.attribute7             := l_tmpl_rec.attribute7;
    l_template_rec.attribute8             := l_tmpl_rec.attribute8;
    l_template_rec.attribute9             := l_tmpl_rec.attribute9;
    l_template_rec.attribute10            := l_tmpl_rec.attribute10;
    l_template_rec.attribute11            := l_tmpl_rec.attribute11;
    l_template_rec.attribute12            := l_tmpl_rec.attribute12;
    l_template_rec.attribute13            := l_tmpl_rec.attribute13;
    l_template_rec.attribute14            := l_tmpl_rec.attribute14;
    l_template_rec.attribute15            := l_tmpl_rec.attribute15;
    l_template_rec.cz_export_wf_key       := l_tmpl_rec.cz_export_wf_key;
    l_template_rec.xprt_clause_mandatory_flag := l_tmpl_rec.xprt_clause_mandatory_flag;
    l_template_rec.xprt_scn_code           := l_tmpl_rec.xprt_scn_code;
    l_template_rec.approval_wf_key         := l_tmpl_rec.approval_wf_key;
--MLS for templates
    l_template_rec.language                := l_tmpl_rec.language;
    l_template_rec.translated_from_tmpl_id := l_tmpl_rec.translated_from_tmpl_id;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: calling OKC_TERMS_COPY_PVT.copy_tc');
    END IF;

    OKC_TERMS_COPY_PVT.copy_tc(
                                  p_api_version            => 1,
                                  p_init_msg_list          => FND_API.G_FALSE,
                                  p_commit                 => FND_API.G_FALSE,
                                  p_source_doc_type        => OKC_TERMS_UTIL_GRP.G_TMPL_DOC_TYPE,
                                  p_source_doc_id          => p_template_id,
                                  p_target_doc_type        => l_document_type,
                                  p_target_doc_id          => x_template_id,
                                  p_keep_version           => 'N',
                                  p_article_effective_date => l_tmpl_rec.start_date,
                                  p_target_template_rec    => l_template_rec,
                                  x_return_status          => x_return_status,
                                  x_msg_data               => x_msg_data,
                                  x_msg_count              => x_msg_count);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: returned from OKC_TERMS_COPY_PVT.copy_tc, return status : '||x_return_status);
   END IF;

   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   ELSIF (x_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR ;
   END IF;
----------------------------------------------
   -- bug#4083525 do not invoke deliverables API for sell side
   -- to be removed when sell side deliverables are enabled.
   IF l_template_rec.intent = 'S' THEN
      l_copy_deliverables := 'N';
   ELSE
      l_copy_deliverables := p_copy_deliverables;
   END IF;

   IF l_copy_deliverables='Y' THEN

        /*  Call Deliverable API to copy Deliverables */

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000:Entering OKC_DELIVERABLE_PROCESS_PVT.CopyDelForTemplateRevision.  ');
       END IF;
    -- bug#4075168 New API for Template Revision replacing copy_deliverables

       OKC_DELIVERABLE_PROCESS_PVT.CopyDelForTemplateRevision(
       p_api_version         => 1,
       p_init_msg_list       => FND_API.G_FALSE,
       p_source_doc_type        => OKC_TERMS_UTIL_GRP.G_TMPL_DOC_TYPE,
       p_source_doc_id          => p_template_id,
       p_target_doc_type        => l_document_type,
       p_target_doc_id          => x_template_id,
       p_target_doc_number     => l_tmpl_rec.template_name,
       p_copy_del_attachments_yn     => 'Y',
       x_msg_data            => x_msg_data,
       x_msg_count           => x_msg_count,
       x_return_status       => x_return_status );


       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1100:Finished OKC_DELIVERABLE_PROCESS_PVT.CopyDelForTemplateRevision');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1100:OKC_DELIVERABLE_PROCESS_PVT.CopyDelForTemplateRevision x_return_status : '||x_return_status);
       END IF;

       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
       RAISE FND_API.G_EXC_ERROR ;
       END IF;

   END IF;--  l_copy_deliverables='Y'

-----------------------------------------------
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

-- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000: Leaving create_template_revision');
   END IF;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN

 IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'800: Leaving create_template_revision: OKC_API.G_EXCEPTION_ERROR Exception');
 END IF;

 IF l_get_tmpl_csr%ISOPEN THEN
    CLOSE l_get_tmpl_csr;
 END IF;

 ROLLBACK TO g_create_template_revision_grp;
 x_return_status := G_RET_STS_ERROR ;
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
 IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'900: Leaving create_template_revision: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
 END IF;

 IF l_get_tmpl_csr%ISOPEN THEN
    CLOSE l_get_tmpl_csr;
 END IF;

 ROLLBACK TO g_create_template_revision_grp;
 x_return_status := G_RET_STS_UNEXP_ERROR ;
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN OTHERS THEN
IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving create_template_revision because of EXCEPTION: '||sqlerrm);
END IF;


 IF l_get_tmpl_csr%ISOPEN THEN
    CLOSE l_get_tmpl_csr;
 END IF;

ROLLBACK TO g_create_template_revision_grp;
x_return_status := G_RET_STS_UNEXP_ERROR ;
IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
END IF;
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
END create_template_revision;

/*
-- To be used while copying a document from archive to make a new document.
-- This functionality is only supported in OM.
*/

Procedure copy_archived_doc   (
                        p_api_version             IN    Number,
                        p_init_msg_list           IN    Varchar2,
                        p_commit                  IN    Varchar2,
                        p_source_doc_type         IN    Varchar2,
                        p_source_doc_id           IN    Number,
                        p_source_version_number   IN    Number,
                        p_target_doc_type         IN    Varchar2,
                        p_target_doc_id           IN    Number,
                        p_document_number         IN    Varchar2,
                        p_allow_duplicate_terms   IN    Varchar2,
                        x_return_status           OUT   NOCOPY Varchar2,
                        x_msg_data                OUT   NOCOPY Varchar2,
                        x_msg_count               OUT   NOCOPY Number
                        ) IS
l_api_version                CONSTANT NUMBER := 1;
l_api_name                   CONSTANT VARCHAR2(30) := 'copy_archived_doc';
BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Entered OKC_TERMS_COPY_GRP.copy_archived_doc');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Parameter List ');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_api_version : '||p_api_version);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_init_msg_list : '||p_init_msg_list);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_commit : '||p_commit);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_source_doc_type : '||p_source_doc_type);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_source_doc_id : '||p_source_doc_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_source_version_number : '||p_source_version_number);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_target_doc_type : '||p_target_doc_type);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_target_doc_id : '||p_target_doc_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_document_number : '||p_document_number);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_allow_duplicate_terms : '||p_allow_duplicate_terms);
    END IF;


    -- Standard Start of API savepoint
    SAVEPOINT g_copy_archived_doc_GRP;

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


    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: calling OKC_TERMS_COPY_PVT.copy_archived_doc');
    END IF;

    OKC_TERMS_COPY_PVT.copy_archived_doc(
                                  p_api_version            => 1,
                                  p_init_msg_list          => FND_API.G_FALSE,
                                  p_commit                 => FND_API.G_FALSE,
                                  p_source_doc_type        => p_source_doc_type,
                                  p_source_doc_id          => p_source_doc_id,
                                  p_target_doc_type        => p_target_doc_type,
                                  p_target_doc_id          => p_target_doc_id,
                                  p_source_version_number  =>p_source_version_number,
                                  p_document_number        => p_document_number,
                                  p_allow_duplicates       => p_allow_duplicate_terms,
                                  x_return_status          => x_return_status,
                                  x_msg_data               => x_msg_data,
                                  x_msg_count              => x_msg_count);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: returned from OKC_TERMS_COPY_PVT.copy_archived_doc return status : '||x_return_status);
   END IF;

   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   ELSIF (x_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

-- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000: Leaving copy_archived_doc');
   END IF;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN

 IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'800: Leaving copy_archived_doc: OKC_API.G_EXCEPTION_ERROR Exception');
 END IF;

 ROLLBACK TO g_copy_archived_doc_grp;
 x_return_status := G_RET_STS_ERROR ;
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
 IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'900: Leaving copy_archived_doc: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
 END IF;

 ROLLBACK TO g_copy_archived_doc_grp;
 x_return_status := G_RET_STS_UNEXP_ERROR ;
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN OTHERS THEN
IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving copy_archived_doc because of EXCEPTION: '||sqlerrm);
END IF;

ROLLBACK TO g_copy_archived_doc_grp;
x_return_status := G_RET_STS_UNEXP_ERROR ;
IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
END IF;
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
END copy_archived_doc;

/*************************************************************
07-APR-2004 pnayani: bug#3524864 added copy_response_doc API              |
This API is used for copying terms, deliverables and document attachments from
one response doc to another. Initially coded to support proxy bidding process in sourcing.
p_source_doc_type               - source document type,
p_source_doc_id             - source document id,
p_target_doc_type               - target document type,
p_target_doc_id             - target document id,
p_target_doc_number             - target document number,
p_keep_version              - passed as 'Y'
                            - 'N' is not supported as this API is called to copy terms from
                            - one doc to another keeping the original reference same as the source
p_article_effective_date    - article effective date,
p_copy_doc_attachments      - flag indicates if doc attachments should be copied, valid values Y/N,
p_allow_duplicate_terms     - flag with valid values Y/N,
p_copy_attachments_by_ref   - flag indicates if document attachments should be
                            - physically copied or referenced, valid values Y/N,

*************************************************************/

Procedure copy_response_doc     (
                        p_api_version             IN    Number,
                        p_init_msg_list           IN    Varchar2 ,
                        p_commit                  IN    Varchar2 ,
                        p_source_doc_type         IN    Varchar2,
                        p_source_doc_id           IN    Number,
                        p_target_doc_type         IN OUT NOCOPY Varchar2,
                        p_target_doc_id           IN OUT NOCOPY Number,
                        p_target_doc_number       IN    Varchar2 ,
                        p_keep_version            IN    Varchar2 ,
                        p_article_effective_date  IN    Date ,
                        p_copy_doc_attachments    IN    Varchar2 ,
                        p_allow_duplicate_terms   IN    Varchar2,
                        p_copy_attachments_by_ref IN    Varchar2,
                        x_return_status           OUT   NOCOPY VARCHAR2,
                        x_msg_data                OUT   NOCOPY VARCHAR2,
                        x_msg_count               OUT   NOCOPY Number
                        )
IS
l_api_version                CONSTANT NUMBER := 1;
l_api_name                   CONSTANT VARCHAR2(30) := 'copy_response_doc';



BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Entered OKC_TERMS_COPY_GRP.copy_response_doc');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Parameter List ');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_api_version : '||p_api_version);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_init_msg_list : '||p_init_msg_list);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_commit : '||p_commit);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_source_doc_type : '||p_source_doc_type);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_source_doc_id : '||p_source_doc_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_target_doc_type : '||p_target_doc_type);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_target_doc_id : '||p_target_doc_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_keep_version : '||p_keep_version);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_article_effective_date : '||p_article_effective_date);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_target_doc_number : '||p_target_doc_number);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_copy_doc_attachments : '||p_copy_doc_attachments);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_allow_duplicate_terms : '||p_allow_duplicate_terms);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_copy_attachments_by_ref : '||p_copy_attachments_by_ref);
    END IF;


    -- Standard Start of API savepoint
    SAVEPOINT g_copy_doc_GRP;

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


    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: calling OKC_TERMS_COPY_PVT.copy_tc');
    END IF;
    -- copy contract terms
    OKC_TERMS_COPY_PVT.copy_tc(
                                  p_api_version            => 1,
                                  p_init_msg_list          => FND_API.G_FALSE,
                                  p_commit                     => FND_API.G_FALSE,
                                  p_source_doc_type        => p_source_doc_type,
                                  p_source_doc_id          => p_source_doc_id ,
                                  p_target_doc_type        => p_target_doc_type,
                                  p_target_doc_id          => p_target_doc_id,
                                  p_keep_version           => 'Y',
                                  p_article_effective_date => p_article_effective_date,
                                  p_target_template_rec    => G_TEMPLATE_MISS_REC,
                                  p_document_number        => p_target_doc_number,
                                  p_allow_duplicates       => p_allow_duplicate_terms,
                                  p_keep_orig_ref          => 'Y',
                                  x_return_status              => x_return_status,
                                  x_msg_data               => x_msg_data,
                                  x_msg_count              => x_msg_count);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Finished OKC_TERMS_COPY_PVT.copy_tc, return status'||x_return_status);
   END IF;

   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   ELSIF (x_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR ;
   END IF;
-----------------------------------------------------


     /*  Call Deliverable API to copy Deliverables */

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000:Entering OKC_DELIVERABLE_PROCESS_PVT.copy_deliverables.');
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000:source  busdoc id: '||to_char(p_source_doc_id));
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000:target busdoc id: '||to_char(p_target_doc_id));
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000:target busdoc type: '||p_target_doc_type);
            END IF;


            OKC_DELIVERABLE_PROCESS_PVT.copy_response_deliverables (
            p_api_version         => 1,
            p_init_msg_list       => FND_API.G_FALSE,
            p_source_doc_id       => p_source_doc_id,
            p_source_doc_type     => p_source_doc_type,
            p_target_doc_id       => p_target_doc_id,
            p_target_doc_type     => p_target_doc_type,
            p_target_doc_number   => p_target_doc_number,
            x_msg_data            => x_msg_data,
            x_msg_count           => x_msg_count,
            x_return_status       => x_return_status );

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1100:Finished OKC_DELIVERABLE_PROCESS_PVT.copy_deliverables  ');
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1100: OKC_DELIVERABLE_PROCESS_PVT.copy_deliverables x_return_status :  '||x_return_status);
            END IF;

            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
            END IF;

-- copy doc attachments if the flag is set to Y
IF p_copy_doc_attachments ='Y' THEN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1150:Entering OKC_CONTRACT_DOCS_GRP.Copy_Attachments  ');
    END IF;

    OKC_CONTRACT_DOCS_GRP.Copy_Attachments (
                          p_api_version  =>1,
                          p_init_msg_list =>FND_API.G_FALSE,
                          x_msg_data            => x_msg_data,
                          x_msg_count           => x_msg_count,
                          x_return_status       => x_return_status,
                          p_from_bus_doc_type => p_source_doc_type ,
                          p_from_bus_doc_id   => p_source_doc_id,
                          p_from_bus_doc_version => -99,
                          p_to_bus_doc_type    => p_target_doc_type,
                          p_to_bus_doc_id     => p_target_doc_id,
                          p_to_bus_doc_version => -99,
                          p_copy_by_ref => p_copy_attachments_by_ref) ;

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1151:Finished OKC_CONTRACT_DOCS_GRP.Copy_Attachments ');
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1151:OKC_CONTRACT_DOCS_GRP.Copy_Attachments x_return_status : '||x_return_status);
       END IF;

       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR ;
       END IF;
  END IF;

-------------------------------------------------------------

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

-- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000: Leaving copy_response_doc');
   END IF;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN

 IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'800: Leaving copy_response_doc: OKC_API.G_EXCEPTION_ERROR Exception');
 END IF;

 ROLLBACK TO g_copy_doc_grp;
 x_return_status := G_RET_STS_ERROR ;
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
 IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'900: Leaving copy_response_doc: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
 END IF;

 ROLLBACK TO g_copy_doc_grp;
 x_return_status := G_RET_STS_UNEXP_ERROR ;
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN OTHERS THEN
IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving copy_response_doc because of EXCEPTION: '||sqlerrm);
END IF;

ROLLBACK TO g_copy_doc_grp;
x_return_status := G_RET_STS_UNEXP_ERROR ;
IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
END IF;
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
END copy_response_doc;



END OKC_TERMS_COPY_GRP;

/
