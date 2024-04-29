--------------------------------------------------------
--  DDL for Package Body IEM_DP_MONITORING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_DP_MONITORING_PVT" AS
/* $Header: iemvmonb.pls 120.13 2006/05/19 14:05:04 rtripath noship $ */

--
--
-- Purpose: Mantain Download  Processor monitoring data
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia   02/25/2005   Created
--  Liang Xia   08/05/2005   Updated cleanup_monitoring_data
--  Liang Xia   08/09/2005   Changed DP service name
--  Liang Xia   08/15/2005   GET_DP_RUNNING_STATUS
--  Liang Xia   08/24/2005   Fixed bug: filter out deleted account
--  Liang Xia   10/07/2005   Fixed bug 4628971
--		  					 R12UT:950 - ICON FOR STATUS NEEDS TO BE NOT STARTED WHEN DP STARTED
--  Liang Xia   10/07/2005   Fixed bug 4628959
--		  					 R12UT:950 - PROCESSOR STATUS FOR NEW ACTIVE ACCOUNTS INCORRECT
--  Liang Xia   11/07/2005   Fixed bug 4628955
-- ---------   ------  ------------------------------------------

-- Enter procedure, function bodies as shown below
G_PKG_NAME CONSTANT varchar2(30) :='IEM_DP_MONITORING_PVT ';
G_created_updated_by   NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
G_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ ID') ) ;

PROCEDURE CREATE_DP_ACCT_STATUS (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
            	 P_acct_id			   IN   number,
                 p_inbox_count         IN   number,
                 p_processed_count     IN   number,
				 p_retry_count     	   IN   number,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='CREATE_DP_ACCT_STATUS';
	l_api_version_number 	NUMBER:=1.0;
    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);
    l_seq_id		        NUMBER := 10000;


    logMessage              varchar2(2000);


BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		create_item_PVT;

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

    --get next sequential number
   	SELECT IEM_DP_ACCT_STATUS_S1.nextval
	INTO l_seq_id
	FROM dual;

	INSERT INTO IEM_DP_ACCT_STATUS
	(
	DP_ACCT_STATUS_ID,
	EMAIL_ACCOUNT_ID,
	INBOX_MSG_COUNT,
	PROCESSED_MSG_COUNT,
	RETRY_MSG_COUNT,
    CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN
	)
	VALUES
	(
	l_seq_id,
	P_ACCT_ID,
	P_INBOX_COUNT,
	P_PROCESSED_COUNT,
    P_RETRY_COUNT,
    decode(G_created_updated_by,null,-1,G_created_updated_by),
	sysdate,
    decode(G_created_updated_by,null,-1,G_created_updated_by),
    sysdate,
    decode(G_LAST_UPDATE_LOGIN,null,-1,G_LAST_UPDATE_LOGIN)
	);
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
	ROLLBACK TO create_item_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;

       FND_MSG_PUB.Count_And_Get

			( p_count => x_msg_count,
              p_data  => x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO create_item_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  =>      x_msg_data
			);

   WHEN OTHERS THEN
	ROLLBACK TO create_item_PVT;
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
 END;


PROCEDURE RECORD_ACCT_STATUS (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
            	 P_acct_id			   IN   number,
                 p_inbox_count         IN   number,
                 p_processed_count     IN   number,
				 p_retry_count     	   IN   number,
				 p_error_flag		   IN   number,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='RECORD_ACCT_STATUS';
	l_api_version_number 	NUMBER:=1.0;

	l_count					NUMBER ;
    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		create_item_PVT;

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

    select count(DP_ACCT_STATUS_ID) into l_count from IEM_DP_ACCT_STATUS where email_account_id=p_acct_id;

	--Check if account record already exist,
	-- if existed, updated record
	-- else create new records.
	if l_count > 0 then
	   if p_error_flag = 0 then
                IEM_DP_MONITORING_PVT.update_dp_acct_status(
                            p_api_version_number    => P_Api_Version_Number,
                            p_init_msg_list         => FND_API.G_FALSE,
                            p_commit                => P_Commit,
            	 			P_acct_id			    => P_acct_id,
	                 		p_inbox_count           => p_inbox_count,
                 			p_processed_count     	=> p_processed_count,
					 		p_retry_count     	  	=> p_retry_count,
                            x_return_status         =>l_return_status,
                            x_msg_count             => l_msg_count,
                            x_msg_data              => l_msg_data);
				if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
				   x_return_status := FND_API.G_RET_STS_ERROR;
                end if;
	   else
		  update IEM_DP_ACCT_STATUS set LAST_UPDATE_DATE = sysdate where email_account_id=P_acct_id;
	   end if;
	else
                IEM_DP_MONITORING_PVT.create_dp_acct_status(
                            p_api_version_number    => P_Api_Version_Number,
                            p_init_msg_list         => FND_API.G_FALSE,
                            p_commit                => P_Commit,
            	 			P_acct_id			    => P_acct_id,
	                 		p_inbox_count           => p_inbox_count,
                 			p_processed_count     	=> p_processed_count,
					 		p_retry_count     	  	=> p_retry_count,
                            x_return_status         =>l_return_status,
                            x_msg_count             => l_msg_count,
                            x_msg_data              => l_msg_data);

                if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
				   x_return_status := FND_API.G_RET_STS_ERROR;
                end if;

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
	ROLLBACK TO create_item_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;

       FND_MSG_PUB.Count_And_Get

			( p_count => x_msg_count,
              p_data  => x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO create_item_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  =>      x_msg_data
			);

   WHEN OTHERS THEN
	ROLLBACK TO create_item_PVT;
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
 END;

PROCEDURE UPDATE_DP_ACCT_STATUS (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
            	 P_acct_id			   IN   number,
                 p_inbox_count         IN   number,
                 p_processed_count     IN   number,
				 p_retry_count     	   IN   number,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='UPDATE_DP_ACCT_STATUS';
	l_api_version_number 	NUMBER:=1.0;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		create_item_PVT;

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

	UPDATE IEM_DP_ACCT_STATUS
	set
	INBOX_MSG_COUNT = P_INBOX_COUNT,
	PROCESSED_MSG_COUNT = P_PROCESSED_COUNT,
	RETRY_MSG_COUNT = P_RETRY_COUNT,
	LAST_UPDATED_BY = decode(G_created_updated_by,null,-1,G_created_updated_by),
	LAST_UPDATE_DATE = sysdate,
	LAST_UPDATE_LOGIN = decode(G_created_updated_by,null,-1,G_created_updated_by)
	where
	EMAIL_ACCOUNT_ID = p_acct_id;

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
	ROLLBACK TO create_item_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;

       FND_MSG_PUB.Count_And_Get

			( p_count => x_msg_count,
              p_data  => x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO create_item_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  =>      x_msg_data
			);

   WHEN OTHERS THEN
	ROLLBACK TO create_item_PVT;
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
 END;


PROCEDURE CREATE_PROCESS_STATUS (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
            	 P_process_id		   IN   VARCHAR2,
				 x_status_id	       OUT	NOCOPY NUMBER,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='CREATE_PROCESS_STATUS';
	l_api_version_number 	NUMBER:=1.0;
    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;

    l_seq_id		        NUMBER := 10000;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		create_item_PVT;

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


    --get next sequential number
   	SELECT IEM_DP_PROCESS_STATUS_S1.nextval
	INTO l_seq_id
	FROM dual;

	INSERT INTO IEM_DP_PROCESS_STATUS
	(
	DP_PROCESS_STATUS_ID,
	PROCESS_ID,
	PROCESSED_MSG_COUNT,
	RETRY_MSG_COUNT,
    CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN
	)
	VALUES
	(
	l_seq_id,
	P_PROCESS_ID,
	0,
	0,
    decode(G_created_updated_by,null,-1,G_created_updated_by),
	sysdate,
    decode(G_created_updated_by,null,-1,G_created_updated_by),
    sysdate,
    decode(G_LAST_UPDATE_LOGIN,null,-1,G_LAST_UPDATE_LOGIN)
	);

	x_status_id := l_seq_id;

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
	ROLLBACK TO create_item_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;

       FND_MSG_PUB.Count_And_Get

			( p_count => x_msg_count,
              p_data  => x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO create_item_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  =>      x_msg_data
			);

   WHEN OTHERS THEN
	ROLLBACK TO create_item_PVT;
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
 END;

PROCEDURE cleanup_monitoring_data
             (p_api_version_number      IN  NUMBER,
              P_init_msg_list           IN  VARCHAR2 := null,
              p_commit                  IN  VARCHAR2 := null,
			  p_preproc_sleep			IN  NUMBER,
			  p_postproc_sleep      	IN  NUMBER,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2)
IS
    l_api_name		        varchar2(30):='cleanup_monitoring_data_PVT';
    l_api_version_number    number:=1.0;
    logMessage              varchar2(2000);

	l_count					NUMBER ;
    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);

	IEM_ERR_QUE_RESET  EXCEPTION;
BEGIN

    --Standard Savepoint
    SAVEPOINT  cleanup_monitoring_data_PVT;

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


    DELETE
    FROM IEM_DP_PROCESS_STATUS;

	DELETE
	FROM IEM_DP_LOGS;


	IEM_PP_QUEUE_PVT.reset_data (
                            p_api_version_number    =>P_Api_Version_Number,
                            p_init_msg_list         => FND_API.G_FALSE,
                            p_commit                => 'F',
                            x_return_status         =>l_return_status,
                            x_msg_count             => l_msg_count,
                            x_msg_data              => l_msg_data);

	if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
        raise IEM_ERR_QUE_RESET;
    end if;

	-- Insert parameters into iem_comp_rt_stats
	delete IEM_COMP_RT_STATS where type='DOWNLOAD PROCESSOR';

	IEM_COMP_RT_STATS_PVT.create_item (
							p_api_version_number    =>P_Api_Version_Number,
                            p_init_msg_list         => FND_API.G_FALSE,
                            p_commit                => 'F',
  			     			p_type => 'DOWNLOAD PROCESSOR',
                            p_param => 'POSTPROC_SLEEP_DURATION',
                            p_value => p_postproc_sleep,
                            x_return_status         =>l_return_status,
                            x_msg_count             => l_msg_count,
                            x_msg_data              => l_msg_data);

	if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
        raise IEM_ERR_QUE_RESET;
    end if;

	IEM_COMP_RT_STATS_PVT.create_item (
							p_api_version_number    =>P_Api_Version_Number,
                            p_init_msg_list         => FND_API.G_FALSE,
                            p_commit                => 'F',
  			     			p_type => 'DOWNLOAD PROCESSOR',
                            p_param => 'PREPROC_SLEEP_DURATION',
                            p_value => p_preproc_sleep,
                            x_return_status         =>l_return_status,
                            x_msg_count             => l_msg_count,
                            x_msg_data              => l_msg_data);


	if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
        raise IEM_ERR_QUE_RESET;
    end if;

    --Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get
  			( p_count => x_msg_count,p_data => x_msg_data);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
  	     ROLLBACK TO cleanup_monitoring_data_PVT;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
  			( p_count => x_msg_count,p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO cleanup_monitoring_data_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,p_data => x_msg_data);


   WHEN OTHERS THEN
	  ROLLBACK TO cleanup_monitoring_data_PVT;

      x_return_status := FND_API.G_RET_STS_ERROR;
	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
      END IF;
	  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count	,p_data	=> x_msg_data);

END cleanup_monitoring_data;


PROCEDURE GET_DP_RUNNING_STATUS
             (p_api_version_number      IN  NUMBER,
              P_init_msg_list           IN  VARCHAR2 := null,
              p_commit                  IN  VARCHAR2 := null,
			  p_mode                  	IN  VARCHAR2 := null,
			  x_DP_STATUS			    OUT NOCOPY VARCHAR2,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2)
is
	l_api_name        		VARCHAR2(255):='GET_DP_RUNNING_STATUS';
	l_api_version_number 	NUMBER:=1.0;

	y number :=1;
	l_count number;
	l_instance FND_CONCURRENT.Service_Instance_Tab_Type;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		GET_DP_RUNNING_STATUS;

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

    l_instance := FND_CONCURRENT.Get_Service_Instances('IEMDPDEV');

	 if ( l_instance is not null ) then

		l_count := l_instance.count;

		while y <= l_count loop
			if ( p_mode = 'N' ) then

			  if ( l_instance(y).Instance_Name = 'DownloadProcessorNormalMode') then
				 if ( l_instance(y).State = 'ACTIVE' ) then
				 	x_DP_STATUS := 'Active';
				 elsif ( l_instance(y).State='INACTIVE' or l_instance(y).State='DISABLED') then
				 	x_DP_STATUS := 'NotStarted';
				 else
				 	x_DP_STATUS := 'Inactive';
				 end if;

				 exit;
			  end if;
			 else

			  if ( l_instance(y).Instance_Name = 'DownloadProcessorMigrationMode') then
				 if ( l_instance(y).State = 'ACTIVE' ) then
				 	x_DP_STATUS := 'Active';
				 elsif ( l_instance(y).State='INACTIVE' or l_instance(y).State='DISABLED') then
				 	x_DP_STATUS := 'NotStarted';
				 else
				 	x_DP_STATUS := 'Inactive';
				 end if;

				 exit;
			  end if;
			 end if;

			  y := Y+1;
		end loop;
	 end if;

    -- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

    -- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			(    p_count =>  x_msg_count,
                p_data  =>    x_msg_data
			);
EXCEPTION


    WHEN FND_API.G_EXC_ERROR THEN

	   ROLLBACK TO GET_DP_RUNNING_STATUS;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
               	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   ROLLBACK TO GET_DP_RUNNING_STATUS;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
            	p_data  =>      x_msg_data
            );
   WHEN OTHERS THEN

	ROLLBACK TO GET_DP_RUNNING_STATUS;
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
    		( p_count         	=>      x_msg_count ,
        	p_data          	=>      x_msg_data
    		);

END	GET_DP_RUNNING_STATUS;


PROCEDURE GET_ACCOUNT_DP_STATUS
             (p_api_version_number      IN  NUMBER,
              P_init_msg_list           IN  VARCHAR2 := null,
              p_commit                  IN  VARCHAR2 := null,
			  P_view_all_accounts		IN  VARCHAR2,
			  x_account_ids				OUT NOCOPY jtf_number_Table,
			  x_email_address			OUT NOCOPY jtf_varchar2_Table_200,
			  x_account_status			OUT NOCOPY jtf_varchar2_Table_100,
			  x_processor_status		OUT NOCOPY jtf_varchar2_Table_100,
			  x_last_run_time			OUT NOCOPY jtf_date_Table,
			  x_inbox_msg_count			OUT NOCOPY jtf_number_Table,
			  x_process_msg_count		OUT NOCOPY jtf_number_Table,
			  x_retry_msg_count			OUT NOCOPY jtf_number_Table,
			  x_log						OUT NOCOPY jtf_varchar2_Table_100,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2)
is
	l_api_name        		VARCHAR2(255):='GET_ACCOUNT_DP_STATUS';
	l_api_version_number 	NUMBER:=1.0;

    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);

	l_dp_status				VARCHAR2(10);
	l_proc_status			date; --VARCHAR2(50); --Date;
	l_count_error 			NUMBER;
	i number;
	l_pre_sleep number := 60000;
	l_count number;

			 l_account_ids jtf_number_Table := jtf_number_Table();
			 l_email_address jtf_varchar2_Table_200 := jtf_varchar2_Table_200();
			  l_account_status	jtf_varchar2_Table_100 := jtf_varchar2_Table_100();
			  l_processor_status jtf_varchar2_Table_100:= jtf_varchar2_Table_100();
			  l_last_run_time jtf_date_Table:= jtf_date_Table();
			  l_inbox_msg_count jtf_number_Table:= jtf_number_Table();
			  l_process_msg_count jtf_number_Table:= jtf_number_Table();
			  l_retry_msg_count jtf_number_Table:= jtf_number_Table();
			  l_log jtf_varchar2_Table_100:= jtf_varchar2_Table_100();

    cursor c_results is

 		  select a.email_account_id, a.email_address, a.active_flag, fl.meaning as account_status,
		   b.last_update_date as processor_status, b.last_update_date as last_run_time,
		   b.inbox_msg_count, b.processed_msg_count, b.retry_msg_count,
		   (select count(*) from iem_dp_logs where email_account_id = a.email_account_id) as log
		   from iem_mstemail_accounts a, iem_dp_acct_status b, fnd_lookups fl
		   where a.email_account_id = b.email_account_id
		   and a.active_flag=fl.lookup_code and fl.lookup_type='IEM_ACCOUNT_STATUS'
		   and a.active_flag='Y' and a.deleted_flag='N'
		   order by a.email_address desc;

    cursor c_all_results is

   		  select a.email_account_id, a.email_address, a.active_flag, fl.meaning as account_status,
		   b.last_update_date as processor_status, b.last_update_date as last_run_time,
		   b.inbox_msg_count, b.processed_msg_count, b.retry_msg_count,
		   (select count(*) from iem_dp_logs where email_account_id = a.email_account_id) as log
		   from iem_mstemail_accounts a, iem_dp_acct_status b,fnd_lookups fl
		   where a.email_account_id = b.email_account_id(+) and a.deleted_flag='N'
		   and a.active_flag<>'M'
		   and a.active_flag=fl.lookup_code and fl.lookup_type='IEM_ACCOUNT_STATUS'
		    order by a.email_address desc;

    IEM_ERROR_GET_DP_STATUS  EXCEPTION;
BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		GET_ACCOUNT_DP_STATUS;

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


  IEM_DP_MONITORING_PVT.get_dp_running_status(
                            p_api_version_number    =>P_Api_Version_Number,
                            p_init_msg_list         => FND_API.G_FALSE,
                            p_commit                => 'F',
							p_mode					=> 'N',
                            x_DP_STATUS			    => l_dp_status,
                            x_return_status         =>l_return_status,
                            x_msg_count             => l_msg_count,
                            x_msg_data              => l_msg_data);

	if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
        raise IEM_ERROR_GET_DP_STATUS;
    end if;

	i:= 1;

	--if ( l_dp_status = 'Active' ) then
		l_pre_sleep := iem_dp_monitoring_pvt.get_parameter('DOWNLOAD PROCESSOR', 'PREPROC_SLEEP_DURATION');


		if ( P_view_all_accounts = 'ONLY_ACTIVE_ACCOUNTS' ) then

		   For v_res in c_results() loop
			  l_account_ids.extend(1);
			  l_email_address.extend(1);
			  l_account_status.extend(1);
			  l_processor_status.extend(1);
			  l_last_run_time.extend(1);
			  l_inbox_msg_count.extend(1);
			  l_process_msg_count.extend(1);
			  l_retry_msg_count.extend(1);
			  l_log.extend(1);

			  l_account_ids(i) := v_res.email_account_id;
			  l_email_address(i) := v_res.email_address;
			  l_account_status(i)	:= v_res.account_status;


			  if ( l_dp_status = 'Active' ) then

				  l_proc_status := v_res.last_run_time;

				  if ( l_proc_status is null ) then
				  		l_processor_status(i) := 'notstartedind_active.gif';
				  elsif ( l_proc_status < sysdate-1/(24*12)-l_pre_sleep*(1/(24*60*60*1000))) then
				  		select count(*) into l_count from iem_emta_config_params
							   where email_account_id=v_res.email_account_id
							   and Account_update_flag='N'
							   and action_type='active';
						if ( l_count > 0 ) then
						   l_processor_status(i) := 'notstartedind_active.gif';
						else
				  	   		l_processor_status(i) := 'criticalind_status.gif';
						end if;
			  	  else
			  	   	   l_processor_status(i) := 'okind_status.gif';
			  	  end if;
			  else
			  	  l_processor_status(i) := 'notstartedind_active.gif';
			  end if;

			  l_last_run_time(i) := v_res.last_run_time;
			  l_inbox_msg_count(i) := v_res.inbox_msg_count;
			  l_process_msg_count(i) := v_res.processed_msg_count;
			  l_retry_msg_count(i) := v_res.retry_msg_count;

			  select count(*) into l_count_error from IEM_DP_LOGS where email_account_id=v_res.email_account_id;

			  if l_count_error > 0 then
			  	 l_log(i) := 'logDetailEnabled'; --'viewwebsites_enabled.gif';
			  else
			  	 l_log(i) := 'logDetailDisabled'; --'viewwebsite_disabled.gif';
			  end if;

			  i := i+1;
		   end loop;

		else --"ALL_ACCOUNT"
		   For v_res in c_all_results() loop
			  l_account_ids.extend(1);
			  l_email_address.extend(1);
			  l_account_status.extend(1);
			  l_processor_status.extend(1);
			  l_last_run_time.extend(1);
			  l_inbox_msg_count.extend(1);
			  l_process_msg_count.extend(1);
			  l_retry_msg_count.extend(1);
			  l_log.extend(1);

			  l_account_ids(i) := v_res.email_account_id;
			  l_email_address(i) := v_res.email_address;
			  --l_proc_status := v_res.account_status;
			  l_account_status(i)	:= v_res.account_status;

			  l_proc_status := v_res.last_run_time;

			  if ( l_dp_status = 'Active' ) then

			  	 if (v_res.active_flag ='N') then

			  	  	l_processor_status(i) := 'notapplicableind_status.gif';
			     else
				 	if ( l_proc_status is null ) then
				  		l_processor_status(i) := 'notstartedind_active.gif';
					elsif ( l_proc_status < sysdate-1/(24*12)-l_pre_sleep*(1/(24*60*60*1000)))  then
						select count(*) into l_count from iem_emta_config_params
							   where email_account_id=v_res.email_account_id
							   and Account_update_flag='N'
							   and action_type='active';
						if ( l_count > 0 ) then
						   l_processor_status(i) := 'notstartedind_active.gif';
						else
				  	   		l_processor_status(i) := 'criticalind_status.gif';
						end if;
			  	  	    --l_processor_status(i) := 'criticalind_status.gif';
			  	  	else
			  	   	   l_processor_status(i) := 'okind_status.gif';
			  	  	end if;

			    end if;
			  else
			  	  l_processor_status(i) := 'notstartedind_active.gif';
			  end if;

			  l_last_run_time(i) := v_res.last_run_time;
			  l_inbox_msg_count(i) := v_res.inbox_msg_count;
			  l_process_msg_count(i) := v_res.processed_msg_count;
			  l_retry_msg_count(i) := v_res.retry_msg_count;

			  select count(*) into l_count_error from IEM_DP_LOGS where email_account_id=v_res.email_account_id;

			  if l_count_error > 0 then
			  	 l_log(i) := 'logDetailEnabled'; --'viewwebsites_enabled.gif';
			  else
			  	 l_log(i) := 'logDetailDisabled'; --'viewwebsite_disabled.gif';
			  end if;

			  i := i+1;
		   end loop;
		end if;


			  x_account_ids := l_account_ids;
			  x_email_address := l_email_address;
			  x_account_status := l_account_status;
			  x_processor_status := l_processor_status;
			  x_last_run_time := l_last_run_time;
			  x_inbox_msg_count	:= l_inbox_msg_count;
			  x_process_msg_count:= l_process_msg_count;
			  x_retry_msg_count	:= l_retry_msg_count;
			  x_log		:= l_log;

    -- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

    -- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			(    p_count =>  x_msg_count,
                p_data  =>    x_msg_data
			);
EXCEPTION

    WHEN IEM_ERROR_GET_DP_STATUS THEN
        ROLLBACK TO GET_ACCOUNT_DP_STATUS;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
               	p_data  =>      x_msg_data
			);

    WHEN FND_API.G_EXC_ERROR THEN

	   ROLLBACK TO GET_ACCOUNT_DP_STATUS;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
               	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   ROLLBACK TO GET_ACCOUNT_DP_STATUS;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
            	p_data  =>      x_msg_data
            );
   WHEN OTHERS THEN

	ROLLBACK TO GET_ACCOUNT_DP_STATUS;
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
    		( p_count         	=>      x_msg_count ,
        	p_data          	=>      x_msg_data
    		);

END	GET_ACCOUNT_DP_STATUS;

FUNCTION get_parameter ( p_type in  varchar2,
		 			   	 p_param in  varchar2 )
		 return number
is
  l_result number := 60000;
  l_value varchar2(15);
BEGIN

		select value into l_value from iem_comp_rt_stats where type=p_type and param=p_param;

		if ( l_value is not null ) then
		   l_result := to_number(l_value);
		end if;

		return l_result;

EXCEPTION
		 when others then
		 	  return l_result;
END;


END IEM_DP_MONITORING_PVT;

/
