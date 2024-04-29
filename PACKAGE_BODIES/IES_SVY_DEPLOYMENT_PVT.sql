--------------------------------------------------------
--  DDL for Package Body IES_SVY_DEPLOYMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IES_SVY_DEPLOYMENT_PVT" AS
/* $Header: iesdpypb.pls 120.1 2005/06/16 11:15:25 appldev  $ */
/*==========================================================================+
 | PROCEDURES.                                                              |
 | Submit_Deployment.                                              |
 +==========================================================================*/


  --global package variables.
  g_sqlerrm varchar2(500);
  g_sqlcode varchar2(500);

  G_PKG_NAME      CONSTANT VARCHAR2(30):='IES_SVY_DEPLOYMENT_PVT';
  G_FILE_NAME     CONSTANT VARCHAR2(12):='iesdpypb.pls';


----------------------------------------------------------------------------------------------------------
-- Procedure
--   Submit_Deployment

-- PURPOSE
--   Submit Deployment to Fulfillemnt through Concurrent Manager at the specified_time.
--
-- PARAMETERS
--  		deployment_id - survey deployment
--		list_entry_id - list entry identifier
--		template_id - fulfillment template identifier
-- NOTES
-- created rrsundar 05/03/2000
-- Modified vacharya 03/19/01 Need to provide value of p_commit as FND_API.G_TRUE when you call Submit_Deployment
--                            the file has been modified to allow for PL/SQL Commits if certain conditions are met
---------------------------------------------------------------------------------------------------------
Procedure  Submit_Deployment
(
                             p_api_version              IN  NUMBER                                      ,
                             p_init_msg_list            IN  VARCHAR2    := FND_API.G_FALSE              ,
                             p_commit                   IN  VARCHAR2    := FND_API.G_FALSE              ,
                             p_validation_level         IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL   ,
                             x_return_status            OUT NOCOPY /* file.sql.39 change */ VARCHAR2                                    ,
                             x_msg_count                OUT NOCOPY /* file.sql.39 change */ NUMBER                                      ,
                             x_msg_data                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2                                    ,
                             x_message                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2                                    ,
                             p_user_id  	        IN NUMBER                                       ,
                             p_resp_id                  IN NUMBER                                       ,
                             p_deployment_id            IN NUMBER       := NULL                         ,
                             p_list_entry_id            IN NUMBER       := NULL                         ,
			     p_template_id              IN NUMBER       := NULL                         ,
			     p_start_time               IN DATE         := NULL                         ,
                             p_reminder_type            IN VARCHAR2     := NULL
) IS

  --PRAGMA AUTONOMOUS_TRANSACTION;

  l_return_number           NUMBER              := NULL ;
  l_api_version		    NUMBER              := 1.0  ;
  l_return_status           VARCHAR2(1000)              ;
  l_msg_count               NUMBER                      ;
  l_msg_data                VARCHAR2(1000)              ;
  l_Error_Msg         	    VARCHAR2(2000) 		;
  l_ret_code                NUMBER              := NULL ;
  l_err_buf                 VARCHAR2(80)        := NULL ;
  l_reminder_type           VARCHAR2(10)        :=NULL  ;
  l_reminder_flag           BOOLEAN             := FALSE;
  l_no_of_reminder          NUMBER                      ;
  l_reminder_interval       NUMBER                      ;
  l_survey_reminder_id      NUMBER                      ;
  l_current_date            DATE                        ;
  l_deploy_date             DATE                        ;
  l_response_end_date       DATE                        ;
  l_reminder_hst_id         NUMBER              := NULL ;
  l_reminder_template_id    NUMBER                      ;
  l_api_name                VARCHAR2(30)        :=  'Submit_Deployment';
  l_schedule_id             NUMBER                      ;

CURSOR reminder_cur IS
	SELECT NVL(SVR.NO_OF_REMINDERS,0) no_of_reminders
		,NVL(SVR.REMINDER_INTERVAL,0) reminder_interval
		,SVR.SURVEY_REMINDER_ID survey_reminder_id
		,SDP.RESPONSE_END_DATE response_end_date
		,SDP.REMINDER_TEMPLATE_ID reminder_template_id
	FROM  IES_SVY_REMINDERS_V  SVR
		,IES_SVY_DEPLYMENTS_V SDP
	WHERE  SDP.SURVEY_DEPLOYMENT_ID = SVR.SURVEY_DEPLOYMENT_ID
	AND    SDP.SURVEY_DEPLOYMENT_ID = p_deployment_id;

BEGIN


	-- Check API Compatability

	IF NOT FND_API.Compatible_API_Call (
    		  l_api_version,
    		  p_api_version,
    		  l_api_name,
    		  G_PKG_NAME)
	THEN
    		  RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Create a Savepoint for Rollback

	SAVEPOINT Submit_Deployment;


	-- Create Initial Summary records for deployment

	IES_SVY_CREATE_INIT_RECORDS.CREATE_INITIAL_RECORDS(
		p_deployment_id => p_deployment_id);


	-- Populate Survey List Entries table

	Populate_Survey_List_Entries
				(p_api_version => 1.0,
				p_init_msg_list => FND_API.G_TRUE,
				p_commit => FND_API.G_FALSE,
				p_validation_level => FND_API.G_VALID_LEVEL_FULL,
				x_return_status => l_return_status,
				x_msg_count => l_msg_count,
				x_msg_data => l_msg_data,
				x_message => l_Error_Msg,
				p_survey_deployment_id => p_deployment_id);

	IF (l_return_status <> 'S') THEN
		ROLLBACK TO Submit_Deployment;
		x_return_status := l_return_status;
		x_msg_data := l_msg_data;
		x_msg_count := l_msg_count;
		x_message := l_Error_Msg;
		return;
	END IF;

 	--Initialize message list if p_init_msg_list is TRUE.
	IF FND_API.To_Boolean (p_init_msg_list) THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- Initialize API return status to success

	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_message := NULL;
	x_msg_count := 0;
	x_msg_data := NULL;

	-- Check if Submit Deployment has been called for individual reminders

	IF ((p_list_entry_id is not NULL) AND ( p_deployment_id is not NULL)) THEN
		FM_Single_Request(
				l_api_version ,
				FND_API.G_FALSE,
				FND_API.G_FALSE,
				FND_API.G_VALID_LEVEL_FULL,
				x_return_status,
				x_msg_count,
				x_msg_data,
				x_message,
				p_list_entry_id,
				p_template_id,
				p_deployment_id,
				p_user_id);
     -- If is not a single reminder but a "Deploy" request
	ELSIF (( p_deployment_id is not NULL)AND (p_list_entry_id is NULL)) THEN
   		l_schedule_id :=  FND_REQUEST.SUBMIT_REQUEST(
			application => 'IES',
			program     => 'SUBMIT_GROUP_REQUEST',
			start_time  => to_char(p_start_time,'DD-MON-YYYY HH24:MI'),
			argument1   => p_api_version,
			argument2   => p_init_msg_list,
			argument3   => p_commit,
			argument4   => p_validation_level,
			argument5   => p_deployment_id,
			argument6   => p_template_id,
			argument7   => p_reminder_type,
			argument8   => p_user_id,
			argument9   => l_reminder_hst_id);
		IF (l_schedule_id = 0) THEN
			Update_Dep_Status(p_dep_id => p_deployment_id,
					   p_status => 'ERROR',
					   p_reminder_type => p_reminder_type,
					   p_update_flag   => 'Y');
		ELSE
			Update_Dep_Status(p_dep_id => p_deployment_id,
					   p_status => 'PENDING',
					   p_reminder_type => p_reminder_type,
					   p_update_flag => 'Y');
			UPDATE ies_svy_deplyments_all
			SET concurrent_req_id = l_schedule_id
			WHERE survey_deployment_id =  p_deployment_id;
		END IF;


		-- Check if reminder needs to be set. Find out the dates on which reminder needs to be send and call
		-- FND_REQUEST.SUBMIT_REQUEST for each request

		SELECT response_end_date
		INTO l_response_end_date
		FROM ies_svy_deplyments_v
		WHERE survey_deployment_id = p_deployment_id;

		l_reminder_type := 'REMINDER';
		l_reminder_flag := FALSE;

		FOR reminder_rec in reminder_cur
		LOOP
			l_reminder_flag := TRUE;
			l_deploy_date := p_start_time;
			l_survey_reminder_id := reminder_rec.survey_reminder_id;
			l_reminder_template_id := reminder_rec.reminder_template_id;
			FOR loop_index IN 1 .. reminder_rec.no_of_reminders
			LOOP
				l_deploy_date := l_deploy_date + reminder_rec.reminder_interval;
				SELECT IES_SVY_REMINDER_HST_S.nextval INTO l_reminder_hst_id FROM DUAL;
				IF(l_deploy_date <= l_response_end_date) THEN
					INSERT INTO ies_svy_reminder_hst_v
							(survey_reminder_hst_id
							,object_version_number
							,created_by
							,creation_date
							,last_updated_by
							,last_update_date
							,last_update_login
							,survey_reminder_id
							,reminder_date)
					VALUES
							(l_reminder_hst_id
							,1
							,p_user_id
							,sysdate
							,p_user_id
							,sysdate
							,p_user_id
							,l_survey_reminder_id
							,sysdate
							);
					l_schedule_id := 0;
					l_schedule_id :=  FND_REQUEST.SUBMIT_REQUEST(
								application => 'IES',
								program     => 'SUBMIT_GROUP_REQUEST',
								start_time  => to_char(l_deploy_date,'DD-MON-YYYY HH24:MI'),
								argument1   => p_api_version,
								argument2   => p_init_msg_list,
								argument3   => p_commit,
								argument4   => p_validation_level,
								argument5   => p_deployment_id,
								argument6   => l_reminder_template_id,
								argument7   => l_reminder_type,
								argument8   => p_user_id,
								argument9   => l_reminder_hst_id);
					IF (l_schedule_id = 0) THEN
						RAISE FND_API.G_EXC_ERROR;
					ELSE
						UPDATE ies_svy_reminder_hst_v
						SET CONCURRENT_REQ_ID = l_schedule_id
						WHERE SURVEY_REMINDER_HST_ID = l_reminder_hst_id;
					END IF;
				END IF;
			END LOOP;
		END LOOP;
	END IF;

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO Submit_Deployment;
		  x_return_status := FND_API.G_RET_STS_ERROR;
            x_message := SQLERRM;
            FND_MSG_PUB.Count_And_Get
			( p_count         => x_msg_count,
			 p_data               => x_msg_data
		   );
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           ROLLBACK TO Submit_Deployment;
		    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              x_message := SQLERRM;
            FND_MSG_PUB.Count_And_Get
    	 	  (  	p_count         	=>      x_msg_count     	,
        	  		p_data          	=>      x_msg_data
     	    );
     WHEN OTHERS THEN
          rollback to Submit_Deployment;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          x_message := SQLERRM;
          FND_MSG_PUB.Count_And_Get
    	     (p_count         	=>      x_msg_count     	,
          p_data          	=>      x_msg_data
    		);
End Submit_Deployment;

----------------------------------------------------------------------------------------------------------
-- Procedure
--   FM_Single_Request
-- PURPOSE  Wrapper API to select the appropriate template details and submit a request to the
--          fulfillment engine.
--
--
-- PARAMETERS
-- NOTES
-- created kpandey 05/02/2000
---------------------------------------------------------------------------------------------------------
PROCEDURE FM_Single_Request(
    p_api_version         	 IN  NUMBER                                    ,
    p_init_msg_list       	 IN  VARCHAR2    := FND_API.G_FALSE              ,
    p_commit              	 IN  VARCHAR2    := FND_API.G_FALSE              ,
    p_validation_level  	 IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL   ,
    x_return_status       	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2                                    ,
    x_msg_count           	 OUT NOCOPY /* file.sql.39 change */ NUMBER                                      ,
    x_msg_data            	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2                                    ,
    x_message                OUT NOCOPY /* file.sql.39 change */ VARCHAR2                                    ,
    p_list_entry_id          IN  NUMBER                                      ,
    p_template_id            IN  NUMBER                                      ,
    p_deployment_id          IN  NUMBER                                      ,
    p_user_id                IN  NUMBER
)

IS
l_api_version				   NUMBER          := 1.0;
l_api_name            CONSTANT VARCHAR2(30)    := 'FM_Request_From_Survey';
l_commit	      VARCHAR2(5)     := FND_API.G_FALSE;
l_full_name           CONSTANT VARCHAR2(60)    := G_PKG_NAME ||'.'|| l_api_name;
l_Error_Msg          VARCHAR2(2000) ;
l_content_id		VARCHAR2(30);
l_media_type		VARCHAR2(30);
l_request_type		VARCHAR2(20);
l_user_note		VARCHAR2(1000);
l_document_type		VARCHAR2(150);
l_template_id 		NUMBER;
l_party_id		NUMBER;
l_user_id		NUMBER;
l_server_id		NUMBER;
l_request_id		NUMBER;
l_subject		VARCHAR2(100);
l_bind_var 		JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
l_bind_var_type 	JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
l_bind_val 		JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;

--
l_msg_count 		NUMBER;
l_msg_data 	        VARCHAR2(1000);
l_return_status         VARCHAR2(1000);
l_content_xml1          VARCHAR2(1000);
l_content_xml VARCHAR2(10000);
l_content_nm	VARCHAR2(100);
l_email		VARCHAR2(100);
l_printer	VARCHAR2(100);
l_file_path	VARCHAR2(100);
l_fax		VARCHAR2(100);

l_content_no                   NUMBER;
l_content_type                 NUMBER;
l_content_type_text            VARCHAR2(30);
v_count                        NUMBER;
l_survey_list_entry_id         NUMBER;

CURSOR CCONTENT IS
SELECT  CONTENT_NUMBER, CONTENT_TYPE_ID
FROM JTF_FM_TEMPLATE_CONTENTS, JTF_FM_AMV_ITEMS_VL
WHERE JTF_FM_TEMPLATE_CONTENTS.TEMPLATE_ID = p_template_id
AND JTF_FM_TEMPLATE_CONTENTS.CONTENT_NUMBER = JTF_FM_AMV_ITEMS_VL.ITEM_ID
AND JTF_FM_TEMPLATE_CONTENTS.F_DELETEDFLAG IS NULL;

CURSOR CEMAILADD IS
  SELECT EMAIL_ADDRESS
  FROM AMS_LIST_ENTRIES
  WHERE LIST_ENTRY_ID = p_list_entry_id;

CURSOR CEMAILSUBJECTHEADING IS
   SELECT EMAIL_SUBJECT_HEADING
   FROM IES_SVY_DEPLYMENTS_ALL
    WHERE SURVEY_DEPLOYMENT_ID = p_deployment_id;

BEGIN
	SAVEPOINT  FM_Request_From_Survey;

	-- Check API Compatibility

	IF NOT FND_API.Compatible_API_Call (
		l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME) THEN
		x_message := 'API not compatible';
		RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Initialize message list if p_init_msg_list is TRUE.
	IF FND_API.To_Boolean (p_init_msg_list) THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- Debug Message
	IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
		FND_MESSAGE.Set_Name('JTF','JTF_FM_API_DEBUG_MESSAGE');
		FND_MESSAGE.Set_Token('ARG1',l_full_name||': Start');
		FND_MSG_PUB.Add;
	END IF;

	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;


	OPEN CEMAILADD;
	FETCH CEMAILADD into l_email;
	IF (CEMAILADD%NOTFOUND) THEN
		CLOSE CEMAILADD;
		l_Error_Msg := 'No e-mail address for this p_list_entry_id';
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
			FND_MESSAGE.set_name('IES', 'IES_SVY_API_MISSING_EMAIL_ID');
			FND_MSG_PUB.Add;
		END IF;
		x_message := l_Error_Msg;
		RAISE  FND_API.G_EXC_ERROR;
	END IF;
	CLOSE CEMAILADD;


	OPEN CEMAILSUBJECTHEADING;
	FETCH CEMAILSUBJECTHEADING into l_subject;
	IF (CEMAILSUBJECTHEADING%NOTFOUND) THEN
		CLOSE CEMAILSUBJECTHEADING;
		l_Error_Msg := 'No e-mail subject heading for this p_deployment_id';
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
			FND_MESSAGE.set_name('IES', 'IES_SVY_API_MISSING_EMAIL_ID');
			FND_MSG_PUB.Add;
		END IF;
        	x_message := l_Error_Msg;
        	RAISE  FND_API.G_EXC_ERROR;
    	END IF;
    	CLOSE CEMAILSUBJECTHEADING;


	l_bind_var(1) := 'party_id';
	l_bind_val(1) := p_list_entry_id;
	l_bind_var_type(1) := 'NUMBER';

	l_bind_var(2) := 'deployment_id';
	l_bind_val(2) := p_deployment_id;
	l_bind_var_type(2) := 'NUMBER';

-- Start the fulfillment request. The output request_id must be passed
-- to all subsequent calls made for this request.

	JTF_FM_REQUEST_GRP.Start_Request
	(
		p_api_version => l_api_version,
		x_return_status => l_return_status,
		x_msg_count => l_msg_count,
		x_msg_data => l_msg_data,
		x_request_id => l_request_id
	);

	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;


	-- Check if a template has contents (MD or collateral)
	-- if it does then for each one, loop to genereate the content id, content_type_id type 20 is "QUERY"
	-- and  10 is Collateral. Get content for each, conactenate and submit.

	v_count :=0;
	OPEN CCONTENT;
	LOOP
		FETCH CCONTENT into l_content_no, l_content_type;

		EXIT WHEN CCONTENT%NOTFOUND OR  CCONTENT%ROWCOUNT >2;
		v_count := v_count + 1;

		IF (l_content_type = 10) THEN
			l_content_type_text := 'COLLATERAL';
         	ELSIF  (l_content_type = 20) THEN
          	l_content_type_text := 'QUERY';
         	END IF;

		l_content_id := l_content_no;
		l_media_type := 'EMAIL';
		l_request_type := l_content_type_text;
		l_user_note := ' ';


		-- This call gets the XML string for the content(Master Document) with
		-- the parameters as defined above
		JTF_FM_REQUEST_GRP.Get_Content_XML
		(
			p_api_version => l_api_version,
			x_return_status => l_return_status,
			x_msg_count => l_msg_count,
			x_msg_data => l_msg_data,
			p_content_id => l_content_id,
			p_content_nm => l_content_nm,
			p_document_type => l_document_type,
			p_media_type	=> l_media_type,
			p_printer => l_printer,
			p_email => l_email,
			p_file_path => l_file_path,
			p_fax => l_fax,
			p_user_note => l_user_note,
			p_content_type => l_request_type,
			p_bind_var => l_bind_var,
			p_bind_val => l_bind_val,
			p_bind_var_type => l_bind_var_type,
			p_request_id => l_request_id,
			x_content_xml => l_content_xml1);

		IF l_return_status = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
		ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

	    --  The output XML string is stored in a local variable
                l_content_xml := l_content_xml || l_content_xml1;


	END LOOP;

	IF(CCONTENT%NOTFOUND) AND ( v_count = 0)THEN
		l_Error_Msg := 'Could not find content no in JTF_FM_TEMPLATE_CONTENTS';
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
			FND_MESSAGE.set_name('JTF', 'IES_SVY_API_CONTENT_NOT_FOUND');
			FND_MESSAGE.Set_Token('ARG1', to_char(l_content_no));
			FND_MSG_PUB.Add;
		END IF;
		x_message := l_Error_Msg;
		RAISE  FND_API.G_EXC_ERROR;
	END IF;

	CLOSE CCONTENT;


	-- Initialize Parameters for submitting the fulfillment request

	l_user_id := p_user_id;
	-- Submit the fulfillment request
	JTF_FM_REQUEST_GRP.Submit_Request
		(p_api_version => l_api_version,
		p_commit => l_commit,
		x_return_status => l_return_status,
		x_msg_count => l_msg_count,
		x_msg_data => l_msg_data,
		p_subject => l_subject,
		p_party_id => l_party_id,
		p_user_id => l_user_id,
		p_server_id	=> l_server_id,
		p_queue_response => FND_API.G_TRUE,
		p_content_xml => l_content_xml,
		p_request_id => l_request_id
	);

	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;


   	FND_MESSAGE.Set_Name('IES','IES_SVY_SUCCESS_REMINDER');
	x_message := FND_MESSAGE.Get();
	x_message := x_message || TO_CHAR(l_request_id);


	--get the survey_list_entry_id to be inserted into ies_svy_entrs_remind_hst

	SELECT survey_list_entry_id
	INTO l_survey_list_entry_id
	FROM ies_svy_list_entries
	WHERE list_entry_id = p_list_entry_id
	AND survey_deployment_id = p_deployment_id;


	INSERT into ies_svy_entrs_remind_hst
		(entry_reminder_hst_id
		,object_version_number
		,created_by
		,creation_date
		,last_updated_by
		,last_update_date
		,last_update_login
		,survey_list_entry_id
		,reminder_date
		,concurrent_req_id
		,fulfillment_req_id)
	VALUES
		(ies_svy_entrs_remind_hst_s.nextval
		,1
		,l_user_id
		,sysdate
		,l_user_id
		,sysdate
		,l_user_id
		,l_survey_list_entry_id
		,sysdate
		,null
		,l_request_id);

     x_message := x_message || ' ,Entry inserted in ies_svy_entrs_remind_hst';
EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO FM_Request_From_Survey;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		x_message := x_message || ' ' ||SQLERRM;
		-- write the error msg to log, if conc request is executing this code then
		-- the log is viewable in concurrent manger log for that specific request
            	if(l_msg_count is not null) then
                	for l_index IN 1..l_msg_count loop
				l_msg_data :=FND_MSG_PUB.Get(
                         	p_msg_index => l_index,
                         	p_encoded => FND_API.G_FALSE);
                    		x_msg_data :=  l_msg_data;
			end loop;
		end if;
		JTF_FM_REQUEST_GRP.Cancel_Request
		(p_api_version => l_api_version,
                 p_commit => l_commit,
                 p_init_msg_list => FND_API.G_FALSE,
                 x_return_status => l_return_status,
                 x_msg_count => l_msg_count,
                 x_msg_data => l_msg_data,
                 p_request_id => l_request_id);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO FM_Request_From_Survey;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		x_message := x_message || ' ' || SQLERRM;
		-- write the error msg to log, if conc request is executing this code then
		-- the log is viewable in concurrent manger log for that specific request
		if(l_msg_count is not null) then
			for l_index IN 1..l_msg_count loop
				l_msg_data :=FND_MSG_PUB.Get(
				p_msg_index => l_index,
				p_encoded => FND_API.G_FALSE);
				x_msg_data :=  l_msg_data;
			end loop;
		end if;

		JTF_FM_REQUEST_GRP.Cancel_Request
			(p_api_version => l_api_version,
			 p_commit => l_commit,
			 p_init_msg_list => FND_API.G_FALSE,
			 x_return_status => l_return_status,
			 x_msg_count => l_msg_count,
			 x_msg_data => l_msg_data,
			 p_request_id => l_request_id);
	WHEN OTHERS THEN
		-- rollback all the database actions
		ROLLBACK to FM_Request_From_Survey;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		x_message := x_message || ' ' || SQLERRM;
		-- write the error msg to log, if conc request is executing this code then
		-- the log is viewable in concurrent manger log for that specific request
		if(l_msg_count is not null) then
			for l_index IN 1..l_msg_count loop
				l_msg_data :=FND_MSG_PUB.Get(
					p_msg_index => l_index,
					p_encoded => FND_API.G_FALSE);
				x_msg_data :=  l_msg_data;
			end loop;
		end if;
		-- cancel the request just sent
		JTF_FM_REQUEST_GRP.Cancel_Request
			(p_api_version => l_api_version,
			p_commit => l_commit,
			p_init_msg_list => FND_API.G_FALSE,
			x_return_status => l_return_status,
			x_msg_count => l_msg_count,
			x_msg_data => l_msg_data,
			p_request_id => l_request_id);

END FM_Single_Request;

----------------------------------------------------------------------------------------------------------
-- Procedure
--   FM_Group_Request
-- PURPOSE  Wrapper API to select the appropriate template details and submit a
--    group (mass e-mail invitation) request to fulfillment engine
--
--
-- PARAMETERS
-- NOTES
-- created kpandey 05/07/2000
---------------------------------------------------------------------------------------------------------
PROCEDURE FM_Group_Request(
	 errbuf 			    OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	 retcode			 OUT NOCOPY /* file.sql.39 change */ NUMBER,
     p_api_version         	IN  NUMBER,
     p_init_msg_list       	IN  VARCHAR2    := FND_API.G_FALSE,
     p_commit              	IN  VARCHAR2    := FND_API.G_FALSE,
     p_validation_level  	IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL,
     p_deployment_id        IN  NUMBER,
     p_template_id          IN  NUMBER,
     p_reminder_type        IN  VARCHAR2,
	 p_user_id              IN  NUMBER,
     p_reminder_hst_id      IN  NUMBER
  -- no other out params are allowed here since its called from concurrent manager
  --   x_return_status        OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  --  x_msg_count            OUT NOCOPY /* file.sql.39 change */ NUMBER,
  --  x_msg_data             OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  --  x_message              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
     )

IS
x_return_status             varchar2(100);
x_msg_count           	NUMBER :=0;
x_msg_data            	VARCHAR2(1000) := '';
x_message              VARCHAR2(1000) := '';
l_api_version				   NUMBER := 1.0;
l_api_name            CONSTANT VARCHAR2(30) := 'FM_Request_From_Survey';
l_commit					   VARCHAR2(5) := FND_API.G_FALSE;
l_full_name           CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
l_Error_Msg         	VARCHAR2(2000);

l_content_id				   VARCHAR2(30);
l_media_type				   VARCHAR2(30);
l_request_type				   VARCHAR2(20);
l_user_note					   VARCHAR2(1000);
l_document_type				   VARCHAR2(150);
l_template_id 				   NUMBER;
l_party_id					   NUMBER;
l_user_id					   NUMBER;
l_server_id					   NUMBER;
l_request_id				   NUMBER;
l_subject					   VARCHAR2(100);
l_list_type					   VARCHAR2(100);
l_bind_var 					   JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE ;
l_bind_var_type 			   JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE ;
l_bind_val 					   JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE ;

--
l_msg_count 				   NUMBER;
l_msg_data 					   VARCHAR2(1000);
l_return_status 			   VARCHAR2(1000);
l_content_xml1 				   VARCHAR2(1000);
l_content_xml 				   VARCHAR2(10000);
l_content_nm				   VARCHAR2(100);

l_mass_party_id                JTF_FM_REQUEST_GRP.G_NUMBER_TBL_TYPE;
l_mass_survey_list_entry_id    JTF_FM_REQUEST_GRP.G_NUMBER_TBL_TYPE;
l_mass_email 			  	   JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
l_mass_printer  			   JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
l_mass_fax 			  	   	   JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
l_mass_path			  	   	   JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
l_mass_party_name			   JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
l_mass_bind_var		JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
l_mass_bind_var_type     JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
l_mass_bind_val     	JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;

l_content_no                   NUMBER;
l_content_type                 NUMBER;
l_content_type_text            VARCHAR2(30);
v_count                        NUMBER;
l_list_header_id               ies_svy_deplyments_all.list_header_id%type;
l_list_entry_id                ams_list_entries.list_entry_id%type;

l_anonymous_code               VARCHAR2(10) := 'NO';
l_max_responses_per_person     NUMBER;
l_no_of_responses_recd         NUMBER := 0;
l_survey_reminder_id           NUMBER := 0;
l_query_id				 NUMBER := 0;

CURSOR CCONTENT IS
SELECT  CONTENT_NUMBER, CONTENT_TYPE_ID
FROM JTF_FM_TEMPLATE_CONTENTS, JTF_FM_AMV_ITEMS_VL
WHERE JTF_FM_TEMPLATE_CONTENTS.TEMPLATE_ID = p_template_id
AND JTF_FM_TEMPLATE_CONTENTS.CONTENT_NUMBER = JTF_FM_AMV_ITEMS_VL.ITEM_ID
AND JTF_FM_TEMPLATE_CONTENTS.F_DELETEDFLAG IS NULL;

CURSOR CEMAILSUBJECTHEADING IS
   SELECT EMAIL_SUBJECT_HEADING
   FROM IES_SVY_DEPLYMENTS_ALL
    WHERE SURVEY_DEPLOYMENT_ID = p_deployment_id;


BEGIN
	SAVEPOINT  FM_Request_From_Survey;
	IF NOT FND_API.Compatible_API_Call (
		l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME)
		THEN
		RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Initialize message list if p_init_msg_list is TRUE.
	IF FND_API.To_Boolean (p_init_msg_list) THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- Debug Message
	IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
		FND_MESSAGE.Set_Name('JTF','JTF_FM_API_DEBUG_MESSAGE');
		FND_MESSAGE.Set_Token('ARG1',l_full_name||': Start');
		FND_MSG_PUB.Add;
	END IF;

	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	IF (p_deployment_id IS NULL) THEN
		l_Error_Msg := 'Must pass p_deployment_id parameter';
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
			FND_MESSAGE.set_name('IES', 'IES_SVY_API_MISSING_DEPLOYMENT_ID');
			FND_MSG_PUB.Add;
		END IF;
		x_message := l_Error_Msg;
		RAISE  FND_API.G_EXC_ERROR;
	END IF;

	IF (p_template_id IS NULL) THEN
		l_Error_Msg := 'Must pass p_template_id parameter';
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
			FND_MESSAGE.set_name('IES', 'IES_SVY_API_MISSING_TEMPLATE_ID');
			FND_MSG_PUB.Add;
		END IF;
		x_message := l_Error_Msg;
		RAISE  FND_API.G_EXC_ERROR;
	END IF;

	if (p_reminder_type = 'REMINDER') then
		SELECT REMINDER_EMAIL_SUBJECT
		INTO l_subject
		FROM ies_svy_reminders_v
		WHERE survey_deployment_id = p_deployment_id;
     else
		OPEN CEMAILSUBJECTHEADING;
		FETCH CEMAILSUBJECTHEADING into l_subject;
		IF (CEMAILSUBJECTHEADING%NOTFOUND) THEN
			CLOSE CEMAILSUBJECTHEADING;
			l_Error_Msg := 'No e-mail subject heading for this p_deployment_id';
			IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
				FND_MESSAGE.set_name('IES', 'IES_SVY_API_MISSING_EMAIL_ID');
				FND_MSG_PUB.Add;
			END IF;
			x_message := l_Error_Msg;
			RAISE  FND_API.G_EXC_ERROR;
		END IF;
		CLOSE CEMAILSUBJECTHEADING;
	end if;

	-- Start the fulfillment request. The output request_id must be passed
	-- to all subsequent calls made for this request.
	JTF_FM_REQUEST_GRP.Start_Request
	(
		p_api_version => l_api_version,
		x_return_status => l_return_status,
		x_msg_count => l_msg_count,
		x_msg_data => l_msg_data,
		x_request_id => l_request_id
	);

	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;


	--Check if a template has contents (MD or collateral)
	--if it does then for each one, loop to genereate the content id, content_type_id type 20 is "QUERY"
	--and  10 is Collateral. Get content for each, conactenate and submit.

	l_bind_var(1) := 'deployment_id';
    	l_bind_val(1) := p_deployment_id;
    	l_bind_var_type(1) := 'NUMBER';

	v_count :=0;
	OPEN CCONTENT;
	LOOP
		v_count := v_count + 1;
		FETCH CCONTENT into l_content_no, l_content_type;
		EXIT WHEN CCONTENT%NOTFOUND OR  CCONTENT%ROWCOUNT >2;
		v_count := v_count + 1;

		IF (l_content_type = 10) THEN
			l_content_type_text := 'COLLATERAL';
		ELSIF  (l_content_type = 20) THEN
			l_content_type_text := 'QUERY';
		END IF;

		l_content_id := l_content_no;
		l_media_type := 'EMAIL';
		l_request_type := l_content_type_text;
		l_user_note := ' ';

		-- This call gets the XML string for the content(Master Document) with
		-- the parameters as defined above
		JTF_FM_REQUEST_GRP.Get_Content_XML
		(
			p_api_version => l_api_version,
			x_return_status => l_return_status,
			x_msg_count => l_msg_count,
			x_msg_data => l_msg_data,
			p_content_id => l_content_id,
			p_content_nm => l_content_nm,
			p_document_type => l_document_type,
			p_media_type	=> l_media_type,
--			p_printer => l_printer,
--			p_email => l_email,
--			p_file_path => l_file_path,
--			p_fax => l_fax,
			p_user_note => l_user_note,
			p_content_type => l_request_type,
			p_bind_var => l_bind_var,
			p_bind_val => l_bind_val,
			p_bind_var_type => l_bind_var_type,
			p_request_id => l_request_id,
			x_content_xml => l_content_xml1);

		IF l_return_status = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
		ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

		-- The output XML string is stored in a local variable
		l_content_xml := l_content_xml || l_content_xml1;
     END LOOP;

     IF(CCONTENT%NOTFOUND) AND ( v_count = 0)THEN
            l_Error_Msg := 'Could not find content no in JTF_FM_TEMPLATE_CONTENTS';
		  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('JTF', 'IES_SVY_API_CONTENT_NOT_FOUND');
		     FND_MESSAGE.Set_Token('ARG1', to_char(l_content_no));
       	     FND_MSG_PUB.Add;
          END IF;
          x_message := 'Could not find content no in JTF_FM_TEMPLATE_CONTENTS';
	      RAISE  FND_API.G_EXC_ERROR;
     END IF;
     CLOSE CCONTENT;
/*
 	SELECT QUERY_ID
 	INTO l_query_id
 	FROM JTF_FM_QUERY
 	WHERE QUERY_NAME = 'SURVEY_LIST_QUERY';

    	l_mass_bind_var(1) := 'list_header_id';
    	l_mass_bind_val(1) := l_list_header_id;
     l_mass_bind_var_type(1) := 'NUMBER';
*/
	l_user_id := p_user_id;
	-- Submit the fulfillment request

	JTF_FM_REQUEST_GRP.Submit_Mass_Request
	   ( p_api_version =>l_api_version,
		p_init_msg_list=> FND_API.G_TRUE,
		p_commit       =>FND_API.G_FALSE,
		p_validation_level=>FND_API.G_VALID_LEVEL_FULL,
		x_return_status   =>l_return_status,
		x_msg_count       =>l_msg_count,
		x_msg_data        =>l_msg_data,
		p_template_id      =>l_template_id,
		p_subject          => l_subject,
		p_user_id          =>l_user_id,
		p_source_code_id    =>FND_API.G_MISS_NUM,
		p_source_code       => FND_API.G_MISS_CHAR,
		p_object_type        =>FND_API.G_MISS_CHAR,
		p_object_id          =>FND_API.G_MISS_NUM,
		p_order_id           =>FND_API.G_MISS_NUM,
		p_doc_id             => FND_API.G_MISS_NUM,
		p_doc_ref            => FND_API.G_MISS_CHAR,
		p_view_nm            =>FND_API.G_MISS_CHAR,
		p_server_id          =>FND_API.G_MISS_NUM,
		p_queue_response     =>FND_API.G_FALSE,
		p_extended_header    =>FND_API.G_MISS_CHAR,
		p_content_xml        =>l_content_xml,
		p_request_id         =>l_request_id,
		p_per_user_history   =>FND_API.G_TRUE,
            p_mass_query_id	   =>0,
            p_list_type          => 'NO_LIST_TYPE');


       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

      -- if p_reminder_type is null then its from the deploy button so update
      -- ies_svy_deplyments_all and populate the ies_svy_list_entries with the survey sent date else
	 -- a record should be inserted in ies_svy_reminder_hst

	IF(p_reminder_type is null) THEN
		-- Set Deployment Status to be Active
		Update_Dep_Status(p_dep_id => p_deployment_id,
					   p_status => 'ACTIVE',
					   p_reminder_type => p_reminder_type,
					   p_update_flag => 'Y');

		-- Set Survey Sent Date.
          UPDATE ies_svy_list_entries
		SET survey_sent_date = sysdate
          WHERE survey_deployment_id = p_deployment_id;

		-- Update FM Request ID
		UPDATE ies_svy_deplyments_v
		SET fulfillment_req_id = l_request_id
		WHERE survey_deployment_id = p_deployment_id;

     ELSIF(p_reminder_type = 'REMINDER') THEN
    	--else a record should be inserted in ies_svy_reminder_hst if its a reminder

         UPDATE ies_svy_reminder_hst_v
         SET fulfillment_req_id = l_request_id
         WHERE SURVEY_REMINDER_HST_ID = p_reminder_hst_id;

	END IF;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO FM_Request_From_Survey;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		fnd_file.put_line(fnd_file.log, x_message);
		x_message := x_message || ' ' ||SQLERRM;
		-- write the error msg to log, if conc request is executing this code then
		-- the log is viewable in concurrent manger log for that specific request
		if(l_msg_count is not null) then
			for l_index IN 1..l_msg_count loop
				l_msg_data :=FND_MSG_PUB.Get(
						p_msg_index => l_index,
						p_encoded => FND_API.G_FALSE);
				x_msg_data :=  l_msg_data;
				fnd_file.put_line(fnd_file.log, l_msg_data);
			end loop;
		end if;
		fnd_file.put_line(fnd_file.log, SQLERRM);
		FND_MSG_PUB.Count_And_Get
			(p_count         	=>      x_msg_count     	,
			p_data          	=>      x_msg_data
			);
		JTF_FM_REQUEST_GRP.Cancel_Request
				(p_api_version => l_api_version,
				p_commit => l_commit,
				p_init_msg_list => FND_API.G_FALSE,
				x_return_status => l_return_status,
				x_msg_count => l_msg_count,
				x_msg_data => l_msg_data,
				p_request_id => l_request_id);
		Update_Dep_Status(p_dep_id => p_deployment_id,
					   p_status => 'ERROR',
					   p_reminder_type => p_reminder_type,
					   p_update_flag => 'Y');
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO FM_Request_From_Survey;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		fnd_file.put_line(fnd_file.log, x_message);
		x_message := x_message || ' ' ||SQLERRM;
		-- write the error msg to log, if conc request is executing this code then
		-- the log is viewable in concurrent manger log for that specific request
		if(l_msg_count is not null) then
			for l_index IN 1..l_msg_count loop
				l_msg_data :=FND_MSG_PUB.Get(
							p_msg_index => l_index,
							p_encoded => FND_API.G_FALSE);
				x_msg_data := l_msg_data;
				fnd_file.put_line(fnd_file.log, l_msg_data);
			end loop;
		end if;
		fnd_file.put_line(fnd_file.log, SQLERRM);
		JTF_FM_REQUEST_GRP.Cancel_Request
			(p_api_version => l_api_version,
				p_commit => l_commit,
				p_init_msg_list => FND_API.G_FALSE,
				x_return_status => l_return_status,
				x_msg_count => l_msg_count,
				x_msg_data => l_msg_data,
				p_request_id => l_request_id);
		Update_Dep_Status(p_dep_id => p_deployment_id,
					   p_status => 'ERROR',
					   p_reminder_type => p_reminder_type,
					   p_update_flag => 'Y');

	WHEN OTHERS THEN
		rollback to FM_Request_From_Survey;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		fnd_file.put_line(fnd_file.log, x_message);
		x_message := x_message || ' ' ||SQLERRM;
		-- write the error msg to log, if conc request is executing this code then
		-- the log is viewable in concurrent manger log for that specific request
		if(l_msg_count is not null) then
			for l_index IN 1..l_msg_count loop
				l_msg_data :=FND_MSG_PUB.Get(
					p_msg_index => l_index,
					p_encoded => FND_API.G_FALSE);
				x_msg_data :=  l_msg_data;
				fnd_file.put_line(fnd_file.log, l_msg_data);
			end loop;
		end if;
		fnd_file.put_line(fnd_file.log, SQLERRM);

		-- cancel the request just sent
		JTF_FM_REQUEST_GRP.Cancel_Request
				(p_api_version => l_api_version,
				p_commit => l_commit,
				p_init_msg_list => FND_API.G_FALSE,
				x_return_status => l_return_status,
				x_msg_count => l_msg_count,
				x_msg_data => l_msg_data,
				p_request_id => l_request_id);
		Update_Dep_Status(p_dep_id => p_deployment_id,
					   p_status => 'ERROR',
					   p_reminder_type => p_reminder_type,
					   p_update_flag => 'Y');

END FM_Group_Request;

----------------------------------------------------------------------------------------------------------
-- Procedure
--   Populate_Survey_List_Entries
-- PURPOSE  Wrapper API to populate IES_SVY_LIST_ENTRIES based on the list_header_id and .
--           deployment_id
--
-- PARAMETERS
-- NOTES
-- created kpandey 06/07/2000
---------------------------------------------------------------------------------------------------------

PROCEDURE Populate_Survey_List_Entries
(
   p_api_version         	IN  NUMBER                                  ,
   p_init_msg_list       	IN  VARCHAR2  := FND_API.G_FALSE           ,
   p_commit              	IN  VARCHAR2  := FND_API.G_FALSE            ,
   p_validation_level  	    IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL ,
   x_return_status        OUT NOCOPY /* file.sql.39 change */ VARCHAR2                                ,
   x_msg_count            OUT NOCOPY /* file.sql.39 change */ NUMBER                                  ,
   x_msg_data             OUT NOCOPY /* file.sql.39 change */ VARCHAR2                                ,
   x_message                OUT NOCOPY /* file.sql.39 change */ VARCHAR2                                ,
   p_survey_deployment_id   IN  NUMBER
)

IS

--PRAGMA AUTONOMOUS_TRANSACTION;

l_api_version				    NUMBER := 1.0                                   ;
l_commit					    VARCHAR2(5) := FND_API.G_FALSE                  ;
l_msg_count 				    NUMBER                                          ;
l_msg_data 					    VARCHAR2(1000)                                  ;
l_return_status 		        VARCHAR2(1000)                                  ;
l_Error_Msg                     VARCHAR2(2000)                                  ;
l_random_number                 BINARY_INTEGER                                  ;
l_total_list_entries            NUMBER := 0                                     ;
l_list_header_id                IES_SVY_DEPLYMENTS_ALL.LIST_HEADER_ID%TYPE      ;
l_list_entry_id                 AMS_LIST_ENTRIES.LIST_ENTRY_ID%TYPE             ;
l_seed		                    NUMBER                                          ;
l_time_in_sec		            NUMBER                                          ;
l_api_name                      VARCHAR2(30) :=  'Populate_Survey_List_Entries' ;
l_count_value                   NUMBER                                          ;
l_full_name            CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

CURSOR CLISTENTRYID IS
  SELECT LIST_ENTRY_ID
  FROM  AMS_LIST_ENTRIES
  WHERE LIST_HEADER_ID =  l_list_header_id
  AND ENABLED_FLAG = 'Y';
BEGIN

   SAVEPOINT Populate_Survey_List_Entries;
	-- Submit the fulfillment request
-- l_api_name :=  'Populate_Survey_List_Entries';
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('JTF','JTF_FM_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ARG1',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
	 -- Initialize API return status to success
  	x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF (p_survey_deployment_id IS NULL) THEN
		l_Error_Msg := 'Must pass p_survey_deployment_id parameter';
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name('IES', 'IES__SVY_API_MISSING_DEPLOYMENT_ID');
       	   FND_MSG_PUB.Add;
        END IF;
         x_message := l_Error_Msg;
	    RAISE  FND_API.G_EXC_ERROR;
    END IF;

    BEGIN
     SELECT  LIST_HEADER_ID INTO l_list_header_id
         FROM IES_SVY_DEPLYMENTS_ALL
       WHERE SURVEY_DEPLOYMENT_ID = p_survey_deployment_id;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             l_Error_Msg := 'Deployment doesn''t have list_header_id';
		  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('IES', 'IES_SVY_API_MISSING_HEADER_ID');
       	     FND_MSG_PUB.Add;
          END IF;
             x_message := l_Error_Msg;
	    RAISE  FND_API.G_EXC_ERROR;
    END;

    BEGIN
     SELECT COUNT(*) INTO l_total_list_entries
        FROM AMS_LIST_ENTRIES
      WHERE LIST_HEADER_ID = l_list_header_id;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
             l_Error_Msg := 'AMS_LIST_ENTRIES doesn''t have list_header_id';
		  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('IES', 'IES_SVY_API_MISSING_HEADER_ID');
       	     FND_MSG_PUB.Add;
          END IF;
             x_message := l_Error_Msg;
	    RAISE  FND_API.G_EXC_ERROR;
    END;

   IF  l_total_list_entries > 0 THEN
     l_time_in_sec := dbms_utility.get_time();
     l_seed := MOD(l_time_in_sec,100000);
     --DBMS_OUTPUT.PUT_LINE('seedis  '|| l_seed);
     dbms_random.initialize (l_seed);

     -- To check if concurrent manager has entered values for particular deployment ID on prior failure.
    SELECT count(*) INTO l_count_value
      FROM IES_SVY_LIST_ENTRIES
    WHERE SURVEY_DEPLOYMENT_ID = p_survey_deployment_id;

    IF l_count_value < 1 THEN
     OPEN CLISTENTRYID;
     LOOP
        FETCH CLISTENTRYID into l_list_entry_id;
        EXIT WHEN CLISTENTRYID%NOTFOUND;
           l_random_number := ABS(dbms_random.random);
           --DBMS_OUTPUT.PUT_LINE('Random no is '||l_random_number);
           --DBMS_OUTPUT.PUT_LINE('list_entry_id is '|| ABS(l_list_entry_id));

        insert into ies_svy_list_entries
		(
		SURVEY_LIST_ENTRY_ID
		,OBJECT_VERSION_NUMBER
		,CREATED_BY
		,CREATION_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATE_LOGIN
		,SURVEY_DEPLOYMENT_ID
		,LIST_ENTRY_ID
		,RESPONDENT_ID
		)
	   values
		( ies_svy_list_entries_s.nextval
		,1
		,-1
		,sysdate
		,-1
		,sysdate
		,-1
		,p_survey_deployment_id
		,l_list_entry_id
		,l_random_number
		);

     END LOOP;
      CLOSE CLISTENTRYID;
      dbms_random.terminate;

    END IF;
   ELSIF l_total_list_entries = 0 THEN
            -- vacharya: Hard Coded x_message 'IES_SVY_EMPTY_AMS_LIST' remember to enter it in FND_NEW_MESSAGE
            x_message := 'IES_SVY_EMPTY_AMS_LIST';
            RAISE FND_API.G_EXC_ERROR;

   END IF;


    -- DBMS_OUTPUT.PUT_LINE('Return Status: '||l_return_status);
    -- DBMS_OUTPUT.PUT_LINE('Message_Count: '||l_msg_count);
    -- DBMS_OUTPUT.PUT_LINE('Message Data: '||l_msg_data);

  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN

		    ROLLBACK TO Populate_Survey_List_Entries;
		    x_return_status := FND_API.G_RET_STS_ERROR ;
            --vacharya: Commented out until the message 'IES_SVY_EMPTY_AMS_LIST' is inserted in the FND_NEW_MESSAGES table
           x_message := x_message || SQLERRM;
		    FND_MSG_PUB.Count_And_Get
    		     (  p_count         	=>      x_msg_count     	,
        		  	p_data          	=>      x_msg_data
             );
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		    ROLLBACK TO Populate_Survey_List_Entries;
		    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            x_message := x_message || SQLERRM;
		    FND_MSG_PUB.Count_And_Get
    	 	    (  	p_count         	=>      x_msg_count     	,
        	  		p_data          	=>      x_msg_data
     		    );
     WHEN OTHERS THEN
        rollback to Populate_Survey_List_Entries;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        x_message := x_message || SQLERRM;

		FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
          			p_data          	=>      x_msg_data
    	);

END Populate_Survey_List_Entries;


Procedure Update_Dep_Status (p_dep_id NUMBER,
			    p_status VARCHAR2,
			    p_reminder_type VARCHAR2,
			    p_update_flag VARCHAR2) IS

l_deployment_status_code       VARCHAR2(30);
l_dep_count_active             NUMBER := 0;
l_survey_cycle_id              NUMBER := 0;
l_survey_id                    NUMBER :=0;

BEGIN
	IF (p_reminder_type is null)  THEN

		SELECT  DEPLOYMENT_STATUS_CODE, SURVEY_CYCLE_ID
		INTO    l_deployment_status_code, l_survey_cycle_id
		FROM IES_SVY_DEPLYMENTS_V
		WHERE SURVEY_DEPLOYMENT_ID = p_dep_id;

		SELECT count(*)
		INTO l_dep_count_active
		FROM IES_SVY_DEPLYMENTS_V
		WHERE SURVEY_CYCLE_ID = l_survey_cycle_id
		AND DEPLOYMENT_STATUS_CODE  = 'ACTIVE';

		if (p_update_flag = 'Y') then
			UPDATE IES_SVY_DEPLYMENTS_V
			SET DEPLOYMENT_STATUS_CODE = p_status
			where survey_deployment_id =  p_dep_id;
		end if;

		IF ((l_dep_count_active is null) OR (l_dep_count_active = 0)) THEN
			SELECT SURVEY_ID
			INTO l_survey_id
			FROM IES_SVY_CYCLES_V
			WHERE SURVEY_CYCLE_ID = l_survey_cycle_id;

			IF ((p_status = 'PENDING') OR (p_status = 'ACTIVE')) THEN
				UPDATE IES_SVY_SURVEYS_V
				SET SURVEY_STATUS_CODE = 'ACTIVE'
				WHERE SURVEY_ID = l_survey_id;
			END IF;
		END IF;
	END IF;

END;

END IES_SVY_DEPLOYMENT_PVT;

/
