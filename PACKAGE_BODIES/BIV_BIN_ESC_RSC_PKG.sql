--------------------------------------------------------
--  DDL for Package Body BIV_BIN_ESC_RSC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIV_BIN_ESC_RSC_PKG" as
/* $Header: bivbescb.pls 115.19 2004/01/27 06:59:29 vganeshk ship $ */
  ---------------------------------------------
  procedure sr_esc_bin (p_param_str varchar2) is
     l_profile  varchar2(50) := 'BIV_DASH_' || fnd_global.user_id || '_' ||
                                 fnd_global.resp_id;
     l_report_code varchar2(50) := 'BIV_DASH_ESC_BIN';
     l_session_id biv_tmp_bin.session_id%type;
     l_new_param_str varchar2(2000);
     l_sql_sttmnt    varchar2(4000);
     l_from_list     varchar2(500);
     l_where_clause  varchar2(2000);
     l_cur           number;
     l_dummy         number;
     l_err           varchar2(2000);
     l_debug         varchar2(30) := fnd_profile.value('BIV:DEBUG');
  begin
     biv_core_pkg.g_report_id := 'BIV_BIN_SR_ESCALATION';

     l_session_id := biv_core_pkg.get_session_id;
     biv_core_pkg.clean_dcf_table('biv_tmp_bin');
     if (l_debug = 'Y') then
        biv_core_pkg.biv_debug('Parameters:'||p_param_str,
                               biv_core_pkg.g_report_id);
     end if;
     commit;
     /*
     l_new_param_str := 'BIV_TASK_SUMMARY' ||biv_core_pkg.g_param_sep ;
     l_new_param_str := l_new_param_str || 'jtfBinId' ||
                      biv_core_pkg.g_value_sep || 'BIV_TASK_SUMMARY' ||
     changed drill down to service request page 5/9/2
     */
     -- Change for Bug 3386946
     l_from_list := ' from jtf_task_references_b r,
                           cs_incidents_b_sec    sr,
                           jtf_tasks_b           t,
                           cs_incident_statuses_b stat,
                           fnd_lookups           lup
              ' ;
     biv_core_pkg.get_report_parameters(p_param_str);
     biv_core_pkg.get_where_clause(l_from_list, l_where_clause);
     l_where_clause := l_where_clause || '
           and sr.incident_id    = r.OBJECT_ID
           and sr.incident_status_id = stat.incident_status_id
           and nvl(stat.close_flag,''N'') <> ''Y''
           and r.object_type_code = ''SR''
           and r.reference_code   = ''ESC''
           and r.task_id          = t.task_id
           and t.task_type_id     = 22
           and lup.lookup_type    = ''JTF_TASK_ESC_LEVEL''
           and lup.lookup_code    = t.escalation_level
           ';

     l_sql_sttmnt := '
     insert into biv_tmp_bin(report_code,  col1, col2, col4,session_id)
        select ''BIV_BIN_SR_ESCALATION'',lup.lookup_code,lup.meaning,
                count(distinct sr.incident_id),:session_id
        ' || l_from_list || l_where_clause ||
        ' group by lup.lookup_code, lup.meaning';
     if (l_debug = 'Y') then
        biv_core_pkg.biv_debug(l_sql_sttmnt,biv_core_pkg.g_report_id);
        commit;
     end if;

     l_cur := dbms_sql.open_cursor;
     dbms_sql.parse(l_cur,l_sql_sttmnt,dbms_sql.native);
     biv_core_pkg.bind_all_variables(l_cur);
     dbms_sql.bind_variable(l_cur,':session_id',l_session_id);
     l_dummy := dbms_sql.execute(l_cur);
     dbms_sql.close_cursor(l_cur);

/**********************************************************************
     insert into biv_tmp_bin(report_code,  col1, col2, col4,session_id)
        select 'BIV_BIN_SR_ESCALATION',lup.lookup_code,lup.meaning,
                count(distinct t.task_id),l_session_id
          from jtf_task_references_b r,
               cs_incidents_all_b    ina,
               jtf_tasks_b           t,
               cs_incident_statuses_b stat,
               fnd_lookups           lup
         where ina.incident_id    = r.OBJECT_ID
           and ina.incident_status_id = stat.incident_status_id
           and nvl(stat.close_flag,'N') <> 'Y'
           and r.object_type_code = 'SR'
           and r.reference_code   = 'ESC'
           and r.task_id          = t.task_id
           and t.task_type_id     = 22
           and lup.lookup_type    = 'JTF_TASK_ESC_LEVEL'
           and lup.lookup_code    = t.escalation_level
         group by lup.lookup_code, lup.meaning;
*********************************************************************/
     l_new_param_str := 'BIV_SERVICE_REQUEST' ||biv_core_pkg.g_param_sep ||
                        biv_core_pkg.reconstruct_param_str;
     l_new_param_str := l_new_param_str || 'jtfBinId' ||
                      biv_core_pkg.g_value_sep || 'BIV_SERVICE_REQUEST' ||
                      biv_core_pkg.g_param_sep ||
                      'P_BLOG' ||
                      biv_core_pkg.g_value_sep || 'Y' ||
                      biv_core_pkg.g_param_sep ||
                      'P_ESC_LVL' ||
                      biv_core_pkg.g_value_sep ;

      update biv_tmp_bin
         set col1 = l_new_param_str || col1
       where report_code = 'BIV_BIN_SR_ESCALATION'
         and session_id = l_session_id;

     exception
       when others then
          rollback;
          if (l_debug = 'Y') then
             l_err := 'Error in SR_escalation:'|| substr(sqlerrm,1,1500);
             biv_core_pkg.biv_debug(l_err, biv_core_pkg.g_report_id);
             commit;
          end if;
  end sr_esc_bin;
  --------------------------------
  procedure resource_bin (p_param_str varchar2) is
     l_session_id biv_tmp_bin.session_id%type;
     l_new_param_str varchar2(2000);
     l_sql_sttmnt    varchar2(4000);
     l_from_list     varchar2(1000);
     l_where_clause  varchar2(2000);
     l_cur           number;
     l_dummy         number;
     l_debug         varchar2(30) := fnd_profile.value('BIV:DEBUG');
     l_all           fnd_lookups.meaning % type :=
                                biv_core_pkg.get_lookup_meaning('ALL');
  begin
     biv_core_pkg.g_report_id := 'BIV_BIN_RESOURCE';
     l_session_id := biv_core_pkg.get_session_id;
     biv_core_pkg.clean_dcf_table('biv_tmp_bin');

     biv_core_pkg.get_report_parameters(p_param_str);
     get_resource_where_clause(l_from_list, l_where_clause);

     l_new_param_str := 'BIV_RT_AGENT_REPORT' ||biv_core_pkg.g_param_sep ||
                        biv_core_pkg.reconstruct_param_str;
     l_new_param_str := l_new_param_str || 'jtfBinId' ||
                      biv_core_pkg.g_value_sep || 'BIV_RT_AGENT_REPORT' ||
                      biv_core_pkg.g_param_sep ||
                      'P_SRT_BY' || biv_core_pkg.g_value_sep || '1' ||
                      biv_core_pkg.g_param_sep ||
                      'P_RSC' || biv_core_pkg.g_value_sep ;

     l_sql_sttmnt := '
     insert into biv_tmp_bin ( report_code, rowno, col1, col2, col4,session_id)
      select ''BIV_BIN_RESOURCE'', rownum, id, descr, total,:session_id
        from (select nvl(ra.mode_of_availability,''ALL'') id,
                     nvl(ra.mode_of_availability,:all_meaning) descr,
                     count(*) total ' ||
              l_from_list || l_where_clause || '
              group by ra.mode_of_availability)';

     if (l_debug = 'Y') then
        biv_core_pkg.biv_debug(l_sql_sttmnt,biv_core_pkg.g_report_id);
     end if;
     --
     l_cur := dbms_sql.open_cursor;
     dbms_sql.parse(l_cur,l_sql_sttmnt,dbms_sql.native);
     biv_core_pkg.bind_all_variables(l_cur);
     if (l_debug = 'Y') then
        biv_core_pkg.biv_debug('Bef session binding',biv_core_pkg.g_report_id);
     end if;
     dbms_sql.bind_variable(l_cur,':session_id', l_session_id);
     if (l_debug = 'Y') then
        biv_core_pkg.biv_debug('Bef all binding',biv_core_pkg.g_report_id);
     end if;
     dbms_sql.bind_variable(l_cur,':all_meaning'       , l_all       );
     l_dummy := dbms_sql.execute(l_cur);

     -- web available employee count
     /*  3/13/02 web available is being inserted in above statement.
         This is due to change sql Statment.
     l_from_list := l_from_list || ',
                  jtf_rs_res_availability avl ';
     l_where_clause := l_where_clause || '
                  and avl.resource_id = rsc.resource_id';
     l_sql_sttmnt := '
     insert into biv_tmp_bin ( report_code, rowno, col1, col2, col4,session_id)
      select ''BIV_BIN_RESOURCE'', rownum, id, descr, total,:session_id
        from (select ''WEB'' id, ''WEB'' descr,count(*) total ' ||
              l_from_list || l_where_clause || ')';

     if (l_debug = 'Y') then
        biv_core_pkg.biv_debug(l_sql_sttmnt,biv_core_pkg.g_report_id);
        commit;
     end if;
     l_cur := dbms_sql.open_cursor;
     dbms_sql.parse(l_cur,l_sql_sttmnt,dbms_sql.native);
     biv_core_pkg.bind_all_variables(l_cur);
     dbms_sql.bind_variable(l_cur,':session_id', l_session_id);
     l_dummy := dbms_sql.execute(l_cur);
     */
/**************************************************************************
     insert into biv_tmp_bin ( report_code, rowno, col1, col2, col4,session_id)
      select 'BIV_BIN_RESOURCE', rownum, id, descr, total,l_session_id
        from (select 'ALL' id, 'ALL' descr,count(*) total
                from jtf_rs_resource_extns
               where category = 'EMPLOYEE'
             );
     insert into biv_tmp_bin ( report_code, rowno, col1, col2, col4,session_id)
      select 'BIV_BIN_RESOURCE', 2, id, descr, total,l_session_id
        from (select 'WEB' id, 'WEB' descr,count(*) total
                from jtf_rs_res_availability
             );
***************************************/
      update biv_tmp_bin
         set col1 = l_new_param_str ||  col1 ||
                      biv_core_pkg.g_param_sep ||
                      'P_DISP' ||
                      biv_core_pkg.g_value_sep || col4
        where report_code = 'BIV_BIN_RESOURCE'
          and session_id = l_session_id;
     exception
       when others then
         if (l_debug = 'Y') then
             biv_core_pkg.biv_debug(sqlerrm,biv_core_pkg.g_report_id);
             commit;
         end if;
  end resource_bin;
  ---------------------------------------------
  procedure tsk_summry_rep(p_param_str varchar2) is
     l_esc_lvl varchar2(80);
     l_session_id biv_tmp_bin.session_id%type;
     l_new_param_str varchar2(2000);
     l_sql_sttmnt    varchar2(4000);
     l_from_list     varchar2(1000);
     l_where_clause  varchar2(2000);
     l_cur           number;
     l_dummy         number;
     l_debug         varchar2(30) := fnd_profile.value('BIV:DEBUG');
  begin
     biv_core_pkg.g_report_id := 'BIV_TASK_SUMMARY';
     l_session_id := biv_core_pkg.get_session_id;
     biv_core_pkg.clean_dcf_table('biv_tmp_rt2');
     --l_esc_lvl := biv_core_pkg.get_parameter_value(p_esc_level, 'P_ESC_LVL');
     -- Change for Bug 3386946
     l_from_list := '
          from jtf_task_references_b r,
               cs_incidents_b_sec ina,
               cs_incident_statuses_vl stat,
               jtf_tasks_b task,
               jtf_rs_resource_extns rsc,
               hz_parties p';

     biv_core_pkg.get_report_parameters(p_param_str);
     biv_core_pkg.get_where_clause(l_from_list, l_where_clause);

     l_where_clause := l_where_clause || '
           and ina.incident_id    = r.OBJECT_ID
           and r.object_type_code = ''SR''
           and r.reference_code   = ''ESC''
           and r.TASK_ID          = task.task_id
           and task.task_type_id     = 22
           and ina.incident_status_id = stat.incident_status_id
           and ina.customer_id = p.party_id
           and task.owner_id      = rsc.resource_id
           and nvl(stat.close_flag,''N'') <> ''Y''';

               --'X' || biv_core_pkg.g_param_sep || 'task_id=' ||t.task_id,
     l_sql_sttmnt := '
           insert into biv_tmp_rt2(report_code, rowno, id,col2, col4,
                 col6, col8, col10, col12, col13,session_id)
              select ''BIV_TASK_SUMMARY'',
               rownum,
               task.task_id,
               task.task_number,
               p.party_name,
               stat.name,
               ina.incident_date,
               task.planned_end_date,
               rsc.source_name,
               reason_code,
               :session_id ' || l_from_list || l_where_clause;

     if (l_debug = 'Y') then
        biv_core_pkg.biv_debug(l_sql_sttmnt,biv_core_pkg.g_report_id);
     end if;
     l_cur := dbms_sql.open_cursor;
     dbms_sql.parse(l_cur,l_sql_sttmnt,dbms_sql.native);
     biv_core_pkg.bind_all_variables(l_cur);
     dbms_sql.bind_variable(l_cur,':session_id',l_session_id);
     l_dummy := dbms_sql.execute(l_cur);
     dbms_sql.close_cursor(l_cur);
     update biv_tmp_rt2
        set col1 = 'task' || biv_core_pkg.g_param_sep ||
                    'task_id' || biv_core_pkg.g_value_sep || id
     ;
     update biv_tmp_rt2 t
         set col14 = ( select meaning from fnd_lookups lup
                        where lup.lookup_code = t.col13
                          and lup.lookup_type = 'JTF_TASK_REASON_CODES'
                     );
    /*
           insert into biv_tmp_rt2(report_code, rowno, col1,col2, col4,
                 col6, col8, col10, col12, col14,session_id)
              select 'BIV_TASK_SUMMARY',
               rownum,
               'X' || biv_core_pkg.g_param_sep || 'task_id=' ||t.task_id,
               t.task_number,
               p.party_name,
               stat.name,
               ina.incident_date,
               t.planned_end_date,
               rsc.source_name,
               reason_code,
               l_session_id
          from jtf_task_references_b r,
               cs_incidents_all_b ina,
               cs_incident_statuses_vl stat,
               jtf_tasks_b t,
               jtf_rs_resource_extns rsc,
               hz_parties p
         where ina.incident_id    = r.OBJECT_ID
           and r.object_type_code = 'SR'
           and r.reference_code   = 'ESC'
           and r.TASK_ID          = t.task_id
           and t.task_type_id     = 22
           and ina.incident_status_id = stat.incident_status_id
           and ina.customer_id = p.party_id
           and t.owner_id      = rsc.resource_id
           and t.escalation_level = l_esc_lvl
           and nvl(stat.close_flag,'N') <> 'Y';
    */
    commit;
    exception
     when others then
        if (l_debug = 'Y') then
           biv_core_pkg.biv_debug(sqlerrm,biv_core_pkg.g_report_id);
        end if;
  end tsk_summry_rep;
  --------------------------------------------
  procedure rltd_task_rep(p_sr_id varchar2) is
     l_sr_id varchar2(20);
     l_session_id biv_tmp_bin.session_id%type;
     l_debug         varchar2(30) := fnd_profile.value('BIV:DEBUG');
  begin
     l_session_id := biv_core_pkg.get_session_id;
     biv_core_pkg.clean_dcf_table('biv_tmp_rt2');
     l_sr_id := biv_core_pkg.get_parameter_value(p_sr_id, 'P_SR_ID');
     insert into biv_tmp_rt2(report_code, rowno, col1,col2, col4, col6,
                                  col8, col10, col12, col14, col16,session_id)
      select 'BIV_RELATED_TASK_REPORT', rownum,
             tsk.task_id,
             tsk.task_number,
             tskl.task_name,
             tskl.description,
             pr.name,
             'ESC',
             stat.name,
             rsc.source_name,
             typ.name,
             l_session_id
        from jtf_tasks_b  tsk,
             jtf_tasks_tl tskl,
             jtf_task_priorities_vl pr,
             jtf_task_statuses_vl   stat,
             jtf_task_types_vl      typ,
             jtf_rs_resource_extns  rsc
       where tsk.source_object_type_code = 'SR'
         and tsk.source_object_id        = to_number(l_sr_id)
         and tsk.task_status_id          = stat.task_status_id
         and tsk.task_type_id            = typ.task_type_id
         and tsk.task_priority_id        = pr.task_priority_id
         and tsk.owner_id                = rsc.resource_id (+)
         and tsk.task_id                 = tskl.task_id (+)
         and userenv('LANG')             = tskl.language (+)
 ;
  end rltd_task_rep;
  ---------------------------------------------------
  procedure get_resource_where_clause (p_from_list    out nocopy varchar2,
                                      p_where_clause  out nocopy varchar2) is
  begin
     p_from_list := '
                  from jtf_rs_resource_extns rsc,
                       jtf_objects_vl o,
                       jtf_object_usages ou,
                       jtf_rs_res_availability ra ';
     -- to_date removed because of GSCC fail
     p_where_clause := '
            WHERE rsc.category = o.object_code
              and o.object_code = ou.object_code
              and ou.object_user_code = ''RESOURCE_CATEGORIES''
              and rsc.resource_id = ra.resource_id (+)
              and sysdate between
                       nvl(rsc.start_date_active,sysdate-1)
                   and nvl(rsc.end_date_active, sysdate+1) ';
     -----
     if (biv_core_pkg.g_agrp_cnt > 0 ) then
       p_from_list := p_from_list || ',
                            jtf_rs_groups_denorm adnorm1,
                            jtf_rs_group_members agmmbr';
       p_where_clause := p_where_clause || '
             and agmmbr.group_id = adnorm1.group_id
             and rsc.resource_id = agmmbr.resource_id ';
     end if;
     -----
     if (biv_core_pkg.g_ogrp_cnt > 0) then
       p_from_list := p_from_list || ',
                            jtf_rs_groups_denorm odnorm1,
                            jtf_rs_group_members ogmmbr';
       p_where_clause := p_where_clause || '
             and ogmmbr.group_id = odnorm1.group_id
             and rsc.resource_id = ogmmbr.resource_id ';
     end if;
     -----
     /* 3/13/02 where clause for resource changed. resources are now obtained
        by joining jtf_rs_resurce_extns with jtf_object, jtf_object_usages
        and jtd_res_availability tables.

     p_where_clause := p_where_clause || '
              and category = ''EMPLOYEE''';
     */
     biv_core_pkg.add_a_condition(biv_core_pkg.g_ogrp,
                                  biv_core_pkg.g_ogrp_cnt,
                                  'odnorm1', 'parent_group_id',
                                  null, p_where_clause);
     biv_core_pkg.add_a_condition(biv_core_pkg.g_agrp,
                                  biv_core_pkg.g_agrp_cnt,
                                  'adnorm1', 'parent_group_id',
                                  null, p_where_clause);
     biv_core_pkg.add_a_condition(biv_core_pkg.g_mgr_id,
                                  biv_core_pkg.g_mgr_id_cnt,
                                  'rsc', 'source_mgr_id',
                                  null, p_where_clause);
  end get_resource_where_clause;
  -----------------------------
end;

/
