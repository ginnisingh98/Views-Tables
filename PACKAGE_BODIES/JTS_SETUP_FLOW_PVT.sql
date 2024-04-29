--------------------------------------------------------
--  DDL for Package Body JTS_SETUP_FLOW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTS_SETUP_FLOW_PVT" as
/* $Header: jtsvcsfb.pls 115.6 2002/04/10 18:10:14 pkm ship    $ */


-- --------------------------------------------------------------------------------------
-- Package name     : JTS_SETUP_FLOW_PVT
-- Purpose          : Setup Summary Hiearchy.
-- History          : 21-Feb-02  Sung Ha Huh  Created.
--		      27-Feb-02  SHUH         Moved insert, update, delete,
--					      translate, and load to
--					      new package JTS_SETUP_FLOW_HIEARCHY_PKG.
-- NOTE             :
-- --------------------------------------------------------------------------------------


-- Returns the flow id of a flow's parent
FUNCTION GET_PARENT_FLOW_ID(p_flow_id	IN NUMBER)
RETURN NUMBER IS
   l_flow_id 	JTS_SETUP_FLOWS_B.flow_id%TYPE;
BEGIN
   SELECT parent_id
   INTO   l_flow_id
   FROM   jts_setup_flows_b
   WHERE  flow_id = p_flow_id;

   return (l_flow_id);
EXCEPTION
  WHEN OTHERS THEN
    return NULL;
END GET_PARENT_FLOW_ID;

-- Returns the flow name of a flow given a flow id
FUNCTION GET_FLOW_NAME(p_flow_id	IN NUMBER)
RETURN VARCHAR2 IS
   l_flow_name 	JTS_SETUP_FLOWS_VL.flow_name%TYPE;
BEGIN
   SELECT flow_name
   INTO   l_flow_name
   FROM   jts_setup_flows_vl
   WHERE  flow_id = p_flow_id;

   return (l_flow_name);
EXCEPTION
  WHEN OTHERS THEN
    return NULL;
END GET_FLOW_NAME;

-- Gets Configuration Types that is a Complete Business Flow
PROCEDURE GET_FLOW_ROOT_FLOWS(
	p_api_version		IN  NUMBER,
   	x_flow_tbl		OUT NOCOPY Root_Setup_Flow_Tbl_Type
) IS
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'GET_FLOW_ROOT_FLOWS';
   l_full_name     CONSTANT VARCHAR2 (60) := G_PKG_NAME || '.' || l_api_name;

   i		   NUMBER := 1;

CURSOR l_flow_csr IS
  SELECT flow_id, flow_name, flow_type
  FROM   jts_setup_flows_vl
  WHERE  parent_id IS NULL
  AND    flow_type = C_FLOW_FLOW_TYPE;

BEGIN
   IF NOT fnd_api.compatible_api_call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                      )
   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   i := 1;
   OPEN l_flow_csr;
   LOOP
      FETCH l_flow_csr INTO x_flow_tbl(i);
      EXIT WHEN l_flow_csr%NOTFOUND;
      i := i + 1;
   END LOOP;
   CLOSE l_flow_csr;

EXCEPTION
   WHEN OTHERS THEN
      APP_EXCEPTION.RAISE_EXCEPTION;
END GET_FLOW_ROOT_FLOWS;

-- Gets Configuration Types that are indivdual modules
PROCEDURE GET_MODULE_ROOT_FLOWS(p_api_version	IN  NUMBER,
   		      x_flow_tbl	OUT NOCOPY  Root_Setup_Flow_Tbl_Type) IS
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'GET_MODULE_ROOT_FLOWS';
   l_full_name     CONSTANT VARCHAR2 (60) := G_PKG_NAME || '.' || l_api_name;

   i		   NUMBER := 1;

CURSOR l_flow_csr IS
  SELECT flow_id, flow_name, flow_type
  FROM  jts_setup_flows_vl
  WHERE parent_id IS NULL
  AND   flow_type = C_MODULE_FLOW_TYPE;

BEGIN
   IF NOT fnd_api.compatible_api_call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                      )
   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   i := 1;
   OPEN l_flow_csr;
   LOOP
      FETCH l_flow_csr INTO x_flow_tbl(i);
      EXIT WHEN l_flow_csr%NOTFOUND;
      i := i + 1;
   END LOOP;
   CLOSE l_flow_csr;

EXCEPTION
   WHEN OTHERS THEN
      APP_EXCEPTION.RAISE_EXCEPTION;
END GET_MODULE_ROOT_FLOWS;

-- Gets Setup Hiearchy through recursion, starting from the root
PROCEDURE GET_FLOW_HIEARCHY(p_api_version	IN  NUMBER,
   		  p_flow_id		IN  NUMBER,
 	   	  x_flow_tbl		OUT NOCOPY Setup_Flow_Tbl_Type) IS

   l_api_version   CONSTANT NUMBER        := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'GET_FLOW_HIEARCHY';
   l_full_name     CONSTANT VARCHAR2 (60) := G_PKG_NAME || '.' || l_api_name;

   i		   NUMBER := 1;

CURSOR l_flows_csr IS
   SELECT	sb.flow_id, sv.flow_name, sb.flow_code, sb.parent_id,
		sb.mlevel, sb.flow_sequence, sb.overview_url, sb.diagnostics_url,
		sb.dpf_code, sb.dpf_asn, sb.num_steps, sb.flow_type, sb.has_child_flag
   FROM   (SELECT flow_id, flow_code, parent_id, level mlevel, flow_sequence, flow_type,
		  overview_url, diagnostics_url,
		  dpf_code, dpf_asn, num_steps, has_child_flag
	   FROM   jts_setup_flows_b
	   START WITH  flow_id = p_flow_id
	   CONNECT BY prior flow_id= parent_id) sb,
	   jts_setup_flows_vl sv
   WHERE  sv.flow_id=sb.flow_id;

BEGIN
   IF NOT fnd_api.compatible_api_call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                      )
   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   i := 1;
   OPEN l_flows_csr;
   LOOP
      FETCH l_flows_csr INTO x_flow_tbl(i);
      EXIT WHEN l_flows_csr%NOTFOUND;
      i := i + 1;
   END LOOP;
   CLOSE l_flows_csr;

EXCEPTION
   WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'Hiearchy');
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', '');
      FND_MESSAGE.SET_TOKEN('PARAMETERS', '');
      APP_EXCEPTION.RAISE_EXCEPTION;
END GET_FLOW_HIEARCHY;


-- Gets Setup Hiearchy through recursion, starting from the root
PROCEDURE GET_FLOW_DATA_HIEARCHY(p_api_version	IN  NUMBER,
   		  p_flow_id		IN  NUMBER,
		  p_version_id		IN  NUMBER,
 	   	  x_flow_tbl		OUT NOCOPY Flow_Tbl_Type) IS

   l_api_version   CONSTANT NUMBER        := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'GET_FLOW_DATA_HIEARCHY';
   l_full_name     CONSTANT VARCHAR2 (60) := G_PKG_NAME || '.' || l_api_name;

   i		   NUMBER := 1;

CURSOR l_flows_csr IS
   SELECT	sb.flow_id, sv.flow_name, sb.flow_code, sb.parent_id,
		sb.mlevel, sb.flow_sequence, sb.overview_url, sb.diagnostics_url,
		sb.dpf_code, sb.dpf_asn, sb.num_steps, sb.flow_type, sb.has_child_flag,
		vf.version_id, vf.complete_flag, vf.creation_date, vf.last_update_date,
		u1.user_name, u2.user_name
   FROM   (SELECT flow_id, level mlevel, flow_code, flow_sequence, parent_id, flow_type,
		  has_child_flag, overview_url, diagnostics_url,
		  dpf_code, dpf_asn, num_steps
	   FROM   jts_setup_flows_b
	   START WITH  flow_id = p_flow_id
	   CONNECT BY prior flow_id= parent_id) sb,
	   jts_setup_flows_vl sv,
	   jts_config_version_flows vf,
	   fnd_user u1,
	   fnd_user u2
    WHERE 	sb.flow_id=sv.flow_id
    AND  	vf.flow_id = sb.flow_id
    AND		vf.version_id = p_version_id
    AND		u1.user_id (+) = vf.created_by
    AND		u2.user_id (+) = vf.last_updated_by;

BEGIN
   IF NOT fnd_api.compatible_api_call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                      )
   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   i := 1;
   OPEN l_flows_csr;
   LOOP
      FETCH l_flows_csr INTO x_flow_tbl(i);
      EXIT WHEN l_flows_csr%NOTFOUND;
      i := i + 1;
   END LOOP;
   CLOSE l_flows_csr;

EXCEPTION
   WHEN OTHERS THEN
      APP_EXCEPTION.RAISE_EXCEPTION;
END GET_FLOW_DATA_HIEARCHY;


END JTS_SETUP_FLOW_PVT;

/
