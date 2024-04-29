--------------------------------------------------------
--  DDL for Package Body BIV_HS_ESC_ACTVTY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIV_HS_ESC_ACTVTY_PKG" as
/* $Header: bivhactb.pls 115.23 2004/01/23 04:54:52 vganeshk ship $ */
-------------------------------------------
procedure sr_escalation(p_param_str varchar2) as
   l_cur  number;
   l_from_list    varchar2(1000);
   l_where_clause varchar2(2000);
   l_sql_sttmnt   varchar2(5000);
   l_dummy number;
   l_start_date date;
   l_end_date   date;
   l_time_frame varchar2(80);
   l_order_by   varchar2(60);
   l_desc_asc   varchar2(20);
   l_param_col  varchar2(20);
   l_new_param_str varchar2(2000);
   l_new_param_str1 varchar2(2000);
   l_gt_param_str   varchar2(2000);
   l_bt_param_str   varchar2(2000);
   l_session_id     biv_tmp_hs2.session_id % type;
   l_err            varchar2(1000);
   l_loc            varchar2( 100);
   l_debug         varchar2(30) := fnd_profile.value('BIV:DEBUG');
begin
   biv_core_pkg.g_report_id := 'BIV_HS_SR_ESCALATION';
   l_session_id := biv_core_pkg.get_session_id;
   biv_core_pkg.clean_dcf_table('biv_tmp_hs2');
   biv_core_pkg.g_srl_no := 1;
   biv_core_pkg.get_report_parameters(p_param_str);
   if (l_debug = 'Y') then
      biv_core_pkg.biv_debug('Param :'||p_param_str,'BIV_HS_SR_ESCALATION');
   end if;

   -- Change for Bug 3386946
   l_from_list := ' from cs_incidents_b_sec sr, biv_sr_summary srs /*,
                         cs_incident_statuses_b stat*/ ';

   biv_core_pkg.get_where_clause(l_from_list,l_where_clause);

   if (biv_core_pkg.g_srt_by = '1') then
      l_order_by := 'col2 ';
      l_desc_asc := ' asc ';
      l_param_col := ' col1';
   elsif (biv_core_pkg.g_srt_by = '2') then
      l_order_by := 'col4 ';
      l_desc_asc := ' desc ';
      l_param_col := ' col4';
   elsif (biv_core_pkg.g_srt_by = '3') then
      l_order_by := 'col6 ';
      l_desc_asc := ' desc ';
      l_param_col := ' col4';
   end if;

   l_where_clause := l_where_clause || '
                         and sr.incident_id = srs.incident_id
                         --and sr.incident_status_id = stat.incident_status_id
                         --and nvl(stat.close_flag,''N'') <> ''Y''
                         and srs.escalation_level is not null';
   l_sql_sttmnt := '
        select ' || biv_core_pkg.g_base_column || ' col1,
               srs.escalation_level col4,
               count(distinct sr.incident_id) col6
          ' || l_from_list || '
          ' || l_where_clause || '
          group by ' || biv_core_pkg.g_base_column || ',srs.escalation_level
         ' ;

   l_sql_sttmnt := 'insert into biv_tmp_hs2(report_code, rowno,
      col1,col4,col6,session_id)
      select ''SR_ESC'', rownum, col1, col4, col6, :session_id from (
      ' || l_sql_sttmnt || ')
      ';

   if (l_debug = 'Y') then
      biv_core_pkg.biv_debug(l_sql_sttmnt,'BIV_HS_SR_ESCALATION');
      commit;
   end if;
   l_cur := dbms_sql.open_cursor;
   dbms_sql.parse(l_cur,l_sql_sttmnt,dbms_sql.native);
   biv_core_pkg.bind_all_variables(l_cur);
   dbms_sql.bind_variable(l_cur,':session_id', l_session_id);
   l_loc := 'Before Second Execute';
   l_dummy := dbms_sql.execute(l_cur);

   biv_core_pkg.update_base_col_desc('biv_tmp_hs2');
   -- Here rownum*2 is select so that there are gaps and in those gaps
   -- we could fit total for groups
   l_sql_sttmnt := 'insert into biv_tmp_hs2(report_code, rowno,
      col1,col2, col4,col6,session_id)
      select ''BIV_HS_SR_ESCALATION'', rownum * 2, col1, col2, col4,
             col6 ,session_id
       from (
          select col1, col2, col4, col6,session_id
            from biv_tmp_hs2
           where report_code = ''SR_ESC''
             and session_id = :session_id
           order by ' || l_order_by || ' ,nvl(col2,'' ''))
        where rownum <= :rows_to_display '; -- || biv_core_pkg.g_disp ;
   l_loc := 'Before third execute';
   if (l_debug = 'Y') then
      biv_core_pkg.biv_debug(l_sql_sttmnt,biv_core_pkg.g_report_id);
   end if;
   execute immediate l_sql_sttmnt using l_session_id, biv_core_pkg.g_disp;
--, to_number(biv_core_pkg.g_disp);

   l_gt_param_str   := 'BIV_HS_ESCALATION_VIEW' ||biv_core_pkg.g_param_sep ||
                       biv_core_pkg.reconstruct_param_str || 'jtfBinId' ||
                      biv_core_pkg.g_value_sep || 'BIV_HS_ESCALATION_VIEW' --||
                     -- biv_core_pkg.g_param_sep || 'P_BLOG' ||
                     -- biv_core_pkg.g_value_sep || 'Y'
                     ;
   biv_core_pkg.reset_view_by_param;
   l_new_param_str := 'BIV_SERVICE_REQUEST' ||biv_core_pkg.g_param_sep ||
                       biv_core_pkg.reconstruct_param_str;
   -- was used for col3 value. This URL is disbaled for time being 4/27/02
   l_new_param_str := l_new_param_str || 'jtfBinId' ||
                      biv_core_pkg.g_value_sep || 'BIV_SERVICE_REQUEST' ||
                      biv_core_pkg.g_param_sep ||
                      biv_core_pkg.param_for_base_col ||
                      biv_core_pkg.g_value_sep ;

   l_new_param_str1 := 'BIV_HS_ESCALATION_VIEW' ||biv_core_pkg.g_param_sep ||
                       biv_core_pkg.reconstruct_param_str;
   l_new_param_str1 := l_new_param_str1 || 'jtfBinId' ||
                      biv_core_pkg.g_value_sep || 'BIV_HS_ESCALATION_VIEW' ||
                     -- biv_core_pkg.g_param_sep || 'P_BLOG' ||
                    --  biv_core_pkg.g_value_sep || 'Y' ||
                      biv_core_pkg.g_param_sep ||
                      biv_core_pkg.param_for_base_col ||
                      biv_core_pkg.g_value_sep ;

   delete from biv_tmp_hs2
    where report_code = 'SR_ESCaa'
      and session_id = l_session_id;
   l_loc := 'Before update of odd col';
   update biv_tmp_hs2
     set /*col5 = l_new_param_str || col1 || biv_core_pkg.g_param_sep ||
                'P_ESC_LVL' || biv_core_pkg.g_value_sep || col4,*/
         -- this was column col3
         col5 = l_new_param_str1 || nvl(col1,biv_core_pkg.g_null) ||
                biv_core_pkg.g_param_sep ||
                'P_ESC_LVL' || biv_core_pkg.g_value_sep || col4,
         creation_date = sysdate
    where session_id = l_session_id
      and report_code = 'BIV_HS_SR_ESCALATION' ;

   --
   --
   -- this will insert total for the group
   --
   --
   if (l_order_by <> 'col6 ') then
   l_new_param_str1 := 'BIV_HS_ESCALATION_VIEW' ||biv_core_pkg.g_param_sep ||
                       biv_core_pkg.reconstruct_param_str --||
                      --  'P_BLOG' || biv_core_pkg.g_value_sep || 'Y' ||
                      --biv_core_pkg.g_param_sep
                      ;
   l_new_param_str1 := l_new_param_str1 || 'jtfBinId' ||
                      biv_core_pkg.g_value_sep || 'BIV_HS_ESCALATION_VIEW' ||
                      biv_core_pkg.g_param_sep ;
   if (l_order_by = 'col2 ') then
      l_new_param_str1 := l_new_param_str1 ||
                      biv_core_pkg.param_for_base_col ;
   else
      l_new_param_str1 := l_new_param_str1 ||
                          'P_ESC_LVL';
   end if;
   l_new_param_str1 := l_new_param_str1 || biv_core_pkg.g_value_sep ;
   l_sql_sttmnt := '
   insert into biv_tmp_hs2 (report_code, rowno, col4, col6,session_id,col5,col9,
                            creation_date)
     select ''BIV_HS_SR_ESCALATION'', max(rowno)+1,
            ''Total '' || nvl(' || l_order_by ||','' ''), sum(col6), :session_id,
            :l_new_param_str1 || nvl('||l_param_col ||',''' ||
            biv_core_pkg.g_null ||'''),''Total'', sysdate
       from biv_tmp_hs2
      where report_code = ''BIV_HS_SR_ESCALATION''
        and session_id = :session_id
      group by nvl(' ||l_order_by ||','' '')' ||
               ', nvl('|| l_param_col || ','''||biv_core_pkg.g_null ||
                  ''')'
       ;
   if (l_debug = 'Y') then
      biv_core_pkg.biv_debug(l_sql_sttmnt,biv_core_pkg.g_report_id);
   end if;
   execute immediate l_sql_sttmnt using l_session_id,l_new_param_str1,
                                        l_session_id;
   end if;

   -- this will insert grand total
   insert into biv_tmp_hs2 (report_code, rowno, col4, col6,session_id,col5,
                            creation_date)
     select 'BIV_HS_SR_ESCALATION', max(rowno)+1,
            'Grand Total ', sum(col6), l_session_id,
            l_gt_param_str, sysdate
       from biv_tmp_hs2
      where report_code = 'BIV_HS_SR_ESCALATION'
        and session_id = l_session_id
        and (l_order_by = 'col6 ' or col9 = 'Total')
        --and col1 is not null
       ;
   if (l_debug = 'Y') then
      biv_core_pkg.biv_debug('End of Report', biv_core_pkg.g_report_id);
   end if;
   biv_core_pkg.g_report_id := 'NULL';
   commit;
   exception
      when others then
       if (l_debug = 'Y') then
          l_err := 'Err at ' || l_loc|| ':'|| substr(sqlerrm,1,500);
          biv_core_pkg.biv_debug(l_err,'BIV_HS_SR_ESCALATION');
       end if;
end;
-------------------------------------------------
procedure escalation_view(p_param_str varchar2) as
   l_cur  number;
   l_from_list    varchar2(1000);
   l_where_clause varchar2(2000);
   l_sql_sttmnt   varchar2(5000);
   l_dummy number;
   l_start_date date;
   l_end_date   date;
   l_time_frame varchar2(80);
   l_session_id biv_tmp_hs2.session_id % type;
   l_debug         varchar2(30) := fnd_profile.value('BIV:DEBUG');
begin
   biv_core_pkg.g_report_id := 'BIV_HS_ESCALATION_VIEW';
   l_session_id := biv_core_pkg.get_session_id;
   biv_core_pkg.clean_dcf_table('biv_tmp_hs2');
   biv_core_pkg.g_srl_no := 1;
   if (l_debug = 'Y') then
      biv_core_pkg.biv_debug('Param Passed to Proc:'||p_param_str,
                             'BIV_HS_ESCALATION_VIEW');
   end if;

   biv_core_pkg.get_report_parameters(p_param_str);

   -- Change for Bug 3386946
   l_from_list := ' from cs_incidents_b_sec sr,
                         biv_sr_summary srs';

   biv_core_pkg.get_where_clause(l_from_list,l_where_clause);
   l_where_clause := l_where_clause || '
                          and sr.incident_id = srs.incident_id
                          and srs.escalation_level is not null';
   l_sql_sttmnt := '
     select sr.customer_id col1, srs.escalation_level col4,
            sr.incident_id col5,
            sr.incident_number col6, sr.incident_owner_id col7,
            srs.esc_owner_id col9, sr.inventory_item_id col11,
            null col14, sr.platform_id col16' || l_from_list ||
            l_where_clause ; --|| '
            --group by ' || biv_core_pkg.g_base_column;


   l_sql_sttmnt := '
      insert into biv_tmp_hs2 (report_code,
                  col1,col4, col5, col6, col7, col9, col11, col14, col16,
                  session_id)
          select ''TEMP'', col1,col4,col5,col6, col7, col9, col11,
                 col14, col16, :x_session_id
           from (' || l_sql_sttmnt || ')'
         ;

   if (l_debug = 'Y') then
      biv_core_pkg.biv_debug(l_sql_sttmnt,'BIV_HS_ESCALATION_VIEW');
      commit;
   end if;
   l_cur := dbms_sql.open_cursor;
   dbms_sql.parse(l_cur,l_sql_sttmnt,dbms_sql.native);
   biv_core_pkg.bind_all_variables(l_cur);
   dbms_sql.bind_variable(l_cur,':x_session_id', l_session_id);
   l_dummy := dbms_sql.execute(l_cur);

   --biv_core_pkg.update_base_col_desc('biv_tmp_hs2');
   biv_core_pkg.update_description('P_AGENT_ID','col7' ,'col8' ,'biv_tmp_hs2');
   biv_core_pkg.update_description('P_AGENT_ID','col9' ,'col10','biv_tmp_hs2');
   biv_core_pkg.update_description('P_PRD_ID'  ,'col11','col12','biv_tmp_hs2');
   biv_core_pkg.update_description('P_CUST_ID' ,'col1' ,'col2' ,'biv_tmp_hs2');
   insert into biv_tmp_hs2 (report_code, rowno,
                col1, col2, col4, col5, col6, col7, col8, col9, col10,
                col11, col12, col14, col16,session_id)
    select * from (
    select 'BIV_HS_ESCALATION_VIEW' report_code, rownum rowno,
                col1, col2, col4, col5, col6, col7, col8, col9, col10,
                col11, col12, col14, col16,session_id
      from biv_tmp_hs2
     where report_code = 'TEMP'
       and session_id  = l_session_id
     order by col2)
     ;
   delete from biv_tmp_hs2 where report_code = 'TEMP'
     and session_id = l_session_id;

   update biv_tmp_hs2
      set col5 = 'X' || biv_core_pkg.g_param_sep || 'SR_ID=' || col5,
      --set col5 = 'X' || biv_core_pkg.g_param_sep || 'SrCreate_SrID=' || col5,
          creation_date = sysdate
    where report_code = 'BIV_HS_ESCALATION_VIEW'
      and session_id = l_session_id;

   if (l_debug = 'Y') then
      biv_core_pkg.biv_debug('End of Report', 'BIV_HS_ESCALATION_VIEW');
   end if;
   biv_core_pkg.g_report_id := 'NULL';
   exception
     when others then
       if (l_debug = 'Y') then
          biv_core_pkg.biv_debug(sqlerrm,biv_core_pkg.g_report_id);
       end if;
end;
procedure sr_activity(p_param_str varchar2) as
   l_cur  number;
   l_from_list    varchar2(1000);
   l_where_clause varchar2(2000);
   l_sql_sttmnt   varchar2(5000);
   l_dummy number;
   l_start_date date;
   l_end_date   date;
   l_time_frame varchar2(80);
   l_order_by   varchar2(60);
   l_session_id biv_tmp_hs2.session_id % type;
   l_err        varchar2(1000);
   l_new_param_str varchar2(2000);
   l_new_param_str1 varchar2(2000);
   l_new_view_by   varchar2(30);
   l_loc           varchar2(100);
   l_dt_fmt        varchar2(20);
   l_drilldown_rep varchar2(30);
   l_ttl_recs      number;
   l_ttl_meaning   fnd_lookups.meaning%type :=
                                     biv_core_pkg.get_lookup_meaning('TOTAL');
   l_debug         varchar2(30) := fnd_profile.value('BIV:DEBUG');
begin
   l_dt_fmt := FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK');
   biv_core_pkg.g_report_id := 'BIV_HS_SR_ACTIVITY';
   l_session_id := biv_core_pkg.get_session_id;
   biv_core_pkg.clean_dcf_table('biv_tmp_hs2');
   biv_core_pkg.g_srl_no := 1;
   if (l_debug = 'Y') then
     biv_core_pkg.biv_debug('Prameters Are:'||p_param_str,'BIV_HS_SR_ACTIVITY');
   end if;
   biv_core_pkg.get_report_parameters(p_param_str);

   l_time_frame := biv_core_pkg.g_time_frame;
   l_start_date := nvl(biv_core_pkg.g_st_date,trunc(sysdate)-30);
   l_end_date   := trunc(nvl(biv_core_pkg.g_end_date,sysdate))+1;
   -------------------------
   if (l_debug = 'Y') then
      biv_core_pkg.biv_debug('Start Date:'||
                     to_char(l_start_date,'dd-mon-yyyy hh24:mi:ss'),
                     biv_core_pkg.g_report_id);
      biv_core_pkg.biv_debug('End   Date:'||
                     to_char(l_end_date,'dd-mon-yyyy hh24:mi:ss'),
                     biv_core_pkg.g_report_id);
   end if;
   -------------------------
   biv_core_pkg.g_time_frame := null;
   biv_core_pkg.g_st_date := null;
   biv_core_pkg.g_end_date   := null;

   -- Change for Bug 3386946
   l_from_list := ' from cs_incidents_vl_sec sr,
                         biv_sr_summary srs,
                         cs_incident_statuses_b stat
                         ';

   biv_core_pkg.get_where_clause(l_from_list,l_where_clause);
   l_where_clause := l_where_clause || '
                       and sr.incident_id = srs.incident_id
                       and sr.incident_status_id = stat.incident_status_id
                       and (sr.close_date is null or
                            nvl(stat.close_flag,''N'') <> ''Y'' or
                            --sr.close_date    between :y_start_date8
                            --                     and :y_end_date8   or
                            sr.close_date >= :y_start_date8 or --Change for Bug 3188504
                            srs.reclose_date between :y_start_date9
                                                 and :y_end_date9   or
                            srs.reopen_date  between :y_start_date10
                                                 and :y_end_date10  or
                            sr.incident_date between :y_start_date11
                                                 and :y_end_date11)
                        ';

/*
            sum(decode(sign(sr.incident_date-:y_end_date5),
                      -1,decode(sign(nvl(sr.close_date,sysdate+1000)-
                                         :y_end_date6),-1,0,1)
               )) col14, --ending_blog
*/
           /* 5/8/02 new def of open blog
           this will not work because SR may have been close in the input
            period. so at the beginning of period, it was a backlog
            sum(decode(sign(sr.incident_date-:y_start_date1),
                      -1,decode(nvl(stat.close_flag,''N''),''Y'',0,1)
                      )) col4, --open_blog
           */
   l_sql_sttmnt := '
     select ' || biv_core_pkg.g_base_column ||' col1,
            sum(decode(sign(sr.incident_date-:y_start_date1),
                      -1,decode(nvl(close_flag,''N''),''N'',1,
                            decode(sign(nvl(sr.close_date,sysdate-1000)-
                                         :y_start_date2),-1,0,1)
                               ),
                       0)) col4, --open_blog
            sum(decode(sign(sr.incident_date-:y_start_date3),
                       -1,0,decode(sign(sr.incident_date-:y_end_date1),-1,1,0))
               ) col6, --new_sr
            sum(decode(sign(nvl(sr.close_date,sysdate+1000)-:y_start_date4),
                       -1,0,decode(sign(nvl(sr.close_date,sysdate+1000)-
                                         :y_end_date2),-1,1,0))
               ) col8, --closed_sr
            sum(decode(sign(srs.reopen_date-:y_start_date5),
                      -1,0,decode(sign(srs.reopen_date-:y_end_date3),-1,1,0))
               ) col10, --reopened_sr
            sum(decode(sign(srs.reclose_date-:y_start_date6),
                      -1,0,decode(sign(srs.reclose_date-:y_end_date4),-1,1,0))
               ) col12, --reclosed_sr
            /* 5/9/2 this is causing problem with null close_date
            sum(decode(sign(sr.incident_date-:y_end_date5),
                      -1,decode(nvl(stat.close_flag,''N''), ''Y'',0,1)
                      )) col14,
            */
            sum(decode(sign(sr.incident_date-:y_end_date5),
                      -1,decode(nvl(close_flag,''N''),''N'',1,
                           decode(sign(nvl(sr.close_date,sysdate-1000)-
                                         :y_end_date6)-1,0,1)
                               ),
                     0)
               ) col14,
            avg(srs.days_to_close) col16, --time_to_close
            sum(decode(sign(sr.incident_date-:y_start_date7),
                       -1,0,decode(sign(sr.incident_date-:y_end_date7),1,0,
                               decode(sr.sr_creation_channel,''WEB'',1,0))
                      )
               ) col18, --new_web_sr
            0 col20, --updated_via_web
            avg(decode(sr.sr_creation_channel,''WEB'',srs.response_time,null)) col22, --resp_time'; --Bug 2960243
     if ( nvl(biv_core_pkg.g_view_by,'AGENT') = 'AGENT' or
          nvl(biv_core_pkg.g_view_by,'AGENT') = 'PRD' ) then
        l_sql_sttmnt := l_sql_sttmnt || '
                          to_char(avg(decode(nvl(stat.close_flag,''N''), ''Y'', null,
                                         sysdate -  sr.incident_date
                                    )
                             ),''999,999.00'') col24
                  ';
     else
        l_sql_sttmnt := l_sql_sttmnt || '
                         count(distinct sr.incident_owner_id) col24
                  ';
     end if;

/************************
                decode(closed_sr,0,0,
                           to_char(closed_sr/no_of_agents,''999,999.00''))
***************/
   if (biv_core_pkg.g_srt_by = '1') then
      l_order_by := 'col2 asc';
   else
      l_order_by := 'to_number(col' || to_number(biv_core_pkg.g_srt_by)*2 ||
                      ') desc ';
   end if;
   l_sql_sttmnt := '
       insert into biv_tmp_hs2(report_code,rowno,
                                    col1,col4,col6,col8,col10,col12,
                                    col14, col16,col18,col20, col22, col24,
                                    session_id)
         select ''SR_ACT'', rownum, col1,
                col4, col6, col8,
                col10, col12, col14,
                to_char(col16,''999,999.99''),
                col18, col20,
                to_char(col22*24,''999,999,999.00''),
                col24, :session_id
           from (' || l_sql_sttmnt || l_from_list || l_where_clause ||
           ' group by ' || biv_core_pkg.g_base_column || ')'
             /*order by ' || l_order_by || ')
          where rownum <= ' || biv_core_pkg.g_disp */ ;
   if (l_debug = 'Y') then
      biv_core_pkg.biv_debug(l_sql_sttmnt,'BIV_HS_SR_ACTIVITY');
      commit;
   end if;
   l_cur := dbms_sql.open_cursor;
   dbms_sql.parse(l_cur,l_sql_sttmnt,dbms_sql.native);
   biv_core_pkg.bind_all_variables(l_cur);
   l_loc := 'Before bind variables';
   dbms_sql.bind_variable(l_cur,':y_start_date1' , l_start_date);
   dbms_sql.bind_variable(l_cur,':y_start_date2' , l_start_date);
   dbms_sql.bind_variable(l_cur,':y_start_date3' , l_start_date);
   dbms_sql.bind_variable(l_cur,':y_start_date4' , l_start_date);
   dbms_sql.bind_variable(l_cur,':y_start_date5' , l_start_date);
   dbms_sql.bind_variable(l_cur,':y_start_date6' , l_start_date);
   dbms_sql.bind_variable(l_cur,':y_start_date7' , l_start_date);
   dbms_sql.bind_variable(l_cur,':y_start_date8' , l_start_date);
   dbms_sql.bind_variable(l_cur,':y_start_date9' , l_start_date);
   dbms_sql.bind_variable(l_cur,':y_start_date10', l_start_date);
   dbms_sql.bind_variable(l_cur,':y_start_date11', l_start_date);
   dbms_sql.bind_variable(l_cur,':y_end_date1'   , l_end_date  );
   dbms_sql.bind_variable(l_cur,':y_end_date2'   , l_end_date  );
   dbms_sql.bind_variable(l_cur,':y_end_date3'   , l_end_date  );
   dbms_sql.bind_variable(l_cur,':y_end_date4'   , l_end_date  );
   dbms_sql.bind_variable(l_cur,':y_end_date5'   , l_end_date  );
   dbms_sql.bind_variable(l_cur,':y_end_date6'   , l_end_date  );
   dbms_sql.bind_variable(l_cur,':y_end_date7'   , l_end_date  );
--   dbms_sql.bind_variable(l_cur,':y_end_date8'   , l_end_date  );
   dbms_sql.bind_variable(l_cur,':y_end_date9'   , l_end_date  );
   dbms_sql.bind_variable(l_cur,':y_end_date10'  , l_end_date  );
   dbms_sql.bind_variable(l_cur,':y_end_date11'  , l_end_date  );
   dbms_sql.bind_variable(l_cur,':session_id'    , l_session_id);
   l_loc := 'Before first Execute';
   l_dummy := dbms_sql.execute(l_cur);
   l_loc := 'After first Execute';
   biv_core_pkg.update_base_col_desc('biv_tmp_hs2');
   l_sql_sttmnt := '
       insert into biv_tmp_hs2(report_code,rowno,
                                    col1,col2,col4,col6,col8,col10,col12,
                                    col14, col16,col18,col20, col22, col24,
                                    session_id)
         select ''BIV_HS_SR_ACTIVITY'', rownum, col1,
                col2,col4, col6, col8,
                col10, col12, col14,
                col16, col18, col20, col22, col24,session_id
         from ( select col1,col2, col4, col6, col8, col10, col12,
                       col14, col16, col18, col20, col22, col24, session_id
                 from biv_tmp_hs2
                where report_code = ''SR_ACT''
                  and session_id  = :session_id
                order by ' || l_order_by || ')' ;
    if (biv_core_pkg.g_view_by <> 'AGENT' and
        biv_core_pkg.g_view_by <> 'PRD') then
        l_sql_sttmnt := l_sql_sttmnt || '
             where rownum <= :rows_to_display '; -- || biv_core_pkg.g_disp;
        execute immediate l_sql_sttmnt using l_session_id, biv_core_pkg.g_disp ;
    else
        execute immediate l_sql_sttmnt using l_session_id ;
    end if;
   l_loc := 'After second Execute, execute immediate';

   if (biv_core_pkg.g_view_by = 'AGENT') then
      l_new_view_by := 'PRD';
      -- because agent id is available, so no need for any mgr_id if present.
      -- 1/7/03biv_core_pkg.g_mgr_id_cnt := 0;
      -- will be needed for total row.
      l_drilldown_rep := 'BIV_HS_SR_ACTIVITY_PRD';
   else
      l_drilldown_rep := 'BIV_HS_SR_ACTIVITY';
      l_new_view_by := 'AGENT';
   end if;
   l_new_param_str := 'BIV_SERVICE_REQUEST' ||biv_core_pkg.g_param_sep ||
                       biv_core_pkg.reconstruct_param_str;
   l_new_param_str1:= l_drilldown_rep ||biv_core_pkg.g_param_sep ||
                       biv_core_pkg.reconstruct_param_str;
   --Change for bug 3188504 appended P_PREVR parameter to the urls
   l_new_param_str := l_new_param_str || 'jtfBinId' ||
                      biv_core_pkg.g_value_sep || 'BIV_SERVICE_REQUEST' ||
                      biv_core_pkg.g_param_sep ||
                      'P_PREVR' || biv_core_pkg.g_value_sep || 'BIV_HS_SR_ACTIVITY' ||
                      biv_core_pkg.g_param_sep ||
                      biv_core_pkg.param_for_base_col ||
                      biv_core_pkg.g_value_sep ;
   l_new_param_str1 := l_new_param_str1 || 'jtfBinId' ||
                      biv_core_pkg.g_value_sep || l_drilldown_rep ||
                      biv_core_pkg.g_param_sep ||
                      biv_core_pkg.param_for_base_col ||
                      biv_core_pkg.g_value_sep ;

   l_loc := 'Before update of odd cols for drill down';
   update biv_tmp_hs2
      set id    = col1,
          col1  = l_new_param_str1|| nvl(col1,biv_core_pkg.g_null) ||
                      biv_core_pkg.g_param_sep || 'P_VIEW_BY' ||
                      biv_core_pkg.g_value_sep || l_new_view_by ||
                      biv_core_pkg.g_param_sep ||'P_ST_DATE' ||
                      biv_core_pkg.g_value_sep ||
                      to_char(l_start_date,l_dt_fmt) ||
                      biv_core_pkg.g_param_sep ||'P_END_DATE' ||
                      biv_core_pkg.g_value_sep ||
                      to_char(l_end_date-1,l_dt_fmt),
          col3  = l_new_param_str || nvl(col1,biv_core_pkg.g_null) ||
                      biv_core_pkg.g_param_sep ||'P_ST_DATE' ||
                      biv_core_pkg.g_value_sep ||
                      to_char(l_start_date,l_dt_fmt) ||
                      biv_core_pkg.g_param_sep ||
                      'P_OBLOG' || biv_core_pkg.g_value_sep || 'Y',
          col5  = l_new_param_str || nvl(col1,biv_core_pkg.g_null) ||
                      biv_core_pkg.g_param_sep ||'P_CR_ST' ||
                      biv_core_pkg.g_value_sep ||
                      to_char(l_start_date,l_dt_fmt) ||
                      biv_core_pkg.g_param_sep ||'P_CR_END' ||
                      biv_core_pkg.g_value_sep ||
          -- Change for Bug 3285048 l_end_date changed to l_end_date-1
                      to_char(l_end_date-1,l_dt_fmt),
          col7  = l_new_param_str || nvl(col1,biv_core_pkg.g_null) ||
                      biv_core_pkg.g_param_sep ||'P_CL_ST' ||
                      biv_core_pkg.g_value_sep ||
                      to_char(l_start_date,l_dt_fmt) ||
                      biv_core_pkg.g_param_sep ||'P_CL_END' ||
                      biv_core_pkg.g_value_sep ||
                      to_char(l_end_date-1,l_dt_fmt) ,
          col9  = l_new_param_str || nvl(col1,biv_core_pkg.g_null) ||
                      biv_core_pkg.g_param_sep ||'P_ST_DATE' ||
                      biv_core_pkg.g_value_sep ||
                      to_char(l_start_date,l_dt_fmt) ||
                      biv_core_pkg.g_param_sep ||'P_END_DATE' ||
                      biv_core_pkg.g_value_sep ||
         -- Change for Bug 3285048 l_end_date changed to l_end_date-1
                      to_char(l_end_date-1,l_dt_fmt) ||
                      biv_core_pkg.g_param_sep ||
                      'P_REOPEN' || biv_core_pkg.g_value_sep || 'Y',
          col11 = l_new_param_str || nvl(col1,biv_core_pkg.g_null) ||
                      biv_core_pkg.g_param_sep ||'P_ST_DATE' ||
                      biv_core_pkg.g_value_sep ||
                      to_char(l_start_date,l_dt_fmt) ||
                      biv_core_pkg.g_param_sep ||'P_END_DATE' ||
                      biv_core_pkg.g_value_sep ||
         -- Change for Bug 3285048 l_end_date changed to l_end_date-1
                      to_char(l_end_date-1,l_dt_fmt) ||
                      biv_core_pkg.g_param_sep ||
                      'P_RECLOSE' || biv_core_pkg.g_value_sep || 'Y',
          col13 = l_new_param_str || nvl(col1,biv_core_pkg.g_null) ||
                      biv_core_pkg.g_param_sep ||'P_END_DATE' ||
                      biv_core_pkg.g_value_sep ||
                      to_char(l_end_date,l_dt_fmt) ||
                      biv_core_pkg.g_param_sep ||
                      'P_EBLOG' || biv_core_pkg.g_value_sep || 'Y',
          col17 = l_new_param_str || nvl(col1,biv_core_pkg.g_null) ||
                      biv_core_pkg.g_param_sep ||'P_CR_ST' ||
                      biv_core_pkg.g_value_sep ||
                      to_char(l_start_date,l_dt_fmt) ||
                      biv_core_pkg.g_param_sep ||'P_CR_END' ||
                      biv_core_pkg.g_value_sep ||
         -- Change for Bug 3285048 changed l_end_date to l_end_date-1
                      to_char(l_end_date-1,l_dt_fmt) ||
                  biv_core_pkg.g_param_sep || 'P_CHNL=WEB',
           creation_date = sysdate
    where report_code = 'BIV_HS_SR_ACTIVITY'
      and session_id = l_session_id;

  ---
  --- Add a row fot toal of all column
  ---
  SELECT count(*) into l_ttl_recs
    FROM biv_tmp_hs2
   WHERE report_code = 'BIV_HS_SR_ACTIVITY'
     and session_id = l_session_id;
  if (l_debug = 'Y') then
     biv_core_pkg.biv_debug('Total Recs:'||to_char(l_ttl_recs),
                            biv_core_pkg.g_report_id);
  end if;
  if ( l_ttl_recs > 1 and ( l_ttl_recs < biv_core_pkg.g_disp or
                            biv_core_pkg.g_view_by = 'AGENT' or
                            biv_core_pkg.g_view_by = 'PRD') ) then
  if (l_debug = 'Y') then
     biv_core_pkg.biv_debug('Adding Total row',biv_core_pkg.g_report_id);
  end if;
     insert into biv_tmp_hs2 (report_code, rowno,
                              col4, col6, col8, col10, col12,
                              col14, col18, col1, session_id)
      SELECT report_code, max(rowno) + 1, sum(col4), sum(col6), sum(col8),
              sum(col10), sum(col12), sum(col14), sum(col18), 'Y', session_id
        FROM biv_tmp_hs2
       WHERE session_id = l_session_id
        and report_code = 'BIV_HS_SR_ACTIVITY'
       group by report_code, session_id;
   l_new_param_str := 'BIV_SERVICE_REQUEST' ||biv_core_pkg.g_param_sep ||
                       biv_core_pkg.reconstruct_param_str;
   --Change for bug 3188504 appended P_PREVR to the url
   l_new_param_str := l_new_param_str || 'jtfBinId' ||
                      biv_core_pkg.g_value_sep || 'BIV_SERVICE_REQUEST' ||
                      biv_core_pkg.g_param_sep || 'P_PREVR' ||
                      biv_core_pkg.g_value_sep || 'BIV_HS_SR_ACTIVITY' ||
                      biv_core_pkg.g_param_sep;
   l_new_param_str1:= l_drilldown_rep ||biv_core_pkg.g_param_sep ||
                       biv_core_pkg.reconstruct_param_str;
   l_new_param_str1 := l_new_param_str1 || 'jtfBinId' ||
                      biv_core_pkg.g_value_sep || l_drilldown_rep ||
                      biv_core_pkg.g_param_sep ;
   --
   if (biv_core_pkg.g_view_by = 'AGRP') then
       l_new_param_str := l_new_param_str || 'P_AGRP_LVL' ||
                      biv_core_pkg.g_value_sep || biv_core_pkg.g_lvl ||
                      biv_core_pkg.g_param_sep;
   elsif (biv_core_pkg.g_view_by = 'OGRP') then
       l_new_param_str := l_new_param_str || 'P_OGRP_LVL' ||
                      biv_core_pkg.g_value_sep || biv_core_pkg.g_lvl ||
                      biv_core_pkg.g_param_sep;
   end if;

   l_loc := 'Before update of odd cols for drill down for Total Row';
  SELECT count(*) into l_ttl_recs
    FROM biv_tmp_hs2
   WHERE report_code = 'BIV_HS_SR_ACTIVITY'
     and session_id = l_session_id;
  if (l_debug = 'Y') then
     biv_core_pkg.biv_debug('Total Recs:'||to_char(l_ttl_recs),
                            biv_core_pkg.g_report_id);
  end if;
   update biv_tmp_hs2
      set --id    = col1,
          col1  = l_new_param_str1|| 'P_VIEW_BY' ||
                      biv_core_pkg.g_value_sep || l_new_view_by ||
                      biv_core_pkg.g_param_sep ||'P_ST_DATE' ||
                      biv_core_pkg.g_value_sep ||
                      to_char(l_start_date,l_dt_fmt) ||
                      biv_core_pkg.g_param_sep ||'P_END_DATE' ||
                      biv_core_pkg.g_value_sep ||
                      to_char(l_end_date-1,l_dt_fmt),
          col3  = l_new_param_str || 'P_ST_DATE' ||
                      biv_core_pkg.g_value_sep ||
                      to_char(l_start_date,l_dt_fmt) ||
                      biv_core_pkg.g_param_sep ||
                      'P_OBLOG' || biv_core_pkg.g_value_sep || 'Y',
          col5  = l_new_param_str || 'P_CR_ST' ||
                      biv_core_pkg.g_value_sep ||
                      to_char(l_start_date,l_dt_fmt) ||
                      biv_core_pkg.g_param_sep ||'P_CR_END' ||
                      biv_core_pkg.g_value_sep ||
          -- Change for Bug 3285048 chnaged l_end_date to l_end_date-1
                      to_char(l_end_date-1,l_dt_fmt),
          col7  = l_new_param_str || 'P_CL_ST' ||
                      biv_core_pkg.g_value_sep ||
                      to_char(l_start_date,l_dt_fmt) ||
                      biv_core_pkg.g_param_sep ||'P_CL_END' ||
                      biv_core_pkg.g_value_sep ||
                      to_char(l_end_date-1,l_dt_fmt) ,
          col9  = l_new_param_str || 'P_ST_DATE' ||
                      biv_core_pkg.g_value_sep ||
                      to_char(l_start_date,l_dt_fmt) ||
                      biv_core_pkg.g_param_sep ||'P_END_DATE' ||
                      biv_core_pkg.g_value_sep ||
          -- Change for Bug 3285048 changed l_end_date to l_end_date-1
                      to_char(l_end_date-1,l_dt_fmt) ||
                      biv_core_pkg.g_param_sep ||
                      'P_REOPEN' || biv_core_pkg.g_value_sep || 'Y',
          col11 = l_new_param_str || 'P_ST_DATE' ||
                      biv_core_pkg.g_value_sep ||
                      to_char(l_start_date,l_dt_fmt) ||
                      biv_core_pkg.g_param_sep ||'P_END_DATE' ||
                      biv_core_pkg.g_value_sep ||
          -- Change for Bug 3285048 changed l_end_date to l_end_date-1
                      to_char(l_end_date-1,l_dt_fmt) ||
                      biv_core_pkg.g_param_sep ||
                      'P_RECLOSE' || biv_core_pkg.g_value_sep || 'Y',
          col13 = l_new_param_str || 'P_END_DATE' ||
                      biv_core_pkg.g_value_sep ||
                      to_char(l_end_date,l_dt_fmt) ||
                      biv_core_pkg.g_param_sep ||
                      'P_EBLOG' || biv_core_pkg.g_value_sep || 'Y',
          col17 = l_new_param_str || 'P_CR_ST' ||
                      biv_core_pkg.g_value_sep ||
                      to_char(l_start_date,l_dt_fmt) ||
                      biv_core_pkg.g_param_sep ||'P_CR_END' ||
                      biv_core_pkg.g_value_sep ||
          -- Change for Bug 3285048 changed l_end_date to l_end_date-1
                      to_char(l_end_date-1,l_dt_fmt) ||
                  biv_core_pkg.g_param_sep || 'P_CHNL=WEB',
           col2 = l_ttl_meaning,
           creation_date = sysdate
    where report_code = 'BIV_HS_SR_ACTIVITY'
      and session_id = l_session_id
      and col1 = 'Y';

   end if;
    l_loc := 'After update of odd cols';
    if (l_debug = 'Y') then
       biv_core_pkg.biv_debug('End of Report', biv_core_pkg.g_report_id);
    end if;
    biv_core_pkg.g_report_id := 'NULL';
    exception
       when others then
         if (l_debug = 'Y') then
            l_err := 'Err at ' || l_loc|| ':'|| substr(sqlerrm,1,500);
            biv_core_pkg.biv_debug(l_err,'BIV_HS_SR_ACTIVITY');
            commit;
         end if;
end;
function col_heading_10 (p_param_str varchar2) return varchar2 as
  l_view_by varchar2(80);
begin
  l_view_by := biv_core_pkg.get_parameter_value(p_param_str,'P_VIEW_BY');
  if (l_view_by = 'AGENT' or l_view_by = 'PRD') then
     return biv_core_pkg.get_lookup_meaning('AVG_BACKLOG_AGE');
  else
     return biv_core_pkg.get_lookup_meaning('TOTAL_HEAD_COUNT');
  end if;

end;
end;

/
