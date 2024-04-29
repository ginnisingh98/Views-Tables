--------------------------------------------------------
--  DDL for Package Body JTF_DIAGNOSTICLOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_DIAGNOSTICLOG" AS
/* $Header: jtfdiaglog_b.pls 120.2 2005/08/13 01:56:40 minxu noship $ */
  ----------------------------------------------------------
  -- Insert a new stat or update an existing stat
  ----------------------------------------------------------

  procedure INSERT_LOG_STATS(
	                     P_SESSIONID 		IN VARCHAR2,
	                     P_MIDTIERNODE 		IN VARCHAR2,
	                     P_APPNAME 			IN VARCHAR2,
	                     P_GROUPNAME 		IN VARCHAR2,
	                     P_TESTCLASSNAME 		IN VARCHAR2,
	                     P_TIME 			IN DATE,
	                     P_STATUS 			IN NUMBER,
	                     P_MILLISCONSUMED 		IN NUMBER,
	                     P_MODE			IN NUMBER,
	                     P_INDEX			IN NUMBER,
               	             P_INSTALLVERSION		IN VARCHAR2,
	                     P_TOOLVERSION		IN VARCHAR2,
	                     P_TESTVERSION		IN VARCHAR2,
	                     P_INPUTS			IN VARCHAR2,
	                     P_ERROR			IN VARCHAR2,
	                     P_FIXINFO			IN VARCHAR2,
	                     P_REPORT		 	IN CLOB,
	                     P_VERSIONS			IN VARCHAR2,
	                     P_DEPENDENCIES		IN VARCHAR2,
                             P_LUBID                    IN NUMBER,
		             P_SEQUENCE			OUT NOCOPY NUMBER
                           ) IS

  V_SEQUENCE NUMBER;

  BEGIN

  INSERT_LOG(P_SESSIONID, P_MIDTIERNODE, P_APPNAME, P_GROUPNAME,
	     P_TESTCLASSNAME, P_TIME, P_STATUS, P_MILLISCONSUMED,
             P_MODE, P_INDEX, P_INSTALLVERSION, P_TOOLVERSION, P_TESTVERSION,
             P_INPUTS, P_ERROR, P_FIXINFO, P_REPORT, P_VERSIONS,
             P_DEPENDENCIES, P_LUBID, V_SEQUENCE);

  P_SEQUENCE := V_SEQUENCE;

  INSERT_OR_UPDATE_STATS(P_APPNAME, P_GROUPNAME, P_TESTCLASSNAME,
                         P_TIME, P_STATUS, V_SEQUENCE, P_LUBID);


  END INSERT_LOG_STATS;


  ----------------------------------------------------------
  -- Insert a new stat or update an existing stat
  ----------------------------------------------------------

  procedure INSERT_OR_UPDATE_STATS(
                                   P_APPNAME	IN VARCHAR2,
				   P_GROUPNAME  IN VARCHAR2,
				   P_TESTCLASSNAME IN VARCHAR2,
				   P_TIME	IN DATE,
				   P_STATUS	IN NUMBER,
				   P_SEQUENCE	IN NUMBER,
                                   P_LUBID    IN NUMBER
                                  ) IS
  V_SEQUENCE NUMBER;
  V_FAIL NUMBER := 0;
  V_FAIL_TIME DATE;
  V_FAIL_SEQ NUMBER;
  V_RECORD_EXIST NUMBER := 0;

  BEGIN

      if P_STATUS <> 0 then
         V_FAIL := 1;
         V_FAIL_TIME := P_TIME;
         V_FAIL_SEQ := P_SEQUENCE;
      end if;

      select count(*) into V_RECORD_EXIST
      from JTF_DIAGNOSTIC_STATS where
      appName = P_APPNAME
      and groupName = P_GROUPNAME
      and testClassName = P_TESTCLASSNAME;

      if V_RECORD_EXIST = 0 then

             select JTF_DIAGNOSTIC_LOG_S.nextval
	     into V_SEQUENCE from DUAL;

             insert into JTF_DIAGNOSTIC_STATS(SEQUENCE, APPNAME, GROUPNAME, TESTCLASSNAME,
                 TOTALRUN, TOTALFAIL, LASTEXECUTIONTIME, LASTSTATUS,
                 LASTREPORTSEQUENCEID, LASTFAILURETIME, LASTFAILURESEQUENCEID,
                 OBJECT_VERSION_NUMBER, CREATED_BY,
                 LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, CREATION_DATE)
             values(V_SEQUENCE, P_APPNAME, P_GROUPNAME, P_TESTCLASSNAME, 1, V_FAIL, P_TIME, P_STATUS,
                 P_SEQUENCE, V_FAIL_TIME, V_FAIL_SEQ,
                 1, P_LUBID, SYSDATE, P_LUBID,
                 NULL, SYSDATE);

      else

             if (P_STATUS = 1 OR P_STATUS = 2) then

             	update JTF_DIAGNOSTIC_STATS
             	set totalRun = totalRun + 1,
                    totalFail = totalFail + 1,
                    lastExecutionTime = P_TIME,
                    lastStatus = P_STATUS,
                    lastReportSequenceID = P_SEQUENCE,
                    lastFailureTime = P_TIME,
                    lastFailureSequenceID = P_SEQUENCE,
                    last_updated_by = P_LUBID
                where appName = P_APPNAME
                  and groupName = P_GROUPNAME
                  and testClassName = P_TESTCLASSNAME;

              else

                update JTF_DIAGNOSTIC_STATS
             	set totalRun = totalRun + 1,
                    lastExecutionTime = P_TIME,
                    lastStatus = P_STATUS,
                    lastReportSequenceID = P_SEQUENCE,
                    last_updated_by = P_LUBID
                where appName = P_APPNAME
                  and groupName = P_GROUPNAME
                  and testClassName = P_TESTCLASSNAME;

              end if;

      end if;

  END INSERT_OR_UPDATE_STATS;


  ----------------------------------------------------------
  -- Insert a new QALog entry in the DB
  ----------------------------------------------------------

  procedure INSERT_LOG(
	               P_SESSIONID 		IN VARCHAR2,
	               P_MIDTIERNODE 		IN VARCHAR2,
	               P_APPNAME 		IN VARCHAR2,
	               P_GROUPNAME 		IN VARCHAR2,
	               P_TESTCLASSNAME 		IN VARCHAR2,
	               P_TIME 			IN DATE,
	               P_STATUS 		IN NUMBER,
	               P_MILLISCONSUMED 	IN NUMBER,
	               P_MODE			IN NUMBER,
	               P_INDEX			IN NUMBER,
               	       P_INSTALLVERSION		IN VARCHAR2,
	               P_TOOLVERSION		IN VARCHAR2,
	               P_TESTVERSION		IN VARCHAR2,
	               P_INPUTS			IN VARCHAR2,
	               P_ERROR			IN VARCHAR2,
	               P_FIXINFO		IN VARCHAR2,
	               P_REPORT		 	IN CLOB,
	               P_VERSIONS		IN VARCHAR2,
	               P_DEPENDENCIES		IN VARCHAR2,
                       P_LUBID                IN NUMBER,
		       P_SEQUENCE		OUT NOCOPY NUMBER
	              ) IS
  V_SEQUENCE NUMBER;

  BEGIN
      	select JTF_DIAGNOSTIC_LOG_S.nextval
	into V_SEQUENCE from DUAL;

	insert into jtf_diagnostic_log( SEQUENCE, SESSIONID, MIDTIERNODE, APPNAME, GROUPNAME, TESTCLASSNAME, TIME, STATUS, MILLISCONSUMED, TESTMODE, TESTINDEX, INSTALLVERSION, TOOLVERSION, TESTVERSION, INPUTS, ERROR,
	FIXINFO, REPORT, VERSIONS, DEPENDENCIES, OBJECT_VERSION_NUMBER,
	CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
	CREATION_DATE) values ( V_SEQUENCE, P_SESSIONID,
        P_MIDTIERNODE, P_APPNAME, P_GROUPNAME, P_TESTCLASSNAME, P_TIME, P_STATUS,
	P_MILLISCONSUMED, P_MODE, P_INDEX, P_INSTALLVERSION, P_TOOLVERSION,
	P_TESTVERSION, P_INPUTS, P_ERROR, P_FIXINFO, P_REPORT, P_VERSIONS,
	P_DEPENDENCIES, 1, P_LUBID, SYSDATE, P_LUBID,
	NULL, SYSDATE);

	P_SEQUENCE := V_SEQUENCE;

  END INSERT_LOG;

  procedure GET_REPORT_CLOB(
	                    P_SEQUENCE		IN NUMBER,
			    P_REPORT		OUT NOCOPY CLOB
		           ) IS

   BEGIN

	select REPORT into P_REPORT
        from JTF_DIAGNOSTIC_LOG
        where sequence = P_SEQUENCE
        for update;

        IF SQL%NOTFOUND THEN
		RAISE_APPLICATION_ERROR(-20000, 'Report CLOB not found');
    	END IF;

  END GET_REPORT_CLOB;


  procedure DELETE_EXPIRED_LOGS(
	                        P_EXPIRATION	IN DATE
	                       ) IS

  BEGIN

	delete from jtf_diagnostic_log
	where time <= P_EXPIRATION;

  END DELETE_EXPIRED_LOGS;


END JTF_DIAGNOSTICLOG;

/
