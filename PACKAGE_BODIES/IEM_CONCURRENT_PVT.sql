--------------------------------------------------------
--  DDL for Package Body IEM_CONCURRENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_CONCURRENT_PVT" as
/* $Header: iemvconb.pls 115.7 2002/12/22 01:20:05 sboorela shipped $*/

G_PKG_NAME CONSTANT varchar2(30) :='IEM_CONCURRENT_PVT ';

PROCEDURE StartProcess(ERRBUF   OUT NOCOPY     VARCHAR2,
                       RETCODE  OUT NOCOPY     VARCHAR2,
                       p_period_to_wake_up  NUMBER,
                       p_number_of_threads  NUMBER,
                       p_number_of_msgs     NUMBER,
                       p_schedule_retry	    VARCHAR2,
                       p_hour		    NUMBER,
                       p_minutes	    NUMBER)
IS
    l_request_id              NUMBER;
    l_Error_Message           VARCHAR2(2000);
    l_call_status             BOOLEAN;
    l_time_to_sch	      VARCHAR2(25);

    MAIN_WORKER_NOT_SUBMITTED EXCEPTION;
    REPEAT_OPTIONS_NOT_SET    EXCEPTION;
    WORKER_NOT_SUBMITTED      EXCEPTION;
    RETRY_NOT_SUBMITTED	      EXCEPTION;
    INVALID_HOUR	      EXCEPTION;
    INVALID_MINUTE	      EXCEPTION;
BEGIN

    fnd_file.put_line(fnd_file.log, 'p_period_to_wake_up = ' || to_char(p_period_to_wake_up));
    fnd_file.put_line(fnd_file.log, 'p_number_of_threads = ' || to_char(p_number_of_threads));
    fnd_file.put_line(fnd_file.log, 'p_number_of_msgs = ' || to_char(p_number_of_msgs));
    fnd_file.put_line(fnd_file.log, 'p_schedule_retry = ' || p_schedule_retry);
    fnd_file.put_line(fnd_file.log, 'p_hour = ' || to_char(p_hour));
    fnd_file.put_line(fnd_file.log, 'p_minutes = ' || to_char(p_minutes));

    fnd_file.put_line(fnd_file.log, 'Starting Processing');

    if p_schedule_retry = 'Y' then
    	if p_hour not between 0 and 23 then
    		raise INVALID_HOUR;
    	end if;

    	if p_minutes not between 0 and 59 then
    		raise INVALID_MINUTE;
    	end if;
    end if;

    --Submitting the process that remains forever
    --samir.hans commented out on 8/18/2000
    /*l_request_id := fnd_request.submit_request('IEM', 'IEMADMWW', '','',FALSE,1,'F','T','MAILPREPROC','IEM_MAIL','FOREVER',p_number_of_msgs);

    fnd_file.put_line(fnd_file.log, 'Main Worker Request Id ' || to_char(l_request_id));

    if l_request_id = 0 then
        rollback;
        raise MAIN_WORKER_NOT_SUBMITTED;
    else
        commit;
   end if;*/

   FOR i in 1..p_number_of_threads loop

        l_call_status := fnd_request.set_repeat_options('',p_period_to_wake_up,'MINUTES','END');

        if not l_call_status then
            rollback;
            raise REPEAT_OPTIONS_NOT_SET;
        end if;

        l_request_id := fnd_request.submit_request('IEM', 'IEMADMWW', '','',FALSE,1,'F','T','MAILPREPROC','IEM_MAIL','NO_WAIT',p_number_of_msgs);

        fnd_file.put_line(fnd_file.log, 'Worker number ' || to_char(i) || ' Request Id ' || to_char(l_request_id));

        if l_request_id = 0 then
            rollback;
            raise WORKER_NOT_SUBMITTED;
        else
            commit;
        end if;

   end loop;

   if (p_schedule_retry = 'Y') then

    	l_time_to_sch := to_char(p_hour) || ':' || to_char(p_minutes);

    	fnd_file.put_line(fnd_file.log, 'Retry process time  ' || l_time_to_sch);

    	l_call_status := fnd_request.set_repeat_options(repeat_time => l_time_to_sch);

        if not l_call_status then
        	 rollback;
        	raise REPEAT_OPTIONS_NOT_SET;
    	end if;

    	fnd_file.put_line(fnd_file.log, 'Retry repeat options set for retry process');

    	l_request_id := fnd_request.submit_request('IEM', 'IEMADMWR', '','',FALSE,1,'F','T','MAILPREPROC','IEM_MAIL');

    	if l_request_id = 0 then
            rollback;
            raise RETRY_NOT_SUBMITTED;
        else
            commit;
   	 end if;

    	fnd_file.put_line(fnd_file.log, 'Retry folders scheduled. Request id = ' || to_char(l_request_id));

    end if;


    Commit work;
    fnd_file.put_line(fnd_file.log, 'Controller Exited');

EXCEPTION
	WHEN INVALID_HOUR THEN
        FND_MESSAGE.SET_NAME('IEM','IEM_ADM_INVALID_HOUR');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', l_Error_Message);

        WHEN INVALID_MINUTE THEN
        FND_MESSAGE.SET_NAME('IEM','IEM_ADM_INVALID_MINUTE');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', l_Error_Message);

        WHEN REPEAT_OPTIONS_NOT_SET THEN
        FND_MESSAGE.SET_NAME('IEM','IEM_ADM_REPEAT_OPTIONS_NOT_SET');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', l_Error_Message);

        WHEN MAIN_WORKER_NOT_SUBMITTED THEN
        FND_MESSAGE.SET_NAME('IEM','IEM_ADM_MAIN_WORKER_NOT_SUBMITTED');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', l_Error_Message);

        WHEN WORKER_NOT_SUBMITTED THEN
        FND_MESSAGE.SET_NAME('IEM','IEM_ADM_WORKER_NOT_SUBMITTED');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', l_Error_Message);

        WHEN RETRY_NOT_SUBMITTED THEN
        FND_MESSAGE.SET_NAME('IEM','IEM_ADM_RETRY_NOT_SUBMITTED');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', l_Error_Message);

        WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IEM','IEM_ADM_UNXP_ERROR');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', l_Error_Message);
END StartProcess;

PROCEDURE SyncFolder(ERRBUF   OUT   NOCOPY   VARCHAR2,
                     RETCODE  OUT   NOCOPY   VARCHAR2
                    )
 is
  i number;
  l_counter NUMBER:=1;
  email_account_id_list email_account_id_tbl;
  	l_pass VARCHAR2(15);
	l_email_user VARCHAR2(30);
	l_domain VARCHAR2(30);
	l_db_server_id NUMBER;
    l_im_link varchar2(200);
    l_im_link1 varchar2(200);
  	l_stat	varchar2(10);
    l_count	number;
    l_data	varchar2(255);
    l_str VARCHAR2(200);
    l_ret NUMBER;
    IM_AUTHENTICATION_FAILED EXCEPTION;
    IM_CREATEFOLDER_FAILED EXCEPTION;
    l_resource_id number;
    l_Error_Message           VARCHAR2(2000);
    l_call_status             BOOLEAN;
    l_user_name varchar2(50);
    l_folder varchar2(100);


 begin
   declare
               CURSOR r_cur is
                 SELECT email_account_id from iem_email_accounts;
                  begin
                    open r_cur;
                        LOOP

    	 	     	       FETCH r_cur into email_account_id_list(l_counter);
     				       EXIT WHEN (r_cur%notfound);
     		               l_counter:=l_counter+1;

     	                END LOOP;

                    close r_cur;
                  end;
   for i in 1..email_account_id_list.count loop
        SELECT	EMAIL_PASSWORD,	EMAIL_USER,	DOMAIN, DB_SERVER_ID
  		INTO l_pass,	l_email_user, l_domain, 	l_db_server_id
  	    FROM IEM_EMAIL_ACCOUNTS
   		WHERE EMAIL_ACCOUNT_ID = email_account_id_list(i);

        IEM_DB_CONNECTIONS_PVT.select_item(
               		p_api_version_number =>1.0,
                 	p_db_server_id  =>l_db_server_id,
               		p_is_admin =>'P',
  					x_db_link=>l_IM_LINK1,
  					x_return_status =>l_stat,
  					x_msg_count    => l_count,
  					x_msg_data      => l_data);

		If l_im_link1 is null then
  	         l_im_link:=null;
		else
   		     l_im_link:='@'||l_im_link1;
		end if;
  	    l_str:='begin :l_ret:=im_api.authenticate'||l_im_link||'(:a_user,:a_domain,:a_password);end; ';
        EXECUTE IMMEDIATE l_str using OUT l_ret,l_email_user,l_domain,l_pass;
   	    IF l_ret <> 0 THEN
   		   raise IM_AUTHENTICATION_FAILED;

  	    END IF;

        declare
            cursor v_cur is
                select resource_id
                from jtf_rs_resource_values where value_type = to_char(email_account_id_list(i));
                begin
                    open v_cur;
                        LOOP

    	 	     	       FETCH v_cur into l_resource_id;
     				       EXIT WHEN (v_cur%notfound);

                           select a.user_name into l_user_name
                           from fnd_user a, jtf_rs_resource_extns b
                           where a.user_id = b.user_id and b.resource_id = l_resource_id;

                           l_folder := '/'||l_user_name||'/Drafts';

                        	-- Now we are ready to call im createfolder
                            l_str:='begin :l_ret:=im_api.createfolder'||l_im_link||'(:a_folder);end; ';
                            EXECUTE IMMEDIATE l_str using OUT l_ret,l_folder;
                            IF l_ret <> 0 THEN
                                raise IM_CREATEFOLDER_FAILED;

	                        END IF;

     	                END LOOP;

                    close v_cur;
                end;

   end loop;

   EXCEPTION

   WHEN IM_AUTHENTICATION_FAILED THEN
        FND_MESSAGE.SET_NAME('IEM','IM_AUTHENTICATION_FAILED');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', l_Error_Message);


   WHEN IM_CREATEFOLDER_FAILED THEN
        FND_MESSAGE.SET_NAME('IEM','IM_CREATEFOLDER_FAILED');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', l_Error_Message);

 end SyncFolder;


END IEM_CONCURRENT_PVT;

/
