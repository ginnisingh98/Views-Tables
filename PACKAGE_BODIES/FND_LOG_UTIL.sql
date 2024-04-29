--------------------------------------------------------
--  DDL for Package Body FND_LOG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_LOG_UTIL" AS
/* $Header: AFUTLBEB.pls 115.9 2004/04/05 23:06:31 rmohan noship $ */

  C_SUCCESS CONSTANT NUMBER := 0;
  C_WARNING CONSTANT NUMBER := 1;
  C_ERROR CONSTANT NUMBER := 2;

  COUNT_COMMIT CONSTANT NUMBER := 500;


--------------------------------------------------------------------------------
-------------DEBUG METHODS
--------------------------------------------------------------------------------
  procedure fdebug(msg in varchar2)
  IS
  l_msg 		VARCHAR2(1);
  BEGIN
---     l_msg := dbms_utility.get_time || '   ' || msg;
---     dbms_output.put_line(dbms_utility.get_time || ' ' || msg);
---     fnd_file.put_line( fnd_file.log, dbms_utility.get_time || ' ' || msg);
     l_msg := 'm';
  END fdebug;


--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
function IS_TRANSACTION_COMPLETED(trId in NUMBER, trType in VARCHAR2
   ,sessId in NUMBER, ignoreICX in BOOLEAN) return BOOLEAN
  IS
  l_retu BOOLEAN;
  l_phase_code FND_CONCURRENT_REQUESTS.PHASE_CODE%TYPE;
  l_process_status_code FND_CONCURRENT_PROCESSES.PROCESS_STATUS_CODE%TYPE;
  l_audsid_count NUMBER;
  l_last_connect ICX_TRANSACTIONS.LAST_CONNECT%TYPE;

  BEGIN
    fdebug('In:FND_BE_UTIL.IS_TRANSACTION_COMPLETED');
    fdebug('trId:'||trId ||',trType:'||trType ||',sessId:'||sessId );
    l_retu := false;
    IF (trType = 'REQUEST') THEN
          select PHASE_CODE into l_phase_code
          from FND_CONCURRENT_REQUESTS
          where REQUEST_ID=trId;

          IF (l_phase_code='C') THEN
              l_retu:= TRUE;
          END IF;
    ELSIF (trType = 'FORM') THEN
          select  count(*) into l_audsid_count
          from GV$SESSION
          where AUDSID=trId;

          IF (l_audsid_count = 0) THEN
              l_retu:= TRUE;
          END IF;
    ELSIF (trType = 'SERVICE') THEN
          select  PROCESS_STATUS_CODE into l_process_status_code
          from FND_CONCURRENT_PROCESSES
          where  CONCURRENT_PROCESS_ID=trId;

          IF ((l_process_status_code='S') OR (l_process_status_code='K')) THEN
              l_retu:= TRUE;
          END IF;
    ELSIF (trType = 'ICX') THEN
          IF (ignoreICX = TRUE) THEN
             l_retu:= TRUE;
          ELSE
             IF (trID <> NULL) THEN
                select  LAST_CONNECT into l_last_connect
                from ICX_TRANSACTIONS
                where  TRANSACTION_ID=sessId;
             ELSE
                select  max(LAST_CONNECT) into l_last_connect
                from ICX_TRANSACTIONS
                where  SESSION_ID=sessId;
             END IF;

             IF (SYSDATE > l_last_connect + 1) THEN
                l_retu:= TRUE;
             END IF;
           END IF;

    END IF;
    fdebug('Out:FND_BE_UTIL.IS_TRANSACTION_COMPLETED');
    RETURN l_retu;
  EXCEPTION
    WHEN no_data_found THEN
       RETURN TRUE;
    WHEN OTHERS THEN
       raise;
  END IS_TRANSACTION_COMPLETED;
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
  procedure METRIC_EVENT_PNDG_MTRCS(trCtxId in number, trId in NUMBER
     , sessId in NUMBER, trType in VARCHAR2, err OUT NOCOPY VARCHAR2)
  IS
  BEGIN
    fdebug('In:FND_BE_UTIL.METRIC_EVENT_PNDG_MTRCS');
       IF (IS_TRANSACTION_COMPLETED(trId, trType, sessId, true)= TRUE) THEN
          FND_LOG.WORK_METRICS_EVENT(trCtxId);
       END IF;
    fdebug('Out:FND_BE_UTIL.METRIC_EVENT_PNDG_MTRCS');
  EXCEPTION
    WHEN OTHERS THEN
       FND_MESSAGE.CLEAR;
       FND_MESSAGE.SET_NAME(application=>'FND', name=>'AF_OAM_BE_ERR_MP');
       FND_MESSAGE.SET_TOKEN(token=>'TRANSACTION_CONTEXT_ID', value=>trCtxId);
       FND_MESSAGE.SET_TOKEN(token=>'ERR_NUM', value=>SQLCODE);
       FND_MESSAGE.SET_TOKEN(token=>'ERR_MSG', value=>SQLERRM);
       err := FND_MESSAGE.GET;
       FND_MESSAGE.CLEAR;

       fdebug('Error:FND_BE_UTIL.METRIC_EVENT_PNDG_MTRCS err msg='||err);
       --Don't raise;

  END METRIC_EVENT_PNDG_MTRCS;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--Actual Package Implementation------------------------------------------------------------------------------




--------------------------------------------------------------------------------
 procedure METRIC_EVENT_PENDING_METRICS(errbuf OUT NOCOPY VARCHAR2
      , retcode OUT NOCOPY VARCHAR2)
  IS
  err_msg VARCHAR2(2000);

  CURSOR l_cur is
    select
         distinct fltc.SESSION_ID, fltc.TRANSACTION_CONTEXT_ID, fltc.TRANSACTION_TYPE
      ,  fltc.TRANSACTION_ID
    from
        FND_LOG_TRANSACTION_CONTEXT fltc,
        FND_LOG_METRICS flm
    where
        fltc.TRANSACTION_CONTEXT_ID=flm.TRANSACTION_CONTEXT_ID
    and flm.EVENT_KEY is null;


  BEGIN
    fdebug('In:FND_BE_UTIL.MTERIC_EVENT_PENDING_METRICS');
    retcode := C_SUCCESS;
    FOR l_rec in l_cur LOOP
       err_msg := null;
       METRIC_EVENT_PNDG_MTRCS(
           l_rec.TRANSACTION_CONTEXT_ID
          ,l_rec.TRANSACTION_ID
          ,l_rec.SESSION_ID
          ,l_rec.TRANSACTION_TYPE
          ,err_msg);
       IF (err_msg is not NULL) THEN
          fnd_file.put_line( fnd_file.log, err_msg);
          retcode := C_WARNING;
       END IF;
    END LOOP;  --subs_cur

---    fdebug('errbuf:::'||errbuf);
    IF (retcode = C_WARNING) THEN
       FND_MESSAGE.CLEAR;
       FND_MESSAGE.SET_NAME(application=>'FND', name=>'AF_OAM_BE_ERR_MPS');
       errbuf:=FND_MESSAGE.GET;
       FND_MESSAGE.CLEAR;
    END IF;
    fnd_file.put_line( fnd_file.log, 'Posted metrics for all completed transactions');
    fdebug('Out:FND_BE_UTIL.MTERIC_EVENT_PENDING_METRICS');
  EXCEPTION
    WHEN OTHERS THEN
       errbuf := SQLERRM;
       retcode := C_ERROR;
       fdebug('Error:FND_BE_UTIL.MTERIC_EVENT_PENDING_METRICS msg' ||errbuf);
  END METRIC_EVENT_PENDING_METRICS;





----Testers
 procedure SYNC_EXP_DATA
  IS
  l_rows_start NUMBER;
  l_rows_end  NUMBER;
  BEGIN
  --Detelet Transaction Context infor if its relevent infor NA
  delete from FND_LOG_TRANSACTION_CONTEXT where
  TRANSACTION_TYPE = 'REQUEST' AND TRANSACTION_ID<>
  ( SELECT REQUEST_ID from FND_CONCURRENT_REQUESTS  where REQUEST_ID=TRANSACTION_ID);

  --Deletes data for which no transaction context info is available.
      ---dbms_output.put_line('IN:SYNC_EXP_DATA');
     select count(*) into l_rows_start from FND_LOG_MESSAGES;
     delete from FND_LOG_MESSAGES where
         TRANSACTION_CONTEXT_ID not in
            (select distinct TRANSACTION_CONTEXT_ID from
               FND_LOG_TRANSACTION_CONTEXT)
      ;
      select count(*) into l_rows_end from FND_LOG_MESSAGES;
      ---dbms_output.put_line('FND_LOG_MESSAGES:dlt rows out of sync'||(l_rows_end-l_rows_start));
      commit;

     select count(*) into l_rows_start from FND_LOG_METRICS;
     delete from FND_LOG_METRICS where
         TRANSACTION_CONTEXT_ID not in
            (select distinct TRANSACTION_CONTEXT_ID from
               FND_LOG_TRANSACTION_CONTEXT)
      ;
      select count(*) into l_rows_end from FND_LOG_METRICS;
      ---dbms_output.put_line('FND_LOG_METRICS:dlt rows out of sync'||(l_rows_end-l_rows_start));
      commit;

      select count(*) into l_rows_start from FND_LOG_EXCEPTIONS;
      delete from  FND_LOG_EXCEPTIONS  where  LOG_SEQUENCE not in
      (select distinct  LOG_SEQUENCE from FND_LOG_MESSAGES );
      select count(*) into l_rows_end from FND_LOG_EXCEPTIONS;
      ---dbms_output.put_line('FND_LOG_EXCEPTIONS: dlt rows out of sync'||(l_rows_end-l_rows_start));
      commit;


      select count(*) into l_rows_start from FND_LOG_UNIQUE_EXCEPTIONS;
      delete from  FND_LOG_UNIQUE_EXCEPTIONS  where  UNIQUE_EXCEPTION_ID not in
      (select distinct  UNIQUE_EXCEPTION_ID from FND_LOG_EXCEPTIONS );
      select count(*) into l_rows_end from FND_LOG_UNIQUE_EXCEPTIONS;
      ---dbms_output.put_line('FND_LOG_UNIQUE_EXCEPTIONS: dlt rows out of sync'||(l_rows_end-l_rows_start));
      commit;


      select count(*) into l_rows_start from FND_EXCEPTION_NOTES;
      delete from  FND_EXCEPTION_NOTES  where  UNIQUE_EXCEPTION_ID not in
        (select distinct  UNIQUE_EXCEPTION_ID from FND_LOG_UNIQUE_EXCEPTIONS );
      select count(*) into l_rows_end from FND_EXCEPTION_NOTES;
      ---dbms_output.put_line('FND_EXCEPTION_NOTES: dlt rows out of sync'||(l_rows_end-l_rows_start));
      commit;


      select count(*) into l_rows_start from FND_OAM_BIZEX_SENT_NOTIF;
      delete from  FND_OAM_BIZEX_SENT_NOTIF  where  UNIQUE_EXCEPTION_ID not in
        (select distinct  UNIQUE_EXCEPTION_ID from FND_LOG_UNIQUE_EXCEPTIONS );
      select count(*) into l_rows_end from FND_OAM_BIZEX_SENT_NOTIF;
      ---dbms_output.put_line('FND_OAM_BIZEX_SENT_NOTIF: dlt rows out of sync'||(l_rows_end-l_rows_start));
      commit;








      ---dbms_output.put_line('OUT:SYNC_EXP_DATA');
  EXCEPTION
    WHEN OTHERS THEN
    raise;
  END SYNC_EXP_DATA;




 END FND_LOG_UTIL;

/
