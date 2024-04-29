--------------------------------------------------------
--  DDL for Package Body AS_LLOG_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_LLOG_SUMMARY_PKG" AS
/* $Header: asxopslb.pls 115.9 2004/06/11 06:29:52 pvarshne ship $ */



PROCEDURE write_log(p_debug_source NUMBER, p_fpt number, p_mssg  varchar2) IS
BEGIN
/*
     --IF G_Debug AND p_debug_source = G_DEBUG_TRIGGER THEN
        -- Write debug message to message stack
       AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, p_mssg);
     --END IF;
*/
        IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
            fnd_message.Set_Name('AS', 'AS_DEBUG_MESSAGE');
            fnd_message.Set_Token('TEXT', p_mssg );
            fnd_msg_pub.Add;
        END IF;


     IF p_debug_source = G_DEBUG_CONCURRENT THEN
            -- p_fpt (1,2)?(log : output)
            FND_FILE.put(p_fpt, p_mssg);
            FND_FILE.NEW_LINE(p_fpt, 1);
            -- If p_fpt == 2 and debug flag then also write to log file
            IF p_fpt = 2 And G_Debug THEN
               FND_FILE.put(1, p_mssg);
               FND_FILE.NEW_LINE(1, 1);
            END IF;
     END IF;

    EXCEPTION
        WHEN OTHERS THEN
         NULL;
END Write_Log;

-- Why doesn't use dbms_session.set_sql_trace(TRUE) ?
PROCEDURE trace (p_mode in boolean) is
ddl_curs integer;
v_Dummy  integer;
BEGIN
    null;
EXCEPTION WHEN OTHERS THEN
 NULL;
END trace;



PROCEDURE Precalculate_Log_data IS

BEGIN


-- clean out duplicate logs on the same LEAD_ID and LAST_UPDATE_DATE
delete from as_leads_log log
where log.log_id <>
( select max(log1.log_id)
  from as_leads_log log1
  where log1.lead_id = log.lead_id
  and log1.last_update_date = log.last_update_date);


-- initial the derivative columns and set log_start_date
update as_leads_log
set object_version_number =  nvl(object_version_number,0) + 1, log_start_date = last_update_date,
    	log_end_date = null,
	log_active_days = null,
	endday_log_flag = 'N',
	current_log = 0;


-- set log_end_date
update as_leads_log log
set object_version_number =  nvl(object_version_number,0) + 1, log.log_end_date =
	( select min(log1.last_update_date)
	  from as_leads_log log1
	  where log1.lead_id = log.lead_id
	  and log1.last_update_date > log.last_update_date);

update as_leads_log log
set object_version_number =  nvl(object_version_number,0) + 1, log.log_end_date = log.log_start_date
where log.log_end_date is null;

-- set log_active_days
update as_leads_log
set object_version_number =  nvl(object_version_number,0) + 1, log_active_days = trunc(log_end_date) - trunc(log_start_date)
where log_active_days is null;

-- set endday_log_flag
update as_leads_log log
set object_version_number =  nvl(object_version_number,0) + 1, log.endday_log_flag = 'Y'
where log.last_update_date =
	( select max(log1.last_update_date)
	  from as_leads_log log1
	  where log1.lead_id = log.lead_id
	  and trunc(log1.last_update_date) = trunc(log.last_update_date) );

-- set current_log
update as_leads_log log
set object_version_number =  nvl(object_version_number,0) + 1, log.current_log = 1
where log.last_update_date =
	( select max(log1.last_update_date)
	  from as_leads_log log1
	  where log1.lead_id = log.lead_id );

EXCEPTION WHEN OTHERS THEN
	Write_Log(G_DEBUG_CONCURRENT, 1, 'Error in Precalculate_Log_data');
        Write_Log(G_DEBUG_CONCURRENT, 1, sqlerrm);
        ROLLBACK;
END Precalculate_Log_data;



Procedure Refresh_Status_Summary(
    ERRBUF       OUT Varchar2,
    RETCODE      OUT Varchar2,
    p_debug_mode IN  Varchar2,
    p_trace_mode IN  Varchar2)
IS


CURSOR last_refresh_date  IS
	select PROGRAM_UPDATE_DATE
	from as_last_run_dates
	where PROGRAM_NAME = 'ASXRSSM';

CURSOR from_date IS
	select min(LAST_UPDATE_DATE)
	from as_leads_log;

l_this_refresh_date 	DATE;
l_last_refresh_date	DATE;


BEGIN

    IF p_debug_mode = 'Y' THEN G_Debug := TRUE; ELSE G_Debug := FALSE; END IF;
    IF p_trace_mode = 'Y' THEN trace(TRUE); ELSE trace(FALSE); END IF;
    Write_Log(G_DEBUG_CONCURRENT, 1, 'Process began: ' || to_char(sysdate,'DD-MON-RRRR:HH:MI:SS'));
    RETCODE     := 0;


    OPEN last_refresh_date;
    FETCH last_refresh_date INTO l_last_refresh_date;
    CLOSE last_refresh_date;

    IF l_last_refresh_date IS NULL THEN
        Write_Log(G_DEBUG_CONCURRENT, 1, 'This is the first time to run the program');
	OPEN from_date;
	FETCH from_date INTO l_last_refresh_date;
	CLOSE from_date;
	IF l_last_refresh_date IS NULL THEN
	    l_last_refresh_date := sysdate - 10000;
	END IF;
	-- Precalculate_Log_data;
    ELSE
  	Write_Log(G_DEBUG_CONCURRENT, 1, 'This program was last run on '|| to_char(l_last_refresh_date));
    END IF;

    l_this_refresh_date := sysdate;

    DELETE FROM AS_LLOG_STATUS_SUMMARY
    WHERE lead_id in
	( select lead_id
	  from as_leads_log
	  where last_update_date >= l_last_refresh_date );

    INSERT INTO AS_LLOG_STATUS_SUMMARY
	    (   CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
		REQUEST_ID,
		PROGRAM_ID,
		PROGRAM_APPLICATION_ID,
		PROGRAM_UPDATE_DATE,
		LEAD_ID,
		DECISION_DATE,
		STATUS_CODE,
		STATUS_START_DATE,
		STATUS_END_DATE,
		STATUS_DAYS,
		CURRENT_STATUS
	    )
    SELECT 	SYSDATE				CREATION_DATE,
		FND_GLOBAL.USER_ID		CREATED_BY,
		SYSDATE				LAST_UPDATE_DATE,
		FND_GLOBAL.USER_ID		LAST_UPDATED_BY,
		FND_GLOBAL.CONC_LOGIN_ID	LAST_UPDATE_LOGIN,
		FND_GLOBAL.Conc_Request_Id	REQUEST_ID,
		FND_GLOBAL.Conc_Program_Id	PROGRAM_ID,
		FND_GLOBAL.Prog_Appl_Id		PROGRAM_APPLICATION_ID,
		SYSDATE				PROGRAM_UPDATE_DATE,
		log.LEAD_ID			LEAD_ID,
		ld.DECISION_DATE                DECISION_DATE,
        	log.STATUS_CODE			STATUS_CODE,
        	min(log.LOG_START_DATE)         STATUS_START_DATE,
        	max(log.LOG_END_DATE)           STATUS_END_DATE,
        	sum(log.LOG_ACTIVE_DAYS)        STATUS_DAYS,
        	sum(log.CURRENT_LOG)            CURRENT_STATUS
    FROM    AS_LEADS_LOG log,
            AS_LEADS_ALL ld
    WHERE   log.ENDDAY_LOG_FLAG = 'Y'
    AND     ld.LEAD_ID = log.LEAD_ID
    AND     log.LEAD_ID IN
		( select lead_id
	  	  from as_leads_log
	  	  where last_update_date >= l_last_refresh_date )
    GROUP BY  log.LEAD_ID, ld.DECISION_DATE, log.STATUS_CODE;

    -- Update as_last_run_dates
    UPDATE AS_LAST_RUN_DATES
    SET PROGRAM_UPDATE_DATE = l_this_refresh_date,
	LAST_UPDATE_DATE = sysdate,
	LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
	LAST_UPDATE_LOGIN = FND_GLOBAL.CONC_LOGIN_ID,
	REQUEST_ID = FND_GLOBAL.Conc_Request_Id,
	PROGRAM_APPLICATION_ID = FND_GLOBAL.Prog_Appl_Id,
	PROGRAM_ID = FND_GLOBAL.Conc_Program_Id
    WHERE PROGRAM_NAME = 'ASXRSSM';
    IF (SQL%NOTFOUND) THEN
	INSERT INTO  AS_LAST_RUN_DATES
	(	LAST_UPDATE_DATE,
 		LAST_UPDATED_BY,
 		CREATION_DATE,
 		CREATED_BY,
 		LAST_UPDATE_LOGIN,
 		REQUEST_ID,
 		PROGRAM_APPLICATION_ID,
 		PROGRAM_ID,
 		PROGRAM_UPDATE_DATE,
 		PROGRAM_NAME
	)
	VALUES
	(	sysdate,
		FND_GLOBAL.USER_ID,
		sysdate,
		FND_GLOBAL.USER_ID,
		FND_GLOBAL.CONC_LOGIN_ID,
		FND_GLOBAL.Conc_Request_Id,
		FND_GLOBAL.Prog_Appl_Id,
		FND_GLOBAL.Conc_Program_Id,
		l_this_refresh_date,
		'ASXRSSM'
	);
    END IF;

    COMMIT;

    Write_Log(G_DEBUG_CONCURRENT, 1, 'Process end:   ' || to_char(sysdate,'DD-MON-RRRR:HH:MI:SS'));

EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ERRBUF := ERRBUF||'Error in Refresh_Status_Summary: '||to_char(sqlcode);
     RETCODE := FND_API.G_RET_STS_UNEXP_ERROR;
     Write_Log(G_DEBUG_CONCURRENT, 1, 'Error in Refresh_Status_Summary');
     Write_Log(G_DEBUG_CONCURRENT, 1, sqlerrm);
     ROLLBACK;
   WHEN OTHERS THEN
     ERRBUF := ERRBUF||'Error in efresh_Status_Summary: '||to_char(sqlcode);
     RETCODE := '2';
     Write_Log(G_DEBUG_CONCURRENT, 1, 'Error in Refresh_Status_Summary');
     Write_Log(G_DEBUG_CONCURRENT, 1, sqlerrm);
     ROLLBACK;
END Refresh_Status_Summary;

End AS_LLOG_SUMMARY_PKG;

/
