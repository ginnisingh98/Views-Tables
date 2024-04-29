--------------------------------------------------------
--  DDL for Package Body EDR_EVENT_RELATIONSHIP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_EVENT_RELATIONSHIP_PVT" AS
/* $Header: EDRVRELB.pls 120.0.12000000.1 2007/01/18 05:56:40 appldev ship $*/

-- Start of comments
-- API name             : STORE_INTER_EVENT_AUTONOMOUS
-- Type                 : Private.
-- Function             : Stores the inter event relationship information into
--                        the databse in an autonomous manner. This API does a bulk
--                        upload of a number of relationship records at one time
--                        and does an autonomous commit.
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   :p_api_version          IN NUMBER       Required
--                       p_init_msg_list        IN VARCHAR2     Optional
--                                        Default = FND_API.G_FALSE
--                       p_inter_event_tbl      IN INTER_EVENT_TBL_TYPE Required
--
-- OUT                  :x_return_status        OUT VARCHAR2
--                       x_msg_count            OUT NUMBER
--                       x_msg_data             OUT VARCHAR2
--
-- Version              :Current version        1.0
--                       Initial version        1.0
--
-- Notes                 :
--
-- End of comments


PROCEDURE STORE_INTER_EVENT_AUTONOMOUS
( p_api_version         	IN		NUMBER				   ,
  p_init_msg_list		IN		VARCHAR2                           ,
  x_return_status		OUT NOCOPY 	VARCHAR2		  	   ,
  x_msg_count			OUT NOCOPY 	NUMBER				   ,
  x_msg_data			OUT NOCOPY 	VARCHAR2			   ,
  p_inter_event_tbl		IN
                                    EDR_EVENT_RELATIONSHIP_PUB.INTER_EVENT_TBL_TYPE
) AS PRAGMA AUTONOMOUS_TRANSACTION;
	l_api_name		CONSTANT VARCHAR2(30)	:= 'STORE_INTER_EVENT_AUTONOMOUS';
	l_api_version           CONSTANT NUMBER 	:= 1.0;
	i 				 NUMBER;
	l_relationship_id 		 NUMBER;
	L_RETURN_STATUS 		 VARCHAR2(1);
	L_MSG_COUNT 			 NUMBER;
	L_MSG_index 			 NUMBER;
	L_MSG_data 			 VARCHAR2(2000);

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
	--  API Body

	i := p_inter_event_tbl.FIRST;

	-- this loop would read each row of the input table and insert
	-- a corresponding row in the relationship table
	-- if any error occurs it would rollback, thereby erasing all
	-- of the inserted rows in the relationship table tiil that point
	-- (by this call only)
      -- Inteer event table data is already validated by calling routine
      -- because of this we need not validate data again

	while i is not null loop
               /* BUG Fix 3135128. SKARIMIS . Added a IF condition to eliminate the posting of orphan childs*/
             IF (p_inter_event_tbl(i).parent_erecord_id is not NULL) THEN
/* Bugfix 3169361 SRPURI added new condition AND NVL(p_inter_event_tbl(i).child_erecord_id,-1) <> -1
to resolve issue when child is not required */

                  IF (p_inter_event_tbl(i).parent_erecord_id <> -1) AND
                     NVL(p_inter_event_tbl(i).child_erecord_id,-1) <> -1 THEN

                     edr_event_relationship_pub.CREATE_RELATIONSHIP
	        	( p_api_version       => 1.0					,
		          p_init_msg_list     => FND_API.G_FALSE			,
		          p_commit	          => FND_API.G_FALSE			,
		          p_validation_level  => FND_API.G_VALID_LEVEL_NONE		,
		          x_return_status     => l_return_status			,
		          x_msg_count	    => l_msg_count				,
		          x_msg_data	    => l_msg_data				,
		          p_parent_erecord_id => p_inter_event_tbl(i).parent_erecord_id ,
		          p_parent_event_name => p_inter_event_tbl(i).parent_event_name ,
		          p_parent_event_key  => p_inter_event_tbl(i).parent_event_key  ,
		          p_child_erecord_id  => p_inter_event_tbl(i).child_erecord_id  ,
		          p_child_event_name  => p_inter_event_tbl(i).child_event_name  ,
		          p_child_event_key   => p_inter_event_tbl(i).child_event_key   ,
		          x_relationship_id   => l_relationship_id
		        );

		   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		   ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
		   END IF;
                  END IF;
             END IF;
          	i := p_inter_event_tbl.NEXT(i);
	end LOOP;

	--  unconditional commit as this is an autonomous txn
	COMMIT;

	FND_MSG_PUB.Count_And_Get
	(p_count         	=>      x_msg_count    ,
	 p_data          	=>      x_msg_data
	);


EXCEPTION
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


		FND_MSG_PUB.Count_And_Get
    		(p_count         	=>      x_msg_count    ,
        	 p_data          	=>      x_msg_data
    		);

		--this would get the message and can be used in the case of
		--an error
		if (x_msg_count > 1) then
			fnd_msg_pub.get
			(	p_data    	=> l_msg_data	,
				p_msg_index_out => l_msg_index
			);
		end if;

		fnd_message.set_encoded(l_msg_data);
		APP_EXCEPTION.RAISE_EXCEPTION;

	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK;
		x_return_status := FND_API.G_RET_STS_ERROR ;

		FND_MSG_PUB.Count_And_Get
    		(p_count         	=>      x_msg_count    ,
        	 p_data          	=>      x_msg_data
    		);

		--this would get the message and can be used in the case of
		--an error
		if (x_msg_count > 1) then
			fnd_msg_pub.get
			(	p_data    	=> l_msg_data	,
				p_msg_index_out => l_msg_index
			);
		end if;

		fnd_message.set_encoded(l_msg_data);
		APP_EXCEPTION.RAISE_EXCEPTION;

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

		--this would get the message and can be used in the case of
		--an error
		if (x_msg_count > 1) then
			fnd_msg_pub.get
			(	p_data    	=> l_msg_data	,
				p_msg_index_out => l_msg_index
			);
		end if;

		fnd_message.set_encoded(l_msg_data);
		APP_EXCEPTION.RAISE_EXCEPTION;

END STORE_INTER_EVENT_AUTONOMOUS;


PROCEDURE STORE_INTER_EVENT
( p_api_version         	IN		NUMBER				   ,
  p_init_msg_list		IN		VARCHAR2                           ,
  x_return_status		OUT NOCOPY 	VARCHAR2		  	   ,
  x_msg_count			OUT NOCOPY 	NUMBER				   ,
  x_msg_data			OUT NOCOPY 	VARCHAR2			   ,
  p_inter_event_tbl		IN
                                    EDR_EVENT_RELATIONSHIP_PUB.INTER_EVENT_TBL_TYPE
)
AS
	l_api_name		CONSTANT VARCHAR2(30)	:= 'STORE_INTER_EVENT';
	l_api_version           CONSTANT NUMBER 	:= 1.0;

	i 				 NUMBER;
	l_relationship_id 		 NUMBER;
	L_RETURN_STATUS 		 VARCHAR2(1);
	L_MSG_COUNT 			 NUMBER;
	L_MSG_index 			 NUMBER;
	L_MSG_data 			 VARCHAR2(2000);

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

	i := p_inter_event_tbl.FIRST;

	-- this loop would read each row of the input table
	-- and validates relationship data.
	--
	--

	while i is not null loop

   /* BUG Fix 3135128. SKARIMIS . Added a IF condition to eliminate the validation of orphan childs*/
             IF (p_inter_event_tbl(i).parent_erecord_id is not NULL) THEN

/* Bugfix 3169361 SRPURI added new condition AND NVL(p_inter_event_tbl(i).child_erecord_id,-1) <> -1
to resolve issue when child is not required */
                  IF (p_inter_event_tbl(i).parent_erecord_id <> -1 AND
                     NVL(p_inter_event_tbl(i).child_erecord_id,-1) <> -1 ) THEN

			EDR_EVENT_RELATIONSHIP_PUB.VALIDATE_RELATIONSHIP
			( p_api_version		=> 1.0,
  		  	x_return_status	=> l_return_status,
  		  	x_msg_count		=> l_msg_count,
  		  	x_msg_data		=> l_msg_data,
  		  	P_PARENT_ERECORD_ID   => p_inter_event_tbl(i).parent_erecord_id ,
  		  	P_PARENT_EVENT_NAME   => p_inter_event_tbl(i).parent_event_name ,
  		  	P_PARENT_EVENT_KEY	=> p_inter_event_tbl(i).parent_event_key  ,
  		  	P_CHILD_ERECORD_ID    => p_inter_event_tbl(i).child_erecord_id  ,
  		  	P_CHILD_EVENT_NAME    => p_inter_event_tbl(i).child_event_name  ,
  		  	P_CHILD_EVENT_KEY     => p_inter_event_tbl(i).child_event_key
			);

		-- If any errors happen abort API.
		IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;
               END IF;
             END IF;

		i := p_inter_event_tbl.NEXT(i);
	end LOOP;
      --
      -- Validation is completed
      -- Now we can commit the data autonomously
      --
      STORE_INTER_EVENT_AUTONOMOUS(p_api_version		=> 1.0,
                                   p_init_msg_list	        => p_init_msg_list,
  		  x_return_status	      => l_return_status,
  		  x_msg_count		=> l_msg_count,
  		  x_msg_data		=> l_msg_data,
              p_inter_event_tbl     => p_inter_event_tbl);

	FND_MSG_PUB.Count_And_Get
	(p_count         	=>      x_msg_count    ,
	 p_data          	=>      x_msg_data
	);


EXCEPTION
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


		FND_MSG_PUB.Count_And_Get
    		(p_count         	=>      x_msg_count    ,
        	 p_data          	=>      x_msg_data
    		);

		--this would get the message and can be used in the case of
		--an error
		if (x_msg_count > 1) then
			fnd_msg_pub.get
			(	p_data    	=> l_msg_data	,
				p_msg_index_out => l_msg_index
			);
		end if;

		fnd_message.set_encoded(l_msg_data);
		APP_EXCEPTION.RAISE_EXCEPTION;

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;

		FND_MSG_PUB.Count_And_Get
    		(p_count         	=>      x_msg_count    ,
        	 p_data          	=>      x_msg_data
    		);

		--this would get the message and can be used in the case of
		--an error
		if (x_msg_count > 1) then
			fnd_msg_pub.get
			(	p_data    	=> l_msg_data	,
				p_msg_index_out => l_msg_index
			);
		end if;

		fnd_message.set_encoded(l_msg_data);
		APP_EXCEPTION.RAISE_EXCEPTION;

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

		--this would get the message and can be used in the case of
		--an error
		if (x_msg_count > 1) then
			fnd_msg_pub.get
			(	p_data    	=> l_msg_data	,
				p_msg_index_out => l_msg_index
			);
		end if;

		fnd_message.set_encoded(l_msg_data);
		APP_EXCEPTION.RAISE_EXCEPTION;

END STORE_INTER_EVENT;


-- Bug 3667036: Start
PROCEDURE ESTABLISH_RELATIONSHIP
(PARENT_CHILD_RECORD IN	PARENT_CHILD_TBL)
AS
  L_RETURN_STATUS    VARCHAR2(10);
  L_MSG_COUNT        NUMBER;
  L_MSG_DATA         VARCHAR2(2000);
  L_RELATIONSHIP_ID  NUMBER;
  L_CHILD_EVENT_NAME VARCHAR2(80);
  L_CHILD_EVENT_KEY  VARCHAR2(240);
BEGIN

  FOR I IN 1..PARENT_CHILD_RECORD.count loop

    L_CHILD_EVENT_NAME := parent_child_record(i).child_event_name;

    if length(l_child_event_name) = 0 then

      edr_ctx_pkg.set_secure_attr;
      select event_name,event_key into l_child_event_name,l_child_event_key
                              from edr_psig_documents
                  where document_id = parent_child_record(i).child_erecord_id;
      edr_ctx_pkg.unset_secure_attr;
      edr_event_relationship_pub.CREATE_RELATIONSHIP
      (p_api_version            => 1.0,
       p_init_msg_list          => FND_API.G_FALSE,
       p_commit                 => FND_API.G_TRUE,
       p_validation_level       => FND_API.G_VALID_LEVEL_NONE,
       x_return_status          => L_RETURN_STATUS,
       x_msg_count              => L_MSG_COUNT,
       x_msg_data               => L_MSG_DATA,
       p_parent_erecord_id      => PARENT_CHILD_RECORD(i).PARENT_ERECORD_ID,
       p_parent_event_name      => PARENT_CHILD_RECORD(i).PARENT_EVENT_NAME,
       p_parent_event_key       => PARENT_CHILD_RECORD(i).PARENT_EVENT_KEY,
       p_child_erecord_id       => PARENT_CHILD_RECORD(i).CHILD_ERECORD_ID,
       p_child_event_name       => L_CHILD_EVENT_NAME,
       p_child_event_key        => L_CHILD_EVENT_KEY,
       x_relationship_id        => L_RELATIONSHIP_ID);

    else

      --Create a relationship for each record in the parent_child_table type
      edr_event_relationship_pub.CREATE_RELATIONSHIP
      (p_api_version            => 1.0,
       p_init_msg_list          => FND_API.G_FALSE,
       p_commit                 => FND_API.G_TRUE,
       p_validation_level       => FND_API.G_VALID_LEVEL_NONE,
       x_return_status          => L_RETURN_STATUS,
       x_msg_count              => L_MSG_COUNT,
       x_msg_data               => L_MSG_DATA,
       p_parent_erecord_id      => PARENT_CHILD_RECORD(i).PARENT_ERECORD_ID,
       p_parent_event_name      => PARENT_CHILD_RECORD(i).PARENT_EVENT_NAME,
       p_parent_event_key       => PARENT_CHILD_RECORD(i).PARENT_EVENT_KEY,
       p_child_erecord_id       => PARENT_CHILD_RECORD(i).CHILD_ERECORD_ID,
       p_child_event_name       => PARENT_CHILD_RECORD(i).CHILD_EVENT_NAME,
       p_child_event_key        => PARENT_CHILD_RECORD(i).CHILD_EVENT_KEY,
       x_relationship_id        => L_RELATIONSHIP_ID);

    end if;

  end loop;

END ESTABLISH_RELATIONSHIP;

--This procedure has been primarily defined to verify if the
--specified event exists in the evidence store.
PROCEDURE VALIDATE_PARENT(P_PARENT_EVENT_NAME IN VARCHAR2,
                          P_PARENT_EVENT_KEY  IN VARCHAR2,
                  				P_PARENT_ERECORD_ID IN NUMBER
                         )
IS

--Temporary count variable
l_count NUMBER := 0;

--This cursor is defined to query the evidence store
cursor l_psig_count_csr is
    select count(*) from edr_psig_documents
                    where event_name = p_parent_event_name
                    and event_key = p_parent_event_key
                    and document_id = p_parent_erecord_id;

--This cursor is defined to query the workflow event details view.
cursor l_wf_count_csr is
    select count(*) from wf_events_vl
                    where name = p_parent_event_name;

PARENT_EVENT_NOT_FOUND EXCEPTION ;
INVALID_PARENT EXCEPTION;

begin

  --If parent e-record id is -1 then the parent event is part of the current
  --transaction. Hence just verify if the event has been defined in workflow.
  if p_parent_erecord_id = -1 then

    --Query the workflow events view using the cursor for the specified parent
    --event name.
    open l_wf_count_csr;
      fetch l_wf_count_csr into l_count;
    close l_wf_count_csr;

    --If count is zero then parent event is not defined.
    --Hence raise an exception.
    if l_count = 0 then
      RAISE PARENT_EVENT_NOT_FOUND;

    end if;

  else

    --The parent e-record ID has also been defined.
    --Hence query evidence store to check if the parent e-record exists.

    --Set the secure context to enable direct query on evidence store.
    edr_ctx_pkg.set_secure_attr;

    --Query the evidence store using the cursor for the specified parent
    --e-record.
    open l_psig_count_csr;
      fetch l_psig_count_csr into l_count;
    close l_psig_count_csr;
    edr_ctx_pkg.unset_secure_attr;
    --If count is zero then the specified parent e-record does not exist.
    --Hence raise an exception.
    if l_count = 0 then

      RAISE INVALID_PARENT;

    end if;

  end if;

EXCEPTION
  --Handle the exceptions by setting the error code.
  WHEN PARENT_EVENT_NOT_FOUND THEN
     FND_MESSAGE.SET_NAME('EDR','EDR_FWK_PARENT_ERROR');
     fnd_message.set_token('EVENT_NAME',P_PARENT_EVENT_NAME);
     fnd_message.set_token('EVENT_KEY',P_PARENT_EVENT_KEY);
     --Diagnostics Start
     if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                      'edr.plsql.EDR_EVENT_RELATIONSHIP_PVT.VALIDATE_PARENT',
                      FALSE
                     );
     end if;
     --Diagnostics End

    APP_EXCEPTION.RAISE_EXCEPTION;

  WHEN INVALID_PARENT THEN
     FND_MESSAGE.SET_NAME('EDR','EDR_FWK_PARENT_CHILD_INVALID');
     fnd_message.set_token('EVENT_NAME',P_PARENT_EVENT_NAME);
     fnd_message.set_token('EVENT_KEY',P_PARENT_EVENT_KEY);
     --Diagnostics Start
     if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                      'edr.plsql.EDR_EVENT_RELATIONSHIP_PVT.VALIDATE_PARENT',
                      FALSE
                     );
     end if;
     --Diagnostics End

    APP_EXCEPTION.RAISE_EXCEPTION;


END VALIDATE_PARENT;

--This API is defined to verify if the specified child e-records
--exist in the evidence store and represent transactions
--other than that of the parent transaction.
PROCEDURE VALIDATE_CHILDREN(P_CHILD_ERECORD_IDS IN FND_TABLE_OF_VARCHAR2_255,
                            P_PARENT_EVENT_NAME IN VARCHAR2
                           )
IS

--Define a cursor to query the evidence store
--based on the e-record id. This cursor would return
--the event_name for the specified e-record id.
cursor l_psig_details_csr(p_erecord_id NUMBER) is
    select event_name from edr_psig_documents
                    where document_id = p_erecord_id;


L_COUNT NUMBER;
L_CHILD_ERECORD_ID NUMBER;

--This variable would hold the values of those invalid e-record IDs
--whose event name is the same as that of their parent.
L_INVALID_CHILD_ERECORD_IDS VARCHAR2(32767);

--This variable would hold the values of those invalid e-record IDs
--which don't exist in evidence store.
L_WRONG_CHILD_ERECORD_IDS VARCHAR2(32767);
L_COUNTER1 NUMBER;
L_COUNTER2 NUMBER;
L_TEMP_EVENT_NAME VARCHAR2(80);

INVALID_CHILD_ERECORDS EXCEPTION;
PARENT_CHILD_SAME_ERROR EXCEPTION;

INTER_EVENT_ERROR EXCEPTION;

BEGIN

  L_WRONG_CHILD_ERECORD_IDS := '';
  L_INVALID_CHILD_ERECORD_IDS := '';
  L_COUNTER1 := 0;
  L_COUNTER2 := 0;
  L_COUNT := P_CHILD_ERECORD_IDS.count;
  for i in 1..l_count loop
    --Convert the VARCHAR2 e-record id value into number format.
    L_CHILD_ERECORD_ID:=to_number(P_CHILD_ERECORD_IDS(i),'999999999999.999999');

    --Set secure attribute
    edr_ctx_pkg.set_secure_attr;
    --Query the evidence using the cursor.
    OPEN l_psig_details_csr(L_CHILD_ERECORD_ID);
      FETCH L_PSIG_DETAILS_CSR into L_TEMP_EVENT_NAME;

    --If no data was found, then update the error message.
    IF L_PSIG_DETAILS_CSR%NOTFOUND THEN
        l_counter1 := l_counter1 + 1;
        L_WRONG_CHILD_ERECORD_IDS := L_WRONG_CHILD_ERECORD_IDS ||
                                     ' '|| P_CHILD_ERECORD_IDS(i);
    ELSE
      --Otherwise check if the parent event name is the same as
      --the child event name.
      if L_TEMP_EVENT_NAME = P_PARENT_EVENT_NAME then
        --If they are the same, keep track of the invalid e-record IDs
        --and increment the counter.
        l_invalid_child_erecord_ids := l_invalid_child_erecord_ids ||
                                      ' ' || P_CHILD_ERECORD_IDS(i);

        l_counter2 := l_counter2 + 1;

      END IF;
    END IF;

    CLOSE L_PSIG_DETAILS_CSR;
  end loop;

  --unset secure attribute
  edr_ctx_pkg.unset_secure_attr;

  if l_counter1 > 0  and l_counter2 > 0 then
    --Some of the specified child e-record IDs do not exist in evidence store
    --and also there exists some e-record IDS whose event name is the same as
    --that of their parent.
    RAISE INTER_EVENT_ERROR;


  elsif l_counter1 > 0 then
    --Some of the specified child e-record IDs do not exist in the evidence
    --store.
    RAISE INVALID_CHILD_ERECORDS;

  elsif l_counter2 > 0 then
    --Some of the specified child e-record IDs have the same event name as that
    --of their parent.
    RAISE PARENT_CHILD_SAME_ERROR;

  end if;

EXCEPTION
  WHEN INVALID_CHILD_ERECORDS THEN
     FND_MESSAGE.SET_NAME('EDR','EDR_FWK_CHILD_ERROR');
     fnd_message.set_token('EVENT_NAME',P_PARENT_EVENT_NAME);
     fnd_message.set_token('CHILD_ERECORD_IDS',L_WRONG_CHILD_ERECORD_IDS);
     --Diagnostics Start
     if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                      'edr.plsql.EDR_EVENT_RELATIONSHIP_PVT.VALIDATE_CHILDREN',
                      FALSE
                     );
     end if;
     --Diagnostics End

    APP_EXCEPTION.RAISE_EXCEPTION;

  WHEN PARENT_CHILD_SAME_ERROR THEN
     FND_MESSAGE.SET_NAME('EDR','EDR_FWK_CHILD_PARENT_SAME_ERR');
     fnd_message.set_token('EVENT_NAME',P_PARENT_EVENT_NAME);
     fnd_message.set_token('CHILD_ERECORD_IDS',L_INVALID_CHILD_ERECORD_IDS);
     --Diagnostics Start
     if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                      'edr.plsql.EDR_EVENT_RELATIONSHIP_PVT.VALIDATE_CHILDREN',
                      FALSE
                     );
     end if;
     --Diagnostics End

    APP_EXCEPTION.RAISE_EXCEPTION;


  WHEN INTER_EVENT_ERROR THEN
     FND_MESSAGE.SET_NAME('EDR','EDR_FWK_INTER_EVENT_ERR');
     fnd_message.set_token('EVENT_NAME',P_PARENT_EVENT_NAME);
     fnd_message.set_token('WRONG_CHILD_ERECORD_IDS',L_WRONG_CHILD_ERECORD_IDS);
     fnd_message.set_token('INVALID_CHILD_ERECORD_IDS',L_INVALID_CHILD_ERECORD_IDS);
     --Diagnostics Start
     if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                      'edr.plsql.EDR_EVENT_RELATIONSHIP_PVT.VALIDATE_CHILDREN',
                      FALSE
                     );
     end if;
     --Diagnostics End

    APP_EXCEPTION.RAISE_EXCEPTION;

END VALIDATE_CHILDREN;
-- Bug 3667036: End

--Bug 4122622: Start
--This is just a wrapper overload on the existing validate_children.
PROCEDURE VALIDATE_CHILDREN(P_CHILD_ERECORD_IDS IN EDR_ERES_EVENT_PUB.ERECORD_ID_TBL_TYPE,
                            P_PARENT_EVENT_NAME IN VARCHAR2)
IS

--This variable would hold the array of child e-record ids in varchar2 format.
l_child_erecord_ids FND_TABLE_OF_VARCHAR2_255;
i pls_integer;
l_counter pls_integer;


BEGIN

  l_counter := 1;

  --Create a new object instance of child e-record IDs.
  l_child_erecord_ids := FND_TABLE_OF_VARCHAR2_255();

  --Copy the contents of e-record ID table type into the object type variable.
  i := p_child_erecord_ids.FIRST;
  while i is not null loop
    l_child_erecord_ids.extend;
    l_child_erecord_ids(l_counter) := to_char(p_child_erecord_ids(i));
    l_counter := l_counter + 1;
    i := p_child_erecord_ids.NEXT(i);
  END LOOP;

  --Validate the e-record IDs.
  VALIDATE_CHILDREN(P_CHILD_ERECORD_IDS => L_CHILD_ERECORD_IDS,
                    P_PARENT_EVENT_NAME => P_PARENT_EVENT_NAME);
END VALIDATE_CHILDREN;
--Bug 4122622: End

end EDR_EVENT_RELATIONSHIP_PVT;

/
