--------------------------------------------------------
--  DDL for Package Body BIS_TREND_PLUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_TREND_PLUG" as
/* $Header: BISTRNDB.pls 120.3 2006/02/02 02:08:40 nbarik noship $ */
-- Added for ARU db drv auto generation
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
-- dbdrv: checkfile(115.189=120.3):~PROD:~PATH:~FILE
/*
REM +===========================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA         |
REM |                         All rights reserved.                              |
REM +===========================================================================+
REM | FILENAME                                                                  |
REM |     BISTRNDB.pls                                                          |
REM |                                                                           |
REM | DESCRIPTION                                                               |
REM |     Package for Scheduling Portlets                                       |
REM |                                                                           |
REM | NOTES                                                                     |
REM |                                                                           |
REM | HISTORY                                                                   |
REM | Date         Developer  Comments                                          |
REM | 26-SEP-2002  nbarik     Bug 1917856: Use ICX Date Format for upd_date     |
REM | 28-SEP-2002  ansingh    Bug 2599787: Reduce updates to                    |
REM |						   icx_portlet_customizations in initialiseRLPortlet|
REM | 24-MAR-2003  rcmuthuk   Bug 2856247: Custom Views attached at function    |
REM |			                         not working due to wrong region code |
REM | 03-APR-2003  nkishore   Bug 2869306: Substitute Time ViewBy with DimLevel |
REM | 14-APR-2003  gsanap   Bug 2852195: get user_function_name for empty prompt |
REM | 11-Aug-2003  nbarik   Bug 3088087                                         |
REM | 24-Nov-2003  ksadagop Bug 3265474                                         |
REM | 27-Nov-2003  ksadagop Bug 3281530                                         |
REM | 02-Dec-2003  ksadagop Enh 3252697--Fnd Cache Invalidation                 |
REM | 12-Jan-2004  nkishore BugFix 3360363                                      |
REM | 12-Jan-2004  nkishore BugFix 3417356                                      |
REM | 12-MAR-2004  mdamle   Enh 3503753 - Site level custom. for links  	|
REM | 31-MAY-2004  nbarik   Enhancement 3576963 - Drill Java Conversion         |
REM | 14-JUN-2004  ansingh  Enh#3690747: Portlet Personalization                |
REM | 04-Aug-2004  ashgarg Enh#3813010:Moving Select Different Report page to  OA        +===========================================================================+
*/

G_MAX_VARCHAR2   constant number := 2000;
G_GRAPH_BORDER   constant number := 0;
G_GRAPH_HEIGHT   constant number := 275;
G_GRAPH_WIDTH    constant number := 450;
G_MAX_LOOP_COUNT constant number := 100;

g_css varchar2(1000) := FND_PROFILE.value('ICX_OA_HTML');
g_CSSDirectory varchar2(1000) := FND_WEB_CONFIG.TRAIL_SLASH(g_css);

images varchar2(1000) := FND_PROFILE.value('ICX_REPORT_IMAGES');
gvImageDirectory varchar2(1000) := FND_WEB_CONFIG.TRAIL_SLASH(images);



-- *****************************************
-- PROCEDURE TO extract a numbered gif file form the output of Web-served Reports
-- *****************************************

procedure get_graph_from_URL( p_trend_type    IN VARCHAR2,
                              p_report_Fn_URL in varchar2,
			                  x_img_html      out NOCOPY varchar2
			     )
  is
  l_html         varchar2(32000);
  l_URL          varchar2(32000);
  l_opening_pos  number;
  l_len          number;
  l_dot_pos	     number;
  l_img_src_str          varchar2(32000);
  l_searched_str         varchar2(32000);
  l_search_str           varchar2(32000);
  l_img_src_found        varchar2(32000);
  l_file_start_found     varchar2(32000);
  l_html_pieces          utl_http.html_pieces;
  l_loop_1_counter  number := 1;
  l_loop_2_counter  number := 1;
  l_loop_3_counter  number := 1;

  i number := 0;
  k_trail number := 0;
  j varchar2(32000);
  j_front varchar2(32000);
  j_trail varchar2(32000);
  k number :=0;
  l varchar2(32000);
  m number :=0;
  n number :=0;
  o number :=0;
  a number :=0;
  b number :=0;
  c number :=0;
  diff number :=0;
  str number ;

begin


 l_html_pieces := utl_http.request_pieces( url => p_report_Fn_URL,
                                             max_pieces => 32000);

-- original code for Graph
 if p_trend_type = 'G' then

   for m in l_html_pieces.first..l_html_pieces.last loop
      n := instr(l_html_pieces(m),'img src ="http://');
      if n > 0 then
         k := n;
         o := m;
         exit;
      end if;
   end loop;


   j := substr(l_html_pieces(o),k+10,k+2000);
   j_front := j;

   i := instr(j,'"></TD>');

   if i > 0 then
     l := substr(j,1,i-1);
   else
     j_trail := substr(l_html_pieces(o+1),1,2000);
     k_trail := instr(j_trail,'"></TD>');
     if k_trail > 0 then
      l := substr(j_trail,1,k_trail-1);
      l := j_front||l;
     end if;
   end if;

   x_img_html := l;

--Code for Table

 elsif p_trend_type = 'T' then


   for m in l_html_pieces.first..l_html_pieces.last loop
      n := instr(l_html_pieces(m),'<!-- Actual Table');
      if n > 0 then
         k := n;
         o := m;
         exit;
      end if;
   end loop;

   m := 0;

   for m in l_html_pieces.first..l_html_pieces.last loop
      a := instr(l_html_pieces(m),'<!-- RELATED');
      if a > 0 then
         b := a;
         c := m;
         exit;
      end if;
   end loop;

   diff := c - o;




   j := substr(l_html_pieces(o),k,k+7000);

   for str in o+1..c-1 loop
      j := j||l_html_pieces(str);
   end loop;


   j_front := j;


   i := instr(l_html_pieces(c),'<!-- RELATED');

   if i > 0 then
     j_trail := substr(l_html_pieces(c),1,i-1);
     l := j_front||j_trail;

   else
     j_trail := substr(l_html_pieces(o+1),1,7000);
     k_trail := instr(j_trail,'<!-- RELATED');
     if k_trail > 0 then
      l := substr(j_trail,1,k_trail-1);
      l := j_front||l;
     end if;
   end if;

   x_img_html := l;

 end if;

	exception
   when others then
      x_img_html := NULL;
      htp.p('<! EXCEPTION '|| Sqlerrm ||'
	    URL is  '|| p_report_Fn_URL ||'
		 >'
		 );
	      htp.p('<! html First piece is'
		    ||REPLACE(l_html_pieces(1),'>',' ')
		    ||'>');

end get_graph_from_URL;

-- mdamle 04/05/2001 - Get Graph and Table HTML from FND_LOBS
procedure Show(p_session_id in pls_integer default NULL,
               p_plug_id    in pls_integer default NULL,
               p_display_name  varchar2 default NULL,
               p_delete in varchar2 default 'N')
is
  l_title        		varchar2(80);
  l_colour       		varchar2(30);
  l_user_id              	pls_integer;
  l_responsibility_id    	pls_integer;
  l_fn_responsibility_id 	pls_integer;
  l_function_id          	pls_integer;
  l_img_html 	         	varchar2(32000);
  l_plsql_agent_URL   	 	varchar2(32000);
  l_Graph_URL            	varchar2(32000);
  l_function_name        	fnd_form_functions_vl.user_function_name%TYPE;
  l_function_description 	fnd_form_functions_vl.description%TYPE;
  l_Report_Run_str       	varchar2(32000);

  l_application_id	 	pls_integer;

  l_graph_width         	varchar2(255);
  l_graph_height        	varchar2(255);
  l_graph_size_HTML     	varchar2(255);

  l_schedule_id         number;
  l_file_id             	pls_integer := null;
  l_profile_defined		boolean;
  l_message             	varchar2(32000);
--l_html_pieces			utl_http.html_pieces;
  l_html_pieces			bis_pmv_util.lob_varchar_pieces;
  last_upd                  	date;
  l_report_url              	varchar2(32000);
  l_parameters              	varchar2(32000);
  l_customize_url           	varchar2(32000);
  r_region                  	varchar2(32000);
  -- mdamle 04/27/01
  l_front			varchar2(32000);
  l_trail			varchar2(32000);
  l_cssFound			boolean;
  l_file_content_type		varchar2(256);
  --ashgarg
  l_resp_id    varchar2(80);
  l_sec_grp_id number;

  -- jprabhud 09/24/02 - Enh. 2470068 DB Graph HTML - Reusing file Ids to store graphs
  vGraphFileId varchar2(20);



begin

	-- mdamle 08/08/01 - Fix Bug#1910032 - Improve Performance
	-- 1) Use fnd_form_functions in join instead of fnd_form_functions_vl
	-- 2) Remove the Cursor for retrieving Application Id - not used anymore
	-- 3) Remove r_function, use function name from query

	IF icx_sec.validatePlugSession(p_plug_id,p_session_id) THEN

	   -- mdamle 01/24/01
	   l_user_id := icx_sec.getID(icx_sec.PV_USER_ID,'',p_session_id);

     IF p_delete = 'Y' THEN
		 -- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
		 -- Delete Portlet data and schedule info now that portlet is deleted
     -- jprabhud 09/24/02 - Enh. 2470068 DB Graph HTML - Reusing file Ids to store graphs - passed in vGraphFileId
 		   bis_rg_schedules_pvt.delete_portlet(p_plug_id, l_user_id,vGraphFileId);
       if vGraphFileId is not null then
    		   delete fnd_lobs where file_id = vGraphFileId;
       end if;


     else

		-- mdamle 08/21/01 - Only one user_id, plug_id combination exists in bis_scheduler from now on
		-- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
		begin
  			SELECT sp.title
		   	, sp.file_id
		   	, ff.function_id
	   		, s.function_name
	           	, sp.last_update_date
        	   	, ff.web_html_call
           		, s.responsibility_id
	           	, sp.schedule_id
			, l.file_content_type
			into
			l_title
			, l_file_id
			, l_function_id
			, l_function_name
			, last_upd
			, l_parameters
			, l_fn_responsibility_id
			, l_schedule_id
			, l_file_content_type
  			FROM   bis_scheduler s, bis_schedule_preferences sp, fnd_form_functions ff, fnd_lobs l
  			WHERE  sp.USER_ID = l_user_id
	  		AND    sp.PLUG_ID = p_plug_id
			AND    sp.schedule_id = s.schedule_id
  			AND    ff.function_name = s.function_name
			AND    sp.file_id = l.file_id;
		exception
			when others then null;
		end;

                if l_fn_responsibility_id is null then
		   l_fn_responsibility_id := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID,'',p_Session_id);
                end if;

                getRespInfo(l_User_Id, l_fn_responsibility_id, l_application_id, l_sec_grp_id);

		-- mdamle 11/08/01 - Get region from utility function
		-- 		   - Form Function definition is changed
		/*
      		r_region := substr( l_parameters, instr(l_parameters, '''')+1 );
      		r_region := substr( r_region, 1, instr(r_region,'''')-1 );
		*/
		r_region := BIS_PMV_UTIL.getReportRegion(l_function_name);

            	if r_region is null and l_function_name is null then
            	--ashgarg changed it for moving select different reports to OA.jsp
            	 --ashgarg Bug Fix:3823820
                begin
        	select function_id into l_function_id
        	from fnd_form_functions
        	where function_name = 'BIS_PMV_SELECT_DIFF_REPORT';
                exception
		     when others then l_function_id := null;
                end;
                if l_function_id is not null then
                    l_parameters := 'Region_Code='||
                    '&Function_Name='||
                    '&respID='||
                    '&pUserId='||l_User_Id
                    ||'&pPlugId='||p_Plug_Id
                    ||'&pScheduleOverride=Y'
                    ||'&pMode=Y';

                l_CUSTOMIZE_URL := icx_sec.createRFURL( p_function_id => l_function_id
                                   , p_session_id => p_session_id
                                   , p_parameters => l_parameters
                                   , p_application_id => l_application_id
                                   , p_responsibility_id => l_fn_responsibility_id
                                   , p_security_group_id => icx_sec.g_security_group_id);

            	/*l_CUSTOMIZE_URL := icx_plug_utilities.getPLSQLagent
                     || 'OracleApps.runFunction?c_function_id=' || l_function_id
                                  ||'&n_session_id='||p_session_id
                                  ||'&c_parameters='||BIS_PMV_UTIL.encode(l_parameters)
                                  ||'&p_resp_appl_id='||l_application_id
                                  ||'&p_responsibility_id='||l_resp_id
				   -- mdamle 01/08/2002
                                  ||'&p_Security_group_id='||icx_sec.g_security_group_id;*/

        end if;
          	/*	l_CUSTOMIZE_URL :='OA_HTML/OA.jsp?akRegionCode=BISPMVRLREPORTSWORKBOOKSPAGE&akRegionApplicationId=191&retainAM=Y'||'&Region_Code='
                                  ||'&Function_Name='
                                  ||'&respID='
                                  ||'&pUserId='||l_User_Id
                                  ||'&pPlugId='||p_Plug_Id
				   -- mdamle 01/08/2002
                                  ||'&pScheduleOverride=Y'
                                  ||'&pMode=Y';*/
            	else
			-- mdamle 10/30/01 - Converted PLSQL to JSP
			/*
                	l_CUSTOMIZE_URL := icx_plug_utilities.getPLSQLagent
                                   ||'bisviewer.parametersection?Region_Code='||r_region
                                   ||'&Function_Name='||l_function_name
                                   ||'&pResponsibilityId='||l_fn_responsibility_id
                                   ||'&pUserId='||l_user_id
                                   -- mdamle 05/09/01 - uncommented session_id
                                   ||'&pSessionId='||p_session_id
                                   ||'&pPlugId='||p_plug_id
                                   ||'&pScheduleId='||l_schedule_id
				   -- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
				   ||'&pFileId='||l_File_id;
			*/

                	l_CUSTOMIZE_URL := icx_plug_utilities.getPLSQLagent
                                   ||'bis_trend_plug.customizePortlet?Region_Code='||r_region
                                   ||'&Function_Name='||l_function_name
                                   ||'&pResponsibilityId='||l_fn_responsibility_id
                                   ||'&pUserId='||l_user_id
                                   -- mdamle 05/09/01 - uncommented session_id
                                   ||'&pSessionId='||p_session_id
                                   ||'&pPlugId='||p_plug_id
                                   ||'&pScheduleId='||l_schedule_id
				   -- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
				   ||'&pFileId='||l_File_id
				   -- mdamle 01/08/2002
				   ||'&pScheduleOverride=Y';

            	end if;

      		htp.p('<!-- Graphics Plug -->');

      		icx_plug_utilities.plugbanner
	    		('<A href='||FND_WEB_CONFIG.trail_slash(icx_plug_utilities.getPLSQLagent)
||'bis_trend_plug.view_report_from_portlet?pRegionCode='||r_region||'&pFunctionName='||l_function_name

                 || '&pScheduleId='||l_schedule_id
	             ||' target=_top><font color="#ffffff" face="Arial">'||l_title||BIS_PMV_UTIL.getAppendTitle(r_region)||'</font></A>'
	     		,l_customize_url
	     		,'FNDTREND.gif');

		setTableStyles;

           	if (l_file_id is not null) then

			-- TABLE / GRAPH IS AVAILABLE IN HTML
                        -- aleung, 7/13/01, use readFndLobs to get the html pieces
                        l_html_pieces := bis_pmv_util.readFndLobs(l_file_id);

			-- mdamle 08/27/01 - Show gif for graph or html for table
			if l_html_pieces.count > 0 then
				if instr(lower(l_file_content_type),'image/gif') > 0 then
					htp.p('<table width="100%" border="0" cellspacing="0" cellpadding="0">
                     				<tr><td>');
					htp.p('<img src='||FND_WEB_CONFIG.trail_slash(FND_WEB_CONFIG.PLSQL_Agent)
						 ||'bis_save_report.retrieve?file_id='||l_file_id);
					htp.p('</td></tr></table>');

				else


					l_cssFound := false;
    	 				for i in 1..l_html_pieces.COUNT loop
    	 					-- mdamle 04/27/01 - Remove reference to css file
	    	 				-- Instead include the required tags in the page.
					    	if l_cssFound = false then
    	 						if instr(l_html_pieces(i), 'bismarli') > 0 then
    	 							l_front := substr(l_html_pieces(i),1,instr(l_html_pieces(i),'<LINK')-1);
                   						l_trail := substr(l_html_pieces(i),instr(l_html_pieces(i),'css">')+5,length(l_html_pieces(i)));
        		   					htp.prn(l_front||l_trail);
        		   					l_cssFound := true;
	    	 					else
        							htp.prn(l_html_pieces(i));
        						end if;
        					else
        						htp.prn(l_html_pieces(i));
       						end if;
	     	 			end loop;
				end if;	-- file_content_type
			end if;

			-- 08/16/2001 - Show Portlet Status
			showPortletStatus(l_html_pieces.count, last_upd);
/*
			htp.p('<table width="100%" border="0" cellspacing="0" cellpadding="0">
                     			<tr><td class=OraTipText>
	                     		<A href='||FND_WEB_CONFIG.trail_slash(icx_plug_utilities.getPLSQLagent)
        	            		||'bis_trend_plug.view_report_from_portlet?pRegionCode='||r_region||'&pFunctionName='||l_function_name
                	    		|| '&pScheduleId='||l_schedule_id
	                    		||' target=_top>'||FND_MESSAGE.get_string('BIS','BIS_VIEW_REPORT')||'</A><br>
        	             		</td></tr></table>');
*/
		end if; -- file_id is not null
   end if; -- p_delete
 END IF;  -- icx_sec.validatesession

exception
  when others then
   htp.header(5,SQLERRM);

end Show;

procedure setTableStyles is
begin

		-- mdamle 04/27/01 - Override styles - remove text-indent  - causing resizing problems in Netscape
		-- gsanap 06/27/01 - modified tags added Border in the tags
		-- Removed references to bismarli.css
		-- mdamle 07/27/01 - Updated styles based on new bismarli.css
		-- mdamle 08/20/01 - Replaced font 10pt with 9pt
	        htp.p('<STYLE TYPE="text/css">');

		htp.p('.OraTable {BORDER-TOP: #cccc99 1px solid; BORDER-LEFT: #cccc99 1px solid;}');
		htp.p('.OraTipText {COLOR: #336699; FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt}');
		htp.p('.OraTableTitle {BACKGROUND-COLOR: #ffffff; COLOR: #336699; FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 14pt}');
		htp.p('.OraTableControlBarText {BACKGROUND-COLOR: #cccc99; COLOR: #336699; FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 11pt; FONT-WEIGHT: bold}');
		htp.p('.OraTableColumnHeader {BACKGROUND-COLOR: #cccc99; COLOR: #336699; FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt; FONT-WEIGHT: bold; TEXT-ALIGN: left; BORDER-BOTTOM: #f7f7e7 1px solid; BORDER-RIGHT: #f7f7e7 1px solid;}');
		htp.p('.OraTableSortableColumnHeader {font-family:Arial,Helvetica,Geneva,sans-serif;font-size:9pt;font-weight:bold;text-align:left;background-color:#cccc99;color:#336699;cursor:hand;BORDER-BOTTOM: #f7f7e7 1px solid;BORDER-RIGHT: #f7f7e7 1px solid;}');
		htp.p('A.OraTableSortableColumnHeader:link {BACKGROUND-COLOR: #cccc99; COLOR: #336699; CURSOR: hand; FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt; FONT-WEIGHT: bold; TEXT-ALIGN: left; TEXT-DECORATION: none; }');
		htp.p('A.OraTableSortableColumnHeader:active {BACKGROUND-COLOR: #cccc99; COLOR: #336699; CURSOR: hand; FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt; FONT-WEIGHT: bold; TEXT-ALIGN: left; TEXT-DECORATION: none; }');
		htp.p('A.OraTableSortableColumnHeader:visited {BACKGROUND-COLOR: #cccc99; COLOR: #336699; CURSOR: hand; FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt; FONT-WEIGHT: bold; TEXT-ALIGN: left; TEXT-DECORATION: none; }');
		htp.p('.OraTableRowHeader {BACKGROUND-COLOR: #cccc99;COLOR: #336699;FONT-FAMILY:Arial, Helvetica,Geneva,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;TEXT-ALIGN:right;BORDER-BOTTOM: #f7f7e7 1px solid; BORDER-RIGHT: #f7f7e7 1px solid;}');
		htp.p('.OraTableColumnFooter {BACKGROUND-COLOR: #cccc99; COLOR: #336699; FONT-FAMILY: Arial,Helvetica,Geneva,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;PADDING-TOP:2px;TEXT-ALIGN:left;VERTICAL-ALIGN:top;BORDER-BOTTOM:#f7f7e7 1px solid;');
                htp.p(' BORDER-RIGHT: #f7f7e7 1px solid;}');
		htp.p('.OraTableTotal {BACKGROUND-COLOR: #cccc99; COLOR: #336699; FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt; FONT-WEIGHT: bold; TEXT-ALIGN: right; BORDER-BOTTOM: #f7f7e7 1px solid; BORDER-RIGHT: #f7f7e7 1px solid;}');
		htp.p('.OraTableTotalNumber {BACKGROUND-COLOR: #cccc99; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt; FONT-WEIGHT: bold; TEXT-ALIGN: right; VERTICAL-ALIGN: baseline; BORDER-BOTTOM: #f7f7e7 1px solid;');
                htp.p(' BORDER-RIGHT:');
                htp.p(' #f7f7e7 1px solid;}');
		htp.p('.OraTableTotalText {BACKGROUND-COLOR: #cccc99; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt; FONT-WEIGHT: bold; TEXT-ALIGN: left; VERTICAL-ALIGN: baseline; BORDER-BOTTOM: #f7f7e7 1px solid; BORDER-RIGHT:');
                htp.p(' #f7f7e7 1px solid;}');
		htp.p('.OraTableCellText {BACKGROUND-COLOR: #f7f7e7; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt; BORDER-BOTTOM: #cccc99 1px solid; BORDER-RIGHT: #cccc99 1px solid;}');
		htp.p('.OraTableCellTextBand {BACKGROUND-COLOR: #ffffff; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt;  BORDER-BOTTOM: #cccc99 1px solid; BORDER-RIGHT: #cccc99 1px solid;}');
		htp.p('.OraTableCellNumber {BACKGROUND-COLOR: #f7f7e7; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt; TEXT-ALIGN: right;  BORDER-BOTTOM: #cccc99 1px solid; BORDER-RIGHT: #cccc99 1px solid;}');
		htp.p('.OraTableCellNumberBand {BACKGROUND-COLOR: #ffffff; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt; TEXT-ALIGN: right;  BORDER-BOTTOM: #cccc99 1px solid; BORDER-RIGHT: #cccc99 1px solid;}');
		htp.p('.OraTableCellIconButton {BACKGROUND-COLOR: #f7f7e7; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt; TEXT-ALIGN: center;  BORDER-BOTTOM: #cccc99 1px solid; BORDER-RIGHT: #cccc99 1px solid;}');
		htp.p('.OraTableCellIconButtonBand {BACKGROUND-COLOR: #ffffff; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt; TEXT-ALIGN: center;  BORDER-BOTTOM: #cccc99 1px solid; BORDER-RIGHT: #cccc99 1px solid;}');
		htp.p('.OraTableCellSelect {BACKGROUND-COLOR: #f7f7e7; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt; TEXT-ALIGN: center; BORDER-BOTTOM: #cccc99 1px solid; BORDER-RIGHT: #cccc99 1px solid;}');
		htp.p('.OraTableCellSelectBand {BACKGROUND-COLOR: #ffffff; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt; TEXT-ALIGN: center; BORDER-BOTTOM: #cccc99 1px solid; BORDER-RIGHT: #cccc99 1px solid;}');
		htp.p('.OraTableVerticalGrid {BACKGROUND-COLOR: #cccc99; WIDTH: 1px}');
		htp.p('.OraTableVerticalHeaderGrid {BACKGROUND-COLOR: #f7f7e7; WIDTH: 1px}');
		htp.p('.OraTableHorizontalGrid {BACKGROUND-COLOR: #cccc99; WIDTH: 1px}');
		htp.p('.OraTableHorizontalHeaderGrid {BACKGROUND-COLOR: #f7f7e7; WIDTH: 1px}');
		htp.p('.OraTableShadowHeaderGrid {BACKGROUND-COLOR: #666633; WIDTH: 1px}');
		htp.p('.OraTableHeaderLink {BACKGROUND-COLOR: #cccc99; COLOR: #336699; FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt; FONT-WEIGHT: bold; TEXT-DECORATION: none; }');
		htp.p('.OraTableAddTotal {font-family:Arial,Helvetica,Geneva,sans-serif;font-size:9pt;font-weight:bold;text-align:left;background-color:#cccc99;color:#336699;padding-top:2px;BORDER-BOTTOM: #f7f7e7 1px solid;BORDER-RIGHT: #f7f7e7 1px solid;}');
		htp.p('.OraTableSortableColumnName {BACKGROUND-COLOR: #cccc99; COLOR: #336699; CURSOR: hand; FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt; FONT-WEIGHT: bold; TEXT-ALIGN: left; TEXT-DECORATION: none; }');
		-- 08/03/2001 - Added new tag for Right justified headers
		htp.p('.OraTableSortableColumnNameNumber {BACKGROUND-COLOR: #cccc99; COLOR: #336699; CURSOR: hand; FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt; FONT-WEIGHT: bold; TEXT-ALIGN: right; TEXT-DECORATION: none; }');
		htp.p('.OraTableColumnHeaderNumber {BACKGROUND-COLOR: #cccc99; COLOR: #336699; FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt; FONT-WEIGHT: bold; TEXT-ALIGN: right; BORDER-BOTTOM: #f7f7e7 1px solid; BORDER-RIGHT:');
                htp.p(' #f7f7e7 1px solid;}');
		htp.p('.OraHeader {COLOR: #336699; FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 16pt}');
		htp.p('.OraInstructionText {COLOR: #000000; FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt}');
		htp.p('.OraInstructionTextStrong {COLOR: #000000; FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt; FONT-WEIGHT: bold}');
		htp.p('.OraTableSortableColumnSpan {BACKGROUND-COLOR: #cccc99; COLOR: #336699; CURSOR: hand; FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt; FONT-WEIGHT: bold; TEXT-ALIGN: center; TEXT-DECORATION: none; }');
		htp.p('.OraTableColumnHeaderSpan {BACKGROUND-COLOR: #cccc99; COLOR: #336699; FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt; FONT-WEIGHT: bold; TEXT-ALIGN: center;  BORDER-BOTTOM: #f7f7e7 1px solid; BORDER-RIGHT:');
                htp.p(' #f7f7e7 1px solid;}');

		htp.p('</STYLE>');

end setTableStyles;

-- nbarik - 05/15/04 - Enhancement 3576963 - Drill Java Conversion
PROCEDURE VIEW_REPORT_FROM_PORTLET(
        pRegionCode IN VARCHAR2
      , pFunctionName IN VARCHAR2
      , pScheduleId  IN NUMBER
      , pPageId IN VARCHAR2 DEFAULT NULL
      , pObjectType IN VARCHAR2 DEFAULT NULL
      , pResponsibilityId IN VARCHAR2 DEFAULT NULL
) IS
l_jsp_params        VARCHAR2(5000);
l_session_id        VARCHAR2(80);
l_resp_id           varchar2(80);
l_user_id           varchar2(80);
l_application_id 	NUMBER;
l_function_id       NUMBER;

CURSOR cFndResp (pRespId IN VARCHAR2) IS
SELECT application_id
FROM fnd_responsibility
WHERE responsibility_id = pRespId;

BEGIN
  IF NOT icx_sec.ValidateSession THEN
      RETURN;
  END IF;

  l_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);
  l_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
  l_resp_id := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);

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

  l_jsp_params := 'pMode=7&pRegionCode=' || BIS_PMV_UTIL.encode(pRegionCode) || '&pFunction=' || BIS_PMV_UTIL.encode(pFunctionName) || '&pScheduleId=' || pScheduleId;
  IF (pPageId IS NOT NULL) THEN
    l_jsp_params := l_jsp_params || '&pPageId=' || pPageId;
  END IF;
  IF (pObjectType IS NOT NULL) THEN
    l_jsp_params := l_jsp_params || '&pObjectType=' || pObjectType;
  END IF;
  IF (pResponsibilityId IS NOT NULL) THEN
    l_jsp_params := l_jsp_params || '&pResponsibilityId=' || pResponsibilityId;
  END IF;

 OracleApps.runFunction (
                     c_function_id => l_function_id
                   , n_session_id => l_session_id
                   , c_parameters => l_jsp_params
                   , p_resp_appl_id => l_application_id
                   , p_responsibility_id => l_resp_id
                   , p_Security_group_id => icx_sec.g_security_group_id
                 );

EXCEPTION
  WHEN OTHERS THEN
	  IF cFNDResp%ISOPEN THEN
	   CLOSE cFNDResp;
	  END IF;

END VIEW_REPORT_FROM_PORTLET;

/*
-- mdamle 11/7/2002 - Added pEnableForecastGraph
PROCEDURE VIEW_REPORT_FROM_PORTLET(pRegionCode in varchar2, pFunctionName in varchar2, pScheduleId  in number,
      pPageId IN VARCHAR2 default null,
      pObjectType IN VARCHAR2 DEFAULT NULL,
      pResponsibilityId IN VARCHAR2 DEFAULT NULL) is
  CURSOR c_sched_attr IS
  SELECT SESSION_VALUE,
         SESSION_DESCRIPTION,
         DEFAULT_VALUE,
         DEFAULT_DESCRIPTION,
         ATTRIBUTE_NAME,
         DIMENSION,
         PERIOD_DATE
  FROM   bis_user_attributes
  WHERE  schedule_id = pScheduleId;


    CURSOR c_pageless_sched_attr(pUserId In VARCHAR2) IS
  SELECT SESSION_VALUE,
         SESSION_DESCRIPTION,
         DEFAULT_VALUE,
         DEFAULT_DESCRIPTION,
         ATTRIBUTE_NAME,
         DIMENSION,
         PERIOD_DATE
  FROM   bis_user_attributes
  WHERE  schedule_id = pScheduleId
  AND    ((dimension IS NULL AND attribute_name not in (SELECT nvl(attribute_name,'-11')
                                                       FROM   BIS_USER_ATTRIBUTES
                                                       WHERE  page_id=pPageId
                                                       AND    user_id=pUserId))
      OR (dimension IS NOT NULL AND dimension not in (SELECT nvl(dimension,'-11')
                                                      FROM   BIS_USER_ATTRIBUTES
                                                      WHERE  page_id=pPageId
                                                      AND    user_id=pUserId)));


  CURSOR cFunctionParams (pFunctionName in varchar) is
  select parameters
  from fnd_form_functions
  where function_name = pFunctionName;

  --BugFix 2869306
  CURSOR cPageTimeParams (cPageId varchar2, cUserId varchar2) is
           select attribute_name
          from   bis_user_attributes
          where user_id = cUserId
          and  page_id = cPageId
          and  dimension in ('TIME', 'EDW_TIME_M')
          and substr(attribute_name, length(attribute_name)-length('_FROM')+1) = '_FROM';

  --ksadagop BugFix 3265474
  CURSOR cNonViewBy (cRegionCode varchar2, cSessionValue varchar2) is
           select attribute2 from ak_region_items where region_code=cRegionCode and
	   attribute2=cSessionValue
      AND  attribute1 not in ('DIMENSION LEVEL', 'DIM LEVEL SINGLE VALUE', 'HIDE DIMENSION LEVEL');

  vUserid varchar2(80);
  vSessionId varchar2(80);
  vResponsibilityId varchar2(80);
  vEnableForecastGraph varchar2(1);
  vParameters fnd_form_functions.parameters%TYPE;

   -- jprabhud - 01/27/03 - Enh 2485974 Custom Views
  vTitleCustomView fnd_form_functions.function_name%TYPE;
  vReportFunctionName fnd_form_functions.function_name%TYPE;
  vCustomView fnd_form_functions.function_name%TYPE;
  vViewName fnd_form_functions.function_name%TYPE;
  vFunctionName fnd_form_functions.function_name%TYPE;
  vReportFunctionParameters fnd_form_functions.parameters%TYPE;
  vRegionCode varchar2(300); --rcmuthuk 03/24/03 Bug#2856247
  vSessionValue varchar2(240);
  vSessionDesc  varchar2(240);
  --ksadagop BugFix 3265474
  vViewBy  varchar2(300);
  vAttribute2 varchar2(300);
  l_flag varchar2(1) := 'Y';


BEGIN    -- validate session

   if not icx_sec.ValidateSession then
      return;
   end if;

   vSessionId := icx_sec.getID(icx_sec.PV_SESSION_ID);
   vUserId := icx_sec.getID(icx_sec.PV_WEB_USER_ID);

   -- mdamle 11/07/2002 - Pass pEnableForecastGraph if needed.
   if cFunctionParams%ISOPEN then
       	CLOSE cFunctionParams;
   end if;
   OPEN cFunctionParams(pFunctionName);
   FETCH cFunctionParams INTO vParameters;
   CLOSE cFunctionParams;

   if vParameters is not null then
	vEnableForecastGraph := BIS_PMV_UTIL.getParameterValue(vParameters, 'pEnableForecastGraph');
	-- jprabhud - 01/27/03 - Enh 2485974 Custom Views
        vTitleCustomView := BIS_PMV_UTIL.getParameterValue(vParameters, 'pTitleCustomView');

        vReportFunctionName := BIS_PMV_UTIL.getParameterValue(vParameters, 'pReportFunctionName');
   end if;

   -- jprabhud - 01/27/03 - Enh 2485974 Custom Views
   if vTitleCustomView is null then
     if vReportFunctionName is not null then
       if cFunctionParams%ISOPEN then
       	 CLOSE cFunctionParams;
       end if;
       OPEN cFunctionParams(vReportFunctionName);
       FETCH cFunctionParams INTO vReportFunctionParameters;
       CLOSE cFunctionParams;
     end if;
   end if;

   if vReportFunctionParameters is not null then
        vCustomView := BIS_PMV_UTIL.getParameterValue(vReportFunctionParameters, 'pCustomView');
        vRegionCode := BIS_PMV_UTIL.getParameterValue(vReportFunctionParameters, 'pRegionCode'); --rcmuthuk 03/24/03 Bug#2856247
   end if;

   -- rcmuthuk - 03/24/03 Bug#2856247
   if vRegionCode is null then
     vRegionCode := pRegionCode;
   end if;

   -- jprabhud - 01/27/03 - Enh 2485974 Custom Views
   if vReportFunctionName is not null then
     vFunctionName := vReportFunctionName;
   else
     vFunctionName := pFunctionName;
   end if;

   -- jprabhud - 01/27/03 - Enh 2485974 Custom Views
   if vTitleCustomView is not null then
     vViewName := vTitleCustomView;
   else
     vViewName := vCustomView;
   end if;

   IF pResponsibilityId IS NOT NULL THEN
      vResponsibilityId := pResponsibilityId;
   ELSE
    BEGIN
      SELECT responsibility_id
      INTO   vResponsibilityId
      FROM   bis_scheduler
      WHERE  schedule_Id = pScheduleId;
    EXCEPTION
    WHEN OTHERS THEN
        NULL;
    END;
   END IF;


   delete from bis_user_attributes
   where  user_id = vUserId
   and    function_name = vFunctionName -- jprabhud - 01/27/03 - Enh 2485974 Custom Views
   and    session_id = vSessionId
   and    schedule_id is null;

   if (pPageId is not null) then
      -- copy the page level paramters
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
      SELECT
         vUserId,
         vFunctionName,-- jprabhud - 01/27/03 - Enh 2485974 Custom Views
         vSessionId,
         SESSION_VALUE,
         SESSION_DESCRIPTION,
         DEFAULT_VALUE,
         DEFAULT_DESCRIPTION,
         ATTRIBUTE_NAME,
         DIMENSION,
         PERIOD_DATE
      FROM   bis_user_attributes
      WHERE  user_id = vUserId
      AND page_id =pPageId;

       for c_rec in c_pageLess_sched_attr(vUserId) loop
          vSessionValue := c_rec.SESSION_VALUE;
          vSessionDesc  := c_rec.SESSION_DESCRIPTION;
		  l_flag := 'Y';
          --BugFix 2869306
          if c_rec.ATTRIBUTE_NAME = 'VIEW_BY' then --BugFix 3281530.
			--ksadagop BugFix 3265474
			if cNonViewBy%ISOPEN then
			CLOSE cNonViewBy;
			end if;
			OPEN  cNonViewBy(vRegionCode, c_rec.SESSION_VALUE);
			FETCH cNonViewBy INTO vAttribute2;
			CLOSE cNonViewBy;
			if vAttribute2 is null then
				if (substr(c_rec.SESSION_VALUE, 1, length('TIME+')) = 'TIME+'
					or substr(c_rec.SESSION_VALUE,1, length('EDW_TIME_M+')) = 'EDW_TIME_M+') then --BugFix 3281530.
					if cPageTimeParams%ISOPEN then
					CLOSE cPageTimeParams;
					end if;
					OPEN  cPageTimeParams(pPageId, vUserId);
					FETCH cPageTimeParams INTO vSessionValue;
					CLOSE cPageTimeParams;
					if vSessionValue is null then
						vSessionValue := c_rec.SESSION_VALUE;
						vSessionDesc  := c_rec.SESSION_DESCRIPTION;
					else
						vSessionValue := substr(vSessionValue,1, length(vSessionValue)-length('_FROM'));
						vSessionDesc  := vSessionValue;
					end if;
				end if;
			else
				l_flag := 'N';
			end if;
          end if;
	  if(l_flag = 'Y') then   --BugFix 3281530.
        insert into bis_user_attributes (USER_ID,
         FUNCTION_NAME,
         SESSION_ID,
         SESSION_VALUE,
         SESSION_DESCRIPTION,
         DEFAULT_VALUE,
         DEFAULT_DESCRIPTION,
         ATTRIBUTE_NAME,
         DIMENSION,
         PERIOD_DATE) values (vUserId,
         vFunctionName, -- jprabhud - 01/27/03 - Enh 2485974 Custom Views
         vSessionId,
         vSessionValue,
         vSessionDesc,
         c_rec.DEFAULT_VALUE,
         c_rec.DEFAULT_DESCRIPTION,
         c_rec.ATTRIBUTE_NAME,
         c_rec.DIMENSION,
         c_rec.PERIOD_DATE);
  	  end if;
     end loop;

   else
     for c_rec in c_sched_attr loop
        insert into bis_user_attributes (USER_ID,
         FUNCTION_NAME,
         SESSION_ID,
         SESSION_VALUE,
         SESSION_DESCRIPTION,
         DEFAULT_VALUE,
         DEFAULT_DESCRIPTION,
         ATTRIBUTE_NAME,
         DIMENSION,
         PERIOD_DATE) values (vUserId,
         vFunctionName, -- jprabhud - 01/27/03 - Enh 2485974 Custom Views
         vSessionId,
         c_rec.SESSION_VALUE,
         c_rec.SESSION_DESCRIPTION,
         c_rec.DEFAULT_VALUE,
         c_rec.DEFAULT_DESCRIPTION,
         c_rec.ATTRIBUTE_NAME,
         c_rec.DIMENSION,
         c_rec.PERIOD_DATE);
     end loop;
     commit;
   end if;



   bisviewer.showReport(pRegionCode=>vRegionCode
               , pFunctionName=> vFunctionName -- jprabhud - 01/27/03 - Enh 2485974 Custom Views
               , pSessionId=>vSessionId
               , pUserId=>vUserId
               , pResponsibilityId=>vResponsibilityId
               , pFirstTime=>0
               , pMode=>'DrillDown'
	       , pEnableForecastGraph=>vEnableForecastGraph
	       , pCustomView=>vViewName -- jprabhud - 01/27/03 - Enh 2485974 Custom Views
               , pObjectType => pObjectType  --Bug Fix 2997706
               );

END VIEW_REPORT_FROM_PORTLET;
*/

-- 08/16/2001 - Show Portlet Status
procedure showPortletStatus(p_report_available number, last_upd date) is
l_icx_date_format VARCHAR2(30);
begin
	htp.p('<STYLE TYPE="text/css">');
	-- mdamle 08/09/01 - Added border tag
	-- mdamle 12/20/01 - Remove background color from last upd date
	-- background-color:#cccc99;
       	htp.p('.OraPortletHeaderSub {font-family:Arial, Helvetica, Geneva, sans-serif; font-size:8pt;
		text-align:right; color:#000000; vertical-align:baseline; BORDER-BOTTOM: #f7f7e7 1px solid;'||
		'BORDER-RIGHT: #f7f7e7 1px solid;}');
        htp.p('</STYLE>');

	htp.p('<table width="100%" border="0" cellspacing="0" cellpadding="0">');

	-- mdamle 08/16/01 - Add a retrieving portlet message
	if p_report_available = 0 then
		-- Add the retrieving portlet message
/*
		htp.p('
                <tr>
                  <td width="40" align="center"><img src="'||gvImageDirectory||'bisprocg.gif" width="32" height="32"></td>
                  <td nowrap class="OraHeader" valign=bottom>'||FND_MESSAGE.get_string('BIS','BIS_PROCESSING_PORTLET_HDR')||'</td>
                </tr>');
		htp.p('
		<TR>
		  <td valign="top" width="40" align="center" height="1"><img src="'||gvImageDirectory||'bisspace.gif" height=1 width=10></td><TD bgcolor="#CCCC99" height="1"><IMG SRC="http://ap100jvm.us.oracle.com:8700/OA_MEDIA/bisspace.gif" height=1 width=1></TD>
		</TR>');
		htp.p('
                <tr>
                  <td valign="top" width="40" align="center" height="5"><img src="'||gvImageDirectory||'bisspace.gif" height=1 width=10></td>
                  <td class="OraInstructionText" height="5"><img src="'||gvImageDirectory||'bisspace.gif" height=1 width=10></td>
                </tr>');
*/
		htp.p('
                <tr>
                  <td valign="top" width="40" align="center">&nbsp;</td>
                  <td class="OraInstructionText">
                    <p><b> </b><span class="OraInstructionTextStrong">'||FND_MESSAGE.get_string('BIS','BIS_PROCESSING_PORTLET_DETAIL')||'</span></p>
                  </td>
                </tr>');

	else
		-- Add last update date
          l_icx_date_format := fnd_profile.value('ICX_DATE_FORMAT_MASK'); --Bug Fix 1917856 Use ICX Date Format
          IF l_icx_date_format IS NOT NULL THEN
     	    htp.p('<tr><td class=OraPortletHeaderSub >' ||TO_CHAR(last_upd,l_icx_date_format)||'</td></tr>');
          ELSE
            htp.p('<tr><td class=OraPortletHeaderSub >'
	              ||TO_CHAR(last_upd,'dd-Mon')
                      ||'</td></tr>');
          END IF;
	end if;

	htp.p('</table>');

end showPortletStatus;

-- mdamle 10/30/01 - Converted plsql customize page to jsp
-- mdamle 11/1/2002 - Bug#2649477 - Support for ICX Patch
--PortletPersonalization: added pShowPortletSettings parameter -ansingh
procedure customizePortlet (	 pResponsibilityId	IN	VARCHAR2 default NULL
				,pSessionId	IN	VARCHAR2 default NULL
				,Region_Code  	IN	VARCHAR2 default NULL
				,Function_Name	IN	VARCHAR2 default NULL
				,pUserId 	IN	VARCHAR2 default NULL
				,pPlugId 	IN	VARCHAR2 default NULL
				,pScheduleId 	IN	VARCHAR2 default NULL
				,pFileId 	IN	VARCHAR2 default NULL
				,pScheduleOverride IN   VARCHAR2 default 'N'
                                ,pShowPortletSettings IN VARCHAR2 DEFAULT NULL
                                ,pMsrId IN VARCHAR2 DEFAULT NULL
                                ,pComponentType IN VARCHAR2 DEFAULT NULL
				,pIsPrintable IN VARCHAR2 DEFAULT NULL
				,pReturnURL IN VARCHAR2 DEFAULT NULL
) IS

vPageFunctionId 		NUMBER;
vPageURL			varchar2(2000);

vParams                         varchar2(2000);
vRespId                         varchar2(80);
vApplicationId                  varchar2(80);
vSecGrpId	                varchar2(80);
vUserId				varchar2(80);
vSessionId			number;

begin

  	if not (icx_sec.validatesession)  then
     		return;
  	end if;

	vSessionId := icx_sec.getid(ICX_SEC.PV_SESSION_ID);
	vUserId := icx_sec.getID(icx_sec.PV_USER_ID,'',vSessionId);

	begin
        	select function_id into vPageFunctionId
        	from fnd_form_functions
        	where function_name = 'BIS_CUSTOMIZE_PORTLET_PAGE';
        exception
		when others then vPageFunctionId := null;
        end;

     	vRespId := nvl(pResponsibilityId, icx_sec.getid(ICX_SEC.PV_RESPONSIBILITY_ID));
     	getRespInfo(vUserId, vRespId, vApplicationId, vSecGrpId);

	icx_sec.updateSessionContext(function_name, null, vApplicationId, vRespId, vSecGrpId, vSessionId, null);

	if vPageFunctionId is not null then

  vParams := 'regionCode='||Region_Code||
             '&functionName='||function_name||
             '&pResponsibilityId='||vRespId||
             '&pUserId='||pUserId||
             '&pSessionId='||pSessionId||
             '&pPlugId='||pPlugId||
             '&pScheduleId='||pScheduleId||
             '&pFileId='||pFileId||
             '&pScheduleOverride='||pScheduleOverride||
	     '&pShowPortletSettings='||pShowPortletSettings||
             '&pComponentType='||pComponentType||
             '&pMsrId='||pMsrId||
						 '&pIsPrintable='||pIsPrintable||
             '&pReturnURL='||NVL(bis_pmv_util.encode(pReturnURL), '');


  OracleApps.runFunction(c_function_id => vPageFunctionId
                        ,n_session_id => pSessionId
                        ,c_parameters => vParams
                        ,p_resp_appl_id => vApplicationId
                        ,p_responsibility_id => vRespId
                        ,p_Security_group_id => vSecGrpId
                        );

	end if;


end customizePortlet;


PROCEDURE initialiseRLPortlet (
    pUserID IN NUMBER,
    pReferencePath IN VARCHAR2,
    x_plug_id OUT NOCOPY NUMBER
)
IS

--l_plug_id NUMBER;
l_responsibility_id NUMBER;
lReturnStatus VARCHAR(1);
lMsgData VARCHAR2(10);
lMsgCount NUMBER;
lScheduleId NUMBER;
lFileId NUMBER;
lTitle VARCHAR2(240);
BEGIN

      l_responsibility_id := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);

			SELECT icx_page_plugs_s.nextval INTO x_Plug_Id FROM DUAL;

 -- bug 2842902 - removed user_id from where clause
	UPDATE icx_portlet_customizations
	SET plug_id = x_Plug_Id,
--		title=lTitle,
		caching_key = TO_CHAR(TO_NUMBER(NVL(caching_key,'0'))+1)
	WHERE 	reference_path = pReferencePath ;

   --   commit;
END initialiseRLPortlet;

-- mdamle 10/29/2002 Bug#2560743 - Use previous page parameters for linked page
procedure invokeBISRunFunction
(function_id           in number
,pFunctionName         in VARCHAR2
,pWebHtmlCall          IN VARCHAR2
,user_id               in varchar2 default null
,responsibility_id     in varchar2 default null
,responsibility_app_id in varchar2 default null
,session_id            in varchar2 default null
,sec_grp_id            in varchar2 default null
-- jprabhud 03/04/2003 - Refresh Portal Page
,pSourcePageId 	       in number default -1
,pParameters             IN VARCHAR2 DEFAULT NULL

)
IS

    l_resp_id		varchar2(80);
    l_resp_app_id	varchar2(80);
    l_user_id           varchar2(80);
    l_sec_grp_id           varchar2(80);
    -- jprabhud 03/04/2003 - Refresh Portal Page
    jspParams		varchar2(32767);

BEGIN

  if not (icx_sec.validatesession)  then
     return;
  end if;


  l_user_id := icx_sec.getID(icx_sec.PV_USER_ID,'',icx_sec.getid(ICX_SEC.PV_SESSION_ID));

  if responsibility_id is not null then
	l_resp_id := responsibility_id;
	if responsibility_app_id is not null then
		l_resp_app_id := responsibility_app_id;
       	end if;
	if sec_grp_id is not null then
		l_sec_grp_id := sec_grp_id;
	end if;
  end if;

  if l_resp_id is null then
	l_resp_id := icx_sec.getid(ICX_SEC.PV_RESPONSIBILITY_ID);
  end if;

  if l_resp_app_id is null or l_sec_grp_id is null then
	getRespInfo(l_user_id, l_resp_id, l_resp_app_id,l_sec_grp_id);
  end if;

  jspParams := pParameters;
  if instr(pWebHtmlCall,'BIS_COMPONENT_PAGE')>0 then
     IF (jspParams IS NOT NULL) THEN
      jspParams := jspParams || '&';
     END IF;
     --nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
     --jspParams := 'functionName='||pFunctionName;
     jspParams := jspParams || 'functionName='||pFunctionName;
  end if;

  --jprabhud - 09/15/03 Toggle View Log -- added BIS_PMV_TOGGLE_VIEWLOG
  --jprabhud - 09/17/03 Toggle Perf View Log -- added BIS_PMV_TOGGLE_VIEWLOG_PERF
  --ksadagop - 12/02/03 Invalidate Fnd Cache -- added BIS_PMV_INVALIDATE_FNDCACHE
  if pFunctionName = 'BIS_PMV_PORTAL_REFRESH' or pFunctionName = 'BIS_PMV_INVALIDATE_AKCACHE'
    or pFunctionName ='BIS_PMV_TOGGLE_VIEWLOG' or pFunctionName ='BIS_PMV_TOGGLE_VIEWLOG_PERF'  or pFunctionName = 'BIS_PMV_INVALIDATE_FNDCACHE' then
     if jspParams is not null then
        jspParams := jspParams || '&';
     end if;
     jspParams := jspParams||'pSourcePageId='||pSourcePageId;
  end if;

/* aleung, comment out for bug 3113469 & bug 3088087
  -- jprabhud 03/04/2003 - Refresh Portal Page
  l_function_name := getFunctionName(function_id);
  -- jprabhud 06/13/2003 - enh 2999555 Invalidate Ak Cache
  -- nbarik - 08/11/03 - Bug 3088087 - Move this inside if condition
  -- jspParams := 'functionName='||l_function_name;
  if l_function_name = 'BIS_PMV_PORTAL_REFRESH' or l_function_name = 'BIS_PMV_INVALIDATE_AKCACHE' then
     jspParams := 'functionName='||l_function_name||'&pSourcePageId='||pSourcePageId;
     --jspParams := '&pSourcePageId='||pSourcePageId;
  end if;
*/

  --jprabhud - 11/13/03 - Bug 3253597
  BIS_PMV_UTIL.bis_run_function( l_resp_app_id,
               l_resp_id,
               l_sec_grp_id ,
               function_id ,
               jspParams );
  /*
  OracleApps.runFunction(c_function_id => function_id
                        ,n_session_id => icx_sec.getid(ICX_SEC.PV_SESSION_ID)
                        -- jprabhud 03/04/2003 - Refresh Portal Page
                        ,c_parameters => jspParams
                        ,p_resp_appl_id => l_resp_app_id
                        ,p_responsibility_id => l_resp_id
                        ,p_Security_group_id => l_sec_grp_id
                        );
   */
END;

-- mdamle 10/29/2002 Bug#2560743 - Use previous page parameters for linked page
procedure invokeRFFunction
(function_id           in number
,user_id               in varchar2 default null
,responsibility_id     in varchar2 default null
,responsibility_app_id in varchar2 default null
,session_id            in varchar2 default null
,sec_grp_id            in varchar2 default null
-- jprabhud 03/04/2003 - Refresh Portal Page
,pSourcePageId 	       in number default -1
,pDrillDefaultParameters IN VARCHAR2 DEFAULT NULL
)
IS
    CURSOR cFunction (pFunctionId in number) is
    select function_name, web_html_call
    from fnd_form_functions
    where function_id = pFunctionId;

    l_function_name     fnd_form_functions.function_name%TYPE;
    lwebhtmlcall     varchar2(2000);
BEGIN
  --aleung, fix for bug 3113469 & bug 3088087
  if cFunction%ISOPEN then
     CLOSE cFunction;
  end if;
  OPEN cFunction(function_id);
     FETCH cFunction INTO l_function_name,lwebhtmlcall;
  CLOSE cFunction;

  invokeBISRunFunction
    (function_id
    ,l_function_name
    ,lwebhtmlcall
    ,user_id
    ,responsibility_id
    ,responsibility_app_id
    ,session_id
    ,sec_grp_id
    -- jprabhud 03/04/2003 - Refresh Portal Page
    ,pSourcePageId
    --nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
    --,null
    , pDrillDefaultParameters
    );

END invokeRFFunction;

--serao -08/30/2002- for user_customizations of the related link portlet-bug 2532340

PROCEDURE checkUsercustomizeRLPortlet (
  pUserId In NUMBER,
  pPlugId IN NUMBER,
  xCustomised OUT NOCOPY NUMBER
) IS

lUserId NUMBER;

CURSOR userRowInBisScheduler IS
 SELECT user_id
 FROM bis_schedule_preferences
 WHERE plug_id=pPlugId
 AND user_id =to_char(pUserId);

BEGIN

  xCustomised := 0;

  -- validate session ?
 -- first check if this user has customized the portlet
  if userRowInBisScheduler%ISOPEN then
    close userRowInBisScheduler;
  end if;
  open userRowInBisScheduler();
  fetch userRowInBisScheduler into lUserId;
  close userRowInBisScheduler;

  IF lUserID IS NOT NULL THEN
    xCustomised := 1;
  END IF;

END checkUsercustomizeRLPortlet ;


PROCEDURE createUserCustPlugRecord (
  pFunctionName IN VARCHAR2,
  pUserId In NUMBER,
  pPlugId IN NUMBER
) IS

l_responsibility_id NUMBER;
lScheduleId NUMBER;
lFileId NUMBER;
lReturnStatus VARCHAR(1);
lMsgData VARCHAR2(10);
lMsgCount NUMBER;

BEGIN

  -- validate sessionx
  l_responsibility_id := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);
   -- add  row in the bis_scheduler preferences table
    BIS_RG_SCHEDULES_PVT.CREATE_SCHEDULE_NO_COMMIT (
				p_plug_id => pPlugId,
				p_user_id => pUserId,
				p_function_name => pFunctionName,
				p_responsibility_id =>l_Responsibility_Id,
				x_schedule_id => lScheduleId,
				x_file_id => lFileId,
				x_return_status =>lReturnStatus,
				x_msg_data => lMsgData,
				x_msg_count => lMsgCount,
				p_live_portlet => 'Y'
			);

END createUserCustPlugRecord;

-- mdamle 11/1/2002 - Bug#2649477 - Support for ICX Patch
procedure getRespInfo(	pUserId 	in number
		      , pRespId		in number
		      , pRespAppId 	out NOCOPY number
		      , pSecGrpId       out NOCOPY number) is

CURSOR cUserResp (pUserId in number, pRespId in number) is
select responsibility_application_id, security_group_id
from fnd_user_resp_groups
where user_id = pUserId
and responsibility_id = pRespId
and rownum = 1;

begin

     if cUserResp%ISOPEN then
        CLOSE cUserResp;
     end if;
     OPEN cUserResp(pUserId, pRespId);
     FETCH cUserResp INTO pRespAppId, pSecGrpId;
     CLOSE cUserResp;

end getRespInfo;

-- mdamle 11/1/2002 - Bug#2649477 - Support for ICX Patch
function getFunctionId (pFunctionName varchar2) return number is

CURSOR cFunction (pFunctionName in varchar2) is
select function_id
from fnd_form_functions
where function_name = pFunctionName;

l_function_id 	number;
begin

	if cFunction%ISOPEN then
        	CLOSE cFunction;
	end if;
	OPEN cFunction(pFunctionName);
     	FETCH cFunction INTO l_function_id;
     	CLOSE cFunction;

	return l_function_id;

end getFunctionId;

--BugFix 3417356
FUNCTION getPageIdFromFunctionId (
 pPageFunctionId IN NUMBER
) RETURN NUMBER
IS
lDestPageId	number;

BEGIN
  lDestPageId := 0 - pPageFunctionId;
  RETURN lDestPageId;

END getPageIdFromFunctionId;

/*
FUNCTION getPageIdFromFunctionId (
 pPageFunctionId IN NUMBER
) RETURN NUMBER
IS

CURSOR cPageInfo (pFunctionId in number) is
select parameters, web_html_call
from fnd_form_functions
where function_id = pFunctionId;

cursor cMenuInfo (pMenuName varchar2) IS
select menu_id
from fnd_menus
where menu_name=pMenuName;

lParameters	fnd_form_functions.parameters%TYPE;
lPageName 	varchar2(240);
lDestPageId	number;
lMenuName        varchar2(2000);
lwebhtmlcall     varchar2(2000);
lSourceType      varchar2(80);

BEGIN

	if cPageInfo%ISOPEN then
        	CLOSE cPageInfo;
	end if;

     	OPEN cPageInfo(pPageFunctionId);
     	FETCH cPageInfo INTO lParameters,lwebhtmlcall;
     	CLOSE cPageInfo;

	if lParameters is not null then
		lPageName := BIS_PMV_UTIL.getParameterValue(upper(lParameters), 'PAGENAME');
		lSourceType := BIS_PMV_UTIL.getParameterValue(upper(lParameters), 'SOURCETYPE');

		if (lPageName is not null and lSourceType is null) then
			lDestPageId := BIS_PMV_UTIL.getPortalPageId(lPageName);
        	else
                  if lPageName is not null then
                     lMenuName := lPageName;
                  else
                     lMenuName := BIS_PMV_UTIL.getParameterValue(upper(lwebhtmlcall),'PAGENAME');
                  end if;

                if (lMenuName is not null) then
                    if cMenuInfo%ISOPEN then
                        CLOSE cMenuInfo;
                    end if;
                    begin
                        OPEN cMenuInfo(lMenuName);
                        FETCH cMenuInfo into ldestPageId;
                        CLOSE cMenuInfo;
                    exception when others then null;
                    end;
                    if (ldestpageid is not null) then
                       ldestpageid := 0-ldestpageid;
                    end if;

                end if;
              end if;
        end if;

   -- Fix for P1 2962792 : kiprabha
   -- Moved the RETURN out of the IF condition
   RETURN lDestPageId;
END getPageIdFromFunctionId;
*/

PROCEDURE processLinkedPage(
         pSourcePageId 	 	in varchar2
				,pDestFunctionId 	in number
        ,pSessionId IN VARCHAR2
        ,pUserId IN NUMBER
        ,xParamRegionCode OUT NOCOPY VARCHAR2
        ,xParamFunctionName OUT NOCOPY VARCHAR2
        , xParamGroup  OUT NOCOPY BIS_PMV_PARAMETERS_PVT.parameter_group_tbl_type
        , xSourcePageId OUT NOCOPY NUMBER
        , xDestPageId OUT NOCOPY NUMBER
        -- nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
        , x_DrillDefaultParameters OUT NOCOPY VARCHAR2
) IS
CURSOR cPageInfo (pFunctionId in number) is
select parameters
from fnd_form_functions
where function_id = pFunctionId;


lParameters	fnd_form_functions.parameters%TYPE;
lPageName 	varchar2(240);

x_return_status varchar2(80);
x_msg_count     number;
x_msg_data      varchar2(80);

--jprabhud 11/13/03 - Bug 3253597
n number := 0;
BEGIN

    xDestPageId := getPageIdFromFunctionId(pDestFunctionId);

    --jprabhud 11/13/03 - Bug 3253597 - check if srcPageId has a comma(,) in it
    n := instr(pSourcePageId, ',');
    if n <= 0 then
     --jprabhud 11/13/03 - Bug 3253597
        xSourcePageId := pSourcePageId;
  		-- If PageId is not null, then copy parameters from source page to dest page
	  	if xDestPageId is not null then
                        --serao - 04/03, added sessionId
		  	BIS_PMV_PARAMETERS_PVT.copyParamtersBetweenPages(
                                         pSessionId,
             --jprabhud 11/13/03 - Bug 3253597
			  		 xSourcePageId,
				  	 xDestPageId,
					   pUserId,
             xParamRegionCode ,
             xParamFunctionName ,
             xParamGroup ,
             -- nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
             x_DrillDefaultParameters,
  					 x_return_status,
  					 x_msg_count,
  					 x_msg_data);

		  	BIS_PMV_UTIL.update_portlets_bypage(xDestPageId);

		  end if;
   else
     xSourcePageId := 0;
   end if;

END processLinkedPage;

-- mdamle 10/31/2002 - Bug#2560743 - Use previous page parameters for linked page
--jprabhud 11/13/03 - Bug 3253597
procedure launchLinkedPage(	 pSourcePageId 	 	in varchar2 --number
				,pDestFunctionId 	in number
				,pRespId     		in varchar2 default null
				,pRespAppId		in varchar2 default null
				,pSecGrpId           	in varchar2 default null) is

lSourcePageId NUMBER ;
lUserId		number;
--serao -04/03, added sessionId
lSessionId VARCHAR2(80);
lDestPageID NUMBER;
lParamGroup BIS_PMV_PARAMETERS_PVT.parameter_group_tbl_type;
lParamRegionCode VARCHAR2(30);
-- udua - 09.27.05 - R12 Mandatory Project - 4480009 [PMV Data-model Change].
lParamFunctionName VARCHAR2(480);
-- nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
l_DrillDefaultParameters  VARCHAR2(3000);
begin

  	if not (icx_sec.validatesession)  then
     		return;
  	end if;

    lSessionId := icx_sec.getId(ICX_SEC.PV_SESSION_ID);
  	lUserId := icx_sec.getID(icx_sec.PV_USER_ID,'',lSessionId);

  processLinkedPage(
           pSourcePageId
          ,pDestFunctionId
          ,lSessionId
          ,lUserId
          ,lParamRegionCode
          ,lParamFunctionName
          ,lParamGroup
          ,lSourcePageId
          ,lDestPageId
          -- nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
          ,l_DrillDefaultParameters
        );

	invokeRFFunction(function_id => pDestFunctionId,
					responsibility_id => pRespId,
					responsibility_app_id => pRespAppId,
					sec_grp_id => pSecGrpId,
					-- jprabhud 03/04/2003 - Refresh Portal Page
          --jprabhud 11/13/03 - Bug 3253597
					pSourcePageId => lSourcePageId,
                              -- nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
					pDrillDefaultParameters => l_DrillDefaultParameters);

end launchLinkedPage;

-- jprabhud 03/04/2003 - Refresh Portal Page
function getFunctionName (pFunctionId number) return varchar2
is

CURSOR cFunction (pFunctionId in number) is
select function_name
from fnd_form_functions
where function_id = pFunctionId;

l_function_name 	fnd_form_functions.function_name%TYPE;
begin

	if cFunction%ISOPEN then
        	CLOSE cFunction;
	end if;
	OPEN cFunction(pFunctionId);
     	FETCH cFunction INTO l_function_name;
     	CLOSE cFunction;

	return l_function_name;

end getFunctionName;

-- gsanap 04/03/2003 - added to get user_function_name if prompt is null
function getUserFunctionName (pFunctionId number) return varchar2
is

CURSOR cFunction (pFunctionId in number) is
select user_function_name
from fnd_form_functions_tl
where function_id = pFunctionId;

-- udua - 09.27.05 - R12 Mandatory Project - 4480009 [PMV Data-model Change].
l_user_function_name    varchar2(480);
begin

        if cFunction%ISOPEN then
                CLOSE cFunction;
        end if;
        OPEN cFunction(pFunctionId);
        FETCH cFunction INTO l_user_function_name;
        CLOSE cFunction;

        return l_user_function_name;

end getUserFunctionName;

PROCEDURE processPageFromReport(
    pFunctionName In VARCHAR2
   ,pDestFunctionId IN NUMBER
   ,pSessionId IN VARCHAR2
   ,pUserId IN NUMBER
   , xDestPageID OUT NOCOPY NUMBER
   , xParamRegionCode OUT NOCOPY VARCHAR2
   , xParamFunctionName OUT NOCOPY VARCHAR2
   ,xParamGroup  OUT NOCOPY BIS_PMV_PARAMETERS_PVT.parameter_group_tbl_type
   -- nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
   ,x_DrillDefaultParameters OUT NOCOPY VARCHAR2
   ,x_return_status OUT NOCOPY varchar2
   ,x_msg_count     OUT NOCOPY number
   ,x_msg_data      OUT NOCOPY varchar2
) IS

BEGIN


    xDestPageID := getPageIdFromFunctionId(pDestFunctionId);
    IF xDestPageID IS NOT NULL THEN
      -- copy the parameters from the current report to the page
      			BIS_PMV_PARAMETERS_PVT.copyParamsFromReportToPage(
                                    pFunctionName,
                                    pSessionId,
                                    pUserId,
                        					  xDestPageID,
                                    xParamRegionCode,
                                    xParamFunctionName,
                                    xParamGroup ,
                                    -- nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
                                    x_DrillDefaultParameters,
                        					  x_return_status,
                        					  x_msg_count,
                        					  x_msg_data
                              );

			BIS_PMV_UTIL.update_portlets_bypage(xDestPageID);
    END IF;

END processPageFromReport;

PROCEDURE launchPageFromReport(
  pFunctionName IN VARCHAR2
  ,pDestFunctionId 	in number
	,pRespId     		in varchar2 default null
	,pRespAppId		in varchar2 default null
	,pSecGrpId           	in varchar2 default null
) IS
lDestPageId	number;
lUserId		number;
x_return_status varchar2(80);
x_msg_count     number;
x_msg_data      varchar2(80);
lSessionId VARCHAR2(80);
lParamRegionCode VARCHAR2(30);
-- udua - 09.27.05 - R12 Mandatory Project - 4480009 [PMV Data-model Change].
lParamFunctionName VARCHAR2(480);
lParamGroup BIS_PMV_PARAMETERS_PVT.parameter_group_tbl_type;
-- nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
l_DrillDefaultParameters VARCHAR2(3000);
BEGIN

  	if not (icx_sec.validatesession)  then
     		return;
  	end if;

    lSessionId := icx_sec.getId(ICX_SEC.PV_SESSION_ID);
  	lUserId := icx_sec.getID(icx_sec.PV_USER_ID,'',lSessionId);

    processPageFromReport(
      pFunctionName
     ,pDestFunctionId
     ,lSessionId
     ,lUserId
     ,lDestPageId
     ,lParamRegionCode
     ,lParamFunctionName
     ,lParamGroup
      -- nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
     ,l_DrillDefaultParameters
     ,x_return_status
     ,x_msg_count
     ,x_msg_data
   );

	-- Launch Dest page.
	invokeRFFunction(function_id => pDestFunctionId,
					responsibility_id => pRespId,
					responsibility_app_id => pRespAppId,
					sec_grp_id => pSecGrpId,
                                        -- nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
					pDrillDefaultParameters => l_DrillDefaultParameters
          );

END launchPageFromReport;

PROCEDURE checkAndSetRL (
  pUserId IN VARCHAR2,
  pPlugId IN VARCHAR2,
  pFunctionName IN VARCHAR2
) IS
 lIsCustomised NUMBER;
BEGIN


  checkUsercustomizeRLPortlet (
  pUserId => pUserId,
  pPlugId => pPlugId,
  xCustomised => lIsCustomised
  ) ;

  --if not customised then add the links
  IF (lIsCustomised <> 1) THEN

    createUserCustPlugRecord (
      pFunctionName => pFunctionName,
      pUserId => pUserId,
      pPlugId => pPlugId
    );

    BIS_RL_PKG.add_rl_from_function(  pFunctionName ,  pUserId ,  pPlugId);
  ELSE
	-- mdamle 03/12/04 - Enh 3503753 - Site level custom. for links
	-- Plug id exists in bis_schedule_preferences, but,
	-- check custom table also, just incase user has deleted links manually
	select count(*) into lIsCustomised from bis_custom_related_links where function_id = pPlugId and level_user_id = pUserId;

	if lIsCustomised = 0 then
	    BIS_RL_PKG.add_rl_from_function(  pFunctionName ,  pUserId ,  pPlugId);
	end if;

  END IF;

  -- commit to be issued by caller
END checkAndSetRL;

end bis_trend_plug;

/
