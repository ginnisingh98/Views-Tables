--------------------------------------------------------
--  DDL for Package Body OKL_KBK_APPROVALS_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_KBK_APPROVALS_WF" AS
/* $Header: OKLRBWFB.pls 120.11.12010000.3 2009/12/03 09:23:54 bkatraga ship $ */

  G_NO_MATCHING_RECORD          CONSTANT VARCHAR2(200)  := 'OKL_LLA_NO_MATCHING_RECORD';
  G_REQUIRED_VALUE              CONSTANT VARCHAR2(200)  := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE               CONSTANT VARCHAR2(200)  := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN              CONSTANT VARCHAR2(200)  := OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN	        CONSTANT VARCHAR2(200)  := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN	        CONSTANT VARCHAR2(200)  := OKL_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200)  := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200)  := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200)  := 'SQLcode';
  G_API_TYPE                    CONSTANT VARCHAR2(200)  := '_PVT';
  G_CHAR_AMPERSAND              CONSTANT VARCHAR2(1)    := '&';
-------------------------------------------------------------------------------------------------
----------------------------- Messages and constant names ---------------------------------------
-------------------------------------------------------------------------------------------------
  G_KHR_STATUS_NOT_COMPLETE               VARCHAR2(200)  := 'OKL_LLA_NOT_COMPLETE';
  G_TRANS_APP_NAME              CONSTANT VARCHAR2(200)  := 'OKL LA Contract Booking Approval';
  G_INVALID_APP                          VARCHAR2(200)  := 'OKL_LLA_INVALID_APPLICATION';

  --mvasudev
  G_MSG_TOKEN_CONTRACT_NUMBER   CONSTANT VARCHAR2(30) := 'CONTRACT_NUMBER';
  G_EVENT_APPROVE_WF            CONSTANT VARCHAR2(50) := 'oracle.apps.okl.la.approve_lease_contract';
  G_EVENT_APPROVE_AME           CONSTANT VARCHAR2(50) := 'oracle.apps.okl.la.approve_lease_contract';
  G_LEASE_CONTRACT_APPROVAL_WF  CONSTANT VARCHAR2(2)  := 'WF';
  G_LEASE_CONTRACT_APPROVAL_AME CONSTANT VARCHAR2(3)  := 'AME';
  G_TRX_TYPE_CONTRACT_APPROVAL  CONSTANT VARCHAR2(20) := 'CONTRACT_APPROVAL';
  G_TRX_TCN_TYPE                CONSTANT VARCHAR2(3)  := 'APR';
  G_TRX_TSU_CODE_SUBMITTED      CONSTANT VARCHAR2(10) := 'SUBMITTED';
  G_TRX_TSU_CODE_PROCESSED      CONSTANT VARCHAR2(10) := 'PROCESSED';
  G_SOURCE_TRX_TYPE_WF          CONSTANT VARCHAR2(10) := 'WF';

  G_KHR_STS_PENDING_APPROVAL    CONSTANT VARCHAR2(20) := 'PENDING_APPROVAL';
  G_KHR_STS_COMPLETE            CONSTANT VARCHAR2(10) := 'COMPLETE';
  G_KHR_STS_INCOMPLETE          CONSTANT VARCHAR2(15) := 'INCOMPLETE';
  G_KHR_STS_APPROVED            CONSTANT VARCHAR2(15) := 'APPROVED';

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

  G_ITEM_TYPE_WF CONSTANT VARCHAR2(10)         := 'OKLLAAPP';
  G_APPROVAL_PROCESS_WF CONSTANT VARCHAR2(30)  := 'KBK_APPROVAL_WF';

  G_ITEM_TYPE_AME CONSTANT VARCHAR2(10)        := 'OKLAMAPP';
  G_APPROVAL_PROCESS_AME CONSTANT VARCHAR2(30) := 'APPROVAL_PROC';

  G_DEFAULT_USER CONSTANT VARCHAR2(10) := 'SYSADMIN';
  G_DEFAULT_USER_DESC CONSTANT VARCHAR2(30) := 'System Administrator';
  G_WF_USER_ORIG_SYSTEM_HR CONSTANT VARCHAR2(5) := 'PER';


  --------------------------------------------------------------------------------------------------
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

  --------------------------------------------------------------------------------------------------
  PROCEDURE l_change_k_status(p_api_version    IN  NUMBER,
                              p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                              x_return_status  OUT NOCOPY VARCHAR2,
                              x_msg_count      OUT NOCOPY NUMBER,
                              x_msg_data       OUT NOCOPY VARCHAR2,
                              p_khr_status     IN  OKC_K_HEADERS_V.STS_CODE%TYPE,
                              p_chr_id         IN  NUMBER) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'l_change_k_status';
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
    Okl_Contract_Status_Pub.update_contract_status(
                            p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_khr_status    => p_khr_status,
                            p_chr_id        => p_chr_id);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --call to cascade status on to lines
    Okl_Contract_Status_Pub.cascade_lease_status(
                            p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_chr_id        => p_chr_id);

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

  FUNCTION get_message(p_msg_name IN VARCHAR2,p_contract_number IN VARCHAR2)
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
  PROCEDURE raise_approval_event (p_api_version    IN  NUMBER,
                                           p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                           x_return_status  OUT NOCOPY VARCHAR2,
                                           x_msg_count      OUT NOCOPY NUMBER,
                                           x_msg_data       OUT NOCOPY VARCHAR2,
                                           p_contract_id IN OKC_K_HEADERS_B.ID%TYPE)
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
    -- Changed CURSOR c_get_trx_type_csr SQL definition
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

    CURSOR l_wf_item_key_csr IS
    SELECT okl_wf_item_s.NEXTVAL item_key
    FROM  dual;

    CURSOR l_trx_try_csr  IS
    SELECT id
    FROM   okl_trx_types_b
    WHERE  trx_type_class = G_TRX_TYPE_CONTRACT_APPROVAL;

    l_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    l_api_version              NUMBER	:= 1.0;
    l_api_name        CONSTANT VARCHAR2(30) := 'raise_approval_event';
    l_msg_count	               NUMBER;
    l_init_msg_list            VARCHAR2(10) := OKL_API.G_FALSE;
    l_msg_data		       VARCHAR2(2000);

    l_parameter_list           wf_parameter_list_t;
    l_key                      VARCHAR2(240);
    l_event_name               VARCHAR2(240);

    l_application_id           FND_APPLICATION.APPLICATION_ID%TYPE;
    l_trans_appl_id            AME_CALLING_APPS.APPLICATION_ID%TYPE;
    l_trans_type_id            AME_CALLING_APPS.TRANSACTION_TYPE_ID%TYPE;

	l_contract_num             OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE;
    l_chrv_id                  OKC_K_HEADERS_V.ID%TYPE := p_contract_id;
    l_sts_code                 OKC_K_HEADERS_V.STS_CODE%TYPE;

	l_requester                VARCHAR2(200);
    l_name                     VARCHAR2(200);
    l_requester_id                  VARCHAR2(200);

    l_trxH_in_rec        Okl_Trx_Contracts_Pvt.tcnv_rec_type;
    l_trxH_out_rec       Okl_Trx_Contracts_Pvt.tcnv_rec_type;
	l_approval_option VARCHAR2(5);
  --Added by dpsingh for LE Uptake
  l_legal_entity_id          NUMBER;
  BEGIN
    x_return_status      := OKL_API.G_RET_STS_SUCCESS;
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

   -- mvasudev
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



    l_trxH_in_rec.khr_id                     := p_contract_id;
    l_trxH_in_rec.tcn_type                   := G_TRX_TCN_TYPE;
    l_trxH_in_rec.tsu_code                   := G_TRX_TSU_CODE_SUBMITTED;
    l_trxH_in_rec.description                := l_requester_id; -- requestor user_id
    l_trxH_in_rec.date_transaction_occurred  := SYSDATE; -- sysdate
    l_trxH_in_rec.source_trx_id              := l_key;
    l_trxH_in_rec.source_trx_type            := G_SOURCE_TRX_TYPE_WF;

    --Added by dpsingh for LE Uptake
    l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_contract_id) ;
    IF  l_legal_entity_id IS NOT NULL THEN
       l_trxH_in_rec.legal_entity_id :=  l_legal_entity_id;
    ELSE
        Okl_Api.set_message(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_LE_NOT_EXIST_CNTRCT',
			     p_token1           =>  'CONTRACT_NUMBER',
			     p_token1_value  =>  l_contract_num);
         RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
      -- Create Transaction Header
        Okl_Trx_Contracts_Pub.create_trx_contracts(
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
	-- end, mvasudev

		l_approval_option := fnd_profile.value('OKL_LEASE_CONTRACT_APPROVAL_PROCESS');
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
		    IF l_sts_code <> G_KHR_STS_COMPLETE THEN
		      OKL_API.set_message(p_app_name     => G_APP_NAME,
		                          p_msg_name     => G_KHR_STATUS_NOT_COMPLETE);
		      RAISE OKL_API.G_EXCEPTION_ERROR;
		    END IF;

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

  FUNCTION compile_message(p_contract_id IN NUMBER)
    RETURN VARCHAR2
  IS

    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_api_version       NUMBER := 1;
    l_init_msg_list     VARCHAR2(3) := OKC_API.G_TRUE;
    l_return_status     VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;

    l_true_tax         VARCHAR2(200);
    l_cap_amt          NUMBER;
    l_res_value        NUMBER;
--    l_message VARCHAR2(4000);

-- start: cklee 31-May-2005 okl.h Lease App IA Authoring
    l_flag           VARCHAR2(10);
    l_message VARCHAR2(20000);
    l_lease_app_found boolean;
    l_dummy number;
-- end: cklee 31-May-2005 okl.h Lease App IA Authoring

-- Changed query as part of Bug#4693302 by zrehman : starts
    CURSOR l_okl_khr_details_csr(p_contract_id OKC_K_HEADERS_V.ID%TYPE)
    IS
      SELECT chrv.contract_number,
             chrv.sts_code,
             stsv.meaning,
             chrv.description,
             chrv.currency_code,
             pdtv.name product,
             chrv.deal_type,
             chrv.start_date,
             chrv.end_date,
             lgle.name legal_name,
             INITCAP(REPLACE(ru.rule_information1,'_',' ')) eto,
             ru.rule_information2 etm,
             Okl_Am_Util_Pvt.get_party_name(chrv.id,'PRIVATE_LABEL') Pvt_Label,
             chrv.pre_tax_irr,
             chrv.after_tax_irr,
             chrv.implicit_interest_rate,
             chrv.after_tax_yield
      FROM okc_rules_b ru,
           okc_rule_groups_b rg,
           xle_entity_profiles lgle,
           okl_k_headers_full_v chrv,
           okl_products_v pdtv,
           okc_statuses_v stsv
      WHERE chrv.id = p_contract_id
      AND lgle.legal_entity_id = chrv.legal_entity_id
      AND rg.dnz_chr_id = chrv.id
      AND rg.rgd_code = 'AMTFOC'
      AND ru.rgp_id = rg.id
      AND ru.rule_information_category = 'AMBPOC'
      AND pdtv.id = chrv.pdt_id
      AND chrv.sts_code = stsv.code;
-- Changed query as part of Bug#4693302 by zrehman : ends

-- start: cklee 31-May-2005 okl.h Lease App IA Authoring
    CURSOR l_okl_list_contents_csr(p_chr_id OKC_K_HEADERS_B.ID%TYPE)
    IS
      SELECT DNZ_CHECKLIST_OBJ_ID,
             TODO_ITEM_CODE,
             TODO_ITEM_MEANING,
             MANDATORY_FLAG_MEANING,
             MANDATORY_FLAG,
             USER_COMPLETE_FLAG_RESULTS,
             FUNCTION_VALIDATE_RSTS_MEANING,
             FUNCTION_ID,
             FUNCTION_NAME,
             CHECKIST_RESULTS
      FROM okl_instance_checklist_dtl_uv
      WHERE DNZ_CHECKLIST_OBJ_ID =  p_chr_id;

    CURSOR c_contract(p_contract_id OKC_K_HEADERS_B.ID%TYPE)
    IS
select 1
 from okc_k_headers_b
 where ORIG_SYSTEM_SOURCE_CODE = 'OKL_LEASE_APP'
 and id = p_contract_id;
-- end: cklee 31-May-2005 okl.h Lease App IA Authoring

  BEGIN

    --l_message  := Fnd_Message.GET_STRING(G_APP_NAME,'OKL_LLA_REQUEST_APPROVAL');

    FOR l_okl_khr_details_rec IN l_okl_khr_details_csr(p_contract_id)
    LOOP
	   -- Start
      l_message := l_message || '<TABLE width="100%" border="0" cellspacing="0" cellpadding="0">';

	  -- Empty Row
      l_message := l_message || '<tr><td colspan=6>' || G_CHAR_AMPERSAND || 'nbsp;</td></tr>';

      l_message := l_message || '<tr><td colspan=6>'
                             || '<table width="100%" border="0" cellspacing="0" cellpadding="0">';

      -- Contract Number, Status
      l_message := l_message || '<tr><td width="18%" align="right">'
                             || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_CONTRACT_DTLS',
     	                                                p_attribute_code => 'OKL_KDTLS_CONTRACT_NUMBER')
                             || '</td><td width="1%">' || G_CHAR_AMPERSAND || 'nbsp;</td>'
                             || '<td width="36%"><b>'
							 || l_okl_khr_details_rec.contract_number
							 || '</b></td>'
							 || '<td width="13%" align="right">'
                             || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_CONTRACT_DTLS',
     	                                                p_attribute_code => 'OKL_KDTLS_STATUS')
							 || '</td><td width="1%">' || G_CHAR_AMPERSAND || 'nbsp;</td>'
							 || '<td width="33%"><b>'
							 || l_okl_khr_details_rec.meaning
							 || '</b></td>'
							 || '</tr>';

		-- Description, Product
      l_message := l_message || '<tr><td width="18%" align="right">'
                             || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_CONTRACT_DTLS',
     	                                                p_attribute_code => 'OKL_KDTLS_CONTRACT_DESCRIPTION')
                             || '</td><td width="1%">' || G_CHAR_AMPERSAND || 'nbsp;</td>'
                             || '<td width="36%"><b>'
							 || l_okl_khr_details_rec.description
							 || '</b></td>'
							 || '<td width="13%" align="right">'
	                         || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_CONTRACT_DTLS',
     	                                                p_attribute_code => 'OKL_KDTLS_PRODUCT')
							 || '</td><td width="1%">' || G_CHAR_AMPERSAND || 'nbsp;</td>'
							 || '<td width="33%"><b>'
							 || l_okl_khr_details_rec.product
							 || '</b></td>'
							 || '</tr>';



	  -- Empty Row
      l_message := l_message || '<tr><td colspan=6>' || G_CHAR_AMPERSAND || 'nbsp;</td></tr>';

	  -- Currency
      l_message := l_message || '<tr><td width="18%" align="right">'
                             || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_CONTRACT_DTLS',
     	                                                p_attribute_code => 'OKL_KDTLS_CURRENCY')
                             || '</td><td width="1%">=</td>'
                             || '<td width="36%" colspan="4"><b>'
                             || l_okl_khr_details_rec.currency_code
							 || '</b></td>';

	  -- Empty Row
      l_message := l_message || '<tr><td colspan=6>' || G_CHAR_AMPERSAND || 'nbsp;</td></tr>';

	  -- "Properties" Sub Head
      l_message := l_message || '<tr><td align="right" width="16%"><h3><b>'
                             || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CONTRACT_BOOK',
     	                                                p_attribute_code => 'OKL_PROPERTIES')
							 || '</b></h3></td>'
							 || '<td colspan="5" valign="middle">'
							 || '<hr></td></tr>';
       l_message := l_message || '</TABLE></td></tr>';

	  -- Empty Row
      l_message := l_message || '<tr><td colspan=6>' || G_CHAR_AMPERSAND || 'nbsp;</td></tr>';

	  -- Book Classification
	  l_message := l_message || '
		  <tr>
		    <td align="right" width="40%">'
	                || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CONTRACT_BOOK',
     	                                                p_attribute_code => 'OKL_DEAL_TYPE')
			|| '</td>
		    <td width="1%">' || G_CHAR_AMPERSAND || 'nbsp;</td>
		    <td><b>'
       		|| l_okl_khr_details_rec.deal_type
			|| '</b></td>
		    <td colspan=3>' || G_CHAR_AMPERSAND || 'nbsp;</td>
		  </tr>';

	  -- True Tax
        IF l_okl_khr_details_rec.deal_type = 'LEASEOP' OR
           l_okl_khr_details_rec.deal_type = 'LEASEDF' THEN
          l_true_tax := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_HEADER_PROMPTS',
	                                                           p_attribute_code => 'OKL_YES');
        ELSE
          l_true_tax := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_HEADER_PROMPTS',
                                                               p_attribute_code => 'OKL_NO');
        END IF;

	  l_message := l_message || '
		  <tr>
		    <td align="right">'
	                || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CONTRACT_BOOK',
     	                                                p_attribute_code => 'OKL_TRUE_TAX')
			|| '</td>
		    <td>' || G_CHAR_AMPERSAND || 'nbsp;</td>
		    <td><b>'
       		|| l_true_tax
			|| '</b></td>
		    <td colspan=3>' || G_CHAR_AMPERSAND || 'nbsp;</td>
		  </tr>';

      -- Start Date
	  l_message := l_message || '
		  <tr>
		    <td align="right">'
	                || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CONTRACT_BOOK',
     	                                                p_attribute_code => 'OKL_START_DATE')
			|| '</td>
		    <td>' || G_CHAR_AMPERSAND || 'nbsp;</td>
		    <td><b>'
       		|| TO_CHAR(l_okl_khr_details_rec.start_date,'dd-mm-yyyy')
			|| '</b></td>
		    <td colspan=3>' || G_CHAR_AMPERSAND || 'nbsp;</td>
		  </tr>';

      -- End Date
	  l_message := l_message || '
		  <tr>
		    <td align="right">'
	                || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CONTRACT_BOOK',
     	                                                p_attribute_code => 'OKL_END_DATE')
			|| '</td>
		    <td>' || G_CHAR_AMPERSAND || 'nbsp;</td>
		    <td><b>'
       		|| TO_CHAR(l_okl_khr_details_rec.end_date,'dd-mm-yyyy')
			|| '</b></td>
		    <td colspan=3>' || G_CHAR_AMPERSAND || 'nbsp;</td>
		  </tr>';

     -- Legal Entity
	  l_message := l_message || '
		  <tr>
		    <td align="right">'
	                || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CONTRACT_BOOK',
     	                                                p_attribute_code => 'OKL_LEGAL_ENTITY')
			|| '</td>
		    <td>' || G_CHAR_AMPERSAND || 'nbsp;</td>
		    <td><b>'
       		|| l_okl_khr_details_rec.legal_name
			|| '</b></td>
		    <td colspan=3>' || G_CHAR_AMPERSAND || 'nbsp;</td>
		  </tr>';

     -- End of Term Option
	  l_message := l_message || '
		  <tr>
		    <td align="right">'
	                || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CONTRACT_BOOK',
     	                                                p_attribute_code => 'OKL_EOT_OPTION')
			|| '</td>
		    <td>' || G_CHAR_AMPERSAND || 'nbsp;</td>
		    <td><b>'
       		|| l_okl_khr_details_rec.eto
			|| '</b></td>
		    <td colspan=3>' || G_CHAR_AMPERSAND || 'nbsp;</td>
		  </tr>';

      -- End of Term amount
	  l_message := l_message || '
		  <tr>
		    <td align="right">'
	                || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CONTRACT_BOOK',
     	                                                p_attribute_code => 'OKL_EOT_AMOUNT')
			|| '</td>
		    <td>' || G_CHAR_AMPERSAND || 'nbsp;</td>
		    <td><b>'
       		|| TO_CHAR(TO_NUMBER(l_okl_khr_details_rec.etm),'999,999,999,999,999,999.00')
			|| '</b></td>
		    <td colspan=3>' || G_CHAR_AMPERSAND || 'nbsp;</td>
		  </tr>';

     -- Private Label
	  l_message := l_message || '
		  <tr>
		    <td align="right">'
	        || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CONTRACT_BOOK',
     	                                                p_attribute_code => 'OKL_PRIVATE_LABEL')
			|| '</td>
		    <td>' || G_CHAR_AMPERSAND || 'nbsp;</td>
		    <td><b>'
       		|| l_okl_khr_details_rec.pvt_label
			|| '</b></td>
		    <td colspan=3>' || G_CHAR_AMPERSAND || 'nbsp;</td>
		  </tr>';

	  -- Capital Amount
        OKL_EXECUTE_FORMULA_PUB.EXECUTE(p_api_version   => l_api_version,
                                        p_init_msg_list => l_init_msg_list,
                                        x_return_status => l_return_status,
                                        x_msg_count     => l_msg_count,
                                        x_msg_data      => l_msg_data,
                                         --fmiao start bug 5178182
                                        --Changed Formula from CONTRACT_CAP_AMNT to CONTRACT_FINANCED_AMOUNT_BKG
                                        --This formula includes the rollover fee as part of Total Financed fee
                                        --p_formula_name  => 'CONTRACT_CAP_AMNT',
                                        p_formula_name  => 'CONTRACT_FINANCED_AMOUNT_BKG',
                                        --fmiao end bug 5178182
                                        p_contract_id   => p_contract_id,
                                        x_value         => l_cap_amt);
         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
	  l_message := l_message || '
		  <tr>
		    <td align="right">'
	        || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CONTRACT_BOOK',
     	                                                p_attribute_code => 'OKL_TOTAL_FIN_AMOUNT')
			|| '</td>
		    <td>' || G_CHAR_AMPERSAND || 'nbsp;</td>
		    <td><b>'
       		|| TO_CHAR(l_cap_amt,'999,999,999,999,999,999.00')
			|| '</b></td>
		    <td colspan=3>' || G_CHAR_AMPERSAND || 'nbsp;</td>
		  </tr>';

     -- Residual Value
        OKL_EXECUTE_FORMULA_PUB.EXECUTE(p_api_version   => l_api_version,
                                        p_init_msg_list => l_init_msg_list,
                                        x_return_status => l_return_status,
                                        x_msg_count     => l_msg_count,
                                        x_msg_data      => l_msg_data,
                                        p_formula_name  => 'CONTRACT_RESIDUAL_VALUE',
                                        p_contract_id   => p_contract_id,
                                        x_value         => l_res_value);
         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
 	  l_message := l_message || '
		  <tr>
		    <td align="right">'
	        || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CONTRACT_BOOK',
     	                                                p_attribute_code => 'OKL_TOTAL_RES_AMOUNT')
			|| '</td>
		    <td>' || G_CHAR_AMPERSAND || 'nbsp;</td>
		    <td><b>'
       		|| TO_CHAR(l_res_value,'999,999,999,999,999,999.00')
			|| '</b></td>
		    <td colspan=3>' || G_CHAR_AMPERSAND || 'nbsp;</td>
		  </tr>';

	  -- "Yields" Sub Head
      l_message := l_message || '<tr>
                    		    <td align="right">
                     	      <h3><b>'
	                || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CONTRACT_BOOK',
     	                                                p_attribute_code => 'OKL_YIELDS')
                    || '</b></h3>
                		    </td>
                		    <td colspan="5" valign="middle">
                    	      <hr>
                		    </td>
                      </tr>';
     -- Pre tax irr
 	  l_message := l_message || '
		  <tr>
		    <td align="right">'
	        || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CONTRACT_BOOK',
     	                                                p_attribute_code => 'OKL_PRE_TAX_IRR')
			|| '</td>
		    <td>' || G_CHAR_AMPERSAND || 'nbsp;</td>
		    <td><b>'
       		|| l_okl_khr_details_rec.pre_tax_irr
			|| '</b></td>
		    <td colspan=3>' || G_CHAR_AMPERSAND || 'nbsp;</td>
		  </tr>';

     -- After tax irr
 	  l_message := l_message || '
		  <tr>
		    <td align="right">'
	        || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CONTRACT_BOOK',
     	                                                p_attribute_code => 'OKL_AFTER_TAX_IRR')
			|| '</td>
		    <td>' || G_CHAR_AMPERSAND || 'nbsp;</td>
		    <td><b>'
       		|| l_okl_khr_details_rec.after_tax_irr
			|| '</b></td>
		    <td colspan=3>' || G_CHAR_AMPERSAND || 'nbsp;</td>
		  </tr>';

     -- Implicit Interest Rate
 	  l_message := l_message || '
		  <tr>
		    <td align="right">'
	        || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CONTRACT_BOOK',
     	                                                p_attribute_code => 'OKL_IMPLICIT_IR')
			|| '</td>
		    <td>' || G_CHAR_AMPERSAND || 'nbsp;</td>
		    <td><b>'
       		|| l_okl_khr_details_rec.implicit_interest_rate
			|| '</b></td>
		    <td colspan=3>' || G_CHAR_AMPERSAND || 'nbsp;</td>
		  </tr>';
	  -- After tax yield
 	  l_message := l_message || '
		  <tr>
		    <td align="right">'
	        || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CONTRACT_BOOK',
     	                                                p_attribute_code => 'OKL_AFTER_TAXT_ROE')
			|| '</td>
		    <td>' || G_CHAR_AMPERSAND || 'nbsp;</td>
		    <td><b>'
       		|| l_okl_khr_details_rec.after_tax_yield
			|| '</b></td>
		    <td colspan=3>' || G_CHAR_AMPERSAND || 'nbsp;</td>
		  </tr>';

--
-- start: cklee 31-May-2005 okl.h Lease App IA Authoring
--
	  -- Empty Row
      l_message := l_message || '<tr><td colspan=6>' || G_CHAR_AMPERSAND || 'nbsp;</td></tr>';

      FOR each_row IN l_okl_list_contents_csr(p_contract_id) LOOP
         l_flag := 'Passed';
--         IF(each_row.mandatory_flag = 'Y' and  each_row.check_off_results <> 'Passed') THEN --cklee 06/01/2005
         IF(each_row.mandatory_flag = 'Y' and  each_row.CHECKIST_RESULTS <> 'Passed') THEN
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

--
-- end: cklee 31-May-2005 okl.h Lease App IA Authoring
--

	  -- End
 	  l_message := l_message || '
                  </TABLE>';

    END LOOP; -- l_okl_khr_details_csr

--
-- start: cklee 31-May-2005 okl.h Lease App IA Authoring
--
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


    FOR l_okl_list_contents_rec IN l_okl_list_contents_csr(p_contract_id)
    LOOP
      IF (l_okl_list_contents_rec.todo_item_code is not null)THEN
         l_message := l_message || '<tr><td class="x1l x4x">'
                                || l_okl_list_contents_rec.todo_item_code
                                || '</td>';
      ELSE
         l_message := l_message || '<tr><td class="x1l x4x"><br></td>';
      END IF;
      IF(l_okl_list_contents_rec.todo_item_meaning is not null)THEN
         l_message := l_message || '<td class="x1l x4x">'
                                || l_okl_list_contents_rec.todo_item_meaning
                                || '</td>';
      ELSE
         l_message := l_message || '<td class="x1l x4x"><br></td>';
      END IF;
      IF(l_okl_list_contents_rec.function_name is not null) THEN
      l_message := l_message || '<td class="x1l x4x">'
                             || l_okl_list_contents_rec.function_name
                             || '</td>';
      ELSE
         l_message := l_message || '<td class="x1l x4x"><br></td>';
      END IF;
      IF( l_okl_list_contents_rec.mandatory_flag_meaning is not null) THEN
      l_message := l_message || '<td class="x1l x4x">'
                             || l_okl_list_contents_rec.mandatory_flag_meaning
                             || '</td>';
      ELSE
         l_message := l_message || '<td class="x1l x4x"><br></td>';
      END IF;
      IF(l_okl_list_contents_rec.function_id is not null) THEN
         l_message := l_message || '<td class="x1l x4x">'
                                || l_okl_list_contents_rec.FUNCTION_VALIDATE_RSTS_MEANING
                                || '</td></tr>';
      ELSE
         l_message := l_message || '<td class="x1l x4x">'
                                || l_okl_list_contents_rec.USER_COMPLETE_FLAG_RESULTS
                                || '</td></tr>';
      END IF;
    END LOOP;
    l_message := l_message || '</table>';
--
-- end: cklee 31-May-2005 okl.h Lease App IA Authoring
--

    RETURN l_message;

  EXCEPTION
   WHEN OTHERS THEN
     RETURN NULL;
  END compile_message;

  /*
  -- This API is for Lease Contract Approval via WF
  */
  PROCEDURE Get_Lease_Contract_Approver(itemtype   IN VARCHAR2,
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

    l_api_name VARCHAR2(200) := 'Get_Lease_Contract_Approver';

	l_user_id   VARCHAR2(200);
    l_contract_number       OKC_K_HEADERS_V.contract_number%TYPE;

	l_return_status VARCHAR2(1);

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


                wf_engine.SetItemAttrText (itemtype            => itemtype,
				   itemkey             => itemkey,
				   aname   			=> G_WF_ITM_MESSAGE_SUBJECT,
                  avalue              => get_message('OKL_LLA_REQUEST_APPROVAL_SUB',l_contract_number));

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

  END Get_Lease_Contract_Approver;

 --------------------------------------------------------------------------------------------------
 --------------------------------- Set Approval Status --------------------------------------------
 --------------------------------------------------------------------------------------------------
  PROCEDURE Set_Parent_Attributes(itemtype  IN VARCHAR2,
                                itemkey   IN VARCHAR2,
                                actid     IN NUMBER,
                                funcmode  IN VARCHAR2,
                                resultout OUT  NOCOPY VARCHAR2) IS

    l_approved_yn     VARCHAR2(30);
    l_parent_key                    VARCHAR2(240);
    l_parent_type                  VARCHAR2(240);
    l_result   VARCHAR2(30);
	l_api_name          VARCHAR2(30) := 'Set_Parent_Attributes';
	l_contract_number okc_k_headers_v.contract_number%TYPE;

  BEGIN
    SAVEPOINT set_atts;
    IF (funcmode = 'RUN') THEN
      -- Get current approval status
      l_result := wf_engine.GetItemAttrText (itemtype  => itemtype,
                                                  itemkey   => itemkey,
                                                  aname     => G_WF_ITM_RESULT);

       l_parent_key :=  wf_engine.GetItemAttrText (itemtype            => itemtype,
				                itemkey             => itemkey,
				                aname               => G_WF_ITM_PARENT_ITEM_KEY);

       l_parent_type :=  wf_engine.GetItemAttrText (itemtype            => itemtype,
				                itemkey             => itemkey,
				                aname               => G_WF_ITM_PARENT_ITEM_TYPE);

       l_contract_number :=   wf_engine.GetItemAttrText (itemtype  => itemtype,
                                                    itemkey   => itemkey,
                                                    aname     => G_WF_ITM_CONTRACT_NUMBER);

      IF l_result = G_WF_ITM_RESULT_APPROVED THEN
        l_approved_yn := G_WF_ITM_APPROVED_YN_YES;
                wf_engine.SetItemAttrText (itemtype            => itemtype,
                        				   itemkey             => itemkey,
                        				   aname   			=> G_WF_ITM_MESSAGE_SUBJECT,
                                           avalue              => get_message('OKL_LLA_REQUEST_APPROVED_SUB',l_contract_number));
      ELSE
        l_approved_yn := G_WF_ITM_APPROVED_YN_NO;
                wf_engine.SetItemAttrText (itemtype            => itemtype,
                        				   itemkey             => itemkey,
                        				   aname   			=> G_WF_ITM_MESSAGE_SUBJECT,
                                           avalue              => get_message('OKL_LLA_REQUEST_REJECTED_SUB',l_contract_number));
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
  PROCEDURE update_approval_status(itemtype  IN VARCHAR2,
                              itemkey   IN VARCHAR2,
                              actid     IN NUMBER,
                              funcmode  IN VARCHAR2,
                              resultout OUT  NOCOPY VARCHAR2)
  IS
    CURSOR l_okl_trx_contracts_csr(p_trx_number IN VARCHAR2)
	IS
	SELECT id
	FROM   okl_trx_contracts
	WHERE  trx_number = p_trx_number
  --rkuttiya added for 12.1.1 Multi GAAP Project
        AND    representation_type = 'PRIMARY';
  --

    l_return_status	VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    l_api_version       NUMBER	:= 1.0;
    l_msg_count		NUMBER;
    l_init_msg_list     VARCHAR2(10) := OKL_API.G_FALSE;
    l_msg_data		VARCHAR2(2000);
	l_api_name VARCHAR2(30) := 'update_approval_status';

    l_chrv_id           OKC_K_HEADERS_V.ID%TYPE;
    l_approved_yn        VARCHAR2(30);
	l_trx_number VARCHAR2(100);

    l_trxH_in_rec        Okl_Trx_Contracts_Pvt.tcnv_rec_type;
    l_trxH_out_rec       Okl_Trx_Contracts_Pvt.tcnv_rec_type;

  BEGIN
    -- We getting the contract_Id from WF
    l_chrv_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => G_WF_ITM_CONTRACT_ID);
    --Run Mode
    IF funcmode = 'RUN' THEN
      l_approved_yn :=  wf_engine.GetItemAttrText (itemtype  => itemtype,
                                                    itemkey   => itemkey,
                                                    aname     => G_WF_ITM_APPROVED_YN);

      IF l_approved_yn = G_WF_ITM_APPROVED_YN_YES THEN
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

     	  Okl_Contract_Book_Pvt.post_approval_process(p_api_version   => l_api_version,
                           p_init_msg_list => l_init_msg_list,
                           x_return_status => l_return_status,
                           x_msg_count     => l_msg_count,
                           x_msg_data      => l_msg_data,
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
                           p_khr_status    => G_KHR_STS_INCOMPLETE,
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

  -- Start of comments
  --
  -- Procedure Name	: pop_approval_doc
  -- Description	:
  --                  This procedure is invoked dynamically by Workflow API's
  --                  in order to populate the message body item attribute
  --                  during notification submission.
  -- Business Rules	:
  -- Parameters		: document_id, display_type, document, document_type
  -- Version		: 1.0
  --
  -- End of comments
  PROCEDURE pop_approval_doc (document_id   IN VARCHAR2,
                              display_type  IN VARCHAR2,
                              document      IN OUT nocopy VARCHAR2,
                              document_type IN OUT nocopy VARCHAR2) IS

    l_message        VARCHAR2(32000);
	l_contract_id NUMBER;
  BEGIN

        l_contract_id := wf_engine.GetItemAttrText (
                                itemtype            => G_ITEM_TYPE_WF,
				                itemkey             => document_id,
				                aname               => G_WF_ITM_CONTRACT_ID);

        document := compile_message(l_contract_id);
        document_type := display_type;

        RETURN;

  EXCEPTION
     WHEN OTHERS THEN NULL;

  END pop_approval_doc;

  PROCEDURE check_approval_process( itemtype	IN VARCHAR2,
				                    itemkey  	IN VARCHAR2,
			                 	    actid		IN NUMBER,
			                        funcmode	IN VARCHAR2,
				                    resultout OUT NOCOPY VARCHAR2 )
    IS
      l_approval_option VARCHAR2(5);
      l_contract_id VARCHAR2(240);
	  l_contract_number okc_k_headers_b.contract_number%TYPE;

      l_api_name          VARCHAR2(30) := 'check_approval_process';

    BEGIN

      IF (funcmode = 'RUN') THEN
		l_approval_option := fnd_profile.value('OKL_LEASE_CONTRACT_APPROVAL_PROCESS');
		IF l_approval_option = G_LEASE_CONTRACT_APPROVAL_AME THEN

          l_contract_id      := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                       itemkey   => itemkey,
                                                       aname     => G_WF_ITM_CONTRACT_ID);

          l_contract_number      := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                       itemkey   => itemkey,
                                                       aname     => G_WF_ITM_CONTRACT_NUMBER);

                -- smadhava - Bug#5235038 - Modified - Start
                -- Commenting code as DESCRIPITON attribute is not used by WF or AME. Besides
                -- compile_message returns a string which is of length > 4000 which cannot be stored
                -- in WF tables. Hence commenting code.
                /*
	        wf_engine.SetItemAttrText (itemtype            => itemtype,
					                itemkey             => itemkey,
					                aname               => G_WF_ITM_MESSAGE_DESCRIPTION,
	         	                    avalue              => compile_message(l_contract_id));
                */
                -- Set the Message Document
             wf_engine.SetItemAttrText (itemtype            => itemtype,
                                        itemkey             => itemkey,
                                        aname               => G_WF_ITM_MESSAGE_DOC,
                                        avalue              => 'plsql:Okl_Kbk_Approvals_Wf.pop_approval_doc/'|| itemkey);

                -- smadhava - Bug#5235038 - Modified - End

	        wf_engine.SetItemAttrText (itemtype            => itemtype,
					                itemkey             => itemkey,
					                aname               => G_WF_ITM_APP_REQUEST_SUB,
	         	                    avalue              => get_message('OKL_LLA_REQUEST_APPROVAL_SUB',l_contract_number));

	        wf_engine.SetItemAttrText (itemtype            => itemtype,
					                itemkey             => itemkey,
					                aname               => G_WF_ITM_APP_REMINDER_SUB,
	         	                    avalue              => get_message('OKL_LLA_REQ_APPR_SUB_REMINDER',l_contract_number));

	        wf_engine.SetItemAttrText (itemtype            => itemtype,
					                itemkey             => itemkey,
					                aname               => G_WF_ITM_APP_APPROVED_SUB,
	         	                    avalue              => get_message('OKL_LLA_REQUEST_APPROVED_SUB',l_contract_number));

	        wf_engine.SetItemAttrText (itemtype            => itemtype,
					                itemkey             => itemkey,
					                aname               => G_WF_ITM_APP_REJECTED_SUB,
	         	                    avalue              => get_message('OKL_LLA_REQUEST_REJECTED_SUB',l_contract_number));

	        wf_engine.SetItemAttrText (itemtype            => itemtype,
					                itemkey             => itemkey,
					                aname               => G_WF_ITM_APP_REMINDER_HEAD,
	         	                    avalue              => get_message('OKL_LLA_REQ_APPROVAL_REMINDER',l_contract_number));

	        wf_engine.SetItemAttrText (itemtype            => itemtype,
					                itemkey             => itemkey,
					                aname               => G_WF_ITM_APP_APPROVED_HEAD,
	         	                    avalue              => get_message('OKL_LLA_REQUEST_APPROVED_SUB',l_contract_number));

	        wf_engine.SetItemAttrText (itemtype            => itemtype,
					                itemkey             => itemkey,
					                aname               => G_WF_ITM_APP_REJECTED_HEAD,
	         	                    avalue              => get_message('OKL_LLA_REQUEST_REJECTED_SUB',l_contract_number));


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

  PROCEDURE wf_approval_process( itemtype	IN VARCHAR2,
				                    itemkey  	IN VARCHAR2,
			                 	    actid		IN NUMBER,
			                        funcmode	IN VARCHAR2,
				                    resultout OUT NOCOPY VARCHAR2 )IS


    CURSOR l_wf_item_key_csr IS
    SELECT okl_wf_item_s.NEXTVAL item_key
    FROM  dual;

    l_key             VARCHAR2(240);
    l_process         VARCHAR2(30) := G_APPROVAL_PROCESS_WF;
	l_item_type       VARCHAR2(10) := G_ITEM_TYPE_WF;

    l_contract_id VARCHAR2(240);
	l_contract_number okc_k_headers_v.contract_number%TYPE;
    l_requester 	VARCHAR2(240);
    l_requester_id VARCHAR2(240);

	l_api_name          VARCHAR2(30) := 'wf_Approval_Process';

    BEGIN

	OPEN l_wf_item_key_csr;
	FETCH l_wf_item_key_csr INTO l_key;
	CLOSE l_wf_item_key_csr;

      IF (funcmode = 'RUN') THEN

        wf_engine.CreateProcess(itemtype	        => l_item_type,
				                itemkey  	        => l_key,
                                process             => l_process);

        wf_engine.SetItemParent(itemtype	        => l_item_type,
				                itemkey  	        => l_key,
                                parent_itemtype     => itemtype,
                                parent_itemkey      => itemkey,
                                parent_context      => G_WF_ITM_MASTER);

        wf_engine.SetItemAttrText (
                                itemtype            => l_item_type,
				                itemkey             => l_key,
				                aname               => G_WF_ITM_PARENT_ITEM_KEY,
         	                    avalue              => itemkey);

        wf_engine.SetItemAttrText (
                                itemtype            => l_item_type,
				                itemkey             => l_key,
				                aname               => G_WF_ITM_PARENT_ITEM_TYPE,
         	                    avalue              => itemtype);

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

	        wf_engine.SetItemAttrText (
	                                itemtype            => l_item_type,
					                itemkey             => l_key,
					                aname               => G_WF_ITM_CONTRACT_ID,
	         	                    avalue              => l_contract_id);

	        wf_engine.SetItemAttrText (
	                                itemtype            => l_item_type,
					                itemkey             => l_key,
					                aname               => G_WF_ITM_CONTRACT_NUMBER,
	         	                    avalue              => l_contract_number);

	        wf_engine.SetItemAttrText (
	                                itemtype            => l_item_type,
					                itemkey             => l_key,
					                aname               => G_WF_ITM_REQUESTER,
	         	                    avalue              => l_requester);
	        wf_engine.SetItemAttrText (
	                                itemtype            => l_item_type,
					                itemkey             => l_key,
					                aname               => G_WF_ITM_REQUESTER_ID,
	         	                    avalue              => l_requester_id);

		-- Set the Message Document
             wf_engine.SetItemAttrText (itemtype            => l_item_type,
                                        itemkey             => l_key,
                                        aname   			=> G_WF_ITM_MESSAGE_DOC,
                                        avalue              => 'plsql:Okl_Kbk_Approvals_Wf.pop_approval_doc/'||l_key);

        -- Now, Start the Detail Process
        wf_engine.StartProcess(itemtype	            => l_item_type,
				               itemkey  	        => l_key);

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


END Okl_Kbk_Approvals_Wf;

/
