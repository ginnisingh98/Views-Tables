--------------------------------------------------------
--  DDL for Package Body IEM_AGENT_ACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_AGENT_ACT_PVT" as
/* $Header: iemvagnb.pls 120.1.12010000.2 2009/07/14 09:09:35 shramana ship $*/
G_PKG_NAME CONSTANT varchar2(30) :='IEM_AGENT_ACT_PVT ';

PROCEDURE create_item (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			p_resource_id       IN  VARCHAR2,
			p_email_account_id         IN NUMBER,
			p_signature                IN  VARCHAR2,
			p_CREATED_BY    NUMBER,
          	p_CREATION_DATE    DATE,
         		p_LAST_UPDATED_BY    NUMBER,
          	p_LAST_UPDATE_DATE    DATE,
          	p_LAST_UPDATE_LOGIN    NUMBER,
         		p_ATTRIBUTE1    VARCHAR2,
          	p_ATTRIBUTE2    VARCHAR2,
          	p_ATTRIBUTE3    VARCHAR2,
          	p_ATTRIBUTE4    VARCHAR2,
          	p_ATTRIBUTE5    VARCHAR2,
          	p_ATTRIBUTE6    VARCHAR2,
          	p_ATTRIBUTE7    VARCHAR2,
          	p_ATTRIBUTE8    VARCHAR2,
          	p_ATTRIBUTE9    VARCHAR2,
          	p_ATTRIBUTE10    VARCHAR2,
          	p_ATTRIBUTE11    VARCHAR2,
          	p_ATTRIBUTE12    VARCHAR2,
          	p_ATTRIBUTE13    VARCHAR2,
          	p_ATTRIBUTE14    VARCHAR2,
          	p_ATTRIBUTE15    VARCHAR2,
		      x_return_status OUT NOCOPY VARCHAR2,
  		 	 x_msg_count	      OUT NOCOPY NUMBER,
	  	  	 x_msg_data OUT NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='create_item';
	l_api_version_number 	NUMBER:=1.0;
	l_seq_id		number;
	l_grp_cnt		number;
	l_stat		varchar2(20);
	l_count		number;
	l_data		varchar2(300);
	l_agent_account_id		number;
	l_CREATED_BY    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID'));
     l_LAST_UPDATED_BY    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
     l_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ ID')) ;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
select iem_agents_s1.nextval into l_agent_account_id
from dual;
INSERT INTO IEM_AGENTS (
AGENT_ID   ,
EMAIL_ACCOUNT_ID   ,
RESOURCE_ID        ,
SIGNATURE          ,
CREATED_BY          ,
CREATION_DATE       ,
LAST_UPDATED_BY     ,
LAST_UPDATE_DATE    ,
LAST_UPDATE_LOGIN   ,
ATTRIBUTE1          ,
ATTRIBUTE2          ,
ATTRIBUTE3          ,
ATTRIBUTE4          ,
ATTRIBUTE5          ,
ATTRIBUTE6          ,
ATTRIBUTE7        ,
ATTRIBUTE8        ,
ATTRIBUTE9        ,
ATTRIBUTE10       ,
ATTRIBUTE11       ,
ATTRIBUTE12       ,
ATTRIBUTE13       ,
ATTRIBUTE14       ,
ATTRIBUTE15
)
VALUES
(
l_AGENT_ACCOUNT_ID   ,
p_EMAIL_ACCOUNT_ID   ,
p_resource_id         ,
decode(p_SIGNATURE,FND_API.G_MISS_CHAR,NULL,p_signature),
	decode(p_CREATED_BY,null,-1,p_CREATED_BY),
	sysdate,
	decode(p_LAST_UPDATED_BY,null,-1,p_LAST_UPDATED_BY),
	sysdate,
	decode(p_LAST_UPDATE_LOGIN,null,-1,p_LAST_UPDATE_LOGIN),
	p_ATTRIBUTE1,
	p_ATTRIBUTE2,
	p_ATTRIBUTE3,
	p_ATTRIBUTE4,
	p_ATTRIBUTE5,
	p_ATTRIBUTE6,
	p_ATTRIBUTE7,
	p_ATTRIBUTE8,
	p_ATTRIBUTE9,
	p_ATTRIBUTE10,
	p_ATTRIBUTE11,
	p_ATTRIBUTE12,
	p_ATTRIBUTE13,
	p_ATTRIBUTE14,
	p_ATTRIBUTE15
 );

--Insert into Comp_Rt-Stats for Client cache to update.
--No error handling here.
IEM_COMP_RT_STATS_PVT.create_item(p_api_version_number =>1.0,
						p_init_msg_list => FND_API.G_FALSE,
						p_commit         => FND_API.G_FALSE,
						p_type => 'AGENT_ACCOUNT',
						p_param => 'CREATE',
						p_value => l_agent_account_id,
						x_return_status  => l_stat,
						x_msg_count      => l_count,
						x_msg_data      => l_data);

-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 	p_data  =>    x_msg_data
			);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
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

 END	create_item;

PROCEDURE delete_item (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_resource_id	in number,
				 p_email_account_id	in number,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='delete_item';
	l_api_version_number 	NUMBER:=1.0;

	l_agent_id		number;
	l_stat		varchar2(20);
	l_count		number;
	l_data		varchar2(300);

BEGIN
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   select agent_id into l_agent_id
   from IEM_AGENTS
   where resource_id=p_resource_id
   and email_account_id=p_email_account_id;

   delete from IEM_AGENTS
   where resource_id=p_resource_id
   and email_account_id=p_email_account_id;

   --Insert into Comp_Rt-Stats for Client cache to update.
   --No error handling here.
   IEM_COMP_RT_STATS_PVT.create_item(p_api_version_number =>1.0,
						p_init_msg_list => FND_API.G_FALSE,
						p_commit         => FND_API.G_FALSE,
						p_type => 'AGENT_ACCOUNT',
						p_param => 'DELETE',
						p_value => l_agent_id,
						x_return_status  => l_stat,
						x_msg_count      => l_count,
						x_msg_data      => l_data);

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
	ROLLBACK TO delete_item_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO delete_item_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO delete_item_PVT;
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

 END	delete_item;

 PROCEDURE create_agntacct_by_agent (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			      p_in_resource_tbl             IN  jtf_varchar2_Table_100,
			      p_email_account_id	in number,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='create_agntacct_by_agent';
	l_api_version_number 	NUMBER:=1.0;
	l_return_status	varchar2(10);
	l_msg_count	number;
	l_msg_data	varchar2(255);
	l_user_id JTF_RS_RESOURCE_EXTNS.USER_ID%TYPE;
	l_user_name JTF_RS_RESOURCE_EXTNS.USER_NAME%TYPE;
	l_res_name varchar2(720);
	l_resource_param_value_id NUMBER;
	l_agent_account_count NUMBER;
	l_error_agent_count   NUMBER:=0;
	l_error_username varchar2(32000);
	l_data_change Boolean := false;

BEGIN

SAVEPOINT create_agntacct_by_agent_PVT;
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

   x_return_status := FND_API.G_RET_STS_SUCCESS;

	 FOR i in 1..p_in_resource_tbl.count() LOOP

		SELECT USER_ID, USER_NAME, SOURCE_LAST_NAME || ', ' || SOURCE_FIRST_NAME as RESOURCE_NAME
		INTO l_user_id, l_user_name, l_res_name
		FROM JTF_RS_RESOURCE_EXTNS
		WHERE RESOURCE_ID = p_in_resource_tbl(i);


    		-- Check if the agent account already exist.  If exist, skip and fetch next resource id in the loop
    		select count(*) into l_agent_account_count from iem_agents where resource_id=p_in_resource_tbl(i)
    		and email_account_id=p_email_account_id;

    		IF (l_agent_account_count = 0) THEN

    			l_data_change := true;

				/*JTF_RS_RESOURCE_VALUES_PUB.CREATE_RS_RESOURCE_VALUES(
      					P_Api_Version => 1.0,
     	 				P_Init_Msg_List  => FND_API.G_FALSE,
      					P_Commit  => FND_API.G_FALSE,
      					P_resource_id => p_in_resource_tbl(i),
      					p_resource_param_id => 1,
      					p_value  => 'IEM_DEFAULT_VALUE',
      					P_value_type => p_email_account_id,
      					X_Return_Status => l_return_status,
      					X_Msg_Count => l_msg_count,
      					X_Msg_Data => l_msg_data,
      					X_resource_param_value_id => l_resource_param_value_id);

      				IF l_return_status='S' THEN
				*/

  	   				IEM_AGENT_ACT_PVT.create_item(p_api_version_number=>1.0,
 						p_init_msg_list=>'F' ,
						p_commit=>'F'	    ,
						p_resource_id=>p_in_resource_tbl(i),
						p_email_account_id=>p_email_account_id,
						p_signature=>null,
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
						x_msg_count=>l_msg_count,
						x_msg_data=>l_msg_data,
						x_return_status=>l_return_status);

					IF l_return_status<>'S' THEN
						if l_error_agent_count < 21 then
  	  						l_error_username := l_error_username || ' ' || l_user_name || ',';
  	  						l_error_agent_count := l_error_agent_count + 1;
  	  					end if;
					END IF;  -- IEM_AGENT_ACT_PVT
				/*ELSE
					if l_error_agent_count < 21 then
  	  					l_error_username := l_error_username || ' ' || l_user_name || ',';
  	  					l_error_agent_count := l_error_agent_count + 1;
  	  				end if;
				END IF;  -- JTF_RS_RESOURCE_VALUES_PUB
				*/
        			/*if l_error_agent_count < 21 then
  	  				l_error_username := l_error_username || ' ' || l_user_name || ',';
  	  				l_error_agent_count := l_error_agent_count + 1;
  	  			end if;
				*/
		END IF;

    	END LOOP;

    	if l_error_username is not null then
    			x_return_status := FND_API.G_RET_STS_ERROR;
            		l_error_username := RTRIM(l_error_username, ', ');

            		if l_error_agent_count > 20 then
            			l_error_username := l_error_username || '...';
            		end if;

    			FND_MESSAGE.SET_NAME('IEM', 'IEM_SSS_AGNTACCT1_CREATED');
    			FND_MESSAGE.SET_TOKEN('AGENT', l_error_username);
    			FND_MSG_PUB.ADD;
   	elsif l_data_change = false then
    		x_return_status := 'N';  -- indicate no data change
    	end if;

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
	ROLLBACK TO create_agntacct_by_agent_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO create_agntacct_by_agent_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO create_agntacct_by_agent_PVT;
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

 END create_agntacct_by_agent;


 PROCEDURE delete_agntacct_by_agent (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			      p_out_resource_tbl             IN  jtf_varchar2_Table_100,
			      p_email_account_id	in number,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='delete_agntacct_by_agent';
	l_api_version_number 	NUMBER:=1.0;
	l_return_status	varchar2(10);
	l_msg_count	number;
	l_msg_data	varchar2(255);
	l_user_id JTF_RS_RESOURCE_EXTNS.USER_ID%TYPE;
	l_user_name JTF_RS_RESOURCE_EXTNS.USER_NAME%TYPE;
	l_agntacct varchar2(160);
	l_res_name varchar2(720);
	l_error_username varchar2(32000);
	l_error_username1 varchar2(32000);
	l_error_username2 varchar2(32000);
	l_error_agent_count  number:=0;
	l_error_agent_count1  number:=0;
	l_error_agent_count2 number:=0;
	l_resource_param_value_id number;
    	l_object_version_number number;
    	l_agent_account_id NUMBER;
    	l_agent_account_count NUMBER;
    	l_email_count NUMBER;
    	l_compose_count  NUMBER;
    	l_process_count	 NUMBER;
    	l_data_change Boolean := false;
    	l_resource_param_count number;
    	l_account_name varchar2(210);
    	l_is_clean 	Boolean;


BEGIN
SAVEPOINT delete_agntacct_by_agent_PVT;
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

   x_return_status := FND_API.G_RET_STS_SUCCESS;


	FOR i in 1..p_out_resource_tbl.count() LOOP

		SELECT USER_ID, USER_NAME, SOURCE_LAST_NAME || ', ' || SOURCE_FIRST_NAME as RESOURCE_NAME
		INTO l_user_id, l_user_name, l_res_name
		FROM JTF_RS_RESOURCE_EXTNS
		WHERE RESOURCE_ID = p_out_resource_tbl(i);


           	-- Check if the agent account already non-exist.  If non-exist, skip and fetch next resource id in the loop
    		select count(*) into l_agent_account_count from iem_agents where resource_id=p_out_resource_tbl(i)
    		and email_account_id=p_email_account_id;

    		IF (l_agent_account_count <> 0) THEN

    			l_data_change := true;

			    -- Check any Agent inbox messages or composing messages or in-processing emails in Outbox Processor
				IEM_CLIENT_PUB.isAgentInboxClean(p_api_version_number=>1.0,
 					p_init_msg_list=>'F' ,
					p_commit=>'F'	    ,
					p_resource_id => p_out_resource_tbl(i),
					p_email_account_id => p_email_account_id,
					x_is_clean => l_is_clean,
					x_msg_count=>l_msg_count,
					x_msg_data=>l_msg_data,
					x_return_status=>l_return_status);

			 IF l_return_status<>'S' THEN
				if l_error_agent_count1 < 21 then
					l_error_username1 := l_error_username1 || ' ' || l_user_name || ',';
					l_error_agent_count1 := l_error_agent_count1 + 1;
				end if;
			 ELSE

			   IF (l_is_clean = false) THEN
			   	if l_error_agent_count2 < 21 then
					l_error_username2 := l_error_username2 || ' ' || l_user_name || ',';
					l_error_agent_count2 := l_error_agent_count2 + 1;
				end if;

    			   ELSE

    			   	IEM_AGENT_ACT_PVT.delete_item(p_api_version_number=>1.0,
 					p_init_msg_list=>'F' ,
					p_commit=>'F'	    ,
					p_resource_id => p_out_resource_tbl(i),
					p_email_account_id => p_email_account_id,
					x_msg_count=>l_msg_count,
					x_msg_data=>l_msg_data,
					x_return_status=>l_return_status);

      				IF l_return_status<>'S' THEN

  	   		/*	   select count(*) into l_resource_param_count from jtf_rs_resource_values
    		 		   where value_type=p_email_account_id and resource_id=p_out_resource_tbl(i) and value='IEM_DEFAULT_VALUE';

    			   	   if (l_resource_param_count > 0) then

    		 		   	select resource_param_value_id, object_version_number into l_resource_param_value_id, l_object_version_number from jtf_rs_resource_values
    		 		   	where value_type=p_email_account_id and resource_id=p_out_resource_tbl(i) and value='IEM_DEFAULT_VALUE';

				   	JTF_RS_RESOURCE_VALUES_PUB.DELETE_RS_RESOURCE_VALUES(
      						P_Api_Version => 1.0,
     	 					P_Init_Msg_List  => FND_API.G_FALSE,
      						P_Commit  => FND_API.G_FALSE,
      						p_resource_param_value_id => l_resource_param_value_id,
      						p_object_version_number => l_object_version_number,
      						X_Return_Status => l_return_status,
      						X_Msg_Count => l_msg_count,
      						X_Msg_Data => l_msg_data);

					IF l_return_status<>'S' THEN
						if l_error_agent_count < 21 then
  	  						l_error_username := l_error_username || ' ' || l_user_name || ',';
  	  						l_error_agent_count := l_error_agent_count + 1;
  	  					end if;
					END IF;  -- IF THEN - JTF_RS_RESOURCE_VALUES_PUB
				   end if; -- if (l_resource_param_count > 0) then
				ELSE
			*/		if l_error_agent_count < 21 then
  	  					l_error_username := l_error_username || ' ' || l_user_name || ',';
  	  					l_error_agent_count := l_error_agent_count + 1;
  	  				end if;
				END IF;  -- IF THEN - IEM_AGENT_ACT_PVT

			     END IF;  -- is inbox clean

			   END IF; -- IF THEN - IEM_CLIENT_PUB

    		END IF; -- l_agent_acount_account<>0

    	END LOOP;


    	if l_error_username is not null then
    		x_return_status := FND_API.G_RET_STS_ERROR;
            	l_error_username := RTRIM(l_error_username, ', ');

		if l_error_agent_count > 20 then
            		l_error_username := l_error_username || '...';
            	end if;

    		FND_MESSAGE.SET_NAME('IEM', 'IEM_SSS_AGNTACCT1_DELETED');
    		FND_MESSAGE.SET_TOKEN('AGENT', l_error_username);
    		FND_MSG_PUB.ADD;

    	end if;

    	if l_error_username1 is not null then
    		x_return_status := FND_API.G_RET_STS_ERROR ;
    		 l_error_username1 := RTRIM(l_error_username1, ', ');

		if l_error_agent_count1 > 20 then
            		l_error_username1 := l_error_username1 || '...';
            	end if;


    		 FND_MESSAGE.SET_NAME('IEM','IEM_SSS_AGNTACCT9_DELETED');
    		 FND_MESSAGE.SET_TOKEN('AGENT', l_error_username1);
    		 FND_MESSAGE.SET_TOKEN('ACCOUNT', l_account_name);
            	 FND_MSG_PUB.Add;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    	end if;

    	if l_error_username2 is not null then
    		x_return_status := FND_API.G_RET_STS_ERROR;
            	l_error_username2 := RTRIM(l_error_username2, ', ');

            	if l_error_agent_count2 > 20 then
            		l_error_username2 := l_error_username2 || '...';
            	end if;


    		FND_MESSAGE.SET_NAME('IEM', 'IEM_SSS_AGNTACCT5_DELETED');
    		FND_MESSAGE.SET_TOKEN('AGENT', l_error_username2);
    		FND_MESSAGE.SET_TOKEN('ACCOUNT', l_account_name);
    		FND_MSG_PUB.ADD;

    	end if;

    	if l_error_username is null and l_error_username1 is null and l_error_username2 is null and l_data_change=false then
    		x_return_status := 'N'; -- indicate no change in data
    	end if;

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
	ROLLBACK TO delete_agntacct_by_agent_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO delete_agntacct_by_agent_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO delete_agntacct_by_agent_PVT;
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

 END delete_agntacct_by_agent;


 PROCEDURE update_agntacct_by_agent_wrap (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
		    	      p_in_resource_tbl              IN  jtf_varchar2_Table_100,
			      p_out_resource_tbl             IN  jtf_varchar2_Table_100,
			      p_email_account_id	in number,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='update_agntacct_by_agent_wrap';
	l_api_version_number 	NUMBER:=1.0;
	l_return_status	varchar2(10);
	l_return_status1	varchar2(10):='';
	l_msg_count	number;
	l_msg_data	varchar2(255);

BEGIN
SAVEPOINT agntacct_by_agent_wrap;
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

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Check for existence of database link

    	-- Assign agents to account
    	iem_agent_act_pvt.create_agntacct_by_agent (p_api_version_number =>1.0,
 						p_init_msg_list=>'F' ,
						p_commit=>'F'	    ,
			      	p_in_resource_tbl  => p_in_resource_tbl,
			      	p_email_account_id => p_email_account_id,
			      	x_return_status =>l_return_status,
  				x_msg_count    => l_msg_count,
  				x_msg_data      => l_msg_data);

	IF l_return_status='N' THEN
  		l_return_status1 := 'N';
      	ELSIF l_return_status<>'S' and l_return_status<>'N' THEN
  	   	 x_return_status := FND_API.G_RET_STS_ERROR ;
       		FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
	END IF;

	-- Unassign agents from account
	iem_agent_act_pvt.delete_agntacct_by_agent (p_api_version_number =>1.0,
 						p_init_msg_list=>'F' ,
						p_commit=>'F'	    ,
			      	p_out_resource_tbl  => p_out_resource_tbl,
			      	p_email_account_id => p_email_account_id,
			      	x_return_status =>l_return_status,
  				x_msg_count    => l_msg_count,
  				x_msg_data      => l_msg_data);

  	IF l_return_status='N'and l_return_status1='N' THEN
  		x_return_status := 'N';
      	ELSIF l_return_status<>'S' and l_return_status<>'N' THEN
  	   	x_return_status := FND_API.G_RET_STS_ERROR ;
       		FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
	END IF;


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
   WHEN NO_DATA_FOUND THEN
            ROLLBACK TO agntacct_by_agent_wrap;
            FND_MESSAGE.SET_NAME('IEM','IEM_SSS_ACCOUNT_NOT_FOUND');
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO agntacct_by_agent_wrap;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO agntacct_by_agent_wrap;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO agntacct_by_agent_wrap;
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

 END update_agntacct_by_agent_wrap;


 PROCEDURE create_agntacct_by_account (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			      p_in_email_account_tbl             IN  jtf_varchar2_Table_100,
			      p_resource_id	in number,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='create_agntacct_by_account';
	l_api_version_number 	NUMBER:=1.0;
	l_return_status	varchar2(10);
	l_msg_count	number;
	l_msg_data	varchar2(255);
	l_email_user IEM_MSTEMAIL_ACCOUNTS.USER_NAME%TYPE;
	l_user_id JTF_RS_RESOURCE_EXTNS.USER_ID%TYPE;
	l_user_name JTF_RS_RESOURCE_EXTNS.USER_NAME%TYPE;
	l_agntacct varchar2(160);
	l_res_name varchar2(720);
	l_resource_param_value_id NUMBER;
	l_agent_account_count NUMBER;
	l_error_email_user varchar2(32000);
	l_count			NUMBER;
	l_error_account_count	NUMBER:=0;
	USER_NULL_ERROR		EXCEPTION;
	RESOURCE_INACTIVE_ERROR EXCEPTION;
	l_data_change Boolean := false;
	l_account_count		number;

BEGIN

SAVEPOINT create_agntacct_by_account_PVT;
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

   x_return_status := FND_API.G_RET_STS_SUCCESS;

	SELECT USER_ID, USER_NAME, SOURCE_LAST_NAME || ', ' || SOURCE_FIRST_NAME as RESOURCE_NAME
		INTO l_user_id, l_user_name, l_res_name
		FROM JTF_RS_RESOURCE_EXTNS
		WHERE RESOURCE_ID = p_resource_id;

	if (l_user_name is null or l_user_name = '') then
		raise USER_NULL_ERROR;
	end if;

	SELECT count(*) into l_count
	FROM jtf_rs_resource_extns
	WHERE resource_id = p_resource_id
        AND ( end_date_active is null OR
		    trunc(end_date_active) >= trunc(sysdate) );

	if (l_count = 0) then
		raise RESOURCE_INACTIVE_ERROR;
	end if;

	 FOR i in 1.. p_in_email_account_tbl.count() LOOP

   	    select count(*) into l_account_count FROM IEM_MSTEMAIL_ACCOUNTS
   	    WHERE EMAIL_ACCOUNT_ID =  p_in_email_account_tbl(i);

   	    if (l_account_count = 1) then

		SELECT USER_NAME
  		INTO l_email_user
		FROM IEM_MSTEMAIL_ACCOUNTS
   		WHERE EMAIL_ACCOUNT_ID = p_in_email_account_tbl(i);

    		-- Check if the agent account already exist.  If exist, skip and fetch next resource id in the loop
    		select count(*) into l_agent_account_count from iem_agents where email_account_id= p_in_email_account_tbl(i) and resource_id=p_resource_id;

    		IF (l_agent_account_count = 0) THEN

    			l_data_change := true;


			/*	JTF_RS_RESOURCE_VALUES_PUB.CREATE_RS_RESOURCE_VALUES(
      					P_Api_Version => 1.0,
     	 				P_Init_Msg_List  => FND_API.G_FALSE,
      					P_Commit  => FND_API.G_FALSE,
      					P_resource_id => p_resource_id,
      					p_resource_param_id => 1,
      					p_value  => 'IEM_DEFAULT_VALUE',
      					P_value_type =>  p_in_email_account_tbl(i),
      					X_Return_Status => l_return_status,
      					X_Msg_Count => l_msg_count,
      					X_Msg_Data => l_msg_data,
      					X_resource_param_value_id => l_resource_param_value_id);

      				IF l_return_status='S' THEN
  	   		*/
  	   				IEM_AGENT_ACT_PVT.create_item(p_api_version_number=>1.0,
     	 				P_Init_Msg_List  =>'F' ,
      					P_Commit  => 'F',
						p_resource_id=>p_resource_id,
						p_email_account_id=> p_in_email_account_tbl(i),
						p_signature=>null,
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
						x_msg_count=>l_msg_count,
						x_msg_data=>l_msg_data,
						x_return_status=>l_return_status);

					IF l_return_status<>'S' THEN
						if l_error_account_count < 6 then
  	  						l_error_email_user := l_error_email_user || ' ' || l_email_user || ',';
  	  						l_error_account_count := l_error_account_count + 1;
  	  					end if;
					END IF;  -- IEM_AGENT_ACT_PVT
			/*	ELSE
					if l_error_account_count < 6 then
  	  					l_error_email_user := l_error_email_user || ' ' || l_email_user || ',';
  	  					l_error_account_count := l_error_account_count + 1;
  	  				end if;
				END IF;  -- JTF_RS_RESOURCE_VALUES_PUB

			ELSE
				if l_error_account_count < 6 then
					l_error_email_user := l_error_email_user || ' ' || l_email_user || ',';
					l_error_account_count := l_error_account_count + 1;
				end if;
			*/
		END IF; -- l_agent_acount_account=0
          end if;  -- l_account_count = 1
    	END LOOP;

    	if l_error_email_user is not null then
    			x_return_status := FND_API.G_RET_STS_ERROR;
            		l_error_email_user := RTRIM(l_error_email_user, ', ');

            		if l_error_account_count > 5 then
            			l_error_email_user := l_error_email_user || '...';
            		end if;

    			FND_MESSAGE.SET_NAME('IEM', 'IEM_SSS_AGNTACCT2_CREATED');
    			FND_MESSAGE.SET_TOKEN('ACCOUNT', l_error_email_user);
    			FND_MSG_PUB.ADD;
    	elsif l_data_change = false then
    		x_return_status := 'N';  -- indicate no data change
    	end if;

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
    WHEN USER_NULL_ERROR THEN
      	   ROLLBACK TO create_agntacct_by_account_PVT;
           FND_MESSAGE.SET_NAME('IEM','IEM_SSS_AGENT_USER_NULL');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN RESOURCE_INACTIVE_ERROR THEN
      	   ROLLBACK TO create_agntacct_by_account_PVT;
           FND_MESSAGE.SET_NAME('IEM','IEM_SSS_RESOURCE_INACTIVE');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO create_agntacct_by_account_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO create_agntacct_by_account_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO create_agntacct_by_account_PVT;
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

 END create_agntacct_by_account;


  PROCEDURE delete_agntacct_by_account (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			      p_out_email_account_tbl             IN  jtf_varchar2_Table_100,
			      p_resource_id	in number,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='delete_agntacct_by_account';
	l_api_version_number 	NUMBER:=1.0;
	l_return_status	varchar2(10);
	l_msg_count	number;
	l_msg_data	varchar2(255);
	l_email_user IEM_MSTEMAIL_ACCOUNTS.USER_NAME%TYPE;
	l_user_id JTF_RS_RESOURCE_EXTNS.USER_ID%TYPE;
	l_user_name JTF_RS_RESOURCE_EXTNS.USER_NAME%TYPE;
	l_agntacct varchar2(160);
	l_res_name varchar2(720);
	l_error_email_user varchar2(32000);
	l_error_email_user1 varchar2(32000);
	l_error_email_user2 varchar2(32000);
	l_error_account_count	 number:=0;
	l_error_account_count1	 number:=0;
	l_error_account_count2	 number:=0;
	l_resource_param_value_id number;
    	l_object_version_number number;
    	l_agent_account_count NUMBER;
    	l_agent_account_id NUMBER;
    	l_email_count NUMBER;
    	l_compose_count NUMBER;
    	l_process_count NUMBER;
    	l_data_change Boolean := false;
    	l_account_count		number;
    	l_resource_param_count	number;
    	l_is_clean	Boolean;

BEGIN
SAVEPOINT delete_agntacct_by_account_PVT;
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

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   	SELECT USER_ID, USER_NAME, SOURCE_LAST_NAME || ', ' || SOURCE_FIRST_NAME as RESOURCE_NAME
		INTO l_user_id, l_user_name, l_res_name
		FROM JTF_RS_RESOURCE_EXTNS
		WHERE RESOURCE_ID = p_resource_id;

	FOR i in 1..p_out_email_account_tbl.count() LOOP

	   select count(*) into l_account_count FROM IEM_MSTEMAIL_ACCOUNTS
   	   WHERE EMAIL_ACCOUNT_ID = p_out_email_account_tbl(i);

   	   if (l_account_count = 1) then

		SELECT USER_NAME
  		INTO l_email_user
		FROM IEM_MSTEMAIL_ACCOUNTS
   		WHERE EMAIL_ACCOUNT_ID = p_out_email_account_tbl(i);

           	l_agntacct:=TO_CHAR(l_user_id)||'-'||l_email_user;

           	-- Check if the agent account already non-exist.  If non-exist, skip and fetch next resource id in the loop
    		select count(*) into l_agent_account_count from iem_agents where email_account_id=p_out_email_account_tbl(i)
    		and resource_id=p_resource_id;

    		IF (l_agent_account_count <> 0) THEN

    			l_data_change := true;

  	  		      -- Check any Agent fetched emails, compose messages or in-process messages in Outbox Processor
  	  		   	IEM_CLIENT_PUB.isAgentInboxClean(p_api_version_number=>1.0,
 					p_init_msg_list=>'F' ,
					p_commit=>'F'	    ,
					p_resource_id => p_resource_id,
					p_email_account_id => p_out_email_account_tbl(i),
					x_is_clean => l_is_clean,
					x_msg_count=>l_msg_count,
					x_msg_data=>l_msg_data,
					x_return_status=>l_return_status);

			 IF l_return_status<>'S' THEN
				if l_error_account_count1 < 6 then
  	  					l_error_email_user1 := l_error_email_user1 || ' ' || l_email_user || ',';
  	  					l_error_account_count1 := l_error_account_count1 + 1;
  	  			end if;
			 ELSE

			   IF (l_is_clean = false) THEN
				if l_error_account_count2 < 6 then
  	  					l_error_email_user2 := l_error_email_user2 || ' ' || l_email_user || ',';
  	  					l_error_account_count2 := l_error_account_count2 + 1;
  	  			end if;

    			   ELSE

    			   	IEM_AGENT_ACT_PVT.delete_item(p_api_version_number=>1.0,
     	 				P_Init_Msg_List  =>'F',
      					P_Commit  => 'F',
					 p_resource_id => p_resource_id,
					 p_email_account_id => p_out_email_account_tbl(i),
					x_msg_count=>l_msg_count,
					x_msg_data=>l_msg_data,
					x_return_status=>l_return_status);

      				IF l_return_status<>'S' THEN

  	   		/*		select count(*) into l_resource_param_count from jtf_rs_resource_values
    		 			where value_type=p_out_email_account_tbl(i) and resource_id=p_resource_id and value='IEM_DEFAULT_VALUE';

    		 			if (l_resource_param_count > 0) then

    		 		   	   select resource_param_value_id, object_version_number into l_resource_param_value_id, l_object_version_number from jtf_rs_resource_values
    		 		    	   where value_type=p_out_email_account_tbl(i) and resource_id=p_resource_id and value='IEM_DEFAULT_VALUE';

				   	   JTF_RS_RESOURCE_VALUES_PUB.DELETE_RS_RESOURCE_VALUES(
      						P_Api_Version => 1.0,
     	 					P_Init_Msg_List  => FND_API.G_FALSE,
      						P_Commit  => FND_API.G_FALSE,
      						p_resource_param_value_id => l_resource_param_value_id,
      						p_object_version_number => l_object_version_number,
      						X_Return_Status => l_return_status,
      						X_Msg_Count => l_msg_count,
      						X_Msg_Data => l_msg_data);

					   IF l_return_status<>'S' THEN
						if l_error_account_count < 6 then
  	  						l_error_email_user := l_error_email_user || ' ' || l_email_user || ',';
  	  						l_error_account_count := l_error_account_count + 1;
  	  					end if;
					   END IF;   -- IF THEN - JTF_RS_RESOURCE_VALUES_PUB
					end if; -- l_resource_param_count > 0
				ELSE
			*/		if l_error_account_count < 6 then
  	  					l_error_email_user := l_error_email_user || ' ' || l_email_user || ',';
  	  					l_error_account_count := l_error_account_count + 1;
  	  				end if;
				END IF; -- IF THEN - IEM_AGENT_ACT_PVT

		    	      END IF;  -- is inbox clean

			   END IF; -- IF THEN - IEM_CLIENT_PUB
    		END IF; -- l_agent_acount_account<>0
    	  end if;  -- l_account_count=0
    	END LOOP;

    	if l_error_email_user is not null then
    		x_return_status := FND_API.G_RET_STS_ERROR;
            	l_error_email_user := RTRIM(l_error_email_user, ', ');

            	if l_error_account_count > 5 then
            		l_error_email_user := l_error_email_user || '...';
            	end if;

    		FND_MESSAGE.SET_NAME('IEM', 'IEM_SSS_AGNTACCT2_DELETED');
    		FND_MESSAGE.SET_TOKEN('ACCOUNT', l_error_email_user);
    		FND_MSG_PUB.ADD;

    	end if;

    	if l_error_email_user1 is not null then
    		x_return_status := FND_API.G_RET_STS_ERROR ;
    		l_error_email_user1 := RTRIM(l_error_email_user1, ', ');

            	if l_error_account_count1 > 5 then
            		l_error_email_user1 := l_error_email_user1 || '...';
            	end if;

    		 FND_MESSAGE.SET_NAME('IEM','IEM_SSS_AGNTACCT10_DELETED');
    		 FND_MESSAGE.SET_TOKEN('ACCOUNT', l_error_email_user1);
    		 FND_MESSAGE.SET_TOKEN('AGENT', l_res_name);
            	 FND_MSG_PUB.Add;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    	end if;

    	if l_error_email_user2 is not null then
    		x_return_status := FND_API.G_RET_STS_ERROR;
            	l_error_email_user2 := RTRIM(l_error_email_user2, ', ');

            	if l_error_account_count2 > 5 then
            		l_error_email_user2 := l_error_email_user2 || '...';
            	end if;

    		FND_MESSAGE.SET_NAME('IEM', 'IEM_SSS_AGNTACCT6_DELETED');
    		FND_MESSAGE.SET_TOKEN('ACCOUNT', l_error_email_user2);
    		FND_MESSAGE.SET_TOKEN('AGENT', l_res_name);
    		FND_MSG_PUB.ADD;

    	end if;

    	if l_error_email_user is null and l_error_email_user1 is null and l_error_email_user2 is null and l_data_change=false then
    		x_return_status := 'N'; -- indicate no change in data
    	end if;

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
	ROLLBACK TO delete_agntacct_by_account_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO delete_agntacct_by_account_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO delete_agntacct_by_account_PVT;
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

 END delete_agntacct_by_account;

 PROCEDURE update_agntacct_by_acct_wrap (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
		    	      p_in_email_account_tbl             IN  jtf_varchar2_Table_100,
			      p_out_email_account_tbl            IN  jtf_varchar2_Table_100,
			      p_resource_id	in number,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='update_agntacct_by_acct_wrap';
	l_api_version_number 	NUMBER:=1.0;
	l_return_status	varchar2(10);
	l_return_status1 varchar2(10);
	l_msg_count	number;
	l_msg_data	varchar2(255);
	l_db_server_id  number;
	l_oo_link1 varchar2(200);
	l_account_count 	number;

	DB_LINK_NOT_FOUND EXCEPTION;

BEGIN
SAVEPOINT agntacct_by_account_wrap;
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

   x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Assign agents to account
    	iem_agent_act_pvt.create_agntacct_by_account (p_api_version_number =>1.0,
     	 		P_Init_Msg_List  =>'F',
      			P_Commit  => 'F',
			      	p_in_email_account_tbl  => p_in_email_account_tbl,
			      	p_resource_id => p_resource_id,
			      	x_return_status =>l_return_status,
  				x_msg_count    => l_msg_count,
  				x_msg_data      => l_msg_data);

  	IF l_return_status = 'N' THEN
  		l_return_status1:='N';
      	ELSIF l_return_status<>'S' and l_return_status<>'N' THEN
  	   	 x_return_status := FND_API.G_RET_STS_ERROR ;
       		FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
	END IF;

	-- Unassign agents from account
	iem_agent_act_pvt.delete_agntacct_by_account (p_api_version_number =>1.0,
     	 		P_Init_Msg_List  =>'F',
      			P_Commit  => 'F',
			      	p_out_email_account_tbl  => p_out_email_account_tbl,
			      	p_resource_id => p_resource_id,
			      	x_return_status =>l_return_status,
  				x_msg_count    => l_msg_count,
  				x_msg_data      => l_msg_data);

  	IF l_return_status='N'and l_return_status1='N' THEN
  		x_return_status := 'N';
      	ELSIF l_return_status<>'S' and l_return_status<>'N' THEN
  	   	x_return_status := FND_API.G_RET_STS_ERROR ;
       		FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
	END IF;


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

   WHEN DB_LINK_NOT_FOUND THEN
            ROLLBACK TO agntacct_by_account_wrap;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO agntacct_by_account_wrap;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO agntacct_by_account_wrap;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO agntacct_by_account_wrap;
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

 END update_agntacct_by_acct_wrap;

--added by siahmed for 12.1.3 project


 PROCEDURE update_agent_cherrypick (
	                      p_api_version_number  IN   NUMBER,
 		  	      p_init_msg_list       IN   VARCHAR2 ,
		    	      p_commit	            IN   VARCHAR2 ,
			      p_in_cherrypick_tbl   IN  jtf_varchar2_Table_100,
			      p_out_cherrypick_tbl  IN  jtf_varchar2_Table_100,
			      p_email_account_id    IN number,
			      x_return_status       OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	    OUT NOCOPY    NUMBER,
	  	  	      x_msg_data            OUT NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='update_agent_cherrypick';
	l_api_version_number 	NUMBER:=1.0;
	l_return_status	varchar2(10);
	l_msg_count	number;
	l_msg_data	varchar2(255);
	l_user_id JTF_RS_RESOURCE_EXTNS.USER_ID%TYPE;
	l_user_name JTF_RS_RESOURCE_EXTNS.USER_NAME%TYPE;
	l_agntacct varchar2(160);
	l_res_name varchar2(720);
	l_error_username varchar2(32000);
	l_error_username1 varchar2(32000);
	l_error_username2 varchar2(32000);
	l_error_agent_count  number:=0;
	l_error_agent_count1  number:=0;
	l_error_agent_count2 number:=0;
	l_resource_param_value_id number;
    	l_object_version_number number;
    	l_agent_account_id NUMBER;
    	l_agent_account_count NUMBER;
    	l_email_count NUMBER;
    	l_compose_count  NUMBER;
    	l_process_count	 NUMBER;
    	l_data_change Boolean := false;
    	l_resource_param_count number;
    	l_account_name varchar2(210);
    	l_is_clean 	Boolean;


  BEGIN
  SAVEPOINT update_agent_cherrypick_PVT;
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

   x_return_status := FND_API.G_RET_STS_SUCCESS;


	FOR i in 1..p_in_cherrypick_tbl.count() LOOP

		SELECT USER_ID, USER_NAME, SOURCE_LAST_NAME || ', ' || SOURCE_FIRST_NAME as RESOURCE_NAME
		INTO l_user_id, l_user_name, l_res_name
		FROM JTF_RS_RESOURCE_EXTNS
		WHERE RESOURCE_ID = p_in_cherrypick_tbl(i);


           	-- Check if the agent account already non-exist.  If non-exist, skip and fetch next resource id in the loop
    		select count(*) into l_agent_account_count
		from iem_agents
		where resource_id=p_in_cherrypick_tbl(i)
    		and email_account_id=p_email_account_id;

    		IF (l_agent_account_count <> 0) THEN

    			l_data_change := true;

			BEGIN
		          UPDATE iem_agents set cherry_pick_flag = 'Y'
			  WHERE resource_id=p_in_cherrypick_tbl(i)
    		          and email_account_id=p_email_account_id;

               		   FND_MESSAGE.SET_NAME('IEM','IEM_CHERRY_PICK_ADDED');
    		           FND_MESSAGE.SET_TOKEN('AGENT', p_in_cherrypick_tbl(i) );
    		           FND_MESSAGE.SET_TOKEN('ACCOUNT', p_email_account_id);
		        EXCEPTION
                           WHEN NO_DATA_FOUND  THEN
               		      FND_MESSAGE.SET_NAME('IEM','IEM_CHERRY_PICK_NO_DATA_ERROR');
    		              FND_MESSAGE.SET_TOKEN('AGENT', p_in_cherrypick_tbl(i) );
    		              FND_MESSAGE.SET_TOKEN('ACCOUNT', p_email_account_id);
                           WHEN OTHERS THEN
               		      FND_MESSAGE.SET_NAME('IEM','IEM_CHERRY_PICK_OTHERS_ERROR');
    		              FND_MESSAGE.SET_TOKEN('AGENT', p_in_cherrypick_tbl(i) );
    		              FND_MESSAGE.SET_TOKEN('ACCOUNT', p_email_account_id);

			END;

    		END IF; -- l_agent_acount_account<>0
    	END LOOP;


       	FOR i in 1..p_out_cherrypick_tbl.count() LOOP

		SELECT USER_ID, USER_NAME, SOURCE_LAST_NAME || ', ' || SOURCE_FIRST_NAME as RESOURCE_NAME
		INTO l_user_id, l_user_name, l_res_name
		FROM JTF_RS_RESOURCE_EXTNS
		WHERE RESOURCE_ID = p_out_cherrypick_tbl(i);


           	-- Check if the agent account already non-exist.  If non-exist, skip and fetch next resource id in the loop
    		select count(*) into l_agent_account_count
		from iem_agents
		where resource_id=p_out_cherrypick_tbl(i)
    		and email_account_id=p_email_account_id;

    		IF (l_agent_account_count <> 0) THEN

    			l_data_change := true;

			BEGIN
		          UPDATE iem_agents set cherry_pick_flag = null
			  WHERE resource_id=p_out_cherrypick_tbl(i)
    		          and email_account_id=p_email_account_id;

               		   FND_MESSAGE.SET_NAME('IEM','IEM_CHRYPICK_ADDED');
    		           FND_MESSAGE.SET_TOKEN('AGENT', p_out_cherrypick_tbl(i) );
    		           FND_MESSAGE.SET_TOKEN('ACCOUNT', p_email_account_id);
		        EXCEPTION
                           WHEN NO_DATA_FOUND  THEN
               		      FND_MESSAGE.SET_NAME('IEM','IEM_CHRYPICK_NO_DATA_ERROR');
    		              FND_MESSAGE.SET_TOKEN('AGENT', p_out_cherrypick_tbl(i) );
    		              FND_MESSAGE.SET_TOKEN('ACCOUNT', p_email_account_id);
                           WHEN OTHERS THEN
               		      FND_MESSAGE.SET_NAME('IEM','IEM_CHRYPICK_OTHERS_ERROR');
    		              FND_MESSAGE.SET_TOKEN('AGENT', p_out_cherrypick_tbl(i) );
    		              FND_MESSAGE.SET_TOKEN('ACCOUNT', p_email_account_id);

			END;

    		END IF; -- l_agent_acount_account<>0
    	END LOOP;



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
	ROLLBACK TO update_agent_cherrypick_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO update_agent_cherrypick_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
      ROLLBACK TO update_agent_cherrypick_PVT;
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

 END update_agent_cherrypick;



 PROCEDURE update_acct_cherrypick (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
		    	      p_in_acct_chrypick_tbl             IN  jtf_varchar2_Table_100,
			      p_out_acct_chrypick_tbl            IN  jtf_varchar2_Table_100,
			      p_resource_id	in number,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='update_acct_cherrypick';
	l_api_version_number 	NUMBER:=1.0;
	l_return_status	varchar2(10);
	l_msg_count	number;
	l_msg_data	varchar2(255);
	l_user_id JTF_RS_RESOURCE_EXTNS.USER_ID%TYPE;
	l_user_name JTF_RS_RESOURCE_EXTNS.USER_NAME%TYPE;
	l_agntacct varchar2(160);
	l_res_name varchar2(720);
	l_error_username varchar2(32000);
	l_error_username1 varchar2(32000);
	l_error_username2 varchar2(32000);
	l_error_agent_count  number:=0;
	l_error_agent_count1  number:=0;
	l_error_agent_count2 number:=0;
	l_resource_param_value_id number;
    	l_object_version_number number;
    	l_agent_account_id NUMBER;
    	l_agent_account_count NUMBER;
    	l_email_count NUMBER;
    	l_compose_count  NUMBER;
    	l_process_count	 NUMBER;
    	l_data_change Boolean := false;
    	l_resource_param_count number;
    	l_account_name varchar2(210);
    	l_is_clean 	Boolean;


  BEGIN
   SAVEPOINT update_acct_chrypick_PVT;
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

   x_return_status := FND_API.G_RET_STS_SUCCESS;


	FOR i in 1..p_in_acct_chrypick_tbl.count() LOOP

		SELECT USER_ID, USER_NAME, SOURCE_LAST_NAME || ', ' || SOURCE_FIRST_NAME as RESOURCE_NAME
		INTO l_user_id, l_user_name, l_res_name
		FROM JTF_RS_RESOURCE_EXTNS
		WHERE RESOURCE_ID = p_resource_id;


           	-- Check if the agent account already non-exist.  If non-exist, skip and fetch next resource id in the loop
    		select count(*) into l_agent_account_count
		from iem_agents
		where resource_id=p_resource_id
    		and email_account_id=p_in_acct_chrypick_tbl(i);

    		IF (l_agent_account_count <> 0) THEN

    			l_data_change := true;

			BEGIN
		          UPDATE iem_agents set cherry_pick_flag = 'Y'
		          where resource_id=p_resource_id
    		          and email_account_id=p_in_acct_chrypick_tbl(i);

               		   FND_MESSAGE.SET_NAME('IEM','IEM_CHERRY_PICK_ACCT_ADDED');
    		           FND_MESSAGE.SET_TOKEN('ACCOUNT', p_resource_id);
    		           FND_MESSAGE.SET_TOKEN('AGENT', p_in_acct_chrypick_tbl(i) );
		        EXCEPTION
                           WHEN NO_DATA_FOUND  THEN
               		      FND_MESSAGE.SET_NAME('IEM','IEM_CHERRY_PICK_ACCT_NO_DATA_ERROR');
    		              FND_MESSAGE.SET_TOKEN('ACCOUNT', p_resource_id);
    		              FND_MESSAGE.SET_TOKEN('AGENT', p_in_acct_chrypick_tbl(i) );
                           WHEN OTHERS THEN
               		      FND_MESSAGE.SET_NAME('IEM','IEM_CHERRY_PICK_ACCT_OTHERS_ERROR');
    		              FND_MESSAGE.SET_TOKEN('ACCOUNT', p_resource_id);
    		              FND_MESSAGE.SET_TOKEN('AGENT', p_in_acct_chrypick_tbl(i));

			END;

    		END IF; -- l_agent_acount_account<>0
    	END LOOP;


       	FOR i in 1..p_out_acct_chrypick_tbl.count() LOOP

		SELECT USER_ID, USER_NAME, SOURCE_LAST_NAME || ', ' || SOURCE_FIRST_NAME as RESOURCE_NAME
		INTO l_user_id, l_user_name, l_res_name
		FROM JTF_RS_RESOURCE_EXTNS
		WHERE RESOURCE_ID = p_resource_id;


           	-- Check if the agent account already non-exist.  If non-exist, skip and fetch next resource id in the loop
    		select count(*) into l_agent_account_count
		from iem_agents
		where resource_id=p_resource_id
    		and email_account_id=p_out_acct_chrypick_tbl(i);

    		IF (l_agent_account_count <> 0) THEN

    			l_data_change := true;

			BEGIN
		          UPDATE iem_agents set cherry_pick_flag = null
		          where resource_id=p_resource_id
    		          and email_account_id=p_out_acct_chrypick_tbl(i);

               		   FND_MESSAGE.SET_NAME('IEM','IEM_CHRYPICK_ACCT_DELETED');
    		           FND_MESSAGE.SET_TOKEN('ACCOUNT', p_resource_id);
    		           FND_MESSAGE.SET_TOKEN('AGENT', p_out_acct_chrypick_tbl(i) );
		        EXCEPTION
                           WHEN NO_DATA_FOUND  THEN
               		      FND_MESSAGE.SET_NAME('IEM','IEM_CHRRYPICK_ACCT_DELETE_NO_DATA_ERROR');
    		              FND_MESSAGE.SET_TOKEN('ACCOUNT', p_resource_id);
    		              FND_MESSAGE.SET_TOKEN('AGENT', p_out_acct_chrypick_tbl(i) );
                           WHEN OTHERS THEN
               		      FND_MESSAGE.SET_NAME('IEM','IEM_CHRYPICK_ACCT_DELETE_OTHERS_ERROR');
    		              FND_MESSAGE.SET_TOKEN('ACCOUNT', p_resource_id);
    		              FND_MESSAGE.SET_TOKEN('AGENT', p_out_acct_chrypick_tbl(i) );

			END;

    		END IF; -- l_agent_acount_account<>0
    	END LOOP;



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
       ROLLBACK TO update_acct_chrypick_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO update_acct_chrypick_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
      ROLLBACK TO update_acct_chrypick_PVT;
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

 END update_acct_cherrypick;
--end of addition for 12.1.3 project siahmed


END IEM_AGENT_ACT_PVT ;

/
