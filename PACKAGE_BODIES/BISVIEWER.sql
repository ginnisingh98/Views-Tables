--------------------------------------------------------
--  DDL for Package Body BISVIEWER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BISVIEWER" as
/* $Header: BISVIEWB.pls 120.6 2006/02/13 02:47:11 nbarik noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
-- dbdrv: checkfile(115.363=120.6):~PROD:~PATH:~FILE
-- create new header and footer in showReport.  08/17/2000 aleung
----------------------------------------------------------------------------
--  PACKAGE:      bisviewer                                               --
--                                                                        --
--  DESCRIPTION:  Report Generate main engine.                            --
--                                                                        --
--  MODIFICATIONS                                                         --
--  Date       User       Modification                                    --
--  XX-XXX-XX  XXXXXXXX   Modifications made, which procedures changed &  --
--  8/17/2000 aleung      intial creation                                 --
--  5/10/2002 nkishore    Added pParameters for showReport                --
--  6/12/2002 mdamle      Disabled calling OA JSP from here               --
-- 10/10/2002 mdamle      Added parameter for pEnableForecastGraph        --
--  4/16/2003 nkishore    Added pRespId to get_notify_rpt_url bug 2833251 --
--  6/27/2003 rcmuthuk    Added p_UserId to get_notify_rpt_url bug 2810397--
--  07-JUN-03 gsanap      Added p_NextExtraViewBy to drilldown bug 3007145--
--  08/21/03  nbarik      Bug Fix 3099831 - delay function access check   --
--  28-JAN-04 nkishore    BugFix 3075441                                  --
--  18-Jan-05 smargand    Enh #4031345 Report XML definition              --
----------------------------------------------------------------------------

  -- declare global variables
  gvImageDirectory varchar2(1000) := BIS_REPORT_UTIL_PVT.get_Images_Server;
  gv_font_name			varchar2(30) := 'Arial';
  gv_font_size			varchar2(5)  := '3';

----------------------------------------------------------------------------------------
--  Procedure:    showReport                                                          --
--                                                                                    --
--  HISTORY                                                                           --
--  Date          Developer  Modifications                                            --
--  05-Nov-2001   aleung     redirect to bisviewm.jsp                                 --
--  08-Mar-2002   nbarik     redirect to OA.jsp                                       --
--  13-Oct-2004   ugodavar   added pMaxResultSetSize & pOutputFormat                  --
----------------------------------------------------------------------------------------
procedure showReport(pRegionCode in varchar2 ,
                     pFunctionName in varchar2 ,
                     pApplicationId in varchar2 default NULL,
                     pSessionId    in varchar2 default NULL,
                     pUserId       in varchar2 default NULL,
                     pResponsibilityId in varchar2 default NULL,
                     pFirstTime   in number default 1,
                     pHideParm    in varchar2 default 'false',
                     pHideGraph   in varchar2 default 'false',
                     pHideTable   in varchar2 default 'false',
                     pHideRinfo   in varchar2 default 'false',
                     pSortInfo    in varchar2 default null,
                     pMode        in varchar2 default 'SHOW',
                     pPreFunctionName in varchar2 default NULL,
                     pScheduleId       in varchar2 default NULL,
                     pRequestType      in varchar2 default 'R',
		     pFileId	       in number default null,
                     pParameterDisplayOnly in varchar2 default 'N',
                     pForceRun             in varchar2 default 'N',
                     pDisplayParameters    in varchar2 default 'Y',
                     pReportSchedule       in varchar2 default 'Y',
	             pCSVFileName in varchar2 default NULL,
                     pPageId in varchar2 default NULL,
               	     pParameters in varchar2 default NULL,
		     -- mdamle 10/10/2002 - Enh# 2460903 - Forecast Graph
               	     pEnableForecastGraph  in varchar2 default NULL,
               	     -- jprabhud - 01/27/03 - Enh 2485974 Custom Views
               	     pCustomView  in varchar2 default NULL,
                     pObjectType IN VARCHAR2 DEFAULT NULL,
                     pautoRefresh IN VARCHAR2 DEFAULT NULL,
		       -- Enh Display Run Button
		     pDispRun IN VARCHAR2 DEFAULT NULL,
             -- nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
             pDrillDefaultParameters IN VARCHAR2 DEFAULT NULL,
             --ugodavar - 10/12/04 - Enh.3946492
             pMaxResultSetSize IN number DEFAULT NULL,
             pOutputFormat IN VARCHAR2 DEFAULT NULL,
                 -- nbarik - 02/08/05 - Enhancement 4120795
                 hideNav IN VARCHAR2 DEFAULT NULL,
                 tab IN VARCHAR2 DEFAULT NULL,
                 displayOnlyParameters IN VARCHAR2 DEFAULT NULL,
                 displayOnlyNoViewByParams IN VARCHAR2 DEFAULT NULL,
                 pBCFromFunctionName IN VARCHAR2 DEFAULT NULL,
                 pPrevBCInfo IN VARCHAR2 DEFAULT NULL,
		 pResetView IN VARCHAR2 DEFAULT NULL
               ) is

    vSessionId          varchar2(80);
    vUserId             varchar2(80);
    vResponsibilityId   varchar2(80);

    jspURL 			varchar2(32767);
    jspParams			varchar2(32767);
    functionid                  NUMBER;
    l_function			VARCHAR2(32000);
    l_application_id 		NUMBER;
    vPageId VARCHAR2(80);

    CURSOR cFndResp (pRespId in varchar2) is
    select application_id
    from fnd_responsibility
    where responsibility_id=pRespId;
    l_render_type varchar2(200) := 'HTML';

    --serao -for grouped parameters
    lParamGrp BIS_PMV_PARAMETERS_PVT.parameter_group_tbl_type;
    lTCTExists boolean := false;

    vURL varchar2(32000);
    l_servlet_agent varchar2(2000);
    l_transaction_id  number;
    lNestedRegionCode varchar2(250);
    lAsofdateExists  boolean;

    -- DIMENSION VALUE EXTENSION - DRILL - Bug 3230530 / Bug 3004363
    lTimeAttribute varchar2(250) ;
    l_DrillDefaultParameters  VARCHAR2(3000);
begin

   /*
   if fnd_profile.value('BIS_SQL_TRACE')= 'Y' then
      dbms_session.set_sql_trace(true);
   end if;
   */
   --nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
   l_DrillDefaultParameters := pDrillDefaultParameters;
   vPageId := pPageId;
   if pScheduleId is null then
      if (not icx_sec.ValidateSession) then
           return;
      end if;
      vSessionId        := icx_sec.getID(icx_sec.PV_SESSION_ID);
      vUserId           := icx_sec.getID(icx_sec.PV_WEB_USER_ID);

     if pResponsibilityId is not null then
         vResponsibilityId := pResponsibilityId;
      else
         vResponsibilityId := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);
      end if;

/* aleung, 8/15/03, bug 3099831 - delay this function access check to bisviewm.jsp
      if not BIS_GRAPH_REGION_HTML_FORMS.hasFunctionAccess(vUserId, pFunctionName) then
                                      displayErrorMessage(BIS_REPORT_UTIL_PVT.Get_Report_Title
                                        (pFunctionName)||BIS_PMV_UTIL.getAppendTitle(pRegionCode),
					'', '', 4, pRegionCode);
	   				return;
      end if;
*/
  else
       vSessionId        := pSessionId;
       vUserId           := pUserId;

       BEGIN
       SELECT responsibility_id INTO vResponsibilityId
       FROM   bis_scheduler
       WHERE  schedule_Id = pScheduleId;
       EXCEPTION
       WHEN OTHERS THEN NULL;
       END;

       vResponsibilityId := pResponsibilityId;
       bis_autoinc_schedule.autoIncrementDates(pRegionCode,
                                             pFunctionName,
                                             vSessionId,
                                             vUserId,
                                             vResponsibilityId,
                                             pScheduleId);
  end if;

  -- nbarik - 06/15/04 - Bug Fix 3687555 - Get it from context
  l_application_id := FND_GLOBAL.RESP_APPL_ID;
  IF (l_application_id IS NULL OR l_application_id = -1) THEN
    OPEN cFNDResp(vResponsibilityId);
    FETCH cFNDResp INTO l_application_id;
    CLOSE cFNDResp;
  END IF;

  -- this is now taken care of by java drill code
  /*
  IF (pMode = 'RELATED') THEN
      -- pass the page id.
      -- serao- 08/23/2002- bug 2514044 - pass respId

      BIS_PMV_PARAMETERS_PVT.getParameterGroupsForRegion( pRegionCode, lParamGrp, lTCTExists, lNestedRegionCode, lAsofdateExists);

    -- DIMENSION VALUE EXTENSION - DRILL - Bug 3230530 / Bug 3004363
      BIS_PMV_DRILL_PVT.copyGroupedParameters(pSessionId          => vSessionId,
                           pUserId             => vUserId,
                           pPreFunctionName    => pPreFunctionName,
                           pFunctionName       => pFunctionName,
                           pRegionCode         => pRegionCode,
                          pPageId         => pPageId,
                          pRespId         => vResponsibilityId,
                          pParameterGroup => lParamGrp,
                          pTCTExists => lTCTExists,
                          pNestedRegionCode => lNestedRegionCode,
                          pAsofDateExists => lAsofdateExists,
			  xTimeAttribute => lTimeAttribute
                        ) ;

      --nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
      BIS_PMV_PARAMETERS_PVT.VALIDATE_SAVE_DRILL_PARAMS(
		  pRegionCode => pRegionCode,
		  pFunctionName => pFunctionName,
		  pParameterGroup => lParamGrp,
		  pPageId => pPageId,
		  pUserId => vUserId,
		  pSessionId => vSessionId,
		  x_DrillDefaultParameters => l_DrillDefaultParameters
      );
      --serao- 08/27/2002- bug 2530913 - do not pass page_id once drilled into a related link
      vPageId := NULL;

  end if;
  */
  BEGIN

  -- mdamle 6/12/2002 - Disabled calling OA JSP from here
  -- PMV will always start from bisviewm.jsp irrespective
  -- of the render type. The OA table will then be
  -- inserted in the JSP at runtime if needed.
/*
  --if fnd_profile.value('PMV_RENDER_TYPE')= 'OAF' then    --Nihar added for OA Rendering
  if BIS_PMV_UTIL.get_Render_type(pRegionCode, vUserId, vResponsibilityId)= 'OAF' then
  -- if (l_render_type = 'OAF') then
             --amkulkar check the generic fun
    select function_id
    into functionid
    from fnd_form_functions
    where function_name = 'BIS_PMV_OA_JSP';
    jspParams := 'akRegionCode=BISREPORTPAGE&akRegionApplicationId=191';
    jspParams := jspParams ||'&reportRegionCode='||BIS_PMV_UTIL.encode(pRegionCode)||'&functionName='||BIS_PMV_UTIL.encode(pFunctionName);
    jspParams := jspParams ||'&forceRun='||pForceRun||'&parameterDisplayOnly='||pParameterDisplayOnly||'&displayParameters='||pDisplayParameters;
    jspParams := jspParams ||'&showSchedule='||pReportSchedule||'&pFirstTime='||pFirstTime||'&pMode='||pMode;
    jspParams := jspParams ||'&scheduleId='||pScheduleId||'&requestType='||pRequestType;
    jspParams := jspParams ||'&fileId='||pFileId ||'&pResponsibilityId='||pResponsibilityId;
    jspParams := jspParams ||'&pUserId='||pUserId||'&pSessionId='||pSessionId;
    jspParams := jspParams ||'&pApplicationId='||pApplicationId||'&pPreFunctionName='||BIS_PMV_UTIL.encode(pPreFunctionNAme);
    jspParams := jspParams ||'&pObjectType='||pObjectType;
    if (vPageId is not null) then
      jspParams := jspParams ||'&_pageid='||vPageId;
    end if;
    if (pParameters is not null) then
      jspParams := jspParams ||'&pParameters='||BIS_PMV_UTIL.encode(pParameters);
    end if;
  else
*/


    select function_id
    into functionid
    from fnd_form_functions
    where function_name = 'BIS_PMV_REPORT_JSP';

    jspParams := 'regionCode='||BIS_PMV_UTIL.encode(pRegionCode)||'&functionName='||BIS_PMV_UTIL.encode(pFunctionName);
    jspParams := jspParams ||'&forceRun='||pForceRun||'&parameterDisplayOnly='||pParameterDisplayOnly||'&displayParameters='||pDisplayParameters;
    jspParams := jspParams ||'&showSchedule='||pReportSchedule||'&pFirstTime='||pFirstTime||'&pMode='||pMode;
    jspParams := jspParams ||'&scheduleId='||pScheduleId||'&requestType='||pRequestType;
    jspParams := jspParams ||'&fileId='||pFileId ||'&pResponsibilityId='||pResponsibilityId;
    jspParams := jspParams ||'&pUserId='||pUserId||'&pSessionId='||vSessionId;
    jspParams := jspParams ||'&pApplicationId='||pApplicationId||'&pPreFunctionName='||BIS_PMV_UTIL.encode(pPreFunctionNAme);

    if (pCSVFileName is not null) then
      jspParams := jspParams ||'&pCSVFileName='||BIS_PMV_UTIL.encode(pCSVFileName);
    end if;
    if (vPageId is not null) then
      jspParams := jspParams ||'&_pageid='||vPageId;
    end if;

    --Bug Fix 2997706
    if (pObjectType is not null) then
      jspParams := jspParams ||'&pObjectType='||pObjectType;
    end if;

    if (displayOnlyParameters is not null) then
       jspParams := jspParams ||'&displayOnlyParameters='||BIS_PMV_UTIL.encode(displayOnlyParameters);
    end if;
    if (displayOnlyNoViewByParams is not null) then
       jspParams := jspParams ||'&displayOnlyNoViewByParams='||BIS_PMV_UTIL.encode(displayOnlyNoViewByParams);
    end if;

    if (pParameters is not null) then
      jspParams := jspParams ||'&pParameters='||BIS_PMV_UTIL.encode(pParameters);--Fix for 2445406
    end if;

    -- mdamle 10/10/2002 - Enh# 2460903 - Forecast Graph
    if (pEnableForecastGraph is not null) then
      jspParams := jspParams ||'&pEnableForecastGraph='||pEnableForecastGraph;
    end if;

    -- jprabhud - 01/27/03 - Enh 2485974 Custom Views
    if (pCustomView is not null) then
      jspParams := jspParams ||'&pCustomView='||BIS_PMV_UTIL.encode(pCustomView);
    end if;
    if (pautorefresh is not null) then
       jspParams := jspParams || '&autoRefresh='||BIS_PMV_UTIL.encode(pautorefresh);
    end if;
    --We need to create an icx transaction. Neal has approved the use of this API.:q
    --l_Transaction_id := icx_sec. createTransaction(p_session_id => vsessionid);

--  end if;


    -- kiprabha - Enh Display Run Button
    if (pDispRun is not null) then
    	jspParams := jspParams || '&pDispRun='||pDispRun;
    end if ;

    IF (l_DrillDefaultParameters IS NOT NULL) THEN
      jspParams := jspParams || '&' || l_DrillDefaultParameters;
    END IF;

    --ugodavar - Enh.3946492
    if(pMaxResultSetSize is not null) then
      jspParams := jspParams ||'&pMaxResultSetSize='||pMaxResultSetSize;
    end if;

    if(pOutputFormat is not null) then
      jspParams := jspParams ||'&pOutputFormat='||pOutputFormat;
    end if;

    -- nbarik - 02/08/05 - Enhancement 4120795
    if(hideNav is not null) then
      jspParams := jspParams ||'&hideNav='||hideNav;
    end if;

    if(tab is not null) then
      jspParams := jspParams ||'&tab='||tab;
    end if;

    if(pBCFromFunctionName is not null) then
      jspParams := jspParams ||'&pBCFromFunctionName='|| pBCFromFunctionName;
    end if;

    if(pPrevBCInfo is not null) then
      jspParams := jspParams ||'&pPrevBCInfo='|| pPrevBCInfo;
    end if;

    if(pResetView is not null) then
      jspParams := jspParams ||'&pResetView='|| pResetView;
    end if;

  EXCEPTION
  WHEN OTHERS THEN NULL;
  END;

  --Invoke the bisviewm.jsp
/*
  l_function := icx_call.encrypt2(l_application_id||'*'||vResponsibilityId||'*'||
				  icx_sec.g_Security_group_id||'*'||functionId||'**]'
			           ,icx_sec.getId(icx_sec.PV_SESSION_ID));
  OracleApps.RF(F=>l_function, P=> icx_call.encrypt2(jspParams,icx_sec.getID(icx_sec.PV_SESSION_ID)));

    l_servlet_agent := FND_WEB_CONFIG.JSP_AGENT;   -- 'http://serv:port/OA_HTML/'
    IF ( l_servlet_agent IS NULL ) THEN   -- 'APPS_SERVLET_AGENT' is null
       l_servlet_agent := FND_WEB_CONFIG.WEB_SERVER || 'OA_HTML/';
    END IF;

    vURL := l_servlet_agent || 'bisviewm.jsp?dbc=' || FND_WEB_CONFIG.DATABASE_ID ||'&'||jspParams;
    vURL := vURL || '&transactionid='||icx_call.encrypt3(l_transaction_id);
    owa_util.redirect_url(vURL);
*/
    OracleApps.runFunction(c_function_id => functionId
                        ,n_session_id => vSessionId
                        ,c_parameters => jspParams
                        ,p_resp_appl_id => l_application_id
                        ,p_responsibility_id => vResponsibilityId
                        ,p_Security_group_id => icx_sec.g_Security_group_id
                        );
  /*
  if fnd_profile.value('BIS_SQL_TRACE')= 'Y' then
     dbms_session.set_sql_trace(false);
  end if;
  */
Exception
  when others then null;
end showReport;

procedure drilldown(pRegionCode         in  varchar2,
                    pFunctionName       in  varchar2,
                    pSessionId          in  Varchar2,
                    pUserId             in  Varchar2,
                    pResponsibilityId   in  Varchar2,
                    pCurrValue          in  varchar2,
                    pCurrLevel          in  varchar2,
                    pCurrAttCode        in  varchar2,
                    pNextLevel          in  varchar2,
                    pNextAttCode        in  varchar2,
                    pDimension          in  varchar2,
                    pYaxisView          in  varchar2,
                    pOrgParam           in  varchar2,
                    pOrgValue           in  varchar2,
                    pScheduleId         in  varchar2 default null,
                    pPageId             in  varchar2 default null,
                    pNextExtraViewBy    in  varchar2 default NULL) is
begin
	NULL;
end drilldown;

procedure displayErrorMessage (p_reportTitle           in varchar2,
                               p_dimn_level_short_name in varchar2,
                               p_dimn_level_value      in varchar2,
                               p_error_no              in number,
                               pRegionCode             in varchar2 default null) is
begin
  -- nbarik - 02/02/06 - Bug Fix 4941888
  -- This shouldn't be used, since it has dependency, making the content null, will remove it later
  NULL;
end displayErrorMessage;

procedure displayError (pErrorNumber        in Number,
                        pOracleErrorNo      in varchar2,
                        pOracleErrorMessage in varchar2)  is

    vErrorMessage varchar2(2000);

begin
  htp.htmlOpen;
  htp.headOpen;
  htp.headClose;
  htp.fontOpen(cface=>gv_font_name, csize=>gv_font_size, ccolor=>'red');
/*gsanap 4/16/04 encoding errormessage bug fix 3568859 */
  vErrorMessage := to_char(pErrorNumber,'99999') || '  ' || pOracleErrorNo
                           || '  ' || wf_notification.SubstituteSpecialChars(pOracleErrorMessage);
  htp.print(vErrorMessage);

  htp.fontClose;
  htp.br;
  htp.fontOpen(cface=>gv_font_name, csize=>gv_font_size);
  htp.fontClose;
  htp.htmlClose;
end displayError;

 --BugFix 3075441, add p_NlsLangCode
FUNCTION GET_NOTIFY_RPT_URL(
                    p_measure_id                  IN   VARCHAR2,
                    p_region_code                 in   varchar2 default null,
                    p_function_name               in   varchar2 default null,
                    p_bplan_name                  IN   VARCHAR2 default null,
                    p_viewby_level_short_name     IN   VARCHAR2 default null,
                    p_Parm1Level_short_name  IN   VARCHAR2 default null, p_Parm1Value_name  IN   VARCHAR2 default null,
                    p_Parm2Level_short_name  IN   VARCHAR2 default null, p_Parm2Value_name  IN   VARCHAR2 default null,
                    p_Parm3Level_short_name  IN   VARCHAR2 default null, p_Parm3Value_name  IN   VARCHAR2 default null,
                    p_Parm4Level_short_name  IN   VARCHAR2 default null, p_Parm4Value_name  IN   VARCHAR2 default null,
                    p_Parm5Level_short_name  IN   VARCHAR2 default null, p_Parm5Value_name  IN   VARCHAR2 default null,
                    p_Parm6Level_short_name  IN   VARCHAR2 default null, p_Parm6Value_name  IN   VARCHAR2 default null,
                    p_Parm7Level_short_name  IN   VARCHAR2 default null, p_Parm7Value_name  IN   VARCHAR2 default null,
                    p_Parm8Level_short_name  IN   VARCHAR2 default null, p_Parm8Value_name  IN   VARCHAR2 default null,
                    p_Parm9Level_short_name  IN   VARCHAR2 default null, p_Parm9Value_name  IN   VARCHAR2 default null,
                    p_Parm10Level_short_name IN   VARCHAR2 default null, p_Parm10Value_name IN   VARCHAR2 default null,
                    p_Parm11Level_short_name IN   VARCHAR2 default null, p_Parm11Value_name IN   VARCHAR2 default null,
                    p_Parm12Level_short_name IN   VARCHAR2 default null, p_Parm12Value_name IN   VARCHAR2 default null,
                    p_Parm13Level_short_name IN   VARCHAR2 default null, p_Parm13Value_name IN   VARCHAR2 default null,
                    p_TimeParmLevel_short_name in varchar2 default null, p_TimeFromParmValue_name in varchar2 default null,
                    p_TimeToParmValue_name in varchar2 default null, p_resp_id in varchar2 default null, p_UserId IN VARCHAR2 default null,
                    p_NlsLangCode in varchar2 default null) RETURN VARCHAR2 IS
  l_url 	VARCHAR2(32767);
BEGIN
    l_url := BIS_PMV_PMF_PVT.GET_NOTIFY_RPT_URL( p_measure_id => p_measure_id
,p_region_code  => p_region_code
,p_function_name => p_function_name
,p_bplan_name                  => p_bplan_name
,p_viewby_level_short_name     => p_viewby_level_short_name
,p_Parm1Level_short_name  => p_parm1level_short_name
,p_Parm1Value_name  => p_parm1value_name
,p_Parm2Level_short_name  => p_parm2level_short_name
,p_Parm2Value_name  => p_parm2value_name
,p_Parm3Level_short_name  => p_parm3level_short_name
,p_Parm3Value_name  => p_parm3value_name
,p_Parm4Level_short_name  => p_parm4level_short_name
,p_Parm4Value_name  => p_parm4value_name
,p_Parm5Level_short_name  => p_parm5level_short_name
,p_Parm5Value_name  => p_parm5value_name
,p_Parm6Level_short_name  => p_parm6level_short_name
,p_Parm6Value_name  => p_parm6value_name
,p_Parm7Level_short_name  => p_parm7level_short_name
,p_Parm7Value_name  => p_parm7value_name
,p_Parm8Level_short_name  => p_parm8level_short_name
,p_Parm8Value_name  => p_parm8value_name
,p_Parm9Level_short_name  => p_parm9level_short_name
,p_Parm9Value_name  => p_parm9value_name
,p_Parm10Level_short_name => p_parm10level_short_name
,p_Parm10Value_name => p_parm10value_name
,p_Parm11Level_short_name => p_parm11level_short_name
,p_Parm11Value_name => p_parm11value_name
,p_Parm12Level_short_name => p_parm12level_short_name
,p_Parm12Value_name  => p_parm12value_name
,p_Parm13Level_short_name => p_parm13level_short_name
,p_Parm13Value_name => p_parm13value_name
,p_TimeParmLevel_short_name => p_TimeParmLevel_short_name
,p_TimeFromParmValue_name => p_TimeFromParmValue_name
,p_TimeToParmValue_name => p_TimeToParmValue_name
,p_resp_id => p_resp_id
,p_UserId => p_UserId
,p_NlsLangCode => p_NlsLangCode);
return l_url;
END GET_NOTIFY_RPT_URL;


-- Report XML Enhancement Senthil
procedure showXmlReport(reportName in varchar2 ,
                     sourceType in varchar2 default 'MDS',
                     pFunctionName in varchar2 ,
                     pApplicationId in varchar2 default NULL,
                     pSessionId    in varchar2 default NULL,
                     pUserId       in varchar2 default NULL,
                     pResponsibilityId in varchar2 default NULL,
                     pFirstTime   in number default 1,
                     pHideParm    in varchar2 default 'false',
                     pHideGraph   in varchar2 default 'false',
                     pHideTable   in varchar2 default 'false',
                     pHideRinfo   in varchar2 default 'false',
                     pSortInfo    in varchar2 default null,
                     pMode        in varchar2 default 'SHOW',
                     pPreFunctionName in varchar2 default NULL,
                     pScheduleId       in varchar2 default NULL,
                     pRequestType      in varchar2 default 'R',
		     pFileId	       in number default null,
                     pParameterDisplayOnly in varchar2 default 'N',
                     pForceRun             in varchar2 default 'N',
                     pDisplayParameters    in varchar2 default 'Y',
                     pReportSchedule       in varchar2 default 'Y',
	             pCSVFileName in varchar2 default NULL,
                     pPageId in varchar2 default NULL,
               	     pParameters in varchar2 default NULL,
		     -- mdamle 10/10/2002 - Enh# 2460903 - Forecast Graph
               	     pEnableForecastGraph  in varchar2 default NULL,
               	     -- jprabhud - 01/27/03 - Enh 2485974 Custom Views
               	     pCustomView  in varchar2 default NULL,
                     pObjectType IN VARCHAR2 DEFAULT NULL,
                     pautoRefresh IN VARCHAR2 DEFAULT NULL,
		       -- Enh Display Run Button
		     pDispRun IN VARCHAR2 DEFAULT NULL,
             -- nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
             pDrillDefaultParameters IN VARCHAR2 DEFAULT NULL,
             --ugodavar - 10/12/04 - Enh.3946492
             pMaxResultSetSize IN number DEFAULT NULL,
             pOutputFormat IN VARCHAR2 DEFAULT NULL
               ) is

    vSessionId          varchar2(80);
    vUserId             varchar2(80);
    vResponsibilityId   varchar2(80);

    jspURL 			varchar2(32767);
    jspParams			varchar2(32767);
    functionid                  NUMBER;
    l_function			VARCHAR2(32000);
    l_application_id 		NUMBER;
    vPageId VARCHAR2(80);
    x_msg_data VARCHAR2(4000);



    CURSOR cFndResp (pRespId in varchar2) is
    select application_id
    from fnd_responsibility
    where responsibility_id=pRespId;
    l_render_type varchar2(200) := 'HTML';

    --serao -for grouped parameters
    lParamGrp BIS_PMV_PARAMETERS_PVT.parameter_group_tbl_type;
    lTCTExists boolean := false;

    vURL varchar2(32000);
    l_servlet_agent varchar2(2000);
    l_transaction_id  number;
    lNestedRegionCode varchar2(250);
    lAsofdateExists  boolean;


begin

   vPageId := pPageId;


   if pScheduleId is null then
      if (not icx_sec.ValidateSession) then
           return;
      end if;
      vSessionId        := icx_sec.getID(icx_sec.PV_SESSION_ID);
      vUserId           := icx_sec.getID(icx_sec.PV_WEB_USER_ID);

     if pResponsibilityId is not null then
         vResponsibilityId := pResponsibilityId;
      else
         vResponsibilityId := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);
      end if;

  else
       vSessionId        := pSessionId;
       vUserId           := pUserId;

       BEGIN
       SELECT responsibility_id INTO vResponsibilityId
       FROM   bis_scheduler
       WHERE  schedule_Id = pScheduleId;
       EXCEPTION
       WHEN OTHERS THEN NULL;
       END;

       vResponsibilityId := pResponsibilityId;
       /* Commenting out for XML Reports
       bis_autoinc_schedule.autoIncrementDates(pRegionCode,
                                             pFunctionName,
                                             vSessionId,
                                             vUserId,
                                             vResponsibilityId,
                                             pScheduleId);
	*/
  end if;

  -- nbarik - 06/15/04 - Bug Fix 3687555 - Get it from context
  l_application_id := FND_GLOBAL.RESP_APPL_ID;
  IF (l_application_id IS NULL OR l_application_id = -1) THEN
    OPEN cFNDResp(vResponsibilityId);
    FETCH cFNDResp INTO l_application_id;
    CLOSE cFNDResp;
  END IF;

  BEGIN

    select function_id
    into functionid
    from fnd_form_functions
    where function_name = 'BIS_PMV_REPORT_JSP';
	-- Maintain the rest of the params, can phase out in a timely manner.
	-- TODO : cleanup params here
	-- DEBUG MODE

    jspParams := 'reportName='||BIS_PMV_UTIL.encode(reportName)||'&sourceType='||BIS_PMV_UTIL.encode(sourceType);
    jspParams := jspParams ||'&functionName='||BIS_PMV_UTIL.encode(pFunctionName);
    jspParams := jspParams ||'&forceRun='||pForceRun||'&parameterDisplayOnly='||pParameterDisplayOnly||'&displayParameters='||pDisplayParameters;
    jspParams := jspParams ||'&showSchedule='||pReportSchedule||'&pFirstTime='||pFirstTime||'&pMode='||pMode;
    jspParams := jspParams ||'&scheduleId='||pScheduleId||'&requestType='||pRequestType;
    jspParams := jspParams ||'&fileId='||pFileId ||'&pResponsibilityId='||pResponsibilityId;
    jspParams := jspParams ||'&pUserId='||pUserId||'&pSessionId='||vSessionId;
    jspParams := jspParams ||'&pApplicationId='||pApplicationId||'&pPreFunctionName='||BIS_PMV_UTIL.encode(pPreFunctionNAme);

    if (pCSVFileName is not null) then
      jspParams := jspParams ||'&pCSVFileName='||BIS_PMV_UTIL.encode(pCSVFileName);
    end if;
    if (vPageId is not null) then
      jspParams := jspParams ||'&_pageid='||vPageId;
    end if;

    --Bug Fix 2997706
    if (pObjectType is not null) then
      jspParams := jspParams ||'&pObjectType='||pObjectType;
    end if;

    if (pParameters is not null) then
      jspParams := jspParams ||'&pParameters='||BIS_PMV_UTIL.encode(pParameters);--Fix for 2445406
    end if;

    -- mdamle 10/10/2002 - Enh# 2460903 - Forecast Graph
    if (pEnableForecastGraph is not null) then
      jspParams := jspParams ||'&pEnableForecastGraph='||pEnableForecastGraph;
    end if;

    -- jprabhud - 01/27/03 - Enh 2485974 Custom Views
    if (pCustomView is not null) then
      jspParams := jspParams ||'&pCustomView='||BIS_PMV_UTIL.encode(pCustomView);
    end if;
    if (pautorefresh is not null) then
       jspParams := jspParams || '&autoRefresh='||BIS_PMV_UTIL.encode(pautorefresh);
    end if;
    --We need to create an icx transaction. Neal has approved the use of this API.:q
    --l_Transaction_id := icx_sec. createTransaction(p_session_id => vsessionid);

--  end if;


    -- kiprabha - Enh Display Run Button
    if (pDispRun is not null) then
    	jspParams := jspParams || '&pDispRun='||pDispRun;
    end if ;

    --IF (l_DrillDefaultParameters IS NOT NULL) THEN
    --  jspParams := jspParams || '&' || l_DrillDefaultParameters;
    --END IF;

    --ugodavar - Enh.3946492
    if(pMaxResultSetSize is not null) then
      jspParams := jspParams ||'&pMaxResultSetSize='||pMaxResultSetSize;
    end if;

    if(pOutputFormat is not null) then
      jspParams := jspParams ||'&pOutputFormat='||pOutputFormat;
    end if;


  EXCEPTION
  WHEN OTHERS THEN

   x_msg_data := SQLERRM;

  NULL;
  END;


    OracleApps.runFunction(c_function_id => functionId
                        ,n_session_id => vSessionId
                        ,c_parameters => jspParams
                        ,p_resp_appl_id => l_application_id
                        ,p_responsibility_id => vResponsibilityId
                        ,p_Security_group_id => icx_sec.g_Security_group_id
                        );

Exception
  when others then  null;
end showXmlReport;


end bisviewer;

/
