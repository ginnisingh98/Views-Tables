--------------------------------------------------------
--  DDL for Package Body OKL_SEC_AGREEMENT_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SEC_AGREEMENT_WF" AS
/* $Header: OKLRZWFB.pls 120.4.12010000.3 2008/10/03 19:22:55 rkuttiya ship $ */
----------------------------------------------------------------------------
-- Global Message Constants
----------------------------------------------------------------------------

  G_NO_MATCHING_RECORD                 CONSTANT VARCHAR2(200)  := 'OKL_LLA_NO_MATCHING_RECORD';
  G_REQUIRED_VALUE                     CONSTANT VARCHAR2(200)  := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE                      CONSTANT VARCHAR2(200)  := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN                     CONSTANT VARCHAR2(200)  := OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN	               CONSTANT VARCHAR2(200)  := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN	               CONSTANT VARCHAR2(200)  := OKL_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR                   CONSTANT VARCHAR2(200)  := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN                      CONSTANT VARCHAR2(200)  := 'SQLerrm';
  G_SQLCODE_TOKEN                      CONSTANT VARCHAR2(200)  := 'SQLcode';
  G_API_TYPE                           CONSTANT VARCHAR2(200)  := '_PVT';
  G_CHAR_AMPERSAND                     CONSTANT VARCHAR2(1)    := '&';
-------------------------------------------------------------------------------------------------
----------------------------- Messages and constant names ---------------------------------------
-------------------------------------------------------------------------------------------------
  G_KHR_STATUS_NOT_COMPLETE            VARCHAR2(200)           := 'OKL_LLA_NOT_COMPLETE';
  G_TRANS_APP_NAME                     CONSTANT VARCHAR2(200)  := 'OKL Investor Adjustment Approval';
  G_INVALID_APP                        VARCHAR2(200)           := 'OKL_LLA_INVALID_APPLICATION';

  G_MSG_TOKEN_AGREEMENT_NUMBER         CONSTANT VARCHAR2(30)   := 'IA_NUMBER';
  G_EVENT_APPROVE_WF                   CONSTANT VARCHAR2(50)   := 'oracle.apps.okl.ia.approve_ia_add_khr';
  G_EVENT_APPROVE_AME                  CONSTANT VARCHAR2(50)   := 'oracle.apps.okl.ia.approve_ia_add_khr';
  G_IA_ADD_KHR_APPROVAL_PROCESS        CONSTANT VARCHAR2(50)   := 'OKL_IA_ADD_KHR_APPR_PROCESS';
  G_IA_ADD_CONTRACTS_APPRV_WF          CONSTANT VARCHAR2(5)    := 'WF';
  G_IA_ADD_KHR_APPROVAL_AME            CONSTANT VARCHAR2(5)    := 'AME';
  G_TRX_TSU_CODE_SUBMITTED             CONSTANT VARCHAR2(20)   := 'SUBMITTED';
  G_TRX_TSU_CODE_PROCESSED             CONSTANT VARCHAR2(20)   := 'PROCESSED';
  G_SOURCE_TRX_TYPE_WF                 CONSTANT VARCHAR2(10)   := 'WF';

  G_POOL_TRX_STS_PEND_APPROVAL         CONSTANT VARCHAR2(30)   := 'PENDING_APPROVAL';
  G_POOL_TRX_STS_APPROVED              CONSTANT VARCHAR2(15)   := 'APPROVED';
  G_POOL_TRX_STS_APPR_REJECTED         CONSTANT VARCHAR2(30)   := 'APPROVAL_REJECTED';

  G_WF_ITM_INVESTOR_AGRMNT_ID          CONSTANT VARCHAR2(20)   := 'INV_AGRMNT_ID';
  G_WF_ITM_INV_AGRMNT_NUMBER           CONSTANT VARCHAR2(20)   := 'INV_AGRMNT_NUMBER';
  G_WF_ITM_POOL_ID                     CONSTANT VARCHAR2(20)   := 'POOL_ID';
  G_WF_ITM_POOL_NUMBER                 CONSTANT VARCHAR2(20)   := 'POOL_NUMBER';
  G_WF_ITM_APPLICATION_ID              CONSTANT VARCHAR2(20)   := 'APPLICATION_ID';
  G_WF_ITM_POOL_TRANSACTION_ID         CONSTANT VARCHAR2(20)   := 'TRANSACTION_ID';
  G_WF_ITM_TRANSACTION_TYPE_ID         CONSTANT VARCHAR2(20)   := 'TRX_TYPE_ID';
  G_WF_ITM_REQUESTER                   CONSTANT VARCHAR2(20)   := 'REQUESTER';
  G_WF_ITM_REQUESTER_ID                CONSTANT VARCHAR2(20)   := 'REQUESTER_ID';
  G_WF_ITM_APPROVER                    CONSTANT VARCHAR2(20)   := 'APPROVER';
  G_WF_ITM_APPROVAL_REQ_MSG            CONSTANT VARCHAR2(30)   := 'APPROVAL_REQUEST_MESSAGE';
  G_WF_ITM_RESULT                      CONSTANT VARCHAR2(10)   := 'RESULT';
  G_WF_ITM_PARENT_ITEM_KEY             CONSTANT VARCHAR2(20)   := 'PARENT_ITEM_KEY';
  G_WF_ITM_PARENT_ITEM_TYPE            CONSTANT VARCHAR2(20)   := 'PARENT_ITEM_TYPE';
  G_WF_ITM_APPROVED_YN                 CONSTANT VARCHAR2(15)   := 'APPROVED_YN';
  G_WF_ITM_MASTER                      CONSTANT VARCHAR2(10)   := 'MASTER';
  G_WF_ITM_MESSAGE_DESCRIPTION         CONSTANT VARCHAR2(30)   := 'MESSAGE_DESCRIPTION';
  G_WF_ITM_MESSAGE_DOC                 CONSTANT VARCHAR2(15)   := 'MESSAGE_DOC';
  G_WF_ITM_MESSAGE_SUBJECT             CONSTANT VARCHAR2(20)   := 'MESSAGE_SUBJECT';
  G_WF_ITM_APP_REQUEST_SUB             CONSTANT VARCHAR2(30)   := 'APP_REQUEST_SUB';
  G_WF_ITM_APP_REMINDER_SUB            CONSTANT VARCHAR2(30)   := 'APP_REMINDER_SUB';
  G_WF_ITM_APP_REMINDER_HEAD           CONSTANT VARCHAR2(30)   := 'APP_REMINDER_HEAD';
  G_WF_ITM_APP_APPROVED_SUB            CONSTANT VARCHAR2(30)   := 'APP_APPROVED_SUB';
  G_WF_ITM_APP_APPROVED_HEAD           CONSTANT VARCHAR2(30)   := 'APP_APPROVED_HEAD';
  G_WF_ITM_APP_REJECTED_SUB            CONSTANT VARCHAR2(30)   := 'APP_REJECTED_SUB';
  G_WF_ITM_APP_REJECTED_HEAD           CONSTANT VARCHAR2(30)   := 'APP_REJECTED_HEAD';
  G_WF_ITM_ORG_ID                      CONSTANT VARCHAR2(20)   := 'ORG_ID';

  G_WF_ITM_RESULT_APPROVED             CONSTANT VARCHAR2(15)   := 'APPROVED';
  G_WF_ITM_APPROVED_YN_YES             CONSTANT VARCHAR2(5)    := 'Y';
  G_WF_ITM_APPROVED_YN_NO              CONSTANT VARCHAR2(5)    := 'N';

  G_ITEM_TYPE_WF                       CONSTANT VARCHAR2(30)   := 'OKLIAADD';
  G_APPROVAL_PROCESS_WF                CONSTANT VARCHAR2(30)   := 'IAADD_APPROVAL_WF';

  G_DEFAULT_USER                       CONSTANT VARCHAR2(30)   := 'SYSADMIN';
  G_DEFAULT_USER_DESC                  CONSTANT  VARCHAR2(30)  := 'System Administrator';
  G_WF_USER_ORIG_SYSTEM_HR             CONSTANT VARCHAR2(5)    := 'PER';

 ----------------------------------------------------------------------------
 -- Data Structures
 ----------------------------------------------------------------------------

 ---------------------------------------------------------------------------
 -- PROCEDURE l_get_agent
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : l_get_agent
  -- Description     :
  -- Business Rules  :
  -- Parameters      : p_user_id , x_return_status, x_name, x_description
  -- Version         : 1.0
  -- End of comments
  ------------------------------ ---------------------------------------------
  PROCEDURE l_get_agent(p_user_id     IN  NUMBER,
                        x_return_status  OUT NOCOPY VARCHAR2,
                        x_name         OUT NOCOPY VARCHAR2,
                        x_description OUT NOCOPY VARCHAR2) IS

    CURSOR wf_users_csr(c_user_id NUMBER)
    IS
    SELECT NAME, DISPLAY_NAME
    FROM   WF_USERS
    WHERE  orig_system_id = c_user_id
   	AND    ORIG_SYSTEM = G_WF_USER_ORIG_SYSTEM_HR;

    CURSOR fnd_users_csr(c_user_id NUMBER)
    IS
    SELECT USER_NAME, DESCRIPTION
    FROM   FND_USER
    WHERE  user_id = c_user_id;
  BEGIN
    x_return_status      := OKL_API.G_RET_STS_SUCCESS;
    OPEN  wf_users_csr(p_user_id);
    FETCH wf_users_csr INTO x_name, x_description;
    CLOSE wf_users_csr;
    IF x_name IS NULL THEN
      OPEN  fnd_users_csr(p_user_id);
      FETCH fnd_users_csr INTO x_name, x_description;
      CLOSE fnd_users_csr;
      IF x_name IS NULL THEN
        x_name        := G_DEFAULT_USER_DESC;
        x_description := G_DEFAULT_USER_DESC;
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status      := OKL_API.G_RET_STS_UNEXP_ERROR;
  END l_get_agent;

 ---------------------------------------------------------------------------
 -- PROCEDURE l_change_add_req_status
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : l_change_add_req_status
  -- Description     :
  -- Business Rules  : This updates the credit line status.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_pool_trx_status, p_pool_trans_id, p_pool_id
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE l_change_add_req_status(p_api_version         IN  NUMBER,
                                        p_init_msg_list       IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                        x_return_status       OUT NOCOPY VARCHAR2,
                                        x_msg_count           OUT NOCOPY NUMBER,
                                        x_msg_data            OUT NOCOPY VARCHAR2,
                                        p_pool_trx_status     IN  OKL_POOL_TRANSACTIONS.TRANSACTION_STATUS%TYPE,
                                        p_pool_trans_id       IN  OKL_POOL_TRANSACTIONS.ID%TYPE,
                                        p_pool_id             IN  OKL_POOLS_ALL.ID%TYPE
                                        ) IS

    l_api_name          CONSTANT VARCHAR2(30) := 'l_change_add_req_status';
    l_pool_trx_status  OKL_POOL_TRANSACTIONS.TRANSACTION_STATUS%TYPE;
    l_pool_trans_id    OKL_POOL_TRANSACTIONS.ID%TYPE;
    l_pool_id          OKL_POOLS_ALL.ID%TYPE;
    lp_poxv_rec         poxv_rec_type;
    lx_poxv_rec         poxv_rec_type;

  BEGIN
    x_return_status      := OKL_API.G_RET_STS_SUCCESS;
    l_pool_trans_id      := p_pool_trans_id;
    l_pool_trx_status    := p_pool_trx_status;
    l_pool_id            := p_pool_id;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name,
                               p_init_msg_list,
                               '_PVT',
                               x_return_status);

    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

 --Set the Pool Transaction Id for the update call
     lp_poxv_rec.ID                    := l_pool_trans_id;
     lp_poxv_rec.TRANSACTION_STATUS    := l_pool_trx_status;
     lp_poxv_rec.pol_id                := l_pool_id;
     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_wf.l_change_add_req_status', 'Before  Pool Transaction update call ');
       fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_wf.l_change_add_req_status', 'lp_poxv_rec.TRANSACTION_STATUS ' || lp_poxv_rec.TRANSACTION_STATUS);
       fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_wf.l_change_add_req_status', 'lp_poxv_rec.ID ' || lp_poxv_rec.ID);
       fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_wf.l_change_add_req_status', 'lp_poxv_rec.pol_id ' || lp_poxv_rec.pol_ID);
    END IF;

    OKL_POOL_PVT.update_pool_transaction(p_api_version    => p_api_version,
                                         p_init_msg_list  => p_init_msg_list,
                                         x_return_status  => x_return_status,
                                         x_msg_count      => x_msg_count,
                                         x_msg_data       => x_msg_data,
                                         p_poxv_rec      => lp_poxv_rec,
                                         x_poxv_rec      => lx_poxv_rec);

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_wf.l_change_add_req_status', 'After  Pool Transaction update call x_return_status ' || x_return_status);
    END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END l_change_add_req_status;

 ---------------------------------------------------------------------------
 -- FUNCTION get_message
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name  : get_message
  -- Description     :
  -- Business Rules  : Sets tha appropriate message for approval and for
  --                   approved or rejected credit line.
  -- Parameters      : p_msg_name, p_inv_agrmnt_number
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  FUNCTION get_message(p_msg_name        IN VARCHAR2,
                       p_inv_agrmnt_number IN VARCHAR2)
  RETURN VARCHAR2
  IS
    l_message VARCHAR2(100);
  BEGIN
    IF p_msg_name IS NOT NULL THEN
       Fnd_Message.SET_NAME(APPLICATION => G_APP_NAME
                           ,NAME => p_msg_name);
       Fnd_Message.SET_TOKEN(TOKEN => G_MSG_TOKEN_AGREEMENT_NUMBER,
                             VALUE => p_inv_agrmnt_number);
       l_message := fnd_message.get();
	END IF;

	RETURN l_message;
  EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
  END get_message;

  --------------------------------------------------------------------------------------------------
  ----------------------------------Raising Business Event ------------------------------------------
  --------------------------------------------------------------------------------------------------
 ---------------------------------------------------------------------------
 -- PROCEDURE raise_add_khr_approval_event
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : raise_add_khr_approval_event
  -- Description     :
  -- Business Rules  : Raises the credit line approval event
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_agreement_id, p_pool_id.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE raise_add_khr_approval_event (p_api_version    IN  NUMBER,
                                  p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                  x_return_status  OUT NOCOPY VARCHAR2,
                                  x_msg_count      OUT NOCOPY NUMBER,
                                  x_msg_data       OUT NOCOPY VARCHAR2,
                                  p_agreement_id   IN  OKC_K_HEADERS_B.ID%TYPE,
                                  p_pool_id        IN  OKL_POOLS_ALL.ID%TYPE,
                                  p_pool_trans_id  IN  OKL_POOL_TRANSACTIONS.ID%TYPE)
  IS

    -- Get Investor Agreement Details
    CURSOR c_fetch_ia_number_csr(p_agreement_id OKC_K_HEADERS_V.ID%TYPE)
    IS
    SELECT chrv.contract_number
    FROM okc_k_headers_v chrv
    WHERE chrv.id = p_agreement_id;

    -- Get Pool Details
    CURSOR c_fetch_pool_number_csr(p_pool_id  OKL_POOLS.ID%TYPE)
    IS
    SELECT pol.pool_number
    FROM okl_pools_all pol
    WHERE pol.id = p_pool_id ;

    -- Get the valid application id from FND
    CURSOR c_get_app_id_csr
    IS
    SELECT APPLICATION_ID
    FROM   FND_APPLICATION
    WHERE  APPLICATION_SHORT_NAME = G_APP_NAME;

    -- Get the Transaction Type Id from OAM
    CURSOR c_get_trx_type_csr(c_trx_type  VARCHAR2)
    IS
    SELECT DESCRIPTION transaction_type_id,
           FND_APPLICATION_ID fnd_application_id
    FROM AME_TRANSACTION_TYPES_V
    WHERE TRANSACTION_TYPE_ID=c_trx_type;

    CURSOR l_wf_item_key_csr IS
    SELECT okl_wf_item_s.NEXTVAL item_key
    FROM  dual;

    l_return_status    VARCHAR2(3);
    l_api_version      NUMBER;
    l_api_name         CONSTANT VARCHAR2(30) := 'raise_add_khr_app_event';
    l_msg_count	       NUMBER;
    l_init_msg_list    VARCHAR2(10);
    l_msg_data		       VARCHAR2(2000);
    l_parameter_list   wf_parameter_list_t;
    l_key              VARCHAR2(240);
    l_event_name       VARCHAR2(240);
    l_application_id   FND_APPLICATION.APPLICATION_ID%TYPE;
    l_trans_appl_id    AME_CALLING_APPS.APPLICATION_ID%TYPE;
    l_trans_type_id    AME_CALLING_APPS.TRANSACTION_TYPE_ID%TYPE;
   	l_agreement_num    OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE;
    l_agreement_id     OKC_K_HEADERS_V.ID%TYPE;
    l_pool_id          OKL_POOLS_ALL.ID%TYPE;
    l_pool_trans_id    OKL_POOL_TRANSACTIONS.ID%TYPE;
   	l_requester        VARCHAR2(200);
    l_pool_number      OKL_POOLS_ALL.POOL_NUMBER%TYPE;
    l_name             VARCHAR2(200);
    l_requester_id     VARCHAR2(200);
   	l_approval_option  VARCHAR2(5);

  BEGIN

    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_api_version 	 := 1.0;
    l_init_msg_list := OKL_API.G_FALSE;
    l_agreement_id  := p_agreement_id;
    l_pool_id       := p_pool_id;
    l_pool_trans_id := p_pool_trans_id;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_wf.raise_add_khr_approval_event', 'Begin Add Contract Approval Processing');
    END IF;
   -- Create Internal Transaction
    -- Get the user id, Item key
    l_requester_id := FND_GLOBAL.USER_ID;

    l_get_agent(p_user_id       => l_requester_id,
                x_return_status => x_return_status,
	               x_name          => l_requester,
	               x_description   => l_name);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_wf.raise_add_khr_approval_event', 'After l_get_agent  l_requester : ' || l_requester);
    END IF;
    FOR l_wf_item_key_rec IN l_wf_item_key_csr
    LOOP
        l_key := l_wf_item_key_rec.item_key;
    END LOOP;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_wf.raise_add_khr_approval_event', 'l_wf_item_key_csr returned l_key  : ' || l_key);
    END IF;

    -- Get the Investor Agreement Number
	OPEN  c_fetch_ia_number_csr(l_agreement_id);
	FETCH c_fetch_ia_number_csr INTO l_agreement_num;
	  IF c_fetch_ia_number_csr%NOTFOUND THEN
		 OKL_API.set_message(p_app_name     => G_APP_NAME,
		                     p_msg_name     => G_NO_MATCHING_RECORD,
		                     p_token1       => G_COL_NAME_TOKEN,
		                     p_token1_value => 'OKC_K_HEADERS_V.ID');
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    CLOSE c_fetch_ia_number_csr;
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_wf.raise_add_khr_approval_event','After c_fetch_ia_number_csr  l_agreement_num : ' || l_agreement_num);
    END IF;
 --Get Pool Number
       OPEN c_fetch_pool_number_csr(p_pool_id);
       FETCH c_fetch_pool_number_csr into l_pool_number;
        IF c_fetch_pool_number_csr%NOTFOUND THEN
		        OKL_API.set_message(p_app_name     => G_APP_NAME,
		                            p_msg_name     => G_NO_MATCHING_RECORD,
		                            p_token1       => G_COL_NAME_TOKEN,
		                            p_token1_value => 'OKL_POOLS.NUMBER');
		        RAISE OKL_API.G_EXCEPTION_ERROR;
   		END IF;
       CLOSE c_fetch_pool_number_csr ;
       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_wf.raise_add_khr_approval_event', 'c_fetch_pool_number_csr  returned l_pool_number : ' || l_pool_number);
       END IF;

    l_approval_option := fnd_profile.value(G_IA_ADD_KHR_APPROVAL_PROCESS);

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_wf.raise_add_khr_approval_event', 'The Profile Option for Sending Workflow is set as ' || l_approval_option);
    END IF;

	IF l_approval_option = G_IA_ADD_KHR_APPROVAL_AME THEN
		-- Get the Application ID
	    OPEN  c_get_app_id_csr;
	    FETCH c_get_app_id_csr INTO l_application_id;
	    IF c_get_app_id_csr%NOTFOUND THEN
	      OKL_API.set_message(p_app_name     => G_APP_NAME,
	                          p_msg_name     => G_NO_MATCHING_RECORD,
	                          p_token1       => G_COL_NAME_TOKEN,
	                          p_token1_value => 'Application id');
	      RAISE OKL_API.G_EXCEPTION_ERROR;
	    END IF;
	    CLOSE c_get_app_id_csr;
     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_wf.raise_add_khr_approval_event', 'After Get the Application ID c_get_app_id_csr  l_application_id : ' || l_application_id);
     END IF;

		-- Get the Transaction Type ID
	    OPEN  c_get_trx_type_csr(G_TRANS_APP_NAME);
	    FETCH c_get_trx_type_csr INTO l_trans_type_id,
	                                  l_trans_appl_id;
	    IF c_get_trx_type_csr%NOTFOUND THEN
	      OKL_API.set_message(p_app_name     => G_APP_NAME,
	                          p_msg_name     => G_NO_MATCHING_RECORD,
	                          p_token1       => G_COL_NAME_TOKEN,
	                          p_token1_value => 'AME Transcation TYPE id, Application id');
	      RAISE OKL_API.G_EXCEPTION_ERROR;
	    END IF;
	    CLOSE c_get_trx_type_csr;

     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_wf.raise_add_khr_approval_event', 'After c_get_trx_type_csr ');
        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_wf.raise_add_khr_approval_event', 'l_trans_type_id  : ' || l_trans_type_id);
        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_wf.raise_add_khr_approval_event', 'l_trans_appl_id  : ' || l_trans_appl_id);
     END IF;

      IF l_application_id = l_trans_appl_id THEN
         l_event_name := G_EVENT_APPROVE_AME;

         wf_event.AddParameterToList(G_WF_ITM_INVESTOR_AGRMNT_ID,p_agreement_id,l_parameter_list);
         wf_event.AddParameterToList(G_WF_ITM_INV_AGRMNT_NUMBER,l_agreement_num,l_parameter_list);
         wf_event.AddParameterToList(G_WF_ITM_POOL_NUMBER,l_pool_number,l_parameter_list);
         wf_event.AddParameterToList(G_WF_ITM_POOL_TRANSACTION_ID,l_pool_trans_id,l_parameter_list);
         wf_event.AddParameterToList(G_WF_ITM_APPLICATION_ID,l_application_id,l_parameter_list);
         wf_event.AddParameterToList(G_WF_ITM_TRANSACTION_TYPE_ID,l_trans_type_id,l_parameter_list);
         wf_event.AddParameterToList(G_WF_ITM_REQUESTER,l_requester,l_parameter_list);
         wf_event.AddParameterToList(G_WF_ITM_REQUESTER_ID,l_requester_id,l_parameter_list);
         wf_event.AddParameterToList(G_WF_ITM_ORG_ID, mo_global.get_current_org_id ,l_parameter_list);
       ELSE
	     OKL_API.set_message(p_app_name     => G_APP_NAME,
	                         p_msg_name     => G_INVALID_APP);
	     RAISE OKL_API.G_EXCEPTION_ERROR;
	   END IF; -- l_application_id
 	ELSIF l_approval_option = G_IA_ADD_CONTRACTS_APPRV_WF THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_wf.raise_add_khr_approval_event', 'l_approval_option ' || l_approval_option);
    END IF;
   	   l_event_name := G_EVENT_APPROVE_WF;

       wf_event.AddParameterToList(G_WF_ITM_INVESTOR_AGRMNT_ID,p_agreement_id,l_parameter_list);
       wf_event.AddParameterToList(G_WF_ITM_INV_AGRMNT_NUMBER,l_agreement_num,l_parameter_list);
       wf_event.AddParameterToList(G_WF_ITM_POOL_ID,l_pool_id,l_parameter_list);
       wf_event.AddParameterToList(G_WF_ITM_POOL_NUMBER,l_pool_number,l_parameter_list);
       wf_event.AddParameterToList(G_WF_ITM_POOL_TRANSACTION_ID,l_pool_trans_id,l_parameter_list);
       wf_event.AddParameterToList(G_WF_ITM_REQUESTER,l_requester,l_parameter_list);
       wf_event.AddParameterToList(G_WF_ITM_REQUESTER_ID,l_requester_id,l_parameter_list);
       wf_event.AddParameterToList(G_WF_ITM_ORG_ID, mo_global.get_current_org_id ,l_parameter_list);
    ELSE
	   RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF; -- l_approval_option

     -- Raise Event
     wf_event.RAISE(p_event_name => l_event_name,
                    p_event_key  => l_key,
                    p_parameters => l_parameter_list);
     l_parameter_list.DELETE;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_wf.raise_add_khr_approval_event', 'Worklow Intiated and Approval Sent');
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                          x_msg_data   => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
      IF c_fetch_ia_number_csr%ISOPEN THEN
        CLOSE c_fetch_ia_number_csr;
      END IF;
      IF c_get_app_id_csr%ISOPEN THEN
        CLOSE c_get_app_id_csr;
      END IF;
      IF c_get_trx_type_csr%ISOPEN THEN
        CLOSE c_get_trx_type_csr;
      END IF;
      IF l_wf_item_key_csr%ISOPEN THEN
        CLOSE l_wf_item_key_csr;
      END IF;
      IF c_fetch_pool_number_csr%ISOPEN THEN
        CLOSE c_fetch_pool_number_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      IF c_fetch_ia_number_csr%ISOPEN THEN
        CLOSE c_fetch_ia_number_csr;
      END IF;
      IF c_get_app_id_csr%ISOPEN THEN
        CLOSE c_get_app_id_csr;
      END IF;
      IF c_get_trx_type_csr%ISOPEN THEN
        CLOSE c_get_trx_type_csr;
      END IF;
      IF l_wf_item_key_csr%ISOPEN THEN
        CLOSE l_wf_item_key_csr;
      END IF;
      IF c_fetch_pool_number_csr%ISOPEN THEN
        CLOSE c_fetch_pool_number_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      IF c_fetch_ia_number_csr%ISOPEN THEN
        CLOSE c_fetch_ia_number_csr;
      END IF;
      IF c_get_app_id_csr%ISOPEN THEN
        CLOSE c_get_app_id_csr;
      END IF;
      IF c_get_trx_type_csr%ISOPEN THEN
        CLOSE c_get_trx_type_csr;
      END IF;
      IF l_wf_item_key_csr%ISOPEN THEN
        CLOSE l_wf_item_key_csr;
      END IF;
      IF c_fetch_pool_number_csr%ISOPEN THEN
        CLOSE c_fetch_pool_number_csr;
      END IF;
      -- store SQL error message on message stack
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);
  END raise_add_khr_approval_event;

 ---------------------------------------------------------------------------
 -- FUNCTION compile_msg_for_add_req
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name  : compile_msg_for_add_req
  -- Description     :
  -- Business Rules  : Creates the message body of the notifications
  -- Parameters      : p_inv_agrmnt_id,p_pool_id,p_pool_trans_id
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  FUNCTION compile_msg_for_add_req(p_inv_agrmnt_id IN NUMBER, p_pool_id IN NUMBER,p_pool_trans_id IN NUMBER)
    RETURN VARCHAR2
  IS
    CURSOR l_okl_add_contracts_csr(p_inv_agrmnt_id OKC_K_HEADERS_V.ID%TYPE, p_pool_id OKL_POOLS.ID%TYPE,p_pool_trans_id IN NUMBER)
    IS
     SELECT  OPA.POOL_NUMBER
      , OKC.CONTRACT_NUMBER  AGREEMENT_NUMBER
      , FND_REASON.MEANING TRANSACTION_REASON
     , FND.MEANING TRANSACTION_STATUS
      , SUM(STRM.AMOUNT) STREAM_VALUE
     , OPT.TRANSACTION_NUMBER
      , OPT.TRANSACTION_DATE
    FROM OKL_POOL_CONTENTS OPC
      ,OKL_POOL_TRANSACTIONS OPT
      ,OKL_STRM_ELEMENTS STRM
      ,FND_LOOKUPS FND
      ,FND_LOOKUPS FND_REASON
      ,OKL_POOLS_ALL OPA
      ,OKC_K_HEADERS_ALL_B OKC
      WHERE OPT.POL_ID = p_pool_id
      AND OPT.TRANSACTION_REASON = 'ADJUSTMENTS'
      AND OPT.TRANSACTION_TYPE = 'ADD'
      AND OPT.POL_ID = OPA.ID
      AND OPT.TRANSACTION_STATUS = FND.LOOKUP_CODE
      AND FND.LOOKUP_TYPE = 'OKL_POOL_TRANSACTION_STATUS'
      AND OPC.POX_ID = OPT.ID
      AND OPT.ID = p_pool_trans_id
      AND OPC.POL_ID = OPT.POL_ID
      AND OPC.STM_ID = STRM.STM_ID
      AND STRM.STREAM_ELEMENT_DATE BETWEEN OPC.STREAMS_FROM_DATE AND NVL(OPC.STREAMS_TO_DATE,OPC.STREAMS_FROM_DATE)
      AND OKC.ID = p_inv_agrmnt_id
      AND OPT.TRANSACTION_REASON = FND_REASON.LOOKUP_CODE
      AND FND_REASON.LOOKUP_TYPE = 'OKL_POOL_TRANSACTION_REASON'
    GROUP BY
      OPT.TRANSACTION_REASON,
      OPT.ID,
      POX_ID,
      FND.MEANING,
      FND_REASON.MEANING,
      OPT.TRANSACTION_NUMBER,
      OPT.TRANSACTION_DATE,
      OPA.POOL_NUMBER,
      OKC.CONTRACT_NUMBER;

    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(2000);
    l_api_version    NUMBER ;
    l_init_msg_list  VARCHAR2(3) ;
    l_return_status  VARCHAR2(3) ;
    l_true_tax       VARCHAR2(200);
    l_cap_amt        NUMBER;
    l_res_value      NUMBER;
    l_message        VARCHAR2(12000);
    l_flag           VARCHAR2(10);

  BEGIN

    l_api_version   := 1;
    l_init_msg_list := OKC_API.G_TRUE;
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_message := l_message || '<table class="x1h" cellpadding="1" cellspacing="0" border="1" width="100%">';

    /* 08-Feb-2008 ankushar
       Modified compile message to display correct notification header format.
       Start Changes
     */
    -- Headers for the creditline details table.
    -- Investor Agreement Number
    l_message := l_message || '<tr class="x1r"> <th scope="col" class="x1r"> <span title="'
                           || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_INVESTOR_DTLS',
                                                      p_attribute_code => 'OKL_INV_AGR_NUM')
                           || '" class="x24">'
                           || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_INVESTOR_DTLS',
                                                      p_attribute_code => 'OKL_INV_AGR_NUM')
                           || '</span></th>';
    -- Pool Number
    l_message := l_message || '<th scope="col" class="x1r"> <span title="'
                           || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_POOL_SERCH',
                                                      p_attribute_code => 'OKL_POOL_NUMBER')
                           || '" class="x24">'
                           || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_POOL_SERCH',
                                                      p_attribute_code => 'OKL_POOL_NUMBER')
                           || '</span></th>';

    -- Transaction Reason
    l_message := l_message || '<th scope="col" class="x1r"> <span title="'
                           || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_POOL_TRANS_DTLS',
                                                      p_attribute_code => 'OKL_TRANSACTION_REASON')
                           || '" class="x24">'
                           || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_POOL_TRANS_DTLS',
                                                      p_attribute_code => 'OKL_TRANSACTION_REASON')
                           || '</span></th>';

    -- Transaction Status
    l_message := l_message || '<th scope="col" class="x1r"> <span title="'
                           || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_VIEW_TRX_DTAIL',
                                                      p_attribute_code => 'OKL_TRANSACTION_STATUS')
                           || '" class="x24">'
                           || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_VIEW_TRX_DTAIL',
                                                      p_attribute_code => 'OKL_TRANSACTION_STATUS')
                           || '</span></th>';

    -- Transaction Date
    l_message := l_message || '<th scope="col" class="x1r"> <span title="'
                           || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_POOL_TRANS_DTLS',
                                                      p_attribute_code => 'OKL_TRANSACTION_DATE')
                           || '" class="x24">'
                           || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_POOL_TRANS_DTLS',
                                                      p_attribute_code => 'OKL_TRANSACTION_DATE')
                           || '</span></th>';
    -- Value Of Streams
    l_message := l_message || '<th scope="col" class="x1r"> <span title="'
                           || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_SEC_COMMON_HDR',
                                                      p_attribute_code => 'OKL_VALUE_OF_STREAMS')
                           || '" class="x24">'
                           || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_SEC_COMMON_HDR',
                                                      p_attribute_code => 'OKL_VALUE_OF_STREAMS')
                           || '</span></th>';
    /* 08-Feb-2008 ankushar
       End Changes
     */

    FOR l_okl_add_contracts_rec IN l_okl_add_contracts_csr(p_inv_agrmnt_id, p_pool_id,p_pool_trans_id)
    LOOP
      IF (l_okl_add_contracts_rec.agreement_number is not null)THEN
         l_message := l_message || '<tr><td class="x1l x4x">'
                                || l_okl_add_contracts_rec.agreement_number
                                || '</td>';
      ELSE
         l_message := l_message || '<tr><td class="x1l x4x"><br></td>';
      END IF;

      IF(l_okl_add_contracts_rec.pool_number is not null)THEN
         l_message := l_message || '<td class="x1l x4x">'
                                || l_okl_add_contracts_rec.pool_number
                                || '</td>';
      ELSE
         l_message := l_message || '<td class="x1l x4x"><br></td>';
      END IF;

      IF(l_okl_add_contracts_rec.transaction_reason is not null) THEN
      l_message := l_message || '<td class="x1l x4x">'
                             || l_okl_add_contracts_rec.transaction_reason
                             || '</td>';
      ELSE
         l_message := l_message || '<td class="x1l x4x"><br></td>';
      END IF;

      IF( l_okl_add_contracts_rec.transaction_status is not null) THEN
      l_message := l_message || '<td class="x1l x4x">'
                             || l_okl_add_contracts_rec.transaction_status
                             || '</td>';
      ELSE
         l_message := l_message || '<td class="x1l x4x"><br></td>';
      END IF;

      IF(l_okl_add_contracts_rec.transaction_date is not null) THEN
         l_message := l_message || '<td class="x1l x4x">'
                                || to_date(l_okl_add_contracts_rec.transaction_date, 'dd-mm-yyyy')
                                || '</td>';
      ELSE
         l_message := l_message || '<td class="x1l x4x""><br></td>';
      END IF;

      IF(l_okl_add_contracts_rec.stream_value is not null) THEN
      l_message := l_message || '<td class="x1l x4x">'
                             || l_okl_add_contracts_rec.stream_value
                             || '</td></tr>';
      ELSE
         l_message := l_message || '<td class="x1l x4x"><br></td></tr>';

      END IF;

    END LOOP;
    l_message := l_message || '</table>';

    RETURN l_message;

  EXCEPTION
   WHEN OTHERS THEN
     RETURN NULL;
  END compile_msg_for_add_req;

  /*
  -- This API is for IA Add Contracts Request Approval via WF
  */
 ---------------------------------------------------------------------------
 -- PROCEDURE get_add_khr_approver
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : get_add_khr_approver
  -- Description     :
  -- Business Rules  : returns whether the approver is found or not.
  -- Parameters      : itemtype, itemkey, actid, funcmode,resultout.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE get_add_khr_approver(itemtype   IN VARCHAR2,
                                     itemkey    IN VARCHAR2,
                                     actid      IN NUMBER,
                                     funcmode   IN VARCHAR2,
           		                        resultout  OUT  NOCOPY VARCHAR2)
  IS
    CURSOR l_fnd_users_csr(p_user_id NUMBER)
    IS
    SELECT USER_NAME
    FROM   FND_USER
    WHERE  user_id = p_user_id;

    l_api_name         CONSTANT VARCHAR2(200) := 'get_add_khr_approver';
   	l_user_id          VARCHAR2(200);
    l_ia_number        OKC_K_HEADERS_V.contract_number%TYPE;
	   l_return_status    VARCHAR2(1);

  BEGIN
     l_return_status := OKL_API.G_RET_STS_SUCCESS;

	 -- "RUN"
     IF (funcmode = 'RUN') THEN
         l_user_id :=   wf_engine.GetItemAttrText (itemtype  => itemtype,
                                                    itemkey   => itemkey,
                                                    aname     => G_WF_ITM_REQUESTER_ID);

         l_ia_number :=   wf_engine.GetItemAttrText (itemtype  => itemtype,
                                                           itemkey   => itemkey,
                                                           aname     => G_WF_ITM_INV_AGRMNT_NUMBER);

         resultout := 'COMPLETE:NOT_FOUND'; -- default
		 IF l_user_id IS NOT NULL THEN
			 FOR l_fnd_users_rec IN l_fnd_users_csr(l_user_id)
			 LOOP
			     wf_engine.SetItemAttrText (itemtype  => itemtype,
			                                itemkey   => itemkey,
			                                aname     => G_WF_ITM_APPROVER,
   				                            avalue    => l_fnd_users_rec.user_name);


        wf_engine.SetItemAttrText (itemtype   => itemtype,
			                       itemkey    => itemkey,
                             	   aname   	  => G_WF_ITM_MESSAGE_SUBJECT,
                                   avalue     => get_message('OKL_IA_ADD_KHR_APPROVAL_SUB',l_ia_number));

        wf_engine.SetItemAttrDocument (itemtype     => itemtype,
                                       itemkey      => itemkey,
                                       aname 	    => G_WF_ITM_MESSAGE_DOC,
                                       documentid   => 'plsql:OKL_SEC_AGREEMENT_WF.pop_approval_doc/'||itemkey);

  	     resultout := 'COMPLETE:FOUND';
			 END LOOP;
		 END IF; -- l_user_id

    -- CANCEL mode
	ELSIF (funcmode = 'CANCEL') THEN
        resultout := 'COMPLETE:';
        RETURN;
    -- TIMEOUT mode
    ELSIF (funcmode = 'TIMEOUT') THEN
        resultout := 'COMPLETE:';
        RETURN;
    END IF; -- funcmode
  EXCEPTION
  WHEN OTHERS THEN
      wf_core.context(G_PKG_NAME,
                      l_api_name,
                      itemtype,
                      itemkey,
                      TO_CHAR(actid),
                      funcmode);
      RAISE;

  END get_add_khr_approver;

 --------------------------------------------------------------------------------------------------
 --------------------------------- Set Approval Status --------------------------------------------
 --------------------------------------------------------------------------------------------------
 ---------------------------------------------------------------------------
 -- PROCEDURE Set_Add_Khr_Attributes
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Set_Add_Khr_Attributes
  -- Description     :
  -- Business Rules  : sets the parent attributes.
  -- Parameters      : itemtype, itemkey, actid, funcmode,resultout.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Set_Add_Khr_Attributes(itemtype  IN  VARCHAR2,
                                  itemkey   IN  VARCHAR2,
                                  actid     IN  NUMBER,
                                  funcmode  IN  VARCHAR2,
                                  resultout OUT NOCOPY VARCHAR2) IS

    l_approved_yn     VARCHAR2(30);
    l_parent_key      VARCHAR2(240);
    l_parent_type     VARCHAR2(240);
    l_result          VARCHAR2(30);
   	l_api_name        CONSTANT VARCHAR2(30) := 'Set_Add_Khr_Attributes';
	l_ia_number       okc_k_headers_v.contract_number%TYPE;

  BEGIN
    SAVEPOINT set_atts;
    IF (funcmode = 'RUN') THEN
      -- Get current approval status
       l_result := wf_engine.GetItemAttrText (itemtype  => itemtype,
                                              itemkey   => itemkey,
                                              aname     => G_WF_ITM_RESULT);

       l_parent_key :=  wf_engine.GetItemAttrText (itemtype  => itemtype,
                                			       itemkey   => itemkey,
                               				       aname     => G_WF_ITM_PARENT_ITEM_KEY);

       l_parent_type :=  wf_engine.GetItemAttrText (itemtype   => itemtype,
                                 			        itemkey    => itemkey,
                                				    aname      => G_WF_ITM_PARENT_ITEM_TYPE);

       l_ia_number :=   wf_engine.GetItemAttrText (itemtype  => itemtype,
                                                   itemkey   => itemkey,
                                                   aname     => G_WF_ITM_INV_AGRMNT_NUMBER);

      IF l_result = G_WF_ITM_RESULT_APPROVED THEN
        l_approved_yn := G_WF_ITM_APPROVED_YN_YES;
        wf_engine.SetItemAttrText (itemtype   => itemtype,
                            	   itemkey    => itemkey,
                            	   aname   	  => G_WF_ITM_MESSAGE_SUBJECT,
                                   avalue     => get_message('OKL_IA_ADD_KHR_APPROVED_SUB',l_ia_number));
      ELSE
        l_approved_yn := G_WF_ITM_APPROVED_YN_NO;
        wf_engine.SetItemAttrText (itemtype   => itemtype,
                            	   itemkey    => itemkey,
                            	   aname   	  => G_WF_ITM_MESSAGE_SUBJECT,
                                   avalue     => get_message('OKL_IA_ADD_KHR_REJECTED_SUB',l_ia_number));
      END IF;

      wf_engine.SetItemAttrText(itemtype  => l_parent_type,
                                itemkey   => l_parent_key,
                            	aname     => G_WF_ITM_APPROVED_YN,
               	                avalue    => l_approved_yn);
       resultout := 'COMPLETE:';
      RETURN;
    END IF;
    -- CANCEL mode
    IF (funcmode = 'CANCEL') THEN
      resultout := 'COMPLETE:';
      RETURN;
    END IF;
    -- TIMEOUT mode
    IF (funcmode = 'TIMEOUT') THEN
      resultout := 'COMPLETE:';
      RETURN;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      wf_core.context(G_PKG_NAME,
                      	l_api_name,
                       itemtype,
                       itemkey,
                       TO_CHAR(actid),
                       funcmode);
        RAISE;
  END Set_Add_Khr_Attributes;

--------------------------------------------------------------------------------------------------
----------------------------------Main Approval Process ------------------------------------------
--------------------------------------------------------------------------------------------------
 ---------------------------------------------------------------------------
 -- PROCEDURE update_add_khr_apprv_sts
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_add_khr_apprv_sts
  -- Description     :
  -- Business Rules  : Updates the Add Contracts Request status from pending approval
  --                   to approved or approval rejected.
  -- Parameters      : itemtype, itemkey, actid, funcmode,resultout.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE update_add_khr_apprv_sts(itemtype  IN  VARCHAR2,
                                   itemkey   IN  VARCHAR2,
                                   actid     IN  NUMBER,
                                   funcmode  IN  VARCHAR2,
                                   resultout OUT NOCOPY VARCHAR2)
  IS
    CURSOR l_okl_trx_contracts_csr(p_trx_number IN VARCHAR2)
    IS
   	SELECT id
    FROM   okl_trx_contracts
   	WHERE  trx_number = p_trx_number
        --rkuttiya added for 12.1.1 Multi GAAP
        AND    representation_type = 'PRIMARY';
        --

    l_return_status	       VARCHAR2(3) ;
    l_api_version          NUMBER	;
    l_msg_count		       NUMBER;
    l_init_msg_list        VARCHAR2(10);
    l_msg_data		       VARCHAR2(2000);
    l_api_name             CONSTANT VARCHAR2(30) := 'update_add_khr_apprv_sts';
    l_pool_trans_id        OKC_K_HEADERS_V.ID%TYPE;
    l_pool_id              OKL_POOLS_ALL.ID%TYPE;
    l_approved_yn          VARCHAR2(30);
    l_trx_number           VARCHAR2(100);
    lv_approval_status_ame VARCHAR2(10);

  BEGIN

    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_api_version := 1.0;
    l_init_msg_list  := OKL_API.G_FALSE;

    -- We getting the pool_trans_Id from WF
    l_pool_trans_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                 itemkey  => itemkey,
                                                 aname    => G_WF_ITM_POOL_TRANSACTION_ID);
    -- We getting the pool_Id from WF
    l_pool_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                 itemkey  => itemkey,
                                                 aname    => G_WF_ITM_POOL_ID);
    --Run Mode
    IF funcmode = 'RUN' THEN
      l_approved_yn :=  wf_engine.GetItemAttrText (itemtype  => itemtype,
                                                   itemkey   => itemkey,
                                                   aname     => G_WF_ITM_APPROVED_YN);
      lv_approval_status_ame := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                          itemkey   => itemkey,
                                                          aname     => 'APPROVED_YN');

      IF (l_approved_yn = G_WF_ITM_APPROVED_YN_YES OR lv_approval_status_ame = G_WF_ITM_APPROVED_YN_YES)THEN
         l_change_add_req_status(p_api_version       => l_api_version,
                                     p_init_msg_list     => l_init_msg_list,
                                     x_return_status     => l_return_status,
                                     x_msg_count         => l_msg_count,
                                     x_msg_data          => l_msg_data,
                                     p_pool_trx_status   => G_POOL_TRX_STS_APPROVED,
                                     p_pool_trans_id     => l_pool_trans_id,
                                     p_pool_id           => l_pool_id);

     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

      ELSE
         l_change_add_req_status(p_api_version        => l_api_version,
                                     p_init_msg_list      => l_init_msg_list,
                                     x_return_status      => l_return_status,
                                     x_msg_count          => l_msg_count,
                                     x_msg_data           => l_msg_data,
                                     p_pool_trx_status    => G_POOL_TRX_STS_APPR_REJECTED,
                                     p_pool_trans_id      => l_pool_trans_id,
                                     p_pool_id           => l_pool_id);


         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
      END IF;

      resultout := 'COMPLETE:';
      RETURN;
   END IF;
    --Transfer Mode
    IF funcmode = 'TRANSFER' THEN
      resultout := wf_engine.eng_null;
      RETURN;
    END IF;
    -- CANCEL mode
    IF (funcmode = 'CANCEL') THEN
      resultout := 'COMPLETE:';
      RETURN;
    END IF;
    -- TIMEOUT mode
    IF (funcmode = 'TIMEOUT') THEN
      resultout := 'COMPLETE:';
      RETURN;
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      wf_core.context(G_PKG_NAME,
                      l_api_name,
                       itemtype,
                       itemkey,
                       TO_CHAR(actid),
                       funcmode);
	  RAISE;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      wf_core.context(G_PKG_NAME,
                      l_api_name,
                       itemtype,
                       itemkey,
                       TO_CHAR(actid),
                       funcmode);
	  RAISE;
    WHEN OTHERS THEN
      wf_core.context(G_PKG_NAME,
                      l_api_name,
                       itemtype,
                       itemkey,
                       TO_CHAR(actid),
                       funcmode);
	  RAISE;
  END update_add_khr_apprv_sts;

 ---------------------------------------------------------------------------
 -- PROCEDURE pop_approval_doc
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : pop_approval_doc
  -- Description     :
  -- Business Rules  : This procedure is invoked dynamically by Workflow API's
  --                   in order to populate the message body item attribute
  --                   during notification submission.
  -- Parameters      : document_id, display_type, document, document_type.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE pop_approval_doc (document_id   IN VARCHAR2,
                              display_type  IN VARCHAR2,
                              document      IN OUT nocopy VARCHAR2,
                              document_type IN OUT nocopy VARCHAR2) IS

    l_message      VARCHAR2(32000);
    l_inv_agrmnt_id NUMBER;
    l_pool_id NUMBER;
    l_pool_trans_id     okl_pool_transactions.ID%TYPE;
  BEGIN
        l_inv_agrmnt_id := wf_engine.GetItemAttrText (itemtype  => G_ITEM_TYPE_WF,
                                				      itemkey   => document_id,
                                 			          aname     => G_WF_ITM_INVESTOR_AGRMNT_ID);

        l_pool_id       := wf_engine.GetItemAttrText (itemtype  => G_ITEM_TYPE_WF,
                                				      itemkey   => document_id,
                                 			          aname     => G_WF_ITM_POOL_ID);

       l_pool_trans_id := wf_engine.GetItemAttrText (itemtype  => G_ITEM_TYPE_WF,
                                				           itemkey   => document_id,
                                 			                   aname     => G_WF_ITM_POOL_TRANSACTION_ID);


        document        := compile_msg_for_add_req(l_inv_agrmnt_id, l_pool_id,l_pool_trans_id);
        document_type   := display_type;

        RETURN;

  EXCEPTION
     WHEN OTHERS THEN NULL;

  END pop_approval_doc;

 ---------------------------------------------------------------------------
 -- PROCEDURE check_add_apprv_process
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : check_add_apprv_process
  -- Description     :
  -- Business Rules  : Checks whether the profile option is set to WF or AME
  --                   and sets the parameter accordingly.
  -- Parameters      : itemtype, itemkey, actid, funcmode,resultout.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE check_add_apprv_process( itemtype	 IN  VARCHAR2,
           				                    itemkey  	IN  VARCHAR2,
		                            	    actid		   IN  NUMBER,
  		                                    funcmode	 IN  VARCHAR2,
            				                resultout OUT NOCOPY VARCHAR2 )
    IS
      l_approval_option VARCHAR2(5);
      l_pool_id     okl_pools.ID%TYPE;
      l_inv_agrmnt_id okc_k_headers_v.ID%TYPE;
      l_inv_agrmnt_number okc_k_headers_v.contract_number%TYPE;
      l_pool_number okl_pools_all.pool_number%TYPE;
      l_api_name        CONSTANT VARCHAR2(30) := 'check_add_apprv_process';
      l_pool_trans_id     okl_pool_transactions.ID%TYPE;

    BEGIN
      IF (funcmode = 'RUN') THEN
       		l_approval_option := fnd_profile.value(G_IA_ADD_KHR_APPROVAL_PROCESS);
       		IF l_approval_option = G_IA_ADD_KHR_APPROVAL_AME THEN

            l_inv_agrmnt_id  := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                       itemkey   => itemkey,
                                                       aname     => G_WF_ITM_INVESTOR_AGRMNT_ID);

           l_inv_agrmnt_number := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                          itemkey   => itemkey,
                                                          aname     => G_WF_ITM_INV_AGRMNT_NUMBER);
           l_pool_id  := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                       itemkey   => itemkey,
                                                       aname     => G_WF_ITM_POOL_ID);
           l_pool_number := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                          itemkey   => itemkey,
                                                          aname     => G_WF_ITM_POOL_NUMBER);

          l_pool_trans_id := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                                             itemkey   => itemkey,
                                                                             aname     => G_WF_ITM_POOL_TRANSACTION_ID);


	       wf_engine.SetItemAttrText (itemtype  => itemtype,
                 					                itemkey   => itemkey,
					                                 aname     => G_WF_ITM_MESSAGE_DESCRIPTION,
	         	                           avalue    => compile_msg_for_add_req(l_inv_agrmnt_id, l_pool_id,l_pool_trans_id));

   	       wf_engine.SetItemAttrText (itemtype  => itemtype,
                 					                itemkey   => itemkey,
					                                 aname     => G_WF_ITM_APP_REQUEST_SUB,
	         	                           avalue    => get_message('OKL_IA_ADD_KHR_APPROVAL_SUB',l_inv_agrmnt_number));

	       wf_engine.SetItemAttrText (itemtype  => itemtype,
                 					                itemkey   => itemkey,
					                                 aname     => G_WF_ITM_APP_REMINDER_SUB,
	         	                           avalue    => get_message('OKL_IA_ADD_KHR_APPROVAL_REM',l_inv_agrmnt_number));
           wf_engine.SetItemAttrText (itemtype  => itemtype,
    					              itemkey   => itemkey,
					                  aname     => G_WF_ITM_APP_REMINDER_HEAD,
	         	                           avalue    => get_message('OKL_IA_ADD_KHR_APPROVAL_REM',l_inv_agrmnt_number));

	       wf_engine.SetItemAttrText (itemtype  => itemtype,
                 					                itemkey   => itemkey,
					                                 aname     => G_WF_ITM_APP_APPROVED_SUB,
	         	                           avalue    => get_message('OKL_IA_ADD_KHR_APPROVED_SUB',l_inv_agrmnt_number));
		  wf_engine.SetItemAttrText (itemtype  => itemtype,
                 					                itemkey   => itemkey,
					                                 aname     => G_WF_ITM_APP_APPROVED_HEAD,
	         	                           avalue    => get_message('OKL_IA_ADD_KHR_APPROVED_SUB',l_inv_agrmnt_number));

	          wf_engine.SetItemAttrText (itemtype  => itemtype,
                 					                itemkey   => itemkey,
					                                 aname     => G_WF_ITM_APP_REJECTED_SUB,
	         	                           avalue    => get_message('OKL_IA_ADD_KHR_REJECTED_SUB',l_inv_agrmnt_number));
	          wf_engine.SetItemAttrText (itemtype  => itemtype,
                 					                itemkey   => itemkey,
					                                 aname     => G_WF_ITM_APP_REJECTED_HEAD,
	         	                           avalue    => get_message('OKL_IA_ADD_KHR_REJECTED_SUB',l_inv_agrmnt_number));

     		   resultout := 'COMPLETE:AME';
	    	ELSIF l_approval_option = G_IA_ADD_CONTRACTS_APPRV_WF THEN
		        resultout := 'COMPLETE:WF';
		    END IF;

       RETURN;
     END IF;
      --
      -- CANCEL mode
      --
      IF (funcmode = 'CANCEL') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;
      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        wf_core.context(G_PKG_NAME , l_api_name, itemtype, itemkey, actid, funcmode);
        RAISE;

  END check_add_apprv_process;


 ---------------------------------------------------------------------------
 -- PROCEDURE wf_add_khr_apprv_process
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : wf_add_khr_apprv_process
  -- Description     :
  -- Business Rules  : This is raised when the profile option is WF.
  -- Parameters      : itemtype, itemkey, actid, funcmode,resultout.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE wf_add_khr_apprv_process( itemtype	 IN  VARCHAR2,
	         			                 itemkey  	IN  VARCHAR2,
			                         	 actid		   IN  NUMBER,
			                             funcmode	 IN  VARCHAR2,
				                         resultout OUT NOCOPY VARCHAR2 )IS


    CURSOR l_wf_item_key_csr IS
    SELECT okl_wf_item_s.NEXTVAL item_key
    FROM  dual;

    l_key               VARCHAR2(240);
    l_process           VARCHAR2(30);
   	l_item_type         VARCHAR2(10) ;
    l_pool_id           okl_pools.ID%TYPE;
    l_pool_number       okl_pools.pool_number%TYPE;
    l_pool_trans_id     okl_pool_transactions.ID%TYPE;
    l_agreement_id      VARCHAR2(240);
   	l_agreement_number  okc_k_headers_v.contract_number%TYPE;
    l_requester 	       VARCHAR2(240);
    l_requester_id      VARCHAR2(240);
   	l_api_name          CONSTANT VARCHAR2(30) := 'wf_add_khr_apprv_process';

    BEGIN

     l_process  := G_APPROVAL_PROCESS_WF;
     l_item_type := G_ITEM_TYPE_WF;

     OPEN l_wf_item_key_csr;
     FETCH l_wf_item_key_csr INTO l_key;
     CLOSE l_wf_item_key_csr;

      IF (funcmode = 'RUN') THEN

        wf_engine.CreateProcess(itemtype	 => l_item_type,
            				                itemkey   => l_key,
                                process   => l_process);

        wf_engine.SetItemParent(itemtype	        => l_item_type,
            				                itemkey  	       => l_key,
                                parent_itemtype  => itemtype,
                                parent_itemkey   => itemkey,
                                parent_context   => G_WF_ITM_MASTER);

        wf_engine.SetItemAttrText (itemtype  => l_item_type,
               				                itemkey   => l_key,
				                               aname     => G_WF_ITM_PARENT_ITEM_KEY,
         	                         avalue    => itemkey);

        wf_engine.SetItemAttrText (itemtype  => l_item_type,
               				                itemkey   => l_key,
				                               aname     => G_WF_ITM_PARENT_ITEM_TYPE,
         	                         avalue    => itemtype);

		-- Re populate Item Attributes for the Detail Process

	        l_agreement_id :=   wf_engine.GetItemAttrText (itemtype  => itemtype,
	                                                      itemkey   => itemkey,
	                                                      aname     => G_WF_ITM_INVESTOR_AGRMNT_ID);

	        l_agreement_number :=   wf_engine.GetItemAttrText (itemtype  => itemtype,
      	                                                    itemkey   => itemkey,
	                                                          aname     => G_WF_ITM_INV_AGRMNT_NUMBER);

	        l_requester :=   wf_engine.GetItemAttrText (itemtype  => itemtype,
	                                                    itemkey   => itemkey,
	                                                    aname     => G_WF_ITM_REQUESTER);

	        l_requester_id :=   wf_engine.GetItemAttrText (itemtype  => itemtype,
	                                                       itemkey   => itemkey,
	                                                       aname     => G_WF_ITM_REQUESTER_ID);

                l_pool_id := wf_engine.GetItemAttrText (itemtype  => itemtype,
	                                                                   itemkey   => itemkey,
	                                                                   aname     => G_WF_ITM_POOL_ID);
               l_pool_number := wf_engine.GetItemAttrText (itemtype  => itemtype,
	                                                                          itemkey   => itemkey,
	                                                                          aname     => G_WF_ITM_POOL_NUMBER);
               l_pool_trans_id := wf_engine.GetItemAttrText (itemtype  => itemtype,
	                                                                          itemkey   => itemkey,
	                                                                          aname     => G_WF_ITM_POOL_TRANSACTION_ID);

               wf_engine.SetItemAttrText (itemtype  => l_item_type,
               					        itemkey   => l_key,
					                aname     => G_WF_ITM_POOL_NUMBER,
	         	                                avalue    => l_pool_number);

               wf_engine.SetItemAttrText (itemtype  => l_item_type,
               					       itemkey   => l_key,
					               aname     => G_WF_ITM_POOL_ID,
	         	                               avalue    => l_pool_id);
               wf_engine.SetItemAttrText (itemtype  => l_item_type,
               					        itemkey   => l_key,
					                aname     => G_WF_ITM_POOL_TRANSACTION_ID,
	         	                                avalue    => l_pool_trans_id);

	        wf_engine.SetItemAttrText (itemtype  => l_item_type,
               					                itemkey   => l_key,
					                               aname     => G_WF_ITM_INVESTOR_AGRMNT_ID,
	         	                         avalue    => l_agreement_id);

	        wf_engine.SetItemAttrText (itemtype  => l_item_type,
               					                itemkey   => l_key,
					                               aname     => G_WF_ITM_INV_AGRMNT_NUMBER,
	         	                         avalue    => l_agreement_number);

	        wf_engine.SetItemAttrText (itemtype  => l_item_type,
               					                itemkey   => l_key,
					                               aname     => G_WF_ITM_REQUESTER,
	         	                         avalue    => l_requester);

	        wf_engine.SetItemAttrText (itemtype  => l_item_type,
					                               itemkey   => l_key,
               					                aname     => G_WF_ITM_REQUESTER_ID,
	         	                         avalue    => l_requester_id);

       -- Set the Message Document
         wf_engine.SetItemAttrDocument (itemtype    => l_item_type,
                                        itemkey     => l_key,
                                        aname   	  	=> G_WF_ITM_MESSAGE_DOC,
                                        documentid  => 'plsql:OKL_SEC_AGREEMENT_WF.pop_approval_doc/'||l_key);

        -- Now, Start the Detail Process
        wf_engine.StartProcess(itemtype	 => l_item_type,
            				               itemkey   => l_key);

        resultout := 'COMPLETE:';
        RETURN;

      END IF;
      --
      -- CANCEL mode
      --
      IF (funcmode = 'CANCEL') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;
      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;

    EXCEPTION
      WHEN OTHERS THEN

        IF l_wf_item_key_csr%ISOPEN THEN
           CLOSE l_wf_item_key_csr;
        END IF;

        wf_core.context(G_PKG_NAME , l_api_name, itemtype, itemkey, actid, funcmode);
        RAISE;

  END wf_add_khr_apprv_process;


 ---------------------------------------------------------------------------
 -- PROCEDURE ame_add_khr_apprv_process
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : ame_add_khr_apprv_process
  -- Description     :
  -- Business Rules  : This is raised when the profile option is AME.
  -- Parameters      : itemtype, itemkey, actid, funcmode,resultout.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE ame_add_khr_apprv_process( itemtype	 IN  VARCHAR2,
			          	                    itemkey  	IN  VARCHAR2,
			                          	    actid		   IN  NUMBER,
			                               funcmode	 IN  VARCHAR2,
				                              resultout OUT NOCOPY VARCHAR2 )IS

    BEGIN

      IF (funcmode = 'RUN') THEN
         wf_engine.SetItemAttrDocument (itemtype     => itemtype,
                                        itemkey      => itemkey,
                                        aname   		   => G_WF_ITM_MESSAGE_DOC,
                                        documentid   => 'plsql:OKL_SEC_AGREEMENT_WF.pop_approval_doc/'||itemkey);

        resultout := 'COMPLETE:';
        RETURN;
      END IF;
      --
      -- CANCEL mode
      --
      IF (funcmode = 'CANCEL') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;
      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        wf_core.context('OKL_SEC_AGREEMENT_WF' , 'AME_APPROVAL_PROCESS', itemtype, itemkey, actid, funcmode);
        RAISE;

  END ame_add_khr_apprv_process;


END OKL_SEC_AGREEMENT_WF;


/
