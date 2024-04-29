--------------------------------------------------------
--  DDL for Package Body DPP_BUSINESSEVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DPP_BUSINESSEVENTS_PVT" AS
/* $Header: dppvbevb.pls 120.39.12010000.13 2010/04/21 11:03:25 anbbalas ship $ */

-- Package name     : DPP_BUSINESSEVENTS_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Raise_Workflow_Event(
            x_return_status OUT NOCOPY VARCHAR2
            ,x_msg_count OUT NOCOPY NUMBER
            ,x_msg_data OUT NOCOPY  VARCHAR2
            ,p_txn_hdr_id IN NUMBER
            ,p_process_code IN VARCHAR2
            ,p_input_xml IN CLOB
            ,p_row_count IN NUMBER
            ,p_exe_dtl_id IN NUMBER
);

FUNCTION IS_NOTIF_EXECUTED(P_TXN_HDR_ID IN NUMBER, P_PROC_CODE IN VARCHAR2) RETURN BOOLEAN;

G_PKG_NAME                 CONSTANT VARCHAR2(30) := 'DPP_BUSINESSEVENTS_PVT';
G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
G_FILE_NAME                CONSTANT VARCHAR2(12) := 'dppvbevb.pls';


  FUNCTION IS_NOTIF_EXECUTED(P_TXN_HDR_ID IN NUMBER, P_PROC_CODE IN VARCHAR2)
  RETURN BOOLEAN IS
      L_EXECUTED BOOLEAN  DEFAULT FALSE;
      L_EXEC_COUNT NUMBER;
      BEGIN
          --Get the number of times the notification process was run without an error for this transaction, from the dpp execution details table.
      SELECT COUNT(1)
      INTO L_EXEC_COUNT
      FROM DPP_EXECUTION_DETAILS
      WHERE TRANSACTION_HEADER_ID=P_TXN_HDR_ID
      AND PROCESS_CODE=P_PROC_CODE
      AND EXECUTION_STATUS <> 'ERROR';

      --return true if the process was not run.
      IF L_EXEC_COUNT > 0
      THEN
          L_EXECUTED := TRUE;
      END IF;

      RETURN L_EXECUTED;
  END IS_NOTIF_EXECUTED;



  PROCEDURE SEND_CANCEL_NOTIFICATIONS(
    P_API_VERSION IN NUMBER,
    P_INIT_MSG_LIST IN VARCHAR2 := FND_API.G_FALSE,
    P_COMMIT IN VARCHAR2 := FND_API.G_FALSE,
    P_VALIDATION_LEVEL IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    X_RETURN_STATUS OUT NOCOPY VARCHAR2,
    X_MSG_COUNT OUT NOCOPY NUMBER,
    X_MSG_DATA OUT NOCOPY VARCHAR2,

    P_TXN_HDR_ID IN NUMBER
  )
  IS
    L_API_VERSION CONSTANT NUMBER := 1.0;
    L_API_NAME CONSTANT VARCHAR2(30) := 'SEND_CANCEL_NOTIFICATIONS';
    L_FULL_NAME CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;
	 l_module    CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_BUSINESSEVENTS_PVT.SEND_CANCEL_NOTIFICATIONS';

  BEGIN

    SAVEPOINT SEND_CANCEL_NOTIF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.COMPATIBLE_API_CALL (L_API_VERSION, P_API_VERSION, L_API_NAME, G_PKG_NAME)
    THEN
      DPP_UTILITY_PVT.DEBUG_MESSAGE(FND_LOG.LEVEL_STATEMENT, l_module, L_API_NAME || ' : Not a compatible API call.');
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    DPP_UTILITY_PVT.DEBUG_MESSAGE(FND_LOG.LEVEL_STATEMENT, l_module, L_API_NAME||': START');

    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.TO_BOOLEAN (P_INIT_MSG_LIST) THEN
      FND_MSG_PUB.INITIALIZE;
    END IF;

    -- Initialize API return status to sucess
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    IF IS_NOTIF_EXECUTED(P_TXN_HDR_ID, 'INPL')
    THEN
    --Call the RAISE_BUSINESS_EVENT procedure with CNCL_INPL as the process code.
      RAISE_BUSINESS_EVT_FOR_PROCESS (
        P_API_VERSION => L_API_VERSION, P_INIT_MSG_LIST => P_INIT_MSG_LIST, P_COMMIT => P_COMMIT, P_VALIDATION_LEVEL => P_VALIDATION_LEVEL,
        X_RETURN_STATUS => X_RETURN_STATUS, X_MSG_COUNT => X_MSG_COUNT, X_MSG_DATA => X_MSG_DATA,
        P_TXN_HDR_ID => P_TXN_HDR_ID, P_PROCESS_CODE => 'CNCL_INPL'
      );
    END IF;

    IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --If an outbound price list notification was sent earlier, then
    IF IS_NOTIF_EXECUTED(P_TXN_HDR_ID, 'OUTPL')
    THEN
    --Call the RAISE_BUSINESS_EVENT procedure with CNCL_OUTPL as the process code.
      RAISE_BUSINESS_EVT_FOR_PROCESS (
        P_API_VERSION => L_API_VERSION, P_INIT_MSG_LIST => P_INIT_MSG_LIST, P_COMMIT => P_COMMIT, P_VALIDATION_LEVEL => P_VALIDATION_LEVEL,
        X_RETURN_STATUS => X_RETURN_STATUS, X_MSG_COUNT => X_MSG_COUNT, X_MSG_DATA => X_MSG_DATA,
        P_TXN_HDR_ID => P_TXN_HDR_ID, P_PROCESS_CODE => 'CNCL_OUTPL'
      );
    END IF;

    IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --If a notification for offers and promotions was sent earlier, then
    IF IS_NOTIF_EXECUTED(P_TXN_HDR_ID, 'PROMO')
    THEN
    --Call the RAISE_BUSINESS_EVENT procedure with CNCL_PROMO as the process code.
      RAISE_BUSINESS_EVT_FOR_PROCESS (
        P_API_VERSION => L_API_VERSION, P_INIT_MSG_LIST => P_INIT_MSG_LIST, P_COMMIT => P_COMMIT, P_VALIDATION_LEVEL => P_VALIDATION_LEVEL,
        X_RETURN_STATUS => X_RETURN_STATUS, X_MSG_COUNT => X_MSG_COUNT, X_MSG_DATA => X_MSG_DATA,
        P_TXN_HDR_ID => P_TXN_HDR_ID, P_PROCESS_CODE => 'CNCL_PROMO'
      );
    END IF;

    IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --If  a notification for purchase orders was sent earlier, then
    IF IS_NOTIF_EXECUTED(P_TXN_HDR_ID, 'NTFYPO')
    THEN
    --Call the RAISE_BUSINESS_EVENT procedure with CNCL_NTFYPO as the process code.
      RAISE_BUSINESS_EVT_FOR_PROCESS (
        P_API_VERSION => L_API_VERSION, P_INIT_MSG_LIST => P_INIT_MSG_LIST, P_COMMIT => P_COMMIT, P_VALIDATION_LEVEL => P_VALIDATION_LEVEL,
        X_RETURN_STATUS => X_RETURN_STATUS, X_MSG_COUNT => X_MSG_COUNT, X_MSG_DATA => X_MSG_DATA,
        P_TXN_HDR_ID => P_TXN_HDR_ID, P_PROCESS_CODE => 'CNCL_NTFYPO'
      );
    END IF;

    IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO  SEND_CANCEL_NOTIF;
                X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
                -- Standard call to get message count and if count=1, get the message
                FND_MSG_PUB.COUNT_AND_GET (P_ENCODED => FND_API.G_FALSE, P_COUNT => X_MSG_COUNT, P_DATA  => X_MSG_DATA);
                IF X_MSG_COUNT > 1 THEN
                        FOR I IN 1..X_MSG_COUNT LOOP
                                X_MSG_DATA := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
                        END LOOP;
                END IF;
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO  SEND_CANCEL_NOTIF;
                X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
                -- Standard call to get message count and if count=1, get the message
                FND_MSG_PUB.COUNT_AND_GET (P_ENCODED => FND_API.G_FALSE, P_COUNT => X_MSG_COUNT, P_DATA  => X_MSG_DATA);
                IF X_MSG_COUNT > 1 THEN
                        FOR I IN 1..X_MSG_COUNT LOOP
                                X_MSG_DATA := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
                        END LOOP;
                END IF;
        WHEN OTHERS THEN
                ROLLBACK TO  SEND_CANCEL_NOTIF;
                X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;

    DPP_UTILITY_PVT.DEBUG_MESSAGE(FND_LOG.LEVEL_STATEMENT, l_module, L_API_NAME || ',FND_API.G_RET_STS_UNEXP_ERROR :: ' || SQLERRM);

    IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MESSAGE.SET_NAME('FND', 'SQL_PLSQL_ERROR');
        FND_MESSAGE.SET_TOKEN('ROUTINE', L_FULL_NAME);
        FND_MESSAGE.SET_TOKEN('ERRNO', SQLCODE);
        FND_MESSAGE.SET_TOKEN('REASON', SQLERRM);
    END IF;

                IF FND_MSG_PUB.CHECK_MSG_LEVEL ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
                THEN
                FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, L_API_NAME);
                END IF;
                -- Standard call to get message count and if count=1, get the message
                FND_MSG_PUB.COUNT_AND_GET (P_ENCODED => FND_API.G_FALSE, P_COUNT => X_MSG_COUNT, P_DATA  => X_MSG_DATA);
                IF X_MSG_COUNT > 1 THEN
                        FOR I IN 1..X_MSG_COUNT LOOP
                                X_MSG_DATA := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
                        END LOOP;
                END IF;

  END SEND_CANCEL_NOTIFICATIONS;


  PROCEDURE RAISE_BUSINESS_EVT_FOR_PROCESS (
      P_API_VERSION IN NUMBER,
      P_INIT_MSG_LIST IN VARCHAR2 := FND_API.G_FALSE,
      P_COMMIT IN VARCHAR2 := FND_API.G_FALSE,
      P_VALIDATION_LEVEL IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

      X_RETURN_STATUS OUT NOCOPY VARCHAR2,
      X_MSG_COUNT OUT NOCOPY NUMBER,
      X_MSG_DATA OUT NOCOPY VARCHAR2,

      P_TXN_HDR_ID IN NUMBER,
      P_PROCESS_CODE IN VARCHAR2
  )
  IS

    L_API_VERSION CONSTANT NUMBER := 1.0;
    L_API_NAME CONSTANT VARCHAR2(35) := 'RAISE_BUSINESS_EVENT_FOR_PROCESS';
    L_FULL_NAME CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;
	 l_module    CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_BUSINESSEVENTS_PVT.RAISE_BUSINESS_EVT_FOR_PROCESS';

    L_TXN_HDR_NUM VARCHAR2(255);

    L_TXN_HDR_REC  DPP_TXN_HDR_REC_TYPE;
    L_TXN_LINE_ID  DPP_TXN_LINE_TBL_TYPE;

  BEGIN

    SAVEPOINT RAISE_BUS_EVT_FOR_PROC;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.COMPATIBLE_API_CALL (L_API_VERSION, P_API_VERSION, L_API_NAME, G_PKG_NAME)
    THEN
      DPP_UTILITY_PVT.DEBUG_MESSAGE(FND_LOG.LEVEL_STATEMENT, l_module, L_API_NAME || ' : Not a compatible API call.');
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    DPP_UTILITY_PVT.DEBUG_MESSAGE(FND_LOG.LEVEL_PROCEDURE, l_module, L_API_NAME||': START');

    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.TO_BOOLEAN (P_INIT_MSG_LIST) THEN
      FND_MSG_PUB.INITIALIZE;
    END IF;

    -- Initialize API return status to sucess
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    SELECT TRANSACTION_NUMBER
    INTO L_TXN_HDR_NUM
    FROM DPP_TRANSACTION_HEADERS_ALL
    WHERE TRANSACTION_HEADER_ID = P_TXN_HDR_ID;

    L_TXN_HDR_REC := NULL;
    L_TXN_LINE_ID.DELETE();
    L_TXN_HDR_REC.TRANSACTION_HEADER_ID := P_TXN_HDR_ID;
    L_TXN_HDR_REC.TRANSACTION_NUMBER := L_TXN_HDR_NUM;
    L_TXN_HDR_REC.PROCESS_CODE := P_PROCESS_CODE;

    RAISE_BUSINESS_EVENT( P_API_VERSION => L_API_VERSION,
                          P_INIT_MSG_LIST => P_INIT_MSG_LIST,
                          P_COMMIT => P_COMMIT,
                          P_VALIDATION_LEVEL => P_VALIDATION_LEVEL,
                          X_RETURN_STATUS => X_RETURN_STATUS,
                          X_MSG_COUNT => X_MSG_COUNT,
                          X_MSG_DATA => X_MSG_DATA,
                          P_TXN_HDR_REC => L_TXN_HDR_REC,
                          P_TXN_LINE_ID => L_TXN_LINE_ID
                        );

   IF X_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS THEN
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Business event raised for the process code : ' || P_PROCESS_CODE);
     FND_FILE.NEW_LINE(FND_FILE.LOG);
   ELSE
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Business event not raised for the process code : ' || P_PROCESS_CODE);
     FND_FILE.NEW_LINE(FND_FILE.LOG);
     FND_FILE.PUT_LINE(FND_FILE.LOG,substr(('Error Message : '||X_MSG_DATA),1,4000));
    FND_FILE.NEW_LINE(FND_FILE.LOG);
    --RETCODE := '2';
    --ERRBUFF := 'ERROR';
    END IF;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO  RAISE_BUS_EVT_FOR_PROC;
                X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
                -- Standard call to get message count and if count=1, get the message
                FND_MSG_PUB.COUNT_AND_GET (P_ENCODED => FND_API.G_FALSE, P_COUNT => X_MSG_COUNT, P_DATA  => X_MSG_DATA);
                IF X_MSG_COUNT > 1 THEN
                        FOR I IN 1..X_MSG_COUNT LOOP
                                X_MSG_DATA := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
                        END LOOP;
                END IF;
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO  RAISE_BUS_EVT_FOR_PROC;
                X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
                -- Standard call to get message count and if count=1, get the message
                FND_MSG_PUB.COUNT_AND_GET (P_ENCODED => FND_API.G_FALSE, P_COUNT => X_MSG_COUNT, P_DATA  => X_MSG_DATA);
                IF X_MSG_COUNT > 1 THEN
                        FOR I IN 1..X_MSG_COUNT LOOP
                                X_MSG_DATA := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
                        END LOOP;
                END IF;
        WHEN OTHERS THEN
                ROLLBACK TO  RAISE_BUS_EVT_FOR_PROC;
                X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;

    DPP_UTILITY_PVT.DEBUG_MESSAGE(FND_LOG.LEVEL_STATEMENT, l_module, L_API_NAME || ',FND_API.G_RET_STS_UNEXP_ERROR :: ' || SQLERRM);

    IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MESSAGE.SET_NAME('FND', 'SQL_PLSQL_ERROR');
        FND_MESSAGE.SET_TOKEN('ROUTINE', L_FULL_NAME);
        FND_MESSAGE.SET_TOKEN('ERRNO', SQLCODE);
        FND_MESSAGE.SET_TOKEN('REASON', SQLERRM);
    END IF;

                IF FND_MSG_PUB.CHECK_MSG_LEVEL ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
                THEN
                FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, L_API_NAME);
                END IF;
                -- Standard call to get message count and if count=1, get the message
                FND_MSG_PUB.COUNT_AND_GET (P_ENCODED => FND_API.G_FALSE, P_COUNT => X_MSG_COUNT, P_DATA  => X_MSG_DATA);
                IF X_MSG_COUNT > 1 THEN
                        FOR I IN 1..X_MSG_COUNT LOOP
                                X_MSG_DATA := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
                        END LOOP;
                END IF;

  END RAISE_BUSINESS_EVT_FOR_PROCESS;





PROCEDURE RAISE_EFFECTIVE_DATE_EVENT(
        P_API_VERSION        IN  NUMBER,
        P_INIT_MSG_LIST      IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
        P_COMMIT             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
        P_VALIDATION_LEVEL   IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
        X_RETURN_STATUS      OUT NOCOPY   VARCHAR2,
        X_MSG_DATA           OUT NOCOPY   VARCHAR2,
        X_MSG_COUNT          OUT NOCOPY   NUMBER,
        P_PROGRAM_ID         IN NUMBER)

IS

  L_API_NAME CONSTANT VARCHAR2(30) := 'RAISE_EFFECTIVE_DATE_EVENT';
  L_API_VERSION CONSTANT NUMBER := 1.0;
  L_FULL_NAME CONSTANT  VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;
  l_module    CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_BUSINESSEVENTS_PVT.RAISE_EFFECTIVE_DATE_EVENT';

  L_EVENT_NAME VARCHAR2(60) := 'oracle.apps.dpp.notifyeffective';
  L_ITEM_KEY VARCHAR2(30);
  L_PARAMETER_LIST WF_PARAMETER_LIST_T;
  L_USER_NAME VARCHAR2(255);
  L_EVENT_TEST VARCHAR2(10);

BEGIN

  SAVEPOINT START_WF_ON_EFF_DATE;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.COMPATIBLE_API_CALL (L_API_VERSION, P_API_VERSION, L_API_NAME, G_PKG_NAME)
    THEN
      DPP_UTILITY_PVT.DEBUG_MESSAGE(FND_LOG.LEVEL_STATEMENT, l_module, L_API_NAME || ' : Not a compatible API call.');
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_PROCEDURE, l_module, L_API_NAME||': START');
    DPP_UTILITY_PVT.DEBUG_MESSAGE(FND_LOG.LEVEL_STATEMENT, l_module, L_API_NAME || ', Program ID : ' || P_PROGRAM_ID );

    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.TO_BOOLEAN (P_INIT_MSG_LIST) THEN
      FND_MSG_PUB.INITIALIZE;
    END IF;

    -- Initialize API return status to sucess
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    L_ITEM_KEY := DBMS_UTILITY.GET_TIME();

    DPP_UTILITY_PVT.DEBUG_MESSAGE(FND_LOG.LEVEL_STATEMENT, l_module, L_API_NAME || ', Event Key : ' || L_ITEM_KEY);

    L_EVENT_TEST := WF_EVENT.TEST(L_EVENT_NAME);

    DPP_UTILITY_PVT.DEBUG_MESSAGE(FND_LOG.LEVEL_STATEMENT, l_module, L_API_NAME || ', Event Test : ' || L_EVENT_TEST);

    IF L_EVENT_TEST = 'NONE' THEN
      X_MSG_DATA := FND_MESSAGE.GET();
      DPP_UTILITY_PVT.DEBUG_MESSAGE(FND_LOG.LEVEL_STATEMENT, l_module, 'No enabled local subscriptions reference the event, or the event does not exist.');
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'No enabled local subscriptions reference the event, or the event does not exist.');
      FND_FILE.NEW_LINE(FND_FILE.LOG);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    L_PARAMETER_LIST := WF_PARAMETER_LIST_T();
    WF_EVENT.ADDPARAMETERTOLIST( P_NAME => 'PROGRAM_ID', P_VALUE => P_PROGRAM_ID, P_PARAMETERLIST => L_PARAMETER_LIST );
    WF_EVENT.RAISE ( P_EVENT_NAME => L_EVENT_NAME,
            P_EVENT_KEY => L_ITEM_KEY,
            P_PARAMETERS => L_PARAMETER_LIST,
            P_SEND_DATE => SYSDATE );

    DPP_UTILITY_PVT.DEBUG_MESSAGE(FND_LOG.LEVEL_STATEMENT, l_module, L_API_NAME || ', Event raised : ' || L_ITEM_KEY );

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Event raised : ' || L_ITEM_KEY );
    FND_FILE.NEW_LINE(FND_FILE.LOG);


    FND_MSG_PUB.COUNT_AND_GET(P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );

EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
                        X_RETURN_STATUS := FND_API.G_RET_STS_ERROR ;
                        DPP_UTILITY_PVT.DEBUG_MESSAGE(FND_LOG.LEVEL_EXCEPTION, l_module, L_API_NAME || ', FND_API.G_EXC_ERROR : ' || SQLERRM);

                FND_FILE.PUT_LINE(FND_FILE.LOG,'EXC_ERROR : '||SQLERRM);
            FND_FILE.NEW_LINE(FND_FILE.LOG);
                        ROLLBACK TO START_WF_ON_EFF_DATE;
            FND_MSG_PUB.COUNT_AND_GET (P_ENCODED => FND_API.G_FALSE, P_COUNT => X_MSG_COUNT, P_DATA  => X_MSG_DATA);
      IF X_MSG_COUNT > 1 THEN
        FOR I IN 1..X_MSG_COUNT LOOP
          X_MSG_DATA := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
        END LOOP;
      END IF;
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                        X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR ;
                        DPP_UTILITY_PVT.DEBUG_MESSAGE(FND_LOG.LEVEL_EXCEPTION, l_module, L_API_NAME || ', FND_API.G_RET_STS_UNEXP_ERROR : ' || SQLERRM);

                FND_FILE.PUT_LINE(FND_FILE.LOG, 'UNEXP_ERROR : '||SQLERRM);
            FND_FILE.NEW_LINE(FND_FILE.LOG);
                        ROLLBACK TO START_WF_ON_EFF_DATE;
                        FND_MSG_PUB.COUNT_AND_GET (P_ENCODED => FND_API.G_FALSE, P_COUNT => X_MSG_COUNT, P_DATA  => X_MSG_DATA);
      IF X_MSG_COUNT > 1 THEN
        FOR I IN 1..X_MSG_COUNT LOOP
          X_MSG_DATA := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
        END LOOP;
      END IF;
        WHEN OTHERS THEN
                        X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
                        DPP_UTILITY_PVT.DEBUG_MESSAGE(FND_LOG.LEVEL_EXCEPTION, l_module, L_API_NAME || ',FND_API.G_RET_STS_UNEXP_ERROR :: ' || SQLERRM);

                FND_FILE.PUT_LINE(FND_FILE.LOG, 'OTHER_ERROR : '||SQLERRM);
            FND_FILE.NEW_LINE(FND_FILE.LOG);
                        IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                                        FND_MESSAGE.SET_NAME('FND', 'SQL_PLSQL_ERROR');
                                        FND_MESSAGE.SET_TOKEN('ROUTINE', L_FULL_NAME);
                                        FND_MESSAGE.SET_TOKEN('ERRNO', SQLCODE);
                                        FND_MESSAGE.SET_TOKEN('REASON', SQLERRM);
                        END IF;

      ROLLBACK TO START_WF_ON_EFF_DATE;
      IF FND_MSG_PUB.CHECK_MSG_LEVEL (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME,L_API_NAME);
      END IF;

      FND_MSG_PUB.COUNT_AND_GET (P_ENCODED => FND_API.G_FALSE, P_COUNT => X_MSG_COUNT, P_DATA  => X_MSG_DATA);
      IF X_MSG_COUNT > 1 THEN
        FOR I IN 1..X_MSG_COUNT LOOP
          X_MSG_DATA := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
        END LOOP;
      END IF;

END RAISE_EFFECTIVE_DATE_EVENT;



PROCEDURE SEND_EFFECTIVE_DATE_NOTIF(
          ITEMTYPE IN VARCHAR2,
          ITEMKEY  IN VARCHAR2,
          ACTID    IN NUMBER,
          FUNCMODE IN VARCHAR2,
          RESULT   IN OUT NOCOPY VARCHAR2
  )
IS

  L_PROGRAM_ID NUMBER := 0;
  l_module     CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_BUSINESSEVENTS_PVT.SEND_EFFECTIVE_DATE_NOTIF';

  CURSOR GET_USER_LIST (P_PROGRAM_ID VARCHAR2) IS
    SELECT DISTINCT H.CREATED_BY, U.USER_NAME
    FROM DPP_TRANSACTION_HEADERS_ALL H, FND_USER U
    WHERE TRUNC(H.EFFECTIVE_START_DATE) < TRUNC(SYSDATE)
    AND H.REQUEST_ID=P_PROGRAM_ID
    AND H.TRANSACTION_STATUS = 'PENDING_ADJUSTMENT'
    AND H.CREATED_BY=U.USER_ID;

  L_USER_ID VARCHAR2(50);
  L_USER_NAME VARCHAR2(50);
  L_NOTIFY_ID NUMBER;
  L_WF_ID VARCHAR2(10) := 'DPP_EDNF';

BEGIN

    L_PROGRAM_ID := WF_ENGINE.GETITEMATTRNUMBER(ITEMTYPE => ITEMTYPE, ITEMKEY => ITEMKEY, ANAME =>'PROGRAM_ID');

        DPP_UTILITY_PVT.DEBUG_MESSAGE(FND_LOG.LEVEL_STATEMENT, l_module, 'SEND_EFFECTIVE_DATE_NOTIF :: itemtype:' || itemtype);
        DPP_UTILITY_PVT.DEBUG_MESSAGE(FND_LOG.LEVEL_STATEMENT, l_module, 'SEND_EFFECTIVE_DATE_NOTIF :: itemkey:' || itemkey);
        DPP_UTILITY_PVT.DEBUG_MESSAGE(FND_LOG.LEVEL_STATEMENT, l_module, 'SEND_EFFECTIVE_DATE_NOTIF :: actid:' || actid);
        DPP_UTILITY_PVT.DEBUG_MESSAGE(FND_LOG.LEVEL_STATEMENT, l_module, 'SEND_EFFECTIVE_DATE_NOTIF :: funcmode:' || funcmode);
        DPP_UTILITY_PVT.DEBUG_MESSAGE(FND_LOG.LEVEL_STATEMENT, l_module, 'SEND_EFFECTIVE_DATE_NOTIF :: programid' || L_PROGRAM_ID);

  OPEN GET_USER_LIST(L_PROGRAM_ID);
  LOOP
    FETCH GET_USER_LIST INTO L_USER_ID, L_USER_NAME;
    EXIT WHEN GET_USER_LIST%NOTFOUND;

    DPP_UTILITY_PVT.DEBUG_MESSAGE(FND_LOG.LEVEL_STATEMENT, l_module, 'SEND_EFFECTIVE_DATE_NOTIF :: ' || L_USER_ID);
    DPP_UTILITY_PVT.DEBUG_MESSAGE(FND_LOG.LEVEL_STATEMENT, l_module, 'SEND_EFFECTIVE_DATE_NOTIF :: ' || L_USER_NAME);

       WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE => ITEMTYPE,
                             ITEMKEY  => ITEMKEY,
                             ANAME    => 'USER_ID',
                             AVALUE   => L_USER_ID);

       WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE => ITEMTYPE,
                             ITEMKEY  => ITEMKEY,
                             ANAME    => 'EFFECTIVE_DATE',
                             AVALUE   => TRUNC(SYSDATE));

--    L_PARAMETER_LIST := WF_PARAMETER_LIST_T();
--
--    WF_EVENT.ADDPARAMETERTOLIST ( P_NAME => 'CREATED_USER_ID',
--                    P_VALUE => L_USER_NAME,
--                    P_PARAMETERLIST => L_PARAMETER_LIST);

      L_NOTIFY_ID := WF_NOTIFICATION.SEND(
                      ROLE         => L_USER_NAME,
                      MSG_TYPE     => L_WF_ID,
                      MSG_NAME     => 'TXN_LIST_MSG',
                      DUE_DATE     => NULL,
                      CALLBACK     => 'WF_ENGINE.CB',
                      CONTEXT      => L_WF_ID || ':' || ITEMKEY || ':',
                      SEND_COMMENT => NULL,
                      PRIORITY     => NULL );

      DPP_UTILITY_PVT.DEBUG_MESSAGE(FND_LOG.LEVEL_STATEMENT, l_module, 'SEND_EFFECTIVE_DATE_NOTIF :: ' || L_NOTIFY_ID);

  END LOOP;
  CLOSE GET_USER_LIST;

    RESULT := 'COMPLETE:Y';

end SEND_EFFECTIVE_DATE_NOTIF;


---------------------------------------------------------------------
-- PROCEDURE
--    Raise_Business_Event
--
-- PURPOSE
--    Raise Business Event.
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------

PROCEDURE Raise_Business_Event(
     p_api_version       IN       NUMBER
    ,p_init_msg_list     IN       VARCHAR2     := FND_API.G_FALSE
    ,p_commit            IN       VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level  IN       NUMBER       := FND_API.G_VALID_LEVEL_FULL
    ,x_return_status     OUT  NOCOPY      VARCHAR2
        ,x_msg_count             OUT  NOCOPY      NUMBER
        ,x_msg_data          OUT  NOCOPY      VARCHAR2

    ,p_txn_hdr_rec           IN       dpp_txn_hdr_rec_type
        ,p_txn_line_id           IN       dpp_txn_line_tbl_type
     )
IS
l_api_version        CONSTANT NUMBER       := 1.0;
l_api_name               CONSTANT VARCHAR2(30) := 'Raise_Business_Event';
l_full_name              CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
l_return_status         VARCHAR2(30);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);
l_module                CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_BUSINESSEVENTS_PVT.RAISE_BUSINESS_EVENT';

l_input_xml     CLOB;
l_queryCtx              dbms_xmlquery.ctxType;
l_table_count           NUMBER;
l_row_count             NUMBER := 0;
l_exe_dtl_id        NUMBER;
l_user_id               NUMBER := FND_GLOBAL.USER_ID;
l_user_name             VARCHAR2(150);
l_login_id      NUMBER := FND_GLOBAL.LOGIN_ID;
l_claim_type_flag       VARCHAR2(240);
l_status_code           CONSTANT VARCHAR2(20)  := '''PENDING_CLOSE''';
l_claim_hdr_amt         NUMBER;
l_cost_adj_acct         NUMBER;
dtl_price_change        VARCHAR2(50);
sup_trd_prf_price_change VARCHAR2(50);
dtla_price_change       VARCHAR2(50);
l_price_change_flag     VARCHAR2(20);

L_CANCEL VARCHAR2(10) DEFAULT 'FALSE';

BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Raise_Business_Event;

   IF NOT FND_API.Compatible_API_Call (
    l_api_version,
        p_api_version,
        l_api_name,
        G_PKG_NAME)
   THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_PROCEDURE, l_module, 'Public API: ' || l_api_name || 'start');

   -- Initialize API return status to sucess
      x_return_status := FND_API.g_ret_sts_success;

    --Get a unique value for the execution detail id
    BEGIN
        SELECT DPP_EXECUTION_DETAIL_ID_SEQ.nextval
          INTO l_exe_dtl_id
          FROM dual;

       EXCEPTION
       WHEN NO_DATA_FOUND THEN
           fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
               fnd_message.set_token('ROUTINE', 'DPP_BUSINESSEVENTS_PVT');
               fnd_message.set_token('ERRNO', sqlcode);
               fnd_message.set_token('REASON', 'EXECUTION DETAIL ID NOT FOUND');
               FND_MSG_PUB.add;
           IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
             FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
           END IF;
           RAISE FND_API.g_exc_error;
        WHEN OTHERS THEN
            fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
               fnd_message.set_token('ROUTINE', 'DPP_BUSINESSEVENTS_PVT');
               fnd_message.set_token('ERRNO', sqlcode);
               fnd_message.set_token('REASON', sqlerrm);
            IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
              FND_MESSAGE.set_name('DPP', 'DPP_BUSEVT_INVALID_EXE_DET_ID');
              fnd_message.set_token('SEQ_NAME', 'DPP_EXECUTION_DETAIL_ID_SEQ');
              FND_MSG_PUB.add;
              FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Execution Detail ID : ' || l_exe_dtl_id ||' For Transaction ID :'||p_txn_hdr_rec.Transaction_Header_ID);
    DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Process Code : ' || p_txn_hdr_rec.process_code);

    --Get the user name corresponding to the user id
    BEGIN
        SELECT user_name
          INTO l_user_name
          FROM fnd_user
         WHERE user_id = l_user_id ;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
           fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
           fnd_message.set_token('ROUTINE', 'DPP_BUSINESSEVENTS_PVT');
           fnd_message.set_token('ERRNO', sqlcode);
           fnd_message.set_token('REASON', 'INVALID USER');
           FND_MSG_PUB.add;
           IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
             FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
           END IF;
           RAISE FND_API.g_exc_error;
        WHEN OTHERS THEN
            fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
            fnd_message.set_token('ROUTINE', 'DPP_BUSINESSEVENTS_PVT');
            fnd_message.set_token('ERRNO', sqlcode);
            fnd_message.set_token('REASON', sqlerrm);
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    l_user_name := ''''||l_user_name||'''';

    IF p_txn_hdr_rec.process_code LIKE 'CNCL%'
    THEN
        L_CANCEL:='TRUE';
    END IF;

    IF p_txn_hdr_rec.process_code = 'DSTRINVCL'
       OR p_txn_hdr_rec.process_code = 'CUSTINVCL'
       OR p_txn_hdr_rec.process_code = 'CUSTCL' THEN

       IF p_txn_hdr_rec.claim_type_flag IS NULL THEN
          --No claim type flag has been sent
          FND_MESSAGE.set_name('DPP', 'DPP_BUSEVT_INVALID_CLAIM_TYPE');
          FND_MSG_PUB.add;
          FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
          RAISE FND_API.g_exc_error;
       ELSE
          --Concatinate the claim flag with necessary quotes to generate xml data
          l_claim_type_flag := ''''||p_txn_hdr_rec.claim_type_flag||'''';
          DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Claim Type Flag : ' || l_claim_type_flag);
       END IF;
       --Delete the existing rows from the DPP_TRANSACTION_LINES_GT table
         DELETE FROM DPP_TRANSACTION_LINES_GT;
       --Check if any line id has been passed and insert into the table DPP_TRANSACTION_LINES_GT
       l_table_count := p_txn_line_id.COUNT;
       --Changed the condition to check the claim source instead of the table count since array cannot be NULL from UI
       IF p_txn_hdr_rec.claim_creation_source <> 'EXEDTLS' THEN
          IF l_table_count > 0 THEN
             FOR i IN p_txn_line_id.FIRST..p_txn_line_id.LAST LOOP
                 BEGIN
                    INSERT INTO  DPP_TRANSACTION_LINES_GT(transaction_header_id,
                                                           transaction_line_id
                                                          )
                                                    VALUES(p_txn_hdr_rec.Transaction_Header_ID,
                                                           p_txn_line_id(i)
                                                          );
                 EXCEPTION
                    WHEN OTHERS THEN
                        fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
                        fnd_message.set_token('ROUTINE', 'DPP_BUSINESSEVENTS_PVT');
                        fnd_message.set_token('ERRNO', sqlcode);
                        fnd_message.set_token('REASON', sqlerrm);
                        FND_MSG_PUB.add;
                        IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
                           FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
                        END IF;
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END;
             END LOOP;
          ELSE
             fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
             fnd_message.set_token('ROUTINE', 'DPP_BUSINESSEVENTS_PVT');
             fnd_message.set_token('ERRNO', sqlcode);
             fnd_message.set_token('REASON', 'Transaction Line Id is required for the API');
             FND_MSG_PUB.add;
             RAISE FND_API.G_EXC_ERROR;
          END IF;  --l_table_count
       ELSE
          IF p_txn_hdr_rec.claim_type_flag = 'SUPP_DSTR_CL' THEN
             BEGIN
                 INSERT INTO  DPP_TRANSACTION_LINES_GT(transaction_header_id,
                                                       transaction_line_id)
                                                SELECT transaction_header_id,
                                                       transaction_line_id
                                                  FROM dpp_transaction_lines_all
                                                 WHERE transaction_header_id = p_txn_hdr_rec.Transaction_Header_ID;
             EXCEPTION
                WHEN OTHERS THEN
                   fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
                   fnd_message.set_token('ROUTINE', 'DPP_BUSINESSEVENTS_PVT');
                   fnd_message.set_token('ERRNO', sqlcode);
                   fnd_message.set_token('REASON', sqlerrm);
                   FND_MSG_PUB.add;
                   IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
                      FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
                   END IF;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END;
          ELSE
             BEGIN
                 INSERT INTO  DPP_TRANSACTION_LINES_GT(transaction_header_id,
                                                       transaction_line_id)
                                                SELECT transaction_header_id,
                                                       customer_inv_line_id
                                                  FROM dpp_customer_claims_all
                                                 WHERE transaction_header_id = p_txn_hdr_rec.Transaction_Header_ID;
             EXCEPTION
                WHEN OTHERS THEN
                   fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
                   fnd_message.set_token('ROUTINE', 'DPP_BUSINESSEVENTS_PVT');
                   fnd_message.set_token('ERRNO', sqlcode);
                   fnd_message.set_token('REASON', sqlerrm);
                   FND_MSG_PUB.add;
                   IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
                      FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
                   END IF;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END;
          END IF;
       END IF;

    END IF;

    IF p_txn_hdr_rec.process_code = 'UPDTLP' THEN
      --Generate the Input Xml required for the Business Event -- UpdateListPrice
      l_queryCtx := dbms_xmlquery.newContext('SELECT Transaction_header_id,
                                                transaction_number,
                                                org_id,
                                                Vendor_id,'
                                                ||l_user_name|| ' user_name, '
                                                ||l_user_id||'user_id,'
                                                ||l_exe_dtl_id||'Execution_detail_id,
                                 CURSOR(select transaction_line_id,
                                               inventory_item_id,
                                               supplier_new_price new_price,
                                               UOM,
                                               headers.trx_currency currency
                                          FROM dpp_transaction_lines_all lines
                                         WHERE headers.Transaction_header_id = lines.Transaction_header_id
                                         AND nvl(lines.UPDATE_ITEM_LIST_PRICE,''N'') = ''N'') LINES
                                         FROM dpp_transaction_headers_all headers
                                         WHERE headers.Transaction_header_id = ' ||p_txn_hdr_rec.Transaction_Header_ID||
                                         'AND EXISTS (SELECT Transaction_header_id
                                                         FROM dpp_transaction_lines_all
                                                        WHERE Transaction_header_id = '||p_txn_hdr_rec.Transaction_Header_ID||'
                                                          AND nvl(UPDATE_ITEM_LIST_PRICE,''N'') = ''N'')'
                                        );
      dbms_xmlquery.setRowTag(l_queryCtx
                             , 'HEADER'
                             );
      dbms_xmlquery.setRowSetTag(l_queryCtx
                                ,'TRANSACTION'
                                );
      l_input_xml := dbms_xmlquery.getXml(l_queryCtx);
      --Check if the query returns any rows
      l_row_count  := dbms_xmlquery.getNumRowsProcessed(l_queryCtx);
      dbms_xmlquery.closeContext(l_queryCtx);

     IF l_row_count >0 THEN
        --Update the line status to PENDING in the DPP_TRANSACTION_LINES_ALL table
        UPDATE DPP_TRANSACTION_LINES_ALL
           SET update_item_list_price = 'P',
               OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER +1,
                  last_updated_by = l_user_id,
                  last_update_date = sysdate,
                  last_update_login = l_login_id
         WHERE transaction_header_id = p_txn_hdr_rec.Transaction_Header_ID
           AND nvl(update_item_list_price, 'N') = 'N';

        IF SQL%ROWCOUNT = 0 THEN
           l_return_status := FND_API.G_RET_STS_ERROR;
           DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Unable to Update  the column update_item_list_price in DPP_TRANSACTION_LINES_ALL Table');
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

     END IF;
  ELSIF p_txn_hdr_rec.process_code = 'OUTPL' OR p_txn_hdr_rec.process_code = 'CNCL_OUTPL' THEN
    --Generate the Input Xml required for the Business-- Event Send Notification for Outbound Price lists
      l_queryCtx := dbms_xmlquery.newContext('SELECT Transaction_header_id,
                                                '''||L_CANCEL||''' CANCEL_TXN,
                                                Transaction_number,
                                                to_char(Effective_start_date,''YYYY-MM-DD'') Effectivity_date,
                                                org_id,
                                                Vendor_id,
                                                Vendor_site_id,'
                                                ||l_user_name|| ' user_name, '
                                                ||l_user_id||'user_id,'
                                                ||l_exe_dtl_id||'Execution_detail_id,
                                 CURSOR(select transaction_line_id,
                                               inventory_item_id,
                                               supplier_new_price new_price,
                                               headers.trx_currency currency
                                          FROM dpp_transaction_lines_all lines
                                         WHERE headers.Transaction_header_id = lines.Transaction_header_id
                                           AND nvl(lines.NOTIFY_OUTBOUND_PRICELIST,''N'') <> ''D'') LINES
                                         FROM dpp_transaction_headers_all headers
                                         WHERE headers.Transaction_header_id = ' ||p_txn_hdr_rec.Transaction_Header_ID||
                                         'AND EXISTS (SELECT Transaction_header_id
                                                         FROM dpp_transaction_lines_all
                                                        WHERE Transaction_header_id = '||p_txn_hdr_rec.Transaction_Header_ID||'
                                                          AND nvl(NOTIFY_OUTBOUND_PRICELIST,''N'') <> ''D'')'
                                        );
      dbms_xmlquery.setRowTag(l_queryCtx
                             , 'HEADER'
                             );
      dbms_xmlquery.setRowSetTag(l_queryCtx
                                ,'TRANSACTION'
                                );
      l_input_xml := dbms_xmlquery.getXml(l_queryCtx);
      --Check if the query returns any rows
      l_row_count := dbms_xmlquery.getNumRowsProcessed(l_queryCtx);
      dbms_xmlquery.closeContext(l_queryCtx);

      IF l_row_count >0 THEN
         --Update the line status to PENDING in the DPP_TRANSACTION_LINES_ALL table
         UPDATE DPP_TRANSACTION_LINES_ALL
            SET NOTIFY_OUTBOUND_PRICELIST = 'P',
               OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER +1,
                  last_updated_by = l_user_id,
                  last_update_date = sysdate,
                  last_update_login = l_login_id
          WHERE transaction_header_id = p_txn_hdr_rec.Transaction_Header_ID
            AND nvl(NOTIFY_OUTBOUND_PRICELIST,'N') <> 'D';

         IF SQL%ROWCOUNT = 0 THEN
           l_return_status := FND_API.G_RET_STS_ERROR;
           DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Unable to Update  the column NOTIFY_OUTBOUND_PRICELIST in DPP_TRANSACTION_LINES_ALL Table');
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
  END IF;

ELSIF p_txn_hdr_rec.process_code = 'UPDCLM' THEN
    --Calculate the value of the claim header amount
        BEGIN
           SELECT SUM(nvl(claim_amount,0))
             INTO l_claim_hdr_amt
             FROM dpp_transaction_lines_all
            WHERE transaction_header_id = p_txn_hdr_rec.Transaction_Header_ID
              AND to_number(supp_dist_claim_id) = p_txn_hdr_rec.claim_id;
        EXCEPTION
       WHEN NO_DATA_FOUND THEN
           fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
               fnd_message.set_token('ROUTINE', 'DPP_BUSINESSEVENTS_PVT');
               fnd_message.set_token('ERRNO', sqlcode);
               fnd_message.set_token('REASON', 'INVALID CLAIM HEADER AMOUNT');
               FND_MSG_PUB.add;
           IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
             FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
           END IF;
           RAISE FND_API.G_EXC_ERROR;
        WHEN OTHERS THEN
            fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
               fnd_message.set_token('ROUTINE', 'DPP_BUSINESSEVENTS_PVT');
               fnd_message.set_token('ERRNO', sqlcode);
               fnd_message.set_token('REASON', sqlerrm);
               FND_MSG_PUB.add;
            IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
              FND_MESSAGE.set_name('DPP', 'DPP_BUSEVT_INVALID_CLAIM_AMT');
              FND_MSG_PUB.add;
              FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;
    --Generate the Input Xml required for the Business Event --Update Claim
      l_queryCtx := dbms_xmlquery.newContext('SELECT Transaction_header_id,
                                                Transaction_number,
                                                Vendor_id,
                                                org_id,
                                                Vendor_site_id,'
                                                ||l_user_name|| ' user_name, '
                                                ||l_user_id||'user_id,'
                                                ||l_exe_dtl_id||'Execution_detail_id,'
                                                ||l_status_code||'Status_code,
                                                trx_currency,'
                                                ||l_claim_hdr_amt||'Claim_amount,'
                                                ||p_txn_hdr_rec.claim_id||'claim_id,
                                 CURSOR(select transaction_line_id,
                                               inventory_item_id,
                                               claim_amount claim_amount,
                                               approved_inventory claim_quantity,
                                               UOM,'
                                               ||p_txn_hdr_rec.claim_id||'claim_id,
                                               headers.trx_currency currency
                                          FROM dpp_transaction_lines_all lines
                                         WHERE headers.Transaction_header_id = lines.Transaction_header_id
                                           AND lines.supp_dist_claim_id = '||p_txn_hdr_rec.claim_id||') LINES
                                         FROM dpp_transaction_headers_all headers
                                         WHERE headers.Transaction_header_id = ' ||p_txn_hdr_rec.Transaction_Header_ID
                                        );
      dbms_xmlquery.setRowTag(l_queryCtx
                             , 'HEADER'
                             );
      dbms_xmlquery.setRowSetTag(l_queryCtx
                                ,'TRANSACTION'
                                );
      l_input_xml := dbms_xmlquery.getXml(l_queryCtx);
      --Check if the query returns any rows
      l_row_count := dbms_xmlquery.getNumRowsProcessed(l_queryCtx);
      dbms_xmlquery.closeContext(l_queryCtx);

   ELSIF p_txn_hdr_rec.process_code = 'INPL' OR p_txn_hdr_rec.process_code = 'CNCL_INPL' THEN
    --Generate the Input Xml required for the Business Event -- Send Notification for Inbound Price lists
      l_queryCtx := dbms_xmlquery.newContext('SELECT Transaction_header_id,
                                                '''||L_CANCEL||''' CANCEL_TXN,
                                                Transaction_number,
                                                to_char(Effective_start_date,''YYYY-MM-DD'') Effectivity_date,
                                                org_id,
                                                Vendor_id,
                                                Vendor_site_id,'
                                                ||l_user_name|| ' user_name, '
                                                ||l_user_id||'user_id,'
                                                ||l_exe_dtl_id||'Execution_detail_id,
                                 CURSOR(select transaction_line_id,
                                               inventory_item_id,
                                               supplier_new_price new_price,
                                               headers.trx_currency currency
                                          FROM dpp_transaction_lines_all lines
                                         WHERE headers.Transaction_header_id = lines.Transaction_header_id
                                           AND nvl(lines.NOTIFY_INBOUND_PRICELIST,''N'') <> ''D'') LINES
                                         FROM dpp_transaction_headers_all headers
                                         WHERE headers.Transaction_header_id = ' ||p_txn_hdr_rec.Transaction_Header_ID||
                                         'AND EXISTS (SELECT Transaction_header_id
                                                         FROM dpp_transaction_lines_all
                                                        WHERE Transaction_header_id = '||p_txn_hdr_rec.Transaction_Header_ID||'
                                                          AND nvl(NOTIFY_INBOUND_PRICELIST,''N'') <> ''D'')'
                                        );
      dbms_xmlquery.setRowTag(l_queryCtx
                             , 'HEADER'
                             );
      dbms_xmlquery.setRowSetTag(l_queryCtx
                                ,'TRANSACTION'
                                );
      l_input_xml := dbms_xmlquery.getXml(l_queryCtx);
      --Check if the query returns any rows
      l_row_count := dbms_xmlquery.getNumRowsProcessed(l_queryCtx);
      dbms_xmlquery.closeContext(l_queryCtx);

    IF l_row_count >0 THEN
       --Update the line status to PENDING in the DPP_TRANSACTION_LINES_ALL table
       UPDATE DPP_TRANSACTION_LINES_ALL
          SET NOTIFY_INBOUND_PRICELIST = 'P',
               OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER +1,
                  last_updated_by = l_user_id,
                  last_update_date = sysdate,
                  last_update_login = l_login_id
        WHERE transaction_header_id = p_txn_hdr_rec.Transaction_Header_ID
          AND nvl(NOTIFY_INBOUND_PRICELIST,'N') <> 'D';

       IF SQL%ROWCOUNT = 0 THEN
           l_return_status := FND_API.G_RET_STS_ERROR;
           DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Unable to Update  the column NOTIFY_INBOUND_PRICELIST in DPP_TRANSACTION_LINES_ALL Table');
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
  END IF;

  ELSIF p_txn_hdr_rec.process_code = 'PROMO' OR p_txn_hdr_rec.process_code = 'CNCL_PROMO' THEN
    --Generate the Input Xml required for the Business Event -- Send Notification for Offers
      l_queryCtx := dbms_xmlquery.newContext('SELECT Transaction_header_id,
                                                '''||L_CANCEL||''' CANCEL_TXN,
                                                Transaction_number,
                                                to_char(Effective_start_date,''YYYY-MM-DD'') Effectivity_date,
                                                org_id,
                                                Vendor_id,
                                                Vendor_site_id,'
                                                ||l_user_name|| ' user_name, '
                                                ||l_user_id||'user_id,'
                                                ||l_exe_dtl_id||'Execution_detail_id,
                                 CURSOR(select transaction_line_id,
                                               inventory_item_id,
                                               supplier_new_price new_price,
                                               headers.trx_currency currency
                                          FROM dpp_transaction_lines_all lines
                                         WHERE headers.Transaction_header_id = lines.Transaction_header_id
                                           AND nvl(lines.NOTIFY_PROMOTIONS_PRICELIST,''N'') <> ''D'') LINES
                                         FROM dpp_transaction_headers_all headers
                                         WHERE headers.Transaction_header_id = ' ||p_txn_hdr_rec.Transaction_Header_ID||
                                         'AND EXISTS (SELECT Transaction_header_id
                                                         FROM dpp_transaction_lines_all
                                                        WHERE Transaction_header_id = '||p_txn_hdr_rec.Transaction_Header_ID||'
                                                          AND nvl(NOTIFY_PROMOTIONS_PRICELIST,''N'') <> ''D'')'
                                        );
      dbms_xmlquery.setRowTag(l_queryCtx
                             , 'HEADER'
                             );
      dbms_xmlquery.setRowSetTag(l_queryCtx
                                ,'TRANSACTION'
                                );
      l_input_xml := dbms_xmlquery.getXml(l_queryCtx);
      --Check if the query returns any rows
      l_row_count := dbms_xmlquery.getNumRowsProcessed(l_queryCtx);
      dbms_xmlquery.closeContext(l_queryCtx);

    IF l_row_count >0 THEN
       --Update the line status to PENDING in the DPP_TRANSACTION_LINES_ALL table
       UPDATE DPP_TRANSACTION_LINES_ALL
          SET NOTIFY_PROMOTIONS_PRICELIST = 'P',
               OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER +1,
                  last_updated_by = l_user_id,
                  last_update_date = sysdate,
                  last_update_login = l_login_id
        WHERE transaction_header_id = p_txn_hdr_rec.Transaction_Header_ID
          AND nvl(NOTIFY_PROMOTIONS_PRICELIST,'N') <> 'D';

       IF SQL%ROWCOUNT = 0 THEN
           l_return_status := FND_API.G_RET_STS_ERROR;
           DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Unable to Update  the column NOTIFY_PROMOTIONS_PRICELIST in DPP_TRANSACTION_LINES_ALL Table');
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
  END IF;
  ELSIF p_txn_hdr_rec.process_code = 'INVC' THEN
    --Retrieve the gl_cost_adjustment_acct
    BEGIN
       SELECT ostp.gl_cost_adjustment_acct
         INTO l_cost_adj_acct
         FROM ozf_supp_trd_prfls_all ostp,
              dpp_transaction_headers_all dtha
        WHERE ostp.supplier_id = to_number(dtha.vendor_id)
          AND ostp.supplier_site_id = to_number(dtha.vendor_site_id)
          AND ostp.org_id = to_number(dtha.org_id)
          AND dtha.transaction_header_id = p_txn_hdr_rec.Transaction_Header_ID;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
           l_cost_adj_acct := null;
        WHEN OTHERS THEN
            fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
               fnd_message.set_token('ROUTINE', 'DPP_BUSINESSEVENTS_PVT');
               fnd_message.set_token('ERRNO', sqlcode);
               fnd_message.set_token('REASON', sqlerrm);
               FND_MSG_PUB.add;
            IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
              FND_MESSAGE.set_name('DPP', 'DPP_BUSEVT_INVALID_COSTADJACC');
            FND_MSG_PUB.add;
              FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;
    IF l_cost_adj_acct IS NULL THEN
       BEGIN
         SELECT osp.gl_cost_adjustment_acct
           INTO l_cost_adj_acct
           FROM ozf_sys_parameters osp,
                dpp_transaction_headers_all dtha
          WHERE osp.org_id = to_number(dtha.org_id)
            AND dtha.transaction_header_id = p_txn_hdr_rec.Transaction_Header_ID;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
           fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
               fnd_message.set_token('ROUTINE', 'DPP_BUSINESSEVENTS_PVT');
               fnd_message.set_token('ERRNO', sqlcode);
               fnd_message.set_token('REASON', 'COST ADJUSTMENT ACCOUNT NOT FOUND');
               FND_MSG_PUB.add;
           IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
             FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
           END IF;
           RAISE FND_API.G_EXC_ERROR;
        WHEN OTHERS THEN
            fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
               fnd_message.set_token('ROUTINE', 'DPP_BUSINESSEVENTS_PVT');
               fnd_message.set_token('ERRNO', sqlcode);
               fnd_message.set_token('REASON', sqlerrm);
               FND_MSG_PUB.add;
            IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
              FND_MESSAGE.set_name('DPP', 'DPP_BUSEVT_INVALID_COSTADJACC');
              FND_MSG_PUB.add;
              FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;
    END IF;

    IF l_cost_adj_acct IS NOT NULL THEN
       DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Cost Adjustment Account : ' ||l_cost_adj_acct);

    --Generate the Input Xml required for the Business Event -- Update Inventory Costing
      l_queryCtx := dbms_xmlquery.newContext('SELECT Transaction_header_id,
                                                Transaction_number,
                                                org_id,'
                                                ||l_user_name|| ' user_name, '
                                                ||l_user_id||'user_id,'
                                                ||l_exe_dtl_id||'Execution_detail_id,'
                                                ||l_cost_adj_acct||'gl_cost_adjustment_acct,
                                 CURSOR(select transaction_line_id,
                                               inventory_item_id,
                                               supplier_new_price new_price,
                                               headers.trx_currency currency,
                                               UOM,
                                               price_change
                                          FROM dpp_transaction_lines_all lines
                                         WHERE headers.Transaction_header_id = lines.Transaction_header_id
                                         AND nvl(lines.UPDATE_INVENTORY_COSTING,''N'') = ''N'') LINES
                                         FROM dpp_transaction_headers_all headers
                                         WHERE headers.Transaction_header_id = ' ||p_txn_hdr_rec.Transaction_Header_ID||
                                         'AND EXISTS (SELECT Transaction_header_id
                                                         FROM dpp_transaction_lines_all
                                                        WHERE Transaction_header_id = '||p_txn_hdr_rec.Transaction_Header_ID||'
                                                          AND nvl(UPDATE_INVENTORY_COSTING,''N'') = ''N'')'
                                        );
      dbms_xmlquery.setRowTag(l_queryCtx
                             , 'HEADER'
                             );
      dbms_xmlquery.setRowSetTag(l_queryCtx
                                ,'TRANSACTION'
                                );
      l_input_xml := dbms_xmlquery.getXml(l_queryCtx);
      --Check if the query returns any rows
      l_row_count := dbms_xmlquery.getNumRowsProcessed(l_queryCtx);
      dbms_xmlquery.closeContext(l_queryCtx);

    IF l_row_count >0 THEN
       --Update the line status to PENDING in the DPP_TRANSACTION_LINES_ALL table
       UPDATE DPP_TRANSACTION_LINES_ALL
          SET UPDATE_INVENTORY_COSTING = 'P',
               OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER +1,
                  last_updated_by = l_user_id,
                  last_update_date = sysdate,
                  last_update_login = l_login_id
        WHERE transaction_header_id = p_txn_hdr_rec.Transaction_Header_ID
          AND nvl(UPDATE_INVENTORY_COSTING,'N') = 'N';

       IF SQL%ROWCOUNT = 0 THEN
           l_return_status := FND_API.G_RET_STS_ERROR;
           DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Unable to Update  the column UPDATE_INVENTORY_COSTING in DPP_TRANSACTION_LINES_ALL Table');
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
  ELSE
     fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
     fnd_message.set_token('ROUTINE', 'DPP_BUSINESSEVENTS_PVT');
     fnd_message.set_token('ERRNO', sqlcode);
     fnd_message.set_token('REASON', 'COST ADJUSTMENT ACCOUNT IS NULL');
     FND_MSG_PUB.add;
     IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
        FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
     END IF;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  ELSIF p_txn_hdr_rec.process_code = 'NTFYPO' OR p_txn_hdr_rec.process_code = 'CNCL_NTFYPO' THEN
    --Generate the Input Xml required for the Business-- Event Send Notifications for Purchase Orders
      l_queryCtx := dbms_xmlquery.newContext('SELECT Transaction_header_id,
                                                '''||L_CANCEL||''' CANCEL_TXN,
                                                Transaction_number,
                                                org_id,
                                                to_char(Effective_start_date,''YYYY-MM-DD'') Effectivity_date,
                                                vendor_site_id,
                                                Vendor_id,'
                                                ||l_user_name|| ' user_name, '
                                                ||l_user_id||'user_id,'
                                                ||l_exe_dtl_id||'Execution_detail_id,
                                 CURSOR(select transaction_line_id,
                                               inventory_item_id,
                                               supplier_new_price new_price,
                                               UOM,
                                               headers.trx_currency currency
                                          FROM dpp_transaction_lines_all lines
                                         WHERE headers.Transaction_header_id = lines.Transaction_header_id
                                           AND nvl(lines.NOTIFY_PURCHASING_DOCS,''N'') <> ''D'') LINES
                                          FROM dpp_transaction_headers_all headers
                                         WHERE headers.Transaction_header_id = ' ||p_txn_hdr_rec.Transaction_Header_ID||
                                         'AND EXISTS (SELECT Transaction_header_id
                                                         FROM dpp_transaction_lines_all
                                                        WHERE Transaction_header_id = '||p_txn_hdr_rec.Transaction_Header_ID||'
                                                          AND nvl(NOTIFY_PURCHASING_DOCS,''N'') <> ''D'')'
                                        );
      dbms_xmlquery.setRowTag(l_queryCtx
                             , 'HEADER'
                             );
      dbms_xmlquery.setRowSetTag(l_queryCtx
                                ,'TRANSACTION'
                                );
      l_input_xml := dbms_xmlquery.getXml(l_queryCtx);
      --Check if the query returns any rows
      l_row_count := dbms_xmlquery.getNumRowsProcessed(l_queryCtx);
      dbms_xmlquery.closeContext(l_queryCtx);

      IF l_row_count >0 THEN
         --Update the line status to PENDING in the DPP_TRANSACTION_LINES_ALL table
         UPDATE DPP_TRANSACTION_LINES_ALL
            SET notify_purchasing_docs = 'P',
               OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER +1,
                  last_updated_by = l_user_id,
                  last_update_date = sysdate,
                  last_update_login = l_login_id
          WHERE transaction_header_id = p_txn_hdr_rec.Transaction_Header_ID
            AND nvl(notify_purchasing_docs ,'N') <> 'D';

         IF SQL%ROWCOUNT = 0 THEN
           l_return_status := FND_API.G_RET_STS_ERROR;
           DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Unable to Update  the column notify_purchasing_docs in DPP_TRANSACTION_LINES_ALL Table');
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;
  ELSIF p_txn_hdr_rec.process_code = 'UPDTPO'  THEN
     --Generate the Input Xml required for the Business Event -- Update  Purchasing - Purchase Orders
      l_queryCtx := dbms_xmlquery.newContext('SELECT Transaction_header_id,
                                                Transaction_number,
                                                org_id,
                                                Vendor_id,'
                                                ||l_user_name|| ' user_name, '
                                                ||l_user_id||'user_id,'
                                                ||l_exe_dtl_id||'Execution_detail_id,
                                 CURSOR(select transaction_line_id,
                                               inventory_item_id,
                                               supplier_new_price new_price,
                                               UOM,
                                               headers.trx_currency currency
                                          FROM dpp_transaction_lines_all lines
                                         WHERE headers.Transaction_header_id = lines.Transaction_header_id
                                           AND nvl(lines.UPDATE_PURCHASING_DOCS,''N'') = ''N'') LINES
                                          FROM dpp_transaction_headers_all headers
                                         WHERE headers.Transaction_header_id = ' ||p_txn_hdr_rec.Transaction_Header_ID||
                                         'AND EXISTS (SELECT Transaction_header_id
                                                         FROM dpp_transaction_lines_all
                                                        WHERE Transaction_header_id = '||p_txn_hdr_rec.Transaction_Header_ID||'
                                                          AND nvl(UPDATE_PURCHASING_DOCS,''N'') = ''N'')'
                                        );
      dbms_xmlquery.setRowTag(l_queryCtx
                             , 'HEADER'
                             );
      dbms_xmlquery.setRowSetTag(l_queryCtx
                                ,'TRANSACTION'
                                );
      l_input_xml := dbms_xmlquery.getXml(l_queryCtx);
      --Check if the query returns any rows
      l_row_count := dbms_xmlquery.getNumRowsProcessed(l_queryCtx);
      dbms_xmlquery.closeContext(l_queryCtx);

    IF l_row_count >0 THEN
       --Update the line status to PENDING in the DPP_TRANSACTION_LINES_ALL table
       UPDATE DPP_TRANSACTION_LINES_ALL
          SET UPDATE_PURCHASING_DOCS = 'P',
               OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER +1,
                  last_updated_by = l_user_id,
                  last_update_date = sysdate,
                  last_update_login = l_login_id
        WHERE transaction_header_id = p_txn_hdr_rec.Transaction_Header_ID
          AND nvl(UPDATE_PURCHASING_DOCS ,'N')= 'N';

       IF SQL%ROWCOUNT = 0 THEN
           l_return_status := FND_API.G_RET_STS_ERROR;
           DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Unable to Update  the column UPDATE_PURCHASING_DOCS in DPP_TRANSACTION_LINES_ALL Table');
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;
  ELSIF p_txn_hdr_rec.process_code = 'DSTRINVCL' THEN
  --Added code for DPP Price Increase Enhancement
    BEGIN
     SELECT nvl(create_claim_price_increase,'N')
       INTO l_price_change_flag
       FROM ozf_supp_trd_prfls_all ostp,
              dpp_transaction_headers_all dtha
      WHERE ostp.supplier_id = to_number(dtha.vendor_id)
          AND ostp.supplier_site_id = to_number(dtha.vendor_site_id)
          AND ostp.org_id = to_number(dtha.org_id)
          AND dtha.transaction_header_id = p_txn_hdr_rec.Transaction_Header_ID;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
               fnd_message.set_token('ROUTINE', 'DPP_BUSINESSEVENTS_PVT');
               fnd_message.set_token('ERRNO', sqlcode);
               fnd_message.set_token('REASON', 'SUPPLIER TRADE PROFILE IS NOT FOUND'); --To be modified
               FND_MSG_PUB.add;
           IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
             FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
           END IF;
           RAISE FND_API.g_exc_error;
        WHEN OTHERS THEN
            fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
               fnd_message.set_token('ROUTINE', 'DPP_BUSINESSEVENTS_PVT');
               fnd_message.set_token('ERRNO', sqlcode);
               fnd_message.set_token('REASON', sqlerrm);
            IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
              FND_MESSAGE.set_name('DPP', 'DPP_BUSEVT_INVALID_EXE_DET_ID'); --To be modified
              fnd_message.set_token('SEQ_NAME', 'DPP_EXECUTION_DETAIL_ID_SEQ'); --To be modified
              FND_MSG_PUB.add;
              FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    IF (l_price_change_flag = 'N') THEN
       dtl_price_change := 'nvl(dtl.price_change,0) > 0';
       dtla_price_change := 'nvl(dtla.price_change,0) > 0';
    ELSE
       dtl_price_change := 'nvl(dtl.price_change,0) <> 0';
       dtla_price_change := 'nvl(dtla.price_change,0) <> 0';
    END IF;

    --Generate the Input Xml required for the Business Event -- Create On-Hand Inventory claim
      l_queryCtx := dbms_xmlquery.newContext('SELECT headers.Transaction_header_id,
                                                headers.Transaction_number,
                                                headers.Vendor_id,
                                                headers.org_id,
                                                headers.Vendor_site_id,'
                                                ||l_user_name|| ' user_name, '
                                                ||l_user_id||'user_id,'
                                                ||l_exe_dtl_id||'Execution_detail_id,'
                                                ||l_claim_type_flag||'claim_type_flag,
                                                headers.trx_currency,
                                 CURSOR(select dtl.transaction_line_id,
                                               dtl.inventory_item_id,
                                               dtl.claim_amount claim_line_amount,
                                               dtl.approved_inventory CLAIM_QUANTITY,
                                               dtl.UOM,
                                               headers.trx_currency currency
                                          FROM dpp_transaction_lines_all dtl,
                                               DPP_TRANSACTION_LINES_GT dtlg
                                         WHERE headers.Transaction_header_id = dtl.Transaction_header_id
                                           AND dtl.transaction_line_id = dtlg.transaction_line_id
                                           AND '||dtl_price_change||'
                                           AND nvl(dtl.approved_inventory,0) > 0
                                           AND nvl(dtl.SUPP_DIST_CLAIM_STATUS,''N'') = ''N'') LINES
                                         FROM dpp_transaction_headers_all headers
                                         WHERE headers.Transaction_header_id  = ' ||p_txn_hdr_rec.Transaction_Header_ID||
                                         'AND EXISTS (SELECT dtla.Transaction_header_id
                                                         FROM dpp_transaction_lines_all dtla,
                                                              DPP_TRANSACTION_LINES_GT dtg
                                                        WHERE dtla.Transaction_header_id = '||p_txn_hdr_rec.Transaction_Header_ID||'
                                                          AND dtla.transaction_line_id = dtg.transaction_line_id
                                                          AND nvl(dtla.SUPP_DIST_CLAIM_STATUS,''N'') = ''N''
                                                          AND '||dtla_price_change||'
                                                          AND nvl(dtla.approved_inventory,0) > 0)'
                                        );
      dbms_xmlquery.setRowTag(l_queryCtx
                             , 'HEADER'
                             );
      dbms_xmlquery.setRowSetTag(l_queryCtx
                                ,'TRANSACTION'
                                );
      l_input_xml := dbms_xmlquery.getXml(l_queryCtx);
      --Check if the query returns any rows
      l_row_count := dbms_xmlquery.getNumRowsProcessed(l_queryCtx);
      dbms_xmlquery.closeContext(l_queryCtx);

   IF l_row_count >0 THEN
     IF p_txn_hdr_rec.claim_creation_source = 'EXEDTLS' THEN

     IF (l_price_change_flag = 'N') THEN     -- Only Price Decrease Lines
         --Update the line status to PENDING in the DPP_TRANSACTION_LINES_ALL table
         UPDATE DPP_TRANSACTION_LINES_ALL
             SET SUPP_DIST_CLAIM_STATUS = 'P',
                 OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER +1,
                    last_updated_by = l_user_id,
                    last_update_date = sysdate,
                    last_update_login = l_login_id
           WHERE transaction_header_id = p_txn_hdr_rec.Transaction_Header_ID
             AND nvl(SUPP_DIST_CLAIM_STATUS ,'N')= 'N'
             AND nvl(approved_inventory,0) > 0
             AND nvl(price_change,0) > 0;

         IF SQL%ROWCOUNT = 0 THEN
             l_return_status := FND_API.G_RET_STS_ERROR;
             DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Unable to Update  the column SUPP_DIST_CLAIM_STATUS in DPP_TRANSACTION_LINES_ALL Table');
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
         --Update those lines to Y who have the approved inventory as 0
         UPDATE DPP_TRANSACTION_LINES_ALL
             SET SUPP_DIST_CLAIM_STATUS = 'Y',
                 OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER +1,
                 last_updated_by = l_user_id,
                 last_update_date = sysdate,
                 last_update_login = l_login_id
           WHERE transaction_header_id = p_txn_hdr_rec.Transaction_Header_ID
             AND nvl(SUPP_DIST_CLAIM_STATUS ,'N')= 'N'
             AND (nvl(approved_inventory,0) = 0 OR nvl(price_change,0) <= 0);
       ELSE         -- Both Price Increase and Price Decrease Lines
         --Update the line status to PENDING in the DPP_TRANSACTION_LINES_ALL table
         UPDATE DPP_TRANSACTION_LINES_ALL
             SET SUPP_DIST_CLAIM_STATUS = 'P',
                 OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER +1,
                    last_updated_by = l_user_id,
                    last_update_date = sysdate,
                    last_update_login = l_login_id
           WHERE transaction_header_id = p_txn_hdr_rec.Transaction_Header_ID
             AND nvl(SUPP_DIST_CLAIM_STATUS ,'N')= 'N'
             AND nvl(approved_inventory,0) > 0
             AND nvl(price_change,0) <> 0;

         IF SQL%ROWCOUNT = 0 THEN
             l_return_status := FND_API.G_RET_STS_ERROR;
             DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Unable to Update  the column SUPP_DIST_CLAIM_STATUS in DPP_TRANSACTION_LINES_ALL Table');
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
         --Update those lines to Y who have the approved inventory as 0
         UPDATE DPP_TRANSACTION_LINES_ALL
             SET SUPP_DIST_CLAIM_STATUS = 'Y',
                 OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER +1,
                 last_updated_by = l_user_id,
                 last_update_date = sysdate,
                 last_update_login = l_login_id
           WHERE transaction_header_id = p_txn_hdr_rec.Transaction_Header_ID
             AND nvl(SUPP_DIST_CLAIM_STATUS ,'N')= 'N'
             AND nvl(approved_inventory,0) = 0;
       END IF;
     END IF;  --p_txn_hdr_rec.claim_creation_source = 'EXEDTLS'
    END IF;
  ELSIF p_txn_hdr_rec.process_code = 'CUSTINVCL' THEN
    --Generate the Input Xml required for the Business Event -- Create Customer Inventory claim for distributor
      l_queryCtx := dbms_xmlquery.newContext('SELECT headers.Transaction_header_id,
                                                headers.Transaction_number,
                                                headers.org_id,
                                                headers.Vendor_id,
                                                headers.Vendor_site_id,'
                                                ||l_user_name|| ' user_name, '
                                                ||l_user_id||'user_id,'
                                                ||l_exe_dtl_id||'Execution_detail_id,'
                                                ||l_claim_type_flag||'claim_type_flag,
                                                headers.trx_currency,
                                 CURSOR(select dcc.customer_inv_line_id TRANSACTION_LINE_ID,
                                               dcc.inventory_item_id,
                                               dcc.cust_account_id CUSTOMER_ACCOUNT_ID,
                                               dcc.supp_claim_amt CLAIM_LINE_AMOUNT,
                                               dcc.reported_inventory claim_quantity,
                                               dcc.trx_currency currency,
                                               dcc.UOM
                                          FROM DPP_customer_claims_all dcc,
                                               DPP_TRANSACTION_LINES_GT dtg
                                         WHERE headers.Transaction_header_id = dcc.Transaction_header_id
                                         AND dcc.customer_inv_line_id = dtg.transaction_line_id
                                         AND nvl(dcc.reported_inventory,0) > 0
                                         AND nvl(dcc.supp_claim_amt,0) > 0
                                         AND nvl(dcc.supplier_claim_created,''N'') = ''N'') LINES
                                         FROM dpp_transaction_headers_all headers
                                         WHERE headers.Transaction_header_id = ' ||p_txn_hdr_rec.Transaction_Header_ID||
                                         'AND EXISTS (SELECT dcca.Transaction_header_id
                                                         FROM DPP_customer_claims_all dcca,
                                                              DPP_TRANSACTION_LINES_GT dtga
                                                        WHERE dcca.Transaction_header_id = '||p_txn_hdr_rec.Transaction_Header_ID||'
                                                          AND dcca.customer_inv_line_id = dtga.transaction_line_id
                                                          AND nvl(dcca.supplier_claim_created,''N'') = ''N''
                                                          AND nvl(dcca.reported_inventory,0) > 0
                                                          AND nvl(dcca.supp_claim_amt,0) > 0)'
                                        );
      dbms_xmlquery.setRowTag(l_queryCtx
                             , 'HEADER'
                             );
      dbms_xmlquery.setRowSetTag(l_queryCtx
                                ,'TRANSACTION'
                                );
      l_input_xml := dbms_xmlquery.getXml(l_queryCtx);
      --Check if the query returns any rows
      l_row_count := dbms_xmlquery.getNumRowsProcessed(l_queryCtx);
      dbms_xmlquery.closeContext(l_queryCtx);

    IF l_row_count >0 THEN
      IF p_txn_hdr_rec.claim_creation_source = 'EXEDTLS' THEN
       --Update the line status to PENDING in the DPP_customer_claims_all table
       UPDATE DPP_customer_claims_all
          SET supplier_claim_created = 'P',
              OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER +1,
              last_updated_by = l_user_id,
              last_update_date = sysdate,
              last_update_login = l_login_id
        WHERE transaction_header_id = p_txn_hdr_rec.Transaction_Header_ID
          AND nvl(supplier_claim_created,'N') = 'N'
          AND nvl(reported_inventory,0) > 0
          AND nvl(supp_claim_amt,0) > 0;

       IF SQL%ROWCOUNT = 0 THEN
           l_return_status := FND_API.G_RET_STS_ERROR;
           DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Unable to Update  the column supplier_claim_created in DPP_customer_claims_all Table');
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --Update those lines to Y which have reported inventory as 0
       UPDATE DPP_customer_claims_all
          SET supplier_claim_created = 'Y',
              OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER +1,
              last_updated_by = l_user_id,
              last_update_date = sysdate,
              last_update_login = l_login_id
        WHERE transaction_header_id = p_txn_hdr_rec.Transaction_Header_ID
          AND nvl(supplier_claim_created,'N') = 'N'
          AND (nvl(reported_inventory,0) = 0 OR nvl(supp_claim_amt,0) <= 0);

     END IF;  --IF p_txn_hdr_rec.claim_creation_source = 'EXEDTLS' THEN
    END IF;
 ELSIF p_txn_hdr_rec.process_code = 'CUSTCL' THEN
   --Generate the Input Xml required for the Business Event -- Create Customer Inventory claim for customer
      l_queryCtx := dbms_xmlquery.newContext('SELECT headers.Transaction_header_id,
                                                headers.Transaction_number,
                                                headers.org_id,
                                                headers.Vendor_id,
                                                headers.Vendor_site_id,'
                                                ||l_user_name|| ' user_name, '
                                                ||l_user_id||'user_id,'
                                                ||l_exe_dtl_id||'Execution_detail_id,'
                                                ||l_claim_type_flag||'claim_type_flag,
                                                headers.trx_currency,
                                 CURSOR(select dcc.customer_inv_line_id transaction_line_id,
                                               dcc.inventory_item_id,
                                               dcc.cust_account_id customer_account_id,
                                               dcc.cust_claim_amt claim_line_amount,
                                               dcc.reported_inventory claim_quantity,
                                               dcc.trx_currency currency,
                                               dcc.UOM
                                          FROM DPP_customer_claims_all dcc,
                                               DPP_TRANSACTION_LINES_GT dtg
                                         WHERE headers.Transaction_header_id = dcc.Transaction_header_id
                                         AND dcc.customer_inv_line_id = dtg.transaction_line_id
                                         AND nvl(dcc.reported_inventory,0) > 0
                                         AND nvl(dcc.cust_claim_amt,0) > 0
                                         AND nvl(dcc.customer_claim_created,''N'') = ''N'') LINES
                                         FROM dpp_transaction_headers_all headers
                                         WHERE headers.Transaction_header_id = ' ||p_txn_hdr_rec.Transaction_Header_ID||
                                         'AND EXISTS (SELECT dcca.Transaction_header_id
                                                         FROM DPP_customer_claims_all dcca,
                                                              DPP_TRANSACTION_LINES_GT dtga
                                                        WHERE dcca.Transaction_header_id = '||p_txn_hdr_rec.Transaction_Header_ID||'
                                                          AND dcca.customer_inv_line_id = dtga.transaction_line_id
                                                          AND nvl(dcca.customer_claim_created,''N'') = ''N''
                                                          AND nvl(dcca.reported_inventory,0) > 0
                                                          AND nvl(dcca.cust_claim_amt,0) > 0)'
                                        );
      dbms_xmlquery.setRowTag(l_queryCtx
                             , 'HEADER'
                             );
      dbms_xmlquery.setRowSetTag(l_queryCtx
                                ,'TRANSACTION'
                                );
      l_input_xml := dbms_xmlquery.getXml(l_queryCtx);
      --Check if the query returns any rows
      l_row_count := dbms_xmlquery.getNumRowsProcessed(l_queryCtx);
      dbms_xmlquery.closeContext(l_queryCtx);

 ELSIF p_txn_hdr_rec.process_code = 'POPCUSTCLAIM' THEN
    --Generate the Input Xml required for the Business Event -- Populate Customer Claim lines details
      l_queryCtx := dbms_xmlquery.newContext('SELECT Transaction_header_id,
                                                Transaction_number,
                                                org_id,
                                                nvl(to_char(effective_start_date-days_covered,''YYYY-MM-DD''),''1900-01-01'' )  EFFECTIVE_START_DATE,
                                                to_char(Effective_start_date,''YYYY-MM-DD'') effective_end_date,
                                                trx_currency,'
                                                ||l_user_name|| ' user_name, '
                                                ||l_user_id||'user_id,'
                                                ||l_exe_dtl_id||'Execution_detail_id,
                                 CURSOR(select transaction_line_id,
                                               inventory_item_id,
                                               UOM
                                          FROM dpp_transaction_lines_all lines
                                         WHERE headers.Transaction_header_id = lines.Transaction_header_id
                                           AND lines.price_change > 0 ) LINES
                                          FROM dpp_transaction_headers_all headers
                                         WHERE headers.Transaction_header_id = ' ||p_txn_hdr_rec.Transaction_Header_ID||
                                         'AND EXISTS (SELECT Transaction_header_id
                                                         FROM dpp_transaction_lines_all
                                                        WHERE price_change > 0
                                                          AND Transaction_header_id = '||p_txn_hdr_rec.Transaction_Header_ID||')'
                                        );
      dbms_xmlquery.setRowTag(l_queryCtx
                             , 'HEADER'
                             );
      dbms_xmlquery.setRowSetTag(l_queryCtx
                                ,'TRANSACTION'
                                );
      l_input_xml := dbms_xmlquery.getXml(l_queryCtx);
      --Check if the query returns any rows
      l_row_count := dbms_xmlquery.getNumRowsProcessed(l_queryCtx);
      dbms_xmlquery.closeContext(l_queryCtx);

  ELSIF p_txn_hdr_rec.process_code = 'POPINVDTLS' THEN
    --Generate the Input Xml required for the Business Event --Populate Inventory Details
      l_queryCtx := dbms_xmlquery.newContext('SELECT Transaction_header_id,
                                                Transaction_number,
                                                org_id,
                                                nvl(to_char(effective_start_date-days_covered,''YYYY-MM-DD''),''1900-01-01'' )  EFFECTIVE_START_DATE,
                                                to_char(Effective_start_date,''YYYY-MM-DD'') effective_end_date,'
                                                ||l_user_name|| ' user_name, '
                                                ||l_user_id||'user_id,'
                                                ||l_exe_dtl_id||'Execution_detail_id,
                                 CURSOR(select transaction_line_id,
                                               inventory_item_id
                                          FROM dpp_transaction_lines_all lines
                                         WHERE headers.Transaction_header_id = lines.Transaction_header_id) LINES
                                         FROM dpp_transaction_headers_all headers
                                         WHERE headers.Transaction_header_id = ' ||p_txn_hdr_rec.Transaction_Header_ID||
                                         'AND EXISTS (SELECT Transaction_header_id
                                                         FROM dpp_transaction_lines_all
                                                        WHERE Transaction_header_id = '||p_txn_hdr_rec.Transaction_Header_ID||')'
                                        );
      dbms_xmlquery.setRowTag(l_queryCtx
                             , 'HEADER'
                             );
      dbms_xmlquery.setRowSetTag(l_queryCtx
                                ,'TRANSACTION'
                                );
      l_input_xml := dbms_xmlquery.getXml(l_queryCtx);
      --Check if the query returns any rows
      l_row_count := dbms_xmlquery.getNumRowsProcessed(l_queryCtx);
      dbms_xmlquery.closeContext(l_queryCtx);
  ELSE
     FND_MESSAGE.set_name('DPP', 'DPP_BUSEVT_INVALID_PRO_CODE');
               fnd_message.set_token('PROCESS_CODE', p_txn_hdr_rec.process_code);
               FND_MSG_PUB.add;
               FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
               RAISE FND_API.g_exc_error;
  END IF;

  --Raise the Workflow Event Procedure for the given process
    Raise_Workflow_Event(
         x_return_status         => l_return_status
        ,x_msg_count             => l_msg_count
        ,x_msg_data              => l_msg_data
    ,p_txn_hdr_id            => p_txn_hdr_rec.Transaction_Header_ID
    ,p_process_code      => p_txn_hdr_rec.process_code
        ,p_input_xml             => l_input_xml
        ,p_row_count             => l_row_count
        ,p_exe_dtl_id            => l_exe_dtl_id
       );

	dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'return status for Raise_Workflow_Event =>'||l_return_status);
   --dpp_utility_pvt.debug_message (FND_LOG.LEVEL_STATEMENT, l_module, substr(('Message data  =>'||l_msg_data),1,4000));

         -- Check return status from the above procedure call
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   x_return_status:= l_return_status;

-- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT;
   END IF;
   FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
           );

--Exception Handling
EXCEPTION
    WHEN FND_API.g_exc_error THEN
       ROLLBACK TO Raise_Business_Event;
       x_return_status := FND_API.g_ret_sts_error;
       FND_MSG_PUB.count_and_get (
             p_encoded => FND_API.g_false,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );

 IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
END IF;

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Raise_Business_Event;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| substr(FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F'),1,254)), 1, 4000);
END LOOP;
END IF;

   WHEN OTHERS THEN
      ROLLBACK TO Raise_Business_Event;
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
               fnd_message.set_token('ROUTINE', 'DPP_BUSINESSEVENTS_PVT');
               fnd_message.set_token('ERRNO', sqlcode);
               fnd_message.set_token('REASON', sqlerrm);
      x_return_status := FND_API.g_ret_sts_unexp_error ;
     IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
        FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
     END IF;
     FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false,
           p_count   => x_msg_count,
           p_data    => x_msg_data
      );

IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
END IF;

END Raise_Business_Event;

---------------------------------------------------------------------
-- PROCEDURE
--    Raise_Workflow_Event
--
-- PURPOSE
--    Raise Workflow Event.
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------
PROCEDURE Raise_Workflow_Event(
     x_return_status     OUT    NOCOPY  VARCHAR2
        ,x_msg_count             OUT    NOCOPY  NUMBER
        ,x_msg_data          OUT    NOCOPY  VARCHAR2

    ,p_txn_hdr_id            IN       NUMBER
    ,p_process_code      IN       VARCHAR2
        ,p_input_xml             IN       CLOB
        ,p_row_count             IN       NUMBER
        ,p_exe_dtl_id            IN       NUMBER
     )
IS
l_api_name               CONSTANT VARCHAR2(30) := 'Raise_Business_Event';
l_event_name            VARCHAR2(60):= 'oracle.apps.dpp.executions';
l_new_item_key          VARCHAR2(30);
l_parameter_list        WF_PARAMETER_LIST_T;
l_target_system         VARCHAR2(4) := 'EBIZ';
l_user_id               NUMBER := FND_GLOBAL.USER_ID;
l_exe_status        VARCHAR2(15) := 'SUBMITTED';
l_event_test            VARCHAR2(10);
l_module                CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_BUSINESSEVENTS_PVT.RAISE_WORKFLOW_EVENT';

BEGIN

x_return_status := FND_API.g_ret_sts_success;
 --------------------- initialize -----------------------
   SAVEPOINT Raise_Workflow_Event;

--Get a unique value for the l_new_item_key key
  l_new_item_key := TO_CHAR(SYSDATE,'DDMMRRRRHH24MISS');
--Check if the event subscription can be raised or not before inserting into the DPP_EXECUTION_DETAILS table
  l_event_test := wf_event.test(l_event_name);
  IF l_event_test = 'NONE' THEN
     DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'No enabled local subscriptions reference the event, or the event does not exist.');
     RAISE FND_API.g_exc_error;
  ELSE
     DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Number of rows Processed : '||p_row_count);

     --Check if the xml has any rows processed and raise the event
     IF p_row_count > 0 THEN
        --Insert a line in to the DPP_EXECUTION_DETAILS table corresponding to the process which has been started
        BEGIN
           INSERT INTO DPP_EXECUTION_DETAILS (EXECUTION_DETAIL_ID,
                                        object_version_number,
                                        TRANSACTION_HEADER_ID,
                                        PROCESS_CODE,
                                        INPUT_XML,
                                        EXECUTION_STATUS,
                                        EXECUTION_START_DATE,
                                        CREATION_DATE,
                                        CREATED_BY,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATED_BY,
                                        LAST_UPDATE_LOGIN)
                                VALUES (p_exe_dtl_id,
                                         1,
                                        p_txn_hdr_id,
                                        p_process_code,
                                        XMLTYPE(p_input_xml),
                                        l_exe_status,
                                        sysdate,
                                        sysdate,
                                        l_user_id,
                                        sysdate,
                                        l_user_id,
                                        l_user_id);

        EXCEPTION
           WHEN OTHERS THEN
              fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
              fnd_message.set_token('ROUTINE', 'DPP_BUSINESSEVENTS_PVT');
              fnd_message.set_token('ERRNO', sqlcode);
              fnd_message.set_token('REASON', sqlerrm);
              FND_MSG_PUB.add;
              IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
                 FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
              END IF;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;
        --Define in WF Attributes l_parameter_list := WF_PARAMETER_LIST_T();
        WF_EVENT.AddParameterToList( p_name            => 'TARGETSYSTEM'
                                   , p_value           => l_target_system
                                   , p_parameterlist   => l_parameter_list
                                   );
        WF_EVENT.AddParameterToList( p_name            => 'FLOWNAME'
                                   , p_value           => p_process_code
                                   , p_parameterlist   => l_parameter_list
                                   );
        WF_EVENT.AddParameterToList( p_name            => 'EXECUTIONDETAILID'
                                   , p_value           => p_exe_dtl_id
                                   , p_parameterlist   => l_parameter_list
                                   );
        WF_EVENT.Raise(p_event_name   =>  l_event_name
                      ,p_event_key    =>  l_new_item_key
                      ,p_event_data   =>  p_input_xml
                      ,p_parameters   =>  l_parameter_list
                      ,p_send_date    =>  sysdate
                      );

        DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Work Flow Event Raised');

     ELSE
        DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Work Flow Event is not Raised');
        FND_MESSAGE.set_name('DPP', 'DPP_CC_NO_ELIGIBLE_LINES_MSG');
        FND_MSG_PUB.add;
        RAISE FND_API.g_exc_error;
     END IF;   --p_row_count > 0
  END IF;

EXCEPTION
    WHEN FND_API.g_exc_error THEN
       ROLLBACK TO Raise_Workflow_Event;
       x_return_status := FND_API.g_ret_sts_error;
       FND_MSG_PUB.count_and_get (
             p_encoded => FND_API.g_false,
             p_count   => x_msg_count,
             p_data    => x_msg_data
         );
      IF x_msg_count > 1 THEN
         FOR I IN 1..x_msg_count LOOP
            x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
         END LOOP;
     END IF;

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Raise_Workflow_Event;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );
      IF x_msg_count > 1 THEN
         FOR I IN 1..x_msg_count LOOP
            x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
         END LOOP;
     END IF;

   WHEN OTHERS THEN
      ROLLBACK TO Raise_Workflow_Event;
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
               fnd_message.set_token('ROUTINE', 'DPP_BUSINESSEVENTS_PVT');
               fnd_message.set_token('ERRNO', sqlcode);
               fnd_message.set_token('REASON', sqlerrm);
               FND_MSG_PUB.add;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
     IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
        FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
     END IF;
     FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false,
           p_count   => x_msg_count,
           p_data    => x_msg_data
         );
      IF x_msg_count > 1 THEN
         FOR I IN 1..x_msg_count LOOP
            x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
         END LOOP;
     END IF;

END Raise_Workflow_Event;

END DPP_BUSINESSEVENTS_PVT;


/
