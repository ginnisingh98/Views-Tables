--------------------------------------------------------
--  DDL for Package Body IEM_EMAIL_PROC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_EMAIL_PROC_PVT" as
/* $Header: iemmprpb.pls 120.20.12010000.17 2010/01/08 06:36:48 sanjrao ship $ */

G_PKG_NAME CONSTANT varchar2(30) :='IEM_EMAIL_PROC_PVT ';
g_statement_log	boolean;		-- Statement Level Logging
g_exception_log	boolean;		-- Statement Level Logging
g_error_log	boolean;		-- Statement Level Logging
g_contact_id		number;
g_relation_id		number;
g_topscore		number;
g_topclass		varchar2(100);

--siahmed 12.1.3 advanced sr creation
 --global variable  for customer_id
  g_customer_id  NUMBER;
  g_account_type IEM_MSTEMAIL_ACCOUNTS.ACCOUNT_TYPE%TYPE;
  --global variable for contact_party_id and party_type
  g_contact_party_id    NUMBER;
  g_contact_party_type  VARCHAR2(100);
  g_contact_point_id    NUMBER;
  --added for contact_point_type
  g_contact_point_type  VARCHAR2(100);
  g_party_role_code VARCHAR2 (100) := 'CONTACT';
  --this is to hold the party_id value for the hz_party_relationships table
  --and then that value is used in the hz_contact_points.owner_table_id to find
  --the contact_point id
  g_owner_table_id number;
--siahmed 12.1.3 end of advanced sr creation


PROCEDURE PROC_EMAILS(ERRBUF OUT NOCOPY		VARCHAR2,
		   ERRRET OUT NOCOPY		VARCHAR2,
		   p_api_version_number in number:= 1.0,
 		   p_init_msg_list  IN   VARCHAR2 ,
	    	   p_commit	    IN   VARCHAR2 ,
		   p_count		IN NUMBER
			 	) IS
	l_post_rec	iem_rt_preproc_emails%rowtype;
	l_count		number:=1;
	l_index		number:=0;
	l_class		number;
	l_ret_status	varchar2(10);
	l_msg_data	varchar2(300);
	l_msg_count	number;
	l_media_id	number;
	l_group_id	number;
	l_rt_classification_id	number;
	l_stat				varchar2(10);
	l_out_text			varchar2(2000):=' ';
	l_routing_classification	varchar2(300);
	KeyValuePairs iem_route_pub.KeyVals_tbl_type;
	l_api_name	varchar2(100):='PROC_EMAILS';
	l_api_version_number	number:=1.0;
	l_Error_Message           VARCHAR2(2000);
	l_call_status             BOOLEAN;
	l_class_val_tbl		IEM_ROUTE_PUB.keyVals_tbl_type;
	l_param_rec_tbl		IEM_RULES_ENGINE_PUB.parameter_tbl_type;
	l_tag_keyval			IEM_TAGPROCESS_PUB.keyVals_tbl_type;
	l_action				varchar2(50);
	l_counter				number:=1;
	l_uid				number;
 	l_media_lc_rec 		JTF_IH_PUB.media_lc_rec_type;
 	l_milcs_id NUMBER;
 	l_mp_milcs_id NUMBER; 	-- MLCS ID for MAIL PROCESSINGS
	l_message_id		number;
	l_email_rec		iem_rt_preproc_emails%ROWTYPE;
	x_stat		varchar2(10);
	l_status		varchar2(10);
	l_text		varchar2(32767);
	l_cust_stat		varchar2(10);
	l_process			varchar2(10);
	l_from_folder		varchar2(50):='/Inbox';
	l_folder_name		varchar2(100);
	l_f_name			varchar2(100);
	l_proc_stat		varchar2(10);
	l_autoproc_result		varchar2(1);
	l_contact_point_id	number;
	l_emp_flag		varchar2(10):='N';
	STOP_PROCESSING	EXCEPTION;
	ABORT_PROCESSING	EXCEPTION;
	ABORT_MOVE_PROCESSING	EXCEPTION;
	ERR_INSERTING		EXCEPTION;
	l_level			varchar2(20):='STATEMENT';
	l_logmessage		varchar2(2000):=' ';
	l_encrypted_id		varchar2(500);
	l_msgid1			number;
	l_index1			number;
	l_index2			number;
	l_autoack_count	number:=0;
	l_autoack_flag	     varchar2(1):='N';
	e_nowait			EXCEPTION;
	PRAGMA			EXCEPTION_INIT(e_nowait, -54);
	NO_ITEM_FOUND			EXCEPTION;
	NO_RECORD_TO_PROCESS		EXCEPTION;
	STOP_REDIRECT_PROCESSING		EXCEPTION;
	cursor c_class_id is
	select classification_id from iem_email_classifications
	where message_id=l_message_id
	order by score desc;
	l_intent_counter	number;
	l_start_search		number:=0;
	l_ih_subject		varchar2(80);
	l_search			varchar2(100);		-- search pattern in subject
	l_doc_id			number;
	l_sr_id			number;
	l_note_type		varchar2(100);
	l_agentid			number;
	l_ih_id			number;
	l_dflt_agt_id		number;
	l_agt_count		number;
	l_tag_custid		number;		-- Customer Id in Tag
	l_customer_id		number;
	l_enable			varchar2(1);
	l_auto_flag		varchar2(1):='N';
	l_noti_flag		varchar2(1);
	l_auto_value		varchar2(20);
	l_dflt_sender		varchar2(200);
	l_wf_custom_val		varchar2(200);
	l_media_rec	JTF_IH_PUB.media_rec_type;
 	l_interaction_rec        JTF_IH_PUB.interaction_rec_type;
 	l_activity_rec        JTF_IH_PUB.activity_rec_type;
 	l_interaction_id        number;
 	l_activity_id        number;
 	l_param_index        number;
	l_cust_search_id		 number;
	l_status_id		 number;
	l_proc_name		 varchar2(100);
	l_result		 varchar2(100);
	l_run_proc_tbl		IEM_TAGPROCESS_PUB.keyVals_tbl_type;
	l_tbl_counter		number;
	l_redirect_id		varchar2(240);
	l_rt_media_item_id		number;
	l_rt_interaction_id	number;
	l_email_doc_tbl		email_doc_tbl;
	l_resource_id			number;
	l_qual_tbl		 IEM_OUTBOX_PROC_PUB.QualifierRecordList;
	l_outbox_tbl		IEM_OUTBOX_PROC_PUB.keyVals_tbl_type;
	l_auto_reply_flag		varchar2(1):='N';
	l_auto_forward_flag		varchar2(1);
	l_action_id		number;
	l_outbox_item_id		number;
	l_cat_counter		number;
	l_search_type		varchar2(10); -- ALL/MES/KM/CP -- Category Map
	l_cm_cat_id		number;	-- store the category for MES category based mapping
	l_kb_rank		number;
	l_contact_id		number;
	l_party_id		number;
	l_party_type		varchar2(100);
	l_id				number;
   l_category_id     AMV_SEARCH_PVT.amv_number_varray_type:=AMV_SEARCH_PVT.amv_number_varray_type();
   l_repos			varchar2(100);	-- MES/KM search repository
   l_ext_address		varchar2(250);		--external email address  for redirecting
   l_ext_temp_id		number;			-- template id created to be used for redirecting external
   l_ext_subject		varchar2(500);		-- prefix for redirect email subject
	l_outbox_id		number;
	l_sender			varchar2(200);
	l_from1			number;
	l_from2			number;
	l_to_address			varchar2(200);
	l_redirect_flag		varchar2(1):='N';
	l_intent_flg			number(15,0);
	l_rule_id			number;
	l_acct_type		iem_mstemail_accounts.account_type%type;
	--12.1.3 Dev Threading
	l_thread_id		number;
        --siahmed 12.1.3 Advanced SR creation
        l_parser_id            NUMBER;
   cursor c_item is select ib.item_id,ib.item_name,ib.last_update_date
   from   amv_c_chl_item_match cim,jtf_amv_items_vl ib
   where  cim.channel_category_id = l_cm_cat_id
   and   cim.channel_id is null
   and   cim.approval_status_type ='APPROVED'
   and   cim.table_name_code ='ITEM'
   and   cim.available_for_channel_date <= sysdate
   and   cim.item_id = ib.item_id
   and    nvl(ib.effective_start_date, sysdate) <= sysdate + 1
   and   nvl(ib.expiration_date, sysdate) >= sysdate;
   -- Introduce additional key Intent String
   l_top_intent	varchar2(50);
   l_top_score		number;
 cursor c_intent is select a.intent,b.score from
 iem_intents a,iem_email_classifications b
 where b.message_id=l_message_id
 and a.intent_id=b.classification_id;
 l_intent_str			varchar2(700);
 l_header_rec			iem_ms_base_headers%rowtype;
 l_email_user_name		iem_mstemail_accounts.user_name%type;
 l_email_address		iem_mstemail_accounts.user_name%type;
 l_email_domain_name	varchar2(300);
 l_auto_msgstatus		varchar2(10);		-- will store msg status for autoreply/autoxredirect;
l_cust_contact_id number;
 STOP_AUTO_PROCESSING	EXCEPTION;
begin
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
		FND_LOG_REPOSITORY.init(null,null);
		if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
			g_statement_log:=true;
		end if;
		if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
			g_exception_log:=true;
		end if;
		if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
			g_error_log:=true;
		end if;
LOOP
		SAVEPOINT process_emails_pvt;
 BEGIN

 /* Get the message in FIFO order to process from iem_rt_preproc_emails */

	IEM_EMAIL_PROC_PVT.iem_returned_msg_rec(l_post_rec);
	IF l_post_rec.message_id is null then
		raise NO_RECORD_TO_PROCESS ;
	END IF;
	l_message_id:=l_post_rec.message_id;
	select * into l_header_Rec
	from iem_ms_base_headers
	where message_id=l_message_id;
	select user_name,kem_flag,email_address,account_type
	into l_email_user_name,l_intent_flg,l_email_address,l_acct_type
	from iem_mstemail_accounts
	where email_account_id=l_post_rec.email_account_id;
	l_email_domain_name:=substr(l_email_address,instr(l_email_address,'@',1)+1,length(l_email_address));
	--  Do Intent Processing if Enabled for Intent
	IF l_intent_flg>0 THEN			-- intent is enabled for the account
		iem_email_proc_pvt.iem_process_intent(l_post_rec.email_account_id,l_post_rec.message_id,l_ret_status,l_out_text);
		IF l_ret_status<>'S' then
		if g_error_log then
			l_logmessage:='Error During Intent Processing.Not able to Map intent to inbound emails.Continued Processing ';
			iem_logger(l_logmessage);
		end if;
		ELSE
		if g_statement_log then
			l_logmessage:='Success in Intent  Processing  ';
			iem_logger(l_logmessage);
		end if;
		END IF;
	END IF;

/* Find the profile value set for Processing Number of Intents for suggested Documents */

	l_intent_counter:=FND_PROFILE.VALUE_SPECIFIC('IEM_INTENT_RESPONSE_NUM');
	if l_intent_counter is null then
		l_intent_counter:=1;
	end if;
	if g_statement_log then
		l_logmessage:='Start Processing for message ID '||l_post_rec.message_id;
		iem_logger(l_logmessage);
	end if;
	-- resetting the below two value to null to get rid of cache data
	g_contact_id:=null;
	g_relation_id:=null;

 -- Check For TAG DATA in Inbound Emails

	l_tag_keyval.delete;
	IEM_EMAIL_PROC_PVT.IEM_RETURN_ENCRYPTID
	(p_subject=>l_header_rec.subject,
	x_id=>l_encrypted_id,
	x_Status=>l_ret_status);
	if l_ret_status='E' then
		if g_statement_log then
			l_logmessage:='Error While searching for Tag in Subject ';
			iem_logger(l_logmessage);
		end if;
		raise ABORT_PROCESSING;
	else
		if l_encrypted_id is not null then
				l_logmessage:='Found Encrypted Tag '||l_encrypted_id;
		else
				l_logmessage:='Inbound message does not contain any tag';
		end if;

			if g_statement_log then
				iem_logger(l_logmessage);
			end if;
	end if;



-- CALLING  TAGGING API TO RESET THE TAG DATA FOR REROUTED MESSAGE
IF l_post_rec.ih_media_item_id is not null then
	if g_statement_log then
		l_logmessage:='Resetting The Tag For Rerouted/Redirected Message';
		iem_logger(l_logmessage);
	end if;
	IEM_ENCRYPT_TAGS_PVT.RESET_TAG
             (p_api_version_number=>1.0,
              p_message_id=>l_post_rec.message_id,
              x_return_status=>l_ret_status ,
              x_msg_count=>l_msg_count,
              x_msg_data=>l_msg_data);

	IF l_ret_status<>'S' THEN
	if g_error_log then
		l_logmessage:='Error while Resetting Tag For Rerouted Message';
		iem_logger(l_logmessage);
	end if;
		raise abort_processing;
	END IF;
END IF;

-- Calling the Tag Processing Api
	if g_statement_log then
		l_logmessage:='Calling Tag Processing Api ';
		iem_logger(l_logmessage);
	end if;
	IF l_encrypted_id is not null then
			IEM_TAGPROCESS_PUB.GETTAGVALUES
					(p_Api_Version_Number=>1.0,
					 p_encrypted_id =>l_encrypted_id,
        				p_message_id=>l_post_rec.message_id,
        				x_key_value=>l_tag_keyval,
        				x_msg_count=>l_msg_count,
        				x_return_status=>l_ret_status,
        				x_msg_data=>l_msg_data);
			IF l_ret_status<>'S' THEN
			if g_error_log then
				l_logmessage:='Error while Calling Tag Processing Api ';
				iem_logger(l_logmessage);
			end if;
				raise abort_processing;
			END IF;
	END IF;

  -- Retrieving Tag Data if Exists
				l_auto_reply_flag:='N';

	IF l_tag_keyval.count>0 THEN
			for i in l_tag_keyval.FIRST..l_tag_keyval.LAST LOOP
			IF l_tag_keyval(i).key='IEMNBZTSRVSRID' then
				l_sr_id:=to_number(l_tag_keyval(i).value);
			ELSIF l_tag_keyval(i).key='IEMNAGENTID' THEN
				l_agentid:=to_number(l_tag_keyval(i).value);
			ELSIF l_tag_keyval(i).key='IEMNINTERACTIONID' THEN
				l_ih_id:=to_number(l_tag_keyval(i).value);
			ELSIF l_tag_keyval(i).key='IEMNCUSTOMERID' THEN
				l_tag_custid:=to_number(l_tag_keyval(i).value);
			ELSIF l_tag_keyval(i).key='IEMSAUTOREPLY' THEN
				l_auto_reply_flag:='Y';
			ELSIF l_tag_keyval(i).key='IEMSAUTOFORWARD' THEN
				l_auto_forward_flag:='Y';
			ELSIF l_tag_keyval(i).key='IEMNCONTACTID' THEN
				g_contact_id:=to_number(l_tag_keyval(i).value);
			ELSIF l_tag_keyval(i).key='IEMNRELATIONSHIPID' THEN
				g_relation_id:=to_number(l_tag_keyval(i).value);
			--12.1.3 Dev
			ELSIF l_tag_keyval(i).key='IEMNTHREADID' THEN
				l_thread_id:=to_number(l_tag_keyval(i).value);
		     END IF;
			END LOOP;
	END IF;	 -- End Of Retrieving Tag Data if Exists

	--12.1.3 Dev
	IF l_tag_keyval.count = 0 and l_encrypted_id is not null THEN
		select value into l_thread_id
		from IEM_ENCRYPTED_TAG_DTLS
		where key ='IEMNTHREADID' and encrypted_id = substr(l_encrypted_id,1,5);

		select agent_id into l_agentid from
		IEM_ENCRYPTED_TAGS where encrypted_id = substr(l_encrypted_id,1,5);
	END IF;

	IF l_thread_id IS NOT NULL THEN
		insert into IEM_THREAD_DTLS(
		THREAD_ID,
		MESSAGE_ID,
		MESSAGE_TYPE,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN)
		values(l_thread_id, l_post_rec.message_id,'I',l_agentid,sysdate, l_agentid,sysdate,l_agentid);
	END IF;
	--End of 12.1.3 dev changes

	/* If interaction id exists in pre mdt , then the current processing should have that Id as the parent IH Id */
	If l_post_rec.ih_interaction_id is not null then
		l_ih_id:=l_post_rec.ih_interaction_id;
	end if;

-- Getting the customer Id for Interaction creation and passing it to all the rules engine. First we check
-- if the tag contain the customer id or not. If yes we used that first. Otherwise we check whether based
-- on email_address pre-processing able to retrieve a single hit customer id and use that.
-- Retrieve only the Email Address from From String in the BASE HEADER TABLE
	l_from1:=instr(l_header_rec.from_str,'<',1,1);
	l_from2:=instr(l_header_rec.from_str,'>',1,1);
	IF l_from1>0 then		-- From Address Contains Both Name and Address
		l_sender:=substr(l_header_rec.from_Str,l_from1+1,l_from2-l_from1-1);
	ELSE					-- From Address contains only Address
		l_sender:=l_header_rec.from_str;
	END IF;
-- getting contact id for internal employee from the email address of
--the sender
	if l_acct_Type='I' then
 		BEGIN
 				IEM_GETCUST_PVT.GETCUSTOMERID
 				(p_api_version_number=>1.0,
 				p_email=>l_sender,
 				p_party_id=>l_cust_contact_id,
 				X_MSG_COUNT=>l_msg_count,
 				X_RETURN_STATUS=>l_ret_status,
 				X_MSG_DATA=>l_msg_data);
		 EXCEPTION
		 WHEN OTHERS THEN NULL;
		 END;
	if g_statement_log then
	 l_logmessage:='Get the emp contact Id '||l_cust_contact_id ||' For Sender '||l_sender ;
	 iem_logger(l_logmessage);
	end if;
        end if;
		IF l_tag_custid is not null THEN
				l_customer_id:=l_tag_custid;

		ELSE
				-- Get the Customer Id
		-- GETTING CUSTOMER ID BASED ON EMAIL ADDRESS
 		BEGIN
 				IEM_GETCUST_PVT.GETCUSTOMERID
 				(p_api_version_number=>1.0,
 				p_email=>l_sender,
 				p_party_id=>l_customer_id,
 				X_MSG_COUNT=>l_msg_count,
 				X_RETURN_STATUS=>l_ret_status,
 				X_MSG_DATA=>l_msg_data);
		 EXCEPTION
		 WHEN OTHERS THEN NULL;
		 END;
 	 if l_customer_id is null then
		l_customer_id:=-1;
 	 end if;
	if g_statement_log then
	 l_logmessage:='Get the Customer Id '||l_customer_id ||' For Sender '||l_sender ;
	 iem_logger(l_logmessage);
	end if;
		END IF;


		-- CALLING THE CUSTOMISED WORKFLOW
		-- Removed the whole section of calling customized workflow --Ranjan
-- Calling Route Classification
   For v1 in c_intent LOOP
	l_intent_str:=nvl(l_intent_str,' ')||v1.intent;
	if l_top_intent is null then
		l_top_intent:=v1.intent;
		l_top_score:=v1.score;
     end if;
   END LOOP;
-- Populating the Classification Engine input data
	if g_statement_log then
		l_logmessage:='Start Populating Key value pair for Classification and Routing Processing ';
		iem_logger(l_logmessage);
	end if;
		l_counter:=1;
		l_class_val_tbl.delete;
	l_class_val_tbl(l_counter).key:='IEMNMESSAGESIZE';
	l_class_val_tbl(l_counter).value:=l_header_rec.message_size;
	l_class_val_tbl(l_counter).datatype:='N';
		l_counter:=l_counter+1;
	l_class_val_tbl(l_counter).key:='IEMSSENDERNAME';
	l_class_val_tbl(l_counter).value:=l_sender;
	l_class_val_tbl(l_counter).datatype:='S';
		l_counter:=l_counter+1;
	l_class_val_tbl(l_counter).key:='IEMSUSERACCTNAME';
	l_class_val_tbl(l_counter).value:=l_email_user_name;
	l_class_val_tbl(l_counter).datatype:='S';
		l_counter:=l_counter+1;
	l_class_val_tbl(l_counter).key:='IEMSDOMAINNAME';
	l_class_val_tbl(l_counter).value:=l_email_domain_name;
	l_class_val_tbl(l_counter).datatype:='S';
	/* this is missing for the time being
		l_counter:=l_counter+1;
	l_class_val_tbl(l_counter).key:='IEMSPRIORITY';
	l_class_val_tbl(l_counter).value:=l_post_rec.priority;
	l_class_val_tbl(l_counter).datatype:='S';
	*/
		l_counter:=l_counter+1;
	l_class_val_tbl(l_counter).key:='IEMSSUBJECT';
	l_class_val_tbl(l_counter).value:=l_header_rec.subject;
	l_class_val_tbl(l_counter).datatype:='S';
		l_counter:=l_counter+1;
	l_class_val_tbl(l_counter).key:='IEMDRECEIVEDDATE';
	l_class_val_tbl(l_counter).value:=to_char(l_post_rec.received_date,'YYYYMMDD');
	l_class_val_tbl(l_counter).datatype:='D';
		l_counter:=l_counter+1;
	l_class_val_tbl(l_counter).key:='IEMTRECEIVEDTIME';
	l_class_val_tbl(l_counter).value:=to_char(l_post_rec.received_date,'HH24:MI:SS');
	l_class_val_tbl(l_counter).datatype:='T';
		l_counter:=l_counter+1;
	l_class_val_tbl(l_counter).key:='IEMSEMAILINTENT';
	l_class_val_tbl(l_counter).value:=l_top_intent;
	l_class_val_tbl(l_counter).datatype:='S';
		l_counter:=l_counter+1;
	l_class_val_tbl(l_counter).key:='IEMNSCOREPERCENT';
	l_class_val_tbl(l_counter).value:=l_top_score;
	l_class_val_tbl(l_counter).datatype:='N';
		l_counter:=l_counter+1;
	l_class_val_tbl(l_counter).key:='IEMSLANGUAGE';
	l_class_val_tbl(l_counter).value:=l_header_rec.language;
	l_class_val_tbl(l_counter).datatype:='S';
		l_counter:=l_counter+1;
	l_class_val_tbl(l_counter).key:='IEMSORGANIZATION';
	l_class_val_tbl(l_counter).value:=l_header_rec.organization;
	l_class_val_tbl(l_counter).datatype:='S';
		l_counter:=l_counter+1;
	l_class_val_tbl(l_counter).key:='IEMDSYSTEMDATE';
	l_class_val_tbl(l_counter).value:=to_char(sysdate,'YYYYMMDD');
	l_class_val_tbl(l_counter).datatype:='D';
		l_counter:=l_counter+1;
	l_class_val_tbl(l_counter).key:='IEMTSYSTEMTIME';
	l_class_val_tbl(l_counter).value:=to_char(sysdate,'HH24:MI:SS');
	l_class_val_tbl(l_counter).datatype:='T';
		l_counter:=l_counter+1;
	l_class_val_tbl(l_counter).key:='IEMSTOADDRESS';
	l_class_val_tbl(l_counter).value:=l_header_rec.to_str;
	l_class_val_tbl(l_counter).datatype:='S';

-- New KEYVALUE Pair Containing All Intents Changes MAde for MP-R By RT on 08/01/03
		l_counter:=l_counter+1;
	l_class_val_tbl(l_counter).key:='IEMSALLINTENTS';
	l_class_val_tbl(l_counter).value:=l_intent_str;
	l_class_val_tbl(l_counter).datatype:='S';

	IF l_wf_custom_val is not null THEN
		l_counter:=l_counter+1;
	l_class_val_tbl(l_counter).key:='IEMSCUSTOMWFVAL';
	l_class_val_tbl(l_counter).value:=l_wf_custom_val;
	l_class_val_tbl(l_counter).datatype:='S';
	END IF;
	IF l_customer_id is not null THEN
		l_counter:=l_counter+1;
		l_class_val_tbl(l_counter).key:='IEMNCUSTOMERID';
		l_class_val_tbl(l_counter).value:=l_customer_id;
		l_class_val_tbl(l_counter).datatype:='N';
	END IF;

   IF l_tag_keyval.count>0 THEN
	FOR j in l_tag_keyval.FIRST..l_tag_keyval.LAST LOOP
		l_counter:=l_counter+1;
	l_class_val_tbl(l_counter).key:=l_tag_keyval(j).key;
	l_class_val_tbl(l_counter).value:=l_tag_keyval(j).value;
	l_class_val_tbl(l_counter).datatype:=l_tag_keyval(j).datatype;
	END LOOP;
  END IF;
IF l_post_rec.rt_classification_id is null THEN
IEM_EMAIL_PROC_PVT.IEM_CLASSIFICATION_PROC(
				p_email_account_id=>l_post_rec.email_account_id,
				p_keyval=>l_class_val_tbl   ,
			x_rt_classification_id=>l_rt_classification_id,
			x_status=>l_status,
		     x_out_text=>l_out_text) ;
	IF l_status <>'S' THEN
	if g_error_log then
		l_logmessage:=l_out_text;
		iem_logger(l_logmessage);
	end if;
		raise abort_processing;
	END IF;
	if g_statement_log then
		l_logmessage:='classification engine return route classificaion id '||l_rt_classification_id;
		iem_logger(l_logmessage);
	end if;
ELSE
	l_rt_classification_id:=l_post_rec.rt_classification_id;
	if g_statement_log then
		l_logmessage:='Use Old Classification Engine Value'||l_rt_classification_id||'  did not call Classification Processing again';
		iem_logger(l_logmessage);
	end if;
END IF;			-- End of if rt_classification_id is null

 BEGIN
	select name
	into l_folder_name
	from iem_route_classifications
	where route_classification_id=l_rt_classification_id;
 EXCEPTION
	WHEN OTHERS THEN
	if g_exception_log then
		l_logmessage:='Error in getting folder name for the route classificaion id '||l_rt_classification_id||' and the error is '||sqlerrm;
		iem_logger(l_logmessage);
	end if;
	raise ABORT_PROCESSING;
  END;

		l_counter:=l_counter+1;
	l_class_val_tbl(l_counter).key:='IEMSROUTINGCLASSIFICATION';
  l_class_val_tbl(l_counter).value:=l_folder_name;
	l_class_val_tbl(l_counter).datatype:='S';

				-- *** Open an Interaction  *** --

     		l_interaction_rec.start_date_time   := sysdate;
     		l_resource_id:=FND_PROFILE.VALUE_SPECIFIC('IEM_SRVR_ARES') ;
     			l_interaction_rec.resource_id:=l_resource_id ;

			IF l_interaction_rec.resource_id is NULL THEN
				l_logmessage:='Default Resource Id is Not Set For Creating Interaction';
			raise ABORT_PROCESSING;
			END IF;
     		l_interaction_rec.handler_id        := 680; -- IEM APPL_ID
			IF l_ih_id is not null then
     			l_interaction_rec.parent_id  := l_ih_id;
			end if;
		if l_acct_type='I' then -- For internal account type it will come from profile
     		l_customer_id := FND_PROFILE.VALUE_SPECIFIC('CS_SR_DEFAULT_CUSTOMER_NAME');
		end if;
		if l_customer_id >0 then	-- Tag Data or pre processing  contain Customer Id
     		l_interaction_rec.party_id          := l_customer_id;
		else 				-- Pre processing/TAg data  fails to retrun customer id
			IEM_GETCUST_PVT.CustomerSearch(
 						P_Api_Version_Number=>1.0,
 						p_email=>l_sender,
 						x_party_id=>l_cust_search_id,
 						x_msg_count=>l_msg_count,
 						x_return_status=>l_ret_status,
 						x_msg_data=>l_msg_data);
     		l_interaction_rec.party_id          := l_cust_search_id;
		end if;
			IF l_tag_custid>0 THEN
-- Tag DAta return customer contact details. So create the interaction by logging contact,primary party and
-- relation id.
				BEGIN
			 	select PARTY_TYPE into l_party_type from HZ_PARTIES
			   	where party_id = l_tag_custid;
				EXCEPTION WHEN OTHERS THEN
					l_logmessage:='Error in getting Party Type for Party id '||l_tag_custid;
					raise ABORT_PROCESSING;
				END;
				IF l_party_type='PERSON' THEN
					 l_interaction_rec.primary_party_id:=l_tag_custid;
					 l_interaction_rec.contact_party_id:=l_tag_custid;
					 l_interaction_rec.contact_rel_party_id:=null;
  				ELSIF ( l_party_type = 'ORGANIZATION') then
					 l_interaction_rec.primary_party_id:=l_tag_custid;
    					 if ( g_contact_id > 0 ) then
      					if ( (g_relation_id < 0)  OR (g_relation_id is null)) then
					 		l_interaction_rec.contact_party_id:=null;
					 		l_interaction_rec.contact_rel_party_id:=null;
						else
							l_interaction_rec.contact_rel_party_id:=g_relation_id;
							l_interaction_rec.contact_party_id:=g_contact_id;
      					end if;
    					else
					 		l_interaction_rec.contact_party_id:=null;
					 		l_interaction_rec.contact_rel_party_id:=null;
    					end if;
			    ELSE				--- For PARTY_RELATIONSHIP
					 l_interaction_rec.primary_party_id:=null;
					 l_interaction_rec.contact_party_id:=null;
					 l_interaction_rec.contact_rel_party_id:=null;
			END IF;
           END IF;			-- end if for if l_tag_custid>0

	-- if account type is internal use employee party id as contact id for
        --creating interaction
	--checking for l_cust_contact_id for bug 8337656, Sanjana Rao
				if l_acct_type='I' then
				    if l_cust_contact_id > 0 then
					 l_interaction_rec.contact_party_id:=l_cust_contact_id;
                                    end if;
					 l_interaction_rec.primary_party_id:=l_customer_id;
					 -- Ranjan for bug 7018980 so that outbound interaction
					-- has employee id as contact id;
					 g_contact_id:=l_cust_contact_id;
				end if;
IF l_post_rec.ih_interaction_id is not null and l_post_rec.msg_status='REDIRECT' THEN --chk auto redirected
	l_interaction_id:=l_post_rec.ih_interaction_id;
	if g_statement_log then
		l_logmessage:='New Interaction is not created and use old one for Redirect message  ';
		iem_logger(l_logmessage);
	end if;
ELSE
			IEM_EMAIL_PROC_PVT.IEM_PROC_IH(
				p_type=>'INTERACTION'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
				p_action=>'ADD'		,		-- ADD/UPDATE/CLOSE
				p_interaction_rec=>l_interaction_rec,
				p_activity_rec=>l_activity_rec     ,
				p_media_lc_rec=>l_media_lc_Rec ,
				p_media_rec=>l_media_rec	,
				x_id=>l_interaction_id,
				x_status=>l_stat		,
			     x_out_text=>l_out_text	);
				select contact_party_id into l_cust_contact_id from jtf_ih_interactions
				where interaction_id=l_interaction_id;
		IF l_stat<>'S' THEN
				l_logmessage:=l_out_text;
				raise ABORT_PROCESSING;
			END IF;
END IF;		-- End of chk auto redirected
		-- Add Interaction ID as key value Pair
		l_counter:=l_counter+1;
		l_class_val_tbl(l_counter).key:='IEMNINTERACTIONID';
		l_class_val_tbl(l_counter).value:=l_interaction_id;
		l_class_val_tbl(l_counter).datatype:='N';
l_routing_classification:=l_folder_name;
IF lengthb(l_header_rec.subject)>80 then
     l_ih_subject:=substrb(l_header_rec.subject,1,80);
ELSE
     l_ih_subject:=l_header_rec.subject;
END IF;
IF l_post_rec.ih_media_item_id is null THEN		-- Normal Mail Proc create media
    l_media_rec.media_id := NULL;
    l_media_rec.source_id := l_post_rec.email_account_id;
	l_media_rec.direction:= 'INBOUND';
    l_media_rec.start_date_time := sysdate;
    l_media_rec.media_item_type := 'EMAIL';
    l_media_rec.media_item_ref := l_post_rec.message_id;  -- Change for 11iX
    l_media_rec.media_data := l_ih_subject;
    l_media_rec.classification := l_routing_classification;
    l_media_rec.address := l_sender; --new on MP-R 07/23/03 by rtripath
IEM_EMAIL_PROC_PVT.IEM_PROC_IH(
				p_type=>'MEDIA'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
				p_action=>'ADD'		,		-- ADD/UPDATE/CLOSE
				p_interaction_rec=>l_interaction_rec,
				p_activity_rec=>l_activity_rec     ,
				p_media_lc_rec=>l_media_lc_Rec ,
				p_media_rec=>l_media_rec	,
				x_id=>l_media_id,
				x_status=>l_stat		,
			     x_out_text=>l_out_text	);
			IF l_stat<>'S' THEN
				l_logmessage:=l_out_text;
				raise ABORT_PROCESSING;
			END IF;
ELSE									-- Rerouted Message Need to update the media item
	l_media_rec.media_id:=l_post_rec.ih_media_item_id;
     l_media_rec.source_id := l_post_rec.email_account_id;
     l_media_rec.classification := l_routing_classification;
     l_media_rec.address := l_sender; --new on MP-R 07/23/03 by rtripath

			IEM_EMAIL_PROC_PVT.IEM_PROC_IH(
				p_type=>'MEDIA'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
				p_action=>'UPDATE'		,		-- ADD/UPDATE/CLOSE
				p_interaction_rec=>l_interaction_rec,
				p_activity_rec=>l_activity_rec     ,
				p_media_lc_rec=>l_media_lc_Rec ,
				p_media_rec=>l_media_rec	,
				x_id=>l_media_id,
				x_status=>l_stat		,
			     x_out_text=>l_out_text	);
			IF l_stat<>'S' THEN
				l_logmessage:=l_out_text;
				raise ABORT_PROCESSING;
			END IF;
			l_media_id:=l_post_rec.ih_media_item_id;
END IF;
		-- Add Media Id to the key value Pair
		l_counter:=l_counter+1;
		l_class_val_tbl(l_counter).key:='IEMNMEDIAID';
		l_class_val_tbl(l_counter).value:=l_media_id;
		l_class_val_tbl(l_counter).datatype:='N';

		-- Take out SOURCEMESSAGEID in 11iX as an input to Rules/ClassificationEngine

		l_counter:=l_counter+1;
		l_class_val_tbl(l_counter).key:='IEMNMESSAGEID';
		l_class_val_tbl(l_counter).value:=l_post_rec.message_id;
		l_class_val_tbl(l_counter).datatype:='N';

	-- Create a Media Life Cycle for Mail Preprocessing

  l_media_lc_rec.media_id :=l_media_id ;
  l_media_lc_rec.milcs_type_id := 16; --MAIL_PREPROCESSING
  IF l_post_rec.ih_media_item_id is null THEN -- normal message
  	l_media_lc_rec.start_date_time := l_post_rec.received_date;
  else
	l_media_lc_rec.start_date_time :=sysdate;		-- for reroute/redirected message
  end if;
  l_media_lc_rec.handler_id := 680;
  l_media_lc_rec.type_type := 'Email, Inbound';

IEM_EMAIL_PROC_PVT.IEM_PROC_IH(
				p_type=>'MLCS'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
				p_action=>'ADD'		,		-- ADD/UPDATE/CLOSE
				p_interaction_rec=>l_interaction_rec,
				p_activity_rec=>l_activity_rec     ,
				p_media_lc_rec=>l_media_lc_Rec ,
				p_media_rec=>l_media_rec	,
				x_id=>l_milcs_id,
				x_status=>l_stat		,
			     x_out_text=>l_out_text	);

			IF l_stat<>'S' THEN
				l_logmessage:=l_out_text;
				raise ABORT_PROCESSING;
			END IF;

	-- Update  the Media Life Cycle for Mail Preprocessing
  l_media_lc_rec.milcs_id:=l_milcs_id;

IEM_EMAIL_PROC_PVT.IEM_PROC_IH(
				p_type=>'MLCS'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
				p_action=>'UPDATE'		,		-- ADD/UPDATE/CLOSE
				p_interaction_rec=>l_interaction_rec,
				p_activity_rec=>l_activity_rec     ,
				p_media_lc_rec=>l_media_lc_Rec ,
				p_media_rec=>l_media_rec	,
				x_id=>l_milcs_id,
				x_status=>l_stat		,
			     x_out_text=>l_out_text	);

			IF l_stat<>'S' THEN
				l_logmessage:=l_out_text;
				raise ABORT_PROCESSING;
			END IF;

	-- Create a Media Life Cycle for Mail Processing
  l_media_lc_rec.media_id :=l_media_id ;
  l_media_lc_rec.milcs_type_id := 17; --MAIL_PROCESSING
  l_media_lc_rec.start_date_time := sysdate;
  l_media_lc_rec.handler_id := 680;
  l_media_lc_rec.type_type := 'Email, Inbound';

	IEM_EMAIL_PROC_PVT.IEM_PROC_IH(
				p_type=>'MLCS'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
				p_action=>'ADD'		,		-- ADD/UPDATE/CLOSE
				p_interaction_rec=>l_interaction_rec,
				p_activity_rec=>l_activity_rec     ,
				p_media_lc_rec=>l_media_lc_Rec ,
				p_media_rec=>l_media_rec	,
				x_id=>l_mp_milcs_id,
				x_status=>l_stat		,
			     x_out_text=>l_out_text	);
			IF l_stat<>'S' THEN
				l_logmessage:=l_out_text;
				raise ABORT_PROCESSING;
			END IF;
-- this is the new default activity for each mail that undergoes processing. Introduced in 11510.
			-- Add a Activity for EMAILPROCESSING
     				l_activity_rec.start_date_time   := SYSDATE;
	       			l_activity_rec.media_id          := l_media_id;
         				l_activity_rec.action_id         := 95;	-- EMAILPROCESSED
         				l_activity_rec.interaction_id    := l_interaction_id;
         				l_activity_rec.action_item_id    := 45;-- EMAIL

		IEM_EMAIl_PROC_PVT.IEM_PROC_IH(
				p_type=>'ACTIVITY'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
				p_action=>'ADD'		,		-- ADD/UPDATE/CLOSE
				p_interaction_rec=>l_interaction_rec,
				p_activity_rec=>l_activity_rec     ,
				p_media_lc_rec=>l_media_lc_Rec ,
				p_media_rec=>l_media_rec	,
				x_id=>l_activity_id,
				x_status=>l_stat		,
			     x_out_text=>l_out_text	);

			IF l_stat<>'S' THEN
				l_logmessage:=l_out_text;
				raise ABORT_PROCESSING;
			END IF;

-- Calling Auto Processing Engine For 'AUTODELETE'
	iem_rules_engine_pub.auto_process_email(p_api_version_number=>1.0,
									p_commit=>FND_API.G_FALSE,
									p_rule_type=>'AUTODELETE',
									p_keyvals_tbl=>l_class_val_tbl,
									p_accountid=>l_post_rec.email_account_id,
									x_result=>l_autoproc_result,
									x_action=>l_action,
									x_parameters=>l_param_rec_tbl,
									x_return_status=>l_ret_status,
									x_msg_count=>l_msg_count,
									x_msg_data=>l_msg_data);
			IF l_ret_status<>'S' THEN
				l_logmessage:='Error While Calling rules Engine for Autodelete';
				raise ABORT_PROCESSING;
			END IF;
	IF l_autoproc_result='T' THEN		-- Delete the message
	 -- Create a New MLCS for AUTO_DELETE
  		l_media_lc_rec.media_id :=l_media_id ;
  		l_media_lc_rec.milcs_type_id := 42; --EMAIL_AUTO_DELETE
  		l_media_lc_rec.start_date_time := sysdate;
  		l_media_lc_rec.handler_id := 680;
  		l_media_lc_rec.type_type := 'Email, Inbound';

		IEM_EMAIL_PROC_PVT.IEM_PROC_IH(
				p_type=>'MLCS'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
				p_action=>'ADD'		,		-- ADD/UPDATE/CLOSE
				p_interaction_rec=>l_interaction_rec,
				p_activity_rec=>l_activity_rec     ,
				p_media_lc_rec=>l_media_lc_Rec ,
				p_media_rec=>l_media_rec	,
				x_id=>l_milcs_id,
				x_status=>l_stat		,
			     x_out_text=>l_out_text	);
			IF l_stat<>'S' THEN
				l_logmessage:=l_out_text;
				raise ABORT_PROCESSING;
			END IF;
			-- Update  the Media Life Cycle for Auto Delete
 			 l_media_lc_rec.milcs_id:=l_milcs_id;

			IEM_EMAIL_PROC_PVT.IEM_PROC_IH(
				p_type=>'MLCS'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
				p_action=>'UPDATE'		,		-- ADD/UPDATE/CLOSE
				p_interaction_rec=>l_interaction_rec,
				p_activity_rec=>l_activity_rec     ,
				p_media_lc_rec=>l_media_lc_Rec ,
				p_media_rec=>l_media_rec	,
				x_id=>l_milcs_id,
				x_status=>l_stat		,
			     x_out_text=>l_out_text	);

			IF l_stat<>'S' THEN
				l_logmessage:=l_out_text;
				raise ABORT_PROCESSING;
			END IF;

			-- Add a Activity for AUTO-DELETE
     				l_activity_rec.start_date_time   := SYSDATE;
	       			l_activity_rec.media_id          := l_media_id;
         				l_activity_rec.action_id         := 72;	-- EMAIL AUTO _DELETED
         				l_activity_rec.interaction_id    := l_interaction_id;
         				l_activity_rec.action_item_id    := 45;-- EMAIL

		IEM_EMAIL_PROC_PVT.IEM_PROC_IH(
				p_type=>'ACTIVITY'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
				p_action=>'ADD'		,		-- ADD/UPDATE/CLOSE
				p_interaction_rec=>l_interaction_rec,
				p_activity_rec=>l_activity_rec     ,
				p_media_lc_rec=>l_media_lc_Rec ,
				p_media_rec=>l_media_rec	,
				x_id=>l_activity_id,
				x_status=>l_stat		,
			     x_out_text=>l_out_text	);

			IF l_stat<>'S' THEN
				l_logmessage:=l_out_text;
				raise ABORT_PROCESSING;
			END IF;
		IEM_RT_PROC_EMAILS_PVT.create_item (
					p_api_version_number => 1.0,
  					p_init_msg_list=>'F' ,
					p_commit=>'F',
				p_message_id =>l_post_rec.message_id,
				p_email_account_id  =>l_post_rec.email_account_id,
				p_priority  =>l_post_rec.priority,
				p_agent_id  =>-1,
				p_group_id  =>-1,
				p_sent_date =>l_header_Rec.sent_date,
				p_received_date =>l_post_Rec.received_Date,
				p_rt_classification_id =>l_rt_classification_id,
				p_customer_id=>l_customer_id    ,
				p_contact_id=>g_contact_id    ,
				p_relationship_id=>g_relation_id    ,
				p_interaction_id=>l_interaction_id ,
				p_ih_media_item_id=>l_media_id ,
				p_msg_status=>l_post_rec.msg_status  ,
				p_mail_proc_status=>'D' ,
				p_mail_item_status=>null ,
				p_category_map_id=>null ,
				p_rule_id=>l_rule_id,
				p_subject=>l_header_rec.subject,
				p_sender_address=>l_sender,
				p_from_agent_id=>null,
     			x_return_status=>l_ret_status	,
  				x_msg_count=>l_msg_count	      ,
 				x_msg_data=>l_msg_data);

			IF l_ret_status<>'S' THEN
				l_logmessage:='AUTODELETE:Error While Inserting Record in Proc Emails Table ';
				raise ABORT_PROCESSING;
			END IF;

-- This wrapup procedure will close the interaction and media and Stamp the message as Deleted in Archived Table.
			IEM_EMAIL_PROC_PVT.IEM_WRAPUP(p_interaction_id=>l_interaction_id,
					p_media_id=>l_media_id		,
					p_milcs_id=>l_mp_milcs_id,
					p_action=>'D',
					p_email_rec =>l_post_rec,
					p_action_id=>72,
					x_out_text=>l_out_text,
					x_status=>l_stat );
			IF l_stat<>'S' THEN
				l_logmessage:='Error in Auto Delete '||l_out_text;
				raise ABORT_PROCESSING;
			ELSE						-- success in deleting the message
				raise STOP_PROCESSING;
			END IF;
	END IF;

	-- Calling Rules Engine for autoacknowledge
	IF l_post_rec.ih_media_item_id is not null then	--chk  autoack for rerouted message
		l_autoack_count:=0;
		select count(*) into l_autoack_count
		from jtf_ih_media_item_lc_segs
		where media_id=l_post_rec.ih_media_item_id
		and MILCS_TYPE_ID=29;
	END IF;
	IF l_autoack_count=0 then		--not auto acked yet  for this message
			l_autoack_flag:='N';
		iem_rules_engine_pub.auto_process_email(p_api_version_number=>1.0,
									p_commit=>FND_API.G_FALSE,
									p_rule_type=>'AUTOACKNOWLEDGE',
									p_keyvals_tbl=>l_class_val_tbl,
									p_accountid=>l_post_rec.email_account_id,
									x_result=>l_autoproc_result,
									x_action=>l_action,
									x_parameters=>l_param_rec_tbl,
									x_return_status=>l_ret_status,
									x_msg_count=>l_msg_count,
									x_msg_data=>l_msg_data);
				IF l_ret_status<>'S' THEN
				l_logmessage:='Error While Calling rules Engine for Autoacknowledgement';
					raise ABORT_PROCESSING;
				END IF;
		IF l_autoproc_result='T' THEN
						FOR l_param_index in l_param_rec_tbl.FIRST..l_param_rec_tbl.LAST LOOP
							l_doc_id:=l_param_rec_tbl(l_param_index).parameter2;
							EXIT;
						END LOOP;
			l_autoack_flag:='Y';
		END IF;			-- For Autoack rule processing
	END IF;					-- for if autaock=0
	-- Calling Rules Engine for AutoProcessing
					l_param_rec_tbl.delete;
	iem_rules_engine_pub.auto_process_email(p_api_version_number=>1.0,
									p_commit=>FND_API.G_FALSE,
									p_rule_type=>'AUTOPROCESSING',
									p_keyvals_tbl=>l_class_val_tbl,
									p_accountid=>l_post_rec.email_account_id,
									x_result=>l_autoproc_result,
									x_action=>l_action,
									x_parameters=>l_param_rec_tbl,
									x_return_status=>l_ret_status,
									x_msg_count=>l_msg_count,
									x_msg_data=>l_msg_data);
					IF l_ret_status<>'S' THEN
						l_logmessage:='Error While Calling rules Engine for Autoprocessing';
						raise ABORT_PROCESSING;
					END IF;

			IF l_autoproc_result='T' THEN
				IF l_action='EXECPROCEDURE' THEN
				   IF ((l_post_rec.ih_media_item_id is not null) and
				      (FND_PROFILE.VALUE_SPECIFIC('IEM_RERUN_CUSTOM_PROCEDURE')='N')) THEN
					if g_statement_log then
						l_logmessage:='Not Executing Custom Procedure Again ';
						iem_logger(l_logmessage);
					end if;
				    ELSE

						FOR l_param_index in l_param_rec_tbl.FIRST..l_param_rec_tbl.LAST LOOP
							l_proc_name:=l_param_rec_tbl(l_param_index).parameter1;
							EXIT;
						END LOOP;
					IF l_proc_name is not null THEN
							l_run_proc_tbl.delete;
							l_tbl_counter:=1;
							FOR i in l_class_val_tbl.first..l_class_val_tbl.last LOOP
								l_run_proc_tbl(l_tbl_counter).key:=l_class_val_tbl(i).key;
								l_run_proc_tbl(l_tbl_counter).value:=l_class_val_tbl(i).value;
								l_run_proc_tbl(l_tbl_counter).datatype:=l_class_val_tbl(i).datatype;
								l_tbl_counter:=l_tbl_counter+1;
							END LOOP;
						IEM_TAG_RUN_PROC_PVT.run_Procedure (
                						 p_api_version_number=>1.0  ,
            							 p_procedure_name=>l_proc_name      ,
  									 p_key_value =>l_run_proc_tbl,
                 						x_result=>l_result              ,
               						x_return_status=>l_ret_status	   ,
  		  	    						x_msg_count=>l_msg_count,
	  	  	     					x_msg_data=>l_msg_data);
			          	IF l_ret_status='E' THEN
				     		l_logmessage:='Error While Executing  Custom Procedure';
				     		raise ABORT_PROCESSING;
				     	ELSE
				     		IF l_result='N' THEN
     					l_activity_rec.start_date_time   := SYSDATE;
	       				l_activity_rec.media_id          := l_media_id;
         					l_activity_rec.action_id         := 65;	-- EMAIL Resolved No Reply
         					l_activity_rec.interaction_id    := l_interaction_id;
         					l_activity_rec.action_item_id    := 45;-- EMAIL

						IEM_EMAIL_PROC_PVT.IEM_PROC_IH(
								p_type=>'ACTIVITY'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
								p_action=>'ADD'		,		-- ADD/UPDATE/CLOSE
								p_interaction_rec=>l_interaction_rec,
								p_activity_rec=>l_activity_rec     ,
								p_media_lc_rec=>l_media_lc_Rec ,
								p_media_rec=>l_media_rec	,
								x_id=>l_activity_id,
								x_status=>l_stat		,
			     				x_out_text=>l_out_text	);

							IF l_stat<>'S' THEN
								l_logmessage:=l_out_text;
								raise ABORT_PROCESSING;
							END IF;
  							l_media_lc_rec.media_id :=l_media_id ;
  							l_media_lc_rec.milcs_type_id := 31; --EMAIL_AUTO_RESOLVED
  							l_media_lc_rec.start_date_time := sysdate;
  							l_media_lc_rec.handler_id := 680;
  							l_media_lc_rec.type_type := 'Email, Inbound';

							IEM_EMAIL_PROC_PVT.IEM_PROC_IH(
									p_type=>'MLCS'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
									p_action=>'ADD'		,		-- ADD/UPDATE/CLOSE
									p_interaction_rec=>l_interaction_rec,
									p_activity_rec=>l_activity_rec     ,
									p_media_lc_rec=>l_media_lc_Rec ,
									p_media_rec=>l_media_rec	,
									x_id=>l_milcs_id,
									x_status=>l_stat		,
			     					x_out_text=>l_out_text	);
								IF l_stat<>'S' THEN
									l_logmessage:=l_out_text;
									raise ABORT_PROCESSING;
								END IF;
			-- Update  the Media Life Cycle for Auto Resolve
 			 l_media_lc_rec.milcs_id:=l_milcs_id;

							IEM_EMAIL_PROC_PVT.IEM_PROC_IH(
								p_type=>'MLCS'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
								p_action=>'UPDATE'		,		-- ADD/UPDATE/CLOSE
								p_interaction_rec=>l_interaction_rec,
								p_activity_rec=>l_activity_rec     ,
								p_media_lc_rec=>l_media_lc_Rec ,
								p_media_rec=>l_media_rec	,
								x_id=>l_milcs_id,
								x_status=>l_stat		,
			     				x_out_text=>l_out_text	);

							IF l_stat<>'S' THEN
								l_logmessage:=l_out_text;
								raise ABORT_PROCESSING;
							END IF;
		-- Create a Record in IEM_RT_PROC_EMAILS
		IEM_RT_PROC_EMAILS_PVT.create_item (
					p_api_version_number => 1.0,
  					p_init_msg_list=>'F' ,
					p_commit=>'F',
				p_message_id =>l_post_rec.message_id,
				p_email_account_id  =>l_post_rec.email_account_id,
				p_priority  =>l_post_rec.priority,
				p_agent_id  =>-1,
				p_group_id  =>-1,
				p_sent_date =>l_header_Rec.sent_date,
				p_received_date =>l_post_Rec.received_Date,
				p_rt_classification_id =>l_rt_classification_id,
				p_customer_id=>l_customer_id    ,
				p_contact_id=>g_contact_id    ,
				p_relationship_id=>g_relation_id    ,
				p_interaction_id=>l_interaction_id ,
				p_ih_media_item_id=>l_media_id ,
				p_msg_status=>l_post_rec.msg_status  ,
				p_mail_proc_status=>'R' ,
				p_mail_item_status=>null ,
				p_category_map_id=>null ,
				p_rule_id=>l_rule_id,
				p_subject=>l_header_rec.subject,
				p_sender_address=>l_sender,
				p_from_agent_id=>null,
     			x_return_status=>l_ret_status	,
  				x_msg_count=>l_msg_count	      ,
 				x_msg_data=>l_msg_data);
			IF l_ret_status<>'S' THEN
				l_logmessage:='EXECPROC:Error While Inserting Record in Proc Emails Table ';
				raise ABORT_PROCESSING;
			END IF;
						IEM_EMAIL_PROC_PVT.IEM_WRAPUP(p_interaction_id=>l_interaction_id,
								p_media_id=>l_media_id		,
								p_milcs_id=>l_mp_milcs_id,
								p_action=>'R',
								p_email_rec =>l_post_rec,
								p_action_id=>65,
								x_out_text=>l_out_text,
								x_status=>l_stat );

			          			IF l_stat='E' THEN
				    					l_logmessage:=l_out_text;
				     				raise ABORT_PROCESSING;
					   		     END IF;
				     	     	raise STOP_PROCESSING;
				     		END IF;
					     END IF;
					 END IF;
					END IF;  -- end if for if media id is not null
				ELSIF l_action in ('AUTOCREATESR','UPDSERVICEREQID') then
                                  l_logmessage := 'AUTOCREATESR section';
                                  iem_logger(l_logmessage);
                                 --dbms_output.put_line(l_logmessage);
			 -- Populate l_email_doc_tbl for both autocreate and autoupdate SR
					FOR l_param_index in l_param_rec_tbl.FIRST..l_param_rec_tbl.LAST LOOP
					l_status_id:=to_number(l_param_rec_tbl(l_param_index).parameter1);
					l_email_doc_tbl(l_param_index).doc_id:=l_param_rec_tbl(l_param_index).parameter2;
                                          -- siahmed 12.1.3
                                          --this has been added in iemprulb.pls in procedure auto_process_email
					 l_parser_id:=to_number(l_param_rec_tbl(l_param_index).parameter3);

                                              l_logmessage := 'status id is: ' || l_status_id ||'parser id is ' || l_parser_id ;
                                              iem_logger(l_logmessage);
                                              --dbms_output.put_line(l_logmessage);
					l_email_doc_tbl(l_param_index).type:='I';
							EXIT;
					END LOOP;
				l_qual_tbl.delete;
 		IEM_EMAIL_PROC_PVT.IEM_GET_MERGEVAL(p_email_account_id=>l_post_rec.email_account_id ,
							p_mailer =>l_header_rec.from_str,
				    p_dflt_sender=>l_sender	,
				    p_subject=>l_header_rec.subject,
				    x_qual_tbl=> l_qual_tbl,
				    x_status=>l_status,
				    x_out_text=>l_out_Text);
				 IF l_action='AUTOCREATESR' THEN
                                    l_logmessage := 'Entering into AUTOCREATESR section';
                                    iem_logger(l_logmessage);
                                    --dbms_output.put_line(l_logmessage);
						-- Retrieve Party Id
						if l_acct_type='I' then -- select the party id from profile
							l_emp_flag:='Y';
						BEGIN
						 Select person_id into l_contact_id
						 from per_workforce_current_x
						 Where upper(email_address)=upper(l_sender);
						 exception when others then
						 	l_contact_id:=null;
						END;
							l_party_id:=FND_PROFILE.VALUE_SPECIFIC('CS_SR_DEFAULT_CUSTOMER_NAME');
						else		-- External Account
							l_emp_flag:='N';
							if l_customer_id>0 then
								-- Check to see if party identified is a contact or not
								select party_type into l_party_type from  hz_parties
								where party_id=l_customer_id;
								if l_party_type='PARTY_RELATIONSHIP' then
									-- Try to identify the actual party here
								begin
								select object_id into l_party_id
								from HZ_RELATIONSHIPS where party_id= l_customer_id and
								(relationship_code='CONTACT_OF' or relationship_code='EMPLOYEE_OF')
								and status='A';
								l_contact_id:=l_customer_id;
								select contact_point_id  into l_contact_point_id
    								from hz_contact_points
    								where owner_table_name='HZ_PARTIES'
								and owner_table_id=l_customer_id
								and contact_point_type='EMAIL'
								and upper(email_address)=upper(l_sender)
    								and contact_point_id not in  (select contact_level_table_id from HZ_CONTACT_PREFERENCES
    								where contact_level_table='HZ_CONTACT_POINTS' and status='A');
								exception when others then
									l_party_id:=null;
								end;
								else
								l_party_id:=l_customer_id;		-- Exact match
								l_Contact_id:=g_contact_id;
								end if;
							elsif l_customer_id=-1 then	-- No customer match check profile
													-- for what to do next
								if fnd_profile.value_specific('IEM_SR_NO_CUST')='CREATESR' then
									l_party_id:=fnd_profile.value_specific('IEM_DEFAULT_CUSTOMER_ID');
							     else
									l_party_id:=null;
								end if;
							else					-- Multiple Customer Match.
								l_party_id:=null;
							end if;

						end if;
					   	  l_logmessage:= 'if party id is null no sr creation- l_party_id:'|| l_party_id;
                                                  iem_logger(l_logmessage);
        				          --dbms_output.put_line (l_logmessage);
                                        --added the OR with parser id becasue just incase l_party_id returns no rowns or null
                                        --but there is a parser_id there is a possibility that the user trying to create an SR via advanced email SR.

					IF ((l_party_id is not null) OR (l_parser_id IS NOT NULL)) then 	-- Go ahead with creating service request
							-- Retrieve the note  for the email
							iem_text_pvt.RETRIEVE_TEXT(p_message_id=>l_message_id,
				    							x_text=>l_text,
			         							x_status=>l_status);
							if l_status<>'S' then
								l_logmessage:='Error Encountered while Retrieving Notes';
                                                                iem_logger(l_logmessage);
								raise ABORT_PROCESSING;
							end if;
							l_note_type:=FND_PROFILE.VALUE_SPECIFIC('IEM_SR_NOTE_TYPE');

							--siahmed 12.1.3 project  Advanced SR creation
                                             		-- if l_parser_id is not null then call advanced SR creation procedure
							--if it fails then run the normal sr creation
					   	  l_logmessage:= 'before sdvanced sr processing';
                                                  iem_logger(l_logmessage);
        				          --dbms_output.put_line (l_logmessage);
                                                IF (l_parser_id IS NOT NULL) THEN
					   	  l_logmessage:=  'started sdvanced sr processing';
                                                  iem_logger(l_logmessage);
        				          --dbms_output.put_line (l_logmessage);
                                                    advanced_sr_processing (
						                p_message_id           =>  l_message_id,
                  						p_parser_id            =>  l_parser_id,
                  						p_account_type         =>  l_acct_type,
                  						p_default_type_id      =>  l_status_id,
                  						p_default_customer_id  =>  l_party_id,
                  						p_init_msg_list	       =>  FND_API.G_TRUE,
                  						p_commit	       =>  FND_API.G_FALSE,
                  						p_note		       =>  l_text,
                  						p_subject              =>  l_header_rec.subject,
                  						p_note_type            =>  l_note_type,
                  						p_contact_id           =>  l_contact_id,
                  						p_contact_point_id     =>  l_contact_point_id,
                  						x_return_status	       =>  l_ret_status,
                  						x_msg_count	       =>  l_msg_count,
                  						x_msg_data	       =>  l_msg_data,
                  						x_request_id           =>  l_sr_id);
					   	              l_logmessage:= 'Advanced sr creation status is:'||l_ret_status || 'sr_id is:'||l_sr_id;
                                                              iem_logger(l_logmessage);
        				                      --dbms_output.put_line (l_logmessage);
							 --if sr creation fails normally then try the old mehtod
                                                         --also make sure there is l_party_id that is being passed
							 if ((l_ret_status <>'S') AND (l_party_id IS NOT NULL)) THEN
					   	              l_logmessage:= 'advanced sr fail resort to normal processing';
                                                              iem_logger(l_logmessage);
        				                      --dbms_output.put_line (l_logmessage);
							        IEM_SERVICEREQUEST_PVT.IEM_CREATE_SR(
                  							p_api_version           => 1.0,
                  							p_init_msg_list         => FND_API.G_TRUE,
                 							 p_commit	          => FND_API.G_FALSE,
		  							p_message_id   	  => l_message_id,
		  							p_note		  => l_text,
		  							p_party_id              => l_party_id,
		  							p_sr_type_id            => l_status_id,
									p_subject				=>l_header_rec.subject,
									p_employee_flag	=>l_emp_flag,
		  							p_note_type             =>  l_note_type,
		  							p_contact_id            =>  l_contact_id,
									p_contact_point_id		=>l_contact_point_id,
                  						x_return_status         => l_ret_status,
                  						x_msg_count             => l_msg_count,
                  						x_msg_data              => l_msg_data,
		  					  		x_request_id	  => l_sr_id);
					   	           l_logmessage:= 'normal not advaned  sr creation status is:'||l_ret_status || 'sr_id is:'||l_sr_id;
                                                           iem_logger(l_logmessage);
        				                   --dbms_output.put_line (l_logmessage);
							 END IF; --end of old sr creation
 						     -- if there is no parser id then create sr the old way only if party_id exist
         				             ELSIF (l_party_id IS NOT NULL) THEN
					   	          l_logmessage:= 'no advanced sr resort to normal processing';
                                                           iem_logger(l_logmessage);
        				                   --dbms_output.put_line (l_logmessage);
              						  IEM_SERVICEREQUEST_PVT.IEM_CREATE_SR(
                  							p_api_version           => 1.0,
                  							p_init_msg_list         => FND_API.G_TRUE,
                 							 p_commit	          => FND_API.G_FALSE,
		  							p_message_id   	  => l_message_id,
		  							p_note		  => l_text,
		  							p_party_id              => l_party_id,
		  							p_sr_type_id            => l_status_id,
									p_subject				=>l_header_rec.subject,
									p_employee_flag	=>l_emp_flag,
		  							p_note_type             =>  l_note_type,
		  							p_contact_id            =>  l_contact_id,
									p_contact_point_id		=>l_contact_point_id,
                  						x_return_status         => l_ret_status,
                  						x_msg_count             => l_msg_count,
                  						x_msg_data              => l_msg_data,
		  					  		x_request_id	  => l_sr_id);
					   	          l_logmessage:= 'creating normal after skipping adv sr processing status'||l_ret_status;
                                                          iem_logger(l_logmessage);
        				                  --dbms_output.put_line (l_logmessage);
					   	          l_logmessage:= 'sr_id is:'||l_sr_id;
                                                          iem_logger(l_logmessage);
        				                  --dbms_output.put_line (l_logmessage);
                                                     END IF;
							IF l_ret_status='S' then
							-- Add MLCS for Email Resolved as SR created
  							l_media_lc_rec.media_id :=l_media_id ;
  							l_media_lc_rec.milcs_type_id := 31;
  							l_media_lc_rec.start_date_time := sysdate;
  							l_media_lc_rec.handler_id := 680;
  							l_media_lc_rec.type_type := 'Email, Inbound';

							IEM_EMAIL_PROC_PVT.IEM_PROC_IH(
									p_type=>'MLCS'		,	-- MEDIA/ACTIVITY/MLCS/INTERACTION
									p_action=>'ADD'		,		-- ADD/UPDATE/CLOSE
									p_interaction_rec=>l_interaction_rec,
									p_activity_rec=>l_activity_rec     ,
									p_media_lc_rec=>l_media_lc_Rec ,
									p_media_rec=>l_media_rec	,
									x_id=>l_milcs_id,
									x_status=>l_stat		,
			     					x_out_text=>l_out_text	);
								IF l_stat<>'S' THEN
									l_logmessage:=l_out_text;
									raise ABORT_PROCESSING;
								END IF;
		IEM_RT_PROC_EMAILS_PVT.create_item (
					p_api_version_number => 1.0,
  					p_init_msg_list=>'F' ,
					p_commit=>'F',
				p_message_id =>l_post_rec.message_id,
				p_email_account_id  =>l_post_rec.email_account_id,
				p_priority  =>l_post_rec.priority,
				p_agent_id  =>-1,
				p_group_id  =>-1,
				p_sent_date =>l_header_Rec.sent_date,
				p_received_date =>l_post_Rec.received_Date,
				p_rt_classification_id =>l_rt_classification_id,
				p_customer_id=>l_customer_id    ,
				p_contact_id=>g_contact_id    ,
				p_relationship_id=>g_relation_id    ,
				p_interaction_id=>l_interaction_id ,
				p_ih_media_item_id=>l_media_id ,
				p_msg_status=>l_post_rec.msg_status  ,
				p_mail_proc_status=>'R' ,
				p_mail_item_status=>null ,
				p_category_map_id=>null ,
				p_rule_id=>l_rule_id,
				p_subject=>l_header_rec.subject,
				p_sender_address=>l_sender,
				p_from_agent_id=>null,
     			x_return_status=>l_ret_status	,
  				x_msg_count=>l_msg_count	      ,
 				x_msg_data=>l_msg_data);
			IF l_ret_status<>'S' THEN
				l_logmessage:='AUTOCREATESR:Error While Inserting Record in Proc Emails Table ';
                                iem_logger(l_logmessage);
                                --dbms_output.put_line ('Auto create sr ' || l_logmessage);
				raise ABORT_PROCESSING;
			END IF;
							-- Update  the Media Life Cycle for Auto Create  SR
 							 l_media_lc_rec.milcs_id:=l_milcs_id;
							IEM_EMAIL_PROC_PVT.IEM_PROC_IH(
								p_type=>'MLCS'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
								p_action=>'UPDATE'		,		-- ADD/UPDATE/CLOSE
								p_interaction_rec=>l_interaction_rec,
								p_activity_rec=>l_activity_rec     ,
								p_media_lc_rec=>l_media_lc_Rec ,
								p_media_rec=>l_media_rec	,
								x_id=>l_id,
								x_status=>l_stat		,
			  				   x_out_text=>l_out_text	);
							IF l_stat<>'S' THEN
								l_logmessage:=l_out_text;
								raise ABORT_PROCESSING;
							END IF;
										-- Create Activity
						-- Add a Activity for AUTO-CREATE  SR
     					l_activity_rec.start_date_time   := SYSDATE;
	       				l_activity_rec.media_id          := l_media_id;
         					l_activity_rec.action_id         := 65;	-- Email Resolved
         					l_activity_rec.interaction_id    := l_interaction_id;
         					l_activity_rec.action_item_id    := 45;-- EMAIL
         					l_activity_rec.DOC_ID   := l_sr_id;
         					l_activity_rec.DOC_REF := 'SR';
						IEM_EMAIL_PROC_PVT.IEM_PROC_IH(
								p_type=>'ACTIVITY'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
								p_action=>'ADD'		,		-- ADD/UPDATE/CLOSE
								p_interaction_rec=>l_interaction_rec,
								p_activity_rec=>l_activity_rec     ,
								p_media_lc_rec=>l_media_lc_Rec ,
								p_media_rec=>l_media_rec	,
								x_id=>l_activity_id,
								x_status=>l_stat		,
			     				x_out_text=>l_out_text	);

							IF l_stat<>'S' THEN
								l_logmessage:=l_out_text;
								raise ABORT_PROCESSING;
							END IF;
						-- Add a Activity for CREATE  SR
					-- select result reason outcome for activity
					select wu.outcome_id, wu.result_id, wu.reason_id INTO
 					l_activity_rec.outcome_id, l_activity_rec.result_id, l_activity_rec.reason_id
        				from jtf_ih_action_action_items aa, jtf_ih_wrap_ups wu
        				where aa.action_id =65
					and aa.action_item_id =45
        				and aa.default_wrap_id = wu.wrap_id;
     					l_activity_rec.start_date_time   := SYSDATE;
	       				l_activity_rec.media_id          := l_media_id;
         					l_activity_rec.action_id         := 13;	-- Create  SR
         					l_activity_rec.interaction_id    := l_interaction_id;
         					l_activity_rec.action_item_id    := 17;-- SR
         					l_activity_rec.DOC_ID   := l_sr_id;
         					l_activity_rec.DOC_REF := 'SR';
						-- Added l_activity_rec.doc_source_object_name for bug 9169782
						-- Changed by Sanjana Rao on 08-Jan-2010
						select incident_number into l_activity_rec.doc_source_object_name
						from cs_incidents_all_b where incident_id=l_sr_id;
						IEM_EMAIL_PROC_PVT.IEM_PROC_IH(
								p_type=>'ACTIVITY'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
								p_action=>'ADD'		,		-- ADD/UPDATE/CLOSE
								p_interaction_rec=>l_interaction_rec,
								p_activity_rec=>l_activity_rec     ,
								p_media_lc_rec=>l_media_lc_Rec ,
								p_media_rec=>l_media_rec	,
								x_id=>l_activity_id,
								x_status=>l_stat		,
			     				x_out_text=>l_out_text	);

							IF l_stat<>'S' THEN
								l_logmessage:=l_out_text;
								raise ABORT_PROCESSING;
							END IF;
					-- Update the mail Processing Life Cycles
 							 l_media_lc_rec.milcs_id:=l_mp_milcs_id;
 							 l_media_lc_rec.milcs_type_id:=17;
							IEM_EMAIL_PROC_PVT.IEM_PROC_IH(
								p_type=>'MLCS'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
								p_action=>'UPDATE'		,		-- ADD/UPDATE/CLOSE
								p_interaction_rec=>l_interaction_rec,
								p_activity_rec=>l_activity_rec     ,
								p_media_lc_rec=>l_media_lc_Rec ,
								p_media_rec=>l_media_rec	,
								x_id=>l_id,
								x_status=>l_stat		,
			  				   x_out_text=>l_out_text	);

							IF l_stat<>'S' THEN
								l_logmessage:=l_out_text;
								raise ABORT_PROCESSING;
							END IF;
						-- Check for Sending out notifications
						l_noti_flag:=FND_PROFILE.VALUE_SPECIFIC('IEM_SR_CREATE_NOTI');
						if l_noti_flag='Y' then
					-- update the itneraction with result reason outcome
					select wu.outcome_id, wu.result_id, wu.reason_id INTO
 					l_interaction_rec.outcome_id, l_interaction_rec.result_id, l_interaction_rec.reason_id
        				from jtf_ih_action_action_items aa, jtf_ih_wrap_ups wu
        				where aa.action_id =65
					and aa.action_item_id =45
        				and aa.default_wrap_id = wu.wrap_id;
					l_interaction_rec.interaction_id:=l_interaction_id;
				select contact_party_id into l_cust_contact_id from jtf_ih_interactions
				where interaction_id=l_interaction_id;
						IEM_EMAIL_PROC_PVT.IEM_PROC_IH(
								p_type=>'INTERACTION'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
								p_action=>'CLOSE'		,		-- ADD/UPDATE/CLOSE
								p_interaction_rec=>l_interaction_rec,
								p_activity_rec=>l_activity_rec     ,
								p_media_lc_rec=>l_media_lc_Rec ,
								p_media_rec=>l_media_rec	,
								x_id=>l_id,
								x_status=>l_stat		,
			     				x_out_text=>l_out_text	);

							IF l_stat<>'S' THEN
								l_logmessage:=l_out_text;
								raise ABORT_PROCESSING;
							END IF;
						IEM_AUTOREPLY(p_interaction_id=>l_interaction_id	,
									p_media_id=>l_media_id,
									p_post_rec=>l_post_rec,
									p_doc_tbl=>l_email_doc_tbl,
									p_subject=>l_header_rec.subject,
 									P_TAG_KEY_VALUE_TBL=>l_outbox_tbl ,
 									P_CUSTOMER_ID=>l_customer_id ,
 									P_RESOURCE_ID=>l_resource_id,
 									p_qualifiers =>l_qual_tbl,
									p_fwd_address=>null,
									p_fwd_doc_id=>l_sr_id,		-- Pass SR id
									p_req_type=>'N',		-- For autonotifications
									x_out_text=>l_out_text,
									x_status=>l_stat  ) ;

							IF l_stat<>'S' THEN
								l_logmessage:=l_out_text;
								raise ABORT_PROCESSING;
							END IF;
							l_autoack_flag:='N';  --so that no autoack is send.
						else
						-- Resolving the message without sending notifications
							IEM_EMAIL_PROC_PVT.IEM_WRAPUP(p_interaction_id=>l_interaction_id,
										p_media_id=>l_media_id		,
										p_milcs_id=>l_mp_milcs_id,
										p_action=>'R',
										p_email_rec =>l_post_rec,
										p_action_id=>65,
										x_out_text=>l_out_text,
										x_status=>l_stat );
										IF l_stat<>'S' THEN
											l_logmessage:=l_out_text;
											raise ABORT_PROCESSING;
										END IF;
						 end if;		-- for if l_noti_flag='Y'
						 	raise STOP_PROCESSING;
						 else		-- Sr creation fails so if it is internal type in that casecheck prfile value for next action. in case of external account it is always route.
						  if l_acct_type='I' then
						 	if (fnd_profile.value_specific('IEM_SR_NOT_UPDATED'))='REDIRECT'
 then
 							l_redirect_flag:='Y';
							end if;
						  end if;

           				 END IF;		-- for if l_Ret_status='S' from create sr api
						 end if;		-- for if l_party_id is not null
						-- End of create Sr
				ELSE 	-- This is a update service request
					IF (l_status_id is not null) and (l_sr_id is not null) then
							IEM_EMAIL_PROC_PVT.IEM_SRSTATUS_UPDATE(p_sr_id=>l_sr_id	,
												p_status_id=>l_status_id,
												p_email_rec=>l_post_rec,
												x_status =>l_stat,
												x_out_text=>l_out_text) ;
					IF l_stat='S' then
						-- Add a Activity for AUTO-UPDATE OF SR
     					l_activity_rec.start_date_time   := SYSDATE;
	       				l_activity_rec.media_id          := l_media_id;
         					l_activity_rec.action_id         := 75;	-- Auto Update Of SR
         					l_activity_rec.interaction_id    := l_interaction_id;
         					l_activity_rec.action_item_id    := 45;-- EMAIL
         					l_activity_rec.DOC_ID   := l_sr_id;
         					l_activity_rec.DOC_REF := 'SR';
						IEM_EMAIL_PROC_PVT.IEM_PROC_IH(
								p_type=>'ACTIVITY'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
								p_action=>'ADD'		,		-- ADD/UPDATE/CLOSE
								p_interaction_rec=>l_interaction_rec,
								p_activity_rec=>l_activity_rec     ,
								p_media_lc_rec=>l_media_lc_Rec ,
								p_media_rec=>l_media_rec	,
								x_id=>l_activity_id,
								x_status=>l_stat		,
			     				x_out_text=>l_out_text	);

							IF l_stat<>'S' THEN
								l_logmessage:=l_out_text;
								raise ABORT_PROCESSING;
							END IF;
					--Update Intearctionwith result reason outcome
					-- Create a Media Life Cycle for Auto update of SR
  						l_media_lc_rec.media_id :=l_media_id ;
  						l_media_lc_rec.milcs_type_id := 40; --EMAIL_AUTO_UPDATED_SR
  						l_media_lc_rec.start_date_time := sysdate;
  						l_media_lc_rec.handler_id := 680;
						IEM_EMAIL_PROC_PVT.IEM_PROC_IH(
								p_type=>'MLCS'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
								p_action=>'ADD'		,		-- ADD/UPDATE/CLOSE
								p_interaction_rec=>l_interaction_rec,
								p_activity_rec=>l_activity_rec     ,
								p_media_lc_rec=>l_media_lc_Rec ,
								p_media_rec=>l_media_rec	,
								x_id=>l_id,
								x_status=>l_stat		,
			    				 x_out_text=>l_out_text	);
							IF l_stat<>'S' THEN
								l_logmessage:=l_out_text;
								raise ABORT_PROCESSING;
							END IF;
							-- Update  the Media Life Cycle for Auto Update of SR
 							 l_media_lc_rec.milcs_id:=l_id;
							IEM_EMAIL_PROC_PVT.IEM_PROC_IH(
								p_type=>'MLCS'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
								p_action=>'UPDATE'		,		-- ADD/UPDATE/CLOSE
								p_interaction_rec=>l_interaction_rec,
								p_activity_rec=>l_activity_rec     ,
								p_media_lc_rec=>l_media_lc_Rec ,
								p_media_rec=>l_media_rec	,
								x_id=>l_id,
								x_status=>l_stat		,
			  				   x_out_text=>l_out_text	);
							IF l_stat<>'S' THEN
								l_logmessage:=l_out_text;
								raise ABORT_PROCESSING;
							END IF;

		IEM_RT_PROC_EMAILS_PVT.create_item (
					p_api_version_number => 1.0,
  					p_init_msg_list=>'F' ,
					p_commit=>'F',
				p_message_id =>l_post_rec.message_id,
				p_email_account_id  =>l_post_rec.email_account_id,
				p_priority  =>l_post_rec.priority,
				p_agent_id  =>-1,
				p_group_id  =>-1,
				p_sent_date =>l_header_Rec.sent_date,
				p_received_date =>l_post_Rec.received_Date,
				p_rt_classification_id =>l_rt_classification_id,
				p_customer_id=>l_customer_id    ,
				p_contact_id=>g_contact_id    ,
				p_relationship_id=>g_relation_id    ,
				p_interaction_id=>l_interaction_id ,
				p_ih_media_item_id=>l_media_id ,
				p_msg_status=>l_post_rec.msg_status  ,
				p_mail_proc_status=>'R' ,
				p_mail_item_status=>null ,
				p_category_map_id=>null ,
				p_rule_id=>l_rule_id,
				p_subject=>l_header_rec.subject,
				p_sender_address=>l_sender,
				p_from_agent_id=>null,
     			x_return_status=>l_ret_status	,
  				x_msg_count=>l_msg_count	      ,
 				x_msg_data=>l_msg_data);
			IF l_ret_status<>'S' THEN
				l_logmessage:='AUTOUPDSR:Error While Inserting Record in Proc Emails Table ';
				raise ABORT_PROCESSING;
			END IF;
			-- Check for Sending Out Notifications
				l_noti_flag:=FND_PROFILE.VALUE_SPECIFIC('IEM_SR_UPDATE_NOTI');
				if l_noti_flag='Y' then		-- Sends out notifications

					-- update the itneraction with result reason outcome
					select wu.outcome_id, wu.result_id, wu.reason_id INTO
 					l_interaction_rec.outcome_id, l_interaction_rec.result_id, l_interaction_rec.reason_id
        				from jtf_ih_action_action_items aa, jtf_ih_wrap_ups wu
        				where aa.action_id =75
					and aa.action_item_id =45
        				and aa.default_wrap_id = wu.wrap_id;
					l_interaction_rec.interaction_id:=l_interaction_id;
						IEM_EMAIL_PROC_PVT.IEM_PROC_IH(
								p_type=>'INTERACTION'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
								p_action=>'UPDATE'		,		-- ADD/UPDATE/CLOSE
								p_interaction_rec=>l_interaction_rec,
								p_activity_rec=>l_activity_rec     ,
								p_media_lc_rec=>l_media_lc_Rec ,
								p_media_rec=>l_media_rec	,
								x_id=>l_id,
								x_status=>l_stat		,
			     				x_out_text=>l_out_text	);


							IF l_stat<>'S' THEN
								l_logmessage:=l_out_text;
								raise ABORT_PROCESSING;
							END IF;
				l_outbox_tbl.delete;
				IF l_tag_keyval.count>0 THEN
						FOR i IN l_tag_keyval.FIRST..l_tag_keyval.LAST LOOP
							l_outbox_tbl(i).key:=l_tag_keyval(i).key;
							l_outbox_tbl(i).value:=l_tag_keyval(i).value;
							l_outbox_tbl(i).datatype:=l_tag_keyval(i).datatype;
						END LOOP;
				END IF;
						IEM_AUTOREPLY(p_interaction_id=>l_interaction_id	,
									p_media_id=>l_media_id,
									p_post_rec=>l_post_rec,
									p_doc_tbl=>l_email_doc_tbl,
									p_subject=>l_header_rec.subject,
 									P_TAG_KEY_VALUE_TBL=>l_outbox_tbl ,
 									P_CUSTOMER_ID=>l_customer_id ,
 									P_RESOURCE_ID=>l_resource_id,
 									p_qualifiers =>l_qual_tbl,
									p_fwd_address=>null,
									p_fwd_doc_id=>l_sr_id,		-- Pass the SR id
									p_req_type=>'N',		-- For autonotifications
									x_out_text=>l_out_text,
									x_status=>l_stat  ) ;

							IF l_stat<>'S' THEN
								l_logmessage:=l_out_text;
								raise ABORT_PROCESSING;
							END IF;
							l_autoack_flag:='N';
					-- Update the mail Processing Life Cycles
 							 l_media_lc_rec.milcs_id:=l_mp_milcs_id;
 							 l_media_lc_rec.milcs_type_id:=17;
							IEM_EMAIL_PROC_PVT.IEM_PROC_IH(
								p_type=>'MLCS'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
								p_action=>'UPDATE'		,		-- ADD/UPDATE/CLOSE
								p_interaction_rec=>l_interaction_rec,
								p_activity_rec=>l_activity_rec     ,
								p_media_lc_rec=>l_media_lc_Rec ,
								p_media_rec=>l_media_rec	,
								x_id=>l_id,
								x_status=>l_stat		,
			  				   x_out_text=>l_out_text	);

							IF l_stat<>'S' THEN
								l_logmessage:=l_out_text;
								raise ABORT_PROCESSING;
							END IF;
				   else					-- notification flag is not set so resolve the message
								IEM_EMAIL_PROC_PVT.IEM_WRAPUP(p_interaction_id=>l_interaction_id,
										p_media_id=>l_media_id		,
										p_milcs_id=>l_mp_milcs_id,
										p_action=>'R',
										p_email_rec =>l_post_rec,
										p_action_id=>75,
										x_out_text=>l_out_text,
										x_status=>l_stat );
										IF l_stat<>'S' THEN
											l_logmessage:=l_out_text;
											raise ABORT_PROCESSING;
										END IF;
					end if;		-- for if l_noti_flag='Y';
								raise STOP_PROCESSING;
					ELSE
						 		-- Sr updation fails so if it is internal type in that casecheck prfile value for next action. in case of external account it is always route.
						  if l_acct_type='I' then
						 	if (fnd_profile.value_specific('IEM_SR_NOT_UPDATED'))='REDIRECT'
 then
 							l_redirect_flag:='Y';
							end if;
						  end if;
					END IF;	-- if l_stat='S' from SR update api
					ELSE
				if g_statement_log then
					l_logmessage:='Status Id is not Set at Profile OR SR# is not present in TAG Not updating the SR';
					iem_logger(l_logmessage);
				end if;
					END IF;		-- if l_status_id is not null
				END IF;	-- indicual processing ends
			END IF;		-- elsif l_Action in ('AUTOCREATESR','AUTOUPDATESR');
			END IF;		-- if l_autoproc_result='T'
					  -- Check for autoack Flag if set then send autoack.
					  IF l_autoack_flag='Y' then
							if g_statement_log then
								l_logmessage:='Start Sending Out Autoacknowledgement' ;
								iem_logger(l_logmessage);
							end if;
    						FND_MESSAGE.Set_Name('IEM','IEM_ADM_AUTO_ACK_CUSTOMER');
 						FND_MSG_PUB.Add;
 						l_dflt_sender :=  FND_MSG_PUB.GET(FND_MSG_pub.Count_Msg,FND_API.G_FALSE);
					IEM_EMAIL_PROC_PVT.IEM_AUTOACK(p_email_user=>l_email_user_name,
							p_mailer =>l_header_rec.from_str,
							p_sender=>l_sender,
							p_subject=>l_header_rec.subject,
				 			 p_domain_name=>l_email_domain_name,
				 			 p_document_id =>l_doc_id,
				  			p_dflt_sender=>l_dflt_sender,
							p_int_id=>l_interaction_id,
				  			p_master_account_id=>l_post_rec.email_account_id,
				 			 x_status=>l_status,
				  			x_out_text=>l_out_text);
  						l_media_lc_rec.media_id :=l_media_id ;
  						l_media_lc_rec.milcs_type_id := 29; --MAIL_AUTOACKNOWLEDGED
  						l_media_lc_rec.start_date_time := sysdate;
  						l_media_lc_rec.handler_id := 680;
  						l_media_lc_rec.type_type := 'Email, Inbound';

				IF l_status<>'S' THEN   -- Create MLCS after auto ack
						if g_error_log then
							l_logmessage:='Error In Autoack '||l_out_text;
							iem_logger(l_logmessage);
						end if;
				ELSE
					IEM_EMAIL_PROC_PVT.IEM_PROC_IH(
						p_type=>'MLCS'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
						p_action=>'ADD'		,		-- ADD/UPDATE/CLOSE
						p_interaction_rec=>l_interaction_rec,
						p_activity_rec=>l_activity_rec     ,
						p_media_lc_rec=>l_media_lc_Rec ,
						p_media_rec=>l_media_rec	,
						x_id=>l_milcs_id,
						x_status=>l_stat		,
			   	  	     x_out_text=>l_out_text	);

 			 		l_media_lc_rec.milcs_id:=l_milcs_id;
					IEM_EMAIL_PROC_PVT.IEM_PROC_IH(
						p_type=>'MLCS'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
						p_action=>'UPDATE'		,		-- ADD/UPDATE/CLOSE
						p_interaction_rec=>l_interaction_rec,
						p_activity_rec=>l_activity_rec     ,
						p_media_lc_rec=>l_media_lc_Rec ,
						p_media_rec=>l_media_rec	,
						x_id=>l_milcs_id,
						x_status=>l_stat		,
			     		x_out_text=>l_out_text	);
				END IF;				-- End of MLCS Creation
				END IF;			-- End if for if l_autoack_flag='Y';
-- Calling Rules Engine for AUTO-REDIRECT Type
	-- Prior to calling this check if the email is to be redirected on the profile
	-- set for  autocreate/auto update SR fails for employee type
	if l_redirect_flag='N' then
	iem_rules_engine_pub.auto_process_email(p_api_version_number=>1.0,
									p_commit=>FND_API.G_FALSE,
									p_rule_type=>'AUTOREDIRECT',
									p_keyvals_tbl=>l_class_val_tbl,
									p_accountid=>l_post_rec.email_account_id,
									x_result=>l_autoproc_result,
									x_action=>l_action,
									x_parameters=>l_param_rec_tbl,
									x_return_status=>l_ret_status,
									x_msg_count=>l_msg_count,
									x_msg_data=>l_msg_data);
					IF l_ret_status<>'S' THEN
						l_logmessage:='Error While Calling rules Engine for AUTOREDIRECT';
						raise ABORT_PROCESSING;
					END IF;
		else		-- As auto redirect flag is set for autoupdate/create SR
			l_autoproc_result:='T';
			l_action:='AUTOREDIRECT_EXTERNAL';
			l_ext_address:=fnd_profile.value_specific('IEM_SR_REDIRECT_EMAIL_ADDR');
		end if;
			if l_action='AUTOREDIRECT_EXTERNAL' and l_autoproc_result='T' THEN
     			IF l_auto_forward_flag='Y' THEN --donot autoforward to a already autofwd message
					l_autoproc_result:='F';
				END IF;
		    end if;
		IF ((l_autoproc_result='T') AND (l_action is not null)) THEN
			-- Create the activity and necessary MLCS for auto redirect
			 IF l_action='AUTOREDIRECT_EXTERNAL' THEN
  						l_media_lc_rec.milcs_type_id := 49; --EMAIL_AUTO_REDIRECTD_EXTERNAL
				 ELSE
  						l_media_lc_rec.milcs_type_id := 48; --EMAIL_AUTO_REDIRECTD_INTERNAL
						l_media_lc_rec.resource_id:=l_post_rec.email_account_id;

                    END IF;
			-- Create the MILCS
						l_media_lc_rec.media_id :=l_media_id ;
  						l_media_lc_rec.start_date_time := sysdate;
  						l_media_lc_rec.handler_id := 680;
				-- Create MLCS for  Auto-Redirect
						IEM_EMAIL_PROC_PVT.IEM_PROC_IH(
								p_type=>'MLCS'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
								p_action=>'ADD'		,		-- ADD/UPDATE/CLOSE
								p_interaction_rec=>l_interaction_rec,
								p_activity_rec=>l_activity_rec     ,
								p_media_lc_rec=>l_media_lc_Rec ,
								p_media_rec=>l_media_rec	,
								x_id=>l_milcs_id,
								x_status=>l_stat		,
			    				 x_out_text=>l_out_text	);
							IF l_stat<>'S' THEN
								l_logmessage:=l_out_text;
								raise ABORT_PROCESSING;
							END IF;
							-- Update  the Media Life Cycle for Auto RRRR
 							 l_media_lc_rec.milcs_id:=l_milcs_id;
							IEM_EMAIL_PROC_PVT.IEM_PROC_IH(
								p_type=>'MLCS'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
								p_action=>'UPDATE'		,		-- ADD/UPDATE/CLOSE
								p_interaction_rec=>l_interaction_rec,
								p_activity_rec=>l_activity_rec     ,
								p_media_lc_rec=>l_media_lc_Rec ,
								p_media_rec=>l_media_rec	,
								x_id=>l_milcs_id,
								x_status=>l_stat		,
			  				   x_out_text=>l_out_text	);

							IF l_stat<>'S' THEN
								l_logmessage:=l_out_text;
								raise ABORT_PROCESSING;
							END IF;
		 IF (l_action='AUTOREDIRECT_EXTERNAL') THEN
				if l_redirect_flag='N' then
					FOR l_param_index in l_param_rec_tbl.FIRST..l_param_rec_tbl.LAST LOOP
							l_ext_address:=l_param_rec_tbl(l_param_index).parameter1;
							l_ext_temp_id:=to_number(l_param_rec_tbl(l_param_index).type);
							EXIT;
						END LOOP;
				end if;
						-- Calling Outbox Processor API

				l_outbox_tbl.delete;
				l_qual_tbl.delete;
				IF l_tag_keyval.count>0 THEN
						FOR i IN l_tag_keyval.FIRST..l_tag_keyval.LAST LOOP
							l_outbox_tbl(i).key:=l_tag_keyval(i).key;
							l_outbox_tbl(i).value:=l_tag_keyval(i).value;
							l_outbox_tbl(i).datatype:=l_tag_keyval(i).datatype;
						END LOOP;
				END IF;
					l_f_name:=substr(l_from_folder,2,length(l_from_folder));
					if l_customer_id>0 then
						l_cust_search_id:=l_customer_id;
					end if;
						IEM_AUTOREPLY(p_interaction_id=>l_interaction_id	,
									p_media_id=>l_media_id,
									p_post_rec=>l_post_rec,
									p_doc_tbl=>l_email_doc_tbl,
									p_subject=>l_header_rec.subject,
 									P_TAG_KEY_VALUE_TBL=>l_outbox_tbl ,
 									P_CUSTOMER_ID=>l_cust_search_id ,
 									P_RESOURCE_ID=>l_resource_id,
 									p_qualifiers =>l_qual_tbl,
									p_fwd_address=>l_ext_address,
									p_fwd_doc_id=>l_ext_temp_id,
									p_req_type=>'F',		-- For autoforward
									x_out_text=>l_out_text,
									x_status=>l_stat  ) ;

							IF l_stat<>'S' THEN
								l_logmessage:=l_out_text;
								raise ABORT_PROCESSING;
							END IF;
						   		l_auto_msgstatus:='XREDIRECT';		-- Xternal redirect
				 			raise STOP_AUTO_PROCESSING;
		 ELSIF (l_action='AUTOREDIRECT_INTERNAL') THEN
				FOR l_param_index in l_param_rec_tbl.FIRST..l_param_rec_tbl.LAST LOOP
					l_redirect_id:=l_param_rec_tbl(l_param_index).parameter1;
					EXIT;
				END LOOP;
				-- Need new code to complete this .
				-- Create a Record for New Email Accounts in PREPROC Tables and Stop Processing for the
				-- Current One
				delete from iem_email_classifications where message_id=l_post_rec.message_id;
				update iem_rt_preproc_emails
				set email_account_id=l_redirect_id,
				msg_status='REDIRECT',
				ih_media_item_id=l_media_id
				where message_id=l_post_rec.message_id;

			IEM_EMAIL_PROC_PVT.IEM_WRAPUP(p_interaction_id=>l_interaction_id,
					p_media_id=>l_media_id		,
					p_milcs_id=>l_mp_milcs_id,
					p_action=>null,
					p_email_rec =>l_post_rec,
					p_action_id=>72,
					x_out_text=>l_out_text,
					x_status=>l_stat );
							IF l_stat<>'S' THEN
								l_logmessage:=l_out_text;
								raise ABORT_PROCESSING;
							END IF;
					raise STOP_REDIRECT_PROCESSING;
		END IF;		-- End if for both redirect actions
       END IF;		--End if for autoproc_result='T'
-- Calling Rules Engine For Auto-Reply
	iem_rules_engine_pub.auto_process_email(p_api_version_number=>1.0,
									p_commit=>FND_API.G_FALSE,
									p_rule_type=>'AUTORRRS',
									p_keyvals_tbl=>l_class_val_tbl,
									p_accountid=>l_post_rec.email_account_id,
									x_result=>l_autoproc_result,
									x_action=>l_action,
									x_parameters=>l_param_rec_tbl,
									x_return_status=>l_ret_status,
									x_msg_count=>l_msg_count,
									x_msg_data=>l_msg_data);
					IF l_ret_status<>'S' THEN
						l_logmessage:='Error While Calling rules Engine for Auto-Reply';
						raise ABORT_PROCESSING;
					END IF;
		IF ((l_autoproc_result='T') AND (l_action is not null)) THEN
			IF ((l_action='AUTOREPLYSPECIFIEDDOC') AND  (l_auto_reply_flag='N')) THEN
				FOR l_param_index in l_param_rec_tbl.FIRST..l_param_rec_tbl.LAST LOOP
				-- Add code for integration into Outbox Processing
				l_email_doc_tbl(l_param_index).doc_id:=l_param_rec_tbl(l_param_index).parameter2;
				l_email_doc_tbl(l_param_index).type:=l_param_rec_tbl(l_param_index).type;
				END LOOP;
				l_outbox_tbl.delete;
				IF l_tag_keyval.count>0 THEN
						FOR i IN l_tag_keyval.FIRST..l_tag_keyval.LAST LOOP
							l_outbox_tbl(i).key:=l_tag_keyval(i).key;
							l_outbox_tbl(i).value:=l_tag_keyval(i).value;
							l_outbox_tbl(i).datatype:=l_tag_keyval(i).datatype;
						END LOOP;
				END IF;
					if l_customer_id>0 then
						l_cust_search_id:=l_customer_id;
					end if;

						IEM_AUTOREPLY(p_interaction_id=>l_interaction_id	,
									p_media_id=>l_media_id,
									p_post_rec=>l_post_rec,
									p_doc_tbl=>l_email_doc_tbl,
									p_subject=>l_header_rec.subject,
 									P_TAG_KEY_VALUE_TBL=>l_outbox_tbl ,
 									P_CUSTOMER_ID=>l_cust_search_id ,
 									P_RESOURCE_ID=>l_resource_id,
 									p_qualifiers =>l_qual_tbl,
									p_fwd_address=>null,
									p_fwd_doc_id=>null,
									p_req_type=>'R',		--for autoreply
									x_out_text=>l_out_text,
									x_status=>l_stat  ) ;

						   IF l_stat='S' THEN
						   		l_auto_msgstatus:='AUTOREPLY';
								raise STOP_AUTO_PROCESSING;
						   ELSE
								l_logmessage:=l_out_text;
						   END IF;

		END IF;	-- End if for l_action=AUTOREPLYSPECIFIED
        END IF;	--	End if for autoproc_result='T'
		-- Calling DOCUMENT_RETRIEVAL		11.5.10 feature
				l_rule_id:=0;
	iem_rules_engine_pub.auto_process_email(p_api_version_number=>1.0,
					p_commit=>FND_API.G_FALSE,
					p_rule_type=>'DOCUMENTRETRIEVAL',
					p_keyvals_tbl=>l_class_val_tbl,
					p_accountid=>l_post_rec.email_account_id,
					x_result=>l_autoproc_result,
					x_action=>l_action,
					x_parameters=>l_param_rec_tbl,
					x_return_status=>l_ret_status,
					x_msg_count=>l_msg_count,
					x_msg_data=>l_msg_data);
		    IF l_ret_status<>'S' THEN
			   l_logmessage:='Error While Calling rules Engine for DOCUMENTRETRIEVAL';
			   raise ABORT_PROCESSING;
			END IF;
			IF l_autoproc_result='T' THEN
			 if l_action <> 'MES_CATEGORY_MAPPING'  THEN
	     l_search_type:=substr(l_action,15,length(l_action));
		 -- identfiying the repository to search
				if l_search_type='MES' THEN
					l_repos:='MES';
				elsif l_search_type='KM' THEN
					l_repos:='SMS';
				elsif l_search_type='BOTH' THEN
					l_repos:='ALL';
				end if;
				   l_cat_counter:=1;
				   IF l_param_rec_tbl.count>0 THEN
				   FOR l_param_index in l_param_rec_tbl.FIRST..l_param_rec_tbl.LAST LOOP
			 		IF l_param_rec_tbl(l_param_index).parameter1 <> to_char(-1)  then
						IF l_param_rec_tbl(l_param_index).parameter1='RULE_ID' then
							l_rule_id:=l_param_rec_tbl(l_param_index).parameter2;
						ELSE
							l_category_id.extend;
					l_category_id(l_cat_counter):=l_param_rec_tbl(l_param_index).parameter1;
							l_cat_counter:=l_cat_counter+1;
						END IF;
					END IF;
				  END LOOP;
				  END IF;
			else
					l_search_type:='CM';		--Category based mapping
				   FOR l_param_index in l_param_rec_tbl.FIRST..l_param_rec_tbl.LAST LOOP
							l_cm_cat_id:=l_param_rec_tbl(l_param_index).parameter1;
							EXIT;
				   END LOOP;
			end if;
		else
			l_search_type:=null;
			l_cm_Cat_id:=0;
          end if ;		-- end if for l_autoproc_result='T'
		-- CALLING ROUTING ----
IEM_EMAIL_PROC_PVT.IEM_ROUTING_PROC(
					p_email_account_id=>l_post_rec.email_account_id,
				p_keyval=>l_class_val_tbl,
				x_routing_group_id=>l_group_id,
					x_status=>l_status,
		     		x_out_text=>l_out_text) ;
	IF l_status <>'S' THEN
		l_logmessage:=l_out_text;
	if g_error_log then
		iem_logger(l_logmessage);
		raise abort_processing;
	end if;
	END IF;
	IF l_group_id=-1 then
		-- pre 11510 group id for the auto routed message is determined by first group the agent belongs to.Because of
		-- supervisor agent inbox requeue message it is defaulted to 0 from 11.5.10.So that anybody can access it.
			l_group_id:=0;
			l_auto_flag:='Y';
	END IF;

		IEM_RT_PROC_EMAILS_PVT.create_item (
					p_api_version_number => 1.0,
  					p_init_msg_list=>'F' ,
					p_commit=>'F',
				p_message_id =>l_post_rec.message_id,
				p_email_account_id  =>l_post_rec.email_account_id,
				p_priority  =>l_post_rec.priority,
				p_agent_id  =>0,
				p_group_id  =>l_group_id,
				p_sent_date =>l_header_Rec.sent_date,
				p_received_date =>l_post_Rec.received_Date,
				p_rt_classification_id =>l_rt_classification_id,
				p_customer_id=>l_customer_id    ,
				p_contact_id=>g_contact_id    ,
				p_relationship_id=>g_relation_id    ,
				p_interaction_id=>l_interaction_id ,
				p_ih_media_item_id=>l_media_id ,
				p_msg_status=>l_post_rec.msg_status  ,
				p_mail_proc_status=>'P' ,
				p_mail_item_status=>'N' ,
				p_category_map_id=>l_cm_cat_id ,
				p_rule_id=>l_rule_id,
				p_subject=>l_header_rec.subject,
				p_sender_address=>l_sender	,
				p_from_agent_id=>null,
     			x_return_status=>l_ret_status	,
  				x_msg_count=>l_msg_count	      ,
 				x_msg_data=>l_msg_data);
IF l_ret_status='S' THEN
	IF l_auto_flag='Y' THEN		-- auto Routing Processing
	 SAVEPOINT auto_route_main;
		-- creating RT item  bug 7428636
		IEM_CLIENT_PUB.createRTItem (p_api_version_number=>1.0,
					p_init_msg_list=>'F',
					p_commit=>'F',
   					p_message_id =>l_post_rec.message_id,
  					p_to_resource_id  =>l_agentid,
  					p_from_resource_id =>l_agentid,
  					p_status  =>'N',
  					p_reason =>'O',
  					p_interaction_id =>l_interaction_id,
  					x_return_status  =>l_ret_status,
  					x_msg_count =>l_msg_count,
  					x_msg_data   =>l_msg_data,
  					x_rt_media_item_id =>l_rt_media_item_id,
  					x_rt_interaction_id =>l_rt_interaction_id);
		 IF l_ret_status<>'S' THEN
	if g_error_log then
				l_logmessage:='Failed To Auto Route The Message due to error in create RT Item ';
				iem_logger(l_logmessage);
	end if;
	ELSE     -- as part of bug fix 7428636
	-- Able to create RT Item So do autorouting
		update iem_rt_proc_emails
		set resource_id=l_agentid
		where message_id=l_post_rec.message_id;
				-- Create MLCS for Auto Routing

  					l_media_lc_rec.media_id :=l_media_id ;
  					l_media_lc_rec.milcs_type_id := 30; --MAIL_AUTOROUTE
  					l_media_lc_rec.start_date_time := sysdate;
  					l_media_lc_rec.handler_id := 680;
  					l_media_lc_rec.type_type := 'Email, Inbound';
  					l_media_lc_rec.resource_id := l_agentid;
					l_stat:='S' ; -- reset to 'S' before starting any MLCS
				--	IH activity;

						IEM_EMAIL_PROC_PVT.IEM_PROC_IH(
							p_type=>'MLCS'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
								p_action=>'ADD'		,		-- ADD/UPDATE/CLOSE
								p_interaction_rec=>l_interaction_rec,
								p_activity_rec=>l_activity_rec     ,
								p_media_lc_rec=>l_media_lc_Rec ,
								p_media_rec=>l_media_rec	,
								x_id=>l_milcs_id,
								x_status=>l_stat		,
			    				 x_out_text=>l_out_text	);
					IF l_stat<>'S' THEN
					if g_error_log then
						l_logmessage:='Error while creating MLCS for Auto Route '||l_out_text;
						iem_logger(l_logmessage);
						rollback to auto_route_main;
					end if;
					END IF;
							-- Update  the Media Life Cycle for Auto Routing
                 if l_stat='S' then
 							 l_media_lc_rec.milcs_id:=l_milcs_id;
							IEM_EMAIL_PROC_PVT.IEM_PROC_IH(
							p_type=>'MLCS'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
								p_action=>'UPDATE'		,		-- ADD/UPDATE/CLOSE
								p_interaction_rec=>l_interaction_rec,
								p_activity_rec=>l_activity_rec     ,
								p_media_lc_rec=>l_media_lc_Rec ,
								p_media_rec=>l_media_rec	,
								x_id=>l_milcs_id,
								x_status=>l_stat		,
			  				   x_out_text=>l_out_text	);

				IF l_stat<>'S' THEN
					if g_error_log then
						l_logmessage:='Error while updating MLCS for Auto Route '||l_out_text;
						iem_logger(l_logmessage);
						rollback to auto_route_main;
					end if;
				END IF;
			  END IF; -- End If for if l_Stat='S'
				 if l_stat='S' then
			-- In case of autoroute update the interaction with resource id of the agent to which
			-- the message is autorouted to
			l_interaction_rec.interaction_id:=l_interaction_id;
			l_interaction_rec.resource_id:=l_agentid;
     		JTF_IH_PUB.Update_Interaction( p_api_version     => 1.1,
                                  p_resp_appl_id    => TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
                                  p_resp_id         => TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
                         		p_user_id		  =>nvl(TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),-1),
							p_login_id	  =>TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),
                                  x_return_status   => l_ret_status,
                                  x_msg_count       => l_msg_count,
                                  x_msg_data        => l_msg_data,
                                  p_interaction_rec => l_interaction_rec
                                 );
					IF l_ret_status<>'S' THEN
					IF g_error_log then
							l_logmessage:='Error while updating Interactions for Auto Route ';
							iem_logger(l_logmessage);
					end if;
						rollback to auto_route;
					ELSE
						if g_statement_log then
							l_logmessage:='Successfully AutoRoute The Message ';
							iem_logger(l_logmessage);
						end if;
    				     END IF;  -- End If for if l_ret_status='S'
					END IF; -- End if for if l_stat='S'
				END IF; -- For the ELSE part  as part of bug fix 7428636
			  END IF; -- End If for auto routing;

ELSE

		raise ERR_INSERTING;
 END IF;
	-- Update  the Media Life Cycle for Mail processing
  l_media_lc_rec.milcs_id:=l_mp_milcs_id;
  l_media_lc_rec.milcs_type_id := 17;
	IEM_EMAIL_PROC_PVT.IEM_PROC_IH(
				p_type=>'MLCS'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
				p_action=>'UPDATE'		,		-- ADD/UPDATE/CLOSE
				p_interaction_rec=>l_interaction_rec,
				p_activity_rec=>l_activity_rec     ,
				p_media_lc_rec=>l_media_lc_Rec ,
				p_media_rec=>l_media_rec	,
				x_id=>l_milcs_id,
				x_status=>l_stat		,
			     x_out_text=>l_out_text	);

			IF l_stat<>'S' THEN
				l_logmessage:=l_out_text;
			raise ABORT_PROCESSING;
			END IF;
	delete from iem_rt_preproc_emails
	where message_id=l_post_rec.message_id;
	-- Calling the specific search at the End
	if g_statement_log then
		l_logmessage:='Calling Specific Search API ' ;
		iem_logger(l_logmessage);
	end if;
	BEGIN
	IF l_search_type<>'CM' THEN			-- Not a MES category based mapping
			l_start_search:=1;
			FOR v1 in c_class_id LOOP
	IEM_EMAIL_PROC_PVT.IEM_WF_SPECIFICSEARCH(
    					l_post_rec.message_id  ,
    					l_post_rec.email_account_id ,
    					v1.classification_id,
					l_category_id,
					l_repos,
    					l_stat ,
    					l_out_text);
		l_start_search:=l_start_search+1;
		EXIT when l_start_search>l_intent_counter;
		END LOOP;
	ELSIF nvl(l_search_type,' ')='CM' and l_cm_cat_id is not null then
		for v_item in c_item LOOP
		select count(*) into l_kb_rank
		from iem_doc_usage_stats
		where kb_doc_id=v_item.item_id;
		IEM_KB_RESULTS_PVT.create_item(p_api_version_number=>1.0,
 		  	      		p_init_msg_list=>'F' ,
		    	      		p_commit=>'F'	    ,
						 p_message_id =>l_post_rec.message_id,
						 p_classification_id=>0,
 				p_email_account_id=>l_post_rec.email_account_id ,
 			p_document_id =>to_char(v_item.item_id),
 		p_kb_repository_name =>'MES',
 		p_kb_category_name =>'MES',
 			p_document_title =>v_item.item_name,
 p_doc_last_modified_date=>v_item.last_update_date,
 			p_score =>l_kb_rank,
 			p_url =>' ',
			p_kb_delete=>'N',
	p_CREATED_BY  =>TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),
    	p_CREATION_DATE  =>SYSDATE,
    	p_LAST_UPDATED_BY  =>TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),
    	p_LAST_UPDATE_DATE  =>SYSDATE,
    	p_LAST_UPDATE_LOGIN=>TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ID')) ,
    	p_ATTRIBUTE1   =>null,
    	p_ATTRIBUTE2   =>null,
    	p_ATTRIBUTE3   =>null,
    	p_ATTRIBUTE4   =>null,
    	p_ATTRIBUTE5   =>null,
    	p_ATTRIBUTE6   =>null,
    	p_ATTRIBUTE7   =>null,
    	p_ATTRIBUTE8   =>null,
    	p_ATTRIBUTE9   =>null,
    	p_ATTRIBUTE10  =>null,
    	p_ATTRIBUTE11  =>null,
    	p_ATTRIBUTE12  =>null,
    	p_ATTRIBUTE13  =>null,
    	p_ATTRIBUTE14  =>null,
    	p_ATTRIBUTE15  =>null,
			x_return_status=>l_ret_status,
			x_msg_count=>l_msg_count,
			x_msg_data=>l_msg_data);
	END LOOP;
	END IF;		-- Endof search_type<>'CM'
   	EXCEPTION WHEN OTHERS THEN
		NULL;
	END;
	if g_statement_log then
		l_logmessage:='End Of Calling Specific Search API  and end of Processing for the message ' ;
		iem_logger(l_logmessage);
	end if;
	commit;
   EXCEPTION
   when STOP_AUTO_PROCESSING THEN
					-- Update  the Media Life Cycle for Mail processing  -- no need to call wrapup
 								 l_media_lc_rec.milcs_id:=l_mp_milcs_id;
 								 l_media_lc_rec.milcs_type_id := 17;
							iem_email_proc_pvt.IEM_PROC_IH(
										p_type=>'MLCS'	,-- MEDIA/ACTIVITY/MLCS/INTERACTION
										p_action=>'UPDATE'	,	-- ADD/UPDATE/CLOSE
										p_interaction_rec=>l_interaction_rec,
										p_activity_rec=>l_activity_rec     ,
										p_media_lc_rec=>l_media_lc_Rec ,
										p_media_rec=>l_media_rec	,
										x_id=>l_milcs_id,
										x_status=>l_stat		,
			    						 x_out_text=>l_out_text	);

									IF l_stat<>'S' THEN
								if g_error_log then
										l_logmessage:=l_out_text;
   										l_Error_Message := 'Abort Processing '||l_logmessage;
     									iem_logger(l_Error_Message);
								end if;
										ROLLBACK TO process_emails_pvt;
										-- Timestamp the message to sent it to back of queue
										update iem_rt_preproc_emails
										set creation_date=sysdate
										where message_id=l_post_rec.message_id;
										commit;
								     ELSE
									-- Create a Record in IEM_RT_PROC_EMAILS_PVT
									IEM_RT_PROC_EMAILS_PVT.create_item (
												p_api_version_number => 1.0,
  												p_init_msg_list=>'F' ,
												p_commit=>'F',
											p_message_id =>l_post_rec.message_id,
											p_email_account_id  =>l_post_rec.email_account_id,
											p_priority  =>l_post_rec.priority,
											p_agent_id  =>-1,
											p_group_id  =>-1,
											p_sent_date =>l_header_Rec.sent_date,
											p_received_date =>l_post_Rec.received_Date,
											p_rt_classification_id =>l_rt_classification_id,
											p_customer_id=>l_customer_id    ,
											p_contact_id=>g_contact_id    ,
											p_relationship_id=>g_relation_id    ,
											p_interaction_id=>l_interaction_id ,
											p_ih_media_item_id=>l_media_id ,
											p_msg_status=>l_auto_msgstatus  ,
											p_mail_proc_status=>'R' ,
											p_mail_item_status=>null ,
											p_category_map_id=>null ,
											p_rule_id=>l_rule_id,
											p_subject=>l_header_rec.subject,
											p_sender_address=>l_sender,
											p_from_agent_id=>null,
     										x_return_status=>l_ret_status	,
  											x_msg_count=>l_msg_count	      ,
 											x_msg_data=>l_msg_data);

									IF l_ret_status<>'S' THEN
								if g_error_log then
										l_logmessage:='AUTOREPLY:Error While Inserting Record in Proc Emails Table ';
   										l_Error_Message := 'Abort Processing '||l_logmessage;
     									iem_logger(l_Error_Message);
								end if;
										ROLLBACK TO process_emails_pvt;
										-- Timestamp the message to sent it to back of queue
										update iem_rt_preproc_emails
										set creation_date=sysdate
										where message_id=l_post_rec.message_id;
										commit;
									ELSE
											delete from iem_rt_preproc_emails where message_id=l_post_rec.message_id;
											commit;
									END IF;
									END IF;
   WHEN STOP_PROCESSING THEN
		delete from iem_rt_preproc_emails
		where message_id=l_post_rec.message_id;
					  -- Check for autoack Flag if set then send autoack.
					  IF l_autoack_flag='Y' then
							if g_statement_log then
								l_logmessage:='Start Sending Out Autoacknowledgement' ;
								iem_logger(l_logmessage);
							end if;
    						FND_MESSAGE.Set_Name('IEM','IEM_ADM_AUTO_ACK_CUSTOMER');
 						FND_MSG_PUB.Add;
 						l_dflt_sender :=  FND_MSG_PUB.GET(FND_MSG_pub.Count_Msg,FND_API.G_FALSE);
					IEM_EMAIL_PROC_PVT.IEM_AUTOACK(p_email_user=>l_email_user_name,
							p_mailer =>l_header_rec.from_str,
							p_sender=>l_sender,
							p_subject=>l_header_rec.subject,
				 			 p_domain_name=>l_email_domain_name,
				 			 p_document_id =>l_doc_id,
				  			p_dflt_sender=>l_dflt_sender,
							p_int_id=>l_interaction_id,
				  			p_master_account_id=>l_post_rec.email_account_id,
				 			 x_status=>l_status,
				  			x_out_text=>l_out_text);
  						l_media_lc_rec.media_id :=l_media_id ;
  						l_media_lc_rec.milcs_type_id := 29; --MAIL_AUTOACKNOWLEDGED
  						l_media_lc_rec.start_date_time := sysdate;
  						l_media_lc_rec.handler_id := 680;
  						l_media_lc_rec.type_type := 'Email, Inbound';

				IF l_status<>'S' THEN   -- Create MLCS after auto ack
						if g_error_log then
							l_logmessage:='Error In Autoack '||l_out_text;
							iem_logger(l_logmessage);
						end if;
				ELSE
					IEM_EMAIL_PROC_PVT.IEM_PROC_IH(
						p_type=>'MLCS'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
						p_action=>'ADD'		,		-- ADD/UPDATE/CLOSE
						p_interaction_rec=>l_interaction_rec,
						p_activity_rec=>l_activity_rec     ,
						p_media_lc_rec=>l_media_lc_Rec ,
						p_media_rec=>l_media_rec	,
						x_id=>l_milcs_id,
						x_status=>l_stat		,
			   	  	     x_out_text=>l_out_text	);

 			 		l_media_lc_rec.milcs_id:=l_milcs_id;
					IEM_EMAIL_PROC_PVT.IEM_PROC_IH(
						p_type=>'MLCS'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
						p_action=>'UPDATE'		,		-- ADD/UPDATE/CLOSE
						p_interaction_rec=>l_interaction_rec,
						p_activity_rec=>l_activity_rec     ,
						p_media_lc_rec=>l_media_lc_Rec ,
						p_media_rec=>l_media_rec	,
						x_id=>l_milcs_id,
						x_status=>l_stat		,
			     		x_out_text=>l_out_text	);
				END IF;				-- End of MLCS Creation
				END IF;			-- End if for if l_autoack_flag='Y';
	     commit;
	if g_statement_log then
      	l_Error_Message := 'stop Further Processing';
     	iem_logger(l_Error_Message);
	end if;
   WHEN STOP_REDIRECT_PROCESSING THEN		-- Here record can not be deleted from preproc_emails table
	if g_statement_log then
      l_Error_Message := 'stop Further Processing';
     	iem_logger(l_Error_Message);
	end if;
	     commit;
   WHEN ABORT_PROCESSING THEN
	if g_exception_log then
   		l_Error_Message := 'Abort Processing Due to  Oracle Error'||sqlerrm;
     	iem_logger(l_Error_Message);
	end if;
	ROLLBACK TO process_emails_pvt;
	-- Timestamp the message to sent it to back of queue
	update iem_rt_preproc_emails
	set creation_date=sysdate
	where message_id=l_post_rec.message_id;
	commit;

   WHEN ERR_INSERTING THEN
	if g_exception_log then
   		l_logmessage := 'Unable To insert Record in Post MDT '||sqlerrm;
		iem_logger(l_logmessage);
	end if;
	ROLLBACK TO process_emails_pvt;
	update iem_rt_preproc_emails
	set creation_date=sysdate
	where message_id=l_post_rec.message_id;
	commit;
  WHEN NO_RECORD_TO_PROCESS THEN
	if g_statement_log then
		l_logmessage:='No Valid Record Found For Processing';
		iem_logger(l_logmessage);
	end if;
  WHEN OTHERS THEN
	if g_exception_log then
		l_logmessage:='Oracle Error Encountered in Processing'||sqlerrm;
		iem_logger(l_logmessage);
	end if;
	ROLLBACK TO process_emails_pvt;
	update iem_rt_preproc_emails
	set creation_date=sysdate
	where message_id=l_post_rec.message_id;
	commit;
		null;
 END;
	  l_count:=l_count+1;
       EXIT when l_count>p_count;
    END LOOP;
-- Standard Check Of p_commit.
    IF FND_API.To_Boolean(p_commit) THEN
          COMMIT WORK;
     END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO process_emails_pvt;
        FND_MESSAGE.SET_NAME('IEM','IEM_RETRYPROCESS_EXEC_ERROR');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_Error_Message);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO process_emails_pvt;
        FND_MESSAGE.SET_NAME('IEM','IEM_RETRYPROCESS_UNXPTD_ERR');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_Error_Message);
   WHEN OTHERS THEN
	ROLLBACK TO process_emails_pvt;
        FND_MESSAGE.SET_NAME('IEM','IEM_RETRYPROCESS_OTHER_ERR');
        l_Error_Message := SQLERRM;
     	fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_Error_Message);

 END	PROC_EMAILS;

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

Procedure iem_returned_msg_rec(x_msg_rec out nocopy iem_rt_preproc_emails%ROWTYPE) is
	e_nowait	EXCEPTION;
	PRAGMA	EXCEPTION_INIT(e_nowait, -54);
	l_post_rec		iem_rt_preproc_emails%rowtype;
	l_folder_name		varchar2(20):='/Inbox';
	l_uid			number;
	l_status			varchar2(10);
	l_out_text		varchar2(1000);
BEGIN
	for x in ( select message_id
 	from iem_rt_preproc_emails
 	order by priority,creation_date)
LOOP
BEGIN
	select * into x_msg_rec from iem_rt_preproc_emails
	where message_id=x.message_id FOR UPDATE NOWAIT;
     	exit;
EXCEPTION when e_nowait then
		null;
when others then
		null ;
END;
END LOOP;
END;
PROCEDURE IEM_AUTOACK(p_email_user	 in varchar2,
				  p_mailer in varchar2,
				  p_sender in varchar2,
				  p_subject in varchar2,
				  p_domain_name	in varchar2,
				  p_document_id in number,
				  p_dflt_sender in varchar2,
				  p_int_id	in number,
				  p_master_account_id 	in number,
				  x_status	OUT NOCOPY varchar2,
				  x_out_text	OUT NOCOPY varchar2) IS
 l_str			varchar2(255);
l_to_recip	varchar2(240);
l_cc_recip	varchar2(240);
l_index		number;
l_ret		number;
l_email_encrypt_tbl	IEM_SENDMAIL_PVT.email_encrypt_tbl;
l_ack_sub			varchar2(250);
l_status			varchar2(10);
l_text_data		varchar2(500);
l_reply_address	varchar2(500);
l_resource_id		number;
l_email_account_id	number;
l_qual_tbl		 IEM_OUTBOX_PROC_PUB.QualifierRecordList;
 ACK_FAILED		EXCEPTION;
 l_ret_status		varchar2(10);
 l_msg_count		number;
 l_msg_data		varchar2(500);
 l_outbox_id		number;
 l_data			varchar2(500);
 l_error_text			varchar2(500);
 l_subject			varchar2(500);
	l_msg_index_out		number;
BEGIN
	x_status:='S';
 IEM_EMAIL_PROC_PVT.IEM_GET_MERGEVAL(p_email_account_id=>p_master_account_id ,
				    p_mailer=>p_mailer,
				    p_dflt_sender=>p_dflt_sender	,
				    p_subject=>p_subject,
				    x_qual_tbl=> l_qual_tbl,
				    x_status=>l_status,
				    x_out_text=>l_text_data);
			if l_status<>'S' THEN
				raise ACK_FAILED;
			end if;
	-- Selecting Auto Ack. Subject which will be appended to original mail
	BEGIN
	select meaning||': '
	into l_ack_sub
	from fnd_lookups
	where lookup_type='IEM_AUTO_ACKNOWLEDGE'
	and lookup_code='SUBJECT';
	l_subject:=substr(l_ack_sub||p_subject,1,240);
	EXCEPTION WHEN OTHERS THEN
		null;
     END;
	-- Calling OP Api for sending Out Auto Acknowledgement

     		l_resource_id:=FND_PROFILE.VALUE_SPECIFIC('IEM_SRVR_ARES') ;
			IEM_OUTBOX_PROC_PUB.createOutboxMessage(p_api_version_number=>1.0,
			p_init_msg_list=>'F',
			p_commit=>'F',
			 P_RESOURCE_ID=>l_resource_id,
			 p_application_id=>680,
			 p_responsibility_id=>null,
			 P_MASTER_ACCOUNT_ID=>p_master_account_id,
			 P_TO_ADDRESS_LIST=>p_sender,
			 p_cc_address_list=>null ,
			 p_bcc_address_list=>null,
			 P_SUBJECT=>l_subject,
			 P_SR_ID=>null,
			 P_CUSTOMER_ID=>null,
			 P_CONTACT_ID=>g_contact_id,
			 P_INTERACTION_ID=>p_int_id,
			 p_qualifiers =>l_qual_tbl     ,
			 P_MESSAGE_TYPE=>null,
			 P_ENCODING=>null,
			 P_CHARACTER_SET=>null,
			 p_option=>'A',
			 p_relationship_id=>g_relation_id,
			 X_OUTBOX_ITEM_ID=>l_outbox_id,
			 X_RETURN_STATUS=>l_ret_status,
			 X_MSG_COUNT=>l_msg_count,
			 X_MSG_DATA=>l_msg_data);
	if l_ret_status<>'S' THEN
		x_out_text:='Failed in createoutbox message '||l_text_data;
		raise ACK_FAILED;
	end if;
			IEM_OUTBOX_PROC_PUB.insertDocument(
 			   p_api_version_number=>1.0    ,
   			   p_outbox_item_id=>l_outbox_id,
                  p_document_source=>'MES'       ,
                  p_document_id =>p_document_id ,
                  X_RETURN_STATUS=>l_ret_status,
			   X_MSG_COUNT=>l_msg_count,
 			   X_MSG_DATA=>l_msg_data);
	if l_ret_status<>'S' THEN
		x_out_text:='Failed in insert document  '||l_text_data;
		raise ACK_FAILED;
	end if;
 				IEM_OUTBOX_PROC_PUB.submitOutboxMessage(
				    p_api_version_number=>1.0    ,
				    p_init_msg_list=>'F',
  				    p_commit  => 'F',
                        p_outbox_item_id=>l_outbox_id  ,
				    p_preview_bool=>'N',
                        X_RETURN_STATUS=>l_ret_status,
                        X_MSG_COUNT=>l_msg_count,
                        X_MSG_DATA=>l_msg_data);
	if l_ret_status<>'S' THEN
		x_out_text:='Failed in submit  request  '||l_text_data;
		raise ACK_FAILED;
	end if;
		x_status:='S';
		x_out_text:='Send Acknowledgement Successfully';
   EXCEPTION WHEN ACK_FAILED THEN
		x_status:='E';
    IF (l_msg_count >= 1) THEN
      --Only one error
      FND_MSG_PUB.Get(p_msg_index => FND_MSG_PUB.G_FIRST,
                      p_encoded=>'F',
                      p_data=>l_data,
                     p_msg_index_out=>l_msg_index_out);
      l_error_text:= substr(l_data,1,500);
      If (l_msg_count > 1) THEN
      --Display all the error messages
      	FOR j in  2..FND_MSG_PUB.Count_Msg LOOP
        	FND_MSG_PUB.Get(p_msg_index => FND_MSG_PUB.G_NEXT,
                        	p_encoded=>'F',
                        	p_data=>l_data,
                        	p_msg_index_out=>l_msg_index_out);
      	l_error_text:= l_error_text||substr(l_data,1,500);
      	END LOOP;
     END IF;
    END IF;
		x_out_text:=x_out_text||l_error_text;
   When Others then
		x_out_text:='Oracle Error During sendmail Processings '||sqlerrm;
		x_status:='E';
   END;
/* This Procedure is invoked for running the customised workflow.
It return the following status .'Y' Process futher . 'N' Not required
to process anymore . 'E' Returns an Error .
*/
PROCEDURE IEM_INVOKE_WORKFLOW(p_message_id in number,
						p_source_message_id in number,
  						p_message_size in number,
  						p_sender_name  in varchar2,
  						p_user_name in varchar2,
  						p_domain_name   in varchar2,
  						p_priority     in varchar2,
  						p_message_status in varchar2,
  						p_email_account_id in number,
						x_wfoutval	out NOCOPY varchar2,
               			x_status out NOCOPY varchar2,
						x_out_text out NOCOPY varchar2) IS

 PRAGMA autonomous_transaction;
 l_itemkey		varchar2(30);
 l_process			varchar2(1);
 l_class			number;
 l_stat			varchar2(10);
 l_outval			varchar2(200);
 l_out_text		varchar2(500);
 l_count			number;
 l_comp_id		number;	-- rt comps id
 l_wf_value		varchar2(500);
 l_ret_status		varchar2(10);
 l_msg_count		number;
 l_msg_data		varchar2(500);
 l_uid			number;
 l_status			varchar2(100);
 l_category_id     AMV_SEARCH_PVT.amv_number_varray_type:=AMV_SEARCH_PVT.amv_number_varray_type();
 CUSTOM_WF_EXCEP    EXCEPTION;
 MOVE_MSG_EXCEP    EXCEPTION;
 PROC_ERROR    EXCEPTION;
 PROCESS_BEFORE    EXCEPTION;
 BEGIN
	-- Check whether the Workflow is already called for this message or not.
	-- May be called by a profile value later
	begin
		select value into l_outval
		from iem_comp_rt_stats
		where type='WORKFLOW' AND param=to_char(p_message_id);
		raise PROCESS_BEFORE;
	exception when others then
		null;
	end;
-- Call the specific search API
	BEGIN
			select classification_id into l_class
			from iem_email_classifications
			where message_id=p_message_id
			and score = (select max(score) from iem_email_classifications
			where message_id=p_message_id)
			and rownum=1;
	IEM_EMAIL_PROC_PVT.IEM_WF_SPECIFICSEARCH(
    					p_message_id  ,
    					p_email_account_id ,
    					l_class,
					l_category_id,
					null,		-- KB search based on profile value
    					l_stat ,
    					l_out_text);
    EXCEPTION WHEN OTHERS THEN
		NULL;
    END;
   SELECT TO_CHAR(iem.IEM_MAILPREPROCWF_S1.nextval)
   INTO l_itemkey
   FROM dual;


	IEM_MAILPREPROCWF_PUB.IEM_STARTPROCESS(
			WorkflowProcess=>'MAILPREPROC',
  			ItemType=>'IEM_MAIL',
  			ItemKey=>l_itemkey,
  			p_itemuserkey =>'iemmail_preproc',
  			p_msgid =>p_message_id,
  			p_msgsize =>p_message_size,
  			p_sender=>p_sender_name,
  			p_username =>p_user_name,
  			p_domain=>p_domain_name,
  			p_priority=>p_priority,
  			p_msg_status =>p_message_status,
  			p_email_account_id=>p_email_account_id,
			p_flow=>'N',
			x_outval=>l_outval,
			x_process=>l_process);

		IF	IEM_Mailpreprocwf_PUB.G_STAT='E' then
			raise CUSTOM_WF_EXCEP;
		end if;

	IEM_COMP_RT_STATS_PVT.create_item(p_api_version_number =>1.0,
                        p_init_msg_list => FND_API.G_FALSE,
                        p_commit         => FND_API.G_FALSE,
                        p_type => 'WORKFLOW',
                        p_param => p_message_id,
                        p_value => l_outval,
                        x_return_status  => l_stat,
                        x_msg_count      => l_count,
                        x_msg_data      => l_msg_data
                        );
		if l_stat<>'S' THEN
			x_out_text:='Error while logging WF Return Value';
			raise PROC_ERROR;
		end if;
	x_wfoutval:=l_outval;
	x_status:=l_process;
	x_out_text:='Complete WF Processing ';
	commit;
	IF l_process='N' THEN		-- move the message to /Resolved folder
			null;		-- incorporate appropriate changes later
	END IF;
 EXCEPTION WHEN CUSTOM_WF_EXCEP THEN
	x_status:='E';
	x_out_text:=' Workflow Process Returns Error '||sqlerrm;
	rollback;
 WHEN MOVE_MSG_EXCEP THEN
	x_status:='E';
	x_out_text:='Error while moving the message to Resolved Folder';
	rollback;
 WHEN PROC_ERROR THEN
	x_status:='E';
	rollback;
 WHEN PROCESS_BEFORE THEN
	x_status:='S';
	x_wfoutval:=l_outval;
	x_out_text:='Complete WF Processing ';
	commit;
 WHEN OTHERS THEN
	x_status:='E';
	x_out_text:=' Oracle Error  Customise WF Processing '||sqlerrm;
	rollback;
 END;

PROCEDURE		IEM_SRSTATUS_UPDATE(p_sr_id	in number,
							p_status_id in number,
							p_email_rec in iem_rt_preproc_emails%rowtype,
							x_status  out NOCOPY varchar2,
							x_out_text out NOCOPY varchar2) IS

l_service_request_rec          CS_ServiceRequest_PUB.service_request_rec_type;
l_request_id  NUMBER;
l_object_version_number  NUMBER;
l_request_number VARCHAR2(64);
l_sr_number		number;
l_sr_status		varchar2(100);
l_status_id		number;
l_party_id		number;
l_ret_status		varchar2(10);
l_msg_count		number;
l_count		number;
l_interaction_id		number;
l_msg_data		varchar2(500);
 l_out_text		varchar2(500);
 l_uid			number;
 l_status_flag		varchar2(100);
 l_str				varchar2(1000);
Type get_data is REF CURSOR;
c1		get_data;
SR_STATUS_UPD_FAIL	EXCEPTION;
BEGIN
			-- code for auto sr update
		x_status:='S';
				-- select object version number
		BEGIN
			open c1 for
				'select object_version_number,status_flag from cs_incidents_all_b where incident_id=:sr_id' using p_sr_id;
LOOP
	fetch c1 into l_object_version_number,l_status_flag;
	exit;
end loop;
		EXCEPTION WHEN OTHERS THEN
			x_out_Text:='Oracle Error for SR# '||p_sr_id|| 'While selecting object version number '||sqlerrm;
				raise SR_STATUS_UPD_FAIL;
		END;
		IF (l_object_version_number is null) OR (l_status_flag is null) then
			x_out_text:='Invalid  SR ID In the Tag Data # '||p_sr_id;
			raise SR_STATUS_UPD_FAIL;
		END IF;
		IF l_status_flag<>'C' THEN		-- SR is not closed so we can update
			l_status_id:=p_status_id;
 		     IEM_ServiceRequest_PVT.Update_Status_Wrap
  				( p_api_version =>2.0,
    				p_init_msg_list =>fnd_api.g_true,
				p_commit => fnd_api.g_false,
                    p_resp_appl_id  => TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
                    p_resp_id       => TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
                   	p_user_id		  =>TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),
       			x_return_status =>l_ret_status,
    				x_msg_count=>l_msg_count,
    				x_msg_data =>l_msg_data,
    				p_request_id =>p_sr_id,
				p_object_version_number =>l_object_version_number,
				p_status_id=>l_status_id,
				p_status=>l_sr_status,
 				x_interaction_id=>l_interaction_id);
				IF l_ret_status<>'S' THEN
				x_out_text:='SR update Status Api fails for SR# '||p_sr_id;
      FND_MSG_PUB.Get(p_msg_index => FND_MSG_PUB.G_FIRST,
                      p_encoded=>'F',
                      p_data=>l_str,
                     p_msg_index_out=>l_msg_count);
				raise SR_STATUS_UPD_FAIL;
				END IF;
		x_status:='S';
		x_out_text:='Successfully Update the SR '||p_sr_id;
		ELSE
			x_status:='E';
			x_out_text:='SR '||p_sr_id||' is Closed  Hence Not updated ';
		END IF;
EXCEPTION WHEN SR_STATUS_UPD_FAIL THEN
		x_status:='E';
		x_out_text:=l_str;
WHEN OTHERS THEN
	x_out_text:='Error Encoutered While updating status of SR# '||p_sr_id||sqlerrm;
	x_status:='E';
end ;

PROCEDURE IEM_CLASSIFICATION_PROC(
				p_email_account_id	in number,
				p_keyval   in iem_route_pub.keyVals_tbl_type,
			x_rt_classification_id		out NOCOPY number,
			x_status		out NOCOPY varchar2,
		     x_out_text	out NOCOPY  varchar2) IS

	l_ret_status			varchar2(10);
	l_msg_count			number;
	l_msg_data			varchar2(500);
	CLASS_EXCEPTION		EXCEPTION;
BEGIN
	x_status:='S';
	IEM_ROUTE_CLASS_PUB.CLASSIFY(
	p_api_version_number=>1.0,
	p_keyVals_tbl=>p_keyval,
	p_accountId=>p_email_account_id,
	x_classificationId=>x_rt_classification_id,
	x_return_status=>l_ret_status,
	x_msg_count=>l_msg_count,
	x_msg_data=>l_msg_data);
	IF l_ret_status <>'S' THEN
	x_out_text:='classification engine return Error abandoning further Processing ';
		raise class_exception;
	END IF;
	x_status:='S';
	x_out_text:='Successfully Processed Classification Engine and Returned Classification Id '||x_rt_classification_id;
EXCEPTION
	WHEN class_exception THEN
		x_status:='E';
	WHEN OTHERS THEN
		x_status:='E';
	x_out_text:='Classification Processing Encountered Oracle Error '||sqlerrm;
END IEM_CLASSIFICATION_PROC;

PROCEDURE IEM_ROUTING_PROC(
				p_email_account_id	in number,
				p_keyval   in iem_route_pub.keyVals_tbl_type,
				x_routing_group_id		out NOCOPY number,
					x_status		out NOCOPY varchar2,
					 x_out_text	out NOCOPY  varchar2) IS
	KeyValuePairs 	iem_route_pub.KeyVals_tbl_type;
	l_counter				number;
	l_ret_status			varchar2(10);
	l_msg_count			number;
	l_msg_data			varchar2(500);
	ROUTE_EXCEPTION		EXCEPTION;
BEGIN
		IEM_ROUTE_PUB.ROUTE(
				P_API_VERSION_NUMBER =>1.0,
				P_KEYVALS_TBL =>p_keyval,
				P_ACCOUNTID =>p_email_account_id,
				X_GROUPID =>x_routing_group_id,
				X_RETURN_STATUS  =>l_ret_status,
				X_MSG_COUNT =>l_msg_count,
				X_MSG_DATA  =>l_msg_data);
	IF l_ret_status <>'S' THEN
	x_out_text:='Routing engine return Error abandoning further Processing ';
		raise route_exception;
	END IF;
	x_status:='S';
	x_out_text:='Successfully Processed Routing Engine and Returned Group Id '||x_routing_group_id;
EXCEPTION
	WHEN route_exception THEN
		x_status:='E';
	WHEN OTHERS THEN
		x_status:='E';
	x_out_text:='Routing Processing Encountered Oracle Error '||sqlerrm;
END IEM_ROUTING_PROC;

PROCEDURE IEM_PROC_IH(
				p_type		in varchar2,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
				p_action		in varchar2,		-- ADD/UPDATE/CLOSE
 				p_interaction_rec IN       JTF_IH_PUB.interaction_rec_type,
				p_activity_rec      IN     JTF_IH_PUB.activity_rec_type,
				p_media_lc_rec IN  JTF_IH_PUB.media_lc_rec_type,
				p_media_rec	IN  JTF_IH_PUB.media_rec_type,
				x_id			OUT NOCOPY NUMBER,
				x_status		out NOCOPY varchar2,
			     x_out_text	out NOCOPY  varchar2) IS
	l_media_id		number;
	l_milcs_id		number;
	l_interaction_id		number;
 	l_activity_rec        JTF_IH_PUB.activity_rec_type;
	l_activity_id		number;
	l_ret_status		varchar2(10);
	l_msg_data		varchar2(1500);
	l_data		varchar2(1500);
	l_error_text		varchar2(1500):=' ';
	l_msg_count		number;
	l_msg_index_out		number;
	IH_EXCEPTION		EXCEPTION;
BEGIN
	if p_type='MEDIA' THEN
		if p_action='ADD' THEN
			JTF_IH_PUB.Open_MediaItem(1.0,
                          'T',
                          'F',
					TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
					TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
                         nvl(TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),-1),
					TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),
              			l_ret_status,
                  		l_msg_count,
                    	l_msg_data,
            			p_media_rec,
              			l_media_id);
					if l_ret_status<>'S' then
						x_out_text:='Error While Creating Media Item '||sqlerrm;
						raise IH_EXCEPTION;
					else
						x_id:=l_media_id;
					end if;

		  elsif p_action='UPDATE' THEN

  				JTF_IH_PUB.Update_MediaItem( 1.0,
						'T',
						'F',
						TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
						TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
						nvl(TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),-1),
						TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),
						l_ret_status,
						l_msg_count,
						l_msg_data,
						p_media_rec);
					if l_ret_status<>'S' then
						x_out_text:='Error While Updating Media Item ';
						raise IH_EXCEPTION;
					end if;
		  elsif p_action='CLOSE' THEN

  				JTF_IH_PUB.Close_MediaItem( 1.0,
						'T',
						'F',
						TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
						TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
						nvl(TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),-1),
						TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),
						l_ret_status,
						l_msg_count,
						l_msg_data,
						p_media_rec);
					if l_ret_status<>'S' then
						x_out_text:='Error While Closing Media Item ';
						raise IH_EXCEPTION;
					end if;
		  end if;
	elsif p_type='MLCS' THEN
		if p_action='ADD' THEN
  			JTF_IH_PUB.Add_MediaLifeCycle( 1.0,
						'T',
						'F',
						TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
						TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
						nvl(TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),-1),
						TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),
						l_ret_status,
						l_msg_count,
						l_msg_data,
						p_media_lc_rec,
						l_milcs_id);

					if l_ret_status<>'S' then
						x_out_text:='Error While Creating Media Life Cycle ';
						raise IH_EXCEPTION;
					else
						x_id:=l_milcs_id;
					end if;
		elsif p_action='UPDATE' THEN
  			JTF_IH_PUB.Update_MediaLifeCycle( 1.0,
						'T',
						'F',
						TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
						TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
						nvl(TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),-1),
						TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),
						l_ret_status,
						l_msg_count,
						l_msg_data,
						p_media_lc_rec);
					if l_ret_status<>'S' then
						x_out_text:='Error While Updating Media Life Cycle ';
						raise IH_EXCEPTION;
					end if;
		end if;
	elsif p_type='INTERACTION' THEN
		IF p_action='ADD' THEN

     		JTF_IH_PUB.Open_Interaction( p_api_version     => 1.1,
                                  p_resp_appl_id    => TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
                                  p_resp_id         => TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
                         		p_user_id		  =>nvl(TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),-1),
							p_login_id	  =>TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),
                                  x_return_status   => l_ret_status,
                                  x_msg_count       => l_msg_count,
                                  x_msg_data        => l_msg_data,
                                  x_interaction_id  => l_interaction_id,
                                  p_interaction_rec => p_interaction_rec
                                 );
					if l_ret_status<>'S' then
						x_out_text:='Error While Creating Interaction ';
						raise IH_EXCEPTION;
					else
						   x_id:=l_interaction_id;
					end if;
		ELSIF p_action='UPDATE' THEN
     		JTF_IH_PUB.Update_Interaction( p_api_version     => 1.1,
                                  p_resp_appl_id    => TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
                                  p_resp_id         => TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
                         		p_user_id		  =>nvl(TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),-1),
							p_login_id	  =>TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),
                                  x_return_status   => l_ret_status,
                                  x_msg_count       => l_msg_count,
                                  x_msg_data        => l_msg_data,
                                  p_interaction_rec => p_interaction_rec
                                 );
					IF l_ret_status<>'S' THEN
						x_out_text:='Error While Updating Interaction ';
						raise IH_EXCEPTION;
					END IF;
		ELSIF p_action='CLOSE' THEN
     		JTF_IH_PUB.Close_Interaction( p_api_version     => 1.1,
                                  p_resp_appl_id    => TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
                                  p_resp_id         => TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
                         		p_user_id		  =>nvl(TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),-1),
							p_login_id	  =>TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),
                                  x_return_status   => l_ret_status,
                                  x_msg_count       => l_msg_count,
                                  x_msg_data        => l_msg_data,
                                  p_interaction_rec => p_interaction_rec);
					IF l_ret_status<>'S' THEN
						x_out_text:='Error While Closing Interaction ';
						raise IH_EXCEPTION;
					END IF;
		END IF;
	elsif p_type='ACTIVITY' THEN
		IF p_action='ADD' THEN
					l_activity_rec:=p_activity_rec;
				BEGIN
					select wu.outcome_id, wu.result_id, wu.reason_id INTO
 					l_activity_rec.outcome_id, l_activity_rec.result_id, l_activity_rec.reason_id
        				from jtf_ih_action_action_items aa, jtf_ih_wrap_ups wu
        				where aa.action_id =l_activity_rec.action_id
					and aa.action_item_id = l_activity_rec.action_item_id
        				and aa.default_wrap_id = wu.wrap_id;
				EXCEPTION WHEN OTHERS THEN
							NULL;
				END;
         		JTF_IH_PUB.Add_Activity(p_api_version     => 1.0,
                                 p_resp_appl_id  => TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
                                 p_resp_id       => TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
                         		p_user_id		  =>nvl(TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),-1),
							p_login_id	  =>TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),
                                 x_return_status => l_ret_status,
                                 x_msg_count     => l_msg_count,
                                 x_msg_data      => l_msg_data,
                                 p_activity_rec  => l_activity_rec,
                                 x_activity_id   => l_activity_id
                                 );
					if l_ret_status<>'S' then
						x_out_text:='Error While Creating Activity ';
						raise IH_EXCEPTION;
					else
						   x_id:=l_activity_id;
					end if;
		END IF;
	end if;
		x_Status:='S';
EXCEPTION
	WHEN IH_EXCEPTION THEN
		x_status:='E';
    IF (l_msg_count >= 1) THEN
      --Only one error
      FND_MSG_PUB.Get(p_msg_index => FND_MSG_PUB.G_FIRST,
                      p_encoded=>'F',
                      p_data=>l_data,
                     p_msg_index_out=>l_msg_index_out);
      l_error_text:= substr(l_data,1,500);
    END IF;
		x_out_text:=x_out_text||l_error_text;
	WHEN OTHERS THEN
		x_status:='E';
	x_out_text:='Interaction History  Processing Encountered Oracle Error '||sqlerrm;
END IEM_PROC_IH;

PROCEDURE		IEM_WRAPUP(p_interaction_id	in number,
					p_media_id		in number,
					p_milcs_id		in number,
					p_action		in varchar2,
					p_email_rec in iem_rt_preproc_emails%rowtype,
					p_action_id	in number,
					x_out_text		out NOCOPY varchar2,
					x_status  out NOCOPY varchar2) IS

l_media_rec	JTF_IH_PUB.media_rec_type;
l_interaction_rec        JTF_IH_PUB.interaction_rec_type;
l_stat			varchar2(10);
l_out_text		varchar2(500);
l_uid			number;
l_milcs_id		number;
l_interaction_id	number;
l_media_lc_rec 	JTF_IH_PUB.media_lc_rec_type;
l_action_id		number;
l_activity_rec        JTF_IH_PUB.activity_rec_type;
WRAPUP_ERROR		EXCEPTION;
l_ret_status		varchar2(10);
l_msg_data		varchar2(300);
l_msg_count		number;
begin
					-- Update the mail Processing Life Cycles
 							 l_media_lc_rec.milcs_id:=p_milcs_id;
							IEM_EMAIL_PROC_PVT.IEM_PROC_IH(
								p_type=>'MLCS'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
								p_action=>'UPDATE'		,		-- ADD/UPDATE/CLOSE
								p_interaction_rec=>l_interaction_rec,
								p_activity_rec=>l_activity_rec     ,
								p_media_lc_rec=>l_media_lc_Rec ,
								p_media_rec=>l_media_rec	,
								x_id=>l_milcs_id,
								x_status=>l_stat		,
			  				   x_out_text=>l_out_text	);

							IF l_stat<>'S' THEN
								x_out_text:=l_out_text;
								raise WRAPUP_ERROR;
							END IF;
		IF p_action is not null  THEN
		-- incase of auto redirect this is set to null
								l_interaction_rec.interaction_id:=p_interaction_id;
								BEGIN
									select wu.outcome_id, wu.result_id, wu.reason_id into
 									l_interaction_rec.outcome_id,
									l_interaction_rec.result_id,
									l_interaction_rec.reason_id
        								from jtf_ih_action_action_items aa, jtf_ih_wrap_ups wu
        								where aa.action_id =p_action_id
									and aa.action_item_id = 45
        								and aa.default_wrap_id = wu.wrap_id;
								EXCEPTION WHEN OTHERS THEN
									null;
								END;
								IEM_EMAIL_PROC_PVT.IEM_PROC_IH(
								p_type=>'INTERACTION'		,	-- MEDIA/ACTIVITY/MLCS/INTERACTION
								p_action=>'CLOSE'		,		-- ADD/UPDATE/CLOSE
								p_interaction_rec=>l_interaction_rec,
								p_activity_rec=>l_activity_rec     ,
								p_media_lc_rec=>l_media_lc_Rec ,
								p_media_rec=>l_media_rec	,
								x_id=>l_interaction_id,
								x_status=>l_stat		,
			  				     x_out_text=>l_out_text	);
								IF l_stat<>'S' THEN
									x_out_text:=l_out_text;
									raise WRAPUP_ERROR;
								END IF;
							--Closing the media Item
								l_media_rec.media_id:=p_media_id;
								IEM_EMAIL_PROC_PVT.IEM_PROC_IH(
									p_type=>'MEDIA'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
									p_action=>'CLOSE'		,		-- ADD/UPDATE/CLOSE
									p_interaction_rec=>l_interaction_rec,
									p_activity_rec=>l_activity_rec     ,
									p_media_lc_rec=>l_media_lc_Rec ,
									p_media_rec=>l_media_rec	,
									x_id=>l_interaction_id,
									x_status=>l_stat		,
			   			 		 	x_out_text=>l_out_text	);

								IF l_stat<>'S' THEN
									raise WRAPUP_ERROR;
								END IF;

							IEM_MAILITEM_PUB.ResolvedMessage (p_api_version_number=>1.0 ,
 		  	     				 p_init_msg_list=>'F'  ,
		    	     				 p_commit=>'F'	    ,
								 p_message_id=>p_email_rec.message_id,
								 p_action_flag=>p_action	,
			     				 x_return_status=>l_ret_status,
  		  	     				 x_msg_count=>l_msg_count ,
								 x_msg_data=>l_msg_data);
								IF l_ret_status<>'S' THEN
									l_out_text:='Error in Moving Message '||sqlerrm;
									raise WRAPUP_ERROR;
								END IF;
						END IF;		-- for p_action is not null
			x_status:='S';
EXCEPTION WHEN WRAPUP_ERROR THEN
		x_out_text:=l_out_text;
		x_status:='E';
WHEN OTHERS THEN
	x_out_text:='Oracle Error Encountered in Wrapup '||sqlerrm;
	x_status:='E';
end	IEM_WRAPUP;

PROCEDURE		IEM_AUTOREPLY(p_interaction_id	in number,
					p_media_id		in number,
					p_post_rec		in iem_rt_preproc_emails%rowtype,
					p_doc_tbl		in email_doc_tbl,
					p_subject		in varchar2,
 					P_TAG_KEY_VALUE_TBL in IEM_OUTBOX_PROC_PUB.keyVals_tbl_type,
 					P_CUSTOMER_ID in number,
 					P_RESOURCE_ID in number,
 					p_qualifiers in IEM_OUTBOX_PROC_PUB.QualifierRecordList,
					p_fwd_address in varchar2,
					p_fwd_doc_id in number,
					p_req_type in varchar2,
					x_out_text		out NOCOPY varchar2,
					x_status  out NOCOPY varchar2) IS
	l_outbox_id		number;
	l_ret_status		varchar2(100);
	l_msg_count		number;
	l_msg_data		varchar2(500);
	AUTOREPLY_ERROR	EXCEPTION;
	l_folder_name		varchar2(240);
	l_file_name		varchar2(256);
	l_ext_subject		varchar2(100);
	l_data			varchar2(500);
	l_msg_index_out		varchar2(10);
	l_qual_tbl		 IEM_OUTBOX_PROC_PUB.QualifierRecordList;
	l_error_text		varchar2(1000);
	l_dflt_sender		varchar2(250);
	l_sender			varchar2(256);
	l_from1			number;
	l_from2			number;
 	l_header_rec			iem_ms_base_headers%rowtype;
	l_notification_id	number;
BEGIN
select * into l_header_rec from iem_ms_base_headers
where message_id=p_post_rec.message_id;
	l_from1:=instr(l_header_rec.from_str,'<',1,1);
	l_from2:=instr(l_header_rec.from_str,'>',1,1);
	IF l_from1>0 then		-- From Address Contains Both Name and Address
		l_sender:=substr(l_header_rec.from_Str,l_from1+1,l_from2-l_from1-1);
	ELSE					-- From Address contains only Address
		l_sender:=l_header_rec.from_str;
	END IF;
if p_req_type='R' then			-- Autoreply
IEM_OUTBOX_PROC_PUB.createautoreply(p_api_version_number=>1.0,
 p_init_msg_list=>'F',
 p_commit=>'F',
 P_MEDIA_ID=>p_media_id,			--- Then next 3 parameter will be null
 P_RFC822_MESSAGE_ID =>null,
 p_folder_name=>null,
 P_MESSAGE_UID =>null,
 P_MASTER_ACCOUNT_ID=>p_post_rec.email_account_id,
 P_TO_ADDRESS_LIST=>l_sender,		-- need to pass sender name
 p_cc_address_list=>null ,
 p_bcc_address_list=>null,
 P_SUBJECT=>l_header_rec.subject,
 P_TAG_KEY_VALUE_TBL=>p_tag_key_value_tbl,
 P_CUSTOMER_ID=>p_customer_id,
 P_INTERACTION_ID=>p_interaction_id,
 P_RESOURCE_ID=>p_resource_id,
 p_qualifiers =>p_qualifiers ,
 p_contact_id=>g_contact_id,
 p_relationship_id=>g_relation_id,
 p_mdt_message_id=>p_post_rec.message_id,
 X_OUTBOX_ITEM_ID=>l_outbox_id,
 X_RETURN_STATUS=>l_ret_status,
 X_MSG_COUNT=>l_msg_count,
 X_MSG_DATA=>l_msg_data);
 IF l_ret_status<>'S' THEN
	x_out_text:='Error Encountered While Calling Create Autoreply';
	raise AUTOREPLY_ERROR;
 END IF;
 FOR i IN  p_doc_tbl.FIRST..p_doc_tbl.LAST LOOP
	IF p_doc_tbl(i).type='I' THEN
		IEM_OUTBOX_PROC_PUB.insertDocument(
   		 p_api_version_number=>1.0    ,
  		  p_outbox_item_id=>l_outbox_id,
  		  p_document_source=>'MES'       ,
   		 p_document_id =>p_doc_tbl(i).doc_id ,
		 X_RETURN_STATUS=>l_ret_status,
		 X_MSG_COUNT=>l_msg_count,
		 X_MSG_DATA=>l_msg_data);

		 IF l_ret_status<>'S' THEN
			x_out_text:='Error Encountered While Calling Insert Document ';
			raise AUTOREPLY_ERROR;
		 END IF;
	ELSIF p_doc_tbl(i).type='A' THEN

		SELECT fl.file_name
		INTO l_file_name
		FROM jtf_amv_items_tl b ,jtf_amv_attachments a ,fnd_lobs fl
		WHERE b.item_id = a.attachment_used_by_id
		and a.attachment_used_by='ITEM'
		AND a.file_id = fl.file_id
		AND b.item_id=p_doc_tbl(i).doc_id
		AND b.language=USERENV('LANG')
		and rownum=1;

        IEM_OUTBOX_PROC_PUB.attachDocument(p_api_version_number=>1.0,
                         p_init_msg_list=>FND_API.G_FALSE,
                         p_commit=>FND_API.G_TRUE,
                         p_outbox_item_id=>l_outbox_id,
                         p_document_source=>'MES',
                         p_document_id=>p_doc_tbl(i).doc_id,
                         p_binary_source=>NULL,
                         p_attachment_name=>l_file_name,
                         x_return_status=>l_ret_status,
                         x_msg_count=>l_msg_count,
                         x_msg_data=>l_msg_data
                        );
		 IF l_ret_status<>'S' THEN
			x_out_text:='Error Encountered While Calling Attach Document ';
			raise AUTOREPLY_ERROR;
		 END IF;
	END IF;
  END LOOP;
elsif p_req_type='N' then		-- Auto Notifications
	if l_header_rec.reply_to_str is not null then
		l_from1:=instr(l_header_rec.reply_to_str,'<',1,1);
		l_from2:=instr(l_header_rec.reply_to_str,'>',1,1);
	IF l_from1>0 then		-- From Address Contains Both Name and Address
		l_sender:=substr(l_header_rec.reply_to_str,l_from1+1,l_from2-l_from1-1);
	ELSE					-- From Address contains only Address
		l_sender:=l_header_rec.reply_to_str;
	END IF;
	END IF;
				IEM_OUTBOX_PROC_PUB.createSRAutoNotification(p_api_version_number=>1.0,
 													p_init_msg_list=>'F',
 													p_commit=>'F',
 													P_MEDIA_ID=>p_media_id,
 												P_MASTER_ACCOUNT_ID=>p_post_rec.email_account_id,
 												P_TO_ADDRESS_LIST=>l_sender,		-- need to pass sender name
 												p_cc_address_list=>null ,
 												p_bcc_address_list=>null,
 												P_SUBJECT=>l_header_rec.subject,
 												P_TAG_KEY_VALUE_TBL=>p_tag_key_value_tbl,
 												P_CUSTOMER_ID=>p_customer_id,
 												P_INTERACTION_ID=>fnd_api.g_miss_num,
 												P_RESOURCE_ID=>p_resource_id,
 												p_qualifiers =>p_qualifiers ,
 												p_contact_id=>g_contact_id,
 												p_relationship_id=>g_relation_id,
 												p_message_id=>p_post_rec.message_id,
												p_sr_id=>p_fwd_doc_id,
 												X_OUTBOX_ITEM_ID=>l_outbox_id,
 												X_RETURN_STATUS=>l_ret_status,
 												X_MSG_COUNT=>l_msg_count,
 												X_MSG_DATA=>l_msg_data);
 				IF l_ret_status<>'S' THEN
					x_out_text:='Error Encountered While Calling Create Autonotification';
      FND_MSG_PUB.Get(p_msg_index => FND_MSG_PUB.G_FIRST,
                      p_encoded=>'F',
                      p_data=>l_data,
                     p_msg_index_out=>l_msg_index_out);
					raise AUTOREPLY_ERROR;
 				END IF;
 FOR i IN  p_doc_tbl.FIRST..p_doc_tbl.LAST LOOP
 	l_notification_id:=p_doc_tbl(i).doc_id;
	EXIT;
 END LOOP;
		IEM_OUTBOX_PROC_PUB.insertDocument(
   		 p_api_version_number=>1.0    ,
  		  p_outbox_item_id=>l_outbox_id,
  		  p_document_source=>'MES'       ,
   		 p_document_id =>l_notification_id ,
		 X_RETURN_STATUS=>l_ret_status,
		 X_MSG_COUNT=>l_msg_count,
		 X_MSG_DATA=>l_msg_data);

		 IF l_ret_status<>'S' THEN
			x_out_text:='Error Encountered While Calling Insert Document ';
      FND_MSG_PUB.Get(p_msg_index => FND_MSG_PUB.G_FIRST,
                      p_encoded=>'F',
                      p_data=>l_data,
                     p_msg_index_out=>l_msg_index_out);
			raise AUTOREPLY_ERROR;
		 END IF;
 else
    				FND_MESSAGE.Set_Name('IEM','IEM_REDIRECT_EXT_HDR');
 				FND_MSG_PUB.Add;
 				l_ext_subject :=  FND_MSG_PUB.GET(FND_MSG_pub.Count_Msg,FND_API.G_FALSE);
				-- Get value for merge fields
    				FND_MESSAGE.Set_Name('IEM','IEM_ADM_AUTO_ACK_CUSTOMER');
 				FND_MSG_PUB.Add;
 				l_dflt_sender :=  FND_MSG_PUB.GET(FND_MSG_pub.Count_Msg,FND_API.G_FALSE);
 		IEM_EMAIL_PROC_PVT.IEM_GET_MERGEVAL(p_email_account_id=>p_post_rec.email_account_id,
				    p_mailer=>l_header_rec.from_str,	-- passing the sender name, sanjana rao, bug 8839425
				    p_dflt_sender=>l_dflt_sender	,
				    p_subject=>l_header_rec.subject,	--passing the subject, sanjana rao , bug 8839425
				    x_qual_tbl=> l_qual_tbl,
				    x_status=>l_ret_status,
				    x_out_text=>l_error_text);
					IEM_OUTBOX_PROC_PUB.autoForward(
    						p_api_version_number=>1.0    ,
    						p_init_msg_list=>'F'         ,
    						p_commit=>'F'                ,
    						p_media_id=>p_media_id,
    						p_rfc822_message_id=>null,
    						p_folder_name=>null       ,
    						p_message_uid=>null,
    						p_master_account_id=>p_post_rec.email_account_id ,
    						p_to_address_list=>p_fwd_address       ,
   						 p_cc_address_list=>null       ,
    						p_bcc_address_list=>null      ,
    						p_subject=>l_ext_subject||p_subject ,
    						p_tag_key_value_tbl=>p_tag_key_value_tbl ,
 						P_CUSTOMER_ID=>p_customer_id,
 						P_INTERACTION_ID=>p_interaction_id,
 						P_RESOURCE_ID=>p_resource_id,
 						p_qualifiers =>l_qual_tbl ,
 						p_contact_id=>g_contact_id,
 						p_relationship_id=>g_relation_id,
    						p_attach_inb=>'A',
						p_mdt_message_id=>p_post_rec.message_id,
			 			X_OUTBOX_ITEM_ID=>l_outbox_id,
			 			X_RETURN_STATUS=>l_ret_status,
			 			X_MSG_COUNT=>l_msg_count,
			 			X_MSG_DATA=>l_msg_data);
					IF l_ret_status<>'S' THEN
					  x_out_text:='Outbox Processing Return Error while creating a request for autoforward';
						raise AUTOREPLY_ERROR;
					END IF;
					IEM_OUTBOX_PROC_PUB.insertDocument(
   		 			p_api_version_number=>1.0    ,
  		  			p_outbox_item_id=>l_outbox_id,
  		 			 p_document_source=>'MES'       ,
   					 p_document_id =>p_fwd_doc_id ,
					 X_RETURN_STATUS=>l_ret_status,
					 X_MSG_COUNT=>l_msg_count,
					 X_MSG_DATA=>l_msg_data);

		 		IF l_ret_status<>'S' THEN
				  x_out_text:='Error Encountered While Calling Insert Document during autoforward';
					raise AUTOREPLY_ERROR;
				END IF;
 end if;
--submitting the request
				IEM_OUTBOX_PROC_PUB.submitOutboxMessage(
   				 p_api_version_number=>1.0    ,
				 p_init_msg_list=>'F',
				 p_commit=>'F',
  				  p_outbox_item_id=>l_outbox_id  ,
				    p_preview_bool=>'N',
				 X_RETURN_STATUS=>l_ret_status,
				 X_MSG_COUNT=>l_msg_count,
				 X_MSG_DATA=>l_msg_data);
		 IF l_ret_status<>'S' THEN
			x_out_text:='Error Encountered While Submitting Outbox Request';
      FND_MSG_PUB.Get(p_msg_index => FND_MSG_PUB.G_FIRST,
                      p_encoded=>'F',
                      p_data=>l_data,
                     p_msg_index_out=>l_msg_index_out);
			raise AUTOREPLY_ERROR;
		 END IF;
	x_status:='S';
	x_out_text:='Submit Request For Autoreply Successfully';
EXCEPTION WHEN AUTOREPLY_ERROR THEN
	x_status:='E';
	x_out_text:=x_out_text||l_data;
WHEN OTHERS THEN
	x_out_text:='Oracle Error Encountered '||sqlerrm||' in autoreply processing ';
	x_status:='E';
end IEM_AUTOREPLY;

 PROCEDURE IEM_GET_MERGEVAL(p_email_account_id in number,
				    p_mailer	in varchar2,
				    p_dflt_sender	in varchar2,
				    p_subject		in varchar2,
				    x_qual_tbl out nocopy  IEM_OUTBOX_PROC_PUB.QualifierRecordList,
				    x_status	out nocopy varchar2,
				    x_out_text	out nocopy varchar2) IS
	cursor c1 is select lookup_code,meaning
	from fnd_lookups
	where enabled_flag = 'Y'
	AND NVL(start_date_active, SYSDATE) <= SYSDATE
	AND NVL(end_date_active,SYSDATE) >= SYSDATE
	AND lookup_type ='IEM_MERGE_FIELDS'
	ANd lookup_code like 'ACK%';
	l_index		number;
	l_sender_name	 varchar2(250);
	l_qual_tbl		 IEM_OUTBOX_PROC_PUB.QualifierRecordList;
	l_from_name		iem_email_accounts.from_name%type;
	l_reply_address	iem_email_accounts.reply_to_address%type;
 begin
	select from_name,reply_to_address
	INTO l_from_name,l_reply_address
	from IEM_MSTEMAIL_ACCOUNTS
	where email_account_id=p_email_account_id;
	l_index:=instr(p_mailer,'<',1,1);
	IF l_index>0 then
		l_sender_name:=substr(p_mailer,1,l_index-1);
		l_sender_name:=replace(l_sender_name,'"','');
	else
		l_sender_name:=p_dflt_sender; -- need to be from profile
	end if;
		l_index:=0;
		x_qual_tbl.delete;
	FOR v1 IN c1 LOOP
	IF v1.lookup_code='ACK_SENDER_NAME' THEN
		l_index:=l_index+1;
		x_qual_tbl(l_index).qualifier_name:=v1.lookup_code;
		x_qual_tbl(l_index).qualifier_value:=l_sender_name;
	ELSIF v1.lookup_code='ACK_SUBJECT' THEN
		l_index:=l_index+1;
		x_qual_tbl(l_index).qualifier_name:=v1.lookup_code;
		x_qual_tbl(l_index).qualifier_value:=p_subject;
	ELSIF v1.lookup_code='ACK_RECEIVED_DATE' THEN
		l_index:=l_index+1;
		x_qual_tbl(l_index).qualifier_name:=v1.lookup_code;
		x_qual_tbl(l_index).qualifier_value:=to_char(sysdate,'DD-MON-YYYY');
	ELSIF v1.lookup_code='ACK_ACCT_FROM_NAME' THEN
			l_index:=l_index+1;
			x_qual_tbl(l_index).qualifier_name:=v1.lookup_code;
			x_qual_tbl(l_index).qualifier_value:=l_from_name;
	ELSIF v1.lookup_code='ACK_ACCT_EMAIL_ADDRESS' THEN
			l_index:=l_index+1;
			x_qual_tbl(l_index).qualifier_name:=v1.lookup_code;
			x_qual_tbl(l_index).qualifier_value:=l_reply_address;
	END IF;
	END LOOP;
		x_status:='S';
 exception when others then
	x_out_Text:='Error Occured While Retrieving Merge Data Value '||sqlerrm;
	x_status:='E';
end IEM_GET_MERGEVAL;
procedure IEM_PROCESS_INTENT(l_email_account_id in number,
					  l_msg_id	in number,
					  l_theme_status	out nocopy varchar2,
					  l_out_text	out nocopy varchar2)

is

l_ret	number;
l_ret1	number;
l_gclassid	number;
l_theme		varchar2(100);
l_count		number:=0;
l_counter		number:=0;
l_tcount	number;
l_markup_count		number;
l_theme_count		number;
l_markupcount	number;
l_class_id	number;
l_classification_id	number;
l_tclassid	number;
l_part		number;
l_index		number;
l_flag		number:=1;
l_errtext	varchar2(600);
l_qstr          varchar2(500);
l_tstr          varchar2(2000);
l_tclstr          varchar2(2000);
l_class	number;
l_first	varchar2(1);
l_val	number:=0;
l_match	varchar2(1):='F';
l_msg_data	varchar2(200);
l_data	iem_class_tbl_typ:=iem_class_tbl_typ();
l_errmsg	varchar2(200);
l_str	varchar2(200);
l_class_scr	varchar2(3500);
l_wtot		number:=0;
theme_proc_excep	EXCEPTION;
theme_proc_excep1	EXCEPTION;
l_text		varchar2(100);
l_status		varchar2(100);
l_class_str	varchar2(32000);
l_imt_string1	varchar2(4000);
l_imt_string	varchar2(32000);
l_occur		number;
x_stat		varchar2(10);
l_lang		varchar2(10);
l_theme_code		varchar2(50);
l_logmessage	varchar2(500);
l_level		varchar2(20):='STATEMENT';
l_tweight		number:=0;
l_rms		number;
l_class_count		number;
l_theme_buf	IEM_TEXT_PVT.theme_tAble;
l_token_buf	IEM_TEXT_PVT.token_table;
cursor c1 is
 SELECT a.intent_id, a.keyword,a.weight
 from iem_intent_dtls a,iem_account_intents b
WHERE   b.email_account_id=l_email_account_id
AND a.intent_id=b.intent_id
AND QUERY_RESPONSE='Q'
and weight>0
order by 1;
   CURSOR get_theme_csr IS
   SELECT keyword,weight FROM iem_intent_dtls
   where intent_id=l_class_id
   AND QUERY_RESPONSE='Q'
   and weight>0
   order by 2 desc;
begin
	l_theme_status:='S';
	select kem_flag,account_language
	INTO l_theme_code,l_lang
	FROM IEM_MSTEMAIL_ACCOUNTS
	WHERE EMAIL_ACCOUNT_ID=l_email_account_id;
		l_theme_buf.delete;
		l_token_buf.delete;
		IF l_theme_code=1 then	-- Theme processing
				iem_text_pvt.getthemes(l_msg_id,null,l_theme_buf,l_errmsg);
		ELSIF l_theme_code=2 then -- Token Processing
			iem_text_pvt.gettokens(l_msg_id,null,l_lang,l_token_buf,l_errmsg);
			IF l_token_buf.count>0 THEN
				l_counter:=1;
			FOR i in l_token_buf.FIRST..l_token_buf.LAST LOOP
				l_theme_buf(l_counter).theme:=l_token_buf(i).token;
				l_theme_buf(l_counter).weight:=null;
				l_counter:=l_counter+1;
			END LOOP;
			END IF;
		END IF;
		-- Need to Handle Error Processing
	l_val:=0;
		-- Create the classification String from the first top 10 theme
		l_class_str:=' ';

		IF l_theme_buf.count>0 then	-- Theme API return themes
		if g_statement_log then
			l_logmessage:='Number of  theme returned '||l_theme_buf.count ;
			 iem_logger(l_logmessage);
		end if;

			-- normalised using RMS --
			l_rms:=0;
			l_count:=0;
	  FOR l_ind in 1.. l_theme_buf.count LOOP
				l_count:=l_count+1;
				l_rms:= l_rms+power(l_theme_buf(l_ind).weight,2);
			EXIT when l_count=10;
			END LOOP;
			l_rms:=sqrt(l_rms);
	  FOR l_ind in 1.. l_theme_buf.count LOOP
		l_count:=l_count+1;
		l_theme_buf(l_ind).weight:=round(l_theme_buf(l_ind).weight/l_rms,2)*10;
			EXIT when l_count=10;
			END LOOP;
	-- End of normalisation Using RMS
	  FOR l_ind in 1.. l_theme_buf.count LOOP
		l_class_str:=l_class_str||'about ('||l_theme_buf(l_ind).theme||'),';
				l_count:=l_count+1;
			END LOOP;
		ELSE
	if g_statement_log then
			l_logmessage:='No themes  for  OES Message '||l_msg_id;
			 iem_logger(l_logmessage);
	end if;
			raise theme_proc_excep1;	-- Theme API return zero Themes
		END IF;
		l_count:=0;
FOR v1 in c1 loop
      FOR l_ind in l_theme_buf.FIRST .. l_theme_buf.LAST LOOP
-- fix for 12.1.1 bug 7584830 to make intent case insensitive
IF upper(v1.keyword)=upper(l_theme_buf(l_ind).theme) then
IF (l_class<>v1.intent_id) and (l_class is not null) then
	l_data.extend;
	l_data(l_data.count):=iem_class_obj_typ(l_class,l_val);
	l_val:=0;
 END IF;
          l_val:=v1.weight+nvl(l_val,0);
		l_wtot:=l_wtot+l_val;
		l_class:=v1.intent_id;
END IF;
	END LOOP;
END LOOP;
	if l_val<>0 then
	l_data.extend;
	l_data(l_data.count):=iem_class_obj_typ(l_class,l_val);
	l_wtot:=l_wtot+l_val;
	end if;
l_class_count:=1;
		g_topclass:=null;
		g_topscore:=null;
	  l_wtot:=0;
	 FOR x in (select * from the(select cast(l_data as iem_class_tbl_typ)
	  from dual)a where score>0 and rownum<8 order by score desc)
	  LOOP
		l_wtot:=l_wtot+x.score;
	  END LOOP;
	 FOR x in (select * from the(select cast(l_data as iem_class_tbl_typ)
	  from dual)a where score>0 and rownum<8 order by score desc)
	  LOOP
		x.score:=x.score*100/l_wtot;
IF x.score > 0 THEN			 -- -ve Classification score not allowed Start
	IF x.score>100 THEN
		x.score:=100;
	END IF;
	IF l_gclassid is null then
	l_gclassid:=x.classification_id;
	g_topscore:=x.score;
	BEGIN
	select intent into g_topclass
	from iem_intents
	where intent_id=l_gclassid;
	EXCEPTION WHEN OTHERS THEN
		null;
	END;
	end if;
		l_classification_id:=x.classification_id;
		l_imt_string:=' ';
		l_count:=1;
		l_class_str:=substr(l_class_str,1,length(l_class_str)-1);
          iem_eml_classifications_pvt.create_item(
          p_api_version_number=>1.0,
		p_init_msg_list=>'F',
		p_commit=>'F',
          p_email_account_id=>l_email_account_id,
          p_classification_id=>x.classification_id,
          p_score=>x.score,
          p_message_id=>l_msg_id,
		p_class_string=>l_class_str,
               p_CREATED_BY =>TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),
               p_CREATION_DATE=> SYSDATE,
               p_LAST_UPDATED_BY=>TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ,
               p_LAST_UPDATE_DATE=>SYSDATE,
               p_LAST_UPDATE_LOGIN=>TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ ID')) ,
          x_return_Status=>l_status,
          x_msg_count=>l_count,
          x_msg_data=>l_msg_data);
     l_class_count:=l_class_count+1;
 END IF;  				-- -ve Classification score not allowed end
     EXIT when l_class_count>7 ;
     END LOOP;
	l_theme_status:='S';
exception
  when theme_proc_excep1 then
	l_theme_status:='S';
  when theme_proc_excep then
	l_theme_status:='E';
  when others then
		l_theme_status:='E';
	if g_exception_log then
			l_logmessage:='Oracle Error Encountered in IEM_THEMEPROC Procedure  for  OES Message '||l_msg_id||'  '||sqlerrm;
			iem_logger(l_logmessage);
	end if;
		l_out_text:=l_out_text||' Oracle Error '||sqlerrm|| 'While theme classification processing for message id '||l_msg_id;
end IEM_PROCESS_INTENT;
PROCEDURE ReprocessAutoreply(p_api_version_number    IN   NUMBER,
                   p_init_msg_list  IN   VARCHAR2 ,
                   p_commit      IN   VARCHAR2 ,
                   p_media_id in number,
		   		p_interaction_id	in number,
	           	p_customer_id	in number,
	           	p_contact_id	in number,
	           	p_relationship_id	in number,
                   x_return_status    OUT NOCOPY      VARCHAR2,
                   x_msg_count              OUT NOCOPY           NUMBER,
                   x_msg_data OUT NOCOPY      VARCHAR2) IS

	l_header_rec		iem_ms_base_headers%rowtype;
	l_mail_rec		iem_rt_proc_emails%rowtype;
	l_class_val_tbl		IEM_ROUTE_PUB.keyVals_tbl_type;
	l_counter		number;
	l_message_id			number;
   l_top_intent	varchar2(50);
   l_top_score		number;
 cursor c_intent is select a.intent,b.score from
 iem_intents a,iem_email_classifications b
 where b.message_id=l_message_id
 and a.intent_id=b.classification_id;
g_statement_log	boolean;		-- Statement Level Logging
 l_intent_str			varchar2(700);
 l_index1				number;
 l_index2				number;
	l_api_name	varchar2(100):='ReprocessAutoreply';
	l_media_rec	JTF_IH_PUB.media_rec_type;
	l_kb_rank		number;
	l_api_version_number	number;
 l_rt_media_item_id		number;
 l_rt_interaction_id	number;
 l_milcs_id			number;
 l_intent_counter		number;
 	l_media_lc_rec 		JTF_IH_PUB.media_lc_rec_type;
 	l_interaction_rec        JTF_IH_PUB.interaction_rec_type;
 	l_activity_rec        JTF_IH_PUB.activity_rec_type;
	l_Stat		varchar2(100);
 l_auto_flag		varchar2(10);
 l_encrypted_id		varchar2(100);
 l_ret_status			varchar2(10);
 l_search			varchar2(10);
 l_msg_count			number;
 l_msg_data			varchar2(255);
l_tag_keyval			IEM_TAGPROCESS_PUB.keyVals_tbl_type;
l_folder_name			varchar2(255);
l_from_folder			varchar2(255);
l_agentid				number;
	l_autoproc_result		varchar2(1);
	l_param_rec_tbl		IEM_RULES_ENGINE_PUB.parameter_tbl_type;
	l_action				varchar2(50);
	l_rule_id			number;
	l_search_type		varchar2(100);
	l_repos			varchar2(100);
	l_cm_cat_id		number;	-- store the category for MES category based mapping
   l_category_id     AMV_SEARCH_PVT.amv_number_varray_type:=AMV_SEARCH_PVT.amv_number_varray_type();
	l_cat_counter		number;
	l_group_id		number;
	l_status			varchar2(10);
	l_out_text		varchar2(255);
	l_uid			number;
	cursor c_class_id is
	select classification_id from iem_email_classifications
	where message_id=l_message_id
	order by score desc;
	l_start_search		number;
	ABORT_REPROCESSING	EXCEPTION;
	l_logmessage		varchar2(1000);
	l_level			varchar2(20);
   cursor c_item is select ib.item_id,ib.item_name,ib.last_update_date
   from   amv_c_chl_item_match cim,jtf_amv_items_vl ib
   where  cim.channel_category_id = l_cm_cat_id
   and   cim.channel_id is null
   and   cim.approval_status_type ='APPROVED'
   and   cim.table_name_code ='ITEM'
   and   cim.available_for_channel_date <= sysdate
   and   cim.item_id = ib.item_id
   and    nvl(ib.effective_start_date, sysdate) <= sysdate + 1
   and   nvl(ib.expiration_date, sysdate) >= sysdate;
   l_email_user_name		varchar2(500);
   l_email_domain_name		varchar2(500);
   l_email_address		varchar2(500);
   l_from1		number;
   l_from2		number;
   l_sender		varchar2(500);

begin
	l_api_version_number:=1.0;
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
	l_level:='STATEMENT';
		FND_LOG_REPOSITORY.init(null,null);
		g_statement_log:= fnd_log.test(FND_LOG.LEVEL_STATEMENT,'IEM.PLSQL.iem_email_proc_pvt');
	SAVEPOINT processautoreply;
		-- Find the record from iem_rt_proc_emails  based on media id
		BEGIN
		select * into l_mail_rec from iem_rt_proc_emails
		where ih_media_item_id=p_media_id and msg_status='AUTOREPLY';
		EXCEPTION WHEN OTHERS THEN
	if g_exception_log then
		l_logmessage:='Error while selecting Message For re-processing '||sqlerrm;
		iem_logger(l_logmessage);
	end if;
			raise abort_reprocessing;
		END;

	select * into l_header_Rec
	from iem_ms_base_headers
	where message_id=l_mail_Rec.message_id;

	select user_name,email_address
	into l_email_user_name,l_email_address
	from iem_mstemail_accounts
	where email_account_id=l_mail_rec.email_account_id;
	l_email_domain_name:=substr(l_email_address,instr(l_email_address,'@',1)+1,length(l_email_address));
	l_from1:=instr(l_header_rec.from_str,'<',1,1);
	l_from2:=instr(l_header_rec.from_str,'>',1,1);
	IF l_from1>0 then		-- From Address Contains Both Name and Address
		l_sender:=substr(l_header_rec.from_Str,l_from1+1,l_from2-l_from1-1);
	ELSE					-- From Address contains only Address
		l_sender:=l_header_rec.from_str;
	END IF;

		-- Create the set of Key Value pairs to be passed to Rules Engine for Document Retrieval and Routing.
   For v1 in c_intent LOOP
	l_intent_str:=nvl(l_intent_str,' ')||v1.intent;
	if l_top_intent is null then
		l_top_intent:=v1.intent;
		l_top_score:=v1.score;
     end if;
   END LOOP;
		l_counter:=1;
		l_class_val_tbl.delete;
	l_class_val_tbl(l_counter).key:='IEMNMESSAGESIZE';
	l_class_val_tbl(l_counter).value:=l_header_rec.message_size;
	l_class_val_tbl(l_counter).datatype:='N';
		l_counter:=l_counter+1;
	l_class_val_tbl(l_counter).key:='IEMSSENDERNAME';
	l_class_val_tbl(l_counter).value:=l_sender;
	l_class_val_tbl(l_counter).datatype:='S';
		l_counter:=l_counter+1;
	l_class_val_tbl(l_counter).key:='IEMSUSERACCTNAME';
	l_class_val_tbl(l_counter).value:=l_email_user_name;
	l_class_val_tbl(l_counter).datatype:='S';
		l_counter:=l_counter+1;
	l_class_val_tbl(l_counter).key:='IEMSDOMAINNAME';
	l_class_val_tbl(l_counter).value:=l_email_domain_name;
	l_class_val_tbl(l_counter).datatype:='S';
	/* this is missing for the time being
		l_counter:=l_counter+1;
	l_class_val_tbl(l_counter).key:='IEMSPRIORITY';
	l_class_val_tbl(l_counter).value:=l_post_rec.priority;
	l_class_val_tbl(l_counter).datatype:='S';
	*/
		l_counter:=l_counter+1;
	l_class_val_tbl(l_counter).key:='IEMSSUBJECT';
	l_class_val_tbl(l_counter).value:=l_header_rec.subject;
	l_class_val_tbl(l_counter).datatype:='S';
		l_counter:=l_counter+1;
	l_class_val_tbl(l_counter).key:='IEMDRECEIVEDDATE';
	l_class_val_tbl(l_counter).value:=to_char(l_mail_rec.received_date,'YYYYMMDD');
	l_class_val_tbl(l_counter).datatype:='D';
		l_counter:=l_counter+1;
	l_class_val_tbl(l_counter).key:='IEMTRECEIVEDTIME';
	l_class_val_tbl(l_counter).value:=to_char(l_mail_rec.received_date,'HH24:MI:SS');
	l_class_val_tbl(l_counter).datatype:='T';
		l_counter:=l_counter+1;
	l_class_val_tbl(l_counter).key:='IEMSEMAILINTENT';
	l_class_val_tbl(l_counter).value:=l_top_intent;
	l_class_val_tbl(l_counter).datatype:='S';
		l_counter:=l_counter+1;
	l_class_val_tbl(l_counter).key:='IEMNSCOREPERCENT';
	l_class_val_tbl(l_counter).value:=l_top_score;
	l_class_val_tbl(l_counter).datatype:='N';
		l_counter:=l_counter+1;
	l_class_val_tbl(l_counter).key:='IEMSLANGUAGE';
	l_class_val_tbl(l_counter).value:=l_header_rec.language;
	l_class_val_tbl(l_counter).datatype:='S';
		l_counter:=l_counter+1;
	l_class_val_tbl(l_counter).key:='IEMSORGANIZATION';
	l_class_val_tbl(l_counter).value:=l_header_rec.organization;
	l_class_val_tbl(l_counter).datatype:='S';
		l_counter:=l_counter+1;
	l_class_val_tbl(l_counter).key:='IEMDSYSTEMDATE';
	l_class_val_tbl(l_counter).value:=to_char(sysdate,'YYYYMMDD');
	l_class_val_tbl(l_counter).datatype:='D';
		l_counter:=l_counter+1;
	l_class_val_tbl(l_counter).key:='IEMTSYSTEMTIME';
	l_class_val_tbl(l_counter).value:=to_char(sysdate,'HH24:MI:SS');
	l_class_val_tbl(l_counter).datatype:='T';
		l_counter:=l_counter+1;
	l_class_val_tbl(l_counter).key:='IEMSTOADDRESS';
	l_class_val_tbl(l_counter).value:=l_header_rec.to_str;
	l_class_val_tbl(l_counter).datatype:='S';

-- New KEYVALUE Pair Containing All Intents Changes MAde for MP-R By RT on 08/01/03
		l_counter:=l_counter+1;
	l_class_val_tbl(l_counter).key:='IEMSALLINTENTS';
	l_class_val_tbl(l_counter).value:=l_intent_str;
	l_class_val_tbl(l_counter).datatype:='S';
-- Retrieving the Tag Data if any present ..
	l_tag_keyval.delete;
	l_search:='[REF:';
 l_index1:=instr(l_header_rec.subject,l_search,1,1);
 l_index2:=instr(substr(l_header_rec.subject,l_index1+length(l_search),length(l_header_rec.subject)-1),']',1,1);
 IF (l_index1 <> 0) and (l_index2<>0) THEN
l_encrypted_id:=ltrim(substr(l_header_rec.subject,l_index1+length(l_search),l_index2-1));
-- Reset the Tag
	IEM_ENCRYPT_TAGS_PVT.RESET_TAG
             (p_api_version_number=>1.0,
              p_message_id=>l_mail_rec.message_id,
              x_return_status=>l_ret_status ,
              x_msg_count=>l_msg_count,
              x_msg_data=>l_msg_data);

	IF l_ret_status<>'S' THEN
	if g_error_log then
		l_logmessage:='Error while Resetting Tag For Rerouted Message';
		iem_logger(l_logmessage);
	end if;
	END IF;
			IEM_TAGPROCESS_PUB.GETTAGVALUES
					(p_Api_Version_Number=>1.0,
					 p_encrypted_id =>l_encrypted_id,
        				p_message_id=>l_mail_rec.message_id,
        				x_key_value=>l_tag_keyval,
        				x_msg_count=>l_msg_count,
        				x_return_status=>l_ret_status,
        				x_msg_data=>l_msg_data);
	IF l_ret_status<>'S' THEN
	if g_error_log then
	l_logmessage:='Error while Calling Tag Processing Api while reprocessing autoreplied message';
		iem_logger(l_logmessage);
		end if;
		raise abort_reprocessing;
	END IF;
  END IF;
	IF p_customer_id is not null THEN
		l_counter:=l_counter+1;
		l_class_val_tbl(l_counter).key:='IEMNCUSTOMERID';
		l_class_val_tbl(l_counter).value:=p_customer_id;
		l_class_val_tbl(l_counter).datatype:='N';
	END IF;

   IF l_tag_keyval.count>0 THEN
	FOR j in l_tag_keyval.FIRST..l_tag_keyval.LAST LOOP
		l_counter:=l_counter+1;
	l_class_val_tbl(l_counter).key:=l_tag_keyval(j).key;
	l_class_val_tbl(l_counter).value:=l_tag_keyval(j).value;
	l_class_val_tbl(l_counter).datatype:=l_tag_keyval(j).datatype;
	-- Check for Agent Id if exists in TAG
			IF l_tag_keyval(l_counter).key='IEMNAGENTID' THEN
				l_agentid:=to_number(l_tag_keyval(l_counter).value);
			END IF;
	END LOOP;
  END IF;

 BEGIN
	select name
	into l_folder_name
	from iem_route_classifications
	where route_classification_id=l_mail_Rec.rt_classification_id;
 EXCEPTION
	WHEN OTHERS THEN
	if g_exception_log then
	l_logmessage:='Error in getting folder name for the route classificaion id '||l_mail_rec.rt_classification_id||' and the error is '||sqlerrm;
		iem_logger(l_logmessage);
	end if;
		raise abort_reprocessing;
  END;
		l_counter:=l_counter+1;
	l_class_val_tbl(l_counter).key:='IEMSROUTINGCLASSIFICATION';
  l_class_val_tbl(l_counter).value:=l_folder_name;
	l_class_val_tbl(l_counter).datatype:='S';

		l_counter:=l_counter+1;
		l_class_val_tbl(l_counter).key:='IEMNINTERACTIONID';
		l_class_val_tbl(l_counter).value:=p_interaction_id;
		l_class_val_tbl(l_counter).datatype:='N';

		-- Add Media Id to the key value Pair
		l_counter:=l_counter+1;
		l_class_val_tbl(l_counter).key:='IEMNMEDIAID';
		l_class_val_tbl(l_counter).value:=p_media_id;
		l_class_val_tbl(l_counter).datatype:='N';
		l_counter:=l_counter+1;
		l_class_val_tbl(l_counter).key:='IEMNMESSAGEID';
		l_class_val_tbl(l_counter).value:=l_mail_rec.message_id;
		l_class_val_tbl(l_counter).datatype:='N';

		-- Now Calling Document Retrieval Rule
		l_rule_id:=0;
	iem_rules_engine_pub.auto_process_email(p_api_version_number=>1.0,
					p_commit=>FND_API.G_FALSE,
					p_rule_type=>'DOCUMENTRETRIEVAL',
					p_keyvals_tbl=>l_class_val_tbl,
					p_accountid=>l_mail_rec.email_account_id,
					x_result=>l_autoproc_result,
					x_action=>l_action,
					x_parameters=>l_param_rec_tbl,
					x_return_status=>l_ret_status,
					x_msg_count=>l_msg_count,
					x_msg_data=>l_msg_data);
		    IF l_ret_status<>'S' THEN
			   l_logmessage:='Error While Calling rules Engine for DOCUMENTRETRIEVAL';
			END IF;
			IF l_autoproc_result='T' THEN
			 if l_action <> 'MES_CATEGORY_MAPPING'  THEN
	     l_search_type:=substr(l_action,15,length(l_action));
		 -- identfiying the repository to search
				if l_search_type='MES' THEN
					l_repos:='MES';
				elsif l_search_type='KM' THEN
					l_repos:='SMS';
				elsif l_search_type='BOTH' THEN
					l_repos:='ALL';
				end if;
				   l_cat_counter:=1;
				   IF l_param_rec_tbl.count>0 THEN
				   FOR l_param_index in l_param_rec_tbl.FIRST..l_param_rec_tbl.LAST LOOP
			 		IF l_param_rec_tbl(l_param_index).parameter1 <> to_char(-1)  then
						IF l_param_rec_tbl(l_param_index).parameter1='RULE_ID' then
							l_rule_id:=l_param_rec_tbl(l_param_index).parameter2;
						ELSE
							l_category_id.extend;
					l_category_id(l_cat_counter):=l_param_rec_tbl(l_param_index).parameter1;
							l_cat_counter:=l_cat_counter+1;
						END IF;
					END IF;
				  END LOOP;
				  END IF;
			else
					l_search_type:='CM';		--Category based mapping
				   FOR l_param_index in l_param_rec_tbl.FIRST..l_param_rec_tbl.LAST LOOP
							l_cm_cat_id:=l_param_rec_tbl(l_param_index).parameter1;
							EXIT;
				   END LOOP;
			end if;
		else
			l_search_type:=null;
			l_cm_Cat_id:=0;
          end if ;		-- end if for l_autoproc_result='T'
		-- CALLING ROUTING ----
iem_email_proc_pvt.IEM_ROUTING_PROC(
					p_email_account_id=>l_mail_rec.email_account_id,
				p_keyval=>l_class_val_tbl,
				x_routing_group_id=>l_group_id,
					x_status=>l_status,
		     		x_out_text=>l_out_text) ;
	IF l_status <>'S' THEN
	if g_error_log then
		l_logmessage:=l_out_text;
		iem_logger(l_logmessage);
	end if;
		raise abort_reprocessing;
	END IF;
	IF l_group_id=-1 then
			l_group_id:=0;
			l_auto_flag:='Y';
	END IF;
		update iem_rt_proc_emails
		set resource_id=0,
		group_id=l_group_id,
		customer_id=p_customer_id,
		contact_id=p_contact_id,
		relationship_id=p_relationship_id,
		msg_status=null,
		mail_proc_status='P',
		category_map_id=l_cm_cat_id
		where message_id=l_mail_rec.message_id;

	IF l_auto_flag='Y' THEN		-- auto Routing Processing
		-- Create a Record in RT Table
		BEGIN
		SAVEPOINT AUTO_ROUTE;
		IEM_CLIENT_PUB.createRTItem (p_api_version_number=>1.0,
					p_init_msg_list=>'F',
					p_commit=>'F',
   					p_message_id =>l_mail_rec.message_id,
  					p_to_resource_id  =>l_agentid,
  					p_from_resource_id =>l_agentid,
  					p_status  =>'N',
  					p_reason =>'O',
  					p_interaction_id =>p_interaction_id,
  					x_return_status  =>l_ret_status,
  					x_msg_count =>l_msg_count,
  					x_msg_data   =>l_msg_data,
  					x_rt_media_item_id =>l_rt_media_item_id,
  					x_rt_interaction_id =>l_rt_interaction_id);
		 IF l_ret_status<>'S' THEN
	if g_error_log then
				l_logmessage:='Failed To Auto Route The Message due to error in create RT Item ';
				iem_logger(l_logmessage);
	end if;
				rollback to auto_route;
		 ELSE
				-- Create MLCS for Auto Routing

  					l_media_lc_rec.media_id :=p_media_id ;
  					l_media_lc_rec.milcs_type_id := 30; --MAIL_AUTOROUTE
  					l_media_lc_rec.start_date_time := sysdate;
  					l_media_lc_rec.handler_id := 680;
  					l_media_lc_rec.type_type := 'Email, Inbound';
  					l_media_lc_rec.resource_id := l_agentid;

						iem_email_proc_pvt.IEM_PROC_IH(
							p_type=>'MLCS'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
								p_action=>'ADD'		,		-- ADD/UPDATE/CLOSE
								p_interaction_rec=>l_interaction_rec,
								p_activity_rec=>l_activity_rec     ,
								p_media_lc_rec=>l_media_lc_Rec ,
								p_media_rec=>l_media_rec	,
								x_id=>l_milcs_id,
								x_status=>l_stat		,
			    				 x_out_text=>l_out_text	);
							IF l_stat<>'S' THEN
					if g_error_log then
						l_logmessage:='Error while creating MLCS for Auto Route '||l_out_text;
								iem_logger(l_logmessage);
					end if;
								rollback to auto_route;
							ELSE
							-- Update  the Media Life Cycle for Auto Routing
 							 l_media_lc_rec.milcs_id:=l_milcs_id;
							iem_email_proc_pvt.IEM_PROC_IH(
							p_type=>'MLCS'		,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
								p_action=>'UPDATE'		,		-- ADD/UPDATE/CLOSE
								p_interaction_rec=>l_interaction_rec,
								p_activity_rec=>l_activity_rec     ,
								p_media_lc_rec=>l_media_lc_Rec ,
								p_media_rec=>l_media_rec	,
								x_id=>l_milcs_id,
								x_status=>l_stat		,
			  				   x_out_text=>l_out_text	);
							END IF;

							IF l_stat<>'S' THEN
					if g_error_log then
						l_logmessage:='Error while updating MLCS for Auto Route '||l_out_text;
								iem_logger(l_logmessage);
					end if;
								rollback to auto_route;
							END IF;
				-- In case of autoroute update the interaction with resource id of the agent to which
				-- the message is autorouted to
			l_interaction_rec.interaction_id:=p_interaction_id;
			l_interaction_rec.resource_id:=l_agentid;
     		JTF_IH_PUB.Update_Interaction( p_api_version     => 1.1,
                                  p_resp_appl_id    => TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
                                  p_resp_id         => TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
                         		p_user_id		  =>nvl(TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),-1),
							p_login_id	  =>TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),
                                  x_return_status   => l_ret_status,
                                  x_msg_count       => l_msg_count,
                                  x_msg_data        => l_msg_data,
                                  p_interaction_rec => l_interaction_rec
                                 );
							IF l_ret_status<>'S' THEN
					if g_error_log then
						l_logmessage:='Error while updating Interactions for Auto Route ';
								iem_logger(l_logmessage);
						end if;
								rollback to auto_route;
							END IF;
				if g_statement_log then
					l_logmessage:='Successfully AutoRoute The Message ';
					iem_logger(l_logmessage);
				end if;
		END IF;
		EXCEPTION WHEN OTHERS THEN
			rollback to auto_route;
		END;
      END IF;		-- End for Auto-Routing
	-- Calling the specific search at the End
	if g_statement_log then
	l_logmessage:='Calling Specific Search API ' ;
	iem_logger(l_logmessage);
	end if;
	BEGIN
	IF l_search_type<>'CM' THEN			-- Not a MES category based mapping
			l_start_search:=1;
			FOR v1 in c_class_id LOOP
	IEM_EMAIL_PROC_PVT.IEM_WF_SPECIFICSEARCH(
    					l_mail_rec.message_id  ,
    					l_mail_rec.email_account_id ,
    					v1.classification_id,
					l_category_id,
					l_repos,
    					l_stat ,
    					l_out_text);
		l_start_search:=l_start_search+1;
		EXIT when l_start_search>l_intent_counter;
		END LOOP;
	ELSIF nvl(l_search_type,' ')='CM' and l_cm_cat_id is not null then
		for v_item in c_item LOOP
		select count(*) into l_kb_rank
		from iem_doc_usage_stats
		where kb_doc_id=v_item.item_id;
		IEM_KB_RESULTS_PVT.create_item(p_api_version_number=>1.0,
 		  	      		p_init_msg_list=>'F' ,
		    	      		p_commit=>'F'	    ,
						 p_message_id =>l_mail_rec.message_id,
						 p_classification_id=>0,
 				p_email_account_id=>l_mail_rec.email_account_id ,
 			p_document_id =>to_char(v_item.item_id),
 		p_kb_repository_name =>'MES',
 		p_kb_category_name =>'MES',
 			p_document_title =>v_item.item_name,
 p_doc_last_modified_date=>v_item.last_update_date,
 			p_score =>l_kb_rank,
 			p_url =>' ',
			p_kb_delete=>'N',
	p_CREATED_BY  =>TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),
    	p_CREATION_DATE  =>SYSDATE,
    	p_LAST_UPDATED_BY  =>TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),
    	p_LAST_UPDATE_DATE  =>SYSDATE,
    	p_LAST_UPDATE_LOGIN=>TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ID')) ,
    	p_ATTRIBUTE1   =>null,
    	p_ATTRIBUTE2   =>null,
    	p_ATTRIBUTE3   =>null,
    	p_ATTRIBUTE4   =>null,
    	p_ATTRIBUTE5   =>null,
    	p_ATTRIBUTE6   =>null,
    	p_ATTRIBUTE7   =>null,
    	p_ATTRIBUTE8   =>null,
    	p_ATTRIBUTE9   =>null,
    	p_ATTRIBUTE10  =>null,
    	p_ATTRIBUTE11  =>null,
    	p_ATTRIBUTE12  =>null,
    	p_ATTRIBUTE13  =>null,
    	p_ATTRIBUTE14  =>null,
    	p_ATTRIBUTE15  =>null,
			x_return_status=>l_ret_status,
			x_msg_count=>l_msg_count,
			x_msg_data=>l_msg_data);
	END LOOP;
	END IF;		-- Endof search_type<>'CM'
   	EXCEPTION WHEN OTHERS THEN
	if g_exception_log then
		l_logmessage:='Error in calling Document Search while reprocessing auto-reply message'||sqlerrm ;
		iem_logger(l_logmessage);
	end if;
	END;
	if g_statement_log then
	l_logmessage:='End Of Calling Specific Search API  and end of Processing for the message ' ;
	iem_logger(l_logmessage);
	end if;
-- Standard Check Of p_commit.
	IF p_commit='T' THEN
		COMMIT WORK;
	END IF;
-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 	p_data  =>    x_msg_data
			);
	x_return_status:='S';

 EXCEPTION WHEN ABORT_REPROCESSING THEN
		x_Return_status:='E';
		rollback to processautoreply;
 WHEN OTHERS THEN
	if g_exception_log then
	l_logmessage:='Error occur during Reprocessing autoreply message '||sqlerrm ;
	iem_logger(l_logmessage);
	end if;
		rollback to processautoreply;
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
    		( p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    		);
 END REPROCESSAUTOREPLY;

procedure IEM_WF_SPECIFICSEARCH(
    l_msg_id  in number,
    l_email_account_id   in number,
    l_classification_id	in number,
    l_category_id  AMV_SEARCH_PVT.amv_number_varray_type,
    l_repos		in varchar2,
    l_stat    out nocopy varchar2,
    l_out_text	out nocopy varchar2)
is
  l_return_status      VARCHAR2(20);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(400);
  l_doc_id		number;
  l_kb_repos		iem_kb_results.kb_repository_name%type;
l_rows_returned cs_kb_number_tbl_type :=cs_kb_number_tbl_type();
l_next_row_pos cs_kb_number_tbl_type :=cs_kb_number_tbl_type();
l_total_row_cnt cs_kb_number_tbl_type :=cs_kb_number_tbl_type();
l_logmessage		varchar2(500);
l_level			varchar2(20):='STATEMENT';
l_app_id		number;
l_part		number;
l_flag		number:=1;
l_ret		number;
l_search		varchar2(100);
l_theme		   varchar2(200);
l_tstr		   varchar2(2000);
l_errtext		   varchar2(200);
l_score			number;
l_class          NUMBER;
l_count          NUMBER;
l_next_row_tbl	cs_kb_number_tbl_type:=cs_kb_number_tbl_type();
l_total_row_tbl	cs_kb_number_tbl_type:=cs_kb_number_tbl_type();
l_area_array    AMV_SEARCH_PVT.amv_char_varray_type:=null;
l_result_array       cs_kb_result_varray_type;
l_amv_result_array    AMV_SEARCH_PVT.amv_searchres_varray_type;
l_content_array AMV_SEARCH_PVT.amv_char_varray_type:=null;
l_param_array AMV_SEARCH_PVT.amv_searchpar_varray_type;
l_rep	cs_kb_varchar100_tbl_type ;
l_imt_string varchar2(4000);
r_imt_string varchar2(4000);
l_proc_name	varchar2(30):='IEM_WF_SPECIFICSEARCH';
--l_category_id	AMV_SEARCH_PVT.amv_number_varray_type:=AMV_SEARCH_PVT.amv_number_varray_type();
l_tag1		number;
l_cnt		number;
l_res1		varchar2(10);
l_res2		varchar2(10);
l_search_repos		varchar2(10);
l_days  number ;
l_user_id number ;
l_rows_req cs_kb_number_tbl_type ;
l_rows		number;
l_start_row cs_kb_number_tbl_type:=cs_kb_number_tbl_type(1,1);
l_sms_string	varchar2(255);
l_sms_count    number;
l_counter    number:=1;
g_app_id		number;
cursor c1 is select category_id from iem_account_categories
where email_account_id=l_email_account_id;
 cursor c2 is
 select keyword,weight from iem_intent_dtls where intent_id=l_classification_id
 and query_response='R';
 cursor c_doc is
 select document_id,KB_REPOSITORY_NAME,score,kb_result_id from iem_kb_results
 where message_id=l_msg_id
 order by 2,1,score asc;
begin
	select count(*) into l_cnt from iem_kb_results
	where message_id=l_msg_id
	and classification_id=l_classification_id
	and email_account_id=l_email_account_id;
 IF l_cnt=0 THEN
	if g_statement_log then
		l_logmessage:= 'Start Initializing for Specific search  '||l_msg_id;
		iem_logger(l_logmessage);
	end if;
	-- Prepare the response String  for Intent
	for v2 in c2 loop
		r_imt_string:=r_imt_string||'about ('||v2.keyword||')*'||v2.weight||',';
	end loop;
	if r_imt_string is not null then
		r_imt_string:=substr(r_imt_string,1,length(r_imt_string)-1);
	end if;

	l_rows:=10;	-- Number of Document Retrieved...
	l_rows_req :=cs_kb_number_tbl_type(l_rows,l_rows);
	G_APP_ID:=520;
 l_area_array := AMV_SEARCH_PVT.amv_char_varray_type();
 l_area_array.extend;
l_area_array(1) := 'ITEM';
l_content_array := AMV_SEARCH_PVT.amv_char_varray_type();
l_content_array.extend;
l_content_array(1) := 'CONTENT';
l_content_array.extend;
 l_param_array := AMV_SEARCH_PVT.amv_searchpar_varray_type();
		l_rep	:=cs_kb_varchar100_tbl_type() ;
 begin
	select classification_string into l_imt_string
	from IEM_EMAIL_CLASSIFICATIONS
	WHERE MESSAGE_ID=l_msg_id AND EMAIL_ACCOUNT_ID=l_email_account_id
	and classification_id=l_classification_id;
	IF l_repos is null then
	l_search_repos:=FND_PROFILE.VALUE_SPECIFIC('IEM_KNOWLEDGE_BASE');
	IF l_search_repos is null then
		l_search_repos:='MES';
     END IF;
	else
		l_search_repos:=l_repos;
	end if;
IF (l_search_repos='MES') or (l_search_repos='ALL') Then
	if g_statement_log then
	l_logmessage:= 'Calling the MES Specific Search For Message Id '||l_msg_id;
	iem_logger(l_logmessage);
	end if;
		l_rep	:=cs_kb_varchar100_tbl_type('MES') ;
  cs_knowledge_grp.Specific_Search(
      p_api_version => 1.0,
      p_init_msg_list => fnd_api.g_true,
      --p_validation_level => p_validation_level,
      x_return_status => l_return_status,
      x_msg_count => l_msg_count,
      x_msg_data => l_msg_data,
      p_repository_tbl => l_rep,
      p_search_string => l_imt_string,
      p_updated_in_days => l_days,
      p_check_login_user => FND_API.G_FALSE,
      p_application_id => G_APP_ID,
        p_area_array => l_area_array,
        p_content_array => l_content_array,
        p_param_array => l_param_array,
        p_user_id => l_user_id,
        p_category_id => l_category_id,
        p_include_subcats   => FND_API.G_FALSE,
        p_external_contents => FND_API.G_TRUE,
      p_rows_requested_tbl => l_rows_req,
      p_start_row_pos_tbl  => l_start_row,
      p_get_total_cnt_flag => 'T',
      x_rows_returned_tbl => l_rows_returned,
      x_next_row_pos_tbl => l_next_row_pos,
      x_total_row_cnt_tbl => l_total_row_cnt,
      x_result_array  => l_result_array);

	if g_statement_log then
		l_logmessage:= 'End Calling the Specific Search For Message Id '||l_msg_id||' No of document Returned '||l_result_array.count;
	 	iem_logger(l_logmessage);
	end if;
-- Insert The Data into IEM_KB_RESULTS

	FOR l_count IN 1..l_result_array.count LOOP
		IEM_KB_RESULTS_PVT.create_item(p_api_version_number=>1.0,
 		  	      		p_init_msg_list=>'F' ,
		    	      		p_commit=>'F'	    ,
						 p_message_id =>l_msg_id,
						 p_classification_id=>l_classification_id,
 				p_email_account_id=>l_email_account_id ,
 			p_document_id =>to_char(l_result_array(l_count).id) ,
 		p_kb_repository_name =>l_result_array(l_count).repository,
 		p_kb_category_name =>l_result_array(l_count).repository,
 			p_document_title =>l_result_array(l_count).title,
 p_doc_last_modified_date=>l_result_array(l_count).last_update_date,
 			p_score =>to_char(l_result_array(l_count).score),
 			p_url =>l_result_array(l_count).url_string,
			p_kb_delete=>'N',
	p_CREATED_BY  =>TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),
    	p_CREATION_DATE  =>SYSDATE,
    	p_LAST_UPDATED_BY  =>TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),
    	p_LAST_UPDATE_DATE  =>SYSDATE,
    	p_LAST_UPDATE_LOGIN=>TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ID')) ,
    	p_ATTRIBUTE1   =>null,
    	p_ATTRIBUTE2   =>null,
    	p_ATTRIBUTE3   =>null,
    	p_ATTRIBUTE4   =>null,
    	p_ATTRIBUTE5   =>null,
    	p_ATTRIBUTE6   =>null,
    	p_ATTRIBUTE7   =>null,
    	p_ATTRIBUTE8   =>null,
    	p_ATTRIBUTE9   =>null,
    	p_ATTRIBUTE10  =>null,
    	p_ATTRIBUTE11  =>null,
    	p_ATTRIBUTE12  =>null,
    	p_ATTRIBUTE13  =>null,
    	p_ATTRIBUTE14  =>null,
    	p_ATTRIBUTE15  =>null,
			x_return_status=>l_return_status,
			x_msg_count=>l_msg_count,
			x_msg_data=>l_msg_data);
	END LOOP;
--  Calling Search Api for Response String Separately
IF r_imt_string is not null then
  cs_knowledge_grp.Specific_Search(
      p_api_version => 1.0,
      p_init_msg_list => fnd_api.g_true,
      --p_validation_level => p_validation_level,
      x_return_status => l_return_status,
      x_msg_count => l_msg_count,
      x_msg_data => l_msg_data,
      p_repository_tbl => l_rep,
      p_search_string => r_imt_string,
      p_updated_in_days => l_days,
      p_check_login_user => FND_API.G_FALSE,
      p_application_id => G_APP_ID,
        p_area_array => l_area_array,
        p_content_array => l_content_array,
        p_param_array => l_param_array,
        p_user_id => l_user_id,
        p_category_id => l_category_id,
        p_include_subcats   => FND_API.G_FALSE,
        p_external_contents => FND_API.G_TRUE,
      p_rows_requested_tbl => l_rows_req,
      p_start_row_pos_tbl  => l_start_row,
      p_get_total_cnt_flag => 'T',
      x_rows_returned_tbl => l_rows_returned,
      x_next_row_pos_tbl => l_next_row_pos,
      x_total_row_cnt_tbl => l_total_row_cnt,
      x_result_array  => l_result_array);

	if g_statement_log then
	l_logmessage:= 'End Calling the Specific Search For Message Id '||l_msg_id||' No of document Returned '||l_result_array.count;
	 iem_logger(l_logmessage);
	end if;
-- Insert The Data into IEM_KB_RESULTS

	FOR l_count IN 1..l_result_array.count LOOP
		IEM_KB_RESULTS_PVT.create_item(p_api_version_number=>1.0,
 		  	      		p_init_msg_list=>'F' ,
		    	      		p_commit=>'F'	    ,
						 p_message_id =>l_msg_id,
						 p_classification_id=>l_classification_id,
 				p_email_account_id=>l_email_account_id ,
 			p_document_id =>to_char(l_result_array(l_count).id) ,
 		p_kb_repository_name =>l_result_array(l_count).repository,
 		p_kb_category_name =>l_result_array(l_count).repository,
 			p_document_title =>l_result_array(l_count).title,
 p_doc_last_modified_date=>l_result_array(l_count).last_update_date,
 			p_score =>to_char(l_result_array(l_count).score),
 			p_url =>l_result_array(l_count).url_string,
			p_kb_delete=>'N',
	p_CREATED_BY  =>TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),
    	p_CREATION_DATE  =>SYSDATE,
    	p_LAST_UPDATED_BY  =>TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),
    	p_LAST_UPDATE_DATE  =>SYSDATE,
    	p_LAST_UPDATE_LOGIN=>TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ID')) ,
    	p_ATTRIBUTE1   =>null,
    	p_ATTRIBUTE2   =>null,
    	p_ATTRIBUTE3   =>null,
    	p_ATTRIBUTE4   =>null,
    	p_ATTRIBUTE5   =>null,
    	p_ATTRIBUTE6   =>null,
    	p_ATTRIBUTE7   =>null,
    	p_ATTRIBUTE8   =>null,
    	p_ATTRIBUTE9   =>null,
    	p_ATTRIBUTE10  =>null,
    	p_ATTRIBUTE11  =>null,
    	p_ATTRIBUTE12  =>null,
    	p_ATTRIBUTE13  =>null,
    	p_ATTRIBUTE14  =>null,
    	p_ATTRIBUTE15  =>null,
			x_return_status=>l_return_status,
			x_msg_count=>l_msg_count,
			x_msg_data=>l_msg_data);
	END LOOP;
	END IF;	-- End if for if r_imt_string is not null
  END IF;
IF (l_search_repos='SMS') or (l_search_repos='ALL') Then
	if g_statement_log then
		l_logmessage:= 'Calling the SMS Specific Search For Message Id '||l_msg_id;
		iem_logger(l_logmessage);
	end if;
		l_rep	:=cs_kb_varchar100_tbl_type('SMS') ;
		-- Currently SMS has 255 character limitations . So we have to
		--truncate the SMS search string to 255 character length which
		--will removed later
  IF length(l_imt_string)>255 THEN
		l_sms_string:=substr(l_imt_string,1,255);
		l_sms_count:=instr(l_sms_string,',about',-1,1);
		l_imt_string:=substr(l_sms_string,1,l_sms_count-1);
  END IF;
  cs_knowledge_grp.Specific_Search(
      p_api_version => 1.0,
      p_init_msg_list => fnd_api.g_true,
      --p_validation_level => p_validation_level,
      x_return_status => l_return_status,
      x_msg_count => l_msg_count,
      x_msg_data => l_msg_data,
      p_repository_tbl => l_rep,
      p_search_string => l_imt_string,
      p_updated_in_days => l_days,
      p_check_login_user => FND_API.G_FALSE,
      p_application_id => G_APP_ID,
        p_area_array => l_area_array,
        p_content_array => l_content_array,
        p_param_array => l_param_array,
        p_user_id => l_user_id,
        p_category_id => l_category_id,
        p_include_subcats   => FND_API.G_TRUE,
        p_external_contents => FND_API.G_TRUE,
      p_rows_requested_tbl => l_rows_req,
      p_start_row_pos_tbl  => l_start_row,
      p_get_total_cnt_flag => 'T',
      x_rows_returned_tbl => l_rows_returned,
      x_next_row_pos_tbl => l_next_row_pos,
      x_total_row_cnt_tbl => l_total_row_cnt,
      x_result_array  => l_result_array);

	if g_statement_log then
	l_logmessage:= 'End Calling the Specific Search For Message Id '||l_msg_id||' No of document Returned '||l_result_array.count;
	 iem_logger(l_logmessage);
	end if;
-- Insert The Data into IEM_KB_RESULTS

	FOR l_count IN 1..l_result_array.count LOOP
		IEM_KB_RESULTS_PVT.create_item(p_api_version_number=>1.0,
 		  	      		p_init_msg_list=>'F' ,
		    	      		p_commit=>'F'	    ,
						 p_message_id =>l_msg_id,
						 p_classification_id=>l_classification_id,
 				p_email_account_id=>l_email_account_id ,
 			p_document_id =>to_char(l_result_array(l_count).id) ,
 		p_kb_repository_name =>l_result_array(l_count).repository,
 		p_kb_category_name =>l_result_array(l_count).repository,
 			p_document_title =>l_result_array(l_count).title,
 p_doc_last_modified_date=>l_result_array(l_count).last_update_date,
 			p_score =>to_char(l_result_array(l_count).score),
 			p_url =>l_result_array(l_count).url_string,
			p_kb_delete=>'N',
	p_CREATED_BY  =>TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),
    	p_CREATION_DATE  =>SYSDATE,
    	p_LAST_UPDATED_BY  =>TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),
    	p_LAST_UPDATE_DATE  =>SYSDATE,
    	p_LAST_UPDATE_LOGIN=>TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ID')) ,
    	p_ATTRIBUTE1   =>null,
    	p_ATTRIBUTE2   =>null,
    	p_ATTRIBUTE3   =>null,
    	p_ATTRIBUTE4   =>null,
    	p_ATTRIBUTE5   =>null,
    	p_ATTRIBUTE6   =>null,
    	p_ATTRIBUTE7   =>null,
    	p_ATTRIBUTE8   =>null,
    	p_ATTRIBUTE9   =>null,
    	p_ATTRIBUTE10  =>null,
    	p_ATTRIBUTE11  =>null,
    	p_ATTRIBUTE12  =>null,
    	p_ATTRIBUTE13  =>null,
    	p_ATTRIBUTE14  =>null,
    	p_ATTRIBUTE15  =>null,
			x_return_status=>l_return_status,
			x_msg_count=>l_msg_count,
			x_msg_data=>l_msg_data);
	END LOOP;
 IF r_imt_string is not null then
  -- Calling Specific Search for Response String
  cs_knowledge_grp.Specific_Search(
      p_api_version => 1.0,
      p_init_msg_list => fnd_api.g_true,
      --p_validation_level => p_validation_level,
      x_return_status => l_return_status,
      x_msg_count => l_msg_count,
      x_msg_data => l_msg_data,
      p_repository_tbl => l_rep,
      p_search_string => r_imt_string,
      p_updated_in_days => l_days,
      p_check_login_user => FND_API.G_FALSE,
      p_application_id => G_APP_ID,
        p_area_array => l_area_array,
        p_content_array => l_content_array,
        p_param_array => l_param_array,
        p_user_id => l_user_id,
        p_category_id => l_category_id,
        p_include_subcats   => FND_API.G_FALSE,
        p_external_contents => FND_API.G_TRUE,
      p_rows_requested_tbl => l_rows_req,
      p_start_row_pos_tbl  => l_start_row,
      p_get_total_cnt_flag => 'T',
      x_rows_returned_tbl => l_rows_returned,
      x_next_row_pos_tbl => l_next_row_pos,
      x_total_row_cnt_tbl => l_total_row_cnt,
      x_result_array  => l_result_array);

	if g_statement_log then
	l_logmessage:= 'End Calling the Specific Search For Message Id '||l_msg_id||' No of document Returned '||l_result_array.count;
	 iem_logger(l_logmessage);
	end if;
-- Insert The Data into IEM_KB_RESULTS

	FOR l_count IN 1..l_result_array.count LOOP
		IEM_KB_RESULTS_PVT.create_item(p_api_version_number=>1.0,
 		  	      		p_init_msg_list=>'F' ,
		    	      		p_commit=>'F'	    ,
						 p_message_id =>l_msg_id,
						 p_classification_id=>l_classification_id,
 				p_email_account_id=>l_email_account_id ,
 			p_document_id =>to_char(l_result_array(l_count).id) ,
 		p_kb_repository_name =>l_result_array(l_count).repository,
 		p_kb_category_name =>l_result_array(l_count).repository,
 			p_document_title =>l_result_array(l_count).title,
 p_doc_last_modified_date=>l_result_array(l_count).last_update_date,
 			p_score =>to_char(l_result_array(l_count).score),
 			p_url =>l_result_array(l_count).url_string,
			p_kb_delete=>'N',
	p_CREATED_BY  =>TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),
    	p_CREATION_DATE  =>SYSDATE,
    	p_LAST_UPDATED_BY  =>TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),
    	p_LAST_UPDATE_DATE  =>SYSDATE,
    	p_LAST_UPDATE_LOGIN=>TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ID')) ,
    	p_ATTRIBUTE1   =>null,
    	p_ATTRIBUTE2   =>null,
    	p_ATTRIBUTE3   =>null,
    	p_ATTRIBUTE4   =>null,
    	p_ATTRIBUTE5   =>null,
    	p_ATTRIBUTE6   =>null,
    	p_ATTRIBUTE7   =>null,
    	p_ATTRIBUTE8   =>null,
    	p_ATTRIBUTE9   =>null,
    	p_ATTRIBUTE10  =>null,
    	p_ATTRIBUTE11  =>null,
    	p_ATTRIBUTE12  =>null,
    	p_ATTRIBUTE13  =>null,
    	p_ATTRIBUTE14  =>null,
    	p_ATTRIBUTE15  =>null,
			x_return_status=>l_return_status,
			x_msg_count=>l_msg_count,
			x_msg_data=>l_msg_data);
	END LOOP;
  END IF;		--End if for r_imt_string is not null
 END IF;
 -- Deleting duplicate rows from Document retrieval set
 l_doc_id:=0;
 l_kb_repos:=null;
 for v_doc in c_doc LOOP
 	if (v_doc.document_id = l_doc_id and v_doc.kb_repository_name=l_kb_repos) then
 		delete from iem_kb_results where message_id=l_msg_id and kb_result_id=v_doc.kb_result_id;
	end if;
 l_doc_id:=v_doc.document_id;
 l_kb_repos:=v_doc.kb_repository_name;
 END LOOP;

EXCEPTION when others then
		null;
END;
	l_stat:='S';
ELSE
		l_stat:='S';
END IF;
exception
  when others then
	if g_exception_log then
		l_logmessage:='Oracle Error in MES Search '||sqlerrm||' while processing for message id '||l_msg_id;
	 iem_logger(l_logmessage);
	end if;
		l_stat:='E';
		l_out_text:='Oracle Error in Specific Search '||sqlerrm||' while processing for message id '||l_msg_id;
end IEM_WF_SPECIFICSEARCH;
procedure IEM_RETURN_ENCRYPTID
	(p_subject	in varchar2,
	x_id		out nocopy varchar2,
	x_Status		out nocopy varchar2) IS
l_search	varchar2(10);
l_index1	number;
l_index2	number;
l_encrypted_id		varchar2(100);
begin
	l_search:='[REF:';
 l_index1:=instr(p_subject,l_search,1,1);
 l_index2:=instr(substr(p_subject,l_index1+length(l_search),length(p_subject)-1),']',1,1);
 IF (l_index1 <> 0) and (l_index2<>0) THEN
	l_encrypted_id:=ltrim(substr(p_subject,l_index1+length(l_search),l_index2-1));
 END IF;
 x_id:=l_encrypted_id;
 x_status:='S';
 EXCEPTION WHEN OTHERS THEN
 	x_status:='E';
end IEM_RETURN_ENCRYPTID;

--siahmed 12.1.3 advanced SR processing changes begin


  --Developer attention:
  --I am using the rownum to restrict the number of rows that gets returned. Since
  --rownum will limit the number of rows it searches; if it finds more than one match
  --we are not interested with that data and therefore we need not proceed further.
  --Rownum works in the following manner therefore it should be ok for us to use as a
  --restricted methadology
  --1. The FROM/WHERE clause goes first.
  --2. ROWNUM is assigned and incremented to each output row from the FROM/WHERE clause.

  --p_account_type is to determine weather an account is internal or external
    --this will help us determine which processing route to proceede with during
    --contact processing. Account type can of be type I for internal
    --this is the p_employee_flag that gets passed to the create_Sr api
  --p_default_type_id is the default status id being used by the current sr processing
    --incase the user pass a sr_type but an associated Sr_type_id could not be recovered
    --then we need to use the default type_id to create the sr
  --p_default_customer_id this is the customer_id that will be used if no customer id could be
    --found using the values that the customer has provided.This is the default customer_id
    --which is currently being used during the R12 functionality of SR creation.
  PROCEDURE advanced_sr_processing (
                  p_message_id          IN NUMBER,
                  p_parser_id           IN NUMBER,
                  p_account_type        IN VARCHAR2 DEFAULT NULL, --p_employee_flag
                  p_default_type_id   IN NUMBER   DEFAULT NULL, --p_sr_type_id
                  p_default_customer_id IN NUMBER   DEFAULT NULL, --p_party_id
                  p_init_msg_list	IN   VARCHAR2 	:= FND_API.G_FALSE,
                  p_commit		IN   VARCHAR2 	:= FND_API.G_FALSE,
                  p_note		IN   VARCHAR2,
                  p_subject             IN   VARCHAR2,
                  p_note_type           IN   VARCHAR2,
                  p_contact_id          IN   NUMBER             := NULL,
                  p_contact_point_id    IN   NUMBER             := NULL,
                  x_return_status	OUT  NOCOPY   VARCHAR2,
                  x_msg_count		OUT  NOCOPY  NUMBER,
                  x_msg_data		OUT  NOCOPY  VARCHAR2,
                  x_request_id          OUT  NOCOPY  NUMBER
                )
  IS
    -- local var for creating SR
    l_return_status        VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count            NUMBER := 0;
    l_msg_data             VARCHAR2(2000);
    l_index                NUMBER := 1;

    l_api_name            VARCHAR2(255):='ADVANCED_SR_PROCESSING';
    --l_api_version_number  NUMBER:=1.0;
    l_cs_version_number   NUMBER:=4.0;

    l_service_request_rec  CS_ServiceRequest_PUB.service_request_rec_type;
    p_notes                CS_ServiceRequest_PUB.notes_table;
    p_contacts             CS_ServiceRequest_PUB.contacts_table;
    l_sr_create_out_rec    CS_ServiceRequest_PUB.sr_create_out_rec_type;
    p_keyVals_tbl          IEM_ROUTE_PUB.keyVals_tbl_type;

    l_notes                CS_ServiceRequest_PUB.notes_table;
    l_contacts             CS_ServiceRequest_PUB.contacts_table;
    l_summary_prefix       VARCHAR2(80);
    l_summary              VARCHAR2(300);
    l_party_type           VARCHAR2(80);
    l_contact_type         VARCHAR2(80);
    l_auto_assign          VARCHAR2(10);
    --end of local var for SR

     l_coverage_template_id    NUMBER;

      IEM_SR_NOT_CREATE EXCEPTION;

    --local varaibles for getting values to be passed to the SR API
    l_cust_account_id     NUMBER; --to be passed as account_id in SR API
    l_customer_phone_id   NUMBER;
    l_customer_email_id   NUMBER;
    l_customer_product_id NUMBER;
    l_inventory_item_id   NUMBER;
    l_inventory_org_id    NUMBER;
    l_incident_location_id  NUMBER;
    l_type_id              NUMBER;
    l_problem_code        VARCHAR2(100);
    l_urgency_id          NUMBER;
    l_party_site_id       NUMBER;
    l_ext_ref             VARCHAR2(100);


    --cursor for doing customer info processing
    --in the order or rank. Attribute with the lower number
    --will get a higher precedence.  So 1 has a higer precedence over 2 or 3
    --Question
    -- we can also make these attributes dynamic by driving them from fnd tabel
    -- rather than hard coding them;where we can define which processing group each column name belongs to
    Cursor c_customer_attributes (l_parser_id IN NUMBER)
    IS
    Select parser_id, start_tag, end_tag, column_name, rank
    from iem_parser_dtls
    where parser_id = l_parser_id
    and UPPER(column_name) IN ('ACCOUNT_NUMBER','CUSTOMER_NUMBER','CUSTOMER_NAME',
                               'CUSTOMER_PHONE','CUSTOMER_EMAIL','INSTANCE_NUMBER',
      		  	       'INSTANCE_SERIAL_NUMBER','INCIDENT_SITE_NUMBER','CONTACT_NUMBER',
                               'CONTACT_NAME','CONTACT_PHONE','CONTACT_EMAIL')
    order by rank asc;

    --Note: serial number is not being implemented
    Cursor c_other_attributes (l_parser_id IN NUMBER)
    IS
    Select parser_id, start_tag, end_tag, column_name, rank
    from iem_parser_dtls
    where parser_id = l_parser_id
    and UPPER(column_name) IN ('ADDRESSEE', 'EXTERNAL_REFERENCE', 'INCIDENT_ADDRESS1', 'INCIDENT_ADDRESS2',
                               'INCIDENT_ADDRESS3', 'INCIDENT_ADDRESS4', 'INCIDENT_CITY', 'INCIDENT_COUNTRY',
                               'INCIDENT_COUNTY', 'INCIDENT_POSTAL_CODE', 'INCIDENT_PROVINCE', 'INCIDENT_STATE',
                               'PROBLEM_CODE',  'SERVICE_REQUEST_TYPE', 'SITE_NAME', 'URGENCY', 'INVENTORY_ITEM_NAME')
    order by rank asc;

   CURSOR caller_type
   IS
   SELECT party_type
   FROM  hz_parties a
   WHERE a.party_id = g_customer_id
   AND	a.status = 'A'
   AND   a.party_type IN ('ORGANIZATION','PERSON');

    --local varaibles to store parsed tag data information
    --these local var are needed because these att will go through
    --double processing. Once for finding the customer_id and once for
    --fiding more information from those attr. There fore the loc
    --var will prevent an extra trip to get the parsed values
    l_account_number VARCHAR2(100);
    l_customer_number VARCHAR2(100);
    l_customer_name VARCHAR2(100);
    l_customer_phone VARCHAR2(100);
    l_customer_email VARCHAR2(100);
    l_instance_number VARCHAR2(100);
    l_instance_serial_number VARCHAR2(100);
    l_incident_site_number VARCHAR2(100);
    l_contact_number VARCHAR2(100);
    l_contact_name VARCHAR2(100);
    l_contact_phone VARCHAR2(100);
    l_contact_email VARCHAR2(100);

    --getting parsed inventory values
    --for all other attrbutee processing we will use tag_Data
    l_tag_data    VARCHAR2(1000);

    l_addressee                     VARCHAR2(100);
    l_external_reference            VARCHAR2(100);
    l_incident_address1             VARCHAR2(100);
    l_incident_address2             VARCHAR2(100);
    l_incident_address3             VARCHAR2(100);
    l_incident_address4             VARCHAR2(100);
    l_incident_city                 VARCHAR2(100);
    l_incident_country              VARCHAR2(100);
    l_incident_county               VARCHAR2(100);
    l_incident_postal_code          VARCHAR2(100);
    l_incident_province             VARCHAR2(100);
    l_incident_state                VARCHAR2(100);
    l_inventory_item_name           VARCHAR2(100);
    l_serial_number                 VARCHAR2(100);
    l_service_request_type          VARCHAR2(100);
    l_site_name                     VARCHAR2(100);
    l_urgency                       VARCHAR2(100);

    --for debuggin remove late
   lx_msg_data                 VARCHAR2(2000);
   lx_return_status            VARCHAR2(1);
   lx_msg_index_out            NUMBER;

   --logger
   l_logmessage		varchar2(2000):=' ';

  BEGIN

  --initialize all the global variables to null here to prevent session issues
  g_customer_id          := null;
  g_contact_party_id     := null;
  g_contact_party_type   := null;
  g_contact_point_id     := null;
  g_contact_point_type   := null;


    --assign the account_type to the global variable g_account_type
    --this global variabel will be later used in the contact processing
    l_logmessage:='account type '|| p_account_type;
    iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);

    g_account_type := p_account_type;

    -- process all the customer information tags to get customer_number
    --this will give us the req in sequence and we can process it for customer
    --note the internal getCustomerNumber procedure makes sure that if we have already
    --got a customer_id then dont try to fetch the customer_id
    IF (g_account_type = 'I') THEN

        l_logmessage:='Account type is of I ';
        iem_logger(l_logmessage);
        --dbms_output.put_line(l_logmessage);

         --we dont do any customer processing for internal accounts and use the default customer id
         g_customer_id := p_default_customer_id;
          l_logmessage:='Customer id used for internal processing is '||g_customer_id;
          iem_logger(l_logmessage);
          --dbms_output.put_line(l_logmessage);

         --if account type is of type I and the contact information has been passed in the email
         --then we should pick up the contact information from the email content otherwise we should
         --use the default
         FOR contact_rec in (Select start_tag, end_tag, column_name, rank
                                 from iem_parser_dtls
                                 where parser_id = p_parser_id
                                 and UPPER(column_name) IN ('CONTACT_PHONE','CONTACT_EMAIL')
                                 order by rank asc)
         LOOP
             IF (contact_rec.column_name = 'CONTACT_PHONE') THEN
                      BEGIN
                          l_contact_phone:= get_tag_data(contact_rec.start_tag, contact_rec.end_tag, p_message_id);
                          l_contact_phone:= REGEXP_REPLACE(l_contact_phone,'([[:punct:]|[:space:]]*)');
                          Select a.person_id, b.phone_id,  'PHONE','EMPLOYEE'
	                  into g_contact_party_id,g_contact_point_id, g_contact_point_type, g_contact_party_type
	                  from  per_workforce_x a,per_phones b
 			  where a.person_id = b.parent_id
	                  and REGEXP_REPLACE(b.phone_number,'([[:punct:]|[:space:]]*)') = l_contact_phone;
                      EXCEPTION
                          when TOO_MANY_ROWS then
                             l_logmessage:='internal contact phone:'||l_contact_phone||' fetch returned too many rows'|| SQL%ROWCOUNT;
                             iem_logger(l_logmessage);
                             --dbms_output.put_line(l_logmessage);
                             --plsql issue when there are many rows the first rows get associated with values
                              g_contact_party_id := null;
                              g_contact_point_id := null;
                              g_contact_point_type := null;
                              g_contact_party_type :=null;
                          when NO_DATA_FOUND then
                             l_logmessage:='contact phone:'||l_contact_phone||'  fetch returned 0 rows'|| SQL%ROWCOUNT;
                             iem_logger(l_logmessage);
                             --dbms_output.put_line(l_logmessage);
                          when others then
                             l_logmessage:='cotanct_phone:'||l_contact_phone||'  other exception';
                             iem_logger(l_logmessage);
                             --dbms_output.put_line(l_logmessage);
                      END;
             ELSIF (contact_rec.column_name = 'CONTACT_EMAIL') THEN
                      BEGIN
                          l_contact_email:= get_tag_data(contact_rec.start_tag, contact_rec.end_tag, p_message_id);
                          Select a.person_id, 'EMAIL','EMPLOYEE'
	                  into g_contact_party_id, g_contact_point_type , g_contact_party_type
	                  from per_workforce_current_x a
	                  where UPPER(a.email_Address) = upper(l_contact_email);
                      EXCEPTION
                          when TOO_MANY_ROWS then
                             l_logmessage:='internal contact email:'||l_contact_email||' fetch returned too many rows'|| SQL%ROWCOUNT;
                             iem_logger(l_logmessage);
                             --dbms_output.put_line(l_logmessage);
                             --plsql issue when there are many rows the first rows get associated with values
                              g_contact_party_id := null;
                              g_contact_point_type := null;
                              g_contact_party_type :=null;
                          when NO_DATA_FOUND then
                             l_logmessage:='contact email:'||l_contact_email||'  fetch returned 0 rows'|| SQL%ROWCOUNT;
                             iem_logger(l_logmessage);
                             --dbms_output.put_line(l_logmessage);
                          when others then
                             l_logmessage:='cotanct_email:'||l_contact_email||'  other exception';
                             iem_logger(l_logmessage);
                             --dbms_output.put_line(l_logmessage);
                      END;
            END IF; --end if of contact_phone and contact_Email
         END LOOP;
         -- if after the loop the values are still null then assign the default values
         IF g_contact_party_id IS NULL THEN
                    g_contact_party_id := p_contact_id;
                    g_contact_point_id := p_contact_point_id;
                    g_contact_point_type := 'EMAIL';
                    g_contact_party_type := 'EMPLOYEE';
         END IF;
    ELSE
      --dbms_output.put_line('customer_id proessing ');
      l_logmessage:='customer_id proessing ';
      iem_logger(l_logmessage);
      IF (g_customer_id IS NULL) THEN
          l_logmessage:='customer_id is null calling parser cursor ' || p_parser_id;
          --dbms_output.put_line('customer_id is null calling parser cursor ' || p_parser_id);
          iem_logger(l_logmessage);


       --this is where we will assign all the values so that we can process them later
       FOR r_sr_attr_assign IN c_customer_attributes(p_parser_id)
       LOOP

         IF r_sr_attr_assign.column_name ='CUSTOMER_NUMBER' THEN
           --dbms_output.put_line( r_sr_attr_assign.column_name || ' assigning ');
           l_logmessage:=r_sr_attr_assign.column_name || ' assigning ';
           iem_logger(l_logmessage);
           l_customer_number:= TO_NUMBER(get_tag_data(r_sr_attr_assign.start_tag, r_sr_attr_assign.end_tag, p_message_id));
         END IF;

         IF r_sr_attr_assign.column_name ='CUSTOMER_NAME' THEN
           --dbms_output.put_line(r_sr_attr_assign.column_name || ' assigning ');
           l_logmessage:=r_sr_attr_assign.column_name || ' assigning ';
           iem_logger(l_logmessage);
       	   l_customer_name:= get_tag_data (r_sr_attr_assign.start_tag, r_sr_attr_assign.end_tag, p_message_id);
         END IF;

         IF r_sr_attr_assign.column_name ='ACCOUNT_NUMBER' THEN
            --dbms_output.put_line( r_sr_attr_assign.column_name || ' assigning ');
            l_logmessage:=r_sr_attr_assign.column_name || ' assigning ';
            iem_logger(l_logmessage);
	    l_account_number:= get_tag_data (r_sr_attr_assign.start_tag, r_sr_attr_assign.end_tag, p_message_id);
         END IF;

         IF r_sr_attr_assign.column_name ='CUSTOMER_PHONE' THEN
           --dbms_output.put_line(  r_sr_attr_assign.column_name || ' assigning ');
           l_logmessage:=r_sr_attr_assign.column_name || ' assigning ';
           iem_logger(l_logmessage);
	   l_customer_phone:= get_tag_data (r_sr_attr_assign.start_tag, r_sr_attr_assign.end_tag, p_message_id);
         END IF;

         IF r_sr_attr_assign.column_name ='CUSTOMER_EMAIL' THEN
           --dbms_output.put_line( r_sr_attr_assign.column_name || ' assigning ');
           l_logmessage:=r_sr_attr_assign.column_name || ' assigning ';
           iem_logger(l_logmessage);
	   l_customer_email:= get_tag_data (r_sr_attr_assign.start_tag, r_sr_attr_assign.end_tag, p_message_id);
         END IF;

         IF r_sr_attr_assign.column_name ='INSTANCE_NUMBER' THEN
           --dbms_output.put_line(r_sr_attr_assign.column_name || ' assigning ');
           l_logmessage:=r_sr_attr_assign.column_name || ' assigning ';
           iem_logger(l_logmessage);
	   l_instance_number:= get_tag_data (r_sr_attr_assign.start_tag, r_sr_attr_assign.end_tag, p_message_id);
         END IF;

         IF r_sr_attr_assign.column_name ='INSTANCE_SERIAL_NUMBER' THEN
           --dbms_output.put_line(r_sr_attr_assign.column_name || ' assigning ');
           l_logmessage:=r_sr_attr_assign.column_name || ' assigning ';
           iem_logger(l_logmessage);
	   l_instance_serial_number:= get_tag_data (r_sr_attr_assign.start_tag, r_sr_attr_assign.end_tag, p_message_id);
         END IF;

         IF r_sr_attr_assign.column_name ='INCIDENT_SITE_NUMBER' THEN
           --dbms_output.put_line(r_sr_attr_assign.column_name || ' assigning ');
           l_logmessage:=r_sr_attr_assign.column_name || ' assigning ';
           iem_logger(l_logmessage);
	   l_incident_site_number:= get_tag_data (r_sr_attr_assign.start_tag, r_sr_attr_assign.end_tag, p_message_id);
         END IF;

         IF r_sr_attr_assign.column_name ='CONTACT_NUMBER' THEN
           --dbms_output.put_line(r_sr_attr_assign.column_name || ' assigning ');
           l_logmessage:=r_sr_attr_assign.column_name || ' assigning ';
           iem_logger(l_logmessage);
	   l_contact_number:= get_tag_data (r_sr_attr_assign.start_tag, r_sr_attr_assign.end_tag, p_message_id);
         END IF;

         IF r_sr_attr_assign.column_name ='CONTACT_NAME' THEN
          --dbms_output.put_line(r_sr_attr_assign.column_name || ' assigning ');

          l_logmessage:=r_sr_attr_assign.column_name || ' assigning ';
          iem_logger(l_logmessage);
	   l_contact_name:= get_tag_data (r_sr_attr_assign.start_tag, r_sr_attr_assign.end_tag, p_message_id);
         END IF;

         IF r_sr_attr_assign.column_name ='CONTACT_PHONE' THEN
          --dbms_output.put_line(r_sr_attr_assign.column_name || ' assigning ');
          l_logmessage:=r_sr_attr_assign.column_name || ' assigning ';
          iem_logger(l_logmessage);
	   l_contact_phone:= get_tag_data (r_sr_attr_assign.start_tag, r_sr_attr_assign.end_tag, p_message_id);
         END IF;

         IF r_sr_attr_assign.column_name ='CONTACT_EMAIL' THEN
          --dbms_output.put_line(r_sr_attr_assign.column_name || ' assigning ');
          l_logmessage:=r_sr_attr_assign.column_name || ' assigning ';
          iem_logger(l_logmessage);
          --dbms_output.put_line(' passing contact_email_tag - starttag:'||r_sr_attr_assign.start_tag);
	   l_contact_email:= get_tag_data (r_sr_attr_assign.start_tag, r_sr_attr_assign.end_tag, p_message_id);
         END IF;
       END LOOP;

  ---end of value assignment




       FOR r_sr_attr IN c_customer_attributes(p_parser_id)
       LOOP

         IF r_sr_attr.column_name ='CUSTOMER_NUMBER' THEN
           --dbms_output.put_line( r_sr_attr.column_name || ' proessing ');
           l_logmessage:=r_sr_attr.column_name || ' proessing ';
           iem_logger(l_logmessage);
	   getCustomerNumber (p_customer_number => l_customer_number,
       		              x_customer_id     => g_customer_id);
         END IF;

         IF r_sr_attr.column_name ='CUSTOMER_NAME' THEN
           --dbms_output.put_line( r_sr_attr.column_name || ' proessing ');
           l_logmessage:=r_sr_attr.column_name || ' proessing ';
           iem_logger(l_logmessage);
	   getCustomerNumber (p_customer_name => l_customer_name,
       	      	              x_customer_id   => g_customer_id);
         END IF;

         IF r_sr_attr.column_name ='ACCOUNT_NUMBER' THEN
          --dbms_output.put_line( r_sr_attr.column_name || ' proessing ');
          l_logmessage:=r_sr_attr.column_name || ' proessing ';
          iem_logger(l_logmessage);
            getCustomerNumber (p_account_number => l_account_number,
                               x_customer_id => g_customer_id);
         END IF;

         IF r_sr_attr.column_name ='CUSTOMER_PHONE' THEN
          --dbms_output.put_line(  r_sr_attr.column_name || ' proessing ');
          l_logmessage:=r_sr_attr.column_name || ' proessing ';
          iem_logger(l_logmessage);
	   getCustomerNumber (p_customer_phone => l_customer_phone,
       	      	              x_customer_id   => g_customer_id);
         END IF;

         IF r_sr_attr.column_name ='CUSTOMER_EMAIL' THEN
          --dbms_output.put_line( r_sr_attr.column_name || ' proessing ');
          l_logmessage:=r_sr_attr.column_name || ' proessing ';
          iem_logger(l_logmessage);
	   getCustomerNumber (p_customer_email => l_customer_email,
       	      	              x_customer_id   => g_customer_id);
         END IF;

         IF r_sr_attr.column_name ='INSTANCE_NUMBER' THEN
          --dbms_output.put_line(r_sr_attr.column_name || ' proessing ');
          l_logmessage:=r_sr_attr.column_name || ' proessing ';
          iem_logger(l_logmessage);
	   getCustomerNumber (p_instance_number => l_instance_number,
       	      	              x_customer_id   => g_customer_id);
         END IF;

         IF r_sr_attr.column_name ='INSTANCE_SERIAL_NUMBER' THEN
          --dbms_output.put_line(r_sr_attr.column_name || ' proessing ');
          l_logmessage:=r_sr_attr.column_name || ' proessing ';
          iem_logger(l_logmessage);
	   getCustomerNumber (p_instance_serial_number => l_instance_serial_number,
       	      	              x_customer_id   => g_customer_id);
         END IF;

         IF r_sr_attr.column_name ='INCIDENT_SITE_NUMBER' THEN
          --dbms_output.put_line(r_sr_attr.column_name || ' proessing ');
          l_logmessage:=r_sr_attr.column_name || ' proessing ';
          iem_logger(l_logmessage);
	   getCustomerNumber (p_incident_site_number => l_incident_site_number,
       	      	              x_customer_id   => g_customer_id);
         END IF;

         IF r_sr_attr.column_name ='CONTACT_NUMBER' THEN
          --dbms_output.put_line(r_sr_attr.column_name || ' proessing ');
          l_logmessage:=r_sr_attr.column_name || ' proessing ';
          iem_logger(l_logmessage);
	   getCustomerNumber (p_contact_number => l_contact_number,
       	      	              x_customer_id   => g_customer_id);
         END IF;

         IF r_sr_attr.column_name ='CONTACT_NAME' THEN
          --dbms_output.put_line(r_sr_attr.column_name || ' proessing ');

          l_logmessage:=r_sr_attr.column_name || ' proessing ';
          iem_logger(l_logmessage);
	   getCustomerNumber (p_contact_name => l_contact_name,
       	      	              x_customer_id   => g_customer_id);
         END IF;

         IF r_sr_attr.column_name ='CONTACT_PHONE' THEN
          --dbms_output.put_line(r_sr_attr.column_name || ' proessing ');
          l_logmessage:=r_sr_attr.column_name || ' proessing ';
          iem_logger(l_logmessage);
	   getCustomerNumber (p_contact_phone => l_contact_phone,
       	      	              x_customer_id   => g_customer_id);
         END IF;

         IF r_sr_attr.column_name ='CONTACT_EMAIL' THEN
          --dbms_output.put_line(r_sr_attr.column_name || ' proessing ');
          l_logmessage:=r_sr_attr.column_name || ' proessing ';
          iem_logger(l_logmessage);
	   getCustomerNumber (p_contact_email => l_contact_email,
       	      	              x_customer_id   => g_customer_id);
         END IF;

         --exit out of the loop if g_customer_id has been found
         --dbms_output.put_line(' G_CUSTOMER_ID in the loop is ' || g_customer_id);
         l_logmessage:=' G_CUSTOMER_ID in the loop is ' || g_customer_id;
          iem_logger(l_logmessage);
         EXIT WHEN g_customer_id IS NOT NULL;

       END LOOP;
       --if after going throug the loop to find g_Customer_id was
       --not found then we should give it the default customer_id which got passed
       --we should exit this program if there is not defulat_Customer_id
       --IF (g_customer_id IS NULL) AND (p_default_customer_id >0) THEN
        --issue this i
       IF (g_customer_id IS NULL) THEN
           g_customer_id := p_default_customer_id;
       ELSIF ((g_customer_id is NULL) AND (p_default_customer_id IS NULL)) THEN
             --exit out of the program and dont do anything
           --dbms_output.put_line('Exiting plsql procedure no customer_id found');
           l_logmessage:=' Exiting plsql procedure no customer_id found';
          iem_logger(l_logmessage);
           x_return_status:= 'E';
           x_msg_count:= 1;
           x_msg_data:= 'Exiting out of the procedure because no customer_id found';

          --return statement will exit out of the procedure
           RETURN;
       END IF;
    END IF; --end of weather g_cutomer_id existance check
   END IF; --end of customer_type check

    --once we have found the customer_id information we will use the same cursor
    --to find additinal information
      --Question: Should we even do the processing for all the attributes if we were not
      --able to find a customer_id and if are using the default customer_id ..
      -- so bascially should we check over here if g_customer_id <> p_default_customer_id
      --then only do this processing other wise why even bother with these processing with the
      --default customer_id.
    FOR r_sr_cust_attr IN c_customer_attributes(p_parser_id)
    LOOP
         IF ((r_sr_cust_attr.column_name ='ACCOUNT_NUMBER') AND (l_account_number IS NOT NULL)) THEN
           --dbms_output.put_line('Detailed '||r_sr_cust_attr.column_name || ' processing - 2nloop');
           l_logmessage:=' Detailed '||r_sr_cust_attr.column_name || ' processing - 2nloop' ;
          iem_logger(l_logmessage);
            getAccountNumber (p_account_number => l_account_number,
                               x_cust_account_id => l_cust_account_id);
         END IF;

         IF ((r_sr_cust_attr.column_name ='CUSTOMER_PHONE') AND (l_customer_phone IS NOT NULL)) THEN
           --dbms_output.put_line('Detailed '||r_sr_cust_attr.column_name || ' processing - 2nloop');
           l_logmessage:=' Detailed '||r_sr_cust_attr.column_name || ' processing - 2nloop' ;
          iem_logger(l_logmessage);
	   getCustomerPhone (p_customer_phone => l_customer_phone,
       	      	              x_customer_phone_id   => l_customer_phone_id);
         END IF;

         IF ((r_sr_cust_attr.column_name ='CUSTOMER_EMAIL') AND (l_customer_email IS NOT NULL)) THEN
           --dbms_output.put_line('Detailed '||r_sr_cust_attr.column_name || ' processing - 2nloop');
           l_logmessage:=' Detailed '||r_sr_cust_attr.column_name || ' processing - 2nloop' ;
          iem_logger(l_logmessage);
	   getCustomerEmail (p_customer_email => l_customer_email,
       	      	             x_customer_email_id   => l_customer_email_id);
         END IF;

         --putting in additional condition because if we have already found thesse values
         --that means we should honor those values and should not find them again as they
         --have been found with attributes that had a higer rank
         IF ((r_sr_cust_attr.column_name ='INSTANCE_NUMBER') AND (l_customer_product_id IS NULL)
              AND (l_inventory_item_id IS NULL) AND (l_instance_number IS NOT NULL))
         THEN
           --dbms_output.put_line('Detailed '||r_sr_cust_attr.column_name || ' processing - 2nloop');
           l_logmessage:=' Detailed '||r_sr_cust_attr.column_name || ' processing - 2nloop' ;
          iem_logger(l_logmessage);
           getInstanceNumber (p_instance_number     => l_instance_number,
                              p_cust_account_id     => l_cust_account_id,
                              x_customer_product_id => l_customer_product_id,
                              x_inventory_org_id => l_inventory_org_id,
                              x_inventory_item_id   => l_inventory_item_id);
         END IF;

         IF ((r_sr_cust_attr.column_name ='INSTANCE_SERIAL_NUMBER') AND (l_customer_product_id IS NULL)
              AND (l_inventory_item_id IS NULL) AND (l_instance_serial_number IS NOT NULL))
         THEN
           --dbms_output.put_line('Detailed '||r_sr_cust_attr.column_name || ' processing - 2nloop');
           l_logmessage:=' Detailed '||r_sr_cust_attr.column_name || ' processing - 2nloop' ;
          iem_logger(l_logmessage);
           getInstanceSerialNumber
                             (p_instance_serial_number     => l_instance_serial_number,
                              p_cust_account_id            => l_cust_account_id,
                              x_customer_product_id        => l_customer_product_id,
                              x_inventory_org_id           => l_inventory_org_id,
                              x_inventory_item_id          => l_inventory_item_id);
         END IF;

         IF ((r_sr_cust_attr.column_name ='INCIDENT_SITE_NUMBER') AND (l_incident_site_number is not null))  THEN
           --dbms_output.put_line('Detailed '||r_sr_cust_attr.column_name || ' processing - 2nloop');
           l_logmessage:=' Detailed '||r_sr_cust_attr.column_name || ' processing - 2nloop' ;
          iem_logger(l_logmessage);
	   getIncidentSiteNumber (p_incident_site_number => l_incident_site_number,
       	      	                  x_incident_location_id   => l_incident_location_id);
         END IF;

         --all the contact related stuff should be there from customer processing so
         --we will pass all the contact related values to its procdure here
         --process the contact related information only if
         --type is external and g_customer_id not null and g_contact_party_id is null or g_contact_
         IF ((g_contact_party_id IS NULL) AND (g_customer_id IS NOT NULL)
             AND (r_sr_cust_attr.column_name ='CONTACT_NUMBER') AND (l_contact_number IS NOT NULL))
         THEN
           --dbms_output.put_line('Detailed '||r_sr_cust_attr.column_name || ' processing - 2nloop');
           l_logmessage:=' Detailed '||r_sr_cust_attr.column_name || ' processing - 2nloop' ;
           iem_logger(l_logmessage);
             getContactNumber (p_contact_number => l_contact_number,
                              p_parser_id       => p_parser_id ,
                              p_contact_phone   => l_contact_phone,
                              p_contact_email  => l_contact_email,
                              x_contact_party_id  => g_contact_party_id,
                              x_contact_type      => g_contact_party_type,
                              x_contact_point_type  => g_contact_point_type,
                              x_contact_point_id  => g_contact_point_id);

         END IF;

         IF ((g_contact_party_id IS NULL) AND (g_customer_id IS NOT NULL)
             AND (r_sr_cust_attr.column_name ='CONTACT_NAME') AND (l_contact_name IS NOT NULL))
         THEN
            --dbms_output.put_line('Detailed '||r_sr_cust_attr.column_name || ' processing - 2nloop');
            l_logmessage:=' Detailed '||r_sr_cust_attr.column_name || ' processing - 2nloop' ;
            iem_logger(l_logmessage);
                l_logmessage:='before contact_name-call'||l_contact_name||'--partyid:'||g_contact_party_id||'point_id:'||g_contact_point_id ;
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
            getContactName (p_contact_name       => l_contact_name,
                              p_parser_id        => p_parser_id ,
                              p_contact_phone    => l_contact_phone,
                              p_contact_email   => l_contact_email,
                              x_contact_party_id  => g_contact_party_id,
                              x_contact_type      => g_contact_party_type,
                              x_contact_point_type  => g_contact_point_type,
                              x_contact_point_id  => g_contact_point_id);

                l_logmessage:='after contact_name-call'||l_contact_name||'--partyid:'||g_contact_party_id||'point_id'||g_contact_point_id ;
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
         END IF;

         IF ((g_contact_party_id IS NULL) AND (g_customer_id IS NOT NULL)
             AND (r_sr_cust_attr.column_name ='CONTACT_PHONE') AND (l_contact_phone IS NOT NULL))
         THEN
           --dbms_output.put_line('Detailed '||r_sr_cust_attr.column_name || ' processing - 2nloop');
            l_logmessage:=' Detailed '||r_sr_cust_attr.column_name || ' processing - 2nloop' ;
          iem_logger(l_logmessage);
            getContactPhone (p_contact_phone   => l_contact_phone,
                              x_contact_party_id  => g_contact_party_id,
                              x_contact_type      => g_contact_party_type,
                              x_contact_point_type  => g_contact_point_type,
                              x_contact_point_id  => g_contact_point_id);

         END IF;

         IF ((g_contact_party_id IS NULL) AND (g_customer_id IS NOT NULL)
             AND (r_sr_cust_attr.column_name ='CONTACT_EMAIL') AND (l_contact_email IS NOT NULL))
         THEN
           --dbms_output.put_line('Detailed '||r_sr_cust_attr.column_name || ' processing - 2nloop');
            l_logmessage:=' Detailed '||r_sr_cust_attr.column_name || ' processing - 2nloop' ;
          iem_logger(l_logmessage);
           --dbms_output.put_line('contact_email is: '||l_contact_email);
            getContactEmail (p_contact_email   => l_contact_email,
                              x_contact_party_id  => g_contact_party_id,
                              x_contact_type      => g_contact_party_type,
                              x_contact_point_type  => g_contact_point_type,
                              x_contact_point_id  => g_contact_point_id);

         END IF;

    END LOOP;

    --process all the other attributes
    FOR r_sr_other_attr IN c_other_attributes(p_parser_id)
    LOOP
       IF (r_sr_other_attr.column_name = 'INVENTORY_ITEM_NAME') THEN
           --dbms_output.put_line(r_sr_other_attr.column_name || ' processing - other Attributes' );
           l_logmessage:= r_sr_other_attr.column_name || ' processing - other Attributes' ;
          iem_logger(l_logmessage);
           l_tag_data:= get_tag_data (r_sr_other_attr.start_tag, r_sr_other_attr.end_tag, p_message_id);
            if l_tag_data IS NOT NULL THEN
              getInventoryItemName (p_inventory_item_name => l_tag_data,
                                    x_inventory_item_id   => l_inventory_item_id,
                                    x_inventory_org_id    => l_inventory_org_id);
             --set the tag_data to null for next processing
            END IF;
             l_tag_data := null;
       END IF;

       IF (r_sr_other_attr.column_name = 'SERVICE_REQUEST_TYPE') THEN
           --dbms_output.put_line(r_sr_other_attr.column_name || ' processing - other Attributes' );
           l_logmessage:= r_sr_other_attr.column_name || ' processing - other Attributes' ;
          iem_logger(l_logmessage);
           l_tag_data:= get_tag_data (r_sr_other_attr.start_tag, r_sr_other_attr.end_tag, p_message_id);
           if l_tag_data IS NOT NULL THEN
             getServiceRequestType (p_service_request_type => l_tag_data,
                                    p_default_type_id     => p_default_type_id,
	                            x_type_id             => l_type_id);
           --set the tag_data to null for next processing
           END IF;
            l_tag_data := null;

       END IF;

       IF (r_sr_other_attr.column_name = 'PROBLEM_CODE') THEN
           --dbms_output.put_line(r_sr_other_attr.column_name || ' processing - other Attributes' );
           l_logmessage:= r_sr_other_attr.column_name || ' processing - other Attributes' ;
          iem_logger(l_logmessage);
           l_tag_data:= get_tag_data (r_sr_other_attr.start_tag, r_sr_other_attr.end_tag, p_message_id);
           if l_tag_data IS NOT NULL THEN
             getProblemCode (p_problem_code => l_tag_data,
                             x_problem_code => l_problem_code);
            --set the tag_data to null for next processing
           END IF;
            l_tag_data := null;
       END IF;

       IF (r_sr_other_attr.column_name = 'URGENCY') THEN
           --dbms_output.put_line(r_sr_other_attr.column_name || ' processing - other Attributes' );
           l_logmessage:= r_sr_other_attr.column_name || ' processing - other Attributes' ;
          iem_logger(l_logmessage);
           l_tag_data:= get_tag_data (r_sr_other_attr.start_tag, r_sr_other_attr.end_tag, p_message_id);
            getUrgency (p_urgency => l_tag_data,
                        x_urgency_id => l_urgency_id);
           --set the tag_data to null for next processing
           l_tag_data := null;
       END IF;

       IF (r_sr_other_attr.column_name = 'SITE_NAME') THEN
           --dbms_output.put_line(r_sr_other_attr.column_name || ' processing - other Attributes' );
           l_logmessage:= r_sr_other_attr.column_name || ' processing - other Attributes' ;
          iem_logger(l_logmessage);
           l_tag_data := get_tag_data (r_sr_other_attr.start_tag, r_sr_other_attr.end_tag, p_message_id);
            getSiteName(p_site_name    => l_tag_data,
                        x_party_site_id  => l_party_site_id);
          --set the tag_data to null for next processing
           l_tag_data := null;
       END IF;

       IF (r_sr_other_attr.column_name = 'EXTERNAL_REFERENCE') THEN
           --dbms_output.put_line(r_sr_other_attr.column_name || ' processing - other Attributes' );
           l_logmessage:= r_sr_other_attr.column_name || ' processing - other Attributes' ;
          iem_logger(l_logmessage);
           l_tag_data := get_tag_data (r_sr_other_attr.start_tag, r_sr_other_attr.end_tag, p_message_id);
           --we should have found l_customer_id from the customer related processing already
           --if the l_customer_id does not exist then there is no point calling the sub procedure
           IF l_customer_product_id is not null THEN
            getExtReference(p_ext_ref => l_tag_data,
                            p_customer_product_id => l_customer_product_id,
                            x_ext_ref          => l_ext_ref);
           END IF;
          --set the tag_data to null for next processing
           l_tag_data := null;
       END IF;

       IF (r_sr_other_attr.column_name = 'ADDRESSEE') THEN
           --dbms_output.put_line(r_sr_other_attr.column_name || ' processing - other Attributes' );
           l_logmessage:= r_sr_other_attr.column_name || ' processing - other Attributes' ;
          iem_logger(l_logmessage);
           l_addressee:= get_tag_data (r_sr_other_attr.start_tag, r_sr_other_attr.end_tag, p_message_id);
       END IF;
       IF (r_sr_other_attr.column_name = 'INCIDENT_ADDRESS1') THEN
           --dbms_output.put_line(r_sr_other_attr.column_name || ' processing - other Attributes' );
           l_logmessage:= r_sr_other_attr.column_name || ' processing - other Attributes' ;
          iem_logger(l_logmessage);
           l_incident_address1:= get_tag_data (r_sr_other_attr.start_tag, r_sr_other_attr.end_tag, p_message_id);
       END IF;
       IF (r_sr_other_attr.column_name = 'INCIDENT_ADDRESS2') THEN
           --dbms_output.put_line(r_sr_other_attr.column_name || ' processing - other Attributes' );
           l_logmessage:= r_sr_other_attr.column_name || ' processing - other Attributes' ;
          iem_logger(l_logmessage);
           l_incident_address2:= get_tag_data (r_sr_other_attr.start_tag, r_sr_other_attr.end_tag, p_message_id);
       END IF;
       IF (r_sr_other_attr.column_name = 'INCIDENT_ADDRESS3') THEN
           --dbms_output.put_line(r_sr_other_attr.column_name || ' processing - other Attributes' );
           l_logmessage:= r_sr_other_attr.column_name || ' processing - other Attributes' ;
          iem_logger(l_logmessage);
           l_incident_address3:= get_tag_data (r_sr_other_attr.start_tag, r_sr_other_attr.end_tag, p_message_id);
       END IF;
       IF (r_sr_other_attr.column_name = 'INCIDENT_ADDRESS4') THEN
           --dbms_output.put_line(r_sr_other_attr.column_name || ' processing - other Attributes' );
           l_logmessage:= r_sr_other_attr.column_name || ' processing - other Attributes' ;
          iem_logger(l_logmessage);
           l_incident_address4:= get_tag_data (r_sr_other_attr.start_tag, r_sr_other_attr.end_tag, p_message_id);
       END IF;
       IF (r_sr_other_attr.column_name = 'INCIDENT_CITY') THEN
           --dbms_output.put_line(r_sr_other_attr.column_name || ' processing - other Attributes' );
           l_logmessage:= r_sr_other_attr.column_name || ' processing - other Attributes' ;
          iem_logger(l_logmessage);
           l_incident_city:= get_tag_data (r_sr_other_attr.start_tag, r_sr_other_attr.end_tag, p_message_id);
       END IF;
       IF (r_sr_other_attr.column_name = 'INCIDENT_COUNTRY') THEN
           --dbms_output.put_line(r_sr_other_attr.column_name || ' processing - other Attributes' );
           l_logmessage:= r_sr_other_attr.column_name || ' processing - other Attributes' ;
          iem_logger(l_logmessage);
           l_incident_country:= get_tag_data (r_sr_other_attr.start_tag, r_sr_other_attr.end_tag, p_message_id);
       END IF;
       IF (r_sr_other_attr.column_name = 'INCIDENT_COUNTY') THEN
           --dbms_output.put_line(r_sr_other_attr.column_name || ' processing - other Attributes' );
           l_logmessage:= r_sr_other_attr.column_name || ' processing - other Attributes' ;
          iem_logger(l_logmessage);
           l_incident_county:= get_tag_data (r_sr_other_attr.start_tag, r_sr_other_attr.end_tag, p_message_id);
       END IF;
       IF (r_sr_other_attr.column_name = 'INCIDENT_POSTAL_CODE') THEN
           --dbms_output.put_line(r_sr_other_attr.column_name || ' processing - other Attributes' );
           l_logmessage:= r_sr_other_attr.column_name || ' processing - other Attributes' ;
          iem_logger(l_logmessage);
           l_incident_postal_code:= get_tag_data (r_sr_other_attr.start_tag, r_sr_other_attr.end_tag, p_message_id);
       END IF;
       IF (r_sr_other_attr.column_name = 'INCIDENT_PROVINCE') THEN
           --dbms_output.put_line(r_sr_other_attr.column_name || ' processing - other Attributes' );
           l_logmessage:= r_sr_other_attr.column_name || ' processing - other Attributes' ;
          iem_logger(l_logmessage);
           l_incident_province:= get_tag_data (r_sr_other_attr.start_tag, r_sr_other_attr.end_tag, p_message_id);
       END IF;
       IF (r_sr_other_attr.column_name = 'INCIDENT_STATE') THEN
           --dbms_output.put_line(r_sr_other_attr.column_name || ' processing - other Attributes' );
           l_logmessage:= r_sr_other_attr.column_name || ' processing - other Attributes' ;
          iem_logger(l_logmessage);
           l_incident_state:= get_tag_data (r_sr_other_attr.start_tag, r_sr_other_attr.end_tag, p_message_id);
       END IF;
       IF (r_sr_other_attr.column_name = 'SERIAL_NUMBER') THEN
           --dbms_output.put_line(r_sr_other_attr.column_name || ' processing - other Attributes' );
           l_logmessage:= r_sr_other_attr.column_name || ' processing - other Attributes' ;
          iem_logger(l_logmessage);
           l_serial_number:= get_tag_data (r_sr_other_attr.start_tag, r_sr_other_attr.end_tag, p_message_id);
       END IF;

    END LOOP;

      -- create the srevice record with the returned values
      --create_sr start
      -- Initialize message list if p_init_msg_list is set to TRUE.
      -- Standard Start of API savepoint
    BEGIN
       SAVEPOINT  ADVANCED_CREATE_SR;

    -- Standard call to check for call compatibility.
  /*
      IF NOT FND_API.Compatible_API_Call (l_api_version_number,
          1.0,
          l_api_name,
          G_PKG_NAME)
     THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
  */

    l_logmessage:='Came to create SR  ' ;
          iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);

  -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
      FND_MSG_PUB.initialize;
    END IF;

     FND_PROFILE.Get('IEM_SR_SUM_PREFIX', l_summary_prefix);
     l_summary :=  l_summary_prefix||' : '|| p_subject ;

        l_logmessage:='customer _id is '|| g_customer_id ;
          iem_logger(l_logmessage);
        --dbms_output.put_line(l_logmessage);
       CS_ServiceRequest_PUB.initialize_rec(l_service_request_rec);


  OPEN caller_type;
  FETCH caller_type INTO l_party_type;

  IF (caller_type%NOTFOUND) THEN
          l_logmessage:='caller type fail for customer_id '|| g_customer_id ;
          iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);
    x_return_status := FND_API.G_RET_STS_ERROR;
    CLOSE caller_type;
  END IF;

  CLOSE caller_type;

    -- sr can not be created without the sr_type_id if it did not go throught
    --any processing then just use what was passed in from via the calling program
     if l_type_id IS NULL THEN
        l_type_id := p_default_type_id;
     END IF;

    --siahmed changes made on jul30, 2009
    --change in the scenario to find account_id. If the customer g_customer_id has been found then we
    --try to find the account_id using the customer_id
       l_logmessage:='starting p_account_id fetch before sr creation';
       iem_logger(l_logmessage);
       --dbms_output.put_line(l_logmessage);

    IF (l_cust_account_id is NULL  AND g_customer_id is NOT NULL) THEN
       l_logmessage:='inside p_account_id fetch before sr creation';
       iem_logger(l_logmessage);
       --dbms_output.put_line(l_logmessage);
       BEGIN
	     select cust_account_id into l_cust_account_id
	     from hz_cust_accounts
	     where party_id =g_customer_id;
       EXCEPTION
             when TOO_MANY_ROWS then
                l_logmessage:='p_account_id fetch before sr creation  too many rows'|| SQL%ROWCOUNT;
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
                l_cust_account_id := null;
             when NO_DATA_FOUND then
                l_logmessage:='p_account_id fetch before sr creation returned 0 rows'|| SQL%ROWCOUNT;
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
             when others then
               l_logmessage:='p_account_id fetch  other exception'|| SQLCODE||'-ERROR- '||SQLERRM ;
               iem_logger(l_logmessage);
               --dbms_output.put_line(l_logmessage);
      END;
    END IF;


    l_logmessage:='p_account_id or l_cust_account_id or account_id :'|| l_cust_account_id ;
    iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);


    l_logmessage:='party type   '|| l_party_type ;
    iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);

    l_logmessage:='sr type_id   '|| l_type_id ;
    iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);

    l_logmessage:='add1:'|| l_incident_address1 ||'address2:'||l_incident_address2||'add3:'||l_incident_address3||'add4:'||l_incident_address4 ;
    iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);

    l_logmessage:='city:'|| l_incident_city ||'country:'||l_incident_country||'county:'||l_incident_county||'post:'||l_incident_postal_code ;
    iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);

      l_service_request_rec.caller_type  := l_party_type; -- 'ORGANIZATION'/'PERSON';
     --needed attributes
       l_service_request_rec.severity_id                := 4;
       --l_service_request_rec.status_id                  := 1;

       l_service_request_rec.type_id                  := l_type_id;
       l_service_request_rec.summary                  := l_summary;
       l_service_request_rec.customer_id              := g_customer_id;
       l_service_request_rec.sr_creation_channel      := 'EMAIL';
       l_service_request_rec.creation_program_code    := 'EMAILCENTER';

       l_service_request_rec.urgency_id               :=  l_urgency_id;
       --l_service_request_rec.caller_type := p_service_request_rec.caller_type;
       l_service_request_rec.customer_product_id       := l_customer_product_id;
       l_service_request_rec.inventory_item_id         := l_inventory_item_id ;
       l_service_request_rec.inventory_org_id          := l_inventory_org_id ;
       l_service_request_rec.problem_code              := l_problem_code;
       l_service_request_rec.account_id                := l_cust_account_id;
       l_service_request_rec.incident_location_id      := l_incident_location_id;
       l_service_request_rec.site_id                   := l_party_site_id;
       l_service_request_rec.customer_phone_id        := l_customer_phone_id;
       l_service_request_rec.customer_email_id        := l_customer_email_id;
       l_service_request_rec.external_reference        := l_ext_ref;
       --l_service_request_rec.addressee                 := l_addressee;
       l_service_request_rec.incident_Address          := l_incident_address1;
       l_service_request_rec.incident_Address2         := l_incident_address2;
       l_service_request_rec.incident_Address3         := l_incident_address3;
       l_service_request_rec.incident_Address4         := l_incident_address4;
       l_service_request_rec.incident_city              := l_incident_city;
       l_service_request_rec.incident_country           := l_incident_country ;
       l_service_request_rec.incident_county            := l_incident_county    ;
       l_service_request_rec.incident_postal_code       := l_incident_postal_code;
       l_service_request_rec.incident_province         := l_incident_province    ;
       l_service_request_rec.incident_state             :=l_incident_state       ;
       l_service_request_rec.current_serial_number      := l_serial_number;


        l_index := 1;
        l_notes(l_index).NOTE                       := p_note ;
        l_notes(l_index).NOTE_TYPE                  := p_NOTE_TYPE;

     If g_contact_party_id IS NOT NULL THEN
      --contact stuff

        l_logmessage:='contact party id :' ||g_contact_party_id ;
          iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);
        l_logmessage:='contact point id  :'|| g_contact_point_id ;
          iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);
        l_logmessage:='contact party_type  :'|| g_contact_party_type ;
          iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);
        l_logmessage:='contact point_type  :'|| g_contact_point_type ;
          iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);
        l_logmessage:='contact party role code  :'|| g_party_role_code ;
          iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);
      l_index := 1;
        l_contacts(l_index).PARTY_ID                   := g_contact_party_id;
        l_contacts(l_index).contact_point_id           := g_contact_point_id;
        l_contacts(l_index).contact_point_type         := g_contact_point_type;
        l_contacts(l_index).CONTACT_TYPE               := g_contact_party_type;
        l_contacts(l_index).party_role_code            := g_party_role_code;
        l_contacts(l_index).primary_flag            := 'Y';
     END IF;

       l_auto_assign := fnd_profile.value('CS_AUTO_ASSIGN_OWNER_HTML');
       l_coverage_template_id:=fnd_profile.value_specific('CS_SR_DEFAULT_COVERAGE');

        l_logmessage:='start calling service request' ;
          iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);
      CS_ServiceRequest_PUB.Create_ServiceRequest (
                  p_api_version           => l_cs_version_number,
                  p_init_msg_list         => FND_API.G_FALSE,
                  p_commit	          => FND_API.G_FALSE,
                  x_return_status         => l_return_status,
                  x_msg_count             => l_msg_count,
                  x_msg_data              => l_msg_data,
                  p_resp_appl_id	  => NULL,
                  p_resp_id		  => NULL,
                  p_user_id		  => 1318,
                  p_login_id		  => NULL,
                  p_org_id		  => NULL,
                  p_request_id            => NULL,
                  p_request_number	  => NULL,
                  p_service_request_rec   => l_service_request_rec,
                  p_notes                 => l_notes,
                  p_contacts              => l_contacts,
                  p_auto_assign           => l_auto_assign,
                  p_auto_generate_tasks		  => 'N',
                  x_sr_create_out_rec	  	  => l_sr_create_out_rec,
                  -- added by siahmed for fixing the bug 8251673
                  p_default_contract_sla_ind	  => 'Y',
                  p_default_coverage_template_id  => l_coverage_template_id
                  --end of addition by siahmed for fixing the bug 8251673
                  );

     if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
        l_logmessage:='raise IEM_SR_NOT_CREATE ' ;
          iem_logger(l_logmessage);
          --dbms_output.put_line(l_logmessage);
        raise IEM_SR_NOT_CREATE;
     --end if;
     ELSIF  (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        IF (FND_MSG_PUB.Count_Msg > 1) THEN
         --Display all the warning messages
         FOR j in  1..FND_MSG_PUB.Count_Msg LOOP
            FND_MSG_PUB.Get(
               p_msg_index     => j,
               p_encoded       => 'F',
               p_data          => lx_msg_data,
               p_msg_index_out => lx_msg_index_out);

              l_logmessage:= 'MESSAGE INDEX3 = ' || lx_msg_index_out;
              iem_logger(l_logmessage);
              --dbms_output.put_line(l_logmessage);

              l_logmessage:='MESSAGE3 = ' || substr(lx_msg_data ,1,150) ;
              iem_logger(l_logmessage);
              --dbms_output.put_line(l_logmessage);
         END LOOP;
       ELSE
         --Only one warning
         FND_MSG_PUB.Get(
            p_msg_index     => 1,
            p_encoded       => 'F',
            p_data          => lx_msg_data,
            p_msg_index_out => lx_msg_index_out);

          l_logmessage:= 'MESSAGE INDEX4 = ' || lx_msg_index_out;
          iem_logger(l_logmessage);
          --dbms_output.put_line(l_logmessage);

          l_logmessage:='MESSAGE4 = ' || substr(lx_msg_data,1,200);
          iem_logger(l_logmessage);
          --dbms_output.put_line(l_logmessage);

          l_logmessage:='MESSAGE4 = ' || substr(lx_msg_data,201);
          iem_logger(l_logmessage);
          --dbms_output.put_line(l_logmessage);

        END IF;
    END IF;

     l_logmessage:='INSERTED REQUEST ID  : ' || l_sr_create_out_rec.request_id ;
     iem_logger(l_logmessage);
     --dbms_output.put_line(l_logmessage);

     l_logmessage:='INSERTED REQUEST NUM : ' || l_sr_create_out_rec.request_number;
     iem_logger(l_logmessage);
     --dbms_output.put_line(l_logmessage);


     l_logmessage:='MESSAGE COUNT = ' || l_msg_count;
     iem_logger(l_logmessage);
     --dbms_output.put_line(l_logmessage);


     x_return_status := l_return_status ;
     x_request_id     := l_sr_create_out_rec.request_id;

   --Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

   EXCEPTION
      WHEN IEM_SR_NOT_CREATE THEN
          ROLLBACK TO ADVANCED_CREATE_SR;
          x_return_status := l_return_status ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

           FOR j in  1..FND_MSG_PUB.Count_Msg LOOP

            FND_MSG_PUB.Get(
               p_msg_index     => j,
               p_encoded       => 'F',
               p_data          => lx_msg_data,
               p_msg_index_out => lx_msg_index_out);

            l_logmessage:='-----------ERROR-----------';
           iem_logger(l_logmessage);
           --dbms_output.put_line(l_logmessage);

            l_logmessage:='MESSAGE INDEX1 = ' || lx_msg_index_out;
           iem_logger(l_logmessage);
           --dbms_output.put_line(l_logmessage);
            l_logmessage:='MESSAGE1 = ' || substr(lx_msg_data ,1,150) ;
            iem_logger(l_logmessage);
           --dbms_output.put_line(l_logmessage);

            l_logmessage:='----------END OF ERROR-----------';
           iem_logger(l_logmessage);
           --dbms_output.put_line(l_logmessage);
         END LOOP;

     WHEN FND_API.G_EXC_ERROR THEN
    	     ROLLBACK TO ADVANCED_CREATE_SR;
           x_return_status := FND_API.G_RET_STS_ERROR ;
           FND_MSG_PUB.Count_And_Get
    			( p_count => x_msg_count,p_data => x_msg_data);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO ADVANCED_CREATE_SR;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,p_data => x_msg_data);

    WHEN OTHERS THEN
            ROLLBACK TO ADVANCED_CREATE_SR;
            x_return_status := FND_API.G_RET_STS_ERROR;
            IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME , l_api_name);
            END IF;
            FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    END;

  END ADVANCED_SR_PROCESSING;


  Procedure  getCustomerNumber (
                    p_customer_number IN VARCHAR2   DEFAULT NULL,
	            p_customer_name   IN VARCHAR2 DEFAULT NULL,
		    p_account_number  IN VARCHAR2   DEFAULT NULL,
		    p_customer_phone  IN VARCHAR2 DEFAULT NULL,
 		    p_customer_email  IN VARCHAR2 DEFAULT NULL,
		    p_instance_number IN VARCHAR2   DEFAULT NULL,
		    p_instance_serial_number IN VARCHAR2 DEFAULT NULL,
		    p_incident_site_number   IN VARCHAR2 DEFAULT NULL,
                    --contact related stuff to find customerNumber
		    p_contact_number  IN VARCHAR2 DEFAULT NULL,
 		    p_contact_name    IN VARCHAR2 DEFAULT NULL,
		    p_contact_phone   IN VARCHAR2   DEFAULT NULL,
		    p_contact_email   IN VARCHAR2   DEFAULT NULL,
		    x_customer_id   OUT NOCOPY NUMBER)
  IS
   l_party_count NUMBER;
   l_party_type VARCHAR2(100);
   l_logmessage		varchar2(2000):=' ';
  BEGIN
    --this procedure is called to find the customer_id in giving precdence to
    -- the attribute defined by the users via the rank system in the definition page
    -- if g_customer_id is null then only we will go through different checks
    -- and try to find a valid customer_id based on the calling program
    --once an g_customer_id has been found this procedure will just come out
    --without doing any checks and return the first found g_customer_id
    --which is also the customer_id that the customer intended to used based on the
    --ranking system put in place.

    IF g_customer_id is NULL THEN
	IF p_customer_number is not null THEN
         BEGIN
	   select party_id into x_customer_id
           from hz_parties where party_number = p_customer_number;
         EXCEPTION
           when TOO_MANY_ROWS then
              x_customer_id := null;
             l_logmessage:='p_customer_number fetch returned too many rows'|| SQL%ROWCOUNT;
            iem_logger(l_logmessage);
            --dbms_output.put_line(l_logmessage);
           when NO_DATA_FOUND then
             l_logmessage:='p_customer_number fetch returned 0 rows'|| SQL%ROWCOUNT;
            iem_logger(l_logmessage);
            --dbms_output.put_line(l_logmessage);
           when others then
             l_logmessage:='p_customer_number other exception' || SQLCODE||'-ERROR- '||SQLERRM;
            iem_logger(l_logmessage);
            --dbms_output.put_line(l_logmessage);
         END;

        --since this is an exact text match, we will upper the party_name
        --to increase the chances of a party_name match.
        --it would be nice to have bitmap index on party_name for performance reasons
        ELSIF p_customer_name is not null then
         BEGIN
	     select party_id into x_customer_id
	     from hz_parties where UPPER(party_name) = UPPER(p_customer_name);
         EXCEPTION
           when TOO_MANY_ROWS then
              x_customer_id := null;
             l_logmessage:='p_customer_name fetch returned too many rows'|| SQL%ROWCOUNT;
             iem_logger(l_logmessage);
             --dbms_output.put_line(l_logmessage);
           when NO_DATA_FOUND then
             l_logmessage:='p_customer_name fetch returned 0 rows'|| SQL%ROWCOUNT;
             iem_logger(l_logmessage);
             --dbms_output.put_line(l_logmessage);
           when others then
             l_logmessage:='p_customer_name other exception '|| SQLCODE||'-ERROR- '||SQLERRM ;
             iem_logger(l_logmessage);
             --dbms_output.put_line(l_logmessage);
         END;

        ELSIF p_account_number is not null then
           BEGIN
	     select party_id into x_customer_id
	     from hz_cust_accounts
	     where account_number=p_account_number;
           EXCEPTION
             when TOO_MANY_ROWS then
              x_customer_id := null;
                l_logmessage:='p_account_number fetch returned too many rows'|| SQL%ROWCOUNT;
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
             when NO_DATA_FOUND then
                l_logmessage:='p_account_number fetch returned 0 rows'|| SQL%ROWCOUNT;
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
             when others then
                  l_logmessage:='p_account_number other exception'|| SQLCODE||'-ERROR- '||SQLERRM ;
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
           END;

	ELSIF p_customer_phone is not null then
          BEGIN
            /*
	    Select owner_table_id into x_customer_id
	    From hz_contact_points
	    where owner_table_name='HZ_PARTIES'
	    and contact_point_type = 'PHONE'
	    and phone_number =p_customer_phone;
            */
	    Select owner_table_id into x_customer_id
            from hz_contact_points a, hz_parties b
            where a.owner_table_name='HZ_PARTIES'
            and a.contact_point_type='PHONE'
            and a.status='A'
            and a.contact_point_id not in  (select contact_level_table_id from HZ_CONTACT_PREFERENCES
    					 	 	  where contact_level_table='HZ_CONTACT_POINTS' and status='A')
	    and a.owner_table_id = b.party_id
  	    and b.party_type in ('PERSON', 'ORGANIZATION')
            and reverse(a.transposed_phone_number)=REGEXP_REPLACE(p_customer_phone,'([[:punct:]|[:space:]]*)');

          EXCEPTION
             when TOO_MANY_ROWS then
                x_customer_id := null;
                l_logmessage:='p_customer_phone fetch returned too many rows'|| SQL%ROWCOUNT;
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
             when NO_DATA_FOUND then
                l_logmessage:='p_customer_phone fetch returned 0 rows'|| SQL%ROWCOUNT;
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
             when others then
               l_logmessage:='p_customer_phone other exception';
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
          END;

        ELSIF p_customer_email is not null then
          BEGIN
            /*
	    Select owner_table_id into x_customer_id
	    From hz_contact_points
	    where owner_table_name='HZ_PARTIES'
	    and contact_point_type = 'EMAIL'
	    and upper(email_address) =upper(p_customer_email);
            */
            l_logmessage:='p_customer_email address is '|| p_customer_email;
            iem_logger(l_logmessage);
            --dbms_output.put_line(l_logmessage);
             Select a.owner_table_id into x_customer_id
            from hz_contact_points a, hz_parties b
            where a.owner_table_name='HZ_PARTIES'
	    and a.contact_point_type = 'EMAIL'
            and a.status='A'
            and a.contact_point_id not in  (select contact_level_table_id from HZ_CONTACT_PREFERENCES
    					 	 	  where contact_level_table='HZ_CONTACT_POINTS' and status='A')
	    and a.owner_table_id = b.party_id
  	    and b.party_type in ('PERSON', 'ORGANIZATION')
	    and upper(a.email_address) =upper(p_customer_email);

            l_logmessage:='p_customer_email x_Customer_id is '|| p_customer_email;
            iem_logger(l_logmessage);
            --dbms_output.put_line(l_logmessage);
          EXCEPTION
             when TOO_MANY_ROWS then
                x_customer_id := null;
                l_logmessage:='p_customer_email fetch returned too many rows'|| SQL%ROWCOUNT;
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
             when NO_DATA_FOUND then
                l_logmessage:='p_customer_email fetch returned 0 rows'|| SQL%ROWCOUNT;
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
             when others then
               l_logmessage:='p_customer_email other exception';
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
          END;

	 --and inventory_item_id is of mtl_system_items_b.serv_req_enabled_code = 'E'
	ELSIF p_instance_number is not null then
          BEGIN
            select distinct owner_party_id
            into x_customer_id
            from csi_item_instances
	    where instance_number = p_instance_number;
          EXCEPTION
             when TOO_MANY_ROWS then
                x_customer_id := null;
                l_logmessage:='p_instance_number fetch returned too many rows'|| SQL%ROWCOUNT;
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
             when NO_DATA_FOUND then
                l_logmessage:='p_instance_number fetch returned 0 rows'|| SQL%ROWCOUNT;
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
             when others then
               l_logmessage:='p_instance_number other exception';
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
          END;

	 --Item must be service- request enabled (serv_req_enabled_code = 'E').
	 -- The itemmust not be a service item (contract_item_type_code is Null).
	 ELSIF p_instance_serial_number is not null then
           BEGIN
            select distinct owner_party_id
            into x_customer_id
            from csi_item_instances
	    where serial_number = p_instance_serial_number;
           EXCEPTION
             when TOO_MANY_ROWS then
                x_customer_id := null;
                l_logmessage:='p_instance_serial fetch returned too many rows'|| SQL%ROWCOUNT;
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
             when NO_DATA_FOUND then
                l_logmessage:='p_instance_serial fetch returned 0 rows'|| SQL%ROWCOUNT;
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
             when others then
               l_logmessage:='p_instance_serial other exception';
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
           END;

         ELSIF p_incident_site_number is not null then
          BEGIN
             select party_id into x_customer_id
             from hz_party_sites
             where party_site_number = p_incident_site_number;
          EXCEPTION
             when TOO_MANY_ROWS then
                x_customer_id := null;
                l_logmessage:='p_incident_site_number fetch returned too many rows'|| SQL%ROWCOUNT;
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
             when NO_DATA_FOUND then
                l_logmessage:='p_incident_site_number fetch returned 0 rows'|| SQL%ROWCOUNT;
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
             when others then
               l_logmessage:='p_incident_site_number other exception';
               iem_logger(l_logmessage);
              --dbms_output.put_line(l_logmessage);
          END;

         --we are entering contact related customer_processing section
         ELSIF p_contact_number is not null then
           BEGIN
              --this is being fixed by the QA bug 8860086
              --the ditinct is doen to get a unique customer_id as this query will pass the multiple
              --rows with the same customer_id. Multiple rows comes because based on a party_number a
              --particular organization might have multiple contacts
              --NEW REQUIREMENT
              --the user can either pass the contact_number (party_number) of the RELATIONHIP record
              --or the contact or organization record. In either case I have to create the org.
              --therefore i have to fist find out what type of contact_number it is and accordingly
              --find the customer information.
           /* --old query
              Select distinct b.subject_id
              into g_customer_id
	      from hz_contact_points a,hz_relationships b, hz_parties c
              where a.owner_table_name='HZ_PARTIES'
              and a.status='A'
	      and a.primary_flag = 'Y'
              and a.owner_table_id = b.party_id
	      and directional_flag = 'B'
              and a.contact_point_id not in  (select contact_level_table_id from HZ_CONTACT_PREFERENCES
     	  	                              where contact_level_table='HZ_CONTACT_POINTS' and status='A')
	      and b.object_id = c.party_id
	      and c.party_number = p_contact_number;
            */
             select upper(party_type) into l_party_type
             from hz_parties
             where party_number = p_contact_number;

                l_logmessage:='p_contact_number processing for party and party_type is  '|| l_party_type;
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);

             IF (l_party_type = 'PARTY_RELATIONSHIP') THEN
                 select distinct a.subject_id
                 into g_customer_id
  	         from hz_relationships a, hz_parties b
	         where a.party_id = b.party_id
                 and directional_flag = 'B'
                 and b.party_number = p_contact_number;

                 l_logmessage:='p_contact_number inside PARTY_RELATIONSHIP ';
                 iem_logger(l_logmessage);
                 --dbms_output.put_line(l_logmessage);
             ELSIF (l_party_type = 'PERSON') THEN
                 select distinct a.subject_id
                 into g_customer_id
          	 from hz_relationships a, hz_parties b
	         where a.object_id = b.party_id
                 and directional_flag = 'B'
                 and b.party_number = p_contact_number;

                 l_logmessage:='p_contact_number inside PERSON ';
                 iem_logger(l_logmessage);
                 --dbms_output.put_line(l_logmessage);
             ELSIF (l_party_type = 'ORGANIZATION') THEN
                 select party_id into g_customer_id
                 from hz_parties
                 where party_number = p_contact_number;

                 l_logmessage:='p_contact_number inside ORGANIZATION ';
                 iem_logger(l_logmessage);
                 --dbms_output.put_line(l_logmessage);
             END IF;
           EXCEPTION
             when TOO_MANY_ROWS then
                g_customer_id := null;
                l_logmessage:='p_contact_number fetch returned too many rows'|| SQL%ROWCOUNT;
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
             when NO_DATA_FOUND then
                l_logmessage:='p_contact_number fetch returned 0 rows'|| SQL%ROWCOUNT;
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
             when others then
               l_logmessage:='p_contact_number other exception';
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
          END;

         ELSIF p_contact_name is not null then
           BEGIN
             --i did distinct because there may be many contacts for a single party_id
             --since we are trying to find the party_id of type organization or person here a distinct is a better match
             select distinct a.subject_id
             into g_customer_id
  	     from hz_relationships a, hz_parties b
	     where a.object_id = b.party_id
             and directional_flag = 'B'
             and upper(b.party_name) = upper(p_contact_name);

           EXCEPTION
             when TOO_MANY_ROWS then
                g_customer_id := null;
                l_logmessage:='p_contact_name fetch returned too many rows'|| SQL%ROWCOUNT;
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
             when NO_DATA_FOUND then
                l_logmessage:='p_contact_name fetch returned 0 rows'|| SQL%ROWCOUNT;
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
             when others then
               l_logmessage:='p_contact_name other exception';
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
          END;

         ELSIF p_contact_phone is not null then
          BEGIN
             --i did distinct because there may be many contacts for a single party_id
             --since we are trying to find the party_id  distinct is a valid assumption
            /*
             select distinct b.object_id into g_customer_id
             from hz_parties a, hz_party_relationships b, hz_contact_points c
             where  c.phone_number = p_contact_phone
             where and reverse(c.transposed_phone_number)=REGEXP_REPLACE(p_contact_phone,'([[:punct:]|[:space:]]*)')
             and a.party_id = b.subject_id
             and c.owner_table_id = b.party_id
             and c.contact_point_type = 'PHONE'
             and c.owner_table_name = 'HZ_PARTIES';
            */
             Select distinct b.subject_id into g_customer_id
	     from hz_contact_points a,hz_relationships b, hz_parties c
             where a.owner_table_name='HZ_PARTIES'
	     and  a.contact_point_type='PHONE'
             and a.status='A'
	     and a.primary_flag = 'Y'
             and a.owner_table_id = b.party_id
	     and directional_flag = 'B'
             and a.contact_point_id not in  (select contact_level_table_id from HZ_CONTACT_PREFERENCES
     	  	                              where contact_level_table='HZ_CONTACT_POINTS' and status='A')
	     and b.object_id = c.party_id
	     and reverse(a.transposed_phone_number)=REGEXP_REPLACE(p_contact_phone,'([[:punct:]|[:space:]]*)');
         EXCEPTION
             when TOO_MANY_ROWS then
                g_customer_id := null;
                l_logmessage:='p_contact_phone fetch returned too many rows'|| SQL%ROWCOUNT;
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
             when NO_DATA_FOUND then
                l_logmessage:='p_contact_phone fetch returned 0 rows'|| SQL%ROWCOUNT;
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
             when others then
               l_logmessage:='p_contact_phone other exception';
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
          END;

         ELSIF p_contact_email is not null then
           BEGIN
             --i did distinct because there may be many contacts for a single party_id
             --since we are trying to find the party_id  distinct is a valid assumption
             /*
             select distinct b.object_id into g_customer_id
             from hz_parties a, hz_party_relationships b, hz_contact_points c
	     where upper(c.email_address) =upper(p_contact_email)
             and a.party_id = b.subject_id
             and c.owner_table_id = b.party_id
             and c.contact_point_type = 'EMAIL'
             and c.owner_table_name = 'HZ_PARTIES';
             */
             Select distinct b.subject_id into g_customer_id
	     from hz_contact_points a,hz_relationships b, hz_parties c
             where a.owner_table_name='HZ_PARTIES'
	     and  a.contact_point_type='EMAIL'
             and a.status='A'
	     and a.primary_flag = 'Y'
             and a.owner_table_id = b.party_id
	     and directional_flag = 'B'
             and a.contact_point_id not in  (select contact_level_table_id from HZ_CONTACT_PREFERENCES
     	  	                              where contact_level_table='HZ_CONTACT_POINTS' and status='A')
	     and b.object_id = c.party_id
	     and upper(a.email_address) =upper(p_contact_email);

           EXCEPTION
             when TOO_MANY_ROWS then
                g_customer_id := null;
                l_logmessage:='p_contact_email fetch returned too many rows'|| SQL%ROWCOUNT;
          iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);
             when NO_DATA_FOUND then
                l_logmessage:='p_contact_email fetch returned 0 rows'|| SQL%ROWCOUNT;
          iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);
             when others then
               l_logmessage:='p_contact_email other exception';
          iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);
           END;

       END IF; --END IF of all the validation
    ELSE
         --if customer id exist in that case pass the existing customer_id so that the x_value does not
         --go back as null causing issues in the program
         x_customer_id := g_customer_id;
    END IF; --END IF of customer_id chevk
  END getCustomerNumber;

  --Account number can be used to get customer_id as well as the cust_account_id
  --therefore we will automatically try to get the customer_id if it has not
  --been found already and try to populate the global variable
  --g_customer_id if a match is found; we will also return
  --the cust_account_id when ever there is a single match
  --NOTE: Reason for splitting account_id and customer_id processing is that
  --you can create a SR without account_id but you can not create a sr without customer_id
  Procedure getAccountNumber(p_account_number IN VARCHAR2,
                             x_cust_account_id    OUT NOCOPY NUMBER)
  IS
    l_account_count number;
    l_logmessage		varchar2(2000):=' ';
  BEGIN

      --try to find customer_id if its not been found yet
      --it should not come here but left the package here for future
      --change in processing use. Ignore for now

      IF g_customer_id IS NULL THEN
	getCustomerNumber (p_account_number  => p_account_number,
       		           x_customer_id   => g_customer_id);
      END IF;

      IF (g_customer_id IS NOT NULL) AND (p_account_number IS NOT NULL) THEN
        BEGIN
          --the status must be active for cust_account_id
	  Select cust_account_id into x_cust_account_id
	  from hz_cust_accounts
	  where party_id=g_customer_id
	  and account_number=p_account_number
          and status = 'A';
        EXCEPTION
             when TOO_MANY_ROWS then
                x_cust_account_id :=null;
                l_logmessage:=p_account_number|| ' p_account_number fetch returned too many rows'|| SQL%ROWCOUNT;
          iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);
             when NO_DATA_FOUND then
                l_logmessage:=p_account_number ||  'p_account_number fetch returned 0 rows'|| SQL%ROWCOUNT;
          iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);
             when others then
               l_logmessage:=p_account_number || 'p_account_number other exception';
          iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);
        END;
      -- try to find account_number related info even if there is no customer_id
     ELSE
        BEGIN
	  Select cust_account_id into x_cust_account_id
	  from hz_cust_accounts
	  where account_number=p_account_number
          and status = 'A';
        EXCEPTION
             when TOO_MANY_ROWS then
                x_cust_account_id :=null;
                l_logmessage:=p_account_number|| ' p_account_number fetch returned too many rows'|| SQL%ROWCOUNT;
          iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);
             when NO_DATA_FOUND then
                l_logmessage:=p_account_number ||  'p_account_number fetch returned 0 rows'|| SQL%ROWCOUNT;
          iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);
             when others then
               l_logmessage:=p_account_number || 'p_account_number other exception';
          iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);
        END;

      END IF;
  END getAccountNumber;

  --Question: Should we try to find contact related information from this
  -- we can find contact_point_id in this case too. so the question is should we seperate
  --out the contact point processing from the contact processing section; for now we are not treating
  --customer_phone_id and customer_email_id as the contact_point_id of contact information. How are things
  --going to work if the customer passes the contact_information as well as the customer information such as
  --customer_phone and customer_email apart from contact_phone and contact_email. We need to discuss

  --Qeustion: if this procedure like all other procedure you will see we have IF g_Customer_id is not null / ELSE section
  --where we try to find information without the cutomer_id. The question is lets see we finished our customer processing
  --and we did not find a customer_id from the parsed value. The what should the program do.
  --1. Should I break out of the program and return the status E to the calling program and revert to old processing
  --2. Should I continu processing trying to get information regarding customer_phone_id and other related information
      --with the default customer_id
  --3. Should I even have a condition in this section where I try to get values without the customer_number; since I should have
      --found a customer_id by now; and If i a havent found a customer_id by now; that means I cant create SR anyways. So why
      --bother with the porcessing and trying to find things without the customer_id
  Procedure getCustomerPhone (p_customer_phone     IN VARCHAR2,
                              x_customer_phone_id  OUT NOCOPY NUMBER)
  IS
   l_phone_count NUMBER;
   l_logmessage		varchar2(2000):=' ';
  BEGIN
        --try to find customer_id IF its not been found yet
      IF g_customer_id IS NULL THEN
           getCustomerNumber (p_customer_phone  => p_customer_phone,
                              x_customer_id   => g_customer_id);
      END IF;

      IF (g_customer_id IS NOT NULL) AND (p_customer_phone IS NOT NULL) THEN
         BEGIN
            Select contact_point_id into x_customer_phone_id
            From hz_contact_points
            where contact_point_type = 'PHONE'
            --and phone_number = p_customer_phone
            and reverse(transposed_phone_number)=REGEXP_REPLACE(p_customer_phone,'([[:punct:]|[:space:]]*)')
            and owner_table_id = g_customer_id;
          EXCEPTION
             when TOO_MANY_ROWS then
                x_customer_phone_id := null;
                l_logmessage:=p_customer_phone|| ' p_customer_phone fetch returned too many rows'|| SQL%ROWCOUNT;
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
             when NO_DATA_FOUND then
                l_logmessage:=p_customer_phone ||  'p_customer_phone fetch returned 0 rows'|| SQL%ROWCOUNT;
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
             when others then
               l_logmessage:=p_customer_phone || 'p_customer_phone other exception';
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
          END;
      ELSE
         BEGIN
           Select contact_point_id into x_customer_phone_id
            From hz_contact_points
            where owner_table_name='HZ_PARTIES'
            and contact_point_type = 'PHONE'
            and reverse(transposed_phone_number)=REGEXP_REPLACE(p_customer_phone,'([[:punct:]|[:space:]]*)');
         EXCEPTION
             when TOO_MANY_ROWS then
                x_customer_phone_id := null;
                l_logmessage:=p_customer_phone|| ' p_customer_phone fetch returned too many rows'|| SQL%ROWCOUNT;
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
             when NO_DATA_FOUND then
                l_logmessage:=p_customer_phone ||  'p_customer_phone fetch returned 0 rows'|| SQL%ROWCOUNT;
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
             when others then
               l_logmessage:=p_customer_phone || 'p_customer_phone other exception';
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
         END;
      END IF;

  END getCustomerPhone;

  Procedure getCustomerEmail (p_customer_email VARCHAR2,
                              x_customer_email_id  out NOCOPY number)
  IS
   l_email_count NUMBER;
   l_logmessage		varchar2(2000):=' ';
  BEGIN

        --try to find customer_id IF its not been found yet
        IF g_customer_id IS NULL THEN
        getCustomerNumber ( p_customer_email  => p_customer_email,
                            x_customer_id   => g_customer_id);
        END IF;

        --convert email address to uppercase to prevent case relative mismatch
        IF (g_customer_id IS NOT Null) AND (p_customer_email IS NOT NULL) THEN
         BEGIN
            Select contact_point_id into x_customer_email_id
            From hz_contact_points
            where contact_point_type = 'EMAIL'
            and upper(email_address) =upper(p_customer_email)
            and owner_table_id = g_customer_id;
          EXCEPTION
             when TOO_MANY_ROWS then
                x_customer_email_id := null;
                l_logmessage:=p_customer_email|| ' p_customer_email fetch returned too many rows'|| SQL%ROWCOUNT;
          iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);
             when NO_DATA_FOUND then
                l_logmessage:=p_customer_email ||  'p_customer_email fetch returned 0 rows'|| SQL%ROWCOUNT;
          iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);
             when others then
               l_logmessage:=p_customer_email || 'p_customer_email other exception';
          iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);
          END;

        ELSE
          BEGIN
             Select contact_point_id into x_customer_email_id
             From hz_contact_points
             where owner_table_name='HZ_PARTIES'
             and contact_point_type = 'EMAIL'
             and upper(email_address) =upper(p_customer_email);
          EXCEPTION
             when TOO_MANY_ROWS then
                x_customer_email_id := null;
                l_logmessage:=p_customer_email|| ' p_customer_email fetch returned too many rows'|| SQL%ROWCOUNT;
          iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);
             when NO_DATA_FOUND then
                l_logmessage:=p_customer_email ||  'p_customer_email fetch returned 0 rows'|| SQL%ROWCOUNT;
          iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);
             when others then
               l_logmessage:=p_customer_email || 'p_customer_email other exception';
          iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);
          END;

       END IF;
  END getCustomerEmail;

  --this procedure will accept a cust_account_id as avalue if it not passed
  --it is defaulted to null. However if its passed then it will use the cust_account_id
  --as an additional filter while retrieving value. The additional filter will
  -- further retrict the result set to retrive a unique match

  --Questions: what happens if the customer has ranked customer_number (Customer_number gives use
  -- cust_account_id) lower in the ranking and a cust_account_id has not yet been found
  --but would be found after processing getInstnaceNumber.
  --Should we try to find a cust_account_id if it has not been found at this stage
  --- ANSWSER: Go with the way things are right now.. if ranking is preventing us we are not going to do it

  --Question: in this query you will notice we are checking for customer_id and createing one set of query
  --and then another set of query without the customer_id. Now there are several scenarios.
  -- 1. Technically we should not be doing any of these processing if a customer_id hsa not been found already
        --so shall we take out the section with where we are trying to get info without the customer_id
  -- 2. OR shall we try to get the information withe the customer_id as customer_id will be present by now,
        --and if we are not able to get a single hit with customer_id; shall we try to get a single hit without the
        --customer_id
  Procedure getInstanceNumber (p_instance_number     IN VARCHAR2,
                               p_cust_account_id     IN NUMBER DEFAULT NULL,
                               x_customer_product_id OUT NOCOPY NUMBER,
                               x_inventory_org_id    OUT NOCOPY NUMBER,
                               x_inventory_item_id   OUT NOCOPY NUMBER)
  IS
   l_instance_count number;
   l_logmessage		varchar2(2000):=' ';
  BEGIN
       --Item must inventroy_item_id of (mtl_system_items_b.serv_req_enabled_code = 'E').
       -- The item must not be a service item (contract_item_type_code is Null).
       IF g_customer_id IS NULL THEN
        getCustomerNumber ( p_instance_number => p_instance_number,
                            x_customer_id     => g_customer_id);
       END IF;

        IF (g_customer_id IS NOT NULL) AND (p_instance_number IS NOT NULL) THEN

            --cust_account_id is found in the call getAccountNumber
            --this procedure will accept a cust_account_id as avalue if it not passed
            --it is defaulted to null. However if its passed then it will use the cust_account_id
            --as an additional filter while retrieving value. The additional filter will
            -- further retrict the result set to retrive a unique match
            IF (p_cust_account_id IS NOT NULL) THEN
                BEGIN
                  select instance_id,inventory_item_id, inv_master_organization_id
                  into x_customer_product_id, x_inventory_item_id, x_inventory_org_id
                  from csi_item_instances
                  where instance_number = p_instance_number
                  and owner_party_account_id = p_cust_account_id
                  and owner_party_id = g_customer_id;
                EXCEPTION
                  when TOO_MANY_ROWS then
                     x_customer_product_id := null;
                     x_inventory_item_id := null;
                     x_inventory_org_id := null;
                     l_logmessage:=p_instance_number|| '1p_instance_number fetch returned too many rows'|| SQL%ROWCOUNT;
          	     iem_logger(l_logmessage);
    	    	      --dbms_output.put_line(l_logmessage);
                  when NO_DATA_FOUND then
                     l_logmessage:=p_instance_number || '1p_instance_number fetch returned 0 rows'|| SQL%ROWCOUNT;
          	     iem_logger(l_logmessage);
    	    	      --dbms_output.put_line(l_logmessage);
                  when others then
                    l_logmessage:=p_instance_number || '1p_instance_number other exception';
          	     iem_logger(l_logmessage);
    	    	      --dbms_output.put_line(l_logmessage);
                END;
            ELSE
               BEGIN
                  select instance_id,inventory_item_id, inv_master_organization_id
                  into x_customer_product_id, x_inventory_item_id, x_inventory_org_id
                  from csi_item_instances
                  where instance_number = p_instance_number
                  and owner_party_id = g_customer_id;
               EXCEPTION
                  when TOO_MANY_ROWS then
                     x_customer_product_id := null;
                     x_inventory_item_id := null;
                     x_inventory_org_id := null;
                     l_logmessage:=p_instance_number|| '2p_instance_number fetch returned too many rows'|| SQL%ROWCOUNT;
          	     iem_logger(l_logmessage);
    	    	      --dbms_output.put_line(l_logmessage);
                  when NO_DATA_FOUND then
                     l_logmessage:=p_instance_number || '2p_instance_number fetch returned 0 rows'|| SQL%ROWCOUNT;
          	     iem_logger(l_logmessage);
    	    	      --dbms_output.put_line(l_logmessage);
                  when others then
                    l_logmessage:=p_instance_number || '2p_instance_number other exception';
          	     iem_logger(l_logmessage);
    	    	      --dbms_output.put_line(l_logmessage);
               END;
           END IF;
        ELSE
          IF (p_cust_account_id IS NOT NULL) THEN
             BEGIN
                select instance_id,inventory_item_id, inv_master_organization_id
                into x_customer_product_id, x_inventory_item_id, x_inventory_org_id
                from csi_item_instances
                where instance_number = p_instance_number
                and owner_party_account_id = p_cust_account_id;
             EXCEPTION
                when TOO_MANY_ROWS then
                     x_customer_product_id := null;
                     x_inventory_item_id := null;
                     x_inventory_org_id := null;
                   l_logmessage:=p_instance_number|| '3p_instance_number fetch returned too many rows'|| SQL%ROWCOUNT;
                    iem_logger(l_logmessage);
    	          --dbms_output.put_line(l_logmessage);
                when NO_DATA_FOUND then
                   l_logmessage:=p_instance_number || '3p_instance_number fetch returned 0 rows'|| SQL%ROWCOUNT;
                    iem_logger(l_logmessage);
                   --dbms_output.put_line(l_logmessage);
                when others then
                   l_logmessage:=p_instance_number || '3p_instance_number other exception';
                    iem_logger(l_logmessage);
                   --dbms_output.put_line(l_logmessage);
             END;
          ELSE
            BEGIN
              select instance_id,inventory_item_id, inv_master_organization_id
              into x_customer_product_id, x_inventory_item_id, x_inventory_org_id
              from csi_item_instances
              where instance_number = p_instance_number;
            EXCEPTION
                when TOO_MANY_ROWS then
                     x_customer_product_id := null;
                     x_inventory_item_id := null;
                     x_inventory_org_id := null;
                   l_logmessage:=p_instance_number|| '4p_instance_number fetch returned too many rows'|| SQL%ROWCOUNT;
                    iem_logger(l_logmessage);
                   --dbms_output.put_line(l_logmessage);
                when NO_DATA_FOUND then
                   l_logmessage:=p_instance_number || '4p_instance_number fetch returned 0 rows'|| SQL%ROWCOUNT;
                    iem_logger(l_logmessage);
                   --dbms_output.put_line(l_logmessage);
                when others then
                   l_logmessage:=p_instance_number || '4p_instance_number other exception';
                    iem_logger(l_logmessage);
                   --dbms_output.put_line(l_logmessage);
            END;
        END IF;
      END IF; --end if of g_customer_id check
  END getInstanceNumber;


  --this procedure will accept a cust_account_id as avalue if it not passed
  --it is defaulted to null. However if its passed then it will use the
  -- cust_account_id
  --as an additional filter while retrieving value. The additional filter will
  -- further retrict the result set to retrive a unique match

  --Questions: what happens if the customer has ranked customer_number lower in
  -- the ranking and a customer a cust_account_id has not yet been found but would b e found
  -- after processing getInstnaceNumber. Should we try to find a cust_account_id if it has not
  -- been found at this stage
   --ANSWER: No go with the current way we are handling things

  Procedure getInstanceSerialNumber (p_instance_serial_number     IN VARCHAR2,
                               p_cust_account_id     IN NUMBER DEFAULT NULL,
                               x_customer_product_id OUT NOCOPY NUMBER,
                               x_inventory_org_id    OUT NOCOPY NUMBER,
                               x_inventory_item_id   OUT NOCOPY NUMBER)
  IS
   l_instance_count number;
   l_logmessage		varchar2(2000):=' ';
  BEGIN
       --Item must inventroy_item_id of
       --(mtl_system_items_b.serv_req_enabled_code = 'E').
       -- The item must not be a service item (contract_item_type_code is Null).
  --IGNORE this section as we should have already found the customer_id but
       --leaving the code here for futere purpose if we change our mind
       IF g_customer_id IS NULL THEN
        getCustomerNumber ( p_instance_serial_number => p_instance_serial_number,
                            x_customer_id             => g_customer_id);
       END IF;

        IF (g_customer_id IS NOT NULL) AND (p_instance_serial_number IS NOT NULL) THEN

                      l_logmessage:=p_instance_serial_number|| 'inside customer_id not null and instance_Serila not null';
                      iem_logger(l_logmessage);
                      --dbms_output.put_line(l_logmessage);
            --this procedure will accept a cust_account_id
            --as avalue if it not passed
            --it is defaulted to null. However if its passed
            --then it will use the cust_account_id
            --as an additional filter while retrieving value.
            --The additional filter will
            -- further retrict the result set to retrive a unique match
            IF (p_cust_account_id IS NOT NULL) THEN
                 BEGIN
                      l_logmessage:='instance_Serial:'||p_instance_serial_number|| 'cust_account_id not null';
                      iem_logger(l_logmessage);
                      --dbms_output.put_line(l_logmessage);
                   select instance_id,inventory_item_id,inv_master_organization_id
                   into x_customer_product_id, x_inventory_item_id, x_inventory_org_id
                   from csi_item_instances
                   where serial_number = p_instance_serial_number
                   and owner_party_account_id = p_cust_account_id
                   and owner_party_id = g_customer_id;

                   l_logmessage:='customer_product_id:'||x_customer_product_id|| 'inv_item_id:'||x_inventory_item_id||'org:'||x_inventory_org_id;
                   iem_logger(l_logmessage);
                   --dbms_output.put_line(l_logmessage);
                 EXCEPTION
                   when TOO_MANY_ROWS then
                     x_customer_product_id := null;
                     x_inventory_item_id := null;
                     x_inventory_org_id := null;
                      l_logmessage:=p_instance_serial_number|| 'inst_ser_number fetch returned too many rows'|| SQL%ROWCOUNT;
                      iem_logger(l_logmessage);
                      --dbms_output.put_line(l_logmessage);
                   when NO_DATA_FOUND then
                      l_logmessage:=p_instance_serial_number || 'inst_ser_number fetch returned 0 rows'|| SQL%ROWCOUNT;
                      iem_logger(l_logmessage);
                      --dbms_output.put_line(l_logmessage);
                   when others then
                      l_logmessage:=p_instance_serial_number || 'inst_ser_number other exception';
                      iem_logger(l_logmessage);
                      --dbms_output.put_line(l_logmessage);
                END;
           ELSE
                BEGIN
                  select instance_id,inventory_item_id,inv_master_organization_id
                  into x_customer_product_id, x_inventory_item_id, x_inventory_org_id
                  from csi_item_instances
                  where serial_number = p_instance_serial_number
                  and owner_party_id = g_customer_id;
                   l_logmessage:='account_id is null ';
                   iem_logger(l_logmessage);
                   --dbms_output.put_line(l_logmessage);

                   l_logmessage:='customer_product_id:'||x_customer_product_id|| 'inv_item_id:'||x_inventory_item_id||'org:'||x_inventory_org_id;
                   iem_logger(l_logmessage);
                   --dbms_output.put_line(l_logmessage);
                EXCEPTION
                  when TOO_MANY_ROWS then
                     x_customer_product_id := null;
                     x_inventory_item_id := null;
                     x_inventory_org_id := null;
                     l_logmessage:=p_instance_serial_number|| 'inst_ser_number fetch returned too many rows'|| SQL%ROWCOUNT;
                    iem_logger(l_logmessage);
                    --dbms_output.put_line(l_logmessage);
                  when NO_DATA_FOUND then
                     l_logmessage:=p_instance_serial_number || 'inst_ser_number fetch returned 0 rows'|| SQL%ROWCOUNT;
                      iem_logger(l_logmessage);
                     --dbms_output.put_line(l_logmessage);
                  when others then
                     l_logmessage:=p_instance_serial_number || 'inst_ser_number other exception';
                      iem_logger(l_logmessage);
                      --dbms_output.put_line(l_logmessage);
                END;

           END IF;
        ELSE
           IF (p_cust_account_id IS NOT NULL) THEN
             BEGIN
                select instance_id,inventory_item_id, inv_master_organization_id
                into x_customer_product_id, x_inventory_item_id, x_inventory_org_id
                from csi_item_instances
                where serial_number = p_instance_serial_number
                and owner_party_account_id = p_cust_account_id;
                   l_logmessage:='account_id is not null in the else section meaning g_customer_id is null ';
                   iem_logger(l_logmessage);
                   --dbms_output.put_line(l_logmessage);

                   l_logmessage:='customer_product_id:'||x_customer_product_id|| 'inv_item_id:'||x_inventory_item_id||'org:'||x_inventory_org_id;
                   iem_logger(l_logmessage);
                   --dbms_output.put_line(l_logmessage);
             EXCEPTION
                when TOO_MANY_ROWS then
                     x_customer_product_id := null;
                     x_inventory_item_id := null;
                     x_inventory_org_id := null;
                   l_logmessage:='p_instance_serial_number fetch returned too many rows'|| SQL%ROWCOUNT;
                   iem_logger(l_logmessage);
                   --dbms_output.put_line(l_logmessage);
                when NO_DATA_FOUND then
                   l_logmessage:='p_instance_serial_number fetch returned 0 rows'|| SQL%ROWCOUNT;
                   iem_logger(l_logmessage);
                   --dbms_output.put_line(l_logmessage);
                when others then
                   l_logmessage:='p_instance_serial_number other exception';
                   iem_logger(l_logmessage);
                      --dbms_output.put_line(l_logmessage);
             END;
          ELSE
             BEGIN
               select instance_id,inventory_item_id, inv_master_organization_id
               into x_customer_product_id, x_inventory_item_id, x_inventory_org_id
               from csi_item_instances
                where serial_number = p_instance_serial_number;

                   l_logmessage:='account_id is null ';
                   iem_logger(l_logmessage);
                   --dbms_output.put_line(l_logmessage);

                   l_logmessage:='customer_product_id:'||x_customer_product_id|| 'inv_item_id:'||x_inventory_item_id||'org:'||x_inventory_org_id;
                   iem_logger(l_logmessage);
                   --dbms_output.put_line(l_logmessage);
             EXCEPTION
                when TOO_MANY_ROWS then
                     x_customer_product_id := null;
                     x_inventory_item_id := null;
                     x_inventory_org_id := null;
                   l_logmessage:='p_instance_serial_number fetch returned too many rows'|| SQL%ROWCOUNT;
                   iem_logger(l_logmessage);
                      --dbms_output.put_line(l_logmessage);
                when NO_DATA_FOUND then
                   l_logmessage:='p_instance_serial_number fetch returned 0 rows'|| SQL%ROWCOUNT;
                   iem_logger(l_logmessage);
                      --dbms_output.put_line(l_logmessage);
                when others then
                   l_logmessage:='p_instance_serial_number other exception';
                   iem_logger(l_logmessage);
                    --dbms_output.put_line(l_logmessage);
             END;
          END IF;
       END IF;
  END getInstanceSerialNumber;


  Procedure getIncidentSiteNumber (p_incident_site_number IN VARCHAR2,
                                   x_incident_location_id out NOCOPY NUMBER)
  IS
    l_site_count number;
    l_logmessage		varchar2(2000):=' ';
  BEGIN
      IF g_customer_id IS NULL THEN
          getCustomerNumber ( p_incident_site_number  => p_incident_site_number,
                              x_customer_id   => g_customer_id);
      END IF;

      IF (g_customer_id IS NOT NULL) AND (p_incident_site_number IS NOT NULL) THEN
          BEGIN
            select party_site_id into x_incident_location_id
            from hz_party_sites
            where party_site_number = p_incident_site_number
            and party_id = g_customer_id;
          EXCEPTION
            when TOO_MANY_ROWS then
               x_incident_location_id := null;
                l_logmessage:='p_instance_serial_number fetch returned too many rows'|| SQL%ROWCOUNT;
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
            when NO_DATA_FOUND then
                l_logmessage:='p_instance_serial_number fetch returned 0 rows'|| SQL%ROWCOUNT;
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
            when others then
                l_logmessage:='p_instance_serial_number other exception';
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
          END;
      ELSE
        BEGIN
          select party_site_id into x_incident_location_id
          from hz_party_sites
          where party_site_number = p_incident_site_number;
        EXCEPTION
           when TOO_MANY_ROWS then
               x_incident_location_id := null;
                l_logmessage:='p_instance_serial_number fetch returned too many rows'|| SQL%ROWCOUNT;
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
           when NO_DATA_FOUND then
                 l_logmessage:='p_instance_serial_number fetch returned 0 rows'|| SQL%ROWCOUNT;
                iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
           when others then
                l_logmessage:='p_instance_serial_number other exception';
          iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);
        END;
      END IF;
  END getIncidentSiteNumber;

  ------------------------------------------------------------
  -- contact processing
  -------------------------------------------------------------
  --this are few essential information whihc is needed
  --party_id of type contact
  --contact_point_id from hz_contact_points of the contact
  --party_id is the object_id of the type contact_of from hz_parties.party_id
  --contact_point id is the contact_point_id from hz_contact_points where object_id
  --NOTE: Make sure we are not calling this procedure if the account type if of Internal
  --if its internal then we will just use the passed contact_party_id and contact_point_id

  Procedure getContactNumber (p_contact_number IN VARCHAR2,
                              p_parser_id      IN NUMBER,
                              p_contact_phone  IN VARCHAR2,
                              p_contact_email IN VARCHAR2,
                              x_contact_party_id  OUT NOCOPY NUMBER,
                              x_contact_type      OUT NOCOPY VARCHAR2,
                              x_contact_point_type      OUT NOCOPY VARCHAR2,
                              x_contact_point_id  OUT NOCOPY NUMBER)
  IS
    l_party_count NUMBER;
    l_logmessage		varchar2(2000):=' ';
    l_party_type VARCHAR2(100) :=null;
  BEGIN

        --process this attribute only if g_contact_party_id has not been found yet.
        --if it has been found then there is not need to process this attribute a
        IF g_contact_party_id IS NULL THEN

            l_logmessage:='entered contact_number processing and g_contact party id is null';
            iem_logger(l_logmessage);
            --dbms_output.put_line(l_logmessage);

             --check what is the contact type for the contact number
             select upper(party_type) into l_party_type
             from hz_parties
             where party_number = p_contact_number;

            l_logmessage:='contact_party_type is ' || l_party_type ;
            iem_logger(l_logmessage);
            --dbms_output.put_line(l_logmessage);

             FOR contact_rec in (Select column_name, rank
                                 from iem_parser_dtls
                                 where parser_id = p_parser_id
                                 and UPPER(column_name) IN ('CONTACT_PHONE','CONTACT_EMAIL')
                                 order by rank asc)
             LOOP
                --only go throug the processing if the value has not been found
                --in the last itiration there fore checking the x_contact_party_id value
                --we are also looking for contact_phone and contact_email because its very rare to get a
                --single hit from just from the contact_number.
                IF x_contact_party_id IS NULL THEN

                   IF ((contact_rec.column_name = 'CONTACT_PHONE') AND (p_contact_phone is not null)) THEN
                      BEGIN
                        IF (l_party_type = 'PERSON') THEN
                            l_logmessage:='contact_number->contact_phone->type:person processing';
                            iem_logger(l_logmessage);
                            --dbms_output.put_line(l_logmessage);

                            --i am using reglar expression here to check if there are any unwanted chars that are
                            --passed by users and strip those off.
                            Select c.party_id, c.party_type,  a.contact_point_id, a.contact_point_type
		            into x_contact_party_id, x_contact_type, x_contact_point_id, x_contact_point_type
                            from hz_contact_points a,hz_relationships b, hz_parties c
                            where a.owner_table_name='HZ_PARTIES'
                            and  a.contact_point_type='PHONE'
                            and a.status='A'
                            and a.owner_table_id = b.party_id
                            and a.contact_point_id not in  (select contact_level_table_id from HZ_CONTACT_PREFERENCES
     	 					    where contact_level_table='HZ_CONTACT_POINTS' and status='A')
	                    and b.party_id = c.party_id
                            and b.object_id in (select party_id from hz_parties where party_number = p_contact_number)
                            --and c.party_number =p_contact_number
                            and reverse(a.transposed_phone_number)=REGEXP_REPLACE(p_contact_phone,'([[:punct:]|[:space:]]*)')
	                    and b.subject_id = g_customer_id;
                         ELSIF (l_party_type = 'PARTY_RELATIONSHIP') THEN
                            l_logmessage:='contact_number->contact_phone->type:party_relationship processing';
                            iem_logger(l_logmessage);
                            --dbms_output.put_line(l_logmessage);

                            Select c.party_id, c.party_type,  a.contact_point_id, a.contact_point_type
		            into x_contact_party_id, x_contact_type, x_contact_point_id, x_contact_point_type
                            from hz_contact_points a,hz_relationships b, hz_parties c
                            where a.owner_table_name='HZ_PARTIES'
                            and  a.contact_point_type='PHONE'
                            and a.status='A'
                            and a.owner_table_id = b.party_id
                            and a.contact_point_id not in  (select contact_level_table_id from HZ_CONTACT_PREFERENCES
     	 					    where contact_level_table='HZ_CONTACT_POINTS' and status='A')
	                    and b.party_id = c.party_id
                            --and b.object_id in (select party_id from hz_parties where party_number = p_contact_number)
                            and c.party_number =p_contact_number
                            and reverse(a.transposed_phone_number)=REGEXP_REPLACE(p_contact_phone,'([[:punct:]|[:space:]]*)')
	                    and b.subject_id = g_customer_id;
                         END IF;

                       EXCEPTION
                           when TOO_MANY_ROWS then
                              x_contact_party_id := null;
                              x_contact_type := null;
                              x_contact_point_id := null;
                              x_contact_point_type := null;

                              l_logmessage:='contact_number fetch returned too many rows'|| SQL%ROWCOUNT;
                              iem_logger(l_logmessage);
                              --dbms_output.put_line(l_logmessage);
                           when NO_DATA_FOUND then
                              l_logmessage:='contact_number fetch returned 0 rows'|| SQL%ROWCOUNT;
                              iem_logger(l_logmessage);
                              --dbms_output.put_line(l_logmessage);
                           when others then
                              l_logmessage:='contact_number other exception';
                              iem_logger(l_logmessage);
                              --dbms_output.put_line(l_logmessage);
                       END;
                     --run the queries to get values
                   ELSIF ((contact_rec.column_name = 'CONTACT_EMAIL') AND (p_contact_email IS NOT NULL)) THEN
                        BEGIN
                        IF (l_party_type = 'PERSON') THEN
                            l_logmessage:='contact_number->contact_email->type:person processing';
                            iem_logger(l_logmessage);
                            --dbms_output.put_line(l_logmessage);

                            Select c.party_id, c.party_type,  a.contact_point_id, a.contact_point_type
		            into x_contact_party_id, x_contact_type, x_contact_point_id, x_contact_point_type
                            from hz_contact_points a,hz_relationships b, hz_parties c
                            where a.owner_table_name='HZ_PARTIES'
                            and a.contact_point_type = 'EMAIL'
                            and a.status='A'
                            and a.owner_table_id = b.party_id
                            and a.contact_point_id not in  (select contact_level_table_id from HZ_CONTACT_PREFERENCES
     	 					    where contact_level_table='HZ_CONTACT_POINTS' and status='A')
	                    and b.party_id = c.party_id
                            and b.object_id in (select party_id from hz_parties where party_number = p_contact_number)
                            --and c.party_number =p_contact_number
                            and upper(c.email_address) = upper(p_contact_email)
	                    and b.subject_id = g_customer_id;

                         ELSIF (l_party_type = 'PARTY_RELATIONSHIP') THEN
                            l_logmessage:='contact_number->contact_email->type:party_relationship processing';
                            iem_logger(l_logmessage);
                            --dbms_output.put_line(l_logmessage);
                            Select c.party_id, c.party_type,  a.contact_point_id, a.contact_point_type
		            into x_contact_party_id, x_contact_type, x_contact_point_id, x_contact_point_type
                            from hz_contact_points a,hz_relationships b, hz_parties c
                            where a.owner_table_name='HZ_PARTIES'
                            and a.contact_point_type = 'EMAIL'
                            and a.status='A'
                            and a.owner_table_id = b.party_id
                            and a.contact_point_id not in  (select contact_level_table_id from HZ_CONTACT_PREFERENCES
     	 					    where contact_level_table='HZ_CONTACT_POINTS' and status='A')
	                    and b.party_id = c.party_id
                            --and b.object_id in (select party_id from hz_parties where party_number = p_contact_number)
                            and c.party_number =p_contact_number
                            and upper(c.email_address) = upper(p_contact_email)
	                    and b.subject_id = g_customer_id;
                          END IF;

                         EXCEPTION
                           when TOO_MANY_ROWS then
                              x_contact_party_id := null;
                              x_contact_type := null;
                              x_contact_point_id := null;
                              x_contact_point_type := null;
                              l_logmessage:='contact_number fetch returned too many rows'|| SQL%ROWCOUNT;
                              iem_logger(l_logmessage);
                               --dbms_output.put_line(l_logmessage);
                           when NO_DATA_FOUND then
                              l_logmessage:='contact_number fetch returned 0 rows'|| SQL%ROWCOUNT;
                              iem_logger(l_logmessage);
                                            --dbms_output.put_line(l_logmessage);
                           when others then
                              l_logmessage:='contact_number other exception';
                              iem_logger(l_logmessage);
                                            --dbms_output.put_line(l_logmessage);
                         END;
                    END IF;  --end if of contact_Column name checl

                --exit loop if x_contact_party_id has been found
                EXIT WHEN x_contact_party_id IS NOT NULL;
                END IF; --end if of x_contact_party_id check
             END LOOP;

            ---after going throug the loop if the x_contact_party_id was not populated then try alone
            -- wit the p_Contact_number information
            --NOTE: I am doing rownum = 1 here to get the top hit. Since we are given only contact_number
            --which can yeild multiple contact values for mail and phone.
            IF x_contact_party_id IS NULL THEN
                  BEGIN
                   IF (l_party_type = 'PERSON') THEN
                      --If we were not able to match in this case we are hoping to get single hit
                      -- based on the primary flag but many a times both phone and email are flagged Y
                            l_logmessage:='contact_number->no email or phone ->type:person processing';
                            iem_logger(l_logmessage);
                            --dbms_output.put_line(l_logmessage);
                      Select c.party_id, c.party_type,  a.contact_point_id, a.contact_point_type
		      into x_contact_party_id, x_contact_type, x_contact_point_id, x_contact_point_type
                      from hz_contact_points a,hz_relationships b, hz_parties c
                      where a.owner_table_name='HZ_PARTIES'
                      and a.status='A'
                      and a.primary_flag = 'Y'
                      and a.owner_table_id = b.party_id
                      and a.contact_point_id not in  (select contact_level_table_id from HZ_CONTACT_PREFERENCES
     	 			  where contact_level_table='HZ_CONTACT_POINTS' and status='A')
	               and b.party_id = c.party_id
                       and b.object_id in (select party_id from hz_parties where party_number = p_contact_number)
                      -- and c.party_number =p_contact_number
	               and b.subject_id = g_customer_id
                       and rownum = 1;
                    ELSIF (l_party_type = 'PARTY_RELATIONSHIP') THEN
                            l_logmessage:='contact_number->no email or phone ->type:party_relationship processing';
                            iem_logger(l_logmessage);
                            --dbms_output.put_line(l_logmessage);
                      Select c.party_id, c.party_type,  a.contact_point_id, a.contact_point_type
		      into x_contact_party_id, x_contact_type, x_contact_point_id, x_contact_point_type
                      from hz_contact_points a,hz_relationships b, hz_parties c
                      where a.owner_table_name='HZ_PARTIES'
                      and a.status='A'
                      and a.primary_flag = 'Y'
                      and a.owner_table_id = b.party_id
                      and a.contact_point_id not in  (select contact_level_table_id from HZ_CONTACT_PREFERENCES
     	 			  where contact_level_table='HZ_CONTACT_POINTS' and status='A')
	               and b.party_id = c.party_id
                       --and b.object_id in (select party_id from hz_parties where party_number = p_contact_number)
                       and c.party_number =p_contact_number
	               and b.subject_id = g_customer_id
                       and rownum = 1;
                    END IF;

                  EXCEPTION
                     when TOO_MANY_ROWS then
                              x_contact_party_id := null;
                              x_contact_type := null;
                              x_contact_point_id := null;
                              x_contact_point_type := null;
                        l_logmessage:='contact_number fetch returned too many rows'|| SQL%ROWCOUNT;
                        iem_logger(l_logmessage);
                                --dbms_output.put_line(l_logmessage);
                     when NO_DATA_FOUND then
                        l_logmessage:='contact_number fetch returned 0 rows'|| SQL%ROWCOUNT;
                        iem_logger(l_logmessage);
                                --dbms_output.put_line(l_logmessage);
                     when others then
                        l_logmessage:='contact_number other exception';
                        iem_logger(l_logmessage);
                                --dbms_output.put_line(l_logmessage);
                  END;
            END IF;
        END IF; --end if of of contact_id processing
  END getContactNumber;

 Procedure getContactName   (p_contact_name IN VARCHAR2,
                              p_parser_id      IN NUMBER,
                              p_contact_phone  IN VARCHAR2,
                              p_contact_email IN VARCHAR2,
                              x_contact_party_id  OUT NOCOPY NUMBER,
                              x_contact_type      OUT NOCOPY VARCHAR2,
                              x_contact_point_type    OUT NOCOPY VARCHAR2,
                              x_contact_point_id  OUT NOCOPY NUMBER)
  IS
    l_party_count NUMBER;
    l_logmessage		varchar2(2000):=' ';
  BEGIN

        --process this attribute only if g_contact_party_id has not been found yet.
        --if it has been found then there is not need to process this attribute a
          l_logmessage:='inside getContactName sub proc';
          iem_logger(l_logmessage);
           --dbms_output.put_line(l_logmessage);
        IF g_contact_party_id IS NULL THEN

             FOR contact_rec in (Select column_name, rank
                                 from iem_parser_dtls
                                 where parser_id = p_parser_id
                                 and UPPER(column_name) IN ('CONTACT_PHONE','CONTACT_EMAIL')
                                 order by rank asc)
             LOOP
                --only go throug the processing if the value has not been found
                --in the last itiration there fore checking the x_contact_party_id value
                IF (x_contact_party_id) IS NULL THEN
                   IF (contact_rec.column_name = 'CONTACT_PHONE') THEN
                      BEGIN
                          Select c.party_id, c.party_type,  a.contact_point_id, a.contact_point_type
		          into x_contact_party_id, x_contact_type, x_contact_point_id, x_contact_point_type
                          from hz_contact_points a,hz_relationships b, hz_parties c
                          where a.owner_table_name='HZ_PARTIES'
                          and  a.contact_point_type='PHONE'
                          and a.status='A'
                          and a.owner_table_id = b.party_id
                          and a.contact_point_id not in  (select contact_level_table_id from HZ_CONTACT_PREFERENCES
     	 					  where contact_level_table='HZ_CONTACT_POINTS' and status='A')
	                  and b.party_id = c.party_id
                          and b.object_id in (select party_id from hz_parties where upper(party_name) =upper(p_contact_name))
                          --and upper(c.party_name) =upper(p_contact_name)
                          and reverse(a.transposed_phone_number)=REGEXP_REPLACE(p_contact_phone,'([[:punct:]|[:space:]]*)')
	                  and b.subject_id = g_customer_id;
                             l_logmessage:='cotanct_name-phone'||p_contact_name||'--partyid:'||x_contact_party_id||'point_id'||x_contact_point_id ;
                             iem_logger(l_logmessage);
                             --dbms_output.put_line(l_logmessage);
                      EXCEPTION
                          when TOO_MANY_ROWS then
                              x_contact_party_id := null;
                              x_contact_type := null;
                              x_contact_point_id := null;
                              x_contact_point_type := null;
                             l_logmessage:='cotanct_name fetch returned too many rows'|| SQL%ROWCOUNT;
                             iem_logger(l_logmessage);
                                          --dbms_output.put_line(l_logmessage);
                          when NO_DATA_FOUND then
                             l_logmessage:='cotanct_name fetch returned 0 rows'|| SQL%ROWCOUNT;
                             iem_logger(l_logmessage);
                                          --dbms_output.put_line(l_logmessage);
                          when others then
                             l_logmessage:='cotanct_name other exception';
                             iem_logger(l_logmessage);
                                          --dbms_output.put_line(l_logmessage);
                      END;

                     --run the queries to get values
                   ELSIF (contact_rec.column_name = 'CONTACT_EMAIL') THEN
                        BEGIN
                          Select c.party_id, c.party_type,  a.contact_point_id, a.contact_point_type
		          into x_contact_party_id, x_contact_type, x_contact_point_id, x_contact_point_type
                          from hz_contact_points a,hz_relationships b, hz_parties c
                          where a.owner_table_name='HZ_PARTIES'
                          and a.contact_point_type = 'EMAIL'
                          and a.status='A'
                          and a.owner_table_id = b.party_id
                          and a.contact_point_id not in  (select contact_level_table_id from HZ_CONTACT_PREFERENCES
     	 					  where contact_level_table='HZ_CONTACT_POINTS' and status='A')
	                  and b.party_id = c.party_id
                         -- and upper(c.party_name) =upper(p_contact_name)
                          and b.object_id in (select party_id from hz_parties where upper(party_name) =upper(p_contact_name))
                          and upper(c.email_address) = upper(p_contact_email)
	                  and b.subject_id = g_customer_id;
                             l_logmessage:='cotanct_name-email'||p_contact_name||'--partyid:'||x_contact_party_id||'point_id'||x_contact_point_id ;
                               iem_logger(l_logmessage);
                               --dbms_output.put_line(l_logmessage);
                         EXCEPTION
                            when TOO_MANY_ROWS then
                              x_contact_party_id := null;
                              x_contact_type := null;
                              x_contact_point_id := null;
                              x_contact_point_type := null;
                               l_logmessage:='cotanct_name fetch returned too many rows'|| SQL%ROWCOUNT;
                               iem_logger(l_logmessage);
                                              --dbms_output.put_line(l_logmessage);
                            when NO_DATA_FOUND then
                               l_logmessage:='cotanct_name fetch returned 0 rows'|| SQL%ROWCOUNT;
                               iem_logger(l_logmessage);
                                              --dbms_output.put_line(l_logmessage);
                            when others then
                               l_logmessage:='cotanct_name other exception';
                               iem_logger(l_logmessage);
                                              --dbms_output.put_line(l_logmessage);
                         END;
                    END IF;  --end if of contact_Column name checl
                --exit out of the loop if x_contact_party_id was found
                EXIT WHEN x_contact_party_id IS NOT NULL;
                END IF; --end if of x_contact_party_id check
             END LOOP;

            ---after going throug the loop if the x_contact_party_id was not populated then try alone
            -- wit the p_Contact_name information
            IF x_contact_party_id IS NULL THEN
                  BEGIN
                      Select c.party_id, c.party_type,  a.contact_point_id, a.contact_point_type
		      into x_contact_party_id, x_contact_type, x_contact_point_id, x_contact_point_type
                      from hz_contact_points a,hz_relationships b, hz_parties c
                      where a.owner_table_name='HZ_PARTIES'
                      and a.status='A'
                      and a.primary_flag = 'Y'
                      and a.owner_table_id = b.party_id
                      and a.contact_point_id not in  (select contact_level_table_id from HZ_CONTACT_PREFERENCES
     	 			  where contact_level_table='HZ_CONTACT_POINTS' and status='A')
	               and b.party_id = c.party_id
                       and b.object_id in (select party_id from hz_parties where upper(party_name) =upper(p_contact_name))
                       --and upper(c.party_name) =upper(p_contact_name)
	               and b.subject_id = g_customer_id;
                          l_logmessage:='cotanct_name-alone'||p_contact_name||'--partyid:'||x_contact_party_id||'point_id'||x_contact_point_id ;
                               iem_logger(l_logmessage);
                               --dbms_output.put_line(l_logmessage);
                  EXCEPTION
                          when TOO_MANY_ROWS then
                              x_contact_party_id := null;
                              x_contact_type := null;
                              x_contact_point_id := null;
                              x_contact_point_type := null;
                             l_logmessage:='cotanct_name fetch returned too many rows'|| SQL%ROWCOUNT;
                             iem_logger(l_logmessage);
                                          --dbms_output.put_line(l_logmessage);
                          when NO_DATA_FOUND then
                             l_logmessage:='cotanct_name fetch returned 0 rows'|| SQL%ROWCOUNT;
                             iem_logger(l_logmessage);
                                          --dbms_output.put_line(l_logmessage);
                          when others then
                             l_logmessage:='cotanct_name other exception';
                             iem_logger(l_logmessage);
                                          --dbms_output.put_line(l_logmessage);
                  END;
            END IF;
        END IF; --end if of of contact_id processing
  END getContactName;



  --Qestion: check the parent_id = contact_point_id match
  --primary flag is not a required filed for the sr contact rec type
  --Note we should not call this procedure if the account type is of internal
  --and we should pass the contact_id and contact_point_id that is passed by the
  --calling api
  Procedure getContactPhone (p_contact_phone IN VARCHAR2,
                             x_contact_party_id  OUT NOCOPY NUMBER,
                             x_contact_type      OUT NOCOPY VARCHAR2,
                             x_contact_point_type      OUT NOCOPY VARCHAR2,
                             x_contact_point_id  OUT NOCOPY NUMBER)
  IS
    l_phone_count number;
    l_logmessage		varchar2(2000):=' ';
  BEGIN

     --part_role_code is a required field for contact SR information
     --there for populating it.
     IF (g_contact_party_id IS NULL)  THEN
           BEGIN
                  Select c.party_id, c.party_type,  a.contact_point_id, a.contact_point_type
		  into x_contact_party_id, x_contact_type, x_contact_point_id, x_contact_point_type
                  from hz_contact_points a,hz_relationships b, hz_parties c
                  where a.owner_table_name='HZ_PARTIES'
                  and  a.contact_point_type='PHONE'
                  and a.status='A'
                  and a.owner_table_id = b.party_id
                  and a.contact_point_id not in  (select contact_level_table_id from HZ_CONTACT_PREFERENCES
     	 					  where contact_level_table='HZ_CONTACT_POINTS' and status='A')
	          and b.party_id = c.party_id
                  and reverse(a.transposed_phone_number)=REGEXP_REPLACE(p_contact_phone,'([[:punct:]|[:space:]]*)')
	          and b.subject_id = g_customer_id;
            EXCEPTION
                 when TOO_MANY_ROWS then
                              x_contact_party_id := null;
                              x_contact_type := null;
                              x_contact_point_id := null;
                              x_contact_point_type := null;
                      l_logmessage:='cotanct_phone fetch returned too many rows'|| SQL%ROWCOUNT;
                      iem_logger(l_logmessage);
                            --dbms_output.put_line(l_logmessage);
                 when NO_DATA_FOUND then
                      l_logmessage:='cotanct_phone fetch returned 0 rows'|| SQL%ROWCOUNT;
                      iem_logger(l_logmessage);
                            --dbms_output.put_line(l_logmessage);
                 when others then
                       l_logmessage:='cotanct_phone other exception';
                      iem_logger(l_logmessage);
                            --dbms_output.put_line(l_logmessage);
             END;
     END IF;
  END getContactPhone;


  Procedure getContactEmail (p_contact_email IN VARCHAR2,
                             x_contact_party_id  OUT NOCOPY NUMBER,
                             x_contact_type      OUT NOCOPY VARCHAR2,
                             x_contact_point_type      OUT NOCOPY VARCHAR2,
                             x_contact_point_id  OUT NOCOPY NUMBER)
  IS
    l_email_count number;
    l_logmessage		varchar2(2000):=' ';
  BEGIN

     IF (g_contact_party_id IS NULL)  THEN
           BEGIN
                  Select c.party_id, c.party_type,  a.contact_point_id, a.contact_point_type
		  into x_contact_party_id, x_contact_type, x_contact_point_id, x_contact_point_type
                  from hz_contact_points a,hz_relationships b, hz_parties c
                  where a.owner_table_name='HZ_PARTIES'
                  and  a.contact_point_type='EMAIL'
                  and a.status='A'
                  and a.owner_table_id = b.party_id
                  and a.contact_point_id not in  (select contact_level_table_id from HZ_CONTACT_PREFERENCES
     	 					  where contact_level_table='HZ_CONTACT_POINTS' and status='A')
	          and b.party_id = c.party_id
                  and upper(a.email_address)=upper(p_contact_email)
	          and b.subject_id = g_customer_id;
            EXCEPTION
                 when TOO_MANY_ROWS then
                              x_contact_party_id := null;
                              x_contact_type := null;
                              x_contact_point_id := null;
                              x_contact_point_type := null;
                      l_logmessage:='cotanct_email fetch returned too many rows'|| SQL%ROWCOUNT;
                      iem_logger(l_logmessage);
                            --dbms_output.put_line(l_logmessage);
                 when NO_DATA_FOUND then
                    l_logmessage:='cotanct_email fetch returned 0 rows'|| SQL%ROWCOUNT || 'email is:'||p_contact_email||'cust_id:'||g_customer_id;
                      iem_logger(l_logmessage);
                            --dbms_output.put_line(l_logmessage);
                 when others then
                       l_logmessage:='cotanct_email other exception';
                      iem_logger(l_logmessage);
                            --dbms_output.put_line(l_logmessage);
             END;
      END IF;

  END getContactEmail;

  --inventory stuff
  Procedure getInventoryItemName (p_inventory_item_name IN VARCHAR2,
                                  x_inventory_item_id OUT NOCOPY NUMBER,
                                  x_inventory_org_id OUT NOCOPY NUMBER)
  IS
    l_inventory_count number;
    l_logmessage		varchar2(2000):=' ';
  BEGIN

     BEGIN
       select DISTINCT inventory_item_id, organization_id
       into x_inventory_item_id, x_inventory_org_id
       from mtl_system_items_b
       where organization_id=FND_PROFILE.value('CS_INV_VALIDATION_ORG') and
       upper(segment1)= upper(p_inventory_item_name);

       l_logmessage:='inventoryItemName is '||p_inventory_item_name||' inventory_item_id is '|| x_inventory_item_id;
       iem_logger(l_logmessage);
       --dbms_output.put_line(l_logmessage);
       l_logmessage:='inventoryItemName is '||p_inventory_item_name||' inventory_org_id is '|| x_inventory_org_id;
       iem_logger(l_logmessage);
       --dbms_output.put_line(l_logmessage);
     EXCEPTION
         when TOO_MANY_ROWS then
              x_inventory_item_id := null;
              x_inventory_org_id  := null;
              l_logmessage:='inventoryItemName fetch returned too many rows'|| SQL%ROWCOUNT;
              iem_logger(l_logmessage);
              --dbms_output.put_line(l_logmessage);
         when NO_DATA_FOUND then
              l_logmessage:='inventoryItemName fetch returned 0 rows'|| SQL%ROWCOUNT;
              iem_logger(l_logmessage);
            --dbms_output.put_line(l_logmessage);
         when others then
              l_logmessage:='inventoryItemName other exception';
              iem_logger(l_logmessage);
                --dbms_output.put_line(l_logmessage);
     END;

  END getInventoryItemName;
  --end of inventory related stuff


  --get service request type and if no type is found get the default
  --type from the calling program to use it.
  PROCEDURE getServiceRequestType (p_service_request_type IN VARCHAR2,
                                   p_default_type_id      IN NUMBER,
	                           x_type_id              OUT NOCOPY NUMBER)
  IS
   l_type_id number;
   l_return_status varchar2(10);
   l_logmessage		varchar2(2000):=' ';
  BEGIN
    --Validate against CS_ServiceRequest_UTIL.Convert_Type_To_ID Where pass subtype='INC'
    CS_ServiceRequest_UTIL.Convert_Type_To_ID (
        p_api_name             => 'Advanced_SR_PROCESSING.GETSERVICEREQUESTTYPE',
	p_parameter_name       => 'LOOKUP_TYPE',
        p_type_name            => p_service_request_type,
        p_subtype              => 'INC',
        p_parent_type_id       => FND_API.G_MISS_NUM,
        p_type_id              => l_type_id,
        x_return_status        => l_return_status);

    IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         x_type_id := l_type_id;
           l_logmessage:='sr_type_id found sr_type_id :'||l_type_id;
           iem_logger(l_logmessage);
           --dbms_output.put_line(l_logmessage);
    ELSE
        --use the default type id
         x_type_id := p_default_type_id;
           l_logmessage:='sr_type_id not found using default type id :'||p_default_type_id;
           iem_logger(l_logmessage);
           --dbms_output.put_line(l_logmessage);
    END IF;
  END getServiceRequestType;


 Procedure getProblemCode (p_problem_code in VARCHAR2,
                           x_problem_code OUT NOCOPY VARCHAR2)
  IS
    l_code_count NUMBER;
    l_logmessage		varchar2(2000):=' ';
  BEGIN
     select count(problem_code) into l_code_count
     from cs_sr_prob_code_mapping_detail
     where problem_code = p_problem_code;

     l_logmessage:='problemcode rowcount for'|| p_problem_code ||' returned count'|| l_code_count;
     iem_logger(l_logmessage);
     --dbms_output.put_line(l_logmessage);

     --the code exisit in the system
     IF l_code_count >0 THEN
        x_problem_code := p_problem_code;
     ELSE
        x_problem_code := null;
     END IF;
  EXCEPTION
         when TOO_MANY_ROWS then
              l_logmessage:='problemcode fetch returned too many rows'|| SQL%ROWCOUNT;
              iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);
         when NO_DATA_FOUND then
              l_logmessage:='problemcode fetch returned 0 rows'|| SQL%ROWCOUNT;
          iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);
         when others then
              l_logmessage:='problemcode other exception';
          iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);

  END getProblemCode;

  Procedure getUrgency (p_urgency IN VARCHAR2,
  	                x_urgency_id OUT NOCOPY NUMBER)
  IS
   l_urgency_id number;
   l_return_status VARCHAR2(10);
   l_logmessage		varchar2(2000):=' ';
  BEGIN
   --  Validate against CS_ServiceRequest_UTIL. Convert_Urgency_To_ID
    CS_ServiceRequest_UTIL.Convert_Urgency_To_ID
      ( p_api_name            => 'ADVANCED_SR_PROCESSING.GETURGENCY',
        p_parameter_name      => 'Urgency Name',
        p_urgency_name        => p_urgency,
        p_urgency_id          => l_urgency_id,
        x_return_status       => l_return_status);

     IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
        x_urgency_id := l_urgency_id;
     END IF;

  END getUrgency;

  Procedure getSiteName(p_site_name      IN VARCHAR2,
                        x_party_site_id  OUT NOCOPY NUMBER)
  IS
    l_site_count NUMBER;
     l_logmessage		varchar2(2000):=' ';
  BEGIN
    IF (g_customer_id IS NOT NULL) THEN
        BEGIN
          select party_site_id into x_party_site_id
          from hz_party_sites
          where upper(party_site_name) = upper(p_site_name)
          and party_id = g_customer_id;
        EXCEPTION
          when TOO_MANY_ROWS then
               x_party_site_id := null;
              l_logmessage:='inventoryItemName fetch returned too many rows'|| SQL%ROWCOUNT;
          iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);
          when NO_DATA_FOUND then
              l_logmessage:='inventoryItemName fetch returned 0 rows'|| SQL%ROWCOUNT;
          iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);
          when others then
              l_logmessage:='inventoryItemName other exception';
          iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);
        END;
    END IF;
  END getSiteName;

  --initially we had decided that we will call the utilpackage.Validate_External_Reference
  --to ensure weather a valid ext_ref was passed. However the util procedure expects a
  --lot of values to do that particuualr validation and since we dont have all the attributes
  --to be passed to the util package; we will validate the ext ref passed with the
  --csi_item_instance table only. The other thing to keep in mind is that the UTIL procdure
  --is not checking the case during its validation
  Procedure getExtReference(p_ext_ref               IN VARCHAR2,
                            p_customer_product_id   IN NUMBER,
                            x_ext_ref               OUT NOCOPY VARCHAR2)
   IS
    l_ext_ref_count NUMBER;
     l_logmessage		varchar2(2000):=' ';
   BEGIN
   --took out the if condition and will let the api handle any errors
    --IF (p_customer_product_id is not null) THEN
        --we will just do a simple validation for ext_Ref_item and if it exists
        --then we will just pass it to the SR API and the let the SR api handle
        --additional validation.
        select count(external_reference) into l_ext_ref_count
        from   csi_item_instances
        where  upper(external_reference) = upper(p_ext_ref);
        --where instance_id = p_customer_product_id
         l_logmessage:='external reference count for '|| p_ext_Ref||' is '||l_ext_ref_count;
         iem_logger(l_logmessage);
         --dbms_output.put_line(l_logmessage);


        IF l_ext_ref_count >0 THEN
          x_ext_ref := p_ext_ref;
        END IF;

   -- END IF;

    --signature of util prcodeure which is not being called due to the extensive
    --requirement of the attributes
    /*
    Validate_External_Reference(
    p_api_name			     IN  VARCHAR2,
    p_parameter_name		 IN  VARCHAR2,
    p_external_reference     IN  VARCHAR2,
    p_customer_product_id    IN  NUMBER,
    p_inventory_item_id      IN  NUMBER   := NULL,
    p_inventory_org_id       IN  NUMBER   := NULL,
    p_customer_id            IN NUMBER    := NULL,
    x_return_status			 OUT  NOCOPY VARCHAR2
    */
   END getExtReference;



  FUNCTION GET_TAG_DATA
  ( p_start_tag   IN VARCHAR2,
    p_end_tag     IN VARCHAR2,
    p_message_id  IN NUMBER
   ) return VARCHAR2
  IS
    l_start_pos number;
    l_end_pos   number;
    l_length    number;
    l_body      varchar2(32000);
    l_start_tag VARCHAR2(300);
    l_end_tag   VARCHAR2(300);
    l_token     varchar2(5000);
    l_logmessage		varchar2(2000):=' ';

    cursor c_msg_body (l_message_id IN NUMBER)
    IS
    select upper(value) email
    from IEM_MS_MSGBODYS
    where message_id = l_message_id
    order by order_id asc;
  BEGIN

    l_logmessage:='tag processing ';
          iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);
    l_logmessage:='message_id '|| p_message_id ;
          iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);
    --get the body
    for msg in c_msg_body(p_message_id)
    LOOP
     l_body:= l_body || msg.email;
    END LOOP;

    --set everything to uppercase to prevent case validation run time error
    l_start_tag := upper(p_start_tag);
    l_end_tag := upper(p_end_tag);

    --get the start position for for the tag
    l_start_pos := INSTR(l_body,l_start_tag);

    --get the first occurance of the end position of the tag
    l_end_pos := INSTR(l_body,l_end_tag,l_start_pos,1);

    --get the length between the start and the end position.
    l_length := l_end_pos - l_start_pos;

    --get all the characters starting from the start tag till the starting of the end tag
    --note this includes the start tag
    l_token := SUBSTR(l_body,l_start_pos,l_length);

    --since we grabbed everything including the start tag
    --we need to replace the start tag with blank to get the raw value of the tag data
    l_token := REPLACE(l_token,l_start_tag,'');

    --trim the text so that leading and trailing spaces are taken out.
    l_token := TRIM(l_token);

    l_logmessage:='start_tag '|| l_Start_tag ;
          iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);
    l_logmessage:='end tag '|| l_end_tag ;
          iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);
    l_logmessage:='value '|| l_token ;
          iem_logger(l_logmessage);
    --dbms_output.put_line(l_logmessage);
    -- return the trimmed information to the calling program
    return l_token;

  END GET_TAG_DATA;


--siahmed end of 12.1.3 advanced sr processing

end IEM_EMAIL_PROC_PVT;

/
