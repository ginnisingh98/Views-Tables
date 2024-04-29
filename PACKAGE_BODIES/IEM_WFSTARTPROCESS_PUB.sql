--------------------------------------------------------
--  DDL for Package Body IEM_WFSTARTPROCESS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_WFSTARTPROCESS_PUB" as
/* $Header: iempwfsb.pls 120.2 2005/12/29 15:57:46 rtripath ship $*/

G_PKG_NAME CONSTANT varchar2(30) :='IEM_WFSTARTPROCESS_PUB ';
G_RETRY_FOLDER		varchar2(50):='/Retry';
G_ADMIN_FOLDER		varchar2(50):='/Admin';
G_DEFAULT_FOLDER	varchar2(50):='/Inbox';
G_IM_LINK			varchar2(90);

PROCEDURE CallWorkflow(p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
  				p_workflowProcess in varchar2 ,
 				p_Item_Type	 in varchar2 ,
				itemkey in number,
				p_itemuserkey in varchar2,
				p_queue_opt	in varchar2:='FOREVER',
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2
			 ) IS

		l_api_name        		VARCHAR2(255):='CallWorkflow';
		l_api_version_number 	NUMBER:=1.0;
		l_msg_id number;
  		l_msg_size number;
  		ll_msg_size varchar2(30);
  		l_sender_name varchar2(100);
  		l_user_name varchar2(100);
  		l_domain_name varchar2(100);
  		l_priority varchar2(128);
 		l_msg_status varchar2(30):='NULL';
 		l_key1 varchar2(50);
 		l_val1 varchar2(50);
 		l_process varchar2(50);
  		l_msg_count number;
  		l_email_account_id number;
  		l_return_status varchar2(6);
  		l_outval varchar2(200);
 		l_msg_data varchar2(1000);
		l_key		number;
		l_wf_excep	EXCEPTION;

BEGIN
-- Standard Start of API savepoint
SAVEPOINT		CallWorkflow_PUB;
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
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>      x_msg_count,
                 p_data  =>      x_msg_data
			);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO CallWorkFlow_PUB;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count =>      x_msg_count,
                 p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO CallWorkFlow_PUB;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count =>      x_msg_count,
                 p_data  =>      x_msg_data
			);
   WHEN l_wf_excep  THEN
	ROLLBACK TO CallWorkFlow_PUB;
   WHEN OTHERS THEN
	ROLLBACK TO CallWorkFlow_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);

 END CallWorkFlow;

PROCEDURE LaunchProcess(ERRBUF OUT NOCOPY VARCHAR2,
				    ERRRET    OUT NOCOPY VARCHAR2,
				p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	      p_commit	    IN   VARCHAR2 := FND_API.G_FALSE,
  				p_workflowProcess in varchar2 :=null,
 				p_Item_Type	 in varchar2 :=null,
				p_qopt	in varchar2:='FOREVER',
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
 		  	      p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	      p_commit	    IN   VARCHAR2 := FND_API.G_TRUE,
  				p_workflowProcess in varchar2 :=null,
 				p_Item_Type	 in varchar2 :=null
			 	) IS

BEGIN
		null;
END ProcessRetry;
PROCEDURE StopWorkflow(ERRBUF	 OUT NOCOPY	VARCHAR2,
				   ERRRET	 OUT NOCOPY	VARCHAR2,
				p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	      p_commit	    IN   VARCHAR2 := FND_API.G_TRUE
				 ) IS
		l_api_name        		VARCHAR2(255):='StopWorkflow';
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

 END StopWorkflow;
PROCEDURE PurgeWorkflow(ERRBUF	 OUT NOCOPY VARCHAR2,
					ERRRET OUT NOCOPY	VARCHAR2,
				p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	      p_commit	    IN   VARCHAR2 := FND_API.G_TRUE,
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
		CURSOR wf_err_data_csr is
		SELECT  item_key
 		from wf_item_activity_statuses
 		where item_type=p_item_type
		and activity_status = 'ERROR'
		and begin_date<=to_date(p_end_date,'YYYY/MM/DD HH24:MI:SS');
		l_date	date;
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
	l_date	:= to_date(p_end_Date,'YYYY/MM/DD HH24:MI:SS');
	wf_purge.total(p_item_type,null,l_date);
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

END IEM_WFSTARTPROCESS_PUB ;

/
