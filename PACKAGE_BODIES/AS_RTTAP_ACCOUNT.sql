--------------------------------------------------------
--  DDL for Package Body AS_RTTAP_ACCOUNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_RTTAP_ACCOUNT" as
/* $Header: asxrtacb.pls 120.6.12000000.2 2007/04/26 13:28:08 annsrini ship $ */

TYPE ResourceList is VARRAY(10000) OF NUMBER(15);
TYPE GroupList is VARRAY(10000) OF NUMBER(15);

TYPE ResourceRec is RECORD (
	resource_id ResourceList := ResourceList(),
	group_id    GroupList := GroupList());
G_ENTITY CONSTANT VARCHAR2(20) := 'GAR::ACCOUNTS::RT::';
G_PARTY_ID NUMBER;
G_PKG_NAME CONSTANT VARCHAR2(20) := 'AS_RTTAP_ACCOUNT';

PROCEDURE PROCESS_RTTAP_ACCOUNT(p_party_Id NUMBER,p_return_status OUT NOCOPY VARCHAR2)
IS
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(2000);
    l_event_key        VARCHAR2(240);
    l_return_status    VARCHAR2(1);
    tap_return_status   VARCHAR2(1);
BEGIN

	IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
	     AS_GAR.g_debug_flag := 'Y';
        END IF;

	AS_BUSINESS_EVENT_PUB.Before_Cust_STeam_Update(
	    p_api_version_number        => 2.0,
	    p_init_msg_list             => FND_API.G_FALSE,
	    p_commit                    => FND_API.G_FALSE,
	    p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
	    p_cust_id                   => P_party_id,
	    x_return_status             => l_return_status,
	    x_msg_count                 => l_msg_count,
	    x_msg_data                  => l_msg_data,
	    x_event_key                 => l_event_key);
	 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		AS_GAR.LOG('BE FOR ACCOUNT REALTIME TAP BEFORE UPDATE FAILED');
		l_event_key := NULL;
	 END IF;

	 RTTAP_WRAPPER(p_party_Id,p_return_status);

	 IF l_event_key IS NOT NULL
	 THEN
		AS_BUSINESS_EVENT_PUB.Upd_Cust_STeam_post_event(
		  p_api_version_number        => 2.0,
		  p_init_msg_list             => FND_API.G_FALSE,
		  p_commit                    => FND_API.G_FALSE,
		  p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
		  p_cust_id                   => p_party_id,
		  p_event_key                 => l_event_key,
		  x_return_status             => l_return_status,
		  x_msg_count                 => l_msg_count,
		  x_msg_data                  => l_msg_data);
	 END IF;
	 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		AS_GAR.LOG('BE FOR ACCOUNT REALTIME TAP AFTER UPDATE FAILED');
	 END IF;

END PROCESS_RTTAP_ACCOUNT;

FUNCTION CREATE_ORGANIZATION_POST ( p_subscription_guid IN RAW, p_event IN OUT NOCOPY wf_event_t ) RETURN VARCHAR2 IS
p_return_status VARCHAR2(1);
BEGIN
	PROCESS_RTTAP_ACCOUNT(p_event.GetValueForParameter('PARTY_ID'),p_return_status);
	IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	RETURN 'SUCCESS';
EXCEPTION
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		WF_CORE.CONTEXT('AS_RTTAP_ACCOUNT', 'CREATE_ORGANIZATION_POST', p_event.getEventName(), p_subscription_guid);
		WF_EVENT.setErrorInfo(p_event, 'ERROR');
		RETURN 'ERROR';
	WHEN OTHERS THEN
		WF_CORE.CONTEXT('AS_RTTAP_ACCOUNT', 'CREATE_ORGANIZATION_POST', p_event.getEventName(), p_subscription_guid);
		WF_EVENT.setErrorInfo(p_event, 'ERROR');
	RETURN 'ERROR';
END CREATE_ORGANIZATION_POST;

FUNCTION UPDATE_ORGANIZATION_POST ( p_subscription_guid IN RAW, p_event IN OUT NOCOPY wf_event_t ) RETURN VARCHAR2 IS
p_return_status VARCHAR2(1);
BEGIN
   PROCESS_RTTAP_ACCOUNT(p_event.GetValueForParameter('PARTY_ID'),p_return_status);
	IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	RETURN 'SUCCESS';
EXCEPTION
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		WF_CORE.CONTEXT('AS_RTTAP_ACCOUNT', 'UPDATE_ORGANIZATION_POST', p_event.getEventName(), p_subscription_guid);
		WF_EVENT.setErrorInfo(p_event, 'ERROR');
		RETURN 'ERROR';
	WHEN OTHERS THEN
		WF_CORE.CONTEXT('AS_RTTAP_ACCOUNT', 'UPDATE_ORGANIZATION_POST', p_event.getEventName(), p_subscription_guid);
		WF_EVENT.setErrorInfo(p_event, 'ERROR');
	RETURN 'ERROR';
END;

FUNCTION CREATE_PERSON_POST ( p_subscription_guid IN RAW, p_event IN OUT NOCOPY wf_event_t ) RETURN VARCHAR2 IS
p_return_status VARCHAR2(1);
BEGIN
   PROCESS_RTTAP_ACCOUNT(p_event.GetValueForParameter('PARTY_ID'),p_return_status);
	IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	RETURN 'SUCCESS';
EXCEPTION
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		WF_CORE.CONTEXT('AS_RTTAP_ACCOUNT', 'CREATE_PERSON_POST', p_event.getEventName(), p_subscription_guid);
		WF_EVENT.setErrorInfo(p_event, 'ERROR');
		RETURN 'ERROR';
	WHEN OTHERS THEN
		WF_CORE.CONTEXT('AS_RTTAP_ACCOUNT', 'CREATE_PERSON_POST', p_event.getEventName(), p_subscription_guid);
		WF_EVENT.setErrorInfo(p_event, 'ERROR');
	RETURN 'ERROR';
END;


FUNCTION UPDATE_PERSON_POST ( p_subscription_guid IN RAW, p_event IN OUT NOCOPY wf_event_t ) RETURN VARCHAR2 IS
p_return_status VARCHAR2(1);
BEGIN
    PROCESS_RTTAP_ACCOUNT(p_event.GetValueForParameter('PARTY_ID'),p_return_status);
	IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	RETURN 'SUCCESS';
EXCEPTION
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		WF_CORE.CONTEXT('AS_RTTAP_ACCOUNT', 'UPDATE_PERSON_POST', p_event.getEventName(), p_subscription_guid);
		WF_EVENT.setErrorInfo(p_event, 'ERROR');
		RETURN 'ERROR';
	WHEN OTHERS THEN
		WF_CORE.CONTEXT('AS_RTTAP_ACCOUNT', 'UPDATE_PERSON_POST', p_event.getEventName(), p_subscription_guid);
		WF_EVENT.setErrorInfo(p_event, 'ERROR');
	RETURN 'ERROR';

END;

FUNCTION CREATE_PARTY_SITE_POST ( p_subscription_guid IN RAW, p_event IN OUT NOCOPY wf_event_t ) RETURN VARCHAR2 IS
	CURSOR c1 IS
	SELECT party_id
	FROM HZ_PARTY_SITES
	WHERE party_site_id = p_event.GetValueForParameter('PARTY_SITE_ID');
l_party_id NUMBER;
p_return_status VARCHAR2(1);
BEGIN
    OPEN c1;
    FETCH c1 INTO l_party_id;
    CLOSE c1;
    PROCESS_RTTAP_ACCOUNT(l_party_id,p_return_status);
	IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	RETURN 'SUCCESS';
EXCEPTION
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		WF_CORE.CONTEXT('AS_RTTAP_ACCOUNT', 'CREATE_PARTY_SITE_POST', p_event.getEventName(), p_subscription_guid);
		WF_EVENT.setErrorInfo(p_event, 'ERROR');
		RETURN 'ERROR';
	WHEN OTHERS THEN
		WF_CORE.CONTEXT('AS_RTTAP_ACCOUNT', 'CREATE_PARTY_SITE_POST', p_event.getEventName(), p_subscription_guid);
		WF_EVENT.setErrorInfo(p_event, 'ERROR');
	RETURN 'ERROR';

END;

FUNCTION UPDATE_PARTY_SITE_POST ( p_subscription_guid IN RAW, p_event IN OUT NOCOPY wf_event_t ) RETURN VARCHAR2 IS
	CURSOR c1 IS
	SELECT party_id
	FROM HZ_PARTY_SITES
	WHERE party_site_id = p_event.GetValueForParameter('PARTY_SITE_ID');
l_party_id NUMBER;
p_return_status VARCHAR2(1);
BEGIN
    OPEN c1;
    FETCH c1 INTO l_party_id;
    CLOSE c1;
    PROCESS_RTTAP_ACCOUNT(l_party_id,p_return_status);
	IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	RETURN 'SUCCESS';
EXCEPTION
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		WF_CORE.CONTEXT('AS_RTTAP_ACCOUNT', 'UPDATE_PARTY_SITE_POST', p_event.getEventName(), p_subscription_guid);
		WF_EVENT.setErrorInfo(p_event, 'ERROR');
		RETURN 'ERROR';
	WHEN OTHERS THEN
		WF_CORE.CONTEXT('AS_RTTAP_ACCOUNT', 'UPDATE_PARTY_SITE_POST', p_event.getEventName(), p_subscription_guid);
		WF_EVENT.setErrorInfo(p_event, 'ERROR');
	RETURN 'ERROR';

END;


FUNCTION CREATE_CONTACT_POINT_POST ( p_subscription_guid IN RAW, p_event IN OUT NOCOPY wf_event_t ) RETURN VARCHAR2 IS
	CURSOR c1 IS
		SELECT owner_table_name,owner_table_id
		FROM hz_contact_points
		WHERE contact_point_id = p_event.GetValueForParameter('CONTACT_POINT_ID')
		AND primary_flag = 'Y'
		AND contact_point_type ='PHONE'
		AND status <>'I';
	CURSOR c2(p_party_site_id NUMBER) IS
		SELECT party_id
		FROM hz_party_sites
		WHERE party_site_id= p_party_site_id;

    l_owner_table_name VARCHAR2(30);
    l_owner_table_id   NUMBER;
    l_party_id	NUMBER;
    p_return_status VARCHAR2(1);
BEGIN
      OPEN c1;
      FETCH c1 INTO l_owner_table_name,l_owner_table_id;
      If (c1%NOTFOUND) THEN
          CLOSE c1;
	   RETURN 'SUCCESS';
      END IF;
      Close c1;

      IF l_owner_table_name= 'HZ_PARTY_SITES' THEN
          OPEN C2(l_owner_table_id);
	  FETCH C2 INTO l_party_id;
	  CLOSE C2;
	  PROCESS_RTTAP_ACCOUNT(l_party_id,p_return_status);
      ELSIF  l_owner_table_name = 'HZ_PARTIES' THEN
	   PROCESS_RTTAP_ACCOUNT(l_owner_table_id,p_return_status);
      END IF;
	IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	RETURN 'SUCCESS';
EXCEPTION
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		WF_CORE.CONTEXT('AS_RTTAP_ACCOUNT', 'CREATE_CONTACT_POINT_POST', p_event.getEventName(), p_subscription_guid);
		WF_EVENT.setErrorInfo(p_event, 'ERROR');
		RETURN 'ERROR';
	WHEN OTHERS THEN
		WF_CORE.CONTEXT('AS_RTTAP_ACCOUNT', 'CREATE_CONTACT_POINT_POST', p_event.getEventName(), p_subscription_guid);
		WF_EVENT.setErrorInfo(p_event, 'ERROR');
	RETURN 'ERROR';

END CREATE_CONTACT_POINT_POST;

FUNCTION UPDATE_CONTACT_POINT_POST ( p_subscription_guid IN RAW, p_event IN OUT NOCOPY wf_event_t ) RETURN VARCHAR2 IS
   CURSOR C1 IS
       SELECT owner_table_name,owner_table_id
         FROM hz_contact_points
	WHERE contact_point_id = p_event.GetValueForParameter('CONTACT_POINT_ID')
	  AND primary_flag = 'Y'
	  AND contact_point_type ='PHONE'
	  AND status <>'I';
   CURSOR C2(p_party_site_id NUMBER) IS
        SELECT party_id
        FROM hz_party_sites
        WHERE party_site_id=   p_party_site_id;

    l_owner_table_name VARCHAR2(30);
    l_owner_table_id   NUMBER;
    l_party_id	NUMBER;
    p_return_status VARCHAR2(1);
BEGIN
      OPEN c1;
      FETCH c1 into l_owner_table_name,l_owner_table_id;
      IF (c1%NOTFOUND) then
          CLOSE c1;
          RETURN 'SUCCESS';
      END IF;
      CLOSE c1;

      IF l_owner_table_name= 'HZ_PARTY_SITES' THEN
          OPEN C2(l_owner_table_id);
	  FETCH C2 INTO l_party_id;
	  CLOSE C2;
	  PROCESS_RTTAP_ACCOUNT(l_party_id,p_return_status);
      ELSIF  l_owner_table_name = 'HZ_PARTIES' THEN
	   PROCESS_RTTAP_ACCOUNT(l_owner_table_id,p_return_status);
      END IF;
      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      RETURN 'SUCCESS';
EXCEPTION
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		WF_CORE.CONTEXT('AS_RTTAP_ACCOUNT', 'UPDATE_CONTACT_POINT_POST', p_event.getEventName(), p_subscription_guid);
		WF_EVENT.setErrorInfo(p_event, 'ERROR');
		RETURN 'ERROR';
	WHEN OTHERS THEN
		WF_CORE.CONTEXT('AS_RTTAP_ACCOUNT', 'UPDATE_CONTACT_POINT_POST', p_event.getEventName(), p_subscription_guid);
		WF_EVENT.setErrorInfo(p_event, 'ERROR');
	RETURN 'ERROR';

END UPDATE_CONTACT_POINT_POST;

FUNCTION UPDATE_LOCATION_POST ( p_subscription_guid IN RAW, p_event IN OUT NOCOPY wf_event_t ) RETURN VARCHAR2 IS

        CURSOR C2 IS
        SELECT DISTINCT party_id
        FROM   AS_PARTY_ADDRESSES_V
        WHERE location_id = p_event.GetValueForParameter('LOCATION_ID') ;
p_return_status VARCHAR2(1);
BEGIN
        FOR cur_party IN C2 LOOP
		PROCESS_RTTAP_ACCOUNT(cur_party.party_id,p_return_status);
		IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	END LOOP;
	RETURN 'SUCCESS';
EXCEPTION
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		WF_CORE.CONTEXT('AS_RTTAP_ACCOUNT', 'UPDATE_LOCATION_POST', p_event.getEventName(), p_subscription_guid);
		WF_EVENT.setErrorInfo(p_event, 'ERROR');
		RETURN 'ERROR';
	WHEN OTHERS THEN
		WF_CORE.CONTEXT('AS_RTTAP_ACCOUNT', 'UPDATE_LOCATION_POST', p_event.getEventName(), p_subscription_guid);
		WF_EVENT.setErrorInfo(p_event, 'ERROR');
	RETURN 'ERROR';
END UPDATE_LOCATION_POST;

PROCEDURE RTTAP_WRAPPER(
    p_party_id			 IN  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2
    )
IS


	l_errbuf        VARCHAR2(4000);
	l_retcode       VARCHAR2(255);
	l_msg_count	NUMBER;
	l_msg_data	VARCHAR2(255);
	l_trans_rec	JTY_ASSIGN_REALTIME_PUB.bulk_trans_id_type;
	l_WinningTerrMember_tbl	JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type;
	l_return_status    VARCHAR2(1);

BEGIN

	G_PARTY_ID := p_party_id;

        -- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( FND_API.G_FALSE ) THEN
          FND_MSG_PUB.initialize;
	END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF NVL(FND_PROFILE.Value('AS_ENABLE_CUST_ONLINE_TAP'), 'N') <> 'Y' THEN
		/*------------------------------------------------------+
		|	If REALTIME TAP profile is turned on there is NO need
		|	to insert into changed accounts since the ACCOUNT is
		|	processed immediately.
		+-------------------------------------------------------*/
			INSERT INTO AS_CHANGED_ACCOUNTS_ALL
			(	   customer_id,
				   address_id,
				   last_update_date,
				   last_updated_by,
				   creation_date,
				   created_by,
				   last_update_login,
				   change_type )
			SELECT  G_PARTY_ID,
				    NULL,
				    SYSDATE,
				    0,
				    SYSDATE,
				    0,
				    0,
				    'ACCOUNT'
			FROM    DUAL
			WHERE	NOT EXISTS
			(	SELECT 'X'
				FROM	AS_CHANGED_ACCOUNTS_ALL ACC
				WHERE	ACC.customer_id = G_PARTY_ID
				AND     ACC.lead_id IS NULL
				AND     ACC.sales_lead_id IS NULL
				AND		ACC.request_id IS NULL	);

	ELSE
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CW || AS_GAR.G_START);


		l_trans_rec.trans_object_id1 := jtf_terr_number_list(G_PARTY_ID);
		l_trans_rec.trans_object_id2 := jtf_terr_number_list(null);
		l_trans_rec.trans_object_id3 := jtf_terr_number_list(null);
		l_trans_rec.trans_object_id4 := jtf_terr_number_list(null);
		l_trans_rec.trans_object_id5 := jtf_terr_number_list(null);
		l_trans_rec.txn_date := jtf_terr_date_list(null);
		  JTY_ASSIGN_REALTIME_PUB.get_winners(
		    p_api_version_number       => 1.0,
		    p_init_msg_list            => FND_API.G_FALSE,
		    p_source_id                => -1001,
		    p_trans_id                 => -1002,
		    p_mode                     => 'REAL TIME:RESOURCE',
		    p_param_passing_mechanism  => 'PBR',
		    p_program_name             => 'SALES/ACCOUNT PROGRAM',
		    p_trans_rec                => l_trans_rec,
		    p_name_value_pair          => null,
		    p_role                     => null,
		    p_resource_type            => null,
		    x_return_status            => l_return_status,
		    x_msg_count                => l_msg_count,
		    x_msg_data                 => l_msg_data,
		    x_winners_rec              => l_WinningTerrMember_tbl);
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CW || AS_GAR.G_END);
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CW || AS_GAR.G_RETURN_STATUS || l_return_status);
		If l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			FND_MSG_PUB.Count_And_Get
				(  p_count          =>   l_msg_count,
				   p_data           =>   l_msg_data
			        );
			AS_UTILITY_PVT.Get_Messages(l_msg_count, l_msg_data);
			AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CW, l_msg_data, 'ERROR');
			RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
		End If;
		If (l_WinningTerrMember_tbl.resource_id.count > 0) THEN
		      FOR i IN l_WinningTerrMember_tbl.terr_id.FIRST .. l_WinningTerrMember_tbl.terr_id.LAST LOOP
		          AS_GAR.LOG(G_ENTITY ||  'Trans Object ID : ' || l_WinningTerrMember_tbl.trans_object_id(i) ||
					     'Trans Detail Object ID : ' || l_WinningTerrMember_tbl.trans_detail_object_id(i) ||
					     'Terr ID : ' || l_WinningTerrMember_tbl.terr_id(i) || ' Terr Name : ' || l_WinningTerrMember_tbl.terr_name(i) ||
					     ' Resource ID : ' || l_WinningTerrMember_tbl.resource_id(i) ||
					     ' Resource TYPE : ' || l_WinningTerrMember_tbl.resource_type(i));
		      END LOOP;
			-- Explode GROUPS if any inside winners
			AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CEX_GROUPS || AS_GAR.G_START);
			AS_RTTAP_ACCOUNT.EXPLODE_GROUPS_ACCOUNTS(
				  x_errbuf        => l_errbuf,
				  x_retcode       => l_retcode,
				  p_WinningTerrMember_tbl  => l_WinningTerrMember_tbl,
				  x_return_status => l_return_status);

			AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CEX_GROUPS || AS_GAR.G_END);
			AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CEX_GROUPS || AS_GAR.G_RETURN_STATUS || l_return_status);

			If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
			  AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CEX_GROUPS, l_errbuf, l_retcode);
			  RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
			End If;

			-- Explode TEAMS if any inside winners
			AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CEX_TEAMS || AS_GAR.G_START);
			AS_RTTAP_ACCOUNT.EXPLODE_TEAMS_ACCOUNTS(
				  x_errbuf        => l_errbuf,
				  x_retcode       => l_retcode,
				  p_WinningTerrMember_tbl  => l_WinningTerrMember_tbl,
				  x_return_status => l_return_status);

			AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CEX_TEAMS || AS_GAR.G_END);
			AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CEX_TEAMS || AS_GAR.G_RETURN_STATUS || l_return_status);

			If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
			  AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CEX_TEAMS, l_errbuf, l_retcode);
			  RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
			End If;

			-- Set team leader for ACCOUNTs
			AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_STLEAD || AS_GAR.G_START);
			AS_RTTAP_ACCOUNT.SET_TEAM_LEAD_ACCOUNTS(
				x_errbuf        => l_errbuf,
				x_retcode       => l_retcode,
				p_WinningTerrMember_tbl  => l_WinningTerrMember_tbl,
				x_return_status => l_return_status);

			AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_STLEAD || AS_GAR.G_END);
			AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_STLEAD || AS_GAR.G_RETURN_STATUS || l_return_status);

			If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
			  AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_STLEAD, l_errbuf, l_retcode);
			  RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
			End If;

			 -- Insert into ACCOUNT Accesses from Winners
			AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_INSACC || AS_GAR.G_START);
			AS_RTTAP_ACCOUNT.INSERT_ACCESSES_ACCOUNTS(
				x_errbuf        => l_errbuf,
				x_retcode       => l_retcode,
				p_WinningTerrMember_tbl  => l_WinningTerrMember_tbl,
				x_return_status => l_return_status);

			AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_INSACC || AS_GAR.G_END);
			AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_INSACC || AS_GAR.G_RETURN_STATUS || l_return_status);

			If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
			  AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_INSACC, l_errbuf, l_retcode);
			  RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
			End If;

			 -- Insert into territory Accesses
			AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_INSTERRACC || AS_GAR.G_START);
			AS_RTTAP_ACCOUNT.INSERT_TERR_ACCESSES_ACCOUNTS(
				x_errbuf        => l_errbuf,
				x_retcode       => l_retcode,
				p_WinningTerrMember_tbl  => l_WinningTerrMember_tbl,
				x_return_status => l_return_status);

			AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_INSTERRACC || AS_GAR.G_END);
			AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_INSTERRACC || AS_GAR.G_RETURN_STATUS || l_return_status);

			If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
			  AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_INSTERRACC, l_errbuf, l_retcode);
			  RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
			End If;
		End If;

		-- Remove (soft delete) records in access table that are not qualified
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CC || AS_GAR.G_START);
		AS_RTTAP_ACCOUNT.PERFORM_ACCOUNT_CLEANUP(
				  x_errbuf        => l_errbuf,
				  x_retcode       => l_retcode,
				  p_WinningTerrMember_tbl  => l_WinningTerrMember_tbl,
				  x_return_status => l_return_status);

		AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CC || AS_GAR.G_END);
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CC || AS_GAR.G_RETURN_STATUS || l_return_status);

		If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
		  AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_CALL_TO || AS_GAR.G_CC, l_errbuf, l_retcode);
		  RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
		End If;

	END IF;

       COMMIT;

EXCEPTION
	  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
          WHEN OTHERS THEN
	        AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_TEAMS, SQLERRM, TO_CHAR(SQLCODE));
		x_return_status := FND_API.G_RET_STS_ERROR;
END RTTAP_WRAPPER;


/************************** Start Explode Teams ACCOUNTs ******************/
PROCEDURE EXPLODE_TEAMS_ACCOUNTS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    OUT NOCOPY VARCHAR2)
IS

 /*-------------------------------------------------------------------------+
 |                             LOGIC
 |
 | A RESOURCE team can be comprised OF resources who belong TO one OR more
 | GROUPS OF resources.
 | So get a LIST OF team members (OF TYPE employee OR partner OR parter contact
 | AND play a ROLE OF salesrep ) AND get atleast one GROUP id that they belong TO
 | WHERE they play a similar ROLE.
 | UNION THE above WITH a LIST OF ALL members OF ALL GROUPS which BY themselves
 | are a RESOURCE within a team.
 | INSERT these members INTO winners IF they are NOT already IN winners.
 +-------------------------------------------------------------------------*/

l_errbuf         VARCHAR2(4000);
l_retcode        VARCHAR2(255);
TYPE num_list  is TABLE of NUMBER INDEX BY BINARY_INTEGER;
TYPE vchar_list  is TABLE of VARCHAR2(30) INDEX BY BINARY_INTEGER;


l_resource_id    num_list;
l_group_id       num_list;
l_person_id      num_list;
l_resource_type  vchar_list;


BEGIN
   AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_TEAMS || AS_GAR.G_START);
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   /* Get resources within a resource team */
   /** Note
     Hard coding RS_EMPLOYEE INSTEAD OF resource_category IN following SQL
     because JTA returns RS_EMPLOYEE AND NOT EMPLOYEE
   **/
   AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_TEAMS || AS_GAR.G_INS_WINNERS || AS_GAR.G_START);
   IF p_WinningTerrMember_tbl.resource_id.COUNT > 0 THEN
        FOR l_index IN p_WinningTerrMember_tbl.resource_id.FIRST..p_WinningTerrMember_tbl.resource_id.LAST LOOP
				IF p_WinningTerrMember_tbl.resource_type(l_index) = 'RS_TEAM' THEN

						SELECT resource_id,  group_id,person_id, DECODE(resource_category,'PARTY','RS_PARTY',
														  'PARTNER','RS_PARTNER',
									                                          'EMPLOYEE','RS_EMPLOYEE','UNKNOWN') resource_type
						BULK COLLECT INTO l_resource_id, l_group_id,l_person_id,l_resource_type
						FROM
						(
							 SELECT TM.team_resource_id resource_id,
								TM.person_id person_id2,
								MIN(G.group_id)group_id,
								MIN(T.team_id) team_id,
								TRES.CATEGORY resource_category,
								MIN(TRES.source_id) person_id
							 FROM  jtf_rs_team_members TM, jtf_rs_teams_b T,
								   jtf_rs_team_usages TU, jtf_rs_role_relations TRR,
								   jtf_rs_roles_b TR, jtf_rs_resource_extns TRES,
								   (
								SELECT m.group_id group_id, m.resource_id resource_id
								FROM   jtf_rs_group_members m,
									   jtf_rs_groups_b g,
									   jtf_rs_group_usages u,
									   jtf_rs_role_relations rr,
									   jtf_rs_roles_b r,
									   jtf_rs_resource_extns res
								WHERE  m.group_id = g.group_id
								AND    SYSDATE BETWEEN NVL(g.start_date_active,SYSDATE)
								AND    NVL(g.end_date_active,SYSDATE)
								AND    u.group_id = g.group_id
								AND    u.usage IN ('SALES','PRM')
								AND    m.group_member_id = rr.role_resource_id
								AND    rr.role_resource_type = 'RS_GROUP_MEMBER'
								AND    rr.delete_flag <> 'Y'
								AND    SYSDATE BETWEEN rr.start_date_active
								AND    NVL(rr.end_date_active,SYSDATE)
								AND    rr.role_id = r.role_id
								AND    r.role_type_code
									   IN ('SALES', 'TELESALES', 'FIELDSALES','PRM')
								AND    r.active_flag = 'Y'
								AND    res.resource_id = m.resource_id
								AND    res.CATEGORY IN ('EMPLOYEE','PARTY','PARTNER')
								 )  G
							WHERE tm.team_id = t.team_id
							AND   SYSDATE BETWEEN NVL(t.start_date_active,SYSDATE)
							AND   NVL(t.end_date_active,SYSDATE)
							AND   tu.team_id = t.team_id
							AND   tu.usage IN ('SALES','PRM')
							AND   tm.team_member_id = trr.role_resource_id
							AND   tm.delete_flag <> 'Y'
							AND   tm.resource_type = 'INDIVIDUAL'
							AND   trr.role_resource_type = 'RS_TEAM_MEMBER'
							AND   trr.delete_flag <> 'Y'
							AND   SYSDATE BETWEEN trr.start_date_active
									AND   NVL(trr.end_date_active,SYSDATE)
							AND   trr.role_id = tr.role_id
							AND   tr.role_type_code IN
								  ('SALES', 'TELESALES', 'FIELDSALES', 'PRM')
							AND   tr.active_flag = 'Y'
							AND   tres.resource_id = tm.team_resource_id
							AND   tres.category IN ('EMPLOYEE','PARTY','PARTNER')
							AND   tm.team_resource_id = g.resource_id
							GROUP BY tm.team_resource_id,
								 tm.person_id,
								 tres.CATEGORY,
								 tres.source_id
						 UNION ALL
							 SELECT    MIN(m.resource_id) resource_id,
									   MIN(m.person_id) person_id2, MIN(m.group_id) group_id,
									   MIN(jtm.team_id) team_id, res.CATEGORY resource_category,
									   MIN(res.source_id) person_id
							FROM  jtf_rs_group_members m, jtf_rs_groups_b g,
								  jtf_rs_group_usages u, jtf_rs_role_relations rr,
								  jtf_rs_roles_b r, jtf_rs_resource_extns res,
								  (
								   SELECT tm.team_resource_id group_id,
								   t.team_id team_id
								   FROM   jtf_rs_team_members tm, jtf_rs_teams_b t,
									  jtf_rs_team_usages tu,jtf_rs_role_relations trr,
									  jtf_rs_roles_b tr, jtf_rs_resource_extns tres
								   WHERE  tm.team_id = t.team_id
								   AND   SYSDATE BETWEEN NVL(t.start_date_active,SYSDATE)
								   AND   NVL(t.end_date_active,SYSDATE)
								   AND   tu.team_id = t.team_id
								   AND   tu.usage IN ('SALES','PRM')
								   AND   tm.team_member_id = trr.role_resource_id
								   AND   tm.delete_flag <> 'Y'
								   AND   tm.resource_type = 'GROUP'
								   AND   trr.role_resource_type = 'RS_TEAM_MEMBER'
								   AND   trr.delete_flag <> 'Y'
								   AND   SYSDATE BETWEEN trr.start_date_active
								   AND   NVL(trr.end_date_active,SYSDATE)
								   AND   trr.role_id = tr.role_id
								   AND   tr.role_type_code IN
									 ('SALES', 'TELESALES', 'FIELDSALES', 'PRM')
								   AND   tr.active_flag = 'Y'
								   AND   tres.resource_id = tm.team_resource_id
								   AND   tres.category IN ('EMPLOYEE','PARTY','PARTNER')
								   ) jtm
							WHERE m.group_id = g.group_id
							AND   SYSDATE BETWEEN NVL(g.start_date_active,SYSDATE)
							AND   NVL(g.end_date_active,SYSDATE)
							AND   u.group_id = g.group_id
							AND   u.usage IN ('SALES','PRM')
							AND   m.group_member_id = rr.role_resource_id
							AND   rr.role_resource_type = 'RS_GROUP_MEMBER'
							AND   rr.delete_flag <> 'Y'
							AND   SYSDATE BETWEEN rr.start_date_active
									AND   NVL(rr.end_date_active,SYSDATE)
							AND   rr.role_id = r.role_id
							AND   r.role_type_code IN
								  ('SALES', 'TELESALES', 'FIELDSALES', 'PRM')
							AND   r.active_flag = 'Y'
							AND   res.resource_id = m.resource_id
							AND   res.category IN ('EMPLOYEE','PARTY','PARTNER')
							AND   jtm.group_id = g.group_id
							GROUP BY m.resource_id, m.person_id, jtm.team_id, res.CATEGORY) J

						WHERE j.team_id = p_WinningTerrMember_tbl.resource_id(l_index);
						AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_GROUPS || AS_GAR.G_INS_WINNERS ||
						AS_GAR.G_N_ROWS_PROCESSED || SQL%ROWCOUNT ||' FOR TEAM '||p_WinningTerrMember_tbl.resource_id(l_index));

						IF l_resource_id.COUNT > 0 THEN
							FOR i IN l_resource_id.FIRST .. l_resource_id.LAST LOOP
							/* No need to Check to see if it is already part of
							   p_WinningTerrMember_tbl because this will be slow,
							   So we insert into p_WinningTerrMember_tbl directly*/
							   ---IF l_group_id(i) IS NOT NULL THEN --- Resources without groups should NOT be added to the sales team
								p_WinningTerrMember_tbl.resource_id.EXTEND;
								p_WinningTerrMember_tbl.group_id.EXTEND;
								p_WinningTerrMember_tbl.person_id.EXTEND;
								p_WinningTerrMember_tbl.resource_type.EXTEND;
								p_WinningTerrMember_tbl.full_access_flag.EXTEND;
								p_WinningTerrMember_tbl.terr_id.EXTEND;
								p_WinningTerrMember_tbl.trans_object_id.EXTEND;
								p_WinningTerrMember_tbl.trans_detail_object_id.EXTEND;
								p_WinningTerrMember_tbl.org_id.EXTEND;
								p_WinningTerrMember_tbl.resource_id(p_WinningTerrMember_tbl.resource_id.COUNT) := l_resource_id(i);
								p_WinningTerrMember_tbl.group_id(p_WinningTerrMember_tbl.resource_id.COUNT) := l_group_id(i);
								p_WinningTerrMember_tbl.person_id(p_WinningTerrMember_tbl.person_id.COUNT ) := l_person_id(i);
								p_WinningTerrMember_tbl.resource_type(p_WinningTerrMember_tbl.resource_id.COUNT) := l_resource_type(i);
								p_WinningTerrMember_tbl.full_access_flag(p_WinningTerrMember_tbl.resource_id.COUNT) := p_WinningTerrMember_tbl.full_access_flag(l_index);
								p_WinningTerrMember_tbl.terr_id(p_WinningTerrMember_tbl.resource_id.COUNT) := p_WinningTerrMember_tbl.terr_id(l_index);
								p_WinningTerrMember_tbl.trans_object_id(p_WinningTerrMember_tbl.resource_id.COUNT ) := G_PARTY_ID;
								p_WinningTerrMember_tbl.trans_detail_object_id(p_WinningTerrMember_tbl.resource_id.COUNT ) := p_WinningTerrMember_tbl.trans_detail_object_id(l_index);
								p_WinningTerrMember_tbl.org_id(p_WinningTerrMember_tbl.org_id.COUNT ) :=p_WinningTerrMember_tbl.org_id(l_index);
							   ---END IF;
							END LOOP;
						END IF;
				END IF;
		END LOOP;
	    AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_TEAMS || AS_GAR.G_INS_WINNERS || AS_GAR.G_END);
   END IF;  /* if p_WinningTerrMember_tbl.resource_id.COUNT > 0 */
EXCEPTION
WHEN others THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_TEAMS, SQLERRM, TO_CHAR(SQLCODE));
      x_errbuf := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
END EXPLODE_TEAMS_ACCOUNTS;
/************************** End Explode Teams ACCOUNTs ******************/

/************************** Start Explode Groups ACCOUNTs ******************/
PROCEDURE EXPLODE_GROUPS_ACCOUNTS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    OUT NOCOPY VARCHAR2)
IS
-------------RS_GROUP---------
/*-------------------------------------------------------------------------+
 |                             PROGRAM LOGIC
 |
 | FOR EACH GROUP listed AS a winner within winners, get THE members who play
 | a sales ROLE AND are either an employee OR partner AND INSERT back INTO
 | winners IF they are NOT already IN winners.
 +-------------------------------------------------------------------------*/
l_errbuf         VARCHAR2(4000);
l_retcode        VARCHAR2(255);

TYPE num_list  is TABLE of NUMBER INDEX BY BINARY_INTEGER;
TYPE vchar_list  is TABLE of VARCHAR2(30) INDEX BY BINARY_INTEGER;
l_resource_id    num_list;
l_group_id       num_list;
l_person_id      num_list;
l_resource_type  vchar_list;

BEGIN
   AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_TEAMS || AS_GAR.G_START);
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   /* Get resources within a resource group */
   /** Note
     Hard coding RS_EMPLOYEE INSTEAD OF resource_category IN following SQL
     because JTA returns RS_EMPLOYEE AND NOT EMPLOYEE
   **/
   AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_TEAMS || AS_GAR.G_INS_WINNERS || AS_GAR.G_START);
   IF p_WinningTerrMember_tbl.resource_id.COUNT > 0 THEN
        FOR l_index IN p_WinningTerrMember_tbl.resource_id.FIRST..p_WinningTerrMember_tbl.resource_id.LAST LOOP
				IF p_WinningTerrMember_tbl.resource_type(l_index) = 'RS_GROUP' THEN

						SELECT resource_id,  group_id, person_id,DECODE(resource_category,'PARTY','RS_PARTY',
														  'PARTNER','RS_PARTNER',
									                                          'EMPLOYEE','RS_EMPLOYEE','UNKNOWN') resource_type
						BULK COLLECT INTO l_resource_id, l_group_id,l_person_id,l_resource_type
						FROM
							  (
							   SELECT min(m.resource_id) resource_id,
									  res.category resource_category,
									  m.group_id group_id, min(res.source_id) person_id
							   FROM  jtf_rs_group_members m, jtf_rs_groups_b g,
									 jtf_rs_group_usages u, jtf_rs_role_relations rr,
									 jtf_rs_roles_b r, jtf_rs_resource_extns res
							   WHERE m.group_id = g.group_id
							   AND   SYSDATE BETWEEN NVL(g.start_date_active,SYSDATE)
												 AND NVL(g.end_date_active,SYSDATE)
							   AND   u.group_id = g.group_id
							   AND   u.usage IN ('SALES','PRM')
							   AND   m.group_member_id = rr.role_resource_id
							   AND   rr.role_resource_type = 'RS_GROUP_MEMBER'
							   AND   rr.role_id = r.role_id
							   AND   rr.delete_flag <> 'Y'
							   AND   SYSDATE BETWEEN rr.start_date_active
							   AND   NVL(rr.end_date_active,SYSDATE)
							   AND   r.role_type_code IN
									 ('SALES', 'TELESALES', 'FIELDSALES', 'PRM')
							   AND   r.active_flag = 'Y'
							   AND   res.resource_id = m.resource_id
							   AND   res.category IN ('EMPLOYEE','PARTY','PARTNER')
							   GROUP BY m.group_member_id, m.resource_id, m.person_id,
										m.group_id, res.CATEGORY) j
						WHERE j.group_id = p_WinningTerrMember_tbl.resource_id(l_index);
						AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_GROUPS || AS_GAR.G_INS_WINNERS ||
						AS_GAR.G_N_ROWS_PROCESSED || SQL%ROWCOUNT ||' FOR GROUP '||p_WinningTerrMember_tbl.resource_id(l_index));
						IF l_resource_id.COUNT > 0 THEN
							FOR i IN l_resource_id.FIRST .. l_resource_id.LAST LOOP
							/* No need to Check to see if it is already part of
							   p_WinningTerrMember_tbl because this will be slow,
							   So we insert into p_WinningTerrMember_tbl directly*/
							   --IF l_group_id(i) IS NOT NULL THEN --- Resources without groups should NOT be added to the sales team
								p_WinningTerrMember_tbl.resource_id.EXTEND;
								p_WinningTerrMember_tbl.group_id.EXTEND;
								p_WinningTerrMember_tbl.person_id.EXTEND;
								p_WinningTerrMember_tbl.resource_type.EXTEND;
								p_WinningTerrMember_tbl.full_access_flag.EXTEND;
								p_WinningTerrMember_tbl.terr_id.EXTEND;
								p_WinningTerrMember_tbl.trans_object_id.EXTEND;
								p_WinningTerrMember_tbl.trans_detail_object_id.EXTEND;
								p_WinningTerrMember_tbl.org_id.EXTEND;
								p_WinningTerrMember_tbl.resource_id(p_WinningTerrMember_tbl.resource_id.COUNT) := l_resource_id(i);
								p_WinningTerrMember_tbl.group_id(p_WinningTerrMember_tbl.resource_id.COUNT) := l_group_id(i);
								p_WinningTerrMember_tbl.person_id(p_WinningTerrMember_tbl.person_id.COUNT ) := l_person_id(i);
								p_WinningTerrMember_tbl.resource_type(p_WinningTerrMember_tbl.resource_id.COUNT) := l_resource_type(i);
								p_WinningTerrMember_tbl.full_access_flag(p_WinningTerrMember_tbl.resource_id.COUNT) := p_WinningTerrMember_tbl.full_access_flag(l_index);
								p_WinningTerrMember_tbl.terr_id(p_WinningTerrMember_tbl.resource_id.COUNT) := p_WinningTerrMember_tbl.terr_id(l_index);
								p_WinningTerrMember_tbl.trans_object_id(p_WinningTerrMember_tbl.resource_id.COUNT ) := G_PARTY_ID;
								p_WinningTerrMember_tbl.trans_detail_object_id(p_WinningTerrMember_tbl.resource_id.COUNT ) := p_WinningTerrMember_tbl.trans_detail_object_id(l_index);
								p_WinningTerrMember_tbl.org_id(p_WinningTerrMember_tbl.org_id.COUNT ) :=p_WinningTerrMember_tbl.org_id(l_index);
							   --END IF;
							END LOOP;
						END IF;
				END IF;
		END LOOP;
		AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_GROUPS || AS_GAR.G_INS_WINNERS || AS_GAR.G_END);
        COMMIT;
   END IF;   /* if p_WinningTerrMember_tbl.resource_id.COUNT > 0 */
EXCEPTION
WHEN OTHERS THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CEX_GROUPS, SQLERRM, TO_CHAR(SQLCODE));
      x_errbuf := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
END EXPLODE_GROUPS_ACCOUNTS;

PROCEDURE SET_TEAM_LEAD_ACCOUNTS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    OUT NOCOPY VARCHAR2) IS

    src_id NUMBER:= 0;
BEGIN
     AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || AS_GAR.G_START);
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     IF p_WinningTerrMember_tbl.resource_id.COUNT > 0 THEN
        FOR l_index IN p_WinningTerrMember_tbl.resource_id.FIRST..p_WinningTerrMember_tbl.resource_id.LAST LOOP
	     IF p_WinningTerrMember_tbl.resource_type(l_index) IN('RS_EMPLOYEE','RS_PARTY','RS_PARTNER')THEN
		    SELECT NVL(source_id,0) INTO src_id FROM JTF_RS_RESOURCE_EXTNS RES WHERE resource_id = p_WinningTerrMember_tbl.resource_id(l_index);
		    AS_GAR.LOG(G_ENTITY || G_PARTY_ID ||' : BEFORE UPDATE :'|| '::' || 'RESOURCE/GROUP/RESOURCE_TYPE/SOURCE_ID::' || p_WinningTerrMember_tbl.resource_id(l_index)
		    || '/' || p_WinningTerrMember_tbl.group_id(l_index) || '/' || p_WinningTerrMember_tbl.resource_type(l_index) || '/' || src_id);
			---IF p_WinningTerrMember_tbl.resource_type(l_index) = 'RS_EMPLOYEE' THEN
					 UPDATE  AS_ACCESSES_ALL ACC
					 SET	 object_version_number =  nvl(object_version_number,0) + 1,
							 ACC.last_update_date = SYSDATE,
							 ACC.last_updated_by = FND_GLOBAL.USER_ID,
							 ACC.last_update_login = FND_GLOBAL.USER_ID,
							 ACC.team_leader_flag = NVL(p_WinningTerrMember_tbl.full_access_flag(l_index),'N')
					 WHERE	 ACC.customer_id    = G_PARTY_ID
					 AND     ACC.lead_id IS NULL
					 AND     ACC.sales_lead_id IS NULL
					 AND	 ACC.salesforce_id  = p_WinningTerrMember_tbl.resource_id(l_index)
					 AND	 NVL(ACC.sales_group_id,-777) = NVL(p_WinningTerrMember_tbl.group_id(l_index),-777)
					 AND     NVL(ACC.team_leader_flag,'N') <> NVL(p_WinningTerrMember_tbl.full_access_flag(l_index),'N');
			---END IF;
	       END IF;
	    END LOOP;
	 END IF;
 	 AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD || AS_GAR.G_END);
EXCEPTION
WHEN OTHERS THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_STLEAD, SQLERRM, TO_CHAR(SQLCODE));
      x_errbuf := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE;
END SET_TEAM_LEAD_ACCOUNTS;


PROCEDURE INSERT_ACCESSES_ACCOUNTS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    OUT NOCOPY VARCHAR2) IS
BEGIN
      AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSACC || AS_GAR.G_START);
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF p_WinningTerrMember_tbl.resource_id.COUNT > 0 THEN
			FOR l_index IN p_WinningTerrMember_tbl.resource_id.FIRST..p_WinningTerrMember_tbl.resource_id.LAST LOOP
		            AS_GAR.LOG(G_ENTITY || G_PARTY_ID ||' : BEFORE INSERT :'|| '::' || 'RESOURCE/GROUP/RESOURCE_TYPE ' || p_WinningTerrMember_tbl.resource_id(l_index)
				    || '/' || p_WinningTerrMember_tbl.group_id(l_index) || '/' || p_WinningTerrMember_tbl.resource_type(l_index) );

		--added inline view in the select clause of Insert statement to fetch the salesforce role code for Employee resource --fix for bug 5869095

					IF p_WinningTerrMember_tbl.resource_type(l_index) = 'RS_EMPLOYEE' AND p_WinningTerrMember_tbl.group_id(l_index) IS NOT NULL THEN
						INSERT  INTO AS_ACCESSES_ALL
							       (access_id ,
								last_update_date ,
								last_updated_by,
								creation_date ,
								created_by ,
								last_update_login,
								access_type ,
								freeze_flag,
								reassign_flag,
								team_leader_flag ,
								customer_id ,
								address_id ,
								salesforce_id ,
								person_id ,
								sales_group_id,
								created_by_tap_flag,
								salesforce_role_code)
								---- JTY need to pass org_id as well
                                    SELECT  AS_ACCESSES_S.NEXTVAL access_id,
								last_update_date ,
								last_updated_by,
								creation_date ,
								created_by ,
								last_update_login,
								access_type ,
								freeze_flag,
								reassign_flag,
								team_leader_flag ,
								customer_id ,
								address_id ,
								salesforce_id ,
								person_id ,
								sales_group_id,
								created_by_tap_flag,
								salesforce_role_code
						FROM
                 					   (SELECT  SYSDATE  last_update_date,
								FND_GLOBAL.USER_ID  last_updated_by,
								SYSDATE  creation_date,
								FND_GLOBAL.USER_ID  created_by,
								FND_GLOBAL.USER_ID  last_update_login,
								'Online'  access_type,
								'N'  freeze_flag,
								'N'  reassign_flag,
								DECODE(p_WinningTerrMember_tbl.full_access_flag(l_index),'Y','Y','N')  team_leader_flag,
								G_PARTY_ID  customer_id,
								p_WinningTerrMember_tbl.trans_detail_object_id(l_index)  address_id,
								p_WinningTerrMember_tbl.resource_id(l_index)  salesforce_id,
								(SELECT source_id FROM JTF_RS_RESOURCE_EXTNS RES WHERE RES.resource_id = p_WinningTerrMember_tbl.resource_id(l_index))  person_id,
								p_WinningTerrMember_tbl.group_id(l_index)  sales_group_id,
								'Y'  created_by_tap_flag
							  FROM DUAL
							  WHERE NOT EXISTS
								( SELECT NULL FROM AS_ACCESSES_ALL ACC
								   WHERE ACC.customer_id = G_PARTY_ID
								   AND	ACC.lead_id IS NULL
								   AND	ACC.sales_lead_id IS NULL
								   AND	ACC.salesforce_id = p_WinningTerrMember_tbl.resource_id(l_index)
								   AND	ACC.sales_group_id = p_WinningTerrMember_tbl.group_id(l_index) ) ) asa,
								( SELECT USERS.EMPLOYEE_ID EMPLOYEE_ID ,
									   VAL.PROFILE_OPTION_VALUE SALESFORCE_ROLE_CODE
								    FROM FND_PROFILE_OPTION_VALUES VAL,
							               FND_PROFILE_OPTIONS OPTIONS,
						                     FND_USER USERS
				 			         WHERE VAL.LEVEL_ID = 10004
								     AND USERS.EMPLOYEE_ID is not null
								     AND VAL.PROFILE_OPTION_VALUE is not null
								     AND USERS.USER_ID = VAL.LEVEL_VALUE
								     AND VAL.PROFILE_OPTION_VALUE is not null
								     AND OPTIONS.PROFILE_OPTION_ID = VAL.PROFILE_OPTION_ID
								     AND OPTIONS.APPLICATION_ID = VAL.APPLICATION_ID
								     AND OPTIONS.PROFILE_OPTION_NAME = 'AS_DEF_CUST_ST_ROLE') prf
						WHERE asa.PERSON_ID = prf.EMPLOYEE_ID (+);
					ELSIF p_WinningTerrMember_tbl.resource_type(l_index) IN ('RS_PARTY','RS_PARTNER') THEN
						INSERT  INTO AS_ACCESSES_ALL
							   (access_id ,
								last_update_date ,
								last_updated_by,
								creation_date ,
								created_by ,
								last_update_login,
								access_type ,
								freeze_flag,
								reassign_flag,
								team_leader_flag ,
								customer_id ,
								address_id ,
								salesforce_id ,
								person_id ,
								sales_group_id,
								created_by_tap_flag,
								partner_customer_id,
								partner_cont_party_id,org_id)
						SELECT  AS_ACCESSES_S.NEXTVAL,
								SYSDATE,
								FND_GLOBAL.USER_ID,
								SYSDATE,
								FND_GLOBAL.USER_ID,
								FND_GLOBAL.USER_ID,
								'Online',
								'N',
								'N',
								DECODE(p_WinningTerrMember_tbl.full_access_flag(l_index),'Y','Y','N'),
								G_PARTY_ID,
								p_WinningTerrMember_tbl.trans_detail_object_id(l_index),
								p_WinningTerrMember_tbl.resource_id(l_index),
								NULL,
								p_WinningTerrMember_tbl.group_id(l_index),
								'Y',
								DECODE(p_WinningTerrMember_tbl.resource_type(l_index),'RS_PARTNER',(SELECT source_id FROM JTF_RS_RESOURCE_EXTNS RES WHERE resource_id = p_WinningTerrMember_tbl.resource_id(l_index)),NULL),
 						                DECODE(p_WinningTerrMember_tbl.resource_type(l_index),'RS_PARTY',(SELECT source_id FROM JTF_RS_RESOURCE_EXTNS RES WHERE resource_id = p_WinningTerrMember_tbl.resource_id(l_index)),NULL),
 							        p_WinningTerrMember_tbl.org_id(l_index)
						FROM DUAL
						WHERE NOT EXISTS
								( SELECT NULL FROM AS_ACCESSES_ALL ACC
								   WHERE ACC.customer_id = G_PARTY_ID
								   AND	ACC.lead_id IS NULL
								   AND	ACC.sales_lead_id IS NULL
								   AND	ACC.salesforce_id = p_WinningTerrMember_tbl.resource_id(l_index)
								   AND	NVL(ACC.sales_group_id,-777) = NVL(p_WinningTerrMember_tbl.group_id(l_index),-777) );
					END IF;
			END LOOP;
	  END IF;
 	  AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSACC || AS_GAR.G_END);
EXCEPTION
WHEN OTHERS THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSACC, SQLERRM, TO_CHAR(SQLCODE));
      x_errbuf := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
END INSERT_ACCESSES_ACCOUNTS;

PROCEDURE INSERT_TERR_ACCESSES_ACCOUNTS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    OUT NOCOPY VARCHAR2) IS
BEGIN
      AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSTERRACC || AS_GAR.G_START);
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      /*------------------------------------------------------------------------------+
      | we are deleting all rows for the entity from as_territory_accesses prior to
      | inserting into it because the logic for removing only certain terr_id/access_id
      | combinations is very complex and could be slow..
      +-------------------------------------------------------------------------------*/
      DELETE FROM AS_TERRITORY_ACCESSES TACC
      WHERE TACC.access_id IN
       (SELECT ACC.access_id
       FROM    AS_ACCESSES_ALL ACC
       WHERE   customer_id = G_PARTY_ID
       AND     lead_id IS NULL
       AND     sales_lead_id IS NULL);
	         IF p_WinningTerrMember_tbl.resource_id.COUNT > 0 THEN
			FOR l_index IN p_WinningTerrMember_tbl.resource_id.FIRST..p_WinningTerrMember_tbl.resource_id.LAST LOOP
					IF p_WinningTerrMember_tbl.resource_type(l_index) = 'RS_EMPLOYEE' THEN
						INSERT INTO AS_TERRITORY_ACCESSES
							(	access_id,
								territory_id,
								user_territory_id,
								last_update_date,
								last_updated_by,
								creation_date,
								created_by,
								last_update_login )
						SELECT
								ACC.access_id,
								p_WinningTerrMember_tbl.terr_id(l_index),
								p_WinningTerrMember_tbl.terr_id(l_index),
								SYSDATE,
								FND_GLOBAL.USER_ID,
								SYSDATE,
								FND_GLOBAL.USER_ID,
								FND_GLOBAL.USER_ID
						FROM	AS_ACCESSES_ALL ACC
						WHERE   ACC.customer_id = G_PARTY_ID
						AND		ACC.salesforce_id = p_WinningTerrMember_tbl.resource_id(l_index)
						AND		ACC.sales_group_id = p_WinningTerrMember_tbl.group_id(l_index)
						AND NOT EXISTS ( SELECT 'Y'
								FROM	AS_TERRITORY_ACCESSES TACC
								WHERE	TACC.access_id = ACC.access_id
								AND		TACC.territory_id = p_WinningTerrMember_tbl.terr_id(l_index)) ;
					ELSIF p_WinningTerrMember_tbl.resource_type(l_index) IN ('RS_PARTY','RS_PARTNER') THEN
						INSERT INTO AS_TERRITORY_ACCESSES
							(	access_id,
								territory_id,
								user_territory_id,
								last_update_date,
								last_updated_by,
								creation_date,
								created_by,
								last_update_login )
						SELECT  ACC.access_id,
								p_WinningTerrMember_tbl.terr_id(l_index),
								p_WinningTerrMember_tbl.terr_id(l_index),
								SYSDATE,
								FND_GLOBAL.USER_ID,
								SYSDATE,
								FND_GLOBAL.USER_ID,
								FND_GLOBAL.USER_ID
						FROM	AS_ACCESSES_ALL ACC
						WHERE   ACC.customer_id = G_PARTY_ID
						AND		ACC.salesforce_id = p_WinningTerrMember_tbl.resource_id(l_index)
						AND		NVL(ACC.sales_group_id,-777) = NVL(p_WinningTerrMember_tbl.group_id(l_index),-777)
						AND		(ACC.partner_customer_id IS NOT NULL OR ACC.partner_cont_party_id IS NOT NULL )
						AND NOT EXISTS ( SELECT 'Y'
								FROM	AS_TERRITORY_ACCESSES TACC
								WHERE	TACC.access_id = ACC.access_id
								AND		TACC.territory_id = p_WinningTerrMember_tbl.terr_id(l_index)) ;
					END IF;
			END LOOP;
	  END IF;

 	 AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSTERRACC || AS_GAR.G_END);
EXCEPTION
WHEN OTHERS THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_INSTERRACC, SQLERRM, TO_CHAR(SQLCODE));
      x_errbuf := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
END INSERT_TERR_ACCESSES_ACCOUNTS;

PROCEDURE PERFORM_ACCOUNT_CLEANUP(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    OUT NOCOPY VARCHAR2) IS

	TYPE access_type IS TABLE OF NUMBER;
	l_access_rec_id access_type;

BEGIN
	AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_START);
	x_return_status := FND_API.G_RET_STS_SUCCESS;
		DELETE FROM AS_ACCESSES_ALL ACC
		WHERE  customer_id = G_PARTY_ID
	        AND    lead_id IS NULL
	        AND    sales_lead_id IS NULL
	        AND    NVL(freeze_flag, 'N') <> 'Y'
	        AND    SALESFORCE_ID||NVL(SALES_GROUP_ID,-777) NOT IN (
				SELECT  RESTAB.RES||NVL(GRPTAB.GRP,-777)  FROM
				(SELECT rownum ROW_NUM,A.COLUMN_VALUE RES FROM TABLE(CAST(p_WinningTerrMember_tbl.resource_id AS jtf_terr_number_list)) a) RESTAB,
				(SELECT rownum ROW_NUM,b.COLUMN_VALUE GRP FROM TABLE(CAST(p_WinningTerrMember_tbl.group_id AS jtf_terr_number_list)) b) GRPTAB
				WHERE RESTAB.ROW_NUM = GRPTAB.ROW_NUM
				) ;
        AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_N_ROWS_PROCESSED || SQL%ROWCOUNT);
	AS_GAR.LOG(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC || AS_GAR.G_END);
EXCEPTION
WHEN OTHERS THEN
      AS_GAR.LOG_EXCEPTION(G_ENTITY || AS_GAR.G_PROCESS || AS_GAR.G_CC, SQLERRM, TO_CHAR(SQLCODE));
      x_errbuf := SQLERRM;
      x_retcode := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
END PERFORM_ACCOUNT_CLEANUP;



END AS_RTTAP_ACCOUNT;

/
