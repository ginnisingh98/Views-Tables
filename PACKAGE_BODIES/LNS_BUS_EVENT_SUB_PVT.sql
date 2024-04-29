--------------------------------------------------------
--  DDL for Package Body LNS_BUS_EVENT_SUB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_BUS_EVENT_SUB_PVT" AS
/* $Header: LNS_BUS_EVENT_B.pls 120.3 2006/07/31 23:37:47 karamach noship $ */

/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
    G_PKG_NAME CONSTANT VARCHAR2(30):= 'LNS_BUS_EVENT_SUB_PVT';
    G_LOG_ENABLED                   varchar2(5);
    G_MSG_LEVEL                     NUMBER;


/*========================================================================
 | PRIVATE PROCEDURE LogMessage
 |
 | DESCRIPTION
 |      This procedure logs debug messages to db and to CM log
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      Delinquency_Create
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | PARAMETERS
 |      p_msg_level     IN      Debug msg level
 |      p_msg           IN      Debug msg itself
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 01-01-2004            scherkas          Created
 |
 *=======================================================================*/
Procedure LogMessage(p_msg_level IN NUMBER, p_msg in varchar2)
IS
BEGIN
    if (p_msg_level >= G_MSG_LEVEL) then

        FND_LOG.STRING(p_msg_level, G_PKG_NAME, p_msg);

    end if;

EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR in LogMessage: ' || sqlerrm);
END;




/*========================================================================
 | PUBLIC FUNCTION Delinquency_Create
 |
 | DESCRIPTION
 |      This function processes oracle.apps.iex.delinquency.create event
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      p_subscription_guid     IN          Standard in parameter
 |      p_event         		IN          Standard in parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 01-01-2004            scherkas          Created
 |
 *=======================================================================*/
FUNCTION Delinquency_Create(p_subscription_guid In RAW, p_event IN OUT NOCOPY WF_EVENT_T)RETURN VARCHAR2
IS
/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name                      CONSTANT VARCHAR2(30) := 'Delinquency_Create';
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_status                        varchar2(30);
    l_loan_number                   varchar2(60);
    l_loan_id                       number;
    l_version_number                number;
    l_loan_header_rec               LNS_LOAN_HEADER_PUB.loan_header_rec_type;
    l_score                         number;
    l_index                         number := 0;
    l_indexNo                       number := 1;
    l_msg                           varchar2(4000) := null;
    l_org_id                        number;
    l_request_id                    number;
    l_num_del_cr                    number;
    l_num_del_upd                   number;
    l_count                         number;
    l_amortization_schedule_id      number;
    l_cust_trx_id                   number;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    /* query for loans trx */
    CURSOR loan_trx_cur(P_REQUEST_ID number) IS
        select ams.LOAN_ID,
            loan.loan_number,
            loan.org_id,
            ams.AMORTIZATION_SCHEDULE_ID,
            del.transaction_id
        from
            lns_loan_headers_all loan,
            lns_amortization_scheds ams,
            IEX_DELINQUENCIES_ALL del
        where
        	del.request_id = P_REQUEST_ID and
        	del.transaction_id in (ams.PRINCIPAL_TRX_ID, ams.INTEREST_TRX_ID, ams.FEE_TRX_ID) and
            ams.loan_id = loan.loan_id;

    -- getting loan version
    CURSOR loan_version_cur(P_LOAN_ID number) IS
        select OBJECT_VERSION_NUMBER
        from LNS_LOAN_HEADERS_ALL
        where LOAN_ID = P_LOAN_ID;

BEGIN
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'Received event ' || p_event.getEventName());

    /* Established savepoint */
    SAVEPOINT Delinquency_Create;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Established savepoint');

    l_request_id := p_event.GetValueForParameter('REQUEST_ID');
    l_num_del_cr := p_event.GetValueForParameter('NOOFDELCREATED');
    l_num_del_upd := p_event.GetValueForParameter('NOOFDELUPDATED');

    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'Event parameters:');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, 'request id: ' || l_request_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'number of created del: ' || l_num_del_cr);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'number of updated del: ' || l_num_del_upd);

    if l_request_id is not null then

        l_count := 0;

        /* query for loans trx */
        open loan_trx_cur(to_number(l_request_id));
        LOOP

            fetch loan_trx_cur into l_loan_id,
                                    l_loan_number,
                                    l_org_id,
                                    l_amortization_schedule_id,
                                    l_cust_trx_id;
            exit when loan_trx_cur%NOTFOUND;

            l_count := l_count + 1;
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Found trx #' || l_count);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'cust_trx_id: ' || l_cust_trx_id);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'amortization_schedule_id: ' || l_amortization_schedule_id);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_id: ' || l_loan_id);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_number: ' || l_loan_number);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'org_id: ' || l_org_id);

            /* calling scoring engine to get new loan status */
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling collections scoring engine to get new loan status...');

            BEGIN

                MO_GLOBAL.INIT('LNS');
                MO_GLOBAL.set_policy_context('S', l_org_id);

                IEX_SCOREAPI_PUB.GETSCORESTATUS(
                    P_API_VERSION => 1.0,
                    P_INIT_MSG_LIST => FND_API.G_TRUE,
                    P_SCORE_ID => 8,    -- hardcoded value from collections seeded data
                    P_OBJECT_ID => l_loan_id,
                    X_STATUS => l_status,
                    X_SCORE =>  l_score,
                    X_RETURN_STATUS => l_return_status,
                    X_MSG_COUNT => l_msg_count,
                    X_MSG_DATA  => l_msg_data);

            EXCEPTION
                WHEN OTHERS  THEN
                    LogMessage(FND_LOG.LEVEL_ERROR, 'Collections scoring engine API is not installed. Please install it first.');
                    RAISE FND_API.G_EXC_ERROR;
            END;

            LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Call to collections scoring engine failed with following error:');
                while (l_indexNo <= l_msg_Count ) loop
                    fnd_msg_pub.get(l_indexNo, 'F', l_msg, l_index);
                    LogMessage(FND_LOG.LEVEL_UNEXPECTED, l_msg);
                    l_indexNo := l_indexNo + 1;
                End Loop;

                RAISE FND_API.G_EXC_ERROR;

            END IF;

            LogMessage(FND_LOG.LEVEL_STATEMENT, 'New score: ' || l_score);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'New status: ' || l_status);

            -- updating loan header table
            l_loan_header_rec.loan_id := l_loan_id;
            l_loan_header_rec.LOAN_STATUS := l_status;

            -- getting loan version
            open loan_version_cur(l_loan_header_rec.loan_id);
            fetch loan_version_cur into l_version_number;
            close loan_version_cur;

            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating loan header...');

            LNS_LOAN_HEADER_PUB.UPDATE_LOAN(P_OBJECT_VERSION_NUMBER => l_version_number,
                                            P_LOAN_HEADER_REC => l_loan_header_rec,
                                            P_INIT_MSG_LIST => FND_API.G_TRUE,
                                            X_RETURN_STATUS => l_return_status,
                                            X_MSG_COUNT => l_msg_count,
                                            X_MSG_DATA => l_msg_data);

            LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);

            IF l_return_status = 'S' THEN
                LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully update LNS_LOAN_HEADERS_ALL with status ' || l_status);
            ELSE
                FND_MESSAGE.SET_NAME('LNS', 'LNS_UPD_LOAN_FAIL');
                FND_MSG_PUB.Add;
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END LOOP;

        close loan_trx_cur;

    end if;

    -- commiting
    if l_count > 0 then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited');
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Total processed ' || l_count || ' transactions');
    else
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'No loan invoices found - no actions will be performed');
    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully processed event ' || p_event.getEventName());
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');
    RETURN 'SUCCESS';

 EXCEPTION
    WHEN OTHERS  THEN
        ROLLBACK TO Delinquency_Create;

        WF_CORE.CONTEXT('LNS_BUS_EVENT_SUB_PVT', 'Delinquency_Create', p_event.getEventName(), p_subscription_guid);
        WF_EVENT.setErrorInfo(p_event, 'ERROR');
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Failed to process event ' || p_event.getEventName());

        RETURN 'ERROR';

END Delinquency_Create;


BEGIN

    G_LOG_ENABLED := 'N';
    G_MSG_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    /* getting msg logging info */
    G_LOG_ENABLED := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'), 'N');
    /*
    if (G_LOG_ENABLED = 'N') then
       G_MSG_LEVEL := FND_LOG.LEVEL_UNEXPECTED;
    else
       G_MSG_LEVEL := NVL(to_number(FND_PROFILE.VALUE('AFLOG_LEVEL')), FND_LOG.LEVEL_UNEXPECTED);
    end if;
    */
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'G_LOG_ENABLED: ' || G_LOG_ENABLED);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'G_MSG_LEVEL: ' || G_MSG_LEVEL);

END LNS_BUS_EVENT_SUB_PVT; -- Package body

/
