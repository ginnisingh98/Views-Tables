--------------------------------------------------------
--  DDL for Package Body IEM_SPV_MONITORING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_SPV_MONITORING_PVT" as
/* $Header: iemvspmb.pls 120.3 2006/05/01 15:20:14 chtang ship $*/
G_PKG_NAME		varchar2(100):='IEM_SPV_MONITORING_PVT';

 PROCEDURE get_email_activity (p_api_version_number    	IN   	NUMBER,
 		  	      p_init_msg_list  		IN   	VARCHAR2,
		    	      p_commit	    		IN   	VARCHAR2,
			      x_email_activity_tbl 	OUT 	NOCOPY email_activity_tbl,
			      x_return_status		OUT	NOCOPY VARCHAR2,
  		  	      x_msg_count	      	OUT	NOCOPY NUMBER,
	  	  	      x_msg_data		OUT	NOCOPY VARCHAR2) IS

l_api_name        	VARCHAR2(255):='get_email_activity';
l_api_version_number 	NUMBER:=1.0;
l_index		number := 1;
l_monitor_index number := 1;
i		number := 1;
l_agent_acct_count number;
l_count		number;
l_queue_count   number;
l_queue_wait_time     number;
l_queue_average_time  number;
l_inbox_count   number;
l_inbox_wait_time     number;
l_inbox_average_time  number;
l_total_count   number;
l_string		varchar2(32767):='';
Type email_activity_rec is REF CURSOR ;
email_activity_cur		email_activity_rec;

l_email_account_id_tbl  jtf_number_table:=jtf_number_table() ;
l_account_name_tbl  jtf_varchar2_table_100:=jtf_varchar2_table_100() ;
l_queue_count_tbl  jtf_number_table:=jtf_number_table() ;
l_wait_time_tbl  jtf_number_table:=jtf_number_table() ;
l_class_id_tbl  jtf_number_table:=jtf_number_table() ;
l_class_name_tbl  jtf_varchar2_table_100:=jtf_varchar2_table_100() ;

l_current_user    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;

BEGIN

	SAVEPOINT get_email_activity_pvt;
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

	select a.email_account_id, a.from_name bulk collect into l_email_account_id_tbl, l_account_name_tbl
	from iem_mstemail_accounts a, iem_agents b, jtf_rs_resource_extns c
 	where a.email_account_id=b.email_account_id and b.resource_id =  c.resource_id and c.user_id = l_current_user
 	order by UPPER(a.from_name);


	for l_index in l_email_account_id_tbl.FIRST..l_email_account_id_tbl.LAST LOOP
		-- Queue statistics
		select Count(*) Total, nvl(max(sysdate-a.received_date)*24*60,0) wait_time,
		nvl(avg(sysdate-a.received_date)*24*60,0) average_time
		into l_queue_count, l_queue_wait_time, l_queue_average_time
 		FROM iem_rt_proc_emails a
		WHERE a.resource_id = 0 and
		a.email_account_id=l_email_account_id_tbl(l_index);

		--Agent Inbox statistics
		select Count(*) Total, nvl(max(sysdate-a.received_date)*24*60,0) wait_time,
		nvl(avg(sysdate-a.received_date)*24*60,0) average_time
		into l_inbox_count, l_inbox_wait_time, l_inbox_average_time
 		FROM iem_rt_proc_emails a, iem_rt_media_items b
		WHERE a.resource_id <> 0 and a.message_id=b.message_id and b.expire='N' and
		a.email_account_id=l_email_account_id_tbl(l_index);

		select count(*) into l_agent_acct_count from iem_agents where email_account_id=l_email_account_id_tbl(l_index);

		select count(*) into l_total_count from iem_rt_proc_emails where email_account_id=l_email_account_id_tbl(l_index);

		x_email_activity_tbl(l_monitor_index).email_account_id:=l_email_account_id_tbl(l_index);
		x_email_activity_tbl(l_monitor_index).account_classification_name:=l_account_name_tbl(l_index);
		x_email_activity_tbl(l_monitor_index).classification_id:=-1;  -- All Classifications
		x_email_activity_tbl(l_monitor_index).queue_count:=l_queue_count;
		x_email_activity_tbl(l_monitor_index).queue_wait_time:=l_queue_wait_time;
		x_email_activity_tbl(l_monitor_index).queue_average_time:=l_queue_average_time;
		x_email_activity_tbl(l_monitor_index).inbox_count:=l_inbox_count;
		x_email_activity_tbl(l_monitor_index).inbox_wait_time:=l_inbox_wait_time;
		x_email_activity_tbl(l_monitor_index).inbox_average_time:=l_inbox_average_time;
		x_email_activity_tbl(l_monitor_index).agent_count:=l_agent_acct_count;
		x_email_activity_tbl(l_monitor_index).total_count:=l_total_count;

		if (l_queue_count = 0) then
			x_email_activity_tbl(l_monitor_index).queue_zero_flag:='true';
		else
			x_email_activity_tbl(l_monitor_index).queue_zero_flag:='false';
		end if;
		if (l_inbox_count = 0) then
			x_email_activity_tbl(l_monitor_index).inbox_zero_flag:='true';
		else
			x_email_activity_tbl(l_monitor_index).inbox_zero_flag:='false';
		end if;

		l_monitor_index := l_monitor_index + 1;

		select a.route_classification_id, a.name bulk collect into l_class_id_tbl, l_class_name_tbl
		from iem_route_classifications a, iem_account_route_class b
		where a.route_classification_id = b.route_classification_id and b.email_account_id=l_email_account_id_tbl(l_index) order by UPPER(a.name);

		for i in l_class_id_tbl.FIRST..l_class_id_tbl.LAST LOOP
			-- Queue statistics
			select Count(*) Total, nvl(max(sysdate-a.received_date)*24*60,0) wait_time,
			nvl(avg(sysdate-a.received_date)*24*60,0) average_time
 			into l_queue_count, l_queue_wait_time, l_queue_average_time
 			FROM iem_rt_proc_emails a,iem_mstemail_accounts b, iem_route_classifications c
			WHERE a.email_account_id=b.email_account_id and a.rt_classification_id=c.route_classification_id
    			and a.resource_id=0 and a.email_account_id=l_email_account_id_tbl(l_index) and c.route_classification_id=l_class_id_tbl(i);

    			-- Agent Inbox statistics
    			select Count(*) Total, nvl(max(sysdate-a.received_date)*24*60,0) wait_time,
			nvl(avg(sysdate-a.received_date)*24*60,0) average_time
 			into l_inbox_count, l_inbox_wait_time, l_inbox_average_time
 			FROM iem_rt_proc_emails a,iem_mstemail_accounts b, iem_route_classifications c, iem_rt_media_items d
			WHERE a.email_account_id=b.email_account_id and a.rt_classification_id=c.route_classification_id
    			and a.resource_id<>0 and a.message_id=d.message_id and d.expire='N'
    			and a.email_account_id=l_email_account_id_tbl(l_index) and c.route_classification_id=l_class_id_tbl(i);

    			select count(*) into l_total_count from iem_rt_proc_emails where email_account_id=l_email_account_id_tbl(l_index)
    			and rt_classification_id=l_class_id_tbl(i);

    			x_email_activity_tbl(l_monitor_index).email_account_id:=l_email_account_id_tbl(l_index);
			x_email_activity_tbl(l_monitor_index).account_classification_name:=l_class_name_tbl(i);
			x_email_activity_tbl(l_monitor_index).classification_id:=l_class_id_tbl(i);
			x_email_activity_tbl(l_monitor_index).queue_count:=l_queue_count;
			x_email_activity_tbl(l_monitor_index).queue_wait_time:=l_queue_wait_time;
			x_email_activity_tbl(l_monitor_index).queue_average_time:=l_queue_average_time;
			x_email_activity_tbl(l_monitor_index).inbox_count:=l_inbox_count;
			x_email_activity_tbl(l_monitor_index).inbox_wait_time:=l_inbox_wait_time;
			x_email_activity_tbl(l_monitor_index).inbox_average_time:=l_inbox_average_time;
			x_email_activity_tbl(l_monitor_index).agent_count:=-1;  -- No Agent Count per classification
			x_email_activity_tbl(l_monitor_index).total_count:=l_total_count;

			if (l_queue_count = 0) then
				x_email_activity_tbl(l_monitor_index).queue_zero_flag:='true';
			else
				x_email_activity_tbl(l_monitor_index).queue_zero_flag:='false';
			end if;
			if (l_inbox_count = 0) then
				x_email_activity_tbl(l_monitor_index).inbox_zero_flag:='true';
			else
				x_email_activity_tbl(l_monitor_index).inbox_zero_flag:='false';
			end if;

			l_monitor_index := l_monitor_index + 1;
		end loop;
    	end loop;

-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;
-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 	p_data  =>    x_msg_data
			);
EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO get_email_activity_pvt;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO get_email_activity_pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO get_email_activity_pvt;
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
    		(p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data
    		);
END get_email_activity;

PROCEDURE get_agent_activity (p_api_version_number    	IN   	NUMBER,
 		  	      p_init_msg_list  		IN   	VARCHAR2,
		    	      p_commit	    		IN   	VARCHAR2,
		    	      p_resource_role		IN	NUMBER:=1,
		    	      p_resource_name		IN	VARCHAR2:=null,
			      x_agent_activity_tbl 	OUT 	NOCOPY agent_activity_tbl,
			      x_return_status		OUT	NOCOPY VARCHAR2,
  		  	      x_msg_count	      	OUT	NOCOPY NUMBER,
	  	  	      x_msg_data		OUT	NOCOPY VARCHAR2) IS

l_api_name        	VARCHAR2(255):='get_agent_activity';
l_api_version_number 	NUMBER:=1.0;
l_index		number := 1;
l_monitor_index number := 1;
i		number := 1;
l_agent_acct_count number;
l_count		number;
l_email_count   number;
l_assigned_email_count number;
l_requeue_all_count number;
l_wait_time     number;
l_average_time	number;
l_total_count   number;
l_last_login_time varchar2(500);
l_resource_role	varchar2(30);
l_email_count_flag number;
l_string		varchar2(32767):='';
l_where_clause		varchar2(32767):='';
Type agent_activity_rec is REF CURSOR ;
agent_activity_cur		agent_activity_rec;

l_resource_id_tbl  jtf_number_table:=jtf_number_table() ;
l_resource_name_tbl  jtf_varchar2_table_100:=jtf_varchar2_table_100() ;
l_email_count_tbl  jtf_number_table:=jtf_number_table() ;
l_average_age_tbl  jtf_number_table:=jtf_number_table() ;
l_oldest_age_tbl  jtf_number_table:=jtf_number_table() ;
l_account_id_tbl  jtf_number_table:=jtf_number_table() ;
l_account_name_tbl  jtf_varchar2_table_100:=jtf_varchar2_table_100() ;

l_current_user    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;

BEGIN

	SAVEPOINT get_email_activity_pvt;
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

   	if p_resource_role = 0 then -- All Agents
   		if (p_resource_name is not null) then
			select unique res.resource_id,concat(concat(res.source_last_name, ', '), res.source_first_name) as resource_name
   			bulk collect into l_resource_id_tbl, l_resource_name_tbl from fnd_user_resp_groups respgrp,
			jtf_rs_resource_extns res, fnd_responsibility resp where res.user_id=respgrp.user_id
			and respgrp.responsibility_id=resp.responsibility_id and resp.application_id=680
			and (resp.responsibility_key = 'EMAIL_CENTER_SUPERVISOR' or resp.responsibility_key = 'IEM_SA_AGENT')
 			and res.resource_id in ( select unique rel.role_resource_id from jtf_rs_role_relations rel where
           		rel.role_id in (28, 29, 30) and rel.delete_flag = 'N'
            		and rel.role_resource_type = 'RS_INDIVIDUAL'
            	--	and trunc(sysdate) between trunc(nvl(rel.start_date_active, sysdate))
      	     	--	and trunc(nvl(rel.end_date_active, sysdate))
			)
 			and res.resource_id in (select resource_id from iem_agents)
   			and (upper(res.source_last_name) like upper(p_resource_name) or upper(res.source_first_name) like upper(p_resource_name)
			or upper(res.user_name) like upper(p_resource_name))
   			order by resource_name;
   		else
   			select unique res.resource_id,concat(concat(res.source_last_name, ', '), res.source_first_name) as resource_name
   			bulk collect into l_resource_id_tbl, l_resource_name_tbl from fnd_user_resp_groups respgrp,
			jtf_rs_resource_extns res, fnd_responsibility resp where res.user_id=respgrp.user_id
 			and respgrp.responsibility_id=resp.responsibility_id and resp.application_id=680
 			and (resp.responsibility_key = 'EMAIL_CENTER_SUPERVISOR' or resp.responsibility_key = 'IEM_SA_AGENT')
 			and res.resource_id in ( select unique rel.role_resource_id from jtf_rs_role_relations rel where
            		rel.role_id in (28, 29, 30) and rel.delete_flag = 'N'
            		and rel.role_resource_type = 'RS_INDIVIDUAL'
            	--	and trunc(sysdate) between trunc(nvl(rel.start_date_active, sysdate))
      	     	--	and trunc(nvl(rel.end_date_active, sysdate))
			)
 			and res.resource_id in (select resource_id from iem_agents)
 			order by resource_name;
   		end if;
   	else
   	/*	if p_resource_role = 2 then
   			l_resource_role := 23720;	-- Supervisor
   		else
   			l_resource_role := 23107;	-- Agent
   		end if;
   	*/
   		if p_resource_role = 2 then
   			l_resource_role := 'EMAIL_CENTER_SUPERVISOR';	-- Supervisor
   		else
   			l_resource_role := 'IEM_SA_AGENT';	-- Agent
   		end if;

   		if (p_resource_name is not null) then
			select res.resource_id,concat(concat(res.source_last_name, ', '), res.source_first_name) as resource_name
   			bulk collect into l_resource_id_tbl, l_resource_name_tbl from fnd_user_resp_groups respgrp,
			jtf_rs_resource_extns res, fnd_responsibility resp where res.user_id=respgrp.user_id
			and respgrp.responsibility_id=resp.responsibility_id and resp.application_id=680
 			and resp.responsibility_key = l_resource_role
 			and res.resource_id in ( select unique rel.role_resource_id from jtf_rs_role_relations rel where
            		rel.role_id in (28, 29, 30) and rel.delete_flag = 'N'
            		and rel.role_resource_type = 'RS_INDIVIDUAL'
            		and trunc(sysdate) between trunc(nvl(rel.start_date_active, sysdate))
         		and trunc(nvl(rel.end_date_active, sysdate)) )
 			and res.resource_id in (select resource_id from iem_agents)
   			and (upper(res.source_last_name) like upper(p_resource_name) or upper(res.source_first_name) like upper(p_resource_name)
			or upper(res.user_name) like upper(p_resource_name))
   			order by resource_name;
   		else
   			select res.resource_id,concat(concat(res.source_last_name, ', '), res.source_first_name) as resource_name
   			bulk collect into l_resource_id_tbl, l_resource_name_tbl from fnd_user_resp_groups respgrp,
			jtf_rs_resource_extns res, fnd_responsibility resp where res.user_id=respgrp.user_id
			and respgrp.responsibility_id=resp.responsibility_id and resp.application_id=680
 			and resp.responsibility_key = l_resource_role
 			and res.resource_id in ( select unique rel.role_resource_id from jtf_rs_role_relations rel where
            		rel.role_id in (28, 29, 30) and rel.delete_flag = 'N'
            		and rel.role_resource_type = 'RS_INDIVIDUAL'
            		and trunc(sysdate) between trunc(nvl(rel.start_date_active, sysdate))
         		and trunc(nvl(rel.end_date_active, sysdate)) )
 			and res.resource_id in (select resource_id from iem_agents)
 			order by resource_name;
   		end if;
   	end if; -- if p_resource_role = 0

	for l_index in l_resource_id_tbl.FIRST..l_resource_id_tbl.LAST LOOP
		select Count(*) Total, nvl(max(sysdate-a.received_date)*24*60,0) wait_time,
 		nvl(avg(sysdate-a.received_date)*24*60,0) average_time
 		into l_email_count, l_wait_time, l_average_time
 		FROM iem_rt_proc_emails a, iem_rt_media_items b
		WHERE a.message_id=b.message_id and b.expire='N'
		and a.resource_id = l_resource_id_tbl(l_index);

		select Count(*) Total into l_assigned_email_count
 		FROM iem_rt_proc_emails a, iem_rt_media_items b
		WHERE a.message_id=b.message_id and b.expire='N'
		and a.resource_id = l_resource_id_tbl(l_index) and a.email_account_id in
  		(select a.email_account_id from iem_agents a, jtf_rs_resource_extns b
  		where a.resource_id = b.resource_id and b.user_id=l_current_user);

  		select Count(*) Total into l_requeue_all_count
 		FROM iem_rt_proc_emails a, iem_rt_media_items b
		WHERE a.message_id=b.message_id and b.expire='N'
		and a.resource_id =  l_resource_id_tbl(l_index) and a.email_account_id in
 		(select email_account_id from iem_agents c, jtf_rs_resource_extns d
  		where c.resource_id=d.resource_id and d.user_id=l_current_user);

		select count(*) into l_agent_acct_count from iem_agents where resource_id=l_resource_id_tbl(l_index);

		select to_char(max(begin_date_time), 'MM/DD/RRRR HH24:MI:SS') into l_last_login_time
	 	from ieu_sh_sessions where application_id=680 and resource_id=l_resource_id_tbl(l_index);

		x_agent_activity_tbl(l_monitor_index).resource_id:=l_resource_id_tbl(l_index);
		x_agent_activity_tbl(l_monitor_index).resource_account_name:=l_resource_name_tbl(l_index);
		x_agent_activity_tbl(l_monitor_index).email_account_id:=-1;  -- All Accounts
		x_agent_activity_tbl(l_monitor_index).email_count:=l_email_count;
		x_agent_activity_tbl(l_monitor_index).assigned_email_count:=l_assigned_email_count;
		x_agent_activity_tbl(l_monitor_index).oldest_age:=l_wait_time;
		x_agent_activity_tbl(l_monitor_index).average_age:=l_average_time;
		x_agent_activity_tbl(l_monitor_index).account_count:=l_agent_acct_count;
		x_agent_activity_tbl(l_monitor_index).last_login_time:=l_last_login_time;

		if (l_requeue_all_count = 0) then
			x_agent_activity_tbl(l_monitor_index).requeue_all_flag:='false';
		else
			x_agent_activity_tbl(l_monitor_index).requeue_all_flag:='true';
		end if;

		l_monitor_index := l_monitor_index + 1;

		select a.email_account_id, a.from_name  bulk collect into l_account_id_tbl, l_account_name_tbl
		from iem_mstemail_accounts a, iem_agents b
		where a.email_account_id=b.email_account_id and b.resource_id=l_resource_id_tbl(l_index)
		order by UPPER(a.from_name);

		for i in l_account_id_tbl.FIRST..l_account_id_tbl.LAST LOOP
			select Count(*) Total, nvl(max(sysdate-a.received_date)*24*60,0) wait_time,
 			nvl(avg(sysdate-a.received_date)*24*60,0) average_time
 			into l_email_count, l_wait_time, l_average_time
 			FROM iem_rt_proc_emails a, iem_rt_media_items b
			WHERE a.message_id=b.message_id and b.expire='N'
			and a.resource_id = l_resource_id_tbl(l_index)
			and a.email_account_id=l_account_id_tbl(i);

			select count(*) into l_email_count_flag from iem_agents a, jtf_rs_resource_extns b
			where a.email_account_id=l_account_id_tbl(i)
			and a.resource_id = b.resource_id and b.user_id=l_current_user;

			if (l_email_count_flag = 0) then
				x_agent_activity_tbl(l_monitor_index).zero_flag:='true';
			else
				x_agent_activity_tbl(l_monitor_index).zero_flag:='false';
			end if;

			x_agent_activity_tbl(l_monitor_index).resource_id:=l_resource_id_tbl(l_index);
			x_agent_activity_tbl(l_monitor_index).resource_account_name:=l_account_name_tbl(i);
			x_agent_activity_tbl(l_monitor_index).email_account_id:=l_account_id_tbl(i);
			x_agent_activity_tbl(l_monitor_index).email_count:=l_email_count;
			x_agent_activity_tbl(l_monitor_index).oldest_age:=l_wait_time;
			x_agent_activity_tbl(l_monitor_index).average_age:=l_average_time;
			x_agent_activity_tbl(l_monitor_index).account_count:=-1;  -- No Account Count
			x_agent_activity_tbl(l_monitor_index).last_login_time:='-1'; -- No Last Login Time

			l_monitor_index := l_monitor_index + 1;

		end loop;
    	end loop;

-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;
-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 	p_data  =>    x_msg_data
			);
EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO get_email_activity_pvt;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO get_email_activity_pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO get_email_activity_pvt;
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
    		(p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data
    		);
END get_agent_activity;

end IEM_SPV_MONITORING_PVT ;

/
