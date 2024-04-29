--------------------------------------------------------
--  DDL for Package Body BIS_RSG_PMV_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_RSG_PMV_REPORT_PKG" AS
/* $Header: BISRSPRB.pls 120.2 2006/03/27 09:34:38 amitgupt noship $ */

PROCEDURE debug (	text varchar2 )
IS
BEGIN
 --INSERT INTO AMIT_DEBUG(TEXT) VALUES(text);
 --commit;
 null;
END;

FUNCTION  returnLogUrl(req_id Number, fromReport Number) return Varchar2 IS

  pUrlString Varchar2(300);

BEGIN
  ---pUrlString := fnd_webfile.get_url(3, req_id, null, null, 1);

  --if(pUrlString is NULL) then
     if(fromReport = 1) then
       pUrlString := 'pFunctionName=BIS_BIA_RSG_RPT_ERR_MSG_PG&formErrorType=NO_LOG_URL1&formRSID='||req_id;
     else
       pUrlString := 'pFunctionName=BIS_BIA_RSG_RPT_ERR_MSG_PG&formErrorType=NO_LOG_URL&formRSID='||req_id;
     end if;
  --end if;

  return pUrlString;
END returnLogUrl;

FUNCTION format (p_value IN NUMBER) RETURN VARCHAR2  IS
  l_str   VARCHAR2 (30);
BEGIN
  l_str := '';
  IF p_value < 10
  THEN
    l_str := '0' || TO_CHAR (p_value);
  ELSE
    l_str := p_value;
  END IF;

  RETURN l_str;
END format;

FUNCTION time_interval (p_interval IN NUMBER)RETURN NUMBER
IS
  l_dummy    NUMBER;

BEGIN
  l_dummy := p_interval * 24;
  RETURN l_dummy;
END time_interval;


FUNCTION time_interval_str (p_interval IN NUMBER) RETURN VARCHAR2
IS
  l_result   VARCHAR2 (30);
  l_dummy    PLS_INTEGER;
BEGIN
  l_dummy := FLOOR (p_interval) * 24 + MOD (FLOOR (p_interval * 24), 24);
  l_result := format (l_dummy) || ':';
  l_dummy := MOD (FLOOR (p_interval * 24 * 60), 60);
  l_result := l_result || format (l_dummy) || ':';
  l_dummy := MOD (FLOOR (p_interval * 24 * 60 * 60), 60);
  l_result := l_result || format (l_dummy);
  RETURN l_result;
END time_interval_str;

FUNCTION time_interval_HHMM (p_interval IN NUMBER) RETURN VARCHAR2
IS
  l_result   VARCHAR2 (30);
  l_dummy    PLS_INTEGER;
BEGIN
  l_dummy := FLOOR (p_interval) * 24 + MOD (FLOOR (p_interval * 24), 24);
  l_result := format (l_dummy) || ':';
  l_dummy := MOD (FLOOR (p_interval * 24 * 60), 60);
  l_result := l_result || format (l_dummy) ;
RETURN l_result;
END time_interval_HHMM;


FUNCTION duration(
	p_duration		number) return NUMBER IS
BEGIN
   if(p_duration is null) then
     return null;
   else
     return time_interval(p_duration);
   end if;
END duration;

FUNCTION duration_HHMM(
	p_duration		number) return VARCHAR2 IS
BEGIN
   if(p_duration is null) then
     return null;
   else
     return time_interval_HHMM(p_duration);
   end if;
END duration_HHMM;

FUNCTION duration_str(
	p_duration		number) return VARCHAR2 IS
BEGIN
   if(p_duration is null) then
     return null;
   else
     return time_interval_str(p_duration);
   end if;
END duration_str;

FUNCTION get_meaning(p_status_code VARCHAR2,
                   p_phase_code VARCHAR2) return VARCHAR2 IS

l_meaning VARCHAR2(80);
BEGIN
  -- if status code is normal('C') then we have to display Completed, else take the value for
  -- that status code
  IF (p_status_code = 'C') THEN
    SELECT MEANING INTO l_meaning FROM FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'CP_PHASE_CODE' AND
    LOOKUP_CODE = p_phase_code;
  ELSE
    SELECT MEANING INTO l_meaning FROM FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'CP_STATUS_CODE' AND
    LOOKUP_CODE = p_status_code;
  END IF;

  return l_meaning;

END get_meaning;

 --added for bug 4486989
 -- function is added for timezone conversion
 -- is also being called from BIS_SUBMIT_REQUESTSET AND BIS_BIA_RSG_PSTATE
FUNCTION date_to_charDTTZ(pServerDate DATE) return varchar2 IS
l_server_code varchar2(50);
l_client_code varchar2(50);
l_client_date DATE;
BEGIN
 -- get the timezones code
 l_server_code := fnd_timezones.get_server_timezone_code;
 l_client_code := fnd_timezones.get_client_timezone_code;

 -- call adjust time zone to convert to client timezone
 l_client_date := fnd_timezones_pvt.adjust_datetime(
						date_time => pServerDate
						,from_tz => l_server_code
						,to_tz => l_client_code
						);
  --convert the date format
  return to_char(l_client_date,FND_PROFILE.value('ICX_DATE_FORMAT_MASK') || ' HH24:MI:SS');
END date_to_charDTTZ;

PROCEDURE request_set_perf_report
               (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY 	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sql_stmt    VARCHAR2(32767);
  l_custom_rec  BIS_QUERY_ATTRIBUTES;
  pname         VARCHAR2(2000);
  pvalue        VARCHAR2(2000);
  pid           VARCHAR2(2000);
  rs_id         VARCHAR2(2200);
  rs_type       varchar2(30);
  rs_history    varchar2(30);

  l_col         VARCHAR2(100);
  view_by_id    Number;
  counter       Number;
  l_days_cond   VARCHAR2(200);
  l_type_cond   VARCHAR2(200);
  l_rsid_cond   VARCHAR2(2200);

BEGIN

  pname      := NULL;
  pvalue     := NULL;
  pid        := NULL;
  rs_id      := null;
  rs_type    := null;
  rs_history := null;
  l_col      := NULL;
  view_by_id := 0;
  counter    :=1;
  l_days_cond  := NULL;
  l_type_cond  := NULL;
  l_rsid_cond  := NULL;

  FOR counter IN 1..p_param.count LOOP
    pname  := p_param(counter).parameter_name;
    pvalue := p_param(counter).parameter_value;
    pid :=  p_param(counter).parameter_id;
  --         debug( '( ' || pname || ', ' || pvalue  || ' )' );

    if pname = 'BIS_D_RS_NAME+BIS_D_RS_NAME' then
  --          debug( '( ' || pname || ' PID_amit, ' || pid  || ' )' );
      rs_id := pid ;
    end if;

    if pname = 'BISDRSTYPE+BISDRSTYPE' then
      rs_type := pid ;
    end if;

    if pname = 'BISDRSDAYS+BISDRSDAYS' then
      rs_history := pid ;
    end if;

    IF ( UPPER(pname) LIKE '%VIEW_BY%') THEN
      IF( UPPER(pvalue) =  'BIS_D_RS_NAME+BIS_D_RS_NAME' ) THEN
        l_col      := 'request_set_id';
        view_by_id := 0;
      END IF;
      IF( UPPER(pvalue) =  'BISDRSTYPE+BISDRSTYPE' ) THEN
        l_col      := 'request_set_type';
        view_by_id := 1;
      END IF;
    END IF;

  END LOOP;

  counter :=1;

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := bis_query_attributes_tbl();

  if (rs_history is not null AND rs_history <> 'All') then
    l_days_cond := 'and r.last_update_date >= sysdate - :BIND_HISTORY ';
    l_sql_stmt  := l_sql_stmt|| l_days_cond;
    l_custom_rec.attribute_name := ':BIND_HISTORY';
    l_custom_rec.attribute_value := rs_history;
    l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
    x_custom_output.extend;
    x_custom_output(counter) := l_custom_rec;
    counter:= counter+1;
  end if;

  if (rs_type is not null AND rs_type <> 'All') then
    l_type_cond := 'and r.request_set_type= :BIND_TYPE ';
    l_sql_stmt := l_sql_stmt || l_type_cond;

    l_custom_rec.attribute_name := ':BIND_TYPE';
    l_custom_rec.attribute_value := rs_type;
    l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
    x_custom_output.extend;
    x_custom_output(counter) := l_custom_rec;
  end if;

  if (rs_id is not null AND rs_id <> 'All') then
      l_rsid_cond := 'and r.request_set_id in (' || rs_id||') ';
  end if;

  --if view by is request set type
  IF(view_by_id = 1) THEN
    l_sql_stmt := 'select
                   view_type.value AS VIEWBY,
                   view_type.ID AS VIEWBYID,
                   BIS_RSG_PMV_REPORT_PKG.duration(avg(avg_run_time)) AS BIS_TIME,
                   BIS_RSG_PMV_REPORT_PKG.duration_str(avg(avg_run_time)) AS BIS_REQUEST_REFRESH_TIME,
                   BIS_RSG_PMV_REPORT_PKG.duration(max(max_run_time)) AS BIS_MAXIMUM,
		   BIS_RSG_PMV_REPORT_PKG.duration_str(max(max_run_time)) AS BIS_MAX,
                   BIS_RSG_PMV_REPORT_PKG.duration(min(min_run_time)) AS BIS_MINIMUM,
                   BIS_RSG_PMV_REPORT_PKG.duration_str(min(min_run_time)) AS BIS_MIN,
                   sum(num_runs) AS BIS_RUN,
                   sum(space_use)/(1024*1024) AS BIS_RS_TOTAL_SPACE_OCCUPIED,
                   NULL
                   BISREPORTURL ';

  ELSE -- if the view by is request set name
    l_sql_stmt := 'select
                   view_type.value AS VIEWBY,
                   view_type.ID AS VIEWBYID,
                   BIS_RSG_PMV_REPORT_PKG.duration(avg_run_time) AS BIS_TIME,
                   BIS_RSG_PMV_REPORT_PKG.duration_str(avg_run_time) AS BIS_REQUEST_REFRESH_TIME,
                   BIS_RSG_PMV_REPORT_PKG.duration(max_run_time) AS BIS_MAXIMUM,
		   BIS_RSG_PMV_REPORT_PKG.duration_str(max_run_time) AS BIS_MAX,
                   BIS_RSG_PMV_REPORT_PKG.duration(min_run_time) AS BIS_MINIMUM,
                   BIS_RSG_PMV_REPORT_PKG.duration_str(min_run_time) AS BIS_MIN,
                   num_runs AS BIS_RUN,
                   space_use/(1024*1024) AS BIS_RS_TOTAL_SPACE_OCCUPIED,
                   nvl2(space_use,
                   ''pFunctionName=BIS_BIA_RSG_SPACE_DET_PGE&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'',
                   null)
                   BISREPORTURL ';

  end if;

  --common part of the query
  l_sql_stmt := l_sql_stmt || 'from
                (
                select agg_runs.request_set_id,
                agg_runs.request_set_type,
                min_run_time,
                max_run_time,
                Num_runs,
                avg_run_time
                from
		(select request_set_id,request_set_type
		,Min(completion_date-start_date) min_run_time
		,Max(completion_date-start_date) max_run_time
		,avg(completion_date- start_date) avg_run_time
		,R.REQUEST_SET_TYPE rstype
		from
		bis_rs_run_history r
		where
		r.phase_code =''C'' AND (STATUS_CODE=''G''
		or STATUS_CODE=''C'') ';

  l_sql_stmt:= l_sql_stmt||l_days_cond||  l_type_cond ||l_rsid_cond;

  l_sql_stmt:= l_sql_stmt || 'GROUP BY r.request_set_id,r.request_set_type ) agg_time, ';

  l_sql_stmt:= l_sql_stmt || '(Select request_set_id,request_set_type
		,count(r.request_set_id) Num_runs
		from
		bis_rs_run_history r, bis_rs_names_v v
		where
		r.phase_code =''C''
		AND v.id = r.request_set_id
		AND r.STATUS_CODE<>''X'' ';

		-- added join with bis_rs_names_v for bug 4293781

  l_sql_stmt:= l_sql_stmt||l_days_cond||  l_type_cond ||l_rsid_cond;

  l_sql_stmt:= l_sql_stmt || 'GROUP BY r.request_set_id,r.request_set_type ) agg_runs
               where agg_time.request_set_id(+)=agg_runs.request_set_id
               ) tmp, ';

  l_sql_stmt:= l_sql_stmt || '
               (select tmp.srid srid, sum(tmp.object_space_usage) space_use,tmp.rsid rsid, tmp.rstype rstype
               from
               (select distinct object_name, object_type, object_space_usage,p.set_request_id srid,
               Latestreq.request_set_id rsid,
               Latestreq.request_set_type rstype from bis_obj_refresh_history o,
               bis_rs_prog_run_history p,
               (select max(request_id) maxid, request_set_id,request_set_type
	                      from bis_rs_run_history WHERE PHASE_CODE=''C'' AND (STATUS_CODE=''C''
	                      OR STATUS_CODE =''G'')
               group by request_set_id,request_set_type) Latestreq
               where
               o.prog_request_id = p.request_id
               and p.set_request_id = Latestreq.maxid) tmp
               group by tmp.srid,tmp.rsid, tmp.rstype ) total_space ';

  --if view by is request set type
  IF(view_by_id = 1) THEN
    l_sql_stmt:= l_sql_stmt ||', BIS_RS_REFRESH_TYPE_V view_type ';
  ELSE
    l_sql_stmt:= l_sql_stmt ||', BIS_RS_NAMES_V view_type ';
  END IF;

  l_sql_stmt:= l_sql_stmt ||'where
               total_space.rsid(+)=tmp.request_set_id
               and view_type.ID = tmp.'||l_col;

  --if view by is request set type
  IF(view_by_id = 1) THEN
    l_sql_stmt:= l_sql_stmt || ' GROUP BY VIEW_TYPE.ID,VIEW_TYPE.VALUE ';
  END IF;

  l_sql_stmt := l_sql_stmt || ' &' || 'ORDER_BY_CLAUSE NULLS LAST ';

  --debug(l_sql_stmt);
  x_custom_sql := l_sql_stmt;

END request_set_perf_report ;

PROCEDURE request_set_perf_det_rep
               (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY 	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sql_stmt     VARCHAR2(32767);
  l_custom_rec   BIS_QUERY_ATTRIBUTES;
  pname          VARCHAR2(2000);
  pvalue         VARCHAR2(2000);
  pid            VARCHAR2(2000);
  rs_id          VARCHAR2(30);
  rs_type        varchar2(30);
  rs_history     varchar2(30);
  rs_run_id      varchar2(2000);

  counter        number;

BEGIN

  pname      := NULL;
  pvalue     := NULL;
  pid        := NULL;
  rs_id      := null;
  rs_type    := null;
  rs_history := null;
  rs_run_id  := NULL;
  counter    :=1;

  FOR counter IN 1..p_param.count LOOP
    pname  := p_param(counter).parameter_name;
    pvalue := p_param(counter).parameter_value;
    pid :=  p_param(counter).parameter_id;
           --debug( '( ' || pname || ', ' || pvalue  || ' )' );

    if pname = 'BIS_D_RS_NAME+BIS_D_RS_NAME' then
      rs_id := pid ;
    end if;

    if pname = 'BIS_D_RS_TYPE2+BIS_D_RS_TYPE2' then
      rs_type := pid ;
    end if;

    if pname = 'BISDRSDAYS+BISDRSDAYS' then
      rs_history := pid ;
    end if;

    if pname = 'BIS_D_RS_RUN_ID+BIS_D_RS_RUN_ID' then
        --         debug( '( ' || pname || ' PID_amit, ' || pid  || ' )' );
        --        debug( '( ' || pname || ', ' || pvalue  || ' )' );
      rs_run_id := pid ;
    end if;


  END LOOP;

  counter := 1;

  l_sql_stmt := 'select B.request_id AS VIEWBY,
  		 B.request_id AS VIEWBYID,
  		 BIS_RSG_PMV_REPORT_PKG.date_to_charDTTZ(start_date) AS BIS_RS_START_TIME,
                 BIS_RSG_PMV_REPORT_PKG.duration_str(completion_date - start_date) AS BIS_RS_DURATION,
                 BIS_RSG_PMV_REPORT_PKG.get_meaning(STATUS_CODE,PHASE_CODE) AS BIS_RS_STATUS,
                 ''pFunctionName=BIS_BIA_RSG_SUB_REQS_PGE&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'' BISREPORTURL
                 ,BIS_RSG_PMV_REPORT_PKG.returnLogUrl( B.request_id,2) BISLOGFILEURL
                 from BIS_RS_RUN_HISTORY B, FND_REQUEST_SETS_VL F
                 where F.request_set_id = B.request_set_id
                 AND PHASE_CODE = ''C'' and STATUS_CODE <>''X'' ';


  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := bis_query_attributes_tbl();


  if (rs_history is not null AND rs_history <> 'All') then
    l_sql_stmt:= l_sql_stmt||'and B.last_update_date >= sysdate - :BIND_HISTORY ';
    l_custom_rec.attribute_name := ':BIND_HISTORY';
    l_custom_rec.attribute_value := rs_history;
    l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
    x_custom_output.extend;
    x_custom_output(counter) := l_custom_rec;
    counter:= counter+1;
  end if;

  if (rs_type is not null AND rs_type <> 'All') then
    l_sql_stmt := l_sql_stmt || 'and B.request_set_type= :BIND_TYPE ';

    l_custom_rec.attribute_name := ':BIND_TYPE';
    l_custom_rec.attribute_value := rs_type;
    l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
    x_custom_output.extend;
    x_custom_output(counter) := l_custom_rec;
    counter:= counter+1;
  end if;

  if (rs_id is not null AND rs_id <> 'All') then
    l_sql_stmt := l_sql_stmt || 'and f.request_set_id= :BIND_RSID ';

    l_custom_rec.attribute_name := ':BIND_RSID';
    l_custom_rec.attribute_value := rs_id;
    l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
    x_custom_output.extend;
    x_custom_output(counter) := l_custom_rec;
  end if;

  if (rs_run_id is not null AND rs_run_id <> 'All') then
    l_sql_stmt := l_sql_stmt || 'and B.request_id in ('||rs_run_id||') ';
  end if;

  l_sql_stmt := l_sql_stmt || ' &' || 'ORDER_BY_CLAUSE NULLS LAST ';

  --debug(l_sql_stmt);
  x_custom_sql := l_sql_stmt;

END request_set_perf_det_rep ;

PROCEDURE request_set_sub_req_rep
               (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY 	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sql_stmt    VARCHAR2(32767);
  l_custom_rec  BIS_QUERY_ATTRIBUTES;
  pname         VARCHAR2(2000);
  pvalue        VARCHAR2(2000);
  pid           VARCHAR2(2000);
  rs_id         VARCHAR2(30);
  rs_type       varchar2(30);
  rs_history    varchar2(30);
  rs_run_id     varchar2(2000);
  rs_stage_req  varchar2(2000);
  rs_sub_req    varchar2(2000);
  rs_prog_req   varchar2(2000);


  counter       number;
  l_setid_cond  VARCHAR2(200);
  l_type_cond   VARCHAR2(200);
  l_runid_cond1 VARCHAR2(200);
  l_runid_cond2 VARCHAR2(200);
  l_stage_cond1 VARCHAR2(200);
  l_stage_cond2 VARCHAR2(200);
  l_prog_cond   VARCHAR2(2200);
  l_prog_cond2  VARCHAR2(2200);

BEGIN
  pname        := NULL;
  pvalue       := NULL;
  pid          := NULL;
  rs_id        := null;
  rs_type      := null;
  rs_history   := null;
  rs_run_id    :=null;
  rs_stage_req :=null;
  rs_sub_req   :=null;
  rs_prog_req  :=null;


  counter       :=1;
  l_setid_cond  :=NULL;
  l_type_cond   :=NULL;
  l_runid_cond1 :=NULL;
  l_runid_cond2 :=NULL;
  l_stage_cond1 :=NULL;
  l_stage_cond2 :=NULL;
  l_prog_cond   :=NULL;
  l_prog_cond2  :=NULL;

  FOR counter IN 1..p_param.count LOOP
    pname  := p_param(counter).parameter_name;
    pvalue := p_param(counter).parameter_value;
    pid :=  p_param(counter).parameter_id;
  ---  debug( '( ' || pname || ', ' || pvalue  || ', ' || pid  || ' )' );

    if pname = 'BISDRSDAYS+BISDRSDAYS' then
      rs_history := pid ;
    end if;

    if pname = 'BIS_D_RS_NAME+BIS_D_RS_NAME' then
      rs_id := pid ;
    end if;

    if pname = 'BIS_D_RS_TYPE2+BIS_D_RS_TYPE2' then
      rs_type := pid ;
    end if;

    if pname = 'BIS_D_RS_RUN_ID+BIS_D_RS_RUN_ID' then
      rs_run_id := pid ;
    end if;

    if pname = 'BISDRSSTAGE+BISDRSSTAGE' then
      rs_stage_req := pid ;
    end if;

    /*if pname = 'BISDRSSUBR+BISDRSSUBR' then
      rs_sub_req := pid ;
    end if;*/

    if pname = 'BISDRSPROG+BISDRSPROG' then
      rs_prog_req := pid ;
    end if;

  END LOOP;

  counter := 1;

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := bis_query_attributes_tbl();


  if (rs_type is not null AND rs_type <> 'All') then
    l_type_cond :='and R.request_set_type= :BIND_TYPE ';

    l_custom_rec.attribute_name := ':BIND_TYPE';
    l_custom_rec.attribute_value := rs_type;
    l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
    x_custom_output.extend;
    x_custom_output(counter) := l_custom_rec;
    counter:= counter+1;
  end if;


  if (rs_id is not null AND rs_id <> 'All') then
    l_setid_cond:= 'and R.request_set_id= :BIND_RSID ';

    l_custom_rec.attribute_name := ':BIND_RSID';
    l_custom_rec.attribute_value := rs_id;
    l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
    x_custom_output.extend;
    x_custom_output(counter) := l_custom_rec;
    counter:=counter+1;
  end if;

  if (rs_run_id is not null AND rs_run_id <> 'All') then
    l_runid_cond1 := 'and R.request_id= :BIND_RUNID ';
    l_runid_cond2 := 'and B.set_request_id= :BIND_RUNID ';

    l_custom_rec.attribute_name := ':BIND_RUNID';
    l_custom_rec.attribute_value := rs_run_id;
    l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
    x_custom_output.extend;
    x_custom_output(counter) := l_custom_rec;
    counter:=counter+1;
  end if;

  if (rs_stage_req is not null AND rs_stage_req <> 'All') then
    --l_stage_cond1 := 'and B.request_id in ('|| rs_stage_req ||') ';
    l_stage_cond1 := 'and B.request_id = :BIND_STAGEID ';
    --l_stage_cond2 := 'and B.STAGE_REQUEST_ID in ('|| rs_stage_req ||') ';
    l_stage_cond2 := 'and B.STAGE_REQUEST_ID = :BIND_STAGEID ';

    l_custom_rec.attribute_name := ':BIND_STAGEID';
    l_custom_rec.attribute_value := rs_stage_req;
    l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
    x_custom_output.extend;
    x_custom_output(counter) := l_custom_rec;
  end if;

  if (rs_prog_req is not null AND rs_prog_req <> 'All') then
    l_prog_cond := 'and B.program_id in (' || rs_prog_req ||') ';
    l_prog_cond2:= 'and exists (Select 1 from bis_rs_prog_run_history where stage_request_id=B.request_id and program_id in(' || rs_prog_req ||'))';
  end if;

  l_sql_stmt := 'select
                 rid BIS_RS_SUB_REQS_ID,
    		 rname BIS_RS_REQUEST_NAME
    		, BIS_RSG_PMV_REPORT_PKG.date_to_charDTTZ(started) BIS_RS_START_TIME
    		,dur BIS_RS_DURATION
    		,BIS_RSG_PMV_REPORT_PKG.get_meaning(tmp.STATUS,''C'') BIS_RS_STATUS
    		,LOG_MESSAGE BIS_LOG_MESSAGE
    		,decode(url,'' '',null,url) BISREPORTURL
    		,BIS_RSG_PMV_REPORT_PKG.returnLogUrl(rid,1) BISLOGFILEURL
    		FROM ';

  l_sql_stmt:= l_sql_stmt||
               '(select R.request_id rid,F.user_request_set_name rname,
                R.start_date started,
                BIS_RSG_PMV_REPORT_PKG.Duration_str(R.completion_date-R.start_date) dur,
                STATUS_CODE status, R.completion_text LOG_MESSAGE, '' '' url
                from bis_rs_run_history R,fnd_request_sets_vl F
                where F.request_set_id = R.request_set_id AND R.PHASE_CODE=''C'' ' ||
                l_type_cond ||l_setid_cond ||l_runid_cond1
                ||' union
                select B.request_id rid, F.user_stage_name rname,
                B.start_date started,
                BIS_RSG_PMV_REPORT_PKG.Duration_str(B.completion_date-B.start_date) dur,
                B.STATUS_CODE status,B.completion_text LOG_MESSAGE,'' '' url
                from
                bis_rs_stage_run_history B, fnd_request_set_stages_vl F,bis_rs_run_history R
                where F.request_set_stage_id = B.stage_id
                and R.request_id = B.set_request_id AND R.PHASE_CODE=''C'' '
                ||l_type_cond||l_setid_cond||l_runid_cond2||l_stage_cond1||l_prog_cond2
                ||' union
                Select B.request_id rid, F.user_concurrent_program_name rname, B.start_date started,
                BIS_RSG_PMV_REPORT_PKG.Duration_str(B.completion_date-B.start_date) dur,
                B.STATUS_CODE status,B.completion_text LOG_MESSAGE,
                decode(num_obj,0,
                ''pFunctionName=BIS_BIA_RSG_RPT_ERR_MSG_PG&formErrorType=NO_OBJECT'',
                ''pFunctionName=BIS_BIA_RSG_REQ_DETAILS_PGE&BIS_RS_SUB_REQS_ID=BIS_RS_SUB_REQS_ID&BISRSSTAGE=''||B.stage_request_id||''&BISRSPROG=''||B.program_id||''&pParamIds=Y''
                ) url
                from
                bis_rs_prog_run_history B, fnd_concurrent_programs_vl F,
                bis_rs_run_history R,bis_rs_stage_run_history S,
                (select distinct prog_request_id prid, 1 num_obj from bis_obj_refresh_history
                union select request_id prid,0 num_obj from bis_rs_prog_run_history where request_id not
                in(select prog_request_id from bis_obj_refresh_history)) count_obj
                where F.concurrent_program_id = B.program_id
                and F.APPLICATION_ID = B.Prog_app_id
                and R.request_id=B.set_request_id
                and S.request_id=B.stage_request_id
                and B.request_id=count_obj.prid
                AND R.PHASE_CODE=''C'' '
                ||l_type_cond||l_setid_cond||l_runid_cond2||l_stage_cond2
                ||l_prog_cond ||
                ') tmp ';



  if (rs_sub_req is not null AND rs_sub_req <> 'All') then
    l_sql_stmt:=l_sql_stmt||'Where rid in ('|| rs_sub_req ||') ';
  end if;


  l_sql_stmt := l_sql_stmt || ' &' || 'ORDER_BY_CLAUSE NULLS LAST ';

  --  debug(l_sql_stmt);
  x_custom_sql := l_sql_stmt;

END request_set_sub_req_rep ;

PROCEDURE request_details_report
               (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY 	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sql_stmt    VARCHAR2(32767);
  l_custom_rec  BIS_QUERY_ATTRIBUTES;
  base          varchar2(257);
  pname         VARCHAR2(2000);
  pvalue        VARCHAR2(2000);
  pid           VARCHAR2(2000);
  rs_id         VARCHAR2(30);
  rs_type       varchar2(30);
  rs_history    varchar2(30);
  rs_run_id     varchar2(30);
  rs_stage_req  varchar2(200);
  rs_sub_req    varchar2(2000);
  rs_prog_req   varchar2(2000);

  counter       number;


BEGIN

  pname        := NULL;
  pvalue       := NULL;
  pid          := NULL;

  rs_id        := null;
  rs_type      := null;
  rs_history   := null;
  rs_run_id    :=null;
  rs_stage_req :=null;
  rs_sub_req   :=null;
  rs_prog_req  :=null;


  counter      :=1;

  FOR counter IN 1..p_param.count LOOP
    pname  := p_param(counter).parameter_name;
    pvalue := p_param(counter).parameter_value;
    pid :=  p_param(counter).parameter_id;
    --debug( '( ' || pname || ', ' || pvalue  || ' )' );

    if pname = 'BISDRSDAYS+BISDRSDAYS' then
      rs_history := pid ;
    end if;

    if pname = 'BIS_D_RS_NAME+BIS_D_RS_NAME' then
      rs_id := pid ;
    end if;

    if pname = 'BIS_D_RS_TYPE2+BIS_D_RS_TYPE2' then
      rs_type := pid ;
    end if;

    if pname = 'BIS_D_RS_RUN_ID+BIS_D_RS_RUN_ID' then
      rs_run_id := pid ;
    end if;

    if pname = 'BISDRSSTAGE+BISDRSSTAGE' then
      rs_stage_req := pid ;
    end if;

    /*if pname = 'BISDRSSUBR+BISDRSSUBR' then
      rs_sub_req := pid ;
    end if;*/

    if pname = 'BISDRSPROG+BISDRSPROG' then
      rs_prog_req := pid ;
    end if;

  END LOOP;

  counter := 1;
  fnd_profile.get('APPS_FRAMEWORK_AGENT', base);

  l_sql_stmt:='select distinct object_name BIS_REQUEST_OBJECT_NAME,
               --BIS_REQUESTSET_VIEWHISTORY.get_bis_lookup_meaning( ''BIS_OBJECT_TYPE'',O.OBJECT_TYPE) BIS_REQUEST_OBJECT_TYPE,
               CASE O.OBJECT_TYPE WHEN ''MV_LOG'' THEN BIS_REQUESTSET_VIEWHISTORY.get_sys_lookup_meaning( ''BIS_OBJECT_TYPE_RPT'',O.OBJECT_TYPE)
                                  WHEN ''BSC_CUSTOM_KPI'' THEN BIS_REQUESTSET_VIEWHISTORY.get_sys_lookup_meaning( ''BIS_OBJECT_TYPE_RPT'',O.OBJECT_TYPE)
               ELSE BIS_REQUESTSET_VIEWHISTORY.get_bis_lookup_meaning( ''BIS_OBJECT_TYPE'',O.OBJECT_TYPE) END BIS_REQUEST_OBJECT_TYPE,
               0 BIS_OBJECT_ROW_COUNT,
               decode(refresh_type,''INCR'',
               BIS_REQUESTSET_VIEWHISTORY.get_sys_lookup_meaning( ''BIS_REQUEST_SET_TYPE'',''INCR_LOAD''),
               ''ANALYZED'',
               BIS_REQUESTSET_VIEWHISTORY.get_bis_lookup_meaning( ''BIS_REFRESH_MODE'',''ANALYZED''),
               ''CONSIDER_REFRESH'',
               BIS_REQUESTSET_VIEWHISTORY.get_bis_lookup_meaning( ''BIS_REFRESH_MODE'',''CONSIDER_REFRESH''),
               BIS_REQUESTSET_VIEWHISTORY.get_sys_lookup_meaning( ''BIS_REQUEST_SET_TYPE'',''INIT_LOAD'')) BIS_REQUEST_REFRESH_TYPE,
               null BIS_RS_STATUS,
               decode(O.OBJECT_TYPE,''MV_LOG'',NULL,''BSC_CUSTOM_KPI'',NULL,'||''''||
               'pFunctionName=BIS_BIA_RSG_DEPENDENCIES_ALONE'
               ||'&requestType=RSGReport&ObjType=''||o.object_type||''&ObjName=BIS_REQUEST_OBJECT_NAME''
               ) BISREPORTURL
               from bis_obj_refresh_history O,bis_rs_prog_run_history P,bis_rs_run_history R,
               bis_rs_stage_run_history S
               where O.prog_request_id = P.request_id
               AND R.REQUEST_ID = S.SET_REQUEST_ID
               AND S.REQUEST_ID = P.STAGE_REQUEST_ID
               AND R.PHASE_CODE = ''C'' ';

 l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
 x_custom_output := bis_query_attributes_tbl();

 if (rs_type is not null AND rs_type <> 'All') then
   l_sql_stmt :=l_sql_stmt||'and R.REQUEST_SET_TYPE= :BIND_TYPE ';

   l_custom_rec.attribute_name := ':BIND_TYPE';
   l_custom_rec.attribute_value := rs_type;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.extend;
   x_custom_output(counter) := l_custom_rec;
   counter:= counter+1;
 end if;


 if (rs_id is not null AND rs_id <> 'All') then
   l_sql_stmt :=l_sql_stmt||'and R.REQUEST_SET_ID= :BIND_RSID ';
   l_custom_rec.attribute_name := ':BIND_RSID';
   l_custom_rec.attribute_value := rs_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.extend;
   x_custom_output(counter) := l_custom_rec;
   counter:=counter+1;
 end if;

 if (rs_stage_req is not null AND rs_stage_req <> 'All') then
   l_sql_stmt :=l_sql_stmt|| 'and S.request_id = :BIND_STAGEID ';
   l_custom_rec.attribute_name := ':BIND_STAGEID';
   l_custom_rec.attribute_value := rs_stage_req;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.extend;
   x_custom_output(counter) := l_custom_rec;
   counter:=counter+1;
 end if;

 if (rs_prog_req is not null AND rs_prog_req <> 'All') then
   l_sql_stmt :=l_sql_stmt|| 'and P.program_id in (' ||rs_prog_req||') ';
 end if;

 if (rs_run_id is not null AND rs_run_id <> 'All') then
   l_sql_stmt :=l_sql_stmt||'and R.request_id= :BIND_RUNID ';

   l_custom_rec.attribute_name := ':BIND_RUNID';
   l_custom_rec.attribute_value := rs_run_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.extend;
   x_custom_output(counter) := l_custom_rec;
 end if;

 if (rs_sub_req is not null AND rs_sub_req <> 'All') then
   l_sql_stmt :=l_sql_stmt||'and P.request_id IN ('||rs_sub_req ||') ';
 end if;

  l_sql_stmt := l_sql_stmt || ' &' || 'ORDER_BY_CLAUSE NULLS LAST ';

  --debug(l_sql_stmt);
  x_custom_sql := l_sql_stmt;

END request_details_report ;


PROCEDURE request_set_space_rep
               (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY 	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sql_stmt         VARCHAR2(32767);
  l_custom_rec       BIS_QUERY_ATTRIBUTES;
  base               VARCHAR2(257);
  pname              VARCHAR2(2000);
  pvalue             VARCHAR2(2000);
  pid                VARCHAR2(2000);
  rs_id              VARCHAR2(30);
  rs_type            VARCHAR2(30);
  rs_latest_id       VARCHAR2(30);
  rs_stage_req       varchar2(200);
  rs_prog_req        varchar2(2000);


  counter            number;


BEGIN

  pname        := NULL;
  pvalue       := NULL;
  pid          := NULL;
  rs_id        := NULL;
  rs_type      := NULL;
  rs_latest_id := NULL;
  rs_stage_req := NULL;
  rs_prog_req  := NULL;

  counter      :=1;

  FOR counter IN 1..p_param.count LOOP
    pname  := p_param(counter).parameter_name;
    pvalue := p_param(counter).parameter_value;
    pid :=  p_param(counter).parameter_id;
  --  debug( '( ' || pname || ', ' || pvalue  ||', ' || pid || ' )' );

    if pname = 'BIS_D_RS_NAME+BIS_D_RS_NAME' then
      rs_id := pid ;
    end if;

    if pname = 'BISDRSSTAGE+BISDRSSTAGE' then
      rs_stage_req := pid ;
    end if;

    if pname = 'BISDRSPROG+BISDRSPROG' then
      rs_prog_req := pid ;
    end if;

  END LOOP;

  counter := 1;
  fnd_profile.get('APPS_FRAMEWORK_AGENT', base);

  l_sql_stmt:='SELECT Distinct OBJECT_NAME BIS_REQUEST_OBJECT_NAME,
               --BIS_REQUESTSET_VIEWHISTORY.get_bis_lookup_meaning( ''BIS_OBJECT_TYPE'',O.OBJECT_TYPE) BIS_REQUEST_OBJECT_TYPE,
	       CASE O.OBJECT_TYPE WHEN ''MV_LOG'' THEN BIS_REQUESTSET_VIEWHISTORY.get_sys_lookup_meaning( ''BIS_OBJECT_TYPE_RPT'',O.OBJECT_TYPE)
	                          WHEN ''BSC_CUSTOM_KPI'' THEN BIS_REQUESTSET_VIEWHISTORY.get_sys_lookup_meaning( ''BIS_OBJECT_TYPE_RPT'',O.OBJECT_TYPE)
               ELSE BIS_REQUESTSET_VIEWHISTORY.get_bis_lookup_meaning( ''BIS_OBJECT_TYPE'',O.OBJECT_TYPE) END BIS_REQUEST_OBJECT_TYPE,
               O.TABLESPACE_NAME BIS_TABLESPACE_NAME,
               -- next two columns are not in use anymore..
               0 BIS_TABLESPACE_SIZE,
               0 BIS_TABLESPACE_FREE_SPACE,
               OBJECT_SPACE_USAGE/(1024*1024) BIS_RS_TOTAL_SPACE_OCCUPIED,
               object_row_count BIS_OBJECT_ROW_COUNT,
               (OBJECT_SPACE_USAGE/TOTAL_SPACE.BYTES)*100 BIS_RS_PCT_SPACE_USED,
               decode(O.OBJECT_TYPE,''MV_LOG'',NULL,''BSC_CUSTOM_KPI'',NULL,'||''''||
               'pFunctionName=BIS_BIA_RSG_DEPENDENCIES_ALONE'
	       ||'&requestType=RSGReport&ObjType=''||o.object_type||''&ObjName=BIS_REQUEST_OBJECT_NAME''
               ) BISREPORTURL
               from BIS_OBJ_REFRESH_HISTORY O,
               (select max(request_id) maxid, request_set_id rsid,request_set_type rstype
               from bis_rs_run_history WHERE PHASE_CODE=''C'' AND (STATUS_CODE=''C''
               OR STATUS_CODE =''G'')
               group by request_set_id,request_set_type) Latestreq,
               bis_rs_prog_run_history P, bis_rs_stage_run_history S,
               (select	TABLESPACE_NAME, sum(BYTES) BYTES from 	dba_data_files
               group by TABLESPACE_NAME) TOTAL_SPACE
               where
               Latestreq.maxid=S.set_request_id
               and S.request_id= P.stage_request_id
               and P.request_id=O.prog_request_id
               AND TOTAL_SPACE.TABLESPACE_NAME=O.TABLESPACE_NAME ';

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := bis_query_attributes_tbl();

  if (rs_id is not null AND rs_id <> 'All') then
    l_sql_stmt :=l_sql_stmt||'and Latestreq.rsid= :BIND_RSID ';

    l_custom_rec.attribute_name := ':BIND_RSID';
    l_custom_rec.attribute_value := rs_id;
    l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
    x_custom_output.extend;
    x_custom_output(counter) := l_custom_rec;
    counter:=counter+1;
  end if;

  if (rs_stage_req is not null AND rs_stage_req <> 'All') then
   l_sql_stmt :=l_sql_stmt|| 'and S.request_id = :BIND_STAGEID ';
   l_custom_rec.attribute_name := ':BIND_STAGEID';
   l_custom_rec.attribute_value := rs_stage_req;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.extend;
   x_custom_output(counter) := l_custom_rec;
  end if;

  if (rs_prog_req is not null AND rs_prog_req <> 'All') then
    l_sql_stmt :=l_sql_stmt|| 'and P.program_id in ('|| rs_prog_req||') ';
  end if;

  l_sql_stmt := l_sql_stmt || ' &' || 'ORDER_BY_CLAUSE NULLS LAST ';

  --debug(l_sql_stmt);
  x_custom_sql := l_sql_stmt;

END request_set_space_rep ;

PROCEDURE tablespace_detail_report
               (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY 	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sql_stmt    VARCHAR2(32767);
  l_custom_rec	BIS_QUERY_ATTRIBUTES;
  pname         VARCHAR2(2000);
  pvalue        VARCHAR2(2000);
  pid           VARCHAR2(2000);
  ts_name       VARCHAR2(30);

  counter       number;


BEGIN

  pname     := NULL;
  pvalue    := NULL;
  pid       := NULL;
  ts_name   := null;

  counter   :=1;

  FOR counter IN 1..p_param.count LOOP
    pname  := p_param(counter).parameter_name;
    pvalue := p_param(counter).parameter_value;
    pid :=  p_param(counter).parameter_id;
    --debug( '( ' || pname || ', ' || pvalue  || ' )' );

    if pname = 'BIS_TABLESPACE_NAME+BIS_TABLESPACE_NAME' then
      ts_name := pid ;
    end if;

  END LOOP;

  l_sql_stmt:='select	DB_TS.TABLESPACE_NAME BIS_TS_NAME_PARAM,
               TOTAL_SPACE.BYTES/(1024*1024) BIS_TABLESPACE_SIZE,
               INITIAL_EXTENT/(1024*1024) BIS_TS_INIT_EXTENT,
               NEXT_EXTENT/(1024*1024) BIS_TS_NEXT_EXTENT,
               MAX_EXTENTS BIS_TS_MAX_EXTENT,
               free_space.BYTES/(1024*1024) BIS_TABLESPACE_FREE_SPACE
               from 	dba_tablespaces DB_TS,
               (select	TABLESPACE_NAME, sum(BYTES) BYTES from 	dba_data_files
               group by TABLESPACE_NAME) TOTAL_SPACE,
               (select	TABLESPACE_NAME, sum(BYTES) BYTES from 	dba_free_space
               group by TABLESPACE_NAME) FREE_SPACE
               WHERE  free_space.tablespace_name=db_ts.tablespace_name
               AND total_space.tablespace_name=db_ts.tablespace_name
               AND db_ts.contents = ''PERMANENT'' ';

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := bis_query_attributes_tbl();

  if (ts_name is not null AND ts_name <> 'All') then
    l_sql_stmt :=l_sql_stmt||'and db_ts.tablespace_name= :BIND_NAME ';

    l_custom_rec.attribute_name := ':BIND_NAME';
    l_custom_rec.attribute_value := ts_name;
    l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
    x_custom_output.extend;
    x_custom_output(1) := l_custom_rec;
  end if;


  l_sql_stmt := l_sql_stmt || ' &' || 'ORDER_BY_CLAUSE NULLS LAST ';

  --debug(l_sql_stmt);
  x_custom_sql := l_sql_stmt;

END tablespace_detail_report ;

FUNCTION  gtitle(p_param 	 		BIS_PMV_PAGE_PARAMETER_TBL) return varchar2 IS

  pname         VARCHAR2(2000);
  pvalue        VARCHAR2(2000);
  pid           VARCHAR2(2000);

BEGIN
  pname     := NULL;
  pvalue    := NULL;
  pid       := NULL;

  FOR counter IN 1..p_param.count LOOP
    pname  := p_param(counter).parameter_name;
    pvalue := p_param(counter).parameter_value;
    pid :=  p_param(counter).parameter_id;

    IF ( UPPER(pname) LIKE '%VIEW_BY%') THEN
          IF( UPPER(pvalue) =  'BIS_D_RS_NAME+BIS_D_RS_NAME' ) THEN
            return BIS_REQUESTSET_VIEWHISTORY.get_sys_lookup_meaning('BIS_BIA_RSG_REPORT','GRAPH_TITLE_NAME');
          END IF;
          IF( UPPER(pvalue) =  'BISDRSTYPE+BISDRSTYPE' ) THEN
            return BIS_REQUESTSET_VIEWHISTORY.get_sys_lookup_meaning('BIS_BIA_RSG_REPORT','GRAPH_TITLE_TYPE');
          END IF;
    END IF;

  END LOOP;

END gtitle;

FUNCTION  get_max_stg(prog_id Number,
                       set_req_id Number,
                       stage_id Varchar2) return Number IS
  l_stmt Varchar2(200);
  stg_req_id Number;

  cursor get_max_stg (pid NUMBER ,srid NUMBER) is
  Select max(stage_request_id) from bis_rs_prog_run_history where program_id=pid
  and set_request_id= srid;

BEGIN

  if(stage_id = 'ALL') then
    stg_req_id := NULL;
    open get_max_stg(prog_id,set_req_id);
    Fetch get_max_stg into stg_req_id;
    close get_max_stg;
    return stg_req_id;
  else
    return stage_id;
  end if;

EXCEPTION
   WHEN OTHERS THEN
     NULL;
END get_max_stg;

FUNCTION  get_latest_run(req_set_id Number) return Number IS
  l_stmt Varchar2(300);
  Latest_run_id Number;

  cursor get_latest_run (rsid NUMBER) is
  select max(request_id) maxid
  from bis_rs_run_history WHERE PHASE_CODE='C' AND (STATUS_CODE='C'
  OR STATUS_CODE ='G') and request_set_id= rsid
  group by request_set_id,request_set_type;


BEGIN

  Latest_run_id := NULL;
  open get_latest_run(req_set_id);
  Fetch get_latest_run into Latest_run_id;
  close get_latest_run;


  return Latest_run_id;
EXCEPTION
   WHEN OTHERS THEN
     NULL;
END get_latest_run;

FUNCTION  Check_rsid(req_set_id Number) return Number IS
  l_stmt Varchar2(300);

  ret_val Number;
  cursor check_rsid (rsid NUMBER) is
    select 1 from dual where exists
    (select r.request_set_id from bis_rs_run_history r, bis_rs_prog_run_history p,
    bis_obj_refresh_history o
    where
    r.phase_code ='C' AND (r.STATUS_CODE='C' OR r.STATUS_CODE ='G')
    and p.set_request_id=r.Request_id
    and p.request_id = o.prog_request_id and r.request_set_id= rsid);

BEGIN

  ret_val := 0;
  open check_rsid(req_set_id);
  Fetch check_rsid into ret_val;
  close check_rsid;

 return ret_val;

END Check_rsid;

END;

/
