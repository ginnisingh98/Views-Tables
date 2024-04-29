--------------------------------------------------------
--  DDL for Package Body IEM_SPV_ACTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_SPV_ACTIONS_PVT" as
/* $Header: iemvspab.pls 120.0 2005/06/02 14:06:59 appldev noship $*/
G_PKG_NAME		varchar2(100):='IEM_SPV_ACTIONS_PVT';


PROCEDURE delete_queue_msg (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 := NULL,
		    	      p_commit	    IN   VARCHAR2 := NULL,
			      p_message_id in number,
			      p_reason_id  in number,
			      x_return_status	OUT	NOCOPY 	VARCHAR2,
  		  	      x_msg_count	OUT	NOCOPY  NUMBER,
	  	  	      x_msg_data	OUT	NOCOPY	VARCHAR2) IS

    l_api_name		varchar2(30):='delete_queue_msg';
    l_api_version_number number:=1.0;
    l_status              NUMBER := 0;
    l_return_status       VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count           NUMBER := 0;
    l_msg_data            VARCHAR2(2000);
    l_post_mdts		iem_rt_proc_emails%rowtype;
    l_class_name   	iem_route_classifications.name%type;
    MOVE_MSG_FAIL	exception;
    l_current_user    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
    l_spv_resource_id number := 0;
    l_interaction_rec        JTF_IH_PUB.interaction_rec_type;
    l_interaction_id  NUMBER;
    l_activity_id          NUMBER;
    l_activity_rec           JTF_IH_PUB.activity_rec_type;
    l_media_lc_rec APPS.JTF_IH_PUB.media_lc_rec_type;
    l_milcs_id		number;
    l_party_id		NUMBER := 1000;

BEGIN

--Standard Savepoint
    SAVEPOINT delete_queue_msg;

-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME)
THEN
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Initialize the message list if p_init_msg_list is set to TRUE
    If FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

--Initialize API status return
x_return_status := FND_API.G_RET_STS_SUCCESS;

	select * into l_post_mdts from iem_rt_proc_emails where message_id=p_message_id for update;

	--l_current_user := 1003651;

	select resource_id into l_spv_resource_id from jtf_rs_resource_extns where user_id=l_current_user;

	if (l_post_mdts.customer_id = 0 or l_post_mdts.customer_id = -1)  then
		IEM_GETCUST_PVT.CustomerSearch(
 			P_Api_Version_Number => 1.0,
 			p_email  => l_post_mdts.from_address,
 			x_party_id  => l_party_id,
 			x_msg_count   => l_msg_count,
 			x_return_status => l_return_status,
 			x_msg_data=> l_msg_data);

 			IF l_return_status<>'S' THEN
    				raise MOVE_MSG_FAIL;
    			END IF;
    	else
    		l_party_id := l_post_mdts.customer_id;
    	end if;

    	if (l_post_mdts.ih_interaction_id is null) then

		-- Open an Interaction
     		l_interaction_rec.start_date_time   := sysdate;
     		l_interaction_rec.resource_id:= l_spv_resource_id;
     		l_interaction_rec.party_id          := l_party_id;
     		--l_interaction_rec.outcome_id        := 14; -- EMAIL DELETED
     		--l_interaction_rec.result_id         := 13;
     		l_interaction_rec.handler_id        := 680; -- IEM APPL_ID
     		--l_interaction_rec.reason_id         := 10;

     		select wu.outcome_id, wu.result_id, wu.reason_id into
		l_interaction_rec.outcome_id, l_interaction_rec.result_id, l_interaction_rec.reason_id
		from jtf_ih_action_action_items aa, jtf_ih_wrap_ups wu
		where aa.action_id =  31 and aa.action_item_id = 45
		and aa.default_wrap_id = wu.wrap_id;

     		JTF_IH_PUB.Open_Interaction( p_api_version     => 1.0,
                                  p_resp_appl_id    => TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
                                  p_resp_id         => TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
                         	  p_user_id		  =>nvl(TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),-1),
				  p_login_id	  =>TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),
                                  x_return_status   => l_return_status,
                                  x_msg_count       => l_msg_count,
                                  x_msg_data        => l_msg_data,
                                  x_interaction_id  => l_interaction_id,
                                  p_interaction_rec => l_interaction_rec
                                 );

		IF l_return_status<>'S' THEN
    			raise MOVE_MSG_FAIL;
    		END IF;
    	else
    		l_interaction_id := l_post_mdts.ih_interaction_id;

    		l_interaction_rec.interaction_id:= l_interaction_id;
               	l_interaction_rec.resource_id:= l_spv_resource_id;
               	l_interaction_rec.reason_id:= p_reason_id;

               	select wu.outcome_id, wu.result_id into
		l_interaction_rec.outcome_id, l_interaction_rec.result_id
		from jtf_ih_action_action_items aa, jtf_ih_wrap_ups wu
		where aa.action_id =  31 and aa.action_item_id = 45
		and aa.default_wrap_id = wu.wrap_id;

               	JTF_IH_PUB.Update_Interaction( p_api_version     => 1.0,
                                  p_resp_appl_id    => TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
                                  p_resp_id         => TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
                                  p_user_id         => nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1),
                                  p_login_id	    =>TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),
                                  x_return_status   => l_return_status,
                                  x_msg_count       => l_msg_count,
                                  x_msg_data        => l_msg_data,
                                  p_interaction_rec => l_interaction_rec
				 );

		IF l_return_status<>'S' THEN
    			raise MOVE_MSG_FAIL;
    		END IF;

    	end if; -- if (l_post_mdts.ih_interaction_id is null) then

    	-- Add an Activity
     		l_activity_rec.start_date_time   := SYSDATE;
	       	l_activity_rec.media_id          := l_post_mdts.ih_media_item_id;
         	l_activity_rec.action_id         := 31;	-- Deleted an inbound email
         	l_activity_rec.interaction_id    := l_interaction_id;
         	l_activity_rec.outcome_id        := 14;
         	l_activity_rec.result_id         := 13;
         	l_activity_rec.reason_id         := p_reason_id;
         	l_activity_rec.action_item_id    := 45;-- EMAIL


         JTF_IH_PUB.Add_Activity(p_api_version     => 1.0,
                                 p_resp_appl_id  => TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
                                 p_resp_id       => TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
                         	 p_user_id		  =>nvl(TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),-1),
				 p_login_id	  =>TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),
                                 x_return_status => l_return_status,
                                 x_msg_count     => l_msg_count,
                                 x_msg_data      => l_msg_data,
                                 p_activity_rec  => l_activity_rec,
                                 x_activity_id   => l_activity_id
                                 );

	IF l_return_status<>'S' THEN
   		raise MOVE_MSG_FAIL;
     	END IF;


	-- Create a Media Life Cycle
  	l_media_lc_rec.media_id :=l_post_mdts.ih_media_item_id ;
  	l_media_lc_rec.milcs_type_id := 6;
  	l_media_lc_rec.start_date_time := sysdate;
  	l_media_lc_rec.handler_id := 680;
  	l_media_lc_rec.resource_id := l_spv_resource_id;

  		JTF_IH_PUB.Add_MediaLifeCycle( 1.0,
						'T',
						'F',
						TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
						TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
						nvl(TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),-1),
						TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),
						l_return_status,
						l_msg_count,
						l_msg_data,
						l_media_lc_rec,
						l_milcs_id);
		IF l_return_status<>'S' THEN
			raise MOVE_MSG_FAIL;
		END IF;

		-- Close Interaction
		l_interaction_rec.interaction_id:=l_interaction_id;

     		JTF_IH_PUB.Close_Interaction( p_api_version     => 1.0,
                                  p_resp_appl_id    => TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
                                  p_resp_id         => TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
                         	  p_user_id		  =>nvl(TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),-1),
				  p_login_id	  =>TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),
                                  x_return_status   => l_return_status,
                                  x_msg_count       => l_msg_count,
                                  x_msg_data        => l_msg_data,
                                  p_interaction_rec => l_interaction_rec);

		IF l_return_status<>'S' THEN
    			raise MOVE_MSG_FAIL;
     		END IF;

	-- Move Messages between folders
	/*select name into l_class_name from iem_route_classifications where route_classification_id=l_post_mdts.rt_classification_id;

		iem_movemsg_pvt.moveOesMessage (p_api_version_number   => 1.0,
 		  	         p_init_msg_list  => FND_API.G_FALSE,
		    	     	 p_commit=> FND_API.G_FALSE,
  				 p_msgid	=> l_post_mdts.source_message_id,
  			       	 p_email_account_id	=> l_post_mdts.email_account_id,
  				 p_tofolder	=> 'Deleted',
  				 p_fromfolder => l_class_name,
		  		x_return_status	=> l_return_status,
  		    		x_msg_count	 => l_msg_count,
	  	    		x_msg_data	=> l_msg_data);


        	--Check for error, raise exception
        	--if error raise MOVE_MSG_FAIL;
        		IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         			raise MOVE_MSG_FAIL;
    			END IF;
    	*/
    	-- Delete from queue and close media items
	IEM_MAILITEM_PUB.ResolvedMessage (p_api_version_number  => 1.0,
                        	p_init_msg_list => FND_API.G_FALSE,
                                p_commit => FND_API.G_FALSE,
                                p_message_id          => l_post_mdts.message_id,
				p_action_flag	      => 'D',
				x_return_status       => l_return_status,
                                x_msg_count           => l_msg_count,
                                x_msg_data            => l_msg_data);

	  --Check for error, raise exception
          --if error raise MOVE_MSG_FAIL;
          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         	raise MOVE_MSG_FAIL;
    	  END IF;

--Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;


EXCEPTION
   WHEN MOVE_MSG_FAIL THEN
       	    ROLLBACK TO delete_queue_msg;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);



 WHEN FND_API.G_EXC_ERROR THEN
	   ROLLBACK TO delete_queue_msg;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO delete_queue_msg;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,p_data => x_msg_data);

   WHEN OTHERS THEN
	  ROLLBACK TO delete_queue_msg;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  IF 	FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        		FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
      END IF;

	  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count	,p_data	=> x_msg_data);

END delete_queue_msg;


PROCEDURE delete_queue_msg_batch (p_api_version_number  IN   NUMBER,
 		  	      p_init_msg_list  		IN   VARCHAR2 := NULL,
		    	      p_commit	    		IN   VARCHAR2 := NULL,
			      p_message_ids_tbl 	IN  jtf_varchar2_Table_100,
			      p_reason_id		IN	NUMBER,
			      x_moved_message_count  	OUT	NOCOPY NUMBER,
			      x_return_status		OUT	NOCOPY VARCHAR2,
  		  	      x_msg_count	      	OUT	NOCOPY   NUMBER,
	  	  	      x_msg_data		OUT	NOCOPY VARCHAR2) IS

    l_api_name		varchar2(30):='delete_queue_msg_batch';
    l_api_version_number number:=1.0;
    l_status              NUMBER := 0;
    l_return_status       VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count           NUMBER := 0;
    l_msg_data            VARCHAR2(2000);
    l_moved_message_count NUMBER := 0;

BEGIN

--Standard Savepoint
    SAVEPOINT delete_queue_msg_batch;

-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME)
THEN
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Initialize the message list if p_init_msg_list is set to TRUE
    If FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

--Initialize API status return
x_return_status := FND_API.G_RET_STS_SUCCESS;

FOR i IN p_message_ids_tbl.FIRST..p_message_ids_tbl.LAST LOOP


	iem_spv_actions_pvt.delete_queue_msg (p_api_version_number => 1.0,
 		  	      p_init_msg_list => FND_API.G_FALSE,
		    	      p_commit	=> FND_API.G_FALSE,
			      p_message_id => p_message_ids_tbl(i),
			      p_reason_id => p_reason_id,
			      x_return_status => l_return_status,
  		  	      x_msg_count => l_msg_count,
	  	  	      x_msg_data => l_msg_data) ;

	  IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         		l_moved_message_count := l_moved_message_count + 1;
    	  END IF;

END LOOP;

	x_moved_message_count := l_moved_message_count;


--Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;


EXCEPTION

 WHEN FND_API.G_EXC_ERROR THEN
	   ROLLBACK TO delete_queue_msg;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO delete_queue_msg;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,p_data => x_msg_data);

   WHEN OTHERS THEN
	  ROLLBACK TO delete_queue_msg;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  IF 	FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        		FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
      END IF;

	  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count	,p_data	=> x_msg_data);

END delete_queue_msg_batch;

end IEM_SPV_ACTIONS_PVT ;

/
