--------------------------------------------------------
--  DDL for Package Body OKC_TERMS_QA_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TERMS_QA_GRP" AS
/* $Header: OKCGDQAB.pls 120.5.12010000.2 2012/08/23 06:41:09 vechittu ship $ */


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
    G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_TERMS_QA_GRP';
    G_MODULE                     CONSTANT   VARCHAR2(200) := 'okc.plsql.'||G_PKG_NAME||'.';
    G_APP_NAME                   CONSTANT   VARCHAR2(3)   := OKC_API.G_APP_NAME;
    ------------------------------------------------------------------------------
    -- GLOBAL CONSTANTS
    ------------------------------------------------------------------------------
    G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
    G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;

    G_RET_STS_SUCCESS            CONSTANT   varchar2(1) := FND_API.G_RET_STS_SUCCESS;
    G_RET_STS_ERROR              CONSTANT   varchar2(1) := FND_API.G_RET_STS_ERROR;
    G_RET_STS_UNEXP_ERROR        CONSTANT   varchar2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

    G_QA_SUCCESS                 CONSTANT   VARCHAR2(200) := 'OKC_CONTRACTS_QA_SUCCESS';
    G_UNEXPECTED_ERROR           CONSTANT   varchar2(200) := 'OKC_UNEXPECTED_ERROR';
    G_SQLERRM_TOKEN              CONSTANT   varchar2(200) := 'ERROR_MESSAGE';
    G_SQLCODE_TOKEN              CONSTANT   varchar2(200) := 'ERROR_CODE';

    G_QA_LOOKUP                  CONSTANT   VARCHAR2(30)  := 'OKC_TERM_QA_LIST';
    G_TMPL_QA_TYPE               CONSTANT   VARCHAR2(30)  := 'TEMPLATE';
    G_TMPL_DOC_TYPE              CONSTANT   VARCHAR2(30)  := OKC_TERMS_UTIL_GRP.G_TMPL_DOC_TYPE;

    ---------------------------------------------------------------------------
    -- Procedure QA_Doc version 1
    ---------------------------------------------------------------------------
    /* version 1, logs valiation messages in OKC_QA_ERRORS_T table
    returns x_sequence_id as out parameter
    11.5.10+ : Modified to accept addtional in parameter p_validation_level
    */
    PROCEDURE qa_doc     (
        p_api_version       IN  NUMBER ,
        p_init_msg_list     IN  VARCHAR2 ,
        x_return_status     OUT NOCOPY VARCHAR2 ,
        x_msg_data          OUT NOCOPY VARCHAR2 ,
        x_msg_count         OUT NOCOPY NUMBER ,

        p_qa_mode           IN  VARCHAR2 ,
        p_doc_type          IN  VARCHAR2 ,
        p_doc_id            IN  NUMBER ,

        x_sequence_id       OUT NOCOPY NUMBER ,
        x_qa_return_status  OUT NOCOPY VARCHAR2 ,
        p_qa_terms_only     IN VARCHAR2 ,
        p_validation_level  IN VARCHAR2,
        p_commit            IN	VARCHAR2,
        p_run_expert_flag   IN VARCHAR2 DEFAULT 'Y')
    IS

        l_api_version       CONSTANT NUMBER := 1;
        l_api_name          CONSTANT VARCHAR2(30) := 'QA_Doc';
        l_qa_result_tbl     qa_result_tbl_type;
        l_bus_doc_date_events_tbl BUSDOCDATES_TBL_TYPE;
        l_error_found      Boolean := FALSE;
        l_warning_found    Boolean := FALSE;
        l_contract_source  OKC_TEMPLATE_USAGES.CONTRACT_SOURCE_CODE%TYPE;
        l_now              DATE;

        l_qa_code           OKC_QA_ERRORS_T.QA_CODE%TYPE;
        l_severity          OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
        l_desc              OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;
        l_perform_layout_tmpl_qa VARCHAR2(1);
        l_template_id       OKC_TEMPLATE_USAGES.TEMPLATE_ID%TYPE;

      CURSOR l_get_qa_detail_csr IS
       SELECT fnd.lookup_code qa_code,
             fnd.meaning qa_name,
             nvl(qa.severity_flag,G_QA_STS_WARNING) severity_flag ,
             decode(fnd.enabled_flag,'N','N','Y',decode(qa.enable_qa_yn,'N','N','Y'),'Y') perform_qa
        FROM FND_LOOKUPS FND, OKC_DOC_QA_LISTS QA
        WHERE QA.DOCUMENT_TYPE(+)=p_doc_type
        AND   QA.QA_CODE(+) = FND.LOOKUP_CODE
        AND   FND.LOOKUP_CODE = 'CHECK_TERMS_EXIST'
        AND   Fnd.LOOKUP_TYPE=G_QA_LOOKUP;

      CURSOR l_get_template_id IS
       SELECT template_id
        FROM  OKC_TEMPLATE_USAGES
        WHERE document_type = p_doc_type
        AND   document_id = p_doc_id;

    BEGIN
        l_contract_source := 'NONE';
        l_now := SYSDATE;
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Entered QA_Doc');
        END IF;

        -- Standard Start of API savepoint
        SAVEPOINT g_QA_Doc;

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

      IF p_doc_type <> G_TMPL_QA_TYPE THEN

        l_contract_source := OKC_TERMS_UTIL_GRP.Get_Contract_Source_Code(
                                    p_document_type    => p_doc_type,
                                    p_document_id      => p_doc_id
                                    );
          IF (l_contract_source = 'E') THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
          END IF;
	 END IF;

      --Added for 10+ word integration
      IF l_contract_source = 'ATTACHED' THEN
       --------------------------------------------
       -- Contract is in attached document from
       --------------------------------------------
      --Added for 10+ word integration
        OKC_CONTRACT_DOCS_GRP.qa_doc(
            p_api_version      => l_api_version,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data,

            p_doc_type         => p_doc_type,
            p_doc_id           => p_doc_id,

            x_qa_result_tbl    => l_qa_result_tbl,
            x_qa_return_status => x_qa_return_status
            );

        --------------------------------------------
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR ;
        END IF;
        --------------------------------------------

      ELSIF  (l_contract_source = 'STRUCTURED' OR p_doc_type = G_TMPL_QA_TYPE) THEN
       --------------------------------------------
       -- Contract is in structured terms format OR Document is Template
       --------------------------------------------
       IF p_qa_mode='AMEND' THEN
            --------------------------------------------
            -- Calling API to mark any article amended if system variable used in that API has been changed
            --------------------------------------------
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'200: Call API OKC_TERMS_UTIL_GRP.Mark_Variable_Based_Amendment ');
            END IF;

            OKC_TERMS_UTIL_GRP.Mark_Variable_Based_Amendment(
                               p_api_version      =>1,
                               p_init_msg_list    => FND_API.G_FALSE,
                               p_commit           => FND_API.G_TRUE,
                               p_doc_type         => p_doc_type,
                               p_doc_id           => p_doc_id,
                               x_return_status    => x_return_status,
                               x_msg_count        => x_msg_count,
                               x_msg_data         => x_msg_data
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
      -- Call internal QA_Doc and put result into PLSQL table and save it in DB
      --------------------------------------------
       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'200: Call Private QA_Doc and put result into PLSQL table and save it in DB');
       END IF;

       OKC_TERMS_QA_PVT.QA_Doc(
        x_return_status    => x_return_status,

----      p_save             => 'Y',
        p_qa_mode          => p_qa_mode,
        p_doc_type         => p_doc_type,
        p_doc_id           => p_doc_id,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data,

        x_sequence_id      => x_sequence_id,
        x_qa_result_tbl    => l_qa_result_tbl,
        x_qa_return_status => x_qa_return_status,
	   p_run_expert_flag  => p_run_expert_flag
       );
      --------------------------------------------
       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR ;
       END IF;
      --------------------------------------------

    ELSE --l_contract_source = NULL
      --Template has not been applied on the document, no qa needs to be done.
      x_qa_return_status := G_QA_STS_SUCCESS;
      RETURN;
    END IF;


    ----------------------------------------------------------------------
    -- QA Check for Lock Contract - to be run for p_doc_type <> 'TEMPLATE'
    ----------------------------------------------------------------------
    IF p_doc_type<>G_TMPL_DOC_TYPE THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2210: calling check_lock_contract');
	 END IF;
	 OKC_TERMS_QA_PVT.Check_lock_contract(
	 p_qa_mode          => p_qa_mode,
	 p_doc_type         => p_doc_type,
	 p_doc_id           => p_doc_id,
	 x_qa_result_tbl   => l_qa_result_tbl,
	 x_qa_return_status => x_qa_return_status,
	 x_return_status    => x_return_status);

	 IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	 ELSIF (x_return_status = G_RET_STS_ERROR) THEN
	    RAISE FND_API.G_EXC_ERROR ;
	 END IF;
    END IF;

    ----------------------------------------------------------------------
    -- QA Check for Contract Admin - to be run for p_doc_type <> 'TEMPLATE'
    ----------------------------------------------------------------------
    IF p_doc_type<>G_TMPL_DOC_TYPE THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	 FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2210: calling check_contract_admin');
      END IF;
      OKC_TERMS_QA_PVT.check_contract_admin(
       p_qa_mode          => p_qa_mode,
	  p_doc_type         => p_doc_type,
	  p_doc_id           => p_doc_id,
	  x_qa_result_tbl   => l_qa_result_tbl,
	  x_qa_return_status => x_qa_return_status,
	  x_return_status    => x_return_status
	  );
	 IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	 ELSIF (x_return_status = G_RET_STS_ERROR) THEN
	   RAISE FND_API.G_EXC_ERROR ;
	 END IF;
    END IF;


    OPEN l_get_template_id;
    FETCH l_get_template_id INTO l_template_id;
    CLOSE l_get_template_id;
    ------------------------------------------------------------
    -- QA Check for deliverables, if p_qa_terms_only is 'N' and a template is instantiated
    ------------------------------------------------------------

    IF p_qa_terms_only = 'N' AND l_template_id IS NOT NULL THEN


            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'201: Call Private QA_Doc for deilverables and add result into PLSQL table and save it in DB');
            END IF;

            OKC_DELIVERABLE_PROCESS_PVT.validate_deliverable_for_qa (
                p_api_version     => 1,
                p_init_msg_list   => FND_API.G_FALSE,
                p_doc_type        => p_doc_type,
                p_doc_id          => p_doc_id,
                p_mode            => p_qa_mode,
                p_bus_doc_date_events_tbl => l_bus_doc_date_events_tbl,
                p_qa_result_tbl   => l_qa_result_tbl,
                x_msg_data        => x_msg_data,
                x_msg_count       => x_msg_count,
                x_return_status   => x_return_status,
                x_qa_return_status => x_qa_return_status);
            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
            END IF;

        END IF;

        --------------------------------------------
        -- VALIDATIONS are done for Terms and Deliverables.
        -- Now insert into Temp table.
        --------------------------------------------
        -- Save result from PLSQL table into DB table
        --------------------------------------------
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2200: Save result from PLSQL table into DB table');
        END IF;

        x_qa_return_status := G_QA_STS_SUCCESS;

        --Bug fix for bug#3290738
        --After calling the validation APIs we need to find out about the x_qa_return_status
        IF l_qa_result_tbl.COUNT > 0 THEN
            FOR i IN l_qa_result_tbl.FIRST..l_qa_result_tbl.LAST LOOP
                --Bug 3302652 takintoy
                --Populate columns to be updated in okc_qa_errors_t
                l_qa_result_tbl(i).error_record_type_name := okc_util.decode_lookup('OKC_ERROR_RECORD_TYPE',l_qa_result_tbl(i).error_record_type);
                l_qa_result_tbl(i).error_severity_name    := okc_util.decode_lookup('OKC_QA_SEVERITY',l_qa_result_tbl(i).error_severity);

                IF l_qa_result_tbl(i).Error_severity = G_QA_STS_ERROR THEN
                    l_error_found := true;
                END IF;
                IF l_qa_result_tbl(i).Error_severity = G_QA_STS_WARNING THEN
                    l_warning_found := true;
                END IF;

            END LOOP;
            IF l_error_found THEN
                x_qa_return_status := G_QA_STS_ERROR;
            ELSIF l_warning_found THEN
                x_qa_return_status := G_QA_STS_WARNING;
            END IF;
        END IF;



        OKC_TERMS_QA_PVT.log_qa_messages(
            x_return_status    => x_return_status,

            p_qa_result_tbl    => l_qa_result_tbl,
            x_sequence_id      => x_sequence_id
            );
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;

        -- do a commit only if p_commit = 'T' (default value)
        IF FND_API.To_Boolean( p_commit ) THEN
			COMMIT WORK;
		END IF;

        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'300: Leaving QA_Doc');
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO g_QA_Doc;
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'400: Leaving QA_Doc : OKC_API.G_EXCEPTION_ERROR Exception');
            END IF;
            x_return_status := G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO g_QA_Doc;
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'500: Leaving QA_Doc : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
            END IF;
            x_return_status := G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

        WHEN OTHERS THEN
            ROLLBACK TO g_QA_Doc;
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'600: Leaving QA_Doc because of EXCEPTION: '||sqlerrm);
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;
            IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
            END IF;
            FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    END qa_doc;

    ---------------------------------------------------------------------------
    -- Procedure QA_Doc version 2
    ---------------------------------------------------------------------------
    /* version 2, does not log valiation messages in OKC_QA_ERRORS_T table
    returns x_qa_result_tbl as out parameter
    11.5.10+: No modification
    */
    PROCEDURE QA_Doc     (
        p_api_version       IN  NUMBER ,
        p_init_msg_list     IN  VARCHAR2 ,
        x_return_status     OUT NOCOPY VARCHAR2 ,
        x_msg_data          OUT NOCOPY VARCHAR2 ,
        x_msg_count         OUT NOCOPY NUMBER ,

        p_qa_mode           IN  VARCHAR2 ,
        p_doc_type          IN  VARCHAR2 ,
        p_doc_id            IN  NUMBER ,

        x_qa_result_tbl    OUT NOCOPY qa_result_tbl_type,
        x_qa_return_status OUT NOCOPY VARCHAR2,

        p_qa_terms_only    IN VARCHAR2 ,
	   p_run_expert_flag  IN VARCHAR2 DEFAULT 'Y') -- Bug 5186245
    IS

        l_api_version       CONSTANT NUMBER := 1;
        l_api_name          CONSTANT VARCHAR2(30) := 'QA_Doc';
        l_sequence_id      NUMBER;
        l_bus_doc_date_events_tbl BUSDOCDATES_TBL_TYPE;
        l_error_found      Boolean := FALSE;
        l_warning_found    Boolean := FALSE;
        l_contract_source  OKC_TEMPLATE_USAGES.CONTRACT_SOURCE_CODE%TYPE;
        l_template_id       OKC_TEMPLATE_USAGES.TEMPLATE_ID%TYPE;
	l_clm_doc_flag varchar2(1) := 'N';

      CURSOR l_get_template_id IS
       SELECT template_id
        FROM  OKC_TEMPLATE_USAGES
        WHERE document_type = p_doc_type
        AND   document_id = p_doc_id;

    BEGIN
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'700: Entered QA_Doc');
        END IF;

        -- Standard Start of API savepoint
        SAVEPOINT g_QA_Doc;

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

        IF NVL(FND_PROFILE.VALUE('PO_CLM_INSTALLED'),'N') = 'Y' and
          NVL(FND_PROFILE.VALUE('PO_CLM_ENABLED'),'N') = 'Y' THEN
          l_clm_doc_flag := 'Y';
        END IF;

    --Added for 10+ word integration
    IF p_doc_type <> G_TMPL_QA_TYPE THEN
      l_contract_source := OKC_TERMS_UTIL_GRP.Get_Contract_Source_Code(
                                    p_document_type    => p_doc_type,
                                    p_document_id      => p_doc_id
                                    );
      IF (l_contract_source = 'E') THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF;
    END IF;

    IF l_contract_source = 'ATTACHED' THEN
       --------------------------------------------
       -- Contract is in attached document from
       --------------------------------------------
       --Added for 10+ word integration
       OKC_CONTRACT_DOCS_GRP.qa_doc(
            p_api_version      => l_api_version,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data,

            p_doc_type         => p_doc_type,
            p_doc_id           => p_doc_id,

            x_qa_result_tbl    => x_qa_result_tbl,
            x_qa_return_status => x_qa_return_status
            );


      --------------------------------------------
       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR ;
       END IF;
      --------------------------------------------

    ELSIF (l_contract_source = 'STRUCTURED' OR p_doc_type = G_TMPL_QA_TYPE) THEN
       --------------------------------------------
       -- Contract is in structured terms format OR Document is Template
       --------------------------------------------

      IF p_qa_mode='AMEND' THEN
            --------------------------------------------
            -- Calling API to mark any article amended if system variable used in that API has been changed
            --------------------------------------------
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'200: Call API OKC_TERMS_UTIL_GRP.Mark_Variable_Based_Amendment ');
            END IF;

            OKC_TERMS_UTIL_GRP.Mark_Variable_Based_Amendment(
                               p_api_version      =>1,
                               p_init_msg_list    => FND_API.G_FALSE,
                               p_commit           => FND_API.G_TRUE,
                               p_doc_type         => p_doc_type,
                               p_doc_id           => p_doc_id,
                               x_return_status    => x_return_status,
                               x_msg_count        => x_msg_count,
                               x_msg_data         => x_msg_data
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
      -- Call internal QA_Doc and put result into PLSQL table
      --------------------------------------------
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'800: Call Private QA_Doc and put result into PLSQL table');
      END IF;
      OKC_TERMS_QA_PVT.QA_Doc(
        x_return_status    => x_return_status,

----      p_save             => 'N',
        p_qa_mode          => p_qa_mode,
        p_doc_type         => p_doc_type,
        p_doc_id           => p_doc_id,

        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data,
        x_sequence_id      => l_sequence_id,
        x_qa_result_tbl    => x_qa_result_tbl,
        x_qa_return_status => x_qa_return_status,
	   p_run_expert_flag  => p_run_expert_flag
      );
      --------------------------------------------
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;
      --------------------------------------------

    ELSE --l_contract_source = NULL
      --Template has not been applied on the document, no qa needs to be done.
      x_qa_return_status := G_QA_STS_SUCCESS;
      RETURN;
    END IF;


-- Repository Enhancement (For Validate Action)
 IF SubStr(p_doc_type,1,3) <> 'REP' THEN   -- If the Document Type is not Repository Contract'


    ----------------------------------------------------------------------
    -- QA Check for Lock Contract - to be run for p_doc_type <> 'TEMPLATE'
    ----------------------------------------------------------------------
    IF p_doc_type<>G_TMPL_DOC_TYPE THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2210: calling check_lock_contract');
	 END IF;
	 OKC_TERMS_QA_PVT.Check_lock_contract(
	 p_qa_mode          => p_qa_mode,
	 p_doc_type         => p_doc_type,
	 p_doc_id           => p_doc_id,
	 x_qa_result_tbl   =>  x_qa_result_tbl,
	 x_qa_return_status => x_qa_return_status,
	 x_return_status    => x_return_status);

	 IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	 ELSIF (x_return_status = G_RET_STS_ERROR) THEN
	    RAISE FND_API.G_EXC_ERROR ;
	 END IF;
    END IF;

    ----------------------------------------------------------------------
    -- QA Check for Contract Admin - to be run for p_doc_type <> 'TEMPLATE'
    ----------------------------------------------------------------------
    IF p_doc_type<>G_TMPL_DOC_TYPE THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	 FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2210: calling check_contract_admin');
      END IF;

   IF l_clm_doc_flag = 'N' THEN
      OKC_TERMS_QA_PVT.check_contract_admin(
       p_qa_mode          => p_qa_mode,
	  p_doc_type         => p_doc_type,
	  p_doc_id           => p_doc_id,
	  x_qa_result_tbl   => x_qa_result_tbl,
	  x_qa_return_status => x_qa_return_status,
	  x_return_status    => x_return_status
	  );
  END IF;
	 IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	 ELSIF (x_return_status = G_RET_STS_ERROR) THEN
	   RAISE FND_API.G_EXC_ERROR ;
	 END IF;
    END IF;
    OPEN l_get_template_id;
    FETCH l_get_template_id INTO l_template_id;
    CLOSE l_get_template_id;
    ------------------------------------------------------------
    -- QA Check for deliverables, if p_qa_terms_only is 'N' and a template is instantiated
    ------------------------------------------------------------

    IF p_qa_terms_only = 'N' AND l_template_id IS NOT NULL THEN


            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'201: Call Private QA_Doc for deilverables and add result into PLSQL table and save it in DB');
            END IF;

            OKC_DELIVERABLE_PROCESS_PVT.validate_deliverable_for_qa (
                p_api_version     => 1,
                p_init_msg_list   => FND_API.G_FALSE,
                p_doc_type        => p_doc_type,
                p_doc_id          => p_doc_id,
                p_mode            => p_qa_mode,
                p_bus_doc_date_events_tbl => l_bus_doc_date_events_tbl,
                p_qa_result_tbl   => x_qa_result_tbl,
                x_msg_data        => x_msg_data,
                x_msg_count       => x_msg_count,
                x_return_status   => x_return_status,
                x_qa_return_status => x_qa_return_status);
            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
            END IF;

        END IF;

        x_qa_return_status := G_QA_STS_SUCCESS;
        IF x_qa_result_tbl.COUNT > 0 THEN
            FOR i in x_qa_result_tbl.FIRST..x_qa_result_tbl.LAST LOOP

                x_qa_result_tbl(i).error_record_type_name := okc_util.decode_lookup('OKC_ERROR_RECORD_TYPE',x_qa_result_tbl(i).error_record_type);
                x_qa_result_tbl(i).error_severity_name := okc_util.decode_lookup('OKC_QA_SEVERITY',x_qa_result_tbl(i).error_severity);

                IF x_qa_result_tbl(i).Error_severity = G_QA_STS_ERROR THEN
                    l_error_found := true;
                END IF;
                IF x_qa_result_tbl(i).Error_severity = G_QA_STS_WARNING THEN
                    l_warning_found := true;
                END IF;

            END LOOP;
            --fix for bug 3290738
            IF l_error_found THEN
                x_qa_return_status := G_QA_STS_ERROR;
            ELSIF l_warning_found THEN
                x_qa_return_status := G_QA_STS_WARNING;
            END IF;

        END IF;

        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'900: Leaving QA_Doc');
        END IF;
       END IF; -- Repository Enhancement (For Validate Action)


    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO g_QA_Doc;
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1000: Leaving QA_Doc : OKC_API.G_EXCEPTION_ERROR Exception');
            END IF;
            x_return_status := G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO g_QA_Doc;
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1100: Leaving QA_Doc : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
            END IF;
            x_return_status := G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

        WHEN OTHERS THEN
            ROLLBACK TO g_QA_Doc;
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1200: Leaving QA_Doc because of EXCEPTION: '||sqlerrm);
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;
            IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
            END IF;
            FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    END qa_doc;

    ---------------------------------------------------------------------------
    -- Procedure Check_Terms calls QA_doc version 2
    ---------------------------------------------------------------------------
    PROCEDURE Check_Terms(
        x_return_status            OUT NOCOPY VARCHAR2,
        p_chr_id                   IN  NUMBER)
    IS

        l_msg_data            FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;   --Fix for bug# 4019909
        l_msg_count           NUMBER;
        l_api_version       CONSTANT NUMBER := 1;
        l_api_name          CONSTANT VARCHAR2(30) := 'Check_Terms';
        l_qa_result_tbl     qa_result_tbl_type;
        l_doc_type          OKC_BUS_DOC_TYPES_B.DOCUMENT_TYPE%TYPE;
        l_doc_id            NUMBER;
        l_qa_return_status  VARCHAR2(50);

    BEGIN

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'700: Entered '||l_api_name);
        END IF;
        x_return_status := G_RET_STS_SUCCESS;

        OKC_TERMS_UTIL_GRP.Get_Contract_Document_Type_ID(
            p_api_version   => l_api_version,
            x_return_status => x_return_status,
            x_msg_data      => l_msg_data,
            x_msg_count     => l_msg_count,
            p_chr_id        => p_chr_id,
            x_doc_type      => l_doc_type,
            x_doc_id        => l_doc_id
            );
        IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        END IF;

        QA_Doc(
            p_api_version      => l_api_version,
            x_return_status    => x_return_status,
            x_msg_count        => l_msg_count,
            x_msg_data         => l_msg_data,

            p_qa_mode          => G_NORMAL_QA,
            p_doc_type         => l_doc_type,
            p_doc_id           => l_doc_id,

            x_qa_result_tbl    => l_qa_result_tbl,
            x_qa_return_status => l_qa_return_status
            );
        IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        END IF;


        IF l_qa_return_status = G_QA_STS_SUCCESS THEN
            OKC_API.set_message(
                p_app_name      => G_APP_NAME,
                p_msg_name      => G_QA_SUCCESS);
        ELSE
--Bug 4019909 Added following IF condition to prevent PL/SQL numeric error is l_qa_result_tbl is null.
          IF l_qa_result_tbl.COUNT > 0 THEN
            FOR i IN l_qa_result_tbl.first..l_qa_result_tbl.last LOOP
                Okc_Qa_Check_Pvt.pub_qa_msg_tbl(i).data := l_qa_result_tbl(i).Problem_details||Fnd_Global.Newline||l_qa_result_tbl(i).Suggestion;
                Okc_Qa_Check_Pvt.pub_qa_msg_tbl(i).error_status := l_qa_result_tbl(i).Error_severity;
            END LOOP;
          END IF;
        END IF;
        x_return_status := l_qa_return_status;

        -- Standard call to get message count and if count is 1, get message info.
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'500: Leaving '||l_api_name);
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO g_QA_Doc;
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1100: Leaving '||l_api_name||' : G_EXCEPTION_UNEXPECTED_ERROR Exception');
            END IF;
            x_return_status := G_QA_STS_ERROR ;

        WHEN OTHERS THEN
            ROLLBACK TO g_QA_Doc;
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1200: Leaving '||l_api_name||' because of EXCEPTION: '||sqlerrm);
            END IF;

            x_return_status := G_QA_STS_ERROR ;
            IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
            END IF;
    END Check_Terms;

    ---------------------------------------------------------------------------
    -- Procedure QA_Doc version 3 - calls qa_doc version 2
    ---------------------------------------------------------------------------
    /* version 3, does not log valiation messages in OKC_QA_ERRORS_T table
    returns x_qa_result_tbl as out parameter, takes in additional parameter
    p_bus_doc_date_events_tbl
    11.5.10+: No modification
    */
    Procedure QA_Doc     (
        p_api_version       IN  NUMBER ,
        p_init_msg_list     IN  VARCHAR2 ,
        x_return_status     OUT NOCOPY VARCHAR2 ,
        x_msg_data          OUT NOCOPY VARCHAR2 ,
        x_msg_count         OUT NOCOPY NUMBER ,

        p_qa_mode           IN  VARCHAR2 ,
        p_doc_type          IN  VARCHAR2 ,
        p_doc_id            IN  NUMBER ,

        x_qa_result_tbl     OUT NOCOPY qa_result_tbl_type,
        x_qa_return_status  OUT NOCOPY VARCHAR2,

        p_bus_doc_date_events_tbl   IN BUSDOCDATES_TBL_TYPE,
	   p_run_expert_flag   IN VARCHAR2 DEFAULT 'Y')
    IS

        l_api_version       CONSTANT NUMBER := 1;
        l_api_name          CONSTANT VARCHAR2(30) := 'QA_Doc';
        l_qa_result_tbl     qa_result_tbl_type;
        l_error_found      Boolean := FALSE;
        l_warning_found    Boolean := FALSE;

    BEGIN

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Entered QA_Doc - OVERLOADED ONE');
        END IF;

        -- Standard Start of API savepoint
        SAVEPOINT g_QA_Doc;

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
        -- Call internal QA_Doc and put result into PLSQL table
        --------------------------------------------
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'800: Call Private QA_Doc and put result into PLSQL table');
        END IF;

        QA_Doc(
            p_api_version      => l_api_version,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data,

            p_qa_mode          => p_qa_mode,
            p_doc_type         => p_doc_type,
            p_doc_id           => p_doc_id,

            x_qa_result_tbl    => x_qa_result_tbl,
            x_qa_return_status => x_qa_return_status,

            p_qa_terms_only    => 'Y',
		  p_run_expert_flag  => p_run_expert_flag
            );
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'201: Call Private QA_Doc for deilverables and add result into PLSQL table and save it in DB');
        END IF;

        OKC_DELIVERABLE_PROCESS_PVT.validate_deliverable_for_qa (
            p_api_version     => 1,
            p_init_msg_list   => FND_API.G_FALSE,
            p_doc_type        => p_doc_type,
            p_doc_id          => p_doc_id,
            p_mode            => p_qa_mode,
            p_bus_doc_date_events_tbl => p_bus_doc_date_events_tbl,
            p_qa_result_tbl   => x_qa_result_tbl,
            x_msg_data        => x_msg_data,
            x_msg_count       => x_msg_count,
            x_return_status   => x_return_status,
            x_qa_return_status => x_qa_return_status);
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;

        IF x_qa_result_tbl.COUNT > 0 THEN
            FOR i in x_qa_result_tbl.FIRST..x_qa_result_tbl.LAST LOOP

                x_qa_result_tbl(i).error_record_type_name := okc_util.decode_lookup('OKC_ERROR_RECORD_TYPE',x_qa_result_tbl(i).error_record_type);
                x_qa_result_tbl(i).error_severity_name := okc_util.decode_lookup('OKC_QA_SEVERITY',x_qa_result_tbl(i).error_severity);

                IF x_qa_result_tbl(i).Error_severity = G_QA_STS_ERROR THEN
                    l_error_found := true;
                END IF;
                IF x_qa_result_tbl(i).Error_severity = G_QA_STS_WARNING THEN
                    l_warning_found := true;
                END IF;

            END LOOP;

            --fix for bug 3290738
            IF l_error_found THEN
                x_qa_return_status := G_QA_STS_ERROR;
            ELSIF l_warning_found THEN
                x_qa_return_status := G_QA_STS_WARNING;
            END IF;
        END IF;

        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'300: Leaving QA_Doc - OVERLOADED ONE ');
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO g_QA_Doc;
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'400: Leaving QA_Doc : OKC_API.G_EXCEPTION_ERROR Exception');
            END IF;
            x_return_status := G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO g_QA_Doc;
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'500: Leaving QA_Doc : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
            END IF;
            x_return_status := G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

        WHEN OTHERS THEN
            ROLLBACK TO g_QA_Doc;
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'600: Leaving QA_Doc because of EXCEPTION: '||sqlerrm);
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;
            IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
            END IF;
            FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    END QA_Doc;


END OKC_TERMS_QA_GRP;

/
