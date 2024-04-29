--------------------------------------------------------
--  DDL for Package Body EDR_STANDARD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_STANDARD_PUB" AS
/* $Header: EDRPSTDB.pls 120.0.12000000.1 2007/01/18 05:54:50 appldev ship $ */

-- globle variables
G_PKG_NAME CONSTANT VARCHAR2(100) := 'EDR_STANDARD_PUB';



-- --------------------------------------
-- API name 	: Get_PsigStatus
-- Type		: Public
-- Pre-reqs	: None
-- Function	: Obtains signature status ('PENDING','COMPLETE','ERROR') for a given event
-- Parameters
-- IN	:	p_event_name   	VARCHAR2	event name, eg oracle.apps.gmi.item.create
--		p_event_key	VARCHAR2	event key, eg ItemNo3125
-- OUT	:	x_psig_status	VARCHAR2	event psig status,
--						null: no data found, SQLERROR: exception in callee
-- Versions	: 1.0	17-Jul-03	created from edr_standard.Psig_Status
-- ---------------------------------------

PROCEDURE Get_PsigStatus (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_event_name 		in    	varchar2,
	p_event_key		in    	varchar2,
      	x_psig_status    	out 	NOCOPY varchar2   )
IS
	l_api_version CONSTANT NUMBER := 1.0;
	l_api_name CONSTANT VARCHAR2(50) := 'Get_PsigStatus';
BEGIN
    -- Standard call to check for call compatibility
    IF NOT fnd_api.Compatible_API_Call ( l_api_version, p_api_version, l_api_name, G_PKG_NAME )
    THEN	RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if the caller asks me to do so
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    edr_standard.Psig_Status(
         		P_EVENT 	=> p_event_name,
         		P_EVENT_KEY  	=> p_event_key,
         		P_STATUS     	=> x_psig_status );

    -- Standard call to get message count, and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF  FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )  THEN
		FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
	END IF;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
END Get_PsigStatus;


-- --------------------------------------
-- API name 	: Is_Psig_Required
-- Type		: Public
-- Pre-reqs	: None
-- Function	: return True/False on signature requirement for a given event
-- Parameters
-- IN	:	p_event_name   	VARCHAR2	event name, eg oracle.apps.gmi.item.create
--		p_event_key	VARCHAR2	event key, eg ItemNo3125
-- OUT	:	x_psig_required	VARCHAR2	event psig status
-- Versions	: 1.0	17-Jul-03	created from edr_standard.PSIG_REQUIRED
-- ---------------------------------------

PROCEDURE Is_eSig_Required  (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_event_name 	       	IN 	varchar2,
	p_event_key	 	IN   	varchar2,
	x_isRequired_eSig    	OUT 	NOCOPY VARCHAR2  )
IS
	l_api_version CONSTANT NUMBER := 1.0;
	l_api_name CONSTANT VARCHAR2(50) := 'Is_Psig_Required';
	l_isRequired	BOOLEAN;
BEGIN
    -- Standard call to check for call compatibility
    IF NOT fnd_api.Compatible_API_Call ( l_api_version, p_api_version, l_api_name, G_PKG_NAME )
    THEN	RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if the caller asks me to do so
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN
    	edr_standard.Psig_Required(
         		P_EVENT 	=> p_event_name,
         		P_EVENT_KEY  	=> p_event_key,
         		P_STATUS     	=> l_isRequired );
	IF  l_isRequired  THEN  x_isRequired_eSig := FND_API.G_TRUE;
	ELSE  x_isRequired_eSig := FND_API.G_FALSE;
	END IF;
    EXCEPTION
	WHEN  OTHERS  THEN
		x_isRequired_eSig := FND_API.G_FALSE;
		fnd_msg_pub.Add;
	   	raise fnd_api.G_EXC_ERROR;
    END;
    -- fetch the message off the dictionary stack and add to API message list
    -- would only add the last one message in the above api call
    -- need to do this in the above api after each fnd_message.set_name/set_token
    FND_MSG_PUB.Add;

    -- Standard call to get message count, and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF  FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )  THEN
		FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
	END IF;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
END Is_eSig_Required;


-- --------------------------------------
-- API name 	: Is_Erec_Required
-- Type		: Public
-- Pre-reqs	: None
-- Function	: return True/False on eRecord Requirement for a given event
-- Parameters
-- IN	:	p_event_name   	VARCHAR2	event name, eg oracle.apps.gmi.item.create
--		p_event_key	VARCHAR2	event key, eg ItemNo3125
-- OUT	:	x_erec_required	VARCHAR2	event psig status
-- Versions	: 1.0	17-Jul-03	created from edr_standard.EREC_REQUIRED
-- ---------------------------------------

PROCEDURE Is_eRec_Required  (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_event_name 	       	IN 	varchar2,
	p_event_key	 	IN   	varchar2,
	x_isRequired_eRec     	OUT 	NOCOPY VARCHAR2   )
IS
	l_api_version CONSTANT NUMBER := 1.0;
	l_api_name CONSTANT VARCHAR2(50) := 'Is_Erec_Required';
	l_isRequired	BOOLEAN;
BEGIN
    -- Standard call to check for call compatibility
    IF NOT fnd_api.Compatible_API_Call ( l_api_version, p_api_version, l_api_name, G_PKG_NAME )
    THEN	RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if the caller asks me to do so
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN
    	edr_standard.Erec_Required(
         		P_EVENT 	=> p_event_name,
         		P_EVENT_KEY  	=> p_event_key,
         		P_STATUS     	=> l_isRequired );
	IF  l_isRequired  THEN  x_isRequired_eRec := FND_API.G_TRUE;
	ELSE  x_isRequired_eRec := FND_API.G_FALSE;
	END IF;
    EXCEPTION
	WHEN  OTHERS  THEN
		x_isRequired_eRec := FND_API.G_FALSE;
	   	fnd_msg_pub.Add;
	   	raise fnd_api.G_EXC_ERROR;
    END;
    -- fetch the message off the dictionary stack and add to API message list
    -- would only add the last one message in the above api call
    -- need to do this in the above api after each fnd_message.set_name/set_token
    FND_MSG_PUB.Add;

    -- Standard call to get message count, and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF  FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )  THEN
		FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
	END IF;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
END Is_eRec_Required;


-- --------------------------------------
-- API name 	: Get_PsigQuery_Id
-- Type		: Public
-- Pre-reqs	: None
-- Function	: obtain a query id for events based on records of event informations
-- Parameters
-- IN	:	p_event_name   	VARCHAR2	event name, eg oracle.apps.gmi.item.create
--		p_event_key	VARCHAR2	event key, eg ItemNo3125
-- OUT	:	x_psig_status	VARCHAR2	event psig status
-- Versions	: 1.0	17-Jul-03	created from edr_standard.PSIG_QUERY
-- ---------------------------------------

Procedure Get_QueryId_OnEvents (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	p_commit		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_eventQuery_recTbl 	IN	EventDetail_tbl_type,
	x_query_id		OUT	NOCOPY NUMBER  )
IS
	l_api_version CONSTANT NUMBER := 1.0;
	l_api_name CONSTANT VARCHAR2(50) := 'Get_QueryId_OnEvents';
	l_eventDetl_tbl	edr_standard.eventQuery;
	lth	NUMBER;
BEGIN
    -- Standard call to check for call compatibility
    IF NOT fnd_api.Compatible_API_Call ( l_api_version, p_api_version, l_api_name, G_PKG_NAME )
    THEN	RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if the caller asks me to do so
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    FOR  lth in 1..p_eventQuery_recTbl.COUNT  LOOP
	l_eventDetl_tbl(lth) := p_eventQuery_recTbl(lth);
    END LOOP;
    x_query_id := edr_standard.Psig_Query ( l_eventDetl_tbl );

    IF  FND_API.To_Boolean( p_commit )  THEN
	COMMIT WORK;
    END IF;
    -- Standard call to get message count, and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF  FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )  THEN
		FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
	END IF;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
END Get_QueryId_OnEvents;


-- --------------------------------------
-- API name 	: Display_Date
-- Type		: Public
-- Pre-reqs	: None
-- Function	: convert a date to string in server timezone
-- Parameters
-- IN	:	p_api_version  NUMBER 	1.0
--		p_init_msg_list	VARCHAR2
--	        p_date_in	DATE   date that need to be converted
-- OUT	:	x_return_status	VARCHAR2
--              x_msg_count     NUMBER
--              x_msg_data      VARCHAR2
--              x_date_out      VARCHAR2  converted date
-- Versions	: 1.0	17-Jul-03	created from edr_standard.DISPLAY_DATE
-- ---------------------------------------

PROCEDURE Display_Date (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_date_in  		IN  	DATE ,
	x_date_out 		OUT 	NOCOPY Varchar2 )
IS
	l_api_name CONSTANT VARCHAR2(50) := 'Display_Date';
	l_api_version CONSTANT NUMBER := 1.0;
BEGIN
    IF NOT fnd_api.Compatible_API_Call ( l_api_version, p_api_version, l_api_name, G_PKG_NAME )
    THEN	RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    edr_standard.Display_Date ( P_DATE_IN => p_date_in, P_DATE_OUT => x_date_out );

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF  FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )  THEN
		FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
	END IF;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
END Display_Date;

-- BUG: 3075771 New Procedure added to return date  only
-- --------------------------------------
-- API name     : Display_Date_Only
-- Type         : Public
-- Pre-reqs     : None
-- Function     : convert a date to string and time is truncated
-- Parameters
-- IN	:	p_api_version  NUMBER 	1.0
--		p_init_msg_list	VARCHAR2
--	        p_date_in	DATE   date that need to be converted
-- OUT	:	x_return_status	VARCHAR2
--              x_msg_count     NUMBER
--              x_msg_data      VARCHAR2
--              x_date_out      VARCHAR2  converted date
-- Versions     : 1.0   07-Nov-03       created from edr_standard.DISPLAY_DATE_ONLY
-- ---------------------------------------

PROCEDURE Display_Date_Only (
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2,
        p_date_in               IN      DATE ,
        x_date_out              OUT     NOCOPY Varchar2 )
IS
        l_api_name  CONSTANT VARCHAR2(50) := 'Display_Date_Only';
        l_api_version CONSTANT NUMBER := 1.0;
BEGIN
    IF NOT fnd_api.Compatible_API_Call ( l_api_version, p_api_version, l_api_name, G_PKG_NAME )
    THEN        RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    edr_standard.Display_Date_Only ( P_DATE_IN => p_date_in, P_DATE_OUT => x_date_out );

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF  FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )  THEN
                FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
        END IF;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
END Display_Date_Only;

-- BUG: 3075771 New Procedure added to return time  only
-- --------------------------------------
-- API name     : Display_Time_Only
-- Type         : Public
-- Pre-reqs     : None
-- Function     : convert a date to string and time is truncated
-- Parameters
-- IN   :       p_api_version  NUMBER   1.0
--              p_init_msg_list VARCHAR2
--              p_date_in       DATE   date that need to be converted
-- OUT  :       x_return_status VARCHAR2
--              x_msg_count     NUMBER
--              x_msg_data      VARCHAR2
--              x_date_out      VARCHAR2  converted time
-- Versions     : 1.0   12-Nov-03       created from edr_standard.DISPLAY_TIME_ONLY
-- ---------------------------------------

PROCEDURE Display_Time_Only (
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2,
        p_date_in               IN      DATE ,
        x_date_out              OUT     NOCOPY Varchar2 )
IS
        l_api_name CONSTANT VARCHAR2(50) := 'Display_Time_Only';
        l_api_version CONSTANT NUMBER := 1.0;
BEGIN
    IF NOT fnd_api.Compatible_API_Call ( l_api_version, p_api_version, l_api_name, G_PKG_NAME )
    THEN        RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    edr_standard.Display_Time_Only ( P_DATE_IN => p_date_in, P_DATE_OUT => x_date_out );

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF  FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )  THEN
                FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
        END IF;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
END Display_Time_Only;


-- --------------------------------------
-- API name 	: Get_AmeRule_VarValues
-- Type		: Public
-- Pre-reqs	: None
-- Function	: check if the table column has been audited with a different old value
-- Parameters
-- IN	:	p_transaction_name  	VARCHAR2	transaction name, eg GMI ERES Item Creation
--		p_ameRule_id		NUMBER		AME rule id, eg 11400
--		p_ameRule_name		VARCHAR2	AME rule name, eg Item Creation Rule
-- OUT	:	x_inputVar_values_tbl	inputvar_values_tbl_type	table of inputVar values
-- Versions	: 1.0	17-Jul-03	created from edr_standard.GET_AMERULE_INPUT_VALUES
-- ---------------------------------------

-- Bug 3214495 : Start

/* This API is deprecated. Use Get_AmeRule_VariableValues */

PROCEDURE Get_AmeRule_VarValues (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_transaction_name     	IN   	VARCHAR2,
        p_ameRule_id          	IN    	NUMBER,
        p_ameRule_name        	IN    	VARCHAR2,
        x_inputVar_values_tbl 	OUT 	NOCOPY InputVar_Values_tbl_type  )
IS
	l_api_name CONSTANT VARCHAR2(50) := 'Get_AmeRule_VarValues';
	l_api_version CONSTANT NUMBER := 1.0;
	l_ruleVar_values 	EDR_STANDARD.ameruleinputvalues;
	lth		NUMBER;
BEGIN
    IF NOT fnd_api.Compatible_API_Call ( l_api_version, p_api_version, l_api_name, G_PKG_NAME )
    THEN	RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    edr_standard.GET_AMERULE_INPUT_VALUES (
		ameapplication 	=> p_transaction_name,
		ameruleid 	=> p_ameRule_id,
		amerulename	=> p_ameRule_name,
		ameruleinputvalues	=> l_ruleVar_values );
    FOR  lth  IN  1..l_ruleVar_values.COUNT  LOOP
	x_inputVar_values_tbl(lth) := l_ruleVar_values(lth);
    END LOOP;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF  FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )  THEN
		FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
	END IF;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
END Get_AmeRule_VarValues;


/* New API that takes Transaction Type Id as the Input parameter instead of Transaction Name */

-- --------------------------------------
-- API name 	: Get_AmeRule_VarValues
-- Type		: Public
-- Pre-reqs	: None
-- Function	: check if the table column has been audited with a different old value
-- Parameters
-- IN	:	p_transaction_id  	VARCHAR2	transaction id, eg oracle.apps.gme.item.create
--		p_ameRule_id		NUMBER		AME rule id, eg 11400
--		p_ameRule_name		VARCHAR2	AME rule name, eg Item Creation Rule
-- OUT	:	x_inputVar_values_tbl	inputvar_values_tbl_type	table of inputVar values
-- Versions	: 1.0	19-Feb-05	created from edr_standard.GET_AMERULE_INPUT_VARIABLES
-- ---------------------------------------


PROCEDURE Get_AmeRule_VariableValues (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_transaction_id     	IN   	VARCHAR2,
        p_ameRule_id          	IN    	NUMBER,
        p_ameRule_name        	IN    	VARCHAR2,
        x_inputVar_values_tbl 	OUT 	NOCOPY InputVar_Values_tbl_type  )
IS
	l_api_name CONSTANT VARCHAR2(50) := 'Get_AmeRule_VarValues';
	l_api_version CONSTANT NUMBER := 1.0;
	l_ruleVar_values 	EDR_STANDARD.ameruleinputvalues;
	lth		NUMBER;
BEGIN
    IF NOT fnd_api.Compatible_API_Call ( l_api_version, p_api_version, l_api_name, G_PKG_NAME )
    THEN	RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    edr_standard.GET_AMERULE_INPUT_VARIABLES (
		transactiontypeid => p_transaction_id,
		ameruleid 	=> p_ameRule_id,
		amerulename	=> p_ameRule_name,
		ameruleinputvalues	=> l_ruleVar_values );
    FOR  lth  IN  1..l_ruleVar_values.COUNT  LOOP
	x_inputVar_values_tbl(lth) := l_ruleVar_values(lth);
    END LOOP;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF  FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )  THEN
		FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
	END IF;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );

END Get_AmeRule_VariableValues;

-- Bug 3214495 : End


-- --------------------------------------
-- API name 	: Is_AuditValue_Old
-- Type		: Public
-- Pre-reqs	: None
-- Function	: check if the table column has been audited with a different old value
-- Parameters
-- IN	:	p_table_name   		VARCHAR2	table being audited, eg oracle.apps.gmi.item.create
--		p_column_name		VARCHAR2	column to be checked, eg ItemNo3125
--		p_primKey_name		VARCHAR2	name of primary key, eg ItemNo3125
--		p_primKey_value		VARCHAR2	value of primary key, eg ItemNo3125
-- OUT	:	x_auditValue_old	VARCHAR2	indicate if the audited value is updated
-- Versions	: 1.0	17-Jul-03	created from edr_standard.COMPARE_AUDITVALUES
-- ---------------------------------------

Procedure Is_AuditValue_Old (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_table_name 		IN 	VARCHAR2,
	p_column_name   	IN 	VARCHAR2,
	p_primKey_name     	IN 	VARCHAR2,
	p_primKey_value    	IN 	VARCHAR2,
	x_isOld_auditValue	OUT	NOCOPY VARCHAR2   )
IS
	l_api_version CONSTANT NUMBER := 1.0;
	l_api_name CONSTANT VARCHAR2(50) := 'Is_AuditValue_Old';
	l_isAudited	VARCHAR2(10);
BEGIN
    -- Standard call to check for call compatibility
    IF NOT fnd_api.Compatible_API_Call ( l_api_version, p_api_version, l_api_name, G_PKG_NAME )
    THEN	RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if the caller asks me to do so
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN
    	l_isAudited := edr_standard.Compare_AuditValues ( p_table_name,
         		p_column_name, p_primKey_name, p_primKey_value );
	IF  l_isAudited = 'true'  THEN  x_isOld_auditValue := FND_API.G_TRUE;
	ELSE  x_isOld_auditValue := FND_API.G_FALSE;
	END IF;
    EXCEPTION
	WHEN  OTHERS  THEN
		x_isOld_auditValue := FND_API.G_FALSE;
	   	fnd_message.Set_Name( 'EDR', 'EDR_PLS_STDMSG_AUDIT_DISABLED' );
	   	fnd_msg_pub.Add;
	   	raise fnd_api.G_EXC_ERROR;
    END;
    -- fetch the message off the dictionary stack and add to API message list
    -- would only add the last one message in the above api call
    -- need to do this in the above api after each fnd_message.set_name/set_token
    FND_MSG_PUB.Add;

    -- Standard call to get message count, and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF  FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )  THEN
		FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
	END IF;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
END Is_AuditValue_Old;


-- --------------------------------------
-- API name 	: Get_Notif_Routing_Info
-- Type		: Public
-- Pre-reqs	: None
-- Function	: Obtain the overriding recipient and routing comment for a routed notification
-- Parameters
-- IN	:	p_original_recipient   	VARCHAR2	original recipient
--		p_message_type		VARCHAR2	message type
--		p_message_name		VARCHAR2	message name
-- OUT	:	x_final_recipient	VARCHAR2	final recipient
--		x_allrout_comments	VARCHAR2	all routing comments
-- Versions	: 1.0	17-Jul-03	created from edr_standard.FIND_WF_NTF_RECIPIENT
-- ---------------------------------------

PROCEDURE Get_Notif_Routing_Info (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_original_recipient 	IN 	VARCHAR2,
        p_message_type 		IN 	VARCHAR2,
        p_message_name 		IN 	VARCHAR2,
	x_final_recipient	OUT	NOCOPY VARCHAR2,
	x_allrout_comments	OUT	NOCOPY VARCHAR2   )
IS
	l_api_name CONSTANT VARCHAR2(50) := 'Get_Notif_Routing_Info';
	l_api_version CONSTANT NUMBER := 1.0;
	l_error_code 	NUMBER;
	l_error_mesg	VARCHAR2(1000);
BEGIN
    IF NOT fnd_api.Compatible_API_Call ( l_api_version, p_api_version, l_api_name, G_PKG_NAME )
    THEN	RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if the caller asks me to do so
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN
    	edr_standard.FIND_WF_NTF_RECIPIENT(
		P_ORIGINAL_RECIPIENT  	=> p_original_recipient,
         	P_MESSAGE_TYPE  	=> p_message_type,
         	P_MESSAGE_NAME		=> p_message_name,
		P_RECIPIENT		=> x_final_recipient,
		P_NTF_ROUTING_COMMENTS	=> x_allrout_comments,
         	P_ERR_CODE  		=> l_error_code,
         	P_ERR_MSG		=> l_error_mesg );
    EXCEPTION
	WHEN  OTHERS  THEN
	   IF l_error_code > 0  THEN
	   	fnd_message.Set_Name( 'EDR', 'EDR_PLS_STDMSG_GENERATED' );
	   	fnd_message.Set_Token( 'ERR_CODE', l_error_code );
	   	fnd_message.Set_Token( 'ERR_MESG', l_error_mesg );
	   	fnd_msg_pub.Add;
	   	raise fnd_api.G_EXC_ERROR;
	   ELSE
	   	fnd_message.Set_Name( 'EDR', 'EDR_PLS_STDMSG_UNEXPECTED' );
	   	fnd_message.Set_Token( 'ERR_CODE', l_error_code );
	   	fnd_message.Set_Token( 'ERR_MESG', l_error_mesg );
	   	fnd_msg_pub.Add;
	   	raise fnd_api.G_EXC_UNEXPECTED_ERROR;
   	   END IF;
    END;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF  FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )  THEN
		FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
	END IF;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
END Get_Notif_Routing_Info;



-- --------------------------------------
-- API name 	: Get_DescFlex_OnePrompt
-- Type		: Public
-- Pre-reqs	: None
-- Function	: Obtains a single descriptive flexfield prompt for designated column
-- Parameters
-- IN	:	p_application_id  	NUMBER		descriptive flexfield owner application id
--		p_descFlex_defName	VARCHAR2	name of flexfield definiation
--		p_descFlex_context	VARCHAR2	flex definition context (ATTRIBUTE_CATEGORY)
--		p_column_name		VARCHAR2	name of the column corresponding to a flex segment
--		p_prompt_type		VARCHAR2	indicate the field from which to return values
--					'LEFT' --> FORM_LEFT_PROMPT; 'ABOVE' --> FORM_ABOVE_PROMPT
-- OUT	:	x_column_prompt		VARCHAR2	the prompt values for the columns
-- Versions	: 1.0	17-Jul-03	created from edr_standard.GET_DESC_FLEX_SINGLE_PROMPT
-- ---------------------------------------

PROCEDURE Get_DescFlex_OnePrompt (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_application_id     	IN 	NUMBER,
	p_descFlex_defName 	IN 	VARCHAR2,
	p_descFlex_context  	IN 	VARCHAR2,
	P_COLUMN_NAME        	IN 	VARCHAR2,
	p_prompt_type        	IN 	VARCHAR2,
	x_column_prompt      	OUT 	NOCOPY VARCHAR2   )
IS
	l_api_version CONSTANT NUMBER := 1.0;
	l_api_name CONSTANT VARCHAR2(50) := 'Get_DescFlex_OnePrompt';
	l_prompt_type	VARCHAR2(20);
BEGIN
    -- Standard call to check for call compatibility
    IF NOT fnd_api.Compatible_API_Call ( l_api_version, p_api_version, l_api_name, G_PKG_NAME )
    THEN	RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if the caller asks me to do so
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_prompt_type is NULL OR p_prompt_type = fnd_api.g_miss_char THEN
	l_prompt_type := 'LEFT';
    ELSE  l_prompt_type := p_prompt_type;
    END IF;

    edr_standard.Get_Desc_Flex_Single_Prompt (
			P_APPLICATION_ID	=> p_application_id ,
			P_DESC_FLEX_DEF_NAME	=> p_descFlex_defName ,
			P_DESC_FLEX_CONTEXT	=> p_descFlex_context ,
			P_COLUMN_NAME		=> P_COLUMN_NAME ,
			P_PROMPT_TYPE		=> l_prompt_type ,
			P_COLUMN_PROMPT		=> x_column_prompt );

    -- Standard call to get message count, and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF  FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )  THEN
		FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
	END IF;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
END Get_DescFlex_OnePrompt;


-- --------------------------------------
-- API name 	: Get_DescFlex_AllPrompts
-- Type		: Public
-- Pre-reqs	: None
-- Function	: Obtains all 30 descriptive flexfield prompts
-- Parameters
-- IN	:	p_application_id  	NUMBER		descriptive flexfield owner application id
--		p_descFlex_defName	VARCHAR2	name of flexfield definiation
--		p_descFlex_context	VARCHAR2	flex definition context (ATTRIBUTE_CATEGORY)
--		p_colnNames_rec		Flex_ColnName_Rec_Type
--							names of the columns corresponding to a flex segment
--		p_prompt_type		VARCHAR2	indicate the field from which to return values
--					'LEFT': FORM_LEFT_PROMPT; 'ABOVE': FORM_ABOVE_PROMPT
-- OUT	:	x_colnPrompts_rec 	Flex_ColnPrompt_Rec_Type
--							the prompt values for the columns
-- Versions	: 1.0	17-Jul-03	created from edr_standard.GET_DESC_FLEX_ALL_PROMPTS
-- ---------------------------------------

PROCEDURE Get_DescFlex_AllPrompts (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_application_id     	IN 	NUMBER,
	p_descFlex_defName 	IN 	VARCHAR2,
	p_descFlex_context  	IN 	VARCHAR2,
	p_colnNames_rec		IN	edr_standard_pub.Flex_ColnName_Rec_Type,
	p_prompt_type        	IN 	VARCHAR2,
	x_colnPrompts_rec	OUT	NOCOPY edr_standard_pub.Flex_ColnPrompt_Rec_Type  )
IS
	l_api_version CONSTANT NUMBER := 1.0;
	l_api_name CONSTANT VARCHAR2(50) := 'Get_DescFlex_AllPrompts';
	l_prompt_type	VARCHAR2(20);
BEGIN
    -- Standard call to check for call compatibility
    IF NOT fnd_api.Compatible_API_Call ( l_api_version, p_api_version, l_api_name, G_PKG_NAME )
    THEN	RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if the caller asks me to do so
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_prompt_type is NULL OR p_prompt_type = fnd_api.g_miss_char THEN
	l_prompt_type := 'LEFT';
    ELSE  l_prompt_type := p_prompt_type;
    END IF;

    edr_standard.Get_Desc_Flex_All_Prompts (
		P_APPLICATION_ID	=> p_application_id,
		P_DESC_FLEX_DEF_NAME	=> p_descFlex_defName,
		P_DESC_FLEX_CONTEXT	=> p_descFlex_context,
		P_PROMPT_TYPE	=> l_prompt_type,
		P_COLUMN1_NAME	=> p_colnNames_rec.P_COLUMN1_NAME,
		P_COLUMN2_NAME	=> p_colnNames_rec.P_COLUMN2_NAME,
		P_COLUMN3_NAME	=> p_colnNames_rec.P_COLUMN3_NAME,
		P_COLUMN4_NAME	=> p_colnNames_rec.P_COLUMN4_NAME,
		P_COLUMN5_NAME	=> p_colnNames_rec.P_COLUMN5_NAME,
		P_COLUMN6_NAME	=> p_colnNames_rec.P_COLUMN6_NAME,
		P_COLUMN7_NAME	=> p_colnNames_rec.P_COLUMN7_NAME,
		P_COLUMN8_NAME	=> p_colnNames_rec.P_COLUMN8_NAME,
		P_COLUMN9_NAME	=> p_colnNames_rec.P_COLUMN9_NAME,
		P_COLUMN10_NAME	=> p_colnNames_rec.P_COLUMN10_NAME,
		P_COLUMN11_NAME	=> p_colnNames_rec.P_COLUMN11_NAME,
		P_COLUMN12_NAME	=> p_colnNames_rec.P_COLUMN12_NAME,
		P_COLUMN13_NAME	=> p_colnNames_rec.P_COLUMN13_NAME,
		P_COLUMN14_NAME	=> p_colnNames_rec.P_COLUMN14_NAME,
		P_COLUMN15_NAME	=> p_colnNames_rec.P_COLUMN15_NAME,
		P_COLUMN16_NAME	=> p_colnNames_rec.P_COLUMN16_NAME,
		P_COLUMN17_NAME	=> p_colnNames_rec.P_COLUMN17_NAME,
		P_COLUMN18_NAME	=> p_colnNames_rec.P_COLUMN18_NAME,
		P_COLUMN19_NAME	=> p_colnNames_rec.P_COLUMN19_NAME,
		P_COLUMN20_NAME	=> p_colnNames_rec.P_COLUMN20_NAME,
		P_COLUMN21_NAME	=> p_colnNames_rec.P_COLUMN21_NAME,
		P_COLUMN22_NAME	=> p_colnNames_rec.P_COLUMN22_NAME,
		P_COLUMN23_NAME	=> p_colnNames_rec.P_COLUMN23_NAME,
		P_COLUMN24_NAME	=> p_colnNames_rec.P_COLUMN24_NAME,
		P_COLUMN25_NAME	=> p_colnNames_rec.P_COLUMN25_NAME,
		P_COLUMN26_NAME	=> p_colnNames_rec.P_COLUMN26_NAME,
		P_COLUMN27_NAME	=> p_colnNames_rec.P_COLUMN27_NAME,
		P_COLUMN28_NAME	=> p_colnNames_rec.P_COLUMN28_NAME,
		P_COLUMN29_NAME	=> p_colnNames_rec.P_COLUMN29_NAME,
		P_COLUMN30_NAME	=> p_colnNames_rec.P_COLUMN30_NAME,
		P_COLUMN1_PROMPT	=> x_colnPrompts_rec.P_COLUMN1_PROMPT,
		P_COLUMN2_PROMPT	=> x_colnPrompts_rec.P_COLUMN2_PROMPT,
		P_COLUMN3_PROMPT	=> x_colnPrompts_rec.P_COLUMN3_PROMPT,
		P_COLUMN4_PROMPT	=> x_colnPrompts_rec.P_COLUMN4_PROMPT,
		P_COLUMN5_PROMPT	=> x_colnPrompts_rec.P_COLUMN5_PROMPT,
		P_COLUMN6_PROMPT	=> x_colnPrompts_rec.P_COLUMN6_PROMPT,
		P_COLUMN7_PROMPT	=> x_colnPrompts_rec.P_COLUMN7_PROMPT,
		P_COLUMN8_PROMPT	=> x_colnPrompts_rec.P_COLUMN8_PROMPT,
		P_COLUMN9_PROMPT	=> x_colnPrompts_rec.P_COLUMN9_PROMPT,
		P_COLUMN10_PROMPT	=> x_colnPrompts_rec.P_COLUMN10_PROMPT,
		P_COLUMN11_PROMPT	=> x_colnPrompts_rec.P_COLUMN11_PROMPT,
		P_COLUMN12_PROMPT	=> x_colnPrompts_rec.P_COLUMN12_PROMPT,
		P_COLUMN13_PROMPT	=> x_colnPrompts_rec.P_COLUMN13_PROMPT,
		P_COLUMN14_PROMPT	=> x_colnPrompts_rec.P_COLUMN14_PROMPT,
		P_COLUMN15_PROMPT	=> x_colnPrompts_rec.P_COLUMN15_PROMPT,
		P_COLUMN16_PROMPT	=> x_colnPrompts_rec.P_COLUMN16_PROMPT,
		P_COLUMN17_PROMPT	=> x_colnPrompts_rec.P_COLUMN17_PROMPT,
		P_COLUMN18_PROMPT	=> x_colnPrompts_rec.P_COLUMN18_PROMPT,
		P_COLUMN19_PROMPT	=> x_colnPrompts_rec.P_COLUMN19_PROMPT,
		P_COLUMN20_PROMPT	=> x_colnPrompts_rec.P_COLUMN20_PROMPT,
		P_COLUMN21_PROMPT	=> x_colnPrompts_rec.P_COLUMN21_PROMPT,
		P_COLUMN22_PROMPT	=> x_colnPrompts_rec.P_COLUMN22_PROMPT,
		P_COLUMN23_PROMPT	=> x_colnPrompts_rec.P_COLUMN23_PROMPT,
		P_COLUMN24_PROMPT	=> x_colnPrompts_rec.P_COLUMN24_PROMPT,
		P_COLUMN25_PROMPT	=> x_colnPrompts_rec.P_COLUMN25_PROMPT,
		P_COLUMN26_PROMPT	=> x_colnPrompts_rec.P_COLUMN26_PROMPT,
		P_COLUMN27_PROMPT	=> x_colnPrompts_rec.P_COLUMN27_PROMPT,
		P_COLUMN28_PROMPT	=> x_colnPrompts_rec.P_COLUMN28_PROMPT,
		P_COLUMN29_PROMPT	=> x_colnPrompts_rec.P_COLUMN29_PROMPT,
		P_COLUMN30_PROMPT	=> x_colnPrompts_rec.P_COLUMN30_PROMPT );

    -- Standard call to get message count, and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF  FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )  THEN
		FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
	END IF;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
END Get_DescFlex_AllPrompts;


-- --------------------------------------
-- API name 	: Get_Lookup_Meaning
-- Type		: Public
-- Pre-reqs	: None
-- Function	: Obtains lookup code meaning using fnd_lookups view
-- Parameters
-- IN	:	p_lookup_type   VARCHAR2	event name, eg oracle.apps.gmi.item.create
--		p_lookup_code	VARCHAR2	event key, eg ItemNo3125
-- OUT	:	x_psig_status	VARCHAR2	event psig status
-- Versions	: 1.0	17-Jul-03	created from edr_standard.Get_Meaning
-- ---------------------------------------

PROCEDURE Get_Lookup_Meaning (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_lookup_type	IN 	VARCHAR2,
	p_lookup_code 	IN 	VARCHAR2,
	x_lkup_meaning 	OUT 	NOCOPY VARCHAR2  )
IS
	l_api_name CONSTANT VARCHAR2(50) := 'Get_Lookup_Meaning';
	l_api_version CONSTANT NUMBER := 1.0;
BEGIN
    IF NOT fnd_api.Compatible_API_Call ( l_api_version, p_api_version, l_api_name, G_PKG_NAME )
    THEN	RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    edr_standard.Get_Meaning ( 	P_LOOKUP_TYPE	=> p_lookup_type,
				P_LOOKUP_CODE	=> p_lookup_code,
				P_MEANING	=> x_lkup_meaning );

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF  FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )  THEN
		FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
	END IF;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
END Get_Lookup_Meaning;


/**** It is a simplied version wrapped over PSIG_QUERY for Java api ***/
-- --------------------------------------
-- API name 	: Get_QueryId_OnParams
-- Type		: Public
-- Pre-reqs	: None
-- Function	: obtain a query id for events based on arrays of event parameters (name, key)
-- Parameters
-- IN	:	p_event_name   	VARCHAR2	event name, eg oracle.apps.gmi.item.create
--		p_event_key	VARCHAR2	event key, eg ItemNo3125
-- OUT	:	x_query_id	NUMBER		one query id for all events details
-- Versions	: 1.0	17-Jul-03	created from edr_standard.Psig_Query_One
-- ---------------------------------------

PROCEDURE Get_QueryId_OnParams (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	p_commit		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_eventNames_tbl 	IN 	FND_TABLE_OF_VARCHAR2_255,
	p_eventKeys_tbl  	IN 	FND_TABLE_OF_VARCHAR2_255,
	x_query_id		OUT 	NOCOPY NUMBER )
IS
	l_api_version CONSTANT NUMBER := 1.0;
	l_api_name CONSTANT VARCHAR2(50) := 'Get_QueryId_OnParams';
BEGIN
    -- Standard call to check for call compatibility
    IF NOT fnd_api.Compatible_API_Call ( l_api_version, p_api_version, l_api_name, G_PKG_NAME )
    THEN	RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if the caller asks me to do so
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    edr_standard.Psig_Query_One(
		P_EVENT_NAME	=> p_eventNames_tbl,
		P_EVENT_KEY	=> p_eventKeys_tbl,
		O_QUERY_ID	=> x_query_id );

    IF  FND_API.To_Boolean( p_commit )  THEN
	COMMIT WORK;
    END IF;
    -- Standard call to get message count, and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF  FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )  THEN
		FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
	END IF;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
END Get_QueryId_OnParams;


-- Following procedure returns current eRecord ID for
-- event name and event key passed in

PROCEDURE GET_ERECORD_ID ( p_api_version   IN	NUMBER	    ,
                           p_init_msg_list IN	VARCHAR2 	    ,
                           x_return_status OUT	NOCOPY VARCHAR2 ,
                           x_msg_count	 OUT	NOCOPY NUMBER   ,
                           x_msg_data	 OUT	NOCOPY VARCHAR2 ,
                           p_event_name    IN   VARCHAR2        ,
                           p_event_key     IN   VARCHAR2        ,
                           x_erecord_id	 OUT NOCOPY	NUMBER         )  AS

  l_api_name CONSTANT VARCHAR2(30)	:= 'GET_ERECORD_ID';
  l_api_version   CONSTANT NUMBER 	:= 1.0;

  CURSOR GET_CUR_ERECORD_ID IS
    SELECT max(DOCUMENT_ID)
    FROM EDR_PSIG_DOCUMENTS
    WHERE EVENT_NAME = p_event_name
      AND EVENT_KEY  = p_event_key;

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

	--  Following code gets the current eRecord Id into out variable

      --Bug 3935913: Start
      -- Added security context logic
      edr_ctx_pkg.set_secure_attr;
      OPEN GET_CUR_ERECORD_ID;
      FETCH GET_CUR_ERECORD_ID INTO x_erecord_id;
      CLOSE GET_CUR_ERECORD_ID;
      edr_ctx_pkg.unset_secure_attr;
      --Bug 3935913: End
	-- Standard call to get message count and if count is 1,
	--get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count        	=>      x_msg_count     	,
        	p_data          =>      x_msg_data
    	);

EXCEPTION
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
END GET_ERECORD_ID;

--Bug 3437422: Start
PROCEDURE USER_DATA_XML (X_USER_DATA OUT NOCOPY VARCHAR2)
AS
BEGIN
  	X_USER_DATA := '#EDR_USER_DATA';
END USER_DATA_XML;
--Bug 3437422: End


-- Bug 3848049 : Start
-- API name             : GET_ERECORD_ID
-- Type                 : public
-- Function             : Accepts event name and event key and returns Latest
--                        eRecord ID
--
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   :p_event_name           IN VARCHAR2     Required
--                       p_event_key            IN VARCHAR2     Required
--
-- Return Paramter
--                       erecord_id             Return Number
--
-- Version              :Current version        1.0
--                       Initial version        1.0
--
-- Notes                 :

FUNCTION GET_ERECORD_ID ( p_event_name    IN   VARCHAR2,
                          p_event_key     IN   VARCHAR2) return NUMBER
is
L_RETURN_STATUS varchar2(100);
L_MSG_COUNT number;
l_MSG_DATA varchar2(4000);
l_erecord_id NUMBER;
BEGIN

 GET_ERECORD_ID           ( p_api_version =>1.0 ,
                            p_init_msg_list =>'T',
                           x_return_status=> l_return_status ,
                           x_msg_count=>L_MSG_COUNT  ,
                           x_msg_data=>l_MSG_DATA,
                           p_event_name=>P_EVENT_NAME ,
                           p_event_key=>p_EVENT_KEY ,
                           x_erecord_id =>L_ERECORD_ID);
 return l_ERECORD_ID;

END GET_ERECORD_ID;
--Bug 3848049 : End






END EDR_STANDARD_PUB;

/
