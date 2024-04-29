--------------------------------------------------------
--  DDL for Package Body BIS_GRAPH_REGION_UI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_GRAPH_REGION_UI" AS
/* $Header: BISCHRUB.pls 120.1 2006/02/02 02:07:27 nbarik noship $ */
---  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
---  All rights reserved.
---
---==========================================================================
---  FILENAME
---
---     BISCHRUB.pls
---
---  DESCRIPTION
---     Package Body File for displaying the three
---     html forms in which to
---     enter parameters to be stored for a PHP Chart
---
---  NOTES
---
---  HISTORY
---
---  20-Jun-2000 Walid.Nasrallah Created
---  05-Oct-2000 Walid.Nasrallah moved "WHO" column defintion to database
---  09-Oct-2000 Walid.Nasrallah modfied review_chart_action to use
---              sql@notfound instead of an explicit cursor
---  12-Oct-2000 Walid.Nasrallah comented out first database commit
---
---  22-Jan-2001 Ganesh.Sanap Removed all commented out code from prev ver.
---===========================================================================


-- *********************************************
-- PROCEDURES to preserve session_user state
-- *****************************************

---===============================================================
--- Function def_mode_query returns true if there exists
--- a well-formed cookie named g_cookie_name and encrypted by current session
---=============================================================================
g_len     constant pls_integer := length(g_sep);

FUNCTION def_mode_query
  return boolean

  is
     l_cookie      owa_cookie.cookie;
     l_value       varchar2(4096);
     l_code        pls_integer;
     l_session_id  pls_integer;
begin
---   return false;
   l_cookie := owa_cookie.get(g_cookie_name);
   for i in 1..l_cookie.num_vals loop
      l_value := l_cookie.vals(i);
      if (instr(l_value,g_sep) > 0)
	then
	 l_code := to_number(substr(l_value
				  ,1
				  ,instr(l_value,g_sep)-1
				  )
			   );
---	 def_mode_clear(l_value);

       else
	 l_code := to_number(l_value);
      end if;
---      htp.p(substr(icx_call.decrypt2(l_code), 1,11));
      if(substr(icx_call.decrypt2(l_code), 1,length(g_cookie_prefix))
	 =
	 g_cookie_prefix)
	then
---	 htp.p('true');
	 return true;
      end if;
   end loop;

   ---- IF we get to the end of the loop without inding a suitable value,
---   htp.p('NOT ');
   return false;
exception
   when others then
     return false;

end def_mode_query ;

---=====================================================================
--- Procedure def_mode_get re-parses the graph_region cookie into a
--- BIS_ESER_TREND_PLUG record
---==========================================================================
PROCEDURE def_mode_get
  (p_session_id  IN PLS_INTEGER
   ,x_record     OUT NOCOPY BIS_USER_TREND_PLUGS%ROWTYPE
    )
  is
     l_code            PLS_INTEGER;
     l_point1          PLS_INTEGER;
     l_point2          PLS_INTEGER;
     l_decoded         VARCHAR2(4096);
     l_string          VARCHAR2(4096);
     l_cookie          owa_cookie.cookie;
begin
   l_cookie := owa_cookie.get(g_cookie_name);

   for i in 1..l_cookie.num_vals loop
      l_string := l_cookie.vals(i);
      if (instr(l_string,g_sep) > 0)
	then
	 --- l_code gets the first half and l_string gets the last half
	 --- (any middle portion is discarded)
	 l_code := to_number(substr(l_string, 1, instr(l_string,g_sep)-1));

	 l_string := substr(l_string, instr(l_string, g_sep,-1) + 1);
       else
	 l_code := to_number(l_string);
	 l_string := '';
      end if;

      l_decoded := icx_call.decrypt2(l_code,p_session_id);
      if (substr(l_decoded, 1, length(g_cookie_prefix)) = g_cookie_prefix)
	then
	 --- We have found the right cookie and can exit the loop
	 --- after loading up the values
	 x_record.chart_user_title :=
	   replace
	      (replace
	          (replace
	              (replace(l_string
			       ,'%20'
			       ,' '
			       )
		       ,'%2A'
		       ,'*'
		       )
		   ,'%2C'
		   ,','
		   )
	       ,'%3B'
	       ,';'
	       );
	 l_point1 := instr(l_decoded,g_sep,1,1) + g_len;
	 l_point2 := instr(l_decoded,g_sep,l_point1,1);
	 x_record.plug_id := substr(l_decoded,l_point1,l_point2-l_point1);
	 l_point1 := l_point2 + g_len;
	 l_point2 := instr(l_decoded,g_sep,l_point1);
	 x_record.user_id := substr(l_decoded,l_point1,l_point2-l_point1);
	 l_point1 := l_point2 + g_len;
	 l_point2 := instr(l_decoded,g_sep,l_point1);
	 x_record.function_id := substr(l_decoded,l_point1,l_point2-l_point1);
	 l_point1 := l_point2 + g_len;
	 l_point2 := instr(l_decoded,g_sep,l_point1);
	 x_record.responsibility_id := substr(l_decoded,l_point1,l_point2-l_point1);
	 exit;
	 ----else loop again
      end if;
   end loop;
exception
   when others
     then
      null;
end def_mode_get;


---=======================================================================
--- The following two procedures are not in use.  owa_cookie does not perform as expected
---========================================================================
PROCEDURE def_mode_set  ( cookie_code IN pls_integer)
  is
     mycookie  owa_cookie.cookie;
     code      pls_integer;
begin
   owa_cookie.send(g_cookie_name,to_char(cookie_code));

end def_mode_set;


PROCEDURE def_mode_clear
 (p_coded_string  IN  varchar2)
   is
begin
   owa_cookie.remove(g_cookie_name,p_coded_string);
end def_mode_clear;


PROCEDURE Review_Chart_Action
  (  p_where               in  PLS_INTEGER
   , p_plug_id             in  PLS_INTEGER
   , p_user_id             in  PLS_INTEGER
   , p_function_id         in  PLS_INTEGER
   , p_responsibility_id   in  PLS_INTEGER
   , p_chart_user_title    in  VARCHAR2
   , p_parameter_string    in  VARCHAR2
    )
  is
     l_plug_id            pls_integer;
     l_user_id            pls_integer;
     l_session_id         pls_integer;
     l_home_url           varchar2(240);
     l_parm_url           varchar2(1000);
     l_img_html           varchar2(32000);
     hu_instr             number;
     pTrendParam          number;
     TrendType            varchar2(5000);

     BEGIN


     if icx_sec.validateSession
       then

	l_session_id :=  icx_sec.getID(icx_sec.PV_session_ID);

	l_plug_id := icx_call.decrypt2(p_plug_id, l_session_id);
	l_user_id := icx_call.decrypt2(p_user_id,l_session_id);

    l_home_url := bis_report_util_pvt.get_home_url;

    hu_instr  := instr(l_home_url,'oraclemyPage.home');

    l_home_url := substr(l_home_url,1,hu_instr-1);

    l_parm_url := l_home_url||p_parameter_string;

    ptrendParam := instr(l_parm_url,'&pTrendType=');

    if pTrendParam > 0 then
       TrendType   := substr(l_parm_url,pTrendParam+12,1);
    end if;


    bis_trend_plug.get_graph_from_URL(TrendType,l_parm_url, l_img_html);


	UPDATE
	  bis_user_trend_plugs
	  SET FUNCTION_ID = icx_call.decrypt2(p_function_id,l_session_id)
	  ,   RESPONSIBILITY_ID  = p_responsibility_id
	  ,   CHART_USER_TITLE = p_chart_user_title
--	  ,   PARAMETER_STRING = replace(p_parameter_string,'=','~')||'*]'
	  ,   PARAMETER_STRING = p_parameter_string
      ,   CACHED_GRAPH     = l_img_html
	  ,   LAST_UPDATE_DATE = sysdate
	  ,   LAST_UPDATED_BY  =  l_user_id
	  ,   last_update_login = fnd_global.login_id
	  WHERE user_id = l_user_id
	  and   plug_id = l_plug_id ;

	IF SQL%notfound THEN
	   insert into BIS_USER_TREND_PLUGS
	     (  plug_id
		, user_id
		, function_id
		, responsibility_id
		, chart_user_title
		, parameter_string
		, graph_sequence
		, cached_graph
		, creation_date
		, created_by
		, last_update_date
		, last_updated_by
		, last_update_login
		)
	     values (l_plug_id
		     , l_user_id
		     , icx_call.decrypt2(p_function_id,l_session_id)
		     , p_responsibility_id
		     , p_chart_user_title
--		     , replace(p_parameter_string,'=','~')||'*]'
		     , p_parameter_string
		     , 1
             , l_img_html
		     , sysdate
		     , l_user_id
		     , sysdate
		     , l_user_id
		     , fnd_global.login_id
		     );

	end if; --- NOTFOUND


--- Note: delay commit to keep the plug locked just in case two sessions
---       try to customize the same graphs region
---	commit;

     end if; --- Validate Session

     owa_util.redirect_url(icx_call.decrypt2(p_where));

exception
   when others then
      htp.p(SQLERRM);
end Review_Chart_Action;


END BIS_GRAPH_REGION_UI;

/
