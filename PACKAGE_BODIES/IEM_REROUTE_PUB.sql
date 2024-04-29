--------------------------------------------------------
--  DDL for Package Body IEM_REROUTE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_REROUTE_PUB" as
/* $Header: iemprerb.pls 120.1 2005/10/13 17:08:22 rtripath noship $*/

/* -- Change History
  -- 08/25/04 rtripath In case of reroute to same classification make sure that group associated with the
  --                   message is valid. i.e either the group contain other valid agent attach to the same account
  --				  otherwise update the group to make the message avaialble to all agent (i.e group_id=0)
  */
/**********************Global Variable Declaration **********************/
G_PKG_NAME CONSTANT varchar2(30) :='IEM_REROUTE_PUB ';

	PROCEDURE 	IEM_MAIL_REROUTE_CLASS(
        				p_Api_Version_Number 	  IN NUMBER,
        				p_Init_Msg_List  		  IN VARCHAR2     ,
        				p_Commit    			  IN VARCHAR2     ,
					p_msgid in number,
					p_agent_id	in number,
					p_class_id in number,
					p_customer_id	in number,
					p_uid in number,
					p_interaction_id in number,
					p_group_id	in number,
        				x_msg_count   		      OUT NOCOPY  NUMBER,
       				x_return_status  		  OUT NOCOPY  VARCHAR2,
      				x_msg_data   			  OUT NOCOPY  VARCHAR2) IS
	l_api_name        		VARCHAR2(255):='iem_mail_reroute_class';
	l_api_version_number 	NUMBER:=1.0;
l_old_id		iem_rt_proc_emails.rt_classification_id%type;
l_ret_status	varchar2(10);
l_msg_count	number;
l_counter	number;
l_count	number;
l_msg_data	varchar2(1000);
l_folder_name	varchar2(300);
l_post_rec	iem_rt_proc_emails%rowtype;
l_search		varchar2(100);		-- search pattern in subject
l_interaction_rec        JTF_IH_PUB.interaction_rec_type;
l_activity_rec        JTF_IH_PUB.activity_rec_type;
l_resource_id		number;
l_source_message_id		number;
l_customer_id		number;
l_interaction_id		number;
l_activity_id		number;
l_sender_name		varchar2(240);
KeyValuePairs iem_route_pub.KeyVals_tbl_type;
	l_encrypted_id		varchar2(500);
	l_index1			number;
	l_index2			number;
	l_tag_keyval			IEM_TAGPROCESS_PUB.keyVals_tbl_type;
l_group_id		number;
l_status		varchar2(10);
l_out_text		varchar2(500);
INSERT_HIST_EXCEPTION	EXCEPTION;
INSERT_MDT_EXCEPTION	EXCEPTION;
 FAILED_CREATE_INTERACTION EXCEPTION;
 FAILED_CREATE_ACTIVITY EXCEPTION;
 NO_DEFAULT_RESOURCE_ID	EXCEPTION;
 INVALID_CLASSIFICATION EXCEPTION;
 ERROR_RETRIEVE_SOURCE_MESSAGE EXCEPTION;
 BEGIN
-- Standard Start of API savepoint
SAVEPOINT		IEM_MAIL_REROUTE_PVT;
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
-- Initialize message list if p_init_msg_list is set to TRUE.
   IF p_init_msg_list='T'
   THEN
     FND_MSG_PUB.initialize;
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
	IEM_REROUTING_HISTS_PVT.CREATE_ITEM (p_api_version_number=>1.0,
 		  	      p_init_msg_list=>'F' ,
		    	      p_commit=>'F'	    ,
			p_message_id=>p_msgid,
			p_agent_id=>p_agent_id,
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
		      x_return_status=>l_ret_status	,
  		 	 x_msg_count=>l_msg_count	      ,
	  	  	 x_msg_data=>l_msg_data);
	IF l_ret_status<>'S' THEN
		RAISE INSERT_HIST_EXCEPTION;
	END IF;
 -- Check to See whether the message is transfered to same bin or different
 IF p_class_id is null then
 -- Create Interaction
     		l_interaction_rec.start_date_time   := sysdate;
     		l_resource_id:=FND_PROFILE.VALUE_SPECIFIC('IEM_SRVR_ARES') ;
			IF l_resource_id is NULL THEN
				raise NO_DEFAULT_RESOURCE_ID;
			END IF;
     		l_interaction_rec.resource_id:=l_resource_id ;
     		l_interaction_rec.party_id  := p_customer_id;
     		l_interaction_rec.handler_id        := 680; -- IEM APPL_ID
     		l_interaction_rec.parent_id  := p_interaction_id;
     		JTF_IH_PUB.Open_Interaction( p_api_version     => 1.0,
                                  p_resp_appl_id    => TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
                                  p_resp_id         => TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
                         		p_user_id		  =>nvl(TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),-1),
							p_login_id	  =>TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),
                                  x_return_status   => l_ret_status,
                                  x_msg_count       => l_msg_count,
                                  x_msg_data        => l_msg_data,
                                  x_interaction_id  => l_interaction_id,
                                  p_interaction_rec => l_interaction_rec
                                 );
			IF l_ret_status<>'S' THEN
				raise FAILED_CREATE_INTERACTION;
			END IF;
	select * into l_post_rec
	from iem_rt_proc_emails
	where message_id=p_msgid;
			-- Add a Activity for EMAILPROCESSING

     				l_activity_rec.start_date_time   := SYSDATE;
	       			l_activity_rec.media_id          := l_post_rec.ih_media_item_id;
         				l_activity_rec.action_id         := 95;	-- EMAILPROCESSED
         				l_activity_rec.interaction_id    := l_interaction_id;
         				l_activity_rec.action_item_id    := 45;-- EMAIL
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
						raise FAILED_CREATE_ACTIVITY;
					end if;
if p_group_id is null then		-- not a supervisor requeue
	IF l_post_rec.group_id >0 then	-- message was not routed to ALL group
   -- The below query verify that existing group for the message is valid. In this regard it checks its association
   -- with more than one agent i.e group should have some additional agent then the current one to fetch the
   -- message
	select count(*) into l_count from
 	jtf_rs_group_members c,iem_agents d
	where group_id=l_post_rec.group_id
	and delete_flag = 'N' and c.resource_id<>p_agent_id and c.resource_id = d.resource_id
	and d.email_account_id = l_post_rec.email_account_id
	and d.resource_id not in (select agent_id from iem_reroute_hists where message_id=p_msgid);
		IF l_count>0 then	--existing group is a valid group
			l_group_id:=l_post_rec.group_id;
		ELSE
			l_group_id:=0;		-- No more valid group available.So route to ALL group
		END IF;
	ELSE					     -- Message was originall routed to ALL group
		l_group_id:=0;
	END IF;
ELSE			-- supervisor requeue case
	l_group_id:=p_group_id;
end if;
		update iem_rt_proc_emails
		set resource_id=0,
		msg_status='REROUTE',
		group_id=l_group_id,
		IH_INTERACTION_ID=l_interaction_id
		where message_id=p_msgid;
 ELSE
	select * into l_post_rec
	from iem_rt_proc_emails
	where message_id=p_msgid;
 iem_Rt_preproc_emails_pvt.create_item(
	p_api_version_number => 1.0,
 	p_init_msg_list=>'F' ,
	p_commit=>'F'	    ,
	p_message_id=>p_msgid,
	p_email_account_id=>l_post_rec.email_account_id,
	p_priority => l_post_rec.priority,
	p_received_date=>l_post_rec.received_date,
	x_return_status => l_ret_status,
	x_msg_count => l_msg_count,
	x_msg_data => l_msg_data);

	IF l_ret_status<>'S' THEN
		RAISE INSERT_MDT_EXCEPTION;
	END IF;
	-- Later the below update statement will be added  to above create_item api 09/30/04 RT

	update iem_rt_preproc_emails
	set msg_status='REROUTE',
	IH_INTERACTION_ID=p_interaction_id,
	IH_MEDIA_ITEM_ID=l_post_rec.ih_media_item_id,
	RT_CLASSIFICATION_ID=p_class_id
	where message_id=p_msgid;
	delete from iem_rt_proc_emails where message_id=p_msgid;
 END IF;

-- Standard Check Of p_commit.
	IF p_commit='T' THEN
		COMMIT WORK;
	END IF;
	COMMIT;
-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 	p_data  =>    x_msg_data
			);
 EXCEPTION WHEN INSERT_HIST_EXCEPTION  THEN
	rollback to IEM_MAIL_REROUTE_PVT;
           FND_MESSAGE.SET_NAME('IEM','IEM_INSERT_HIST_EXCEPTION');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

 WHEN INSERT_MDT_EXCEPTION  THEN
	rollback to IEM_MAIL_REROUTE_PVT;
           FND_MESSAGE.SET_NAME('IEM','IEM_INSERT_MDT_EXCEPTION');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

 WHEN  FAILED_CREATE_INTERACTION THEN
	rollback to IEM_MAIL_REROUTE_PVT;
           FND_MESSAGE.SET_NAME('IEM','IEM_FAILED_CREATE_INTERACTIONS');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

 WHEN  FAILED_CREATE_ACTIVITY THEN
	rollback to IEM_MAIL_REROUTE_PVT;
           FND_MESSAGE.SET_NAME('IEM','IEM_FAILED_CREATE_ACTIVITY');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

 WHEN  INVALID_CLASSIFICATION THEN
	rollback to IEM_MAIL_REROUTE_PVT;
           FND_MESSAGE.SET_NAME('IEM','IEM_INVALID_CLASSIFICATION');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

 WHEN  NO_DEFAULT_RESOURCE_ID THEN
	rollback to IEM_MAIL_REROUTE_PVT;
           FND_MESSAGE.SET_NAME('IEM','IEM_NO_DEFAULT_RESOURCE_ID');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

 WHEN  ERROR_RETRIEVE_SOURCE_MESSAGE THEN
	rollback to IEM_MAIL_REROUTE_PVT;
           FND_MESSAGE.SET_NAME('IEM','IEM_ERROR_RETRIEVE_SOURCE_MSG');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);


   WHEN FND_API.G_EXC_ERROR THEN
	rollback to IEM_MAIL_REROUTE_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	rollback to IEM_MAIL_REROUTE_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
 WHEN OTHERS then
	rollback to IEM_MAIL_REROUTE_PVT;
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
 END  IEM_MAIL_REROUTE_CLASS;

	PROCEDURE 	IEM_MAIL_REROUTE_ACCOUNT(
        				p_Api_Version_Number 	  IN NUMBER,
        				p_Init_Msg_List  		  IN VARCHAR2     ,
        				p_Commit    			  IN VARCHAR2     ,
					p_msgid in number,
					p_agent_id in number,
					p_email_account_id in number,
					p_interaction_id in number,
					p_uid in number,
        				x_msg_count   		      OUT NOCOPY  NUMBER,
       				x_return_status  		  OUT NOCOPY  VARCHAR2,
      				x_msg_data   			  OUT NOCOPY  VARCHAR2) IS
	l_api_name        		VARCHAR2(255):='iem_mail_reroute_account';
	l_api_version_number 	NUMBER:=1.0;
	l_status			  varchar2(10);
	l_out_text		  varchar2(500);
	l_buf          varchar2(200);
	l_ret          varchar2(200);
	l_ret_status		varchar2(10);
	l_msg_count		number;
	l_msg_data		varchar2(100);
	l_media_id		number;
	l_received_date	date;
	l_post_Rec		iem_rt_proc_emails%rowtype;
	REROUTING_FAILS	EXCEPTION;
	INSERT_HIST_EXCEPTION	EXCEPTION;

	BEGIN
-- Standard Start of API savepoint
SAVEPOINT		IEM_MAIL_REROUTE_PVT;
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
-- Initialize message list if p_init_msg_list is set to TRUE.
   IF p_init_msg_list ='T'
   THEN
     FND_MSG_PUB.initialize;
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

	IEM_REROUTING_HISTS_PVT.CREATE_ITEM (p_api_version_number=>1.0,
 		  	      p_init_msg_list=>'F' ,
		    	      p_commit=>'F'	    ,
			p_message_id=>p_msgid,
			p_agent_id=>p_agent_id,
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
		      x_return_status=>l_ret_status	,
  		 	 x_msg_count=>l_msg_count	      ,
	  	  	 x_msg_data=>l_msg_data);
		IF l_ret_status<>'S' THEN
			raise INSERT_HIST_EXCEPTION;
		END IF;
		delete from iem_email_classifications where message_id=p_msgid;
		delete from iem_kb_Results where message_id=p_msgid;
select * into l_post_rec from iem_rt_proc_emails where message_id=p_msgid;
 iem_Rt_preproc_emails_pvt.create_item(
	p_api_version_number => 1.0,
 	p_init_msg_list=>'F' ,
	p_commit=>'F'	    ,
	p_message_id=>p_msgid,
	p_email_account_id=>p_email_account_id,
	p_priority => l_post_rec.priority,
	p_received_date=>l_post_rec.received_date,
	x_return_status => l_ret_status,
	x_msg_count => l_msg_count,
	x_msg_data => l_msg_data);

	IF l_ret_status<>'S' THEN
		RAISE REROUTING_FAILS;
	END IF;
	-- Later the below update statement will be added  to above create_item api 09/30/04 RT

	update iem_rt_preproc_emails
	set msg_status='REROUTE',
	IH_INTERACTION_ID=p_interaction_id,
	IH_MEDIA_ITEM_ID=l_post_rec.ih_media_item_id
	where message_id=p_msgid;
 delete from iem_rt_proc_emails where message_id=p_msgid;
-- Standard Check Of p_commit.
	IF p_commit='T' THEN
		COMMIT WORK;
	END IF;
	COMMIT;
-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 	p_data  =>    x_msg_data
			);
 EXCEPTION WHEN INSERT_HIST_EXCEPTION  THEN
	rollback to IEM_MAIL_REROUTE_PVT;
           FND_MESSAGE.SET_NAME('IEM','IEM_REROUTE_INSERT_FAILS');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

 WHEN NO_DATA_FOUND  THEN
	rollback to IEM_MAIL_REROUTE_PVT;
           FND_MESSAGE.SET_NAME('IEM','IEM_INVALID_REROUTE_RECORD');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
 WHEN REROUTING_FAILS  THEN
	rollback to IEM_MAIL_REROUTE_PVT;
           FND_MESSAGE.SET_NAME('IEM','IEM_REROUTING_FAILS');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
	rollback to IEM_MAIL_REROUTE_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	rollback to IEM_MAIL_REROUTE_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
 WHEN OTHERS then
	rollback to IEM_MAIL_REROUTE_PVT;
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
END IEM_MAIL_REROUTE_ACCOUNT;
	PROCEDURE 	IEM_UPD_GRP_QUEMSG(
        				p_Api_Version_Number 	  IN NUMBER,
        				p_Init_Msg_List  		  IN VARCHAR2     ,
        				p_Commit    			  IN VARCHAR2     ,
      				p_msg_ids_tbl IN  		  jtf_varchar2_Table_100,
					p_group_id 		in number,
					x_upd_count	 out nocopy number,
        				x_msg_count   		      OUT NOCOPY  NUMBER,
       				x_return_status  		  OUT NOCOPY  VARCHAR2,
      				x_msg_data   			  OUT NOCOPY  VARCHAR2) IS
	l_api_name        		VARCHAR2(255):='IEM_UPD_GRP_QUEMSG';
	l_api_version_number 	NUMBER:=1.0;
	l_upd_count			number:=0;

	BEGIN
-- Standard Start of API savepoint
SAVEPOINT		IEM_UPD_GRP_QUEMSG_PVT;
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
-- Initialize message list if p_init_msg_list is set to TRUE.
   IF p_init_msg_list ='T'
   THEN
     FND_MSG_PUB.initialize;
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
 IF p_msg_ids_tbl.count>0 THEN
	FOR i IN p_msg_ids_tbl.first..p_msg_ids_tbl.last LOOP
		update iem_rt_proc_emails
		set group_id=p_group_id
		where message_id=to_number(p_msg_ids_tbl(i));
		l_upd_count:=l_upd_count+1;
	END LOOP;
		x_upd_count:=l_upd_count;
ELSE
		x_upd_count:=0;
END IF;

-- Standard Check Of p_commit.
	IF p_commit='T' THEN
		COMMIT WORK;
	END IF;
EXCEPTION   WHEN FND_API.G_EXC_ERROR THEN
	rollback to IEM_UPD_GRP_QUEMSG_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	rollback to IEM_UPD_GRP_QUEMSG_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
 WHEN OTHERS then
	rollback to IEM_UPD_GRP_QUEMSG_PVT;
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
END IEM_UPD_GRP_QUEMSG;

	PROCEDURE 	IEM_MAIL_REDIRECT_ACCOUNT(
        				p_Api_Version_Number 	  IN NUMBER,
        				p_Init_Msg_List  		  IN VARCHAR2     ,
        				p_Commit    			  IN VARCHAR2     ,
					p_msgid in number,
					p_email_account_id in number,
					p_uid in number,
        				x_msg_count   		      OUT NOCOPY  NUMBER,
       				x_return_status  		  OUT NOCOPY  VARCHAR2,
      				x_msg_data   			  OUT NOCOPY  VARCHAR2) IS
					--This api is stubbed out as it is not required for 11ix RT 09/30/04
begin
	null;

end iem_mail_redirect_account ;
end ;

/
