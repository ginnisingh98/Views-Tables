--------------------------------------------------------
--  DDL for Package Body JTF_USR_HKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_USR_HKS" as
/* $Header: JTFUHKSB.pls 120.4 2005/10/21 12:24:43 kjayapra ship $ */

-------------------------------------------------------------------------
 G_PKJ_NAME        CONSTANT	VARCHAR2(25) := 'JTF_USR_HKS';

/*  function to check for execution of pre/post logic */

Function	Ok_To_Execute(	p_Pkg_name		varchar2,
				p_API_name		varchar2,
				p_Process_type		varchar2,
				p_User_hook_type	varchar2
			      ) Return Boolean  is
l_execute	Varchar2(1);
l_conc_pgm_id   Number;
l_conc_pgm_name Varchar2(25) := 'DEFAULT';

Begin

	Begin

		Select EXECUTE_FLAG
		into	l_execute
		from
		JTF_USER_HOOKS
		Where
 		pkg_name = p_pkg_name	and
		api_name = p_api_name	and
		processing_type = p_process_type	and
		user_hook_type = p_user_hook_type;
	Exception
		When NO_DATA_FOUND  then
			Return FALSE;

       	End;

	If ( l_execute = 'Y' )	then
           l_conc_pgm_id := fnd_global.conc_program_id;


		If ( l_conc_pgm_id = -1 ) then
		        return TRUE;
		else
/* actual logic should have a statement to find out conc program name from
   fnd_concurrent programs for the conc_pgm_id and compare for that  */

		       if ( l_conc_pgm_name = 'CRM_SUBSCRIBER') AND
						( p_User_hook_type = 'M' ) then
				return FALSE;
                       else
                                return TRUE;
		        end if;
	        End if;
	  Else
		return FALSE;
	End if;

End Ok_To_Execute;



/*  Procedure to launch non message generating workflow */

Procedure WrkflowLaunch( p_Wf_item_name			varchar2,
                         p_Wf_item_process_name  	varchar2,
                         p_Wf_item_key       		varchar2,
		         p_Bind_data_id			Number,
                         x_return_code        Out NOCOPY 	varchar2
			)   is

l_bind_data_id 	Number := p_bind_data_id;

Cursor ATT_BIND_DATA is
	Select bind_name, bind_value, data_type
	From	JTF_BIND_DATA
	Where 	bind_data_id = l_bind_data_id  And
		bind_type    = 'W';

l_wf_item_exists	Boolean := FALSE;
l_owner_name		Varchar2(100);

Begin


-- Check for existence of same workflow instance.
 l_wf_item_exists := wf_item.item_exist( itemtype => p_wf_item_name,
                                        itemkey =>  p_wf_item_key );
 if ( l_wf_item_exists ) then
                FND_MESSAGE.SET_NAME('JTF','JTF_WF_ALREADY_EXISTS');
                FND_MESSAGE.SET_TOKEN('WF_NAME',p_wf_item_name);
                FND_MESSAGE.SET_TOKEN('WF_KEY',p_wf_item_key);
                FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
 else
--	Create workflow process.
       wf_engine.CreateProcess( itemType => p_Wf_item_name,
				itemKey  => p_Wf_item_key,
                                process  => p_Wf_item_process_name
				);

-- Set workflow instance owner

  l_owner_name := FND_GLOBAL.USER_NAME;

  wf_engine.SetItemOwner( itemtype => p_wf_item_name,
                          itemkey  => p_wf_item_key,
                          owner    => l_owner_name );

-- Set Workflow item attributes

 FOR wf_att IN att_bind_data  LOOP

	IF ( wf_att.data_type = 'T' ) then
  		wf_engine.setitemattrText( itemtype => p_wf_item_name,
               			             itemkey  => p_wf_item_key,
                               		     aname    => wf_att.bind_name,
                               		     avalue   => wf_att.bind_value );

	ELSIF ( wf_att.data_type = 'N' ) then
  		wf_engine.setitemattrNumber( itemtype => p_wf_item_name,
               			             itemkey  => p_wf_item_key,
                               		     aname    => wf_att.bind_name,
                               		     avalue   => wf_att.bind_value );

	ELSIF ( wf_att.data_type = 'D' ) then
  		wf_engine.setitemattrDate( itemtype => p_wf_item_name,
               			           itemkey  => p_wf_item_key,
                       aname    => wf_att.bind_name,
                       avalue   => to_date(wf_att.bind_value,'YYYY/MM/DD')  );

	END IF;
 END LOOP;


/* 	start workflow process  */
	wf_engine.StartProcess( itemType => p_wf_item_name,
				itemKey  => p_wf_item_key
				);

                FND_MESSAGE.SET_NAME('JTF','JTF_WF_LAUNCH_SUCCESS');
                FND_MESSAGE.SET_TOKEN('WF_NAME',p_wf_item_name);
                FND_MESSAGE.SET_TOKEN('WF_KEY',p_wf_item_key);
                FND_MSG_PUB.Add;

/*	Purge Bind data table   */
	JTF_USR_HKS.Purge_Bind_Data( p_bind_data_id => l_bind_data_id,
				     p_bind_type   => 'W'
				    );

	x_return_code := FND_API.G_RET_STS_SUCCESS;

 end if;
Exception
        When  FND_API.G_EXC_ERROR  then
                x_return_code := FND_API.G_RET_STS_ERROR;

	When  FND_API.G_EXC_UNEXPECTED_ERROR  then
                x_return_code := FND_API.G_RET_STS_UNEXP_ERROR;

	When  OTHERS  then
                x_return_code := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MESSAGE.SET_NAME('JTF','JTF_WF_LAUNCH_ERROR');
                FND_MESSAGE.SET_TOKEN('WF_NAME',p_wf_item_name);
                FND_MESSAGE.SET_TOKEN('WF_KEY',p_wf_item_key);
                FND_MSG_PUB.Add;

End WrkflowLaunch;


/*  Procedure to launch message generating workflow */

Procedure  GenMsgWrkflowLaunch(
	     	p_Wf_item_name			varchar2,
                p_Wf_item_process_name  	varchar2,
                p_Wf_item_key       		varchar2,
                p_prod_code     		varchar2,
	   	p_bus_obj_code  		varchar2,
                p_bus_obj_name  		varchar2,
		p_action_code			varchar2,
		p_correlation			varchar2,
          	p_bind_data_id			Number,
		p_OAI_param			varchar2,
		p_OAI_array			JTF_USR_HKS.OAI_data_array_type,
                x_return_code      Out NOCOPY		varchar2
			) is

l_bind_data_id 	Number := p_bind_data_id;

Cursor ATT_BIND_DATA is
	Select bind_name, bind_value, data_type
	From	JTF_BIND_DATA
	Where 	bind_data_id = l_bind_data_id  And
		bind_type    = 'W';

l_wf_item_exists	Boolean := FALSE;
l_owner_name		Varchar2(100);

Begin


-- Check for existence of same workflow instance.
 l_wf_item_exists := wf_item.item_exist( itemtype => p_wf_item_name,
                                        itemkey =>  p_wf_item_key );
 if ( l_wf_item_exists ) then
                FND_MESSAGE.SET_NAME('JTF','JTF_WF_ALREADY_EXISTS');
                FND_MESSAGE.SET_TOKEN('WF_NAME',p_wf_item_name);
                FND_MESSAGE.SET_TOKEN('WF_KEY',p_wf_item_key);
                FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
 else
--	Create workflow process.
       wf_engine.CreateProcess( itemType => p_Wf_item_name,
				itemKey  => p_Wf_item_key,
                                process  => p_Wf_item_process_name
				);

-- Set workflow instance owner

  l_owner_name := FND_GLOBAL.USER_NAME;

  wf_engine.SetItemOwner( itemtype => p_wf_item_name,
                          itemkey  => p_wf_item_key,
                          owner    => l_owner_name );

-- Set Workflow item attributes

 FOR wf_att IN att_bind_data  LOOP

	IF ( wf_att.data_type = 'T' ) then
  		wf_engine.setitemattrText( itemtype => p_wf_item_name,
               			             itemkey  => p_wf_item_key,
                               		     aname    => wf_att.bind_name,
                               		     avalue   => wf_att.bind_value );

	ELSIF ( wf_att.data_type = 'N' ) then
  		wf_engine.setitemattrNumber( itemtype => p_wf_item_name,
               			             itemkey  => p_wf_item_key,
                               		     aname    => wf_att.bind_name,
                               		     avalue   => wf_att.bind_value );

	ELSIF ( wf_att.data_type = 'D' ) then
  		wf_engine.setitemattrDate( itemtype => p_wf_item_name,
               			           itemkey  => p_wf_item_key,
                       aname    => wf_att.bind_name,
                       avalue   => to_date(wf_att.bind_value,'YYYY/MM/DD')  );

	END IF;
 END LOOP;

  		wf_engine.setitemattrNumber( itemtype => p_wf_item_name,
                                             itemkey  => p_wf_item_key,
                                             aname    => 'BIND_DATA_ID',
                                             avalue   => p_bind_data_id );

		wf_engine.setitemattrText( itemtype => p_wf_item_name,
                                           itemkey  => p_wf_item_key,
                                           aname    => 'PRODUCT_CODE',
                                           avalue   => p_prod_code );

  		wf_engine.setitemattrText( itemtype => p_wf_item_name,
                                           itemkey  => p_wf_item_key,
                                           aname    => 'BUS_OBJ_CODE',
                                           avalue   => p_bus_obj_code);

  		wf_engine.setitemattrText( itemtype => p_wf_item_name,
                                           itemkey  => p_wf_item_key,
                                           aname    => 'BUS_OBJ_NAME',
                                           avalue   => p_bus_obj_name);

  		wf_engine.setitemattrText( itemtype => p_wf_item_name,
                                           itemkey  => p_wf_item_key,
                                           aname    => 'ACTION_CODE',
                                           avalue   => p_action_code);

  		wf_engine.setitemattrText( itemtype => p_wf_item_name,
                                           itemkey  => p_wf_item_key,
                                           aname    => 'CORRELATION',
                                           avalue   => p_correlation);
-- 	start workflow process
	wf_engine.StartProcess( itemType => p_wf_item_name,
				itemKey  => p_wf_item_key
				);

                FND_MESSAGE.SET_NAME('JTF','JTF_WF_LAUNCH_SUCCESS');
                FND_MESSAGE.SET_TOKEN('WF_NAME',p_wf_item_name);
                FND_MESSAGE.SET_TOKEN('WF_KEY',p_wf_item_key);
                FND_MSG_PUB.Add;

--	Purge Bind data table
	JTF_USR_HKS.Purge_Bind_Data( p_bind_data_id => l_bind_data_id,
				     p_bind_type   => 'W'
				    );

	x_return_code := FND_API.G_RET_STS_SUCCESS;

 end if;
Exception
        When  FND_API.G_EXC_ERROR  then
                x_return_code := FND_API.G_RET_STS_ERROR;

	When  FND_API.G_EXC_UNEXPECTED_ERROR  then
                x_return_code := FND_API.G_RET_STS_UNEXP_ERROR;

	When  OTHERS  then
                x_return_code := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MESSAGE.SET_NAME('JTF','JTF_WF_LAUNCH_ERROR');
                FND_MESSAGE.SET_TOKEN('WF_NAME',p_wf_item_name);
                FND_MESSAGE.SET_TOKEN('WF_KEY',p_wf_item_key);
                FND_MSG_PUB.Add;

End GenMsgWrkflowLaunch;


/* This procedure starts an autonomous transaction for commit a msg in queue */
procedure Queue_Sync_Msg( p_prod_code    varchar2,
			  p_bus_obj_code varchar2,
			  p_bus_obj_name varchar2,
                          p_correlation  varchar2,
                          p_msg_XML      clob ) is

PRAGMA  AUTONOMOUS_TRANSACTION;
Begin
       JTF_Message.Queue_Message(
		   p_prod_code    => p_prod_code,
                   p_bus_obj_code => p_bus_obj_code,
                   p_bus_obj_name => p_bus_obj_name,
                   p_correlation  => p_correlation,
                   p_message      => p_msg_XML     );
        Commit;

End Queue_Sync_Msg ;


/*  Procedure to Genearate  message for publishing only  */
Procedure Generate_message(
			p_prod_code     	varchar2,
	  	 	p_bus_obj_code  	varchar2,
       		        p_bus_obj_name  	varchar2 ,
			p_action_code		varchar2,
			p_correlation		varchar2,
			p_bind_data_id		number,
			p_OAI_param	        varchar2,
			p_OAI_array	        JTF_USR_HKS.OAI_data_array_type,
			x_return_code   Out NOCOPY	varchar2
  			) is
l_msg_SQL	CLOB;
l_msg_mode	number;
l_msg_type      varchar2(20):= 'PUBLISH';
l_bus_obj_name	varchar2(50);

Begin


	Begin
		select  bus_obj_sql, nvl(msg_mode,1) , bus_obj_name
		into  l_msg_SQL, l_msg_mode, l_bus_obj_name
		from  JTF_MESSAGE_OBJECTS
		where
			PRODUCT_CODE   =  p_prod_code  and
			BUS_OBJ_CODE   =  p_bus_obj_code  and
			ACTION_CODE    =  p_action_code and
			ACTIVE_FLAG    =  'Y';
	Exception
		When NO_DATA_FOUND then
		FND_MESSAGE.SET_NAME('JTF','JTF_NO_BUS_OBJECT');
                FND_MESSAGE.SET_TOKEN('BO_CODE',p_bus_obj_code);
		FND_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;
	When OTHERS then
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	End;
-- dbms_output.put_line(' Got message mode');

	If ( l_msg_mode = 1 ) then             /*  Online Messaging */

		Publish_message(
			p_prod_code     =>   p_prod_code   ,
                        p_bus_obj_code  =>   p_bus_obj_code,
       		        p_bus_obj_name 	=>   p_bus_obj_name,
                        p_action_code   =>   p_action_code ,
                        p_correlation   =>   p_correlation ,
                        p_bind_data_id  =>   p_bind_data_id,
			p_msg_type      =>   l_msg_type
  			     );

	Elsif ( l_msg_mode = 2 ) then    /*  off line messaging  */

		Stage_Message(
			p_prod_code     =>   p_prod_code   ,
                        p_bus_obj_code  =>   p_bus_obj_code,
                        p_action_code   =>   p_action_code ,
                        p_correlation   =>   p_correlation ,
                        p_bind_data_id  =>   p_bind_data_id
			     );

	Else

                FND_MESSAGE.SET_NAME('JTF','JTF_INVALID_MSG_MODE');
		FND_MESSAGE.SET_TOKEN('MSG_MODE', to_char(l_msg_mode) );
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
        End If;

	x_return_code := FND_API.G_RET_STS_SUCCESS;

Exception
	When  FND_API.G_EXC_ERROR then
		x_return_code := FND_API.G_RET_STS_ERROR;
	When  OTHERS then
		x_return_code := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MESSAGE.SET_NAME('JTF','JTF_MSG_GEN_ERROR');
                FND_MESSAGE.SET_TOKEN('PROD_CODE',p_prod_code);
                FND_MESSAGE.SET_TOKEN('BO_CODE',p_bus_obj_code);
		FND_MSG_PUB.ADD;

End Generate_Message;

/* For sending Reply type message */
Procedure Generate_message(
			p_prod_code     	varchar2,
	  	 	p_bus_obj_code  	varchar2,
       		        p_bus_obj_name  	varchar2 ,
			p_action_code		varchar2,
			p_correlation		varchar2,
			p_bind_data_id		number,
			p_ref_sender		varchar2,
			p_ref_msg_id		number,
			p_OAI_param	        varchar2,
			p_OAI_array	        JTF_USR_HKS.OAI_data_array_type,
			x_return_code   Out NOCOPY	varchar2
  			) is
l_msg_SQL	CLOB;
l_msg_mode	number;
l_msg_type      varchar2(20):= 'REPLY';
l_bus_obj_name  varchar2(20);

Begin


	Begin
		select  bus_obj_sql ,nvl(msg_mode,1) , bus_obj_name
		into  l_msg_SQL, l_msg_mode, l_bus_obj_name
		from  JTF_MESSAGE_OBJECTS
		where
			PRODUCT_CODE   =  p_prod_code  and
			BUS_OBJ_CODE   =  p_bus_obj_code  and
			ACTION_CODE    =  p_action_code and
			ACTIVE_FLAG    =  'Y';
	Exception
		When NO_DATA_FOUND then
		FND_MESSAGE.SET_NAME('JTF','JTF_NO_BUS_OBJECT');
                FND_MESSAGE.SET_TOKEN('BO_CODE',p_bus_obj_code);
		FND_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;
	When OTHERS then
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	End;
-- dbms_output.put_line(' Got message mode');

		Publish_message(
			p_prod_code     =>   p_prod_code   ,
                        p_bus_obj_code  =>   p_bus_obj_code,
       		        p_bus_obj_name 	=>   p_bus_obj_name,
                        p_action_code   =>   p_action_code ,
                        p_correlation   =>   p_correlation ,
                        p_bind_data_id  =>   p_bind_data_id,
                        p_msg_type  	=>   l_msg_type,
                        p_ref_sender  	=>   p_ref_sender,
                        p_ref_msg_id  	=>   p_ref_msg_id
  			     );

	x_return_code := FND_API.G_RET_STS_SUCCESS;

Exception
	When  FND_API.G_EXC_ERROR then
		x_return_code := FND_API.G_RET_STS_ERROR;
	When  OTHERS then
		x_return_code := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MESSAGE.SET_NAME('JTF','JTF_MSG_GEN_ERROR');
                FND_MESSAGE.SET_TOKEN('PROD_CODE',p_prod_code);
                FND_MESSAGE.SET_TOKEN('BO_CODE',p_bus_obj_code);
		FND_MSG_PUB.ADD;

End Generate_Message;

/* For sync/Async request/reply message */
Procedure Generate_message(
			p_prod_code     	varchar2,
	  	 	p_bus_obj_code  	varchar2,
       		        p_bus_obj_name  	varchar2 ,
			p_action_code		varchar2,
			p_correlation		varchar2,
			p_bind_data_id		number,
			p_timeout               number,
			p_OAI_param	        varchar2,
			p_OAI_array	        JTF_USR_HKS.OAI_data_array_type,
			x_msg_id       Out NOCOPY      number,
        		x_reply_msg    Out NOCOPY      CLOB,
			x_return_code  Out NOCOPY	varchar2
  			) is
l_msg_SQL	CLOB;
l_msg_mode	number;
l_msg_type      varchar2(20);
l_bus_obj_name  varchar2(20);
l_wait_time	number;
l_alert_name    varchar2(100);
l_alert_message varchar2(1);
l_alert_status  number;

Begin


	Begin
		select  bus_obj_sql ,nvl(msg_mode,1) , bus_obj_name
		into  l_msg_SQL, l_msg_mode, l_bus_obj_name
		from  JTF_MESSAGE_OBJECTS
		where
			PRODUCT_CODE   =  p_prod_code  and
			BUS_OBJ_CODE   =  p_bus_obj_code  and
			ACTION_CODE    =  p_action_code and
			ACTIVE_FLAG    =  'Y';
	Exception
		When NO_DATA_FOUND then
		FND_MESSAGE.SET_NAME('JTF','JTF_NO_BUS_OBJECT');
                FND_MESSAGE.SET_TOKEN('BO_CODE',p_bus_obj_code);
		FND_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;
	When OTHERS then
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	End;

  	select jtf_msg_id_s.nextval
	into x_msg_id
	from dual;

 	 if (p_timeout = 0) then
	    l_msg_type := 'ASYNC_REQUEST';
	    l_wait_time := 0;
	 elsif (p_timeout < 0) then
  	    l_msg_type := 'SYNC_REQUEST';
  	    l_wait_time := DBMS_ALERT.MAXWAIT;
         else
            l_msg_type := 'SYNC_REQUEST';
            l_wait_time := p_timeout;
         end if;


		Publish_message(
			p_prod_code     =>   p_prod_code   ,
                        p_bus_obj_code  =>   p_bus_obj_code,
       		        p_bus_obj_name 	=>   p_bus_obj_name,
                        p_action_code   =>   p_action_code ,
                        p_correlation   =>   p_correlation ,
                        p_bind_data_id  =>   p_bind_data_id,
                        p_msg_type  	=>   l_msg_type,
			p_ref_msg_id	=>   x_msg_id,
			p_timeout       =>   p_timeout
  			     );

		if (p_timeout <> 0) then
       			l_alert_name := 'JTF' || x_msg_id;

    			DBMS_ALERT.REGISTER(l_alert_name);
		    	DBMS_ALERT.WAITONE(
		      			l_alert_name,
		     		 	l_alert_message,
		      			l_alert_status,
		      			l_wait_time
		    			);

		        DBMS_ALERT.REMOVE(l_alert_name);

		        if (l_alert_status = 0) then

		        	  delete from JTF_SYNC_REPLY_MSG
		        	  where msg_id = x_msg_id
		        	  returning reply_msg into x_reply_msg;

		        	  x_return_code := FND_API.G_RET_STS_SUCCESS;
			else
			          x_return_code := FND_API.G_RET_STS_ERROR;
    			end if;

        	  else
		          x_return_code := FND_API.G_RET_STS_SUCCESS;
    		  end if;

Exception
	When  FND_API.G_EXC_ERROR then
		x_return_code := FND_API.G_RET_STS_ERROR;
	When  OTHERS then
		x_return_code := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MESSAGE.SET_NAME('JTF','JTF_MSG_GEN_ERROR');
                FND_MESSAGE.SET_TOKEN('PROD_CODE',p_prod_code);
                FND_MESSAGE.SET_TOKEN('BO_CODE',p_bus_obj_code);
		FND_MSG_PUB.ADD;

End Generate_Message;


/* For sending pre-generated XML message */
Procedure Generate_message(
			p_prod_code    	 	varchar2,
   			p_bus_obj_code   	varchar2,
        		p_bus_obj_name   	varchar2,
			p_correlation           varchar2,
			p_timeout		number,
			p_message		CLOB,
			p_msg_type		varchar2,
			x_msg_id        Out NOCOPY	number,
			x_reply_msg     Out NOCOPY	CLOB,
			x_return_code   Out NOCOPY 	varchar2
  			) is
l_wait_time	number;
l_alert_name    varchar2(100);
l_alert_message varchar2(1);
l_alert_status  number;

Begin


   if ( p_msg_type = 'R' ) then

  	select jtf_msg_id_s.nextval
	into x_msg_id
	from dual;

 	 if (p_timeout = 0) then
	    l_wait_time := 0;
	 elsif (p_timeout < 0) then
  	    l_wait_time := DBMS_ALERT.MAXWAIT;
         else
            l_wait_time := p_timeout;
         end if;
   end if;

    if ( ( p_msg_type = 'P') OR ( p_timeout = 0 ) ) then

	JTF_Message.Queue_Message( p_prod_code => p_prod_code,
                          	   p_bus_obj_code => p_bus_obj_code,
                         	   p_bus_obj_name => p_bus_obj_name,
       			           p_correlation  => p_correlation,
	             		   p_message	  => p_message     );
   else
                    /* To take care of sync req/reply scenario */
                Queue_Sync_Msg(
				   p_prod_code => p_prod_code,
                                   p_bus_obj_code => p_bus_obj_code,
                                   p_bus_obj_name => p_bus_obj_name,
                                   p_correlation  => p_correlation,
                                   p_msg_XML      => p_message     );
   end if;

    if (( p_msg_type = 'R') AND ( p_timeout <> 0)) then

   		l_alert_name := 'JTF' || x_msg_id;

		DBMS_ALERT.REGISTER(l_alert_name);
	    	DBMS_ALERT.WAITONE(
	      			l_alert_name,
	     		 	l_alert_message,
	      			l_alert_status,
	      			l_wait_time
	    			);

	        DBMS_ALERT.REMOVE(l_alert_name);

	        if (l_alert_status = 0) then

	        	  delete from JTF_SYNC_REPLY_MSG
	        	  where msg_id = x_msg_id
	        	  returning reply_msg into x_reply_msg;

	        	  x_return_code := FND_API.G_RET_STS_SUCCESS;
		else
		          x_return_code := FND_API.G_RET_STS_ERROR;
    		end if;

    else
	          x_return_code := FND_API.G_RET_STS_SUCCESS;
    end if;

Exception
	When  FND_API.G_EXC_ERROR then
		x_return_code := FND_API.G_RET_STS_ERROR;
	When  OTHERS then
		x_return_code := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MESSAGE.SET_NAME('JTF','JTF_MSG_GEN_ERROR');
                FND_MESSAGE.SET_TOKEN('PROD_CODE',p_prod_code);
                FND_MESSAGE.SET_TOKEN('BO_CODE',p_bus_obj_code);
		FND_MSG_PUB.ADD;

End Generate_Message;

/*  Function to return Bind data Id  */

Function Get_Bind_Data_Id Return Number is

l_db_id	Number;
Begin
	l_db_id := JTF_USR_HKS.Get_Bus_Obj_Id;

   return(l_db_id);

End Get_Bind_Data_Id;



/*  Procedure Load_Bind_data will load the bind data to
	JTF_BIND_DATA table
*/

Procedure Load_Bind_Data( p_bind_data_id	Number,
			  p_bind_name		Varchar2,
			  p_bind_value		Varchar2,
			  p_bind_type		Varchar2,
			  p_data_type		Varchar2
			)  is
Begin

	Insert into JTF_BIND_DATA(
				   bind_data_id,
				   bind_name,
				   bind_value,
				   bind_type,
				   data_type   )
		   	Values  (
				   p_bind_data_id,
				   p_bind_name,
				   p_bind_value,
				   p_bind_type,
				   p_data_type  );
End Load_Bind_Data;


/*  Procedure to purge bind data table */

Procedure Purge_Bind_Data( p_Bind_Data_Id	Number,
			   p_bind_type		Varchar2 ) is

Begin
	Delete from JTF_BIND_DATA
	Where  BIND_DATA_ID  = p_Bind_Data_Id  And
	       BIND_TYPE     = p_bind_type ;
     Exception
	When NO_DATA_FOUND then
		null;

End Purge_Bind_Data;


/*  Function to return user hook  Id  */

Function Get_User_Hook_Id Return Number is

l_hk_id	Number;
Begin
	Select JTF_USER_HOOKS_S.NEXTVAL
	into l_hk_id
	from Dual;

   return(l_hk_id);

End Get_User_Hook_Id;


/*  Function to return Bus Obj Id  */

Function Get_Bus_Obj_Id Return Number is

l_bo_id	Number;
Begin
	Select JTF_MSG_OBJ_S.NEXTVAL
	into l_bo_id
	from Dual;

   return(l_bo_id);

End Get_Bus_Obj_Id;


procedure Generate_Hdrxml(
                        p_prodcode        IN varchar2,
                        p_bo_code         IN varchar2,
                        p_noun            IN varchar2 ,
                        p_verb            IN varchar2 ,
                        p_type 	          IN varchar2 ,
                        p_sender          IN varchar2 ,
                        p_msg_id  	  IN varchar2 ,
                        x_hdrxml          OUT NOCOPY varchar2 ) Is

l_hdrxml    varchar2(8000) ;
l_line	    varchar2(1000);
l_newline   varchar2(20) := fnd_global.newline;

BEGIN
-- dbms_output.enable(20000);
 l_line := '<CNTRLAREA>';
 l_hdrxml := l_hdrxml||l_line||l_newline;

 l_line := lpad(' ',4)||'<prodcode>'||ltrim(rtrim(p_prodcode))||'</prodcode>';
 l_hdrxml := l_hdrxml||l_line||l_newline;

 l_line := lpad(' ',4)||'<bocode>'||ltrim(rtrim(p_bo_code))||'</bocode>';
 l_hdrxml := l_hdrxml||l_line||l_newline;

 l_line := lpad(' ',4)||'<verb>'||ltrim(rtrim(p_verb))||'</verb>';
 l_hdrxml := l_hdrxml||l_line||l_newline;

 if ( p_noun <> FND_API.G_MISS_CHAR ) then
    l_line := lpad(' ',4)||'<noun>'||ltrim(rtrim(p_noun))||'</noun>';
    l_hdrxml := l_hdrxml||l_line||l_newline;
 end if;

 if ( p_type <> FND_API.G_MISS_CHAR ) then
   l_line := lpad(' ',4)||'<type>'||ltrim(rtrim(p_type))||'</type>';
   l_hdrxml := l_hdrxml||l_line||l_newline;
 end if;

 if ( p_sender <> FND_API.G_MISS_CHAR ) then
   l_line := lpad(' ',4)||'<sender>'||ltrim(rtrim(p_sender))||'</sender>';
   l_hdrxml := l_hdrxml||l_line||l_newline;
 end if;

 if ( p_msg_id <> FND_API.G_MISS_CHAR ) then
     l_line := '<msg_id>'||ltrim(rtrim(p_msg_id))||'</msg_id>';
     l_hdrxml := l_hdrxml||l_line||l_newline;
 end if;

  l_line := '</CNTRLAREA>';
  l_hdrxml := l_hdrxml||l_line;

-- dbms_output.put_line(l_hdrxml );

  x_hdrxml := l_hdrxml;
End Generate_Hdrxml;


/*  Procedure to publish  message   */
Procedure Publish_message(
			p_prod_code     	varchar2,
	  	 	p_bus_obj_code  	varchar2,
			p_bus_obj_name		varchar2,
			p_action_code		varchar2,
			p_correlation		varchar2,
			p_bind_data_id		number  ,
			p_msg_type		varchar2,
			p_ref_sender     	Varchar2,
			p_ref_msg_id     	Number,
			p_timeout		Number
  			) is

l_hdrXML_len	Number;
l_hdrXML_str	Varchar2(9000);
l_msg_XML	CLOB;
l_msg_SQL	CLOB;
l_hdr_DTD	CLOB;
l_hdr_XML	CLOB;
l_msg_mode	number;
l_bus_obj_name	varchar2(50);

amount          number := 240;
position	number := 1;
charstr		varchar2(255);
queryCtx DBMS_XMLquery.ctxType;

Cursor SQL_BIND_DATA(v_bind_data_id	Number) is
	Select bind_name, bind_value
	From	JTF_BIND_DATA
	Where 	bind_data_id = v_bind_data_id  And
		bind_type    = 'S';

Begin


	Begin
		select  bus_obj_sql, nvl(msg_mode,1), bus_obj_name
		into  l_msg_SQL, l_msg_mode, l_bus_obj_name
		from  JTF_MESSAGE_OBJECTS
		where
			PRODUCT_CODE   =  p_prod_code  and
			BUS_OBJ_CODE   =  p_bus_obj_code  and
			ACTION_CODE    =  p_action_code and
			ACTIVE_FLAG    =  'Y';
	Exception
		When NO_DATA_FOUND then
		FND_MESSAGE.SET_NAME('JTF','JTF_NO_BUS_OBJECT');
                FND_MESSAGE.SET_TOKEN('BO_CODE',p_bus_obj_code);
		FND_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;
	When OTHERS then
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	End;
-- dbms_output.put_line(' Got message sql');
 -- set up the query context...!
  queryCtx := DBMS_XMLQuery.newContext(l_msg_SQL);
		Begin
			select  HEADER_DTD  into  l_hdr_DTD
			from  JTF_HEADER_DTD
			where
				ACTIVE_FLAG    =  'Y';
		Exception
			When NO_DATA_FOUND then
			FND_MESSAGE.SET_NAME('JTF','JTF_NO_HDR_DTD');
			FND_MSG_PUB.ADD;
			RAISE FND_API.G_EXC_ERROR;
		When OTHERS then
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		End;

-- dbms_output.put_line(' Got header dtd');

      	Generate_Hdrxml( p_prodcode  => p_prod_code,
       	                 p_bo_code   => p_bus_obj_code ,
       	                 p_noun     => l_bus_obj_name ,
       	                 p_verb     => p_action_code ,
			 p_type     => p_msg_type,
			 p_sender   => p_ref_sender,
			 p_msg_id   => p_ref_msg_id,
       	                 x_hdrxml   => l_hdrXML_str   ) ;

-- dbms_output.put_line(' generate header xml :' ||chr(10)||l_hdrXML_str );

     	l_hdrXML_len := length(l_hdrXML_str);
-- dbms_output.put_line(' getting length');
    	 dbms_lob.createtemporary( l_hdr_XML, true, dbms_lob.call);
-- dbms_output.put_line(' creating temp lob');
     	dbms_lob.write( l_hdr_XML, l_hdrXML_len, 1, l_hdrXML_str);
-- dbms_output.put_line(' after writting to lob');

/*  Set bind variables                                      */


 	--DBMS_XMLQUERY.clearBindValues;

 	FOR sql_bind IN sql_bind_data(p_bind_data_id)  LOOP
	    DBMS_XMLQUERY.setBindValue( queryCtx,sql_bind.bind_name, sql_bind.bind_value );
 	END LOOP;

    DBMS_XMLQUERY.setRowSetTag( ctxHdl => queryCtx, Tag  => 'DATAAREA');
   DBMS_XMLQUERY.setMetaHeader( ctxHdl => queryCtx, Header => l_hdr_DTD);
   DBMS_XMLQUERY.setDataHeader( ctxHdl => queryCtx, Header => l_hdr_XML,
            		       Tag => 'BUS_OBJ');


/*
 begin
  loop
    dbms_lob.read(l_msg_SQL,amount,position,charstr);
    dbms_output.put_line(charstr);
    position := position + amount;
  end loop;
 exception
     when NO_DATA_FOUND then
          null;
end;

     dbms_lob.createtemporary( l_msg_SQL_lob, true, dbms_lob.call);
     l_msg_SQL_len := dbms_lob.getlength(l_msg_SQL);
     dbms_lob.copy( l_msg_SQL_lob, l_msg_SQL, l_msg_SQL_len, 1, 1);
*/


     l_msg_XML := DBMS_XMLQUERY.getXML ( ctxHdl => queryCtx,
				  metatype => DBMS_XMLQUERY.DTD);


/*
position := 1;
 begin
  loop
    dbms_lob.read(l_msg_XML,amount,position,charstr);
    dbms_output.put_line(charstr);
    position := position + amount;
  end loop;
 exception
     when NO_DATA_FOUND then
          null;
end;
*/

-- dbms_output.put_line(' before queue message');

/* JTF_Message.Queue_Message routine enqueues the message in message queue */

   if ( p_timeout = 0 ) then

	JTF_Message.Queue_Message( p_prod_code => p_prod_code,
                          	   p_bus_obj_code => p_bus_obj_code,
                         	   p_bus_obj_name => p_bus_obj_name,
       			           p_correlation  => p_correlation,
	             		   p_message	  => l_msg_XML     );
   else
                    /* To take care of sync req/reply scenario */
                Queue_Sync_Msg(
				   p_prod_code => p_prod_code,
                                   p_bus_obj_code => p_bus_obj_code,
                                   p_bus_obj_name => p_bus_obj_name,
                                   p_correlation  => p_correlation,
                                   p_msg_XML      => l_msg_XML     );
   end if;
-- dbms_output.put_line(' after queue message');

/*	Purge Bind data table   */
	JTF_USR_HKS.Purge_Bind_Data( p_bind_data_id => p_bind_data_id,
				     p_bind_type   => 'S'
				    );

End Publish_Message;


Procedure get_prod_info( p_apps_short_name     varchar2,
                         x_schema        Out NOCOPY varchar2 ) IS
 l_schema  varchar2(30);
 l_status  varchar2(1);
 l_industry varchar2(1);
begin
    if ( FND_INSTALLATION.get_app_info(	p_apps_short_name, l_status, l_industry,
					l_schema  )  )  then
	x_schema := l_schema;
    else
	raise_application_error(-20000, 'Failed to get Info for Product'||
			         p_apps_short_name );
    end if;
end get_prod_info;


Procedure  Stage_Message(
			p_prod_code     Varchar2,
                        p_bus_obj_code  Varchar2,
                        p_action_code   Varchar2,
                        p_correlation   Varchar2,
                        p_bind_data_id  Number
			      ) IS

 l_stage_obj	       SYSTEM.JTF_STAGING_MSG_OBJ :=
		   		SYSTEM.JTF_STAGING_MSG_OBJ( null,null,
							    null,null,
							    0,null );
 l_enqueue_options     dbms_aq.enqueue_options_t;
 l_message_properties  dbms_aq.message_properties_t;
 l_Qname	       Varchar2(55) := 'JTF_STAGING_MSG_QUEUE';
 l_msg_id	       RAW(16);
 l_schema	       Varchar2(30);

Begin

    get_prod_info( 'JTF', l_schema);

    l_Qname := l_schema||'.'||l_Qname;

    l_stage_obj.prod_code    := p_prod_code;
    l_stage_obj.bus_obj_code := p_bus_obj_code;
    l_stage_obj.action_code  := p_action_code;
    l_stage_obj.correlation  := p_correlation;
    l_stage_obj.bind_data_id := p_bind_data_id;

    dbms_aq.enqueue(    queue_name         => l_Qname ,
   			enqueue_options    => l_enqueue_options ,
   			message_properties => l_message_properties ,
   			payload            => l_stage_obj ,
   			msgid              => l_msg_id );
Exception
	When OTHERS then
		JTF_USR_HKS.Handle_msg_Excep(
			p_prod_code    => p_prod_code,
                        p_bus_obj_code => p_bus_obj_code ,
                        p_action_code  => p_action_code ,
                        p_correlation  => p_correlation ,
                        p_bind_data_id => p_bind_data_id ,
    			p_msg_type     => 'O' ,
                        p_err_msg      => 'Error in writting to stage Queue' );
End   Stage_Message;


Procedure  Handle_msg_Excep(
			p_prod_code      Varchar2,
                        p_bus_obj_code   Varchar2,
                        p_action_code    Varchar2,
                        p_correlation    Varchar2,
                        p_bind_data_id   Number,
    			p_msg_type       Varchar2,
                        p_err_msg        Varchar2    ) Is

 l_excep_obj	       SYSTEM.JTF_EXCEP_MSG_OBJ :=
		   		SYSTEM.JTF_EXCEP_MSG_OBJ( null,null,
						          null,null,
						          0,null,null );
 l_enqueue_options     dbms_aq.enqueue_options_t;
 l_message_properties  dbms_aq.message_properties_t;
 l_Qname	       Varchar2(55) := 'JTF_EXCEP_MSG_QUEUE';
 l_msg_id	       RAW(16);
 l_schema              varchar2(30);
Begin


    get_prod_info( 'JTF', l_schema);

    l_Qname := l_schema||'.'||l_Qname;

    l_excep_obj.prod_code    := p_prod_code;
    l_excep_obj.bus_obj_code := p_bus_obj_code;
    l_excep_obj.action_code  := p_action_code;
    l_excep_obj.correlation  := p_correlation;
    l_excep_obj.bind_data_id := p_bind_data_id;
    l_excep_obj.msg_type     := p_msg_type;
    l_excep_obj.err_msg      := p_err_msg;

    l_message_properties.correlation := p_correlation;

    dbms_aq.enqueue(    queue_name         => l_Qname ,
   			enqueue_options    => l_enqueue_options ,
   			message_properties => l_message_properties ,
   			payload            => l_excep_obj ,
   			msgid              => l_msg_id );

End  Handle_msg_Excep;


END jtf_usr_hks;

/
