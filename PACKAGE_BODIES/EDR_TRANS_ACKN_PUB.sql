--------------------------------------------------------
--  DDL for Package Body EDR_TRANS_ACKN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_TRANS_ACKN_PUB" as
/* $Header: EDRPACKB.pls 120.0.12000000.1 2007/01/18 05:54:16 appldev ship $ */

procedure SEND_ACKN
( p_api_version          IN		NUMBER				   ,
  p_init_msg_list	 IN		VARCHAR2 			   ,
  x_return_status	 OUT NOCOPY	VARCHAR2		  	   ,
  x_msg_count		 OUT NOCOPY 	NUMBER				   ,
  x_msg_data		 OUT NOCOPY	VARCHAR2			   ,
  p_event_name           IN            	VARCHAR2  			   ,
  p_event_key            IN            	VARCHAR2  			   ,
  p_erecord_id	         IN		NUMBER			  	   ,
  p_trans_status	 IN		VARCHAR2			   ,
  p_ackn_by              IN             VARCHAR2 			   ,
  p_ackn_note	         IN		VARCHAR2                           ,
  p_autonomous_commit    IN             VARCHAR2
)
as
	l_api_name	CONSTANT VARCHAR2(30)	:= 'SEND_ACKN';
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
	l_status                 VARCHAR2(30);

	l_event_name             VARCHAR2(80);
	l_event_key              VARCHAR2(240);
	l_existing_ack_count     PLS_INTEGER	:= 0;

	cursor l_ack_csr is
	select transaction_status
	from edr_trans_ackn
	where erecord_id = p_erecord_id;

	INVALID_ERECORD_ERROR	 EXCEPTION;
	INVALID_ACK_STATUS_ERROR EXCEPTION;
	INVALID_EVENT_ERROR      EXCEPTION;
	DUPLICATE_ACK_ERROR	 EXCEPTION;
	NO_DATA_ERROR		 EXCEPTION;
begin
/*
	-- Standard Start of API savepoint
	SAVEPOINT	SEND_ACKN_PUB;
*/
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

      -- BEGIN Bug : 3834375. Added Secure context to allow query of all rows
         edr_ctx_pkg.set_secure_attr;
      -- END  Bug : 3834375
	--  API Body

	-- validate that the erecord id is valid and that the event
	-- name and event key are the right ones for the erecord id

	EDR_ERES_EVENT_PUB.GET_EVENT_DETAILS
	( p_api_version         => 1.0			,
	  x_return_status	=> l_return_status	,
	  x_msg_count		=> l_msg_count		,
	  x_msg_data		=> l_msg_data		,
	  p_erecord_id  	=> p_erecord_id		,
	  x_event_name  	=> l_event_name		,
	  x_event_key   	=> l_event_key
	);

	-- If any errors happen abort API.
	IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE INVALID_ERECORD_ERROR;
	END IF;

	if l_event_name <> p_event_name OR l_event_key <> p_event_key
	then
		RAISE INVALID_EVENT_ERROR;
	end if;

	-- now validate that the value of the trans ackn status is
	-- valid

	l_valid_status := EDR_TRANS_ACKN_PVT.IS_STATUS_VALID
			  ( p_status   => p_trans_status    ,
			    p_mode    => EDR_TRANS_ACKN_PVT.G_UPDATE_MODE
			  );

	if not l_valid_status then
		RAISE INVALID_ACK_STATUS_ERROR;
	end if;

	-- now validate that there this is not a duplicate acknowledgement

	open l_ack_csr;

	loop
		fetch l_ack_csr into l_status;
		exit when l_ack_csr%NOTFOUND;

		l_existing_ack_count := l_existing_ack_count + 1;
            --
            -- Start bug fix 3129598
            -- Commented following 5 lines of code which verifies
            -- current call is duplicate or not
            --
            /*
		  if l_status  = EDR_CONSTANTS_GRP.g_success_ack_status
		    or l_status  = EDR_CONSTANTS_GRP.g_error_ack_status
		  then
			RAISE DUPLICATE_ACK_ERROR;
              end if;
            */
	end loop;

	if l_existing_ack_count = 0 then
		RAISE NO_DATA_ERROR;
	end if;

	close l_ack_csr;

	-- after all the validations are done, update the acknowledgement
	-- row in the database

	-- Find out if the autonomous commit flag is on or not
	-- if an auto commit is required call the corresponding
	-- auto txn

	IF FND_API.To_Boolean(p_autonomous_commit) THEN
		EDR_TRANS_ACKN_PVT.SEND_ACKN_AUTO
		( p_api_version          => 1.0			,
		  p_init_msg_list	 => FND_API.G_FALSE	,
		  x_return_status	 => l_return_status	,
		  x_msg_count		 => l_msg_count		,
		  x_msg_data		 => l_msg_data		,
		  p_event_name           => p_event_name	,
		  p_event_key            => p_event_key		,
		  p_erecord_id	         => p_erecord_id	,
		  p_trans_status	 => p_trans_status	,
		  p_ackn_by              => p_ackn_by		,
		  p_ackn_note	         => p_ackn_note
		);

		-- If any errors happen abort API.
		IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

	ELSE
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

	END IF;

	--  End of API Body

	-- Standard call to get message count and if count is 1,
	--get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count        		=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);

      -- BEGIN Bug : 3834375. Added Secure context to allow query of all rows
         edr_ctx_pkg.unset_secure_attr;
      -- END  Bug : 3834375
EXCEPTION
	WHEN INVALID_ERECORD_ERROR THEN
--		ROLLBACK TO SEND_ACKN_PUB;
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

      -- BEGIN Bug : 3834375. Added Secure context to allow query of all rows
         edr_ctx_pkg.unset_secure_attr;
      -- END  Bug : 3834375
	WHEN INVALID_EVENT_ERROR THEN
--		ROLLBACK TO SEND_ACKN_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;

		fnd_message.set_name('EDR','EDR_ACK_INVALID_EVENT');
		fnd_message.set_token('ERECORD_ID', p_erecord_id);
		fnd_message.set_token('EVENT_NAME', p_event_name);
		fnd_message.set_token('EVENT_KEY', p_event_key);
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

      -- BEGIN Bug : 3834375. Added Secure context to allow query of all rows
         edr_ctx_pkg.unset_secure_attr;
      -- END  Bug : 3834375
	WHEN INVALID_ACK_STATUS_ERROR THEN
--		ROLLBACK TO SEND_ACKN_PUB;
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

      -- BEGIN Bug : 3834375. Added Secure context to allow query of all rows
         edr_ctx_pkg.unset_secure_attr;
      -- END  Bug : 3834375
	WHEN DUPLICATE_ACK_ERROR THEN
--		ROLLBACK TO SEND_ACKN_PUB;
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

      -- BEGIN Bug : 3834375. Added Secure context to allow query of all rows
         edr_ctx_pkg.unset_secure_attr;
      -- END  Bug : 3834375
	WHEN NO_DATA_ERROR then
--		ROLLBACK TO SEND_ACKN_PUB;

		--close the cursor that was opened
		close l_ack_csr;

		x_return_status := FND_API.G_RET_STS_ERROR;

		fnd_message.set_name('EDR','EDR_ACK_UNEXPECTED_ERROR');
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

      -- BEGIN Bug : 3834375. Added Secure context to allow query of all rows
         edr_ctx_pkg.unset_secure_attr;
      -- END  Bug : 3834375
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
--		ROLLBACK;
--		ROLLBACK TO SEND_ACKN_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

		FND_MSG_PUB.Count_And_Get
    		(  p_count         	=>      x_msg_count     ,
        	   p_data          	=>      x_msg_data
    		);

      -- BEGIN Bug : 3834375. Added Secure context to allow query of all rows
         edr_ctx_pkg.unset_secure_attr;
      -- END  Bug : 3834375
	WHEN OTHERS THEN
--		ROLLBACK;
--		ROLLBACK TO SEND_ACKN_PUB;
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

      -- BEGIN Bug : 3834375. Added Secure context to allow query of all rows
         edr_ctx_pkg.unset_secure_attr;
      -- END  Bug : 3834375
end SEND_ACKN;

end EDR_TRANS_ACKN_PUB;

/
