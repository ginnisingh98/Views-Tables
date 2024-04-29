--------------------------------------------------------
--  DDL for Package Body IEM_PARAMETERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_PARAMETERS_PVT" as
/* $Header: iemvparb.pls 115.8 2002/12/04 01:23:07 chtang noship $ */
G_PKG_NAME CONSTANT varchar2(30) :='IEM_PARAMETERS_PVT ';

PROCEDURE select_profile (p_api_version_number  IN   NUMBER,
 		          p_init_msg_list  	IN   VARCHAR2 := FND_API.G_FALSE,
		          p_commit	    	IN   VARCHAR2 := FND_API.G_FALSE,
  			  p_profile_name    	IN   VARCHAR2,
  			  x_profile_value OUT NOCOPY  VARCHAR2,
             		  x_return_status OUT NOCOPY  VARCHAR2,
  		  	  x_msg_count	       OUT NOCOPY  NUMBER,
	  	  	  x_msg_data	 OUT NOCOPY  VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='select_profile';
	l_api_version_number 	NUMBER:=1.0;

BEGIN
-- Standard Start of API savepoint
SAVEPOINT		select_profile_PVT;
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

    x_profile_value :=  FND_PROFILE.VALUE_SPECIFIC(p_profile_name);

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
	ROLLBACK TO select_profile_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO select_profile_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);

   WHEN OTHERS THEN
	ROLLBACK TO select_profile_PVT;
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

 END	select_profile;


PROCEDURE update_profile (p_api_version_number  IN   NUMBER,
 		          p_init_msg_list  	IN   VARCHAR2,
		          p_commit	    	IN   VARCHAR2,
  			  p_profile_name    	IN   VARCHAR2,
  			  p_profile_value	IN   VARCHAR2,
             		  x_return_status OUT NOCOPY VARCHAR2,
  		  	  x_msg_count	       OUT NOCOPY NUMBER,
	  	  	  x_msg_data	 OUT NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='update_profile';
	l_api_version_number 	NUMBER:=1.0;
	l_count			NUMBER;
	l_party_relate_count	NUMBER;
	l_party_type		VARCHAR2(30);
	l_party_id		number;
	l_resource_id		number;
	INVALID_DEFAULT_CUSTOMER_NUM EXCEPTION;
	INVALID_DEFAULT_RESOURCE_NUM EXCEPTION;
	PROFILE_NOT_UPDATED EXCEPTION;

BEGIN
-- Standard Start of API savepoint
SAVEPOINT		update_profile_PVT;
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

    -- Validate Default Customer number if the profile name is IEM_DEFAULT_CUSTOMER_NUMBER
   if UPPER(p_profile_name) = 'IEM_DEFAULT_CUSTOMER_NUMBER' then

   	select count(*) into l_count from hz_parties where party_number=p_profile_value;
   	if l_count = 0 then
   		raise INVALID_DEFAULT_CUSTOMER_NUM;
   	end if;

   	-- Convert customer number into customer id
	-- party_id and party_number is a 1 to 1 relationship
	select party_id into l_party_id from hz_parties where party_number=p_profile_value;

	if SQL%ROWCOUNT <> 1 then
		raise PROFILE_NOT_UPDATED;
	end if;

   /*	select party_type into l_party_type from hz_parties where party_number=p_profile_value;
	if l_party_type <> 'PERSON' and l_party_type <> 'PARTY_RELATIONSHIP' then
		raise INVALID_DEFAULT_CUSTOMER_NUM;
	end if;
	*/

	-- Save default customer id profile
	if not FND_PROFILE.SAVE('IEM_DEFAULT_CUSTOMER_ID', l_party_id, 'SITE') then
   		raise PROFILE_NOT_UPDATED;
   	end if;
   -- Validate Default Resource number if the profile name is IEM_DEFAULT_RESOURCE_NUMBER
   elsif UPPER(p_profile_name) = 'IEM_DEFAULT_RESOURCE_NUMBER' then

	if (p_profile_value is null) then
		l_resource_id := '';
	else
		select count(*) into l_count from jtf_rs_resource_extns where resource_number=p_profile_value;
   		if l_count = 0 then
   			raise INVALID_DEFAULT_RESOURCE_NUM;
   		end if;

   		-- Convert resource number into resource id
		-- resource_id and resource_number is a 1 to 1 relationship
		select resource_id into l_resource_id from jtf_rs_resource_extns where resource_number=p_profile_value;

		if SQL%ROWCOUNT <> 1 then
			raise PROFILE_NOT_UPDATED;
		end if;
	end if; -- p_profile_value is null

	-- Save default resource id profile
	if not FND_PROFILE.SAVE('IEM_SRVR_ARES', l_resource_id, 'SITE') then
   		raise PROFILE_NOT_UPDATED;
   	end if;


   end if;

   if not FND_PROFILE.SAVE(p_profile_name, p_profile_value, 'SITE') then
   	raise PROFILE_NOT_UPDATED;
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
   WHEN INVALID_DEFAULT_CUSTOMER_NUM THEN
        ROLLBACK TO update_profile_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('IEM', 'IEM_SSS_INVALID_DEF_CUST_NUM');
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN INVALID_DEFAULT_RESOURCE_NUM THEN
        ROLLBACK TO update_profile_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('IEM', 'IEM_SSS_INVALID_DEF_REST_NUM');
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN PROFILE_NOT_UPDATED THEN
        ROLLBACK TO update_profile_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('IEM', 'IEM_ADMIN_INTENT_N_NOT_UPDATED');
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);


   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO update_profile_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO update_profile_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);

   WHEN OTHERS THEN
	ROLLBACK TO update_profile_PVT;
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

 END	update_profile;

 PROCEDURE update_profile_wrap (p_api_version_number  IN   NUMBER,
 		          p_init_msg_list  	IN   VARCHAR2,
		          p_commit	    	IN   VARCHAR2,
  			  p_profile_name_tbl 	IN   jtf_varchar2_Table_100,
  			  p_profile_value_tbl	IN   jtf_varchar2_Table_100,
             		  x_return_status OUT NOCOPY VARCHAR2,
  		  	  x_msg_count	       OUT NOCOPY NUMBER,
	  	  	  x_msg_data	 OUT NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='update_profile_wrap';
	l_api_version_number 	NUMBER:=1.0;
    	l_return_status       VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    	l_msg_count           NUMBER := 0;
    	l_msg_data            VARCHAR2(2000);
	PROFILE_NOT_UPDATED EXCEPTION;

BEGIN
-- Standard Start of API savepoint
SAVEPOINT		update_profile_PVT;
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

     FOR i IN p_profile_name_tbl.FIRST..p_profile_name_tbl.LAST LOOP

     	iem_parameters_pvt.update_profile (p_api_version_number => l_api_version_number,
 		          p_init_msg_list => FND_API.G_FALSE,
		          p_commit => FND_API.G_FALSE,
  			  p_profile_name => p_profile_name_tbl(i),
  			  p_profile_value => p_profile_value_tbl(i),
             		  x_return_status=> l_return_status,
  		  	  x_msg_count => l_msg_count,
	  	  	  x_msg_data => l_msg_data);

      	if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
        	raise PROFILE_NOT_UPDATED;
   	end if;

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

   WHEN PROFILE_NOT_UPDATED THEN
        ROLLBACK TO update_profile_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);


   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO update_profile_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO update_profile_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);

   WHEN OTHERS THEN
	ROLLBACK TO update_profile_PVT;
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

 END	update_profile_wrap;

 END IEM_PARAMETERS_PVT ;

/
