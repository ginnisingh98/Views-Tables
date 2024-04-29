--------------------------------------------------------
--  DDL for Package Body IEX_PAYMENTS_BATCH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_PAYMENTS_BATCH_PUB" as
/* $Header: iexpypbb.pls 120.3 2006/05/30 17:49:23 scherkas noship $ */

PG_DEBUG NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

G_APP_ID   CONSTANT NUMBER := 695;
G_PKG_NAME CONSTANT VARCHAR2(30):= 'IEX_PAYMENTS_BATCH_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'iexpypbb.pls';
G_LOGIN_ID NUMBER := FND_GLOBAL.Conc_Login_Id;
G_PROGRAM_ID NUMBER := FND_GLOBAL.Conc_Program_Id;
G_USER_ID NUMBER := FND_GLOBAL.User_Id;
G_REQUEST_ID NUMBER := FND_GLOBAL.Conc_Request_Id;
G_START_DATE DATE;
G_END_DATE DATE;
G_DATES_LOADED BOOLEAN := FALSE;

procedure debug(p_msg varchar2) is
begin
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(p_msg);
END IF;
end;

PROCEDURE IEX_PAYMENTS_CONCUR(
	ERRBUF      OUT NOCOPY     VARCHAR2,
	RETCODE     OUT NOCOPY     VARCHAR2) IS
	l_msg_count	number;
BEGIN
	debug('IEX_PAYMENTS_CONCUR: Start');
	PROCESS_PAYMENTS(
    		P_API_VERSION => 1.0,
    		P_INIT_MSG_LIST	=> FND_API.G_TRUE,
    		P_COMMIT => FND_API.G_TRUE,
    		P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
    		X_RETURN_STATUS	=> RETCODE,
    		X_MSG_COUNT => l_msg_count,
    		X_MSG_DATA => ERRBUF);
	debug('IEX_PAYMENTS_CONCUR: End');
END;


PROCEDURE LOAD_DATES IS
	CURSOR get_start_date_crs(p_request_id number)
	IS
		select max(ACTUAL_START_DATE)
		from FND_CONC_REQ_SUMMARY_V
		where PROGRAM_SHORT_NAME = 'IEX_PROCESS_PAYMENTS'
                and (program_application_id = 695 or program_application_id = 222) -- fixed a perf bug 4930381
		and request_id <> p_request_id;

	CURSOR get_end_date_crs(p_request_id number)
	IS
		select ACTUAL_START_DATE
		from FND_CONC_REQ_SUMMARY_V
		where PROGRAM_SHORT_NAME = 'IEX_PROCESS_PAYMENTS'
                and (program_application_id = 695 or program_application_id = 222) -- fixed a perf bug 4930381
		and request_id = p_request_id;

	l_date	date;
BEGIN
	debug('LOAD_DATES: Start');
	debug('LOAD_DATES: current G_REQUEST_ID: ' || G_REQUEST_ID);
	if G_DATES_LOADED = FALSE then
		debug('LOAD_DATES: Loading dates...');

		OPEN get_start_date_crs(p_request_id => G_REQUEST_ID);
		debug('LOAD_DATES: get_start_date_crs is opened');

		FETCH get_start_date_crs INTO l_date;
		if get_start_date_crs%FOUND then
			G_START_DATE := l_date;
			debug('LOAD_DATES: G_START_DATE: ' || G_START_DATE);
		else
			G_START_DATE := null;
			debug('LOAD_DATES: G_START_DATE is null');
		end if;
		CLOSE get_start_date_crs;
		debug('LOAD_DATES: get_start_date_crs is closed');

		OPEN get_end_date_crs(p_request_id => G_REQUEST_ID);
		debug('LOAD_DATES: get_end_date_crs is opened');

		FETCH get_end_date_crs INTO l_date;
		if get_end_date_crs%FOUND then
			G_END_DATE := l_date;
			debug('LOAD_DATES: G_END_DATE: ' || G_END_DATE);
		else
			G_START_DATE := null;
			debug('LOAD_DATES: G_END_DATE is null');
		end if;
		CLOSE get_end_date_crs;
		debug('LOAD_DATES: get_end_date_crs is closed');

		G_DATES_LOADED := TRUE;
	else
		debug('LOAD_DATES: Dates are loaded already');
		debug('LOAD_DATES: G_START_DATE: ' || G_START_DATE);
		debug('LOAD_DATES: G_END_DATE: ' || G_END_DATE);
	end if;
	debug('LOAD_DATES: End');
END;

PROCEDURE PROCESS_PAYMENTS(
    P_API_VERSION		    	IN      NUMBER,
    P_INIT_MSG_LIST		    	IN      VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_COMMIT					IN      VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_VALIDATION_LEVEL	    	IN      NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    X_RETURN_STATUS		    	OUT NOCOPY     VARCHAR2,
    X_MSG_COUNT					OUT NOCOPY     NUMBER,
    X_MSG_DATA	    	    	OUT NOCOPY     VARCHAR2)
IS
    	l_api_name                       CONSTANT VARCHAR2(30) := 'PROCESS_PAYMENTS';
    	l_api_version                    CONSTANT NUMBER := 1.0;
    	l_return_status                  VARCHAR2(1);
    	l_msg_count                      NUMBER;
    	l_msg_data                       VARCHAR2(32767);
    	Type refCur is Ref Cursor;
    	l_curs			     	refCur;
	vSQL				varchar2(1000);

	i				number := 0;
	l_inv_tbl			IEX_PAYMENTS_BATCH_PUB.CL_INV_TBL_TYPE;
	l_psa				number;
	l_org				number;

BEGIN
	debug('PROCESS_PAYMENTS: Start');
	LOAD_DATES;

    	-- Standard start of API savepoint
    	SAVEPOINT PROCESS_PAYMENTS_PVT;

	debug('PROCESS_PAYMENTS: Savepoint is established');

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

	debug('PROCESS_PAYMENTS: Start of PROCESS_PAYMENTS body');

	debug('PROCESS_PAYMENTS: Looking for closed payment schedules...');
	-- get paid and closed payment_schedules


	if G_START_DATE is not null then
		vSQL := 'SELECT PSA.PAYMENT_SCHEDULE_ID ' ||
			'FROM ' ||
			'AR_PAYMENT_SCHEDULES PSA, ' ||
			'IEX_DELINQUENCIES DEL ' ||
			'WHERE  ' ||
			'(PSA.ACTUAL_DATE_CLOSED BETWEEN trunc(:P_START_DATE) AND trunc(:P_END_DATE)) AND ' ||
			'PSA.STATUS = ''CL'' AND ' ||
			'DEL.PAYMENT_SCHEDULE_ID = PSA.PAYMENT_SCHEDULE_ID AND ' ||
			'DEL.STATUS = ''OPEN''';

		debug('PROCESS_PAYMENTS: SQL: ' || vSQL);
		open l_curs for vSQL
		using G_START_DATE, G_END_DATE;
	else
		vSQL := 'SELECT PSA.PAYMENT_SCHEDULE_ID ' ||
			'FROM ' ||
			'AR_PAYMENT_SCHEDULES PSA, ' ||
			'IEX_DELINQUENCIES DEL ' ||
			'WHERE  ' ||
			'trunc(PSA.ACTUAL_DATE_CLOSED) <= trunc(:P_END_DATE) AND ' ||
			'PSA.STATUS = ''CL'' AND ' ||
			'DEL.PAYMENT_SCHEDULE_ID = PSA.PAYMENT_SCHEDULE_ID AND ' ||
			'DEL.STATUS <> ''CLOSED''';

		debug('PROCESS_PAYMENTS: SQL: ' || vSQL);
		open l_curs for vSQL
		using G_END_DATE;
	end if;

	i := 0;
	LOOP
		FETCH l_curs INTO l_psa;
		EXIT WHEN l_curs%NOTFOUND;

		i := i+1;
		l_inv_tbl(i) := l_psa;
		debug('PROCESS_PAYMENTS: loop #' || i);
		debug('PROCESS_PAYMENTS: Found closed payment schedule with PAYMENT_SCHEDULE_ID = ' || l_inv_tbl(i));
	END LOOP;
	CLOSE l_curs;
	debug('PROCESS_PAYMENTS: l_curs cursor is closed');

	debug('PROCESS_PAYMENTS: table count: ' || i);
	if i > 0 then
		debug('PROCESS_PAYMENTS: Calling Close_Delinquencies...');
		IEX_DELINQUENCY_PUB.Close_Delinquencies(
			p_api_version => l_api_version,
			p_init_msg_list => FND_API.G_FALSE,		-- passed 'F' to get all debug messages
			p_payments_tbl => l_inv_tbl,
			p_security_check => 'N',
			x_return_status => l_return_status,
			x_msg_count => l_msg_count,
			x_msg_data => l_msg_data);

		-- check for errors
		IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
			debug('PROCESS_PAYMENTS: call Close_Delinquencies failed');
		ELSE
			debug('PROCESS_PAYMENTS: call Close_Delinquencies succeeded');
		END IF;
	else
		debug('PROCESS_PAYMENTS: No closed payment_schedules found');
	end if;
	debug('PROCESS_PAYMENTS: End of PROCESS_PAYMENTS body');
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
	debug('PROCESS_PAYMENTS: End');

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      debug('PROCESS_PAYMENTS: In FND_API.G_EXC_ERROR exception');
      ROLLBACK TO PROCESS_PAYMENTS_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      debug('PROCESS_PAYMENTS: In FND_API.G_EXC_UNEXPECTED_ERROR exception');
      ROLLBACK TO PROCESS_PAYMENTS_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      debug('PROCESS_PAYMENTS: In OTHERS exception');
      ROLLBACK TO PROCESS_PAYMENTS_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END;

END;

/
