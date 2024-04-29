--------------------------------------------------------
--  DDL for Package Body IEM_EMAILACCOUNT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_EMAILACCOUNT_PUB" as
/* $Header: iempactb.pls 120.9.12010000.2 2009/08/27 06:07:19 shramana ship $ */
G_PKG_NAME CONSTANT varchar2(30) :='IEM_EMAILACCOUNT_PUB ';

PROCEDURE Get_EmailAccount_List (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	      p_commit	    IN   VARCHAR2 := FND_API.G_FALSE,
			      p_RESOURCE_ID  IN NUMBER:=null,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2,
 			      x_Email_Acnt_tbl  OUT NOCOPY  EMACNT_tbl_type
			 ) is
CURSOR email_details_csr IS

   SELECT    a.from_name,
             a.user_name,
        	a.email_account_id
   FROM      IEM_MSTEMAIL_ACCOUNTS A,
             JTF_RS_RESOURCE_VALUES B
   WHERE     (B.resource_id=p_RESOURCE_ID)
   AND       (A.email_account_id=B.VALUE_TYPE);

CURSOR email_details_no_resource_csr IS

   SELECT    a.from_name,
             a.user_name,
		 a.email_account_id
   FROM      IEM_MSTEMAIL_ACCOUNTS A ;
	l_email_index	number:=1;

	l_api_name        		VARCHAR2(255):='Get_EmailAccount_List';
	l_api_version_number 	NUMBER:=1.0;

BEGIN
-- Standard Start of API savepoint
SAVEPOINT		Get_EmailAccount_List_PUB;
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
   IF p_resource_id is not null then
	FOR c_email_rec in email_details_csr
	LOOP
   --	x_Email_Acnt_tbl(l_email_index).server_id:=c_email_rec.mail_server_id;
  		x_Email_Acnt_tbl(l_email_index).account_name:=c_email_rec.from_name;
  		x_Email_Acnt_tbl(l_email_index).db_user:=c_email_rec.user_name;
   	--	x_Email_Acnt_tbl(l_email_index).domain:=c_email_rec.user_domain;
   	--	x_Email_Acnt_tbl(l_email_index).account_password:=c_email_rec.user_password;
		 	x_Email_Acnt_tbl(l_email_index).account_id:=c_email_rec.email_account_id;

		l_email_index:=l_email_index+1;

	END LOOP;
    ELSE
	FOR c_email_rec in email_details_no_resource_csr
	LOOP
-- 		x_Email_Acnt_tbl(l_email_index).server_id:=c_email_rec.mail_server_id;
  		x_Email_Acnt_tbl(l_email_index).account_name:=c_email_rec.from_name;
  		x_Email_Acnt_tbl(l_email_index).db_user:=c_email_rec.user_name;
  --		x_Email_Acnt_tbl(l_email_index).domain:=c_email_rec.user_domain;
  --		x_Email_Acnt_tbl(l_email_index).account_password:=c_email_rec.user_password;
	     x_Email_Acnt_tbl(l_email_index).account_id:=c_email_rec.email_account_id;

		l_email_index:=l_email_index+1;

	END LOOP;
    END IF;
-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;
-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>      x_msg_count,
                 p_data  =>      x_msg_data
			);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO Get_EmailAccount_List_PUB;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count =>      x_msg_count,
                 p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO Get_EmailAccount_List_PUB;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count =>      x_msg_count,
                 p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO Get_EmailAccount_List_PUB;
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

 END	Get_EmailAccount_List;

 Procedure getEmailHeaders(
                           p_AgentName   IN VARCHAR2,
                           p_top_n       IN INTEGER default 0,
                           p_top_option  IN INTEGER default 1,
                           p_folder_path IN VARCHAR2 default 'ALL',
                           message_headers OUT NOCOPY msg_header_table
                                         ) is
begin
   null;
  end getEmailHeaders;

PROCEDURE ListAgentAccounts (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			      p_RESOURCE_ID  IN NUMBER,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2,
 			      x_Agent_Acnt_tbl  OUT NOCOPY  AGENTACNT_tbl_type
			 ) is
CURSOR agent_accounts_csr IS

      SELECT      nvl(nvl(b.reply_to_address,b.return_address),b.email_address) reply_to_address,
             a.signature,
             a.agent_id,
        	   a.email_account_id
   FROM      IEM_AGENTS A,
             IEM_MSTEMAIL_ACCOUNTS B
   WHERE     (A.resource_id=p_RESOURCE_ID)
   AND       (A.email_account_id=B.EMAIL_ACCOUNT_ID)
   ORDER BY a.agent_id;

	l_email_index	number:=1;

	l_api_name        		VARCHAR2(255):='ListAgentAccounts';
	l_api_version_number 	NUMBER:=1.0;
	l_user_name		varchar2(500);
	l_res_name		varchar2(1000);
	l_flag			number;

BEGIN
-- Standard Start of API savepoint
SAVEPOINT		ListAgentAccounts_PUB;
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
   IF p_resource_id is not null then
	FOR agent_account_rec in agent_accounts_csr
	LOOP
	SELECT  USER_NAME, SOURCE_LAST_NAME || ', ' || SOURCE_FIRST_NAME as RESOURCE_NAME
          INTO  l_user_name, l_res_name
          FROM JTF_RS_RESOURCE_EXTNS
          WHERE RESOURCE_ID = p_resource_id;
	select sender_flag into l_flag from iem_mstemail_accounts
	where email_account_id= agent_account_rec.email_account_id;
	IF l_flag=0 then			-- From Name selected from Account.
		select from_name into l_res_name
		from iem_mstemail_accounts
		where email_account_id= agent_account_rec.email_account_id;
	END IF;
  	x_Agent_Acnt_tbl(l_email_index).account_name:=l_user_name;
  	x_Agent_Acnt_tbl(l_email_index).reply_to_address:=agent_account_rec.reply_to_address;
  	x_Agent_Acnt_tbl(l_email_index).from_address:=agent_account_rec.reply_to_address;
  	x_Agent_Acnt_tbl(l_email_index).from_name:=l_res_name;
  	x_Agent_Acnt_tbl(l_email_index).user_name:=l_user_name;
  	x_Agent_Acnt_tbl(l_email_index).signature:=agent_account_rec.signature;
   	x_Agent_Acnt_tbl(l_email_index).email_account_id:=agent_account_rec.email_account_id;
	x_Agent_Acnt_tbl(l_email_index).agent_account_id:=agent_account_rec.agent_id;

	l_email_index:=l_email_index+1;

	END LOOP;
    END IF;
-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;
-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>      x_msg_count,
                 p_data  =>      x_msg_data
			);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO ListAgentAccounts_PUB;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count =>      x_msg_count,
                 p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO ListAgentAccounts_PUB;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count =>      x_msg_count,
                 p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO ListAgentAccounts_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);

 END	ListAgentAccounts;
-- 12.1.2 Development. Bug 8829918
PROCEDURE ListAgentCPAccounts (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			      p_RESOURCE_ID  IN NUMBER,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2,
 			      x_Agent_Acnt_tbl  OUT NOCOPY  AGENTACNT_tbl_type
			 ) is
CURSOR agent_accounts_csr IS

      SELECT      nvl(nvl(b.reply_to_address,b.return_address),b.email_address) reply_to_address,
             a.signature,
             a.agent_id,
        	   a.email_account_id
   FROM      IEM_AGENTS A,
             IEM_MSTEMAIL_ACCOUNTS B
   WHERE     (A.resource_id=p_RESOURCE_ID)
   AND       (A.email_account_id=B.EMAIL_ACCOUNT_ID)
   AND        A.cherry_pick_flag = 'Y'
   ORDER BY a.agent_id;

	l_email_index	number:=1;

	l_api_name        		VARCHAR2(255):='ListAgentCPAccounts';
	l_api_version_number 	NUMBER:=1.0;
	l_user_name		varchar2(500);
	l_res_name		varchar2(1000);
	l_flag			number;

BEGIN
-- Standard Start of API savepoint
SAVEPOINT		ListAgentCPAccounts_PUB;
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
   IF p_resource_id is not null then
	FOR agent_account_rec in agent_accounts_csr
	LOOP
	SELECT  USER_NAME, SOURCE_LAST_NAME || ', ' || SOURCE_FIRST_NAME as RESOURCE_NAME
          INTO  l_user_name, l_res_name
          FROM JTF_RS_RESOURCE_EXTNS
          WHERE RESOURCE_ID = p_resource_id;
	select sender_flag into l_flag from iem_mstemail_accounts
	where email_account_id= agent_account_rec.email_account_id;
	IF l_flag=0 then			-- From Name selected from Account.
		select from_name into l_res_name
		from iem_mstemail_accounts
		where email_account_id= agent_account_rec.email_account_id;
	END IF;
  	x_Agent_Acnt_tbl(l_email_index).account_name:=l_user_name;
  	x_Agent_Acnt_tbl(l_email_index).reply_to_address:=agent_account_rec.reply_to_address;
  	x_Agent_Acnt_tbl(l_email_index).from_address:=agent_account_rec.reply_to_address;
  	x_Agent_Acnt_tbl(l_email_index).from_name:=l_res_name;
  	x_Agent_Acnt_tbl(l_email_index).user_name:=l_user_name;
  	x_Agent_Acnt_tbl(l_email_index).signature:=agent_account_rec.signature;
   	x_Agent_Acnt_tbl(l_email_index).email_account_id:=agent_account_rec.email_account_id;
	x_Agent_Acnt_tbl(l_email_index).agent_account_id:=agent_account_rec.agent_id;

	l_email_index:=l_email_index+1;

	END LOOP;
    END IF;
-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;
-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>      x_msg_count,
                 p_data  =>      x_msg_data
			);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO ListAgentCPAccounts_PUB;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count =>      x_msg_count,
                 p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO ListAgentCPAccounts_PUB;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count =>      x_msg_count,
                 p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO ListAgentCPAccounts_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);

 END	ListAgentCPAccounts;
-- 12.1.2 Development. Bug 8829918

PROCEDURE ListAgentAccountDetails (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	      p_commit	    IN   VARCHAR2 := FND_API.G_FALSE,
			      p_EMAIL_ACCOUNT_ID  IN NUMBER,
				 p_ROLEid     		IN NUMBER:=-1,
				 p_Resource_id     		IN NUMBER:=-1,
				 p_search_criteria IN VARCHAR2:=null,
				 p_display_size     in NUMBER:=null,
				 p_page_count  	in NUMBER:=null,
				 p_sort_by     	in VARCHAR2:='F',
				 p_sort_order     	in NUMBER:=1,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
  		  	      x_search_count	 OUT NOCOPY    NUMBER,
	  	  	      x_msg_data		 OUT NOCOPY VARCHAR2,
 			      x_Agent_Acnt_Dtl_data  OUT NOCOPY  AGNTACNTDETAILS_tbl_type
			 ) is

	l_api_name        		VARCHAR2(255):='ListAgentAccountDetails';
	l_api_version_number 	NUMBER:=1.0;
	Type get_data is REF CURSOR;-- RETURN Agent_Acnt_Dtl_tbl;
	email_cur      get_data;
	l_counter      number:=0;
	l_order_by          varchar2(255);
	l_order          varchar2(255);
	l_where             varchar2(1000);
	l_stmt             varchar2(600);
	l_temp_tbl          AGNTACNTDETAILS_tbl_type;
--	l_start_index       number:=0;
	l_first_index       number:=0;
	l_last_index             number:=0;
	l_roleid 		NUMBER:= 0;
	l_string		varchar2(32767):='';
	l_resource_id	number;
	l_resource_name	varchar2(360);
	l_user_name	varchar2(256);
	l_responsibility_name varchar2(100);
	l_last_login_time varchar2(256);
	l_cursorID INTEGER;
   	l_dummy INTEGER;
	l_role_Str		varchar2(1000);

BEGIN
-- Standard Start of API savepoint
SAVEPOINT		ListAgentAccountDetails_PUB;
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
						     p_api_version_number,
						     l_api_name,
							G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
SAVEPOINT ListAgentAccountDetails_pvt;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_where:=' AND agnt.email_account_id= :email_account_id';
   IF p_search_criteria is not null THEN
   	l_where:= l_where||' and (upper(res.source_last_name) like upper(:search_criteria) or upper(res.source_first_name) like upper(:search_criteria) or upper(res.user_name) like upper(:search_criteria)) ';
   END IF;
   IF p_roleid <> -1 THEN

   	if p_roleid = 2 then
		l_role_str:='resp.responsibility_key = ''EMAIL_CENTER_SUPERVISOR''' ;
   	else
		l_role_str:='resp.responsibility_key = ''IEM_SA_AGENT''' ;
   	end if;
	l_where:= l_where||' and resp.application_id=680 and '||l_role_str;
   ELSE
	l_where:= l_where||' and resp.responsibility_key in (''EMAIL_CENTER_SUPERVISOR'', ''IEM_SA_AGENT'' ) and (res.user_id,respgrp.responsibility_id)
			IN (select respgrp.user_id,max(respgrp.responsibility_id)
				from fnd_user_resp_groups respgrp,fnd_responsibility resp
				where respgrp.responsibility_id=resp.responsibility_id
				and resp.application_id=680 and (resp.responsibility_key =''EMAIL_CENTER_SUPERVISOR'' or resp.responsibility_key=''IEM_SA_AGENT'')
				group by respgrp.user_id) ';
   END IF;
   IF p_resource_id <> -1 THEN
	l_where:= l_where||' and agnt.resource_id<> :resource_id';
   END IF;

   IF p_sort_order=1 THEN
	l_order:=' ASC';
   ELSE
	l_order:=' DESC';
   END IF;
   IF p_sort_by = 'F' THEN
	l_order_by:=' Order BY res.source_last_name '||l_order || ', res.source_first_name '||l_order;
   ELSIF p_sort_by='U' THEN
	l_order_by:=' ORDER BY res.user_name '||l_order;
   ELSIF p_sort_by='R' THEN
	l_order_by:=' ORDER BY resp.responsibility_name '||l_order;
   END IF;

l_string := 'select agnt.resource_id, concat(concat(res.source_last_name, '', ''), res.source_first_name) as resource_name, res.user_name,
	resptl.responsibility_name
   from iem_agents agnt, fnd_responsibility resp,fnd_user_resp_groups respgrp,
	jtf_rs_resource_extns res, fnd_user fu,fnd_responsibility_tl resptl
   where agnt.resource_id=res.resource_id and res.user_id=respgrp.user_id
	and resp.application_id=680
	and resp.responsibility_id=respgrp.responsibility_id
	and respgrp.user_id=fu.user_id
	and resptl.application_id=680
	and resptl.responsibility_id=resp.responsibility_id
	and resptl.LANGUAGE = USERENV (''LANG'')
	 and trunc(sysdate) between trunc(nvl(respgrp.start_date, sysdate))
    	and trunc(nvl(respgrp.end_date, sysdate))
    	 and trunc(sysdate) between trunc(nvl(fu.start_date, sysdate))
    	and trunc(nvl(fu.end_date, sysdate))
    	and trunc(sysdate) between trunc(nvl(res.start_date_active, sysdate))
      	and trunc(nvl(res.end_date_active, sysdate))
      	and res.resource_id in ( select unique rel.role_resource_id from jtf_rs_role_relations rel where
       rel.role_id in (28, 29, 30) and rel.delete_flag = ''N''
        and rel.role_resource_type = ''RS_INDIVIDUAL''
          and trunc(sysdate) between trunc(nvl(rel.start_date_active, sysdate))
      	and trunc(nvl(rel.end_date_active, sysdate)) ) ';
	l_string := l_string ||l_where||l_order_by;
	l_cursorID := DBMS_SQL.OPEN_CURSOR;
	DBMS_SQL.PARSE(l_cursorID, l_string, DBMS_SQL.native);

	IF p_search_criteria is not null THEN
		DBMS_SQL.BIND_VARIABLE(l_cursorID, ':search_criteria', p_search_criteria);
	end if;
	/*
	IF p_roleid <> -1 THEN
		DBMS_SQL.BIND_VARIABLE(l_cursorID, ':roleid', l_roleid);
	END IF;
	*/
	IF p_resource_id <> -1 THEN
		DBMS_SQL.BIND_VARIABLE(l_cursorID, ':resource_id', p_resource_id);
	END IF;

	DBMS_SQL.BIND_VARIABLE(l_cursorID, ':email_account_id', p_email_account_id);

	DBMS_SQL.DEFINE_COLUMN(l_cursorID, 1, l_resource_id);
	DBMS_SQL.DEFINE_COLUMN(l_cursorID, 2, l_resource_name, 360);
	DBMS_SQL.DEFINE_COLUMN(l_cursorID, 3, l_user_name, 256);
	DBMS_SQL.DEFINE_COLUMN(l_cursorID, 4, l_responsibility_name, 100);

	l_dummy := DBMS_SQL.EXECUTE(l_cursorID);
	l_temp_tbl.delete;
   	l_counter:=1;

LOOP
    IF (DBMS_SQL.FETCH_ROWS(l_cursorID) = 0) THEN
        EXIT;
     END IF;

     DBMS_SQL.COLUMN_VALUE(l_cursorID, 1, l_resource_id);
     DBMS_SQL.COLUMN_VALUE(l_cursorID, 2, l_resource_name);
     DBMS_SQL.COLUMN_VALUE(l_cursorID, 3, l_user_name);
     DBMS_SQL.COLUMN_VALUE(l_cursorID, 4, l_responsibility_name);

     select to_char(max(begin_date_time), 'MM/DD/RRRR HH24:MI:SS') into l_last_login_time
	 	    from ieu_sh_sessions where application_id=680 and resource_id=l_resource_id;

	l_temp_tbl(l_counter).resource_id := l_resource_id;
	l_temp_tbl(l_counter).resource_name := l_resource_name;
	l_temp_tbl(l_counter).user_name := l_user_name;
	l_temp_tbl(l_counter).role := l_responsibility_name;
	l_temp_tbl(l_counter).last_login_time := l_last_login_time;

	l_counter:=l_counter+1;

END LOOP;

DBMS_SQL.CLOSE_CURSOR(l_cursorID);

   x_search_count:=0;
   x_search_count:=l_temp_tbl.count;
   IF l_temp_tbl.count>0  THEN
	--x_total_message:=l_temp_tbl.count;
	IF p_display_size is null THEN
		x_Agent_Acnt_Dtl_data:=l_temp_tbl;
     ELSE
		IF p_page_count is not null THEN
			l_first_index:=p_page_count*p_display_size - p_display_size+1;
			l_last_index:=p_page_count*p_display_size;
		ELSIF p_page_count is null THEN
			l_first_index:=1;
			l_last_index:=p_display_size;
		END IF;
		IF l_last_index>x_search_count THEN
		  l_last_index:=x_search_count;
		END IF;
		FOR l_index in l_first_index..l_last_index LOOP
			x_Agent_Acnt_Dtl_data(l_index):=l_temp_tbl(l_index);
		END LOOP;
	END IF;
   END IF;

-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;
-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>      x_msg_count,
                 p_data  =>      x_msg_data
			);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO ListAgentAccountDetails_PUB;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count =>      x_msg_count,
                 p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO ListAgentAccountDetails_PUB;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count =>      x_msg_count,
                 p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO ListAgentAccountDetails_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);

 END	ListAgentAccountDetails;

PROCEDURE ListAccountDetails (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  	 IN   VARCHAR2 := FND_API.G_FALSE,
		    	      p_commit	    		 IN   VARCHAR2 := FND_API.G_FALSE,
			      p_EMAIL_ACCOUNT_ID	 IN NUMBER :=null,
			      x_return_status	 OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data		 OUT NOCOPY VARCHAR2,
 			      x_Acnt_Details_tbl  OUT NOCOPY  ACNTDETAILS_tbl_type
			 ) is
CURSOR account_details_csr IS

   SELECT    from_name,
             user_name,
		   email_address,
      	   nvl(nvl(reply_to_address,return_address),email_address) reply_to_address,
             email_account_id,
		   out_host,
		   out_port,
		   template_category
   FROM      IEM_MSTEMAIL_ACCOUNTS
   WHERE     email_account_id=p_EMAIL_ACCOUNT_ID;

	l_email_index	number:=1;

	l_api_name        		VARCHAR2(255):='ListAccountDetails';
	l_api_version_number 	NUMBER:=1.0;

BEGIN
-- Standard Start of API savepoint
SAVEPOINT		ListAccountDetails_PUB;
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
   IF p_email_account_id is not null then
	FOR account_det_rec in account_details_csr
	LOOP
  	x_Acnt_Details_tbl(l_email_index).account_name:=account_det_rec.from_name;
  	x_Acnt_Details_tbl(l_email_index).email_user:=account_det_rec.user_name;
  	x_Acnt_Details_tbl(l_email_index).email_address:=account_det_rec.email_address;
  	x_Acnt_Details_tbl(l_email_index).reply_to_address:=account_det_rec.reply_to_address;
  	x_Acnt_Details_tbl(l_email_index).from_name:=account_det_rec.from_name;
   	x_Acnt_Details_tbl(l_email_index).email_account_id:=account_det_rec.email_account_id;
   	x_Acnt_Details_tbl(l_email_index).smtp_server:=account_det_rec.out_host;
   	x_Acnt_Details_tbl(l_email_index).port:=account_det_rec.out_port;
   	x_Acnt_Details_tbl(l_email_index).template_category_id:=account_det_rec.template_category;
	l_email_index:=l_email_index+1;

	END LOOP;
    END IF;
-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;
-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>      x_msg_count,
                 p_data  =>      x_msg_data
			);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO ListAccountDetails_PUB;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count =>      x_msg_count,
                 p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO ListAccountDetails_PUB;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count =>      x_msg_count,
                 p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO ListAccountDetails_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);

 END	ListAccountDetails;
END IEM_EMAILACCOUNT_PUB ;

/
