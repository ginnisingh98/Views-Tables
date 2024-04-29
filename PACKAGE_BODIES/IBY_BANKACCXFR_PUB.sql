--------------------------------------------------------
--  DDL for Package Body IBY_BANKACCXFR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_BANKACCXFR_PUB" AS
/*$Header: ibybareqb.pls 120.3 2005/09/15 01:33:03 rameshsh noship $ */

 -- *** Declaring global datatypes and variables ***
 G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBY_BANKACCXFR_PUB';

 g_validation_level CONSTANT NUMBER  := FND_API.G_VALID_LEVEL_FULL;

----------------------------------------------------
-- *** Declaring global datatypes and variables ***
----------------------------------------------------

/* ============================================================================
   --1. OraPmtBatchReq
   --   -----------------------
   --   Start of comments
   --      API name  : OraPmtBankAccXfrBatchReq
   --      Type      : Public
   --      Pre-reqs  : None
   --      Function  : Handles Batch Payment requests from Accounts Receivables
   --      Parameters:
   --      IN        : p_api_version        IN  NUMBER
   --                  p_init_msg_list      IN  VARCHAR2
   --                  p_commit             IN  VARCHAR2
   --                  p_validation_level   IN  NUMBER
   --                  p_ecapp_id           IN  NUMBER
   --		       x_return_status      OUT VARCHAR2,
   --                  x_msg_count          OUT NUMBER,
   -- 	               x_msg_data           OUT VARCHAR2,
   --                  p_pmt_batch_req_rec  IN  BankAccXfrReq_Rec_Type,
   --                  p_pmt_batch_trxn_tbl IN  BankAccXfrTrxn_Tbl_Type,
   --                  x_batch_resp_rec     IN  BankAccXfrResp_Rec_Type,
   --                  x_batch_respdet_rec  IN  BankAccXfrRespDet_Tbl_Type
   --   Version :
   --   Current version      1.0
   --   Previous version     1.0
   --   Initial version      1.0
   --   End of comments
 ============================================================================ */

PROCEDURE OraPmtBatchReq(
         p_api_version        IN    NUMBER,
         p_init_msg_list      IN    VARCHAR2  DEFAULT FND_API.G_FALSE,
         p_commit             IN    VARCHAR2  DEFAULT FND_API.G_FALSE,
         p_validation_level   IN    NUMBER  DEFAULT FND_API.G_VALID_LEVEL_FULL,
	 p_payee_id           IN    VARCHAR2,
         p_ecapp_id           IN    NUMBER,
         x_return_status      OUT   NOCOPY VARCHAR2,
         x_msg_count          OUT   NOCOPY NUMBER,
         x_msg_data           OUT   NOCOPY VARCHAR2,
         p_batch_req_rec      IN    BankAccXfrReq_Rec_Type,
         p_accxfr_trxn_tbl    IN    BankAccXfrTrxn_Tbl_Type,
         x_batch_resp_rec     OUT   NOCOPY BankAccXfrResp_Rec_Type,
	 x_batch_respdet_tbl  OUT   NOCOPY BankAccXfrRespDet_Tbl_Type
	 ) IS

        l_get_baseurl   VARCHAR2(2000);
        --The following 3 variables are meant for output of
        --get_baseurl procedure.
        l_status_url    VARCHAR2(2000);
        l_msg_count_url NUMBER := 0;
        l_msg_data_url  VARCHAR2(2000);
        l_pmt_mode      VARCHAR2(80) := 'OFFLINE';

        l_api_name      CONSTANT  VARCHAR2(30) := 'OraPmtBatchReq';
        l_oapf_action   CONSTANT  VARCHAR2(30) := 'oraPmtBatchReq';
        l_api_version   CONSTANT  NUMBER := 1.0;

        l_url           VARCHAR2(30000) ;
        l_html          VARCHAR2(32767) ;

        l_names         IBY_NETUTILS_PVT.v240_tbl_type;
        l_values        IBY_NETUTILS_PVT.v240_tbl_type;

        --The following 3 variables are meant for output of
        --unpack_results_url procedure.
        l_status        NUMBER := 0;
        l_errcode       NUMBER := 0;
        l_curr_index   NUMBER :=1;
        l_index        NUMBER := 1;
        l_errmessage    VARCHAR2(2000) := 'Success';
        l_ret_val      PLS_INTEGER;
        l_conn         UTL_TCP.CONNECTION;  -- TCP/IP connection to the Web server

        l_content_len  NUMBER := 0;
   	    l_pos          NUMBER := 0;
     	l_post_body    VARCHAR2(30000);
        l_tempclob     CLOB;

        -- for NLS bug fix #1692300 - 4/3/2001 jleybovi
	--
	l_db_nls	p_batch_req_rec.NLS_LANG%TYPE := NULL;
	l_ecapp_nls	p_batch_req_rec.NLS_LANG%TYPE := NULL;

	v_trxnTimestamp	DATE	:= NULL;

        --Defining a local variable to hold the payment instrument type.
        l_pmtinstr_type VARCHAR2(200);
        l_sec_cred NUMBER;

BEGIN

      ---------------------------------------------------
      -- Standard call to check for call compatibility.
      ---------------------------------------------------
      IF NOT FND_API.Compatible_API_Call ( l_api_version,

                                          p_api_version,
                                          l_api_name,
                                          G_PKG_NAME )
      THEN
        FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --------------------------------------------------------------
      -- Initialize message list if p_init_msg_list is set to TRUE.
      --------------------------------------------------------------

      IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
      END IF;


      -----------------------------------------------------------------------------
      -- Verifying if validation level is FULL, which is expected for PUBLIC APIs.
      -----------------------------------------------------------------------------
      IF (p_validation_level <> g_validation_level) THEN
        FND_MESSAGE.SET_NAME('IBY', 'IBY_204401_VAL_LEVEL_ERROR');
        FND_MSG_PUB.Add;
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

     -----------------------
     -- get iPayment URL
     -----------------------
     IBY_NETUTILS_PVT.get_baseurl(l_get_baseurl);
     l_url := l_get_baseurl;
     l_url := rtrim(l_url,'?');

     l_db_nls := IBY_NETUTILS_PVT.get_local_nls();
     l_ecapp_nls := NULL; -- not passed in this api??

     -------------------------
     -- create temporary clob
     -------------------------
     DBMS_LOB.CreateTemporary(l_tempclob, TRUE);

     -----------------------------
     -- reading header level data
     -----------------------------
     IBY_NETUTILS_PVT.check_mandatory('OapfAction', l_oapf_action, l_post_body, l_db_nls, l_ecapp_nls);
     IBY_NETUTILS_PVT.check_mandatory('OapfECAppId', to_char(p_ecapp_id), l_post_body, l_db_nls, l_ecapp_nls);
     -- Payee ID
     IBY_NETUTILS_PVT.check_mandatory('OapfStoreId', p_payee_ID, l_post_body, l_db_nls, l_ecapp_nls);

     -- the mode has to be mandatory as per the specifications

     IBY_NETUTILS_PVT.check_mandatory('OapfMode', l_pmt_mode, l_post_body, l_db_nls, l_ecapp_nls);
     IBY_NETUTILS_PVT.check_mandatory('OapfOrgId', p_batch_req_rec.Org_ID, l_post_body, l_db_nls, l_ecapp_nls);
     IBY_NETUTILS_PVT.check_mandatory('OapfBatchId', p_batch_req_rec.ECBatch_ID, l_post_body, l_db_nls, l_ecapp_nls);

     IBY_NETUTILS_PVT.check_mandatory('OapfPmtInstrType', p_batch_req_rec.PmtInstrType, l_post_body, l_db_nls, l_ecapp_nls);
     IBY_NETUTILS_PVT.check_mandatory('OapfBatchSize', p_accxfr_trxn_tbl.count, l_post_body, l_db_nls, l_ecapp_nls);


     --reading trxn detail data
     IBY_NETUTILS_PVT.check_mandatory('OapfPmtRegId', p_batch_req_rec.Payee_Instr_ID, l_post_body, l_db_nls, l_ecapp_nls);


     -- set security token
     --
     iby_security_pkg.store_credential(l_post_body,l_sec_cred);
     IBY_NETUTILS_PVT.check_mandatory('OapfSecurityToken', TO_CHAR(l_sec_cred),
          l_post_body, l_db_nls, l_ecapp_nls);


     -- write to CLOB
     DBMS_LOB.WriteAppend(l_tempclob, length(l_post_body), l_post_body);

     --dbms_output.put_line('String :'||l_post_body);

     -- Writing Transaction Level Data
     WHILE (l_curr_index <= p_accxfr_trxn_tbl.last) LOOP

         l_post_body := '';

         IBY_NETUTILS_PVT.check_mandatory('OapfPayerId-'|| l_index,p_accxfr_trxn_tbl(l_curr_index).Payer_Name, l_post_body, l_db_nls, l_ecapp_nls);
         IBY_NETUTILS_PVT.check_mandatory('OapfPayerInstrId-'|| l_index,p_accxfr_trxn_tbl(l_curr_index).Payer_Instr_ID, l_post_body, l_db_nls, l_ecapp_nls);
         IBY_NETUTILS_PVT.check_mandatory('OapfPmtInstrSubType-'|| l_index,p_accxfr_trxn_tbl(l_curr_index).PmtInstrSubType, l_post_body, l_db_nls, l_ecapp_nls);
         IBY_NETUTILS_PVT.check_mandatory('OapfOrderId-'|| l_index,p_accxfr_trxn_tbl(l_curr_index).Tangible_ID, l_post_body, l_db_nls, l_ecapp_nls);
         IBY_NETUTILS_PVT.check_mandatory('OapfPrice-'|| l_index,p_accxfr_trxn_tbl(l_curr_index).Tangible_Amount, l_post_body, l_db_nls, l_ecapp_nls);
         IBY_NETUTILS_PVT.check_optional('OapfMemo-'|| l_index,p_accxfr_trxn_tbl(l_curr_index).Memo, l_post_body, l_db_nls, l_ecapp_nls);
         IBY_NETUTILS_PVT.check_optional('OapfRefNumber-'|| l_index,p_accxfr_trxn_tbl(l_curr_index).RefInfo, l_post_body, l_db_nls, l_ecapp_nls);
         IBY_NETUTILS_PVT.check_mandatory('OapfSchedDate-'|| l_index,to_char(p_accxfr_trxn_tbl(l_curr_index).Settlement_Date,'YYYY-MM-DD'),l_post_body, l_db_nls, l_ecapp_nls);
         IBY_NETUTILS_PVT.check_mandatory('OapfIssueDate-'|| l_index,to_char(p_accxfr_trxn_tbl(l_curr_index).IssueDate,'YYYY-MM-DD'), l_post_body, l_db_nls, l_ecapp_nls);
	     IBY_NETUTILS_PVT.check_mandatory('OapfTrxnCurr-'|| l_index,p_accxfr_trxn_tbl(l_curr_index).Currency_Code, l_post_body, l_db_nls, l_ecapp_nls);
	     IBY_NETUTILS_PVT.check_optional('OapfNLSLang-'|| l_index,p_accxfr_trxn_tbl(l_curr_index).NLS_LANG, l_post_body, l_db_nls, l_ecapp_nls);

         --
         -- Customer reference / debtors reference
         --
         IBY_NETUTILS_PVT.check_optional('OapfCustomerRef-'|| l_index,p_accxfr_trxn_tbl(l_curr_index).customerRef, l_post_body, l_db_nls, l_ecapp_nls);

         -- Adder for new fields ordermedium and EFTAuthMethod
         IBY_NETUTILS_PVT.check_optional('OapfOrderMedium-'||l_index,p_accxfr_trxn_tbl(l_curr_index).OrderMedium, l_post_body, l_db_nls, l_ecapp_nls);
         IBY_NETUTILS_PVT.check_optional('OapfEftAuthMethod-'||l_index,p_accxfr_trxn_tbl(l_curr_index).EFTAuthMethod, l_post_body, l_db_nls, l_ecapp_nls);

         l_index := l_index + 1;
         l_curr_index := p_accxfr_trxn_tbl.next(l_curr_index);
         --dbms_output.put_line('IBY_BANKACCXFR_PUB : '||l_pos);
         --dbms_output.put_line('String :'||l_post_body);
         -- write to CLOB
         DBMS_LOB.WriteAppend(l_tempclob, length(l_post_body), l_post_body);



     END LOOP;


     ---------------------------------------------------
     -- sending POST request and unpacking the results
     ---------------------------------------------------

     --dbms_output.put_line('Length : '||DBMS_LOB.GETLENGTH(l_tempclob));
     IBY_NETUTILS_PVT.POST_REQUEST(l_url,l_tempclob,l_names,l_values, l_status, l_errcode, l_errmessage);

     -- Release temporary blobs
     DBMS_LOB.FreeTemporary(l_tempclob);


     FOR i IN l_names.FIRST..l_names.last LOOP
          --dbms_output.put_line(l_names(i)||' : '||l_values(i));
	    -- Read Batch response from ECServlet
	    IF l_names(i) = 'OapfBatchStatus' THEN
	       x_batch_resp_rec.BatchStatus := TO_NUMBER(l_values(i));
	    ELSIF l_names(i) = 'OapfBatchId' THEN
	       x_batch_resp_rec.Batch_Id := l_values(i);
	    ELSIF l_names(i) = 'OapfCode' THEN
	       x_batch_resp_rec.ErrorCode := l_values(i);
	    ELSIF l_names(i) = 'OapfMsg' THEN
	       x_batch_resp_rec.ErrorMsg := l_values(i);

	    -- Read Transaction Response
            ELSIF substr(l_names(i),0,instr(l_names(i),'-')-1) = 'OapfTangibleId' THEN
	       l_index := TO_NUMBER(substr(l_names(i),instr(l_names(i),'-')+1,length(l_names(i))));
	       x_batch_respdet_tbl(l_index).TangibleID := l_values(i);
	    ELSIF substr(l_names(i),0,instr(l_names(i),'-')-1) = 'OapfTrxnId' THEN
	       l_index := TO_NUMBER(substr(l_names(i),instr(l_names(i),'-')+1,length(l_names(i))));
	       x_batch_respdet_tbl(l_index).TrxnId := l_values(i);
	    ELSIF substr(l_names(i),0,instr(l_names(i),'-')-1) = 'OapfTrxnRef' THEN
	       l_index := TO_NUMBER(substr(l_names(i),instr(l_names(i),'-')+1,length(l_names(i))));
	       x_batch_respdet_tbl(l_index).TrxnRef := l_values(i);
	    ELSIF substr(l_names(i),0,instr(l_names(i),'-')-1) = 'OapfTrxnStatus' THEN
	       l_index := TO_NUMBER(substr(l_names(i),instr(l_names(i),'-')+1,length(l_names(i))));
	       x_batch_respdet_tbl(l_index).TrxnStatus := l_values(i);
            ELSIF substr(l_names(i),0,instr(l_names(i),'-')-1) = 'OapfTrxnErrCode' THEN
	       l_index := TO_NUMBER(substr(l_names(i),instr(l_names(i),'-')+1,length(l_names(i))));
	       x_batch_respdet_tbl(l_index).ErrorCode := l_values(i);
            ELSIF substr(l_names(i),0,instr(l_names(i),'-')-1) = 'OapfTrxnErrMsg' THEN
	       l_index := TO_NUMBER(substr(l_names(i),instr(l_names(i),'-')+1,length(l_names(i))));
	       x_batch_respdet_tbl(l_index).ErrorMsg := l_values(i);
	    END IF;


     END LOOP;

     -----------------------------------------------------------------------
     --Raising Exception to handle errors in unpacking resulting html file.
     -----------------------------------------------------------------------
     IF (l_status = -1) THEN
	iby_debug_pub.add('Unpack status error');
        FND_MESSAGE.SET_NAME('IBY', 'IBY_204403_HTML_UNPACK_ERROR');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     --------------------------------------------------------
     --Raising Exception to handle Servlet related errors.
     --------------------------------------------------------
     IF (l_names.COUNT = 0) THEN
	iby_debug_pub.add('Names count=0');
        FND_MESSAGE.SET_NAME('IBY', 'IBY_204402_JSERVLET_ERROR');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -------------------------------------------------------------------------
     -- Set return status to success and return
     -------------------------------------------------------------------------
        x_return_status := FND_API.G_RET_STS_SUCCESS ;

     iby_debug_pub.add('Exit OraPmtBankAccXfrBatchReq');

   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	     iby_debug_pub.add('In G_EXC_ERROR Exception');
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

   	     iby_debug_pub.add('In G_EXC_UNEXPECTED_ERROR Exception');
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN OTHERS THEN

	     --dbms_output.put_line('In OTHERS Exception');
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
         END IF;

         FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data
                                   );

         iby_debug_pub.add('x_return_status=' || x_return_status);
         iby_debug_pub.add('Exit Exception');

END OraPmtBatchReq;

END IBY_BANKACCXFR_PUB;


/
