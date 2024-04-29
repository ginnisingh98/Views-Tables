--------------------------------------------------------
--  DDL for Package Body IEM_GETMERGEVALUE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_GETMERGEVALUE_PVT" as
/* $Header: iemvmrgb.pls 115.3 2002/12/04 22:52:19 sboorela shipped $*/

/**********************Global Variable Declaration **********************/

	PROCEDURE 	IEM_GET_MERGE_VALUES(
			p_msgid in number,
			x_merge_vals OUT NOCOPY template_merge_tbl,
			x_status	out NOCOPY varchar2) IS

		l_dblink		varchar2(250);
		l_user		varchar2(100);
		l_domain		varchar2(100);
		l_password		varchar2(100);
		l_account_name	varchar2(256);
		l_source_message_id number;
		l_subject	varchar2(1000);
		l_sender	varchar2(70);
		l_to_recip	varchar2(1000);
		l_cc_recip	varchar2(100);
		l_fwd_recip	varchar2(100);
		l_frm_str	varchar2(100);
		l_sentdate	date;
		l_received_date	date;
		l_str		varchar2(500);
		l_replyto		varchar2(500);
		l_ret		number;
		l_index		number;
		l_sender_name  varchar2(500);
		l_reply_to	varchar2(100);
		l_msg_size 	number;
		l_counter 	number;
	BEGIN
			x_status:='S';
		select '@'||a.db_link,b.email_user,b.email_password, b.domain,
		b.account_name,c.source_message_id,c.received_date,b.reply_to_address
		INTO
		l_dblink,l_user,l_password,l_domain,
		l_account_name,l_source_message_id,l_received_date,l_replyto
		from iem_db_connections a,iem_email_accounts b,iem_post_mdts c
		where  c.message_id=p_msgid
		and b.email_account_id=c.email_account_id
		and a.db_server_id=b.db_server_id
		and a.is_admin='A';
		l_str:='begin :l_ret:=im_api.authenticate'||l_dblink||'(:a_user,:a_domain,:a_password);end; ';
EXECUTE IMMEDIATE l_str using OUT l_ret,l_user,l_domain,l_password;
 	l_str :='begin :l_ret:=im_api.GetMessageHdrs'||l_dblink||'(:a_msg_id,:a_subject,:a_sender,:a_to_recip,:a_cc_recip,:a_frm_str,:a_sent_date,:a_reply_to,:a_msg_size);end;';
 	EXECUTE IMMEDIATE l_str USING OUT l_ret,l_source_message_id,OUT l_subject,
	OUT l_sender,OUT l_to_recip,OUT l_cc_recip,OUT l_frm_str,OUT l_sentdate,
	OUT l_reply_to, OUT l_msg_size;
	l_index:=instr(l_frm_str,'<',1,1);

	IF l_index>0 then
		l_sender_name:=substr(l_frm_Str,1,l_index-1);
		l_sender_name:=replace(l_sender_name,'"','');
	else
    			FND_MESSAGE.Set_Name('IEM','IEM_ADM_AUTO_ACK_CUSTOMER');
 			FND_MSG_PUB.Add;
 	l_sender_name :=  FND_MSG_PUB.GET(FND_MSG_pub.Count_Msg,FND_API.G_FALSE);
	end if;
			x_merge_vals.delete;
			l_counter:=1;
			x_merge_vals(l_counter).field_name:='ACK_SENDER_NAME';
			x_merge_vals(l_counter).field_value:=l_sender_name;
			l_counter:=l_counter+1;
			x_merge_vals(l_counter).field_name:='ACK_SUBJECT';
			x_merge_vals(l_counter).field_value:=l_subject;
			l_counter:=l_counter+1;
			x_merge_vals(l_counter).field_name:='ACK_RECEIVED_DATE';
			x_merge_vals(l_counter).field_value:=l_received_date;
			l_counter:=l_counter+1;
			x_merge_vals(l_counter).field_name:='ACK_ACCT_FROM_NAME';
			x_merge_vals(l_counter).field_value:=l_account_name;
			l_counter:=l_counter+1;
			x_merge_vals(l_counter).field_name:='ACK_ACCT_EMAIL_ADDRESS';
			x_merge_vals(l_counter).field_value:=l_replyto;

	EXCEPTION WHEN OTHERS THEN
		x_status:='E';
 END IEM_GET_MERGE_VALUES;

	PROCEDURE 	IEM_GET_MERGE_VALUE(
			p_msgid in number,
			p_merge_key IN varchar2,
			x_merge_val OUT NOCOPY varchar2,
			x_status	out NOCOPY varchar2) IS

		l_dblink		varchar2(250);
		l_user		varchar2(100);
		l_domain		varchar2(100);
		l_password		varchar2(100);
		l_account_name	varchar2(256);
		l_source_message_id number;
		l_subject	varchar2(1000);
		l_sender	varchar2(70);
		l_to_recip	varchar2(1000);
		l_cc_recip	varchar2(100);
		l_fwd_recip	varchar2(100);
		l_frm_str	varchar2(100);
		l_sentdate	date;
		l_received_date	date;
		l_str		varchar2(500);
		l_replyto		varchar2(500);
		l_ret		number;
		l_index		number;
		l_sender_name  varchar2(500);
		l_reply_to	varchar2(100);
		l_msg_size 	number;
   BEGIN
			x_status:='S';

		select '@'||a.db_link,b.email_user,b.email_password, b.domain,
		b.account_name,c.source_message_id,c.received_date,b.reply_to_address
		INTO
		l_dblink,l_user,l_password,l_domain,
		l_account_name,l_source_message_id,l_received_date,l_replyto
		from iem_db_connections a,iem_email_accounts b,iem_post_mdts c
		where  c.message_id=p_msgid
		and b.email_account_id=c.email_account_id
		and a.db_server_id=b.db_server_id
		and a.is_admin='A';
IF upper(p_merge_key)='ACK_SENDER_NAME' THEN
		l_str:='begin :l_ret:=im_api.authenticate'||l_dblink||'(:a_user,:a_domain,:a_password);end; ';
EXECUTE IMMEDIATE l_str using OUT l_ret,l_user,l_domain,l_password;
 	l_str :='begin :l_ret:=im_api.GetMessageHdrs'||l_dblink||'(:a_msg_id,:a_subject,:a_sender,:a_to_recip,:a_cc_recip,:a_frm_str,:a_sent_date,:a_reply_to,:a_msg_size);end;';
 	EXECUTE IMMEDIATE l_str USING OUT l_ret,l_source_message_id,OUT l_subject,
	OUT l_sender,OUT l_to_recip,OUT l_cc_recip,OUT l_frm_str,OUT l_sentdate,
	OUT l_reply_to, OUT l_msg_size;
	l_index:=instr(l_frm_str,'<',1,1);

	IF l_index>0 then
		l_sender_name:=substr(l_frm_Str,1,l_index-1);
		l_sender_name:=replace(l_sender_name,'"','');
	else
		l_sender_name:='Customer '; -- need to be from profile
	end if;
		x_merge_val:=l_sender_name;
ELSIF upper(p_merge_key)='ACK_SUBJECT' THEN
		x_merge_val:=l_subject;
ELSIF upper(p_merge_key)='ACK_RECEIVED_DATE' THEN
		x_merge_val:=l_received_date;
ELSIF upper(p_merge_key)='ACK_ACCT_FROM_NAME' THEN
		x_merge_val:=l_account_name;
ELSIF upper(p_merge_key)='ACK_ACCT_EMAIL_ADDRESS' THEN
		x_merge_val:=l_replyto;
END IF;
EXCEPTION WHEN OTHERS THEN
	x_status:='E';
END IEM_GET_MERGE_VALUE;
END ;

/
