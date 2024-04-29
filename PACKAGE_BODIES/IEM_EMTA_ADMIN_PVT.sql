--------------------------------------------------------
--  DDL for Package Body IEM_EMTA_ADMIN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_EMTA_ADMIN_PVT" AS
/* $Header: iemvemtb.pls 120.3 2005/08/07 17:33:04 appldev noship $ */

--
--
-- Purpose: Mantain EMTA admin related issue.
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia  12/05/2004    Created
--  Liang Xia  01/10/2004    Added  UPDATE_DP_CONFIG_DATA_WRAP for Email Account GUI
--  Liang Xia  01/19/2005    Changed UPDATE_DP_CONFIG_DATA_WRAP, if P_PASSWORD is null, means no changes
--  Liang Xia  07/08/2005    Changed for FND_VAL: removed PASSWORD column in account tables
-- ---------   ------  ------------------------------------------

-- Enter procedure, function bodies as shown below
G_PKG_NAME CONSTANT varchar2(30) :='IEM_EMTA_ADMIN_PVT ';
G_created_updated_by   NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
G_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ID') ) ;

PROCEDURE IS_DLPS_RUNNING  (
                 			p_api_version_number  IN   NUMBER,
 		  	     			p_init_msg_list       IN   VARCHAR2 := null,
		    	 			p_commit              IN   VARCHAR2 := null,
            				p_email_acct_id       IN   NUMBER,
							x_running_status      OUT  NOCOPY VARCHAR2,
                 	    	x_return_status	  	  OUT  NOCOPY VARCHAR2,
  							x_msg_count	  		  OUT  NOCOPY NUMBER,
							x_msg_data	          OUT  NOCOPY VARCHAR2

			 ) is
	l_api_name        		VARCHAR2(255):='IS_DLPS_RUNNING';
	l_api_version_number 	NUMBER:=1.0;
    l_seq_id		        NUMBER;

    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);
    i				INTEGER;


BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		IS_DLPS_RUNNING_PVT;

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

   --begins here

   x_running_status := 'N';

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
	ROLLBACK TO IS_DLPS_RUNNING_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get

			( p_count => x_msg_count,
              p_data  => x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO IS_DLPS_RUNNING_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  =>      x_msg_data
			);

   WHEN OTHERS THEN
	ROLLBACK TO IS_DLPS_RUNNING_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	FND_MSG_PUB.Add_Exc_Msg
	    	(	G_PKG_NAME ,
	    		l_api_name
	    	);
	END IF;

	FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data

    		);

 END IS_DLPS_RUNNING;


PROCEDURE UPDATE_DP_CONFIG_DATA_WRAP(
 		  p_api_version_number  IN   NUMBER,
		  p_init_msg_list       IN   VARCHAR2 := null,
		  p_commit              IN   VARCHAR2 := null,
		  p_email_acct_id       IN   NUMBER,
		  p_action         		IN 	 VARCHAR2,
		  P_ACTIVE_FLAG    		IN 	 varchar2 := null,
		  P_USER_NAME 			IN 	 varchar2 := null,
		  P_USER_PASSWORD 		IN 	 varchar2 := null,
		  P_IN_HOST 			IN 	 varchar2 := null,
		  P_IN_PORT				IN 	 varchar2 := null,
		  x_return_status       OUT  NOCOPY VARCHAR2,
		  x_msg_count    		OUT  NOCOPY NUMBER,
		  x_msg_data            OUT  NOCOPY VARCHAR2 )
	 is
	l_api_name        		VARCHAR2(255):='IS_DLPS_RUNNING';
	l_api_version_number 	NUMBER:=1.0;

    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);

	l_email_acct_id       	   NUMBER;
	l_is_acct_updated     	   VARCHAR2(1);
	l_is_data_changed		   VARCHAR2(1);
	l_active_flag              VARCHAR2(1);

	--l_action         		 	 VARCHAR2;


	l_USER_NAME 			 	 varchar2(100);
	l_USER_PASSWORD 		 	 varchar2(100);
	l_IN_HOST 				 	 varchar2(256);
	l_IN_PORT				 	 varchar2(15);

	l_count 					 NUMBER;
    errorMessage varchar2(2000);
    logMessage varchar2(2000);

	IEM_INVALID_DATA_DO_NOTHING	EXCEPTION;
	IEM_UPD_DP_CONFIG_DATA_FAILED 	EXCEPTION;
	IEM_ACCOUT_ID_NOT_EXIST		EXCEPTION;
BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		UPDATE_DP_CONFIG_DATA_WRAP_PVT;

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

   --begins here

   if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            logMessage := 'Input data: [p_email_acct_id=' ||p_email_acct_id
		  			   	  ||'][p_action=' || p_action ||'][P_ACTIVE_FLAG=' || P_ACTIVE_FLAG
		  				  ||'][P_USER_NAME=' || P_USER_NAME --||'][P_USER_PASSWORD =' || P_USER_PASSWORD
						  ||'][P_IN_HOST=' || P_IN_HOST ||'][ P_IN_PORT =' ||  P_IN_PORT ||']' ;
			--dbms_output.put_line(logMessage);
	        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_EMTA_ADMIN_PVT.UPDATE_DP_CONFIG_DATA_WRAP', logMessage);
   end if;

   if ( p_email_acct_id is null ) then
      raise IEM_INVALID_DATA_DO_NOTHING;
   end if;

   if ( p_action = 'create' ) then

   	  if ( p_active_flag is null or ( p_active_flag <> 'Y' and p_active_flag <> 'N') ) then
	  	 raise IEM_INVALID_DATA_DO_NOTHING;
	  end if;

	  l_is_acct_updated := 'Y';

      IEM_EMTA_ADMIN_PVT.UPDATE_DP_CONFIG_DATA(
                 	p_api_version_number  => P_Api_Version_Number,
                    p_init_msg_list       => FND_API.G_FALSE,
                	p_commit              => P_Commit,
            		p_email_acct_id       => p_email_acct_id,
					p_active_flag		  => p_active_flag,
					p_is_acct_update      => l_is_acct_updated,
                	x_return_status       => l_return_status,
                    x_msg_count           => x_msg_count,
                    x_msg_data            => x_msg_data
                );
      if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
              raise IEM_UPD_DP_CONFIG_DATA_FAILED;
      end if;


   elsif ( p_action = 'update' ) then

      select count(*) into l_count from iem_mstemail_accounts where email_account_id=p_email_acct_id;

   	  if ( l_count = 0 ) then
   	  	 raise IEM_ACCOUT_ID_NOT_EXIST;
   	  end if;

   	  if ( p_active_flag is null or ( p_active_flag <> 'Y' and p_active_flag <> 'N') ) then
	  	 raise IEM_INVALID_DATA_DO_NOTHING;
	  end if;

	  --if ( P_USER_NAME is null or P_USER_PASSWORD is null or P_IN_HOST is null or P_IN_PORT is null ) then
	  if ( P_USER_NAME is null or P_IN_HOST is null or P_IN_PORT is null ) then
		  	 raise IEM_INVALID_DATA_DO_NOTHING;
	  end if;

		l_USER_NAME := RTRIM(LTRIM(P_USER_NAME)) ;
		--l_USER_PASSWORD := RTRIM(LTRIM(P_USER_PASSWORD));
		l_IN_HOST := RTRIM(LTRIM(P_IN_HOST));
		l_IN_PORT := RTRIM(LTRIM(P_IN_PORT));



	  CHECK_IF_ACCOUNT_UPDATED (
	   						   		    p_api_version_number  => l_api_version_number,
                    					p_init_msg_list       => FND_API.G_FALSE,
                						p_commit              => P_Commit,
										p_email_account_id    => p_email_acct_id,
	  					   				P_ACTIVE_FLAG 		  => P_ACTIVE_FLAG,
		  								P_USER_NAME 		  => l_USER_NAME,
		  								P_USER_PASSWORD 	  => P_USER_PASSWORD,
						  				P_IN_HOST 			  => l_IN_HOST,
		  								P_IN_PORT 			  => l_IN_PORT,
										x_is_data_changed 	  => l_is_data_changed,
										x_is_acct_updated 	  => l_is_acct_updated,
               							x_return_status       => l_return_status,
                    					x_msg_count           => x_msg_count,
                    					x_msg_data            => x_msg_data
										 );

		if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
              raise IEM_UPD_DP_CONFIG_DATA_FAILED;
      	    end if;

	  if ( l_is_data_changed = 'Y' ) then

	       IEM_EMTA_ADMIN_PVT.UPDATE_DP_CONFIG_DATA(
                 	p_api_version_number  => P_Api_Version_Number,
                    p_init_msg_list       => FND_API.G_FALSE,
                	p_commit              => P_Commit,
            		p_email_acct_id       => p_email_acct_id,
					p_active_flag		  => p_active_flag,
					p_is_acct_update      => l_is_acct_updated,
                	x_return_status       => l_return_status,
                    x_msg_count           => x_msg_count,
                    x_msg_data            => x_msg_data
                );

	  	   if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
              raise IEM_UPD_DP_CONFIG_DATA_FAILED;
      	   end if;

	  end if;
   elsif ( p_action = 'delete' ) then

   		   l_active_flag := 'N';
		   l_is_acct_updated := 'N';

	       IEM_EMTA_ADMIN_PVT.UPDATE_DP_CONFIG_DATA(
                 	p_api_version_number  => P_Api_Version_Number,
                    p_init_msg_list       => FND_API.G_FALSE,
                	p_commit              => P_Commit,
            		p_email_acct_id       => p_email_acct_id,
					p_active_flag		  => l_active_flag,
					p_is_acct_update      => l_is_acct_updated,
                	x_return_status       => l_return_status,
                    x_msg_count           => x_msg_count,
                    x_msg_data            => x_msg_data
                );

		   if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
                    --dbms_output.put_line('ERROR when calling IEM_ENCRYPT_TAGS_PVT.duplicate_tags ');
              raise IEM_UPD_DP_CONFIG_DATA_FAILED;
      	   end if;

   else
   	   raise IEM_INVALID_DATA_DO_NOTHING;
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
    WHEN IEM_INVALID_DATA_DO_NOTHING THEN
        ROLLBACK TO UPDATE_DP_CONFIG_DATA_WRAP_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR; --FND_API.G_RET_STS_SUCCESS ;

        FND_MESSAGE.SET_NAME('IEM', 'IEM_INVALID_DATA_DO_NOTHING');

        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

        if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            logMessage := '[input data is invalid, no data inserted to IEM_EMTA_CONFIG_PARAMS,return true!]';
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_EMTA_ADMIN_PVT.UPDATE_DP_CONFIG_DATA_WRAP', logMessage);
        end if;

    WHEN IEM_UPD_DP_CONFIG_DATA_FAILED THEN
        ROLLBACK TO UPDATE_DP_CONFIG_DATA_WRAP_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;

        FND_MESSAGE.SET_NAME('IEM', 'IEM_UPD_DP_CONFIG_DATA_FAILED');

        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

        if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            logMessage := '[Failed when calling IEM_UPDATE_DP_CONFIG_DATA!]';
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_EMTA_ADMIN_PVT.UPDATE_DP_CONFIG_DATA_WRAP', logMessage);
        end if;
    WHEN IEM_ACCOUT_ID_NOT_EXIST THEN

        ROLLBACK TO UPDATE_DP_CONFIG_DATA_WRAP_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;

        FND_MESSAGE.SET_NAME('IEM', 'IEM_ACCOUT_ID_NOT_EXIST');

        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

        if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            logMessage := '[Email Account Id does not exist in IEM_MSTEMAIL_ACCOUNTS!]';
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_EMTA_ADMIN_PVT.UPDATE_DP_CONFIG_DATA_WRAP', logMessage);
        end if;
	WHEN FND_API.G_EXC_ERROR THEN
		 ROLLBACK TO UPDATE_DP_CONFIG_DATA_WRAP_PVT;
       	 x_return_status := FND_API.G_RET_STS_ERROR ;
       	 FND_MSG_PUB.Count_And_Get

			( p_count => x_msg_count,
              p_data  => x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO UPDATE_DP_CONFIG_DATA_WRAP_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  =>      x_msg_data
			);

   WHEN OTHERS THEN
	ROLLBACK TO UPDATE_DP_CONFIG_DATA_WRAP_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	FND_MSG_PUB.Add_Exc_Msg
	    	(	G_PKG_NAME ,
	    		l_api_name
	    	);
	END IF;

	FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data

    		);

 END UPDATE_DP_CONFIG_DATA_WRAP;


PROCEDURE UPDATE_DP_CONFIG_DATA(
                 			p_api_version_number  IN   NUMBER,
 		  	     			p_init_msg_list       IN   VARCHAR2 := null,
		    	 			p_commit              IN   VARCHAR2 := null,
            				p_email_acct_id       IN   NUMBER,
							p_active_flag		  IN   VARCHAR2,
							p_is_acct_update      IN   VARCHAR2,
                 	    	x_return_status	  	  OUT  NOCOPY VARCHAR2,
  							x_msg_count	  		  OUT  NOCOPY NUMBER,
							x_msg_data	          OUT  NOCOPY VARCHAR2 )
	 is
	l_api_name        		VARCHAR2(255):='IS_DLPS_RUNNING';
	l_api_version_number 	NUMBER:=1.0;

    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);

    l_seq_id		        NUMBER;
	l_action 			    VARCHAR2(10);
	l_update_flag           VARCHAR2(1);

	l_has_updated           VARCHAR2(1);

 	e_nowait	EXCEPTION;
 	PRAGMA	EXCEPTION_INIT(e_nowait, -54);

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		UPDATE_DP_CONFIG_DATA_PVT;

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

   --begins here
   l_has_updated := 'N';

   if p_active_flag = 'Y' then
   	  l_action := 'active';
   elsif p_active_flag = 'N' then
      l_action := 'inactive';
   end if;

   l_update_flag := p_is_acct_update;

   begin
		FOR x IN (
			select emta_config_param_id, action_type, email_account_id, account_update_flag
			from iem_emta_config_params where flag='N' and email_account_id=p_email_acct_id for update nowait
		)
    	LOOP

			 if x.account_update_flag = 'Y' then
		   	   	  update iem_emta_config_params set action_type = l_action,last_update_date = sysdate
		   		  where emta_config_param_id = x.emta_config_param_id;

				  l_has_updated := 'Y';
				  exit;
	         else
		   		  update iem_emta_config_params set action_type = l_action, account_update_flag=l_update_flag, last_update_date = sysdate
		   		  where emta_config_param_id = x.emta_config_param_id;

				  l_has_updated := 'Y';
				  exit;
		     end if;

	    END LOOP;

	exception
			 when e_nowait then

		 	 null;
    	 when others then

		 	  null;
    end;

	if l_has_updated = 'N' then
		   	select IEM_EMTA_CONFIG_PARAMS_S1.nextval into l_seq_id from dual;


			INSERT INTO IEM_EMTA_CONFIG_PARAMS
			(
	 		 EMTA_CONFIG_PARAM_ID,
	 		 EMAIL_ACCOUNT_ID,
	 		 ACTION_TYPE,
	 		 ACCOUNT_UPDATE_FLAG,
	 		 FLAG,
     		 CREATED_BY,
     		 CREATION_DATE,
     		 LAST_UPDATED_BY,
   	 		 LAST_UPDATE_DATE,
   	 		 LAST_UPDATE_LOGIN
			 )
			 VALUES
			 (
	 		 l_seq_id,
	 		 p_email_acct_id,
	 		 l_action,
	 		 l_update_flag,
	 		 'N',
			 decode(G_created_updated_by,null,-1,G_created_updated_by),
    		 sysdate,
   			 decode(G_created_updated_by,null,-1,G_created_updated_by),
   			 sysdate,
   			 decode(G_LAST_UPDATE_LOGIN,null,-1,G_LAST_UPDATE_LOGIN)
			 );
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
	ROLLBACK TO UPDATE_DP_CONFIG_DATA_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get

			( p_count => x_msg_count,
              p_data  => x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO UPDATE_DP_CONFIG_DATA_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  =>      x_msg_data
			);

   WHEN OTHERS THEN
	ROLLBACK TO UPDATE_DP_CONFIG_DATA_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	FND_MSG_PUB.Add_Exc_Msg
	    	(	G_PKG_NAME ,
	    		l_api_name
	    	);
	END IF;

	FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data

    		);

 END UPDATE_DP_CONFIG_DATA;


PROCEDURE GET_ACCOUNT_INFO (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
                 x_acct_info      	   OUT NOCOPY acct_info_tbl,
                 x_return_status	   OUT NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT NOCOPY VARCHAR2
			 )
IS
    l_api_name		        varchar2(30):='GET_ACCOUNT_INFO';
    l_api_version_number    number:=1.0;

    l_acct_info    		 acct_info_tbl;
	l_count				 number;
	Y 					 number;
 	account_rec IEM_MSTEMAIL_ACCOUNTS%ROWTYPE;

 	e_nowait	EXCEPTION;
 	PRAGMA	EXCEPTION_INIT(e_nowait, -54);

BEGIN

    --Standard Savepoint
    SAVEPOINT GET_ACCOUNT_INFO_pvt;

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

    --Actual API starts here

	Y := 1;

	for x in (
		select emta_config_param_id, action_type, email_account_id, account_update_flag
		from iem_emta_config_params where flag='N' for update nowait
		)
    LOOP
	        update IEM_EMTA_CONFIG_PARAMS set FLAG='A', LAST_UPDATE_DATE=SYSDATE
	        where emta_config_param_id=x.emta_config_param_id;

			select count(*) into l_count
			from iem_mstemail_accounts where email_account_id=x.email_account_id;

			if ( l_count = 0 ) then
			   delete IEM_EMTA_CONFIG_PARAMS where emta_config_param_id=x.emta_config_param_id;
			else

				select * into account_rec
				from iem_mstemail_accounts where email_account_id=x.email_account_id;

				l_acct_info(Y).account_id := x.email_account_id;
    			l_acct_info(Y).action := x.action_type;
				l_acct_info(Y).update_flag := x.account_update_flag;
				l_acct_info(Y).user_name := account_rec.user_name;
				--l_acct_info(Y).user_password := account_rec.user_password;
				l_acct_info(Y).in_host := account_rec.in_host;
				l_acct_info(Y).in_port := account_rec.in_port;

	 			Y := Y+1;
			end if;
	end LOOP;

	x_acct_info := l_acct_info;

    --Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;


EXCEPTION
   WHEN e_nowait THEN
     NULL;

   WHEN FND_API.G_EXC_ERROR THEN
  	     ROLLBACK TO GET_ACCOUNT_INFO_pvt;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
  			( p_count => x_msg_count,p_data => x_msg_data);


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO GET_ACCOUNT_INFO_pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,p_data => x_msg_data);


   WHEN OTHERS THEN
	  ROLLBACK TO GET_ACCOUNT_INFO_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
      END IF;

	  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count	,p_data	=> x_msg_data);

END ;


PROCEDURE DELETE_ITEMS (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
                 x_return_status	   OUT NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT NOCOPY VARCHAR2
			 )
IS
    l_api_name		        varchar2(30):='GET_ACCOUNT_INFO';
    l_api_version_number    number:=1.0;

    l_acct_info    		 acct_info_tbl;
	Y 					 number;
 	account_rec IEM_MSTEMAIL_ACCOUNTS%ROWTYPE;

 	e_nowait	EXCEPTION;
 	PRAGMA	EXCEPTION_INIT(e_nowait, -54);

BEGIN

    --Standard Savepoint
    SAVEPOINT GET_ACCOUNT_INFO_pvt;

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

    --Actual API starts here
	delete iem_emta_config_params where flag='A';

    --Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;


EXCEPTION
   WHEN e_nowait THEN
     NULL;

   WHEN FND_API.G_EXC_ERROR THEN
  	     ROLLBACK TO GET_ACCOUNT_INFO_pvt;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
  			( p_count => x_msg_count,p_data => x_msg_data);


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO GET_ACCOUNT_INFO_pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,p_data => x_msg_data);


   WHEN OTHERS THEN
	  ROLLBACK TO GET_ACCOUNT_INFO_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
      END IF;

	  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count	,p_data	=> x_msg_data);

END ;


FUNCTION is_data_changed ( 	 p_email_account_id 		IN number,
	  					 	 P_ACTIVE_FLAG 				IN varchar2,
		  					 P_USER_NAME 				IN varchar2,
		  					 P_USER_PASSWORD 			IN varchar2,
						  	 P_IN_HOST 					IN varchar2,
		  					 P_IN_PORT 					IN varchar2,
							 x_is_acct_updated 			OUT NOCOPY varchar2 )
return boolean
is
  l_data_changed boolean;
  l_active_flag varchar2(1);
  l_user_name varchar2(100);
  l_user_pwd varchar2(100);
  l_encrypt_key varchar2(100);
  l_in_host varchar2(256);
  l_in_port varchar2(15);
  l_decrypted_pwd varchar2(256);

  l_is_acct_updated varchar2(1);
  IEM_FAILED_DECRYPT_ACCT_PWD EXCEPTION;
BEGIN
	 l_data_changed := false;
	 l_is_acct_updated := 'N';

	 --select active_flag, user_name, user_password, encrypt_key, in_host, in_port
	 select active_flag, user_name, in_host, in_port
	 into l_active_flag, l_user_name, l_in_host, l_in_port
	 from iem_mstemail_accounts where email_account_id = p_email_account_id ;

	 /*
	 IEM_UTILS_PVT.IEM_DecryptPassword(
							p_api_version_number =>1.0,
                     		p_init_msg_list => 'T',
                    		p_commit => 'T',
        					p_input_data =>  l_user_pwd,
							p_decrypted_key => l_encrypt_key,
        					x_decrypted_data => l_decrypted_pwd ,
                            x_return_status =>l_return_status,
                            x_msg_count   => l_msg_count,
                            x_msg_data => l_msg_data);

	 if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
             raise IEM_FAILED_DECRYPT_ACCT_PWD;
     end if;
		*/
	l_decrypted_pwd := fnd_vault.get('IEM', p_email_account_id );

	 if ( l_active_flag <> P_ACTIVE_FLAG ) then
	 	l_data_changed := true;
	 end if;

	 --fixme
	 if ( l_user_name = P_USER_NAME and l_decrypted_pwd=P_USER_PASSWORD and l_in_host = P_IN_HOST and l_in_port = P_IN_PORT ) then
	 --if ( l_user_name = RTRIM(LTRIM(P_USER_NAME)) and l_user_pwd=RTRIM(LTRIM(P_USER_PASSWORD))
	 --	and l_in_host = RTRIM(LTRIM(P_IN_HOST)) and l_in_port = RTRIM(LTRIM(P_IN_PORT)) ) then
	 	null;
	 else
	 	l_is_acct_updated := 'Y';
		l_data_changed := true;
	 end if;

	 x_is_acct_updated := l_is_acct_updated;

	 return l_data_changed;

EXCEPTION/*
    WHEN IEM_FAILED_DECRYPT_ACCT_PWD THEN

	 	x_is_acct_updated := l_is_acct_updated;


        --FND_MESSAGE.SET_NAME('IEM', 'IEM_INVALID_DATA_DO_NOTHING');

        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

        if fnd_log.test(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_EMTA_ADMIN_PVT.UPDATE_DP_CONFIG_DATA_WRAP') then
            logMessage := '[input data is invalid, no data inserted to IEM_EMTA_CONFIG_PARAMS,return true!]';
			dbms_output.put_line(logMessage);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_EMTA_ADMIN_PVT.UPDATE_DP_CONFIG_DATA_WRAP', logMessage);
        end if;
		*/ when others then
		 null;

		return l_data_changed;
END is_data_changed;


PROCEDURE CHECK_IF_ACCOUNT_UPDATED(
 		  				  	 p_api_version_number  IN   NUMBER,
		  					 p_init_msg_list       IN   VARCHAR2 := null,
		  					 p_commit              IN   VARCHAR2 := null,
		  					 p_email_account_id 		IN number,
	  					 	 P_ACTIVE_FLAG 				IN varchar2,
		  					 P_USER_NAME 				IN varchar2,
		  					 P_USER_PASSWORD 			IN varchar2,
						  	 P_IN_HOST 					IN varchar2,
		  					 P_IN_PORT 					IN varchar2,
							 x_is_data_changed		OUT NOCOPY varchar2,
							 x_is_acct_updated 		OUT NOCOPY varchar2,
		  					 x_return_status        OUT  NOCOPY VARCHAR2,
		  					 x_msg_count    		OUT  NOCOPY NUMBER,
		  					 x_msg_data             OUT  NOCOPY VARCHAR2 )
	 is
	l_api_name        		VARCHAR2(255):='CHECK_IF_ACCOUNT_UPDATED';
	l_api_version_number 	NUMBER:=1.0;

    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);

  l_data_changed varchar2(1);
  l_active_flag varchar2(1);
  l_user_name varchar2(100);
  l_user_pwd varchar2(100);
  l_encrypt_key varchar2(100);
  l_in_host varchar2(256);
  l_in_port varchar2(15);
  l_decrypted_pwd varchar2(256);

  l_is_acct_updated varchar2(1);
  IEM_FAILED_DECRYPT_ACCT_PWD EXCEPTION;
	l_count 					 NUMBER;
    errorMessage varchar2(2000);
    logMessage varchar2(2000);

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		CHECK_IF_ACCOUNT_UPDATED_PVT;

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

   --begins here
	 x_is_acct_updated := 'N';
	 x_is_data_changed := 'N';

 	 l_data_changed := 'N';
	 l_is_acct_updated := 'N';

	 --select active_flag, user_name, user_password, encrypt_key, in_host, in_port
	 select active_flag, user_name,  in_host, in_port
	 into l_active_flag, l_user_name, l_in_host, l_in_port
	 from iem_mstemail_accounts where email_account_id = p_email_account_id ;

	 if ( l_active_flag <> P_ACTIVE_FLAG ) then
	 	l_data_changed := 'Y';
	 end if;

	 if ( P_USER_PASSWORD is null or P_USER_PASSWORD = '') then

		if ( l_user_name = P_USER_NAME  and l_in_host = P_IN_HOST and l_in_port = P_IN_PORT ) then
	 	 	null;
	 	else
	 		l_is_acct_updated := 'Y';
			l_data_changed := 'Y';
	 	end if;

	 else
	 	 /*

	 	IEM_UTILS_PVT.IEM_DecryptPassword(
							p_api_version_number =>1.0,
                     		p_init_msg_list => 'T',
                    		p_commit => 'T',
        					p_input_data =>  l_user_pwd,
							p_decrypted_key => l_encrypt_key,
        					x_decrypted_data => l_decrypted_pwd ,
                            x_return_status =>l_return_status,
                            x_msg_count   => l_msg_count,
                            x_msg_data => l_msg_data);

	 	if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
             raise IEM_FAILED_DECRYPT_ACCT_PWD;
     	end if;
		*/
		l_decrypted_pwd := fnd_vault.get('IEM', p_email_account_id );

	 	if ( l_user_name = P_USER_NAME and l_decrypted_pwd=P_USER_PASSWORD and l_in_host = P_IN_HOST and l_in_port = P_IN_PORT ) then
	 	 	null;
	 	else
	 		l_is_acct_updated := 'Y';
			l_data_changed := 'Y';
	 	end if;

	 end if;



	 x_is_acct_updated := l_is_acct_updated;
	 x_is_data_changed := l_data_changed;

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
    WHEN IEM_FAILED_DECRYPT_ACCT_PWD THEN
        ROLLBACK TO CHECK_IF_ACCOUNT_UPDATED_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('IEM', 'IEM_FAILED_DECRYPT_ACCT_PWD');

        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

        if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            logMessage := '[Unable to descript password for account_id=' || p_email_account_id ||'!]';
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_EMTA_ADMIN_PVT.CHECK_IF_ACCOUNT_UPDATED', logMessage);
        end if;


	WHEN FND_API.G_EXC_ERROR THEN
		 ROLLBACK TO CHECK_IF_ACCOUNT_UPDATED_PVT;
       	 x_return_status := FND_API.G_RET_STS_ERROR ;
       	 FND_MSG_PUB.Count_And_Get

			( p_count => x_msg_count,
              p_data  => x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO CHECK_IF_ACCOUNT_UPDATED_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  =>      x_msg_data
			);

   WHEN OTHERS THEN
	ROLLBACK TO CHECK_IF_ACCOUNT_UPDATED_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	FND_MSG_PUB.Add_Exc_Msg
	    	(	G_PKG_NAME ,
	    		l_api_name
	    	);
	END IF;

	FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data

    		);

 END CHECK_IF_ACCOUNT_UPDATED;

END;

/
