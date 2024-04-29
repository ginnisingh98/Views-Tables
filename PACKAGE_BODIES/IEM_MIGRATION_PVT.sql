--------------------------------------------------------
--  DDL for Package Body IEM_MIGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_MIGRATION_PVT" as
/* $Header: iemvmgrb.pls 120.24.12010000.3 2008/11/06 00:26:05 rtripath ship $*/
g_statement_log	boolean;		-- Statement Level Logging
g_exception_log	boolean;		-- Statement Level Logging
g_error_log	boolean;		-- Statement Level Logging


procedure build_migration_queue(x_status out nocopy varchar2) IS
cursor c_account is select email_account_id,email_user,domain,EMAIL_PASSWORD,db_link from
iem_email_accounts a,iem_db_connections b
where a.db_server_id=b.db_server_id
and b.is_admin='A'
and upper(a.email_user)<>'INTENT';
l_email_account_id		number;
cursor c_folder is
select name||','||a.route_classification_id name from iem_route_classifications a,iem_account_route_class b
where a.route_classification_id=b.route_classification_id
and b.email_account_id=l_email_account_id
union
select 'Inbox' from dual
union
select 'Drafts' from dual
union
select 'Resolved' from dual
union
select 'Sent' from dual
union
select 'Deleted' from dual
union
select 'Admin' from dual
union
select 'Retry' from dual;
l_total_count		number;
l_str 		varchar2(255);
G_IM_LINK		varchar2(255);
G_FOLDER		varchar2(255);
l_ret		number;
l_auth		number;
l_class_id		number;
l_folder_name		varchar2(256);
l_folder_type		varchar2(1);
l_msg_table         iem_im_wrappers_pvt.msg_table;
l_status		varchar2(1);
l_status_text		varchar2(1000);
l_ack_flag		number:=0;
cursor c_agent is select agent_account_id,resource_id from iem_agent_accounts
where email_account_id= l_email_account_id;
 l_CREATED_BY    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID'));
     l_LAST_UPDATED_BY    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
     l_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ ID')) ;
	l_mig_id			number;
	l_logmessage		varchar2(1000);
	x_folder_tbl  	jtf_varchar2_table_100:=jtf_varchar2_table_100() ;
	Type get_folder_data is REF CURSOR;
	arch_cur		get_folder_data;
	l_folder_count		number;
	l_arch_folder		varchar2(100);
begin
	-- Check Logging Enabled or Not...
		FND_LOG_REPOSITORY.init(null,null);
		if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
			g_exception_log:=true;
		end if;
for v1 in c_account LOOP
	l_email_account_id:=v1.email_account_id;
	-- Authenticate into OES
	G_IM_LINK:='@'||v1.db_link;
		l_str:='begin :l_auth:=im_api.authenticate'||G_IM_LINK||'(:a_user,:a_domain,:a_password);end; ';
EXECUTE IMMEDIATE l_str using OUT l_auth,v1.email_user,v1.domain,v1.email_password;
	open c_folder;
	fetch c_folder bulk collect into x_folder_tbl;
	close c_folder;

	-- Check for archived folder
	begin
	open arch_cur for
	'select arch_folder_name from iem_Archived_Folders where
	email_account_id=:id ' using l_email_account_id;
	l_folder_count:=x_folder_tbl.last;
	LOOP
		fetch arch_cur into l_arch_folder;
		exit when	 arch_cur%notfound ;
		if l_arch_folder is not null then
			l_folder_count:=l_folder_count+1;
 	 		x_folder_tbl.extend;
			x_folder_tbl(l_folder_count):=l_arch_folder;
		end if;
	END LOOP;
	EXCEPTION WHEN OTHERS THEN
		null;
	END;
	for i in x_folder_Tbl.first..x_folder_tbl.last LOOP
	/* Check for ack account . We are only required to record for Sent folder of Ack account */
	 IF (upper(v1.email_user)='ACKNOWLEDGEMENTS') and x_folder_tbl(i) in ('Resolved','Deleted','Admin','Retry') then
	 	l_ack_flag:=1;
	 END IF;
	 if l_ack_flag=0 then
		l_status_text:=null;
		l_status:='S';
		if x_folder_tbl(i) in ('Inbox','Drafts') then
			l_folder_name:=x_folder_tbl(i);
			l_folder_type:= substr(x_folder_tbl(i),1,1);
			l_status_text:='Succesfully Count for Folder ';
			l_status:='S';
			for v3 in c_agent LOOP
			if l_folder_type='I' then
				select count(*) into l_total_count
				from iem_post_mdts where email_account_id=l_email_account_id and agent_id=v3.resource_id ;
			else
				select count(a.rt_media_item_id)
	   			into l_total_count
           		from iem_rt_media_items a, iem_msg_parts part
           		where a.rt_interaction_id in (select rtm.rt_interaction_id
           		from iem_rt_media_items rtm, iem_rt_interactions rti
           		where rtm.message_id in (select message_id from iem_post_mdts
          		 where email_account_id = l_email_account_id  and agent_id = v3.resource_id)
           		and rtm.email_type ='I' and rtm.rt_interaction_id = rti.rt_interaction_id
           		and rti.expire = 'N') and a.email_type = 'O' and a.folder_uid > 0
           		and a.folder_name = 'Drafts' and part.ref_key = a.rt_media_item_id
           		and part.part_type = 'HEADERS' and part.delete_flag <> 'Y';
			end if;
				select IEM_MIGRATION_DETAILS_S1.nextval into l_mig_id from dual;
				insert into IEM_MIGRATION_DETAILS
				(migration_id,
				agent_account_id,
				email_account_id,
				folder_name,
				folder_type,
				total_msg_count,
				status,
				status_text,
				CREATED_BY          ,
				CREATION_DATE       ,
				LAST_UPDATED_BY     ,
				LAST_UPDATE_DATE    ,
				LAST_UPDATE_LOGIN   )

				values

				(l_mig_id,v3.agent_Account_id,l_email_account_id,l_folder_name,l_folder_type,l_total_count,
				l_status,l_status_text,l_created_by,sysdate,l_last_updated_by,sysdate,l_last_update_login);
		END LOOP;
		else
			if ((x_folder_tbl(i) in  ('Resolved','Sent','Deleted','Admin','Retry'))
			OR (x_folder_tbl(i) like 'Arch%')) then
				l_folder_name:=x_folder_tbl(i);
				if x_folder_tbl(i) in ('Admin','Retry') then
					l_folder_type:='N';
				else
					l_folder_type:='H';
				end if;
		 	if l_auth=0 then	-- succesfully authenticated
		 		G_FOLDER:='/'||x_folder_tbl(i);
				l_total_count:=0;
		 		l_ret:=iem_im_wrappers_pvt.openfolder(G_FOLDER,G_IM_LINK,l_msg_table);
		 		if l_ret=0 then		-- openfolder return no error
		 			l_total_count:=l_msg_table.count;
					l_folder_name:=x_folder_tbl(i);
					l_status_text:='Succesfully Count for Folder ';
					l_status:='S';
		     	else
		 			l_status_text:=' Open Folder Error for Folder '||x_folder_tbl(i)||'Error Code is '||l_ret ;
					l_status:='E';
		 		end if;
		 	else
		 	 l_status_text:=' Error in Authentication '||' Error Code Is '||l_auth|| ' Can not retrieve Folder Count ';
				l_status:='E';
		 	end if;
		else  			-- Classification Folders
			l_class_id:=substr(x_folder_tbl(i),instr(x_folder_tbl(i),',',1)+1);
			l_folder_name:=substr(x_folder_tbl(i),1,instr(x_folder_tbl(i),',',1)-1);
			l_folder_type:='Q';
			select count(*) into l_total_count
			from iem_post_mdts where email_account_id=l_email_account_id
			and rt_classification_id=l_class_id and agent_id=0;
			l_status_text:='Succesfully Count for Folder ';
			l_status:='S';
		end if;
				select IEM_MIGRATION_DETAILS_S1.nextval into l_mig_id from dual;
				insert into IEM_MIGRATION_DETAILS
				(migration_id,
				email_account_id,
				folder_name,
				folder_type,
				total_msg_count,
				status,
				status_text,
				CREATED_BY          ,
				CREATION_DATE       ,
				LAST_UPDATED_BY     ,
				LAST_UPDATE_DATE    ,
				LAST_UPDATE_LOGIN   )

		values

		(l_mig_id,l_email_account_id,l_folder_name,l_folder_type,l_total_count,l_status,l_status_text,l_created_by,
		sysdate,l_last_updated_by,sysdate,l_last_update_login);
		END IF;		-- End if for all folders type
	   END IF;		-- end if for ack flag..
	   l_ack_flag:=0;
	  END LOOP;
	END LOOP;			-- Account LOOP
	x_status:='S';
EXCEPTION WHEN OTHERS THEN
	if g_exception_log then
		l_logmessage:='Oracle Error Encountered during Building Folder Counts '||sqlerrm;
		iem_logger(l_logmessage);
		x_Status:='E';
	end if;
end build_migration_queue;

procedure start_postprocessing(p_migration_id in number, x_Status out nocopy varchar2) IS
cursor c1 is select * from iem_migration_store_temp
where migration_id=p_migration_id and mig_status='R' and dp_status='D';
l_media_id	number;
l_contact_id	number;
l_resource_id	number;
l_relationship_id	number;
l_party_id	number;
 l_CREATED_BY    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID'));
 l_LAST_UPDATED_BY    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
 l_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ ID')) ;
 l_proc_status		varchar2(100);
 l_mail_type		number;
 l_received_Date		date;
 l_folder_type		varchar2(10);
  l_priority		number;
  l_post_rec		iem_post_mdts%rowtype;
  l_ret_status		varchar2(10);
  l_msg_count		number;
  l_msg_Data		varchar2(250);
  l_message_id		number;
  l_mig_status		varchar2(1);
  l_error_text		varchar2(1000);
  Type get_data is REF CURSOR;
  ih_cur		get_data;
begin
select folder_type into l_folder_type from iem_migration_details
where migration_id=p_migration_id;
if l_folder_type='H' then
for v1 in c1 LOOP
	BEGIN
	l_mail_type:=0;		-- This is by default and will change based on folder name
	if upper(v1.folder_name) like '%RESOLVED%' then
		l_proc_status:='R';
	elsif  upper(v1.folder_name) like '%DELETE%' then
		l_proc_status:='D';
	else
		l_proc_status:='S';
		l_mail_type:=1;
	end if;
-- Retrieve Resouce Party etc from IH
	l_media_id:=v1.ih_media_item_id;
	select creation_date into l_received_Date from jtf_ih_media_items
	where media_id=l_media_id;
	l_received_date:=sysdate;
	select iem_ms_base_headers_s1.nextval into l_message_id from dual;

	insert into iem_arch_msgdtls
    (MESSAGE_ID   ,
 	EMAIL_ACCOUNT_ID  ,
 	MAILPROC_STATUS ,
 	MAIL_TYPE,
 	FROM_STR,
 	REPLY_TO_STR,
 	TO_STR,
 	CC_STR,
 	BCC_STR,
 	SENT_DATE,
 	RECEIVED_DATE ,
 	SUBJECT,
 	RESOURCE_ID ,
 	MESSAGE_SIZE ,
 	IH_MEDIA_ITEM_ID,
 	CUSTOMER_ID,
 	CONTACT_ID,
 	RELATIONSHIP_ID ,
 	MESSAGE_TEXT,
 	CREATED_BY,
 	CREATION_DATE,
 	LAST_UPDATED_BY,
 	LAST_UPDATE_DATE ,
 	LAST_UPDATE_LOGIN)
values
       ( 	l_message_id,
          v1.email_account_id,
          l_proc_status,
          l_mail_type,
          v1.from_str,
          v1.reply_to_str,
          v1.to_str,
          v1.cc_str,
          v1.bcc_str,
          v1.sent_date,
          l_received_date,
          v1.subject,
          l_resource_id,
          v1.message_size,
	  l_media_id,
	   l_party_id,
          l_contact_id,
          l_relationship_id,
          v1.message_text,
		nvl(l_created_by,-1),
		sysdate,
		nvl(l_last_updated_by,-1),
		sysdate,
		l_last_update_login);

	-- Insert into IEM_ARCH_MESSAGES
	insert into iem_arch_msgs
	(MESSAGE_ID,
 	MESSAGE_CONTENT,
 	CREATED_BY,
 	CREATION_DATE,
 	LAST_UPDATED_BY,
 	LAST_UPDATE_DATE,
 	LAST_UPDATE_LOGIN)
	(select decode(message_id,message_id,l_message_id),message_content,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN from
	iem_migration_Store_temp where migration_id=p_migration_id and message_id=v1.message_id);

	-- Update Media Items with new message Id
	update jtf_ih_media_items
	set media_item_ref=l_message_id
	where media_id=v1.ih_media_item_id;
			update iem_migration_store_temp
			set mig_Status='M'
			where migration_id=p_migration_id and message_id=v1.message_id;
	EXCEPTION
		WHEN OTHERS THEN
			l_mig_status:='E';
			l_error_text:=sqlerrm;

			delete from iem_arch_msgs where message_id=l_message_id;
			delete from iem_arch_msgdtls where message_id=l_message_id;

			update iem_migration_store_temp
			set mig_Status='E',
			error_text=l_error_text
			where migration_id=p_migration_id and  message_id=v1.message_id;
	END;

 END LOOP;
 elsif l_folder_type in ('Q','I') then -- Queued/Acquired Message
	for v1 in c1 LOOP
	BEGIN
		select * into l_post_rec from iem_post_mdts
		where message_id=v1.message_id;
		if l_post_rec.priority='High' then
			l_priority:=2;
	     elsif  l_post_rec.priority='Low' then
			 l_priority:=0;
		else
			 l_priority:=1;
		end if;
		IEM_RT_PROC_EMAILS_PVT.create_item (
					p_api_version_number => 1.0,
  					p_init_msg_list=>'F' ,
					p_commit=>'F',
				p_message_id =>v1.message_id,
				p_email_account_id  =>v1.email_account_id,
				p_priority  =>l_priority,
				p_agent_id  =>l_post_rec.agent_id,
				p_group_id  =>l_post_rec.group_id,
				p_sent_date =>v1.sent_date,
				p_received_date =>l_post_rec.received_Date,
				p_rt_classification_id =>l_post_rec.rt_classification_id,
				p_customer_id=>l_party_id    ,
				p_contact_id=>l_contact_id    ,
				p_relationship_id=>l_relationship_id    ,
				p_interaction_id=>l_post_rec.ih_interaction_id ,
				p_ih_media_item_id=>v1.ih_media_item_id ,
				p_msg_status=>l_post_rec.msg_status  ,
				p_mail_proc_status=>'P' ,
				p_mail_item_status=>l_post_rec.mail_item_status ,
				p_category_map_id=>l_post_rec.category_map_id ,
				p_rule_id=>l_post_rec.icenter_map_id,
				p_subject=>v1.subject,
				p_sender_address=>v1.from_str,
				p_from_agent_id=>l_post_rec.from_agent_id,
     			x_return_status=>l_ret_status	,
  				x_msg_count=>l_msg_count	      ,
 				x_msg_data=>l_msg_data);
		if l_ret_status='S' then
				-- Update Message Flag
				begin
				if l_post_rec.message_flag is not null then
					update iem_Rt_proc_emails
					set message_flag=l_post_rec.message_flag
					where message_id=l_post_rec.message_id;
			     end if;
				exception when others then
					null;
				end;
	-- Update Media Items with new message Id

	update jtf_ih_media_items
	set media_item_ref=v1.message_id
	where media_id=v1.ih_media_item_id;
	-- update MIG status to "M"
			update iem_migration_store_temp
			set mig_Status='M'
			where migration_id=p_migration_id and message_id=v1.message_id;
	end if;
	EXCEPTION
		WHEN OTHERS THEN
			l_mig_status:='E';
			l_error_text:=sqlerrm;
			update iem_migration_Store_temp
			set mig_Status=l_mig_status,
			error_text=l_error_text
			where migration_id=p_migration_id and message_id=v1.message_id;
	END;
	END LOOP;
 end if;
 		update iem_migration_details
		set folder_status='M'
		where migration_id=p_migration_id;
 	commit;
 EXCEPTION WHEN OTHERS THEN		-- Folder level Error During Post Processing
 		update iem_migration_details
		set folder_status='M',
		status='E',
		STATUS_TEXT='Error Encountered During Post Processing '
		where migration_id=p_migration_id;
		commit;

end start_postprocessing;
procedure create_worklist(p_migration_id in number,x_status out nocopy varchar2) IS
l_email_account_id  number;
l_folder_name  varchar2(128);
l_folder_type varchar2(10);
l_mig_rec		iem_migration_store_temp%rowtype;
l_error_text	varchar2(500);
cursor c_queue is
 select a.* from iem_post_mdts a,iem_route_classifications b
 where a.email_account_id=l_email_account_id and a.agent_id=0
 and a.rt_classification_id=b.route_classification_id and
 b.name=l_folder_name and a.message_id not in (select message_id from iem_migration_store_temp
 where migration_id=p_migration_id)
 union			-- select records which are also errors out
 select a.* from iem_post_mdts a,iem_route_classifications b
 where a.email_account_id=l_email_account_id and a.agent_id=0
 and a.rt_classification_id=b.route_classification_id and
 b.name=l_folder_name and a.message_id in (select message_id from iem_migration_store_temp
 where migration_id=p_migration_id and mig_status='E' and dp_status is null);
l_dblink		varchar2(500);
l_user		varchar2(500);
l_domain		varchar2(500);
l_pass		varchar2(100);
l_rec_counter	number:=0;
l_str		varchar2(1000);
l_msg_table		iem_im_wrappers_pvt.msg_table;
l_folder_count		number:=0;
l_folder		varchar2(255);
l_uid		number;
l_received_date	date;
x_priority		number;
l_read		number;
l_expiration		date;
l_ret		number;
 l_CREATED_BY    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID'));
 l_LAST_UPDATED_BY    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
 l_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ ID')) ;
 l_hist_date			date;
 l_hist_count		number;
 l_mig_status		varchar2(1);
 l_content		blob;
 l_agent_account_id		number;
 INSERT_ERROR		EXCEPTION;
 OTHER_ERROR		EXCEPTION;
 AUTH_ERROR		EXCEPTION;
 OPEN_FOLDER_ERROR 	EXCEPTION;
	cursor c_historical is
	select message_id from iem_migration_store_temp
	where migration_id=p_migration_id and
	(mig_status='E' and DP_STATUS is null);
	cursor c_normal is 			-- For Admin and Retry folder
	select message_id from iem_migration_store_temp
	where migration_id=p_migration_id and
	(mig_status='E' and  DP_STATUS is null);
	l_ret_status		varchar2(10);
	l_msg_count		number;
	l_msg_data		varchar2(100);
	l_total_msg_count	number;
	INQ_EXCEPTION		EXCEPTION;
	UID_EXCEPTION		EXCEPTION;
	l_hist_flag		varchar2(10);
	l_inb_migration_id	number;
	l_outb_migration_id	number;
	l_type			varchar2(10);
	l_ag_count		number;
	l_qcount		number;
	l_disc_count		number;
	l_mig_id		number;
	l_source_message_id		number;
	l_error_counter		number;
	l_rerun			varchar2(10);
	cursor c_discp is
		select mail_id,folder_name,email_account_id from iem_migration_store_temp
		where migration_id=p_migration_id and substr(folder_name,1,1)<>'I';
begin
select email_account_id,folder_name,folder_type,agent_Account_id,total_msg_count into
l_email_account_id,l_folder_name,l_folder_type,l_agent_account_id,l_total_msg_count
from iem_migration_details
where migration_id=p_migration_id;
if l_folder_type='Q' THEN
BEGIN
		select a.db_link into l_dblink
         from iem_db_connections a, iem_email_accounts b
         where a.db_server_id=b.db_Server_id
           and b.email_account_id = l_email_account_id and a.is_admin='A';
		 -- Check normal processing or error Processing
		select count(*) into l_qcount from iem_migration_store_temp
		where migration_id=p_migration_id;
	 IF l_qcount>0 then  -- Error Processing
			delete from iem_migration_store_temp
			where migration_id=p_migration_id and mig_status=null;
	  end if;
		for v1 in c_queue LOOP
			l_mig_Rec:=null;
			l_mig_Rec.msg_uid:=v1.message_uid;
			l_mig_rec.RFC822_MESSAGE_ID:=v1.rfc822_message_id;
			l_mig_status:='R';
    		BEGIN
		l_source_message_id:=v1.source_message_id;
         execute immediate 'select reply_to, cc_str, bcc_str from '
           ||'OM_HEADER@'||l_dblink||' where msg_id = :b1'
		into l_mig_rec.reply_to_str,l_mig_rec.cc_str, l_mig_rec.bcc_str using l_source_message_id;
		EXCEPTION when others then
		 l_mig_status:='E';
		 l_error_text:='Error in Retrieving Data from OES';
		END;
			l_mig_rec.sent_date:=v1.sent_date;
			l_mig_rec.subject:=v1.subject;
			l_mig_rec.message_id:=v1.message_id;
			l_mig_rec.ih_media_item_id:=v1.ih_media_item_id;
			l_mig_rec.to_str:=v1.to_address;
			l_mig_rec.from_str:=v1.sender_name;
			l_mig_rec.message_size:=v1.message_size;

		-- Create Record into Worklist Queue.
		select IEM_MIGRATION_STORE_TEMP_s1.nextval into l_mig_rec.mail_id from dual;
	insert into iem_migration_store_temp
	(MAIL_ID,
 	MESSAGE_ID ,
	MIGRATION_ID,
 	MESSAGE_TYPE ,
 	EMAIL_ACCOUNT_ID ,
     AGENT_ACCOUNT_ID  ,
 	RESOURCE_ID       ,
 	FOLDER_NAME       ,
 	RT_MEDIA_ITEM_ID  ,
 	MSG_UID          ,
 	RFC822_MESSAGE_ID ,
 	FROM_STR       ,
 	TO_STR          ,
 	REPLY_TO_STR   ,
 	CC_STR         ,
 	BCC_STR          ,
 	SENT_DATE        ,
 	SUBJECT          ,
 	IH_MEDIA_ITEM_ID ,
 	MESSAGE_SIZE     ,
 	DP_STATUS        ,
 	MIG_STATUS       ,
 	ERROR_TEXT,
	CREATED_BY          ,
	CREATION_DATE       ,
	LAST_UPDATED_BY     ,
	LAST_UPDATE_DATE    ,
	LAST_UPDATE_LOGIN   )

 VALUES
 	(l_mig_rec.mail_id,
 	l_mig_rec.message_id,
	p_migration_id,
	l_folder_type,
 	l_email_account_id,
 	l_mig_rec.agent_account_id,
 	l_mig_rec.resource_id,
	l_folder_name,
	null,
 	l_mig_rec.msg_uid,
 	l_mig_rec.RFC822_MESSAGE_ID,
 	l_mig_rec.from_Str,
 	l_mig_rec.to_str,
 	l_mig_rec.reply_to_str,
 	l_mig_rec.cc_str,
 	l_mig_rec.bcc_Str,
 	l_mig_rec.sent_Date,
	l_mig_rec.subject,
	l_mig_rec.ih_media_item_id,
	l_mig_rec.MESSAGE_SIZE,
	null,
     l_mig_status,
	l_error_text,
	l_created_by,
	sysdate,
	l_last_updated_by,
	sysdate,
	l_last_update_login);
	END LOOP;
	select count(*) into l_rec_counter from iem_migration_Store_temp
	where migration_id=p_migration_id ;
		update iem_migration_details
		set MSG_RECORD_COUNT=l_rec_counter
		where migration_id=p_migration_id;
	EXCEPTION WHEN OTHERS THEN
		raise INQ_EXCEPTION;
	END;
		update iem_migration_details
		set folder_status='R',
		status='S'
		where migration_id=p_migration_id;
 elsif l_folder_type in ('I','D') THEN
 	l_inb_migration_id:=p_migration_id;
 	l_outb_migration_id:=null;
	l_type:='I';
 	if l_folder_type='D' then
		select migration_id into l_inb_migration_id from iem_migration_details
		where email_account_id=l_email_Account_id and agent_account_id=l_agent_account_id
		and folder_name='Inbox';
		l_outb_migration_id:=p_migration_id;
		l_type:='O';
	end if;
	-- Also check is this first run or retry run
	select count(*) into l_ag_count from iem_migration_store_temp where migration_id=p_migration_id;
	if l_ag_count>0 then
		l_rerun:='Y';
	else
		l_rerun:='N';
	end if;

 	-- Call Message Inbox api from Ting
	iem_mginbox_pub.RUNINBOX(
	P_API_VERSION_NUMBER=>1.0,
	P_INIT_MSG_LIST=>'F',
	P_COMMIT=>'T',
	P_EMAIL_ACCOUNT_ID=>l_email_account_id,
	P_AGENT_ACCOUNT_ID=>l_agent_account_id,
	P_INB_MIGRATION_ID=>l_inb_migration_id,
	P_OUTB_MIGRATION_ID=>l_outb_migration_id,
	p_type=>l_type,
	p_rerun=>l_rerun,
	X_RETURN_STATUS=>l_ret_status,
	x_msg_count=>l_msg_count,
	x_msg_data=>l_msg_data);
	if l_ret_Status='S' then
	-- Fixed Data discrepancy
	if l_folder_type='I' and l_rerun='N' then -- fixed discrepancy for first time
		select count(*) into l_disc_count from iem_migration_Store_temp
		where migration_id=p_migration_id and substr(folder_name,1,1) not in ('I');
		IF l_disc_count >0 then		-- There are discrepancy
			for v1 in c_discp LOOP
			select migration_id into l_mig_id from iem_migration_details
			where email_account_id=v1.email_account_id and folder_name=v1.folder_name;
			update iem_migration_store_temp
			set message_type='Q',
			migration_id=l_mig_id
			where mail_id=v1.mail_id;
			-- Update Count of Migration after pushing these inbox message into Queue Count
			update iem_migration_details
			set total_msg_count=nvl(total_msg_count,0)+1,
			msg_record_count=nvl(msg_record_count,0)+1
			where migration_id=l_mig_id;
			END LOOP;
		END IF;
	end if ;
		select count(*) into l_rec_counter from iem_migration_store_temp
		where migration_id=p_migration_id ;
		-- Find the error message only at the recording phase
		select count(*) into l_error_counter from iem_migration_store_temp
		where migration_id=p_migration_id and mig_status='E' and dp_status is null;
			update iem_migration_details
			set MSG_RECORD_COUNT=l_rec_counter-l_error_counter,
			total_msg_count=l_rec_counter,
			folder_status='R'
			where migration_id=p_migration_id;
	else			-- l_ret_status<>'S' from Inbox creation api
	update iem_migration_details
		set folder_Status='R',
		status='E',
		status_text='Error While Creating Worklist Items'
		where  migration_id=p_migration_id;
	end if;
 elsif l_folder_type in ('H','N') THEN
	select to_date(value,'YYYY/MM/DD HH24:MI:SS') into l_hist_date from
	iem_comp_rt_Stats where  type='HISTORICAL' and param='LASTRUN' ;
		select a.email_user,a.domain,a.email_password,'@'||DB_LINK
		into l_user,l_domain,l_pass,l_dblink
		from iem_email_accounts a,iem_db_connections b
		where a.email_account_id=l_email_account_id
		and a.db_server_id=b.db_server_id
		and b.is_admin='A';
	l_mig_status:=null;
	  l_str:='begin :l_ret:=im_api.authenticate'||l_dblink||'(:a_user,:a_domain,:a_password);end; ';
EXECUTE IMMEDIATE l_str using OUT l_ret,l_user,l_domain,l_pass;
	if l_ret<>0 then
		update iem_migration_details
		set status='E',
		folder_status=null,
		STATUS_TEXT='Unable to Authenticate  USer '||l_user||'  Error Code '||l_ret
		where migration_id=p_migration_id;
		x_Status:='E';
		raise AUTH_ERROR;
	end if;
	-- Check whether this is processing the Error entry or these are processed for the first time
	select count(*) into l_hist_count from iem_migration_store_temp
	where migration_id=p_migration_id;

		l_folder:='/'||l_folder_name;
	IF l_hist_count=0 then		-- Historical Records are created for first time

		l_ret:=iem_im_wrappers_pvt.openfolder(l_folder,l_dblink,l_msg_table);
	if l_ret<>0 then
		update iem_migration_details
		set status='E',
		folder_status=null,
		STATUS_TEXT='Unable to Open Folder'||l_folder||'  Error Code '||l_ret
		where migration_id=p_migration_id;
		x_Status:='E';
		raise OPEN_FOLDER_ERROR;
		if l_folder_type='N' then
			l_mig_status:='R';	-- Default value for Normal Message
		end if;
	end if;
	else
		l_hist_flag:='O';		-- that means running second time for historical folder
		l_msg_table.delete;
		if l_folder_type='H' then
					l_mig_status:=null;	-- Update it to "R" later based on date
			open c_historical;
			fetch c_historical bulk collect into l_msg_table;
			close c_historical;
		else								-- For Admin/Retry Folder
			l_mig_status:='R';	-- This is the default value
			open c_normal;
			fetch c_normal bulk collect into l_msg_Table;
			close c_normal;
		end if;

	end if;
	IF l_msg_table.count>0 THEN
				for i in l_msg_table.first..l_msg_table.last LOOP
					l_mig_Rec:=null;

					/* Retrieve below information for only Historical messages */
				IF l_folder_type='H' then
					BEGIN
						l_source_message_id:=l_msg_table(i);
         					execute immediate 'select subject,sent_date,to_str,from_str,reply_to, cc_str, bcc_str,msg_size from '
           			||'OM_HEADER'||l_dblink||' where msg_id = :b1'
           		into l_mig_rec.subject,l_mig_rec.sent_date,l_mig_rec.to_str,l_mig_Rec.from_str,
				l_mig_rec.reply_to_str, l_mig_rec.cc_str, l_mig_rec.bcc_str,l_mig_rec.message_size using l_source_message_id;
				 	EXCEPTION WHEN OTHERS THEN
						l_error_text:='Oracle Error Occured while selecting Header Information '||sqlerrm;
						l_mig_Status:='E';
					END;

					-- Retrieve RFC822_MESSAGE_ID
					BEGIN
					l_source_message_id:=l_msg_table(i);
					-- modified the query to make it case insensitive Ranjan 07/16/2008
					execute immediate ' select value from om_ext_header'||l_dblink||' where msg_id =:b1 '||' AND upper(prompt)=''MESSAGE-ID:'' AND eh_type IN (80, 0)' into l_mig_rec.rfc822_message_id using l_source_message_id;
				 	EXCEPTION WHEN OTHERS THEN
						l_error_text:='Oracle Error Occured while selecting Extended Header Information '||sqlerrm;
						l_mig_Status:='E';
					END;
					BEGIN
					select media_id into l_mig_rec.ih_media_item_id
          			from jtf_ih_media_items
          			where media_item_type = 'EMAIL'
          			AND  media_item_ref=l_mig_rec.rfc822_message_id
          			AND source_id=l_email_account_id;
				 	EXCEPTION WHEN OTHERS THEN
						l_error_text:='Error Encountered while selecting Media Info '||sqlerrm;
						l_mig_Status:='E';
					END;

				END IF;			-- end if for if folder_type='H'

		--			Get MEssage UID for this Folder
					BEGIN
					l_str:='begin :l_ret:=im_api.getmessageprops'||l_dblink||'(:a_message,:a_folder,:a_uid,:a_priority,:a_received_date,:a_expiration,:a_read);end; ';
		execute immediate l_str using out l_ret,l_msg_table(i),l_folder,out l_uid,out x_priority,out l_received_date,out l_expiration,out l_read;
					if l_ret<>0 then
						raise UID_EXCEPTION;
					end if;
		l_mig_rec.msg_uid:=l_uid;
				 	EXCEPTION WHEN UID_EXCEPTION THEN
						l_error_text:='Error Encountered while retrieving Message UID and error code is  '||l_ret;
						l_mig_Status:='E';

						WHEN OTHERS THEN
						l_error_text:='Oracle Error Encountered while retrieving Message UID and error is  '||sqlerrm;
						l_mig_Status:='E';
					END;
					if l_hist_flag='O' then  -- To avoid duplicate
					delete from iem_migration_Store_temp where migration_id=p_migration_id and message_id=l_msg_table(i);
					end if;
		l_mig_Rec.message_id:=l_msg_table(i);
select IEM_MIGRATION_STORE_TEMP_s1.nextval into l_mig_rec.mail_id from dual;
	l_mig_rec.folder_name:=l_folder_name;
	l_mig_rec.message_type:=l_folder_type;
	l_mig_rec.email_account_id:=l_email_account_id;
	l_content:=empty_blob();
	insert into iem_migration_store_temp
	(MAIL_ID,
 	MESSAGE_ID ,
	MIGRATION_ID,
 	MESSAGE_TYPE ,
 	EMAIL_ACCOUNT_ID ,
     AGENT_ACCOUNT_ID  ,
 	RESOURCE_ID       ,
 	FOLDER_NAME       ,
 	RT_MEDIA_ITEM_ID  ,
 	MSG_UID          ,
 	RFC822_MESSAGE_ID ,
 	FROM_STR       ,
 	TO_STR          ,
 	REPLY_TO_STR   ,
 	CC_STR         ,
 	BCC_STR          ,
 	SENT_DATE        ,
 	SUBJECT          ,
 	IH_MEDIA_ITEM_ID ,
 	MESSAGE_SIZE     ,
 	DP_STATUS        ,
 	MIG_STATUS       ,
 	ERROR_TEXT,
	message_content,
	CREATED_BY          ,
	CREATION_DATE       ,
	LAST_UPDATED_BY     ,
	LAST_UPDATE_DATE    ,
	LAST_UPDATE_LOGIN
	)
 VALUES
 	(l_mig_rec.mail_id,
 	l_mig_rec.message_id,
	p_migration_id,
	l_folder_type,
 	l_mig_rec.email_account_id,
 	l_mig_rec.agent_account_id,
 	l_mig_rec.resource_id,
	l_folder_name,
	null,
 	l_mig_rec.msg_uid,
 	l_mig_rec.RFC822_MESSAGE_ID,
 	l_mig_rec.from_Str,
 	l_mig_rec.to_str,
 	l_mig_rec.reply_to_str,
 	l_mig_rec.cc_str,
 	l_mig_rec.bcc_Str,
 	l_mig_rec.sent_Date,
	l_mig_rec.subject,
	l_mig_rec.ih_media_item_id,
	l_mig_rec.MESSAGE_SIZE,
	null,
	l_mig_status,
	l_error_text,
	l_content,
	l_created_by,
	sysdate,
	l_last_updated_by,
	sysdate,
	l_last_update_login);
	end loop;
  END IF;			-- End if for l_msg_tabl.count>0
  	if l_folder_type='H' then
		-- Mark MIG_STAUS to "R" for messages that have sent_date < Historical message Date
		update iem_migration_store_temp
		set mig_status='R'
		where mig_status is null and
		sent_date>=l_hist_date;
	end if;
	select count(*) into l_rec_counter from iem_migration_Store_temp
	where migration_id=p_migration_id and mig_Status is not null;
		-- Find the error message only at the recording phase
		select count(*) into l_error_counter from iem_migration_store_temp
		where migration_id=p_migration_id and mig_status='E' and dp_status is null;
	update iem_migration_details
	set MSG_RECORD_COUNT=l_rec_counter-l_error_counter,
	folder_status='R',
	status='S'
	where migration_id=p_migration_id;
	end if;		-- End if for message type in 'H'/'N'
	x_status:='S';
	commit;
EXCEPTION
	WHEN INQ_EXCEPTION THEN
		rollback;
		l_error_text:='Oracle Error Occured During In queue Processing '||sqlerrm;
	update iem_migration_details
	set status='E',
	folder_Status=null,
	status_text=l_error_text
	where migration_id=p_migration_id;
	commit;

	WHEN AUTH_ERROR THEN
		commit;
	WHEN OPEN_FOLDER_ERROR THEN
		commit;
	WHEN OTHERS THEN
		update iem_migration_details
		set status='E',
		folder_Status=null,
		STATUS_TEXT='Oracle Error occured During Worklist item creation '
		where migration_id=p_migration_id;
		commit;
end create_worklist;


PROCEDURE retry_folders(p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_folders	IN jtf_number_table,
			      x_return_status	OUT	NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY NUMBER,
	  	  	      x_msg_data	OUT NOCOPY	VARCHAR2) IS

	l_folder_status	varchar2(10);
	l_new_Status		varchar2(10);
	l_mig_Status		varchar2(10);
	l_id				number;

 	cursor c1 is select * from iem_migration_store_temp
	where migration_id=l_id and (dp_status='E' or mig_Status='E');
	l_mig_count			number;
	cursor c_account is select email_account_id from iem_mstemail_accounts
	where active_flag in ('Y','N') ;
 begin

 	for i in p_folders.first..p_folders.last LOOP
		select folder_Status into l_folder_status
		from iem_migration_details
		where  migration_id=p_folders(i);
		l_id:=p_folders(i);
	if l_folder_Status in ('R','P') then
		l_new_status:=null;
		l_mig_status:=null;
	elsif l_folder_status in ('D','U') then
		l_new_status:='R';
		l_mig_status:='R';
	elsif l_folder_Status in ('V','M') then
		l_new_status:='D';
		l_mig_status:='D';
	end if;
		update iem_migration_details
		set folder_Status=l_new_status,
		status='S',
		status_text=null
		where migration_id=p_folders(i);
		-- Update Status at message levels
		for v1 in c1 LOOP
		if v1.dp_status='E' then
			update iem_migration_store_temp
			set dp_status=null,
			error_text=null
			where mail_id=v1.mail_id;
		elsif v1.mig_status='E' THEN
			update iem_migration_store_temp
			set mig_status=l_mig_status,
			error_text=null
			where mail_id=v1.mail_id;
		end if;
		END LOOP;
	end loop;
	x_return_status:='S';
			-- Reset account flag to Migrated mode
			for v1 in c_account LOOP
 				select count(*) into l_mig_count from iem_migration_details
 				where email_account_id=v1.email_account_id and nvl(folder_status,' ')<>'M'
				and folder_type<>'H';
 				IF l_mig_count>0 then
 					update iem_mstemail_accounts
					set active_flag='M'
					where email_account_id=v1.email_Account_id;
 				END IF;
 			END LOOP;
	commit;
	EXCEPTION WHEN OTHERS THEN
		 x_return_status:='E';
 end retry_folders;
PROCEDURE retry_messages(p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_messages	IN jtf_number_table,
			      x_return_status	OUT	NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY NUMBER,
	  	  	      x_msg_data	OUT NOCOPY	VARCHAR2) IS
l_mig_status		varchar2(10);
l_mignew_status		varchar2(10);
l_dp_status		varchar2(10);
l_folder_status		varchar2(10);
l_mig_id			number;
l_mig_count			number;
	cursor c_account is select email_account_id from iem_mstemail_accounts
	where active_flag in ('Y','N') ;
begin
		for i in p_messages.first..p_messages.last LOOP
		select migration_id,mig_status,dp_status into l_mig_id,l_mig_status,l_dp_status
		from iem_migration_store_temp
		where mail_id=p_messages(i);
		if l_dp_status='E' THEN
			update iem_migration_store_temp
			set dp_status=null,
			error_text=null
			where mail_id=p_messages(i);
			update iem_migration_details
			set folder_Status=null,
			status=null,
			status_text=null
			where migration_id=l_mig_id;
		elsif l_mig_status='E' THEN
			if l_dp_Status is not null then		-- Post processing DRP
				l_mignew_Status:='R';
				l_folder_status:='D';
			else
				l_mignew_Status:=null;			-- Pre Processing DRP
				l_folder_status:=null;
			end if;

			update iem_migration_store_temp
			set mig_status=l_mignew_status
			where mail_id=p_messages(i);
			update iem_migration_details
			set folder_Status=null,
			status=null,
			status_text=null
			where migration_id=l_mig_id;

		end if;
			end loop;
			-- Reset account flag to Migrated mode
			for v1 in c_account LOOP
 				select count(*) into l_mig_count from iem_migration_details
 				where email_account_id=v1.email_account_id and nvl(folder_status,' ')<>'M'
				and folder_type<>'H';
 				IF l_mig_count>0 then
 					update iem_mstemail_accounts
					set active_flag='M'
					where email_account_id=v1.email_Account_id;
 				END IF;
 			END LOOP;
	x_return_status:='S';
	commit;
end retry_messages;
PROCEDURE StartMigration(ERRBUF   OUT NOCOPY     		VARCHAR2,
                       			RETCODE  OUT NOCOPY     		VARCHAR2,
                       			p_hist_date in 		VARCHAR2,
                      			p_number_of_threads in 		NUMBER) IS
l_stat		varchar2(10);
l_buildstat		varchar2(10);
l_count		number;
l_request_id	number;
l_msg_data	varchar2(200);
l_call_status		boolean;
l_error_message		varchar2(1000);
l_value			varchar2(10);
l_hist_Date		date;
l_mig_count		number;
l_id			number;
l_id1			number;
WORKER_NOT_SUBMITTED	EXCEPTION;
	cursor c_account is select email_account_id from iem_mstemail_accounts
	where active_flag in ('Y','N') ;
begin
	SAVEPOINT start_migration;
	-- Create a record in IEM_COMP_RT_STATS
	select count(*) into l_count from iem_comp_rt_stats
	where type='MIGRATION' and param='STATUS' ;
	if l_count=0 then 									-- First Run
	-- Check Migration Pre requisite Condition like OP queue is null and pre processing Queue is null;
	select count(*) into l_mig_count from iem_pre_mdts;
	if l_mig_count>0 then
		l_error_message:='Please Clean up the Preprocessing Queue Before starting Migration ';
		raise WORKER_NOT_SUBMITTED;
	end if;
	select count(rt_interaction_id) into l_mig_count
	from iem_rt_interactions where expire <> 'N' AND expire <> 'Y';
	if l_mig_count>0 then
		l_error_message:='Please Clean up the Outbox Processing Queue Before starting Migration ';
		raise WORKER_NOT_SUBMITTED;
	end if;

	IEM_COMP_RT_STATS_PVT.create_item(p_api_version_number =>1.0,
                        p_init_msg_list => FND_API.G_FALSE,
                        p_commit         => FND_API.G_FALSE,
                        p_type => 'MIGRATION',
                        p_param => 'STATUS',
                        p_value => 'Y',				-- Start Migration
                        x_return_status  => l_stat,
                        x_msg_count      => l_count,
                        x_msg_data      => l_msg_data
                        );
		if l_stat='S' then
			IEM_COMP_RT_STATS_PVT.create_item(p_api_version_number =>1.0,
                        p_init_msg_list => FND_API.G_FALSE,
                        p_commit         => FND_API.G_FALSE,
                        p_type => 'HISTORICAL',
                        p_param => 'LASTRUN',
                        p_value => p_hist_date,				-- Start Migration
                        x_return_status  => l_stat,
                        x_msg_count      => l_count,
                        x_msg_data      => l_msg_data
                        );
			if l_stat='S' then
			-- Migrate Config Data
				iem_migration_pvt.iem_config(l_stat);
				if l_stat<>'S' then
			 	 l_error_message:='Error While Creating Configuration Data'||sqlerrm;
				 raise WORKER_NOT_SUBMITTED;
				else
				IEM_MIGRATION_PVT.build_migration_queue(l_buildstat); --Build only Once
				end if;
			else
			 	 l_error_message:='Error While Creating Config Historical Date Info in IEM_COMP_RT_STATS';
				 raise WORKER_NOT_SUBMITTED;
			end if;
			if l_buildstat<>'S' then
				raise WORKER_NOT_SUBMITTED;
			else		-- Mark folder as 'Migrated' if there are no messages
				update iem_migration_details
				set folder_Status='M' where total_msg_count=0 and status='S';
				-- Reset MEssage Id Sequence to the highest Post mdts message id
				-- fix by ranjan on 5th nov. use nvl where there is no
			-- 	record in iem_post_mdts.otherwise the loop will be never
			-- 	ending
				select nvl(max(message_id),0) into l_id from iem_post_mdts;
				LOOP
					select iem_ms_base_headers_s1.nextval into l_id1 from dual;
					exit when l_id1>l_id;
				END LOOP;
			end if;
		else
			 l_error_message:='Error While Creating Config Data in IEM_COMP_RT_STATS';
			 raise WORKER_NOT_SUBMITTED;
		end if;
	else
			update iem_comp_rt_Stats
			set value='Y' where  type='MIGRATION' and param='STATUS' ;
			select to_date(value,'YYYY/MM/DD HH24:MI:SS') into l_hist_date from
			iem_comp_rt_Stats where  type='HISTORICAL' and param='LASTRUN' ;
			if l_hist_date>to_date(p_hist_date ,'YYYY/MM/DD HH24:MI:SS') then
				update iem_comp_rt_Stats
				set value=p_hist_date where  type='HISTORICAL' and param='LASTRUN' ;
			end if;
				-- Check if account have folders to migrated
			for v1 in c_account LOOP
 				select count(*) into l_mig_count from iem_migration_details
 				where email_account_id=v1.email_account_id and folder_status<>'M';
 				IF l_mig_count>0 then
 					update iem_mstemail_accounts
					set active_flag='M'
					where email_account_id=v1.email_Account_id;
 				END IF;
 			END LOOP;
	end if;
   FOR i in 1..p_number_of_threads loop
        l_request_id := fnd_request.submit_request('IEM', 'IEMMIGWW', '','',FALSE);
        if l_request_id = 0 then
            rollback;
            raise WORKER_NOT_SUBMITTED;
        end if;
	END LOOP;
	commit;

exception
        WHEN WORKER_NOT_SUBMITTED THEN
        FND_MESSAGE.SET_NAME('IEM','IEM_ADM_WORKER_NOT_SUBMITTED');
        l_Error_Message := nvl(l_error_message,' ')||FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', l_Error_Message);
	   rollback ;

        WHEN OTHERS THEN
	   l_error_message:='Oracle Error occured '||sqlerrm;
        FND_MESSAGE.SET_NAME('IEM','IEM_ADM_WORKER_NOT_SUBMITTED');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', l_Error_Message);
	   rollback ;

 end StartMigration;

PROCEDURE Start_worker(ERRBUF   OUT NOCOPY     		VARCHAR2,
            		   RETCODE  OUT NOCOPY     		VARCHAR2) IS
l_folder_Rec	iem_migration_details%rowtype;
l_count		number;
l_status	    varchar2(10);
l_migration_id		number;
	e_nowait			EXCEPTION;
	cursor c_dp_folder is
	select distinct b.migration_id from iem_migration_store_temp a,iem_migration_details b
	where a.migration_id=b.migration_id and b.folder_Status='M' and a.dp_status=null;

	cursor c_mig_folder is
	select distinct migration_id,folder_Status from iem_migration_Details
	where migration_id in (select a.migration_id from iem_migration_store_temp a,iem_migration_details b
	where a.migration_id=b.migration_id and b.folder_Status='M'  and a.mig_Status in (null,'D'));
	cursor c_account is select email_account_id from iem_mstemail_accounts
	where active_flag='M' ;
	l_mig_count		number;

begin
LOOP				-- Loop For Worker which it will check after it has no folder to process
	select count(*) into l_count from iem_comp_rt_stats
	where type='MIGRATION' and param='STATUS' and value='Y';
	EXIT when l_count=0 ;		-- Exit from Main Worker Loop
	-- Recording Phase  loop. Will go to next loop after it record for all the folders
 LOOP
	select count(*) into l_count from iem_comp_rt_stats
	where type='MIGRATION' and param='STATUS' and value='Y';
	EXIT when l_count=0;		-- Before start processing check migration status
	l_migration_id:=null;
	for x in ( select migration_id
 	from iem_migration_details
	where folder_Status is null
	and total_msg_count>0
 	order by decode(folder_type,'H',1,0))
LOOP
BEGIN
	select * into l_folder_rec from iem_migration_details
	where migration_id=x.migration_id FOR UPDATE NOWAIT;
	l_migration_id:=l_folder_rec.migration_id;
     	exit;
EXCEPTION when e_nowait then
		null;
when others then
		null ;
END;
END LOOP;
 EXIT when l_migration_id is null; 		-- Exit from the Recording Loop
	update iem_migration_details
	set folder_status='P',
	status=null,
	status_Text=null
	where migration_id=l_migration_id;
	commit;
	-- Build WorkList Item For the Folders
	IEM_MIGRATION_PVT.create_worklist(l_migration_id,l_status);
 END LOOP;		-- End Loop for all folders

	-- PostProcessing Phase
 LOOP
 		-- Before start processing check migration status

	select count(*) into l_count from iem_comp_rt_stats
	where type='MIGRATION' and param='STATUS' and value='Y';
   EXIT when l_count=0;
	l_migration_id:=null;
	for x in ( select migration_id
 	from iem_migration_details
	where folder_Status='D'
 	order by decode(folder_type,'H',1,0))
LOOP
BEGIN
	select * into l_folder_rec from iem_migration_details
	where migration_id=x.migration_id FOR UPDATE NOWAIT;
	l_migration_id:=l_folder_rec.migration_id;
     	exit;
EXCEPTION when e_nowait then
		null;
when others then
		null ;
END;
END LOOP;
 EXIT when l_migration_id is null ;		-- Exit from the Postprocessing  Loop
  if l_folder_rec.folder_type in ('N','D') then  --just set the folder to migrated for Normal/Draft message no post processing
	update iem_migration_details
	set folder_status='M'
	where migration_id=l_migration_id;
	update iem_migration_Store_temp
	set mig_status='M'
	where migration_id=l_migration_id
	and dp_status='D';
	commit;
  else
	update iem_migration_details
	set folder_status='V'
	where migration_id=l_migration_id;
	commit;
	-- Build WorkList Item For the Folders
	IEM_MIGRATION_PVT.start_postprocessing(l_migration_id,l_status);
  end if;
 END LOOP;		-- End Loop for all folders
 -- Check for all account to transfer them from Migrate mode to in active mode. WE make account
 --active even if it is doing historical email migration
	for v1 in c_account LOOP
 select count(*) into l_mig_count from iem_migration_details
 where email_account_id=v1.email_account_id and folder_status<>'M'
 and folder_type<>'H';
 IF l_mig_count=0 then
 	update iem_mstemail_accounts
	set active_flag='N'
	where email_account_id=v1.email_Account_id;
	commit;
 END IF;
 END LOOP;
END LOOP;					-- End Loop for worker
end Start_worker;
PROCEDURE StopMigration(ERRBUF   OUT NOCOPY     		VARCHAR2,
                       	RETCODE  OUT NOCOPY     		VARCHAR2) IS
BEGIN
 update iem_comp_rt_Stats
 set value='N' where  type='MIGRATION' and param='STATUS' ;
commit;
END StopMigration;
PROCEDURE iem_logger(l_logmessage in varchar2) IS
begin
	if g_statement_log THEN
			if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
				FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'IEM.PLSQL.IEM_EMAIL_PROC_PVT',l_logmessage);
			end if;
	end if;
	if g_exception_log then
			if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
				FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'IEM.PLSQL.IEM_EMAIL_PROC_PVT',l_logmessage);
			end if;
	 end if;
	 if g_error_log then
			if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
				FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'IEM.PLSQL.IEM_EMAIL_PROC_PVT',l_logmessage);
			end if;
	 end if;
end iem_logger;

PROCEDURE iem_config(x_Status OUT NOCOPY varchar2) IS
l_email_account_id		number;
l_intent_id		number;
l_rule_id		number;
l_max_id			number;
l_val			number;
cursor c_account is select * from iem_email_accounts where email_account_id not in
(select email_account_id from iem_mstemail_accounts);
cursor c_agent is select * from iem_agent_Accounts where agent_account_id not in
(select agent_id from iem_agents);
 cursor c_intent is
 select distinct a.classification_id,a.classification from
 iem_classifications a
 where  a.email_account_id=l_email_account_id;

 cursor c1 is select * from iem_themes where classification_id=l_intent_id
 and score>0;

l_template_profile	number;
l_sender_profile		varchar2(100);
l_in_host			varchar2(256);
l_out_host			varchar2(256);
l_in_port			number;
l_out_port		number;
 l_mod    NUMBER;
 l_CREATED_BY    NUMBER;
 l_LAST_UPDATED_BY    NUMBER ;
 l_LAST_UPDATE_LOGIN    NUMBER;
 l_flag			number;
 l_theme_enabled	varchar2(10);
 l_acct_language		varchar2(10);
 l_intent_dtl_id	number;
l_msg_count		number;
l_ret_status		varchar2(10);
l_msg_data		varchar2(1000);
l_deleted_flag		varchar2(1);
l_dblink			iem_db_connections.db_link%type;
l_weight		number;
l_sc_lang		iem_mstemail_accounts.sc_lang%type;
cursor c_rule is select email_user,domain from iem_email_accounts
where upper(email_user) not in ('ACKNOWLEDGEMENTS');
begin
-- Migrate Email Account Config Data
l_created_by:=nvl(TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),-1);
l_LAST_UPDATED_BY:=nvl(TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),-1);
l_last_update_login:=nvl(TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ ID')),-1);
for v1 in c_account LOOP
	l_email_Account_id:=v1.email_account_id;
	l_acct_language:=v1.acct_language;
	l_template_profile:=to_number(FND_PROFILE.VALUE_SPECIFIC('IEM_TEMPLATE_CATEGORY_ID')) ;
	select to_number(decode(FND_PROFILE.VALUE_SPECIFIC('IEM_ACCOUNT_SENDER_NAME'),'ACCOUNT',0,1)) into
	l_sender_profile from dual;
	select dns_name,port
	into l_in_host,l_in_port
	from iem_email_servers a,iem_email_server_types b
	where a.server_type_id=b.email_server_type_id and
	b.email_server_type='IMAP' and
	a.server_group_id=v1.server_group_id;

	select dns_name,port
	into l_out_host,l_out_port
	from iem_email_servers a,iem_email_server_types b
	where a.server_type_id=b.email_server_type_id and
	b.email_server_type='SMTP' and
	a.server_group_id=v1.server_group_id;
	if l_dblink is null then -- not required to get the dblink repeatedly
	  if upper(v1.email_user) not in ('ACKNOWLEDGEMENTS') then
		select a.db_link into l_dblink
         from iem_db_connections a, iem_email_accounts b
         where a.db_server_id=b.db_Server_id
           and b.email_account_id = l_email_account_id and a.is_admin='A';
       end if;
     end if;
-- get the KEM flag /Intent Enabled etc ...for both 1159 and 11510
	IF v1.intent_enabled='Y' THEN
	BEGIN
		select kem_flag into l_flag from iem_email_Accounts
		where email_account_id=v1.email_Account_id;
		if l_flag is null then
			select decode(v1.acct_language,'GB',1,2) into l_flag from dual;
		end if;

	EXCEPTION WHEN OTHERS THEN
		-- This is 1159 ..
			select decode(v1.acct_language,'GB',1,2) into l_flag from dual;
	END;
	ELSE
			l_flag:=0;
	END IF;
	if l_flag=1 then
		l_theme_enabled:='Y';
	else
	     l_theme_enabled:='N';
	end if;
	if upper(v1.email_user) in ('INTENT','ACKNOWLEDGEMENTS') then
		l_deleted_flag:='Y';
	else
		l_deleted_flag:='N';
	end if;
	begin
	if v1.sc_lang is null then
		l_sc_lang:=FND_PROFILE.VALUE('IEM_SC_DEFAULT_LANG');
	else
		l_sc_lang:=v1.sc_lang;
	end if;
	exception when others then -- just incase the 1159 column is not present.
	l_sc_lang:=FND_PROFILE.VALUE('IEM_SC_DEFAULT_LANG');
	end;
	insert into iem_mstemail_accounts
	(EMAIL_ACCOUNT_ID,
	 EMAIL_ADDRESS ,
	 ACCOUNT_DESC,
	 USER_NAME ,
	 ACTIVE_FLAG ,
	 DELETED_FLAG,
	 TEMPLATE_CATEGORY,
	 SENDER_FLAG,
	 ACCOUNT_LANGUAGE ,
	 REPLY_TO_ADDRESS,
	 RETURN_ADDRESS,
	 FROM_NAME    ,
	 IN_HOST ,
	 OUT_HOST,
	 IN_PORT ,
	 OUT_PORT ,
	 CUSTOM_ENABLED  ,
	 SC_LANG  ,
	 KEM_FLAG  ,
	 ACCOUNT_TYPE,
	 CREATED_BY ,
	 CREATION_DATE  ,
	 LAST_UPDATED_BY  ,
	 LAST_UPDATE_DATE ,
 	LAST_UPDATE_LOGIN )
	VALUES
	(v1.email_Account_id,
	v1.reply_to_Address,
	v1.account_profile,
	v1.email_user,
	'M',
	l_deleted_flag,
	l_template_profile,
	l_sender_profile,
	v1.acct_language,
	v1.reply_to_address,
	v1.reply_to_address,
	v1.from_name,
	l_in_host,
	l_out_host,
	l_in_port,
	l_out_port,
	v1.custom_enabled,
	l_sc_lang,
	l_flag,
	'E',
	l_created_by,
	sysdate,
	l_last_updated_by,
	sysdate,
	l_last_update_login);

	if upper(v1.email_user) in ('INTENT','ACKNOWLEDGEMENTS') then
		update iem_mstemail_accounts
		set deleted_flag='Y'
		where user_name=v1.email_user;
	end if;

-- Encrypt the Password
IEM_MSTEMAIL_ACCOUNTS_PVT.encrypt_password(
        P_Api_Version_Number =>1.0,
        P_Init_Msg_List            =>'F',
        P_Commit                =>'F',
    p_email_account_id    =>v1.email_Account_id,
        p_raw_data          =>v1.email_password,
        x_msg_count     =>l_msg_count,
        x_return_status   =>l_ret_status,
        x_msg_data         =>l_msg_data);
-- Migrating Intent Data
for v2 in c_intent LOOP
	l_intent_id:=v2.classification_id;
insert into iem_intents
(intent_id,
intent,
INTENT_LANG,
THEME_ENABLED,
 CREATED_BY ,
 CREATION_DATE  ,
 LAST_UPDATED_BY  ,
 LAST_UPDATE_DATE ,
 LAST_UPDATE_LOGIN )
VALUES
(v2.classification_id,
v2.classification,
l_acct_language,
l_theme_enabled,
l_created_by,
sysdate,
l_last_updated_by,
sysdate,
l_last_update_login);
	-- Insert into iem_ACCOUNT_INTENTS
	insert into iem_account_intents
	(intent_id,
	email_account_id,
 	CREATED_BY ,
 	CREATION_DATE  ,
 	LAST_UPDATED_BY  ,
 	LAST_UPDATE_DATE ,
 	LAST_UPDATE_LOGIN )
	VALUES
	(v2.classification_id,
	 l_email_account_id,
	l_created_by,
	sysdate,
	l_last_updated_by,
	sysdate,
	l_last_update_login);

	-- Insert into IEM_INTENT_DTLS
	for v3 in c1 LOOP
	select iem_intent_dtls_s1.nextval into l_intent_dtl_id from dual;
	l_mod:=mod(v3.score*100,10);
	if (l_mod=0 or l_mod>=5) then
		l_weight:=ceil(v3.score*10);
	else
		l_weight:=floor(v3.score*10);
	end if;
	insert into iem_intent_dtls
	(INTENT_DTL_ID,
	 INTENT_ID,
	 KEYWORD,
	 WEIGHT,
	 QUERY_RESPONSE,
 	CREATED_BY ,
 	CREATION_DATE  ,
 	LAST_UPDATED_BY  ,
	 LAST_UPDATE_DATE ,
	 LAST_UPDATE_LOGIN )
	 VALUES
	 (l_intent_dtl_id,
	 l_intent_id,
	 v3.theme,
	 l_weight,
	 v3.query_Response,
	 v3.created_by,
	 sysdate,
	 v3.last_updated_by,
	 sysdate,
	 v3.last_update_login);

 END LOOP;		-- End Loop for INTENT DETAILS
END LOOP;			-- End Loop For INTENT
END LOOP;			-- Edn Loop For Account
for v4 in c_agent LOOP
insert into IEM_AGENTS
(AGENT_ID,
email_account_id,
RESOURCE_ID,
signature,
 CREATED_BY ,
 CREATION_DATE  ,
 LAST_UPDATED_BY  ,
 LAST_UPDATE_DATE ,
 LAST_UPDATE_LOGIN )
VALUES
(v4.agent_account_id,
v4.email_Account_id,
v4.resource_id,
v4.signature,
l_created_by,
sysdate,
l_last_updated_by,
sysdate,
l_last_update_login);
END LOOP;
 -- Update Deleted flag of IEM_ROUTE_CLASSFICATIONS

 update iem_route_classifications
 set deleted_flag='N'
 where deleted_flag is null;		-- So that can be re runnable..
 -- Reset the Sequence to have highest email account id id
 select nvl(max(email_account_id),0) into l_max_id from iem_mstemail_accounts;
 LOOP
 select iem_mstemail_accounts_s1.nextval into l_val from dual;
 exit when l_val>l_max_id;
 END LOOP;

 -- Reset the Sequence to have highest agent id

 select nvl(max(agent_id),0) into l_max_id from iem_agents;
 LOOP
 select iem_agents_s1.nextval into l_val from dual;
 exit when l_val>l_max_id;
 END LOOP;

 -- Reset the Sequence to have highest intent id

 select nvl(max(intent_id),0) into l_max_id from iem_intents;
 LOOP
 select iem_intents_s1.nextval into l_val from dual;
 exit when l_val>l_max_id;
 END LOOP;
 -- Deleting OES Rule
 for v1 in c_rule LOOP
 BEGIN
 execute immediate 'select rule_id from ds_account@'||l_dblink||' a,om_server_rules@'||l_dblink||' b,ds_domain@'||l_dblink||' c where a.objectid=b.account_id and a.domainid=c.objectid
 and upper(a.name)=:user1
 and upper(c.qualifiedname)=:name'
 into l_rule_id using upper(v1.email_user),upper(v1.domain);
 execute immediate 'delete from om_Server_rules@'||l_dblink||'  where rule_id=:id' using l_rule_id;
 EXCEPTION when others then
 	null;
 end;
 end loop;
 x_status:='S';
EXCEPTION WHEN OTHERS THEN
	x_status:='E';
end iem_config;
end IEM_MIGRATION_PVT;

/
