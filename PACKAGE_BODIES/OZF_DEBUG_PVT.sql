--------------------------------------------------------
--  DDL for Package Body OZF_DEBUG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_DEBUG_PVT" AS
/*$Header: ozfvdbgb.pls 120.0.12010000.3 2012/11/06 06:59:36 nkjaiswa noship $*/

/*****************************************************************************************/
   -- NAME --    DEBUG_MO
   -- PURPOSE
   --    Retrieves the MOAC context form MO_GLOBAL and DB session
   --    and pass it to the calling API.
/*****************************************************************************************/

PROCEDURE DEBUG_MO(P_APP_SHORT_NAME OUT NOCOPY VARCHAR2,
            P_RESP_ID OUT NOCOPY NUMBER,
            P_USER_ID OUT NOCOPY NUMBER,
            P_MO_CURRENT_ORG_ID OUT NOCOPY NUMBER,
            P_MO_ACCESS_MODE OUT NOCOPY VARCHAR2,
            P_DB_CURRENT_ORG_ID OUT NOCOPY NUMBER,
            P_DB_ACCESS_MODE OUT NOCOPY VARCHAR2,
            P_MO_SECURITY_ORGS OUT NOCOPY VARCHAR2)
IS
l_org_id NUMBER;
l_org_name VARCHAR2(1000);
l_tmp_str VARCHAR2(4000);
CURSOR c_populate_orgs IS SELECT ORGANIZATION_ID,ORGANIZATION_NAME from MO_GLOB_ORG_ACCESS_TMP;
BEGIN
		P_APP_SHORT_NAME :=FND_GLOBAL.APPLICATION_SHORT_NAME;
		P_RESP_ID := FND_GLOBAL.RESP_ID;
		P_USER_ID := FND_GLOBAL.USER_ID;
		P_MO_CURRENT_ORG_ID := mo_global.get_current_org_id;
		P_MO_ACCESS_MODE :=  mo_global.get_access_mode;
		P_DB_CURRENT_ORG_ID :=sys_context('multi_org2','current_org_id');
		P_DB_ACCESS_MODE := sys_context('multi_org','access_mode');
		OPEN c_populate_orgs;
			LOOP
				FETCH c_populate_orgs INTO l_org_id,l_org_name;
					l_tmp_str :=l_tmp_str||l_org_id ||',';
				EXIT WHEN c_populate_orgs%NOTFOUND;
			END LOOP;
		CLOSE c_populate_orgs;
		P_MO_SECURITY_ORGS := RTRIM(l_tmp_str,',');
EXCEPTION
	WHEN OTHERS THEN
		RAISE Fnd_Api.g_exc_error;
		ozf_utility_pvt.debug_message('Exception in Getting MOAC Context');
END;

/*****************************************************************************************/
   -- NAME --    DEBUG_MO
   -- PURPOSE
   --    Retrieves the MOAC context form MO_GLOBAL and DB session
   --    and log  into the  FND_LOG_MESSAGES.
/*****************************************************************************************/

PROCEDURE DEBUG_MO(P_TEXT IN VARCHAR2)
IS
l_org_id NUMBER;
l_org_name VARCHAR2(1000);
l_tmp_str VARCHAR2(4000);
CURSOR c_populate_orgs IS SELECT ORGANIZATION_ID,ORGANIZATION_NAME from MO_GLOB_ORG_ACCESS_TMP;
BEGIN

OZF_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT,'OZF',P_TEXT||' APP_SHORT_NAME : '||FND_GLOBAL.APPLICATION_SHORT_NAME);
OZF_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT,'OZF',P_TEXT||' USER_ID : '||FND_GLOBAL.USER_ID);
OZF_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT,'OZF',P_TEXT||' RESP_ID : '||FND_GLOBAL.RESP_ID);
OZF_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT,'OZF',P_TEXT||' MO_ACCESS_MODE : '||mo_global.get_access_mode);
OZF_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT,'OZF',P_TEXT||' MO_CURRENT_ORG_ID : '||mo_global.get_current_org_id);
OZF_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT,'OZF',P_TEXT||' DB_ACCESS_MODE : '||sys_context('multi_org','access_mode'));
OZF_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT,'OZF',P_TEXT||' DB_CURRENT_ORG_ID : '||sys_context('multi_org2','current_org_id'));
OPEN c_populate_orgs;
    LOOP
		FETCH c_populate_orgs INTO l_org_id,l_org_name;
			l_tmp_str :=l_tmp_str||l_org_id ||',';
		EXIT WHEN c_populate_orgs%NOTFOUND;
    END LOOP;
CLOSE c_populate_orgs;
OZF_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT,'OZF',P_TEXT||' MO:Security profile :org_ids -- ' || RTRIM(l_tmp_str,','));
EXCEPTION
	WHEN OTHERS THEN
		RAISE Fnd_Api.g_exc_error;
		ozf_utility_pvt.debug_message('Exception in Getting MOAC Context');
END ;

END OZF_DEBUG_PVT;

/
