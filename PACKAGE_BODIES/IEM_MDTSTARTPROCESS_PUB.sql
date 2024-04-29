--------------------------------------------------------
--  DDL for Package Body IEM_MDTSTARTPROCESS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_MDTSTARTPROCESS_PUB" as
/* $Header: iempcmsb.pls 120.2 2005/12/27 17:22:49 rtripath ship $*/

G_PKG_NAME CONSTANT varchar2(30) :='IEM_MDTSTARTPROCESS_PUB ';
--G_RETRY_FOLDER		varchar2(50):='/'||IEM_IM_SETUP_PVT.G_RetryFldrName;
--G_ADMIN_FOLDER		varchar2(50):='/'||IEM_IM_SETUP_PVT.G_AdminFldrName;
G_RETRY_FOLDER		varchar2(50):='/Retry';
G_ADMIN_FOLDER		varchar2(50):='/Admin';
G_DEFAULT_FOLDER	varchar2(50):='/Inbox';
G_IM_LINK			varchar2(90);
STOP_ALL_WORKERS        EXCEPTION;
PROCEDURE LaunchProcess(ERRBUF OUT NOCOPY VARCHAR2,
				    ERRRET    OUT NOCOPY VARCHAR2,
				p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
  			p_workflowProcess in varchar2 ,
 			p_Item_Type	 in varchar2 ,
			p_qopt	in varchar2:='NO_WAIT',
			p_counter	in number
			 ) IS
		l_api_name        		VARCHAR2(255):='LaunchProcess';
		l_api_version_number 	NUMBER:=1.0;
		Itemuserkey		varchar2(30) := 'iemmail_preproc';
		l_itemkey		varchar2(30);
  		l_msg_count 		number;
  		l_seq 		number;
		l_Error_Message           VARCHAR2(2000);
 		l_call_status             BOOLEAN;
  		l_return_status varchar2(6);
 		l_msg_data varchar2(1000);
		l_exit		varchar2(1):='T';
		l_status varchar2(1);
		l_counter	number:=1;
		l_errbuf		varchar2(100);
		l_errret		varchar2(10);
          l_rphase      varchar2(30);
          l_rstatus     varchar2(30);
          l_dphase      varchar2(30);
          l_dstatus     varchar2(30);
          l_message     varchar2(240);
          l_request_id  number;
          l_counter2    number:=0;
          l_UProcess_ID number;
          l_UTerminal   varchar2(50);
          l_UNode       varchar2(50);
          l_UName       varchar2(50);
          l_UProgram    varchar2(50);
BEGIN
-- Standard Start of API savepoint
SAVEPOINT		LaunchProcess_PUB;
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
						     p_api_version_number,
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

   BEGIN
   SELECT VALUE into l_status from IEM_COMP_RT_STATS
   WHERE TYPE='MAILPROC' and PARAM='RUNTIME STATUS';
   EXCEPTION WHEN NO_DATA_FOUND THEN
   INSERT into IEM_COMP_RT_STATS
			(
   			COMP_RT_STATS_ID,
   			TYPE,
   			PARAM,
   			VALUE,
   			LAST_UPDATED_BY,
   			LAST_UPDATE_DATE)
   VALUES
   			(-1,
    			'MAILPROC',
   			'RUNTIME STATUS',
   			'T',
   			99999,
  			SYSDATE);
  WHEN TOO_MANY_ROWS  THEN
  delete from iem_comp_rt_Stats
  WHERE TYPE='MAILPROC' and PARAM='RUNTIME STATUS'
  and rownum<
  (select count(*) from iem_comp_rt_stats
  WHERE TYPE='MAILPROC' and PARAM='RUNTIME STATUS');
  WHEN OTHERS  THEN
  NULL;
  END;
  IF l_status='F'
     THEN RAISE STOP_ALL_WORKERS;
  END IF;
  -- Fix for bug 3410951
  --UPDATE IEM_COMP_RT_STATS
  --set VALUE='T'
  --WHERE TYPE='MAILPROC' and PARAM='RUNTIME STATUS';

	LOOP
		BEGIN
		 SELECT value into l_status from iem_comp_rt_stats
		 WHERE type='MAILPROC' and param='RUNTIME STATUS';
		 EXIT when l_status='F';
                 --IF l_status='F'
                 --    THEN RAISE STOP_ALL_WORKERS;
                 --END IF;
		 EXCEPTION WHEN OTHERS THEN
		 EXIT;
		END;

               -- Added new procedure with new parameters
			IEM_EMAIL_PROC_PVT.PROC_EMAILS(ERRBUF=>l_errbuf,
		   	ERRRET=>l_errret,
		   	p_api_version_number=>1.0,
			p_init_msg_list=>p_init_msg_list,
			p_commit=>p_commit,
		   	p_count=>1);
			COMMIT;
			l_counter:=l_counter+1;
			IF p_counter is not null and p_qopt='NO_WAIT' then
				EXIT when l_counter>p_counter;
			END IF;
	END LOOP;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO LaunchProcess_PUB;
        FND_MESSAGE.SET_NAME('IEM','IEM_LAUNCHPROCESS_EXEC_ERROR');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_Error_Message);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO LaunchProcess_PUB;
        FND_MESSAGE.SET_NAME('IEM','IEM_LAUNCHPROCESS_UNXPTD_ERR');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_Error_Message);
   WHEN STOP_ALL_WORKERS THEN
        -- Get a current IEM Concurrent worker id.
        l_call_status :=FND_CONCURRENT.GET_REQUEST_STATUS(l_request_id, 'IEM', 'IEMMDTWW', l_rphase,l_rstatus,l_dphase,l_dstatus,l_message);
        IF l_call_status = false THEN
            fnd_file.put_line(fnd_file.log, l_message);
            l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',l_message);

        ELSE -- call staus is true
            -- Cancel request id
            l_call_status :=FND_CONCURRENT.CANCEL_REQUEST(l_request_id,l_Error_Message);

            IF l_call_status = false THEN
                  -- Try again
                  l_counter2 :=0;
                  LOOP -- Sleep while other worker is terminating
                      l_counter2 := l_counter2 +1;
                      EXIT when l_counter2 = 100000000;
                  END LOOP;
                  l_call_status :=FND_CONCURRENT.GET_REQUEST_STATUS(l_request_id, 'IEM', 'IEMMDTWW', l_rphase,l_rstatus,l_dphase,l_dstatus,l_message);
                  l_call_status :=FND_CONCURRENT.CANCEL_REQUEST(l_request_id,l_Error_Message);
                  IF l_call_status = false THEN
                      fnd_file.put_line(fnd_file.log, l_Error_Message);
                      l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',l_Error_Message);
                  ELSE -- call ststus is true
                      l_call_status :=FND_CONCURRENT.WAIT_FOR_REQUEST(l_request_id, 60, 600, l_rphase, l_rstatus, l_dphase, l_dstatus, l_message);
                      IF l_call_status = false THEN
                          fnd_file.put_line(fnd_file.log, l_Error_Message);
                          l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',l_message);
                      END IF;
                  END IF;

            ELSE  -- Call status is True
                  l_call_status :=FND_CONCURRENT.WAIT_FOR_REQUEST(l_request_id, 60, 600, l_rphase, l_rstatus, l_dphase, l_dstatus, l_message);
                  IF  l_call_status = false OR l_dstatus='TERMINATING' THEN
                      l_call_status :=FND_CONCURRENT.CHECK_LOCK_CONTENTION('', l_request_id, l_UProcess_ID, l_UTerminal, l_UNode, l_UName, l_UProgram);
                      fnd_file.put_line(fnd_file.log, l_message);
                      l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING', ' '||l_UProcess_ID||' '||l_UName||' '||l_UProgram);
                  END IF;
             END IF;
        END IF;
        --l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',' '||l_request_id||' '||l_Error_Message||' '||l_counter2);
   WHEN OTHERS THEN
	ROLLBACK TO LaunchProcess_PUB;
        FND_MESSAGE.SET_NAME('IEM','IEM_LAUNCHPROCESS_OTHER_ERRORS');
        l_Error_Message := SQLERRM;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_Error_Message);
 END LaunchProcess;

PROCEDURE ProcessRetry(ERRBUF OUT NOCOPY 	VARCHAR2,
		   ERRRET OUT NOCOPY 	VARCHAR2,
		   p_api_version_number in number,
 		   p_init_msg_list  IN   VARCHAR2 ,
	    	   p_commit	    IN   VARCHAR2 ,
  		p_workflowProcess in varchar2 ,
 		p_Item_Type	 in varchar2
			 	) IS

l_api_version_number number:=1.0;
l_api_name	varchar2(30):='ProcessRetry';
l_errbuf		varchar2(500);
l_errret		varchar2(100);
l_Error_Message           VARCHAR2(2000);
l_call_status             BOOLEAN;
BEGIN
-- Standard Start of API savepoint
SAVEPOINT		ProcessRetry_PUB;
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
			     p_api_version_number,
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
   commit;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO LaunchProcess_PUB;
        FND_MESSAGE.SET_NAME('IEM','IEM_RETRYPROCESS_EXEC_ERROR');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_Error_Message);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO LaunchProcess_PUB;
        FND_MESSAGE.SET_NAME('IEM','IEM_RETRYPROCESS_UNXPTD_ERR');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_Error_Message);
   WHEN OTHERS THEN
	ROLLBACK TO LaunchProcess_PUB;
        FND_MESSAGE.SET_NAME('IEM','IEM_RETRYPROCESS_OTHER_ERR');
        l_Error_Message := SQLERRM;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_Error_Message);

END ProcessRetry;
PROCEDURE StopProcessing(ERRBUF OUT NOCOPY		VARCHAR2,
				   ERRRET OUT NOCOPY		VARCHAR2,
					p_api_version_number    IN   NUMBER,
 		    		 p_init_msg_list  IN   VARCHAR2 ,
		       	 p_commit	    IN   VARCHAR2
				 ) IS
		l_api_name        		VARCHAR2(255):='StopProcessing';
		l_api_version_number 	NUMBER:=1.0;
  		l_msg_count number;
 		l_call_status             BOOLEAN;
  		l_return_status varchar2(10);
		l_Error_Message           VARCHAR2(2000);
		l_msg_data varchar2(240);
BEGIN
-- Standard Start of API savepoint
SAVEPOINT		StopWorkflow_PUB;
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				     p_api_version_number,
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
-- Initialize API return status to SUCCESS
   UPDATE IEM_COMP_RT_STATS
   set VALUE='F'
   WHERE TYPE='MAILPROC' and PARAM='RUNTIME STATUS';
   COMMIT;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO Stopworkflow_PUB;
        FND_MESSAGE.SET_NAME('IEM','IEM_STOPWORKFLOW_EXEC_ERROR');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_Error_Message);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO Stopworkflow_PUB;
        FND_MESSAGE.SET_NAME('IEM','IEM_STOPWORKFLOW_UNXPTD_ERR');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_Error_Message);
   WHEN OTHERS THEN
	ROLLBACK TO Stopworkflow_PUB;
        FND_MESSAGE.SET_NAME('IEM','IEM_STOPWORKFLOW_OTHER_ERR');
        l_Error_Message := SQLERRM;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_Error_Message);

 END StopProcessing;

PROCEDURE PurgeWorkflow(ERRBUF OUT NOCOPY	varchar2,
			ERRRET OUT NOCOPY		varchar2,
			p_api_version_number    IN   NUMBER,
 		        p_init_msg_list  IN   VARCHAR2 ,
		         p_commit	    IN   VARCHAR2 ,
			 p_item_type	IN VARCHAR2:='IEM_MAIL',
			 p_end_date   IN varchar2
			 ) IS
		l_api_name       		VARCHAR2(255):='PurgeWorkflow';
		l_api_version_number 	NUMBER:=1.0;
  		l_msg_count number;
 		l_call_status             BOOLEAN;
  		l_return_status varchar2(10);
  		l_error_message varchar2(200);
 		l_msg_data varchar2(1000);
		l_date	date;
		CURSOR wf_err_data_csr is
		SELECT  item_key
 		from wf_item_activity_statuses
 		where item_type=p_item_type
		and activity_status = 'ERROR'
		and begin_date<=to_date(p_end_date,'yyyy/mm/dd hh24:mi:ss');
BEGIN
-- Standard Start of API savepoint
SAVEPOINT		PurgeWorkflow_PUB;
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
						     p_api_version_number,
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
-- Initialize API return status to SUCCESS
	FOR wf_err_data_rec in wf_err_data_csr LOOP
	BEGIN
	wf_engine.abortprocess(p_item_type,wf_err_data_rec.item_key);
	EXCEPTION WHEN OTHERS THEN
		NULL;
	END;
	END LOOP;
	l_date:=to_date(p_end_Date,'yyyy/mm/dd hh24:mi:ss');
	wf_purge.total(p_item_type,null,l_Date);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO Purgeworkflow_PUB;
        FND_MESSAGE.SET_NAME('IEM','IEM_PURGEWORKFLOW_EXEC_ERROR');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_Error_Message);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO Purgeworkflow_PUB;
        FND_MESSAGE.SET_NAME('IEM','IEM_PURGEWORKFLOW_UNXPTD_ERR');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_Error_Message);
   WHEN OTHERS THEN
	ROLLBACK TO Purgeworkflow_PUB;
        FND_MESSAGE.SET_NAME('IEM','IEM_PURGEWORKFLOW_OTHER_ERR');
        l_Error_Message := SQLERRM;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_Error_Message);
END PurgeWorkflow;

END IEM_MDTSTARTPROCESS_PUB ;

/
