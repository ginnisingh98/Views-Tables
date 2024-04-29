--------------------------------------------------------
--  DDL for Package Body OKC_TERMS_TMPL_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TERMS_TMPL_APPROVAL_PVT" as
/* $Header: OKCVTMPLAPPB.pls 120.6.12010000.5 2013/02/06 08:13:28 skavutha ship $ */

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
    -- GLOBAL VARIABLES
    ---------------------------------------------------------------------------
    G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_TERMS_TMPL_APPROVAL_PVT';
    G_APP_NAME                   CONSTANT   VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

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
    G_TEMPLATE_MISS_REC          OKC_TERMS_TEMPLATES_PVT.template_rec_type;

    G_OKC_MSG_INVALID_ARGUMENT  CONSTANT    VARCHAR2(200) := 'OKC_INVALID_ARGUMENT';
    -- ARG_NAME ARG_VALUE is invalid.

    G_DBG_LEVEL							    NUMBER 	    := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    G_PROC_LEVEL							NUMBER		:= FND_LOG.LEVEL_PROCEDURE;
    G_EXCP_LEVEL							NUMBER		:= FND_LOG.LEVEL_EXCEPTION;


    l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

    CURSOR tmpl_csr(cp_template_id IN NUMBER, cp_object_version_number IN NUMBER) IS
        SELECT  okc_template_wf_keys_s1.NEXTVAL WF_SEQUENCE,
            tmpl.template_id,
            tmpl.template_name,
            tmpl.description,
            tmpl.status_code,
            tmpl.object_version_number,
            tmpl.org_id,
            tmpl.intent,
            tmpl.working_copy_flag,
            tmpl.print_template_id,
            tmpl.contract_expert_enabled,
	    fnd_lang.description language_desc
        FROM    okc_terms_templates_all tmpl,
	        fnd_languages_vl fnd_lang
        WHERE tmpl.template_id = cp_template_id
            AND ( tmpl.object_version_number = cp_object_version_number
                OR cp_object_version_number IS NULL)
            AND tmpl.language = fnd_lang.language_code(+)
            FOR UPDATE OF
            tmpl.status_code,
            tmpl.object_version_number,
            tmpl.last_update_date,
            tmpl.last_updated_by
        NOWAIT;

    l_tmpl_rec  tmpl_csr%ROWTYPE;

    ---------------------------------------------------------------------------
    -- Procedure set_wf_error_context
    ---------------------------------------------------------------------------
    /* Proceedure loops through the FND_MSG_PUB stack and sets the
    workflow error context to give as much information as possible to wf engine
    in case an api fails
    */
    PROCEDURE set_wf_error_context(
        p_pkg_name      IN VARCHAR2,
        p_api_name      IN VARCHAR2,
        p_itemtype      IN VARCHAR2 DEFAULT NULL,
        p_itemkey       IN VARCHAR2 DEFAULT NULL,
        p_actid         IN  NUMBER DEFAULT NULL,
        p_funcmode      IN VARCHAR2 DEFAULT NULL,
        p_msg_count     IN NUMBER)
    IS

        TYPE l_arg_tbl_type     IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
        l_arg_tbl               l_arg_tbl_type;

        l_err_msg               VARCHAR2(2000);

    BEGIN

        l_arg_tbl(0) := null;
        l_arg_tbl(1) := null;
        l_arg_tbl(2) := null;
        l_arg_tbl(3) := null;
        l_arg_tbl(4) := null;

        l_arg_tbl(0) := substrb('ItemType='||p_itemtype||' ItemKey='||p_itemkey||' actid='||p_actid||
            ' funcmode='||p_funcmode,1,2000);

        FOR k in 1..p_msg_count LOOP
            EXIT WHEN k >= 4;
            l_arg_tbl(k) := substrb(FND_MSG_PUB.get(p_msg_index => k,p_encoded   => 'F'), 1, 2000);
        END LOOP;

        WF_CORE.CONTEXT(p_pkg_name, p_api_name,
            l_arg_tbl(0), l_arg_tbl(1), l_arg_tbl(2),l_arg_tbl(3),l_arg_tbl(4));

    EXCEPTION

        WHEN OTHERS THEN
            l_err_msg := substrb('SQLCODE='||SQLCODE||' SQLERRM='||SQLERRM,1,2000);
            WF_CORE.CONTEXT(G_PKG_NAME, 'set_wf_error_context',
             'p_pkg_name='||p_pkg_name||' p_api_name='||p_api_name,
             'p_itemtype='||p_itemtype||' p_itemkey='||p_itemkey,
             'p_actid='||p_actid||' p_funcmode='||p_funcmode,
             'p_msg_count='||p_msg_count,
             l_err_msg);
    END;


    ---------------------------------------------------------------------------
    -- Procedure selector
    ---------------------------------------------------------------------------
    --
    -- Procedure
    --    selector
    --
    -- Description
    --      Determine which process to run
    -- IN
    --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
    --   itemkey   - A string generated from the application object's primary key.
    --   actid     - The function activity(instance id).
    --   funcmode  - Run/Cancel/Timeout
    -- OUT
    --   resultout - Name of workflow process to run
    --
    PROCEDURE selector  (
        itemtype    in varchar2,
        itemkey      in varchar2,
        actid        in number,
        funcmode    in varchar2,
        resultout    out nocopy varchar2    )
    IS
    l_user_id      NUMBER;
    l_resp_id      NUMBER;
    l_resp_appl_id NUMBER;

    CURSOR get_resp_id_csr IS
    SELECT responsibility_id
    FROM fnd_responsibility
    WHERE responsibility_key = 'OKC_TERMS_LIBRARY_ADMIN'
    AND application_id = 510;

    BEGIN

       /*6329229, 7605085*/
        l_user_id := FND_GLOBAL.user_id;
        --l_resp_id := 24286;

        OPEN 	get_resp_id_csr;
        FETCH   get_resp_id_csr INTO l_resp_id;
        CLOSE   get_resp_id_csr;

        l_resp_appl_id := 510;


        -- RUN mode - normal process execution
        IF (funcmode = 'RUN') THEN
            -- Return process to run
            resultout := 'TMPL_APPROVAL';
            RETURN;
	/*Bug 6329229*/
 	 ELSIF (funcmode = 'SET_CTX') THEN

 -- wf_seq_id     := wf_engine.getItemAttrNumber(itemtype, itemkey, 'TMPL_WF_SEQ_ID', false);


               -- Set the database session context
        fnd_global.apps_initialize(l_user_id,l_resp_id, l_resp_appl_id);

	RETURN;

        END IF;

        -- CANCEL mode - activity 'compensation'
        IF (funcmode = 'CANCEL') THEN
            -- Return process to run
            resultout := 'TMPL_APPROVAL';
            RETURN;
        END IF;

        -- TIMEOUT mode
        IF (funcmode = 'TIMEOUT') THEN
            resultout := 'TMPL_APPROVAL';
            RETURN;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            IF (get_resp_id_csr%ISOPEN) THEN
            CLOSE get_resp_id_csr;
            END IF;
            WF_CORE.context('OKC_TERMS_TMPL_APPROVAL_PVT','Selector',itemtype,itemkey,actid,funcmode);
            RAISE;
    END selector;

    ---------------------------------------------------------------------------
    -- Procedure lock_row
    ---------------------------------------------------------------------------
    FUNCTION lock_row(
        p_template_id             IN NUMBER,
        p_object_version_number   IN NUMBER
    ) RETURN VARCHAR2
    IS

        E_Resource_Busy               EXCEPTION;
        PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);

        CURSOR  lchk_csr (cp_template_id NUMBER) IS
            SELECT object_version_number
            FROM OKC_TERMS_TEMPLATES_ALL
            WHERE TEMPLATE_ID = cp_template_id;

        l_return_status                VARCHAR2(1);
        l_object_version_number       OKC_TERMS_TEMPLATES_ALL.OBJECT_VERSION_NUMBER%TYPE;
        l_row_notfound                BOOLEAN := FALSE;

    BEGIN

        /*IF (l_debug = 'Y') THEN
            Okc_Debug.Log('4900: Entered Lock_Row', 2);
        END IF;*/

	IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
	    FND_LOG.STRING(G_PROC_LEVEL,
	        G_PKG_NAME, '4900: Entered Lock_Row' );
	END IF;


        BEGIN -- begin inner block

            OPEN tmpl_csr( p_template_id, p_object_version_number );
            FETCH tmpl_csr INTO l_tmpl_rec;
            l_row_notfound := tmpl_csr%NOTFOUND;
            CLOSE tmpl_csr;

        EXCEPTION
            WHEN E_Resource_Busy THEN

                /*IF (l_debug = 'Y') THEN
                    Okc_Debug.Log('5000: Leaving Lock_Row:E_Resource_Busy Exception', 2);
                END IF;*/

		IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	 	   FND_LOG.STRING(G_EXCP_LEVEL,
	  	       G_PKG_NAME, '5000: Leaving Lock_Row:E_Resource_Busy Exception' );
		END IF;

                IF (tmpl_csr%ISOPEN) THEN
                    CLOSE tmpl_csr;
                END IF;

                Okc_Api.Set_Message(G_FND_APP,G_UNABLE_TO_RESERVE_REC);
                RETURN( G_RET_STS_ERROR );
        END; -- end inner block

        IF ( l_row_notfound ) THEN

            l_return_status := G_RET_STS_ERROR;

            OPEN lchk_csr(p_template_id);
            FETCH lchk_csr INTO l_object_version_number;
            l_row_notfound := lchk_csr%NOTFOUND;
            CLOSE lchk_csr;

            IF (l_row_notfound) THEN
                Okc_Api.Set_Message(G_FND_APP,G_RECORD_DELETED);
            ELSIF l_object_version_number > p_object_version_number THEN
                Okc_Api.Set_Message(G_FND_APP,G_RECORD_CHANGED);
            ELSIF l_object_version_number = -1 THEN
                Okc_Api.Set_Message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
            ELSE -- it can be the only above condition. It can happen after restore version
                Okc_Api.Set_Message(G_FND_APP,G_RECORD_CHANGED);
            END IF;
        ELSE
            l_return_status := G_RET_STS_SUCCESS;
        END IF;

        /*IF (l_debug = 'Y') THEN
            Okc_Debug.Log('5100: Leaving Lock_Row', 2);
        END IF;*/

	IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
 	   FND_LOG.STRING(G_PROC_LEVEL,
   	       G_PKG_NAME, '5100: Leaving Lock_Row' );
	END IF;

        RETURN( l_return_status );

    EXCEPTION

        WHEN OTHERS THEN
            IF (tmpl_csr%ISOPEN) THEN
                CLOSE tmpl_csr;
            END IF;
            IF (lchk_csr%ISOPEN) THEN
                CLOSE lchk_csr;
            END IF;

            /*IF (l_debug = 'Y') THEN
                Okc_Debug.Log('5200: Leaving Lock_Row because of EXCEPTION: '||sqlerrm, 2);
            END IF;*/

	    IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
 	       FND_LOG.STRING(G_EXCP_LEVEL,
   	           G_PKG_NAME, '5200: Leaving Lock_Row because of EXCEPTION: '||sqlerrm );
            END IF;

            Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                p_msg_name     => G_UNEXPECTED_ERROR,
                p_token1       => G_SQLCODE_TOKEN,
                p_token1_value => sqlcode,
                p_token2       => G_SQLERRM_TOKEN,
                p_token2_value => sqlerrm);
            RETURN( G_RET_STS_UNEXP_ERROR );
    END lock_row;


    ---------------------------------------------------------------------------
    -- Procedure start_approval
    ---------------------------------------------------------------------------
    /* added 2 new IN params and 1 out param
        p_validation_level  : 'A' or 'E' do all checks or checks with severity = E
        p_check_for_drafts  : 'Y' or 'N' if Y checks for drafts and inserts them
                              in the OKC_TMPL_DRAFT_CLAUSES table
        x_sequence_id       : contains the sequence id for table OKC_QA_ERRORS_T
                               that contains the validation results, is null if
                               no qa errors or warnings are found.

        Existing out param  x_qa_return_status will change to
        have the following statues
        x_qa_return_status  : S if the template was succesfully submitted
                              W if qa check resulted in warnings. Use x_sequence_id
                                to display the qa results.
                              E if qa check resulted in errors. Use x_sequence_id
                                to display the qa results
                              D if there are draft articles and the user should be
                                redirected to the new submit page. Use x_sequence_id
                                if not null, to display a warnings link on the
                                 new submit page.

                                p_validation_level      p_check_for_drafts
        Search/View/Update  :   A                       Y
        New Submit Page     :   A                       N
        Validation Page     :   E                       N

    */

    PROCEDURE start_approval     (
        p_api_version                IN    Number,
        p_init_msg_list                IN    Varchar2 default FND_API.G_FALSE,
        p_commit                    IN    Varchar2 default FND_API.G_FALSE,
        p_template_id                IN    Number,
        p_object_version_number        IN    Number default NULL,
        x_return_status                OUT    NOCOPY Varchar2,
        x_msg_data                    OUT    NOCOPY Varchar2,
        x_msg_count                    OUT    NOCOPY Number,
        x_qa_return_status            OUT    NOCOPY Varchar2,
        p_validation_level            IN VARCHAR2 DEFAULT 'A',
        p_check_for_drafts          IN VARCHAR2 DEFAULT 'N',
        x_sequence_id                OUT NOCOPY NUMBER
        )
    IS

        l_api_version                CONSTANT NUMBER := 2;
        --l_api_version                CONSTANT NUMBER := 1;
        l_api_name                    CONSTANT VARCHAR2(30) := 'start_approval';
        l_ItemType                    varchar2(30) := 'OKCTPAPP';
        l_ItemKey                    varchar2(240);
        l_Attach_key                varchar2(250);
        --Bug 3374952  l_ItemUserKey        varchar2(80);
        l_ItemUserKey                varchar2(300);
        l_WorkFlowProcess            varchar2(80);
        l_org_name                    varchar2(2000);
        l_processowner                varchar2(80);
        l_dummy_var                    varchar2(1);
        l_seq_id                    NUMBER;
        --l_qa_return_status        varchar2(250);
        l_qa_result_tbl                OKC_TERMS_QA_GRP.QA_RESULT_TBL_TYPE;
        l_deliverables_exist        VARCHAR2(100);

        l_tmpl_org_id               NUMBER;
        l_drafts_present            VARCHAR2(1) := 'N';
        l_art_validation_results    OKC_ART_BLK_PVT.validation_tbl_type;
        l_expert_enabled            VARCHAR2(1) := 'N';

        --modify cursor to fetch org_id also
        CURSOR tmpl_exists_csr IS
            SELECT org_id
            --    SELECT '!'
            FROM okc_terms_templates_all
            WHERE template_id = p_template_id;

        CURSOR article_exists_cur IS
            SELECT 1
            FROM OKC_K_ARTICLES_B
            WHERE document_id = p_template_id
                AND document_type = 'TEMPLATE';

        CURSOR org_name_csr(pc_org_id NUMBER) IS
            SELECT name
            FROM hr_operating_units
            WHERE organization_id = pc_org_id;

    BEGIN

        /*IF (l_debug = 'Y') THEN
            okc_debug.log('100: Entered OKC_TERMS_TMPL_APPROVAL_PVT.start_approval', 2);
        END IF;*/

	IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
 	   FND_LOG.STRING(G_PROC_LEVEL,
  	       G_PKG_NAME, '100: Entered OKC_TERMS_TMPL_APPROVAL_PVT.start_approval' );
	END IF;

        -- Standard Start of API savepoint
        SAVEPOINT g_start_approval_PVT;

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


        /*IF (l_debug = 'Y') THEN
            okc_debug.log('600: opening tmpl_exits_csr', 2);
        END IF;*/

	IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
 	   FND_LOG.STRING(G_PROC_LEVEL,
  	       G_PKG_NAME, '600: opening tmpl_exits_csr' );
	END IF;

        OPEN tmpl_exists_csr;
        FETCH tmpl_exists_csr INTO l_tmpl_org_id;
        --    FETCH tmpl_exists_csr INTO l_dummy_var;
        IF tmpl_exists_csr%NOTFOUND THEN
            /*IF (l_debug = 'Y') THEN
                Okc_Debug.Log('2300: - attribute TEMPLATE_ID is invalid', 2);
            END IF;*/

	    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
 	       FND_LOG.STRING(G_PROC_LEVEL,
  	           G_PKG_NAME, '2300: - attribute TEMPLATE_ID is invalid' );
    	    END IF;
            Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TEMPLATE_ID');
            x_return_status := G_RET_STS_ERROR;
        END IF;
        CLOSE tmpl_exists_csr;
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        x_return_status := Lock_Row(
            p_template_id             => p_template_id,
            p_object_version_number   => p_object_version_number );

        IF l_tmpl_rec.status_code NOT IN ('DRAFT','REJECTED','REVISION') THEN
            /*IF (l_debug = 'Y') THEN
                Okc_Debug.Log('2310: - Status not in DRAFT/REJECTED', 2);
            END IF;*/

	    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
 	       FND_LOG.STRING(G_PROC_LEVEL,
  	           G_PKG_NAME, '2310: - Status not in DRAFT/REJECTED' );
    	    END IF;

            Okc_Api.Set_Message(G_APP_NAME, 'OKC_TMPL_APP_INVALID_STATUS','STATUS',okc_util.decode_lookup('OKC_TERMS_TMPL_STATUS',l_tmpl_rec.status_code));
            x_return_status := G_RET_STS_ERROR;
        END IF;
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- 11.5.10+ changes
        -- Insert records in OKC_TMPL_DRAFT_CLAUSES if p_check_for_drafts = Y
        IF (p_check_for_drafts = 'Y') THEN

            OKC_TERMS_UTIL_PVT.create_tmpl_clauses_to_submit  (
                p_api_version                  => 1,
                p_init_msg_list                => FND_API.G_FALSE,
                p_template_id                  => p_template_id,
                p_org_id                       => l_tmpl_org_id,
                x_drafts_present               => l_drafts_present,
                x_return_status                => x_return_status,
                x_msg_count                    => x_msg_count,
                x_msg_data                     => x_msg_data);
            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;


        l_deliverables_exist :=  okc_terms_util_grp.Is_Deliverable_Exist(
            p_api_version      => 1,
            p_init_msg_list    =>  FND_API.G_FALSE,
            x_return_status    => x_return_status,
            x_msg_data         => x_msg_data,
            x_msg_count        => x_msg_count,
            p_doc_type         => 'TEMPLATE',
            p_doc_id           => p_template_id
            );
        l_deliverables_exist := UPPER(nvl(l_deliverables_exist,'NONE'));

        --IF (nvl(l_tmpl_rec.contract_expert_enabled,'N') = 'N' AND
        -- l_deliverables_exist =  'NONE') THEN

        IF (l_deliverables_exist =  'NONE'
            AND NVL(l_tmpl_rec.contract_expert_enabled,'N') = 'N') THEN

            OPEN article_exists_cur;
            FETCH article_exists_cur INTO l_dummy_var;
            IF article_exists_cur%NOTFOUND THEN
                IF (l_tmpl_rec.intent = 'S') THEN
                    -- Added new message for sell side template for bug 3699018
                    Okc_Api.Set_Message(G_APP_NAME, 'OKC_TMPL_APP_NO_ARTICLE_SELL');
                ELSE
                    Okc_Api.Set_Message(G_APP_NAME, 'OKC_TMPL_APP_NO_ARTICLE');
                END IF;
                x_return_status := G_RET_STS_ERROR;
            END IF;
            CLOSE article_exists_cur;

        END IF;

        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        x_qa_return_status := 'S';
        OKC_TERMS_QA_GRP.QA_Doc     (
            p_api_version       => 1,
            p_init_msg_list     => FND_API.G_FALSE,
            p_commit			=> FND_API.G_FALSE,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,

            p_qa_mode           => 'NORMAL',
            p_doc_type          => 'TEMPLATE',
            p_doc_id            => p_template_id,

            x_sequence_id       => x_sequence_id,
            x_qa_return_status  => x_qa_return_status,
            p_validation_level  => p_validation_level);

        /* obsolete for 11.5.10+
        IF x_qa_return_status = 'E' THEN
            --IF (l_debug = 'Y') THEN
            --    Okc_Debug.Log('2320: - Errors found in Template QA', 2);
            --END IF;

	    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
 	       FND_LOG.STRING(G_PROC_LEVEL,
  	           G_PKG_NAME, '2320: - Errors found in Template QA' );
    	    END IF;
            Okc_Api.Set_Message(G_APP_NAME, 'OKC_TMPL_APP_QA_ERROR');
            x_return_status := G_RET_STS_ERROR;
        END IF;
        */
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- 11.5.10+ changes
        -- check for various conditions to see if we need proceed further

        -- set x_sequence_id to null if there are no errors or warnings
        IF (x_qa_return_status = 'S') THEN
            x_sequence_id := NULL;
        END IF;

        IF (x_qa_return_status = 'E') THEN
            -- exit immediately, no further processing
            RETURN;
        ELSE
            IF (l_drafts_present = 'Y') THEN
                x_qa_return_status := 'D';
                -- exit immediately as the user has to first
                -- select/unselect draft articles
                RETURN;
            ELSE
                -- no errors and no drafts, x_qa_return_status = S or W
                IF (x_qa_return_status = 'W') THEN

                    -- validation level = A, and we get warnings we stop
                    IF (p_validation_level = 'A') THEN
                        -- exit immediately as the user has to be shown the warnings
                        RETURN;
                    -- validation level = E, so with warnings we are ok
                    ELSE
                        x_qa_return_status := 'S';
                    END IF;
                ELSE
                   -- no warnings or error, so continue
                   NULL;
                END IF; -- of IF/ELSE (x_qa_return_status = 'W')

            END IF; -- of IF/ELSE (l_drafts_present = 'Y')
        END IF;    -- of IF/ELSE (x_qa_return_status = 'E')

        -- call change_clause_status to update all draft articles to pending approval
        -- if no draft articles are there, this will do nothing


         -- check wether the template is expert enabled or not
        l_expert_enabled := OKC_XPRT_UTIL_PVT. xprt_enabled_template(p_template_id);


        change_clause_status     (
            p_api_version                => 1,
            p_init_msg_list                => FND_API.G_FALSE,
            p_commit                    => FND_API.G_FALSE,

            x_return_status                => x_return_status,
            x_msg_data                    => x_msg_data,
            x_msg_count                    => x_msg_count,

            p_template_id               => p_template_id,
            p_wf_seq_id                 => NULL, -- we do not have this here
            p_status                    => 'PENDING_APPROVAL',

            -- the call to OKC_TERMS_QA_GRP.QA_Doc will ensure that
            -- all article validation has been done
            p_validation_level          => FND_API.G_VALID_LEVEL_NONE,
            x_validation_results        => l_art_validation_results);

        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            -- get the validation results as a simple string
            -- and  add to fnd message stack
            FND_MSG_PUB.add_exc_msg(G_PKG_NAME, 'change_clause_status', get_error_string(l_art_validation_results));
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        UPDATE okc_terms_templates_all
            SET status_code = 'PENDING_APPROVAL',
                object_version_number = object_version_number + 1,
                last_update_date = sysdate,
                last_updated_by = fnd_global.user_id
            WHERE template_id = p_template_id;

        l_processOwner := fnd_global.user_name;

        --Bug 3570042
        --    l_itemkey :=   substr(l_tmpl_rec.template_name,1,150)||':'||l_tmpl_rec.org_id||':'||l_tmpl_rec.wf_sequence;
        --    l_ItemUserKey := l_ItemKey;

        l_itemkey := l_tmpl_rec.template_id||l_tmpl_rec.wf_sequence;
        l_ItemUserKey :=
            substrb(rpad(substr(l_tmpl_rec.template_name,1,130)||':'||l_tmpl_rec.org_id||':'
            ||l_tmpl_rec.wf_sequence,(round(length(substr(l_tmpl_rec.template_name,1,160)||':'
            ||l_tmpl_rec.org_id||':'||l_tmpl_rec.wf_sequence)/8)+1)*8,'0'),1,160);

        l_ItemType := 'OKCTPAPP';
        l_WorkflowProcess := 'TMPL_APPROVAL';

        --
        -- Start Process :
        --  If workflowprocess is passed, it will be run.
        --  If workflowprocess is NOT passed, the selector function
        --  defined in the item type will determine which process to run.
        --
        wf_engine.CreateProcess( ItemType => l_ItemType,
            ItemKey  => l_ItemKey,
            process  => l_WorkflowProcess );

        wf_engine.SetItemUserKey (     ItemType    => l_ItemType,
            ItemKey        => l_ItemKey,
            UserKey        => l_ItemUserKey);
        --
        --
        -- Initialize workflow item attributes
        --
        wf_engine.SetItemAttrText (     itemtype => l_itemtype,
            itemkey  => l_itemkey,
            aname      => 'TEMPLATE_NAME',
            avalue     =>  l_tmpl_rec.template_name);
        --
        wf_engine.SetItemAttrText (     itemtype => l_itemtype,
            itemkey  => l_itemkey,
            aname      => 'TEMPLATE_DESCRIPTION',
            avalue     =>  l_tmpl_rec.description);

        wf_engine.SetItemAttrText (     itemtype => l_itemtype,
            itemkey  => l_itemkey,
            aname      => 'SUBMITTED_BY_USER',
            avalue     => l_ProcessOwner);

        wf_engine.SetItemAttrNumber (     itemtype => l_itemtype,
            itemkey  => l_itemkey,
            aname      => 'TEMPLATE_ID',
            avalue     =>  l_tmpl_rec.template_id);


        wf_engine.SetItemAttrNumber (     itemtype => l_itemtype,
            itemkey  => l_itemkey,
            aname      => 'PRINT_TEMPLATE_ID',
            avalue     =>  l_tmpl_rec.print_template_id);

        wf_engine.SetItemAttrNumber (     itemtype => l_itemtype,
            itemkey  => l_itemkey,
            aname      => 'ORG_ID',
            avalue     =>  l_tmpl_rec.org_id);

        wf_engine.SetItemAttrText (     itemtype => l_itemtype,
            itemkey  => l_itemkey,
            aname      => 'STATUS_CODE',
            avalue     =>  l_tmpl_rec.status_code);

        wf_engine.SetItemAttrText (     itemtype => l_itemtype,
            itemkey  => l_itemkey,
            aname      => 'TMPL_INTENT',
            avalue     =>  okc_util.decode_lookup('OKC_TERMS_INTENT',l_tmpl_rec.intent) );

        wf_engine.SetItemAttrText (     itemtype => l_itemtype,
            itemkey  => l_itemkey,
            aname      => 'TMPL_WORKINGCOPY',
            avalue     =>  NVL(l_tmpl_rec.working_copy_flag,'N'));

        wf_engine.SetItemAttrNumber (     itemtype => l_itemtype,
            itemkey  => l_itemkey,
            aname      => 'TMPL_WF_SEQ_ID',
            avalue     =>  l_tmpl_rec.wf_sequence);

        OPEN org_name_csr(l_tmpl_rec.org_id);
        FETCH org_name_csr INTO l_org_name;
        CLOSE org_name_csr;

        wf_engine.SetItemAttrText (     itemtype => l_itemtype,
            itemkey  => l_itemkey,
            aname      => 'ORG_NAME',
            avalue     =>  l_org_name);

        --l_attach_key := 'FND:entity=OKC_TERMS_TEMPLATES'||fnd_global.local_chr(38)||'pk1name=TEMPLATE_ID'
        --                 ||fnd_global.local_chr(38)||'pk1value='||l_tmpl_rec.template_id||fnd_global.local_chr(38)
        --                 ||'pk2name=WF_SEQUENCE_ID'||fnd_global.local_chr(38)||'pk2value='||l_tmpl_rec.wf_sequence ;

        l_attach_key := 'FND:entity=OKC_TERMS_TEMPLATES'||'&pk1name=TEMPLATE_ID&pk1value='||
        l_tmpl_rec.template_id||'&pk2name=WF_SEQUENCE_ID&pk2value='||l_tmpl_rec.wf_sequence ;


        wf_engine.SetItemAttrText (     itemtype => l_itemtype,
            itemkey  => l_itemkey,
            aname      => 'TMPL_ATTACHMENT',
            avalue     =>  l_attach_key);

        --wf_directory.GetRoleDisplayName(RequestorUsername) );

        wf_engine.SetItemAttrText(     itemtype => l_itemtype,
            itemkey  => l_itemkey,
            aname      => 'MONITOR_URL',
            avalue     =>
            wf_monitor.GetUrl(wf_core.translate('WF_WEB_AGENT')
            ,l_itemtype,l_itemkey,'NO'));

        -- set new attribute expert enabled
        -- TODO call expert function to set l_expert_enabled
        wf_engine.SetItemAttrText (     itemtype => l_itemtype,
            itemkey  => l_itemkey,
            aname      => 'TMPL_EXPERT_ENABLED',
            avalue     =>  l_expert_enabled);

        wf_engine.SetItemOwner (    itemtype => l_itemtype,
            itemkey     => l_itemkey,
            owner     => l_ProcessOwner );

        -- 11.5.10+ changes
        -- update     okc_tmpl_draft_clauses with the wf_seq_id
        UPDATE OKC_TMPL_DRAFT_CLAUSES
        SET WF_SEQ_ID = l_tmpl_rec.wf_sequence
            WHERE template_id = p_template_id
            AND nvl(selected_yn, 'N') = 'Y';

        -- delete all clauses with selectedYn= N, they are not required any more.
        DELETE OKC_TMPL_DRAFT_CLAUSES
            WHERE TEMPLATE_ID = p_template_id
            AND nvl(selected_yn, 'N') = 'N';

        -- end of 11.5.10+ changes
--MLS for templates
        wf_engine.SetItemAttrText (     itemtype => l_itemtype,
            itemkey  => l_itemkey,
            aname      => 'TEMPLATE_LANGUAGE',
            avalue     =>  l_tmpl_rec.language_desc);


        -- need to ensure that call to wf start_process is the last to be called
        -- becuase once invoked, it stops only if a blocking activity is reached.
        wf_engine.StartProcess(     itemtype => l_itemtype,
            itemkey     => l_itemkey );

        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

        /*IF (l_debug = 'Y') THEN
            okc_debug.log('1000: Leaving start_approval', 2);
        END IF;*/

	IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
 	   FND_LOG.STRING(G_PROC_LEVEL,
  	       G_PKG_NAME, '1000: Leaving start_approval' );
	END IF;

    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            /*IF (l_debug = 'Y') THEN
                okc_debug.log('800: Leaving start_approval: OKC_API.G_EXCEPTION_ERROR Exception', 2);
            END IF;*/

	    IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	        FND_LOG.STRING(G_EXCP_LEVEL,
	            G_PKG_NAME, '800: Leaving start_approval: OKC_API.G_EXCEPTION_ERROR Exception' );
	    END IF;

            ROLLBACK TO g_start_approval_pvt;
            x_return_status := G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            /*IF (l_debug = 'Y') THEN
                okc_debug.log('900: Leaving start_approval: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
            END IF;*/

	    IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	        FND_LOG.STRING(G_EXCP_LEVEL,
	            G_PKG_NAME, '900: Leaving start_approval: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception' );
	    END IF;

            ROLLBACK TO g_start_approval_pvt;
            x_return_status := G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

        WHEN OTHERS THEN
            /*IF (l_debug = 'Y') THEN
                okc_debug.log('1000: Leaving start_approval because of EXCEPTION: '||sqlerrm, 2);
            END IF;*/

	    IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	        FND_LOG.STRING(G_EXCP_LEVEL,
	            G_PKG_NAME, '1000: Leaving start_approval because of EXCEPTION: '||sqlerrm );
	    END IF;

            ROLLBACK TO g_start_approval_pvt;
            x_return_status := G_RET_STS_UNEXP_ERROR ;
            IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
            END IF;
            FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    END start_approval;

    ---------------------------------------------------------------------------
    -- Procedure approve_template
    ---------------------------------------------------------------------------
    --
    -- Procedure
    --    approve_template
    --
    -- Description
    --
    -- IN
    --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
    --   itemkey   - A string generated from the application object's primary key.
    --   itemuserkey - A string generated from the application object user-friendly
    --               primary key.
    --   actid     - The function activity(instance id).
    --   processowner - The username owner for this item instance.
    --   funcmode  - Run/Cancel
    -- OUT
    --   resultout    - Name of workflow process to run
    --
   PROCEDURE approve_template (
        itemtype	in varchar2,
        itemkey  	in varchar2,
        actid		in number,
        funcmode	in varchar2,
        resultout	out nocopy varchar2	)
    IS

    pragma autonomous_transaction;

        l_tmpl_id                   okc_terms_templates_all.template_id%TYPE;
        l_tmpl_status               okc_terms_templates_all.status_code%TYPE;
        l_tmpl_wc                   okc_terms_templates_all.working_copy_flag%TYPE;
        l_tmpl_wf_seq_id            NUMBER;
        x_return_status             VARCHAR2(1);
        x_msg_count                 NUMBER;
        x_msg_data                  VARCHAR2(2000);
        l_validation_results        OKC_ART_BLK_PVT.validation_tbl_type;
        l_parent_template_id        NUMBER;
        l_expert_enabled            VARCHAR2(1) := 'N';
        approval_exception          EXCEPTION;

        clause_sts_exception_1  EXCEPTION;
        clause_sts_exception_2  EXCEPTION;
        templ_publish_exception EXCEPTION;

        l_okc_rules_engine VARCHAR2(1);


    BEGIN
        IF ( funcmode = 'RUN' ) THEN
            l_tmpl_id :=
            wf_engine.getItemAttrNumber(itemtype, itemkey, 'TEMPLATE_ID', false);
            l_tmpl_status :=
            wf_engine.getItemAttrText(itemtype, itemkey, 'STATUS_CODE', false);
            l_tmpl_wc :=
            wf_engine.getItemAttrText(itemtype, itemkey, 'TMPL_WORKINGCOPY', false);
            l_tmpl_wf_seq_id :=
            wf_engine.getItemAttrText(itemtype, itemkey, 'TMPL_WF_SEQ_ID', false);
	    l_expert_enabled :=
            wf_engine.getItemAttrText(itemtype, itemkey, 'TMPL_EXPERT_ENABLED', false);
            x_return_status := 'S';


            IF (l_expert_enabled = 'Y') THEN

    SELECT fnd_profile.Value('OKC_USE_CONTRACTS_RULES_ENGINE') INTO l_okc_rules_engine FROM dual;

    fnd_file.put_line(FND_FILE.LOG,'Using OKC Rules Engine'||l_okc_rules_engine);

    IF Nvl(l_okc_rules_engine,'N') = 'N' THEN

		    OKC_XPRT_UTIL_PVT.create_production_publication (
			p_calling_mode          => 'TEMPLATE_APPROVAL',
			p_template_id           => l_tmpl_id,
			x_return_status         => x_return_status,
			x_msg_data              => x_msg_data,
			x_msg_count             => x_msg_count);

		    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
			-- some clause validation failed
			RAISE templ_publish_exception;
		    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			-- unexpected error
			RAISE templ_publish_exception;
		    END IF;

    ELSE

   	  UPDATE Okc_Xprt_Question_Orders
	     SET runtime_available_flag = 'Y',
	         last_updated_by = FND_GLOBAL.USER_ID,
	         last_update_date = SYSDATE,
	         last_update_login = FND_GLOBAL.LOGIN_ID
	   WHERE template_id= l_tmpl_id
	     AND question_rule_status = 'ACTIVE';

   -- Delete from okc_xprt_template_rules
      DELETE FROM okc_xprt_template_rules
	  WHERE NVL(deleted_flag,'N') = 'Y'
	    AND template_id =  l_tmpl_id;

   -- Update published_flag in okc_xprt_template_rules
        UPDATE okc_xprt_template_rules
	      SET published_flag = 'Y'
	   WHERE template_id= l_tmpl_id ;


    END IF;

            END IF;

            CHANGE_CLAUSE_STATUS (
                p_api_version           => 1,
                p_init_msg_list         => FND_API.G_FALSE,
                p_commit                => FND_API.G_FALSE,
                p_template_id           => l_tmpl_id,
                p_wf_seq_id 			=> l_tmpl_wf_seq_id,
                p_status                => 'APPROVED',
                x_validation_results    => l_validation_results,
                x_return_status         => x_return_status,
                x_msg_data              => x_msg_data,
                x_msg_count             => x_msg_count);


            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                -- some clause validation failed
                RAISE clause_sts_exception_1;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                -- unexpected error
                RAISE clause_sts_exception_2;
            END IF;

            IF ((l_tmpl_status = 'REVISION') OR
                (l_tmpl_status = 'REJECTED' AND l_tmpl_wc = 'Y')) THEN

                OKC_TERMS_UTIL_PVT.merge_template_working_copy(
                    p_api_version           => 1,
                    p_init_msg_list         => FND_API.G_FALSE,
                    p_commit                => FND_API.G_FALSE,
                    p_template_id           => l_tmpl_id,
                    x_return_status         => x_return_status,
                    x_msg_data              => x_msg_data,
                    x_msg_count             => x_msg_count,
                    x_parent_template_id    => l_parent_template_id);

                Wf_engine.setItemAttrNumber(
                    itemtype => itemtype,
                    itemkey  => itemkey,
                    aname 	 => 'TEMPLATE_ID',
                    avalue	 =>  l_parent_template_id);

            ELSE

                UPDATE okc_terms_templates_all
                    SET status_code = 'APPROVED'
                    WHERE template_id = l_tmpl_id;

            END IF;

            resultout := 'COMPLETE';

            IF x_return_status = 'S' THEN
                COMMIT;
            ELSE
                /*
                ROLLBACK;
                UPDATE okc_terms_templates_all
                SET status_code = l_tmpl_status
                WHERE template_id = l_tmpl_id;
                COMMIT;
                */
                RAISE approval_exception;
            END IF;

            RETURN;

    END IF; -- of IF ( funcmode = 'RUN' ) THEN

    EXCEPTION
        WHEN clause_sts_exception_1 THEN
            -- try to send as much info as possible to the workflow error stack from validation results
            WF_CORE.CONTEXT(G_PKG_NAME, 'Change_clause_status', itemtype,
                itemkey, to_char(actid)||funcmode,
                get_error_string(l_validation_results));
            RAISE;

        WHEN clause_sts_exception_2 THEN
            set_wf_error_context(
                p_pkg_name      => G_PKG_NAME,
                p_api_name      =>  'change_clause_status',
                p_itemtype      => itemtype,
                p_itemkey       => itemkey,
                p_actid         => actid,
                p_funcmode      => funcmode,
                p_msg_count     => x_msg_count);
            RAISE;

        WHEN approval_exception THEN
            set_wf_error_context(
                p_pkg_name      => G_PKG_NAME,
                p_api_name      =>  'merge_template_working_copy',
                p_itemtype      => itemtype,
                p_itemkey       => itemkey,
                p_actid         => actid,
                p_funcmode      => funcmode,
                p_msg_count     => x_msg_count);
            RAISE;

        WHEN templ_publish_exception THEN
            set_wf_error_context(
                p_pkg_name      => G_PKG_NAME,
                p_api_name      =>  'create_production_publication',
                p_itemtype      => itemtype,
                p_itemkey       => itemkey,
                p_actid         => actid,
                p_funcmode      => funcmode,
                p_msg_count     => x_msg_count);
            RAISE;
        WHEN OTHERS THEN
            WF_CORE.CONTEXT ( G_PKG_NAME, 'approve_tempalte', itemtype,
                itemkey, to_char(actid), funcmode);
            RAISE;
    END approve_template;



    ---------------------------------------------------------------------------
    -- Procedure reject_template
    ---------------------------------------------------------------------------
    --
    -- Procedure
    --    reject_template
    --
    -- Description
    --
    -- IN
    --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
    --   itemkey   - A string generated from the application object's primary key.
    --   itemuserkey - A string generated from the application object user-friendly
    --               primary key.
    --   actid     - The function activity(instance id).
    --   processowner - The username owner for this item instance.
    --   funcmode  - Run/Cancel
    -- OUT
    --   resultout    - Name of workflow process to run
    --
    PROCEDURE reject_template (
        itemtype	in varchar2,
        itemkey  	in varchar2,
        actid		in number,
        funcmode	in varchar2,
        resultout	out nocopy varchar2	)
    IS

        l_tmpl_id               okc_terms_templates_all.template_id%TYPE;
        l_tmpl_status           okc_terms_templates_all.status_code%TYPE;
        l_tmpl_wf_seq_id        NUMBER;
        x_return_status         VARCHAR2(1);
        x_msg_count             NUMBER;
        x_msg_data              VARCHAR2(2000);
        reject_exception        EXCEPTION;
        clause_sts_exception_1  EXCEPTION;
        clause_sts_exception_2  EXCEPTION;
        l_validation_results    OKC_ART_BLK_PVT.validation_tbl_type;

    BEGIN

        IF ( funcmode = 'RUN' ) THEN

            l_tmpl_id :=
                wf_engine.getItemAttrNumber(itemtype, itemkey, 'TEMPLATE_ID', false);
            l_tmpl_status :=
                wf_engine.getItemAttrText(itemtype, itemkey, 'STATUS_CODE', false);
            l_tmpl_wf_seq_id :=
                wf_engine.getItemAttrText(itemtype, itemkey, 'TMPL_WF_SEQ_ID', false);
            x_return_status := 'S';

            CHANGE_CLAUSE_STATUS (
                p_api_version           => 1,
                p_init_msg_list         => FND_API.G_FALSE,
                p_commit                => FND_API.G_FALSE,
                p_template_id           => l_tmpl_id,
                p_wf_seq_id             => l_tmpl_wf_seq_id,
                p_status                => 'REJECTED',
                x_validation_results    => l_validation_results,
                x_return_status         => x_return_status,
                x_msg_data              => x_msg_data,
                x_msg_count             => x_msg_count);

            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                -- some clause validation failed
                RAISE clause_sts_exception_1;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                -- unexpected error
                RAISE clause_sts_exception_2;
            END IF;

            UPDATE okc_terms_templates_all
                --SET status_code = nvl(l_tmpl_status,decode(working_copy_flag,null,'DRAFT','REVISION'))
                --SET status_code = decode(working_copy_flag,null,'DRAFT','REVISION')
                SET status_code = 'REJECTED'
                WHERE template_id = l_tmpl_id;

            resultout := 'COMPLETE';

            IF x_return_status = 'S' THEN
                RETURN;
            ELSE
                RAISE reject_exception;
            END IF;

            RETURN;

        END IF;

    EXCEPTION
        WHEN clause_sts_exception_1 THEN
            -- try to send as much info as possible to the workflow error stack from validation results
            WF_CORE.CONTEXT('OKC_TERMS_TMPL_APPROVAL_PVT', 'Change_clause_status', itemtype,
                itemkey, to_char(actid)||funcmode,
                get_error_string(l_validation_results));
            RAISE;

        WHEN clause_sts_exception_2 THEN
            set_wf_error_context(
                p_pkg_name      => G_PKG_NAME,
                p_api_name      =>  'change_clause_status',
                p_itemtype      => itemtype,
                p_itemkey       => itemkey,
                p_actid         => actid,
                p_funcmode      => funcmode,
                p_msg_count     => x_msg_count);
            RAISE;

        WHEN reject_exception THEN
            WF_CORE.CONTEXT('OKC_TERMS_UTIL_PVT', 'Reject_Template', itemtype,
                itemkey, to_char(actid), funcmode);
            RAISE;

        WHEN OTHERS THEN
            WF_CORE.CONTEXT ( 'OKC_TERMS_TMPL_APPROVAL_PVT', 'Reject_Template', itemtype,
                itemkey, to_char(actid), funcmode);
            RAISE;
    END reject_template;




    PROCEDURE select_approver (
        itemtype    in varchar2,
        itemkey      in varchar2,
        actid        in number,
        funcmode    in varchar2,
        resultout    out nocopy varchar2    )
    IS

        l_template_id NUMBER;
        l_tmpl_intent VARCHAR2(1);
        l_approver fnd_user.user_name%TYPE NULL;
        l_org_id NUMBER := NULL;

        CURSOR tmpl_approver_csr(cp_template_id IN NUMBER) IS
            SELECT decode(tmpl.intent,'S',org.org_information2,org.org_information6) org_information
            FROM hr_organization_information org,
		       okc_terms_templates_all tmpl
            WHERE org.organization_id = tmpl.org_id
                AND org.org_information_context = 'OKC_TERMS_LIBRARY_DETAILS'
			 AND tmpl.template_id = cp_template_id;

    BEGIN
        --
        -- RUN mode - normal process execution
        --
        IF (funcmode = 'RUN') then

            l_template_id := wf_engine.GetItemAttrNumber(
                itemtype    => itemtype,
                itemkey     => itemkey,
                aname       => 'TEMPLATE_ID' );

            OPEN tmpl_approver_csr(l_template_id);
            FETCH tmpl_approver_csr INTO l_approver;
            CLOSE tmpl_approver_csr;

            --l_approver := 'CONMGR';

            IF l_approver IS NOT NULL THEN
                wf_engine.SetItemAttrText (itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'APPROVER_USERNAME',
                    avalue   =>  l_approver);

                resultout := 'COMPLETE:T';

            ELSE
                resultout := 'COMPLETE:F';
            END IF;

            RETURN;

        END IF;

        -- CANCEL mode - activity 'compensation'
        IF (funcmode = 'CANCEL') then
            resultout := 'COMPLETE:';
            RETURN;
        END IF;

        -- TIMEOUT mode
        IF (funcmode = 'TIMEOUT') then
            resultout := 'COMPLETE:';
            RETURN;
        END IF;

    END select_approver;

    ---------------------------------------------------------------------------
    -- Procedure attachment_exists
    ---------------------------------------------------------------------------
    PROCEDURE attachment_exists (
        itemtype    in varchar2,
        itemkey      in varchar2,
        actid        in number,
        funcmode    in varchar2,
        resultout    out nocopy varchar2    )
    IS
        l_template_id NUMBER;
        l_wf_seq_id NUMBER;
        l_dummy_var VARCHAR2(1);
        l_tmpl_attach_exists VARCHAR2(1);

        CURSOR attachment_exists_csr(cp_val1 IN VARCHAR2,cp_val2 IN VARCHAR2) IS
            SELECT 1
            FROM fnd_attached_documents
            WHERE entity_name = 'OKC_TERMS_TEMPLATES'
                AND pk1_value = cp_val1
                AND pk2_value = cp_val2;

    BEGIN

        -- RUN mode - normal process execution
        IF (funcmode = 'RUN') then


        -- checking wether the item attribute was already set.
            l_tmpl_attach_exists := wf_engine.GetItemAttrNumber(
                itemtype => itemtype,
                itemkey    => itemkey,
            aname => 'TMPL_ATTACH_EXISTS' );

            if l_tmpl_attach_exists is not null then

                IF l_tmpl_attach_exists = 'Y' then
                    resultout := 'COMPLETE:T';
                ELSE
                    resultout := 'COMPLETE:F';
                END IF;

            -- first time ,if item attribute was not set, execute the query
            else

                l_template_id := wf_engine.GetItemAttrNumber(
                itemtype => itemtype,
                itemkey    => itemkey,
                aname => 'TEMPLATE_ID' );

                l_wf_seq_id := wf_engine.GetItemAttrNumber(
                itemtype => itemtype,
                itemkey    => itemkey,
                aname => 'TMPL_WF_SEQ_ID' );

                OPEN attachment_exists_csr(l_template_id,l_wf_seq_id);
                FETCH attachment_exists_csr INTO l_dummy_var;


                IF attachment_exists_csr%FOUND THEN
                    resultout := 'COMPLETE:T';
                    wf_engine.setItemAttrText(itemtype, itemkey, 'TMPL_ATTACH_EXISTS', 'Y');
                ELSE
                    resultout := 'COMPLETE:F';
                    wf_engine.setItemAttrText(itemtype, itemkey, 'TMPL_ATTACH_EXISTS', 'N');
                END IF;
                CLOSE attachment_exists_csr;

            end if;

            RETURN;

        END IF;
/* bug 5631705 commented out CANCEL and TIMEOUT modes
        -- CANCEL mode - activity 'compensation'
        IF (funcmode = 'CANCEL') then
            resultout := 'COMPLETE:';
            RETURN;
        END IF;

        -- TIMEOUT mode
        IF (funcmode = 'TIMEOUT') then
            resultout := 'COMPLETE:';
            RETURN;
        END IF;
*/
    END attachment_exists;

    ---------------------------------------------------------------------------
    -- Procedure layout_template_exists
    ---------------------------------------------------------------------------
    PROCEDURE layout_template_exists (   itemtype        in varchar2,
    itemkey         in varchar2,
    actid           in number,
    funcmode        in varchar2,
    resultout       out nocopy varchar2     )
    IS
    l_template_id NUMBER;
    l_wf_seq_id NUMBER;
    l_dummy_var VARCHAR2(1);

    CURSOR print_template_exits_csr(cp_tmpl_id IN NUMBER) IS
    SELECT 1
    FROM OKC_TERMS_TEMPLATES_ALL
    WHERE template_id = cp_tmpl_id
    AND print_template_id IS NOT NULL;

    BEGIN

        -- RUN mode - normal process execution
        IF (funcmode = 'RUN') then

            l_template_id := wf_engine.GetItemAttrNumber(
                itemtype => itemtype,
                itemkey => itemkey,
                aname => 'TEMPLATE_ID' );

            OPEN print_template_exits_csr(l_template_id);
            FETCH print_template_exits_csr INTO l_dummy_var;
            IF print_template_exits_csr%FOUND THEN
                resultout := 'COMPLETE:T';
            ELSE
                resultout := 'COMPLETE:F';
            END IF;
            CLOSE print_template_exits_csr;

            RETURN;
        END IF;


        -- CANCEL mode -
        IF (funcmode = 'CANCEL') then
            resultout := 'COMPLETE:';
            RETURN;
        END IF;

        -- TIMEOUT mode
        IF (funcmode = 'TIMEOUT') then
            resultout := 'COMPLETE:';
            RETURN;
        END IF;

    END layout_template_exists;

    ---------------------------------------------------------------------------
    -- Procedure get_template_url
    ---------------------------------------------------------------------------
    PROCEDURE get_template_url (
        itemtype        in varchar2,
        itemkey         in varchar2,
        actid           in number,
        funcmode        in varchar2,
        resultout       out nocopy varchar2    )
    IS
    BEGIN

        -- RUN mode - normal process execution
        IF (funcmode = 'RUN') then
            resultout := 'COMPLETE:';
            RETURN;
        END IF;

        -- CANCEL mode - activity 'compensation'
        IF (funcmode = 'CANCEL') then
            resultout := 'COMPLETE:';
            RETURN;
        END IF;

        -- TIMEOUT mode
        IF (funcmode = 'TIMEOUT') then
            resultout := 'COMPLETE:';
            RETURN;
        END IF;
    END get_template_url;

    ---------------------------------------------------------------------------
    -- Procedure change_clause_status
    ---------------------------------------------------------------------------
    /* 11.5.10+
        new procedure to change the status of articles submitted with a template
        Fecthes the article versions from table OKC_TMPL_DRAFT_CLAUSES and then
        calls article bulk api's to do the actual status changes.

        The following status changes are allowed
            DRAFT               -> PENDING_APPROVAL
            PENDING_APPROVAL    -> APPROVED/REJECTED

        p_template_id   Maps to document_id column in table OKC_TMPL_DRAFT_CLAUSES.
        p_wf_seq_id     Maps to WF_SEQ_ID column in table OKC_TMPL_DRAFT_CLAUSES.
        p_status        The status that the articles should be updated to,
                        can be one of 3 values - 'PENDING_APPROVAL', 'APPROVED', 'REJECTED'.
                        Error is thrown if the status is something else.

        p_validation_level meaningful only for p_status = PENDING_APPROVAL.
                        The pending approval blk api accepts a validation level parameter
                        to either do complete or no validation. Passed as it is to the
                        pending approval blk api.

        x_validation_results    If for any clauses fail the validation check the results
                        are returned in this table
    */
    PROCEDURE change_clause_status     (
        p_api_version               IN    NUMBER,
        p_init_msg_list             IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_commit                    IN    VARCHAR2 DEFAULT FND_API.G_FALSE,

        x_return_status             OUT    NOCOPY VARCHAR2,
        x_msg_data                  OUT    NOCOPY VARCHAR2,
        x_msg_count                 OUT    NOCOPY NUMBER,

        p_template_id               IN NUMBER,
        p_wf_seq_id                 IN NUMBER DEFAULT NULL,
        p_status                    IN VARCHAR2,
        p_validation_level          IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
        x_validation_results        OUT    NOCOPY OKC_ART_BLK_PVT.validation_tbl_type)

    IS

        l_api_version                CONSTANT NUMBER := 1;
        l_api_name                    CONSTANT VARCHAR2(30) := 'change_clause_status';
        l_current_org_id            NUMBER;
        l_article_version_id_tbl    OKC_ART_BLK_PVT.NUM_TBL_TYPE;

        CURSOR l_tmpl_csr  (cp_template_id IN NUMBER) IS
            SELECT org_id from OKC_TERMS_TEMPLATES_ALL
            WHERE template_id = cp_template_id;

        CURSOR l_tmpl_clauses_csr  (cp_template_id IN NUMBER, cp_wf_seq_id IN NUMBER) IS
            SELECT article_version_id from OKC_TMPL_DRAFT_CLAUSES
            WHERE template_id = cp_template_id
                AND nvl(wf_seq_id, -99) = nvl(cp_wf_seq_id, -99)  --[p_wf_seq_id can be null]
                AND selected_yn = 'Y';

    BEGIN

        /*IF (l_debug = 'Y') THEN
            okc_debug.log('100: Entered OKC_TERMS_TMPL_APPROVAL_PVT.change_clause_status', 2);
        END IF;*/

	IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
 	   FND_LOG.STRING(G_PROC_LEVEL,
  	       G_PKG_NAME, '100: Entered OKC_TERMS_TMPL_APPROVAL_PVT.change_clause_status' );
	END IF;

        -- Standard Start of API savepoint
        SAVEPOINT change_clause_status_pvt;

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
        l_article_version_id_tbl := OKC_ART_BLK_PVT.NUM_TBL_TYPE();

        IF (p_status NOT IN ('PENDING_APPROVAL', 'APPROVED', 'REJECTED')) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.set_name(G_APP_NAME, G_OKC_MSG_INVALID_ARGUMENT);
            FND_MESSAGE.set_token('ARG_NAME', 'p_status');
            FND_MESSAGE.set_token('ARG_VALUE', p_status);
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        OPEN l_tmpl_csr(p_template_id);
        FETCH l_tmpl_csr INTO l_current_org_id;
        IF l_tmpl_csr%NOTFOUND THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
		  CLOSE l_tmpl_csr;
            FND_MESSAGE.set_name(G_APP_NAME, G_OKC_MSG_INVALID_ARGUMENT);
            FND_MESSAGE.set_token('ARG_NAME', 'p_template_id');
            FND_MESSAGE.set_token('ARG_VALUE', p_template_id);
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        OPEN l_tmpl_clauses_csr(p_template_id, p_wf_seq_id);
        LOOP
            l_article_version_id_tbl.DELETE;

		    FETCH l_tmpl_clauses_csr BULK COLLECT INTO l_article_version_id_tbl  LIMIT 100;

            IF l_article_version_id_tbl.COUNT = 0 THEN
    			EXIT;
		    END IF;

            IF (p_status = 'PENDING_APPROVAL') THEN
                OKC_ART_BLK_PVT.PENDING_APPROVAL_BLK(
                    p_api_version           => 1,
                    p_init_msg_list         => FND_API.G_FALSE,
                    p_commit                => FND_API.G_FALSE,
                    p_validation_level      => p_validation_level,

                    x_return_status            => x_return_status,
                    x_msg_count             => x_msg_count,
                    x_msg_data              => x_msg_data,

                    p_org_id                => l_current_org_id,
                    p_art_ver_tbl           => l_article_version_id_tbl,
                    x_validation_results    => x_validation_results);
            ELSIF(p_status = 'APPROVED') THEN
                OKC_ART_BLK_PVT.APPROVE_BLK(
                    p_api_version           => 1,
                    p_init_msg_list         => FND_API.G_FALSE,
                    p_commit                => FND_API.G_FALSE,

                    x_return_status            => x_return_status,
                    x_msg_count             => x_msg_count,
                    x_msg_data              => x_msg_data,

                    p_org_id                => l_current_org_id,
                    p_art_ver_tbl           => l_article_version_id_tbl,
                    x_validation_results    => x_validation_results);
            ELSIF(p_status = 'REJECTED') THEN
                OKC_ART_BLK_PVT.REJECT_BLK(
                    p_api_version           => 1,
                    p_init_msg_list         => FND_API.G_FALSE,
                    p_commit                => FND_API.G_FALSE,

                    x_return_status            => x_return_status,
                    x_msg_count             => x_msg_count,
                    x_msg_data              => x_msg_data,

                    p_org_id                => l_current_org_id,
                    p_art_ver_tbl           => l_article_version_id_tbl,
                    x_validation_results    => x_validation_results);
            END IF;

            IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
            ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            END IF;

        END LOOP;

        IF l_tmpl_clauses_csr%ISOPEN THEN
            CLOSE l_tmpl_clauses_csr;
        END IF;


        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

        IF(FND_API.to_boolean(p_commit)) THEN
            COMMIT;
        END IF;

        /*IF (l_debug = 'Y') THEN
            okc_debug.log('1000: Leaving change_clause_status', 2);
        END IF;*/

	IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
 	   FND_LOG.STRING(G_PROC_LEVEL,
  	       G_PKG_NAME, '1000: Leaving change_clause_status' );
	END IF;

    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            /*IF (l_debug = 'Y') THEN
                okc_debug.log('800: Leaving change_clause_status: OKC_API.G_EXCEPTION_ERROR Exception', 2);
            END IF;*/

	    IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
               FND_LOG.STRING(G_EXCP_LEVEL,
                   G_PKG_NAME, '800: Leaving change_clause_status: OKC_API.G_EXCEPTION_ERROR Exception' );
            END IF;

            IF (l_tmpl_csr%ISOPEN) THEN
                CLOSE l_tmpl_csr;
            END IF;
            IF (l_tmpl_clauses_csr%ISOPEN) THEN
                CLOSE l_tmpl_clauses_csr;
            END IF;

            ROLLBACK TO change_clause_status_pvt;
            x_return_status := G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            /*IF (l_debug = 'Y') THEN
                okc_debug.log('900: Leaving change_clause_status: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
            END IF;*/

	    IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
               FND_LOG.STRING(G_EXCP_LEVEL,
                   G_PKG_NAME, '900: Leaving change_clause_status: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception' );
            END IF;

            IF (l_tmpl_csr%ISOPEN) THEN
                CLOSE l_tmpl_csr;
            END IF;
            IF (l_tmpl_clauses_csr%ISOPEN) THEN
                CLOSE l_tmpl_clauses_csr;
            END IF;

            ROLLBACK TO change_clause_status_pvt;
            x_return_status := G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

        WHEN OTHERS THEN
            /*IF (l_debug = 'Y') THEN
                okc_debug.log('1000: Leaving change_clause_status because of EXCEPTION: '||sqlerrm, 2);
            END IF;*/

	    IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
               FND_LOG.STRING(G_EXCP_LEVEL,
                   G_PKG_NAME, '1000: Leaving change_clause_status because of EXCEPTION: '||sqlerrm );
            END IF;

            IF (l_tmpl_csr%ISOPEN) THEN
                CLOSE l_tmpl_csr;
            END IF;
            IF (l_tmpl_clauses_csr%ISOPEN) THEN
                CLOSE l_tmpl_clauses_csr;
            END IF;

            ROLLBACK TO change_clause_status_pvt;
            x_return_status := G_RET_STS_UNEXP_ERROR ;
            IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
            END IF;
            FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    END change_clause_status;

    ---------------------------------------------------------------------------
    -- Function get_error_string
    ---------------------------------------------------------------------------
    FUNCTION get_error_string(
        l_validation_results IN OKC_ART_BLK_PVT.validation_tbl_type)  RETURN VARCHAR2
    IS
        l_error_msg VARCHAR2(4000);

    BEGIN

        IF l_validation_results.COUNT > 0 THEN
            FOR i IN l_validation_results.FIRST..l_validation_results.LAST LOOP
                l_error_msg := substrb( l_error_msg ||
                    l_validation_results(i).article_title || ' ' ||
                    l_validation_results(i).article_version_id  || ' ' ||
                    l_validation_results(i).error_message, 0,1333 );
            END LOOP;
        END if;
        RETURN l_error_msg;
    END;

       PROCEDURE set_notified_list(
           itemtype in varchar2,
           itemkey in varchar2,
           actid in number,
           funcmode in varchar2,
           resultout out nocopy varchar2)
       IS

           template_id  number;
           l_tmpl_intent VARCHAR2(1);

           CURSOR notified_csr(cp_tmpl_intent IN VARCHAR2, cp_global_org_id IN NUMBER) is
           SELECT decode(org_information1, 'Y', 'ADOPTED','AVAILABLE'),
               hr.organization_id,
               decode(cp_tmpl_intent,'S',org_information3,org_information7) org_information
           FROM hr_organization_units hr,
               hr_organization_information hri
           WHERE hri.organization_id = hr.organization_id
               and org_information_context = 'OKC_TERMS_LIBRARY_DETAILS'
			and hr.organization_id <> cp_global_org_id;



           TYPE adoption_type_tbl    IS TABLE OF VARCHAR(30)  INDEX BY BINARY_INTEGER;
           TYPE organization_id_tbl  IS TABLE OF NUMBER       INDEX BY BINARY_INTEGER;
           TYPE org_information3_tbl IS TABLE OF VARCHAR(150) INDEX BY BINARY_INTEGER;

           adoption_type_lst       adoption_type_tbl;
           organization_id_lst     organization_id_tbl;
           org_information3_lst    org_information3_tbl;

           operation               Wf_Engine.NameTabTyp;
           operation_list          Wf_Engine.TextTabTyp;
           organization            Wf_Engine.NameTabTyp;
           organization_list       Wf_Engine.NumTabTyp;
           notified                Wf_Engine.NameTabTyp;
           notified_list           Wf_Engine.TextTabTyp;
           global_org_id           NUMBER := NVL(FND_PROFILE.VALUE('OKC_GLOBAL_ORG_ID'),-99);
           counter                 NUMBER;

       BEGIN
           counter := 0;
           template_id := wf_engine.getItemAttrNumber(itemtype, itemkey, 'TEMPLATE_ID', false);
           l_tmpl_intent := wf_engine.getItemAttrNumber(itemtype, itemkey, 'TMPL_INTENT', false);

		 IF ( funcmode = 'RUN' ) THEN
               OPEN notified_csr(l_tmpl_intent , global_org_id);
               FETCH notified_csr BULK COLLECT INTO adoption_type_lst,organization_id_lst,org_information3_lst;
               CLOSE notified_csr;

               IF adoption_type_lst.COUNT > 0 THEN
                   FOR i IN adoption_type_lst.FIRST..adoption_type_lst.LAST LOOP
                       counter := counter+1;
                       operation(counter):=          'OPERATION_LIST$'||counter;
                       operation_list(counter):=     adoption_type_lst(i);
                       organization(counter):=       'ORGANIZATION_LIST$'||counter;
                       organization_list(counter):=  organization_id_lst(i);
                       notified(counter):=           'NOTIFIED_LIST$'||counter;
                       notified_list(counter):=      org_information3_lst(i);
                   END LOOP;

                   wf_engine.AddItemAttrTextArray( itemtype, itemkey, operation, operation_list);
                   wf_engine.AddItemAttrNumberArray( itemtype, itemkey, organization, organization_list);
                   wf_engine.AddItemAttrTextArray( itemtype, itemkey, notified, notified_list);
                   wf_engine.AddItemAttr(itemtype, itemkey, 'COUNTER$', null, counter, null);
                   resultout := 'COMPLETE';

                   RETURN;
               END IF;
           END IF;
       EXCEPTION

           WHEN OTHERS THEN
               WF_CORE.CONTEXT ( 'OKC_TERMS_TMPL_APPROVAL_PVT', 'set_notified_list', itemtype,
               itemkey, to_char(actid), funcmode);
               RAISE;
       END set_notified_list;



    ---------------------------------------------------------------------------
    -- PROCEDURE set_notified
    ---------------------------------------------------------------------------
    --
    -- set_notified
    -- IN
    --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
    --   itemkey   - A string generated from the application object's primary key.
    --   actid     - The function activity(instance id).
    --   funcmode  - Run/Cancel
    -- OUT
    --   Resultout    - 'COMPLETE:'||operation' where operations is ADOPTED or AVAILABLE
    --         	     -'COMPLETE:UNDEFINED' if any error
    --

    --
    PROCEDURE set_notified(
        itemtype in varchar2,
        itemkey in varchar2,
        actid in number,
        funcmode in varchar2,
        resultout out nocopy varchar2)
    IS

        operation okc_article_adoptions.adoption_type%type;
        organization hr_organization_units_v.organization_id%type;
        notified hr_organization_information.org_information3%type;

        org_name		VARCHAR(240);
        wf_admin_user   VARCHAR(320);
        counter 		NUMBER;
        adoption_type_desc   fnd_lookup_values.meaning%type;

	   CURSOR org_name_csr(cp_org_id in number) IS
            SELECT	name
            FROM 	hr_all_organization_units
            WHERE	organization_id =  cp_org_id;

        CURSOR	adoption_type_meaning_csr(cp_adoption_type in VARCHAR2) IS
            SELECT	meaning
            FROM 	fnd_lookups
            WHERE  lookup_type = 'OKC_ARTICLE_ADOPTION_TYPE'
                AND	lookup_code = cp_adoption_type;

        CURSOR  wf_admin_csr IS
            SELECT	user_name
            FROM  wf_user_roles
            WHERE  role_name ='SYSADMIN';

    BEGIN
      IF (funcmode = 'RUN') THEN
        OPEN 	wf_admin_csr;
        FETCH   wf_admin_csr INTO wf_admin_user;
        CLOSE   wf_admin_csr;

        counter := wf_engine.getItemAttrNumber(itemtype, itemkey, 'COUNTER$', false);
        IF counter > 0 THEN
            operation := wf_engine.getItemAttrText(itemtype, itemkey, 'OPERATION_LIST$'||counter, false);
            organization := wf_engine.getItemAttrNumber(itemtype, itemkey, 'ORGANIZATION_LIST$'||counter, false);
            notified := wf_engine.getItemAttrText(itemtype, itemkey, 'NOTIFIED_LIST$'||counter, false);

            OPEN 	org_name_csr(organization);
            FETCH org_name_csr INTO org_name;
            CLOSE org_name_csr;

            OPEN 	adoption_type_meaning_csr(operation);
            FETCH adoption_type_meaning_csr INTO adoption_type_desc;
            CLOSE adoption_type_meaning_csr;

            if (org_name is null ) then
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            end if ;

            if (adoption_type_desc is null ) then
		     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	       end if ;

	       wf_engine.setItemAttrText(itemtype, itemkey, 'ADOPTION_DESC', adoption_type_desc);
            wf_engine.setItemAttrText(itemtype, itemkey, 'ADOPTION_TYPE', operation);
            wf_engine.setItemAttrText(itemtype, itemkey, 'LOCAL_ORG_NAME', org_name);
            wf_engine.setItemAttrNumber(itemtype, itemkey, 'LOCAL_ORG_ID', organization);

            IF notified IS NOT NULL THEN
                wf_engine.setItemAttrText(itemtype, itemkey, 'LOCAL_ORG_APPROVER', notified);
            ELSE
                wf_engine.setItemAttrText(itemtype, itemkey, 'LOCAL_ORG_APPROVER', wf_admin_user);
            END IF;

            resultout := 'COMPLETE:'||operation;
        ELSE
            resultout := 'COMPLETE:UNDEFINED';
        END IF;

        RETURN;
      END IF; --if func mode is 'RUN'
    EXCEPTION
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	       WF_CORE.CONTEXT ( 'OKC_TERMS_TMPL_APPROVAL_PVT', 'set_notified ', itemtype,
	       itemkey, to_char(actid), funcmode);
        RAISE;
	   WHEN OTHERS THEN
            WF_CORE.CONTEXT ( 'OKC_TERMS_TMPL_APPROVAL_PVT', 'set_notified', itemtype,
            itemkey, to_char(actid), funcmode);
            RAISE;
    END set_notified;

    ---------------------------------------------------------------------------
    -- PROCEDURE decrement_counter
    ---------------------------------------------------------------------------
    --
    -- decrement_counter
    -- IN
    --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
    --   itemkey   - A string generated from the application object's primary key.
    --   actid     - The function activity(instance id).
    --   funcmode  - Run/Cancel
    -- OUT
    --   Resultout    - 'COMPLETE:T' if the counter is greater than 0, more notifications to be sent
    --          - 'COMPLETE:F' if the counter is 0 , no more notifications to be sent
    --

    --
    PROCEDURE decrement_counter(
        itemtype in varchar2,
        itemkey in varchar2,
        actid in number,
        funcmode in varchar2,
        resultout out nocopy varchar2)
    IS

        counter number;

    BEGIN
      IF (funcmode = 'RUN') THEN
        counter := wf_engine.getItemAttrNumber(itemtype, itemkey, 'COUNTER$', false) - 1;
        IF counter > 0 THEN
            wf_engine.setItemAttrNumber(itemtype, itemkey, 'COUNTER$', counter);
            resultout := 'COMPLETE:T';
        ELSE
            resultout := 'COMPLETE:F';
        END IF;

        RETURN;
      END IF; -- if funcmode = 'RUN'
    EXCEPTION
        WHEN OTHERS THEN
            WF_CORE.CONTEXT ( 'OKC_TERMS_TMPL_APPROVAL_PVT', 'decrement_counter', itemtype,
            itemkey, to_char(actid), funcmode);
            RAISE;
    END decrement_counter;

  /*Bug 6329229*/
    ---------------------------------------------------------------------------
    -- PROCEDURE set_context_info
    ---------------------------------------------------------------------------

PROCEDURE set_context_info(
itemtype in varchar2,
itemkey in varchar2,
actid in number,
funcmode in varchar2,
resultout out nocopy varchar2)
IS

begin
	  resultout := NULL;

      selector(itemtype => itemtype,
	  itemkey => itemkey,
      actid => actid,
      funcmode => 'SET_CTX',
	  resultout => resultout);

	return;

end set_context_info;

    ---------------------------------------------------------------------------
    -- PROCEDURE global_articles_exist
    ---------------------------------------------------------------------------
    --
    -- global_articles_exist
    -- IN
    --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
    --   itemkey   - A string generated from the application object's primary key.
    --   actid     - The function activity(instance id).
    --   funcmode  - Run/Cancel
    -- OUT
    --   Resultout    - 'COMPLETE:T' if global articles exist in the template
    --          - 'COMPLETE:F' if current org is not a global org or no global articles exist
    --
    PROCEDURE global_articles_exist(
        itemtype in varchar2,
        itemkey in varchar2,
        actid in number,
        funcmode in varchar2,
        resultout out nocopy varchar2)
    IS
        template_id             NUMBER;
        wf_seq_id               NUMBER;
        current_org_id          NUMBER;
        l_rowfound              BOOLEAN := FALSE;
        GLOBAL_ORG_ID           NUMBER := NVL(FND_PROFILE.VALUE('OKC_GLOBAL_ORG_ID'),-99);
        l_dummy                 NUMBER;
		l_org_count             NUMBER;

        CURSOR global_articles_csr(cp_template_id in number,cp_wf_seq_id IN NUMBER) IS
            SELECT 1
            FROM   okc_article_versions oav,
                okc_tmpl_draft_clauses otdc
            WHERE  otdc.template_id = cp_template_id
                AND  otdc.wf_seq_id = cp_wf_seq_id
                AND  otdc.article_version_id = oav.article_version_id
                AND  oav.global_yn = 'Y'
                AND ROWNUM < 2;

    BEGIN
      IF (funcmode = 'RUN') THEN
        resultout :=  'COMPLETE:F';
        current_org_id := wf_engine.getItemAttrNumber(itemtype, itemkey, 'ORG_ID', false);
        template_id    := wf_engine.getItemAttrNumber(itemtype, itemkey, 'TEMPLATE_ID', false);
        wf_seq_id     := wf_engine.getItemAttrNumber(itemtype, itemkey, 'TMPL_WF_SEQ_ID', false);

        IF  (current_org_id = GLOBAL_ORG_ID ) THEN

            OPEN global_articles_csr(template_id,wf_seq_id);
            FETCH global_articles_csr INTO l_dummy;
            l_rowfound := global_articles_csr%FOUND;
            CLOSE global_articles_csr;

            IF (l_rowfound) THEN
                --resultout := 'COMPLETE:T';
                -- bug fix 14822902 start    - SKAVUTHA
                -- if only one org exists in the setup, then return COMPLETE:F
                SELECT Count(1)
                      INTO l_org_count
                        FROM hr_organization_units hr,
                             hr_organization_information hri
                       WHERE hri.organization_id = hr.organization_id
                         and org_information_context = 'OKC_TERMS_LIBRARY_DETAILS'
	                       and hr.organization_id <> global_org_id;

                IF l_org_count = 0 THEN
                    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
                      FND_LOG.STRING(G_PROC_LEVEL,
                          G_PKG_NAME, 'NO active local orgs exist.' );
                    END IF;

                    resultout := 'COMPLETE:F';
                ELSE
                    resultout := 'COMPLETE:T';
                END IF;
            ELSE
                resultout := 'COMPLETE:F';
            END IF;

        ELSE
            resultout := 'COMPLETE:F';
        END IF;

        RETURN;
      END IF; -- if funcmode = 'RUN'
    EXCEPTION
        WHEN OTHERS THEN
            WF_CORE.CONTEXT ( 'OKC_TERMS_TMPL_APPROVAL_PVT', 'global_articles_exist', itemtype,
            itemkey, to_char(actid), funcmode);
            RAISE;
    END global_articles_exist;

    ---------------------------------------------------------------------------
    -- PROCEDURE select_draft_clauses
    ---------------------------------------------------------------------------
    --
    -- global_articles_exist
    -- IN
    --   p_template_id  - A valid template id for which all draft clauses
    --                   in table OKC_TMPL_DRAFT_CLAUSES will have the selected_yn flag set to Y
    --
    PROCEDURE select_draft_clauses(
        p_api_version               IN    NUMBER,
        p_init_msg_list             IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_commit                    IN    VARCHAR2 DEFAULT FND_API.G_FALSE,

        x_return_status             OUT    NOCOPY VARCHAR2,
        x_msg_data                  OUT    NOCOPY VARCHAR2,
        x_msg_count                 OUT    NOCOPY NUMBER,

        p_template_id               IN NUMBER)
    IS
        l_api_version                CONSTANT NUMBER := 1;
        l_api_name                   CONSTANT VARCHAR2(30) := 'select_draft_clauses';

    BEGIN

        /*IF (l_debug = 'Y') THEN
            okc_debug.log('100: Entered OKC_TERMS_TMPL_APPROVAL_PVT.select_draft_clauses, p_template_id' || p_template_id, 2);
        END IF;*/

	IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
	    FND_LOG.STRING(G_PROC_LEVEL,
	        G_PKG_NAME, '100: Entered OKC_TERMS_TMPL_APPROVAL_PVT.select_draft_clauses, p_template_id' || p_template_id );
	END IF;

        -- Standard Start of API savepoint
        SAVEPOINT select_draft_clauses_pvt;

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

        UPDATE OKC_TMPL_DRAFT_CLAUSES
            SET selected_yn = 'Y'
            WHERE template_id  = (
                select template_id from okc_terms_templates_all
                where template_id = p_template_id and status_code in ('DRAFT', 'REJECTED', 'REVISION'));

        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

        IF(FND_API.to_boolean(p_commit)) THEN
            COMMIT;
        END IF;

        /*IF (l_debug = 'Y') THEN
            okc_debug.log('1000: Leaving select_draft_clauses', 2);
        END IF;*/

	IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
	    FND_LOG.STRING(G_PROC_LEVEL,
 	       G_PKG_NAME, '1000: Leaving select_draft_clauses' );
	END IF;

    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            /*IF (l_debug = 'Y') THEN
                okc_debug.log('800: Leaving select_draft_clauses: OKC_API.G_EXCEPTION_ERROR Exception', 2);
            END IF;*/

	    IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	       FND_LOG.STRING(G_EXCP_LEVEL,
                   G_PKG_NAME, '800: Leaving select_draft_clauses: OKC_API.G_EXCEPTION_ERROR Exception' );
	    END IF;

            ROLLBACK TO change_clause_status_pvt;
            x_return_status := G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            /*IF (l_debug = 'Y') THEN
                okc_debug.log('900: Leaving select_draft_clauses: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
            END IF;*/

	    IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	       FND_LOG.STRING(G_EXCP_LEVEL,
                   G_PKG_NAME, '900: Leaving select_draft_clauses: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception' );
	    END IF;

            ROLLBACK TO change_clause_status_pvt;
            x_return_status := G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

        WHEN OTHERS THEN
            /*IF (l_debug = 'Y') THEN
                okc_debug.log('1000: Leaving select_draft_clauses because of EXCEPTION: '||sqlerrm, 2);
            END IF;*/

	    IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	       FND_LOG.STRING(G_EXCP_LEVEL,
                   G_PKG_NAME, '1000: Leaving select_draft_clauses because of EXCEPTION: '||sqlerrm );
	    END IF;

            ROLLBACK TO change_clause_status_pvt;
            x_return_status := G_RET_STS_UNEXP_ERROR ;
            IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
            END IF;
            FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    END select_draft_clauses;

end OKC_TERMS_TMPL_APPROVAL_PVT;

/
