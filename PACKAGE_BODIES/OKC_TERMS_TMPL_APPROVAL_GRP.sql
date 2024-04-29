--------------------------------------------------------
--  DDL for Package Body OKC_TERMS_TMPL_APPROVAL_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TERMS_TMPL_APPROVAL_GRP" AS
/* $Header: OKCGTMPLAPPB.pls 120.1 2005/10/07 07:04:45 ndoddi noship $ */

    l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

	---------------------------------------------------------------------------
	-- GLOBAL MESSAGE CONSTANTS
	---------------------------------------------------------------------------
	G_FND_APP                    CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
	---------------------------------------------------------------------------
	-- GLOBAL VARIABLES
	---------------------------------------------------------------------------
	G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_TERMS_TMPL_APPROVAL_GRP';
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
	G_INVALID_VALUE              CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
	G_COL_NAME_TOKEN             CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
	G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
	G_UNABLE_TO_RESERVE_REC      CONSTANT   VARCHAR2(200) := OKC_API.G_UNABLE_TO_RESERVE_REC;
	G_TEMPLATE_MISS_REC          OKC_TERMS_TEMPLATES_PVT.template_rec_type;

	G_DBG_LEVEL							    NUMBER 		:= FND_LOG.G_CURRENT_RUNTIME_LEVEL;
 	G_PROC_LEVEL							NUMBER		:= FND_LOG.LEVEL_PROCEDURE;
	G_EXCP_LEVEL							NUMBER		:= FND_LOG.LEVEL_EXCEPTION;


    ---------------------------------------------------------------------------
    -- Procedure start_approval
    ---------------------------------------------------------------------------
    /* added 2 new IN params and 1 out param
        p_validation_level  : 'A' or 'E' do all checks or checks with severity = E
        p_check_for_drafts  : 'Y' or 'N' if Y checks for drafts and inserts them
                              in the OKC_TMPL_DRAFT_CLAUSES table
        x_sequence_id       : contains the sequence id for table OKC_QA_ERRORS_T
                               that contains the validation results

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
		p_api_version				IN	Number,
		p_init_msg_list				IN	Varchar2 default FND_API.G_FALSE,
		p_commit					IN	Varchar2 default FND_API.G_FALSE,
		p_template_id				IN    Number,
		p_object_version_number		IN    Number default NULL,
		x_return_status				OUT	NOCOPY Varchar2,
		x_msg_data					OUT	NOCOPY Varchar2,
		x_msg_count					OUT	NOCOPY Number,
		x_qa_return_status			OUT	NOCOPY Varchar2,

		p_validation_level			IN VARCHAR2 DEFAULT 'A',
        p_check_for_drafts          IN VARCHAR2 DEFAULT 'N',
		x_sequence_id				OUT NOCOPY NUMBER)
	IS

		l_api_version                CONSTANT NUMBER := 2;
		--l_api_version                CONSTANT NUMBER := 1;
		l_api_name                   CONSTANT VARCHAR2(30) := 'g_start_approval';
		l_seq_id                     NUMBER;
		l_qa_return_status           VARCHAR2(30);
		l_qa_result_tbl              OKC_TERMS_QA_GRP.QA_RESULT_TBL_TYPE;
		l_deliverables_exist         VARCHAR2(100);
		l_dummy_var                  VARCHAR2(1);

		CURSOR tmpl_csr(pc_template_id NUMBER) IS
			SELECT object_version_number
			FROM okc_terms_templates
			WHERE template_id = pc_template_id;

		CURSOR article_exists_cur IS
			SELECT 1
			FROM OKC_K_ARTICLES_B
			WHERE document_id = p_template_id
				AND document_type = 'TEMPLATE';

		l_tmpl_rec  tmpl_csr%ROWTYPE;

	BEGIN

		/*IF (l_debug = 'Y') THEN
			okc_debug.log('100: Entered OKC_TERMS_TMPL_APPROVAL_GRP.start_approval', 2);
		END IF;*/

		IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
		    FND_LOG.STRING(G_PROC_LEVEL,
		        G_PKG_NAME, '100: Entered OKC_TERMS_TMPL_APPROVAL_GRP.start_approval' );
		END IF;

		-- Standard Start of API savepoint
		SAVEPOINT g_start_approval_GRP;

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
			okc_debug.log('200: opening tmpl_csr', 2);
		END IF;*/

		IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
		    FND_LOG.STRING(G_PROC_LEVEL,
		        G_PKG_NAME, '200: opening tmpl_csr' );
		END IF;

		-- Calling Template Apporval PVT API

		OPEN tmpl_csr(p_template_id);
		FETCH tmpl_csr INTo l_tmpl_rec;
		IF tmpl_csr%NOTFOUND THEN
			/*IF (l_debug = 'Y') THEN
				Okc_Debug.Log('300: - attribute TEMPLATE_ID is invalid', 2);
			END IF;*/

		    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
		        FND_LOG.STRING(G_PROC_LEVEL,
		            G_PKG_NAME, '300: - attribute TEMPLATE_ID is invalid' );
 		    END IF;
			Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TEMPLATE_ID');
			x_return_status := G_RET_STS_ERROR;
		END IF;
		CLOSE tmpl_csr;

		IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		ELSIF (x_return_status = G_RET_STS_ERROR) THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;

		OKC_TERMS_TMPL_APPROVAL_PVT.start_approval(
			p_api_version             => p_api_version,
			p_init_msg_list           => FND_API.G_FALSE,
			p_commit                  => FND_API.G_FALSE,
			p_template_id             => p_template_id,
			p_object_version_number   => l_tmpl_rec.object_version_number,
			x_return_status           => x_return_status,
			x_msg_data                => x_msg_data,
			x_msg_count               => x_msg_count,
			x_qa_return_status        => x_qa_return_status,
			p_validation_level		  => p_validation_level,
            p_check_for_drafts        => p_check_for_drafts,
			x_sequence_id			  => x_sequence_id);
		IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		ELSIF (x_return_status = G_RET_STS_ERROR) THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;

		IF FND_API.To_Boolean( p_commit ) THEN
			COMMIT WORK;
		END IF;

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

			ROLLBACK TO g_start_approval_grp;
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

			ROLLBACK TO g_start_approval_grp;
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

			ROLLBACK TO g_start_approval_grp;
			x_return_status := G_RET_STS_UNEXP_ERROR ;
			IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
				FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
			END IF;
			FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

	END start_approval;

END OKC_TERMS_TMPL_APPROVAL_GRP;

/
