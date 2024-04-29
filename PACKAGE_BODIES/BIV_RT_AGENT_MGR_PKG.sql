--------------------------------------------------------
--  DDL for Package Body BIV_RT_AGENT_MGR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIV_RT_AGENT_MGR_PKG" as
/* $Header: bivrmgrb.pls 115.16 2004/02/17 08:04:22 vganeshk ship $ */
procedure agent_report(p_param_str varchar2) as
   l_cur  number;
   l_from_list     varchar2(1000);
   l_from_list2    varchar2(1000);
   l_from_list3    varchar2(1000);
   l_where_clause  varchar2(2000);
   l_where_clause2 varchar2(2000);
   l_where_clause3 varchar2(2000);
   l_sql_sttmnt    varchar2(5000);
   l_order_by      varchar2(80);
   l_dummy number;
   x_param_str     varchar2(500);
   l_new_param_str varchar2(200);
   l_session_id    varchar2(50);
   l_dt            varchar2(20);
   l_dt_fmt        varchar2(50) := fnd_profile.value('ICX_DATE_FORMAT_MASK');
   l_ttl_recs      number;
   l_url1          varchar2(2000);
   l_url3          varchar2(2000);
   l_url5          varchar2(2000);
   l_url7          varchar2(2000);
   l_url9          varchar2(2000);
   l_url_base_col  varchar2(2000);
   l_ttl_desc      fnd_lookups.meaning % type;
   l_debug         varchar2(30) := fnd_profile.value('BIV:DEBUG');
begin
   biv_core_pkg.clean_dcf_table('biv_tmp_rt2');
   biv_core_pkg.g_report_id := 'BIV_RT_AGENT_REPORT';
   l_dt := to_char(sysdate,l_dt_fmt);
   if (l_debug = 'Y') then
      biv_core_pkg.biv_debug(p_param_str,biv_core_pkg.g_report_id);
      biv_core_pkg.biv_debug('Date:'|| l_dt || ', format:' || l_dt_fmt,
                             biv_core_pkg.g_report_id);
   end if;

   l_session_id := biv_core_pkg.get_session_id;

   biv_core_pkg.get_report_parameters(p_param_str);

   -- Change for Bug 3386946
   l_from_list := ' FROM cs_incidents_b_sec sr,
                         cs_incident_statuses_b stat';
   biv_core_pkg.get_where_clause(l_from_list,l_where_clause);
   l_from_list2 := l_from_list || ',
                      cs_incidents_all_tl srt ';
   l_where_clause := l_where_clause || '
                       and sr.incident_status_id = stat.incident_status_id ';
                      -- and sr.resource_type = ''RS_EMPLOYEE''
                      -- and sr.incident_owner_id is not null
   l_where_clause2 := l_where_clause || '
                         and sr.incident_id = srt.incident_id
                         and srt.language = userenv(''LANG'') ';

  if (l_debug = 'Y') then
     biv_core_pkg.biv_debug(l_where_clause,biv_core_pkg.g_report_id);
  end if;

  /**** 10/11/2003. see the reason in manager report.
  if (biv_core_pkg.g_srt_by = '2') then
  l_sql_sttmnt := '
    SELECT sr.incident_owner_id ,
           count(sr.incident_id) col2
      ' || l_from_list || l_where_clause || '
       and nvl(stat.close_flag,''N'') <> ''Y''
     group by sr.incident_owner_id
     order by 2 desc';
  elsif (biv_core_pkg.g_srt_by = '3') then
  l_sql_sttmnt := '
    SELECT sr.incident_owner_id,
           sum(decode(upper(sr.sr_creation_channel), ''WEB'',1,0)) col2
      ' || l_from_list || l_where_clause || '
       and sr.incident_date >= trunc(sysdate)
       and sr.incident_date <  trunc(sysdate+1)
       and sr.sr_creation_channel = ''WEB''
     group by sr.incident_owner_id
     order by 2 desc';
  elsif (biv_core_pkg.g_srt_by = '4') then
  l_sql_sttmnt := '
    SELECT sr.incident_owner_id,
           sum(decode(upper(sr.sr_creation_channel), ''PHONE'',1,0)) col2
      ' || l_from_list || l_where_clause || '
       and sr.incident_date >= trunc(sysdate)
       and sr.incident_date <  trunc(sysdate+1)
       and sr.sr_creation_channel = ''PHONE''
     group by sr.incident_owner_id
     order by 2 desc';
  elsif (biv_core_pkg.g_srt_by = '5') then
  l_sql_sttmnt := '
    SELECT sr.incident_owner_id ,
           count(sr.incident_id)  col2
      ' || l_from_list || l_where_clause || '
       and sr.close_date >= trunc(sysdate)
       and sr.close_date <  trunc(sysdate+1)
       and nvl(stat.close_flag,''N'') = ''Y''
     group by sr.incident_owner_id
     order by 2 desc';
 ******************** 10/11/2003 ***********************/
  if (biv_core_pkg.g_srt_by = '1') then
  if (biv_core_pkg.g_agrp_cnt > 0) then
  l_sql_sttmnt := '
    SELECT sr.incident_owner_id ,
           count(sr.incident_id) col2
      ' || l_from_list || l_where_clause || '
     group by sr.incident_owner_id
     order by 1 desc';
  else
  biv_bin_esc_rsc_pkg.get_resource_where_clause(l_from_list3,l_where_clause3);
  l_sql_sttmnt := '
    SELECT distinct rsc.resource_id incident_owner_id,
           substr(rsc.source_name,1,50) col2
      ' || l_from_list3 || l_where_clause3 || '
     order by 2 asc';
  end if;

  l_sql_sttmnt := '
      insert into biv_tmp_rt2(report_code, col1, col4, session_id)
       SELECT ''X'', incident_owner_id, col2, :session_id
         FROM (' || l_sql_sttmnt || ')
        WHERE rownum <= :rows_to_display ';-- || biv_core_pkg.g_disp;

   if (l_debug = 'Y') then
      biv_core_pkg.biv_debug(l_sql_sttmnt,biv_core_pkg.g_report_id);
   end if;

   l_cur := dbms_sql.open_cursor;
   dbms_sql.parse(l_cur,l_sql_sttmnt,dbms_sql.native);
   biv_core_pkg.bind_all_variables(l_cur);
   dbms_sql.bind_variable(l_cur,':session_id',l_session_id);
   dbms_sql.bind_variable(l_cur,':rows_to_display',
                            to_number(biv_core_pkg.g_disp));
   l_dummy := dbms_sql.execute(l_cur);
   dbms_sql.close_cursor(l_cur);
   biv_core_pkg.update_base_col_desc('biv_tmp_rt2');
  end if;

 /***** 10/11/2002
  the above sql statement will few rows where order col is not null.
  this is causing total line to be different and drill down from total line
  print real total and hence confusion
  l_from_list := l_from_list || ',
                   biv_tmp_rt2 rep';
  l_from_list2:= l_from_list2 || ',
                   biv_tmp_rt2 rep';
  l_where_clause := l_where_clause || '
    and to_char(nvl(sr.incident_owner_id'||',-999))=nvl(rep.col1,''-999'')
    and rep.report_code = ''X''
    and rep.session_id = :session_id ';
  l_where_clause2 := l_where_clause2 || '
    and to_char(nvl(sr.incident_owner_id'||',-999))=nvl(rep.col1,''-999'')
    and rep.report_code = ''X''
    and rep.session_id = :session_id ';
*****/
  l_sql_sttmnt := '
    SELECT sr.incident_owner_id col1,
           1 col4, 0 col6, 0 col8, 0 col10
      ' || l_from_list || l_where_clause || '
       and nvl(stat.close_flag,''N'') <> ''Y''
   UNION ALL
    SELECT sr.incident_owner_id,
           0,decode(upper(sr.sr_creation_channel), ''WEB'',1,0),
             decode(upper(sr.sr_creation_channel), ''PHONE'',1,0),0
      ' || l_from_list || l_where_clause || '
       and sr.incident_date >= trunc(sysdate)
       and sr.incident_date <  trunc(sysdate+1)
    UNION ALL
    SELECT sr.incident_owner_id ,
           0, 0, 0, 1
      ' || l_from_list || l_where_clause || '
       and sr.close_date >= trunc(sysdate)
       and sr.close_date <  trunc(sysdate+1)
       and nvl(stat.close_flag,''N'') = ''Y''';

  if (biv_core_pkg.g_srt_by = '1') then
     l_sql_sttmnt :=  l_sql_sttmnt || '
      UNION ALL
      SELECT to_number(col1), 0,0,0,0
       FROM biv_tmp_rt2  rep
      WHERE session_id = :session_id
';
  end if;

  l_sql_sttmnt := '
      SELECT col1, sum(col4) col4, sum(col6) col6,
                   sum(col8) col8, sum(col10) col10
        FROM (' || l_sql_sttmnt || ')
       group by col1';

  l_sql_sttmnt := '
       insert into biv_tmp_rt2 (report_code,rowno,
                         col1, col4, col6, col8, col10, col12, session_id)
         SELECT ''Y'', rownum,
                col1, col4, col6, col8, col10, ''N'', :session_id
           FROM (' || l_sql_sttmnt || ')
           ';

   if (l_debug = 'Y') then
      biv_core_pkg.biv_debug(l_sql_sttmnt,biv_core_pkg.g_report_id);
   end if;

   l_cur := dbms_sql.open_cursor;
   dbms_sql.parse(l_cur,l_sql_sttmnt,dbms_sql.native);
   biv_core_pkg.bind_all_variables(l_cur);
   dbms_sql.bind_variable(l_cur, ':session_id', l_session_id);
   l_dummy := dbms_sql.execute(l_cur);
   biv_core_pkg.update_base_col_desc('biv_tmp_rt2');

   if (nvl(biv_core_pkg.g_srt_by,'1') = '1') then
      l_order_by := '1 asc';
   else
      l_order_by := 'to_number(col' || to_number(biv_core_pkg.g_srt_by)*2 ||
                     ') desc';
   end if;
    x_param_str := substr(p_param_str,1,length(p_param_str)-2);
   l_sql_sttmnt := '
       insert into biv_tmp_rt2(report_code,rowno,id,
                   col1,col2,col4,col6,col8,col10,col12,col3,col5,col7,col9,
                   session_id)
        SELECT ''BIV_RT_AGENT_REPORT'', rownum,col1,
               col1, col2, col4, col6, col8, col10,col12,
               col1 ,
               col1 ,
               col1 ,
               col1 ,
               session_id
         FROM (SELECT col2,col4, col6,col8,col10,col12, col1, session_id
                 FROM biv_tmp_rt2
                WHERE report_code = ''Y''
                 and session_id = :session_id
                order by ' || l_order_by || ', col2
              )
        WHERE rownum <= :rows_to_display ';-- || nvl(biv_core_pkg.g_disp,200);
   if (l_debug = 'Y') then
      biv_core_pkg.biv_debug(l_sql_sttmnt,biv_core_pkg.g_report_id);
   end if;
   execute immediate l_sql_sttmnt using l_session_id,
                                        biv_core_pkg.g_disp;

   biv_core_pkg.reset_view_by_param;
   l_new_param_str := 'BIV_SERVICE_REQUEST' ||biv_core_pkg.g_param_sep
                      || biv_core_pkg.reconstruct_param_str;
     -- 7/23/2 above line reconstruct_param_str is needed because assignment
     -- group parameter compares owner_group_id and one agent may be
     -- present in many owner group ids. same could be applicable to other
     -- parameters.
     -- 5/9/2 above line s commented because for all the lines we have agent id
     -- as parameter, so no need for manage or org or asg group ids
     -- those parameter will cause extrac join but results will be same.
   l_new_param_str := l_new_param_str || 'jtfBinId' ||
                      biv_core_pkg.g_value_sep || 'BIV_SERVICE_REQUEST' ||
                      biv_core_pkg.g_param_sep ||'P_AGENT_ID' ||
                      biv_core_pkg.g_value_sep ;

   delete FROM biv_tmp_rt2
    WHERE report_code in ('X', 'Y')
      and session_id = l_session_id
     ;
   commit;
   update biv_tmp_rt2
      set col1 = 'resource' || biv_core_pkg.g_param_sep ||
          --          'ID' || biv_core_pkg.g_value_sep || col1,
                  'p_resource_id' || biv_core_pkg.g_value_sep || col1,
          col3 = l_new_param_str || nvl(col1,biv_core_pkg.g_null) ||
                 biv_core_pkg.g_param_sep ||
                 'P_BLOG'|| biv_core_pkg.g_value_sep || 'Y',
          col7 = l_new_param_str || nvl(col1,biv_core_pkg.g_null) ||
                 biv_core_pkg.g_param_sep ||
                 'P_CHNL' || biv_core_pkg.g_value_sep || 'PHONE' ||
                 biv_core_pkg.g_param_sep || 'P_TODAY_ONLY' ||
                 biv_core_pkg.g_value_sep || 'Y',
          col5 = l_new_param_str || nvl(col1,biv_core_pkg.g_null) ||
                 biv_core_pkg.g_param_sep ||
                 'P_CHNL' || biv_core_pkg.g_value_sep || 'WEB' ||
                 biv_core_pkg.g_param_sep || 'P_TODAY_ONLY' ||
                 biv_core_pkg.g_value_sep || 'Y',
          col9 = l_new_param_str || nvl(col1,biv_core_pkg.g_null) ||
                 biv_core_pkg.g_param_sep ||
                 'P_CLOSE_SR' || biv_core_pkg.g_value_sep || 'Y' ||
                 biv_core_pkg.g_param_sep || 'P_CL_ST' ||
                 biv_core_pkg.g_value_sep || l_dt ||
                 biv_core_pkg.g_param_sep || 'P_CL_END' ||
                 biv_core_pkg.g_value_sep || l_dt ,
          creation_date = sysdate
    WHERE report_code = 'BIV_RT_AGENT_REPORT'
      and session_id = l_session_id;

    -- Change for Bug 3448591
    update biv_tmp_rt2 rpt
       set col12 = 'Y'
      WHERE session_id = l_session_id
       and report_code = 'BIV_RT_AGENT_REPORT'
       and exists ( SELECT 1 FROM JTF_RS_WEB_AVAILABLE_V avl
                     WHERE avl.resource_id = rpt.id);
  commit;
  ---
  --- Add a row fot toal of all column
  ---
  SELECT count(*) into l_ttl_recs
    FROM biv_tmp_rt2
   WHERE report_code = 'BIV_RT_AGENT_REPORT'
     and session_id = l_session_id;
  if ( l_ttl_recs > 1 and l_ttl_recs < biv_core_pkg.g_disp ) then
     if (l_debug = 'Y') then
        biv_core_pkg.biv_debug('Adding Total row',biv_core_pkg.g_report_id);
     end if;
     insert into biv_tmp_rt2 (report_code, rowno,
                              col4, col6, col8, col10, col13,session_id)
      SELECT report_code, max(rowno) + 1, sum(col4), sum(col6), sum(col8),
              sum(col10) ,'Y', session_id
        FROM biv_tmp_rt2
       WHERE session_id = l_session_id
        and report_code = 'BIV_RT_AGENT_REPORT'
       group by report_code, session_id;
   l_new_param_str := 'BIV_SERVICE_REQUEST' ||biv_core_pkg.g_param_sep ||
                       biv_core_pkg.reconstruct_param_str;
   l_new_param_str := l_new_param_str || 'jtfBinId' ||
                      biv_core_pkg.g_value_sep || 'BIV_SERVICE_REQUEST' ||
                      biv_core_pkg.g_param_sep
                      ;

   l_ttl_desc := biv_core_pkg.get_lookup_meaning('TOTAL');
   update biv_tmp_rt2
      set col2 = l_ttl_desc,
          col1 = 'resource' || biv_core_pkg.g_param_sep ||
                  'p_resource_id' || biv_core_pkg.g_value_sep || col1,
          col3 = l_new_param_str ||
                 'P_BLOG'|| biv_core_pkg.g_value_sep || 'Y',
          col7 = l_new_param_str ||
                 'P_CHNL' || biv_core_pkg.g_value_sep || 'PHONE' ||
                 biv_core_pkg.g_param_sep || 'P_TODAY_ONLY' ||
                 biv_core_pkg.g_value_sep || 'Y',
          col5 = l_new_param_str ||
                 'P_CHNL' || biv_core_pkg.g_value_sep || 'WEB' ||
                 biv_core_pkg.g_param_sep || 'P_TODAY_ONLY' ||
                 biv_core_pkg.g_value_sep || 'Y',
          col9 = l_new_param_str ||
                 'P_CLOSE_SR' || biv_core_pkg.g_value_sep || 'Y' ||
                 biv_core_pkg.g_param_sep || 'P_CL_ST' ||
                 biv_core_pkg.g_value_sep || l_dt ||
                 biv_core_pkg.g_param_sep || 'P_CL_END' ||
                 biv_core_pkg.g_value_sep || l_dt ,
          creation_date = sysdate
    WHERE report_code = 'BIV_RT_AGENT_REPORT'
      and session_id = l_session_id
      and col13 = 'Y';
  end if;
  --- End of Total row
  if (l_debug = 'Y') then
     biv_core_pkg.biv_debug('End of Report',biv_core_pkg.g_report_id);
  end if;
  biv_core_pkg.g_report_id := null;
  exception
   when others then
      rollback;
      if (l_debug = 'Y') then
         biv_core_pkg.biv_debug(l_sql_sttmnt, biv_core_pkg.g_report_id);
         biv_core_pkg.biv_debug('Err:' ||sqlerrm, biv_core_pkg.g_report_id);
         l_new_param_str := 'Err:'||substr(sqlerrm,1,145);
         insert into biv_tmp_rt2 (report_code, session_id,col2)
          values('BIV_RT_AGENT_REPORT',l_session_id, l_new_param_str);
         commit;
      end if;
end;
procedure manager_report(p_param_str varchar2) as
   l_cur  number;
   l_from_list     varchar2(1000);
   l_where_clause  varchar2(2000);
   l_from_list2    varchar2(1000);
   l_where_clause2 varchar2(2000);
   l_sql_sttmnt    varchar2(4000);
   l_order_by      varchar2(80);
   l_new_param_str varchar2(200);
   l_ttl_param_str varchar2(200);
   l_dummy number;
   l_session_id    biv_tmp_rt2.session_id % type;
   l_pos           varchar2(50);
   l_dt_fmt        varchar2(50) := fnd_profile.value('ICX_DATE_FORMAT_MASK');
   l_dt            varchar2(50);
   l_ttl_recs      number;
   l_ttl_desc      fnd_lookups.meaning % type;
   l_debug         varchar2(30) := fnd_profile.value('BIV:DEBUG');
begin
   biv_core_pkg.clean_dcf_table('biv_tmp_rt2');
   l_dt := to_char(sysdate,l_dt_fmt);
   biv_core_pkg.g_report_id := 'BIV_RT_MANAGER_REPORT';
   if (l_debug = 'Y') then
      biv_core_pkg.biv_debug(p_param_str,biv_core_pkg.g_report_id);
   end if;
   l_session_id := biv_core_pkg.get_session_id;
   biv_core_pkg.get_report_parameters(p_param_str);
   -- Change for Bug 3386946
   l_from_list := ' FROM cs_incidents_b_sec sr';
   biv_core_pkg.get_where_clause(l_from_list,l_where_clause);

   l_from_list2    := l_from_list || ',
                        cs_incident_statuses_b stat ';
   l_where_clause2 := l_where_clause || '
                        and sr.incident_status_id = stat.incident_status_id ';

   -- remove it
   --
   --
   --biv_core_pkg.g_srt_by := '4';
   --
   --
   --
   --
   --
   --
   --
   --

   /* 10/11/2003 This part is not necessary. Total line problem
      report print total from rows displayed but real total of columns
      such as total backlog may be different and when you drilldown, it
      displays real total.

      This part was written so that you get data for order by column and
      rejected record with 0 values. In this way this section is rejecting
      all other records where other columns have values. Suppose order by is
      New requests and there are 10 managers who do not have any new request
      bug have some backlog. Then this section will cause those managers
      not get selected. so total backlog in total line will not represent
      TOTAL backlog. when click on total backlog, it displays the TOTAL
      backlog which obivously does not match the total line value.
   if    (biv_core_pkg.g_srt_by = '2') then
      l_sql_sttmnt := '
        SELECT ' || biv_core_pkg.g_base_column || ' col1,
                        count(sr.incident_id) col2
                  ' || l_from_list || l_where_clause || '
                   and sr.incident_date >= trunc(sysdate)
                   and sr.incident_date <  trunc(sysdate+1)
                  group by ' || biv_core_pkg.g_base_column || '
                  order by 2 desc  ';
   elsif (biv_core_pkg.g_srt_by = '3') then
      l_sql_sttmnt := '
                SELECT ' || biv_core_pkg.g_base_column || ' col1,
                        count(sr.incident_id) col2
                  ' || l_from_list2 || l_where_clause2 || '
                   and nvl(stat.close_flag,''N'') = ''Y''
                   and sr.close_date >= trunc(sysdate)
                   and sr.close_date <  trunc(sysdate+1)
                   group by ' || biv_core_pkg.g_base_column || '
                  order by 2 desc  ';
   elsif (biv_core_pkg.g_srt_by = '4') then
      l_sql_sttmnt := '
                SELECT ' || biv_core_pkg.g_base_column || ' col1,
                        count(sr.incident_id) col2
                  ' || l_from_list2 || l_where_clause2 || '
                   and nvl(stat.close_flag,''N'') <> ''Y''
                   group by ' || biv_core_pkg.g_base_column || '
                  order by 2 desc ' ;
   else
      l_sql_sttmnt := '
                SELECT ' || biv_core_pkg.g_base_column || ' col1, ' ||
                       biv_core_pkg.g_base_column || ' col2 '
                   || l_from_list || l_where_clause || '
                   group by ' || biv_core_pkg.g_base_column ;
   end if;

  l_sql_sttmnt := '
      insert into biv_tmp_rt2(report_code, col1, col4,session_id)
       SELECT ''X'', col1, col2, :session_id
         FROM (' || l_sql_sttmnt || ')
        WHERE rownum <= :rows_to_display '; -- || biv_core_pkg.g_disp;

   if (l_debug = 'Y') then
      biv_core_pkg.biv_debug(l_sql_sttmnt,biv_core_pkg.g_report_id);
   end if;

   l_cur := dbms_sql.open_cursor;
   dbms_sql.parse(l_cur,l_sql_sttmnt,dbms_sql.native);
   biv_core_pkg.bind_all_variables(l_cur);
   dbms_sql.bind_variable(l_cur,':session_id', l_session_id);
   dbms_sql.bind_variable(l_cur,':rows_to_display', biv_core_pkg.g_disp);
   l_pos := 'Before Execute';
   l_dummy := dbms_sql.execute(l_cur);
   dbms_sql.close_cursor(l_cur);

  l_from_list := l_from_list || ',
                   biv_tmp_rt2 rep';
  l_from_list2:= l_from_list2 || ',
                   biv_tmp_rt2 rep';
  l_where_clause := l_where_clause || '
                    and nvl('||biv_core_pkg.g_base_column||
                             ',''-999'') = to_number(nvl(rep.col1,''-999''))
                    and session_id = :session_id ';
  l_where_clause2 := l_where_clause2 || '
                    and nvl('||biv_core_pkg.g_base_column||
                             ',''-999'') = to_number(nvl(rep.col1,''-999''))
                    and session_id = :session_id ';
****************************************************/



   l_sql_sttmnt := '
        SELECT col1, sum(col4) col4, sum(col6) col6, sum(col8) col8,
               :session_id session_id
          FROM ( SELECT ' || biv_core_pkg.g_base_column || ' col1,
                        1 col4, 0 col6, 0 col8
                  ' || l_from_list || l_where_clause || '
                   and sr.incident_date >= trunc(sysdate)
                   and sr.incident_date <  trunc(sysdate+1)
               UNION ALL
                SELECT ' || biv_core_pkg.g_base_column || ' col1,
                        0, 1, 0
                  ' || l_from_list2 || l_where_clause2 || '
                   and nvl(stat.close_flag,''N'') = ''Y''
                   and sr.close_date >= trunc(sysdate)
                   and sr.close_date <  trunc(sysdate+1)
               UNION ALL
                SELECT ' || biv_core_pkg.g_base_column || ' col1,
                        0, 0, 1
                  ' || l_from_list2 || l_where_clause2 || '
                   and nvl(stat.close_flag,''N'') <> ''Y''
                ) group by col1 ';

  l_sql_sttmnt := '
       insert into biv_tmp_rt2 (report_code,rowno,
                         col1, col4, col6, col8,session_id)
         SELECT ''Y'', rownum,
                col1, col4, col6, col8,session_id
           FROM (' || l_sql_sttmnt || ')';

   if (l_debug = 'Y') then
      biv_core_pkg.biv_debug(l_sql_sttmnt,biv_core_pkg.g_report_id);
   end if;

   l_cur := dbms_sql.open_cursor;
   dbms_sql.parse(l_cur,l_sql_sttmnt,dbms_sql.native);
   biv_core_pkg.bind_all_variables(l_cur);
   dbms_sql.bind_variable(l_cur,':session_id', l_session_id);
   l_pos := 'Before 2nd Execute';
   l_dummy := dbms_sql.execute(l_cur);
   biv_core_pkg.update_base_col_desc('biv_tmp_rt2');

   if (biv_core_pkg.g_srt_by = '2') then
      l_order_by := 'to_number(col4) desc';
   elsif (biv_core_pkg.g_srt_by = '3') then
      l_order_by := 'to_number(col6) desc';
   elsif (biv_core_pkg.g_srt_by = '4') then
      l_order_by := 'to_number(col8) desc';
   else
      l_order_by := 'col2 asc';
   end if;

   l_ttl_param_str := 'BIV_SERVICE_REQUEST' ||biv_core_pkg.g_param_sep ||
                       biv_core_pkg.reconstruct_param_str;
   l_ttl_param_str := l_ttl_param_str || 'jtfBinId' ||
                      biv_core_pkg.g_value_sep || 'BIV_SERVICE_REQUEST' ||
                      biv_core_pkg.g_param_sep;
   -- new reset view by param for all other rows.
   biv_core_pkg.reset_view_by_param;
   l_new_param_str := 'BIV_SERVICE_REQUEST' ||biv_core_pkg.g_param_sep ||
                       biv_core_pkg.reconstruct_param_str;
   l_new_param_str := l_new_param_str || 'jtfBinId' ||
                      biv_core_pkg.g_value_sep || 'BIV_SERVICE_REQUEST' ||
                      biv_core_pkg.g_param_sep ||
                      biv_core_pkg.param_for_base_col ||
                      biv_core_pkg.g_value_sep ;

   l_sql_sttmnt := '
       insert into biv_tmp_rt2(report_code,rowno, col1, col2,
                                    col4, col6, col8,session_id)
        SELECT ''BIV_RT_MANAGER_REPORT'', rownum,
               col1, col2, col4, col6, col8,session_id
         FROM (SELECT col1, col2, col4, col6, col8,session_id
                 FROM biv_tmp_rt2
                WHERE report_code =''Y''
                  and session_id = :session_id
                order by ' || l_order_by || ')
        WHERE rownum <= :rows_to_display '; --|| nvl(biv_core_pkg.g_disp,'10');
   l_pos := 'Before 3rd Execute';
   if (l_debug = 'Y') then
      biv_core_pkg.biv_debug(l_sql_sttmnt,biv_core_pkg.g_report_id);
      biv_core_pkg.biv_debug('Order By :'||l_order_by||':',
                                          biv_core_pkg.g_report_id);
   end if;
   execute immediate l_sql_sttmnt using l_session_id,
                                        biv_core_pkg.g_disp;
   l_pos := 'deleting temp records';
   delete from biv_tmp_rt2
    where session_id = l_session_id
      and report_code in ('X', 'Y');
   l_pos := 'Before Update of odd columns';
   update biv_tmp_rt2
      set col7 = l_new_param_str || nvl(col1,biv_core_pkg.g_null) ||
                 biv_core_pkg.g_param_sep ||
                 'P_BLOG'||biv_core_pkg.g_value_sep||'Y',
          col3 = l_new_param_str || nvl(col1,biv_core_pkg.g_null) ||
                 biv_core_pkg.g_param_sep ||
                 'P_TODAY_ONLY'||biv_core_pkg.g_value_sep||'Y',
          col5 = l_new_param_str || nvl(col1,biv_core_pkg.g_null) ||
                 biv_core_pkg.g_param_sep ||
                 'P_CLOSE_SR' || biv_core_pkg.g_value_sep || 'Y' ||
                 biv_core_pkg.g_param_sep || 'P_CL_ST' ||
                 biv_core_pkg.g_value_sep || l_dt ||
                 biv_core_pkg.g_param_sep || 'P_CL_END' ||
                 biv_core_pkg.g_value_sep || l_dt ,
          creation_date = sysdate
     WHERE report_code = 'BIV_RT_MANAGER_REPORT'
       and session_id = l_session_id;
  ---
  --- Add a row fot toal of all column
  ---
  SELECT count(*) into l_ttl_recs
    FROM biv_tmp_rt2
   WHERE report_code = 'BIV_RT_MANAGER_REPORT'
     and session_id = l_session_id;
  if ( l_ttl_recs > 1 and l_ttl_recs < biv_core_pkg.g_disp ) then
     if (l_debug = 'Y') then
        biv_core_pkg.biv_debug('Adding Total row: Manager Report',
                               biv_core_pkg.g_report_id);
     end if;
     insert into biv_tmp_rt2 (report_code, rowno,
                              col4, col6, col8,  col13,session_id)
      SELECT report_code, max(rowno) + 1, sum(col4), sum(col6), sum(col8),
              'Y', session_id
        FROM biv_tmp_rt2
       WHERE session_id = l_session_id
        and report_code = 'BIV_RT_MANAGER_REPORT'
       group by report_code, session_id;
   if (biv_core_pkg.g_view_by = 'AGRP') then
       l_ttl_param_str := l_ttl_param_str || 'P_AGRP_LVL' ||
                      biv_core_pkg.g_value_sep || biv_core_pkg.g_lvl ||
                      biv_core_pkg.g_param_sep;
   elsif (biv_core_pkg.g_view_by = 'OGRP') then
       l_ttl_param_str := l_ttl_param_str || 'P_OGRP_LVL' ||
                      biv_core_pkg.g_value_sep || biv_core_pkg.g_lvl ||
                      biv_core_pkg.g_param_sep;
   end if;
   l_ttl_desc := biv_core_pkg.get_lookup_meaning('TOTAL');
   update biv_tmp_rt2
      set col2 = l_ttl_desc,
          col7 = l_ttl_param_str ||
                 'P_BLOG'||biv_core_pkg.g_value_sep||'Y',
          col3 = l_ttl_param_str ||
                 'P_TODAY_ONLY'||biv_core_pkg.g_value_sep||'Y',
          col5 = l_ttl_param_str ||
                 'P_CLOSE_SR' || biv_core_pkg.g_value_sep || 'Y' ||
                 biv_core_pkg.g_param_sep || 'P_CL_ST' ||
                 biv_core_pkg.g_value_sep || l_dt ||
                 biv_core_pkg.g_param_sep || 'P_CL_END' ||
                 biv_core_pkg.g_value_sep || l_dt ,
          creation_date = sysdate
     WHERE report_code = 'BIV_RT_MANAGER_REPORT'
       and session_id = l_session_id
       and col13 = 'Y';
  end if;

  ----
  ----
  ----
  if (l_debug = 'Y') then
     biv_core_pkg.biv_debug('End of Report',biv_core_pkg.g_report_id);
  end if;
  biv_core_pkg.g_report_id := null;
  commit;
  exception
   when others then
     if (l_debug = 'Y') then
        l_new_param_str := 'Err-manager_report at ' ||l_pos || ':'
                              ||substr(sqlerrm,1,145);
        biv_core_pkg.biv_debug(l_new_param_str, biv_core_pkg.g_report_id);
     end if;
end;
end;

/
