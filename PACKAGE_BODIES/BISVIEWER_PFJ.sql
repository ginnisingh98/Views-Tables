--------------------------------------------------------
--  DDL for Package Body BISVIEWER_PFJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BISVIEWER_PFJ" as
/* $Header: BISPFJB.pls 115.34 2002/11/18 20:36:49 kiprabha ship $ */
  -- declare global variables

-----------------------------------------------------------------------------
-- FUNCTION:     pieDataSet                                                --
--                                                                         --
-- DESCRIPTION: This function will transform an input string into a format --
--              necessary for a PFJ pie graph type.                        --
--              For example, it will transform input string                --
--              'setDataSeries(1,2,3,...99,);' into a new string           --
--              'setDataSeries(1);setDataSeries(2);...setDataSeries(99);'  --
--                                                                         --
--                                                                         --
-- PARAMETERS: inputStr string of PFJ format - data set for a graph        --
--                                                                         --
-- MODIFICATIONS:                                                          --
-- DATE          DEVELOPER        COMMENTS                                 --
-- 22-JUN-00     dmarkman         Created                                  --
--                                                                         --
-- 20-MAR-01     dmarkman         bug#1529456 pie chart - 'other'slice     --
-----------------------------------------------------------------------------

FUNCTION  pieDataSet(inputStr in VARCHAR2, pGraphDataPoints in VARCHAR2, pGraphLegend in out NOCOPY varchar2)
RETURN  VARCHAR2 IS

  v_start NUMBER  := 1;
  v_finish NUMBER := 1;
  v_dataPointsCount NUMBER := 0;
  v_sum  NUMBER := 0;
  v_flag NUMBER := 0;

  v_inStr VARCHAR2(32000)  := inputStr;
  v_outStr VARCHAR2(32000) := '';
  v_tempStr VARCHAR2(1000) := '';

BEGIN

  v_inStr := REPLACE(v_inStr, 'setDataSeries');
  v_inStr := REPLACE(v_inStr, '(');
  v_inStr := REPLACE(v_inStr, ')');
  v_inStr := REPLACE(v_inStr, ';');

  v_finish := INSTR(v_inStr, ',');

  WHILE(v_finish <> 0) LOOP

    v_tempStr := SUBSTR(v_inStr, v_start, v_finish - v_start);

    if(v_dataPointsCount < TO_NUMBER(pGraphDataPoints)) then

       v_outStr := v_outStr || 'setDataSeries(' || v_tempStr || ');';

    else

       v_sum := v_sum + TO_NUMBER(v_tempStr);

       v_flag := 1;

    end if;

    v_start := v_finish + 1;

    v_finish := INSTR(v_inStr, ',', v_start);

    v_dataPointsCount := v_dataPointsCount + 1;

  END LOOP;

  if(v_flag > 0) then      -- put 'other' slice

     v_outStr := v_outStr || 'setDataSeries(' || v_sum || ');';

     pGraphLegend := substr(pGraphLegend,1,instr(pGraphLegend,',',1,pGraphDataPoints)) || fnd_message.get_string('BIS','OTHER');

end if;

  RETURN v_outStr;

END pieDataSet;

-----------------------------------------------------------------------------
-- FUNCTION:    buildChartApplet                                           --
--                                                                         --
-- DESCRIPTION: This function will create an applet that displays a PFJ    --
--              graph. See PFJ documentation fot more details.             --
--                                                                         --
-- PARAMETERS:  pAppletWidth   Applet width                                --
--              pFrameYaxis    Frame Y axis                                --
--		pFrameHeight   Frame height                                        --
--              pGraphStyle    Graph style                                 --
--		pGraphyaxis    Graph Y axis                                        --
--		pGraphTitle    Graph title                                         --
--		pGraphLegend   Graph legend                                        --
--		pXaxisLabel    X axis label                                        --
--		pGraphValue    Graph data set                                      --
--                                                                         --
-- MODIFICATIONS:                                                          --
-- DATE          DEVELOPER        COMMENTS                                 --
-- 22-JUN-00     dmarkman         Created                                  --
-- 20-Sep-00	 aleung		  use variable applet width and height         --
-- 13-Nov-00     dmarkman     comment out the servlet                      --
-- 16-Nov-00     dmarkman     set viewable datapoints to 12                --
-- 05-Dec-00     dmarkman     in viewable datapoints, pass a parameter     --
--                            pGraphDataPoints to a call setViewableGroups --
--                            (applet). To be added to sevlet as well      --
-- 06-Dec-00       hali         Added pGraphDataPoints to servlet
-- 07-Dec-00       hali        Added vMode for no Default sample points in servlet

-- 08-Dec-00       hali       Activated the servlet
-- 07-Mar-01       dmarkman   bug#1671995
-- 09/07/01        mdamle    Add Graph Number poplist			  --
-----------------------------------------------------------------------------

function  buildChartApplet ( pAppletWidth  in number,
                             pAppletHeight in number,
                             pFrameYaxis   in number,
                             pFrameHeight  in number,
                             pGraphStyle   in varchar2,
                             pGraphyaxis   in varchar2,
                             pGraphTitle   in varchar2,
                             pGraphLegend  in varchar2,
                             pXaxisLabel   in varchar2,
                             pGraphValue   in varchar2,
			     pGraphDataPoints  in varchar2,
                             pGraphName in varchar2 default null,
                             pRequestType in varchar2 default null,
                             pScheduleId  in number default null,
			     pDeltaFontSize  in number default 0,
			     pFontType  in varchar2 default 'Dialog',
			     -- mdamle 09/07/01 - Add Graph Number poplist
			     pFileId 	   in number default null
                           ) return  varchar2 is


   vApplet           varchar2(32000) := '';
   vGraphValue1      varchar2(32000) := '';
   vGraphTitle       varchar2(32000) := '';
   vGraphyaxis       varchar2(32000) :='';
   vGraphValue       varchar2(32000) := pGraphValue;
   vGraphLegend      varchar2(32000) := pGraphLegend;
   vXaxisLabel       varchar2(32000) := pXaxisLabel;
   vDepthRadiusValue number := 40;

--hali 6/12/00 No Default Sample points in servlet

   vMode           varchar2(320) := 'nodefault';
   vAgent            varchar2(100);
   vGraphName        varchar2(1000);

   vGraphStyle NUMBER := pGraphStyle;

   vUserId  varchar2(80);
   vRespId  varchar2(80);
   vFileId  number;
   vAppsId  number;
   vFunctionId number;
   vSessionId  varchar2(80);
   vCookieName varchar2(2000);
   vCookieValue varchar2(2000);
   vTransactionId varchar2(2000);
   vDBCName varchar2(2000);
   vWebAgent varchar2(2000);
   vFwkAgent varchar2(2000);
   vLanguageCode varchar2(1000);
   vReturnStatus varchar2(2000);
   vMsgData  varchar2(2000);
   vMsgCount number;
   vParameterString varchar2(32000);
   l_function  varchar2(32000);
   vDummyString varchar2(32000);

   cursor cScheduler(cpScheduleId in number) is
   -- mdamle 09/07/01 - Add Graph Number poplist
   -- Removed fileId from select
   select user_id, responsibility_id
   from   bis_scheduler
   where  schedule_id = cpScheduleId;

/*
   cursor cAppsId(cpRespId in number) is
   select application_id
   from fnd_responsibility
   where responsibility_id = cpRespId;

   cursor cFuncId(cpFunctionName in varchar2) is
   select function_id
   from   fnd_form_functions
   where  function_name = cpFunctionName;
*/

   vSqlErr varchar2(32000);
   l_plsql_agent varchar2(32000);

begin

  if (TO_NUMBER(vGraphStyle) = 117) then

      vDepthRadiusValue := 0;
      vGraphStyle := 17;

  elsif (TO_NUMBER(vGraphStyle) = 118) then

      vDepthRadiusValue := 0;
      vGraphStyle := 18;

  elsif (TO_NUMBER(vGraphStyle) = 41) then

      vDepthRadiusValue := 0;

  elsif (TO_NUMBER(vGraphStyle) = 141) then

      vGraphStyle := 41;

  elsif (TO_NUMBER(vGraphStyle) = 131) then

      vDepthRadiusValue := 0;
      vGraphStyle := 31;

  end if;

  if (TO_NUMBER(vGraphStyle) = 55) then

      vGraphLegend := pXaxisLabel;
      vXaxisLabel  := pGraphLegend;
      vGraphValue  := pieDataSet(vGraphValue,'11',vGraphLegend);

  end if;


/*********SERVLET*START*******COMMENTED OUT*******/

--  SELECT fnd_profile.value('BIS_SERVLET_BASE_PATH')
--    INTO vAgent
--  FROM dual;

   vAgent := fnd_profile.value('BIS_SERVLET_BASE_PATH');

--hali 11/30/00 Cannot have spaces,#  and semi-colon in the URL

--   dmarkman 03/06/01 URL is too long bug#1671995 - remove spaces in vGraphValue.
   vGraphValue    := replace(vGraphValue,' ');

-- dmarkman 05/01/01 '&' in the data in the URL bug#1765105

   vGraphLegend   := replace(vGraphLegend,' ','^');
   vGraphLegend   := replace(vGraphLegend,'&quot;,',',,,,');
   vGraphLegend   := replace(vGraphLegend,'&quot;','');
   vGraphLegend   := replace(vGraphLegend,'%','Percent^');
   vGraphLegend   := replace(vGraphLegend,'&','%26!');

   vXaxisLabel    := replace(vXaxisLabel,' ','^');
   vXaxisLabel    := replace(vXaxisLabel,'&quot;,',',,,,');
   vXaxisLabel    := replace(vXaxisLabel,'&quot;','');
   vXaxisLabel    := replace(vXaxisLabel,'%','Percent^');
   vXaxisLabel    := replace(vXaxisLabel,'&','%26');

   vGraphyaxis    := replace(pGraphyaxis,' ','^');
   vGraphyaxis    := replace(vGraphyaxis,'&quot;,',',,,,');
   vGraphyaxis    := replace(vGraphyaxis,'&quot;','');
   vGraphyaxis    := replace(vGraphyaxis ,'%','Percent^');
   vGraphyaxis    := replace(vGraphyaxis,'&','%26');

   vGraphTitle    := replace(pGraphTitle,' ','^');
   vGraphTitle    := replace(vGraphTitle,'&quot;,',',,,,');
   vGraphTitle    := replace(vGraphTitle,'&quot;','');
   vGraphTitle    := replace(vGraphTitle,'%','Percent^');
   vGraphTitle    := replace(vGraphTitle,'&','%26');

   if pGraphTitle is null then
      vGraphName := pGraphName;
   else
      vGraphName := pGraphTitle;
   end if;

   vApplet := '<img src ="' || vAgent || '/oracle.apps.bis.chart.BisGraph?';
   vApplet := vApplet || 'param='||vMode;
   vApplet := vApplet || '&pGraphStyle='||vGraphStyle;
   vApplet := vApplet || '&vDepthRadiusValue='||vDepthRadiusValue;
   vApplet := vApplet || '&pHeight='||pAppletHeight;
   vApplet := vApplet || '&pWidth='||pAppletWidth;
   vApplet := vApplet || '&pFrameYaxis='||pFrameYaxis;
   vApplet := vApplet || '&pFrameHeight='||pFrameHeight;
   vApplet := vApplet || '&pGraphDataPoints='||pGraphDataPoints;
   vApplet := vApplet || '&vDeltaFontSize='||pDeltaFontSize;
   vApplet := vApplet || '&vFontType='||pFontType;
   vApplet := vApplet || '&pGraphyaxis=' ||vGraphyaxis;
   vApplet := vApplet || '&pGraphTitle=' ||vGraphTitle;
   vApplet := vApplet || '&vGraphLegend=' || vGraphLegend;
   vApplet := vApplet || '&vXaxisLabel=' || vXaxisLabel;
   vApplet := vApplet || '&vGraphValue=' || vGraphValue;
   vApplet := vApplet || '" ALT="'||vGraphName||'">';

   vApplet   := replace(vApplet,'&quot;,',',,,,');
   vApplet   := replace(vApplet,'&quot;','');
   vApplet   := replace(vApplet,';',',');
   vApplet   := replace(vApplet,'#','~');
   --vApplet   := replace(vApplet,'%','Percent^');

-- vApplet := vApplet || '" height='|| to_char(pAppletHeight);
-- vApplet := vApplet || ' width='||to_char(pAppletWidth)||'>';
-- aleung 9/20/2000 change 700 to
-- to_char(pAppletWidth)

  --aleung, 8/27/01, invoke the graph servlet as OracleApps.RF, pass file id and request type
  if pRequestType = 'G' and pScheduleId > 0 then
     if cScheduler%ISOPEN then
        close cScheduler;
     end if;
     open cScheduler(pScheduleId);
	  -- mdamle 09/07/01 - Add Graph Number poplist
	  -- Removed file_id from fetch
          fetch cScheduler into vUserId, vRespId;
     close cScheduler;
/*
     if cAppsId%ISOPEN then
        close cAppsId;
     end if;
     open cAppsId(vRespId);
          fetch cAppsId into vAppsId;
     close cAppsId;

     if cFuncId%ISOPEN then
        close cFuncId;
     end if;
     open cFuncId('BIS_PMV_GRAPH_SERVLET');
          fetch cFuncId into vFunctionId;
     close cFuncId;

*/
     --create ICX Session
     BIS_ICX_SECURITY_PVT.CREATE_ICX_SESSION
     (p_user_id => vUserId
     ,x_session_id => vSessionId
     ,x_cookie_value => vCookieValue
     ,x_cookie_name => vCookieName
     ,x_transaction_id => vTransactionId
     ,x_dbc_name => vDBCName
     ,x_apps_web_agent => vWebAgent
     ,x_apps_fwk_agent => vFwkAgent
     ,x_language_code => vLanguageCode
     ,x_return_Status => vReturnStatus
     ,x_msg_Data => vMsgData
     ,x_msg_count => vMsgCount);

/*
     l_function := icx_Call.encrypt2(vAppsId||'*'||vRespId ||'*'||
                                  icx_sec.g_security_group_id || '*'||vFunctionId||'**]',
                                  vSessionId);
*/
     -- mdamle 09/07/01 - Add Graph Number poplist
     -- Changed vFileId to pFileId
     vParameterString := vParameterString || 'pFileId='||pFileId;
     vParameterString := vParameterString || '&pRequestType=G';
     vParameterString := vParameterString || '&param='||vMode;
     vParameterString := vParameterString || '&pGraphStyle='||vGraphStyle;
     vParameterString := vParameterString || '&vDepthRadiusValue='||vDepthRadiusValue;
     vParameterString := vParameterString || '&pHeight='||pAppletHeight;
     vParameterString := vParameterString || '&pWidth='||pAppletWidth;
     vParameterString := vParameterString || '&pFrameYaxis='||pFrameYaxis;
     vParameterString := vParameterString || '&pFrameHeight='||pFrameHeight;
     vParameterString := vParameterString || '&pGraphDataPoints='||pGraphDataPoints;
     vParameterString := vParameterString || '&vDeltaFontSize='||pDeltaFontSize;
     vParameterString := vParameterString || '&vFontType='||pFontType;
     vParameterString := vParameterString || '&pGraphyaxis=' ||vGraphyaxis;
     vParameterString := vParameterString || '&pGraphTitle=' ||vGraphTitle;
     vParameterString := vParameterString || '&vGraphLegend=' ||vGraphLegend;
     vParameterString := vParameterString || '&vXaxisLabel=' ||vXaxisLabel;
     vParameterString := vParameterString || '&vGraphValue=' ||vGraphValue;

     vParameterString := replace(vParameterString,'&quot;,',',,,,');
     vParameterString := replace(vParameterString,'&quot;','');
     vParameterString := replace(vParameterString,';',',');
     vParameterString := replace(vParameterString,'#','~');


     vDummyString := utl_http.request(vAgent||'/oracle.apps.bis.chart.BisGraph?dbc='||FND_WEB_CONFIG.DATABASE_ID
                                 ||'&sessionid='||vsessionid||'&'||vParameterString);
/*
     OracleApps.RF(F => l_function,
                   P => icx_call.encrypt2(vParameterString, vSessionId));

*/

  end if;

/********SERVLET*END*****COMMENTED OUT*******/


/*******APPLET*START*********

  vApplet := '<applet CODE="oracle.apps.bis.chart.BISChartApplet.class" WIDTH="'||to_char(pAppletWidth)||'"
HEIGHT="' || to_char(pAppletHeight) || '" ARCHIVE="/OA_JAVA/oracle/apps/bis/jar/bischart.jar">
   <param name="TDGSCRIPT"
   value="
        setGraphType(' || vGraphStyle || ');
        setFontSizeAbsolute(true);
        setFontSize(getTitle(),8);
        setFontSizeAbsolute(true);
        setFontSize(get01Label(),6);
        setFontSizeAbsolute(true);
        setFontSize(getY1Label(),6);
        setFontSizeAbsolute(true);
        setFontSize(getY1Title(),7);
        setFontSizeAbsolute(true);
        setFontSize(getX1Label(),6);
        setFontStyle(getX1Label(),0);
        setX1LabelRotate(2);
        setAutofit(getY1Label(),true);
        setAutofit(getX1Label(),true);
        setFontSize(getLegendText(),5);
        setUseOffScreen(false);
        setAutofit(getFrame(),false);
        setManualRedraw(false);
        setLegendOrient(0);
        setReshapeEnable(true);
        setSelectionEnableMove(true);
        setDepthRadius(' || vDepthRadiusValue || ');
        setFillColor(getLegendArea(),new Color(255,255,255));
        setRect(getFrame(),new Rectangle(-12000,-'|| pFrameYaxis ||',21000,'|| pFrameHeight ||'));
        setRect(getTitle(),new Rectangle(-14913,13283,29850,1800));
        setRect(getLegendArea(),new Rectangle(9200,4000,6000,7000));
        setFillColor(getTitle(),new Color(0,0,255));
        setTextRotation(getO1Label(),2); setTextFormatPattern(getY1Label(),2);
        setTextRotation(getX1Label(),1);
        setTextRotation(getY1Label(),0);
        setScrollOffsetGroups(3);
        setViewableGroups(' || pGraphDataPoints || ');
        setViewableSeries(10);
        setY1TitleString(&quot;' || pGraphyaxis || '&quot;);
        setTextString(getTitle(), &quot;' || pGraphTitle || '&quot;);
        setSeriesLabelArray(' || vGraphLegend || ');
        setGroupLabelArray(' || vXaxisLabel || '); ' || vGraphValue ||
        '">
      </applet>';

/*****APPLET*END************************/


  return vApplet;
exception when others then
  null;
end buildChartApplet;



end bisviewer_pfj;


/
