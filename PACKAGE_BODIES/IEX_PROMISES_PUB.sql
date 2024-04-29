--------------------------------------------------------
--  DDL for Package Body IEX_PROMISES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_PROMISES_PUB" as
/* $Header: iexpyprb.pls 120.8.12010000.7 2010/02/05 14:48:44 gnramasa ship $ */

PG_DEBUG NUMBER; --  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

G_APP_ID   CONSTANT NUMBER := 695;
G_PKG_NAME CONSTANT VARCHAR2(30) := 'IEX_PROMISES_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'iexpyprb.pls';
G_LOGIN_ID NUMBER; --  := FND_GLOBAL.Conc_Login_Id;
G_PROGRAM_ID NUMBER; -- := FND_GLOBAL.Conc_Program_Id;
G_USER_ID NUMBER; -- := FND_GLOBAL.User_Id;
G_REQUEST_ID NUMBER; --  := FND_GLOBAL.Conc_Request_Id;

PROCEDURE SHOW_IN_UWQ(
    	P_API_VERSION		IN      NUMBER,
    	P_INIT_MSG_LIST		IN      VARCHAR2, -- DEFAULT FND_API.G_FALSE,
    	P_COMMIT                IN      VARCHAR2, -- DEFAULT FND_API.G_FALSE,
    	P_VALIDATION_LEVEL	IN      NUMBER, --  DEFAULT FND_API.G_VALID_LEVEL_FULL,
    	X_RETURN_STATUS		OUT NOCOPY     VARCHAR2,
    	X_MSG_COUNT             OUT NOCOPY     NUMBER,
    	X_MSG_DATA	    	OUT NOCOPY     VARCHAR2,
	P_PROMISE_TBL 		IN 	DBMS_SQL.NUMBER_TABLE,
	P_STATUS 		IN 	VARCHAR2,
	P_DAYS 			IN 	NUMBER DEFAULT NULL)
IS
    	l_api_name			CONSTANT VARCHAR2(30) := 'SHOW_IN_UWQ';
   	l_api_version               	CONSTANT NUMBER := 1.0;
	l_return_status			varchar2(10);
	l_msg_count			number;
	l_msg_data			varchar2(200);

	l_validation_item		varchar2(100);
	l_days				NUMBER;
	l_state				varchar2(20);
	nCount				number;

    	Type refCur is Ref Cursor;
    	l_cursor			refCur;
	l_SQL				VARCHAR2(10000);
	l_broken_promises 		DBMS_SQL.NUMBER_TABLE;
	i				number;
	j				number;
	l_uwq_active_date 		date;
	l_uwq_complete_date		date;
begin
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': start');
END IF;

    	-- Standard start of API savepoint
    	SAVEPOINT SHOW_IN_UWQ_PVT;

    	-- Standard call to check for call compatibility
    	IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    	END IF;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.To_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;

    	-- Initialize API return status to success
    	l_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- START OF BODY OF API

	-- validating uwq status
	l_validation_item := 'P_STATUS';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': new uwq status: ' || P_STATUS);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Validating ' || l_validation_item);
END IF;
	if P_STATUS is null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' failed validation');
END IF;
		FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
		FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_api_name);
		FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

	-- validating table of promises
	l_validation_item := 'P_PROMISE_TBL';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': count of P_PROMISE_TBL: ' || P_PROMISE_TBL.count);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Validating ' || l_validation_item);
END IF;
	if P_PROMISE_TBL.count = 0 then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' failed validation');
END IF;
		FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
		FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_api_name);
		FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

	-- validating p_days
	l_validation_item := 'P_DAYS';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': P_DAYS: ' || P_DAYS);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Validating ' || l_validation_item);
END IF;
	if P_DAYS is not null and P_DAYS < 0 then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' failed validation');
END IF;
		FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
		FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_api_name);
		FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

	-- filter passed promises; we need only BROKEN_PROMISE promises for update
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': filtering broken promises...');
END IF;
	l_SQL := 'SELECT state ' ||
			'FROM IEX_PROMISE_DETAILS ' ||
			'WHERE ' ||
			'PROMISE_DETAIL_ID = :P_PROMISE_ID';

	j := 0;
	for i in 1..P_PROMISE_TBL.count loop
		open l_cursor for l_SQL
		using P_PROMISE_TBL(i);
		fetch l_cursor into l_state;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': promise ' || P_PROMISE_TBL(i));
END IF;
                if l_cursor%NOTFOUND then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': invalid promise');
END IF;
		else
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': state ' || l_state);
END IF;
			if l_state = 'BROKEN_PROMISE' then
				j := j + 1;
				l_broken_promises(j) := P_PROMISE_TBL(i);
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': promise ' || P_PROMISE_TBL(i) || ' is added to broken promises table');
END IF;
			end if;
		end if;
	end loop;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': total broken promises ' || l_broken_promises.count);
END IF;

	-- check for status
	if P_STATUS = 'ACTIVE' then
		l_uwq_active_date := NULL;
		l_uwq_complete_date := NULL;
	elsif P_STATUS = 'PENDING' then
		-- set number of days
		if P_DAYS is null then
	   		l_days := to_number(nvl(fnd_profile.value('IEX_UWQ_DEFAULT_PENDING_DAYS'), '0'));
		else
	   		l_days := P_DAYS;
		end if;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': number of days: ' || l_days);
END IF;
		l_uwq_active_date := sysdate + l_days;

		l_uwq_complete_date := NULL;
	elsif P_STATUS = 'COMPLETE' then
		l_uwq_active_date := NULL;
		l_uwq_complete_date := sysdate;
	end if;

        -- do updates of broken promises as appropriate
        nCount := l_broken_promises.count;
        if nCount > 0 then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': l_uwq_active_date: ' || l_uwq_active_date);
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': l_uwq_complete_date: ' || l_uwq_complete_date);
        	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': updating promise details...');
END IF;
        	FORALL i in 1..nCount
            		update iex_promise_details
            		set UWQ_STATUS = P_STATUS,
                		UWQ_ACTIVE_DATE = l_uwq_active_date,
                		UWQ_COMPLETE_DATE = l_uwq_complete_date,
                		last_update_date = sysdate,
                		last_updated_by = G_USER_ID
            		where
                		promise_detail_id = l_broken_promises(i);
        else
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': nothing to update');
END IF;
        end if;

    	-- END OF BODY OF API

    	-- Standard check of p_commit.
    	IF FND_API.To_Boolean( p_commit ) THEN
        	COMMIT WORK;
    	END IF;

	x_return_status := l_return_status;
    	-- Standard call to get message count and if count is 1, get message info
    	FND_MSG_PUB.Count_And_Get(
                   p_encoded => FND_API.G_FALSE,
                   p_count => x_msg_count,
                   p_data => x_msg_data);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO SHOW_IN_UWQ_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO SHOW_IN_UWQ_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO SHOW_IN_UWQ_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
end;


PROCEDURE SET_STRATEGY(P_PROMISE_ID 		IN 	NUMBER,
		       P_STATUS 		IN 	VARCHAR2)
IS
    	l_api_name                  	CONSTANT VARCHAR2(30) := 'SET_STRATEGY';
	l_return_status			varchar2(10);
	l_msg_count			number;
	l_msg_data			varchar2(200);

    	Type refCur is Ref Cursor;
    	l_cursor			refCur;
	l_SQL				VARCHAR2(10000);
	l_cust_account_id		number;
	l_delinquency_id		number;
	l_object_type			varchar2(100);
	l_object_id			number;
	l_cnsld_id			number;
	l_contract_id			number;

	--begin bug#2369298 schekuri 24-Feb-2006
    	/*CURSOR  del_crs(p_promise_id number) IS
		SELECT delinquency_id, cust_account_id, CNSLD_INVOICE_ID, CONTRACT_ID
		FROM IEX_PROMISE_DETAILS
		WHERE PROMISE_DETAIL_ID = P_PROMISE_ID;*/

	l_DefaultStrategyLevel number;
	l_party_id number;
	l_cust_site_use_id number;
	l_unpro_dels number;
	CURSOR  del_crs(p_promise_id number) IS
		SELECT del.party_cust_id,del.cust_account_id,del.CUSTOMER_SITE_USE_ID,
		del.delinquency_id,  prd.CNSLD_INVOICE_ID, prd.CONTRACT_ID
		FROM IEX_PROMISE_DETAILS prd,
		IEX_DELINQUENCIES_ALL del
		WHERE prd.PROMISE_DETAIL_ID = P_PROMISE_ID
		and prd.delinquency_id = del.delinquency_id;
	--end bug#2369298 schekuri 24-Feb-2006

        -- Start for bug8844974 PNAVEENK 27-Aug-2009
	cursor c_strategy_level (p_party_id number) is
        select strategy_level
	from iex_strategies
	where party_id= p_party_id
	and status_code in ('OPEN', 'ONHOLD');
        -- end for bug 8844974
begin
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': start');
END IF;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': promise = ' || P_PROMISE_ID);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': status = ' || P_STATUS);
END IF;

	-- validation input
	if P_PROMISE_ID is null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Error! P_PROMISE_ID is null');
END IF;
		FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
		FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_api_name);
		FND_MESSAGE.SET_TOKEN('API_PARAMETER', 'P_PROMISE_ID');
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

	if P_STATUS is null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Error! P_STATUS is null');
END IF;
		FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
		FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_api_name);
		FND_MESSAGE.SET_TOKEN('API_PARAMETER', 'P_STATUS');
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

         --begin bug#2369298 schekuri 24-Feb-2006
	 --get party_id and cust_site_use id also
	/* getting delinquency_id, cust_account_id, l_cnsld_id and l_contract_id */
	/*l_SQL := 'SELECT delinquency_id, cust_account_id, CNSLD_INVOICE_ID, CONTRACT_ID ' ||
			'FROM IEX_PROMISE_DETAILS ' ||
			'WHERE ' ||
			'PROMISE_DETAIL_ID = :P_PROMISE_ID';

	open l_cursor for l_SQL
	using P_PROMISE_ID;
	fetch l_cursor into l_delinquency_id, l_cust_account_id, l_cnsld_id, l_contract_id;*/
	OPEN  del_crs(P_PROMISE_ID);
    	FETCH del_crs INTO l_party_id, l_cust_account_id, l_cust_site_use_id, l_delinquency_id, l_cnsld_id, l_contract_id;
    	CLOSE del_crs;

      -- Start for bug 8844974 PNAVEENK 27-AUG-2009
     /*   --get strategy level
	select decode(preference_value, 'CUSTOMER', 10, 'ACCOUNT', 20, 'BILL_TO', 30, 'DELINQUENCY', 40,  40)
	into l_DefaultStrategyLevel
	from iex_app_preferences_b
	where  preference_name = 'COLLECTIONS STRATEGY LEVEL'
	and enabled_flag = 'Y'
	and org_id is null;  -- changed for bug 8708271 pnaveenk
	--end bug#2369298 schekuri 24-Feb-2006*/

	open c_strategy_level(l_party_id);
	fetch c_strategy_level into l_DefaultStrategyLevel;
	close c_strategy_level;

       -- end for bug 8844974

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': l_delinquency_id = ' || l_delinquency_id);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': l_cust_account_id = ' || l_cust_account_id);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': l_cnsld_id = ' || l_cnsld_id);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': l_contract_id = ' || l_contract_id);
END IF;

	if l_delinquency_id is not null and l_cust_account_id is not null and l_cnsld_id is null and l_contract_id is null then --promise on delinquency
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': this is promise on delinquency. Move on with set strategy.');
END IF;
		l_object_type := 'DELINQUENT';
		l_object_id := l_delinquency_id;
	else
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': This version does not support set strategy for this kind of promises. Return from the API');
END IF;
		return;
	end if;

	--begin bug#2369298 schekuri 24-Feb-2006
	--pass values of object_type  object_id to strategy api
	if l_DefaultStrategyLevel = 10 then
		l_object_type := 'PARTY';
		l_object_id := l_party_id;

	elsif l_DefaultStrategyLevel = 20 then
		l_object_type := 'ACCOUNT';
		l_object_id := l_cust_account_id;

	elsif l_DefaultStrategyLevel = 30 then
		l_object_type := 'BILL_TO';
		l_object_id := l_cust_site_use_id;

	else
		l_object_type := 'DELINQUENT';
		l_object_id := l_delinquency_id;
	end if;
	--end bug#2369298 schekuri 24-Feb-2006

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Calling iex_strategy_pub.set_strategy...');
END IF;
	iex_strategy_pub.set_strategy
	(
		P_Api_Version_Number         => 2.0,
		P_Init_Msg_List              => 'F',
		P_Commit                     => 'F',
                p_validation_level           => null,
		X_Return_Status              => l_return_status,
		X_Msg_Count                  => l_msg_count,
		X_Msg_Data                   => l_msg_data,
		p_DelinquencyID              => l_object_id,
		p_ObjectType                 => l_object_type,
		p_ObjectID                   => l_object_id,
		p_Status                     => P_STATUS
	);

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Return status ' || l_return_status);
END IF;
	if l_return_status <> 'S' then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Failed to set strategy');
END IF;
	end if;

EXCEPTION
    	WHEN OTHERS THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': in exception');
END IF;
end;


PROCEDURE SEND_FFM(P_PROMISE_ID IN NUMBER, P_PARTY_ID IN NUMBER)
IS
	l_template_id		number;
	l_request_id		number;
	l_return_status		varchar2(10);
	l_msg_count		number;
	l_msg_data		varchar2(200);
	l_party_id		number;
	l_autofulfill		varchar2(1);
begin
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.SEND_FFM: start');
END IF;
	l_autofulfill := fnd_profile.value('IEX_AUTO_FULFILL');
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.SEND_FFM: l_autofulfill: ' || l_autofulfill);
END IF;

	if l_autofulfill is not null and l_autofulfill = 'Y' then
		l_template_id := to_number(fnd_profile.value('IEX_PROMISE_CONFIRM'));
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.SEND_FFM: ptp ffm template_id = ' || l_template_id);
END IF;
		if l_template_id is not null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(G_PKG_NAME || '.SEND_FFM: Sending ffm ...');
END IF;
			IEX_DUNNING_PVT.CALL_FFM(
				p_api_version   => 1.0,
				p_init_msg_list => FND_API.G_TRUE,
	 			p_commit        => FND_API.G_TRUE,
				p_key_name      => 'promise_id',
				p_key_id        => p_promise_id,
				p_template_id   => l_template_id,
				p_method		=> 'EMAIL',
				p_party_id		=> p_party_id,
				x_request_id	=> l_request_id,
				x_return_status => l_return_status,
				x_msg_count		=> l_msg_count,
				x_msg_data		=> l_msg_data);

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(G_PKG_NAME || '.SEND_FFM: request_id ' || l_request_id);
			iex_debug_pub.LogMessage(G_PKG_NAME || '.SEND_FFM: Return status ' || l_return_status);
END IF;
			IF l_return_status <> 'S' then
				FND_MESSAGE.SET_NAME('IEX', 'IEX_FULFILLMENT_ERROR');
				FND_MSG_PUB.Add;
			end if;
		end if;
	end if;
EXCEPTION
    	WHEN OTHERS THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.SET_STRATEGY: in exception');
END IF;
end;


PROCEDURE START_PTP_WF(P_PROMISE_ID IN NUMBER, X_PROMISE_STATUS OUT NOCOPY VARCHAR2)
IS
	l_wf_item_type			varchar2(10);
	l_wf_process			varchar2(30); --  := 'PROMISE_WORKFLOW';
	l_item_key			varchar2(30);
    	l_result             		VARCHAR2(10);
    	l_return_status     		VARCHAR2(20);
    	l_approval_required		VARCHAR2(3);
    	l_ptp_wf_item_key		NUMBER;

    	-- generate new iex_ptp_wf item key
    	CURSOR  ptp_wf_crs IS
		select IEX_PTP_WF_S.NEXTVAL from dual;
begin
	l_wf_process := 'PROMISE_WORKFLOW';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.start_ptp_wf: start');
END IF;
   	l_approval_required := fnd_profile.value('IEX_PTP_APPROVAL');
   	l_wf_item_type := fnd_profile.value('IEX_PTP_WF_ITEM_TYPE');
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.start_ptp_wf: approval required = ' || l_approval_required);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.start_ptp_wf: item type = ' || l_wf_item_type);
END IF;

	x_promise_status := 'COLLECTABLE';
	if l_approval_required is not null and
	   l_approval_required = 'Y' and
	   l_wf_item_type is not null then

        	-- generate new iex_ptp_wf item key
        	OPEN ptp_wf_crs;
			FETCH ptp_wf_crs INTO l_ptp_wf_item_key;
			CLOSE ptp_wf_crs;

    		l_item_key := 'IEX_PTP_' || TO_CHAR(l_ptp_wf_item_key);
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(G_PKG_NAME || '.start_ptp_wf: item key = ' || l_item_key);
END IF;

    		wf_engine.createprocess(
			itemtype => l_wf_item_type,
			itemkey  => l_item_key,
			process  => l_wf_process);
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.start_ptp_wf: After createprocess');
END IF;

		wf_engine.setitemattrnumber(
			itemtype =>  l_wf_item_type,
			itemkey  =>  l_item_key,
			aname    =>  'PROMISE_ID',
			avalue   =>  p_promise_id);
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.start_ptp_wf: After setitemattrnumber');
END IF;

		wf_engine.startprocess(
			itemtype =>  l_wf_item_type,
			itemkey  =>  l_item_key);
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.start_ptp_wf: After startprocess');
END IF;

		wf_engine.ItemStatus(
			itemtype =>   l_wf_item_type,
			itemkey   =>  l_item_key,
			status   =>   l_return_status,
			result   =>   l_result);

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.start_ptp_wf: l_return_status = ' || l_return_status);
		iex_debug_pub.LogMessage(G_PKG_NAME || '.start_ptp_wf: l_result = ' || l_result);
END IF;

    		if l_return_status = 'COMPLETE' THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(G_PKG_NAME || '.start_ptp_wf: Set promise status to PENDING');
END IF;
			x_promise_status := 'PENDING';
    		end if;
	end if;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.start_ptp_wf: return_status = ' || x_promise_status);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.start_ptp_wf: end');
END IF;
EXCEPTION
	WHEN OTHERS THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.start_ptp_wf: In start_ptp_wf exception');
END IF;
end;


PROCEDURE GET_BROKEN_ON_DATE(P_PROMISE_DATE IN DATE, X_BROKEN_ON_DATE OUT NOCOPY DATE)
IS
      	l_grace_period		number;
      	l_broken_on_date	date;
begin
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.get_broken_on_date: start');
END IF;
   	l_grace_period := to_number(nvl(fnd_profile.value('IEX_PTP_GRACE_PERIOD'), '0'));
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.get_broken_on_date: grace period = ' || l_grace_period);
END IF;
	l_broken_on_date := p_promise_date + l_grace_period;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.get_broken_on_date: broken on date = ' || l_broken_on_date);
END IF;
   	x_broken_on_date := l_broken_on_date;
end;


PROCEDURE VALIDATE_INSERT_INPUT(P_PROMISE_REC IN IEX_PROMISES_PUB.PRO_INSRT_REC_TYPE)
IS
    	Type refCur is Ref Cursor;

    	l_api_name		CONSTANT VARCHAR2(30) := 'VALIDATE_INSERT_INPUT';
	l_validation_item	varchar2(100);
    	l_cursor		refCur;
	l_SQL			VARCHAR2(10000);
	l_result_num		number;
	l_result_varchar	varchar2(100);
	l_fun_currency		varchar2(15);
	l_return_status         VARCHAR2(1);
	l_msg_count             NUMBER;
    	l_msg_data              VARCHAR2(32767);

begin
	/* validate promise target */
	l_validation_item := 'P_PROMISE_REC.PROMISE_TARGET';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Validating ' || l_validation_item);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' = ' || P_PROMISE_REC.PROMISE_TARGET);
END IF;
	if P_PROMISE_REC.PROMISE_TARGET is null or
	   (P_PROMISE_REC.PROMISE_TARGET <> 'ACCOUNTS' and
	   P_PROMISE_REC.PROMISE_TARGET <> 'INVOICES' and
	   P_PROMISE_REC.PROMISE_TARGET <> 'CNSLD' and
	   P_PROMISE_REC.PROMISE_TARGET <> 'CONTRACTS')
	then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' failed validation');
END IF;
		FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
		FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_api_name);
		FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

	/* validate promise_amount */
	l_validation_item := 'P_PROMISE_REC.PROMISE_AMOUNT';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Validating ' || l_validation_item);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' = ' || P_PROMISE_REC.PROMISE_AMOUNT);
END IF;
	if P_PROMISE_REC.PROMISE_AMOUNT is null or P_PROMISE_REC.PROMISE_AMOUNT <= 0 then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' failed validation');
END IF;
		FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
		FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_api_name);
		FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

	/* validate promise_date */
	l_validation_item := 'P_PROMISE_REC.PROMISE_DATE';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Validating ' || l_validation_item);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' = ' || P_PROMISE_REC.PROMISE_DATE);
END IF;
	if P_PROMISE_REC.PROMISE_DATE is null or trunc(P_PROMISE_REC.PROMISE_DATE) < trunc(sysdate) then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' failed validation');
END IF;
		FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
		FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_api_name);
		FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

	/* validate currency */
	l_validation_item := 'P_PROMISE_REC.CURRENCY_CODE';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Validating ' || l_validation_item);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' = ' || P_PROMISE_REC.CURRENCY_CODE);
END IF;
	if P_PROMISE_REC.CURRENCY_CODE is null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' failed validation');
END IF;
		FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
		FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_api_name);
		FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

	/* validate resource_id */
	l_validation_item := 'P_PROMISE_REC.TAKEN_BY_RESOURCE_ID';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Validating ' || l_validation_item);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' = ' || P_PROMISE_REC.TAKEN_BY_RESOURCE_ID);
END IF;
	if P_PROMISE_REC.TAKEN_BY_RESOURCE_ID is null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' failed validation');
END IF;
		FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
		FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_api_name);
		FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

	/* get functional currency */
	IEX_CURRENCY_PVT.GET_FUNCT_CURR(
		p_api_version => 1.0,
		p_init_msg_list => FND_API.G_FALSE,
		p_commit => FND_API.G_FALSE,
		P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
		x_return_status => l_return_status,
		x_msg_count => l_msg_count,
		x_msg_data => l_msg_data,
		x_functional_currency => l_fun_currency);

	/* validate payment_method */
	l_validation_item := 'P_PROMISE_REC.PROMISE_PAYMENT_METHOD';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Validating ' || l_validation_item);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' = ' || P_PROMISE_REC.PROMISE_PAYMENT_METHOD);
END IF;
	if P_PROMISE_REC.PROMISE_PAYMENT_METHOD is not null and rtrim(P_PROMISE_REC.PROMISE_PAYMENT_METHOD) <> '' then
		l_SQL := 'SELECT ''X'' ' ||
				'FROM IEX_LOOKUPS_V ' ||
				'WHERE ' ||
				'LOOKUP_TYPE = ''IEX_PAYMENT_TYPES'' AND LOOKUP_CODE = :P_PAYMENT_METHOD AND ' ||
				'ENABLED_FLAG = ''Y''';

		open l_cursor for l_SQL
		using P_PROMISE_REC.PROMISE_PAYMENT_METHOD;
		fetch l_cursor into l_result_varchar;

		if l_cursor%rowcount = 0 or l_result_varchar is null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' failed validation: wrong payment method');
END IF;
			FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
			FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_api_name);
			FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
			FND_MSG_PUB.Add;
			RAISE FND_API.G_EXC_ERROR;
		end if;
	else
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' is null - nothing to validate');
END IF;
	end if;

	/* validate cust_account_id */
	l_validation_item := 'P_PROMISE_REC.CUST_ACCOUNT_ID';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Validating ' || l_validation_item);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' = ' || P_PROMISE_REC.CUST_ACCOUNT_ID);
END IF;
	if P_PROMISE_REC.CUST_ACCOUNT_ID is null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' failed validation');
END IF;
		FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
		FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_api_name);
		FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

	/* validate promise object */
	if P_PROMISE_REC.PROMISE_TARGET = 'ACCOUNTS' then

		/* validate promise date */
		l_validation_item := 'P_PROMISE_REC.PROMISE_DATE';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Validating ' || l_validation_item || ' for dublicates');
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' = ' || P_PROMISE_REC.PROMISE_DATE);
END IF;

        	l_SQL := 'SELECT COUNT(1) ' ||
			'FROM IEX_PROMISE_DETAILS ' ||
			'WHERE ' ||
			'DELINQUENCY_ID IS NULL AND CNSLD_INVOICE_ID IS NULL AND CONTRACT_ID IS NULL AND ' ||
			'CUST_ACCOUNT_ID IS NOT NULL AND CUST_ACCOUNT_ID = :P_CUST_ACCOUNT_ID AND ' ||
			'PROMISE_DATE = :P_PROMISE_DATE AND ' ||
			'STATUS in (''COLLECTABLE'', ''PENDING'')';

        	open l_cursor for l_SQL
        	using P_PROMISE_REC.CUST_ACCOUNT_ID, P_PROMISE_REC.PROMISE_DATE;
        	fetch l_cursor into l_result_num;

        	if l_cursor%rowcount = 0 or l_result_num > 0 then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' failed validation');
END IF;
			FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
			FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_api_name);
			FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
			FND_MSG_PUB.Add;
			RAISE FND_API.G_EXC_ERROR;
		end if;

		/* validate promise currency */
		l_validation_item := 'P_PROMISE_REC.CURRENCY_CODE';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Validating ' || l_validation_item);
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' = ' || P_PROMISE_REC.CURRENCY_CODE);
END IF;
		if P_PROMISE_REC.CURRENCY_CODE <> l_fun_currency then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' failed validation');
END IF;
			FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
			FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_api_name);
			FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
			FND_MSG_PUB.Add;
			RAISE FND_API.G_EXC_ERROR;
		end if;

	elsif P_PROMISE_REC.PROMISE_TARGET = 'INVOICES' then

		/* validate delinquency_id */
		l_validation_item := 'P_PROMISE_REC.DELINQUENCY_ID';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Validating ' || l_validation_item);
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' = ' || P_PROMISE_REC.DELINQUENCY_ID);
END IF;
		if P_PROMISE_REC.DELINQUENCY_ID is null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' failed validation');
END IF;
			FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
			FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_api_name);
			FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
			FND_MSG_PUB.Add;
			RAISE FND_API.G_EXC_ERROR;
		end if;

		/* validate promise date */
		l_validation_item := 'P_PROMISE_REC.PROMISE_DATE';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Validating ' || l_validation_item || ' for dublicates');
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' = ' || P_PROMISE_REC.PROMISE_DATE);
END IF;

        	l_SQL := 'SELECT COUNT(1) ' ||
				'FROM IEX_PROMISE_DETAILS ' ||
				'WHERE ' ||
				'CNSLD_INVOICE_ID IS NULL AND CONTRACT_ID IS NULL AND ' ||
				'CUST_ACCOUNT_ID IS NOT NULL AND CUST_ACCOUNT_ID = :P_CUST_ACCOUNT_ID AND ' ||
				'DELINQUENCY_ID IS NOT NULL AND DELINQUENCY_ID = :P_DELINQUENCY_ID AND ' ||
				'PROMISE_DATE = :P_PROMISE_DATE AND ' ||
				'STATUS in (''COLLECTABLE'', ''PENDING'')';

        	open l_cursor for l_SQL
        	using P_PROMISE_REC.CUST_ACCOUNT_ID,
              		P_PROMISE_REC.DELINQUENCY_ID,
              		P_PROMISE_REC.PROMISE_DATE;
        	fetch l_cursor into l_result_num;

        	if l_cursor%rowcount = 0 or l_result_num > 0 then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' failed validation');
END IF;
			FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
			FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_api_name);
			FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
			FND_MSG_PUB.Add;
			RAISE FND_API.G_EXC_ERROR;
		end if;

		/* validate promise currency */
		l_validation_item := 'P_PROMISE_REC.CURRENCY_CODE';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Validating ' || l_validation_item);
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' = ' || P_PROMISE_REC.CURRENCY_CODE);
END IF;
		l_SQL := 'SELECT PSA.INVOICE_CURRENCY_CODE ' ||
				'FROM AR_PAYMENT_SCHEDULES PSA, IEX_DELINQUENCIES DEL ' ||
				'WHERE ' ||
				'DEL.DELINQUENCY_ID = :P_DELINQUENCY_ID AND ' ||
				'DEL.PAYMENT_SCHEDULE_ID = PSA.PAYMENT_SCHEDULE_ID';

        	open l_cursor for l_SQL
        	using P_PROMISE_REC.DELINQUENCY_ID;
        	fetch l_cursor into l_result_varchar;

        	if l_cursor%rowcount = 0 or l_result_varchar is null or l_result_varchar <> P_PROMISE_REC.CURRENCY_CODE then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' failed validation');
END IF;
			FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
			FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_api_name);
			FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
			FND_MSG_PUB.Add;
			RAISE FND_API.G_EXC_ERROR;
		end if;

	elsif P_PROMISE_REC.PROMISE_TARGET = 'CNSLD' then

		/* validate consolidated_invoice_id */
		l_validation_item := 'P_PROMISE_REC.CNSLD_INVOICE_ID';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Validating ' || l_validation_item);
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' = ' || P_PROMISE_REC.CNSLD_INVOICE_ID);
END IF;
		if P_PROMISE_REC.CNSLD_INVOICE_ID is null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' failed validation');
END IF;
			FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
			FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_api_name);
			FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
			FND_MSG_PUB.Add;
			RAISE FND_API.G_EXC_ERROR;
		end if;

		/* validate promise date */
		l_validation_item := 'P_PROMISE_REC.PROMISE_DATE';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Validating ' || l_validation_item || ' for dublicates');
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' = ' || P_PROMISE_REC.PROMISE_DATE);
END IF;

        	l_SQL := 'SELECT COUNT(1) ' ||
				'FROM IEX_PROMISE_DETAILS ' ||
				'WHERE ' ||
				'DELINQUENCY_ID IS NULL AND CONTRACT_ID IS NULL AND ' ||
				'CUST_ACCOUNT_ID IS NOT NULL AND CUST_ACCOUNT_ID = :P_CUST_ACCOUNT_ID AND ' ||
				'CNSLD_INVOICE_ID IS NOT NULL AND CNSLD_INVOICE_ID = :P_CNSLD_INVOICE_ID AND ' ||
				'PROMISE_DATE = :P_PROMISE_DATE AND ' ||
				'STATUS in (''COLLECTABLE'', ''PENDING'')';

        	open l_cursor for l_SQL
        	using P_PROMISE_REC.CUST_ACCOUNT_ID,
              		P_PROMISE_REC.CNSLD_INVOICE_ID,
              		P_PROMISE_REC.PROMISE_DATE;
        	fetch l_cursor into l_result_num;

        	if l_cursor%rowcount = 0 or l_result_num > 0 then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' failed validation');
END IF;
			FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
			FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_api_name);
			FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
			FND_MSG_PUB.Add;
			RAISE FND_API.G_EXC_ERROR;
		end if;

		/* validate promise currency */
		l_validation_item := 'P_PROMISE_REC.CURRENCY_CODE';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Validating ' || l_validation_item);
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' = ' || P_PROMISE_REC.CURRENCY_CODE);
END IF;

		l_SQL := 'SELECT CNSLD.CURRENCY_CODE ' ||
				'FROM IEX_BPD_CNSLD_INV_REMAINING_V CNSLD ' ||
				'WHERE ' ||
				'CNSLD.CONSOLIDATED_INVOICE_ID = :P_CNSLD_ID';

        	open l_cursor for l_SQL
        	using P_PROMISE_REC.CNSLD_INVOICE_ID;
        	fetch l_cursor into l_result_varchar;

        	if l_cursor%rowcount = 0 or l_result_varchar is null or l_result_varchar <> P_PROMISE_REC.CURRENCY_CODE then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' failed validation');
END IF;
			FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
			FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_api_name);
			FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
			FND_MSG_PUB.Add;
			RAISE FND_API.G_EXC_ERROR;
		end if;

	elsif P_PROMISE_REC.PROMISE_TARGET = 'CONTRACTS' then

		/* validate contract_id */
		l_validation_item := 'P_PROMISE_REC.CONTRACT_ID';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Validating ' || l_validation_item);
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' = ' || P_PROMISE_REC.CONTRACT_ID);
END IF;
		if P_PROMISE_REC.CONTRACT_ID is null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' failed validation');
END IF;
			FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
			FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_api_name);
			FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
			FND_MSG_PUB.Add;
			RAISE FND_API.G_EXC_ERROR;
		end if;

		/* validate promise date */
		l_validation_item := 'P_PROMISE_REC.PROMISE_DATE';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Validating ' || l_validation_item || ' for dublicates');
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' = ' || P_PROMISE_REC.PROMISE_DATE);
END IF;

        	l_SQL := 'SELECT COUNT(1) ' ||
				'FROM IEX_PROMISE_DETAILS ' ||
				'WHERE ' ||
				'DELINQUENCY_ID IS NULL AND CNSLD_INVOICE_ID IS NULL AND ' ||
				'CUST_ACCOUNT_ID IS NOT NULL AND CUST_ACCOUNT_ID = :P_CUST_ACCOUNT_ID AND ' ||
				'CONTRACT_ID IS NOT NULL AND CONTRACT_ID = :P_CONTRACT_ID AND ' ||
				'PROMISE_DATE = :P_PROMISE_DATE AND ' ||
				'STATUS in (''COLLECTABLE'', ''PENDING'')';

        	open l_cursor for l_SQL
        	using P_PROMISE_REC.CUST_ACCOUNT_ID,
              		P_PROMISE_REC.CONTRACT_ID,
              		P_PROMISE_REC.PROMISE_DATE;
        	fetch l_cursor into l_result_num;

        	if l_cursor%rowcount = 0 or l_result_num > 0 then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' failed validation');
END IF;
			FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
			FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_api_name);
			FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
			FND_MSG_PUB.Add;
			RAISE FND_API.G_EXC_ERROR;
		end if;

		/* validate promise currency */
		l_validation_item := 'P_PROMISE_REC.CURRENCY_CODE';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Validating ' || l_validation_item);
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' = ' || P_PROMISE_REC.CURRENCY_CODE);
END IF;

                /* Fixed a perf bug 4932919
		l_SQL := 'SELECT cntr.CURRENCY_CODE ' ||
				'FROM iex_pay_okl_contracts_v cntr ' ||
				'WHERE ' ||
				'cntr.CONTRACT_ID = :P_CONTRACT_ID';     */

		l_SQL := 'SELECT CURRENCY_CODE ' ||
				'FROM OKC_K_HEADERS_B ' ||
				'WHERE ' ||
				'ID = :P_CONTRACT_ID';


        	open l_cursor for l_SQL
        	using P_PROMISE_REC.CONTRACT_ID;
        	fetch l_cursor into l_result_varchar;

        	if l_cursor%rowcount = 0 or l_result_varchar is null or l_result_varchar <> P_PROMISE_REC.CURRENCY_CODE then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' failed validation');
END IF;
			FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
			FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_api_name);
			FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
			FND_MSG_PUB.Add;
			RAISE FND_API.G_EXC_ERROR;
		end if;

	end if;

end;

PROCEDURE INSERT_PROMISE(
    	P_API_VERSION		IN      NUMBER,
    	P_INIT_MSG_LIST		IN      VARCHAR2, --  DEFAULT FND_API.G_FALSE,
    	P_COMMIT                IN      VARCHAR2, -- DEFAULT FND_API.G_FALSE,
    	P_VALIDATION_LEVEL	IN      NUMBER, -- DEFAULT FND_API.G_VALID_LEVEL_FULL,
    	X_RETURN_STATUS		OUT NOCOPY     VARCHAR2,
    	X_MSG_COUNT             OUT NOCOPY     NUMBER,
    	X_MSG_DATA	    	OUT NOCOPY     VARCHAR2,
    	P_PROMISE_REC           IN	IEX_PROMISES_PUB.PRO_INSRT_REC_TYPE,
    	X_PRORESP_REC		OUT NOCOPY	IEX_PROMISES_PUB.PRO_RESP_REC_TYPE)
IS
    	l_api_name			CONSTANT VARCHAR2(30) := 'INSERT_PROMISE';
   	 l_api_version               	CONSTANT NUMBER := 1.0;
    	l_return_status             	VARCHAR2(1);
    	l_msg_count                	 NUMBER;
    	l_msg_data                  	VARCHAR2(32767);

    	i                           	NUMBER;
    	l_promise_id                	NUMBER;
	l_broken_on_date			date;
    	l_rowid                     	VARCHAR2(100);
	l_promise_status		varchar2(30);
	l_promise_state			varchar2(30); -- := 'PROMISE';

	l_note_payer_id			NUMBER;
	l_payer_num_id			NUMBER;
	l_payer_id			VARCHAR2(80);
	l_payer_name			HZ_PARTIES.PARTY_NAME%TYPE;  --Changed the datatype for bug#5652085 by ehuh 2/28/07
	l_note_payer_type		VARCHAR2(100);
	l_context_tab			IEX_NOTES_PVT.CONTEXTS_TBL_TYPE;
	l_note_id			NUMBER;
	l_org_id			number;  --Added for bug 7237026 barathsr 17-Nov-2008


    	-- generate new promise detail
    	CURSOR prd_genid_crs IS
        	select IEX_PROMISE_DETAILS_S.NEXTVAL from dual;
     --Begin bug 7237026 17-Nov-2208 barathsr
		CURSOR c_org_id (p_del_id number) IS
		select org_id
		from iex_delinquencies_all
		where delinquency_id = p_del_id;
     --End bug 7237026 17-Nov-2208 barathsr

BEGIN
	l_promise_state := 'PROMISE';

    	-- Standard start of API savepoint
    	SAVEPOINT INSERT_PROMISE_PVT;

    	-- Standard call to check for call compatibility
    	IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    	END IF;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.To_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;

    	-- Initialize API return status to success
    	l_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- START OF BODY OF API
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	   iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Start of body');
        END IF;

	/* validate input */
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	   iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Validating input...');
        END IF;

	VALIDATE_INSERT_INPUT(P_PROMISE_REC);

	/* validate payer info */
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	   iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Validating parties...');
        END IF;

	IEX_PAYMENTS_PUB.GET_PAYER_INFO(
		P_PAYER_PARTY_REL_ID => P_PROMISE_REC.PROMISED_BY_PARTY_REL_ID,
		P_PAYER_PARTY_ORG_ID => P_PROMISE_REC.PROMISED_BY_PARTY_ORG_ID,
		P_PAYER_PARTY_PER_ID => P_PROMISE_REC.PROMISED_BY_PARTY_PER_ID,
		X_NOTE_PAYER_TYPE => l_note_payer_type,
		X_NOTE_PAYER_NUM_ID => l_note_payer_id,
		X_PAYER_NUM_ID => l_payer_num_id,
		X_PAYER_ID => l_payer_id,
		X_PAYER_NAME => l_payer_name);

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	   iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Generate new promise_id');
        END IF;

    	-- generate new promise id
    	OPEN prd_genid_crs;
	FETCH prd_genid_crs INTO l_promise_id;
	CLOSE prd_genid_crs;

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	   iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': new promise_id = ' || l_promise_id);
        END IF;

	-- get broken on date
	GET_BROKEN_ON_DATE(P_PROMISE_DATE => P_PROMISE_REC.PROMISE_DATE, X_BROKEN_ON_DATE => l_broken_on_date);
	-- start wf and return promise status
	START_PTP_WF(P_PROMISE_ID => l_promise_id, X_PROMISE_STATUS => l_promise_status);


--Begin bug 7237026 17-Nov-2208 barathsr
	open c_org_id(P_PROMISE_REC.DELINQUENCY_ID);
        fetch c_org_id into l_org_id;
        close c_org_id;

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	   iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Doing insert...');
        END IF;

    	INSERT INTO IEX_PROMISE_DETAILS
	(
		PROMISE_DETAIL_ID,
		OBJECT_VERSION_NUMBER,
		PROGRAM_ID,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
		CREATION_DATE,
		CREATED_BY,
		PROMISE_DATE,
		PROMISE_AMOUNT,
		PROMISE_PAYMENT_METHOD,
		STATUS,
		ACCOUNT,
		PROMISE_ITEM_NUMBER,
		CURRENCY_CODE,
		CAMPAIGN_SCHED_ID,
		DELINQUENCY_ID,
		RESOURCE_ID,
		PROMISE_MADE_BY,
		CUST_ACCOUNT_ID,
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15,
		CNSLD_INVOICE_ID,
		CONTRACT_ID,
		BROKEN_ON_DATE,
		AMOUNT_DUE_REMAINING,
		STATE,
		ORG_ID
	)
	VALUES
	(
		l_promise_id,
		1.0,
		G_APP_ID,
		sysdate,
		G_USER_ID,
		G_LOGIN_ID,
		sysdate,
		G_USER_ID,
		P_PROMISE_REC.PROMISE_DATE,
		P_PROMISE_REC.PROMISE_AMOUNT,
		P_PROMISE_REC.PROMISE_PAYMENT_METHOD,
		l_promise_status,
		P_PROMISE_REC.ACCOUNT,
		P_PROMISE_REC.PROMISE_ITEM_NUMBER,
		P_PROMISE_REC.CURRENCY_CODE,
		P_PROMISE_REC.CAMPAIGN_SCHED_ID,
		P_PROMISE_REC.DELINQUENCY_ID,
		P_PROMISE_REC.TAKEN_BY_RESOURCE_ID,
		P_PROMISE_REC.PROMISED_BY_PARTY_PER_ID,
		P_PROMISE_REC.CUST_ACCOUNT_ID,
		P_PROMISE_REC.ATTRIBUTES.ATTRIBUTE_CATEGORY,
		P_PROMISE_REC.ATTRIBUTES.ATTRIBUTE1,
		P_PROMISE_REC.ATTRIBUTES.ATTRIBUTE2,
		P_PROMISE_REC.ATTRIBUTES.ATTRIBUTE3,
		P_PROMISE_REC.ATTRIBUTES.ATTRIBUTE4,
		P_PROMISE_REC.ATTRIBUTES.ATTRIBUTE5,
		P_PROMISE_REC.ATTRIBUTES.ATTRIBUTE6,
		P_PROMISE_REC.ATTRIBUTES.ATTRIBUTE7,
		P_PROMISE_REC.ATTRIBUTES.ATTRIBUTE8,
		P_PROMISE_REC.ATTRIBUTES.ATTRIBUTE9,
		P_PROMISE_REC.ATTRIBUTES.ATTRIBUTE10,
		P_PROMISE_REC.ATTRIBUTES.ATTRIBUTE11,
		P_PROMISE_REC.ATTRIBUTES.ATTRIBUTE12,
		P_PROMISE_REC.ATTRIBUTES.ATTRIBUTE13,
		P_PROMISE_REC.ATTRIBUTES.ATTRIBUTE14,
		P_PROMISE_REC.ATTRIBUTES.ATTRIBUTE15,
		P_PROMISE_REC.CNSLD_INVOICE_ID,
		P_PROMISE_REC.CONTRACT_ID,
		l_broken_on_date,
		P_PROMISE_REC.PROMISE_AMOUNT,
		l_promise_state,
		l_org_id
	);

	--End bug 7237026 17-Nov-2208 barathsr

    	X_PRORESP_REC.PROMISE_ID := l_promise_id;
    	X_PRORESP_REC.STATUS := l_promise_status;
    	X_PRORESP_REC.STATE := l_promise_state;

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	   iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Insert OK');
        END IF;

	--start
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Calling update_del_stage_level');
	END IF;
	update_del_stage_level (
		p_promise_id		=> l_promise_id,
		X_RETURN_STATUS		=> l_return_status,
		X_MSG_COUNT             => l_msg_count,
		X_MSG_DATA	    	=> l_msg_data);

	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': After call to update_del_stage_level');
	      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Status = ' || L_RETURN_STATUS);
	END IF;

	-- check for errors
	IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		     iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': update_del_stage_level failed');
		END IF;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
	--end

	-- inserting a note
	if P_PROMISE_REC.NOTE is not null then

                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		   iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Going to build context for note...');
                END IF;

		i := 1;
		/* assigning source_object and adding parties into note context */
		if l_note_payer_type = 'PARTY_RELATIONSHIP' then
			l_context_tab(i).context_type := 'PARTY';
			l_context_tab(i).context_id := P_PROMISE_REC.PROMISED_BY_PARTY_ORG_ID;
			i := i + 1;
			l_context_tab(i).context_type := 'PARTY';
			l_context_tab(i).context_id := P_PROMISE_REC.PROMISED_BY_PARTY_PER_ID;
			i := i + 1;
		end if;

		/* adding account into note context */
		l_context_tab(i).context_type := 'IEX_ACCOUNT';
		l_context_tab(i).context_id := P_PROMISE_REC.CUST_ACCOUNT_ID;
		i := i + 1;

		l_context_tab(i).context_type := 'IEX_PROMISE';
		l_context_tab(i).context_id := l_promise_id;
		i := i + 1;

		FOR i IN 1..l_context_tab.COUNT LOOP
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': l_context_tab(' || i || ').context_type = ' || l_context_tab(i).context_type);
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': l_context_tab(' || i || ').context_id = ' || l_context_tab(i).context_id);
                   END IF;
		END LOOP;

		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		  iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Calling IEX_NOTES_PVT.Create_Note...');
                END IF;

		IEX_NOTES_PVT.Create_Note(
			P_API_VERSION => 1.0,
			P_INIT_MSG_LIST => 'F',
			P_COMMIT => 'F',
			P_VALIDATION_LEVEL => 100,
			X_RETURN_STATUS => l_return_status,
			X_MSG_COUNT => l_msg_count,
			X_MSG_DATA => l_msg_data,
			p_source_object_id => l_promise_id, -- Fixed by Ehuhh 02/05/-7 for a bug 5763697 l_note_payer_id,
			p_source_object_code => 'IEX_PROMISE', -- Fixed by Ehuhh 02/05/-7 for a bug 5763697 'PARTY',
			p_note_type => 'IEX_PROMISE',
			p_notes	=> P_PROMISE_REC.NOTE,
			p_contexts_tbl => l_context_tab,
			x_note_id => l_note_id);

		X_PRORESP_REC.NOTE_ID := l_note_id;

		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': After call to IEX_NOTES_PVT.Create_Note');
		      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Status = ' || L_RETURN_STATUS);
                END IF;

		-- check for errors
		IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			     iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': IEX_NOTES_PVT.Create_Note failed');
                        END IF;
			RAISE FND_API.G_EXC_ERROR;
		END IF;
	else
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		  iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': no note to save');
        END IF;
	end if;

/*	SEND_FFM and SET_STRATEGY should be processed on the client

	-- sending ffm
	--SEND_FFM(P_PROMISE_ID => l_promise_id, P_PARTY_ID => l_note_payer_id);

	-- setting strategy
	--SET_STRATEGY(P_PROMISE_ID => l_promise_id, P_STATUS => 'ONHOLD');
*/

    	-- END OF BODY OF API

    	-- Standard check of p_commit.
    	IF FND_API.To_Boolean( p_commit ) THEN
        	COMMIT WORK;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': commited');
END IF;
    	END IF;

	x_return_status := l_return_status;
    	-- Standard call to get message count and if count is 1, get message info
    	FND_MSG_PUB.Count_And_Get(
                   p_encoded => FND_API.G_FALSE,
                   p_count => x_msg_count,
                   p_data => x_msg_data);

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': end of API');
END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO INSERT_PROMISE_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO INSERT_PROMISE_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO INSERT_PROMISE_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END;

PROCEDURE VALIDATE_UPDATE_INPUT(P_PROMISE_REC IN IEX_PROMISES_PUB.PRO_UPDT_REC_TYPE)
IS
    	Type refCur is Ref Cursor;

	l_validation_item		varchar2(100);
    	l_cursor			refCur;
	l_SQL				VARCHAR2(10000);
	l_result_num			number;
	l_result_varchar		varchar2(100);
	l_fun_currency			varchar2(15);
	l_return_status             	VARCHAR2(1);
	l_msg_count                 	NUMBER;
    	l_msg_data                  	VARCHAR2(32767);
	l_procedure			varchar2(50); --  := 'VALIDATE_UPDATE_INPUT';
	l_promise_status		varchar2(30);
	l_promise_state			varchar2(30);
	l_del_id			number;
	l_cust_id			number;
	l_cnsld_id			number;
	l_cntr_id			number;
	l_where_clause			varchar2(2000);
	l_promise_amount		number;
	l_remaining_amount		number;
        l_str_del1 varchar2(100); -- := ' AND DELINQUENCY_ID = ';
        l_str_del2 varchar2(100); -- := ' AND DELINQUENCY_ID is null';
        l_str_cnsld1 varchar2(100); -- := ' AND CNSLD_INVOICE_ID = ';
        l_str_cnsld2 varchar2(100); --  := ' AND CNSLD_INVOICE_ID is null';
        l_str_cnt1 varchar2(100); -- := ' AND CONTRACT_ID = ';
        l_str_cnt2 varchar2(100); -- := ' AND CONTRACT_ID is null';
        l_str_select varchar2(1000); -- := 'SELECT COUNT(1) ' ||
			 -- 'FROM IEX_PROMISE_DETAILS ' ||
			 -- 'WHERE ';
        l_str_cond varchar2(1000); -- := ' AND ' ||
			-- 'promise_detail_id <> :P_PROMISE_ID AND ' ||
			-- 'PROMISE_DATE = :P_PROMISE_DATE AND ' ||
			-- 'STATUS in (''COLLECTABLE'', ''PENDING'')';

begin
	l_procedure := 'VALIDATE_UPDATE_INPUT';
        l_str_del1  := ' AND DELINQUENCY_ID = ';
        l_str_del2  := ' AND DELINQUENCY_ID is null';
        l_str_cnsld1 := ' AND CNSLD_INVOICE_ID = ';
        l_str_cnsld2 := ' AND CNSLD_INVOICE_ID is null';
        l_str_cnt1  := ' AND CONTRACT_ID = ';
        l_str_cnt2  := ' AND CONTRACT_ID is null';
        l_str_select := 'SELECT COUNT(1) ' ||
			'FROM IEX_PROMISE_DETAILS ' ||
			'WHERE ';
        l_str_cond  := ' AND ' ||
			'promise_detail_id <> :P_PROMISE_ID AND ' ||
			'PROMISE_DATE = :P_PROMISE_DATE AND ' ||
			'STATUS in (''COLLECTABLE'', ''PENDING'')';
	/* validate promise id */
	l_validation_item := 'P_PROMISE_REC.PROMISE_ID';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': Validating ' || l_validation_item);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': ' || l_validation_item || ' = ' || P_PROMISE_REC.PROMISE_ID);
END IF;
	if P_PROMISE_REC.PROMISE_ID is null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': ' || l_validation_item || ' failed validation');
END IF;
		FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
		FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_procedure);
		FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

	/* validate promise_amount */
	l_validation_item := 'P_PROMISE_REC.PROMISE_AMOUNT';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': Validating ' || l_validation_item);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': ' || l_validation_item || ' = ' || P_PROMISE_REC.PROMISE_AMOUNT);
END IF;
	if P_PROMISE_REC.PROMISE_AMOUNT is null or P_PROMISE_REC.PROMISE_AMOUNT <= 0 then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': ' || l_validation_item || ' failed validation');
END IF;
		FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
		FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_procedure);
		FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

	/* validate resource_id */
	l_validation_item := 'P_PROMISE_REC.TAKEN_BY_RESOURCE_ID';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': Validating ' || l_validation_item);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': ' || l_validation_item || ' = ' || P_PROMISE_REC.TAKEN_BY_RESOURCE_ID);
END IF;
	if P_PROMISE_REC.TAKEN_BY_RESOURCE_ID is null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': ' || l_validation_item || ' failed validation: resource id must be set');
END IF;
		FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
		FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_procedure);
		FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

	/* pull data from db to do some validation */
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': Validating db data');
END IF;
	l_SQL := 'SELECT CUST_ACCOUNT_ID, DELINQUENCY_ID, CNSLD_INVOICE_ID, CONTRACT_ID, STATUS, STATE, PROMISE_AMOUNT, AMOUNT_DUE_REMAINING ' ||
			'FROM IEX_PROMISE_DETAILS ' ||
			'WHERE ' ||
			'PROMISE_DETAIL_ID = :P_PROMISE_ID';

    	open l_cursor for l_SQL
    	using P_PROMISE_REC.PROMISE_ID;
    	fetch l_cursor into l_cust_id, l_del_id, l_cnsld_id, l_cntr_id, l_promise_status, l_promise_state, l_promise_amount, l_remaining_amount;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': From db:');
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': Cust_account_id = ' || l_cust_id);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': Delinquency_id = ' || l_promise_status);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': Cnsld_id = ' || l_cnsld_id);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': Contract_id = ' || l_cntr_id);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': Promise status = ' || l_promise_status);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': Promise state = ' || l_promise_state);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': Promise amount = ' || l_promise_amount);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': Promise remaining amount = ' || l_remaining_amount);
END IF;

	/* validate promise_status */
	l_validation_item := 'STATUS';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': Validating ' || l_validation_item);
END IF;
    	if l_promise_status <> 'COLLECTABLE' then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': ' || l_validation_item || ' failed validation: status is not COLLECTABLE');
END IF;
		FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
		FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_procedure);
		FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

	/* validate promise_state */
	l_validation_item := 'STATE';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': Validating ' || l_validation_item);
END IF;
    	if l_promise_state <> 'PROMISE' then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': ' || l_validation_item || ' failed validation: state is not PROMISE');
END IF;
		FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
		FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_procedure);
		FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

	/* validate remaining amount */
	l_validation_item := 'AMOUNT_DUE_REMAINING';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': Validating ' || l_validation_item);
END IF;
    	if l_remaining_amount <> l_promise_amount then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': ' || l_validation_item || ' failed validation: remaining amount <> promise amount');
END IF;
		FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
		FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_procedure);
		FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

	/* validate promise_date */
	l_validation_item := 'P_PROMISE_REC.PROMISE_DATE';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': Validating ' || l_validation_item);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': ' || l_validation_item || ' = ' || P_PROMISE_REC.PROMISE_DATE);
END IF;
	if P_PROMISE_REC.PROMISE_DATE is null or trunc(P_PROMISE_REC.PROMISE_DATE) < trunc(sysdate) then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': ' || l_validation_item || ' failed validation: promise_date must be >= current date');
END IF;
		FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
		FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_procedure);
		FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': Validating ' || l_validation_item || ' for dublicates');
END IF;

	/* building sql stmt to check for duplicates */
	l_where_clause := 'CUST_ACCOUNT_ID = ' || l_cust_id;


	if l_del_id is not null then
		l_where_clause := l_where_clause || l_str_del1 || l_del_id;
	else
		l_where_clause := l_where_clause || l_str_del2;
	end if;

	if l_cnsld_id is not null then
		l_where_clause := l_where_clause || l_str_cnsld1 || l_cnsld_id;
	else
		l_where_clause := l_where_clause || l_str_cnsld2;
	end if;

	if l_cntr_id is not null then
		l_where_clause := l_where_clause || l_str_cnt1 || l_cntr_id;
	else
		l_where_clause := l_where_clause || l_str_cnt2;
	end if;

        l_SQL := l_str_select || l_where_clause || l_str_cond;

        /* fix bind varviolation error
       	l_SQL := 'SELECT COUNT(1) ' ||
			'FROM IEX_PROMISE_DETAILS ' ||
			'WHERE ' || l_where_clause || ' AND ' ||
			'promise_detail_id <> :P_PROMISE_ID AND ' ||
			'PROMISE_DATE = :P_PROMISE_DATE AND ' ||
			'STATUS in (''COLLECTABLE'', ''PENDING'')';
       */

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': l_SQL = ' || l_SQL);
END IF;

	open l_cursor for l_SQL
	using P_PROMISE_REC.PROMISE_ID,
	      P_PROMISE_REC.PROMISE_DATE;
	fetch l_cursor into l_result_num;

	if l_cursor%rowcount = 0 or l_result_num > 0 then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': ' || l_validation_item || ' failed validation: found promise date duplication');
END IF;
		FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
		FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_procedure);
		FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

	/* validate payment_method */
	l_validation_item := 'P_PROMISE_REC.PROMISE_PAYMENT_METHOD';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': Validating ' || l_validation_item);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': ' || l_validation_item || ' = ''' || rtrim(P_PROMISE_REC.PROMISE_PAYMENT_METHOD) || '''');
END IF;
	if P_PROMISE_REC.PROMISE_PAYMENT_METHOD is not null and rtrim(P_PROMISE_REC.PROMISE_PAYMENT_METHOD) <> '' then
		l_SQL := 'SELECT ''X'' ' ||
				'FROM IEX_LOOKUPS_V ' ||
				'WHERE ' ||
				'LOOKUP_TYPE = ''IEX_PAYMENT_TYPES'' AND LOOKUP_CODE = :P_PAYMENT_METHOD AND ' ||
				'ENABLED_FLAG = ''Y''';

		open l_cursor for l_SQL
		using P_PROMISE_REC.PROMISE_PAYMENT_METHOD;
		fetch l_cursor into l_result_varchar;

		if l_cursor%rowcount = 0 or l_result_varchar is null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': ' || l_validation_item || ' failed validation: wrong payment method');
END IF;
			FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
			FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_procedure);
			FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
			FND_MSG_PUB.Add;
			RAISE FND_API.G_EXC_ERROR;
		end if;
	else
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': ' || l_validation_item || ' is null - nothing to validate');
END IF;
	end if;

end;

PROCEDURE UPDATE_PROMISE(
    	P_API_VERSION			IN      NUMBER,
    	P_INIT_MSG_LIST			IN      VARCHAR2, -- DEFAULT FND_API.G_FALSE,
    	P_COMMIT                    	IN      VARCHAR2, -- DEFAULT FND_API.G_FALSE,
    	P_VALIDATION_LEVEL	    	IN      NUMBER, --  DEFAULT FND_API.G_VALID_LEVEL_FULL,
    	X_RETURN_STATUS			OUT NOCOPY     VARCHAR2,
    	X_MSG_COUNT                 	OUT NOCOPY     NUMBER,
    	X_MSG_DATA	    	    	OUT NOCOPY     VARCHAR2,
    	P_PROMISE_REC               	IN	IEX_PROMISES_PUB.PRO_UPDT_REC_TYPE,
    	X_PRORESP_REC			OUT NOCOPY	IEX_PROMISES_PUB.PRO_RESP_REC_TYPE)
IS
    	l_api_name			CONSTANT VARCHAR2(30) := 'UPDATE_PROMISE';
    	l_api_version               	CONSTANT NUMBER := 1.0;
    	l_return_status             	VARCHAR2(1);
    	l_msg_count                 	NUMBER;
    	l_msg_data                  	VARCHAR2(32767);

    	i                           	NUMBER;
    	l_promise_id                	NUMBER;
	l_broken_on_date		date;
	l_promise_status		varchar2(30);

	l_note_payer_id			NUMBER;
	l_payer_num_id			NUMBER;
	l_payer_id			VARCHAR2(80);
	l_payer_name			HZ_PARTIES.PARTY_NAME%TYPE;  --Changed the datatype for bug#5652085 by ehuh 2/28/07
	l_note_payer_type		VARCHAR2(100);
	l_context_tab			IEX_NOTES_PVT.CONTEXTS_TBL_TYPE;
	l_note_id			NUMBER;
	l_cust_id			number;
	l_SQL				VARCHAR2(1000);
    	Type refCur is Ref Cursor;
    	l_cursor			refCur;

BEGIN
    	-- Standard start of API savepoint
    	SAVEPOINT UPDATE_PROMISE_PVT;

    	-- Standard call to check for call compatibility
    	IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    	END IF;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.To_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;

    	-- Initialize API return status to success
    	l_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- START OF BODY OF API
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Start of body');
END IF;

	/* validate input */
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Validating input...');
END IF;
	VALIDATE_UPDATE_INPUT(P_PROMISE_REC);

	/* validate promiser info */
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Validating parties...');
END IF;
	IEX_PAYMENTS_PUB.GET_PAYER_INFO(
		P_PAYER_PARTY_REL_ID => P_PROMISE_REC.PROMISED_BY_PARTY_REL_ID,
		P_PAYER_PARTY_ORG_ID => P_PROMISE_REC.PROMISED_BY_PARTY_ORG_ID,
		P_PAYER_PARTY_PER_ID => P_PROMISE_REC.PROMISED_BY_PARTY_PER_ID,
		X_NOTE_PAYER_TYPE => l_note_payer_type,
		X_NOTE_PAYER_NUM_ID => l_note_payer_id,
		X_PAYER_NUM_ID => l_payer_num_id,
		X_PAYER_ID => l_payer_id,
		X_PAYER_NAME => l_payer_name);

	/*get broken_on date */
	GET_BROKEN_ON_DATE(P_PROMISE_DATE => P_PROMISE_REC.PROMISE_DATE, X_BROKEN_ON_DATE => l_broken_on_date);
	/* start workflow and get new promise status */
	START_PTP_WF(P_PROMISE_ID => l_promise_id, X_PROMISE_STATUS => l_promise_status);

	/* do update */
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	   iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Doing update...');
        END IF;

	UPDATE iex_promise_details
	SET PROMISE_AMOUNT = P_PROMISE_REC.PROMISE_AMOUNT,
	AMOUNT_DUE_REMAINING = P_PROMISE_REC.PROMISE_AMOUNT,
	PROMISE_DATE = P_PROMISE_REC.PROMISE_DATE,
	BROKEN_ON_DATE = l_broken_on_date,
	STATUS = l_promise_status,
	PROMISE_PAYMENT_METHOD = P_PROMISE_REC.PROMISE_PAYMENT_METHOD,
	ACCOUNT = P_PROMISE_REC.ACCOUNT,
	PROMISE_ITEM_NUMBER = P_PROMISE_REC.PROMISE_ITEM_NUMBER,
	CAMPAIGN_SCHED_ID = P_PROMISE_REC.CAMPAIGN_SCHED_ID,
	ATTRIBUTE_CATEGORY = P_PROMISE_REC.ATTRIBUTES.ATTRIBUTE_CATEGORY,
	ATTRIBUTE1 = P_PROMISE_REC.ATTRIBUTES.ATTRIBUTE1,
	ATTRIBUTE2 = P_PROMISE_REC.ATTRIBUTES.ATTRIBUTE2,
	ATTRIBUTE3 = P_PROMISE_REC.ATTRIBUTES.ATTRIBUTE3,
	ATTRIBUTE4 = P_PROMISE_REC.ATTRIBUTES.ATTRIBUTE4,
	ATTRIBUTE5 = P_PROMISE_REC.ATTRIBUTES.ATTRIBUTE5,
	ATTRIBUTE6 = P_PROMISE_REC.ATTRIBUTES.ATTRIBUTE6,
	ATTRIBUTE7 = P_PROMISE_REC.ATTRIBUTES.ATTRIBUTE7,
	ATTRIBUTE8 = P_PROMISE_REC.ATTRIBUTES.ATTRIBUTE8,
	ATTRIBUTE9 = P_PROMISE_REC.ATTRIBUTES.ATTRIBUTE9,
	ATTRIBUTE10 = P_PROMISE_REC.ATTRIBUTES.ATTRIBUTE10,
	ATTRIBUTE11 = P_PROMISE_REC.ATTRIBUTES.ATTRIBUTE11,
	ATTRIBUTE12 = P_PROMISE_REC.ATTRIBUTES.ATTRIBUTE12,
	ATTRIBUTE13 = P_PROMISE_REC.ATTRIBUTES.ATTRIBUTE13,
	ATTRIBUTE14 = P_PROMISE_REC.ATTRIBUTES.ATTRIBUTE14,
	ATTRIBUTE15 = P_PROMISE_REC.ATTRIBUTES.ATTRIBUTE15,
	RESOURCE_ID = P_PROMISE_REC.TAKEN_BY_RESOURCE_ID,
	PROMISE_MADE_BY = P_PROMISE_REC.PROMISED_BY_PARTY_PER_ID,
	PROGRAM_ID = G_APP_ID,
	last_update_date = sysdate,
	last_updated_by = G_USER_ID,
	LAST_UPDATE_LOGIN = G_LOGIN_ID
	where promise_detail_id = P_PROMISE_REC.PROMISE_ID;

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	   iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Update OK');
        END IF;

   	X_PRORESP_REC.PROMISE_ID := P_PROMISE_REC.PROMISE_ID;
    	X_PRORESP_REC.STATUS := l_promise_status;

	/* getting promise state */
	l_SQL := 'SELECT state FROM IEX_PROMISE_DETAILS WHERE PROMISE_DETAIL_ID = :P_PROMISE_ID';

	open l_cursor for l_SQL
	using P_PROMISE_REC.PROMISE_ID;
	fetch l_cursor into X_PRORESP_REC.STATE;

	--start
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Calling update_del_stage_level');
	END IF;
	update_del_stage_level (
		p_promise_id		=> P_PROMISE_REC.PROMISE_ID,
		X_RETURN_STATUS		=> l_return_status,
		X_MSG_COUNT             => l_msg_count,
		X_MSG_DATA	    	=> l_msg_data);

	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': After call to update_del_stage_level');
	      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Status = ' || L_RETURN_STATUS);
	END IF;

	-- check for errors
	IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		     iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': update_del_stage_level failed');
		END IF;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
	--end

	-- inserting a note
	if P_PROMISE_REC.NOTE is not null then

                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	      	   iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Going to build context for note...');
                END IF;

		i := 1;
		/* assigning source_object and adding parties into note context */
		if l_note_payer_type = 'PARTY_RELATIONSHIP' then
			l_context_tab(i).context_type := 'PARTY';
			l_context_tab(i).context_id := P_PROMISE_REC.PROMISED_BY_PARTY_ORG_ID;
			i := i + 1;
			l_context_tab(i).context_type := 'PARTY';
			l_context_tab(i).context_id := P_PROMISE_REC.PROMISED_BY_PARTY_PER_ID;
			i := i + 1;
		end if;

		/* adding account into note context */
		l_SQL := 'SELECT CUST_ACCOUNT_ID ' ||
				'FROM IEX_PROMISE_DETAILS ' ||
				'WHERE ' ||
				'PROMISE_DETAIL_ID = :P_PROMISE_ID';

		open l_cursor for l_SQL
		using P_PROMISE_REC.PROMISE_ID;
		fetch l_cursor into l_cust_id;

		l_context_tab(i).context_type := 'IEX_ACCOUNT';
		l_context_tab(i).context_id := l_cust_id;
		i := i + 1;

		l_context_tab(i).context_type := 'IEX_PROMISE';
		l_context_tab(i).context_id := P_PROMISE_REC.PROMISE_ID;
		i := i + 1;

		FOR i IN 1..l_context_tab.COUNT LOOP
                      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': l_context_tab(' || i || ').context_type = ' || l_context_tab(i).context_type);
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': l_context_tab(' || i || ').context_id = ' || l_context_tab(i).context_id);
                      END IF;
		END LOOP;

		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		  iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Calling IEX_NOTES_PVT.Create_Note...');
                END IF;

		IEX_NOTES_PVT.Create_Note(
			P_API_VERSION => 1.0,
			P_INIT_MSG_LIST => 'F',
			P_COMMIT => 'F',
			P_VALIDATION_LEVEL => 100,
			X_RETURN_STATUS => l_return_status,
			X_MSG_COUNT => l_msg_count,
			X_MSG_DATA => l_msg_data,
			p_source_object_id => P_PROMISE_REC.PROMISE_ID, -- Fixed by Ehuhh 02/05/-7 for a bug 5763697 l_note_payer_id,
			p_source_object_code => 'IEX_PROMISE', -- Fixed by Ehuhh 02/05/-7 for a bug 5763697 'PARTY',
			p_note_type => 'IEX_PROMISE',
			p_notes	=> P_PROMISE_REC.NOTE,
			p_contexts_tbl => l_context_tab,
			x_note_id => l_note_id);

		X_PRORESP_REC.NOTE_ID := l_note_id;

		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': After call to IEX_NOTES_PVT.Create_Note');
		      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Status = ' || L_RETURN_STATUS);
                END IF;

		-- check for errors
		IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			     iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': IEX_NOTES_PVT.Create_Note failed');
                        END IF;
			RAISE FND_API.G_EXC_ERROR;
		END IF;
	else
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		  iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': no note to save');
                END IF;
	end if;

/*	SEND_FFM and SET_STRATEGY should be processed on the client

	-- sending ffm
	--SEND_FFM(P_PROMISE_ID => P_PROMISE_REC.PROMISE_ID, P_PARTY_ID => l_note_payer_id);

	-- setting strategy
	--SET_STRATEGY(P_PROMISE_ID => P_PROMISE_REC.PROMISE_ID, P_STATUS => 'ONHOLD');
*/
    	-- commit if promise updated successfully
    	IF FND_API.To_Boolean( p_commit ) THEN
        	COMMIT WORK;
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		          iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': commited');
            END IF;
   	END IF;

    	-- END OF BODY OF API

	x_return_status := l_return_status;
    	-- Standard call to get message count and if count is 1, get message info
   	FND_MSG_PUB.Count_And_Get(
                   p_encoded => FND_API.G_FALSE,
                   p_count => x_msg_count,
                   p_data => x_msg_data);

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': end of API');
END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO UPDATE_PROMISE_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDATE_PROMISE_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO UPDATE_PROMISE_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END;


PROCEDURE VALIDATE_CANCEL_INPUT(P_PROMISE_REC IN IEX_PROMISES_PUB.PRO_CNCL_REC_TYPE)
IS
	l_validation_item		varchar2(100);
	l_procedure			varchar2(50); --  := 'VALIDATE_CANCEL_INPUT';

begin
	l_procedure := 'VALIDATE_CANCEL_INPUT';
	/* validate promise id */
	l_validation_item := 'P_PROMISE_REC.PROMISE_ID';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': Validating ' || l_validation_item);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': ' || l_validation_item || ' = ' || P_PROMISE_REC.PROMISE_ID);
END IF;
	if P_PROMISE_REC.PROMISE_ID is null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': ' || l_validation_item || ' failed validation');
END IF;
		FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
		FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_procedure);
		FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

	/* validate resource_id */
	l_validation_item := 'P_PROMISE_REC.TAKEN_BY_RESOURCE_ID';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': Validating ' || l_validation_item);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': ' || l_validation_item || ' = ' || P_PROMISE_REC.TAKEN_BY_RESOURCE_ID);
END IF;
	if P_PROMISE_REC.TAKEN_BY_RESOURCE_ID is null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': ' || l_validation_item || ' failed validation: resource id must be set');
END IF;
		FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
		FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_procedure);
		FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

end;

PROCEDURE CANCEL_PROMISE(
    	P_API_VERSION			IN      NUMBER,
    	P_INIT_MSG_LIST			IN      VARCHAR2, -- DEFAULT FND_API.G_FALSE,
    	P_COMMIT                    	IN      VARCHAR2, -- DEFAULT FND_API.G_FALSE,
    	P_VALIDATION_LEVEL	    	IN      NUMBER, -- DEFAULT FND_API.G_VALID_LEVEL_FULL,
    	X_RETURN_STATUS			OUT NOCOPY     VARCHAR2,
    	X_MSG_COUNT                 	OUT NOCOPY     NUMBER,
    	X_MSG_DATA	    	    	OUT NOCOPY     VARCHAR2,
    	P_PROMISE_REC               	IN	IEX_PROMISES_PUB.PRO_CNCL_REC_TYPE,
    	X_PRORESP_REC			OUT NOCOPY	IEX_PROMISES_PUB.PRO_RESP_REC_TYPE)
IS
    	l_api_name			CONSTANT VARCHAR2(30) := 'CANCEL_PROMISE';
    	l_api_version               	CONSTANT NUMBER := 1.0;
    	l_return_status             	VARCHAR2(1);
    	l_msg_count                 	NUMBER;
    	l_msg_data                  	VARCHAR2(32767);

    	i                           	NUMBER;
    	l_promise_id                	NUMBER;
	l_promise_status		varchar2(30); --  := 'CANCELLED';
	l_note_payer_id			NUMBER;
	l_payer_num_id			NUMBER;
	l_payer_id			VARCHAR2(80);
	l_payer_name			HZ_PARTIES.PARTY_NAME%TYPE;  --Changed the datatype for bug#5652085 by ehuh 2/28/07
	l_note_payer_type		VARCHAR2(100);
	l_context_tab			IEX_NOTES_PVT.CONTEXTS_TBL_TYPE;
	l_note_id			NUMBER;
	l_cust_id			number;
	l_SQL				VARCHAR2(1000);
    	Type refCur is Ref Cursor;
    	l_cursor			refCur;


BEGIN
	l_promise_status := 'CANCELLED';

    	-- Standard start of API savepoint
    	SAVEPOINT CANCEL_PROMISE_PVT;

    	-- Standard call to check for call compatibility
    	IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    	END IF;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.To_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;

    	-- Initialize API return status to success
    	l_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- START OF BODY OF API
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Start of body');
END IF;

	/* validate input */
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Validating input...');
END IF;
	VALIDATE_CANCEL_INPUT(P_PROMISE_REC);

	/* validate promiser info */
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Validating parties...');
END IF;
	IEX_PAYMENTS_PUB.GET_PAYER_INFO(
		P_PAYER_PARTY_REL_ID => P_PROMISE_REC.PROMISED_BY_PARTY_REL_ID,
		P_PAYER_PARTY_ORG_ID => P_PROMISE_REC.PROMISED_BY_PARTY_ORG_ID,
		P_PAYER_PARTY_PER_ID => P_PROMISE_REC.PROMISED_BY_PARTY_PER_ID,
		X_NOTE_PAYER_TYPE => l_note_payer_type,
		X_NOTE_PAYER_NUM_ID => l_note_payer_id,
		X_PAYER_NUM_ID => l_payer_num_id,
		X_PAYER_ID => l_payer_id,
		X_PAYER_NAME => l_payer_name);

	/* do update */
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Doing update...');
END IF;

	UPDATE iex_promise_details
	SET STATUS = l_promise_status,
	RESOURCE_ID = P_PROMISE_REC.TAKEN_BY_RESOURCE_ID,
	PROMISE_MADE_BY = P_PROMISE_REC.PROMISED_BY_PARTY_PER_ID,
	PROGRAM_ID = G_APP_ID,
	last_update_date = sysdate,
	last_updated_by = G_USER_ID,
	LAST_UPDATE_LOGIN = G_LOGIN_ID
	where promise_detail_id = P_PROMISE_REC.PROMISE_ID;

	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Update OK');
	END IF;
   	X_PRORESP_REC.PROMISE_ID := P_PROMISE_REC.PROMISE_ID;
    	X_PRORESP_REC.STATUS := l_promise_status;

	/* getting promise state */
	l_SQL := 'SELECT state FROM IEX_PROMISE_DETAILS WHERE PROMISE_DETAIL_ID = :P_PROMISE_ID';

	open l_cursor for l_SQL
	using P_PROMISE_REC.PROMISE_ID;
	fetch l_cursor into X_PRORESP_REC.STATE;

	--start
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Calling update_del_stage_level');
	END IF;
	update_del_stage_level (
		p_promise_id		=> P_PROMISE_REC.PROMISE_ID,
		X_RETURN_STATUS		=> l_return_status,
		X_MSG_COUNT             => l_msg_count,
		X_MSG_DATA	    	=> l_msg_data);

	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': After call to update_del_stage_level');
	      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Status = ' || L_RETURN_STATUS);
	END IF;

	-- check for errors
	IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		     iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': update_del_stage_level failed');
		END IF;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
	--end


	-- inserting a note
	if P_PROMISE_REC.NOTE is not null then

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Going to build context for note...');
END IF;
		i := 1;
		/* assigning source_object and adding parties into note context */
		if l_note_payer_type = 'PARTY_RELATIONSHIP' then
			l_context_tab(i).context_type := 'PARTY';
			l_context_tab(i).context_id := P_PROMISE_REC.PROMISED_BY_PARTY_ORG_ID;
			i := i + 1;
			l_context_tab(i).context_type := 'PARTY';
			l_context_tab(i).context_id := P_PROMISE_REC.PROMISED_BY_PARTY_PER_ID;
			i := i + 1;
		end if;

		/* adding account into note context */
		l_SQL := 'SELECT CUST_ACCOUNT_ID ' ||
				'FROM IEX_PROMISE_DETAILS ' ||
				'WHERE ' ||
				'PROMISE_DETAIL_ID = :P_PROMISE_ID';

		open l_cursor for l_SQL
		using P_PROMISE_REC.PROMISE_ID;
		fetch l_cursor into l_cust_id;

		l_context_tab(i).context_type := 'IEX_ACCOUNT';
		l_context_tab(i).context_id := l_cust_id;
		i := i + 1;

		l_context_tab(i).context_type := 'IEX_PROMISE';
		l_context_tab(i).context_id := P_PROMISE_REC.PROMISE_ID;
		i := i + 1;

		FOR i IN 1..l_context_tab.COUNT LOOP
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': l_context_tab(' || i || ').context_type = ' || l_context_tab(i).context_type);
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': l_context_tab(' || i || ').context_id = ' || l_context_tab(i).context_id);
END IF;
		END LOOP;

		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Calling IEX_NOTES_PVT.Create_Note...');
                END IF;

		IEX_NOTES_PVT.Create_Note(
			P_API_VERSION => 1.0,
			P_INIT_MSG_LIST => 'F',
			P_COMMIT => 'F',
			P_VALIDATION_LEVEL => 100,
			X_RETURN_STATUS => l_return_status,
			X_MSG_COUNT => l_msg_count,
			X_MSG_DATA => l_msg_data,
			p_source_object_id =>  P_PROMISE_REC.PROMISE_ID, -- Fixed by Ehuhh 02/05/-7 for a bug 5763697 l_note_payer_id,
			p_source_object_code => 'IEX_PROMISE', -- Fixed by Ehuhh 02/05/-7 for a bug 5763697 'PARTY',
			p_note_type => 'IEX_PROMISE',
			p_notes	=> P_PROMISE_REC.NOTE,
			p_contexts_tbl => l_context_tab,
			x_note_id => l_note_id);

		X_PRORESP_REC.NOTE_ID := l_note_id;

		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': After call to IEX_NOTES_PVT.Create_Note');
		      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Status = ' || L_RETURN_STATUS);
        END IF;

		-- check for errors
		IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
	       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			 iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': IEX_NOTES_PVT.Create_Note failed');
            END IF;
			RAISE FND_API.G_EXC_ERROR;
		END IF;
	else
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': no note to save');
END IF;
	end if;

    	-- commit if promise updated successfully
    	IF FND_API.To_Boolean( p_commit ) THEN
        	COMMIT WORK;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': commited');
END IF;
   	END IF;

    	-- END OF BODY OF API

	x_return_status := l_return_status;
    	-- Standard call to get message count and if count is 1, get message info
   	FND_MSG_PUB.Count_And_Get(
                   p_encoded => FND_API.G_FALSE,
                   p_count => x_msg_count,
                   p_data => x_msg_data);

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': end of API');
END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CANCEL_PROMISE_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CANCEL_PROMISE_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO CANCEL_PROMISE_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END;


PROCEDURE VALIDATE_MASS_INPUT(
	P_MASS_IDS_TBL		IN	DBMS_SQL.NUMBER_TABLE,
	P_PROMISE_REC      	IN	IEX_PROMISES_PUB.PRO_MASS_REC_TYPE)
IS
    	Type refCur is Ref Cursor;

    	l_cursor			refCur;
	l_SQL				VARCHAR2(10000);
	l_validation_item		varchar2(100);
	l_procedure			varchar2(50); --  := 'VALIDATE_MASS_INPUT';
	l_result_varchar		varchar2(100);
	l_result_num			number;
	i				number;

begin
	l_procedure := 'VALIDATE_MASS_INPUT';
	/* validate delinquency table count */
	l_validation_item := 'P_MASS_IDS_TBL.COUNT';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': Validating ' || l_validation_item);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': ' || l_validation_item || ' = ' || P_MASS_IDS_TBL.COUNT);
END IF;
	if P_MASS_IDS_TBL.COUNT = 0 then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': ' || l_validation_item || ' failed validation: no delinquencies were passed');
END IF;
		FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
		FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_procedure);
		FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

--commenting begin for bug 6717279 by gnramasa 25th Aug 08
	/* validate that all passed delinquencies belong to the same account */
	/*
	l_validation_item := 'P_MASS_IDS_TBL';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': Validating ' || l_validation_item);
END IF;
	*/
	/* building sql for validating ids */
	/*
	l_SQL := 'SELECT count(distinct CUST_ACCOUNT_ID) from iex_delinquencies where delinquency_id in (';
	FOR i IN 1..P_MASS_IDS_TBL.COUNT LOOP
		if i = 1 then
			l_SQL := l_SQL || P_MASS_IDS_TBL(i);
		else
			l_SQL := l_SQL || ',' || P_MASS_IDS_TBL(i);
		end if;
	END LOOP;
	l_SQL := l_SQL || ')';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': sql =  ' || l_SQL);
END IF;

	open l_cursor for l_SQL;
	fetch l_cursor into l_result_num;

	if l_result_num > 1 then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': ' || l_validation_item || ' failed validation: passed delinquencies belong to different accounts');
END IF;
		FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
		FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_procedure);
		FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;
*/
--commenting end for bug 6717279 by gnramasa 25th Aug 08
	/* validate promise_date */
	l_validation_item := 'P_PROMISE_REC.PROMISE_DATE';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': Validating ' || l_validation_item);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': ' || l_validation_item || ' = ' || P_PROMISE_REC.PROMISE_DATE);
END IF;
	if P_PROMISE_REC.PROMISE_DATE is null or trunc(P_PROMISE_REC.PROMISE_DATE) < trunc(sysdate) then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': ' || l_validation_item || ' failed validation: promise_date must be >= current date');
END IF;
		FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
		FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_procedure);
		FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

	/* validate resource_id */
	l_validation_item := 'P_PROMISE_REC.TAKEN_BY_RESOURCE_ID';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': Validating ' || l_validation_item);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': ' || l_validation_item || ' = ' || P_PROMISE_REC.TAKEN_BY_RESOURCE_ID);
END IF;
	if P_PROMISE_REC.TAKEN_BY_RESOURCE_ID is null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': ' || l_validation_item || ' failed validation: resource id must be set');
END IF;
		FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
		FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_procedure);
		FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

	/* validate payment_method */
	l_validation_item := 'P_PROMISE_REC.PROMISE_PAYMENT_METHOD';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': Validating ' || l_validation_item);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': ' || l_validation_item || ' = ''' || rtrim(P_PROMISE_REC.PROMISE_PAYMENT_METHOD) || '''');
END IF;
	if P_PROMISE_REC.PROMISE_PAYMENT_METHOD is not null and rtrim(P_PROMISE_REC.PROMISE_PAYMENT_METHOD) <> '' then
		l_SQL := 'SELECT ''X'' ' ||
				'FROM IEX_LOOKUPS_V ' ||
				'WHERE ' ||
				'LOOKUP_TYPE = ''IEX_PAYMENT_TYPES'' AND LOOKUP_CODE = :P_PAYMENT_METHOD AND ' ||
				'ENABLED_FLAG = ''Y''';

		open l_cursor for l_SQL
		using P_PROMISE_REC.PROMISE_PAYMENT_METHOD;
		fetch l_cursor into l_result_varchar;

		if l_cursor%rowcount = 0 or l_result_varchar is null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': ' || l_validation_item || ' failed validation: wrong payment method');
END IF;
			FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
			FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_procedure);
			FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
			FND_MSG_PUB.Add;
			RAISE FND_API.G_EXC_ERROR;
		end if;
	else
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' ||l_procedure || ': ' || l_validation_item || ' is null - nothing to validate');
END IF;
	end if;

end;


PROCEDURE MASS_PROMISE(
    	P_API_VERSION		IN      NUMBER,
    	P_INIT_MSG_LIST		IN      VARCHAR2, -- DEFAULT FND_API.G_FALSE,
    	P_COMMIT                IN      VARCHAR2, -- DEFAULT FND_API.G_FALSE,
    	P_VALIDATION_LEVEL	IN      NUMBER, --  DEFAULT FND_API.G_VALID_LEVEL_FULL,
    	X_RETURN_STATUS		OUT NOCOPY     VARCHAR2,
    	X_MSG_COUNT             OUT NOCOPY     NUMBER,
    	X_MSG_DATA	    	OUT NOCOPY     VARCHAR2,
    	P_MASS_IDS_TBL		IN	DBMS_SQL.NUMBER_TABLE,
    	P_MASS_PROMISE_REC      IN	IEX_PROMISES_PUB.PRO_MASS_REC_TYPE,
    	X_MASS_PRORESP_TBL	OUT NOCOPY	IEX_PROMISES_PUB.PRO_MASS_RESP_TBL)
IS
    	l_api_name			CONSTANT VARCHAR2(30) := 'MASS_PROMISE';
    	l_api_version               	CONSTANT NUMBER := 1.0;
    	l_return_status             	VARCHAR2(1);
    	l_msg_count                 	NUMBER;
    	l_msg_data                  	VARCHAR2(32767);

    	i                           	NUMBER;
    	k                           	NUMBER;
    	l_promise_id                	NUMBER;
    	l_promise_amount               	NUMBER;
    	l_currency			varchar2(240);
    	l_cust_account_id		number;
    	l_payment_schedule_id		number;
    	l_status			varchar2(30);
    	l_state				varchar2(30);
    	l_remaining_amount		number;
	l_broken_on_date		date;
	l_note_payer_id			NUMBER;
	l_payer_num_id			NUMBER;
	l_payer_id			VARCHAR2(80);
	l_payer_name		        HZ_PARTIES.PARTY_NAME%TYPE;  --Changed the datatype for bug#5652085 by ehuh 2/28/07
	l_note_payer_type		VARCHAR2(100);
	l_context_tab			IEX_NOTES_PVT.CONTEXTS_TBL_TYPE;
	l_note_id			NUMBER;
	l_SQL				VARCHAR2(1000);
    	Type refCur is Ref Cursor;
    	l_cursor			refCur;
    	l_note_type			varchar2(30);
    	l_source_object_id		NUMBER;
    	l_source_object_code		varchar2(20);
    	l_cust_site_use_id		number;
        l_MASS_IDS_TBL			DBMS_SQL.NUMBER_TABLE;
	l_org_id                       	number;   --Added for bug 7237026 17-Nov-2008 barathsr

    	-- generate new promise detail
    	CURSOR prd_genid_crs IS
        	select IEX_PROMISE_DETAILS_S.NEXTVAL from dual;

	--Begin bug 7237026 17-Nov-2008 barathsr
	CURSOR c_org_id (p_del_id number) IS
		select org_id
		from iex_delinquencies_all
		where delinquency_id = p_del_id;
	--End  bug 7237026 17-Nov-2008 barathsr


BEGIN

    	-- Standard start of API savepoint
    	SAVEPOINT MASS_PROMISE_PVT;

    	-- Standard call to check for call compatibility
    	IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    	END IF;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.To_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;

    	-- Initialize API return status to success
    	l_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- START OF BODY OF API
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Start of body');
END IF;

	/* validate input */
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Validating input...');
END IF;
	VALIDATE_MASS_INPUT(P_MASS_IDS_TBL, P_MASS_PROMISE_REC);

	/* validate promiser info */
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Validating parties...');
END IF;
	IEX_PAYMENTS_PUB.GET_PAYER_INFO(
		P_PAYER_PARTY_REL_ID => P_MASS_PROMISE_REC.PROMISED_BY_PARTY_REL_ID,
		P_PAYER_PARTY_ORG_ID => P_MASS_PROMISE_REC.PROMISED_BY_PARTY_ORG_ID,
		P_PAYER_PARTY_PER_ID => P_MASS_PROMISE_REC.PROMISED_BY_PARTY_PER_ID,
		X_NOTE_PAYER_TYPE => l_note_payer_type,
		X_NOTE_PAYER_NUM_ID => l_note_payer_id,
		X_PAYER_NUM_ID => l_payer_num_id,
		X_PAYER_ID => l_payer_id,
		X_PAYER_NAME => l_payer_name);

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Looping thru table of ids...');
END IF;
	k := 0;
	FOR i IN 1..P_MASS_IDS_TBL.COUNT LOOP

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': record = ' || i || '; delinquency = ' || P_MASS_IDS_TBL(i));
END IF;

		-- fixed a perf bug 4930381
                -- l_SQL := 'SELECT CUSTOMER_ID, CUSTOMER_SITE_USE_ID, payment_schedule_id' ||
                --          ' from iex_pay_invoices_v where delinquency_id = :P_DEL_ID';

                l_SQL := 'SELECT psa.CUSTOMER_ID, psa.CUSTOMER_SITE_USE_ID, del.payment_schedule_id ' ||
                         ' FROM iex_delinquencies del, ar_payment_schedules psa ' ||
                         ' WHERE psa.payment_schedule_id = del.payment_schedule_id and psa.status = ''OP'' and ' ||
                         ' psa.AMOUNT_DUE_REMAINING > 0 and del.DELINQUENCY_ID = :P_DEL_ID';

		open l_cursor for l_SQL
		using P_MASS_IDS_TBL(i);
		fetch l_cursor into l_cust_account_id, l_cust_site_use_id, l_payment_schedule_id;
		close l_cursor;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': l_cust_account_id = ' || l_cust_account_id);
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': l_cust_site_use_id = ' || l_cust_site_use_id);
END IF;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Getting promises to be canceled...');
END IF;
		l_SQL := 'SELECT PROMISE_DETAIL_ID, PROMISE_AMOUNT, CURRENCY_CODE, STATUS, STATE, AMOUNT_DUE_REMAINING ' ||
		         'FROM IEX_PROMISE_DETAILS ' ||
		         'WHERE DELINQUENCY_ID = :P_DEL_ID AND STATUS in (''COLLECTABLE'', ''PENDING'') ' ||
			 'UNION ' ||
			 'SELECT PROMISE_DETAIL_ID, PROMISE_AMOUNT, CURRENCY_CODE, STATUS, STATE, AMOUNT_DUE_REMAINING ' ||
		         'FROM IEX_PROMISE_DETAILS ' ||
		         'WHERE CUST_ACCOUNT_ID = :P_CUST_ACCOUNT_ID AND ' ||
		         'DELINQUENCY_ID IS NULL AND CNSLD_INVOICE_ID IS NULL AND CONTRACT_ID IS NULL AND ' ||
		         'TRUNC(promise_date) = TRUNC(:P_PROMISE_DATE) AND ' ||
		         'STATUS in (''COLLECTABLE'', ''PENDING'')';

		open l_cursor for l_SQL
		using P_MASS_IDS_TBL(i), l_cust_account_id, P_MASS_PROMISE_REC.PROMISE_DATE;

		LOOP
			fetch l_cursor into l_promise_id, l_promise_amount, l_currency, l_status, l_state, l_remaining_amount;
			exit when l_cursor%NOTFOUND;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': l_promise_id = ' || l_promise_id);
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': l_promise_amount = ' || l_promise_amount);
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': l_currency = ' || l_currency);
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': l_status = ' || l_status);
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': l_state = ' || l_state);
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': l_remaining_amount = ' || l_remaining_amount);
END IF;

			k := k+1;
			X_MASS_PRORESP_TBL(k).PROMISE_ID := l_promise_id;
			X_MASS_PRORESP_TBL(k).PROMISE_AMOUNT := l_promise_amount;
			X_MASS_PRORESP_TBL(k).CURRENCY_CODE := l_currency;
			X_MASS_PRORESP_TBL(k).CUST_ACCOUNT_ID := l_cust_account_id;
			X_MASS_PRORESP_TBL(k).CUST_SITE_USE_ID := l_cust_site_use_id;
			X_MASS_PRORESP_TBL(k).DELINQUENCY_ID := P_MASS_IDS_TBL(i);
			X_MASS_PRORESP_TBL(k).STATUS := 'CANCELLED';
			X_MASS_PRORESP_TBL(k).STATE := l_state;
			X_MASS_PRORESP_TBL(k).COLLECTABLE_AMOUNT := l_remaining_amount;
                        l_MASS_IDS_TBL(k) := l_payment_schedule_id;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Canceling the promise...');
END IF;
			UPDATE iex_promise_details
			SET STATUS = 'CANCELLED',
			RESOURCE_ID = P_MASS_PROMISE_REC.TAKEN_BY_RESOURCE_ID,
			PROMISE_MADE_BY = P_MASS_PROMISE_REC.PROMISED_BY_PARTY_PER_ID,
			PROGRAM_ID = G_APP_ID,
			last_update_date = sysdate,
			last_updated_by = G_USER_ID,
			LAST_UPDATE_LOGIN = G_LOGIN_ID
			where
			PROMISE_DETAIL_ID = l_promise_id;
			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Done');
			END IF;

			--start
			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Calling update_del_stage_level');
			END IF;
			update_del_stage_level (
				p_promise_id		=> l_promise_id,
				X_RETURN_STATUS		=> l_return_status,
				X_MSG_COUNT             => l_msg_count,
				X_MSG_DATA	    	=> l_msg_data);

			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': After call to update_del_stage_level');
			      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Status = ' || L_RETURN_STATUS);
			END IF;

			-- check for errors
			IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
				IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				     iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': update_del_stage_level failed');
				END IF;
				RAISE FND_API.G_EXC_ERROR;
			END IF;
			--end

		END LOOP;
		close l_cursor;

		-- fixed a perf bug 4930381  l_SQL := 'SELECT CUSTOMER_ID, AMOUNT_DUE_REMAINING, INVOICE_CURRENCY_CODE, CUSTOMER_SITE_USE_ID FROM iex_pay_invoices_v WHERE DELINQUENCY_ID = :P_DEL_ID';
                l_SQL := 'SELECT psa.CUSTOMER_ID, psa.AMOUNT_DUE_REMAINING, psa.INVOICE_CURRENCY_CODE, psa.CUSTOMER_SITE_USE_ID '||
                         '  FROM iex_delinquencies del, ar_payment_schedules psa ' ||
                         '  WHERE psa.payment_schedule_id = del.payment_schedule_id and psa.status = ''OP'' and ' ||
                         '  psa.AMOUNT_DUE_REMAINING > 0 and del.DELINQUENCY_ID = :P_DEL_ID';
		open l_cursor for l_SQL
		using P_MASS_IDS_TBL(i);
		fetch l_cursor into l_cust_account_id, l_remaining_amount, l_currency, l_cust_site_use_id;

    		-- generate new promise id
    		OPEN prd_genid_crs;
		FETCH prd_genid_crs INTO l_promise_id;
		CLOSE prd_genid_crs;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': new promise_id = ' || l_promise_id);
END IF;

		-- get broken on date
		GET_BROKEN_ON_DATE(P_PROMISE_DATE => P_MASS_PROMISE_REC.PROMISE_DATE, X_BROKEN_ON_DATE => l_broken_on_date);
		-- start wf and return promise status
		START_PTP_WF(P_PROMISE_ID => l_promise_id, X_PROMISE_STATUS => l_status);

--Begin bug 7237026 17-Nov-2008 barathsr
open c_org_id (P_MASS_IDS_TBL(i));
fetch c_org_id into l_org_id;
close c_org_id;


IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Inserting new promise...');
END IF;
    		INSERT INTO IEX_PROMISE_DETAILS
		(
			PROMISE_DETAIL_ID,
			OBJECT_VERSION_NUMBER,
			PROGRAM_ID,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			LAST_UPDATE_LOGIN,
			CREATION_DATE,
			CREATED_BY,
			PROMISE_DATE,
			PROMISE_AMOUNT,
			PROMISE_PAYMENT_METHOD,
			STATUS,
			ACCOUNT,
			PROMISE_ITEM_NUMBER,
			CURRENCY_CODE,
			CAMPAIGN_SCHED_ID,
			DELINQUENCY_ID,
			RESOURCE_ID,
			PROMISE_MADE_BY,
			CUST_ACCOUNT_ID,
			ATTRIBUTE_CATEGORY,
			ATTRIBUTE1,
			ATTRIBUTE2,
			ATTRIBUTE3,
			ATTRIBUTE4,
			ATTRIBUTE5,
			ATTRIBUTE6,
			ATTRIBUTE7,
			ATTRIBUTE8,
			ATTRIBUTE9,
			ATTRIBUTE10,
			ATTRIBUTE11,
			ATTRIBUTE12,
			ATTRIBUTE13,
			ATTRIBUTE14,
			ATTRIBUTE15,
			CNSLD_INVOICE_ID,
			CONTRACT_ID,
			BROKEN_ON_DATE,
			AMOUNT_DUE_REMAINING,
			STATE,
			ORG_ID
		)
		VALUES
		(
			l_promise_id,
			1.0,
			G_APP_ID,
			sysdate,
			G_USER_ID,
			G_LOGIN_ID,
			sysdate,
			G_USER_ID,
			P_MASS_PROMISE_REC.PROMISE_DATE,
			l_remaining_amount,
			P_MASS_PROMISE_REC.PROMISE_PAYMENT_METHOD,
			l_status,
			P_MASS_PROMISE_REC.ACCOUNT,
			P_MASS_PROMISE_REC.PROMISE_ITEM_NUMBER,
			l_currency,
			P_MASS_PROMISE_REC.CAMPAIGN_SCHED_ID,
			P_MASS_IDS_TBL(i),
			P_MASS_PROMISE_REC.TAKEN_BY_RESOURCE_ID,
			P_MASS_PROMISE_REC.PROMISED_BY_PARTY_PER_ID,
			l_cust_account_id,
			P_MASS_PROMISE_REC.ATTRIBUTES.ATTRIBUTE_CATEGORY,
			P_MASS_PROMISE_REC.ATTRIBUTES.ATTRIBUTE1,
			P_MASS_PROMISE_REC.ATTRIBUTES.ATTRIBUTE2,
			P_MASS_PROMISE_REC.ATTRIBUTES.ATTRIBUTE3,
			P_MASS_PROMISE_REC.ATTRIBUTES.ATTRIBUTE4,
			P_MASS_PROMISE_REC.ATTRIBUTES.ATTRIBUTE5,
			P_MASS_PROMISE_REC.ATTRIBUTES.ATTRIBUTE6,
			P_MASS_PROMISE_REC.ATTRIBUTES.ATTRIBUTE7,
			P_MASS_PROMISE_REC.ATTRIBUTES.ATTRIBUTE8,
			P_MASS_PROMISE_REC.ATTRIBUTES.ATTRIBUTE9,
			P_MASS_PROMISE_REC.ATTRIBUTES.ATTRIBUTE10,
			P_MASS_PROMISE_REC.ATTRIBUTES.ATTRIBUTE11,
			P_MASS_PROMISE_REC.ATTRIBUTES.ATTRIBUTE12,
			P_MASS_PROMISE_REC.ATTRIBUTES.ATTRIBUTE13,
			P_MASS_PROMISE_REC.ATTRIBUTES.ATTRIBUTE14,
			P_MASS_PROMISE_REC.ATTRIBUTES.ATTRIBUTE15,
			null,
			null,
			l_broken_on_date,
			l_remaining_amount,
			'PROMISE',
			l_org_id
		);

	--End bug 7237026 17-Nov-2008 barathsr


		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Insert OK');
		END IF;

		--start
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Calling update_del_stage_level');
		END IF;
		update_del_stage_level (
			p_promise_id		=> l_promise_id,
			X_RETURN_STATUS		=> l_return_status,
			X_MSG_COUNT             => l_msg_count,
			X_MSG_DATA	    	=> l_msg_data);

		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': After call to update_del_stage_level');
		      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Status = ' || L_RETURN_STATUS);
		END IF;

		-- check for errors
		IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			     iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': update_del_stage_level failed');
			END IF;
			RAISE FND_API.G_EXC_ERROR;
		END IF;
		--end

		k := k+1;
		X_MASS_PRORESP_TBL(k).PROMISE_ID := l_promise_id;
		X_MASS_PRORESP_TBL(k).PROMISE_AMOUNT := l_remaining_amount;
		X_MASS_PRORESP_TBL(k).CURRENCY_CODE := l_currency;
		X_MASS_PRORESP_TBL(k).CUST_ACCOUNT_ID := l_cust_account_id;
		X_MASS_PRORESP_TBL(k).CUST_SITE_USE_ID := l_cust_site_use_id;
		X_MASS_PRORESP_TBL(k).DELINQUENCY_ID := P_MASS_IDS_TBL(i);
		X_MASS_PRORESP_TBL(k).STATUS := l_status;
		X_MASS_PRORESP_TBL(k).STATE := 'PROMISE';
		X_MASS_PRORESP_TBL(k).COLLECTABLE_AMOUNT := l_remaining_amount;
                l_MASS_IDS_TBL(k) := l_payment_schedule_id;
	END LOOP;

	l_note_type := fnd_profile.value('AST_NOTES_DEFAULT_TYPE');
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(l_api_name || ':  l_note_type = ' ||  l_note_type);
END IF;

	-- inserting a note
	if P_MASS_PROMISE_REC.NOTE is not null and l_note_type is not null then

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Going to build context for note...');
END IF;
		i := 1;
		/* adding parties into note context */
		if l_note_payer_type = 'PARTY_RELATIONSHIP' then
			l_context_tab(i).context_type := 'PARTY';
			l_context_tab(i).context_id := P_MASS_PROMISE_REC.PROMISED_BY_PARTY_REL_ID;
			i := i + 1;
			l_context_tab(i).context_type := 'PARTY';
			l_context_tab(i).context_id := P_MASS_PROMISE_REC.PROMISED_BY_PARTY_ORG_ID;
			i := i + 1;
			l_context_tab(i).context_type := 'PARTY';
			l_context_tab(i).context_id := P_MASS_PROMISE_REC.PROMISED_BY_PARTY_PER_ID;
			i := i + 1;
		elsif l_note_payer_type = 'PARTY_ORGANIZATION' then
			l_context_tab(i).context_type := 'PARTY';
			l_context_tab(i).context_id := P_MASS_PROMISE_REC.PROMISED_BY_PARTY_ORG_ID;
			i := i + 1;
		elsif l_note_payer_type = 'PARTY_PERSON' then
			l_context_tab(i).context_type := 'PARTY';
			l_context_tab(i).context_id := P_MASS_PROMISE_REC.PROMISED_BY_PARTY_PER_ID;
			i := i + 1;
		end if;

		FOR k IN 1..X_MASS_PRORESP_TBL.count LOOP
			/* adding account to note context */
			l_context_tab(i).context_type := 'IEX_ACCOUNT';
			l_context_tab(i).context_id := X_MASS_PRORESP_TBL(k).CUST_ACCOUNT_ID;
			i := i + 1;

			/* adding transaction number to note context */
			l_context_tab(i).context_type := 'IEX_INVOICES';
			l_context_tab(i).context_id := l_MASS_IDS_TBL(k);
			i := i + 1;

			/* adding bill-to to note context */
			l_context_tab(i).context_type := 'IEX_BILLTO';
			l_context_tab(i).context_id := X_MASS_PRORESP_TBL(k).CUST_SITE_USE_ID;
			i := i + 1;

			/* adding first promise as note source and all others as note context */
			if k = 1 then
	    			l_source_object_code := 'IEX_PROMISE';
	    			l_source_object_id := X_MASS_PRORESP_TBL(k).PROMISE_ID;
			else
				l_context_tab(i).context_type := 'IEX_PROMISE';
				l_context_tab(i).context_id := X_MASS_PRORESP_TBL(k).PROMISE_ID;
				i := i + 1;
			end if;

			/* adding delinquency to note context */
			l_context_tab(i).context_type := 'IEX_DELINQUENCY';
			l_context_tab(i).context_id := X_MASS_PRORESP_TBL(k).DELINQUENCY_ID;
			i := i + 1;

		END LOOP;

		-- for debug purpose only
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': l_source_object_code = ' || l_source_object_code);
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': l_source_object_id = ' || l_source_object_id);
END IF;
		FOR i IN 1..l_context_tab.COUNT LOOP
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': l_context_tab(' || i || ').context_type = ' || l_context_tab(i).context_type);
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': l_context_tab(' || i || ').context_id = ' || l_context_tab(i).context_id);
END IF;
		END LOOP;

		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Calling IEX_NOTES_PVT.Create_Note...');
        END IF;
		IEX_NOTES_PVT.Create_Note(
			P_API_VERSION => 1.0,
			P_INIT_MSG_LIST => 'F',
			P_COMMIT => 'F',
			P_VALIDATION_LEVEL => 100,
			X_RETURN_STATUS => l_return_status,
			X_MSG_COUNT => l_msg_count,
			X_MSG_DATA => l_msg_data,
			p_source_object_id => l_source_object_id,
			p_source_object_code => l_source_object_code,
			p_note_type => l_note_type,
			p_notes	=> P_MASS_PROMISE_REC.NOTE,
			p_contexts_tbl => l_context_tab,
			x_note_id => l_note_id);

		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		  iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': After call to IEX_NOTES_PVT.Create_Note');
		  iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Status = ' || L_RETURN_STATUS);
        END IF;

		-- check for errors
		IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			     iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': IEX_NOTES_PVT.Create_Note failed');
            END IF;
			RAISE FND_API.G_EXC_ERROR;
		END IF;

		FOR k IN 1..X_MASS_PRORESP_TBL.count LOOP
			X_MASS_PRORESP_TBL(k).note_id := l_note_id;
		END LOOP;
	else
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		  iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': no note to save');
        END IF;
	end if;

    	-- commit if promise updated successfully
    	IF FND_API.To_Boolean( p_commit ) THEN
        	COMMIT WORK;
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': commited');
            END IF;
   	END IF;

    	-- END OF BODY OF API

	x_return_status := l_return_status;
    	-- Standard call to get message count and if count is 1, get message info
   	FND_MSG_PUB.Count_And_Get(
                   p_encoded => FND_API.G_FALSE,
                   p_count => x_msg_count,
                   p_data => x_msg_data);

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': end of API');
END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO MASS_PROMISE_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO MASS_PROMISE_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO MASS_PROMISE_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END;

Procedure update_del_stage_level (
		p_promise_id		IN	       NUMBER,
		X_RETURN_STATUS		OUT NOCOPY     VARCHAR2,
		X_MSG_COUNT             OUT NOCOPY     NUMBER,
		X_MSG_DATA	    	OUT NOCOPY     VARCHAR2)
is
	l_api_name			CONSTANT VARCHAR2(30) := 'update_del_stage_level';
   	l_api_version               	CONSTANT NUMBER := 1.0;
	l_return_status			varchar2(10);
	l_msg_count			number;
	l_msg_data			varchar2(200);
	l_total_already_pro_amt		number;
	l_amt_due_remaining		number;
	l_promised_delinquency_id	number;
	l_stage_number			number;
begin
	-- Standard start of API savepoint
    	SAVEPOINT UPDATE_DEL_STAGE_PVT;
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': start');
	END IF;
	-- Initialize API return status to success
    	l_return_status := FND_API.G_RET_STS_SUCCESS;
--start
	Begin
	   select delinquency_id into l_promised_delinquency_id
	   from iex_promise_details
	   where promise_detail_id = p_promise_id;

	   SELECT  sum(promise_amount) into l_total_already_pro_amt
	   from iex_promise_details where delinquency_id = l_promised_delinquency_id
	   and status = 'COLLECTABLE'
	   and state = 'PROMISE';
	Exception
	    WHEN NO_DATA_FOUND then
		l_total_already_pro_amt := 0;
	End ;
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || 'l_total_already_pro_amt: ' || l_total_already_pro_amt);
	END IF;
	Begin
	    SELECT  amount_due_remaining into l_amt_due_remaining
	   from ar_payment_schedules pay,
		iex_delinquencies del
	   where
	   del.payment_schedule_id = pay.payment_schedule_id
	   and del.delinquency_id = l_promised_delinquency_id;
	Exception
	    WHEN NO_DATA_FOUND then
		l_amt_due_remaining := 0;
	End ;
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || 'l_amt_due_remaining: ' || l_amt_due_remaining);
	end if;
	if l_amt_due_remaining <= l_total_already_pro_amt then
		update iex_delinquencies_all
		set staged_dunning_level = 0
		where delinquency_id = l_promised_delinquency_id;

		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || 'Updated the staged dunning level to 0 for delinquency id: ' || l_promised_delinquency_id);
		end if;
	else
		iex_utilities.MaxStageForanDelinquency (p_delinquency_id  => l_promised_delinquency_id
							, p_stage_number  => l_stage_number);
		update iex_delinquencies_all
		set staged_dunning_level = l_stage_number
		where delinquency_id = l_promised_delinquency_id;
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || 'Updated the staged dunning level to ' || l_stage_number || ' for delinquency id: ' || l_promised_delinquency_id);
		end if;
	end if;
	--end

	x_return_status := l_return_status;
	-- Standard call to get message count and if count is 1, get message info
    	FND_MSG_PUB.Count_And_Get(
                   p_encoded => FND_API.G_FALSE,
                   p_count => x_msg_count,
                   p_data => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO UPDATE_DEL_STAGE_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDATE_DEL_STAGE_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO UPDATE_DEL_STAGE_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
end update_del_stage_level;

begin
   PG_DEBUG  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   G_LOGIN_ID  := FND_GLOBAL.Conc_Login_Id;
   G_PROGRAM_ID := FND_GLOBAL.Conc_Program_Id;
   G_USER_ID  := FND_GLOBAL.User_Id;
   G_REQUEST_ID := FND_GLOBAL.Conc_Request_Id;


END;

/
