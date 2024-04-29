--------------------------------------------------------
--  DDL for Package Body OKC_REP_QA_CHECK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_REP_QA_CHECK_PVT" AS
/* $Header: OKCVREPQACHKB.pls 120.9.12010000.8 2013/04/05 15:20:29 harchand ship $ */

-- Start of comments
--API name      : check_no_external_party
--Type          : Private.
--Function      : This procedure checks for the presence of an external party in a given contract.
--              : and modifies px_qa_result_tbl  table of records that contains validation
--              : errors and warnings
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_id         IN NUMBER       Required
--                   ID of the contract to be checked
--              : p_severity            IN VARCHAR2     Required
--                   Severity level for this check. Possible values are ERROR, WARNING.
--INOUT         : px_qa_result_tbl
--                The table of records that contains validation errors and warnings
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
   PROCEDURE check_no_external_party (
      p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2,
      p_contract_id       IN  NUMBER,
      p_severity            IN VARCHAR2,
      px_qa_result_tbl   IN OUT NOCOPY OKC_TERMS_QA_PVT.qa_result_tbl_type,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2
    ) IS

     l_party_role_code CONSTANT VARCHAR2(40) := 'INTERNAL_ORG';
     l_api_version                   CONSTANT NUMBER := 1;
     l_api_name                      CONSTANT VARCHAR2(30) := 'check_no_external_party';
     l_index                         PLS_INTEGER := 0;

     CURSOR party_csr IS
     SELECT 'X'
     FROM okc_rep_contract_parties
     WHERE contract_id = p_contract_id
     and party_role_code <> l_party_role_code;
     --APS Changes
         CURSOR is_acq_csr(con_id NUMBER) IS
        SELECT
          dtl.NAME
      FROM
           okc_rep_contracts_all c
          ,okc_lookups_v l2
          ,okc_bus_doc_types_b db
          ,okc_bus_doc_types_tl dtl

      WHERE  c.contract_type = db.document_type
      AND    dtl.document_type = db.document_type
      AND    c.contract_id = con_id;

      party_rec       party_csr%ROWTYPE;
      is_acq_rec     is_acq_csr%ROWTYPE;

   	  l_OKC_REP_NO_EXT_PARTY VARCHAR2(2000) ;
	  l_OKC_REP_NO_EXT_PARTY_S VARCHAR2(2000) ;

	  l_resolved_msg_name VARCHAR2(30);
      l_resolved_token VARCHAR2(30);

	  l_doc_type varchar2(60);

    CURSOR c_get_doctype is
	  SELECT CONTRACT_TYPE
	  FROM okc_rep_contracts_all
	  WHERE CONTRACT_id = p_contract_id;

    BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                     'Entered OKC_REP_QA_CHECK_PVT.check_no_external_party ');
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                     'Contract Id is:  ' || p_contract_id);
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                     'Severity level is:  ' || p_severity);
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
    x_return_status := FND_API.G_RET_STS_SUCCESS;

	open c_get_doctype;
	fetch c_get_doctype into l_doc_type;
	close c_get_doctype;

    l_resolved_token := OKC_API.resolve_hdr_token(l_doc_type);


    OPEN party_csr;
    FETCH party_csr INTO party_rec;
     ---Change for Acquisition Plan Summary
    OPEN is_acq_csr(p_contract_id);
    FETCH is_acq_csr INTO is_acq_rec;
    IF (is_acq_rec.NAME NOT LIKE '%Acquisition Plan Summary%') THEN



    IF party_csr%NOTFOUND THEN
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, G_MODULE||l_api_name,
                     'External Party is not found');
        END IF;
        -- Set the Qa Table index.
		l_resolved_msg_name := OKC_API.resolve_message(G_OKC_REP_NO_EXT_PARTY,l_doc_type);



    	l_OKC_REP_NO_EXT_PARTY := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, l_resolved_msg_name, p_token1 => 'HDR_TOKEN',
                                                    p_token1_value => l_resolved_token) ;

		l_resolved_msg_name := OKC_API.resolve_message(G_OKC_REP_NO_EXT_PARTY_S,l_doc_type);


    	l_OKC_REP_NO_EXT_PARTY_S := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, l_resolved_msg_name, p_token1 => 'HDR_TOKEN',
                                                    p_token1_value => l_resolved_token) ;


        -- Set the Qa Table index.


        l_index := px_qa_result_tbl.count + 1;
        px_qa_result_tbl(l_index).error_record_type   := G_REP_QA_TYPE;
        px_qa_result_tbl(l_index).title               := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_REP_NO_EXT_PARTY_T);
        -- Need to verify the qa_code with Sanjay
        px_qa_result_tbl(l_index).qa_code             := G_CHECK_REP_NO_EXT_PARTY;
        px_qa_result_tbl(l_index).message_name        := G_OKC_REP_NO_EXT_PARTY;
        px_qa_result_tbl(l_index).suggestion          := l_OKC_REP_NO_EXT_PARTY_S;
        px_qa_result_tbl(l_index).error_severity      := p_severity;
        px_qa_result_tbl(l_index).problem_short_desc  := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_REP_NO_EXT_PARTY_SD);
        px_qa_result_tbl(l_index).problem_details     := l_OKC_REP_NO_EXT_PARTY;

    END IF;

    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                     'Leaving OKC_REP_QA_CHECK_PVT.check_no_external_party');
    END IF;
    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION , G_MODULE||l_api_name,
             'Leaving OKC_REP_QA_CHECK_PVT.check_no_external_party with G_EXC_ERROR');
        END IF;
        x_return_status := G_RET_STS_ERROR;
        --close cursors
        IF (party_csr%ISOPEN) THEN
          CLOSE party_csr ;
        END IF;
        IF (is_acq_csr%ISOPEN) THEN
          CLOSE is_acq_csr ;

        END IF;



        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,G_MODULE||l_api_name,
             'Leaving OKC_REP_QA_CHECK_PVT.check_no_external_party with G_EXC_UNEXPECTED_ERROR');
        END IF;
        x_return_status := G_RET_STS_UNEXP_ERROR;
        --close cursors

        IF (party_csr%ISOPEN) THEN
          CLOSE party_csr ;
        END IF;
        IF (is_acq_csr%ISOPEN) THEN
          CLOSE is_acq_csr ;
        END IF;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

     WHEN OTHERS THEN

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 G_MODULE || l_api_name,
                 'Leaving OKC_REP_QA_CHECK_PVT.check_no_external_party because of EXCEPTION: ' || sqlerrm);
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        --close cursors
        IF (party_csr%ISOPEN) THEN
          CLOSE party_csr ;
        END IF;
         IF (is_acq_csr%ISOPEN) THEN
          CLOSE is_acq_csr ;
        END IF;

        x_return_status := G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
    END check_no_external_party;



-- Start of comments
--API name      : check_no_eff_date
--Type          : Private.
--Function      : This procedure checks for the presence of effective date in a given contract.
--              : and modifies px_qa_result_tbl table of records that contains validation
--              : errors and warnings
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_effective_date         IN NUMBER       Required
--                   Effective date of the contract to be checked
--              : p_severity            IN VARCHAR2     Required
--                   Severity level for this check. Possible values are ERROR, WARNING.
--INOUT         : px_qa_result_tbl
--                The table of records that contains validation errors and warnings
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
   PROCEDURE check_no_eff_date (
      p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2,
      p_effective_date      IN  DATE,
	  p_contract_id IN NUMBER DEFAULT NULL,
      p_severity            IN VARCHAR2,
      px_qa_result_tbl   IN OUT NOCOPY OKC_TERMS_QA_PVT.qa_result_tbl_type,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2
    ) IS

     l_api_version                   CONSTANT NUMBER := 1;
     l_api_name                      CONSTANT VARCHAR2(30) := 'check_no_eff_date';
     l_index                         PLS_INTEGER := 0;

	  l_OKC_REP_NO_EFF_DATE VARCHAR2(2000) ;
	  l_OKC_REP_NO_EFF_DATE_S VARCHAR2(2000) ;

	  l_resolved_msg_name VARCHAR2(30);
      l_resolved_token VARCHAR2(30);

	  l_doc_type varchar2(60);

      CURSOR c_get_doctype is
	  SELECT CONTRACT_TYPE
	  FROM okc_rep_contracts_all
	  WHERE CONTRACT_id = p_contract_id;



    BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                     'Entered OKC_REP_QA_CHECK_PVT.check_no_eff_date ');
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                     'Effective Date is:  ' || p_effective_date);
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                     'Severity level is:  ' || p_severity);
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

	open c_get_doctype;
	fetch c_get_doctype into l_doc_type;
	close c_get_doctype;

	l_resolved_token := OKC_API.resolve_hdr_token(l_doc_type);

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Check for effective date
    IF (p_effective_date IS NULL) THEN
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, G_MODULE||l_api_name,
                     'Effective Date is NULL');
        END IF;
		l_resolved_msg_name := OKC_API.resolve_message(G_OKC_REP_NO_EFF_DATE,l_doc_type);


    	l_OKC_REP_NO_EFF_DATE := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, l_resolved_msg_name, p_token1 => 'HDR_TOKEN',
                                                    p_token1_value => l_resolved_token) ;

		l_resolved_msg_name := OKC_API.resolve_message(G_OKC_REP_NO_EFF_DATE_S,l_doc_type);


    	l_OKC_REP_NO_EFF_DATE_S := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, l_resolved_msg_name, p_token1 => 'HDR_TOKEN',
                                                    p_token1_value => l_resolved_token) ;

        l_index := px_qa_result_tbl.count + 1;
        px_qa_result_tbl(l_index).error_record_type   := G_REP_QA_TYPE;
        px_qa_result_tbl(l_index).title               := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_REP_NO_EFF_DATE_T);
        -- Need to verify the qa_code with Sanjay
        px_qa_result_tbl(l_index).qa_code             := G_CHECK_REP_NO_EFF_DATE;
        px_qa_result_tbl(l_index).message_name        := G_OKC_REP_NO_EFF_DATE;
        px_qa_result_tbl(l_index).suggestion          := l_OKC_REP_NO_EFF_DATE_S;
        px_qa_result_tbl(l_index).error_severity      := p_severity;
        px_qa_result_tbl(l_index).problem_short_desc  := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_REP_NO_EFF_DATE_SD);
        px_qa_result_tbl(l_index).problem_details     := l_OKC_REP_NO_EFF_DATE;

    END IF;  -- p_effective_date IS NULL

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                     'Leaving OKC_REP_QA_CHECK_PVT.check_no_eff_date');
    END IF;
    EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION , G_MODULE||l_api_name,
             'Leaving OKC_REP_QA_CHECK_PVT.check_no_eff_date with G_EXC_ERROR');
        END IF;
        x_return_status := G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,G_MODULE||l_api_name,
             'Leaving OKC_REP_QA_CHECK_PVT.check_no_eff_date with G_EXC_UNEXPECTED_ERROR');
        END IF;

        x_return_status := G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

     WHEN OTHERS THEN

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 G_MODULE || l_api_name,
                 'Leaving OKC_REP_QA_CHECK_PVT.check_no_eff_date because of EXCEPTION: ' || sqlerrm);
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        x_return_status := G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
    END check_no_eff_date;


-- Start of comments
--API name      : check_expiry_check
--Type          : Private.
--Function      : This procedure checks if the document has expired already at the time of validating/submitting for approval
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_expiration_date         IN NUMBER       Required
--                   Expiration date of the contract to be checked
--              : p_severity            IN VARCHAR2     Required
--                   Severity level for this check. Possible values are ERROR, WARNING.
--INOUT         : px_qa_result_tbl
--                The table of records that contains validation errors and warnings
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments

-- End of comments


   PROCEDURE check_expiry_check (
      p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2,
      p_expiration_date      IN  DATE,
	    p_contract_id IN NUMBER DEFAULT NULL,
      p_severity            IN VARCHAR2,
      px_qa_result_tbl   IN OUT NOCOPY OKC_TERMS_QA_PVT.qa_result_tbl_type,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2
    ) IS

     l_api_version                   CONSTANT NUMBER := 1;
     l_api_name                      CONSTANT VARCHAR2(30) := 'check_expiry_check';
     l_index                         PLS_INTEGER := 0;

	  l_OKC_REP_EXPIRED VARCHAR2(2000) ;
	  l_OKC_REP_EXPIRED_SD VARCHAR2(2000) ;

	  l_resolved_msg_name VARCHAR2(30);
    l_resolved_token VARCHAR2(30);

	  l_doc_type varchar2(60);

    CURSOR c_get_doctype is
	  SELECT CONTRACT_TYPE
	  FROM okc_rep_contracts_all
	  WHERE CONTRACT_id = p_contract_id;



    BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                     'Entered OKC_REP_QA_CHECK_PVT.check_expiry_check ');
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                     'Expiration Date is:  ' || p_expiration_date);
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                     'Severity level is:  ' || p_severity);
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

	open c_get_doctype;
	fetch c_get_doctype into l_doc_type;
	close c_get_doctype;

	l_resolved_token := OKC_API.resolve_hdr_token(l_doc_type);

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Check for effective date
    IF (p_expiration_date <= SYSDATE ) THEN
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, G_MODULE||l_api_name,
                     'Contract expired');
        END IF;

    l_resolved_msg_name := OKC_API.resolve_message(G_OKC_REP_EXPIRED,l_doc_type);


    	l_OKC_REP_EXPIRED := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, l_resolved_msg_name, p_token1 => 'HDR_TOKEN',
                                                    p_token1_value => l_resolved_token) ;

		l_resolved_msg_name := OKC_API.resolve_message(G_OKC_REP_EXPIRED_SD,l_doc_type);


    	l_OKC_REP_EXPIRED_SD := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, l_resolved_msg_name, p_token1 => 'HDR_TOKEN',
                                                    p_token1_value => l_resolved_token) ;

        l_index := px_qa_result_tbl.count + 1;
        px_qa_result_tbl(l_index).error_record_type   := G_REP_QA_TYPE;
        px_qa_result_tbl(l_index).title               := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_REP_EXPIRED_T);
        px_qa_result_tbl(l_index).qa_code             := G_CHECK_REP_EXPIRED;
        px_qa_result_tbl(l_index).message_name        := G_OKC_REP_EXPIRED;
        px_qa_result_tbl(l_index).suggestion          := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_REP_EXPIRED_S);
        px_qa_result_tbl(l_index).error_severity      := p_severity;
        px_qa_result_tbl(l_index).problem_short_desc  := l_OKC_REP_EXPIRED_SD;
        px_qa_result_tbl(l_index).problem_details     := l_OKC_REP_EXPIRED;

    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                     'Leaving OKC_REP_QA_CHECK_PVT.check_expiry_check');
    END IF;
    EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION , G_MODULE||l_api_name,
             'Leaving OKC_REP_QA_CHECK_PVT.check_expiry_check with G_EXC_ERROR');
        END IF;
        x_return_status := G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,G_MODULE||l_api_name,
             'Leaving OKC_REP_QA_CHECK_PVT.check_expiry_check with G_EXC_UNEXPECTED_ERROR');
        END IF;

        x_return_status := G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

     WHEN OTHERS THEN

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 G_MODULE || l_api_name,
                 'Leaving OKC_REP_QA_CHECK_PVT.check_expiry_check because of EXCEPTION: ' || sqlerrm);
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        x_return_status := G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
    END check_expiry_check;


-- Start of comments
--API name      : validate_contract_type
--Type          : Private.
--Function      : This procedure checks for validity of the contract type being passed as an input param
--              : and modifies px_qa_result_tbl table of records that contains validation
--              : errors and warnings
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_type         IN NUMBER       Required
--                   Contract type to be validated
--              : p_severity            IN VARCHAR2     Required
--                   Severity level for this check. Possible values are ERROR, WARNING.
--INOUT         : px_qa_result_tbl
--                The table of records that contains validation errors and warnings
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
   PROCEDURE validate_contract_type (
      p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2,
      p_contract_type     IN  VARCHAR2,
      p_severity          IN VARCHAR2,
      px_qa_result_tbl    IN OUT NOCOPY OKC_TERMS_QA_PVT.qa_result_tbl_type,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2
    ) IS

     l_api_version                   CONSTANT NUMBER := 1;
     l_api_name                      CONSTANT VARCHAR2(30) := 'validate_contract_type';
     l_index                         PLS_INTEGER := 0;
     l_valid_contract_type_flag      VARCHAR2(1);
     l_contract_type_name            OKC_BUS_DOC_TYPES_TL.NAME%TYPE;

    CURSOR contract_type_csr IS
       SELECT  name, start_date, end_date
       FROM    okc_bus_doc_types_vl
       WHERE   document_type = p_contract_type;
    contract_type_rec       contract_type_csr%ROWTYPE;
    BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                     'Entered OKC_REP_QA_CHECK_PVT.validate_contract_type ');
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                     'Contract type is:  ' || p_contract_type);
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                     'Severity level is:  ' || p_severity);
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
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_valid_contract_type_flag := 'Y';

    OPEN contract_type_csr;
    FETCH contract_type_csr INTO contract_type_rec;
    IF contract_type_csr%NOTFOUND THEN
      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION ,
          G_MODULE||l_api_name, 'Contract Type:  '|| p_contract_type || ' does not exist');
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;   -- contract_type_csr%NOTFOUND
    l_contract_type_name := contract_type_rec.name;
    IF (sysdate BETWEEN nvl(contract_type_rec.start_date, sysdate) AND nvl(contract_type_rec.end_date, sysdate))  THEN
        l_valid_contract_type_flag := 'Y';
    ELSE
        l_valid_contract_type_flag := 'N';
    END IF;
    CLOSE contract_type_csr;

    --Check for contract type
    IF (l_valid_contract_type_flag = 'N') THEN
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, G_MODULE||l_api_name,
                     'Contract Type is invalid');
        END IF;
        l_index := px_qa_result_tbl.count + 1;
        px_qa_result_tbl(l_index).error_record_type   := G_REP_QA_TYPE;
        px_qa_result_tbl(l_index).title               := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_REP_INV_CONTRACT_TYPE_T);
        px_qa_result_tbl(l_index).qa_code             := G_CHECK_REP_INV_CONTRACT_TYPE;
        px_qa_result_tbl(l_index).message_name        := G_OKC_REP_INV_CONTRACT_TYPE;
        -- Bug 4702590. Removed the suggetion message
        --px_qa_result_tbl(l_index).suggestion          := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_REP_INV_CONTRACT_TYPE_S);
        px_qa_result_tbl(l_index).error_severity      := p_severity;
        px_qa_result_tbl(l_index).problem_short_desc  := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_REP_INV_CONTRACT_TYPE_SD);
        px_qa_result_tbl(l_index).problem_details     := OKC_TERMS_UTIL_PVT.Get_Message(
                                                 p_app_name     => G_OKC,
                                                                             p_msg_name     => G_OKC_REP_INV_CONTRACT_TYPE,
                                                                             p_token1       => G_CONTRACT_TYPE_TOKEN,
                                                                             p_token1_value => l_contract_type_name);
    END IF;  -- l_valid_contract_type_flag = 'N'
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                     'Leaving OKC_REP_QA_CHECK_PVT.validate_contract_type');
    END IF;
    EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION , G_MODULE||l_api_name,
             'Leaving OKC_REP_QA_CHECK_PVT.validate_contract_type with G_EXC_ERROR');
        END IF;
        IF (contract_type_csr%ISOPEN) THEN
           CLOSE contract_type_csr ;
        END IF;
        x_return_status := G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,G_MODULE||l_api_name,
             'Leaving OKC_REP_QA_CHECK_PVT.validate_contract_type with G_EXC_UNEXPECTED_ERROR');
        END IF;
        IF (contract_type_csr%ISOPEN) THEN
           CLOSE contract_type_csr ;
        END IF;
        x_return_status := G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

     WHEN OTHERS THEN
         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 G_MODULE || l_api_name,
                 'Leaving OKC_REP_QA_CHECK_PVT.validate_contract_type because of EXCEPTION: ' || sqlerrm);
        END IF;
        IF (contract_type_csr%ISOPEN) THEN
           CLOSE contract_type_csr ;
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        x_return_status := G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
    END validate_contract_type;


-- Start of comments
--API name      : validate_external_party
--Type          : Private.
--Function      : This procedure checks for validity of the external party
--              : and modifies px_qa_result_tbl table of records that contains validation
--              : errors and warnings
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_party_role_code     IN VARCHER       Required
--                   external party role code
--              : p_party_id           IN NUMBER        Required
--                   party id of the external party.
--              : p_severity            IN VARCHAR2     Required
--                   Severity level for this check. Possible values are ERROR, WARNING.
--INOUT         : px_qa_result_tbl
--                The table of records that contains validation errors and warnings
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
   PROCEDURE validate_external_party (
      p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2,
      p_party_role_code   IN  VARCHAR2,
      p_party_id          IN  NUMBER,
      p_severity          IN VARCHAR2,
      px_qa_result_tbl    IN OUT NOCOPY OKC_TERMS_QA_PVT.qa_result_tbl_type,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2
    ) IS

     l_api_version                   CONSTANT NUMBER := 1;
     l_api_name                      CONSTANT VARCHAR2(30) := 'validate_external_party';
     l_index                         PLS_INTEGER := 0;
     l_valid_external_party_flag     VARCHAR2(1);
     l_party_name                    VARCHAR2(450); -- set to 360 in OKC_REP_IMP_PARTIES_T
    -- For HZ_PARTY validation, using document "TCA Usage Guideline" Version 3.0
    CURSOR partner_csr IS
       SELECT  party_name, status
       FROM    hz_parties
       WHERE   party_id = p_party_id
	AND     party_type IN ('ORGANIZATION', 'PERSON');       /*--10334886: Added person party Type*/
    partner_rec       partner_csr%ROWTYPE;

    CURSOR vendor_csr IS   --enabled flag should be Y for active vendors
       SELECT  vendor_name, enabled_flag,
               start_date_active,
               end_date_active
       FROM    po_vendors
       WHERE vendor_id = p_party_id;
    vendor_rec          vendor_csr%ROWTYPE;

    BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                     'Entered OKC_REP_QA_CHECK_PVT.validate_external_party ');
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                     'Party Role Code is:  ' || p_party_role_code);
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                     'Party Id is:  ' || p_party_id);
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
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_valid_external_party_flag := 'Y';

    IF (p_party_role_code = G_PARTY_ROLE_PARTNER OR
        p_party_role_code = G_PARTY_ROLE_CUSTOMER) THEN
      OPEN partner_csr;
      FETCH partner_csr INTO partner_rec;
      IF partner_csr%NOTFOUND THEN
          IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION ,
                    G_MODULE||l_api_name, 'Party with Party Id: '|| p_party_id || ' does not exist');
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;   -- partner_csr%NOTFOUND
        l_party_name := partner_rec.party_name;
        if (partner_rec.status <> 'A')  THEN
          l_valid_external_party_flag := 'N';
        END IF; -- partner_rec.status <> 'A'
        CLOSE partner_csr;
    ELSE
        OPEN vendor_csr;
      FETCH vendor_csr INTO vendor_rec;
      IF vendor_csr%NOTFOUND THEN
          IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION ,
                    G_MODULE||l_api_name, 'Vendor with vendor Id: '|| p_party_id || ' does not exist');
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;   -- vendor_csr%NOTFOUND
        l_party_name := vendor_rec.vendor_name;
        if (vendor_rec.enabled_flag <> 'Y'  AND
            SYSDATE BETWEEN NVL(vendor_rec.start_date_active, SYSDATE - 1) AND NVL(vendor_rec.end_date_active, SYSDATE + 1))  THEN
          l_valid_external_party_flag := 'N';
        END IF;
        CLOSE vendor_csr;
    END IF; -- p_party_role_code = G_PARTY_ROLE_PARTNER

    --Check for external party
    IF (l_valid_external_party_flag = 'N') THEN
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, G_MODULE||l_api_name,
                     'External party is invalid: ' || l_party_name);
        END IF;
        l_index := px_qa_result_tbl.count + 1;
        px_qa_result_tbl(l_index).error_record_type   := G_REP_QA_TYPE;
        px_qa_result_tbl(l_index).title               := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_REP_INV_EXT_PARTY_T);
        px_qa_result_tbl(l_index).qa_code             := G_CHECK_REP_INV_EXT_PARTY;
        px_qa_result_tbl(l_index).message_name        := G_OKC_REP_INV_EXT_PARTY;
        px_qa_result_tbl(l_index).suggestion          := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_REP_INV_EXT_PARTY_S);
        px_qa_result_tbl(l_index).error_severity      := p_severity;
        px_qa_result_tbl(l_index).problem_short_desc  := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_REP_INV_EXT_PARTY_SD);
        px_qa_result_tbl(l_index).problem_details     := OKC_TERMS_UTIL_PVT.Get_Message(
                                                 p_app_name     => G_OKC,
                                                                             p_msg_name     => G_OKC_REP_INV_EXT_PARTY,
                                                                             p_token1       => G_PARTY_NAME_TOKEN,
                                                                             p_token1_value => l_party_name);
    END IF;  -- l_valid_external_party_flag = 'N'

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                     'Leaving OKC_REP_QA_CHECK_PVT.validate_external_party');
    END IF;
    EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION , G_MODULE||l_api_name,
             'Leaving OKC_REP_QA_CHECK_PVT.validate_external_party with G_EXC_ERROR');
        END IF;
        IF (partner_csr%ISOPEN) THEN
           CLOSE partner_csr ;
        END IF;
        IF (vendor_csr%ISOPEN) THEN
           CLOSE vendor_csr ;
        END IF;
        x_return_status := G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,G_MODULE||l_api_name,
             'Leaving OKC_REP_QA_CHECK_PVT.validate_external_party with G_EXC_UNEXPECTED_ERROR');
        END IF;
        IF (partner_csr%ISOPEN) THEN
           CLOSE partner_csr ;
        END IF;
        IF (vendor_csr%ISOPEN) THEN
           CLOSE vendor_csr ;
        END IF;
        x_return_status := G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

     WHEN OTHERS THEN
         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 G_MODULE || l_api_name,
                 'Leaving OKC_REP_QA_CHECK_PVT.validate_external_party because of EXCEPTION: ' || sqlerrm);
        END IF;
        IF (partner_csr%ISOPEN) THEN
           CLOSE partner_csr ;
        END IF;
        IF (vendor_csr%ISOPEN) THEN
           CLOSE vendor_csr ;
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        x_return_status := G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
    END validate_external_party;




-- Start of comments
--API name      : validate_contact
--Type          : Private.
--Function      : This procedure checks for validity of the party contact
--              : and modifies px_qa_result_tbl table of records that contains validation
--              : errors and warnings
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_party_role_code     IN VARCHER       Required
--                   external party role code
--              : p_party_id           IN NUMBER        Required
--                   party id of the external party.
--              : p_contact_id         IN NUMBER        Required
--                   contact id of the party conatct.
--              : p_severity            IN VARCHAR2     Required
--                   Severity level for this check. Possible values are ERROR, WARNING.
--INOUT         : px_qa_result_tbl
--                The table of records that contains validation errors and warnings
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
   PROCEDURE validate_contact (
      p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2,
      p_party_role_code   IN  VARCHAR2,
      p_party_id          IN  NUMBER,
      p_contact_id        IN  NUMBER,
      p_severity          IN VARCHAR2,
      px_qa_result_tbl    IN OUT NOCOPY OKC_TERMS_QA_PVT.qa_result_tbl_type,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2
    ) IS

     l_api_version                   CONSTANT NUMBER := 1;
     l_api_name                      CONSTANT VARCHAR2(30) := 'validate_contact';
     l_index                         PLS_INTEGER := 0;
     l_valid_contact_flag            VARCHAR2(1);
     l_contact_name                  VARCHAR2(450); -- set to 360 in OKC_REP_IMP_PARTIES_T

    CURSOR tca_contact_csr IS
       SELECT hz.party_name contact_name,
              hr.status     relationship_status,
              hr.start_date start_date,
              hr.end_date   end_date
       FROM   hz_parties  hz,
              hz_relationships hr
       WHERE  hr.object_id = p_party_id  -- The party being passsed
       AND    hz.party_id = p_contact_id -- The contact id
       AND    hr.object_type = 'ORGANIZATION'
       AND    hr.object_table_name = 'HZ_PARTIES'
       AND    hr.subject_type = 'PERSON'
       AND    ((hr.relationship_code = 'CONTACT_OF') OR (hr.relationship_code = 'EMPLOYEE_OF'))
       AND    hz.party_id = hr.party_id;

    tca_contact_rec       tca_contact_csr%ROWTYPE;

    CURSOR vendor_contact_csr IS
       SELECT (first_name || ' ' || middle_name || ' ' || last_name)  contact_name,
              inactive_date
       FROM   po_vendor_contacts
       WHERE  vendor_contact_id=p_contact_id;

    vendor_contact_rec          vendor_contact_csr%ROWTYPE;

-- Bug 6598261.Changed per_all_workforce_v to per_workforce_v.

    CURSOR employee_contact_csr IS
      SELECT full_name contact_name
      FROM   per_workforce_v
      WHERE  person_id = p_contact_id;

    CURSOR employee_name_csr IS
      SELECT per.full_name contact_name
      FROM   per_all_people_f per
      WHERE  per.person_id = p_contact_id
      AND    per.effective_start_date = (SELECT MAX(effective_start_date)
                                         FROM   per_all_people_f
                                         WHERE  person_id = per.person_id);


    employee_contact_rec        employee_contact_csr%ROWTYPE;


    BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                     'Entered OKC_REP_QA_CHECK_PVT.validate_contact ');
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                     'Party Role Code is:  ' || p_party_role_code);
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                     'Party Id is:  ' || p_party_id);
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                     'Contact Id is:  ' || p_contact_id);
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
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_valid_contact_flag := 'Y';

    IF ((p_party_role_code = G_PARTY_ROLE_PARTNER) OR (p_party_role_code = G_PARTY_ROLE_CUSTOMER)) THEN

      OPEN tca_contact_csr;
      FETCH tca_contact_csr INTO tca_contact_rec;

      IF tca_contact_csr%NOTFOUND THEN
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION ,
                    G_MODULE||l_api_name, 'Contact with Contact Id: '|| p_contact_id || ' does not exist');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;   -- partner_csr%NOTFOUND

      l_contact_name := tca_contact_rec.contact_name;

      IF ((tca_contact_rec.relationship_status = 'A') AND
         (sysdate BETWEEN nvl(tca_contact_rec.start_date, sysdate) AND nvl(tca_contact_rec.end_date, sysdate)))  THEN  -- Need to check for date as well.
        l_valid_contact_flag := 'Y';
      ELSE
        l_valid_contact_flag := 'N';
      END IF; -- partner_rec.relationship_status = 'A'

      CLOSE tca_contact_csr;

    ELSIF (p_party_role_code = G_PARTY_ROLE_SUPPLIER) THEN -- Vendor  Party Contact

      OPEN vendor_contact_csr;
      FETCH vendor_contact_csr INTO vendor_contact_rec;

      IF vendor_contact_csr%NOTFOUND THEN
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION ,
                  G_MODULE||l_api_name, 'Vendor contact Id: '|| p_contact_id || ' does not exist');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;   -- vendor_contact_csr%NOTFOUND

      l_contact_name := vendor_contact_rec.contact_name;

      IF (vendor_contact_rec.inactive_date <= sysdate)  THEN
        l_valid_contact_flag := 'N';
      END IF; -- vendor_contact_rec.status <> 'A'

      CLOSE vendor_contact_csr;

    ELSE -- Internal Party Contact

      -- Fetch Internal contact record
      OPEN employee_contact_csr;
      FETCH employee_contact_csr INTO employee_contact_rec;

      -- If row doesn't exist then flag the current contact as invalid
      IF employee_contact_csr%NOTFOUND THEN
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION ,
                G_MODULE||l_api_name, 'Contact with Contact Id: '|| p_contact_id || ' does not exist');
        END IF;

        l_valid_contact_flag := 'N';
      END IF;   -- employee_contact_csr%ROWCOUNT <= 0

      l_contact_name := employee_contact_rec.contact_name;

      CLOSE employee_contact_csr;
    END IF; -- p_party_role_code = G_PARTY_ROLE_PARTNER

    -- If the current contact is not valid, then log the error message
    IF (l_valid_contact_flag = 'N') THEN

      -- Get name of the contact
      OPEN employee_name_csr;
      FETCH employee_name_csr INTO l_contact_name;
      CLOSE employee_name_csr;

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, G_MODULE||l_api_name,
                     'Party Contact is invalid: ' || l_contact_name);
        END IF;
        l_index := px_qa_result_tbl.count + 1;
        px_qa_result_tbl(l_index).error_record_type   := G_REP_QA_TYPE;
        px_qa_result_tbl(l_index).title               := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_REP_INV_CONTACT_T);
        px_qa_result_tbl(l_index).qa_code             := G_CHECK_REP_INV_CONTACT;
        px_qa_result_tbl(l_index).message_name        := G_OKC_REP_INV_CONTACT;
        px_qa_result_tbl(l_index).suggestion          := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_REP_INV_CONTACT_S);
        px_qa_result_tbl(l_index).error_severity      := p_severity;
        px_qa_result_tbl(l_index).problem_short_desc  := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_REP_INV_CONTACT_SD);
        px_qa_result_tbl(l_index).problem_details     := OKC_TERMS_UTIL_PVT.Get_Message(
                                                 p_app_name     => G_OKC,
                                                                             p_msg_name     => G_OKC_REP_INV_CONTACT,
                                                                             p_token1       => G_CONTACT_NAME_TOKEN,
                                                                             p_token1_value => l_contact_name);
    END IF; -- _valid_external_party_flag = 'N'

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                     'Leaving OKC_REP_QA_CHECK_PVT.validate_contact');
    END IF;
    EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION , G_MODULE||l_api_name,
             'Leaving OKC_REP_QA_CHECK_PVT.validate_contact with G_EXC_ERROR');
        END IF;
        IF (tca_contact_csr%ISOPEN) THEN
           CLOSE tca_contact_csr ;
        END IF;
        IF (vendor_contact_csr%ISOPEN) THEN
           CLOSE vendor_contact_csr ;
        END IF;
        IF (employee_contact_csr%ISOPEN) THEN
           CLOSE employee_contact_csr ;
        END IF;
        IF (employee_name_csr%ISOPEN) THEN
	   CLOSE employee_name_csr ;
        END IF;
        x_return_status := G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,G_MODULE||l_api_name,
             'Leaving OKC_REP_QA_CHECK_PVT.validate_contact with G_EXC_UNEXPECTED_ERROR');
        END IF;
        IF (tca_contact_csr%ISOPEN) THEN
           CLOSE tca_contact_csr ;
        END IF;
        IF (vendor_contact_csr%ISOPEN) THEN
           CLOSE vendor_contact_csr ;
        END IF;
        IF (employee_contact_csr%ISOPEN) THEN
           CLOSE employee_contact_csr ;
        END IF;
        IF (employee_name_csr%ISOPEN) THEN
	   CLOSE employee_name_csr ;
        END IF;
        x_return_status := G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

     WHEN OTHERS THEN
         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 G_MODULE || l_api_name,
                 'Leaving OKC_REP_QA_CHECK_PVT.validate_contact because of EXCEPTION: ' || sqlerrm);
        END IF;
        IF (tca_contact_csr%ISOPEN) THEN
           CLOSE tca_contact_csr ;
        END IF;
        IF (vendor_contact_csr%ISOPEN) THEN
           CLOSE vendor_contact_csr ;
        END IF;
        IF (employee_contact_csr%ISOPEN) THEN
           CLOSE employee_contact_csr ;
        END IF;
        IF (employee_name_csr%ISOPEN) THEN
	   CLOSE employee_name_csr ;
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        x_return_status := G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
    END validate_contact;





-- Start of comments
--API name      : validate_contact_role
--Type          : Private.
--Function      : This procedure checks for validity of the contract role being passed as an input param.
--              : and modifies px_qa_result_tbl table of records that contains validation
--              : errors and warnings
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contact_role_id         IN NUMBER       Required
--                   Contract Role Id to be validated
--              : p_severity            IN VARCHAR2     Required
--                   Severity level for this check. Possible values are ERROR, WARNING.
--INOUT         : px_qa_result_tbl
--                The table of records that contains validation errors and warnings
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
   PROCEDURE validate_contact_role (
      p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2,
      p_contact_role_id   IN  NUMBER,
      p_severity          IN  VARCHAR2,
      px_qa_result_tbl    IN OUT NOCOPY OKC_TERMS_QA_PVT.qa_result_tbl_type,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2
    ) IS

     l_api_version                   CONSTANT NUMBER := 1;
     l_api_name                      CONSTANT VARCHAR2(30) := 'validate_contact_role';
     l_index                         PLS_INTEGER := 0;
     l_valid_contact_role_flag      VARCHAR2(1);
     l_contact_role_name            OKC_REP_CONTACT_ROLES_TL.NAME%TYPE;

    CURSOR contact_role_csr IS
       SELECT  name, start_date, end_date
       FROM    okc_rep_contact_roles_vl
       WHERE   contact_role_id = p_contact_role_id;
    contact_role_rec       contact_role_csr%ROWTYPE;
    BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                     'Entered OKC_REP_QA_CHECK_PVT.validate_contact_role ');
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                     'Contact Role Id is:  ' || p_contact_role_id);
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                     'Severity level is:  ' || p_severity);
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
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_valid_contact_role_flag := 'Y';

    OPEN contact_role_csr;
    FETCH contact_role_csr INTO contact_role_rec;
    IF contact_role_csr%NOTFOUND THEN
      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION ,
          G_MODULE||l_api_name, 'Contact role with id :  '|| p_contact_role_id || ' does not exist');
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;   -- contact_role_csr%NOTFOUND
    l_contact_role_name := contact_role_rec.name;
    IF (sysdate BETWEEN nvl(contact_role_rec.start_date, sysdate) AND nvl(contact_role_rec.end_date, sysdate))  THEN
        l_valid_contact_role_flag := 'Y';
    ELSE
        l_valid_contact_role_flag := 'N';
    END IF;
    CLOSE contact_role_csr;

    --Check for Contract Role
    IF (l_valid_contact_role_flag = 'N') THEN
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, G_MODULE||l_api_name,
                     'Contract Role is invalid');
        END IF;
        l_index := px_qa_result_tbl.count + 1;
        px_qa_result_tbl(l_index).error_record_type   := G_REP_QA_TYPE;
        px_qa_result_tbl(l_index).title               := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_REP_INV_CONTACT_ROLE_T);
        px_qa_result_tbl(l_index).qa_code             := G_CHECK_REP_INV_CONTACT_ROLE;
        px_qa_result_tbl(l_index).message_name        := G_OKC_REP_INV_CONTACT_ROLE;
        px_qa_result_tbl(l_index).suggestion          := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_REP_INV_CONTACT_ROLE_S);
        px_qa_result_tbl(l_index).error_severity      := p_severity;
        px_qa_result_tbl(l_index).problem_short_desc  := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_REP_INV_CONTACT_ROLE_SD);
        px_qa_result_tbl(l_index).problem_details     := OKC_TERMS_UTIL_PVT.Get_Message(
                                                 p_app_name     => G_OKC,
                                                                             p_msg_name     => G_OKC_REP_INV_CONTACT_ROLE,
                                                                             p_token1       => G_CONTACT_ROLE_TOKEN,
                                                                             p_token1_value => l_contact_role_name);
    END IF;  -- l_valid_contact_role_flag = 'N'
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                     'Leaving OKC_REP_QA_CHECK_PVT.validate_contact_role');
    END IF;
    EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION , G_MODULE||l_api_name,
             'Leaving OKC_REP_QA_CHECK_PVT.validate_contact_role with G_EXC_ERROR');
        END IF;
        IF (contact_role_csr%ISOPEN) THEN
           CLOSE contact_role_csr ;
        END IF;
        x_return_status := G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,G_MODULE||l_api_name,
             'Leaving OKC_REP_QA_CHECK_PVT.validate_contact_role with G_EXC_UNEXPECTED_ERROR');
        END IF;
        IF (contact_role_csr%ISOPEN) THEN
           CLOSE contact_role_csr ;
        END IF;
        x_return_status := G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

     WHEN OTHERS THEN
         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 G_MODULE || l_api_name,
                 'Leaving OKC_REP_QA_CHECK_PVT.validate_contact_role because of EXCEPTION: ' || sqlerrm);
        END IF;
        IF (contact_role_csr%ISOPEN) THEN
           CLOSE contact_role_csr ;
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        x_return_status := G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
  END validate_contact_role;




-- Start of comments
--API name      : validate_risk_event
--Type          : Private.
--Function      : This procedure checks for validity of the risk event being passed as an input param.
--              : and modifies px_qa_result_tbl table of records that contains validation
--              : errors and warnings
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contact_role         IN NUMBER       Required
--                   Contract type to be validated
--              : p_severity            IN VARCHAR2     Required
--                   Severity level for this check. Possible values are ERROR, WARNING.
--INOUT         : px_qa_result_tbl
--                The table of records that contains validation errors and warnings
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
   PROCEDURE validate_risk_event (
      p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2,
      p_risk_event_id     IN  NUMBER,
      p_severity          IN VARCHAR2,
      px_qa_result_tbl    IN OUT NOCOPY OKC_TERMS_QA_PVT.qa_result_tbl_type,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2
    ) IS

     l_api_version                CONSTANT NUMBER := 1;
     l_api_name                   CONSTANT VARCHAR2(30) := 'validate_risk_event';
     l_index                      PLS_INTEGER := 0;
     l_valid_risk_event_flag      VARCHAR2(1);
     l_risk_event_name            OKC_RISK_EVENTS_TL.NAME%TYPE;

    CURSOR risk_event_csr IS
       SELECT  name, start_date, end_date
       FROM    okc_risk_events_vl
       WHERE   risk_event_id = p_risk_event_id;
    risk_event_rec       risk_event_csr%ROWTYPE;
    BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                     'Entered OKC_REP_QA_CHECK_PVT.validate_risk_event ');
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                     'Risk Event Id is:  ' || p_risk_event_id);
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                     'Severity level is:  ' || p_severity);
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
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_valid_risk_event_flag := 'Y';

    OPEN risk_event_csr;
    FETCH risk_event_csr INTO risk_event_rec;
    IF risk_event_csr%NOTFOUND THEN
      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION ,
          G_MODULE||l_api_name, 'Risk Event with id :  '|| p_risk_event_id || ' does not exist');
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;   -- risk_event_csr%NOTFOUND
    l_risk_event_name := risk_event_rec.name;
    IF (sysdate BETWEEN nvl(risk_event_rec.start_date, sysdate) AND nvl(risk_event_rec.end_date, sysdate))  THEN
        l_valid_risk_event_flag := 'Y';
    ELSE
        l_valid_risk_event_flag := 'N';
    END IF;
    CLOSE risk_event_csr;

    --Check for Risk Event
    IF (l_valid_risk_event_flag = 'N') THEN
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, G_MODULE||l_api_name,
                     'Risk Event is invalid');
        END IF;
        l_index := px_qa_result_tbl.count + 1;
        px_qa_result_tbl(l_index).error_record_type   := G_REP_QA_TYPE;
        px_qa_result_tbl(l_index).title               := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_REP_INV_RISK_EVENT_T);
        px_qa_result_tbl(l_index).qa_code             := G_CHECK_REP_INV_RISK_EVENT;
        px_qa_result_tbl(l_index).message_name        := G_OKC_REP_INV_RISK_EVENT;
        px_qa_result_tbl(l_index).suggestion          := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_REP_INV_RISK_EVENT_S);
        px_qa_result_tbl(l_index).error_severity      := p_severity;
        px_qa_result_tbl(l_index).problem_short_desc  := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_REP_INV_RISK_EVENT_SD);
        px_qa_result_tbl(l_index).problem_details     := OKC_TERMS_UTIL_PVT.Get_Message(
                                                 p_app_name     => G_OKC,
                                                                             p_msg_name     => G_OKC_REP_INV_RISK_EVENT,
                                                                             p_token1       => G_RISK_EVENT_TOKEN,
                                                                             p_token1_value => l_risk_event_name);
    END IF;  -- l_valid_risk_event_flag = 'N'
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                     'Leaving OKC_REP_QA_CHECK_PVT.validate_risk_event');
    END IF;
    EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION , G_MODULE||l_api_name,
             'Leaving OKC_REP_QA_CHECK_PVT.validate_risk_event with G_EXC_ERROR');
        END IF;
        IF (risk_event_csr%ISOPEN) THEN
           CLOSE risk_event_csr ;
        END IF;
        x_return_status := G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,G_MODULE||l_api_name,
             'Leaving OKC_REP_QA_CHECK_PVT.validate_risk_event with G_EXC_UNEXPECTED_ERROR');
        END IF;
        IF (risk_event_csr%ISOPEN) THEN
           CLOSE risk_event_csr ;
        END IF;
        x_return_status := G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

     WHEN OTHERS THEN
         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 G_MODULE || l_api_name,
                 'Leaving OKC_REP_QA_CHECK_PVT.validate_risk_event because of EXCEPTION: ' || sqlerrm);
        END IF;
        IF (risk_event_csr%ISOPEN) THEN
           CLOSE risk_event_csr ;
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        x_return_status := G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
    END validate_risk_event;










-- Start of comments
--API name      : validate_repository_for_qa
--Type          : Private.
--Function      : This API performs QA check on a Repository Contract. The API check for:
--                1. Check contract for no external party (Warning)
--                2. Check contract for no effective date (Error)
--                3. Check contract for invalid contract type
--                4. Check contract for invalid external party type
--                5. Check contract for invalid contact
--                6. Check contract for invalid Risk Event
--                7. Check contract for invalid Risk Event
--                8. Calls OKC_DELIVERABLE_PROCESS_PVT.validate_deliverable_for_qa to qa check the
--                   deliverables.
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--              :    Default = FND_API.G_FALSE
--              : p_contract_id         IN NUMBER       Required
--              :     Contract ID of the contract to be QA checked
--              : p_contract_type       IN NUMBER       Required
--              :     Type of the contract to be QA checked
--INOUT         : p_qa_result_tbl      IN OUT
--              :  The table of records that contains validation errors and warnings
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
-- Note         :
-- End of comments

PROCEDURE validate_repository_for_qa (
                        p_api_version     IN    NUMBER,
                        p_init_msg_list   IN    VARCHAR2,
                        p_contract_type   IN    VARCHAR2,
                        p_contract_id     IN    NUMBER,
                        p_qa_result_tbl   IN OUT NOCOPY    OKC_TERMS_QA_PVT.qa_result_tbl_type,
                        x_msg_data    OUT NOCOPY VARCHAR2,
                        x_msg_count     OUT NOCOPY NUMBER,
                        x_return_status   OUT NOCOPY VARCHAR2)
  IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_repository_for_qa';
    -- Contract cursor
    CURSOR contract_csr IS
        SELECT contract_effective_date
        FROM okc_rep_contracts_all
        WHERE contract_id = p_contract_id;
    contract_rec       contract_csr%ROWTYPE;

    CURSOR contract_exp_csr IS
        SELECT contract_expiration_date
        FROM okc_rep_contracts_all
        WHERE contract_id = p_contract_id;
    contract_exp_rec       contract_exp_csr%ROWTYPE;

    -- Contract parties cursor, used for validating parties
    CURSOR party_csr IS
        SELECT party_id, party_role_code
        FROM okc_rep_contract_parties
        WHERE contract_id = p_contract_id
        AND party_role_code <> 'INTERNAL_ORG';
    party_rec          party_csr%ROWTYPE;
  -- Contract contacts cursor, used for validating contacts, contact roles
    CURSOR party_contact_csr IS
        SELECT party_id, party_role_code, contact_id, contact_role_id
        FROM okc_rep_party_contacts
        WHERE contract_id = p_contract_id;
    party_contact_rec          party_contact_csr%ROWTYPE;
    -- Contract risks cursor, used for validating risk events
    CURSOR risk_csr IS
        SELECT risk_event_id
        FROM okc_contract_risks
        WHERE business_document_type = p_contract_type
        AND business_document_id = p_contract_id;
    risk_rec          risk_csr%ROWTYPE;

   BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
           'Entered validate_repository_for_qa');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
           'Contract Type is: ' || p_contract_type);
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
           'Contract Id is: ' || p_contract_id);
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
    x_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                             x_return_status);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --Check for external party
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
       'Calling  OKC_REP_QA_CHECK_PVT.check_no_exteral_party() API');
    END IF;
    check_no_external_party (
          p_api_version      => 1,
          p_init_msg_list => FND_API.G_FALSE,
          p_contract_id      => p_contract_id,
          p_severity         => G_QA_STS_WARNING,
          px_qa_result_tbl   => p_qa_result_tbl,
          x_msg_data         => x_msg_data,
          x_msg_count        => x_msg_count,
          x_return_status    => x_return_status
    );
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT , G_MODULE||l_api_name,
        'Completed OKC_REP_QA_CHECK_PVT.check_no_exteral_party with returned status: ' || x_return_status);
    END IF;
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Get effective_date column
    OPEN contract_csr;
    FETCH contract_csr into contract_rec;
    IF(contract_csr%NOTFOUND) THEN
               RAISE NO_DATA_FOUND;
    END IF;
    -- Log effective date columns
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,
                     G_MODULE||l_api_name,'Contract Effective Date is : '
                     || contract_rec.contract_effective_date);
    END IF;
    --Check for null effective date
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
     'Calling  OKC_REP_QA_CHECK_PVT.check_no_eff_date() API');
    END IF;
    check_no_eff_date (
      p_api_version      => 1,
      p_init_msg_list => FND_API.G_FALSE,
      p_effective_date   => contract_rec.contract_effective_date,
	  p_contract_id      => p_contract_id,
      p_severity         => G_QA_STS_ERROR,
      px_qa_result_tbl   => p_qa_result_tbl,
      x_msg_data         => x_msg_data,
      x_msg_count        => x_msg_count,
      x_return_status    => x_return_status);

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT , G_MODULE||l_api_name,
        'Completed OKC_REP_QA_CHECK_PVT.check_no_eff_date with returned status: ' || x_return_status);
    END IF;
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Get expiration_date column
    OPEN contract_exp_csr;
    FETCH contract_exp_csr into contract_exp_rec;
    IF(contract_exp_csr%NOTFOUND) THEN
               RAISE NO_DATA_FOUND;
    END IF;
    -- Log expiration date columns
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,
                     G_MODULE||l_api_name,'Contract Expiration Date is : '
                     || contract_exp_rec.contract_expiration_date);
    END IF;
    --Check for expiry
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
     'Calling  OKC_REP_QA_CHECK_PVT.check_expiry_check() API');
    END IF;


    check_expiry_check (
      p_api_version      => 1,
      p_init_msg_list => FND_API.G_FALSE,
      p_expiration_date   => contract_exp_rec.contract_expiration_date,
	    p_contract_id      => p_contract_id,
      p_severity         => G_QA_STS_ERROR,
      px_qa_result_tbl   => p_qa_result_tbl,
      x_msg_data         => x_msg_data,
      x_msg_count        => x_msg_count,
      x_return_status    => x_return_status);





    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT , G_MODULE||l_api_name,
        'Completed OKC_REP_QA_CHECK_PVT.check_expiry_check with returned status: ' || x_return_status);
    END IF;
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --Validate contract type
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
       'Calling  OKC_REP_QA_CHECK_PVT.validate_contract_type() API');
    END IF;
    validate_contract_type (
          p_api_version      => 1,
          p_init_msg_list => FND_API.G_FALSE,
          p_contract_type      => p_contract_type,
          p_severity         => G_QA_STS_WARNING,
          px_qa_result_tbl   => p_qa_result_tbl,
          x_msg_data         => x_msg_data,
          x_msg_count        => x_msg_count,
          x_return_status    => x_return_status
    );
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT , G_MODULE||l_api_name,
        'Completed OKC_REP_QA_CHECK_PVT.validate_contract_type with returned status: ' || x_return_status);
    END IF;
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

  -- Validate Parties
  -- Loop through all the external parties and check if these are still valid.
  FOR party_rec IN party_csr LOOP
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
              'Calling  OKC_REP_QA_CHECK_PVT.validate_external_party() API');
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
              'Party Id is: '|| party_rec.party_id);
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
              'Party role code  is: '|| party_rec.party_role_code);
      END IF;
      validate_external_party (
          p_api_version      => 1,
          p_init_msg_list    => FND_API.G_FALSE,
          p_party_role_code  => party_rec.party_role_code,
          p_party_id         => party_rec.party_id,
          p_severity         => G_QA_STS_WARNING,
          px_qa_result_tbl   => p_qa_result_tbl,
          x_msg_data         => x_msg_data,
          x_msg_count        => x_msg_count,
          x_return_status    => x_return_status
      );
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT , G_MODULE||l_api_name,
        'Completed OKC_REP_QA_CHECK_PVT.validate_external_party with returned status: ' || x_return_status);
      END IF;
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
  END LOOP;

  -- Validate contacts and contact roles
  -- Loop through all the external contacts and check if these are still valid.
  FOR party_contact_rec IN party_contact_csr LOOP
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
              'Calling  OKC_REP_QA_CHECK_PVT.validate_contact() and validate_contact_role() APIs');
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
              'Party Id is: '|| party_contact_rec.party_id);
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
              'Party role code  is: '|| party_contact_rec.party_role_code);
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
              'Contact Id is: '|| party_contact_rec.contact_id);
      END IF;
      -- Validate contact
      validate_contact (
          p_api_version      => 1,
          p_init_msg_list    => FND_API.G_FALSE,
          p_party_role_code  => party_contact_rec.party_role_code,
          p_party_id         => party_contact_rec.party_id,
          p_contact_id       => party_contact_rec.contact_id,
          p_severity         => G_QA_STS_WARNING,
          px_qa_result_tbl   => p_qa_result_tbl,
          x_msg_data         => x_msg_data,
          x_msg_count        => x_msg_count,
          x_return_status    => x_return_status
      );
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT , G_MODULE||l_api_name,
        'Completed OKC_REP_QA_CHECK_PVT.validate_contact with returned status: ' || x_return_status);
      END IF;
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      -- Validate contact role
      validate_contact_role (
          p_api_version      => 1,
          p_init_msg_list    => FND_API.G_FALSE,
          p_contact_role_id  => party_contact_rec.contact_role_id,
          p_severity         => G_QA_STS_WARNING,
          px_qa_result_tbl   => p_qa_result_tbl,
          x_msg_data         => x_msg_data,
          x_msg_count        => x_msg_count,
          x_return_status    => x_return_status
      );
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT , G_MODULE||l_api_name,
        'Completed OKC_REP_QA_CHECK_PVT.validate_contact_role with returned status: ' || x_return_status);
      END IF;
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
  END LOOP;


  -- Validate Parties
  -- Loop through all contract risk events and check if these are still valid.
  FOR risk_rec IN risk_csr LOOP
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
              'Calling  OKC_REP_QA_CHECK_PVT.validate_risk_event() API');
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
              'Risk Event Id is: '|| risk_rec.risk_event_id);
      END IF;
      validate_risk_event (
          p_api_version      => 1,
          p_init_msg_list    => FND_API.G_FALSE,
          p_risk_event_id    => risk_rec.risk_event_id,
          p_severity         => G_QA_STS_WARNING,
          px_qa_result_tbl   => p_qa_result_tbl,
          x_msg_data         => x_msg_data,
          x_msg_count        => x_msg_count,
          x_return_status    => x_return_status
      );
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT , G_MODULE||l_api_name,
        'Completed OKC_REP_QA_CHECK_PVT.validate_risk_event with returned status: ' || x_return_status);
      END IF;
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
  END LOOP;

    -- Close all cursors.
    CLOSE contract_csr;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,
               G_MODULE||l_api_name,'leaving OKC_REP_QA_CHECK_PVT.validate_repository_for_qa');
    END IF;

    EXCEPTION
           WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION , G_MODULE||l_api_name,
             'Leaving OKC_REP_QA_CHECK_PVT.validate_repository_for_qa with G_EXC_ERROR');
        END IF;
        x_return_status := G_RET_STS_ERROR;
        --close cursors
        IF (contract_csr%ISOPEN) THEN
          CLOSE contract_csr ;
        END IF;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,G_MODULE||l_api_name,
             'Leaving OKC_REP_QA_CHECK_PVT.validate_repository_for_qa with G_EXC_UNEXPECTED_ERROR');
        END IF;
        x_return_status := G_RET_STS_UNEXP_ERROR;
        --close cursors
        IF (contract_csr%ISOPEN) THEN
          CLOSE contract_csr ;
        END IF;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

     WHEN OTHERS THEN
         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 G_MODULE || l_api_name,
                 'Leaving OKC_REP_QA_CHECK_PVT.validate_repository_for_qa because of EXCEPTION: ' || sqlerrm);
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        --close cursors
        IF (contract_csr%ISOPEN) THEN
          CLOSE contract_csr ;
        END IF;
        x_return_status := G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

  END validate_repository_for_qa;



-- Start of comments
--API name      : perform_contract_qa_check
--Type          : Private.
--Function      : This API performs QA check on a Repository Contract. The API check for:
--                1. Calls OKC_REP_QA_CHECK_PVT.validate_repository_for_qa() to qa check
--                   repository contracts.
--                2. Calls OKC_DELIVERABLE_PROCESS_PVT.validate_deliverable_for_qa to check the
--                   deliverables.
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_id         IN NUMBER       Required
--                   Contract ID of the contract to be QA checked
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--              : x_qa_return_status    OUT  VARCHAR2 (1)
--                    QA Check return status. Possible values are S, W, E
--              : x_sequence_id         OUT  NUMBER
--                    Sequence id of the qa check errors in OKC_QA_ERRORS_T table
-- Note         :
-- End of comments

  PROCEDURE perform_contract_qa_check (
       p_api_version           IN NUMBER,
       p_init_msg_list         IN VARCHAR2,
       p_contract_id           IN NUMBER,
       x_msg_count             OUT NOCOPY NUMBER,
       x_msg_data              OUT NOCOPY VARCHAR2,
       x_return_status         OUT NOCOPY VARCHAR2,
       x_qa_return_status      OUT NOCOPY VARCHAR2,
       x_sequence_id           OUT NOCOPY NUMBER)

  IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'perform_contract_qa_check';

    l_qa_result_tbl                OKC_TERMS_QA_PVT.qa_result_tbl_type;
    l_bus_doc_date_events_tbl      EVENT_TBL_TYPE;
    l_error_found                  Boolean := FALSE;
    l_warning_found                Boolean := FALSE;

    CURSOR contract_csr IS
    SELECT contract_type, contract_expiration_date, contract_effective_date
    FROM okc_rep_contracts_all
    WHERE contract_id = p_contract_id;

  contract_rec       contract_csr%ROWTYPE;

    BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
           'Entered perform_contract_qa_check');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
           'Contract Id is: ' || p_contract_id);
    END IF;
    x_qa_return_status := G_QA_STS_SUCCESS;
    x_return_status := G_RET_STS_SUCCESS;
    x_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                             x_return_status);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Get effective dates and contract_type of the contract.
    OPEN contract_csr;
    FETCH contract_csr INTO contract_rec;
    IF(contract_csr%NOTFOUND) THEN
          IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION ,
                    G_MODULE||l_api_name,
                                 'Invalid Contract Id: '|| p_contract_id);
          END IF;
          Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_INVALID_CONTRACT_ID_MSG,
                            p_token1       => G_CONTRACT_ID_TOKEN,
                            p_token1_value => to_char(p_contract_id));
          RAISE FND_API.G_EXC_ERROR;
          -- RAISE NO_DATA_FOUND;
    END IF;


    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
           'Contract Type is: ' || contract_rec.contract_type);
    END IF;

	-- Repository Enhancement 12.1 (For Validate Action)

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
       'Calling  OKC_TERMS_QA_GRP.QA_Doc API');
    END IF;


	FND_MSG_PUB.initialize;
	OKC_TERMS_QA_GRP.QA_Doc (p_api_version     => 1,
			    p_init_msg_list   =>     'T',
			    x_return_status    =>    x_return_status,
		                   x_msg_data         =>    x_msg_data,
			    x_msg_count        =>    x_msg_count,
			    p_qa_mode   =>      G_NORMAL_QA,
			    p_doc_type   =>      contract_rec.contract_type,
			    p_doc_id    =>     p_contract_id,
			    x_qa_result_tbl =>       l_qa_result_tbl,
			    x_qa_return_status =>    x_qa_return_status);

  	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT , G_MODULE||l_api_name,
        'Completed OKC_TERMS_QA_GRP.QA_Doc with returned status: ' || x_return_status);
	END IF;

	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
	-- Repository Enhancement 12.1 Ends (For Validate Action)

    -- Make call for Repository QA check
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
       'Calling  OKC_REP_QA_CHECK_PVT.validate_repository_for_qa() API');
    END IF;
    validate_repository_for_qa (
                                       p_api_version     => 1,
                                       p_init_msg_list   => FND_API.G_FALSE,
                                       p_contract_type   => contract_rec.contract_type,
                                       p_contract_id     => p_contract_id,
                                       p_qa_result_tbl   => l_qa_result_tbl,
                                       x_msg_data        => x_msg_data,
                                       x_msg_count       => x_msg_count,
                                       x_return_status   => x_return_status);
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT , G_MODULE||l_api_name,
        'Completed OKC_REP_QA_CHECK_PVT.validate_repository_for_qa with returned status: ' || x_return_status);
    END IF;
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Make call for deliverables QA check

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
       'Calling  OKC_DELIVERABLE_PROCESS_PVT.validate_deliverable_for_qa() API');
    END IF;
    l_bus_doc_date_events_tbl(1).event_code := G_CONTRACT_EFFECTIVE_EVENT;
    l_bus_doc_date_events_tbl(1).event_date := contract_rec.contract_effective_date;

    l_bus_doc_date_events_tbl(2).event_code := G_CONTRACT_EXPIRE_EVENT;
    l_bus_doc_date_events_tbl(2).event_date := contract_rec.contract_expiration_date;

    OKC_DELIVERABLE_PROCESS_PVT.validate_deliverable_for_qa (
                                       p_api_version     => 1,
                                       p_init_msg_list   => FND_API.G_FALSE,
                                       p_doc_type        => contract_rec.contract_type,
                                       p_doc_id          => p_contract_id,
                                       p_mode            => G_NORMAL_QA,
                                       p_bus_doc_date_events_tbl => l_bus_doc_date_events_tbl,
                                       p_qa_result_tbl   => l_qa_result_tbl,
                                       x_msg_data        => x_msg_data,
                                       x_msg_count       => x_msg_count,
                                       x_return_status   => x_return_status,
                                       x_qa_return_status => x_qa_return_status);

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT , G_MODULE||l_api_name,
        'Completed OKC_DELIVERABLE_PROCESS_PVT.validate_deliverable_for_qa with returned status: ' || x_return_status);
    END IF;
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

      --------------------------------------------
        -- VALIDATIONS are done for Repository and Deliverables.
        -- Now insert into Temp table.
      --------------------------------------------
        -- Save result from PLSQL table into DB table
      --------------------------------------------
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,
                     G_MODULE||l_api_name,'1015: Save result from PLSQL table into DB table');
      END IF;


      -- After calling the validation APIs we need to find out about the x_qa_return_status. We should loop through
      -- this only if we get
      IF l_qa_result_tbl.COUNT > 0 THEN
          FOR i IN l_qa_result_tbl.FIRST..l_qa_result_tbl.LAST LOOP
              IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Updating pl/sql table record: ' || i);
              END IF;
              l_qa_result_tbl(i).error_record_type_name := okc_util.decode_lookup('OKC_ERROR_RECORD_TYPE',l_qa_result_tbl(i).error_record_type);
              l_qa_result_tbl(i).error_severity_name    := okc_util.decode_lookup('OKC_QA_SEVERITY',l_qa_result_tbl(i).error_severity);
              l_qa_result_tbl(i).document_type := contract_rec.contract_type;
              l_qa_result_tbl(i).document_id := p_contract_id;
              l_qa_result_tbl(i).creation_date := sysdate;
              IF l_qa_result_tbl(i).error_severity = G_QA_STS_ERROR THEN
                  l_error_found := true;
              END IF;
              IF l_qa_result_tbl(i).error_severity = G_QA_STS_WARNING THEN
                  l_warning_found := true;
              END IF;

          END LOOP;
          IF l_error_found THEN
                x_qa_return_status := G_QA_STS_ERROR;
          ELSIF l_warning_found THEN
                x_qa_return_status := G_QA_STS_WARNING;
          END IF;
      END IF;  -- l_qa_result_tbl.COUNT > 0 THEN

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'Calling OKC_TERMS_QA_PVT.Log_QA_Messages');
      END IF;
      -- Load eror in the DB table
      OKC_TERMS_QA_PVT.Log_QA_Messages(
            x_return_status    => x_return_status,

            p_qa_result_tbl    => l_qa_result_tbl,
            x_sequence_id      => x_sequence_id
      );
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'Completed OKC_TERMS_QA_PVT.Log_QA_Messages');
      END IF;
      --------------------------------------------
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
      END IF;
      --------------------------------------------

      -- We should commit work now
      COMMIT WORK;

    CLOSE contract_csr;

    -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,
               G_MODULE||l_api_name,'Leaving OKC_REP_QA_CHECK_PVT.perform_contract_qa_check');
      END IF;

     EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN

       IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,
              G_MODULE||l_api_name,'Leaving OKC_REP_QA_CHECK_PVT.perform_contract_qa_check with G_EXC_ERROR');
       END IF;
       --close cursors
       IF (contract_csr%ISOPEN) THEN
          CLOSE contract_csr ;
       END IF;
       x_return_status := G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

       IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,
              G_MODULE||l_api_name,'Leaving OKC_REP_QA_CHECK_PVT.perform_contract_qa_check with G_EXC_UNEXPECTED_ERROR');
       END IF;
       --close cursors
       IF (contract_csr%ISOPEN) THEN
          CLOSE contract_csr ;
       END IF;
       x_return_status := G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    WHEN OTHERS THEN

       IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,
             G_MODULE||l_api_name,'Leaving OKC_REP_QA_CHECK_PVT.perform_contract_qa_check with OTHERS EXCEPTION');
       END IF;
      --close cursors
       IF (contract_csr%ISOPEN) THEN
          CLOSE contract_csr ;
       END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

  END perform_contract_qa_check;


-- Start of comments
--API name      : insert_deliverables_qa_check_list
--Type          : Private.
--Function      : This API inserts QA check list of Deliverables for the specified
--                Contract Type into the table OKC_DOC_QA_LISTS
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Required
--              : p_contract_type       IN VARCHAR2       Required
--                   Contract Type for which the QA checkes to be added
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
-- Note         :
-- End of comments

  PROCEDURE insert_deliverables_qa_checks (
             p_api_version           IN NUMBER,
             p_init_msg_list         IN VARCHAR2,
             p_contract_type         IN VARCHAR2,
             x_msg_count             OUT NOCOPY NUMBER,
             x_msg_data              OUT NOCOPY VARCHAR2,
             x_return_status         OUT NOCOPY VARCHAR2)
  IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'insert_deliverables_qa_checks';
    l_okc_doc_qa_lists_tbl         okc_doc_qa_lists_tbl_type;
    l_user_id                      FND_USER.USER_ID%TYPE;

  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
         'Entered insert_deliverables_qa_checks');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
         'Contract Type is: ' || p_contract_type);
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

    -- Initialize the Deliverables QA Check table of records
    l_okc_doc_qa_lists_tbl(1).qa_code := 'CHECK_AMENDMENT';
    l_okc_doc_qa_lists_tbl(1).severity_flag := 'W';
    l_okc_doc_qa_lists_tbl(1).enable_qa_yn := 'N';

    l_okc_doc_qa_lists_tbl(2).qa_code := 'CHECK_NOTIFICATIONS';
    l_okc_doc_qa_lists_tbl(2).severity_flag := 'W';
    l_okc_doc_qa_lists_tbl(2).enable_qa_yn := 'Y';

    l_okc_doc_qa_lists_tbl(3).qa_code := 'CHECK_BUYER_CONTACT';
    l_okc_doc_qa_lists_tbl(3).severity_flag := 'E';
    l_okc_doc_qa_lists_tbl(3).enable_qa_yn := 'Y';

    l_okc_doc_qa_lists_tbl(4).qa_code := 'CHECK_SUPPLIER_CONTACT';
    l_okc_doc_qa_lists_tbl(4).severity_flag := 'E';
    l_okc_doc_qa_lists_tbl(4).enable_qa_yn := 'Y';

    l_okc_doc_qa_lists_tbl(5).qa_code := 'CHECK_DUE_DATES';
    l_okc_doc_qa_lists_tbl(5).severity_flag := 'E';
    l_okc_doc_qa_lists_tbl(5).enable_qa_yn := 'Y';

    l_okc_doc_qa_lists_tbl(6).qa_code := 'CHECK_DELIVERABLES_VAR_USAGE';
    l_okc_doc_qa_lists_tbl(6).severity_flag := 'W';
    l_okc_doc_qa_lists_tbl(6).enable_qa_yn := 'N';

    l_okc_doc_qa_lists_tbl(7).qa_code := 'CHECK_INTERNAL_CONTACT_VALID';
    l_okc_doc_qa_lists_tbl(7).severity_flag := 'W';
    l_okc_doc_qa_lists_tbl(7).enable_qa_yn := 'Y';

    l_okc_doc_qa_lists_tbl(8).qa_code := 'CHECK_EXTERNAL_PARTY_EXISTS';
    l_okc_doc_qa_lists_tbl(8).severity_flag := 'E';
    l_okc_doc_qa_lists_tbl(8).enable_qa_yn := 'Y';

    l_user_id := FND_GLOBAL.user_id();

    FOR i IN l_okc_doc_qa_lists_tbl.FIRST..l_okc_doc_qa_lists_tbl.LAST LOOP

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
        'Inserting pl/sql table record: ' || i);
      END IF;

      insert into OKC_DOC_QA_LISTS(
        QA_CODE,
        DOCUMENT_TYPE,
        SEVERITY_FLAG,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        ENABLE_QA_YN)
      values(
        l_okc_doc_qa_lists_tbl(i).qa_code,
        p_contract_type,
        l_okc_doc_qa_lists_tbl(i).severity_flag,
        1,
        l_user_id,
        sysdate,
        l_user_id,
        sysdate,
        l_okc_doc_qa_lists_tbl(i).enable_qa_yn);

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, g_module || l_api_name,
        'After inserting a row into OKC_DOC_QA_LISTS');
      END IF;

    END LOOP;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                      'Leaving OKC_REP_QA_CHECK_PVT.insert_deliverables_qa_checks');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,
                        'Leaving OKC_REP_QA_CHECK_PVT.insert_deliverables_qa_checks with G_EXC_ERROR');
      END IF;

      x_return_status := G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,
                       'Leaving OKC_REP_QA_CHECK_PVT.insert_deliverables_qa_checks with G_EXC_UNEXPECTED_ERROR');
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
      );

    WHEN OTHERS THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,
                       'Leaving OKC_REP_QA_CHECK_PVT.insert_deliverables_qa_checks with  OTHERS EXCEPTION');
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

      Okc_Api.Set_Message(p_app_name       => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
      );

  END insert_deliverables_qa_checks;

END OKC_REP_QA_CHECK_PVT;

/
