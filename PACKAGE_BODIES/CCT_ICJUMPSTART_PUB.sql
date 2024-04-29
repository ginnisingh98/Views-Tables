--------------------------------------------------------
--  DDL for Package Body CCT_ICJUMPSTART_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_ICJUMPSTART_PUB" as
/* $Header: cctjumpb.pls 120.2 2005/07/22 16:31:25 appldev noship $ */

Procedure CreateICAgent(
	 p_LAST_NAME IN VARCHAR2
	,p_FIRST_NAME IN VARCHAR2 Default NULL
	,p_MIDDLE_NAME IN VARCHAR2 Default NULL
	,p_Agent_SEX IN VARCHAR2 Default 'M'
	,p_APP_USERNAME IN VARCHAR2
	,p_IC_ROLE IN VARCHAR2 Default 'CALL_CENTER_AGENT'
	,p_IC_SERVER_GROUP_ID IN NUMBER
	,p_middleware_config_id IN NUMBER Default NULL
	,p_ACD_AGENT_ID IN VARCHAR2 Default NULL
	,p_ACD_AGENT_PASSWORD IN VARCHAR2 Default Null
	,p_acd_queue IN VARCHAR2 Default NULL
	,p_Resource_ID	OUT nocopy  NUMBER
	,x_Return_Status OUT nocopy  VARCHAR2
	,p_commit	IN VARCHAR2 DEFAULT FND_API.G_FALSE
	,p_init_msg_list IN VARCHAR2 Default FND_API.G_FALSE
	,x_msg_count 	OUT nocopy  NUMBER
	,x_message_data OUT  nocopy VARCHAR2
	,x_user_password OUT nocopy  VARCHAR2
) IS

	l_agent_title VARCHAR2(5):='MR.';
	p_sql_result Number;
	l_date DATE;
	l_sales_credit_type_id Number;
	l_user_password VARCHAR2(32):='WELCOME';
	l_role_resource_type VARCHAR2(32):='RS_INDIVIDUAL';
	l_role_type_code VARCHAR2(32):='CALLCENTER';
	l_role_name VARCHAR2(32):='Call Center Agent';
	l_role_id Number;
	l_middleware_type_id Number;
	l_agent_param_id Number;
	l_agent_param_name VARCHAR2(32);
	l_agent_param_value VARCHAR2(32);
	l_agent_param_value_id Number;
	l_role_relate_id Number;
	l_chgpwd_status Boolean;
Begin

    -- Init message list
    IF FND_API.to_Boolean(p_init_msg_list) THEN
    	FND_MSG_PUB.initialize;
    END IF;

    -- Init Return status
	x_Return_Status:=FND_API.G_RET_STS_SUCCESS;


	-- Check if all the required parameters are not null
	If (p_last_name is null) then
		x_Return_Status:=FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('CCT','CCT_JUMPSTART_NO_LAST_NAME');
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_AND_GET(
			p_count => x_msg_count,
			p_data => x_message_data,
			p_encoded => FND_API.G_FALSE);
		raise FND_API.G_EXC_UNEXPECTED_ERROR;
	End IF;

	-- Check if the Agent Sex is valid
	If ((p_Agent_Sex<>'M') AND (p_Agent_Sex <>'F')) Then
		x_Return_Status:=FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('CCT','CCT_JUMPSTART_INVALID_AGENT_SEX');
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_AND_GET(
			p_count=>x_msg_count,
			p_data =>x_message_data,
			p_encoded =>FND_API.G_FALSE);
		raise FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSE
		if (p_agent_Sex='M') then
			l_agent_title:='MR.';
		else
			l_agent_title:='MS.';
		end if;
	End IF;


	-- Check if the username has not been taken already
	If (p_app_username is not null) then
		Begin
			Select 1
			into p_sql_Result
			from fnd_user
			where user_name=p_app_username;
			If (p_sql_result=1) then
				x_Return_Status:=FND_API.G_RET_STS_ERROR;
				FND_MESSAGE.SET_NAME('CCT','CCT_JUMPSTART_USERNAME_ALREADY_EXISTS');
				FND_MSG_PUB.ADD;
				FND_MSG_PUB.Count_AND_GET(
					p_count=>x_msg_count,
					p_data =>x_message_data,
					p_encoded =>FND_API.G_FALSE);
				raise FND_API.G_EXC_UNEXPECTED_ERROR;
			End IF;
		Exception
			When no_data_found then
				null;
			When others then
				x_Return_Status:=FND_API.G_RET_STS_ERROR;
				FND_MESSAGE.SET_NAME('CCT','CCT_JUMPSTART_INVALID_USERNAME');
				FND_MSG_PUB.ADD;
				FND_MSG_PUB.Count_AND_GET(
					p_count=>x_msg_count,
					p_data =>x_message_data,
					p_encoded =>FND_API.G_FALSE);
				raise FND_API.G_EXC_UNEXPECTED_ERROR;
		End;
	Else
		x_Return_Status:=FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('CCT','CCT_JUMPSTART_INVALID_USERNAME');
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_AND_GET(
			p_count=>x_msg_count,
			p_data =>x_message_data,
			p_encoded =>FND_API.G_FALSE);
		raise FND_API.G_EXC_UNEXPECTED_ERROR;
	End IF;


	-- Check if the Agent Role is valid
	If ((p_ic_role<>'CALL_CENTER_AGENT') AND (p_ic_role<>'CALL_CENTER_MANAGER') AND (p_ic_Role <>'CALL_CENTER_SUPERVISOR')) Then
		x_Return_Status:=FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('CCT','CCT_JUMPSTART_INVALID_AGENT_ROLE');
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_AND_GET(
			p_count=>x_msg_count,
			p_data =>x_message_data,
			p_encoded =>FND_API.G_FALSE);
		raise FND_API.G_EXC_UNEXPECTED_ERROR;
	End IF;

	-- Check if the IC Server Group is valid
	Begin
		Select 1
		into p_sql_Result
		from IEO_SVR_GROUPS
		where Server_Group_ID=p_IC_SERVER_GROUP_ID;
	Exception
		When others then
			x_Return_Status:=FND_API.G_RET_STS_ERROR;
			FND_MESSAGE.SET_NAME('CCT','CCT_JUMPSTART_INVALID_SERVER_GROUP_ID');
			FND_MSG_PUB.ADD;
			FND_MSG_PUB.Count_AND_GET(
				p_count=>x_msg_count,
				p_data =>x_message_data,
				p_encoded =>FND_API.G_FALSE);
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
	End;

	-- Check if the Middleware_Config_ID is valid
	If (p_middleware_Config_id is not null) then
		Begin
		 	Select 1
		 	into p_sql_result
		 	from cct_middlewares
		 	where server_group_id=p_ic_server_Group_id
		 	and middleware_id=p_middleware_config_id
		 	and nvl(f_deletedflag,'N') <> 'D';
		Exception
			When others then
				x_Return_Status:=FND_API.G_RET_STS_ERROR;
				FND_MESSAGE.SET_NAME('CCT','CCT_JUMPSTART_INVALID_MIDDLEWARE_CONFIG_ID');
				FND_MSG_PUB.ADD;
				FND_MSG_PUB.Count_AND_GET(
					p_count=>x_msg_count,
					p_data =>x_message_data,
					p_encoded =>FND_API.G_FALSE);
				raise FND_API.G_EXC_UNEXPECTED_ERROR;
		End;
	End IF;

	-- Get the current date
	Select trunc(sysdate)
	into l_date
	from dual;

	-- Get a default Sales_credit_type
	Select sales_credit_Type_id
	into l_sales_credit_type_id
	from oe_sales_credit_types
	where rownum<2;

	--  Now create the damn agent
--	rem dbms_output.put_line('Creating resource='||p_last_name||', '||p_first_name);

	jtf_rs_res_sswa_pub.Create_Emp_Resource(
		 p_API_VERSION => 1
		,p_source_last_name =>p_last_name
		,p_source_first_name =>p_first_name
		,p_source_middle_name =>p_middle_name
		,p_source_sex =>p_agent_sex
		,p_source_title =>l_agent_title
	    ,p_source_start_date => l_date
	    ,p_user_name=>p_app_username
	    ,p_salesrep_number=>p_app_username /*pass the same value as user name , doesn't matter */
	    ,p_sales_credit_type_id=>l_sales_credit_type_id
	    ,x_resource_id => p_resource_id
	    ,x_return_status =>x_Return_Status
	    ,x_msg_count=>x_msg_count
	    ,x_msg_data=>x_message_data
	    ,p_user_password =>l_user_password
	);
--	rem dbms_output.put_line('Created resource='||p_last_name||', '||p_first_name);
	x_user_password:=l_user_password;

	If (x_Return_Status=FND_API.G_RET_STS_ERROR) Then
--		rem dbms_output.put_line('Error in creating resource');
		x_Return_Status:=FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('CCT','CCT_JUMPSTART_ERROR_FROM_RS_API');
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_AND_GET(
			p_count=>x_msg_count,
			p_data =>x_message_data,
			p_encoded =>FND_API.G_FALSE);
		raise FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

    Begin
        Update JTF_RS_RESOURCE_EXTNS
        set server_group_id=p_ic_server_Group_id
 		where resource_id=p_resource_id;
 	Exception
 		When others then
--			rem dbms_output.put_line('Error in updating resource');
			x_Return_Status:=FND_API.G_RET_STS_ERROR;
			FND_MESSAGE.SET_NAME('CCT','CCT_JUMPSTART_ERROR_FROM_RS_SG');
			FND_MSG_PUB.ADD;
			FND_MSG_PUB.Count_AND_GET(
				p_count=>x_msg_count,
				p_data =>x_message_data,
				p_encoded =>FND_API.G_FALSE);
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
 	End;

    -- Add CCT Web Admin, Telesales Agent, Customer Care responsibilities to
    -- agent
    Begin
	    fnd_user_pkg.addresp(upper(p_app_username),'CCT','CCT_WEB_ADMIN'
	    					,'STANDARD'
	    					,'Call Center Admin'
	    					,sysdate
	    					,null);
  	Exception
  	  	when others then
			FND_MSG_PUB.Count_AND_GET(
				p_count=>x_msg_count,
				p_data =>x_message_data,
				p_encoded =>FND_API.G_FALSE);
			--raise FND_API.G_EXC_UNEXPECTED_ERROR;
--  	  		rem dbms_output.put_line('Error Creating Call Center Responsibility:'||x_message_data);
  	end;
    Begin
		fnd_user_pkg.addresp(upper(p_app_username),'AST','AST_TELEAGENT'
	    					,'STANDARD'
	    					,'Telesales Agent'
	    					,sysdate
	    					,null);
  	Exception
  	  	when others then
			FND_MSG_PUB.Count_AND_GET(
				p_count=>x_msg_count,
				p_data =>x_message_data,
				p_encoded =>FND_API.G_FALSE);
			--raise FND_API.G_EXC_UNEXPECTED_ERROR;
--  	  		rem dbms_output.put_line('Error Creating Telesales Responsibility:'||x_message_data);
  	end;
    Begin
	    fnd_user_pkg.addresp(upper(p_app_username),'CSS','ORACLE_SUPPORT'
	    					,'STANDARD'
	    					,'Customer Support Agent'
	    					,sysdate
	    					,null);
  	Exception
  	  	when others then
			FND_MSG_PUB.Count_AND_GET(
				p_count=>x_msg_count,
				p_data =>x_message_data,
				p_encoded =>FND_API.G_FALSE);
			--raise FND_API.G_EXC_UNEXPECTED_ERROR;
--  	  		rem dbms_output.put_line('Error Creating CCare Responsibility'||x_message_data);
  	end;
--	rem dbms_output.put_line('Added responsibilities for '||p_last_name||', '||p_first_name);

	-- Reset Password to 'WELCOME'

	l_chgpwd_status:=fnd_user_pkg.changepassword(p_app_username,'WELCOME');
	x_user_password:='WELCOME';

	-- Define Agent Role



	if(p_ic_role='CALL_CENTER_MANAGER') then
		l_role_name:='Call Center Manager';
	elsif (p_ic_role='CALL_CENTER_SUPERVISOR') then
		l_role_name:='Call Center Supervisor';
	end if;

	Select role_id
	into l_role_id
	from jtf_rs_roles_Vl
	where role_code=p_ic_role
	and role_type_code='CALLCENTER';

    jtf_rs_role_relate_pub.create_resource_role_relate(
		 p_api_version => 1
		,p_role_resource_Type => l_role_resource_type
		,p_role_resource_id => p_resource_id
		,p_role_code =>p_ic_role
		,p_role_id =>l_role_id
		,p_start_date_active =>l_date
	    ,x_return_status =>x_Return_Status
	    ,x_msg_count=>x_msg_count
	    ,x_msg_data=>x_message_data
	    ,x_role_relate_id =>l_role_relate_id
	);

--	rem dbms_output.put_line('Added Call Center Resource Role for '||p_last_name||', '||p_first_name);

	If (x_Return_Status=FND_API.G_RET_STS_ERROR) Then
		x_Return_Status:=FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('CCT','CCT_JUMPSTART_ERROR_FROM_RS_ROLES_API');
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_AND_GET(
			p_count=>x_msg_count,
			p_data =>x_message_data,
			p_encoded =>FND_API.G_FALSE);
		raise FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	If (p_middleware_config_id is not null) then
--		rem dbms_output.put_line('Adding Agent Parameter Values for '||p_last_name||', '||p_first_name);
		Select middleware_type_id
		into l_middleware_type_id
		from cct_middlewares
		where middlewaRE_id=p_middleware_config_id;

		If (p_acd_queue is not null) then
			l_agent_param_name:='ACD_QUEUE';
			l_agent_param_value:=p_acd_queue;

			Begin
				Select resource_param_id
				into l_agent_param_id
				from jtf_rs_resource_params
				where name =l_agent_param_name
				and param_type=l_middleware_type_id;

				--Create the resource value now

				jtf_rs_resource_values_pub.Create_rs_Resource_values(
					 p_api_version => 1
					,p_resource_id => p_resource_id
					,p_resource_param_id =>l_agent_param_id
					,p_value =>l_agent_param_value
					,p_value_type =>p_middleware_config_id
				    ,x_return_status =>x_Return_Status
				    ,x_msg_count=>x_msg_count
				    ,x_msg_data=>x_message_data
				    ,x_resource_param_value_id=>l_agent_param_value_id
				);
				If (x_Return_Status=FND_API.G_RET_STS_ERROR) Then
					x_Return_Status:=FND_API.G_RET_STS_ERROR;
					FND_MESSAGE.SET_NAME('CCT','CCT_JUMPSTART_ERROR_FROM_RS_VALUES_API_'||l_agent_param_name);
					FND_MSG_PUB.ADD;
					FND_MSG_PUB.Count_AND_GET(
						p_count=>x_msg_count,
						p_data =>x_message_data,
						p_encoded =>FND_API.G_FALSE);
					raise FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;

			Exception
				When others then
					x_Return_Status:=FND_API.G_RET_STS_ERROR;
					FND_MESSAGE.SET_NAME('CCT','CCT_JUMPSTART_ERROR_FROM_RS_VALUES_'||l_agent_param_name);
					FND_MSG_PUB.ADD;
					FND_MSG_PUB.Count_AND_GET(
						p_count=>x_msg_count,
						p_data =>x_message_data,
						p_encoded =>FND_API.G_FALSE);
					raise FND_API.G_EXC_UNEXPECTED_ERROR;
			End;
		End If;

		If (p_acd_agent_id is not null) then
			l_agent_param_name:='ACD_AGENT_ID';
			l_agent_param_value:=p_acd_Agent_id;

			Begin
				Select resource_param_id
				into l_agent_param_id
				from jtf_rs_resource_params
				where name =l_agent_param_name
				and param_type=l_middleware_type_id;

				--Create the resource value now

				jtf_rs_resource_values_pub.Create_rs_Resource_values(
					 p_api_version => 1
					,p_resource_id => p_resource_id
					,p_resource_param_id =>l_agent_param_id
					,p_value =>l_agent_param_value
					,p_value_type =>p_middleware_config_id
				    ,x_return_status =>x_Return_Status
				    ,x_msg_count=>x_msg_count
				    ,x_msg_data=>x_message_data
				    ,x_resource_param_value_id=>l_agent_param_value_id
				);
				If (x_Return_Status=FND_API.G_RET_STS_ERROR) Then
					x_Return_Status:=FND_API.G_RET_STS_ERROR;
					FND_MESSAGE.SET_NAME('CCT','CCT_JUMPSTART_ERROR_FROM_RS_VALUES_API_'||l_agent_param_name);
					FND_MSG_PUB.ADD;
					FND_MSG_PUB.Count_AND_GET(
						p_count=>x_msg_count,
						p_data =>x_message_data,
						p_encoded =>FND_API.G_FALSE);
					raise FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;

			Exception
				When others then
					x_Return_Status:=FND_API.G_RET_STS_ERROR;
					FND_MESSAGE.SET_NAME('CCT','CCT_JUMPSTART_ERROR_FROM_RS_VALUES_'||l_agent_param_name);
					FND_MSG_PUB.ADD;
					FND_MSG_PUB.Count_AND_GET(
						p_count=>x_msg_count,
						p_data =>x_message_data,
						p_encoded =>FND_API.G_FALSE);
					raise FND_API.G_EXC_UNEXPECTED_ERROR;
			End;
		End If;

		If (p_acd_agent_password is not null) then
			l_agent_param_name:='ACD_AGENT_PASSWORD';
			l_agent_param_value:=p_acd_Agent_password;

			Begin
				Select resource_param_id
				into l_agent_param_id
				from jtf_rs_resource_params
				where name =l_agent_param_name
				and param_type=l_middleware_type_id;

				--Create the resource value now

				jtf_rs_resource_values_pub.Create_rs_Resource_values(
					 p_api_version => 1
					,p_resource_id => p_resource_id
					,p_resource_param_id =>l_agent_param_id
					,p_value =>l_agent_param_value
					,p_value_type =>p_middleware_config_id
				    ,x_return_status =>x_Return_Status
				    ,x_msg_count=>x_msg_count
				    ,x_msg_data=>x_message_data
				    ,x_resource_param_value_id=>l_agent_param_value_id
				);
				If (x_Return_Status=FND_API.G_RET_STS_ERROR) Then
					x_Return_Status:=FND_API.G_RET_STS_ERROR;
					FND_MESSAGE.SET_NAME('CCT','CCT_JUMPSTART_ERROR_FROM_RS_VALUES_API_'||l_agent_param_name);
					FND_MSG_PUB.ADD;
					FND_MSG_PUB.Count_AND_GET(
						p_count=>x_msg_count,
						p_data =>x_message_data,
						p_encoded =>FND_API.G_FALSE);
					raise FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;

			Exception
				When others then
					x_Return_Status:=FND_API.G_RET_STS_ERROR;
					FND_MESSAGE.SET_NAME('CCT','CCT_JUMPSTART_ERROR_FROM_RS_VALUES_'||l_agent_param_name);
					FND_MSG_PUB.ADD;
					FND_MSG_PUB.Count_AND_GET(
						p_count=>x_msg_count,
						p_data =>x_message_data,
						p_encoded =>FND_API.G_FALSE);
					raise FND_API.G_EXC_UNEXPECTED_ERROR;
			End;
		End If;

	End If;
Exception
    When others then
--        rem dbms_output.put_line('Error='||x_message_data||sqlerrm);
        null;

End;

Procedure CreateServerGroup(
	 p_server_Group_Name In Varchar2
	,x_return_Status OUT nocopy  VARCHAR2
	,p_commit	IN VARCHAR2 DEFAULT FND_API.G_FALSE
	,p_init_msg_list IN VARCHAR2 Default FND_API.G_FALSE
	,x_msg_count 	OUT  nocopy NUMBER
	,x_message_data OUT  nocopy VARCHAR2
	,x_Server_group_id Out  nocopy Number
) IS

 	x_sql_Result Number;
	l_server_group_id Number;
Begin

    -- Init message list
    IF FND_API.to_Boolean(p_init_msg_list) THEN
    	FND_MSG_PUB.initialize;
    END IF;

    -- Init Return status
	x_return_status:=FND_API.G_RET_STS_SUCCESS;

	-- Check if the Server Group already exists
	Begin
		Select 1
		into x_sql_Result
		from ieo_svr_groups
		where group_name=p_server_Group_name;
		If (x_sql_result=1) then
			x_return_status:=FND_API.G_RET_STS_ERROR;
			FND_MESSAGE.SET_NAME('CCT','CCT_JUMPSTART_ERROR_SERVER_GROUP_EXISTS');
			FND_MSG_PUB.ADD;
			FND_MSG_PUB.Count_AND_GET(
				p_count=>x_msg_count,
				p_data =>x_message_data,
				p_encoded =>FND_API.G_FALSE);
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
		End if;
	Exception
		When No_data_found then
			Select IEO_SVR_GROUPS_S1.nextval
			into l_server_Group_id
			from dual;
			Insert into IEO_SVR_GROUPS
			(Server_group_id,Group_name,Location,Description
			 ,created_by,Creation_Date,last_updateD_by,last_update_date)
			values(l_server_Group_id,p_server_group_name,p_server_group_name,p_server_group_name
			 ,1,sysdate,1,sysdate);
			x_server_group_id:=l_server_group_id;
		When others then
			x_Return_Status:=FND_API.G_RET_STS_ERROR;
			FND_MESSAGE.SET_NAME('CCT','CCT_JUMPSTART_ERROR_SERVER_GROUP_EXISTS');
			FND_MSG_PUB.ADD;
			FND_MSG_PUB.Count_AND_GET(
				p_count=>x_msg_count,
				p_data =>x_message_data,
				p_encoded =>FND_API.G_FALSE);
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
	End;
Exception
	When others then
			x_Return_Status:=FND_API.G_RET_STS_ERROR;
			FND_MESSAGE.SET_NAME('CCT','CCT_JUMPSTART_ERROR_SERVER_GROUP_EXISTS');
			FND_MSG_PUB.ADD;
			FND_MSG_PUB.Count_AND_GET(
				p_count=>x_msg_count,
				p_data =>x_message_data,
				p_encoded =>FND_API.G_FALSE);
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
End;


Procedure CreateAllServers(
     p_server_group_id In Number
    ,p_call_center_type IN VARCHAR2 DEFAULT NULL
	,x_return_Status OUT  nocopy VARCHAR2
	,p_commit	IN VARCHAR2 DEFAULT FND_API.G_FALSE
	,p_init_msg_list IN VARCHAR2 Default FND_API.G_FALSE
	,x_msg_count 	OUT  nocopy NUMBER
	,x_message_data OUT  nocopy VARCHAR2
	,x_SERVERTYPEID_SERVERID OUT  nocopy CCT_KEYVALUE_VARR
)
IS
   l_server_group_name VARCHAR2(255);
   l_SERVERTYPEID_SERVERID CCT_KEYVALUE_VARR:= CCT_KEYVALUE_VARR();
   l_result VARCHAR2(255);
   Cursor c_server_type
   is
   Select IEO_SVR_SERVERS_S1.nextval server_id,Type_id,decode(type_id,10000,'_UWQ'
                                ,10001,'_OTM'
                                ,10080,'_ORS'
                                ,10110,'_IQD'
                                ,10090,'_ITS'
                                ,10120,'_SS'
                                ,10160,'_OTAS') type_name,Type_Description
   from ieo_svr_types_tl
   where type_id in (10000,10001,10080,10110,10090,10120,10160);
Begin
   Select Group_name
   into l_server_group_name
   from ieo_svr_groups
   where server_group_id=p_server_Group_id;
   For v_server in c_server_type Loop
      Insert into ieo_svr_servers
      (Server_id,type_id,server_name,member_Svr_group_id,description,
       creation_date,created_By,last_update_date,last_updated_by)
      Select v_server.server_id,v_server.type_id,l_server_group_name||v_server.type_name
             ,p_server_group_id,v_server.type_description,
             sysdate,1,sysdate,1 from dual
      where not exists (Select 1 from ieo_Svr_servers where
                        member_svr_group_id=p_server_group_id
                        and type_id=v_server.type_id);
      l_result:=CCT_COLLECTION_UTIL_PUB.PUT(l_SERVERTYPEID_SERVERID,v_server.type_id,v_server.server_id);
   END LOOP;
   x_servertypeid_serverid:=l_SERVERTYPEID_SERVERID;
Exception
	When others then
			x_Return_Status:=FND_API.G_RET_STS_ERROR;
			FND_MESSAGE.SET_NAME('CCT','CCT_JUMPSTART_ERROR_CREATING_SERVERS');
			FND_MSG_PUB.ADD;
			FND_MSG_PUB.Count_AND_GET(
				p_count=>x_msg_count,
				p_data =>x_message_data,
				p_encoded =>FND_API.G_FALSE);
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
END;

Procedure CreateServerParam(
    p_server_id In Number
    ,p_param_value IN CCT_KEYVALUE_VARR
	,p_commit	IN VARCHAR2 DEFAULT FND_API.G_FALSE
	,p_init_msg_list IN VARCHAR2 Default FND_API.G_FALSE
	,x_return_Status OUT nocopy  VARCHAR2
	,x_msg_count 	OUT nocopy  NUMBER
	,x_message_data OUT nocopy  VARCHAR2
)
IS
	l_type_id Number;
	l_param_id Number;
	l_param VARCHAR2(255);
	l_value VARCHAR2(255);
	l_value_id Number;
	l_keys CCT_KEY_VARR;
	l_counter Number;
	l_return_status VARCHAR2(32);
Begin
	Select type_id
	into l_type_id
	from ieo_svr_servers
	where server_id=p_server_id;

	l_keys:=CCT_COLLECTION_UTIL_PUB.GETKEYS(p_param_value);

	For l_counter in l_keys.FIRST..l_keys.LAST Loop
	   Begin
	       l_param:=l_keys(l_counter);
	       Select param_id
	       into l_param_id
	       from ieo_svr_params
	       where type_id=l_type_id
	       and param_name=l_param;

	       l_value:=CCT_COLLECTION_UTIL_PUB.GET(p_param_value,l_param,l_return_status);
--	       rem dbms_output.put_line('Inserting Server Param='||l_param||' value='||l_value||' for server_id='||to_char(p_server_id));

	       Select ieo_svr_values_s1.nextval
	       into l_value_id
	       from dual;

	       Insert into ieo_svr_values(value_id,server_id,param_id,value,value_index
	                     ,creation_date,created_by,last_update_date,last_updated_by)
	       Select l_value_id,p_server_id,l_param_id,l_value,0
	                     ,sysdate,1,sysdate,1 from dual
	        where not exists (Select 1 from ieo_svr_values
	                      where server_id=p_server_id and param_id=l_param_id);
	  Exception
	      When others then
	          null;
	  end;
	End loop;

Exception
	When OTHERS then
			x_Return_Status:=FND_API.G_RET_STS_ERROR;
			FND_MESSAGE.SET_NAME('CCT','CCT_JUMPSTART_ERROR_CREATING_MWARE_PARAMS');
			FND_MSG_PUB.ADD;
			FND_MSG_PUB.Count_AND_GET(
				p_count=>x_msg_count,
				p_data =>x_message_data,
				p_encoded =>FND_API.G_FALSE);
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
End;



Procedure CreateMiddlewareConfig(
 	p_server_group_id In Number
 	,p_middleware_type IN Varchar2
	,p_commit	IN VARCHAR2 DEFAULT FND_API.G_FALSE
	,p_init_msg_list IN VARCHAR2 Default FND_API.G_FALSE
	,x_return_Status OUT nocopy  VARCHAR2
	,x_msg_count 	OUT nocopy  NUMBER
	,x_message_data OUT nocopy  VARCHAR2
 	,x_middleware_id OUT nocopy  Number
)IS
	l_middleware_type_id Number;
	l_config_name Varchar2(255);
Begin
	Select Middleware_type_id
	into l_middleware_type_id
	from cct_middleware_types
	where middleware_type=p_middleware_type;

	Select Group_name||'_MW'
	into l_config_name
	from ieo_svr_Groups
	where server_group_id=p_server_Group_id;

	Select CCT_MIDDLEWARES_S.nextval
	into x_middleware_id
	from dual;

	Insert into CCT_Middlewares
	(Middleware_id,Config_Name,Server_Group_id,middleware_type_id
	 ,creation_Date,created_by,last_update_date,last_updated_by)
	Select x_middleware_id,l_config_name,p_server_group_id,l_middleware_type_id
	  ,sysdate,1,sysdate,1 from dual
	where not exists (Select 1 from cct_middlewares
	where server_group_id=p_server_Group_id and config_name=l_config_name);
Exception
	When No_Data_Found then
			x_Return_Status:=FND_API.G_RET_STS_ERROR;
			FND_MESSAGE.SET_NAME('CCT','CCT_JUMPSTART_ERROR_CREATING_MWARE_CONFIG');
			FND_MSG_PUB.ADD;
			FND_MSG_PUB.Count_AND_GET(
				p_count=>x_msg_count,
				p_data =>x_message_data,
				p_encoded =>FND_API.G_FALSE);
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
End;


Procedure GetMiddlewareConfigInfo(
	p_server_group_name In VARCHAR2 Default Null
	,p_server_group_id In Number Default Null
	,p_middleware_id In OUT nocopy  Number
	,x_return_status OUT nocopy  VARCHAR2
	,x_msg_count 	OUT nocopy  NUMBER
	,x_message_data OUT nocopy  VARCHAR2
	,x_config_name OUT nocopy  VARCHAR2
	,x_middleware_type OUT nocopy  VARCHAR2
	,x_param_value OUT nocopy CCT_KEYVALUE_VARR
)
IS
 l_server_group_id Number;
 l_mw VARCHAR2(255);
 l_mw_id Number;
 l_mw_type VARCHAR2(255);
 l_param VARCHAR2(255);
 l_value VARCHAR2(255);
 l_paramValue CCT_KEYVALUE_VARR:= CCT_KEYVALUE_VARR();
 l_result VARCHAR2(32);

 Cursor c_param_value(p_middleware_id Number)
 is
 	Select p.name,v.value
 	from cct_middleware_params p,cct_middleware_values v
 	where v.middleware_id=p_middleware_id
 	and nvl(v.f_deletedflag,'N')<>'D'
 	and v.middleware_param_id=p.middleware_param_id;
Begin
   	x_return_status:=FND_API.G_RET_STS_SUCCESS;
	If p_server_group_name is not null THEN
		Begin
		 	Select server_group_id
		 	into l_server_group_id
		 	from ieo_Svr_groups
		 	where group_name =p_server_Group_name;
		Exception
			When No_Data_Found then
				x_Return_Status:=FND_API.G_RET_STS_ERROR;
				x_message_data:='SERVER_GROUP_NOT_FOUND';
--			    rem dbms_output.put_line(x_message_data);
				raise FND_API.G_EXC_UNEXPECTED_ERROR;
		End;
	End if;

	If (p_server_group_id is not null) Then
		l_server_group_id:=p_server_group_id;
	End if;

	If l_server_group_id is not null Then
		Begin
			Select m.middleware_id,m.config_name,t.middleware_type
			into l_mw_id,l_mw,l_mw_type
			from cct_middlewares m,ieo_svr_servers s,ieo_svr_params p,ieo_svr_values v,cct_middleware_types t
			where s.type_id=10160
			and s.member_svr_group_id=l_server_group_id
			and v.server_id=s.server_id
			and v.param_id=p.param_id
			and p.param_name='TELE_MIDDLEWARE_CONFIG'
			and v.value=m.config_name
			and m.server_Group_id=s.member_svr_group_id
			and m.middleware_type_id=t.middleware_type_id;
		Exception
			When no_data_found then
				x_Return_Status:=FND_API.G_RET_STS_ERROR;
				x_message_data:='NO_MWARE_FOR_OTAS';
--			    rem dbms_output.put_line(x_message_data);
				raise FND_API.G_EXC_UNEXPECTED_ERROR;
			When others then
				x_Return_Status:=FND_API.G_RET_STS_ERROR;
				x_message_data:='ERROR_IN_MWARE_FOR_OTAS';
--			    rem dbms_output.put_line(x_message_data);
				raise FND_API.G_EXC_UNEXPECTED_ERROR;

		End;
	End if;

  	If(p_middleware_id is null) and (l_mw_id is not null) Then
  		p_middleware_id:=l_mw_id;
		x_config_name:=l_mw;
		x_middleware_type:=l_mw_type;
  	End if;

  	If p_middleware_id is not null Then
  		if (x_config_name is null) then
  			Select m.Config_name,t.middlewarE_type
  			into l_mw,l_mw_type
  			from cct_middlewares m,cct_middleware_types t
  			where m.middleware_id=p_middleware_id
  			and m.middleware_type_id=t.middleware_type_id;
  			x_config_name:=l_mw;
  			x_middleware_type:=l_mw_type;
  		End If;
		Open c_param_value(p_middleware_id);
		LOOP
		  Fetch c_param_Value into l_param,l_value;
		  l_result:=CCT_COLLECTION_UTIL_PUB.PUT(l_paramValue,l_param,l_value);
		  Exit When c_param_value%NOTFOUND;
		End loop;
		x_param_value:=l_paramValue;
	Else
		x_Return_Status:=FND_API.G_RET_STS_ERROR;
		x_message_data:='ERROR:MIDDLEWARE_CONFIG_PARAM_NOT_DEFINED';
--		rem dbms_output.put_line(x_message_data);
		raise FND_API.G_EXC_UNEXPECTED_ERROR;
	End if;
Exception
    When others then
		x_Return_Status:=FND_API.G_RET_STS_ERROR;
		x_message_data:='ERROR:INVALID_MWARE';
--	    rem dbms_output.put_line(x_message_data);
		raise FND_API.G_EXC_UNEXPECTED_ERROR;
End;

Procedure CreateTelesets(
	p_middleware_id In Number
	,p_teleset_type In Varchar2
	,p_start_teleset_number In Number
	,p_skip_by In Number Default 1
	,p_number_of_Telesets In Number
	,p_line1 In Number Default Null
	,p_line2 In Number Default Null
	,p_line3 In Number Default 9999
	,p_commit	IN VARCHAR2 DEFAULT FND_API.G_FALSE
	,p_init_msg_list IN VARCHAR2 Default FND_API.G_FALSE
	,x_return_Status OUT nocopy  VARCHAR2
	,x_msg_count 	OUT nocopy  NUMBER
	,x_message_data OUT nocopy  VARCHAR2
)
IS
   l_num_of_lines Number;
   l_teleset_type_id Number;
   l_teleset_id Number;
   l_counter Number;
   l_server_Group_id Number;
   l_teleset_hardware_number number;
   l_line1 number;
   l_line2 number;
   l_line3 number:=9999;
   l_line_id Number;
Begin
	Select teleset_type_id,number_of_line
	into l_teleset_type_id,l_num_of_lines
	from cct_teleset_Types
	where upper(teleset_type)=upper(p_teleset_type);

	Select server_group_id
	into l_server_group_id
	from cct_middlewares
	where middleware_id=p_middleware_id;


	l_teleset_hardware_number:=p_start_teleset_number;
	if(p_line1 is not null) then
	  l_line1:=p_line1;
     end if;
	if(p_line2 is not null) then
	  l_line2:=p_line2;
     end if;
	if(p_line3 is not null) then
	  l_line3:=p_line3;
     end if;
	For l_counter in 1..p_number_of_Telesets Loop
		Select CCT_Telesets_s.nextval
		into l_teleset_id
		from dual;
--        rem dbms_output.put_line('Creating Teleset='||to_char(l_teleset_hardware_number));
		Insert into CCT_TELESETS(TELESET_ID,Teleset_type_id,Teleset_Name,Teleset_hardwarE_number,Middleware_id,server_group_id
		                        ,creation_date,created_by,last_update_date,last_updated_by)
		Select l_teleset_id,l_teleset_type_id,l_teleset_hardware_number,l_teleset_hardware_number,p_middleware_id,l_server_group_id
		                        ,sysdate,1,sysdate,1
		from dual where not exists (Select 1 from cct_telesets where teleset_type_id=l_teleset_type_id
		                            and teleset_hardware_number=l_teleset_hardware_number and middlewarE_id=p_middleware_id);

	    If (upper(p_teleset_type)='LUCENT') THEN
	       For l_counter in 1..l_num_of_lines Loop
	       	 Select cct_lines_s.nextval
	       	 into l_line_id
	       	 from dual;
	       	 Insert into CCT_LINES(Line_id,Line_index,extension,teleset_id,
	       	 					   creation_date,created_by,last_update_date,last_updated_by)
	     	 Select l_line_id,l_counter,l_teleset_hardware_number,l_teleset_id,
	     	        sysdate,1,sysdate,1 from dual
	     	   where not exists (Select 1 from cct_lines where teleset_id=l_teleset_id
	     	                     and line_index=l_counter);
	       End Loop;

	    ELSIf (upper(p_teleset_type)='NORTEL') THEN
	       	 Insert into CCT_LINES(Line_id,Line_index,extension,teleset_id,
	       	 					   creation_date,created_by,last_update_date,last_updated_by)
	     	 Select CCT_LINES_S.nextval,1,l_line1,l_teleset_id,
	     	        sysdate,1,sysdate,1 from dual
	     	   where not exists (Select 1 from cct_lines where teleset_id=l_teleset_id
	     	                     and line_index=1);
	       	 Insert into CCT_LINES(Line_id,Line_index,extension,teleset_id,
	       	 					   creation_date,created_by,last_update_date,last_updated_by)
	     	 Select CCT_LINES_S.nextval,2,l_line2,l_teleset_id,
	     	        sysdate,1,sysdate,1 from dual
	     	   where not exists (Select 1 from cct_lines where teleset_id=l_teleset_id
	     	                     and line_index=2);
	       	 Insert into CCT_LINES(Line_id,Line_index,extension,teleset_id,
	       	 					   creation_date,created_by,last_update_date,last_updated_by)
	     	 Select CCT_LINES_S.nextval,3,l_line3,l_teleset_id,
	     	        sysdate,1,sysdate,1 from dual
	     	   where not exists (Select 1 from cct_lines where teleset_id=l_teleset_id
	     	                     and line_index=3);
	    	l_line1:=l_line1+p_skip_by;
	    	l_line2:=l_line2+p_skip_by;
	    End if;
	    l_teleset_hardware_number:=l_teleset_hardware_number+p_skip_by;
    End loop;

Exception
	When OTHERS then
			x_Return_Status:=FND_API.G_RET_STS_ERROR;
			FND_MESSAGE.SET_NAME('CCT','CCT_JUMPSTART_ERROR_CREATING_TELESETS');
			FND_MSG_PUB.ADD;
			FND_MSG_PUB.Count_AND_GET(
				p_count=>x_msg_count,
				p_data =>x_message_data,
				p_encoded =>FND_API.G_FALSE);
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
End;

Procedure CreateMwareParam(
	p_middleware_id In Number
    ,p_param_value IN CCT_KEYVALUE_VARR
	,p_commit	IN VARCHAR2 DEFAULT FND_API.G_FALSE
	,p_init_msg_list IN VARCHAR2 Default FND_API.G_FALSE
	,x_return_Status OUT nocopy  VARCHAR2
	,x_msg_count 	OUT nocopy  NUMBER
	,x_message_data OUT nocopy  VARCHAR2
) IS

	l_middleware_type_id Number;
	l_middleware_param_id Number;
	l_param VARCHAR2(255);
	l_value VARCHAR2(255);
	l_value_id Number;
	l_keys CCT_KEY_VARR;
	l_counter Number;
	l_return_status VARCHAR2(32);
Begin
	Select middleware_type_id
	into l_middleware_Type_id
	from cct_middlewares
	where middlewarE_id=p_middleware_id;
--	rem dbms_output.put_line('Creating Middleware Params for Middleware_id='||to_char(p_middleware_id));

	l_keys:=CCT_COLLECTION_UTIL_PUB.GETKEYS(p_param_value);

	For l_counter in l_keys.FIRST..l_keys.LAST Loop
	   Begin
	       l_param:=l_keys(l_counter);
	       Select middleware_param_id
	       into l_middleware_param_id
	       from cct_middleware_params
	       where middleware_type_id=l_middleware_type_id
	       and name=l_param;

	       l_value:=CCT_COLLECTION_UTIL_PUB.GET(p_param_value,l_param,l_return_status);
--	       rem dbms_output.put_line('Inserting Middleware Param='||l_param||' value='||l_value);
	       Select cct_middleware_values_s.nextval
	       into l_value_id
	       from dual;

	       Insert into ccT_middleware_values(middleware_value_id,middleware_id,middleware_param_id,value
	                     ,creation_date,created_by,last_update_date,last_updated_by)
	       Select l_value_id,p_middleware_id,l_middleware_param_id,l_value
	                     ,sysdate,1,sysdate,1 from dual
	        where not exists (Select 1 from cct_middleware_values
	                      where middleware_id=p_middleware_id and middleware_param_id=l_middleware_param_id
	                      and nvl(f_deletedflag,'N')<>'D');
	  Exception
	      When others then
	          null;
	  end;
	End loop;

Exception
	When OTHERS then
			x_Return_Status:=FND_API.G_RET_STS_ERROR;
			FND_MESSAGE.SET_NAME('CCT','CCT_JUMPSTART_ERROR_CREATING_MWARE_PARAMS');
			FND_MSG_PUB.ADD;
			FND_MSG_PUB.Count_AND_GET(
				p_count=>x_msg_count,
				p_data =>x_message_data,
				p_encoded =>FND_API.G_FALSE);
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
End;

Procedure CreateRoutePoint(
	p_middleware_id In Number
    ,p_route_point_number IN VARCHAR2
	,p_commit	IN VARCHAR2 DEFAULT FND_API.G_FALSE
	,p_init_msg_list IN VARCHAR2 Default FND_API.G_FALSE
	,x_return_Status OUT nocopy  VARCHAR2
	,x_msg_count 	OUT nocopy  NUMBER
	,x_message_data OUT nocopy  VARCHAR2
	,x_route_point_id OUT nocopy  NUMBER
)
IS
  l_route_point_id Number;
Begin
  Select CCT_MW_ROUTE_POINTS_S.nextval
  into l_route_point_id
  from dual;

  Insert into cct_mw_route_points(mw_route_point_id,middleware_id,route_point_number,description,
              object_version_number,creation_date,created_by,last_update_date,last_updated_By)
  Select l_route_point_id,p_middleware_id,p_route_point_number,p_route_point_number,
         1,sysdate,1,sysdate,1 from dual
         where not exists (Select 1 from cct_mw_route_points
                           where middleware_id=p_middleware_id and route_point_number=p_route_point_number
                           and nvl(f_deletedflag,'N')<>'D');
  x_route_point_id:=l_route_point_id;
Exception
	When OTHERS then
			x_Return_Status:=FND_API.G_RET_STS_ERROR;
			FND_MESSAGE.SET_NAME('CCT','CCT_JUMPSTART_ERROR_CREATING_ROUTE_POINT');
			FND_MSG_PUB.ADD;
			FND_MSG_PUB.Count_AND_GET(
				p_count=>x_msg_count,
				p_data =>x_message_data,
				p_encoded =>FND_API.G_FALSE);
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
End;

Procedure CreateRoutePointParams(
    p_route_point_id In Number
    ,p_param_value CCT_KEYVALUE_VARR
	,p_commit	IN VARCHAR2 DEFAULT FND_API.G_FALSE
	,p_init_msg_list IN VARCHAR2 Default FND_API.G_FALSE
	,x_return_Status OUT nocopy VARCHAR2
	,x_msg_count 	OUT nocopy NUMBER
	,x_message_data OUT nocopy VARCHAR2
)
IS
	l_param_id Number;
	l_param VARCHAR2(255);
	l_value VARCHAR2(255);
	l_value_id Number;
	l_keys CCT_KEY_VARR;
	l_counter Number;
	l_return_status VARCHAR2(32);
Begin
	l_keys:=CCT_COLLECTION_UTIL_PUB.GETKEYS(p_param_value);

	For l_counter in l_keys.FIRST..l_keys.LAST Loop
	   Begin
	       l_param:=l_keys(l_counter);
	       Select mw_route_point_param_id
	       into l_param_id
	       from cct_mw_route_point_params
	       where name=l_param;

	       l_value:=CCT_COLLECTION_UTIL_PUB.GET(p_param_value,l_param,l_return_status);

--	       rem dbms_output.put_line('Inserting Route Point Param='||l_param||' value='||l_value);
	       Select cct_mw_route_point_values_s.nextval
	       into l_value_id
	       from dual;

	       Insert into ccT_mw_route_point_values(mw_route_point_value_id,mw_route_point_id,mw_route_point_param_id,value
	                     ,object_version_number,creation_date,created_by,last_update_date,last_updated_by)
	       Select l_value_id,p_route_point_id,l_param_id,l_value
	                     ,1,sysdate,1,sysdate,1 from dual
	        where not exists (Select 1 from cct_mw_route_point_values
	                      where mw_route_point_id=p_route_point_id and mw_route_point_param_id=l_param_id
	                      and nvl(f_deletedflag,'N')<>'D');
	  Exception
	      When others then
	          null;
	  end;
	End loop;

Exception
	When OTHERS then
			x_Return_Status:=FND_API.G_RET_STS_ERROR;
			FND_MESSAGE.SET_NAME('CCT','CCT_JUMPSTART_ERROR_CREATING_ROUTE_POINT_PARAMS');
			FND_MSG_PUB.ADD;
			FND_MSG_PUB.Count_AND_GET(
				p_count=>x_msg_count,
				p_data =>x_message_data,
				p_encoded =>FND_API.G_FALSE);
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
End;

END CCT_ICJUMPSTART_PUB;

/
