--------------------------------------------------------
--  DDL for Package Body BISVIEWER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BISVIEWER_PUB" AS
/* $Header: BISPUBPB.pls 120.0 2005/06/01 17:41:54 appldev noship $ */
-- Added for ARU db drv auto generation
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb 
-- dbdrv: checkfile(115.13=120.0):~PROD:~PATH:~FILE

procedure    showReport(pUrlString        in   varchar2,
                        pUserId           in   varchar2    default null,
                        pRespId           in   varchar2    default null ,
                        pSessionId        in   varchar2    default null,
                        pFunctionName     in   varchar2    default null,
                        --added pPageId for enhancement #2442162
                        pPageId           in   varchar2    default null
                       )

IS
l_resp_id           varchar2(80);
l_url_string        VARCHAR2(5000);
l_session_id        VARCHAR2(80);
l_application_id 	NUMBER;
l_function_id       NUMBER;

CURSOR cFndResp (pRespId IN VARCHAR2) IS
SELECT application_id
FROM fnd_responsibility
WHERE responsibility_id = pRespId;

BEGIN

   --jprabhud enhancement #2442162
   IF NOT icx_sec.ValidateSession THEN
      RETURN;
    END IF;
    if (pRespId is not null and to_number(pRespId) > 0) then
       l_resp_id := pRespId;
    else
       l_resp_id := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);
    end if;
   --nbarik - 05/15/04 - Enhancement 3576963 - Drill Java Conversion
   -- nbarik - 04/23/04 - Bug Fix 3589098
   -- Senthil bugFix #4112205
   l_url_string := pUrlString;
   IF (pFunctionName IS NOT NULL) THEN
     l_url_string := l_url_string || '&pFunctionName=' || BIS_PMV_UTIL.encode(pFunctionName);
   END IF;
   l_url_string := 'pMode=1&pUrlString=' || BIS_PMV_UTIL.encode(l_url_string);


   IF (pUserId IS NOT NULL) THEN
     l_url_string := l_url_string || '&pUserId=' || pUserId;
   END IF;
   IF (pRespId IS NOT NULL) THEN
     l_url_string := l_url_string || '&pRespId=' || pRespId;
   END IF;
   IF (pSessionId IS NOT NULL) THEN
     l_url_string := l_url_string || '&pSessionId=' || pSessionId;
   END IF;
   IF (pPageId IS NOT NULL) THEN
     l_url_string := l_url_string || '&pPageId=' || pPageId;
   END IF;
  IF (pSessionId is not null) then
    l_session_id := pSessionId;
  ELSE
    l_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);
  END IF;

  IF cFNDResp%ISOPEN THEN
   CLOSE cFNDResp;
  END IF;
  OPEN cFNDResp(l_resp_id);
  FETCH cFNDResp INTO l_application_id;
  CLOSE cFNDResp;

  SELECT function_id
  INTO l_function_id
  FROM fnd_form_functions
  WHERE function_name = 'BIS_PMV_DRILL_JSP';

  OracleApps.runFunction (
                      c_function_id => l_function_id
                    , n_session_id => l_session_id
                    , c_parameters => l_url_string
                    , p_resp_appl_id => l_application_id
                    , p_responsibility_id => l_resp_id
                    , p_Security_group_id => icx_sec.g_security_group_id
                  );
  /*
   BIS_PMV_DRILL_PVT.drillacross(pURLString => l_url_string,
                                 pUserId  => pUserId,
                                 pSessionId => pSessionId,
                                 pRespId => l_resp_id, --jprabhud enhancement #2442162
                                 --jprabhud do not pass pFunctionName, null will be used enhancement #2442162
                                 --jprabhud added pPageId for enhancement #2442162
                                 pPageId=>pPageId
                                 );
   */
EXCEPTION
  WHEN OTHERS THEN
	  IF cFNDResp%ISOPEN THEN
	   CLOSE cFNDResp;
	  END IF;

END showReport;

END BISVIEWER_PUB;

/
