--------------------------------------------------------
--  DDL for Package Body OKE_FLOWDOWN_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_FLOWDOWN_UTILS" AS
/* $Header: OKEFWDUB.pls 120.4 2006/02/07 17:02:40 ifilimon noship $ */
--
--  Name          : Get_Flowdown_URL
--  Pre-reqs      : FND_GLOBAL.INITIALIZE
--  Function      : This function returns the URL for the flowdown viewer
--
--
--  Parameters    :
--  IN            : None
--  OUT           : None
--
--  Returns       : VARCHAR2
--

FUNCTION Flowdown_URL
( X_Business_Area        IN     VARCHAR2
, X_Object_Name          IN     VARCHAR2
, X_PK1                  IN     VARCHAR2
, X_PK2                  IN     VARCHAR2
) RETURN VARCHAR2 IS

CURSOR C_FUNC ( C_Function_Name  VARCHAR2 ) IS
  SELECT function_id
  FROM   fnd_form_functions
  WHERE  function_name=C_Function_Name;

CURSOR C_WIP ( C_Org_ID  NUMBER , C_Job_ID  NUMBER ) IS
  SELECT project_id , task_id
  FROM   wip_discrete_jobs
  WHERE  organization_id = C_Org_ID
  AND    wip_entity_id = C_Job_ID;

CURSOR C_PO_Line ( C_Line_ID  NUMBER ) IS
  SELECT distinct L.oke_contract_header_id , D.oke_contract_line_id
  FROM   po_distributions_all D , po_lines_all L
  WHERE  D.po_line_id = C_Line_ID
  AND    L.po_line_id = D.po_line_id;

CURSOR C_PO_Dist ( C_Dist_ID  NUMBER ) IS
  SELECT L.oke_contract_header_id , D.oke_contract_line_id , D.project_id , D.task_id
  FROM   po_distributions_all D , po_lines_all L
  WHERE  D.po_distribution_id = C_Dist_ID
  AND    L.po_line_id         = D.po_line_id;

CURSOR C_Req_Line ( C_Line_ID  NUMBER ) IS
  SELECT distinct L.oke_contract_header_id , D.oke_contract_line_id
  FROM   po_req_distributions_all D , po_requisition_lines_all L
  WHERE  D.requisition_line_id = C_Line_ID
  AND    L.requisition_line_id = D.requisition_line_id;

CURSOR C_Req_Dist ( C_Dist_ID  NUMBER ) IS
  SELECT L.oke_contract_header_id , D.oke_contract_line_id , D.project_id , D.task_id
  FROM   po_req_distributions_all D , po_requisition_lines_all L
  WHERE  D.distribution_id     = C_Dist_ID
  AND    L.requisition_line_id = D.requisition_line_id;

CURSOR C_Shipping ( C_Delivery_detail_ID  NUMBER ) IS
  SELECT d.k_header_id ,D.k_line_id , d.project_id , d.task_id
  FROM   wsh_delivery_details W , oke_k_deliverables_b D
  WHERE  W.delivery_detail_id = C_Delivery_detail_ID
  AND    W.source_code        ='OKE'
  AND    D.deliverable_id     = W.source_line_id;

   user_id            NUMBER;
   resp_id            NUMBER;
   resp_appl_id       NUMBER;
   sec_grp_id         NUMBER;
   session_id         NUMBER;
   actual_target      VARCHAR2(2000);
   apps_web_agent_url VARCHAR2(2000);
   encrypted_ids      VARCHAR2(512);
   encrypted_params   VARCHAR2(10000);
   encryption_string  VARCHAR2(500);
   other_params       VARCHAR2(1000);

   L_Function_ID      NUMBER;
   L_K_Hdr_ID         NUMBER;
   L_K_Line_ID        NUMBER;
   L_Proj_ID          NUMBER;
   L_Task_ID          NUMBER;
   URL_Text           VARCHAR2(2000);

BEGIN

   /* func_id, userid, resp_id, and func_id will indicate which func we want */

   user_id      := to_number(fnd_profile.value('USER_ID'));
   resp_id      := to_number(fnd_profile.value('RESP_ID'));
   resp_appl_id := to_number(fnd_profile.value('RESP_APPL_ID'));
   sec_grp_id   := to_number(fnd_profile.value('SECURITY_GROUP_ID'));


--   /* Get profile plsql agent with one trailing slash */
-- do not need plsql_agent bug#4865201
--   apps_web_agent_url := fnd_web_config.plsql_agent(help_mode=>'APPS');

--   if (apps_web_agent_url is null) then
--      FND_MESSAGE.RETRIEVE;
--      FND_MESSAGE.ERROR;
--      RETURN ;
--   end if;

   /* prepare other_params. */

   --
   -- PO is passing a business area of PO.  Need to transform that to
   -- PROCUREMENT.  Long term we need to ask PO to fix the call
   --
   IF ( X_Business_Area = 'PO' ) THEN
      other_params := 'p_ba=PROCUREMENT';
   ELSE
      other_params := 'p_ba=' || X_Business_Area;
   END IF;

   --
   -- Initializing output
   --
   L_K_Hdr_ID  := NULL;
   L_K_Line_ID := NULL;
   L_Proj_ID   := NULL;
   L_Task_ID   := NULL;

   --
   -- Retrieveing contract / project reference from desired objects
   --
   IF ( X_Object_Name = 'WIP_DISCRETE_JOBS' ) THEN

      OPEN C_WIP ( X_PK1 , X_PK2 );
      FETCH C_WIP INTO L_Proj_ID , L_Task_ID;
      CLOSE C_WIP;

   ELSIF ( X_Object_Name = 'PO_LINES' ) THEN

      L_K_Line_ID := NULL;
      FOR c IN C_PO_Line ( X_PK1 ) LOOP
        IF L_K_Line_ID IS NOT NULL AND L_K_Line_ID <> c.oke_contract_line_id THEN
          L_K_Line_ID := NULL;
          EXIT;
        END IF;
        L_K_Hdr_ID := c.oke_contract_header_id;
        L_K_Line_ID := c.oke_contract_line_id;
      END LOOP;

   ELSIF ( X_Object_Name = 'PO_DISTRIBUTIONS' ) THEN

      OPEN C_PO_Dist ( X_PK1 );
      FETCH C_PO_Dist INTO L_K_Hdr_ID , L_K_Line_ID , L_Proj_ID , L_Task_ID;
      CLOSE C_PO_Dist;

   ELSIF ( X_Object_Name = 'PO_REQUISITION_LINES' ) THEN

      L_K_Line_ID := NULL;
      FOR c IN C_Req_Line ( X_PK1 ) LOOP
        IF L_K_Line_ID IS NOT NULL AND L_K_Line_ID <> c.oke_contract_line_id THEN
          L_K_Line_ID := NULL;
          EXIT;
        END IF;
        L_K_Hdr_ID := c.oke_contract_header_id;
        L_K_Line_ID := c.oke_contract_line_id;
      END LOOP;

   ELSIF ( X_Object_Name = 'PO_REQ_DISTRIBUTIONS' ) THEN

      OPEN C_Req_Dist ( X_PK1 );
      FETCH C_Req_Dist INTO L_K_Hdr_ID , L_K_Line_ID , L_Proj_ID , L_Task_ID ;
      CLOSE C_Req_Dist;

   ELSIF ( X_Object_Name = 'WSH_DELIVERY_DETAILS' ) THEN

      OPEN C_Shipping ( X_PK1 );
      FETCH C_Shipping INTO L_K_Hdr_ID , L_K_Line_ID , L_Proj_ID , L_Task_ID ;
      CLOSE C_Shipping;

   ELSIF ( X_Object_Name = 'OKE_K_HEADERS' ) THEN

      L_K_Hdr_ID := X_PK1;

   END IF;

   IF ( L_K_Hdr_ID IS NULL ) THEN
      --
      -- Contract reference not found; base flowdown on project reference
      --
      OPEN C_FUNC ( 'OKEFLDVS' );
      FETCH C_FUNC INTO L_Function_ID;
      CLOSE C_FUNC;

      other_params := other_params ||
                      '&p_project_id=' || L_Proj_ID ||
                      '&p_task_id='    || L_Task_ID;

   ELSE
      --
      -- Contract reference found; base flowdown on contract reference
      --
      OPEN C_FUNC ( 'OKEFLDVH' );
      FETCH C_FUNC INTO L_Function_ID;
      CLOSE C_FUNC;

      other_params := other_params ||
                      '&p_k_header_id=' || L_K_Hdr_ID ||
                      '&p_k_line_id='   || L_K_Line_ID ||
                      '&p_project_id='  || L_Proj_ID ||
                      '&p_task_id='     || L_Task_ID ;

   END IF;

   --
   -- Add parameter to enable Bread Crumbs
   --
   other_params := other_params || '&addBreadCrumb=Y';

   IF ( X_Business_Area <> 'APPROVAL' ) THEN
     other_params := other_params || '&CallFromForm=''Y''';
   END IF;

/*  plsql_agent bug#4865201
   --
   -- Prepare and encrypt the parameters
   --
   encryption_string := to_char(user_id)||'*'
                        ||to_char(resp_appl_id)||'*'
                        ||to_char(resp_id)||'*'
                        ||to_char(sec_grp_id)||'*'
                        ||to_char(L_Function_id)||'**]';

   encrypted_ids     := icx_call.encrypt(encryption_string);

   encrypted_params  := icx_call.encrypt(other_params);

   --
   -- Construct the URL
   --
   URL_Text:=apps_web_agent_url
           ||'OracleApps.LF?F='
           ||encrypted_ids
           ||'&P='
           ||encrypted_params;
*/
   URL_Text:= fnd_run_function.get_run_function_url(
     L_Function_id, resp_appl_id, resp_id, sec_grp_id, other_params
   );

   RETURN ( URL_Text );

EXCEPTION
WHEN OTHERS THEN
  RETURN ( apps_web_agent_url || 'oraclemypage.home' );
END Flowdown_URL;


PROCEDURE INSERT_ROW
( P_BUSINESS_AREA_CODE   IN  VARCHAR2
, P_FLOWDOWN_TYPE        IN  VARCHAR2
, P_FLOWDOWN_CODE        IN  VARCHAR2
, P_ATTRIBUTE_GROUP_TYPE IN  VARCHAR2
) IS
  L_CREATION_DATE        DATE;
  L_CREATED_BY           NUMBER;
  L_LAST_UPDATE_LOGIN    NUMBER;

BEGIN

  L_CREATION_DATE        := SYSDATE;
  L_CREATED_BY           := FND_GLOBAL.USER_ID;
  L_LAST_UPDATE_LOGIN    := FND_GLOBAL.LOGIN_ID;

  INSERT INTO OKE_FLOWDOWNS
  ( BUSINESS_AREA_CODE
  , FLOWDOWN_TYPE
  , FLOWDOWN_CODE
  , ATTRIBUTE_GROUP_TYPE
  , CREATION_DATE
  , CREATED_BY
  , LAST_UPDATE_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_LOGIN
  ) VALUES
  ( P_BUSINESS_AREA_CODE
  , P_FLOWDOWN_TYPE
  , P_FLOWDOWN_CODE
  , Decode(P_FLOWDOWN_TYPE,'ATTRIBUTE',P_ATTRIBUTE_GROUP_TYPE,'NONE')
  , L_CREATION_DATE
  , L_CREATED_BY
  , L_CREATION_DATE
  , L_CREATED_BY
  , L_LAST_UPDATE_LOGIN
  );

END INSERT_ROW;

PROCEDURE DELETE_ROW
( P_BUSINESS_AREA_CODE    IN     VARCHAR2
, P_FLOWDOWN_TYPE         IN     VARCHAR2
, P_FLOWDOWN_CODE         IN     VARCHAR2
, P_ATTRIBUTE_GROUP_TYPE  IN     VARCHAR2
) IS

BEGIN

  DELETE FROM OKE_FLOWDOWNS
  WHERE BUSINESS_AREA_CODE = P_BUSINESS_AREA_CODE
    AND FLOWDOWN_TYPE = P_FLOWDOWN_TYPE
    AND ( P_FLOWDOWN_CODE IS NULL
      OR FLOWDOWN_CODE = P_FLOWDOWN_CODE
       AND ATTRIBUTE_GROUP_TYPE =
        Decode( P_FLOWDOWN_TYPE, 'ATTRIBUTE', P_ATTRIBUTE_GROUP_TYPE, 'NONE') );

END DELETE_ROW;


END OKE_FLOWDOWN_UTILS;

/
