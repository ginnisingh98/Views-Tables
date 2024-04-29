--------------------------------------------------------
--  DDL for Package Body IBE_JTA_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_JTA_INTEGRATION_GRP" AS
/* $Header: IBEVUREJB.pls 120.0.12010000.2 2008/08/06 08:39:15 saradhak ship $ */


/*+====================================================================
| FUNCTION NAME
|    postRejection
|
| DESCRIPTION
|    This function is seeded as a subscription to the rejection event
|
| USAGE
|    -   Inactivates the contact associated with the rejected username.
|
|  REFERENCED APIS
|     This API calls the following APIs
|    		-  ibe_party_v2pvt.Update_Party_Status
|	  	-  PRM_USER_PVT.INACTIVATEPARTNERUSER
+======================================================================*/

FUNCTION postRejection(
                       p_subscription_guid      IN RAW,
                       p_event                  IN OUT NOCOPY wf_event_t)
RETURN VARCHAR2
IS

    l_key		VARCHAR2(240) := p_event.GetEventKey();
    l_id		NUMBER;
    l_userreg_id       	NUMBER;
    l_usertype_key      VARCHAR2(240);
    l_usertype_appId    VARCHAR2(240);
    l_usertype_partial  VARCHAR2(240);
    l_party_id	        NUMBER;
    l_user_id		NUMBER;
    l_change_org_status	VARCHAR2(240);
    l_return_status     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(240);
    l_usertype_partner  VARCHAR2(240);

    cur BINARY_INTEGER := DBMS_SQL.OPEN_CURSOR;
    fdbk BINARY_INTEGER;
    x_prm_return_status     VARCHAR2(40);
    x_prm_msg_count         NUMBER;
    x_prm_msg_data          VARCHAR2(40);

    /*
     Cursor C_get_party_id(c_reg_id NUMBER) IS
	select fu.customer_id from
	fnd_user fu, jtf_um_usertype_reg jureg
	where jureg.usertype_reg_id=c_reg_id
	and jureg.user_id=fu.user_id;
    */

    Cursor C_get_user_id(c_reg_id NUMBER) IS
    	select usr.user_id from
    	fnd_user usr, jtf_um_usertype_reg jureg
    	where jureg.usertype_reg_id=c_reg_id
    	and usr.user_id = jureg.user_id;

BEGIN

    -- fnd_global.apps_initialize(1007888,22372,671);

    IBE_UTIL.debug('Inside postRejection procedure');
    IBE_UTIL.debug('l_Key is '|| l_key);

    -- Check for the event and get the required WF parameters

    IBE_UTIL.debug('Getting wf params');
    l_userreg_id   := p_event.getValueForParameter(G_USERTYPEREG_ID);
    l_usertype_key := p_event.getValueForParameter(G_USERTYPE_KEY);
    l_usertype_appId := p_event.getValueForParameter(G_USERTYPE_APPID);
    l_party_id := p_event.getValueForParameter(G_USER_CUSTOMER_ID);
    IBE_UTIL.debug('l_userreg_id=' || l_userreg_id || 'l_usertype_key=' || l_usertype_key || 'l_usertype_appId=' || l_usertype_appId || 'l_party_id=' || l_party_id);

    -- Skip inactivation if username is not released

    OPEN C_get_user_id(l_userreg_id);
    FETCH C_get_user_id into l_user_id;
    CLOSE C_get_user_id;

    IF (l_user_id is null) THEN

    	    IBE_UTIL.debug('l_user_id is released. Hence continue to inactivate contact details');

	    IF (l_usertype_appId = '671' or l_usertype_appId = '672') THEN

		-- Skip inactivation for partial registrations
		-- If l_usertype_key is not in Partial_register_usertypes_lookUp  Then

		l_usertype_partial := getIsPartialRegistrationUser(l_userreg_id);
		IBE_UTIL.debug('l_usertype_partial=' || l_usertype_partial);

		If l_usertype_partial = FND_API.G_TRUE Then
			RETURN 'SUCCESS';
		Else
			-- Get the party_id corresponding to the l_Userreg_id
			/*
			OPEN C_get_party_id(l_userreg_id);
			FETCH C_get_party_id into l_party_id;
			CLOSE C_get_party_id;
			*/

			IBE_UTIL.debug('l_party_id=' || l_party_id);

			If l_party_id = null Then
				RETURN 'SUCCESS';
			End If;

			-- For B2B, decide if Company shall also be inactivated?
			l_change_org_status:=getIsUserCompanyToBeExpired(l_party_id);

			IBE_UTIL.debug('l_change_org_status=' || l_change_org_status);

			IBE_UTIL.debug('Calling Inactivation API');
			-- Call inactivation API
			ibe_party_v2pvt.Update_Party_Status(
				p_party_id=>l_party_id,
				p_party_status=>'I',
				p_change_org_status=>l_change_org_status,
				p_commit=>FND_API.G_TRUE,
				x_return_status=>l_return_status,
				x_msg_count=>l_msg_count,
				x_msg_data=>l_msg_data
			) ;
			IBE_UTIL.debug('Called Inactivation API');

			-- If ERROR, propogate.
			If l_return_status = FND_API.G_RET_STS_ERROR Then
			    WF_CORE.CONTEXT('IBE', 'postRejection',
			    p_event.getEventName(), p_subscription_guid);
			    WF_EVENT.setErrorInfo(p_event, 'l_msg_data=' || l_msg_data);
			    RETURN 'ERROR';
			End If;

/*  Bug  7145499 : PRM team responded that no records to inactivate in their tables
                   on rejection

			-- If Partner Usertype, call PRM API using dynamic sql, through dbms_sql

			l_usertype_partner := getIsPartnerUser(l_userreg_id);
			IBE_UTIL.debug('l_usertype_partner=' || l_usertype_partner);

			If l_usertype_partner = FND_API.G_TRUE Then

				DBMS_SQL.PARSE (cur,
				'BEGIN PRM_USER_PVT.INACTIVATEPARTNERUSER(:userid, :usertype, :appid, :partyid, :x_returnstatus, :x_msgcount, :x_msgdata); END;',
				DBMS_SQL.NATIVE);
				DBMS_SQL.BIND_VARIABLE (cur, 'usertype', l_usertype_key);
				DBMS_SQL.BIND_VARIABLE (cur, 'appid', l_usertype_appId);
				DBMS_SQL.BIND_VARIABLE (cur, 'partyid', l_party_id);
				DBMS_SQL.BIND_VARIABLE (cur, 'x_returnstatus', x_prm_return_status);
				DBMS_SQL.BIND_VARIABLE (cur, 'x_msgcount', x_prm_msg_count);
				DBMS_SQL.BIND_VARIABLE (cur, 'x_msgdata', x_prm_msg_data);

				fdbk := DBMS_SQL.EXECUTE (cur);
				DBMS_SQL.VARIABLE_VALUE (cur, 'x_returnstatus', x_prm_return_status);
				DBMS_SQL.VARIABLE_VALUE (cur, 'x_msgcount', x_prm_msg_count);
				DBMS_SQL.VARIABLE_VALUE (cur, 'x_msgdata', x_prm_msg_data);

				IBE_UTIL.debug('x_prm_return_status ' || x_prm_return_status);
				IBE_UTIL.debug('x_prm_msg_count ' || to_char(x_prm_msg_count));
				IBE_UTIL.debug('x_prm_msg_data ' || x_prm_msg_data);

				If x_prm_return_status = FND_API.G_FALSE Then
					DBMS_SQL.CLOSE_CURSOR (cur);
					IBE_UTIL.debug('Returning ERROR due to PRM');
					WF_CORE.CONTEXT('IBE', 'postRejection',
					p_event.getEventName(), p_subscription_guid);
					WF_EVENT.setErrorInfo(p_event, 'ERROR due to PRM : x_prm_msg_data=' || x_prm_msg_data);
					RETURN 'ERROR';
				End If;

			End If;

			DBMS_SQL.CLOSE_CURSOR (cur);
*/
		 End If;

	    END IF;
    ELSE
    	IBE_UTIL.debug('l_user_id is not released. Hence skipping inactivation of contact details');
    END IF;

    IBE_UTIL.debug('Returning SUCCESS');
    RETURN 'SUCCESS';

EXCEPTION
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     	            WF_CORE.CONTEXT('IBE', 'postRejection',
     	            p_event.getEventName(), p_subscription_guid);
     	            WF_EVENT.setErrorInfo(p_event, 'UNEXPECTED ERROR');
    		    RETURN 'ERROR';
     WHEN OTHERS THEN
	            WF_CORE.CONTEXT('IBE', 'postRejection',
	            p_event.getEventName(), p_subscription_guid);
	            WF_EVENT.setErrorInfo(p_event, 'ERROR');
    		    RETURN 'ERROR';
END;



/*+====================================================================
| FUNCTION NAME
|    getIsUserCompanyToBeExpired
|
| DESCRIPTION
|    This API is called by postRejection
|
| USAGE
|    -   To determine if Company details are also to be inactivated?
|
|  REFERENCED APIS
+======================================================================*/

FUNCTION getIsUserCompanyToBeExpired(
		p_contact_party_id IN NUMBER)
RETURN VARCHAR2
IS
l_company_rel_count NUMBER;

BEGIN
	select count(*) into l_company_rel_count from
	hz_relationships hr
	where hr.object_id in(
		  		select object_id from hz_relationships
				where party_id=p_contact_party_id
				and relationship_code='EMPLOYEE_OF'
			     )
	and status<>'I';
	IF l_company_rel_count < 2 THEN
		RETURN FND_API.G_TRUE;
	ELSE
		RETURN FND_API.G_FALSE;
	END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
	-- must be B2C
	RETURN FND_API.G_FALSE;
END;



/*+====================================================================
| FUNCTION NAME
|    getIsPartialRegistrationUser
|
| DESCRIPTION
|    This API is called by postRejection
|
| USAGE
|    -   Determines whether the user under rejection had registered
|	 using one of the partial registration usertypes
|
|  REFERENCED APIS
+======================================================================*/

FUNCTION getIsPartialRegistrationUser(
		p_user_reg_id IN NUMBER)
RETURN VARCHAR2
IS
l_usertype_group VARCHAR2(240) := 'IBE_UM_PARTIAL_USER_TYPES';
l_usertype_key VARCHAR2(240);

Cursor C_check_user_type(c_lookup_type VARCHAR2) IS
	select ut.usertype_key
	from jtf_um_usertypes_b ut, jtf_um_usertype_reg ureg, fnd_lookup_values flv
	where ut.usertype_id=ureg.usertype_id
	and ureg.usertype_reg_id=p_user_reg_id
	and flv.lookup_type=c_lookup_type
	and ut.usertype_key=flv.lookup_code;

BEGIN
	OPEN C_check_user_type(l_usertype_group);
	FETCH C_check_user_type into l_usertype_key;
	IF C_check_user_type%NOTFOUND THEN
		IBE_UTIL.debug('Not a partial registration type');
		CLOSE C_check_user_type;
		RETURN FND_API.G_FALSE;
	END IF;

	IBE_UTIL.debug('Is a partial registration type');
	CLOSE C_check_user_type;
	RETURN FND_API.G_TRUE;

EXCEPTION
WHEN NO_DATA_FOUND THEN
	RETURN FND_API.G_FALSE;
WHEN OTHERS THEN
	RETURN FND_API.G_FALSE;
END;



/*+====================================================================
| FUNCTION NAME
|    getIsPartnerUser
|
| DESCRIPTION
|    This API is called by postRejection
|
| USAGE
|    -   Determines whether the user under rejection had registered
|	 using one of the partner registration usertypes
|
|  REFERENCED APIS
+======================================================================*/

FUNCTION getIsPartnerUser(
		p_user_reg_id IN NUMBER)
RETURN VARCHAR2
IS
l_usertype_group VARCHAR2(240) := 'IBE_UM_PARTNER_USER_TYPES';
l_usertype_key VARCHAR2(240);

Cursor C_check_user_type(c_lookup_type VARCHAR2) IS
	select ut.usertype_key
	from jtf_um_usertypes_b ut, jtf_um_usertype_reg ureg, fnd_lookup_values flv
	where ut.usertype_id=ureg.usertype_id
	and ureg.usertype_reg_id=p_user_reg_id
	and flv.lookup_type=c_lookup_type
	and ut.usertype_key=flv.lookup_code;

BEGIN
	OPEN C_check_user_type(l_usertype_group);
	FETCH C_check_user_type into l_usertype_key;
	IF C_check_user_type%NOTFOUND THEN
		IBE_UTIL.debug('Not a partner registration type');
		CLOSE C_check_user_type;
		RETURN FND_API.G_FALSE;
	END IF;

	IBE_UTIL.debug('Is a partner registration type');
	CLOSE C_check_user_type;
	RETURN FND_API.G_TRUE;

EXCEPTION
WHEN NO_DATA_FOUND THEN
	RETURN FND_API.G_FALSE;
WHEN OTHERS THEN
	RETURN FND_API.G_FALSE;
END;



END IBE_JTA_INTEGRATION_GRP;


/
