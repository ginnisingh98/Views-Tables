--------------------------------------------------------
--  DDL for Package Body JTS_CONFIG_VERSION_FLOW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTS_CONFIG_VERSION_FLOW_PVT" as
/* $Header: jtsvcvfb.pls 115.4 2002/04/10 18:10:19 pkm ship    $ */


-- --------------------------------------------------------------------
-- Package name     : JTS_CONFIG_VERSION_FLOW_PVT
-- Purpose          : Setup Summary Data.
-- History          : 22-Feb-02  Sung Ha Huh  Created.
-- NOTE             :
-- --------------------------------------------------------------------

-- Precondition: Complete Flag for all the parents have been set
--  		 UPDATE_COMPLETE_FLAGS have been called
FUNCTION GET_PERCENT_COMPLETE(p_api_version	IN  NUMBER,
   			      p_version_id	IN  NUMBER) RETURN NUMBER IS
  l_completed	NUMBER := 0;
  l_total	NUMBER := 0;
BEGIN

  SELECT 	COUNT(*)
  INTO		l_completed
  FROM	  	jts_config_version_flows vf,
	        jts_setup_flows_b sf
  WHERE		version_id = p_version_id
  AND		complete_flag = 'Y'
  AND		sf.flow_id = vf.flow_id
  AND		sf.has_child_flag = 'N';

  SELECT 	COUNT(*)
  INTO		l_total
  FROM	  	jts_config_version_flows vf,
	        jts_setup_flows_b sf
  WHERE		version_id = p_version_id
  AND		sf.flow_id = vf.flow_id
  AND		sf.has_child_flag = 'N';

  IF l_total = 0 THEN
     return 0;
  END IF;
  return ROUND(l_completed*100/l_total);

EXCEPTION
   WHEN OTHERS THEN
	APP_EXCEPTION.RAISE_EXCEPTION;
END GET_PERCENT_COMPLETE;

-- Updates last_update_date, last_updated_by of a subflow and its -- parent up to one level below the root
PROCEDURE UPDATE_FLOW_DETAILS(p_api_version	IN Number,
   			p_version_id		IN NUMBER,
			p_flow_id		IN NUMBER,
			p_complete_flag 	IN VARCHAR2) IS
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'UPDATE_FLOW_DETAILS';
   l_flow_id	   JTS_SETUP_FLOWS_B.flow_id%TYPE;
   l_parent_id	   JTS_SETUP_FLOWS_B.parent_id%TYPE;
BEGIN

   IF NOT fnd_api.compatible_api_call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                      )
   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --propagate the changes up the root for last update fields
   UPDATE jts_config_version_flows
   SET    complete_flag = p_complete_flag,
	  last_updated_by =  FND_GLOBAL.user_id,
	  last_update_login = FND_GLOBAL.user_id,
	  last_update_date = sysdate
   WHERE  version_id = p_version_id
   AND    flow_id = p_flow_id;

   l_flow_id := JTS_SETUP_FLOW_PVT.GET_PARENT_FLOW_ID(p_flow_id);

-- Propagate last_update information up to the parent right below the root level
   WHILE (l_flow_id IS NOT NULL) LOOP
      l_parent_id := JTS_SETUP_FLOW_PVT.GET_PARENT_FLOW_ID(l_flow_id);
      IF (l_parent_id IS NOT NULL) THEN --not at root level yet
      	 UPDATE jts_config_version_flows
      	 SET    last_updated_by =  FND_GLOBAL.user_id,
	  	last_update_login = FND_GLOBAL.user_id,
		last_update_date = sysdate
      	 WHERE  version_id = p_version_id
      	 AND    flow_id = l_flow_id;
      END IF;
      l_flow_id := l_parent_id;
   END LOOP;

   COMMIT;

EXCEPTION
   WHEN OTHERS THEN
	APP_EXCEPTION.RAISE_EXCEPTION;
END UPDATE_FLOW_DETAILS;

-- Creates Setup Summary data by getting the flow hiearchy
-- and inserting with the appropriate flow_id
PROCEDURE CREATE_VERSION_FLOWS(p_api_version	IN  NUMBER,
   				p_version_id	IN  NUMBER,
				p_flow_hiearchy IN  JTS_SETUP_FLOW_PVT.Setup_Flow_Tbl_Type)
IS
   l_api_version   	CONSTANT NUMBER        := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'CREATE_VERSION_FLOWS';
BEGIN

   IF NOT fnd_api.compatible_api_call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                      )
   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   FOR I IN 1..p_flow_hiearchy.count LOOP
      INSERT INTO jts_config_version_flows(
      	version_id,
      	flow_id,
      	complete_flag,
	object_version_number,
      	creation_date,
      	created_by,
      	last_update_date,
      	last_updated_by,
      	last_update_login)
      VALUES(
      	p_version_id,
      	p_flow_hiearchy(I).flow_id,
      	'N',
	1,
      	sysdate,
    	FND_GLOBAL.user_id, --created_by
    	sysdate,
    	FND_GLOBAL.user_id,
    	FND_GLOBAL.user_id
      );
   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
	APP_EXCEPTION.RAISE_EXCEPTION;
END CREATE_VERSION_FLOWS;

--Deletes from jts_config_version_flows
PROCEDURE DELETE_VERSION_FLOWS(p_api_version	IN  Number,
   				p_version_id 	IN  NUMBER) IS
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'DELETE_VERSION_FLOWS';
BEGIN

   IF NOT fnd_api.compatible_api_call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                      )
   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   DELETE FROM jts_config_version_flows
   WHERE  version_id = p_version_id;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
	NULL;
   WHEN OTHERS THEN
	APP_EXCEPTION.RAISE_EXCEPTION;
END DELETE_VERSION_FLOWS;

-- Deletes all records from jts_config_version_flows where
-- version_id exists for p_config_id in versions table
PROCEDURE DELETE_CONFIG_VERSION_FLOWS(p_api_version	IN  Number,
   					p_config_id 	IN  NUMBER) IS
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'DELETE_CONFIG_VERSION_FLOWS';
   versions_csr    JTS_CONFIG_UTIL_PVT.Versions_Csr_Type;
   l_version_id	   JTS_CONFIG_VERSION_FLOWS.version_id%TYPE;
BEGIN

   IF NOT fnd_api.compatible_api_call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                      )
   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   JTS_CONFIG_UTIL_PVT.GET_VERSIONS_CURSOR(p_api_version,
					   p_config_id,
					   versions_csr);
   LOOP
     FETCH versions_csr INTO l_version_id;
     EXIT WHEN versions_csr%NOTFOUND;

     DELETE FROM jts_config_version_flows
     WHERE  version_id = l_version_id;
   END LOOP;

   CLOSE versions_csr;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
	NULL;
   WHEN OTHERS THEN
	APP_EXCEPTION.RAISE_EXCEPTION;
END DELETE_CONFIG_VERSION_FLOWS;

-- Gets all the version flows
PROCEDURE GET_VERSION_FLOWS(p_api_version	IN  Number,
   		p_version_id	IN  NUMBER,
		p_flow_tbl	OUT NOCOPY Version_Flow_Tbl_Type) IS
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'GET_VERSION_FLOWS';
   i		   NUMBER := 1;
CURSOR vflows_csr IS
	SELECT 	 version_id, flow_id, v.complete_flag,
		 v.creation_date, v.created_by, v.last_update_date, v.last_updated_by, v.last_update_login,
		 u1.user_name, u2.user_name
	FROM 	 jts_config_version_flows v,
		 fnd_user u1,
		 fnd_user u2
	WHERE	 version_id = p_version_id
	AND	 u1.user_id (+) = v.created_by
	AND	 u2.user_id (+) = v.last_updated_by
	ORDER BY flow_id;
BEGIN

   IF NOT fnd_api.compatible_api_call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                      )
   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   OPEN vflows_csr;
   i:=1;
   LOOP
     FETCH vflows_csr
     INTO  p_flow_tbl(i).version_id,
           p_flow_tbl(i).flow_id,
           p_flow_tbl(i).complete_flag,
           p_flow_tbl(i).creation_date,
           p_flow_tbl(i).created_by,
           p_flow_tbl(i).last_update_date,
           p_flow_tbl(i).last_updated_by,
           p_flow_tbl(i).last_update_login,
           p_flow_tbl(i).created_by_name,
           p_flow_tbl(i).last_updated_by_name;
     EXIT WHEN vflows_csr%NOTFOUND;

     i := i+1;
   END LOOP;

   CLOSE vflows_csr;

EXCEPTION
   WHEN OTHERS THEN
	APP_EXCEPTION.RAISE_EXCEPTION;
END GET_VERSION_FLOWS;


END JTS_CONFIG_VERSION_FLOW_PVT;

/
