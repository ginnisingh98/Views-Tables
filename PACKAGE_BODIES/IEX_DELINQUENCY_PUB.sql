--------------------------------------------------------
--  DDL for Package Body IEX_DELINQUENCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_DELINQUENCY_PUB" AS
/* $Header: iexpdelb.pls 120.14.12010000.8 2010/02/19 11:13:28 pnaveenk ship $ */

G_PKG_NAME   CONSTANT VARCHAR2(30):= 'IEX_DELINQUENCY_PUB';
G_FILE_NAME  CONSTANT VARCHAR2(12) := 'iexpdelb.pls';
G_USER_ID    NUMBER := FND_GLOBAL.User_Id;

--
-- Begin - 01/24/2005 - Andre Araujo - This procedure uses a memory schema uses up all memory available for the session, changing it to chunks
--
--G_Batch_Size NUMBER := to_number(nvl(fnd_profile.value('IEX_BATCH_SIZE'), '1000'));
G_Batch_Size NUMBER := to_number(nvl(fnd_profile.value('IEX_BATCH_SIZE'), '100000'));
--
-- End - 01/24/2005 - Andre Araujo - This procedure uses a memory schema uses up all memory available for the session, changing it to chunks
--

-- CONSTANTS FOR FINAL VALUES. (Delinquency statuses)
vf_delinquent       CONSTANT varchar2(30) := 'DELINQUENT';
vf_predelinquent    CONSTANT varchar2(30) := 'PREDELINQUENT';
vf_current          CONSTANT varchar2(30) := 'CURRENT';

l_api_version_number    CONSTANT NUMBER   := 1.0;

    v_line   varchar2(100)  ;
    PG_DEBUG NUMBER ;

/*
|| Overview:  Clean up delinquency_buffers table
||
|| Parameter:  None
||
|| Source Tables:  None
||
|| Target Tables:  IEX_DEL_BUFFERS
||
|| Creation date:  03/15/02 3:29:PM
||
|| Major Modifications: when             who                what
||                      03/15/02 3:29:PM raverma            created
*/
--PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
--Added this function for bug#7133605 by schekuri on 17-Jun-2008 -- Added by PNAVEENK
FUNCTION isRefreshProgramsRunning RETURN BOOLEAN IS
CURSOR C1 IS
select request_id
from AR_CONC_PROCESS_REQUESTS
where CONCURRENT_PROGRAM_NAME in ('ARSUMREF','IEX_POPULATE_UWQ_SUM');
l_request_id  number;
BEGIN

OPEN C1;

  FETCH C1 INTO l_request_id;

  IF C1%NOTFOUND THEN
   return false;
  ELSE
   return true;
  END IF;

CLOSE C1;

END isRefreshProgramsRunning;
--End PNAVEENK
procedure CLEAR_DEL_BUFFERS(ERRBUF       OUT NOCOPY     VARCHAR2,
                            RETCODE      OUT NOCOPY     VARCHAR2)

is
begin

    RETCODE := 0;
    --SAVEPOINT CLEAN_DEL_BUFFERS_PVT;
    RETCODE := FND_API.G_RET_STS_SUCCESS;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.logMessage('CLEAR_DEL_BUFFERS: ' || 'IEX_DEL_PUB: cleaning del buffers');
    END IF;
    --
    -- Begin - 01/25/2005 - Andre Araujo - This will cause the temp tables space to blow up changing it...
    --
    CLEAR_BUFFERS2(-1);
    --Delete
    --  from IEX_DEL_BUFFERS;
    --
    -- End - 01/25/2005 - Andre Araujo - This will cause the temp tables space to blow up changing it...
    --

    COMMIT;

    Exception
         When others then
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.logMessage('CLEAR_DEL_BUFFERS: ' || 'IEX_DEL_PUB: cleaning failed due to ' || sqlerrm);
            END IF;
            RETCODE := -1;
            ERRBUF := sqlerrm;

end CLEAR_DEL_BUFFERS;

/* This procedure will take a tbl of delinquencies and close them.
   If the p_validate = 'Y', then the procedure will attempt to
   validate ALL closures of delinquencies before close
   if p_validate = 'N' then the procedure will close all delinquencies
   without any validations.

   Logic:
    1. Call IEX_PAYMENT_BATCH_PUB.Close_Inv_Promises
    2. Call Close Dunnings
    3. Update IEX_DELIQUENCIES_ALL table
 */
PROCEDURE Close_Delinquencies(p_api_version         IN  NUMBER,
                              p_init_msg_list       IN  VARCHAR2 ,
                              p_payments_tbl        IN  IEX_PAYMENTS_BATCH_PUB.CL_INV_TBL_TYPE,
                              p_security_check      IN  VARCHAR2,
                              x_return_status       OUT NOCOPY VARCHAR2,
                              x_msg_count           OUT NOCOPY NUMBER,
                              x_msg_data            OUT NOCOPY VARCHAR2)
IS
    l_return_status      VARCHAR2(1);
    --l_api_name           VARCHAR2(50)  := 'Close_Delinquencies';
    l_api_version        NUMBER := 1.0;
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(4000);

    l_num_payments       NUMBER;
    l_del_tbl  IEX_DUNNING_PUB.DELID_NUMLIST;
    l_del_id   number;
    nCount     number;
    l_delinquency_tbl IEX_DELINQUENCY_PUB.DELINQUENCY_TBL_TYPE;

    i  NUMBER;
    j  NUMBER;

BEGIN
  NULL;
/*
      -- Standard Start of API savepoint
      SAVEPOINT Close_Delinquencies_PVT;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean(p_init_msg_list)
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
     IEX_DEBUG_PUB.LogMessage(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'PVT: ' || l_api_name || ' start');

      --
      -- API body
      --

      l_num_payments := p_payments_tbl.count;

      IEX_DEBUG_PUB.LogMessage(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Calling Process Inv Payments');
      IEX_PROMISES_BATCH_PUB.CLOSE_PROMISES(P_API_VERSION         => l_api_version,
                                            P_INIT_MSG_LIST       => FND_API.G_FALSE,
                                            P_COMMIT              => FND_API.G_TRUE,
                                            P_VALIDATION_LEVEL    => NULL,
                                            X_RETURN_STATUS       => l_return_status,
                                            X_MSG_COUNT           => l_msg_count,
                                            X_MSG_DATA            => l_msg_data,
                                            P_PAYMENTS_TBL        => p_payments_tbl);

        IEX_DEBUG_PUB.LogMessage(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Process Inv Payments returns ' || l_return_status);

        IF l_return_status <> 'S' THEN
            NULL;
            -- log error
        END IF;

        IEX_DEBUG_PUB.LogMessage(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'pay count is ' || l_num_payments);

        -- get all delinquency IDs to be closed
        IF l_num_payments >= 1 THEN
            FOR i in 1..l_num_payments LOOP

                IEX_DEBUG_PUB.LogMessage(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'before open del cursor');
                select delinquency_id into l_del_id
                from iex_delinquencies
                where payment_schedule_id = p_payments_tbl(i);

                l_del_tbl(i) := l_del_id;

            END LOOP;
        ELSE
             NULL;
        END IF;

        IEX_DEBUG_PUB.LogMessage(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'callling close dunnings');

        -- here we will call crystal's API to Close_Dunnings
        IEX_DUNNING_PUB.Close_Dunning(p_api_version         => l_api_version
                                      ,p_init_msg_list      => FND_API.G_FALSE
                                      ,p_commit             => FND_API.G_TRUE
                                      ,p_delinquencies_tbl  => l_del_tbl
                                      ,p_security_check     => 'N'
                                      ,x_return_status      => l_return_status
                                      ,x_msg_count          => l_msg_count
                                      ,x_msg_data           => l_msg_data);

        IEX_DEBUG_PUB.LogMessage(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Close dunning returns ' || l_return_status);

        IF l_return_status <> 'S' THEN
            NULL;
            -- log error
        END IF;

        IEX_DEBUG_PUB.LogMessage(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'before update');

        -- now update the delinquencies table
        nCount := l_del_tbl.count;

        if nCount >= 1 then
            FORALL j in 1..nCount
                UPDATE IEX_DELINQUENCIES_ALL
                   SET STATUS='CLOSE',
                   DUNN_YN='N',
                   LAST_UPDATE_DATE=sysdate
                WHERE DELINQUENCY_ID = l_del_tbl(j);

        end if;

        IEX_DEBUG_PUB.LogMessage(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'after update');
        COMMIT;

        x_return_status := l_return_status;

      --
      -- End of API body
      --

      -- Debug Message
     IEX_DEBUG_PUB.LogMessage(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'PVT: ' || l_api_name || ' end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                    P_API_NAME => L_API_NAME
                   ,P_PKG_NAME => G_PKG_NAME
                   ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                   ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                   ,X_MSG_COUNT => X_MSG_COUNT
                   ,X_MSG_DATA => X_MSG_DATA
                   ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                    P_API_NAME => L_API_NAME
                   ,P_PKG_NAME => G_PKG_NAME
                   ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                   ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                   ,X_MSG_COUNT => X_MSG_COUNT
                   ,X_MSG_DATA => X_MSG_DATA
                   ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                    P_API_NAME => L_API_NAME
                   ,P_PKG_NAME => G_PKG_NAME
                   ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                   ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                   ,X_MSG_COUNT => X_MSG_COUNT
                   ,X_MSG_DATA => X_MSG_DATA
                   ,X_RETURN_STATUS => X_RETURN_STATUS);
*/
END Close_Delinquencies;


/** -jsanju 09/15/05
 * obsolete the concurrent pgm and raise the event
 * for every concurrent request launced to determine delinquencies.
 *Raises an event for every concurrent request
 *parameters passed to the event, so that other team can subscribe to that
 *REQUEST_ID -- request id of the concurrent program which created/update the
               --delinquencies
 *NOOFDELCREATED    -number of delinquencies created
 *NOOFDELUPDATED    -number of delinquencies updated
 **/

PROCEDURE  RAISE_EVENT(
           P_REQUEST_ID                 IN  NUMBER,
           p_del_create_count           IN  NUMBER,
           p_del_update_count           IN  NUMBER,
           X_Return_Status              OUT  NOCOPY  VARCHAR2,
           X_Msg_Count                  OUT  NOCOPY  NUMBER,
           X_Msg_Data                   OUT  NOCOPY  VARCHAR2) IS



   l_parameter_list        wf_parameter_list_t;
   l_key                   VARCHAR2(240);
   l_seq                   NUMBER;
   l_event_name            varchar2(240) := 'oracle.apps.iex.delinquency.create';
   l_evt_ctr               NUMBER ;

   l_request_id            NUMBER;
   l_del_create_count      NUMBER;
   l_del_update_count      NUMBER;
   l_return_status      VARCHAR2(1);
BEGIN

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        l_request_id        :=p_request_id;
        l_del_create_count  := p_del_create_count ;
        l_del_update_count  := p_del_update_count ;
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.logMessage( 'Start Raise Delinquency Event Concurrent program');
           IEX_DEBUG_PUB.logMessage('Program Run Date:'||SYSDATE);
        END IF;


           select iex_del_wf_s.nextval INTO l_seq from dual;
           l_key := l_event_name  ||'-'||l_request_id || '-'||l_seq;
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              IEX_DEBUG_PUB.logMessage(' EVENT KEY ' ||l_key );
              IEX_DEBUG_PUB.logMessage(
                                    ' request_id ='            ||l_request_id
                                   ||'No of Del Created = '    ||l_del_create_count
                                   ||'No of Del Updated ='     ||l_del_update_count
                                   );

           END IF;


           wf_event.AddParameterToList('REQUEST_ID',
                                  to_char(l_request_id),
                                  l_parameter_list);
           wf_event.AddParameterToList('NOOFDELCREATED',
                                  to_char(l_del_create_count),
                                  l_parameter_list);
           wf_event.AddParameterToList('NOOFDELUPDATED',
                                   to_char(l_del_update_count),
                                   l_parameter_list);

           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              IEX_DEBUG_PUB.logMessage(' Before Launching Event ');
           END IF;

          wf_event.raise(p_event_name  => l_event_name
                         ,p_event_key  => l_key
                         ,p_parameters  => l_parameter_list);

          COMMIT ;

         l_parameter_list.DELETE;

          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             IEX_DEBUG_PUB.logMessage( 'End Raise Delinquency Event  program');
          END IF;

         -- Standard call to get message count and if count is 1, get message info.
         FND_MSG_PUB.Count_And_Get
          (  p_count          =>   x_msg_count,
             p_data           =>   x_msg_data
          );

EXCEPTION
    WHEN OTHERS THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          IEX_DEBUG_PUB.logMessage('Raise Delinquency Event Concurrent program raised exception '
          || sqlerrm);
       END IF;
       x_msg_count := 1 ;
       x_msg_data  := sqlerrm ;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                  p_data    => x_msg_data);

END RAISE_EVENT;



/*------------------------------------------------------------------------
------------------------------------------------------------------------
        11.5.7  Modified Delinquency Creation Process
------------------------------------------------------------------------
------------------------------------------------------------------------ */
PROCEDURE MANAGE_DELINQUENCIES (ERRBUF       OUT NOCOPY VARCHAR2,
                                RETCODE      OUT NOCOPY VARCHAR2,
                                p_request_id IN  Number)
    IS

    -- All Delinquency Declarations
        vt_del_id       IEX_UTILITIES.t_del_id;
        vt_del_status   t_buf_status;
        vt_buf_status   t_buf_status;
        vt_pmt_schd_id  IEX_UTILITIES.t_numbers ;
        vt_case_id      IEX_UTILITIES.t_numbers ;
        vt_contract_id  IEX_UTILITIES.t_numbers ;
        vt_wf_del_id    IEX_UTILITIES.t_del_id;

        v_today     date;
        v_object    IEX_DEL_BUFFERS.SCORE_OBJECT_CODE%TYPE;
        v_score     Number;

        -- 0 Indicates non existence of range and 1 indicates the existence
        v_score_range   Number := 0 ;

        v_org_id    iex_delinquencies_all.org_id%TYPE;
        v_user_id   Number;
        v_count     Number := 1;

        -- Debug Variables. Remove after unit testing
        i   number;


    -- standard Stuff
        l_return_status   VARCHAR2(10);
        l_msg_count       NUMBER;
        l_msg_data        VARCHAR2(1000);

      l_source_module     VARCHAR2(100) ;

      -- Added for bug fix 3090360
      l_enable_business_events varchar2(10) ;
      l_business_event_req_id Number ;

      l_del_insert_count    Number := 0 ;
      l_del_update_count    Number := 0 ;

      /***************************************************************
                        Debug Declarations
      ****************************************************************/
      v_debug_level Number := 20 ;

      CURSOR dbg_test
      is
                  SELECT
                        HZCA.cust_Account_id,
                        ARPS.customer_trx_id,
                        IDB.score_object_id,
                        IDS.del_status
                    FROM HZ_CUST_ACCOUNTS   HZCA,
                         IEX_DEL_BUFFERS     IDB,
                         AR_PAYMENT_SCHEDULES    ARPS,
                         IEX_DEL_STATUSES        IDS
                    WHERE
                    NOT EXISTS
                        (Select 1
                         from iex_delinquencies
                         where payment_schedule_id = idb.score_object_id)
                        AND NOT EXISTS
                        (select 1
                         from dual
                         where IDS.del_status = vf_current)
                     AND   HZCA.cust_account_id   = ARPS.customer_id
                     AND   ARPS.payment_schedule_id = IDB.score_object_id
                     AND   IDB.score_value between
                                IDS.score_value_low and IDS.score_value_high
                     AND IDB.score_id = IDS.score_id
                     AND IDB.request_id = p_request_id
                     ORDER By IDB.score_object_id;

        dbg_cust        Number;
        dbg_trx         Number;
        dbg_object_id   Number;
        dbg_status      varchar2(30);

    --
    -- Begin - 01/24/2005 - Andre Araujo - This procedure uses a memory schema uses up all memory available for the session, changing it to chunks
    --
    Cursor c_scores(p_request_id NUMBER, p_delinquent varchar2, p_predelinquent varchar2) is
    SELECT
        id.delinquency_id,
        ids.del_status buf_status,
        id.status del_status,
        id.payment_schedule_id
    FROM iex_delinquencies id,
        iex_del_buffers idb,
        iex_del_statuses ids
    where NOT EXISTS
        (select 1
        from dual
        where id.status = ids.del_status)
       and idb.score_id = ids.score_id
       and idb.score_value between ids.score_value_low
       and ids.score_value_high
       and idb.score_object_id =  id.payment_schedule_id
       and idb.request_id = p_request_id;

    --
    -- End - 01/24/2005 - Andre Araujo - This procedure uses a memory schema uses up all memory available for the session, changing it to chunks
    --
 --Bug5237039. Fix By LKKUMAR on 28-Aug-2006. Start.
    CURSOR c_cust_account_id_1 IS
     SELECT DISTINCT CUST_ACCOUNT_ID FROM AR_TRX_BAL_SUMMARY ARS,
     AR_SYSTEM_PARAMETERS ARP
     WHERE ARS.REFERENCE_1 IS Null
     AND ARS.ORG_ID   = ARP.ORG_ID
     AND EXISTS (SELECT 1 FROM IEX_DELINQUENCIES_ALL IED WHERE
                  IED.STATUS IN ('DELINQUENT', 'PREDELINQUENT')
                  AND ARS.CUST_ACCOUNT_ID = IED.CUST_ACCOUNT_ID
                  AND ARS.ORG_ID = IED.ORG_ID);

    CURSOR c_cust_account_id_n IS
     SELECT DISTINCT CUST_ACCOUNT_ID FROM AR_TRX_BAL_SUMMARY ARS,
     AR_SYSTEM_PARAMETERS ARP
     WHERE ARS.REFERENCE_1 = 1
     AND ARS.ORG_ID = ARP.ORG_ID
     AND  NOT EXISTS (SELECT 1 FROM IEX_DELINQUENCIES_ALL IED WHERE
                 IED.STATUS IN ('DELINQUENT', 'PREDELINQUENT')
                 AND ARS.CUST_ACCOUNT_ID = IED.CUST_ACCOUNT_ID
 	         AND ARS.ORG_ID = IED.ORG_ID);

    TYPE cust_account_id_list_1    is TABLE of NUMBER INDEX BY BINARY_INTEGER;
    TYPE cust_account_id_list_n    is TABLE of NUMBER INDEX BY BINARY_INTEGER;

    l_cust_account_id_1 cust_account_id_list_1;
    l_cust_account_id_n cust_account_id_list_n;
    --Bug5237039. Fix By LKKUMAR on 28-Aug-2006. End.


 --jsanju 09/19/05 , set concurrent status to 'WARNING if business event fails'
   request_status BOOLEAN;
   x_errbuf varchar2(240);
   x_retcode varchar2(240);

    BEGIN



      l_source_module := 'IEX_SCORE_NEW_PVT' ;
      l_enable_business_events := FND_PROFILE.VALUE('IEX_ENABLE_CUST_STATUS_EVENT') ;

--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || v_line);
        END IF;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LOGMESSAGE('---------->> PROCEDURE MANAGE_DELINQUENCIES Start <<----------');
        END IF;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || v_line);
        END IF;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.logMessage('MANAGE_DELINQUENCIES: ' || 'Start time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
        END IF;


        RETCODE := 0 ;
        SAVEPOINT del_sp ;

        -- Perform Updates First
        -- Get all the Existing Delinquency Statuses that are Pre-Delinquent
        -- A Direct Update can be performed over them.

        -- Selects all the existing delinquencies for a particular scoring Engine
        -- that are having the Status PREDELINQUENT or the same status as before.
        -- This way All the newly found statuses can be updated without any
        -- verifications.

        Begin
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.logMessage('MANAGE_DELINQUENCIES: ' || 'finding bridge ' || p_request_id);
            END IF;
            SELECT  score_object_code,
                        score_id
              INTO      v_object,
                        v_score
            FROM    iex_del_buffers
            WHERE   request_id = p_request_id
            AND     rownum = 1 ;

--              IF PG_DEBUG < 10  THEN
              IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                 IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || v_line);
              END IF;
--              IF PG_DEBUG < 10  THEN
              IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                 IEX_DEBUG_PUB.LOGMESSAGE
            ('MANAGE_DELINQUENCIES: ' || 'Object >> ' || v_object || '    Score Id  >>  ' || v_score);
              END IF;
--              IF PG_DEBUG < 10  THEN
              IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                 IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || v_line);
              END IF;
        Exception
            WHEN NO_DATA_FOUND then
                ERRBUF := ' No Data Found on IEX_DEL_BUFFERS Table for the Passed Request Id...> '
                                                || to_char(p_Request_id) ;
                RETCODE := 1;
--                IF PG_DEBUG < 10  THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || ERRBUF);
                END IF;
                ROLLBACK TO del_sp;

--                IF PG_DEBUG < 10  THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || v_line);
                END IF;
--                IF PG_DEBUG < 10  THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   IEX_DEBUG_PUB.LOGMESSAGE
            ('---------->> PROCEDURE MANAGE_DELINQUENCIES End (returned) <<--------');
                END IF;
--                IF PG_DEBUG < 10  THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || v_line);
                END IF;
                return ;
        End ;

--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || 'Score Id = ' || v_score || '  Object Code = ' || v_object);
        END IF;

        Select  --fnd_profile.value('ORG_ID'), --Commneted for MOAC
                fnd_profile.value('USER_ID'),
                fnd_profile.value('IEX_DEBUG_LEVEL'),
                sysdate
        into    --v_org_id, --Commneted for MOAC
                v_user_id,
                v_debug_level,
                v_today
        From    dual ;

        Select count(1)
        into v_score_range
        from iex_del_statuses
        where score_id = v_score ;

--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LOGMESSAGE
        ('MANAGE_DELINQUENCIES: ' || 'Org Id = ' || v_org_id || '  Score Range Count = ' || v_score_range);
        END IF;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || 'Debug Level = ' || to_char(v_debug_level));
        END IF;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || v_line);
        END IF;

         -- Everything works only when Score Range is Defined.
         If v_score_range > 0 then
          If v_object = 'IEX_INVOICES' then

            -- Selects All the matching rows between buffer and Delinquencies table
            -- except when the statuses are same or when buffer status is PREDELINQUENT
            -- and delinquency table status is DELINQUENT.
            --
            -- Begin - 01/24/2005 - Andre Araujo - This memory schema uses up all memory available for the session, changing it to chunks
            --
            open c_scores(p_request_id, vf_delinquent, vf_predelinquent);
            LOOP
                FETCH c_scores
                    BULK COLLECT INTO
                        vt_del_id,
                        vt_buf_status,
                        vt_del_status,
                        vt_pmt_schd_id
                    LIMIT G_Batch_Size;

                BEGIN

                    /* 01/24/2005 - Andre Araujo - This memory schema uses up all memory available for the session, changing it to chunks
                    SELECT
                        id.delinquency_id,
                        ids.del_status buf_status,
                        id.status del_status,
                        id.payment_schedule_id
                    BULK COLLECT INTO
                        vt_del_id,
                        vt_buf_status,
                        vt_del_status,
                        vt_pmt_schd_id
                    FROM iex_delinquencies id,
                        iex_del_buffers idb,
                        iex_del_statuses ids
                    where NOT EXISTS
                        (select 1
                         from dual
                -- Begin - Andre Araujo - 12/21/2004 - Remove the pre-del 2 del constraint bug#4072687
                         --where (id.status = vf_delinquent
                         --   and ids.del_status = vf_predelinquent)
                         --   OR id.status = ids.del_status)
                         where id.status = ids.del_status)
                -- End - Andre Araujo - 12/21/2004 - Remove the pre-del 2 del constraint bug#4072687
                    and idb.score_id = ids.score_id
                    and idb.score_value between ids.score_value_low
                    and ids.score_value_high
                    and idb.score_object_id =  id.payment_schedule_id
                    and idb.request_id = p_request_id;

                    */
            --
            -- End - 01/24/2005 - Andre Araujo - This procedure uses a memory schema uses up all memory available for the session, changing it to chunks
            --


                /* =================    Debug Message   ====================*/
--                  IF PG_DEBUG < 10  THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                        IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || 'Row Count after Update Select ');
                    END IF;
--                  IF PG_DEBUG < 10  THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                        IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || v_line);
                    END IF;

                    if v_debug_level <= 10 then
                        for i in 1..vt_del_id.count
                        LOOP
--                          IF PG_DEBUG < 10  THEN
                            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                               IEX_DEBUG_PUB.LOGMESSAGE
                              ('MANAGE_DELINQUENCIES: ' || ' Pmt Schd Id = ' || to_char(vt_pmt_schd_id(i))||
                                ' Delinquency Id = ' || to_char(vt_del_id(i)) ||
                                ' Buf Status = ' || vt_buf_status(i) ||
                                'Del Status = ' || vt_del_status(i));
                            END IF;
                        END LOOP ;
                    End If ;
--                  IF PG_DEBUG < 10  THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                     IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || v_line);
                    END IF;
                 /*=================  Debug Message   ====================== */

                     Exception
                        WHEN OTHERS then
                           ERRBUF := ' FIRST SELECT - Error Code = ' || SQLCODE ||
                                                               ' Error Msg ' || SQLERRM ;
                           RETCODE := -1;
            --               IF PG_DEBUG < 10  THEN
                           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                              IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || ERRBUF);
                           END IF;
                           ROLLBACK TO del_sp;

            --               IF PG_DEBUG < 10  THEN
                           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                              IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || 'Deleting Buffer Table after RollBack due to Error');
                           END IF;


                            --
                            -- Begin - 01/24/2005 - Andre Araujo - This procedure uses a memory schema uses up all memory available for the session, changing it to chunks
                            --
                            CLEAR_BUFFERS2(p_request_id);
                            --DELETE FROM IEX_DEL_BUFFERS
                            --WHERE request_id = p_request_id;

                            --IEX_CONC_REQUEST_MSG_PKG.LOG_ERROR(p_request_id, 'MANAGE_DELINQUENCIES',ERRBUF);
                            --
                            -- End - 01/24/2005 - Andre Araujo - This procedure uses a memory schema uses up all memory available for the session, changing it to chunks
                            --


                            -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
                --            IEX_CONC_REQUEST_MSG_PKG.LOG_ERROR(p_request_id, 'MANAGE_DELINQUENCIES',ERRBUF);
                            -- End - Andre Araujo - 09/30/2004- Remove obsolete logging

            --                IF PG_DEBUG < 10  THEN
                            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                               IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || 'Deletd Buffer Row Count >> '||to_char(SQL%ROWCOUNT));
                            END IF;
            --                IF PG_DEBUG < 10  THEN
                            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                               IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || v_line);
                            END IF;
            --                IF PG_DEBUG < 10  THEN
                            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                               IEX_DEBUG_PUB.LOGMESSAGE
                            ('--->> PROCEDURE MANAGE_DELINQUENCIES End (returned) <<--------');
                            END IF;
            --                IF PG_DEBUG < 10  THEN
                            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                               IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || v_line);
                            END IF;

                            Commit;
                            return;
                    End;

                    Begin
                        -- Once all the Existing PreDelinquent Rows are found then Update them
                        -- UPDATE Phase 1
                        FORALL v_count in 1..vt_del_id.count
                            UPDATE IEX_DELINQUENCIES
                            SET     status = vt_buf_status(v_count),
                                    last_update_date = v_today,
                                    last_updated_by = v_user_id,
                                    dunn_yn = decode(vt_buf_status(v_count), vf_current, 'N'),
                                    object_version_number = object_version_number + 1,
                                    request_id = p_request_id
                            WHERE delinquency_id = vt_del_id(v_count);

                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Number Of Delinquencies Updated..>> '|| vt_del_id.count) ;
                        l_del_update_count := vt_del_id.count ;

                        /* =================    Debug Message   ================== */
        --              IF PG_DEBUG < 10  THEN
                        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                           IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || v_line);
                        END IF;
                        if v_debug_level <= 10 then
                            FOR i in 1..vt_del_id.count
                            LOOP
        --                     IF PG_DEBUG < 10  THEN
                               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                                  IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || 'Rows Updated for ' ||
                                            to_char(vt_del_id(i)) || ' is ' ||
                                                to_char(SQL%BULK_ROWCOUNT(i)));
                               END IF;
                            END LOOP ;
                        End If ;
        --              IF PG_DEBUG < 10  THEN
                        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                           IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || v_line);
                        END IF;
                        /* ================= Debug Message   =========================== */

                        Exception
                            WHEN OTHERS then

                                ERRBUF := 'INVOICE - Matching Delinquencies Update --> Error Code '
                                        || SQLCODE  || ' Error Mesg ' ||  SQLERRM ;
                                RETCODE := -1;
                --                  IF PG_DEBUG < 10  THEN
                                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                                   IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || ERRBUF);
                                END IF;
                                ROLLBACK TO del_sp ;

                --                  IF PG_DEBUG < 10  THEN
                                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                                   IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || 'Deleting Buffer Table after RollBack due to Error');
                                END IF;

                                --
                                -- Begin - 01/24/2005 - Andre Araujo - This procedure uses a memory schema uses up all memory available for the session, changing it to chunks
                                --

                                CLEAR_BUFFERS2(p_request_id);

                                --DELETE FROM IEX_DEL_BUFFERS
                                --WHERE request_id = p_request_id ;

                                --IEX_CONC_REQUEST_MSG_PKG.LOG_ERROR(p_request_id, 'MANAGE_DELINQUENCIES',ERRBUF) ;
                                --
                                -- End - 01/24/2005 - Andre Araujo - This procedure uses a memory schema uses up all memory available for the session, changing it to chunks
                                --

                --                IF PG_DEBUG < 10  THEN
                                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                                   IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || 'Deleted Buffer Row Count >> ' || to_char(SQL%ROWCOUNT));
                                END IF;
                --              IF PG_DEBUG < 10  THEN
                                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                                   IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || v_line);
                                END IF;
                --                IF PG_DEBUG < 10  THEN
                                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                                   IEX_DEBUG_PUB.LOGMESSAGE('--->> PROCEDURE MANAGE_DELINQUENCIES End (returned) <<--------');
                                END IF;
                --              IF PG_DEBUG < 10  THEN
                                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                                   IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || v_line);
                                END IF;

                                Commit;
                                return;
                    End;


                    /* =================    Debug Message   ===========================*/
                    Begin
                        if v_debug_level < 11 then
                            Open dbg_test ;

            --              IF PG_DEBUG < 10  THEN
                            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                               IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || '--------- Insert Candidate Rows ----------');
                            END IF;
            --              IF PG_DEBUG < 10  THEN
                            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                               IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || '----cust----pmt schd----status----');
                            END IF;

                            LOOP
                                FETCH dbg_test
                                into
                                dbg_cust        ,
                                dbg_trx         ,
                                dbg_object_id   ,
                                dbg_status       ;

                                EXIT WHEN dbg_test%NOTFOUND ;

            --                  IF PG_DEBUG < 10  THEN
                                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                                   IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || to_char(dbg_cust) || ' ---- ' ||
                                         to_char(dbg_object_id) || ' ---- ' ||dbg_status);
                                END IF;
                            END LOOP ;

                            CLOSE dbg_test ;
                        End If ;
                    Exception
                        when others then
                            close dbg_test ;
                    End ;
                    /* =================    Debug Message   =========================*/


                         -- clchang updated 04/18/2003 for BILL_TO
                         -- get customer_site_use_id from ar_payment_schedules

                     Begin
                            -- Simple Insert for Payment Schedule Id
                            INSERT INTO IEX_DELINQUENCIES_ALL
                                    ( DELINQUENCY_ID        ,
                                    LAST_UPDATE_DATE        ,
                                    LAST_UPDATED_BY         ,
                                    CREATION_DATE           ,
                                    CREATED_BY              ,
                                    OBJECT_VERSION_NUMBER   ,
                                    DUNN_YN         ,
                                    PARTY_CUST_ID           ,
                                    CUST_ACCOUNT_ID         ,
                                    CUSTOMER_SITE_USE_ID    , -- added by clchang for bill_to
                                    TRANSACTION_ID          ,
                                    PAYMENT_SCHEDULE_ID     ,
                                    STATUS                  ,
                                    ORG_ID                  ,
                                    SOURCE_PROGRAM_NAME     ,
                                    SCORE_ID                ,
                                    SCORE_VALUE             ,
                                    REQUEST_ID              )
                                SELECT
                                    IEX_DELINQUENCIES_S.NEXTVAL ,
                                    v_today,
                                    v_user_id,
                                    v_today,
                                    v_user_id,
                                    1     ,
                                    'Y'   ,
                                    HZCA.party_id       ,
                                    HZCA.cust_Account_id    ,
                                    ARPS.customer_site_use_id    , -- added by clchang for bill_to
                                    ARPS.customer_trx_id    ,
                                    IDB.score_object_id ,
                                    IDS.del_status      ,
            --                        v_org_id        ,
            --jsanju for bug 3581105
            --get payment schedule org ID
                                    ARPS.org_id,
                                    l_source_module     ,
                                    IDB.score_id        ,
                                    IDB.score_value     ,
                                    p_Request_id
                                FROM HZ_CUST_ACCOUNTS   HZCA    ,
                                     IEX_DEL_BUFFERS     IDB ,
                                     AR_PAYMENT_SCHEDULES    ARPS    ,
                                     IEX_DEL_STATUSES        IDS
                                WHERE
                                NOT EXISTS
                                    (Select 1
                                     from iex_delinquencies_all --added by barathsr for bug#7366451 10-Oct-08
				     --iex_delinquencies
                                     where payment_schedule_id = idb.score_object_id)
                                AND NOT EXISTS
                                    (select 1
                                     from dual
                                     where IDS.del_status = vf_current)
                                AND   HZCA.cust_account_id   = ARPS.customer_id
                                AND   ARPS.payment_schedule_id = IDB.score_object_id
                                AND IDB.score_value between
                                            IDS.score_value_low and IDS.score_value_high
                                AND IDB.score_id = IDS.score_id
                                AND IDB.request_id = p_request_id ;


                            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Number Of Delinquencies Created..>> '|| SQL%ROWCOUNT) ;
                            l_del_insert_count := SQL%ROWCOUNT ;

                            /* =================    Debug Message   ==================== */
            --                      IF PG_DEBUG < 10  THEN
                                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                                   IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || v_line);
                                END IF;
            --                      IF PG_DEBUG < 10  THEN
                                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                                   IEX_DEBUG_PUB.LOGMESSAGE
                            ('MANAGE_DELINQUENCIES: ' || 'Number of Rows Inserted --> ' || to_char(SQL%ROWCOUNT));
                                END IF;
            --                      IF PG_DEBUG < 10  THEN
                                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                                   IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || v_line);
                                END IF;
                            /* =================    Debug Message   ==================== */

                        Exception
                            WHEN OTHERS then
                                ERRBUF := 'INSERT - Error Code = ' || SQLCODE || ' Error Msg ' || SQLERRM ;
            --                      IF PG_DEBUG < 10  THEN
                                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                                   IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || ERRBUF);
                                END IF;
                                RETCODE := -1 ;
                                ROLLBACK TO del_sp ;

            --                      IF PG_DEBUG < 10  THEN
                                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                                   IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || 'Deleting Buffer Table after RollBack due to Error');
                                END IF;

                                --
                                -- Begin - 01/24/2005 - Andre Araujo - This procedure uses a memory schema uses up all memory available for the session, changing it to chunks
                                --

                                CLEAR_BUFFERS2(p_request_id);

                                --DELETE FROM IEX_DEL_BUFFERS
                                --WHERE request_id = p_request_id ;
                                --
                                -- End - 01/24/2005 - Andre Araujo - This procedure uses a memory schema uses up all memory available for the session, changing it to chunks
                                --

            --                  IF PG_DEBUG < 10  THEN
                                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                                   IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || 'Deletd Buffer Row Count >> ' ||
                                                                    to_char(SQL%ROWCOUNT));
                                END IF;
                                Commit;
                                return;
                        End;

                --
                -- Begin - 01/24/2005 - Andre Araujo - This procedure uses a memory schema uses up all memory available for the session, changing it to chunks
                --
                    EXIT WHEN c_scores%NOTFOUND;
                END LOOP;
                close c_scores;
                --
                -- End - 01/24/2005 - Andre Araujo - This procedure uses a memory schema uses up all memory available for the session, changing it to chunks
                --

            --ELSE
           elsif  v_object = 'IEX_CONTRACTS' then

               begin

                  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                       IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_CONTRACTS: ' || 'Starting Contract..... ');
                  END IF;

                  SELECT ico.object_id, ids.del_status, ico.delinquency_status
                        BULK COLLECT INTO vt_contract_id, vt_buf_status, vt_del_status
                   FROM iex_case_objects ico,
                        iex_del_buffers idb,
                        iex_del_statuses ids
                  WHERE idb.score_id = ids.score_id
                    AND idb.score_value BETWEEN ids.score_value_low and ids.score_value_high
                    AND idb.score_object_id = ico.object_id
                    AND ico.object_code = 'CONTRACTS'
                    AND idb.request_id = p_request_id;
                  null;

                  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                     IEX_DEBUG_PUB.LOGMESSAGE
                        ('MANAGE_DELINQUENCIES: ' || 'CONTRACT - Row Count after Update Select ' || to_char(vt_contract_id.COUNT));
                  END IF;

                  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                     IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || v_line);
                  END IF;

                  if v_debug_level < 11 then
                        for i in 1..vt_del_id.count
                        LOOP

                            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                               IEX_DEBUG_PUB.LOGMESSAGE
                              ('MANAGE_DELINQUENCIES: ' || '  CONTRACT Id = ' || to_char(vt_contract_id(i))||
                                ' Delinquency Id = ' || to_char(vt_del_id(i)) ||
                                ' Buf Status = ' || vt_buf_status(i) ||
                                'Del Status = ' || vt_del_status(i));
                            END IF;
                        END LOOP ;
                  End If ;

                  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                     IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || v_line);
                  END IF;

                EXCEPTION
                  WHEN OTHERS THEN
                   ERRBUF := 'CONTRACT - Matching Delinquencies Select -->' || SQLCODE || ' Error Msg ' || SQLERRM  ;

                   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                      IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || ERRBUF);
                   END IF;
                   RETCODE := -1 ;

                   ROLLBACK TO del_sp ;

                   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                      IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || 'Deletd Buffer Row Count >> ' || to_char(SQL%ROWCOUNT));
                   END IF;

                   Commit;
                   return;
              end;

              begin

                FORALL v_count in 1..vt_contract_id.count
                UPDATE IEX_CASE_OBJECTS
                    SET delinquency_status = vt_buf_status(v_count),
                        last_update_date = v_today,
                        last_updated_by = v_user_id,
                        object_version_number = object_version_number + 1,
                        request_id = p_request_id
                   WHERE object_id = vt_contract_id(v_count);

                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Number Of Contracts Updated..>> '|| vt_contract_id.count) ;
                l_del_update_count := vt_del_id.count ;

                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || v_line);
                END IF;
                if v_debug_level < 11 then
                    FOR i in 1..vt_del_id.count
                    LOOP

                        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                           IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || 'Rows Updated for ' || to_char(vt_del_id(i)) || ' is ' ||
                                    to_char(SQL%BULK_ROWCOUNT(i)));
                        END IF;
                    END LOOP ;
                End If ;

                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || v_line);
                END IF;

               EXCEPTION
                WHEN OTHERS THEN
                     ERRBUF := 'CONTRACT Updating... - Matching Delinquencies Update --> ' || SQLCODE || ' Error Msg ' || SQLERRM ;

                     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                        IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || ERRBUF);
                     END IF;
                     RETCODE := -1;
                     ROLLBACK TO del_sp;

                     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                         IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || 'Deleting Buffer Table after RollBack due to Error');
                     END IF;
                     CLEAR_BUFFERS2(p_request_id);
                     Commit;
                     return;
              end;

           elsif  v_object = 'IEX_CASES' then
            /* *******************************************************************
                                        HANDLING FOR CASE
            ******************************************************************* */
            BEGIN

--                      IF PG_DEBUG < 10  THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                       IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || 'Starting Cases ');
                    END IF;

            -- Selects All the matching rows between buffer and Delinquencies table
            -- except when the statuses are same or when buffer status is PREDELINQUENT
            -- and delinquency table status is DELINQUENT.
            /* 6785378
                    SELECT
                        id.delinquency_id,
                        ids.del_status buf_status,
                        id.status del_status,
                        id.case_id
                    BULK COLLECT INTO
                        vt_del_id,
                        vt_buf_status,
                        vt_del_status,
                        vt_case_id
                    FROM iex_delinquencies id,
                         iex_del_buffers idb,
                         iex_del_statuses ids
                    where
                    NOT EXISTS
                        (select 1
                         from dual
                         where (id.status = vf_delinquent and   ids.del_status = vf_predelinquent)
                            OR id.status = ids.del_status)
                    and idb.score_id = ids.score_id
                    and idb.score_value between ids.score_value_low
                    and ids.score_value_high
                    and idb.score_object_id =  id.case_id
                    and idb.request_id = p_request_id ;
               */
                  SELECT ic.cas_id, ids.del_status, ic.status_code
                        BULK COLLECT INTO vt_case_id, vt_buf_status, vt_del_status
                   FROM iex_cases_all_b ic,
                        iex_del_buffers idb,
                        iex_del_statuses ids
                  WHERE idb.score_id = ids.score_id
                    AND idb.score_value BETWEEN ids.score_value_low and ids.score_value_high
                    AND idb.score_object_id = ic.cas_id
                    AND idb.request_id = p_request_id;
                /* =================    Debug Message   ====================*/

                  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                     IEX_DEBUG_PUB.LOGMESSAGE
                        -- ('MANAGE_DELINQUENCIES: ' || 'CASE - Row Count after Update Select ' || to_char(vt_del_id.COUNT));
                        ('MANAGE_DELINQUENCIES: ' || 'CASE - Row Count after Update Select ' || to_char(vt_case_id.COUNT));
                  END IF;

                  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                     IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || v_line);
                  END IF;

                  if v_debug_level < 11 then
                        for i in 1..vt_del_id.count
                        LOOP

                            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                               IEX_DEBUG_PUB.LOGMESSAGE
                              ('MANAGE_DELINQUENCIES: ' || '  Case Id = ' || to_char(vt_case_id(i))||
                                ' Delinquency Id = ' || to_char(vt_del_id(i)) ||
                                ' Buf Status = ' || vt_buf_status(i) ||
                                'Del Status = ' || vt_del_status(i));
                            END IF;
                        END LOOP ;
                  End If ;

                  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                     IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || v_line);
                  END IF;
                 /*=================  Debug Message   ====================== */

            EXCEPTION
                WHEN OTHERS THEN
                ERRBUF := 'CASE - Matching Delinquencies Select -->' || SQLCODE || ' Error Msg ' || SQLERRM  ;

                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || ERRBUF);
                END IF;
                RETCODE := -1 ;

                ROLLBACK TO del_sp ;

                --
                -- Begin - 01/24/2005 - Andre Araujo - This procedure uses a memory schema uses up all memory available for the session, changing it to chunks
                --

                CLEAR_BUFFERS2(p_request_id);

                --DELETE FROM IEX_DEL_BUFFERS
                --WHERE request_id = p_request_id ;
                --
                -- End - 01/24/2005 - Andre Araujo - This procedure uses a memory schema uses up all memory available for the session, changing it to chunks
                --

--                IF PG_DEBUG < 10  THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || 'Deletd Buffer Row Count >> ' || to_char(SQL%ROWCOUNT));
                END IF;

                -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
                -- IEX_CONC_REQUEST_MSG_PKG.LOG_ERROR(p_request_id, 'MANAGE_DELINQUENCIES',ERRBUF) ;
                -- End - Andre Araujo - 09/30/2004- Remove obsolete logging

                Commit;
                return;
            END;

            BEGIN
                -- Once all the Existing PreDelinquent Rows are found then
                -- Update them
                /* 6785378
                FORALL v_count in 1..vt_del_id.count
                UPDATE IEX_DELINQUENCIES
                    SET status = vt_buf_status(v_count),
                        last_update_date = v_today,
                        last_updated_by = v_user_id,
                        dunn_yn = decode(vt_buf_status(v_count), vf_current, 'N'),
                        object_version_number = object_version_number + 1,
                        request_id = p_request_id
                WHERE delinquency_id = vt_del_id(v_count);
                */
                FORALL v_count in 1..vt_case_id.count
                UPDATE IEX_CASES_ALL_B
                    SET status_code = vt_buf_status(v_count),
                        last_update_date = v_today,
                        last_updated_by = v_user_id,
                        object_version_number = object_version_number + 1,
                        request_id = p_request_id
                   WHERE cas_id = vt_case_id(v_count);


                -- FND_FILE.PUT_LINE(FND_FILE.LOG, 'Number Of Delinquencies Updated..>> '|| vt_del_id.count) ;
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Number Of Cases Updated..>> '|| vt_case_id.count) ; -- 6785378
                l_del_update_count := vt_del_id.count ;

            /* =================    Debug Message   =========================*/
--                  IF PG_DEBUG < 10  THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || v_line);
                END IF;
                if v_debug_level < 11 then
                    FOR i in 1..vt_del_id.count
                    LOOP
--                      IF PG_DEBUG < 10  THEN
                        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                           IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || 'Rows Updated for ' ||
                            to_char(vt_del_id(i)) || ' is ' ||
                                    to_char(SQL%BULK_ROWCOUNT(i)));
                        END IF;
                    END LOOP ;
                End If ;
--              IF PG_DEBUG < 10  THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || v_line);
                END IF;
            /* ================= Debug Message   =========================== */

            EXCEPTION
                WHEN OTHERS THEN
                ERRBUF := 'CASE - Matching Delinquencies Update --> ' ||
                                    SQLCODE || ' Error Msg ' || SQLERRM ;
--                IF PG_DEBUG < 10  THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || ERRBUF);
                END IF;
                RETCODE := -1;
                ROLLBACK TO del_sp;

--              IF PG_DEBUG < 10  THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || 'Deleting Buffer Table after RollBack due to Error');
                END IF;

                --
                -- Begin - 01/24/2005 - Andre Araujo - This procedure uses a memory schema uses up all memory available for the session, changing it to chunks
                --

                CLEAR_BUFFERS2(p_request_id);

                --DELETE FROM IEX_DEL_BUFFERS
                --WHERE request_id = p_request_id ;
                --
                -- End - 01/24/2005 - Andre Araujo - This procedure uses a memory schema uses up all memory available for the session, changing it to chunks
                --

                -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
                --IEX_CONC_REQUEST_MSG_PKG.LOG_ERROR(p_request_id, 'MANAGE_DELINQUENCIES',ERRBUF) ;
            -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
                Commit;
                return;
            END;


            /*  6785378
            BEGIN

             -- clchang updated 04/18/2003 for BILL_TO
             -- get cust_account_id and customer_site_use_id
             -- by OKL, column_name = 'CUSTOMER_ACCOUNT' and 'BILL_TO_ADDRESS_ID'
             -- will be not null;

            -- Simple Insert for Payment Schedule Id
               INSERT INTO IEX_DELINQUENCIES_ALL
                ( DELINQUENCY_ID,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                OBJECT_VERSION_NUMBER,
                DUNN_YN,
                PARTY_CUST_ID,
                CUST_ACCOUNT_ID,
                CUSTOMER_SITE_USE_ID, -- added by clchang for BILL_TO
                CASE_ID,
                STATUS,
                ORG_ID,
                SOURCE_PROGRAM_NAME,
                SCORE_ID        ,
                SCORE_VALUE     ,
                REQUEST_ID      )
               SELECT
                IEX_DELINQUENCIES_S.NEXTVAL,
                v_today         ,
                v_user_id       ,
                v_today         ,
                v_user_id       ,
                1               ,
                'Y'             ,
                ICV.party_id    ,
                ICD.column_value,
                ICD2.column_value,
                IDB.score_object_id ,
                IDS.del_status  ,
                --v_org_id        ,
                ICV.org_id,  --Modified for MOAC
                l_source_module,
                IDB.Score_id,
                IDB.score_value ,
                p_REQUEST_ID
               FROM IEX_DEL_BUFFERS         IDB,
                 IEX_CASES_VL            ICV,
                 IEX_CASE_DEFINITIONS   ICD,
                 IEX_CASES_VL            ICV2,
                 IEX_CASE_DEFINITIONS   ICD2,
                 IEX_DEL_STATUSES    IDS
               WHERE
                NOT EXISTS
                (Select 1
                 from iex_delinquencies
                 where case_id = idb.score_object_id)
            AND NOT EXISTS
                (select 1
                 from dual
                 where IDS.del_status = vf_current)
            AND     ICV.cas_id = IDB.score_object_id
            AND IDB.score_value between
                    IDS.score_value_low and IDS.score_value_high
            AND IDB.score_id = IDS.score_id
            AND IDB.request_id = p_request_id
            AND ICV.cas_id = ICD.cas_id
            AND ICD.column_name = 'CUSTOMER_ACCOUNT'
            AND ICV2.cas_id = ICV.cas_id
            AND ICV2.cas_id = ICD2.cas_id
            AND ICD2.column_name = 'BILL_TO_ADDRESS_ID';


            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Number Of Delinquencies Created..>> '|| SQL%ROWCOUNT) ;
            l_del_insert_count := SQL%ROWCOUNT ;

            -- =================    Debug Message   ========================
            -- IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || v_line);
            END IF;
            -- IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || 'Number of Rows Inserted --> ' || to_char(SQL%ROWCOUNT));
            END IF;
            IF PG_DeBUG < 10  THEN
               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || v_line);
               END IF;
            END IF;
            -- =================  Debug Message   ===========================

            Exception
            WHEN OTHERS then
                ERRBUF := 'INSERT - Error Code = ' || SQLCODE || ' Error Msg ' || SQLERRM ;
                -- IF PG_DEBUG < 10  THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || ERRBUF);
                END IF;
                RETCODE := -1 ;
                ROLLBACK TO del_sp ;

                -- IF PG_DEBUG < 10  THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || 'CASE INSERT >> Deleting Buffer Table after RollBack due to Error');
                END IF;

                --
                -- Begin - 01/24/2005 - Andre Araujo - This procedure uses a memory schema uses up all memory available for the session, changing it to chunks
                --

                CLEAR_BUFFERS2(p_request_id);

                --DELETE FROM IEX_DEL_BUFFERS
                --WHERE request_id = p_request_id ;
                --
                -- End - 01/24/2005 - Andre Araujo - This procedure uses a memory schema uses up all memory available for the session, changing it to chunks
                --

                -- IF PG_DEBUG < 10  THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || 'Deletd Buffer Row Count >> ' || to_char(SQL%ROWCOUNT));
                END IF;
                -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
                --IEX_CONC_REQUEST_MSG_PKG.LOG_ERROR(p_request_id, 'MANAGE_DELINQUENCIES',ERRBUF) ;
                -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
                Commit;
                return;
            End;
            */  -- 6785378


          End If;
        End If;


        -- ______________________ CALLING THE WORKFLOW __________________________
        -- IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || 'Calling the Work Flow........ ');
        END IF;
        -- IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || 'Delinquency Table Count After Mangement Process ' || to_char(vt_del_id.count));
        END IF;

        -- Filter out NOCOPY the delinquency ids that are not the Workflow Candidates.
        if vt_del_id.count > 0 then

            for ct in 1..vt_del_id.COUNT
            LOOP
                if vt_del_status(ct) IN (vf_delinquent, vf_predelinquent)
                    AND (vt_buf_status(ct) = vf_current) THEN
                    -- F PG_DEBUG < 10  THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                       IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || 'Del Id for Workflow >> ' || to_char(vt_del_id(ct)));
                    END IF;
                    if vt_wf_del_id.COUNT = 0 then
                        vt_wf_del_id(1) := vt_del_id(ct)    ;
                    else
                        vt_wf_del_id(vt_wf_del_id.LAST + 1) := vt_del_id(ct) ;
                    end If ;
                End If ;
            END LOOP ;
        End If ;

        --  =================    Debug Message   ===========================
--            IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || '------------------------------------------------------------');
        END IF;
--          IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || 'Number of WorlFlow Candidate Rows --> ' || to_char(vt_wf_del_id.COUNT));
        END IF;

        -- Launch the Workflow and Close Promises only when required
        if vt_wf_del_id.COUNT > 0 then

            FOR p in 1..vt_wf_del_id.COUNT
            LOOP
--              IF PG_DEBUG < 10  THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || 'Delinquency Id --> ' || to_char(vt_wf_del_id(p)));
                END IF;
            END LOOP ;
--              IF PG_DEBUG < 10  THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || '------------------------------------------------------------');
                END IF;
            /* =================    Debug Message   =========================== */


            -- Launch the WorkFlow
            IEX_WF_DEL_CUR_STATUS_NOTE_PUB.START_WORKFLOW
                    (p_api_version      => 1.0,
                     p_init_msg_list    => FND_API.G_FALSE,
                     p_commit           => FND_API.G_FALSE,
                     p_delinquency_ids  => vt_wf_del_id,
                     x_return_status    => l_return_status,
                     x_msg_count        => l_msg_count,
                     x_msg_data         => l_msg_data);

--          IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || 'WorlFlow Status --> ' || l_return_status);
            END IF;

            -- Close the Promises
                IEX_PROMISES_BATCH_PUB.CLOSE_PROMISES
                    (p_api_version      => 1.0,
                     p_init_msg_list    => FND_API.G_FALSE,
                     p_commit           => FND_API.G_FALSE,
                     p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                     x_return_status    => l_return_status,
                     x_msg_count        => l_msg_count,
                     x_msg_data         => l_msg_data   ,
                     p_delinq_tbl       => vt_wf_del_id );

--          IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || 'Close Promises Status --> ' || l_return_status);
            END IF;

        End If ;

--      IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || 'Deleting Buffer Table');
        END IF;
        --
        -- Begin - 01/24/2005 - Andre Araujo - This procedure uses a memory schema uses up all memory available for the session, changing it to chunks
        --
        CLEAR_BUFFERS2(p_request_id);
        --DELETE FROM IEX_DEL_BUFFERS WHERE request_id = p_request_id ;
        --
        -- End - 01/24/2005 - Andre Araujo - This procedure uses a memory schema uses up all memory available for the session, changing it to chunks
        --
--      IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || 'Deleted Buffer Row Count >> ' || to_char(SQL%ROWCOUNT));
        END IF;

    if not isRefreshProgramsRunning then -- Added for bug#7133605 by schekuri on 17-Jun-2008 --Added by PNAVEENK
	--Bug5237039. Fix by LKKUMAR on 25-May-2006. Start
  	FND_FILE.PUT_LINE(FND_FILE.LOG,'Starting to update ar_trx_bal_summary....'); --Added by PNAVEENK
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          IEX_DEBUG_PUB.LOGMESSAGE('Starting to update ar_trx_bal_summary with reference_1 = 1...');
        END IF;

      --if vt_del_id.count > 0 then  -- 6785378
	BEGIN
	    OPEN c_cust_account_id_1;
	    LOOP
	    FETCH c_cust_account_id_1 BULK COLLECT INTO
	          l_cust_account_id_1 LIMIT G_BATCH_SIZE;
	    IF l_cust_account_id_1.count =  0 THEN
                 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                    IEX_DEBUG_PUB.LOGMESSAGE('Exit after Updating ar_trx_bal_summary with reference_1 = 1...');
                 END IF;
	         CLOSE c_cust_account_id_1;
	     EXIT;
            ELSE
         	   FORALL I IN l_cust_account_id_1.first..l_cust_account_id_1.last
	           UPDATE AR_TRX_BAL_SUMMARY ARS
                   SET REFERENCE_1 = 1
                   WHERE CUST_ACCOUNT_ID = l_cust_account_id_1(I);

                   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                      IEX_DEBUG_PUB.LOGMESSAGE(SQL%ROWCOUNT || ' Rows updated in ar_trx_bal_summary with reference_1 = 1');
                   END IF;
	     END IF;
	     END LOOP;
        EXCEPTION WHEN OTHERS THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LOGMESSAGE(SQLERRM || ' Error while updating ar_trx_bal_summary with reference_1 = 1');
          END IF;
	END;

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          IEX_DEBUG_PUB.LOGMESSAGE('Starting to update ar_trx_bal_summary with reference_1 = Null...');
        END IF;
	BEGIN
	OPEN c_cust_account_id_n;
	 LOOP
	  FETCH c_cust_account_id_n BULK COLLECT INTO
	    l_cust_account_id_n LIMIT G_BATCH_SIZE;
	  IF l_cust_account_id_n.count =  0 THEN
             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LOGMESSAGE('Exit after Update ar_trx_bal_summary on complete with reference_1 = Null...');
             END IF;
	    CLOSE c_cust_account_id_n;
	    EXIT;
          ELSE
	   FORALL I IN l_cust_account_id_n.first..l_cust_account_id_n.last
	    UPDATE AR_TRX_BAL_SUMMARY ARS
            SET REFERENCE_1 = Null
            WHERE CUST_ACCOUNT_ID = l_cust_account_id_n(I);
            FND_FILE.PUT_LINE(FND_FILE.LOG,SQL%ROWCOUNT || ' Rows updated in ar_trx_bal_summary with reference_1 = NULL');
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             IEX_DEBUG_PUB.LOGMESSAGE(SQL%ROWCOUNT ||  'Rows updated in ar_trx_bal_summary with reference_1 = Null');
            END IF;
	   END IF;
	 END LOOP;
        EXCEPTION WHEN OTHERS THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LOGMESSAGE(SQLERRM || ' Error while updating ar_trx_bal_summary with reference_1 = Null');
          END IF;
	END;
	--Bug5237039. Fix by LKKUMAR on 25-May-2006. End.
   --   end if; -- 6785378

        COMMIT;
        -- Start Bug 5874874 gnramasa 25-Apr-2007

      --  if vt_del_id.count > 0 then     -- 6785378
	      iex_uwq_pop_sum_tbl_pvt.refresh_summary_incr
						(x_errbuf,
						x_retcode,
						NULL,
						'DLN');
        -- End Bug 5874874 gnramasa 25-Apr-2007
       -- end if;  -- 6785378
	end if; --End if isRefreshProgramsRunning -- Added by PNAVEENK


        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling the Dunning Closing Process.... ') ;
        CLOSE_DUNNINGS(RETCODE, ERRBUF, 'ALL') ;
        FND_FILE.PUT_LINE(FND_FILE.LOG, '*******   Dunning Closing Process Result  *******') ;
        FND_FILE.PUT_LINE(FND_FILE.LOG, ' RETCODE >>> ' || RETCODE) ;
        FND_FILE.PUT_LINE(FND_FILE.LOG, ' ERRBUF  >>> ' || ERRBUF) ;



        if l_del_insert_count > 0 OR l_del_update_count > 0 then
            if l_enable_business_events = 'Y' then
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Business Events Processing Enabled... ' ) ;

            --jsanju 09/15/05 , logic has changed, raise event directly for the request id
            ---do not call the concurrent program. There will be one event for every scoring engine
            -- request and not for every del created or updated.
            --set concurrent status to warning if event is not raised.
               /* l_business_event_req_id :=
                            FND_REQUEST.SUBMIT_REQUEST(
                                        APPLICATION       => 'IEX',
                                        PROGRAM           => 'IEX:RAISE_DEL_CREATE_EVENT' ,
                                        DESCRIPTION       => 'Business Event when Delinquencies are Created or Closed',
                                        START_TIME        => sysdate,
                                        SUB_REQUEST       => false,
                                        ARGUMENT1         => p_Request_id); */


                         RAISE_EVENT(
                                      P_REQUEST_ID          =>p_request_id,
                                      p_del_create_count    =>l_del_insert_count,
                                      p_del_update_count    =>l_del_update_count,
                                      x_return_status       => l_return_status,
                                      x_msg_count           => l_msg_count,
                                      x_msg_data            => l_msg_data  );


                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   if l_return_Status = FND_API.G_RET_STS_SUCCESS THEN
                       fnd_file.put_line(fnd_file.log,'Business Event raised  Successfully');
                   else
                       fnd_file.put_line(fnd_file.log,'Business Event not raised ');
                        request_status := fnd_concurrent.set_completion_status('WARNING'
                                          , 'Business Event Not Raised');
                   end if;
                END IF ;

            else
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Business Events Processing Disabled... ' ) ;
            End If ;
        End If ;

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || '--------------------------------------------------------------');
           IEX_DEBUG_PUB.LOGMESSAGE('---------->> PROCEDURE MANAGE_DELINQUENCIES End <<----------');
           IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || '--------------------------------------------------------------');
           IEX_DEBUG_PUB.logMessage('MANAGE_DELINQUENCIES: ' || 'End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
        END IF;

    EXCEPTION
        WHEN Others then
            RETCODE := -1 ;
            ERRBUF := 'MANAGE_DELINQUENCIES  >> WHEN OTHERS - ERROR - ' || SQLCODE || ' ' || SQLERRM ;
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || ERRBUF);
            END IF;
            ROLLBACK TO del_sp ;

--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || 'Deleting Buffer Table after RollBack due to Error');
            END IF;

            --
            -- Begin - 01/24/2005 - Andre Araujo - This procedure uses a memory schema uses up all memory available for the session, changing it to chunks
            --
            CLEAR_BUFFERS2(p_request_id);
            --DELETE FROM IEX_DEL_BUFFERS WHERE request_id = p_request_id ;
            --
            -- End - 01/24/2005 - Andre Araujo - This procedure uses a memory schema uses up all memory available for the session, changing it to chunks
            --

--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LOGMESSAGE('MANAGE_DELINQUENCIES: ' || 'Deletd Buffer Row Count >> ' || to_char(SQL%ROWCOUNT));
            END IF;

            Commit;
    END MANAGE_DELINQUENCIES;

    /*------------------------------------------------------------------------
            11.5.7  Independent Delinquency Creation Process
    ------------------------------------------------------------------------ */
    PROCEDURE Create_Ind_Delinquency
       (  p_api_version         IN  NUMBER  ,
          p_init_msg_list       IN  VARCHAR2,
          p_commit              IN  VARCHAR2,
          p_validation_level    IN  NUMBER  ,
          x_return_status       OUT NOCOPY VARCHAR2    ,
          x_msg_count           OUT NOCOPY NUMBER  ,
          x_msg_data            OUT NOCOPY VARCHAR2    ,
          p_source_module       IN  VARCHAR2    ,
          p_party_id            IN  Number  ,
          p_object_code         IN  Varchar2    ,
          p_object_id_tbl       IN  IEX_UTILITIES.t_numbers,
          x_del_id_tbl          OUT NOCOPY IEX_UTILITIES.t_numbers)
    IS
    v_first     Number := 0 ;
    v_last      Number := 0 ;

    v_org_id    Number  ;
    v_today     Date    ;
    v_user_id   Number  ;
    v_count     Number := 1 ;

      l_api_name varchar2(50);

    v_error_msg varchar2(200);
    --Begin Bug 6446848 08-Dec-2008 barathsr
    l_deln_id number;
    l_pay_sch_id number;
    l_org_id number;
    l_cust_acct_id number;    --29/12
    l_cust_site_use_id number;--29/12
 --End Bug 6446848 08-Dec-2008 barathsr
    l_cust_trx_id number;--Added for Bug 8517550 14-May-2009 barathsr

    Begin

      -- clchang 10/28/04 fixed gscc warning
      l_api_name := 'Create_Ind_Delinquency';


    if p_object_id_tbl.COUNT > 0 then
        v_first := p_object_id_tbl.FIRST ;
        v_last  := p_object_id_tbl.LAST ;
    End If ;


        -- Standard Start of API savepoint
        SAVEPOINT   IEX_IND_DEL ;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call(l_api_version_number,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME)
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean(p_init_msg_list) THEN
            FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        if x_del_id_tbl.COUNT > 0 then
            x_del_id_tbl.DELETE ;
        End IF ;

        Select
        --fnd_profile.value('ORG_ID'), --Commneted for MOAC
        NVL(fnd_profile.value('USER_ID'), -1),
        sysdate
      into
        --v_org_id    , --Commneted for MOAC
        v_user_id   ,
        v_today
      From dual         ;

        -- Loop Through the Table of Cases and Create Delinquencies.
      IF p_object_code = 'IEX_CASE' then
          FOR cnt IN v_first..v_last
          LOOP

            Select  IEX_DELINQUENCIES_S.NEXTVAL
        into    x_del_id_tbl(v_count)
        From    dual        ;

             INSERT INTO IEX_DELINQUENCIES_ALL
                  (DELINQUENCY_ID   ,
                   LAST_UPDATE_DATE ,
                   LAST_UPDATED_BY  ,
                   CREATION_DATE    ,
                   CREATED_BY       ,
                   OBJECT_VERSION_NUMBER,
                   DUNN_YN          ,
                   PARTY_CUST_ID    ,
                   CUST_ACCOUNT_ID  ,
                   CASE_ID          ,
                   STATUS           ,
                   ORG_ID           ,
              SOURCE_PROGRAM_NAME   )
                VALUES
                    (x_del_id_tbl(v_count)  ,
                    v_today     ,
                    v_user_id   ,
                    v_today     ,
                    v_user_id   ,
                    1           ,
                    'N'         ,
                    p_party_id  ,
                    NULL        ,
                    p_object_id_tbl(cnt),
                    vf_delinquent   ,
                    v_org_id        ,
                    p_source_module ) ;

            v_count := v_count + 1 ;
        END LOOP ;
	--Begin Bug 6446848 08-Dec-2008 barathsr
   else

	 IEX_DEBUG_PUB.LOGMESSAGE('In for Current invoice insertion....');

	select IEX_DELINQUENCIES_S.NEXTVAL
	into l_deln_id
	from dual;

	if  p_object_id_tbl.count = 1 then
	 for i in v_first..v_last loop

	  begin--29/12
          select org_id,customer_id,customer_site_use_id,customer_trx_id--Added for Bug 8517550 14-May-2009 barathsr
	  into l_org_id,l_cust_acct_id,l_cust_site_use_id,l_cust_trx_id  --29/12
	  from ar_payment_schedules_all
	  where payment_schedule_id= p_object_id_tbl(i);

	  IEX_DEBUG_PUB.LOGMESSAGE('Org_id--->'||l_org_id);
          IEX_DEBUG_PUB.LOGMESSAGE('Cust_account_id-->'||l_cust_acct_id);
	  IEX_DEBUG_PUB.LOGMESSAGE('Customer_site_use_id-->'||l_cust_site_use_id);
	  IEX_DEBUG_PUB.LOGMESSAGE('Customer_site_use_id-->'||l_cust_trx_id);

	   INSERT INTO IEX_DELINQUENCIES_ALL
                  (DELINQUENCY_ID   ,
                   LAST_UPDATE_DATE ,
                   LAST_UPDATED_BY  ,
                   CREATION_DATE    ,
                   CREATED_BY       ,
                   OBJECT_VERSION_NUMBER,
                   DUNN_YN          ,
                   PARTY_CUST_ID    ,
                   CUST_ACCOUNT_ID  ,
		   transaction_id,  --Added for Bug 8517550 14-May-2009 barathsr
                   payment_schedule_id,
                   STATUS           ,
                   ORG_ID           ,
                   SOURCE_PROGRAM_NAME,
		   CUSTOMER_SITE_USE_ID)
                VALUES
                    (l_deln_id,
                    v_today     ,
                    v_user_id   ,
                    v_today     ,
                    v_user_id   ,
                    1           ,
                    'N'         ,
                    p_party_id  ,
                    l_cust_acct_id, --29/12
		    l_cust_trx_id, --Added for Bug 8517550 14-May-2009 barathsr
                   p_object_id_tbl(i),
                   vf_current,
                   l_org_id        ,
                   p_source_module,
		   l_cust_site_use_id) ;  --29/12
		   exception
	           when others then --29/12
	           IEX_DEBUG_PUB.LOGMESSAGE('Error in CURRENT invoice selection/insertion activity.....');
	           raise FND_API.G_EXC_UNEXPECTED_ERROR;
	           end;--29/12
		  end loop;
                  end if;

		    x_del_id_tbl(1):=l_deln_id;

         --End Bug 6446848 08-Dec-2008 barathsr
    END IF ;

        -- Standard check for p_commit
        IF FND_API.to_Boolean(p_commit) THEN
            COMMIT WORK;
      ELSE
        ROLLBACK TO IEX_IND_DEL ;
        END IF;

        -- Debug Message
        IEX_DEBUG_PUB.LogMessage('PUB: ' || l_api_name || ' end');
        IEX_DEBUG_PUB.LogMessage('End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

   EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
                 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                 IEX_DEBUG_PUB.logMessage('IEX_DELINQUENCY_PUB: Create_Ind_Delinquency: Expected Error ' || sqlerrm);
                 END IF;
                 RAISE FND_API.G_EXC_ERROR;
                 ROLLBACK TO IEX_IND_DEL;

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                IEX_DEBUG_PUB.logMessage('IEX_DELINQUENCY_PUB: Create_Ind_Delinquency: Unexpected Error ' || sqlerrm);
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ROLLBACK TO IEX_IND_DEL;

          WHEN OTHERS THEN
                v_error_msg := SQLCODE || ' Error Msg ' || SQLERRM ;
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                IEX_DEBUG_PUB.LOGMESSAGE(v_error_msg) ;
                END IF;
                ROLLBACK TO IEX_IND_DEL;
                -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
                --IEX_CONC_REQUEST_MSG_PKG.LOG_ERROR(-9999, 'CREATE_IND_DELINQUENCIES', v_error_msg) ;
                -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
                COMMIT ;
   End ;


/*
|| Overview:  will update the delinquency header table once the
||            scoring engine for delinquencies is run
||
|| Parameter:   p_request_id => request_id of score engine run
||
|| Source Tables: IEX_DEL_BUFFERS
||
|| Target Tables: IEX_DELINQUENCIES_ALL
||
|| Creation date:       03/19/02 10:04:AM
||
|| Major Modifications: when              who                   what
||                      03/19/02 10:04:AM raverma               created
*/
procedure SCORE_DELINQUENCIES (ERRBUF       OUT NOCOPY     VARCHAR2,
                               RETCODE      OUT NOCOPY     VARCHAR2,
                               p_request_id Number) IS

type t_ids is table of number
    index by binary_integer;

v_score_objects t_ids;
v_score_values  t_ids;
l_score_id      number;
nCount          number;

cursor c_scores(p_request_id in number)
is
    select score_object_id,
           score_value
      from iex_del_buffers
     where request_id = p_request_id;
BEGIN

    RETCODE := 0;

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logMessage('IEX_DELINQUENCY_PUB.SCORE_DELINQUENCIES');
    END IF;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logMessage('SCORE_DELINQUENCIES: ' || 'StartTime: ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));
    END IF;
    -- get the score id for the engine
    Select score_id into l_score_id
      from iex_del_buffers
     Where request_id = p_request_id and
           rownum = 1;

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logMessage('SCORE_DELINQUENCIES: ' || 'ScoreID is ' || l_score_id);
    END IF;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logMessage('SCORE_DELINQUENCIES: ' || 'bridge value is ' || p_request_id);
    END IF;

    -- now get the data
    open c_scores(p_request_id);
    LOOP
        FETCH c_scores
        BULK COLLECT INTO
               v_score_objects,
               v_score_values
        LIMIT G_Batch_Size;

        nCount := v_score_objects.count;

        for i in  1..nCount
        loop
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               iex_debug_pub.logMessage('SCORE_DELINQUENCIES: ' || v_score_objects(i));
            END IF;
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               iex_debug_pub.logMessage('SCORE_DELINQUENCIES: ' || v_score_values(i));
            END IF;
        end loop;

--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           iex_debug_pub.logMessage('SCORE_DELINQUENCIES: ' || 'Count is ' || nCount);
        END IF;
        FORALL r in 1..nCount
            UPDATE IEX_DELINQUENCIES_ALL
               SET SCORE_ID   = l_score_id,
                   Score_value = v_score_values(r),
                   last_update_date = sysdate,
                   request_id = FND_GLOBAL.CONC_REQUEST_ID
             WHERE DELINQUENCY_ID = v_score_objects(r);

        EXIT WHEN c_scores%NOTFOUND;
    END LOOP;
    close c_scores;
    /*
    SELECT score_object_id,
           score_value
      BULK COLLECT INTO
     LIMIT NVL(FND_PROFILE.VALUE('IEX_BATCH_SIZE'), 1000)
      FROM iex_del_buffers
     WHERE request_id = p_request_id;
    */
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.logMessage('SCORE_DELINQUENCIES: ' || 'Deleting from buffers');
     END IF;
    --
    -- Begin - 01/24/2005 - Andre Araujo - This procedure uses a memory schema uses up all memory available for the session, changing it to chunks
    --
    CLEAR_BUFFERS2(p_request_id);
    --Delete From IEX_DEL_BUFFERS
    --      Where request_id = p_request_id;
    --
    -- End - 01/24/2005 - Andre Araujo - This procedure uses a memory schema uses up all memory available for the session, changing it to chunks
    --

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logMessage('IEX_DELINQUENCY_PUB.SCORE_DELINQUENCIES');
    END IF;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logMessage('SCORE_DELINQUENCIES: ' || 'ENDTime: ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));
    END IF;
Exception
    When NO_DATA_FOUND then
--     IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logMessage('SCORE_DELINQUENCIES: ' || 'no data found ' || sqlerrm);
       END IF;
        RETCODE := -1;
        ERRBUF := sqlerrm;
    When others then
--     IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logMessage('SCORE_DELINQUENCIES: ' || 'other error ' || sqlerrm);
       END IF;
        RETCODE := -1;
        ERRBUF := sqlerrm;

END SCORE_DELINQUENCIES;

/*********************
Set UWQ status for promises
***********************/
PROCEDURE SHOW_IN_UWQ(
        P_API_VERSION              IN      NUMBER,
        P_INIT_MSG_LIST            IN      VARCHAR2,
        P_COMMIT                   IN      VARCHAR2,
        P_VALIDATION_LEVEL         IN      NUMBER,
        X_RETURN_STATUS            OUT NOCOPY     VARCHAR2,
        X_MSG_COUNT                OUT NOCOPY     NUMBER,
        X_MSG_DATA                 OUT NOCOPY     VARCHAR2,
        P_DELINQUENCY_ID_TBL       IN      DBMS_SQL.NUMBER_TABLE,
        P_UWQ_STATUS               IN      VARCHAR2,
        P_NO_DAYS                  IN      NUMBER)
IS
    l_api_name          CONSTANT VARCHAR2(30) := 'SHOW_IN_UWQ';
    l_api_version       CONSTANT NUMBER := 1.0;
    l_return_status     varchar2(10);
    l_msg_count         number;
    l_msg_data          varchar2(200);

    l_validation_item   varchar2(100);
    l_days              NUMBER;
    l_set_status_date   DATE;
    l_status            varchar2(20);
    nCount              number;

    Type refCur is Ref Cursor;
    l_cursor            refCur;
    l_SQL               VARCHAR2(10000);
    l_broken_promises   DBMS_SQL.NUMBER_TABLE;
    i                   number;
    j                   number;
    l_uwq_active_date   date;
    l_uwq_complete_date date;
    l_level             VARCHAR2(80);

  CURSOR c_get_level IS
    SELECT PREFERENCE_VALUE FROM IEX_APP_PREFERENCES_VL WHERE PREFERENCE_NAME = 'COLLECTIONS STRATEGY LEVEL';

begin

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': start');
END IF;

        -- Standard start of API savepoint
        SAVEPOINT SHOW_IN_UWQ_PVT;

        -- Standard call to check for call compatibility
        IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE
        IF FND_API.To_Boolean(p_init_msg_list) THEN
            FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to success
        l_return_status := FND_API.G_RET_STS_SUCCESS;

        -- START OF BODY OF API

    -- validating uwq status
    l_validation_item := 'P_UWQ_STATUS';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': new uwq status: ' || P_UWQ_STATUS);
    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Validating ' || l_validation_item);
END IF;
    if P_UWQ_STATUS is null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' failed validation');
END IF;
        FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
        FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_api_name);
        FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    -- validating table of promises
    l_validation_item := 'P_DELINQUENCY_ID_TBL';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': count of P_DELINQUENCY_ID_TBL: ' || P_DELINQUENCY_ID_TBL.count);
    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Validating ' || l_validation_item);
END IF;
    if P_DELINQUENCY_ID_TBL.count = 0 then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' failed validation');
END IF;
        FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
        FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_api_name);
        FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    -- validating p_days
    l_validation_item := 'P_NO_DAYS';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': P_NO_DAYS: ' || P_NO_DAYS);
    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Validating ' || l_validation_item);
END IF;
    if P_NO_DAYS is not null and P_NO_DAYS < 0 then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' failed validation');
END IF;
        FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
        FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_api_name);
        FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    -- set number of days
    if P_NO_DAYS is null then
        l_days := to_number(nvl(fnd_profile.value('IEX_UWQ_DEFAULT_PENDING_DAYS'), '0'));
    else
        l_days := P_NO_DAYS;
    end if;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': number of days: ' || l_days);
END IF;
    l_set_status_date := sysdate + l_days;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': set status date: ' || l_set_status_date);
END IF;

    -- check for status
    if P_UWQ_STATUS = 'ACTIVE' then
        l_uwq_active_date := NULL;
        l_uwq_complete_date := NULL;
    elsif P_UWQ_STATUS = 'PENDING' then
        l_uwq_active_date := l_set_status_date;
        l_uwq_complete_date := NULL;
    elsif P_UWQ_STATUS = 'COMPLETE' then
        l_uwq_active_date := NULL;
        l_uwq_complete_date := sysdate;
    end if;

        nCount := p_delinquency_id_tbl.count;
        if nCount > 0 then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': l_uwq_active_date: ' || l_uwq_active_date);
        iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': l_uwq_complete_date: ' || l_uwq_complete_date);
        iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': updating promise details...');
END IF;
            FORALL i in 1..nCount
                update iex_delinquencies_all
                set UWQ_STATUS = P_UWQ_STATUS,
                    UWQ_ACTIVE_DATE = l_uwq_active_date,
                    UWQ_COMPLETE_DATE = l_uwq_complete_date,
                    last_update_date = sysdate,
                    last_updated_by = G_USER_ID
                where
                    delinquency_id = p_delinquency_id_tbl(i);

            -- start of fix for bug 5874874 gnramasa 25-Apr-07
            OPEN c_get_level;
            FETCH c_get_level INTO l_level;
            CLOSE c_get_level;
            iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Strateg Level = ' || l_level);

            IF l_level = 'CUSTOMER' THEN

               FORALL i in 1..nCount
                update IEX_DLN_UWQ_SUMMARY sum
                set
                sum.active_delinquencies =
                (SELECT 1
                   FROM dual
                   WHERE EXISTS
                      (SELECT 1
                        FROM iex_delinquencies_all
                        WHERE party_cust_id = sum.party_id
                        AND status IN('DELINQUENT',      'PREDELINQUENT')
                        AND(uwq_status IS NULL OR uwq_status = 'ACTIVE' OR(TRUNC(uwq_active_date) <= TRUNC(sysdate)
                        AND uwq_status = 'PENDING'))
                       )
                 ),
                 sum.complete_delinquencies =
                 (SELECT 1
                   FROM dual
                   WHERE EXISTS
                      (SELECT 1
                       FROM iex_delinquencies_all
                       WHERE party_cust_id = sum.party_id
                       AND status IN('DELINQUENT',      'PREDELINQUENT')
                       AND(uwq_status = 'COMPLETE'
                       AND(TRUNC(uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') > TRUNC(sysdate))))
                  ),
                  sum.pending_delinquencies =
                 (SELECT 1
                   FROM dual
                   WHERE EXISTS
                      (SELECT 1
                       FROM iex_delinquencies_all
                       WHERE party_cust_id = sum.party_id
                       AND status IN('DELINQUENT',      'PREDELINQUENT')
                       AND(uwq_status = 'PENDING'
                       AND(TRUNC(uwq_active_date) > TRUNC(sysdate))))
                  )
                 WHERE sum.party_id = (select party_cust_id
                                    from iex_delinquencies_all
                                    where delinquency_id = p_delinquency_id_tbl(i));

            ELSIF l_level = 'ACCOUNT' THEN

               FORALL i in 1..nCount
                update IEX_DLN_UWQ_SUMMARY sum
                set
                sum.active_delinquencies =
                (SELECT 1
                   FROM dual
                   WHERE EXISTS
                      (SELECT 1
                        FROM iex_delinquencies_all
                        WHERE party_cust_id = party_id
                        AND status IN('DELINQUENT',      'PREDELINQUENT')
                        AND(uwq_status IS NULL OR uwq_status = 'ACTIVE' OR(TRUNC(uwq_active_date) <= TRUNC(sysdate)
                        AND uwq_status = 'PENDING'))
                       )
                 ),
                 sum.complete_delinquencies =
                 (SELECT 1
                   FROM dual
                   WHERE EXISTS
                      (SELECT 1
                       FROM iex_delinquencies_all
                       WHERE cust_account_id = sum.cust_account_id
                       AND status IN('DELINQUENT',      'PREDELINQUENT')
                       AND(uwq_status = 'COMPLETE'
                       AND(TRUNC(uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') > TRUNC(sysdate))))
                  ),
                  sum.pending_delinquencies =
                 (SELECT 1
                   FROM dual
                   WHERE EXISTS
                      (SELECT 1
                       FROM iex_delinquencies_all
                       WHERE cust_account_id = sum.cust_account_id
                       AND status IN('DELINQUENT',      'PREDELINQUENT')
                       AND(uwq_status = 'PENDING'
                       AND(TRUNC(uwq_active_date) > TRUNC(sysdate))))
                  )
                 WHERE sum.cust_account_id = (select cust_account_id
                                    from iex_delinquencies_all
                                    where delinquency_id = p_delinquency_id_tbl(i));

            ELSIF l_level = 'BILL_TO' THEN

               FORALL i in 1..nCount
                update IEX_DLN_UWQ_SUMMARY sum
                set
                sum.active_delinquencies =
                (SELECT 1
                   FROM dual
                   WHERE EXISTS
                      (SELECT 1
                        FROM iex_delinquencies_all
                        WHERE customer_site_use_id = sum.site_use_id
                        AND status IN('DELINQUENT',      'PREDELINQUENT')
                        AND(uwq_status IS NULL OR uwq_status = 'ACTIVE' OR(TRUNC(uwq_active_date) <= TRUNC(sysdate)
                        AND uwq_status = 'PENDING'))
                       )
                 ),
                 sum.complete_delinquencies =
                 (SELECT 1
                   FROM dual
                   WHERE EXISTS
                      (SELECT 1
                       FROM iex_delinquencies_all
                       WHERE customer_site_use_id = sum.site_use_id
                       AND status IN('DELINQUENT',      'PREDELINQUENT')
                       AND(uwq_status = 'COMPLETE'
                       AND(TRUNC(uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') > TRUNC(sysdate))))
                  ),
                  sum.pending_delinquencies =
                 (SELECT 1
                   FROM dual
                   WHERE EXISTS
                      (SELECT 1
                       FROM iex_delinquencies_all
                       WHERE customer_site_use_id = sum.site_use_id
                       AND status IN('DELINQUENT',      'PREDELINQUENT')
                       AND(uwq_status = 'PENDING'
                       AND(TRUNC(uwq_active_date) > TRUNC(sysdate))))
                  )
                 WHERE sum.site_use_id = (select customer_site_use_id
                                    from iex_delinquencies_all
                                    where delinquency_id = p_delinquency_id_tbl(i));

            END IF;

            iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Updated ' || SQL%ROWCOUNT || ' rows in IEX_DLN_UWQ_SUMMARY');
            -- end of fix for bug 5874874 gnramasa 25-Apr-07

        else
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': nothing to update');
END IF;
        end if;

        -- END OF BODY OF API

        -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
        END IF;

        x_return_status := l_return_status;
        -- Standard call to get message count and if count is 1, get message info
        FND_MSG_PUB.Count_And_Get(p_encoded   => FND_API.G_FALSE,
                                    p_count   => x_msg_count,
                                    p_data    => x_msg_data);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO SHOW_IN_UWQ_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO SHOW_IN_UWQ_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO SHOW_IN_UWQ_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
end;

    /*------------------------------------------------------------------------
                        CLOSE Dunnings Process
    This process closes all the dunnings that are open for the delinquencies
    that are in CURRENT status. This makes the Dunning, Delinquency records
    consistant. Dunning level passed as parameter decides which dunning level
    to run. (ACCOUNT, CUSTOMER, DELINQUENCY. ALL). ALL performs the closing
    for all the three dunning levels.

    clchang updated 04/18/2003 for BILL_TO.
    in 11.5.10, one more level BILL_TO for dunning level.

    --jsanju 08/04/05 for bug#4505461
    --change SQL stmts
    ------------------------------------------------------------------------ */
    PROCEDURE CLOSE_DUNNINGS(ERRBUF       OUT NOCOPY VARCHAR2,
                             RETCODE      OUT NOCOPY VARCHAR2,
                             DUNNING_LEVEL Varchar2)
    IS
    BEGIN
        SAVEPOINT close_dunn ;
      RETCODE := 0 ;

--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LOGMESSAGE(v_line);
           IEX_DEBUG_PUB.LOGMESSAGE('---------->> PROCEDURE CLOSE_DUNNINGS Start <<----------');
           IEX_DEBUG_PUB.logMessage('CLOSE_DUNNINGS : ' || 'Start time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
           IEX_DEBUG_PUB.LOGMESSAGE(v_line);
        END IF;

        if dunning_level in ('ALL', 'DELINQUENCY') then
            Begin
                UPDATE iex_dunnings idun
                set status = 'CLOSE'
                where idun.dunning_level = 'DELINQUENCY'
                and idun.status = 'OPEN'
                and EXISTS
                    (select delinquency_id
                    from iex_delinquencies id
                    where status = 'CURRENT'
                    and id.delinquency_id = dunning_object_id) ;

                FND_FILE.PUT_LINE(FND_FILE.LOG, ' <<< DELINQUENCY >>>
                            Number Of Dunnings Closed..>> '|| SQL%ROWCOUNT) ;
            Exception
                WHEN OTHERS then
                    ERRBUF := 'CLOSE DUNNINGS << DELINQUENCY >>  Error Code = '
                                || SQLCODE || ' Error Msg ' || SQLERRM ;
--                      IF PG_DEBUG < 10  THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                        IEX_DEBUG_PUB.LOGMESSAGE('CLOSE_DUNNINGS for Delinquency : ' || ERRBUF);
                    END IF;
                    RETCODE := -1 ;
                    ROLLBACK TO close_dunn ;

--                    IF PG_DEBUG < 10  THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                        IEX_DEBUG_PUB.LOGMESSAGE(v_line);
                        IEX_DEBUG_PUB.LOGMESSAGE('---------->> PROCEDURE CLOSE_DUNNINGS End ERROR <<----------');
                        IEX_DEBUG_PUB.logMessage('CLOSE_DUNNINGS : ' || 'End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
                        IEX_DEBUG_PUB.LOGMESSAGE(v_line);
                    END IF;
            End ;
        end if ;


        -- clchang updated 04/18/2003 for BILL_TO level

        if dunning_level in ('ALL', 'BILL_TO') then
            Begin


                UPDATE iex_dunnings idun
                set status = 'CLOSE'
                where idun.dunning_level = 'BILL_TO'
                and idun.status = 'OPEN'
                and dunning_object_id IN
                   (select DISTINCT id.customer_site_use_id
                    from iex_delinquencies id
                    where NOT EXISTS
                      (SELECT customer_site_use_id
                       FROM IEX_DELINQUENCIES id2
                       where id2.status IN ('PREDELINQUENT', 'DELINQUENT')
                       and id2.customer_site_use_id = id.customer_site_use_id)) ;







                FND_FILE.PUT_LINE(FND_FILE.LOG, ' <<< BILL_TO >>>
                            Number Of Dunnings Closed..>> '|| SQL%ROWCOUNT) ;
            Exception
                WHEN OTHERS then
                    ERRBUF := 'CLOSE DUNNINGS << BILL_TO >>  Error Code = '
                                || SQLCODE || ' Error Msg ' || SQLERRM ;
--                      IF PG_DEBUG < 10  THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                        IEX_DEBUG_PUB.LOGMESSAGE('CLOSE_DUNNINGS for Bill To : ' || ERRBUF);
                    END IF;
                    RETCODE := -1 ;
                    ROLLBACK TO close_dunn ;

--                    IF PG_DEBUG < 10  THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                        IEX_DEBUG_PUB.LOGMESSAGE(v_line);
                        IEX_DEBUG_PUB.LOGMESSAGE('---------->> PROCEDURE CLOSE_DUNNINGS End ERROR <<----------');
                        IEX_DEBUG_PUB.logMessage('CLOSE_DUNNINGS : ' || 'End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
                        IEX_DEBUG_PUB.LOGMESSAGE(v_line);
                    END IF;
            End ;
        end if ;
        --  clchang updated 04/18/2003 for BILL_TO level -- end

        if dunning_level in ('ALL', 'ACCOUNT') then
            Begin
                UPDATE iex_dunnings idun
                set status = 'CLOSE'
                where idun.dunning_level = 'ACCOUNT'
                and idun.status = 'OPEN'
                and dunning_object_id IN
                   (select DISTINCT id.cust_account_id
                    from iex_delinquencies id
                    where NOT EXISTS
                      (SELECT CUST_ACCOUNT_ID
                       FROM IEX_DELINQUENCIES id2
                       where id2.status IN ('PREDELINQUENT', 'DELINQUENT')
                       and id2.cust_account_id = id.cust_account_id)) ;

                FND_FILE.PUT_LINE(FND_FILE.LOG, ' <<< ACCOUNT >>>
                            Number Of Dunnings Closed..>> '|| SQL%ROWCOUNT) ;
            Exception
                WHEN OTHERS then
                    ERRBUF := 'CLOSE DUNNINGS << ACCOUNT >>  Error Code = '
                                || SQLCODE || ' Error Msg ' || SQLERRM ;
--                      IF PG_DEBUG < 10  THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                        IEX_DEBUG_PUB.LOGMESSAGE('CLOSE_DUNNINGS for Account : ' || ERRBUF);
                    END IF;
                    RETCODE := -1 ;
                    ROLLBACK TO close_dunn ;

--                    IF PG_DEBUG < 10  THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                        IEX_DEBUG_PUB.LOGMESSAGE(v_line);
                        IEX_DEBUG_PUB.LOGMESSAGE('---------->> PROCEDURE CLOSE_DUNNINGS End ERROR <<----------');
                        IEX_DEBUG_PUB.logMessage('CLOSE_DUNNINGS : ' || 'End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
                        IEX_DEBUG_PUB.LOGMESSAGE(v_line);
                    END IF;
            End ;
        end if ;

        if dunning_level in ('ALL', 'CUSTOMER') then
            Begin

            -- BEGIN jsanju for 4505461 -change sql stmt

                /*
                UPDATE iex_dunnings idun
                set status = 'CLOSE'
                where idun.dunning_level = 'CUSTOMER'
                and idun.status = 'OPEN'
                and dunning_object_id IN
                   (select DISTINCT id.party_cust_id
                    from iex_delinquencies id
                    where NOT EXISTS
                      (SELECT PARTY_CUST_ID
                       FROM IEX_DELINQUENCIES id2
                       where id2.status IN ('PREDELINQUENT', 'DELINQUENT')
                       and id2.party_cust_id = id.party_cust_id)) ;
               */
              UPDATE IEX_DUNNINGS IDUN
              SET STATUS = 'CLOSE'
              WHERE IDUN.DUNNING_LEVEL = 'CUSTOMER'
              AND   IDUN.STATUS = 'OPEN'
              and not exists  (SELECT 'x'
                               FROM IEX_DELINQUENCIES ID
                               where ID.PARTY_CUST_ID = idun.DUNNING_OBJECT_ID
                               and   ID.STATUS  IN ('PREDELINQUENT', 'DELINQUENT'));

            --END jsanju for 4505461 -change sql stmt


                FND_FILE.PUT_LINE(FND_FILE.LOG, ' <<< CUSTOMER >>>
                            Number Of Dunnings Closed..>> '|| SQL%ROWCOUNT) ;
            Exception
                WHEN OTHERS then
                    ERRBUF := 'CLOSE DUNNINGS << CUSTOMER >>  Error Code = '
                                || SQLCODE || ' Error Msg ' || SQLERRM ;
--                      IF PG_DEBUG < 10  THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                        IEX_DEBUG_PUB.LOGMESSAGE('CLOSE_DUNNINGS for Customer : ' || ERRBUF);
                    END IF;
                    RETCODE := -1 ;
                    ROLLBACK TO close_dunn ;

--                    IF PG_DEBUG < 10  THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                        IEX_DEBUG_PUB.LOGMESSAGE(v_line);
                        IEX_DEBUG_PUB.LOGMESSAGE('---------->> PROCEDURE CLOSE_DUNNINGS End ERROR <<----------');
                        IEX_DEBUG_PUB.logMessage('CLOSE_DUNNINGS : ' || 'End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
                        IEX_DEBUG_PUB.LOGMESSAGE(v_line);
                    END IF;
            End ;
        end if ;

        Commit;

--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LOGMESSAGE('CLOSE_DUNNINGS : ' || v_line);
           IEX_DEBUG_PUB.LOGMESSAGE('---------->> PROCEDURE CLOSE_DUNNINGS End NORMAL <<----------');
           IEX_DEBUG_PUB.LOGMESSAGE('CLOSE_DUNNINGS : ' || v_line);
           IEX_DEBUG_PUB.logMessage('CLOSE_DUNNINGS : ' || 'End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
        END IF;

    Exception
        WHEN OTHERS then
            ERRBUF := 'CLOSE DUNNINGS - Error Code = ' || SQLCODE || ' Error Msg ' || SQLERRM ;
--              IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LOGMESSAGE('CLOSE_DUNNINGS : ' || ERRBUF);
            END IF;
            RETCODE := -1 ;
            ROLLBACK TO close_dunn ;

--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                IEX_DEBUG_PUB.LOGMESSAGE(v_line);
                IEX_DEBUG_PUB.LOGMESSAGE('---------->> PROCEDURE CLOSE_DUNNINGS End ERROR <<----------');
                IEX_DEBUG_PUB.logMessage('CLOSE_DUNNINGS : ' || 'End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
                IEX_DEBUG_PUB.LOGMESSAGE(v_line);
            END IF;
    END ;

--
-- Begin - 01/24/2005 - Andre Araujo - This procedure uses a memory schema uses up all memory available for the session, changing it to chunks
--
/*
|| Overview:  Clean up delinquency_buffers table this will use the batch size profile and do one request or all table
||
|| Parameter:  P_REQUEST is the request Id we need to delete, if it is -1 we delete the whole table
||
|| Source Tables:  None
||
|| Target Tables:  IEX_DEL_BUFFERS
||
|| Creation date:  01/25/05 3:29:PM
||
|| Major Modifications: when             who                what
||                      01/25/05         acaraujo            created
*/
PROCEDURE CLEAR_BUFFERS2(P_REQUEST    IN      NUMBER) IS

iCount  number;
iSize   number;
i       number;

--Begin base bug 6902192 barathsr 13-Nov-2008
	--For big customers delete from IEX_DEL_BUFFERS process takes hours

l_del_count   number;
l_truncate_table VARCHAR2(60);

Begin

IEX_DEBUG_PUB.logMessage('IEX_DELINQUENCY_PUB: cleaning delinquency buffers +');
FND_FILE.PUT_LINE(FND_FILE.LOG,'IEX_DELINQUENCY_PUB: cleaning delinquency buffers +');

    select count(1) into l_del_count
    from fnd_conc_req_summary_v
    where program_application_id = 695 and
    program_short_name in ('IEXDLMGB', 'IEX_SCORE_OBJECTS') and
    phase_code in ('P', 'R')
    and status_code <> 'Q'; -- changed for bug 9251590

    IEX_DEBUG_PUB.logMessage('Running IEXDLMGB count = ' || l_del_count);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Running IEXDLMGB count = ' || l_del_count);

    if (((p_request = -1) and (l_del_count = 0)) OR ((p_request <> -1) and (l_del_count <= 2))) then
        if ((p_request = -1) and (l_del_count = 0)) then
			IEX_DEBUG_PUB.logMessage('IEX: Clear Delinquency Buffers Table cp is running and IEX: Scoring Engine Harness cp is not running, so truncating IEX_DEL_BUFFERS table...');
			FND_FILE.PUT_LINE(FND_FILE.LOG,'IEX: Clear Delinquency Buffers Table cp is running and IEX: Scoring Engine Harness cp is not running, so truncating IEX_DEL_BUFFERS table...');
		else
			IEX_DEBUG_PUB.logMessage('This is the last running instance of IEXDLMGB - truncating IEX_DEL_BUFFERS table...');
			FND_FILE.PUT_LINE(FND_FILE.LOG,'This is the last running instance of IEXDLMGB - truncating IEX_DEL_BUFFERS table...');
		end if;
        select OWNER || '.' || TABLE_NAME into l_truncate_table from sys.all_tables where table_name = 'IEX_DEL_BUFFERS';
        EXECUTE IMMEDIATE 'truncate table ' || l_truncate_table;
        IEX_DEBUG_PUB.logMessage('Done');
    else
        IEX_DEBUG_PUB.logMessage('There are other running instances of IEXDLMGB - quiting');
	FND_FILE.PUT_LINE(FND_FILE.LOG,'There are other running instances of IEXDLMGB - quiting');
    end if;

    IEX_DEBUG_PUB.logMessage('IEX_DELINQUENCY_PUB: cleaning delinquency buffers -');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'IEX_DELINQUENCY_PUB: cleaning delinquency buffers -');

    Exception
         When others then
            IEX_DEBUG_PUB.logMessage('IEX_DELINQUENCY_PUB: CLEAR_BUFFERS2: cleaning failed due to ' || sqlcode || ' ' || sqlerrm);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'IEX_DELINQUENCY_PUB: CLEAR_BUFFERS2: cleaning failed due to ' || sqlcode || ' ' || sqlerrm);


End CLEAR_BUFFERS2;

-- End base bug 6902192 barathsr 13-Nov-2008
--
-- End - 01/24/2005 - Andre Araujo - This procedure uses a memory schema uses up all memory available for the session, changing it to chunks
--

  -- clchang added 10/28/04 to fix gscc warning
  BEGIN

    G_USER_ID    := FND_GLOBAL.User_Id;
    G_Batch_Size := to_number(nvl(fnd_profile.value('IEX_BATCH_SIZE'), '1000'));
    v_line := '--------------------------------------------------------------' ;
    PG_DEBUG  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

END IEX_DELINQUENCY_PUB;

/
