--------------------------------------------------------
--  DDL for Package Body IEX_PROMISES_BATCH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_PROMISES_BATCH_PUB" as
/* $Header: iexpyrbb.pls 120.13.12010000.8 2010/02/05 14:49:40 gnramasa ship $ */

PG_DEBUG NUMBER; -- := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

G_APP_ID   CONSTANT NUMBER := 695;
G_PKG_NAME CONSTANT VARCHAR2(30):= 'IEX_PROMISES_BATCH_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'iexpyrbb.pls';
G_LOGIN_ID NUMBER; -- := FND_GLOBAL.Conc_Login_Id;
G_PROGRAM_ID NUMBER; -- := FND_GLOBAL.Conc_Program_Id;
G_USER_ID NUMBER; -- := FND_GLOBAL.User_Id;
G_REQUEST_ID NUMBER; -- := FND_GLOBAL.Conc_Request_Id;

G_TASK_REFERENCE_TAB    JTF_TASKS_PUB.TASK_REFER_TBL;


/**********************
	This procedure logging messages
***********************/
Procedure LogMessage(p_msg in varchar2)
IS
BEGIN
/*
    if G_REQUEST_ID <> -1 then
        fnd_file.put_line(FND_FILE.LOG, p_msg);
    end if;
    */
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.LogMessage(p_msg);
    END IF;
END;

/**********************
	This procedure calculate callback date
***********************/
Procedure Get_Callback_Date(p_promise_date in date, x_callback_date OUT NOCOPY DATE)
IS
    l_result        	NUMBER;
    l_result1       	DATE;
    l_callback_days  	NUMBER;
    vSQL 		varchar2(500);
BEGIN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    LogMessage(G_PKG_NAME || '.Get_Calback_Date: start');
END IF;

    l_callback_days := to_number(nvl(fnd_profile.value('IEX_PTP_CALLBACK_DAYS'), '0'));
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    LogMessage(G_PKG_NAME || '.Get_Calback_Date: callback days from profile = ' || l_callback_days);
END IF;
    if l_callback_days < 0 then
   	    l_callback_days := 0;
    end if;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    LogMessage(G_PKG_NAME || '.Get_Calback_Date: before cursor execute');
END IF;
    vSQL := 'SELECT TO_NUMBER(TO_CHAR(:b + :a, ''D'')) FROM DUAL';

    Execute Immediate
        vSQL
        INTO l_result
        using p_promise_date, l_callback_days;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    LogMessage(G_PKG_NAME || '.Get_Calback_Date: after cursor execute');
END IF;

    -- If Weekend => Monday
    -- 6 => Firday
    -- 1 => Sunday

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    LogMessage(G_PKG_NAME || '.Get_Calback_Date: l_result = ' || l_result);
END IF;
    if (l_result = 7) then
        l_callback_days := l_callback_days + 2;
    elsif (l_result = 1) then
        l_callback_days := l_callback_days + 1;
    end if;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    LogMessage(G_PKG_NAME || '.Get_Calback_Date: l_callback_days = ' || l_callback_days);
END IF;

    vSQL := 'SELECT :b + :a FROM DUAL';
    Execute Immediate
        vSQL
    into l_result1 using p_promise_date, l_callback_days;

    x_callback_date := l_result1;

    if trunc(sysdate) > trunc(x_callback_date) then
  	    x_callback_date := sysdate;
    end if;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    LogMessage(G_PKG_NAME || '.Get_CALLback_Date: x_callback_date = ' || x_callback_date);
END IF;

EXCEPTION
    WHEN OTHERS THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        LogMessage(G_PKG_NAME || '.Get_CALLback_Date: in other execption');
END IF;
        x_callback_date := sysdate;
        -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
        /*
        IEX_CONC_REQUEST_MSG_PKG.Log_Error(
                   P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
                   P_Procedure_name        => 'IEX_PROMISES_BATCH_PUB.GET_CALLBACK_DATE',
                   P_MESSAGE               => 'Cannot Get Callback_Date. Assing sysdate.' );
        */
        -- End - Andre Araujo - 09/30/2004- Remove obsolete logging

END;

/**********************
	This procedure closes all open promises for payment schedules that have been closed.
***********************/
PROCEDURE CLOSE_PROMISES(
    P_API_VERSION		    	IN      NUMBER,
    P_INIT_MSG_LIST		    	IN      VARCHAR2,
    P_COMMIT				IN      VARCHAR2,
    P_VALIDATION_LEVEL	    		IN      NUMBER,
    X_RETURN_STATUS		    	OUT NOCOPY     VARCHAR2,
    X_MSG_COUNT				OUT NOCOPY     NUMBER,
    X_MSG_DATA	    	    		OUT NOCOPY     VARCHAR2,
    p_payments_tbl			IN	IEX_PAYMENTS_BATCH_PUB.CL_INV_TBL_TYPE)
IS
    l_api_name                       	CONSTANT VARCHAR2(30) := 'CLOSE_PROMISES';
    l_api_version                    	CONSTANT NUMBER := 1.0;
    l_return_status                  	VARCHAR2(1);
    l_msg_count                      	NUMBER;
    l_msg_data                       	VARCHAR2(32767);

    i					number := 0;
    k					number := 0;
    l_cr_id				number;
    l_promise_detail_id			number;

    CURSOR get_cl_pro_crs(P_PAYMENT_SCHEDULE_ID NUMBER)
    IS
	SELECT
	PRD.PROMISE_DETAIL_ID
	FROM
	IEX_PROMISE_DETAILS PRD,
	IEX_DELINQUENCIES_ALL DEL
	WHERE
	DEL.DELINQUENCY_ID = PRD.DELINQUENCY_ID AND
	DEL.CUST_ACCOUNT_ID = PRD.CUST_ACCOUNT_ID AND
	DEL.PAYMENT_SCHEDULE_ID = P_PAYMENT_SCHEDULE_ID AND
	PRD.STATUS = 'OPEN'
	ORDER BY PRD.PROMISE_DETAIL_ID;

BEGIN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	iex_debug_pub.LogMessage(G_PKG_NAME || '.CLOSE_PROMISES: this procedure has been obsoleted - no actions have beed done.');
END IF;
	X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

/*
	Commented out whole procedure because PROB now can apply payments to promises or
	reverse payments from promises automatically.
	We do not need to close or reopen promises if delinquency is closed or reopened - all this will be done by PROB.
	We are obsoleting status CLOSED.


IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    LogMessage('*************************');
    LogMessage(G_PKG_NAME || '.' || l_api_name || ':Start');
END IF;

    -- Standard start of API savepoint
    SAVEPOINT CLOSE_PROMISES_PVT;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    LogMessage(G_PKG_NAME || '.' || l_api_name || ':Savepoint is established');
END IF;
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
    LogMessage(G_PKG_NAME || '.' || l_api_name || ':Start of body');
END IF;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    LogMessage(G_PKG_NAME || '.' || l_api_name || ':Processing closed invoices');
END IF;
    -- run thru table of payments and close promises
    FOR i IN 1..p_payments_tbl.COUNT LOOP
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	LogMessage(G_PKG_NAME || '.' || l_api_name || ':record #' || i);
	LogMessage(G_PKG_NAME || '.' || l_api_name || ':payment_schedule_id = ' || p_payments_tbl(i));
END IF;

	-- get open promises for the invoice
	OPEN get_cl_pro_crs(P_PAYMENT_SCHEDULE_ID => p_payments_tbl(i));
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	LogMessage(G_PKG_NAME || '.' || l_api_name || ':get_cl_pro_crs cursor is opened');
END IF;

	LOOP
		FETCH get_cl_pro_crs INTO l_promise_detail_id;
		EXIT WHEN get_cl_pro_crs%NOTFOUND;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		LogMessage(G_PKG_NAME || '.' || l_api_name || ':Promise found!');
		LogMessage(G_PKG_NAME || '.' || l_api_name || ':l_promise_detail_id = ' || l_promise_detail_id);
END IF;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		LogMessage(G_PKG_NAME || '.' || l_api_name || ':going to update promise ' || l_promise_detail_id || ' with status CLOSED');
END IF;
		UPDATE iex_promise_details
		SET STATUS = 'CLOSED',
		last_update_date = sysdate,
		last_updated_by = G_USER_ID
		WHERE promise_detail_id = l_promise_detail_id;

		if (sql%notfound) then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			LogMessage(G_PKG_NAME || '.' || l_api_name || ':update failed');
END IF;
			-- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
			/*
    			--IEX_CONC_REQUEST_MSG_PKG.Log_Error(
        		--	P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
                   	--	P_Procedure_name        => G_PKG_NAME || '.' || l_api_name,
                  	--	P_MESSAGE               => 'Failed to update iex_promise_details with STATUS = CLOSED for promise_detail_id = ' || l_promise_detail_id);

                        -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
		else
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			LogMessage(G_PKG_NAME || '.' || l_api_name || ':update successfull');
END IF;
		end if;
	END LOOP;
	CLOSE get_cl_pro_crs;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	LogMessage(G_PKG_NAME || '.' || l_api_name || ':get_cl_pro_crs cursor is closed');
END IF;
    END LOOP;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    LogMessage(G_PKG_NAME || '.' || l_api_name || ':End of body');
END IF;
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
      ROLLBACK TO CLOSE_PROMISES_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
      -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
      --IEX_CONC_REQUEST_MSG_PKG.Log_Error(
      --      P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
      --      P_Procedure_name        => G_PKG_NAME || '.' || l_api_name,
      --      P_MESSAGE               => 'Failed to close promises.' );
       -- End - Andre Araujo - 09/30/2004- Remove obsolete logging

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      LogMessage(G_PKG_NAME || '.' || l_api_name || ': In G_EXC_ERROR exception. Failed to close promises');
END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CLOSE_PROMISES_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
      -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
      --IEX_CONC_REQUEST_MSG_PKG.Log_Error(
      --      P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
      --      P_Procedure_name        => G_PKG_NAME || '.' || l_api_name,
      --      P_MESSAGE               => 'Failed to close promises.' );
      -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      LogMessage(G_PKG_NAME || '.' || l_api_name || ': In G_EXC_UNEXPECTED_ERROR exception. Failed to close promises');
END IF;
    WHEN OTHERS THEN
      ROLLBACK TO CLOSE_PROMISES_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
      -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
      --IEX_CONC_REQUEST_MSG_PKG.Log_Error(
      --      P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
      --      P_Procedure_name        => G_PKG_NAME || '.' || l_api_name,
      --      P_MESSAGE               => 'Failed to close promises.' );
      -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      LogMessage(G_PKG_NAME || '.' || l_api_name || ': In OTHERS exception. Failed to close promises');
END IF;
*/

END;

/**********************
	This procedure closes all promises for delinquencies passed.
***********************/
PROCEDURE CLOSE_PROMISES(
    	P_API_VERSION		    	IN      NUMBER,
    	P_INIT_MSG_LIST		    	IN      VARCHAR2,
    	P_COMMIT			IN      VARCHAR2,
    	P_VALIDATION_LEVEL	    	IN      NUMBER,
    	X_RETURN_STATUS		    	OUT NOCOPY     VARCHAR2,
    	X_MSG_COUNT			OUT NOCOPY     NUMBER,
    	X_MSG_DATA	    	    	OUT NOCOPY     VARCHAR2,
    	P_DELINQ_TBL			IN	IEX_UTILITIES.t_del_id)
IS
    	l_api_name			CONSTANT VARCHAR2(30) := 'CLOSE_PROMISES';
    	l_api_version           	CONSTANT NUMBER := 1.0;
    	l_return_status         	VARCHAR2(1);
    	l_msg_count             	NUMBER;
    	l_msg_data              	VARCHAR2(32767);

	vSQL				varchar2(1000);
	i				number := 0;
	j				number := 0;
	k				number := 0;
	l_del_count			number := 0;
	l_promise_id			number;
	l_status			varchar2(100);
	l_type				varchar2(100);
	l_cl_prd_count			number := 0;

    	Type refCur is Ref Cursor;
   	del_cur				refCur;

    	type ids_table is table of number index by binary_integer;
    	L_PROMISE_IDS_TBL     		ids_table;
    	L_BROKEN_PROMISE_IDS_TBL     		ids_table;

BEGIN

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	iex_debug_pub.LogMessage(G_PKG_NAME || '.CLOSE_PROMISES: this procedure has been obsoleted - no actions have beed done.');
END IF;
	X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

/*
	Commented out whole procedure because PROB now can apply payments to promises or
	reverse payments from promises automatically.
	We do not need to close or reopen promises if delinquency is closed or reopened - all this will be done by PROB.
	We are obsoleting status CLOSED.

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	iex_debug_pub.LogMessage(G_PKG_NAME || '.CLOSE_PROMISES: start');
END IF;
    	-- Standard start of API savepoint
    	SAVEPOINT CLOSE_PROMISES_PVT;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	iex_debug_pub.LogMessage(G_PKG_NAME || '.CLOSE_PROMISES: Savepoint is established');
END IF;
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
    	iex_debug_pub.LogMessage(G_PKG_NAME || '.CLOSE_PROMISES: Start of body');
END IF;

    	-- run thru table of payments and close promises
	l_del_count := P_DELINQ_TBL.count;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	iex_debug_pub.LogMessage(G_PKG_NAME || '.CLOSE_PROMISES: count of passed table of delinquencies = ' || l_del_count);
END IF;

	vSQL := 'SELECT ' ||
		'PROMISE_DETAIL_ID, status, ''Invoice'' ' ||
		'FROM ' ||
		'IEX_PROMISE_DETAILS ' ||
		'WHERE ' ||
		'DELINQUENCY_ID = :del and ' ||
		'STATUS in (''OPEN'', ''PENDING'', ''BROKEN'') ' ||
		'union ' ||
		'SELECT ' ||
		'PRD.PROMISE_DETAIL_ID, prd.status, ''Case'' ' ||
		'FROM ' ||
		'IEX_CASE_OBJECTS CAO, ' ||
		'IEX_PROMISE_DETAILS PRD, ' ||
		'IEX_DELINQUENCIES DEL ' ||
		'WHERE ' ||
		'DEL.DELINQUENCY_ID = :del AND ' ||
		'DEL.CASE_ID IS NOT NULL AND ' ||
		'DEL.CASE_ID = CAO.CAS_ID AND ' ||
		'CAO.OBJECT_CODE = ''CONTRACTS'' AND ' ||
		'CAO.OBJECT_ID = PRD.CONTRACT_ID AND ' ||
		'PRD.DELINQUENCY_ID IS NULL AND ' ||
		'PRD.CNSLD_INVOICE_ID IS NULL and ' ||
		'PRD.STATUS IN (''OPEN'', ''PENDING'', ''BROKEN'') ' ||
		'ORDER BY PROMISE_DETAIL_ID';

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	iex_debug_pub.LogMessage(G_PKG_NAME || '.CLOSE_PROMISES: processing promises...');
END IF;
	FOR i in 1..l_del_count LOOP
		open del_cur for vSQL
		using p_delinq_tbl(i), p_delinq_tbl(i);
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.CLOSE_PROMISES: record #' || i);
		iex_debug_pub.LogMessage(G_PKG_NAME || '.CLOSE_PROMISES: delinquency: ' || p_delinq_tbl(i));
END IF;

		LOOP
			fetch del_cur into l_promise_id, l_status, l_type;
			exit when del_cur%NOTFOUND;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(G_PKG_NAME || '.CLOSE_PROMISES: found promise with id: ' || l_promise_id);
			iex_debug_pub.LogMessage(G_PKG_NAME || '.CLOSE_PROMISES: promise status: ' || l_status);
			iex_debug_pub.LogMessage(G_PKG_NAME || '.CLOSE_PROMISES: promise type: ' || l_type);
END IF;

			if l_status = 'BROKEN' then
				k := k + 1;
				l_broken_promise_ids_tbl(k) := l_promise_id;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				iex_debug_pub.LogMessage(G_PKG_NAME || '.CLOSE_PROMISES: added to broken promise table');
END IF;
			else
				j := j + 1;
				l_promise_ids_tbl(j) := l_promise_id;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				iex_debug_pub.LogMessage(G_PKG_NAME || '.CLOSE_PROMISES: added to open/pending promise table');
END IF;
			end if;
		END LOOP;
	END LOOP;

	l_cl_prd_count := l_promise_ids_tbl.count;
	if l_cl_prd_count > 0 then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    		iex_debug_pub.LogMessage(G_PKG_NAME || '.CLOSE_PROMISES: updating open/pending promises...');
END IF;
    		FORALL n in 1..l_cl_prd_count
            		UPDATE iex_promise_details
            		SET STATUS = 'CLOSED',
            		last_update_date = sysdate,
            		last_updated_by = G_USER_ID
            		WHERE promise_detail_id = l_promise_ids_tbl(n);
	end if;

	l_cl_prd_count := l_broken_promise_ids_tbl.count;
	if l_cl_prd_count > 0 then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    		iex_debug_pub.LogMessage(G_PKG_NAME || '.CLOSE_PROMISES: updating broken promises...');
END IF;
    		FORALL n in 1..l_cl_prd_count
            		UPDATE iex_promise_details
            		SET UWQ_STATUS = 'COMPLETE',
            		UWQ_COMPLETE_DATE = sysdate,
            		last_update_date = sysdate,
            		last_updated_by = G_USER_ID
            		WHERE promise_detail_id = l_broken_promise_ids_tbl(n);
	end if;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	iex_debug_pub.LogMessage(G_PKG_NAME || '.CLOSE_PROMISES: End of body');
END IF;
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
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      		iex_debug_pub.LogMessage(G_PKG_NAME || '.CLOSE_PROMISES: in FND_API.G_EXC_ERROR execption');
END IF;
      		ROLLBACK TO CLOSE_PROMISES_PVT;
      		x_return_status := FND_API.G_RET_STS_ERROR;
      		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
      		-- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
      		--IEX_CONC_REQUEST_MSG_PKG.Log_Error(
                --   	P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
                --   	P_Procedure_name        => 'IEX_PROMISES_BATCH_PUB.CLOSE_PROMISES',
                --   	P_MESSAGE               => 'Failed to close promises.' );
                -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
    	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      		iex_debug_pub.LogMessage(G_PKG_NAME || '.CLOSE_PROMISES: in FND_API.G_EXC_UNEXPECTED_ERROR execption');
END IF;
      		ROLLBACK TO CLOSE_PROMISES_PVT;
      		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
      		-- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
      		--IEX_CONC_REQUEST_MSG_PKG.Log_Error(
                --   	P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
                --   	P_Procedure_name        => 'IEX_PROMISES_BATCH_PUB.CLOSE_PROMISES',
                --   	P_MESSAGE               => 'Failed to close promises.' );
                -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
    	WHEN OTHERS THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      		iex_debug_pub.LogMessage(G_PKG_NAME || '.CLOSE_PROMISES: in OTHERS execption');
END IF;
      		ROLLBACK TO CLOSE_PROMISES_PVT;
      		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        		FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      		END IF;
      		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
      		-- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
      		--IEX_CONC_REQUEST_MSG_PKG.Log_Error(
                --   	P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
                --   	P_Procedure_name        => 'IEX_PROMISES_BATCH_PUB.CLOSE_PROMISES',
                --   	P_MESSAGE               => 'Failed to close promises.' );
                -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
*/
END;

/**********************
	This procedure is called from concurent meneger to start promises processing
***********************/
PROCEDURE IEX_PROMISES_CONCUR(
	ERRBUF      OUT NOCOPY     VARCHAR2,
	RETCODE     OUT NOCOPY     VARCHAR2,
	P_ORG_ID IN NUMBER DEFAULT NULL)  --Added for MOAC
IS
	l_msg_count	number;
BEGIN
        --Start MOAC
        mo_global.init('IEX');
	IF p_org_id IS NULL THEN
		mo_global.set_policy_context('M',NULL);
	ELSE
		mo_global.set_policy_context('S',p_org_id);
	END IF;
	--End MOAC

        fnd_file.put_line(FND_FILE.LOG, 'Running Promise Reconciliation concurrent program');
        fnd_file.put_line(FND_FILE.LOG, 'Operating Unit: '|| nvl(mo_global.get_ou_name(mo_global.get_current_org_id), 'All'));

	PROCESS_ALL_PROMISES(
    		P_API_VERSION => 1.0,
    		P_INIT_MSG_LIST	=> FND_API.G_TRUE,
    		P_COMMIT => FND_API.G_TRUE,
    		P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
    		X_RETURN_STATUS	=> RETCODE,
    		X_MSG_COUNT => l_msg_count,
    		X_MSG_DATA => ERRBUF);
END;

/**********************
	This procedure process all available promises
***********************/
PROCEDURE PROCESS_ALL_PROMISES(
    P_API_VERSION		    	IN      NUMBER,
    P_INIT_MSG_LIST		    	IN      VARCHAR2,
    P_COMMIT				IN      VARCHAR2,
    P_VALIDATION_LEVEL	    		IN      NUMBER,
    X_RETURN_STATUS		    	OUT NOCOPY     VARCHAR2,
    X_MSG_COUNT				OUT NOCOPY     NUMBER,
    X_MSG_DATA	    	    		OUT NOCOPY     VARCHAR2)
IS
    l_api_name                       CONSTANT VARCHAR2(30) := 'PROCESS_ALL_PROMISES';
    l_api_version                    CONSTANT NUMBER := 1.0;
    l_return_status                  VARCHAR2(1);
    l_msg_count                      NUMBER;
    l_msg_data                       VARCHAR2(32767);

--Begin bug 6053792 gnramasa 17-May-2007
    --Should update IEX_DLN_UWQ_SUMMARY even when there are no broken promises with status COLLECTABLE
    -- Bug #6251572 bibeura 24-OCT-2007 Modified Cursor definition
    CURSOR UPDATE_IEX_SUMMARY
    IS
        SELECT sum(decode(a.status, 'COLLECTABLE', 1, 0) ) numb,
             sum(decode(a.status, 'COLLECTABLE', a.amount_due_remaining, 0)) broken_amount,
             sum(decode(a.status, 'COLLECTABLE', a.promise_amount, 0)) promise_amount,
	     d.party_cust_id party_cust_id,
             a.cust_account_id cust_account_id,
	     d.customer_site_use_id customer_site_use_id
        FROM iex_promise_details a,
	     iex_delinquencies d--_all d --Changed for bug 7237026 20-Jan-2009 barathsr
	WHERE a.delinquency_id=d.delinquency_id
	AND a.state = 'BROKEN_PROMISE'
        AND a.status in ('COLLECTABLE','FULFILLED', 'CANCELLED')
	AND a.org_id = d.org_id --Added for bug 7237026 31-Dec-2008 barathsr
        AND EXISTS (SELECT 1 FROM iex_promise_details b
               where TRUNC(b.last_update_date)=TRUNC(SYSDATE) AND a.cust_account_id = b.cust_account_id)
        GROUP BY d.party_cust_id,
	         a.cust_account_id,
		 d.customer_site_use_id;

   CURSOR UPDATE_IEX_ACTIVE_PRO
   IS
	 SELECT sum(decode(pd.status, 'COLLECTABLE', 1, 0)) active_promises,
	        d.party_cust_id party_cust_id,
		pd.cust_account_id cust_account_id,
		d.customer_site_use_id customer_site_use_id
	 FROM iex_promise_details pd,
	      iex_delinquencies d--_all d --Changed for bug 7237026 20-Jan-2009 barathsr
	 WHERE pd.delinquency_id=d.delinquency_id
	 AND pd.state = 'BROKEN_PROMISE'
	 AND pd.status in ('COLLECTABLE','FULFILLED', 'CANCELLED')
	 AND pd.org_id =d.org_id --Added for bug 7237026 31-Dec-2008 barathsr
	 AND EXISTS (SELECT 1 FROM iex_promise_details b
		   where TRUNC(b.last_update_date)=TRUNC(SYSDATE) AND pd.cust_account_id = b.cust_account_id)
	 AND(pd.uwq_status IS NULL OR pd.uwq_status = 'ACTIVE'
	  OR(TRUNC(pd.uwq_active_date) <= TRUNC(sysdate)
	  AND pd.uwq_status = 'PENDING'))
	 GROUP BY d.party_cust_id,
	          pd.cust_account_id,
		  d.customer_site_use_id;

   CURSOR UPDATE_IEX_COMP_PRO
   IS
	 SELECT sum(decode(pd.status, 'COLLECTABLE', 1, 0)) complete_promises,
	        d.party_cust_id party_cust_id,
	        pd.cust_account_id cust_account_id,
		d.customer_site_use_id customer_site_use_id
	 FROM iex_promise_details pd,
	      iex_delinquencies d--_all d --Changed for bug 7237026 20-Jan-2009 barathsr
	 WHERE pd.delinquency_id=d.delinquency_id
	 AND pd.state = 'BROKEN_PROMISE'
	 AND pd.status in ('COLLECTABLE','FULFILLED', 'CANCELLED')
	 AND pd.org_id = d.org_id --Added for bug 7237026 31-Dec-2008 barathsr
	 AND EXISTS (SELECT 1 FROM iex_promise_details b
		   where TRUNC(b.last_update_date)=TRUNC(SYSDATE) AND pd.cust_account_id = b.cust_account_id)
	 AND(pd.uwq_status = 'COMPLETE'
	 AND(TRUNC(pd.uwq_complete_date) +
	 fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') > TRUNC(sysdate)))
	 GROUP BY d.party_cust_id,
	          pd.cust_account_id,
		  d.customer_site_use_id;

   CURSOR UPDATE_IEX_PEND_PRO
   IS
	 SELECT sum(decode(pd.status, 'COLLECTABLE', 1, 0)) pending_promises,
		d.party_cust_id party_cust_id,
		pd.cust_account_id cust_account_id,
		d.customer_site_use_id customer_site_use_id
	 FROM iex_promise_details pd,
	      iex_delinquencies d--_all d --Changed for bug 7237026 20-Jan-2009 barathsr
	 WHERE pd.delinquency_id=d.delinquency_id
	 AND pd.state = 'BROKEN_PROMISE'
	 AND pd.status in ('COLLECTABLE','FULFILLED', 'CANCELLED')
	 AND pd.org_id = d.org_id --Added for bug 7237026 31-Dec-2008 barathsr
	 AND EXISTS (SELECT 1 FROM iex_promise_details b
		   where TRUNC(b.last_update_date)=TRUNC(SYSDATE) AND pd.cust_account_id = b.cust_account_id)
	 AND (pd.uwq_status = 'PENDING'
		 AND(TRUNC(pd.uwq_active_date) > TRUNC(sysdate)))
	 GROUP BY d.party_cust_id,
	          pd.cust_account_id,
		  d.customer_site_use_id;

   l_stage_number	number;
   /*
   CURSOR UPDATE_NOT_FULLY_PRO_DEL
   IS
	SELECT pd.delinquency_id delinquency_id
	from iex_promise_details pd,
	     iex_delinquencies d
	where pd.delinquency_id = d.delinquency_id
	 AND pd.status = 'COLLECTABLE'
	 AND pd.state = 'PROMISE'
	 AND d.staged_dunning_level = 0
	 group by pd.delinquency_id
	 having sum(pd.promise_amount) < (select amount_due_remaining from ar_payment_schedules pay,
									   iex_delinquencies del
					  where pay.payment_schedule_id = del.payment_schedule_id
					  and del.delinquency_id = pd.delinquency_id);

   CURSOR UPDATE_FULLY_PRO_DEL
   IS
	SELECT pd.delinquency_id delinquency_id
	from iex_promise_details pd,
	     iex_delinquencies d
	where pd.delinquency_id = d.delinquency_id
	 AND pd.status = 'COLLECTABLE'
	 AND pd.state = 'PROMISE'
	 AND d.staged_dunning_level <> 0
	 group by pd.delinquency_id
	 having sum(pd.promise_amount) >= (select amount_due_remaining from ar_payment_schedules pay,
									   iex_delinquencies del
					  where pay.payment_schedule_id = del.payment_schedule_id
					  and del.delinquency_id = pd.delinquency_id);
*/
  CURSOR UPDATE_PRO_DEL
   IS
	SELECT promise_detail_id
	from iex_promise_details pd
	where status = 'COLLECTABLE';
/*
-- Start bug#5874874 gnramasa 25-Apr-07

    CURSOR UPDATE_IEX_SUMMARY IS
      SELECT COUNT(CUST_ACCOUNT_ID) NUMB,
      sum(AMOUNT_DUE_REMAINING) broken_amount,
      sum(PROMISE_AMOUNT) promise_amount,
      CUST_ACCOUNT_ID
      FROM IEX_PROMISE_DETAILS
      WHERE STATE = 'BROKEN_PROMISE'
      AND STATUS = 'COLLECTABLE'
      AND NVL(AMOUNT_DUE_REMAINING,0) > 0
      GROUP BY CUST_ACCOUNT_ID;

   CURSOR UPDATE_IEX_ACTIVE_PRO IS
     SELECT count(cust_account_id)active_promises,cust_account_id
     FROM iex_promise_details pd
     WHERE pd.state = 'BROKEN_PROMISE'
     AND(pd.uwq_status IS NULL OR pd.uwq_status = 'ACTIVE'
     OR(TRUNC(pd.uwq_active_date) <= TRUNC(sysdate)
     AND pd.uwq_status = 'PENDING'))
     GROUP BY CUST_ACCOUNT_ID;

   CURSOR UPDATE_IEX_COMP_PRO IS
     SELECT count(cust_account_id)complete_promises,cust_account_id
     FROM iex_promise_details pd
     WHERE pd.state = 'BROKEN_PROMISE'
     AND(pd.uwq_status = 'COMPLETE'
     AND(TRUNC(pd.uwq_complete_date) +
     fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') > TRUNC(sysdate)))
    GROUP BY CUST_ACCOUNT_ID;

   CURSOR UPDATE_IEX_PEND_PRO IS
     SELECT count(cust_account_id)pending_promises,cust_account_id
     FROM iex_promise_details pd
     WHERE pd.state = 'BROKEN_PROMISE' AND(pd.uwq_status = 'PENDING'
     AND(TRUNC(pd.uwq_active_date) > TRUNC(sysdate)))
     GROUP BY CUST_ACCOUNT_ID;

-- End bug#5874874 gnramasa 25-Apr-07
*/
--End bug 6053792 gnramasa 17-May-2007
BEGIN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    LogMessage('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$');
    LogMessage(G_PKG_NAME || '.' || l_api_name || ':Start');
END IF;


    -- Standard start of API savepoint
    SAVEPOINT PROCESS_ALL_PROMISES_PVT;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    LogMessage(G_PKG_NAME || '.' || l_api_name || ':Savepoint is established');
END IF;
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
    LogMessage(G_PKG_NAME || '.' || l_api_name || ':Start of body');
END IF;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    LogMessage('********************************************');
    LogMessage(G_PKG_NAME || '.' || l_api_name || ':Calling PROCESS_REVERSALS for AR ');
END IF;
    PROCESS_REVERSALS(
    	P_API_VERSION => 1.0,
    	P_INIT_MSG_LIST	=> FND_API.G_TRUE,
    	P_COMMIT => FND_API.G_TRUE,
    	P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
    	X_RETURN_STATUS	=> l_return_status,
    	X_MSG_COUNT => l_msg_count,
    	X_MSG_DATA => l_msg_data,
    	P_TYPE => 'AR');

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    LogMessage('********************************************');
    LogMessage(G_PKG_NAME || '.' || l_api_name || ':Calling PROCESS_REVERSALS for OKL ');
END IF;
    PROCESS_REVERSALS(
    	P_API_VERSION => 1.0,
    	P_INIT_MSG_LIST	=> FND_API.G_TRUE,
    	P_COMMIT => FND_API.G_TRUE,
    	P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
    	X_RETURN_STATUS	=> l_return_status,
    	X_MSG_COUNT => l_msg_count,
    	X_MSG_DATA => l_msg_data,
    	P_TYPE => 'OKL');

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    LogMessage('********************************************');
    LogMessage(G_PKG_NAME || '.' || l_api_name || ':Processing promises on AR invoices...');
END IF;
    PROCESS_PROMISES(
    	P_API_VERSION => 1.0,
    	P_INIT_MSG_LIST	=> FND_API.G_TRUE,
    	P_COMMIT => FND_API.G_TRUE,
    	P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
    	X_RETURN_STATUS	=> l_return_status,
    	X_MSG_COUNT => l_msg_count,
    	X_MSG_DATA => l_msg_data,
        P_TYPE => 'INV');

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    LogMessage('********************************************');
    LogMessage(G_PKG_NAME || '.' || l_api_name || ':Processing promises on AR account...');
END IF;
    PROCESS_PROMISES(
    	P_API_VERSION => 1.0,
    	P_INIT_MSG_LIST	=> FND_API.G_TRUE,
    	P_COMMIT => FND_API.G_TRUE,
    	P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
    	X_RETURN_STATUS	=> l_return_status,
    	X_MSG_COUNT => l_msg_count,
    	X_MSG_DATA => l_msg_data,
        P_TYPE => 'ACC');

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    LogMessage('********************************************');
    LogMessage(G_PKG_NAME || '.' || l_api_name || ':Processing promises on OKL contracts...');
END IF;
    PROCESS_PROMISES(
    	P_API_VERSION => 1.0,
    	P_INIT_MSG_LIST	=> FND_API.G_TRUE,
    	P_COMMIT => FND_API.G_TRUE,
    	P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
    	X_RETURN_STATUS	=> l_return_status,
    	X_MSG_COUNT => l_msg_count,
    	X_MSG_DATA => l_msg_data,
        P_TYPE => 'CNTR');

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    LogMessage(G_PKG_NAME || '.' || l_api_name || ':End of body');
END IF;
    -- END OF BODY OF API

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	LogMessage(G_PKG_NAME || '.' || l_api_name || ':Commited work');
END IF;
    END IF;

    x_return_status := l_return_status;
    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data);

-- Start bug#5874874 gnramasa 25-Apr-07
  BEGIN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	LogMessage(G_PKG_NAME || '.' || l_api_name || 'Started Updating IEX_DLN_UWQ_SUMMARY');
  END IF;
  -- Bug #6251572 bibeura 24-OCT-2007 modified the following Update statement
  FOR I IN UPDATE_IEX_SUMMARY
  LOOP
   UPDATE IEX_DLN_UWQ_SUMMARY
   SET NUMBER_OF_PROMISES = I.NUMB,
       BROKEN_PROMISE_AMOUNT = I.BROKEN_AMOUNT,
       PROMISE_AMOUNT = I.PROMISE_AMOUNT,
       LAST_UPDATE_DATE= SYSDATE
   WHERE PARTY_ID = I.PARTY_CUST_ID
   AND CUST_ACCOUNT_ID = NVL(I.CUST_ACCOUNT_ID,CUST_ACCOUNT_ID)
   AND SITE_USE_ID = NVL(I.CUSTOMER_SITE_USE_ID,SITE_USE_ID);
  END LOOP;

  COMMIT;

  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	LogMessage(G_PKG_NAME || '.' || l_api_name || 'Finished Updating IEX_DLN_UWQ_SUMMARY');
  END IF;
  EXCEPTION WHEN OTHERS THEN
   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    LogMessage(G_PKG_NAME || '.' || l_api_name || 'Error Occurred while updating IEX_DLN_UWQ_SUMMARY ' || SQLERRM );
   END IF;
  END;

BEGIN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	LogMessage(G_PKG_NAME || '.' || l_api_name || 'Started Updating IEX_DLN_UWQ_SUMMARY ACTIVE COLUMN');
  END IF;
  -- Bug #6251572 bibeura 24-OCT-2007 modified the following Update statement
  FOR I IN UPDATE_IEX_ACTIVE_PRO
  LOOP
   UPDATE IEX_DLN_UWQ_SUMMARY
   SET ACTIVE_PROMISES = I.ACTIVE_PROMISES,
       LAST_UPDATE_DATE= SYSDATE
   WHERE PARTY_ID = I.PARTY_CUST_ID
   AND CUST_ACCOUNT_ID = NVL(I.CUST_ACCOUNT_ID,CUST_ACCOUNT_ID)
   AND SITE_USE_ID = NVL(I.CUSTOMER_SITE_USE_ID,SITE_USE_ID);
  END LOOP;

  COMMIT;

  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	LogMessage(G_PKG_NAME || '.' || l_api_name || 'Finished Updating IEX_DLN_UWQ_SUMMARY ACTIVE COLUMN');
  END IF;
  EXCEPTION WHEN OTHERS THEN
   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    LogMessage(G_PKG_NAME || '.' || l_api_name || 'Error Occurred while updating IEX_DLN_UWQ_SUMMARY ACTIVE' || SQLERRM );
   END IF;
  END;

  BEGIN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	LogMessage(G_PKG_NAME || '.' || l_api_name || 'Started Updating IEX_DLN_UWQ_SUMMARY COMPLETED COLUMN');
  END IF;
  -- Bug #6251572 bibeura 24-OCT-2007 modified the following Update statement
  FOR I IN UPDATE_IEX_COMP_PRO
  LOOP
   UPDATE IEX_DLN_UWQ_SUMMARY
   SET COMPLETE_PROMISES = I.COMPLETE_PROMISES,
       LAST_UPDATE_DATE= SYSDATE
   WHERE PARTY_ID = I.PARTY_CUST_ID
   AND CUST_ACCOUNT_ID = NVL(I.CUST_ACCOUNT_ID,CUST_ACCOUNT_ID)
   AND SITE_USE_ID = NVL(I.CUSTOMER_SITE_USE_ID,SITE_USE_ID);
  END LOOP;

  COMMIT;

  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	LogMessage(G_PKG_NAME || '.' || l_api_name || 'Finished Updating IEX_DLN_UWQ_SUMMARY COMPLETED COLUMN');
  END IF;
  EXCEPTION WHEN OTHERS THEN
   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    LogMessage(G_PKG_NAME || '.' || l_api_name ||
    'Error Occurred while updating IEX_DLN_UWQ_SUMMARY COMPLETED COLUMN' || SQLERRM );
   END IF;
  END;

  BEGIN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	LogMessage(G_PKG_NAME || '.' || l_api_name || 'Started Updating IEX_DLN_UWQ_SUMMARY PENDING COLUMN');
  END IF;
  -- Bug #6251572 bibeura 24-OCT-2007 modified the following Update statement
  FOR I IN UPDATE_IEX_PEND_PRO
  LOOP
   UPDATE IEX_DLN_UWQ_SUMMARY
   SET PENDING_PROMISES = I.PENDING_PROMISES,
       LAST_UPDATE_DATE = SYSDATE
   WHERE PARTY_ID = I.PARTY_CUST_ID
   AND CUST_ACCOUNT_ID = NVL(I.CUST_ACCOUNT_ID,CUST_ACCOUNT_ID)
   AND SITE_USE_ID = NVL(I.CUSTOMER_SITE_USE_ID,SITE_USE_ID);
  END LOOP;

  COMMIT;

  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	LogMessage(G_PKG_NAME || '.' || l_api_name || ' Finished Updating IEX_DLN_UWQ_SUMMARY PENDING COLUMN');
  END IF;
  EXCEPTION WHEN OTHERS THEN
   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    LogMessage(G_PKG_NAME || '.' || l_api_name ||
      'Error Occurred while updating IEX_DLN_UWQ_SUMMARY PENDING COLUMN ' || SQLERRM );
   END IF;
  END;

-- End bug#5874874 gnramasa 25-Apr-07


  --start
  BEGIN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	LogMessage(G_PKG_NAME || '.' || l_api_name || 'Started Updating IEX_DELINQUENCY_ALL STAGED_DUNNING_LEVEL COLUMN');
    END IF;

    /*
    FOR I IN UPDATE_NOT_FULLY_PRO_DEL
    LOOP

	iex_utilities.MaxStageForanDelinquency (p_delinquency_id  => I.delinquency_id
						, p_stage_number  => l_stage_number);
	update iex_delinquencies_all
	set staged_dunning_level = l_stage_number
	where delinquency_id = I.delinquency_id;
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		LogMessage(G_PKG_NAME || '.' || l_api_name || 'Updated the staged dunning level to ' || l_stage_number || ' for delinquency id: ' || I.delinquency_id);
	end if;

    END LOOP;

    FOR J IN UPDATE_FULLY_PRO_DEL
    LOOP

	update iex_delinquencies_all
	set staged_dunning_level = 0
	where delinquency_id = J.delinquency_id;
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		LogMessage(G_PKG_NAME || '.' || l_api_name || 'Updated the staged dunning level to 0 for delinquency id: ' || J.delinquency_id);
	end if;

    END LOOP;
    */

    FOR I IN UPDATE_PRO_DEL
    LOOP

	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	      LogMessage(G_PKG_NAME || '.' || l_api_name || ': Calling IEX_PROMISES_PUB.update_del_stage_level');
	END IF;
	IEX_PROMISES_PUB.update_del_stage_level (
		p_promise_id		=> I.promise_detail_id,
		X_RETURN_STATUS		=> l_return_status,
		X_MSG_COUNT             => l_msg_count,
		X_MSG_DATA	    	=> l_msg_data);

	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	      LogMessage(G_PKG_NAME || '.' || l_api_name || ': After call to IEX_PROMISES_PUB.update_del_stage_level');
	      LogMessage(G_PKG_NAME || '.' || l_api_name || ': Status = ' || l_return_status);
	END IF;

	-- check for errors
	IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		     LogMessage(G_PKG_NAME || '.' || l_api_name || ': IEX_PROMISES_PUB.update_del_stage_level failed');
		END IF;
		RAISE FND_API.G_EXC_ERROR;
	END IF;

    END LOOP;

    COMMIT;

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	LogMessage(G_PKG_NAME || '.' || l_api_name || ' Finished Updating IEX_DELINQUENCY_ALL STAGED_DUNNING_LEVEL COLUMN');
    END IF;
    EXCEPTION WHEN OTHERS THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       LogMessage(G_PKG_NAME || '.' || l_api_name ||
      'Error Occurred while updating IEX_DELINQUENCY_ALL STAGED_DUNNING_LEVEL COLUMN ' || SQLERRM );
    END IF;
  END;
  --end

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO PROCESS_ALL_PROMISES_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
      -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
      /*
      IEX_CONC_REQUEST_MSG_PKG.Log_Error(
            P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
            P_Procedure_name        => G_PKG_NAME || '.' || l_api_name,
            P_MESSAGE               => 'Failed to process all promises');
      */
      -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      LogMessage(G_PKG_NAME || '.' || l_api_name || ': In G_EXC_ERROR exception. Failed to process all promises');
END IF;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO PROCESS_ALL_PROMISES_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
      -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
      /*
      IEX_CONC_REQUEST_MSG_PKG.Log_Error(
            P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
            P_Procedure_name        => G_PKG_NAME || '.' || l_api_name,
            P_MESSAGE               => 'Failed to process all promises');
      */
      -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      LogMessage(G_PKG_NAME || '.' || l_api_name || ': In G_EXC_UNEXPECTED_ERROR exception. Failed to process all promises');
END IF;
    WHEN OTHERS THEN
      ROLLBACK TO PROCESS_ALL_PROMISES_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
      -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
      /*
      IEX_CONC_REQUEST_MSG_PKG.Log_Error(
            P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
            P_Procedure_name        => G_PKG_NAME || '.' || l_api_name,
            P_MESSAGE               => 'Failed to process all promises');
      */
      -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      LogMessage(G_PKG_NAME || '.' || l_api_name || ': In OTHERS exception. Failed to process all promises');
END IF;
END;

/**********************
	This procedure unapply promise applications that have been reversed in AR
***********************/
PROCEDURE PROCESS_REVERSALS(
    P_API_VERSION		    	IN      NUMBER,
    P_INIT_MSG_LIST		    	IN      VARCHAR2,
    P_COMMIT				IN      VARCHAR2,
    P_VALIDATION_LEVEL	    		IN      NUMBER,
    X_RETURN_STATUS		    	OUT NOCOPY     VARCHAR2,
    X_MSG_COUNT				OUT NOCOPY     NUMBER,
    X_MSG_DATA	    	    		OUT NOCOPY     VARCHAR2,
    P_TYPE                      	IN      VARCHAR2)
IS
    l_api_name                  	CONSTANT VARCHAR2(30) := 'PROCESS_REVERSALS';
    l_api_version               	CONSTANT NUMBER := 1.0;
    l_return_status             	VARCHAR2(1);
    l_msg_count                 	NUMBER;
    l_msg_data                  	VARCHAR2(32767);
    vSQL				varchar2(10000);
    Type refCur is Ref Cursor;
    promises_cur			refCur;
    l_appl_tbl			        IEX_PROMISES_BATCH_PUB.REVERSE_APPLS_TBL;
    i                           	NUMBER;
    nCount                      	NUMBER;
    l_promise_detail_id			NUMBER;
    l_promise_date			DATE;
    l_status				VARCHAR2(30);
    l_promise_amount			NUMBER;
    l_amount_due_remaining		NUMBER;
    l_amount_applied			NUMBER;
    l_receivable_application_id		NUMBER;
    l_new_status			VARCHAR2(30) := null;
    l_callback_date			DATE;
    l_new_remaining_amount		NUMBER;

BEGIN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    LogMessage(G_PKG_NAME || '.' || l_api_name || ':Start');
END IF;



    -- Standard start of API savepoint
    SAVEPOINT PROCESS_REVERSALS_PVT;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    LogMessage(G_PKG_NAME || '.' || l_api_name || ':Savepoint is established');
END IF;
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
    LogMessage(G_PKG_NAME || '.' || l_api_name || ':Start of body');
END IF;

    if P_TYPE = 'AR' then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	LogMessage(G_PKG_NAME || '.' || l_api_name || ':Searching for applications that still applied to promises but reversed in AR ');
END IF;
    	-- search for all applications that still applied to promises but reversed in AR
    	vSQL := 'SELECT ' ||
	 	'prd.promise_detail_id, ' ||
	 	'prd.promise_date, ' ||
	 	'prd.status, ' ||
	 	'prd.promise_amount, ' ||
	 	'prd.amount_due_remaining, ' ||
	 	'pax.amount_applied, ' ||
	 	'raa.receivable_application_id ' ||
		'FROM ' ||
		'AR_RECEIVABLE_APPLICATIONS raa, ' ||
		'IEX_prd_appl_xref pax, ' ||
		'iex_promise_details prd ' ||
		'WHERE ' ||
		'raa.receivable_application_id = pax.receivable_application_id and ' ||
		'raa.status in (''APP'', ''ACC'') and ' ||
		'raa.amount_applied > 0 and ' ||
            	'raa.reversal_gl_date is not null and ' ||
		'pax.reversed_flag is null and ' ||
		'pax.reversed_date is null and ' ||
		'pax.receivable_application_id is not null and ' ||
		'pax.promise_detail_id = prd.promise_detail_id and ' ||
		'prd.status in (''COLLECTABLE'', ''FULFILLED'') and ' ||
		'prd.org_id = raa.org_id ' || --Added for bug 7237026 barathsr 31-Dec-2008
		'ORDER BY raa.receivable_application_id';

    else
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	LogMessage(G_PKG_NAME || '.' || l_api_name || ':Searching for applications that still applied to promises but reversed in OKL ');
END IF;
    	-- search for all applications that still applied to promises but reversed in OKL
       /* replaced the statement just below to fix a perf bug 4930383
    	vSQL := 'SELECT ' ||
	 	'prd.promise_detail_id, ' ||
	 	'prd.promise_date, ' ||
	 	'prd.status, ' ||
	 	'prd.promise_amount, ' ||
	 	'prd.amount_due_remaining, ' ||
	 	'pax.amount_applied, ' ||
	 	'raa.receivable_application_id ' ||
		'FROM ' ||
		'IEX_OKL_PAYMENTS_V raa, ' ||
		'IEX_prd_appl_xref pax, ' ||
		'iex_promise_details prd ' ||
		'WHERE ' ||
		'raa.receivable_application_id = pax.receivable_application_id and ' ||
		'raa.amount_applied > 0 and ' ||
            	'raa.reversal_gl_date is not null and ' ||
		'pax.reversed_flag is null and ' ||
		'pax.reversed_date is null and ' ||
		'pax.promise_detail_id = prd.promise_detail_id and ' ||
		'prd.status in (''COLLECTABLE'', ''FULFILLED'') ' ||
		'ORDER BY raa.receivable_application_id';
       */

        vSQL := 'SELECT ' ||
                'prd.promise_detail_id, ' ||
                'prd.promise_date, ' ||
                'prd.status, ' ||
                'prd.promise_amount, ' ||
                'prd.amount_due_remaining, ' ||
                'pax.amount_applied, ' ||
                'pax.receivable_application_id ' ||
                'FROM ' ||
                'IEX_prd_appl_xref pax, ' ||
                'iex_promise_details prd, ' ||
		'AR_SYSTEM_PARAMETERS asp ' ||--Added for bug 73237026 barathsr 31-Dec-2008
                'WHERE ' ||
                'pax.receivable_application_id IN  (select receivable_application_id from IEX_OKL_PAYMENTS_V where ' ||
                'amount_applied > 0 and ' ||
                'reversal_gl_date is not null)  and ' ||
                'pax.reversed_flag is null and ' ||
                'pax.reversed_date is null and ' ||
		'pax.receivable_application_id is not null and ' ||
                'pax.promise_detail_id = prd.promise_detail_id and ' ||
                'prd.status in (''COLLECTABLE'', ''FULFILLED'') and ' ||
		'prd.org_id = asp.org_id ' || --Added for bug 73237026 barathsr
                'ORDER BY pax.receivable_application_id';
    end if;

    open promises_cur for vSQL ;
    i := 0;
    LOOP
        fetch promises_cur into
        	l_promise_detail_id,
        	l_promise_date,
        	l_status,
        	l_promise_amount,
        	l_amount_due_remaining,
        	l_amount_applied,
        	l_receivable_application_id;
	exit when promises_cur%NOTFOUND;
        i := i+1;
        l_appl_tbl(i).promise_detail_id := l_promise_detail_id;
        l_appl_tbl(i).promise_date := l_promise_date;
        l_appl_tbl(i).status := l_status;
        l_appl_tbl(i).promise_amount := l_promise_amount;
        l_appl_tbl(i).amount_due_remaining := l_amount_due_remaining;
        l_appl_tbl(i).amount_applied := l_amount_applied;
        l_appl_tbl(i).receivable_application_id := l_receivable_application_id;



IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	LogMessage(G_PKG_NAME || '.' || l_api_name || '------------------------');
    	LogMessage(G_PKG_NAME || '.' || l_api_name || ':Reversed record  ' || i);
        LogMessage(G_PKG_NAME || '.' || l_api_name || ':promise_detail_id = ' || l_appl_tbl(i).promise_detail_id);
        LogMessage(G_PKG_NAME || '.' || l_api_name || ':promise_date = ' || l_appl_tbl(i).promise_date);
        LogMessage(G_PKG_NAME || '.' || l_api_name || ':status = ' || l_appl_tbl(i).status);
        LogMessage(G_PKG_NAME || '.' || l_api_name || ':promise_amount = ' || l_appl_tbl(i).promise_amount);
        LogMessage(G_PKG_NAME || '.' || l_api_name || ':amount_due_remaining = ' || l_appl_tbl(i).amount_due_remaining);
        LogMessage(G_PKG_NAME || '.' || l_api_name || ':amount_applied = ' || l_appl_tbl(i).amount_applied);
        LogMessage(G_PKG_NAME || '.' || l_api_name || ':receivable_application_id = ' || l_appl_tbl(i).receivable_application_id);
END IF;
    END LOOP;

    nCount := l_appl_tbl.count;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    LogMessage(G_PKG_NAME || '.' || l_api_name || ':Total count of found reversed applications = ' || nCount);
END IF;
    if nCount > 0 then

    	FOR i in 1..nCount LOOP
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    		LogMessage(G_PKG_NAME || '.' || l_api_name || '------------------------');
    		LogMessage(G_PKG_NAME || '.' || l_api_name || ':Reversing record  ' || i);
END IF;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    		LogMessage(G_PKG_NAME || '.' || l_api_name || ':Analizing what status to set for the promise...');
    		LogMessage(G_PKG_NAME || '.' || l_api_name || ':current promise status ' || l_appl_tbl(i).status);
END IF;
		if l_appl_tbl(i).status = 'FULFILLED' then   -- it can effect only to FULFILLED records
			l_new_status := 'COLLECTABLE';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    			LogMessage(G_PKG_NAME || '.' || l_api_name || ':the promise status after reversing will be ' || l_new_status);
END IF;
		else
			l_new_status := null;
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    			LogMessage(G_PKG_NAME || '.' || l_api_name || ':will leave this status');
            END IF;
		end if;

    		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    		    LogMessage(G_PKG_NAME || '.' || l_api_name || ':updating records in IEX_prd_appl_xref with reversed_flag = Y...');
            END IF;

            	update IEX_prd_appl_xref
           	set reversed_flag = 'Y',
                reversed_date = sysdate,
               	last_update_date = sysdate,
                last_updated_by = G_USER_ID,
                request_id = G_REQUEST_ID
            	where
                receivable_application_id = l_appl_tbl(i).receivable_application_id and
                promise_detail_id = l_appl_tbl(i).promise_detail_id;

		if (sql%notfound) then
			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				LogMessage(G_PKG_NAME || '.' || l_api_name || ':update failed');
			END IF;
			-- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
			/*
    			IEX_CONC_REQUEST_MSG_PKG.Log_Error(
        			P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
                   		P_Procedure_name        => G_PKG_NAME || '.' || l_api_name,
                  		P_MESSAGE               => 'Failed to update record in IEX_prd_appl_xref for promise_detail_id = ' || l_appl_tbl(i).promise_detail_id);
                        */
                        -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
		else
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			     LogMessage(G_PKG_NAME || '.' || l_api_name || ':update successfull');
            END IF;
		end if;

		l_new_remaining_amount := l_appl_tbl(i).amount_due_remaining + l_appl_tbl(i).amount_applied;
    	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    		LogMessage(G_PKG_NAME || '.' || l_api_name || ':updating record in IEX_PROMISE_DETAILS with:');
    		LogMessage(G_PKG_NAME || '.' || l_api_name || ':amount_due_remaining = ' || l_new_remaining_amount);
        END IF;

        if l_new_status is not null then
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    			LogMessage(G_PKG_NAME || '.' || l_api_name || ':status = ' || l_new_status);
            END IF;
            		update IEX_PROMISE_DETAILS
           		set status = l_new_status,
                	amount_due_remaining = l_new_remaining_amount,
               		last_update_date = sysdate,
                	last_updated_by = G_USER_ID
            		where promise_detail_id = l_appl_tbl(i).promise_detail_id;
    		else
            		update IEX_PROMISE_DETAILS
                	set amount_due_remaining = l_new_remaining_amount,
               		last_update_date = sysdate,
                	last_updated_by = G_USER_ID
            		where promise_detail_id = l_appl_tbl(i).promise_detail_id;
    		end if;

		if (sql%notfound) then
                      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			     LogMessage(G_PKG_NAME || '.' || l_api_name || ':update failed');
                      END IF;
                      -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
                      /*
    			IEX_CONC_REQUEST_MSG_PKG.Log_Error(
        			P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
                   		P_Procedure_name        => G_PKG_NAME || '.' || l_api_name,
                  		P_MESSAGE               => 'Failed to update record in IEX_PROMISE_DETAILS for promise_detail_id = ' || l_appl_tbl(i).promise_detail_id);
                      */
                      -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
		else
			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			     LogMessage(G_PKG_NAME || '.' || l_api_name || ':update successfull');
			END IF;

			/*
			--start
			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Calling IEX_PROMISES_PUB.update_del_stage_level');
			END IF;
			IEX_PROMISES_PUB.update_del_stage_level (
				p_promise_id		=> l_appl_tbl(i).promise_detail_id,
				X_RETURN_STATUS		=> l_return_status,
				X_MSG_COUNT             => l_msg_count,
				X_MSG_DATA	    	=> l_msg_data);

			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': After call to IEX_PROMISES_PUB.update_del_stage_level');
			      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Status = ' || L_RETURN_STATUS);
			END IF;

			-- check for errors
			IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
				IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				     iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': IEX_PROMISES_PUB.update_del_stage_level failed');
				END IF;
				RAISE FND_API.G_EXC_ERROR;
			END IF;
			--end
			*/
		end if;

    	END LOOP;
    else
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	   LogMessage(G_PKG_NAME || '.' || l_api_name || ':no reversed applications found');
        END IF;
    end if;

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        LogMessage(G_PKG_NAME || '.' || l_api_name || ':End of body');
    END IF;
    -- END OF BODY OF API

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	LogMessage(G_PKG_NAME || '.' || l_api_name || ':Commited work');
END IF;
    END IF;

    x_return_status := l_return_status;
    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data);

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO PROCESS_REVERSALS_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
      -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
      /*
      IEX_CONC_REQUEST_MSG_PKG.Log_Error(
            P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
            P_Procedure_name        => G_PKG_NAME || '.' || l_api_name,
            P_MESSAGE               => 'Failed to reverse promise applications');
      */
      -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      LogMessage(G_PKG_NAME || '.' || l_api_name || ': In G_EXC_ERROR exception. Failed to reverse promise applications');
END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO PROCESS_REVERSALS_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
      -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
      /*
      IEX_CONC_REQUEST_MSG_PKG.Log_Error(
            P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
            P_Procedure_name        => G_PKG_NAME || '.' || l_api_name,
            P_MESSAGE               => 'Failed to reverse promise applications');
      */
      -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      LogMessage(G_PKG_NAME || '.' || l_api_name || ': In G_EXC_UNEXPECTED_ERROR exception. Failed to reverse promise applications');
END IF;
    WHEN OTHERS THEN
      ROLLBACK TO PROCESS_REVERSALS_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
      /*
      IEX_CONC_REQUEST_MSG_PKG.Log_Error(
            P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
            P_Procedure_name        => G_PKG_NAME || '.' || l_api_name,
            P_MESSAGE               => 'Failed to reverse promise applications');
      */
      -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      LogMessage(G_PKG_NAME || '.' || l_api_name || ': In OTHERS exception. Failed to reverse promise applications');
END IF;
END;

/**********************
	This procedure processes promises
***********************/
PROCEDURE PROCESS_PROMISES(
    P_API_VERSION		    	IN      NUMBER,
    P_INIT_MSG_LIST		    	IN      VARCHAR2,
    P_COMMIT				IN      VARCHAR2,
    P_VALIDATION_LEVEL	    		IN      NUMBER,
    X_RETURN_STATUS		    	OUT NOCOPY     VARCHAR2,
    X_MSG_COUNT				OUT NOCOPY     NUMBER,
    X_MSG_DATA	    	    		OUT NOCOPY     VARCHAR2,
    P_TYPE                      	IN      VARCHAR2)
IS
    l_api_name                  	CONSTANT VARCHAR2(30) := 'PROCESS_PROMISES';
    l_api_version               	CONSTANT NUMBER := 1.0;
    l_return_status             	VARCHAR2(1);
    l_msg_count                 	NUMBER;
    l_msg_data                  	VARCHAR2(32767);
    vSQL				varchar2(10000);
    Type refCur is Ref Cursor;
    promise_cur                 	refCur;
    y                           	NUMBER;
    nCount                      	NUMBER;
    l_pro_tbl                   	IEX_PROMISES_BATCH_PUB.PROMISES_TBL;

    l_PROMISE_DETAIL_ID         	NUMBER;
    l_CREATION_DATE             	DATE;
    l_PROMISE_DATE              	DATE;
    l_STATUS                    	VARCHAR2(30);
    l_STATE                    		VARCHAR2(30);
    l_PROMISE_AMOUNT            	NUMBER;
    l_AMOUNT_DUE_REMAINING      	NUMBER;
    l_DELINQUENCY_ID            	NUMBER;
    l_PAYMENT_SCHEDULE_ID       	NUMBER;
    l_CUST_ACCOUNT_ID            	NUMBER;
    l_CONTRACT_ID			NUMBER;

BEGIN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    LogMessage(G_PKG_NAME || '.' || l_api_name || ':Start');
END IF;


    -- Standard start of API savepoint
    SAVEPOINT PROCESS_PROMISES_PVT;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    LogMessage(G_PKG_NAME || '.' || l_api_name || ':Savepoint is established');
END IF;
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
    LogMessage(G_PKG_NAME || '.' || l_api_name || ':Start of body');
END IF;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    LogMessage(G_PKG_NAME || '.' || l_api_name || ':searching for all available valid promises...');
END IF;

    if P_TYPE = 'INV' then	-- processing all promises on invoices

        vSQL := 'SELECT ' ||
		 'PRD.promise_detail_id, ' ||
		 'PRD.creation_date, ' ||
		 'nvl(PRD.broken_on_date, PRD.promise_date), ' ||
		 'PRD.status, ' ||
		 'PRD.state, ' ||
		 'PRD.promise_amount, ' ||
		 'PRD.amount_due_remaining, ' ||
		 'PRD.delinquency_id, ' ||
		 'DEL.payment_schedule_id ' ||
		 'FROM ' ||
		 'iex_promise_details prd, ' ||
		 'iex_delinquencies del ' ||
		 'WHERE ' ||
		 'prd.delinquency_id is not null and ' ||
		 'del.delinquency_id = prd.delinquency_id and ' ||
		 'prd.status = ''COLLECTABLE'' and ' ||
		 'prd.org_id = del.org_id ' || --Added for bug 7237026 barathsr 31-Dec-2008
                 'order by PRD.promise_date';

        open promise_cur for vSQL;
        y := 0;
        LOOP
	    fetch promise_cur into
	 	l_PROMISE_DETAIL_ID,
                l_CREATION_DATE,
                l_PROMISE_DATE,
                l_STATUS,
                l_STATE,
                l_PROMISE_AMOUNT,
                l_AMOUNT_DUE_REMAINING,
                l_DELINQUENCY_ID,
                l_PAYMENT_SCHEDULE_ID;
	        exit when promise_cur%NOTFOUND;

            y := y+1;
            l_pro_tbl(y).PROMISE_DETAIL_ID := l_PROMISE_DETAIL_ID;
            l_pro_tbl(y).CREATION_DATE := l_CREATION_DATE;
            l_pro_tbl(y).PROMISE_DATE := l_PROMISE_DATE;
            l_pro_tbl(y).STATUS := l_STATUS;
            l_pro_tbl(y).STATE := l_STATE;
            l_pro_tbl(y).PROMISE_AMOUNT := l_PROMISE_AMOUNT;
            l_pro_tbl(y).AMOUNT_DUE_REMAINING := l_AMOUNT_DUE_REMAINING;
            l_pro_tbl(y).DELINQUENCY_ID := l_DELINQUENCY_ID;
            l_pro_tbl(y).PAYMENT_SCHEDULE_ID := l_PAYMENT_SCHEDULE_ID;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	    LogMessage(G_PKG_NAME || '.' || l_api_name || '------------------------');
    	    LogMessage(G_PKG_NAME || '.' || l_api_name || ':found promise ' || y);
    	    LogMessage(G_PKG_NAME || '.' || l_api_name || ':PROMISE_DETAIL_ID = ' || l_pro_tbl(y).PROMISE_DETAIL_ID);
END IF;

        END LOOP;

        nCount := l_pro_tbl.count;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        LogMessage(G_PKG_NAME || '.' || l_api_name || ':Total count of found promises = ' || nCount);
END IF;

        if nCount > 0 then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	    LogMessage(G_PKG_NAME || '.' || l_api_name || ':Doing FIFO promise applications...');
END IF;
            APPLY_PROMISES_FIFO(
    	        P_API_VERSION => 1.0,
    	        P_INIT_MSG_LIST	=> FND_API.G_TRUE,
    	        P_COMMIT => FND_API.G_TRUE,
    	        P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
    	        X_RETURN_STATUS	=> l_return_status,
    	        X_MSG_COUNT => l_msg_count,
    	        X_MSG_DATA => l_msg_data,
                P_PROMISES_TBL => l_pro_tbl,
                P_TYPE => 'INV');
        else
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	    LogMessage(G_PKG_NAME || '.' || l_api_name || ':no promises found - do not call FIFO');
END IF;
        end if;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        LogMessage(G_PKG_NAME || '.' || l_api_name || ':Updating all COLLECTABLE and PENDING promises for delinquencies that have status CURRENT to status FULFILLED ...');
END IF;

	UPDATE iex_promise_details
	SET STATUS = 'FULFILLED',
	last_update_date = sysdate,
	last_updated_by = G_USER_ID
	WHERE
	promise_detail_id in
	(select prd.promise_detail_id
	from iex_promise_details prd, iex_delinquencies del, ar_payment_schedules aps --added for Bug 6446848 08-Dec-2008 barathsr
	where prd.delinquency_id is not null and
	prd.delinquency_id = del.delinquency_id and
        prd.org_id = del.org_id and --Added for bug 7237026 barathsr 31-Dec-2008
	del.payment_schedule_id=aps.payment_schedule_id and --added for Bug 6446848 08-Dec-2008 barathsr
	prd.status in ('COLLECTABLE', 'PENDING') and
	del.status = 'CURRENT' and
        aps.amount_due_remaining = 0);--added for Bug 6446848 08-Dec-2008 barathsr


IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || sql%rowcount || ' rows is updated');
END IF;

    elsif P_TYPE = 'ACC' then	-- processing all promises on account

        vSQL := 'SELECT ' ||
		'PRD.promise_detail_id pro, ' ||
		'PRD.creation_date, ' ||
		'nvl(PRD.broken_on_date, PRD.promise_date), ' ||
		'PRD.status, ' ||
		'PRD.state, ' ||
		'PRD.promise_amount, ' ||
		'PRD.amount_due_remaining, ' ||
		'PRD.cust_account_id ' ||
		'FROM ' ||
		'iex_promise_details prd,' ||
		'AR_SYSTEM_PARAMETERS asp ' || --Added for bug 7237026 barathsr 31-Dec-2008
		'WHERE ' ||
		'prd.delinquency_id is null and ' ||
		'prd.CNSLD_INVOICE_ID is null and ' ||
		'prd.CONTRACT_ID is null and ' ||
		'prd.status = ''COLLECTABLE'' and ' ||
		'prd.org_id = asp.org_id ' || --Added for bug 7237026 barathsr 31-Dec-2008
        	'order by PRD.promise_date';

        open promise_cur for vSQL;
        y := 0;
        LOOP
	    fetch promise_cur into
		l_PROMISE_DETAIL_ID,
                l_CREATION_DATE,
                l_PROMISE_DATE,
                l_STATUS,
                l_STATE,
                l_PROMISE_AMOUNT,
                l_AMOUNT_DUE_REMAINING,
                l_CUST_ACCOUNT_ID;
	        exit when promise_cur%NOTFOUND;

            y := y+1;
            l_pro_tbl(y).PROMISE_DETAIL_ID := l_PROMISE_DETAIL_ID;
            l_pro_tbl(y).CREATION_DATE := l_CREATION_DATE;
            l_pro_tbl(y).PROMISE_DATE := l_PROMISE_DATE;
            l_pro_tbl(y).STATUS := l_STATUS;
            l_pro_tbl(y).STATE := l_STATE;
            l_pro_tbl(y).PROMISE_AMOUNT := l_PROMISE_AMOUNT;
            l_pro_tbl(y).AMOUNT_DUE_REMAINING := l_AMOUNT_DUE_REMAINING;
            l_pro_tbl(y).CUST_ACCOUNT_ID := l_CUST_ACCOUNT_ID;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	    LogMessage(G_PKG_NAME || '.' || l_api_name || '------------------------');
    	    LogMessage(G_PKG_NAME || '.' || l_api_name || ':found promise ' || y);
    	    LogMessage(G_PKG_NAME || '.' || l_api_name || ':PROMISE_DETAIL_ID = ' || l_pro_tbl(y).PROMISE_DETAIL_ID);
END IF;

        END LOOP;

        nCount := l_pro_tbl.count;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        LogMessage(G_PKG_NAME || '.' || l_api_name || ':Total count of found promises = ' || nCount);
END IF;

        if nCount > 0 then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            LogMessage(G_PKG_NAME || '.' || l_api_name || ':Doing FIFO promise applications...');
END IF;
            APPLY_PROMISES_FIFO(
    	        P_API_VERSION => 1.0,
    	        P_INIT_MSG_LIST	=> FND_API.G_TRUE,
    	        P_COMMIT => FND_API.G_TRUE,
    	        P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
    	        X_RETURN_STATUS	=> l_return_status,
    	        X_MSG_COUNT => l_msg_count,
    	        X_MSG_DATA => l_msg_data,
                P_PROMISES_TBL => l_pro_tbl,
                P_TYPE => 'ACC');
        else
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	    LogMessage(G_PKG_NAME || '.' || l_api_name || ':no promises found - do not call FIFO');
END IF;
        end if;

    elsif P_TYPE = 'CNTR' then	-- processing all promises on contracts

        vSQL := 'SELECT ' ||
		 'PRD.promise_detail_id, ' ||
		 'PRD.creation_date, ' ||
		 'nvl(PRD.broken_on_date, PRD.promise_date), ' ||
		 'PRD.status, ' ||
		 'PRD.state, ' ||
		 'PRD.promise_amount, ' ||
		 'PRD.amount_due_remaining, ' ||
		 'PRD.contract_id ' ||
		 'FROM ' ||
		 'iex_promise_details prd, ' ||
		 'AR_SYSTEM_PARAMETERS asp ' || --Added for bug 7237026 barathsr 31-Dec-2008
		 'WHERE ' ||
		 'prd.contract_id is not null and ' ||
		 'prd.status = ''COLLECTABLE'' and ' ||
		 'prd.org_id = asp.org_id '||--Added for bug 7237026 barathsr 31-Dec-2008
                 'order by PRD.promise_date';

        open promise_cur for vSQL;
        y := 0;
        LOOP
	    fetch promise_cur into
	 	l_PROMISE_DETAIL_ID,
                l_CREATION_DATE,
                l_PROMISE_DATE,
                l_STATUS,
                l_STATE,
                l_PROMISE_AMOUNT,
                l_AMOUNT_DUE_REMAINING,
                l_CONTRACT_ID;
	        exit when promise_cur%NOTFOUND;

            y := y+1;
            l_pro_tbl(y).PROMISE_DETAIL_ID := l_PROMISE_DETAIL_ID;
            l_pro_tbl(y).CREATION_DATE := l_CREATION_DATE;
            l_pro_tbl(y).PROMISE_DATE := l_PROMISE_DATE;
            l_pro_tbl(y).STATUS := l_STATUS;
            l_pro_tbl(y).STATE := l_STATE;
            l_pro_tbl(y).PROMISE_AMOUNT := l_PROMISE_AMOUNT;
            l_pro_tbl(y).AMOUNT_DUE_REMAINING := l_AMOUNT_DUE_REMAINING;
            l_pro_tbl(y).CONTRACT_ID := l_CONTRACT_ID;


IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	    LogMessage(G_PKG_NAME || '.' || l_api_name || '------------------------');
    	    LogMessage(G_PKG_NAME || '.' || l_api_name || ':found promise ' || y);
    	    LogMessage(G_PKG_NAME || '.' || l_api_name || ':PROMISE_DETAIL_ID = ' || l_pro_tbl(y).PROMISE_DETAIL_ID);
END IF;

        END LOOP;

        nCount := l_pro_tbl.count;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        LogMessage(G_PKG_NAME || '.' || l_api_name || ':Total count of found promises = ' || nCount);
END IF;

        if nCount > 0 then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	    LogMessage(G_PKG_NAME || '.' || l_api_name || ':Doing FIFO promise applications...');
END IF;
            APPLY_PROMISES_FIFO(
    	        P_API_VERSION => 1.0,
    	        P_INIT_MSG_LIST	=> FND_API.G_TRUE,
    	        P_COMMIT => FND_API.G_TRUE,
    	        P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
    	        X_RETURN_STATUS	=> l_return_status,
    	        X_MSG_COUNT => l_msg_count,
    	        X_MSG_DATA => l_msg_data,
                P_PROMISES_TBL => l_pro_tbl,
                P_TYPE => 'CNTR');
        else
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	    LogMessage(G_PKG_NAME || '.' || l_api_name || ':no promises found - do not call FIFO');
END IF;
        end if;

    end if;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    LogMessage(G_PKG_NAME || '.' || l_api_name || ':End of body');
END IF;
    -- END OF BODY OF API

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	LogMessage(G_PKG_NAME || '.' || l_api_name || ':Commited work');
END IF;
    END IF;

    x_return_status := l_return_status;
    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO PROCESS_PROMISES_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
      -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
      /*
      IEX_CONC_REQUEST_MSG_PKG.Log_Error(
            P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
            P_Procedure_name        => G_PKG_NAME || '.' || l_api_name,
            P_MESSAGE               => 'Failed to process promises');
      */
      -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      LogMessage(G_PKG_NAME || '.' || l_api_name || ': In G_EXC_ERROR exception. Failed to process promises');
END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO PROCESS_PROMISES_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
      -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
      /*
      IEX_CONC_REQUEST_MSG_PKG.Log_Error(
            P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
            P_Procedure_name        => G_PKG_NAME || '.' || l_api_name,
            P_MESSAGE               => 'Failed to process promises');
      */
      -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      LogMessage(G_PKG_NAME || '.' || l_api_name || ': In G_EXC_UNEXPECTED_ERROR exception. Failed to process promises');
END IF;
    WHEN OTHERS THEN
      ROLLBACK TO PROCESS_PROMISES_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
      -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
      /*
      IEX_CONC_REQUEST_MSG_PKG.Log_Error(
            P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
            P_Procedure_name        => G_PKG_NAME || '.' || l_api_name,
            P_MESSAGE               => 'Failed to process promises');
      */
      -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      LogMessage(G_PKG_NAME || '.' || l_api_name || ': In OTHERS exception. Failed to process promises');
END IF;
END;

/**********************
	This procedure implements FIFO application method for promises
***********************/
PROCEDURE APPLY_PROMISES_FIFO(
    P_API_VERSION		    	IN      NUMBER,
    P_INIT_MSG_LIST		    	IN      VARCHAR2,
    P_COMMIT				IN      VARCHAR2,
    P_VALIDATION_LEVEL	    		IN      NUMBER,
    X_RETURN_STATUS		    	OUT NOCOPY     VARCHAR2,
    X_MSG_COUNT				OUT NOCOPY     NUMBER,
    X_MSG_DATA	    	    		OUT NOCOPY     VARCHAR2,
    P_PROMISES_TBL              	IN OUT NOCOPY  IEX_PROMISES_BATCH_PUB.PROMISES_TBL,
    P_TYPE                          	IN      VARCHAR2)
IS
    l_api_name                      CONSTANT VARCHAR2(30) := 'APPLY_PROMISES_FIFO';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    vSQL			    varchar2(10000);
    -- start bug 3635087 gnramasa 10/07/07
    vSQL_pay_only		    varchar2(10000);
    vSQL_pay_adj		    varchar2(10000);
    l_adjustment_count              NUMBER := 0;
    l_adjustment_id                 NUMBER;
    l_adjusted_amount               NUMBER;
    l_adjusted_date                 DATE;
    l_adj_remaining_amount          NUMBER;
    -- End bug 3635087 gnramasa 10/07/07
    Type refCur is Ref Cursor;
    appl_cur			    refCur;
    l_appl_tbl			    IEX_PROMISES_BATCH_PUB.APPLS_TBL;
    i                               NUMBER;
    y                               NUMBER;
    x                               NUMBER;
    nCount                          NUMBER;
    nCount1                         NUMBER;
    l_receivable_application_id     NUMBER;
    l_ar_applied_amount             NUMBER;
    l_ar_remaining_amount           NUMBER;
    l_ar_apply_date                 DATE;
    l_callback_date                 DATE;
    l_status                        VARCHAR2(30);
    l_state	                    VARCHAR2(30);
    l_applied_appl_count	    NUMBER;


BEGIN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    LogMessage(G_PKG_NAME || '.' || l_api_name || ':Start');
END IF;

    -- Standard start of API savepoint
    SAVEPOINT APPLY_PROMISES_FIFO_PVT;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    LogMessage(G_PKG_NAME || '.' || l_api_name || ':Savepoint is established');
END IF;
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
    LogMessage(G_PKG_NAME || '.' || l_api_name || ':Start of body');
END IF;

    nCount := P_PROMISES_TBL.count;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    LogMessage(G_PKG_NAME || '.' || l_api_name || ':Total count of passed promises = ' || nCount);
END IF;

    FOR i in 1..nCount LOOP
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        LogMessage(G_PKG_NAME || '.' || l_api_name || ':---------------------------');
        LogMessage(G_PKG_NAME || '.' || l_api_name || ':Promise ' || i || ' details:');
    	LogMessage(G_PKG_NAME || '.' || l_api_name || ':PROMISE_DETAIL_ID = ' || P_PROMISES_TBL(i).PROMISE_DETAIL_ID);
    	LogMessage(G_PKG_NAME || '.' || l_api_name || ':CREATION_DATE = ' || P_PROMISES_TBL(i).CREATION_DATE);
    	LogMessage(G_PKG_NAME || '.' || l_api_name || ':nvl(BROKEN_ON_DATE, PROMISE_DATE) = ' || P_PROMISES_TBL(i).PROMISE_DATE);
    	LogMessage(G_PKG_NAME || '.' || l_api_name || ':PROMISE_AMOUNT = ' || P_PROMISES_TBL(i).PROMISE_AMOUNT);
    	LogMessage(G_PKG_NAME || '.' || l_api_name || ':AMOUNT_DUE_REMAINING = ' || P_PROMISES_TBL(i).AMOUNT_DUE_REMAINING);
    	LogMessage(G_PKG_NAME || '.' || l_api_name || ':STATUS = ' || P_PROMISES_TBL(i).STATUS);
    	LogMessage(G_PKG_NAME || '.' || l_api_name || ':STATE = ' || P_PROMISES_TBL(i).STATE);
END IF;

        if P_TYPE = 'INV' then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	    LogMessage(G_PKG_NAME || '.' || l_api_name || ':DELINQUENCY_ID = ' || P_PROMISES_TBL(i).DELINQUENCY_ID);
    	    LogMessage(G_PKG_NAME || '.' || l_api_name || ':PAYMENT_SCHEDULE_ID = ' || P_PROMISES_TBL(i).PAYMENT_SCHEDULE_ID);
END IF;
            -- start bug 3635087 gnramasa 10/07/07
            vSQL_pay_only := 'select ' ||
                'raa.receivable_application_id, ' ||
                'raa.amount_applied, ' ||
                'raa.apply_date, ' ||
                'raa.amount_applied - nvl(sum(pax.amount_applied), 0), ' ||
		'NULL, ' ||
		'NULL, ' ||
		'NULL, ' ||
		'NULL ' ||
                'from ' ||
                'AR_RECEIVABLE_APPLICATIONS raa, ' ||
                'IEX_prd_appl_xref pax ' ||
                'where ' ||
                '(trunc(raa.apply_date) between trunc(:PROMISE_CR_DATE) and trunc(sysdate)) and ' ||
                'raa.status = ''APP'' and ' ||
                'raa.amount_applied > 0 and ' ||
                'raa.reversal_gl_date is null and ' ||
                'raa.applied_payment_schedule_id = :PSA_ID and ' ||
                'raa.receivable_application_id = pax.receivable_application_id(+) and ' ||
                'raa.receivable_application_id not in ' ||
                '(select receivable_application_id ' ||
                'from IEX_prd_appl_xref where promise_detail_id = :PROMISE_ID and ' ||
                'REVERSED_FLAG is null and REVERSED_DATE is null and receivable_application_id is NOT NULL) ' ||
                'group by raa.receivable_application_id, raa.amount_applied, raa.apply_date ' ||
                'order by raa.receivable_application_id';

	    vSQL_pay_adj := 'SELECT ' ||
	          'raa.receivable_application_id, ' ||
		  'raa.amount_applied, ' ||
		  'raa.apply_date, ' ||
		  'raa.amount_applied -nvl(SUM(pax.amount_applied),   0), ' ||
		  'NULL, ' ||
		  'NULL, ' ||
		  'NULL, ' ||
		  'NULL ' ||
		'FROM ar_receivable_applications raa, ' ||
		  'iex_prd_appl_xref pax ' ||
		'WHERE(TRUNC(raa.apply_date) BETWEEN TRUNC(:promise_cr_date) ' ||
		 'AND TRUNC(sysdate)) ' ||
		 'AND raa.status = ''APP'' ' ||
		 'AND raa.amount_applied > 0 ' ||
		 'AND raa.reversal_gl_date IS NULL ' ||
		 'AND raa.applied_payment_schedule_id = :psa_id ' ||
		 'AND raa.receivable_application_id = pax.receivable_application_id(+) ' ||
		 'AND raa.receivable_application_id NOT IN ' ||
		  '(SELECT receivable_application_id ' ||
		   'FROM iex_prd_appl_xref ' ||
		   'WHERE promise_detail_id = :promise_id ' ||
		   'AND reversed_flag IS NULL ' ||
		   'AND reversed_date IS NULL AND receivable_application_id is NOT NULL) ' ||
		'GROUP BY raa.receivable_application_id, ' ||
		  'raa.amount_applied, ' ||
		  'raa.apply_date ' ||
		'UNION ALL ' ||
		'SELECT NULL, ' ||
		  'NULL, ' ||
		  'NULL, ' ||
		  'NULL, ' ||
		  'ara.adjustment_id, ' ||
		  '-ara.amount, ' ||
		  'ara.apply_date, ' ||
		  '-ara.amount -nvl(SUM(pax.amount_applied),   0) ' ||
		'FROM ar_adjustments ara, ' ||
		  'iex_prd_appl_xref pax ' ||
		'WHERE(TRUNC(ara.apply_date) BETWEEN TRUNC(:promise_cr_date) ' ||
		 'AND TRUNC(sysdate)) ' ||
		 'AND ara.status = ''A'' ' ||
		 'AND ara.amount < 0 ' ||
		 'AND ara.payment_schedule_id = :psa_id ' ||
		 'AND ara.adjustment_id = pax.adjustment_id(+) ' ||
		 'AND ara.adjustment_id NOT IN ' ||
		  '(SELECT adjustment_id ' ||
		   'FROM iex_prd_appl_xref ' ||
		   'WHERE promise_detail_id = :promise_id AND adjustment_id is NOT NULL)' ||
		 'GROUP BY ara.adjustment_id, ' ||
		  'ara.amount, ' ||
		  'ara.apply_date';

	    SELECT count(adjustment_id)
	    into l_adjustment_count
	    FROM ar_adjustments
	    WHERE PAYMENT_SCHEDULE_ID = P_PROMISES_TBL(i).PAYMENT_SCHEDULE_ID;

	    IF l_adjustment_count = 0 THEN
		vSQL := vSQL_pay_only;
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			LogMessage(G_PKG_NAME || '.' || l_api_name || 'No adjustment exist for this invoice, vSQL := vSQL_pay_only' );
		END IF;
	    ELSE
	        vSQL := vSQL_pay_adj;
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			LogMessage(G_PKG_NAME || '.' || l_api_name || 'Adjustments exist for this invoice, vSQL := vSQL_pay_adj' );
		END IF;
	    END IF;

        elsif P_TYPE = 'ACC' then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	    LogMessage(G_PKG_NAME || '.' || l_api_name || ':CUST_ACCOUNT_ID = ' || P_PROMISES_TBL(i).CUST_ACCOUNT_ID);
END IF;
            vSQL := 'select ' ||
                'raa.receivable_application_id, ' ||
                'raa.amount_applied, ' ||
                'raa.apply_date, ' ||
                'raa.amount_applied - nvl(sum(pax.amount_applied), 0), ' ||
		'NULL, ' ||
		'NULL, ' ||
		'NULL, ' ||
		'NULL ' ||
                'from ' ||
                'AR_RECEIVABLE_APPLICATIONS raa, ' ||
                'IEX_prd_appl_xref pax, ' ||
                'AR_PAYMENT_SCHEDULES psa ' ||
                'where ' ||
                '(trunc(raa.apply_date) between trunc(:PROMISE_CR_DATE) and trunc(sysdate)) and ' ||
                'raa.status = ''ACC'' and ' ||
                'raa.amount_applied > 0 and ' ||
                'raa.reversal_gl_date is null and ' ||
                'raa.payment_schedule_id = psa.payment_schedule_id and ' ||
                'psa.customer_id = :CUSTOMER_ID and ' ||
                'raa.receivable_application_id = pax.receivable_application_id(+) and ' ||
                'raa.receivable_application_id not in ' ||
                '(select receivable_application_id ' ||
                'from IEX_prd_appl_xref where promise_detail_id = :PROMISE_ID and ' ||
                'REVERSED_FLAG is null and REVERSED_DATE is null and receivable_application_id is NOT NULL) ' ||
                'group by raa.receivable_application_id, raa.amount_applied, raa.apply_date ' ||
                'order by raa.receivable_application_id';

        elsif P_TYPE = 'CNTR' then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	    LogMessage(G_PKG_NAME || '.' || l_api_name || ':CONTRACT_ID = ' || P_PROMISES_TBL(i).CONTRACT_ID);
END IF;
           /* replaced the statement just below to fix a perf bug 4930383
            vSQL := 'select ' ||
                'raa.receivable_application_id, ' ||
                'raa.amount_applied, ' ||
                'raa.apply_date, ' ||
                'raa.amount_applied - nvl(sum(pax.amount_applied), 0) ' ||
                'from ' ||
                'IEX_OKL_PAYMENTS_V raa, ' ||
                'IEX_prd_appl_xref pax ' ||
                'where ' ||
                '(trunc(raa.apply_date) between trunc(:PROMISE_CR_DATE) and trunc(sysdate)) and ' ||
                'raa.amount_applied > 0 and ' ||
                'raa.reversal_gl_date is null and ' ||
                'raa.contract_id = :CONTRACT_ID and ' ||
                'raa.receivable_application_id = pax.receivable_application_id(+) and ' ||
                'raa.receivable_application_id not in ' ||
                '(select receivable_application_id ' ||
                'from IEX_prd_appl_xref where promise_detail_id = :PROMISE_ID and ' ||
                'REVERSED_FLAG is null and REVERSED_DATE is null) ' ||
                'group by raa.receivable_application_id, raa.amount_applied, raa.apply_date ' ||
                'order by raa.receivable_application_id';
          */

            vSQL := ' Select '||
                    '   ARAPP.RECEIVABLE_APPLICATION_ID, '||
                    '   ARAPP.AMOUNT_APPLIED, '||
                    '   ARAPP.APPLY_DATE, '||
                    '   ARAPP.AMOUNT_APPLIED - nvl(sum(PAX.amount_applied), 0), '||
		    '   NULL, ' ||
		    '   NULL, ' ||
		    '   NULL, ' ||
		    '   NULL ' ||
                    ' From ' ||
                    '  OKL_CNSLD_AR_STRMS_B CNSLD, '||
                    '  AR_RECEIVABLE_APPLICATIONS ARAPP, '||
                    '  AR_PAYMENT_SCHEDULES PMTSCH, '||
                    '  IEX_prd_appl_xref PAX '||
                    ' Where '||
                    '       CNSLD.khr_id = :CONTRACT_ID '||
                    '   and CNSLD.receivables_invoice_id = PMTSCH.customer_trx_id '||
                    '   and PMTSCH.class = ''INV''  '||
                    '   and PMTSCH.payment_schedule_id = ARAPP.applied_payment_schedule_id '||
                    '   and (trunc(ARAPP.apply_date) between trunc(:PROMISE_CR_DATE) and trunc(sysdate)) '||
                    '   and ARAPP.amount_applied > 0 '||
                    '   and ARAPP.reversal_gl_date is null '||
                    '   and ARAPP.receivable_application_id = PAX.receivable_application_id(+) '||
                    '   and ARAPP.receivable_application_id not in (select receivable_application_id from  IEX_prd_appl_xref ' ||
                    '   where promise_detail_id = :PROMISE_ID and REVERSED_FLAG is null and REVERSED_DATE is null ' ||
		    '   and receivable_application_id is NOT NULL) '||
                    '   group by ARAPP.receivable_application_id, ARAPP.amount_applied, ARAPP.apply_date '||
                    '   order by ARAPP.receivable_application_id ';

        end if;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	LogMessage(G_PKG_NAME || '.' || l_api_name || ':Searching for applications to apply to the promise ' || P_PROMISES_TBL(i).PROMISE_DETAIL_ID);
END IF;

        if P_TYPE = 'INV' then
	    IF l_adjustment_count = 0 THEN
		open appl_cur for vSQL using
                P_PROMISES_TBL(i).CREATION_DATE,
                P_PROMISES_TBL(i).PAYMENT_SCHEDULE_ID,
                P_PROMISES_TBL(i).PROMISE_DETAIL_ID;
	    ELSE
	        open appl_cur for vSQL using
                P_PROMISES_TBL(i).CREATION_DATE,
                P_PROMISES_TBL(i).PAYMENT_SCHEDULE_ID,
                P_PROMISES_TBL(i).PROMISE_DETAIL_ID,
                P_PROMISES_TBL(i).CREATION_DATE,
                P_PROMISES_TBL(i).PAYMENT_SCHEDULE_ID,
                P_PROMISES_TBL(i).PROMISE_DETAIL_ID;
	    END IF;

        elsif P_TYPE = 'ACC' then
            open appl_cur for vSQL using
                P_PROMISES_TBL(i).CREATION_DATE,
                P_PROMISES_TBL(i).CUST_ACCOUNT_ID,
                P_PROMISES_TBL(i).PROMISE_DETAIL_ID;
        elsif P_TYPE = 'CNTR' then
            open appl_cur for vSQL using
                P_PROMISES_TBL(i).CREATION_DATE,
                P_PROMISES_TBL(i).CONTRACT_ID,
                P_PROMISES_TBL(i).PROMISE_DETAIL_ID;
        end if;

        y := 0;
        l_appl_tbl.delete;
        LOOP

            fetch appl_cur into
                l_receivable_application_id,
                l_ar_applied_amount,
                l_ar_apply_date,
                l_ar_remaining_amount,
		l_adjustment_id,
		l_adjusted_amount,
		l_adjusted_date,
		l_adj_remaining_amount;
            exit when appl_cur%NOTFOUND;

            if l_ar_remaining_amount > 0 or l_adj_remaining_amount > 0 then
                y := y+1;
                l_appl_tbl(y).receivable_application_id := l_receivable_application_id;
                l_appl_tbl(y).ar_applied_amount := l_ar_applied_amount;
                l_appl_tbl(y).ar_remaining_amount := l_ar_remaining_amount;
                l_appl_tbl(y).ar_apply_date := l_ar_apply_date;
		l_appl_tbl(y).adjustment_id := l_adjustment_id;
		l_appl_tbl(y).ar_adjusted_amount := l_adjusted_amount;
		l_appl_tbl(y).ar_adj_remaining_amount := l_adj_remaining_amount;
		l_appl_tbl(y).ar_adjusted_date := l_adjusted_date;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IF l_appl_tbl(y).receivable_application_id IS NOT NULL THEN
    	        LogMessage(G_PKG_NAME || '.' || l_api_name || ':found receivable_application_id = ' || l_appl_tbl(y).receivable_application_id);
    	        LogMessage(G_PKG_NAME || '.' || l_api_name || ':ar_applied_amount = ' || l_appl_tbl(y).ar_applied_amount);
    	        LogMessage(G_PKG_NAME || '.' || l_api_name || ':ar_remaining_amount = ' || l_appl_tbl(y).ar_remaining_amount);
    	        LogMessage(G_PKG_NAME || '.' || l_api_name || ':ar_apply_date = ' || l_appl_tbl(y).ar_apply_date);
    ELSE
                LogMessage(G_PKG_NAME || '.' || l_api_name || ':found adjustment_id = ' || l_appl_tbl(y).adjustment_id);
    	        LogMessage(G_PKG_NAME || '.' || l_api_name || ':ar_adjusted_amount = ' || l_appl_tbl(y).ar_adjusted_amount);
    	        LogMessage(G_PKG_NAME || '.' || l_api_name || ':ar_adj_remaining_amount = ' || l_appl_tbl(y).ar_adj_remaining_amount);
    	        LogMessage(G_PKG_NAME || '.' || l_api_name || ':ar_adjusted_date = ' || l_appl_tbl(y).ar_adjusted_date);
    END IF;
END IF;
            end if;

        END LOOP;

        nCount1 := l_appl_tbl.count;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        LogMessage(G_PKG_NAME || '.' || l_api_name || ':Total found ' || nCount1 || ' available applications');
END IF;

        if nCount1 > 0 then     -- do applications
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            LogMessage(G_PKG_NAME || '.' || l_api_name || ':applying...');
END IF;

            FOR y in 1..nCount1 LOOP

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	        LogMessage(G_PKG_NAME || '.' || l_api_name || ':processing application ' || y || ' Details:');
    	        LogMessage(G_PKG_NAME || '.' || l_api_name || ':receivable_application_id = ' || l_appl_tbl(y).receivable_application_id);
    	        LogMessage(G_PKG_NAME || '.' || l_api_name || ':ar_applied_amount = ' || l_appl_tbl(y).ar_applied_amount);
    	        LogMessage(G_PKG_NAME || '.' || l_api_name || ':ar_remaining_amount = ' || l_appl_tbl(y).ar_remaining_amount);
    	        LogMessage(G_PKG_NAME || '.' || l_api_name || ':ar_apply_date = ' || l_appl_tbl(y).ar_apply_date);
		LogMessage(G_PKG_NAME || '.' || l_api_name || ':adjustment_id = ' || l_appl_tbl(y).adjustment_id);
    	        LogMessage(G_PKG_NAME || '.' || l_api_name || ':ar_adjusted_amount = ' || l_appl_tbl(y).ar_adjusted_amount);
    	        LogMessage(G_PKG_NAME || '.' || l_api_name || ':ar_adj_remaining_amount = ' || l_appl_tbl(y).ar_adj_remaining_amount);
    	        LogMessage(G_PKG_NAME || '.' || l_api_name || ':ar_adjusted_date = ' || l_appl_tbl(y).ar_adjusted_date);
    	        LogMessage(G_PKG_NAME || '.' || l_api_name || ':pro_applied_amount = ' || l_appl_tbl(y).pro_applied_amount);
END IF;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	        LogMessage(G_PKG_NAME || '.' || l_api_name || ':comparing application remaining amount = ' || l_appl_tbl(y).ar_remaining_amount);
		LogMessage(G_PKG_NAME || '.' || l_api_name || ':comparing adjustment remaining amount = ' || l_appl_tbl(y).ar_adj_remaining_amount);
    	        LogMessage(G_PKG_NAME || '.' || l_api_name || ':and promise remaining amount = ' || P_PROMISES_TBL(i).AMOUNT_DUE_REMAINING);
END IF;
             if l_appl_tbl(y).ar_remaining_amount > 0 THEN
                if l_appl_tbl(y).ar_remaining_amount > P_PROMISES_TBL(i).AMOUNT_DUE_REMAINING then
                    l_appl_tbl(y).pro_applied_amount := P_PROMISES_TBL(i).AMOUNT_DUE_REMAINING;
                elsif l_appl_tbl(y).ar_remaining_amount <= P_PROMISES_TBL(i).AMOUNT_DUE_REMAINING then
                    l_appl_tbl(y).pro_applied_amount := l_appl_tbl(y).ar_remaining_amount;
                end if;
	     elsif l_appl_tbl(y).ar_adj_remaining_amount > 0 THEN
	        if l_appl_tbl(y).ar_adj_remaining_amount > P_PROMISES_TBL(i).AMOUNT_DUE_REMAINING then
                    l_appl_tbl(y).pro_applied_amount := P_PROMISES_TBL(i).AMOUNT_DUE_REMAINING;
                elsif l_appl_tbl(y).ar_adj_remaining_amount <= P_PROMISES_TBL(i).AMOUNT_DUE_REMAINING then
                    l_appl_tbl(y).pro_applied_amount := l_appl_tbl(y).ar_adj_remaining_amount;
                end if;
	     end if;

                P_PROMISES_TBL(i).AMOUNT_DUE_REMAINING := P_PROMISES_TBL(i).AMOUNT_DUE_REMAINING - l_appl_tbl(y).pro_applied_amount;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	        LogMessage(G_PKG_NAME || '.' || l_api_name || ':we will apply amount = ' || l_appl_tbl(y).pro_applied_amount);
    	        LogMessage(G_PKG_NAME || '.' || l_api_name || ':promise remaining amount after this application = ' || P_PROMISES_TBL(i).AMOUNT_DUE_REMAINING);
END IF;

   	        l_applied_appl_count := y;
                if P_PROMISES_TBL(i).AMOUNT_DUE_REMAINING = 0 then   -- we are done appliyng to the promise
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	            LogMessage(G_PKG_NAME || '.' || l_api_name || ':promise fulfilled by amount - exiting loop');
END IF;
                    exit;
                else    -- we are not done yet. process next application
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	            LogMessage(G_PKG_NAME || '.' || l_api_name || ':promise still not fulfilled by amount - process next application');
END IF;
                end if;

            END LOOP;

            if P_PROMISES_TBL(i).AMOUNT_DUE_REMAINING > 0 then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	    	LogMessage(G_PKG_NAME || '.' || l_api_name || ':no more available applications');
END IF;
    	    end if;

            l_callback_date := null;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            LogMessage(G_PKG_NAME || '.' || l_api_name || ':figuring out promise status and state ...');
END IF;

            if trunc(sysdate) > trunc(P_PROMISES_TBL(i).PROMISE_DATE) then /* the promise is in the past */
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                LogMessage(G_PKG_NAME || '.' || l_api_name || ':the promise is in the past');
END IF;

                if P_PROMISES_TBL(i).AMOUNT_DUE_REMAINING = 0 then   -- promise is fulfilled by amount
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                    LogMessage(G_PKG_NAME || '.' || l_api_name || ':the promise is fulfilled by amount - setting status FILFILLED');
END IF;
                    l_status := 'FULFILLED';

                    if (trunc(l_appl_tbl(l_applied_appl_count).ar_apply_date) > trunc(P_PROMISES_TBL(i).PROMISE_DATE))
		    or (trunc(l_appl_tbl(l_applied_appl_count).ar_adjusted_date) > trunc(P_PROMISES_TBL(i).PROMISE_DATE))
		    then  -- payments are late
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   	                LogMessage(G_PKG_NAME || '.' || l_api_name || ':payments are late - setting state to BROKEN_PROMISE');
END IF;
                    	l_state := 'BROKEN_PROMISE';
                    else  -- payment on time
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	            	LogMessage(G_PKG_NAME || '.' || l_api_name || ':payments are on time - setting state PROMISE');
END IF;
                    	l_state := 'PROMISE';
                    end if;

                else   -- promise is not fulfilled by amount
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                    LogMessage(G_PKG_NAME || '.' || l_api_name || ':the promise is not fulfilled by amount - leaving status COLLECTABLE');
END IF;
                    l_status := 'COLLECTABLE';

                    if P_PROMISES_TBL(i).STATE = 'PROMISE' then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                    	LogMessage(G_PKG_NAME || '.' || l_api_name || ':the promise state is PROMISE - setting state to BROKEN_PROMISE');
END IF;
                        l_state := 'BROKEN_PROMISE';
		        Get_Callback_Date(p_promise_date => P_PROMISES_TBL(i).PROMISE_DATE, x_callback_date => l_callback_date);
                    elsif P_PROMISES_TBL(i).STATE = 'BROKEN_PROMISE' then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                        LogMessage(G_PKG_NAME || '.' || l_api_name || ':the promise state is already BROKEN_PROMISE - leave it BROKEN_PROMISE');
END IF;
                        l_state := 'BROKEN_PROMISE';
                    end if;
                end if;

            else /* promise is in the future */

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                LogMessage(G_PKG_NAME || '.' || l_api_name || ':the promise is in the future - leaving state PROMISE');
END IF;
                l_state := 'PROMISE';
                if P_PROMISES_TBL(i).AMOUNT_DUE_REMAINING = 0 then   -- promise is fulfilled by amount
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                    LogMessage(G_PKG_NAME || '.' || l_api_name || ':the promise is fulfilled by amount - setting status to FULFILLED');
END IF;
                    l_status := 'FULFILLED';
                else
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                    LogMessage(G_PKG_NAME || '.' || l_api_name || ':the promise not fulfilled by amount - leaving status COLLECTABLE');
END IF;
                    l_status := 'COLLECTABLE';
                end if;

            end if;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	    LogMessage(G_PKG_NAME || '.' || l_api_name || '......................');
    	    LogMessage(G_PKG_NAME || '.' || l_api_name || ':will set promise status to ' || l_status);
    	    LogMessage(G_PKG_NAME || '.' || l_api_name || ':will set promise state to ' || l_state);
    	    LogMessage(G_PKG_NAME || '.' || l_api_name || ':Updating iex_promise_details with promise_detail_id = ' || P_PROMISES_TBL(i).PROMISE_DETAIL_ID || ' set:');
    	    LogMessage(G_PKG_NAME || '.' || l_api_name || ':amount_due_remaining ' || P_PROMISES_TBL(i).AMOUNT_DUE_REMAINING);
END IF;

            if l_callback_date is not null then
		UPDATE iex_promise_details
		SET amount_due_remaining = P_PROMISES_TBL(i).AMOUNT_DUE_REMAINING,
                STATUS = l_status,
                STATE = l_state,
		CALLBACK_CREATED_YN = 'N',
		CALLBACK_DATE = l_callback_date,
		last_update_date = sysdate,
		last_updated_by = G_USER_ID
		WHERE promise_detail_id = P_PROMISES_TBL(i).PROMISE_DETAIL_ID;
            else
		UPDATE iex_promise_details
		SET amount_due_remaining = P_PROMISES_TBL(i).AMOUNT_DUE_REMAINING,
               	STATUS = l_status,
                STATE = l_state,
		last_update_date = sysdate,
		last_updated_by = G_USER_ID
		WHERE promise_detail_id = P_PROMISES_TBL(i).PROMISE_DETAIL_ID;
            end if;

            if (sql%notfound) then
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		    LogMessage(G_PKG_NAME || '.' || l_api_name || ':Failed to update iex_promise_details');
		END IF;
		-- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
		/*
    		    IEX_CONC_REQUEST_MSG_PKG.Log_Error(
                    	P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
                   	P_Procedure_name    => G_PKG_NAME || '.' || l_api_name,
                   	P_MESSAGE           => 'Failed to update iex_promise_details');
                 */
                 -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
	    else
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		    LogMessage(G_PKG_NAME || '.' || l_api_name || ':update successfull');
		END IF;
	    end if;

	    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	    LogMessage(G_PKG_NAME || '.' || l_api_name || ':Inserting into iex_prd_appl_xref values:');
	    END IF;

            FOR x in 1..l_applied_appl_count LOOP
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			LogMessage(G_PKG_NAME || '.' || l_api_name || ':record ' || x);
			LogMessage(G_PKG_NAME || '.' || l_api_name || ':PROMISE_DETAIL_ID = ' || P_PROMISES_TBL(i).PROMISE_DETAIL_ID);
			LogMessage(G_PKG_NAME || '.' || l_api_name || ':RECEIVABLE_APPLICATION_ID ' || l_appl_tbl(x).receivable_application_id);
			LogMessage(G_PKG_NAME || '.' || l_api_name || ':AMOUNT_APPLIED ' || l_appl_tbl(x).pro_applied_amount);
			LogMessage(G_PKG_NAME || '.' || l_api_name || ':ADJUSTMENT_ID = ' || l_appl_tbl(x).adjustment_id);
    			LogMessage(G_PKG_NAME || '.' || l_api_name || ':AR_ADJUSTED_AMOUNT = ' || l_appl_tbl(x).ar_adjusted_amount);
    			LogMessage(G_PKG_NAME || '.' || l_api_name || ':PRO_APPLIED_AMOUNT = ' || l_appl_tbl(x).pro_applied_amount);
		END IF;

            	INSERT INTO iex_prd_appl_xref
            	(PRD_APPL_XREF_ID
                ,PROMISE_DETAIL_ID
                ,RECEIVABLE_APPLICATION_ID
                ,AMOUNT_APPLIED
                ,APPLY_DATE
                ,REVERSED_FLAG
                ,REVERSED_DATE
                ,LAST_UPDATE_DATE
             	,LAST_UPDATED_BY
             	,LAST_UPDATE_LOGIN
             	,CREATION_DATE
             	,CREATED_BY
             	,PROGRAM_ID
             	,OBJECT_VERSION_NUMBER
                ,SECURITY_GROUP_ID
                ,REQUEST_ID
		,ADJUSTMENT_ID)
             	VALUES (
             	iex_prd_appl_xref_s.NEXTVAL
             	,P_PROMISES_TBL(i).PROMISE_DETAIL_ID
                ,l_appl_tbl(x).receivable_application_id
                ,l_appl_tbl(x).pro_applied_amount
                ,sysdate
                ,null
                ,null
                ,SYSDATE
             	,G_USER_ID
             	,G_LOGIN_ID
             	,SYSDATE
             	,G_USER_ID
             	,G_PROGRAM_ID
             	,1.0
             	,null
             	,G_REQUEST_ID
		,l_appl_tbl(x).adjustment_id);
            END LOOP;
            -- End bug 3635087 gnramasa 10/07/07
	    -- reopen strategy for just got broken promise
            if l_callback_date is not null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	    	LogMessage(G_PKG_NAME || '.' || l_api_name || ': reopen strategy for promise ' || P_PROMISES_TBL(i).PROMISE_DETAIL_ID);
END IF;
		IEX_PROMISES_PUB.SET_STRATEGY(P_PROMISE_ID => P_PROMISES_TBL(i).PROMISE_DETAIL_ID,
	             	     			P_STATUS => 'OPEN');
	    end if;

        else    -- nothing to apply
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            LogMessage(G_PKG_NAME || '.' || l_api_name || ':nothing to apply');
            LogMessage(G_PKG_NAME || '.' || l_api_name || ':leaving promise status as it is - COLLECTABLE');
            LogMessage(G_PKG_NAME || '.' || l_api_name || ':figuring out promise state ...');
END IF;

            if P_PROMISES_TBL(i).STATE = 'PROMISE' then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                LogMessage(G_PKG_NAME || '.' || l_api_name || ':the promise state is still PROMISE');
END IF;

                if trunc(sysdate) > trunc(P_PROMISES_TBL(i).PROMISE_DATE) then /* the promise is in the past */
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                    LogMessage(G_PKG_NAME || '.' || l_api_name || ':the promise is in the past - setting state to BROKEN_PROMISE');
END IF;
                    l_state := 'BROKEN_PROMISE';
		    Get_Callback_Date(p_promise_date => P_PROMISES_TBL(i).PROMISE_DATE, x_callback_date => l_callback_date);

                    if l_callback_date is not null then
			UPDATE iex_promise_details
			SET state = l_state,
			CALLBACK_CREATED_YN = 'N',
			CALLBACK_DATE = l_callback_date,
			last_update_date = sysdate,
			last_updated_by = G_USER_ID
			WHERE promise_detail_id = P_PROMISES_TBL(i).PROMISE_DETAIL_ID;
                    else
			UPDATE iex_promise_details
			SET state = l_state,
			last_update_date = sysdate,
			last_updated_by = G_USER_ID
			WHERE promise_detail_id = P_PROMISES_TBL(i).PROMISE_DETAIL_ID;
                    end if;

		    if (sql%notfound) then
			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				LogMessage(G_PKG_NAME || '.' || l_api_name || ':Failed to update iex_promise_details with STATUS = BROKEN for promise_detail_id = ' || P_PROMISES_TBL(i).PROMISE_DETAIL_ID);
			END IF;
			-- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
			/*
    			IEX_CONC_REQUEST_MSG_PKG.Log_Error(
                   		P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
                   		P_Procedure_name        => G_PKG_NAME || '.' || l_api_name,
                   		P_MESSAGE               => 'Failed to update iex_promise_details with STATUS = BROKEN for promise_detail_id = ' || P_PROMISES_TBL(i).PROMISE_DETAIL_ID);
                         */
                         -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
		    else
			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			LogMessage(G_PKG_NAME || '.' || l_api_name || ':update successfull');
			END IF;

	    		-- reopen strategy for just got broken promise
            		if l_callback_date is not null then
				IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	    			LogMessage(G_PKG_NAME || '.' || l_api_name || ': reopen strategy for promise ' || P_PROMISES_TBL(i).PROMISE_DETAIL_ID);
				END IF;
				IEX_PROMISES_PUB.SET_STRATEGY(P_PROMISE_ID => P_PROMISES_TBL(i).PROMISE_DETAIL_ID,
	             	     					P_STATUS => 'OPEN');
	    		end if;
		    end if;
                else /* promise is in the future */
			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               		     LogMessage(G_PKG_NAME || '.' || l_api_name || ':the promise is in the future - leaving the promise state PROMISE');
			END IF;
                end if;
            elsif P_PROMISES_TBL(i).STATE = 'BROKEN_PROMISE' then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                LogMessage(G_PKG_NAME || '.' || l_api_name || ':the promise state is already BROKEN_PROMISE - nothing to change.');
END IF;
            end if;
        end if;
    END LOOP;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    LogMessage(G_PKG_NAME || '.' || l_api_name || ':End of body');
END IF;
    -- END OF BODY OF API

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	LogMessage(G_PKG_NAME || '.' || l_api_name || ':Commited work');
END IF;
    END IF;

    x_return_status := l_return_status;
    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data);

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO APPLY_PROMISES_FIFO_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
      -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
      /*
      IEX_CONC_REQUEST_MSG_PKG.Log_Error(
            P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
            P_Procedure_name        => G_PKG_NAME || '.' || l_api_name,
            P_MESSAGE               => 'Failed to do FIFO promise applications');
      */
      -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      LogMessage(G_PKG_NAME || '.' || l_api_name || ': In G_EXC_ERROR exception. Failed to do FIFO promise applications');
	END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO APPLY_PROMISES_FIFO_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
      -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
      /*
      IEX_CONC_REQUEST_MSG_PKG.Log_Error(
            P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
            P_Procedure_name        => G_PKG_NAME || '.' || l_api_name,
            P_MESSAGE               => 'Failed to do FIFO promise applications');
      */
      -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      LogMessage(G_PKG_NAME || '.' || l_api_name || ': In G_EXC_UNEXPECTED_ERROR exception. Failed to do FIFO promise applications');
	END IF;
    WHEN OTHERS THEN
      ROLLBACK TO APPLY_PROMISES_FIFO_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
      -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
      /*
      IEX_CONC_REQUEST_MSG_PKG.Log_Error(
            P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
            P_Procedure_name        => G_PKG_NAME || '.' || l_api_name,
            P_MESSAGE               => 'Failed to do FIFO promise applications');
      */
      -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   	   LogMessage(G_PKG_NAME || '.' || l_api_name || ': In OTHERS exception. Failed to do FIFO promise applications');
	END IF;
END;


    PROCEDURE Copy_Task_Ref_To_Tab(  p_counter BINARY_INTEGER,
                                     p_object_type_code varchar2,
                                     p_object_id number ) IS

    Cursor Get_Object_Type(l_object_type_code varchar2) IS
    select o.name,o.select_id,o.select_name,o.select_details,o.from_table,o.where_clause
    from jtf_objects_vl o,
       jtf_object_usages u
    where trunc(sysdate)
        between trunc(nvl(o.start_date_active, sysdate))
            and trunc(nvl(o.end_date_active, sysdate))
    and u.object_user_code = 'TASK'
    and u.object_code = o.object_code
    and o.object_code <> 'ESC'
    and o.object_code = l_object_type_code;

    l_select_id    VARCHAR2(200);
    l_select_name  VARCHAR2(200);
    l_select_details  VARCHAR2(2000);
    l_from_table   VARCHAR2(200);
    l_where_clause VARCHAR2(2000);
    l_CursorID     INTEGER;
    l_SelectStmt   VARCHAR2(2500);
    l_Dummy        INTEGER;
    l_object_name VARCHAR2(360);

    l_object_type             varchar2(80);
    l_object_details          varchar2(2000);
    l_current_block           varchar2(2000);

    BEGIN

        OPEN Get_Object_Type(p_object_type_code);
        FETCH Get_Object_Type INTO l_object_type,l_select_id,l_select_name,l_select_details,l_from_table,l_where_clause;
        if Get_Object_Type%FOUND then

               l_CursorID      := DBMS_SQL.OPEN_CURSOR;

               l_SelectStmt    := 'SELECT ' || l_select_name;

               IF (l_select_details IS NOT NULL) THEN
                    l_SelectStmt    := l_SelectStmt  || ',' || l_select_details;
               END IF;

               l_SelectStmt := l_SelectStmt || ' FROM '|| l_from_table || ' WHERE ' || l_where_clause;

               IF l_where_clause is not null THEN
                 l_SelectStmt    := l_SelectStmt  || ' AND ' ;
               END IF;

               l_SelectStmt    := l_SelectStmt  || l_select_id || ' = :source_object_id ';

               DBMS_SQL.PARSE(l_CursorID, l_SelectStmt, 1 );

               DBMS_SQL.BIND_VARIABLE(l_CursorID,':source_object_id',p_object_id);

               DBMS_SQL.DEFINE_COLUMN(l_CursorID, 1 , l_object_name , 360 );
               IF (l_select_details IS NOT NULL) THEN
                    DBMS_SQL.DEFINE_COLUMN(l_CursorID, 2 , l_object_details , 2000 );
               END IF;

               l_Dummy := DBMS_SQL.EXECUTE(l_CursorID);

               LOOP

                 IF DBMS_SQL.FETCH_ROWS(l_CursorID) = 0 THEN

                   EXIT;

                 END IF;

                 DBMS_SQL.COLUMN_VALUE(l_CursorID, 1 , l_object_name );
                 IF (l_select_details IS NOT NULL) THEN
                    DBMS_SQL.COLUMN_VALUE(l_CursorID, 2 , l_object_details );
                END IF;


               END LOOP;

               DBMS_SQL.CLOSE_CURSOR(l_CursorID);
        end if;
        CLOSE Get_Object_Type;


        G_TASK_REFERENCE_TAB(p_counter).object_type_code      := p_object_type_code;
        G_TASK_REFERENCE_TAB(p_counter).object_type_name      := l_object_type;
        G_TASK_REFERENCE_TAB(p_counter).object_name           := l_object_name;
        G_TASK_REFERENCE_TAB(p_counter).object_id             := p_object_id;
        G_TASK_REFERENCE_TAB(p_counter).object_details        := l_object_details;
        G_TASK_REFERENCE_TAB(p_counter).reference_code        := null;
        G_TASK_REFERENCE_TAB(p_counter).usage                 := null;


    END Copy_Task_Ref_To_Tab;


/**********************
	This procedure processing promise callbacks
***********************/
PROCEDURE PROCESS_PROMISE_CALLBACKS(
        p_api_version             IN 	NUMBER,
        p_init_msg_list           IN 	VARCHAR2,
        p_commit                  IN 	VARCHAR2,
	P_VALIDATION_LEVEL	  IN    NUMBER,
        x_return_status           OUT NOCOPY 	VARCHAR2,
        x_msg_count               OUT NOCOPY 	NUMBER,
        x_msg_data                OUT NOCOPY 	VARCHAR2)
IS
    	CURSOR C_GET_PROS IS
      	SELECT
      		pro.promise_detail_id,
             	hca.party_id,
             	pro.resource_id,
             	pro.cust_account_id,
		idel.customer_site_use_id,
		idel.delinquency_id
        FROM IEX_PROMISE_DETAILS pro, HZ_CUST_ACCOUNTS hca, iex_delinquencies_all idel
       	WHERE
       	pro.cust_account_id = hca.cust_account_id
	AND idel.delinquency_id(+) = pro.delinquency_id
       	AND pro.state = 'BROKEN_PROMISE'
        AND pro.CALLBACK_CREATED_YN = 'N'
        AND trunc(sysdate) >= trunc(pro.callback_date);

    	l_api_name              CONSTANT VARCHAR2(30) := 'PROCESS_PROMISE_CALLBACKS';
    	l_api_version           CONSTANT NUMBER := 1.0;
    	l_return_status         VARCHAR2(1);
    	l_msg_count             NUMBER;
    	l_msg_data              VARCHAR2(32767);

	l_promise_detail_id	NUMBER;
    	l_task_id         	NUMBER;
    	l_party_id         	NUMBER;
    	l_resource_id         	NUMBER;
    	l_task_name             varchar2(80) ;
    	l_task_type             varchar2(30) ;
    	l_task_status           varchar2(30) ;
    	l_description           varchar2(4000);
    	l_task_priority_name    varchar2(30) ;
    	l_task_priority_id      number;
    	l_owner_id              number;
    	l_owner                 varchar2(4000);
    	l_owner_type_code       varchar2(4000);
    	l_customer_id           number;
    	l_cust_account_id	number;
    	l_address_id            number;
	l_customer_site_use_id  number;
	l_delinquency_id	number;
	p_counter		number;
    	l_task_notes_tbl           JTF_TASKS_PUB.TASK_NOTES_TBL;
    	l_miss_task_assign_tbl     JTF_TASKS_PUB.TASK_ASSIGN_TBL;
    	l_miss_task_depends_tbl    JTF_TASKS_PUB.TASK_DEPENDS_TBL;
    	l_miss_task_rsrc_req_tbl   JTF_TASKS_PUB.TASK_RSRC_REQ_TBL;
    	l_miss_task_refer_tbl      JTF_TASKS_PUB.TASK_REFER_TBL;
    	l_miss_task_dates_tbl      JTF_TASKS_PUB.TASK_DATES_TBL;
    	l_miss_task_recur_rec      JTF_TASKS_PUB.TASK_RECUR_REC;
    	l_miss_task_contacts_tbl   JTF_TASKS_PUB.TASK_CONTACTS_TBL;

      --Begin bug 7317666 21-Nov-2008 barathsr
	cursor c_invalid_tasks is
	select tsk.task_id,
	tsk.object_version_number
	--,tsk.task_type_id,typ.name task_type, tsk.task_status_id,st.name,tsk.source_object_id
	from jtf_tasks_vl tsk,
	jtf_task_types_tl typ,
	jtf_task_statuses_vl st
	where tsk.source_object_type_code='IEX_PROMISE'
	and tsk.task_type_id=typ.task_type_id
	and typ.name='Callback'
	and tsk.task_status_id=st.task_status_id
	and  nvl(st.closed_flag,   'N') <>'Y'
	and  nvl(st.cancelled_flag,   'N')<>'Y'
	and  nvl(st.completed_flag,   'N')<>'Y'
	and exists(select 1 from iex_promise_details prd where tsk.source_object_id = prd.promise_detail_id
	and prd.status<>'COLLECTABLE');
	l_obj_version_number number;
     --End bug 7317666 21-Nov-2008 barathsr


  BEGIN

      	-- Standard Start of API savepoint
      	SAVEPOINT PROCESS_PROMISE_CALLBACKS_PUB;

      	-- Standard call to check for call compatibility.
    	IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    	END IF;

      	-- Initialize message list if p_init_msg_list is set to TRUE.
      	IF FND_API.to_Boolean( p_init_msg_list ) THEN
          	FND_MSG_PUB.initialize;
      	END IF;

	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      		LogMessage( 'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
	END IF;

      	-- Initialize API return status to SUCCESS
      	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- START OF BODY OF API
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	LogMessage( 'Start of ' || l_api_name || ' body');
END IF;

      	Open C_GET_PROS;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
  	LogMessage( 'OPEN C_GET_PROS');
END IF;
      	LOOP

           	Fetch C_GET_PROS into
      			l_promise_detail_id,
             		l_party_id,
             		l_resource_id,
             		l_cust_account_id,
			l_customer_site_use_id,
			l_delinquency_id;

		EXIT WHEN C_GET_PROS%NOTFOUND;

		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			LogMessage( 'Found promise');
			LogMessage( 'promise_detail_id =' || l_promise_detail_id );
			LogMessage( 'party_id =' || l_party_id );
			LogMessage( 'resource_id =' || l_resource_id );
			LogMessage( 'l_cust_account_id =' || l_cust_account_id );
		END IF;

    		If ( l_resource_id is null ) Then
			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         			LogMessage( 'No Resource_ID');
			END IF;
			-- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
			/*
         		IEX_CONC_REQUEST_MSG_PKG.Log_Error(
                        	P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
                        	P_Procedure_name        => G_PKG_NAME || '.' || l_api_name,
                        	P_MESSAGE               => 'No resource_ID for promise_detail_id = ' || l_promise_detail_id || '. Cannot create task.');
                        */
                        -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
		else
	         	--Bug4201040. Fix By LKKUMAR on 24-Jan-2006. Start.
         		--l_task_name   := 'Oracle Collections Callback for Broken Promise';
			l_task_name   := 'Broken Promise Callback';
         		l_task_status := 'Open';
         		l_task_type   := 'Callback';
         		--l_description := 'Oracle Collections Callback for Broken Promise';
			l_description := 'Broken Promise Callback';
			--Bug4201040. Fix By LKKUMAR on 24-Jan-2006. End.
         		l_owner_type_code := 'RS_EMPLOYEE';
         		l_owner_id := l_resource_id;
         		l_customer_id := l_party_id;

			/* begin kasreeni 01/20/2006 Create task reference for Party_id, ACCOUNT and bill to */

    			G_TASK_REFERENCE_TAB := l_miss_task_refer_tbl;
		        p_counter := 1;
			copy_Task_ref_to_Tab(p_counter, 'IEX_ACCOUNT', l_cust_account_id);

			if (l_customer_site_use_id is not null) then
				p_counter := p_counter + 1;
				copy_Task_ref_to_Tab(p_counter, 'IEX_BILLTO', l_customer_site_use_id);
				p_counter := p_counter + 1;
				copy_Task_ref_to_Tab(p_counter, 'IEX_DELINQUENCY', l_delinquency_id);
			end if;

			/* end  kasreeni 01/20/2006 Create task reference for Party_id, ACCOUNT and bill to */

			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				LogMessage( 'Calling JTF_TASKS_PUB.CREATE_TASK...');
			END IF;

         		JTF_TASKS_PUB.CREATE_TASK(
            			p_api_version           	=> p_api_version,
            			p_init_msg_list         	=> p_init_msg_list,
            			p_commit                	=> p_commit,
            			p_task_name             	=> l_task_name,
            			p_task_type_name        	=> l_task_type,
            			p_task_status_name      	=> l_task_status,
            			p_owner_type_code       	=> l_owner_type_code,
            			p_owner_id              	=> l_owner_id,
            			p_description           	=> l_description,
            			p_customer_id           	=> l_customer_id,
            			P_CUST_ACCOUNT_ID		=> l_cust_account_id,
				P_SOURCE_OBJECT_TYPE_CODE 	=> 'IEX_PROMISE',
				P_SOURCE_OBJECT_ID 		=> l_promise_detail_id,
				P_SOURCE_OBJECT_NAME 		=> l_promise_detail_id,
				p_task_assign_tbl       	=> l_miss_task_assign_tbl,
            			p_task_depends_tbl      	=> l_miss_task_depends_tbl,
            			p_task_rsrc_req_tbl     	=> l_miss_task_rsrc_req_tbl,
            			p_task_refer_tbl        	=> G_TASK_REFERENCE_TAB,
            			p_task_dates_tbl        	=> l_miss_task_dates_tbl,
            			p_task_notes_tbl        	=> l_task_notes_tbl,
            			p_task_recur_rec        	=> l_miss_task_recur_rec,
            			p_task_contacts_tbl     	=> l_miss_task_contacts_tbl,
            			x_return_status         	=> l_return_status,
            			x_msg_count             	=> l_msg_count,
            			x_msg_data              	=> l_msg_data,
            			x_task_id               	=> l_task_id );

			-- check for errors
			IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
				IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
					LogMessage( 'Call JTF_TASKS_PUB.CREATE_TASK failed');
				END IF;
				-- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
				/*
      				IEX_CONC_REQUEST_MSG_PKG.Log_Error(
                   			P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
                   			P_Procedure_name        => G_PKG_NAME || '.' || l_api_name,
                   			P_MESSAGE               => 'Call JTF_TASKS_PUB.CREATE_TASK failed');
                   		*/
                   		-- End - Andre Araujo - 09/30/2004- Remove obsolete logging
                   		exit;
			ELSE
				IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
					LogMessage( 'Call JTF_TASKS_PUB.CREATE_TASK succeeded. Task_ID=' || l_task_id);
				END IF;

			END IF;

			-- update iex_promise_details table
			UPDATE iex_promise_details
			SET CALLBACK_CREATED_YN = 'Y',
			last_update_date = sysdate,
			last_updated_by = G_USER_ID
			WHERE promise_detail_id = l_promise_detail_id;

			if (sql%notfound) then
				IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
					LogMessage( 'update failed');
				END IF;
				-- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
				/*
    				IEX_CONC_REQUEST_MSG_PKG.Log_Error(
                   			P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
                   			P_Procedure_name        => G_PKG_NAME || '.' || l_api_name,
                   			P_MESSAGE               => 'Failed to update iex_promise_details for promise_detail_id = ' || l_promise_detail_id);
                   		*/
                   		-- End - Andre Araujo - 09/30/2004- Remove obsolete logging
			else
				IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
					LogMessage( 'update successfull');
				END IF;
			end if;

    		end if;

	end loop;  -- end of CURSOR loop

	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      		LogMessage( 'Close C_GET_PROS');
	END IF;
      	Close C_GET_PROS;

	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		LogMessage( 'End of ' || l_api_name || ' body');
	END IF;
    	-- END OF BODY OF API

	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      		LogMessage( 'End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
	END IF;

    	-- Standard check of p_commit.
    	IF FND_API.To_Boolean( p_commit ) THEN
        	COMMIT WORK;
    	END IF;

	--Begin bug 7317666 21-Nov-2008 barathsr
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		LogMessage( 'Cancelling the callback tasks correpsonding to fulfilled promises...');
	END IF;
	FOR rec1 IN c_invalid_tasks LOOP
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		LogMessage( 'Cancelling the callback task: '||rec1.task_id);
	END IF;
	l_obj_version_number:=rec1.object_version_number;
	JTF_TASKS_PUB.UPDATE_TASK(
	P_API_VERSION           	=> p_api_version,
        P_INIT_MSG_LIST         	=> p_init_msg_list,
        P_COMMIT                	=> p_commit,
	P_OBJECT_VERSION_NUMBER	=> l_obj_version_number,
	P_TASK_ID 			=> rec1.task_id,
	P_TASK_STATUS_NAME		=> 'Cancelled',
	x_return_status		=> l_return_status,
	x_msg_count			=> l_msg_count,
	x_msg_data			=> l_msg_data);

	END LOOP;

	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		LogMessage( 'Completed Cancelling the callback tasks correpsonding to fulfilled promises...');
  	END IF;

	IF FND_API.To_Boolean( p_commit ) THEN

        	COMMIT WORK;
    	END IF;
	--End bug 7317666 21-Nov-2008 barathsr

	x_return_status := l_return_status;
   	-- Standard call to get message count and if count is 1, get message info
    	FND_MSG_PUB.Count_And_Get(
                   p_encoded => FND_API.G_FALSE,
                   p_count => x_msg_count,
                   p_data => x_msg_data);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO PROCESS_PROMISE_CALLBACKS_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
      -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
      /*
      IEX_CONC_REQUEST_MSG_PKG.Log_Error(
                   P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
                   P_Procedure_name        => G_PKG_NAME || '.' || l_api_name,
                   P_MESSAGE               => 'Failed to process promise callbacks');
      */
      -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO PROCESS_PROMISE_CALLBACKS_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
      -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
      /*
      IEX_CONC_REQUEST_MSG_PKG.Log_Error(
                   P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
                   P_Procedure_name        => G_PKG_NAME || '.' || l_api_name,
                   P_MESSAGE               => 'Failed to process promise callbacks');
      */
      -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
    WHEN OTHERS THEN
      ROLLBACK TO PROCESS_PROMISE_CALLBACKS_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
      -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
      /*
      IEX_CONC_REQUEST_MSG_PKG.Log_Error(
                   P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
                   P_Procedure_name        => G_PKG_NAME || '.' || l_api_name,
                   P_MESSAGE               => 'Failed to process promise callbacks');
      */
      -- End - Andre Araujo - 09/30/2004- Remove obsolete logging

END;

/**********************
	This procedure reopens promises for delinquencies that have been reopened.
***********************/
PROCEDURE REOPEN_PROMISES(
    	P_API_VERSION			IN      NUMBER,
    	P_INIT_MSG_LIST			IN      VARCHAR2,
    	P_COMMIT			IN      VARCHAR2,
    	P_VALIDATION_LEVEL	    	IN      NUMBER,
    	X_RETURN_STATUS			OUT NOCOPY     VARCHAR2,
    	X_MSG_COUNT			OUT NOCOPY     NUMBER,
    	X_MSG_DATA	    	    	OUT NOCOPY     VARCHAR2,
    	p_dels_tbl			IN	DBMS_SQL.NUMBER_TABLE /*table of delinquency ids*/)
IS
    	l_api_name                       CONSTANT VARCHAR2(30) := 'REOPEN_PROMISES';
    	l_api_version                    CONSTANT NUMBER := 1.0;
    	l_return_status                  VARCHAR2(1);
    	l_msg_count                      NUMBER;
    	l_msg_data                       VARCHAR2(32767);

    	l_promise_id			NUMBER;
    	l_promise_date			DATE;
    	l_del_count			NUMBER;
	vSQL				varchar2(10000);

    	Type refCur is Ref Cursor;
        promises_cur			refCur;
    	l_callback_date     		DATE;
BEGIN
	X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

/*
	Commented out whole procedure because PROB now can apply payments to promises or
	reverse payments from promises automatically.
	We do not need to close or reopen promises if delinquency is closed or reopened - all this will be done by PROB.
	We are obsoleting status CLOSED.

    	-- Standard start of API savepoint
    	SAVEPOINT REOPEN_PROMISES_PVT;

	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    		LogMessage(G_PKG_NAME || '.REOPEN_PROMISES: Savepoint is established');
	END IF;
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
    		LogMessage(G_PKG_NAME || '.REOPEN_PROMISES: Start of ' || l_api_name || ' body');
	END IF;

        l_del_count := p_dels_tbl.count;
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		LogMessage(G_PKG_NAME || '.REOPEN_PROMISES: delinquencies count: ' || l_del_count);
	END IF;
        if l_del_count > 0 then

		vSQL := 'SELECT ' ||
			'PROMISE_DETAIL_ID, PROMISE_DATE ' ||
			'FROM ' ||
			'IEX_PROMISE_DETAILS ' ||
			'WHERE ' ||
			'DELINQUENCY_ID is not null and ' ||
			'DELINQUENCY_ID = :del and ' ||
			'STATUS = ''CLOSED'' ' ||
			'ORDER BY PROMISE_DETAIL_ID';

		FOR i in 1..l_del_count LOOP
			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				LogMessage(G_PKG_NAME || '.REOPEN_PROMISES: pulling closed promises for delinquency: ' || p_dels_tbl(i));
			END IF;
			open promises_cur for vSQL
			using p_dels_tbl(i);

			LOOP
				fetch promises_cur into l_promise_id, l_promise_date;
				exit when promises_cur%NOTFOUND;

				IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
					LogMessage(G_PKG_NAME || '.REOPEN_PROMISES: found promise with id: ' || l_promise_id);
					LogMessage(G_PKG_NAME || '.REOPEN_PROMISES: promise date: ' || l_promise_date);
				END IF;

				if trunc(sysdate) > trunc(l_promise_date) then
					Get_Callback_Date(p_promise_date => l_promise_date, x_callback_date => l_callback_date);

					IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
						LogMessage(G_PKG_NAME || '.REOPEN_PROMISES: updating promise ' || l_promise_id || ' with status BROKEN');
						LogMessage(G_PKG_NAME || '.REOPEN_PROMISES: callback date ' || l_callback_date);
					END IF;
					UPDATE iex_promise_details
					SET STATUS = 'BROKEN',
					CALLBACK_CREATED_YN = 'N',
					CALLBACK_DATE = l_callback_date,
					last_update_date = sysdate,
					last_updated_by = G_USER_ID
					WHERE promise_detail_id = l_promise_id;
				else
					IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
						LogMessage(G_PKG_NAME || '.REOPEN_PROMISES: updating promise ' || l_promise_id || ' with status OPEN');
					END IF;
					UPDATE iex_promise_details
					SET STATUS = 'OPEN',
					last_update_date = sysdate,
					last_updated_by = G_USER_ID
					WHERE promise_detail_id = l_promise_id;
				end if;

				if (sql%notfound) then
					IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
						LogMessage(G_PKG_NAME || '.REOPEN_PROMISES: update of promise ' || l_promise_id || ' failed');
					END IF;
					-- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
    					--IEX_CONC_REQUEST_MSG_PKG.Log_Error(
                   			--	P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
                   			--	P_Procedure_name        => G_PKG_NAME || '.' || l_api_name,
                   			--	P_MESSAGE               => 'Failed to update iex_promise_details for promise_detail_id = ' || l_promise_id);
                   			-- End - Andre Araujo - 09/30/2004- Remove obsolete logging
				else
					IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
						LogMessage(G_PKG_NAME || '.REOPEN_PROMISES: update of promise ' || l_promise_id || ' succeeded');
					END IF;
				end if;
			END LOOP;
		END LOOP;
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			LogMessage(G_PKG_NAME || '.REOPEN_PROMISES: done processing all delinquencies');
		END IF;
	end if;

	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	LogMessage(G_PKG_NAME || '.REOPEN_PROMISES: End of ' || l_api_name || ' body');
	END IF;
    	-- END OF BODY OF API

    	-- Standard check of p_commit.
    	IF FND_API.To_Boolean( p_commit ) THEN
        	COMMIT WORK;
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    			LogMessage(G_PKG_NAME || '.REOPEN_PROMISES: Commited');
		END IF;
    	END IF;

	x_return_status := l_return_status;
    	-- Standard call to get message count and if count is 1, get message info
    	FND_MSG_PUB.Count_And_Get(
                   p_encoded => FND_API.G_FALSE,
                   p_count => x_msg_count,
                   p_data => x_msg_data);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO REOPEN_PROMISES_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
      -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
      --IEX_CONC_REQUEST_MSG_PKG.Log_Error(
      --             P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
      --             P_Procedure_name        => 'IEX_PROMISES_BATCH_PUB.REOPEN_PROMISES',
      --             P_MESSAGE               => 'Failed to reopen promises.' );
      -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO REOPEN_PROMISES_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
      -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
      --IEX_CONC_REQUEST_MSG_PKG.Log_Error(
      --             P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
      --             P_Procedure_name        => 'IEX_PROMISES_BATCH_PUB.REOPEN_PROMISES',
      --             P_MESSAGE               => 'Failed to reopen promises.' );
      -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
    WHEN OTHERS THEN
      ROLLBACK TO REOPEN_PROMISES_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
      -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
      --IEX_CONC_REQUEST_MSG_PKG.Log_Error(
      --             P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
      --             P_Procedure_name        => 'IEX_PROMISES_BATCH_PUB.REOPEN_PROMISES',
      --             P_MESSAGE               => 'Failed to reopen promises.' );
      -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
*/
END;
begin
  PG_DEBUG  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LOGIN_ID  := FND_GLOBAL.Conc_Login_Id;
  G_PROGRAM_ID := FND_GLOBAL.Conc_Program_Id;
  G_USER_ID  := FND_GLOBAL.User_Id;
  G_REQUEST_ID := FND_GLOBAL.Conc_Request_Id;
END;

/
