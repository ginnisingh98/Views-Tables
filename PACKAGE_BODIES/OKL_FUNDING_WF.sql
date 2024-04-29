--------------------------------------------------------
--  DDL for Package Body OKL_FUNDING_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_FUNDING_WF" AS
/* $Header: OKLRFUNB.pls 120.18.12010000.7 2010/02/18 08:10:08 rpillay ship $ */

  G_NO_MATCHING_RECORD          CONSTANT VARCHAR2(200)  := 'OKL_LLA_NO_MATCHING_RECORD';
  G_REQUIRED_VALUE              CONSTANT VARCHAR2(200)  := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE               CONSTANT VARCHAR2(200)  := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN              CONSTANT VARCHAR2(200)  := OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN	        CONSTANT VARCHAR2(200)  := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN	        CONSTANT VARCHAR2(200)  := OKL_API.G_CHILD_TABLE_TOKEN;
--  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200)  := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200)  := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200)  := 'SQLcode';
  G_API_TYPE                    CONSTANT VARCHAR2(200)  := '_PVT';
-------------------------------------------------------------------------------------------------
----------------------------- Messages and constant names ---------------------------------------
-------------------------------------------------------------------------------------------------
--  G_KHR_STATUS_NOT_COMPLETE               VARCHAR2(200)  := 'OKL_LLA_NOT_COMPLETE';
  G_TRANS_APP_NAME              CONSTANT VARCHAR2(200)  := 'OKL LA Funding Approval';
  G_INVALID_APP                          VARCHAR2(200)  := 'OKL_LLA_INVALID_APPLICATION';

  --cklee

  G_MSG_TOKEN_FUNDING_NUMBER   CONSTANT VARCHAR2(30) := 'FUNDING_NUMBER';
  -- mvasudev
  G_EVENT_APPROVE_WF            CONSTANT VARCHAR2(50) := 'oracle.apps.okl.la.approve_lease_funding';
  G_EVENT_APPROVE_AME           CONSTANT VARCHAR2(50) := 'oracle.apps.okl.la.approve_lease_funding';
  G_LEASE_FUNDING_APPROVAL_WF  CONSTANT VARCHAR2(2)  := 'WF';
  G_LEASE_FUNDING_APPROVAL_AME CONSTANT VARCHAR2(3)  := 'AME';
  G_TRX_TYPE_FUNDING_APPROVAL  CONSTANT VARCHAR2(20) := 'FUNDING_APPROVAL';
  G_TRX_TCN_TYPE                CONSTANT VARCHAR2(3)  := 'FAP';
  G_TRX_TSU_CODE_SUBMITTED      CONSTANT VARCHAR2(10) := 'SUBMITTED';
  G_TRX_TSU_CODE_PROCESSED      CONSTANT VARCHAR2(10) := 'PROCESSED';
  G_SOURCE_TRX_TYPE_WF          CONSTANT VARCHAR2(10) := 'WF';

  G_KHR_STS_PENDING_APPROVAL    CONSTANT VARCHAR2(20) := 'PENDING_APPROVAL';
  G_KHR_STS_COMPLETE            CONSTANT VARCHAR2(10) := 'COMPLETE';
  G_KHR_STS_INCOMPLETE          CONSTANT VARCHAR2(15) := 'INCOMPLETE';
  G_KHR_STS_APPROVED            CONSTANT VARCHAR2(15) := 'APPROVED';

  G_WF_ITM_FUNDING_ID         CONSTANT VARCHAR2(20) := 'FUNDING_ID';
  G_WF_ITM_FUNDING_NUMBER     CONSTANT VARCHAR2(20) := 'FUNDING_NUMBER';
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

  G_ITEM_TYPE_WF CONSTANT VARCHAR2(10)         := 'OKLLAFUN';
  G_APPROVAL_PROCESS_WF CONSTANT VARCHAR2(30)  := 'FUN_APPROVAL_WF';

  G_ITEM_TYPE_AME CONSTANT VARCHAR2(10)        := 'OKLAMAPP';
  G_APPROVAL_PROCESS_AME CONSTANT VARCHAR2(30) := 'APPROVAL_PROC';

  G_DEFAULT_USER CONSTANT VARCHAR2(10) := 'SYSADMIN';
  G_DEFAULT_USER_DESC CONSTANT VARCHAR2(30) := 'SYSTEM Administrator';
  G_WF_USER_ORIG_SYSTEM_HR CONSTANT VARCHAR2(5) := 'PER';

 ----------------------------------------------------------------------------
 -- Data Structures
 ----------------------------------------------------------------------------
 subtype tapv_rec_type is okl_tap_pvt.tapv_rec_type;
 subtype tapv_tbl_type is okl_tap_pvt.tapv_tbl_type;
 subtype tplv_rec_type is okl_tpl_pvt.tplv_rec_type;
 subtype tplv_tbl_type is okl_tpl_pvt.tplv_tbl_type;


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
--------------------------------------------------------------------------------------------------
  PROCEDURE l_update_funding_status(p_api_version    IN  NUMBER,
                              p_init_msg_list  IN  VARCHAR2,
                              x_return_status  OUT NOCOPY VARCHAR2,
                              x_msg_count      OUT NOCOPY NUMBER,
                              x_msg_data       OUT NOCOPY VARCHAR2,
                              p_funding_status    IN  OKL_TRX_AP_INVOICES_B.TRX_STATUS_CODE%TYPE,
                              p_funding_id        IN  OKL_TRX_AP_INVOICES_B.ID%TYPE) IS

    l_tapv_rec            tapv_rec_type;
    x_tapv_rec            tapv_rec_type;
    l_api_name      CONSTANT VARCHAR2(30) := 'LOCAL_STATUS';

    funding_line_id   number;

-- Fix BPD Bug. these columns will be overridden by tapi
    CURSOR c_tap (p_funding_id OKL_TRX_AP_INVOICES_B.ID%TYPE)
    IS
      SELECT h.VENDOR_INVOICE_NUMBER,
             h.PAY_GROUP_LOOKUP_CODE,
             h.NETTABLE_YN,
             h.FUNDING_TYPE_CODE,
             h.INVOICE_TYPE,
             --Bug# 5690875
             h.KHR_ID
        FROM OKL_TRX_AP_INVOICES_B h
       WHERE h.id = p_funding_id
    ;

    r_tap c_tap%ROWTYPE;

  --- vpanwar 21/02/2007 Added
  --- to get all the funding lines for the funding header
    CURSOR fund_line_csr(p_fund_id number) IS
        Select id funding_line_id
        from OKL_TXL_AP_INV_LNS_B
        Where tap_id = p_fund_id;
  --- vpanwar 21/02/2007 End


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

    -- Get the internal invoice Details
    OPEN  c_tap(p_funding_id);
    FETCH c_tap INTO r_tap;
    CLOSE c_tap;

    l_tapv_rec.id := p_funding_id;
    l_tapv_rec.trx_status_code := p_funding_status;
    l_tapv_rec.vendor_invoice_number := r_tap.vendor_invoice_number;
    l_tapv_rec.pay_group_lookup_code := r_tap.pay_group_lookup_code;
    l_tapv_rec.nettable_yn := r_tap.nettable_yn;
    l_tapv_rec.invoice_type := r_tap.invoice_type; -- cklee 05/17/2004

    IF (l_tapv_rec.trx_status_code = 'APPROVED') THEN
      l_tapv_rec.DATE_FUNDING_APPROVED := sysdate;
    END IF;

    -- update funding status
    OKL_TRX_AP_INVOICES_PUB.UPDATE_TRX_AP_INVOICES(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_tapv_rec      => l_tapv_rec,
      x_tapv_rec      => x_tapv_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Bug# 5690875: Update contract status to 'Incomplete'
    --              when Pre-funding request is Approved
    IF (r_tap.funding_type_code = OKL_FUNDING_PVT.G_PREFUNDING_TYPE_CODE
        AND l_tapv_rec.trx_status_code = 'APPROVED') THEN

      OKL_CONTRACT_STATUS_PUB.cascade_lease_status_edit
        (p_api_version     => p_api_version,
         p_init_msg_list   => p_init_msg_list,
         x_return_status   => x_return_status,
         x_msg_count       => x_msg_count,
         x_msg_data        => x_msg_data,
         p_chr_id          => r_tap.khr_id);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;

    -- creates internal accounting entry if trx_status_code = 'APPROVED'
    IF (l_tapv_rec.trx_status_code = 'APPROVED') THEN

--start:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |
/*       --- vpanwar 21/02/2007 Added
    OPEN fund_line_csr(l_tapv_rec.id);
    LOOP
    FETCH fund_line_csr into funding_line_id;

    EXIT WHEN fund_line_csr%NOTFOUND;
*/
--start:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |

        OKL_FUNDING_PVT.CREATE_ACCOUNTING_DIST
                          (p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           p_status        => l_tapv_rec.trx_status_code,
--start:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |
                           p_fund_id       => l_tapv_rec.id);--,--start:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |
--                           p_fund_line_id  => funding_line_id);
--end:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

--start:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |
--    END LOOP;
--    CLOSE fund_line_csr;
    --- vpanwar 21/02/2007 End
--end:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |

      -------------------------------------------------------------
      -- create subsidy entries for 11.5.10
      -------------------------------------------------------------
      IF (r_tap.FUNDING_TYPE_CODE = OKL_FUNDING_PVT.G_ASSET_TYPE_CODE) THEN

        OKL_FUNDING_PVT.create_fund_asset_subsidies(
                           p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           p_status        => l_tapv_rec.trx_status_code,
                           p_fund_id       => l_tapv_rec.id);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

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
  END l_update_funding_status;

---------------------------------------------------------------------------------------------------------
  FUNCTION get_message(p_msg_name IN VARCHAR2,p_funding_number IN VARCHAR2)
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(100);
  BEGIN
    IF p_msg_name IS NOT NULL THEN
       Fnd_Message.SET_NAME(APPLICATION => G_APP_NAME
                           ,NAME => p_msg_name);
       Fnd_Message.SET_TOKEN(TOKEN => G_MSG_TOKEN_FUNDING_NUMBER,
                             VALUE => p_funding_number);
       l_message := fnd_message.get();
	END IF;

	RETURN l_message;
  EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
  END get_message;

-------------------------------------------------------------------------------------------------
--------------------------------- Step 1: Rasing Business Event ---------------------------------
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-- Start of Comments
-- API Name  : raise_approval_event
-- TYPE      : WF
-- Purpose   : Process API to Launch funding Approval Process.
-- Modification History
--              23-JUN-2003  cklee Created
--              18-Jun-2009  7594853 sechawla -- Set the Org, User ID, Responsibility Id and Application Id as
--                                               workflow attributes
-- Notes    : Step 1
-- End of Comments
-------------------------------------------------------------------------------------------------


  PROCEDURE raise_approval_event (p_api_version    IN  NUMBER,
                                  p_init_msg_list  IN  VARCHAR2,
                                  x_return_status  OUT NOCOPY VARCHAR2,
                                  x_msg_count      OUT NOCOPY NUMBER,
                                  x_msg_data       OUT NOCOPY VARCHAR2,
                                  p_funding_id     IN OKL_TRX_AP_INVOICES_B.ID%TYPE)
  IS

    CURSOR c_fetch_funding_number(p_funding_id OKL_TRX_AP_INVOICES_B.ID%TYPE)
    IS
    SELECT tap.vendor_invoice_number
    FROM okl_trx_ap_invoices_b tap
    WHERE tap.id  = p_funding_id;

  --Added by dpsingh for LE uptake
  -- sjalasut, modified the cursor to include okl_txl_ap_inv_lns_all_b as khr_id
  -- now resides in this table. changes made as part of OKLR12B disbursements project
  CURSOR contract_num_csr (p_funding_id OKL_TRX_AP_INVOICES_B.ID%TYPE) IS
  SELECT con.contract_number,con.id
  FROM OKL_TRX_AP_INVOICES_B ap_inv
      ,OKC_K_HEADERS_B con
      ,okl_txl_ap_inv_lns_all_b tpl
  WHERE ap_inv.id = tpl.tap_id
    AND tpl.khr_id = con.id
    AND ap_inv.id  = p_funding_id;

  l_cntrct_number          OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
  l_legal_entity_id          NUMBER;
  l_con_id                     NUMBER;

    -- Get the valid application id from FND
    CURSOR c_get_app_id_csr
    IS
    SELECT APPLICATION_ID
    FROM   FND_APPLICATION
    WHERE  APPLICATION_SHORT_NAME = G_APP_NAME;

    -- Modified cursor by bkatraga for bug 9313918
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
    WHERE  trx_type_class = G_TRX_TYPE_FUNDING_APPROVAL;

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

    l_invoice_number            OKL_TRX_AP_INVOICES_B.VENDOR_INVOICE_NUMBER%TYPE;
    l_sts_code                 OKC_K_HEADERS_V.STS_CODE%TYPE;

	l_requester                VARCHAR2(200);
    l_name                     VARCHAR2(200);
    l_requester_id                  VARCHAR2(200);

    l_trxH_in_rec        Okl_Trx_Contracts_Pvt.tcnv_rec_type;
    l_trxH_out_rec       Okl_Trx_Contracts_Pvt.tcnv_rec_type;
	l_approval_option VARCHAR2(5);

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

   -- cklee
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
     --Added by dpsingh for LE Uptake
    -- get the contract number
       OPEN contract_num_csr(p_funding_id);
       FETCH contract_num_csr INTO l_cntrct_number,l_con_id;
       CLOSE contract_num_csr;

    l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(l_con_id) ;
    IF  l_legal_entity_id IS NOT NULL THEN
       l_trxH_in_rec.legal_entity_id :=  l_legal_entity_id;
    ELSE
       Okl_Api.set_message(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_LE_NOT_EXIST_CNTRCT',
			     p_token1           =>  'CONTRACT_NUMBER',
			     p_token1_value  =>  l_cntrct_number);
         RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_trxH_in_rec.tcn_type                   := G_TRX_TCN_TYPE;
    l_trxH_in_rec.tsu_code                   := G_TRX_TSU_CODE_SUBMITTED;
    l_trxH_in_rec.description                := l_requester_id; -- requestor user_id
    l_trxH_in_rec.date_transaction_occurred  := SYSDATE; -- sysdate
    l_trxH_in_rec.source_trx_id              := l_key;
    l_trxH_in_rec.source_trx_type            := G_SOURCE_TRX_TYPE_WF;

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
	-- end, cklee


        -- Get the Vendor Invoice Number
        OPEN  c_fetch_funding_number(p_funding_id);
        FETCH c_fetch_funding_number INTO l_invoice_number;

        IF c_fetch_funding_number%NOTFOUND THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKL_TRX_AP_INVOICES_B.VENDOR_INVOICE_NUMBER');
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        CLOSE c_fetch_funding_number;

        l_update_funding_status(p_api_version   => p_api_version,
                      p_init_msg_list    => p_init_msg_list,
                      x_return_status    => x_return_status,
                      x_msg_count        => x_msg_count,
                      x_msg_data         => x_msg_data,
                      p_funding_status   => 'PENDING_APPROVAL',
                      p_funding_id       => p_funding_id);


        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

		l_approval_option := fnd_profile.value('OKL_LEASE_FUNDING_APPROVAL_PROCESS');
		IF l_approval_option = G_LEASE_FUNDING_APPROVAL_AME THEN

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

  		      wf_event.AddParameterToList(G_WF_ITM_FUNDING_ID,p_funding_id,l_parameter_list);
		      wf_event.AddParameterToList(G_WF_ITM_FUNDING_NUMBER,l_invoice_number,l_parameter_list);
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

	 	ELSIF l_approval_option = G_LEASE_FUNDING_APPROVAL_WF THEN
		      l_event_name := G_EVENT_APPROVE_WF;

		      wf_event.AddParameterToList(G_WF_ITM_FUNDING_ID,p_funding_id,l_parameter_list);
		      wf_event.AddParameterToList(G_WF_ITM_FUNDING_NUMBER,l_invoice_number,l_parameter_list);
		      wf_event.AddParameterToList(G_WF_ITM_REQUESTER,l_requester,l_parameter_list);
		      wf_event.AddParameterToList(G_WF_ITM_REQUESTER_ID,l_requester_id,l_parameter_list);
		      wf_event.AddParameterToList(G_WF_ITM_TRANSACTION_ID,l_trxH_out_rec.trx_number,l_parameter_list);
		      --added by akrangan
		      --wf_event.AddParameterToList('ORG_ID',mo_global.get_current_org_id ,l_parameter_list);



           ELSE
		      RAISE OKL_API.G_EXCEPTION_ERROR;
		END IF; -- l_approval_option

        --Added by sechawla for bug 7594853
        -- Set the User ID, Responsibility Id and Application Id as workflow attributes
		wf_event.AddParameterToList('ORG_ID',mo_global.get_current_org_id ,l_parameter_list);
	    --wf_event.AddParameterToList('ORG_ID',NVL(fnd_profile.value('ORG_ID'),-99),l_parameter_list);
	    wf_event.AddParameterToList('USER_ID',Fnd_Global.User_Id,l_parameter_list);
	    wf_event.AddParameterToList('RESPONSIBILITY_ID',Fnd_Global.Resp_Id,l_parameter_list);
	    wf_event.AddParameterToList('APPLICATION_ID',Fnd_Global.Resp_Appl_Id,l_parameter_list);
	    --end sechawla for bug 7594853

        -- Raise Event
        wf_event.RAISE(p_event_name => l_event_name,
                    p_event_key  => l_key,
                    p_parameters => l_parameter_list);
        l_parameter_list.DELETE;

/* move before raise WF event
     l_update_funding_status(p_api_version   => p_api_version,
                      p_init_msg_list    => p_init_msg_list,
                      x_return_status    => x_return_status,
                      x_msg_count        => x_msg_count,
                      x_msg_data         => x_msg_data,
                      p_funding_status   => 'PENDING_APPROVAL',
                      p_funding_id       => p_funding_id);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
*/
    OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                          x_msg_data   => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
      IF c_fetch_funding_number%ISOPEN THEN
        CLOSE c_fetch_funding_number;
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
      IF c_fetch_funding_number%ISOPEN THEN
        CLOSE c_fetch_funding_number;
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
      IF c_fetch_funding_number%ISOPEN THEN
        CLOSE c_fetch_funding_number;
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
-------------------------------------------------------------------------------------------------------------

  FUNCTION compile_message(p_funding_id IN NUMBER)
    RETURN VARCHAR2
  IS

    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_api_version       NUMBER := 1;
    l_init_msg_list     VARCHAR2(3) := OKC_API.G_TRUE;
    l_return_status     VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;

    l_creditline_id     okc_k_headers_b.id%Type;
-- start: cklee 31-May-2005 okl.h Lease App IA Authoring
    l_flag           VARCHAR2(10);
    l_message VARCHAR2(20000);
    l_lease_app_found boolean;
    l_dummy number;
-- end: cklee 31-May-2005 okl.h Lease App IA Authoring

    CURSOR c_creditline(p_creditline_id OKC_K_HEADERS_B.ID%TYPE)
    IS
  SELECT chrb.id,
       chrb.contract_number creditline,
       chrb.currency_code
  FROM okc_k_headers_b chrb
WHERE chrb.id = p_creditline_id
;

    -- sjalasut, modified the cursor to include okl_txl_ap_inv_lns_all_b
    -- as references of khr_id is now moved to this table from okl_trx_ap_invoices_b
    -- changes made as part of OKLR12B disbursments project
    CURSOR c_funding_req(p_funding_id OKL_TRX_AP_INVOICES_B.ID%TYPE)
    IS
  SELECT h.id,
       h.funding_type_code,
       h.vendor_invoice_number fund_number,
       h.currency_code,
       look1.MEANING payment_method_name,
       look2.MEANING funding_type_name,
       h.date_invoiced fund_due_date,
       v.vendor_name,
       vs.vendor_site_code,
       khr.id contract_id,
       khr.contract_number,
       party.name customer_name
  FROM OKL_TRX_AP_INVS_ALL_B h,
       okl_txl_ap_inv_lns_all_b tpl,
       OKC_K_HEADERS_ALL_B khr,
       PO_VENDORS v,
       PO_VENDOR_SITES_ALL vs,
       FND_LOOKUPS look1,
       FND_LOOKUPS look2,
       okx_parties_v party,
       okc_k_party_roles_b cpl
 WHERE party.id1 = cpl.object1_id1
   AND party.id2 = cpl.object1_id2
   AND cpl.rle_code = 'LESSEE'
   AND cpl.chr_id = khr.id
   AND h.id = tpl.tap_id
   and tpl.khr_id = khr.id
   AND h.ipvs_id = vs.vendor_site_id
   AND vs.vendor_id = v.vendor_id
   AND h.payment_method_code = look1.LOOKUP_CODE
   AND look1.LOOKUP_TYPE = 'OKL_AP_PAYMENT_METHOD'
   AND h.funding_type_code = look2.LOOKUP_CODE
   AND look2.LOOKUP_TYPE = 'OKL_FUNDING_TYPE'
   AND h.id = p_funding_id;

-- start: cklee 31-May-2005 okl.h Lease App IA Authoring
    CURSOR l_okl_list_contents_csr(p_funding_id OKL_TRX_AP_INVOICES_B.ID%TYPE)
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
      FROM okl_funding_checklists_uv
      WHERE FUND_REQ_ID =  p_funding_id;

    CURSOR c_contract(p_contract_id OKC_K_HEADERS_B.ID%TYPE)
    IS
select 1
 from okc_k_headers_b
 where ORIG_SYSTEM_SOURCE_CODE = 'OKL_LEASE_APP'
 and id = p_contract_id;
-- end: cklee 31-May-2005 okl.h Lease App IA Authoring

    r_creditline c_creditline%ROWTYPE;
    r_funding_req c_funding_req%ROWTYPE;


  BEGIN

	-- Get the Funding Request Details to display Requesting Page
        OPEN  c_funding_req(p_funding_id);
        FETCH c_funding_req INTO r_funding_req;
        CLOSE c_funding_req;

        l_creditline_id := OKL_CREDIT_PUB.get_creditline_by_chrid(r_funding_req.contract_id);

        -- Get the Credit line Details to display Requesting Page
        OPEN  c_creditline(l_creditline_id);
        FETCH c_creditline INTO r_creditline;
        CLOSE c_creditline;


-- start: cklee 31-May-2005 okl.h Lease App IA Authoring
        OPEN  c_contract(r_funding_req.contract_id);
        FETCH c_contract INTO l_dummy;
        l_lease_app_found := c_contract%found;
        CLOSE c_contract;

	   -- Start
      l_message := l_message || '<TABLE width="100%" border="0" cellspacing="0" cellpadding="0">';

	  -- Empty Row
      l_message := l_message || '<tr><td colspan=6>' || G_AMP_SIGN || 'nbsp;</td></tr>';

      l_message := l_message || '<tr><td colspan=6>'
                             || '<table width="100%" border="0" cellspacing="0" cellpadding="0">';

      -- Funding Number, Funding type
      l_message := l_message || '<tr><td width="18%" align="right">'
	                || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_FUNDING_REQ',
     	                                                p_attribute_code => 'OKL_FUND_NUMBER')
                             || '</td><td width="1%">' || G_AMP_SIGN || 'nbsp;</td>'
                             || '<td width="36%"><b>'
                     							 || r_funding_req.fund_number
                      						 || '</b></td>'
                     							 || '<td width="13%" align="right">'
	                || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_FUNDING_REQ',
     	                                                p_attribute_code => 'OKL_FUNDING_TYPE')
                     							 || '</td><td width="1%">' || G_AMP_SIGN || 'nbsp;</td>'
                      						 || '<td width="33%"><b>'
                     							 ||  r_funding_req.funding_type_name
                     							 || '</b></td>'
                     							 || '</tr>';

      -- Vendor Name, Vendor Site Code
      l_message := l_message || '<tr><td width="18%" align="right">'
	                || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_FUNDING_REQ',
     	                                                p_attribute_code => 'OKL_VENDOR_NAME')
                             || '</td><td width="1%">' || G_AMP_SIGN || 'nbsp;</td>'
                             || '<td width="36%"><b>'
                     							 ||  r_funding_req.vendor_name
                      						 || '</b></td>'
                     							 || '<td width="13%" align="right">'
	                || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_FUNDING_REQ',
     	                                                p_attribute_code => 'OKL_VENDOR_SITE')
                     							 || '</td><td width="1%">' || G_AMP_SIGN || 'nbsp;</td>'
                      						 || '<td width="33%"><b>'
                     							 ||  r_funding_req.vendor_site_code
                     							 || '</b></td>'
                     							 || '</tr>';

	  -- Empty Row
      l_message := l_message || '<tr><td colspan=6>' || G_AMP_SIGN || 'nbsp;</td></tr>';

   -- End
 	  l_message := l_message || '
                  </TABLE>';
-- end: cklee 31-May-2005 okl.h Lease App IA Authoring

	   -- Start
      l_message := l_message || '<TABLE width="100%" border="0" cellspacing="0" cellpadding="0">';

	  -- Empty Row
      l_message := l_message || '<tr><td colspan=6>'|| G_AMP_SIGN ||'nbsp;</td></tr>';

-- start: cklee 31-May-2005 okl.h Lease App IA Authoring
/*
      -- Funding Number, Funding type

      l_message := l_message || '<tr><td>'
	                || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_FUNDING_REQ',
     	                                                p_attribute_code => 'OKL_FUND_NUMBER')
					|| '</td>
				        <td>'|| G_AMP_SIGN ||'nbsp;</td>
				        <td><b>' || r_funding_req.fund_number || '</b></td>
				        <td>'
	                || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_FUNDING_REQ',
     	                                                p_attribute_code => 'OKL_FUNDING_TYPE')
                    || '</td>
				        <td>'|| G_AMP_SIGN ||'nbsp;</td>
				        <td><b>' || r_funding_req.funding_type_name || '</b></td>
				        </tr>';

      -- Vendor Name, Vendor Site Code

      l_message := l_message || '<tr><td>'
	                || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_FUNDING_REQ',
     	                                                p_attribute_code => 'OKL_VENDOR_NAME')
					|| '</td>
				        <td>'|| G_AMP_SIGN ||'nbsp;</td>
				        <td><b>' || r_funding_req.vendor_name || '</b></td>
				        <td>'
	                || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_FUNDING_REQ',
     	                                                p_attribute_code => 'OKL_VENDOR_SITE')
                    || '</td>
				        <td>'|| G_AMP_SIGN ||'nbsp;</td>
				        <td><b>' || r_funding_req.vendor_site_code || '</b></td>
				        </tr>';

*/
-- end: cklee 31-May-2005 okl.h Lease App IA Authoring

	  -- Empty Row
      l_message := l_message || '<tr><td colspan=6>'|| G_AMP_SIGN ||'nbsp;</td></tr>';

	  -- Currency
	  l_message := l_message || '<tr><td>'
	                || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_FUNDING_REQ',
     	                                                p_attribute_code => 'OKL_CURRENCY')
                    || ' = <b>'
					|| r_funding_req.currency_code
					|| '</b></td>
             		    <td colspan=5>'|| G_AMP_SIGN ||'nbsp;</td>
						</tr>';

	  -- Empty Row
      l_message := l_message || '<tr><td colspan=6>'|| G_AMP_SIGN ||'nbsp;</td></tr>';
--
-- Funding
--
	  -- "Funding Details" Sub Head
      l_message := l_message || '<tr>
                    		    <td align="right">
                     	      <h3><b>'
	                || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_FUNDING_REQ',
     	                                                p_attribute_code => 'OKL_FUNDING_DETAILS')
                    || '</b></h3>
                		    </td>
                		    <td colspan="5" valign="middle">
                    	      <hr>
                		    </td>
                      </tr>';

	  -- Empty Row
      l_message := l_message || '<tr><td colspan=6>'|| G_AMP_SIGN ||'nbsp;</td></tr>';

	  -- Funding Total
	  l_message := l_message || '
		  <tr>
		    <td align="right">'
	                || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_FUNDING_REQ',
     	                                                p_attribute_code => 'OKL_AMOUNT')
			|| '</td>
		    <td>'|| G_AMP_SIGN ||'nbsp;</td>
		    <td><b>'
       		||  OKL_ACCOUNTING_UTIL.format_amount(
                     NVL(OKL_FUNDING_PVT.get_contract_line_funded_amt(r_funding_req.id,
                                                                  r_funding_req.funding_type_code),0),
                      r_funding_req.currency_code)
			|| '</b></td>
		    <td colspan=3>'|| G_AMP_SIGN ||'nbsp;</td>
		  </tr>';

	  -- Funding Remaining
	  l_message := l_message || '
		  <tr>
		    <td align="right">'
	                || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_FUNDING_SUMMY',
     	                                                p_attribute_code => 'OKL_TOTAL_FUNDED_REMAINING')
			|| '</td>
		    <td>'|| G_AMP_SIGN ||'nbsp;</td>
		    <td><b>'
       		||  OKL_ACCOUNTING_UTIL.format_amount(
                      NVL(OKL_FUNDING_PVT.get_chr_canbe_funded_rem(r_funding_req.contract_id),0),
                      r_funding_req.currency_code)
			|| '</b></td>
		    <td colspan=3>'|| G_AMP_SIGN ||'nbsp;</td>
		  </tr>';

      -- Due Date
	  l_message := l_message || '
		  <tr>
		    <td align="right">'
	                || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_FUNDING_REQ',
     	                                                p_attribute_code => 'OKL_DATE_DUE')
			|| '</td>
		    <td>'|| G_AMP_SIGN ||'nbsp;</td>
		    <td><b>'
       		|| TO_CHAR(r_funding_req.fund_due_date,fnd_profile.value('ICX_DATE_FORMAT_MASK'))
			|| '</b></td>
		    <td colspan=3>'|| G_AMP_SIGN ||'nbsp;</td>
		  </tr>';

	  -- Empty Row
      l_message := l_message || '<tr><td colspan=6>'|| G_AMP_SIGN ||'nbsp;</td></tr>';

--
-- Contract
--

	  -- "Contract" Sub Head
      l_message := l_message || '<tr>
                    		    <td align="right">
                     	      <h3><b>'
	                || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CONTRACT_SRCHT',
     	                                                p_attribute_code => 'OKL_CONTRACT')
                    || '</b></h3>
                		    </td>
                		    <td colspan="5" valign="middle">
                    	      <hr>
                		    </td>
                      </tr>';

	  -- Empty Row
      l_message := l_message || '<tr><td colspan=6>'|| G_AMP_SIGN ||'nbsp;</td></tr>';


	  -- Contract Number
	  l_message := l_message || '
		  <tr>
		    <td align="right">'
	                || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CONTRACT_SRCHT',
     	                                                p_attribute_code => 'OKL_CONTRACT_NUMBER')
			|| '</td>
		    <td>'|| G_AMP_SIGN ||'nbsp;</td>
		    <td><b>'
       		||  r_funding_req.contract_number
			|| '</b></td>
		    <td colspan=3>'|| G_AMP_SIGN ||'nbsp;</td>
		  </tr>';

	  -- Customer Name
	  l_message := l_message || '
		  <tr>
		    <td align="right">'
	                || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CREDIT',
     	                                                p_attribute_code => 'OKL_CUSTOMER_NAME')
			|| '</td>
		    <td>'|| G_AMP_SIGN ||'nbsp;</td>
		    <td><b>'
       		|| r_funding_req.customer_name
			|| '</b></td>
		    <td colspan=3>'|| G_AMP_SIGN ||'nbsp;</td>
		  </tr>';


	  -- Empty Row
      l_message := l_message || '<tr><td colspan=6>'|| G_AMP_SIGN ||'nbsp;</td></tr>';

--
-- Credit line
--
-- start: cklee 31-May-2005 okl.h Lease App IA Authoring
    IF NOT l_lease_app_found AND l_creditline_id IS NOT NULL THEN
-- end: cklee 31-May-2005 okl.h Lease App IA Authoring
	  -- "Credit" Sub Head
      l_message := l_message || '<tr>
                    		    <td align="right">
                     	      <h3><b>'
	                || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CREDIT',
     	                                                p_attribute_code => 'OKL_CREDIT')
                    || '</b></h3>
                		    </td>
                		    <td colspan="5" valign="middle">
                    	      <hr>
                		    </td>
                      </tr>';

	  -- Empty Row
      l_message := l_message || '<tr><td colspan=6>'|| G_AMP_SIGN ||'nbsp;</td></tr>';


	  -- Credit line
	  l_message := l_message || '
		  <tr>
		    <td align="right">'
	                || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CREDIT',
     	                                                p_attribute_code => 'OKL_CREDIT_NUMBER')
			|| '</td>
		    <td>'|| G_AMP_SIGN ||'nbsp;</td>
		    <td><b>'
       		||  r_creditline.creditline
			|| '</b></td>
		    <td colspan=3>'|| G_AMP_SIGN ||'nbsp;</td>
		  </tr>';

	  -- Credit line remaining
	  l_message := l_message || '
		  <tr>
		    <td align="right">'
	                || Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LA_CREDIT',
     	                                                p_attribute_code => 'OKL_REMAINING')
			|| '</td>
		    <td>'|| G_AMP_SIGN ||'nbsp;</td>
		    <td><b>'
       		||  OKL_ACCOUNTING_UTIL.format_amount(
                      nvl(OKL_SEEDED_FUNCTIONS_PVT.creditline_total_remaining(r_creditline.id),0),
                      r_creditline.currency_code)
			|| '</b></td>
		    <td colspan=3>'|| G_AMP_SIGN ||'nbsp;</td>
		  </tr>';
-- start: cklee 31-May-2005 okl.h Lease App IA Authoring
    END IF; -- IF l_lease_app_found THEN
-- end: cklee 31-May-2005 okl.h Lease App IA Authoring

--
-- start: cklee 31-May-2005 okl.h Lease App IA Authoring
--
	  -- Empty Row
      l_message := l_message || '<tr><td colspan=6>' || G_AMP_SIGN || 'nbsp;</td></tr>';

      FOR each_row IN l_okl_list_contents_csr(p_funding_id) LOOP
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
      l_message := l_message || '<tr><td colspan=6>' || G_AMP_SIGN || 'nbsp;</td></tr>';

--
-- end: cklee 31-May-2005 okl.h Lease App IA Authoring
--
	  -- End
 	  l_message := l_message || '
                  </TABLE>';
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


    FOR l_okl_list_contents_rec IN l_okl_list_contents_csr(p_funding_id)
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
                                || l_okl_list_contents_rec.func_val_rsts_meaning
                                || '</td></tr>';
      ELSE
         l_message := l_message || '<td class="x1l x4x">'
                                || l_okl_list_contents_rec.check_off_results
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

-------------------------------------------------------------------------------------------------
-------------------------------------- Step 2: Get Approver -------------------------------------
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-- Start of Comments
-- API Name  : get_approver
-- TYPE      : WF
-- Purpose   : Process API to get approver.
-- Modification History
--              23-JUN-2003  cklee Created
-- Notes    : Step 2
-- End of Comments
-------------------------------------------------------------------------------------------------

  PROCEDURE get_approver(itemtype   IN VARCHAR2,
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

    l_api_name VARCHAR2(200) := 'Get_Approver';

    l_user_id   VARCHAR2(200);
    l_funding_number       OKL_TRX_AP_INVOICES_B.vendor_invoice_number%TYPE;

    l_return_status VARCHAR2(1);

  BEGIN
     l_return_status := OKL_API.G_RET_STS_SUCCESS;

	 -- "RUN"
     IF (funcmode = 'RUN') THEN
		 --l_user_id := fnd_profile.value('OKL_LEASE_FUNDING_APPROVER');
         l_user_id :=   wf_engine.GetItemAttrText (itemtype  => itemtype,
                                                    itemkey   => itemkey,
                                                    aname     => G_WF_ITM_REQUESTER_ID);

         l_funding_number :=   wf_engine.GetItemAttrText (itemtype  => itemtype,
                                                    itemkey   => itemkey,
                                                    aname     => G_WF_ITM_FUNDING_NUMBER);

         resultout := 'COMPLETE:NOT_FOUND'; -- default
		 IF l_user_id IS NOT NULL THEN
			 FOR l_fnd_users_rec IN l_fnd_users_csr(l_user_id)
			 LOOP
			     wf_engine.SetItemAttrText (itemtype  => itemtype,
			                                itemkey   => itemkey,
			                                aname     => G_WF_ITM_APPROVER,
	                                            avalue    => l_fnd_users_rec.user_name);


                       wf_engine.SetItemAttrText (itemtype  => itemtype,
				                           itemkey  => itemkey,
                         				   aname   	=> G_WF_ITM_MESSAGE_SUBJECT,
                                                   avalue  =>
                                       get_message('OKL_LLA_FUND_REQ_APPROVAL_SUB',l_funding_number));

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

  END get_approver;

 --------------------------------------------------------------------------------------------------
 --------------------------------- Set Approval Status --------------------------------------------
 --------------------------------------------------------------------------------------------------
  PROCEDURE set_parent_attributes(itemtype  IN VARCHAR2,
                                itemkey   IN VARCHAR2,
                                actid     IN NUMBER,
                                funcmode  IN VARCHAR2,
                                resultout OUT  NOCOPY VARCHAR2) IS

    l_approved_yn     VARCHAR2(30);
    l_parent_key                    VARCHAR2(240);
    l_parent_type                  VARCHAR2(240);
    l_result   VARCHAR2(30);
	l_api_name          VARCHAR2(30) := 'Set_Parent_Attributes';
	l_funding_number    okl_trx_ap_invoices_b.vendor_invoice_number%TYPE;

  BEGIN
    SAVEPOINT set_atts;
    IF (funcmode = 'RUN') THEN
      -- Get current approval status
      l_result := wf_engine.GetItemAttrText (itemtype  => itemtype,
                                             itemkey   => itemkey,
                                             aname     => G_WF_ITM_RESULT);

      l_parent_key := wf_engine.GetItemAttrText
                                            (itemtype  => itemtype,
                  	                      itemkey   => itemkey,
			      	                aname     => G_WF_ITM_PARENT_ITEM_KEY);

      l_parent_type := wf_engine.GetItemAttrText
                                            (itemtype   => itemtype,
				                     itemkey    => itemkey,
				                     aname      => G_WF_ITM_PARENT_ITEM_TYPE);

      l_funding_number := wf_engine.GetItemAttrText
                                            (itemtype  => itemtype,
                                             itemkey   => itemkey,
                                             aname     => G_WF_ITM_FUNDING_NUMBER);
      IF l_result = G_WF_ITM_RESULT_APPROVED THEN
        l_approved_yn := G_WF_ITM_APPROVED_YN_YES;
        wf_engine.SetItemAttrText (itemtype            => itemtype,
                                   itemkey             => itemkey,
                        	      aname   		  => G_WF_ITM_MESSAGE_SUBJECT,
                                    avalue              =>
-- Fixed incorrect message token 12-05-2003 cklee
                              get_message('OKL_LLA_FUND_REQ_APPROVAL_SUB',l_funding_number));
      ELSE
        l_approved_yn := G_WF_ITM_APPROVED_YN_NO;
         wf_engine.SetItemAttrText (itemtype            => itemtype,
                                    itemkey             => itemkey,
                                    aname               => G_WF_ITM_MESSAGE_SUBJECT,
                                    avalue              =>
                              get_message('OKL_LLA_FUND_REQ_REJECTED_SUB',l_funding_number));
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
  END set_parent_attributes;
-------------------------------------------------------------------------------------------------
----------------------------------Step 4: Main Approval Process ---------------------------------
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-- Start of Comments
-- API Name  : update_approval_status
-- TYPE      : WF
-- Purpose   : Process API to set funding request approval.
-- Modification History
--              23-JUN-2003  cklee Created
-- Notes    : Step 4
-- End of Comments
-------------------------------------------------------------------------------------------------


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
        AND representation_type = 'PRIMARY';
        --

    --For bug 8788410 - NIKSHAH: START
    CURSOR c_get_org_id(p_funding_id IN okl_trx_ap_invoices_b.id%TYPE)
    IS
    SELECT org_id
    FROM   OKL_TRX_AP_INVS_ALL_B
    where  ID = p_funding_id;
    --For bug 8788410 - NIKSHAH: END;

    l_return_status	VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    l_api_version       NUMBER	:= 1.0;
    l_msg_count		NUMBER;
    l_init_msg_list     VARCHAR2(10) := OKL_API.G_FALSE;
    l_msg_data		VARCHAR2(2000);
	l_api_name VARCHAR2(30) := 'update_approval_status';

    l_funding_id         okl_trx_ap_invoices_b.id%TYPE;
    l_approved_yn        VARCHAR2(30);
    l_trx_number VARCHAR2(100);

    l_trxH_in_rec        Okl_Trx_Contracts_Pvt.tcnv_rec_type;
    l_trxH_out_rec       Okl_Trx_Contracts_Pvt.tcnv_rec_type;

    -- variables for bug 4900097 - Start
    l_org_id             OKC_K_HEADERS_B.AUTHORING_ORG_ID%TYPE;
    l_khr_id             OKC_K_HEADERS_B.ID%TYPE;
    -- variables for bug 4900097 - End

    --For bug 8788410 - NIKSHAH: START
    l_orig_access_mode VARCHAR2(3) := MO_GLOBAL.GET_ACCESS_MODE;
    l_orig_org_id NUMBER :=  MO_GLOBAL.GET_CURRENT_ORG_ID;
    --For bug 8788410 - NIKSHAH: END

  BEGIN
    -- We getting the contract_Id from WF
    l_funding_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => G_WF_ITM_FUNDING_ID);

    --For bug 8788410 - NIKSHAH: START
    IF l_orig_org_id IS NULL THEN
      OPEN c_get_org_id(l_funding_id);
      FETCH c_get_org_id INTO l_org_id;
      CLOSE c_get_org_id;
    END IF;
    IF l_org_id IS NOT NULL THEN
      MO_GLOBAL.SET_POLICY_CONTEXT('S', l_org_id);
    END IF;
    --For bug 8788410 - NIKSHAH: END
     --Run Mode
    IF funcmode = 'RUN' THEN
      l_approved_yn :=  wf_engine.GetItemAttrText (itemtype  => itemtype,
                                                    itemkey   => itemkey,
                                                    aname     => G_WF_ITM_APPROVED_YN);

      IF l_approved_yn = G_WF_ITM_APPROVED_YN_YES THEN

         l_update_funding_status
                          (p_api_version   => l_api_version,
                           p_init_msg_list       => l_init_msg_list,
                           x_return_status       => l_return_status,
                           x_msg_count           => l_msg_count,
                           x_msg_data            => l_msg_data,
                           p_funding_status      => 'APPROVED',
                           p_funding_id          => l_funding_id);

         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

      ELSE

         l_update_funding_status
                          (p_api_version   => l_api_version,
                           p_init_msg_list       => l_init_msg_list,
                           x_return_status       => l_return_status,
                           x_msg_count           => l_msg_count,
                           x_msg_data            => l_msg_data,
                           p_funding_status      => 'REJECTED',
                           p_funding_id          => l_funding_id);

         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
      END IF;

      -- trx's trx_number IS ame's trx_id
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
      --For bug 8788410 - NIKSHAH
      MO_GLOBAL.SET_POLICY_CONTEXT(l_orig_access_mode,l_orig_org_id);
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
      --For bug 8788410 - NIKSHAH
      MO_GLOBAL.SET_POLICY_CONTEXT(l_orig_access_mode,l_orig_org_id);
      wf_core.context(G_PKG_NAME,
                      l_api_name,
                       itemtype,
                       itemkey,
                       TO_CHAR(actid),
                       funcmode);
	  RAISE;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      --For bug 8788410 - NIKSHAH
      MO_GLOBAL.SET_POLICY_CONTEXT(l_orig_access_mode,l_orig_org_id);
      wf_core.context(G_PKG_NAME,
                      l_api_name,
                       itemtype,
                       itemkey,
                       TO_CHAR(actid),
                       funcmode);
	  RAISE;
    WHEN OTHERS THEN
      --For bug 8788410 - NIKSHAH
      MO_GLOBAL.SET_POLICY_CONTEXT(l_orig_access_mode,l_orig_org_id);
      wf_core.context(G_PKG_NAME,
                      l_api_name,
                       itemtype,
                       itemkey,
                       TO_CHAR(actid),
                       funcmode);
	  RAISE;
  END update_approval_status;

-------------------------------------------------------------------------------------------------
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
-------------------------------------------------------------------------------------------------

  PROCEDURE pop_approval_doc (document_id   IN VARCHAR2,
                              display_type  IN VARCHAR2,
                              document      IN OUT nocopy VARCHAR2,
                              document_type IN OUT nocopy VARCHAR2) IS

    l_message        VARCHAR2(4000);
	l_funding_id NUMBER;
  BEGIN

        l_funding_id := wf_engine.GetItemAttrText (
                                  itemtype            => G_ITEM_TYPE_WF,
        		                itemkey             => document_id,
			                aname               => G_WF_ITM_FUNDING_ID);

        document := compile_message(l_funding_id);
        document_type := display_type;

        RETURN;

  EXCEPTION
     WHEN OTHERS THEN NULL;

  END pop_approval_doc;
-------------------------------------------------------------------------------------------------

  PROCEDURE check_approval_process( itemtype	IN VARCHAR2,
                                    itemkey  	IN VARCHAR2,
		                         actid		IN NUMBER,
			                   funcmode	IN VARCHAR2,
				             resultout OUT NOCOPY VARCHAR2 )
    IS
      l_approval_option VARCHAR2(5);
      l_funding_id VARCHAR2(240);
	  l_funding_number okl_trx_ap_invoices_b.vendor_invoice_number%TYPE;

      l_api_name          VARCHAR2(30) := 'check_approval_process';
      l_message VARCHAR2(4000);

    BEGIN

      IF (funcmode = 'RUN') THEN

        l_approval_option := fnd_profile.value('OKL_LEASE_FUNDING_APPROVAL_PROCESS');
	  IF l_approval_option = G_LEASE_FUNDING_APPROVAL_AME THEN

          l_funding_id := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                       itemkey   => itemkey,
                                                       aname     => G_WF_ITM_FUNDING_ID);

          l_funding_number := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                       itemkey   => itemkey,
                                                       aname     => G_WF_ITM_FUNDING_NUMBER);
          wf_engine.SetItemAttrText (itemtype            => itemtype,
  			                    itemkey             => itemkey,
			                    aname               => G_WF_ITM_MESSAGE_DESCRIPTION,
         	                          avalue              => compile_message(l_funding_id));

          wf_engine.SetItemAttrText (itemtype            => itemtype,
 	       	                    itemkey             => itemkey,
		      	              aname               => G_WF_ITM_APP_REQUEST_SUB,
             	                    avalue              =>
                               get_message('OKL_LLA_FUND_REQ_APPROVAL_SUB',l_funding_number));

          wf_engine.SetItemAttrText (itemtype            => itemtype,
		                          itemkey             => itemkey,
				              aname               => G_WF_ITM_APP_REMINDER_SUB,
                	                    avalue              =>
                               get_message('OKL_LLA_FUND_REQ_APPR_SUB_REMD',l_funding_number));

          wf_engine.SetItemAttrText (itemtype            => itemtype,
                                     itemkey             => itemkey,
                                     aname               => G_WF_ITM_APP_APPROVED_SUB,
	         	                    avalue              =>
-- Fixed incorrect message token 12-05-2003 cklee
                               get_message('OKL_LLA_FUND_REQ_APPROVAL_SUB',l_funding_number));

          wf_engine.SetItemAttrText (itemtype            => itemtype,
				                itemkey             => itemkey,
				                aname               => G_WF_ITM_APP_REJECTED_SUB,
                 	                      avalue              =>
                               get_message('OKL_LLA_FUND_REQ_REJECTED_SUB',l_funding_number));

          wf_engine.SetItemAttrText (itemtype            => itemtype,
				                itemkey             => itemkey,
				                 aname               => G_WF_ITM_APP_REMINDER_HEAD,
	         	                       avalue              =>
                                get_message('OKL_LLA_FUND_REQ_APPROVAL_REMD',l_funding_number));

          wf_engine.SetItemAttrText (itemtype            => itemtype,
          			                itemkey             => itemkey,
		       	                aname               => G_WF_ITM_APP_APPROVED_HEAD,
                   	                    avalue              =>
-- Fixed incorrect message token 12-05-2003 cklee
                      get_message('OKL_LLA_FUND_REQ_APPROVAL_SUB',l_funding_number));

          wf_engine.SetItemAttrText (itemtype            => itemtype,
        			                itemkey             => itemkey,
				                aname               => G_WF_ITM_APP_REJECTED_HEAD,
                                        avalue              =>
                      get_message('OKL_LLA_FUND_REQ_REJECTED_SUB',l_funding_number));


		   resultout := 'COMPLETE:AME';
        ELSIF l_approval_option = G_LEASE_FUNDING_APPROVAL_WF THEN
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
-------------------------------------------------------------------------------------------------

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

    l_funding_id VARCHAR2(240);
	l_funding_number okl_trx_ap_invoices_b.vendor_invoice_number%TYPE;
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
                                process          => l_process);

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

	        l_funding_id :=   wf_engine.GetItemAttrText (itemtype  => itemtype,
	                                                    itemkey   => itemkey,
	                                                    aname     => G_WF_ITM_FUNDING_ID);

	        l_funding_number :=   wf_engine.GetItemAttrText (itemtype  => itemtype,
	                                                    itemkey   => itemkey,
	                                                    aname     => G_WF_ITM_FUNDING_NUMBER);

	        l_requester :=   wf_engine.GetItemAttrText (itemtype  => itemtype,
	                                                    itemkey   => itemkey,
	                                                    aname     => G_WF_ITM_REQUESTER);

	        l_requester_id :=   wf_engine.GetItemAttrText (itemtype  => itemtype,
	                                                    itemkey   => itemkey,
	                                                    aname     => G_WF_ITM_REQUESTER_ID);

	        wf_engine.SetItemAttrText (
	                                itemtype            => l_item_type,
	                                itemkey             => l_key,
				              aname               => G_WF_ITM_FUNDING_ID,
	         	                    avalue              => l_funding_id);

	        wf_engine.SetItemAttrText (
	                                itemtype            => l_item_type,
                                     itemkey             => l_key,
				              aname               => G_WF_ITM_FUNDING_NUMBER,
	         	                    avalue              => l_funding_number);

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
                                        aname  			=> G_WF_ITM_MESSAGE_DOC,
                                        avalue              => 'plsql:OKL_FUNDING_WF.pop_approval_doc/'||l_key);

        -- Now, Start the Detail Process
        wf_engine.StartProcess(itemtype	        => l_item_type,
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


END okl_funding_wf;

/
