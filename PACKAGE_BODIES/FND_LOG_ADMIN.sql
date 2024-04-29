--------------------------------------------------------
--  DDL for Package Body FND_LOG_ADMIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_LOG_ADMIN" as
/* $Header: AFUTLGAB.pls 120.2.12010000.2 2009/07/17 15:48:13 tshort ship $ */

  C_PKG_NAME 	CONSTANT VARCHAR2(30) := 'FND_FUNCTION';
  C_LOG_HEAD 	CONSTANT VARCHAR2(30) := 'fnd.plsql.FND_LOG_ADMIN.';


/******************************************************************************/
/***Constants for Changes due to system Log ***********************************/
TYPE GenCursor IS REF CURSOR;
TYPE TransxCurTyp IS REF CURSOR RETURN FND_LOG_TRANSACTION_CONTEXT%ROWTYPE;
TYPE UExcIdListTyp IS TABLE OF FND_LOG_UNIQUE_EXCEPTIONS.UNIQUE_EXCEPTION_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE LogSeqListTyp IS TABLE OF FND_LOG_EXCEPTIONS.LOG_SEQUENCE%TYPE INDEX BY BINARY_INTEGER;
TYPE TrnCtxIdListTyp IS TABLE OF FND_LOG_TRANSACTION_CONTEXT.TRANSACTION_CONTEXT_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE VARCAHRListTyp IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
TYPE VARCAHRSmallListTyp IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;


C_SUCCESS CONSTANT NUMBER := 0;
C_WARNING CONSTANT NUMBER := 1;
C_ERROR CONSTANT NUMBER := 2;

C_BE_PURGE_INTERVAL CONSTANT NUMBER := 5;
COUNT_COMMIT CONSTANT NUMBER := 500;
DELETE_BLOCK CONSTANT NUMBER := 1000;
MAX_LIST_COUNT CONSTANT NUMBER := 1000;

s_rows_deleted_flm NUMBER := 0;   --FND_LOG_MESSAGES;
s_rows_deleted_fen NUMBER := 0;   --FND_EXCEPTION_NOTES
s_rows_deleted_fle NUMBER := 0;   --FND_LOG_EXCEPTIONS
s_rows_deleted_flmt NUMBER := 0;  --FND_LOG_METRICS
s_rows_deleted_flue NUMBER := 0;  --FND_LOG_UNIQUE_EXCEPTIONS
s_rows_deleted_fobsn NUMBER := 0; --FND_OAM_BIZEX_SENT_NOTIF
s_rows_deleted_fltc NUMBER := 0;  --FND_LOG_TRANSACTION_CONTEXT


---Constants used for dynamic SQL
--List
C_TrnCtxIdListTyp CONSTANT NUMBER := 0;
C_UExcIdListTyp CONSTANT NUMBER := 1;
C_LogSeqListTyp CONSTANT NUMBER := 2;

--Tr Type
C_TR_REQUEST_TYPE CONSTANT NUMBER := 0;
C_TR_SERVICE_TYPE CONSTANT NUMBER := 1;
C_TR_FORM_TYPE CONSTANT NUMBER := 2;
C_TR_ICX_TYPE CONSTANT NUMBER := 3;
C_TR_UNKNOWN_TYPE CONSTANT NUMBER := 4;

--Criteria
C_PURGE_CRITERIA_ALL NUMBER := 0;
C_PURGE_CRITERIA_START_DATE NUMBER := 1;
C_PURGE_CRITERIA_END_DATE NUMBER := 2;
C_PURGE_CRITERIA_RANGE_DATE NUMBER := 3;

C_PURGE_CRITERIA_USER NUMBER := 4;
C_PURGE_CRITERIA_SESSION NUMBER := 5;
C_PURGE_CRITERIA_USER_SESSION NUMBER := 6;

C_PURGE_CRITERIA_MODULE NUMBER := 7;
C_PURGE_CRITERIA_LEVEL NUMBER := 8;

C_DEBUG BOOLEAN := TRUE;


---Start pre 1150 methods ------------------------------------------------------


--------------------------------------------------------------------------------
--Functions pre 1159 release. These are useful for those customers who will
--migrate to 1159 and have some log data before migrations.

function delete_by_user_pre1159(
         X_USER_ID IN VARCHAR2 ) return NUMBER is
  rowcount number := 0;
  temp_rowcount number := 0;
begin
  loop
    begin
      delete from fnd_log_messages
            where rownum <= 1000
              and USER_ID = X_USER_ID
              and TRANSACTION_CONTEXT_ID is null;
      temp_rowcount := sql%rowcount;
      commit;
      rowcount := rowcount + temp_rowcount;
      exit when (temp_rowcount = 0);
    exception
      when no_data_found then
        null; /* Should never happen */
      when others then
        if ((sqlcode = 60) or (sqlcode = 4020)) then
          null;  /* Ignore rows that are deadlocked */
        else
          raise;
        end if;
    end;

  end loop;
  return rowcount;
end;



function delete_by_session_pre1159(
          X_SESSION_ID IN VARCHAR2 ) return NUMBER is
  rowcount number := 0;
  temp_rowcount number := 0;
begin
  loop
    begin
      delete from fnd_log_messages
            where rownum <= 1000
              and SESSION_ID = X_SESSION_ID
              and TRANSACTION_CONTEXT_ID is null;
      temp_rowcount := sql%rowcount;
      commit;
      rowcount := rowcount + temp_rowcount;
      exit when (temp_rowcount = 0);
    exception
      when no_data_found then
        null; /* Should never happen */
      when others then
        if ((sqlcode = 60) or (sqlcode = 4020)) then
          null;  /* Ignore rows that are deadlocked */
        else
          raise;
        end if;
    end;


  end loop;
  return rowcount;
end;

function delete_by_user_session_pre1159(
          X_USER_ID        IN VARCHAR2 ,
          X_SESSION_ID     IN VARCHAR2 ) return NUMBER is
  rowcount number := 0;
  temp_rowcount number := 0;
begin
  loop
    begin
      delete from fnd_log_messages
            where rownum <= 1000
              and USER_ID = X_USER_ID
              and SESSION_ID = X_SESSION_ID
              and TRANSACTION_CONTEXT_ID is null;
      temp_rowcount := sql%rowcount;
      commit;
      rowcount := rowcount + temp_rowcount;
      exit when (temp_rowcount = 0);
    exception
      when no_data_found then
        null; /* Should never happen */
      when others then
        if ((sqlcode = 60) or (sqlcode = 4020)) then
          null;  /* Ignore rows that are deadlocked */
        else
          raise;
        end if;
    end;


  end loop;
  return rowcount;
end;


function delete_by_module(
          X_MODULE IN VARCHAR2 ) return NUMBER is
  rowcount number := 0;
  temp_rowcount number := 0;
begin
  loop
    begin
      delete from fnd_log_messages
            where rownum <= 1000
              and module like X_MODULE
              and TRANSACTION_CONTEXT_ID is null;
      temp_rowcount := sql%rowcount;
      commit;
      rowcount := rowcount + temp_rowcount;
      exit when (temp_rowcount = 0);
    exception
      when no_data_found then
        null; /* Should never happen */
      when others then
        if ((sqlcode = 60) or (sqlcode = 4020)) then
          null;  /* Ignore rows that are deadlocked */
        else
          raise;
        end if;
    end;


  end loop;
  return rowcount;
end;


function delete_by_date_range_pre1159(
          X_START_DATE  IN DATE ,
          X_END_DATE    IN DATE ) return NUMBER is
  rowcount number := 0;
  temp_rowcount number := 0;
begin
  if((X_START_DATE is NULL) and (X_END_DATE is NULL)) then
    return delete_all;
  end if;
  loop
    begin
      if (X_START_DATE is NULL) then
        delete from fnd_log_messages
              where rownum <= 1000
              and timestamp <= X_END_DATE
              and TRANSACTION_CONTEXT_ID is null;
      elsif (X_END_DATE is NULL) then
        delete from fnd_log_messages
              where rownum <= 1000
              and timestamp >= X_START_DATE
              and TRANSACTION_CONTEXT_ID is null;
      elsif ((X_START_DATE is NOT NULL) and (X_END_DATE is NOT NULL)) then
        delete from fnd_log_messages
              where rownum <= 1000
              and timestamp >= X_START_DATE
              and timestamp <= X_END_DATE
              and TRANSACTION_CONTEXT_ID is null;
      else
        return -1; /* should never happen */
      end if;
      -- Store in temp_rowcount as commit will reset
      temp_rowcount := sql%rowcount;
      commit;
      rowcount := rowcount + temp_rowcount;
      exit when (temp_rowcount = 0);
    exception
      when no_data_found then
        null; /* Should never happen */
      when others then
        if ((sqlcode = 60) or (sqlcode = 4020)) then
          null;  /* Ignore rows that are deadlocked */
        else
          raise;
        end if;
    end;
  end loop;
  fnd_file.put_line(fnd_file.log, dbms_utility.get_time || ' delete_by_date_range_pre1159: ' ||
			'Deleted rows from fnd_log_messages ' || rowcount);
  return rowcount;
end;



/* Deletes messages at level and all levels below.*/
function delete_by_max_level(
          X_LEVEL          IN NUMBER) return NUMBER is
  rowcount number := 0;
  temp_rowcount number := 0;
begin
  /* For performance just delete all if we would anyway*/
  if (X_LEVEL <= 1) then
    return delete_all;
  end if;
  loop
    begin
      delete from fnd_log_messages
            where rownum <= 1000
              and level <= X_LEVEL
              and TRANSACTION_CONTEXT_ID is null;
      temp_rowcount := sql%rowcount;
      commit;
      rowcount := rowcount + temp_rowcount;
      exit when (temp_rowcount = 0);
    exception
      when no_data_found then
        null; /* Should never happen */
      when others then
        if ((sqlcode = 60) or (sqlcode = 4020)) then
          null;  /* Ignore rows that are deadlocked */
        else
          raise;
        end if;
    end;


  end loop;
  return rowcount;
end;


function delete_all_pre1159 return NUMBER is
  rowcount number := 0;
  temp_rowcount number := 0;
begin
  loop
    begin
      delete from fnd_log_messages
            where rownum <= 1000
              and TRANSACTION_CONTEXT_ID is null;
      temp_rowcount := sql%rowcount;
      commit;
      rowcount := rowcount + temp_rowcount;
      exit when (temp_rowcount = 0);
    exception
      when no_data_found then
        null; /* Should never happen */
      when others then
        if ((sqlcode = 60) or (sqlcode = 4020)) then
          null;  /* Ignore rows that are deadlocked */
        else
          raise;
        end if;
    end;


  end loop;
  return rowcount;
end;









---End Pre 1159 methods---------------------------------------------------------


--Start Methods for System Alert -----------------------------------------------
-------------DEBUG METHODS
--------------------------------------------------------------------------------
  procedure fdebug(msg in varchar2)
  IS
  l_msg 		VARCHAR2(1);
  BEGIN
   if (C_DEBUG) then
---     xdbms_xoutput.xput_line(dbms_utility.get_time || ' ' || msg);
     fnd_file.put_line( fnd_file.log, dbms_utility.get_time || ' ' || msg);
     l_msg := 'm';
   end if;
  END fdebug;

  procedure init
  IS
  BEGIN
    s_rows_deleted_flm   := 0;   --FND_LOG_MESSAGES;
    s_rows_deleted_fen   := 0;   --FND_EXCEPTION_NOTES
    s_rows_deleted_fle   := 0;   --FND_LOG_EXCEPTIONS
    s_rows_deleted_flmt  := 0;   --FND_LOG_METRICS
    s_rows_deleted_flue  := 0;   --FND_LOG_UNIQUE_EXCEPTIONS
    s_rows_deleted_fobsn := 0;   --FND_OAM_BIZEX_SENT_NOTIF
    s_rows_deleted_fltc  := 0;   --FND_LOG_TRANSACTION_CONTEXT
  END init;

  procedure printCount
  is
     l_count NUMBER;
  begin
     l_count := 0;

/*
    select count(*) into l_count from  FND_LOG_MESSAGES;
    fnd_file.put_line( fnd_file.log,'Rows in FND_LOG_MESSAGES=' || l_count);
    select count(*) into l_count from  FND_EXCEPTION_NOTES;
    fnd_file.put_line( fnd_file.log,'Rows in FND_EXCEPTION_NOTES=' || l_count);
    select count(*) into l_count from  FND_LOG_EXCEPTIONS;
    fnd_file.put_line( fnd_file.log,'Rows in FND_LOG_EXCEPTIONS=' || l_count);
    select count(*) into l_count from  FND_LOG_METRICS;
    fnd_file.put_line( fnd_file.log,'Rows in FND_LOG_METRICS=' || l_count);
    select count(*) into l_count from  FND_LOG_UNIQUE_EXCEPTIONS;
    fnd_file.put_line( fnd_file.log,'Rows in FND_LOG_UNIQUE_EXCEPTIONS=' || l_count);
    select count(*) into l_count from FND_OAM_BIZEX_SENT_NOTIF;
    fnd_file.put_line( fnd_file.log,'Rows in FND_OAM_BIZEX_SENT_NOTIF=' || l_count);
    select count(*) into l_count from  FND_LOG_TRANSACTION_CONTEXT;
    fnd_file.put_line( fnd_file.log,'Rows in FND_LOG_TRANSACTION_CONTEXT=' || l_count);
    select count(*) into l_count from  FND_LOG_ATTACHMENTS;
    fnd_file.put_line( fnd_file.log,'Rows in FND_LOG_ATTACHMENTS=' || l_count);
 */
  end printCount;



  procedure debugPrint(list in TrnCtxIdListTyp)
  IS
  BEGIN
     if ((list is null) or (list.count = 0)) then
        fdebug(' Null List ..TrnCtxIdListTyp');
        return;
     end if;

---     fdebug(' Start Printing ..TrnCtxIdListTyp');
     fdebug(' Count ..TrnCtxIdListTyp=' || list.count);

---     for ii in  list.FIRST..list.LAST loop
--        fdebug(ii || '...' || list(ii));
--     end loop;
---     fdebug(' End Printing ..TrnCtxIdListTyp');

  END debugPrint;

  procedure debugPrint(list in LogSeqListTyp)
  IS
  BEGIN
     if ((list is null) or (list.count = 0)) then
---        fdebug(' Null List ..LogSeqListTyp');
        return;
     end if;

---     fdebug(' Start Printing ..LogSeqListTyp');
---     fdebug(' Count ..LogSeqListTyp=' || list.count);


--     fdebug(' Start Printing ..LogSeqListTyp');
--     for ii in  list.FIRST..list.LAST loop
--        fdebug(ii || '...' || list(ii));
--    end loop;
--     fdebug(' End Printing ..LogSeqListTyp');

  END debugPrint;

  procedure debugPrint(list in UExcIdListTyp)
  IS
  BEGIN
     if ((list is null) or (list.count = 0)) then
        fdebug(' Null List ..UExcIdListTyp');
        return;
     end if;

--     fdebug(' Start Printing ..UExcIdListTyp');
     fdebug(' Count ..UExcIdListTyp=' || list.count);
--    for ii in  list.FIRST..list.LAST loop
--        fdebug(ii || '...' || list(ii));
--     end loop;
--     fdebug(' End Printing ..UExcIdListTyp');

  END debugPrint;

--------------------------------------------------------------------------------
  procedure mergelist(listFinal in out NOCOPY LogSeqListTyp, listSub in LogSeqListTyp)
  IS
  indx number := 1;
  BEGIN
     if ((listSub is null) or (listSub.count = 0)) then
        return;
     end if;

     if (listFinal is not null) then
        indx := listFinal.count + 1;
     end if;

     for ii in listSub.FIRST..listSub.LAST loop
        listFinal(indx) := listSub(ii);
        indx := indx+1;
     end loop;
  END mergelist;


  procedure mergelist(listFinal in out NOCOPY UExcIdListTyp, listSub in UExcIdListTyp)
  IS
  indx number := 1;
  BEGIN
---     fdebug('Start merge final list');
--     debugprint(listFinal);
     if (listSub.count = 0) then
---         fdebug('Nothing to merge listSub is null');
         null;
        return;
     end if;

     if (listFinal is not null) then
        indx := listFinal.count + 1;
     end if;

     for ii in listSub.FIRST..listSub.LAST loop
        listFinal(indx) := listSub(ii);
        indx := indx+1;
     end loop;

---     fdebug('end merge final');
---     debugprint(listFinal);
---     fdebug('Sublist');
---     debugprint(listSub);
  END mergelist;


  procedure mergelist(listFinal in out NOCOPY TrnCtxIdListTyp, listSub in TrnCtxIdListTyp)
  IS
  indx number := 1;
  BEGIN
     if ((listSub is null) or (listSub.count = 0)) then
        return;
     end if;

     if (listFinal is not null) then
        indx := listFinal.count + 1;
     end if;

     for ii in listSub.FIRST..listSub.LAST loop
        listFinal(indx) := listSub(ii);
        indx := indx+1;
     end loop;
  END mergelist;


--------------------------------------------------------------------------------
--Methods for dynamic sql

  function getTrSQLCriteria(pCriteria in number) return VARCHAR2
  IS
  l_retu VARCHAR2(200);
  BEGIN
     if (pCriteria = C_PURGE_CRITERIA_ALL ) then
        l_retu := '';
     elsif (pCriteria = C_PURGE_CRITERIA_START_DATE) then
        l_retu := ' and  fltc.CREATION_DATE >= :1 ';
     elsif(pCriteria = C_PURGE_CRITERIA_END_DATE ) then
        l_retu := ' and  fltc.CREATION_DATE <= :1 ';
     elsif(pCriteria = C_PURGE_CRITERIA_RANGE_DATE ) then
        l_retu := ' and  fltc.CREATION_DATE >= :1 '
          || ' and  fltc.CREATION_DATE <= :2 ';
     elsif(pCriteria = C_PURGE_CRITERIA_USER ) then
        l_retu := ' and fltc.USER_ID  = :1 ';
     elsif(pCriteria = C_PURGE_CRITERIA_SESSION ) then
        l_retu := ' and fltc.SESSION_ID  = :1 ';
     elsif(pCriteria = C_PURGE_CRITERIA_USER_SESSION) then
        l_retu := ' and fltc.USER_ID  = :1 '
           || ' and fltc.SESSION_ID = :2 ';
     end if;

---     fdebug('getTrSQLCriteria:' || l_retu);
     return l_retu;
  END getTrSQLCriteria;



  function getTrSQL(pTrType in number, pCriteria in number) return VARCHAR2
  IS
  l_retu VARCHAR2(2000);
  l_part1 VARCHAR2(250);
  l_part2 VARCHAR2(250);
  l_part3 VARCHAR2(250);
  l_part4 VARCHAR2(250);
  BEGIN
     fdebug('In getTrSQL');
     l_part3 :='';
     l_part4 :='';

     l_retu := 'select distinct fltc.TRANSACTION_CONTEXT_ID '
        || ' from FND_LOG_TRANSACTION_CONTEXT fltc ';


     if (pTrType = C_TR_REQUEST_TYPE) then
        l_part1 :=  ' where  fltc.TRANSACTION_TYPE = ''REQUEST'' ';
        l_part2 :=  ' and not exists (select null from FND_CONCURRENT_REQUESTS fcr ';
        l_part3 :=         ' where fcr.REQUEST_ID = fltc.TRANSACTION_ID and  fcr.phase_code <> ''C'')';
     elsif (pTrType = C_TR_SERVICE_TYPE) then
        l_part1 :=  ' where  fltc.TRANSACTION_TYPE = ''SERVICE'' ';
        l_part2 :=  ' and not exists (select null from FND_CONCURRENT_PROCESSES  fcp ';
        --5688407, added "U" below
        l_part3 :=         ' where fcp.CONCURRENT_PROCESS_ID = fltc.TRANSACTION_ID and  fcp.PROCESS_STATUS_CODE  not in ( ''S'', ''K'', ''U'' ))';
     elsif(pTrType = C_TR_FORM_TYPE) then
        l_part1 := ' where  fltc.TRANSACTION_TYPE = ''FORM'' ';
        l_part2 := ' and NOT EXISTS ';
        l_part3 := ' (select NULL from GV$SESSION where AUDSID= fltc.TRANSACTION_ID )';
     elsif(pTrType = C_TR_ICX_TYPE) then
        l_part1 := ' where  fltc.TRANSACTION_TYPE = ''ICX''  and((exists'
           || ' (select null  from  ICX_TRANSACTIONS it where it.TRANSACTION_ID=fltc.TRANSACTION_ID'
           || ' and  SYSDATE-1 > it.LAST_CONNECT ))';
        l_part2 := ' or(sysdate-1 > ';
        l_part3 :=     ' (select it1.LAST_CONNECT  from ICX_SESSIONS it1 where  it1.SESSION_ID=fltc.SESSION_ID))';
        l_part4 := ' or (NOT EXISTS ( SELECT null  FROM ICX_SESSIONS it1 where  it1.SESSION_ID=fltc.SESSION_ID)'
           || ' ))'
           ;
     elsif(pTrType = C_TR_UNKNOWN_TYPE) then
        l_part1 := ' where  fltc.TRANSACTION_TYPE NOT IN ';
        l_part2 := ' (''REQUEST'', ''SERVICE'', ''FORM'', ''ICX'') ';
     end if;

     fdebug('SQL1:' || l_retu);
     fdebug(l_part1);
     fdebug(l_part2);
     fdebug(l_part3);
     fdebug(l_part4);
     fdebug(getTrSQLCriteria(pCriteria));

     l_retu := l_retu || l_part1 || l_part2 || l_part3 || l_part4
        || getTrSQLCriteria(pCriteria);
     fdebug('Out getTrSQL');
     return l_retu;
  END getTrSQL;





--------------------------------------------------------------------------------
  procedure upDateRetCode(pCodeExist in out NOCOPY number, pCodeNew in number)
  IS
  BEGIN
     if (pCodeExist < pCodeNew) then
        pCodeExist := pCodeNew;
     end if;
  END upDateRetCode;
--------------------------------------------------------------------------------
  procedure doCommit
  IS
  BEGIN
     commit;
     --s_rows_deleted := s_rows_deleted + sql%rowcount;
     --fdebug('s_rows_deleted=' || s_rows_deleted);
     --if (s_rows_deleted >= COUNT_COMMIT) then
     --   commit;
     --   s_rows_deleted := 0;
     --   fdebug('Commit');
    -- end if;
  END doCommit;

--------------------------------------------------------------------------------
  function getDeleteBlock(pCurrentIndex in number, pTotalSize in number) return number
  IS
  l_retu NUMBER;
  l_start NUMBER;
  BEGIN
     if (pCurrentIndex < 1) then
        l_retu := DELETE_BLOCK;
     else
        l_retu := pCurrentIndex + DELETE_BLOCK;
     end if;

     if (l_retu > pTotalSize) then
        l_retu := pTotalSize;
     end if;

     return l_retu;
  END getDeleteBlock;

/******************************************************************************/
procedure DELETE_EXCEPTIONS_INFO(p_logSeqList in LogSeqListTyp
     , pRetCode out NOCOPY number)
  IS
  l_table VARCHAR2(25);
  l_start NUMBER;
  l_end NUMBER :=0;

  BEGIN
    fdebug('In:FND_BE_UTIL.DELETE_EXCEPTIONS_INFO rec=' || p_logSeqList.count);
    pRetCode := C_SUCCESS;

    --Check input parameters
    if (p_logSeqList is null) or (p_logSeqList.count < 1) then
       return;
    end if;

    loop
       l_start := l_end + 1;
       l_end := getDeleteBlock(l_end, p_logSeqList.count);
       exit when l_start > p_logSeqList.count;

       begin

        fdebug('Start Del FND_LOG_EXCEPTIONS');
        fdebug('l_start = ' || l_start || '  l_end = ' || l_end);

          l_table := 'FND_LOG_EXCEPTIONS';
          FORALL ii IN l_start..l_end
             delete from FND_LOG_EXCEPTIONS flem where flem.LOG_SEQUENCE=p_logSeqList(ii)
                and NOT EXISTS
                (select null from FND_LOG_EXCEPTIONS fle, FND_LOG_UNIQUE_EXCEPTIONS flue where
                   fle.LOG_SEQUENCE = flem.LOG_SEQUENCE
                   and flue.UNIQUE_EXCEPTION_ID = fle.UNIQUE_EXCEPTION_ID
                   and flue.STATUS <> 'C');

          s_rows_deleted_fle   := s_rows_deleted_fle  + sql%rowcount;   --FND_LOG_EXCEPTIONS
          doCommit;

       fdebug('Start Del FND_LOG_MESSAGES');
          l_table := 'FND_LOG_MESSAGES';

          FORALL ii IN l_start..l_end
             delete from FND_LOG_MESSAGES flm where flm.LOG_SEQUENCE=p_logSeqList(ii)
                and NOT EXISTS
                (select null from FND_LOG_EXCEPTIONS fle where
                   fle.LOG_SEQUENCE = flm.LOG_SEQUENCE
                 );

          s_rows_deleted_flm   := s_rows_deleted_flm  + sql%rowcount;   --FND_LOG_MESSAGES;
          doCommit;


          l_table := 'FND_LOG_ATTACHMENTS';
          FORALL ii IN l_start..l_end
             delete from FND_LOG_ATTACHMENTS fla where fla.LOG_SEQUENCE=p_logSeqList(ii)
                and NOT EXISTS
		      (select null from FND_LOG_EXCEPTIONS fle where fle.LOG_SEQUENCE = p_logSeqList(ii))
		    and NOT EXISTS
                 (select null from FND_LOG_MESSAGES flm where flm.LOG_SEQUENCE = p_logSeqList(ii));



          EXCEPTION
             when others then
              fdebug('Failed in DELETE_EXCEPTIONS_INFO');
              raise;
              pRetCode := C_WARNING;
--              if ((sqlcode = 60) or (sqlcode = 4020)) then
--                 null;  /* Ignore rows that are deadlocked */
--              else
--                 raise;
--              end if;
        end; ----begin

    end loop;


    fdebug('OUT:FND_BE_UTIL.DELETE_EXCEPTIONS_INFO');

  END DELETE_EXCEPTIONS_INFO;
--------------------------------------------------------------------------------
procedure DELETE_UNIQUE_EXCEPTIONS_INFO(p_UEXList UExcIdListTyp
  , pRetCode out NOCOPY number)
  IS
  l_table VARCHAR2(25);
  l_start NUMBER;
  l_end NUMBER :=0;

  BEGIN
    fdebug('In:FND_BE_UTIL.DELETE_UNIQUE_EXCEPTIONS_INFO rec:' || p_UEXList.count);
    pRetCode := C_SUCCESS;

    --Check input parameters
    if (p_UEXList is null) or (p_UEXList.count < 1) then
       return;
    end if;

    loop
       l_start := l_end + 1;
       l_end := getDeleteBlock(l_end, p_UEXList.count);
       exit when l_start > p_UEXList.count;

       begin
       fdebug('Start Del FND_EXCEPTION_NOTES');
          l_table := 'FND_LOG_MESSAGES';

          FORALL ii IN l_start..l_end
              DELETE FROM FND_EXCEPTION_NOTES fen
                 WHERE fen.UNIQUE_EXCEPTION_ID = p_UEXList(ii)
                    and NOT EXISTS
                      (SELECT null from FND_LOG_EXCEPTIONS fle
                         where fle.UNIQUE_EXCEPTION_ID = fen.UNIQUE_EXCEPTION_ID
                       );
          s_rows_deleted_fen   := s_rows_deleted_fen  + sql%rowcount;   --FND_EXCEPTION_NOTES
          doCommit;

       fdebug('Start Del FND_OAM_BIZEX_SENT_NOTIF');
          l_table := 'FND_OAM_BIZEX_SENT_NOTIF';
          FORALL ii IN l_start..l_end
              DELETE FROM FND_OAM_BIZEX_SENT_NOTIF fobsf
                 WHERE fobsf.UNIQUE_EXCEPTION_ID = p_UEXList(ii)
                    and NOT EXISTS
                     (SELECT null from FND_LOG_EXCEPTIONS fle
                        where fle.UNIQUE_EXCEPTION_ID = fobsf.UNIQUE_EXCEPTION_ID
                       );
          s_rows_deleted_fobsn := s_rows_deleted_fobsn  + sql%rowcount;   --FND_OAM_BIZEX_SENT_NOTIF
          doCommit;

       fdebug('Start Del FND_LOG_UNIQUE_EXCEPTIONS');
          l_table := 'FND_LOG_UNIQUE_EXCEPTIONS';
          FORALL ii IN l_start..l_end
              DELETE FROM FND_LOG_UNIQUE_EXCEPTIONS flue
                 WHERE   flue.UNIQUE_EXCEPTION_ID = p_UEXList(ii)
                    and NOT EXISTS
                     (SELECT null from FND_LOG_EXCEPTIONS fle
                        where fle.UNIQUE_EXCEPTION_ID = flue.UNIQUE_EXCEPTION_ID
                       );
          s_rows_deleted_flue  := s_rows_deleted_flue  + sql%rowcount;   --FND_LOG_UNIQUE_EXCEPTIONS
          doCommit;

          EXCEPTION
             when others then
              fdebug('Failed in DELETE_UNIQUE_EXCEPTIONS_INFO');
              pRetCode := C_WARNING;
              if ((sqlcode = 60) or (sqlcode = 4020)) then
                 null;  /* Ignore rows that are deadlocked */
              else
                 raise;
              end if;
       end; ----begin
    end loop;
    fdebug('Out:FND_BE_UTIL.DELETE_UNIQUE_EXCEPTIONS_INFO');

  END DELETE_UNIQUE_EXCEPTIONS_INFO;

--------------------------------------------------------------------------------
--This function deletes those unique exceptions for which there is no infor
-- in fnd_log_exceptions

procedure DELETE_UNIQUEA_EXCEPTIONS_INFO(pRetCode out NOCOPY number)
  IS
  l_table VARCHAR2(25);
  l_start NUMBER;
  l_end NUMBER :=0;
  l_UEXList UExcIdListTyp;

  BEGIN
    fdebug('In:FND_BE_UTIL.DELETE_UNIQUEA_EXCEPTIONS_INFO ');

    --Check input parameters
    select flue.UNIQUE_EXCEPTION_ID  BULK COLLECT into l_UEXList
    from
       FND_LOG_UNIQUE_EXCEPTIONS flue
    where
       NOT EXISTS
      (SELECT null from FND_LOG_EXCEPTIONS fle
          where fle.UNIQUE_EXCEPTION_ID = flue.UNIQUE_EXCEPTION_ID
      );

    DELETE_UNIQUE_EXCEPTIONS_INFO(l_UEXList,pRetCode);

    fdebug('Out:FND_BE_UTIL.DELETE_UNIQUEA_EXCEPTIONS_INFO');

END DELETE_UNIQUEA_EXCEPTIONS_INFO;

--------------------------------------------------------------------------------
--This function deletes those exceptions whose transaction Context Id is null.
-- but meets the input date range.

procedure DELETE_EXCEPTIONS_NULL_TRID(pRetCode out NOCOPY number
    ,X_START_DATE  IN DATE, X_END_DATE    IN DATE )
  IS
  l_EXList LogSeqListTyp;

  BEGIN
    fdebug('In:FND_BE_UTIL.DELETE_EXCEPTIONS_NULL_TRID');

    --Check input parameters
    select fle.LOG_SEQUENCE  BULK COLLECT into l_EXList
    from
       FND_LOG_EXCEPTIONS fle
      ,FND_LOG_UNIQUE_EXCEPTIONS flue
    where
          fle.UNIQUE_EXCEPTION_ID = flue.UNIQUE_EXCEPTION_ID
      and fle.TRANSACTION_CONTEXT_ID is null
      and flue.STATUS = 'C'
      and (X_START_DATE is null or flue.CREATION_DATE >= X_START_DATE)
      and (X_END_DATE is null or flue.CREATION_DATE <= X_END_DATE);

    DELETE_EXCEPTIONS_INFO(l_EXList ,pRetCode);

    fdebug('Out:DELETE_EXCEPTIONS_NULL_TRID');

END DELETE_EXCEPTIONS_NULL_TRID;

/******************************************************************************/
procedure DELETE_MESSAGES_INFO(p_logSeqList in LogSeqListTyp
     , pRetCode out NOCOPY number, X_START_DATE  IN DATE, X_END_DATE    IN DATE)
  IS
  l_table VARCHAR2(25);
  l_start NUMBER;
  l_end NUMBER :=0;

  BEGIN
    fdebug('In:FND_LOG_ADMIN.DELETE_MESSAGES_INFO rec=' || p_logSeqList.count);
    pRetCode := C_SUCCESS;

    --Check input parameters
    if (p_logSeqList is null) or (p_logSeqList.count < 1) then
       return;
    end if;

    loop
       l_start := l_end + 1;
       l_end := getDeleteBlock(l_end, p_logSeqList.count);
       exit when l_start > p_logSeqList.count;

       begin

        fdebug('Start Del FND_LOG_MESSAGES');
        --still need date because transaction_context_id's aren't unique
          FORALL ii IN l_start..l_end
             delete from FND_LOG_MESSAGES flm where
                    flm.TRANSACTION_CONTEXT_ID=p_logSeqList(ii)
    		    and (X_START_DATE is null or flm.TIMESTAMP >= X_START_DATE)
    		    and (X_END_DATE is null or flm.TIMESTAMP <= X_END_DATE);

          s_rows_deleted_fle   := s_rows_deleted_fle  + sql%rowcount;
          doCommit;

          EXCEPTION
             when others then
              fdebug('Failed in DELETE_MESSAGES_INFO');
              raise;
              pRetCode := C_WARNING;
        end; ----begin

    end loop;


    fdebug('OUT:FND_LOG_ADMIN.DELETE_MESSAGES_INFO');

  END DELETE_MESSAGES_INFO;

--------------------------------------------------------------------------------
--This function deletes those log messages whose transaction Context Id is
--doesn't exist in fnd_log_transaction_context but meets the input date range.

procedure DELETE_MESSAGES_INVALID_TRID(pRetCode out NOCOPY number
    ,X_START_DATE  IN DATE, X_END_DATE    IN DATE )
  IS
  l_EXList LogSeqListTyp;
  l_table VARCHAR2(25);
  l_start NUMBER;
  l_end NUMBER :=0;

  BEGIN
    fdebug('In:FND_LOG_ADMIN.DELETE_MESSAGES_INVALID_TRID');

    pRetCode := C_SUCCESS;

    --Check input parameters
    select flm.TRANSACTION_CONTEXT_ID BULK COLLECT into l_EXList
    from
       FND_LOG_MESSAGES flm
    where
        not exists (select null from FND_LOG_TRANSACTION_CONTEXT fltc
        where flm.TRANSACTION_CONTEXT_ID = fltc.TRANSACTION_CONTEXT_ID)
    and (X_START_DATE is null or flm.TIMESTAMP >= X_START_DATE)
    and (X_END_DATE is null or flm.TIMESTAMP <= X_END_DATE);

    DELETE_MESSAGES_INFO(l_EXList ,pRetCode, X_START_DATE, X_END_DATE);
    fdebug('Out:DELETE_MESSAGES_INVALID_TRID');

END DELETE_MESSAGES_INVALID_TRID;

--------------------------------------------------------------------------------
function DEL_METR_TRANS_INFO(p_TrList in TrnCtxIdListTyp
     , pRetCode out NOCOPY number) return number
  IS
  l_table VARCHAR2(30);
  l_start NUMBER;
  l_end NUMBER :=0;
  l_TrList TrnCtxIdListTyp;
  l_retu NUMBER := 0;

  BEGIN
    fdebug('In:FND_BE_UTIL.DEL_METR_TRANS_INFO' || p_TrList.count);
    pRetCode := C_SUCCESS;

    --Check input parameters
    if (p_TrList is null) or (p_TrList.count < 1) then
       return l_retu;
    end if;

    loop
       l_start := l_end + 1;
       l_end := getDeleteBlock(l_end, p_TrList.count);
       exit when l_start > p_TrList.count;

       begin
       fdebug('Start Del FND_LOG_METRICS');
          l_table := 'FND_LOG_METRICS';

          FORALL ii IN l_start..l_end
             delete from FND_LOG_METRICS flm where flm.TRANSACTION_CONTEXT_ID=p_TrList(ii)
             and NOT EXISTS
                (select null from FND_LOG_EXCEPTIONS fle WHERE fle.TRANSACTION_CONTEXT_ID=flm.TRANSACTION_CONTEXT_ID);
          s_rows_deleted_flmt  := s_rows_deleted_flmt  + sql%rowcount;   --FND_LOG_METRICS
          doCommit;


        fdebug('Start Del FND_LOG_TRANSACTION_CONTEXT');
          l_table := 'FND_LOG_TRANSACTION_CONTEXT';
          FORALL ii IN l_start..l_end
             delete from FND_LOG_TRANSACTION_CONTEXT where TRANSACTION_CONTEXT_ID=p_TrList(ii)
             and NOT EXISTS
                (select null from FND_LOG_EXCEPTIONS fle WHERE fle.TRANSACTION_CONTEXT_ID=p_TrList(ii))
             and NOT EXISTS
                (select null from FND_LOG_MESSAGES flm WHERE flm.TRANSACTION_CONTEXT_ID=p_TrList(ii));

        l_retu := sql%rowcount;
        s_rows_deleted_fltc  := s_rows_deleted_fltc  + sql%rowcount;   --FND_LOG_TRANSACTION_CONTEXT
        doCommit;
        return l_retu;
        fdebug('End Del FND_LOG_TRANSACTION_CONTEXT');

          EXCEPTION
             when others then
              fdebug('Failed in DEL_METR_TRANS_INFO');
              pRetCode := C_WARNING;
              if ((sqlcode = 60) or (sqlcode = 4020)) then
                 null;  /* Ignore rows that are deadlocked */
              else
                 raise;
              end if;

       end; ----begin
    end loop;
    fdebug('Out:FND_BE_UTIL.DEL_METR_TRANS_INFO');
  END DEL_METR_TRANS_INFO;
--------------------------------------------------------------------------------
function purgeTablesForLists(pLogSeqList in LogSeqListTyp, pUEXList in UExcIdListTyp
   , pTrnCtxIdList in TrnCtxIdListTyp, pRetCode out NOCOPY number)  return NUMBER
  is
  l_retCode number;
  l_retu number := 0;
begin
    fdebug('In purgeTablesForLists');
    fdebug('pTrnCtxIdList count=' || pTrnCtxIdList.count);
    fdebug('pLogSeqList count=' || pLogSeqList.count);
    fdebug('pUEXList count=' || pUEXList.count);

   debugPrint(pTrnCtxIdList);

   --Delete Messages and Exceptions
---   debugPrint(l_LogSeqList);
   DELETE_EXCEPTIONS_INFO(pLogSeqList, l_retCode);
   upDateRetCode(pRetCode, l_retCode);

   ---Delete UniqueExceptions
---   debugPrint(l_UEXList);
   DELETE_UNIQUE_EXCEPTIONS_INFO(pUEXList, l_retCode);
   upDateRetCode(pRetCode, l_retCode);

   ---Delete Transaction Info
   l_retu := DEL_METR_TRANS_INFO(pTrnCtxIdList, l_retCode);
   upDateRetCode(pRetCode, l_retCode);
   fdebug('Out purgeTablesForLists');
   return l_retu;
end purgeTablesForLists;

function purge(pTrCursor in out NOCOPY GenCursor, pRetCode out NOCOPY number)  return NUMBER is
  l_LogSeqList LogSeqListTyp;
  l_UEXList UExcIdListTyp;
  l_LogSeqList1 LogSeqListTyp;
  l_UEXList1 UExcIdListTyp;

  l_LogSeqListNull LogSeqListTyp;
  l_UEXListNull UExcIdListTyp;

  l_TrnCtxIdList TrnCtxIdListTyp;
  l_TrnCtxIdListNull TrnCtxIdListTyp;
  ii number;
  l_retCode number;
  l_retu number := 0;
begin
   fdebug('In purge');
   pRetCode := C_SUCCESS;
   if ((pTrCursor is null) or (pTrCursor%ISOPEN = false)) then
      return l_retu;
   end if;

   ii := 1;
   fdebug('Start creating log seq and exception list');
   LOOP
        FETCH pTrCursor INTO l_TrnCtxIdList(ii);
        EXIT WHEN pTrCursor%NOTFOUND;
        --fdebug('l_TrnCtxIdList(ii)=' || l_TrnCtxIdList(ii));


        --Collect l_UEXList
        l_UEXList1 := l_UEXListNull;
        select distinct flue.UNIQUE_EXCEPTION_ID BULK COLLECT into l_UEXList1
        from
           FND_LOG_EXCEPTIONS fle
         , FND_LOG_UNIQUE_EXCEPTIONS flue
        where
               fle.TRANSACTION_CONTEXT_ID = l_TrnCtxIdList(ii)
          and  flue.UNIQUE_EXCEPTION_ID = fle.UNIQUE_EXCEPTION_ID ---
          and  flue.STATUS = 'C';

        ---fdebug('l_UEXList1.count=' || l_UEXList1.count);
        mergelist(l_UEXList, l_UEXList1);


        --Collect LogSeq
        l_LogSeqList1 := l_LogSeqListNull;
        select LOG_SEQUENCE BULK COLLECT into l_LogSeqList1
        from
        (
            select LOG_SEQUENCE from FND_LOG_MESSAGES flm
                where flm.TRANSACTION_CONTEXT_ID = l_TrnCtxIdList(ii)
            union
            select LOG_SEQUENCE from FND_LOG_EXCEPTIONS fle
                where fle.TRANSACTION_CONTEXT_ID = l_TrnCtxIdList(ii)
                and NOT EXISTS(select null from FND_LOG_MESSAGES flm1 where flm1.LOG_SEQUENCE=fle.LOG_SEQUENCE)
        );
        ---fdebug('l_LogSeqList1.count=' || l_LogSeqList1.count);
        mergelist(l_LogSeqList, l_LogSeqList1);

        --Check if any list has more than MAX_LIST_COUNT Data. If Yes Delete All
        if (
           (l_LogSeqList.count >= MAX_LIST_COUNT)
         OR (l_UEXList.count >= MAX_LIST_COUNT)
         OR(l_TrnCtxIdList.count >= MAX_LIST_COUNT)
           ) then
           l_retu := l_retu + purgeTablesForLists(l_LogSeqList, l_UEXList, l_TrnCtxIdList, l_retCode);
           upDateRetCode(pRetCode, l_retCode);
           l_LogSeqList := l_LogSeqListNull;
           l_UEXList := l_UEXListNull;
           l_TrnCtxIdList := l_TrnCtxIdListNull;
           ii := 0;
        end if;
        ii := ii + 1;
   END LOOP;
   fdebug('ii=' || ii);
   fdebug('End creating log seq and exception list');
   l_retu := l_retu + purgeTablesForLists(l_LogSeqList, l_UEXList, l_TrnCtxIdList, l_retCode);
   upDateRetCode(pRetCode, l_retCode);

   close pTrCursor;
   commit;
   fdebug('Out purge');
   return l_retu;
end purge;
--------------------------------------------------------------------------------

procedure getDebugTrType(pList in out NOCOPY VARCAHRSmallListTyp)
is
begin
   pList(1) := 'Request';
   pList(2) := 'Service';
   pList(3) := 'Form';
   pList(4) := 'ICX';
   pList(5) := 'Unknown';
end;



--------------------------------------------------------------------------------
--Specification APIS
/******************************************************************************/
/******************************************************************************/
function delete_by_date_range(
          X_START_DATE  IN DATE ,
          X_END_DATE    IN DATE ) return NUMBER is
   rowcount number := 0;
   l_retCode number;

   l_sqlList VARCAHRListTyp;
   l_debugList VARCAHRSmallListTyp;
   l_GenCur GenCursor;

   l_criteria NUMBER;
   l_param1 DATE;
   l_sessionId NUMBER;
begin
    fdebug ('In  - delete_by_date_range -calling old');
    init;
    -- printCount;
    s_rows_deleted_flm := delete_by_date_range_pre1159(X_START_DATE, X_END_DATE);

    if((X_START_DATE is NULL) and (X_END_DATE is NULL)) then
       return delete_all;
    end if;

    if (X_START_DATE is NULL) then
       l_criteria := C_PURGE_CRITERIA_END_DATE;
       l_param1 := X_END_DATE;
    elsif (X_END_DATE is NULL) then
       l_criteria := C_PURGE_CRITERIA_START_DATE;
       l_param1 := X_START_DATE;
    else
       l_criteria := C_PURGE_CRITERIA_RANGE_DATE;
    end if;

    l_sqlList(1) := getTrSQL(C_TR_REQUEST_TYPE, l_criteria);
    l_sqlList(2) := getTrSQL(C_TR_SERVICE_TYPE, l_criteria);
    l_sqlList(3) := getTrSQL(C_TR_FORM_TYPE, l_criteria);
    l_sqlList(4) := getTrSQL(C_TR_ICX_TYPE, l_criteria);
    l_sqlList(5) := getTrSQL(C_TR_UNKNOWN_TYPE, l_criteria);

    getDebugTrType(l_debugList);

    for ii in l_sqlList.FIRST..l_sqlList.LAST loop
       if (l_criteria = C_PURGE_CRITERIA_RANGE_DATE) then
          open l_GenCur for l_sqlList(ii) using X_START_DATE, X_END_DATE;
       else
          open l_GenCur for l_sqlList(ii) using l_param1;
       end if;
       fdebug ('Purging - ' || l_debugList(ii));
       rowcount := rowcount + purge(l_GenCur, l_retCode);
       fdebug ('total rows - ' || rowcount);
    end loop;

    --Delete the exceptions whose transaction context id is null.
    DELETE_EXCEPTIONS_NULL_TRID(l_retCode, X_START_DATE, X_END_DATE);
    commit;

    --Delete abondoned attachements
    delete from FND_LOG_ATTACHMENTS fla where NOT EXISTS
      (select null from FND_LOG_EXCEPTIONS fle where fle.LOG_SEQUENCE = fla.LOG_SEQUENCE)
      and NOT EXISTS (select null from FND_LOG_MESSAGES flm where flm.LOG_SEQUENCE = fla.LOG_SEQUENCE );
    commit;

    --delete the abondoned unique exceptions;
    DELETE_UNIQUEA_EXCEPTIONS_INFO(l_retCode);
    commit;

    --Delete the messages whose transaction context id doesn't exist in
    --fnd_log_transaction_context.
    DELETE_MESSAGES_INVALID_TRID(l_retCode, X_START_DATE, X_END_DATE);
    commit;

    printCount;
    fdebug ('Out  - delete_by_date_range');
    return rowcount;
    exception
      when others then
        fdebug ('in error delete_by_date_range: ' || SQLCODE);
        if l_GenCur %ISOPEN then close  l_GenCur; end if;
        raise;
end delete_by_date_range;

--------------------------------------------------------------------------------
function delete_by_user(
         X_USER_ID IN VARCHAR2 ) return NUMBER is
   rowcount number := 0;
   l_retCode number;

   l_sqlList VARCAHRListTyp;
   l_debugList VARCAHRSmallListTyp;
   l_GenCur GenCursor;
   l_userid NUMBER;
begin
    fdebug ('In  - delete_by_user');
    init;
    s_rows_deleted_flm := delete_by_user_pre1159(X_USER_ID);
    rowcount := 0;

    if ( X_USER_ID is null ) then
       return rowcount;
    end if;

    l_userid := to_number(X_USER_ID);

    C_DEBUG := true;
    fdebug ('getPurgeSQLS - Request');
    l_sqlList(1) := getTrSQL(C_TR_REQUEST_TYPE, C_PURGE_CRITERIA_USER);
    l_sqlList(2) := getTrSQL(C_TR_SERVICE_TYPE, C_PURGE_CRITERIA_USER);
    l_sqlList(3) := getTrSQL(C_TR_FORM_TYPE, C_PURGE_CRITERIA_USER);
    l_sqlList(4) := getTrSQL(C_TR_ICX_TYPE, C_PURGE_CRITERIA_USER);
    l_sqlList(5) := getTrSQL(C_TR_UNKNOWN_TYPE, C_PURGE_CRITERIA_USER);

    getDebugTrType(l_debugList);


    for ii in l_sqlList.FIRST..l_sqlList.LAST loop
       open l_GenCur for l_sqlList(ii) using l_userid;
       fdebug ('Purging - ' || l_debugList(ii));
       rowcount := rowcount + purge(l_GenCur, l_retCode);
    end loop;

    printCount;
    fdebug ('Out  - delete_by_user');

    commit;
    return rowcount;
    exception
      when others then
        fdebug ('in error' || SQLCODE);
        if l_GenCur %ISOPEN then close  l_GenCur; end if;
        raise;
end delete_by_user;


--------------------------------------------------------------------------------
function delete_by_session(
         X_SESSION_ID IN VARCHAR2 ) return NUMBER is
   rowcount number := 0;
   l_retCode number;

   l_sqlList VARCAHRListTyp;
   l_debugList VARCAHRSmallListTyp;
   l_GenCur GenCursor;
   l_sessionId NUMBER;
begin
    fdebug ('In  - delete_by_session');
    init;
    s_rows_deleted_flm := delete_by_session_pre1159(X_SESSION_ID);
    rowcount := 0;

    if ( X_SESSION_ID is null ) then
       return rowcount;
    end if;

    l_sessionId := to_number(X_SESSION_ID);

    l_sqlList(1) := getTrSQL(C_TR_REQUEST_TYPE, C_PURGE_CRITERIA_SESSION);
    l_sqlList(2) := getTrSQL(C_TR_SERVICE_TYPE, C_PURGE_CRITERIA_SESSION);
    l_sqlList(3) := getTrSQL(C_TR_FORM_TYPE, C_PURGE_CRITERIA_SESSION);
    l_sqlList(4) := getTrSQL(C_TR_ICX_TYPE, C_PURGE_CRITERIA_SESSION);
    l_sqlList(5) := getTrSQL(C_TR_UNKNOWN_TYPE, C_PURGE_CRITERIA_SESSION);

    getDebugTrType(l_debugList);

    for ii in l_sqlList.FIRST..l_sqlList.LAST loop
       open l_GenCur for l_sqlList(ii) using l_sessionId;
       fdebug ('Purging - ' || l_debugList(ii));
       rowcount := rowcount + purge(l_GenCur, l_retCode);
    end loop;

    printCount;
    fdebug ('Out  - delete_by_session');
    commit;
    return rowcount;
    exception
      when others then
        fdebug ('in error delete_by_session: ' || SQLCODE);
        if l_GenCur %ISOPEN then close  l_GenCur; end if;
        raise;
end delete_by_session;

--------------------------------------------------------------------------------
function delete_by_user_session(
          X_USER_ID        IN VARCHAR2,
          X_SESSION_ID     IN VARCHAR2 ) return NUMBER is
   rowcount number := 0;
   l_retCode number;

   l_sqlList VARCAHRListTyp;
   l_debugList VARCAHRSmallListTyp;
   l_GenCur GenCursor;

   l_userId NUMBER;
   l_sessionId NUMBER;
begin
    fdebug ('In  - delete_by_user_session');
    init;
    s_rows_deleted_flm := delete_by_user_session_pre1159(X_USER_ID, X_SESSION_ID);
    rowcount := 0;

    if (X_USER_ID is null ) or ( X_SESSION_ID is null ) then
       return rowcount;
    end if;

    l_userId := to_number(X_USER_ID);
    l_sessionId := to_number(X_SESSION_ID);

    l_sqlList(1) := getTrSQL(C_TR_REQUEST_TYPE, C_PURGE_CRITERIA_USER_SESSION);
    l_sqlList(2) := getTrSQL(C_TR_SERVICE_TYPE, C_PURGE_CRITERIA_USER_SESSION);
    l_sqlList(3) := getTrSQL(C_TR_FORM_TYPE, C_PURGE_CRITERIA_USER_SESSION);
    l_sqlList(4) := getTrSQL(C_TR_ICX_TYPE, C_PURGE_CRITERIA_USER_SESSION);
    l_sqlList(5) := getTrSQL(C_TR_UNKNOWN_TYPE, C_PURGE_CRITERIA_USER_SESSION);

    getDebugTrType(l_debugList);

    for ii in l_sqlList.FIRST..l_sqlList.LAST loop
       open l_GenCur for l_sqlList(ii) using l_userId, l_sessionId;
       fdebug ('Purging - ' || l_debugList(ii));
       rowcount := rowcount + purge(l_GenCur, l_retCode);
    end loop;

    printCount;
    fdebug ('Out  - delete_by_user_session');
    commit;
    return rowcount;
    exception
      when others then
        fdebug ('in error delete_by_user_session: ' || SQLCODE);
        if l_GenCur %ISOPEN then close  l_GenCur; end if;
        raise;
end delete_by_user_session;

--------------------------------------------------------------------------------
--function delete_by_max_level   Use old API
--------------------------------------------------------------------------------
function delete_all  return NUMBER is
   rowcount number := 0;
   l_retCode number;

   l_sqlList VARCAHRListTyp;
   l_debugList VARCAHRSmallListTyp;
   l_GenCur GenCursor;
begin
    fdebug ('In  - delete_all');
    init;
    s_rows_deleted_flm := delete_all_pre1159;
    rowcount := 0;

    l_sqlList(1) := getTrSQL(C_TR_REQUEST_TYPE, C_PURGE_CRITERIA_ALL);
    l_sqlList(2) := getTrSQL(C_TR_SERVICE_TYPE, C_PURGE_CRITERIA_ALL);
    l_sqlList(3) := getTrSQL(C_TR_FORM_TYPE, C_PURGE_CRITERIA_ALL);
    l_sqlList(4) := getTrSQL(C_TR_ICX_TYPE, C_PURGE_CRITERIA_ALL);
    l_sqlList(5) := getTrSQL(C_TR_UNKNOWN_TYPE, C_PURGE_CRITERIA_ALL);

    getDebugTrType(l_debugList);

    for ii in l_sqlList.FIRST..l_sqlList.LAST loop
       open l_GenCur for l_sqlList(ii);
       fdebug ('Purging - ' || l_debugList(ii));
       rowcount := rowcount + purge(l_GenCur, l_retCode);
    end loop;


    printCount;
    fdebug ('Out  - delete_all');
    commit;
    return rowcount;
    exception
      when others then
        fdebug ('in error delete_all: ' || SQLCODE);
        if l_GenCur %ISOPEN then close  l_GenCur; end if;
        raise;
end delete_all;
---------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------
/** Concurrent Program ********************************************************/

procedure delete_by_date_i( errbuf out NOCOPY varchar2,
                           retcode out NOCOPY varchar2,
                         last_date  in varchar2 ) is
  l_api_name  CONSTANT VARCHAR2(30) := 'DELETE_BY_DATE_I';
  numrows NUMBER;
  msgbuf varchar2(2000);
  last_dt DATE;
begin

   if ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name ||'(' ||
          'last_date=>'|| last_date||');');
   end if;

   /* Convert character string to date */
   if(last_date is NULL) then
     last_dt := NULL; /* NULL means for all dates */
   else
     last_dt := FND_CONC_DATE.STRING_TO_DATE(last_date);
     if(last_dt is NULL) then
       errbuf := 'Unexpected error converting character string to date:'
                 ||last_date;
       retcode := '2';
       FND_FILE.put_line(FND_FILE.log,errbuf);
       if ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
            c_log_head || l_api_name || '.end_exception',
            'returning from delete_by_date with date exception. last_date='
               ||last_date);
       end if;
       return;
     end if;
   end if;

   fnd_message.set_name('FND', 'PURGING_UP_TO_DATE');
   fnd_message.set_token('ENTITY', 'FND_LOG_MESSAGES');
   if (last_date is NULL) then
     fnd_message.set_token('DATE', 'WF_ALL', TRUE);
   else
     fnd_message.set_token('DATE', last_date);
   end if;
   msgbuf := fnd_message.get;
   FND_FILE.put_line(FND_FILE.log, msgbuf);

   /* Delete from the date back in time */
   numrows := delete_by_date_range(NULL, last_dt);

   fnd_message.set_name('FND', 'GENERIC_ROWS_PROCESSED');
   fnd_message.set_token('ROWS', numrows);
   msgbuf := fnd_message.get;
   FND_FILE.put_line(FND_FILE.log, msgbuf);

   if ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end',
          'returning from delete_by_date_i.  numrows='||numrows);
   end if;
exception
   when others then
     errbuf := sqlerrm;
     retcode := '2';
     FND_FILE.put_line(FND_FILE.log,errbuf);
     if ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end_exception',
          'returning from delete_by_date with exception.  numrows='||numrows);
     end if;
     raise;
end delete_by_date_i;




/* Delete data from fnd_log_messages only - Used by Java UI */

function delete_by_sequence(
         pLogSeqList IN VARCHAR2) return NUMBER is
begin
    fdebug ('In  - delete_by_Sequence');

    if ( pLogSeqList is null ) then
       return 0;
    end if;

    delete from  FND_LOG_MESSAGES flm
       where
          flm.LOG_SEQUENCE = pLogSeqList;
    fdebug ('Out  - delete_by_Sequence');
    commit;
    return 1;
end delete_by_sequence;

------------------------------------------------------------------------------------------------
/* Delet data from fnd_log_messages only - Used by Java UI */
function delete_by_seqarray(numArrayList IN FND_ARRAY_OF_NUMBER_25) return NUMBER is
  ii number := 0;
  begin
      fdebug ('In  - delete_by_seqarray');
      for ii in  numArrayList.FIRST..numArrayList.LAST loop
	   delete from
	         FND_LOG_MESSAGES flm  where flm.LOG_SEQUENCE = numArrayList(ii);
      END LOOP;
      commit;
      fdebug ('Out  - delete_by_seqarray, deleted ' || numArrayList.COUNT || ' rows');
      return numArrayList.COUNT;
  end delete_by_seqarray;
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Initializes the apps context to SYSADMIN.
--------------------------------------------------------------------------------
procedure apps_initialize
is
   l_user_id number;
   l_resp_id number;
   l_resp_appl_id number;
begin
   select u.user_id
   into l_user_id
   from fnd_user u
   where u.user_name = 'SYSADMIN';

   select r.application_id,
          r.responsibility_id
   into l_resp_appl_id,
        l_resp_id
   from fnd_application a,
        fnd_responsibility r
   where r.application_id = a.application_id
   and a.application_short_name = 'SYSADMIN'
   and r.responsibility_key = 'SYSTEM_ADMINISTRATOR';

   fnd_global.apps_initialize(user_id      => l_user_id,
                              resp_id      => l_resp_id,
                              resp_appl_id => l_resp_appl_id);
end apps_initialize;

/* Checks if the 'Purge Debug Log' CP is running, and submits
   it if its not. Called by aflogcustart.sql */
procedure start_purge_cp is
   l_request_id number;
   l_phase varchar2(30);
   l_status varchar2(30);
   l_dev_phase varchar2(30);
   l_dev_status varchar2(30);
   l_message varchar2(2000);
   l_request_status_return boolean;
   l_repeat_options_return boolean;
   l_submit_request_return number;

   l_cleanup_repeat_interval number;
   l_cleanup_app_short_name varchar2(50);
   l_cleanup_program varchar2(30);
  begin
   l_cleanup_repeat_interval := 1;
   l_cleanup_app_short_name := 'FND';
   l_cleanup_program := 'FNDLGPRG';

  -- see if the cleanup process is already there

   l_request_status_return := fnd_concurrent.get_request_status(
                                 request_id     => l_request_id,
                                 appl_shortname => l_cleanup_app_short_name,
                                 program        => l_cleanup_program,
                                 phase          => l_phase,
                                 status         => l_status,
                                 dev_phase      => l_dev_phase,
                                 dev_status     => l_dev_status,
                                 message        => l_message);

   if(l_request_id is null or l_status = 'Cancelled') then
      -- Submit the Request with repeating option

      apps_initialize();

      l_repeat_options_return := fnd_request.set_repeat_options(
                                    repeat_interval => l_cleanup_repeat_interval,
                                    increment_dates => 'Y');

      l_submit_request_return := fnd_request.submit_request(
                                    application => l_cleanup_app_short_name,
                                    program     => l_cleanup_program,
                                    argument1   => FND_DATE.date_to_canonical(sysdate-7));
      fdebug('Submitted id=' || l_submit_request_return);
      commit;
   else
      -- the cleanup request has already been submitted so no action is required
      fdebug('Already pending id=' || l_request_id ||
         '; status=' || l_status || '; dev_status=' || l_dev_status);
   end if;
  end start_purge_cp;

function self_test return varchar2 is
  rows number;
  result varchar2(2000) := '';
 test_date varchar2(255) := '25-'||'MAY-'||'1970';
 test_mask varchar2(255) := 'DD'||'-MON-'||'RRRR';
begin
 result := result
          || 'If successful, the following will be a string of all 1s:';

delete from fnd_log_messages where user_id = 62202999;

insert into fnd_log_messages
(module, log_level, message_text, session_id, user_id,
  timestamp, log_sequence)
 values
('fnd.src.dict.afdict.afdwarn.tom_test_module', 5,
'This is a test log message', 62202999, 62202999,
 to_date(test_date, test_mask),  62202999);

 rows := fnd_log_admin.delete_by_user(62202999);
 result := result || rows ;



delete from fnd_log_messages where user_id = 62202999;

insert into fnd_log_messages
(module, log_level, message_text, session_id, user_id,
  timestamp, log_sequence)
 values
('fnd.src.dict.afdict.afdwarn.tom_test_module', 5,
'This is a test log message', 62202999, 62202999,
 to_date(test_date, test_mask),  62202999);

rows := fnd_log_admin.delete_by_session(62202999);
result := result || rows ;




delete from fnd_log_messages where user_id = 62202999;

insert into fnd_log_messages
(module, log_level, message_text, session_id, user_id,
  timestamp, log_sequence)
 values
('fnd.src.dict.afdict.afdwarn.tom_test_module', 5,
'This is a test log message', 62202999, 62202999,
 to_date(SYSDATE+500, test_mask),  62202999);

/* Dangerous so not doing this test */
-- rows := fnd_log_admin.delete_by_date_range(SYSDATE+499,NULL);
-- result := result || rows ;




delete from fnd_log_messages where user_id = 62202999;

insert into fnd_log_messages
(module, log_level, message_text, session_id, user_id,
  timestamp, log_sequence)
 values
('fnd.src.dict.afdict.afdwarn.tom_test_module', 5,
'This is a test log message', 62202999, 62202999,
 to_date(SYSDATE+500, test_mask),  62202999);

 rows := fnd_log_admin.delete_by_date_range(SYSDATE+499, SYSDATE+501);
 result := result || rows ;




delete from fnd_log_messages where user_id = 62202999;

insert into fnd_log_messages
(module, log_level, message_text, session_id, user_id,
  timestamp, log_sequence)
 values
('fnd.src.dict.afdict.afdwarn.tom_test_module', 5,
'This is a test log message', 62202999, 62202999,
 to_date(SYSDATE+500, test_mask),  62202999);

/* Not doing this test because it's destructive */
-- rows := fnd_log_admin.delete_by_date_range(NULL,SYSDATE+501);
-- result := result || rows ;




delete from fnd_log_messages where user_id = 62202999;

insert into fnd_log_messages
(module, log_level, message_text, session_id, user_id,
  timestamp, log_sequence)
 values
('fnd.src.dict.afdict.afdwarn.tom_test_module', 1,
'This is a test log message', 62202999, 62202999,
 to_date(test_date, test_mask),  62202999);

/* Not doing this test because it's destructive */
-- rows := fnd_log_admin.delete_by_max_level(1);
-- result := result || rows ;




delete from fnd_log_messages where user_id = 62202999;

insert into fnd_log_messages
(module, log_level, message_text, session_id, user_id,
  timestamp, log_sequence)
 values
('fnd.src.dict.afdict.afdwarn.tom_test_module', 5,
'This is a test log message', 62202999, 62202999,
 to_date(test_date, test_mask),  62202999);

 rows := fnd_log_admin.delete_by_user_session(62202999, 62202999);
 result := result || rows ;




insert into fnd_log_messages
(module, log_level, message_text, session_id, user_id,
  timestamp, log_sequence)
 values
('fnd.src.dict.afdict.afdwarn.tom_test_module', 5,
'This is a test log message', 62202999, 62202999,
 to_date(test_date, test_mask),  62202999);

 rows := fnd_log_admin.delete_by_module(
          'fnd.src.dict.afdict.afdwarn.tom_test_module');
 result := result || rows;



 return result;
end SELF_TEST;

end FND_LOG_ADMIN;

/
