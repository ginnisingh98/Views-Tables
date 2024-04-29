--------------------------------------------------------
--  DDL for Package Body BIV_RT_TASK_BLOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIV_RT_TASK_BLOG_PKG" as
/* $Header: bivrtskb.pls 115.18 2004/01/23 04:56:21 vganeshk ship $ */
procedure sr_backlog(p_param_str varchar2) as
   x_status1 cs_incidents_all_b.incident_status_id % type;
   x_status2 cs_incidents_all_b.incident_status_id % type;
   x_status3 cs_incidents_all_b.incident_status_id % type;
   x_sql_sttmnt varchar2(5000);
   TYPE t_cursor is REF CURSOR;
   x_cur1 t_cursor;
   x_cur  number;

   x_cnt1   number;
   x_cnt2   number;
   x_cnt3   number;
   x_base_col_val number;
   x_rowno        number := 0;

   x_from_list    varchar2(1000);
   x_where_clause varchar2(2000);
   x_order_by     varchar2(80);
   x_param_name   varchar2(80);
   l_order_by     varchar2(80);
   l_new_param_str varchar2(200);
   l_ttl_param_str varchar2(200);
   l_base_col_param varchar2(40);
   x_dummy number;
   l_session_id   biv_tmp_rt2.session_id % type;
   l_ttl_recs     number;
   l_ttl_meaning  fnd_lookups.meaning % type;
   l_debug         varchar2(30) := fnd_profile.value('BIV:DEBUG');
begin
   biv_core_pkg.g_report_id := 'BIV_RT_BACKLOG_BY_STATUS';
   l_session_id := biv_core_pkg.get_session_id;
   biv_core_pkg.clean_dcf_table('biv_tmp_rt2');

   x_status1 := fnd_profile.value('BIV:INC_STATUS_1');
   x_status2 := fnd_profile.value('BIV:INC_STATUS_2');
   x_status3 := fnd_profile.value('BIV:INC_STATUS_3');

   biv_core_pkg.get_report_parameters(p_param_str);

   if (l_debug = 'Y') then
      biv_core_pkg.biv_debug('Parameter:'||p_param_str,
                                            biv_core_pkg.g_report_id);
      biv_core_pkg.biv_debug('Status Profiles are:'||x_status1||','||
                                            x_status2||','||
                                            x_status3, 'BIV_RT_SR_BACKLOG');
   end if;

   -- Change for Bug 3386946
   x_from_list := ' from cs_incidents_b_sec sr, cs_incident_statuses_b stat ';
   biv_core_pkg.get_where_clause(x_from_list,x_where_clause);
   x_where_clause := x_where_clause ||
                      ' and sr.incident_status_id = stat.incident_status_id' ||
                      ' and nvl(stat.close_flag,''N'') != ''Y''';

   x_sql_sttmnt := 'select ''BACKLOG'', ' ||
                      biv_core_pkg.g_base_column || ' col1,' ||
                     'sum(decode(stat.close_flag,''Y'',0,1)) col4,
                      sum(decode(sr.incident_status_id, :x_stat1,1,0)) col6,
                      sum(decode(sr.incident_status_id, :x_stat2,1,0)) col8,
                      sum(decode(sr.incident_status_id, :x_stat3,1,0)) col10,
                      :session_id '||
                     x_from_list || x_where_clause ||
                  ' group by ' || biv_core_pkg.g_base_column
                 -- || ' order by ' || nvl(biv_core_pkg.g_srt_by,'2')
                  ;
   x_sql_sttmnt := 'insert into biv_tmp_rt2(report_code,col1,col4,
                      col6,col8,col10,session_id)
                     ' || x_sql_sttmnt  ;

   if (l_debug = 'Y') then
      biv_core_pkg.biv_debug(x_sql_sttmnt,biv_core_pkg.g_report_id);
   end if;
   x_cur := dbms_sql.open_cursor;
   dbms_sql.parse(x_cur,x_sql_sttmnt,dbms_sql.native);
   biv_core_pkg.bind_all_variables(x_cur);
   dbms_sql.bind_variable(x_cur,':x_stat1', x_status1);
   dbms_sql.bind_variable(x_cur,':x_stat2', x_status2);
   dbms_sql.bind_variable(x_cur,':x_stat3', x_status3);
   dbms_sql.bind_variable(x_cur,':session_id', l_session_id);
   x_dummy := dbms_sql.execute(x_cur);

   biv_core_pkg.update_base_col_desc('biv_tmp_rt2');
   update biv_tmp_rt2
      set col12 = col4 - col6 - col8 - col10
    where report_code = 'BACKLOG'
      and session_id = l_session_id;

   select decode(biv_core_pkg.g_srt_by, '2', 'to_number(col4) desc',
                           '3', 'to_number(col6) desc',
                           '4', 'to_number(col8) desc',
                           '5', 'to_number(col10) desc',
                           '6', 'to_number(col12) desc',
                          'col2 asc')
           into l_order_by from dual;

   x_sql_sttmnt := '
          insert into biv_tmp_rt2 (report_code, rowno, col1, col2,
                                   col4, col6, col8, col10, col12, session_id)
           select ''BIV_RT_BACKLOG_BY_STATUS'', rownum,
                  col1, col2, col4, col6, col8, col10, col12,session_id
            from (select col1, col2, col4, col6, col8, col10, col12,session_id
                    from biv_tmp_rt2
                   where report_code = ''BACKLOG''
                     and session_id = :session_id
                   order by ' || l_order_by || ')
           where rownum <= :rows_to_display ';-- || nvl(biv_core_pkg.g_disp,10);
   if (l_debug = 'Y') then
      biv_core_pkg.biv_debug(x_sql_sttmnt,biv_core_pkg.g_report_id);
   end if;
   execute immediate x_sql_sttmnt using l_session_id,biv_core_pkg.g_disp;
   x_param_name := biv_core_pkg.param_for_base_col;

   l_ttl_param_str := 'BIV_SERVICE_REQUEST' || biv_core_pkg.g_param_sep ||
            biv_core_pkg.reconstruct_param_str ||
            'jtfBinId'||biv_core_pkg.g_value_sep || 'BIV_SERVICE_REQUEST' ||
            biv_core_pkg.g_param_sep;
   biv_core_pkg.reset_view_by_param;
   l_new_param_str := 'BIV_SERVICE_REQUEST' || biv_core_pkg.g_param_sep ||
            biv_core_pkg.reconstruct_param_str ||
            'jtfBinId'||biv_core_pkg.g_value_sep || 'BIV_SERVICE_REQUEST' ||
            biv_core_pkg.g_param_sep ||
            biv_core_pkg.param_for_base_col || biv_core_pkg.g_value_sep;
--Change for bug 3093779 and enh 2914005 appended P_PREVR
   update biv_tmp_rt2
      set col5= l_new_param_str||col1||biv_core_pkg.g_param_sep ||
                'P_STS_ID' || biv_core_pkg.g_value_sep || x_status1 ||
                 biv_core_pkg.g_param_sep || 'P_PREVR' || biv_core_pkg.g_value_sep || 'BIV_RT_BACKLOG_BY_STATUS',
          col7= l_new_param_str||col1||biv_core_pkg.g_param_sep ||
                'P_STS_ID' || biv_core_pkg.g_value_sep || x_status2 ||
                 biv_core_pkg.g_param_sep || 'P_PREVR' || biv_core_pkg.g_value_sep || 'BIV_RT_BACKLOG_BY_STATUS',
          col9= l_new_param_str||col1||biv_core_pkg.g_param_sep ||
                'P_STS_ID' || biv_core_pkg.g_value_sep || x_status3 ||
                 biv_core_pkg.g_param_sep || 'P_PREVR' || biv_core_pkg.g_value_sep || 'BIV_RT_BACKLOG_BY_STATUS',
          col11=l_new_param_str||col1||biv_core_pkg.g_param_sep ||
                'P_OTHER_BLOG' || biv_core_pkg.g_value_sep || 'Y' ||
                 biv_core_pkg.g_param_sep || 'P_PREVR' || biv_core_pkg.g_value_sep || 'BIV_RT_BACKLOG_BY_STATUS',
          col3= l_new_param_str || col1 ||
                biv_core_pkg.g_param_sep || 'P_BLOG' ||
                biv_core_pkg.g_value_sep || 'Y' ||
                biv_core_pkg.g_param_sep || 'P_PREVR' || biv_core_pkg.g_value_sep || 'BIV_RT_BACKLOG_BY_STATUS',
          creation_date = sysdate
     where report_code = 'BIV_RT_BACKLOG_BY_STATUS'
       and session_id  = l_session_id
     ;
   delete from biv_tmp_rt2
    where report_code = 'BACKLOG'
      and session_id = l_session_id;

  ---
  --- Add a row fot toal of all column
  ---
  select count(*) into l_ttl_recs
    from biv_tmp_rt2
   where report_code = 'BIV_RT_BACKLOG_BY_STATUS'
     and session_id = l_session_id;
  if ( l_ttl_recs > 1 and l_ttl_recs < biv_core_pkg.g_disp ) then
  if (l_debug = 'Y') then
     biv_core_pkg.biv_debug('Adding Total row',biv_core_pkg.g_report_id);
  end if;
     insert into biv_tmp_rt2 (report_code, rowno,
                              col4, col6, col8, col10, col12, col13,session_id)
      select report_code, max(rowno) + 1, sum(col4), sum(col6), sum(col8),
              sum(col10), sum(col12), 'Y', session_id
        from biv_tmp_rt2
       where session_id = l_session_id
        and report_code = 'BIV_RT_BACKLOG_BY_STATUS'
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

   l_ttl_meaning := biv_core_pkg.get_lookup_meaning('TOTAL');
   --Change for bug 3093779 appended P_UA=N to all the total urls
   --Change for enh 2914005 appended P_PREVR to all the urls
   update biv_tmp_rt2
      set col5= l_ttl_param_str||
                'P_STS_ID' || biv_core_pkg.g_value_sep || x_status1 ||
                 biv_core_pkg.g_param_sep || 'P_UA' || biv_core_pkg.g_value_sep || 'N' ||
                 biv_core_pkg.g_param_sep || 'P_PREVR' || biv_core_pkg.g_value_sep || 'BIV_RT_BACKLOG_BY_STATUS',
          col7= l_ttl_param_str||
                'P_STS_ID' || biv_core_pkg.g_value_sep || x_status2 ||
                 biv_core_pkg.g_param_sep || 'P_UA' || biv_core_pkg.g_value_sep || 'N' ||
		 biv_core_pkg.g_param_sep || 'P_PREVR' || biv_core_pkg.g_value_sep || 'BIV_RT_BACKLOG_BY_STATUS',
          col9= l_ttl_param_str||
                'P_STS_ID' || biv_core_pkg.g_value_sep || x_status3 ||
                 biv_core_pkg.g_param_sep || 'P_UA' || biv_core_pkg.g_value_sep || 'N' ||
                 biv_core_pkg.g_param_sep || 'P_PREVR' || biv_core_pkg.g_value_sep || 'BIV_RT_BACKLOG_BY_STATUS',
          col11=l_ttl_param_str||
                'P_OTHER_BLOG' || biv_core_pkg.g_value_sep || 'Y' ||
                 biv_core_pkg.g_param_sep || 'P_UA' || biv_core_pkg.g_value_sep || 'N' ||
                 biv_core_pkg.g_param_sep || 'P_PREVR' || biv_core_pkg.g_value_sep || 'BIV_RT_BACKLOG_BY_STATUS',
          col3= l_ttl_param_str ||
                'P_BLOG' || biv_core_pkg.g_value_sep || 'Y' ||
                 biv_core_pkg.g_param_sep || 'P_UA' || biv_core_pkg.g_value_sep || 'N' ||
                 biv_core_pkg.g_param_sep || 'P_PREVR' || biv_core_pkg.g_value_sep || 'BIV_RT_BACKLOG_BY_STATUS',
          col2= l_ttl_meaning,
          creation_date = sysdate
     where report_code = 'BIV_RT_BACKLOG_BY_STATUS'
       and session_id  = l_session_id
       and col13 = 'Y'
     ;
  end if;
  ---
  ---
   biv_core_pkg.g_report_id := 'NULL';
   if (l_debug = 'Y') then
      biv_core_pkg.biv_debug('End of Report',biv_core_pkg.g_report_id);
   end if;
   exception
     when others then
        if (l_debug = 'Y') then
          biv_core_pkg.biv_debug(sqlerrm,biv_core_pkg.g_report_id);
        end if;
end sr_backlog;
procedure task_activity(p_param_str varchar2) as
   l_cur  number;
   l_from_list      varchar2(1000);
   l_where_clause   varchar2(2000);
   l_sql_sttmnt     varchar2(5000);
   l_order_by       varchar2(80);
   l_new_param_str1 varchar2(2000);
   l_new_param_str2 varchar2(2000);
   l_ttl_param_str1 varchar2(2000);
   l_ttl_param_str2 varchar2(2000);
   l_param_name     varchar2(80);
   l_dummy number;
   l_session_id   biv_tmp_rt2.session_id % type;
   l_ttl_recs     number;
   l_ttl_meaning  fnd_lookups.meaning % type;
   l_debug         varchar2(30) := fnd_profile.value('BIV:DEBUG');
begin
   biv_core_pkg.g_report_id := 'BIV_RT_TASK_ACTIVITY';
   l_session_id := biv_core_pkg.get_session_id;
   biv_core_pkg.clean_dcf_table('biv_tmp_rt2');

   biv_core_pkg.get_report_parameters(p_param_str);
   -- Change for Bug 3386946
   l_from_list := ' from cs_incidents_b_sec sr, jtf_tasks_b task' ||
                  ', jtf_task_statuses_b tstat, cs_incident_statuses_b stat';
   biv_core_pkg.get_where_clause(l_from_list,l_where_clause);
   l_where_clause := l_where_clause ||
                      ' and sr.incident_status_id = stat.incident_status_id' ||
                      ' and nvl(stat.close_flag,''N'') != ''Y'''             ||
                      ' and sr.incident_id = task.source_object_id'          ||
                      ' and task.source_object_type_code = ''SR'''           ||
                      ' and task.task_status_id = tstat.task_status_id'      ||
                      ' and nvl(tstat.closed_flag,''N'') != ''Y'''
                       ;
  l_sql_sttmnt := '
        select ' || biv_core_pkg.g_base_column || ' base_col,
               count(distinct sr.incident_id) no_of_srs,
               count(distinct task.task_id) no_of_tasks';

   l_sql_sttmnt := '
       insert into biv_tmp_rt2(report_code,rowno,
                                    col1,col4, col6,session_id)
         select ''X'', rownum,
                base_col, no_of_srs, no_of_tasks, :session_id
           from (' || l_sql_sttmnt || l_from_list || l_where_clause ||
           ' group by ' || biv_core_pkg.g_base_column  || ')';
   if (l_debug = 'Y') then
      biv_core_pkg.biv_debug(l_sql_sttmnt,'BIV_RT_TASK_ACTIVITY');
   end if;
   l_cur := dbms_sql.open_cursor;
   dbms_sql.parse(l_cur,l_sql_sttmnt,dbms_sql.native);
   biv_core_pkg.bind_all_variables(l_cur);
   dbms_sql.bind_variable(l_cur,':session_id',l_session_id);
   l_dummy := dbms_sql.execute(l_cur);
   biv_core_pkg.update_base_col_desc('biv_tmp_rt2');

   select decode(biv_core_pkg.g_srt_by,'2','to_number(col4) desc',
                                       '3','to_number(col6) desc',
                                         'col2 asc')
     into l_order_by
     from dual;
   l_sql_sttmnt := '
       insert into biv_tmp_rt2(report_code,rowno, col1,col2,
                               col4, col6,session_id)
        select ''BIV_RT_TASK_ACTIVITY'', rownum,
               col1, col2, col4, col6,session_id
          from ( select col1, col2, col4, col6,session_id
                   from biv_tmp_rt2
                  where report_code =''X''
                    and session_id = :session_id
                  order by ' || l_order_by || ' ,col2)
         where rownum <= :rows_to_display ';--|| nvl(biv_core_pkg.g_disp,'10') ;
   execute immediate l_sql_sttmnt using l_session_id, biv_core_pkg.g_disp;
   if (l_debug = 'Y') then
      biv_core_pkg.biv_debug(l_sql_sttmnt,biv_core_pkg.g_report_id);
   end if;

   l_param_name := biv_core_pkg.param_for_base_col;

   l_ttl_param_str1 := 'BIV_SERVICE_REQUEST_TASKS' ||
                       biv_core_pkg.g_param_sep ||
                       biv_core_pkg.reconstruct_param_str ||
                       'jtfBinId'||biv_core_pkg.g_value_sep ||
                       'BIV_SERVICE_REQUEST_TASKS' ||
                       biv_core_pkg.g_param_sep;

   l_ttl_param_str2 := 'BIV_OPEN_TASKS' || biv_core_pkg.g_param_sep ||
            biv_core_pkg.reconstruct_param_str ||
            'jtfBinId'||biv_core_pkg.g_value_sep || 'BIV_OPEN_TASKS' ||
            biv_core_pkg.g_param_sep;
   biv_core_pkg.reset_view_by_param;
   l_new_param_str1 := 'BIV_SERVICE_REQUEST_TASKS' || biv_core_pkg.g_param_sep ||
            biv_core_pkg.reconstruct_param_str ||
            'jtfBinId'||biv_core_pkg.g_value_sep ||'BIV_SERVICE_REQUEST_TASKS' ||
            biv_core_pkg.g_param_sep ||
            biv_core_pkg.param_for_base_col || biv_core_pkg.g_value_sep;

   l_new_param_str2 := 'BIV_OPEN_TASKS' || biv_core_pkg.g_param_sep ||
            biv_core_pkg.reconstruct_param_str ||
            'jtfBinId'||biv_core_pkg.g_value_sep || 'BIV_OPEN_TASKS' ||
            biv_core_pkg.g_param_sep ||
            biv_core_pkg.param_for_base_col || biv_core_pkg.g_value_sep;

   update biv_tmp_rt2
      set col5= l_new_param_str2||nvl(col1,biv_core_pkg.g_null)||
                biv_core_pkg.g_param_sep,
          col3= l_new_param_str1|| nvl(col1,biv_core_pkg.g_null) ||
                biv_core_pkg.g_param_sep || 'P_OTT' ||
                biv_core_pkg.g_value_sep || 'Y',
          creation_date = sysdate
     where report_code = 'BIV_RT_TASK_ACTIVITY'
       and session_id = l_session_id
     ;
   delete from biv_tmp_rt2
    where report_code = 'X';
   commit;
   ---
   --- Add a row fot toal of all column
   ---
   select count(*) into l_ttl_recs
     from biv_tmp_rt2
    where report_code = 'BIV_RT_TASK_ACTIVITY'
      and session_id = l_session_id;
   if ( l_ttl_recs > 1 and l_ttl_recs < biv_core_pkg.g_disp ) then
   if (l_debug = 'Y') then
      biv_core_pkg.biv_debug('Adding Total row',biv_core_pkg.g_report_id);
   end if;
      insert into biv_tmp_rt2 (report_code, rowno,
                               col4, col6, col13,session_id)
       select report_code, max(rowno) + 1, sum(col4), sum(col6),
               'Y', session_id
         from biv_tmp_rt2
        where session_id = l_session_id
         and report_code = 'BIV_RT_TASK_ACTIVITY'
        group by report_code, session_id;
   end if;

   if (biv_core_pkg.g_view_by = 'AGRP') then
       l_ttl_param_str1 := l_ttl_param_str1 || 'P_AGRP_LVL' ||
                      biv_core_pkg.g_value_sep || biv_core_pkg.g_lvl ||
                      biv_core_pkg.g_param_sep;
       l_ttl_param_str2 := l_ttl_param_str2 || 'P_AGRP_LVL' ||
                      biv_core_pkg.g_value_sep || biv_core_pkg.g_lvl ||
                      biv_core_pkg.g_param_sep;
   elsif (biv_core_pkg.g_view_by = 'OGRP') then
       l_ttl_param_str1 := l_ttl_param_str1 || 'P_OGRP_LVL' ||
                      biv_core_pkg.g_value_sep || biv_core_pkg.g_lvl ||
                      biv_core_pkg.g_param_sep;
       l_ttl_param_str2 := l_ttl_param_str2 || 'P_OGRP_LVL' ||
                      biv_core_pkg.g_value_sep || biv_core_pkg.g_lvl ||
                      biv_core_pkg.g_param_sep;
   end if;

   l_ttl_meaning := biv_core_pkg.get_lookup_meaning('TOTAL');
   update biv_tmp_rt2
      set col5= l_ttl_param_str2||
                biv_core_pkg.g_param_sep,
          col3= l_ttl_param_str1||
                biv_core_pkg.g_param_sep || 'P_OTT' ||
                biv_core_pkg.g_value_sep || 'Y',
          col2= l_ttl_meaning,
          creation_date = sysdate
     where report_code = 'BIV_RT_TASK_ACTIVITY'
       and session_id = l_session_id
       and col13 = 'Y';
   --
   --
   biv_core_pkg.g_report_id := 'NULL';
   exception
     when others then
        rollback;
        if (l_debug = 'Y') then
           biv_core_pkg.biv_debug(sqlerrm,biv_core_pkg.g_report_id);
        end if;
end;
------------------------------------------------------
procedure open_tasks(p_param_str varchar2) as
   l_cur  number;
   l_from_list      varchar2(1000);
   l_where_clause   varchar2(2000);
   l_sql_sttmnt     varchar2(5000);
   l_order_by       varchar2(80);
   l_new_param_str1 varchar2(2000);
   l_new_param_str2 varchar2(2000);
   l_param_name     varchar2(80);
   l_dummy number;
   l_session_id   biv_tmp_rt2.session_id % type;
   l_debug         varchar2(30) := fnd_profile.value('BIV:DEBUG');
begin
   l_session_id := biv_core_pkg.get_session_id;
   biv_core_pkg.clean_dcf_table('biv_tmp_rt2');

   biv_core_pkg.get_report_parameters(p_param_str);
   -- Change for Bug 3386946
   l_from_list := ' cs_incidents_b_sec     sr,
                         cs_incident_statuses_b stat,
                         jtf_tasks_b            task,
                         jtf_task_statuses_vl   tstat,
                         /*jtf_rs_resource_ext ns  rsc, */
                         jtf_rs_resource_extns  tsk_rsc ';
   biv_core_pkg.get_where_clause(l_from_list,l_where_clause);
   l_where_clause := l_where_clause ||
                      ' and sr.incident_status_id = stat.incident_status_id
                        and nvl(stat.close_flag,''N'') != ''Y''
                        --and sr.incident_owner_id = rsc.resource_id
                        and sr.incident_id = task.source_object_id
                        and task.source_object_type_code = ''SR''
                        and task.task_status_id = tstat.task_status_id
                        and task.owner_id = tsk_rsc.resource_id (+)
                        and nvl(tstat.closed_flag,''N'') != ''Y'''
                       ;
            --''X&SrCreate_SrID='' ||task.source_object_id,
  l_sql_sttmnt := '
     insert into biv_tmp_rt2 (report_code, col1, col2, col3, col6,
                                   col8, col10,
                                   col12, col14, col15,col16, col17,
                                   col19,session_id,creation_date)
     select ''BIV_OPEN_TASKS'', ''task' ||
            biv_core_pkg.g_param_sep || 'task_id' || biv_core_pkg.g_value_sep
            || ''' || task.task_id,
            task.task_number,
            task.owner_id, tstat.name, null,
            task.creation_date, task.last_update_date,
            task.escalation_level,
            ''X' || biv_core_pkg.g_param_sep ||'SR_ID'||
            biv_core_pkg.g_value_sep || ''' || task.source_object_id,
            sr.incident_number,
            sr.incident_owner_id,
            sr.inventory_item_id,
            :session_id,sysdate
      from ' || l_from_list || l_where_clause;

   if (l_debug = 'Y') then
      biv_core_pkg.biv_debug(l_sql_sttmnt,biv_core_pkg.g_report_id);
   end if;
   l_cur := dbms_sql.open_cursor;
   dbms_sql.parse(l_cur,l_sql_sttmnt,dbms_sql.native);
   biv_core_pkg.bind_all_variables(l_cur);
   dbms_sql.bind_variable(l_cur,':session_id',l_session_id);
   l_dummy := dbms_sql.execute(l_cur);
   biv_core_pkg.update_description('P_AGENT_ID','col3' ,'col4' , 'biv_tmp_rt2');
   biv_core_pkg.update_description('P_AGENT_ID','col17','col18', 'biv_tmp_rt2');
   biv_core_pkg.update_description('P_PRD_ID'  ,'col19','col20', 'biv_tmp_rt2');
   exception
     when others then
       rollback;
       if (l_debug = 'Y') then
          biv_core_pkg.biv_debug(sqlerrm,biv_core_pkg.g_report_id);
       end if;
end;
------------------------------------------------------
procedure service_requests(p_param_str varchar2) as
   l_cur  number;
   l_from_list    varchar2(1000);
   l_where_clause varchar2(2000);
   l_sql_sttmnt   varchar2(5000);
   l_order_by     varchar2(80);
   l_dummy number;
   l_session_id   biv_tmp_rt2.session_id % type;
   l_err          varchar2(1000);
   l_new_param_str varchar2(200);
   l_pos          varchar2(80);
   l_debug         varchar2(30) := fnd_profile.value('BIV:DEBUG');
begin
   biv_core_pkg.g_report_id := 'BIV_SERVICE_REQUEST';
   l_session_id := biv_core_pkg.get_session_id;
   biv_core_pkg.clean_dcf_table('biv_tmp_hs2');

   if (l_debug = 'Y') then
      biv_core_pkg.biv_debug('Parameters:'||p_param_str,
                                                    biv_core_pkg.g_report_id);
   end if;
   -- Change for Bug 3386946
   l_from_list := ' from cs_incidents_b_sec sr';
   biv_core_pkg.get_report_parameters(p_param_str);
   biv_core_pkg.get_where_clause(l_from_list, l_where_clause);
   if (l_debug = 'Y') then
      biv_core_pkg.biv_debug(l_from_list,biv_core_pkg.g_report_id);
      biv_core_pkg.biv_debug(l_where_clause,biv_core_pkg.g_report_id);
   end if;
   l_sql_sttmnt := '
    select sr.incident_id          col1,
           sr.incident_number      col2,
           sr.incident_owner_id    col3,
           sr.incident_type_id     col5,
           sr.customer_id          col7,
           decode(sr.customer_product_id,null,sr.inv_component_id,
                                              sr.cp_component_id) col9,
           sr.sr_creation_channel  col10,
           sr.inventory_item_id    col11,
           decode(sr.customer_product_id,null,sr.inv_subcomponent_id,
                                              sr.cp_subcomponent_id) col13,
           sr.product_revision     col14,
           sr.platform_id          col16,
           sr.incident_date        col17,
           sr.close_date           col18,
           trunc(sysdate) - trunc(sr.incident_date) col19,
           sr.last_update_date     col20,
           sr.incident_severity_id col22,
           sr.incident_status_id   col24
     ';
  l_sql_sttmnt := l_sql_sttmnt || l_from_list || l_where_clause;
  l_sql_sttmnt := '
    insert into biv_tmp_hs2(report_code,rowno,
                                 col1, col2, col3, col5,
                                 col7, col9, col10, col11, col13, col14,
                                 col16, col17, col18,
                                 col19, col20, col22, col24,session_id,
                                 creation_date)
     select ''BIV_SERVICE_REQUEST'', rownum,
            col1, col2, col3, col5,
                                 col7, col9, col10,  col11, col13,
                                 col14, col16, col17, col18,
                                 col19, col20, col22, col24,:session_id,sysdate
       from ( ' || l_sql_sttmnt || ' )';

   if (l_debug = 'Y') then
      biv_core_pkg.biv_debug(l_sql_sttmnt,biv_core_pkg.g_report_id);
   end if;
   l_cur := dbms_sql.open_cursor;
   dbms_sql.parse(l_cur,l_sql_sttmnt,dbms_sql.native);
   biv_core_pkg.bind_all_variables(l_cur);
   dbms_sql.bind_variable(l_cur,':session_id',l_session_id);
   l_dummy := dbms_sql.execute(l_cur);
   commit;

   l_pos := 'updating resource name';
   begin
   update biv_tmp_hs2 r
      set col4 = (select substr(source_name,1,50) from jtf_rs_resource_extns s
                   where s.resource_id = r.col3)
    where report_code = 'BIV_SERVICE_REQUEST'
      and session_id  = l_session_id;
   exception
     when others then
        if (l_debug = 'Y') then
           l_err := 'Err in biv_rt_task_blog_pkg.service_request at:' ||
                     l_pos || ':' ||
                     substr(sqlerrm,1,500);
           biv_core_pkg.biv_debug(l_err,'BIV_SERVICE_REQUEST');
        end if;
   end;
   l_pos := 'updating incident type';
   begin
   update biv_tmp_hs2 r
      set col6 = (select substr(name,1,50) from cs_incident_types_vl s
                   where s.incident_type_id = r.col5)
    where report_code = 'BIV_SERVICE_REQUEST'
      and session_id  = l_session_id;
   exception
     when others then
        if (l_debug = 'Y') then
           l_err := 'Err in biv_rt_task_blog_pkg.service_request at:' ||
                     l_pos || ':' ||
                     substr(sqlerrm,1,500);
           biv_core_pkg.biv_debug(l_err,'BIV_SERVICE_REQUEST');
        end if;
   end;
   l_pos := 'updating party name';
   begin
   update biv_tmp_hs2 r
      set col8 = (select substr(party_name,1,50) from hz_parties p
                   where p.party_id = r.col7)
    where report_code = 'BIV_SERVICE_REQUEST'
      and session_id  = l_session_id;
   exception
     when others then
        if (l_debug = 'Y') then
           l_err := 'Err in biv_rt_task_blog_pkg.service_request at:' ||
                     l_pos || ':' ||
                     substr(sqlerrm,1,500);
           biv_core_pkg.biv_debug(l_err,'BIV_SERVICE_REQUEST');
           commit;
        end if;
   end;
   /***** channel is being taken from cs_incidents_all_b itself 4/30/02
   l_pos := 'updating SR channel';
   begin
   update biv_tmp_hs2 r
      set col10= (select sr_creation_channel
                    from cs_incidents_all_tl inc
                   where inc.incident_id = r.col1
                     and inc.language = userenv('LANG'))
    where report_code = 'BIV_SERVICE_REQUEST'
      and session_id  = l_session_id;
   exception
     when others then
        l_err := 'Err in biv_rt_task_blog_pkg.service_request at:' ||
                  l_pos || ':' ||
                  substr(sqlerrm,1,500);
        biv_core_pkg.biv_debug(l_err,'BIV_SERVICE_REQUEST');
        commit;
   end;
   ******/
   l_pos := 'updating product';
   begin
   update biv_tmp_hs2 r
      set col12= (select substr(description,1,50) from mtl_system_items_vl i
                   where i.organization_id   = biv_core_pkg.g_prd_org
                     and i.inventory_item_id = r.col11)
    where report_code = 'BIV_SERVICE_REQUEST'
      and session_id  = l_session_id;
   exception
     when others then
        if (l_debug = 'Y') then
           l_err := 'Err in biv_rt_task_blog_pkg.service_request at:' ||
                     l_pos || ':' ||
                     substr(sqlerrm,1,500);
           biv_core_pkg.biv_debug(l_err,'BIV_SERVICE_REQUEST');
           commit;
        end if;
   end;
   --
   l_pos := 'updating componet name';
   begin
   update biv_tmp_hs2 r
      set col9 = (select substr(description,1,50) from mtl_system_items_vl i
                   where i.organization_id   = biv_core_pkg.g_prd_org
                     and i.inventory_item_id = r.col9)
    where report_code = 'BIV_SERVICE_REQUEST'
      and session_id  = l_session_id;
   exception
     when others then
        if (l_debug = 'Y') then
           l_err := 'Err in biv_rt_task_blog_pkg.service_request at:' ||
                     l_pos || ':' ||
                     substr(sqlerrm,1,500);
           biv_core_pkg.biv_debug(l_err,'BIV_SERVICE_REQUEST');
           commit;
        end if;
   end;
   --
   l_pos := 'updating subcomponent name';
   begin
   update biv_tmp_hs2 r
      set col13= (select substr(description,1,50) from mtl_system_items_vl i
                   where i.organization_id   = biv_core_pkg.g_prd_org
                     and i.inventory_item_id = r.col13)
    where report_code = 'BIV_SERVICE_REQUEST'
      and session_id  = l_session_id;
   exception
     when others then
        if (l_debug = 'Y') then
           l_err := 'Err in biv_rt_task_blog_pkg.service_request at:' ||
                     l_pos || ':' ||
                     substr(sqlerrm,1,500);
           biv_core_pkg.biv_debug(l_err,'BIV_SERVICE_REQUEST');
           commit;
        end if;
   end;
   --
   l_pos := 'updating severity';
   begin
   update biv_tmp_hs2 r
      set col23= (select substr(name,1,50) from cs_incident_severities_vl s
                   where s.incident_severity_id = r.col22)
    where report_code = 'BIV_SERVICE_REQUEST'
      and session_id  = l_session_id;
   exception
     when others then
        if (l_debug = 'Y') then
           l_err := 'Err in biv_rt_task_blog_pkg.service_request at:' ||
                     l_pos || ':' ||
                     substr(sqlerrm,1,500);
           biv_core_pkg.biv_debug(l_err,'BIV_SERVICE_REQUEST');
           commit;
        end if;
   end;
   l_pos := 'updating status';
   begin
   update biv_tmp_hs2 r
      set col25= (select substr(name,1,50) from cs_incident_statuses_vl s
                   where s.incident_status_id = r.col24)
    where report_code = 'BIV_SERVICE_REQUEST'
      and session_id  = l_session_id;
   exception
     when others then
        if (l_debug = 'Y') then
           l_err := 'Err in biv_rt_task_blog_pkg.service_request at:' ||
                     l_pos || ':' ||
                     substr(sqlerrm,1,500);
           biv_core_pkg.biv_debug(l_err,'BIV_SERVICE_REQUEST');
           commit;
        end if;
   end;
   l_pos := 'updating escalation level';
   begin
   update biv_tmp_hs2 r
      set col21= (select task.escalation_level
                    from jtf_tasks_b task,
                         jtf_task_references_b ref
                   where ref.object_type_code = 'SR'
                     and ref.object_id = r.col1
                     and ref.reference_code = 'ESC'
                     and ref.task_id = task.task_id
                     and task_type_id = 22)
    where report_code = 'BIV_SERVICE_REQUEST'
      and session_id  = l_session_id;
   exception
     when others then
        if (l_debug = 'Y') then
           l_err := 'Err in biv_rt_task_blog_pkg.service_request at:' ||
                     l_pos || ':' ||
                     substr(sqlerrm,1,500);
           biv_core_pkg.biv_debug(l_err,'BIV_SERVICE_REQUEST');
           commit;
        end if;
   end;
  -- here col15 is set to col1 so that in case of service_request_task report
  -- this will be used to update no of tasks for SR
   l_pos := 'updating col15, col1 for Drill down';
   begin
   l_new_param_str := biv_core_pkg.g_param_sep ||
            biv_core_pkg.reconstruct_param_str ||
            'jtfBinId'||biv_core_pkg.g_value_sep || 'BIV_SERVICE_REQUEST';
   update biv_tmp_hs2
     set col15 = col1,
          col1 = 'BIV_SERVICE_REQUEST' || biv_core_pkg.g_param_sep ||
                 'SR_ID=' || col1 || l_new_param_str
                 --'SrCreate_SrID=' || col1 || l_new_param_str
    where col1 is not null
      and report_code = 'BIV_SERVICE_REQUEST'
      and session_id  = l_session_id;
   exception
     when others then
        if (l_debug = 'Y') then
           l_err := 'Err in biv_rt_task_blog_pkg.service_request at:' ||
                     l_pos || ':' ||
                     substr(sqlerrm,1,500);
           biv_core_pkg.biv_debug(l_err,'BIV_SERVICE_REQUEST');
           commit;
        end if;
   end;
   if (l_debug = 'Y') then
      biv_core_pkg.biv_debug('End of report',biv_core_pkg.g_report_id);
   end if;
   biv_core_pkg.g_report_id := 'NULL';

   exception
     when others then
        if (l_debug = 'Y') then
           l_err := 'Err in biv_rt_task_blog_pkg.service_request at:' ||
                     l_pos || ':' ||
                     substr(sqlerrm,1,500);
           biv_core_pkg.biv_debug(l_err,'BIV_SERVICE_REQUEST');
        end if;
end;
function status_descr(p_sts_id varchar2) return varchar2 is
   l_name varchar2(50);
   l_bklg_meaning fnd_lookups.meaning%type;
begin
   l_bklg_meaning := biv_core_pkg.get_lookup_meaning('BACKLOG');
   select name into l_name
     from cs_incident_statuses_vl
    where incident_status_id = to_number(p_sts_id);
   return(l_name || ' ' || l_bklg_meaning);

   exception
     when others then
       return('invalid Status Id');
end;
function status_descr1(p_param_str varchar2) return varchar2 is
begin
  return(status_descr(fnd_profile.value('BIV:INC_STATUS_1')));
end;
function status_descr2(p_param_str varchar2) return varchar2 is
begin
  return(status_descr(fnd_profile.value('BIV:INC_STATUS_2')));
end;
function status_descr3(p_param_str varchar2) return varchar2 is
begin
  return(status_descr(fnd_profile.value('BIV:INC_STATUS_3')));
end;
procedure service_requests_task(p_param_str varchar2) is
   l_debug         varchar2(30) := fnd_profile.value('BIV:DEBUG');
begin
   service_requests(p_param_str);
   update biv_tmp_hs2 rep
      set col26 = (select count(*)
                     from jtf_tasks_b tsk,
                          jtf_task_statuses_b tstat
                    where source_object_type_code = 'SR'
                      and source_object_id        = to_number(rep.col15)
                      and tsk.task_status_id      = tstat.task_status_id
                      and nvl(tstat.closed_flag,'N') <> 'Y'
                  )
     where report_code = 'BIV_SERVICE_REQUEST'
       and session_id  = biv_core_pkg.get_session_id;

   exception
     when others then
       biv_core_pkg.biv_debug(sqlerrm,biv_core_pkg.g_report_id);
end;
end;

/
