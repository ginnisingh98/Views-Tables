--------------------------------------------------------
--  DDL for Package Body IEM_SEARCHMESSAGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_SEARCHMESSAGE_PVT" as
/* $Header: iemvmshb.pls 120.3 2005/09/30 12:42:23 appldev noship $*/
G_PKG_NAME CONSTANT varchar2(30) :='IEM_SEARCHMESSAGE_PVT ';
PROCEDURE searchmessages (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			p_email_account_id         IN NUMBER,
			p_resource_id         IN NUMBER,
			p_email_queue         IN varchar2,
			p_sent_date_from	IN varchar2,
			p_sent_date_to		IN varchar2,
			p_received_date_from	in date,
			p_received_date_to		in date,
			p_from_str	in		varchar2,
			p_recepients	in		varchar2,
			p_cc_flag		in		varchar2,
			p_subject		in 		varchar2,
			p_message_body	 in varchar2,
			p_customer_id		in number,
			p_classification 	in varchar2,
			p_resolved_agent	in varchar2,
			p_resolved_group	in varchar2,
			x_message_tbl	out nocopy message_rec_tbl,
		      x_return_status OUT NOCOPY VARCHAR2,
  		 	 x_msg_count	      OUT NOCOPY NUMBER,
	  	  	 x_msg_data OUT NOCOPY VARCHAR2
			 ) IS
	 l_cursorid INTEGER;
   	l_dummy INTEGER;
	l_api_version_number	number:=1.0;
	l_api_name		varchar2(30):='searchmessage';
	l_str			varchar2(1000);
	l_exe_Str			varchar2(2000);
	Type get_data is REF CURSOR;-- RETURN acq_email_info_tbl;
	email_cur		get_data;
	l_temp_tbl		message_rec_tbl;
	l_counter		number:=1;
	l_message_id	iem_arch_msgdtls.message_id%type;
	l_ih_media_item_id	iem_arch_msgdtls.ih_media_item_id%type;
	l_from_str	iem_arch_msgdtls.from_str%type;
	l_from_str1	iem_arch_msgdtls.from_str%type;
	l_to_str	iem_arch_msgdtls.to_str%type;
	l_to_str1	iem_arch_msgdtls.to_str%type;
	l_subject		iem_arch_msgdtls.subject%type;
	l_subject1		iem_arch_msgdtls.subject%type;
	l_sent_date		iem_arch_msgdtls.sent_date%type;
	l_Str1		varchar2(500);
BEGIN
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
SAVEPOINT select_mail_count_pvt;
IF p_email_queue <> 'I' THEN			-- Search non draft message

	l_str:='select message_id,ih_media_item_id,from_str,to_str,subject, to_char(to_date(substr(sent_Date,1,20),''DD-MON-YYYY HH24:MI:SS''),''MM/DD/RRRR HH24:MI:SS'')';
	l_str1:=' from iem_arch_msgdtls where email_account_id=:id and mailproc_status=:q_status';
	l_str:=l_str||l_str1;

	If p_sent_date_from is not null  then
		l_str:=l_str||' AND to_date(substr(sent_Date,1,20),''DD-MON-YYYY HH24:MI:SS'') >= to_date(:f_dt,''mm-dd-rrrr hh24:mi:ss'')';
	end if;
	if p_sent_date_to is not null then
		 l_str:=l_str||' AND to_date(substr(sent_Date,1,20),''DD-MON-YYYY HH24:MI:SS'') <= to_date(:t_dt,''mm-dd-rrrr hh24:mi:ss'')';
	end if;

	IF p_subject is not null then
		l_str:=l_str||' AND upper(subject) like :subject';
	END IF;
	IF p_from_str is not null then
		l_str:=l_str||' AND upper(from_str) like :from1';
	END IF;
	IF p_recepients is not null and nvl(p_cc_flag,' ')<>'Y' then
		l_str:=l_str||' AND upper(to_str) like :tostr';
	END IF;
	IF p_recepients is not null and nvl(p_cc_flag,' ')='Y' then
		l_str:=l_str||' AND (upper(to_str) like :tostr OR upper(cc_str) like :tostr)';
	END IF;

ELSE

	l_str:='select a.message_id,b.ih_media_item_id,a.from_str,a.to_str,a.subject,to_char(to_date(substr(a.sent_Date,1,20),''DD-MON-YYYY HH24:MI:SS''),''MM/DD/RRRR HH24:MI:SS'')';
	l_str1:=' from iem_ms_base_headers a,iem_rt_proc_emails b,iem_rt_media_items c where a.message_id=b.message_id and b.resource_id=:resource_id and b.email_account_id=:id and b.message_id=c.message_id and c.expire=''N''';
	l_str:=l_str||l_str1;
	If p_sent_date_from is not null  then
		l_str:=l_str||' AND to_date(substr(a.sent_Date,1,20),''DD-MON-YYYY HH24:MI:SS'') >= to_date(:f_dt,''mm-dd-rrrr hh24:mi:ss'')';
	end if;

	if p_sent_date_to is not null then
		 l_str:=l_str||' AND to_date(substr(a.sent_Date,1,20),''DD-MON-YYYY HH24:MI:SS'') <= to_date(:t_dt,''mm-dd-rrrr hh24:mi:ss'')';
	end if;

	IF p_subject is not null then
		l_str:=l_str||' AND upper(a.subject) like :subject';
	END IF;
	IF p_from_str is not null then
		l_str:=l_str||' AND upper(a.from_str) like :from1';
	END IF;
	IF p_recepients is not null and nvl(p_cc_flag,' ')<>'Y' then
		l_str:=l_str||' AND upper(a.to_str) like :tostr';
	END IF;
	IF p_recepients is not null and nvl(p_cc_flag,' ')='Y' then
		l_str:=l_str||' AND (upper(a.to_str) like :tostr OR upper(a.cc_str) like :tostr)';
	END IF;
END IF;				-- End if for p_email_queue<>'I'
 	l_cursorID := DBMS_SQL.OPEN_CURSOR;
	DBMS_SQL.PARSE(l_cursorID, l_str, DBMS_SQL.native);
		DBMS_SQL.BIND_VARIABLE(l_cursorid, ':id', p_email_account_id);
	IF p_email_queue <>'I' THEN
		DBMS_SQL.BIND_VARIABLE(l_cursorid, ':q_status', p_email_queue);
	END IF;
	IF p_resource_id is not null then
		DBMS_SQL.BIND_VARIABLE(l_cursorid, ':resource_id', p_resource_id);
	END IF;
	If p_sent_date_from is not null  then
		DBMS_SQL.BIND_VARIABLE(l_cursorid, ':f_dt', p_sent_date_from);
	end if;

	if p_sent_date_to is not null then
		DBMS_SQL.BIND_VARIABLE(l_cursorid, ':t_dt', p_sent_date_to);
	end if;
	IF p_subject is not null then
		l_subject1:=upper(p_subject);
		DBMS_SQL.BIND_VARIABLE(l_cursorid, ':subject', l_subject1);
	END IF;
	IF p_from_str is not null then
		l_from_str1:='%'||upper(p_from_str)||'%';
		DBMS_SQL.BIND_VARIABLE(l_cursorid, ':from1', l_from_str1);
	END IF;
	IF p_recepients is not null then
		l_to_str1:='%'||upper(p_recepients)||'%';
		DBMS_SQL.BIND_VARIABLE(l_cursorid,':tostr',l_to_str1);
	END IF;
	DBMS_SQL.DEFINE_COLUMN(l_cursorID, 1, l_message_id);
	DBMS_SQL.DEFINE_COLUMN(l_cursorID, 2, l_ih_media_item_id);
	DBMS_SQL.DEFINE_COLUMN(l_cursorID, 3, l_from_str,2000);
	DBMS_SQL.DEFINE_COLUMN(l_cursorID, 4, l_to_str,2000);
	DBMS_SQL.DEFINE_COLUMN(l_cursorID, 5, l_subject,2000);
	DBMS_SQL.DEFINE_COLUMN(l_cursorID, 6, l_sent_date,60);

	l_dummy := DBMS_SQL.EXECUTE(l_cursorID);
    LOOP
     IF (DBMS_SQL.FETCH_ROWS(l_cursorid) = 0) THEN
        EXIT;
     END IF;
	DBMS_SQL.COLUMN_VALUE(l_cursorID, 1, l_message_id);
	DBMS_SQL.COLUMN_VALUE(l_cursorID, 2, l_ih_media_item_id);
	DBMS_SQL.COLUMN_VALUE(l_cursorID, 3, l_from_str);
	DBMS_SQL.COLUMN_VALUE(l_cursorID, 4, l_to_str);
	DBMS_SQL.COLUMN_VALUE(l_cursorID, 5, l_subject);
	DBMS_SQL.COLUMN_VALUE(l_cursorID, 6, l_sent_date);

	x_message_tbl(l_counter).message_id:=l_message_id;
	x_message_tbl(l_counter).ih_media_item_id:=l_ih_media_item_id;
	x_message_tbl(l_counter).from_str:=l_from_str;
	x_message_tbl(l_counter).to_str:=l_to_str;
	x_message_tbl(l_counter).subject:=l_subject;
	x_message_tbl(l_counter).sent_date:=l_sent_date;
	   l_counter:=l_counter+1;
    END LOOP;

DBMS_SQL.CLOSE_CURSOR(l_cursorID);

	IF p_commit='T' THEN
		COMMIT WORK;
	END IF;
	x_return_Status:='S';
-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 	p_data  =>    x_msg_data
			);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO select_mail_count_pvt;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO select_mail_count_pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO select_mail_count_pvt;
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
END searchmessages;
END IEM_SEARCHMESSAGE_PVT ;

/
