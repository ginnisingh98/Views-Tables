--------------------------------------------------------
--  DDL for Package Body BIS_BIA_RSG_PSTATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_BIA_RSG_PSTATE" AS
/* $Header: BISPGSTB.pls 120.6 2006/05/09 05:30:59 rkumar ship $ */

PROCEDURE debug (	text varchar2 )
IS
BEGIN
--INSERT INTO amit_DEBUG VALUES(text);
--  commit;
  null;
END;

   FUNCTION time_interval (p_interval IN NUMBER)
      RETURN VARCHAR2
   IS
      l_result   VARCHAR2 (30) := '';
      l_dummy    PLS_INTEGER   := 0;

      FUNCTION format (p_value IN NUMBER)
         RETURN VARCHAR2
      IS
         l_str   VARCHAR2 (30) := '';
      BEGIN
         IF p_value < 10
         THEN
            l_str := '0' || TO_CHAR (p_value);
         ELSE
            l_str := p_value;
         END IF;

         RETURN l_str;
      END format;
   BEGIN
      l_dummy := FLOOR (p_interval) * 24 + MOD (FLOOR (p_interval * 24), 24);
      l_result := format (l_dummy) || ':';
      l_dummy := MOD (FLOOR (p_interval * 24 * 60), 60);
      l_result := l_result || format (l_dummy) || ':';
      l_dummy := MOD (FLOOR (p_interval * 24 * 60 * 60), 60);
      l_result := l_result || format (l_dummy);
      RETURN l_result;
   END time_interval;



FUNCTION duration(
	p_duration		number) return VARCHAR2 IS
BEGIN
   if(p_duration is null) then
     return null;
   else
     return time_interval(p_duration);
   end if;
END duration;




FUNCTION get_refresh_mode(P_REQUEST_SET_NAME varchar2) RETURN VARCHAR2 IS  --added for bug 4183903

  cursor refresh_mode is
    select option_value
    from bis_request_set_options
    where request_set_name = P_REQUEST_SET_NAME
    and option_name='REFRESH_MODE';

  cursor analyze_object is
    select option_value
    from bis_request_set_options
    where request_set_name= P_REQUEST_SET_NAME
    and option_name='ANALYZE_OBJECT';

  l_refresh_mode   refresh_mode%rowtype;
  l_analyze_object analyze_object%rowtype;

BEGIN
  OPEN refresh_mode;
  FETCH refresh_mode INTO l_refresh_mode;
  CLOSE refresh_mode;

  if (l_refresh_mode.option_value is null) then
    OPEN analyze_object;
    FETCH analyze_object INTO l_analyze_object;
    CLOSE analyze_object;
    if (l_analyze_object.option_value ='Y') then
      RETURN 'ANAL';
    end if;
  end if;

  RETURN l_refresh_mode.option_value;

EXCEPTION WHEN OTHERS THEN
  BIS_COLLECTION_UTILITIES.put_line('Exception happens in get_refresh_mode ' ||  sqlerrm);
  raise;

END get_refresh_mode;




function sync_last_refresh_time(p_last_refresh_time in date) return date is
 begin
  if  p_last_refresh_time=to_date('01-01-1900','DD-MM-YYYY') then
    return null;
  else
   return p_last_refresh_time;
  end if;
 end;


FUNCTION get_Plan_URL RETURN VARCHAR2
IS
  l_value varchar2(32767);
  l_url   varchar2(32767);
BEGIN
   l_value := fnd_profile.value('BIS_LOAD_SCHEDULE');
   if (l_value is not null) then
     l_url := '''<A HREF="'|| l_value || '">Plan</A>''';
   else
     l_url := ''' ''';
   end if;
   return  l_url;


END;

/*Enh 4638578
This function will get the Request set names for all the request sets either created for
that report or created for a dashbaord to which the report is attached.

Will return the name of request sets for that dashboard
*/
Function get_rs_for_content(p_content_name in varchar2,
                            p_content_type in varchar2) return varchar2 is
 cursor c_rs_for_reports (l_report_name varchar2) is
      select request_set_name from (select request_set_name --request set for dashboard that has this report
      from bis_request_set_objects
      where object_name in (
        select Distinct obj.OBJECT_NAME
        from bis_obj_dependency  obj
        where object_type in ('PAGE') and enabled_flag='Y'
        start with
         obj.depend_object_type ='REPORT'
         and obj.depend_object_name=l_report_name
        connect by prior obj.OBJECT_NAME=obj.depend_object_name
         and prior obj.OBJECT_TYPE=obj.depend_object_TYPE)
      and object_type ='PAGE'
    union -- request set for report directly
      select request_set_name from bis_request_set_objects
      where object_name =l_report_name  and object_type ='REPORT') where
      BIS_BIA_RSG_PSTATE.get_refresh_mode(REQUEST_SET_NAME) <> 'ANAL';

  cursor c_rs_for_pages (l_page_name varchar2) is
      SELECT REQUEST_SET_NAME FROM
      (select request_set_name from bis_request_set_objects
      where object_name =l_PAGE_name and object_type ='PAGE') WHERE
      BIS_BIA_RSG_PSTATE.get_refresh_mode(REQUEST_SET_NAME) <> 'ANAL';

  l_rs_names varchar2(32767);
  l_currow1  c_rs_for_reports%rowtype;
  l_currow2  c_rs_for_reports%rowtype;
begin
  l_rs_names := null;
  DEBUG('iN GET_rs'||p_content_type);
  DEBUG('iN GET_rs'||p_content_name);
  --EXECUTE THE CURSOR DEPENDEING ON THE CONTENT TYPE
  if(p_content_type='PAGE') THEN
    DEBUG('IN GET_rs if page');
    for l_currow1 in c_rs_for_pages(p_content_name) loop
      l_rs_names  := l_rs_names ||','''||l_currow1.request_set_name||'''';
    end loop;
  ELSIF (p_content_type ='REPORT') THEN
    DEBUG('IN GET_rs if report');
    for l_currow2 in c_rs_for_reports(p_content_name) loop
      l_rs_names  := l_rs_names ||','''||l_currow2.request_set_name||'''';
      --DEBUG('RS_NAME'||L_RS_NAMES);
    end loop;
  END IF;
  --DEBUG('RS_NAME'||L_RS_NAMES);
  return substr(l_rs_names,2);

end;

PROCEDURE Get_Sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY 	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sql_stmt		VARCHAR2(32767);
  l_custom_rec		BIS_QUERY_ATTRIBUTES;
  l_bind                VARCHAR2(32767);
  pname                 VARCHAR2(1024);
  pid                   VARCHAR2(1024);
  content_name          varchar2(1024);
  plan_url              varchar2(250); --ADDED FOR BUG 4418935
  plan_text             varchar2(250); --ADDED FOR BUG 4418935
  content_type          varchar2(30);
  l_rs_names            varchar2(32767); -- added for enh 4638578
BEGIN

  --TO REMOVE GSCC WARNING MOVED THE INITIALIZATIONS HERE
  pname                 := NULL;
  pid                   := NULL;
  content_name          := NULL;
  plan_url              := NULL;
  plan_text             := NULL;

  FOR i IN 1..p_param.count LOOP
         pname  := p_param(i).parameter_name;
         --pvalue := p_param(i).parameter_value;
         pid :=  p_param(i).parameter_id;
         --debug( '( ' || pname || ', ' || pvalue  || ' )' );

         if pname = 'DBI_REQUEST_SET+DBI_REQUEST_SET' then
            content_name := pid ;
            debug('DBI_REQUEST_SET+DBI_REQUEST_SET: ' || content_name);
            --code to remove extra quotes added by PMV
            content_name := trim('''' from content_name);
         end if;

         if pname = 'DBI_CONTENT_TYPE+DBI_CONTENT_TYPE' then
            content_type := pid ;
            debug('DBI_CONTENT_TYPE+DBI_CONTENT_TYPE' || content_type);
            --code to remove extra quotes added by PMV
            content_type := trim('''' from content_type);
         end if;
  END LOOP;

  --following condition is not needed, because after enhancement 4638578
  -- because user is not allowed to change the page_name on the report
  /*if (page_name is not null AND page_name <> 'All')  then
    l_bind := ' bis_impl_dev_pkg.get_function_by_page(OBJECTS.object_name) = :PAGE_NAME ';
  else
    l_bind := ' bis_impl_dev_pkg.get_function_by_page(OBJECTS.object_name) is not null ';
  end if;   */

  begin
    --call the procedure update_terminated_rs that will update the status of those request sets that were terminated by user.  --Bug 4183903
    BIS_COLL_RS_HISTORY.update_terminated_rs;

    EXCEPTION WHEN OTHERS THEN
      debug('Error happened while trying to update the status of those request sets that were terminated by user. Report MAY show terminated request sets as running');
  END;

  --CODE ADDED FOR BUG 4418935
  plan_url := fnd_profile.value('BIS_LOAD_SCHEDULE');
  if(plan_url is null) then
     plan_url := ' ';
  end if;

  plan_text := BIS_REQUESTSET_VIEWHISTORY.get_bis_lookup_meaning('BIS_RSG_PAGE_STATUS_REPORT','PLAN_URL');

  --query Modified for 3753793
  --query modified for bug 4319254
  --query modified for bug 4418395
  -- added one more column in select list to implement plan url

  --added code for enhancment 4638578
  if (content_type = 'PAGE')  then
    debug ('in page if first');
    l_bind := ' bis_impl_dev_pkg.get_function_by_page(OBJECTS.object_name) = :CONTENT_NAME ';
  ELSIF (CONTENT_TYPE ='REPORT') THEN
    l_bind := ' OBJECTS.object_name = :CONTENT_NAME ';
  end if;

  debug(content_type||'<=content_type');
  --added code for enhancment 4638578
  if (content_type = 'PAGE')  then
    debug ('in page if');
    l_sql_stmt := 'select
           DISP.value BIS_BIA_RSG_PAGE_NAME_DISPLAY,
           BIS_RSG_PMV_REPORT_PKG.date_to_charDTTZ( LAST_SUCCESSFUL_REFRESH.Last_Refresh_Time ) BIS_BIA_RSG_PAGE_LSTREFDATE,
           LAST_SUCCESSFUL_REFRESH.Last_Refresh_Duration BIS_BIA_RSG_PAGE_LAST_REFDUR,
           CURRENT_RUN.Current_Status BIS_BIA_RSG_PAGE_STATUS,
           BIS_RSG_PMV_REPORT_PKG.date_to_charDTTZ(CURRENT_RUN.Refresh_Start_Time) BIS_BIA_RSG_PAGE_REFSTARTTIME,
           BIS_RSG_PMV_REPORT_PKG.date_to_charDTTZ(NEXT_SCHEDULED_REFRESH.REQUESTED_START_DATE) BIS_BIA_RSG_PAGE_NEXTREF,
           decode('''||plan_url||''','' '',null,'''|| plan_text||''') BIS_BIA_RSG_PAGE_REFPLAN,
	   decode('''||plan_url||''','' '',null,'''||plan_url||''') BISREPORTURL
           from

           BIS_BIA_RSG_PAGE_STATUS_V DISP,

           (
           select OBJECT_NAME,
           decode(Last_Refresh_Time,to_date(''01-01-1900'',''DD-MM-YYYY''),null,Last_Refresh_Duration) Last_Refresh_Duration,
           BIS_BIA_RSG_PSTATE.sync_last_refresh_time(Last_Refresh_Time) Last_Refresh_Time
		   from
             (
           select OBJECTS.OBJECT_NAME,
		   BIS_BIA_RSG_PSTATE.duration(COMPLETION_DATE - START_DATE) Last_Refresh_Duration,
                   bis_submit_requestset.get_last_refreshdate(objects.object_type,null,objects.object_name) Last_Refresh_Time,
		   rank() over(partition by OBJECTS.OBJECT_NAME order by START_DATE desc) rk
		   FROM BIS_RS_RUN_HISTORY HISTORY, BIS_REQUEST_SET_OBJECTS OBJECTS
		   WHERE
		   '|| l_bind ||' AND
		   OBJECTS.OBJECT_TYPE = ''PAGE'' AND
		   BIS_BIA_RSG_PSTATE.get_refresh_mode(OBJECTS.REQUEST_SET_NAME) <> ''ANAL'' AND
		   OBJECTS.REQUEST_SET_NAME =  HISTORY.REQUEST_SET_NAME AND
		   HISTORY.PHASE_CODE = ''C'' AND
		   (HISTORY.STATUS_CODE = ''C'' OR  HISTORY.STATUS_CODE = ''G'')
           )
             where rk =1
           )
           LAST_SUCCESSFUL_REFRESH,

           (
           SELECT OBJECTS.OBJECT_NAME,
		          LOOKUPS.MEANING Current_Status,
   		         min(START_DATE) Refresh_Start_Time
		   FROM BIS_RS_RUN_HISTORY HISTORY, BIS_REQUEST_SET_OBJECTS OBJECTS,  FND_LOOKUPS LOOKUPS
		   WHERE
		   '|| l_bind ||' AND
		   OBJECTS.OBJECT_TYPE = ''PAGE'' AND
		   BIS_BIA_RSG_PSTATE.get_refresh_mode(OBJECTS.REQUEST_SET_NAME) <>''ANAL'' AND
		   OBJECTS.REQUEST_SET_NAME =  HISTORY.REQUEST_SET_NAME AND
		   HISTORY.PHASE_CODE = ''R'' AND
		   HISTORY.PHASE_CODE = LOOKUPS.LOOKUP_CODE AND
		   LOOKUPS.LOOKUP_TYPE = ''BIS_RSG_PSTATE_RPT_LKP''  --modified for bug#5144541: rkumar
		   group by OBJECTS.OBJECT_NAME,LOOKUPS.MEANING
		   )
		   CURRENT_RUN,

		   (
		   SELECT
		   OBJECTS.OBJECT_NAME,
		   min(FND_CONC.REQUESTED_START_DATE)   REQUESTED_START_DATE
		   from
		   BIS_REQUEST_SET_OBJECTS OBJECTS,
		   FND_CONCURRENT_REQUESTS FND_CONC,
		   FND_REQUEST_SETS FND
		   where
		   '|| l_bind ||' AND
		   OBJECTS.OBJECT_TYPE = ''PAGE'' AND
		   BIS_BIA_RSG_PSTATE.get_refresh_mode(OBJECTS.REQUEST_SET_NAME) <> ''ANAL'' AND
		   OBJECTS.REQUEST_SET_NAME =  FND.REQUEST_SET_NAME AND
		   OBJECTS.SET_APP_ID = FND.APPLICATION_ID AND
		   to_char(FND.APPLICATION_ID) = FND_CONC.ARGUMENT1 AND
		   to_char(FND.REQUEST_SET_ID) = FND_CONC.ARGUMENT2 AND
		   FND_CONC.PHASE_CODE = ''P'' AND
		   FND_CONC.STATUS_CODE = ''I''
		   group by objects.object_name
		   )
		   NEXT_SCHEDULED_REFRESH

		   WHERE
                   DISP.TYPE=''PAGE'' AND --added for enh 4638578
		   bis_impl_dev_pkg.get_function_by_page(NEXT_SCHEDULED_REFRESH.object_name(+))  = DISP.ID AND
  		   bis_impl_dev_pkg.get_function_by_page(CURRENT_RUN.object_name(+)) = DISP.ID AND
  		   bis_impl_dev_pkg.get_function_by_page(LAST_SUCCESSFUL_REFRESH.object_name(+)) = DISP.ID
		   ';

		    --END OF l_sql_stmt
  else -- here the query for report goes
    debug ('in report if');
    DEBUG('IN MAIN CONTENT_NAME'||content_name);
    --l_rs_names := get_rs_for_content(content_name,'REPORT');
    --debug('rs_names'||l_rs_names);
    l_sql_stmt := '  select
           DISP.value BIS_BIA_RSG_PAGE_NAME_DISPLAY,
           BIS_RSG_PMV_REPORT_PKG.date_to_charDTTZ( LAST_SUCCESSFUL_REFRESH.Last_Refresh_Time ) BIS_BIA_RSG_PAGE_LSTREFDATE,
           LAST_SUCCESSFUL_REFRESH.Last_Refresh_Duration BIS_BIA_RSG_PAGE_LAST_REFDUR,
           CURRENT_RUN.Current_Status BIS_BIA_RSG_PAGE_STATUS,
           BIS_RSG_PMV_REPORT_PKG.date_to_charDTTZ(CURRENT_RUN.Refresh_Start_Time) BIS_BIA_RSG_PAGE_REFSTARTTIME,
           BIS_RSG_PMV_REPORT_PKG.date_to_charDTTZ(NEXT_SCHEDULED_REFRESH.REQUESTED_START_DATE) BIS_BIA_RSG_PAGE_NEXTREF,
           decode('''||plan_url||''','' '',null,'''|| plan_text||''') BIS_BIA_RSG_PAGE_REFPLAN,
	   decode('''||plan_url||''','' '',null,'''||plan_url||''') BISREPORTURL
           from
           (SELECT ''Dummy'' JOIN_COL,id,value from BIS_BIA_RSG_PAGE_STATUS_V where TYPE=''REPORT''
           AND ID=:CONTENT_NAME) DISP,
           ( select ''Dummy'' AS JOIN_COL,
             decode(Last_Refresh_Time,to_date(''01-01-1900'',''DD-MM-YYYY''),null,Last_Refresh_Duration) Last_Refresh_Duration,
             BIS_BIA_RSG_PSTATE.sync_last_refresh_time(Last_refresh_time) Last_Refresh_Time
	     from (SELECT Last_Refresh_Duration,
                   bis_submit_requestset.get_last_refreshdate(''REPORT'',null,:CONTENT_NAME) Last_refresh_time
                   from
                  (select BIS_BIA_RSG_PSTATE.duration(COMPLETION_DATE - START_DATE) Last_Refresh_Duration
		   FROM BIS_RS_RUN_HISTORY HISTORY   WHERE
		   HISTORY.REQUEST_SET_NAME IN
                           (select request_set_name RS_NAME from (select request_set_name --request set for dashboard that has this report
                            from bis_request_set_objects where object_name in ( select Distinct obj.OBJECT_NAME
                            from bis_obj_dependency obj where object_type in (''PAGE'') and enabled_flag=''Y''
                            start with obj.depend_object_type =''REPORT'' and obj.depend_object_name=:CONTENT_NAME
                            connect by prior obj.OBJECT_NAME=obj.depend_object_name and
                            prior obj.OBJECT_TYPE=obj.depend_object_TYPE) and object_type =''PAGE'' union -- request set for report directly
                            select request_set_name RS_NAME from bis_request_set_objects
                            where object_name =:CONTENT_NAME and object_type =''REPORT'')
                            where BIS_BIA_RSG_PSTATE.get_refresh_mode(REQUEST_SET_NAME) != ''ANAL'') AND
		   HISTORY.PHASE_CODE = ''C'' AND
		   (HISTORY.STATUS_CODE = ''C'' OR  HISTORY.STATUS_CODE = ''G'')
                   order by start_date desc
                   )
                   where rownum =1 )
           )
           LAST_SUCCESSFUL_REFRESH,
           (
           SELECT ''Dummy'' AS JOIN_COL,
		          LOOKUPS.MEANING Current_Status,
   		         min(START_DATE) Refresh_Start_Time
		   FROM BIS_RS_RUN_HISTORY HISTORY,  FND_LOOKUPS LOOKUPS
		   WHERE
		   HISTORY.REQUEST_SET_NAME IN
                            (select request_set_name RS_NAME from (select request_set_name --request set for dashboard that has this report
                            from bis_request_set_objects where object_name in ( select Distinct obj.OBJECT_NAME
                            from bis_obj_dependency obj where object_type in (''PAGE'') and enabled_flag=''Y''
                            start with obj.depend_object_type =''REPORT'' and obj.depend_object_name=:CONTENT_NAME
                            connect by prior obj.OBJECT_NAME=obj.depend_object_name and
                            prior obj.OBJECT_TYPE=obj.depend_object_TYPE) and object_type =''PAGE'' union -- request set for report directly
                            select request_set_name RS_NAME from bis_request_set_objects
                            where object_name =:CONTENT_NAME and object_type =''REPORT'')
                            where BIS_BIA_RSG_PSTATE.get_refresh_mode(REQUEST_SET_NAME) != ''ANAL'')AND
		   HISTORY.PHASE_CODE = ''R'' AND
		   HISTORY.PHASE_CODE = LOOKUPS.LOOKUP_CODE AND
		   LOOKUPS.LOOKUP_TYPE = ''BIS_RSG_PSTATE_RPT_LKP''
                   group by history.request_id,LOOKUPS.MEANING
		   )
		   CURRENT_RUN,
           	   (
		   SELECT ''Dummy'' AS JOIN_COL,
		   min(FND_CONC.REQUESTED_START_DATE)   REQUESTED_START_DATE
		   from
		   BIS_REQUEST_SET_OBJECTS OBJECTS,
		   FND_CONCURRENT_REQUESTS FND_CONC,
		   FND_REQUEST_SETS FND
		   where
                   OBJECTS.REQUEST_SET_NAME in(select request_set_name RS_NAME from (select request_set_name --request set for dashboard that has this report
                            from bis_request_set_objects where object_name in ( select Distinct obj.OBJECT_NAME
                            from bis_obj_dependency obj where object_type in (''PAGE'') and enabled_flag=''Y''
                            start with obj.depend_object_type =''REPORT'' and obj.depend_object_name=:CONTENT_NAME
                            connect by prior obj.OBJECT_NAME=obj.depend_object_name and
                            prior obj.OBJECT_TYPE=obj.depend_object_TYPE) and object_type =''PAGE'' union -- request set for report directly
                            select request_set_name RS_NAME from bis_request_set_objects
                            where object_name =:CONTENT_NAME and object_type =''REPORT'')
                            where BIS_BIA_RSG_PSTATE.get_refresh_mode(REQUEST_SET_NAME) != ''ANAL'') and
		   OBJECTS.REQUEST_SET_NAME = FND.REQUEST_SET_NAME AND
		   OBJECTS.SET_APP_ID = FND.APPLICATION_ID AND
		   to_char(FND.APPLICATION_ID) = FND_CONC.ARGUMENT1 AND
		   to_char(FND.REQUEST_SET_ID) = FND_CONC.ARGUMENT2 AND
		   FND_CONC.PHASE_CODE = ''P'' AND
		   FND_CONC.STATUS_CODE = ''I''
                   group by fnd_conc.request_id
		   )
		   NEXT_SCHEDULED_REFRESH
	           WHERE
		   NEXT_SCHEDULED_REFRESH.JOIN_COL(+)  = DISP.JOIN_COL AND
  		   CURRENT_RUN.JOIN_COL(+) = DISP.JOIN_COL AND
  		   LAST_SUCCESSFUL_REFRESH.JOIN_COL(+) = DISP.JOIN_COL
		   ';

		    --END OF l_sql_stmt
  end if;

  debug ('IN MAIN after if');
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := bis_query_attributes_tbl();

  l_sql_stmt := l_sql_stmt || ' and DISP.ID = :CONTENT_NAME' ;

  l_custom_rec.attribute_name := ':CONTENT_NAME';
  l_custom_rec.attribute_value := content_name;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;
  --- we have inserted the parameter directly in the query, as pmv does not allow
  ---- bind parameter length to exceed more than 255..
  /*
  IF(CONTENT_TYPE='REPORT') THEN
    debug ('IN MAIN setting up rs name');
    l_custom_rec.attribute_name := ':RS_NAME';
    l_custom_rec.attribute_value := l_rs_names;
    l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
    x_custom_output.extend;
    x_custom_output(2) := l_custom_rec;
  END IF;*/

  debug ('IN MAIN after setting up rs_name');
  --debug(l_sql_stmt);
  l_sql_stmt := l_sql_stmt || ' &' || 'ORDER_BY_CLAUSE NULLS LAST ';

  x_custom_sql := l_sql_stmt;

END GET_SQL ;


END; -- Package Body BIS_BIA_RSG_PSTATE

/
