--------------------------------------------------------
--  DDL for Package Body EDR_TRANS_ACKN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_TRANS_ACKN_PVT" as
/* $Header: EDRVACKB.pls 120.0.12000000.1 2007/01/18 05:55:58 appldev ship $ */

-- Private Utility Functions --

function IS_STATUS_VALID
( p_status               IN             VARCHAR2			   ,
  p_mode                 IN             VARCHAR2
)
RETURN BOOLEAN
is
	l_return_value   BOOLEAN := TRUE;
begin
	--when a row is being inserted only the NOTACKNOWLEDGED status is valid.
	--along with the one time migration value of NOTCOLLECTED
	--the insert happens privately in the ERES Fwk

	if (p_mode = G_INSERT_MODE)
	then
		if  p_status <> EDR_CONSTANTS_GRP.g_no_ack_status
		and p_status <> EDR_CONSTANTS_GRP.g_migration_ack_status
		then
			l_return_value := FALSE;
		end if;

	--when a row is being updated only the SUCCESS and ERROR are valid
	--the upadate happens publicly by product teams

	elsif (p_mode = G_UPDATE_MODE)
	then
		if  p_status <> EDR_CONSTANTS_GRP.g_success_ack_status
		and p_status <> EDR_CONSTANTS_GRP.g_error_ack_status
		then
			l_return_value := FALSE;
		end if;
	end if;

	return l_return_value;

end IS_STATUS_VALID;

procedure INSERT_ROW
( p_api_version          IN		NUMBER		        ,
  p_init_msg_list	 IN		VARCHAR2 		,
  p_validation_level	 IN  		NUMBER   		,
  x_return_status	 OUT NOCOPY	VARCHAR2	        ,
  x_msg_count		 OUT NOCOPY NUMBER		        ,
  x_msg_data		 OUT NOCOPY	VARCHAR2	        ,
  p_erecord_id	         IN		NUMBER		        ,
  p_trans_status	 IN		VARCHAR2	        ,
  p_ackn_by              IN             VARCHAR2                ,
  p_ackn_note	         IN		VARCHAR2                ,
  x_ackn_id              OUT NOCOPY     NUMBER
)
as
	l_api_name	CONSTANT VARCHAR2(30)	:= 'INSERT_ROW';
	l_api_version   CONSTANT NUMBER 	:= 1.0;

	l_return_status		 VARCHAR2(1);
	l_msg_count		 NUMBER;
	l_msg_data		 VARCHAR2(2000);
	l_mesg_text		 VARCHAR2(2000);

  	L_CREATION_DATE       	 DATE;
  	L_CREATED_BY           	 NUMBER;
  	L_LAST_UPDATE_DATE    	 DATE;
  	L_LAST_UPDATED_BY     	 NUMBER;
  	L_LAST_UPDATE_LOGIN   	 NUMBER;

	l_valid_status           BOOLEAN;
	l_ackn_id                NUMBER;
	l_existing_ack_count	 PLS_INTEGER;

	INVALID_ERECORD_ERROR	 EXCEPTION;
	INVALID_ACK_STATUS_ERROR EXCEPTION;
	DUPLICATE_ACK_ERROR	 EXCEPTION;

	cursor l_ack_csr is
	select count(ackn_id)
	from edr_trans_ackn
	where erecord_id = p_erecord_id;

begin
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

		-- validate if this is a duplicate acknowledgement
		if p_validation_level >= G_VALIDATE_DUP_ACK then
			open l_ack_csr;

			fetch l_ack_csr into l_existing_ack_count;

			if (l_existing_ack_count > 0) then
				RAISE DUPLICATE_ACK_ERROR;
			end if;

			close l_ack_csr;

		end if;

		-- validate if the erecord id is valid
		if p_validation_level >= G_VALIDATE_ERECORD then
			EDR_ERES_EVENT_PUB.VALIDATE_ERECORD
			( p_api_version     => 1.0,
			  x_return_status   => l_return_status,
			  x_msg_count       => l_msg_count,
			  x_msg_data        => l_msg_data,
			  p_erecord_id      => p_erecord_id
			);

			-- If any errors happen abort API.
			IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
				RAISE INVALID_ERECORD_ERROR;
			END IF;
		end if;

		-- validate if the status is valid
		if p_validation_level >= G_VALIDATE_STATUS then
			l_valid_status := IS_STATUS_VALID
					  ( p_status   => p_trans_status    ,
					    p_mode    => G_INSERT_MODE
					  );

			if not l_valid_status then
				RAISE INVALID_ACK_STATUS_ERROR;
			end if;
		end if;

	END IF; --if for validation check

	-- after all the validations are done, insert the row in the
	-- database

	select edr_trans_ackn_s.nextval
	into l_ackn_id
	from dual;

	EDR_UTILITIES.getWhoColumns
	( creation_date 	=> l_creation_date	,
	  created_by    	=> l_created_by		,
	  last_update_date	=> l_last_update_date	,
	  last_updated_by	=> l_last_updated_by	,
	  last_update_login	=> l_last_update_login
	);

	insert into EDR_TRANS_ACKN(
	       ACKN_ID
	      ,ERECORD_ID
	      ,ACKN_DATE
	      ,TRANSACTION_STATUS
	      ,ACKN_BY
	      ,ACKN_NOTE
	      ,CREATION_DATE
	      ,CREATED_BY
	      ,LAST_UPDATE_DATE
	      ,LAST_UPDATED_BY
	      ,LAST_UPDATE_LOGIN
	) values (
	       l_ackn_id
	      ,p_erecord_id
	      ,SYSDATE
	      ,p_trans_status
	      ,p_ackn_by
	      ,p_ackn_note
	      ,L_CREATION_DATE
	      ,L_CREATED_BY
	      ,L_LAST_UPDATE_DATE
	      ,L_LAST_UPDATED_BY
	      ,L_LAST_UPDATE_LOGIN
	);

	x_ackn_id := l_ackn_id;

	--  End of API Body

	-- Standard call to get message count and if count is 1,
	--get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count        		=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);

EXCEPTION
	WHEN INVALID_ERECORD_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;

		fnd_message.set_name('EDR','EDR_ACK_INVALID_ERECORD');
		fnd_message.set_token('ERECORD_ID', p_erecord_id);
		l_mesg_text := fnd_message.get();

		FND_MSG_PUB.Add_Exc_Msg
		( G_PKG_NAME  	    ,
		  l_api_name   	    ,
		  l_mesg_text
		);
		FND_MSG_PUB.Count_And_Get
    		(  p_count        =>      x_msg_count     ,
        	   p_data         =>      x_msg_data
    		);

	WHEN INVALID_ACK_STATUS_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;

		fnd_message.set_name('EDR','EDR_ACK_INVALID_STATUS');
		fnd_message.set_token('ERECORD_ID', p_erecord_id);
		fnd_message.set_token('STATUS', p_trans_status);
		l_mesg_text := fnd_message.get();

		FND_MSG_PUB.Add_Exc_Msg
		( G_PKG_NAME  	    ,
		  l_api_name   	    ,
		  l_mesg_text
		);
		FND_MSG_PUB.Count_And_Get
    		(  p_count        =>      x_msg_count     ,
        	   p_data         =>      x_msg_data
    		);

	WHEN DUPLICATE_ACK_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;

		--close the cursor that was opened
		close l_ack_csr;

		fnd_message.set_name('EDR','EDR_ACK_DUPLICATE_ACKN');
		fnd_message.set_token('ERECORD_ID', p_erecord_id);
		l_mesg_text := fnd_message.get();

		FND_MSG_PUB.Add_Exc_Msg
		( G_PKG_NAME  	    ,
		  l_api_name   	    ,
		  l_mesg_text
		);
		FND_MSG_PUB.Count_And_Get
    		(  p_count        =>      x_msg_count     ,
        	   p_data         =>      x_msg_data
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

end INSERT_ROW;

procedure SEND_ACKN_AUTO
( p_api_version          IN		NUMBER				   ,
  p_init_msg_list	 IN		VARCHAR2 default FND_API.G_FALSE   ,
  x_return_status	 OUT NOCOPY	VARCHAR2		  	   ,
  x_msg_count		 OUT NOCOPY 	NUMBER				   ,
  x_msg_data		 OUT NOCOPY	VARCHAR2			   ,
  p_event_name           IN            	VARCHAR2  			   ,
  p_event_key            IN            	VARCHAR2  			   ,
  p_erecord_id	         IN		NUMBER			  	   ,
  p_trans_status	 IN		VARCHAR2			   ,
  p_ackn_by              IN             VARCHAR2 default NULL              ,
  p_ackn_note	         IN		VARCHAR2 default NULL
)
as PRAGMA AUTONOMOUS_TRANSACTION;
	l_api_name	CONSTANT VARCHAR2(30)	:= 'SEND_ACKN_AUTO';
	l_api_version   CONSTANT NUMBER 	:= 1.0;

  	L_CREATION_DATE       	 DATE;
  	L_CREATED_BY           	 NUMBER;
  	L_LAST_UPDATE_DATE    	 DATE;
  	L_LAST_UPDATED_BY     	 NUMBER;
  	L_LAST_UPDATE_LOGIN   	 NUMBER;

begin
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

	-- This API is called after all the validations are done
	-- so dont do any validation. just do an update and commit

	EDR_UTILITIES.getWhoColumns
	( creation_date 	=> l_creation_date	,
	  created_by    	=> l_created_by		,
	  last_update_date	=> l_last_update_date	,
	  last_updated_by	=> l_last_updated_by	,
	  last_update_login	=> l_last_update_login
	);

	update EDR_TRANS_ACKN SET
	  ACKN_DATE		= SYSDATE		,
	  TRANSACTION_STATUS    = p_trans_status	,
	  ACKN_BY               = p_ackn_by		,
	  ACKN_NOTE		= p_ackn_note		,
          LAST_UPDATE_DATE      = l_last_update_date	,
	  LAST_UPDATED_BY       = l_last_updated_by	,
	  LAST_UPDATE_LOGIN     = l_last_update_login
	where ERECORD_ID = p_erecord_id;

	-- always commit, this is an autonomous txn
	COMMIT;

EXCEPTION
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

		FND_MSG_PUB.Count_And_Get
    		(  p_count         	=>      x_msg_count     ,
        	   p_data          	=>      x_msg_data
    		);

	WHEN OTHERS THEN
		ROLLBACK;
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

end SEND_ACKN_AUTO;

end EDR_TRANS_ACKN_PVT;

/
