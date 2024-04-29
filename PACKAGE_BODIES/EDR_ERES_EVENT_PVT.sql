--------------------------------------------------------
--  DDL for Package Body EDR_ERES_EVENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_ERES_EVENT_PVT" AS
/* $Header: EDRVEVTB.pls 120.2.12000000.1 2007/01/18 05:56:10 appldev ship $*/

-- Private Utility Functions --

/** Gets the guid of the ERES subscription for a business event **/

/** following get subscription GUI function is totaly rewritten to resolve the bug
    3355468
**/
FUNCTION GET_SUBSCRIPTION_GUID
( p_event_name 		IN 	VARCHAR2)
RETURN RAW
IS

   l_guid RAW(16);
   l_no_enabled_eres_sub NUMBER;
   l_no_of_eres_sub NUMBER;

   cursor enabled_subscription_csr is
     select b.guid
     from wf_events_vl a, wf_event_subscriptions b
     where	a.guid=b.EVENT_FILTER_GUID
	  and a.name = p_event_name
	  and UPPER(b.rule_function) = EDR_CONSTANTS_GRP.g_rule_function
        and b.status = 'ENABLED'
	  --Bug No 4912782- Start
	  and b.source_type = 'LOCAL'
	  and b.system_guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID')) ;
	  --Bug No 4912782- End

   cursor single_subscription_csr is
     select b.guid
     from wf_events_vl a, wf_event_subscriptions b
     where	a.guid=b.EVENT_FILTER_GUID
	  and a.name = p_event_name
	  and UPPER(b.rule_function) = EDR_CONSTANTS_GRP.g_rule_function
	  --Bug No 4912782- Start
	  and b.source_type = 'LOCAL'
	  and b.system_guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID')) ;
	  --Bug No 4912782- End

BEGIN
 /*
 ** added following comments as part of bug fix 3355468
 ** This function returns valid Subscription GUID for following cases
 ** 1. only one ERES subscription present
 ** 2. Only one ERES subscription is enabled when multiple
 **    ERES subscriptions are present for the event
 **
 ** in all other cases it will return "Null" */

         --
         -- find out how many ERES subscriptions are
         -- present for the event
         --

         select count(*)  INTO l_no_of_eres_sub
         from
           wf_events a, wf_event_subscriptions b
         where a.GUID = b.EVENT_FILTER_GUID
           and a.name = p_event_name
           and b.RULE_FUNCTION='EDR_PSIG_RULE.PSIG_RULE'
	     --Bug No 4912782- Start
	     and b.source_type = 'LOCAL'
	     and b.system_guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID')) ;
	     --Bug No 4912782- End

         IF l_no_of_eres_sub > 1 then

          --
          --
          -- Verify is more than one active ERES subscriptions are present
          -- for the event. then return subscription guid as null.
          -- return null when no subscription is enabled
          -- return valid Subscription GUID when only one
          -- subscription is enabled
          --
          --
            select count(*)  INTO l_no_enabled_eres_sub
            from
              wf_events a, wf_event_subscriptions b
            where a.GUID = b.EVENT_FILTER_GUID
              and a.name = p_event_name
              and b.RULE_FUNCTION='EDR_PSIG_RULE.PSIG_RULE'
              and b.STATUS = 'ENABLED'
		  --Bug No 4912782- Start
	   	  and b.source_type = 'LOCAL'
        	  and b.system_guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID')) ;
		  --Bug No 4912782- End
            IF l_no_enabled_eres_sub > 1 THEN
               l_guid := null;
            ELSIF l_no_enabled_eres_sub = 0 THEN
               l_guid := null;
            ELSIF l_no_enabled_eres_sub = 1 THEN
              open enabled_subscription_csr;
              fetch enabled_subscription_csr into l_guid;
              close enabled_subscription_csr ;
            END IF;
          ELSIF l_no_of_eres_sub = 0 THEN
               l_guid := null;
          ELSIF l_no_of_eres_sub = 1 THEN
           --
           -- if only one ERES subscription is present
           -- then ignore status and return valid subscription GUID
           --
            open single_subscription_csr;
            fetch single_subscription_csr into l_guid;
            close single_subscription_csr ;
          END IF;

	return l_guid;

EXCEPTION WHEN NO_DATA_FOUND then
	return(null);

END GET_SUBSCRIPTION_GUID;

-- Private APIs --

PROCEDURE RAISE_EVENT
( p_api_version       IN		NUMBER,
  p_init_msg_list	    IN		VARCHAR2,
  p_validation_level	IN		NUMBER,
  x_return_status	    OUT 	NOCOPY 	VARCHAR2,
  x_msg_count		      OUT 	NOCOPY 	NUMBER,
  x_msg_data		      OUT 	NOCOPY 	VARCHAR2,
  p_mode  		        IN 		VARCHAR2,
  x_event 		      IN OUT 	NOCOPY 	EDR_ERES_EVENT_PUB.ERES_EVENT_REC_TYPE,
  x_is_child_event 	  OUT 	NOCOPY 	BOOLEAN,
  --Bug 4122622: Start
  p_parameter_list    IN    FND_WF_EVENT.PARAM_TABLE
  --Bug 4122622: End
)
AS
	l_api_name	CONSTANT VARCHAR2(30)	:= 'RAISE_EVENT';
	l_api_version   CONSTANT NUMBER 	:= 1.0;

	l_parameter_list	 fnd_wf_event.param_table;
	l_param_name		 varchar2(30);
	l_param_value 		 varchar2(2000);
	l_param_number		 number;
	i			 pls_integer;

	l_return_status		 VARCHAR2(1);
	l_msg_count		 NUMBER;
	l_msg_data		 VARCHAR2(2000);
	l_mesg_text		 VARCHAR2(2000);


	PAYLOAD_VALIDATION_ERROR 		EXCEPTION;
	EVENT_RAISE_ERROR 			EXCEPTION;

  --Bug 4122622: Start
  PARENT_ERECORD_ID_ERROR EXCEPTION;
  l_parent_erecord_id VARCHAR2(128);
  --Bug 4122622: End

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

	-- CHANGE_SOURCE_TYPE(x_event.payload, EDR_CONSTANTS_GRP.g_db_mode);
		--Bug 3136403: Start
		--Copy the individual parameters to a structure
		--of type fnd_wf_event.param_table
		--start with 4 because in event of the payload with valid
		--the first three parameters are set to specific values below
          -- SKARIMIS Moved the code logic outside of follwing IF statment. Payload should
          -- be populated without checking validation

    --Bug 4122622: Start
    if(P_PARAMETER_LIST.COUNT = 0) then
  		CREATE_PAYLOAD
  		( p_event 		          => x_event           ,
  		  p_starting_position   => 4                 ,
  		  x_payload 	          => l_parameter_list
  		);
    else
      l_parameter_list := p_parameter_list;
    end if;
    --Bug 4122622: End

	--validate that the payload passed is valid
	IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

		EDR_ERES_EVENT_PUB.VALIDATE_PAYLOAD
		( p_api_version         => 1.0			,
		  p_init_msg_list       => FND_API.G_FALSE	,
		  x_return_status       => l_return_status	,
		  x_msg_count           => l_msg_count		,
		  x_msg_data            => l_msg_data		,
		  p_event_name          => x_event.event_name	,
		  p_event_key           => x_event.event_key	,
		  p_payload             => l_parameter_list	,
		  p_mode                => p_mode
		);


		--Bug 3136403: End

		-- If any errors happen abort API.
		IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
			RAISE PAYLOAD_VALIDATION_ERROR;
		END IF;

	END IF;
     --Bug 3136403: Start
     -- SKARIMIS Introduced a check of child record
	      i := 4;
	   while i is not null loop
       --Bug 4122622: Start
       --We need to obtain the parent e-record id.
       if (l_parameter_list(i).PARAM_NAME = EDR_CONSTANTS_GRP.g_parent_erecord_id) then
         l_parent_erecord_id := l_parameter_list(i).param_value;
		     x_is_child_event := TRUE;
         exit;
		  end if;
      --Bug 4122622: End
		     i := l_parameter_list.NEXT(i);
     end loop;

     --Bug 4122622: Start
     --Validate the parent erecord if they are set and only if they were'nt validated
     --earlier.
     --They would'nt be validated if the Validation level was set to NONE.
     if x_is_child_event and l_parent_erecord_id is not null and
        l_parent_erecord_id <> '-1' and p_validation_level = FND_API.G_VALID_LEVEL_NONE
     then
 		   EDR_ERES_EVENT_PUB.VALIDATE_ERECORD
			 ( p_api_version   => 1.0,
	  	   x_return_status => l_return_status,
	  		 x_msg_count     => l_msg_count,
				 x_msg_data      => l_msg_data,
				 p_erecord_id    => to_number(l_parent_erecord_id,'999999999999.999999')
			 );
 		   -- If any errors happen abort API.
			 IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			 ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
			   RAISE PARENT_ERECORD_ID_ERROR;
			 END IF;
     END IF;
     --Bug 4122622: End;

	--Bug 3136403: End
	--if valid then extend the payload to have additional parameters
	--this is done by copying the payload to another table of same type
	--this would help in putting additional parameters at specific locations
	--and also do some additional payload inspection to figure out if
	--this is inter event mode

        l_parameter_list(1).param_name  := EDR_CONSTANTS_GRP.g_wf_pageflow_itemtype_attr;
      	l_parameter_list(1).param_value := null;
      	l_parameter_list(2).param_name  := EDR_CONSTANTS_GRP.g_wf_pageflow_itemkey_attr;
      	l_parameter_list(2).param_value := null;

  	--the third parameter would be the #ERECORD_ID that would contain the erecord id
      	l_parameter_list(3).param_name  := EDR_CONSTANTS_GRP.g_erecord_id_attr;
      	l_parameter_list(3).param_value := null;

      	--raise the event
      	begin
      	--Bug 3136403: Start
      	--Get the value of the number of parameters in the parameter list
      	--and pass it
      		l_param_number := l_parameter_list.COUNT;

      		--Bug 3207385: Start
		RAISE_TABLE
		( x_event.event_name,
		  x_event.event_key,
                  --Bug 3893101: Start
                  --Pass the event xml payload while raising the event.
                  x_event.event_xml,
                  --Bug 3893101: End
		  l_parameter_list,
		  l_param_number,
		  NULL
		);
		--Bug 3207385: End
      	--Bug 3136403: End

      	exception WHEN OTHERS then
        	l_parameter_list(1).param_value := 'WF_ERROR';
        	l_parameter_list(2).param_value := '-999';

		--this would get the messages on the error stack set by
		--the rule function and add to the api error stack

		l_mesg_text := fnd_message.get();

		FND_MSG_PUB.Add_Exc_Msg
		( G_PKG_NAME  	    ,
		  l_api_name   	    ,
		  l_mesg_text
		);
	end;

      	IF   l_parameter_list(1).param_value = 'WF_ERROR'
      	 AND l_parameter_list(2).param_value = '-999'
      	THEN
      		RAISE EVENT_RAISE_ERROR;

      	ELSIF l_parameter_list(1).param_value is NULL
      	 AND  l_parameter_list(2).param_value is NULL
      	THEN
		-- this means that no signature was required
        	-- No WF, mark as success
      	  	x_event.event_status := EDR_CONSTANTS_GRP.g_no_action_status;

		-- an eRecord may or may not have been required anyhow
		-- get the erecord id
		x_event.erecord_id := l_parameter_list(3).param_value;

      	ELSE
		-- this means that signature was required and offline notification
		-- has been sent out
      	  	x_event.event_status := EDR_CONSTANTS_GRP.g_pending_status;

		--get the erecord id
		x_event.erecord_id := l_parameter_list(3).param_value;
	END IF;

	-- Standard call to get message count and if count is 1,
	--get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count        	=>      x_msg_count     	,
        	p_data          =>      x_msg_data
    	);

EXCEPTION
	WHEN PAYLOAD_VALIDATION_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		x_event.event_status := EDR_CONSTANTS_GRP.g_error_status;

		-- this would pass on the validation errors to the calling
		-- routine

		FND_MSG_PUB.Count_And_Get
    		(  p_count         	=>      x_msg_count     ,
        	   p_data          	=>      x_msg_data
    		);

	WHEN EVENT_RAISE_ERROR 	THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		x_event.event_status := EDR_CONSTANTS_GRP.g_error_status;
		x_event.erecord_id := null;

		l_mesg_text := fnd_message.get_string('EDR','EDR_EVENT_RAISE_ERROR');

		FND_MSG_PUB.Add_Exc_Msg
		( G_PKG_NAME  	    ,
		  l_api_name   	    ,
		  l_mesg_text
		);

		FND_MSG_PUB.Count_And_Get
    		(  p_count         	=>      x_msg_count     ,
        	   p_data          	=>      x_msg_data
    		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		x_event.event_status := EDR_CONSTANTS_GRP.g_error_status;
		x_event.erecord_id := null;

		FND_MSG_PUB.Count_And_Get
    		(  p_count         	=>      x_msg_count     ,
        	   p_data          	=>      x_msg_data
    		);


--Bug 4122622: Start
--This exception would be thrown when the parent e-record ID is invalid.
	WHEN PARENT_ERECORD_ID_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;

		fnd_message.set_name('EDR','EDR_VAL_INVALID_PARENT_ID');
		fnd_message.set_token('ERECORD_ID', l_parent_erecord_id);
		fnd_message.set_token('EVENT_NAME', x_event.event_name);
		fnd_message.set_token('EVENT_KEY', x_event.event_key);
		l_mesg_text := fnd_message.get();
    FND_MSG_PUB.Add_Exc_Msg
		   (G_PKG_NAME,
    	  l_api_name,
    		l_mesg_text
     	 );
  	FND_MSG_PUB.Count_And_Get
 		(p_count    	=>      x_msg_count,
     p_data      	=>      x_msg_data
 		);
--Bug 4122622: End

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		x_event.event_status := EDR_CONSTANTS_GRP.g_error_status;
		x_event.erecord_id := null;

  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
    	    		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;

		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     ,
        		p_data          	=>      x_msg_data
		);

END RAISE_EVENT;

PROCEDURE CREATE_PAYLOAD
( p_event 		IN      EDR_ERES_EVENT_PUB.ERES_EVENT_REC_TYPE        ,
  p_starting_position   IN      NUMBER                                        ,
  x_payload 	        OUT 	NOCOPY 	FND_WF_EVENT.PARAM_TABLE
)
IS
  l_position number;
BEGIN

 --Bug 4074173 : GSCC Warning
 l_position := p_starting_position;

/* SKARIMIS. Cahged the way payload is populated */
     IF p_event.param_name_1 is NOT NULL THEN
	x_payload(l_position).param_name       := p_event.param_name_1;
	x_payload(l_position).param_value      := p_event.param_value_1;
      l_position:=l_position+1;
     END IF;
     IF p_event.param_name_2 is NOT NULL THEN
	x_payload(l_position).param_name       := p_event.param_name_2;
	x_payload(l_position).param_value      := p_event.param_value_2;
      l_position:=l_position+1;
     END IF;
   IF p_event.param_name_3 is NOT NULL THEN
	x_payload(l_position).param_name       := p_event.param_name_3;
	x_payload(l_position).param_value      := p_event.param_value_3;
      l_position:=l_position+1;
     END IF;
     IF p_event.param_name_4 is NOT NULL THEN
	x_payload(l_position).param_name       := p_event.param_name_4;
	x_payload(l_position).param_value      := p_event.param_value_4;
      l_position:=l_position+1;
     END IF;

   IF p_event.param_name_5 is NOT NULL THEN
	x_payload(l_position).param_name       := p_event.param_name_5;
	x_payload(l_position).param_value      := p_event.param_value_5;
      l_position:=l_position+1;
     END IF;
     IF p_event.param_name_6 is NOT NULL THEN
	x_payload(l_position).param_name       := p_event.param_name_6;
	x_payload(l_position).param_value      := p_event.param_value_6;
      l_position:=l_position+1;
     END IF;

   IF p_event.param_name_7 is NOT NULL THEN
	x_payload(l_position).param_name       := p_event.param_name_7;
	x_payload(l_position).param_value      := p_event.param_value_7;
      l_position:=l_position+1;
     END IF;
     IF p_event.param_name_8 is NOT NULL THEN
	x_payload(l_position).param_name       := p_event.param_name_8;
	x_payload(l_position).param_value      := p_event.param_value_8;
      l_position:=l_position+1;
     END IF;

   IF p_event.param_name_9 is NOT NULL THEN
     /* SKARIMIS . There was a bug here name is beign populated for both name and value */
	x_payload(l_position).param_name       := p_event.param_name_9;
	x_payload(l_position).param_value      := p_event.param_value_9;
      l_position:=l_position+1;
     END IF;
   IF p_event.param_name_10 is NOT NULL THEN
	x_payload(l_position).param_name       := p_event.param_name_10;
	x_payload(l_position).param_value      := p_event.param_value_10;
      l_position:=l_position+1;
   END IF;

     IF p_event.param_name_11 is NOT NULL THEN
	x_payload(l_position).param_name       := p_event.param_name_11;
	x_payload(l_position).param_value      := p_event.param_value_11;
      l_position:=l_position+1;
     END IF;
     IF p_event.param_name_12 is NOT NULL THEN
	x_payload(l_position).param_name       := p_event.param_name_12;
	x_payload(l_position).param_value      := p_event.param_value_12;
      l_position:=l_position+1;
     END IF;
   IF p_event.param_name_13 is NOT NULL THEN
	x_payload(l_position).param_name       := p_event.param_name_13;
	x_payload(l_position).param_value      := p_event.param_value_13;
      l_position:=l_position+1;
     END IF;
     IF p_event.param_name_14 is NOT NULL THEN
	x_payload(l_position).param_name       := p_event.param_name_14;
	x_payload(l_position).param_value      := p_event.param_value_14;
      l_position:=l_position+1;
     END IF;

   IF p_event.param_name_15 is NOT NULL THEN
	x_payload(l_position).param_name       := p_event.param_name_15;
	x_payload(l_position).param_value      := p_event.param_value_15;
      l_position:=l_position+1;
     END IF;
     IF p_event.param_name_16 is NOT NULL THEN
	x_payload(l_position).param_name       := p_event.param_name_16;
	x_payload(l_position).param_value      := p_event.param_value_16;
      l_position:=l_position+1;
     END IF;

   IF p_event.param_name_17 is NOT NULL THEN
	x_payload(l_position).param_name       := p_event.param_name_17;
	x_payload(l_position).param_value      := p_event.param_value_17;
      l_position:=l_position+1;
     END IF;
     IF p_event.param_name_18 is NOT NULL THEN
	x_payload(l_position).param_name       := p_event.param_name_18;
	x_payload(l_position).param_value      := p_event.param_value_18;
      l_position:=l_position+1;
     END IF;

   IF p_event.param_name_19 is NOT NULL THEN
	x_payload(l_position).param_name       := p_event.param_name_19;
	x_payload(l_position).param_value      := p_event.param_value_19;
      l_position:=l_position+1;
     END IF;
   IF p_event.param_name_20 is NOT NULL THEN
	x_payload(l_position).param_name       := p_event.param_name_20;
	x_payload(l_position).param_value      := p_event.param_value_20;
      l_position:=l_position+1;
   END IF;

END CREATE_PAYLOAD;

PROCEDURE GET_EVENT_APPROVERS
( p_api_version         IN		NUMBER				      ,
  p_init_msg_list	IN		VARCHAR2 ,
  x_return_status	OUT 	NOCOPY 	VARCHAR2		  	      ,
  x_msg_count		OUT 	NOCOPY 	NUMBER				      ,
  x_msg_data		OUT 	NOCOPY 	VARCHAR2			      ,
  p_event_name 		IN 		VARCHAR2                              ,
  p_event_key           IN              VARCHAR2                              ,
  x_approver_count      OUT     NOCOPY  NUMBER                                ,
  x_approvers_name      OUT     NOCOPY  FND_TABLE_OF_VARCHAR2_255             ,
  x_approvers_role_name OUT     NOCOPY  FND_TABLE_OF_VARCHAR2_255             ,
  x_overriding_details  OUT     NOCOPY  FND_TABLE_OF_VARCHAR2_255             ,
  x_approvers_sequence  OUT     NOCOPY  FND_TABLE_OF_VARCHAR2_255
)
AS
  l_api_name	    CONSTANT VARCHAR2(30)	:= 'GET_EVENT_APPROVERS';
  l_api_version     CONSTANT NUMBER 	        := 1.0;

  --Bug 2674799 : start
  l_approver_list            EDR_UTILITIES.approvers_Table;

  -- ame approver api call variables
  l_ruleids   edr_utilities.id_List;
  l_rulenames edr_utilities.string_List;

  --Bug 2674799 : end

  l_fnd_user                 varchar2(100);
  l_application_id           NUMBER;
  i                          NUMBER             := 1;
  l_ame_txn_type             VARCHAR2(1000);
  l_new_user                 VARCHAR2(100);
  l_comments                 VARCHAR2(1000);
  l_sub_count                NUMBER;
  l_user_id                  NUMBER;
  l_cur_user_id              NUMBER;
  l_err_code varchar2(100);
  l_err_mesg varchar2(1000);
  l_guid raw(16);
  INVALID_EVENT_NAME_ERROR   EXCEPTION;
  INVALID_USER_NAME_ERROR   EXCEPTION;
  MULTIPLE_ERES_SUBSCRIPTIONS EXCEPTION;
  CURSOR CUR_EVENT is
  SELECT application_id
		FROM FND_APPLICATION A, WF_EVENTS B
		WHERE A.APPLICATION_SHORT_NAME = B.OWNER_TAG
		AND B.NAME=P_EVENT_NAME;

  CURSOR CUR_SUB is
  select count(*)
        from
          wf_events a, wf_event_subscriptions b
        where a.GUID = b.EVENT_FILTER_GUID
          and a.name = p_event_name
          and b.RULE_FUNCTION='EDR_PSIG_RULE.PSIG_RULE'
          and b.STATUS = 'ENABLED'
	    --Bug No 4912782- Start
	    and b.source_type = 'LOCAL'
          and b.system_guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID')) ;
          --Bug No 4912782- End

   CURSOR CUR_USER_NAME(l_cur_user_id number) is
          select user_name
	      from FND_USER
	      where USER_ID = l_cur_user_id;

BEGIN
	--by default return 0 as the approver count
	x_approver_count := 0;

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
	--validate the event name and get the application id
	    OPEN CUR_EVENT;
            FETCH CUR_EVENT into l_application_id;
            IF CUR_EVENT%NOTFOUND THEN
               CLOSE CUR_EVENT;
    		   RAISE INVALID_EVENT_NAME_ERROR;
            END IF;
            CLOSE CUR_EVENT;
      -- Validate Subscription
            OPEN CUR_SUB;
            FETCH CUR_SUB into l_SUB_COUNT;
            IF l_SUB_COUNT > 1 THEN
               CLOSE CUR_SUB;
               RAISE MULTIPLE_ERES_SUBSCRIPTIONS;
            END IF;
            CLOSE CUR_SUB;
  	--get the ame transaction type of the event
        BEGIN

         --Bug 2674799: start
         --Fixing this as a part of AME patch.
	 --If there are > 1 subscriptions, and one is enabled query returns >1
         -- rows. Hence adding two more conditions in where clause

         SELECT EDR_INDEXED_XML_UTIL.GET_WF_PARAMS('EDR_AME_TRANSACTION_TYPE',b.guid) into l_ame_txn_type
		from wf_events_vl a,
	 	wf_event_subscriptions b
		WHERE a.guid=b.EVENT_FILTER_GUID
		and a.name = p_event_name
            and b.RULE_FUNCTION='EDR_PSIG_RULE.PSIG_RULE'
            and b.STATUS = 'ENABLED'
	  	--Bug No 4912782- Start
		and b.source_type = 'LOCAL'
	  	and b.system_guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID')) ;
	  	--Bug No 4912782- End
        --Bug 2674799: end

        EXCEPTION
         when OTHERS THEN
             raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END;

        l_ame_txn_type := nvl(l_ame_txn_type, p_event_name);


      --Bug 2674799: start

        EDR_UTILITIES.GET_APPROVERS
            (p_APPLICATION_ID    => l_application_Id,
             p_TRANSACTION_ID    => p_event_key,
             p_TRANSACTION_TYPE  => l_ame_txn_type,
             X_APPROVERS       => l_approver_List,
             X_RULE_IDS         => l_ruleids,
             X_RULE_DESCRIPTIONS => l_rulenames
         );

      --Bug 2674799: end


	--initialize the return tables
	x_approvers_name := fnd_table_of_varchar2_255('');
	x_approvers_role_name := fnd_table_of_varchar2_255('');
	x_overriding_details  := fnd_table_of_varchar2_255('');
        x_approvers_sequence := fnd_table_of_varchar2_255('');

	--for each user id returned by ame get the user_name from fnd schema
	--and the role name from the wf directory services
	while (i <= l_approver_list.count) loop

	    if (i > 1) then

	      x_approvers_name.extend;
	      x_approvers_role_name.extend;
	      x_overriding_details.extend;
              x_approvers_sequence.extend;

	    end if;

            --Bug 2674799 : start
            l_fnd_user := l_approver_list(i).name;
            --Bug 2674799 : end

            --find out if any overriding approver is defined in the workflow
            --system for this user currently
            edr_standard.FIND_WF_NTF_RECIPIENT
            (P_ORIGINAL_RECIPIENT           => l_fnd_user,
             P_MESSAGE_TYPE                 => null,
             P_MESSAGE_NAME                 => null,
             P_RECIPIENT                    => l_new_user,
             P_NTF_ROUTING_COMMENTS         => l_comments,
             P_ERR_CODE                     => l_err_code,
             P_ERR_MSG                      => l_err_mesg
            );

            if (l_err_code = '0') then
              x_approvers_name(i) := l_new_user;
	      x_approvers_role_name(i) := wf_directory.getroledisplayname(l_new_user);
	      x_overriding_details(i) := l_comments;
	    else
              x_approvers_name(i) := l_fnd_user;
	      x_approvers_role_name(i) := wf_directory.getroledisplayname(l_fnd_user);
	      x_overriding_details(i) := null;
            end if;

            x_approvers_sequence(i) := l_approver_list(i).approver_order_number;

	    i := i+1;
	end loop;

	x_approver_count := i-1;

	-- Standard call to get message count and if count is 1,
	--get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count        	=>      x_msg_count     	,
        	p_data          =>      x_msg_data
    	);

EXCEPTION
	WHEN INVALID_EVENT_NAME_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

		-- this would pass on the validation errors to the calling
		-- routine
		FND_MSG_PUB.Count_And_Get
    		(  p_count         	=>      x_msg_count     ,
        	   p_data          	=>      x_msg_data
    		);
      WHEN INVALID_USER_NAME_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

		-- this would pass on the validation errors to the calling
		-- routine
		FND_MSG_PUB.Count_And_Get
    		(  p_count         	=>      x_msg_count     ,
        	   p_data          	=>      x_msg_data
    		);
      WHEN MULTIPLE_ERES_SUBSCRIPTIONS THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('EDR','EDR_MULTI_ERES_SUBSCRP_ERR');
            fnd_message.set_token( 'EVENT', p_event_NAME);
            fnd_msg_pub.Add;
		-- this would pass on the validation errors to the calling
		-- routine
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

  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
    	    		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;

		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     ,
        		p_data          	=>      x_msg_data
		);
END GET_EVENT_APPROVERS;


--Bug 3667036: Start
PROCEDURE CREATE_MANAGER_PROCESS(P_RETURN_URL           IN         VARCHAR2,
                                 P_RETURN_FUNCTION      IN         VARCHAR2,
                                 P_OVERALL_STATUS       IN         VARCHAR2,
                  		 P_CREATION_DATE        IN         DATE,
                                 P_CREATED_BY           IN         NUMBER,
                                 P_LAST_UPDATE_DATE     IN         DATE,
                                 P_LAST_UPDATED_BY      IN         NUMBER,
                                 P_LAST_UPDATE_LOGIN    IN         NUMBER,
                                 X_ERES_PROCESS_ID      OUT NOCOPY NUMBER)
IS
BEGIN
  --get the next pk value from sequence
  select EDR_ERESMANAGER_T_S.nextval into X_ERES_PROCESS_ID from dual;

  --insert all the values in db
  insert into EDR_ERESMANAGER_T(ERES_PROCESS_ID,
                                RETURN_URL,
                                RETURN_FUNCTION,
                        				OVERALL_STATUS,
                                CREATED_BY,
                        				CREATION_DATE,
                                LAST_UPDATE_DATE,
                                LAST_UPDATED_BY,
                                LAST_UPDATE_LOGIN
                               )
                         values( X_ERES_PROCESS_ID,
                                 P_RETURN_URL,
                                 P_RETURN_FUNCTION,
                                 P_OVERALL_STATUS,
                                 P_CREATED_BY,
                                 P_CREATION_DATE,
                                 P_LAST_UPDATE_DATE,
                                 P_LAST_UPDATED_BY,
                                 P_LAST_UPDATE_LOGIN);

  --no exception handling is done here because only an unexpected exception can occur
  --here which is supposed to be handled in the calling code

END CREATE_MANAGER_PROCESS;


PROCEDURE DELETE_ERECORDS(P_ERES_PROCESS_ID  IN    NUMBER)
IS
  L_TEMP_DATA_LIFE      VARCHAR2(128);
  L_TEMP_DATE           DATE;
  L_TEMP_DATA_LIFE_NUM  NUMBER;
BEGIN

  --If eres_process_id is not null then delete from edr_process_erecords_t and
  --edr_eres_manager_t tables
  if P_ERES_PROCESS_ID is not null then

    --Bug 3893101: Start
    --Delete from the EDR parameters table as well.

    delete from EDR_ERESPARAMETERS_T params
           where params.PARENT_ID in (select ERECORD_SEQUENCE_ID
                                     from EDR_PROCESS_ERECORDS_T records
                                     where records.ERES_PROCESS_ID = P_ERES_PROCESS_ID
                                    ) and params.parent_type = 'ERECORD';

    delete from EDR_ERESPARAMETERS_T where parent_id = p_eres_process_id
           and parent_type = 'ERESMANAGER';
    --Bug 3893101: End
    delete from EDR_PROCESS_ERECORDS_T where ERES_PROCESS_ID = P_ERES_PROCESS_ID;
    delete from EDR_ERESMANAGER_T where ERES_PROCESS_ID = P_ERES_PROCESS_ID;

  else
    --If eres_process_id is null then delete temp data based on the profile values
    L_TEMP_DATE := sysdate;
    L_TEMP_DATA_LIFE := FND_PROFILE.VALUE('EDR_TEMP_DATA_LIFE');

    --Perform delete operation only if profile value is not null
    if L_TEMP_DATA_LIFE is not null then

      --Convert varchar2 to number. Ensure MLS compliancy
      L_TEMP_DATA_LIFE_NUM := TO_NUMBER(L_TEMP_DATA_LIFE,'999999999999');

      --verify -ve value.
      if L_TEMP_DATA_LIFE_NUM <= 0 then
      raise VALUE_ERROR;
      end if;

      L_TEMP_DATE := L_TEMP_DATE - L_TEMP_DATA_LIFE_NUM;

      --Bug 3893101: Start
      --Delete the EDR parameters table as well
      delete from EDR_ERESPARAMETERS_T params
      where params.PARENT_ID in (select records.ERECORD_SEQUENCE_ID
                                 from EDR_PROCESS_ERECORDS_T records
                                 where records.CREATION_DATE <= L_TEMP_DATE
                                 ) and params.parent_type = 'ERECORD';

      delete from EDR_ERESPARAMETERS_T params
      where params.PARENT_ID in (select manager.ERES_PROCESS_ID
                                 from EDR_ERESMANAGER_T manager
                                 where manager.CREATION_DATE <= L_TEMP_DATE
                                 ) and params.parent_type = 'ERESMANAGER';
      --Bug 3893101: End

      delete from EDR_ERESMANAGER_T where CREATION_DATE <= L_TEMP_DATE;
      fnd_message.set_name('EDR', 'EDR_TEMP_ERESMANAGER_CLEANUP');
      fnd_message.set_token( 'CLN_ERESMANAGER', SQL%ROWCOUNT);
      fnd_file.put_line(fnd_file.output, fnd_message.get);

      delete from EDR_PROCESS_ERECORDS_T where CREATION_DATE <= L_TEMP_DATE;
      fnd_message.set_name('EDR', 'EDR_TEMP_ERECORDS_CLEANUP');
      fnd_message.set_token( 'CLN_ERECORDS', SQL%ROWCOUNT);
      fnd_file.put_line(fnd_file.output, fnd_message.get);

      --Bug 3621309 : Start
      delete from EDR_RAW_XML_T where CREATION_DATE <= L_TEMP_DATE;
      fnd_message.set_name('EDR', 'EDR_VALIDATE_TEMP_DATA_CLEANUP');
      fnd_message.set_token( 'CLN_ERECORDS', SQL%ROWCOUNT);
      fnd_file.put_line(fnd_file.output, fnd_message.get);
      --Bug 3621309 : End

    end if;
  end if;

exception

when VALUE_ERROR then
fnd_file.put_line(fnd_file.output, fnd_message.get_string('EDR', 'EDR_INVALID_PROFILE_VALUE'));

END DELETE_ERECORDS;

--Bug 3667036: End


--Bug 3207385: Start

--This method would raise the file approval completion event.
--We need to perform the a commit operation after raising the event.
--Hence this new API will perform an autonomous commit.

PROCEDURE RAISE_COMPLETION_EVENT(P_ORIG_EVENT_NAME IN VARCHAR2,
                                 P_ORIG_EVENT_KEY  IN VARCHAR2,
			         P_ORIG_PARAM_LIST IN FND_WF_EVENT.PARAM_TABLE,
			         P_SEND_DATE       IN DATE)
IS

PRAGMA AUTONOMOUS_TRANSACTION;

i NUMBER;

l_wfitemtype_set boolean;
l_wfitemkey_set boolean;

l_temp_string VARCHAR2(4000);
l_erecord_id VARCHAR2(128);

l_event_name VARCHAR2(240);
l_event_key VARCHAR2(240);
l_param_list WF_PARAMETER_LIST_T;

BEGIN

l_erecord_id := NULL;

l_temp_string := NULL;

l_wfitemtype_set := false;

l_wfitemkey_set := false;

--Check if approval is required for the event.
--This is done by checking the values of wfitemtype,wfitemkey attributes set in
--the parameter list.
FOR i IN 1..p_orig_param_list.count loop
  IF p_orig_param_list(i).param_name = '#WF_PAGEFLOW_ITEMTYPE'
     AND length(p_orig_param_list(i).param_value) > 0 THEN

    l_temp_string := trim(' ' FROM p_orig_param_list(i).param_value);

    IF length(l_temp_string) > 0 then
      l_wfitemtype_set := true;
    END IF;

  ELSIF p_orig_param_list(i).param_name = '#WF_PAGEFLOW_ITEMKEY'
        AND length(p_orig_param_list(i).param_value) > 0 THEN

    l_temp_string := trim(' ' FROM p_orig_param_list(i).param_value);

    IF length(l_temp_string) > 0 then
      l_wfitemkey_set := true;
    END IF;

  ELSIF p_orig_param_list(i).param_name = '#ERECORD_ID'
        AND length(p_orig_param_list(i).param_value) > 0 THEN

    l_erecord_id := trim(' ' FROM p_orig_param_list(i).param_value);

  END IF;

END LOOP;

--Signature is not required if either of these parameters is not set.
IF NOT l_wfitemtype_set or NOT l_wfitemkey_set then

  --Hence the approval is complete.
  --Raise the approval completetion event with same event key as a combination of the event name and event key.
  l_event_name := EDR_CONSTANTS_GRP.G_APPROVAL_COMPLETION_EVT;

  IF length(l_erecord_id) > 0 then
    l_event_key := l_erecord_id;
  else
    l_event_key := '-1';
  END IF;

  wf_event.addParameterToList(EDR_CONSTANTS_GRP.G_ORIGINAL_EVENT_NAME,p_orig_event_name,l_param_list);

  wf_event.addParameterToList(EDR_CONSTANTS_GRP.G_ORIGINAL_EVENT_KEY,p_orig_event_key,l_param_list);

  if length(l_erecord_id) > 0 THEN

    wf_event.addParameterToList(EDR_CONSTANTS_GRP.G_ERECORD_ID,l_erecord_id,l_param_list);

    wf_event.addParameterToList(EDR_CONSTANTS_GRP.G_EVENT_STATUS,EDR_CONSTANTS_GRP.G_COMPLETE_STATUS,l_param_list);

  ELSE
    wf_event.addParameterToList(EDR_CONSTANTS_GRP.G_EVENT_STATUS,EDR_CONSTANTS_GRP.G_NO_ERES_STATUS,l_param_list);
  END IF;

  --Raise the approval completion event.
  WF_EVENT.RAISE3(L_EVENT_NAME,
                  L_EVENT_KEY,
                  null,
                  L_PARAM_LIST,
                  P_SEND_DATE);

  --Perform a commit after raising the event.
  COMMIT;
END IF;

END RAISE_COMPLETION_EVENT;


--This method will be a wrapper over FND_WF_EVENT.RAISE_EVENT
PROCEDURE RAISE_TABLE(P_EVENT_NAME     IN              VARCHAR2,
                      P_EVENT_KEY      IN              VARCHAR2,
                      P_EVENT_DATA     IN              CLOB      DEFAULT NULL,
                      P_PARAM_TABLE    IN  OUT NOCOPY  FND_WF_EVENT.PARAM_TABLE,
                      P_NUMBER_PARAMS  IN              NUMBER,
                      P_SEND_DATE      IN              DATE      DEFAULT NULL)
IS

BEGIN

--Call the workflow API to raise the event.
FND_WF_EVENT.RAISE_TABLE(P_EVENT_NAME,
                         P_EVENT_KEY,
                         P_EVENT_DATA,
                         P_PARAM_TABLE,
                         P_NUMBER_PARAMS,
                         P_SEND_DATE);

--Call the API to raise the approval completion if required.
RAISE_COMPLETION_EVENT(P_ORIG_EVENT_NAME => p_event_name,
                       P_ORIG_EVENT_KEY  => p_event_key,
   	               P_ORIG_PARAM_LIST => p_param_table,
		       P_SEND_DATE       => p_send_date);


END RAISE_TABLE;

--Bug 3207385: End

--Bug 4122622: Start
--This procedure would fetch the event name and event key for the specified e-record ID.
--This method is strictly private.
--It should be used for a valid e-record ID only.
PROCEDURE GET_EVENT_DETAILS(P_ERECORD_ID IN NUMBER,
                            X_EVENT_NAME OUT NOCOPY VARCHAR2,
			    X_EVENT_KEY  OUT NOCOPY VARCHAR2)
IS

--Define a cursor on edr_psig_documents.
cursor l_event_csr is
        SELECT EVENT_NAME, EVENT_KEY
        FROM EDR_PSIG_DOCUMENTS
        WHERE DOCUMENT_ID = p_erecord_id;
BEGIN

  --Set the secure context.
  edr_ctx_pkg.set_secure_attr;

  --Open the cursor and fetch the event details.
  open l_event_csr;

  fetch l_event_csr into x_event_name,x_event_key;

  close l_event_csr;

  edr_ctx_pkg.unset_secure_attr;

END GET_EVENT_DETAILS;
--Bug 4122622: End

end EDR_ERES_EVENT_PVT;

/
