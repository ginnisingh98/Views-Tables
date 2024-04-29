--------------------------------------------------------
--  DDL for Package Body BIS_RG_SCHEDULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_RG_SCHEDULES_PVT" as
/* $Header: BISVSCHB.pls 120.2.12000000.3 2007/02/06 07:47:47 akoduri ship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
-- dbdrv: checkfile(115.62=120.2.12000000.3):~PROD:~PATH:~FILE
----------------------------------------------------------------------------
--  PACKAGE:      BIS_SCHEDULE_PVT
--                                                                        --
--  DESCRIPTION:  Private package to create records in BIS_SCHEDULER
--
--                                                                        --
--  MODIFICATIONS                                                         --
--  Date       User       Modification
--  XX-XXX-XX  XXXXXXXX   Modifications made, which procedures changed &  --
--                        list bug number, if fixing a bug.               --
--                                                                        --
--  02-25-00   amkulkar   Initial creation                                --
--  5/12/01    aleung     need to duplicate records(but schedule id is null)
--                        for drilldown from table porlet to work         --
--  07/03/01   mdamle	  Scheduling Enhancements			  --
--  08/01/01   mdamle 	  Check for expired default schedule Bug# 1925970 --
--  08/20/01   mdamle	  Scheduling Enhancements - Phase II - unsubscribe--
--  09/04/01   mdamle	  Scheduling Enhancements - Phase II - purge      --
--  09/04/01   mdamle     Scheduling Enhancements - Phase II - Multiple   --
--	                  Preferences per schedule			  --
--  09/13/01   mdamle	  Fixed Bug#1994876				  --
--  09/19/01   mdamle	  Remove background purge of email data		  --
--  09/19/01   mdamle	  Trap File_ID creation error			  --
--  09/21/01   mdamle	  Fixed Bug#1999207				  --
--  09/21/01   mdamle 	  Fixed Bug#1999262 				  --
--  10/25/01   mdamle	  Update Title in ICX_PORTLET_CUSTOMIZATIONS 	  --
--  12/04/01   mdamle	  Title in ICX_PORTLET_CUSTOMIZATIONS is link 	  --
--  12/12/01   mdamle	  Changes for Live Portlet		 	  --
--  01/03/02   mdamle     Added plug_id to TL				  --
--  01/16/02   mdamle     External Source Id changes			  --
--  01/25/02   mdamle     Fix profile option bug for getUserType	  --
--  11/29/02   nkishore   Added creating_schedule, updating_schedule	  --
--  03/12/03   rcmuthuk   Bug Fix:2807197 - added regionCode and functionName params to redirect URL --
--  04/25/03   rcmuthuk   Bug Fix:2799113 - Changed order of parmPrint param --
--  06/05/03   nkishore   BugFix 2972706 -- Encode Report Title           --
--  09/08/03   nkishore   BugFix 3127079 -- Call FND_MSG.COUNT_AND_GET    --
--  10/10/03   ksadagop   Bug Fix:3182441 -- Encoded header and reportTitle --
--  01/19/04   nkishore   Save Report to PDF                                --
--  01/25/07   akoduri    Bug#5752469  Issue with Cancel & Apply buttons  d--
--                        in portal                                       --
--  02/06/07   akoduri    GSCC Error while building R12 ARU               --
----------------------------------------------------------------------------

-- mdamle 07/03/01 - Scheduling Enhancements
gvRoleName varchar2(20) := 'BIS_SCHEDULE_';

-- copied from bisviewer_pmf for bug 5031067
procedure scheduleReports(
    pRegionCode         in  varchar2,
	pFunctionName       in  varchar2,
    pUserId             in  varchar2,
    pSessionId          in  varchar2,
    pResponsibilityId   in  varchar2,
    pReportTitle        in  varchar2 default NULL,
	pApplicationId      in  varchar2 default NULL,
    pParmPrint          in  varchar2 default NULL,
    pRequestType        in  varchar2 default 'R',
    pPlugId             in  varchar2 default NULL,
    pGraphType          in  varchar2 default NULL
    )
is
vScheduleURL varchar2(5000);
--l_customize_URL varchar2(32000);
l_customize_id   pls_integer;
l_fn_Responsibility_id number;
l_application_id number;
l_user_id        number;
l_rowid          varchar2(1000);

l_form_func_name  varchar2(1000) := 'BIS_SCHEDULE_PAGE';
l_form_func_call  varchar2(1000) := 'bissched.jsp';

vParams  varchar2(2000);

CURSOR cFndResp (pRespId in varchar2) is
select application_id
from fnd_responsibility
where responsibility_id=pRespId;

begin
      l_user_id := pUserId;

  l_fn_responsibility_id := nvl(pResponsibilityId, icx_sec.getid(ICX_SEC.PV_RESPONSIBILITY_ID));
  if pApplicationId is null then
     if cFNDResp%ISOPEN then
        CLOSE cFNDResp;
     end if;
     OPEN cFNDResp(l_fn_responsibility_id);
     FETCH cFNDResp INTO l_application_id;
     CLOSE cFNDResp;
  else
     l_application_id := pApplicationId;
  end if;

/*
      begin
           select application_id into l_application_id
           from fnd_responsibility
           where responsibility_id=l_fn_responsibility_id;
      end;

if pRequestType <> 'R' then
   l_form_func_name := 'BIS_SCHEDULE_CONFIRM_PAGE';
   l_form_func_call := 'bisschcf.jsp';
end if;
*/

      begin
           select function_id
           into l_customize_id
           from fnd_form_functions
           where function_name = l_form_func_name;
      exception
           when no_data_found then
              l_customize_id := null;
      end;

      if l_customize_id is null then
         begin
             select FND_FORM_FUNCTIONS_S.NEXTVAL into l_customize_id from dual;

--aleung, 5/14/01, for gsi1av envrionment, their fnd_form_functions_pkg.insert_row has more parameters

      fnd_form_functions_pkg.INSERT_ROW(
       X_ROWID                  => l_rowid,
       X_FUNCTION_ID            => l_customize_id,
       X_WEB_HOST_NAME          => null,
       X_WEB_AGENT_NAME         => null,
       X_WEB_HTML_CALL          => l_form_func_call,
       X_WEB_ENCRYPT_PARAMETERS => null,
       X_WEB_SECURED            => null,
       X_WEB_ICON               => null,
       X_OBJECT_ID              => null,
       X_REGION_APPLICATION_ID  => null,
       X_REGION_CODE            => null,
       X_FUNCTION_NAME          => l_form_func_name,
       X_APPLICATION_ID         => l_application_id,
       X_FORM_ID                => null,
       X_PARAMETERS             => null,
       X_TYPE                   => 'JSP',
       X_USER_FUNCTION_NAME     => 'BIS SCHEDULE',
       X_DESCRIPTION            => null,
       X_CREATION_DATE          => sysdate,
       X_CREATED_BY             => l_user_id,
       X_LAST_UPDATE_DATE       => sysdate,
       X_LAST_UPDATED_BY        => l_user_id,
       X_LAST_UPDATE_LOGIN      => l_user_id);

/*
             fnd_form_functions_pkg.insert_row (l_rowid,
                               l_customize_id, null,null,
                                l_form_func_call,
                                null,null,null,l_form_func_name,
                                l_application_id,null,null,'JSP','BIS SCHEDULE',
                                null,sysdate,l_user_id,sysdate,l_user_id,l_user_id);
*/

         exception
         when others then
           null;
         end;
      end if;

/*
      vScheduleURL := 'OracleApps.RF?F='||icx_call.encrypt2(l_application_id||'*'||l_fn_responsibility_id||'*'||icx_sec.g_security_group_id||'*'||l_customize_id||'**]',
                                                               icx_sec.getID(icx_sec.PV_SESSION_ID))
                                           ||'&P='||icx_call.encrypt2('regionCode='||bis_pmv_util.encode(pRegionCode)
                                           ||'&functionName='||bis_pmv_util.encode(pFunctionName)
                                           ||'&parmPrint='||bis_pmv_util.encode(pParmPrint)
                                           ||'&requestType='||pRequestType
                                           ||'&plugId='||pPlugId
                                           ||'&reportTitle='||bis_pmv_util.encode(pReportTitle)
                                           ||'&graphType='||pGraphType,icx_sec.getID(icx_sec.PV_SESSION_ID));
*/

    /*fnd_profile.get(name=>'APPS_SERVLET_AGENT',
                    val => vScheduleURL);
    vScheduleURL := FND_WEB_CONFIG.trail_slash(vScheduleURL)||
                   'bissched.jsp?dbc=' || FND_WEB_CONFIG.DATABASE_ID
                   ||'&sessionid='||icx_call.encrypt3(icx_sec.getID(icx_sec.PV_SESSION_ID))
                   ||'&responsibilityId='||pResponsibilityId
                   ||'&regionCode='||bis_pmv_util.encode(pRegionCode)
                   ||'&functionName='||bis_pmv_util.encode(pFunctionName)
                   ||'&parmPrint='||bis_pmv_util.encode(pParmPrint)
                   ||'&requestType='||pRequestType
                   ||'&plugId='||pPlugId
                   ||'&graphType='||pGraphType;*/

--    owa_util.redirect_url(vScheduleURL);

  -- mdamle 11/01/2002 - Added encode
  vParams := 'regionCode='|| pRegionCode
           ||'&functionName='||pFunctionName
           ||'&parmPrint='||bis_pmv_util.encode(pParmPrint)
           ||'&requestType='||pRequestType
           ||'&plugId='||pPlugId
           ||'&reportTitle='||pReportTitle
           ||'&graphType='||pGraphType;

  OracleApps.runFunction(c_function_id => l_customize_id
                        ,n_session_id => icx_sec.getID(icx_sec.PV_SESSION_ID)
                        ,c_parameters => vParams
                        ,p_resp_appl_id => l_application_id
                        ,p_responsibility_id => l_fn_responsibility_id
                        ,p_Security_group_id => icx_sec.g_Security_group_id
                        );

end scheduleReports;
--jprabhud 09/24/02 - Enh 2470068 Storing of Graphs to FND_LOBS
procedure deleteReportGraphsLobs(p_user_id in varchar2
                      ,p_schedule_id in varchar2
                      ,p_function_name in varchar2);

PROCEDURE  CREATE_SCHEDULE
(p_plug_id 			IN	NUMBER  	DEFAULT NULL
,p_user_id      		IN      VARCHAR2
,p_function_name		IN      VARCHAR2
,p_responsibility_id            IN      VARCHAR2
,p_title        		IN      VARCHAR2 	DEFAULT NULL
,p_graph_type   		IN      NUMBER 		DEFAULT NULL
,p_concurrent_request_id   	IN   	NUMBER 		DEFAULT NULL
-- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
,p_file_id      		IN OUT  NOCOPY NUMBER
,p_request_type			IN	VARCHAR2	DEFAULT NULL
,x_schedule_id                  OUT     NOCOPY NUMBER
,x_return_Status 		OUT     NOCOPY VARCHAR2
,x_msg_Data    			OUT     NOCOPY VARCHAR2
,x_msg_count    		OUT     NOCOPY NUMBER
-- mdamle 12/12/01 - Changes for Live Portlet
,p_live_portlet			IN	VARCHAR2	DEFAULT 'N'
--jprabhud - 12/20/02 - NLS Bug 2320171 Graph Fonts and Mutli-Byte characters
,p_context_values  	        IN	VARCHAR2  DEFAULT NULL
)
IS
  l_schedule_id                  NUMBER;
  l_request_Type                 VARCHAR2(1) := 'G';
BEGIN


  -- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
  -- Added the plug_id condition
  IF p_plug_id is null then
	l_request_type := 'R';
  else
	l_request_type := p_request_type;
  END IF;

  -- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Purge Portlet Data
  /*
  if p_plug_id is not null then
	delete_portlet(p_plug_id, p_user_id);
  end if;
  */

  SELECT bis_scheduler_s.nextval INTO l_schedule_id FROM dual;
  INSERT INTO BIS_SCHEDULER
  (schedule_id
  -- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
  --,plug_id
  ,user_id
  ,function_name
  ,responsibility_id
  -- ,title
  -- ,graph_type
  ,concurrent_request_id
  -- ,file_id
  ,creation_Date
  ,last_update_date
  ,created_By
  ,last_update_login
  )
  VALUES
  (l_schedule_id
  -- ,p_plug_id
  ,p_user_id
  ,p_function_name
  ,p_responsibility_id
  -- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
  -- ,p_title
  -- ,p_graph_type
  ,p_concurrent_request_id
  -- ,get_file_id(l_Request_Type)
  ,SYSDATE
  ,SYSDATE
  ,0
  ,0
  );

  -- mdamle 09/04/01, 12/12/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
  -- jprabhud 09/24/02 - Enh. 2470068 DB Graph HTML - Reusing file Ids to store graphs - passed in function name
  --jprabhud - 12/20/02 - NLS Bug 2320171 Graph Fonts and Mutli-Byte characters - passed in p_context_values
  create_schedule_preferences(l_schedule_id, p_user_id, p_plug_id, p_title, p_graph_type, l_request_type, p_file_id, p_live_portlet,p_function_name,p_context_values);

  commit;
  x_schedule_id := l_schedule_id;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
/* BugFix 3127079
  FND_MSG_PUB.COUNT_AND_GET
  (p_count => x_msg_count
  ,p_data  => x_msg_Data
  );*/

EXCEPTION
WHEN OTHERS THEN
   --WHEN FND_API.G_EXC_ERROR
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.COUNT_AND_GET
        (p_count => x_msg_count
        ,p_data  => x_msg_data
        );
END;

/* serao, 06/03, This creates a schedule for the create schedule call with the same signature but does not do a commit.
   Called by Related Links Functionality
   */
PROCEDURE  CREATE_SCHEDULE_NO_COMMIT
(p_plug_id 			IN	NUMBER   DEFAULT NULL
,p_user_id      		IN      VARCHAR2
,p_function_name		IN      VARCHAR2
,p_responsibility_id            IN      VARCHAR2
,p_title        		IN      VARCHAR2 DEFAULT NULL
,p_graph_type   		IN      NUMBER   DEFAULT NULL
,p_request_type			IN	VARCHAR2 DEFAULT NULL
,x_schedule_id                  OUT     NOCOPY NUMBER
-- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
,x_file_id			OUT	NOCOPY NUMBER
,x_return_Status 		OUT     NOCOPY VARCHAR2
,x_msg_Data    			OUT     NOCOPY VARCHAR2
,x_msg_count    		OUT     NOCOPY NUMBER
-- mdamle 12/12/01 - Changes for Live Portlet
,p_live_portlet			IN	VARCHAR2 DEFAULT 'N'
)
IS
  l_schedule_id                  NUMBER;
  l_Request_Type                 VARCHAR2(1);
BEGIN

  -- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
  -- Added the plug_id condition
  IF p_plug_id is null then
	l_request_type := 'R';
  else
	l_request_type := p_request_type;
  END IF;

  -- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Purge Portlet Data
  /*
  if p_plug_id is not null then
	delete_portlet(p_plug_id, p_user_id);
  end if;
  */
  SELECT bis_scheduler_s.nextval INTO l_schedule_id FROM dual;
  INSERT INTO BIS_SCHEDULER
  (schedule_id
  -- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
  -- ,plug_id
  ,user_id
  ,function_name
  ,responsibility_id
  -- ,title
  -- ,graph_type
  ,concurrent_request_id
  -- ,file_id
  ,creation_Date
  ,last_update_date
  ,created_By
  ,last_update_login
  )
  VALUES
  (l_schedule_id
  -- ,p_plug_id
  ,p_user_id
  ,p_function_name
  ,p_responsibility_id
  -- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
  -- ,p_title
  -- ,p_graph_type
  ,NULL--current_request_id
  -- ,get_File_id(l_request_Type)
  ,SYSDATE
  ,SYSDATE
  ,0
  ,0
  );


  -- mdamle 09/04/01, 12/12/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
  create_schedule_preferences(l_schedule_id, p_user_id, p_plug_id, p_title, p_graph_type, l_request_type, x_file_id, p_live_portlet);

  x_schedule_id := l_schedule_id;
END CREATE_SCHEDULE_NO_COMMIT;

PROCEDURE  CREATE_SCHEDULE
(p_plug_id 			IN	NUMBER   DEFAULT NULL
,p_user_id      		IN      VARCHAR2
,p_function_name		IN      VARCHAR2
,p_responsibility_id            IN      VARCHAR2
,p_title        		IN      VARCHAR2 DEFAULT NULL
,p_graph_type   		IN      NUMBER   DEFAULT NULL
,p_request_type			IN	VARCHAR2 DEFAULT NULL
,x_schedule_id                  OUT     NOCOPY NUMBER
-- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
,x_file_id			OUT	NOCOPY NUMBER
,x_return_Status 		OUT     NOCOPY VARCHAR2
,x_msg_Data    			OUT     NOCOPY VARCHAR2
,x_msg_count    		OUT     NOCOPY NUMBER
-- mdamle 12/12/01 - Changes for Live Portlet
,p_live_portlet			IN	VARCHAR2 DEFAULT 'N'
) IS

BEGIN

 CREATE_SCHEDULE_NO_COMMIT(
    p_plug_id
    ,p_user_id
    ,p_function_name
    ,p_responsibility_id
    ,p_title
    ,p_graph_type
    ,p_request_type
    ,x_schedule_id
    -- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
    ,x_file_id
    ,x_return_Status
    ,x_msg_Data
    ,x_msg_count
    -- mdamle 12/12/01 - Changes for Live Portlet
    ,p_live_portlet
  );
  COMMIT;

END CREATE_SCHEDULE;

PROCEDURE  CREATE_SCHEDULE
(p_plug_id 			IN	NUMBER       DEFAULT NULL
,p_user_id      		IN      VARCHAR2
,p_function_name		IN      VARCHAR2
,p_responsibility_id            IN      VARCHAR2
,p_title        		IN      VARCHAR2     DEFAULT NULL
,p_graph_type   		IN      NUMBER       DEFAULT NULL
,p_concurrent_request_id   	IN   	NUMBER       DEFAULT NULL
  -- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
,p_file_id      		IN OUT  NOCOPY NUMBER
,p_session_id			IN      VARCHAR2       DEFAULT NULL
,p_report_region_code           IN 	VARCHAR2       DEFAULT NULL
,p_request_type			IN	VARCHAR2	DEFAULT NULL
,x_Schedule_id                  OUT     NOCOPY NUMBER
,x_return_Status 		OUT     NOCOPY VARCHAR2
,x_msg_Data    			OUT     NOCOPY VARCHAR2
,x_msg_count    		OUT     NOCOPY NUMBER
-- mdamle 12/12/01 - Changes for Live Portlet
,p_live_portlet			IN	VARCHAR2	DEFAULT 'N'
--jprabhud - 12/20/02 - NLS Bug 2320171 Graph Fonts and Mutli-Byte characters
,p_context_values  	        IN	VARCHAR2  DEFAULT NULL
)
IS
  l_schedule_id                 NUMBER;
BEGIN

  BIS_RG_SCHEDULES_PVT.CREATE_SCHEDULE
  (p_plug_id
  ,p_user_id
  ,p_function_name
  ,p_responsibility_id
  ,p_title
  ,p_graph_Type
  ,p_concurrent_request_id
  ,p_file_id
  ,p_request_type
  ,l_schedule_id
  ,x_return_status
  ,x_msg_Data
  ,x_msg_count
  -- mdamle 12/12/01 - Changes for Live Portlet
  ,p_live_portlet
  --jprabhud - 12/20/02 - NLS Bug 2320171 Graph Fonts and Mutli-Byte characters
  ,p_context_values
  );
  x_Schedule_id := l_schedule_id;
  BEGIN
  UPDATE BIS_USER_ATTRIBUTES
  SET schedule_id = l_schedule_id
  WHERE session_id=p_Session_id AND
        function_name = p_function_name AND
        user_id = p_user_id AND
        schedule_id is null;

/* -- aleung, 10/19/01, no need to do this, should retrieve data according to schedule id
  -- aleung, 5/12/01, need to duplicate records(but schedule id is null)
  -- for drilldown from table porlet to work
  insert into bis_user_attributes (USER_ID,
                                   FUNCTION_NAME,
                                   SESSION_ID,
                                   SESSION_VALUE,
                                   SESSION_DESCRIPTION,
                                   DEFAULT_VALUE,
                                   DEFAULT_DESCRIPTION,
                                   ATTRIBUTE_NAME,
                                   DIMENSION,
                                   PERIOD_DATE)
  select  USER_ID,
          FUNCTION_NAME,
          SESSION_ID,
          SESSION_VALUE,
          SESSION_DESCRIPTION,
          DEFAULT_VALUE,
          DEFAULT_DESCRIPTION,
          ATTRIBUTE_NAME,
          DIMENSION,
          PERIOD_DATE
  from    bis_user_attributes
  where   schedule_id = l_schedule_id;
*/

  END;
  COMMIT;
EXCEPTION
WHEN OTHERS THEN
     NULL;
END;

--Customize UI Enhancement
PROCEDURE  CREATING_SCHEDULE
(p_plug_id 			IN	NUMBER       DEFAULT NULL
,p_user_id      		IN      VARCHAR2
,p_function_name		IN      VARCHAR2
,p_responsibility_id            IN      VARCHAR2
,p_title        		IN      VARCHAR2     DEFAULT NULL
,p_graph_type   		IN      NUMBER       DEFAULT NULL
,p_concurrent_request_id   	IN   	NUMBER       DEFAULT NULL
  -- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
,p_file_id      		IN OUT  NOCOPY NUMBER
,p_session_id			IN      VARCHAR2       DEFAULT NULL
,p_report_region_code           IN 	VARCHAR2       DEFAULT NULL
,p_request_type			IN	VARCHAR2	DEFAULT NULL
,x_Schedule_id                  OUT     NOCOPY NUMBER
,x_return_Status 		OUT     NOCOPY VARCHAR2
,x_msg_Data    			OUT     NOCOPY VARCHAR2
,x_msg_count    		OUT     NOCOPY NUMBER
--jprabhud - 12/20/02 - NLS Bug 2320171 Graph Fonts and Mutli-Byte characters
,p_context_values  	        IN	VARCHAR2  DEFAULT NULL
)
IS
  l_schedule_id                 NUMBER;
  l_request_Type                 VARCHAR2(1) := 'G';
BEGIN

  IF p_plug_id is null then
	l_request_type := 'R';
  else
	l_request_type := p_request_type;
  END IF;
  SELECT bis_scheduler_s.nextval INTO l_schedule_id FROM dual;
  INSERT INTO BIS_SCHEDULER
  (schedule_id
  -- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
  --,plug_id
  ,user_id
  ,function_name
  ,responsibility_id
  -- ,title
  -- ,graph_type
  ,concurrent_request_id
  -- ,file_id
  ,creation_Date
  ,last_update_date
  ,created_By
  ,last_update_login
  )
  VALUES
  (l_schedule_id
  -- ,p_plug_id
  ,p_user_id
  ,p_function_name
  ,p_responsibility_id
  -- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
  -- ,p_title
  -- ,p_graph_type
  ,p_concurrent_request_id
  -- ,get_file_id(l_Request_Type)
  ,SYSDATE
  ,SYSDATE
  ,0
  ,0
  );

  -- mdamle 09/04/01, 12/12/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
  --jprabhud - 12/20/02 - NLS Bug 2320171 Graph Fonts and Mutli-Byte characters - passed in p_context_values
  create_schedule_preferences(l_schedule_id, p_user_id, p_plug_id, p_title, p_graph_type, l_request_type, p_file_id, 'N', p_function_name,p_context_values);
  commit;

  x_Schedule_id := l_schedule_id;
  BEGIN
  insert into bis_user_attributes (USER_ID,
                                   FUNCTION_NAME,
                                   SESSION_ID,
                                   SESSION_VALUE,
                                   SESSION_DESCRIPTION,
                                   DEFAULT_VALUE,
                                   DEFAULT_DESCRIPTION,
                                   ATTRIBUTE_NAME,
                                   DIMENSION,
                                   PERIOD_DATE,
				   SCHEDULE_ID)
  select  USER_ID,
          FUNCTION_NAME,
          SESSION_ID,
          SESSION_VALUE,
          SESSION_DESCRIPTION,
          DEFAULT_VALUE,
          DEFAULT_DESCRIPTION,
          ATTRIBUTE_NAME,
          DIMENSION,
          PERIOD_DATE,
	  l_schedule_id
  from    bis_user_attributes
    WHERE session_id=p_Session_id AND
          function_name = p_function_name AND
          user_id = p_user_id AND
          schedule_id is null;
  END;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.COUNT_AND_GET
  (p_count => x_msg_count
  ,p_data  => x_msg_Data
  );


EXCEPTION
WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.COUNT_AND_GET
      (p_count => x_msg_count
      ,p_data  => x_msg_data
      );
END;

PROCEDURE UPDATE_SCHEUDLE
(p_schedule_id                 IN       NUMBER
,p_user_id                     IN       VARCHAR2     DEFAULT NULL
,p_function_name               IN       VARCHAR2     DEFAULT NULL
,p_title                       IN       VARCHAR2     DEFAULT NULL
,p_graph_type                  IN       NUMBER       DEFAULT NULL
,p_concurrent_Request_id       IN       NUMBER       DEFAULT NULL
,p_file_id                     IN       NUMBER       DEFAULT NULL
,x_return_Status               OUT      NOCOPY VARCHAR2
,x_msg_data                    OUT      NOCOPY VARCHAR2
,x_msg_count                   OUT      NOCOPY NUMBER
-- mdamle 07/03/01 - Scheduling Enhancements
,p_parameters		       IN	VARCHAR2 default null
)
IS
BEGIN
 UPDATE BIS_SCHEDULER
 SET user_id = p_user_id
    ,function_name = p_function_name
    ,title = p_title
    ,graph_type = p_graph_type
    ,concurrent_request_id=p_concurrent_request_id
    ,file_id  = p_file_id
    ,last_update_date=SYSDATE
    -- mdamle 07/03/01 - Scheduling Enhancements
    ,parameter_string = p_parameters
  WHERE schedule_id=p_schedule_id;

EXCEPTION
WHEN OTHERS THEN
     NULL; -- Add proper Error Handling
END;
PROCEDURE UPDATE_SCHEDULE
(p_schedule_id                 IN       NUMBER
,p_concurrent_Request_id       IN       NUMBER
,x_return_Status               OUT      NOCOPY VARCHAR2
,x_msg_Data                    OUT      NOCOPY VARCHAR2
,x_msg_count                   OUT      NOCOPY NUMBER
-- mdamle 07/03/01 - Scheduling Enhancements
,p_parameters		       IN	VARCHAR2 default null
,p_commit		       IN       VARCHAR2 DEFAULT 'Y'
)
IS
BEGIN
   -- mdamle 07/03/01 - Scheduling Enhancements
   -- Added parameters field to update
   UPDATE bis_scheduler
   SET concurrent_request_id = p_concurrent_request_id
   , parameter_string = p_parameters
   WHERE schedule_id = p_schedule_id;

   if (p_commit = 'Y') then
     COMMIT;
   end if;


EXCEPTION
WHEN OTHERS THEN
     NULL; -- Add proper error handling
END;

--nkishore Customize UI Enhancement
PROCEDURE UPDATING_SCHEDULE
(p_schedule_id                 IN       NUMBER
,p_user_id                     IN       VARCHAR2
,p_function_name               IN       VARCHAR2
,p_session_id                  IN       VARCHAR2
,x_return_Status               OUT      NOCOPY VARCHAR2
,x_msg_data                    OUT      NOCOPY VARCHAR2
,x_msg_count                   OUT      NOCOPY NUMBER
)
IS
BEGIN

  DELETE FROM bis_user_attributes
  WHERE  schedule_id = p_schedule_id
  AND    function_name = p_function_name;

  UPDATE BIS_USER_ATTRIBUTES
  SET schedule_id = p_schedule_id
  WHERE session_id=p_Session_id AND
        function_name = p_function_name AND
        user_id = p_user_id AND
        schedule_id is null;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.COUNT_AND_GET
  (p_count => x_msg_count
  ,p_data  => x_msg_Data
  );


EXCEPTION
WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.COUNT_AND_GET
      (p_count => x_msg_count
      ,p_data  => x_msg_data
      );
END;

FUNCTION GET_FILE_ID
(p_request_type     IN  VARCHAR2)
RETURN NUMBER
IS
  l_File_id          NUMBER;
  l_content_type     VARCHAR2(32000);
BEGIN
 --CREATE AN EMPTY FILE;
 --Save Report to PDF add application/pdf
  IF (p_request_Type = 'G') THEN
     l_content_type := 'IMAGE/GIF';
  ELSIF (p_request_Type = 'PDF') THEN
     l_content_type := 'application/pdf';
  ELSE
     l_content_type := 'TEXT/HTML';
  END IF;
  l_file_id := BIS_SAVE_REPORT.CREATEENTRY
  ('BIS_REPORT'
  ,l_Content_type
  ,null
  ,null);

  if l_file_id is null then
  	l_file_id := 0;
  end if;

  RETURN l_file_id;
END;
PROCEDURE IS_SCHEDULED
(p_user_id			IN	VARCHAR2
,p_function_name		IN	VARCHAR2
,p_report_region_code		IN	VARCHAR2  DEFAULT NULL
,p_session_id			IN	VARCHAR2  DEFAULT NULL
,p_parameter1			IN	VARCHAR2  DEFAULT NULL
,p_parameter2			IN	VARCHAR2  DEFAULT NULL
,p_parameter3			IN	VARCHAR2  DEFAULT NULL
,p_parameter4			IN	VARCHAR2  DEFAULT NULL
,p_parameter5			IN	VARCHAR2  DEFAULT NULL
,p_parameter6			IN	VARCHAR2  DEFAULT NULL
,p_parameter7			IN	VARCHAR2  DEFAULT NULL
,p_parameter8			IN	VARCHAR2  DEFAULT NULL
,p_parameter9			IN	VARCHAR2  DEFAULT NULL
,p_parameter10			IN	VARCHAR2  DEFAULT NULL
,p_parameter11			IN	VARCHAR2  DEFAULT NULL
,p_parameter12			IN	VARCHAR2  DEFAULT NULL
,p_parameter13			IN	VARCHAR2  DEFAULT NULL
,p_parameter14			IN	VARCHAR2  DEFAULT NULL
,p_parameter15			IN	VARCHAR2  DEFAULT NULL
,p_timetoparameter		IN	VARCHAR2  DEFAULT NULL
,p_timefromparameter		IN	VARCHAR2  DEFAULT NULL
,p_viewby			IN	VARCHAR2  DEFAULT NULL
,x_Scheduled			OUT	NOCOPY VARCHAR2
)
IS
  CURSOR c_attrs IS
  SELECT attribute_name, session_value
  FROM bis_user_attributes
  WHERE user_id=p_user_id AND
	function_name = p_function_name AND
        schedule_id IS NOT NULL;
   l_scheduled    varchar2(1);

BEGIN
  FOR c_rec IN c_attrs LOOP
      if (p_parameter1 = c_rec.session_value) then
          l_scheduled := 'Y';
	  GOTO skip_this;
      end if;
      if (p_parameter2 = c_rec.session_value) then
          l_scheduled := 'Y';
	  GOTO skip_this;
      end if;
      if (p_parameter3 = c_rec.session_value) then
          l_scheduled := 'Y';
	  GOTO skip_this;
      end if;
      if (p_parameter4 = c_rec.session_value) then
          l_scheduled := 'Y';
	  GOTO skip_this;
      end if;
      if (p_parameter5 = c_rec.session_value) then
          l_scheduled := 'Y';
	  GOTO skip_this;
      end if;
      if (p_parameter6 = c_rec.session_value) then
          l_scheduled := 'Y';
	  GOTO skip_this;
      end if;
      if (p_parameter7 = c_rec.session_value) then
          l_scheduled := 'Y';
	  GOTO skip_this;
      end if;
      if (p_parameter8 = c_rec.session_value) then
          l_scheduled := 'Y';
	  GOTO skip_this;
      end if;
      if (p_parameter9 = c_rec.session_value) then
          l_scheduled:= 'Y';
	  GOTO skip_this;
      end if;
      if (p_parameter10 = c_rec.session_value) then
          l_scheduled := 'Y';
	  GOTO skip_this;
      end if;
      if (p_parameter11 = c_rec.session_value) then
          l_scheduled := 'Y';
	  GOTO skip_this;
      end if;
      if (p_parameter12 = c_rec.session_value) then
          l_scheduled := 'Y';
	  GOTO skip_this;
      end if;
      if (p_parameter13 = c_rec.session_value) then
          l_scheduled := 'Y';
	  GOTO skip_this;
      end if;
      if (p_parameter14 = c_rec.session_value) then
          l_scheduled := 'Y';
	  GOTO skip_this;
      end if;
      if (p_parameter15 = c_rec.session_value) then
          l_scheduled := 'Y';
	  GOTO skip_this;
      end if;
      if (p_timetoparameter = c_rec.session_value) then
          l_scheduled := 'Y';
	  GOTO skip_this;
      end if;
      if (p_timefromparameter = c_rec.session_value) then
          l_scheduled := 'Y';
	  GOTO skip_this;
      end if;
      l_scheduled := 'N';
      <<skip_this>>
      NULL;
   END LOOP;
   x_scheduled := l_scheduled;
END
;
PROCEDURE SAVE_COMPONENT
(p_file_id			IN	NUMBER
,p_Request_type			IN	VARCHAR2
)
IS
  l_html_pieces                 utl_http.html_pieces;
  l_url				varchar2(32000);
  m				number;
  n				number;
  o				number;
  k				number;
  j				varchar2(32000);
  j_front			varchar2(32000);
  j_trail			varchar2(32000);
  k_trail			number := 0;
  l				varchar2(32000);
  i				number := 0;
  l_Apps_web_agent              varchar2(32000);
  l_Ampersand			varchar2(1) := '?';
BEGIN
   /*l_apps_web_Agent := FND_WEB_CONFIG.TRAIL_SLASH(fnd_profile.value('APPS_WEB_AGENT'));
   l_url :=l_apps_web_Agent||'BIS_SAVE_REPORT.retrieve'||l_ampersand||'file_id='||p_file_id;
   l_html_pieces := utl_http.request_pieces(url => l_url,
					   max_pieces => 32000);
   if (p_request_type = 'G') then
   for m in l_html_pieces.first..l_html_pieces.last loop
       n := instr(l_html_pieces(m),'"OA_HTML/BisChart.jsp'||l_ampersand||'index=1');
       if (n > 0) then
          k := n;
          o := m;
          exit;
       end if;
   end loop;
   j := substr(l_html_pieces(0),k+10,k+2000);
   j_front := j;
   i := instr(j,'"></TD>');
   if (i >0) then
      l := substr(j,1,i-1);
   else
      j_trail := substr(l_html_pieces(0+1),1,2000);
      k_trail := instr(j_trail, '"></TD>');
     if (k_trail >0) then
        l:=substr(j_trail,1,k_trail-1);
        l := j_front||l;
     end if;
   end if;
   BIS_SAVE_REPORT.INITWRITE(p_File_id, l);
  end if;
  */
  null;
END;

PROCEDURE UPDATE_LAST_UPDATE
(p_schedule_id                 IN       NUMBER
,x_return_Status               OUT      NOCOPY VARCHAR2
,x_msg_Data                    OUT      NOCOPY VARCHAR2
,x_msg_count                   OUT      NOCOPY NUMBER
)
IS
BEGIN
   -- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
   UPDATE bis_schedule_preferences
   SET last_update_date = SYSDATE
   WHERE schedule_id = p_schedule_id;

COMMIT;
EXCEPTION
WHEN OTHERS THEN
     NULL; -- Add proper error handling
END;

-- mdamle 07/03/2001 - Scheduling Enhancements
-- Returns Advanced / Basic user
FUNCTION getUserType return varchar2
IS
userType varchar2(1) default 'B';
BEGIN

	userType := fnd_profile.value('PMV_USER_TYPE');

	if userType is null or userType = '' then
		userType := 'B';
	end if;

	return userType;

END getUserType;


-- mdamle 08/20/2001 - Add users to a role
procedure addUserToRole(
		 pUserId  	IN number
		,pRole		IN varchar2) is

vUserName			varchar2(100);
vUserExists			number default 0;
begin

	begin
		select user_name
		into vUserName
		from fnd_user
		where user_id = pUserId;
	end;

	-- Check if user is not already part of the role
	select count(1)
	into vUserExists
      	from WF_LOCAL_USER_ROLES ur, fnd_user u
	where u.user_id = pUserId
	and ur.user_name = u.user_name
	and role_name = pRole;

	if vUserExists = 0 then
		wf_directory.adduserstoadhocrole(pRole, vUserName);
	end if;

end addUserToRole;

-- 07/03/01 mdamle - Scheduling Enhancements
FUNCTION getDefaultSchedule
(pRegionCode			IN 	VARCHAR2
,pViewBy			IN 	VARCHAR2 default NULL
) return varchar2
IS
vSchedule	VARCHAR2(20)  default '';
BEGIN

	-- Get default schedule based on dimension level in view by
	if pViewBy is not null then
		begin
			select nvl(attribute8, '')
			into vSchedule
			from ak_region_items
			where region_code = pRegionCode
			and attribute2 = pViewBy;
		exception
			when others then vSchedule := '';
		end;
	end if;

	-- If dimension level schedule has not been set up, look for report
	-- level schedule

	if vSchedule = '' or vSchedule is null then
		begin
			select nvl(attribute3, '')
			into vSchedule
			from ak_regions
			where region_code = pRegionCode;
		exception
			when others then vSchedule := '';
		end;
	end if;

	return vSchedule;

END getDefaultSchedule;

-- 07/03/01 mdamle - Scheduling Enhancements
PROCEDURE showDefaultSchedulePage
(pRegionCode			IN 	VARCHAR2
,pFunctionName			IN 	VARCHAR2
,pResponsibilityId		IN	VARCHAR2
,pApplicationId			IN	VARCHAR2
,pSessionId			IN	VARCHAR2
,pUserId			IN	VARCHAR2
,pViewBy			IN 	VARCHAR2
,pReportTitle			IN	VARCHAR2 default NULL
,pRequestType			IN	VARCHAR2 default NULL
,pPlugId			IN	VARCHAR2 default NULL
,pParmPrint			IN	VARCHAR2 default NULL
,pGraphType			IN	VARCHAR2 default NULL
) IS
lPageFunctionId 		NUMBER;
lSessionId                      NUMBER;
lRespId                         VARCHAR2(80);
lApplicationId                  VARCHAR2(80);
lParams                         VARCHAR2(2000);
lsecurityGroupId                NUMBER;
lWebHtmlCall                    fnd_form_functions.web_html_call%TYPE;
BEGIN
  getSchedulePageDetails(
    pRegionCode	      =>   pRegionCode
    ,pFunctionName     =>   pFunctionName
    ,pResponsibilityId =>   pResponsibilityId
    ,pApplicationId    =>   pApplicationId
    ,pSessionId	      =>   pSessionId
    ,pUserId	      =>   pUserId
    ,pViewBy	      =>   pViewBy
    ,pReportTitle      =>   pReportTitle
    ,pRequestType      =>   pRequestType
    ,pPlugId	      =>   pPlugId
    ,pParmPrint	      =>   pParmPrint
    ,pGraphType	      =>   pGraphType
    ,xPageFunctionId   =>   lPageFunctionId
    ,xSessionId        =>   lSessionId
    ,xRespId           =>   lRespId
    ,xApplicationId    =>   lApplicationId
    ,xParams           =>   lParams
    ,xsecurityGroupId  =>   lsecurityGroupId
    ,xWebHtmlCall      =>   lWebHtmlCall
  );

  IF lPageFunctionId IS NOT NULL THEN
    OracleApps.runFunction(c_function_id => lPageFunctionId
                        ,n_session_id => lSessionId
                        ,c_parameters => lParams
                        ,p_resp_appl_id => lApplicationId
                        ,p_responsibility_id => lRespId
                        ,p_Security_group_id => lsecurityGroupId
                        );
  END IF;

END showDefaultSchedulePage;


-- 07/03/01 mdamle - Scheduling Enhancements
PROCEDURE getSchedulePageDetails
(pRegionCode			IN 	VARCHAR2
,pFunctionName			IN 	VARCHAR2
,pResponsibilityId		IN	VARCHAR2
,pApplicationId			IN	VARCHAR2
,pSessionId			IN	VARCHAR2
,pUserId			IN	VARCHAR2
,pViewBy			IN 	VARCHAR2
,pReportTitle			IN	VARCHAR2 default NULL
,pRequestType			IN	VARCHAR2 default NULL
,pPlugId			IN	VARCHAR2 default NULL
,pParmPrint			IN	VARCHAR2 default NULL
,pGraphType			IN	VARCHAR2 default NULL
,xPageFunctionId 		OUT     NOCOPY NUMBER
,xSessionId                     OUT     NOCOPY NUMBER
,xRespId                        OUT     NOCOPY VARCHAR2
,xApplicationId                 OUT     NOCOPY VARCHAR2
,xParams                        OUT     NOCOPY VARCHAR2
,xsecurityGroupId               OUT     NOCOPY NUMBER
,xWebHtmlCall                   OUT     NOCOPY VARCHAR2
)
IS
vSchedule			varchar2(30);
vReportName   			varchar2(240);
vPageURL			varchar2(5000);
vPageFunctionId 		number;
vShowAdvancedPage		boolean default false;
vDupScheduleId			number;
vParameters			varchar2(5000) default '';
vNextRun			varchar2(30) default '';
vLastRun			varchar2(30) default '';
vSubscribedSchedule		number;
vUserExists			number default 0;

vRespId                         varchar2(80);
vApplicationId                  varchar2(80);
vParams                         varchar2(2000);
vRequestType                    VARCHAR2(100);
lWebHtmlCall                    fnd_form_functions.web_html_call%TYPE;

CURSOR cFndResp (pRespId in varchar2) is
select application_id
from fnd_responsibility
where responsibility_id=pRespId;

BEGIN

  vRespId := pResponsibilityId ;
  vRequestType := nvl(pRequestType, 'T');
  if (vRequestType = 'null') then
   vRequestType := 'T';
  end if;

  if pApplicationId is null then
     if cFNDResp%ISOPEN then
        CLOSE cFNDResp;
     end if;
     OPEN cFNDResp(vRespId);
     FETCH cFNDResp INTO vApplicationId;
     CLOSE cFNDResp;
  else
     vApplicationId := pApplicationId;
  end if;

	-- mdamle 07/30/01 - Use the default only if Report Title is blank
	if pReportTitle is null or pReportTitle = '' then
		vReportName := BIS_REPORT_UTIL_PVT.Get_Report_Title(pFunctionName);
	else
		vReportName := pReportTitle;
	end if;

	vSchedule := getDefaultSchedule(pRegionCode, pViewBy);

	-- mdamle 08/20/2001 - Unsubscribe from Schedule Page
	vParameters := getParameterString(pFunctionName, pUserId, pSessionId);
	vDupScheduleId := getDuplicateSchedule(pFunctionName, vParameters, vSchedule, pPlugId);

	if vDupScheduleId is not null then
		-- Check if user has already subscribed to this report
 		-- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
		select count(1)
		into vUserExists
		from bis_schedule_preferences
		where schedule_id = vDupScheduleId
		and user_id = pUserId
		and nvl(plug_id, 0) = nvl(pPlugId, 0);

		if vUserExists > 0 then
			vSubscribedSchedule := vDupScheduleId;
		end if;

	end if;

	if getUserType = 'B' then

		-- SHOW BASIC USER PAGE

		if vSchedule = '' or vSchedule is null then
			-- If Schedule has not been setup, then let the user apply own options
			vShowAdvancedPage := true;
		else

			-- Schedule has been setup
        		begin
        			select function_id,web_html_call
        			into vPageFunctionId,lWebHtmlCall
        			from fnd_form_functions
        			where function_name = 'BIS_BU_SCHEDULE_PAGE';
        		exception
				when others then vPageFunctionId := null;
        		end;
        	end if;
        end if;

        if ((getUserType = 'A') or (vShowAdvancedPage = true)) then

		-- SHOW ADVANCED USER PAGE

	       	begin
        		select function_id,web_html_call
        		into vPageFunctionId,lWebHtmlCall
        		from fnd_form_functions
        		where function_name = 'BIS_AU_SCHEDULE_PAGE';
        	exception
			when others then vPageFunctionId := null;
        	end;
	end if;

      	if vPageFunctionId is not null then

		if vSchedule = '' or vSchedule is null then
			-- If Schedule has not been setup for this report
                        -- made into local call for  bug 5031067
                        select function_id, web_html_call
			into vPageFunctionId, lWebHtmlCall
			from fnd_form_functions
			where function_name = 'BIS_SCHEDULE_PAGE';
                        vParams := 'regionCode='|| pRegionCode
                                 ||'&functionName='||pFunctionName
                                 ||'&parmPrint='||bis_pmv_util.encode(pParmPrint)
                                 ||'&requestType='||pRequestType
                                 ||'&plugId='||pPlugId
                                 ||'&reportTitle='||bis_pmv_util.encode(pReportTitle)
                                 ||'&graphType='||pGraphType
			         ||'&sessionId='||pSessionId
			         ||'&userId='||pUserId
			         ||'&respId='||vRespId
                                 ||'&appId='||vApplicationId;

                        xPageFunctionId  :=  vPageFunctionId;
                        xSessionId       :=  pSessionId;
                        xRespId          :=  pResponsibilityId;
                        xApplicationId   :=  pApplicationId;
                        xParams          :=  vParams;
                        xsecurityGroupId :=  icx_sec.g_security_group_id;
                        xWebHtmlCall     :=  lWebHtmlCall;

		else

			-- If a schedule has been setup, get the last run date, and next run date
			if vDupScheduleId is not null then
 				-- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
				-- Fixed the SQL
				-- Get the last run date from the last completed request
				select to_char(max(requested_start_date), 'Mon DD, YYYY  HH:MI AM')
				into vLastRun
				from fnd_concurrent_requests
				where phase_code = 'C'
				start with request_id = (select s.concurrent_request_id from bis_scheduler s where schedule_id = vDupScheduleId)
				connect by prior request_id = parent_request_id;

				-- Get the next run date from the next pending request
				select to_char(requested_start_date, 'Mon DD, YYYY  HH:MI AM')
				into vNextRun
				from fnd_concurrent_requests
				where phase_code IN ('P', 'R')
				start with request_id = (select s.concurrent_request_id from bis_scheduler s where schedule_id = vDupScheduleId)
				connect by prior request_id = parent_request_id;

			end if;
			-- rcmuthuk  Bug Fix:2799113. Moved parmPrint param to last.
			-- ksadagop  Bug Fix:3182441. Encoded header and reportTitle
			vParams := 'header='||bis_pmv_util.encode(vReportName)||
			           '&schedule='||vSchedule||
			           '&regionCode='||pRegionCode||
			           '&functionName='||pFunctionName||
			           '&sessionId='||pSessionId||
			           '&userId='||pUserId||
			           '&respId='||vRespId||
                                   '&appId='||vApplicationId||
			           '&reportTitle='||bis_pmv_util.encode(vReportName)||
			           '&requestType='||vRequestType||
			           '&plugId='||pPlugId||
			           '&nextRun='||vNextRun||
			           '&lastRun='||vLastRun||
			           '&subscribedSchedule='||vSubscribedSchedule||
			           '&graphType='||pGraphType||
			           '&parmPrint='||pParmPrint;

			xPageFunctionId  :=  vPageFunctionId;
			xSessionId       :=  pSessionId;
 			xRespId          :=  vRespId;
 			xApplicationId   :=  vApplicationId;
 			xParams          :=  vParams;
 			xsecurityGroupId :=  icx_sec.g_security_group_id;
                 	xWebHtmlCall     :=  lWebHtmlCall;
        	end if;
	end if;

END getSchedulePageDetails;


-- mdamle 07/03/01 - Scheduling Enhancements
FUNCTION getDuplicateSchedule
(pFunctionName			IN	VARCHAR2
,pParameters			IN	VARCHAR2
,pSchedule			IN	VARCHAR2
,pPlugId			IN	VARCHAR2 default NULL
) return number
IS

vScheduleId		number;
BEGIN

	-- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
	/*
	if pPlugId is not null then
		-- Check by plug_id as well
		-- Will not be able to subscribe to a request of a different plug
		-- mdamle 08/20/2001 - Fixed SQL
		begin
			select max(schedule_id)
			into vScheduleId
			from bis_scheduler s, fnd_concurrent_requests cr, fnd_conc_release_classes rc
			where s.function_name = pFunctionName
			and s.parameter_string = pParameters
			and s.concurrent_request_id = cr.request_id
			and cr.release_class_id = rc.release_class_id
			and s.plug_id = pPlugId
			and (rc.date2 is null or rc.date2 > sysdate)
			and 0 <	(select count(*)
				from fnd_concurrent_requests
				where phase_code = 'P'
				start with request_id = cr.request_id
				connect by prior request_id = parent_request_id);

		exception
			when others then vScheduleId := null;
		end;

	else
		-- Check for :
		--		same function name
		--		same parameters
		--		same schedule
		-- 		end date/time of the schedule is > today's date/time
		-- 		there exists a pending request for this schedule
		-- mdamle 08/20/2001 - Fixed SQL
		begin
			select max(schedule_id)
			into vScheduleId
			from bis_scheduler s, fnd_concurrent_requests cr, fnd_conc_release_classes rc
			where s.function_name = pFunctionName
			and s.parameter_string = pParameters
			and s.concurrent_request_id = cr.request_id
			and cr.release_class_id = rc.release_class_id
			and (rc.date2 is null or rc.date2 > sysdate)
			and 0 <	(select count(*)
				from fnd_concurrent_requests
				where phase_code = 'P'
				start with request_id = cr.request_id
				connect by prior request_id = parent_request_id);
		exception
			when others then vScheduleId := null;
		end;
	end if;
	*/

	begin
		select max(schedule_id)
		into vScheduleId
		from bis_scheduler s, fnd_concurrent_requests cr, fnd_conc_release_classes rc
		where s.function_name = pFunctionName
		-- mdamle 09/21/01 - Fixed Bug#1999262 - Added nvl
		and nvl(s.parameter_string, ' ') = nvl(pParameters, ' ')
		and s.concurrent_request_id = cr.request_id
		and cr.release_class_id = rc.release_class_id
		and (rc.date2 is null or rc.date2 > sysdate)
		and 0 <	(select count(*)
			from fnd_concurrent_requests
			where phase_code IN ('P', 'R')
			start with request_id = cr.request_id
			connect by prior request_id = parent_request_id);
	exception
		when others then vScheduleId := null;
	end;


	return vScheduleId;

END getDuplicateSchedule;

PROCEDURE subscribeToReport
(pRegionCode			IN	VARCHAR2
,pFunctionName			IN	VARCHAR2
,pResponsibilityId		IN	VARCHAR2
,pApplicationId			IN	VARCHAR2
,pSessionId			IN	VARCHAR2
,pUserId			IN	VARCHAR2
,pSchedule			IN	VARCHAR2
,pRequestType			IN	VARCHAR2
,pReportTitle			IN	VARCHAR2
,pPlugId			IN	VARCHAR2 default NULL
-- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
,pGraphType			IN	VARCHAR2
)
IS
vScheduleId			number;
vReturnStatus			varchar2(100);
vMsgData			varchar2(240);
vMsgCount			number;
vAppsShortName 			varchar2(3) := 'BIS';
vProgramName 			varchar2(25) := 'BIS_REPORT_SCHEDULER';
vProgramDesc 			varchar2(30) := 'Report Generator Scheduler';
vRoleName			varchar2(30);
vReportName   			varchar2(240);
vPageURL			varchar2(5000);
vPageFunctionId 		number;
vResult				boolean;
vRequestId			number;
vParameters			varchar2(5000) default '';
vUserExists			number default 0;
vValidSchedule			number;
-- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
vFileId				number;
vRoleDisplayName		varchar2(30);

vParams                         varchar2(2000);
vRespId                         varchar2(80);
vApplicationId                  varchar2(80);

CURSOR cFndResp (pRespId in varchar2) is
select application_id
from fnd_responsibility
where responsibility_id=pRespId;

BEGIN

    	if not icx_sec.ValidateSession then
      		return;
    	end if;

  vRespId := nvl(pResponsibilityId, icx_sec.getid(ICX_SEC.PV_RESPONSIBILITY_ID));
  if pApplicationId is null then
     if cFNDResp%ISOPEN then
        CLOSE cFNDResp;
     end if;
     OPEN cFNDResp(vRespId);
     FETCH cFNDResp INTO vApplicationId;
     CLOSE cFNDResp;
  else
     vApplicationId := pApplicationId;
  end if;

	-- mdamle 07/30/01 - Use the default only if Report Title is blank
	if pReportTitle = '' or pReportTitle is null then
		vReportName := BIS_REPORT_UTIL_PVT.Get_Report_Title(pFunctionName);
	else
		vReportName := pReportTitle;
	end if;

	--  mdamle 08/01/01 - Check for expired default schedule Bug# 1925970
	vValidSchedule := 0;
	begin
		select count(*)
		into vValidSchedule
		from fnd_conc_release_classes rc
		where rc.release_class_name = pSchedule
		and (rc.date2 is null or rc.date2 > sysdate);
	end;

	if vValidSchedule = 0 then
		-- default Schedule has expired
		-- Show Error Page
		begin
        		select function_id into vPageFunctionId
        		from fnd_form_functions
        		where function_name = 'BIS_INFORMATION_PAGE';
        	exception
			when others then vPageFunctionId := null;
        	end;

       		if vPageFunctionId is not null then
/*
    			vPageURL := 'OracleApps.RF?F='||icx_call.encrypt2(''||'*'||pResponsibilityId||'*'||icx_sec.g_security_group_id||'*'||vPageFunctionId||'**]',
                                                               pSessionId)
                                              ||'&P='||icx_call.encrypt2('header='||bis_pmv_util.encode(vReportName)||
								 	 '&mainMessage=BIS_SCHED_EXPIRED_ERR'||
									 '&detailMessage=BIS_SCHED_EXPIRED_ERR_DETAIL');

                	owa_util.redirect_url(vPageURL);
*/

  vParams := 'header='||vReportName||
             '&mainMessage=BIS_SCHED_EXPIRED_ERR'||
             '&detailMessage=BIS_SCHED_EXPIRED_ERR_DETAIL';

  OracleApps.runFunction(c_function_id => vPageFunctionId
                        ,n_session_id => pSessionId
                        ,c_parameters => vParams
                        ,p_resp_appl_id => vApplicationId
                        ,p_responsibility_id => vRespId
                        ,p_Security_group_id => icx_sec.g_security_group_id
                        );

        	end if;

	else

		-- Get Parameter String
		vParameters := getParameterString(pFunctionName, pUserId, pSessionId);

		-- Check if duplicate schedule exists
		vScheduleId := getDuplicateSchedule(pFunctionName, vParameters, pSchedule, pPlugId);
		if vScheduleId is not null then
			-- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
			-- Create a new record in bis_schedule_preferences
			-- Check if another subscriber has the same preferences, if so, then reuse FileId

			begin
				select file_id
				into vFileId
				from bis_schedule_preferences
				where schedule_id  = vScheduleId
				and nvl(title, ' ') = nvl(vReportName, ' ')
				and request_type = pRequestType
				and nvl(graph_type, ' ') = nvl(pGraphType, ' ');
			exception
				when no_data_found then vFileId := null;
			end;

			if vFileId is null then
				vFileId := get_File_Id(pRequestType);

				-- mdamle 09/19/01 - Trap File_ID creation error
				if vFileId is null or vFileId = 0 then
					fndLobsError(vRespId, pSessionId, vReportName);
				else
					vRoleName := gvRoleName||vFileId;
					vRoleDisplayName := fnd_message.get_string('BIS', 'BIS_REPORT_SUBSCRIBERS') || ' - ' || vFileId;
					wf_directory.createadhocrole(vRoleName, vRoleDisplayName) ;
				end if;
			else
				vRoleName := gvRoleName||vFileId;
			end if;

			-- mdamle 09/19/01 - Trap File_ID creation error
			if vFileId is not null and vFileId > 0 then
			        -- jprabhud 09/24/02 - Enh. 2470068 DB Graph HTML - Reusing file Ids to store graphs - passed in function name
	  		  	create_schedule_preferences(vScheduleId, pUserId, pPlugId, vReportName, pGraphType, pRequestType, vFileId, pFunctionName);
            commit;
			end if;

		else

			-- Create a new schedule
			-- mdamle 09/13/01 - Fixed Bug#1994876 - Corrected Parameter order
			bis_rg_schedules_pvt.create_schedule
						(pPlugId
						,pUserId
						,pFunctionName
						,vRespId
						,vReportName
						,pGraphType
						-- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
						,null
						,vFileId
						,pSessionId
						,pRegionCode
						,pRequestType
						,vScheduleId
						,vReturnStatus
						,vMsgData
						,vMsgCount
						--jprabhud - 12/20/02 - NLS Bug 2320171 Graph Fonts and Mutli-Byte characters
						,'N',null);

			-- mdamle 09/19/01 - Trap File_ID creation error
			if vFileId is null or vFileId = 0 then
				fndLobsError(vRespId, pSessionId, vReportName);
			else
				-- Submit a new request
/*
				if pApplicationId is null then
					select application_id
					into vApplicationId
					from fnd_responsibility
					where responsibility_id = pResponsibilityId;
				else
					vApplicationId := pApplicationId;
				end if;
*/

				-- mdamle 07/26/01 - Initialize Apps session for CM operation
				fnd_global.APPS_INITIALIZE(TO_NUMBER(pUserId),TO_NUMBER(vRespId),TO_NUMBER(vApplicationId));


				vResult := fnd_request.set_rel_class_options(application=>'FND', class_name=>pSchedule);

				vRequestId := fnd_request.submit_request
					(application=>vAppsShortName
					,program=>vProgramName
					,description=>vProgramDesc
					,argument1=>vScheduleId
					,argument2=>pRegionCode
					,argument3=>pFunctionName
					,argument4=>pRequestType
					,argument5=>pUserId
					,argument6=>'JSP');

				-- Update the Schedule
				if vRequestId > 0 then
					update_schedule( vScheduleId
					,vRequestId
					,vReturnStatus
					,vMsgData
					,vMsgCount
					,vParameters);

				end if;

				-- Create a new role for this schedule
				-- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
				vRoleName := gvRoleName||vFileId;
				vRoleDisplayName := fnd_message.get_string('BIS', 'BIS_REPORT_SUBSCRIBERS') || ' - ' || vFileId;
				wf_directory.createadhocrole(vRoleName, vRoleDisplayName) ;

			end if;
		end if;

		if vFileId is not null and vFileId > 0 then
			if pPlugId is null then
				-- Add users to Role
				addUserToRole(pUserId, vRoleName);

				-- Show Confirmation Page
				begin
        				select function_id into vPageFunctionId
	        			from fnd_form_functions
        				where function_name = 'BIS_CONFIRMATION_PAGE';
		        	exception
					when others then vPageFunctionId := null;
	        		end;

       				if vPageFunctionId is not null then
/*
    					vPageURL := 'OracleApps.RF?F='||icx_call.encrypt2(pApplicationId||'*'||pResponsibilityId||'*'||icx_sec.g_security_group_id||'*'||vPageFunctionId||'**]',
                                                              pSessionId)
	                                             ||'&P='||icx_call.encrypt2('header='||bis_pmv_util.encode(vReportName)||
							 	 '&mainMessage=BIS_SUBSCRIBE_CONF'||
								 '&detailMessage=BIS_SUBSCRIBE_CONF_DETAIL');
		                		owa_util.redirect_url(vPageURL);
*/
  -- rcmuthuk   Bug Fix:2807197 added regCode, functName params
  vParams := 'header='||vReportName||
             '&mainMessage=BIS_SUBSCRIBE_CONF'||
             '&detailMessage=BIS_SUBSCRIBE_CONF_DETAIL'||
		 '&regionCode='||pRegionCode||
		 '&functionName='||pFunctionName;


  OracleApps.runFunction(c_function_id => vPageFunctionId
                        ,n_session_id => pSessionId
                        ,c_parameters => vParams
                        ,p_resp_appl_id => vApplicationId
                        ,p_responsibility_id => vRespId
                        ,p_Security_group_id => icx_sec.g_security_group_id
                        );

		        	end if;
			else
				-- If coming from Portal, go to Home Page
				vPageURL := FND_WEB_CONFIG.TRAIL_SLASH(fnd_profile.value('ICX_REPORT_LINK')) || 'oraclemyPage.home';
       			       	owa_util.redirect_url(vPageURL);
			end if;
		end if;
	end if;

END subscribeToReport;

function getParameterString
(pFunctionName 				IN	VARCHAR2
,pUserId				IN	VARCHAR2
,pSessionId				IN	VARCHAR2
) return varchar2
IS

vParameters			varchar2(5000) default '';
vSessionValue			varchar2(160);


cursor cParameterValues (cpFunctionName varchar2, cpSessionId varchar2, cpUserId varchar2) is
	select session_value
	from bis_user_attributes
	where session_id = cpSessionId
	and user_id = cpUserId
	and function_name  = cpFunctionName
	and schedule_id is null
	order by attribute_name;


BEGIN

      	open cParameterValues(pFunctionName, pSessionId, pUserId);
       	loop
       		fetch cParameterValues into vSessionValue;
       	  	exit when cParameterValues%NOTFOUND;
		if vParameters = '' then
	  		vParameters := vParameters || vSessionValue;
		else
	  		vParameters := vParameters || '+' || vSessionValue;
		end if;
	end loop;

	return vParameters;

END getParameterString;


PROCEDURE unSubscribeFromReport
(pScheduleID 			IN 		number
,pPlugId			IN		number  default NULL
) IS

vRoleName			varchar2(30);
vUserName			varchar2(100);
vUserId				number;
vPageURL			varchar2(5000);
vPageFunctionId 		number;
vReportName   			varchar2(240) default '';
vUserExists			number;
vCount				number := 0;

cursor cUserFiles (cpScheduleId number, cpPlugId number) is
	select distinct file_id
	from bis_schedule_preferences
	where schedule_id = cpScheduleId
	and user_id = vUserId
	and nvl(plug_id, 0) = nvl(cpPlugID, 0);

-- jprabhud 09/24/02 - Enh 2470068 Storing of Graphs to FND_LOBS
vGraphFileId varchar2(20);
vAttrName varchar2(20);
vFunctionName fnd_form_functions.function_name%TYPE;

vParams varchar2(2000);
vRespId                         varchar2(80);
vApplicationId                  varchar2(80);

CURSOR cFndResp (pRespId in varchar2) is
select application_id
from fnd_responsibility
where responsibility_id=pRespId;

BEGIN

   	if not icx_sec.ValidateSession then
   		return;
    	end if;

     vRespId := icx_sec.getid(ICX_SEC.PV_RESPONSIBILITY_ID);
     if cFNDResp%ISOPEN then
        CLOSE cFNDResp;
     end if;
     OPEN cFNDResp(vRespId);
     FETCH cFNDResp INTO vApplicationId;
     CLOSE cFNDResp;

   	vUserId := icx_sec.getID(icx_sec.PV_WEB_USER_ID);

	begin
		select user_name
		into vUserName
		from fnd_user
		where user_id = vUserId;
	exception
		when others then vUserName := null;
	end;


	for c1 in cUserFiles(pScheduleId, pPlugId) loop
		vRoleName := gvRoleName||c1.file_id;

		if vUserName is not null then
			-- Check if user is part of the role
			select count(1)
			into vUserExists
    			from WF_LOCAL_USER_ROLES
	     		where user_name = vUserName
			and role_name = vRoleName;

			if vUserExists > 0 then
				wf_directory.removeusersfromadhocrole(vRoleName, vUserName);
			end if;

			-- If no more subscribers to this file, then delete this role as well
			select count(1)
			into vUserExists
      			from WF_LOCAL_USER_ROLES
	        	where role_name = vRoleName;

			if vUserExists = 0 then
				delete wf_local_roles
				where name = gvRoleName||c1.file_id;
			end if;
		end if;

		select distinct title
		into vReportName
		from bis_schedule_preferences
		where schedule_id = pScheduleId
		and file_id = c1.file_id;

		delete_schedule_preferences(pScheduleId, vUserId, pPlugId);

	end loop;

	-- mdamle 08/21/2001 - Purge Data
	select count(*) into vCount
	from bis_schedule_preferences
	where schedule_id = pScheduleId;

	if vCount = 0 then

		 -- jprabhud 09/24/02 - Enh 2470068 Storing of Graphs to FND_LOBS
		 select function_name
 	         into vFunctionName
  	         from bis_scheduler
 	         where schedule_id = pScheduleId;

                 BIS_PMV_PARAMETERS_PVT.RETRIEVE_GRAPH_FILEID(vUserId,pScheduleId,'GRAPH_FILE_ID',vFunctionName,vGraphFileId);
                 if vGraphFileId is not null then
                    delete fnd_lobs where file_id = vGraphFileId;
                 else
                    deleteReportGraphsLobs(vUserId,pScheduleId,vFunctionName);
                 end if;

		 delete_schedule(pScheduleId);


	end if;

	-- Show Confirmation Page
	begin
        	select function_id into vPageFunctionId
	       	from fnd_form_functions
        	where function_name = 'BIS_CONFIRMATION_PAGE';
        exception
		when others then vPageFunctionId := null;
        end;

       	if vPageFunctionId is not null then
/*
    		vPageURL := 'OracleApps.RF?F='||icx_call.encrypt2('*'||'*'||icx_sec.g_security_group_id||'*'||vPageFunctionId||'**]',
                                                               icx_sec.getID(icx_sec.PV_SESSION_ID))
                                              ||'&P='||icx_call.encrypt2('header='||bis_pmv_util.encode(vReportName)||
								 	 '&mainMessage=BIS_UNSUBSCRIBE_CONF'||
									 '&detailMessage=BIS_UNSUBSCRIBE_CONF_DETAIL');

                owa_util.redirect_url(vPageURL);
*/

  vParams := 'header='||vReportName||
             '&mainMessage=BIS_UNSUBSCRIBE_CONF'||
             '&detailMessage=BIS_UNSUBSCRIBE_CONF_DETAIL';

  OracleApps.runFunction(c_function_id => vPageFunctionId
                        ,n_session_id => icx_sec.getID(icx_sec.PV_SESSION_ID)
                        ,c_parameters => vParams
                        ,p_resp_appl_id => vApplicationId
                        ,p_responsibility_id => vRespId
                        ,p_Security_group_id => icx_sec.g_security_group_id
                        );

        end if;


END unSubscribeFromReport;

PROCEDURE scheduleFunction
(pRegionCode			IN	VARCHAR2
,pFunctionName			IN	VARCHAR2
,pResponsibilityId		IN	VARCHAR2
,pApplicationId			IN	VARCHAR2
,pSessionId			IN	VARCHAR2
,pUserId			IN	VARCHAR2
,pSchedule			IN	VARCHAR2
,pRequestType			IN	VARCHAR2
,pReportTitle			IN	VARCHAR2
,pMode				IN	VARCHAR2 default 'UPDATE'
,pPlugId			IN	VARCHAR2 default NULL
,pParmPrint			IN	VARCHAR2 default NULL
,pSubscribedSchedule		IN 	VARCHAR2 default NULL
-- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
,pGraphType			IN	VARCHAR2 default NULL
) IS
BEGIN
	if pMode = 'SUBSCRIBE' then
		subscribeToReport
			(pRegionCode
			,pFunctionName
			,pResponsibilityId
			,pApplicationId
			,pSessionId
			,pUserId
			,pSchedule
			,pRequestType
			,pReportTitle
			,pPlugId
			-- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
			,pGraphType
			) ;

	else
		if pMode = 'UN_SUBSCRIBE' then
			unSubscribeFromReport
				(pSubscribedSchedule
				,pPlugId
				);
		else
                        -- ksadagop  Bug Fix:3182441. Encoded header and reportTitle
                        -- made into local call for bug 503106
       			scheduleReports
				(pRegionCode=>pRegionCode
	                         ,pFunctionName=>pFunctionName
        	                 ,pSessionId=>pSessionId
                	         ,pUserId=>pUserId
                        	 ,pResponsibilityId=>pResponsibilityId
		                 ,pReportTitle=>bis_pmv_util.encode(pReportTitle)
                	         ,pApplicationId=>pApplicationId
                        	 ,pParmPrint => pParmPrint
	                         ,pRequestType => pRequestType
        	                 ,pPlugId => pPlugId
				 -- mdamle 09/07/01 - Add Graph Number poplist
				 ,pGraphType=>pGraphType
                	         );

		end if;
	end if;


END scheduleFunction;

--aleung, 8/21/01 -- autoincrement feature
procedure updateIncrementDate(p_concurrent_Request_id       IN       NUMBER) is
begin

   update fnd_concurrent_requests
   set    increment_dates = 'Y'
   where  request_id = p_concurrent_request_id;
   commit;

exception
  when others then null;
end updateIncrementDate;

-- mdamle 09/04/01 Scheduling Enhancements - Phase II - Purge
procedure delete_schedule(
		 pScheduleId		IN 	NUMBER) is

vRequestId		number;

begin


   begin
	-- Step 1 - Get the File_Id and Request_Id from schedule record

	select concurrent_request_id
	into vRequestId
	from bis_scheduler
	where schedule_id = pScheduleId;

	-- Step 2 - Delete from BIS_USER_ATTRIBUTES

	delete bis_user_attributes
	where schedule_id = pScheduleId;

	-- Step 3 - Delete from bis_schedule_preferences

	delete_schedule_preferences(pScheduleId);

	-- Step 4 - Delete from bis_scheduler

	delete bis_scheduler
	where schedule_id = pScheduleId;

	-- Step 5 - Cancel Request
	cancelRequest(vRequestId);


   end;

   commit;

EXCEPTION
	when others then null;
	commit;

end delete_schedule;

-- mdamle 09/04/01 Scheduling Enhancements - Phase II - Purge Portlet Data
procedure delete_portlet(
		 pPlugId	IN 	NUMBER
		,pUserId	IN 	NUMBER
		-- jprabhud 09/24/02 - Enh 2470068 Storing of Graphs to FND_LOBS -- added xGraphFileId
                ,xGraphFileId OUT NOCOPY VARCHAR2) is


vCount 		number;
vScheduleId	number;
-- jprabhud 09/24/02 - Enh 2470068 Storing of Graphs to FND_LOBS
vFunctionName fnd_form_functions.function_name%TYPE;
vRequestType varchar2(1);

begin

    -- Purge Portlet data, whenever portlet is deleted or customized, basically whenever
    -- a new schedule is being created.

    -- jprabhud 09/24/02 - Enh 2470068 Storing of Graphs to FND_LOBS -added vRequestType

    if pPlugId is not null then
    	select distinct schedule_id, request_type
	into vScheduleId, vRequestType
	from bis_schedule_preferences
	where user_id = pUserId
	and plug_id = pPlugId;

	 --jprabhud 09/24/02 - Enh 2470068 Storing of Graphs to FND_LOBS
	if vRequestType = 'G' then
           select function_name
   	   into vFunctionName
    	   from bis_scheduler
   	   where schedule_id = vScheduleId;
           BIS_PMV_PARAMETERS_PVT.RETRIEVE_GRAPH_FILEID(pUserId,vScheduleId,'GRAPH_FILE_ID',vFunctionName,xGraphFileId);
        end if;

	delete_schedule_preferences(vScheduleId, pUserId, pPlugId);

	select count(*) into vCount
	from bis_schedule_preferences
	where schedule_id = vScheduleId;
	if vCount = 0 then
		delete_schedule(vScheduleId);
	end if;
    end if;

EXCEPTION
	when others then null;

end delete_portlet;


-- mdamle 09/04/01 Scheduling Enhancements - Phase II - Purge Portlet Data
-- Deletes old portlet data from old schema
procedure delete_old_portlet(
		 pPlugId	IN 	NUMBER
		,pUserId	IN 	NUMBER
		,pKeepLatest	IN 	BOOLEAN default false) is


cursor cOldPortletSchedules (cpUserId varchar2, cpPlugId number) is
    	select schedule_id
	from bis_scheduler
	where user_id = cpUserId
	and plug_id = cpPlugId
	order by schedule_id desc;


vFirstDone	boolean;

begin

    -- Purge Portlet data, whenever portlet is deleted or customized, basically whenever
    -- a new schedule is being created.

    if pPlugId is not null then

	if pKeepLatest then
		vFirstDone := false;
	else
		vFirstDone := true;
	end if;

    	for c1 in cOldPortletSchedules(pUserId, pPlugId) loop
		if vFirstDone then
			delete_old_schedule(c1.schedule_id);
		end if;
		vFirstDone := true;
	end loop;
    end if;

end delete_old_portlet;

-- mdamle 09/04/01 Scheduling Enhancements - Phase II - Purge
procedure delete_old_schedule(
		 pScheduleId		IN 	NUMBER) is

vRequestId		number;
vFileId			number;

begin


   begin
	-- Step 1 - Get the File_Id and Request_Id from schedule record

	select concurrent_request_id, file_id
	into vRequestId, vFileId
	from bis_scheduler
	where schedule_id = pScheduleId;

	-- Step 2 - Delete all schedule files from FND_LOBS

	delete fnd_lobs
	where file_id = vFileId;

	-- Step 3 - Delete from BIS_USER_ATTRIBUTES

	delete bis_user_attributes
	where schedule_id = pScheduleId;

	-- Step 4 - Delete Role

	delete wf_local_roles
	where name = gvRoleName||pScheduleId;

	-- Step 5 - Cancel Request
	cancelRequest(vRequestId);

	-- Step 6 - Delete from bis_schedule_preferences

	delete_schedule_preferences(pScheduleId);

	-- Step 7 - Delete from bis_scheduler

	delete bis_scheduler
	where schedule_id = pScheduleId;

   end;

   commit;

EXCEPTION
	when others then null;
	commit;

end delete_old_schedule;


-- mdamle 09/04/01 Scheduling Enhancements - Phase II - Purge Portlet Data
procedure delete_Notification_Data is

cursor cNotificationSchedules is
	select schedule_id
	from bis_scheduler s, fnd_concurrent_requests cr
	where s.concurrent_request_id = cr.request_id
	and 0 =	(select count(*)
		from fnd_concurrent_requests
		where phase_code IN ('P', 'R')
		start with request_id = cr.request_id
		connect by prior request_id = parent_request_id)
	and 0 = (select count(*) from bis_schedule_preferences sp
			where sp.schedule_id = s.schedule_id
			and plug_id is not null);

vCount		number;
begin
    	for c1 in cNotificationSchedules loop
		-- Check if the notification is closed
		select count(*)
		into vCount
	  	from wf_notifications w, bis_schedule_preferences sp
		where sp.schedule_id = c1.schedule_id
		and w.recipient_role = gvRoleName||sp.file_id
		and w.status = 'CLOSED';

		if vCount > 0 then
			delete_schedule(c1.schedule_id);
		end if;
	end loop;

	-- When a user unsubscribes from a notification (when email is not sent), without closing the notification,
	-- the file_id is retained in FND_LOBS since the user may wish to view the file again. In this case though,
	-- there is now no record in bis_schedule_preferences since the user has unsubscribed from the schedule.
	-- Check to see if any of notifications are now closed, and delete the file if they are.

	delete fnd_lobs
	where file_id in(
		select substr(recipient_role, Length(gvRoleName)+1)
		from wf_notifications w
		where w.recipient_role like gvRoleName || '%'
		and status = 'CLOSED');


end delete_Notification_Data;

-- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
PROCEDURE create_schedule_preferences(
	 p_schedule_id	IN	NUMBER
	,p_user_id	IN 	VARCHAR2
	,p_plug_id	IN	NUMBER
	,p_title	IN	VARCHAR2
	,p_graph_type	IN	VARCHAR2
	,p_request_type IN	VARCHAR2
	,p_file_id	IN OUT  NOCOPY NUMBER
	-- mdamle 12/12/01 - Changes for Live Portlet
	,p_live_portlet	IN	VARCHAR2 DEFAULT 'N'
	-- jprabhud 09/24/02 - Enh. 2470068 DB Graph HTML - Reusing file Ids to store graphs - added function name
        ,p_function_name IN VARCHAR2 DEFAULT NULL
         --jprabhud - 12/20/02 - NLS Bug 2320171 Graph Fonts and Mutli-Byte characters - passed in p_context_values
        ,p_context_values IN	VARCHAR2 DEFAULT NULL
) is

vExternalSourceId 	number;

--jprabhud 09/24/02 - Enh 2470068 Storing of Graphs to FND_LOBS
vGraphFileId varchar2(20);
vRequestType varchar2(1);

BEGIN
	-- mdamle 01/16/2002 - External Source Id changes
	-- Before delete existing plug id, get the external source id
	-- and then update the new record with this source id


	 --jprabhud 09/24/02 - Enh 2470068 Storing of Graphs to FND_LOBS -- added vRequestType
	begin
		select external_source_id, request_type
		into vExternalSourceId, vRequestType
		from bis_schedule_preferences
		where user_id = p_user_id
		and plug_id = p_plug_id;
	exception
		when others then vExternalSourceId := null;
	end;


  	if p_plug_id is not null then
  	        --jprabhud 09/24/02 - Enh 2470068 Storing of Graphs to FND_LOBS -- added vGraphFileId
		delete_portlet(p_plug_id, p_user_id, vGraphFileId);

 	        --jprabhud 09/24/02 - Enh 2470068 Storing of Graphs to FND_LOBS
                -- save the file id associated with the previous schedule, for the same plug,
                -- for the new schedule id as the previous schedule gets deleted.
                --jprabhud - 12/20/02 - NLS Bug 2320171
                if p_request_type = 'G' and vGraphFileId is not null then
                   BIS_PMV_PARAMETERS_PVT.SAVE_GRAPH_FILEID(p_user_id,p_schedule_id,'GRAPH_FILE_ID',p_function_name,vGraphFileId);
                end if;
  	end if;


        --jprabhud - 12/20/02 - NLS Bug 2320171 Graph Fonts and Mutli-Byte characters
         if p_live_portlet = 'N' and p_context_values is not null then
           --jprabhud - 12/20/02 - NLS Bug 2320171
           if p_request_type ='G' or p_request_type = 'R'  then
              BIS_PMV_PARAMETERS_PVT.SAVE_CONTEXT_VALUES(p_user_id,p_schedule_id,'RENDERING_CONTEXT_VALUES',p_function_name,p_context_values);
           end if;
         end if;



	-- mdamle 12/12/01 - Changes for Live Portlet
	if p_live_portlet = 'Y' then
		p_file_id := null;
	else
		if p_file_id is null or p_file_id = 0 then
			p_file_id := get_file_id(p_request_type);
		end if;
	end if;

	insert into bis_schedule_preferences
	  	(schedule_id
  		,user_id
	  	,plug_id
		,request_type
		,title
	  	,graph_type
  		,file_id
	  	,creation_Date
  		,last_update_date
	  	,created_By
	  	,last_updated_by
  		,last_update_login
		,external_source_id
	  	)
 		values
	  	(p_schedule_id
  		,p_user_id
	  	,p_plug_id
		,p_request_type
	  	,p_title
		-- mdamle 09/07/01 - Add Graph Number poplist
  		,decode(p_request_type, 'G', p_graph_type, null)
	  	,p_file_id
  		,sysdate
	  	,sysdate
  		,0
	  	,0
  		,0
		,vExternalSourceId
	  	);

	--  mdamle 10/25/01 - Update Title in ICX_PORTLET_CUSTOMIZATIONS
	-- In Web Portlets, the title has to be updated in ICX_PORTLET_CUSTOMIZATIONS
	-- since changing the title at runtime is not possible
  --serao - 02/25/02- added so that the title is not updated for rl portlet

	if (p_plug_id is not null and p_title is not null )then
		updateTitleInPortal(p_schedule_id, p_plug_id, p_title);
	end if;


 	--commit;

END create_schedule_preferences;

-- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
PROCEDURE delete_schedule_preferences
(	 pScheduleId	IN 	number
	,pUserId	IN	number default NULL
	,pPlugId	IN	number default NULL
) IS

cursor cUserFiles (cpScheduleId number, cpUserId number, cpPlugId number) is
	select distinct file_id
	from bis_schedule_preferences
	where schedule_id = cpScheduleId
	and user_id = cpUserId
	and nvl(plug_id, 0) = nvl(cpPlugID, 0);

vCount		number;
BEGIN

	if pUserId is not null then

		for c1 in cUserFiles(pScheduleId, pUserId, pPlugId) loop

			select count(*)
			into vCount
			from bis_schedule_preferences sp, wf_notifications w
			where file_id = c1.file_id
			and w.recipient_role = gvRoleName||sp.file_id
			and w.status = 'CLOSED';

			-- If notification still open, then leave it alone.
			if vCount = 1 then
				-- Step 1 - Delete file from FND_LOBS for this preference
				delete fnd_lobs
				where file_id = c1.file_id;

				-- Step 2 - Delete Role
				delete wf_local_roles
				where name = gvRoleName||c1.file_id;
			end if;

			-- Step 3 - Delete the user preference
			delete bis_schedule_preferences
			where schedule_id = pScheduleId
			and user_id = pUserId
			and nvl(plug_id, 0) = nvl(pPlugID, 0);
		end loop;

	else
		-- Step 1 - Delete all schedule files from FND_LOBS

		delete fnd_lobs
		where file_id IN (select file_id from bis_schedule_preferences where schedule_id = pScheduleId);

		-- Step 2 - Delete Role

		delete wf_local_roles
		where name IN (select gvRoleName||file_id from bis_schedule_preferences where schedule_id = pScheduleId);

		-- Step 3 - Delete all preferences for this schedule
		delete bis_schedule_preferences
		where schedule_id = pScheduleId;
	end if;

	commit;

EXCEPTION
	when others then null;
	commit;

END delete_schedule_preferences;

procedure cancelRequest(pRequestId	IN 	NUMBER) IS

vStatusCode 		varchar2(1);
vPhaseCode 		varchar2(1);
vCompletionText 	varchar2(240);
vPendingRequestId	number;

begin
	begin
		select request_id, status_code, phase_code
			into vPendingRequestId, vStatusCode, vPhaseCode
		from fnd_concurrent_requests
		where phase_code <> 'C'
		start with request_id = pRequestId
		connect by prior request_id = parent_request_id;
	exception
		when no_data_found then
			vPendingRequestId := null;
	end;

	if vPendingRequestId is not null then
		if vStatusCode = 'R' then
			vStatusCode := 'T';
		else
			if vStatusCode IN ('W','B') then
				vStatusCode := 'X';
				vPhaseCode := 'C';
			else
				vStatusCode := 'D';
				vPhaseCode := 'C';
			end if;
		end if;

		vCompletionText := fnd_message.get_string('BIS', 'BIS_REQUEST_CANCELED');

		update fnd_concurrent_requests
		set status_code = vStatusCode,
		phase_code = vPhaseCode,
		completion_text = vCompletionText
		where request_id = vPendingRequestId;
	end if;


end cancelRequest;

-- mdamle 09/19/01 - Trap File_ID creation error
procedure fndLobsError(	 pResponsibilityId	IN	number
			,pSessionId		IN	number
			,pReportName		IN	varchar2) is

vPageURL			varchar2(5000);
vPageFunctionId 		number;
vParams                         varchar2(2000);
vRespId                         varchar2(80);
vApplicationId                  varchar2(80);

CURSOR cFndResp (pRespId in varchar2) is
select application_id
from fnd_responsibility
where responsibility_id=pRespId;

begin

     vRespId := nvl(pResponsibilityId, icx_sec.getid(ICX_SEC.PV_RESPONSIBILITY_ID));
     if cFNDResp%ISOPEN then
        CLOSE cFNDResp;
     end if;
     OPEN cFNDResp(vRespId);
     FETCH cFNDResp INTO vApplicationId;
     CLOSE cFNDResp;

     	begin
        	select function_id into vPageFunctionId
        	from fnd_form_functions
        	where function_name = 'BIS_INFORMATION_PAGE';
     	exception
		when others then vPageFunctionId := null;
        end;

      	if vPageFunctionId is not null then
/*
    		vPageURL := 'OracleApps.RF?F='||icx_call.encrypt2(''||'*'||pResponsibilityId||'*'||icx_sec.g_security_group_id||'*'||vPageFunctionId||'**]',pSessionId)
                                              ||'&P='||icx_call.encrypt2('header='||bis_pmv_util.encode(pReportName)||
								 	 '&mainMessage=BIS_SCHEDULE_ERR'||
									 '&detailMessage=BIS_SCHEDULE_ERR_DETAIL');



			-- Show the Default schedule
                	owa_util.redirect_url(vPageURL);
*/

  vParams := 'header='||pReportName||
             '&mainMessage=BIS_SCHEDULE_ERR'||
             '&detailMessage=BIS_SCHEDULE_ERR_DETAIL';

  OracleApps.runFunction(c_function_id => vPageFunctionId
                        ,n_session_id => pSessionId
                        ,c_parameters => vParams
                        ,p_resp_appl_id => vApplicationId
                        ,p_responsibility_id => vRespId
                        ,p_Security_group_id => icx_sec.g_security_group_id
                        );

	end if;

end fndLobsError;


procedure updateTitleInPortal(	p_schedule_id IN NUMBER,
				p_plug_id IN NUMBER,
				p_title IN VARCHAR2) is

vSQL			varchar2(1000);
vPortletPlugExists	number;
vTitle			varchar2(2000);
vRegion			varchar2(240);
vFunctionName		fnd_form_functions.function_name%TYPE;
vType			varchar2(30);

begin

	vSQL := 'select count(*) from icx_portlet_customizations where plug_id = :1';

	begin
        	execute immediate vSQL into vPortletPlugExists using p_Plug_Id;
        Exception
        	when others then
          	vPortletPlugExists := 0;
        end;


	if vPortletPlugExists > 0 then

		begin
			select s.function_name, type
			into vFunctionName, vType
			from bis_scheduler s, fnd_form_functions f
			where schedule_id = p_schedule_id
			and s.function_name = f.function_name;
		exception
			when others then null;
		end;

		vRegion := BIS_PMV_UTIL.getReportRegion(vFunctionName);
		-- mdamle 01/03/2002 - Added plug_id to TL - multiple plugs on a page - will have their respective title link functions
		-- mdamle 09/30/2002 - Use the Fwk implementation for the Title link in Web Portlets.
		if vType <> 'WEBPORTLET' then
  		        -- P1 Bug 3902169 : Do not pass javascript in the title
			-- vTitle := '<A href="javascript:TL'||p_plug_id||'()"><font class=PortletHeaderText>'||p_title||BIS_PMV_UTIL.getAppendTitle(vRegion);
			vTitle := p_title||BIS_PMV_UTIL.getAppendTitle(vRegion);

			--Title limit = 100 in icx_portlet_customizations table
			vTitle := substr(vTitle, 1, 96);

  		        -- P1 Bug 3879391 : Do not pass javascript in the title
			-- vTitle := vTitle || '</a>';

			vSQL := 'update icx_portlet_customizations set title = :1 where plug_id = :2';

			begin
       				execute immediate vSql using vTitle, p_Plug_Id;
       			Exception
        			when others then null;
        		end;
		end if;
	end if;

	commit;

end updateTitleInPortal;

procedure savePortletSettings(	p_schedule_id in varchar2,
				p_request_type in varchar2,
				p_graph_type in varchar2,
				p_title in varchar2,
				p_user_id in varchar2,
				p_plug_id in varchar2)  is

begin

    update bis_schedule_preferences
    set request_type = p_request_type,
    graph_type = decode(p_request_type, 'G', p_graph_type, null),
    title = p_title
    where user_id = p_user_id
    and plug_id = p_plug_id;

    --serao - 02/25/02- added so that the title is not updated for rl portlet
    if (p_plug_id is not null and p_title is not null) then
      updateTitleInPortal(p_schedule_id, p_plug_id, p_title);
    end if;

    commit;

end savePortletSettings;

-- mdamle 01/16/2002
procedure updateExternalSource(	p_schedule_id in varchar2,
				p_file_id  in varchar2,
				p_external_source_id in varchar2) is
begin

	update bis_schedule_preferences
	set external_source_id = p_external_source_id
	where schedule_id = p_schedule_id
	and nvl(p_file_id, 0) = nvl(p_file_id, 0);

commit;

end  updateExternalSource;

procedure expireExistingFile(
         p_schedule_id in varchar2,
         p_file_id  in varchar2,
        o_external_source_id OUT NOCOPY VARCHAR2
) IS
BEGIN

        SELECT external_source_id INTO o_external_source_id
        FROM bis_schedule_preferences
        WHERE schedule_id = p_schedule_id
        AND nvl(file_id, 0) = nvl(p_file_id, 0);

        IF (o_external_source_id IS NOT NULL) THEN
            update fnd_lobs
            SET expiration_date = SYSDATE
            WHERE file_id = o_external_source_id;

            COMMIT;
            --    fnd_gfm.purge_expired;
       END IF;
END expireExistingFile;


--jprabhud 09/24/02 - Enh 2470068 Storing of Graphs to FND_LOBS
procedure deleteReportGraphsLobs(p_user_id in varchar2
                      ,p_schedule_id in varchar2
                      ,p_function_name in varchar2)
IS
BEGIN
   delete fnd_lobs where file_id in
      (select session_value
       from bis_user_attributes
       where user_id = p_user_id
       and schedule_id = p_schedule_id
       and function_name = p_function_name
       and attribute_name in
       ('GRAPH_FILE_ID_1','GRAPH_FILE_ID_2','GRAPH_FILE_ID_3','GRAPH_FILE_ID_4','GRAPH_FILE_ID_5','GRAPH_FILE_ID_6')
       );

    EXCEPTION
    WHEN OTHERS then NULL;

END deleteReportGraphsLobs;


END BIS_RG_SCHEDULES_PVT;

/
