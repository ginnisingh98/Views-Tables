--------------------------------------------------------
--  DDL for Package Body BIS_GRAPH_REGION_HTML_FORMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_GRAPH_REGION_HTML_FORMS" AS
/* $Header: BISCHRFB.pls 120.3 2006/03/27 16:28:42 nbarik noship $ */
---  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
---  All rights reserved.
---
---==========================================================================
---  filename
---
---     bischrfb.pls
---
---  description
---     package body file for displaying the three
---     html forms in which to
---     enter parameters to be stored for a php chart
---
---  notes
---
---  history
---
---  20-Jun-2000 Walid.Nasrallah created
---  28-sep-2000 walid.nasrallah modified call to build_html_banner
---  03-oct-2000 walid.nasrallah enabled preview by inserting calls to
---              bis_trend_plug.get_graph_from_URL
---  04-oct-2000 walid.nasrallah enabled exclusion of designated reports
---  05-Oct-2000 Walid.Nasrallah moved "WHO" column defintion to database
---  10-Oct-2000 Walid.Nasrallah added comments to function definitions
---                              added code to clear cookie at cancel
---                              moved exception messages into html comments
---                                      invisible to end users
---  11-Oct-2000 Walid.Nasrallah added call to fnd_global.apps_initialize
---  12-Oct-2000 Walid.Nasrallah replaced apps_initialize with update
---                              icx_page_plugs
---  17-Oct-2000 Walid.Nasrallah added special case for HRI report preview
---
---  22-Jan-2001 Ganesh.Sanap Removed all the Code that was commented out
---                           from the previous version
---  05-Mar-2001 Maneesha.Damle  Bug#1652353 Fix - Parameters LOV does not
---                              update field on parent form in IE
---  21-Mar-2001 Maneesha.Damle  Wrapper routines to return Resp & Funcns
---				 lists to java
---  29-May-2001 Maneesha.Damle	 Added function hasFunctionAccess()
---  31-May-2001 Maneesha.Damle  New ICX Profile for OA_HTML, OA_MEDIA
---  28-Jun-2001 Maneesha.Damle  fixed bug in has_good_report
---  12-Nov-2001 Maneesha.Damle	 Use FND security function to check function access
---  08-Jan-2002 Maneesha.Damle	 Check for valid region in get_accessible_functions
------======================================================================

--- *********************************************
--- global variables
--- *****************************************

g_help_target_name    constant varchar2(200) := 'bistrnd';
g_and                 constant varchar2(5) := '&' || '&';
g_nbsp                constant varchar2(200) := '&'||'nbsp;';
g_initialize          constant varchar2(2000) := '12345678901234567890123456789012345';
g_sep                 constant varchar2(10) := BIS_GRAPH_REGION_UI.g_sep;

g_saved_appl_id      pls_integer;

-- mdamle 05/31/2001 - New ICX Profile for OA_HTML, OA_MEDIA
-- g_images varchar2(1000) := FND_PROFILE.value('ICX_REPORT_IMAGES');
g_images varchar2(1000) := BIS_REPORT_UTIL_PVT.get_Images_Server;
g_ImageDirectory varchar2(1000) := FND_WEB_CONFIG.TRAIL_SLASH(g_images);

-- mdamle 05/31/2001 - New ICX Profile for OA_HTML, OA_MEDIA
-- g_css varchar2(1000) := FND_PROFILE.value('ICX_OA_HTML');

-- g_CSSDirectory varchar2(1000) := '/' || FND_WEB_CONFIG.TRAIL_SLASH(g_css);
   g_CSSDirectory varchar2(1000) := BIS_REPORT_UTIL_PVT.get_html_server;

/*
--- *********************************************
--- Type declarations
--- *****************************************

TYPE t_resp_rec IS RECORD(
			  responsibility_name
			  fnd_responsibility_vl.responsibility_name%TYPE
			  , responsibility_id
			   fnd_responsibility.responsibility_id%TYPE
			  , application_id
			  fnd_responsibility.application_id%TYPE
			  , security_group_id
			  fnd_user_resp_groups.security_group_id%TYPE
			  );

TYPE t_resp_tbl_type IS TABLE OF t_resp_rec;


TYPE t_func_rec IS RECORD(menu_name
			   fnd_menu_entries_vl.prompt%TYPE
			   ,web_html_call
			  fnd_form_functions.web_html_call%TYPE
			  ,web_args
			  fnd_form_functions.web_html_call%TYPE
			  ,parameters
			  fnd_form_functions.parameters%TYPE
			  ,function_id
			  fnd_form_functions.function_id%TYPE
			  -- mdamle 03/21/2001
			  ,menu_id
			  fnd_menu_entries.menu_id%TYPE
			  );


TYPE t_func_tbl_type IS TABLE OF t_func_rec;

TYPE t_menu_tbl_type IS TABLE OF fnd_responsibility.menu_id%TYPE;

*/
---==========================================================================
---  FUNCTION has_good_report
---
---  arguments:
---         IN: a record out of the fnd_form_functions table
---        OUT: a boolean
---
---  action:  Returns TRUE if the funciton described int he record
---           meets certain criteria.  The criteria are meant to be
---           edited during code development.  Currently, the criteria
---           correspond to fomr funcitrons which call three types of
---           reports: Reprot Generator reports, Oracle Reports reports
---           with normal parameter forms, and Oracel Reports reprots
---           with custom parameter fomrs written as PL/SQL packages
---           according to BIS specification.
---
---==========================================================================


--  11/12/01 mdamle - Passing only web_html_call instead of the function record
FUNCTION has_good_report(pWebHTMLCall in varchar2)
  return boolean
  is
     l_call varchar(4000);
     l_dummy pls_integer;
begin

      	l_call := upper(pWebHTMLCall);

      	if (l_call = 'ORACLEOASIS.RUNREPORT') THEN --- Regular Oracle Reports function
		return false;
       	elsif l_call like '%_PARAMETER%FORMVIEW%' THEN --- Oracle Reprots with custom package for parameter form
		return false;
       	-- mdamle 06/28/01 - Changed from = to like
       	elsif upper(l_call) like 'BISVIEWER%' THEN --- BIS Rerpot Generator
		return true;
		-- nbarik - 10/04/05 - Bug Fix 4633433
       	elsif (trim(pWebHTMLCall) like '%page=/oracle/apps/bis/report/webui/BISReportPG%') THEN --- BIS Rerpot Generator
		return true;
	-- mdamle 12/28/01
	elsif l_call like '%BIS_PM_PORTLET_TABLE_LAYOUT%' then
		return true;
       	else --- ALL OTHERS (Discoverer workbooks, concurrent requests, etc.)
	 	return false;
      	end if;

EXCEPTION
	WHEN OTHERS THEN
      RETURN FALSE;

end has_good_report;


PROCEDURE Review_Chart_Render
  (   p_user_id             in  PLS_INTEGER
    , p_parameter_string    in  VARCHAR2
   )
  is

     l_plug_id      	       PLS_INTEGER;
     l_session_id	       PLS_INTEGER;
     l_user_id                 PLS_INTEGER;
     l_responsibility_id       PLS_INTEGER;
     l_function_id             PLS_INTEGER;
     l_application_id	       PLS_INTEGER;
     l_security_group_id       PLS_INTEGER;
     c_call	               PLS_INTEGER;
     c_dummy                   PLS_INTEGER;
     l_page_title              varchar2(240);
     l_chart_title_prompt      varchar2(240);
     l_report_title_prompt     varchar2(240);
     l_back_btn_txt            varchar2(240);
     l_submit_btn_txt          varchar2(240);
     l_cancel_btn_txt          varchar2(240);
     l_report_name             varchar2(240);
     l_function_parameters     varchar2(32000);
     l_function_web_args       varchar2(32000);
     l_function_web_call       varchar2(32000);
     l_plsql_agent_URL         varchar2(32000);
     l_Report_Fn_URL           varchar2(32000);
     l_report_cache_url        varchar2(32000);
     l_img_html 	           varchar2(32000);
     l_profile_defined         boolean;
     l_record                  BIS_USER_TREND_PLUGS%ROWTYPE;

     tmp_parm                varchar2(240);

begin

  l_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);

  --- Get saved data from cookie
  BIS_GRAPH_REGION_UI.def_mode_get(l_session_id, l_record);

  l_plug_id := icx_call.decrypt2(l_record.plug_id,l_session_id);

  if icx_sec.validatePlugSession(l_plug_id, l_session_id)
   then

    l_user_id := icx_call.decrypt2(l_record.user_id,l_session_id);

    l_function_id:=
      icx_call.decrypt2(l_record.function_id,l_session_id);

    l_page_title := icx_plug_utilities.getPlugTitle(l_plug_id);

    fnd_message.set_name('BIS','BIS_BACK');
    l_back_btn_txt := fnd_message.get;

    fnd_message.set_name('BIS','BIS_SUBMIT');
    l_submit_btn_txt := fnd_message.get;

    fnd_message.set_name('BIS','BIS_CANCEL');
    l_cancel_btn_txt := fnd_message.get;

    fnd_message.set_name('BIS','BIS_CHART_TITLE');
    l_chart_title_prompt := fnd_message.get;


    SELECT
      web_html_call
      , parameters
      INTO
      l_function_web_call
      , l_function_parameters
      FROM fnd_form_functions
      WHERE function_id = l_function_id;

    fnd_profile.get_specific
      (
       name_z                  => 'ICX_REPORT_LINK',
       user_id_z               => l_user_id,
       responsibility_id_z     => l_record.responsibility_id,
       application_id_z        => l_application_id,
       val_z                   => l_plsql_agent_URL,
       defined_z               => l_profile_defined
       );

        ---Parameters all obtained
	-------------------------------------------------------------------



	if (lower(l_function_web_call) = 'oracleoasis.runreport')
	  then

	   ----- CASE 1 : Direct RunReprot call

	   l_Report_Fn_URL := l_plsql_agent_URL
	     ||'OracleOASIS.RunReport?'
	     || 'session_id='
	     || l_session_id||'&'
	     || 'user_id='
	     || l_user_id||'&'
	     || 'responsibility_application_id='
	     ||l_application_id||'&'
	     || 'responsibility_id='
	     ||l_record.responsibility_id
	     ||'&'
	     || replace(l_function_parameters
			,'PARAMFORM=HTML'
			,'PARAMFORM=NO')
	     ||'*'
	     || replace(p_parameter_string,'=','~')||'*]'
	     ;


	   ---- Run the report and obtain the file name containing the graphic.

	   bis_trend_plug.get_graph_from_URL('G',l_report_Fn_URL, l_img_html);



	 else

	   if instr(l_function_web_call,'(') > 0
	     then
	      l_function_web_args := substr(l_function_web_call
					    , instr(l_function_web_call,'(') + 1
					    , instr(l_function_web_call,')') - 1
					    );

	      l_function_web_call := substr(l_function_web_call
					    , 1
					    , instr(l_function_web_call,'(') - 1
					    );


	   end if;

	   if (lower(l_function_web_call) = 'bisviewer.showreport')

	   ----- CASE 2 : BIS Report Generator

       then


	      --- WFN Debug
	      --- for report generator this logic won't work

          null;




	    --- END OF CASE 2 - BIS Report Generator

	    else
	     ----- CASE 3 : Custom Package

	      ---- Normally, the report name is the string after the last
	      ---- underscore character in the function name
	      ----  However, for HR reprots, the report name is in the arguments.


	      IF substr(l_function_web_call,1,3)='HRI' THEN
  		     l_report_name := substr(l_function_web_args ,instr(l_function_web_args,'''',1)+1,8);
	      ELSE
             l_report_name := substr(  l_function_web_call, instr(l_function_web_call,'_',-1)+1, length(l_function_web_call) );
	      END IF;


	      l_Report_Fn_URL := l_plsql_agent_URL
		||'OracleOASIS.RunReport?report='
		|| l_report_name
		||'&'
		|| 'session_id='||icx_sec.getID(icx_sec.PV_SESSION_ID)||'&'
		|| 'user_id='||l_user_id||'&'
		|| 'responsibility_application_id='||l_application_id||'&'
		|| 'responsibility_id='
		||l_record.responsibility_id
		||'&'
		|| 'PARAMETERS='|| replace(p_parameter_string,'=','~')||'*]';



     ---- Run the report and obtain the file name containing the graphic.


	   bis_trend_plug.get_graph_from_URL('G',l_report_Fn_URL, l_img_html);



	   --- END OF CASE 3 - Custom Package
	   end if;
	end if;

    htp.htmlOpen;
    htp.headOpen;
    htp.title(l_page_title);
    BIS_UTILITIES_PVT.putstyle;
    htp.linkRel( crel => 'stylesheet', curl => g_CSSDirectory || 'bismarli.css');
    BIS_HTML_UTILITIES_PVT.Build_HTML_Banner(l_page_title,G_HELP_TARGET_NAME);
    htp.headClose;

    htp.p('<body onLoad="
	   document.cookie='''
	  ||
	  BIS_GRAPH_REGION_UI.g_cookie_name
	  ||
	  '=nonsense ; domain='
	  || BIS_GRAPH_REGION_UI.g_domain
	  ||';'';
	   ">');

    g_graph_title := l_record.chart_user_title;

    htp.centerOpen;
    htp.p('<table width=95%>');  --- Main
    htp.formOpen('BIS_GRAPH_REGION_UI.REVIEW_CHART_Action','POST','','','NAME="saveForm"');

    htp.formHidden( 'p_where'
		    ,icx_call.encrypt2(bis_report_util_pvt.get_home_URL)
		   );
   htp.formHidden( 'p_plug_id'
		    ,l_record.plug_id
		   );
    htp.formHidden( 'p_user_id'
		    ,l_record.user_id
		    );
    htp.formHidden('p_function_id'
		   ,l_record.function_id
		   );
    htp.formHidden('p_responsibility_id'
		   ,l_record.responsibility_id
		   );
    htp.formHidden('p_chart_user_title'
		   ,l_record.chart_user_title
		   );
    htp.formHidden('p_parameter_string'
		   ,p_parameter_string
		   );
	  htp.p('<tr><td colspan=2><table border=0 cellpadding=0 width=100%>');
	  --- Instructions
        fnd_message.set_name('BIS','BIS_TREND_PLUG_CZ3_SUMMARY');
	htp.tablerowopen(cvalign => 'bottom');
	htp.tabledata(htf.bold(fnd_message.get));
	htp.tablerowclose;
	htp.p('<tr height = 2 bgcolor=#666666><td><img src="/OA_MEDIA/BISPX666.gif"></td></tr>');
	htp.tablerowopen(cvalign => 'top');
	fnd_message.set_name('BIS','BIS_TREND_PLUG_CZ3_INSTR');
	fnd_message.set_token('BACK','"'||l_back_btn_txt||'"');
	htp.tabledata(fnd_message.get);
	htp.tablerowclose;

     htp.p('</table></td></tr>'); --instructions

     htp.p('<tr><td align=left width=3%> </td>');
     htp.p('<td align=left>');
     htp.p('<table border=0 cellpadding=0 width=100%>');  -- Report Name
	 htp.tablerowopen(cvalign => 'bottom');
	 htp.tabledata(htf.bold(l_chart_title_prompt
			 ||': '
			 ||l_record.chart_user_title
			 )
		);

         htp.tablerowclose;
	 htp.p('<tr height = 1 bgcolor=#666666><td>'
	       ||'<img src="/OA_MEDIA/BISPX666.gif">'
	       ||'</td></tr>');
      htp.p('</table></td></tr>'); -- Report Name

      if ( l_img_html IS NOT  NULL)
	THEN
	 IF substr(l_img_html,1,4) <>'http'
	   THEN
	    fnd_profile.get_specific
	      (
	       name_z            => 'ICX_REPORT_CACHE',
	       user_id_z          => l_user_id,
	       responsibility_id_z => l_responsibility_id,
	       application_id_z      => l_application_id,
	       val_z                 => l_Report_Cache_URL,
	       defined_z             => l_profile_defined);
	    if l_profile_defined
	      THEN l_img_html := l_report_cache_url || l_img_html;
	    END IF;
	 END IF;

---Ganesh this is where the graphs image is printed

	 htp.p('<tr><td> </td> <td  align=center>'
		    || ' <img src='
		    ||l_img_html
		    ||'>'
		    );
       ELSE --- null l_img_html
	 htp.p('<! Review_Chart_Render: REPORT URL IS '|| l_report_fn_url);
      END IF;



      htp.p('<tr><td> </td> <td  align=right>');
      htp.p('<table> <tr><td align=center>');   ---buttons
         icx_plug_utilities.buttonBoth(l_cancel_btn_txt
				       ,'Javascript:history.go(-3)'
				       ,'');
	 htp.p('</td><td colspan="2" nowrap=1>');
	 htp.p('<table width="100%">'); -- inner buttons
	    htp.p('<tr><td width="50%" align="right">');
	    icx_plug_utilities.buttonLeft(l_back_btn_txt
					  ,'Javascript:history.go(-1)'
					  ,'');
	    htp.p('</td><td align="left" width="50%">');

	    icx_plug_utilities.buttonBoth(l_Submit_btn_txt
					  ,'Javascript:document.saveForm.submit()'
					  ,'');
        htp.p('</td></tr></table>'); -- inner buttons
     htp.p('</td></tr></table>'); -- all buttons

  htp.p('</td></tr></table>'); -- Main
  htp.centerClose;
  htp.bodyClose;
end if;

exception
     when others then
	htp.p('<! Review_Chart_Render:EXCEPTION
	      '
	      ||SQLERRM
	      ||'
	      >'
	      );
end Review_Chart_Render;

function get_graph_title return varchar2 is
tmp_g_title varchar2(200);
begin
  tmp_g_title :=  g_graph_title;
  return tmp_g_title;
end;

-- mdamle 05/29/2001 - Added function to check if user has access to this function
-- mdamle 07/03/2001 - Added pCheckPMVSpecific flag
function hasFunctionAccess(pUserId 		in varchar2
			 , pFunctionName	in varchar2
			 , pCheckPMVSpecific    in varchar2 default 'Y') return boolean IS

cursor p_resps is
 -- 11/12/01 mdamle - Use FND security function to check function access
 -- Get menu_id
 select  a.menu_id
 from fnd_responsibility a,
   fnd_user_resp_groups b
 where b.user_id = pUserId
   and   a.version = 'W'
   and   b.responsibility_id = a.responsibility_id
   and   b.start_date <= sysdate
   and   (b.end_date is null or b.end_date >= sysdate)
   and    a.start_date <= sysdate
   and   (a.end_date is null or a.end_date >= sysdate);

l_function_table      	t_func_tbl_type;
l_default_resp_Id	number;
l_foundResp		boolean;
p_Resps_rec 		p_Resps%ROWTYPE;
l_function_id		number;
l_web_html_call 	fnd_form_functions.web_html_call%TYPE;

begin
	begin
		select function_id, web_html_call
		into l_function_id, l_web_html_call
		from fnd_form_functions
		where function_name = pFunctionName;
	exception
		when others then l_function_id := null;
	end;

	if l_function_id is null then
		l_foundResp := false;
	else
		-- First, get a list of all valid responsibilities for this user
		l_foundResp := false;
        	open p_Resps;
        	<<resp_loop>>
        	loop
        		fetch p_Resps into p_Resps_rec;
                	EXIT WHEN p_Resps%NOTFOUND;

			l_foundResp := fnd_function.is_function_on_menu(p_Resps_rec.menu_id, l_function_id);
			if l_foundResp = true then
				if (has_good_report(l_web_html_call) = false) and (pCheckPMVSpecific = 'Y') then
					l_foundResp := false;
				end if;

				exit resp_loop;
			end if;
	        end loop;
        	close p_Resps;
	end if;

	return l_foundResp;

end hasFunctionAccess;


END BIS_GRAPH_REGION_HTML_FORMS;

/
