--------------------------------------------------------
--  DDL for Package Body DPP_EXECUTIONPROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DPP_EXECUTIONPROCESS_PVT" AS
/* $Header: dppexppb.pls 120.0.12010000.22 2010/04/26 07:15:15 pvaramba noship $ */

-- Package name     : DPP_EXECUTIONPROCESS_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

  G_PKG_NAME CONSTANT VARCHAR2(30) := 'DPP_EXECUTIONPROCESS_PVT';
  G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
  G_FILE_NAME     CONSTANT VARCHAR2(14) := 'dppexppb.pls';

  G_NO_REC_PROC_MSG CONSTANT VARCHAR2(50) := 'This process is not enabled (process code) : ';
  G_NO_EVT_MSG CONSTANT VARCHAR2(52) := 'Business event not raised for the process code : ';
  G_NO_DAYS_MSG CONSTANT VARCHAR2(60) := 'Number of days is not set up in the System parameter for ';
  G_NO_TXN_MSG CONSTANT VARCHAR2(90) := 'No transactions effective after the number of days specified in the System parameter : ';
  G_AUTO_PROC_MSG CONSTANT VARCHAR2(50) := 'This process is not automatic (process code) : ';
  G_AUTO_EVT_SUCCESS_MSG CONSTANT VARCHAR2(50) := 'Auto notification events raised successfully.';
  G_PRCSING_TXN_MSG CONSTANT VARCHAR2(30) := 'Processing transaction : ';
  G_ERR_AUTO_NTF_MSG CONSTANT VARCHAR2(50) := 'Error while executing auto notification process.';
  G_NO_PROFILE_MSG CONSTANT VARCHAR2(45) := 'Supplier trade profile setup not available.';
  G_NO_EXEC_SETUP_MSG CONSTANT VARCHAR2(65) := 'No Execution processes setup available for this transaction : ';
  G_NO_SETUP_MSG CONSTANT VARCHAR2(60) := 'Supplier Trade Profile or Process Setup not available';

    PROCEDURE EXECUTE_PROCESS(
                            P_API_VERSION IN NUMBER,
                            P_INIT_MSG_LIST IN VARCHAR2 := FND_API.G_FALSE,
                            P_COMMIT IN VARCHAR2 := FND_API.G_FALSE,
                            P_VALIDATION_LEVEL IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
                            X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                            X_MSG_COUNT OUT NOCOPY NUMBER,
                            X_MSG_DATA OUT NOCOPY VARCHAR2,
                            P_TRANSACTION_HEADER_ID IN VARCHAR2,
                            P_TRANSACTION_NUMBER IN VARCHAR2,
                            P_PROCESS_CODE IN VARCHAR2);

    PROCEDURE EXECUTE_NOTIF_PROCESSES(
                            P_API_VERSION IN NUMBER,
                            P_INIT_MSG_LIST IN VARCHAR2 := FND_API.G_FALSE,
                            P_COMMIT IN VARCHAR2 := FND_API.G_FALSE,
                            P_VALIDATION_LEVEL IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
                            X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                            X_MSG_COUNT OUT NOCOPY NUMBER,
                            X_MSG_DATA OUT NOCOPY VARCHAR2,
                            P_SUPP_TRADE_PROFILE_ID IN VARCHAR2,
                            P_IN_ORG_ID IN NUMBER,
                            P_TRANSACTION_HEADER_ID IN VARCHAR2,
                            P_TRANSACTION_NUMBER IN VARCHAR2);

    FUNCTION GET_SUPPLIER_TRADE_PROFILE_ID ( P_VENDOR_ID IN VARCHAR2, P_VENDOR_SITE_ID IN VARCHAR2, P_ORG_ID IN VARCHAR2 ) RETURN NUMBER;

    FUNCTION IS_PROCESS_SETUP ( P_SUPP_TRADE_PROFILE_ID IN NUMBER, P_ORG_ID IN NUMBER ) RETURN BOOLEAN;

    FUNCTION GET_PROCESS_SETUP_ID ( P_VENDOR_ID IN VARCHAR2, P_VENDOR_SITE_ID IN VARCHAR2, P_ORG_ID IN VARCHAR2 ) RETURN NUMBER;

---------------------------------------------------------------------
-- PROCEDURE
--    INITIATE_EXECUTIONPROCESS
--
-- PURPOSE
--    Initiates the Execution Process for an org/transaction.
--
-- PARAMETERS
-- org id, transaction number.
----------------------------------------------------------------------
PROCEDURE INITIATE_EXECUTIONPROCESS(ERRBUF OUT NOCOPY VARCHAR2,
                                    RETCODE OUT NOCOPY VARCHAR2,
                                    P_IN_ORG_ID IN NUMBER,
                                    P_IN_TXN_NUMBER IN VARCHAR2)
IS
    L_API_VERSION CONSTANT NUMBER := 1.0;
    L_API_NAME CONSTANT VARCHAR2(30) := 'INITIATE_EXECUTIONPROCESS';
    L_FULL_NAME CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;

	 L_RETURN_STATUS          VARCHAR2(10);
    L_MSG_DATA               VARCHAR2(4000);
    L_MSG_COUNT              NUMBER;

    L_TXN_HDR_REC            DPP_BUSINESSEVENTS_PVT.DPP_TXN_HDR_REC_TYPE;
    L_TXN_LINE_ID            DPP_BUSINESSEVENTS_PVT.DPP_TXN_LINE_TBL_TYPE;
    L_FLAG                   BOOLEAN := FALSE;
    L_SUPP_TRADE_PROFILE_ID  NUMBER;
    L_SETUP_FLAG             BOOLEAN := FALSE;

	CURSOR get_auto_flag_csr(p_supp_trd_prf_id NUMBER, p_process_code VARCHAR2, p_txn_hdr_id VARCHAR2) IS
		SELECT NVL(AUTOMATIC_FLAG,'N') AUTOMATIC_FLAG
		FROM OZF_PROCESS_SETUP_ALL OPSA, DPP_EXECUTION_PROCESSES DEP
		WHERE NVL(SUPP_TRADE_PROFILE_ID,0) = NVL(P_SUPP_TRD_PRF_ID,0)
		AND OPSA.PROCESS_CODE = P_PROCESS_CODE
		AND OPSA.PROCESS_CODE = DEP.PROCESS_CODE
		AND OPSA.ORG_ID = P_IN_ORG_ID
		AND DEP.TRANSACTION_HEADER_ID=P_TXN_HDR_ID;

    --Cursor to check if the customer claims tab is already populated
    CURSOR get_customer_claim_csr(p_txn_header_id IN NUMBER) IS
        SELECT dpp.transaction_header_id
        FROM dpp_transaction_headers_all dpp
        WHERE dpp.transaction_header_id = p_txn_header_id
        AND NOT EXISTS (SELECT DISTINCT dcc.transaction_header_id
        FROM dpp_customer_claims_all dcc
        WHERE dcc.transaction_header_id = dpp.transaction_header_id);

    --Cursor for Update PO
    CURSOR get_lines_for_updatepo_csr(p_txn_hdr_id IN NUMBER) IS
        SELECT dpp.transaction_header_id
        FROM dpp_transaction_headers_all dpp
        WHERE dpp.transaction_header_id = p_txn_hdr_id
        AND EXISTS (SELECT update_purchasing_docs
        FROM dpp_transaction_lines_all dtl
        WHERE nvl(update_purchasing_docs,'N') = 'N'
        AND dtl.transaction_header_id = p_txn_hdr_id);

    --Cursor for Update inv costing
    CURSOR get_lines_for_updateinv_csr(p_txn_hdr_id IN NUMBER) IS
        SELECT dtl.transaction_line_id
        FROM dpp_transaction_lines_all dtl
        WHERE dtl.transaction_header_id = p_txn_hdr_id
        AND EXISTS (SELECT UPDATE_INVENTORY_COSTING
        FROM dpp_transaction_lines_all
        WHERE nvl(UPDATE_INVENTORY_COSTING,'N') = 'N'
        AND transaction_header_id = p_txn_hdr_id)
        AND rownum = 1;

    --Cursor for Update item List Price
    CURSOR get_lines_for_updlistprice_csr(p_txn_hdr_id IN NUMBER) IS
        SELECT dtl.transaction_line_id
        FROM dpp_transaction_lines_all dtl
        WHERE dtl.transaction_header_id = p_txn_hdr_id
        AND EXISTS (SELECT UPDATE_ITEM_LIST_PRICE
        FROM dpp_transaction_lines_all
        WHERE nvl(UPDATE_ITEM_LIST_PRICE,'N') = 'N'
        AND transaction_header_id = p_txn_hdr_id)
        AND rownum = 1;

    CURSOR get_approved_txn_csr (p_txn_number VARCHAR2) IS
       SELECT DPP.TRANSACTION_HEADER_ID,
              DPP.TRANSACTION_NUMBER,
              DPP.VENDOR_ID,
              DPP.VENDOR_SITE_ID
       FROM DPP_TRANSACTION_HEADERS_ALL DPP
       WHERE DPP.TRANSACTION_STATUS = 'APPROVED'
       AND DPP.EFFECTIVE_START_DATE <= SYSDATE
       AND TO_NUMBER(DPP.ORG_ID) = P_IN_ORG_ID
       AND DPP.TRANSACTION_NUMBER = NVL(P_TXN_NUMBER,DPP.TRANSACTION_NUMBER);

BEGIN

    -- Initialize return status to sucess
    ERRBUF := 'SUCCESS';
    RETCODE := 0;

    SAVEPOINT INITIATE_EXEC;

    DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_PROCEDURE, 'dpp.plsql.' || L_FULL_NAME,  'Public API: ' || L_API_NAME || ' started at: ' || to_char(sysdate,'dd-mon-yyyy hh24:mi:ss'));

    --Initialize message list
    FND_MSG_PUB.INITIALIZE;

    -- Initialize API return status to sucess
    L_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    --Get all the active transactions
    FOR get_approved_txn_rec IN get_approved_txn_csr(p_in_txn_number)  LOOP

      FND_FILE.PUT_LINE(FND_FILE.LOG,'Concurrent program executed for the transaction header id : ' ||get_approved_txn_rec.transaction_header_id);
      FND_FILE.NEW_LINE(FND_FILE.LOG);

      DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  '*Concurrent program executed for the transaction header id : '
                ||get_approved_txn_rec.transaction_header_id);


      l_supp_trade_profile_id := GET_PROCESS_SETUP_ID (get_approved_txn_rec.vendor_id, get_approved_txn_rec.vendor_site_id, P_IN_ORG_ID);

      FOR get_auto_flag_rec IN get_auto_flag_csr(l_supp_trade_profile_id, 'UPDTPO', get_approved_txn_rec.transaction_header_id) LOOP
        l_flag := TRUE;
        l_setup_flag  := TRUE;
        IF get_auto_flag_rec.automatic_flag = 'Y' THEN
          FOR get_lines_for_updatepo_rec IN get_lines_for_updatepo_csr(get_approved_txn_rec.transaction_header_id) LOOP
            EXECUTE_PROCESS(L_API_VERSION, FND_API.G_FALSE, FND_API.G_FALSE, FND_API.G_VALID_LEVEL_FULL, L_RETURN_STATUS, L_MSG_COUNT,
                L_MSG_DATA, GET_APPROVED_TXN_REC.TRANSACTION_HEADER_ID, GET_APPROVED_TXN_REC.TRANSACTION_NUMBER, 'UPDTPO');
            IF L_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            ELSIF L_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END LOOP;
        ELSE
        FND_FILE.PUT_LINE(FND_FILE.LOG, G_AUTO_PROC_MSG || 'UPDTPO');
        FND_FILE.NEW_LINE(FND_FILE.LOG);
        DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,   '*' || G_AUTO_PROC_MSG || 'UPDTPO');
        END IF;
      END LOOP;
      IF NOT l_flag  THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, G_NO_REC_PROC_MSG || 'UPDTPO');
        FND_FILE.NEW_LINE(FND_FILE.LOG);
        DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,   '*' || G_NO_REC_PROC_MSG || 'UPDTPO');
      END IF;

      FOR get_auto_flag_rec IN get_auto_flag_csr(l_supp_trade_profile_id,   'INVC', get_approved_txn_rec.transaction_header_id) LOOP
        l_flag := TRUE;
        l_setup_flag  := TRUE;
        IF get_auto_flag_rec.automatic_flag = 'Y' THEN
          FOR get_lines_for_updateinv_rec IN get_lines_for_updateinv_csr(get_approved_txn_rec.transaction_header_id) LOOP
            EXECUTE_PROCESS(L_API_VERSION, FND_API.G_FALSE, FND_API.G_FALSE, FND_API.G_VALID_LEVEL_FULL, L_RETURN_STATUS, L_MSG_COUNT,
                L_MSG_DATA, GET_APPROVED_TXN_REC.TRANSACTION_HEADER_ID, GET_APPROVED_TXN_REC.TRANSACTION_NUMBER, 'INVC');
            IF L_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            ELSIF L_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END LOOP;
        ELSE
        FND_FILE.PUT_LINE(FND_FILE.LOG, G_AUTO_PROC_MSG || 'INVC');
        FND_FILE.NEW_LINE(FND_FILE.LOG);
            DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,   '*' || G_AUTO_PROC_MSG || 'INVC');
        END IF;
      END LOOP;
      IF NOT l_flag  THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, G_NO_REC_PROC_MSG || 'INVC');
        FND_FILE.NEW_LINE(FND_FILE.LOG);
        DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,   '*' || G_NO_REC_PROC_MSG || 'INVC');
      END IF;

      FOR get_auto_flag_rec IN get_auto_flag_csr(l_supp_trade_profile_id,   'UPDTLP', get_approved_txn_rec.transaction_header_id) LOOP
        l_flag := TRUE;
        l_setup_flag  := TRUE;
        IF get_auto_flag_rec.automatic_flag = 'Y' THEN
          FOR get_lines_for_updlistprice_rec IN get_lines_for_updlistprice_csr(get_approved_txn_rec.transaction_header_id) LOOP
            EXECUTE_PROCESS(L_API_VERSION, FND_API.G_FALSE, FND_API.G_FALSE, FND_API.G_VALID_LEVEL_FULL, L_RETURN_STATUS, L_MSG_COUNT,
                L_MSG_DATA, GET_APPROVED_TXN_REC.TRANSACTION_HEADER_ID, GET_APPROVED_TXN_REC.TRANSACTION_NUMBER, 'UPDTLP');
            IF L_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            ELSIF L_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END LOOP;
        ELSE
        FND_FILE.PUT_LINE(FND_FILE.LOG, G_AUTO_PROC_MSG || 'UPDTLP');
        FND_FILE.NEW_LINE(FND_FILE.LOG);
        DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,   '*' || G_AUTO_PROC_MSG || 'UPDTLP');
        END IF;
      END LOOP;
      IF NOT l_flag  THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, G_NO_REC_PROC_MSG || 'UPDTLP');
        FND_FILE.NEW_LINE(FND_FILE.LOG);
        DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,   '*' || G_NO_REC_PROC_MSG || 'UPDTLP');
      END IF;

     EXECUTE_NOTIF_PROCESSES(L_API_VERSION, FND_API.G_FALSE, FND_API.G_FALSE, FND_API.G_VALID_LEVEL_FULL, L_RETURN_STATUS, L_MSG_COUNT,
        L_MSG_DATA, L_SUPP_TRADE_PROFILE_ID,P_IN_ORG_ID, GET_APPROVED_TXN_REC.TRANSACTION_HEADER_ID,GET_APPROVED_TXN_REC.TRANSACTION_NUMBER);
     IF L_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
     ELSIF L_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     --Check if the customer claims tab is populated
     FOR get_customer_claim_rec IN get_customer_claim_csr(get_approved_txn_rec.transaction_header_id) LOOP
       EXECUTE_PROCESS(L_API_VERSION, FND_API.G_FALSE, FND_API.G_FALSE, FND_API.G_VALID_LEVEL_FULL, L_RETURN_STATUS, L_MSG_COUNT,
        L_MSG_DATA, GET_APPROVED_TXN_REC.TRANSACTION_HEADER_ID, GET_APPROVED_TXN_REC.TRANSACTION_NUMBER, 'POPCUSTCLAIM');
       IF L_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
       ELSIF L_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     END LOOP;

    END LOOP;

    --Commit thechanges
    COMMIT;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO INITIATE_EXEC;
     retcode := 2;
     errbuf := 'Error';
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE, p_count   => l_msg_count, p_data    => l_msg_data );
     IF l_msg_count > 1 THEN
            FOR I IN 1..l_msg_count LOOP
               l_msg_data := SUBSTR((l_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
            END LOOP;
     END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,substr(('Error Message : ' || l_msg_data),1,4000));
    FND_FILE.NEW_LINE(FND_FILE.LOG);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO INITIATE_EXEC;
     retcode := 2;
     errbuf := 'Error';
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE, p_count   => l_msg_count, p_data    => l_msg_data );
     IF l_msg_count > 1 THEN
            FOR I IN 1..l_msg_count LOOP
               l_msg_data := SUBSTR((l_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
            END LOOP;
     END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,substr(('Error Message : ' || l_msg_data),1,4000));
    FND_FILE.NEW_LINE(FND_FILE.LOG);
  WHEN OTHERS THEN
     ROLLBACK TO INITIATE_EXEC;
     retcode := 2;
     errbuf := 'Error';
     fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
     fnd_message.set_token('ROUTINE', l_full_name);
     fnd_message.set_token('ERRNO', sqlcode);
     fnd_message.set_token('REASON', sqlerrm);
     FND_MSG_PUB.add;

     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE, p_count   => l_msg_count, p_data    => l_msg_data );
     IF l_msg_count > 1 THEN
            FOR I IN 1..l_msg_count LOOP
               l_msg_data := SUBSTR((l_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
            END LOOP;
     END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,substr(('Error Message : ' || l_msg_data),1,4000));
    FND_FILE.NEW_LINE(FND_FILE.LOG);

END INITIATE_EXECUTIONPROCESS;

---------------------------------------------------------------------
-- PROCEDURE
--    EXECUTE_NOTIF_PROCESSES
--
-- PURPOSE
--    Executes the Notification Process
--
-- PARAMETERS
-- supplier trade profile id(if null, the setup is taken from the system parameters)
-- org-id, transaction header id, transaction number.
----------------------------------------------------------------------
PROCEDURE EXECUTE_NOTIF_PROCESSES(
                            P_API_VERSION IN NUMBER,
                            P_INIT_MSG_LIST IN VARCHAR2 := FND_API.G_FALSE,
                            P_COMMIT IN VARCHAR2 := FND_API.G_FALSE,
                            P_VALIDATION_LEVEL IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
                            X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                            X_MSG_COUNT OUT NOCOPY NUMBER,
                            X_MSG_DATA OUT NOCOPY VARCHAR2,
                            P_SUPP_TRADE_PROFILE_ID IN VARCHAR2,
                            P_IN_ORG_ID IN NUMBER,
                            P_TRANSACTION_HEADER_ID IN VARCHAR2,
                            P_TRANSACTION_NUMBER IN VARCHAR2)
  IS

    L_API_VERSION CONSTANT NUMBER := 1.0;
    L_API_NAME CONSTANT VARCHAR2(30) := 'EXECUTE_NOTIF_PROCESSES';
    L_FULL_NAME CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;

	 l_flag boolean := false;

    CURSOR get_lines_for_notif_csr(p_txn_hdr_id IN NUMBER)
      IS
         SELECT dpp.transaction_header_id
          FROM dpp_transaction_headers_all dpp
         WHERE dpp.transaction_header_id = p_txn_hdr_id
     AND ROWNUM=1;

    CURSOR get_auto_flag_csr(p_supp_trd_prf_id NUMBER, p_process_code VARCHAR2, p_txn_hdr_id VARCHAR2) IS
        SELECT NVL(AUTOMATIC_FLAG,'N') AUTOMATIC_FLAG
        FROM OZF_PROCESS_SETUP_ALL OPSA, DPP_EXECUTION_PROCESSES DEP
        WHERE NVL(SUPP_TRADE_PROFILE_ID,0) = NVL(P_SUPP_TRD_PRF_ID,0)
        AND OPSA.PROCESS_CODE = P_PROCESS_CODE
        AND OPSA.PROCESS_CODE = DEP.PROCESS_CODE
        AND OPSA.ORG_ID = P_IN_ORG_ID
        AND DEP.TRANSACTION_HEADER_ID=P_TXN_HDR_ID;

  BEGIN

    SAVEPOINT EXECUTE_NOTIF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.COMPATIBLE_API_CALL (L_API_VERSION, P_API_VERSION, L_API_NAME, G_PKG_NAME)
    THEN
      DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_ERROR, 'dpp.plsql.' || L_FULL_NAME, L_API_NAME || ' : Not a compatible API call.');
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_PROCEDURE, 'dpp.plsql.' || L_FULL_NAME,  L_API_NAME||': START');

    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.TO_BOOLEAN (P_INIT_MSG_LIST) THEN
      FND_MSG_PUB.INITIALIZE;
    END IF;

    -- Initialize API return status to sucess
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

      FOR get_lines_for_notif_rec IN get_lines_for_notif_csr(p_transaction_header_id) LOOP
        l_flag := FALSE;
        FOR get_auto_flag_rec IN get_auto_flag_csr(p_supp_trade_profile_id,   'NTFYPO', p_transaction_header_id) LOOP
        l_flag := TRUE;
        IF get_auto_flag_rec.automatic_flag = 'Y' THEN
          EXECUTE_PROCESS(L_API_VERSION, FND_API.G_FALSE, FND_API.G_FALSE, FND_API.G_VALID_LEVEL_FULL, X_RETURN_STATUS, X_MSG_COUNT, X_MSG_DATA,
                P_TRANSACTION_HEADER_ID,P_TRANSACTION_NUMBER, 'NTFYPO');
          IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
          ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        ELSE
          FND_FILE.PUT_LINE(FND_FILE.LOG, G_AUTO_PROC_MSG || 'NTFYPO');
          FND_FILE.NEW_LINE(FND_FILE.LOG);
          DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,   '*' || G_AUTO_PROC_MSG || 'NTFYPO');
        END IF;
        END LOOP;
        IF NOT l_flag  THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, G_NO_REC_PROC_MSG || 'NTFYPO');
            FND_FILE.NEW_LINE(FND_FILE.LOG);
            DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,   '*' || G_NO_REC_PROC_MSG || 'NYFYPO');
        END IF;

        l_flag := FALSE;
        FOR get_auto_flag_rec IN get_auto_flag_csr(p_supp_trade_profile_id,   'INPL', p_transaction_header_id) LOOP
        l_flag := TRUE;
        IF get_auto_flag_rec.automatic_flag = 'Y' THEN
              EXECUTE_PROCESS(L_API_VERSION, FND_API.G_FALSE, FND_API.G_FALSE, FND_API.G_VALID_LEVEL_FULL, X_RETURN_STATUS, X_MSG_COUNT, X_MSG_DATA,
                P_TRANSACTION_HEADER_ID,P_TRANSACTION_NUMBER, 'INPL');
              IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
        ELSE
          FND_FILE.PUT_LINE(FND_FILE.LOG, G_AUTO_PROC_MSG || 'INPL');
          FND_FILE.NEW_LINE(FND_FILE.LOG);
          DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,   '*' || G_AUTO_PROC_MSG || 'INPL');
        END IF;
        END LOOP;
        IF NOT l_flag  THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, G_NO_REC_PROC_MSG || 'INPL');
            FND_FILE.NEW_LINE(FND_FILE.LOG);
            DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,   '*' || G_NO_REC_PROC_MSG || 'INPL');
        END IF;

        l_flag := FALSE;
        FOR get_auto_flag_rec IN get_auto_flag_csr(p_supp_trade_profile_id,   'OUTPL', p_transaction_header_id) LOOP
        l_flag := TRUE;
        IF get_auto_flag_rec.automatic_flag = 'Y' THEN
          EXECUTE_PROCESS(L_API_VERSION, FND_API.G_FALSE, FND_API.G_FALSE, FND_API.G_VALID_LEVEL_FULL, X_RETURN_STATUS, X_MSG_COUNT, X_MSG_DATA,
                P_TRANSACTION_HEADER_ID,P_TRANSACTION_NUMBER, 'OUTPL');
          IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
          ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        ELSE
          FND_FILE.PUT_LINE(FND_FILE.LOG, G_AUTO_PROC_MSG || 'OUTPL');
          FND_FILE.NEW_LINE(FND_FILE.LOG);
          DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,   '*' || G_AUTO_PROC_MSG || 'OUTPL');
        END IF;
        END LOOP;
        IF NOT l_flag  THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, G_NO_REC_PROC_MSG || 'OUTPL');
            FND_FILE.NEW_LINE(FND_FILE.LOG);
            DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,   '*' || G_NO_REC_PROC_MSG || 'OUTPL');
        END IF;

        l_flag := FALSE;
        FOR get_auto_flag_rec IN get_auto_flag_csr(p_supp_trade_profile_id,   'PROMO', p_transaction_header_id) LOOP
        l_flag := TRUE;
        IF get_auto_flag_rec.automatic_flag = 'Y' THEN
          EXECUTE_PROCESS(L_API_VERSION, FND_API.G_FALSE, FND_API.G_FALSE, FND_API.G_VALID_LEVEL_FULL, X_RETURN_STATUS, X_MSG_COUNT, X_MSG_DATA,
                P_TRANSACTION_HEADER_ID,P_TRANSACTION_NUMBER, 'PROMO');
          IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
          ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        ELSE
          FND_FILE.PUT_LINE(FND_FILE.LOG, G_AUTO_PROC_MSG || 'PROMO');
          FND_FILE.NEW_LINE(FND_FILE.LOG);
          DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,   '*' || G_AUTO_PROC_MSG || 'PROMO');
        END IF;
        END LOOP;
        IF NOT l_flag  THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, G_NO_REC_PROC_MSG || 'PROMO');
            FND_FILE.NEW_LINE(FND_FILE.LOG);
            DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,   '*' || G_NO_REC_PROC_MSG || 'PROMO');
        END IF;

      END LOOP;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO EXECUTE_NOTIF;
     FND_MSG_PUB.COUNT_AND_GET (P_ENCODED => FND_API.G_FALSE, P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );
     IF x_msg_count > 1 THEN
            FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
            END LOOP;
     END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG,substr(('Error Message : ' || x_msg_data),1,4000));
    FND_FILE.NEW_LINE(FND_FILE.LOG);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO EXECUTE_NOTIF;
          FND_MSG_PUB.COUNT_AND_GET (P_ENCODED => FND_API.G_FALSE, P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );
     IF x_msg_count > 1 THEN
            FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
            END LOOP;
     END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG,substr(('Error Message : ' || x_msg_data),1,4000));
    FND_FILE.NEW_LINE(FND_FILE.LOG);

  WHEN OTHERS THEN
     ROLLBACK TO EXECUTE_NOTIF;
     fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
     fnd_message.set_token('ROUTINE', l_full_name);
     fnd_message.set_token('ERRNO', sqlcode);
     fnd_message.set_token('REASON', sqlerrm);
     FND_MSG_PUB.add;

     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE, p_count   => x_msg_count, p_data    => x_msg_data );
     IF x_msg_count > 1 THEN
            FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
            END LOOP;
     END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG,substr(('Error Message : ' || x_msg_data),1,4000));
    FND_FILE.NEW_LINE(FND_FILE.LOG);


END EXECUTE_NOTIF_PROCESSES;


---------------------------------------------------------------------
-- PROCEDURE
--    EXECUTE_PROCESS
--
-- PURPOSE
--    Executes a process depending on the process code.
--
-- PARAMETERS
-- transaction header id, transaction number, process code.
----------------------------------------------------------------------
PROCEDURE EXECUTE_PROCESS(P_API_VERSION IN NUMBER,
                          P_INIT_MSG_LIST IN VARCHAR2 := FND_API.G_FALSE,
                          P_COMMIT IN VARCHAR2 := FND_API.G_FALSE,
                          P_VALIDATION_LEVEL IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
                          X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                          X_MSG_COUNT OUT NOCOPY NUMBER,
                          X_MSG_DATA OUT NOCOPY VARCHAR2,
                          P_TRANSACTION_HEADER_ID IN VARCHAR2,
                          P_TRANSACTION_NUMBER IN VARCHAR2,
                          P_PROCESS_CODE IN VARCHAR2)
IS

        L_API_VERSION CONSTANT NUMBER := 1.0;
        L_API_NAME CONSTANT VARCHAR2(30) := 'EXECUTE_PROCESS';
        L_FULL_NAME CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;

        L_TXN_HDR_REC            DPP_BUSINESSEVENTS_PVT.DPP_TXN_HDR_REC_TYPE;
        L_TXN_LINE_ID            DPP_BUSINESSEVENTS_PVT.DPP_TXN_LINE_TBL_TYPE;

        L_FLAG                   BOOLEAN := FALSE;


BEGIN

        SAVEPOINT EXEC_PROCESS;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.COMPATIBLE_API_CALL (L_API_VERSION, P_API_VERSION, L_API_NAME, G_PKG_NAME)
        THEN
          DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_ERROR, 'dpp.plsql.' || L_FULL_NAME, L_API_NAME || ' : Not a compatible API call.');
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_PROCEDURE, 'dpp.plsql.' || L_FULL_NAME,  L_API_NAME||': START');

        --Initialize message list if p_init_msg_list is TRUE.
        IF FND_API.TO_BOOLEAN (P_INIT_MSG_LIST) THEN
          FND_MSG_PUB.INITIALIZE;
        END IF;

        -- Initialize API return status to sucess
        X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

	L_TXN_HDR_REC := NULL;
	L_TXN_LINE_ID.DELETE();
	L_TXN_HDR_REC.TRANSACTION_HEADER_ID := P_TRANSACTION_HEADER_ID;
	L_TXN_HDR_REC.TRANSACTION_NUMBER  := P_TRANSACTION_NUMBER;
	L_TXN_HDR_REC.PROCESS_CODE := P_PROCESS_CODE;

	--Raise business event for the process
	DPP_BUSINESSEVENTS_PVT.RAISE_BUSINESS_EVENT( P_API_VERSION         =>    1.0
                                                ,P_INIT_MSG_LIST       =>    FND_API.G_FALSE
                                                ,P_COMMIT              =>    FND_API.G_FALSE
                                                ,P_VALIDATION_LEVEL    =>    FND_API.G_VALID_LEVEL_FULL
                                                ,X_RETURN_STATUS       =>    X_RETURN_STATUS
                                                ,X_MSG_COUNT           =>    X_MSG_COUNT
                                                ,X_MSG_DATA            =>    X_MSG_DATA
                                                ,P_TXN_HDR_REC         =>    L_TXN_HDR_REC
                                                ,P_TXN_LINE_ID         =>    L_TXN_LINE_ID
                                                );

        IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Business event raised for the process code : ' || P_PROCESS_CODE);
            FND_FILE.NEW_LINE(FND_FILE.LOG);
            DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  '*Business event raised for the process code : ' || P_PROCESS_CODE);
	END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO EXEC_PROCESS;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE, p_count   => x_msg_count, p_data    => x_msg_data );
     IF x_msg_count > 1 THEN
            FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
            END LOOP;
     END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, G_NO_EVT_MSG || P_PROCESS_CODE);
    FND_FILE.NEW_LINE(FND_FILE.LOG);
    FND_FILE.PUT_LINE(FND_FILE.LOG,substr(('Error Message : ' || x_msg_data),1,4000));
    FND_FILE.NEW_LINE(FND_FILE.LOG);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO EXEC_PROCESS;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE, p_count   => x_msg_count, p_data    => x_msg_data );
     IF x_msg_count > 1 THEN
            FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
            END LOOP;
     END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, G_NO_EVT_MSG || P_PROCESS_CODE);
    FND_FILE.NEW_LINE(FND_FILE.LOG);
    FND_FILE.PUT_LINE(FND_FILE.LOG,substr(('Error Message : ' || x_msg_data),1,4000));
    FND_FILE.NEW_LINE(FND_FILE.LOG);

  WHEN OTHERS THEN
     ROLLBACK TO EXEC_PROCESS;
     FND_MESSAGE.SET_NAME('FND', 'SQL_PLSQL_ERROR');
     FND_MESSAGE.SET_TOKEN('ROUTINE', L_FULL_NAME);
     FND_MESSAGE.SET_TOKEN('ERRNO', SQLCODE);
     FND_MESSAGE.SET_TOKEN('REASON', SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE, p_count   => x_msg_count, p_data    => x_msg_data );
     IF x_msg_count > 1 THEN
            FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
            END LOOP;
     END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, G_NO_EVT_MSG || P_PROCESS_CODE);
    FND_FILE.NEW_LINE(FND_FILE.LOG);
    FND_FILE.PUT_LINE(FND_FILE.LOG,substr(('Error Message : ' || x_msg_data),1,4000));
    FND_FILE.NEW_LINE(FND_FILE.LOG);


END EXECUTE_PROCESS;


---------------------------------------------------------------------
-- PROCEDURE
--    GET_SUPPLIER_TRADE_PROFILE_ID
--
-- PURPOSE
--    Returns the supplier trade profile id.
--
-- PARAMETERS
-- vendor id, vendor site id, org id.
----------------------------------------------------------------------
FUNCTION GET_SUPPLIER_TRADE_PROFILE_ID ( P_VENDOR_ID IN VARCHAR2, P_VENDOR_SITE_ID IN VARCHAR2, P_ORG_ID IN VARCHAR2) RETURN NUMBER IS
L_RET_ID NUMBER;
L_API_NAME CONSTANT VARCHAR2(30) := 'GET_SUPPLIER_TRADE_PROFILE_ID';
L_FULL_NAME CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;
BEGIN
    SELECT SUPP_TRADE_PROFILE_ID
    INTO L_RET_ID
    FROM OZF_SUPP_TRD_PRFLS_ALL
    WHERE SUPPLIER_ID = P_VENDOR_ID
    AND SUPPLIER_SITE_ID = P_VENDOR_SITE_ID
    AND ORG_ID = P_ORG_ID;

    RETURN (L_RET_ID);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        L_RET_ID := null;
        fnd_message.set_name( 'DPP','DPP_SUPP_TRDPRFLS_MISSING_ERR');
        fnd_msg_pub.add;
        DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME, 'Supplier trade profile setup not available');
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Supplier trade profile setup not available');
        FND_FILE.NEW_LINE(FND_FILE.LOG);
        RAISE FND_API.G_EXC_ERROR;
    WHEN OTHERS THEN
        L_RET_ID := null;
        DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME, 'Exception while fetching supp_trade_profile_id: ' || SQLERRM);
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Exception while fetching supp_trade_profile_id: ' || SQLERRM);
        FND_FILE.NEW_LINE(FND_FILE.LOG);
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END GET_SUPPLIER_TRADE_PROFILE_ID;


---------------------------------------------------------------------
-- PROCEDURE
--    IS_PROCESS_SETUP
--
-- PURPOSE
--    Checks if the price protection setup is done for a supplier with the specified id.
--    If the id is null, the system parameter is checked.
--
-- PARAMETERS
-- Supplier trade profile id, org id.
----------------------------------------------------------------------
FUNCTION IS_PROCESS_SETUP ( P_SUPP_TRADE_PROFILE_ID IN NUMBER, P_ORG_ID IN NUMBER ) RETURN BOOLEAN IS

  L_COUNT NUMBER := 0;

  L_API_NAME CONSTANT VARCHAR2(30) := 'IS_PROCESS_SETUP';
  L_FULL_NAME CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;

  CURSOR GET_PROCESS_SETUP_CNT_CSR (P_SUPP_TRADE_PROFILE_ID NUMBER, P_ORG_ID NUMBER)
  IS
    SELECT COUNT(1)
    FROM OZF_PROCESS_SETUP_ALL
    WHERE NVL(SUPP_TRADE_PROFILE_ID,0) = NVL(P_SUPP_TRADE_PROFILE_ID,0)
    AND ENABLED_FLAG = 'Y'
    AND ORG_ID = P_ORG_ID;

BEGIN

  OPEN GET_PROCESS_SETUP_CNT_CSR(P_SUPP_TRADE_PROFILE_ID, P_ORG_ID);
    FETCH GET_PROCESS_SETUP_CNT_CSR INTO L_COUNT;
  CLOSE GET_PROCESS_SETUP_CNT_CSR;

  IF L_COUNT = 0 THEN	--Process setup does not exist for the supplier.
    RETURN FALSE;
  ELSE
    RETURN TRUE;
  END IF;

EXCEPTION
WHEN OTHERS THEN
  DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME, 'Exception while fetching from OZF_PROCESS_SETUP_ALL: ' || SQLERRM);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'Exception while fetching from OZF_PROCESS_SETUP_ALL: ' || SQLERRM);
  FND_FILE.NEW_LINE(FND_FILE.LOG);
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END IS_PROCESS_SETUP;


---------------------------------------------------------------------
-- PROCEDURE
--    GET_PROCESS_SETUP_ID
--
-- PURPOSE
--    Returns the supplier trade profile id if the setup is available, else returns null.
--
-- PARAMETERS
-- vendor id, vendor site id, org id.
----------------------------------------------------------------------
FUNCTION GET_PROCESS_SETUP_ID ( P_VENDOR_ID IN VARCHAR2, P_VENDOR_SITE_ID IN VARCHAR2, P_ORG_ID IN VARCHAR2 ) RETURN NUMBER IS

L_SUPP_TRADE_PROFILE_ID NUMBER;

  L_API_NAME CONSTANT VARCHAR2(30) := 'GET_PROCESS_SETUP_ID';
  L_FULL_NAME CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;

BEGIN

      L_SUPP_TRADE_PROFILE_ID := GET_SUPPLIER_TRADE_PROFILE_ID(P_VENDOR_ID, P_VENDOR_SITE_ID, P_ORG_ID);

      --Check if the Process Setup is done for the Supplier, Supplier site and Operating Unit
      IF NOT IS_PROCESS_SETUP(L_SUPP_TRADE_PROFILE_ID, P_ORG_ID) THEN
       L_SUPP_TRADE_PROFILE_ID := NULL;
       DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'No setup at supplier trade profile for vendor id : '
                || P_VENDOR_ID || ' at site id ' || P_VENDOR_SITE_ID || ', org id ' || P_ORG_ID);
       --Check if setup is available at system parameter level
       IF NOT IS_PROCESS_SETUP(NULL, P_ORG_ID) THEN
         --Process Setup does not exist
         fnd_message.set_name( 'DPP','DPP_PROCESS_SETUP_MISSING_ERR');
         fnd_msg_pub.add;
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'No price protection setup available for vendor id : '
                || P_VENDOR_ID || ' at site id ' || P_VENDOR_SITE_ID || ', org id ' || P_ORG_ID);
         FND_FILE.NEW_LINE(FND_FILE.LOG);
         DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,   'No price protection setup available for vendor id : '
                || P_VENDOR_ID || ' at site id ' || P_VENDOR_SITE_ID || ', org id ' || P_ORG_ID );
         RAISE FND_API.G_EXC_ERROR;
       END IF;
      END IF;

      RETURN L_SUPP_TRADE_PROFILE_ID;

END GET_PROCESS_SETUP_ID;


---------------------------------------------------------------------
-- PROCEDURE
--    INITIATE_NOTIFICATION_PROCESS
--
-- PURPOSE
--    Initiates the notification Execution Process for transactions under an org.
--
-- PARAMETERS
-- org id.
----------------------------------------------------------------------
PROCEDURE INITIATE_NOTIFICATION_PROCESS(ERRBUF OUT NOCOPY VARCHAR2,
                                    RETCODE OUT NOCOPY VARCHAR2,
                                    P_IN_ORG_ID IN   NUMBER
                                   )
IS
    L_API_VERSION CONSTANT NUMBER := 1.0;
    L_API_NAME CONSTANT VARCHAR2(30) := 'INITIATE_NOTIFICATION_PROCESS';
    L_FULL_NAME CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;

    L_RETURN_STATUS          VARCHAR2(10);
    L_MSG_DATA               VARCHAR2(4000);
    L_MSG_COUNT              NUMBER;

    L_TXN_HDR_REC            DPP_BUSINESSEVENTS_PVT.DPP_TXN_HDR_REC_TYPE;
    L_TXN_LINE_ID            DPP_BUSINESSEVENTS_PVT.DPP_TXN_LINE_TBL_TYPE;

    L_SUPP_TRADE_PROFILE_ID  NUMBER;

	 L_DAYS NUMBER;
    NO_TXN_FLAG BOOLEAN := TRUE;

CURSOR get_txn_to_notify_csr (p_days in number)
IS
   SELECT dpp.transaction_header_id,
          dpp.transaction_number,
          dpp.vendor_id,
          dpp.vendor_site_id
    FROM dpp_transaction_headers_all dpp
   WHERE dpp.transaction_status = 'ACTIVE'
     AND trunc(dpp.effective_start_date) = trunc(sysdate)+p_days
     AND to_number(dpp.org_id) = p_in_org_id;

BEGIN

    ERRBUF := 'SUCCESS';
    RETCODE := 0;

    SAVEPOINT INITIATE_NOTIF;

    DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Public API: ' || l_api_name || ' started at: ' || to_char(sysdate,'dd-mon-yyyy hh24:mi:ss'));

    --Initialize message list
    FND_MSG_PUB.INITIALIZE;

    -- Initialize API return status to sucess
    L_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

     BEGIN
        SELECT AUTOMATE_NOTIFICATION_DAYS INTO L_DAYS
        FROM OZF_SYS_PARAMETERS_ALL
        WHERE ORG_ID = P_IN_ORG_ID;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        retcode := 2;
        errbuf := 'Error';
        FND_FILE.PUT_LINE(FND_FILE.LOG, G_NO_DAYS_MSG || P_IN_ORG_ID);
        FND_FILE.NEW_LINE(FND_FILE.LOG);
        DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  '*' || G_NO_DAYS_MSG || P_IN_ORG_ID);

    END;

    DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME, L_API_NAME || ' Number of days for auto notif:' || L_DAYS);

    IF L_DAYS >= 0
    THEN
    FOR get_txn_to_notify_rec IN get_txn_to_notify_csr(l_days)  LOOP
        FND_FILE.PUT_LINE(FND_FILE.LOG, G_PRCSING_TXN_MSG || get_txn_to_notify_rec.transaction_number);
        FND_FILE.NEW_LINE(FND_FILE.LOG);
        DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME, '*' || G_PRCSING_TXN_MSG || get_txn_to_notify_rec.transaction_number);

        NO_TXN_FLAG := FALSE;

        L_SUPP_TRADE_PROFILE_ID := GET_PROCESS_SETUP_ID(GET_TXN_TO_NOTIFY_REC.VENDOR_ID, GET_TXN_TO_NOTIFY_REC.VENDOR_SITE_ID, P_IN_ORG_ID);
        EXECUTE_NOTIF_PROCESSES(L_API_VERSION, FND_API.G_FALSE,FND_API.G_FALSE, FND_API.G_VALID_LEVEL_FULL, L_RETURN_STATUS, L_MSG_COUNT, L_MSG_DATA,
                l_supp_trade_profile_id,p_in_org_id, get_txn_to_notify_rec.transaction_header_id,get_txn_to_notify_rec.transaction_number);

        IF L_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS THEN
           FND_FILE.PUT_LINE(FND_FILE.LOG, G_AUTO_EVT_SUCCESS_MSG);
           FND_FILE.NEW_LINE(FND_FILE.LOG);
           DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME, '*' || G_AUTO_EVT_SUCCESS_MSG );
        ELSE
             retcode := 1;
             errbuf := 'Warning';
             FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE, p_count   => l_msg_count, p_data    => l_msg_data );
             IF l_msg_count > 1 THEN
                    FOR I IN 1..l_msg_count LOOP
                       l_msg_data := SUBSTR((l_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
                    END LOOP;
             END IF;
             FND_FILE.PUT_LINE(FND_FILE.LOG,G_ERR_AUTO_NTF_MSG);
             FND_FILE.NEW_LINE(FND_FILE.LOG);
             FND_FILE.PUT_LINE(FND_FILE.LOG,substr(('Error Message : ' || l_msg_data),1,4000));
             FND_FILE.NEW_LINE(FND_FILE.LOG);
        END IF;

    END LOOP;

    IF NO_TXN_FLAG THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, G_NO_TXN_MSG || L_DAYS);
        FND_FILE.NEW_LINE(FND_FILE.LOG);
        DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME, '*' || G_NO_TXN_MSG || L_DAYS);
    END IF;

    END IF;

--Commit the changes
  COMMIT;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO INITIATE_NOTIF;
     retcode := 2;
     errbuf := 'Error';
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE, p_count   => l_msg_count, p_data    => l_msg_data );
     IF l_msg_count > 1 THEN
            FOR I IN 1..l_msg_count LOOP
               l_msg_data := SUBSTR((l_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
            END LOOP;
     END IF;
     FND_FILE.PUT_LINE(FND_FILE.LOG,G_ERR_AUTO_NTF_MSG);
     FND_FILE.NEW_LINE(FND_FILE.LOG);
     FND_FILE.PUT_LINE(FND_FILE.LOG,substr(('Error Message : ' || l_msg_data),1,4000));
     FND_FILE.NEW_LINE(FND_FILE.LOG);

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO INITIATE_NOTIF;
     retcode := 2;
     errbuf := 'Error';
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE, p_count   => l_msg_count, p_data    => l_msg_data );
     IF l_msg_count > 1 THEN
            FOR I IN 1..l_msg_count LOOP
               l_msg_data := SUBSTR((l_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
            END LOOP;
     END IF;
     FND_FILE.PUT_LINE(FND_FILE.LOG, G_ERR_AUTO_NTF_MSG);
     FND_FILE.NEW_LINE(FND_FILE.LOG);
     FND_FILE.PUT_LINE(FND_FILE.LOG,substr(('Error Message : ' || l_msg_data),1,4000));
     FND_FILE.NEW_LINE(FND_FILE.LOG);
WHEN OTHERS THEN
     ROLLBACK TO INITIATE_NOTIF;
     retcode := 2;
     errbuf := 'Error';
     fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
     fnd_message.set_token('ROUTINE', l_full_name);
     fnd_message.set_token('ERRNO', sqlcode);
     fnd_message.set_token('REASON', sqlerrm);
     FND_MSG_PUB.add;

     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE, p_count   => l_msg_count, p_data    => l_msg_data );
     IF l_msg_count > 1 THEN
            FOR I IN 1..l_msg_count LOOP
               l_msg_data := SUBSTR((l_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
            END LOOP;
     END IF;
     FND_FILE.PUT_LINE(FND_FILE.LOG, G_ERR_AUTO_NTF_MSG);
     FND_FILE.NEW_LINE(FND_FILE.LOG);
     FND_FILE.PUT_LINE(FND_FILE.LOG,substr(('Error Message : ' || l_msg_data),1,4000));
     FND_FILE.NEW_LINE(FND_FILE.LOG);

END Initiate_Notification_Process;

---------------------------------------------------------------------
-- PROCEDURE
--    Populate_ExecutionProcess
--
-- PURPOSE
--    Populate Execution Process as soon as the transaction is created
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------
PROCEDURE populate_ExecutionProcess(
    p_api_version_number      IN   NUMBER,
    p_init_msg_list           IN   VARCHAR2    := FND_API.G_FALSE,
    p_commit                  IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level        IN   NUMBER      := FND_API.g_valid_level_full,
    x_return_status           OUT  NOCOPY  VARCHAR2,
    x_msg_count               OUT  NOCOPY  NUMBER,
    x_msg_data                OUT  NOCOPY  VARCHAR2,
    p_org_id                  IN NUMBER,
    p_txn_hdr_id              IN NUMBER,
    p_txn_number              IN VARCHAR2,
    p_vendor_id               IN NUMBER,
    p_vendor_site_id	      IN NUMBER
)
IS
   l_api_name               CONSTANT VARCHAR2(30) := 'populate_ExecutionProcess';
   l_api_version_number     CONSTANT NUMBER   := 1.0;

   l_supp_trade_profile_id  NUMBER;
   l_exe_process_cnt        NUMBER := 0;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT POPULATE_EXECUTIONPROCESS;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
      p_api_version_number,
      l_api_name,
      G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   L_SUPP_TRADE_PROFILE_ID := GET_PROCESS_SETUP_ID(P_VENDOR_ID, P_VENDOR_SITE_ID, P_ORG_ID);

	--Process Setup exist
   --Insert records into DPP_EXECUTION_PROCESSES based on the Execution Process setup either at STP or System Parameters
   InsertExecProcesses(
          p_txn_hdr_id  =>  p_txn_hdr_id,
          p_org_id      => p_org_id,
          p_supp_trd_prfl_id => l_supp_trade_profile_id,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data,
          x_return_status    => x_return_status );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO POPULATE_EXECUTIONPROCESS;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_FILE.PUT_LINE(FND_FILE.LOG,G_NO_SETUP_MSG);
       FND_FILE.NEW_LINE(FND_FILE.LOG);
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
       );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO POPULATE_EXECUTIONPROCESS;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Unexpected error occured: ' || SQLERRM);
       FND_FILE.NEW_LINE(FND_FILE.LOG);
        -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count   => x_msg_count,
       p_data    => x_msg_data
       );
    WHEN OTHERS THEN
        ROLLBACK TO POPULATE_EXECUTIONPROCESS;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Unexpected error occured: ' || SQLERRM);
       FND_FILE.NEW_LINE(FND_FILE.LOG);
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
   );

END Populate_ExecutionProcess;

---------------------------------------------------------------------
-- PROCEDURE
--    InsertExecProcesses
--
-- PURPOSE
--    Insert Execution Process as soon as the transaction is created
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------
PROCEDURE InsertExecProcesses(
    p_txn_hdr_id              IN NUMBER,
    p_org_id                  IN NUMBER,
    p_supp_trd_prfl_id        IN NUMBER,
    x_msg_count               OUT  NOCOPY  NUMBER,
    x_msg_data                OUT  NOCOPY  VARCHAR2,
    x_return_status           OUT  NOCOPY  VARCHAR2
)
IS
   l_api_name               CONSTANT VARCHAR2(30) := 'InsertExecProcesses';
   l_api_version_number     CONSTANT NUMBER   := 1.0;

   l_user_id 	            NUMBER := FND_GLOBAL.USER_ID;
   l_login_id 		    NUMBER := FND_GLOBAL.LOGIN_ID;

   l_exe_process_cnt        NUMBER := 0;

--Cursor to get the count of execution processes for the transaction
CURSOR get_exec_processes_cnt(p_txn_hdr_id NUMBER)
IS
   SELECT COUNT(1)
   FROM DPP_EXECUTION_PROCESSES
   WHERE transaction_header_id = p_txn_hdr_id;

--Cursor to retrieve the process codes from look up
CURSOR get_process_codes_csr (p_supp_trd_prf_id NUMBER)
  IS
    SELECT dppl.lookup_code
      FROM dpp_lookups dppl,
           OZF_PROCESS_SETUP_ALL opsa
     WHERE dppl.lookup_type = 'DPP_EXECUTION_PROCESSES'
       AND dppl.tag is not null
       AND nvl(opsa.supp_trade_profile_id,0) = nvl(p_supp_trd_prf_id,0)
       AND opsa.enabled_flag = 'Y'
       AND opsa.org_id = p_org_id
       AND dppl.lookup_code = opsa.process_code;

BEGIN
    SAVEPOINT InsertExecProcesses;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   BEGIN	--Check if the transaction exists in DPP_EXECUTION_PROCESSES table
     OPEN get_exec_processes_cnt(p_txn_hdr_id);
       FETCH get_exec_processes_cnt INTO l_exe_process_cnt;
     CLOSE get_exec_processes_cnt;
   EXCEPTION
     WHEN OTHERS THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Exception while checking if the transaction exists in DPP_EXECUTION_PROCESSES table: '||SQLERRM);
       FND_FILE.NEW_LINE(FND_FILE.LOG);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   IF l_exe_process_cnt > 0 THEN
     BEGIN
       DELETE FROM DPP_EXECUTION_PROCESSES
         WHERE transaction_header_id = p_txn_hdr_id;
     EXCEPTION
       WHEN OTHERS THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Exception while deleting the records from DPP_EXECUTION_PROCESSES table: ' || SQLERRM);
         FND_FILE.NEW_LINE(FND_FILE.LOG);
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END;
   END IF;

   FOR get_process_codes_rec IN get_process_codes_csr(p_supp_trd_prfl_id)
   LOOP
     BEGIN
       --Insert the Process codes into the DPP_EXECUTION_PROCESSES table
       INSERT INTO DPP_EXECUTION_PROCESSES (process_code,
                                              transaction_header_id,
                                              created_by,
                                              creation_date,
                                              last_updated_by,
                                              last_update_date,
                                              last_update_login
       )
       VALUES (get_process_codes_rec.lookup_code,
                  p_txn_hdr_id,
                  l_user_id,
                  sysdate,
                  l_user_id,
                  sysdate,
                  l_login_id
       );
     EXCEPTION
       WHEN OTHERS THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Exception while inserting into DPP_EXECUTION_PROCESSES: ' || SQLERRM);
         FND_FILE.NEW_LINE(FND_FILE.LOG);
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END;
    END LOOP;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO InsertExecProcesses;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_FILE.PUT_LINE(FND_FILE.LOG,G_NO_SETUP_MSG);
       FND_FILE.NEW_LINE(FND_FILE.LOG);
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
       );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO InsertExecProcesses;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Unexpected error occured: ' || SQLERRM);
       FND_FILE.NEW_LINE(FND_FILE.LOG);
        -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count   => x_msg_count,
       p_data    => x_msg_data
       );
    WHEN OTHERS THEN
        ROLLBACK TO InsertExecProcesses;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Unexpected error occured: ' || SQLERRM);
       FND_FILE.NEW_LINE(FND_FILE.LOG);
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
   );

END InsertExecProcesses;


---------------------------------------------------------------------
-- PROCEDURE
--    Change_Status
--
-- PURPOSE
--    Future dated Transactions will be moved from Active to Pending Adjustment
--  status on the effective date. It raised business events for populating the
--  inventory details for all those transactions. Further, Work Flow notification
--  will be sent to the creators of the transactions.
--
-- PARAMETERS
--     p_in_org_id - operating unit
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Change_Status (
    errbuf               OUT NOCOPY   VARCHAR2
   ,retcode              OUT NOCOPY   VARCHAR2
   ,p_in_org_id          IN           NUMBER )
IS
--Declare the variables
l_api_name                CONSTANT VARCHAR2(30) := 'Change_Status';
l_api_version             CONSTANT NUMBER := 1.0;
l_full_name               CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

l_user_id                  NUMBER := FND_GLOBAL.USER_ID;
l_login_id                 NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
l_request_id               NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
l_program_application_id   NUMBER := FND_GLOBAL.PROG_APPL_ID;
l_program_id               NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;

l_return_status            VARCHAR2(10);
l_msg_data                 VARCHAR2(4000);
l_msg_count                NUMBER;

l_org_id                 NUMBER := p_in_org_id;
l_txn_hdr_rec            DPP_BUSINESSEVENTS_PVT.dpp_txn_hdr_rec_type;
l_txn_line_id            DPP_BUSINESSEVENTS_PVT.dpp_txn_line_tbl_type;

l_approval_rec           DPP_APPROVAL_PVT.approval_rec_type;
l_approversOut           DPP_APPROVAL_PVT.approversTable;
l_final_approval_flag    VARCHAR2(1) := 'N';

l_transaction_header_id  NUMBER;
l_transaction_number     VARCHAR2(40);
l_ref_document_number    VARCHAR2(40);
l_skip_adjustment_flag   VARCHAR2(1) := 'N';
l_skip_approval_flag     VARCHAR2(1) := 'N';

l_eligible_txn_exist     VARCHAR2(1) := 'N';

CURSOR eligible_txn_cur (p_org_id IN NUMBER)
IS
SELECT transaction_header_id,
       transaction_number,
       ref_document_number,
       skip_adjustment_flag,
       skip_approval_flag
FROM dpp_transaction_headers_all dtha, ozf_supp_trd_prfls_all ostpa
WHERE dtha.vendor_id = ostpa.supplier_id
AND dtha.vendor_site_id = ostpa.supplier_site_id
AND dtha.org_id = ostpa.org_id
AND dtha.transaction_status = 'ACTIVE'
AND trunc(dtha.effective_start_date) <= trunc(sysdate)
AND dtha.org_id = p_org_id;

BEGIN
   SAVEPOINT Change_Status;

   -- Initialize message list
   FND_MSG_PUB.initialize;


   DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Public API: ' || l_api_name || ' started at: ' || to_char(sysdate,'dd-mon-yyyy hh24:mi:ss'));

   -- Initialize API return status to sucess
   errbuf := 'Success';
   retcode := 0;

   FOR eligible_txn_rec IN eligible_txn_cur(l_org_id) LOOP

      l_transaction_header_id := eligible_txn_rec.transaction_header_id;
      l_transaction_number := eligible_txn_rec.transaction_number;
      l_ref_document_number := eligible_txn_rec.ref_document_number;
      l_skip_adjustment_flag := eligible_txn_rec.skip_adjustment_flag;
      l_skip_approval_flag := eligible_txn_rec.skip_approval_flag;

      l_approval_rec.object_type := 'PRICE PROTECTION';
      l_approval_rec.object_id := l_transaction_header_id;
      l_approval_rec.action_code := 'SUBMIT';
      l_approval_rec.status_code := 'SUBMITTED_FOR_APPROVAL';

      IF l_skip_adjustment_flag = 'Y' AND l_skip_approval_flag = 'N' THEN
        BEGIN
          DPP_APPROVAL_PVT.Get_AllApprovers(
              p_api_version         => 1.0
            , p_init_msg_list       => FND_API.G_FALSE
            , p_validation_level    => FND_API.G_VALID_LEVEL_FULL
            , x_return_status       => l_return_status
            , x_msg_data            => l_msg_data
            , x_msg_count           => l_msg_count
            , p_approval_rec        => l_approval_rec
            , p_approversOut        => l_approversOut
            );

          IF l_approversOut.COUNT = 0   THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          UPDATE dpp_transaction_headers_all
          SET transaction_status = 'PENDING_APPROVAL',
            object_version_number = object_version_number +1,
            last_updated_by = l_user_id,
            last_update_date = sysdate,
            last_update_login = l_login_id,
            request_id = l_request_id,
            program_application_id = l_program_application_id,
            program_id = l_program_id,
            program_update_date = sysdate
          WHERE transaction_header_id = l_transaction_header_id;

          DPP_APPROVAL_PVT.Process_User_Action (
              p_api_version            => 1.0
            , p_init_msg_list          => FND_API.G_FALSE
            , p_commit                 => FND_API.G_FALSE
            , p_validation_level       => FND_API.G_VALID_LEVEL_FULL
            , x_return_status          => l_return_status
            , x_msg_data               => l_msg_data
            , x_msg_count              => l_msg_count
            , p_approval_rec           => l_approval_rec
            , p_approver_id            => null
            , x_final_approval_flag    => l_final_approval_flag
          );

          IF l_return_status = Fnd_Api.g_ret_sts_error OR l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
             fnd_file.put_line(fnd_file.log, l_msg_data);
             fnd_file.new_line(fnd_file.log);
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

        EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
            l_msg_data := fnd_message.get_string('DPP','DPP_AME_NO_APP');
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Transaction Number : ' || l_transaction_number || ' Ref. Document Number : ' || l_ref_document_number);
            FND_FILE.NEW_LINE(FND_FILE.LOG);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error Message : ' || l_msg_data);
	         FND_FILE.NEW_LINE(FND_FILE.LOG);
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Transaction Number : ' || l_transaction_number || ' Ref. Document Number : ' || l_ref_document_number);
            FND_FILE.NEW_LINE(FND_FILE.LOG);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error Message : ' || l_msg_data);
	         FND_FILE.NEW_LINE(FND_FILE.LOG);
          WHEN OTHERS THEN
            fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
            fnd_message.set_token('ROUTINE', l_full_name);
            fnd_message.set_token('ERRNO', sqlcode);
            fnd_message.set_token('REASON', sqlerrm);
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;

      ELSIF l_skip_adjustment_flag = 'Y' AND l_skip_approval_flag = 'Y' THEN
        BEGIN
          UPDATE dpp_transaction_headers_all
          SET transaction_status = 'APPROVED',
              object_version_number = object_version_number +1,
              last_updated_by = l_user_id,
              last_update_date = sysdate,
              last_update_login = l_login_id,
              request_id = l_request_id,
              program_application_id = l_program_application_id,
              program_id = l_program_id,
              program_update_date = sysdate
          WHERE transaction_header_id = l_transaction_header_id;

          --Call the Initiate execution process
          Initiate_ExecutionProcess(errbuf,
                                  retcode,
                                  l_org_id,
                                  l_transaction_number
                                  );

          IF G_DEBUG THEN
            fnd_file.put_line(fnd_file.log, ' Initiate_ExecutionProcess. retcode: ' || retcode || ' errbuf: ' || errbuf);
          END IF;

          IF retcode <> 0 THEN
            FND_FILE.PUT_LINE(fnd_file.log, 'Initiate_ExecutionProcess did not complete successfully for' );
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Transaction Number : ' || l_transaction_number || ' Ref. Document Number : ' || l_ref_document_number);
            FND_FILE.NEW_LINE(FND_FILE.LOG);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error Message : ' || errbuf);
	    FND_FILE.NEW_LINE(FND_FILE.LOG);
          END IF;

        EXCEPTION
          WHEN OTHERS THEN
            fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
            fnd_message.set_token('ROUTINE', l_full_name);
            fnd_message.set_token('ERRNO', sqlcode);
            fnd_message.set_token('REASON', sqlerrm);
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;

      ELSE

		  IF l_eligible_txn_exist = 'N' THEN
			l_eligible_txn_exist := 'Y';
        END IF;

        BEGIN
          UPDATE dpp_transaction_headers_all
          SET transaction_status = 'PENDING_ADJUSTMENT',
              object_version_number = object_version_number +1,
              last_updated_by = l_user_id,
              last_update_date = sysdate,
              last_update_login = l_login_id,
              request_id = l_request_id,
              program_application_id = l_program_application_id,
              program_id = l_program_id,
              program_update_date = sysdate
          WHERE transaction_header_id = l_transaction_header_id;
        EXCEPTION
          WHEN OTHERS THEN
            fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
            fnd_message.set_token('ROUTINE', l_full_name);
            fnd_message.set_token('ERRNO', sqlcode);
            fnd_message.set_token('REASON', sqlerrm);
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;

      END IF;

      Update_HeaderLog(
                p_api_version_number => 1.0
            ,   p_init_msg_list      => FND_API.G_FALSE
            ,   p_commit             => FND_API.G_FALSE
            ,   p_validation_level   => FND_API.G_VALID_LEVEL_FULL
            ,   x_return_status      => l_return_status
            ,   x_msg_count          => l_msg_count
            ,   x_msg_data           => l_msg_data
            ,   p_transaction_header_id => l_transaction_header_id
      ) ;

      IF G_DEBUG THEN
        fnd_file.put_line(fnd_file.log, ' Update_HeaderLog. Return Status: ' || l_return_status || ' Error Msg: ' || l_msg_data);
      END IF;

      IF l_return_status = Fnd_Api.g_ret_sts_error THEN
        RAISE Fnd_Api.g_exc_error;
      ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
        RAISE Fnd_Api.g_exc_unexpected_error;
      END IF;

      EXECUTE_PROCESS(L_API_VERSION, FND_API.G_FALSE, FND_API.G_FALSE, FND_API.G_VALID_LEVEL_FULL, L_RETURN_STATUS, L_MSG_COUNT, L_MSG_DATA,
	           l_transaction_header_id, l_transaction_number, 'POPINVDTLS');

   END LOOP;

   IF l_eligible_txn_exist = 'Y' THEN

      --Invoke the API to raise the business event
      DPP_BUSINESSEVENTS_PVT.RAISE_EFFECTIVE_DATE_EVENT( p_api_version          =>    1.0
                                                        ,p_init_msg_list        =>    FND_API.G_FALSE
							,p_commit               =>    FND_API.G_FALSE
							,p_validation_level     =>    FND_API.G_VALID_LEVEL_FULL
							,x_return_status        =>    l_return_status
							,x_msg_data             =>    l_msg_data
							,x_msg_count            =>    l_msg_count
							,p_program_id           =>    l_request_id
							);

      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
	     FND_FILE.PUT_LINE(FND_FILE.LOG,'Invoked API to send WF Notifications to the '
	           || 'Creator on the effective date of the Price Protection Transaction');
	     FND_FILE.NEW_LINE(FND_FILE.LOG);
	   ELSE
	     FND_FILE.PUT_LINE(FND_FILE.LOG,'Error while invoking API that sends WF Notifications to the '
	           ||'Creator on the effective date of the Price Protection Transaction');
	     FND_FILE.NEW_LINE(FND_FILE.LOG);
	     FND_FILE.PUT_LINE(FND_FILE.LOG,substr(('Error Message : '||l_msg_data),1,4000));
	     FND_FILE.NEW_LINE(FND_FILE.LOG);
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

  ELSE
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'No Price protection transactions effective today.');
     FND_FILE.NEW_LINE(FND_FILE.LOG);
     DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'No Price protection transactions effective today.');
  END IF;

--Commit the changes
  COMMIT;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Change_Status;
     retcode := 2;
     errbuf := 'Error';
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
        p_encoded => FND_API.G_FALSE,
        p_count   => l_msg_count,
        p_data    => l_msg_data
     );
     IF l_msg_count > 1 THEN
            FOR I IN 1..l_msg_count LOOP
               l_msg_data := SUBSTR((l_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
            END LOOP;
     END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,substr(('Error Message : ' || l_msg_data),1,4000));
    FND_FILE.NEW_LINE(FND_FILE.LOG);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Change_Status;
     retcode := 2;
     errbuf := 'Error';
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
        p_encoded => FND_API.G_FALSE,
        p_count => l_msg_count,
        p_data  => l_msg_data
     );
     IF l_msg_count > 1 THEN
            FOR I IN 1..l_msg_count LOOP
               l_msg_data := SUBSTR((l_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
            END LOOP;
     END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,substr(('Error Message : ' || l_msg_data),1,4000));
    FND_FILE.NEW_LINE(FND_FILE.LOG);
  WHEN OTHERS THEN
     ROLLBACK TO Change_Status;
     retcode := 2;
     errbuf := 'Error';
     fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
     fnd_message.set_token('ROUTINE', l_full_name);
     fnd_message.set_token('ERRNO', sqlcode);
     fnd_message.set_token('REASON', sqlerrm);
     FND_MSG_PUB.add;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
        p_encoded => FND_API.G_FALSE,
        p_count => l_msg_count,
        p_data  => l_msg_data
     );
     IF l_msg_count > 1 THEN
            FOR I IN 1..l_msg_count LOOP
               l_msg_data := SUBSTR((l_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
            END LOOP;
     END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,substr(('Error Message : ' || l_msg_data),1,4000));
    FND_FILE.NEW_LINE(FND_FILE.LOG);

END Change_Status;

---------------------------------------------------------------------
-- PROCEDURE
--    approve_transaction
--
-- PURPOSE
--    This procedure will directly update the transaction status to
-- APPROVED without going through the AME approval and initiate the
-- automated execution processes
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------
PROCEDURE approve_transaction(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2    := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.g_valid_level_full,
    x_return_status              OUT  NOCOPY  VARCHAR2,
    x_msg_count                  OUT  NOCOPY  NUMBER,
    x_msg_data                   OUT  NOCOPY  VARCHAR2,
    p_txn_hdr_id                 IN   NUMBER
)
IS
--Declare the variables
l_api_name                CONSTANT VARCHAR2(30) := 'approve_transaction';
l_api_version_number      CONSTANT NUMBER := 1.0;
l_full_name               CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

l_user_id                  NUMBER := FND_GLOBAL.USER_ID;
l_login_id                 NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
l_request_id               NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
l_program_application_id   NUMBER := FND_GLOBAL.PROG_APPL_ID;
l_program_id               NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;

l_init_msg_list            VARCHAR2(10) := p_init_msg_list;
l_commit                   VARCHAR2(10) := p_commit;
l_validation_level         NUMBER := p_validation_level;

l_return_status            VARCHAR2(10);
l_msg_data                 VARCHAR2(4000);
l_msg_count                NUMBER;

errbuff                    VARCHAR2(4000);
retcode                    VARCHAR2(10);

l_txn_hdr_id               NUMBER := p_txn_hdr_id;
l_org_id                   NUMBER;
l_txn_number               VARCHAR2(40);

CURSOR txn_dtls_cur (p_txn_hdr_id IN NUMBER)
IS
  SELECT transaction_number, org_id
  FROM dpp_transaction_headers_all
  WHERE transaction_header_id = p_txn_hdr_id;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT APPROVE_TRANSACTION;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
      p_api_version_number,
      l_api_name,
      G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   update_status(
                p_api_version_number => l_api_version_number
            ,   p_init_msg_list      => l_init_msg_list
            ,   p_commit             => l_commit
            ,   p_validation_level   => l_validation_level
            ,   x_return_status      => l_return_status
            ,   x_msg_count          => l_msg_count
            ,   x_msg_data           => l_msg_data
            ,   p_txn_hdr_id         => l_txn_hdr_id
            ,   p_to_status          => 'APPROVED'
      ) ;

   IF G_DEBUG THEN
        fnd_file.put_line(fnd_file.log, ' Update_Status. Return Status: ' || l_return_status || ' Error Msg: ' || l_msg_data);
   END IF;

   IF l_return_status = Fnd_Api.g_ret_sts_error THEN
        RAISE Fnd_Api.g_exc_error;
   ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
        RAISE Fnd_Api.g_exc_unexpected_error;
   END IF;

   BEGIN
    OPEN txn_dtls_cur(l_txn_hdr_id);
    FETCH txn_dtls_cur INTO l_txn_number, l_org_id;
    CLOSE txn_dtls_cur;
   EXCEPTION
    WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   --Call the Initiate execution process
   Initiate_ExecutionProcess(errbuff,
                             retcode,
                             l_org_id,
                             l_txn_number
                             );

   IF G_DEBUG THEN
      fnd_file.put_line(fnd_file.log, ' Initiate_ExecutionProcess. retcode: ' || retcode || ' errbuff: ' || errbuff);
   END IF;

   IF retcode <> 0 THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO APPROVE_TRANSACTION;
       x_return_status := FND_API.G_RET_STS_ERROR;
       --FND_FILE.PUT_LINE(FND_FILE.LOG,'Supplier Trade Profile or Process Setup not available');
       --FND_FILE.NEW_LINE(FND_FILE.LOG);
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
       );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO APPROVE_TRANSACTION;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Unexpected error occured: ' || SQLERRM);
       FND_FILE.NEW_LINE(FND_FILE.LOG);
        -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count   => x_msg_count,
       p_data    => x_msg_data
       );
    WHEN OTHERS THEN
        ROLLBACK TO APPROVE_TRANSACTION;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Unexpected error occured: ' || SQLERRM);
       FND_FILE.NEW_LINE(FND_FILE.LOG);
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
   );

END approve_transaction;

---------------------------------------------------------------------
-- PROCEDURE
--    update_status
--
-- PURPOSE
--    This procedure will update the transaction status of a particular
-- Price Protection transaction.
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------
PROCEDURE update_status(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2    := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.g_valid_level_full,
    x_return_status              OUT  NOCOPY  VARCHAR2,
    x_msg_count                  OUT  NOCOPY  NUMBER,
    x_msg_data                   OUT  NOCOPY  VARCHAR2,
    p_txn_hdr_id                 IN   NUMBER,
    p_to_status                  IN   VARCHAR2
)
IS
--Declare the variables
l_api_name                CONSTANT VARCHAR2(30) := 'update_status';
l_api_version_number      CONSTANT NUMBER := 1.0;
l_full_name               CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

l_user_id                  NUMBER := FND_GLOBAL.USER_ID;
l_login_id                 NUMBER := FND_GLOBAL.LOGIN_ID;

l_return_status            VARCHAR2(10);
l_msg_data                 VARCHAR2(4000);
l_msg_count                NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT UPDATE_STATUS;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
      p_api_version_number,
      l_api_name,
      G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   UPDATE dpp_transaction_headers_all
   SET transaction_status = p_to_status,
       object_version_number = object_version_number +1,
       last_updated_by = l_user_id,
       last_update_date = sysdate,
       last_update_login = l_login_id
   WHERE transaction_header_id = p_txn_hdr_id;

   Update_HeaderLog(
                p_api_version_number => l_api_version_number
            ,   p_init_msg_list      => p_init_msg_list
            ,   p_commit             => p_commit
            ,   p_validation_level   => p_validation_level
            ,   x_return_status      => l_return_status
            ,   x_msg_count          => l_msg_count
            ,   x_msg_data           => l_msg_data
            ,   p_transaction_header_id => p_txn_hdr_id
      ) ;

   IF G_DEBUG THEN
        fnd_file.put_line(fnd_file.log, ' Update_HeaderLog. Return Status: ' || l_return_status || ' Error Msg: ' || l_msg_data);
   END IF;

   IF l_return_status = Fnd_Api.g_ret_sts_error THEN
        RAISE Fnd_Api.g_exc_error;
   ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
        RAISE Fnd_Api.g_exc_unexpected_error;
   END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO UPDATE_STATUS;
       x_return_status := FND_API.G_RET_STS_ERROR;
       --FND_FILE.PUT_LINE(FND_FILE.LOG,'Supplier Trade Profile or Process Setup not available');
       --FND_FILE.NEW_LINE(FND_FILE.LOG);
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
       );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO UPDATE_STATUS;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Unexpected error occured: ' || SQLERRM);
       FND_FILE.NEW_LINE(FND_FILE.LOG);
        -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count   => x_msg_count,
       p_data    => x_msg_data
       );
    WHEN OTHERS THEN
        ROLLBACK TO UPDATE_STATUS;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Unexpected error occured: ' || SQLERRM);
       FND_FILE.NEW_LINE(FND_FILE.LOG);
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
   );

END update_status;

---------------------------------------------------------------------
-- PROCEDURE
--    Update_HeaderLog
--
-- PURPOSE
--    This procedure will update the transaction header log of a particular
-- Price Protection transaction.
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------

PROCEDURE Update_HeaderLog(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2    := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.g_valid_level_full,
    x_return_status              OUT  NOCOPY  VARCHAR2,
    x_msg_count                  OUT  NOCOPY  NUMBER,
    x_msg_data                   OUT  NOCOPY  VARCHAR2,
    p_transaction_header_id      IN   NUMBER
)
IS
--Declare the variables
l_api_name                CONSTANT VARCHAR2(30) := 'Update_HeaderLog';
l_api_version_number      CONSTANT NUMBER := 1.0;
l_full_name               CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

l_user_id                  NUMBER := FND_GLOBAL.USER_ID;
l_login_id                 NUMBER := FND_GLOBAL.LOGIN_ID;

l_return_status            VARCHAR2(10);
l_msg_data                 VARCHAR2(4000);
l_msg_count                NUMBER;

l_log_enabled              VARCHAR2(20);

l_txn_hdr_hist_rec         dpp_log_pvt.dpp_cst_hdr_rec_type;
l_txn_hdr_rec              dpp_log_pvt.dpp_cst_hdr_rec_type;

--Cursor to fetch header information
CURSOR fetch_header_cur IS
SELECT *
FROM dpp_transaction_headers_all dtha
WHERE dtha.transaction_header_id = p_transaction_header_id;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT UPDATE_HEADERLOG;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
      p_api_version_number,
      l_api_name,
      G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF G_DEBUG THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'      Begin Update HeaderLog');
   END IF;

   SELECT fnd_profile.VALUE('DPP_AUDIT_ENABLED')
   INTO l_log_enabled
   FROM dual;

   IF G_DEBUG THEN
      fnd_file.put_line(fnd_file.log,   'Audit Enabled ' || l_log_enabled );
   END IF;

   --Update Header history log
   IF l_log_enabled = 'Y' THEN
     FOR fetch_header_rec IN fetch_header_cur
        LOOP
            --Form header record type to populate header log table
            l_txn_hdr_hist_rec.log_mode                  := 'U';
            l_txn_hdr_hist_rec.transaction_header_id     := fetch_header_rec.transaction_header_id;
            l_txn_hdr_hist_rec.ref_document_number       := fetch_header_rec.ref_document_number;
            l_txn_hdr_hist_rec.vendor_id                 := fetch_header_rec.vendor_id;
            l_txn_hdr_hist_rec.vendor_site_id            := fetch_header_rec.vendor_site_id;
            l_txn_hdr_hist_rec.vendor_contact_id         := fetch_header_rec.vendor_contact_id;
            l_txn_hdr_hist_rec.contact_email_address     := fetch_header_rec.contact_email_address;
            l_txn_hdr_hist_rec.contact_phone             := fetch_header_rec.contact_phone;
            l_txn_hdr_hist_rec.effective_start_date      := TRUNC(fetch_header_rec.effective_start_date);
            l_txn_hdr_hist_rec.days_covered              := fetch_header_rec.days_covered;
            l_txn_hdr_hist_rec.trx_currency              := fetch_header_rec.trx_currency;
            l_txn_hdr_hist_rec.transaction_status        := fetch_header_rec.transaction_status;
            l_txn_hdr_hist_rec.org_id                    := fetch_header_rec.org_id;
            l_txn_hdr_hist_rec.creation_date             := fetch_header_rec.creation_date;
            l_txn_hdr_hist_rec.created_by                := fetch_header_rec.created_by;
            l_txn_hdr_hist_rec.last_update_date          := fetch_header_rec.last_update_date;
            l_txn_hdr_hist_rec.last_updated_by           := fetch_header_rec.last_updated_by;
            l_txn_hdr_hist_rec.last_update_login         := fetch_header_rec.last_update_login;
            l_txn_hdr_hist_rec.last_refreshed_by         := fetch_header_rec.last_refreshed_by;
            l_txn_hdr_hist_rec.last_refreshed_date       := fetch_header_rec.last_refreshed_date;
            l_txn_hdr_hist_rec.attribute_category        := fetch_header_rec.attribute_category;
            l_txn_hdr_hist_rec.attribute1                := fetch_header_rec.attribute1;
            l_txn_hdr_hist_rec.attribute2                := fetch_header_rec.attribute2;
            l_txn_hdr_hist_rec.attribute3                := fetch_header_rec.attribute3;
            l_txn_hdr_hist_rec.attribute4                := fetch_header_rec.attribute4;
            l_txn_hdr_hist_rec.attribute5                := fetch_header_rec.attribute5;
            l_txn_hdr_hist_rec.attribute6                := fetch_header_rec.attribute6;
            l_txn_hdr_hist_rec.attribute7                := fetch_header_rec.attribute7;
            l_txn_hdr_hist_rec.attribute8                := fetch_header_rec.attribute8;
            l_txn_hdr_hist_rec.attribute9                := fetch_header_rec.attribute9;
            l_txn_hdr_hist_rec.attribute10               := fetch_header_rec.attribute10;
            l_txn_hdr_hist_rec.attribute11               := fetch_header_rec.attribute11;
            l_txn_hdr_hist_rec.attribute12               := fetch_header_rec.attribute12;
            l_txn_hdr_hist_rec.attribute13               := fetch_header_rec.attribute13;
            l_txn_hdr_hist_rec.attribute14               := fetch_header_rec.attribute14;
            l_txn_hdr_hist_rec.attribute15               := fetch_header_rec.attribute15;
            l_txn_hdr_hist_rec.attribute16               := fetch_header_rec.attribute16;
            l_txn_hdr_hist_rec.attribute17               := fetch_header_rec.attribute17;
            l_txn_hdr_hist_rec.attribute18               := fetch_header_rec.attribute18;
            l_txn_hdr_hist_rec.attribute19               := fetch_header_rec.attribute19;
            l_txn_hdr_hist_rec.attribute20               := fetch_header_rec.attribute20;
            l_txn_hdr_hist_rec.attribute21               := fetch_header_rec.attribute21;
            l_txn_hdr_hist_rec.attribute22               := fetch_header_rec.attribute22;
            l_txn_hdr_hist_rec.attribute23               := fetch_header_rec.attribute23;
            l_txn_hdr_hist_rec.attribute24               := fetch_header_rec.attribute24;
            l_txn_hdr_hist_rec.attribute25               := fetch_header_rec.attribute25;
            l_txn_hdr_hist_rec.attribute26               := fetch_header_rec.attribute26;
            l_txn_hdr_hist_rec.attribute27               := fetch_header_rec.attribute27;
            l_txn_hdr_hist_rec.attribute28               := fetch_header_rec.attribute28;
            l_txn_hdr_hist_rec.attribute29               := fetch_header_rec.attribute29;
            l_txn_hdr_hist_rec.attribute30               := fetch_header_rec.attribute30;

            dpp_log_pvt.insert_headerlog(
                p_api_version       => l_api_version_number
               ,p_init_msg_list     => p_init_msg_list
               ,p_commit            => p_commit
               ,p_validation_level  => p_validation_level
               ,x_return_status     => l_return_status
               ,x_msg_count         => x_msg_count
               ,x_msg_data          => x_msg_data
               ,p_txn_hdr_rec       => l_txn_hdr_hist_rec
            );

            IF G_DEBUG THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'      End Update HeaderLog');
            END IF;

            IF l_return_status =  Fnd_Api.g_ret_sts_error THEN
               RAISE Fnd_Api.g_exc_error;
            ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
               RAISE Fnd_Api.g_exc_unexpected_error;
           END IF;
      END LOOP;
   END IF;
EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
     x_return_status := Fnd_Api.g_ret_sts_error ;
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
   WHEN OTHERS THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
     IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
       fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
       fnd_message.set_token('ROUTINE', l_full_name);
       fnd_message.set_token('ERRNO', SQLCODE);
       fnd_message.set_token('REASON', sqlerrm);
     END IF;
     x_msg_data := fnd_message.get();
     FND_FILE.PUT_LINE(FND_FILE.LOG,'      ' || x_msg_data);
END Update_HeaderLog;

END DPP_EXECUTIONPROCESS_PVT;

/
