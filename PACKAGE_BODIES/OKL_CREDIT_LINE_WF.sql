--------------------------------------------------------
--  DDL for Package Body OKL_CREDIT_LINE_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CREDIT_LINE_WF" AS
/* $Header: OKLRDWFB.pls 120.2.12010000.3 2009/12/03 09:31:12 bkatraga ship $ */

  G_NO_MATCHING_RECORD          CONSTANT VARCHAR2(200)  := 'OKL_LLA_NO_MATCHING_RECORD';
  G_REQUIRED_VALUE              CONSTANT VARCHAR2(200)  := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE               CONSTANT VARCHAR2(200)  := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN              CONSTANT VARCHAR2(200)  := OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN	        CONSTANT VARCHAR2(200)   := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN	        CONSTANT VARCHAR2(200)    := OKL_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200)  := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200)  := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200)  := 'SQLcode';
  G_API_TYPE                    CONSTANT VARCHAR2(200)  := '_PVT';
  G_CHAR_AMPERSAND              CONSTANT VARCHAR2(1)    := '&';
-------------------------------------------------------------------------------------------------
----------------------------- Messages and constant names ---------------------------------------
-------------------------------------------------------------------------------------------------
  G_KHR_STATUS_NOT_COMPLETE               VARCHAR2(200)  := 'OKL_LLA_NOT_COMPLETE';
  G_TRANS_APP_NAME              CONSTANT VARCHAR2(200)  := 'OKL LA Credit Line Approval';
  G_INVALID_APP                          VARCHAR2(200)  := 'OKL_LLA_INVALID_APPLICATION';

  G_MSG_TOKEN_CONTRACT_NUMBER   CONSTANT VARCHAR2(30) := 'CONTRACT_NUMBER';
  G_EVENT_APPROVE_WF            CONSTANT VARCHAR2(50) := 'oracle.apps.okl.la.approve_credit_line';
  G_EVENT_APPROVE_AME           CONSTANT VARCHAR2(50) := 'oracle.apps.okl.la.approve_credit_line';
  G_LEASE_CONTRACT_APPROVAL_WF  CONSTANT VARCHAR2(2)  := 'WF';
  G_LEASE_CONTRACT_APPROVAL_AME CONSTANT VARCHAR2(3)  := 'AME';
-- cklee : start: 5/18/2005
  G_TRX_TYPE_CONTRACT_APPROVAL  CONSTANT VARCHAR2(20) := 'CREDIT_LINE_APPROVAL';
  G_TRX_TCN_TYPE                CONSTANT VARCHAR2(3)  := 'CLA';--10/03/2005 cklee. 'CPR';
-- cklee : end: 5/18/2005
  G_TRX_TSU_CODE_SUBMITTED      CONSTANT VARCHAR2(10) := 'SUBMITTED';
  G_TRX_TSU_CODE_PROCESSED      CONSTANT VARCHAR2(10) := 'PROCESSED';
  G_SOURCE_TRX_TYPE_WF          CONSTANT VARCHAR2(10) := 'WF';

  G_KHR_STS_PENDING_APPROVAL    CONSTANT VARCHAR2(20) := 'PENDING_APPROVAL';
  G_KHR_STS_COMPLETE            CONSTANT VARCHAR2(10) := 'COMPLETE';
  G_KHR_STS_INCOMPLETE          CONSTANT VARCHAR2(15) := 'INCOMPLETE';
  G_KHR_STS_APPROVED            CONSTANT VARCHAR2(15) := 'APPROVED';
  G_KHR_STS_DECLINED            CONSTANT VARCHAR2(15) := 'DECLINED';

  G_WF_ITM_CONTRACT_ID         CONSTANT VARCHAR2(20) := 'CONTRACT_ID';
  G_WF_ITM_CONTRACT_NUMBER     CONSTANT VARCHAR2(20) := 'CONTRACT_NUMBER';
  G_WF_ITM_APPLICATION_ID      CONSTANT VARCHAR2(20) := 'APPLICATION_ID';
  G_WF_ITM_TRANSACTION_TYPE_ID CONSTANT VARCHAR2(20) := 'TRX_TYPE_ID';
  G_WF_ITM_TRANSACTION_ID      CONSTANT VARCHAR2(20) := 'TRANSACTION_ID';
  G_WF_ITM_REQUESTER           CONSTANT VARCHAR2(20) := 'REQUESTER';
  G_WF_ITM_REQUESTER_ID        CONSTANT VARCHAR2(20) := 'REQUESTER_ID';
  G_WF_ITM_APPROVER            CONSTANT VARCHAR2(20) := 'APPROVER';
  G_WF_ITM_APPROVAL_REQ_MSG    CONSTANT VARCHAR2(30) := 'APPROVAL_REQUEST_MESSAGE';
  G_WF_ITM_RESULT              CONSTANT VARCHAR2(10) := 'RESULT';
  G_WF_ITM_PARENT_ITEM_KEY     CONSTANT VARCHAR2(20) := 'PARENT_ITEM_KEY';
  G_WF_ITM_PARENT_ITEM_TYPE    CONSTANT VARCHAR2(20) := 'PARENT_ITEM_TYPE';
  G_WF_ITM_APPROVED_YN         CONSTANT VARCHAR2(15) := 'APPROVED_YN';
  G_WF_ITM_MASTER              CONSTANT VARCHAR2(10) := 'MASTER';
  G_WF_ITM_MESSAGE_DESCRIPTION CONSTANT VARCHAR2(30) := 'MESSAGE_DESCRIPTION';
  G_WF_ITM_MESSAGE_DOC         CONSTANT VARCHAR2(15) := 'MESSAGE_DOC';
  G_WF_ITM_MESSAGE_SUBJECT     CONSTANT VARCHAR2(20) := 'MESSAGE_SUBJECT';
  G_WF_ITM_APP_REQUEST_SUB     CONSTANT VARCHAR2(30) := 'APP_REQUEST_SUB';
  G_WF_ITM_APP_REMINDER_SUB    CONSTANT VARCHAR2(30) := 'APP_REMINDER_SUB';
  G_WF_ITM_APP_APPROVED_SUB     CONSTANT VARCHAR2(30) := 'APP_APPROVED_SUB';
  G_WF_ITM_APP_REJECTED_SUB     CONSTANT VARCHAR2(30) := 'APP_REJECTED_SUB';
  G_WF_ITM_APP_REMINDER_HEAD    CONSTANT VARCHAR2(30) := 'APP_REMINDER_HEAD';
  G_WF_ITM_APP_APPROVED_HEAD     CONSTANT VARCHAR2(30) := 'APP_APPROVED_HEAD';
  G_WF_ITM_APP_REJECTED_HEAD     CONSTANT VARCHAR2(30) := 'APP_REJECTED_HEAD';

  G_WF_ITM_RESULT_APPROVED     CONSTANT VARCHAR2(15) := 'APPROVED';
  G_WF_ITM_APPROVED_YN_YES     CONSTANT VARCHAR2(1)  := 'Y';
  G_WF_ITM_APPROVED_YN_NO      CONSTANT VARCHAR2(1)  := 'N';

  G_ITEM_TYPE_WF CONSTANT VARCHAR2(10)         := 'OKLCLAPP';
  G_APPROVAL_PROCESS_WF CONSTANT VARCHAR2(30)  := 'CRTLINE_APPROVAL_WF';

  G_DEFAULT_USER CONSTANT VARCHAR2(10) := 'SYSADMIN';
  G_DEFAULT_USER_DESC CONSTANT VARCHAR2(30) := 'System Administrator';
  G_WF_USER_ORIG_SYSTEM_HR CONSTANT VARCHAR2(5) := 'PER';


 ---------------------------------------------------------------------------
 -- PROCEDURE l_get_agent
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : l_get_agent
  -- Description     :
  -- Business Rules  :
  -- Parameters      : p_user_id, x_return_status, x_name, x_description
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE l_get_agent(p_user_id     IN  NUMBER,
                        x_return_status  OUT NOCOPY VARCHAR2,
                        x_name        OUT NOCOPY VARCHAR2,
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
 -- PROCEDURE l_change_k_status
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : l_change_k_status
  -- Description     :
  -- Business Rules  : This updates the credit line status.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_khr_status, p_chr_id.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE l_change_k_status(p_api_version    IN  NUMBER,
                              p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                              x_return_status  OUT NOCOPY VARCHAR2,
                              x_msg_count      OUT NOCOPY NUMBER,
                              x_msg_data       OUT NOCOPY VARCHAR2,
                              p_khr_status     IN  OKC_K_HEADERS_V.STS_CODE%TYPE,
                              p_chr_id         IN  NUMBER) IS

    l_api_name     CONSTANT VARCHAR2(30) := 'l_change_k_status';
    lx_khr_status  varchar2(30);

  BEGIN
    x_return_status      := OKL_API.G_RET_STS_SUCCESS;
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

--------------------------------------------------------------------------------
-- The status of the credit line will initiate to 'SUBMITTED' and the credit line
-- process API will do the validations before invoke:
-- OKL_CREDIT_LINE_WF.raise_approval_event().
-- cklee May-06-2005
--------------------------------------------------------------------------------
    OKL_CREDIT_PUB.update_credit_line_status(
                            p_api_version    => p_api_version,
                            p_init_msg_list  => p_init_msg_list,
                            x_return_status  => x_return_status,
                            x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data,
                            x_status_code    => lx_khr_status,
                            p_status_code    => p_khr_status,
                            p_credit_line_id => p_chr_id);

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
  END l_change_k_status;

 ---------------------------------------------------------------------------
 -- FUNCTION get_message
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name  : get_message
  -- Description     :
  -- Business Rules  : Sets tha appropriate message for approval and for
  --                   approved or rejected credit line.
  -- Parameters      : p_msg_name, p_contract_number
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  FUNCTION get_message(p_msg_name        IN VARCHAR2,
                       p_contract_number IN VARCHAR2)
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(100);
  BEGIN
    IF p_msg_name IS NOT NULL THEN
       Fnd_Message.SET_NAME(APPLICATION => G_APP_NAME
                           ,NAME => p_msg_name);
       Fnd_Message.SET_TOKEN(TOKEN => G_MSG_TOKEN_CONTRACT_NUMBER,
                             VALUE => p_contract_number);
       l_message := fnd_message.get();
	END IF;

	RETURN l_message;
  EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
  END get_message;

  --------------------------------------------------------------------------------------------------
  ----------------------------------Rasing Business Event ------------------------------------------
  --------------------------------------------------------------------------------------------------
 ---------------------------------------------------------------------------
 -- PROCEDURE raise_approval_event
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : raise_approval_event
  -- Description     :
  -- Business Rules  : Raises the credit line approval event
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_contract_id.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE raise_approval_event (p_api_version    IN  NUMBER,
                                  p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                  x_return_status  OUT NOCOPY VARCHAR2,
                                  x_msg_count      OUT NOCOPY NUMBER,
                                  x_msg_data       OUT NOCOPY VARCHAR2,
                                  p_contract_id    IN  OKC_K_HEADERS_B.ID%TYPE)
  IS

    -- Get Contract Details
    CURSOR c_fetch_k_number(p_contract_id OKC_K_HEADERS_V.ID%TYPE)
    IS
    SELECT chrv.contract_number,
           chrv.sts_code
    FROM okc_k_headers_v chrv
    WHERE chrv.id = p_contract_id;

    -- Get the valid application id from FND
    CURSOR c_get_app_id_csr
    IS
    SELECT APPLICATION_ID
    FROM   FND_APPLICATION
    WHERE  APPLICATION_SHORT_NAME = G_APP_NAME;

    -- Modified cursor by bkatraga for bug 9118673
    -- Get the Transaction Type Id from OAM
    CURSOR c_get_trx_type_csr(c_trx_type  VARCHAR2)
    IS
    SELECT B.TRANSACTION_TYPE_ID,
           B.FND_APPLICATION_ID
      FROM AME_CALLING_APPS B,
           AME_CALLING_APPS_TL T
     WHERE B.APPLICATION_ID = T.APPLICATION_ID
       AND T.LANGUAGE = 'US'
       AND T.APPLICATION_NAME = c_trx_type;

/*  --commented for performance issue#5484903
    SELECT transaction_type_id,
           fnd_application_id
    FROM   AME_CALLING_APPS
    WHERE  application_name = c_trx_type; */

    CURSOR l_wf_item_key_csr IS
    SELECT okl_wf_item_s.NEXTVAL item_key
    FROM  dual;

    CURSOR l_trx_try_csr  IS
    SELECT id
    FROM   okl_trx_types_b
    WHERE  trx_type_class = G_TRX_TYPE_CONTRACT_APPROVAL;


    l_return_status    VARCHAR2(3);
    l_api_version      NUMBER;
    l_api_name         CONSTANT VARCHAR2(30) := 'raise_approval_event';
    l_msg_count	       NUMBER;
    l_init_msg_list    VARCHAR2(10);
    l_msg_data		       VARCHAR2(2000);
    l_parameter_list   wf_parameter_list_t;
    l_key              VARCHAR2(240);
    l_event_name       VARCHAR2(240);
    l_application_id   FND_APPLICATION.APPLICATION_ID%TYPE;
    l_trans_appl_id    AME_CALLING_APPS.APPLICATION_ID%TYPE;
    l_trans_type_id    AME_CALLING_APPS.TRANSACTION_TYPE_ID%TYPE;
   	l_contract_num     OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE;
    l_chrv_id          OKC_K_HEADERS_V.ID%TYPE ;
    l_sts_code         OKC_K_HEADERS_V.STS_CODE%TYPE;
   	l_requester        VARCHAR2(200);
    l_name             VARCHAR2(200);
    l_requester_id     VARCHAR2(200);
    l_trxH_in_rec      Okl_Trx_Contracts_Pvt.tcnv_rec_type;
    l_trxH_out_rec     Okl_Trx_Contracts_Pvt.tcnv_rec_type;
   	l_approval_option  VARCHAR2(5);

  BEGIN

    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_api_version 	 := 1.0;
    l_init_msg_list := OKL_API.G_FALSE;
    l_chrv_id       := p_contract_id;
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

    FOR l_wf_item_key_rec IN l_wf_item_key_csr
    LOOP
        l_key := l_wf_item_key_rec.item_key;
    END LOOP;

    FOR l_trx_try_rec IN l_trx_try_csr
    LOOP
         l_trxH_in_rec.try_id         := l_trx_try_rec.id;
    END LOOP;

    l_trxH_in_rec.tcn_type                   := G_TRX_TCN_TYPE;
    l_trxH_in_rec.tsu_code                   := G_TRX_TSU_CODE_SUBMITTED;
    l_trxH_in_rec.description                := l_requester_id; -- requestor user_id
    l_trxH_in_rec.date_transaction_occurred  := SYSDATE; -- sysdate
    l_trxH_in_rec.source_trx_id              := l_key;
    l_trxH_in_rec.source_trx_type            := G_SOURCE_TRX_TYPE_WF;

  -- Create Transaction Header
    Okl_Trx_Contracts_Pub.create_trx_contracts(p_api_version     => l_api_version
                                               ,p_init_msg_list  => l_init_msg_list
                                               ,x_return_status  => l_return_status
                                               ,x_msg_count      => l_msg_count
                                               ,x_msg_data       => l_msg_data
                                               ,p_tcnv_rec       => l_trxH_in_rec
                                               ,x_tcnv_rec       => l_trxH_out_rec);

    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
	-- end, mvasudev

		l_approval_option := fnd_profile.value('OKL_CREDIT_LINE_APPROVAL_PROCESS');
		IF l_approval_option = G_LEASE_CONTRACT_APPROVAL_AME THEN

	    -- Get the Contract Number
		    OPEN  c_fetch_k_number(l_chrv_id);
		    FETCH c_fetch_k_number INTO l_contract_num,l_sts_code;
		    IF c_fetch_k_number%NOTFOUND THEN
		      OKL_API.set_message(p_app_name     => G_APP_NAME,
		                          p_msg_name     => G_NO_MATCHING_RECORD,
		                          p_token1       => G_COL_NAME_TOKEN,
		                          p_token1_value => 'OKC_K_HEADERS_V.ID');
		      RAISE OKL_API.G_EXCEPTION_ERROR;
		    END IF;
		    CLOSE c_fetch_k_number;

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


		    IF l_application_id = l_trans_appl_id THEN
         l_event_name := G_EVENT_APPROVE_AME;

         wf_event.AddParameterToList(G_WF_ITM_CONTRACT_ID,p_contract_id,l_parameter_list);
         wf_event.AddParameterToList(G_WF_ITM_CONTRACT_NUMBER,l_contract_num,l_parameter_list);
         wf_event.AddParameterToList(G_WF_ITM_APPLICATION_ID,l_application_id,l_parameter_list);
         wf_event.AddParameterToList(G_WF_ITM_TRANSACTION_TYPE_ID,l_trans_type_id,l_parameter_list);
         wf_event.AddParameterToList(G_WF_ITM_TRANSACTION_ID,l_trxH_out_rec.trx_number,l_parameter_list);
         wf_event.AddParameterToList(G_WF_ITM_REQUESTER,l_requester,l_parameter_list);
         wf_event.AddParameterToList(G_WF_ITM_REQUESTER_ID,l_requester_id,l_parameter_list);
	 --added by akrangan
	wf_event.AddParameterToList('ORG_ID',mo_global.get_current_org_id ,l_parameter_list);

		    ELSE
		      OKL_API.set_message(p_app_name     => G_APP_NAME,
		                          p_msg_name     => G_INVALID_APP);
		      RAISE OKL_API.G_EXCEPTION_ERROR;
		    END IF; -- l_application_id

	 	ELSIF l_approval_option = G_LEASE_CONTRACT_APPROVAL_WF THEN
		   l_event_name := G_EVENT_APPROVE_WF;

			  FOR c_fetch_k_number_rec IN c_fetch_k_number(l_chrv_id)
			  LOOP
			    l_contract_num := c_fetch_k_number_rec.contract_number;
			  END LOOP;

     wf_event.AddParameterToList(G_WF_ITM_CONTRACT_ID,p_contract_id,l_parameter_list);
     wf_event.AddParameterToList(G_WF_ITM_CONTRACT_NUMBER,l_contract_num,l_parameter_list);
     wf_event.AddParameterToList(G_WF_ITM_REQUESTER,l_requester,l_parameter_list);
     wf_event.AddParameterToList(G_WF_ITM_REQUESTER_ID,l_requester_id,l_parameter_list);
     wf_event.AddParameterToList(G_WF_ITM_TRANSACTION_ID,l_trxH_out_rec.trx_number,l_parameter_list);
     --added by akrangan
	wf_event.AddParameterToList('ORG_ID',mo_global.get_current_org_id ,l_parameter_list);
    ELSE
	     RAISE OKL_API.G_EXCEPTION_ERROR;
		END IF; -- l_approval_option

    -- We need to status to Approved Pending since We are sending for approval
    l_change_k_status(p_api_version   => p_api_version,
                      p_init_msg_list => p_init_msg_list,
                      x_return_status => x_return_status,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data,
                      p_khr_status    => G_KHR_STS_PENDING_APPROVAL,
                      p_chr_id        => l_chrv_id);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

     -- Raise Event
     wf_event.RAISE(p_event_name => l_event_name,
                    p_event_key  => l_key,
                    p_parameters => l_parameter_list);
     l_parameter_list.DELETE;

    OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                          x_msg_data   => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
      IF c_fetch_k_number%ISOPEN THEN
        CLOSE c_fetch_k_number;
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
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      IF c_fetch_k_number%ISOPEN THEN
        CLOSE c_fetch_k_number;
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
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      IF c_fetch_k_number%ISOPEN THEN
        CLOSE c_fetch_k_number;
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
      -- store SQL error message on message stack
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);
  END raise_approval_event;

 ---------------------------------------------------------------------------
 -- FUNCTION compile_message
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name  : compile_message
  -- Description     :
  -- Business Rules  : Creates the message body of the notifications
  -- Parameters      : p_contract_id
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  FUNCTION compile_message(p_contract_id IN NUMBER)
    RETURN VARCHAR2
  IS

    CURSOR l_okl_crtline_csr(p_contract_id OKC_K_HEADERS_V.ID%TYPE)
    IS
      SELECT ID,
             CONTRACT_NUMBER,
             DESCRIPTION,
             STS_MEANING,
             CURRENCY_CODE,
             CUSTOMER_NAME,
             CUST_ACCT_NUMBER,
             TOTAL_LIMIT,
             START_DATE,
             END_DATE
      FROM okl_creditlines_uv
      WHERE id =  p_contract_id;

    CURSOR l_okl_crtline_contents_csr(p_contract_id OKC_K_HEADERS_V.ID%TYPE)
    IS
      SELECT KHR_ID,
             TODO_ITEM_CODE,
             TODO_ITEM_MEANING,
             MANDATORY_FLAG_MEANING,
             MANDATORY_FLAG,
             CHECK_OFF_RESULTS,
             FUNC_VAL_RSTS_MEANING,
             FUNCTION_ID,
             FUNCTION_NAME,
             CHECKIST_RESULTS
      FROM okl_credit_checklists_uv
      WHERE khr_id =  p_contract_id;

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

--    l_flag          := 'Passed'; -- cklee 06/01/2005
    l_api_version   := 1;
    l_init_msg_list := OKC_API.G_TRUE;
    l_return_status := OKL_API.G_RET_STS_SUCCESS;


    FOR l_okl_crtline_rec IN l_okl_crtline_csr(p_contract_id)
    LOOP
	   -- Start
      l_message := l_message || '<TABLE width="100%" border="0" cellspacing="0" cellpadding="0">';

	  -- Empty Row
      l_message := l_message || '<tr><td colspan=6>' || G_CHAR_AMPERSAND || 'nbsp;</td></tr>';

      l_message := l_message || '<tr><td colspan=6>'
                             || '<table width="100%" border="0" cellspacing="0" cellpadding="0">';

      -- Credit Line, Currency
      l_message := l_message || '<tr><td width="18%" align="right">'
                             || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CREDIT',
     	                                                p_attribute_code => 'OKL_CREDIT')
                             || '</td><td width="1%">' || G_CHAR_AMPERSAND || 'nbsp;</td>'
                             || '<td width="36%"><b>'
                     							 || l_okl_crtline_rec.contract_number
                      						 || '</b></td>'
                     							 || '<td width="13%" align="right">'
                             || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CREDIT',
     	                                                p_attribute_code => 'OKL_CURRENCY')
                     							 || '</td><td width="1%">' || G_CHAR_AMPERSAND || 'nbsp;</td>'
                      						 || '<td width="33%"><b>'
                     							 || l_okl_crtline_rec.currency_code
                     							 || '</b></td>'
                     							 || '</tr>';

		-- Description, Effective From
      l_message := l_message || '<tr><td width="18%" align="right">'
                             || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CREDIT',
     	                                                p_attribute_code => 'OKL_DESCRIPTION')
                             || '</td><td width="1%">' || G_CHAR_AMPERSAND || 'nbsp;</td>'
                             || '<td width="36%"><b>'
                     							 || l_okl_crtline_rec.description
                     							 || '</b></td>'
                     							 || '<td width="13%" align="right">'
	                            || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CREDIT',
     	                                                p_attribute_code => 'OKL_EFFECTIVE_FROM')
                         			 || '</td><td width="1%">' || G_CHAR_AMPERSAND || 'nbsp;</td>'
                     							 || '<td width="33%"><b>'
                     							 || to_date(l_okl_crtline_rec.start_date,'dd-mm-yyyy')
                        				 || '</b></td>'
                     							 || '</tr>';

		-- Customer, Effective To
      l_message := l_message || '<tr><td width="18%" align="right">'
                             || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CREDIT',
     	                                                p_attribute_code => 'OKL_CUSTOMER')
                             || '</td><td width="1%">' || G_CHAR_AMPERSAND || 'nbsp;</td>'
                             || '<td width="36%"><b>'
                       					 || l_okl_crtline_rec.customer_name
                     							 || '</b></td>'
                     							 || '<td width="13%" align="right">'
	                            || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CREDIT',
     	                                                p_attribute_code => 'OKL_EFFECTIVE_TO')
                     							 || '</td><td width="1%">' || G_CHAR_AMPERSAND || 'nbsp;</td>'
                     							 || '<td width="33%"><b>'
                     							 || to_date(l_okl_crtline_rec.end_date,'dd-mm-yyyy')
                     							 || '</b></td>'
                     							 || '</tr>';

		-- Customer Account, Total Credit Limit
      l_message := l_message || '<tr><td width="18%" align="right">'
                             || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CREDIT',
     	                                                p_attribute_code => 'OKL_KDTLS_CUSTOMER_ACCOUNT_N')
                             || '</td><td width="1%">' || G_CHAR_AMPERSAND || 'nbsp;</td>'
                             || '<td width="36%"><b>'
                     							 || l_okl_crtline_rec.cust_acct_number
                      						 || '</b></td>'
                     							 || '<td width="13%" align="right">'
	                            || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CREDIT',
       	                                                p_attribute_code => 'OKL_TOTAL_CREDIT_LIMIT')
		                      				 || '</td><td width="1%">' || G_CHAR_AMPERSAND || 'nbsp;</td>'
                     							 || '<td width="33%"><b>'
                     							 || TO_CHAR(l_okl_crtline_rec.total_limit,'999,999,999,999,999,999.00')
                     							 || '</b></td>'
                     							 || '</tr>';

	  -- Empty Row
      l_message := l_message || '<tr><td colspan=6>' || G_CHAR_AMPERSAND || 'nbsp;</td></tr>';

      FOR each_row IN l_okl_crtline_contents_csr(p_contract_id) LOOP
         l_flag := 'Passed'; -- cklee 06/01/2005
         IF(each_row.mandatory_flag = 'Y' and  each_row.CHECKIST_RESULTS <> 'Passed') THEN --cklee 06/01/2005
           l_flag := 'Failed';
           EXIT;
         END IF;
      END LOOP;

      IF l_flag = 'Passed' THEN
        l_flag := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CHECKLIST',
                                                        p_attribute_code => 'OKL_PASSED');
      ELSIF l_flag = 'Failed' THEN
        l_flag := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CHECKLIST',
                                                        p_attribute_code => 'OKL_FAILED');
      END IF;

	  -- Checklist Validation Result
      l_message := l_message || '<tr><td width="18%" align="right">'
                             || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CREDIT',
     	                                                p_attribute_code => 'OKL_CHKLIST_VAL_RESULT')
                             || '</td><td width="1%">=</td>'
                             || '<td width="36%" colspan="4"><b>'
                             || l_flag
							 || '</b></td>';
	  -- Empty Row
      l_message := l_message || '<tr><td colspan=6>' || G_CHAR_AMPERSAND || 'nbsp;</td></tr>';

   -- End
 	  l_message := l_message || '
                  </TABLE>';

    END LOOP; -- l_okl_crtline_rec

    l_message := l_message || '<table class="x1h" cellpadding="1" cellspacing="0" border="1" width="100%">';

    -- Headers for the creditline details table.
    -- Checklist Item
    l_message := l_message || '<tr> <th scope="col" class="x1r"> <span title="'
                           || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CHECKLIST',
     	                                                p_attribute_code => 'OKL_ITEM')
                           || '" class="x24">'
                           || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CHECKLIST',
     	                                                p_attribute_code => 'OKL_ITEM')
                           || '</span></th>';

    -- Description
    l_message := l_message || '<th scope="col" class="x1r"> <span title="'
                           || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CHECKLIST',
     	                                                p_attribute_code => 'OKL_DESCRIPTION')
                           || '" class="x24">'
                           || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CHECKLIST',
     	                                                p_attribute_code => 'OKL_DESCRIPTION')
                           || '</span></th>';

    -- Function
    l_message := l_message || '<th scope="col" class="x1r"> <span title="'
                           || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CHECKLIST',
     	                                                p_attribute_code => 'OKL_FUNCTION')
                           || '" class="x24">'
                           || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CHECKLIST',
     	                                                p_attribute_code => 'OKL_FUNCTION')
                           || '</span></th>';

    -- Mandatory
    l_message := l_message || '<th scope="col" class="x1r"> <span title="'
                           || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CHECKLIST',
     	                                                p_attribute_code => 'OKL_MANDATORY')
                           || '" class="x24">'
                           || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CHECKLIST',
     	                                                p_attribute_code => 'OKL_MANDATORY')
                           || '</span></th>';

    -- Results
    l_message := l_message || '<th scope="col" class="x1r"> <span title="'
                           || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CHECKLIST',
     	                                                p_attribute_code => 'OKL_RESULTS')
                           || '" class="x24">'
                           || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CHECKLIST',
     	                                                p_attribute_code => 'OKL_RESULTS')
                           || '</span></th></tr>';


    FOR l_okl_crtline_contents_rec IN l_okl_crtline_contents_csr(p_contract_id)
    LOOP
      IF (l_okl_crtline_contents_rec.todo_item_code is not null)THEN
         l_message := l_message || '<tr><td class="x1l x4x">'
                                || l_okl_crtline_contents_rec.todo_item_code
                                || '</td>';
      ELSE
         l_message := l_message || '<tr><td class="x1l x4x"><br></td>';
      END IF;
      IF(l_okl_crtline_contents_rec.todo_item_meaning is not null)THEN
         l_message := l_message || '<td class="x1l x4x">'
                                || l_okl_crtline_contents_rec.todo_item_meaning
                                || '</td>';
      ELSE
         l_message := l_message || '<td class="x1l x4x"><br></td>';
      END IF;
      IF(l_okl_crtline_contents_rec.function_name is not null) THEN
      l_message := l_message || '<td class="x1l x4x">'
                             || l_okl_crtline_contents_rec.function_name
                             || '</td>';
      ELSE
         l_message := l_message || '<td class="x1l x4x"><br></td>';
      END IF;
      IF( l_okl_crtline_contents_rec.mandatory_flag_meaning is not null) THEN
      l_message := l_message || '<td class="x1l x4x">'
                             || l_okl_crtline_contents_rec.mandatory_flag_meaning
                             || '</td>';
      ELSE
         l_message := l_message || '<td class="x1l x4x"><br></td>';
      END IF;
      IF(l_okl_crtline_contents_rec.function_id is not null) THEN
         l_message := l_message || '<td class="x1l x4x">'
                                || l_okl_crtline_contents_rec.func_val_rsts_meaning
                                || '</td></tr>';
      ELSE
         l_message := l_message || '<td class="x1l x4x">'
                                || l_okl_crtline_contents_rec.check_off_results
                                || '</td></tr>';
      END IF;
    END LOOP;
    l_message := l_message || '</table>';

    RETURN l_message;

  EXCEPTION
   WHEN OTHERS THEN
     RETURN NULL;
  END compile_message;

  /*
  -- This API is for Lease Contract Approval via WF
  */
 ---------------------------------------------------------------------------
 -- PROCEDURE get_credit_line_approver
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : get_credit_line_approver
  -- Description     :
  -- Business Rules  : returns whether the approver is found or not.
  -- Parameters      : itemtype, itemkey, actid, funcmode,resultout.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE get_credit_line_approver(itemtype   IN VARCHAR2,
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

    l_api_name         CONSTANT VARCHAR2(200) := 'get_credit_line_approver';
   	l_user_id          VARCHAR2(200);
    l_contract_number  OKC_K_HEADERS_V.contract_number%TYPE;
	   l_return_status    VARCHAR2(1);

  BEGIN
     l_return_status := OKL_API.G_RET_STS_SUCCESS;

	 -- "RUN"
     IF (funcmode = 'RUN') THEN
		 --l_user_id := fnd_profile.value('OKL_LEASE_CONTRACT_APPROVER');
         l_user_id :=   wf_engine.GetItemAttrText (itemtype  => itemtype,
                                                    itemkey   => itemkey,
                                                    aname     => G_WF_ITM_REQUESTER_ID);

         l_contract_number :=   wf_engine.GetItemAttrText (itemtype  => itemtype,
                                                           itemkey   => itemkey,
                                                           aname     => G_WF_ITM_CONTRACT_NUMBER);

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
                             			   aname   			=> G_WF_ITM_MESSAGE_SUBJECT,
                                   avalue     => get_message('OKL_CRTLINE_APPROVAL_SUMMARY',l_contract_number));

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

  END get_credit_line_approver;

 --------------------------------------------------------------------------------------------------
 --------------------------------- Set Approval Status --------------------------------------------
 --------------------------------------------------------------------------------------------------
 ---------------------------------------------------------------------------
 -- PROCEDURE Set_Parent_Attributes
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Set_Parent_Attributes
  -- Description     :
  -- Business Rules  : sets the parent attributes.
  -- Parameters      : itemtype, itemkey, actid, funcmode,resultout.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Set_Parent_Attributes(itemtype  IN  VARCHAR2,
                                  itemkey   IN  VARCHAR2,
                                  actid     IN  NUMBER,
                                  funcmode  IN  VARCHAR2,
                                  resultout OUT NOCOPY VARCHAR2) IS

    l_approved_yn     VARCHAR2(30);
    l_parent_key      VARCHAR2(240);
    l_parent_type     VARCHAR2(240);
    l_result          VARCHAR2(30);
   	l_api_name        CONSTANT VARCHAR2(30) := 'Set_Parent_Attributes';
	   l_contract_number okc_k_headers_v.contract_number%TYPE;

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

       l_contract_number :=   wf_engine.GetItemAttrText (itemtype  => itemtype,
                                                         itemkey   => itemkey,
                                                         aname     => G_WF_ITM_CONTRACT_NUMBER);

      IF l_result = G_WF_ITM_RESULT_APPROVED THEN
        l_approved_yn := G_WF_ITM_APPROVED_YN_YES;
        wf_engine.SetItemAttrText (itemtype   => itemtype,
                            				   itemkey    => itemkey,
                            				   aname   			=> G_WF_ITM_MESSAGE_SUBJECT,
                                   avalue     => get_message('OKL_LLA_REQUEST_APPROVED_SUB',l_contract_number));
      ELSE
        l_approved_yn := G_WF_ITM_APPROVED_YN_NO;
        wf_engine.SetItemAttrText (itemtype   => itemtype,
                            				   itemkey    => itemkey,
                            				   aname   			=> G_WF_ITM_MESSAGE_SUBJECT,
                                   avalue     => get_message('OKL_LLA_REQUEST_REJECTED_SUB',l_contract_number));
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
  END Set_Parent_Attributes;
--------------------------------------------------------------------------------------------------
----------------------------------Main Approval Process ------------------------------------------
--------------------------------------------------------------------------------------------------
 ---------------------------------------------------------------------------
 -- PROCEDURE update_approval_status
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_approval_status
  -- Description     :
  -- Business Rules  : Updates the credit line status from pending approval
  --                   to approved or declined.
  -- Parameters      : itemtype, itemkey, actid, funcmode,resultout.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE update_approval_status(itemtype  IN  VARCHAR2,
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
    --rkuttiya added for 12.1.1. Multi GAAP Project
        AND  representation_type = 'PRIMARY';
    --

    l_return_status	       VARCHAR2(3) ;
    l_api_version          NUMBER	;
    l_msg_count		          NUMBER;
    l_init_msg_list        VARCHAR2(10);
    l_msg_data		           VARCHAR2(2000);
	   l_api_name             CONSTANT VARCHAR2(30) := 'update_approval_status';
    l_chrv_id              OKC_K_HEADERS_V.ID%TYPE;
    l_approved_yn          VARCHAR2(30);
    l_trx_number           VARCHAR2(100);
    lv_approval_status_ame VARCHAR2(10);
    l_trxH_in_rec          Okl_Trx_Contracts_Pvt.tcnv_rec_type;
    l_trxH_out_rec         Okl_Trx_Contracts_Pvt.tcnv_rec_type;

  BEGIN

    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_api_version := 1.0;
    l_init_msg_list  := OKL_API.G_FALSE;

    -- We getting the contract_Id from WF
    l_chrv_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => G_WF_ITM_CONTRACT_ID);
    --Run Mode
    IF funcmode = 'RUN' THEN
      l_approved_yn :=  wf_engine.GetItemAttrText (itemtype  => itemtype,
                                                    itemkey   => itemkey,
                                                    aname     => G_WF_ITM_APPROVED_YN);
      lv_approval_status_ame := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                          itemkey   => itemkey,
                                                          aname     => 'APPROVED_YN');

      IF (l_approved_yn = G_WF_ITM_APPROVED_YN_YES OR lv_approval_status_ame = G_WF_ITM_APPROVED_YN_YES)THEN
         l_change_k_status(p_api_version   => l_api_version,
                           p_init_msg_list => l_init_msg_list,
                           x_return_status => l_return_status,
                           x_msg_count     => l_msg_count,
                           x_msg_data      => l_msg_data,
                           p_khr_status    => G_KHR_STS_APPROVED,
                           p_chr_id        => l_chrv_id);
         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

      ELSE
         l_change_k_status(p_api_version   => l_api_version,
                           p_init_msg_list => l_init_msg_list,
                           x_return_status => l_return_status,
                           x_msg_count     => l_msg_count,
                           x_msg_data      => l_msg_data,
--------------------------------------------------------------------------------
-- cklee's Note: no rejected status available. we use DECLINED instead
--------------------------------------------------------------------------------
                           p_khr_status    => G_KHR_STS_DECLINED,
                           p_chr_id        => l_chrv_id);
         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
      END IF;

      -- trx's trx_number IS wf's trx_id
      l_trx_number :=  wf_engine.GetItemAttrText (itemtype  => itemtype,
                                                  itemkey   => itemkey,
                                                  aname     => G_WF_ITM_TRANSACTION_ID);

      FOR l_okl_trx_contracts_rec IN l_okl_trx_contracts_csr(l_trx_number)
      LOOP
            l_trxH_in_rec.id := l_okl_trx_contracts_rec.id;
      END LOOP;

      l_trxH_in_rec.tsu_code := G_TRX_TSU_CODE_PROCESSED;

      Okl_Trx_Contracts_Pub.update_trx_contracts(
           p_api_version      => l_api_version
          ,p_init_msg_list    => l_init_msg_list
          ,x_return_status    => l_return_status
          ,x_msg_count        => l_msg_count
          ,x_msg_data         => l_msg_data
          ,p_tcnv_rec         => l_trxH_in_rec
          ,x_tcnv_rec         => l_trxH_out_rec);

      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_ERROR;
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
  END update_approval_status;

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
   	l_contract_id  NUMBER;
  BEGIN

        l_contract_id := wf_engine.GetItemAttrText (itemtype  => G_ITEM_TYPE_WF,
                                				                itemkey   => document_id,
                                 			                aname     => G_WF_ITM_CONTRACT_ID);

        document := compile_message(l_contract_id);
        document_type := display_type;

        RETURN;

  EXCEPTION
     WHEN OTHERS THEN NULL;

  END pop_approval_doc;

 ---------------------------------------------------------------------------
 -- PROCEDURE check_approval_process
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : check_approval_process
  -- Description     :
  -- Business Rules  : Checks whether the profile option is set to WF or AME
  --                   and sets the parameter accordingly.
  -- Parameters      : itemtype, itemkey, actid, funcmode,resultout.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE check_approval_process( itemtype	 IN  VARCHAR2,
            				                    itemkey  	IN  VARCHAR2,
			                            	    actid		   IN  NUMBER,
			                                 funcmode	 IN  VARCHAR2,
            				                    resultout OUT NOCOPY VARCHAR2 )
    IS
      l_approval_option VARCHAR2(5);
      l_contract_id     VARCHAR2(240);
      l_contract_number okc_k_headers_b.contract_number%TYPE;
      l_api_name        CONSTANT VARCHAR2(30) := 'check_approval_process';

    BEGIN

      IF (funcmode = 'RUN') THEN
       		l_approval_option := fnd_profile.value('OKL_CREDIT_LINE_APPROVAL_PROCESS');
       		IF l_approval_option = G_LEASE_CONTRACT_APPROVAL_AME THEN

           l_contract_id  := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                       itemkey   => itemkey,
                                                       aname     => G_WF_ITM_CONTRACT_ID);

           l_contract_number := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                          itemkey   => itemkey,
                                                          aname     => G_WF_ITM_CONTRACT_NUMBER);

	          wf_engine.SetItemAttrText (itemtype  => itemtype,
                 					                itemkey   => itemkey,
					                                 aname     => G_WF_ITM_MESSAGE_DESCRIPTION,
	         	                           avalue    => compile_message(l_contract_id));

   	       wf_engine.SetItemAttrText (itemtype  => itemtype,
                 					                itemkey   => itemkey,
					                                 aname     => G_WF_ITM_APP_REQUEST_SUB,
	         	                           avalue    => get_message('OKL_LLA_REQUEST_APPROVAL_SUB',l_contract_number));

	          wf_engine.SetItemAttrText (itemtype  => itemtype,
                 					                itemkey   => itemkey,
					                                 aname     => G_WF_ITM_APP_REMINDER_SUB,
	         	                           avalue    => get_message('OKL_LLA_REQ_APPR_SUB_REMINDER',l_contract_number));

	          wf_engine.SetItemAttrText (itemtype  => itemtype,
                 					                itemkey   => itemkey,
					                                 aname     => G_WF_ITM_APP_APPROVED_SUB,
	         	                           avalue    => get_message('OKL_LLA_REQUEST_APPROVED_SUB',l_contract_number));

	          wf_engine.SetItemAttrText (itemtype  => itemtype,
                 					                itemkey   => itemkey,
					                                 aname     => G_WF_ITM_APP_REJECTED_SUB,
	         	                           avalue    => get_message('OKL_LLA_REQUEST_REJECTED_SUB',l_contract_number));

	          wf_engine.SetItemAttrText (itemtype  => itemtype,
                 					                itemkey   => itemkey,
					                                 aname     => G_WF_ITM_APP_REMINDER_HEAD,
	         	                           avalue    => get_message('OKL_LLA_REQ_APPROVAL_REMINDER',l_contract_number));

	          wf_engine.SetItemAttrText (itemtype  => itemtype,
                 					                itemkey   => itemkey,
					                                 aname     => G_WF_ITM_APP_APPROVED_HEAD,
	         	                           avalue    => get_message('OKL_LLA_REQUEST_APPROVED_SUB',l_contract_number));

	          wf_engine.SetItemAttrText (itemtype  => itemtype,
                 					                itemkey   => itemkey,
					                                 aname     => G_WF_ITM_APP_REJECTED_HEAD,
	         	                           avalue    => get_message('OKL_LLA_REQUEST_REJECTED_SUB',l_contract_number));

     		   resultout := 'COMPLETE:AME';
	    	ELSIF l_approval_option = G_LEASE_CONTRACT_APPROVAL_WF THEN
		        resultout := 'COMPLETE:WF';
		    END IF;

       --resultout := 'COMPLETE:';
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

  END check_approval_process;

 ---------------------------------------------------------------------------
 -- PROCEDURE wf_approval_process
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : wf_approval_process
  -- Description     :
  -- Business Rules  : This is raised when the profile option is WF.
  -- Parameters      : itemtype, itemkey, actid, funcmode,resultout.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE wf_approval_process( itemtype	 IN  VARCHAR2,
	         			                    itemkey  	IN  VARCHAR2,
			                         	    actid		   IN  NUMBER,
			                              funcmode	 IN  VARCHAR2,
				                             resultout OUT NOCOPY VARCHAR2 )IS


    CURSOR l_wf_item_key_csr IS
    SELECT okl_wf_item_s.NEXTVAL item_key
    FROM  dual;

    l_key             VARCHAR2(240);
    l_process         VARCHAR2(30);
   	l_item_type       VARCHAR2(10) ;
    l_contract_id     VARCHAR2(240);
   	l_contract_number okc_k_headers_v.contract_number%TYPE;
    l_requester 	     VARCHAR2(240);
    l_requester_id    VARCHAR2(240);
   	l_api_name        CONSTANT VARCHAR2(30) := 'wf_Approval_Process';

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

	        l_contract_id :=   wf_engine.GetItemAttrText (itemtype  => itemtype,
	                                                      itemkey   => itemkey,
	                                                      aname     => G_WF_ITM_CONTRACT_ID);

	        l_contract_number :=   wf_engine.GetItemAttrText (itemtype  => itemtype,
      	                                                    itemkey   => itemkey,
	                                                          aname     => G_WF_ITM_CONTRACT_NUMBER);

	        l_requester :=   wf_engine.GetItemAttrText (itemtype  => itemtype,
	                                                    itemkey   => itemkey,
	                                                    aname     => G_WF_ITM_REQUESTER);

	        l_requester_id :=   wf_engine.GetItemAttrText (itemtype  => itemtype,
	                                                       itemkey   => itemkey,
	                                                       aname     => G_WF_ITM_REQUESTER_ID);

	        wf_engine.SetItemAttrText (itemtype  => l_item_type,
               					                itemkey   => l_key,
					                               aname     => G_WF_ITM_CONTRACT_ID,
	         	                         avalue    => l_contract_id);

	        wf_engine.SetItemAttrText (itemtype  => l_item_type,
               					                itemkey   => l_key,
					                               aname     => G_WF_ITM_CONTRACT_NUMBER,
	         	                         avalue    => l_contract_number);

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
                                        documentid  => 'plsql:OKL_CREDIT_LINE_WF.pop_approval_doc/'||l_key);

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

  END wf_approval_process;


 ---------------------------------------------------------------------------
 -- PROCEDURE ame_approval_process
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : ame_approval_process
  -- Description     :
  -- Business Rules  : This is raised when the profile option is AME.
  -- Parameters      : itemtype, itemkey, actid, funcmode,resultout.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE ame_approval_process( itemtype	 IN  VARCHAR2,
			          	                    itemkey  	IN  VARCHAR2,
			                          	    actid		   IN  NUMBER,
			                               funcmode	 IN  VARCHAR2,
				                              resultout OUT NOCOPY VARCHAR2 )IS

    BEGIN

      IF (funcmode = 'RUN') THEN
         wf_engine.SetItemAttrDocument (itemtype     => itemtype,
                                        itemkey      => itemkey,
                                        aname   		   => G_WF_ITM_MESSAGE_DOC,
                                        documentid   => 'plsql:OKL_CREDIT_LINE_WF.pop_approval_doc/'||itemkey);

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
        wf_core.context('OKL_CREDIT_LINE_WF' , 'AME_APPROVAL_PROCESS', itemtype, itemkey, actid, funcmode);
        RAISE;

  END AME_APPROVAL_PROCESS;


END OKL_CREDIT_LINE_WF;

/
