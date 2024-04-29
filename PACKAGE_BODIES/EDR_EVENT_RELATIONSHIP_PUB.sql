--------------------------------------------------------
--  DDL for Package Body EDR_EVENT_RELATIONSHIP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_EVENT_RELATIONSHIP_PUB" as
/* $Header: EDRPRELB.pls 120.0.12000000.1 2007/01/18 05:54:39 appldev ship $ */

-- Private Utility Functions --

-- Start of comments
-- API name             : getWhoColumns
-- Type                 : Private Utility.
-- Function             : Gets the WHO columns for inserting a row
-- Pre-reqs             : None.
-- Parameters           :
-- OUT                  : creation_date         out date
--                        created_by            out number
--                        last_update_date      out date
--                        last_updated_by       out number
--                        last_update_login     out number
--
-- End of comments

PROCEDURE getWhoColumns(creation_date     out nocopy date,
                        created_by        out nocopy number,
                        last_update_date  out nocopy date,
                        last_updated_by   out nocopy number,
                        last_update_login out nocopy number)
is
begin
  creation_date := sysdate;
  created_by := fnd_global.user_id();
  last_update_date := sysdate;
  last_updated_by := fnd_global.user_id();
  last_update_login := fnd_global.login_id();

end getWhoColumns;

procedure CREATE_RELATIONSHIP
( p_api_version          IN		NUMBER				,
  p_init_msg_list	 IN		VARCHAR2 			,
  p_commit	    	 IN  		VARCHAR2 			,
  p_validation_level	 IN  		NUMBER   			,
  x_return_status	 OUT NOCOPY	VARCHAR2		  	,
  x_msg_count		 OUT NOCOPY 	NUMBER				,
  x_msg_data		 OUT NOCOPY	VARCHAR2			,
  P_PARENT_ERECORD_ID    IN         	NUMBER				,
  P_PARENT_EVENT_NAME    IN         	VARCHAR2 			,
  P_PARENT_EVENT_KEY	 IN         	VARCHAR2 			,
  P_CHILD_ERECORD_ID     IN         	NUMBER				,
  P_CHILD_EVENT_NAME     IN         	VARCHAR2 			,
  P_CHILD_EVENT_KEY      IN         	VARCHAR2 			,
  X_RELATIONSHIP_ID      OUT NOCOPY 	NUMBER
)
AS
	l_api_name	CONSTANT VARCHAR2(30)	:= 'CREATE_RELATIONSHIP';
	l_api_version   CONSTANT NUMBER 	:= 1.0;

	l_return_status		 VARCHAR2(1);
	l_msg_count		 NUMBER;
	l_msg_data		 VARCHAR2(2000);

  	L_CREATION_DATE       	 DATE;
  	L_CREATED_BY           	 NUMBER;
  	L_LAST_UPDATE_DATE    	 DATE;
  	L_LAST_UPDATED_BY     	 NUMBER;
  	L_LAST_UPDATE_LOGIN   	 NUMBER;


BEGIN
	-- Standard Start of API savepoint
	SAVEPOINT	CREATE_RELATIONSHIP_PUB;

	-- Standard call to check for call compatibility.
    	IF NOT FND_API.Compatible_API_Call (l_api_version        	,
        	    	    	    	    p_api_version        	,
   	       	    	 		    l_api_name 	    		,
		    	    	    	    G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	--  API Body

	IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN
		VALIDATE_RELATIONSHIP
		( p_api_version		=> 1.0,
  		  x_return_status	=> l_return_status,
  		  x_msg_count		=> l_msg_count,
  		  x_msg_data		=> l_msg_data,
  		  P_PARENT_ERECORD_ID   => p_parent_erecord_id,
  		  P_PARENT_EVENT_NAME   => p_parent_event_name,
  		  P_PARENT_EVENT_KEY	=> p_parent_event_key,
  		  P_CHILD_ERECORD_ID    => p_child_erecord_id,
  		  P_CHILD_EVENT_NAME    => p_child_event_name,
  		  P_CHILD_EVENT_KEY     => p_child_event_key
		);

		-- If any errors happen abort API.
		IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;

	END IF; --end of validation

	-- after all the validations are done, insert the row in the
	-- database

	select edr_event_relationship_s.nextval into x_relationship_id
    	from dual;

    	getWhoColumns(	l_creation_date,
                  	l_created_by,
                  	l_last_update_date,
                  	l_last_updated_by,
                  	l_last_update_login);

    	insert into EDR_EVENT_RELATIONSHIP(
               RELATIONSHIP_ID
              ,PARENT_EVENT_NAME
              ,PARENT_EVENT_KEY
              ,PARENT_ERECORD_ID
              ,CHILD_EVENT_NAME
              ,CHILD_EVENT_KEY
              ,CHILD_ERECORD_ID
              ,CREATION_DATE
              ,CREATED_BY
              ,LAST_UPDATE_DATE
              ,LAST_UPDATED_BY
              ,LAST_UPDATE_LOGIN
    	) values (
               X_RELATIONSHIP_ID
              ,P_PARENT_EVENT_NAME
              ,P_PARENT_EVENT_KEY
              ,P_PARENT_ERECORD_ID
              ,P_CHILD_EVENT_NAME
              ,P_CHILD_EVENT_KEY
              ,P_CHILD_ERECORD_ID
              ,L_CREATION_DATE
              ,L_CREATED_BY
              ,L_LAST_UPDATE_DATE
              ,L_LAST_UPDATED_BY
              ,L_LAST_UPDATE_LOGIN
    	);

	--  End of API Body

	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT;
	END IF;

	-- Standard call to get message count and if count is 1,
	--get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count        	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
		(  	p_count        =>      x_msg_count  ,
       			p_data         =>      x_msg_data
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO CREATE_RELATIONSHIP_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  p_count         	=>      x_msg_count     ,
        	   p_data          	=>      x_msg_data
    		);

	WHEN OTHERS THEN
		ROLLBACK TO CREATE_RELATIONSHIP_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		x_relationship_id := null;

  		IF FND_MSG_PUB.Check_Msg_Level
  				(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
    	    		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME	,
       			 	l_api_name
	    		);
		END IF;

		FND_MSG_PUB.Count_And_Get
    		(p_count         	=>      x_msg_count    ,
        	 p_data          	=>      x_msg_data
    		);


END CREATE_RELATIONSHIP;

PROCEDURE VALIDATE_RELATIONSHIP
( p_api_version          IN		NUMBER				   ,
  p_init_msg_list	 IN		VARCHAR2 ,
  x_return_status	 OUT NOCOPY	VARCHAR2		  	   ,
  x_msg_count		 OUT NOCOPY NUMBER				   ,
  x_msg_data		 OUT NOCOPY	VARCHAR2			   ,
  P_PARENT_ERECORD_ID    IN         NUMBER				   ,
  P_PARENT_EVENT_NAME    IN         VARCHAR2 		   ,
  P_PARENT_EVENT_KEY	 IN         VARCHAR2 		   ,
  P_CHILD_ERECORD_ID     IN         NUMBER				   ,
  P_CHILD_EVENT_NAME     IN         VARCHAR2 		   ,
  P_CHILD_EVENT_KEY      IN         VARCHAR2
)
AS
	l_mesg_text 		 VARCHAR2(2000);

	l_api_name	CONSTANT VARCHAR2(30)	:= 'VALIDATE_RELATIONSHIP';
	l_api_version   CONSTANT NUMBER 	:= 1.0;

	l_return_status		 VARCHAR2(1);
	l_msg_count		 NUMBER;
	l_msg_data		 VARCHAR2(2000);

  	l_event_name		 VARCHAR2(80);
  	l_event_key		 VARCHAR2(240);

	PARENT_ERECORD_ID_ERROR 	EXCEPTION;
	PARENT_EVENT_ERROR 		EXCEPTION;
	INVALID_EVENT_ERROR 		EXCEPTION;
	CHILD_ERECORD_ID_ERROR 		EXCEPTION;
	CHILD_EVENT_ERROR 		EXCEPTION;
BEGIN
	-- Standard call to check for call compatibility.
    	IF NOT FND_API.Compatible_API_Call (l_api_version        	,
        	    	    	    	    p_api_version        	,
   	       	    	 		    l_api_name 	    		,
		    	    	    	    G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	--  API Body

          /* SKARIMIS Bug fix 3134883 */
       if ( p_child_event_name = p_parent_event_name
	  and p_Child_event_key = p_parent_event_key) then
		RAISE INVALID_EVENT_ERROR;
	end if;
          /* ENd of Bug Fix */

	-- validate the parent erecord id
	EDR_ERES_EVENT_PUB.VALIDATE_ERECORD
	( p_api_version         => 1.0				,
	  x_return_status	=> l_return_status  		,
	  x_msg_count		=> l_msg_count			,
	  x_msg_data		=> l_msg_data			,
	  p_erecord_id		=> p_parent_erecord_id
	);

	-- If any errors happen abort API.
	IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE PARENT_ERECORD_ID_ERROR;
	END IF;

	-- Now validate that the parent event name and event key are
	-- valid for the parent erecord id
	EDR_ERES_EVENT_PUB.GET_EVENT_DETAILS
	( p_api_version         => 1.0			,
	  x_return_status	=> l_return_status	,
	  x_msg_count		=> l_msg_count		,
	  x_msg_data		=> l_msg_data		,
	  p_erecord_id  	=> p_parent_erecord_id	,
	  x_event_name  	=> l_event_name		,
	  x_event_key   	=> l_event_key
	);

	if ( l_event_name <> p_parent_event_name
	  OR l_event_key <> p_parent_event_key) then
		RAISE PARENT_EVENT_ERROR;
	end if;

	-- validate the child erecord id
	EDR_ERES_EVENT_PUB.VALIDATE_ERECORD
	( p_api_version         => 1.0				,
	  x_return_status	=> l_return_status  		,
	  x_msg_count		=> l_msg_count			,
	  x_msg_data		=> l_msg_data			,
	  p_erecord_id		=> p_child_erecord_id
	);

	-- If any errors happen abort API.
	IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE CHILD_ERECORD_ID_ERROR;
	END IF;

	-- Now validate that the child event name and event key are
	-- valid for the child erecord id
	EDR_ERES_EVENT_PUB.GET_EVENT_DETAILS
	( p_api_version         => 1.0			,
	  x_return_status	=> l_return_status	,
	  x_msg_count		=> l_msg_count		,
	  x_msg_data		=> l_msg_data		,
	  p_erecord_id  	=> p_child_erecord_id	,
	  x_event_name  	=> l_event_name		,
	  x_event_key   	=> l_event_key
	);

	if ( l_event_name <> p_child_event_name
	  OR l_event_key <> p_child_event_key) then
		RAISE CHILD_EVENT_ERROR;
	end if;

	--  End of API Body

	-- Standard call to get message count and if count is 1,
	--get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count        	=>      x_msg_count     	,
        	p_data          =>      x_msg_data
    	);

EXCEPTION
	WHEN PARENT_ERECORD_ID_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;

		fnd_message.set_name('EDR','EDR_VAL_INVALID_PARENT_ID');
		fnd_message.set_token('ERECORD_ID', p_parent_erecord_id);
		fnd_message.set_token('EVENT_NAME', p_parent_event_name);
		fnd_message.set_token('EVENT_KEY', p_parent_event_key);

		l_mesg_text := fnd_message.get();

    		FND_MSG_PUB.Add_Exc_Msg
		(	G_PKG_NAME  	    ,
    	    		l_api_name    	    ,
    	    		l_mesg_text
	    	);

		FND_MSG_PUB.Count_And_Get
    		(  p_count         	=>      x_msg_count     ,
        	   p_data          	=>      x_msg_data
    		);


	WHEN INVALID_EVENT_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		fnd_message.set_name('EDR','EDR_VAL_INVALID_EVENT');
		l_mesg_text := fnd_message.get();

    		FND_MSG_PUB.Add_Exc_Msg
		(	G_PKG_NAME  	    ,
    	    		l_api_name    	    ,
    	    		l_mesg_text
	    	);

		FND_MSG_PUB.Count_And_Get
    		(  p_count         	=>      x_msg_count     ,
        	   p_data          	=>      x_msg_data
    		);
	WHEN PARENT_EVENT_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;

		fnd_message.set_name('EDR','EDR_VAL_INVALID_PARENT_EVENT');
		fnd_message.set_token('EVENT_NAME', l_event_name);
		fnd_message.set_token('EVENT_KEY', l_event_key);
		l_mesg_text := fnd_message.get();

    		FND_MSG_PUB.Add_Exc_Msg
		(	G_PKG_NAME  	    ,
    	    		l_api_name    	    ,
    	    		l_mesg_text
	    	);

		FND_MSG_PUB.Count_And_Get
    		(  p_count         	=>      x_msg_count     ,
        	   p_data          	=>      x_msg_data
    		);

	WHEN CHILD_ERECORD_ID_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;

		fnd_message.set_name('EDR','EDR_VAL_INVALID_CHILD_ID');
		fnd_message.set_token('ERECORD_ID', p_child_erecord_id);
		l_mesg_text := fnd_message.get();

    		FND_MSG_PUB.Add_Exc_Msg
		(	G_PKG_NAME  	    ,
    	    		l_api_name    	    ,
    	    		l_mesg_text
	    	);

		FND_MSG_PUB.Count_And_Get
    		(  p_count         	=>      x_msg_count     ,
        	   p_data          	=>      x_msg_data
    		);


	WHEN CHILD_EVENT_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;

		fnd_message.set_name('EDR','EDR_VAL_INVALID_CHILD_EVENT');
		fnd_message.set_token('EVENT_NAME', l_event_name);
		fnd_message.set_token('EVENT_KEY', l_event_key);
		l_mesg_text := fnd_message.get();

    		FND_MSG_PUB.Add_Exc_Msg
		(	G_PKG_NAME  	    ,
    	    		l_api_name    	    ,
    	    		l_mesg_text
	    	);

		FND_MSG_PUB.Count_And_Get
    		(  p_count         	=>      x_msg_count     ,
        	   p_data          	=>      x_msg_data
    		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

		FND_MSG_PUB.Count_And_Get
    		(  p_count         	=>      x_msg_count     ,
        	   p_data          	=>      x_msg_data
    		);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  		IF FND_MSG_PUB.Check_Msg_Level
  				(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
    	    		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME	,
       			 	l_api_name
	    		);
		END IF;

		FND_MSG_PUB.Count_And_Get
    		(p_count         	=>      x_msg_count    ,
        	 p_data          	=>      x_msg_data
    		);

END VALIDATE_RELATIONSHIP;

end EDR_EVENT_RELATIONSHIP_PUB;

/
