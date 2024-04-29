--------------------------------------------------------
--  DDL for Package Body BIV_RT_ESC_CUS_BLOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIV_RT_ESC_CUS_BLOG_PKG" AS
/* $Header: bivecbgb.pls 115.30 2004/04/06 21:19:57 ltong ship $ */

-- severity label in customer backlog report
function severity_label(p_param_str IN varchar2 /*default null*/) return varchar2 is
  l_label_m            varchar2(100);
  l_label_s            varchar2(100);
  l_check_val        number;
begin

select attribute_label_long into l_label_m
from ak_attributes_vl
where attribute_application_id = 862
and attribute_code='P_DASH_SR_VIEW_11';

l_check_val:=fnd_profile.value('BIV:INC_SEVERITY_1') ;

if l_check_val is not null then
execute immediate ' select description
               from cs_incident_severities_vl
               where incident_severity_id=:l_check_val'  into l_label_s using l_check_val;
    l_label_m:=l_label_m||' '||l_label_s;
end if;

return l_label_m;
end severity_label;


function inc_status_1_label(p_param_str IN varchar2 /*default null*/)  return varchar2 is
  l_label_m            varchar2(100);
  l_label_m1            varchar2(100);
  l_label_m2            varchar2(100);
  l_label_m3            varchar2(100);
  l_label_s            varchar2(100);
  l_check_val          number;
begin
select attribute_label_long into l_label_m1
from ak_attributes_vl
where attribute_application_id = 862
and attribute_code='P_SR_SEV_RPT_5';

select attribute_label_long into l_label_m2
from ak_attributes_vl
where attribute_application_id = 862
and attribute_code='P_SR_SEV_RPT_7';


select attribute_label_long into l_label_m3
from ak_attributes_vl
where attribute_application_id = 862
and attribute_code='P_DASH_SR_VIEW_9';

l_label_m:=l_label_m1||' '||l_label_m3||' '||l_label_m2;


l_check_val:= fnd_profile.value('BIV:INC_STATUS_1');


if l_check_val is not null then
execute immediate ' select name
    from cs_incident_statuses_vl
    where incident_status_id=:l_check_val' into l_label_s using l_check_val;
l_label_m:=l_label_m1||' '||l_label_m2||' '||l_label_s||' '||l_label_m3;
   -- l_label_m:=l_label_s||' '||l_label_m;
end if;

return l_label_m;
end inc_status_1_label;



function inc_status_2_label(p_param_str IN varchar2 /*default null*/)  return varchar2 is
  l_label_m            varchar2(100);
  l_label_m1           varchar2(100);
  l_label_m2           varchar2(100);
  l_label_m3           varchar2(100);
  l_label_s            varchar2(100);
  l_check_val          number;
begin
select attribute_label_long into l_label_m1
from ak_attributes_vl
where attribute_application_id = 862
and attribute_code='P_SR_SEV_RPT_5';

select attribute_label_long into l_label_m2
from ak_attributes_vl
where attribute_application_id = 862
and attribute_code='P_SR_SEV_RPT_7';


select attribute_label_long into l_label_m3
from ak_attributes_vl
where attribute_application_id = 862
and attribute_code='P_DASH_SR_VIEW_9';

l_label_m:=l_label_m1||' '||l_label_m3||' '||l_label_m2;


l_check_val:= fnd_profile.value('BIV:INC_STATUS_2');


if l_check_val is not null then
    execute immediate ' select name
    from cs_incident_statuses_vl
    where incident_status_id=:l_check_val' into l_label_s using l_check_val;
l_label_m:=l_label_m1||' '||l_label_m2||' '||l_label_s||' '||l_label_m3;
   -- l_label_m:=l_label_s||' '||l_label_m;
end if;

return l_label_m;
end inc_status_2_label;

function inc_status_3_label(p_param_str IN varchar2 /*default null*/)  return varchar2 is
  l_label_m            varchar2(100);
  l_label_m1           varchar2(100);
  l_label_m2           varchar2(100);
  l_label_m3           varchar2(100);
  l_label_s            varchar2(100);
  l_check_val          number;
begin
select attribute_label_long into l_label_m1
from ak_attributes_vl
where attribute_application_id = 862
and attribute_code='P_SR_SEV_RPT_5';

select attribute_label_long into l_label_m2
from ak_attributes_vl
where attribute_application_id = 862
and attribute_code='P_SR_SEV_RPT_7';


select attribute_label_long into l_label_m3
from ak_attributes_vl
where attribute_application_id = 862
and attribute_code='P_DASH_SR_VIEW_9';

l_label_m:=l_label_m1||' '||l_label_m3||' '||l_label_m2;


l_check_val:= fnd_profile.value('BIV:INC_STATUS_3');


if l_check_val is not null then
    execute immediate ' select name
    from cs_incident_statuses_vl
    where incident_status_id=:l_check_val' into l_label_s using l_check_val;
l_label_m:=l_label_m1||' '||l_label_m2||' '||l_label_s||' '||l_label_m3;
   -- l_label_m:=l_label_s||' '||l_label_m;
end if;

return l_label_m;
end inc_status_3_label;


function base_column_label(p_param_str IN varchar2 /*default null*/) return varchar2 is
  l_label      varchar2(100);

begin


select meaning into l_label  from fnd_lookups where lookup_type='BIV_VIEW_BY'
and  lookup_code=biv_core_pkg.g_view_by;

return l_label;
end base_column_label;


procedure  customer_backlog ( p_param_str  in varchar2 )  is

x_where_clause1   varchar2(2000);
x_where_clause2   varchar2(2000);
x_where_clause    varchar2(2000);
x_from_list       varchar2(1000);
x_from_list1       varchar2(1000);
x_from_list2       varchar2(1000);
x_sql_sttmnt      long;
x_order           number;
x_cur             pls_integer;
x_dummy           pls_integer;
x_order_by        number;
x_display         number;
x_severity_id     number;
l_new_param_str   varchar2(200);
l_new_param_str1  varchar2(200);
q3_str            varchar2(2000);
q4_str            varchar2(2000);
q5_str            varchar2(2000);
q6_str            varchar2(2000);
x_session         number;
x_sev_count       number;
l_ttl_recs        number;
l_ttl_meaning     fnd_lookups.meaning % type;
l_debug         varchar2(30) := fnd_profile.value('BIV:DEBUG');

begin
x_session:=biv_core_pkg.get_session_id;

biv_core_pkg.clean_dcf_table('BIV_TMP_RT1');

q3_str:=' ';
q4_str:=' ';
q5_str:=' ';
q6_str:=' ';
x_severity_id:=fnd_profile.value('BIV:INC_SEVERITY_1');

biv_core_pkg.get_report_parameters(p_param_str);
biv_core_pkg.g_report_type:='RT';
if (l_debug = 'Y') then
   biv_core_pkg.biv_debug('Param :'||p_param_str,'BIV_CUSTOMER_BACKLOG');
   commit;
end if;

x_sev_count:=biv_core_pkg.g_sev_cnt;
--Change for Bug 3386946
x_from_list:='from cs_incidents_b_sec sr,cs_incident_statuses_b stat ';

-- Buliding from list and where clause for severity query
biv_core_pkg.g_sev_cnt:=0;
biv_core_pkg.get_where_clause(x_from_list,x_where_clause);
x_where_clause1:= x_where_clause||'  and sr.incident_status_id=stat.incident_status_id
                                     and sr.incident_severity_id=:x_severity_id ' ;
x_from_list1:=x_from_list;
if (l_debug = 'Y') then
   biv_core_pkg.biv_debug('Severity Query Where Clause :'||x_where_clause1,
                          'BIV_CUSTOMER_BACKLOG');
   biv_core_pkg.biv_debug('Severity Query From List    :'||x_from_list1,
                          'BIV_CUSTOMER_BACKLOG');
   commit;
end if;
-- Restting severity parameter and building where clause and from list
biv_core_pkg.g_sev_cnt:=x_sev_count;
-- Change for Bug 3386946
x_from_list:='from cs_incidents_b_sec sr,cs_incident_statuses_b stat ';
biv_core_pkg.get_where_clause(x_from_list,x_where_clause);
x_where_clause:= x_where_clause||'  and sr.incident_status_id=stat.incident_status_id ';
if (l_debug = 'Y') then
   biv_core_pkg.biv_debug('Others Where Clause :'||x_where_clause,
                          'BIV_CUSTOMER_BACKLOG');
   biv_core_pkg.biv_debug('Others From List    :'||x_from_list,
                          'BIV_CUSTOMER_BACKLOG');
   commit;
end if;

-- Building from list and where clause in Escalated Request case
if (instr(upper(x_from_list),'JTF_TASKS_B') = 0) then
            x_from_list2 := x_from_list || ',
                               jtf_tasks_b task,
                               jtf_task_references_b ref';
else
           x_from_list2 := x_from_list;
end if;
x_where_clause2:= x_where_clause || ' and sr.incident_id    = ref.object_id
                 and ref.object_type_code = ''SR''
                 and ref.reference_code   = ''ESC''
                 and ref.task_id          = task.task_id
                 and task.task_type_id=22 and escalation_level is not null ' ;

if (l_debug = 'Y') then
   biv_core_pkg.biv_debug('Escalated Sr Where Clause :'||x_where_clause2,
                          'BIV_CUSTOMER_BACKLOG');
   biv_core_pkg.biv_debug('Escalated SR  From List    :'||x_from_list2,
                          'BIV_CUSTOMER_BACKLOG');
   commit;
end if;
-- Setting order by
if biv_core_pkg.g_srt_by is null then
x_order_by:=4;
else
x_order_by:=to_number(nvl(biv_core_pkg.g_srt_by,0))+2;
end if;

x_display:=to_number(nvl(biv_core_pkg.g_disp,0))+1;

--  q2_str  : unowned_sr  q3_str :escalated_sr , q4_str  : total_backlog , q5_str  : severity_backlog,

-- Building Sql to populate the BIV_TMP_RT1  table
if (x_order_by=4)then
            x_sql_sttmnt:='select ''X'',:x_session, sr.customer_id,count(1)'
                      ||x_from_list||x_where_clause||'
                      and (nvl(sr.resource_type,''X'') <>''RS_EMPLOYEE''  or sr.incident_owner_id is null )
                      and nvl(stat.close_flag,''N'') <> ''Y''
                      group by sr.customer_id';

 elsif  (x_order_by=5) then
            x_sql_sttmnt:=' select ''X'',:x_session,sr.customer_id,count(1)'
                    ||x_from_list2||x_where_clause2||'
                     and nvl(stat.close_flag,''N'') <> ''Y''
                     group by sr.customer_id ';

elsif (x_order_by=6) then
           x_sql_sttmnt:='select ''X'',:x_session,sr.customer_id,count(1)'
                         ||x_from_list||x_where_clause||'
                          and nvl(stat.close_flag,''N'')  <> ''Y''
                          group by sr.customer_id';

elsif (x_order_by=7 ) then
biv_core_pkg.g_sev_cnt:=0;
           x_sql_sttmnt:=' select ''X'',:x_session,sr.customer_id,count(1)'
                          ||x_from_list1||x_where_clause1||'
                          and nvl( stat.close_flag,''N'') <>''Y''
                          group by sr.customer_id ';

end if;

x_sql_sttmnt:='insert into biv_tmp_rt1 rep(report_code,session_id, ID,col2)(select * from ( '
               ||x_sql_sttmnt||' order by 4 desc ) where rownum < :x_display )';



if (l_debug = 'Y') then
   biv_core_pkg.biv_debug('FIRST SQL STATEMENT ORDER BY'||
              TO_CHAR(X_ORDER_BY)||':'||x_sql_sttmnt,'BIV_CUSTOMER_BACKLOG');
   commit;
end if;

x_cur:=dbms_sql.open_cursor;
dbms_sql.parse(x_cur,x_sql_sttmnt,dbms_sql.native);
biv_core_pkg.bind_all_variables(x_cur);
if x_order_by=7 then
dbms_sql.bind_variable(x_cur,':x_severity_id',x_severity_id);
end if;
dbms_sql.bind_variable(x_cur,':x_display',x_display);
dbms_sql.bind_variable(x_cur,':x_session',x_session);
x_dummy:=dbms_sql.execute(x_cur);
dbms_sql.close_cursor(x_cur);
-- setting the customer id parameter to null in the parameter list


biv_core_pkg.g_cust_id_cnt:=0;
biv_core_pkg.g_sev_cnt:=x_sev_count;
biv_core_pkg.g_sev_cnt:=0;
-- Change for Bug 3386946
x_from_list:='from cs_incidents_b_sec sr,cs_incident_statuses_b stat  ';
biv_core_pkg.get_where_clause(x_from_list,x_where_clause);
x_from_list1:=x_from_list;
x_where_clause1:= x_where_clause ||'  and sr.incident_status_id=stat.incident_status_id
                                     and sr.incident_severity_id=:x_severity_id  ' ;


biv_core_pkg.g_sev_cnt:=x_sev_count;
if (l_debug = 'Y') then
   biv_core_pkg.biv_debug('SEVERITY Count  :'||to_char(x_sev_count),
                          'BIV_CUSTOMER_BACKLOG');
end if;
-- Change for Bug 3386946
x_from_list:='from cs_incidents_b_sec sr,cs_incident_statuses_b stat ';
biv_core_pkg.get_where_clause(x_from_list,x_where_clause);
x_where_clause:= x_where_clause ||'  and sr.incident_status_id=stat.incident_status_id ' ;

x_from_list :=x_from_list||', biv_tmp_rt1  rep  ' ;
x_from_list1 :=x_from_list1||', biv_tmp_rt1  rep  ' ;

if (l_debug = 'Y') then
   biv_core_pkg.biv_debug('Rebuild Severity Query Where Clause :'||
                          x_where_clause1,'BIV_CUSTOMER_BACKLOG');
   biv_core_pkg.biv_debug('Rebuild Severity Query From List    :'||x_from_list1,
                          'BIV_CUSTOMER_BACKLOG');
   biv_core_pkg.biv_debug('Rebuild OTher  Where Clause :'||x_where_clause,
                          'BIV_CUSTOMER_BACKLOG');
   biv_core_pkg.biv_debug('Rebuild Other From List    :'||x_from_list,
                          'BIV_CUSTOMER_BACKLOG');
commit;
end if;

if (instr(upper(x_from_list),'JTF_TASKS_B') = 0) then
            x_from_list2 := x_from_list || ',
                               jtf_tasks_b task,
                               jtf_task_references_b ref';
else
           x_from_list2 := x_from_list;
end if;

x_where_clause2:= x_where_clause || ' and sr.incident_id    = ref.object_id
                                     and ref.object_type_code = ''SR''
                                     and ref.reference_code   = ''ESC''
                                     and ref.task_id          = task.task_id
                                     and task.task_type_id=22 and escalation_level is not null ' ;

if (l_debug = 'Y') then
   biv_core_pkg.biv_debug('Rebuild ESR Query Where Clause :'||x_where_clause2,
                          'BIV_CUSTOMER_BACKLOG');
   biv_core_pkg.biv_debug('Rebuild ESR Query From List    :'||x_from_list2,
                          'BIV_CUSTOMER_BACKLOG');
   commit;
end if;

q3_str:='select sr.customer_id a,count(1) b,0 c,0 d,0 e '
           ||x_from_list||x_where_clause||'
           and (nvl(sr.resource_type,''X'') <>''RS_EMPLOYEE'' or  sr.incident_owner_id is null)
           and nvl(stat.close_flag,''N'') <> ''Y''
           and sr.customer_id=rep.ID
           and rep.session_id=:x_session group by sr.customer_id';
q4_str:='  select sr.customer_id a,0 b,count(1)c,0 d,0 e '
           ||x_from_list2||x_where_clause2||'
           and sr.customer_id=rep.ID
           and nvl(stat.close_flag,''N'') <> ''Y''
           and rep.session_id=:x_session  group by sr.customer_id ' ;
q5_str:=' select sr.customer_id a, 0 b,0 c,count(1) d, 0 e '
            ||x_from_list||x_where_clause||'
            and nvl(stat.close_flag,''N'')  <> ''Y''
            and sr.customer_id=rep.ID
            and rep.session_id=:x_session  group by sr.customer_id' ;
q6_str:='select sr.customer_id a,0 b, 0 c, 0 d,count(1) e '
            ||x_from_list1||x_where_clause1||'
             and nvl( stat.close_flag,''N'') <>''Y''
             and sr.customer_id=rep.ID
             and rep.session_id=:x_session  group by sr.customer_id ';

if (x_order_by=4)then
    q3_str:='select ID a,to_number(col2) b ,0 c,0 d,0 e from biv_tmp_rt1 where report_code=''X''
             and session_id=:x_session';
elsif  (x_order_by=5) then
    q4_str:='select ID a,0 b ,to_number(col2) c,0 d,0 e from biv_tmp_rt1 where report_code=''X''
              and session_id=:x_session ';
elsif (x_order_by=6) then
    q5_str:='select ID a,0 b ,0 c,to_number(col2) d,0 e from biv_tmp_rt1 where report_code=''X''
              and session_id=:x_session ';
elsif (x_order_by=7 ) then
    q6_str:='select ID a,0 b ,0 c,0 d,to_number(col2) e from biv_tmp_rt1 where report_code=''X''
             and session_id=:x_session ';
end if;


x_sql_sttmnt:='insert into biv_tmp_rt1  ( report_code,rowno,session_id,ID,col4,col6,col8,col10)
               (select ''BIV_CUSTOMER_BACKLOG'',rownum,ses,ID,col4,col6,col8,col10 from (
               (select ''BIV_CUSTOMER_BACKLOG'',:x_session  ses,  a ID , sum(b) col4, sum(c) col6, sum(d) col8, sum(e) col10 from ('
                 ||q3_str||' union all '||q4_str||' union all '||q5_str||' union all '||q6_str||
                ') group by a ) order by '||x_order_by||' desc ))';


if (l_debug = 'Y') then
   biv_core_pkg.biv_debug(x_sql_sttmnt,'BIV_CUSTOMER_BACKLOG');
   commit;
end if;

x_cur:=dbms_sql.open_cursor;
dbms_sql.parse(x_cur,x_sql_sttmnt,dbms_sql.native);
biv_core_pkg.bind_all_variables(x_cur);
if x_order_by <> 7 then
dbms_sql.bind_variable(x_cur,':x_severity_id',x_severity_id);
end if;
--dbms_sql.bind_variable(x_cur,':x_display',x_display);
dbms_sql.bind_variable(x_cur,':x_session',x_session);
x_dummy:=dbms_sql.execute(x_cur);
dbms_sql.close_cursor(x_cur);
-- x_cur:=dbms_sql.open_cursor;

execute immediate 'delete from biv_tmp_rt1 where report_code=''X'' and session_id=:x_session'
            using x_session;

biv_core_pkg.update_description('P_CUST_ID','ID','col2','BIV_TMP_RT1');

biv_core_pkg.reset_view_by_param;
l_new_param_str := 'BIV_SERVICE_REQUEST' ||biv_core_pkg.g_param_sep ||
                       biv_core_pkg.reconstruct_param_str;
l_new_param_str := l_new_param_str ||'P_CUST_ID' ||
                      biv_core_pkg.g_value_sep ;
                     -- biv_core_pkg.g_value_sep || 'BIV_SERVICE_REQUEST' ||biv_core_pkg.g_param_sep ||

l_new_param_str1 := 'BIV_RT_CUS_BLOG_DD' ||biv_core_pkg.g_param_sep ||
                       biv_core_pkg.reconstruct_param_str;
l_new_param_str1 := l_new_param_str1 ||'P_CUST_ID' ||biv_core_pkg.g_value_sep ;
                   -- biv_core_pkg.g_value_sep || 'BIV_RT_CUS_BLOG_DD' ||

update biv_tmp_rt1 rep
set col1=l_new_param_str1||nvl(to_char(rep.ID),biv_core_pkg.g_null)||
           biv_core_pkg.g_param_sep,
    col3=l_new_param_str||nvl(to_char(rep.ID),biv_core_pkg.g_null)||
           biv_core_pkg.g_param_sep ||'P_UNOWN'|| biv_core_pkg.g_value_sep ||
           'Y'||biv_core_pkg.g_param_sep||'P_BLOG'||
           biv_core_pkg.g_value_sep || 'Y'||biv_core_pkg.g_param_sep,
    col5=l_new_param_str||nvl(to_char(rep.ID),biv_core_pkg.g_null)||
           biv_core_pkg.g_param_sep ||'P_ESC_SR'|| biv_core_pkg.g_value_sep ||
           'Y'||biv_core_pkg.g_param_sep||'P_BLOG'||
           biv_core_pkg.g_value_sep || 'Y'||biv_core_pkg.g_param_sep,
    col7=l_new_param_str||nvl(to_char(rep.ID),biv_core_pkg.g_null)||
           biv_core_pkg.g_param_sep ||'P_BLOG'|| biv_core_pkg.g_value_sep ||
           'Y'||biv_core_pkg.g_param_sep,
    col9=l_new_param_str||nvl(to_char(rep.ID),biv_core_pkg.g_null)||
           biv_core_pkg.g_param_sep ||'P_SEV'|| biv_core_pkg.g_value_sep ||
           to_char(x_severity_id)||biv_core_pkg.g_param_sep||'P_BLOG'||
           biv_core_pkg.g_value_sep || 'Y'||biv_core_pkg.g_param_sep,
    creation_date = sysdate,
    col20 = 'INDV_ROW';
select count(1) into l_ttl_recs
  from biv_tmp_rt1
 where session_id = x_session
   and report_code = 'BIV_CUSTOMER_BACKLOG';
if (nvl(l_ttl_recs,0) between 2 and biv_core_pkg.g_disp-1) then
   if (l_debug = 'Y') then
      biv_core_pkg.biv_debug('Inserting totol row','BIV_CUSTOMER_BACKLOG');
   end if;
   insert into biv_tmp_rt1(report_code,session_id, rowno,col4,col6,col8,
             col10,col20)
      select 'BIV_CUSTOMER_BACKLOG',x_session,max(rowno)+1,
             sum(col4), sum(col6),
             sum(col8), sum(col10),'TTL_ROW'
        from biv_tmp_rt1
       where session_id = x_session
         and report_code = 'BIV_CUSTOMER_BACKLOG'
         and col20 = 'INDV_ROW';
   l_new_param_str := 'BIV_SERVICE_REQUEST' ||biv_core_pkg.g_param_sep ||
                          biv_core_pkg.reconstruct_param_str;

   l_new_param_str1 := 'BIV_RT_CUS_BLOG_DD' ||biv_core_pkg.g_param_sep ||
                          biv_core_pkg.reconstruct_param_str;
   if (l_debug = 'Y') then
      biv_core_pkg.biv_debug('Updating hyper links in total row',
                             'BIV_CUSTOMER_BACKLOG');
   end if;
   l_ttl_meaning := biv_core_pkg.get_lookup_meaning('TOTAL');
   update biv_tmp_rt1 rep
   set col1=l_new_param_str1 ,
       col2=l_ttl_meaning,
       col3=l_new_param_str||
              'P_UNOWN'|| biv_core_pkg.g_value_sep ||
              'Y'||biv_core_pkg.g_param_sep||'P_BLOG'||
              biv_core_pkg.g_value_sep || 'Y'||biv_core_pkg.g_param_sep,
       col5=l_new_param_str||
              'P_ESC_SR'|| biv_core_pkg.g_value_sep ||
              'Y'||biv_core_pkg.g_param_sep||'P_BLOG'||
              biv_core_pkg.g_value_sep || 'Y'||biv_core_pkg.g_param_sep,
       col7=l_new_param_str||
              'P_BLOG'|| biv_core_pkg.g_value_sep ||
              'Y'||biv_core_pkg.g_param_sep,
       col9=l_new_param_str||
              'P_SEV'|| biv_core_pkg.g_value_sep ||
              to_char(x_severity_id)||biv_core_pkg.g_param_sep||'P_BLOG'||
              biv_core_pkg.g_value_sep || 'Y'||biv_core_pkg.g_param_sep,
       creation_date = sysdate
      where col20 = 'TTL_ROW';
end if;

exception
  when others then
    if (l_debug = 'Y') then
       biv_core_pkg.biv_debug('Error:'||substr(sqlerrm,1,200),
                              'BIV_CUSTOMER_BACKLOG');
    end if;

end; -- procedure customer_backlog


procedure  escalated_sr_backlog ( p_param_str  in varchar2 )  is
x_where_clause1  varchar2(2000);
x_where_clause2  varchar2(2000);
x_where_clause   varchar2(2000);
x_from_list      varchar2(1000);
x_from_list1     varchar2(1000);
x_from_list2     varchar2(1000);
x_sql_sttmnt     long;
x_cur            pls_integer;
x_dummy          pls_integer;
x_order_by       number;
x_display        number;
x_severity_id    number;
x_stat_1         number;
x_stat_2         number;
x_stat_3         number;
dd_param_str     varchar2(2000);
l_new_param_str  varchar2(200);
x_session         number;
q3_str            varchar2(2000);
q4_str            varchar2(4000);
x_sev_count       number;
l_ttl_recs        number;
l_ttl_meaning     fnd_lookups.meaning % type;
l_debug         varchar2(30) := fnd_profile.value('BIV:DEBUG');

begin
x_session:=biv_core_pkg.get_session_id;
biv_core_pkg.clean_dcf_table('BIV_TMP_RT1');


x_severity_id:=fnd_profile.value('BIV:INC_SEVERITY_1');
x_stat_1:=fnd_profile.value('BIV:INC_STATUS_1');
x_stat_2:=fnd_profile.value('BIV:INC_STATUS_2');
x_stat_3:=fnd_profile.value('BIV:INC_STATUS_3');

biv_core_pkg.g_report_id:='BIV_RT_ESC_SR';
biv_core_pkg.get_report_parameters(p_param_str);
biv_core_pkg.g_report_type:='RT';

if biv_core_pkg.g_view_by is null then
biv_core_pkg.g_base_column:='sr.inventory_item_id ';
end if;

x_sev_count:=biv_core_pkg.g_sev_cnt;

-- Building the from list and where clause for severity query
-- Change for Bug 3386946
x_from_list:='from cs_incidents_b_sec sr,cs_incident_statuses_b stat ';
biv_core_pkg.g_sev_cnt:=0;
biv_core_pkg.get_where_clause(x_from_list,x_where_clause);
x_from_list1:=x_from_list;
x_where_clause1:= x_where_clause || '   and sr.incident_status_id = stat.incident_status_id
                                  and nvl(stat.close_flag,''N'') <> ''Y'' ';
-- resseting the severity parameter and building the where clause for escalated queries...
biv_core_pkg.g_sev_cnt:=x_sev_count ;
-- Change for bug 3386946
x_from_list:='from cs_incidents_b_sec sr,cs_incident_statuses_b stat ';
biv_core_pkg.get_where_clause(x_from_list,x_where_clause);
x_where_clause:= x_where_clause || '   and sr.incident_status_id = stat.incident_status_id
                                  and nvl(stat.close_flag,''N'') <> ''Y'' ';


-- Building the from list and where clause in Escalated Request case
if (instr(upper(x_from_list),'JTF_TASKS_B') = 0) then
            x_from_list2 := x_from_list || ',
                               jtf_tasks_b task,
                               jtf_task_references_b ref';
else
           x_from_list2 := x_from_list;
end if;
-- x_from_list2:=x_from_list;
x_where_clause2:= x_where_clause || ' and sr.incident_id    = ref.object_id
                                     and ref.object_type_code = ''SR''
                                     and ref.reference_code   = ''ESC''
                                     and ref.task_id          = task.task_id
                                     and task.task_type_id=22 and escalation_level is not null ';

if biv_core_pkg.g_srt_by is null then
x_order_by:=4;
else
x_order_by:=to_number(nvl(biv_core_pkg.g_srt_by,0))+2;
end if;
x_display:=to_number(nvl(biv_core_pkg.g_disp,0))+1;


if (x_order_by=4)then  /* Sort by Severity */
       x_sql_sttmnt:='select  ''X'',:x_session ,'|| biv_core_pkg.g_base_column||'  , count(1) '
                ||x_from_list1||x_where_clause1||'
                and sr.incident_severity_id=:x_severity_id
                group by '|| biv_core_pkg.g_base_column ;
 elsif  (x_order_by=5) then  /* Sort by Escalation */
      x_sql_sttmnt:=' select  ''X'' ,:x_session ,'|| biv_core_pkg.g_base_column||' , count(1) '
                        ||x_from_list2||x_where_clause2||'
                        group by '|| biv_core_pkg.g_base_column ;

 end if;



x_sql_sttmnt:='insert into biv_tmp_rt1 rep(report_code,session_id, ID,col2)(select * from ( '
               ||x_sql_sttmnt||' order by 4 desc ) where rownum < :x_display )';

if (l_debug = 'Y') then
   biv_core_pkg.biv_debug(x_sql_sttmnt,'BIV_ESCALATED_SR');
   commit;
end if;

x_cur:=dbms_sql.open_cursor;
dbms_sql.parse(x_cur,x_sql_sttmnt,dbms_sql.native);
biv_core_pkg.bind_all_variables(x_cur);
if x_order_by=4 then
dbms_sql.bind_variable(x_cur,':x_severity_id',x_severity_id);
end if;
dbms_sql.bind_variable(x_cur,':x_display',x_display);
dbms_sql.bind_variable(x_cur,':x_session',x_session);
x_dummy:=dbms_sql.execute(x_cur);
dbms_sql.close_cursor(x_cur);


-- Fix for bug 3461261
-- x_from_list1:=x_from_list1||',biv_tmp_rt1 rep ' ;

if (x_order_by=5) then  /* Sort by Escalation */
   x_from_list2:=x_from_list2||', biv_tmp_rt1 rep ' ;
end if;


-- Fix for bug 3461261
-- x_where_clause1:=x_where_clause1|| ' and  nvl('||biv_core_pkg.g_base_column||',-99)=nvl(rep.ID,-99) and rep.session_id=:x_session and rep.report_code=''X'' ' ;

if (x_order_by=5) then  /* Sort by Escalation */
   x_where_clause2:=x_where_clause2|| ' and  nvl('||biv_core_pkg.g_base_column||',-99)=nvl(rep.ID,-99) and rep.session_id=:x_session and rep.report_code=''X'' ';
end if;


if x_order_by=4 then  /* Sort by Severity, overwrites previous values sort by Escalation */
q3_str:='(select ''BIV_ESCALATED_SR'',:x_session, ID a ,to_number(col2) b, 0 c ,0 d,0 e,0 f,0 g
          from biv_tmp_rt1 where report_code=''X'' and session_id=:x_session )';
else
 /* Used when sort by Escalation (first part of union all) */
 q3_str:= '(select  ''BIV_ESCALATED_SR'',:x_session ,'|| biv_core_pkg.g_base_column||'  a,
            count(1) b, 0 c ,0 d,0 e,0 f,0 g '
            ||x_from_list1||x_where_clause1|| ' and sr.incident_severity_id=:x_severity_id
            group by '|| biv_core_pkg.g_base_column||')';
end if;


/* Always used as the second union all part */
q4_str:= '(select  ''BIV_ESCALATED_SR'',:x_session ,'|| biv_core_pkg.g_base_column||'  a, 0  b ,
               count(1) c ,
               sum(decode(sr.incident_status_id,:x_stat_1,1,0)) d ,
               sum(decode(sr.incident_status_id,:x_stat_2,1,0)) e ,
               sum(decode(sr.incident_status_id,:x_stat_3,1,0)) f,
               (count(1)-(sum(decode(sr.incident_status_id,:x_stat_1,1,0))+sum(decode(sr.incident_status_id,:x_stat_2,1,0))+
                sum(decode(sr.incident_status_id,:x_stat_3,1,0)))) g '
               ||x_from_list2||x_where_clause2||
               ' group by '|| biv_core_pkg.g_base_column||')';


x_sql_sttmnt:= '(select ''BIV_ESCALATED_SR'',rownum ,ses,ID,col4,col6,col8,col10,col12,col14
               from (select ''BIV_ESCALATED_SR'',:x_session ses,a ID,sum(b) col4,sum(c) col6,sum(d) col8,
                 sum(e) col10,sum(f) col12,sum(g) col14 from  ('||q3_str ||'
                union all '||q4_str||'
               )  group by a
               order by '||x_order_by ||'   desc ) where rownum < :x_display)' ;

x_sql_sttmnt:='insert into biv_tmp_rt1 rep (report_code,rowno,session_id,ID,col4,col6,col8,col10,col12,col14)
              '||x_sql_sttmnt||' '  ;

if (l_debug = 'Y') then
   biv_core_pkg.biv_debug(x_sql_sttmnt,'BIV_ESCALATED_SR');
   commit;
end if;

x_cur:=dbms_sql.open_cursor;
dbms_sql.parse(x_cur,x_sql_sttmnt,dbms_sql.native);
biv_core_pkg.bind_all_variables(x_cur);
if x_order_by <> 4 then
dbms_sql.bind_variable(x_cur,':x_severity_id',x_severity_id);
end if;
dbms_sql.bind_variable(x_cur,':x_stat_1',x_stat_1);
dbms_sql.bind_variable(x_cur,':x_stat_2',x_stat_2);
dbms_sql.bind_variable(x_cur,':x_stat_3',x_stat_3);
dbms_sql.bind_variable(x_cur,':x_display',x_display);
dbms_sql.bind_variable(x_cur,':x_session',x_session);
x_dummy:=dbms_sql.execute(x_cur);
dbms_sql.close_cursor(x_cur);

execute immediate 'delete from biv_tmp_rt1 where report_code=''X'' and session_id=:x_session'
            using x_session;


biv_core_pkg.update_base_col_desc('BIV_TMP_RT1');


dd_param_str:=biv_core_pkg.param_for_base_col;
--dd_param_str:='P_PRD_ID';
biv_core_pkg.reset_view_by_param;
l_new_param_str := 'BIV_SERVICE_REQUEST' ||biv_core_pkg.g_param_sep ||
                       biv_core_pkg.reconstruct_param_str;
l_new_param_str := l_new_param_str ||dd_param_str ||biv_core_pkg.g_value_sep ;
-- 'jtfBinId' || biv_core_pkg.g_value_sep || 'BIV_SERVICE_REQUEST' ||biv_core_pkg.g_param_sep ||

update biv_tmp_rt1 rep
   set col3=l_new_param_str||
            nvl(to_char(rep.ID),biv_core_pkg.g_null)||
            biv_core_pkg.g_param_sep ||'P_SEV'||
            biv_core_pkg.g_value_sep ||to_char(x_severity_id)||
            biv_core_pkg.g_param_sep||'P_BLOG'||
            biv_core_pkg.g_value_sep || 'Y'||biv_core_pkg.g_param_sep,
       col5=l_new_param_str||nvl(to_char(rep.ID),biv_core_pkg.g_null)||
            biv_core_pkg.g_param_sep ||'P_ESC_SR'||
            biv_core_pkg.g_value_sep || 'Y'||biv_core_pkg.g_param_sep||
            'P_BLOG'|| biv_core_pkg.g_value_sep || 'Y'||
            biv_core_pkg.g_param_sep,
       col7=l_new_param_str||nvl(to_char(rep.ID),biv_core_pkg.g_null)||
            biv_core_pkg.g_param_sep ||'P_ESC_SR'||
            biv_core_pkg.g_value_sep || 'Y'||biv_core_pkg.g_param_sep||
            'P_STS_ID'||biv_core_pkg.g_value_sep ||to_char(x_stat_1) ||
            biv_core_pkg.g_param_sep ||
            'P_BLOG'|| biv_core_pkg.g_value_sep || 'Y'||
            biv_core_pkg.g_param_sep,
       col9=l_new_param_str||nvl(to_char(rep.ID),biv_core_pkg.g_null)||
            biv_core_pkg.g_param_sep ||'P_ESC_SR'||
            biv_core_pkg.g_value_sep || 'Y'||biv_core_pkg.g_param_sep||
            'P_STS_ID'||biv_core_pkg.g_value_sep ||to_char(x_stat_2) ||
            biv_core_pkg.g_param_sep ||
            'P_BLOG'|| biv_core_pkg.g_value_sep || 'Y'||
            biv_core_pkg.g_param_sep,
      col11=l_new_param_str||nvl(to_char(rep.ID),biv_core_pkg.g_null)||
            biv_core_pkg.g_param_sep ||'P_ESC_SR'||
            biv_core_pkg.g_value_sep || 'Y'||biv_core_pkg.g_param_sep||
            'P_STS_ID'||biv_core_pkg.g_value_sep ||to_char(x_stat_3) ||
            biv_core_pkg.g_param_sep ||
            'P_BLOG'|| biv_core_pkg.g_value_sep || 'Y'||
            biv_core_pkg.g_param_sep,
      col13=l_new_param_str||nvl(to_char(rep.ID),biv_core_pkg.g_null)||
            biv_core_pkg.g_param_sep ||'P_ESC_SR'||
            biv_core_pkg.g_value_sep || 'Y'||biv_core_pkg.g_param_sep||
            'P_OTHER_BLOG'||biv_core_pkg.g_value_sep ||'Y' ||
            biv_core_pkg.g_param_sep ||
            'P_BLOG'|| biv_core_pkg.g_value_sep || 'Y'||
            biv_core_pkg.g_param_sep,
      col20='INDV_ROW';
--
-- Generate total row
--
commit;
select count(1) into l_ttl_recs
  from biv_tmp_rt1
 where session_id = x_session
   and report_code = 'BIV_ESCALATED_SR';
l_ttl_meaning := biv_core_pkg.get_lookup_meaning('TOTAL');
if (nvl(l_ttl_recs,0) between 2 and biv_core_pkg.g_disp-1) then
   insert into biv_tmp_rt1(report_code,rowno,col2,col4,col6,col8,col10,
                           col12, col14, session_id,col20)
    select report_code, max(rowno)+1, l_ttl_meaning, sum(col4), sum(col6),
           sum(col8), sum(col10), sum(col12), sum(col14), session_id,'TTL_ROW'
     from biv_tmp_rt1
    where report_code = 'BIV_ESCALATED_SR'
      and session_id = x_session
      and col20 = 'INDV_ROW'
     group by report_code, session_id;
l_new_param_str := 'BIV_SERVICE_REQUEST' ||biv_core_pkg.g_param_sep ||
                       biv_core_pkg.reconstruct_param_str;
update biv_tmp_rt1 rep
   set col3=l_new_param_str||'P_SEV'|| biv_core_pkg.g_value_sep ||
            to_char(x_severity_id)||biv_core_pkg.g_param_sep||'P_BLOG'||
            biv_core_pkg.g_value_sep || 'Y'||biv_core_pkg.g_param_sep,
       col5=l_new_param_str||'P_ESC_SR'|| biv_core_pkg.g_value_sep || 'Y'||
            biv_core_pkg.g_param_sep||'P_BLOG'|| biv_core_pkg.g_value_sep ||
            'Y'||biv_core_pkg.g_param_sep,
       col7=l_new_param_str||'P_ESC_SR'|| biv_core_pkg.g_value_sep || 'Y'||
            biv_core_pkg.g_param_sep||'P_BLOG'|| biv_core_pkg.g_value_sep ||
            'Y'||biv_core_pkg.g_param_sep ||
            'P_STS_ID'||biv_core_pkg.g_value_sep ||to_char(x_stat_1) ||
            biv_core_pkg.g_param_sep,
       col9=l_new_param_str||'P_ESC_SR'|| biv_core_pkg.g_value_sep || 'Y'||
            biv_core_pkg.g_param_sep||'P_BLOG'|| biv_core_pkg.g_value_sep ||
            'Y'||biv_core_pkg.g_param_sep ||
            'P_STS_ID'||biv_core_pkg.g_value_sep ||to_char(x_stat_2) ||
            biv_core_pkg.g_param_sep,
      col11=l_new_param_str||'P_ESC_SR'|| biv_core_pkg.g_value_sep || 'Y'||
            biv_core_pkg.g_param_sep||'P_BLOG'|| biv_core_pkg.g_value_sep ||
            'Y'||biv_core_pkg.g_param_sep ||
            'P_STS_ID'||biv_core_pkg.g_value_sep ||to_char(x_stat_3) ||
            biv_core_pkg.g_param_sep,
      col13=l_new_param_str||'P_ESC_SR'|| biv_core_pkg.g_value_sep || 'Y'||
            biv_core_pkg.g_param_sep||'P_BLOG'|| biv_core_pkg.g_value_sep ||
            'Y'||biv_core_pkg.g_param_sep ||
            'P_OTHER_BLOG'||biv_core_pkg.g_value_sep ||'Y' ||
            biv_core_pkg.g_param_sep
 where report_code = 'BIV_ESCALATED_SR'
   and session_id = x_session
   and col20 = 'TTL_ROW';
end if;

exception
  when others then
    if (l_debug='Y') then
       biv_core_pkg.biv_debug('Error:'||substr(sqlerrm,1,200),
                              biv_core_pkg.g_report_id);
    end if;


end; -- procedure escalated sr backlog

procedure  customer_backlog_dd ( p_param_str  in varchar2 )  is

x_where_clause1  varchar2(2000);
x_where_clause2  varchar2(2000);
x_where_clause   varchar2(2000);
x_from_list      varchar2(1000);
x_from_list1      varchar2(1000);
x_from_list2      varchar2(1000);
x_sql_sttmnt     varchar2(4000);
x_cur            pls_integer;
x_dummy          pls_integer;
x_severity_id    number;
l_cust_id        number;
l_new_param_str  varchar2(200);
x_session         varchar2(50);
x_sev_count       number;
l_ttl_recs        number;
l_ttl_meaning     fnd_lookups.meaning % type;
l_debug         varchar2(30) := fnd_profile.value('BIV:DEBUG');

begin
x_session:=biv_core_pkg.get_session_id;

biv_core_pkg.clean_dcf_table('BIV_TMP_RT1');

x_severity_id:=fnd_profile.value('BIV:INC_SEVERITY_1');

biv_core_pkg.get_report_parameters(p_param_str);
biv_core_pkg.g_report_type:='RT';
if (l_debug = 'Y') then
   biv_core_pkg.biv_debug('Param :'||p_param_str,'BIV_CUSTOMER_BACKLOG');
   commit;
end if;

x_sev_count:=biv_core_pkg.g_sev_cnt;
-- Change for Bug 3386946
x_from_list:='from cs_incidents_b_sec sr,cs_incident_statuses_b stat ';

-- Buliding from list and where clause for severity query
biv_core_pkg.g_sev_cnt:=0;
biv_core_pkg.get_where_clause(x_from_list,x_where_clause);
x_where_clause1:= x_where_clause||'  and sr.incident_status_id=stat.incident_status_id
                                     and sr.incident_severity_id=:x_severity_id ' ;
x_from_list1:=x_from_list;
if (l_debug = 'Y') then
   biv_core_pkg.biv_debug('Severity Query Where Clause :'||x_where_clause1,
                          'BIV_CUSTOMER_BACKLOG');
   biv_core_pkg.biv_debug('Severity Query From List    :'||x_from_list1,
                          'BIV_CUSTOMER_BACKLOG');
   commit;
end if;
-- Restting severity parameter and building where clause and from list
biv_core_pkg.g_sev_cnt:=x_sev_count;
-- Change for Bug 3386946
x_from_list:='from cs_incidents_b_sec sr,cs_incident_statuses_b stat ';
biv_core_pkg.get_where_clause(x_from_list,x_where_clause);
x_where_clause:= x_where_clause||'  and sr.incident_status_id=stat.incident_status_id ';
if (l_debug = 'Y') then
   biv_core_pkg.biv_debug('Others Where Clause :'||x_where_clause,
                          'BIV_CUSTOMER_BACKLOG');
   biv_core_pkg.biv_debug('Others From List    :'||x_from_list,
                          'BIV_CUSTOMER_BACKLOG');
   commit;
end if;

-- Building from list and where clause in Escalated Request case
if (instr(upper(x_from_list),'JTF_TASKS_B') = 0) then
            x_from_list2 := x_from_list || ',
                               jtf_tasks_b task,
                               jtf_task_references_b ref';
else
           x_from_list2 := x_from_list;
end if;
x_where_clause2:= x_where_clause || ' and sr.incident_id    = ref.object_id
                                     and ref.object_type_code = ''SR''
                                     and ref.reference_code   = ''ESC''
                                     and ref.task_id          = task.task_id
                                     and task.task_type_id=22 and escalation_level is not null ' ;

if (l_debug = 'Y') then
   biv_core_pkg.biv_debug('Escalated Sr Where Clause :'||x_where_clause2,
                          'BIV_CUSTOMER_BACKLOG');
   biv_core_pkg.biv_debug('Escalated SR  From List    :'||x_from_list2,
                          'BIV_CUSTOMER_BACKLOG');
   commit;
end if;

x_sql_sttmnt:= '(SELECT ''BIV_CUSTOMER_BACKLOG'',rownum, ses, A ,col4,col6,col8,col10 FROM
              (select ''BIV_CUSTOMER_BACKLOG'',:x_session ses, A ,sum(B) col4,sum(C)col6,sum(D)col8,sum(E) col10
                from  (
               (select ''BIV_CUSTOMER_BACKLOG''  ,sr.contract_number A ,count(1) B ,0 C,0 D,0 E '
               ||x_from_list||x_where_clause||'
               and (nvl(sr.resource_type,''X'') <>''RS_EMPLOYEE'' or  sr.incident_owner_id is null)
               and nvl(stat.close_flag,''N'') <> ''Y'' group by sr.contract_number )
               union all
               (select  ''BIV_CUSTOMER_BACKLOG''  ,sr.contract_number A , 0 B ,0 C,count(1) D, 0 E '
               ||x_from_list||x_where_clause||'
               and nvl(stat.close_flag,''N'')  <> ''Y'' group by sr.contract_number)
               union all
               (select  ''BIV_CUSTOMER_BACKLOG''  ,sr.contract_number A ,0 B ,0 C, 0 D,count(1) E '
               ||x_from_list1||x_where_clause1||'
                and nvl( stat.close_flag,''N'') <>''Y''  group by sr.contract_number)
                union all
               (select  ''BIV_CUSTOMER_BACKLOG'' ,sr.contract_number A ,0 B ,count(1) C ,0 D ,0 E '
               ||x_from_list2||x_where_clause2|| ' and nvl( stat.close_flag,''N'') <>''Y''
               group by sr.contract_number)) group by A
               ORDER BY 3  ))';


x_sql_sttmnt:='insert into biv_tmp_rt1(report_code,rowno,session_id,col2,col4,col6,col8,col10)
              '||x_sql_sttmnt||' '  ;

if (l_debug = 'Y') then
   biv_core_pkg.biv_debug(x_sql_sttmnt,'BIV_CUSTOMER_BACKLOG');
   commit;
end if;

x_cur:=dbms_sql.open_cursor;
dbms_sql.parse(x_cur,x_sql_sttmnt,dbms_sql.native);
biv_core_pkg.bind_all_variables(x_cur);
dbms_sql.bind_variable(x_cur,':x_severity_id',x_severity_id);
dbms_sql.bind_variable(x_cur,':x_session',x_session);
x_dummy:=dbms_sql.execute(x_cur);
dbms_sql.close_cursor(x_cur);

update biv_tmp_rt1
set ID=biv_core_pkg.g_cust_id(1);


biv_core_pkg.reset_view_by_param;
l_new_param_str := 'BIV_SERVICE_REQUEST' ||biv_core_pkg.g_param_sep ||
                       biv_core_pkg.reconstruct_param_str;
l_new_param_str := l_new_param_str ||'P_CUST_ID' ||biv_core_pkg.g_value_sep ;

if (l_debug = 'Y') then
   biv_core_pkg.biv_debug(biv_core_pkg.reconstruct_param_str,
                         'BIV_CUSTOMER_BACKLOG');
end if;
-- 'jtfBinId' ||biv_core_pkg.g_value_sep || 'BIV_SERVICE_REQUEST' ||biv_core_pkg.g_param_sep ||
-- may be cust_id in update in not needed
update biv_tmp_rt1 d
   set col3=l_new_param_str||nvl(to_char(d.ID),biv_core_pkg.g_null)||
            biv_core_pkg.g_param_sep ||'P_UNOWN'|| biv_core_pkg.g_value_sep ||
            'Y'||biv_core_pkg.g_param_sep ||'P_CNTR_ID' ||
            biv_core_pkg.g_value_sep||nvl(d.col2,biv_core_pkg.g_null)||
            biv_core_pkg.g_param_sep||'P_BLOG'|| biv_core_pkg.g_value_sep ||
            'Y'||biv_core_pkg.g_param_sep,
       col5=l_new_param_str||nvl(to_char(d.ID),biv_core_pkg.g_null)||
            biv_core_pkg.g_param_sep ||'P_ESC_SR'|| biv_core_pkg.g_value_sep ||
            'Y'||biv_core_pkg.g_param_sep ||'P_CNTR_ID' ||
            biv_core_pkg.g_value_sep||nvl(d.col2,biv_core_pkg.g_null)||
            biv_core_pkg.g_param_sep||'P_BLOG'|| biv_core_pkg.g_value_sep ||
            'Y'||biv_core_pkg.g_param_sep,
       col7=l_new_param_str||nvl(to_char(d.ID),biv_core_pkg.g_null)||
            biv_core_pkg.g_param_sep ||'P_BLOG'|| biv_core_pkg.g_value_sep ||
            'Y'||biv_core_pkg.g_param_sep ||'P_CNTR_ID' ||
            biv_core_pkg.g_value_sep||nvl(d.col2,biv_core_pkg.g_null)||
            biv_core_pkg.g_param_sep,
       col9=l_new_param_str||nvl(to_char(d.ID),biv_core_pkg.g_null)||
            biv_core_pkg.g_param_sep ||'P_SEV'|| biv_core_pkg.g_value_sep ||
            to_char(x_severity_id)||biv_core_pkg.g_param_sep ||'P_CNTR_ID' ||
            biv_core_pkg.g_value_sep||nvl(d.col2,biv_core_pkg.g_null)||
            biv_core_pkg.g_param_sep||'P_BLOG'|| biv_core_pkg.g_value_sep ||
            'Y'||biv_core_pkg.g_param_sep,
  col20 = 'INDV_ROW',
  creation_date = sysdate;

/*** 7/30/2 not needed as this drill does not have g_disp. it is to display all
select count(1) into l_ttl_recs
  from biv_tmp_rt1
 where session_id = x_session
   and report_code = 'BIV_CUSTOMER_BACKLOG';
*****/

  insert into biv_tmp_rt1 ( report_code,session_id, rowno, col4, col6,
                            col8, col10, col20)
    select 'BIV_CUSTOMER_BACKLOG', x_session, max(rowno)+1,sum(col4),
           sum(col6), sum(col8), sum(col10), 'TTL_ROW'
      from biv_tmp_rt1
     where session_id = x_session
       and col20 = 'INDV_ROW'
       and report_code = 'BIV_CUSTOMER_BACKLOG';

l_new_param_str := 'BIV_SERVICE_REQUEST' ||biv_core_pkg.g_param_sep ||
                       biv_core_pkg.reconstruct_param_str;
   l_ttl_meaning := biv_core_pkg.get_lookup_meaning('TOTAL');
update biv_tmp_rt1 d
   set col3=l_new_param_str||
            'P_UNOWN'|| biv_core_pkg.g_value_sep ||
            'Y'||
            biv_core_pkg.g_param_sep||'P_BLOG'|| biv_core_pkg.g_value_sep ||
            'Y'||biv_core_pkg.g_param_sep,
       col5=l_new_param_str||
            'P_ESC_SR'|| biv_core_pkg.g_value_sep ||
            'Y'||
            biv_core_pkg.g_param_sep||'P_BLOG'|| biv_core_pkg.g_value_sep ||
            'Y'||biv_core_pkg.g_param_sep,
       col7=l_new_param_str||
            'P_BLOG'|| biv_core_pkg.g_value_sep ||
            'Y'||
            biv_core_pkg.g_param_sep,
       col9=l_new_param_str||
            'P_SEV'|| biv_core_pkg.g_value_sep ||
            to_char(x_severity_id)||
            biv_core_pkg.g_param_sep||'P_BLOG'|| biv_core_pkg.g_value_sep ||
            'Y'||biv_core_pkg.g_param_sep,
       col2=l_ttl_meaning,
  creation_date = sysdate
     where session_id = x_session
       and col20 = 'TTL_ROW'
       and report_code = 'BIV_CUSTOMER_BACKLOG';

exception
 when others then
    if (l_debug = 'Y') then
       biv_core_pkg.biv_debug('Error:'||substr(sqlerrm,1,200),
                              'BIV_CUSTOMER_BACKLOG');
    end if;
end; -- procedure customer_backlog_drill_down

  -- enter further code below as specified in the package spec.
end;

/
