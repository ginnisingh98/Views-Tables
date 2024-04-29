--------------------------------------------------------
--  DDL for Package Body IEM_NEXT_GEN_PROCESS_EMAIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_NEXT_GEN_PROCESS_EMAIL_PVT" as
/* $Header: iemngcwb.pls 120.0 2005/06/02 13:49:35 appldev noship $*/

G_PKG_NAME CONSTANT 		varchar2(30) :='IEM_NEXT_GEN_PROCESS_EMAIL_PVT';
G_ADMIN_FOLDER CONSTANT		varchar2(50) :='/Admin';
G_DEFAULT_FOLDER CONSTANT	varchar2(50) :='/Inbox';
G_IM_LINK					varchar2(90);
STOP_ALL_WORKERS        		EXCEPTION;

PROCEDURE LaunchProcess(
		ERRBUF 			OUT NOCOPY VARCHAR2,
		ERRRET    		OUT NOCOPY VARCHAR2,
		p_api_version_number    IN  NUMBER,
		p_init_msg_list  	IN  VARCHAR2 ,
		p_commit	    	IN  VARCHAR2 ,
  	p_workflowProcess 	IN  VARCHAR2 ,
 		p_Item_Type	 	IN  VARCHAR2 ,
		p_qopt			IN  VARCHAR2:='NO_WAIT',
		p_counter		IN  NUMBER
		 ) IS

		l_api_name        	VARCHAR2(255):='LaunchProcess';
		l_api_version_number 	NUMBER:=1.0;
		Itemuserkey		varchar2(30) := 'iemmail_preproc';
		l_itemkey		varchar2(30);
  		l_msg_count 		number;
  		l_seq 			number;
		l_Error_Message         VARCHAR2(2000);
 		l_call_status           BOOLEAN;
  		l_return_status 	varchar2(6);
 		l_msg_data 		varchar2(1000);
		l_exit			varchar2(1):='T';
		l_status 		varchar2(1);
		l_counter		number:=1;
		l_errbuf		varchar2(100);
		l_errret		varchar2(10);
          	l_rphase      		varchar2(30);
          	l_rstatus     		varchar2(30);
          	l_dphase      		varchar2(30);
          	l_dstatus     		varchar2(30);
          	l_message     		varchar2(240);
          	l_request_id  		number;
          	l_counter2    		number:=0;
          	l_UProcess_ID 		number;
          	l_UTerminal   		varchar2(50);
          	l_UNode       		varchar2(50);
          	l_UName       		varchar2(50);
          	l_UProgram    		varchar2(50);
BEGIN
-- Standard Start of API savepoint
SAVEPOINT		LaunchProcess_PVT;
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
   SELECT VALUE into l_status from IEM_COMP_RT_STATS -- New Table
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
  delete from IEM_COMP_RT_STATS
  WHERE TYPE='MAILPROC' and PARAM='RUNTIME STATUS'
  and rownum<
  (select count(*) from IEM_COMP_RT_STATS
  WHERE TYPE='MAILPROC' and PARAM='RUNTIME STATUS');
  WHEN OTHERS  THEN
  NULL;
  END;
  IF l_status='F'
     THEN RAISE STOP_ALL_WORKERS;
  END IF;

	LOOP
		BEGIN
		 SELECT value into l_status from IEM_COMP_RT_STATS
		 WHERE type='MAILPROC' and param='RUNTIME STATUS';
		 EXIT when l_status='F';
		 EXCEPTION WHEN OTHERS THEN
		 EXIT;
		END;

		 IEM_EMAIL_PROC_PVT.PROC_EMAILS(ERRBUF=>l_errbuf, -- New procedure
		 				ERRRET=>l_errret,
		 				p_api_version_number=>1.0,
            p_init_msg_list=>p_init_msg_list, -- New parameter
		 				p_commit=>p_commit,
            p_count=>1); -- New parameter
		 COMMIT;
		 l_counter:=l_counter+1;
		 IF p_counter is not null and p_qopt='NO_WAIT' then
		     EXIT when l_counter>p_counter;
		 END IF;
	END LOOP;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO LaunchProcess_PVT;
        FND_MESSAGE.SET_NAME('IEM','IEM_LAUNCHPROCESS_EXEC_ERROR');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_Error_Message);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO LaunchProcess_PVT;
        FND_MESSAGE.SET_NAME('IEM','IEM_LAUNCHPROCESS_UNXPTD_ERR');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_Error_Message);

   WHEN STOP_ALL_WORKERS THEN
        -- Get a current IEM Concurrent worker id.
        l_call_status :=FND_CONCURRENT.GET_REQUEST_STATUS(l_request_id, 'IEM', 'IEMNGNWW', l_rphase,l_rstatus,l_dphase,l_dstatus,l_message);
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
                  l_call_status :=FND_CONCURRENT.GET_REQUEST_STATUS(l_request_id, 'IEM', 'IEMNGNWW', l_rphase,l_rstatus,l_dphase,l_dstatus,l_message);
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
	ROLLBACK TO LaunchProcess_PVT;
        FND_MESSAGE.SET_NAME('IEM','IEM_LAUNCHPROCESS_OTHER_ERRORS');
        l_Error_Message := SQLERRM;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_Error_Message);
 END LaunchProcess;

PROCEDURE StopProcessing(ERRBUF OUT NOCOPY	VARCHAR2,
			 ERRRET OUT NOCOPY	VARCHAR2,
		 	 p_api_version_number   IN  NUMBER,
 		    	 p_init_msg_list  	IN  VARCHAR2 ,
		       	 p_commit	    	IN  VARCHAR2
				 ) IS
			l_api_name        	VARCHAR2(255):='StopProcessing';
			l_api_version_number 	NUMBER:=1.0;
  			l_msg_count 		number;
 			l_call_status           BOOLEAN;
  			l_return_status 	varchar2(10);
			l_Error_Message         VARCHAR2(2000);
			l_msg_data 		varchar2(240);
BEGIN
-- Standard Start of API savepoint
SAVEPOINT		StopWorkflow_PVT;
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
	ROLLBACK TO Stopworkflow_PVT;
        FND_MESSAGE.SET_NAME('IEM','IEM_STOPWORKFLOW_EXEC_ERROR');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_Error_Message);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO Stopworkflow_PVT;
        FND_MESSAGE.SET_NAME('IEM','IEM_STOPWORKFLOW_UNXPTD_ERR');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_Error_Message);

   WHEN OTHERS THEN
	ROLLBACK TO Stopworkflow_PVT;
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
			p_end_date   IN DATE:=sysdate-3
			 ) IS
			l_api_name       		VARCHAR2(255):='PurgeWorkflow';
			l_api_version_number 	NUMBER:=1.0;
  			l_msg_count number;
 			l_call_status             BOOLEAN;
  			l_return_status varchar2(10);
  			l_error_message varchar2(200);
 			l_msg_data varchar2(1000);
			CURSOR wf_err_data_csr is
			SELECT  item_key
 			from wf_item_activity_statuses
 			where item_type=p_item_type
			and activity_status = 'ERROR'
			and begin_date<=p_end_date;
BEGIN
-- Standard Start of API savepoint
SAVEPOINT		PurgeWorkflow_PVT;
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
	wf_purge.total(p_item_type,null,p_end_date);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO Purgeworkflow_PVT;
        FND_MESSAGE.SET_NAME('IEM','IEM_PURGEWORKFLOW_EXEC_ERROR');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_Error_Message);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO Purgeworkflow_PVT;
        FND_MESSAGE.SET_NAME('IEM','IEM_PURGEWORKFLOW_UNXPTD_ERR');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_Error_Message);
   WHEN OTHERS THEN
	ROLLBACK TO Purgeworkflow_PVT;
        FND_MESSAGE.SET_NAME('IEM','IEM_PURGEWORKFLOW_OTHER_ERR');
        l_Error_Message := SQLERRM;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_Error_Message);
END PurgeWorkflow;

END IEM_NEXT_GEN_PROCESS_EMAIL_PVT;

/
